#-----------------------------------------------------------#
# SISTEMA.: RELATORIO DE RAZAO															#
#	PROGRAMA:	pol0951																					#
#	CLIENTE.:	CODESP																					#
#	OBJETIVO:	GERAR RELATORIO DE RAZAO												#
#	AUTOR...:	THIAGO																					#
#	DATA....:	11/05/2009																			#
#-----------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   			LIKE empresa.cod_empresa,
		    p_user          			LIKE usuario.nom_usuario,
		    p_den_empresa					LIKE empresa.den_empresa,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_nom_help      			CHAR(200),
				p_den_mes							CHAR(08),
				p_saldo								LIKE saldos.val_saldo_acum,
				p_saldo_ant						LIKE saldos.val_saldo_acum,
				p_den_conta						LIKE plano_contas.den_conta,
				p_cont								SMALLINT,
				p_ies_impressao       CHAR(01),
				g_ies_ambiente        CHAR(01)
END GLOBALS 
DEFINE p_entrada RECORD 
				dat_movto_ini			DATE,				
				dat_movto_fim			DATE,				
				num_conta_ini			LIKE plano_contas.num_conta,
				num_conta_fim			LIKE plano_contas.num_conta
END RECORD 
DEFINE p_razao RECORD
				den_sistema_ger				LIKE	lancamentos.den_sistema_ger, 
				per_contabil					LIKE	lancamentos.per_contabil,	
				cod_seg_periodo				LIKE	lancamentos.cod_seg_periodo,
				num_lote							LIKE	lancamentos.num_lote,
				dat_movto							LIKE	lancamentos.dat_movto, 
				ies_tip_lanc					LIKE	lancamentos.ies_tip_lanc, 
				num_conta							LIKE	plano_contas.num_conta_reduz,
				num_lanc							LIKE	lancamentos.num_lanc, 
				num_relacionto				LIKE	lanctos_compl.num_relacionto,
				num_conta_cpartida		LIKE	plano_contas.num_conta_reduz,
				val_lancto						LIKE  ctb_lanc_ctbl_ctb.val_lancto
END RECORD 

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0951-10.02.00"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0951.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
	  CALL pol0951_controle()
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol0951_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0951") RETURNING comando
	OPEN WINDOW w_pol0951 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	LET p_retorno = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0951_entrada_dados() RETURNING p_retorno
				NEXT OPTION "Listar"
			END IF
		
		COMMAND "Listar"  "Lista dados"
			HELP 1053
			IF p_retorno THEN
				IF log005_seguranca(p_user,"VDP","pol0903","MO") THEN
					IF log028_saida_relat(18,35) IS NOT NULL THEN
						MESSAGE " Processando a Extracao do Relatorio..." 
						ATTRIBUTE(REVERSE)
						IF p_ies_impressao = "S" THEN
							IF g_ies_ambiente = "U" THEN
								START REPORT pol0951_relat TO PIPE p_nom_arquivo
							ELSE
								CALL log150_procura_caminho ('LST') RETURNING p_caminho
								LET p_caminho = p_caminho CLIPPED, 'pol0903.tmp'
								START REPORT pol0951_relat  TO p_caminho
							END IF
						ELSE
							START REPORT pol0951_relat TO p_nom_arquivo
						END IF
						IF NOT  pol0951_listar() THEN
							LET p_retorno = FALSE 
							ERROR "Erro ao processar dados "
						END IF   
						FINISH REPORT pol0951_relat 
						LET p_retorno = FALSE   
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
				END IF     
			ELSE
				ERROR "Por favor informar parametros!"
				NEXT OPTION "Informar"
			END IF
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0951
END FUNCTION

#--------------------------------#
FUNCTION  pol0951_entrada_dados()#
#--------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CLEAR FORM 
 	CURRENT WINDOW IS w_pol0933	
 	DISPLAY p_cod_empresa TO cod_empresa
 	INPUT BY NAME p_entrada.*
 		BEFORE  INPUT
		 	LET p_entrada.dat_movto_ini = CURRENT
		 	LET p_entrada.dat_movto_fim = CURRENT
		 	DISPLAY p_entrada.dat_movto_ini  TO dat_movto_ini
		 	DISPLAY p_entrada.dat_movto_fim  TO dat_movto_fim 
 	
 		AFTER FIELD dat_movto_ini
 			IF p_entrada.dat_movto_ini IS NULL THEN
 				ERROR"Campo de Prenchimento Obrigatório!"
 				NEXT FIELD dat_movto_ini
 			END IF 
 		AFTER FIELD dat_movto_fim
			IF p_entrada.dat_movto_fim IS NULL THEN
 				ERROR"Campo de Prenchimento Obrigatório!"
 				NEXT FIELD dat_movto_fim
 			ELSE 
 				IF p_entrada.dat_movto_fim < p_entrada.dat_movto_ini THEN
 					ERROR"Data Final não pode ser menor que a data inicial"
 					NEXT FIELD dat_movto_fim
 				ELSE
 					IF NOT  pol0951_valida_data() THEN 
 						ERROR"Periodo de datas nao podem ser de meses diferentes"
 						NEXT FIELD dat_movto_fim
 					END IF 
 				END IF 
 			END IF
 		AFTER FIELD num_conta_ini
 			IF p_entrada.num_conta_ini IS NOT NULL THEN 
 				IF NOT pol0952_verifica_conta(p_entrada.num_conta_ini) THEN
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_ini
 				END IF 
 			END IF 
 		BEFORE  FIELD num_conta_fim
 			IF p_entrada.num_conta_ini IS NULL THEN
 				EXIT INPUT
 			END IF
 		AFTER FIELD num_conta_fim
 			IF p_entrada.num_conta_fim IS NULL THEN
 				ERROR"Campo de Preenchimento Obraigatório"
 				NEXT FIELD num_conta_fim
 			ELSE  
 				IF NOT pol0951_verifica_conta(p_entrada.num_conta_fim) THEN 
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_fim
 				END IF 
 			END IF
 		ON KEY (control-z)
    	CALL pol0951_popup()  
 	END INPUT
 	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#------------------------------#
FUNCTION  pol0951_valida_data()#
#------------------------------#
	DEFINE l_con SMALLINT
	
	SELECT COUNT(PER_CONTABIL)
	INTO l_con
	FROM PERIODOS
	WHERE COD_EMPRESA=p_cod_empresa
	AND DAT_INI_SEG_PER<=p_entrada.dat_movto_ini
	AND DAT_FIM_SEG_PER>=p_entrada.dat_movto_fim
	
	IF l_con > 0 THEN 
		RETURN TRUE
	ELSE
		RETURN FALSE 
	END IF 
END FUNCTION
 
#--------------------------#
FUNCTION  pol0951_den_mes()#														#VERIFICANDO O MES E INSERINDO A DENOMINAÇAO
#--------------------------#														#PARA EXIBIR EM TELA DE POSTERIORMENTE NO RELATORIO
DEFINE 	l_mes			INTEGER
	LET l_mes = MONTH(p_razao.cod_seg_periodo)
	CASE
		WHEN l_mes =  1
			LET p_den_mes = 'JANEIRO'
		WHEN l_mes = 2
			LET p_den_mes = 'FEVEREIRO'
		WHEN l_mes = 3
			LET p_den_mes = 'MARCO'
		WHEN l_mes = 4
			LET p_den_mes = 'ABRIL'
		WHEN l_mes = 5
			LET p_den_mes = 'MAIO'
		WHEN l_mes = 6
			LET p_den_mes = 'JUNHO'
		WHEN l_mes = 7
			LET p_den_mes = 'JULHO'
		WHEN l_mes = 8
			LET p_den_mes = 'AGOSTO'
		WHEN l_mes = 9
			LET p_den_mes = 'SETEMBRO'
		WHEN l_mes = 10
			LET p_den_mes = 'OUTUBRO'
		WHEN l_mes = 11
			LET p_den_mes = 'NOVEMBRO'
		WHEN l_mes = 12
			LET p_den_mes = 'DEZEMBRO'
	END CASE
	
END FUNCTION
#------------------------#
FUNCTION  pol0951_popup()#
#------------------------#
DEFINE p_codigo CHAR(25)
	IF  INFIELD(num_conta_ini) OR INFIELD(num_conta_fim) THEN 
		CALL log009_popup(8,10,"CONTAS","plano_contas",
		"num_conta","den_conta","","S","") 
		RETURNING p_codigo
		CALL log006_exibe_teclas("01 02 07", p_versao)
		CURRENT WINDOW IS w_pol0951
		IF p_codigo IS NOT NULL THEN
			IF  INFIELD(num_conta_ini) THEN 
				LET p_entrada.num_conta_ini = p_codigo CLIPPED
				DISPLAY p_codigo TO num_conta_ini
			ELSE
				LET p_entrada.num_conta_fim = p_codigo CLIPPED
				DISPLAY p_codigo TO num_conta_fim
			END IF 
		END IF
	END IF 
END FUNCTION
#----------------------------------#
FUNCTION  pol0951_cria_temp_table()#
#----------------------------------#
	WHENEVER ERROR CONTINUE 
		DROP TABLE t_ord_c_partida
		CREATE TEMP TABLE t_ord_c_partida (
				num_seq							INTEGER ,
				cod_seg_periodo			DECIMAL(2,0),				
				ies_tip_lanc				CHAR(01),
				num_lanc						DECIMAL(7,0),		
				num_relacionto			DECIMAL(6,0),
				num_conta_cpartida 	CHAR(10),
				num_conta					 	CHAR(10),
				val_lancto				 	DECIMAL(17,2)
			)
		IF SQLCA.sqlcode<>0 THEN
			CALL log003_err_sql('Criar','t_ord_c_partida')
			RETURN FALSE
		END IF 
	WHENEVER ERROR STOP 
	RETURN TRUE
END FUNCTION 

#-----------------------------------#
FUNCTION  pol0951_saldo_ant(l_conta)#
#-----------------------------------#
DEFINE 	l_mes,l_ano		SMALLINT,
				l_saldo				LIKE saldos.val_saldo_acum,
				l_conta				CHAR(25)
	
	SELECT cod_seg_periodo , per_contabil
	INTO l_mes,l_ano
	FROM PERIODOS
	WHERE COD_EMPRESA=p_cod_empresa
	AND DAT_INI_SEG_PER<=p_entrada.dat_movto_ini
	AND DAT_FIM_SEG_PER>=p_entrada.dat_movto_fim
	
	IF l_mes = 1 THEN
		LET l_mes =12
		LET l_ano =l_ano - 1 
	ELSE
		LET l_mes =l_mes - 1
	END IF 
	
	SELECT VAL_SALDO_ACUM	
	INTO 	l_saldo
	FROM SALDOS
	WHERE PER_CONTABIL	=	l_ano
	AND COD_SEG_PERIODO	= l_mes
	AND COD_EMPRESA			=	p_cod_empresa
	AND NUM_CONTA				= l_conta
	
	RETURN l_saldo
END FUNCTION

#-------------------------------------#
FUNCTION pol0951_verifica_conta(l_num)#
#-------------------------------------#
	DEFINE 	l_den  	LIKE PLANO_CONTAS.DEN_CONTA,
					l_num		LIKE PLANO_CONTAS.NUM_CONTA
				
	SELECT  DEN_CONTA
	INTO l_den
	FROM PLANO_CONTAS
	WHERE COD_EMPRESA = p_cod_empresa
	AND NUM_CONTA 		= l_num
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN FALSE
	ELSE
		IF  INFIELD(num_conta_ini) THEN 
			DISPLAY l_den TO den_conta_ini
		ELSE
			DISPLAY  l_den TO den_conta_fim
		END IF 
		RETURN TRUE 
	END IF 
END FUNCTION
#-----------------------------------#
FUNCTION  pol0951_den_conta(l_conta)#
#-----------------------------------#
DEFINE l_conta						CHAR(23),
				l_cod_empresa_plano		CHAR(02)
	SELECT cod_empresa_plano											#Verifica se a a empresa tem um parametro de empresa 
	INTO l_cod_empresa_plano 											#para conta cadastrado, se tiver o prog pega o numero 
	FROM par_con																	#da empresa cadastrado ele vai fazer o filtro pelo 
	WHERE cod_empresa = p_cod_empresa							#numero da conta cadastrado senão ele vai o filtro
	IF l_cod_empresa_plano IS NOT NULL THEN 			#pela empresa logada
	
		SELECT DEN_CONTA  ,NUM_CONTA_REDUZ
		INTO p_den_conta,
				 p_razao.num_conta
		FROM PLANO_CONTAS
		WHERE COD_EMPRESA =	l_cod_empresa_plano
		AND NUM_CONTA 		=	l_conta
	ELSE
		SELECT DEN_CONTA ,NUM_CONTA_REDUZ
		INTO p_den_conta,
				 p_razao.num_conta
		FROM PLANO_CONTAS
		WHERE COD_EMPRESA =	p_cod_empresa
		AND NUM_CONTA 		=	l_conta
	END IF 
	IF SQLCA.SQLCODE<>0 THEN 	
		CALL log003_err_sql('LISTAR','PLANO_CONTAS')
		RETURN FALSE
	END IF
	RETURN TRUE 
END FUNCTION 

#-------------------------#
FUNCTION  pol0951_listar()#
#-------------------------#
DEFINE 	#l_per_contabil				INTEGER,
				l_cont								SMALLINT,
				l_conta								LIKE	lancamentos.num_conta,
				l_conta1							LIKE	lancamentos.num_conta,
				l_conta2							LIKE 	lancamentos.num_conta,
				l_cod_empresa_plano		CHAR(02),
				l_sql									CHAR(100),
				sql_stmt        			CHAR(999)
DEFINE p_razao1 RECORD
				den_sistema_ger				LIKE	lancamentos.den_sistema_ger, 
				per_contabil					LIKE	lancamentos.per_contabil,	
				cod_seg_periodo				LIKE	lancamentos.cod_seg_periodo,
				num_lote							LIKE	lancamentos.num_lote,
				dat_movto							LIKE	lancamentos.dat_movto, 
				ies_tip_lanc					LIKE	lancamentos.ies_tip_lanc, 
				num_conta							LIKE	plano_contas.num_conta_reduz,
				num_lanc							LIKE	lancamentos.num_lanc, 
				num_relacionto				LIKE	lanctos_compl.num_relacionto,
				num_conta_cpartida		LIKE	plano_contas.num_conta_reduz,
				val_lancto						LIKE  ctb_lanc_ctbl_ctb.val_lancto
END RECORD 
	
	INITIALIZE  l_conta1 TO  NULL
	LET p_cont = 0
	
	SELECT DEN_EMPRESA 
	INTO p_den_empresa
	FROM EMPRESA
	WHERE COD_EMPRESA = p_cod_empresa
	
	LET l_sql = ' '
	IF p_entrada.num_conta_ini THEN 
		LET l_sql=" AND A.NUM_CONTA	BETWEEN '" ,p_entrada.num_conta_ini,"' AND '",p_entrada.num_conta_fim,"' "
	END IF 
	
	LET sql_stmt = 	"SELECT A.DEN_SISTEMA_GER, A.PER_CONTABIL,	A.COD_SEG_PERIODO,A.NUM_LOTE, ",
									"A.DAT_MOVTO, A.IES_TIP_LANC, A.NUM_CONTA,A.NUM_LANC, B.NUM_RELACIONTO ",
									"FROM LANCAMENTOS A ,LANCTOS_COMPL B ",
									"WHERE A.COD_EMPRESA = '",p_cod_empresa,"'",
									"AND A.DAT_MOVTO BETWEEN '",p_entrada.dat_movto_ini,"' AND '",p_entrada.dat_movto_fim,"' ",
									l_sql,																					#variavel verifica se tem ou nao um peiodo de conta
									" AND A.COD_EMPRESA = B.COD_EMPRESA ",					#se tiver digitado uma conta ele insere um filtro
									"AND A.DEN_SISTEMA_GER = B.DEN_SISTEMA_GER ",		#no sql senão fica nulo
									"AND A.PER_CONTABIL = B.PER_CONTABIL ",
									"AND A.COD_SEG_PERIODO = B.COD_SEG_PERIODO ",
									"AND A.NUM_LOTE = B.NUM_LOTE ",
									"AND   A.NUM_LANC = B.NUM_LANC ",
									"ORDER BY A.NUM_CONTA,B.NUM_RELACIONTO "
	PREPARE var_queri FROM sql_stmt  
	DECLARE cq_conta SCROLL CURSOR WITH HOLD FOR var_queri
																								
	IF SQLCA.SQLCODE<>0 THEN 
		CALL log003_err_sql('LISTAR','LANCAMENTOS-LANCTOS_COMPL')
		RETURN FALSE
	END IF																				
	FOREACH cq_conta INTO p_razao.den_sistema_ger, 
												p_razao.per_contabil,	
												p_razao.cod_seg_periodo,
												p_razao.num_lote,							
												p_razao.dat_movto, 
												p_razao.ies_tip_lanc, 
												l_conta,
												p_razao.num_lanc, 
												p_razao.num_relacionto
												
		CALL pol0951_den_mes()												#pega a denominação do mes
 		
 		IF l_conta1 IS NULL THEN
 			LET l_conta1 = l_conta
 			LET l_conta2 = l_conta
 			IF NOT pol0951_cria_temp_table() THEN    								# cria a tabela temporaria para
		 			RETURN FALSE 																				#poder ordenar as contra partida
		 	END IF
 		ELSE
 			IF l_conta1<> l_conta THEN
 				IF l_conta1<> l_conta2 THEN
					SELECT VAL_SALDO_ACUM																	#carrega o saldo da conta, como
					INTO p_saldo																					#o saldo so aparece no evento before
					FROM SALDOS																						#group ele ai o numero da conta ja mudou
					WHERE PER_CONTABIL	=	p_razao.per_contabil						#então criou se essa outra variavel conta
					AND COD_SEG_PERIODO	= p_razao.cod_seg_periodo					#para que mantenha o numero da conta anterior
					AND COD_EMPRESA			=	p_cod_empresa
					AND NUM_CONTA				= l_conta2
					
					LET l_conta2=l_conta1
				END IF 
				LET p_razao1.*=p_razao.*		
				
				IF NOT pol0951_den_conta(l_conta1) THEN 								#pega a denominação da conta
					RETURN FALSE 
				END IF
				
				LET p_saldo_ant =  pol0951_saldo_ant(l_conta1)						#PEGA O SALDO ANTIGO PARA EXIBIR
				
				DECLARE cq_orden_cp CURSOR FOR 	SELECT COD_SEG_PERIODO,	IES_TIP_LANC,	NUM_LANC,	
																				NUM_RELACIONTO,	NUM_CONTA_CPARTIDA, NUM_CONTA,VAL_LANCTO			#partida para facilidar a visualização	
 																				FROM T_ORD_C_PARTIDA																					#a pedido do cliente			
 																				ORDER BY NUM_CONTA_CPARTIDA													
				
				FOREACH cq_orden_cp INTO 	p_razao.cod_seg_periodo,
																	p_razao.ies_tip_lanc,
																	p_razao.num_lanc,
																	p_razao.num_relacionto,
																	p_razao.num_conta_cpartida,
																	p_razao.num_conta,
																	p_razao.val_lancto
					CALL pol0951_relat(l_conta1)
				END FOREACH
				IF NOT pol0951_cria_temp_table() THEN    								# cria a tabela temporaria para
			 			RETURN FALSE 																				#poder ordenar as contra partida
			 	END IF			
				LET p_razao.*=p_razao1.*	
				LET l_conta1 = l_conta
			END IF 
		END IF 
		IF NOT pol0951_den_conta(l_conta) THEN 								#pega a denominação da conta
			RETURN FALSE 
		END IF
 		LET l_cont = 1
 			
 		DECLARE cq_cpartida SCROLL CURSOR WITH HOLD FOR 	SELECT VAL_LANCTO FROM CTB_LANC_CTBL_CTB					#PEGADO OS VALORES LANÇADO
																											WHERE EMPRESA   	= p_cod_empresa									#PARA OS LANÇAMENTOS
																											AND SISTEMA_GERADOR =	p_razao.den_sistema_ger
																											AND PERIODO_CONTAB  =	p_razao.per_contabil
																											AND SEGMTO_PERIODO  =	p_razao.cod_seg_periodo
																											AND LOTE_CONTAB	   	=	p_razao.num_lote
																											AND NUM_LANCTO	   	=	p_razao.num_lanc
																											AND NUM_RELACIONTO 	= p_razao.num_relacionto
 		
 		FOREACH cq_cpartida INTO p_razao.val_lancto
	 		IF SQLCA.SQLCODE<>0 THEN 	
	 			CALL log003_err_sql('LISTAR','CTB_LANC_CTBL_CTB.VAL_LANCTO')
				RETURN FALSE
	 		END IF 
 			IF  p_razao.ies_tip_lanc = "C" THEN															#AQUI ELE VERIFICO SE A CONTA  É DEBIDO 
				DECLARE cq_contra CURSOR FOR SELECT CTA_DEB										#OU CREDITO PARA PODER ACHAR A CONTRA
																		FROM CTB_LANC_CTBL_CTB						#PARTIDA
																		WHERE EMPRESA   		= p_cod_empresa
																		AND SISTEMA_GERADOR =	p_razao.den_sistema_ger
																		AND PERIODO_CONTAB  =	p_razao.per_contabil
																		AND SEGMTO_PERIODO  =	p_razao.cod_seg_periodo
																		AND LOTE_CONTAB	   	=	p_razao.num_lote
																		AND NUM_RELACIONTO 	= p_razao.num_relacionto
																		AND VAL_LANCTO  		= p_razao.val_lancto
																		AND CTA_DEB 				<> p_razao.num_conta
																		AND CTA_DEB					<> 0
				
				IF SQLCA.SQLCODE<>0 THEN 	
	 				CALL log003_err_sql('LISTAR','CTB_LANC_CTBL_CTB.CTA_DEB')
					RETURN FALSE
 				END IF
 				FOREACH cq_contra INTO p_razao.num_conta_cpartida	
 					EXIT FOREACH
 				END FOREACH
 			ELSE
 				DECLARE cq_contra1 CURSOR FOR SELECT CTA_CRE
																				FROM CTB_LANC_CTBL_CTB
																				WHERE EMPRESA   		= p_cod_empresa
																				AND SISTEMA_GERADOR =	p_razao.den_sistema_ger
																				AND PERIODO_CONTAB  =	p_razao.per_contabil
																				AND SEGMTO_PERIODO  =	p_razao.cod_seg_periodo
																				AND LOTE_CONTAB	   	=	p_razao.num_lote
																				AND NUM_RELACIONTO 	= p_razao.num_relacionto
																				AND VAL_LANCTO  		= p_razao.val_lancto
																				AND CTA_CRE 				<> p_razao.num_conta
																				AND CTA_CRE					<> 0
				
				IF SQLCA.SQLCODE<>0 THEN 	
	 				CALL log003_err_sql('LISTAR','CTB_LANC_CTBL_CTB.CTA_CRE')
					RETURN FALSE
 				END IF
 				FOREACH cq_contra1 INTO p_razao.num_conta_cpartida	
 					EXIT FOREACH
 				END FOREACH
 			END IF 
 			MESSAGE "Processando",p_razao.num_conta
 			LET p_cont = p_cont + 1
 			
 			INSERT INTO T_ORD_C_PARTIDA VALUES (l_cont,	p_razao.cod_seg_periodo,p_razao.ies_tip_lanc, p_razao.num_lanc,
																						p_razao.num_relacionto,p_razao.num_conta_cpartida,p_razao.num_conta,
																						p_razao.val_lancto)
 			IF SQLCA.SQLCODE<>0 THEN 																# Esse insert foi feito para que possa inserir dadods
 				CALL log003_err_sql('INSERIR','T_ORD_C_PARTIDA')			# numa tabela e que atraves dessa tabela eu possa
				RETURN FALSE																					# ordenar os dados por contrapartida
			END IF
 			LET l_cont= l_cont+1																													
 		END FOREACH																																		
	END FOREACH
	IF p_cont = 0 THEN 
		CALL log0030_mensagem('Pesquisa não rotornou nenhum valor','info')
		RETURN FALSE
	END IF 
	RETURN TRUE 
END FUNCTION
#-----------------------------#
 REPORT pol0951_relat(l_conta)#
#-----------------------------#
	
   DEFINE l_conta LIKE	lancamentos.num_conta,
   				l_lanc	CHAR(01)											
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   FORMAT
          
      PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------

				 PRINT COLUMN 001, "POL0951"
         PRINT COLUMN 001,p_cod_empresa,' - ',p_den_empresa
         PRINT COLUMN 001,'PERIODO ',p_den_mes, ' DE ',p_razao.per_contabil,
               COLUMN 020, p_entrada.dat_movto_ini USING "DD/MM/YY",' A ', p_entrada.dat_movto_fim USING "DD/MM/YY",
               COLUMN 95,"EXTRAIDO EM DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
               
         PRINT 
         			 COLUMN 001,'GERENCIA DE INFORMATICA',
          		 COLUMN 125,"PAG: ", PAGENO USING "#&"
			
         PRINT COLUMN 50,'F I C H A     D O     R A Z A O' 
         PRINT 
         PRINT COLUMN 001, "I",
         			 COLUMN 007,"TITULO",
         			 COLUMN 035, "I",
         			 COLUMN 040,"L.C",
         			 COLUMN 045, "I",
         			 COLUMN 047,"DOCUM",
         			 COLUMN 055, "I",
         			 COLUMN 057,"C.PARTIDA",
         			 COLUMN 071, "I",
         			 COLUMN 073,"DEBITO",
         			 COLUMN 084, "I",
         			 COLUMN 086,"CREDITO",
         			 COLUMN 100, "I",
         			 COLUMN 102,"SALDO",
         			 COLUMN 118, "I",
         			 COLUMN 120,"CONTA",
         			 COLUMN 131, "I"
         PRINT
         
      ON EVERY ROW		
							IF p_razao.ies_tip_lanc = "D" THEN 
								 PRINT COLUMN 001, "I",
		         			 COLUMN 035, "I",
		         			 COLUMN 040,p_razao.num_lanc USING '######&',
         			 		 COLUMN 045, "I",
		         			 COLUMN 047,"CL",p_razao.num_relacionto USING '&&&',p_razao.cod_seg_periodo USING '&&',
		         			 COLUMN 055, "I",
		         			 COLUMN 057,p_razao.num_conta_cpartida,
		         			 COLUMN 071, "I",
		         			 COLUMN 073,p_razao.val_lancto USING '##,###,##&.&&',
		         			 COLUMN 084, "I",
		         			 COLUMN 100, "I",
		         			 COLUMN 118, "I",
		         			 COLUMN 131, "I"
							ELSE
								 PRINT COLUMN 001, "I",
		         			 COLUMN 035, "I",
		         			 COLUMN 040,p_razao.num_lanc USING '######&',
         			 		 COLUMN 045, "I",
		         			 COLUMN 047,"CL",p_razao.num_relacionto USING '&&&',p_razao.cod_seg_periodo USING '&&',
		         			 COLUMN 055, "I",
		         			 COLUMN 057,p_razao.num_conta_cpartida,
		         			 COLUMN 071, "I",
		         			 COLUMN 084, "I",
		         			 COLUMN 086,p_razao.val_lancto USING '##,###,##&.&&',
		         			 COLUMN 100, "I",
		         			 COLUMN 118, "I",
		         			 COLUMN 131, "I"
							END IF       			
      			BEFORE GROUP OF l_conta
	      			IF p_saldo_ant >=0 THEN
								LET l_lanc = 'C'
							ELSE
								LET l_lanc = 'D'
							END IF 
		      		PRINT COLUMN 001, "I",
			         			 	COLUMN 003, p_den_conta[1,30],
			         			  COLUMN 035, "I",
         			 			  COLUMN 045, "I",
			         			  COLUMN 055, "I",
			         			  COLUMN 071, "I",
			         			  COLUMN 084, "I",
			         			  COLUMN 100, "I",
			         			  COLUMN 102, p_saldo_ant USING '####,###,##&.&&', 
			         			  COLUMN 117,l_lanc,
		         			  	COLUMN 118, "I",
			         			  COLUMN 120,p_razao.num_conta,
			         			  COLUMN 131, "I"
      			AFTER GROUP OF l_conta
      				IF p_saldo >=0 THEN
								LET l_lanc = 'C'
							ELSE
								LET l_lanc = 'D'
							END IF 
	      			PRINT COLUMN 001, "I",
		         			  COLUMN 035, "I",
         			 		 	COLUMN 045, "I",
		         			  COLUMN 055, "I",
		         			  COLUMN 071, "I",
		         			  COLUMN 084, "I",
		         			  COLUMN 100, "I",
		         			  COLUMN 102, p_saldo USING '#,###,###,##&.&&', 
		         			  COLUMN 117,l_lanc,
		         			  COLUMN 118, "I",
		         			  COLUMN 131, "I"
	      			
	      				PRINT COLUMN 001, "I",
			         			  COLUMN 035, "I",
			         			  COLUMN 045, "I",
			         			  COLUMN 055, "I",
			         			  COLUMN 071, "I",
			         			  COLUMN 084, "I",
			         			  COLUMN 100, "I",
			         			  COLUMN 118, "I",
			         			  COLUMN 131, "I"
      	ON LAST ROW
      		PRINT 
      		PRINT COLUMN 050,"****Ultima Pagina****"		                    
END REPORT



