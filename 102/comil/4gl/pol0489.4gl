#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: pol0489                                                 #
# MODULOS.: pol0489 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA IT_ANALISE_COMIL                   #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 05/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),
					p_msg                CHAR(500)
          
END GLOBALS

    DEFINE p_it_analise_comil  RECORD LIKE it_analise_comil.*,
           p_it_analise_comilr RECORD LIKE it_analise_comil.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	 LET p_versao = "pol0489-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0489.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0489_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0489_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0489") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0489 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0489_incluir() RETURNING p_status
         LET p_ies_cons = FALSE   
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0489_modificar()
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0489_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 002
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0489_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0489_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0489_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0489","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0489_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0489.tmp'
                     START REPORT pol0489_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0489_relat TO p_nom_arquivo
               END IF
               CALL pol0489_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0489_relat   
            ELSE
               CONTINUE MENU
            END IF                                                     
            IF p_ies_impressao = "S" THEN
               MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
               IF g_ies_ambiente = "W" THEN
                  LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", 
                                p_nom_arquivo
                  RUN comando
               END IF
            ELSE
               MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo,
                  " " ATTRIBUTE(REVERSE)
            END IF                              
            NEXT OPTION "Fim"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	 			CALL pol0489_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0489

END FUNCTION

#--------------------------#
 FUNCTION pol0489_incluir()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0489_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      LET p_it_analise_comil.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO it_analise_comil VALUES (p_it_analise_comil.*)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","it_analise_comil")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      ERROR "Inclusão Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0489_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0489
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_it_analise_comil.* TO NULL
      LET p_it_analise_comil.ies_tip_texto = 'N'
   END IF

   INPUT BY NAME p_it_analise_comil.* WITHOUT DEFAULTS  

      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_analise
         END IF

      AFTER FIELD tip_analise  
         IF p_it_analise_comil.tip_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD tip_analise  
         END IF

         SELECT cod_empresa
           FROM it_analise_comil
          WHERE cod_empresa = p_cod_empresa  
            AND tip_analise = p_it_analise_comil.tip_analise

         IF STATUS = 0 THEN
            ERROR "Tipo de análise já Cadastrada."
            NEXT FIELD tip_analise
         END IF
                  
      AFTER FIELD den_analise    
         IF p_it_analise_comil.den_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_analise
         END IF

         
      AFTER FIELD ies_tip_texto
         IF p_it_analise_comil.ies_tip_texto IS NULL OR      
            p_it_analise_comil.ies_tip_texto = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR 'Campo de preenchimento obrigatório.'
               NEXT FIELD ies_tip_texto
            END IF
         ELSE
            IF p_it_analise_comil.ies_tip_texto <> 'S' AND 
               p_it_analise_comil.ies_tip_texto <> 'N' THEN
               ERROR 'Valor inválido. Informe S - Sim ou N - Não'
               NEXT FIELD ies_tip_texto
            END IF
         END IF

      END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0489
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0489_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   LET p_it_analise_comilr.* = p_it_analise_comil.*

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON it_analise_comil.tip_analise,   
                                     it_analise_comil.den_analise
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0489

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_it_analise_comil.* = p_it_analise_comilr.*
      CALL pol0489_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM it_analise_comil ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_it_analise_comil.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0489_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0489_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME p_it_analise_comil.tip_analise,
                   p_it_analise_comil.den_analise,
                   p_it_analise_comil.ies_tip_texto

END FUNCTION

#-----------------------------------#
 FUNCTION pol0489_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_it_analise_comilr.* = p_it_analise_comil.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_it_analise_comil.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_it_analise_comil.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET p_it_analise_comil.* = p_it_analise_comilr.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO p_it_analise_comil.* 
           FROM it_analise_comil   
          WHERE cod_empresa = p_it_analise_comil.cod_empresa
            AND tip_analise = p_it_analise_comil.tip_analise
             
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0489_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0489_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR FOR
    SELECT *                            
      INTO p_it_analise_comil.*                                              
      FROM it_analise_comil 
     WHERE cod_empresa = p_it_analise_comil.cod_empresa
       AND tip_analise = p_it_analise_comil.tip_analise
       FOR UPDATE 
   CALL log085_transacao("BEGIN")
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usuá",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro não mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","IT_ANALISE_comil")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0489_modificar()
#-----------------------------#

   IF pol0489_cursor_for_update() THEN
      LET p_it_analise_comilr.* = p_it_analise_comil.*
      IF pol0489_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE it_analise_comil
            SET den_analise     = p_it_analise_comil.den_analise,
                ies_tip_texto   = p_it_analise_comil.ies_tip_texto 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","IT_ANALISE_comil")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","IT_ANALISE_comil")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET p_it_analise_comil.* = p_it_analise_comilr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_it_analise_comil.tip_analise
         DISPLAY BY NAME p_it_analise_comil.den_analise
         DISPLAY BY NAME p_it_analise_comil.ies_tip_texto
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0489_exclusao()
#--------------------------#

   IF pol0489_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM it_analise_comil 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","IT_ANALISE_comil")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_it_analise_comil.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","IT_ANALISE_comil")
            CALL log085_transacao("ROLLBACK")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0489_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_listar CURSOR FOR
    SELECT *
      FROM it_analise_comil
     WHERE cod_empresa = p_cod_empresa
     ORDER BY 1
     
   FOREACH cq_listar INTO p_it_analise_comil.*

      OUTPUT TO REPORT pol0489_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0489_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "pol0489              TIPOS DE ANALISES DO PRODUTO",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"

         PRINT

         PRINT COLUMN 003, "ANALISE      DESCRICAO PORTUGUES        TEXTO"
         PRINT COLUMN 003, "------- ------------------------------  -----"
         
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 003, p_it_analise_comil.tip_analise USING '######',
               COLUMN 011, p_it_analise_comil.den_analise,
               COLUMN 043, p_it_analise_comil.ies_tip_texto
         
END REPORT


#-----------------------#
 FUNCTION pol0489_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION



#----------------------------- FIM DE PROGRAMA --------------------------------#
