#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol0000		                                              #
# OBJETIVO: cadastro de parametros para importação de nf de entrada	#
#									 																									#
# CLIENTE.: CODESP                                            			#
# DATA....: 00/00/2009                                              #
# POR.....: THIAGO				                                          #
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
DEFINE 	p_parametro_912	 	RECORD 		LIKE   par_imp_nf_sup_912.*,
			 	p_parametro_9121 	RECORD  	LIKE  par_imp_nf_sup_912.*
#----#
MAIN #
#----#
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0950-10.02.00"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0950.iem") RETURNING p_nom_help
	LET p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		CALL pol0950_controle()
	END IF
END MAIN

#---------------------------#
 FUNCTION pol0950_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol0950") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol0950 AT 2,2 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui Dados na Tabela"
			HELP 001
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0950_incluir() RETURNING p_status
		COMMAND "Modificar" "Inclui Dados das Cotas"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0950_alterar()
				ELSE
			ERROR "Consulte Previamente para fazer a Modificacao"
			END IF
		COMMAND "Excluir" "Exclui Dados das Cotas"
			HELP 003
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0950_excluir()
				ELSE
				ERROR "Consulte Previamente para fazer a Exclusao"
			END IF 
		COMMAND "Consultar" "Consulta Dados das Cotas"
			HELP 004
			MESSAGE "" 
			LET INT_FLAG = 0
			CALL pol0950_consultar()
			IF p_ies_cons THEN
				NEXT OPTION "Seguinte" 
			END IF
		COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
			HELP 005
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0950_paginacao("SEGUINTE")
		COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
			HELP 006
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0950_paginacao("ANTERIOR")
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
	CLOSE WINDOW w_pol0950
END FUNCTION

#--------------------------------------#
FUNCTION  pol0950_entrada_dados(p_oper)#
#--------------------------------------#
DEFINE p_oper			CHAR(1) # verifica se esta inserindo ou alterando
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol0950	
 	DISPLAY p_cod_empresa TO cod_empresa
	INPUT BY NAME  p_parametro_912.cod_parametro,
								p_parametro_912.den_parametro,
								p_parametro_912.cond_pagto
								#p_parametro_912.clas_fiscal
								
								WITHOUT DEFAULTS 
		
		BEFORE FIELD cod_parametro
			IF p_oper = 'A' THEN 
				CALL pol0950_exibe_dados()
				NEXT FIELD den_parametro
			END IF 
		AFTER FIELD cod_parametro 
			IF p_parametro_912.cod_parametro IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cod_parametro
			ELSE 
				IF pol0950_verifica_duplicidade() THEN
					ERROR"Codigo já cadastrado!!!"
				NEXT FIELD cod_parametro
				END IF 
			END IF 
		AFTER FIELD	den_parametro 
			IF p_parametro_912.den_parametro IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD den_parametro
			END IF 
		AFTER FIELD	cond_pagto
			IF p_parametro_912.cond_pagto IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cond_pagto
			ELSE 
				IF NOT pol0950_verifica_cond_pagto() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD cond_pagto
				END IF  
			END IF 
		#AFTER FIELD	clas_fiscal
		#	IF p_parametro_912.clas_fiscal IS NULL THEN 
		#		ERROR"Campo de preenchimento obrigatorio!!!"
		#		NEXT FIELD clas_fiscal
		#	ELSE 
		#		IF NOT pol0950_verifica_clas_fiscal() THEN
		#			ERROR"Código não cadastrado!!!"
		#		NEXT FIELD clas_fiscal
		#		END IF 
		#	END IF 
		ON KEY (control-z)
		CALL pol0950_popup()
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#--------------------------------------#
FUNCTION pol0950_verifica_duplicidade()#
#--------------------------------------#
DEFINE l_cont	SMALLINT
	SELECT COUNT(*)
	INTO l_cont
	FROM  par_imp_nf_sup_912
	WHERE cod_empresa = p_cod_empresa
	AND cod_parametro = p_parametro_912.cod_parametro
	IF l_cont>0 THEN
		RETURN TRUE 
	ELSE
		RETURN FALSE	
	END IF
END FUNCTION 
#--------------------------------------#
FUNCTION pol0950_verifica_cond_pagto() #
#--------------------------------------#
DEFINE l_den				CHAR(040)
	SELECT DES_CND_PGTO
	INTO l_den 
	FROM COND_PGTO_CAP 
	WHERE CND_PGTO = p_parametro_912.cond_pagto
	
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_cond_pagto
		RETURN TRUE 
	END IF 
END FUNCTION 
{
#--------------------------------------#
FUNCTION pol0950_verifica_clas_fiscal()#
#--------------------------------------#
DEFINE l_den 				CHAR(035)
	INITIALIZE l_den TO NULL

	SELECT  DEN_COD_FISCAL
	INTO l_den 
	FROM COD_FISCAL_SUP
	WHERE COD_FISCAL = p_parametro_912.clas_fiscal
	
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_cod_fiscal
		RETURN TRUE 
	END IF 
END FUNCTION 
}
#-------------------------#
FUNCTION pol0950_incluir()#
#-------------------------#
	INITIALIZE p_parametro_912 TO NULL 
	IF pol0950_entrada_dados('I') THEN
		CALL log085_transacao("BEGIN")
		LET p_parametro_912.cod_empresa = p_cod_empresa
		INSERT INTO  par_imp_nf_sup_912 VALUES (p_parametro_912.*)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('Incluir',' par_imp_nf_sup_912')
				CLEAR FORM 
				INITIALIZE p_parametro_912.* TO NULL 
				ERROR"Inclusão cancelada!"
				RETURN FALSE 
			ELSE
				CALL log085_transacao("COMMIT")
				MESSAGE"Dados incuidos com sucesso!!"
				RETURN TRUE
			END IF 
	ELSE
		CLEAR FORM 
		INITIALIZE p_parametro_912 TO NULL 
		ERROR"Inclusão cancelada!"
		RETURN FALSE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol0950_excluir()#
#-------------------------#
	IF pol0950_cursor_para_alterar() THEN
		IF log004_confirm(18,35) THEN
			WHENEVER ERROR CONTINUE
			DELETE FROM  par_imp_nf_sup_912
			WHERE CURRENT OF cm_padrao
			IF SQLCA.SQLCODE = 0 THEN
				CALL log085_transacao("COMMIT")
				MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				INITIALIZE p_parametro_912.* TO NULL
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
 FUNCTION pol0950_cursor_para_alterar()#
#--------------------------------------#
WHENEVER ERROR CONTINUE
	DECLARE cm_padrao CURSOR WITH HOLD FOR	SELECT * INTO p_parametro_912.*                                              
																					FROM  par_imp_nf_sup_912
																					WHERE cod_empresa = p_parametro_912.cod_empresa
																					AND  cod_parametro    = p_parametro_912.cod_parametro
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
			OTHERWISE CALL log003_err_sql("LEITURA"," par_imp_nf_sup_912")
		END CASE
	CALL log085_transacao("ROLLBACK")
WHENEVER ERROR STOP
RETURN FALSE
END FUNCTION
#-------------------------#
FUNCTION pol0950_alterar()#
#-------------------------#
	IF pol0950_cursor_para_alterar() THEN
		LET p_parametro_9121.* = p_parametro_912.*
		IF pol0950_entrada_dados('A') THEN
			WHENEVER ERROR CONTINUE
				UPDATE  par_imp_nf_sup_912
				SET den_parametro	= p_parametro_912.den_parametro,
						cond_pagto		= p_parametro_912.cond_pagto
						#clas_fiscal		= p_parametro_912.clas_fiscal
				WHERE CURRENT OF cm_padrao
		
				IF SQLCA.SQLCODE = 0 THEN
					CALL log085_transacao("COMMIT")
					MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				ELSE
					CALL log085_transacao("ROLLBACK")
					CALL log003_err_sql("MODIFICACAO"," par_imp_nf_sup_912")
				END IF
		ELSE
			CALL log085_transacao("ROLLBACK")
			LET p_parametro_912.* = p_parametro_9121.*
			ERROR "Modificacao Cancelada"
			CALL pol0950_exibe_dados()
		END IF
			CLOSE cm_padrao
	END IF
END FUNCTION 
#---------------------------#
FUNCTION pol0950_consultar()#
#---------------------------#
DEFINE  where_clause, sql_stmt		CHAR(300)				

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	LET p_parametro_9121.* = p_parametro_912.*
	
	CONSTRUCT BY NAME where_clause ON cod_parametro ,
																		den_parametro,
																		cond_pagto
																		#clas_fiscal
		ON KEY(control-z)
		CALL pol0950_popup()									
	END CONSTRUCT
	CALL log006_exibe_teclas("01",p_versao)
	CURRENT WINDOW IS w_pol0950
	IF INT_FLAG THEN
		LET INT_FLAG = 0 
		LET p_parametro_912.* = p_parametro_9121.*
		#CALL pol0950_exibe_dados()
		ERROR "Consulta Cancelada"
	RETURN
	END IF
	LET sql_stmt = 	"SELECT * FROM  par_imp_nf_sup_912 ",
						    	" WHERE ",where_clause CLIPPED,             
						   		" AND cod_empresa = '",p_cod_empresa,"' ",
						    	"ORDER BY cod_parametro "
	
	PREPARE var_query FROM sql_stmt   
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	OPEN cq_padrao
	FETCH cq_padrao INTO p_parametro_912.*
	IF SQLCA.SQLCODE = NOTFOUND THEN
		ERROR "Argumentos de Pesquisa nao Encontrados"
		LET p_ies_cons = FALSE
	ELSE 
		LET p_ies_cons = TRUE
		CALL pol0950_exibe_dados()
	END IF
END FUNCTION 
#-----------------------------------#
FUNCTION pol0950_paginacao(p_funcao)#
#-----------------------------------#
DEFINE p_funcao CHAR(20)
	IF p_ies_cons THEN
		LET p_parametro_9121.* = p_parametro_912.*
		WHILE TRUE
			CASE
				WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO  p_parametro_912.*
				WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO  p_parametro_912.*
			END CASE
			IF SQLCA.SQLCODE = NOTFOUND THEN
				ERROR "Nao Existem Mais Itens Nesta Direção"
				LET p_parametro_912.* = p_parametro_9121.* 
				EXIT WHILE
			END IF
			SELECT * INTO p_parametro_912.* 
			FROM  par_imp_nf_sup_912
			WHERE cod_empresa    = p_parametro_912.cod_empresa
			AND cod_parametro = p_parametro_912.cod_parametro
			IF SQLCA.SQLCODE = 0 THEN  
				CALL pol0950_exibe_dados()
				EXIT WHILE
			END IF
		END WHILE
	ELSE
		ERROR "Nao Existe Nenhuma Consulta Ativa"
	END IF
END FUNCTION 
#-----------------------#
FUNCTION pol0950_popup()#
#-----------------------#
DEFINE p_codigo  CHAR(15)
      
	CASE
	#	WHEN INFIELD(clas_fiscal)
	#		CALL log009_popup(8,10,"CODIGO CLASSIFICAÇÃO FISCAL","cod_fiscal_sup",
	#					"cod_fiscal","den_cod_fiscal","","N","") RETURNING p_codigo
	#		CALL log006_exibe_teclas("01 02 07", p_versao)
	#		CURRENT WINDOW IS w_pol0950
	#		IF p_codigo IS NOT NULL THEN
	#			LET p_parametro_912.clas_fiscal = p_codigo CLIPPED
	#			DISPLAY p_codigo TO clas_fiscal
	#		END IF
		WHEN INFIELD(cond_pagto)
			CALL log009_popup(8,10,"CODIGO CONDIÇÃO DE PAGAMENTO","cond_pgto_cap",
						"cnd_pgto","des_cnd_pgto","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0950
			IF p_codigo IS NOT NULL THEN
				LET p_parametro_912.cond_pagto = p_codigo CLIPPED
				DISPLAY p_codigo TO cond_pagto
			END IF
	END CASE
END FUNCTION 
#-----------------------------#
FUNCTION pol0950_exibe_dados()#
#-----------------------------#
	DISPLAY BY NAME p_parametro_912.*
	CALL pol0950_verifica_cond_pagto()				RETURNING p_retorno
	#CALL pol0950_verifica_clas_fiscal()					RETURNING p_retorno
END FUNCTION