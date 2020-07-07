#-------------------------------------------------------------------------#
# SISTEMA.: Finaliza operações de retrabalho  		                				#
#	PROGRAMA:	pol0979																												#
#	CLIENTE.:	Grauna																												#
#	OBJETIVO:	Finaliza operações de retrabalho            									#
#	AUTOR...:	THIAGO																												#
#	DATA....:	13/10/2009																										#
#-------------------------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		   	p_den_empresa					LIKE empresa.den_empresa,
		    p_user          			LIKE usuario.nom_usuario,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				p_resposta						SMALLINT,
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont								SMALLINT,
				p_nom_help      			CHAR(200),
				p_natureza_operacao		INTEGER,
				p_index								SMALLINT,
				s_index								SMALLINT,
				p_entrada							DECIMAL(06),
				p_tipo								CHAR(03),
				p_houve_erro					SMALLINT,
				p_print								SMALLINT
END GLOBALS

DEFINE p_retrabalho  	ARRAY [5000] OF RECORD
		num_ordem					LIKE ord_oper.num_ordem,
		cod_item					LIKE item.cod_item,
	#	qtd_planejada			LIKE ord_oper.qtd_planejada,
	#	qtd_boas					LIKE ord_oper.qtd_boas,
	#	qtd_rejeitada			LIKE ord_oper.qtd_sucata,
		processa					CHAR(01)
END RECORD 

MAIN
	CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0979-05.10.03"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0903.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0979_controle()
   END IF
END MAIN  

#---------------------------#
FUNCTION  pol0979_controle()#
#---------------------------#
		CALL log006_exibe_teclas('01', p_versao)
		CALL log130_procura_caminho("pol0979") RETURNING p_caminho
		
		OPEN WINDOW w_pol0979 AT 2,2  WITH FORM  p_caminho 
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
		
		
		CURRENT WINDOW IS w_pol0979
		DISPLAY p_cod_empresa TO cod_empresa  
		LET p_ies_cons = FALSE
		LET p_retorno = FALSE          
		
		MENU 'OPCAO'
			COMMAND 'Consultar' 'Consulta Ordens De Retrabalho'
				HELP 001
				CALL pol0979_lista_ord() RETURNING p_ies_cons
				NEXT OPTION 'Selecionar'
			
			COMMAND 'Selecionar' 'Seleciona Ordens De Retrabalho Desejada'
				HELP 002
				MESSAGE ''
				IF p_ies_cons THEN 
					IF pol0979_seleciona() THEN 
						LET p_retorno = TRUE
						NEXT OPTION  'Processar'
					ELSE
						ERROR "Operação cancelada"
					END IF 
				ELSE
					ERROR"Por favor listar antes de selecionar"
					NEXT OPTION 'Consultar'
				END IF 
				
			COMMAND 'selecTodos' 'Seleciona Todas Ordens De Retrabalho'
				HELP 003
				MESSAGE ''
				IF p_ies_cons THEN 
					CALL  pol0979_seleciona_todas()
					LET p_retorno = TRUE
					NEXT OPTION  'Processar'
				ELSE
					ERROR"Por favor listar antes de selecionar"
					NEXT OPTION 'Consultar'
				END IF 

			COMMAND 'Processar' 'Exibe Ordens De Retrabalho'
				HELP 004
				IF pol0979_processa() THEN
					LET p_ies_cons = FALSE
					LET p_retorno = FALSE 
					NEXT OPTION  'Fim'
				ELSE
					LET p_ies_cons = FALSE
					LET p_retorno = FALSE 
					ERROR"Erro ao processar dados!"
					NEXT OPTION 'Consultar'  
				END IF
			
			COMMAND KEY ("!")
				PROMPT "Digite o comando : " FOR comando
				RUN comando
			
			COMMAND 'Fim'       'Retorna ao menu anterior.'
				HELP 008
				EXIT MENU
		END MENU
		
		CLOSE WINDOW w_pol0979
	
END FUNCTION 

#----------------------------#		Procura e encontra ordens que nao estejam finalizadas que sejam retrabalho verifica
FUNCTION  pol0979_lista_ord()#		se as mesmas tem quantidade de todas as operações são superiores a quantidade planejada
#----------------------------#		se forem adicionar a um array e mandada a tela para o usuarios escolher quais processar
DEFINE l_num_ord_ret			LIKE ordens.NUM_ORDEM,
			 l_retorno					SMALLINT,
			 l_cod_item					LIKE item.cod_item,
			 l_qtd_planejada		LIKE ord_oper.qtd_planejada,
			 l_qtd_boas					LIKE ord_oper.qtd_boas,
			 l_qtd_rejeitada		LIKE ord_oper.qtd_sucata
			 
	INITIALIZE p_retrabalho TO NULL 
	CLEAR FORM
	
	LET p_cont= 0
	DECLARE cq_retrabalho CURSOR FOR 	SELECT UNIQUE  A.NUM_ORDEM,  B.COD_ITEM
																		FROM NCA_FO_RETRAB_1040 A, ORDENS B
																		WHERE TIPO = 'P'
																		AND A.COD_EMPRESA = p_cod_empresa
																		AND A.COD_EMPRESA = B.COD_EMPRESA
																		AND A.NUM_ORDEM = B.NUM_ORDEM
																		AND B.IES_SITUA = '4'
																		
		FOREACH cq_retrabalho INTO l_num_ord_ret, l_cod_item
		LET l_retorno = FALSE
		
		DECLARE cq_ord_oper CURSOR FOR SELECT qtd_planejada,qtd_boas,qtd_sucata
																		FROM ord_oper
																	 WHERE num_ordem = l_num_ord_ret
																	 AND cod_empresa = p_cod_empresa
																	 AND ies_apontamento = 'S'
		FOREACH cq_ord_oper INTO l_qtd_planejada, l_qtd_boas, l_qtd_rejeitada
			IF l_qtd_planejada >(l_qtd_boas + l_qtd_rejeitada) THEN 
				LET l_retorno = TRUE 
				EXIT FOREACH
			END IF 
		END FOREACH
		IF NOT l_retorno THEN 
			LET p_cont= p_cont + 1
			
			LET p_retrabalho[p_cont].num_ordem = l_num_ord_ret
			LET p_retrabalho[p_cont].cod_item  = l_cod_item
		#	LET p_retrabalho[p_cont].qtd_boas  = l_qtd_boas
		#	LET p_retrabalho[p_cont].qtd_rejeitada = l_qtd_rejeitada
		#	LET p_retrabalho[p_cont].qtd_planejada = l_qtd_planejada
			LET p_retrabalho[p_cont].processa = 'N'
		END IF
		IF p_cont >= 5000 THEN 
			EXIT FOREACH
		END IF 
	END FOREACH
	IF p_cont > 0 THEN
		CALL SET_COUNT(p_cont)
		IF p_cont > 5000 THEN 
      DISPLAY ARRAY p_retrabalho TO s_retrabalho.*
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
		ELSE 
			INPUT ARRAY p_retrabalho WITHOUT DEFAULTS FROM s_retrabalho.*
	      BEFORE INPUT
	         EXIT INPUT
	   	END INPUT
   	END IF 
   	RETURN TRUE 	
	ELSE
		CALL log0030_mensagem("Nenhum registro encontrado!!!","info")
		RETURN FALSE
	END IF 
	
END FUNCTION 

#---------------------------# 		Faz um update em todas as ordens que o usuario selecionou
FUNCTION  pol0979_processa()#			mudanto o status da ordem para 5 e quantidade de peças boas
#---------------------------#			fica igual a quantidade de peças planejadas.
DEFINE l_index SMALLINT
	
	CALL SET_COUNT(p_cont)
	CALL log085_transacao("BEGIN")
	FOR l_index = 1 TO ARR_COUNT()
		IF p_retrabalho[l_index].processa = "S" THEN 
			UPDATE ordens 
				SET IES_SITUA = '5',
				qtd_boas = qtd_planej
			WHERE cod_empresa = p_cod_empresa
			AND num_ordem = p_retrabalho[l_index].NUM_ORDEM
			
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("UPDATE","ordens")
				CALL log085_transacao("ROLLBACK")
				RETURN FALSE
			ELSE 
				MESSAGE "Processando ordem N. ", p_retrabalho[l_index].num_ordem
			END IF 
		END IF 
	END FOR
	MESSAGE "Dados processados com sucesso!!!"
	CALL log085_transacao("COMMIT")
	RETURN TRUE 
END FUNCTION

#----------------------------------#	Seleciona todas as ordens para que possa ser processadas
FUNCTION  pol0979_seleciona_todas()#
#----------------------------------#
DEFINE l_index SMALLINT

 FOR l_index = 1  TO ARR_COUNT()
 	LET p_retrabalho[l_index].processa ='S'
 END FOR 
 	INPUT ARRAY p_retrabalho WITHOUT DEFAULTS FROM s_retrabalho.*
		BEFORE INPUT
			EXIT INPUT
	END INPUT
END FUNCTION

#----------------------------#	Selciona ordem a ordem para ser processada utilizando um input e limitando ele 
FUNCTION  pol0979_seleciona()#	ao tamanho do array para que nao adicione alem do tamanho do array
#----------------------------#
	CALL log006_exibe_teclas("01 02 07",p_versao)
	CURRENT WINDOW IS w_pol0979
	CALL SET_COUNT(p_cont)
	
	INPUT ARRAY p_retrabalho WITHOUT DEFAULTS FROM s_retrabalho.*
		ATTRIBUTE(MAXCOUNT=ARR_COUNT())
	
		BEFORE ROW
			LET p_index = ARR_CURR() 
			LET s_index = SCR_LINE()
		AFTER FIELD processa
			IF p_retrabalho[p_index].processa IS NULL THEN 
				ERROR "Campo de preenchimento obrigatório!!!"
				NEXT FIELD processa
			ELSE 
				IF NOT (p_retrabalho[p_index].processa = 'S' OR p_retrabalho[p_index].processa ='N') THEN 
					ERROR "Valor invalido!!!"
					NEXT FIELD processa
				END IF 
			END IF 
	END INPUT
	IF INT_FLAG = 0 THEN
		RETURN TRUE
	ELSE
		CLEAR FORM
		LET INT_FLAG = 0
		RETURN FALSE 
	END IF   
END FUNCTION