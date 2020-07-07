#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol0947		                                            #
# OBJETIVO: CARREGAMENTO DE DADOS DA NOTA FISCAL ATRAVEs DE ARQUIVO #
#						 TEXTO 										#
# CLIENTE.: CODESP                                            		#
# DATA....: 00/00/2009                                              #
# POR.....: THIAGO				                                    #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_den_empresa        LIKE empresa.den_empresa,
         p_val_ipi            LIKE nf_sup.val_ipi_calc,
         p_cfop_orig          CHAR(04),
         p_nom_arquivo        CHAR(100),
		 p_nom_arquivo1       CHAR(100),
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
         p_status             SMALLINT,
	     p_caminho            CHAR(100),
		 p_caminho1           CHAR(100),
	     comando              CHAR(80),
	     p_versao             CHAR(18),
	     p_num_programa       CHAR(07),
	     p_resposta						SMALLINT,
         p_cod_operacao       LIKE nf_sup.cod_operacao,
       	 p_num_conta          LIKE item_sup.num_conta,
         p_num_prx_ar         LIKE nf_sup.num_aviso_rec,
         p_cod_oper           LIKE nf_sup.cod_operacao,
		 p_cod_fiscal         CHAR(05),
	     p_num_transac        INTEGER,
	     p_msg                CHAR(250),
		 p_msg_erro           CHAR(60),
		 p_mensagem           CHAR(250),
	   	 p_houve_erro         SMALLINT,
	   	 p_retorno            SMALLINT,
	   	 p_ind                SMALLINT,
	     p_nom_tela           CHAR(200),
	     p_nom_help           CHAR(200),
	     p_cont								SMALLINT,
		 p_val_total  						DECIMAL(17,2),
	     p_erro								SMALLINT,
	     p_primeira_vez				SMALLINT,
		 p_primeira_vez1			SMALLINT,
		 p_cod_fornecedor 			CHAR(15)
	
	DEFINE	p_pct_iss 				DECIMAL(5,2),
					p_pct_irpj				DECIMAL(5,2),  
					p_pct_csll				DECIMAL(5,2),  
					p_pct_cofins			DECIMAL(5,2),  
					p_pct_pis					DECIMAL(5,2)       	 
	
	DEFINE p_aviso_temp     RECORD
		      num_aviso_rec    DECIMAL(6,0),
		      num_seq          DECIMAL(3,0),
		      cod_item         CHAR(15),
		      qtd_declarad_nf  DECIMAL(12,3),
		      cod_unid_med_nf  CHAR(03)
	END RECORD
	
	DEFINE p_entrada				RECORD
					data						DATE,
					hora						DATETIME HOUR TO  MINUTE,
					cod_parametro		LIKE par_imp_nf_sup_912.cod_parametro
	END RECORD
	
	DEFINE p_aen              RECORD 
	      cod_lin_prod       LIKE item.cod_lin_prod,
	      cod_lin_recei      LIKE item.cod_lin_recei,
	      cod_seg_merc       LIKE item.cod_seg_merc,
	      cod_cla_uso        LIKE item.cod_cla_uso
	END RECORD
	DEFINE p_fornecedor RECORD 
					Cod_fornecedor		CHAR(14),
					Tipo_fornecedor		CHAR(01),
					Nom_fornecedor		CHAR(50),
					Nom_reduzido 			CHAR(10),
					End_fornecedor		CHAR(36),
					Den_bairro				CHAR(20),
					Cidade						CHAR(30),
					Cod_cidade				DECIMAL(7,0),
					Cod_cep						CHAR(09),
					Estado 						CHAR(02),
					Telefone					CHAR(15),
					Num_fax						CHAR(15),
					Ins_estadual			CHAR(16),
					Contato 					CHAR(15)
	END RECORD 
	
	DEFINE p_nfe RECORD 
					Cod_empresa							CHAR(02),
					Num_nf								DECIMAL(7,0),
					Ser_nf								CHAR(03),
					SSr_nf								DECIMAL(2,0),   #IVO 15/08/2013
					especie_nf							CHAR(03),
					Cod_fornecedor						CHAR(14),
					cfop                    			CHAR(07),
					Data_emissao						DATE,
					Data_entrada						DATE,
					Data_vencto							DATE,
					Val_tot_desconto					DECIMAL(17,2),
					Val_tot_frete						DECIMAL(17,2),
					Val_tot_nff							DECIMAL(17,2),
					num_conta_cont                      CHAR(10)
	END RECORD 
	DEFINE  p_nf_sup		RECORD 		LIKE nf_sup.*,
					p_audit_ar  RECORD 		LIKE audit_ar.*,
					p_dest_ar   RECORD 		LIKE dest_aviso_rec.*,
					p_ar_sq     RECORD		LIKE aviso_rec_compl_sq.*,
					p_aviso_rec	RECORD		LIKE aviso_rec.*
					
	DEFINE p_nfe_item RECORD
					Cod_empresa					CHAR(02),
					Num_nf						DECIMAL(7,0),
					Ser_nf						CHAR(03),
					SSr_nf								DECIMAL(2,0),   #IVO 15/08/2013
					Cod_fornecedor				CHAR(14),
					Sequencia					DECIMAL(5,0),
					cfop                		CHAR(07),
					Cod_item					CHAR(15),
					Den_item					CHAR(50),
					Qtd_item					DECIMAL(12,3),
					Unidade_medida				CHAR(03),
					Pre_unit					DECIMAL(17,6),
					Val_desc_item				DECIMAL(17,2),
					Val_liq_item				DECIMAL(17,2),   
					Pct_iss             		DECIMAL(5,2),  
					Val_tot_base_iss			DECIMAL(17,2),
					Val_tot_iss					DECIMAL(17,2),
					Cod_retencao				DECIMAL(4,0),
					Pct_irpj            		DECIMAL(5,2),
					Val_base_irpj				DECIMAL(15,2),
					Val_irpj					DECIMAL(15,2),
					Pct_csll            		DECIMAL(5,2), 
					Val_base_csll				DECIMAL(15,2),
					Val_csll					DECIMAL(15,2),
					Pct_cofins          		DECIMAL(5,2),
					Val_base_cofins				DECIMAL(15,2),
					Val_cofins					DECIMAL(15,2),
					Pct_pis             		DECIMAL(5,2),
					Val_base_pis				DECIMAL(15,2),
					Val_pis						DECIMAL(15,2),
					Pct_icms            		DECIMAL(5,2),
					Val_base_icms				DECIMAL(15,2),
					Val_icms					DECIMAL(15,2),
					Val_inss					DECIMAL(17,2),
					Val_frete					DECIMAL(17,2),
					Val_pis_rec					DECIMAL(15,2),
					Val_cofins_rec				DECIMAL(15,2),
					Pct_ipi             		DECIMAL(5,2),
					Val_base_ipi				DECIMAL(15,2),
					Val_ipi 					DECIMAL(15,2)
				 

	END RECORD 
	DEFINE p_parametro			RECORD
				cond_pagto					LIKE par_imp_nf_sup_912.cond_pagto,
				#clas_fiscal				LIKE par_imp_nf_sup_912.clas_fiscal,
				cod_parametro				LIKE par_imp_nf_sup_912.cod_parametro
	END RECORD
END GLOBALS 

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 11
   DEFER INTERRUPT 
   LET p_versao = "pol0947-10.02.71" #ivo 15/08/2013
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0947.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b,
        DELETE KEY control-e
   
    CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0947_controle()
   END IF
END MAIN

#---------------------------#
FUNCTION  pol0947_controle()#
#---------------------------#
DEFINE p_processa SMALLINT 
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0947") RETURNING comando
	OPEN WINDOW w_pol0947 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	LET p_processa = FALSE 
	LET p_retorno = FALSE 
	LET p_resposta = FALSE 
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				CALL pol0947_entrada_parametro() RETURNING p_retorno
				LET p_erro = FALSE
				LET p_primeira_vez = TRUE
				LET p_primeira_vez1 = TRUE
				NEXT OPTION "Carregar"
			END IF
		COMMAND "Carregar"   "Carregar arquivo de dados"
			HELP 0009
			MESSAGE ""
			IF log005_seguranca(p_user,"VDP","VDP2565","CO") THEN
				 IF p_retorno THEN
				 		MESSAGE "Carregando arquivo..."
					 	IF  pol0947_carrega_arquivo() THEN
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
					 	IF pol0947_processar() THEN
					 	
					 	 MESSAGE "Arquivo processado com sucesso! Foram processados ",p_cont
						LET p_mensagem = " Total de nf carregadas= ", p_cont," Valor Total= ", p_val_total
						CALL pol0947_imprime_NF(p_mensagem)
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
		COMMAND "Consistir"  "Consistir a NF Entrada"
			HELP 0001
			CALL log120_procura_caminho("SUP0480") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0934
   COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0947_sobre() 		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	CLOSE WINDOW w_pol0947
END FUNCTION 

#-----------------------#
FUNCTION pol0947_sobre()
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

#----------------------------------#
FUNCTION pol0947_entrada_parametro()#
#----------------------------------#
	CALL log006_exibe_teclas("01 02 07",p_versao)
	CURRENT WINDOW IS w_pol0947
	DISPLAY p_cod_empresa TO cod_empresa
	INITIALIZE p_entrada.* TO NULL 
	INPUT  p_entrada.* WITHOUT DEFAULTS FROM data,hora, cod_parametro 
		AFTER FIELD data
			IF p_entrada.data IS NULL THEN 
				ERROR 'Campo de preenchimento obrigatório!!!'
				NEXT FIELD data
			ELSE
				NEXT FIELD hora
			END IF 
		AFTER FIELD hora
			IF p_entrada.hora IS NULL THEN 
				ERROR 'Campo de preenchimento obrigatório!!!'
				NEXT FIELD hora
			END IF 
		AFTER FIELD cod_parametro
			IF p_entrada.cod_parametro IS NULL THEN 
				 ERROR 'Campo de preenchimento obrigatório!!!'
				 NEXT FIELD cod_parametro
			ELSE 
				IF NOT pol0947_verifica_par() THEN
					ERROR 'Parametro não cadastrado!!!'
					NEXT FIELD cod_parametro
				END IF 
			END IF 
			ON KEY (control-z)
			CALL pol0947_popup()
	END INPUT
	IF INT_FLAG = 0 THEN
		RETURN TRUE 
	ELSE
		CLEAR FORM
		DISPLAY p_cod_empresa TO cod_empresa
		LET INT_FLAG = 0
		RETURN FALSE
	END IF
END FUNCTION
#------------------------------#
FUNCTION pol0947_verifica_par()#
#------------------------------#
DEFINE l_parametro			LIKE par_imp_nf_sup_912.den_parametro
	SELECT cond_pagto, den_parametro 
	INTO 	p_parametro.cond_pagto,
				l_parametro
	FROM par_imp_nf_sup_912
	WHERE cod_empresa = p_cod_empresa
	AND cod_parametro = p_entrada.cod_parametro
	
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE 
	ELSE
		DISPLAY l_parametro TO den_parametro
		RETURN TRUE
	END IF
END FUNCTION 
#-----------------------#
FUNCTION pol0947_popup()#
#-----------------------#
DEFINE p_codigo		LIKE par_imp_nf_sup_912.cod_parametro
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"PARAMETROS","par_imp_nf_sup_912",
						"cod_parametro","den_parametro","","N","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0947
			IF p_codigo IS NOT NULL THEN
				LET p_parametro.cod_parametro = p_codigo CLIPPED
				DISPLAY p_parametro.cod_parametro TO cod_parametro
			END IF
	END CASE 
END FUNCTION 
#-------------------------------------#
FUNCTION pol0947_gerencia_fornecedor()#
#-------------------------------------#
DEFINE 	l_cont  							SMALLINT,
				l_cpf_cnpj 						CHAR(25),
				l_cod_fornecedor 			CHAR(15),
				l_cod_cidade					CHAR(15),
				l_ies_zona_franca 		CHAR(01),
				l_parametro						CHAR(20), 
				l_des_parametro				CHAR(60),
				l_parametro_booleano	CHAR(01),
				l_parametro_texto			CHAR(200),
				l_chave_fornecedor		INTEGER

	DECLARE cq_fornecedor SCROLL CURSOR WITH HOLD FOR 
											SELECT * FROM t_nf_fornecedor
											
	FOREACH cq_fornecedor INTO p_fornecedor.*
	
		IF p_fornecedor.Tipo_fornecedor = 'J' THEN 
			LET l_cpf_cnpj = '0',p_fornecedor.Cod_fornecedor[1,2],'.',p_fornecedor.Cod_fornecedor[3,5],
													'.',p_fornecedor.Cod_fornecedor[6,8],'/',p_fornecedor.Cod_fornecedor[9,12],
													'-',p_fornecedor.Cod_fornecedor[13,14]
		ELSE
			LET l_cpf_cnpj =p_fornecedor.Cod_fornecedor[1,3],'.',p_fornecedor.Cod_fornecedor[4,6],'.'
											,p_fornecedor.Cod_fornecedor[7,9],'/0000-',p_fornecedor.Cod_fornecedor[10,11]
		END IF 
		
		LET l_cod_fornecedor = '0',p_fornecedor.Cod_fornecedor			#codigo fornecedor logix tem 15 digito então acrescentamos o '0'
		
		SELECT cidade_logix																					#convertendo cidade ibge para codigo logix
		INTO l_cod_cidade
	 	FROM obf_cidade_ibge
		WHERE cidade_ibge = p_fornecedor.Cod_cidade
		
		IF SQLCA.SQLCODE <> 0 THEN
			IF SQLCA.SQLCODE = 100 THEN
				ERROR 'CADASTRAR O CODIGO DA CIDADE IBGE ',p_fornecedor.Cod_cidade
			END IF 
			LET p_msg = "FORNECEDOR ",p_fornecedor.Cod_fornecedor		,"- REGISTRO ",p_fornecedor.Cod_cidade," NÂO CADASTRADO - CADASTRAR NO PROGRAMA VDP9113"
										
			CALL pol0947_imprime_erros(p_msg)
     	
     	LET l_cod_cidade = 11000	
		END IF
		
		
		IF p_fornecedor.Estado = "AM" THEN
			LET l_ies_zona_franca = "S"
		ELSE
			LET l_ies_zona_franca = "N"
		END IF 
		
		SELECT COUNT(cod_fornecedor)
		INTO l_cont	
		FROM fornecedor 																								#verificando se o fornecedor ja e cadastrado
		WHERE Cod_fornecedor = l_cod_fornecedor
		
		IF l_cont> 0 THEN
			UPDATE FORNECEDOR
				SET RAZ_SOCIAL				=	p_fornecedor.Nom_fornecedor,
						RAZ_SOCIAL_REDUZ	=	p_fornecedor.Nom_reduzido,
						INS_ESTADUAL 			=  p_fornecedor.Ins_estadual,
						DAT_ATUALIZ 			= CURRENT ,
						END_FORNEC 				= p_fornecedor.End_fornecedor,
						DEN_BAIRRO 				= p_fornecedor.Den_bairro,
						COD_CEP 					= p_fornecedor.Cod_cep,
						COD_CIDADE				=	l_cod_cidade,
						COD_UNI_FEDER 		=	p_fornecedor.Estado,
						IES_ZONA_FRANCA		=	l_ies_zona_franca,
						NUM_TELEFONE			=	p_fornecedor.Telefone,
						NUM_FAX 					= p_fornecedor.Num_fax,
						NOM_CONTATO 			= p_fornecedor.Contato,
						NOM_GUERRA				=	p_fornecedor.Contato
					WHERE Cod_fornecedor = l_cod_fornecedor
		
		ELSE
			INSERT INTO FORNECEDOR 
						(NUM_CGC_CPF, COD_FORNECEDOR, RAZ_SOCIAL, RAZ_SOCIAL_REDUZ, 								#inserindo dados basicos do
						IES_TIP_FORNEC, IES_FORNEC_ATIVO, IES_CONTRIB_IPI, IES_FIS_JURIDICA,				#forcenedor
						INS_ESTADUAL, DAT_CADAST, DAT_ATUALIZ, DAT_VALIDADE, DAT_MOVTO_ULT, 
						END_FORNEC, DEN_BAIRRO, COD_CEP, COD_CIDADE, COD_UNI_FEDER, COD_PAIS, 
						IES_ZONA_FRANCA, NUM_TELEFONE, NUM_FAX, NUM_TELEX, NOM_CONTATO, NOM_GUERRA, 
						COD_CIDADE_PGTO, CAMARA_COMP, COD_BANCO, NUM_AGENCIA, NUM_CONTA_BANCO, 
						TMP_TRANSPOR, TEX_OBSERV, NUM_LOTE_TRANSF, PCT_ACEITE_DIV, IES_TIP_ENTREGA, 
						IES_DEP_CRED, ULT_NUM_COLETA, IES_GERA_AP) 
			VALUES(l_cpf_cnpj, l_cod_fornecedor, p_fornecedor.Nom_fornecedor,p_fornecedor.Nom_reduzido,
						 '1', 'A','N', p_fornecedor.Tipo_fornecedor,
						  p_fornecedor.Ins_estadual, CURRENT,CURRENT,CURRENT, NULL,
						  p_fornecedor.End_fornecedor, p_fornecedor.Den_bairro, p_fornecedor.Cod_cep, l_cod_cidade,p_fornecedor.Estado, '001',
						  l_ies_zona_franca, p_fornecedor.Telefone,p_fornecedor.Num_fax, NULL , p_fornecedor.Contato, p_fornecedor.Contato,
						  NULL, NULL, NULL, NULL, NULL, 
						  1, NULL, 0, 0, 'D',
						   'N', 0, NULL)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql("Inserindo","fornecedor")
				LET p_msg = log0030_txt_err_sql("INSERT","AUDIT_AR"), " Codigo Fornecedor ",p_fornecedor.Cod_fornecedor
     		CALL pol0947_imprime_erros(p_msg)
     		LET p_erro = TRUE
			END IF
			
			INSERT INTO FORNEC_COMPL 
							(COD_FORNECEDOR, IES_LIQUIDA_OC, IES_APROVEITA_PED, INS_MUNICIPAL, 						#inserindo complemento do
							IES_ITEM_ISO, DAT_APROV, IES_APROVADO, IES_TIP_APROVACAO, IES_FUNRURAL, 			#fornecedor 
							IES_FORMA_PAGTO, REGISTRO_SAA, CODIGO_RET, VALIDADE_RET, IES_FORMA_ENVIO, 
							E_MAIL, NUM_TEL_CELULAR, ENDERECO_WEB, EMAIL_SECUND, PCT_PONTUACAO) 
			VALUES(l_cod_fornecedor, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql("Inserindo","fornec_compl")
				LET p_msg = log0030_txt_err_sql("INSERT","AUDIT_AR"), " Codigo Fornecedor ",p_fornecedor.Cod_fornecedor
     		CALL pol0947_imprime_erros(p_msg)
     		LET p_erro = TRUE
			END IF
			
			FOR l_cont = 1 TO 10																				#Preparando variaveis para inserir na tabela
				CASE 																											#sup_par_fornecedor 
					WHEN l_cont = 1
						LET l_parametro 				=	'ies_depositante'
						LET l_des_parametro 		=	'Indica se o cadastro é um depositante    '
						LET l_parametro_booleano =	NULL
						LET l_parametro_texto		= NULL  
					WHEN l_cont = 2
						LET l_parametro 				=	'email_compras  '
						LET l_des_parametro 		=	'E-mail do Setor de Compras do Fornecedor '
						LET l_parametro_booleano =	NULL 
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 3
						LET l_parametro 				=	'declara_isento '
						LET l_des_parametro 		=	'DECLARACAO DE ISENTO SIMPLES             '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 4
						LET l_parametro 				=	'ies_contrib_pis'
						LET l_des_parametro 		=	'Indicador de Contribuicao de PIS.        '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 5
						LET l_parametro 				=	'ies_contrib_cofins  '
						LET l_des_parametro 		=	'Indicador de Contribuicao de COFINS      '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 6
						LET l_parametro 				=	'ies_contrib_csl'
						LET l_des_parametro 		=	'Indicador de Contribuicao de CSL         '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 7
						LET l_parametro 				=	'ind_ret_pis_cof'
						LET l_des_parametro 		=	'Indicador tipo retencao do PIS/COFINS/CSL'
						LET l_parametro_booleano =	NULL
						LET l_parametro_texto		= '0' 
					WHEN l_cont = 8
						LET l_parametro 				=	'cred_pis_cofins'
						LET l_des_parametro 		=	'Credito presumido PIS/COFINS             '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 9
						LET l_parametro 				=	'util_subcontratacao '
						LET l_des_parametro 		=	'Indicador de Subcontratacao              '
						LET l_parametro_booleano =	'N'
						LET l_parametro_texto		= NULL 
					WHEN l_cont = 10
						LET l_parametro 				=	'subtipo_fornecedor  '
						LET l_des_parametro 		=	'Subtipo do fornecedor                    '
						LET l_parametro_booleano =	NULL 
						LET l_parametro_texto		= NULL 
				END CASE 
			
				INSERT INTO SUP_PAR_FORNECEDOR 
								(EMPRESA, FORNECEDOR, PARAMETRO, DES_PARAMETRO, PARAMETRO_BOOLEANO, 
								PARAMETRO_TEXTO, PARAMETRO_VAL, PARAMETRO_NUMERICO, PARAMETRO_DAT)
				VALUES(p_cod_empresa, l_cod_fornecedor,l_parametro,l_des_parametro, l_parametro_booleano,
							l_parametro_texto, NULL, NULL, NULL)
				IF SQLCA.SQLCODE<>0 THEN
					CALL log003_err_sql("Inserindo","sup_par_fornecedor")
					LET p_msg = log0030_txt_err_sql("Inserindo","sup_par_fornecedor"), " Codigo Fornecedor ",l_cod_fornecedor
     			CALL pol0947_imprime_erros(p_msg)
     			LET p_erro = TRUE
				END IF
			END FOR 
			
			INSERT INTO VDP_CLI_FORNEC_CPL 
							(CLIENTE_FORNECEDOR, TIP_CADASTRO, RAZAO_SOCIAL, RAZAO_SOCIAL_REDUZ, 
							BAIRRO, CORREIO_ELETRONICO, CORREI_ELETR_SECD, CORREI_ELETR_VENDA, 
							ENDERECO_WEB, TELEFONE_1, TELEFONE_2, COMPL_ENDERECO, TIP_LOGRADOURO, 
							LOGRADOURO, NUM_IDEN_LOGRAD) 
			VALUES(l_cod_fornecedor, 'F', p_fornecedor.Nom_fornecedor, p_fornecedor.Nom_reduzido,
						  p_fornecedor.Den_bairro,NULL, NULL, NULL, 
						  NULL,p_fornecedor.Telefone, NULL, NULL, NULL, 
						  NULL, NULL)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql("Inserindo","vdp_cli_fornec_cpl")
				LET p_msg = log0030_txt_err_sql("Inserindo","vdp_cli_fornec_cpl"), " Codigo Fornecedor ",p_fornecedor.Cod_fornecedor
     		CALL pol0947_imprime_erros(p_msg)
     		LET p_erro = TRUE
			END IF
			
			SELECT MAX(CHAVE_FORNECEDOR)+1
			INTO l_chave_fornecedor
			FROM SIL_DIMENSAO_FORNECEDOR
			
			IF l_chave_fornecedor IS NULL THEN
				LET l_chave_fornecedor = 1
			END IF 
			 
			INSERT INTO SIL_DIMENSAO_FORNECEDOR 
							(CHAVE_FORNECEDOR, FORNECEDOR, CPF_CNPJ_FORNECEDOR, RAZAO_SOCIAL, 
							RAZAO_SOCIAL_REDUZ, DES_SUBTIPO_FORNECEDOR) 
			VALUES(l_chave_fornecedor, l_cod_fornecedor, l_cpf_cnpj, p_fornecedor.Nom_fornecedor, 
						p_fornecedor.Nom_reduzido, NULL)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql("Inserindo","sil_dimensao_fornecedor")
				LET p_msg = log0030_txt_err_sql("Inserindo","sil_dimensao_fornecedor"), " Codigo Fornecedor ",p_fornecedor.Cod_fornecedor
     		CALL pol0947_imprime_erros(p_msg)
     		LET p_erro = TRUE
			END IF
			
			INSERT INTO CAP_PAR_FORNEC_IMP 
							(FORNECEDOR, PARAMETRO, DES_PARAMETRO, PARAMETRO_BOOLEANO, 
							PARAMETRO_TEXTO, PARAMETRO_VAL, PARAMETRO_NUMERICO, PARAMETRO_DAT) 
			VALUES(l_cod_fornecedor,'reten_iss_pag_ent', 'RETEM ISS NO PAGAMENTO ', 
						NULL, NULL, NULL, NULL,NULL)
			IF SQLCA.SQLCODE<>0 THEN
				CALL log003_err_sql("Inserindo","cap_par_fornec_imp")
					LET p_msg = log0030_txt_err_sql("Inserindo","cap_par_fornec_imp"), " Codigo Fornecedor ",p_fornecedor.Cod_fornecedor
     		CALL pol0947_imprime_erros(p_msg)
     		LET p_erro = TRUE
			END IF
		END IF 
	END FOREACH
	IF p_erro THEN
		RETURN FALSE
	ELSE
		RETURN TRUE
	END IF 
END FUNCTION 
#-----------------------------#
FUNCTION pol0947_cria_tabela()#
#-----------------------------#

		DROP TABLE t_nf_entrada															#criação das tabelas temporarias que
			CREATE  TABLE t_nf_entrada											#cão receber os arquivos de importação
			(
				Cod_empresa							CHAR(02),
				Num_nf								DECIMAL(7,0),
				Ser_nf								CHAR(03),
				Ssr_nf								DECIMAL(2,0), #ivo 15/08/2013
				especie_nf							CHAR(03),
				Cod_fornecedor						CHAR(14),
				cfop                    			CHAR(07),
				Data_emissao						DATE,
				Data_entrada						DATE,
				Data_vencto							DATE,
				Val_tot_desconto					DECIMAL(17,0),
				Val_tot_frete						DECIMAL(17,0),
				Val_tot_nff							DECIMAL(17,0),
				num_conta_cont                      CHAR(10)
			)
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("CRIACAO","t_nf_entrada")
				CALL pol0947_imprime_erros('ERRO AO CRIAR T_NF_ENTRADA')
				LET p_erro = TRUE 
			END IF

		DROP TABLE t_nf_item
			CREATE  TABLE t_nf_item
			(
			Cod_empresa						CHAR(02),
			Num_nf							DECIMAL(7,0),
			Ser_nf							CHAR(03),
			Ssr_nf								DECIMAL(2,0), #ivo 15/08/2013
			Cod_fornecedor					CHAR(14),
			Sequencia						DECIMAL(5,0),
			cfop                			CHAR(07),
			Cod_item						CHAR(15),
			Den_item						CHAR(50),
			Qtd_item						DECIMAL(12,0),
			Unidade_medida					CHAR(03),
			Pre_unit						DECIMAL(17,0),
			Val_desc_item					DECIMAL(17,0),
			Val_liq_item					DECIMAL(17,0),
			Pct_iss             			DECIMAL(5,0),
			Val_tot_base_iss				DECIMAL(17,0),
			Val_tot_iss						DECIMAL(17,0),
			Cod_retencao					DECIMAL(4,0),
			Pct_irpj             			DECIMAL(5,0),
			Val_base_irpj					DECIMAL(15,0),			
			Val_irpj						DECIMAL(15,0),
			Pct_csll            			DECIMAL(5,0),
			Val_base_csll					DECIMAL(15,0),
			Val_csll						DECIMAL(15,0),
			Pct_cofins          			DECIMAL(5,0),
			Val_base_cofins					DECIMAL(15,0),
			Val_cofins						DECIMAL(15,0),
			Pct_pis             			DECIMAL(5,0),
			Val_base_pis					DECIMAL(15,0),
			Val_pis							DECIMAL(15,0),
			Pct_icms            			DECIMAL(5,0),
			Val_base_icms					DECIMAL(15,0),
			Val_icms						DECIMAL(15,0),
			Val_inss						DECIMAL(17,0),
			Val_frete						DECIMAL(17,0),
			Val_pis_rec						DECIMAL(15,0),
			Val_cofins_rec					DECIMAL(15,0),
			Pct_ipi             			DECIMAL(5,0),
			Val_base_ipi					DECIMAL(15,0),			
			Val_ipi 						DECIMAL(15,0)	
			)
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("CRIACAO","t_nf_item")
				CALL pol0947_imprime_erros('ERRO AO CRIAR T_NF_ITEM')
				LET p_erro = TRUE 
			END IF
		
		DROP TABLE t_nf_fornecedor
			CREATE  TABLE t_nf_fornecedor
			(
			Cod_fornecedor		CHAR(14),
			Tipo_fornecedor		CHAR(01),
			Nom_fornecedor		CHAR(50),
			Nom_reduzido 			CHAR(10),
			End_fornecedor		CHAR(36),
			Den_bairro				CHAR(20),
			Cidade						CHAR(30),
			Cod_cidade				DECIMAL(7,0),
			Cod_cep						CHAR(09),
			Estado 						CHAR(02),
			Telefone					CHAR(15),
			Num_fax						CHAR(15),
			Ins_estadual			CHAR(16),
			Contato 					CHAR(15)
			)
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("CRIACAO","t_nf_fornecedor")
				CALL pol0947_imprime_erros('ERRO AO CRIAR T_NF_FORNECEDOR')
				LET p_erro = TRUE 
			END IF
	IF p_erro THEN  
		FINISH REPORT pol0947_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		FINISH REPORT pol0947_imprime_nf_processada
		RETURN FALSE 
	ELSE
		RETURN TRUE
	END IF 
END FUNCTION 
#---------------------------------#
FUNCTION pol0947_carrega_arquivo()#
#---------------------------------#
DEFINE l_data_char CHAR(10),
			 l_hora_char CHAR(05),
			 l_nome_arq	 CHAR(12),
			 l_caminho	 CHAR(100),
			 l_caminho1	 CHAR(100),
			 l_cont 		 SMALLINT

	LET p_houve_erro = FALSE									#convertendo data e hora para caracter para	
	LET l_data_char = p_entrada.data					#que posssa retirar os pontos e a barra
	LET l_hora_char = p_entrada.hora					#para poder verificar o nome do arquivo
	LET l_nome_arq = l_data_char[1,2],l_data_char[4,5],l_data_char[7,10],l_hora_char[1,2],l_hora_char[4,5]
	
	IF NOT pol0947_cria_tabela() THEN 
		RETURN FALSE 
	END IF 

	SELECT nom_caminho 
	INTO l_caminho1
	FROM path_logix_v2																	#localizando caminho onde vai procurar o arquivo
	WHERE cod_empresa = p_cod_empresa 
	AND cod_sistema = "UNL"
	
	LET l_caminho = l_caminho1 CLIPPED, "FORNECEDORES_",l_nome_arq CLIPPED,'.txt'
		LOAD FROM l_caminho INSERT INTO t_nf_fornecedor
	
	IF STATUS = -805 THEN
		LET p_msg = "Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"			#fazendo o load do aquivo de fornecedores
		CALL log0030_mensagem(p_msg,"excla")
		CALL pol0947_imprime_erros(p_msg)									#carregando a tabela temporaria de fornecedores
		LET p_erro = TRUE 
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","t_nf_fornecedor")
			LET p_msg = log0030_txt_err_sql("LOAD","t_nf_fornecedor")
			CALL pol0947_imprime_erros(p_msg)
			LET p_erro = TRUE 
		END IF
	END IF
   
	LET l_caminho = l_caminho1 CLIPPED, "NFE_",l_nome_arq CLIPPED,'.txt'
		LOAD FROM l_caminho INSERT INTO t_nf_entrada
	
	IF STATUS = -805 THEN
		LET p_msg = "Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"														#fazendo o load do aquivo da nota fiscal entrada
		CALL log0030_mensagem(p_msg,"excla")
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 																				#carregando a tabela temporaria de Nota fiscal
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","t_nf_entrada")
			LET p_msg = log0030_txt_err_sql("LOAD","t_nf_entrada")
			CALL pol0947_imprime_erros(p_msg)
			LET p_erro = TRUE 
		END IF
	END IF
	
	LET l_caminho = l_caminho1 CLIPPED, "NFE_ITENS_",l_nome_arq CLIPPED,'.txt'
		LOAD FROM l_caminho INSERT INTO t_nf_item
	
	IF STATUS = -805 THEN
		LET p_msg = "Arquivo: ", l_caminho
		LET p_msg = p_msg CLIPPED, " Não encontrado!"													#fazendo o load do aquivo de itens da nota
		CALL log0030_mensagem(p_msg,"excla")	
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 																			#carregando a tabela temporaria de itens da nota
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("LOAD","t_nf_item")
			LET p_msg = log0030_txt_err_sql("LOAD","t_nf_item")
			CALL pol0947_imprime_erros(p_msg)
			LET p_erro = TRUE 
		END IF
	END IF
	IF p_erro THEN  
		FINISH REPORT pol0947_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		FINISH REPORT pol0947_imprime_nf_processada
		RETURN FALSE 
	ELSE
		RETURN TRUE
	END IF 
	
END FUNCTION

#----------------------------#
 FUNCTION pol0947_processar()#
#----------------------------#
DEFINE l_cont SMALLINT,
       l_cod_fornecedor 			CHAR(15)
	IF NOT pol0947_gerencia_fornecedor() THEN
		LET p_erro = TRUE 
	END IF 
	LET p_cont = 0
	LET p_val_total = 0 
	DECLARE cq_nfe SCROLL CURSOR WITH HOLD FOR  
	SELECT 	COD_EMPRESA,
	        NUM_NF,
	        SER_NF,
	        SSR_NF,         #ivo 15/08/2013
			ESPECIE_NF,
	        COD_FORNECEDOR,
	        cfop,
			DATA_EMISSAO,
			DATA_ENTRADA,
			DATA_VENCTO,  																						
			(VAL_TOT_DESCONTO/100),             																						
			(VAL_TOT_FRETE/100),                																						
			(VAL_TOT_NFF/100),
			num_conta_cont
     FROM  T_NF_ENTRADA                                 					                  																						
#	 GROUP BY COD_EMPRESA, NUM_NF, SER_NF, SSR_NF, COD_FORNECEDOR, 																					
#						cfop,	DATA_EMISSAO, DATA_ENTRADA, DATA_VENCTO , NUM_CONTA_CONT    																					
	
	FOREACH cq_nfe INTO p_nfe.*
	
	IF p_nfe.cod_empresa <> p_cod_empresa THEN 
		LET p_msg = "Empresa do arquivo não é igual a empresa corrente, processo cancelado."
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
		RETURN FALSE
	END IF 
	
	LET l_cod_fornecedor = '0',p_nfe.cod_fornecedor	
	
			IF  p_nfe.especie_nf = 'NFS'   THEN
				LET p_nfe.Ser_nf  = 'A'
				LET p_nfe.cfop    = ' '
			ELSE
				IF  p_nfe.especie_nf = 'REC'   THEN
				    LET p_nfe.Ser_nf  = 'A'
				    LET p_nfe.cfop    = ' '
                ELSE
					IF  p_nfe.especie_nf = 'DOC'   THEN
						LET p_nfe.Ser_nf  = 'A'
						LET p_nfe.cfop    = ' '
					ELSE
						LET p_nfe.Ser_nf  = '0'
					END IF	
				END IF
			END IF
	
		SELECT COUNT(NUM_NF)
		INTO l_cont																#verifica se a nota ja foi carregado
		FROM NF_SUP
		WHERE NUM_NF= p_nfe.Num_nf
		  AND COD_FORNECEDOR = l_cod_fornecedor
		  AND COD_EMPRESA    = p_cod_empresa
#		  AND SER_NF		 = p_nfe.Ser_nf
		  AND IES_ESPECIE_NF = p_nfe.especie_nf
		  AND SSR_NF		     = p_nfe.Ssr_nf       #ivo 15/08/2013
		  
	 	
	 	IF l_cont = 0 THEN 
			 	
			#CALL  pol0947_converte_valor("N")
			
			IF pol0947_insere_nf_sup() THEN

				DECLARE cq_nfe_item SCROLL CURSOR WITH HOLD FOR 
				SELECT COD_EMPRESA,
				        NUM_NF,
				        SER_NF,
						SSR_NF, 
				        COD_FORNECEDOR,
				        SEQUENCIA,  
				        cfop, 																								
						COD_ITEM,
						DEN_ITEM, 
						(QTD_ITEM/1000) qtd_item,
						UNIDADE_MEDIDA,       																							
						(PRE_UNIT/100000000) pre_unit,                                 																							
						SUM(VAL_DESC_ITEM)/100,   
						SUM(VAL_LIQ_ITEM)/100,                                  																							
						(pct_iss/100) pct_iss,
						SUM(VAL_TOT_BASE_ISS)/100,                              																							
						SUM(VAL_TOT_ISS)/100,                                   																							
						Cod_retencao,                                                      																							
						(pct_irpj/100) pct_irpj,
						SUM(VAL_BASE_IRPJ)/100,                                 																							
						SUM(VAL_IRPJ)/100,                                      																							
						(Pct_csll/100) pct_csll,
						SUM(VAL_BASE_CSLL)/100,                                 																							
						SUM(VAL_CSLL)/100,                                      																							
						(Pct_cofins/100) pct_cofins,
						SUM(VAL_BASE_COFINS)/100,                               																							
						SUM(VAL_COFINS)/100,                                    																							
						(Pct_pis/100) pct_pis,
						SUM(VAL_BASE_PIS)/100,                                  																							
						SUM(VAL_PIS)/100,                                       																							
						(Pct_icms/100) pct_icms,
						SUM(VAL_BASE_ICMS)/100,                                 																	 						
						SUM(VAL_ICMS)/100,                                      																							
						SUM(VAL_INSS)/100,                                      																							
 						SUM(VAL_FRETE)/100,
						SUM(VAL_PIS_REC)/100,  
						SUM(VAL_COFINS_REC)/100,  
						(pct_ipi/100) pct_ipi,
						SUM(VAL_BASE_IPI)/100,                                 																							
						SUM(VAL_IPI)/100        
					 FROM T_NF_ITEM                                             																							
					WHERE cod_empresa = p_nfe.cod_empresa                        																							
					  AND NUM_NF = p_nfe.Num_nf                                    																							
					  AND COD_FORNECEDOR = p_nfe.Cod_fornecedor                    																							
					GROUP BY COD_EMPRESA, NUM_NF, SER_NF, SSR_NF, COD_FORNECEDOR,          																							
					         SEQUENCIA, cfop, COD_ITEM, DEN_ITEM, 
							 qtd_item, UNIDADE_MEDIDA,  pre_unit,       
				           pct_iss, Cod_retencao, pct_irpj, Pct_csll, Pct_cofins, Pct_pis, Pct_icms, pct_ipi           
					ORDER BY 	SEQUENCIA
	
				FOREACH cq_nfe_item INTO p_nfe_item.*
					
					IF STATUS <> 0 THEN
						CALL log003_err_sql('Lendo:','t_nf_item')
						LET p_msg = log0030_txt_err_sql('Lendo:','t_nf_item'), " nota fiscal ",p_nfe.Num_nf
						CALL pol0947_imprime_erros(p_msg)
						LET p_erro = TRUE 			
					END IF 


					
					
			
				IF NOT  pol0947_insere_ar() THEN
				   RETURN FALSE 
				END IF 
				
				END FOREACH
				
				SELECT SUM(val_ipi_calc_item)
				  INTO p_val_ipi
				  FROM aviso_rec
				 WHERE cod_empresa   = p_aviso_rec.cod_empresa
				   AND num_aviso_rec = p_aviso_rec.num_aviso_rec
				
				IF p_val_ipi IS NULL THEN
				   LET p_val_ipi = 0
				END IF
				
				UPDATE nf_sup
				   SET val_ipi_calc = p_val_ipi,
				       val_ipi_nf   = p_val_ipi 
				 WHERE cod_empresa   = p_aviso_rec.cod_empresa
				   AND num_aviso_rec = p_aviso_rec.num_aviso_rec
				  
				IF STATUS <> 0 THEN
					CALL log003_err_sql("UPDATE","NF_SUP")
					LET p_msg = log0030_txt_err_sql("UPDATE","NF_SUP"), " nota fiscal ",p_nfe.Num_nf
					CALL pol0947_imprime_erros(p_msg)
					LET p_erro = TRUE 
				END IF
				
				IF 	pol0947_insere_piscofin_csl()  THEN 
				ELSE
					LET p_msg = 'Nota de entrada nº ',p_nfe.Num_nf,' Erro ao gravar cap_p_piscofin_csl!'
			        CALL pol0947_imprime_erros(p_msg)
				END IF 

			END IF
		ELSE
		    LET p_cod_fornecedor = l_cod_fornecedor
		    CALL pol0947_atu_grupo_desp()
			LET p_msg = 'Nota de entrada nº ',p_nfe.Num_nf,' Subserie ', p_nfe.SSr_nf,
			            ' Fornecedor ',p_nfe.cod_fornecedor,    ' já processada!'
			CALL pol0947_imprime_erros(p_msg)
		END IF
	END FOREACH
	
	IF p_erro THEN  
		FINISH REPORT pol0947_imprime 
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		FINISH REPORT pol0947_imprime_nf_processada
		RETURN FALSE 
	ELSE
		CALL pol0947_imprime_erros('DADOS CARREGADOS COM SUCESSO!')
		RETURN TRUE
	END IF 
END FUNCTION 

#-------------------------------#
 FUNCTION pol0947_insere_nf_sup()
#-------------------------------#
DEFINE  l_erro 		SMALLINT,
				l_estado 		CHAR(02),
				l_cont			SMALLINT,
				l_count     	INTEGER,
				l_tem_codigo 	INTEGER,
				l_tot_itens  	LIKE AVISO_REC.VAL_LIQUIDO_ITEM,
				l_cod_fiscal 	CHAR(04),
				l_codigo     	SMALLINT
	 
	 LET l_erro = FALSE

   IF NOT pol0947_gera_num_ar() THEN
      RETURN FALSE
   END IF
		
		LET p_cod_operacao = pol0947_troca_cod(p_nfe.cfop)

		LET p_nf_sup.cod_empresa 				=	p_nfe.cod_empresa							#char(2) not null 
		LET p_nf_sup.cod_empresa_estab 			=	NULL 										#char2)
		LET p_nf_sup.num_nf 					=	p_nfe.Num_nf								#DECIMAL(70) not null 
		LET p_nf_sup.ser_nf 					=	p_nfe.Ser_nf								#char(3) not null 
		LET p_nf_sup.ssr_nf 					=	p_nfe.Ssr_nf								#ivo 15/08/2013
		LET p_nf_sup.ies_especie_nf 			=	p_nfe.especie_nf							#char(3) not null 
		LET p_nf_sup.cod_fornecedor 			=	'0',p_nfe.Cod_fornecedor					#char(15) not null 
		
		IF 	(p_nfe.especie_nf  = 'NFS')  OR
			(p_nfe.especie_nf  = 'REC')  OR
			(p_nfe.especie_nf  = 'DOC')  THEN 
			LET p_nf_sup.cod_operacao           	= 	'    '  
			LET p_nf_sup.cod_regist_entrada 		=	'2'											#DECIMAL(20) not null 
		ELSE
			LET l_cod_fiscal = p_cod_operacao [1],p_cod_operacao[3,5]
			LET l_codigo     = l_cod_fiscal
			LET l_tem_codigo = 0 
			SELECT count(*) 
			  INTO l_tem_codigo
     		  FROM CODIGO_FISCAL
    		 WHERE cod_fiscal = l_codigo			 
			 IF SQLCA.SQLCODE <> 0 THEN
				LET p_msg_erro = 'FALTA CONSISTIR A NF, 1CODIGO FISCAL NAO ENCONTRADO'
				IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
					RETURN FALSE  
				END IF 
			ELSE	
				IF l_tem_codigo = 0 THEN 
					LET p_msg_erro = 'FALTA CONSISTIR A NF, 2CODIGO FISCAL NAO ENCONTRADO'
					IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
						RETURN FALSE  
					END IF 
				END IF 
			END IF 		
			LET p_nf_sup.cod_operacao           	= 	p_cod_operacao   
			LET p_nf_sup.cod_regist_entrada 		=	'1'											#DECIMAL(20) not null 
		END IF 	
		
		LET p_nf_sup.num_conhec 				=	0											#DECIMAL(70) not null 
		LET p_nf_sup.ser_conhec 				= 	0											#char(3) not null 
		LET p_nf_sup.ssr_conhec 				=	0											#DECIMAL(20) not null 
		LET p_nf_sup.cod_transpor 				=	0											#char(19) not null 
		LET p_nf_sup.num_aviso_rec 				=	p_num_prx_ar								#DECIMAL(60) not null 
		LET p_nf_sup.dat_emis_nf 				=	p_nfe.Data_emissao 							#date not null constraint 
		LET p_nf_sup.dat_entrada_nf 			=	p_nfe.Data_entrada							#date not null constraint 
		LET p_nf_sup.val_tot_nf_c 				=	p_nfe.Val_tot_nff							#DECIMAL(172) not null 
		LET p_nf_sup.val_tot_nf_d 				=	p_nfe.Val_tot_nff							#DECIMAL(172) not null 
		
		LET p_nf_sup.val_tot_icms_nf_d =	0
		
		SELECT SUM(val_icms),
			   SUM(val_liq_item)/100
		INTO p_nf_sup.val_tot_icms_nf_d,
			 l_tot_itens
		FROM  T_NF_ITEM
		WHERE cod_empresa = p_nfe.cod_empresa
	 	  AND NUM_NF = p_nfe.Num_nf
		  AND COD_FORNECEDOR = p_nfe.Cod_fornecedor
		
		IF SQLCA.SQLCODE <> 0 OR  p_nf_sup.val_tot_icms_nf_d IS NULL THEN
			LET p_nf_sup.val_tot_icms_nf_d  =	0	
		ELSE 
			LET p_nf_sup.val_tot_icms_nf_d  = p_nf_sup.val_tot_icms_nf_d /100
		END IF 
		
		LET p_nf_sup.val_tot_icms_nf_c 			=	p_nf_sup.val_tot_icms_nf_d 		#DECIMAL(172) not null constraint "informix".nn1069_5534
#		LET p_nf_sup.val_tot_desc 					=	p_nfe.Val_tot_desconto 		#DECIMAL(172) not null constraint "informix".nn1069_5535
		LET p_nf_sup.val_tot_desc 					=	0							#DECIMAL(172) not null constraint "informix".nn1069_5535

		LET p_nf_sup.val_tot_acresc 				=	0															#DECIMAL(172) not null constraint "informix".nn1069_5536
		LET p_nf_sup.val_ipi_nf 						=	0															#DECIMAL(172) not null constraint "informix".nn1069_5537
		LET p_nf_sup.val_ipi_calc 					=	0															#DECIMAL(172) not null constraint "informix".nn1069_5538
		LET p_nf_sup.val_despesa_aces 			=	0															#DECIMAL(172) not null constraint "informix".nn1069_5539
		LET p_nf_sup.val_adiant 						=	0															#DECIMAL(172) not null constraint "informix".nn1069_5540
		LET p_nf_sup.ies_tip_frete 					=	'0'														#char(1) not null constraint "informix".nn1069_5541
		LET p_nf_sup.cnd_pgto_nf 						=	p_parametro.cond_pagto #par		#DECIMAL(30) not null constraint "informix".nn1069_5542
		LET p_nf_sup.cod_mod_embar 					=	3															#DECIMAL(20) not null constraint "informix".nn1069_5543
			
		LET p_nf_sup.nom_resp_aceite_er 		=	' '														#char(8)
		LET p_nf_sup.ies_incl_cap 					=	'N'														#char(1) not null constraint "informix".nn1069_5545
		LET p_nf_sup.ies_incl_contab 				=	'N'														#char(1) not null constraint "informix".nn1069_5546
		
		
		LET p_nf_sup.ies_calc_subst 				=	"N" 													#char(1)
		LET p_nf_sup.val_bc_subst_d 				=	0															#DECIMAL(172) not null constraint "informix".nn1069_5548
		LET p_nf_sup.val_icms_subst_d 			=	0															#DECIMAL(172) not null constraint "informix".nn1069_5549
		LET p_nf_sup.val_bc_subst_c 				=	0															#DECIMAL(172) not null constraint "informix".nn1069_5550
		LET p_nf_sup.val_icms_subst_c 			=	0															#DECIMAL(172) not null constraint "informix".nn1069_5551
		LET p_nf_sup.cod_imp_renda 					=	''															#char(4)
		LET p_nf_sup.val_imp_renda 					=	0															#DECIMAL(172) not null 
		LET p_nf_sup.ies_situa_import 			=	' '														#char(1) not null constraint "informix".nn1069_5553
		LET p_nf_sup.val_bc_imp_renda 			=	0															#DECIMAL(172) not null constraint "informix".nn1069_5554
		LET p_nf_sup.ies_nf_aguard_nfe 			=	'1'														#char(1)
		
		IF p_nf_sup.val_tot_nf_d <> l_tot_itens  THEN 
			LET p_msg_erro = 'FALTA CONSISTIR A NF, TOT.DA NF DIFERENTE DA SOMA DOS ITENS'
			IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
				RETURN FALSE  
			END IF 
		END IF 
		
		IF p_nf_sup.val_tot_icms_nf_d > 0 THEN 
			LET p_msg_erro = 'FALTA CONSISTIR A NOTA FISCAL COM ICMS'
			IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
				RETURN FALSE  
			END IF 
		END IF 
		
# Verifica se existem mensagem de erro gravado para a nota fiscal se existir  
# grava campo ies_nf_com_erro com S-Sim para que o erro apareca no sup3760.   

  	SELECT COUNT(*)   
	INTO l_count
	FROM NF_SUP_ERRO
	WHERE empresa	= p_nf_sup.cod_empresa
	AND   num_aviso_rec	= p_nf_sup.num_aviso_rec

	IF STATUS <> 0 THEN                                                      
		LET l_count  = 0 
    END IF  
	
	IF l_count  > 0   THEN 
		LET p_nf_sup.ies_nf_com_erro 				=	"S" 													#char(1) not null constraint "informix".nn1069_5544
	ELSE
		LET p_nf_sup.ies_nf_com_erro 				=	"N" 													#char(1) not null constraint "informix".nn1069_5544
	END IF  
	
   INSERT INTO nf_sup VALUES (p_nf_sup.*)

   IF sqlca.SQLCODE <> 0 THEN
      CALL log003_err_sql("INSERT","NF_SUP")
      LET P_msg = log0030_txt_err_sql("INSERT","NF_SUP"), " nota fiscal ",p_nfe.Num_nf
      CALL pol0947_imprime_erros(p_msg)
      LET p_erro = TRUE 
      RETURN FALSE
   END IF
   
   	LET p_cont = p_cont + 1
	LET p_val_total = p_val_total + p_nf_sup.val_tot_nf_d
	
	LET p_mensagem = p_nfe.Num_nf,"  ",p_nfe.cod_fornecedor,"  ", p_nf_sup.val_tot_nf_d
	CALL pol0947_imprime_NF(p_mensagem)

  INSERT INTO aviso_rec_compl VALUES
		(p_nf_sup.cod_empresa ,p_nf_sup.num_aviso_rec,NULL,NULL,NULL,NULL,NULL,NULL,' ',NULL,NULL,NULL,'N',NULL,NULL,NULL,0)
	IF SQLCA.SQLCODE <> 0 THEN
	   MESSAGE "Erro INSERT AVISO_REC_COMPL " ATTRIBUTE(REVERSE)
	   CALL log003_err_sql("INSERT","AVISO_REC_COMPL")
	    LET P_msg = log0030_txt_err_sql("INSERT","AVISO_REC_COMPL"), " nota fiscal ",p_nfe.Num_nf
      CALL pol0947_imprime_erros(p_msg)
      
      LET p_erro = TRUE 
	   RETURN FALSE
	END IF 
	
	RETURN TRUE 
 
END FUNCTION
#---------------------------------------------------#
 FUNCTION pol0947_grava_erro(l_msg_erro, l_num_seq)
#---------------------------------------------------#
DEFINE 	l_msg_erro		CHAR(60),
		l_num_seq       DEC(3,0)

	
	   INSERT INTO nf_sup_erro
	        VALUES (p_cod_empresa,
	                p_nf_sup.num_aviso_rec,
	                l_num_seq,
	                l_msg_erro,
	                '1',
	                'S',
	                0)
   
                
	   IF sqlca.SQLCODE <> 0 THEN
	      CALL log003_err_sql("INSERT","NF_SUP_ERRO")
	      LET p_msg = log0030_txt_err_sql("INSERT","NF_SUP_ERRO"), " nota fiscal ",p_nfe.Num_nf
	      CALL pol0947_imprime_erros(p_msg)
	      LET p_erro = TRUE 
	      RETURN FALSE
	   END IF

	RETURN TRUE 
 
END FUNCTION
#-----------------------------#
 FUNCTION pol0947_gera_num_ar()
#-----------------------------#
DEFINE  l_erro SMALLINT
	LET l_erro = FALSE
	
   SELECT par_val    
     INTO p_num_prx_ar 
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa    
      AND cod_parametro = "num_prx_ar" 

    IF sqlca.SQLCODE <>   0   THEN 
    	 LET l_erro = TRUE 
       CALL log003_err_sql("SELECT" ,"PAR_SUP_PAD")
       LET p_msg = log0030_txt_err_sql("SELECT" ,"PAR_SUP_PAD"), " nota fiscal ",p_nfe.Num_nf
       CALL pol0947_imprime_erros(p_msg)
       LET p_erro = TRUE 

    END IF

    UPDATE par_sup_pad  
       SET par_val = (par_val + 1)
     WHERE cod_empresa   = p_cod_empresa    
       AND cod_parametro = "num_prx_ar" 
	
	IF l_erro THEN
		RETURN FALSE 
	ELSE
		RETURN TRUE 
	END IF 
	
END FUNCTION
          
   
#---------------------------#
FUNCTION pol0947_insere_ar()#
#---------------------------#
	DEFINE 	l_icms  DECIMAL(15,0),
			l_cod_cfop_refer  char(04),
			l_val_liquido   LIKE AVISO_REC.VAL_LIQUIDO_ITEM,
			l_tem_codigo 	INTEGER,
			l_cod_fiscal 	CHAR(04),
			l_codigo     	SMALLINT,
			l_seq           DECIMAL(3,0),
			l_achou         INTEGER,
			l_count2		INTEGER,
			l_gru_ctr_desp_item DECIMAL(4,0)
			
	LET l_achou = 0 
			
	SELECT COUNT(*) 
	  INTO l_achou 
	  FROM aviso_rec
	WHERE  cod_empresa 		= p_nfe_item.cod_empresa
     AND   num_aviso_rec 	= p_num_prx_ar
     AND   num_seq          = p_nfe_item.Sequencia
	 
	IF l_achou >  0   THEN 
	   SELECT MAX(num_seq) 
	     INTO l_seq
	     FROM aviso_rec
	    WHERE  cod_empresa 		= p_nfe_item.cod_empresa
          AND   num_aviso_rec 	= p_num_prx_ar
		  
		LET  p_nfe_item.Sequencia = l_seq + 1
	END IF 
	 
	LET p_aviso_rec.cod_empresa 			=	p_nfe_item.cod_empresa				#char(2) not null 
	LET p_aviso_rec.cod_empresa_estab 		=	NULL								#char(2),
	LET p_aviso_rec.num_aviso_rec 			=	p_num_prx_ar						#DECIMAL(6,0)
	LET p_aviso_rec.num_seq 				=	p_nfe_item.Sequencia				#DECIMAL(3,0) not null
	LET p_aviso_rec.dat_inclusao_seq 		=	TODAY								#date,
	LET p_aviso_rec.ies_situa_ar 			=	"E"									#char(1) not null 
	LET p_aviso_rec.ies_incl_almox 			=	"N"									#char(1) not null 
	LET p_aviso_rec.ies_receb_fiscal 		=	"S"									#char(1) not null 
	LET p_aviso_rec.ies_liberacao_ar 		=	"1"									#char(1) not null 
	LET p_aviso_rec.ies_liberacao_cont 		=	"S"									#char(1) not null 
	LET p_aviso_rec.ies_liberacao_insp 		=	"S"									#char(1) not null 
	LET p_aviso_rec.ies_diverg_listada 		=	"N"									#char(1) not null 
	LET p_aviso_rec.ies_item_estoq 			=	"N"									#char(1) not null 
	LET p_aviso_rec.ies_controle_lote 		=	"N"									#char(1) not null 
	
	SELECT cod_comprador,
				gru_ctr_desp,
				cod_tip_despesa,
				num_conta,
				ies_tip_incid_ipi,
				ies_tip_incid_icms,
				cod_fiscal
	INTO 	p_aviso_rec.cod_comprador,
				p_aviso_rec.gru_ctr_desp_item,
				p_aviso_rec.cod_tip_despesa,
				p_num_conta,
				p_aviso_rec.ies_tip_incid_ipi,
				p_aviso_rec.ies_incid_icms_ite,
				p_aviso_rec.cod_fiscal_item
	FROM 	item_sup  
	WHERE cod_empresa = p_aviso_rec.cod_empresa
	AND  	cod_item   = p_nfe_item.Cod_item  
	
	IF SQLCA.SQLCODE <> 0 THEN
		LET p_aviso_rec.cod_comprador			= 0
		LET p_aviso_rec.gru_ctr_desp_item		= 0
		LET p_aviso_rec.cod_tip_despesa			= 0
	END IF 
	
	IF	p_num_conta IS NULL THEN
		LET p_num_conta = 0
	END IF 
	
	IF p_aviso_rec.gru_ctr_desp_item IS NULL THEN
		LET p_aviso_rec.gru_ctr_desp_item		= 0
	END IF 
	
	
	SELECT cod_cla_fisc,
				cod_local_estoq,
				cod_lin_prod, 
				cod_lin_recei,
				cod_seg_merc, 
				cod_cla_uso             
	INTO 	p_aviso_rec.cod_cla_fisc,
				p_aviso_rec.cod_local_estoq,
				p_aen.cod_lin_prod,
				p_aen.cod_lin_recei,
				p_aen.cod_seg_merc,
				p_aen.cod_cla_uso
	FROM 	item  
	WHERE cod_empresa =  p_cod_empresa
	AND  	cod_item    = p_nfe_item.cod_item
	
	IF SQLCA.SQLCODE <> 0 THEN 
		LET p_aviso_rec.cod_cla_fisc = '0'
	END IF 
	
	LET p_aviso_rec.cod_local_estoq = ' '
	
	#LET p_aviso_rec.cod_comprador 				=									#DECIMAL(3,0) not null
	LET p_aviso_rec.num_pedido 					=	NULL							#DECIMAL(6,0),
	LET p_aviso_rec.num_oc 						=	NULL							#DECIMAL(9,0),
	LET p_aviso_rec.cod_item 					=	p_nfe_item.Cod_item				#char(15) not null 
	LET p_aviso_rec.den_item 					=	p_nfe_item.Den_item				#char(50) not null 
	#LET p_aviso_rec.cod_cla_fisc 				=	 								#char(10) not null 
	LET p_aviso_rec.cod_unid_med_nf 			=	p_nfe_item.Unidade_medida		#char(3) not null 

	IF p_nfe_item.Pre_unit IS NULL THEN 
		LET p_nfe_item.Pre_unit = 0
	END IF 
	
	LET p_aviso_rec.pre_unit_nf 				=	p_nfe_item.Pre_unit				#DECIMAL(17,6) not null 
	LET p_aviso_rec.val_despesa_aces_i 			=	0								#DECIMAL(17,2) not null 
	LET p_aviso_rec.ies_da_bc_ipi 				=	"N"								#char(1),
	
	CASE 
		WHEN p_aviso_rec.ies_tip_incid_ipi = "C"
			LET p_aviso_rec.cod_incid_ipi 			=	1
		WHEN p_aviso_rec.ies_tip_incid_ipi = "O"									#DECIMAL(2,0) not null 
			LET p_aviso_rec.cod_incid_ipi 			=	3
		WHEN p_aviso_rec.ies_tip_incid_ipi = "I"
			LET p_aviso_rec.cod_incid_ipi 			=	2
		OTHERWISE
			LET p_aviso_rec.cod_incid_ipi 			=	0
	END CASE
	 
	#LET p_aviso_rec.ies_tip_incid_ipi 			=	"O"								#char(1) not null 
	LET p_aviso_rec.pct_direito_cred 			=	100								#DECIMAL(6,3) not null 

	LET p_aviso_rec.pct_ipi_tabela 				=	p_nfe_item.pct_ipi				#DECIMAL(6,3) not null 
	LET p_aviso_rec.pct_ipi_declarad 			=	p_nfe_item.pct_ipi				#DECIMAL(6,3) not null 
	LET p_aviso_rec.val_base_c_ipi_it 			=	p_nfe_item.Val_liq_item			#DECIMAL(17,2) not null 
 	LET p_aviso_rec.val_ipi_calc_item 			=	p_nfe_item.Val_liq_item * p_nfe_item.pct_ipi / 100
	LET p_aviso_rec.val_ipi_decl_item 			=	p_nfe_item.Val_liq_item * p_nfe_item.pct_ipi / 100	
	LET p_aviso_rec.val_base_c_ipi_da 			=	0								#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_ipi_desp_aces 			=	0								#DECIMAL(17,2) not null 

	LET p_aviso_rec.ies_bitributacao 			=	"N"								#char(1) not null 
##	LET p_aviso_rec.val_desc_item 				=	p_nfe_item.Val_desc_item		#DECIMAL(17,6) not null 
	LET p_aviso_rec.val_desc_item 				=	0								#DECIMAL(17,6) not null 
	LET p_aviso_rec.val_liquido_item 			=	p_nfe_item.Val_liq_item			#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_contabil_item 			=	p_nfe_item.Val_liq_item			#DECIMAL(17,2) not null 
	LET p_aviso_rec.qtd_declarad_nf 			=	p_nfe_item.Qtd_item				#DECIMAL(12,3) not null 
	LET p_aviso_rec.qtd_recebida 				=	p_nfe_item.Qtd_item				#DECIMAL(12,3) not null 
	LET p_aviso_rec.qtd_devolvid 				=	0								#DECIMAL(12,3) not null 
	LET p_aviso_rec.dat_devoluc 				=	NULL							#date,
	LET p_aviso_rec.val_devoluc 				= 	0								#DECIMAL(17,2) not null 
	LET p_aviso_rec.num_nf_dev 					=	0								#DECIMAL(7,0) not null 
	LET p_aviso_rec.qtd_rejeit 					=	0								#DECIMAL(12,3) not null 
	LET p_aviso_rec.qtd_liber 					=	p_nfe_item.Qtd_item				#DECIMAL(12,3) not null 
	LET p_aviso_rec.qtd_liber_excep 			=	0								#DECIMAL(12,3) not null 
	LET p_aviso_rec.cus_tot_item 				=	0								#DECIMAL(17,2) not null
	
	{IF LENGTH(p_nf_sup.cod_operacao CLIPPED) <=2 THEN
		LET p_nf_sup.cod_operacao = p_nf_sup.cod_operacao, p_aviso_rec.cod_fiscal_item CLIPPED
	END IF
	
	CASE
		WHEN p_nf_sup.cod_operacao[1] = '7'					#acerta a cpof						
			LET p_aviso_rec.cod_fiscal_item = '3.',p_aviso_rec.cod_fiscal_item CLIPPED
		WHEN p_nf_sup.cod_operacao[1] = '6'
			LET p_aviso_rec.cod_fiscal_item = '2.',p_aviso_rec.cod_fiscal_item CLIPPED
		WHEN p_nf_sup.cod_operacao[1] = '5'
			LET p_aviso_rec.cod_fiscal_item = '1.',p_aviso_rec.cod_fiscal_item CLIPPED
	END CASE
	CASE
		WHEN p_aviso_rec.cod_fiscal_item[1] = '2'
			LET p_nf_sup.cod_operacao = '6',p_aviso_rec.cod_fiscal_item[2,7] CLIPPED
		WHEN p_aviso_rec.cod_fiscal_item[1] = '1'
			LET p_nf_sup.cod_operacao= '5',p_aviso_rec.cod_fiscal_item[2,7] CLIPPED
	END CASE
				
	UPDATE nf_sup 
		SET cod_operacao = p_nf_sup.cod_operacao
	WHERE cod_empresa 	=  p_nf_sup.cod_empresa
		AND num_nf				= p_nf_sup.num_nf
	AND num_aviso_rec	= p_nf_sup.num_aviso_rec}

	#LET p_aviso_rec.cod_fiscal_item 			= p_parametro.clas_fiscal
	#LET p_aviso_rec.gru_ctr_desp_item 			=						#DECIMAL(4,0) not null
	#LET p_aviso_rec.cod_local_estoq 			=						#char(10) not null  
		  
    LET 	l_cod_cfop_refer = ' '
	LET p_cfop_orig = p_nfe_item.cfop[4,7]
	SELECT cfop_ref
    INTO   l_cod_cfop_refer
	FROM   CFOP_REFERENCIA_792G 
    WHERE  cfop_orig = p_cfop_orig
	
	IF STATUS = 0 THEN        
       LET 	p_nfe_item.cfop[4,7] = l_cod_cfop_refer
    END IF  

# NO CASO SE O ITEM FOR 888888888888888 O ITEM EH DE ENERGIA ELETRICA, ENTAO O CFOP TEM QUE SER IGUAL A 1.253 ou 2.253 	
	IF p_aviso_rec.cod_item  = '888888888888888'  THEN 
		LET p_nfe_item.cfop[5,7] = 253
	END IF 
	
	LET p_aviso_rec.cod_fiscal_item =	
      p_nfe_item.cfop[4], '.', p_nfe_item.cfop[5,7]
	  
	CASE
		WHEN p_nfe_item.cfop[4] = '7'					#acerta a cpof						
			LET p_aviso_rec.cod_fiscal_item = '3.',p_nfe_item.cfop[5,7] CLIPPED
		WHEN p_nfe_item.cfop[4] = '6'
			LET p_aviso_rec.cod_fiscal_item = '2.',p_nfe_item.cfop[5,7] CLIPPED
		WHEN p_nfe_item.cfop[4] = '5'
			LET p_aviso_rec.cod_fiscal_item = '1.',p_nfe_item.cfop[5,7] CLIPPED
	END CASE
	
#  Esta rotina abaixo eh para verificar se o cfop do item existe.
	
	LET l_cod_fiscal = p_aviso_rec.cod_fiscal_item [1],p_aviso_rec.cod_fiscal_item[3,5]
		
	LET l_codigo     = l_cod_fiscal
	LET l_tem_codigo = 0 

	SELECT count(*) 
	  INTO l_tem_codigo
      FROM CODIGO_FISCAL
     WHERE cod_fiscal = l_codigo			 
	 IF SQLCA.SQLCODE <> 0 THEN
		LET p_msg_erro = 'FALTA CONSISTIR A NF, 3CODIGO FISCAL NAO ENCONTRADO'
		IF NOT pol0947_grava_erro(p_msg_erro, p_aviso_rec.num_seq)  THEN 
		   RETURN FALSE  
		END IF 
	 ELSE	
		IF l_tem_codigo = 0 THEN 
			LET p_msg_erro = 'FALTA CONSISTIR A NF, 4CODIGO FISCAL NAO ENCONTRADO'
			IF NOT pol0947_grava_erro(p_msg_erro, p_aviso_rec.num_seq )  THEN 
				RETURN FALSE  
			END IF 
		END IF 
	 END IF 
	  
	LET p_aviso_rec.num_lote 						=	' '									#char(15),
	LET p_aviso_rec.cod_operac_estoq 				=	0									#char(4) not null 
	LET p_aviso_rec.val_base_c_item_d 				=	p_nfe_item.Val_liq_item				#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_base_c_item_c 				=	p_nfe_item.Val_liq_item				#DECIMAL(17,2) not null 
	LET p_aviso_rec.pct_icms_item_d 				=	0									#DECIMAL(5,3) not null 
	


	LET p_aviso_rec.pct_icms_item_c 			= 	p_nfe_item.pct_icms		#DECIMAL(5,3) not null constraint "informix".nn953_4667,
	LET p_aviso_rec.pct_icms_item_d 			= 	p_nfe_item.pct_icms	
	LET p_aviso_rec.val_icms_item_d 			=	p_nfe_item.Val_icms						#DECIMAL(17,2) not null constraint "informix".nn953_4672,
	LET p_aviso_rec.val_icms_item_c 			=	p_nfe_item.Val_icms						#DECIMAL(17,2) not null constraint "informix".nn953_4673,

	
#--O programa verifica primeiro se a conta contábil que veio no arquivo do cabecalho na nota tem um grupo de despesa associado, se tiver usa ele senao
#--quando o tipo da nota eh REC (recibo), pois REC eh usado apenas para locacao o grupo de despesa sera 9 devido a necessidade do SPED PIS COFINS
	
	INITIALIZE l_gru_ctr_desp_ite  TO  NULL 
	SELECT gru_ctr_desp_item
	  INTO	l_gru_ctr_desp_item
	  FROM cta_grupo_man912
	 WHERE num_conta_cont =  p_nfe.num_conta_cont  
	
	IF SQLCA.SQLCODE <> 0 THEN
		IF  p_nfe.especie_nf = 'REC'   THEN
			LET p_aviso_rec.gru_ctr_desp_item = 9
		ELSE
			IF  p_nfe.especie_nf = 'DOC'   THEN
				LET p_aviso_rec.gru_ctr_desp_item = 10
			END IF 
		END IF 	
		
		IF  p_nfe_item.pct_icms  > 0 THEN 
			LET p_aviso_rec.gru_ctr_desp_item = p_nfe_item.pct_icms
		END IF 	
	
#--Quando for energia eletrica e o item nao tiver icms, mudo o grupo icms para 10 e 
	
		IF (p_aviso_rec.cod_item  = '888888888888888')  
		AND (p_nfe_item.Val_icms   = 0) THEN 
			LET p_aviso_rec.gru_ctr_desp_item = 10
		END IF   	
	ELSE 	
		LET p_aviso_rec.gru_ctr_desp_item = l_gru_ctr_desp_item
	END IF 	
	
#--Quando for energia eletrica e o item nao tiver icms, mudo o item para '666666666666666'
	
	IF (p_aviso_rec.cod_item  = '888888888888888')  
	AND (p_nfe_item.Val_icms   = 0) THEN 
		LET p_aviso_rec.cod_item  = '666666666666666'
		LET p_aviso_rec.ies_incid_icms_ite = 'O'
	END IF   
	
	LET p_aviso_rec.pct_red_bc_item_d 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_red_bc_item_c 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_diferen_item_d 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_diferen_item_c 				=	0							#DECIMAL(5,3) not null 
	
	LET p_aviso_rec.val_base_c_icms_da 				=	0							#DECIMAL(17,2) not null
	LET p_aviso_rec.val_icms_diferen_i 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_icms_desp_aces 				=	0							#DECIMAL(17,2) not null 
	####alterar
	#LET p_aviso_rec.ies_incid_icms_ite 			=	'N'							#char(1) not null
	LET p_aviso_rec.val_frete 						=	0							#DECIMAL(17,2) not null
	LET p_aviso_rec.val_icms_frete_d 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_icms_frete_c 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_base_c_frete_d 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_base_c_frete_c 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_icms_diferen_f 				=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.pct_icms_frete_d 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_icms_frete_c 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_red_bc_frete_d 				=	0							#DECIMAL(5,3) not null
	LET p_aviso_rec.pct_red_bc_frete_c 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_diferen_fret_d 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.pct_diferen_fret_c 				=	0							#DECIMAL(5,3) not null 
	LET p_aviso_rec.val_acrescimos 					=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.val_enc_financ 					=	0							#DECIMAL(17,2) not null 
	LET p_aviso_rec.ies_contabil 					=	'S'							#char(1) not null  
	LET p_aviso_rec.ies_total_nf 					=	'S'							#char(1) not null  
	LET p_aviso_rec.val_compl_estoque 				=	0							#DECIMAL(17,2) not null  
	LET p_aviso_rec.dat_ref_val_compl 				=	NULL						#date,
	LET p_aviso_rec.pct_enc_financ 					=	0							#DECIMAL(13,10) not null  
	LET p_aviso_rec.cod_cla_fisc_nf 				=	p_aviso_rec.cod_cla_fisc	#char(10) not null 
	#LET p_aviso_rec.cod_tip_despesa 				=								#DECIMAL(4,0) not null 
	LET p_aviso_rec.observacao 						=	NULL						#char(20)
	
	
	INSERT INTO aviso_rec    VALUES (p_aviso_rec.*)
	IF sqlca.SQLCODE <> 0 THEN
	   CALL log003_err_sql("INSERT","AVISO_REC")
	   LET p_msg = log0030_txt_err_sql("INSERT","AVISO_REC"), " nota fiscal ",p_nfe.Num_nf
     CALL pol0947_imprime_erros(p_msg)
     LET p_erro = TRUE 
	   RETURN FALSE
	END IF

# Se a nota for de energia eletrica, incluo registro na tabela SUP_COMPL_NF_SUP
	
    IF ((p_aviso_rec.cod_item  =  '888888888888888')  OR
	     (p_aviso_rec.cod_item  = '666666666666666'))     THEN  
		LET  l_count2 = 0 
	    SELECT COUNT(*) 
		INTO   l_count2
		FROM  sup_compl_nf_sup 
		WHERE empresa = p_cod_empresa
		  AND aviso_recebto =  p_aviso_rec.num_aviso_rec
		  
		IF l_count2 = 0 THEN   
			INSERT INTO sup_compl_nf_sup   VALUES (p_aviso_rec.cod_empresa, p_aviso_rec.num_aviso_rec, '    06' )
				IF sqlca.SQLCODE <> 0 THEN
					CALL log003_err_sql("INSERT","SUP_COMPL_NF_SUP")
					LET p_msg = log0030_txt_err_sql("INSERT","SUP_COMPL_NF_SUP"), " nota fiscal ",p_nfe.Num_nf
					CALL pol0947_imprime_erros(p_msg)
					LET p_erro = TRUE 
					RETURN FALSE
				END IF
		END IF
	END IF	
		
		
	LET l_val_liquido =   p_aviso_rec.qtd_declarad_nf * p_aviso_rec.pre_unit_nf 
	 
	 
		IF p_aviso_rec.val_liquido_item <> l_val_liquido  THEN 
			LET p_msg_erro = 'FALTA CONSISTIR A NF, VALOR LIQUIDO DIF.DE QTD x PRE_UNIT'
			IF NOT pol0947_grava_erro(p_msg_erro, p_aviso_rec.num_seq )  THEN 
				RETURN FALSE  
			END IF 
		END IF  
	 
	
	LET p_audit_ar.cod_empresa = p_aviso_rec.cod_empresa
	LET p_audit_ar.num_aviso_rec = p_aviso_rec.num_aviso_rec
	LET p_audit_ar.num_seq = p_nfe_item.Sequencia
	LET p_audit_ar.nom_usuario = p_user
	LET p_audit_ar.dat_hor_proces = CURRENT
	LET p_audit_ar.num_prog = 'pol0947'
	LET p_audit_ar.ies_tipo_auditoria = '1'
	
	INSERT INTO audit_ar VALUES(p_audit_ar.*)
	
	IF sqlca.SQLCODE <> 0 THEN
	   CALL log003_err_sql("INSERT","AUDIT_AR")
	   LET p_msg = log0030_txt_err_sql("INSERT","AUDIT_AR"), " nota fiscal ",p_nfe.Num_nf
     CALL pol0947_imprime_erros(p_msg)
     LET p_erro = TRUE 
	   RETURN FALSE
	END IF       
	
	LET p_dest_ar.cod_empresa        = p_aviso_rec.cod_empresa
	LET p_dest_ar.num_aviso_rec      = p_aviso_rec.num_aviso_rec
	LET p_dest_ar.num_seq            = p_nfe_item.Sequencia
	LET p_dest_ar.sequencia          = 1                                
	LET p_dest_ar.cod_area_negocio   = p_aen.cod_lin_prod
	LET p_dest_ar.cod_lin_negocio    = p_aen.cod_lin_recei
	LET p_dest_ar.pct_particip_comp  = 100
	LET p_dest_ar.num_conta_deb_desp = p_num_conta
	LET p_dest_ar.cod_secao_receb    = 0          
	LET p_dest_ar.qtd_recebida       = p_nfe_item.Qtd_item
	LET p_dest_ar.ies_contagem       = 'S' 
	
	INSERT INTO dest_aviso_rec       VALUES (p_dest_ar.*)
	IF sqlca.SQLCODE <> 0 THEN
	   MESSAGE "Erro INSERT DEST_AVISO_REC   " ATTRIBUTE(REVERSE)
	   CALL log003_err_sql("INSERT","DEST_AVISO_REC")
	   CALL pol0947_imprime_erros('ERRO AO INSERIR DEST_AVISO_REC')
	   LET p_erro = TRUE 
	   RETURN FALSE
	END IF       
	
	LET p_ar_sq.cod_empresa       =  p_aviso_rec.cod_empresa
	LET p_ar_sq.num_aviso_rec     =  p_aviso_rec.num_aviso_rec
	LET p_ar_sq.num_seq           =  p_aviso_rec.num_seq
	LET p_ar_sq.cod_fiscal_compl  =  0
	LET p_ar_sq.val_base_d_ipi_it =  0
	
	INSERT INTO aviso_rec_compl_sq       VALUES (p_ar_sq.*)
	IF SQLCA.SQLCODE <> 0 THEN
	   MESSAGE "Erro INSERT AVISO_REC_COMPL_SQ " ATTRIBUTE(REVERSE)
	   CALL log003_err_sql("INSERT","AVISO_REC_COMPL_SQ")
	   LET p_msg = log0030_txt_err_sql("INSERT","AVISO_REC_COMPL_SQ"), " nota fiscal ",p_nfe.Num_nf
     CALL pol0947_imprime_erros(p_msg)
     LET p_erro = TRUE 
	   RETURN FALSE
	END IF  

   IF p_nfe_item.val_pis IS NULL THEN
      LET p_nfe_item.val_pis = 0
   END IF
   
   IF p_nfe_item.val_base_pis IS NULL THEN
      LET p_nfe_item.val_base_pis = 0
   END IF

   IF p_nfe_item.Val_cofins IS NULL THEN
      LET p_nfe_item.Val_cofins = 0
   END IF
   
   IF p_nfe_item.Val_base_cofins IS NULL THEN
      LET p_nfe_item.Val_base_cofins = 0
   END IF
   
   IF p_nfe_item.val_pis_rec > 0 OR p_nfe_item.Val_cofins_rec > 0 THEN
      IF NOT pol0947_ins_pis_cof() THEN
         RETURN FALSE
      END IF
   END IF
      
	RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0947_ins_pis_cof()
#-----------------------------#

   DEFINE p_sup_ar 		record like ar_pis_cofins.*,
		  p_sup_par_ar  RECORD like sup_par_ar.*,
		  l_count   INTEGER
   
   SELECT pct_pis, pct_cofins
     INTO p_sup_ar.pct_pis_item_d, p_sup_ar.pct_cofins_item_d
     FROM retencao_912
	 WHERE cod_empresa  = p_cod_empresa
	   AND cod_retencao = 0 
	   
   	IF SQLCA.SQLCODE <> 0 THEN
		LET p_sup_ar.pct_pis_item_d 	= 1,65
		LET p_sup_ar.pct_cofins_item_d	= 7,6
	END IF    
   
   IF p_nfe_item.val_pis_rec   is NULL THEN 
      LET p_nfe_item.val_pis_rec = 0 
   END IF 	  
   
   IF p_nfe_item.val_cofins_rec  is NULL THEN 
      LET p_nfe_item.val_cofins_rec = 0 
   END IF 	  
   
   IF  (p_nfe_item.val_pis_rec      = 0)  
   AND (p_nfe_item.val_cofins_rec   = 0 ) THEN 
      RETURN   TRUE
   END IF 	 

   let p_sup_ar.cod_empresa         =  p_aviso_rec.cod_empresa  
   let p_sup_ar.num_aviso_rec      	=  p_aviso_rec.num_aviso_rec
   let p_sup_ar.num_seq  			=  p_aviso_rec.num_seq         
   let p_sup_ar.val_base_pis_d  	=  p_nfe_item.val_pis_rec               
   let p_sup_ar.val_base_cofins_d	=  p_nfe_item.val_cofins_rec                                                      
   let p_sup_ar.val_pis_d   		=  ((p_nfe_item.val_pis_rec    * p_sup_ar.pct_pis_item_d)/ 100)            
   let p_sup_ar.val_cofins_d  		=  ((p_nfe_item.val_cofins_rec * p_sup_ar.pct_cofins_item_d)/ 100)    
   let p_sup_ar.ies_base_calc  		=  "U"
  
   INSERT INTO ar_pis_cofins
    VALUES(p_sup_ar.cod_empresa,
           p_sup_ar.num_aviso_rec,
           p_sup_ar.num_seq,
           p_sup_ar.val_base_pis_d,
           p_sup_ar.val_base_cofins_d,
           p_sup_ar.pct_pis_item_d,
           p_sup_ar.pct_cofins_item_d,
           p_sup_ar.val_pis_d,
           p_sup_ar.val_cofins_d,
		   p_sup_ar.ies_base_calc)

   IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT AR_PIS_COFINS " ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","AR_PIS_COFINS")
		LET p_msg = log0030_txt_err_sql("INSERT","AR_PIS_COFINS"), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
	   RETURN FALSE
   END IF  

   UPDATE aviso_rec  set gru_ctr_desp_item = gru_ctr_desp_item + 100
	WHERE cod_empresa 	= p_aviso_rec.cod_empresa
	  and num_aviso_rec = p_aviso_rec.num_aviso_rec
	  and num_seq		= p_aviso_rec.num_seq  
	  
	IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro UPDATE AVISO_REC " ATTRIBUTE(REVERSE)
		CALL log003_err_sql("UPDATE","AVISO_REC")
		LET p_msg = log0030_txt_err_sql("UPDATE","AVISO_REC"), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
	   RETURN FALSE
	END IF  
   
# Grava tabela SUP_PAR_AR para COFINS
	 
	
	let p_sup_par_ar.empresa         		=  p_aviso_rec.cod_empresa  
	let p_sup_par_ar.aviso_recebto      	=  p_aviso_rec.num_aviso_rec
	let p_sup_par_ar.seq_aviso_recebto		=  p_aviso_rec.num_seq  
	let p_sup_par_ar.parametro				=  'cod_cst_COFINS'  	
	let p_sup_par_ar.par_ind_especial		=  'M'  
	let p_sup_par_ar.parametro_val			=  50
	INITIALIZE  p_sup_par_ar.parametro_dat TO NULL

    INSERT INTO sup_par_ar
	VALUES(p_sup_par_ar.*)	   

   IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT1 SUP_PAR_AR " ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","SUP_PAR_AR ")
		LET p_msg = log0030_txt_err_sql("INSERT","SUP_PAR_AR "), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
	   RETURN FALSE
   END IF  

   # Grava tabela SUP_PAR_AR para PIS
	 
	let p_sup_par_ar.empresa         		=  p_aviso_rec.cod_empresa  
	let p_sup_par_ar.aviso_recebto      	=  p_aviso_rec.num_aviso_rec
	let p_sup_par_ar.seq_aviso_recebto		=  p_aviso_rec.num_seq  
	let p_sup_par_ar.parametro				=  'cod_cst_PIS'  	
	let p_sup_par_ar.par_ind_especial		=  'M'  
	let p_sup_par_ar.parametro_val			=  50
	INITIALIZE  p_sup_par_ar.parametro_dat TO NULL

    INSERT INTO sup_par_ar
	VALUES(p_sup_par_ar.*)	   

   IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT2 SUP_PAR_AR " ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","SUP_PAR_AR ")
		LET p_msg = log0030_txt_err_sql("INSERT","SUP_PAR_AR "), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
	   RETURN FALSE
   END IF  
   
      # Grava tabela SUP_PAR_AR para IPI
	 
	let p_sup_par_ar.empresa         		=  p_aviso_rec.cod_empresa  
	let p_sup_par_ar.aviso_recebto      	=  p_aviso_rec.num_aviso_rec
	let p_sup_par_ar.seq_aviso_recebto		=  p_aviso_rec.num_seq  
	let p_sup_par_ar.parametro				=  'cod_cst_IPI'  	
	let p_sup_par_ar.par_ind_especial		=  'M'  
	let p_sup_par_ar.parametro_val			=  3
	INITIALIZE  p_sup_par_ar.parametro_dat TO NULL

    INSERT INTO sup_par_ar
	VALUES(p_sup_par_ar.*)	   

   IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT3 SUP_PAR_AR " ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","SUP_PAR_AR ")
		LET p_msg = log0030_txt_err_sql("INSERT","SUP_PAR_AR "), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
	   RETURN FALSE
   END IF  
# Verifica se já existe mensagem de erro gravado para o AR se já existir não 
#grava nova pois o usuario ja terá que obrigatoriamente consistir a nota no sup3760.   

  {	SELECT COUNT(*)   
	INTO l_count
	FROM NF_SUP_ERRO
	WHERE empresa	= p_sup_ar.cod_empresa
	AND   num_aviso_rec	= p_sup_ar.num_aviso_rec

	IF STATUS <> 0 THEN                                                      
		LET l_count  = 0 
    END IF  
	
	IF l_count  > 0   THEN 
		LET p_msg_erro = 'FALTA CONSISTIR A NOTA FISCAL COM PIS/COFINS REC'
		IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
			RETURN FALSE  
		END IF 
	END IF  }
	
   RETURN TRUE                                                                     
      
END FUNCTION

#---------------------------------------#
FUNCTION pol0947_insere_piscofin_csl()  
#---------------------------------------#

    DEFINE p_cap_p_piscofin_csl RECORD LIKE cap_p_piscofin_csl.*

    SELECT 	(Pct_pis/100) pct_pis,
			SUM(VAL_BASE_PIS)/100,                                  																							
			SUM(VAL_PIS)/100,    
			(Pct_cofins/100) pct_cofins,
			SUM(VAL_BASE_COFINS)/100,                               																							
			SUM(VAL_COFINS)/100,   
			(Pct_csll/100) pct_csll,
			SUM(VAL_BASE_CSLL)/100,                                 																							
			SUM(VAL_CSLL)/100                                      																							
    INTO				 
     	p_cap_p_piscofin_csl.pct_retencao_pis,   	 
			p_cap_p_piscofin_csl.val_bas_calc_pis,  	 
			p_cap_p_piscofin_csl.val_retencao_pis,   	 
			p_cap_p_piscofin_csl.pct_ret_cofins,   		 
			p_cap_p_piscofin_csl.val_bc_cofins,   		 
			p_cap_p_piscofin_csl.val_ret_cofins,   		 	 
			p_cap_p_piscofin_csl.pct_retencao_csl,    
			p_cap_p_piscofin_csl.val_bas_calc_csl,   	 
			p_cap_p_piscofin_csl.val_retencao_csl 
	FROM T_NF_ITEM                                             																							
	WHERE cod_empresa = p_nfe.cod_empresa                        																							
	AND 	NUM_NF = p_nfe.Num_nf                                    																							
	AND 	COD_FORNECEDOR = p_nfe.Cod_fornecedor  
    AND     Pct_pis<>0 	
	GROUP BY    Pct_pis, Pct_cofins, Pct_csll
			
	IF STATUS = 100 THEN   
	   RETURN TRUE
	ELSE   
		IF STATUS <> 0 THEN                                                      
			MESSAGE "Erro leitura 2 T_NF_ITEM " ATTRIBUTE(REVERSE)
			CALL log003_err_sql("SELECT","T_NF_ITEM2")
			LET p_msg = log0030_txt_err_sql("SELECT","T_NF_ITEM2"), " nota fiscal ",p_nfe.Num_nf
			CALL pol0947_imprime_erros(p_msg)
			LET p_erro = TRUE 
			RETURN FALSE
		END IF
	END IF
 			
	IF 	(p_cap_p_piscofin_csl.val_bas_calc_pis IS NULL)  AND 
		(p_cap_p_piscofin_csl.val_bc_cofins    IS NULL)  AND 
		(p_cap_p_piscofin_csl.val_bas_calc_csl IS NULL)  THEN
        RETURN TRUE		
	END IF 	
 
						  
	IF 	p_cap_p_piscofin_csl.pct_retencao_pis IS NULL THEN 
	    LET p_cap_p_piscofin_csl.pct_retencao_pis = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_bas_calc_pis IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_bas_calc_pis = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_retencao_pis IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_retencao_pis = 0 
	END IF
	
	IF 	p_cap_p_piscofin_csl.pct_ret_cofins IS NULL THEN 
	    LET p_cap_p_piscofin_csl.pct_ret_cofins = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_bc_cofins IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_bc_cofins = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_ret_cofins IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_ret_cofins = 0 
	END IF
	
	IF 	p_cap_p_piscofin_csl.pct_retencao_csl IS NULL THEN 
	    LET p_cap_p_piscofin_csl.pct_retencao_csl = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_bas_calc_csl IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_bas_calc_csl = 0 
	END IF
	IF 	p_cap_p_piscofin_csl.val_retencao_csl IS NULL THEN 
	    LET p_cap_p_piscofin_csl.val_retencao_csl = 0 
	END IF
	
	
	IF 	(p_cap_p_piscofin_csl.val_bas_calc_pis = 0)  AND 
		(p_cap_p_piscofin_csl.val_bc_cofins    = 0)  AND 
		(p_cap_p_piscofin_csl.val_bas_calc_csl = 0)  THEN
        RETURN TRUE		
	END IF 	
		
#----Carrega tabela CAP_P_PISCOFIN_CSL 

	LET p_cap_p_piscofin_csl.empresa        		=  	p_aviso_rec.cod_empresa  
	LET p_cap_p_piscofin_csl.ad_nf_origem      		=  	p_nf_sup.num_nf
    LET p_cap_p_piscofin_csl.serie_nota_fiscal 		=	p_nf_sup.ser_nf
    LET p_cap_p_piscofin_csl.subserie_nf 			=  	p_nf_sup.ssr_nf
    LET p_cap_p_piscofin_csl.espc_nota_fiscal  		= 	p_nf_sup.ies_especie_nf
    LET p_cap_p_piscofin_csl.fornecedor   			= 	p_nf_sup.cod_fornecedor
    LET p_cap_p_piscofin_csl.dat_moviment   		=   p_nf_sup.dat_entrada_nf
    LET p_cap_p_piscofin_csl.dat_vencto   			=	p_nf_sup.dat_entrada_nf
    LET p_cap_p_piscofin_csl.tip_val_ret_pis   		=	"1"
	LET p_cap_p_piscofin_csl.tip_val_ret_cofins   	=	"1"
    LET p_cap_p_piscofin_csl.tip_val_ret_csl   		=   "1"

	DELETE FROM cap_p_piscofin_csl
	WHERE empresa 	   			= 	p_aviso_rec.cod_empresa 
	AND ad_nf_origem 			= 	p_nf_sup.num_nf
	AND serie_nota_fiscal		= 	p_nf_sup.ser_nf
	AND subserie_nf 			=  	p_nf_sup.ssr_nf
	AND espc_nota_fiscal  		= 	p_nf_sup.ies_especie_nf
	AND fornecedor   			= 	p_nf_sup.cod_fornecedor
	AND dat_moviment   			=   p_nf_sup.dat_entrada_nf

	IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT CAP_P_PISCOFIN_CSL" ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","INSERT CAP_P_PISCOFIN_CSL")
		LET p_msg = log0030_txt_err_sql("INSERT","INSERT CAP_P_PISCOFIN_CSL"), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
		RETURN FALSE
	END IF 
 
   INSERT INTO cap_p_piscofin_csl 
    VALUES(
			p_cap_p_piscofin_csl.empresa,
			p_cap_p_piscofin_csl.ad_nf_origem,
			p_cap_p_piscofin_csl.serie_nota_fiscal,
			p_cap_p_piscofin_csl.subserie_nf,
			p_cap_p_piscofin_csl.espc_nota_fiscal,
			p_cap_p_piscofin_csl.fornecedor,
			p_cap_p_piscofin_csl.dat_moviment,
			p_cap_p_piscofin_csl.dat_vencto,
			p_cap_p_piscofin_csl.tip_val_ret_pis,
			p_cap_p_piscofin_csl.pct_retencao_pis,
			p_cap_p_piscofin_csl.val_bas_calc_pis,
			p_cap_p_piscofin_csl.val_retencao_pis,
			p_cap_p_piscofin_csl.tip_val_ret_cofins,
			p_cap_p_piscofin_csl.pct_ret_cofins,
			p_cap_p_piscofin_csl.val_bc_cofins,
			p_cap_p_piscofin_csl.val_ret_cofins,
			p_cap_p_piscofin_csl.tip_val_ret_csl,
			p_cap_p_piscofin_csl.pct_retencao_csl,
			p_cap_p_piscofin_csl.val_bas_calc_csl,
			p_cap_p_piscofin_csl.val_retencao_csl)


	IF STATUS <> 0 THEN                                                      
		MESSAGE "Erro INSERT CAP_P_PISCOFIN_CSL" ATTRIBUTE(REVERSE)
		CALL log003_err_sql("INSERT","INSERT CAP_P_PISCOFIN_CSL")
		LET p_msg = log0030_txt_err_sql("INSERT","INSERT CAP_P_PISCOFIN_CSL"), " nota fiscal ",p_nfe.Num_nf
		CALL pol0947_imprime_erros(p_msg)
		LET p_erro = TRUE 
		RETURN FALSE
	END IF                                                                          
  
{	LET p_msg_erro = 'FALTA CONSISTIR A NOTA FISCAL COM PIS/COFINS/CSLL RET'
	IF NOT pol0947_grava_erro(p_msg_erro, 0)  THEN 
		RETURN FALSE  
	END IF }
 
    RETURN TRUE   
   	
END FUNCTION 

#-----------------------------------#
FUNCTION pol0947_converte_valor(par)#
#-----------------------------------#
DEFINE par CHAR(01)												#variavel vai servir pra identificar se converto os
																					#valores da nota ou do item da nota
	IF par = "N" THEN 
		LET p_nfe.Val_tot_desconto	= p_nfe.Val_tot_desconto	/100		#DECIMAL(17,2)
		LET p_nfe.Val_tot_frete			= p_nfe.Val_tot_frete			/100		#DECIMAL(17,2)
		LET p_nfe.Val_tot_nff				=	p_nfe.Val_tot_nff				/100		#DECIMAL(17,2)
	END IF 
	
	IF par = "I" THEN
		LET p_nfe_item.qtd_item					=	 p_nfe_item.qtd_item							/1000				#DECIMAL(12,3)
		LET p_nfe_item.pre_unit					=	 p_nfe_item.pre_unit							/1000000		#DECIMAL(17,6)
		LET p_nfe_item.val_desc_item			=	 p_nfe_item.val_desc_item					/100				#DECIMAL(17,2)
		LET p_nfe_item.val_liq_item				=	 p_nfe_item.val_liq_item					/100				#DECIMAL(17,2)
		LET p_nfe_item.val_tot_base_iss			=	 p_nfe_item.val_tot_base_iss			/100				#DECIMAL(17,2)
		LET p_nfe_item.val_tot_iss				=	 p_nfe_item.val_tot_iss						/100				#DECIMAL(17,2)
		LET p_nfe_item.val_base_irpj			=	 p_nfe_item.val_base_irpj					/100				#DECIMAL(15,2)
		LET p_nfe_item.val_irpj					=	 p_nfe_item.val_irpj							/100				#DECIMAL(15,2)
		LET p_nfe_item.val_base_csll			=	 p_nfe_item.val_base_csll					/100				#DECIMAL(15,2)
		LET p_nfe_item.val_csll					=	 p_nfe_item.val_csll							/100				#DECIMAL(15,2)
		LET p_nfe_item.val_base_cofins			=	 p_nfe_item.val_base_cofins				/100				#DECIMAL(15,2)
		LET p_nfe_item.val_cofins				=	 p_nfe_item.val_cofins						/100				#DECIMAL(15,2)
		LET p_nfe_item.val_base_pis				=	 p_nfe_item.val_base_pis					/100				#DECIMAL(15,2)
		LET p_nfe_item.val_pis					=	 p_nfe_item.val_pis								/100				#DECIMAL(15,2)
		LET p_nfe_item.val_frete				=	 p_nfe_item.val_frete							/100				#DECIMAL(17,2)
		LET p_nfe_item.Val_base_icms			=	 p_nfe_item.Val_base_icms					/100
		LET p_nfe_item.Val_icms					=	 p_nfe_item.Val_icms							/100
		LET p_nfe_item.Val_inss					=	 p_nfe_item.Val_inss							/100
	END IF 
END FUNCTION 
#-------------------------------------#
FUNCTION pol0947_imprime_erros(l_erro)#			#prepara para imprimir erro
#-------------------------------------#
DEFINE 	l_erro		CHAR(250)
	
	IF p_primeira_vez THEN 
		SELECT den_empresa
		INTO p_den_empresa
		FROM empresa
		WHERE cod_empresa = p_cod_empresa
				
		CALL log150_procura_caminho ('LST') RETURNING p_caminho
		LET p_caminho = p_caminho CLIPPED, 'pol0947.lst'
		LET p_nom_arquivo = p_caminho
		START REPORT pol0947_imprime TO p_nom_arquivo
		
		LET p_primeira_vez =  FALSE
	END IF 
	
	OUTPUT TO REPORT pol0947_imprime(l_erro)
	
	
END FUNCTION 
#-----------------------------#
REPORT pol0947_imprime(p_erro)#			#vai imprimir os erros apresentados no programa
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

         PRINT COLUMN 001, "pol0947  CARGA DE NOTAS FISCAIS DE ENTRADA",
               COLUMN 056, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRIÇÃO DO ERRO"
         PRINT COLUMN 001, "--------------------------------------------------"

      ON EVERY ROW
         PRINT COLUMN 001, p_erro CLIPPED
END REPORT

#Rotinas criadas para atender às necessidades no SPED - Ivo

#-------------------------------------#
FUNCTION pol0947_troca_cod(p_cod_cfop) 
#-------------------------------------#

   define i, j        integer,
          p_cfop      char(05),
          p_cod_cfop  char(07),
          p_carac char(01)	  

   LET p_cfop = p_cod_cfop[4],'.',p_cod_cfop[5,7]
   
   if p_cfop[1] = '1' then
      LET p_cfop[1] = '5'
   else
      if p_cfop[1] = '2' then
         LET p_cfop[1] = '6'
      else
         if p_cfop[1] = '3' then
            LET p_cfop[1] = '7'
         end if
      end if
   end if

   
   IF p_cfop = '0.000'  THEN
      lET p_cfop= '    '
   END IF  	  
   RETURN(p_cfop)

END FUNCTION
#-------------------------------------#
FUNCTION pol0947_atu_grupo_desp()
#-------------------------------------#
     DEFINE  x_gru_ctr_desp_item 	DECIMAL(4,0),
	         x_num_aviso_rec    	LIKE aviso_rec.num_aviso_rec,
			 x_num_seq     			LIKE aviso_rec.num_seq
	
	INITIALIZE x_gru_ctr_desp_ite  TO  NULL 
	SELECT gru_ctr_desp_item
	  INTO	x_gru_ctr_desp_item
	  FROM cta_grupo_man912
	 WHERE num_conta_cont =  p_nfe.num_conta_cont  
	
	IF SQLCA.SQLCODE = 0 THEN			
	   DECLARE cq_nf CURSOR FOR
		SELECT num_aviso_rec
		FROM NF_SUP
		WHERE NUM_NF		 = p_nfe.Num_nf
		  AND COD_FORNECEDOR = p_cod_fornecedor
		  AND COD_EMPRESA    = p_cod_empresa
		  AND IES_ESPECIE_NF = p_nfe.especie_nf
		  AND dat_entrada_nf = p_nfe.Data_entrada
		
		FOREACH cq_nf INTO x_num_aviso_rec 
		
			UPDATE aviso_rec  SET 	gru_ctr_desp_item = x_gru_ctr_desp_item 
			 WHERE cod_empresa   = p_cod_empresa
			   AND num_aviso_rec =  x_num_aviso_rec 
				   IF STATUS <> 0 THEN                                                      
					  MESSAGE "Erro UPDATE 2 AVISO_REC " ATTRIBUTE(REVERSE)
		              CALL log003_err_sql("UPDATE","AVISO_REC")
		              LET p_msg = log0030_txt_err_sql("UPDATE","AVISO_REC"), " nota fiscal ",p_nfe.Num_nf
		              CALL pol0947_imprime_erros(p_msg)
                    END IF  
		
		        LET x_num_seq   = 0 
				DECLARE cq_ar_pis_cofins CURSOR FOR
				SELECT num_seq 
				  FROM ar_pis_cofins 
				WHERE cod_empresa   = p_cod_empresa
				  AND num_aviso_rec = x_num_aviso_rec 
				
				FOREACH cq_ar_pis_cofins into x_num_seq
				
				   UPDATE aviso_rec  set gru_ctr_desp_item = gru_ctr_desp_item + 100
					WHERE cod_empresa 	= p_cod_empresa
					  and num_aviso_rec = x_num_aviso_rec
					  and num_seq		= x_num_seq  
				
				   IF STATUS <> 0 THEN                                                      
					  MESSAGE "Erro UPDATE 3 AVISO_REC " ATTRIBUTE(REVERSE)
		              CALL log003_err_sql("UPDATE","AVISO_REC")
		              LET p_msg = log0030_txt_err_sql("UPDATE","AVISO_REC"), " nota fiscal ",p_nfe.Num_nf
		              CALL pol0947_imprime_erros(p_msg)
                    END IF  
				END FOREACH
		END FOREACH
	END IF 
	
END FUNCTION
#-------------------------------------#
FUNCTION pol0947_imprime_NF(l_mensagem)#			#prepara para imprimir NF processadas com sucesso
#-------------------------------------#
DEFINE 	l_mensagem		CHAR(250)
	
	IF p_primeira_vez1 THEN 
		SELECT den_empresa
		INTO p_den_empresa
		FROM empresa
		WHERE cod_empresa = p_cod_empresa
				
		CALL log150_procura_caminho ('LST') RETURNING p_caminho1
		LET p_caminho1 = p_caminho1 CLIPPED, 'pol09471.lst'
		LET p_nom_arquivo1 = p_caminho1
		START REPORT pol0947_imprime_nf_processada TO p_nom_arquivo1
		
		LET p_primeira_vez1 =  FALSE
	END IF 
	
	OUTPUT TO REPORT pol0947_imprime_nf_processada(l_mensagem)
	
	
END FUNCTION 
#-------------------------------------------------#
REPORT pol0947_imprime_nf_processada(p_mensagem)#			#vai imprimiras notas processadas com sucesso
#-------------------------------------------------#
DEFINE p_mensagem			CHAR(250)

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  66

   FORMAT
      PAGE HEADER
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&"

         PRINT COLUMN 001, "pol0947  NOTAS FISCAIS DE ENTRADA CARREGADAS COM SUCESSO",
               COLUMN 056, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRIÇÃO DA MENSAGEM"
         PRINT COLUMN 001, "--------------------------------------------------"
		 PRINT COLUMN 001, " NOTA FISCAL      FORNECEDOR        VALOR DA NOTA"

      ON EVERY ROW
         PRINT COLUMN 001, p_mensagem CLIPPED
END REPORT

