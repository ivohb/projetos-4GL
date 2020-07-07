#-------------------------------------------------------------------#
# SISTEMA.: ANÁLISE DOS PRODUTOS                                    #
# PROGRAMA: pol0494                                                 #
# MODULOS.: pol0494-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
#           min0710.4go                                             #
# OBJETIVO: CADASTRO DE CLIENTES P/ OMISSÃO DO LAUDO                #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 26/10/2006                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
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


   DEFINE p_cli_laudo_comil RECORD LIKE cli_laudo_comil.*

   DEFINE pr_cliente      ARRAY[2000] OF RECORD
          cod_cliente     LIKE clientes.cod_cliente,
          nom_cliente     LIKE clientes.nom_cliente
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
	LET p_versao = "pol0494-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0494.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0494_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0494_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0494") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0494 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         INITIALIZE pr_cliente TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         WHENEVER ERROR CONTINUE
         CALL log085_transacao("BEGIN")
         CALL pol0494_incluir() RETURNING p_status
         IF p_status THEN
            CALL log085_transacao("COMMIT")	      
            MESSAGE "Inclusão de Dados Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            CALL log085_transacao("ROLLBACK")
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
         WHENEVER ERROR STOP
         LET p_ies_cons = FALSE   
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 002
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0494_consulta()
      COMMAND "Modificar" "Modifica dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            CALL pol0494_modificar()
         ELSE
            ERROR "Execute Previamente a Consulta !!!"
         END IF
      COMMAND "Listar" "Lista os Dados do Cadastro"
         HELP 003
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0494","MO") THEN
            IF log028_saida_relat(18,35) IS NOT NULL THEN
               MESSAGE " Processando a Extracao do Relatorio..." 
                  ATTRIBUTE(REVERSE)
               IF p_ies_impressao = "S" THEN
                  IF g_ies_ambiente = "U" THEN
                     START REPORT pol0494_relat TO PIPE p_nom_arquivo
                  ELSE
                     CALL log150_procura_caminho ('LST') RETURNING p_caminho
                     LET p_caminho = p_caminho CLIPPED, 'pol0494.tmp'
                     START REPORT pol0494_relat  TO p_caminho
                  END IF
               ELSE
                  START REPORT pol0494_relat TO p_nom_arquivo
               END IF
               CALL pol0494_emite_relatorio()   
               IF p_count = 0 THEN
                  ERROR "Nao Existem Dados para serem Listados" 
               ELSE
                  ERROR "Relatorio Processado com Sucesso" 
               END IF
               FINISH REPORT pol0494_relat   
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
	 			CALL pol0494_sobre()
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
   CLOSE WINDOW w_pol0494

END FUNCTION

#-----------------------#
FUNCTION pol0494_incluir()
#-----------------------#
   
   INPUT ARRAY pr_cliente
      WITHOUT DEFAULTS FROM sr_cliente.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      AFTER FIELD cod_cliente
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
            IF pr_cliente[p_index].cod_cliente IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               NEXT FIELD cod_cliente
            END IF
         END IF
         
         IF pr_cliente[p_index].cod_cliente IS NOT NULL THEN
            IF pol0494_repetiu_cod() THEN
               ERROR "Cliente ",pr_cliente[p_index].cod_cliente CLIPPED ," já Informado !!!"
               NEXT FIELD cod_cliente
            ELSE
              SELECT nom_cliente
                INTO pr_cliente[p_index].nom_cliente
                FROM clientes
               WHERE cod_cliente = pr_cliente[p_index].cod_cliente
               IF STATUS = 0 THEN 
                  DISPLAY pr_cliente[p_index].nom_cliente TO 
                          sr_cliente[s_index].nom_cliente
               ELSE
                  ERROR "Cliente Não Existente !!!"
                  NEXT FIELD cod_cliente
               END IF
               SELECT cod_empresa
                 FROM cli_laudo_comil
                WHERE cod_empresa = p_cod_empresa
                  AND cod_cliente = pr_cliente[p_index].cod_cliente
               IF STATUS = 0 THEN
                  ERROR "Cliente Já Cadastrado !!!"
                  NEXT FIELD cod_cliente
               END IF
            END IF
         END IF
         
      ON KEY (control-z)
         CALL pol0494_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      IF pol0494_grava_itens() THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   
   
END FUNCTION

#-------------------------------#
FUNCTION pol0494_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_cliente[p_ind].cod_cliente = pr_cliente[p_index].cod_cliente THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   
   RETURN FALSE
   
END FUNCTION


#-----------------------#
FUNCTION pol0494_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0494
         IF p_codigo IS NOT NULL THEN
            LET pr_cliente[p_index].cod_cliente = p_codigo
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE

END FUNCTION 


#-----------------------------#
FUNCTION pol0494_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_cliente[p_ind].cod_cliente IS NOT NULL THEN
          INSERT INTO cli_laudo_comil
           VALUES(p_cod_empresa,
                  pr_cliente[p_ind].cod_cliente)
          IF SQLCA.sqlcode <> 0 THEN 
             CALL log003_err_sql("INCLUSÃO","cli_laudo_comil")
             RETURN FALSE
          END IF
       END IF
   END FOR

   RETURN TRUE
   
END FUNCTION


#--------------------------#
 FUNCTION pol0494_consulta()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_cliente = p_cli_laudo_comil.cod_cliente

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol04941") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol04941 AT 5,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   
   CONSTRUCT BY NAME where_clause ON 
      cli_laudo_comil.cod_cliente

#      ON KEY (control-z)
#         CALL pol0494_popup()
         
#   END CONSTRUCT

   CLOSE WINDOW w_pol04941
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0494

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   CALL pol0494_exibe_dados()

END FUNCTION


#-------------------------------#
 FUNCTION pol0494_exibe_dados()
#-------------------------------#

   LET sql_stmt = "SELECT cod_cliente FROM cli_laudo_comil ",
                  " WHERE ", where_clause CLIPPED,                 
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  "ORDER BY 1"

   LET p_index = 1

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao CURSOR FOR var_query
   
   FOREACH cq_padrao INTO pr_cliente[p_index].cod_cliente

      INITIALIZE pr_cliente[p_index].nom_cliente TO NULL
      
      SELECT nom_cliente
        INTO pr_cliente[p_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = pr_cliente[p_index].cod_cliente

      LET p_index = p_index + 1

   END FOREACH

   IF p_index > 1 THEN   
      LET p_ies_cons = TRUE
      CALL SET_COUNT(p_index - 1)

      DISPLAY ARRAY pr_cliente TO sr_cliente.*

         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE() 
   ELSE
      ERROR 'Argumentos de pesquisa não encontrado !!!'
   END IF

END FUNCTION 

#---------------------------#
FUNCTION pol0494_modificar()
#---------------------------#

   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   FOR p_ind = 1 TO ARR_COUNT()
   
      DELETE FROM cli_laudo_comil
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente = pr_cliente[p_ind].cod_cliente

   END FOR
   
   CALL pol0494_incluir() RETURNING p_status

   IF p_status THEN
      CALL log085_transacao("COMMIT")	      
      MESSAGE "Modificação de Dados Efetuada c/ Sucesso !!!"
          ATTRIBUTE(REVERSE)
   ELSE
     CALL log085_transacao("ROLLBACK")
     MESSAGE "Operação Cancelada !!!"  ATTRIBUTE(REVERSE)
  END IF      
 
  WHENEVER ERROR STOP

END FUNCTION

#-----------------------------------#
 FUNCTION pol0494_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_listar CURSOR FOR
    SELECT a.cod_cliente,
           b.nom_cliente
      FROM cli_laudo_comil a,
           clientes b
     WHERE a.cod_empresa = p_cod_empresa
       AND b.cod_cliente = a.cod_cliente
     ORDER BY 1
     
   FOREACH cq_listar INTO 
           p_cod_cliente,
           p_nom_cliente

      OUTPUT TO REPORT pol0494_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH
  
END FUNCTION 

#----------------------#
 REPORT pol0494_relat()
#----------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT COLUMN 001, "POL0494              CLIENTES PARA EMISSÃO DE LAUDO",
               COLUMN 056, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"

         PRINT

         PRINT COLUMN 017, "   CLIENTE                       NOME"
               
         PRINT COLUMN 017, "---------------   ------------------------------------"
         
         PRINT
                           
      ON EVERY ROW
         
         PRINT COLUMN 017, p_cod_cliente,'   ',p_nom_cliente
         
END REPORT

#-----------------------#
 FUNCTION pol0494_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#


