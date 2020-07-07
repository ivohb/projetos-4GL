#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol1127		                                            #
# OBJETIVO: Cadastro de grupo de despesa por conta contábil CODESP  #
# CLIENTE.: CODESP                                            	    #
# DATA....: 19/01/2012                                              #
# POR.....: Manuel 				                                    #
#-------------------------------------------------------------------#


DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		    p_user          			LIKE usuario.nom_usuario,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				p_resposta						SMALLINT,
				comando         			CHAR(80),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_nom_help      			CHAR(200)
END GLOBALS 
DEFINE 	p_cta_grupo_man912	 	RECORD 		LIKE  cta_grupo_man912.*,
		p_cta_grupo_man9121 	RECORD  	LIKE  cta_grupo_man912.*
#----#
MAIN #
#----#
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol1127-10.02.01"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol1127.iem") RETURNING p_nom_help
	LET p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		CALL pol1127_controle()
	END IF
END MAIN

#---------------------------#
 FUNCTION pol1127_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol1127") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol1127 AT 2,2 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui grupo de despesa para a conta contábil Codesp"
			HELP 001
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol1127_incluir() RETURNING p_status
		COMMAND "Modificar" "Modifica o grupo de despesa para a conta contábil Codesp"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol1127_alterar()
				ELSE
			ERROR "Consulte Previamente para fazer a Modificacao"
			END IF
		COMMAND "Excluir" "Exclui o grupo de despesa para a conta contábil Codesp"
			HELP 003
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol1127_excluir()
				ELSE
				ERROR "Consulte Previamente para fazer a Exclusao"
			END IF 
		COMMAND "Consultar" "Consulta o grupo de despesa para a conta contábil Codesp"
			HELP 004
			MESSAGE "" 
			LET INT_FLAG = 0
			CALL pol1127_consultar()
			IF p_ies_cons THEN
				NEXT OPTION "Seguinte" 
			END IF
		COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
			HELP 005
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol1127_paginacao("SEGUINTE")
		COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
			HELP 006
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol1127_paginacao("ANTERIOR")
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
	CLOSE WINDOW w_pol1127
END FUNCTION

#--------------------------------------#
FUNCTION  pol1127_entrada_dados(p_oper)#
#--------------------------------------#
DEFINE p_oper			CHAR(1) # verifica se esta inserindo ou alterando
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol1127	
 	DISPLAY p_cod_empresa TO cod_empresa
	INPUT BY NAME  p_cta_grupo_man912.num_conta_cont,
				   p_cta_grupo_man912.gru_ctr_desp_item							
								WITHOUT DEFAULTS 
		
		BEFORE FIELD num_conta_cont
			IF p_oper = 'A' THEN 
				CALL pol1127_exibe_dados()
				NEXT FIELD gru_ctr_desp_item	
			END IF 
		AFTER FIELD num_conta_cont 
			IF p_cta_grupo_man912.num_conta_cont IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD num_conta_cont
			ELSE 
				IF pol1127_verifica_duplicidade() THEN
					ERROR"Codigo já cadastrado!!!"
				NEXT FIELD num_conta_cont
				END IF 
			END IF 
		AFTER FIELD	gru_ctr_desp_item
			IF p_cta_grupo_man912.gru_ctr_desp_item IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD gru_ctr_desp_item
			ELSE 
				IF NOT pol1127_verifica_grupo_desp() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD gru_ctr_desp_item
				END IF  
			END IF 
		ON KEY (control-z)
		CALL pol1127_popup()
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#--------------------------------------#
FUNCTION pol1127_verifica_duplicidade()#
#--------------------------------------#
DEFINE l_cont	SMALLINT
	SELECT COUNT(*)
	INTO l_cont
	FROM  cta_grupo_man912
	WHERE cod_empresa = p_cod_empresa
	AND gru_ctr_desp_item = p_cta_grupo_man912.gru_ctr_desp_item
	IF l_cont>0 THEN
		RETURN TRUE 
	ELSE
		RETURN FALSE	
	END IF
END FUNCTION 
#--------------------------------------#
FUNCTION pol1127_verifica_grupo_desp() #
#--------------------------------------#
DEFINE l_den				CHAR(040)
	SELECT den_gru_ctr_desp
	INTO l_den 
	FROM grupo_ctr_desp 
	WHERE cod_empresa = p_cod_empresa 
	AND   gru_ctr_desp = p_cta_grupo_man912.gru_ctr_desp_item
	
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO nom_grp_despesa
		RETURN TRUE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol1127_incluir()#
#-------------------------#
	INITIALIZE p_cta_grupo_man912 TO NULL 
	IF pol1127_entrada_dados('I') THEN
		CALL log085_transacao("BEGIN")
		LET p_cta_grupo_man912.cod_empresa = p_cod_empresa
		INSERT INTO  cta_grupo_man912 VALUES (p_cta_grupo_man912.*)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('Incluir',' cta_grupo_man912')
				CLEAR FORM 
				INITIALIZE p_cta_grupo_man912.* TO NULL 
				ERROR"Inclusão cancelada!"
				RETURN FALSE 
			ELSE
				CALL log085_transacao("COMMIT")
				MESSAGE"Dados incuidos com sucesso!!"
				RETURN TRUE
			END IF 
	ELSE
		CLEAR FORM 
		INITIALIZE p_cta_grupo_man912 TO NULL 
		ERROR"Inclusão cancelada!"
		RETURN FALSE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol1127_excluir()#
#-------------------------#
	IF pol1127_cursor_para_alterar() THEN
		IF log004_confirm(18,35) THEN
			WHENEVER ERROR CONTINUE
			DELETE FROM  cta_grupo_man912
			WHERE CURRENT OF cm_padrao
			IF SQLCA.SQLCODE = 0 THEN
				CALL log085_transacao("COMMIT")
				MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				INITIALIZE p_cta_grupo_man912.* TO NULL
				CLEAR FORM
				DISPLAY p_cod_empresa TO cod_empresa
			ELSE
				CALL log085_transacao("ROLLBACK")
				CALL log003_err_sql("EXCLUSAO","cotas_1120")
			END IF
			WHENEVER ERROR STOP
		ELSE
			CALL log085_transacao("ROLLBACK")
		END IF
	#	CLOSE cm_padrao
	END IF
END FUNCTION 
#--------------------------------------#
 FUNCTION pol1127_cursor_para_alterar()#
#--------------------------------------#
WHENEVER ERROR CONTINUE
	DECLARE cm_padrao CURSOR WITH HOLD FOR	SELECT * INTO p_cta_grupo_man912.*                                              
												FROM  cta_grupo_man912
												WHERE cod_empresa 		= p_cta_grupo_man912.cod_empresa
												AND  num_conta_cont    	= p_cta_grupo_man912.num_conta_cont
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
			OTHERWISE CALL log003_err_sql("LEITURA"," cta_grupo_man912")
		END CASE
	CALL log085_transacao("ROLLBACK")
WHENEVER ERROR STOP
RETURN FALSE
END FUNCTION
#-------------------------#
FUNCTION pol1127_alterar()#
#-------------------------#
	IF pol1127_cursor_para_alterar() THEN
		LET p_cta_grupo_man9121.* = p_cta_grupo_man912.*
		IF pol1127_entrada_dados('A') THEN
			WHENEVER ERROR CONTINUE
				UPDATE  cta_grupo_man912
				SET 	gru_ctr_desp_item		= p_cta_grupo_man912.gru_ctr_desp_item
				WHERE CURRENT OF cm_padrao
		
				IF SQLCA.SQLCODE = 0 THEN
					CALL log085_transacao("COMMIT")
					MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				ELSE
					CALL log085_transacao("ROLLBACK")
					CALL log003_err_sql("MODIFICACAO"," cta_grupo_man912")
				END IF
		ELSE
			CALL log085_transacao("ROLLBACK")
			LET p_cta_grupo_man912.* = p_cta_grupo_man9121.*
			ERROR "Modificacao Cancelada"
			CALL pol1127_exibe_dados()
		END IF
			CLOSE cm_padrao
	END IF
END FUNCTION 
#---------------------------#
FUNCTION pol1127_consultar()#
#---------------------------#
DEFINE  where_clause, sql_stmt		CHAR(300)				

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	LET p_cta_grupo_man9121.* = p_cta_grupo_man912.*
	
	CONSTRUCT BY NAME where_clause ON num_conta_cont ,
									  gru_ctr_desp_item
		ON KEY(control-z)
		CALL pol1127_popup()									
	END CONSTRUCT
	CALL log006_exibe_teclas("01",p_versao)
	CURRENT WINDOW IS w_pol1127
	IF INT_FLAG THEN
		LET INT_FLAG = 0 
		LET p_cta_grupo_man912.* = p_cta_grupo_man9121.*
		#CALL pol1127_exibe_dados()
		ERROR "Consulta Cancelada"
	RETURN
	END IF
	LET sql_stmt = 	"SELECT * FROM  cta_grupo_man912 ",
						    	" WHERE ",where_clause CLIPPED,             
						   		" AND cod_empresa = '",p_cod_empresa,"' ",
						    	"ORDER BY num_conta_cont "
	
	PREPARE var_query FROM sql_stmt   
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	OPEN cq_padrao
	FETCH cq_padrao INTO p_cta_grupo_man912.*
	IF SQLCA.SQLCODE = NOTFOUND THEN
		ERROR "Argumentos de Pesquisa nao Encontrados"
		LET p_ies_cons = FALSE
	ELSE 
		LET p_ies_cons = TRUE
		CALL pol1127_exibe_dados()
	END IF
END FUNCTION 
#-----------------------------------#
FUNCTION pol1127_paginacao(p_funcao)#
#-----------------------------------#
DEFINE p_funcao CHAR(20)
	IF p_ies_cons THEN
		LET p_cta_grupo_man9121.* = p_cta_grupo_man912.*
		WHILE TRUE
			CASE
				WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO  p_cta_grupo_man912.*
				WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO  p_cta_grupo_man912.*
			END CASE
			IF SQLCA.SQLCODE = NOTFOUND THEN
				ERROR "Nao Existem Mais Itens Nesta Direção"
				LET p_cta_grupo_man912.* = p_cta_grupo_man9121.* 
				EXIT WHILE
			END IF
			SELECT * INTO p_cta_grupo_man912.* 
			FROM  cta_grupo_man912
			WHERE cod_empresa    = p_cta_grupo_man912.cod_empresa
			AND num_conta_cont = p_cta_grupo_man912.num_conta_cont
			IF SQLCA.SQLCODE = 0 THEN  
				CALL pol1127_exibe_dados()
				EXIT WHILE
			END IF
		END WHILE
	ELSE
		ERROR "Nao Existe Nenhuma Consulta Ativa"
	END IF
END FUNCTION 
#-----------------------#
FUNCTION pol1127_popup()#
#-----------------------#
DEFINE p_codigo  DEC(02)
      
	CASE
		WHEN INFIELD(gru_ctr_desp_item)
         CALL log009_popup(9,13,"GRUPO DE DESPESA","grupo_ctr_desp","gru_ctr_desp",
                                "den_gru_ctr_desp","SUP0260","S","")
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol1127
			IF p_codigo IS NOT NULL THEN
				LET p_cta_grupo_man912.gru_ctr_desp_item = p_codigo CLIPPED
				DISPLAY p_codigo TO gru_ctr_desp_item
			END IF
					
	END CASE

END FUNCTION 
#-----------------------------#
FUNCTION pol1127_exibe_dados()#
#-----------------------------#
	DISPLAY BY NAME p_cta_grupo_man912.*
	CALL pol1127_verifica_grupo_desp()				RETURNING p_retorno

END FUNCTION