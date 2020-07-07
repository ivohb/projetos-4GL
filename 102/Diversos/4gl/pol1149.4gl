#-------------------------------------------------------------------#
# SISTEMA.: CONTAS A PAGAR                                          #
# PROGRAMA: pol1149                                                 #
# OBJETIVO: CADASTRO DE SIMBOLOS                                    #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 10/05/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix 

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_simbolo        LIKE simbolo_itaesbra.cod_simbolo,
          p_den_simbolo        LIKE simbolo_itaesbra.den_simbolo,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
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
          

   DEFINE p_simbolo_itaesbra RECORD LIKE simbolo_itaesbra.*

    
   DEFINE p_simbolo       ARRAY[100] OF RECORD
          cod_simbolo     LIKE simbolo_itaesbra.cod_simbolo,
          den_simbolo     LIKE simbolo_itaesbra.den_simbolo,
          cod_tip_oper    LIKE simbolo_itaesbra.cod_tip_oper
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol1149-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1149.iem") RETURNING p_nom_help
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
      CALL pol1149_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1149_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1149") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1149 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1149_modificar() RETURNING p_status
         IF p_status THEN
            MESSAGE "Operação Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
      COMMAND "Modificar" "Modifica Dados na Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1149_modificar() RETURNING p_status
         IF p_status THEN
            MESSAGE "Operação Efetuada c/ Sucesso !!!"
               ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Operação Cancelada !!!"
               ATTRIBUTE(REVERSE)
         END IF      
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol1149_exibe_simbolos()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1149_sobre()
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
   CLOSE WINDOW w_pol1149

END FUNCTION

#--------------------------#
FUNCTION pol1149_modificar()
#--------------------------#

   IF NOT p_ies_cons THEN
      CALL pol1149_exibe_simbolos()
   END IF
   IF pol1149_aceita_simbolos() THEN
      CALL pol1149_grava_simbolos()
   ELSE
      CALL pol1149_exibe_simbolos()
   END IF

   RETURN(p_retorno)
   
END FUNCTION

#--------------------------------#
FUNCTION pol1149_aceita_simbolos()
#--------------------------------#

   CALL SET_COUNT(p_index)
   
   INPUT ARRAY p_simbolo
      WITHOUT DEFAULTS FROM s_simbolo.*
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         
      BEFORE FIELD cod_simbolo
         LET p_cod_simbolo = p_simbolo[p_index].cod_simbolo
         
      AFTER FIELD cod_simbolo
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN
            IF p_simbolo[p_index].cod_simbolo IS NULL THEN
               ERROR "Campo c/ Prenchimento Obrigatório !!!"
               LET p_simbolo[p_index].cod_simbolo = p_cod_simbolo
               NEXT FIELD cod_simbolo
            END IF
         END IF
         
         IF p_simbolo[p_index].cod_simbolo IS NOT NULL THEN
            IF pol1149_repetiu_cod() THEN
               ERROR "Simbolo ",p_simbolo[p_index].cod_simbolo," já Cadastrado !!!"
               LET p_simbolo[p_index].cod_simbolo = p_cod_simbolo
               NEXT FIELD cod_simbolo
            END IF
         END IF

      BEFORE FIELD den_simbolo         
         IF p_simbolo[p_index].cod_simbolo IS NULL THEN
            ERROR "Campo c/ Prenchimento Obrigatório !!!"
            LET p_simbolo[p_index].cod_simbolo = p_cod_simbolo
            NEXT FIELD cod_simbolo
         END IF

      AFTER FIELD cod_tip_oper         
         IF p_simbolo[p_index].cod_tip_oper IS NULL THEN
            ERROR "Campo c/ Prenchimento Obrigatório !!!"
            NEXT FIELD cod_tip_oper
         END IF
      
      ON KEY (control-z)
         CALL pol1149_popup()
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      LET p_retorno = TRUE
   ELSE
      LET p_retorno = FALSE
      LET INT_FLAG = 0
   END IF   
   RETURN(p_retorno)
   
END FUNCTION

#-------------------------------#
FUNCTION pol1149_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF p_simbolo[p_ind].cod_simbolo = p_simbolo[p_index].cod_simbolo THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1149_grava_simbolos()
#--------------------------------#
   
   DEFINE p_ind SMALLINT 
   
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")

   DELETE FROM simbolo_itaesbra
     WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE 
      MESSAGE "Erro na deleção" ATTRIBUTE(REVERSE)
   ELSE
      FOR p_ind = 1 TO ARR_COUNT()
          IF p_simbolo[p_ind].cod_simbolo IS NULL THEN
             CONTINUE FOR
          END IF
          
          INSERT INTO simbolo_itaesbra
          VALUES (p_cod_empresa,
                  p_simbolo[p_ind].cod_simbolo,
                  p_simbolo[p_ind].den_simbolo,
                  p_simbolo[p_ind].cod_tip_oper)
                  
          IF sqlca.sqlcode <> 0 THEN 
             LET p_houve_erro = TRUE
             MESSAGE "Erro na inclusão" ATTRIBUTE(REVERSE)
             EXIT FOR
          END IF
      END FOR
   END IF
         
   IF NOT p_houve_erro THEN
      CALL log085_transacao("COMMIT")	      
      LET p_retorno = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      CALL log003_err_sql("GRAVAÇÃO","simbolo_itaesbra")
      LET p_retorno = FALSE
   END IF      
   WHENEVER ERROR STOP
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1149_exibe_simbolos()
#--------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   DECLARE cq_simbolo CURSOR FOR 
    SELECT cod_simbolo,
           den_simbolo,
           cod_tip_oper
      FROM simbolo_itaesbra
     WHERE cod_empresa = p_cod_empresa
     ORDER BY 1

   LET p_index = 1
   
   FOREACH cq_simbolo INTO p_simbolo[p_index].*

      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY p_simbolo WITHOUT DEFAULTS FROM s_simbolo.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

   LET p_ies_cons = TRUE
   
END FUNCTION 


#-----------------------------------#
 FUNCTION pol1149_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
      FROM empresa
         WHERE cod_empresa = p_cod_empresa
  
   DECLARE cq_imp CURSOR FOR 
    SELECT cod_simbolo,
           den_simbolo,
           cod_tip_oper
      FROM simbolo_itaesbra
     WHERE cod_empresa = p_cod_empresa
     ORDER BY 1

   FOREACH cq_imp INTO p_simbolo_itaesbra.*
   

      OUTPUT TO REPORT pol1149_relat() 
 
      LET p_count = p_count + 1
      
   END FOREACH


  
END FUNCTION 

#---------------------#
 REPORT pol1149_relat()
#---------------------#


   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "POL0368              RELATORIO DE EMPRESAS POR USUÁRIOS"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"

         PRINT
                           

      ON EVERY ROW

         PRINT COLUMN 001, ''
         
END REPORT


#-----------------------#
FUNCTION pol1149_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_simbolo)
         
   END CASE

END FUNCTION 

#-----------------------#
 FUNCTION pol1149_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
