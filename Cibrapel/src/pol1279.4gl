#-------------------------------------------------------------------#
# OBJETIVO: USUÁRIOS PARA EXCLUSãO DE BAIXAS PENDENTES              #
# DATA....: 10/04/2015                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_index              SMALLINT,
          s_index              SMALLINT,
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
          p_msg                CHAR(500),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(80),
          p_nom_usuario        CHAR(30),
          p_nom_funcionario    LIKE funcionario.nom_funcionario
          
   DEFINE p_usuario_exclui_baixa_885  RECORD 
          cod_usuario          CHAR(08)
   END RECORD

   DEFINE p_usuario_exclui_baixa_885a RECORD 
          cod_usuario          CHAR(08)
   END RECORD
             
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1279-10.02.00  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1279" ) RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

	CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
	#LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0
	
	IF p_status = 0 THEN
 		CALL pol1279_controle()
	END IF
	
END MAIN

#--------------------------#
 FUNCTION pol1279_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1279") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1279 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela."
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol1279_inclusao() THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela."
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol1279_exclusao() THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela."
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol1279_consulta() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso'
         ELSE
            ERROR 'Operação cancelada'
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta."
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1279_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta."
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1279_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1279_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior."
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1279

END FUNCTION

#--------------------------#
 FUNCTION pol1279_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_usuario_exclui_baixa_885.* TO NULL

   IF pol1279_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO usuario_exclui_baixa_885 VALUES (p_usuario_exclui_baixa_885.*)
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('INSERT','usuario_exclui_baixa_885')
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
 FUNCTION pol1279_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1279

   INPUT BY NAME p_usuario_exclui_baixa_885.*
      WITHOUT DEFAULTS  

      AFTER FIELD cod_usuario
      IF p_usuario_exclui_baixa_885.cod_usuario IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_usuario
      END IF

      INITIALIZE p_nom_usuario TO NULL
      
      SELECT nom_funcionario
        INTO p_nom_usuario
        FROM usuarios
       WHERE cod_usuario  = p_usuario_exclui_baixa_885.cod_usuario 

      IF STATUS <> 0 THEN
         ERROR 'Usuario não cadastrado !!!'
         NEXT FIELD cod_usuario
      END IF
         
      DISPLAY p_nom_usuario TO nom_usuario

      SELECT cod_usuario
        FROM usuario_exclui_baixa_885
       WHERE cod_usuario  = p_usuario_exclui_baixa_885.cod_usuario
         
      IF STATUS = 0 THEN
         ERROR "Usuario já cadastrado na usuario_exclui_baixa_885 !!!"
         NEXT FIELD cod_usuario
      END IF         
      
      ON KEY (control-z)
         CALL pol1279_popup()

    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1279

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1279_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_usuario_exclui_baixa_885a.* = p_usuario_exclui_baixa_885.*
   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON
        usuario_exclui_baixa_885.cod_usuario
   
      ON KEY (control-z)
         CALL pol1279_popup()
         
   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1279

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_usuario_exclui_baixa_885.* = p_usuario_exclui_baixa_885a.*
      CALL pol1279_exibe_dados()
      CLEAR FORM         
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

    LET sql_stmt = "SELECT * FROM usuario_exclui_baixa_885 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_usuario "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_usuario_exclui_baixa_885.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de Pesquisa\n não Encontrados", 'info')
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol1279_exibe_dados()
   END IF
   
   RETURN p_ies_cons
   
END FUNCTION

#------------------------------#
 FUNCTION pol1279_exibe_dados()
#------------------------------#

   INITIALIZE p_nom_usuario TO NULL 

   SELECT nom_funcionario
     INTO p_nom_usuario
     FROM usuarios
    WHERE cod_usuario = p_usuario_exclui_baixa_885.cod_usuario
      
   DISPLAY BY NAME p_usuario_exclui_baixa_885.*
   DISPLAY p_nom_usuario TO nom_usuario
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol1279_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_usuario_exclui_baixa_885.*                                              
     FROM usuario_exclui_baixa_885
    WHERE cod_usuario = p_usuario_exclui_baixa_885.cod_usuario
   FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","usuario_exclui_baixa_885")   
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol1279_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol1279_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM usuario_exclui_baixa_885
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_usuario_exclui_baixa_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","usuario_exclui_baixa_885")
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
 FUNCTION pol1279_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_usuario_exclui_baixa_885a.* =  p_usuario_exclui_baixa_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_usuario_exclui_baixa_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_usuario_exclui_baixa_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem Mais Itens Nesta Direção !!!"
            LET p_usuario_exclui_baixa_885.* = p_usuario_exclui_baixa_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_usuario_exclui_baixa_885.*
           FROM usuario_exclui_baixa_885
          WHERE cod_usuario = p_usuario_exclui_baixa_885.cod_usuario
                            
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol1279_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa !!!"
   END IF

END FUNCTION

#----------------------#
FUNCTION pol1279_popup()
#----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_usuario)
         CALL log009_popup(8,15,"USUARIOS","usuarios",
              "cod_usuario","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1279
         IF p_codigo IS NOT NULL THEN
            LET p_usuario_exclui_baixa_885.cod_usuario = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_usuario
         END IF
   END CASE
END FUNCTION

#-------------------------------------#
FUNCTION pol1279_exibe_versao()
#-------------------------------------#
	
	LET p_msg = p_versao CLIPPED, "\n","\n",
				"LOGIX 10.02 ","\n","\n",
				" Home page: www.aceex.com.br","\n","\n",
				" (0xx11) 4991-6667 ","\n","\n"
	
	CALL log0030_mensagem(p_msg,"excla")
	
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#