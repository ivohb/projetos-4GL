#--------------------------------------------------------------------------------#
# SISTEMA.: Gerar nota fiscal									                 #
#	PROGRAMA:	pol0989											                 #
#	CLIENTE.:	Fame					                				         #
#	OBJETIVO:	GERAR NOTA FISCAL ATRAVES DOS ITENS DE UM ARQUVO TEXTO           #
#	AUTOR...:	IVO   														     #
#	DATA....:	11/05/2009													     #
#	ALTERADO EM : 09/03/2011 por Manuel para evitar gerar movto no estoque zerado#
#	             e para descartar movimentos que vem da Lojinha zerados, pois    # 
#                estava fazendo com que a seqeuncia da nota pulasse numeros      #
#--------------------------------------------------------------------------------#

DATABASE logix

   DEFINE
        p_cod_empresa   			LIKE empresa.cod_empresa,
				p_den_empresa				  LIKE empresa.den_empresa,
				p_user          			LIKE usuario.nom_usuario,		    
				p_encontrou         	CHAR(01),
				p_status        			SMALLINT,
				p_count               SMALLINT,
				p_versao        			CHAR(18),
				p_resposta					  SMALLINT,
				comando         			CHAR(80),
				p_caminho					    CHAR(30),
				p_ies_impressao 			CHAR(001),
				g_ies_ambiente 		  	CHAR(001),
				p_nom_arquivo			   	CHAR(100),
				sql_stmt					    CHAR(600),
				where_clause				  CHAR(300),
				p_nom_tela 					  CHAR(200),
				p_retorno					    SMALLINT,
				p_ies_cons      			SMALLINT,
				p_cont					      SMALLINT,
				p_nom_help      			CHAR(200),
				p_natureza_operacao			INTEGER,
				p_entrada					DECIMAL(06),
				p_tipo						CHAR(03),
				p_houve_erro				SMALLINT,
				p_erro				     	SMALLINT,
				p_data						DATE,
				p_msg						CHAR(600), 
				p_incide_ipi				CHAR(1),
				p_val_icm             		decimal(17,2),  
				p_val_base_icm 	      		decimal(17,2),
				p_print						SMALLINT				

   DEFINE m_msg                CHAR(600),
          p_tip_item           CHAR(01),
          c_data               DATETIME YEAR TO SECOND,
          p_trans_nf           INTEGER,
          p_tem_tributo        SMALLINT,
          p_num_ctr_acesso     INTEGER,
          p_query              CHAR(600),
          p_cod_cliente        CHAR(15),
          p_tributo_benef      CHAR(20),
          p_grp_classif_fisc   CHAR(10),
          p_grp_fiscal_item    CHAR(10),
          p_grp_fisc_cliente   CHAR(10),
          p_trans_config       INTEGER,
          p_chave              CHAR(11),
          p_matriz             CHAR(24),
          p_regiao_fiscal      CHAR(10),
          p_pct_reduz_icm      DECIMAL(7,4),
          p_cod_uni_feder      CHAR(02),
          p_micro_empresa      CHAR(01),
          p_cod_status         CHAR(05),
		  p_preco_uni_nf	   LIKE fat_nf_item.preco_unit_liquido,
		  p_num_nff            INTEGER,		
		  p_valor_ipi_item     DECIMAL(17,2),
		  p_qtd_reservada      LIKE ordem_montag_item.qtd_reservada

   #ivo 24/09/2013 daqui...
   DEFINE p_cod_hist           LIKE fiscal_hist.cod_hist,
          p_tex_hist_1         LIKE fiscal_hist.tex_hist_1,
          p_tex_hist_2         LIKE fiscal_hist.tex_hist_2,
          p_tex_hist_3         LIKE fiscal_hist.tex_hist_3,
          p_tex_hist_4         LIKE fiscal_hist.tex_hist_4,
          p_qtd_fci            LIKE fat_item_fci.qtd_item_fci, 
          p_pct_import         LIKE vdp_controle_fci.pct_contd_import,
          p_num_controle_fci   LIKE vdp_controle_fci.num_controle_fci,
          p_trans_controle_fci LIKE vdp_controle_fci.trans_controle_fci,
          p_descricao_texto    LIKE fat_nota_fiscal_texto_item.descricao_texto,
          p_seq_item_nf        INTEGER,
          p_seq_texto          INTEGER,
          p_tip_fci            CHAR(01),
          p_controle_fci       CHAR(01)    
   #... até aqui ivo 24/09/2013
   
   DEFINE p_preco_s_trib       LIKE fat_nf_item.preco_unit_liquido,
		  	  p_preco_uni   	     LIKE fat_nf_item.preco_unit_liquido,
          p_cod_fiscal         LIKE fat_nf_item_fisc.cod_fiscal,
          p_val_base_trib      LIKE fat_nf_item_fisc.val_unit,
          p_val_tribruto       LIKE fat_nf_item_fisc.val_unit,
          p_val_ipi            LIKE fat_nf_item_fisc.val_trib_merc,
          p_val_icms           LIKE fat_nf_item_fisc.val_trib_merc,
          p_pct_red_bas_calc   LIKE fat_nf_item_fisc.pct_red_bas_calc,
          p_val_icm_it         LIKE fat_nf_item_fisc.val_trib_merc,
          p_tot_peso           LIKE fat_nf_mestre.peso_bruto,
          p_val_bruto          LIKE fat_nf_mestre.val_nota_fiscal,
          p_val_liqui          LIKE fat_nf_mestre.val_nota_fiscal,
		      p_val_acres          LIKE fat_nf_mestre.val_acre_nf,
          p_cod_nat_oper       LIKE fat_nf_mestre.natureza_operacao,
          p_cod_cnd_pgto       LIKE fat_nf_mestre.cond_pagto,
          p_cod_cidade         LIKE clientes.cod_cidade,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_cod_cla_fisc       LIKE item.cod_cla_fisc,
          p_cod_familia        LIKE item.cod_familia, 
          p_gru_ctr_estoq      LIKE item.gru_ctr_estoq,           
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_ies_tipo           LIKE estoque_operac.ies_tipo,
          p_cod_item           LIKE item.cod_item,
          p_cod_incide         LIKE obf_config_fiscal.incide, 
          p_incide_icm         LIKE obf_config_fiscal.incide, 
          p_aliquota           LIKE obf_config_fiscal.aliquota,
		      p_aliquota_ipi       LIKE obf_config_fiscal.aliquota,
          p_tip_docum          LIKE vdp_num_docum.tip_docum,
          p_modelo_docum       LIKE vdp_num_docum.modelo_docum,
          p_tip_solic          LIKE vdp_num_docum.tip_solicitacao,
          p_ser                LIKE vdp_num_docum.serie_docum,
          p_ssr                LIKE vdp_num_docum.subserie_docum,
          p_esp                LIKE vdp_num_docum.especie_docum,
          p_pes_unit           LIKE item.pes_unit,
          p_fat_conver         LIKE item.fat_conver,
          p_des_item           LIKE item.den_item

   DEFINE 
          p_fiscal_par         RECORD LIKE fiscal_par.*,
          p_fat_mestre         RECORD LIKE fat_nf_mestre.*,
          p_fat_item           RECORD LIKE fat_nf_item.*,
          p_item_fisc          RECORD LIKE fat_nf_item_fisc.*,
          p_txt_hist           RECORD LIKE fat_nf_texto_hist.*,
          p_mest_fisc          RECORD LIKE fat_mestre_fiscal.*,
          p_param              RECORD LIKE par_nf_912.*,
          p_nf_duplicata       RECORD LIKE fat_nf_duplicata.*
	 
		  
   DEFINE p_obf_controle_chave RECORD 
			empresa 			char(2),
			tributo_benef 		char(20),
			natureza_operacao 	char(1),
			ctr_nat_operacao 	integer,
			grp_fiscal_regiao 	char(1),
    	ctr_grp_fisc_regi 	integer,
    	estado 				char(1),
    	controle_estado 	integer,
   		municipio 			char(1),
			controle_municipio  integer,
			carteira 			char(1),
			controle_carteira 	integer,
			finalidade 			char(1),
			ctr_finalidade 		integer,
			familia_item 		char(1),
			ctr_familia_item 	integer,
			grp_fiscal_classif 	char(1),
			ctr_grp_fisc_clas 	integer,
			classif_fisc 		char(1),
			ctr_classif_fisc 	integer,
			linha_produto 		char(1),
			ctr_linha_produto 	integer,
			linha_receita 		char(1),
			ctr_linha_receita 	integer,
			segmto_mercado 		char(1),
			ctr_segmto_mercado 	integer,
			classe_uso 			char(1),
			ctr_classe_uso 		integer,
			unid_medida 		char(1),
			ctr_unid_medida 	integer,
			produto_bonific 	char(1),
			ctr_prod_bonific 	integer,
			grupo_fiscal_item 	char(1),
			ctr_grp_fisc_item 	integer,
			item 				char(1),
			controle_item 		integer,
			micro_empresa 		char(1),
			ctr_micro_empresa 	integer,
			grp_fiscal_cliente 	char(1),
			ctr_grp_fisc_cli 	integer,
			cliente 			char(1),
			controle_cliente 	integer,
			via_transporte 		char(1),
			ctr_via_transporte 	integer,
			tem_valid_config 	char(1),
			ctrl_valid_config 	integer 
	END RECORD

   DEFINE p_arquivo           RECORD 
		  		cod_item				    CHAR(20),
			  	sequencia				    INTEGER,
				  qtd_item 				    DECIMAL(9,2),
				  total_val_item 	    DECIMAL(12,2),
				  desc_val_item 	    DECIMAL(12,2),
				  acresc_val_item     DECIMAL(12,2)
   END RECORD

MAIN

	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
	  SET ISOLATION TO DIRTY READ
	  SET LOCK MODE TO WAIT 300 
	DEFER INTERRUPT
	LET p_versao = "pol0989-10.02.50"
	INITIALIZE p_nom_help TO NULL  
	CALL log140_procura_caminho("pol0989.iem") RETURNING p_nom_help
	LET  p_nom_help = p_nom_help CLIPPED
	OPTIONS HELP FILE p_nom_help,
	  NEXT KEY control-f,
	  INSERT KEY control-i,
	  DELETE KEY control-e,
	  PREVIOUS KEY control-b
	CALL log001_acessa_usuario("ESPEC999","")
	  RETURNING p_status, p_cod_empresa, p_user
	IF p_status = 0  THEN
		IF pol0989_cria_tabelas() THEN 
	  	CALL pol0989_controle()
	  END IF 
	END IF
	
END MAIN 			

#---------------------------#
FUNCTION  pol0989_controle()#
#---------------------------#
	
	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol0989") RETURNING comando
	OPEN WINDOW w_pol0989 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

	LET p_retorno = FALSE 
	LET p_resposta = FALSE 
	
	MENU "OPCAO"
		COMMAND "Informar"   "Informar parametros "
			HELP 0009
			MESSAGE ""
			CALL pol0989_entrada_parametro() RETURNING p_retorno
			NEXT OPTION "Carregar"
		COMMAND "Carregar"   "Carregar arquivo de dados"
			HELP 0009
			MESSAGE ""
		  IF p_retorno THEN                                 
				 MESSAGE "Carregando arquivo..."               	 
			 	 IF pol0989_carrega_arquivo() THEN              		
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
		COMMAND "Processar"  "Processar dados"
			HELP 1053
			IF p_resposta THEN                                                                 
				 MESSAGE "Processando..."                                                       	
				 CALL log085_transacao('BEGIN')                                                 	
				 IF pol0989_processar() THEN                                                    	
				 	  CALL pol0989_deleta_arquivo() RETURNING p_status                                          	
  				 	MESSAGE "Arquivo processado com sucesso! "                                    	
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
		COMMAND "Rel_cupom"  "Processar dados"
			CALL log120_procura_caminho("POL1011") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0989
		COMMAND "Nfe"  "Processar dados"
			CALL log120_procura_caminho("VDP9202") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0989
		COMMAND "Listar"  "Lista itens processados e mostra pendencias"
			IF NOT pol0989_gera_relatorio() THEN 
				 ERROR"Não foram encontrados movimentos para a nota." 
			END IF 				
    COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0989_sobre() 		
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
		COMMAND "Fim" "Retorna ao Menu Anterior"
			HELP 008
			EXIT MENU
	END MENU
	
	CLOSE WINDOW w_pol0989

END FUNCTION 

#-----------------------#
FUNCTION pol0989_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------#
FUNCTION  pol0989_cria_tabelas()#
#-------------------------------#

   DROP TABLE tributo_tmp

   CREATE TABLE tributo_tmp (
      tributo_benef CHAR(11),
      trans_config  INTEGER
   );

		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("Criando","tributo_tmp")
			RETURN FALSE
		END IF

   DROP TABLE chave_tmp
   
   CREATE TABLE chave_tmp (
      chave CHAR(11)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','chave_tmp')
      RETURN FALSE
   END IF  

		DROP TABLE t_entrada
		
		CREATE  TABLE t_entrada
		(
			arquivo			CHAR(80)
		)
		
		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("create","t_entrada")
			RETURN FALSE
		END IF
		
		DROP TABLE t_ctrl_trans
		
		CREATE  TABLE t_ctrl_trans
		(
			cod_empresa char(02) NOT NULL,
			num_nff decimal(6,0) NOT NULL,
			ser_nff char(02) NOT NULL,
			cod_item char(15 ) NOT NULL,
			num_sequencia DECIMAL(5,0) NOT NULL ,
			num_transac integer NOT NULL
		);
		
		IF SQLCA.SQLCODE <> 0 THEN
			CALL log003_err_sql("t_ctrl_trans","t_entrada")
			RETURN FALSE
		END IF
		
		DROP TABLE t_arquivo
		
		CREATE   TABLE t_arquivo (
			cod_item				CHAR(20),
			sequencia				INTEGER,
			qtd_item 				DECIMAL(9,2),
			total_val_item 	DECIMAL(12,2),
			desc_val_item 	DECIMAL(12,2),
			acresc_val_item DECIMAL(12,2)
			)

	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_arquivo")
		RETURN FALSE
	END IF
		
	RETURN TRUE 

END FUNCTION

#--------------------------------#
FUNCTION  pol0989_limpa_tabelas()#
#--------------------------------#
	
	DELETE FROM t_entrada
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("create","t_entrada")
	END IF
	
	DELETE FROM t_arquivo
	
	IF SQLCA.SQLCODE <> 0 THEN
		CALL log003_err_sql("delete","t_entrada")
	END IF 
	
END FUNCTION

#------------------------------------#
FUNCTION  pol0989_entrada_parametro()#
#------------------------------------#
	
	INITIALIZE p_data TO NULL 
	INITIALIZE p_param TO NULL
	INITIALIZE p_val_icm TO NULL 
	INITIALIZE p_val_base_icm TO NULL  
	
	LET INT_FLAG = FALSE
	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	
	INPUT p_param.cod_param,
	      p_data,
	      p_val_base_icm,
	      p_val_icm 
	   WITHOUT DEFAULTS FROM 
	      cod_parametro,
	      data, 
	      val_base_icm,
	      val_icm
				
		AFTER FIELD cod_parametro	
			IF p_param.cod_param IS NULL THEN 
				ERROR"Campo de preenchimento obrigatório!!!"
				NEXT FIELD cod_parametro
			END IF
			
			IF NOT pol0989_verifica_parametro() THEN 
					ERROR "Codigo invalido!!!"
					NEXT FIELD cod_parametro
			END IF 
				
		AFTER FIELD data	
			IF p_data IS NULL THEN 
				ERROR"Campo de preenchimento obrigatório!!!"
				NEXT FIELD data
			END IF
			
			IF NOT pol0989_valida_data() THEN 
				 ERROR"A data atual e menor que a ultima já processada!!!"
				 NEXT FIELD data
			END IF 
					
		AFTER FIELD val_base_icm	
			IF p_val_base_icm IS NULL THEN 
				 ERROR"Campo de preenchimento obrigatório!!!"
				 NEXT FIELD val_base_icm
			END IF 
			
		AFTER FIELD val_icm	
			IF p_val_icm IS NULL THEN 
				 ERROR"Campo de preenchimento obrigatório!!!"
				 NEXT FIELD val_icm
			END IF 
			
		ON KEY (control-z)
		   CALL pol0989_popup()
	
	END INPUT 
	
	IF INT_FLAG = 0 THEN
		RETURN TRUE
	ELSE
		LET INT_FLAG = 0
		RETURN FALSE
	END IF
	
END FUNCTION

#-------------------------------------#
 FUNCTION pol0989_verifica_parametro()#
#-------------------------------------#

	SELECT *
  	INTO p_param.*
	  FROM par_nf_912
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_param   = p_param.cod_param
   
   IF SQLCA.SQLCODE = 0 THEN
   		DISPLAY p_param.den_param	TO den_param
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF 
      
END FUNCTION 

#------------------------------#
FUNCTION  pol0989_valida_data()#
#------------------------------#
   
   DEFINE l_data		DATE
    		
	 SELECT MAX(DATE(dat_hor_emissao))
		 INTO l_data 
		 FROM fat_nf_mestre
		WHERE empresa = p_cod_empresa
		  AND  serie_nota_fiscal IN
		      (SELECT ser_nff 
		         FROM  par_nf_912
            WHERE cod_empresa = p_cod_empresa
              AND cod_param   = p_param.cod_param)

		
		IF p_data < l_data THEN
			RETURN FALSE
		ELSE 
			RETURN TRUE
		END IF

END FUNCTION

#-----------------------#
FUNCTION pol0989_popup()#
#-----------------------#
   
  DEFINE p_codigo  CHAR(15)
      
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"CODIGO DO PARAMETRO","par_nf_912",
						"cod_param","den_param","pol0988","S","") RETURNING p_codigo
			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0989
	
			IF p_codigo IS NOT NULL THEN
				LET p_param.cod_param = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_parametro
			END IF
	
	END CASE 

END FUNCTION 

#---------------------------------#
FUNCTION pol0989_carrega_arquivo()#							
#---------------------------------#
  
  DEFINE p_data_char		CHAR(10),
	 		   l_caminho			CHAR(100)
	
	SELECT den_empresa
	  INTO p_den_empresa
	  FROM empresa
	 WHERE cod_empresa = p_cod_empresa
	
	LET p_print = FALSE
	
	CALL  pol0989_limpa_tabelas()  
		
	LET p_data_char = p_data
	CALL log150_procura_caminho("UNL") RETURNING p_caminho
	LET l_caminho = p_caminho CLIPPED,"PZ",
	                p_data_char[1,2], 
	                p_data_char[4,5], 
	                p_data_char[9,10],".002"
	
	LOAD FROM l_caminho INSERT INTO t_entrada
	
	IF STATUS = -805 THEN
		 LET p_msg = log0030_txt_err_sql("LOAD","t_entrada")," Arquivo: ", l_caminho
		 LET p_msg = p_msg CLIPPED, " Não encontrado!"	
		 CALL log0030_mensagem(p_msg,"excla")						
		 RETURN FALSE															
	ELSE
		IF SQLCA.SQLCODE <> 0 THEN 
			 CALL log003_err_sql("LOAD","t_entrada")
			 RETURN FALSE
		END IF
	END IF
	
	RETURN TRUE 

END FUNCTION

#---------------------------#
FUNCTION pol0989_processar()#
#---------------------------#

  LOCK TABLE vdp_num_docum IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      CALL log0030_txt_err_sql('Bloqueando','excla')
      RETURN FALSE
   END IF

   SELECT tip_docum,
          num_ultimo_docum,
          serie_docum,
          subserie_docum,
          especie_docum,
          num_ultimo_docum,
          modelo_docum
     INTO p_tip_docum,
          p_num_nff,
          p_ser,
          p_ssr,
          p_esp,
          p_num_nff,
          p_modelo_docum
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      AND serie_docum  IN (SELECT ser_nff
                             FROM par_nf_912
                            WHERE cod_empresa = p_cod_empresa
                              AND cod_param = p_param.cod_param)


	IF SQLCA.SQLCODE <> 0 THEN 
		CALL log003_err_sql("LENDO",'VDP_NUM_DOCUM')
		RETURN FALSE
	END IF  

	IF p_num_nff IS NULL THEN  
	    CALL log003_err_sql("LENDO 2",'VDP_NUM_DOCUM')
		RETURN FALSE
	END IF 
	
  LET p_tot_peso = 0
    
  IF NOT pol0989_ins_mestre() THEN 
     RETURN FALSE
  END IF
	
  IF NOT pol0989_insere_item() THEN
		FINISH REPORT pol0989_imprime 
		CALL log0030_mensagem("Erro ao tentar Gerar Nota fiscal!!",'info')
		MESSAGE "Erro Gravado no Arquivo ",p_nom_arquivo," " ATTRIBUTE(REVERSE)
		RETURN FALSE
  END IF 
	
  IF NOT pol0989_txt_fisc() THEN
     RETURN FALSE
  END IF
	
  IF NOT pol0989_mestre_fisc() THEN #versão 10.02
     RETURN FALSE
  END IF

  IF NOT pol0989_atu_fat_mestre() THEN #versão 10.02
     RETURN FALSE
  END IF
	
	IF NOT pol0989_insere_duplicata() THEN 
		RETURN FALSE
	END IF 
		
	IF NOT pol0989_valida_bases() THEN 
		RETURN FALSE	
	END IF 
	
	IF NOT pol0989_movimenta_estoque() THEN 
		RETURN FALSE 
	ELSE 
		CALL pol0989_exibe_tela()
	END IF 
	
	
	IF NOT pol0989_insere_integr() THEN 
		RETURN FALSE
	END IF
  UPDATE vdp_num_docum 
     SET num_ultimo_docum = p_num_nff
   WHERE empresa = p_cod_empresa
     AND serie_docum  IN (SELECT ser_nff
                             FROM par_nf_912
                            WHERE cod_empresa = p_cod_empresa
                              AND cod_param = p_param.cod_param)

	IF SQLCA.SQLCODE <> 0 THEN 
		CALL log003_err_sql("Atualizando",'vdp_num_docum')
		RETURN FALSE
	END IF  
		
	RETURN TRUE 

END FUNCTION 

#---------------------------#
FUNCTION pol0989_ins_mestre()
#---------------------------#

   DEFINE p_hor  CHAR(08),
          p_dat  CHAR(19)

   MESSAGE 'Gravando fat_nf_mestre!'
   
   LET p_dat = p_data
   LET p_hor = CURRENT HOUR TO SECOND
   LET p_dat = p_dat CLIPPED, " ", p_hor
   LET c_data = p_dat 
   
   INITIALIZE p_fat_mestre TO NULL
   LET p_num_nff = p_num_nff + 1
   
   LET p_fat_mestre.empresa            =  p_cod_empresa            
   LET p_fat_mestre.trans_nota_fiscal  =  0                        
   LET p_fat_mestre.tip_nota_fiscal    =  p_tip_docum             
   LET p_fat_mestre.serie_nota_fiscal  =  p_ser                    
   LET p_fat_mestre.subserie_nf        =  p_ssr                    
   LET p_fat_mestre.espc_nota_fiscal   =  p_esp                    
   LET p_fat_mestre.nota_fiscal        =  p_num_nff              
   LET p_fat_mestre.status_nota_fiscal =  'F'                      
   LET p_fat_mestre.modelo_nota_fiscal =  p_modelo_docum                    
   LET p_fat_mestre.origem_nota_fiscal =  'M'                      
   LET p_fat_mestre.tip_processamento  =  'A'                      
   LET p_fat_mestre.sit_nota_fiscal    =  'N'                      
   LET p_fat_mestre.cliente            =  p_param.cod_cliente            
   LET p_fat_mestre.remetent           =  ' '                      
   LET p_fat_mestre.zona_franca        =  'N'                      
   LET p_fat_mestre.natureza_operacao  =  p_param.cod_nat_oper           
   LET p_fat_mestre.finalidade         =  p_param.ies_finalidade         
   LET p_fat_mestre.cond_pagto         =  p_param.cod_cnd_pgto           
   LET p_fat_mestre.tip_carteira       =  p_param.cod_tip_carteira       
   LET p_fat_mestre.ind_despesa_financ =  0                        
   LET p_fat_mestre.moeda              =  p_param.cod_moeda                        
   LET p_fat_mestre.plano_venda        =  'N'     
   LET p_fat_mestre.transportadora     =  p_param.cod_cliente    
   LET p_fat_mestre.tip_frete          =  1 
   LET p_fat_mestre.via_transporte     =  1                      
   LET p_fat_mestre.peso_liquido       =  0                        
   LET p_fat_mestre.peso_bruto         =  0                        
   LET p_fat_mestre.peso_tara          =  0                        
   LET p_fat_mestre.num_prim_volume    =  0                        
   LET p_fat_mestre.volume_cubico      =  0                        
   LET p_fat_mestre.usu_incl_nf        =  p_user                   
   LET p_fat_mestre.dat_hor_emissao    =  p_data                  
   LET p_fat_mestre.sit_impressao      =  'N'                      
   LET p_fat_mestre.val_frete_rodov    =  0                        
   LET p_fat_mestre.val_seguro_rodov   =  0                        
   LET p_fat_mestre.val_fret_consig    =  0                        
   LET p_fat_mestre.val_segr_consig    =  0                        
   LET p_fat_mestre.val_frete_cliente  =  0                        
   LET p_fat_mestre.val_seguro_cliente =  0                        
   LET p_fat_mestre.val_desc_merc      =  0                        
   LET p_fat_mestre.val_desc_nf        =  0                        
   LET p_fat_mestre.val_desc_duplicata =  0                        
   LET p_fat_mestre.val_acre_merc      =  0                        
   LET p_fat_mestre.val_acre_nf        =  0                        
   LET p_fat_mestre.val_acre_duplicata =  0                        
   LET p_fat_mestre.val_mercadoria     =  0                        
   LET p_fat_mestre.val_duplicata      =  0                        
   LET p_fat_mestre.val_nota_fiscal    =  0                        
                       
                                                                   
   INSERT INTO fat_nf_mestre VALUES (p_fat_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('iNSERINDO','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   LET p_trans_nf = SQLCA.SQLERRD[2]
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0989_insere_item()#
#-----------------------------#

 DEFINE	l_cont SMALLINT,
				p_ies_tip_incid_ipi CHAR(01),
				p_uf 						    CHAR(02),
				l_seq						    SMALLINT,
				p_exce					    CHAR(04),
				l_index				      SMALLINT,
				p_msg						    CHAR(120),
				l_tem						    SMALLINT,
				p_cons  		        DECIMAL(5,2),
				p_contr 		        DECIMAL(5,2),
				p_ncontr		        DECIMAL(5,2),
				p_pct_desc_b_icm_c  DECIMAL(5,2),
				p_pct_desc_b_icm_nc DECIMAL(5,2)
				
 DEFINE p_conver        RECORD 
				cod_item	      CHAR(20),
				qtd_item        INTEGER ,
				total_val_item  INTEGER,
				desc_val_item   INTEGER,
 				acresc_val_item INTEGER

 END RECORD
	
	#O bloco a seguir, irá gravar os registros enviados na tabela TEMP t_arquivo ...

	
		LET l_cont = 1 
		
		DECLARE cq_convert	CURSOR FOR 
		 SELECT	arquivo[1,20]  cod_item,
						arquivo[21,29] qtd_item,
						arquivo[31,44] total_val_item,
						arquivo[45,58] desc_val_item,
						arquivo[59,72] acresc_val_item
			FROM t_entrada
		
		FOREACH cq_convert INTO p_conver.*  #tem erro
		
		    IF  p_conver.qtd_item  <= 0 THEN       # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM QUANTIDADE = 0 
			    CONTINUE FOREACH                   # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM QUANTIDADE = 0 
			END IF                                 # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM QUANTIDADE = 0 	
			
			
			IF  p_conver.total_val_item  <= 0 THEN # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM VALOR = 0 
			    CONTINUE FOREACH                   # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM VALOR = 0 
			END IF                                 # ALTERADO EM 09/03/2011 POR MANUEL PARA DESCONSIDERAR MOVIMENTOS DA LOJINHA COM VALOR = 0 	
		
			IF p_conver.cod_item[13,15] <> '000' THEN  #Se o codigo da posição 13 a 15 for <> de zero
					LET p_arquivo.cod_item	= p_conver.cod_item[13,20] #o codigo do item vai ser o codigo do logix
			ELSE
				 IF p_conver.cod_item[16,17] = '99' THEN	# Se for codigo 99 busco o item da posição 16 a 19
					  LET p_exce = p_conver.cod_item[16,19]						
				 ELSE  																						
					  LET p_exce = p_conver.cod_item[17,20]	# senão da 17à 20						
				 END IF 
				
				 LET p_encontrou = 'N'	
				
				 DECLARE cq_item2 CURSOR FOR 
					SELECT a.cod_item
					  FROM item_vdp a, 
					       item b
				 	 WHERE a.cod_item[4,7] = p_exce
					   AND a.cod_empresa   = p_cod_empresa
					   AND a.cod_item = b.COD_ITEM
					   AND a.cod_empresa = b.cod_empresa 
				 
				 FOREACH cq_item2 INTO p_arquivo.cod_item
											 
			      LET p_encontrou = 'S'
			  
					  EXIT FOREACH
					  
				 END FOREACH

  			 IF  p_encontrou = 'N' THEN  					
			      LET p_msg = 'Item: ',p_exce CLIPPED, ' item não encontrado na ITEM_VDP'
			      CALL pol0989_imprime_erros(p_msg)
			      LET p_erro = TRUE 
	  		    CONTINUE FOREACH
		  	 END IF 
				
			END IF 
						    
			LET p_arquivo.sequencia 			= l_cont													#Converte os valores e coloca as virgulas
			LET p_arquivo.qtd_item 				= p_conver.qtd_item /100
			LET p_arquivo.total_val_item	= p_conver.total_val_item /100
			LET p_arquivo.desc_val_item		= p_conver.desc_val_item /100
			LET p_arquivo.acresc_val_item	= p_conver.acresc_val_item /100
			
			
			LET p_exce = p_conver.cod_item[17,20]
					 
			SELECT cod_excecao
			  FROM par_excecoes
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_excecao = p_exce
			
			IF SQLCA.SQLCODE = 0 THEN						#Se estiver cadastrado nas excessões 
				 SELECT sequencia
					 INTO l_seq 
					 FROM t_arquivo
					WHERE cod_item = p_arquivo.cod_item	
					
					IF SQLCA.SQLCODE = 0 THEN																						
						 UPDATE t_arquivo																									
						    SET total_val_item = total_val_item + p_arquivo.total_val_item,	
						        qtd_item = 1,																											
						        desc_val_item = desc_val_item + p_arquivo.desc_val_item,					
						        cresc_val_item = acresc_val_item	+ p_arquivo.acresc_val_item
						  WHERE cod_item  = p_arquivo.cod_item
						    AND sequencia = l_seq
					ELSE
						 LET p_arquivo.qtd_item = 1									
																												
						 INSERT INTO t_arquivo VALUES (p_arquivo.*)
						
						 IF SQLCA.SQLCODE <> 0 THEN 
							  CALL log003_err_sql('insert', 't_arquivo')
						 END IF
						
						 LET l_cont = l_cont + 1
						
					END IF
			ELSE
				 LET sql_stmt = 
				  " SELECT sequencia, CASE qtd_item WHEN  0 THEN round((total_val_item /1),7) ",
       		"   ELSE round((total_val_item /qtd_item),7) END ",
					"   FROM t_arquivo ",
				  "  WHERE cod_item = '", p_arquivo.cod_item,"'"
				
				PREPARE var_queri FROM sql_stmt   
				LET l_tem = FALSE															#L_TEM tem a função de controlar quANDo vai ser um upadate  
				                                              # ou um insert pois podemos ter variios itens com preços dIFerentes
				DECLARE cq_igual CURSOR FOR 	var_queri				
					
				FOREACH cq_igual INTO l_seq, p_preco_uni
								
				   IF SQLCA.SQLCODE = 0 THEN
 						  
 						  IF p_arquivo.qtd_item = 0 THEN
						     LET p_arquivo.qtd_item = 1
					    END IF
	  
					    IF p_preco_uni = (p_arquivo.total_val_item / p_arquivo.qtd_item) THEN 

						     UPDATE t_arquivo
						        SET total_val_item = total_val_item + p_arquivo.total_val_item,
						            qtd_item = qtd_item + p_arquivo.qtd_item,
						            desc_val_item = desc_val_item + p_arquivo.desc_val_item,
						            acresc_val_item = acresc_val_item	+ p_arquivo.acresc_val_item
						      WHERE cod_item = p_arquivo.cod_item
						        AND sequencia = l_seq
						
						     LET l_tem = TRUE							     
						     EXIT FOREACH
						  END IF
					 END IF
					
				END FOREACH  
				
				IF NOT l_tem THEN 
					INSERT INTO t_arquivo VALUES (p_arquivo.*)
						IF SQLCA.SQLCODE <> 0 THEN 
							CALL log003_err_sql('insert', 't_arquivo')
						END IF 
						LET l_cont = l_cont + 1
				END IF 
			
			END IF 
			
		END FOREACH

	#... tabela t_arquivo gravada
	
	#INSERIR OS ITENS DA NOTA ...  #
	 
	DECLARE cq_t_arquiv	SCROLL CURSOR FOR 
	 SELECT * 
	   FROM t_arquivo 
	  ORDER BY sequencia

	FOREACH cq_t_arquiv INTO 
	        p_arquivo.cod_item,
	        p_arquivo.sequencia,
	        p_arquivo.qtd_item,
	        p_arquivo.total_val_item,
	        p_arquivo.desc_val_item,
	        p_arquivo.acresc_val_item	        

		IF p_arquivo.total_val_item <= 0 OR
		   p_arquivo.total_val_item IS NULL THEN
			 LET p_msg = 'Item: ',p_arquivo.cod_item CLIPPED, ' sem valor total, item descartado'
			 CALL pol0989_imprime_erros(p_msg)
			 CONTINUE FOREACH
		END IF

		IF p_arquivo.qtd_item <= 0 OR
		   p_arquivo.qtd_item IS NULL THEN
			 LET p_msg = 'Item: ',p_arquivo.cod_item CLIPPED, ' sem a quantidade, item descartado'
			 CALL pol0989_imprime_erros(p_msg)
			 CONTINUE FOREACH
		END IF

    LET p_cod_nat_oper = p_param.cod_nat_oper 
    LET p_cod_item     = p_arquivo.cod_item

		SELECT den_item, 
		       pes_unit, 
		       cod_cla_fisc, 
		       cod_unid_med, 
		       fat_conver
		  INTO p_des_item , 
			 		 p_pes_unit,
					 p_cod_cla_fisc,
					 p_cod_unid_med,
					 p_fat_conver
 		  FROM item
		 WHERE cod_empresa = p_cod_empresa
		   AND cod_item    = p_cod_item
		
		IF SQLCA.SQLCODE <> 0 THEN
			 LET p_msg = log0030_txt_err_sql("SELECT","item"),' Codigo Item:',p_arquivo.cod_item
			 CALL pol0989_imprime_erros(p_msg)
			 LET p_erro = TRUE 
			 CONTINUE FOREACH
		END IF 
    
    IF NOT pol0989_le_param_fisc() THEN 
       CONTINUE FOREACH
    END IF

    IF NOT pol0989_ins_tributo_fisc() THEN # versão 10.02
			 CONTINUE FOREACH
    END IF
    
    INITIALIZE p_fat_item TO NULL                                      
                                                                       
    IF NOT pol0989_le_item() THEN                                      
       RETURN FALSE                                                    
    END IF                                                             
                                                                       
    {IF NOT pol0989_le_tip_item() THEN                                  
       RETURN FALSE                                                    
    END IF}           

    LET p_tip_item= 'P'	
	
	LET p_valor_ipi_item	= 0  
	select SUM(val_tributo_tot)   
      INTO p_valor_ipi_item	
	  FROM    FAT_NF_ITEM_FISC
	  WHERE  empresa		   =	p_cod_empresa
	    AND  trans_nota_fiscal = p_trans_nf 
		AND  seq_item_nf       = p_arquivo.sequencia 
		AND  tributo_benef     = 'IPI'
		
	    IF SQLCA.SQLCODE <> 0 THEN
           LET p_valor_ipi_item	= 0  
		END IF 
    LET p_preco_uni_nf = (p_arquivo.total_val_item -  p_valor_ipi_item) / p_arquivo.qtd_item 	                                            

	LET p_fat_item.empresa            = p_cod_empresa                  
	LET p_fat_item.trans_nota_fiscal  = p_trans_nf                     
	LET p_fat_item.seq_item_nf  	 	  = p_arquivo.sequencia           
	LET p_fat_item.pedido  			 = 0                               
	LET p_fat_item.seq_item_pedido    = 0                              
    LET p_fat_item.ord_montag         = 0                              
    LET p_fat_item.tip_item           = 'N'                             
	LET p_fat_item.item     				   = p_arquivo.cod_item            
	LET p_fat_item.des_item           = p_des_item                     
    LET p_fat_item.unid_medida        = p_cod_unid_med                 
    LET p_fat_item.peso_unit          = p_pes_unit                     
 	LET p_fat_item.qtd_item           = p_arquivo.qtd_item 		         
    LET p_fat_item.fator_conv         = p_fat_conver                   
    LET p_fat_item.tip_preco          = 'F'                            
    LET p_fat_item.natureza_operacao  = p_cod_nat_oper                 
    LET p_fat_item.classif_fisc       = p_cod_cla_fisc                 
    LET p_fat_item.item_prod_servico  = p_tip_item                     
    LET p_fat_item.preco_unit_bruto   = 0                
    LET p_fat_item.pre_uni_desc_incnd = p_preco_uni_nf                 
    LET p_fat_item.preco_unit_liquido = p_preco_uni_nf                 
    LET p_fat_item.pct_frete          = 0                              
    LET p_fat_item.val_desc_item      = p_arquivo.desc_val_item        
    LET p_fat_item.val_desc_merc      = 0                              
    LET p_fat_item.val_desc_contab    = 0                              
    LET p_fat_item.val_desc_duplicata = 0                              
    LET p_fat_item.val_acresc_item    = 0                             
    LET p_fat_item.val_acre_merc      = 0                              
    LET p_fat_item.val_acresc_contab  = p_valor_ipi_item                               
    LET p_fat_item.val_acre_duplicata = 0                              
    LET p_fat_item.val_fret_consig    = 0                              
    LET p_fat_item.val_segr_consig    = 0                              
    LET p_fat_item.val_frete_cliente  = 0                              
    LET p_fat_item.val_seguro_cliente = 0                              
    LET p_fat_item.val_bruto_item     = 0      
    LET p_fat_item.val_brt_desc_incnd = (p_arquivo.total_val_item -  p_valor_ipi_item)      
    LET p_fat_item.val_liquido_item   = (p_arquivo.total_val_item -  p_valor_ipi_item)              
    LET p_fat_item.val_merc_item      = (p_arquivo.total_val_item -  p_valor_ipi_item)        
    LET p_fat_item.val_duplicata_item = p_arquivo.total_val_item       
    LET p_fat_item.val_contab_item    = p_arquivo.total_val_item       
                                                                       
    LET p_tot_peso = p_tot_peso + (p_pes_unit * p_fat_item.qtd_item)   
                                                                       
    INSERT INTO fat_nf_item VALUES(p_fat_item.*)                       
                                                                       
	  IF SQLCA.SQLCODE <> 0 THEN                                         
			 LET p_msg = log0030_txt_err_sql("SELECT","fat_nf_item"),         
			            ' Codigo Item:',p_arquivo.cod_item                   
			 CALL pol0989_imprime_erros(p_msg)                                
			 LET p_erro = TRUE                                                
			 CONTINUE FOREACH                                                 
	  END IF                                                             
		
	END FOREACH
	
	IF  p_erro THEN 
		 RETURN FALSE
	ELSE
		 RETURN TRUE
	END IF 
	
END FUNCTION 

#------------------------------#
FUNCTION pol0989_le_param_fisc()
#------------------------------#

   
   LET m_msg = NULL
   DELETE FROM tributo_tmp
   LET p_ies_tipo = 'S'                   #S-Saida
   LET p_cod_cliente = p_param.cod_cliente

   SELECT b.cod_uni_feder,
          b.cod_cidade   
     INTO p_cod_uni_feder,
          p_cod_cidade    
     FROM clientes a, cidades b
    WHERE a.cod_cliente = p_param.cod_cliente
      AND b.cod_cidade  = a.cod_cidade

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'LENDO TABELAS CLIENTES E CIDADES'
			CALL pol0989_imprime_erros(p_msg)
			LET p_erro = TRUE 
      RETURN FALSE
   END IF
   
   
   LET p_tip_item= 'P'
   
   SELECT COUNT(tributo_benef)                 #Verifica se tem tribustos 
     INTO p_count                                #cadastrados
     FROM obf_oper_fiscal  
    WHERE empresa           = p_cod_empresa
	  AND origem            = p_ies_tipo
      AND nat_oper_grp_desp = p_cod_nat_oper

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'CHECANDO TABELAS OBF_OPER_FISCAL E OBF_TRIBUTO_BENEF'
			CALL pol0989_imprime_erros(p_msg)
			LET p_erro = TRUE 
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'TRIBUTOS FISCAIS NAO ENCONTRADOS P/ NAT. OPER. = ',p_cod_nat_oper,
                  ' ITEM = ', p_cod_item
			CALL pol0989_imprime_erros(p_msg)
			LET p_erro = TRUE 
      RETURN FALSE      
   END IF
   
   LET m_msg = NULL 
	   
	   
   DECLARE cq_tributos	CURSOR FOR    
   SELECT DISTINCT tributo_benef                        
     FROM obf_oper_fiscal  
    WHERE empresa           = p_cod_empresa
	  AND origem            = p_ies_tipo
      AND nat_oper_grp_desp = p_cod_nat_oper

	  
   FOREACH  cq_tributos INTO
            p_tributo_benef

      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO ', p_cod_status, 'LENDO TABELAS OBF_OPER_FISCAL E OBF_TRIBUTO_BENEF'
			   CALL pol0989_imprime_erros(p_msg)
			   LET p_erro = TRUE 
         RETURN FALSE
      END IF

      LET p_tem_tributo = FALSE   
	 
	    IF NOT pol0989_le_tributo()  THEN 
	       RETURN FALSE	
      END IF 
	   
	    IF NOT p_tem_tributo THEN	
	       EXIT FOREACH
      END IF 		 

   END FOREACH
   
   IF NOT p_tem_tributo THEN
      LET p_msg = 'NAO EXISTEM PARAMETROS FISCAIS P/ ',
                  'NAT OPER = ',p_cod_nat_oper,
                  'ITEM = ',p_cod_item, 'TRIBUTO = ', p_tributo_benef
		  CALL pol0989_imprime_erros(p_msg)
 	    LET p_erro = TRUE 
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0989_le_tributo()
#----------------------------#

      IF NOT pol0989_checa_tributo('1') THEN
	     RETURN FALSE	
      END IF 
	  
	  IF  p_tributo_benef  <> 'IPI'   THEN 
	      RETURN TRUE 
	  END IF 	  
		  
	  IF p_tem_tributo THEN
	  	 RETURN TRUE 
	  END IF 	  
	  
	  IF NOT pol0989_checa_tributo('2') THEN
	     RETURN FALSE	
      END IF 
		  
	  IF p_tem_tributo THEN
	  	 RETURN TRUE 
	  END IF 	 
	 
	  IF NOT pol0989_checa_tributo('3') THEN
	     RETURN FALSE	
      END IF 
		  
	  IF p_tem_tributo THEN
	  	 RETURN TRUE 
	  END IF 	

	   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0989_le_tip_item()
#----------------------------#

   SELECT parametro_ind
    INTO p_tip_item                       #P-Produto S-Serviço
    FROM vdp_parametro_item 
   WHERE empresa   = p_cod_empresa
     AND item      = p_cod_item
     AND parametro = 'tipo_item'
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_parametro_item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------------#
FUNCTION pol0989_checa_tributo(p_situacao)
#-----------------------------------------#

   DEFINE p_situacao   CHAR (01)
   
   LET p_matriz = 'SSSSSSSSSSSSSSSSSSSSSSSS'
   
   
   SELECT   empresa,
			tributo_benef,
			natureza_operacao,
			ctr_nat_operacao, 	
			grp_fiscal_regiao, 	
    		ctr_grp_fisc_regi, 	
    		estado, 				
    		controle_estado, 	
   			municipio, 			
			controle_municipio,  
			carteira, 			
			controle_carteira, 	
			finalidade, 			
			ctr_finalidade, 		
			familia_item, 		
			ctr_familia_item, 	
			grp_fiscal_classif, 	
			ctr_grp_fisc_clas, 	
			classif_fisc, 		
			ctr_classif_fisc, 	
			linha_produto, 		
			ctr_linha_produto, 	
			linha_receita, 		
			ctr_linha_receita, 	 
			segmto_mercado, 		 
			ctr_segmto_mercado, 	 
			classe_uso, 			 
			ctr_classe_uso, 		 
			unid_medida, 		 
			ctr_unid_medida, 	 
			produto_bonific, 	 
			ctr_prod_bonific, 	 
			grupo_fiscal_item, 	 
			ctr_grp_fisc_item,	 
			item, 				 
			controle_item, 		 
			micro_empresa, 		 
			ctr_micro_empresa, 	 
			grp_fiscal_cliente, 	 
			ctr_grp_fisc_cli, 	 
			cliente, 			 
			controle_cliente, 	 
			via_transporte, 		 
			ctr_via_transporte, 	 
			tem_valid_config, 	 
			ctrl_valid_config  
	 INTO p_obf_controle_chave.*
	 FROM obf_controle_chave
    WHERE empresa         = p_cod_empresa
      AND tributo_benef   = p_tributo_benef


   LET p_query = 
       "SELECT trans_config FROM obf_config_fiscal ",
       " WHERE empresa = '",p_cod_empresa,"' ",
       " AND origem  = '",p_ies_tipo,"' ",
       " AND tributo_benef = '",p_tributo_benef,"' "
       
     
      IF p_obf_controle_chave.natureza_operacao  = 'S'  THEN 
         LET p_query  = p_query CLIPPED, " AND nat_oper_grp_desp = '",p_cod_nat_oper,"' "
         LET p_matriz[1] = 'N'
      END IF  		 
      
      IF p_obf_controle_chave.grp_fiscal_regiao  = 'S'  THEN
         IF NOT pol0989_le_obf_regiao() THEN
            RETURN FALSE
         END IF
		 IF p_regiao_fiscal IS NOT NULL THEN 
            LET p_query  = p_query CLIPPED, " AND grp_fiscal_regiao = '",p_regiao_fiscal,"' "
            LET p_matriz[2] = 'N'
		 END IF 	
	  END IF 

      IF p_obf_controle_chave.finalidade = 'S'  THEN
         LET p_query  = p_query CLIPPED, " AND finalidade = '",p_param.ies_finalidade,"' "
         LET p_matriz[6] = 'N'
	  END IF 	 

	  
	  IF p_tributo_benef   = 'IPI'    THEN 
	     IF p_situacao <> '3'   THEN 
	  	    IF p_obf_controle_chave.classif_fisc = 'S' THEN
               LET p_query  = p_query CLIPPED, " AND classif_fisc = '",p_cod_cla_fisc,"' "
               LET p_matriz[10] = 'N'
	        END IF 
		 END IF 	
	  ELSE 
         IF p_obf_controle_chave.grp_fiscal_classif = 'S'  THEN
            IF NOT pol0989_le_obf_cl_fisc() THEN
               RETURN FALSE
            END IF
		    IF p_grp_classif_fisc IS NOT NULL THEN 
               LET p_query  = p_query CLIPPED, " AND grp_fiscal_classif = '",p_grp_classif_fisc,"' "
               LET p_matriz[9] = 'N'
		    END IF  	
	     END IF  
      END IF 		
	  
      IF p_obf_controle_chave.grupo_fiscal_item = 'S'  THEN 
	     IF p_tributo_benef   	= 'IPI'   
         AND p_situacao 		= '2'   THEN
         ELSE		 
		    	IF NOT pol0989_le_obf_fisc_item() THEN
					RETURN FALSE
				END IF
				IF p_grp_fiscal_item  IS NOT NULL THEN 
					LET p_query  = p_query CLIPPED, " AND grupo_fiscal_item = '",p_grp_fiscal_item,"' "
					LET p_matriz[17] = 'N'
				END IF
		 END IF		
      END IF 		 

      IF p_tributo_benef   <> 'IPI'    THEN 
	     IF p_obf_controle_chave.cliente = 'S'  THEN 
            LET p_query  = p_query CLIPPED, " AND cliente = '",p_cod_cliente,"' "
            LET p_matriz[21] = 'N'
	     END IF
	  END IF	 
   
      LET p_query  = p_query CLIPPED, 
          " AND (matriz = '",p_matriz,"' OR matriz IS NULL) "
   
      PREPARE var_query FROM p_query   
      DECLARE cq_obf_cfg CURSOR FOR var_query

      FOREACH cq_obf_cfg INTO p_trans_config

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','cq_obf_cfg')
            RETURN FALSE
         END IF
         
         INSERT INTO tributo_tmp
          VALUES(p_tributo_benef, p_trans_config)

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('inserindo','tributo_tmp')
            RETURN FALSE
         END IF
		 
		     LET p_tem_tributo = TRUE
         
         EXIT FOREACH
      
      END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0989_le_obf_regiao()
#-------------------------------#

   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = p_cod_empresa
         AND tributo_benef = p_tributo_benef
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'obf_regiao_fiscal')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION pol0989_le_obf_cl_fisc()
#-------------------------------#

   SELECT grupo_classif_fisc
     INTO p_grp_classif_fisc
     FROM obf_grp_cl_fisc
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND classif_fisc  = p_cod_cla_fisc
   
   IF STATUS = 100 THEN
      LET p_grp_classif_fisc = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_regiao_fiscal')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0989_le_obf_fisc_item()
#---------------------------------#

   SELECT grupo_fiscal_item
     INTO p_grp_fiscal_item
     FROM obf_grp_fisc_item
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND item          = p_cod_item
   
   IF STATUS = 100 THEN
      LET p_grp_fiscal_item = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_item')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0989_le_obf_fisc_cli()
#---------------------------------#

   SELECT grp_fiscal_cliente
     INTO p_grp_fisc_cliente
     FROM obf_grp_fisc_cli
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND cliente       = p_cod_cliente
   
   IF STATUS = 100 THEN
      LET p_grp_fisc_cliente = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_cli')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------#
FUNCTION pol0989_le_item()
#-------------------------#

   SELECT cod_lin_prod,                                         
          cod_lin_recei,                                     
          cod_seg_merc,                                      
          cod_cla_uso,                                       
          cod_familia,                                       
          gru_ctr_estoq,                                     
          cod_cla_fisc,                                      
          cod_unid_med,
          pes_unit,
          fat_conver                                      
     INTO p_cod_lin_prod,                                    
          p_cod_lin_recei,                                   
          p_cod_seg_merc,                                    
          p_cod_cla_uso,                                     
          p_cod_familia,                                     
          p_gru_ctr_estoq,                                   
          p_cod_cla_fisc,                                    
          p_cod_unid_med,
          p_pes_unit,
          p_fat_conver                          
     FROM item                                               
    WHERE cod_empresa  = p_cod_empresa                       
      AND cod_item     = p_cod_item          

   IF STATUS <> 0 THEN
      ERROR 'Item; ',p_cod_item
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0989_le_me()
#-----------------------#

   SELECT tip_parametro
     INTO p_micro_empresa
     FROM vdp_cli_parametro
    WHERE cliente   = p_cod_cliente 
      AND parametro = 'microempresa'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_cli_parametro')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#---------------------------------#
FUNCTION pol0989_ins_tributo_fisc()
#---------------------------------#

   SELECT trans_config
     INTO p_trans_config
     FROM tributo_tmp
    WHERE tributo_benef = 'IPI'

   IF STATUS <> 0 THEN
      LET p_val_base_trib   = p_arquivo.total_val_item 
   ELSE
      SELECT aliquota
        INTO p_aliquota_ipi
        FROM obf_config_fiscal
       WHERE empresa  	= p_cod_empresa
         AND trans_config = p_trans_config
         
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO ', p_cod_status, 'LENDO TABELA OBF_CONFIG_FISCAL - IPI'
		 CALL pol0989_imprime_erros(p_msg)
		 LET p_erro = TRUE 
         RETURN FALSE
      END IF
	       
   END IF
		
   DECLARE cq_trib_tmp CURSOR FOR
    SELECT tributo_benef,
           trans_config
      FROM tributo_tmp

   FOREACH cq_trib_tmp INTO p_tributo_benef, p_trans_config

      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO ', p_cod_status, 'LENDO TABELA TEMPORARIA TRIBUTO_TMP'
		     CALL pol0989_imprime_erros(p_msg)
			   LET p_erro = TRUE 
         RETURN FALSE
      END IF
      
      IF NOT pol0989_le_obf_config() THEN
         RETURN FALSE
      END IF

      IF p_tributo_benef = 'ICMS'   THEN
	       LET p_val_base_trib = p_arquivo.total_val_item  - (p_val_base_trib * (p_pct_reduz_icm/100))
	       IF p_controle_fci = '1' THEN                         #ivo 24/09/2013
            CALL pol0989_grava_fci() RETURNING p_status       #ivo 24/09/2013
         END IF                                               #ivo 24/09/2013
      ELSE	
         LET p_val_base_trib    = p_arquivo.total_val_item / (1+(p_aliquota_ipi / 100))
	    END IF
	  
      LET p_val_tribruto = p_val_base_trib * (p_aliquota / 100)

      IF NOT pol0989_ins_fisc() THEN
         RETURN FALSE
      END IF
	      
   END FOREACH
   
# acerta codigo fiscal dos demais registros de impostos para o item da nota que foi gravado 

   INITIALIZE p_cod_fiscal   TO NULL 

			SELECT 
			cod_fiscal
			INTO 
			p_cod_fiscal
			FROM  fat_nf_item_fisc
			where empresa			=	p_cod_empresa
			and   trans_nota_fiscal	=	p_trans_nf 
			and tributo_benef		=	'ICMS'
			and seq_item_nf			=	p_arquivo.sequencia 
   
      IF STATUS = 0 THEN
            UPDATE         
			fat_nf_item_fisc
			SET cod_fiscal=p_cod_fiscal
 			where empresa			=	p_cod_empresa
			and   trans_nota_fiscal	=	p_trans_nf 
			and tributo_benef		<>	'ICMS'
			and seq_item_nf			=	p_arquivo.sequencia 
      END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0989_ins_fisc()
#--------------------------#

   LET p_item_fisc.empresa              = p_cod_empresa   
   LET p_item_fisc.trans_nota_fiscal    = p_trans_nf      
   LET p_item_fisc.seq_item_nf          = p_arquivo.sequencia           
   LET p_item_fisc.incide               = p_cod_incide        
   LET p_item_fisc.aliquota             = p_aliquota      
   LET p_item_fisc.tributo_benef        = p_tributo_benef 
   LET p_item_fisc.trans_config         = p_trans_config  
   LET p_item_fisc.bc_trib_mercadoria   = p_val_base_trib                 
   LET p_item_fisc.bc_tributo_frete     = 0                               
   LET p_item_fisc.bc_trib_calculado    = 0                            
   LET p_item_fisc.bc_tributo_tot       = p_val_base_trib                  
   LET p_item_fisc.val_trib_merc        = p_val_tribruto
   LET p_item_fisc.val_tributo_frete    = 0                               
   LET p_item_fisc.val_trib_calculado   = 0                            
   LET p_item_fisc.val_tributo_tot      = p_val_tribruto
      
   INSERT INTO fat_nf_item_fisc
      VALUES(p_item_fisc.*)
      
   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO TRIBUTOS DA TABELA FAT_NF_ITEM_FISC'
      CALL pol0989_imprime_erros(p_msg)
	    LET p_erro = TRUE 
      RETURN FALSE
   END IF
	  
   RETURN TRUE

END FUNCTION



#--------------------------#
FUNCTION pol0989_txt_fisc()
#--------------------------#

   DEFINE p_hist_fiscal    LIKE  fat_nf_item_fisc.hist_fiscal,
	        p_txt_fiscal     LIKE  fiscal_hist.tex_hist_1,
		      p_seq_txt        LIKE  fat_nf_texto_hist.sequencia_texto

   DECLARE  cq_hist_fiscal  CURSOR FOR

	 SELECT DISTINCT hist_fiscal, tex_hist_1
	   FROM fat_nf_item_fisc, 
	        fiscal_hist
		WHERE hist_fiscal = cod_hist
      AND empresa = p_cod_empresa
	    AND trans_nota_fiscal = p_trans_nf 
		  AND hist_fiscal > 0

   FOREACH cq_hist_fiscal INTO p_hist_fiscal, p_txt_fiscal 
   
   		SELECT MAX(sequencia_texto)
		  INTO p_seq_txt
		  FROM fat_nf_texto_hist
		WHERE empresa = p_cod_empresa
	    AND trans_nota_fiscal = p_trans_nf 
		
		IF STATUS <> 0 THEN
		   LET p_seq_txt =  20
		ELSE 
		   IF  p_seq_txt   IS NULL THEN 
		       LET p_seq_txt =  1
		   ELSE
               LET p_seq_txt = p_seq_txt + 1	
           END IF			   
		END IF    

		LET p_seq_txt = p_seq_txt + 1	

		LET p_txt_hist.empresa              	= p_cod_empresa   
		LET p_txt_hist.trans_nota_fiscal    	= p_trans_nf      
		LET p_txt_hist.sequencia_texto       	= p_seq_txt           
		LET p_txt_hist.texto                	 = p_hist_fiscal        
		LET p_txt_hist.des_texto             	= p_txt_fiscal     
		LET p_txt_hist.tip_txt_nf       		= 2
   
   
		INSERT INTO fat_nf_texto_hist
			VALUES(p_txt_hist.*)
      
		IF STATUS <> 0 THEN
			LET p_cod_status = STATUS
			LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO TRIBUTOS DA TABELA FAT_NF_texto_hist'
			CALL pol0989_imprime_erros(p_msg)
				LET p_erro = TRUE 
			RETURN FALSE
		END IF
      END FOREACH
	  
	RETURN TRUE

END FUNCTION
#-------------------------------#
FUNCTION pol0989_le_obf_config()
#-------------------------------#

   SELECT incide,                      
          aliquota, 
          acresc_desc,              
          aplicacao_val,               
          origem_produto,              
          hist_fiscal,                 
          sit_tributo,                 
          inscricao_estadual,          
          dipam_b,                     
          retencao_cre_vdp,            
          motivo_retencao,             
          val_unit,                    
          pre_uni_mercadoria,          
          pct_aplicacao_base,          
          pct_acre_bas_calc,  
          pct_red_bas_calc,         
          pct_diferido_base,           
          pct_diferido_val,            
          pct_acresc_val,              
          pct_reducao_val,             
          pct_margem_lucro,            
          pct_acre_marg_lucr,          
          pct_red_marg_lucro,          
          taxa_reducao_pct,            
          taxa_acresc_pct,
		      cod_fiscal,
		      tributacao,
		      controle_fci             #ivo 24/09/2013
     INTO p_cod_incide,                    
          p_aliquota,
          p_item_fisc.acresc_desc,               
          p_item_fisc.aplicacao_val,             
          p_item_fisc.origem_produto,            
          p_item_fisc.hist_fiscal,               
          p_item_fisc.sit_tributo,               
          p_item_fisc.inscricao_estadual,        
          p_item_fisc.dipam_b,                   
          p_item_fisc.retencao_cre_vdp,          
          p_item_fisc.motivo_retencao,           
          p_item_fisc.val_unit,                  
          p_item_fisc.pre_uni_mercadoria,        
          p_item_fisc.pct_aplicacao_base,        
          p_item_fisc.pct_acre_bas_calc, 
          p_item_fisc.pct_red_bas_calc,        
          p_item_fisc.pct_diferido_base,         
          p_item_fisc.pct_diferido_val,          
          p_item_fisc.pct_acresc_val,            
          p_item_fisc.pct_reducao_val,           
          p_item_fisc.pct_margem_lucro,          
          p_item_fisc.pct_acre_marg_lucr,        
          p_item_fisc.pct_red_marg_lucro,        
          p_item_fisc.taxa_reducao_pct,          
          p_item_fisc.taxa_acresc_pct,
		      p_item_fisc.cod_fiscal,
		      p_item_fisc.tributacao,
		      p_controle_fci                    #ivo 24/09/2013
     FROM obf_config_fiscal
    WHERE empresa      = p_cod_empresa
      AND trans_config = p_trans_config                             

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'LENDO TRIBUTOS DA TABELA OBF_CONFIG_FISCAL'
      CALL pol0989_imprime_erros(p_msg)
	    LET p_erro = TRUE 
      RETURN FALSE
   END IF

   LET p_pct_reduz_icm = p_item_fisc.pct_red_bas_calc
   
   IF p_pct_reduz_icm IS NULL THEN
      LET p_pct_reduz_icm = 0
   END IF

   IF p_aliquota IS NULL THEN
      LET p_aliquota = 0
   END IF       		     
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0989_mestre_fisc()
#-----------------------------#

   MESSAGE 'Gravando fat_mestre_fiscal!'
   
   INITIALIZE p_mest_fisc TO NULL

   LET p_mest_fisc.empresa            = p_cod_empresa  
   LET p_mest_fisc.trans_nota_fiscal  = p_trans_nf

   DECLARE cq_sum CURSOR FOR
    SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot)
      FROM fat_nf_item_fisc
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nf
     GROUP BY tributo_benef

   FOREACH cq_sum INTO 
           p_mest_fisc.tributo_benef,
           p_mest_fisc.bc_trib_mercadoria,
           p_mest_fisc.bc_tributo_tot,
           p_mest_fisc.val_trib_merc,
           p_mest_fisc.val_tributo_tot
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

      LET p_mest_fisc.bc_tributo_frete   = 0
      LET p_mest_fisc.bc_trib_calculado  = 0
      LET p_mest_fisc.val_tributo_frete  = 0
      LET p_mest_fisc.val_trib_calculado = 0

      INSERT INTO fat_mestre_fiscal
       VALUES(p_mest_fisc.*)
    
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_MESTRE_FISCAL'
         CALL pol0989_imprime_erros(p_msg)
	       LET p_erro = TRUE 
         RETURN FALSE
      END IF
   
   END FOREACH
    
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0989_atu_fat_mestre()
#--------------------------------#
          
   MESSAGE 'Atualizando fat_nf_mestre!'

	SELECT SUM(peso_unit * qtd_item), 
	       SUM(val_merc_item),
	       SUM(val_contab_item),
		   SUM(val_acresc_contab)
    INTO p_tot_peso,
         p_val_liqui,
         p_val_bruto,
		 p_val_acres
    FROM fat_nf_item
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','fat_nf_item:sum')
      RETURN FALSE
   END IF
    
   UPDATE fat_nf_mestre
      SET peso_bruto      	= p_tot_peso,
          peso_liquido    	= p_tot_peso,
          val_mercadoria  	= p_val_liqui,
          val_duplicata   	= p_val_bruto,
          val_nota_fiscal 	= p_val_bruto,
		  val_acre_nf       = p_val_acres
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_MESTRE_FISCAL'
      CALL pol0989_imprime_erros(p_msg)
      LET p_erro = TRUE 
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0989_insere_duplicata()#
#----------------------------------#

  INITIALIZE 	 p_nf_duplicata  TO NULL
  
  LET  p_nf_duplicata.empresa           = p_cod_empresa
  LET  p_nf_duplicata.trans_nota_fiscal = p_trans_nf
  LET  p_nf_duplicata.seq_duplicata     = 1
  LET  p_nf_duplicata.val_duplicata     = p_val_bruto
  LET  p_nf_duplicata.dat_vencto_sdesc  = p_data
  LET  p_nf_duplicata.pct_desc_financ   = 0
  LET  p_nf_duplicata.val_bc_comissao   = 0
  LET  p_nf_duplicata.agencia           = 0
  LET  p_nf_duplicata.dig_agencia       = ' '
  LET  p_nf_duplicata.titulo_bancario   = ' '
  LET  p_nf_duplicata.tip_duplicata     = 'N'
  LET  p_nf_duplicata.docum_cre         = ' '
  LET  p_nf_duplicata.empresa_cre       = ' '
	
	INSERT INTO fat_nf_duplicata
	 VALUES(p_nf_duplicata.*)	        
	 
	IF SQLCA.SQLCODE <> 0 THEN 
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_NF_DUPLICATA'
      CALL pol0989_imprime_erros(p_msg)
      LET p_erro = TRUE 
      RETURN FALSE
	END IF 
	
	RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol0989_valida_bases()#		
#------------------------------#		

   #compara o icms obitido para ver se o usuario realmente valida o valor senão
   #ele cancela a operação(variação que pode ocorrer e de 0,25 centavos)

   DEFINE l_val_tot_icm, 
          l_val_tot_base_icm,
          l_limite 	          DECIMAL(17,2),
			    l_msg               CHAR(700)

	LET l_limite = 1/4          # limite e de 0,25 centavos de diferença
	
	SELECT val_trib_merc, 
	       bc_tributo_tot
	  INTO l_val_tot_icm, 
	       l_val_tot_base_icm
	  FROM fat_mestre_fiscal
	 WHERE empresa           = p_cod_empresa
	   AND trans_nota_fiscal = p_trans_nf
	   AND tributo_benef     = 'ICMS'

	IF ((p_val_icm - l_limite) > l_val_tot_icm) OR 
	   ((p_val_icm + l_limite) < l_val_tot_icm) THEN 
		   
		 LET l_msg = "O ICMS aprensentou divergencia\n",
		             "nos valores maior que o informado.\n",
		             "Valor do ICSM informado R$",p_val_icm USING "##,##&.&&\n",
								 "Valor de ICMS obtido R$" ,l_val_tot_icm USING "##,##&.&&\n",
								 "Valor base R$",p_val_base_icm USING "##,##&.&&\n",
								 "Valor base obtido R$",l_val_tot_base_icm USING "##,##&.&&\n",
								 "Deseja continuar?"
		IF NOT log0040_confirm(18,35,l_msg) THEN
			RETURN FALSE
		END IF 
		
	END IF 
	
	RETURN TRUE
	 
END FUNCTION


#-----------------------------------#
FUNCTION pol0989_movimenta_estoque()#
#-----------------------------------#

DEFINE p_baixa RECORD 
			 cod_item				LIKE fat_nf_item.item,
			 qtd_item				LIKE fat_nf_item.qtd_item,
			 num_sequencia	LIKE fat_nf_item.seq_item_nf
END RECORD 

DEFINE 	p_estoque RECORD
				qtd_saldo				LIKE estoque_lote.qtd_saldo,
				endereco				LIKE estoque_lote_ender.endereco,
				ies_ctr_estoque			LIKE item.ies_ctr_estoque,
				num_transac 			LIKE estoque_lote.num_transac,
				num_transac_ender		LIKE estoque_lote_ender.num_transac,
				cod_local				LIKE estoque_lote.cod_local,
				num_lote				LIKE estoque_lote.num_lote,
				num_volume 				LIKE estoque_lote_ender.num_volume,
				cod_grade_1 			LIKE estoque_lote_ender.cod_grade_1,
				cod_grade_2 			LIKE estoque_lote_ender.cod_grade_2,
				cod_grade_3 			LIKE estoque_lote_ender.cod_grade_3,
				cod_grade_4 			LIKE estoque_lote_ender.cod_grade_4,
				cod_grade_5				LIKE estoque_lote_ender.cod_grade_5,
				dat_hor_producao 		LIKE estoque_lote_ender.dat_hor_producao,
				num_ped_ven 			LIKE estoque_lote_ender.num_ped_ven,
				num_seq_ped_ven 		LIKE estoque_lote_ender.num_seq_ped_ven,
				ies_origem_entrada 		LIKE estoque_lote_ender.ies_origem_entrada,
				dat_hor_validade 		LIKE estoque_lote_ender.dat_hor_validade,
				num_peca 				LIKE estoque_lote_ender.num_peca,
				num_serie 				LIKE estoque_lote_ender.num_serie,
				comprimento 			LIKE estoque_lote_ender.comprimento,
				largura 				LIKE estoque_lote_ender.largura,
				altura 					LIKE estoque_lote_ender.altura,
				diametro 				LIKE estoque_lote_ender.diametro,
				dat_hor_reserv_1 		LIKE estoque_lote_ender.dat_hor_reserv_1,
				dat_hor_reserv_2 		LIKE estoque_lote_ender.dat_hor_reserv_2,
				dat_hor_reserv_3 		LIKE estoque_lote_ender.dat_hor_reserv_3,
				qtd_reserv_1 			LIKE estoque_lote_ender.qtd_reserv_1,
				qtd_reserv_2 			LIKE estoque_lote_ender.qtd_reserv_2,
				qtd_reserv_3 			LIKE estoque_lote_ender.qtd_reserv_3,
				num_reserv_1 			LIKE estoque_lote_ender.num_reserv_1,
				num_reserv_2 			LIKE estoque_lote_ender.num_reserv_2,
				num_reserv_3 			LIKE estoque_lote_ender.num_reserv_3,
				tex_reservado 			LIKE estoque_lote_ender.tex_reservado,
				identif_estoque 		LIKE estoque_lote_ender.identif_estoque ,
				deposit 				LIKE estoque_lote_ender.deposit
 


END RECORD 

DEFINE 		 p_estoque_trans 		RECORD LIKE estoque_trans.*,
			 p_estoque_trans_end  	RECORD LIKE estoque_trans_end .*,
			 p_est_trans_area_lin	RECORD LIKE est_trans_area_lin.*,
			 p_nf_item_transac		RECORD LIKE fat_ctr_est_nf.*,
			 p_estoque_auditoria 	RECORD LIKE estoque_auditoria.*,
			 p_estoque_loc_reser    RECORD LIKE estoque_loc_reser.*,
			 p_est_loc_reser_end    RECORD LIKE est_loc_reser_end.*


DEFINE p_movito				LIKE estoque_lote.qtd_saldo,
			 p_movito_pen 	LIKE estoque_lote.qtd_saldo,
			 p_cod_movto		LIKE nat_operacao.cod_movto_estoq,
			 p_num_conta		LIKE estoque_operac_ct.num_conta_debito,
			 p_num_transac	LIKE estoque_lote.num_transac,
			 p_cod_exce			CHAR(04),
			 p_movito_trans	LIKE estoque_lote.qtd_saldo,
			 p_tip_reg			CHAR(1),
			 p_seq_ant      LIKE fat_nf_item.seq_item_nf
		
		DELETE FROM t_ctrl_trans

	  IF STATUS <> 0 THEN
	     CALL log003_err_sql('Deletando','t_ctrl_trans')
	     RETURN FALSE
	  END IF

	SELECT cod_movto_estoq 
	INTO p_cod_movto
	FROM nat_operacao  
	WHERE cod_nat_oper = p_param.cod_nat_oper     

	  IF STATUS <> 0 THEN
	     CALL log003_err_sql('Lendo','nat_operacao')
	     RETURN FALSE
	  END IF
	
	SELECT num_conta_debito
	INTO p_num_conta
	FROM estoque_operac_ct  
	WHERE cod_empresa = p_cod_empresa
	AND cod_operacao = p_cod_movto             

	  IF STATUS <> 0 THEN
	     CALL log003_err_sql('Lendo','estoque_operac_ct')
	     RETURN FALSE
	  END IF
	
	DECLARE cq_baixa_estoque CURSOR FOR
		SELECT item, 
		       qtd_item, 
		       seq_item_nf
		  FROM fat_nf_item
		 WHERE empresa = p_cod_empresa
		   AND trans_nota_fiscal = p_trans_nf
		 ORDER BY seq_item_nf
	
	LET p_seq_ant = 0 
	
	FOREACH cq_baixa_estoque INTO p_baixa.*
	
	  IF STATUS <> 0 THEN
	     CALL log003_err_sql('Lendo','cq_baixa_estoque')
	     RETURN FALSE
	  END IF
	  
		LET p_movito_pen = p_baixa.qtd_item
		
		DECLARE cq_baixa_item CURSOR FOR 
		 SELECT a.qtd_saldo,
		        b.endereco, 
		        c.ies_ctr_estoque, 
		        a.num_transac, 
						b.num_transac,
						a.cod_local,
						a.num_lote,
						b.num_volume, 				
						b.cod_grade_1, 
						b.cod_grade_2, 			
						b.cod_grade_3, 		
						b.cod_grade_4, 			
						b.cod_grade_5,			
						b.dat_hor_producao, 		
						b.num_ped_ven, 			
						b.num_seq_ped_ven, 		
						b.ies_origem_entrada, 		
						b.dat_hor_validade, 		
						b.num_peca, 				
						b.num_serie, 				
						b.comprimento, 			
						b.largura, 				
						b.altura, 					
						b.diametro, 				
						b.dat_hor_reserv_1, 		
						b.dat_hor_reserv_2, 		
						b.dat_hor_reserv_3, 		
						b.qtd_reserv_1, 			
						b.qtd_reserv_2, 			
						b.qtd_reserv_3, 			
						b.num_reserv_1, 			
						b.num_reserv_2, 			
						b.num_reserv_3, 			
						b.tex_reservado, 			
						b.identif_estoque, 		
						b.deposit, 				
			 FROM estoque_lote a, 
			      estoque_lote_ender b, 
			      item c
			WHERE a.cod_item =b.cod_item
			  AND a.cod_item =c.cod_item
			  AND a.cod_local = b.cod_local
			  AND a.num_lote = b.num_lote
			  AND a.cod_empresa = b.cod_empresa
			  AND a.cod_empresa = c.cod_empresa
			  AND a.ies_situa_qtd = b.ies_situa_qtd
			  AND a.ies_situa_qtd = "L"
			  AND a.qtd_saldo > 0
			  AND c.ies_situacao <>"I"
			  AND a.cod_item = p_baixa.cod_item
			  AND a.cod_empresa = p_cod_empresa
			  AND (a.cod_local = p_param.cod_local OR a.cod_local = p_param.cod_local1 )
			ORDER BY a.cod_item,a.cod_local,b.num_lote
			
		FOREACH cq_baixa_item INTO p_estoque.*
			
			LET p_cod_exce = p_baixa.cod_item[1,4]
			
			SELECT * FROM par_excecoes
			WHERE cod_empresa = p_cod_empresa
			AND cod_excecao = p_cod_exce
			
			IF SQLCA.SQLCODE = 0 THEN 
				EXIT FOREACH
			END IF 
			
			IF p_movito_pen = 0 THEN 
				EXIT FOREACH
			END IF 
#---------Alterado pelo Manuel em 11/02/2011 daqui 	

	
			LET p_qtd_reservada = 0 
			
			SELECT SUM(qtd_reservada)
              INTO p_qtd_reservada
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_baixa.cod_item
            AND cod_local   = p_estoque.cod_local
			AND num_lote    = p_estoque.num_lote
			
			IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
				LET p_qtd_reservada = 0
            END IF
						
			LET p_estoque.qtd_saldo = p_estoque.qtd_saldo - p_qtd_reservada


#---------Alterado pelo Manuel em 11/02/2011 ate aqui	

#---------Alterado pelo Manuel em 09/03/2011 daqui 
			
			IF p_estoque.qtd_saldo <= 0 THEN 
			   CONTINUE FOREACH
			END IF    
	
#---------Alterado pelo Manuel em 09/03/2011 ate aqui	
	
			IF p_movito_pen > p_estoque.qtd_saldo THEN 
				LET p_movito = p_estoque.qtd_saldo
				LET p_movito_pen = p_movito_pen - p_estoque.qtd_saldo
			ELSE
				LET p_movito = p_movito_pen
				LET p_movito_pen = p_movito_pen - p_movito
			END IF 
			
			UPDATE estoque
			SET qtd_liberada = qtd_liberada - p_movito
			WHERE cod_empresa = p_cod_empresa
			AND cod_item = p_baixa.cod_item
			
			UPDATE estoque_lote
			SET qtd_saldo = qtd_saldo - p_movito
			WHERE cod_empresa = p_cod_empresa 
			AND num_transac 	= p_estoque.num_transac
			
			UPDATE estoque_lote_ender
			SET qtd_saldo = qtd_saldo - p_movito
			WHERE cod_empresa = p_cod_empresa 
			AND num_transac 	= p_estoque.num_transac_ender
			
			LET p_estoque_trans.cod_empresa  = p_cod_empresa #NOT NULL ,
			LET p_estoque_trans.num_transac  = 0 #NOT NULL ,
			LET p_estoque_trans.cod_item  = p_baixa.cod_item #NOT NULL ,
			LET p_estoque_trans.dat_movto =p_data #NOT NULL ,
			LET p_estoque_trans.dat_ref_moeda_fort =p_data 
			LET p_estoque_trans.cod_operacao  = p_cod_movto #NOT NULL ,
			LET p_estoque_trans.num_docum =p_num_nff USING "&&&&&&","-",p_param.ser_nff USING '&&'
			LET p_estoque_trans.num_seq = p_baixa.num_sequencia
			LET p_estoque_trans.ies_tip_movto  = "N" #NOT NULL ,
#---------Alterado pelo Manuel em 12/12/2011, estava movimentando o estoque errado quando faltava itens no local assistec
###			LET p_estoque_trans.qtd_movto  = p_baixa.qtd_item - p_movito_pen #NOT NULL ,
            LET p_estoque_trans.qtd_movto  = p_movito #NOT NULL ,
			LET p_estoque_trans.cus_unit_movto_p  = 0 #NOT NULL ,
			LET p_estoque_trans.cus_tot_movto_p  = 0 #NOT NULL ,
			LET p_estoque_trans.cus_unit_movto_f  = 0 #NOT NULL ,
			LET p_estoque_trans.cus_tot_movto_f  = 0 #NOT NULL ,
			LET p_estoque_trans.num_conta = p_num_conta
			LET p_estoque_trans.num_secao_requis = ""
			LET p_estoque_trans.cod_local_est_orig = p_estoque.cod_local
			LET p_estoque_trans.cod_local_est_dest = ""
			LET p_estoque_trans.num_lote_orig = p_estoque.num_lote
			LET p_estoque_trans.num_lote_dest =""
			LET p_estoque_trans.ies_sit_est_orig ="L"
			LET p_estoque_trans.ies_sit_est_dest =""
			LET p_estoque_trans.cod_turno =NULL 
			LET p_estoque_trans.nom_usuario =p_user 
			LET p_estoque_trans.dat_proces = TODAY 
			LET p_estoque_trans.hor_operac = TIME 
			LET p_estoque_trans.num_prog ="POL0989"
			
			INSERT INTO estoque_trans  VALUES (p_estoque_trans.*)
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("estoque_trans","insert")	
				RETURN FALSE 		
			END IF 
			LET p_num_transac = SQLCA.SQLERRD[2]
			
			LET p_estoque_trans_end.cod_empresa = p_cod_empresa
			LET p_estoque_trans_end.num_transac	= p_num_transac
			LET p_estoque_trans_end.endereco	=	p_estoque.endereco
			LET p_estoque_trans_end.num_volume	= p_estoque.num_volume
			LET p_estoque_trans_end.qtd_movto	= 	p_estoque_trans.qtd_movto
			LET p_estoque_trans_end.cod_grade_1= p_estoque.cod_grade_1
			LET p_estoque_trans_end.cod_grade_2= p_estoque.cod_grade_2
			LET p_estoque_trans_end.cod_grade_3= p_estoque.cod_grade_3
			LET p_estoque_trans_end.cod_grade_4= p_estoque.cod_grade_4
			LET p_estoque_trans_end.cod_grade_5= p_estoque.cod_grade_5
			LET p_estoque_trans_end.dat_hor_prod_ini='1900-01-01 00:00:00'
			LET p_estoque_trans_end.dat_hor_prod_fim='1900-01-01 00:00:00'
			LET p_estoque_trans_end.vlr_temperatura= 0
			LET p_estoque_trans_end.endereco_origem= p_estoque.endereco
			LET p_estoque_trans_end.num_ped_ven= 0
			LET p_estoque_trans_end.num_seq_ped_ven= 0
			LET p_estoque_trans_end.dat_hor_producao='1900-01-01 00:00:00'
			LET p_estoque_trans_end.dat_hor_validade='1900-01-01 00:00:00'
			LET p_estoque_trans_end.num_peca=p_estoque.num_peca
			LET p_estoque_trans_end.num_serie=p_estoque.num_serie
			LET p_estoque_trans_end.comprimento= p_estoque.comprimento
			LET p_estoque_trans_end.largura= p_estoque.largura
			LET p_estoque_trans_end.altura= p_estoque.altura
			LET p_estoque_trans_end.diametro= p_estoque.diametro
			LET p_estoque_trans_end.dat_hor_reserv_1=p_estoque.dat_hor_reserv_1
			LET p_estoque_trans_end.dat_hor_reserv_2=p_estoque.dat_hor_reserv_2
			LET p_estoque_trans_end.dat_hor_reserv_3=p_estoque.dat_hor_reserv_3
			LET p_estoque_trans_end.qtd_reserv_1= p_estoque.qtd_reserv_1
			LET p_estoque_trans_end.qtd_reserv_2= p_estoque.qtd_reserv_2
			LET p_estoque_trans_end.qtd_reserv_3= p_estoque.qtd_reserv_3
			LET p_estoque_trans_end.num_reserv_1= p_estoque.num_reserv_1
			LET p_estoque_trans_end.num_reserv_2= p_estoque.num_reserv_2
			LET p_estoque_trans_end.num_reserv_3= p_estoque.num_reserv_3
			LET p_estoque_trans_end.tex_reservado=" "
			LET p_estoque_trans_end.cus_unit_movto_p= 0
			LET p_estoque_trans_end.cus_unit_movto_f= 0
			LET p_estoque_trans_end.cus_tot_movto_p= 0
			LET p_estoque_trans_end.cus_tot_movto_f= 0
			LET p_estoque_trans_end.cod_item= p_estoque_trans.cod_item
			LET p_estoque_trans_end.dat_movto= TODAY
			LET p_estoque_trans_end.cod_operacao= p_cod_movto
			LET p_estoque_trans_end.ies_tip_movto= p_estoque_trans.ies_tip_movto
			LET p_estoque_trans_end.num_prog= p_estoque_trans.num_prog 
			
			INSERT INTO estoque_trans_end  VALUES (p_estoque_trans_end.*) 
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("estoque_trans_end","insert")	
				RETURN FALSE 		
			END IF
			
			LET p_estoque_auditoria.cod_empresa = p_cod_empresa #NOT NULL ,
			LET p_estoque_auditoria.num_transac =p_num_transac #NOT NULL ,
			LET p_estoque_auditoria.nom_usuario =p_user #NOT NULL ,
			LET p_estoque_auditoria.dat_hor_proces = CURRENT  #NOT NULL ,
			LET p_estoque_auditoria.num_programa  = "POL0989"#NOT NULL ,
			
			INSERT INTO estoque_auditoria VALUES (p_estoque_auditoria.*) 
			IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("estoque_auditoria","insert")	
				RETURN FALSE 		
			END IF
		   
			INITIALIZE 	p_estoque_loc_reser, p_est_loc_reser_end  TO NULL
				
    		LET p_estoque_loc_reser.cod_empresa 		= p_cod_empresa
			LET p_estoque_loc_reser.num_reserva  		= 0
   		 LET p_estoque_loc_reser.cod_item  			= p_estoque_trans.cod_item
   		 LET p_estoque_loc_reser.cod_local  			= p_estoque_trans.cod_local_est_orig
   		 LET p_estoque_loc_reser.qtd_reservada  		= 0
  		 LET p_estoque_loc_reser.num_lote  			= p_estoque_trans.num_lote_orig
    	 LET p_estoque_loc_reser.ies_origem  		= 'V'
    	 LET p_estoque_loc_reser.ies_situacao  		= 'L'
  		 LET p_estoque_loc_reser.dat_solicitacao  	= TODAY
		 LET p_estoque_loc_reser.qtd_atendida  		= p_estoque_trans.qtd_movto
		LET p_estoque_loc_reser.dat_ult_atualiz  	= TODAY
		
    
		INSERT INTO estoque_loc_reser VALUES (p_estoque_loc_reser.*)
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("ESTOQUE_LOC_RESER","insert")	
			RETURN FALSE 		
		END IF
	
		LET p_est_loc_reser_end.num_reserva = SQLCA.SQLERRD[2]
	
	
		LET p_est_loc_reser_end.cod_empresa 		= p_cod_empresa
		LET p_est_loc_reser_end.endereco 			= p_estoque_trans_end.endereco
		LET p_est_loc_reser_end.num_volume 			= p_estoque_trans_end.num_volume
		LET p_est_loc_reser_end.cod_grade_1 		= p_estoque_trans_end.cod_grade_1
		LET p_est_loc_reser_end.cod_grade_2  		= p_estoque_trans_end.cod_grade_2
		LET p_est_loc_reser_end.cod_grade_3  		= p_estoque_trans_end.cod_grade_3
		LET p_est_loc_reser_end.cod_grade_4  		= p_estoque_trans_end.cod_grade_4
		LET p_est_loc_reser_end.cod_grade_5  		= p_estoque_trans_end.cod_grade_5
		LET p_est_loc_reser_end.dat_hor_producao	= p_estoque_trans_end.dat_hor_prod_ini
		LET p_est_loc_reser_end.num_ped_ven  		= 0
		LET p_est_loc_reser_end.num_seq_ped_ven 	= 0
		LET p_est_loc_reser_end.dat_hor_validade	= p_estoque_trans_end.dat_hor_validade
		LET p_est_loc_reser_end.num_peca  			= p_estoque_trans_end.num_peca
		LET p_est_loc_reser_end.num_serie  			= p_estoque_trans_end.num_serie
		LET p_est_loc_reser_end.comprimento 		= p_estoque_trans_end.comprimento
		LET p_est_loc_reser_end.largura   			= p_estoque_trans_end.largura 
		LET p_est_loc_reser_end.altura  			= p_estoque_trans_end.altura
		LET p_est_loc_reser_end.diametro   			= p_estoque_trans_end.diametro
		LET p_est_loc_reser_end.dat_hor_reserv_1  	= p_estoque_trans_end.dat_hor_reserv_1 
		LET p_est_loc_reser_end.dat_hor_reserv_2  	= p_estoque_trans_end.dat_hor_reserv_2 
		LET p_est_loc_reser_end.dat_hor_reserv_3  	= p_estoque_trans_end.dat_hor_reserv_3 
		LET p_est_loc_reser_end.qtd_reserv_1  		= p_estoque_trans_end.qtd_reserv_1 
		LET p_est_loc_reser_end.qtd_reserv_2  		= p_estoque_trans_end.qtd_reserv_2
		LET p_est_loc_reser_end.qtd_reserv_3  		= p_estoque_trans_end.qtd_reserv_3
		LET p_est_loc_reser_end.num_reserv_1  		= p_estoque_trans_end.num_reserv_1  
		LET p_est_loc_reser_end.num_reserv_2  		= p_estoque_trans_end.num_reserv_2 
		LET p_est_loc_reser_end.num_reserv_3  		= p_estoque_trans_end.num_reserv_3  
		LET p_est_loc_reser_end.tex_reservado  		= ' ' 
		LET p_est_loc_reser_end.identif_estoque  	= p_estoque.identif_estoque  
		LET p_est_loc_reser_end.deposit  			= p_estoque.deposit

		INSERT INTO est_loc_reser_end VALUES (p_est_loc_reser_end.*)
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("EST_LOC_RESER_END","insert")	
			RETURN FALSE 		
		END IF

		INSERT INTO SUP_RESV_EST_TRANS (EMPRESA, NUM_TRANS_RESV_EST, NUM_TRANS_MOV_EST)
		VALUES(p_cod_empresa, p_est_loc_reser_end.num_reserva, p_estoque_trans_end.num_transac)
	
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("SUP_RESV_EST_TRANS","insert")	
			RETURN FALSE 		
		END IF
	
	
{	INSERT INTO SUP_RESV_LOTE_EST (EMPRESA, NUM_TRANS_RESV_EST, NUM_TRANS_LOTE_EST, QTD_RESERVADA, QTD_ATENDIDA) 
	VALUES(	p_cod_empresa, 
			p_est_loc_reser_end.num_reserva, 
			p_estoque.num_transac_ender, 
			p_estoque_trans.qtd_movto, 
			p_estoque_trans.qtd_movto)
	
	IF SQLCA.SQLCODE <> 0 THEN 
	   CALL log003_err_sql("SUP_RESV_LOTE_EST","insert")	
	   RETURN FALSE 		
	END IF  }
	
			INSERT INTO FAT_RESV_ITEM_NF (EMPRESA, TRANS_NOTA_FISCAL, SEQ_ITEM_NF, RESERVA_ESTOQUE, QTD_RESERVADA, TRANS_ESTOQUE, SEQ_TABULACAO) 
			VALUES(	p_cod_empresa,
					p_trans_nf, 
					p_baixa.num_sequencia, 
					p_est_loc_reser_end.num_reserva, 
					0, 
					p_estoque.num_transac_ender, 1) 

			IF SQLCA.SQLCODE <> 0 THEN 
			   CALL log003_err_sql("FAT_RESV_ITEM_NF","insert")	
	 		  RETURN FALSE 		
			END IF

		INITIALIZE 	p_nf_item_transac  TO NULL
		
		LET p_nf_item_transac.empresa 						= p_cod_empresa
	    LET p_nf_item_transac.trans_nota_fiscal				= p_trans_nf
	    LET p_nf_item_transac.trans_estoque					= p_num_transac
		LET p_nf_item_transac.seq_item_nf					= p_baixa.num_sequencia  
		LET p_nf_item_transac.seq_tabulacao      			= 1
		LET p_nf_item_transac.empresa_estoque      			= p_cod_empresa
		LET p_nf_item_transac.qtd_item        				= p_estoque_trans.qtd_movto
		LET p_nf_item_transac.reserva_estoque  				= p_est_loc_reser_end.num_reserva
	    
	    INSERT INTO fat_ctr_est_nf VALUES (p_nf_item_transac.*)
	    IF SQLCA.SQLCODE <> 0 THEN 
				CALL log003_err_sql("FAT_CTR_EST_NF","insert")	
				RETURN FALSE 		
		END IF

			
			SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso 
			INTO p_est_trans_area_lin.cod_area_negocio,
					 p_est_trans_area_lin.cod_lin_negocio,
					 p_est_trans_area_lin.cod_seg_merc,
					 p_est_trans_area_lin.cod_cla_uso
			FROM item 
			WHERE cod_empresa = p_cod_empresa
			AND cod_item = p_baixa.cod_item
			
			LET p_est_trans_area_lin.cod_empresa = p_cod_empresa
			LET p_est_trans_area_lin.num_transac = p_trans_nf

			IF p_seq_ant <> p_baixa.num_sequencia THEN
			   INSERT INTO fat_aen_item_nf 	
			     VALUES (p_cod_empresa,
			          p_trans_nf,
			          p_baixa.num_sequencia,
			          p_est_trans_area_lin.cod_area_negocio,
					      p_est_trans_area_lin.cod_lin_negocio,
					      p_est_trans_area_lin.cod_seg_merc,
					      p_est_trans_area_lin.cod_cla_uso)
			
			   IF SQLCA.SQLCODE <> 0 THEN 
			     	CALL log003_err_sql("Inserindo","fat_aen_item_nf")	
					RETURN FALSE 		
				END IF
			END IF	
			
			LET p_seq_ant = p_baixa.num_sequencia
			IF p_estoque_trans.cod_local_est_orig = p_param.cod_local1 THEN 
				INSERT INTO t_ctrl_trans VALUES 
				(p_cod_empresa,p_num_nff,p_param.ser_nff,p_baixa.cod_item,p_baixa.num_sequencia,p_num_transac)
			END IF
		
	  END FOREACH
		
		LET p_movito_trans = p_baixa.qtd_item - p_movito_pen
		IF p_movito_trans = p_baixa.qtd_item THEN
			LET p_tip_reg = "T"
		ELSE
			LET p_tip_reg = "P"
		END IF 
		 
		INSERT INTO rel_item_nf_912	 
			VALUES (p_cod_empresa,p_num_nff,p_param.ser_nff,p_baixa.cod_item,p_baixa.num_sequencia,
			p_baixa.qtd_item,p_movito_pen, p_data,p_movito_trans,p_tip_reg )
		
		IF SQLCA.SQLCODE <> 0 THEN 
			CALL log003_err_sql("rel_item_nf_912","insert")	
			RETURN FALSE 		
		END IF
		
			DELETE FROM estoque_lote_ender
			WHERE cod_item = p_baixa.cod_item
			AND QTD_SALDO =0
			
			DELETE FROM estoque_lote
			WHERE cod_item = p_baixa.cod_item	
			AND QTD_SALDO =0
	END FOREACH
	
	INSERT INTO rel_item_nf_912                                                                                   
	SELECT a.cod_empresa,a.num_nff,a.ser_nff,                                                                     	
	       a.cod_item,a.num_sequencia,b.qtd_movto,0,                                                                     	
	       b.dat_movto,b.qtd_movto,'E'                                                                                   	
	  FROM t_ctrl_trans a, estoque_trans b                                                                          	
	 WHERE a.cod_empresa = p_cod_empresa                                                                          	
	   AND a.num_nff = p_num_nff                                                                                     	
	   AND a.ser_nff =p_param.ser_nff                                                                                	
	   AND b.cod_empresa = a.cod_empresa                                                                             	
	   AND b.num_transac = a.num_transac                                                                             	
	                                                                                                              
	INSERT INTO rel_item_nf_912				#Insere os item que estão inativos.#        	
	SELECT a.empresa, c.nota_fiscal, c.serie_nota_fiscal, a.item,                                               	
	       a.seq_item_nf, a.qtd_item, a.qtd_item, date(dat_hor_emissao),0,'I'                                               	
	  FROM fat_nf_item a, item b, fat_nf_mestre c                                                                              	
	 WHERE a.empresa     = p_cod_empresa                                                                          	
	   AND a.empresa     = b.cod_empresa                                                                              	
	   AND a.item        = b.cod_item
	   AND a.empresa     = c.empresa                                                                              	
     AND a.trans_nota_fiscal = c.trans_nota_fiscal
	   AND c.nota_fiscal       = p_num_nff                                                                                      	
	   AND c.serie_nota_fiscal = p_param.ser_nff                                                                        	
	   AND b.ies_situacao      = "I"   
	
	                                                                                   	
	RETURN TRUE 
	
END FUNCTION

#----------------------------------#
FUNCTION pol0989_insere_integr()   #
#----------------------------------#

  DEFINE p_nf_integr RECORD 
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
	 
  INITIALIZE 	 p_nf_integr  TO NULL
  
  LET  p_nf_integr.empresa           	= p_cod_empresa
  LET  p_nf_integr.trans_nota_fiscal 	= p_trans_nf
  LET  p_nf_integr.sit_nota_fiscal   	= 'N'
  LET  p_nf_integr.status_intg_est   	= 'I' 	 
  LET  p_nf_integr.dat_hr_intg_est		= p_fat_mestre.dat_hor_emissao   	 
  LET  p_nf_integr.status_intg_contab	= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_contab	= 	 
  LET  p_nf_integr.status_intg_creceb	= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_creceb	=  
  LET  p_nf_integr.status_integr_obf	= 'P'	 
#  LET  p_nf_integr.dat_hor_integr_obf	= 	 
  LET  p_nf_integr.status_intg_migr		= 'P'	 
#  LET  p_nf_integr.dat_hr_intg_migr	= 	 
	
	INSERT INTO fat_nf_integr
	 VALUES(p_nf_integr.*)	        
	 
	IF SQLCA.SQLCODE <> 0 THEN 
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO DADOS DA TABELA FAT_NF_INTEGR'
      CALL pol0989_imprime_erros(p_msg)
      LET p_erro = TRUE 
      RETURN FALSE
	END IF 
	
	RETURN TRUE

END FUNCTION
#----------------------------#
FUNCTION pol0989_exibe_tela()#
#----------------------------#

  DEFINE 	l_val_icm, l_val_nff		DECIMAL(17,2),
				  l_num_nff				INTEGER
	

	SELECT val_trib_merc, 
	       bc_tributo_tot
	  INTO l_val_icm, 
	       l_val_nff
	  FROM fat_mestre_fiscal
	 WHERE empresa           = p_cod_empresa
	   AND trans_nota_fiscal = p_trans_nf
	   AND tributo_benef     = 'ICMS'
	
	DISPLAY l_val_icm TO val_tot_icm
	DISPLAY l_val_nff TO val_tot_base
	DISPLAY p_num_nff TO num_nff

END FUNCTION


#-------------------------------------#
FUNCTION pol0989_imprime_erros(p_erro)#			#prepara para imprimir erro
#-------------------------------------#
   
   DEFINE p_erro			CHAR(250)
	
	
	IF NOT  p_print THEN 			
		CALL log150_procura_caminho('LST') RETURNING p_caminho
		LET p_caminho = p_caminho CLIPPED, 'pol0989.lst'
		LET p_nom_arquivo = p_caminho
		START REPORT pol0989_imprime TO p_nom_arquivo
		LET p_print = TRUE 
	END IF 
	
	OUTPUT TO REPORT pol0989_imprime(p_erro)
	
END FUNCTION 

#-----------------------------#
REPORT pol0989_imprime(p_erro)#			#vai imprimir os erros apresentados no programa
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

         PRINT COLUMN 001, "pol0989  CARGA DE NOTAS FISCAIS",
               COLUMN 085, "DATA: ", TODAY USING "dd/mm/yyyy ", TIME
         
         PRINT COLUMN 001, "*-------------------------------------------------------------------------------------------------------------*"
       
         PRINT
         
         PRINT COLUMN 001, "            DESCRIÇÃO DO ERRO"
         PRINT COLUMN 001, "*-------------------------------------------------------------------------------------------------------------*"

      ON EVERY ROW
      	 PRINT COLUMN 001,p_erro CLIPPED
END REPORT

#---------------------------------#
 FUNCTION pol0989_gera_relatorio()#
#---------------------------------#
	
	DEFINE p_return SMALLINT

	CALL log006_exibe_teclas("01", p_versao)
	CALL log130_procura_caminho("pol09891") RETURNING comando
	OPEN WINDOW w_pol09891 AT 5,3 WITH FORM comando
	ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)	
	CLEAR FORM
  DISPLAY p_cod_empresa TO cod_empresa	
	
	SELECT den_empresa INTO p_den_empresa
	FROM empresa
	WHERE cod_empresa = p_cod_empresa
	
	CONSTRUCT BY NAME where_clause 	ON	rel_item_nf_912.num_nff,
										rel_item_nf_912.ser_nff,
										rel_item_nf_912.dat_emis
	
																	
    IF log0280_saida_relat(13,29) IS NOT NULL THEN
		MESSAGE " Processando a Extracao do Relatorio..." 	ATTRIBUTE(REVERSE)
		IF p_ies_impressao = "S" THEN
			IF g_ies_ambiente = "U" THEN
				START REPORT pol0989_relat TO PIPE p_nom_arquivo
			ELSE
				CALL log150_procura_caminho ('LST') RETURNING p_caminho
				LET p_caminho = p_caminho CLIPPED, 'pol0989.tmp'
				START REPORT pol0989_relat  TO p_caminho
			END IF
		ELSE
			CALL log150_procura_caminho('LST') RETURNING p_caminho
			LET p_caminho = p_caminho CLIPPED, 'pol0989.lst'
			LET p_nom_arquivo = p_caminho

			START REPORT pol0989_relat TO p_nom_arquivo
		END IF
		IF NOT  pol0989_emite_relatorio()  THEN
			FINISH REPORT pol0989_relat
			LET p_return = FALSE
		ELSE 
			FINISH REPORT pol0989_relat
			LET p_return = TRUE 
		END IF
	END IF 
	
	CLOSE WINDOW w_pol09891 
	CURRENT WINDOW IS w_pol0989				

	IF p_return THEN 
		IF p_ies_impressao = "S" THEN
			MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo 	ATTRIBUTE(REVERSE)
			IF g_ies_ambiente = "W" THEN
				LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
				RUN comando
			END IF
		ELSE
			ERROR "Relatorio Gravado no Arquivo ",p_nom_arquivo," " 
		END IF  
	END IF 
	
	RETURN p_return
		
END FUNCTION

#----------------------------------#
 FUNCTION pol0989_emite_relatorio()#
#----------------------------------#

  DEFINE 	p_rel_item_nf_912 RECORD 
				cod_empresa 		CHAR(02),
				num_nff 				DECIMAL(6,0),
				ser_nff					CHAR(2),
				cod_item 				CHAR(15),
				num_sequencia 	DECIMAL(5,0),
				qtd_item 				DECIMAL(12,3),
				qtd_item_pen 		DECIMAL(12,3),
				dat_emis 				DATE,
				qtd_item_trans	DECIMAL(12,3),
				tip_reg					CHAR(1),
				den_item 				CHAR(25)
 END RECORD 

 DEFINE p_count					SMALLINT,
			  sql_stmt1				CHAR(800)
			 

	LET  p_count = 0

	LET sql_stmt1 =    " SELECT rel_item_nf_912.* , ",
										 " ' ' ",
										 " FROM rel_item_nf_912  ",
										 " WHERE ",where_clause CLIPPED,
										 " and cod_empresa = '",p_cod_empresa,"' ",
										 " and tip_reg<>'T' ",
										 " ORDER BY num_nff,tip_reg,num_sequencia"
										
	PREPARE var_quer1 FROM sql_stmt1   
	DECLARE cq_relatorio CURSOR FOR var_quer1
		FOREACH cq_relatorio INTO p_rel_item_nf_912.*
		
		SELECT den_item[1,25]
		INTO p_rel_item_nf_912.den_item
		FROM item 
		WHERE cod_empresa = p_cod_empresa
		AND cod_item = p_rel_item_nf_912.cod_item
		
		
		OUTPUT TO REPORT pol0989_relat(p_rel_item_nf_912.*)
		LET p_count = p_count + 1
	END FOREACH 
	
	IF p_count > 0 THEN 
		RETURN TRUE 
	ELSE
		RETURN FALSE
	END IF 
		
END FUNCTION 

#---------------------------#
 REPORT pol0989_relat(p_rel)#
#---------------------------#

	DEFINE 	p_rel RECORD 
					cod_empresa 		CHAR(02),
					num_nff 				DECIMAL(6,0),
					ser_nff					CHAR(2),
					cod_item 				CHAR(9),
					num_sequencia 	DECIMAL(5,0),
					qtd_item 				DECIMAL(12,3),
					qtd_item_pen 		DECIMAL(12,3),
					dat_emis 				DATE,
					qtd_item_trans	DECIMAL(12,3),
					tip_reg					CHAR(1),
					den_item 				CHAR(25)
	END RECORD
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  								#----------CABEÇALHO DO RELATORIO-------------

         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "POL00903              RELATORIO DE ITENS PENDENTES "
         PRINT 	COLUMN 001, "--------------------------------------------------------------------------------"

      BEFORE GROUP OF p_rel.tip_reg			  	#------------GRUPO----------
				PRINT 	COLUMN 001,"NOTA FISCAL: ", p_rel.num_nff USING "######", " SERIE ",p_rel.ser_nff CLIPPED
						CASE 
							WHEN p_rel.tip_reg ="I"
								PRINT COLUMN 001,"ITENS PENDENTES - ITENS INATIVOS "	
							WHEN p_rel.tip_reg ="P"	
								PRINT COLUMN 001,"ITENS PENDENTES - FALTOU ESTOQUE "	
							WHEN p_rel.tip_reg ="E"	
								PRINT COLUMN 001,"ITENS PENDENTES - EMPRESTADO DO SEGUNDO LOCAL DE ESTOQUE "
						END CASE 
        PRINT 	COLUMN 001, "CODIGO",
          			COLUMN 011, "DESCRICAO",
          			COLUMN 037,"QTD.ITEM" ,
          			COLUMN 048,"QTD.TRANS.",
          			COLUMN 059,"QTD.PEND.",
          			COLUMN 070,"DATA" 
          			
         PRINT 	COLUMN 001, "---------",
          			COLUMN 011, "------------------------",
          			COLUMN 037,"----------" ,
          			COLUMN 048,"----------",
          			COLUMN 059,"----------" ,
          			COLUMN 070,"----------"
      AFTER GROUP OF p_rel.num_nff
      	PRINT 
      	PRINT 	COLUMN 001, "--------------------------------------------------------------------------------"
      ON EVERY ROW			#---ITENS DO  GRUPO---
            PRINT COLUMN 001, p_rel.cod_item[1,9] CLIPPED,
	          			COLUMN 011, p_rel.den_item CLIPPED,
	          			COLUMN 037, p_rel.qtd_item USING "##,##&.&&&",
	          			COLUMN 048, p_rel.qtd_item_trans USING "##,##&.&&&",
	          			COLUMN 059, p_rel.qtd_item_pen USING "##,##&.&&&",
	          			COLUMN 070, p_rel.dat_emis
	          			
	    ON LAST ROW
	    		PRINT
					PRINT COLUMN 025, "ULTIMA FOLHA."
         
END REPORT

#--------------------------------#
FUNCTION pol0989_deleta_arquivo()#
#--------------------------------#
   
   DEFINE p_data_char		CHAR(10),
			    l_caminho			CHAR(500),			#--->vai receber o comando para deletar em linux
			    w_caminho			CHAR(500),			#--->vai receber o comando para deletar em windows
			    w_bol,l_bol		SMALLINT				#--->vai receber o retorno do comando
			 
	LET p_data_char = p_data
	CALL log150_procura_caminho("UNL") RETURNING p_caminho
	LET l_caminho = "rm ",  p_caminho CLIPPED,"PZ",p_data_char[1,2], p_data_char[4,5], p_data_char[9,10],".002"
	LET w_caminho = "del ", p_caminho CLIPPED,"PZ",p_data_char[1,2], p_data_char[4,5], p_data_char[9,10],".002"
			
	RUN l_caminho	 RETURNING l_bol
	RUN w_caminho	 RETURNING w_bol
	
	IF l_bol = TRUE  OR w_bol = TRUE  THEN 
		RETURN TRUE 
	ELSE
		RETURN FALSE 
	END IF 
	
END FUNCTION

#ivo 24/09/2013 daqui...
#---------------------------#
FUNCTION pol0989_grava_fci()#
#---------------------------#
   
  SELECT trans_controle_fci,
         num_controle_fci 
    INTO p_trans_controle_fci,
         p_num_controle_fci
    FROM vdp_controle_fci 
   WHERE empresa = p_cod_empresa
     AND item = p_cod_item
     AND versao_atual='S' 
     AND tip_operacao='I'

   IF STATUS = 0 THEN
      INSERT INTO fat_item_fci (
        empresa, 
        trans_nota_fiscal, 
        seq_item_nf, 
        trans_controle_fci, 
        origem_fci, 
        qtd_item_fci) 
      VALUES(p_cod_empresa,
             p_trans_nf,         
             p_arquivo.sequencia,
             p_trans_controle_fci,
             'V',
             p_arquivo.qtd_item)
      IF STATUS <> 0 THEN 
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO TABELA FAT_ITEM_FCI'
         CALL pol0989_imprime_erros(p_msg)
    	   #LET p_erro = TRUE 
         RETURN FALSE
      END IF
      LET p_seq_item_nf = p_arquivo.sequencia
      CALL pol0989_txt_fci() RETURNING p_status   
   END IF
   
   RETURN TRUE

END FUNCTION
  
#-------------------------#   
FUNCTION pol0989_txt_fci()#   
#-------------------------#

   IF p_item_fisc.hist_fiscal IS NULL OR
      p_item_fisc.hist_fiscal = ' ' THEN
      RETURN TRUE
   END IF

   SELECT   
     fiscal_hist.cod_hist,  
     fiscal_hist.tex_hist_1,  
     fiscal_hist.tex_hist_2,  
     fiscal_hist.tex_hist_3,  
     fiscal_hist.tex_hist_4  
    INTO p_cod_hist,  
      p_tex_hist_1,
      p_tex_hist_2,
      p_tex_hist_3,
      p_tex_hist_4
    FROM fiscal_hist  
   WHERE fiscal_hist.cod_hist = p_item_fisc.hist_fiscal  

   IF STATUS <> 0 THEN 
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO ', p_cod_status, 'LENDO TEXTO FISCAL'
      CALL pol0989_imprime_erros(p_msg)
 	   #LET p_erro = TRUE 
      RETURN FALSE
   END IF

   IF p_cod_hist IS NULL OR p_cod_hist = 0 THEN
      RETURN TRUE
   END IF      

   IF p_tex_hist_1 IS NULL OR p_tex_hist_1 = ' ' THEN
    ELSE
      CALL pol0989_ins_texto_fci(p_tex_hist_1) RETURN p_status
   END IF

   IF p_tex_hist_2 IS NULL OR p_tex_hist_2 = ' ' THEN
   ELSE
      CALL pol0989_ins_texto_fci(p_tex_hist_2) RETURN p_status
   END IF
         
   IF p_tex_hist_3 IS NULL OR p_tex_hist_3 = ' ' THEN
   ELSE
      CALL pol0989_ins_texto_fci(p_tex_hist_3) RETURN p_status
   END IF

   IF p_tex_hist_4 IS NULL OR p_tex_hist_4 = ' ' THEN
   ELSE
      CALL pol0989_ins_texto_fci(p_tex_hist_4) RETURN p_status
   END IF
          
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0989_ins_texto_fci(p_texto)#
#--------------------------------------#
   
   DEFINE p_texto LIKE fiscal_hist.tex_hist_1,
          m_texto LIKE fiscal_hist.tex_hist_1,
          m_ind   INTEGER,
          m_carac CHAR(01)
   
   LET m_texto = p_texto CLIPPED
   LET p_texto = ''
   
   FOR m_ind = TO LENGTH(m_texto)
       m_carac = m_texto[m_ind,1]
       IF m_carac = '<' THEN
          EXIT FOR
       END IF
       LET p_texto = p_texto, m_carac
   END FOR
   
   LET p_descricao_texto = p_texto CLIPPED, ' ', p_num_controle_fci
   
   SELECT MAX(sequencia_texto)                                                                                         
     INTO p_seq_texto                                                                                               
     FROM fat_nota_fiscal_texto_item                                                                                
    WHERE empresa = p_cod_empresa                                                                                   
      AND trans_nota_fiscal = p_trans_nf                                                                            
      AND sequencia_item_nota_fiscal = p_seq_item_nf                                                                
                                                                                                                    
   IF p_seq_texto IS NULL THEN                                                                                      
      LET p_seq_texto = 0                                                                                           
   END IF                                                                                                           
                                                                                                                    
   LET p_seq_texto = p_seq_texto + 1                                                                                
                                                                                                                    
   INSERT INTO fat_nota_fiscal_texto_item (                                                                         
      empresa,                                                                                                      
      trans_nota_fiscal,                                                                                            
      sequencia_item_nota_fiscal,                                                                                   
      sequencia_texto,                                                                                              
      texto,                                                                                                        
      descricao_texto)                                                                                              
   VALUES(p_cod_empresa,                                                                                            
          p_trans_nf,                                                                                               
          p_seq_item_nf,                                                                                            
          p_seq_texto,                                                                                              
          p_cod_hist,                                                                                               
          p_descricao_texto)                                                                                        
                                                                                                                    
   IF STATUS <> 0 THEN                                                                                              
      LET p_cod_status = STATUS                                                                                     
      LET p_msg = 'ERRO ', p_cod_status, 'INSERINDO TABELA FAT_NOTA_FISCAL_TEXTO_ITEM'                              
      CALL pol0989_imprime_erros(p_msg)                                                                             
      #LET p_erro = TRUE                                                                                            
      RETURN FALSE                                                                                                  
   END IF                                                                                                           

END FUNCTION


# até aqui - ivo 24/09/2013



#--------------FIM DO PROGRAMA---------------#
