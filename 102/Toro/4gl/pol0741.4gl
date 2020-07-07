#------------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                       #
# PROGRAMA: pol0741                                                      #
# OBJETIVO: PARAMETRO PARA INFORMAR O DIRETORIO ONDE SERA GRAVADO EDI    #
# AUTOR...: POLO INFORMATICA - ANA PAULA QF                              #
# DATA....: 23/01/2008                                                   #
# ALTERADO: 11/03/2008 por Ana Paula - versao 00                         #
#------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_retorno            SMALLINT,
          p_msg                CHAR(300),
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_diretorio          LIKE diretorio_159.diretorio
          
   DEFINE p_diretorio_159   RECORD LIKE diretorio_159.*,
          p_diretorio_159a  RECORD LIKE diretorio_159.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   LET p_versao = "pol0741-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0741.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0741_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0741_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0741") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0741 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0741_consulta() RETURNING p_status
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            ERROR 'Parâmetros da Empresa corrente já cadastrados !!!'
         ELSE         
            IF pol0741_inclusao() THEN
               ERROR 'Inclusão efetuada com sucesso !!!'
               LET p_ies_cons = TRUE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF 
         END IF
      COMMAND "Modificar" "Modifica Dados"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0741_modificacao() THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0741_exclusao() THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
               LET p_ies_cons = FALSE
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            ERROR 'A consulta já está ativa !!!'
         ELSE
            IF pol0741_consulta() THEN
               ERROR 'Consulta efetuada com sucesso !!!'
               NEXT OPTION "Modificar" 
            ELSE
               ERROR 'Não há parametros cadastrados p/ Empresa corrente !!!'
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0741_sobre() 
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
   CLOSE WINDOW w_pol0741

END FUNCTION

#-----------------------#
FUNCTION pol0741_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
FUNCTION pol0741_consulta()
#--------------------------#

   SELECT *
     INTO p_diretorio_159.*
     FROM diretorio_159
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS = 0 THEN
      LET p_ies_cons = TRUE
      CALL pol0741_exibe_dados()
      RETURN TRUE
   ELSE
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0741_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_diretorio_159.* TO NULL
   LET p_diretorio_159.cod_empresa = p_cod_empresa

   IF pol0741_entrada_dados("INCLUSAO") THEN
      WHENEVER ANY ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      INSERT INTO diretorio_159 VALUES (p_diretorio_159.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	       CALL log003_err_sql("INCLUSAO","diretorio_159")       
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
 FUNCTION pol0741_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0741

   INPUT BY NAME p_diretorio_159.* 
      WITHOUT DEFAULTS  

      AFTER FIELD diretorio
          IF p_diretorio_159.diretorio IS NULL THEN 
             ERROR 'Campo de preenchimento obrigatório.'
             NEXT FIELD diretorio
          END IF 

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0741

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0741_exibe_dados()
#------------------------------#
   CLEAR FORM
   DISPLAY BY NAME p_diretorio_159.*
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION
 
#-----------------------------------#
 FUNCTION pol0741_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   
   SELECT *
     INTO p_diretorio_159.*
     FROM diretorio_159
    WHERE cod_empresa = p_cod_empresa
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","diretorio_159")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0741_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0741_cursor_for_update() THEN
      LET p_diretorio_159a.* = p_diretorio_159.*
      IF pol0741_entrada_dados("MODIFICACAO") THEN
         UPDATE diretorio_159
            SET diretorio_159.* = p_diretorio_159.*
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","diretorio_159")
         END IF
      ELSE
         LET p_diretorio_159.* = p_diretorio_159a.*
         CALL pol0741_exibe_dados()
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
 FUNCTION pol0741_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0741_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM diretorio_159
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_diretorio_159.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","diretorio_159")
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

#------------------------------ FIM DO PROGRAMA ------------------------------#

