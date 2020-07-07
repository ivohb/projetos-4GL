#---------------------------------------------------------------------------#
# SISTEMA.: IMPORTAÇAO DE SOLICITAÇÃO DE FATURA		                	  	#
#	PROGRAMA:	pol0934														#
#	CLIENTE.:	CODESP														#
#	OBJETIVO:	IMPORTAR DADOS ATRAVES DE UM ARQUIVO DE TEXTO				#
#	AUTOR...:	THIAGO														#
#	DATA....:	11/05/2009													#
#---------------------------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE 
		   	p_cod_empresa   				LIKE empresa.cod_empresa,
		   	p_den_empresa					LIKE empresa.den_empresa,
		    p_user          				LIKE usuario.nom_usuario,
				p_status        			SMALLINT,
				p_versao        			CHAR(18),
				p_resposta					SMALLINT,
				comando         			CHAR(80),
				p_caminho					CHAR(30),
			    p_nom_arquivo				CHAR(100),
				p_nom_tela 					CHAR(200),
				p_retorno					SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont						SMALLINT,
				p_tem_virgula				SMALLINT,
				p_nom_help      			CHAR(200),
				p_natureza_operacao			INTEGER,
				p_entrada					DECIMAL(06),
				p_tipo						CHAR(03),
				p_msg						CHAR(600), 
				p_houve_erro				SMALLINT,
				p_print						SMALLINT				#VARIAVEL FOI CRIADA PARA PODER SABER QUANDO EU ESTOU ABRINDO O
END GLOBALS 																	#REPORT PARA CONTROLE DE ABRIR E FECHAR O REPORT 
DEFINE p_data 	RECORD
				data		DATE,
				hora		DATETIME HOUR TO MINUTE 
END RECORD
DEFINE p_cliente_codesp RECORD 
				cod_cliente			CHAR(14),
				tipo_cliente		CHAR(01),
				nom_cliente			CHAR(60),
				nom_reduzido		CHAR(15),
				end_cliente			CHAR(36),
				den_bairro			CHAR(19),
				cidade				CHAR(50),
				cod_cidade			CHAR(07),#DECIMAL(7,0),
				cod_cep				CHAR(09),
				estado				CHAR(02),
				telefone			CHAR(15),
				num_fax				CHAR(15),
				ins_estadual		CHAR(15),
				end_cod				CHAR(36),
				den_bairro_cob		CHAR(19),
				cidade_cob			CHAR(50),
				cod_cidade_cob		DECIMAL(7,0),
				estado_cob			CHAR(02),
				cod_cep_cob			CHAR(09),
				contato				CHAR(15),
				Emal1				CHAR(50),
				Emal2				CHAR(50),
				Emal3				CHAR(50)

END RECORD 
DEFINE p_fatura_codesp RECORD 
			cod_empresa				CHAR(02),
			num_docum				DECIMAL(6,0),
			especie					CHAR(03),
			cod_cliente 			CHAR(14),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17,2),
			val_duplicata			DECIMAL(17,2),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
			#dat_cancel				DATE,
			texto_fatura			CHAR(300)
END RECORD 
DEFINE p_itens_fatura_codesp RECORD 
			cod_empresa					CHAR(02),
			num_docum					DECIMAL(6,0),
			especie						CHAR(03),
			cod_cliente 				CHAR(14),
			sequencia					DECIMAL(5,0),
			cod_item 					CHAR(15) ,
			den_item					CHAR(76),
			qtd_item					DECIMAL(17,6),
			unidade_medida				CHAR(3),
			pre_unit					DECIMAL(17,6),
			val_liq_item				DECIMAL(17,6),
			pct_icms					DECIMAL(5,2),
			val_tot_base_icms			DECIMAL(17,2),
			val_tot_icms				DECIMAL(17,2),
			pct_irpj					DECIMAL(5,2),
			val_base_irpj				DECIMAL(15,2),
			val_irpj					DECIMAL(15,2),
			pct_csll					DECIMAL(5,2),
			val_base_csll				DECIMAL(15,2),
			val_csll					DECIMAL(15,2),
			pct_cofins					DECIMAL(5,2),
			val_base_cofins				DECIMAL(15,2),
			val_cofins					DECIMAL(15,2),
			pct_pis						DECIMAL(5,2),	
			val_base_pis				DECIMAL(15,2),
			val_pis						DECIMAL(15,2)
END RECORD
DEFINE p_item_converte RECORD
			qtd_item					DECIMAL(12,0),
			pre_unit					DECIMAL(17,0),
			val_liq_item				DECIMAL(17,0),
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
DEFINE p_fatura_converte RECORD
			val_tot_nff				DECIMAL(17,0),
			val_duplicata			DECIMAL(17,0)
END RECORD

DEFINE p_parametro RECORD LIKE par_solc_fat_codesp.*
MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	WHENEVER ANY ERROR STOP
	DEFER INTERRUPT
	LET p_versao = "pol0934-10.02.34"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0934.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("VDP","LIC_LIB")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		IF pol0934_cria_tabelas() THEN 
	  	CALL pol0934_controle()
	  END IF 
	END IF
END MAIN 
#---------------------------#
FUNCTION  pol0934_controle()#
#---------------------------#
DEFINE p_processa SMALLINT 
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0934") RETURNING comando
	OPEN WINDOW w_pol0934 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	LET p_processa = FALSE 
	LET p_retorno = FALSE 
	LET p_resposta = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0934_entrada_parametro() RETURNING p_retorno
				NEXT OPTION "Carregar"
			END IF
		COMMAND "Carregar"   "Carregar arquivo de dados"
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				 IF p_retorno THEN
				 		MESSAGE "Carregando arquivo..."
					 	IF  pol0934_carrega_arquivo() THEN
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
					 	IF pol0934_processar() THEN
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
				 	ERROR "Arquivos não foram carregados!"
				 	NEXT OPTION "Informar"
				 END IF
			END IF
		COMMAND "faTurar"  "Fatura as solicitações de  faturas"
			HELP 0001
			CALL log120_procura_caminho("VDP0747") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0934
		  
		COMMAND "Nfe"  "Exporta as solicitações de  faturas importadas"
			HELP 0001
			CALL log120_procura_caminho("VDP9202") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0934
		
		COMMAND "Exportar"  "Exporta as solicitações de  faturas importadas"
			HELP 0001
			CALL log120_procura_caminho("POL0936") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0934
		COMMAND "fAt_nf"
			HELP 0001
			CALL pol0934_control()
			CALL log006_exibe_teclas("01 02 07", p_versao)
 			CURRENT WINDOW IS w_pol0934	
	    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0934_sobre() 	
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0934
END FUNCTION 

#-----------------------#
FUNCTION pol0934_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#--------------------------------#
FUNCTION  pol0934_entrada_parametro()#
#--------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
 	CURRENT WINDOW IS w_pol0934	
 	INITIALIZE p_data.* TO NULL 
 	INITIALIZE p_parametro.* TO NULL 
 	CLEAR FORM	
 	DISPLAY p_cod_empresa TO cod_empresa
	INPUT p_data.data, p_data.hora, p_parametro.cod_parametro WITHOUT DEFAULTS FROM data,hora, cod_parametro
		AFTER FIELD data
			IF p_data.data IS NULL THEN
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD data 
			END IF 
		AFTER FIELD hora
			IF p_data.hora IS NULL THEN
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD hora
			END IF 
		AFTER FIELD cod_parametro
			IF p_parametro.cod_parametro IS NULL THEN
				ERROR"Campo de preenchimento obrigatório"
				NEXT FIELD cod_parametro
			ELSE 
				IF p_parametro.cod_parametro <> '6' THEN
			     ERROR 'Valor deve ser igual a 6 !'
    			 NEXT FIELD cod_parametro
				END IF
				IF NOT  pol0934_verifica_parametro() THEN
					ERROR"Parametro nao cadastrado"
					NEXT FIELD cod_parametro
				END IF 
			END IF 
		ON KEY (control-z)
		CALL pol0934_popup()
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
{vai criar as tabelas temporarias
	a serem trabalhadas}
#-------------------------------#
FUNCTION  pol0934_cria_tabelas()#
#-------------------------------#
	LET p_houve_erro = FALSE 
	WHENEVER ERROR CONTINUE
		DROP TABLE t_clientes_codesp  
		CREATE TEMP TABLE t_clientes_codesp(
			cod_cliente			CHAR(14),
			tipo_cliente		CHAR(01),
			nom_cliente			CHAR(60),
			nom_reduzido		CHAR(15),
			end_cliente			CHAR(36),
			den_bairro			CHAR(19),
			cidade					CHAR(50),
			cod_cidade			CHAR(07),#DECIMAL(7,0),
			cod_cep					CHAR(09),
			estado					CHAR(02),
			telefone				CHAR(15),
			num_fax					CHAR(15),
			ins_estadual		CHAR(15),
			end_cod					CHAR(36),
			den_bairro_cob	CHAR(19),
			cidade_cob			CHAR(50),
			cod_cidade_cob	CHAR(7),#DECIMAL(7,0),
			estado_cob			CHAR(02),
			cod_cep_cob			CHAR(09),
			contato					CHAR(15),
			Emal1						CHAR(50),
			Emal2						CHAR(50),
			Emal3						CHAR(50)
		)
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("CREATE TABLE","CLIENTE_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("CREATE TABLE","CLIENTE_CODESP"))
			LET p_houve_erro = TRUE  
		END IF
		DROP TABLE t_fatura_codesp 
		CREATE TEMP TABLE t_fatura_codesp(
			cod_empresa				CHAR(02),
			num_docum					DECIMAL(6,0),
			especie						CHAR(03),
			cod_cliente 			CHAR(14),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17,0),
			val_duplicata			DECIMAL(17,0),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
		 #dat_cancel				DATE,
			texto_fatura		CHAR(300)
		)
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("CREATE TABLE","T_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("CREATE TABLE","T_FATURA_CODESP"))
			LET p_houve_erro = TRUE  
		END IF 
		DROP TABLE t_itens_fatura_codesp
		CREATE TEMP TABLE t_itens_fatura_codesp(
			cod_empresa				CHAR(02),
			num_docum					DECIMAL(6,0),
			especie						CHAR(03),
			cod_cliente 			CHAR(14),
			sequencia					DECIMAL(5,0),
			cod_item 					CHAR(15) ,
			den_item					CHAR(76),
			qtd_item					DECIMAL(12,0),
			unidade_medida		CHAR(3),
			pre_unit					DECIMAL(17,0),
			val_liq_item			DECIMAL(17,0),
			pct_icms					DECIMAL(5,0),
			val_tot_base_icms	DECIMAL(17,0),
			val_tot_icms			DECIMAL(17,0),
			pct_irpj					DECIMAL(5,0),
			val_base_irpj			DECIMAL(15,0),
			val_irpj					DECIMAL(15,0),
			pct_csll					DECIMAL(5,0),
			val_base_csll			DECIMAL(15,0),
			val_csll					DECIMAL(15,0),
			pct_cofins				DECIMAL(5,0),
			val_base_cofins		DECIMAL(15,0),
			val_cofins				DECIMAL(15,0),
			pct_pis						DECIMAL(5,0),	
			val_base_pis			DECIMAL(15,0),
			val_pis						DECIMAL(5,0)
		)
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("CREATE TABLE","T_ITENS_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("CREATE TABLE","T_ITENS_FATURA_CODESP"))
			LET p_houve_erro = TRUE  
		END IF 
	WHENEVER ERROR STOP
	IF p_houve_erro THEN 
		FINISH REPORT pol0934_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF  
END FUNCTION
#---------------------------------#
FUNCTION  pol0934_delete_tabelas()#
#---------------------------------#
	LET p_houve_erro = FALSE 
	WHENEVER ERROR CONTINUE 
		DELETE  T_ITENS_FATURA_CODESP
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","T_ITENS_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("DELETE","T_ITENS_FATURA_CODESP"))
			LET p_houve_erro = TRUE  
		END IF 
		DELETE  T_CLIENTES_CODESP
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","T_CLIENTES_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("DELETE","T_CLIENTES_CODESP"))
			LET p_houve_erro = TRUE 
		END IF 
		DELETE  T_FATURA_CODESP
		IF SQLCA.SQLCODE <>0 THEN
			CALL log003_err_sql("DELETE","T_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("DELETE","T_FATURA_CODESP"))
			LET p_houve_erro = TRUE  
		END IF 
	WHENEVER ERROR STOP 
	
	IF p_houve_erro THEN 
		FINISH REPORT pol0934_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF  
END FUNCTION

{Função vai abrir os arquivos texto 
	e jogar numa tabela temporaria para 
	poder trabalhar com os dados}	
#---------------------------------#	
FUNCTION pol0934_carrega_arquivo()# 
#--------------------------------#
DEFINE #p_nome_arquivo CHAR(20),
			 l_data_char		CHAR(10),
			 l_hora_char		CHAR(05),
			 l_nome_arq	 		CHAR(12),
			 l_caminho	 		CHAR(100),
			 p_msg					CHAR(200)
	
	SELECT den_empresa
	INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
	LET p_print = FALSE
	LET p_houve_erro = TRUE 
			 
	LET l_data_char = p_data.data
	LET l_hora_char = p_data.hora
	LET l_nome_arq = l_data_char[1,2],l_data_char[4,5],l_data_char[9,10],l_hora_char[1,2],l_hora_char[4,5]
	
	IF NOT pol0934_delete_tabelas() THEN
		RETURN FALSE
	END IF
	
	SELECT nom_caminho 
	INTO p_caminho
	FROM path_logix_v2																	#localizando caminho onde vai procurar o arquivo
	WHERE cod_empresa = p_cod_empresa 
	AND cod_sistema = "UNL"
	
	#Abre o arquivo faturas_data.txt e joga na tabela temporaria fatura 
	LET l_caminho = p_caminho CLIPPED,"FATURAS_",l_nome_arq CLIPPED,'.txt'
	WHENEVER ERROR CONTINUE 
		LOAD FROM l_caminho INSERT INTO t_fatura_codesp
	WHENEVER ERROR STOP
	IF STATUS = -805 THEN
		LET p_msg = log0030_txt_err_sql("LOAD","T_FATURA_CODESP")," Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"			#fazendo o load do aquivo de Fatuas
		CALL log0030_mensagem(p_msg,"excla")							#carregando a tabela temporaria de faturas
		CALL pol0934_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","T_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("LOAD","T_FATURA_CODESP"))
			LET p_houve_erro = TRUE 
		END IF
	END IF

	#Abre o arquivo clientes_data.txt e joga na tabela temporaria clientes_codesp
	LET l_caminho = p_caminho CLIPPED,"CLIENTES_",l_nome_arq CLIPPED,'.txt'
	WHENEVER ERROR CONTINUE 
		LOAD FROM l_caminho INSERT INTO t_clientes_codesp
	WHENEVER ERROR STOP 
	IF STATUS = -805 THEN
		LET p_msg = log0030_txt_err_sql("LOAD","T_CLIENTES_CODESP")," Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"			#fazendo o load do aquivo de fornecedores
		CALL log0030_mensagem(p_msg,"excla")							#carregando a tabela temporaria de fornecedores
		CALL pol0934_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","T_CLIENTES_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("LOAD","T_CLIENTES_CODESP"))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	
	#Abre o arquivo faturas_Itens_data.txt e joga na tabela temporaria itens_fatura 
	LET l_caminho = p_caminho CLIPPED,"FATURAS_ITENS_",l_nome_arq CLIPPED,'.txt'
	WHENEVER ERROR CONTINUE 
		LOAD FROM l_caminho INSERT INTO t_itens_fatura_codesp
	WHENEVER ERROR STOP
	IF STATUS = -805 THEN
		LET p_msg = log0030_txt_err_sql("LOAD","T_ITENS_FATURA_CODESP")," Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"			#fazendo o load do aquivo de fornecedores
		CALL log0030_mensagem(p_msg,"excla")							#carregando a tabela temporaria t_itens_fatura_codesp
		CALL pol0934_imprime_erros(p_msg)
		LET p_houve_erro = TRUE 																			
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","T_ITENS_FATURA_CODESP")
			CALL pol0934_imprime_erros(log0030_txt_err_sql("LOAD","T_ITENS_FATURA_CODESP"))
			LET p_houve_erro = TRUE 
		END IF
	END IF
	IF p_houve_erro THEN 
		FINISH REPORT pol0934_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF 
END FUNCTION 
#---------------------------#
FUNCTION pol0934_processar()#
#---------------------------#	
DEFINE			p_zona_franca			CHAR(1),
				p_cidade_logix			CHAR(5),
				p_trans_config			INTEGER,
			 	p_incide				CHAR(1),
			 	p_cod_fiscal			INTEGER,
				p_aliquota          	DECIMAL(7,4),
				p_acresc_desc      		LIKE  obf_config_fiscal.acresc_desc,
				p_origem_produto		LIKE  obf_config_fiscal.origem_produto,
				p_tributacao			LIKE  obf_config_fiscal.tributacao,
			 	p_estado				CHAR(2),
			 	p_trans_nota_fiscal 	INTEGER,
			 	p_fatura				CHAR(60),
			 	p_cliente				CHAR(15),
			 	p_row_id				INTEGER,
			 	#p_empresa				CHAR(2),
			 	p_cpf_cgc				CHAR(20),
			 	l_tip_solicitacao		LIKE VDP_NUM_DOCUM.tip_solicitacao, 
			 	l_especie_docum			LIKE VDP_NUM_DOCUM.especie_docum,	
			 	l_desconto				LIKE FAT_NF_MESTRE.VAL_DESC_NF,
			 	l_desconto_item			LIKE FAT_NF_MESTRE.VAL_DESC_NF,
			 	l_val_item				LIKE FAT_NF_ITEM.VAL_BRUTO_ITEM,
				l_val_primeiro_item		LIKE FAT_NF_ITEM.VAL_BRUTO_ITEM,
			 	l_acrescimo				LIKE FAT_NF_MESTRE.VAL_ACRE_NF,
			 	l_msg 					CHAR(250),
			 	l_texto					CHAR(300),
				p_cod					SMALLINT,
				l_cont					SMALLINT,
				l_qtd_item				DECIMAL(17,6),
				l_transac				INTEGER,
                l_val_pis_rec           DECIMAL(17,2),
				l_val_cofins_rec        DECIMAL(17,2),
				l_cod_fiscal			INTEGER

			
				
				
			 	
			 	
	#adiciona o cliente
	LET p_houve_erro = FALSE 
	
	IF NOT  POL0934_gerencia_cliente() THEN 
		LET p_houve_erro =  TRUE
	END IF 
	
	LET p_cont = 0
	WHENEVER ERROR CONTINUE 
	DECLARE cq_fatura CURSOR WITH HOLD FOR 	SELECT * FROM t_fatura_codesp
	FOREACH cq_fatura INTO p_fatura_codesp.cod_empresa,
													p_fatura_codesp.num_docum,
													p_fatura_codesp.especie,
													p_fatura_codesp.cod_cliente,
													p_fatura_codesp.data_emissao,
													p_fatura_codesp.data_vencto,
													p_fatura_converte.val_tot_nff,
													p_fatura_converte.val_duplicata,
													p_fatura_codesp.num_boleto,
													p_fatura_codesp.ies_situacao,
												#	p_fatura_codesp.dat_cancel,
													p_fatura_codesp.texto_fatura
	
	
		LET p_cont = p_cont+1 
		IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("SELECT","T_FATURA_CODESP")
				CALL pol0934_imprime_erros(log0030_txt_err_sql("SELECT","T_FATURA_CODESP"))
				LET p_houve_erro = TRUE 
			END IF
		SELECT COUNT(num_docum)
		INTO l_cont
		FROM rel_fat_nfs_codesp
		WHERE cod_empresa = p_fatura_codesp.cod_empresa
		AND num_docum = p_fatura_codesp.num_docum

		SELECT COUNT(EMPRESA) 
		INTO l_transac
		FROM FAT_NF_MESTRE
		WHERE EMPRESA = p_cod_empresa
		AND TRANS_NOTA_FISCAL = (
		SELECT NUM_TRANSAC
		FROM REL_FAT_NFS_CODESP
		WHERE COD_EMPRESA = p_cod_empresa
		AND NUM_DOCUM = p_fatura_codesp.num_docum
		)
		IF l_transac IS NULL THEN
			LET l_transac	= 0
		END IF 
		
		IF l_transac = 0  THEN 
			
			#TRANFORMA CODIGO DA EMPRESA EM DOIS DIGITOS
			#LET p_empresa = p_fatura_codesp.cod_empresa
			#converte os valores da fatura
			CALL pol0934_converte_valores_nota()
			#identifica zona franca
			SELECT ies_zona_franca
			INTO p_zona_franca 
			FROM clientes
			WHERE cod_cliente  =p_fatura_codesp.cod_cliente
				IF SQLCA.SQLCODE <> 0 THEN
					IF p_cliente_codesp.estado = 'AM' THEN
						LET p_zona_franca = 'S'
					ELSE
						LET p_zona_franca = 'N'
					END IF 
				END IF 
		
			#inserindo a fatura
			
			SELECT TIP_SOLICITACAO, ESPECIE_DOCUM 
			INTO l_tip_solicitacao, l_especie_docum
			FROM VDP_NUM_DOCUM
			WHERE EMPRESA =p_cod_empresa
			AND SERIE_DOCUM =1
			AND TIP_SOLICITACAO='SOLPRDSV'
			
			IF SQLCA.SQLCODE<> 0 THEN 
				CALL log003_err_sql('SELECT','VDP_NUM_DOCUM')
				LET l_msg = log0030_txt_err_sql("SELECT","VDP_NUM_DOCUM"),
										"NÃO EXISTE NENHUM REGISTRO CADASTRADO PARA EMPRESA ",p_cod_empresa," SERIE 1"
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
			
			#LET p_cliente	='0', p_fatura_codesp.cod_cliente
			INSERT INTO FAT_NF_MESTRE 
	{1}			(EMPRESA, TIP_NOTA_FISCAL, SERIE_NOTA_FISCAL, SUBSERIE_NF, 
	{2}			ESPC_NOTA_FISCAL, NOTA_FISCAL, STATUS_NOTA_FISCAL, 
	{3}			MODELO_NOTA_FISCAL, ORIGEM_NOTA_FISCAL, TIP_PROCESSAMENTO, 
	{4}			SIT_NOTA_FISCAL, CLIENTE, REMETENT, ZONA_FRANCA, 
	{5}			NATUREZA_OPERACAO, FINALIDADE, COND_PAGTO, TIP_CARTEIRA, 
	{6}			IND_DESPESA_FINANC, MOEDA, PLANO_VENDA, TRANSPORTADORA, 
	{7}			TIP_FRETE, PLACA_VEICULO, ESTADO_PLACA_VEIC, PLACA_CARRETA_1, 
	{8}			ESTADO_PLAC_CARR_1, PLACA_CARRETA_2, ESTADO_PLAC_CARR_2, 
	{9}			TABELA_FRETE, SEQ_TABELA_FRETE, SEQUENCIA_FAIXA, VIA_TRANSPORTE, 
	{10}			PESO_LIQUIDO, PESO_BRUTO, PESO_TARA, NUM_PRIM_VOLUME, VOLUME_CUBICO, 
	{11}			USU_INCL_NF, DAT_HOR_EMISSAO, DAT_HOR_SAIDA, DAT_HOR_ENTREGA, 
	{12}			CONTATO_ENTREGA, DAT_HOR_CANCEL, MOTIVO_CANCEL, USU_CANC_NF, 
	{13}			SIT_IMPRESSAO, VAL_FRETE_RODOV, VAL_SEGURO_RODOV, VAL_FRET_CONSIG, 
	{14}			VAL_SEGR_CONSIG, VAL_FRETE_CLIENTE, VAL_SEGURO_CLIENTE, VAL_DESC_MERC, 
	{15}			VAL_DESC_NF, VAL_DESC_DUPLICATA, VAL_ACRE_MERC, VAL_ACRE_NF, 
	{16}			VAL_ACRE_DUPLICATA, VAL_MERCADORIA, VAL_DUPLICATA, VAL_NOTA_FISCAL, TIP_VENDA)
			VALUES  
	{1}			(p_fatura_codesp.cod_empresa,l_tip_solicitacao,1,0,
	{2}			l_especie_docum,p_fatura_codesp.num_docum,'S',			
	{3}			'55','M','M',
	{4}			p_fatura_codesp.ies_situacao,p_fatura_codesp.cod_cliente,' ',p_zona_franca, 
	{5}			p_parametro.natureza_operacao,p_parametro.finalidade,p_parametro.COND_PAGTO,p_parametro.TIP_CARTEIRA,
	{6}			1,p_parametro.moeda,'N',NULL,
	{7}			3,NULL,NULL,NULL,
	{8}			NULL,NULL,NULL,
	{9}			NULL,NULL,NULL,NULL,
	{10}			0,0,0,0,0,
	{11}			p_user,p_fatura_codesp.data_emissao{p_fatura_codesp.dataCURRENT},NULL,NULL,
	{12}			NULL,NULL {p_fatura_codesp.dat_cancel},NULL,NULL,
	{13}			'N',0,0,0,
	{14}			0,0,0,0,
	{15}			0,0,0,0,
	{16}			0,p_fatura_codesp.val_tot_nff{val_mercadoria},p_fatura_codesp.val_duplicata,p_fatura_codesp.val_tot_nff, p_parametro.TIPO_VENDA
				)
				
				{numero do boleto, dat_vencimento sobrou}
			#LET p_trans_nota_fiscal = SQLCA.SQLERRD[2] #vai retornar a transação da nota
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql('INSERT','FAT_NF_MESTRE')
				LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql(  )
				CALL pol0934_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_MESTRE"))
				LET p_houve_erro =  TRUE
			ELSE
				SELECT MAX(trans_nota_fiscal)
				INTO p_trans_nota_fiscal
				FROM FAT_NF_MESTRE
				WHERE EMPRESA=p_cod_empresa
			END IF
			
			IF l_cont > 0 THEN 
				UPDATE rel_fat_nfs_codesp
				SET NUM_TRANSAC =  p_trans_nota_fiscal
				WHERE cod_empresa = p_fatura_codesp.cod_empresa
				AND num_docum = p_fatura_codesp.num_docum
			END IF 
		
	    INITIALIZE l_desconto TO NULL 
	    LET l_val_item = 0
	    LET l_qtd_item = 0
		LET l_val_primeiro_item = 0
			# INSERIR os itens
			DECLARE cq_item_fiscal CURSOR WITH HOLD FOR SELECT * 
																									FROM t_itens_fatura_codesp
																									WHERE cod_empresa = p_fatura_codesp.cod_empresa
																									AND num_docum = p_fatura_codesp.num_docum
																									AND especie = p_fatura_codesp.especie #voltar
			FOREACH cq_item_fiscal INTO p_itens_fatura_codesp.cod_empresa,
																	p_itens_fatura_codesp.num_docum,
																	p_itens_fatura_codesp.especie,
																	p_itens_fatura_codesp.cod_cliente,
																	p_itens_fatura_codesp.sequencia,
																	p_itens_fatura_codesp.cod_item,
																	p_itens_fatura_codesp.den_item,
																	p_item_converte.qtd_item,
																	p_itens_fatura_codesp.unidade_medida,
																	p_item_converte.pre_unit,
																	p_item_converte.val_liq_item,
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
																	p_item_converte.val_pis
	
			
				IF SQLCA.SQLCODE<> 0 THEN
					CALL log003_err_sql("SELECT","T_ITENS_FATURA_CODESP")
					LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "SELECT","T_ITENS_FATURA_CODESP" )
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
				END IF
			
				#converte os valores do item
				CALL pol0934_converte_valores_Item()
				#convertendo a unidade de medida para maiuscula
				LET p_itens_fatura_codesp.unidade_medida = UPSHIFT(p_itens_fatura_codesp.unidade_medida) 
				#adcionando o preço da tributação do icms ao preço unitario do produto
##				LET p_itens_fatura_codesp.pre_unit = p_itens_fatura_codesp.pre_unit /(1-(p_itens_fatura_codesp.pct_icms/100))
				LET p_itens_fatura_codesp.pre_unit = p_itens_fatura_codesp.val_liq_item /p_itens_fatura_codesp.qtd_item
				LET p_itens_fatura_codesp.val_liq_item  =  p_itens_fatura_codesp.pre_unit *  p_itens_fatura_codesp.qtd_item
				#soma valor dos items
				
				IF l_val_item  = 0 THEN 
				   let l_val_primeiro_item = p_itens_fatura_codesp.val_liq_item
				END IF 
				
				LET l_val_item = l_val_item + p_itens_fatura_codesp.val_liq_item
				#soma os impostos a serem descontados da nota
				LET l_desconto = p_itens_fatura_codesp.val_irpj + p_itens_fatura_codesp.val_pis +
													p_itens_fatura_codesp.val_csll + p_itens_fatura_codesp.val_cofins 
				#desconto do item
				
				
				INITIALIZE l_desconto_item TO NULL
				LET l_desconto_item = p_itens_fatura_codesp.val_irpj + p_itens_fatura_codesp.val_pis +
																p_itens_fatura_codesp.val_csll + p_itens_fatura_codesp.val_cofins
				IF p_itens_fatura_codesp.pct_cofins = 0 AND p_itens_fatura_codesp.pct_csll= 0 AND 
				  p_itens_fatura_codesp.pct_irpj= 0 AND p_itens_fatura_codesp.pct_pis= 0 THEN 
				  LET 	p_natureza_operacao = p_parametro.nat_oper_nao_trib
				  	
				ELSE
					LET p_natureza_operacao = p_parametro.natureza_operacao
				END IF
				
				IF p_itens_fatura_codesp.qtd_item = 0 THEN 
				   LET p_itens_fatura_codesp.qtd_item = 1
				END IF				
				
				LET l_qtd_item = l_qtd_item + p_itens_fatura_codesp.qtd_item
				
				INSERT INTO FAT_NF_ITEM 
					(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, PEDIDO,		SEQ_ITEM_PEDIDO,
					ORD_MONTAG, TIP_ITEM, ITEM, DES_ITEM, UNID_MEDIDA,PESO_UNIT, QTD_ITEM, 
					FATOR_CONV, LISTA_PRECO, VERSAO_LISTA_PRECO,TIP_PRECO, NATUREZA_OPERACAO,
					CLASSIF_FISC, ITEM_PROD_SERVICO,PRECO_UNIT_BRUTO, PRE_UNI_DESC_INCND, 
					PRECO_UNIT_LIQUIDO,PCT_FRETE, VAL_DESC_ITEM, VAL_DESC_MERC, VAL_DESC_CONTAB, 
					VAL_DESC_DUPLICATA, VAL_ACRESC_ITEM, VAL_ACRE_MERC, VAL_ACRESC_CONTAB, 
					VAL_ACRE_DUPLICATA, VAL_FRET_CONSIG, VAL_SEGR_CONSIG, VAL_FRETE_CLIENTE, 
					VAL_SEGURO_CLIENTE, VAL_BRUTO_ITEM, VAL_BRT_DESC_INCND, VAL_LIQUIDO_ITEM, 
					VAL_MERC_ITEM, val_duplicata_ITEM, VAL_CONTAB_ITEM) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia,0,p_itens_fatura_codesp.sequencia
					,0,'N',p_itens_fatura_codesp.cod_item,p_itens_fatura_codesp.den_item,p_itens_fatura_codesp.unidade_medida,1,p_itens_fatura_codesp.qtd_item
					,1,NULL,NULL,p_parametro.tipo_preco,p_natureza_operacao,
					p_parametro.clas_fiscal,p_parametro.item_prod,p_itens_fatura_codesp.pre_unit,p_itens_fatura_codesp.pre_unit,
					p_itens_fatura_codesp.pre_unit,0,0,0,0,
					0,0,0,0,
					0,0,0,0,
					0,p_itens_fatura_codesp.val_liq_item,p_itens_fatura_codesp.val_liq_item,p_itens_fatura_codesp.val_liq_item,
					p_itens_fatura_codesp.val_liq_item,p_fatura_codesp.val_tot_nff,p_itens_fatura_codesp.val_liq_item	
					)
				IF SQLCA.SQLCODE<>0 THEN
					CALL log003_err_sql('INSERT','FAT_NF_ITEM ')
					LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_NF_ITEM" )
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
				END IF 
				#tributos relacionados ao item
				#ICMS
				CALL pol0934_trib_benef('ICMS') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
				LET l_cod_fiscal = p_cod_fiscal 
				IF (p_itens_fatura_codesp.val_tot_icms IS NOT NULL) AND (p_itens_fatura_codesp.val_tot_base_icms IS NOT NULL)
						AND (p_itens_fatura_codesp.pct_icms IS NOT NULL ) THEN 
					INSERT INTO FAT_NF_ITEM_FISC 
						(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
						BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
						VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
						ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
						SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
						DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
						PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
						PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
						PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
					VALUES
						(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "ICMS",p_trans_config ,
						p_itens_fatura_codesp.val_tot_base_icms,0,0,p_itens_fatura_codesp.val_tot_base_icms,
						p_itens_fatura_codesp.val_tot_icms,0,0,p_itens_fatura_codesp.val_tot_icms,
						p_acresc_desc,NULL,p_incide,p_origem_produto,p_tributacao,NULL, # alterado o campo acres_desc tem que ter o valor P
						NULL,NULL,NULL,p_cod_fiscal,NULL,
						NULL,p_itens_fatura_codesp.pct_icms,NULL,NULL,NULL,
						NULL,0,NULL,NULL,
						NULL,NULL,NULL,NULL,
						NULL,NULL,NULL)
					IF SQLCA.SQLCODE<>0 THEN
						CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
						LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_NF_ITEM_FISC" )
						CALL pol0934_imprime_erros(l_msg)
						LET p_houve_erro =  TRUE
					END IF
					
					INSERT INTO FAT_MESTRE_FISCAL 
						(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
						BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
						VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
					VALUES
						(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,'ICMS',p_itens_fatura_codesp.val_tot_base_icms,
						0,0,p_itens_fatura_codesp.val_tot_base_icms,p_itens_fatura_codesp.val_tot_icms,
						0,0,p_itens_fatura_codesp.val_tot_icms)
					IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
							UPDATE FAT_MESTRE_FISCAL
								SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_tot_base_icms,
								BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_tot_base_icms,
								VAL_TRIB_MERC = VAL_TRIB_MERC +p_itens_fatura_codesp.val_tot_icms,
								VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + p_itens_fatura_codesp.val_tot_icms
								
							WHERE EMPRESA = p_fatura_codesp.cod_empresa
							AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
						#ELSE 
							IF SQLCA.SQLCODE <> 0  THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_MESTRE_FISCAL" )
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						#END IF 
					END IF 
				END IF  
				#IRPJ
				IF p_itens_fatura_codesp.pct_irpj > 0 THEN 
					CALL pol0934_trib_benef('IRRF_RET') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF (p_itens_fatura_codesp.val_irpj IS NOT NULL) AND (p_itens_fatura_codesp.val_base_irpj IS NOT NULL)
							AND (p_itens_fatura_codesp.pct_irpj IS NOT NULL ) THEN 
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "IRRF_RET",p_trans_config,
							p_itens_fatura_codesp.val_base_irpj,0,0,p_itens_fatura_codesp.val_base_irpj,
							p_itens_fatura_codesp.val_irpj,0,0,p_itens_fatura_codesp.val_irpj,
							'D','N',p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_itens_fatura_codesp.pct_irpj,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_NF_ITEM_FISC" )
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF 
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"IRRF_RET",p_itens_fatura_codesp.val_base_irpj,
							0,0,p_itens_fatura_codesp.val_base_irpj,p_itens_fatura_codesp.val_irpj,
							0,0,(p_itens_fatura_codesp.val_irpj))
						IF SQLCA.SQLCODE<>0 THEN
						#	IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_base_irpj,
									BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_base_irpj,
									VAL_TRIB_MERC = VAL_TRIB_MERC + p_itens_fatura_codesp.val_irpj ,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + (p_itens_fatura_codesp.val_irpj)
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_MESTRE_FISCAL" )
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					END IF
				END IF  
				#CSLL
				IF p_itens_fatura_codesp.pct_csll >0 THEN 
					CALL pol0934_trib_benef('CSLL_RET') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF (p_itens_fatura_codesp.val_csll IS NOT NULL) AND (p_itens_fatura_codesp.val_base_csll IS NOT NULL)
							AND (p_itens_fatura_codesp.pct_csll IS NOT NULL ) THEN 
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "CSLL_RET",p_trans_config,
							p_itens_fatura_codesp.val_base_csll,0,0,p_itens_fatura_codesp.val_base_csll,
							p_itens_fatura_codesp.val_csll,0,0,p_itens_fatura_codesp.val_csll,
							'D','N',p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_itens_fatura_codesp.pct_csll,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_NF_ITEM_FISC" )
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"CSLL_RET",p_itens_fatura_codesp.val_base_csll,
							0,0,p_itens_fatura_codesp.val_base_csll ,p_itens_fatura_codesp.val_csll,
							0,0,p_itens_fatura_codesp.val_csll)
						IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_base_csll,
									BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_base_csll,
									VAL_TRIB_MERC = VAL_TRIB_MERC + p_itens_fatura_codesp.val_csll,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + p_itens_fatura_codesp.val_csll
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
								AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_MESTRE_FISCAL" )
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					END IF 
				END IF 
				#COFINS RET
				IF p_itens_fatura_codesp.pct_cofins >0 THEN 
					CALL pol0934_trib_benef('COFINS_RET') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF (p_itens_fatura_codesp.val_cofins IS NOT NULL) AND (p_itens_fatura_codesp.val_base_cofins IS NOT NULL)
							AND (p_itens_fatura_codesp.pct_cofins IS NOT NULL ) THEN 
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "COFINS_RET",p_trans_config,
							p_itens_fatura_codesp.val_base_cofins,0,0,p_itens_fatura_codesp.val_base_cofins,
							p_itens_fatura_codesp.val_cofins,0,0,p_itens_fatura_codesp.val_cofins,
							'D','N',p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_itens_fatura_codesp.pct_cofins,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_NF_ITEM_FISC" )
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"COFINS_RET",p_itens_fatura_codesp.val_base_cofins,
							0,0,p_itens_fatura_codesp.val_base_cofins ,p_itens_fatura_codesp.val_cofins,
							0,0,p_itens_fatura_codesp.val_cofins)
						IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_base_cofins,
									VAL_TRIB_MERC = VAL_TRIB_MERC + p_itens_fatura_codesp.val_cofins,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + p_itens_fatura_codesp.val_cofins
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
								AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_MESTRE_FISCAL"  )
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					END IF 
				END IF
				#COFINS_REC
				    LET p_aliquota = 0 
					LET p_incide = 'N'
					CALL pol0934_trib_benef('COFINS_REC') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF p_incide =  'S'  THEN 
					    LET l_val_cofins_rec = p_itens_fatura_codesp.val_liq_item * (p_aliquota/100)
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "COFINS_REC",p_trans_config,
							p_itens_fatura_codesp.val_liq_item,0,0,p_itens_fatura_codesp.val_liq_item,
							l_val_cofins_rec,0,0,l_val_cofins_rec,
							p_acresc_desc,NULL,p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_aliquota,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA COFINS_REC", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_NF_ITEM_FISC")
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"COFINS_REC",p_itens_fatura_codesp.val_liq_item,
							0,0,p_itens_fatura_codesp.val_liq_item ,l_val_cofins_rec,
							0,0,l_val_cofins_rec)
						IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_liq_item,
									BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_liq_item,
									VAL_TRIB_MERC = VAL_TRIB_MERC + l_val_cofins_rec,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + l_val_cofins_rec
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
								AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA COFINS_REC", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_MESTRE_FISCAL")
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					END IF
				#PIS_RET
				IF p_itens_fatura_codesp.pct_pis>0 THEN 
					CALL pol0934_trib_benef('PIS_RET') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF (p_itens_fatura_codesp.val_pis IS NOT NULL) AND (p_itens_fatura_codesp.val_base_pis IS NOT NULL)
							AND (p_itens_fatura_codesp.pct_pis IS NOT NULL ) THEN 
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "PIS_RET",p_trans_config,
							p_itens_fatura_codesp.val_base_pis,0,0,p_itens_fatura_codesp.val_base_pis,
							p_itens_fatura_codesp.val_pis,0,0,p_itens_fatura_codesp.val_pis,
							'D','N',p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_itens_fatura_codesp.pct_pis,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_NF_ITEM_FISC")
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"PIS_RET",p_itens_fatura_codesp.val_base_pis,
							0,0,p_itens_fatura_codesp.val_base_pis ,p_itens_fatura_codesp.val_pis,
							0,0,p_itens_fatura_codesp.val_pis)
						IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_base_pis,
									BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_base_pis,
									VAL_TRIB_MERC = VAL_TRIB_MERC + p_itens_fatura_codesp.val_pis,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + p_itens_fatura_codesp.val_pis
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
								AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_MESTRE_FISCAL")
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					END IF 
				END IF	
					
				#PIS_REC
				    LET p_aliquota = 0 
					LET p_incide = 'N'
					CALL pol0934_trib_benef('PIS_REC') RETURNING p_trans_config,p_incide,p_cod_fiscal, p_aliquota,p_acresc_desc,p_origem_produto,p_tributacao
					IF p_incide =  'S'  THEN 
					    LET l_val_pis_rec = p_itens_fatura_codesp.val_liq_item * (p_aliquota/100)
						INSERT INTO FAT_NF_ITEM_FISC 
							(EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, TRIBUTO_BENEF, TRANS_CONFIG, 
							BC_TRIB_MERCADORIA, BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT, 
							VAL_TRIB_MERC, VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT, 
							ACRESC_DESC, APLICACAO_VAL, INCIDE, ORIGEM_PRODUTO, TRIBUTACAO, HIST_FISCAL, 
							SIT_TRIBUTO, MOTIVO_RETENCAO, RETENCAO_CRE_VDP, COD_FISCAL, INSCRICAO_ESTADUAL, 
							DIPAM_B, ALIQUOTA, VAL_UNIT, PRE_UNI_MERCADORIA, PCT_APLICACAO_BASE, 
							PCT_ACRE_BAS_CALC, PCT_RED_BAS_CALC, PCT_DIFERIDO_BASE, PCT_DIFERIDO_VAL, 
							PCT_ACRESC_VAL, PCT_REDUCAO_VAL, PCT_MARGEM_LUCRO, PCT_ACRE_MARG_LUCR, 
							PCT_RED_MARG_LUCRO, TAXA_REDUCAO_PCT, TAXA_ACRESC_PCT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,p_itens_fatura_codesp.sequencia, "PIS_REC",p_trans_config,
							p_itens_fatura_codesp.val_liq_item,0,0,p_itens_fatura_codesp.val_liq_item,
							l_val_pis_rec,0,0,l_val_pis_rec,
							p_acresc_desc,NULL,p_incide,p_origem_produto,p_tributacao,NULL,
							NULL,NULL,NULL,l_cod_fiscal,NULL,
							NULL,p_aliquota,NULL,NULL,NULL,
							NULL,0,NULL,NULL,
							NULL,NULL,NULL,NULL,
							NULL,NULL,NULL)
						IF SQLCA.SQLCODE<>0 THEN
							CALL log003_err_sql('INSERT','FAT_NF_ITEM_FISC')
							LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA PIS_REC", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_NF_ITEM_FISC")
							CALL pol0934_imprime_erros(l_msg)
							LET p_houve_erro =  TRUE
						END IF
						INSERT INTO FAT_MESTRE_FISCAL 
							(EMPRESA, TRANS_NOTA_FISCAL, TRIBUTO_BENEF,BC_TRIB_MERCADORIA, 
							BC_TRIBUTO_FRETE, BC_TRIB_CALCULADO, BC_TRIBUTO_TOT,VAL_TRIB_MERC, 
							VAL_TRIBUTO_FRETE, VAL_TRIB_CALCULADO, VAL_TRIBUTO_TOT) 
						VALUES
							(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,"PIS_REC",p_itens_fatura_codesp.val_liq_item,
							0,0,p_itens_fatura_codesp.val_liq_item ,l_val_pis_rec,
							0,0,l_val_pis_rec)
						IF SQLCA.SQLCODE<>0 THEN
							#IF SQLCA.SQLCODE = 268 THEN 
								UPDATE FAT_MESTRE_FISCAL
									SET BC_TRIBUTO_TOT = BC_TRIBUTO_TOT + p_itens_fatura_codesp.val_liq_item,
									BC_TRIB_MERCADORIA = BC_TRIB_MERCADORIA + p_itens_fatura_codesp.val_liq_item,
									VAL_TRIB_MERC = VAL_TRIB_MERC + l_val_pis_rec,
									VAL_TRIBUTO_TOT = VAL_TRIBUTO_TOT + l_val_pis_rec
								WHERE EMPRESA = p_fatura_codesp.cod_empresa
								AND TRANS_NOTA_FISCAL= p_trans_nota_fiscal
							#ELSE 
							IF SQLCA.SQLCODE<>0 THEN 
								CALL log003_err_sql('INSERT','FAT_MESTRE_FISCAL')
								LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA PIS_REC", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_MESTRE_FISCAL")
								CALL pol0934_imprime_erros(l_msg)
								LET p_houve_erro =  TRUE
							END IF 
						END IF
					
					
				END IF  
			END FOREACH #cq_item_fiscal
			
		LET l_acrescimo = p_fatura_codesp.val_tot_nff -  l_val_item
		
		IF l_acrescimo < 0 THEN 
		   LET l_acrescimo =  0
		END IF 
			
		UPDATE FAT_NF_MESTRE
	  	SET NATUREZA_OPERACAO = p_natureza_operacao,
	  	VAL_DESC_NF = l_desconto,
		VAL_ACRE_NF = l_acrescimo,
	  	VAL_MERCADORIA = VAL_MERCADORIA + l_desconto
	  	WHERE empresa = p_cod_empresa
	  	AND TRANS_NOTA_FISCAL =p_trans_nota_fiscal

			
		
		IF l_acrescimo > 0 THEN 
		    INSERT INTO FAT_DACRE_NF (EMPRESA, TRANS_NOTA_FISCAL, DESC_ACRE,
			SEQ_DESC_ACRE, VAL_DACRE_NF, PCT_DACRE_NF)
			VALUES(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal, '10', 1, l_acrescimo, 0)
			
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('INSERT','FAT_DACRE_NF')
				LET l_msg = "ERRO NA INCLUSAO FAT_DACRE_NF", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_DACRE_NF")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO FAT_DACRE_ITEM_NF (EMPRESA,
			  TRANS_NOTA_FISCAL, SEQ_ITEM_NF, DESC_ACRE,
			  IND_DESC_ACRE, APLIC_DESC_ACRE,
			  BAS_CALC_DESC_ACRE, PCT_DESC_ACRE, VAL_DESC_ACRE)
			  VALUES(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,1, '10', 'A','N', l_val_primeiro_item, 0, l_acrescimo)
			  
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('INSERT','FAT_DACRE_ITEM_NF')
				LET l_msg = "ERRO NA INCLUSAO FAT_DACRE_ITEM_NF", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_DACRE_ITEM_NF")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF		  

			UPDATE FAT_NF_ITEM
			SET val_acresc_contab = l_acrescimo,
			val_contab_item = val_contab_item + l_acrescimo
			WHERE empresa = p_cod_empresa
			AND TRANS_NOTA_FISCAL =p_trans_nota_fiscal
			AND SEQ_ITEM_NF  = 1
			
		END IF 
			
#Esta rotina foi comentada a pedido do Jurandir pois segundo ele essa rotida duplica o desconto no Sefaz.			
		
		IF l_desconto > 0 THEN 
{		    INSERT INTO FAT_DACRE_NF (EMPRESA, TRANS_NOTA_FISCAL, DESC_ACRE,
			SEQ_DESC_ACRE, VAL_DACRE_NF, PCT_DACRE_NF)
			VALUES(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal, '1', 1, l_desconto, 0)
			
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('INSERT','FAT_DACRE_NF 2')
				LET l_msg = "ERRO NA INCLUSAO FAT_DACRE_NF 2", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_DACRE_NF")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO FAT_DACRE_ITEM_NF (EMPRESA,
			  TRANS_NOTA_FISCAL, SEQ_ITEM_NF, DESC_ACRE,
			  IND_DESC_ACRE, APLIC_DESC_ACRE,
			  BAS_CALC_DESC_ACRE, PCT_DESC_ACRE, VAL_DESC_ACRE)
			  VALUES(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,1, '1', 'D','N', l_val_primeiro_item, 0, l_desconto)
			  
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql('INSERT','FAT_DACRE_ITEM_NF 2')
				LET l_msg = "ERRO NA INCLUSAO FAT_DACRE_ITEM_NF 2", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_DACRE_ITEM_NF")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF		 } 

			UPDATE FAT_NF_ITEM
			SET val_desc_contab = l_desconto,
			val_contab_item = val_contab_item - l_desconto
			WHERE empresa = p_cod_empresa
			AND TRANS_NOTA_FISCAL =p_trans_nota_fiscal
			AND SEQ_ITEM_NF  = 1
			
		END IF 
			
			
		LET l_val_item =l_val_item - l_desconto	
		
			IF p_natureza_operacao = 1 THEN
				LET	p_cod = 99
			ELSE
				LET p_cod = 98
			END IF 
			
					#texto com nºfatura
			IF l_qtd_item = 0 THEN 
				LET p_fatura = 'FATURA: ',p_fatura_codesp.num_docum,' VENCIMENTO: ',p_fatura_codesp.data_vencto," TAXA MINIMA "
			ELSE
				LET p_fatura = 'FATURA: ',p_fatura_codesp.num_docum,' VENCIMENTO: ',p_fatura_codesp.data_vencto
			END IF 
			INSERT INTO FAT_NF_TEXTO_HIST 
				(EMPRESA, TRANS_NOTA_FISCAL, SEQUENCIA_TEXTO, TEXTO,DES_TEXTO, TIP_TXT_NF) 
			VALUES
				(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,1,0,p_fatura,2)
			IF SQLCA.SQLCODE<> 0 THEN 
				CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
				LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql(  )
				CALL pol0934_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
				LET p_houve_erro =  TRUE
			END IF 
			#textos
			IF p_fatura_codesp.texto_fatura IS NOT NULL THEN 
				INSERT INTO FAT_NF_TEXTO_HIST 
					(EMPRESA, TRANS_NOTA_FISCAL, SEQUENCIA_TEXTO, TEXTO,DES_TEXTO, TIP_TXT_NF) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,2,0,p_fatura_codesp.texto_fatura,2)
				IF SQLCA.SQLCODE<> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql(  )
					CALL pol0934_imprime_erros(log0030_txt_err_sql("INSERT","FAT_NF_TEXTO_HIST"))
					LET p_houve_erro =  TRUE
				END IF
			END IF
				
				SELECT TEX_HIST_1|| TEX_HIST_2 || TEX_HIST_3 || TEX_HIST_4 
				INTO l_texto
				FROM FISCAL_HIST
				WHERE COD_HIST = p_cod
				
				INSERT INTO FAT_NF_TEXTO_HIST 
					(EMPRESA, TRANS_NOTA_FISCAL, SEQUENCIA_TEXTO, TEXTO,DES_TEXTO, TIP_TXT_NF) 
				VALUES
					(p_fatura_codesp.cod_empresa,p_trans_nota_fiscal,3,p_cod,l_texto,2)
				IF SQLCA.SQLCODE<> 0 THEN 
					CALL log003_err_sql('INSERT','FAT_NF_TEXTO_HIST')
					LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql( "INSERT","FAT_NF_TEXTO_HIST" )
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
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
				LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","FAT_NF_DUPLICATA" )
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF}
			
			#guardando o dados das faturas importadas para poder exportar no arquivo NFS_ddmmyyyyhhmm.txt
			IF l_cont = 0 THEN 
				INSERT INTO rel_fat_nfs_codesp
					( cod_empresa,num_docum,especie,data_emissao_fa,data_emissao_nf,num_transac)
				VALUES
					(	p_fatura_codesp.cod_empresa,	p_fatura_codesp.num_docum,p_fatura_codesp.especie,p_fatura_codesp.data_emissao,CURRENT,p_trans_nota_fiscal)
			 END IF 
			IF SQLCA.SQLCODE<>0 THEN 
				CALL log003_err_sql('INSERT','REL_FAT_NFS_CODESP')
				LET l_msg = "ERRO NA SOLICITAÇÃO DE FATURA ", p_fatura_codesp.num_docum," ",log0030_txt_err_sql("INSERT","REL_FAT_NFS_CODESP")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
		ELSE 			#TRECHO ADICIONADO PARA PULAR AS FATURAS
							#JÁ PROCESSADAS E COLOCAR NO ARQUIVO DE 
							#ERROS PARA SABER QUE JA FORAM PROCESSADAS 
							#ANTERIORMENTE
			LET l_msg = "SOLICITAÇÃO DE FATURA Nº ",p_fatura_codesp.num_docum," JÁ PROCESSSADA" 
			CALL pol0934_imprime_erros(l_msg)
		END IF  
		MESSAGE"Processando fatura Nº",p_fatura_codesp.num_docum
	END FOREACH	#cq_fatura
	IF p_houve_erro THEN 
		FINISH REPORT pol0934_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE 
	ELSE
		IF p_print THEN	
			FINISH REPORT pol0934_imprime 
			CALL log0030_mensagem("Houve a tentativa de processar solicitações já existentes!!",'info')
			MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		END IF
		RETURN TRUE 
	END IF 
END FUNCTION
	#Devido os valores vindo do aquivo texto
	#virem sem as casas decimais depois da 
	#virgula termos que fazer um tratamento
	#para colocar as virgulas
#---------------------------------------#
FUNCTION pol0934_converte_valores_nota()#
#---------------------------------------#
	LET p_fatura_codesp.val_tot_nff							=	p_fatura_converte.val_tot_nff   								/ 100 #DECIMAL(17,2),
	LET p_fatura_codesp.val_duplicata						=	p_fatura_converte.val_duplicata  								/ 100 #DECIMAL(17,2),
END FUNCTION 

#----------------------------------#
FUNCTION POL0934_gerencia_cliente()#
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
				l_index						SMALLINT
				

	DECLARE cq_cliente CURSOR FOR  SELECT  * FROM t_clientes_codesp
	FOREACH cq_cliente INTO p_cliente_codesp.*
		
		DELETE FROM vdp_cli_grp_email
		WHERE cliente = p_cliente_codesp.cod_cliente
		AND SEQ_EMAIL <=3
		AND grupo_email = 1
		
		IF SQLCA.SQLCODE <> 0 THEN
		   LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO DELETE DA TABELA VDP_CLI_GRP_EMAIL-STATUS= ", SQLCA.SQLCODE
		   CALL pol0934_imprime_erros(l_msg)
		   LET p_houve_erro =  TRUE
		END IF 
		
		IF p_cliente_codesp.Emal1 IS NOT NULL AND p_cliente_codesp.Emal1 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL VALUES (p_cliente_codesp.cod_cliente,1,1,p_cliente_codesp.Emal1, "C" )
			IF SQLCA.SQLCODE <> 0 THEN
			   LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 1 - STATUS= ", SQLCA.SQLCODE 
			   CALL pol0934_imprime_erros(l_msg)
			   LET p_houve_erro =  TRUE
			END IF 
		
			INSERT INTO VDP_CLIENTE_GRUPO VALUES (p_cliente_codesp.cod_cliente, 1,"NFE", "C" )
		END IF 			

		IF p_cliente_codesp.Emal2 IS NOT NULL AND p_cliente_codesp.Emal2 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL VALUES (p_cliente_codesp.cod_cliente,1,2,p_cliente_codesp.Emal2 , "C" )
			IF SQLCA.SQLCODE <> 0 THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 2 - STATUS= ", SQLCA.SQLCODE
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF
		
		IF p_cliente_codesp.Emal3 IS NOT NULL AND p_cliente_codesp.Emal3 <> ' ' THEN
			INSERT INTO VDP_CLI_GRP_EMAIL 	VALUES (p_cliente_codesp.cod_cliente,1,3,p_cliente_codesp.Emal3,  "C"  )
			IF SQLCA.SQLCODE <> 0 THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," ERRO NO CADASTRAMENTO DO EMAIL 3 - STATUS= ", SQLCA.SQLCODE
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF 

		
		#pegando codigo da cidade ibge passando pra logix
		SELECT cidade_logix, estado_logix
		INTO l_cidade_logix,
				 l_estado
	 	FROM obf_cidade_ibge
		WHERE cidade_ibge = p_cliente_codesp.cod_cidade
		
		IF SQLCA.SQLCODE <> 0 THEN
			IF SQLCA.SQLCODE = 100 THEN
				ERROR 'CADASTRAR O CODIGO DA CIDADE IBGE ',p_cliente_codesp.cod_cidade
			END IF 
			#CALL log003_err_sql('SELECIONAR','OBF_CIDADE_IBGE')
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED 
										,"- REGISTRO ",p_cliente_codesp.cod_cidade," - CADASTRAR NO PROGRAMA VDP9113"
										
			CALL pol0934_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE 
		END IF
		 
		IF p_cliente_codesp.den_bairro IS NULL THEN 
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM BAIRRO CADASTRADO"
			CALL pol0934_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
		ELSE
			IF p_cliente_codesp.den_bairro ="null" OR p_cliente_codesp.den_bairro ="Null"
				OR p_cliente_codesp.den_bairro ="NULL" THEN
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM BAIRRO CADASTRADO"
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
		END IF 
		
		LET p_tem_virgula = 0		
		
		SELECT  count(*) 
		INTO    p_tem_virgula 
		FROM    t_clientes_codesp
		WHERE    cod_cliente = p_cliente_codesp.cod_cliente
		AND      end_cliente   like '%,%'  
		
		IF p_tem_virgula = 0 THEN 
			LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED," NAO TEM VIRGULA NO ENDERECO"
			CALL pol0934_imprime_erros(l_msg)
			LET p_houve_erro =  TRUE
		END IF 

		IF l_estado = "AM" THEN
			LET l_zona_franca= 'S'
		ELSE
			LET l_zona_franca= 'N'
		END IF
		#definido mascara do cnpj_cpf do cliente
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
			#CALL log0030_mensagem(l_cpf_cgc,'')
		END IF 
		#coloca a mascara no cep
		LET p_cliente_codesp.cod_cep = p_cliente_codesp.cod_cep[1,5],'-',p_cliente_codesp.cod_cep[6,8]
		
		SELECT COUNT(*)
		INTO l_cont
		FROM clientes
		WHERE cod_cliente = l_cliente
		
		
		IF p_cliente_codesp.nom_reduzido  IS NULL oR p_cliente_codesp.nom_reduzido  = ' ' THEN 
		     LET p_cliente_codesp.nom_reduzido = p_cliente_codesp.nom_cliente[1,15]
		END IF 	 
				
		IF l_cont > 0 THEN
			UPDATE clientes
					
				SET nom_cliente			=	p_cliente_codesp.nom_cliente[1,35],			
					nom_reduzido		=	p_cliente_codesp.nom_reduzido	,
					end_cliente			=	p_cliente_codesp.end_cliente,		
					den_bairro			=	p_cliente_codesp.den_bairro,
					#cidade					=	p_cliente_codesp.cidade					
					cod_cidade			=	l_cidade_logix		,
					cod_cep					=	p_cliente_codesp.cod_cep,	
					cod_praca			=	'0',									
					num_telefone		=	p_cliente_codesp.telefone,
					num_fax					=	p_cliente_codesp.num_fax,	
					dat_atualiz			= CURRENT, 
					ins_estadual		=	p_cliente_codesp.ins_estadual
			WHERE cod_cliente			=	l_cliente
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("ATUALIZAR","CLIENTES")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("ATUALIZAR","CLIENTES")
				CALL pol0934_imprime_erros()
				LET p_houve_erro =  TRUE
			END IF 
			INSERT INTO VDP_CLI_FORNEC_CPL 
						(CLIENTE_FORNECEDOR, TIP_CADASTRO, RAZAO_SOCIAL, RAZAO_SOCIAL_REDUZ, 
						BAIRRO, CORREIO_ELETRONICO, CORREI_ELETR_SECD, CORREI_ELETR_VENDA, 
						ENDERECO_WEB, TELEFONE_1, TELEFONE_2, COMPL_ENDERECO, TIP_LOGRADOURO, 
						LOGRADOURO, NUM_IDEN_LOGRAD) 
			VALUES(l_cliente, 'C', p_cliente_codesp.nom_cliente,p_cliente_codesp.nom_reduzido, 
						p_cliente_codesp.den_bairro, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			IF SQLCA.SQLCODE<> 0 THEN
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
			END IF 
		ELSE 
			INSERT INTO clientes
				(cod_cliente,cod_class,nom_cliente,nom_reduzido,end_cliente,den_bairro,
				cod_cidade,cod_cep,num_telefone,num_fax,ins_estadual,num_cgc_cpf,
				cod_tip_cli,ies_cli_forn,ies_zona_franca,ies_situacao,cod_rota,cod_praca, 
				dat_cadastro,	dat_atualiz,cod_local)
			VALUES 
				(l_cliente,'A',p_cliente_codesp.nom_cliente[1,35],p_cliente_codesp.nom_reduzido,p_cliente_codesp.end_cliente,p_cliente_codesp.den_bairro,
				l_cidade_logix,p_cliente_codesp.cod_cep,p_cliente_codesp.telefone,p_cliente_codesp.num_fax,p_cliente_codesp.ins_estadual,l_cpf_cgc,
				p_cliente_codesp.tipo_cliente,'C',l_zona_franca,'A','0','0',
				CURRENT,CURRENT,'0')
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CLIENTES")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CLIENTES")
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
			
			INSERT INTO VDP_CLIENTE_COMPL (CLIENTE, EMAIL, EMAIL_SECUND, ENDERECO_WEB) 
			VALUES(l_cliente, NULL, NULL,NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","VDP_CLIENTE_COMPL")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","VDP_CLIENTE_COMPL")				
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
			FOR l_cont = 1 TO 5
				CASE 																											 
					WHEN l_cont = 1
						LET l_parametro				= 'ins_municipal'
						LET l_des_parametro		= 'Inscricao Municipal'
						LET l_tip_parametro		=	NULL
					WHEN l_cont = 2
						LET l_parametro				= 'dat_validade_suframa'
						LET l_des_parametro		= 'Data de Validade do Suframa'
						LET l_tip_parametro		=	NULL
					WHEN l_cont = 3
						LET l_parametro				= 'microempresa'
						LET l_des_parametro		= 'INDICADOR SE O CLIENTE EH OU NAO MICROEMPRESA'
						LET l_tip_parametro		=	'N'
					WHEN l_cont = 4
						LET l_parametro				= 'ies_depositante'
						LET l_des_parametro		= 'Indica se o cadastro é um depositante'
						LET l_tip_parametro		=	NULL
					WHEN l_cont = 5
						LET l_parametro				= 'celular'
						LET l_des_parametro		= 'CELULAR DO CLIENTE'
						LET l_tip_parametro		=	NULL
				END CASE 
				INSERT INTO VDP_CLI_PARAMETRO 
						(CLIENTE, PARAMETRO, DES_PARAMETRO, TIP_PARAMETRO, TEXTO_PARAMETRO, 
						VAL_PARAMETRO, NUM_PARAMETRO, DAT_PARAMETRO) 
				VALUES(l_cliente, l_parametro, l_des_parametro, l_tip_parametro, NULL, NULL, NULL, NULL)
				IF SQLCA.SQLCODE<> 0 THEN
					CALL log003_err_sql("INSERT","VDP_CLI_PARAMETRO")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","VDP_CLI_PARAMETRO")								
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
				END IF 
			END FOR 
			
			SELECT COUNT(*)
			INTO l_cont 
			FROM CLI_CANAL_VENDA
			WHERE COD_CLIENTE = l_cliente
			AND COD_TIP_CARTEIRA= p_parametro.tip_carteira
			
			IF l_cont = 0 THEN 
				INSERT INTO CLI_CANAL_VENDA VALUES(l_cliente,99,1,0,0,0,0,0,02,p_parametro.tip_carteira)
				IF SQLCA.SQLCODE<> 0 THEN
					CALL log003_err_sql("INSERT","CLI_CANAL_VENDA")
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CLI_CANAL_VENDA")																		
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
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
					LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CLI_DIST_GEOG")								
					CALL pol0934_imprime_erros(l_msg)
					LET p_houve_erro =  TRUE
				END IF
			END IF 
			
			INSERT INTO VDP_CLI_FORNEC_CPL 
						(CLIENTE_FORNECEDOR, TIP_CADASTRO, RAZAO_SOCIAL, RAZAO_SOCIAL_REDUZ, 
						BAIRRO, CORREIO_ELETRONICO, CORREI_ELETR_SECD, CORREI_ELETR_VENDA, 
						ENDERECO_WEB, TELEFONE_1, TELEFONE_2, COMPL_ENDERECO, TIP_LOGRADOURO, 
						LOGRADOURO, NUM_IDEN_LOGRAD) 
			VALUES(l_cliente, 'C', p_cliente_codesp.nom_cliente,p_cliente_codesp.nom_reduzido, 
						p_cliente_codesp.den_bairro, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","VDP_CLI_FORNEC_CPL")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","VDP_CLI_FORNEC_CPL")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF 
			
			LET l_text_aux = 'CLIENTE ',l_cliente
			LET l_hora = CURRENT 
			INSERT INTO AUDIT_LOGIX (COD_EMPRESA, TEXTO, NUM_PROGRAMA, DATA, HORA, USUARIO) 
			VALUES(p_cod_empresa,l_text_aux,'POL0934',CURRENT , l_hora[12,16] , p_user)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","AUDIT_LOGIX")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","AUDIT_LOGIX")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CLI_CREDITO (COD_CLIENTE, QTD_DIAS_ATR_DUPL, QTD_DIAS_ATR_MED, 
															VAL_PED_CARTEIRA, VAL_DUP_ABERTO, DAT_ULT_FAT, 
															VAL_LIMITE_CRED, DAT_VAL_LMT_CR, IES_NOTA_DEBITO, DAT_ATUALIZ) 
			VALUES(l_cliente, 0, 0, 0, 0, NULL, 0, NULL, 'N',CURRENT )
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CLI_CREDITO")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CLI_CREDITO")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CLIENTE_ALTER (COD_CLIENTE) VALUES(l_cliente)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CLIENTE_ALTER")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CLIENTE_ALTER")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CREDCAD_CLI 
			VALUES(l_cliente, 0, NULL, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 0, NULL,
				0, 0, 0, NULL, 0, NULL, 0, 0, 0, 0, 0, 0, NULL, 0, NULL, 0, NULL, NULL, 'N', NULL, NULL, 'N', 'N', 'S', 0, 'N', NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CREDCAD_CLI")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CREDCAD_CLI")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CREDCAD_CGC 
			VALUES(l_cpf_cgc[1,11], 0, NULL,0,NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,0,0
    ,NULL,0,NULL,0,0,0,0,0,0,NULL,0,NULL,0,NULL,NULL,'N','N','N','S',0,'N',NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CREDCAD_CGC")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CREDCAD_CGC")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CREDCAD_RATEIO 
			VALUES(l_cpf_cgc[1,11], l_cliente, 0, NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CREDCAD_RATEIO")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CREDCAD_RATEIO")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			
			INSERT INTO CREDCAD_COD_CLI 
			VALUES(l_cliente, ' ', ' ', ' ', NULL, NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CREDCAD_COD_CLI")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CREDCAD_COD_CLI")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
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
			
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","SIL_DIMENSAO_CLIENTE")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","SIL_DIMENSAO_CLIENTE")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
			{
			LET l_text_aux = 'Incluido o cliente '+p_cliente_codesp.cod_cliente
			
			INSERT INTO MCG_AUDIT_SAIDA 
					(EMPRESA, USUARIO, NOM_TABELA, NOM_COLUNA, DES_COLUNA, 
					DAT_PROCESSO, CONTEUDO_ANT, CONTEUDO_ATUAL, PROGRAMA, TIP_OPERACAO) 
			VALUES(p_cod_empresa, p_user, 'clientes', ' ', ' ', CURRENT, ' ', l_text_aux, 'POL0934', 'I')
			
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","MCG_AUDIT_SAIDA")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","MCG_AUDIT_SAIDA")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			ELSE 
				SELECT MAX(trans_saida)
				INTO l_trans_saida 
				FROM MCG_AUDIT_SAIDA
			END IF 
			
			INSERT INTO MCG_AUDIT_ITEM_SAI (EMPRESA, TRANS_MESTRE, TIP_AUDITORIA, 
																			TRANS_AUDIT_SAIDA, SEQUENCIA_CHAVE, CHAVE) 
			VALUES(p_cod_empresa, 0, 'CLIENTE', l_trans_saida, 1, p_cliente_codesp.cod_cliente)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","MCG_AUDIT_ITEM_SAI")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","MCG_AUDIT_ITEM_SAI")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
						
			INSERT INTO CAP_PAR_FORNEC_IMP (FORNECEDOR, PARAMETRO, DES_PARAMETRO, PARAMETRO_BOOLEANO, 
																			PARAMETRO_TEXTO, PARAMETRO_VAL, PARAMETRO_NUMERICO, PARAMETRO_DAT) 
			VALUES(p_cliente_codesp.cod_cliente, 'reten_iss_pag_ent', 'RETEM ISS NO PAGAMENTO', NULL, NULL, NULL, NULL, NULL)
			IF SQLCA.SQLCODE<> 0 THEN
				CALL log003_err_sql("INSERT","CAP_PAR_FORNEC_IMP")
				LET l_msg = "ClIENTE ",p_cliente_codesp.cod_cliente," - ",p_cliente_codesp.nom_cliente[1,15] CLIPPED,' ',log0030_txt_err_sql("INSERT","CAP_PAR_FORNEC_IMP")								
				CALL pol0934_imprime_erros(l_msg)
				LET p_houve_erro =  TRUE
			END IF
		}
		END IF 
	END FOREACH 
	WHENEVER ERROR STOP 
	IF p_houve_erro THEN 
		RETURN FALSE
	ELSE 
		RETURN TRUE 
	END IF 
END FUNCTION 
#---------------------------------------#
FUNCTION pol0934_converte_valores_Item()#
#---------------------------------------# p_item_converte.
	LET p_itens_fatura_codesp.qtd_item					= p_item_converte.qtd_item   							/ 1000 #DECIMAL(12,3),
	LET p_itens_fatura_codesp.pre_unit					=	p_item_converte.pre_unit	   						/ 1000000 #DECIMAL(17,6),
	LET p_itens_fatura_codesp.val_liq_item				=	p_item_converte.val_liq_item 				  	/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.pct_icms					=	p_item_converte.pct_icms   						 	/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_tot_base_icms			=	p_item_converte.val_tot_base_icms  			/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.val_tot_icms				=	p_item_converte.val_tot_icms  					/ 100 #DECIMAL(17,2),
	LET p_itens_fatura_codesp.pct_irpj					=	p_item_converte.pct_irpj   							/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_irpj				=	p_item_converte.val_base_irpj   				/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_irpj					=	p_item_converte.val_irpj   							/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_csll					=	p_item_converte.pct_csll   							/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_csll				= p_item_converte.val_base_csll  					/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_csll					=	p_item_converte.val_csll   						/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_cofins				=	p_item_converte.pct_cofins   						/ 100 #DECIMAL(5,2),
	LET p_itens_fatura_codesp.val_base_cofins			=	p_item_converte.val_base_cofins   			/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_cofins				=	p_item_converte.val_cofins   						/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.pct_pis					= p_item_converte.pct_pis  								/ 100 #DECIMAL(5,2),	
	LET p_itens_fatura_codesp.val_base_pis				=	p_item_converte.val_base_pis   					/ 100 #DECIMAL(15,2),
	LET p_itens_fatura_codesp.val_pis					= p_item_converte.val_pis  								/ 100 #DECIMAL(5,2)
END FUNCTION 
	#Para nao ter que ficar refazendo o codigo a cada 
	#tributo foi criada essa função retorna 3 valores
#-------------------------------------------#
FUNCTION pol0934_trib_benef(l_tributo_benef)#
#-------------------------------------------#	
DEFINE l_tributo_benef  CHAR(20),
			 l_trans_config		INTEGER,
			 l_incide			CHAR(1),
			 l_cod_fiscal		INTEGER,
			 l_aliquota         DECIMAL(7,4),
			 l_acresc_desc      LIKE  obf_config_fiscal.acresc_desc,
			 l_origem_produto	LIKE  obf_config_fiscal.origem_produto,
			 l_tributacao		LIKE  obf_config_fiscal.tributacao,
			 l_menssagem		CHAR(30),
			 l_estado CHAR(02)
			 
			 
			SELECT ESTADO_LOGIX
			INTO l_estado
			FROM OBF_CIDADE_IBGE A, CLIENTES B
			WHERE A.CIDADE_LOGIX = B.COD_CIDADE
			AND B.COD_CLIENTE =p_fatura_codesp.cod_cliente

      IF l_tributo_benef = 'ICMS'   THEN         
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
				AND tributo_benef = l_tributo_benef  
				AND origem        = 'S' 
				AND obf_config_fiscal.nat_oper_grp_desp =  p_natureza_operacao
				AND obf_config_fiscal.grp_fiscal_regiao IS NULL 
				AND obf_config_fiscal.estado = l_estado
				AND obf_config_fiscal.municipio IS NULL 
				AND obf_config_fiscal.carteira IS NULL 
				AND obf_config_fiscal.finalidade = p_parametro.FINALIDADE 
				AND obf_config_fiscal.familia_item IS NULL 
				AND obf_config_fiscal.grupo_estoque IS NULL 
				AND obf_config_fiscal.grp_fiscal_classif IS NULL 
				AND obf_config_fiscal.classif_fisc IS NULL 
				AND obf_config_fiscal.linha_produto IS NULL 
				AND obf_config_fiscal.linha_receita IS NULL 
				AND obf_config_fiscal.segmto_mercado IS NULL 
				AND obf_config_fiscal.classe_uso IS NULL 
				AND obf_config_fiscal.unid_medida IS NULL 
				AND obf_config_fiscal.produto_bonific IS NULL 
				AND obf_config_fiscal.grupo_fiscal_item IS NULL 
				AND obf_config_fiscal.item IS NULL 
				AND obf_config_fiscal.micro_empresa IS NULL 
				AND obf_config_fiscal.grp_fiscal_cliente IS NULL 
				AND obf_config_fiscal.cliente IS NULL 
				AND obf_config_fiscal.via_transporte IS NULL 
				AND valid_config_ini    IS NULL  
				AND valid_config_final  IS NULL
      ELSE
		  	SELECT trans_config,   incide, cod_fiscal, aliquota, acresc_desc, origem_produto,tributacao
				INTO 	l_trans_config,
							l_incide,
							l_cod_fiscal,
							l_aliquota,
							l_acresc_desc,
							l_origem_produto,
							l_tributacao
				FROM obf_config_fiscal 
				WHERE empresa       = p_fatura_codesp.cod_empresa
				AND tributo_benef = l_tributo_benef  
				AND origem        = 'S' 
				AND obf_config_fiscal.nat_oper_grp_desp =   p_natureza_operacao
				AND obf_config_fiscal.grp_fiscal_regiao IS NULL 
				AND obf_config_fiscal.estado IS NULL
				AND obf_config_fiscal.municipio IS NULL 
				AND obf_config_fiscal.carteira IS NULL 
				AND obf_config_fiscal.finalidade IS NULL
				AND obf_config_fiscal.familia_item IS NULL 
				AND obf_config_fiscal.grupo_estoque IS NULL 
				AND obf_config_fiscal.grp_fiscal_classif IS NULL 
				AND obf_config_fiscal.classif_fisc IS NULL 
				AND obf_config_fiscal.linha_produto IS NULL 
				AND obf_config_fiscal.linha_receita IS NULL 
				AND obf_config_fiscal.segmto_mercado IS NULL 
				AND obf_config_fiscal.classe_uso IS NULL 
				AND obf_config_fiscal.unid_medida IS NULL 
				AND obf_config_fiscal.produto_bonific IS NULL 
				AND obf_config_fiscal.grupo_fiscal_item IS NULL 
				AND obf_config_fiscal.item IS NULL 
				AND obf_config_fiscal.micro_empresa IS NULL 
				AND obf_config_fiscal.grp_fiscal_cliente IS NULL 
				AND obf_config_fiscal.cliente IS NULL 
				AND obf_config_fiscal.via_transporte IS NULL 
				AND valid_config_ini    IS NULL  
				AND valid_config_final  IS NULL
      END IF 

	IF SQLCA.SQLCODE = 0 THEN
		RETURN l_trans_config,l_incide,l_cod_fiscal, l_aliquota,l_acresc_desc,l_origem_produto,l_tributacao
	ELSE 
		LET l_menssagem ='Cadastrar ',l_tributo_benef,'na tabela obf_config_fiscal'
		CALL log0030_mensagem(l_menssagem,'')
		CALL pol0934_imprime_erros(l_menssagem)
		RETURN	'','','', '', '','', '' 
	END IF  
END FUNCTION
#---------------------------------------#
FUNCTION pol0934_verifica_parametro()#
#---------------------------------------#
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
#-----------------------#
FUNCTION pol0934_popup()#
#-----------------------#
DEFINE p_codigo  CHAR(15)
      
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"CODIGO DO PARAMETRO","par_solc_fat_codesp",
						"cod_parametro","den_parametro","","S","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0934
			IF p_codigo IS NOT NULL THEN
				LET p_parametro.cod_parametro = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_parametro
			END IF
	END CASE 
END FUNCTION 

#-----------------------------------#
FUNCTION pol0934_verifica_gravacao()#
#-----------------------------------#
DEFINE l_cont INTEGER 
	SELECT COUNT(*)
	INTO l_cont
	FROM rel_fat_nfs_codesp r, t_fatura_codesp t
	WHERE t.cod_empresa = r.cod_empresa
	AND   t.num_docum = r.num_docum
	AND   t.especie = r.especie
	AND   r.data_emissao_fa = t.data_emissao
	IF l_cont >0 THEN
		RETURN TRUE 
	ELSE
		RETURN FALSE 
	END IF
END FUNCTION
#--------------------------#
FUNCTION  pol0934_control()#
#--------------------------#

	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol09341") RETURNING comando
	OPEN WINDOW w_pol09341 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0934_ent_parametros() RETURNING p_retorno
				NEXT OPTION "Carregar"
			END IF
	COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
	   COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0934_sobre() 		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol09341
END FUNCTION
#-----------------------#
FUNCTION pol0934_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND
   
   LET p_dat = CURRENT
   
   LET p_msg = p_versao CLIPPED,"\n\n",
               " Alteração: ",p_dat,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------#
FUNCTION pol0934_ent_parametros()#
#--------------------------------#
DEFINE l_msg CHAR(200)
	CLEAR FORM	
 	DISPLAY p_cod_empresa TO cod_empresa
 	INITIALIZE p_tipo, p_entrada TO NULL 
	INPUT p_tipo, p_entrada WITHOUT DEFAULTS FROM tipo,entrada
		AFTER FIELD tipo
			IF p_tipo IS NULL THEN
				NEXT FIELD tipo
			END IF 
	AFTER FIELD entrada
		IF p_entrada IS NULL THEN 
			NEXT FIELD entrada
		ELSE
			IF NOT pol0934_verifica_numero() THEN
				IF p_tipo = "SOL" THEN
					LET l_msg = "Solicitação de fatura não existe ou nota fiscal não faturada!!!"
				ELSE
					LET l_msg ="Nota Fiscal nâo cadastrada!!!"
				END IF 
				CALL log0030_mensagem(l_msg,'info')
				ERROR l_msg
				NEXT FIELD entrada
			ELSE
				IF p_tipo = "SOL" THEN
					DISPLAY "NOTA FISCAL" TO tipo_sai
				ELSE
					DISPLAY "FATURA" TO tipo_sai
				END IF 
			END IF 
		END IF 
	END INPUT
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF
END FUNCTION 
#---------------------------------#
FUNCTION pol0934_verifica_numero()#				#Função responsalves  por retornar o numero da solicitação ou 
#---------------------------------#				#numero da nota fiscal
	DEFINE l_saida DECIMAL(6,0)

	IF p_tipo = "NF" THEN 
		SELECT NUM_DOCUM 
		INTO l_saida
		FROM REL_FAT_NFS_CODESP
		WHERE  COD_EMPRESA = p_cod_empresa
		AND NUM_NFF  = p_entrada
	ELSE 
		SELECT NUM_NFF 
		INTO l_saida
		FROM REL_FAT_NFS_CODESP
		WHERE  COD_EMPRESA = p_cod_empresa
		AND NUM_DOCUM = p_entrada
	END IF 
	IF l_saida IS NOT NULL THEN
		DISPLAY l_saida TO saida
		RETURN TRUE 
	ELSE
		RETURN FALSE 
	END IF 

END FUNCTION

#-------------------------------------#
FUNCTION pol0934_imprime_erros(p_erro)#			#prepara para imprimir erro
#-------------------------------------#
DEFINE p_erro			CHAR(250)
	
	
	IF NOT  p_print THEN 			
		CALL log150_procura_caminho ('LST') RETURNING p_caminho
		LET p_caminho = p_caminho CLIPPED, 'pol0934.lst'
		LET p_nom_arquivo = p_caminho
		START REPORT pol0934_imprime TO p_nom_arquivo
		LET p_print = TRUE 
	END IF 
	
	OUTPUT TO REPORT pol0934_imprime(p_erro)
	
	
END FUNCTION 

#-----------------------------#
REPORT pol0934_imprime(p_erro)#			#vai imprimir os erros apresentados no programa
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

         PRINT COLUMN 001, "pol0934  CARGA DE SOLICITAÇÃO DE FATURA",
               COLUMN 085, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*-------------------------------------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRIÇÃO DO ERRO"
         PRINT COLUMN 001, "*-------------------------------------------------------------------------------------------------------------*"

      ON EVERY ROW
      	 PRINT COLUMN 001,p_erro CLIPPED
END REPORT

