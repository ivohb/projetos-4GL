#-----------------------------------------------------------#
# SISTEMA.: CADASTRO DE PARAMETROS PARA SOLICITAÇAO DE FATURA#
#	PROGRAMA:	POL000																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	CADASTRAR PARAMETROS PARA IMPORTAÇÃO DE SOLICITA#
#						DE FATURA																				#
#	AUTOR...:	THIAGO																					#
#	DATA....:	18/05/2009																			#
#-----------------------------------------------------------#

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
DEFINE 	p_par_solc_fat_codesp	 RECORD 	LIKE  par_solc_fat_codesp.*,
			 	p_par_solc_fat_codesp1 RECORD  	LIKE par_solc_fat_codesp.*
#----#
MAIN #
#----#
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0933-10.02.02"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0933.iem") RETURNING p_nom_help
	LET p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		CALL pol0933_controle()
	END IF
END MAIN

#---------------------------#
 FUNCTION pol0933_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL 
	CALL log130_procura_caminho("pol0933") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED 
	OPEN WINDOW w_pol0933 AT 2,2 WITH FORM p_nom_tela
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui Dados na Tabela"
			HELP 001
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0933_incluir() RETURNING p_status
		COMMAND "Modificar" "Inclui Dados das Cotas"
			HELP 002
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0933_alterar()
				ELSE
			ERROR "Consulte Previamente para fazer a Modificacao"
			END IF
		COMMAND "Excluir" "Exclui Dados das Cotas"
			HELP 003
			MESSAGE ""
			LET INT_FLAG = 0
			IF p_ies_cons THEN
				CALL pol0933_excluir()
				ELSE
				ERROR "Consulte Previamente para fazer a Exclusao"
			END IF 
		COMMAND "Consultar" "Consulta Dados das Cotas"
			HELP 004
			MESSAGE "" 
			LET INT_FLAG = 0
			CALL pol0933_consultar()
			IF p_ies_cons THEN
				NEXT OPTION "Seguinte" 
			END IF
		COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
			HELP 005
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0933_paginacao("SEGUINTE")
		COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
			HELP 006
			MESSAGE ""
			LET INT_FLAG = 0
			CALL pol0933_paginacao("ANTERIOR")
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
	CLOSE WINDOW w_pol0933
END FUNCTION

#--------------------------------------#
FUNCTION  pol0933_entrada_dados(p_oper)#
#--------------------------------------#
DEFINE p_oper			CHAR(1) # verifica se esta inserindo ou alterando
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol0933	
 	DISPLAY p_cod_empresa TO cod_empresa
	INPUT BY NAME  p_par_solc_fat_codesp.cod_parametro,
								p_par_solc_fat_codesp.den_parametro,
								p_par_solc_fat_codesp.cond_pagto,
								p_par_solc_fat_codesp.clas_fiscal,
								p_par_solc_fat_codesp.finalidade ,
								p_par_solc_fat_codesp.item_prod,
								p_par_solc_fat_codesp.moeda,
								p_par_solc_fat_codesp.natureza_operacao,
								p_par_solc_fat_codesp.nat_oper_nao_trib,
								p_par_solc_fat_codesp.tip_carteira,
								p_par_solc_fat_codesp.tipo_preco,
								p_par_solc_fat_codesp.tipo_venda 
							#	p_par_solc_fat_codesp.cam_import,
							#	p_par_solc_fat_codesp.cam_export
								WITHOUT DEFAULTS 
		
		BEFORE FIELD cod_parametro
			IF p_oper = 'A' THEN 
				CALL pol0933_exibe_dados()
				NEXT FIELD den_parametro
			END IF 
		AFTER FIELD cod_parametro 
			IF p_par_solc_fat_codesp.cod_parametro IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cod_parametro
			ELSE 
				IF pol0933_verifica_duplicidade() THEN
					ERROR"Codigo já cadastrado!!!"
				NEXT FIELD cod_parametro
				END IF 
			END IF 
		AFTER FIELD	den_parametro 
			IF p_par_solc_fat_codesp.den_parametro IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD den_parametro
			END IF 
		AFTER FIELD	cond_pagto
			IF p_par_solc_fat_codesp.cond_pagto IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cond_pagto
			ELSE 
				IF NOT pol0933_verifica_cond_pagto() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD cond_pagto
				END IF  
			END IF 
		AFTER FIELD	clas_fiscal
			IF p_par_solc_fat_codesp.clas_fiscal IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD clas_fiscal
			ELSE 
				IF NOT pol0933_verifica_clas_fiscal() THEN
					ERROR"Código não cadastrado!!!"
				NEXT FIELD clas_fiscal
				END IF 
			END IF 
		AFTER FIELD	finalidade 
			IF p_par_solc_fat_codesp.finalidade IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD finalidade
			ELSE 
				IF p_par_solc_fat_codesp.finalidade<>'1' AND  p_par_solc_fat_codesp.finalidade<>'2' AND  p_par_solc_fat_codesp.finalidade<>'3' THEN 
					ERROR"Valor inválido!! '1-contribuinte' '2-nao contribuinte' '3-contribuinte uso'"
					NEXT FIELD finalidade
				END IF 
			END IF 
		AFTER FIELD	item_prod
			IF p_par_solc_fat_codesp.item_prod IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD item_prod
			ELSE 
				IF p_par_solc_fat_codesp.item_prod<>'B' AND p_par_solc_fat_codesp.item_prod<>'P' AND 
					 p_par_solc_fat_codesp.item_prod<>'C' AND p_par_solc_fat_codesp.item_prod <>'F' THEN 
					ERROR"Valor inválido!!"
					NEXT FIELD item_prod
				END IF 
			END IF 
		AFTER FIELD	moeda
			IF p_par_solc_fat_codesp.moeda IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD moeda
			ELSE 
				IF NOT  pol0933_verifica_moeda() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD moeda
				END IF 
			END IF 
		AFTER FIELD	natureza_operacao
			IF p_par_solc_fat_codesp.natureza_operacao IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD natureza_operacao
			ELSE 
				IF NOT pol0933_verifica_natureza_operacao() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD natureza_operacao
				END IF  
			END IF
		AFTER FIELD	nat_oper_nao_trib
			IF p_par_solc_fat_codesp.nat_oper_nao_trib IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD nat_oper_nao_trib
			ELSE 
				IF NOT pol0933_verifica_nat_oper_nao_trib() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD nat_oper_nao_trib
				END IF  
			END IF 
		AFTER FIELD	tip_carteira
			IF p_par_solc_fat_codesp.tip_carteira IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD tip_carteira
			ELSE 
				IF NOT pol0933_verifica_tip_carteira() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD tip_carteira
				END IF 
			END IF 
		AFTER FIELD	tipo_preco
			IF p_par_solc_fat_codesp.tipo_preco IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD tipo_preco
			ELSE 
				IF p_par_solc_fat_codesp.tipo_preco<>'F' AND p_par_solc_fat_codesp.tipo_preco<>'R' THEN
					ERROR"Valor inválido!!!Digite 'F-Firme','R-Reajustavel'"
					NEXT FIELD tipo_preco
				END IF 
			END IF 
		AFTER FIELD	tipo_venda
			IF p_par_solc_fat_codesp.tipo_venda IS NULL THEN 
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD tipo_venda
			ELSE 
				IF NOT pol0933_verifica_tipo_venda() THEN
					ERROR"Código não cadastrado!!!"
					NEXT FIELD tipo_venda
				END IF 
			END IF 
		{AFTER FIELD cam_import
			IF p_par_solc_fat_codesp.cam_import IS NULL THEN
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cam_import
			END IF 
		
		AFTER FIELD cam_export
			IF p_par_solc_fat_codesp.cam_export IS NULL THEN
				ERROR"Campo de preenchimento obrigatorio!!!"
				NEXT FIELD cam_export
			END IF}
		
		ON KEY (control-z)
		CALL pol0933_popup()
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#--------------------------------------#
FUNCTION pol0933_verifica_duplicidade()#
#--------------------------------------#
DEFINE l_cont	SMALLINT
	SELECT COUNT(*)
	INTO l_cont
	FROM par_solc_fat_codesp
	WHERE cod_empresa = p_cod_empresa
	AND cod_parametro = p_par_solc_fat_codesp.cod_parametro
	IF l_cont>0 THEN
		RETURN TRUE 
	ELSE
		RETURN FALSE	
	END IF
END FUNCTION 
#--------------------------------------#
FUNCTION pol0933_verifica_cond_pagto() #
#--------------------------------------#
DEFINE l_den				CHAR(30)
	SELECT den_cnd_pgto 
	INTO l_den
	FROM cond_pgto
	WHERE cod_cnd_pgto = p_par_solc_fat_codesp.cond_pagto
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_cond_pagto
		RETURN TRUE 
	END IF 
END FUNCTION 
#---------------------------------------#
FUNCTION pol0933_verifica_clas_fiscal()#
#---------------------------------------#
DEFINE l_den 				SMALLINT
	SELECT COUNT(*)
	INTO l_den
	FROM clas_fiscal
	WHERE cod_cla_fisc = p_par_solc_fat_codesp.clas_fiscal
	IF l_den = 0 THEN
		RETURN FALSE 
	ELSE
		RETURN TRUE 
	END IF 
END FUNCTION 
#---------------------------------#
FUNCTION pol0933_verifica_moeda() #
#---------------------------------#
DEFINE l_den 				CHAR(15)
	SELECT den_moeda 
	INTO l_den
	FROM moeda
	WHERE cod_moeda = p_par_solc_fat_codesp.moeda
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_moeda
		RETURN TRUE 
	END IF 
END FUNCTION 
#--------------------------------------------#
FUNCTION pol0933_verifica_natureza_operacao()#
#--------------------------------------------#
DEFINE l_den 				CHAR(30)
			 
	SELECT den_nat_oper
	INTO l_den
	FROM nat_operacao
	WHERE cod_nat_oper= p_par_solc_fat_codesp.natureza_operacao
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_natureza_operacao
		RETURN TRUE 
	END IF 
END FUNCTION 
#--------------------------------------------#
FUNCTION pol0933_verifica_nat_oper_nao_trib()#
#--------------------------------------------#
DEFINE l_den 				CHAR(30)
			 
	SELECT den_nat_oper
	INTO l_den
	FROM nat_operacao
	WHERE cod_nat_oper= p_par_solc_fat_codesp.nat_oper_nao_trib
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_nat_oper_nao_trib
		RETURN TRUE 
	END IF 
END FUNCTION 
#-----------------------------------------#
FUNCTION  pol0933_verifica_tip_carteira() #
#-----------------------------------------#
DEFINE l_den 				CHAR(15)
	SELECT den_tip_carteira 
	INTO l_den
	FROM tipo_carteira
	WHERE cod_tip_carteira = p_par_solc_fat_codesp.tip_carteira
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_tip_carteira
		RETURN TRUE 
	END IF 
END FUNCTION 
#-------------------------------------#
FUNCTION pol0933_verifica_tipo_venda()#
#-------------------------------------#
DEFINE l_den 				CHAR(15)
	SELECT  den_tip_venda
	INTO l_den
	FROM tipo_venda
	WHERE cod_tip_venda=p_par_solc_fat_codesp.tipo_venda
	IF SQLCA.SQLCODE<>0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_den TO den_tipo_venda
		RETURN TRUE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol0933_incluir()#
#-------------------------#
	INITIALIZE p_par_solc_fat_codesp TO NULL 
	IF pol0933_entrada_dados('I') THEN
		CALL log085_transacao("BEGIN")
		LET p_par_solc_fat_codesp.cod_empresa = p_cod_empresa
		INSERT INTO par_solc_fat_codesp VALUES (p_par_solc_fat_codesp.*)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('Incluir','par_solc_fat_codesp')
				CLEAR FORM 
				INITIALIZE p_par_solc_fat_codesp.* TO NULL 
				ERROR"Inclusão cancelada!"
				RETURN FALSE 
			ELSE
				CALL log085_transacao("COMMIT")
				MESSAGE"Dados incuidos com sucesso!!"
				RETURN TRUE
			END IF 
	ELSE
		CLEAR FORM 
		INITIALIZE p_par_solc_fat_codesp TO NULL 
		ERROR"Inclusão cancelada!"
		RETURN FALSE 
	END IF 
END FUNCTION 
#-------------------------#
FUNCTION pol0933_excluir()#
#-------------------------#
	IF pol0933_cursor_para_alterar() THEN
		IF log004_confirm(18,35) THEN
			WHENEVER ERROR CONTINUE
			DELETE FROM par_solc_fat_codesp
			WHERE CURRENT OF cm_padrao
			IF SQLCA.SQLCODE = 0 THEN
				CALL log085_transacao("COMMIT")
				MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				INITIALIZE p_par_solc_fat_codesp.* TO NULL
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
 FUNCTION pol0933_cursor_para_alterar()#
#--------------------------------------#
WHENEVER ERROR CONTINUE
	DECLARE cm_padrao CURSOR WITH HOLD FOR	SELECT * INTO p_par_solc_fat_codesp.*                                              
																					FROM par_solc_fat_codesp
																					WHERE cod_empresa = p_par_solc_fat_codesp.cod_empresa
																					AND  cod_parametro    = p_par_solc_fat_codesp.cod_parametro
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
			OTHERWISE CALL log003_err_sql("LEITURA","par_solc_fat_codesp")
		END CASE
	CALL log085_transacao("ROLLBACK")
WHENEVER ERROR STOP
RETURN FALSE
END FUNCTION
#-------------------------#
FUNCTION pol0933_alterar()#
#-------------------------#
	IF pol0933_cursor_para_alterar() THEN
		LET p_par_solc_fat_codesp1.* = p_par_solc_fat_codesp.*
		IF pol0933_entrada_dados('A') THEN
			WHENEVER ERROR CONTINUE
				UPDATE par_solc_fat_codesp
				SET den_parametro	= p_par_solc_fat_codesp.den_parametro,
						cond_pagto		= p_par_solc_fat_codesp.cond_pagto,
						clas_fiscal		= p_par_solc_fat_codesp.clas_fiscal,
						finalidade		= p_par_solc_fat_codesp.finalidade ,
						item_prod			= p_par_solc_fat_codesp.item_prod,
						moeda					= p_par_solc_fat_codesp.moeda,
						natureza_operacao 	=p_par_solc_fat_codesp.natureza_operacao,
						nat_oper_nao_trib		=p_par_solc_fat_codesp.nat_oper_nao_trib,
						tip_carteira 	= p_par_solc_fat_codesp.tip_carteira,
						tipo_preco		= p_par_solc_fat_codesp.tipo_preco,
						tipo_venda		= p_par_solc_fat_codesp.tipo_venda
						#cam_import		= p_par_solc_fat_codesp.cam_import,
						#cam_export		= p_par_solc_fat_codesp.cam_export
				WHERE CURRENT OF cm_padrao
		
				IF SQLCA.SQLCODE = 0 THEN
					CALL log085_transacao("COMMIT")
					MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
				ELSE
					CALL log085_transacao("ROLLBACK")
					CALL log003_err_sql("MODIFICACAO","par_solc_fat_codesp")
				END IF
		ELSE
			CALL log085_transacao("ROLLBACK")
			LET p_par_solc_fat_codesp.* = p_par_solc_fat_codesp1.*
			ERROR "Modificacao Cancelada"
			CALL pol0933_exibe_dados()
		END IF
			CLOSE cm_padrao
	END IF
END FUNCTION 
#---------------------------#
FUNCTION pol0933_consultar()#
#---------------------------#
DEFINE  where_clause, sql_stmt		CHAR(300)				

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	LET p_par_solc_fat_codesp1.* = p_par_solc_fat_codesp.*
	
	CONSTRUCT BY NAME where_clause ON cod_parametro ,
																		den_parametro,
																		cond_pagto,
																		clas_fiscal,
																		finalidade,
																		item_prod,
																		moeda,
																		natureza_operacao ,
																		nat_oper_nao_trib,
																		tip_carteira,
																		tipo_preco,
																		tipo_venda
																		#cam_import,
																		#cam_export 
		ON KEY(control-z)
		CALL pol0933_popup()									
	END CONSTRUCT
	CALL log006_exibe_teclas("01",p_versao)
	CURRENT WINDOW IS w_pol0933
	IF INT_FLAG THEN
		LET INT_FLAG = 0 
		LET p_par_solc_fat_codesp.* = p_par_solc_fat_codesp1.*
		#CALL pol0933_exibe_dados()
		ERROR "Consulta Cancelada"
	RETURN
	END IF
	LET sql_stmt = 	"SELECT * FROM par_solc_fat_codesp ",
						    	" WHERE ",where_clause CLIPPED,             
						   		" AND cod_empresa = '",p_cod_empresa,"' ",
						    	"ORDER BY cod_parametro "
	
	PREPARE var_query FROM sql_stmt   
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	OPEN cq_padrao
	FETCH cq_padrao INTO p_par_solc_fat_codesp.*
	IF SQLCA.SQLCODE = NOTFOUND THEN
		ERROR "Argumentos de Pesquisa nao Encontrados"
		LET p_ies_cons = FALSE
	ELSE 
		LET p_ies_cons = TRUE
		CALL pol0933_exibe_dados()
	END IF
END FUNCTION 
#-----------------------------------#
FUNCTION pol0933_paginacao(p_funcao)#
#-----------------------------------#
DEFINE p_funcao CHAR(20)
	IF p_ies_cons THEN
		LET p_par_solc_fat_codesp1.* = p_par_solc_fat_codesp.*
		WHILE TRUE
			CASE
				WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO  p_par_solc_fat_codesp.*
				WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO  p_par_solc_fat_codesp.*
			END CASE
			IF SQLCA.SQLCODE = NOTFOUND THEN
				ERROR "Nao Existem Mais Itens Nesta Direção"
				LET p_par_solc_fat_codesp.* = p_par_solc_fat_codesp1.* 
				EXIT WHILE
			END IF
			SELECT * INTO p_par_solc_fat_codesp.* 
			FROM par_solc_fat_codesp
			WHERE cod_empresa    = p_par_solc_fat_codesp.cod_empresa
			AND cod_parametro = p_par_solc_fat_codesp.cod_parametro
			IF SQLCA.SQLCODE = 0 THEN  
				CALL pol0933_exibe_dados()
				EXIT WHILE
			END IF
		END WHILE
	ELSE
		ERROR "Nao Existe Nenhuma Consulta Ativa"
	END IF
END FUNCTION 
#-----------------------#
FUNCTION pol0933_popup()#
#-----------------------#
DEFINE p_codigo  CHAR(15)
      
	CASE
		WHEN INFIELD(natureza_operacao)
			CALL log009_popup(8,10,"CODIGO DA OPERAÇÃO","nat_operacao",
						"cod_nat_oper","den_nat_oper","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.natureza_operacao = p_codigo CLIPPED
				DISPLAY p_codigo TO natureza_operacao
			END IF
		WHEN INFIELD(nat_oper_nao_trib)
			CALL log009_popup(8,10,"CODIGO DA OPERAÇÃO","nat_operacao",
						"cod_nat_oper","den_nat_oper","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.nat_oper_nao_trib = p_codigo CLIPPED
				DISPLAY p_codigo TO nat_oper_nao_trib
			END IF
						
		WHEN INFIELD(clas_fiscal)
			CALL log009_popup(8,10,"CODIGO CLASSIFICAÇÃO FISCAL","clas_fiscal",
						"cod_cla_fisc","cod_unid_med_fisc","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.clas_fiscal = p_codigo CLIPPED
				DISPLAY p_codigo TO clas_fiscal
			END IF
		WHEN INFIELD(cond_pagto)
			CALL log009_popup(8,10,"CODIGO CONDIÇÃO DE PAGAMENTO","cond_pgto",
						"cod_cnd_pgto","den_cnd_pgto","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.cond_pagto = p_codigo CLIPPED
				DISPLAY p_codigo TO cond_pagto
			END IF
		WHEN INFIELD(moeda)
			CALL log009_popup(8,10,"CODIGO","moeda",
						"cod_moeda","den_moeda","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.moeda = p_codigo CLIPPED
				DISPLAY p_codigo TO moeda
			END IF
		WHEN INFIELD(tipo_venda)
			CALL log009_popup(8,10,"CODIGO","tipo_venda",
						"cod_tip_venda","den_tip_venda","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.tipo_venda = p_codigo CLIPPED
				DISPLAY p_codigo TO tipo_venda
			END IF
		WHEN INFIELD(tip_carteira)
			CALL log009_popup(8,10,"CODIGO","tipo_carteira",
						"cod_tip_carteira","den_tip_carteira","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0933
			IF p_codigo IS NOT NULL THEN
				LET p_par_solc_fat_codesp.tip_carteira = p_codigo CLIPPED
				DISPLAY p_codigo TO tip_carteira 
			END IF
	END CASE
END FUNCTION 
#-----------------------------#
FUNCTION pol0933_exibe_dados()#
#-----------------------------#
	DISPLAY p_par_solc_fat_codesp.cod_parametro     TO cod_parametro    
	DISPLAY p_par_solc_fat_codesp.den_parametro     TO den_parametro    
	DISPLAY p_par_solc_fat_codesp.cond_pagto        TO cond_pagto       
	DISPLAY p_par_solc_fat_codesp.clas_fiscal       TO clas_fiscal      
	DISPLAY p_par_solc_fat_codesp.finalidade        TO finalidade       
	DISPLAY p_par_solc_fat_codesp.item_prod         TO item_prod        
	DISPLAY p_par_solc_fat_codesp.moeda             TO moeda            
	DISPLAY p_par_solc_fat_codesp.natureza_operacao TO natureza_operacao
	DISPLAY p_par_solc_fat_codesp.nat_oper_nao_trib TO nat_oper_nao_trib
	DISPLAY p_par_solc_fat_codesp.tip_carteira      TO tip_carteira     
	DISPLAY p_par_solc_fat_codesp.tipo_preco        TO tipo_preco       
	DISPLAY p_par_solc_fat_codesp.tipo_venda        TO tipo_venda       
	
	CALL pol0933_verifica_cond_pagto ()				RETURNING p_retorno
	CALL pol0933_verifica_moeda() 						RETURNING p_retorno
	CALL pol0933_verifica_natureza_operacao() RETURNING p_retorno
	CALL pol0933_verifica_nat_oper_nao_trib() RETURNING p_retorno
	CALL pol0933_verifica_tip_carteira() 			RETURNING p_retorno
	CALL pol0933_verifica_tip_carteira ()			RETURNING p_retorno
	CALL pol0933_verifica_tipo_venda 	()			RETURNING p_retorno
END FUNCTION