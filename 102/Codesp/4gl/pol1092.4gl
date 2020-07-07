#-----------------------------------------------------------------------#
# SISTEMA.: IMPORTA�AO DE NOTAS DE SERVI�OS   		                	#
#	PROGRAMA:	pol1092													#
#	CLIENTE.:	CODESP													#
#	OBJETIVO:	IMPORTAR DADOS ATRAVES DE UM ARQUIVO DE TEXTO			#
#	AUTOR...:	Ivo   													#
#	DATA....:	18/03/2011												#
#-----------------------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   		LIKE empresa.cod_empresa,
		   	p_den_empresa			LIKE empresa.den_empresa,
		    p_user          		LIKE usuario.nom_usuario,
		    p_men       			CHAR(200),
		    p_ies_abortar         	SMALLINT,
			l_msg 				    CHAR(250),
		    p_tributo_iss_rec     	SMALLINT,
			p_tributo_iss_ret      	SMALLINT,
		    p_tributo_cofins_ret  	SMALLINT,
		    p_tributo_pis_ret     	SMALLINT,
		    p_tributo_cofins_rec  	SMALLINT,
		    p_tributo_pis_rec     	SMALLINT,
		    p_tributo_icms        	SMALLINT,
		    p_tributo_csll        	SMALLINT,
		    p_tributo_irpj        	SMALLINT,
		    p_cod_uni_feder       	CHAR(02),
				p_status        	SMALLINT,
				p_versao        	CHAR(18),
				p_resposta			SMALLINT,
				comando         	CHAR(80),
				p_caminho			CHAR(30),
			    p_nom_arquivo		CHAR(100),
				p_nom_tela 			CHAR(200),
				p_retorno			SMALLINT,
				p_ies_cons      	SMALLINT,
				p_cont				SMALLINT,
				p_tem_virgula		SMALLINT,
				p_nom_help      	CHAR(200),
				p_entrada			DECIMAL(06),
				p_tipo				CHAR(03),
				p_houve_erro		SMALLINT,
				p_print				SMALLINT,
				p_tributo           CHAR(10),
				p_base_tributo      DECIMAL(17,2), 
				p_pct_tributo       DECIMAL(17,2),
				p_val_tributo       DECIMAL(17,2), 
				p_tot_mercadoria    DECIMAL(17,2),
				p_tot_desconto		DECIMAL(17,2),
				p_tot_nf_calc		DECIMAL(17,2),
				p_ies_iss_rec		CHAR(1),
				p_cod_nat_oper      INTEGER
				

DEFINE 		w_tot_desconto				DECIMAL(17,2),
			w_val_tot_base_iss			DECIMAL(17,2),
			w_val_iss			      	DECIMAL(17,2),
			w_val_tot_base_icms			DECIMAL(17,2),
			w_val_tot_icms				DECIMAL(17,2),
			w_val_base_irpj				DECIMAL(17,2),
			w_val_irpj					DECIMAL(17,2),			
			w_val_base_csll				DECIMAL(17,2),
			w_val_csll					DECIMAL(17,2),			
			w_val_base_cofins			DECIMAL(17,2),
			w_val_cofins				DECIMAL(17,2),
			w_val_base_pis				DECIMAL(17,2),
			w_val_pis					DECIMAL(17,2),
			w_val_tot_nff				DECIMAL(17,2)



DEFINE	p_zona_franca				CHAR(1),
				p_cidade_logix		CHAR(5),
				p_trans_config		INTEGER,
			 	p_incide			CHAR(1),
			 	p_cod_fiscal		INTEGER,
				p_aliquota          DEC(7,4),
				p_acresc_desc      	LIKE  obf_config_fiscal.acresc_desc,
				p_origem_produto	LIKE  obf_config_fiscal.origem_produto,
				p_tributacao		LIKE  obf_config_fiscal.tributacao,
			 	p_estado			CHAR(2),
			 	p_trans_nota_fiscal INTEGER,
			 	p_fatura			CHAR(60),
			 	p_cliente			CHAR(15),
			 	p_row_id			INTEGER,
			 	p_cpf_cgc			CHAR(20),
			 	l_tip_solicitacao	CHAR(20), 
			 	l_especie_docum		LIKE VDP_NUM_DOCUM.especie_docum,	
			 	p_desconto_item		LIKE FAT_NF_MESTRE.VAL_DESC_NF,
			 	l_texto				CHAR(300),
				p_cod				SMALLINT,
				l_cont				SMALLINT,
				pl_qtd_item			DECIMAL(17,6),
				l_transac			INTEGER
	

END GLOBALS
 		
DEFINE p_data 	RECORD
				data		DATE,
				hora		DATETIME HOUR TO MINUTE,
				par_tipo            CHAR(1)
				
END RECORD

DEFINE p_cliente_codesp RECORD 
				cod_cliente			CHAR(15),
				tipo_cliente		CHAR(01),
				nom_cliente			CHAR(60),
				nom_reduzido		CHAR(15),
				end_cliente			CHAR(36),
				den_bairro			CHAR(19),
				cidade				CHAR(50),
				cod_cidade			CHAR(07),
				cod_cep				CHAR(09),
				estado				CHAR(02),
				telefone			CHAR(15),
				num_fax				CHAR(15),
				ins_estadual		cHAR(15),
				end_cod				CHAR(36),
				den_bairro_cob		CHAR(19),
				cidade_cob			CHAR(50),
				cod_cidade_cob		CHAR(07),
				estado_cob			CHAR(02),
				cod_cep_cob			CHAR(09),
				contato				CHAR(15),
				Emal1				CHAR(50),
				Emal2				CHAR(50),
				Emal3				CHAR(50),
				ins_municipal   char(20)

END RECORD 

DEFINE p_fatura_codesp RECORD 
			cod_empresa				CHAR(02),
			num_nf  					DECIMAL(6,0),
			serie 						CHAR(02),
			cod_cliente 			CHAR(15),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17,2),
			val_duplicata			DECIMAL(17,2),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
			data_cancel     		CHAR(15),
			texto_fatura		  	CHAR(300),
			viagem	  				CHAR(6),
			navio	  				CHAR(20),	
			atracacao  				CHAR(7),	
			data_atracacao			CHAR(10),	
			data_desatracacao		CHAR(10),
			contrato				CHAR(10),	
			local					CHAR(50),	
			documento				CHAR(18),
			tip_carteira			CHAR(02)
END RECORD 

DEFINE p_itens_fatura_codesp RECORD 
			cod_empresa					CHAR(02),
			num_nf  					DECIMAL(6,0),
			serie 						CHAR(02),
			cod_cliente 				CHAR(15),
			sequencia					DECIMAL(5,0),
			cod_item 					CHAR(15) ,
			den_item					CHAR(76),
			qtd_item					DECIMAL(17,6),
			unidade_medida				CHAR(03),
			pre_unit					DECIMAL(17,6),
			val_liq_item				DECIMAL(17,6),
			pct_iss	  					DECIMAL(5,2),
			val_tot_base_iss			DECIMAL(17,2),
			val_iss			      		DECIMAL(17,2),
			pct_icms					DECIMAL(5,2),
			val_tot_base_icms			DECIMAL(17,2),
			val_tot_icms				DECIMAL(17,2),
			pct_irpj					DECIMAL(5,2),
			val_base_irpj				DECIMAL(17,2),
			val_irpj					DECIMAL(17,2),			
			pct_csll					DECIMAL(5,2),
			val_base_csll				DECIMAL(17,2),
			val_csll					DECIMAL(17,2),			
			pct_cofins					DECIMAL(5,2),
			val_base_cofins				DECIMAL(17,2),
			val_cofins					DECIMAL(17,2),
			pct_pis						DECIMAL(5,2),	
			val_base_pis				DECIMAL(17,2),
			val_pis						DECIMAL(17,2), 
			ies_trib_pis_cofins			CHAR(01)
END RECORD

DEFINE p_item_converte RECORD
			qtd_item					DECIMAL(12,0),
			pre_unit					DECIMAL(17,0),
			val_liq_item				DECIMAL(17,0),
			pct_iss	  					DECIMAL(5,0),
			val_tot_base_iss			DECIMAL(17,0),
			val_iss			      		DECIMAL(17,0),
			pct_icms					DECIMAL(5,0),
			val_tot_base_icms			DECIMAL(17,0),
			val_tot_icms				DECIMAL(17,0),
			pct_irpj					DECIMAL(5,0),
			val_base_irpj				DECIMAL(15,0),
			val_irpj					DECIMAL(15,0),
			pct_csll					DECIMAL(5,0),
			val_base_csll				DECIMAL(15,0),
			val_csll					DECIMAL(15,0),
			pct_cofins					DECIMAL(5,0),
			val_base_cofins				DECIMAL(15,0),
			val_cofins					DECIMAL(15,0),
			pct_pis						DECIMAL(5,0),	
			val_base_pis				DECIMAL(15,0),
			val_pis						DECIMAL(15,0)	

END RECORD

DEFINE p_texto_fatura_codesp RECORD 
			cod_empresa				CHAR(02),
			num_nf  				DECIMAL(6,0),
			serie 					CHAR(02),
			cod_cliente 			CHAR(15),
			sequencia_texto			DECIMAL(05),
			des_texto   			CHAR(300)
END RECORD


DEFINE p_fatura_converte RECORD
			val_tot_nff				DECIMAL(17,0),
			val_duplicata			DECIMAL(17,0)
END RECORD

DEFINE p_parametro RECORD LIKE par_solc_fat_codesp.*
MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 30
	DEFER INTERRUPT
	LET p_versao = "pol1092-10.02.78"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol1092.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b

	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user

	IF p_status = 0  THEN
  	CALL pol1092_controle()
	END IF

END MAIN 

#---------------------------#
FUNCTION  pol1092_controle()#
#---------------------------#

  DEFINE p_processa SMALLINT 
	
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol1092") RETURNING comando
	OPEN WINDOW w_pol1092 AT 2,2 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

	IF NOT pol1092_cria_tabelas() THEN 
	   RETURN
	END IF

	LET p_processa = FALSE 
	LET p_retorno = FALSE 
	LET p_resposta = FALSE 

	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol1092_entrada_parametro() RETURNING p_retorno
				IF p_retorno THEN
				   ERROR 'Par�metros informados com sucesso!'
				   NEXT OPTION "Carregar"
				ELSE
				   ERROR 'Opera��o cancelada!'
				END IF
			END IF
		COMMAND "Carregar"   "Carregar dados das NFs de servi�os"
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				 IF p_retorno THEN
				 		MESSAGE "Carregando arquivo..."
					 	IF  pol1092_carrega_arquivo() THEN
					 	 MESSAGE "Arquivo carregado com sucesso"
					 	 LET p_resposta = TRUE 
					 	 LET p_retorno = FALSE 
					 	 NEXT OPTION "Processar"
					 	ELSE
					 		LET p_retorno = FALSE 
					 		NEXT OPTION "Informar" 
					 	END IF 
				 ELSE
					 		ERROR "Erro ao carregar dados"
				 	ERROR "Favor informar parametros"
				 	LET p_retorno = FALSE 
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		COMMAND "Processar"  "Processar a gera��o das NFs de Servi�os"
			HELP 1053
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				IF p_resposta THEN
						MESSAGE "Processando..."
						CALL log085_transacao('BEGIN') 
					 	IF pol1092_processar() THEN
					 	 MESSAGE "Arquivo processado com sucesso! Foram processados ",p_cont
					 	 
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
				 	ERROR "Arquivos n�o foram carregados!"
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		{COMMAND "faTurar"  "Fatura as solicita��es de  faturas"
			HELP 0001
			CALL log120_procura_caminho("VDP0747") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol1092
		  
		COMMAND "Nfe"  "Exporta as solicita��es de  faturas importadas"
			HELP 0001
			CALL log120_procura_caminho("VDP9202") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol1092
		
		COMMAND "Exportar"  "Exporta as solicita��es de  faturas importadas"
			HELP 0001
			CALL log120_procura_caminho("POL0936") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol1092}
   COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1092_sobre() 		
			
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol1092
END FUNCTION 

#-----------------------#
FUNCTION pol1092_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND
   
   LET p_dat = CURRENT
   
   LET p_men = p_versao CLIPPED,"\n\n",
               " Altera��o: ",p_dat,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_men,'excla')
                  
END FUNCTION

#--------------------------------#
FUNCTION  pol1092_entrada_parametro()#
#--------------------------------#

	CALL log006_exibe_teclas("01 02 07", p_versao)
 	CURRENT WINDOW IS w_pol1092	
 	INITIALIZE p_data.* TO NULL 
 	INITIALIZE p_parametro.* TO NULL 
 	CLEAR FORM	
 	DISPLAY p_cod_empresa TO cod_empresa

	INPUT p_data.data, p_data.hora, p_data.par_tipo, p_parametro.cod_parametro
	  WITHOUT DEFAULTS FROM data,hora, par_tipo, cod_parametro
		
		AFTER FIELD data
			IF p_data.data IS NULL THEN
				ERROR"Campo de preenchimento obrigat�rio"
				NEXT FIELD data 
			END IF 
		
		AFTER FIELD hora
			IF p_data.hora IS NULL THEN
				ERROR"Campo de preenchimento obrigat�rio"
				NEXT FIELD hora
			END IF 
		
		AFTER FIELD par_tipo
			IF p_data.par_tipo IS NULL THEN
				ERROR "Campo de preenchimento obrigat�rio"
				NEXT FIELD par_tipo
			END IF 
		
		
		AFTER FIELD cod_parametro
			IF p_parametro.cod_parametro IS NULL THEN
				ERROR "Campo de preenchimento obrigat�rio"
				NEXT FIELD cod_parametro
			ELSE 
			  IF p_parametro.cod_parametro <> '1' THEN
			     ERROR 'Valor deve ser igual a 1!'
    			 NEXT FIELD cod_parametro
			  END IF
				IF NOT  pol1092_verifica_parametro() THEN
					ERROR "Parametro nao cadastrado"
					NEXT FIELD cod_parametro
				END IF 
			END IF 
					
			
		ON KEY (control-z)
		   CALL pol1092_popup()

	END INPUT

	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		DISPLAY p_cod_empresa TO cod_empresa
		RETURN FALSE
	END IF

	RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1092_popup()#
#-----------------------#

DEFINE p_codigo		CHAR(10)
	
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"PARAMETROS","par_solc_fat_codesp",
						"cod_parametro","den_parametro","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol1092
			IF p_codigo IS NOT NULL THEN
				LET p_parametro.cod_parametro = p_codigo CLIPPED
				DISPLAY p_parametro.cod_parametro TO cod_parametro
			END IF
	END CASE 
END FUNCTION 

#------------------------------------#
FUNCTION pol1092_verifica_parametro()
#------------------------------------#

	SELECT * 
	INTO p_parametro.*
	FROM par_solc_fat_codesp
	WHERE cod_empresa = p_cod_empresa
	AND cod_parametro = p_parametro.cod_parametro

	IF SQLCA.SQLCODE = 0 THEN
		DISPLAY p_parametro.den_parametro TO den_parametro
		RETURN TRUE  
	END IF 

	RETURN FALSE 

END FUNCTION 

#-------------------------------#
FUNCTION  pol1092_cria_tabelas()#
#-------------------------------#

	  LET p_houve_erro = FALSE 

		DROP TABLE t_clientes_codesp_nfs  
		CREATE TABLE t_clientes_codesp_nfs(
				cod_cliente			CHAR(15),
				tipo_cliente		CHAR(01),
				nom_cliente			CHAR(60),
				nom_reduzido		CHAR(15),
				end_cliente			CHAR(36),
				den_bairro			CHAR(19),
				cidade				CHAR(50),
				cod_cidade			CHAR(07),
				cod_cep				CHAR(09),
				estado				CHAR(02),
				telefone			CHAR(15),
				num_fax				CHAR(15),
				ins_estadual		CHAR(15),
				end_cod				CHAR(36),
				den_bairro_cob		CHAR(19),
				cidade_cob			CHAR(50),
				cod_cidade_cob		CHAR(07),
				estado_cob			CHAR(02),
				cod_cep_cob			CHAR(09),
				contato				CHAR(15),
				Emal1				CHAR(50),
				Emal2				CHAR(50),
				Emal3				CHAR(50),
 			  ins_municipal   char(20)

	  )

		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("CREATE TABLE","CLIENTE_CODESP")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("CREATE TABLE","CLIENTE_CODESP"))
			LET p_houve_erro = TRUE  
		END IF
	
		DROP TABLE t_nfs_codesp 
		CREATE   TABLE t_nfs_codesp(
			cod_empresa				CHAR(02),
			num_nf  				DECIMAL(6,0),
			serie 					CHAR(02),
			cod_cliente 			CHAR(15),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17),
			val_duplicata			DECIMAL(17),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
			data_cancel     		CHAR(15),
			texto_fatura		 	CHAR(300),
			viagem	  				CHAR(6),
			navio	  				CHAR(20),	
			atracacao  				CHAR(7),	
			data_atracacao			CHAR(10),	
			data_desatracacao		CHAR(10),
			contrato				CHAR(10),	
			local					CHAR(50),	
			documento				CHAR(18),
			tip_carteira			CHAR(02)
		)

		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("CREATE TABLE","t_nfs_codesp")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("CREATE TABLE","t_nfs_codesp"))
			LET p_houve_erro = TRUE  
		END IF 

		DROP TABLE t_itens_nfs_codesp
		CREATE  TABLE t_itens_nfs_codesp(
			cod_empresa					CHAR(02),
			num_nf  					DECIMAL(6,0),
			serie 						CHAR(02),
			cod_cliente 				CHAR(15),
			sequencia					DECIMAL(5,0),
			cod_item 					CHAR(15) ,
			den_item					CHAR(76),
			qtd_item					DECIMAL(17),
			unidade_medida				CHAR(03),
			pre_unit					DECIMAL(17),
			val_liq_item				DECIMAL(17),
			pct_iss	  					DECIMAL(5),
			val_tot_base_iss			DECIMAL(17),
			val_iss			      		DECIMAL(17),
			pct_icms					DECIMAL(5),
			val_tot_base_icms			DECIMAL(17),
			val_tot_icms				DECIMAL(17),
			pct_irpj					DECIMAL(5),
			val_base_irpj				DECIMAL(17),
			val_irpj					DECIMAL(17),			
			pct_csll					DECIMAL(5),
			val_base_csll				DECIMAL(17),
			val_csll					DECIMAL(17),			
			pct_cofins					DECIMAL(5),
			val_base_cofins				DECIMAL(17),
			val_cofins					DECIMAL(17),
			pct_pis						DECIMAL(5),	
			val_base_pis				DECIMAL(17),
			val_pis						DECIMAL(17),
			ies_trib_pis_cofins			CHAR(01)
		)

		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("CREATE TABLE","t_itens_nfs_codesp")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("CREATE TABLE","t_itens_nfs_codesp"))
			LET p_houve_erro = TRUE  
		END IF 

		DROP TABLE t_nfs_texto
		CREATE   TABLE t_nfs_texto(
			cod_empresa				CHAR(02),
			num_nf  				DECIMAL(6,0),
			serie 					CHAR(02),
			cod_cliente 			CHAR(15),
			sequencia_texto			DECIMAL(05),
			des_texto   			CHAR(300)		)

		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("CREATE TABLE","t_nfs_texto")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("CREATE TABLE","t_nfs_texto"))
			LET p_houve_erro = TRUE  
		END IF 
		
	IF p_houve_erro THEN 
		FINISH REPORT pol1092_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF  

END FUNCTION

#---------------------------------#
FUNCTION  pol1092_delete_tabelas()#
#---------------------------------#

	LET p_houve_erro = FALSE 

		DELETE FROM t_itens_nfs_codesp

		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","t_itens_nfs_codesp")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("DELETE","t_itens_nfs_codesp"))
			LET p_houve_erro = TRUE  
		END IF 

		DELETE FROM t_clientes_codesp_nfs

		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","t_clientes_codesp_nfs")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("DELETE","t_clientes_codesp_nfs"))
			LET p_houve_erro = TRUE 
		END IF 

		DELETE FROM t_nfs_codesp

		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","t_nfs_codesp")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("DELETE","t_nfs_codesp"))
			LET p_houve_erro = TRUE  
		END IF 
		
		DELETE FROM t_nfs_texto

		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","t_nfs_texto")
			CALL pol1092_imprime_erros(log0030_txt_err_sql("DELETE","t_nfs_texto"))
			LET p_houve_erro = TRUE  
		END IF 
		
	IF p_houve_erro THEN 
		FINISH REPORT pol1092_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF  

END FUNCTION

#---------------------------------#	
FUNCTION pol1092_carrega_arquivo()# 
#--------------------------------#

DEFINE l_data_char		CHAR(10),
			 l_hora_char		CHAR(05),
			 l_nome_arq	 		CHAR(12),
			 l_caminho	 		CHAR(100),
			 m_caminho	 		CHAR(100),
			 p_msg					CHAR(200)
	
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
	LET p_print = FALSE
	LET p_houve_erro = TRUE 
			 
	LET l_data_char = p_data.data
	LET l_hora_char = p_data.hora
	LET l_nome_arq = 
	    l_data_char[1,2],l_data_char[4,5],l_data_char[7,10],l_hora_char[1,2],l_hora_char[4,5]
	
	IF NOT pol1092_delete_tabelas() THEN
		RETURN FALSE
	END IF
	
	SELECT nom_caminho 
	INTO m_caminho
	FROM path_logix_v2																	
	WHERE cod_empresa = p_cod_empresa 
	AND cod_sistema = "UNL"

#--Carrega dados de clientes
	
	LET l_caminho = m_caminho CLIPPED,"NFS", p_data.par_tipo, "_MESTRE_",l_nome_arq CLIPPED,'.txt'

	LOAD FROM l_caminho INSERT INTO t_nfs_codesp

		
	IF STATUS = -805 THEN
		LET p_msg = 'Arquvio ', l_caminho CLIPPED, ' nao encontrado!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL pol1092_imprime_erros(log0030_txt_err_sql("LOAD",l_caminho CLIPPED))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	
	UPDATE t_nfs_codesp SET cod_cliente = SUBSTR(cod_cliente,2,14)
	WHERE SUBSTR(cod_cliente,10,4)<>'0000'
	
	UPDATE t_nfs_codesp SET cod_cliente =  SUBSTR(cod_cliente,1,9)||  SUBSTR(cod_cliente,14,2)
	WHERE SUBSTR(cod_cliente,10,4)='0000'
	
	IF STATUS <> 0 THEN
		LET p_msg = 'Erro update cod cliente nf!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	END IF

#--Carrega cabe�alho da nota 
	
	
	LET l_caminho = m_caminho CLIPPED,"CLIENTES_NFS", p_data.par_tipo, "_",l_nome_arq CLIPPED,'.txt'

	LOAD FROM l_caminho INSERT INTO t_clientes_codesp_nfs

	IF STATUS = -805 THEN
		LET p_msg = 'Arquvio ', l_caminho CLIPPED, ' nao encontrado!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL pol1092_imprime_erros(log0030_txt_err_sql("LOAD",l_caminho  CLIPPED))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	
	UPDATE t_clientes_codesp_nfs SET cod_cliente = SUBSTR(cod_cliente,2,14)
		WHERE SUBSTR(cod_cliente,10,4)<>'0000'
		
	UPDATE t_clientes_codesp_nfs  SET cod_cliente =  SUBSTR(cod_cliente,1,9)||  SUBSTR(cod_cliente,14,2)
	WHERE SUBSTR(cod_cliente,10,4)='0000'
	
	IF STATUS <> 0 THEN
		LET p_msg = 'Erro update cod cliente na tabela cliente!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	END IF

#- Carrega itens da notas 	
	
	LET l_caminho = m_caminho CLIPPED,"NFS", p_data.par_tipo, "_ITENS_",l_nome_arq CLIPPED,'.txt'

	LOAD FROM l_caminho INSERT INTO t_itens_nfs_codesp

	IF STATUS = -805 THEN
		LET p_msg = 'Arquvio ', l_caminho CLIPPED, ' nao encontrado!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL pol1092_imprime_erros(log0030_txt_err_sql("LOAD",l_caminho CLIPPED))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	
	
	UPDATE t_itens_nfs_codesp SET cod_cliente = SUBSTR(cod_cliente,2,14)
		WHERE SUBSTR(cod_cliente,10,4)<>'0000'
		
	UPDATE t_itens_nfs_codesp   SET cod_cliente =  SUBSTR(cod_cliente,1,9)||  SUBSTR(cod_cliente,14,2)
	WHERE SUBSTR(cod_cliente,10,4)='0000'
	
	IF STATUS <> 0 THEN
		LET p_msg = 'Erro update cod cliente na tabela item nfs!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	END IF


#- Carrega texto da notas 	
	
	LET l_caminho = m_caminho CLIPPED,"NFS",p_data.par_tipo,"_OBS_",l_nome_arq CLIPPED,'.txt'

	LOAD FROM l_caminho INSERT INTO t_nfs_texto

#-- 23-07-2012 - Manuel - Comentei a verifica��o da existencia do arquivo pois os textos n�o s�o obrigat�rios, assim 
#-- caso o usu�rio n�o gerar o arquivo de texto simplesmente o programa n�o carrega. 

	IF STATUS = -805 THEN
#		LET p_msg = 'Arquvio ', l_caminho CLIPPED, ' nao encontrado!'
#		CALL pol1092_imprime_erros(p_msg)
#		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL pol1092_imprime_erros(log0030_txt_err_sql("LOAD",l_caminho CLIPPED))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	
	
	UPDATE t_nfs_texto SET cod_cliente = SUBSTR(cod_cliente,2,14)
		WHERE SUBSTR(cod_cliente,10,4)<>'0000'
		
	UPDATE t_nfs_texto   SET cod_cliente =  SUBSTR(cod_cliente,1,9)||  SUBSTR(cod_cliente,14,2)
	WHERE SUBSTR(cod_cliente,10,4)='0000'
	
	IF STATUS <> 0 THEN
		LET p_msg = 'Erro update cod cliente na tabela item nfs!'
		CALL pol1092_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	END IF	

	IF p_houve_erro THEN 
		FINISH REPORT pol1092_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF 
	
END FUNCTION 

#-------------------------------------#
FUNCTION pol1092_imprime_erros(p_erro)#			
#-------------------------------------#

  DEFINE p_erro			CHAR(250)	
	
	IF NOT  p_print THEN 			
		CALL log150_procura_caminho ('LST') RETURNING p_caminho
		LET p_caminho = p_caminho CLIPPED, 'pol1092.lst'
		LET p_nom_arquivo = p_caminho
		START REPORT pol1092_imprime TO p_nom_arquivo
		LET p_print = TRUE 
	END IF 
	
	OUTPUT TO REPORT pol1092_imprime(p_erro)
	
END FUNCTION 

#-----------------------------#
REPORT pol1092_imprime(p_erro)#			
#-----------------------------#

  DEFINE p_erro			CHAR(250)		

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  66
	 
   FORMAT
      PAGE HEADER
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 099, "PAG.: ", PAGENO USING "####&"

         PRINT COLUMN 001, "pol1092  CARGA DE SOLICITA��O DE FATURA",
               COLUMN 085, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*-----------------------------------------------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRI��O DO ERRO"
         PRINT COLUMN 001, "*-----------------------------------------------------------------------------------------------------------------------*"

      ON EVERY ROW
      	 PRINT COLUMN 001,p_erro CLIPPED
END REPORT

#---------------------------#
FUNCTION pol1092_processar()#
#---------------------------#	

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF
  
  CALL pol1092_integra_notas() RETURNING p_status
  
	IF p_houve_erro THEN 
		FINISH REPORT pol1092_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE 
	ELSE
		IF p_print THEN	
			FINISH REPORT pol1092_imprime 
			CALL log0030_mensagem("Ocorreu erro no processamento de notas, ver relat�rio gerado!",'info')
			MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		END IF
		RETURN TRUE 
	END IF 

END FUNCTION

#-------------------------------#
FUNCTION pol1092_integra_notas()
#-------------------------------#
	DEFINE l_seq_texto DEC(5,0)


	LET p_houve_erro = FALSE 
  LET l_tip_solicitacao = 'FATSERV'
  LET l_especie_docum   = 'NFS'
  
	{	SELECT TIP_SOLICITACAO, ESPECIE_DOCUM 
			INTO l_tip_solicitacao, l_especie_docum
			FROM vdp_num_docum
		 WHERE EMPRESA =p_cod_empresa
			 AND SERIE_DOCUM =1
			
			IF SQLCA.SQLCODE<> 0 THEN 
				CALL log003_err_sql('SELECT','VDP_NUM_DOCUM')
				LET l_msg = log0030_txt_err_sql("SELECT","VDP_NUM_DOCUM"),
										"N�O EXISTE NENHUM REGISTRO CADASTRADO PARA EMPRESA ",p_cod_empresa," SERIE 1"
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				RETURN FALSE 
			END IF 
  }
							 				 	
	#adiciona o cliente
	
	IF NOT  pol1092_gerencia_cliente() THEN 
		LET p_houve_erro =  TRUE
		RETURN FALSE
	END IF 
  
	LET p_cont = 0

	DECLARE cq_fatura CURSOR WITH HOLD FOR 	SELECT * FROM t_nfs_codesp
  FOREACH cq_fatura INTO  p_fatura_codesp.cod_empresa,
													p_fatura_codesp.num_nf,
													p_fatura_codesp.serie,
													p_fatura_codesp.cod_cliente,
													p_fatura_codesp.data_emissao,
													p_fatura_codesp.data_vencto,
													p_fatura_converte.val_tot_nff,
													p_fatura_converte.val_duplicata,
													p_fatura_codesp.num_boleto,
													p_fatura_codesp.ies_situacao,
													p_fatura_codesp.data_cancel,
													p_fatura_codesp.texto_fatura,
													p_fatura_codesp.viagem,
													p_fatura_codesp.navio,	
													p_fatura_codesp.atracacao,	
													p_fatura_codesp.data_atracacao,	
													p_fatura_codesp.data_desatracacao,
													p_fatura_codesp.contrato,	
													p_fatura_codesp.local,	
													p_fatura_codesp.documento,		
													p_fatura_codesp.tip_carteira	
													
		
		IF SQLCA.SQLCODE <> 0 THEN                                                                             
		 		CALL log003_err_sql("SELECT","t_nfs_codesp")                                                     
		 		CALL pol1092_imprime_erros(log0030_txt_err_sql("SELECT","t_nfs_codesp"))  
		 		LET p_houve_erro = TRUE
		 		RETURN FALSE                                                                             
		 END IF                                                                                                 
		 
		 LET p_cont = p_cont + 1
		                                                                                              
		 SELECT COUNT(EMPRESA)                                                                                  
		   INTO l_transac                                                                                       
	 	   FROM fat_nf_mestre                                                                                   
		  WHERE empresa = p_cod_empresa                                                                         
        AND cliente = p_fatura_codesp.cod_cliente                                                       
        AND nota_fiscal = p_fatura_codesp.num_nf                                                            
        AND serie_nota_fiscal       = p_fatura_codesp.serie                                                             
        AND tip_nota_fiscal = 'FATSERV'                                                                     
                                                                                                            
		 IF l_transac IS NULL THEN                                                                              
		 	LET l_transac	= 0                                                                                     
		 END IF                                                                                                 
		                                                                                                        
		 IF l_transac > 0  THEN                                                                                 
		 	LET l_msg = "NOTA DE SERVICO N� ",p_fatura_codesp.NUM_NF,                                             
		 	            "CLIENTE ",p_fatura_codesp.cod_cliente," J� PROCESSSADA"                                  
		 	CALL pol1092_imprime_erros(l_msg)                                                                     
		 	CONTINUE FOREACH                                                                                      
		 END IF                                                                                                 
                                                                                                            
  	   LET p_fatura_codesp.val_tot_nff		=	p_fatura_converte.val_tot_nff	/ 100                               
	   LET p_fatura_codesp.val_duplicata	=	p_fatura_converte.val_duplicata	/ 100                             
                                                                                                            
		 SELECT ies_zona_franca                                                                                 
		   INTO p_zona_franca                                                                                   
		   FROM clientes                                                                                        
		  WHERE cod_cliente = p_fatura_codesp.cod_cliente                                                       
		                                                                                                        
		 IF SQLCA.SQLCODE <> 0 THEN                                                                             
		 	 IF p_cliente_codesp.estado = 'AM' THEN                                                               
		 			LET p_zona_franca = 'S'                                                                           
		 		ELSE                                                                                                
		 			LET p_zona_franca = 'N'                                                                           
		 		END IF                                                                                              
		 END IF                                                                                                 
		                                                                                                        
		 IF NOT pol1092_ins_fat_nf_mestre() THEN                                                                   
		    RETURN FALSE                                                                                        
		 END IF                                                                                                 
		
		 IF NOT pol1092_ins_nf_integr()  THEN                                                                   
		    RETURN FALSE                                                                                        
		 END IF  

		 
#-- Manuel 23-07-2012 - Inclu� aqui a rotina de inclus�o de texto 

		DECLARE cq_texto_nfs CURSOR WITH HOLD FOR 
		  SELECT *
		    FROM t_nfs_texto
			 WHERE cod_empresa = p_fatura_codesp.cod_empresa
				 AND num_nf = p_fatura_codesp.num_nf
				 AND serie  = p_fatura_codesp.serie
				 AND cod_cliente = p_fatura_codesp.cod_cliente
				 ORDER BY  sequencia_texto
				 
		FOREACH cq_texto_nfs 			INTO
			        p_texto_fatura_codesp.cod_empresa,    
			        p_texto_fatura_codesp.num_nf,      
			        p_texto_fatura_codesp.serie,        
			        p_texto_fatura_codesp.cod_cliente,    
			        p_texto_fatura_codesp.sequencia_texto,  
					p_texto_fatura_codesp.des_texto   	

				IF SQLCA.SQLCODE <> 0 THEN                                                                             
					CALL log003_err_sql("SELECT","t_nfs_texto")                                                     
					CALL pol1092_imprime_erros(log0030_txt_err_sql("SELECT","t_nfs_texto"))  
					LET p_houve_erro = TRUE
					RETURN FALSE                                                                             
				END IF 	 
				
				IF NOT pol1092_ins_fat_nf_texto() THEN                                                                   
					RETURN FALSE                                                                                        
				END IF       

		END FOREACH	#fim da leitura das notas

		LET pl_qtd_item = 0
		LET p_tributo_cofins_ret 	= FALSE
		LET p_tributo_icms 			= FALSE
		LET p_tributo_iss_rec		= FALSE
		LET p_tributo_iss_ret		= FALSE
		LET p_tributo_pis_ret  		= FALSE
		LET p_tributo_csll 			= FALSE
		LET p_tributo_irpj 			= FALSE
		LET p_tributo_cofins_rec 	= FALSE
		LET p_tributo_pis_rec  		= FALSE
		LET p_tot_mercadoria 		= 0
		LET p_tot_desconto   		= 0
		LET w_tot_desconto   		= 0
		LET p_tot_nf_calc			= 0
		LET p_ies_iss_rec			= 'N'

		 DECLARE cq_item_fiscal CURSOR WITH HOLD FOR 
		  SELECT *
		    FROM t_itens_nfs_codesp
			 WHERE cod_empresa = p_fatura_codesp.cod_empresa
				 AND num_nf = p_fatura_codesp.num_nf
				 AND serie  = p_fatura_codesp.serie
				 AND cod_cliente = p_fatura_codesp.cod_cliente
				 
			FOREACH cq_item_fiscal INTO
			        p_itens_fatura_codesp.cod_empresa,    
			        p_itens_fatura_codesp.num_nf,      
			        p_itens_fatura_codesp.serie,        
			        p_itens_fatura_codesp.cod_cliente,    
			        p_itens_fatura_codesp.sequencia,      
			        p_itens_fatura_codesp.cod_item,       
			        p_itens_fatura_codesp.den_item,       
			        p_item_converte.qtd_item,             
			        p_itens_fatura_codesp.unidade_medida, 
			        p_item_converte.pre_unit,             
			        p_item_converte.val_liq_item,         
			        p_item_converte.pct_iss,             
			        p_item_converte.val_tot_base_iss,    
			        p_item_converte.val_iss,         
			        p_item_converte.pct_icms,             
			        p_item_converte.val_tot_base_icms,    
			        p_item_converte.val_tot_icms,         
			        p_item_converte.pct_irpj,             
			        p_item_converte.val_base_irpj,        
			        p_item_converte.val_irpj,             
			        p_item_converte.pct_csll,             
			        p_item_converte.val_base_csll,        
			        p_item_converte.val_csll,             
			        p_item_converte.pct_cofins,           
			        p_item_converte.val_base_cofins,      
			        p_item_converte.val_cofins,           
			        p_item_converte.pct_pis,              
			        p_item_converte.val_base_pis,         
			        p_item_converte.val_pis,
					p_itens_fatura_codesp.ies_trib_pis_cofins					
			                              
				 IF SQLCA.SQLCODE <> 0 THEN   
					  CALL log003_err_sql("SELECT","t_itens_nfs_codesp")
					  LET l_msg = "ERRO NA SOLICITA��O DE FATURA ", p_fatura_codesp.num_NF,
					              " ",log0030_txt_err_sql( "SELECT","t_itens_nfs_codesp" )
					  CALL pol1092_imprime_erros(l_msg)
					  LET p_houve_erro =  TRUE
					  RETURN FALSE
				 END IF
			
				 #converte os valores do item
				 CALL pol1092_converte_valores_Item()
				
				 #convertendo a unidade de medida para maiuscula
				 LET p_itens_fatura_codesp.unidade_medida = 
				     UPSHIFT(p_itens_fatura_codesp.unidade_medida) 
				 #adcionando o pre�o da tributa��o do icms ao pre�o unitario do produto
				 #Esta rotina est� comentada pois para notas de servi�o n�o se tributa icms
				 LET p_desconto_item  = 0 
##				 LET p_itens_fatura_codesp.pre_unit =
##				     p_itens_fatura_codesp.pre_unit /(1-(p_itens_fatura_codesp.pct_icms/100))
				 	

				 # Descarta itens que estao vindo com valores zerados 					
				 IF p_itens_fatura_codesp.val_liq_item  = 0 THEN 
				    CONTINUE FOREACH
				 END IF  
				 
				 #na rotina abaixo verifica-se se o valor liquido eh diferente da base de iss, se for uso a base de iss como liquido pois a base dos demais
				 # impostos inclusive o iss considera o valor do iss + o valor da mercadoria	
				 
				 
				SELECT 	SUM(val_tot_base_iss)/100,
						SUM(val_iss)/100,
						SUM(val_tot_base_icms)/100,
						SUM(val_tot_icms)/100,
						SUM(val_base_irpj)/100,
						SUM(val_irpj)/100,
						SUM(val_base_csll)/100,
						SUM(val_csll)/100,
						SUM(val_base_cofins)/100,
						SUM(val_cofins)/100,
						SUM(val_base_pis)/100,
						SUM(val_pis)/100
				INTO	
						w_val_tot_base_iss,
						w_val_iss,
						w_val_tot_base_icms,
						w_val_tot_icms,
						w_val_base_irpj,
						w_val_irpj,			
						w_val_base_csll,
						w_val_csll,		
						w_val_base_cofins,
						w_val_cofins,
						w_val_base_pis,
						w_val_pis	
				FROM t_itens_nfs_codesp
				WHERE cod_empresa = p_fatura_codesp.cod_empresa
				 AND num_nf = p_fatura_codesp.num_nf
				 AND serie  = p_fatura_codesp.serie
				 AND cod_cliente = p_fatura_codesp.cod_cliente
				 
				 
				LET w_tot_desconto   = (w_val_irpj + w_val_csll + w_val_cofins + w_val_pis)
				
				IF 	w_val_base_cofins > 0 THEN 
					LET p_tot_nf_calc = w_val_base_cofins - w_tot_desconto 
				ELSE 
					IF w_val_tot_base_iss > 0 THEN 
						LET p_tot_nf_calc = w_val_tot_base_iss - w_tot_desconto 
					ELSE 
						LET p_tot_nf_calc = p_fatura_codesp.val_tot_nff
					END IF 
				END IF 
					
							
							
				LET w_val_tot_nff  = p_fatura_codesp.val_tot_nff
				IF  w_val_tot_nff =  p_tot_nf_calc THEN 
					# no caso �  ISS_REC pois o total da nota  
					LET p_ies_iss_rec = 'S' 
					LET p_desconto_item = 
						p_itens_fatura_codesp.val_irpj + p_itens_fatura_codesp.val_pis +
					 	p_itens_fatura_codesp.val_csll + p_itens_fatura_codesp.val_cofins 
				ELSE
					LET p_ies_iss_rec = 'N'	
					LET p_desconto_item = 
						p_itens_fatura_codesp.val_irpj + p_itens_fatura_codesp.val_pis +
					 	p_itens_fatura_codesp.val_csll + p_itens_fatura_codesp.val_cofins + p_itens_fatura_codesp.val_iss
				END IF 
				 
				IF  (w_val_tot_base_iss  =  0) 
				AND (w_val_base_cofins   > 0 ) THEN 
				    IF p_itens_fatura_codesp.val_base_cofins > 0 THEN 
						LET p_itens_fatura_codesp.val_liq_item = p_itens_fatura_codesp.val_base_cofins
					END IF 	
				ELSE
					IF  (w_val_tot_base_iss  >  0) 	
					AND (w_val_base_cofins   = 0 ) THEN
						IF p_itens_fatura_codesp.val_tot_base_iss > 0 THEN 
							LET p_itens_fatura_codesp.val_liq_item = p_itens_fatura_codesp.val_tot_base_iss
						END IF 
					ELSE
						IF  w_val_base_cofins  >  0 	 THEN
							IF p_itens_fatura_codesp.val_base_cofins > 0 THEN 
								LET p_itens_fatura_codesp.val_liq_item = p_itens_fatura_codesp.val_base_cofins
							END IF 
						END IF 
					END IF 
				END IF 		 

			
				LET p_tot_mercadoria = p_tot_mercadoria + p_itens_fatura_codesp.val_liq_item 
				
				LET p_tot_desconto   = p_tot_desconto + p_desconto_item

				 LET pl_qtd_item = pl_qtd_item + p_itens_fatura_codesp.qtd_item
				 
#--------------- DEFINE A NATUREZA DE OPERACAO DEPENDENDO DO ITEM 			 
# Manuel em 29112012  DAQUI  

        LET p_cod_nat_oper   = 0  
		        
		    SELECT  cod_nat_oper 
			  INTO  p_cod_nat_oper
              FROM  item_x_natoper_792g
            WHERE   cod_empresa = 	p_itens_fatura_codesp.cod_empresa
              AND   cod_item    = 	p_itens_fatura_codesp.cod_item
			  
			 IF SQLCA.SQLCODE <> 0 THEN
					LET l_msg = "ERRO 2 NA NF ", p_fatura_codesp.num_NF, 
								' E CLIENTE ', p_fatura_codesp.cod_cliente,
								'  NAT OPERACAO N�O ENCONTRADA NO POL1181 PARA O ITEM: ',
								p_itens_fatura_codesp.cod_item
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					RETURN FALSE
			 END IF
			 
# Manuel em 29112012  ATE AQUI   

				 
				 
				 
				 IF NOT pol1092_ins_item() THEN
				    RETURN FALSE
				 END IF
				 

#--------------- Calcula COFINS REC
		
		IF p_itens_fatura_codesp.Ies_trib_pis_cofins  = 'S'  THEN
			LET p_tributo      = 'COFINS_REC'
			LET p_base_tributo = p_itens_fatura_codesp.val_liq_item 
			LET p_pct_tributo  = 0
			LET p_val_tributo  = 0
					 
			CALL pol1092_trib_benef() RETURNING 
				 p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
			 
			LET p_pct_tributo  = p_aliquota
			LET p_val_tributo  = (p_itens_fatura_codesp.val_liq_item *  p_aliquota)/100
			 
			 
			  IF p_incide IS NOT NULL THEN
				IF pol1092_checa_tributo() THEN
				   IF NOT pol1092_insere_tributo() THEN
					  RETURN FALSE
				   END IF
				   LET p_tributo_cofins_rec = TRUE
				END IF
			  END IF
		END IF 						

				
		
#--------------- Calcula PIS REC

        IF p_itens_fatura_codesp.Ies_trib_pis_cofins  = 'S'   THEN

			LET p_tributo      = 'PIS_REC'
			LET p_base_tributo = p_itens_fatura_codesp.val_liq_item
			LET p_pct_tributo  = 0
			LET p_val_tributo  = 0
					 
			CALL pol1092_trib_benef() RETURNING 
				 p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
			 
			LET p_pct_tributo  = p_aliquota
			LET p_val_tributo  = (p_itens_fatura_codesp.val_liq_item *  p_aliquota)/100
			 
			 
			  IF p_incide IS NOT NULL THEN
				IF pol1092_checa_tributo() THEN
				   IF NOT pol1092_insere_tributo() THEN
					  RETURN FALSE
				   END IF
				   LET p_tributo_pis_rec = TRUE
				END IF
			  END IF
		END IF 		
		
#--------------- Calcula ISS_REC
				 
		IF (p_itens_fatura_codesp.pct_iss	>  0)
		AND (p_ies_iss_rec =  'S')	THEN	 
				 
				 LET p_tributo      = 'ISS_REC'
				 LET p_base_tributo = p_itens_fatura_codesp.val_tot_base_iss
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_iss
				 LET p_val_tributo  = p_itens_fatura_codesp.val_iss
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
				IF NOT pol1092_insere_tributo() THEN
					RETURN FALSE
				END IF
               LET p_tributo_iss_rec = TRUE
			END IF
		  END IF
		END IF 
		
#--------------- Calcula ISS_RET
				 
		IF (p_itens_fatura_codesp.pct_iss	>  0)
		AND (p_ies_iss_rec <>  'S')	THEN	 
				 
				 LET p_tributo      = 'ISS_RET'
				 LET p_base_tributo = p_itens_fatura_codesp.val_tot_base_iss
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_iss
				 LET p_val_tributo  = p_itens_fatura_codesp.val_iss
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               LET p_tributo_iss_ret = TRUE
            END IF
           END IF
		END IF 		
		
#--------------- Calcula ICMS

		IF p_itens_fatura_codesp.pct_icms >0   THEN 
				 
			   SELECT cod_uni_feder
			     INTO p_cod_uni_feder
			     FROM cidades a, clientes b
			    WHERE a.cod_cidade  = b.cod_cidade
			      AND b.cod_cliente = p_fatura_codesp.cod_cliente

				 LET p_tributo      = 'ICMS'
				 LET p_base_tributo = p_itens_fatura_codesp.val_tot_base_icms
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_icms
				 LET p_val_tributo  = p_itens_fatura_codesp.val_tot_icms
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               let p_tributo_icms = TRUE
            END IF
           END IF
		END IF

#--------------- Calcula IRRF
		
		IF  p_itens_fatura_codesp.pct_irpj > 0 THEN 
				 LET p_tributo      = 'IRRF_RET'
				 LET p_base_tributo = p_itens_fatura_codesp.val_base_irpj
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_irpj
				 LET p_val_tributo  = p_itens_fatura_codesp.val_irpj
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               LET p_tributo_irpj = TRUE
            END IF
           END IF
		END IF 
		
		
#--------------- Calcula CSLL

		IF p_itens_fatura_codesp.pct_csll >0 THEN 
				 LET p_tributo      = 'CSLL_RET'
				 LET p_base_tributo = p_itens_fatura_codesp.val_base_csll
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_csll
				 LET p_val_tributo  = p_itens_fatura_codesp.val_csll
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               LET p_tributo_csll = TRUE
            END IF
           END IF
		END IF       

#--------------- Calcula COFINS RET	
		
		IF p_itens_fatura_codesp.pct_cofins  > 0  THEN 
				 LET p_tributo      = 'COFINS_RET'
				 LET p_base_tributo = p_itens_fatura_codesp.val_base_cofins
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_cofins
				 LET p_val_tributo  = p_itens_fatura_codesp.val_cofins
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
          IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               LET p_tributo_cofins_ret = TRUE
            END IF
          END IF
		END IF 		

		
#--------------- Calcula PIS RET	

		IF p_itens_fatura_codesp.pct_pis	> 0 THEN 
				 LET p_tributo      = 'PIS_RET'
				 LET p_base_tributo = p_itens_fatura_codesp.val_base_pis
				 LET p_pct_tributo  = p_itens_fatura_codesp.pct_pis
				 LET p_val_tributo  = p_itens_fatura_codesp.val_pis
				 
				 CALL pol1092_trib_benef() RETURNING 
				      p_trans_config, p_incide, p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
         
           IF p_incide IS NOT NULL THEN
            IF pol1092_checa_tributo() THEN
               IF NOT pol1092_insere_tributo() THEN
                  RETURN FALSE
               END IF
               LET p_tributo_pis_ret = TRUE
            END IF
           END IF
		END IF 


		
	END FOREACH #fim da leitura dos itens

			UPDATE fat_nf_mestre
				SET val_desc_nf    = p_tot_desconto,
					val_mercadoria = p_tot_mercadoria
				WHERE empresa = p_cod_empresa
				AND trans_nota_fiscal = p_trans_nota_fiscal

			
			IF p_tributo_iss_rec THEN
			   IF NOT pol1092_ins_fat_mestre_trib('ISS_REC') THEN
			      RETURN FALSE
			   END IF
			END IF
			
			IF p_tributo_iss_ret THEN
			   IF NOT pol1092_ins_fat_mestre_trib('ISS_RET') THEN
			      RETURN FALSE
			   END IF
			END IF
			
			IF p_tributo_icms THEN
			   IF NOT pol1092_ins_fat_mestre_trib('ICMS') THEN
			      RETURN FALSE
			   END IF
			END IF

			IF p_tributo_cofins_ret THEN
			   IF NOT pol1092_ins_fat_mestre_trib('COFINS_RET') THEN
			      RETURN FALSE
			   END IF
			END IF

			IF p_tributo_pis_ret THEN
			   IF NOT pol1092_ins_fat_mestre_trib('PIS_RET') THEN
			      RETURN FALSE
			   END IF
			END IF

			IF p_tributo_csll THEN
			   IF NOT pol1092_ins_fat_mestre_trib('CSLL_RET') THEN
			      RETURN FALSE
			   END IF
			END IF
			
			IF p_tributo_irpj THEN
			   IF NOT pol1092_ins_fat_mestre_trib('IRRF_RET') THEN
			      RETURN FALSE
			   END IF
			END IF
			
			IF p_tributo_cofins_rec THEN
			   IF NOT pol1092_ins_fat_mestre_trib('COFINS_REC') THEN
			      RETURN FALSE
			   END IF
			END IF

			IF p_tributo_pis_rec THEN
			   IF NOT pol1092_ins_fat_mestre_trib('PIS_REC') THEN
			      RETURN FALSE
			   END IF
			END IF
			
			
		
					#texto com n�fatura
			IF pl_qtd_item = 0 THEN 
				LET p_fatura = 'FATURA: ',p_fatura_codesp.num_nf,' VENCIMENTO: ',
				    p_fatura_codesp.data_vencto," TAXA MINIMA "
			ELSE
				LET p_fatura = 'FATURA: ',p_fatura_codesp.num_nf,' VENCIMENTO: ',
				    p_fatura_codesp.data_vencto
			END IF
			 
			#textos 
			    LET l_seq_texto  = 0
			
				SELECT MAX(sequencia_texto)
				INTO   l_seq_texto
				FROM fat_nf_texto_hist
				WHERE empresa 			= p_fatura_codesp.cod_empresa
				AND   trans_nota_fiscal = p_trans_nota_fiscal

				IF (SQLCA.SQLCODE =  100) OR 
				   (l_seq_texto  IS NULL)	THEN
				   LET l_seq_texto = 0 
				ELSE   
					IF SQLCA.SQLCODE <> 0 THEN
						LET l_msg = "ERRO NA LEITURA TEXTO NF 2 ", p_fatura_codesp.num_NF, 
									' E CLIENTE ', p_fatura_codesp.cod_cliente,
									" ",log0030_txt_err_sql('INSERT','FAT_NF_TEXTO_HIST'), " FAT_NF_TEXTO_HIST"
						CALL pol1092_imprime_erros(l_msg)
						LET p_houve_erro =  TRUE
						RETURN FALSE
					END IF
				END IF
						
			
					
			IF (p_fatura_codesp.viagem IS NOT NULL) 
			AND (p_fatura_codesp.viagem <> ' ') THEN 
			    INITIALIZE l_texto TO NULL
				LET l_texto = "Vg.RAP ", p_fatura_codesp.viagem,"-",p_fatura_codesp.navio,
				    " Atr nr ", p_fatura_codesp.atracacao , " data atr. ",
					p_fatura_codesp.data_atracacao, " desatr. ", 
					p_fatura_codesp.data_desatracacao							
			    LET l_seq_texto  =  l_seq_texto + 1
				INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,0,l_texto,2)
				
				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 3 ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
					CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF
			
			IF (p_fatura_codesp.contrato IS NOT NULL) 
			AND (p_fatura_codesp.contrato <> ' ') THEN 
			    INITIALIZE l_texto TO NULL
				LET l_texto = "Contrato ", p_fatura_codesp.contrato			
			    LET l_seq_texto  =  l_seq_texto + 1
				INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,0,l_texto,2)
				
				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 4 ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
					CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF
			
			
			IF (p_fatura_codesp.local IS NOT NULL) 
			AND (p_fatura_codesp.local <> ' ') THEN 
			    INITIALIZE l_texto TO NULL
				LET l_texto = "Local ", p_fatura_codesp.local			
			    LET l_seq_texto  =  l_seq_texto + 1
				INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,0,l_texto,2)
				
				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 5 ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
					CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF
			
			IF (p_fatura_codesp.documento IS NOT NULL) 
			AND (p_fatura_codesp.documento <> ' ') THEN 
			    INITIALIZE l_texto TO NULL
				LET l_texto = "Documento ", p_fatura_codesp.documento			
			    LET l_seq_texto  =  l_seq_texto + 1
				INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,0,l_texto,2)
				
				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 6 ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
					CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF			
			
			INITIALIZE l_texto TO NULL
			SELECT TEX_HIST_1 || TEX_HIST_2 || TEX_HIST_3 || TEX_HIST_4 
				INTO l_texto
				FROM FISCAL_HIST
				WHERE COD_HIST = p_cod
			
			IF STATUS = 0 AND l_texto IS NOT NULL THEN
				 LET l_seq_texto  =  l_seq_texto + 1
				 INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				 VALUES(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,p_cod,l_texto,2)

				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 7", p_fatura_codesp.num_nf," ",log0030_txt_err_sql( "INSERT","FAT_NF_TEXTO_HIST" )
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF

			IF (p_fatura_codesp.texto_fatura IS NOT NULL) 
			AND (p_fatura_codesp.texto_fatura <> ' ') THEN 
			    LET l_seq_texto  =  l_seq_texto + 1
				INSERT INTO fat_nf_texto_hist 
					(empresa, trans_nota_fiscal, sequencia_texto, texto,des_texto, tip_txt_nf) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,l_seq_texto,0,p_fatura_codesp.texto_fatura,2)
				
				IF SQLCA.SQLCODE <> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA INCLUSAO TEXTO 8 ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
					CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
					RETURN FALSE
				END IF
			END IF
			
			{INSERT INTO FAT_NF_DUPLICATA (EMPRESA,TRANS_NOTA_FISCAL,
				SEQ_DUPLICATA,VAL_DUPLICATA ,DAT_VENCTO_SDESC,
				PCT_DESC_FINANC,VAL_BC_COMISSAO ,PORTADOR,AGENCIA,DIG_AGENCIA,
				TITULO_BANCARIO,DOCUM_CRE,EMPRESA_CRE,TIP_DUPLICATA )
			VALUES 
			(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,
			1,p_fatura_codesp.val_duplicata, p_fatura_codesp.data_vencto,
			0,p_fatura_codesp.val_duplicata,'',0,' ',
		   p_fatura_codesp.num_boleto,' ',' ','N')
		  IF SQLCA.SQLCODE<> 0 THEN 
				CALL log003_err_sql('INSERT','FAT_NF_DUPLICATA')
				LET l_msg = "ERRO NA SOLICITA��O DE FATURA ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql("INSERT","FAT_NF_DUPLICATA" )
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF}
			

		MESSAGE "Processando fatura N�", p_fatura_codesp.num_nf

	END FOREACH	#fim da leitura das notas
  
  RETURN TRUE
  
END FUNCTION
#-------------------------------#
FUNCTION pol1092_ins_nf_integr()
#-------------------------------#

  DEFINE l_nf_integr RECORD 
		empresa 		char(2),
		trans_nota_fiscal 	integer,
		sit_nota_fiscal 	char(1),
		status_intg_est 	char(1),
		dat_hr_intg_est 	datetime year to second,
		status_intg_contab 	char(1),
		dat_hr_intg_contab 	datetime year to second,
		status_intg_creceb 	char(1),
		dat_hr_intg_creceb 	datetime year to second,
		status_integr_obf 	char(1),
		dat_hor_integr_obf 	datetime year to second,
		status_intg_migr 	char(1),
		dat_hr_intg_migr 	datetime year to second
     END RECORD
	 
  INITIALIZE 	 l_nf_integr  TO NULL
  
  
  LET  l_nf_integr.empresa           	= p_fatura_codesp.cod_empresa
  LET  l_nf_integr.trans_nota_fiscal 	= p_trans_nota_fiscal
  LET  l_nf_integr.sit_nota_fiscal   	= 'N'
  LET  l_nf_integr.status_intg_est   	= 'I' 	 
  LET  l_nf_integr.dat_hr_intg_est		= p_fatura_codesp.data_emissao 	 
  LET  l_nf_integr.status_intg_contab	= 'I'	 
  LET  l_nf_integr.dat_hr_intg_contab	= p_fatura_codesp.data_emissao 	 
  LET  l_nf_integr.status_intg_creceb	= 'I'	 
  LET  l_nf_integr.dat_hr_intg_creceb	=  p_fatura_codesp.data_emissao 
  LET  l_nf_integr.status_integr_obf	= 'P'	 
#  LET  l_nf_integr.dat_hor_integr_obf	= 	 
  LET  l_nf_integr.status_intg_migr		= 'I'	 
  LET  l_nf_integr.dat_hr_intg_migr	= p_fatura_codesp.data_emissao 	 
	
	INSERT INTO fat_nf_integr
	 VALUES(l_nf_integr.*)	        
	 
	IF SQLCA.SQLCODE <> 0 THEN 
		CALL log003_err_sql('INSERT','FAT_NF_INTEGR')
		LET l_msg = "ERRO NO INSERT DA FAT_NF_INTEGR ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
		CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_INTEGR"))
		LET p_houve_erro =  TRUE
		RETURN FALSE
	END IF

# Quando a nota eh cancelada a tabela 	fat_nf_integr � gravada duas vezes uma com situacao N-Normal e outra com C-Cancelada
	 IF p_fatura_codesp.ies_situacao = 'C'   THEN 
			LET  l_nf_integr.sit_nota_fiscal   	= p_fatura_codesp.ies_situacao
			INSERT INTO fat_nf_integr
			VALUES(l_nf_integr.*)	        
	 
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql('INSERT','FAT_NF_INTEGR')
				LET l_msg = "ERRO NO INSERT DA FAT_NF_INTEGR ", p_fatura_codesp.num_nf," ",log0030_txt_err_sql(  )
				CALL pol1092_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_INTEGR"))
				LET p_houve_erro =  TRUE
				RETURN FALSE
			END IF
	END IF 
	
	
	
  RETURN TRUE
  
END FUNCTION
#-------------------------------#
FUNCTION pol1092_checa_tributo()
#-------------------------------#

   IF p_pct_tributo  > 0 OR                                           
      p_base_tributo > 0 OR                                                  
      p_val_tributo  > 0 THEN                                                  
      IF p_pct_tributo  = 0 OR                                                   
         p_base_tributo = 0 OR                                               
         p_val_tributo  = 0 THEN                                               
		      LET l_msg = "FALTA VALOR P/ O TRIBUTO", p_tributo CLIPPED,  				
		                  "NA NF ", p_fatura_codesp.num_NF,               				
		                  " E CLIENTE ", p_fatura_codesp.cod_cliente       				
		      CALL pol1092_imprime_erros(l_msg)                           				
		   ELSE                                                           				
		      RETURN TRUE                                                 				
		   END IF                                                         				
		END IF        
		
		RETURN FALSE
		
END FUNCTION
                                                    				

#---------------------------------------#
FUNCTION pol1092_converte_valores_Item()#
#---------------------------------------# 

  IF p_item_converte.qtd_item IS NULL THEN
     LET p_item_converte.qtd_item = 0
  END IF
  IF p_item_converte.pre_unit IS NULL THEN
     LET p_item_converte.pre_unit = 0
  END IF
  IF p_item_converte.val_liq_item IS NULL THEN
     LET p_item_converte.val_liq_item = 0
  END IF
  IF p_item_converte.pct_iss IS NULL THEN
     LET p_item_converte.pct_iss = 0
  END IF
  IF p_item_converte.val_tot_base_iss IS NULL THEN
     LET p_item_converte.val_tot_base_iss = 0
  END IF
  IF p_item_converte.val_iss IS NULL THEN
     LET p_item_converte.val_iss = 0
  END IF
  IF p_item_converte.pct_icms IS NULL THEN
     LET p_item_converte.pct_icms = 0
  END IF
  IF p_item_converte.val_tot_base_icms IS NULL THEN
     LET p_item_converte.val_tot_base_icms = 0
  END IF
  IF p_item_converte.val_tot_icms IS NULL THEN
     LET p_item_converte.val_tot_icms = 0
  END IF
  IF p_item_converte.pct_irpj IS NULL THEN
     LET p_item_converte.pct_irpj = 0
  END IF
  IF p_item_converte.val_base_irpj IS NULL THEN
     LET p_item_converte.val_base_irpj = 0
  END IF
  IF p_item_converte.val_irpj IS NULL THEN
     LET p_item_converte.val_irpj = 0
  END IF
  IF p_item_converte.pct_csll IS NULL THEN
     LET p_item_converte.pct_csll = 0
  END IF
  IF p_item_converte.val_base_csll IS NULL THEN
     LET p_item_converte.val_base_csll = 0
  END IF
  IF p_item_converte.val_csll IS NULL THEN
     LET p_item_converte.val_csll = 0
  END IF
  IF p_item_converte.pct_cofins IS NULL THEN
     LET p_item_converte.pct_cofins = 0
  END IF
  IF p_item_converte.val_base_cofins IS NULL THEN
     LET p_item_converte.val_base_cofins = 0
  END IF
  IF p_item_converte.val_cofins IS NULL THEN
     LET p_item_converte.val_cofins = 0
  END IF
  IF p_item_converte.pct_pis IS NULL THEN
     LET p_item_converte.pct_pis = 0
  END IF
  IF p_item_converte.val_base_pis IS NULL THEN
     LET p_item_converte.val_base_pis = 0
  END IF
  IF p_item_converte.val_pis IS NULL THEN
     LET p_item_converte.val_pis = 0
  END IF
  
	LET p_itens_fatura_codesp.qtd_item					= p_item_converte.qtd_item   				/ 1000 #DECIMAL(12,3),
	LET p_itens_fatura_codesp.pre_unit					=	p_item_converte.pre_unit	   			/ 1000000 #DECIMAL(17,6),
	LET p_itens_fatura_codesp.val_liq_item			=	p_item_converte.val_liq_item 			/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.pct_iss			  		=	p_item_converte.pct_iss   			  / 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_tot_base_iss	=	p_item_converte.val_tot_base_iss	/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.val_iss     			=	p_item_converte.val_iss       		/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.pct_icms					=	p_item_converte.pct_icms   			  / 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_tot_base_icms	=	p_item_converte.val_tot_base_icms	/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.val_tot_icms			=	p_item_converte.val_tot_icms  		/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.pct_irpj					=	p_item_converte.pct_irpj   				/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_irpj			=	p_item_converte.val_base_irpj   	/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_irpj					=	p_item_converte.val_irpj   				/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_csll					=	p_item_converte.pct_csll   				/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_csll			= p_item_converte.val_base_csll  		/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_csll					=	p_item_converte.val_csll   				/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_cofins				=	p_item_converte.pct_cofins   			/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_cofins		=	p_item_converte.val_base_cofins   / 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_cofins				=	p_item_converte.val_cofins   			/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_pis						= p_item_converte.pct_pis  					/ 100 #DECIMAL(5,2),	
	LET p_itens_fatura_codesp.val_base_pis			=	p_item_converte.val_base_pis   		/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_pis						= p_item_converte.val_pis  					/ 100 #DECIMAL(5,2)
END FUNCTION 

#----------------------------------#
FUNCTION pol1092_ins_fat_nf_mestre()
#----------------------------------#

   DEFINE p_fat_nf_mestre RECORD LIKE fat_nf_mestre.*,
          t_cod_item      CHAR(15),
		  t_cod_nat_oper  INTEGER 
   
# Manuel em 29112012  DAQUI  

        LET t_cod_nat_oper   = 0  
		
   		 DECLARE cq_ver_item CURSOR WITH HOLD FOR 
		  SELECT cod_item
		    FROM t_itens_nfs_codesp
			 WHERE cod_empresa = p_fatura_codesp.cod_empresa
				 AND num_nf = p_fatura_codesp.num_nf
				 AND serie  = p_fatura_codesp.serie
				 AND cod_cliente = p_fatura_codesp.cod_cliente
				 
		FOREACH cq_ver_item  into t_cod_item 
		        
		    SELECT  cod_nat_oper 
			  INTO  t_cod_nat_oper 
              FROM  item_x_natoper_792g
            WHERE   cod_empresa = 	p_fatura_codesp.cod_empresa
              AND   cod_item    = 	t_cod_item 		
			  
			 IF SQLCA.SQLCODE <> 0 THEN
					LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_NF, 
								' E CLIENTE ', p_fatura_codesp.cod_cliente,
								'  NAT OPERACAO N�O ENCONTRADA NO POL1181 PARA O ITEM: ',
								t_cod_item 
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					RETURN FALSE
			 ELSE
			    EXIT FOREACH
			 END IF
		END FOREACH	

        IF t_cod_nat_oper  = 0 THEN 
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_NF, 
				' E CLIENTE ', p_fatura_codesp.cod_cliente,
			    ' 2 NAT OPERACAO N�O ENCONTRADA NO POL1181 PARA O ITEM: ',
				t_cod_item 
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					RETURN FALSE
		END IF		
# Manuel em 29112012  ATE AQUI   

 
   LET p_fat_nf_mestre.empresa           = p_fatura_codesp.cod_empresa
   LET p_fat_nf_mestre.trans_nota_fiscal = 0
   LET p_fat_nf_mestre.tip_nota_fiscal   = l_tip_solicitacao
   LET p_fat_nf_mestre.serie_nota_fiscal = p_fatura_codesp.serie
   LET p_fat_nf_mestre.subserie_nf       = 0
   LET p_fat_nf_mestre.espc_nota_fiscal  = l_especie_docum
   LET p_fat_nf_mestre.nota_fiscal       = p_fatura_codesp.num_nf
   LET p_fat_nf_mestre.status_nota_fiscal= 'F'
   LET p_fat_nf_mestre.modelo_nota_fiscal= 'A1'
   LET p_fat_nf_mestre.origem_nota_fiscal= 'M'
   LET p_fat_nf_mestre.tip_processamento = 'M'
   LET p_fat_nf_mestre.sit_nota_fiscal   = p_fatura_codesp.ies_situacao
   LET p_fat_nf_mestre.cliente           = p_fatura_codesp.cod_cliente
   LET p_fat_nf_mestre.remetent          = ' '
   LET p_fat_nf_mestre.zona_franca       = p_zona_franca
   
# Alterado a pedido do Jurandir em 29-11-2012 pelo Manuel DAQUI 
#   LET p_fat_nf_mestre.natureza_operacao = p_parametro.natureza_operacao
	LET p_fat_nf_mestre.natureza_operacao = t_cod_nat_oper
# Alterado a pedido do Jurandir em 29-11-2012 pelo Manuel ATE AQUI

   LET p_fat_nf_mestre.finalidade        = p_parametro.finalidade
   LET p_fat_nf_mestre.cond_pagto        = p_parametro.cond_pagto
 
# Alterado a pedido do Jurandir em 01-11-2012 pelo Manuel  
   IF (p_fatura_codesp.tip_carteira IS NOT NULL) 
   AND (p_fatura_codesp.tip_carteira <> ' ') THEN 
		LET p_fat_nf_mestre.tip_carteira      = p_fatura_codesp.tip_carteira
   ELSE
		LET p_fat_nf_mestre.tip_carteira      = p_parametro.tip_carteira
   END IF 
   
   LET p_fat_nf_mestre.ind_despesa_financ= 1
   LET p_fat_nf_mestre.moeda             = p_parametro.moeda
   LET p_fat_nf_mestre.plano_venda       = 'N'
   LET p_fat_nf_mestre.transportadora    = NULL
   LET p_fat_nf_mestre.tip_frete         = 3
   LET p_fat_nf_mestre.placa_veiculo     = NULL
   LET p_fat_nf_mestre.estado_placa_veic = NULL
   LET p_fat_nf_mestre.placa_carreta_1   = NULL
   LET p_fat_nf_mestre.estado_plac_carr_1= NULL
   LET p_fat_nf_mestre.placa_carreta_2   = NULL
   LET p_fat_nf_mestre.estado_plac_carr_2= NULL
   LET p_fat_nf_mestre.tabela_frete      = NULL
   LET p_fat_nf_mestre.seq_tabela_frete  = NULL
   LET p_fat_nf_mestre.sequencia_faixa   = NULL
   LET p_fat_nf_mestre.via_transporte    = NULL
   LET p_fat_nf_mestre.peso_liquido      = 0
   LET p_fat_nf_mestre.peso_bruto        = 0
   LET p_fat_nf_mestre.peso_tara         = 0
   LET p_fat_nf_mestre.num_prim_volume   = 0
   LET p_fat_nf_mestre.volume_cubico     = 0
   LET p_fat_nf_mestre.usu_incl_nf       = p_user
   LET p_fat_nf_mestre.dat_hor_emissao   = p_fatura_codesp.data_emissao
   LET p_fat_nf_mestre.dat_hor_saida     = NULL
   LET p_fat_nf_mestre.dat_hor_entrega   = NULL
   LET p_fat_nf_mestre.contato_entrega   = NULL
	IF p_fatura_codesp.ies_situacao = 'C'  THEN  
		LET p_fat_nf_mestre.dat_hor_cancel    = p_fatura_codesp.data_cancel
		LET p_fat_nf_mestre.motivo_cancel     = 1
		LET p_fat_nf_mestre.usu_canc_nf       = p_user

	ELSE
		LET p_fat_nf_mestre.dat_hor_cancel    = NULL
		LET p_fat_nf_mestre.motivo_cancel     = NULL
		LET p_fat_nf_mestre.usu_canc_nf       = NULL
	END IF 
   LET p_fat_nf_mestre.sit_impressao     = 'N'
   LET p_fat_nf_mestre.val_frete_rodov   = 0
   LET p_fat_nf_mestre.val_seguro_rodov  = 0
   LET p_fat_nf_mestre.val_fret_consig   = 0
   LET p_fat_nf_mestre.val_segr_consig   = 0
   LET p_fat_nf_mestre.val_frete_cliente = 0
   LET p_fat_nf_mestre.val_seguro_cliente= 0
   LET p_fat_nf_mestre.val_desc_merc     = 0
   LET p_fat_nf_mestre.val_desc_nf       = 0
   LET p_fat_nf_mestre.val_desc_duplicata= 0
   LET p_fat_nf_mestre.val_acre_merc     = 0
   LET p_fat_nf_mestre.val_acre_nf       = 0
   LET p_fat_nf_mestre.val_acre_duplicata= 0
   LET p_fat_nf_mestre.val_mercadoria    = p_fatura_codesp.val_tot_nff
   LET p_fat_nf_mestre.val_duplicata     = p_fatura_codesp.val_duplicata
   LET p_fat_nf_mestre.val_nota_fiscal   = p_fatura_codesp.val_tot_nff
   LET p_fat_nf_mestre.tip_venda         = p_parametro.tipo_venda

   INSERT INTO fat_nf_mestre VALUES(p_fat_nf_mestre.*)
   			
	 IF SQLCA.SQLCODE <> 0 THEN
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_NF, 
			            ' E CLIENTE ', p_fatura_codesp.cod_cliente,
			            " ",log0030_txt_err_sql('INSERT','FAT_NF_MESTRE'), " FAT_NF_MESTRE"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
			RETURN FALSE
	 END IF

	 LET p_trans_nota_fiscal = SQLCA.SQLERRD[2] 
	 
	 RETURN TRUE

END FUNCTION
#----------------------------------#
FUNCTION pol1092_ins_fat_nf_texto()
#----------------------------------#
  DEFINE p_fat_nf_texto RECORD LIKE fat_nf_texto_hist.*,
  	     l_seq_texto2 DEC(5,0)
		 
		 
	SELECT MAX(sequencia_texto)
	INTO   l_seq_texto2
	FROM fat_nf_texto_hist
	WHERE empresa 			= p_fatura_codesp.cod_empresa
	AND   trans_nota_fiscal = p_trans_nota_fiscal

	IF (SQLCA.SQLCODE =  100) OR 
       (l_seq_texto2  IS NULL)	THEN
	   LET l_seq_texto2 = 0 
	ELSE   
		IF SQLCA.SQLCODE <> 0 THEN
			LET l_msg = "ERRO NA LEITURA TEXTO NF ", p_fatura_codesp.num_NF, 
						' E CLIENTE ', p_fatura_codesp.cod_cliente,
						" ",log0030_txt_err_sql('INSERT','FAT_NF_TEXTO_HIST'), " FAT_NF_TEXTO_HIST"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
			RETURN FALSE
		END IF
	END IF
	
   LET l_seq_texto2 = l_seq_texto2 + 1
	
   LET p_fat_nf_texto.empresa            = p_fatura_codesp.cod_empresa
   LET p_fat_nf_texto.trans_nota_fiscal  = p_trans_nota_fiscal
   LET p_fat_nf_texto.sequencia_texto    = l_seq_texto2
   LET p_fat_nf_texto.texto				 = 0
   LET p_fat_nf_texto.des_texto			 = p_texto_fatura_codesp.des_texto
   LET p_fat_nf_texto.tip_txt_nf		 = 2

     INSERT INTO fat_nf_texto_hist  VALUES(p_fat_nf_texto.*)
   			
	 IF SQLCA.SQLCODE <> 0 THEN
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_NF, 
			            ' E CLIENTE ', p_fatura_codesp.cod_cliente,
			            " ",log0030_txt_err_sql('INSERT','FAT_NF_TEXTO_HIST'), " FAT_NF_TEXTO_HIST"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
			RETURN FALSE
	 END IF
  
END FUNCTION 

#----------------------------------#
FUNCTION pol1092_gerencia_cliente()#
#----------------------------------#
 
 DEFINE	l_cidade_logix		LIKE	obf_cidade_ibge.cidade_logix,
				l_estado					LIKE	obf_cidade_ibge.estado_logix,
				l_cliente					CHAR(15),
				l_zona_franca			CHAR(01),
				l_cont						SMALLINT,
				l_parametro				CHAR(20), 
				l_des_parametro		CHAR(60), 
				l_tip_parametro		CHAR(01),
				l_cpf_cgc					CHAR(25),
				l_trans_saida			INTEGER,
				l_chave_cliente		SMALLINT,
				l_text_aux				CHAR(35),
				l_hora						CHAR(16),
				l_cod_reg					SMALLINT,
				l_msg							CHAR(250),
				l_index						SMALLINT,
				l_ins_municipal   char(20)
				

	DECLARE cq_cliente CURSOR FOR  SELECT  * FROM t_clientes_codesp_nfs
	FOREACH cq_cliente INTO p_cliente_codesp.*
	
	   IF STATUS <> 0 THEN
	      CALL log003_err_sql('LENDO','t_clientes_codesp_nfs:cq_cliente')
	      RETURN FALSE
	   END IF
		
	 	LET l_cliente = p_cliente_codesp.cod_cliente

		SELECT cidade_logix, estado_logix
		INTO l_cidade_logix,
				 l_estado
	 	FROM obf_cidade_ibge
		WHERE cidade_ibge = p_cliente_codesp.cod_cidade
		
		IF SQLCA.SQLCODE <> 0 THEN
			IF SQLCA.SQLCODE = 100 THEN
				ERROR 'CADASTRAR O CODIGO DA CIDADE IBGE ',p_cliente_codesp.cod_cidade
			END IF 
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
			            p_cliente_codesp.nom_cliente[1,15] CLIPPED 
									,"- REGISTRO ",p_cliente_codesp.cod_cidade,
									" - CADASTRAR NO PROGRAMA VDP9113"
										
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE 
			RETURN FALSE
		END IF
		

		DELETE FROM vdp_cli_grp_email
		WHERE cliente = p_cliente_codesp.cod_cliente
		AND SEQ_EMAIL <=3
		AND grupo_email = 1
		
		IF SQLCA.SQLCODE <> 0 THEN
		   LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO DELETE DA TABELA VDP_CLI_GRP_EMAIL-STATUS= ", SQLCA.SQLCODE
		   CALL pol1092_imprime_erros(l_msg)
		   LET p_houve_erro =  TRUE
		END IF 
		
		IF p_cliente_codesp.Emal1 IS NOT NULL AND p_cliente_codesp.Emal1 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL VALUES (p_cliente_codesp.cod_cliente,1,1,p_cliente_codesp.Emal1, "C" )
			IF (SQLCA.SQLCODE <> 0) AND
			   (SQLCA.SQLCODE <> -239) THEN
			   LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 1- STATUS= ", SQLCA.SQLCODE
			   CALL pol1092_imprime_erros(l_msg)
			   LET p_houve_erro =  TRUE
			END IF 
		
			INSERT INTO VDP_CLIENTE_GRUPO VALUES (p_cliente_codesp.cod_cliente, 1,"NFS", "C" )

		END IF 			

		IF p_cliente_codesp.Emal2 IS NOT NULL AND p_cliente_codesp.Emal2 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL VALUES (p_cliente_codesp.cod_cliente,1,2,p_cliente_codesp.Emal2 , "C" )
			IF (SQLCA.SQLCODE <> 0) AND
			   (SQLCA.SQLCODE <> -239) THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 2- STATUS= ", SQLCA.SQLCODE
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF
		
		IF p_cliente_codesp.Emal3 IS NOT NULL AND p_cliente_codesp.Emal3 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL 	VALUES (p_cliente_codesp.cod_cliente,1,3,p_cliente_codesp.Emal3,  "C"  )
			IF (SQLCA.SQLCODE <> 0) AND
			   (SQLCA.SQLCODE <> -239) THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 3- STATUS= ", SQLCA.SQLCODE
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF 

			
		IF p_cliente_codesp.den_bairro IS NULL THEN 
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
			    p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM BAIRRO CADASTRADO"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
		ELSE
			IF p_cliente_codesp.den_bairro ="null" OR p_cliente_codesp.den_bairro ="Null"
				OR p_cliente_codesp.den_bairro ="NULL" THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM BAIRRO CADASTRADO"
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF 

# EM 
		LET p_tem_virgula = 0		
		
		SELECT  count(*) 
		INTO    p_tem_virgula 
		FROM    t_clientes_codesp_nfs
		WHERE    cod_cliente = p_cliente_codesp.cod_cliente
		AND      end_cliente   like '%,%'  
		
		IF p_tem_virgula = 0 THEN 
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM VIRGULA NO ENDERECO"
			CALL pol1092_imprime_erros(l_msg)
		END IF 
		
		IF l_estado = "AM" THEN
			LET l_zona_franca= 'S'
		ELSE
			LET l_zona_franca= 'N'
		END IF
		
		IF p_cliente_codesp.tipo_cliente = 'J' THEN 
			LET l_cpf_cgc = '0',p_cliente_codesp.cod_cliente[1,2],'.',p_cliente_codesp.cod_cliente[3,5],
													'.',p_cliente_codesp.cod_cliente[6,8],'/',p_cliente_codesp.cod_cliente[9,12],
													'-',p_cliente_codesp.cod_cliente[13,14]
			LET p_cliente_codesp.tipo_cliente = '1'	
			LET l_cliente = p_cliente_codesp.cod_cliente								
		ELSE
			LET l_cpf_cgc =p_cliente_codesp.cod_cliente[1,3],'.',p_cliente_codesp.cod_cliente[4,6],'.'
										 ,p_cliente_codesp.cod_cliente[7,9],'/0000-',p_cliente_codesp.cod_cliente[10,11]
			LET p_cliente_codesp.tipo_cliente = '4'
			LET l_cliente = p_cliente_codesp.cod_cliente				
		END IF 
		IF (p_cliente_codesp.nom_reduzido IS NULL)           								 	# Manuel em 08-04-2013
		OR (p_cliente_codesp.nom_reduzido = ' ')              									# Manuel em 08-04-2013
		OR (p_cliente_codesp.nom_reduzido = '')               									# Manuel em 08-04-2013 
		OR (p_cliente_codesp.nom_reduzido = '              ') THEN             					# Manuel em 08-04-2013
		    LET p_cliente_codesp.nom_reduzido = p_cliente_codesp.nom_cliente[1,15]     			# Manuel em 08-04-2013
		END IF                                                                 					# Manuel em 08-04-2013 

		
		SELECT COUNT(*)
		INTO l_cont
		FROM clientes
		WHERE cod_cliente = l_cliente
		
		IF l_cont > 0 THEN
	
			UPDATE clientes
				SET nom_cliente			=	p_cliente_codesp.nom_cliente[1,35],			
					nom_reduzido		=	p_cliente_codesp.nom_reduzido	,
					end_cliente			=	p_cliente_codesp.end_cliente,		
					den_bairro			=	p_cliente_codesp.den_bairro,
					cod_cidade			=	l_cidade_logix		,
					cod_cep					=	p_cliente_codesp.cod_cep,		
						
					num_telefone		=	p_cliente_codesp.telefone,
					num_fax					=	p_cliente_codesp.num_fax,	
					dat_atualiz			= CURRENT, 
					ins_estadual		=	p_cliente_codesp.ins_estadual,
					cod_praca			=	0
 		  WHERE cod_cliente			=	l_cliente
			
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("ATUALIZAR","CLIENTES")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("ATUALIZAR","CLIENTES")
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
					UPDATE  VDP_CLI_FORNEC_CPL 
			SET		TIP_CADASTRO		= 'C',
					RAZAO_SOCIAL		= p_cliente_codesp.nom_cliente,
					RAZAO_SOCIAL_REDUZ 	= p_cliente_codesp.nom_reduzido,
					BAIRRO				= p_cliente_codesp.den_bairro
			WHERE CLIENTE_FORNECEDOR 	= l_cliente
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("ATUALIZAR","VDP_CLI_FORNEC_CPL")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("ATUALIZAR","VDP_CLI_FORNEC_CPL")
				CALL pol0934_imprime_erros()
				LET p_houve_erro =  TRUE
			END IF 	
		ELSE 
			INSERT INTO clientes
				(cod_cliente,cod_class,nom_cliente,nom_reduzido,end_cliente,den_bairro,
				cod_cidade,cod_cep,num_telefone,num_fax,ins_estadual,num_cgc_cpf,
				cod_tip_cli,ies_cli_forn,ies_zona_franca,ies_situacao,cod_rota,cod_praca,
				dat_cadastro,	dat_atualiz,cod_local)
			VALUES 
				(l_cliente,'A',p_cliente_codesp.nom_cliente[1,35],
				 p_cliente_codesp.nom_reduzido,p_cliente_codesp.end_cliente,
				 p_cliente_codesp.den_bairro,
				l_cidade_logix,p_cliente_codesp.cod_cep,p_cliente_codesp.telefone,
				p_cliente_codesp.num_fax,p_cliente_codesp.ins_estadual,l_cpf_cgc,
				p_cliente_codesp.tipo_cliente,'C',l_zona_franca,'A','0','0',
				CURRENT,CURRENT,'0')
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","CLIENTES")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","CLIENTES")
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF 
			
			INSERT INTO VDP_CLIENTE_COMPL (CLIENTE, EMAIL, EMAIL_SECUND, ENDERECO_WEB) 
			VALUES(l_cliente, NULL, NULL,NULL)
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","VDP_CLIENTE_COMPL")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","VDP_CLIENTE_COMPL")				
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF 

			FOR l_cont = 1 TO 5
				CASE 																											 
					WHEN l_cont = 1
						LET l_parametro				= 'ins_municipal'
						LET l_des_parametro		= 'Inscricao Municipal'
						LET l_tip_parametro		=	NULL
						IF p_cliente_codesp.ins_municipal IS NULL OR
						   p_cliente_codesp.ins_municipal = ' ' THEN
               LET l_ins_municipal   = NULL
            ELSE
               LET l_ins_municipal   = p_cliente_codesp.ins_municipal
            END IF
					WHEN l_cont = 2
						LET l_parametro				= 'dat_validade_suframa'
						LET l_des_parametro		= 'Data de Validade do Suframa'
						LET l_tip_parametro		=	NULL
            LET l_ins_municipal   = NULL
					WHEN l_cont = 3
						LET l_parametro				= 'microempresa'
						LET l_des_parametro		= 'INDICADOR SE O CLIENTE EH OU NAO MICROEMPRESA'
						LET l_tip_parametro		=	'N'
            LET l_ins_municipal   = NULL
					WHEN l_cont = 4
						LET l_parametro				= 'ies_depositante'
						LET l_des_parametro		= 'Indica se o cadastro � um depositante'
						LET l_tip_parametro		=	NULL
            LET l_ins_municipal   = NULL
					WHEN l_cont = 5
						LET l_parametro				= 'celular'
						LET l_des_parametro		= 'CELULAR DO CLIENTE'
						LET l_tip_parametro		=	NULL
            LET l_ins_municipal   = NULL
				END CASE 
			
				INSERT INTO VDP_CLI_PARAMETRO 
						(CLIENTE, PARAMETRO, DES_PARAMETRO, TIP_PARAMETRO, TEXTO_PARAMETRO, 
						VAL_PARAMETRO, NUM_PARAMETRO, DAT_PARAMETRO) 
				VALUES(l_cliente, l_parametro, l_des_parametro, l_tip_parametro, l_ins_municipal, NULL, NULL, NULL)
			
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","VDP_CLI_PARAMETRO")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
					    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
					    log0030_txt_err_sql("INSERT","VDP_CLI_PARAMETRO")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF 
			
			END FOR 
			
			SELECT COUNT(*)
			INTO l_cont 
			FROM CLI_CANAL_VENDA
			WHERE COD_CLIENTE = l_cliente
			AND COD_TIP_CARTEIRA= p_parametro.tip_carteira
			
			IF l_cont = 0 THEN 
				INSERT INTO CLI_CANAL_VENDA VALUES(l_cliente,99,1,0,0,0,0,0,02,p_parametro.tip_carteira)
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","CLI_CANAL_VENDA")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
					    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
					    log0030_txt_err_sql("INSERT","CLI_CANAL_VENDA")																		
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF
			 
			SELECT COUNT(*)
			INTO l_cont
			FROM CLI_DIST_GEOG
			WHERE CLI_DIST_GEOG.COD_CLIENTE=l_cliente
			
			IF l_cont = 0 THEN 
				CASE 
					WHEN l_estado = "ES" OR l_estado = "MG" OR l_estado = "RJ" OR l_estado = "SP" 
						LET l_cod_reg =1
					WHEN l_estado = "AC" OR l_estado = "AP" OR l_estado = "AM" OR l_estado = "PA" OR l_estado = "RO" OR l_estado = "RR" OR l_estado = "TO"
						LET l_cod_reg =2
					WHEN l_estado = "BA" OR l_estado = "CE" OR l_estado = "MA" OR l_estado = "PB" OR l_estado = "SE" OR l_estado = "PI" OR l_estado = "RN" OR l_estado = "AL" OR l_estado = "PE" 
						LET l_cod_reg =3
					WHEN l_estado = "DF" OR l_estado = "GO" OR l_estado = "MT" OR l_estado = "MS"  
						LET l_cod_reg =4
					WHEN l_estado = "RS" OR l_estado = "PR" OR l_estado = "SC"
						LET l_cod_reg =5
				END CASE 
				INSERT INTO CLI_DIST_GEOG VALUES(l_cliente,'1',1,'001',l_cod_reg,l_estado)
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","CLI_DIST_GEOG")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
					    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
					    log0030_txt_err_sql("INSERT","CLI_DIST_GEOG")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF 
			
			INSERT INTO VDP_CLI_FORNEC_CPL 
						(CLIENTE_FORNECEDOR, TIP_CADASTRO, RAZAO_SOCIAL, RAZAO_SOCIAL_REDUZ, 
						BAIRRO, CORREIO_ELETRONICO, CORREI_ELETR_SECD, CORREI_ELETR_VENDA, 
						ENDERECO_WEB, TELEFONE_1, TELEFONE_2, COMPL_ENDERECO, TIP_LOGRADOURO, 
						LOGRADOURO, NUM_IDEN_LOGRAD) 
			VALUES(l_cliente, 'C', p_cliente_codesp.nom_cliente,p_cliente_codesp.nom_reduzido, 
						p_cliente_codesp.den_bairro, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","VDP_CLI_FORNEC_CPL")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","VDP_CLI_FORNEC_CPL")								
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF 
			
			LET l_text_aux = 'CLIENTE ',l_cliente
			LET l_hora = CURRENT 
			
			INSERT INTO AUDIT_LOGIX (COD_EMPRESA, TEXTO, NUM_PROGRAMA, DATA, HORA, USUARIO) 
			VALUES(p_cod_empresa,l_text_aux,'pol1092',CURRENT , l_hora[12,16] , p_user)
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","AUDIT_LOGIX")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","AUDIT_LOGIX")								
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF
			
			INSERT INTO CLI_CREDITO (COD_CLIENTE, QTD_DIAS_ATR_DUPL, QTD_DIAS_ATR_MED, 
															VAL_PED_CARTEIRA, VAL_DUP_ABERTO, DAT_ULT_FAT, 
															VAL_LIMITE_CRED, DAT_VAL_LMT_CR, IES_NOTA_DEBITO, DAT_ATUALIZ) 
			VALUES(l_cliente, 0, 0, 0, 0, NULL, 0, NULL, 'N',CURRENT )
			
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CLI_CREDITO")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","CLI_CREDITO")								
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF
			
			INSERT INTO CLIENTE_ALTER (COD_CLIENTE) VALUES(l_cliente)
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","CLIENTE_ALTER")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","CLIENTE_ALTER")								
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF
			
			INSERT INTO CREDCAD_CLI 
			VALUES(l_cliente, 0, NULL, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 0, NULL,
				0, 0, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 0, NULL, 0, NULL, NULL, 'N', NULL, NULL, 'N', 'N', 'S', 0, 'N', NULL)
			
			IF SQLCA.SQLCODE <> 0 THEN
				CALL log003_err_sql("INSERT","CREDCAD_CLI")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
				    p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
				    log0030_txt_err_sql("INSERT","CREDCAD_CLI")								
				CALL pol1092_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
				#RETURN FALSE
			END IF
			
			INSERT INTO CREDCAD_CGC 
			VALUES(l_cpf_cgc[1,11], 0, NULL,0,NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,0,0
      ,NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,NULL,NULL,'N','N','N','S',0,'N',NULL)
			
			IF SQLCA.SQLCODE = -239 THEN
			ELSE   
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","CREDCAD_CGC")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
						p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
						log0030_txt_err_sql("INSERT","CREDCAD_CGC")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF
			
			INSERT INTO CREDCAD_RATEIO 
			VALUES(l_cpf_cgc[1,11], l_cliente, 0, NULL)
			
			IF SQLCA.SQLCODE = -239 THEN
			ELSE   
				IF SQLCA.SQLCODE<> 0 THEN
					CALL log003_err_sql("INSERT","CREDCAD_RATEIO")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
						p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
						log0030_txt_err_sql("INSERT","CREDCAD_RATEIO")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF
			
			INSERT INTO CREDCAD_COD_CLI 
			VALUES(l_cliente, ' ', ' ', ' ', NULL, NULL)
			
			IF SQLCA.SQLCODE = -239 THEN
			ELSE   
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","CREDCAD_COD_CLI")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
						p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
						log0030_txt_err_sql("INSERT","CREDCAD_COD_CLI")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF
			
			SELECT MAX(chave_cliente) +1
			INTO  l_chave_cliente
			FROM sil_dimensao_cliente
			
			IF l_chave_cliente IS NULL OR l_chave_cliente = 0 THEN
				LET l_chave_cliente = 1
			END IF 
			
			INSERT INTO SIL_DIMENSAO_CLIENTE 
					(CHAVE_CLIENTE, CLIENTE, NOM_CLIENTE, NOM_REDUZ, DAT_CADASTRO) 
			VALUES(l_chave_cliente, l_cliente, p_cliente_codesp.nom_cliente[1,35], p_cliente_codesp.nom_reduzido, CURRENT )
			
			IF SQLCA.SQLCODE = -239 THEN
			ELSE  
				IF SQLCA.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","SIL_DIMENSAO_CLIENTE")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",
						p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',
						log0030_txt_err_sql("INSERT","SIL_DIMENSAO_CLIENTE")								
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
					#RETURN FALSE
				END IF
			END IF	
		END IF 

	END FOREACH 

	IF p_houve_erro THEN 
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF 

END FUNCTION 

#--------------------------#
FUNCTION pol1092_ins_item()
#--------------------------#

   DEFINE p_fat_nf_item RECORD LIKE fat_nf_item.*

   LET p_fat_nf_item.empresa            = p_fatura_codesp.cod_empresa
   LET p_fat_nf_item.trans_nota_fiscal  = p_trans_nota_fiscal
   LET p_fat_nf_item.seq_item_nf        = p_itens_fatura_codesp.sequencia
   LET p_fat_nf_item.pedido             = 0
   LET p_fat_nf_item.seq_item_pedido    = 0
   LET p_fat_nf_item.ord_montag         = 0
   LET p_fat_nf_item.tip_item           = 'S'
   LET p_fat_nf_item.item               = p_itens_fatura_codesp.cod_item
   LET p_fat_nf_item.des_item           = p_itens_fatura_codesp.den_item
   LET p_fat_nf_item.unid_medida        = p_itens_fatura_codesp.unidade_medida
   LET p_fat_nf_item.peso_unit          = 0
#  Ficou definido que a quantidade seria sempre igual a 1 e o pre�o unit�rio igual ao pre�o liquido para evitar problemas
#   LET p_fat_nf_item.qtd_item           = p_itens_fatura_codesp.qtd_item
   LET p_fat_nf_item.qtd_item           = 1
   LET p_fat_nf_item.fator_conv         = 1
   LET p_fat_nf_item.lista_preco        = NULL
   LET p_fat_nf_item.versao_lista_preco = NULL
   LET p_fat_nf_item.tip_preco          = p_parametro.tipo_preco
   
# ALTERADO A PEDIDO DO JURANDIR PELO MANUEL EM 29-11-2012 DAQUI
#   LET p_fat_nf_item.natureza_operacao  = p_parametro.natureza_operacao
   LET p_fat_nf_item.natureza_operacao  = p_cod_nat_oper
# ALTERADO A PEDIDO DO JURANDIR PELO MANUEL EM 29-11-2012 ATE AQUI

   LET p_fat_nf_item.classif_fisc       = p_parametro.clas_fiscal
   LET p_fat_nf_item.item_prod_servico  = p_parametro.item_prod
   LET p_fat_nf_item.preco_unit_bruto   = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.pre_uni_desc_incnd = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.preco_unit_liquido = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.pct_frete          = 0
   LET p_fat_nf_item.val_desc_item      = 0
   LET p_fat_nf_item.val_desc_merc      = 0
   LET p_fat_nf_item.val_desc_contab    = 0
   LET p_fat_nf_item.val_desc_duplicata = 0
   LET p_fat_nf_item.val_acresc_item    = 0
   LET p_fat_nf_item.val_acre_merc      = 0
   LET p_fat_nf_item.val_acresc_contab  = 0
   LET p_fat_nf_item.val_acre_duplicata = 0
   LET p_fat_nf_item.val_fret_consig    = 0
   LET p_fat_nf_item.val_segr_consig    = 0
   LET p_fat_nf_item.val_frete_cliente  = 0
   LET p_fat_nf_item.val_seguro_cliente = 0
   LET p_fat_nf_item.val_bruto_item     = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.val_brt_desc_incnd = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.val_liquido_item   = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.val_merc_item      = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.val_duplicata_item = (p_itens_fatura_codesp.val_liq_item - p_desconto_item) 
   LET p_fat_nf_item.val_contab_item    = p_itens_fatura_codesp.val_liq_item
   LET p_fat_nf_item.fator_conv_cliente = NULL
   LET p_fat_nf_item.uni_med_cliente    = NULL

   INSERT INTO fat_nf_item VALUES (p_fat_nf_item.*)

	 IF STATUS <> 0 THEN
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_nf,
			            'E CLIENTE ', p_fatura_codesp.cod_cliente,
			            " ",log0030_txt_err_sql("INSERT","FAT_NF_ITEM" )," FAT_NF_ITEM"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
			RETURN FALSE
	 END IF 
	 
	 RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1092_trib_benef()#
#----------------------------#	

   DEFINE l_trans_config	 INTEGER,
			    l_incide			   	CHAR(1),
			    l_cod_fiscal		 	INTEGER,	
			    l_menssagem		   		CHAR(30),
				l_aliquota          	DEC(7,4),
				l_acresc_desc      		LIKE  obf_config_fiscal.acresc_desc,
				l_origem_produto		LIKE  obf_config_fiscal.origem_produto,
				l_tributacao			LIKE  obf_config_fiscal.tributacao

   IF p_tributo = 'ICMS'   THEN         
	 		SELECT trans_config,   incide, cod_fiscal, aliquota,  acresc_desc, origem_produto,tributacao
				INTO 	l_trans_config,
						l_incide,
						l_cod_fiscal,
						l_aliquota,
						l_acresc_desc,
						l_origem_produto,
						l_tributacao
				FROM obf_config_fiscal 
			WHERE empresa       = p_fatura_codesp.cod_empresa
				AND tributo_benef = p_tributo  
				AND origem        = 'S' 
				AND estado        = p_cod_uni_feder
				AND nat_oper_grp_desp =  p_cod_nat_oper
				AND finalidade = p_parametro.finalidade 
				AND grp_fiscal_regiao IS NULL 
				AND municipio IS NULL 
				AND carteira IS NULL 
				AND familia_item IS NULL 
				AND grupo_estoque IS NULL 
				AND grp_fiscal_classif IS NULL 
				AND classif_fisc IS NULL 
				AND linha_produto IS NULL 
				AND linha_receita IS NULL 
				AND segmto_mercado IS NULL 
				AND classe_uso IS NULL 
				AND unid_medida IS NULL 
				AND produto_bonific IS NULL 
				AND grupo_fiscal_item IS NULL 
				AND item IS NULL 
				AND micro_empresa IS NULL 
				AND grp_fiscal_cliente IS NULL 
				AND cliente IS NULL 
				AND via_transporte IS NULL 
				AND valid_config_ini    IS NULL  
				AND valid_config_final  IS NULL
      ELSE
		  	SELECT trans_config, incide, cod_fiscal, aliquota, acresc_desc, origem_produto,tributacao
				INTO 	l_trans_config,
						l_incide,
						l_cod_fiscal,
						l_aliquota,
						l_acresc_desc,
						l_origem_produto,
						l_tributacao						
				FROM obf_config_fiscal 
				WHERE empresa     = p_fatura_codesp.cod_empresa
				AND tributo_benef = p_tributo  
				AND origem        = 'S' 
				AND nat_oper_grp_desp =   p_cod_nat_oper
				AND grp_fiscal_regiao IS NULL 
				AND estado IS NULL
				AND municipio IS NULL 
				AND carteira IS NULL 
				AND finalidade IS NULL
				AND familia_item IS NULL 
				AND grupo_estoque IS NULL 
				AND grp_fiscal_classif IS NULL 
				AND classif_fisc IS NULL 
				AND linha_produto IS NULL 
				AND linha_receita IS NULL 
				AND segmto_mercado IS NULL 
				AND classe_uso IS NULL 
				AND unid_medida IS NULL 
				AND produto_bonific IS NULL 
				AND grupo_fiscal_item IS NULL 
				AND item IS NULL 
				AND micro_empresa IS NULL 
				AND grp_fiscal_cliente IS NULL 
				AND cliente IS NULL 
				AND via_transporte IS NULL 
				AND valid_config_ini    IS NULL  
				AND valid_config_final  IS NULL
      END IF 

	IF STATUS = 0 THEN
		RETURN l_trans_config, l_incide, l_cod_fiscal, l_aliquota, l_acresc_desc,l_origem_produto,l_tributacao
	ELSE 
		LET l_msg = "CADASTAR TRIBUTO ", p_tributo," ",
			           log0030_txt_err_sql( "LENDO","OBF_CONFIG_FISCAL" )
		CALL pol1092_imprime_erros(l_msg)
		LET p_houve_erro =  TRUE
		RETURN	'','','', '', '','', ''
	END IF  
	
END FUNCTION

#---------------------------------#
FUNCTION pol1092_insere_tributo()
#---------------------------------#

   DEFINE p_fat_nf_item_fisc RECORD LIKE fat_nf_item_fisc.*,
          l_null                    DECIMAL(10)
          
   
   LET p_fat_nf_item_fisc.empresa            = p_fatura_codesp.cod_empresa
   LET p_fat_nf_item_fisc.trans_nota_fiscal  = p_trans_nota_fiscal
   LET p_fat_nf_item_fisc.seq_item_nf        = p_itens_fatura_codesp.sequencia
   LET p_fat_nf_item_fisc.tributo_benef      = p_tributo
   LET p_fat_nf_item_fisc.trans_config       = p_trans_config
   LET p_fat_nf_item_fisc.bc_trib_mercadoria = p_base_tributo
   LET p_fat_nf_item_fisc.bc_tributo_frete   = 0
   LET p_fat_nf_item_fisc.bc_trib_calculado  = 0
   LET p_fat_nf_item_fisc.bc_tributo_tot     = p_base_tributo
   LET p_fat_nf_item_fisc.val_trib_merc      = p_val_tributo
   LET p_fat_nf_item_fisc.val_tributo_frete  = 0
   LET p_fat_nf_item_fisc.val_trib_calculado = 0
   LET p_fat_nf_item_fisc.val_tributo_tot    = p_val_tributo
   LET p_fat_nf_item_fisc.acresc_desc        = p_acresc_desc
   LET p_fat_nf_item_fisc.aplicacao_val      = NULL
   LET p_fat_nf_item_fisc.incide             = p_incide
   LET p_fat_nf_item_fisc.origem_produto     = p_origem_produto
   LET p_fat_nf_item_fisc.tributacao         = p_tributacao
   LET p_fat_nf_item_fisc.hist_fiscal        = NULL
   LET p_fat_nf_item_fisc.sit_tributo        = NULL
   LET p_fat_nf_item_fisc.motivo_retencao    = NULL
   LET p_fat_nf_item_fisc.retencao_cre_vdp   = NULL
   LET p_fat_nf_item_fisc.cod_fiscal         = p_cod_fiscal
   LET p_fat_nf_item_fisc.inscricao_estadual = NULL
   LET p_fat_nf_item_fisc.dipam_b            = NULL
   LET p_fat_nf_item_fisc.aliquota           = p_pct_tributo
   LET p_fat_nf_item_fisc.val_unit           = NULL
   LET p_fat_nf_item_fisc.pre_uni_mercadoria = NULL
   LET p_fat_nf_item_fisc.pct_aplicacao_base = NULL
   LET p_fat_nf_item_fisc.pct_acre_bas_calc  = NULL
   LET p_fat_nf_item_fisc.pct_red_bas_calc   = NULL
   LET p_fat_nf_item_fisc.pct_diferido_base  = NULL
   LET p_fat_nf_item_fisc.pct_diferido_val   = NULL
   LET p_fat_nf_item_fisc.pct_acresc_val     = NULL
   LET p_fat_nf_item_fisc.pct_reducao_val    = NULL
   LET p_fat_nf_item_fisc.pct_margem_lucro   = NULL
   LET p_fat_nf_item_fisc.pct_acre_marg_lucr = NULL
   LET p_fat_nf_item_fisc.pct_red_marg_lucro = NULL
   LET p_fat_nf_item_fisc.taxa_reducao_pct   = NULL
   LET p_fat_nf_item_fisc.taxa_acresc_pct    = NULL
   LET p_fat_nf_item_fisc.cotacao_moeda_upf  = NULL
   LET p_fat_nf_item_fisc.simples_nacional   = NULL
   LET l_null                                = NULL
   
   INSERT INTO fat_nf_item_fisc VALUES(p_fat_nf_item_fisc.empresa,
		p_fat_nf_item_fisc.trans_nota_fiscal  ,
		p_fat_nf_item_fisc.seq_item_nf,
		p_fat_nf_item_fisc.tributo_benef,
		p_fat_nf_item_fisc.trans_config ,
		p_fat_nf_item_fisc.bc_trib_mercadoria ,
		p_fat_nf_item_fisc.bc_tributo_frete   ,
		p_fat_nf_item_fisc.bc_trib_calculado  ,
		p_fat_nf_item_fisc.bc_tributo_tot    ,
		p_fat_nf_item_fisc.val_trib_merc     ,
		p_fat_nf_item_fisc.val_tributo_frete  ,
		p_fat_nf_item_fisc.val_trib_calculado ,
		p_fat_nf_item_fisc.val_tributo_tot    ,
		p_fat_nf_item_fisc.acresc_desc        ,
		p_fat_nf_item_fisc.aplicacao_val      ,
		p_fat_nf_item_fisc.incide             ,
		p_fat_nf_item_fisc.origem_produto     ,
		p_fat_nf_item_fisc.tributacao         ,
		p_fat_nf_item_fisc.hist_fiscal        ,
		p_fat_nf_item_fisc.sit_tributo        ,
		p_fat_nf_item_fisc.motivo_retencao    ,
		p_fat_nf_item_fisc.retencao_cre_vdp   ,
		p_fat_nf_item_fisc.cod_fiscal         ,
		p_fat_nf_item_fisc.inscricao_estadual ,
		p_fat_nf_item_fisc.dipam_b            ,
		p_fat_nf_item_fisc.aliquota           ,
		p_fat_nf_item_fisc.val_unit           ,
		p_fat_nf_item_fisc.pre_uni_mercadoria ,
		p_fat_nf_item_fisc.pct_aplicacao_base ,
		p_fat_nf_item_fisc.pct_acre_bas_calc  ,
		p_fat_nf_item_fisc.pct_red_bas_calc   ,
		p_fat_nf_item_fisc.pct_diferido_base  ,
		p_fat_nf_item_fisc.pct_diferido_val   ,
		p_fat_nf_item_fisc.pct_acresc_val    ,
		p_fat_nf_item_fisc.pct_reducao_val    ,
		p_fat_nf_item_fisc.pct_margem_lucro   ,
		p_fat_nf_item_fisc.pct_acre_marg_lucr ,
		p_fat_nf_item_fisc.pct_red_marg_lucro ,
		p_fat_nf_item_fisc.taxa_reducao_pct   ,
		p_fat_nf_item_fisc.taxa_acresc_pct    ,
		p_fat_nf_item_fisc.cotacao_moeda_upf  ,
		p_fat_nf_item_fisc.simples_nacional,
		l_null,0 	)
   
	 IF SQLCA.SQLCODE<>0 THEN
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_nf," ",
			            " E CLIENTE ", p_fatura_codesp.cod_cliente,
			            log0030_txt_err_sql( "INSERT","FAT_NF_ITEM_FISC"), " FAT_NF_ITEM_FISC"
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
			RETURN FALSE
	 END IF
	 
	 RETURN TRUE
	 
END FUNCTION

#----------------------------------------------#
FUNCTION pol1092_ins_fat_mestre_trib(l_tributo)
#----------------------------------------------#

   DEFINE l_tributo CHAR(10)
   DEFINE p_fat_mestre_fiscal RECORD LIKE fat_mestre_fiscal.*

   LET p_fat_mestre_fiscal.empresa           = p_cod_empresa
   LET p_fat_mestre_fiscal.trans_nota_fiscal = p_trans_nota_fiscal
   LET p_fat_mestre_fiscal.tributo_benef     = l_tributo

   SELECT SUM(bc_trib_mercadoria), 
          SUM(bc_tributo_frete),   
          SUM(bc_trib_calculado),  
          SUM(bc_tributo_tot),     
          SUM(val_trib_merc),      
          SUM(val_tributo_frete),  
          SUM(val_trib_calculado), 
          SUM(val_tributo_tot)
     INTO p_fat_mestre_fiscal.bc_trib_mercadoria, 
          p_fat_mestre_fiscal.bc_tributo_frete,   
          p_fat_mestre_fiscal.bc_trib_calculado,  
          p_fat_mestre_fiscal.bc_tributo_tot,     
          p_fat_mestre_fiscal.val_trib_merc,      
          p_fat_mestre_fiscal.val_tributo_frete,  
          p_fat_mestre_fiscal.val_trib_calculado, 
          p_fat_mestre_fiscal.val_tributo_tot     
     FROM fat_nf_item_fisc
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nota_fiscal
      AND tributo_benef = l_tributo
                    
   IF STATUS <> 0 THEN
			LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_nf," ",
			            " E CLIENTE ", p_fatura_codesp.cod_cliente,
			            log0030_txt_err_sql( "LENDO","FAT_NF_ITEM_FISC" )
			CALL pol1092_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
      RETURN FALSE
   END IF

   IF p_fat_mestre_fiscal.bc_trib_mercadoria IS NULL THEN
      LET p_fat_mestre_fiscal.bc_trib_mercadoria = 0
   END IF
   
   IF p_fat_mestre_fiscal.bc_tributo_frete IS NULL THEN
      LET p_fat_mestre_fiscal.bc_tributo_frete = 0
   END IF
   
   IF p_fat_mestre_fiscal.bc_trib_calculado IS NULL THEN
      LET p_fat_mestre_fiscal.bc_trib_calculado = 0
   END IF
   
   IF p_fat_mestre_fiscal.bc_tributo_tot IS NULL THEN
      LET p_fat_mestre_fiscal.bc_tributo_tot = 0
   END IF
   
   IF p_fat_mestre_fiscal.val_trib_merc IS NULL THEN
      LET p_fat_mestre_fiscal.val_trib_merc = 0
   END IF
   
   IF p_fat_mestre_fiscal.val_tributo_frete IS NULL THEN
      LET p_fat_mestre_fiscal.val_tributo_frete = 0
   END IF
   
   IF p_fat_mestre_fiscal.val_trib_calculado IS NULL THEN
      LET p_fat_mestre_fiscal.val_trib_calculado = 0
   END IF
   
   IF p_fat_mestre_fiscal.val_tributo_tot IS NULL THEN
      LET p_fat_mestre_fiscal.val_tributo_tot = 0
   END IF
   
   IF p_fat_mestre_fiscal.bc_tributo_tot > 0  THEN 
		INSERT INTO fat_mestre_fiscal
			VALUES(p_fat_mestre_fiscal.*)

		IF STATUS <> 0 THEN
					LET l_msg = "ERRO NA NF ", p_fatura_codesp.num_nf," ",
								" E CLIENTE ", p_fatura_codesp.cod_cliente,
								log0030_txt_err_sql( "INSERT","FAT_MESTRE_FISCAL"),"FAT_MESTRE_FISCAL"
					CALL pol1092_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
			RETURN FALSE
		END IF
	END IF

   RETURN TRUE

END FUNCTION