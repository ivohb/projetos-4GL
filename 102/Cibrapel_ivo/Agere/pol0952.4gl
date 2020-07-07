#-----------------------------------------------------------#
# SISTEMA.: RELATORIO DE RAZAO															#
#	PROGRAMA:	pol0952																					#
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
		    p_num_cgc							LIKE empresa.num_cgc,	
				p_status        			SMALLINT,        
				g_ies_ambiente char(01),
				p_ies_impressao char(01),
				p_versao        			CHAR(18),
				comando         			CHAR(80),
				p_caminho							CHAR(30),
			  p_nom_arquivo					CHAR(100),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont								SMALLINT,
				p_nom_help      			CHAR(200),
				p_den_mes							CHAR(08),
				p_saldo								LIKE saldos.val_saldo_acum,
				p_den_conta						LIKE plano_contas.den_conta,
				p_num_conta_reduz			LIKE	plano_contas.num_conta_reduz,
				p_texto								CHAR(300),
				p_msg                 CHAR(100)
				
END GLOBALS

DEFINE p_entrada RECORD 
				dat_movto_ini			DATE,				
				dat_movto_fim			DATE,				
				num_conta_ini			LIKE plano_contas.num_conta,
				num_conta_fim			LIKE plano_contas.num_conta
END RECORD 
DEFINE p_diario RECORD
				den_sistema_ger				LIKE	lancamentos.den_sistema_ger, 
				per_contabil					LIKE	lancamentos.per_contabil,	
				cod_seg_periodo				LIKE	lancamentos.cod_seg_periodo,
				num_lote							LIKE	lancamentos.num_lote,
				dat_movto							LIKE	lancamentos.dat_movto, 
				ies_tip_lanc					LIKE	lancamentos.ies_tip_lanc, 
				num_conta							LIKE	lancamentos.num_conta,
				num_lanc							LIKE	lancamentos.num_lanc, 
				num_relacionto				LIKE	lanctos_compl.num_relacionto,
				val_lanc							LIKE  ctb_lanc_ctbl_ctb.val_lancto
END RECORD 

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0952-10.02.00"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0952.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("ESPEC999","")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
	  CALL pol0952_controle()
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol0952_controle()#
#---------------------------#
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0952") RETURNING comando
	OPEN WINDOW w_pol0952 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	LET p_retorno = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0952_entrada_dados() RETURNING p_retorno
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
								START REPORT pol0952_relat TO PIPE p_nom_arquivo
							ELSE
								CALL log150_procura_caminho ('LST') RETURNING p_caminho
								LET p_caminho = p_caminho CLIPPED, 'pol0903.tmp'
								START REPORT pol0952_relat  TO p_caminho
							END IF
						ELSE
							START REPORT pol0952_relat TO p_nom_arquivo
						END IF
						IF NOT  pol0952_listar() THEN
							LET p_retorno = FALSE 
							ERROR "Erro ao processar dados "
						END IF   
						FINISH REPORT pol0952_relat 
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
		COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0952_sobre()
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0952
END FUNCTION

#--------------------------------#
FUNCTION  pol0952_entrada_dados()#
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
 				ERROR"Campo de Prenchimento Obrigat�rio!"
 				NEXT FIELD dat_movto_ini
 			END IF 
 		AFTER FIELD dat_movto_fim
			IF p_entrada.dat_movto_fim IS NULL THEN
 				ERROR"Campo de Prenchimento Obrigat�rio!"
 				NEXT FIELD dat_movto_fim
 			ELSE 
 				IF p_entrada.dat_movto_fim < p_entrada.dat_movto_ini THEN
 					ERROR"Data Final n�o pode ser menor que a data inicial"
 					NEXT FIELD dat_movto_fim
 				ELSE
 					IF NOT  pol0952_valida_data() THEN 
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
 				ERROR"Campo de Preenchimento Obraigat�rio"
 				NEXT FIELD num_conta_fim
 			ELSE  
 				IF NOT pol0952_verifica_conta(p_entrada.num_conta_fim) THEN 
 					ERROR"Conta invalida digite o numero da conta novamente" 
 					NEXT FIELD num_conta_fim
 				END IF 
 			END IF
 		ON KEY (control-z)
    	CALL pol0952_popup()  
 	END INPUT
 	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
#--------------------------#
FUNCTION  pol0952_den_mes()#														#VERIFICANDO O MES E INSERINDO A DENOMINA�AO
#--------------------------#														#PARA EXIBIR EM TELA DE POSTERIORMENTE NO RELATORIO
DEFINE 	l_mes			INTEGER
	LET l_mes = MONTH(p_diario.cod_seg_periodo)
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
#------------------------------#
FUNCTION  pol0952_valida_data()#
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
#------------------------#
FUNCTION  pol0952_popup()#
#------------------------#
DEFINE p_codigo CHAR(25)
	IF  INFIELD(num_conta_ini) OR INFIELD(num_conta_fim) THEN 
		CALL log009_popup(8,10,"CONTAS","plano_contas",
		"num_conta","den_conta","","S","") 
		RETURNING p_codigo
		CALL log006_exibe_teclas("01 02 07", p_versao)
		CURRENT WINDOW IS w_pol0952
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
#-------------------------------------#
FUNCTION pol0952_verifica_conta(l_num)#
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
#-------------------------------------#
FUNCTION pol0952_pega_texto(l_num_rel)#
#-------------------------------------#
DEFINE 	l_num_rel				INTEGER,
				l_seq						SMALLINT,
				l_texto					CHAR(50),
				l_texto1				CHAR(300)
	LET l_texto1 = ''
	DECLARE cq_texto  CURSOR FOR 	SELECT UNIQUE NUM_SEQ_LINHA, TEX_HIST
																FROM HIST_COMPL, CTB_LANC_CTBL_CTB
																WHERE HIST_COMPL.COD_EMPRESA		=	p_cod_empresa
																AND HIST_COMPL.DEN_SISTEMA_GER	=	p_diario.den_sistema_ger
																AND HIST_COMPL.PER_CONTABIL			=	p_diario.per_contabil
																AND HIST_COMPL.COD_SEG_PERIODO	=	p_diario.cod_seg_periodo
																AND HIST_COMPL.NUM_LOTE					=	p_diario.num_lote
																AND NUM_RELACIONTO 							= l_num_rel
																AND EMPRESA =HIST_COMPL.COD_EMPRESA
																AND SISTEMA_GERADOR = HIST_COMPL.DEN_SISTEMA_GER
																AND PERIODO_CONTAB =HIST_COMPL.PER_CONTABIL
																AND SEGMTO_PERIODO =HIST_COMPL.COD_SEG_PERIODO
																AND LOTE_CONTAB =HIST_COMPL.NUM_LOTE
																AND NUM_LANCTO=HIST_COMPL.NUM_LANC
																ORDER BY HIST_COMPL.NUM_SEQ_LINHA
	FOREACH cq_texto INTO l_seq, l_texto
		LET l_texto1 = l_texto1 CLIPPED,' ',l_texto CLIPPED
	END FOREACH
	RETURN  l_texto1												
END FUNCTION

#-------------------------#
FUNCTION  pol0952_listar()#
#-------------------------#
DEFINE 	l_per_contabil				INTEGER,
				l_cod_seg_periodo			INTEGER,
				l_num_rel							INTEGER,
				l_cod_empresa_plano		CHAR(02),
				l_sql									CHAR(100),
				sql_stmt        			CHAR(999)
DEFINE p_txt  ARRAY[5] OF RECORD
          txt    CHAR(60)
   END RECORD
																										#essa variavel vai identificar qdo for o ultimo numero
	LET l_num_rel = 0		 															#de relacionamento para buscar o texto
	
	LET p_cont = 0
	
	SELECT DEN_EMPRESA, NUM_CGC 											#BUSCA NOME E CGC DA EMPRESA CORRENTE
	INTO p_den_empresa,
			 p_num_cgc
	FROM EMPRESA 
	WHERE COD_EMPRESA = p_cod_empresa
	
	LET l_sql = ' '
	IF p_entrada.num_conta_ini THEN 
		LET l_sql=" AND A.NUM_CONTA 	BETWEEN '" ,p_entrada.num_conta_ini,"' AND '",p_entrada.num_conta_fim,"' "
	END IF 
	
	LET sql_stmt = 	"SELECT UNIQUE A.DEN_SISTEMA_GER, A.PER_CONTABIL,	A.COD_SEG_PERIODO,A.NUM_LOTE, ",
									"A.DAT_MOVTO, A.IES_TIP_LANC, A.NUM_CONTA,A.NUM_LANC, A.VAL_LANC, B.NUM_RELACIONTO,C.NUM_CONTA_REDUZ ",
									"FROM LANCAMENTOS A ,CTB_LANC_CTBL_CTB B, PLANO_CONTAS C ",
									"WHERE A.COD_EMPRESA = '",p_cod_empresa,"' ",
									"AND A.DAT_MOVTO BETWEEN '",p_entrada.dat_movto_ini,"' AND '",p_entrada.dat_movto_fim,"' ",
									l_sql CLIPPED,																					#variavel verifica se tem ou nao um peiodo de conta
									" AND EMPRESA = A.COD_EMPRESA ",										#se tiver digitado uma conta ele insere um filtro
									"AND SISTEMA_GERADOR = DEN_SISTEMA_GER ",							#no sql sen�o fica nulo
									"AND PERIODO_CONTAB  = PER_CONTABIL ",
									"AND SEGMTO_PERIODO  = COD_SEG_PERIODO ",
									"AND LOTE_CONTAB = NUM_LOTE ",
									"AND NUM_LANCTO = NUM_LANC ",
									"AND  A.COD_EMPRESA = C.COD_EMPRESA ",
									"AND A.NUM_CONTA= C.NUM_CONTA ",
									"ORDER BY DAT_MOVTO, NUM_RELACIONTO , A.NUM_CONTA "
	PREPARE var_queri FROM sql_stmt  
	DECLARE cq_conta SCROLL CURSOR WITH HOLD FOR var_queri
																								
	IF SQLCA.SQLCODE<>0 THEN 
		CALL log003_err_sql('LISTAR','LANCAMENTOS')
		RETURN FALSE
	END IF																				
	FOREACH cq_conta INTO p_diario.den_sistema_ger, 
												p_diario.per_contabil,	
												p_diario.cod_seg_periodo,
												p_diario.num_lote,							
												p_diario.dat_movto, 
												p_diario.ies_tip_lanc, 
												p_diario.num_conta,
												p_diario.num_lanc,
												p_diario.val_lanc, 
												p_diario.num_relacionto,
												p_num_conta_reduz 
																								
									
		SELECT cod_empresa_plano											#Verifica se a a empresa tem um parametro de empresa 
		INTO l_cod_empresa_plano 											#para conta cadastrado, se tiver o prog pega o numero 
		FROM par_con																	#da empresa cadastrado ele vai fazer o filtro pelo 
 		WHERE cod_empresa = p_cod_empresa							#numero da conta cadastrado sen�o ele vai o filtro
 		IF l_cod_empresa_plano IS NOT NULL THEN 			#pela empresa logada
 		
 			SELECT DEN_CONTA  
			INTO p_den_conta
			FROM PLANO_CONTAS
			WHERE COD_EMPRESA =	l_cod_empresa_plano
			AND NUM_CONTA 		=	p_diario.num_conta
 		ELSE
			SELECT DEN_CONTA 
			INTO p_den_conta
			FROM PLANO_CONTAS
			WHERE COD_EMPRESA =	p_cod_empresa
			AND NUM_CONTA 		=	p_diario.num_conta
 		END IF 
 		IF SQLCA.SQLCODE<>0 THEN 	
 			CALL log003_err_sql('LISTAR','PLANO_CONTAS')
			RETURN FALSE
 		END IF 
 		IF l_num_rel = 0 THEN
 			LET l_num_rel = p_diario.num_relacionto
 		ELSE 
 			IF p_diario.num_relacionto <> l_num_rel THEN 
 				LET p_texto= pol0952_pega_texto(l_num_rel)
 				LET l_num_rel = p_diario.num_relacionto
 			END IF  
 		END IF 
 		LET p_cont = p_cont + 1
 		CALL pol0952_den_mes()
 		CALL pol0952_relat(p_diario.num_relacionto)
	END FOREACH
	IF p_cont = 0 THEN 
		CALL log0030_mensagem('Pesquisa n�o rotornou nenhum valor','info')
		RETURN FALSE
	END IF
	RETURN TRUE 
END FUNCTION
#-----------------------------#
 REPORT pol0952_relat(l_conta)#
#-----------------------------#
	
   DEFINE l_conta 	LIKE	lanctos_compl.num_relacionto,
   				l_num_seq SMALLINT,
   				l_div							INTEGER												
   
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   FORMAT
          
      PAGE HEADER  								#----------CABE�ALHO DO RELATORIO-------------
				 PRINT COLUMN 001, "POL0952"
         PRINT COLUMN 001,p_cod_empresa ,' - ',p_den_empresa
         PRINT COLUMN 001,'PERIODO ',p_den_mes, ' DE ',p_razao.per_contabil,
               COLUMN 020, p_entrada.dat_movto_ini USING "DD/MM/YY",' A ', p_entrada.dat_movto_fim USING "DD/MM/YY",
               COLUMN 85,"EXTRAIDO EM DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME
         PRINT COLUMN 001,'CNPJ ',p_num_cgc,
         			 COLUMN 050,'D I A R I O   G E R A L ',
          		 COLUMN 115,"PAG: ", PAGENO USING "#&"
				 PRINT 
				 PRINT #COLUMN 001, "|",
         			 COLUMN 003,'N.CONTROLE ' ,
          		 #COLUMN 025, "|",
         			 COLUMN 060,"HISTORICO",
         			 #COLUMN 141, "|",
         			 #COLUMN 060,"DETALHE",
         			 #COLUMN 173, "|",
         			 COLUMN 095,"DEBITO",
         			 #COLUMN 205, "|",
         			 COLUMN 115,"CREDITO"
         			 #COLUMN 238, "|"
         PRINT
         
      ON EVERY ROW	
      	IF p_diario.ies_tip_lanc = "D" THEN 
      		PRINT COLUMN 003, p_diario.num_lanc,
      					COLUMN 025, p_num_conta_reduz,' - ', p_den_conta[1,35],
      					COLUMN 086, p_diario.val_lanc USING '###,###,###,##&.&&'
      	ELSE 
      		PRINT COLUMN 003, p_diario.num_lanc,
      					COLUMN 025, p_num_conta_reduz,' - ', p_den_conta[1,35],
      					COLUMN 105, p_diario.val_lanc USING '###,###,###,##&.&&'
      	END IF 
      	
      	BEFORE GROUP OF l_conta
      	
					PRINT COLUMN 030,p_diario.dat_movto USING 'dd',' DE ', p_den_mes, p_diario.per_contabil CLIPPED,
												' - CL ',p_diario.num_relacionto USING '&&&' ,'/',p_diario.cod_seg_periodo USING '&&'
					PRINT 
      			
      	AFTER GROUP OF l_conta
      				PRINT 																								#somarizando as contas debito e contas credito
      				PRINT COLUMN 060,"TOTAL",
      							COLUMN 86,GROUP  SUM(p_diario.val_lanc) WHERE p_diario.ies_tip_lanc = "D" USING '###,###,###,##&.&&',
      							COLUMN 105,GROUP  SUM(p_diario.val_lanc) WHERE p_diario.ies_tip_lanc = "C" USING '###,###,###,##&.&&'
      							
      				PRINT 
							
							IF LENGTH(p_texto)>60  THEN
								IF LENGTH(p_texto) MOD 60 = 0 THEN 			
									LET l_div = LENGTH(p_texto)/50				
								ELSE																			
									LET l_div = (LENGTH(p_texto)/60) + 1
								END IF 
              	
	              FOR l_num_seq = 1 TO l_div
	              	IF l_num_seq = 1 THEN 
	              		PRINT COLUMN 025,p_texto[1,60]
	              	ELSE 
	              		PRINT COLUMN 025,p_texto[(((l_num_seq - 1)* 60)+1),(l_num_seq * 60)]
	              	END IF 
	              END FOR   
							PRINT
							ELSE
								PRINT COLUMN 025,p_texto[1,60]
								PRINT
							END IF 
							PRINT COLUMN 002,"=================================================================================",
										COLUMN 083,"========================================="
							PRINT 
	      			
      	ON LAST ROW
      		PRINT COLUMN 060,"TOTAL GERAL",
      					COLUMN 086,SUM(p_diario.val_lanc) WHERE p_diario.ies_tip_lanc = "D" USING '###,###,###,##&.&&',
      	 				COLUMN 105,SUM(p_diario.val_lanc) WHERE p_diario.ies_tip_lanc = "C" USING '###,###,###,##&.&&'
      							
      		PRINT 
      		PRINT COLUMN 050,"****Ultima Pagina****"		                    
END REPORT

#-----------------------#
 FUNCTION pol0952_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION