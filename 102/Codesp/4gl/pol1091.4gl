#-------------------------------------------------------------------#
# OBJETIVO: GERAR DESCONTO DE PIS E COFINS                          #
# DATA....: 17/03/2011                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_nat_oper       LIKE nat_operacao.cod_nat_oper,
          p_dat_movto          DATE,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_num_bobina         CHAR(20),
          p_ies_apon           SMALLINT,
          p_num_transac        INTEGER,
          p_dat_transfer       DATE,
          p_num_transac_de     INTEGER,
          p_num_transac_para   INTEGER,
          p_qtd_bob_transf    INTEGER,
          p_qtd_txt           CHAR(10)
                   
   DEFINE p_fat_nf_item_fisc  RECORD LIKE fat_nf_item_fisc.*,
          p_fat_mestre_fiscal RECORD LIKE fat_mestre_fiscal.*
   
   DEFINE p_num_docum				  DECIMAL(6,0),
			    p_especie					  CHAR(03),
			    p_cod_cliente 		  CHAR(14),
          p_sequencia					DECIMAL(5,0),
          p_cod_item 					CHAR(15) ,   
          p_pct_cofins				DECIMAL(5,2), 
          p_val_base_cofins		DECIMAL(15,2),
          p_val_cofins				DECIMAL(15,2),
          p_pct_pis						DECIMAL(5,2),	
          p_val_base_pis			DECIMAL(15,2),
          p_val_pis						DECIMAL(5,2),
          p_status_registro   CHAR(01),
          p_insere_tributo    SMALLINT, 
          p_trans_config      INTEGER,
          p_incide            CHAR(01),         
          p_cod_fiscal        INTEGER,
          p_num_nff           INTEGER,
          p_val_liq_item      DECIMAL(17,2),
          p_den_tributo       CHAR(10),
          p_ins_cofins        SMALLINT,
          p_ins_pis           SMALLINT,
          p_tem_itens         SMALLINT,
          p_docum_criticado   INTEGER,
          p_cod_parametro     CHAR(15),
          p_docum_processado  INTEGER
          
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1091-05.10.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1091_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1091_menu()
#----------------------#
          
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1091") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1091 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
			   CALL pol1091_informar() RETURNING p_status
			   IF p_status THEN
			      LET p_ies_cons = TRUE
				    NEXT OPTION "Processar"
         ELSE
            LET p_ies_cons = FALSE
			   END IF
      COMMAND "Processar" "Processa a geração de PIS/COFINS"
         IF p_ies_cons THEN
            CALL pol1091_processar() RETURNING p_status                          
            MESSAGE ''                                                           
            DISPLAY p_docum_processado TO doc_processado                         
            DISPLAY p_docum_criticado TO doc_criticado                                            
            IF p_status THEN                                                     
               ERROR 'Processamento efetuado com sucesso !'                      
               NEXT OPTION 'Fim'                                                 
            ELSE                                                                 
               LET p_msg = 'Houve problemas durante o processamento.\n',         
                           'Não foi possivel processar todos os registros.\n'                                             
               CALL log0030_mensagem(p_msg,'excla')                              
            END IF           
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'      
         END IF                                       
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1091

END FUNCTION

#---------------------------#
FUNCTION pol1091_informar()
#---------------------------#

   LET INT_FLAG = FALSE
   LET p_cod_nat_oper = 0
   
   INPUT p_cod_parametro
      WITHOUT DEFAULTS FROM cod_parametro
      
      AFTER FIELD cod_parametro
      
         IF p_cod_parametro IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD cod_parametro
         END IF
         
         SELECT natureza_operacao
           INTO p_cod_nat_oper
           FROM par_solc_fat_codesp
          WHERE cod_empresa = p_cod_empresa
            AND cod_parametro = p_cod_parametro
         
         IF STATUS = 100 THEN
            ERROR 'Parâmetro não cadastrado!'
            NEXT FIELD cod_parametro
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','par_solc_fat_codesp')
               RETURN FALSE
            END IF
         END IF
         
         DISPLAY p_cod_nat_oper TO cod_nat_oper
   
		 ON KEY (control-z)
    		CALL pol1091_popup()
   
   END INPUT
   
   IF INT_FLAG THEN 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol1091_popup()#
#-----------------------#

   DEFINE p_codigo  CHAR(15)
      
	CASE
		WHEN INFIELD(cod_parametro)
			CALL log009_popup(8,10,"CODIGO DO PARAMETRO","par_solc_fat_codesp",
						"cod_parametro","den_parametro","","S","") RETURNING p_codigo
			
			CALL log006_exibe_teclas("01 02 07", p_versao)
			
			CURRENT WINDOW IS w_pol1091

			IF p_codigo IS NOT NULL THEN
				LET p_cod_parametro = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_parametro
			END IF

	END CASE 

END FUNCTION 
      
#---------------------------#
FUNCTION pol1091_processar()
#---------------------------#

   MESSAGE 'Aguarde! ... processando.'
   
   LET p_docum_criticado = 0
   LET p_docum_processado = 0
   
   DECLARE cq_nf CURSOR WITH HOLD FOR
    SELECT cod_empresa,  
           num_docum,		
           especie,			
           cod_cliente,
           texto_fatura
      FROM nf_mestre_792G
     WHERE status_registro <> 'P'

   FOREACH cq_nf INTO 
           p_cod_empresa,  
           p_num_docum,		 
           p_especie,			 
           p_cod_cliente,
           p_msg

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_mestre_792G:cq_nf')
         RETURN FALSE
      END IF

      LET p_status_registro = 'C'
             
      CALL log085_transacao("BEGIN")                              
      
      IF NOT pol1091_gera_tributo() THEN
         CALL log085_transacao("ROLLBACK")                              
         RETURN FALSE
      END IF
      
      LET p_docum_processado = p_docum_processado + 1
      DISPLAY p_docum_processado TO docum_processado
      
      IF p_status_registro = 'C' THEN
         LET p_docum_criticado = p_docum_criticado + 1
         DISPLAY p_docum_criticado TO docum_criticado
      END IF
      
      UPDATE nf_mestre_792G
         SET status_registro = p_status_registro,
             texto_fatura    = p_msg
       WHERE cod_empresa = p_cod_empresa
         AND num_docum   = p_num_docum
         AND especie     = p_especie
         AND cod_cliente = p_cod_cliente
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Update','nf_mestre_792G')
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
         
      CALL log085_transacao("COMMIT")                              
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1091_gera_tributo()
#-----------------------------#

   LET p_ins_pis = FALSE
   LET p_ins_cofins = FALSE
   LET p_tem_itens = FALSE

   DECLARE cq_itens CURSOR FOR
    SELECT sequencia,	
           cod_item, 	
           pct_cofins,			  
           val_base_cofins,	
           val_cofins,			  
           pct_pis,					
           val_base_pis,		  
           val_pis
      FROM nf_item_792G
     WHERE cod_empresa = p_cod_empresa
       AND num_docum   = p_num_docum
       AND especie     = p_especie
       AND cod_cliente = p_cod_cliente

   FOREACH cq_itens INTO 
           p_sequencia,	      
           p_cod_item, 	      
           p_pct_cofins,			
           p_val_base_cofins,	
           p_val_cofins,			
           p_pct_pis,					
           p_val_base_pis,		
           p_val_pis          

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_mestre_792G:cq_nf')
         RETURN FALSE
      END IF
      
      LET p_tem_itens = TRUE
      
      SELECT num_transac,
             num_nff
        INTO p_num_transac,
             p_num_nff
        FROM rel_fat_nfs_codesp
       WHERE cod_empresa = p_cod_empresa
         AND num_docum   = p_num_docum
         AND especie     = p_especie
       
      IF STATUS = 100 THEN
         LET p_msg = 'Documento nao encontrado na tabela rel_fat_nfs_codesp'
         RETURN TRUE
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','nf_mestre_792G:cq_nf')
            RETURN FALSE
         END IF
      END IF
      
      SELECT val_liquido_item
         INTO p_val_liq_item
         FROM fat_nf_item
        WHERE empresa = p_cod_empresa
          AND trans_nota_fiscal = p_num_transac
          AND seq_item_nf = p_sequencia
       
      IF STATUS <> 0 THEN
         LET p_msg = 'NF ', p_num_nff, ' com transacao ', p_num_transac,
                     ' e sequencia ',p_sequencia, ' nao encontrada ',
                     'na tabela fat_nf_item'
         RETURN TRUE
      END IF
              
      IF p_val_pis > 0 OR p_val_base_pis > 0 OR p_pct_pis > 0 THEN
         
         LET p_den_tributo = 'PIS_RET'
         IF NOT pol1091_le_tributo(p_den_tributo) THEN
            RETURN FALSE
         END IF
         
         IF p_insere_tributo THEN
            IF p_val_pis = 0 OR p_val_base_pis = 0 OR p_pct_pis = 0 THEN
               LET p_msg = 'Um ou mais campos referentes a PIS não esta preenchido'
               RETURN TRUE
            END IF
            IF NOT pol1091_insere_tributo() THEN
               RETURN FALSE
            END IF
            LET p_ins_pis = TRUE
         END IF
         
      END IF
      
      IF p_val_cofins > 0 OR p_val_base_cofins > 0 OR p_pct_cofins > 0 THEN
         
         LET p_den_tributo = 'COFINS_RET'
         IF NOT pol1091_le_tributo(p_den_tributo) THEN
            RETURN FALSE
         END IF
         
         IF p_insere_tributo THEN
            IF p_val_cofins = 0 OR p_val_base_cofins = 0 OR p_pct_cofins = 0 THEN
               LET p_msg = 'Um ou mais campos referentes a COFINS não esta preenchido'
               RETURN TRUE
            END IF
            IF NOT pol1091_insere_tributo() THEN
               RETURN FALSE
            END IF
            LET p_ins_cofins = TRUE
         END IF
         
      END IF
      
   END FOREACH

   IF p_ins_pis THEN
      IF NOT pol1091_ins_fat_mestre_trib('PIS_RET') THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ins_cofins THEN
      IF NOT pol1091_ins_fat_mestre_trib('COFINS_RET') THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_tem_itens THEN
      LET p_status_registro = 'P'
   ELSE
      LET p_msg = 'Nenhum item foi encontrado na tabela nf_item_792g'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------------#      
FUNCTION pol1091_le_tributo(p_tributo_benef)
#-------------------------------------------#

   DEFINE p_tributo_benef CHAR(15)
   
   SELECT COUNT(tributo_benef)
     INTO p_count
     FROM fat_nf_item_fisc
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_num_transac
      AND tributo_benef = p_tributo_benef
      AND seq_item_nf = p_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','fat_nf_item_fisc')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_insere_tributo = FALSE
   ELSE
      LET p_insere_tributo = TRUE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1091_insere_tributo()
#--------------------------------#

   INITIALIZE p_fat_nf_item_fisc TO NULL

   IF NOT pol1091_le_config() THEN
      RETURN FALSE
   END IF

   IF p_den_tributo = 'PIS_RET' THEN
      LET p_fat_nf_item_fisc.bc_trib_mercadoria = p_val_base_pis
      LET p_fat_nf_item_fisc.val_trib_merc      = p_val_pis
      LET p_fat_nf_item_fisc.aliquota           = p_pct_pis
   ELSE
      LET p_fat_nf_item_fisc.bc_trib_mercadoria = p_val_base_cofins
      LET p_fat_nf_item_fisc.val_trib_merc      = p_val_cofins
      LET p_fat_nf_item_fisc.aliquota           = p_pct_cofins
   END IF

   LET p_fat_nf_item_fisc.empresa            = p_cod_empresa
   LET p_fat_nf_item_fisc.trans_nota_fiscal  = p_num_transac
   LET p_fat_nf_item_fisc.seq_item_nf        = p_sequencia
   LET p_fat_nf_item_fisc.tributo_benef      = p_den_tributo
   LET p_fat_nf_item_fisc.trans_config       = p_trans_config
   LET p_fat_nf_item_fisc.bc_tributo_frete   = 0
   LET p_fat_nf_item_fisc.bc_trib_calculado  = 0
   LET p_fat_nf_item_fisc.bc_tributo_tot     = p_fat_nf_item_fisc.bc_trib_mercadoria
   LET p_fat_nf_item_fisc.val_tributo_frete  = 0
   LET p_fat_nf_item_fisc.val_trib_calculado = 0
   LET p_fat_nf_item_fisc.val_tributo_tot    = p_fat_nf_item_fisc.val_trib_merc
   LET p_fat_nf_item_fisc.acresc_desc        = 0
   LET p_fat_nf_item_fisc.incide             = p_incide
   LET p_fat_nf_item_fisc.cod_fiscal         = p_cod_fiscal

   INSERT INTO fat_nf_item_fisc
      VALUES(p_fat_nf_item_fisc.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_nf_item_fisc')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------------------#
FUNCTION pol1091_ins_fat_mestre_trib(p_tributo)
#----------------------------------------------#

   DEFINE p_tributo CHAR(10)

   LET p_fat_mestre_fiscal.empresa           = p_cod_empresa
   LET p_fat_mestre_fiscal.trans_nota_fiscal = p_num_transac
   LET p_fat_mestre_fiscal.tributo_benef     = p_tributo

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
      AND trans_nota_fiscal = p_num_transac
      AND tributo_benef = p_tributo
                    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','fat_nf_item_fisc:2')
      RETURN FALSE
   END IF
   
   INSERT INTO fat_mestre_fiscal
    VALUES(p_fat_mestre_fiscal.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_mestre_fiscal')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1091_le_config()
#---------------------------#

   DEFINE p_men CHAR(60)
   
   SELECT trans_config,   
          incide, 
          cod_fiscal                      
     INTO p_trans_config,                                          		   
					p_incide,                                                		     
					p_cod_fiscal                                             		     
		 FROM obf_config_fiscal                                         		   
		WHERE empresa = p_cod_empresa              		   
		  AND tributo_benef = p_den_tributo                            		   
		  AND origem        = 'S'                                      		   
			AND nat_oper_grp_desp = p_cod_nat_oper	   
			AND grp_fiscal_regiao  IS NULL                	   
		  AND estado             IS NULL                         		   
		  AND municipio          IS NULL                      		   
		  AND carteira           IS NULL                       		   
		  AND finalidade         IS NULL                     		   
		  AND familia_item       IS NULL                   		   
		  AND grupo_estoque      IS NULL                  		   
			AND grp_fiscal_classif IS NULL               	   
		  AND classif_fisc       IS NULL                   		   
		  AND linha_produto      IS NULL                  		   
		  AND linha_receita      IS NULL                  		   
		  AND segmto_mercado     IS NULL                 		   
		  AND classe_uso         IS NULL                     		   
		  AND unid_medida        IS NULL                    		   
		  AND produto_bonific    IS NULL                		   
			AND grupo_fiscal_item  IS NULL                	   
		  AND item               IS NULL                           		   
		  AND micro_empresa      IS NULL                  		   
			AND grp_fiscal_cliente IS NULL               	   
		  AND cliente            IS NULL                        		   
		  AND via_transporte     IS NULL                 		   
		  AND valid_config_ini   IS NULL                              		   
		  AND valid_config_final IS NULL                              		   
   
   IF STATUS = 100 THEN
      LET p_men = 'Tributo ',p_den_tributo CLIPPED,
                  ' não encontrado\n na tabela obf_config_fiscal'
      CALL log0030_mensagem(p_men,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','obf_config_fiscal')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
