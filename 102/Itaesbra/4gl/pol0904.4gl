#-------------------------------------------------------------------#
# SISTEMA.: MANUTENCAO INDUSTRIAL                                   #
# PROGRAMA: pol0904                                                 #
# MODULOS.: pol0904-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: ARMAZENAR O ENDERECO DAS FERRAMENTAS POIS O lOGIX NAO   #
#           POSSUI CAMPO PARA ESTA FINALIDADE                       # 
# AUTOR...: POLO INFORMATICA - MANUEL                               #
# DATA....: 19/01/2009                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_equip          LIKE componente.des_compon_reduz,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
#          p_versao             CHAR(17),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_msg                CHAR(500)
          

   DEFINE p_ferramenta_end_970   RECORD LIKE ferramenta_end_970.*,
          p_ferramenta_end_970a  RECORD LIKE ferramenta_end_970.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0904-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0904.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#   CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0904_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0904_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0904") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0904 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0904_inclusao() RETURNING p_status
      COMMAND "Modificar" "Inclui Dados do Endereço da Ferramenta"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0904_modificacao()
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados do Endereço da Ferramenta"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0904_exclusao()
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados do Endereço da Ferramenta"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0904_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0904_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0904_paginacao("ANTERIOR")
      COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0904","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0904_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0904.tmp'
                     START REPORT pol0904_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0904_relat TO p_nom_arquivo
               END IF
               CALL pol0904_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0904_relat   
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
         CALL pol0904_sobre()
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
   CLOSE WINDOW w_pol0904

END FUNCTION

#--------------------------#
 FUNCTION pol0904_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   IF pol0904_entrada_dados("INCLUSAO") THEN
      LET p_ferramenta_end_970.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO ferramenta_end_970 VALUES (p_ferramenta_end_970.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","ferramenta_end_970")       
      ELSE
         CALL log085_transacao("COMMIT")
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
      WHENEVER ERROR STOP
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      INITIALIZE p_ferramenta_end_970.* TO NULL
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0904_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0904
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_ferramenta_end_970.* TO NULL
      CALL pol0904_exibe_dados()
      LET p_ferramenta_end_970.cod_empresa = p_cod_empresa
   END IF

    INPUT BY NAME p_ferramenta_end_970.* WITHOUT DEFAULTS 
       
       BEFORE FIELD cod_ferramenta
          IF p_funcao <> 'INCLUSAO' THEN
             NEXT FIELD prateleira
          END IF
          
       AFTER FIELD cod_ferramenta
          IF p_ferramenta_end_970.cod_ferramenta IS NULL OR 
             p_ferramenta_end_970.cod_ferramenta = " " THEN 
             ERROR 'Informe o Código da Ferramenta...'
             NEXT FIELD cod_ferramenta
          ELSE
             IF pol0904_verifica_ferramenta() = FALSE THEN
                ERROR 'Ferramenta nao cadastrada.'
                NEXT FIELD cod_ferramenta
             ELSE
                IF pol0904_verifica_duplicidade() THEN
                   ERROR 'Ferramenta já Cadastrada.'
                   NEXT FIELD cod_ferramenta
                END IF 
             END IF    
          END IF 
       
       AFTER FIELD prateleira
          IF p_ferramenta_end_970.prateleira IS NULL OR 
             p_ferramenta_end_970.prateleira  = " " THEN 
             ERROR 'Informe uma Prateleira...'
             NEXT FIELD prateleira
          END IF 

                            
       ON KEY (f4,control-z)
          CALL pol0904_popup()

    END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0904

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0904_verifica_ferramenta()
#--------------------------------------#
   
   SELECT des_compon_reduz
     INTO p_den_equip
     FROM componente
    WHERE cod_empresa  = p_cod_empresa
      AND cod_compon   = p_ferramenta_end_970.cod_ferramenta
   
   IF SQLCA.sqlcode = 0 THEN
      DISPLAY p_den_equip TO des_compon_reduz
      RETURN TRUE
   ELSE
      RETURN FALSE 
   END IF
   
END FUNCTION 
#--------------------------------------#
 FUNCTION pol0904_verifica_duplicidade()
#--------------------------------------#
   
   SELECT UNIQUE cod_ferramenta
     FROM ferramenta_end_970
    WHERE cod_empresa = p_cod_empresa
      AND cod_ferramenta = p_ferramenta_end_970.cod_ferramenta
   
   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 
#--------------------------#
 FUNCTION pol0904_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ferramenta_end_970a.* = p_ferramenta_end_970.*

 CONSTRUCT BY NAME where_clause ON ferramenta_end_970.cod_ferramenta,
                                   ferramenta_end_970.prateleira

    ON KEY (f4,control-z)
       CALL pol0904_popup()
 
 END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0904

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ferramenta_end_970.* = p_ferramenta_end_970a.*
      CALL pol0904_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM ferramenta_end_970 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " and cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY cod_ferramenta "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_ferramenta_end_970.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0904_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0904_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_ferramenta_end_970.*
   DISPLAY p_cod_empresa TO cod_empresa


   INITIALIZE p_den_equip TO NULL
   SELECT des_compon_reduz
     INTO p_den_equip
     FROM componente
    WHERE cod_empresa = p_cod_empresa
      AND cod_compon  = p_ferramenta_end_970.cod_ferramenta
   
   DISPLAY p_den_equip TO des_compon_reduz
   
   
END FUNCTION


#-----------------------------------#
 FUNCTION pol0904_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * INTO p_ferramenta_end_970.*                                              
      FROM ferramenta_end_970  
         WHERE cod_empresa    = p_ferramenta_end_970.cod_empresa
           AND cod_ferramenta = p_ferramenta_end_970.cod_ferramenta
             FOR UPDATE 
   CALL log085_transacao("BEGIN")   
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","ferramenta_end_970")
   END CASE
   CALL log085_transacao("ROLLBACK")
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0904_modificacao()
#-----------------------------#

   IF pol0904_cursor_for_update() THEN
      LET p_ferramenta_end_970a.* = p_ferramenta_end_970.*
      IF pol0904_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE ferramenta_end_970 
            SET prateleira       = p_ferramenta_end_970.prateleira
                WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("MODIFICACAO","ferramenta_end_970")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
         LET p_ferramenta_end_970.* = p_ferramenta_end_970a.*
         ERROR "Modificacao Cancelada"
         CALL pol0904_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0904_exclusao()
#--------------------------#

   IF pol0904_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM ferramenta_end_970
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE p_ferramenta_end_970.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            CALL log085_transacao("ROLLBACK")
            CALL log003_err_sql("EXCLUSAO","ferramenta_end_970")
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0904_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_ferramenta_end_970a.* = p_ferramenta_end_970.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_ferramenta_end_970.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_ferramenta_end_970.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_ferramenta_end_970.* = p_ferramenta_end_970a.* 
            EXIT WHILE
         END IF

         SELECT * INTO p_ferramenta_end_970.* 
         FROM ferramenta_end_970
            WHERE cod_empresa    = p_ferramenta_end_970.cod_empresa
              AND cod_ferramenta = p_ferramenta_end_970.cod_ferramenta
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0904_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0904_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_oper CURSOR FOR
      SELECT * FROM ferramenta_end_970
       WHERE cod_empresa = p_cod_empresa
       ORDER BY cod_ferramenta
   
   FOREACH cq_oper INTO p_ferramenta_end_970.*
 
      INITIALIZE p_den_equip TO NULL
      
   SELECT des_compon_reduz
     INTO p_den_equip
     FROM componente
    WHERE cod_empresa  = p_cod_empresa
      AND cod_compon   = p_ferramenta_end_970.cod_ferramenta
   
  
      OUTPUT TO REPORT pol0904_relat(p_ferramenta_end_970.*) 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#------------------------------#
 REPORT pol0904_relat(p_relat)
#------------------------------#

   DEFINE p_relat RECORD 
      cod_empresa      LIKE ferramenta_end_970.cod_empresa,
      cod_ferramenta   LIKE ferramenta_end_970.cod_ferramenta,    
      prateleira       LIKE ferramenta_end_970.prateleira

   END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 072, "PAG.: ", PAGENO USING "##&"
         PRINT COLUMN 001, "pol0904",
               COLUMN 030, "ENDERECO DAS FERRAMENTAS",
               COLUMN 065, "DATA: ", DATE USING "dd/mm/yyyy"
                
         PRINT COLUMN 001, "*---------------------------------------",
                           "---------------------------------------*"
         PRINT
         PRINT COLUMN 001, "  COD FERRAMENTA      DESCRICAO                     PRATELEIRA"
         PRINT COLUMN 001, "------------------  ------------------------------ -----------------"
      

      ON EVERY ROW

         PRINT COLUMN 003, p_relat.cod_ferramenta,
               COLUMN 023, p_den_equip,
               COLUMN 054, p_relat.prateleira
               
   
END REPORT


#-----------------------#
 FUNCTION pol0904_popup()
#-----------------------#
   CASE

      WHEN INFIELD(cod_ferramenta)
         CALL log009_popup(6,20,"EQUIPAMENTOS","componente",
                          "cod_compon","des_compon",
                          "","S","") RETURNING p_ferramenta_end_970.cod_ferramenta
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0904
         DISPLAY BY NAME p_ferramenta_end_970.cod_ferramenta

   END CASE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0904_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#


