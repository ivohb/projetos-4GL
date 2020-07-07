#-------------------------------------------------------------------#
# SISTEMA.: CONTABILIDADE                                           #
# PROGRAMA: pol0946		                                              #
# OBJETIVO: carga de histórico de lançamentos contábeis							#
#						 																												#
# CLIENTE.:	codesp                                             			#
# DATA....: 18/06/2009                                              #
# POR.....: THIAGO				                                          #
#-------------------------------------------------------------------#
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
				p_caminho							CHAR(100),
				p_ies_impressao				CHAR(1),
				p_nom_arquivo					CHAR(100),
				p_nom_tela 						CHAR(200),
				p_retorno							SMALLINT,
				p_ies_cons      			SMALLINT,
				p_nom_help      			CHAR(200),
				p_cont								SMALLINT
END GLOBALS 
DEFINE p_entrada RECORD
			#	cod_emp			     	CHAR(02),
				cod_sistema				CHAR(03),
				lote							DECIMAL(3,0)
END RECORD 
DEFINE p_compl_hist RECORD 
				cod_empresa      CHAR(02),
				num_lote         DECIMAL(3,0),
				cod_sistema      CHAR(3),
				dat_refer        DATE,
				num_relacionto   DECIMAL(5,0),
				texto_hist       CHAR(250)
END RECORD 

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0946-10.02.02"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0946.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		IF pol0946_cria_tabelas() THEN 
	  	CALL pol0946_controle()
	  END IF 
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol0946_controle()#
#---------------------------#
DEFINE p_processa SMALLINT 
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0946") RETURNING comando
	OPEN WINDOW w_pol0946 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	LET p_processa = FALSE 
	LET p_retorno = FALSE 
	LET p_resposta = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0946_entrada_parametro() RETURNING p_retorno
				NEXT OPTION "Carregar"
			END IF
		COMMAND "Carregar"   "Carregar arquivo de dados"
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				 IF p_retorno THEN
				 		MESSAGE "Carregando arquivo..."
					 	IF pol0946_carrega_arquivo() THEN
					 	 MESSAGE "Arquivo carregado com sucesso"
					 	 LET p_resposta = TRUE 
					 	 LET p_retorno = FALSE 
					 	 NEXT OPTION "Processar"
					 	ELSE
					 		ERROR "Erro ao carregar dados"
					 		LET p_retorno = FALSE 
					 		NEXT OPTION "Informar" 
					 	END IF 
				 ELSE
				 	ERROR "Favor informar parametros"
				 	LET p_retorno = FALSE 
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		COMMAND "Processar"  "Processar dados"
			HELP 1053
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				IF p_resposta THEN
						MESSAGE "Processando..."
						CALL log085_transacao('BEGIN') 
					 	IF pol0946_processar() THEN
					 	 MESSAGE "Arquivo processado com sucesso! Foram processados ",p_cont," registro"
					 	 CALL log085_transacao('COMMIT') 
					 	 LET p_resposta = FALSE
					 	 NEXT OPTION "Fim"
					 	ELSE
					 		ERROR "Erro ao Processar Dados"
					 		CALL log085_transacao('ROLLBACK') 
					 		LET p_resposta = FALSE 
					 		NEXT OPTION "Informar" 
					 	END IF 
				 ELSE
				 	ERROR "Arquivos não foram carregados!"
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0946
END FUNCTION 

#-----------------------------------#
FUNCTION pol0946_entrada_parametro()#								#ENTRADA DE PARAMETRO NO QUAL VAI SER USADO PRA CRIAR
#-----------------------------------#								#O NOME DO ARQUIVO A SER BUSCADO
	CALL log006_exibe_teclas("01 02 07",p_versao)
	CURRENT WINDOW IS w_pol0946
	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	INITIALIZE p_entrada.* TO NULL 
	INPUT BY NAME p_entrada.* WITHOUT DEFAULTS
		{AFTER  FIELD cod_emp
			IF p_entrada.cod_emp IS NULL THEN
				ERROR'CAMPO DE PREENCHIMENTO OBRIGATORIO!!!'
				NEXT FIELD cod_emp
			ELSE
				IF LENGTH(p_entrada.cod_emp) <> 2 THEN
					ERROR'CAMPO DE QUE CONTER 2 CARACTERES OBRIGATORIO!!!'
					NEXT FIELD cod_emp
				ELSE 
					NEXT FIELD cod_sistema
				END IF  
			END IF }
		AFTER  FIELD cod_sistema 
			IF p_entrada.cod_sistema IS NULL THEN 
				ERROR'CAMPO DE PREENCHIMENTO OBRIGATORIO!!!'
				NEXT FIELD cod_sistema
			ELSE
				IF LENGTH(p_entrada.cod_sistema) <> 3 THEN
					ERROR'CAMPO DE QUE CONTER 3 CARACTERES OBRIGATORIO!!!'
					NEXT FIELD cod_sistema
				ELSE 
					NEXT FIELD lote
				END IF 
			END IF 
		AFTER  FIELD lote
			IF p_entrada.lote IS NULL THEN 
				ERROR'CAMPO DE PREENCHIMENTO OBRIGATORIO!!!'
				NEXT FIELD lote
			END IF 
	END INPUT 
	IF INT_FLAG = 0 THEN
	  LET p_retorno = TRUE 
	ELSE
		INITIALIZE p_entrada TO NULL
	  CLEAR FORM
	  LET p_retorno = FALSE
	  LET INT_FLAG = 0
	END IF
	RETURN(p_retorno)
END FUNCTION

#-------------------------------#
FUNCTION  pol0946_cria_tabelas()#							#CRIA A TABELA A SER UTILIZADA PELO PROGRAMA
#-------------------------------#
WHENEVER ERROR CONTINUE 
	DROP TABLE t_ctb_compl_hist
	
		CREATE  TABLE t_ctb_compl_hist
		(
			cod_empresa      CHAR(02) NOT NULL,      	#NAO NULO --> CODIGO DA EMPRESA
			num_lote         DECIMAL(3,0) NOT NULL,  	#NAO NULO --> NUMERO DESTE LOTE
			cod_sistema      CHAR(3)NOT NULL,     		#NAO NULO --> COD. DO SISTEMA GERADOR DO LOTE
			dat_refer        DATE NOT NULL,          	#NAO NULO --> DATA DO PROCESSO (GERACAO DO ARQ.)     
			num_relacionto   DECIMAL(5,0) NOT NULL,   #NAO NULO --> NÚMERO DO LANÇAMENTO CONTÁBIL CODESP 
			texto_hist       CHAR(250)   
		) 
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("CREATE","t_ctb_compl_hist")
			CALL pol0946_imprime_erros(log0030_txt_err_sql("CREATE","T_CTB_COMPL_HIST"))
			RETURN FALSE
		END IF
		RETURN TRUE 
WHENEVER ERROR STOP   
END FUNCTION 
#-------------------------------#
FUNCTION pol0946_deleta_tabela()#
#-------------------------------#
	DELETE T_CTB_COMPL_HIST
	IF SQLCA.SQLCODE <> 0 THEN 
		CALL log003_err_sql("DELETE ","T_CTB_COMPL_HIST")
		CALL pol0946_imprime_erros(log0030_txt_err_sql("DELETE","T_CTB_COMPL_HIST"))
		RETURN FALSE 
	END IF 
	RETURN TRUE 
END FUNCTION
#---------------------------------#
FUNCTION pol0946_carrega_arquivo()#
#---------------------------------#
DEFINE 	l_lote CHAR(3),
				l_nome	CHAR(200)
				
	IF pol0946_valida_arquivo() THEN
		CALL pol0946_imprime_erros('ARQUIVO JÁ PROCESSADO!')
		CALL log0030_mensagem('Arquivo já processado','info')
		RETURN FALSE
	END IF
	
	IF NOT  pol0946_deleta_tabela() THEN
		RETURN FALSE 
	END IF 
	
	LET l_lote = p_entrada.lote							#se numero tiver apenas 1 ou dois digitos
	IF LENGTH(l_lote) <3 THEN								#ele vai completar com os zeros
		IF LENGTH(l_lote) = 2 THEN
			LET l_lote ='0',l_lote
		ELSE
			LET l_lote ='00',l_lote
		END IF 
	END IF  
	SELECT nom_caminho 
	INTO p_caminho
	FROM path_logix_v2																	#localizando caminho onde vai procurar o arquivo
	WHERE cod_empresa = p_cod_empresa 
	AND cod_sistema = "UNL"
	WHENEVER ERROR CONTINUE 
		LET l_nome = p_caminho CLIPPED, p_cod_empresa CLIPPED ,p_entrada.cod_sistema CLIPPED,l_lote,".HIS"
		LOAD FROM l_nome INSERT INTO t_ctb_compl_hist
	WHENEVER ERROR STOP 
	
	IF STATUS = -805 THEN	
		LET l_nome =log0030_txt_err_sql("LOAD","T_CTB_COMPL_HIST"),' Arquivo:',l_nome CLIPPED,'Arquivo não encontrado!' 																						#fazendo o load do aquivo de fornecedores
		CALL log0030_mensagem(l_nome,"excla")				#carregando a tabela temporaria de fornecedores
		CALL pol0946_imprime_erros(l_nome)						#verificando possiveis erros duranto o load
		RETURN FALSE																									
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","t_nf_fornecedor")
			CALL pol0946_imprime_erros(log0030_txt_err_sql("LOAD","T_CTB_COMPL_HIST"))
			RETURN FALSE
		END IF
	END IF
	RETURN TRUE 
END FUNCTION
#--------------------------------#
FUNCTION pol0946_valida_arquivo()#			#validar se o arquivo ja foi processado
#--------------------------------#
DEFINE l_cont SMALLINT

	SELECT COUNT(*)
	INTO l_cont 
	FROM CTB_COMPL_HIST_CODESP
	WHERE cod_empresa = p_cod_empresa
	AND num_lote = p_entrada.lote
	AND cod_sistema = p_entrada.cod_sistema 
	IF l_cont > 0 THEN 
		RETURN TRUE
	ELSE
		RETURN FALSE
	END IF
END FUNCTION 
#---------------------------#
FUNCTION pol0946_processar()#
#---------------------------#
DEFINE 	l_cont 						SMALLINT,
				l_div							INTEGER,
				#l_soma						SMALLINT,
				l_empresa						LIKE CTB_LANC_CTBL_CTB.empresa,
				l_sistema_gerador		LIKE CTB_LANC_CTBL_CTB.sistema_gerador,
				l_periodo_contab		LIKE CTB_LANC_CTBL_CTB.periodo_contab,
				l_segmto_periodo		LIKE CTB_LANC_CTBL_CTB.segmto_periodo, 
				l_lote_controle			LIKE CTB_LANC_CTBL_CTB.lote_controle,
				l_seq_lote_controle	LIKE CTB_LANC_CTBL_CTB.seq_lote_controle
	
	LET p_cont = 0
	DECLARE cq_compl_hist SCROLL CURSOR WITH  HOLD FOR  SELECT * FROM t_ctb_compl_hist
	FOREACH cq_compl_hist INTO p_compl_hist.*
		LET l_cont = 0
		
		DECLARE Cq_Ctb_Lanc SCROLL CURSOR WITH  HOLD FOR 	SELECT UNIQUE	empresa,sistema_gerador,periodo_contab,
																																segmto_periodo, lote_controle,seq_lote_controle
																												FROM CTB_LANC_CTBL_CTB 
																												WHERE empresa = p_cod_empresa
																												AND sistema_gerador = p_compl_hist.cod_sistema
																												AND lote_controle = p_compl_hist.num_lote
																												AND dat_movto = p_compl_hist.dat_refer
																												AND num_relacionto	 = p_compl_hist.num_relacionto
		IF SQLCA.SQLCODE = 0 THEN 																										
			FOREACH cq_ctb_lanc	 INTO l_empresa,
																l_sistema_gerador,
																l_periodo_contab,
																l_segmto_periodo,
																l_lote_controle,
																l_seq_lote_controle
				
				IF LENGTH(p_compl_hist.texto_hist) > 50 THEN 							#Se o texto ter mais de 50 caracteres
					IF LENGTH(p_compl_hist.texto_hist) MOD 50 = 0 THEN 			#ele vai quebrar o texto em partes de 50
						LET l_div = LENGTH(p_compl_hist.texto_hist)/50				# vai fazer um for de um ao valor de
					ELSE																										#quantidade de vezes que ele quebra o texto
						LET l_div = (LENGTH(p_compl_hist.texto_hist)/50) + 1
					END IF 
					FOR l_cont =1 TO l_div 
						IF l_cont = 1 THEN 
							INSERT INTO CTB_COMPL_HIST VALUES (l_empresa,	l_sistema_gerador,l_periodo_contab,
																	l_segmto_periodo,	l_lote_controle, l_seq_lote_controle,1,p_compl_hist.texto_hist[1,50])
							IF SQLCA.SQLCODE <> 0 THEN 
								CALL log003_err_sql('INSERT','CTB_COMPL_HIST VALUES')
								CALL pol0946_imprime_erros(log0030_txt_err_sql('INSERT','CTB_COMPL_HIST VALUES'))
								RETURN FALSE
							END IF 
						ELSE
							#LET l_soma = l_cont + 1
							INSERT INTO CTB_COMPL_HIST VALUES (l_empresa,	l_sistema_gerador,l_periodo_contab,
																	l_segmto_periodo,	l_lote_controle, l_seq_lote_controle,l_cont,p_compl_hist.texto_hist[(((l_cont-1)*50)+1),(l_cont*50)])
							IF SQLCA.SQLCODE <> 0 THEN 
								CALL log003_err_sql('INSERT','CTB_COMPL_HIST')
								CALL pol0946_imprime_erros(log0030_txt_err_sql('INSERT','CTB_COMPL_HIST'))
								RETURN FALSE
							END IF 
						END IF 
					END FOR 
				ELSE
					INSERT INTO CTB_COMPL_HIST VALUES (l_empresa,	l_sistema_gerador,l_periodo_contab,
																l_segmto_periodo,	l_lote_controle, l_seq_lote_controle,1,p_compl_hist.texto_hist)
					IF SQLCA.SQLCODE <> 0 THEN 
						CALL log003_err_sql('INSERT','CTB_COMPL_HIST')
						CALL pol0946_imprime_erros(log0030_txt_err_sql('INSERT','CTB_COMPL_HIST'))
						RETURN FALSE
					END IF 
				END IF 
				LET p_cont = p_cont + 1
			END FOREACH	
		ELSE
			CONTINUE FOREACH
		END IF 
	END FOREACH
	INSERT INTO CTB_COMPL_HIST_CODESP VALUES(p_cod_empresa,p_entrada.lote,p_entrada.cod_sistema,CURRENT)
	IF SQLCA.SQLCODE <> 0 THEN 
		CALL log003_err_sql('INSERT','CTB_COMPL_HIST_CODESP')
		CALL pol0946_imprime_erros(log0030_txt_err_sql('INSERT','CTB_COMPL_HIST_CODESP'))
		RETURN FALSE
	END IF 
	RETURN TRUE 
END FUNCTION
#-------------------------------------#
FUNCTION pol0946_imprime_erros(p_erro)#			#prepara para imprimir erro
#-------------------------------------#
DEFINE p_erro			CHAR(250)
	
	LET p_erro = p_erro 
	 
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
	CALL log150_procura_caminho ('LST') RETURNING p_caminho
	LET p_caminho = p_caminho CLIPPED, 'pol0946.lst'
	LET p_nom_arquivo = p_caminho
	START REPORT pol0946_imprime TO p_nom_arquivo
	
	OUTPUT TO REPORT pol0946_imprime(p_erro)
	FINISH REPORT pol0946_imprime 
	MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
END FUNCTION 
#-----------------------------#
REPORT pol0946_imprime(p_erro)#			#vai imprimir os erros apresentados no programa
#-----------------------------#
DEFINE p_erro			CHAR(250)

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  66

   FORMAT
      PAGE HEADER
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&"

         PRINT COLUMN 001, "pol0946  CARGA DE HISTÓRICO DE LANÇAMENTOS CONTÁBEIS",
               COLUMN 056, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRIÇÃO DO ERRO"
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"

      ON EVERY ROW
         PRINT COLUMN 001, p_erro CLIPPED
END REPORT
