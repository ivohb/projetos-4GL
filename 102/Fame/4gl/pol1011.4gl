#-------------------------------------------------------------------------#
# SISTEMA.: Relaçao de notas fiscais consumidor		                	  #
#	PROGRAMA:	pol1011													  #
#	CLIENTE.:	Fame													  #
#	OBJETIVO:	Relação de cupoms fiscais importada						  #
#	AUTOR...:	THIAGO													  #
#	DATA....:	11/05/2009												  #
#-------------------------------------------------------------------------#

#Programa foi feito com funções independentes e variaveis locais pra facilitar 
#a compreenção para futuras mudanças e manutençoes.

DATABASE logix
GLOBALS
   DEFINE 
				p_cod_empresa   			LIKE empresa.cod_empresa,
				p_den_empresa				LIKE empresa.den_empresa,
				p_user          			LIKE usuario.nom_usuario,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				p_resposta					SMALLINT,
				comando         			CHAR(80),
				p_caminho					CHAR(30),
				p_nom_arquivo				CHAR(100),
				p_ies_impressao 			CHAR(001),
				g_ies_ambiente 		  		CHAR(001),
				p_nom_tela 					CHAR(200),
				p_retorno					SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont						SMALLINT,
				p_nom_help      			CHAR(200),
				p_natureza_operacao			INTEGER,
				p_entrada					DECIMAL(06),
				p_tipo						CHAR(03),
				p_houve_erro				SMALLINT,
				p_data						DATE,
				p_cupom_ini					DECIMAL(6,0),
				p_cupom_fim					DECIMAL(6,0),
				p_msg						CHAR(100), 
				p_incide_ipi				char(1),
				p_total						DECIMAL(10,2),
				p_num_nff					LIKE wfat_mestre_ser.num_nff,
				p_print						SMALLINT				#VARIAVEL FOI CRIADA PARA PODER SABER QUANDO EU ESTOU ABRINDO O
END GLOBALS 														#REPORT PARA CONTROLE DE ABRIR E FECHAR O REPORT 

DEFINE 	p_relacao RECORD 
				nr_fiscal				DECIMAL(6,0),
				qtd						  DECIMAL(9,3),
				#v_mercadoria		    DECIMAL(10,7),
				#v_ipi					DECIMAL(10,7),
				v_total					DECIMAL(17,7)
END RECORD

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol1011-10.02.07"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol1011.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("ESPEC999","")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		IF pol1011_cria_tabelas() THEN 
	  	CALL pol1011_controle()
	  END IF 
	END IF
END MAIN 			

#---------------------------#
FUNCTION  pol1011_controle()#
#---------------------------#
DEFINE p_processa SMALLINT 
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol1011") RETURNING comando
	OPEN WINDOW w_pol1011 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	LET p_processa = FALSE 
	LET p_retorno = FALSE 
	LET p_resposta = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol1011_entrada_parametro() RETURNING p_retorno
				NEXT OPTION "Processar"
			END IF
		
		COMMAND "Processar"  "Processar dados"
			HELP 1053
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				IF p_retorno THEN
				    IF log0280_saida_relat(13,29) IS NOT NULL THEN
						MESSAGE " Processando a Extracao do Relatorio..." 
						ATTRIBUTE(REVERSE)
						IF p_ies_impressao = "S" THEN
							IF g_ies_ambiente = "U" THEN
								START REPORT pol1011_relat TO PIPE p_nom_arquivo
							ELSE
							CALL log150_procura_caminho ('LST') RETURNING p_caminho
								LET p_caminho = p_caminho CLIPPED, 'pol1011.tmp'
								START REPORT pol1011_relat  TO p_caminho
							END IF
						ELSE
							START REPORT pol1011_relat TO p_nom_arquivo
						END IF
						CALL  pol1011_carrega_arquivo()
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
					IF p_cont > 0 THEN 
						IF log0040_confirm(18,35,"Deseja excluir os arquivos de cupons?") THEN
							CALL pol1011_deleta_arquivo()
						END IF
					ELSE
						ERROR"Não foram encontrados arquivos a serem listados!!!"
					END IF                                
					NEXT OPTION "Fim"				 	 
				ELSE
					ERROR "Arquivos não foram carregados!"
					NEXT OPTION "Informar"
				END IF
			END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1011_sobre() 			
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol1011
END FUNCTION 

#-----------------------#
FUNCTION pol1011_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION  pol1011_cria_tabelas()#
#-------------------------------#
	WHENEVER ERROR CONTINUE
		DROP TABLE t_entrada_cancel
		
		CREATE  TABLE t_entrada_cancel
		(
			registro			CHAR(215)
		)
		
	WHENEVER ERROR STOP 
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_entrada_cancel")
		RETURN FALSE
	END IF 
	
	WHENEVER ERROR CONTINUE
		DROP TABLE t_entrada_reg
		
		CREATE  TABLE t_entrada_reg
		(
			registro			CHAR(215)
		)
		
	WHENEVER ERROR STOP 
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_entrada_reg")
		RETURN FALSE
	ELSE
		RETURN TRUE 
	END IF 

END FUNCTION

#--------------------------------#
FUNCTION  pol1011_limpa_tabelas()#
#--------------------------------#

	WHENEVER ERROR CONTINUE
		DELETE FROM t_entrada_reg
	WHENEVER ERROR STOP
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_entrada_reg")
	END IF
END FUNCTION
#---------------------------------#
FUNCTION  pol1011_deleta_arquivo()#
#---------------------------------#
DEFINE l_cupom				INTEGER,
			 l_caminho			CHAR(500),			#--->vai receber o comando para deletar em linux
			 w_caminho			CHAR(500),
			 w_bol,l_bol		SMALLINT				#--->vai receber o retorno do comando

	FOR l_cupom = p_cupom_ini TO p_cupom_fim
		CALL log150_procura_caminho("UNL") RETURNING p_caminho
		LET l_caminho = p_caminho CLIPPED,"L0",l_cupom USING "&&&&&&",".002"
		LET l_caminho = "rm ", p_caminho CLIPPED,"L0",l_cupom USING "&&&&&&",".002"
		LET w_caminho = "del ", p_caminho CLIPPED,"L0",l_cupom USING "&&&&&&",".002"
		
		RUN l_caminho	 RETURNING l_bol
		RUN w_caminho	 RETURNING w_bol
	
	END FOR 

END FUNCTION 


#---------------------------------------#
FUNCTION  pol1011_limpa_tabelas_cancel()#
#---------------------------------------#
WHENEVER ERROR CONTINUE
		DELETE FROM t_entrada_cancel
	WHENEVER ERROR STOP
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_entrada_cancel")
	END IF
END FUNCTION

#------------------------------------#
FUNCTION  pol1011_entrada_parametro()#
#------------------------------------#
	INITIALIZE  p_cupom_ini,p_cupom_fim TO NULL
	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
		
	CALL pol1011_limpa_tabelas()
	CALL pol1011_limpa_tabelas_cancel()
	
	INPUT p_cupom_ini,p_cupom_fim WITHOUT DEFAULTS FROM cupom_ini, cupom_fim
		
		AFTER FIELD cupom_ini	
			IF p_cupom_ini IS NULL THEN 
				ERROR"Campo de preenchimento obrigatório!!!"
				NEXT FIELD cupom_ini
			ELSE
				NEXT FIELD cupom_fim
			END IF 
		
		AFTER FIELD cupom_fim	
			IF p_cupom_fim IS NULL THEN 
				ERROR"Campo de preenchimento obrigatório!!!"
				NEXT FIELD cupom_fim
			ELSE 
				IF p_cupom_ini > p_cupom_fim THEN 
					ERROR "Cupom final não pode ser maior que o cupom inicial!!!"
					NEXT FIELD cupom_fim
				END IF 
			END IF 
		#ON KEY (control-z)
		#CALL pol1011_popup()
	END INPUT 
	
	IF INT_FLAG = 0 THEN
		RETURN TRUE
	ELSE
		LET INT_FLAG = 0
		RETURN FALSE
	END IF
END FUNCTION
#---------------------------------#
FUNCTION pol1011_carrega_arquivo()#
#---------------------------------#
DEFINE l_cupom				INTEGER,
			 l_caminho			CHAR(200),
			 l_cam_canc			CHAR(200),
			 l_cont					SMALLINT,
			 l_cupon_char		CHAR(06),
			 p_qtd          DECIMAL(10,3),
			 p_tot_qtd      DECIMAL(10,3)
	
	LET p_cont = 0
	LET p_total= 0
			 
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
	CALL log150_procura_caminho("UNL") RETURNING p_caminho
	
	FOR l_cupom = p_cupom_ini TO p_cupom_fim +1
		LET l_cam_canc = p_caminho CLIPPED,"c0",l_cupom USING "&&&&&&",".002"		#Carrega os cupons cancelados
		WHENEVER ERROR CONTINUE 
			LOAD FROM l_cam_canc INSERT INTO t_entrada_cancel
		WHENEVER ERROR STOP
	END FOR 

	FOR l_cupom = p_cupom_ini TO p_cupom_fim
		LET l_cont = 0
		LET l_cupon_char = l_cupom USING "&&&&&&"
		
		SELECT COUNT(*)		
		INTO l_cont									#verifica se o cupon foi cancelado se for pula para o proximo
		FROM t_entrada_cancel
		WHERE REGISTRO[1,2] ='06'
		AND REGISTRO[50,55] = l_cupon_char
		
		IF l_cont > 0 THEN
			CONTINUE FOR
		END IF
		
		LET l_caminho = p_caminho CLIPPED,"l0",l_cupom USING "&&&&&&",".002"
		WHENEVER ERROR CONTINUE 
			LOAD FROM l_caminho INSERT INTO T_ENTRADA_REG
		WHENEVER ERROR STOP
		IF SQLCA.SQLCODE<> 0 THEN
			ERROR " Código do Status= ", status   
		    CALL log003_err_sql("CARGA","t_entrada_reg")
			CONTINUE FOR
		END IF 
			
		SELECT UNIQUE REGISTRO[6,11]
		INTO p_relacao.nr_fiscal
		FROM T_ENTRADA_REG
		WHERE REGISTRO[1,2] ='06'
		
	
		SELECT  ROUND((REGISTRO[5,18])/100,2)
		INTO p_relacao.v_total
		FROM T_ENTRADA_REG
		WHERE REGISTRO[1,2] ='01'
		
		LET p_tot_qtd = 0
		
		DECLARE cq_sum CURSOR FOR
 		 SELECT REGISTRO[63,71]
		   FROM T_ENTRADA_REG
		  WHERE REGISTRO[1,2] ='02'
		
		FOREACH cq_sum INTO p_qtd
		   IF p_qtd IS NOT NULL THEN
   		    LET p_tot_qtd = p_tot_qtd + p_qtd
		   END IF
		END FOREACH
		
		LET p_relacao.qtd = p_tot_qtd / 1000				
		LET p_total = p_total + p_relacao.v_total
		
		OUTPUT TO REPORT pol1011_relat(p_relacao.nr_fiscal)
		
		CALL pol1011_limpa_tabelas()
		
		LET p_cont = p_cont +1
	
	END FOR 
	
	FINISH REPORT pol1011_relat 
	
END FUNCTION

#----------------------------------#
 REPORT pol1011_relat(r_fiscal)
#----------------------------------#

	DEFINE 	r_fiscal				DECIMAL(6,0)
   
	OUTPUT LEFT   MARGIN 0
	TOP    				MARGIN 0
	BOTTOM 				MARGIN 3
	
	FORMAT
	
	PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------
	
		PRINT COLUMN 001, "--------------------------------------------------------------------------------"
		PRINT COLUMN 001, p_den_empresa,
					COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
					COLUMN 074, "PAG: ", PAGENO USING "#&"
		PRINT COLUMN 001, "pol1011             *** RELACAO DE NOTAS FISCAIS CONSUMIDOR ***"
		PRINT COLUMN 001, "--------------------------------------------------------------------------------"
	
	# BEFORE GROUP OF g_cod_item 	#------------GRUPO----------
	PRINT
	PRINT COLUMN 05,"N.FISCAL",
				COLUMN 020,"QUANTIDADE",
				#COLUMN 035,"VR. MERCADORIA" ,
				#COLUMN 050,"VR. IPI",
				COLUMN 065,"VR1. TOTAL" 
	PRINT COLUMN 001, "--------------------------------------------------------------------------------"
				
	ON EVERY ROW			#---ITENS DO  GRUPO---
		PRINT COLUMN 005,p_relacao.nr_fiscal 		USING "######",
					COLUMN 020,p_relacao.qtd 					USING "#,##&.&&&" ,
					COLUMN 065,p_relacao.v_total 			USING "###,##&.&&" 
					
	ON LAST ROW
			PRINT 
      PRINT COLUMN 005,"TOTAL GERAL",
      			COLUMN 020,SUM(p_relacao.qtd )					USING "#,##&.&&&" ,
						COLUMN 065, p_total			USING "###,##&.&&"   
   
END REPORT