#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1119                                                 #
# OBJETIVO: USUÁRIO PARA LAUDO                                      #
# DATA....: 03/11/2011                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_nom_usuario  LIKE usuarios.nom_funcionario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(100)

   DEFINE p_laudo_usu  RECORD LIKE laudo_usu_915.*,
          p_laudo_usum RECORD LIKE laudo_usu_915.*
END GLOBALS

MAIN
#  CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1119-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1119.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
#  CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL POL1119_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1119_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1119") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1119 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
      #  IF p_user = "admlog" THEN
            IF log005_seguranca(p_user,"VDP","POL1119","IN") THEN
               CALL POL1119_inclusao() RETURNING p_status
            END IF
      #  ELSE
      #     ERROR "Usuario nao Autorizado para esta Funcao"
      #  END IF
   {  COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_user = "admlog" THEN
            IF log005_seguranca(p_user,"VDP","POL1119","MO") THEN
               CALL POL1119_modificacao()
            END IF
         ELSE
            ERROR "Usuario nao Autorizado para esta Funcao"
         END IF   }
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
      #  IF p_user = "admlog" THEN
            IF log005_seguranca(p_user,"VDP","POL1119","EX") THEN
               CALL POL1119_exclusao()
            END IF
      #  ELSE
      #     ERROR "Usuario nao Autorizado para esta Funcao"
      #  END IF
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1119","CO") THEN
            CALL POL1119_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1119_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1119_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL POL1119_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_POL1119

END FUNCTION

#--------------------------#
 FUNCTION POL1119_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF POL1119_entrada_dados("INCLUSAO") THEN
   #  CALL log085_transacao("BEGIN")
      BEGIN WORK
      LET p_laudo_usu.cod_empresa = p_cod_empresa
      INSERT INTO laudo_usu_915 VALUES (p_laudo_usu.*)
      IF SQLCA.SQLCODE <> 0 THEN 
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","LAUDO_USU_915")       
      ELSE
      #  CALL log085_transacao("COMMIT")
         COMMIT WORK 
         MESSAGE "Inclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION POL1119_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1119
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE p_laudo_usu.* TO NULL
   END IF

   INPUT BY NAME p_laudo_usu.cod_usuario
      WITHOUT DEFAULTS  

   #  BEFORE FIELD cod_usuario
   #  IF p_funcao = "MODIFICACAO" THEN 
   #     NEXT FIELD cod_usuario
   #  END IF

      AFTER FIELD cod_usuario 
      IF p_laudo_usu.cod_usuario IS NULL THEN
         ERROR "O Campo Codigo do Usuario nao pode ser Nulo"
         NEXT FIELD cod_usuario
      ELSE
         SELECT nom_funcionario
            INTO p_nom_usuario
         FROM usuarios
         WHERE cod_usuario = p_laudo_usu.cod_usuario
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Usuario nao Cadastrado"
            NEXT FIELD cod_usuario
         END IF
         SELECT * 
         FROM laudo_usu_915
         WHERE cod_empresa = p_cod_empresa
           AND cod_usuario = p_laudo_usu.cod_usuario
         IF SQLCA.SQLCODE = 0 THEN
            ERROR "Usuario Já Cadastrado"
            NEXT FIELD cod_usuario
         END IF
         DISPLAY p_nom_usuario TO nom_usuario
      END IF   

      ON KEY (control-z)
         IF INFIELD(cod_usuario) THEN
            CALL log009_popup(6,25,"USUARIOS","usuarios","cod_usuario",
                             "nom_funcionario","","N","") 
               RETURNING p_laudo_usu.cod_usuario
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_POL1119
            IF p_laudo_usu.cod_usuario IS NOT NULL THEN
               DISPLAY BY NAME p_laudo_usu.cod_usuario
            END IF
         END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1119
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1119_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON laudo_usu.cod_usuario 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1119

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_laudo_usu_915.* = p_laudo_usum.*
      CALL POL1119_exibe_dados()
      CLEAR FORM
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM laudo_usu_915 ",
                  " WHERE ", where_clause CLIPPED,                 
                  " ORDER BY cod_usuario "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_laudo_usu.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL POL1119_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION POL1119_exibe_dados()
#-----------------------------#

   SELECT nom_funcionario
      INTO p_nom_usuario 
   FROM usuarios
   WHERE cod_usuario = p_laudo_usu.cod_usuario

   DISPLAY BY NAME p_laudo_usu.*
   DISPLAY p_nom_usuario TO nom_usuario

END FUNCTION

#-----------------------------------#
 FUNCTION POL1119_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_laudo_usum.* = p_laudo_usu.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_laudo_usu.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_laudo_usu.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem mais Registros nesta Direcao"
            LET p_laudo_usu.* = p_laudo_usum.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO p_laudo_usu.* 
           FROM laudo_usu_915    
          WHERE cod_empresa = p_cod_empresa
            AND cod_usuario = p_laudo_usu.cod_usuario
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1119_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1119_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
#  DECLARE cm_padrao CURSOR WITH HOLD FOR
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
      INTO p_laudo_usu.*                                              
   FROM laudo_usu_915      
   WHERE cod_empresa = p_cod_empresa
     AND cod_usuario = p_laudo_usu.cod_usuario
   FOR UPDATE 
#  CALL log085_transacao("BEGIN")
   BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","LAUDO_USU_915")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
#FUNCTION POL1119_modificacao()
#-----------------------------#

{
   IF POL1119_cursor_for_update() THEN
      LET p_laudo_usum.* = p_laudo_usu.*
      IF POL1119_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE laudo_usu_915 
            SET cod_usuario = p_laudo_usu.cod_usuario
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
         #  CALL log085_transacao("COMMIT")
            COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","LAUDO_USU_915")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","LAUDO_USU_915")
         #  CALL log085_transacao("ROLLBACK")
            ROLLBACK WORK
         END IF
      ELSE
         LET p_laudo_usu.* = p_laudo_usum.*
         ERROR "Modificacao Cancelada"
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
         DISPLAY BY NAME p_laudo_usu.*
         DISPLAY p_nom_usuario TO nom_usuario
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION   }

#--------------------------#
 FUNCTION POL1119_exclusao()
#--------------------------#

   IF POL1119_cursor_for_update() THEN
      IF log004_confirm(12,40) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM laudo_usu_915    
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
         #  CALL log085_transacao("COMMIT")
            COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","LAUDO_USU_915")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE p_laudo_usu.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","LAUDO_USU_915")
         #  CALL log085_transacao("ROLLBACK")
            ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
      #  CALL log085_transacao("ROLLBACK")
         ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   ELSE
   #  CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION POL1119_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------- FIM DE PROGRAMA --------------------------------#