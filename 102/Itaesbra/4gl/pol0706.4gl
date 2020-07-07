#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0706                                                 #
# MODULOS.: pol0706-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO GRUPO RECURSOS - ITAESBRA                      #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 26/12/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
        # p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
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
          p_cod_grupo          CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_msg                CHAR(500)
          
   DEFINE p_grupo_desc_970   RECORD LIKE grupo_desc_970.*,
          p_grupo_desc_970a  RECORD LIKE grupo_desc_970.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0706-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0706.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0706_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0706_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0706") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0706 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0706_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0706_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0706_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0706_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0706_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0706_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
          COMMAND "Listar" "Lista os Dados Cadastrados"
         HELP 007
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0706","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0706_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0706.tmp'
                     START REPORT pol0706_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0706_relat TO p_nom_arquivo
               END IF
               CALL pol0706_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0706_relat   
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
         CALL pol0706_sobre()
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
   CLOSE WINDOW w_pol0706

END FUNCTION

#--------------------------#
 FUNCTION pol0706_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_grupo_desc_970.* TO NULL
   LET p_grupo_desc_970.cod_empresa = p_cod_empresa

   IF pol0706_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO grupo_desc_970 VALUES (p_grupo_desc_970.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0706_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0706

   INPUT BY NAME p_grupo_desc_970.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_grupo
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD descricao_grupo
      END IF 
      
      AFTER FIELD cod_grupo
      IF p_grupo_desc_970.cod_grupo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_grupo
      ELSE
                
         SELECT cod_grupo
           FROM grupo_desc_970
          WHERE cod_empresa    = p_cod_empresa
            AND cod_grupo = p_grupo_desc_970.cod_grupo
          
         IF STATUS = 0 THEN
            ERROR "Código do Formulario já Cadastrado na Tabela grupo_desc_970 !!!"
            NEXT FIELD cod_grupo
         END IF
      END IF
         
      AFTER FIELD descricao_grupo
      IF p_grupo_desc_970.descricao_grupo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD descricao_grupo
      END IF
      
          ON KEY (control-z)
      CALL pol0706_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0706

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0706_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_grupo_desc_970a.* = p_grupo_desc_970.*

   CONSTRUCT BY NAME where_clause ON grupo_desc_970.cod_grupo
  
            ON KEY (control-z)
      CALL pol0706_popup()
  
  
 {     ON KEY (control-z)
      LET p_cod_grupo = pol0706_carrega_form()
      IF p_cod_grupo IS NOT NULL THEN
         LET p_grupo_desc_970.cod_grupo = p_cod_grupo
         CURRENT WINDOW IS w_pol0706
         DISPLAY p_grupo_desc_970.cod_grupo TO cod_grupo
      END IF   }

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0706

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_grupo_desc_970.* = p_grupo_desc_970a.*
      CALL pol0706_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM grupo_desc_970 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_grupo "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_grupo_desc_970.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0706_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0706_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_grupo_desc_970.*
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0706_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_grupo_desc_970.*                                              
     FROM grupo_desc_970
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grupo = p_grupo_desc_970.cod_grupo
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","grupo_desc_970")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0706_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0706_cursor_for_update() THEN
      LET p_grupo_desc_970a.* = p_grupo_desc_970.*
      IF pol0706_entrada_dados("MODIFICACAO") THEN
         UPDATE grupo_desc_970
            SET cod_grupo = p_grupo_desc_970.cod_grupo,
                descricao_grupo   = p_grupo_desc_970.descricao_grupo
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","grupo_desc_970")
         END IF
      ELSE
         LET p_grupo_desc_970.* = p_grupo_desc_970a.*
         CALL pol0706_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0706_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0706_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM grupo_desc_970
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_grupo_desc_970.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","grupo_desc_970")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0706_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_grupo_desc_970a.* = p_grupo_desc_970.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_grupo_desc_970.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_grupo_desc_970.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_grupo_desc_970.* = p_grupo_desc_970a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_grupo_desc_970.*
           FROM grupo_desc_970
          WHERE cod_empresa    = p_cod_empresa
            AND cod_grupo = p_grupo_desc_970.cod_grupo
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0706_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0706_emite_relatorio()
#-----------------------------------#

   
   DECLARE cq_grupo_desc_970 CURSOR FOR
    SELECT * 
      FROM grupo_desc_970
     ORDER BY cod_grupo
     
     FOREACH cq_grupo_desc_970 INTO p_grupo_desc_970.*
         
         SELECT cod_grupo
           FROM grupo_desc_970
          WHERE cod_empresa    = p_cod_empresa
            AND cod_grupo = p_grupo_desc_970.cod_grupo
           
        OUTPUT TO REPORT pol0706_relat() 
        LET p_count = p_count + 1
      
      
   END FOREACH
  
END FUNCTION 




#---------------------#
 REPORT pol0706_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT COLUMN 001, "CADASTRO GRUPO DE RECURSOS ",
               COLUMN 025, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 055, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "                RELATORIO GRUPO DE RECURSOS                        "
         PRINT COLUMN 001, "-------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "                                                                   "
         PRINT COLUMN 001, "    CODIGO                        DESCRIÇÃO                        "       
         PRINT COLUMN 001, "----------------   ------------------------------------------------"

      ON EVERY ROW

         PRINT COLUMN 005, p_grupo_desc_970.cod_grupo,
               COLUMN 023, p_grupo_desc_970.descricao_grupo
              
         
END REPORT












#-----------------------#
FUNCTION pol0706_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_grupo)
         CALL log009_popup(5,12,"GRUPO","grupo_desc_970",
              "cod_grupo","descricao_grupo","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0705
         IF p_codigo IS NOT NULL THEN
           LET p_grupo_desc_970.cod_grupo = p_codigo CLIPPED
           DISPLAY p_grupo_desc_970.cod_grupo TO cod_grupo
         END IF
      
         
   END CASE
END FUNCTION 










{#-----------------------------------#   
 FUNCTION pol0706_carrega_form() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_grupo LIKE grupo_desc_970.cod_grupo,
         descricao      LIKE grupo_desc_970.descricao
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07061") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07061 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_grupo,
           descricao
      FROM grupo_desc_970
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_grupo

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_grupo, 
                         pr_lista[pr_index].descricao                      

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0706

   LET p_grupo_desc_970.cod_grupo = pr_lista[pr_index].cod_grupo
   
   RETURN pr_lista[pr_index].cod_grupo
      
END FUNCTION }

#-----------------------#
 FUNCTION pol0706_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

