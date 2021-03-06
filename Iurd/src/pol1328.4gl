# PROGRAMA: pol1328                                                            #
# OBJETIVO: GERA��O DE NFE DE ENERGIA EL�TRICA - INTEGRA��O COM GI-IMOVEL      #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 04/09/2017                                                         #
#------------------------------------------------------------------------------#
# \\192.168.1.56\smartclient\TotvsSmartClient.exe -M -Q                        #
#              -P=men1100 -C=tcp_oracle -E=logix102_oracle                     #
#------------------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003)
END GLOBALS

DEFINE    m_msg                  CHAR(255),
          m_erro                 CHAR(05),
          m_cod_empresa          CHAR(02),
          m_num_seq              INTEGER,
          m_num_prx_ar           INTEGER,
          m_cfop                 CHAR(07),
          m_cnd_pgto             INTEGER,
          m_ies_especie_nf       CHAR(03),
          m_irrf                 SMALLINT,
          m_dat_refer            CHAR(07),
          m_mes_ref              CHAR(02),
          m_ano_ref              CHAR(04),
          m_val_desc_dp          DECIMAL(12,2),
          m_val_min              DECIMAL(12,2),
          m_val_desc_tot         DECIMAL(12,2),
          m_val_base             DECIMAL(12,2),
          m_val_irrf             DECIMAL(12,2),
          m_pct_irrf             DECIMAL(12,7),
          m_pct_desc             DECIMAL(12,7),
          m_qtd_depend           INTEGER,
          m_num_relac            INTEGER,
          m_seq_registro         INTEGER,
          m_hist_padrao          INTEGER,
          m_ies_sup_cap          CHAR(01),
          m_min_dat_venct_ap     DATE,
          m_ies_aprov            SMALLINT,
          m_seql_lanc_cap        INTEGER,
          m_val_acres            DECIMAL(17,7),
          m_pct_acres            DECIMAL(17,7),
          m_val_sem_ir           DECIMAL(12,2),
          m_val_com_ir           DECIMAL(12,2),
          m_ies_ir_ap            SMALLINT,
          p_cod_fiscal           CHAR(07),
          m_prefixo              CHAR(01),
          m_execucao             CHAR(01),
          p_num_ad               INTEGER,
          p_num_ap               INTEGER,
          p_num_ar               INTEGER,     
          p_ser_nf               CHAR(03),    
          p_ssr_nf               DECIMAL(2,0),    
          p_num_nf               DECIMAL(7,0),
          m_le_ap                SMALLINT,
          m_val_tol              DECIMAL(12,2),
          m_sem_ap               INTEGER,
          m_seq_txt              INTEGER,
          m_enviou_conta         SMALLINT

DEFINE    m_cod_item             LIKE item.cod_item,
          m_num_nf               LIKE nf_sup.num_nf,
          m_num_ar               LIKE nf_sup.num_aviso_rec,
          m_num_conta_deb        LIKE item_sup.num_conta,
          m_num_conta_cred       LIKE grupo_despesa.num_conta_fornec,
          m_raz_social           LIKE fornecedor.raz_social,
          m_ies_dep_cred         LIKE fornecedor.ies_dep_cred,
          m_cod_banco            LIKE fornecedor.cod_banco,
          m_num_cgc_cpf          LIKE fornecedor.num_cgc_cpf,
          m_num_agencia          LIKE fornecedor.num_agencia,
          m_num_conta_banco      LIKE fornecedor.num_conta_banco,
          m_cod_nivel_autor      LIKE aprov_grade.cod_nivel_autor,
          m_cod_uni_funcio       LIKE usu_nivel_aut_cap.cod_uni_funcio,
          m_uni_funcio           LIKE usu_nivel_aut_cap.cod_uni_funcio,
          m_cod_user             LIKE usuarios.cod_usuario,
          m_nom_user             LIKE usuarios.nom_funcionario,
          m_email_user           LIKE usuarios.e_mail,
	        m_for_juridic          LIKE fornecedor.ies_fis_juridica,
	        m_cgc_empresa          LIKE empresa.num_cgc

DEFINE mr_nota                      RECORD 													
       id_ad                       	INTEGER,             
       cod_empresa                 	CHAR(2),       
       cod_fatura                  	INTEGER,       
       cod_contrato                	INTEGER,       
       cod_obrigacao               	INTEGER,       
       num_ad                     	DECIMAL(6,0),  
       num_ar                      	INTEGER,       
       ser_nf                      	CHAR(03),      
       ssr_nf                      	DECIMAL(2,0),  
       num_nf                      	DECIMAL(7,0), 
       cod_fornecedor              	CHAR(15),    
       den_item 			              CHAR(50),  		
       val_tot_nf                  	DECIMAL(15,2), 
       cod_moeda                   	DECIMAL(3,0),  
       cod_tip_despesa              DECIMAL(4,0),  
       den_observacao              	VARCHAR(4000),  
       ies_gera_nota               	CHAR(1),       
       num_lote                    	INTEGER,                     
       cod_situacao                	CHAR(1),                     
       ies_da_bc_ipi               	char(1),                     
       cod_incid_ipi               	decimal(2,0),                
       ies_tip_incid_ipi           	char(1),                     
       pct_ipi_declarad            	decimal(6,3),                
       val_base_c_ipi_it           	decimal(17,2),               
       val_ipi_decl_item           	decimal(17,2),               
       val_ipi_desp_aces           	decimal(17,2),               
       val_base_c_item_d           	decimal(17,2),               
       pct_icms_item_d 		          decimal(5,3),	              
       val_icms_item_d 		          decimal(17,2),               
       pct_red_bc_item_d 		        decimal(5,3), 	              
       val_base_c_icms_da 		      decimal(17,2),               
       val_icms_desp_aces 		      decimal(17,2),               
       ies_incid_icms_ite 		      char(1), 		                
       val_base_pis_d 		          decimal(17,6),               
       val_base_cofins_d 		        decimal(17,6),               
       pct_pis_item_d 		          decimal(8,6),                
       pct_cofins_item_d 		        decimal(8,6),                
       val_pis_d 			              decimal(17,2),               
       val_cofins_d 		            decimal(17,2), 
       dt_processamento             DATE,         
       cod_usuario                  VARCHAR(255),  
       dt_emissao                   DATE,
       num_nf_dig                   decimal(9,0),
       cod_tipo_obrigacao           INTEGER,
       cod_operacao                 CHAR(05),
       cod_obrig_lcc   	            DECIMAL(7,0)
END RECORD

DEFINE mr_gi_aen                   RECORD
   id_ad_aen                       INTEGER,     
   id_ad                           INTEGER,     
   cod_empresa                     CHAR(2),     
   cod_fatura                      INTEGER,     
   cod_lin_prod                    DEC(2,0),   
   cod_lin_recei                   DEC(2,0),   
   cod_seg_merc                    DEC(2,0),   
   cod_cla_uso                     DEC(2,0),   
   val_aen                         DEC(15,2)
END RECORD

DEFINE mr_gi_ap                    RECORD
       id_ap                       INTEGER,        
       id_ad                       INTEGER,        
       cod_empresa                 CHAR(2),        
       num_ap                      DECIMAL(6,0),   
       cod_fatura                  INTEGER,        
       cod_fornecedor              CHAR(15),       
       cod_favorecido              CHAR(15),       
       val_nom_ap                  DECIMAL(15,2),  
       dt_vencimento               DATE,           
       dt_pagamento                DATE,
       ies_banco                   CHAR(01),
       cod_banco_fav               LIKE cap_info_bancaria.banco,
       num_agencia_fav             LIKE cap_info_bancaria.agencia,
       num_conta_banco_fav         LIKE cap_info_bancaria.cta_bancaria      
END RECORD

DEFINE mr_nf_sup                   RECORD LIKE nf_sup.*,
       mr_aviso                    RECORD LIKE aviso_rec.*,
       mr_ar_compl                 RECORD LIKE aviso_rec_compl.*,
       mr_audit_ar                 RECORD LIKE audit_ar.*,
       mr_dest_ar                  RECORD LIKE dest_aviso_rec4.*,
       mr_ar_sq                    RECORD LIKE aviso_rec_compl_sq.*,             
       mr_tipo_despesa             RECORD LIKE tipo_despesa.*,
       mr_grade_aprov_cap          RECORD LIKE grade_aprov_cap.*

DEFINE m_cod_emp_ad                CHAR(02),
       m_dat_vencto                DATE,
       m_parcela                   INTEGER,
       m_num_ad                    INTEGER,
       m_num_ap                    INTEGER,
       m_id_ad                     INTEGER,
       m_dat_txt_ap                CHAR(10),
       m_dat_txt_atu               CHAR(10),
       m_dat_emissao               DATE,
       m_dat_recebto               DATE

DEFINE mr_ad_mestre                 RECORD LIKE ad_mestre.*,
       mr_ap                        RECORD LIKE ap.*,
       mr_lanc_cont_cap             RECORD LIKE lanc_cont_cap.*

DEFINE mr_reten_irrf_pg             RECORD
       cod_empresa                  CHAR(2),
       num_ad                       DECIMAL(6,0),
       num_nf                       CHAR(7),
       ser_nf                       CHAR(3),
       ssr_nf                       DECIMAL(2,0),
       ies_especie_nf               CHAR(3),
       cod_fornecedor               CHAR(15),
       cod_tip_val                  DECIMAL(3,0),
       val_base_calc                DECIMAL(13,2),
       val_depend                   DECIMAL(13,2),
       val_pensao                   DECIMAL(13,2),
       val_inss                     DECIMAL(13,2),
       val_irrf                     DECIMAL(13,2)
END RECORD

DEFINE mr_reten_irrf_ap             RECORD
       cod_empresa                  CHAR(2),
       num_ap                       DECIMAL(6,0),
       num_versao                   DECIMAL(2,0),
       ies_versao_atual             CHAR(1),
       cod_tip_val                  DECIMAL(3,0),
       val_base_calc                DECIMAL(13,2),
       val_depend                   DECIMAL(13,2),
       val_pensao                   DECIMAL(13,2),
       val_inss                     DECIMAL(13,2),
       val_irrf                     DECIMAL(13,2)
END RECORD

DEFINE m_cod_retencao      LIKE tip_desp_x_irrf.cod_retencao,
       m_cod_tip_val       LIKE tipo_valor.cod_tip_val,
       m_perc_val_princ    LIKE tipo_valor.perc_val_princ,
       m_lmt_sup_sal       LIKE irrf.lmt_sup_sal,     
       m_val_parcel_deduz  LIKE irrf.val_parcel_deduz,
       m_pct_desc_irrf     LIKE irrf.pct_desc_irrf   

   DEFINE m_historico_deb       LIKE hist_padrao_cap.historico,
          m_historico_cred      LIKE hist_padrao_cap.historico,
          m_periodo_contab     CHAR(04),
          m_segmto_periodo     DECIMAL(2,0)
                    
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 30
   LET p_versao = "pol1328-12.00.139 "
   CALL func002_versao_prg(p_versao)

   CALL log001_acessa_usuario("ESPEC999","")     
       RETURNING p_status, p_cod_empresa, p_user

   LET p_status = 0
   LET p_cod_empresa = '01'
   LET p_user = 'admlog'

   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_execucao = 'M'   
   CALL pol1328_processa() RETURNING p_status
   
END MAIN

#------------------------------#
FUNCTION pol1328_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '25'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
   
   LET m_execucao = 'A'
   CALL pol1328_processa() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#------------------------------#
FUNCTION pol1328_check_proces()#
#------------------------------#
   
   DEFINE l_ies_processando  CHAR(01),
          l_qtd_tentativa    INTEGER
          
   SELECT ies_processando,
          qtd_tentativa
     INTO l_ies_processando,
          l_qtd_tentativa
     FROM control_proces_912
    WHERE id_proces = 1

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   IF l_ies_processando = 'N' THEN
      UPDATE control_proces_912
         SET ies_processando = 'S',
             qtd_tentativa = 0
       WHERE id_proces = 1    

      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
     
      RETURN TRUE
   END IF
   
   IF l_qtd_tentativa < 10 THEN
      UPDATE control_proces_912
         SET qtd_tentativa = qtd_tentativa + 1
       WHERE id_proces = 1    

      RETURN FALSE
   
   END IF
         
   RETURN TRUE   

END FUNCTION   

#-------------------------------#
FUNCTION pol1328_cria_controle()#
#-------------------------------#

   CREATE TABLE control_proces_912 (
      id_proces            INTEGER,
      ies_processando      char(01),
      qtd_tentativa        INTEGER
   );

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_proces_912
    ON control_proces_912(id_proces);

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   INSERT INTO control_proces_912 VALUES(1,'N',0)

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE      
   
END FUNCTION

#----------------------------#
FUNCTION pol1328_cria_ad_ap()#
#----------------------------#

   CREATE TABLE gi_ad_ap_912 (
      cod_empresa       CHAR(02),
      id_ad             INTEGER,
      cod_obrigacao     INTEGER,
      cod_fatura        INTEGER,
      num_ad            INTEGER,
      num_ap            INTEGER,
      dat_gravacao      CHAR(19)
   );

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   CREATE INDEX ix_gi_ad_ap_912
    ON gi_ad_ap_912(cod_empresa, id_ad, cod_obrigacao);

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE      
   
END FUNCTION
   
#--------------------------------#
FUNCTION pol1356_cria_banco_912()#
#--------------------------------#
   
   CREATE TABLE ies_banco_912(
      cod_favorecido      CHAR(15)
   );
   
   CREATE UNIQUE INDEX ix_favorecido_912
    ON ies_banco_912(cod_favorecido);
   
   INSERT INTO ies_banco_912 VALUES('092874270000140')
   INSERT INTO ies_banco_912 VALUES('092702067000196') 
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol1356_cria_ap_proces_912()#
#------------------------------------#
   
   CREATE TABLE ap_proces_912(
       cod_empresa   CHAR(02),
       cod_fatura    INTEGER,
       id_ap         INTEGER,
       num_ap        INTEGER      
   );
   
   CREATE INDEX ix_ap_proces_912
    ON ap_proces_912(cod_empresa, cod_fatura);

   RETURN TRUE

END FUNCTION   
          
#--------------------------#
FUNCTION pol1328_processa()#
#--------------------------#   

   DEFINE l_nom_tela        CHAR(200),
          l_num_ordem       CHAR(10),
          l_ret             SMALLINT

   INITIALIZE l_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1328") RETURNING l_nom_tela
   LET l_nom_tela = l_nom_tela CLIPPED 
   OPEN WINDOW w_pol1328 AT 5,10 WITH FORM l_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   CALL LOG_refresh_display()   
   
   IF NOT log0150_verifica_se_tabela_existe("control_proces_912") THEN 
      IF NOT pol1328_cria_controle() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe("gi_ad_ap_912") THEN 
      IF NOT pol1328_cria_ad_ap() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1328_check_proces()THEN
      RETURN FALSE
   END IF
   
   IF NOT log0150_verifica_se_tabela_existe("ies_banco_912") THEN 
      IF NOT pol1356_cria_banco_912() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe("ap_proces_912") THEN 
      IF NOT pol1356_cria_ap_proces_912() THEN
         RETURN FALSE
      END IF
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1328_del_ad_sem_ap() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   DELETE FROM obrigacao_proces_912   
    WHERE obrigacao_proces_912.num_ad IS NOT NULL
      AND obrigacao_proces_912.num_ad > 0
      AND obrigacao_proces_912.num_ad NOT IN 
          (SELECT ad_mestre.num_ad FROM ad_mestre
            WHERE ad_mestre.cod_empresa = obrigacao_proces_912.cod_empresa)
                       
   LET m_erro = NULL
      
   CALL pol1328_proc_nota() RETURNING p_status
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol1328_del_ad_sem_ap() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
   
   UPDATE control_proces_912
      SET ies_processando = 'N',
          qtd_tentativa = 0
    WHERE id_proces = 1    
   
   IF m_erro IS NOT NULL THEN
      CALL pol1328_grava_erro() RETURN l_ret
   END IF
   
   UPDATE gi_ad_912 SET cod_situacao = 'E'   
    WHERE ies_gera_nota IN ('A', 'S') 
      AND id_ad IN 
          (SELECT a.id_ad FROM gi_ad_912  a                
            WHERE num_ar NOT IN 
               (SELECT b.num_aviso_rec FROM nf_sup b
                 WHERE a.cod_empresa = b.cod_empresa                        
                   AND   a.num_ar = b.num_aviso_rec)                          
          AND   a.cod_situacao = 'S'                                 
          AND   a.num_ar > 0)                                        

   UPDATE gi_ap_912
      SET gi_ap_912.dt_pagamento =
         (SELECT ap.dat_pgto FROM ap
           WHERE ap.dat_pgto IS NOT NULL
             AND ap.cod_empresa = gi_ap_912.cod_empresa
             AND ap.num_ap = gi_ap_912.num_ap)
   WHERE gi_ap_912.num_ap IS NOT NULL
     AND gi_ap_912.dt_pagamento IS NULL
     AND gi_ap_912.num_ap IN
         (SELECT ap.NUM_AP FROM ap
           WHERE ap.dat_pgto IS NOT NULL
             AND ap.cod_empresa = gi_ap_912.cod_empresa)
             
   UPDATE gi_ad_912 SET gi_ad_912.cod_situacao = 'E'
    WHERE gi_ad_912.cod_situacao = 'S'
       AND ies_gera_nota NOT IN ('A', 'S') 
       AND gi_ad_912.num_ad IS NOT NULL
       AND gi_ad_912.num_ad > 0
       AND gi_ad_912.num_ad NOT IN
        (SELECT ad_mestre.num_ad FROM ad_mestre
          WHERE ad_mestre.cod_empresa = gi_ad_912.cod_empresa)      
   
   CLOSE WINDOW w_pol1328
           
   RETURN p_status
   
END FUNCTION   

#----------------------------#
FUNCTION pol1328_grava_erro()#
#----------------------------#

   DEFINE l_id_ad      INTEGER
   
   LET l_id_ad = mr_nota.id_ad
   
   IF l_id_ad IS NULL THEN 
      LET l_id_ad = 0
   END IF

   LET m_num_seq = m_num_seq + 1            
   
   INSERT INTO gi_ad_erro_912(
    id_ad, cod_empresa, cod_fatura, num_seq, den_erro)
   VALUES(l_id_ad, p_cod_empresa, mr_nota.cod_fatura,
          m_num_seq, m_msg)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registros na tabela gi_ad_erro_912.'
      LET m_num_seq = 0
   END IF
   
   RETURN TRUE         

END FUNCTION
  
#----------------------------------#
 FUNCTION pol1328_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT * 
      FROM gi_ad_912  
     WHERE id_ad = mr_nota.id_ad
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE      
      RETURN FALSE
   END IF

END FUNCTION


#----------------------------#
 FUNCTION pol1328_proc_nota()#
#----------------------------#       
   
   DEFINE l_num_nota    VARCHAR(09)
   
   DEFINE l_dat_proces   CHAR(19),
          l_num_nf       CHAR(07),
          l_count        INTEGER,
          l_mes          INTEGER,
          l_ano          INTEGER,
          l_qtd_ap       INTEGER
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO DAY)
            				
   DECLARE cq_nota CURSOR WITH HOLD FOR
    SELECT * FROM gi_ad_912
     WHERE cod_situacao = 'N' OR cod_situacao = 'C'
   
   FOREACH cq_nota INTO mr_nota.*
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela gi_ad_912.'
         LET m_num_seq = 0
         EXIT FOREACH
      END IF
            
      LET p_cod_empresa = mr_nota.cod_empresa
      LET m_le_ap = FALSE
      
      IF mr_nota.ies_gera_nota = 'F' THEN
         LET l_num_nota = mr_nota.num_nf_dig USING '<<<<<<<<<'
         LET mr_nota.num_nf = l_num_nota[1,7]
      END IF
            	 
      SELECT 
      num_ad,      
      num_ar,      
      ser_nf,      
      ssr_nf,      
      num_nf 
      INTO
          p_num_ad,          
          p_num_ar,      
          p_ser_nf,    
          p_ssr_nf,    
          p_num_nf               
       FROM obrigacao_proces_912  
       WHERE cod_empresa = p_cod_empresa
         AND cod_fatura =  mr_nota.cod_fatura
    
      IF STATUS = 0 THEN
         LET m_le_ap = TRUE
         LET p_num_ap = 0
         CALL pol1328_gra_gi_ad()
         CONTINUE FOREACH      
      END IF            

      LET m_cod_emp_ad = mr_nota.cod_empresa
      LET m_num_prx_ar = NULL
      
      DELETE FROM gi_ad_erro_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_fatura = mr_nota.cod_fatura
      
      DISPLAY mr_nota.num_nf TO num_nf
      CALL LOG_refresh_display()	
      
      LET m_num_seq = 0
      LET p_user = mr_nota.cod_usuario[1,8]
      
      IF NOT pol1328_consiste_ad() THEN
         RETURN FALSE
      END IF

      IF NOT pol1328_consiste_ad_valores() THEN
         RETURN FALSE
      END IF

      IF NOT pol1328_consiste_ad_aen() THEN
         RETURN FALSE
      END IF

      IF NOT pol1328_consiste_ap() THEN
         RETURN FALSE
      END IF
      
      IF m_num_seq = 0 THEN
         
         IF mr_nota.ies_gera_nota MATCHES '[AS]' THEN
            
            IF mr_nota.ssr_nf IS NULL OR mr_nota.ssr_nf = ' ' THEN
               LET mr_nota.ssr_nf = 0
            END IF

            SELECT cod_empresa FROM nf_sup
             WHERE cod_empresa = p_cod_empresa
               AND num_nf = mr_nota.num_nf
               AND ser_nf = mr_nota.ser_nf
               AND ssr_nf = mr_nota.ssr_nf
               AND ies_especie_nf = m_ies_especie_nf
               AND cod_fornecedor = mr_nota.cod_fornecedor
            
            IF STATUS = 0 THEN
               LET m_msg = 'J� existe no SUP3760 uma NF com essas caracteristicas'
               IF NOT pol1328_grava_erro() THEN
                  RETURN FALSE
               END IF
            END IF
            
         ELSE      
            IF mr_nota.ies_gera_nota = 'F' THEN
            	 IF mr_nota.num_nf IS NULL OR mr_nota.ser_nf IS NULL THEN
                  LET m_msg = 'Para pgto de ART � obriga�rio informar nota/s�rie da NF'
                  IF NOT pol1328_grava_erro() THEN
                     RETURN FALSE
                  END IF
               END IF
            	 IF mr_nota.ser_nf IS NULL THEN
                  LET m_msg = 'Para pgto de ART � obriga�rio informar o n�mero da NF'
                  IF NOT pol1328_grava_erro() THEN
                     RETURN FALSE
                  END IF
               END IF
            	 IF mr_nota.ssr_nf IS NULL  THEN
                  LET m_msg = 'Para pgto de ART � obriga�rio informar a  sub-s�rie da NF'
                  IF NOT pol1328_grava_erro() THEN
                     RETURN FALSE
                  END IF
               END IF
            ELSE
               IF mr_nota.ser_nf IS NULL OR mr_nota.ser_nf = ' ' THEN
                  IF NOT pol1328_gera_ser_ssr() THEN
                     RETURN FALSE
                  END IF
               END IF         
            END IF
         END IF
         
      END IF

      SELECT cod_uni_funcio
        INTO m_uni_funcio
        FROM gi_desp_uni_funcio_912
       WHERE cod_tip_despesa = mr_nota.cod_tip_despesa

      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo a tabela gi_desp_uni_funcio_912. '
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS = 100 THEN
            LET m_uni_funcio = NULL
         END IF
      END IF   
            
      IF m_num_seq > 0 THEN
         UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = mr_nota.id_ad
         CONTINUE FOREACH
      END IF            

      LET m_dat_txt_ap  = EXTEND(m_min_dat_venct_ap, YEAR TO DAY)
      LET m_dat_txt_atu = EXTEND(CURRENT, YEAR TO DAY)    
      
      IF mr_nota.dt_emissao IS NULL THEN
         LET m_dat_emissao = m_min_dat_venct_ap 
      ELSE
         LET m_dat_emissao =  mr_nota.dt_emissao 
      END IF
            
      LET m_dat_recebto = m_dat_emissao
      LET m_dat_vencto  = m_min_dat_venct_ap
            
      IF NOT pol1328_checa_per_cont() THEN
         RETURN FALSE
      END IF

      IF m_num_seq > 0 THEN
         UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = mr_nota.id_ad
         CONTINUE FOREACH
      END IF            
      
      LET l_num_nf = mr_nota.num_nf  USING '<<<<<<<' 
      
      LET l_mes = MONTH(m_dat_vencto)
      LET l_ano = YEAR(m_dat_vencto)
      LET l_count = 0
      
      DECLARE cq_pri_ad CURSOR FOR
      SELECT num_ad, num_nf, ser_nf, ssr_nf 
        FROM ad_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nf = l_num_nf
         AND ser_nf = mr_nota.ser_nf
         AND ssr_nf = mr_nota.ssr_nf
         AND cod_fornecedor = mr_nota.cod_fornecedor
         AND dat_venc = m_dat_vencto
         AND val_tot_nf  = mr_nota.val_tot_nf 

      FOREACH cq_pri_ad INTO p_num_ad, p_num_nf , p_ser_nf, p_ssr_nf

         IF STATUS <> 0 THEN 
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' lendo registros da tabela ad_mestre.'
            LET m_num_seq = 0
            RETURN FALSE
         END IF
         
         LET l_count = 1
         
         SELECT num_aviso_rec
           INTO p_num_ar
           FROM nf_sup
          WHERE cod_empresa = p_cod_empresa
            AND num_nf = p_num_nf
            AND ser_nf = p_ser_nf
            AND ssr_nf = p_ssr_nf             
            AND ies_especie_nf = 'NF'
            AND cod_fornecedor = mr_nota.cod_fornecedor
         
         IF STATUS <> 0 THEN
            LET p_num_ar = 0
         END IF
         
         SELECT COUNT(*) INTO l_qtd_ap
            FROM ad_ap
           WHERE cod_empresa = p_cod_empresa
             AND num_ad = p_num_ad
         
         IF l_qtd_ap > 1 THEN
            LET p_num_ap = 0
            EXIT FOREACH
         END IF
         
         SELECT num_ap INTO p_num_ap
           FROM ad_ap
          WHERE cod_empresa = p_cod_empresa
            AND num_ad = p_num_ad
         
         EXIT FOREACH
         
      END FOREACH
      
      IF l_count > 0 THEN
         
         SELECT COUNT(*) INTO l_count
           FROM gi_ad_912  
          WHERE cod_empresa = p_cod_empresa 
            AND num_ad = p_num_ad
            AND cod_situacao <> 'E'
         
         IF l_count > 0 THEN
            LET m_msg = 'J� existe uma AD para a mesma empresa, nota, serie, fornec, vencto e valor, a AD= ', p_num_ad             
            IF NOT pol1328_grava_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            CALL pol1328_gra_gi_ad()
            CONTINUE FOREACH
         END IF
      END IF            
      
      IF mr_nota.ies_gera_nota MATCHES '[FS]' THEN                                                   
         SELECT COUNT(*) INTO l_count                                                                
           FROM ad_mestre                                                                            
          WHERE cod_empresa = p_cod_empresa                                                          
            AND num_nf = l_num_nf                                                                    
            AND ser_nf = mr_nota.ser_nf                                                              
            AND ssr_nf = mr_nota.ssr_nf                                                              
            AND cod_fornecedor = mr_nota.cod_fornecedor                                              
                                                                                                     
         IF l_count > 0 THEN                                                                         
            LET m_msg = 'J� existe uma AD para a mesma empresa, nota, serie, sub serie e fornecedor '
            IF NOT pol1328_grava_erro() THEN                                                         
               RETURN FALSE                                                                          
            END IF                                                                                   
            CALL pol1328_gra_gi_ad()                                                                 
            CONTINUE FOREACH                                                                         
         END IF                                                                                      
      END IF                                                                                         
      
      SELECT COUNT(*) INTO l_count 
        FROM gi_ad_erro_912
       WHERE cod_empresa = p_cod_empresa
         AND id_ad = mr_nota.id_ad
      
      IF STATUS <> 0 THEN 
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo tabela gi_ad_erro_912.'
         LET m_num_seq = 0
         RETURN FALSE
      END IF

      IF l_count > 0 OR m_num_seq > 0 THEN
         UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = mr_nota.id_ad
         CONTINUE FOREACH
      END IF            
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1328_le_par_ad() THEN 
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      CALL log085_transacao("COMMIT")
      
      IF m_uni_funcio IS NOT NULL THEN
         LET m_cod_uni_funcio = m_uni_funcio
      END IF
      
                                
      IF NOT pol1328_le_tip_desp() THEN 
         RETURN FALSE
      END IF   

      IF not pol1328_prende_registro() THEN 
         CALL log085_transacao("ROLLBACK")
         CLOSE cq_prende
         
         LET m_msg = 'N�o foi possivel ler c/ acesso exclusivo a obriga��o de id ', mr_nota.id_ad           
            
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
            
         UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = mr_nota.id_ad
          CONTINUE FOREACH
      END IF

      
      IF mr_nota.ies_gera_nota MATCHES '[AS]' THEN
               
         LET m_ies_sup_cap = 'S'
         IF NOT pol1328_gera_nota() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      ELSE
         LET m_ies_sup_cap = 'O'
         LET m_ies_especie_nf = 'AD'
      END IF     
      
      IF mr_nota.ies_gera_nota = 'A' THEN
         LET m_num_ad = 0
      ELSE      
         IF NOT pol1328_gera_titulo() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF

         SELECT COUNT(num_ap) INTO m_sem_ap
           FROM ad_ap
          WHERE cod_empresa = mr_ad_mestre.cod_empresa
            AND num_ad = mr_ad_mestre.num_ad

         IF STATUS <> 0 THEN
            LET m_sem_ap = 0
         END IF

         IF m_sem_ap = 0 THEN
            CALL log085_transacao("ROLLBACK")
            CLOSE cq_prende
            LET m_msg = 'N�o foi possivel gerar AP para AD ', mr_ad_mestre.num_ad             
            IF NOT pol1328_grava_erro() THEN
               RETURN FALSE
            END IF
            UPDATE gi_ad_912 SET cod_situacao = 'C'
             WHERE id_ad = mr_nota.id_ad
            CONTINUE FOREACH
         END IF
                        
      END IF   
           
      IF NOT pol1328_atu_gi_ad() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
            
      SELECT cod_situacao 
        FROM gi_ad_912 
       WHERE id_ad = mr_nota.id_ad
         AND cod_situacao = 'S'
      
      IF STATUS <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
         LET m_msg = 'N�o foi possivel atualizar status da tabela gi_ad_912.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
         UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = mr_nota.id_ad
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
      CLOSE cq_prende
      
   END FOREACH

   IF m_erro IS NOT NULL THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION         

#--------------------------------#
FUNCTION pol1328_checa_per_cont()#
#--------------------------------#
   
   DEFINE l_ano_con           VARCHAR(04),
          l_mes_con           VARCHAR(2,0),
          l_ano_mes_con       VARCHAR(06),
          l_ano_rec           VARCHAR(04),
          l_mes_rec           VARCHAR(02),
          l_ano_mes_rec       VARCHAR(06),
          l_ano_orig          VARCHAR(04),
          l_mes_orig          VARCHAR(02),
          l_ano_mes_fec       VARCHAR(06)
   
   LET l_ano_rec = YEAR(m_dat_recebto)
   LET l_mes_rec = MONTH(m_dat_recebto)
   
   LET l_mes_rec = l_mes_rec CLIPPED
   
   IF LENGTH(l_mes_rec) = 1 THEN
      LET l_mes_rec = '0',l_mes_rec CLIPPED
   END IF
   
   LET l_ano_mes_rec = l_ano_rec, l_mes_rec
   
   SELECT ult_num_per_fech, 
          ult_num_seg_fech 
     INTO l_ano_con,
          l_mes_con
     FROM par_con 
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN 
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo tabela par_con.'
      LET m_num_seq = 0
      RETURN FALSE
   END IF
   
   IF LENGTH(l_mes_con) = 1 THEN
      LET l_mes_con = '0',l_mes_con
   END IF
   
   LET l_ano_mes_con = l_ano_con, l_mes_con

   IF l_ano_mes_rec <= l_ano_mes_con THEN
      LET m_msg = 'Modulo contabil fechado para o per�odo'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF      

   IF mr_nota.ies_gera_nota MATCHES '[FS]' THEN 

      SELECT 
             substr(area_livre,3,2), 
             substr(area_livre,5,4)
        INTO l_mes_orig,
             l_ano_orig
        FROM sistemas  
       WHERE cod_empresa = p_cod_empresa  
         AND COD_SISTEMA = 'CAP'

      IF STATUS <> 0 THEN 
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo tabela sistemas.CAP.'
         LET m_num_seq = 0
         RETURN FALSE
      END IF

      LET l_ano_mes_fec = l_ano_orig, l_mes_orig

      IF l_ano_mes_rec <= l_ano_mes_fec THEN
         LET m_msg = 'Modulo financeiro fechado para o per�odo'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF      
   
   END IF
   
   IF mr_nota.ies_gera_nota MATCHES '[AS]' THEN 

      SELECT 
             substr(area_livre,3,2), 
             substr(area_livre,5,4)
        INTO l_mes_orig,
             l_ano_orig
        FROM sistemas  
       WHERE cod_empresa = p_cod_empresa  
         AND COD_SISTEMA = 'SUP'

      IF STATUS <> 0 THEN 
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo tabela sistemas.CAP.'
         LET m_num_seq = 0
         RETURN FALSE
      END IF

      LET l_ano_mes_fec = l_ano_orig, l_mes_orig

      IF l_ano_mes_rec <= l_ano_mes_fec THEN
         LET m_msg = 'Modulo suprimento fechado para o per�odo'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF      
   
   END IF
   
   RETURN TRUE

END FUNCTION
    
#---------------------------#
FUNCTION pol1328_atu_gi_ad()#
#---------------------------#
   
   DEFINE l_cod_situacao       CHAR(01)
   DEFINE l_dat_proces         CHAR(19)
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   
   INSERT INTO obrigacao_proces_912(
      cod_empresa, 
      id_ad,       
      cod_fatura,  
      num_ad,      
      num_ar,      
      ser_nf,      
      ssr_nf,      
      num_nf,      
      dat_proces)        
   VALUES(p_cod_empresa,
          mr_nota.id_ad, 
          mr_nota.cod_fatura,
          m_num_ad,          
          m_num_prx_ar,      
          mr_nota.ser_nf,    
          mr_nota.ssr_nf,    
          mr_nota.num_nf,               
          l_dat_proces)
   
   IF STATUS <> 0 THEN                                                   
      LET m_erro = STATUS USING '<<<<<'                                  
      LET m_msg = 'Erro de status: ',m_erro                              
      LET m_msg = m_msg CLIPPED, ' gravando registro na tabela obrigacao_proces_912.'
      RETURN FALSE                                                       
   END IF       
   
   UPDATE gi_ad_912 
      SET cod_situacao = 'S',  
          num_ad   = m_num_ad,
          num_ar   = m_num_prx_ar,
          ser_nf   = mr_nota.ser_nf,
          ssr_nf   = mr_nota.ssr_nf, 
          num_nf   = mr_nota.num_nf        
    WHERE id_ad = mr_nota.id_ad

   IF STATUS <> 0 THEN                                                   
      LET m_erro = STATUS USING '<<<<<'                                  
      LET m_msg = 'Erro de status: ',m_erro                              
      LET m_msg = m_msg CLIPPED, ' gravando dados da AD/NF na gi_ad_912 '
      RETURN FALSE                                                       
   END IF       
        
   RETURN TRUE

END FUNCTION                                                         

#---------------------------#
FUNCTION pol1328_gra_gi_ad()#
#---------------------------#      
   
   DEFINE l_id_ap, l_num_ap INTEGER,
          l_atu_ap          SMALLINT,
          l_count           INTEGER
          
   LET l_atu_ap = FALSE 
      
   UPDATE gi_ad_912 
      SET cod_situacao = 'S',  
          num_ad   = p_num_ad,
          num_ar   = p_num_ar,
          ser_nf   = p_ser_nf,
          ssr_nf   = p_ssr_nf, 
          num_nf   = p_num_nf        
    WHERE cod_empresa = p_cod_empresa 
      AND cod_fatura = mr_nota.cod_fatura

   IF p_num_ap > 0 THEN
      UPDATE gi_ap_912
         SET num_ap = p_num_ap
       WHERE cod_empresa = p_cod_empresa 
         AND cod_fatura = mr_nota.cod_fatura
      RETURN
   END IF

    SELECT COUNT(*) INTO l_count
      FROM ap_proces_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_fatura = mr_nota.cod_fatura
   
   IF l_count = 1 THEN
      SELECT num_ap INTO l_num_ap
        FROM ap_proces_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_fatura = mr_nota.cod_fatura
      
      IF STATUS = 0 THEN
         UPDATE gi_ap_912
            SET num_ap = l_num_ap
          WHERE cod_empresa = p_cod_empresa 
            AND cod_fatura = mr_nota.cod_fatura
      END IF
   END IF   
   
END FUNCTION                                                         
   
#-----------------------------#
FUNCTION pol1328_consiste_ad()#
#-----------------------------#

   IF NOT pol1328_valida_empresa() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_valida_usuario() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1328_valida_fornec() THEN
      RETURN FALSE
   END IF

   IF mr_nota.ies_gera_nota MATCHES '[AS]' THEN
      IF NOT pol1328_valida_obrigacao() THEN
         RETURN FALSE
      END IF
      #IF NOT pol1328_valida_cnd_pgto() THEN
      #   RETURN FALSE
      #END IF
   ELSE
      LET m_cnd_pgto = NULL
   END IF
   
   IF mr_nota.num_nf = 0 THEN
      LET m_msg = 'O n�mero da nota do campo gi_ad_912.num_nf est� com zero.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   IF NOT pol1328_valida_tip_despesa() THEN
      RETURN FALSE
   END IF
   
   IF mr_nota.val_tot_nf = 0 THEN
      LET m_msg = 'O valor total do campo gi_ad_912.val_tot_nf est� com zero.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF      

   IF LENGTH(mr_nota.den_observacao CLIPPED) > 3950 THEN
      LET m_msg = 'TEXTO DA FATURA SUPERIOR 3950 POSI��ES, O LOGIX N�O ACEITA'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF      
   
   IF NOT pol1328_valida_moeda() THEN
      RETURN FALSE
   END IF
   
   IF mr_nota.ies_gera_nota MATCHES '[ASNF]' THEN
   ELSE
      LET m_msg = 'O valor do campo gi_ad_912.ies_gera_nota n�o � v�lido.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1328_valida_tributos() THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1328_valida_empresa()#
#--------------------------------#

   SELECT num_cgc
     INTO m_cgc_empresa
     FROM empresa
    WHERE cod_empresa = mr_nota.cod_empresa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela empresa, para valida��o da mesma.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'A empresa do campo gi_ad_912.cod_empresa n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1328_valida_usuario()#
#--------------------------------#

   SELECT 1
     FROM usuarios
    WHERE cod_usuario = p_user

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela usuarios, para valida��o do mesmo.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'O usu�rio do campo gi_ad_912.cod_usuario n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION
      
#-------------------------------#
FUNCTION pol1328_valida_fornec()#
#-------------------------------#
   
   DEFINE l_ies_ativo     CHAR(01)
   
   SELECT raz_social,
          ies_dep_cred,
          cod_banco,
          num_cgc_cpf,
          num_agencia,
          num_conta_banco,
          ies_fis_juridica,
          ies_fornec_ativo
     INTO m_raz_social,
          m_ies_dep_cred,
          m_cod_banco,
          m_num_cgc_cpf,         
          m_num_agencia,
          m_num_conta_banco,
          m_for_juridic,
          l_ies_ativo
     FROM fornecedor
    WHERE cod_fornecedor = mr_nota.cod_fornecedor

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela fornecedor, para valida��o do mesmo na AD'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'O fornecedor do campo gi_ad_912.cod_fornecedor n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF l_ies_ativo = 'A' THEN
      ELSE
         LET m_msg = 'Fornecedor ', mr_nota.cod_fornecedor CLIPPED, 'inativo no Logix'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1328_valida_obrigacao()#
#----------------------------------#

   SELECT 
          cod_item,
          especie_nf,
          cnd_pgto
     INTO 
          m_cod_item,
          m_ies_especie_nf,
          m_cnd_pgto
     FROM gi_param_ar_912
    WHERE cod_tipo_obrigacao = mr_nota.cod_tipo_obrigacao

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela gi_param_ar_912. '
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'Tipo de obriga��o ', mr_nota.cod_tipo_obrigacao USING '<<<<',
           ' n�o foi cadastrada no POL1332.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_nota.den_item IS NULL THEN
      LET m_msg = 'A descri��o do campo gi_ad_912.den_item est� nula.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_nota.ies_gera_nota = 'S' THEN
      IF mr_nota.num_nf_dig IS NULL THEN                
         LET m_msg = 'Campo obrigat�rio NUM_NF_DIG n�o foi preenchido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF mr_nota.cod_operacao IS NULL THEN                
         LET m_msg = 'Campo obrigat�rio COD_OPERACAO n�o foi preenchido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF mr_nota.ser_nf IS NULL THEN                
         LET m_msg = 'Campo obrigat�rio SER_NF n�o foi preenchido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF mr_nota.ssr_nf IS NULL THEN                
         LET m_msg = 'Campo obrigat�rio SSR_NF n�o foi preenchido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF mr_nota.dt_emissao IS NULL THEN                
         LET m_msg = 'Campo obrigat�rio. DT_EMISSAO n�o foi preenchido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

   END IF
   
   LET m_cfop = mr_nota.cod_operacao
   
   CALL pol1328_acerta_cfop()   
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1328_valida_cnd_pgto()#
#---------------------------------#  
   
   SELECT val_inteiro
     INTO m_cnd_pgto
     FROM gi_param_integracao_912
    WHERE cod_parametro = 'CONDICAO_DE_PAGAMENTO'
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela gi_param_integracao_912. '
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'A condicao de pagamento n�o foi cadastrada no POL1333.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
     
   RETURN TRUE

END FUNCTION   


#-----------------------------------#
FUNCTION pol1328_le_val_tolerancia()#
#-----------------------------------#  
    
   SELECT val_valor
     INTO m_val_tol
     FROM gi_param_integracao_912
    WHERE cod_parametro = 'VALOR_TOL_DIF_AD_AP'
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela gi_param_integracao_912.VALOR_TOL_DIF_AD_AP '
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'Par�metro VALOR_TOL_DIF_AD_AP n�o cadastrado no POL1333.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
      LET m_val_tol = 0
   END IF
     
   RETURN TRUE

END FUNCTION   
#------------------------------------#
FUNCTION pol1328_valida_tip_despesa()#
#------------------------------------#

   SELECT 1
     FROM tipo_despesa
    WHERE cod_empresa = mr_nota.cod_empresa
      AND cod_tip_despesa = mr_nota.cod_tip_despesa

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela tipo_despesa, para valida��o do mesmo.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'O tipo de despesa do campo gi_ad_912.cod_tip_despesa n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1328_valida_moeda()#
#------------------------------#

   SELECT den_moeda
     FROM moeda
    WHERE cod_moeda = mr_nota.cod_moeda

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela moeda, para valida��o da mesma.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'A moeda do campo gi_ad_912.cod_moeda n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1328_valida_tributos()#
#---------------------------------#

   #IF mr_nota.ies_da_bc_ipi IS NULL THEN
      LET mr_nota.ies_da_bc_ipi = 'P'
   #END IF
      
   IF mr_nota.cod_incid_ipi IS NULL OR 
         mr_nota.cod_incid_ipi = 0 THEN
      LET mr_nota.cod_incid_ipi = '1'
   END IF

   #IF mr_nota.ies_tip_incid_ipi IS NULL THEN
      LET mr_nota.ies_tip_incid_ipi = 'I'
   #END IF

   IF mr_nota.pct_ipi_declarad IS NULL THEN
      LET mr_nota.pct_ipi_declarad = 0
   END IF

   IF mr_nota.val_base_c_ipi_it IS NULL THEN
      LET mr_nota.val_base_c_ipi_it = 0
   END IF

   IF mr_nota.val_ipi_decl_item IS NULL THEN
      LET mr_nota.val_ipi_decl_item = 0
   END IF

   IF mr_nota.val_ipi_desp_aces IS NULL THEN
      LET mr_nota.val_ipi_desp_aces = 0
   END IF

   IF mr_nota.val_base_c_item_d IS NULL THEN
      LET mr_nota.val_base_c_item_d = 0
   END IF

   #IF mr_nota.pct_icms_item_d IS NULL THEN
      LET mr_nota.pct_icms_item_d = 0
   #END IF

   #IF mr_nota.val_icms_item_d IS NULL THEN
      #22/07/19 - n�o gravar valor de icms
      LET mr_nota.val_icms_item_d = 0
   #END IF

   IF mr_nota.pct_red_bc_item_d IS NULL THEN
      LET mr_nota.pct_red_bc_item_d = 0
   END IF

   IF mr_nota.val_base_c_icms_da IS NULL THEN
      LET mr_nota.val_base_c_icms_da = 0
   END IF

   IF mr_nota.val_icms_desp_aces IS NULL THEN
      LET mr_nota.val_icms_desp_aces = 0
   END IF

   #IF mr_nota.ies_incid_icms_ite IS NULL THEN
      LET mr_nota.ies_incid_icms_ite = 'N'
   #END IF

   IF mr_nota.val_base_pis_d IS NULL THEN
      LET mr_nota.val_base_pis_d = 0
   END IF

   IF mr_nota.val_base_cofins_d IS NULL THEN
      LET mr_nota.val_base_cofins_d = 0
   END IF

   IF mr_nota.pct_pis_item_d IS NULL THEN
      LET mr_nota.pct_pis_item_d = 0
   END IF

   IF mr_nota.pct_cofins_item_d IS NULL THEN
      LET mr_nota.pct_cofins_item_d = 0
   END IF

   IF mr_nota.val_pis_d IS NULL THEN
      LET mr_nota.val_pis_d = 0
   END IF

   IF mr_nota.val_cofins_d IS NULL THEN
      LET mr_nota.val_cofins_d = 0
   END IF

   RETURN TRUE   

END FUNCTION

#-------------------------------------#
FUNCTION pol1328_consiste_ad_valores()#
#-------------------------------------#

   DEFINE l_valor     DECIMAL(15,2),
          l_tip_val   INTEGER
   
   DECLARE cq_ad_valores CURSOR FOR
    SELECT cod_tip_valor, valor
      FROM gi_ad_valores_912
     WHERE id_ad = mr_nota.id_ad
       AND valor > 0
   
   FOREACH cq_ad_valores INTO l_tip_val, l_valor

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo cursor cq_ad_valores, ',
              'para valida��o dos campos da tabela gi_ad_valores_912.'
         RETURN FALSE
      END IF
   
      IF l_valor <= 0 THEN
         LET m_msg = 'O valor do campo gi_ad_valores_912.valor n�o � v�lido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1328_consite_ad_tip_valor(l_tip_val) THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#-----------------------------------------------#
FUNCTION pol1328_consite_ad_tip_valor(l_tip_val)#
#-----------------------------------------------#
   
   DEFINE l_tip_val      INTEGER,
          l_ies_ad_ap    CHAR(01)
          
   SELECT ies_ad_ap 
     INTO l_ies_ad_ap
     FROM tipo_valor
    WHERE cod_empresa = mr_nota.cod_empresa
      AND cod_tip_val = l_tip_val

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela tipo_valor, ',
           'para valida��o do tipo de valor da AD.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'O tipo de valor do campo gi_ad_valores_912.cod_tip_valor n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
    
   IF l_ies_ad_ap = '1' THEN
   ELSE
      LET m_msg = 'O tipo de valor do campo gi_ad_valores_912.cod_tip_valor n�o � v�lido.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1328_consiste_ad_aen()#
#---------------------------------#

   DEFINE l_valor     DECIMAL(15,2)
   
   DECLARE cq_ad_aen CURSOR FOR
    SELECT val_aen
      FROM gi_ad_aen_912
     WHERE id_ad = mr_nota.id_ad
   
   FOREACH cq_ad_aen INTO l_valor

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo cursor cq_ad_aen, ',
              'para valida��o dos campos da tabela gi_ad_aen_912.'
         RETURN FALSE
      END IF
   
      IF l_valor <= 0 THEN
         LET m_msg = 'O valor do campo gi_ad_aen_912.val_aen n�o � v�lido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1328_consiste_ap()#
#-----------------------------#

   DEFINE l_valor     DECIMAL(15,2),
          l_id_ap     INTEGER,
          l_ies_ap    SMALLINT,
          l_min_venc  DATE,
          l_fornec    CHAR(15),
          l_favorec   CHAR(15),
          l_val_ap    DECIMAL(12,2),
          l_difer     DECIMAL(12,2),
          l_count     INTEGER,
          l_cod_for   CHAR(15)

   LET l_ies_ap = FALSE
   LET l_val_ap = 0
   LET m_min_dat_venct_ap = NULL
   
   DECLARE cq_ap CURSOR FOR
    SELECT id_ap, val_nom_ap, 
           dt_vencimento,
           cod_fornecedor, 
           cod_favorecido,
           cod_banco_fav,      
           num_agencia_fav,    
           num_conta_banco_fav
      FROM gi_ap_912
     WHERE id_ad = mr_nota.id_ad
     ORDER BY dt_vencimento
   
   FOREACH cq_ap INTO 
      l_id_ap, 
      l_valor, 
      l_min_venc, 
      l_fornec, 
      l_favorec,
      mr_gi_ap.cod_banco_fav,     
      mr_gi_ap.num_agencia_fav,   
      mr_gi_ap.num_conta_banco_fav

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo cursor cq_ap, ',
              'para valida��o dos campos da tabela gi_ap_912.'
         RETURN FALSE
      END IF
      
      LET l_cod_for = NULL
      
      IF l_favorec IS NOT NULL THEN
         LET l_cod_for = l_favorec
      ELSE
         IF l_fornec IS NOT NULL THEN
            LET l_cod_for = l_fornec
         END IF
      END IF
      
      IF l_cod_for IS NOT NULL THEN
         IF mr_gi_ap.cod_banco_fav IS NOT NULL AND
            mr_gi_ap.num_agencia_fav IS NOT NULL AND
            mr_gi_ap.num_conta_banco_fav IS NOT NULL THEN
            SELECT COUNT(*) INTO l_count
              FROM cap_info_bancaria
             WHERE fornecedor = l_cod_for
               AND banco = mr_gi_ap.cod_banco_fav
               AND agencia = mr_gi_ap.num_agencia_fav
               AND cta_bancaria = mr_gi_ap.num_conta_banco_fav
            IF STATUS <> 0 THEN
               LET m_erro = STATUS USING '<<<<<'
               LET m_msg = 'Erro de status: ',m_erro
               LET m_msg = m_msg CLIPPED, ' lendo tabela cap_info_bancaria, '
               RETURN FALSE
            END IF
            
            IF l_count = 0 THEN
               LET m_msg = 'Dados ban�rios enviados n�o s�o do fornecedor/favorecido'
               IF NOT pol1328_grava_erro() THEN
                  RETURN FALSE
               END IF            
            END IF
         ELSE
            IF mr_gi_ap.cod_banco_fav IS NOT NULL THEN
               IF mr_gi_ap.num_agencia_fav IS NULL OR mr_gi_ap.num_conta_banco_fav IS NULL THEN
                  LET m_msg = 'Dados ban�rios da tabela gi_ap_9a2 est�o imcompletos'
                  IF NOT pol1328_grava_erro() THEN
                     RETURN FALSE
                  END IF            
               END IF
            ELSE
               IF mr_gi_ap.num_agencia_fav IS NOT NULL OR mr_gi_ap.num_conta_banco_fav IS NOT NULL THEN
                  LET m_msg = 'Dados ban�rios da tabela gi_ap_9a2 est�o imcompletos'
                  IF NOT pol1328_grava_erro() THEN
                     RETURN FALSE
                  END IF            
               END IF            
            END IF
         END IF
      END IF
            
      LET l_val_ap = l_val_ap + l_valor
      
      IF m_min_dat_venct_ap IS NULL THEN
         LET m_min_dat_venct_ap = l_min_venc
      END IF
      
      LET l_ies_ap = TRUE       
      
      IF l_valor <= 0 THEN
         LET m_msg = 'O valor do campo gi_ap_912.val_nom_ap n�o � v�lido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF l_fornec IS NOT NULL THEN
         IF NOT pol1328_checa_for_ap(l_fornec) THEN
            RETURN FALSE
         END IF
      END IF

      IF l_favorec IS NOT NULL THEN
         IF NOT pol1328_checa_for_ap(l_favorec) THEN
            RETURN FALSE
         END IF
      END IF
         
      IF NOT pol1328_consiste_ap_valores(l_id_ap) THEN
         RETURN FALSE
      END IF      

   END FOREACH

   IF NOT l_ies_ap THEN
      LET m_msg = 'O GI n�o enviou AP da obriga��o ',mr_nota.cod_obrigacao
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET l_difer = mr_nota.val_tot_nf - l_val_ap
   
   IF l_difer < 0 THEN
      LET l_difer = l_difer * (-1)
   END IF
   
   IF NOT pol1328_le_val_tolerancia() THEN 
      RETURN FALSE
   END IF
   
   #IF m_val_tol > 0 THEN
      IF l_difer > m_val_tol THEN
         LET m_msg = 'Soma dos valores da AP n�o bate com o valor da AD'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   #END IF

   RETURN TRUE

END FUNCTION   

#--------------------------------------#
FUNCTION pol1328_checa_for_ap(l_codigo)#
#--------------------------------------#

   DEFINE l_codigo        CHAR(15),
          l_ies_ativo     CHAR(01)
   
   SELECT ies_fornec_ativo
     INTO l_ies_ativo
     FROM fornecedor
    WHERE cod_fornecedor = l_codigo

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela fornecedor, para valida��o do mesmo na AP'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'Fornecedor/favorecido enviado na GI_AP n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF l_ies_ativo = 'A' THEN
      ELSE
         LET m_msg = 'Fornecedor ', l_codigo CLIPPED, 'inativo no Logix'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION
    
#--------------------------------------------#
FUNCTION pol1328_consiste_ap_valores(l_id_ap)#
#--------------------------------------------#

   DEFINE l_valor     DECIMAL(15,2),
          l_id_ap     INTEGER,
          l_tip_val   INTEGER,
          l_ies_ad_ap CHAR(01)
   
   DECLARE cq_ap_valores CURSOR FOR
    SELECT cod_tip_valor, valor
      FROM gi_ap_valores_912
     WHERE id_ad = mr_nota.id_ad
       AND id_ap = l_id_ap
       AND valor > 0
   
   FOREACH cq_ap_valores INTO l_tip_val, l_valor

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo cursor cq_ap_valores, ',
              'para valida��o dos campos da tabela gi_ap_valores_912.'
         RETURN FALSE
      END IF
   
      IF l_valor <= 0 THEN
         LET m_msg = 'O valor do campo gi_ap_912.val_nom_ap n�o � v�lido.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol1328_consite_ap_tip_valor(l_tip_val) THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION   

#-----------------------------------------------#
FUNCTION pol1328_consite_ap_tip_valor(l_tip_val)#
#-----------------------------------------------#
   
   DEFINE l_tip_val      INTEGER,
          l_ies_ad_ap    CHAR(01)
          
   SELECT ies_ad_ap 
     INTO l_ies_ad_ap
     FROM tipo_valor
    WHERE cod_empresa = mr_nota.cod_empresa
      AND cod_tip_val = l_tip_val

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela tipo_valor, para valida��o do mesmo.'
      RETURN FALSE
   END IF
            
   IF STATUS = 100 THEN
      LET m_msg = 'O tipo de valor do campo gi_ap_valores_912.cod_tip_valor n�o existe no Logix.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
    
   IF l_ies_ad_ap = '2' THEN
   ELSE
      LET m_msg = 'O tipo de valor do campo gi_ap_valores_912.cod_tip_valor n�o � v�lido.'
      IF NOT pol1328_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1328_gera_ser_ssr()#
#------------------------------#
   
   DEFINE l_ser_nf      LIKE ad_mestre.ser_nf,
          l_ssr_nf      LIKE ad_mestre.ssr_nf,
          l_num_nf      LIKE ad_mestre.num_nf,
          l_ser_int     INTEGER,
          l_nf_int      INTEGER
   
   LET l_ser_int = 0
   LET l_nf_int = mr_nota.num_nf
   LET l_num_nf = l_nf_int
   
   DECLARE cq_ser CURSOR FOR          
   SELECT ser_nf 
     FROM ad_mestre 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_fornecedor = mr_nota.cod_fornecedor
      AND num_nf = l_num_nf
      AND ( ser_nf >= '0' and ser_nf <= '99' )
    ORDER BY ser_nf DESC
    
   FOREACH cq_ser INTO l_ser_nf

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo maior s�rie da NF na tabela ad_mestre.'
         RETURN FALSE
      END IF
      
      LET l_ser_int = l_ser_nf
      EXIT FOREACH
      
   END FOREACH
   
   IF l_ser_int = 0 THEN
      LET mr_nota.ser_nf = '1'
      LET mr_nota.ssr_nf = 0
      RETURN TRUE
   END IF
      
   SELECT max(ssr_nf) 
     INTO l_ssr_nf
     FROM ad_mestre 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_fornecedor = mr_nota.cod_fornecedor
      AND num_nf = l_num_nf
      AND ser_nf = l_ser_nf

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo maior sub-s�rie da NF na tabela ad_mestre.'
      RETURN FALSE
   END IF
   
   IF l_ssr_nf IS NULL THEN
      LET l_ssr_nf = 1
   END IF

   IF l_ssr_nf < 99 THEN
      LET l_ssr_nf = l_ssr_nf + 1
   ELSE
      IF l_ser_int < 99 THEN
         LET l_ser_int = l_ser_int + 1
         LET l_ser_nf = l_ser_int
         LET l_ssr_nf = 1
      ELSE
         LET m_msg = 'O limite de 99 para s�rie e 99 para sub-serie j� foi atingido p/ a NF enviada.'
         IF NOT pol1328_grava_erro() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF      
   END IF
   
   LET mr_nota.ser_nf = l_ser_nf
   LET mr_nota.ssr_nf = l_ssr_nf
   
   RETURN TRUE
   
END FUNCTION
        
#---------------------------#
FUNCTION pol1328_gera_nota()#
#---------------------------#
      
   IF NOT pol1328_gera_num_ar() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_nf_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_nf_sup_par_ar() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1328_ins_aviso_rec() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1328_ins_aviso_rec_compl() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1328_ins_audit_ar() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_dest_ar() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_ar_seq() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_par_ar() THEN
      RETURN FALSE
   END IF
   
   IF mr_nota.val_cofins_d > 0 OR mr_nota.val_pis_d > 0 THEN   
      #22/07/19 - n�o gravar pis/cofins
      #IF NOT pol1328_is_ar_pis_cofins() THEN
      #   RETURN FALSE
      #END IF
   END IF
   
   #22/07/19 - gravar lan�amentos cont�beis
   
   IF NOT pol1328_contabiliza() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1328_ins_nf_sup()#
#----------------------------#
   
   DEFINE l_ies_incl_cap CHAR(01)
   
   IF mr_nota.ies_gera_nota = 'S' THEN
      LET l_ies_incl_cap = 'S'
   ELSE
      LET l_ies_incl_cap = 'N'
   END IF
   
   LET mr_nf_sup.cod_empresa         = p_cod_empresa       
   LET mr_nf_sup.cod_empresa_estab   = NULL
   LET mr_nf_sup.num_nf              = mr_nota.num_nf
   LET mr_nf_sup.ser_nf              = mr_nota.ser_nf
   LET mr_nf_sup.ssr_nf              = mr_nota.ssr_nf
   LET mr_nf_sup.ies_especie_nf      = m_ies_especie_nf
   LET mr_nf_sup.cod_fornecedor      = mr_nota.cod_fornecedor
   LET mr_nf_sup.num_conhec          = 0
   LET mr_nf_sup.ser_conhec          = ' '
   LET mr_nf_sup.ssr_conhec          = 0
   LET mr_nf_sup.cod_transpor        = '0'
   LET mr_nf_sup.num_aviso_rec       = m_num_prx_ar
   LET mr_nf_sup.dat_emis_nf         = m_dat_emissao
   LET mr_nf_sup.dat_entrada_nf      = m_dat_recebto
   LET mr_nf_sup.cod_regist_entrada  = 1
   LET mr_nf_sup.val_tot_nf_d        = mr_nota.val_tot_nf
   LET mr_nf_sup.val_tot_nf_c        = mr_nf_sup.val_tot_nf_d
   LET mr_nf_sup.val_tot_icms_nf_d   = mr_nota.val_icms_item_d
   LET mr_nf_sup.val_tot_icms_nf_c   = 0
   LET mr_nf_sup.val_tot_desc        = 0
   LET mr_nf_sup.val_tot_acresc      = 0
   LET mr_nf_sup.val_ipi_nf          = mr_nota.val_ipi_decl_item
   LET mr_nf_sup.val_ipi_calc        = 0
   LET mr_nf_sup.val_despesa_aces    = 0
   LET mr_nf_sup.val_adiant          = 0
   LET mr_nf_sup.ies_tip_frete       = '0'
   LET mr_nf_sup.cnd_pgto_nf         = m_cnd_pgto
   LET mr_nf_sup.cod_mod_embar       = 3
   LET mr_nf_sup.ies_nf_com_erro     = 'N'
   LET mr_nf_sup.nom_resp_aceite_er  = mr_nota.cod_usuario
   LET mr_nf_sup.ies_incl_cap        = l_ies_incl_cap
   LET mr_nf_sup.ies_incl_contab     = 'N' 
   LET mr_nf_sup.cod_operacao        = m_cfop
   LET mr_nf_sup.ies_calc_subst      = ' '
   LET mr_nf_sup.val_bc_subst_d      = 0
   LET mr_nf_sup.val_icms_subst_d    = 0
   LET mr_nf_sup.val_bc_subst_c      = 0
   LET mr_nf_sup.val_icms_subst_c    = 0
   LET mr_nf_sup.cod_imp_renda       = NULL
   LET mr_nf_sup.val_imp_renda       = 0
   LET mr_nf_sup.ies_situa_import    = ' '
   LET mr_nf_sup.val_bc_imp_renda    = 0
   LET mr_nf_sup.ies_nf_aguard_nfe   = '1'
                    
   INSERT INTO nf_sup VALUES(mr_nf_sup.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela nf_sup.'
      RETURN FALSE
   END IF

   INSERT INTO vencimento_nff(
      cod_empresa,      
      cod_empresa_estab,          
      num_nf,                     
      ser_nf,                     
      ssr_nf,                     
      espc_nota_fiscal,           
      cod_fornecedor,             
      num_docum,                  
      val_docum,                  
      dat_vencto)
   VALUES(mr_nf_sup.cod_empresa,         
          mr_nf_sup.cod_empresa_estab,
          mr_nf_sup.num_nf,           
          mr_nf_sup.ser_nf,           
          mr_nf_sup.ssr_nf,           
          mr_nf_sup.ies_especie_nf,   
          mr_nf_sup.cod_fornecedor,       
          mr_nf_sup.num_nf,
          mr_nf_sup.val_tot_nf_d,
          m_dat_vencto)       

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela vencimento_nff.'
      RETURN FALSE
   END IF

   {INSERT INTO nf_sup_erro
        VALUES (p_cod_empresa,
                m_num_prx_ar,
                0,
                'FALTA CONSISTIR A NOTA FISCAL',
                '4',
                'N',
                0)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela nf_sup_erro.'
      RETURN FALSE
   END IF}
        
   RETURN TRUE

END FUNCTION   
                 
#-----------------------------#
 FUNCTION pol1328_gera_num_ar()
#-----------------------------#

   SELECT par_val
     INTO m_num_prx_ar
     FROM par_sup_pad
    WHERE cod_empresa   = mr_nota.cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo n�mero do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   UPDATE par_sup_pad
      SET par_val = (par_val + 1)
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' Atualizando n�mero do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1328_ins_aviso_rec()#
#-------------------------------#
   
   LET mr_aviso.cod_empresa        = mr_nf_sup.cod_empresa
   LET mr_aviso.cod_empresa_estab  = mr_nf_sup.cod_empresa_estab
   LET mr_aviso.num_aviso_rec      = mr_nf_sup.num_aviso_rec
   LET mr_aviso.num_seq            = 1
   LET mr_aviso.cod_item           = m_cod_item
   LET mr_aviso.den_item           = mr_nota.den_item
   LET mr_aviso.dat_inclusao_seq   = mr_nf_sup.dat_entrada_nf
   LET mr_aviso.ies_situa_ar       = 'E'
   LET mr_aviso.ies_incl_almox     = 'N'
   LET mr_aviso.ies_receb_fiscal   = 'S'
   LET mr_aviso.ies_liberacao_ar   = '1'
   LET mr_aviso.ies_liberacao_cont = 'S'
   LET mr_aviso.ies_liberacao_insp = 'S'
   LET mr_aviso.ies_diverg_listada = 'N'

   IF NOT pol1328_le_item() THEN
      RETURN FALSE
   END IF

   LET mr_aviso.num_pedido         = NULL   
   LET mr_aviso.num_oc             = NULL
   LET mr_aviso.pre_unit_nf        = mr_nf_sup.val_tot_nf_d
   LET mr_aviso.val_despesa_aces_i = 0
   LET mr_aviso.ies_da_bc_ipi      = mr_nota.ies_da_bc_ipi
   LET mr_aviso.cod_incid_ipi      = 1 #mr_nota.cod_incid_ipi
   LET mr_aviso.ies_tip_incid_ipi  = mr_nota.ies_tip_incid_ipi
   LET mr_aviso.pct_direito_cred   = 100
   LET mr_aviso.pct_ipi_declarad   =  mr_nota.pct_ipi_declarad 
   LET mr_aviso.pct_ipi_tabela     = 0
   LET mr_aviso.ies_bitributacao   = 'N'
   LET mr_aviso.val_base_c_ipi_it  = mr_nota.val_base_c_ipi_it
   LET mr_aviso.val_base_c_ipi_da  = 0
   LET mr_aviso.val_ipi_decl_item  = mr_nota.val_ipi_decl_item
   LET mr_aviso.val_ipi_calc_item  = 0
   LET mr_aviso.val_ipi_desp_aces  = mr_nota.val_ipi_desp_aces
   LET mr_aviso.val_desc_item      = 0
   LET mr_aviso.val_liquido_item   = mr_nf_sup.val_tot_nf_d
   LET mr_aviso.val_contabil_item  = mr_aviso.val_liquido_item
   LET mr_aviso.qtd_declarad_nf    = 1
   LET mr_aviso.qtd_recebida       = 1
   LET mr_aviso.qtd_devolvid       = 0
   LET mr_aviso.dat_devoluc        = NULL
   LET mr_aviso.val_devoluc        = 0
   LET mr_aviso.num_nf_dev         = 0
   LET mr_aviso.qtd_rejeit         = 0
   LET mr_aviso.qtd_liber          = 1
   LET mr_aviso.qtd_liber_excep    = 0
   LET mr_aviso.cus_tot_item       = 0
   
   LET p_cod_fiscal = m_prefixo, '.', p_cod_fiscal CLIPPED  
   LET mr_aviso.cod_fiscal_item    = p_cod_fiscal
   
   LET mr_aviso.num_lote           = NULL
   LET mr_aviso.cod_operac_estoq   = ' '
   LET mr_aviso.val_base_c_item_d  = 0
   LET mr_aviso.val_base_c_item_c  = mr_aviso.val_liquido_item
   LET mr_aviso.pct_icms_item_d    = mr_nota.pct_icms_item_d
   LET mr_aviso.pct_icms_item_c    = mr_nota.pct_icms_item_d
   LET mr_aviso.pct_red_bc_item_d  = mr_nota.pct_red_bc_item_d
   LET mr_aviso.pct_red_bc_item_c  = 0
   LET mr_aviso.pct_diferen_item_d = 0
   LET mr_aviso.pct_diferen_item_c = 0
   LET mr_aviso.val_icms_item_d    = mr_nota.val_icms_item_d
   LET mr_aviso.val_icms_item_c    = mr_nota.val_icms_item_d
   LET mr_aviso.val_base_c_icms_da = mr_nota.val_base_c_icms_da
   LET mr_aviso.val_icms_diferen_i = 0
   LET mr_aviso.val_icms_desp_aces = mr_nota.val_icms_desp_aces

   #IF mr_aviso.val_icms_item_d > 0   THEN
   #   LET mr_aviso.ies_incid_icms_ite  =   "C"         
   #ELSE
   #   LET mr_aviso.ies_incid_icms_ite  =   "I"         
   #END IF 
   
   LET mr_aviso.ies_incid_icms_ite = mr_nota.ies_incid_icms_ite
   
   LET mr_aviso.val_frete          = 0
   LET mr_aviso.val_icms_frete_d   = 0
   LET mr_aviso.val_icms_frete_c   = 0
   LET mr_aviso.val_base_c_frete_d = 0
   LET mr_aviso.val_base_c_frete_c = 0
   LET mr_aviso.val_icms_diferen_f = 0
   LET mr_aviso.pct_icms_frete_d   = 0
   LET mr_aviso.pct_icms_frete_c   = 0
   LET mr_aviso.pct_red_bc_frete_d = 0
   LET mr_aviso.pct_red_bc_frete_c = 0
   LET mr_aviso.pct_diferen_fret_d = 0
   LET mr_aviso.pct_diferen_fret_c = 0
   LET mr_aviso.val_acrescimos     = 0
   LET mr_aviso.val_enc_financ     = 0
   LET mr_aviso.ies_contabil       = 'S' 
   LET mr_aviso.ies_total_nf       = 'S'
   LET mr_aviso.val_compl_estoque  = 0
   LET mr_aviso.dat_ref_val_compl  = NULL
   LET mr_aviso.pct_enc_financ     = 0
   LET mr_aviso.cod_cla_fisc_nf    = ' ' #mr_aviso.cod_cla_fisc
   LET mr_aviso.cod_tip_despesa    = mr_nota.cod_tip_despesa
   LET mr_aviso.observacao         = NULL

   INSERT INTO aviso_rec VALUES(mr_aviso.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
 FUNCTION pol1328_acerta_cfop()#
#------------------------------#

   DEFINE i, j          SMALLINT,
          p_cod_fiscal2 CHAR(07)
   
   IF m_cfop IS NULL THEN
      RETURN 
   END IF
   
   LET p_cod_fiscal = m_cfop
   LET p_cod_fiscal2 = NULL
   
   LET i                  = 0
   LET j                  = 0

   FOR i = 1 TO LENGTH(p_cod_fiscal)
      IF  p_cod_fiscal[i] MATCHES '[0123456789]' THEN   
          LET j  =  j  +  1
          IF j  =   1  THEN
             IF p_cod_fiscal[i] = "7" THEN 
                LET p_cod_fiscal2[j] = "3"    
                LET m_cfop[1] = '3'  
                LET m_prefixo = '3'
             ELSE
                IF p_cod_fiscal[i] = "6" THEN 
                   LET p_cod_fiscal2[j] = "2" 
                   LET m_cfop[1] = '6'   
                   LET m_prefixo = '2'  
                ELSE
                   LET p_cod_fiscal2[j] = "1"   
                   LET m_cfop[1] = '5'   
                   LET m_prefixo = '1'
                END IF
             END IF
             LET j  =  j  +  1
             LET p_cod_fiscal2[j] = "."      
          ELSE
             LET p_cod_fiscal2[j] = p_cod_fiscal[i] 
          END IF
      END IF
   END FOR

   LET p_cod_fiscal = p_cod_fiscal2 CLIPPED
 
END FUNCTION                                                                   

#-----------------------------------#
FUNCTION pol1328_ins_nf_sup_par_ar()#
#-----------------------------------#

   DEFINE lr_sup_par        RECORD LIKE sup_par_ar.*
   DEFINE l_parametro_txt   LIKE sup_par_ar.parametro_texto
   
   LET l_parametro_txt = EXTEND(m_dat_emissao, YEAR TO DAY)
   LET l_parametro_txt = l_parametro_txt CLIPPED, ' ', TIME
   
   LET lr_sup_par.empresa = p_cod_empresa         
   LET lr_sup_par.aviso_recebto = mr_nf_sup.num_aviso_rec   
   LET lr_sup_par.seq_aviso_recebto = 0
   
   LET lr_sup_par.parametro = 'data_hora_nf_entrada'
   LET lr_sup_par.par_ind_especial = ' '
   LET lr_sup_par.parametro_texto = l_parametro_txt
   LET lr_sup_par.parametro_val = NULL   
   LET lr_sup_par.parametro_dat = NULL   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:data_hora_nf_entrada'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'meio_transp_ar'
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 1 

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:meio_transp_ar'
      RETURN FALSE
   END IF
   
   IF mr_nota.num_nf_dig IS NOT NULL THEN
      LET lr_sup_par.parametro = 'num_nf_eletronica'
      LET lr_sup_par.parametro_val = mr_nota.num_nf_dig 

      INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 
             ' inserindo registro na tabela sup_par_ar:meio_transp_ar'
         RETURN FALSE
      END IF

   END IF

   LET lr_sup_par.parametro = 'secao_resp_aprov'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = m_cod_uni_funcio
   LET lr_sup_par.parametro_val = NULL   
   LET lr_sup_par.parametro_dat = NULL   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:secao_resp_aprov'
      RETURN FALSE
   END IF
{
   LET lr_sup_par.parametro = 'di_simplificada'
   LET lr_sup_par.par_ind_especial = '0'
   LET lr_sup_par.parametro_texto = ''
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = NULL   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:di_simplificada'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'val_frete'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:val_frete'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'val_pis_cofins'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:val_pis_cofins'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'aprop_ativ_imob'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:aprop_ativ_imob'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'ressarc_subst_trib'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:ressarc_subst_trib'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'trans_credito'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:trans_credito'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'compl_nfs_icms'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:compl_nfs_icms'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'serv_nao_trib'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:serv_nao_trib'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'nsu'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = TRUNC(SYSDATE)   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:nsu'
      RETURN FALSE
   END IF
   
 }  
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1328_ins_par_ar()#
#----------------------------#

   DEFINE lr_sup_par        RECORD LIKE sup_par_ar.*
   
   LET lr_sup_par.empresa = p_cod_empresa         
   LET lr_sup_par.aviso_recebto = mr_aviso.num_aviso_rec
   LET lr_sup_par.seq_aviso_recebto = mr_aviso.num_seq
   
   LET lr_sup_par.parametro = 'desconto_fiscal'
   LET lr_sup_par.par_ind_especial = NULL
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = 0   
   LET lr_sup_par.parametro_dat = NULL   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:desconto_fiscal'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'bc_dif_aliq_icms'
   LET lr_sup_par.parametro_val = mr_aviso.pre_unit_nf   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:bc_dif_aliq_icms'
      RETURN FALSE
   END IF

   #IF mr_nota.val_icms_item_d > 0 THEN
      LET lr_sup_par.parametro = 'bc_icms_sem_red_fix'
      LET lr_sup_par.parametro_val = mr_nota.val_tot_nf  
   
      INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 
             ' inserindo registro na tabela sup_par_ar:bc_icms_sem_red_fix'
         RETURN FALSE
      END IF

      LET lr_sup_par.parametro = 'val_icms_sem_red_fix'
      LET lr_sup_par.parametro_val = mr_nota.val_icms_item_d  
   
      INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 
             ' inserindo registro na tabela sup_par_ar:val_icms_sem_red_fix'
         RETURN FALSE
      END IF

      LET lr_sup_par.parametro = 'pct_icms_sem_red_fix'
      LET lr_sup_par.parametro_val = mr_nota.pct_icms_item_d  
   
      INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 
             ' inserindo registro na tabela sup_par_ar:pct_icms_sem_red_fix'
         RETURN FALSE
      END IF
   
   #END IF

   #ver
   LET lr_sup_par.parametro = 'cod_cst_IPI'
   LET lr_sup_par.par_ind_especial = 'A'
   LET lr_sup_par.parametro_texto = '431'
   LET lr_sup_par.parametro_val = 49   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:cod_cst_IPI'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'cod_cst_PIS'
   LET lr_sup_par.par_ind_especial = 'A'
   LET lr_sup_par.parametro_texto = '424'
   LET lr_sup_par.parametro_val = 70   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:cod_cst_IPI'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'cod_cst_COFINS'
   LET lr_sup_par.par_ind_especial = 'A'
   LET lr_sup_par.parametro_texto = '429'
   LET lr_sup_par.parametro_val = 70   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:cod_cst_IPI'
      RETURN FALSE
   END IF

   LET lr_sup_par.parametro = 'NULL'
   LET lr_sup_par.par_ind_especial = 'U'
   LET lr_sup_par.parametro_texto = NULL
   LET lr_sup_par.parametro_val = NULL   

   INSERT INTO sup_par_ar VALUES(lr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:NULL'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1328_is_ar_pis_cofins()#
#----------------------------------#

   DEFINE lr_pis_cofins   RECORD LIKE ar_pis_cofins.*      
   
   LET lr_pis_cofins.cod_empresa = p_cod_empresa
   LET lr_pis_cofins.num_aviso_rec = mr_aviso.num_aviso_rec
   LET lr_pis_cofins.num_seq = mr_aviso.num_seq
   LET lr_pis_cofins.val_base_pis_d = mr_nota.val_base_pis_d
   LET lr_pis_cofins.val_base_cofins_d =  mr_nota.val_base_cofins_d
   LET lr_pis_cofins.pct_pis_item_d = mr_nota.pct_pis_item_d  
   LET lr_pis_cofins.pct_cofins_item_d = mr_nota.pct_cofins_item_d
   LET lr_pis_cofins.val_pis_d = mr_nota.val_pis_d        
   LET lr_pis_cofins.val_cofins_d = mr_nota.val_cofins_d     
   LET lr_pis_cofins.ies_base_calc = 'T'   
   
   INSERT INTO ar_pis_cofins VALUES(lr_pis_cofins.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela ar_pis_cofins'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#22/07/19 - daqui ... #

#-----------------------------#
FUNCTION pol1328_contabiliza()#
#-----------------------------#

   DEFINE lr_lanc_cont_rec     RECORD LIKE lanc_cont_rec.*,
          lr_ctb_lanc          RECORD LIKE ctb_lanc_ctbl_recb.*,
          lr_ctb_compl         RECORD LIKE ctb_compl_hist_rec.*
          
   DEFINE l_den_conta          LIKE plano_contas.den_conta,
          l_num_transac        LIKE lanc_cont_rec.num_transac,
          l_tex_hist_lanc      LIKE lanc_cont_rec.tex_hist_lanc
   
   DEFINE l_data               CHAR(10),
          l_periodo_contab     CHAR(04),
          l_segmto_periodo     DECIMAL(2,0),
          l_num_relac          INTEGER,
          l_seq_reg            INTEGER,
          l_txt                CHAR(50),
          l_nota               CHAR(09),
          l_aviso              CHAR(09)
   
   SELECT den_conta
     INTO l_den_conta 
     FROM plano_contas
    WHERE cod_empresa = '99'
      AND num_conta_reduz = mr_dest_ar.num_conta_deb_desp

   IF STATUS <> 0 THEN                                                
      LET m_erro = STATUS USING '<<<<<'                               
      LET m_msg = 'Erro de status: ',m_erro                           
      LET m_msg = m_msg CLIPPED, ' lendo plano_contas'            
      RETURN FALSE                                                    
   END IF                                                             
   
   SELECT MAX(num_transac) 
     INTO l_num_transac
     FROM lanc_cont_rec

   IF STATUS <> 0 THEN                                                
      LET m_erro = STATUS USING '<<<<<'                               
      LET m_msg = 'Erro de status: ',m_erro                           
      LET m_msg = m_msg CLIPPED, ' lendo lanc_cont_rec.num_transac'            
      RETURN FALSE                                                    
   END IF                                                             
   
   IF l_num_transac IS NULL THEN
      LET l_num_transac = 0
   END IF
   
   LET l_num_transac = l_num_transac + 1
   
   LET lr_lanc_cont_rec.cod_empresa     = mr_nf_sup.cod_empresa
   LET lr_lanc_cont_rec.num_nf          = mr_nf_sup.num_nf           
   LET lr_lanc_cont_rec.ser_nf          = mr_nf_sup.ser_nf           
   LET lr_lanc_cont_rec.ssr_nf          = mr_nf_sup.ssr_nf           
   LET lr_lanc_cont_rec.ies_especie     = mr_nf_sup.ies_especie_nf   
   LET lr_lanc_cont_rec.cod_fornecedor  = mr_nf_sup.cod_fornecedor   
   LET lr_lanc_cont_rec.ies_tipo_lanc 	= 'D'
   LET lr_lanc_cont_rec.num_conta_cont  = mr_dest_ar.num_conta_deb_desp
   LET lr_lanc_cont_rec.val_lanc        = mr_nf_sup.val_tot_nf_d
   
   LET l_tex_hist_lanc = l_den_conta CLIPPED, ' ',mr_nf_sup.num_aviso_rec USING '<<<<<<'
   LET l_tex_hist_lanc = l_tex_hist_lanc CLIPPED,'001'
   
   LET lr_lanc_cont_rec.tex_hist_lanc   = l_tex_hist_lanc
   LET lr_lanc_cont_rec.num_lote_lanc   = 0
   LET lr_lanc_cont_rec.ies_cnd_pgto    = 'S'
   LET lr_lanc_cont_rec.dat_base_cmi    = NULL
   LET lr_lanc_cont_rec.dat_lanc        = mr_nf_sup.dat_entrada_nf
   LET lr_lanc_cont_rec.cod_area_negocio= mr_dest_ar.cod_area_negocio
   LET lr_lanc_cont_rec.cod_lin_negocio = mr_dest_ar.cod_lin_negocio 
   LET lr_lanc_cont_rec.num_aviso_rec   = mr_dest_ar.num_aviso_rec
   LET lr_lanc_cont_rec.num_seq         = mr_dest_ar.num_seq      
   LET lr_lanc_cont_rec.ies_item_estoq  = 'N'
   LET lr_lanc_cont_rec.num_lote_pat    = 0
   LET lr_lanc_cont_rec.cod_seg_merc    = mr_dest_ar.cod_seg_merc
   LET lr_lanc_cont_rec.cod_cla_uso     = mr_dest_ar.cod_cla_uso 
   LET lr_lanc_cont_rec.num_transac     = l_num_transac
   
   INSERT INTO lanc_cont_rec VALUES(lr_lanc_cont_rec.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela lanc_cont_rec.conta_deb'
      RETURN FALSE
   END IF
   
   LET lr_lanc_cont_rec.num_transac = lr_lanc_cont_rec.num_transac + 1
   LET lr_lanc_cont_rec.ies_tipo_lanc 	= 'C'
   LET lr_lanc_cont_rec.num_conta_cont  = mr_tipo_despesa.num_conta_cred

   INSERT INTO lanc_cont_rec VALUES(lr_lanc_cont_rec.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela lanc_cont_rec.conta_cred'
      RETURN FALSE
   END IF

   LET l_data = EXTEND(m_dat_recebto, YEAR TO DAY)
   LET l_periodo_contab = l_data[1,4]
   LET l_segmto_periodo = l_data[6,7]

   SELECT MAX(num_relacionto) 
     INTO l_num_relac
     FROM ctb_lanc_ctbl_recb  
    WHERE empresa = p_cod_empresa  
      AND periodo_contab = l_periodo_contab 
      AND segmto_periodo = l_segmto_periodo
  
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo relacionamento da tabela ctb_lanc_ctbl_recb'
      RETURN FALSE
   END IF
   
   IF l_num_relac IS NULL THEN
      LET l_num_relac = 0
   END IF
   
   LET l_num_relac = l_num_relac + 1

   SELECT MAX(sequencia_registro) 
     INTO l_seq_reg
     FROM ctb_lanc_ctbl_recb  
    WHERE empresa = lr_lanc_cont_rec.cod_empresa
      AND periodo_contab = l_periodo_contab
      AND segmto_periodo = l_segmto_periodo

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo sequnc registro da tabela ctb_lanc_ctbl_recb'
      RETURN FALSE
   END IF
   
   IF l_seq_reg IS NULL THEN
      LET l_seq_reg = 0
   END IF
   
   LET l_seq_reg = l_seq_reg + 1
   
   LET lr_ctb_lanc.empresa                = lr_lanc_cont_rec.cod_empresa
   LET lr_ctb_lanc.periodo_contab         = l_periodo_contab
   LET lr_ctb_lanc.segmto_periodo         = l_segmto_periodo
   LET lr_ctb_lanc.cta_deb                = mr_dest_ar.num_conta_deb_desp
   LET lr_ctb_lanc.cta_cre                = '0'
   LET lr_ctb_lanc.dat_movto              = lr_lanc_cont_rec.dat_lanc
   LET lr_ctb_lanc.dat_vencto             = NULL
   LET lr_ctb_lanc.dat_conversao          = NULL
   LET lr_ctb_lanc.val_lancto             = lr_lanc_cont_rec.val_lanc
   LET lr_ctb_lanc.qtd_outra_moeda        = 0
   LET lr_ctb_lanc.hist_padrao            = 767
   LET lr_ctb_lanc.compl_hist             = 'S'
   LET lr_ctb_lanc.linha_produto          = lr_lanc_cont_rec.cod_area_negocio
   LET lr_ctb_lanc.linha_receita          = lr_lanc_cont_rec.cod_lin_negocio 
   LET lr_ctb_lanc.segmto_mercado         = lr_lanc_cont_rec.cod_seg_merc
   LET lr_ctb_lanc.classe_uso             = lr_lanc_cont_rec.cod_cla_uso 
   LET lr_ctb_lanc.num_relacionto         = l_num_relac
   LET lr_ctb_lanc.lote_contab            = 0
   LET lr_ctb_lanc.num_lancto             = 0
   LET lr_ctb_lanc.empresa_origem         = lr_lanc_cont_rec.cod_empresa
   LET lr_ctb_lanc.sequencia_registro     = l_seq_reg
   LET lr_ctb_lanc.nota_fiscal            = lr_lanc_cont_rec.num_nf        
   LET lr_ctb_lanc.serie_nota_fiscal      = lr_lanc_cont_rec.ser_nf        
   LET lr_ctb_lanc.subserie_nf            = lr_lanc_cont_rec.ssr_nf        
   LET lr_ctb_lanc.espc_nota_fiscal       = lr_lanc_cont_rec.ies_especie   
   LET lr_ctb_lanc.fornec_nota_fiscal     = lr_lanc_cont_rec.cod_fornecedor
   LET lr_ctb_lanc.aviso_recebto          = lr_lanc_cont_rec.num_aviso_rec
   LET lr_ctb_lanc.seq_aviso_recebto      = lr_lanc_cont_rec.num_seq      
   LET lr_ctb_lanc.tip_nota_fiscal        = 1       
   LET lr_ctb_lanc.eh_item_estoque        = 'N'     
   LET lr_ctb_lanc.lote_patrimonio        = 0    
   LET lr_ctb_lanc.liberado               = 'S'
   LET lr_ctb_lanc.tip_lancamento_contabil= 'O'       
   
   INSERT INTO ctb_lanc_ctbl_recb VALUES(lr_ctb_lanc.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela ctb_lanc_ctbl_recb.cta_deb'
      RETURN FALSE
   END IF

   LET l_nota = lr_ctb_lanc.nota_fiscal USING '<<<<<<<<<'
   LET l_aviso = lr_ctb_lanc.aviso_recebto USING '<<<<<<<<<'
   
   LET l_txt = 'NF ', l_nota CLIPPED, 
               ' FORNEC ', lr_ctb_lanc.fornec_nota_fiscal CLIPPED,
               ' AR ', l_aviso CLIPPED

   LET lr_ctb_compl.empresa = lr_ctb_lanc.empresa
   LET lr_ctb_compl.sistema_gerador = 'REC'
   LET lr_ctb_compl.periodo_contab  = lr_ctb_lanc.periodo_contab
   LET lr_ctb_compl.segmto_periodo  = lr_ctb_lanc.segmto_periodo
   LET lr_ctb_compl.sequencia_registro = lr_ctb_lanc.sequencia_registro 
   LET lr_ctb_compl.seq_reg_hist_compl = 1
   LET lr_ctb_compl.texto_hist_compl = l_txt
   
   INSERT INTO ctb_compl_hist_rec VALUES(lr_ctb_compl.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela ctb_compl_hist_rec.cta_deb'
      RETURN FALSE
   END IF
   
   LET lr_ctb_lanc.cta_deb = '0'
   LET lr_ctb_lanc.cta_cre = mr_tipo_despesa.num_conta_cred[1,10]
   LET lr_ctb_lanc.sequencia_registro = lr_ctb_lanc.sequencia_registro + 1

   INSERT INTO ctb_lanc_ctbl_recb VALUES(lr_ctb_lanc.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela ctb_lanc_ctbl_recb.cta_cre'
      RETURN FALSE
   END IF

   LET lr_ctb_compl.sequencia_registro = lr_ctb_lanc.sequencia_registro 

   INSERT INTO ctb_compl_hist_rec VALUES(lr_ctb_compl.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela ctb_compl_hist_rec.cta_cre'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

# ...at� aqui----#

#-------------------------#
FUNCTION pol1328_le_item()#
#-------------------------#
   
   SELECT ies_ctr_estoque,                     
          ies_ctr_lote,                           
          cod_cla_fisc,                           
          cod_unid_med,                           
          cod_local_estoq                        
     INTO mr_aviso.ies_item_estoq,     
          mr_aviso.ies_controle_lote,        
          mr_aviso.cod_cla_fisc,               
          mr_aviso.cod_unid_med_nf,            
          mr_aviso.cod_local_estoq           
     FROM item                                    
    WHERE cod_empresa = p_cod_empresa             
      AND cod_item = mr_aviso.cod_item    

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item, p/ grava��o no AR.'
      RETURN FALSE
   END IF
   
   IF mr_aviso.cod_local_estoq IS NULL THEN
      LET mr_aviso.cod_local_estoq = ' '
   END IF
   
   SELECT cod_comprador,                      
          gru_ctr_desp,                          
          cod_tip_despesa,                       
          num_conta,
          cod_fiscal                              
     INTO mr_aviso.cod_comprador,             
          mr_aviso.gru_ctr_desp_item,         
          mr_aviso.cod_tip_despesa,           
          m_num_conta_deb,
          p_cod_fiscal                            
     FROM item_sup                               
    WHERE cod_empresa = p_cod_empresa            
      AND cod_item = mr_aviso.cod_item                   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item_sup, p/ grava��o no AR.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1328_ins_aviso_rec_compl()#
#-------------------------------------#

   LET mr_ar_compl.cod_empresa       = p_cod_empresa              
   LET mr_ar_compl.num_aviso_rec     = mr_aviso.num_aviso_rec        
   LET mr_ar_compl.cod_fiscal_compl  = '0'                           
   LET mr_ar_compl.ies_situacao      = 'N'     
   LET mr_ar_compl.cod_operacao      = ' '                      
   LET mr_ar_compl.dat_proces        = NULL
    
   SELECT filial  
     INTO mr_ar_compl.filial
     FROM log_filial  
    WHERE empresa_logix = p_cod_empresa
      AND SYSDATE >= dat_inicial_validade
      AND SYSDATE <= dat_final_validade
      AND cnpj = m_cgc_empresa
   
   IF STATUS <> 0 THEN
      LET mr_ar_compl.filial = ' '
   END IF
                                                                 
   INSERT INTO aviso_rec_compl                                      
       VALUES (mr_ar_compl.*)                                        

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec_compl.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1328_ins_audit_ar()#
#------------------------------# 

   LET mr_audit_ar.cod_empresa = p_cod_empresa               
   LET mr_audit_ar.num_aviso_rec = mr_aviso.num_aviso_rec    
   LET mr_audit_ar.num_seq = mr_aviso.num_seq                
   LET mr_audit_ar.nom_usuario = mr_nota.cod_usuario                         
   LET mr_audit_ar.dat_hor_proces = CURRENT                     
   LET mr_audit_ar.num_prog = 'POL1328'                         
   LET mr_audit_ar.ies_tipo_auditoria = '1'                     
      
   INSERT INTO audit_ar VALUES(mr_audit_ar.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","audit_ar")
         RETURN FALSE
      END IF       

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec_compl.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1328_ins_dest_ar()#
#-----------------------------# 
   
   DEFINE l_sequencia      INTEGER
      
   LET l_sequencia = 0
   
   DECLARE cq_dest_ar CURSOR FOR
    SELECT *
      FROM gi_ad_aen_912
     WHERE id_ad = mr_nota.id_ad
   
   FOREACH cq_dest_ar  INTO mr_gi_aen.*

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela gi_ad_aen_912.'
         RETURN FALSE
      END IF
      
      LET l_sequencia = l_sequencia + 1
   
      LET mr_dest_ar.cod_empresa        = p_cod_empresa            
      LET mr_dest_ar.num_aviso_rec      = mr_aviso.num_aviso_rec    
      LET mr_dest_ar.num_seq            = mr_aviso.num_seq          
      LET mr_dest_ar.sequencia          = l_sequencia                                  
      LET mr_dest_ar.cod_area_negocio   = mr_gi_aen.cod_lin_prod           
      LET mr_dest_ar.cod_lin_negocio    = mr_gi_aen.cod_lin_recei    
      LET mr_dest_ar.pct_particip_comp  = mr_gi_aen.val_aen / mr_nota.val_tot_nf * 100                      
      LET mr_dest_ar.num_conta_deb_desp = m_num_conta_deb
      LET mr_dest_ar.cod_secao_receb    = m_cod_uni_funcio                           
      LET mr_dest_ar.qtd_recebida       = mr_aviso.qtd_recebida     
      LET mr_dest_ar.ies_contagem       = 'S'                            
      LET mr_dest_ar.cod_seg_merc       = mr_gi_aen.cod_seg_merc           
      LET mr_dest_ar.cod_cla_uso        = mr_gi_aen.cod_cla_uso                      
                                                          
      INSERT INTO dest_aviso_rec4 VALUES (mr_dest_ar.*)           

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela dest_aviso_rec4.'
         RETURN FALSE
      END IF
      
      INSERT INTO dest_aviso_rec VALUES (
         mr_dest_ar.cod_empresa,
         mr_dest_ar.num_aviso_rec,  
         mr_dest_ar.num_seq,           
         mr_dest_ar.sequencia,         
         mr_dest_ar.cod_area_negocio,  
         mr_dest_ar.cod_lin_negocio,   
         mr_dest_ar.pct_particip_comp, 
         mr_dest_ar.num_conta_deb_desp,
         mr_dest_ar.cod_secao_receb,
         mr_dest_ar.qtd_recebida,   
         mr_dest_ar.ies_contagem,
         " ")

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela dest_aviso_rec.'
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION pol1328_ins_ar_seq()#
#----------------------------#

   LET mr_ar_sq.cod_empresa       =  p_cod_empresa             
   LET mr_ar_sq.num_aviso_rec     =  mr_aviso.num_aviso_rec    
   LET mr_ar_sq.num_seq           =  mr_aviso.num_seq          
   LET mr_ar_sq.cod_fiscal_compl  =  0                            
   LET mr_ar_sq.val_base_d_ipi_it =  0                            
                                                               
   INSERT INTO aviso_rec_compl_sq VALUES (mr_ar_sq.*)        
                                                                  
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec_compl_sq.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1328_contab_nf()#
#---------------------------#
   
   
   
   RETURN TRUE

END FUNCTION

#-----------------------------#   
FUNCTION pol1328_gera_titulo()#
#-----------------------------#
   
   DEFINE l_count      INTEGER   
   
   LET m_cod_emp_ad = p_cod_empresa #pol1328_le_emp_orig_dest()
         
   IF NOT pol1328_insere_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_insere_cap() THEN
      RETURN FALSE
   END IF

   IF mr_nota.ies_gera_nota MATCHES '[FN]' THEN
      IF NOT pol1328_insere_lanc() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1328_insere_ad_aen() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_insere_ad_valores() THEN
      RETURN FALSE
   END IF

   LET m_irrf = FALSE

   IF m_for_juridic <> 'J' THEN
      IF NOT pol1328_le_tip_valaor() THEN
         RETURN FALSE
      END IF      
   END IF
   
   LET m_val_irrf = 0
   LET m_ies_ir_ap = FALSE
   
   IF m_irrf THEN
      IF NOT pol1328_ins_irrf_pg() THEN
         RETURN FALSE
      END IF
   END IF
     
   IF NOT pol1328_gera_grade() THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_insere_aps() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1328_le_emp_orig_dest()#
#----------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT cod_empresa_destin
     INTO p_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_empresa = p_cod_empresa
   END IF
   
   IF p_empresa IS NULL THEN
      LET p_empresa = p_cod_empresa
   END IF
   
   RETURN (p_empresa)
   
END FUNCTION

#---------------------------#
FUNCTION pol1328_le_par_ad()#
#---------------------------#

   DECLARE cq_par_ad CURSOR FOR   
   SELECT ult_num_ad     
     FROM par_ad
    WHERE cod_empresa = m_cod_emp_ad
      FOR UPDATE

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' criando cursor p/ leitura do No. da AD'
      RETURN FALSE
   END IF
   
   OPEN cq_par_ad

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' abrindo cursor p/ leitura do No. da AD'
      RETURN FALSE
   END IF
   
   FETCH cq_par_ad INTO m_num_ad

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo cursor p/ leitura do No. da AD'
      RETURN FALSE
   END IF

   WHILE TRUE

      LET m_num_ad = m_num_ad + 1

      SELECT num_ad FROM ad_mestre  
       WHERE cod_empresa = p_cod_empresa 
         AND num_ad = m_num_ad

      IF STATUS = 100 THEN
         EXIT WHILE
      END IF  
   
   END WHILE
   
   UPDATE par_ad SET ult_num_ad = m_num_ad
   WHERE cod_empresa = m_cod_emp_ad

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' atualizando dados na tabela par_ad.'
      RETURN FALSE
   END IF
   
   IF m_uni_funcio IS NOT NULL THEN
      RETURN TRUE
   END IF
   
   LET m_cod_uni_funcio = NULL

   SELECT val_texto
     INTO m_cod_uni_funcio
     FROM gi_param_integracao_912
    WHERE cod_parametro = 'UNIDADE_FUNCIONAL'
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo uni funcional da tabela gi_param_integracao_912.'
      RETURN FALSE
   END IF
         
   IF m_cod_uni_funcio IS NULL THEN
      LET m_msg = ' Unidade funcional do usuario ',p_user,
                  ' nao cadastrada na tabela usu_cap_uni_func.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1328_insere_ad()#
#---------------------------#
   
   DEFINE l_manut       LIKE audit_cap.desc_manut,
          l_hora        LIKE audit_cap.hora_manut,
          l_data        LIKE audit_cap.data_manut,
          l_num_seq     LIKE audit_cap.num_seq,
          l_favorecido  CHAR(15),
          l_fornecedor  CHAR(15)

   LET mr_gi_ap.cod_favorecido = NULL

   DECLARE cq_pri_ap CURSOR FOR
    SELECT cod_favorecido 
      FROM gi_ap_912
     WHERE id_ad = mr_nota.id_ad
     ORDER BY id_ap
   
   FOREACH cq_pri_ap INTO l_favorecido

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                                 
         LET m_msg = 'Erro de status: ',m_erro                                                             
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela gi_ap_912:cq_pri_ap'                    
         RETURN FALSE
      END IF
      
      LET mr_gi_ap.cod_favorecido = l_favorecido
      EXIT FOREACH
      
   END FOREACH

   IF mr_gi_ap.cod_favorecido IS NULL THEN
       LET l_fornecedor = mr_nota.cod_fornecedor
   ELSE
       LET l_fornecedor = mr_gi_ap.cod_favorecido
   END IF

   SELECT ies_dep_cred
     INTO m_ies_dep_cred
     FROM fornecedor
    WHERE cod_fornecedor = l_fornecedor

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo a tabela fornecedor.ies_dep_cred.'
      RETURN FALSE
   END IF           
      
	 SELECT cod_lote_pgto 
	   INTO mr_nota.num_lote
	   FROM def_lot_pgto  
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_tip_despesa = mr_nota.cod_tip_despesa  
	    AND ies_dep_cred = m_ies_dep_cred 
	    AND cod_portador IS NULL

   IF STATUS = 100 OR mr_nota.num_lote IS NULL THEN

      SELECT parametro_val  
        INTO mr_nota.num_lote
        FROM sup_par_fornecedor  
       WHERE empresa = 'SE' 
         AND fornecedor = mr_nota.cod_fornecedor
         AND parametro = 'lote_pagamento_forne'
      
      IF STATUS = 100 OR mr_nota.num_lote IS NULL THEN
         LET mr_nota.num_lote = 44
      END IF
   ELSE
      IF STATUS <> 0 THEN                                                   
         LET m_erro = STATUS USING '<<<<<'                                  
         LET m_msg = 'Erro de status: ',m_erro                              
         LET m_msg = m_msg CLIPPED, ' lendo registro da tabela def_lot_pgto '
         RETURN FALSE                                                       
      END IF                                                                
   END IF
   
   LET mr_ad_mestre.cod_empresa       = m_cod_emp_ad                     
   LET mr_ad_mestre.num_ad            = m_num_ad                         
   LET mr_ad_mestre.cod_tip_despesa   = mr_nota.cod_tip_despesa          
   LET mr_ad_mestre.ser_nf            = mr_nota.ser_nf                   
   LET mr_ad_mestre.ssr_nf            = mr_nota.ssr_nf                   
   LET mr_ad_mestre.num_nf            = mr_nota.num_nf  USING '<<<<<<<'                 
   LET mr_ad_mestre.dat_emis_nf       = m_dat_emissao         
   LET mr_ad_mestre.dat_rec_nf        = m_dat_recebto         
   LET mr_ad_mestre.cod_empresa_estab = NULL                             
   LET mr_ad_mestre.mes_ano_compet    = NULL                             
   LET mr_ad_mestre.num_ord_forn      = NULL                             
   LET mr_ad_mestre.cnd_pgto          = m_cnd_pgto                       
   LET mr_ad_mestre.dat_venc          = m_dat_vencto                     
   LET mr_ad_mestre.cod_fornecedor    = mr_nota.cod_fornecedor           
   LET mr_ad_mestre.cod_portador      = NULL                             
   LET mr_ad_mestre.val_tot_nf        = mr_nota.val_tot_nf               
   LET mr_ad_mestre.val_saldo_ad      = 0               
   LET mr_ad_mestre.cod_moeda         = mr_nota.cod_moeda     
   IF mr_tipo_despesa.ies_set_aplicacao = 'S' THEN           
      LET mr_ad_mestre.set_aplicacao  = 6                             
   ELSE
      LET mr_ad_mestre.set_aplicacao  = NULL
   END IF
   LET mr_ad_mestre.cod_lote_pgto     = mr_nota.num_lote                 
   LET mr_ad_mestre.observ            = mr_nota.den_observacao  

   SELECT cod_tip_ad 
     INTO mr_ad_mestre.cod_tip_ad
     FROM tipo_despesa_compl  
    WHERE cod_empresa = p_cod_empresa
      AND cod_tip_despesa = mr_nota.cod_tip_despesa 

   IF STATUS = 100 OR mr_ad_mestre.cod_tip_ad IS NULL THEN
      LET mr_ad_mestre.cod_tip_ad = 5
   ELSE
      IF STATUS <> 0 THEN                                                   
         LET m_erro = STATUS USING '<<<<<'                                  
         LET m_msg = 'Erro de status: ',m_erro                              
         LET m_msg = m_msg CLIPPED, ' lendo registro da tabela tipo_despesa_compl '
         RETURN FALSE                                                       
      END IF                                                                
   END IF

   LET mr_ad_mestre.ies_ap_autom      = 'S'                              
   LET mr_ad_mestre.ies_sup_cap       = m_ies_sup_cap                            
   LET mr_ad_mestre.ies_fatura        = 'N'                              
   LET mr_ad_mestre.ies_ad_cont       = 'N'                              
   LET mr_ad_mestre.num_lote_transf   = 0                                   
   LET mr_ad_mestre.ies_dep_cred      = m_ies_dep_cred                             
   LET mr_ad_mestre.num_lote_pat      = 0                                
   LET mr_ad_mestre.cod_empresa_orig  = p_cod_empresa                    
                                                                         
   INSERT INTO ad_mestre                                                 
      VALUES(mr_ad_mestre.*)                                             
                                                                         
   IF STATUS <> 0 THEN                                                   
      LET m_erro = STATUS USING '<<<<<'                                  
      LET m_msg = 'Erro de status: ',m_erro                              
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela ad_mestre '
      RETURN FALSE                                                       
   END IF                                                                
   
   IF mr_nota.den_observacao IS NOT NULL THEN
      IF NOT pol1328_grv_texto() THEN
         RETURN FALSE
      END IF
   END IF
                                                                                                                                         
   LET l_data = TODAY
   LET l_hora = TIME

   LET l_manut = 'POL1328 - INCLUSAO DA AD No. ', mr_ad_mestre.num_ad USING '<<<<<<<'
   LET l_num_seq = pol1328_le_audit(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, '1')

   INSERT INTO audit_cap
      VALUES(mr_ad_mestre.cod_empresa,
             '1',
             p_user,
             mr_ad_mestre.num_ad,
             '1',
             mr_ad_mestre.num_nf,
             mr_ad_mestre.ser_nf,
             mr_ad_mestre.ssr_nf,
             mr_ad_mestre.cod_fornecedor,
             'I',
             l_num_seq,
             l_manut,
             l_data,
             l_hora,
             mr_ad_mestre.num_lote_transf)
             
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo dados da AD na tabela audit_cap.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1328_grv_texto()#
#---------------------------#

   DEFINE l_parametro  RECORD 
          texto        VARCHAR(4000),
          tam_linha    SMALLINT,
          justificar   CHAR(01)
   END RECORD
   
   DEFINE l_seq        INTEGER,
          l_texto      VARCHAR(40)

   DELETE FROM cap_obs_ad
    WHERE empresa = p_cod_empresa
      AND apropriacao_desp = m_num_ad

   LET l_parametro.texto = mr_nota.den_observacao
   LET l_parametro.tam_linha = 40
   LET l_parametro.justificar = 'N'
 
   IF NOT func024_quebrar_texto(l_parametro) THEN
      IF NOT pol1328_grv_cap_obs(mr_ad_mestre.observ,1) THEN
         RETURN FALSE
      END IF
   ELSE
      DECLARE cq_txt_obs CURSOR FOR
       SELECT num_seq, texto 
         FROM w_txt_observ
      FOREACH cq_txt_obs INTO l_seq, l_texto

         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'                                                                 
            LET m_msg = 'Erro de status: ',m_erro                                                             
            LET m_msg = m_msg CLIPPED, ' lendo textos da tabela w_txt_observ.'                    
            RETURN FALSE                                                                                      
         END IF
      
         IF l_seq < 100 THEN
            IF NOT pol1328_grv_cap_obs(l_texto, l_seq) THEN
               RETURN FALSE
            END IF
         ELSE
            EXIT FOREACH
         END IF
      END FOREACH
   END IF

   RETURN TRUE

END FUNCTION
   
#-------------------------------------------#
FUNCTION pol1328_grv_cap_obs(l_texto, l_seq)#
#-------------------------------------------#

   DEFINE l_texto VARCHAR(40),
          l_seq   INTEGER
   
   IF l_texto IS NULL THEN
      RETURN TRUE
   END IF
      
   INSERT INTO cap_obs_ad(empresa, apropriacao_desp, seql_obs_ad, obs_ad)
    VALUES(p_cod_empresa, m_num_ad, l_seq, l_texto)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo conta credito na tabela cap_obs_ad.'                    
      RETURN FALSE                                                                                      
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1328_insere_cap()#
#----------------------------#
   
   DEFINE l_nom_tabela   LIKE cap_par_compl.nom_tabela
   
   LET l_nom_tabela = mr_ad_mestre.num_ad

   DELETE FROM cap_par_compl
    WHERE nom_tabela = l_nom_tabela
      AND empresa = mr_ad_mestre.cod_empresa
      AND parametro = 'ies_sup_cap_aprov'     

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando dados da tabela cap_par_compl:1'
      RETURN FALSE
   END IF

   DELETE FROM cap_par_compl
    WHERE nom_tabela = l_nom_tabela
      AND empresa = mr_ad_mestre.cod_empresa
      AND parametro = 'ies_especie_nf_ad'   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando dados da tabela cap_par_compl:2'
      RETURN FALSE
   END IF
   
   INSERT INTO cap_par_compl 
     (nom_tabela, 
      empresa, 
      parametro, 
      des_parametro, 
      parametro_texto)
   VALUES(l_nom_tabela,
          mr_ad_mestre.cod_empresa,
          'ies_sup_cap_aprov',      
          'Origem da AD para aprova��o',
          'A')

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela cap_par_compl.'
      RETURN FALSE
   END IF

   INSERT INTO cap_par_compl 
     (nom_tabela, 
      empresa, 
      parametro, 
      des_parametro, 
      parametro_texto)
   VALUES(l_nom_tabela,
          mr_ad_mestre.cod_empresa,
          'ies_especie_nf_ad',     
          'Especie da nota referente a AD',
          m_ies_especie_nf)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela cap_par_compl.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#---------------------------------------------#
FUNCTION pol1328_le_audit(l_emp, l_num, l_ies)#
#---------------------------------------------#
   
   DEFINE l_sequen     LIKE audit_cap.num_seq,
          l_emp        LIKE audit_cap.cod_empresa,
          l_num        LIKE audit_cap.num_ad_ap,
          l_ies        LIKE audit_cap.ies_ad_ap
   
   {SELECT MAX(num_seq)
     INTO l_sequen
     FROM audit_cap
    WHERE cod_empresa = l_emp
      AND num_ad_ap = l_num
      AND ies_ad_ap = l_ies
      
   IF STATUS <> 0 THEN
      LET l_sequen = 0
   END IF
   
   LET l_sequen = l_sequen + 1}
   
    DELETE FROM audit_cap
    WHERE cod_empresa = l_emp
      AND num_ad_ap = l_num
      AND ies_ad_ap = l_ies
      
   RETURN 1

END FUNCTION

#-------------------------------#
FUNCTION pol1328_insere_ad_aen()#
#-------------------------------#
   
   DEFINE l_data               CHAR(10)
   
   LET l_data = EXTEND(m_dat_emissao, YEAR TO DAY)
   LET m_periodo_contab = l_data[1,4]
   LET m_segmto_periodo = l_data[6,7]

   SELECT MAX(num_relacionto) 
     INTO m_num_relac
     FROM ctb_lanc_ctbl_cap  
    WHERE empresa = p_cod_empresa  
      AND periodo_contab = m_periodo_contab 
      AND segmto_periodo = m_segmto_periodo
  

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo relacionamento da tabela ctb_lanc_ctbl_cap'
      RETURN FALSE
   END IF
   
   IF m_num_relac IS NULL THEN
      LET m_num_relac = 0
   END IF
 
   SELECT MAX(sequencia_registro) 
     INTO m_seq_registro
     FROM ctb_lanc_ctbl_cap  
    WHERE empresa = p_cod_empresa  
      AND periodo_contab = m_periodo_contab   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo sequencia do registro da tabela ctb_lanc_ctbl_cap'
      RETURN FALSE
   END IF
   
   IF m_seq_registro IS NULL THEN
      LET m_seq_registro = 0
   END IF
   
   LET m_num_relac = m_num_relac + 1   
   LET m_seql_lanc_cap = 0
   
   SELECT par_val
     INTO m_hist_padrao
     FROM par_cap_pad  
     WHERE cod_empresa = p_cod_empresa 
       AND cod_parametro = 'cod_hist_lanc_anl'

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela par_cap_pad'                    
      RETURN FALSE
   END IF
    
   DECLARE cq_aen_4 CURSOR FOR
    SELECT *
      FROM gi_ad_aen_912
     WHERE id_ad = mr_nota.id_ad
   
   FOREACH cq_aen_4  INTO mr_gi_aen.*

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela gi_ad_aen_912:cq_aen_4'
         EXIT FOREACH
      END IF
   
      INSERT INTO ad_aen_4 (
       cod_empresa, 
       num_ad, 
       val_aen, 
       cod_lin_prod, 
       cod_lin_recei, 
       cod_seg_merc, 
       cod_cla_uso) 
      VALUES(mr_ad_mestre.cod_empresa,
             mr_ad_mestre.num_ad,
             mr_gi_aen.val_aen,
             mr_gi_aen.cod_lin_prod,
             mr_gi_aen.cod_lin_recei,
             mr_gi_aen.cod_seg_merc,
             mr_gi_aen.cod_cla_uso)
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro a tabela ad_aen_4'
         EXIT FOREACH
      END IF

      IF mr_nota.ies_gera_nota MATCHES '[FN]' THEN
         IF NOT pol1328_ins_ctbl_cap(1) THEN
            EXIT FOREACH
         END IF
         IF NOT pol1328_ins_ctbl_cap(2) THEN
            EXIT FOREACH
         END IF
      END IF
             
   END FOREACH
   
   IF m_erro IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1328_ins_ctbl_cap(l_seq)#
#-----------------------------------#
    
    DEFINE l_seq            INTEGER
    DEFINE lr_cap           RECORD LIKE ctb_lanc_ctbl_cap.*
    DEFINE l_docum          CHAR(06)
    
    LET m_seq_registro = m_seq_registro + 1
    LET m_seql_lanc_cap = m_seql_lanc_cap + 1
    
    LET l_docum = mr_ad_mestre.num_ad USING '<<<<<<', 
     ' FORNECEDOR', mr_nota.cod_fornecedor
    
    LET lr_cap.empresa = mr_ad_mestre.cod_empresa
    LET lr_cap.periodo_contab = m_periodo_contab
    LET lr_cap.segmto_periodo = m_segmto_periodo

    IF l_seq = 1 THEN
       LET lr_cap.cta_deb = mr_tipo_despesa.num_conta_deb
       LET lr_cap.cta_cre = '0'
       LET lr_cap.compl_hist = 'AD ', l_docum CLIPPED, m_historico_deb CLIPPED
       LET lr_cap.sequencia_registro = m_seq_registro
    ELSE
       LET lr_cap.cta_deb = '0'
       LET lr_cap.cta_cre =  mr_tipo_despesa.num_conta_cred
       LET lr_cap.compl_hist = 'AD ', l_docum CLIPPED, m_historico_cred CLIPPED
       LET lr_cap.sequencia_registro = m_seq_registro
    END IF
    
    LET lr_cap.dat_movto = mr_ad_mestre.dat_emis_nf
    LET lr_cap.dat_vencto = NULL
    LET lr_cap.dat_conversao = NULL    
    LET lr_cap.val_lancto = mr_gi_aen.val_aen
    LET lr_cap.qtd_outra_moeda = 0 
    LET lr_cap.hist_padrao = m_hist_padrao
    LET lr_cap.linha_produto = mr_gi_aen.cod_lin_prod
    LET lr_cap.linha_receita = mr_gi_aen.cod_lin_recei
    LET lr_cap.segmto_mercado = mr_gi_aen.cod_seg_merc
    LET lr_cap.classe_uso = mr_gi_aen.cod_cla_uso
    LET lr_cap.num_relacionto = m_num_relac
    LET lr_cap.lote_contab = 0
    LET lr_cap.num_lancto = 0
    LET lr_cap.empresa_origem = mr_ad_mestre.cod_empresa_orig
    LET lr_cap.num_ad_ap = mr_ad_mestre.num_ad    
    LET lr_cap.eh_ad_ap = '1'
    LET lr_cap.seql_lanc_cap = m_seql_lanc_cap * 1000
    LET lr_cap.tip_despesa_val = mr_nota.cod_tip_despesa
    LET lr_cap.eh_despesa_val  = 'D'
    LET lr_cap.eh_manual_autom = 'A'
    LET lr_cap.eh_cond_pagto   = 'S'
    LET lr_cap.lote_transf = 0
    LET lr_cap.banco_pagador = NULL
    LET lr_cap.cta_bancaria = NULL
    LET lr_cap.docum_pagto = NULL 
    LET lr_cap.tip_docum_pagto = NULL
    LET lr_cap.fornecedor = mr_nota.cod_fornecedor
    LET lr_cap.liberado = 'S'
    
    INSERT INTO ctb_lanc_ctbl_cap
     VALUES(lr_cap.*)

    IF STATUS <> 0 THEN
       LET m_erro = STATUS USING '<<<<<'
       LET m_msg = 'Erro de status: ',m_erro
       LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela ctb_lanc_ctbl_cap.'
       RETURN FALSE
    END IF     

   RETURN TRUE

END FUNCTION   
 
#-----------------------------------#
FUNCTION pol1328_insere_ad_valores()#
#-----------------------------------#
   
   DEFINE lr_gi_ad_valor RECORD
          num_seq                     INTEGER,      
          id_ad                       INTEGER,      
          cod_empresa                 CHAR(2),      
          cod_fatura                  INTEGER,      
          cod_tip_valor               INTEGER,      
          valor                       DECIMAL(15,2)
   END RECORD

   DECLARE cq_ins_ad_valores CURSOR FOR
    SELECT *
      FROM gi_ad_valores_912
     WHERE id_ad = mr_nota.id_ad
       AND valor > 0
     ORDER BY num_seq
   
   FOREACH cq_ins_ad_valores INTO lr_gi_ad_valor.*
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela gi_ap_valores_912.'
         EXIT FOREACH
      END IF

      INSERT INTO ad_valores (
       cod_empresa,
       num_ad,
       num_seq,
       cod_tip_val,
       valor)
      VALUES(mr_ad_mestre.cod_empresa,
             mr_ad_mestre.num_ad,
             lr_gi_ad_valor.num_seq,
             lr_gi_ad_valor.cod_tip_valor,
             lr_gi_ad_valor.valor)

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela ad_valores.'
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF m_erro IS NOT NULL THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1328_le_tip_desp()#
#-----------------------------#

   SELECT *
     INTO mr_tipo_despesa.*
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_empresa
      AND cod_tip_despesa = mr_nota.cod_tip_despesa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo registro da tabela tipo_despesa.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1328_insere_lanc()#
#-----------------------------#
      
   DEFINE l_num_seq             SMALLINT,
          l_nf                  CHAR(06)
          
   DELETE FROM lanc_cont_cap                                                                            
    WHERE cod_empresa = mr_ad_mestre.cod_empresa
      AND num_ad_ap = mr_ad_mestre.num_ad                                                        
      AND ies_ad_ap = '1'                                                       
      AND num_seq >= 0                                                            
              
   SELECT historico 
     INTO m_historico_deb
     FROM hist_padrao_cap 
    WHERE cod_hist = mr_tipo_despesa.cod_hist_deb

   SELECT historico 
     INTO m_historico_cred
     FROM hist_padrao_cap 
    WHERE cod_hist = mr_tipo_despesa.cod_hist_cred
   
   LET l_num_seq = 0
   
   LET l_nf = mr_ad_mestre.num_nf USING '<<<<<<'                                                     
   LET l_num_seq = l_num_seq + 1                                                                        
   
   IF m_historico_deb IS NULL THEN
      LET m_historico_deb = 'NF ',l_nf CLIPPED,' DO ', m_raz_social
   END IF

   IF m_historico_cred IS NULL THEN
      LET m_historico_cred = 'NF ',l_nf CLIPPED,' DO ', m_raz_social
   END IF
                                                                                                         
   LET mr_lanc_cont_cap.cod_empresa        = mr_ad_mestre.cod_empresa                                   
   LET mr_lanc_cont_cap.num_ad_ap          = mr_ad_mestre.num_ad                                        
   LET mr_lanc_cont_cap.ies_ad_ap          = '1'                                                        
   LET mr_lanc_cont_cap.num_seq            = l_num_seq                                                                                                                                                                                                                                                                  
   LET mr_lanc_cont_cap.cod_tip_desp_val   = mr_nota.cod_tip_despesa                                    
   LET mr_lanc_cont_cap.ies_desp_val       = 'D'                                                        
   LET mr_lanc_cont_cap.ies_man_aut        = 'A'                                                        
   LET mr_lanc_cont_cap.ies_tipo_lanc      = 'D'                                                        
   LET mr_lanc_cont_cap.num_conta_cont     = mr_tipo_despesa.num_conta_deb                              
   LET mr_lanc_cont_cap.val_lanc           = mr_ad_mestre.val_tot_nf                                    
   LET mr_lanc_cont_cap.tex_hist_lanc      = m_historico_deb                                            
   LET mr_lanc_cont_cap.ies_cnd_pgto       = 'S'                                                        
   LET mr_lanc_cont_cap.num_lote_lanc      = 0                                                          
   LET mr_lanc_cont_cap.ies_liberad_contab = 'S'                                                        
   LET mr_lanc_cont_cap.num_lote_transf    = mr_ad_mestre.num_lote_transf                               
   LET mr_lanc_cont_cap.dat_lanc           = mr_ad_mestre.dat_rec_nf                                    
                                                                                                        
   INSERT INTO lanc_cont_cap                                                                         
      VALUES(mr_lanc_cont_cap.*)                                                                        
                                                                                                        
   IF STATUS <> 0 THEN                                                                               
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo conta debito na tabela lanc_cont_cap.'                 
      RETURN FALSE                                                                                      
   END IF                                                                                               
                                                                                                        
   LET mr_lanc_cont_cap.ies_tipo_lanc  = 'C'                                                         
   LET mr_lanc_cont_cap.num_conta_cont = mr_tipo_despesa.num_conta_cred                                 
   LET mr_lanc_cont_cap.tex_hist_lanc      = m_historico_cred                                           
   LET l_num_seq = l_num_seq + 1                                                                        
   LET mr_lanc_cont_cap.num_seq        = l_num_seq                                                      
                                                                                                                                                                                                                
   INSERT INTO lanc_cont_cap                                                                            
      VALUES(mr_lanc_cont_cap.*)                                                                        
                                                                                                        
   IF STATUS <> 0 THEN                                                                               
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo conta credito na tabela lanc_cont_cap.'                    
      RETURN FALSE                                                                                      
   END IF                                                                                               
      
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1328_insere_aps()#
#----------------------------#
   
   UPDATE gi_ap_912 SET ies_banco = 'N'                       
    WHERE id_ad = mr_nota.id_ad 

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' atualizando campo gi_ap_912.ies_banco(N)'                    
      RETURN FALSE
   END IF
   
   UPDATE gi_ap_912 SET ies_banco = 'S'                       
    WHERE id_ad = mr_nota.id_ad 
      AND cod_favorecido IN (SELECT cod_favorecido FROM ies_banco_912)
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' atualizando campo gi_ap_912.ies_banco(S)'                    
      RETURN FALSE
   END IF
              
   SELECT SUM(val_nom_ap)  
     INTO m_val_sem_ir              
     FROM gi_ap_912                        
    WHERE id_ad = mr_nota.id_ad              
      AND ies_banco = 'S'                  
                                       
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' somando valor da tabela gi_ap_912:1'                    
      RETURN FALSE
   END IF
   
   IF m_val_sem_ir IS NULL THEN
      LET m_val_sem_ir = 0
   END IF
   
   LET m_val_com_ir = mr_ad_mestre.val_tot_nf - m_val_sem_ir
                                       
   LET m_parcela = 0
   
   DECLARE cq_le_ap CURSOR FOR
    SELECT * 
      FROM gi_ap_912
     WHERE id_ad = mr_nota.id_ad
     ORDER BY id_ap
   
   FOREACH cq_le_ap INTO mr_gi_ap.*

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                                 
         LET m_msg = 'Erro de status: ',m_erro                                                             
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela gi_ap_912:cq_le_ap'                    
         EXIT FOREACH
      END IF
      
      LET m_parcela = m_parcela + 1
      
      IF NOT pol1328_insere_ap() THEN
         EXIT FOREACH
      END IF

      IF NOT pol1328_insere_ap_valores() THEN
         RETURN FALSE
      END IF


      IF m_ies_ir_ap THEN
         IF mr_gi_ap.ies_banco IS NULL OR mr_gi_ap.ies_banco <> 'S' THEN
            IF NOT pol1328_ins_irrf_ap() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      UPDATE gi_ap_912 SET num_ap = m_num_ap
       WHERE id_ad = mr_nota.id_ad
         AND id_ap = mr_gi_ap.id_ap

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                                 
         LET m_msg = 'Erro de status: ',m_erro                                                             
         LET m_msg = m_msg CLIPPED, ' gravando numero da AP na tab gi_ap_912'                    
         RETURN FALSE                                                                                      
      END IF

      INSERT INTO ap_proces_912(
       cod_empresa,
       cod_fatura,
       id_ap,
       num_ap)
        VALUES (
          mr_ap.cod_empresa, 
          mr_nota.cod_fatura,
          mr_gi_ap.id_ap, 
          mr_ap.num_ap)
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                                 
         LET m_msg = 'Erro de status: ',m_erro                                                             
         LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela ap_proces_912'                    
         RETURN FALSE                                                                                      
      END IF
      
   END FOREACH
   
   IF m_erro IS NOT NULL THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol1328_le_par_ap()#
#---------------------------#

   DECLARE cq_par_ap CURSOR FOR   
   SELECT ult_num_ap     
     FROM par_ap
    WHERE cod_empresa = m_cod_emp_ad
      FOR UPDATE

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' criando cursor p/ leitura do No. da AP'
      RETURN FALSE
   END IF
   
   OPEN cq_par_ap

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' abrindo cursor p/ leitura do No. da AP'
      RETURN FALSE
   END IF
   
   FETCH cq_par_ap INTO m_num_ap

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo cursor p/ leitura do No. da AP'
      RETURN FALSE
   END IF

   WHILE TRUE

      LET m_num_ap = m_num_ap + 1

      SELECT num_ap FROM ap  
       WHERE cod_empresa = p_cod_empresa 
         AND num_ap = m_num_ap
         AND ies_versao_atual = 'S'

      IF STATUS = 100 THEN
         
         SELECT 1 FROM cap_ap_consolid  
          WHERE empresa = p_cod_empresa AND autoriz_pagto = m_num_ap 
         
         IF STATUS = 100 THEN
            EXIT WHILE
         END IF
      END IF  
   
   END WHILE
   
   UPDATE par_ap SET ult_num_ap = m_num_ap
   WHERE cod_empresa = m_cod_emp_ad

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' atualizando dados na tabela par_ap.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1328_le_conta(l_cod)#
#-------------------------------#
   
   DEFINE l_cod        CHAR(15)

   SELECT cod_banco,                                                            
          num_agencia,                                                          
          num_conta_banco                                                       
     INTO m_cod_banco,                                                          
          m_num_agencia,                                                        
          m_num_conta_banco                                                     
     FROM fornecedor                                                            
    WHERE cod_fornecedor = l_cod                                                
                                                                                   
   IF STATUS <> 0 AND STATUS <> 100 THEN                                        
      LET m_erro = STATUS USING '<<<<<'                                         
      LET m_msg = 'Erro de status: ',m_erro                                     
      LET m_msg = m_msg CLIPPED, ' lendo dados banc�rios da tabela fornecedor.' 
      RETURN FALSE                                                              
   END IF                                                                       
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol1328_insere_ap()#
#---------------------------#

   DEFINE l_manut       LIKE audit_cap.desc_manut,
          l_hora        LIKE audit_cap.hora_manut,
          l_data        LIKE audit_cap.data_manut,
          l_num_seq     LIKE audit_cap.num_seq,
          l_status      SMALLINT,
          l_dat_hor     CHAR(19),
          l_contrato    CHAR(40)
          

    IF NOT pol1328_le_par_ap() THEN 
       RETURN FALSE
    END IF

    IF mr_gi_ap.cod_banco_fav IS NOT NULL AND         
        mr_gi_ap.num_agencia_fav IS NOT NULL AND          
        mr_gi_ap.num_conta_banco_fav IS NOT NULL THEN                                                           
        LET m_cod_banco = mr_gi_ap.cod_banco_fav              
        LET m_num_agencia = mr_gi_ap.num_agencia_fav            
        LET m_num_conta_banco = mr_gi_ap.num_conta_banco_fav                           
    ELSE                                          
       IF mr_gi_ap.cod_favorecido IS NULL THEN
          LET l_status = pol1328_le_conta(mr_gi_ap.cod_fornecedor)
       ELSE
          LET l_status = pol1328_le_conta(mr_gi_ap.cod_favorecido)
       END IF   
       IF NOT l_status THEN
         RETURN FALSE                                                                                      
       END IF        
    END IF
    
    LET mr_ap.cod_empresa       = mr_ad_mestre.cod_empresa
    LET mr_ap.num_ap            = m_num_ap
    LET mr_ap.num_versao        = 1
    LET mr_ap.ies_versao_atual  = 'S'
    LET mr_ap.num_parcela       = m_parcela
    LET mr_ap.cod_portador      = NULL
    LET mr_ap.cod_bco_pagador   = NULL
    LET mr_ap.num_conta_banc    = NULL
    LET mr_ap.cod_fornecedor    = mr_gi_ap.cod_fornecedor
    LET mr_ap.cod_banco_for     = m_cod_banco
    LET mr_ap.num_agencia_for   = m_num_agencia
    LET mr_ap.num_conta_bco_for = m_num_conta_banco
    LET mr_ap.num_nf            = mr_ad_mestre.num_nf
    LET mr_ap.num_duplicata     = NULL
    LET mr_ap.num_bl_awb        = '0'
    LET mr_ap.compl_docum       = NULL
    LET mr_ap.val_nom_ap        = mr_gi_ap.val_nom_ap
    LET mr_ap.val_ap_dat_pgto   = 0
    LET mr_ap.cod_moeda         = mr_ad_mestre.cod_moeda
    LET mr_ap.val_jur_dia       = 0
    LET mr_ap.taxa_juros        = NULL
    LET mr_ap.cod_formula       = NULL
    LET mr_ap.dat_emis          = m_dat_emissao
    LET mr_ap.dat_vencto_s_desc = mr_gi_ap.dt_vencimento
    LET mr_ap.dat_vencto_c_desc = NULL
    LET mr_ap.val_desc          = NULL
    LET mr_ap.dat_pgto          = NULL
    LET mr_ap.dat_proposta      = NULL
    LET mr_ap.cod_lote_pgto     = mr_ad_mestre.cod_lote_pgto
    LET mr_ap.num_docum_pgto    = NULL

    IF m_ies_aprov THEN
       LET mr_ap.ies_lib_pgto_cap  = 'B'
    ELSE
       LET mr_ap.ies_lib_pgto_cap  = 'N'
    END IF

    LET mr_ap.ies_lib_pgto_sup  = 'S'
    LET mr_ap.ies_baixada       = 'N'
    LET mr_ap.ies_docum_pgto    = NULL
    LET mr_ap.ies_ap_impressa   = 'N'
    LET mr_ap.ies_ap_contab     = 'N'
    LET mr_ap.num_lote_transf   = mr_ad_mestre.num_lote_transf
    LET mr_ap.ies_dep_cred      = mr_ad_mestre.ies_dep_cred
    LET mr_ap.data_receb        = NULL
    LET mr_ap.num_lote_rem_escr = 0
    LET mr_ap.num_lote_ret_escr = 0
    LET mr_ap.dat_rem           = NULL
    LET mr_ap.dat_ret           = NULL
    LET mr_ap.status_rem        = 0
    LET mr_ap.ies_form_pgto_escr= NULL
    LET mr_ap.num_duplicata     = mr_nota.cod_obrig_lcc

   
   INSERT INTO ap
      VALUES(mr_ap.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo conta credito na tabela ap.'                    
      RETURN FALSE                                                                                      
   END IF
     
   LET l_contrato =  'AP INCLUIDA PELO GI CONTRATO  ', mr_nota.cod_contrato USING '<<<<<<<'
   
   
   INSERT INTO ap_obser
    VALUES(mr_ap.cod_empresa,
           mr_ap.num_ap,
           1,
           l_contrato)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo conta credito na tabela ap_obser.'                    
      RETURN FALSE                                                                                      
   END IF
   
   IF mr_gi_ap.cod_favorecido IS NOT NULL THEN
      INSERT INTO ap_favorecido (
        cod_empresa, num_ap, cod_fornecedor)
        VALUES(mr_ap.cod_empresa,
               mr_ap.num_ap,
               mr_gi_ap.cod_favorecido)
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                                 
         LET m_msg = 'Erro de status: ',m_erro                                                             
         LET m_msg = m_msg CLIPPED, ' inserindo conta credito na tabela ap_favorecido.'                    
         RETURN FALSE                                                                                      
      END IF
   END IF
                  
   INSERT INTO ap_tip_desp(
      cod_empresa, 
      num_ap, 
      conta_forn_trans, 
      cod_hist, 
      cod_tip_despesa, 
      val_tip_despesa)
    VALUES(mr_ap.cod_empresa,
           mr_ap.num_ap,
           mr_tipo_despesa.num_conta_cred,
           mr_tipo_despesa.cod_hist_deb_ap,
           mr_nota.cod_tip_despesa,
           mr_ap.val_nom_ap)
           
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo dados na ap_tip_desp ap.'                    
      RETURN FALSE
   END IF
      
   INSERT INTO ad_ap(
      cod_empresa,
      num_ad,
      num_ap,
      num_lote_transf)
      VALUES(mr_ap.cod_empresa,
             mr_ad_mestre.num_ad,
             mr_ap.num_ap,
             mr_ap.num_lote_transf)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo dados na ad_ap.'                    
      RETURN FALSE
   END IF
   
   LET l_dat_hor = EXTEND(CURRENT, YEAR TO SECOND)
   
   INSERT INTO gi_ad_ap_912(       
      cod_empresa,   
      id_ad,         
      cod_obrigacao, 
      cod_fatura,    
      num_ad,        
      num_ap,        
      dat_gravacao) VALUES(
      mr_ad_mestre.cod_empresa,
      mr_nota.id_ad,
      mr_nota.cod_obrigacao,
      mr_nota.cod_fatura,
      mr_ad_mestre.num_ad,
      mr_ap.num_ap,
      l_dat_hor)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo dados na gi_ad_ap_912.'                    
      RETURN FALSE
   END IF

   LET l_manut = 'POL1328 - INCLUSAO DA AP No. ', mr_ap.num_ap USING '<<<<<<'
   LET l_hora = TIME
   LET l_data = TODAY
   
   LET l_num_seq = pol1328_le_audit(mr_ap.cod_empresa, mr_ap.num_ap, '2')
   
   INSERT INTO audit_cap
      VALUES(mr_ap.cod_empresa,
             '1',
             p_user,
             mr_ap.num_ap,
             '2',
             mr_ad_mestre.num_nf,
             mr_ad_mestre.ser_nf,
             mr_ad_mestre.ssr_nf,
             mr_ad_mestre.cod_fornecedor,
             'I',
             l_num_seq,
             l_manut,
             l_data,
             l_hora,
             mr_ad_mestre.num_lote_transf)
             
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'                                                                 
      LET m_msg = 'Erro de status: ',m_erro                                                             
      LET m_msg = m_msg CLIPPED, ' inserindo dados da AP na audit_cap.'                    
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1328_insere_ap_valores()#
#-----------------------------------#
   
   DEFINE lr_gi_ap_valor RECORD
           num_seq                     INTEGER,     
           id_ad                       INTEGER,      
           id_ap                       INTEGER,      
           cod_empresa                 CHAR(2),      
           cod_fatura                  INTEGER,      
           cod_tip_valor               INTEGER,      
           valor                       DECIMAL(15,2)
   END RECORD

   DECLARE cq_ins_ap_valores CURSOR FOR
    SELECT *
      FROM gi_ap_valores_912
     WHERE id_ad = mr_nota.id_ad
       AND id_ap = mr_gi_ap.id_ap
       AND valor > 0
     ORDER BY num_seq
   
   FOREACH cq_ins_ap_valores INTO lr_gi_ap_valor.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela gi_ap_valores_912.'
         EXIT FOREACH
      END IF

      INSERT INTO ap_valores (
       cod_empresa,
       num_ap,
       num_versao,
       ies_versao_atual,
       num_seq,
       cod_tip_val,
       valor)
      VALUES(mr_ap.cod_empresa,
             mr_ap.num_ap,
             mr_ap.num_versao,
             mr_ap.ies_versao_atual,
             lr_gi_ap_valor.num_seq,
             lr_gi_ap_valor.cod_tip_valor,
             lr_gi_ap_valor.valor)

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela ap_valores.'
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF m_erro IS NOT NULL THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1328_le_tip_valaor()#
#-------------------------------#
   
   DEFINE l_cod_retencao      LIKE tip_desp_x_irrf.cod_retencao,
          l_ies_irrf          CHAR(01)
   
   LET m_cod_retencao = NULL
   
   DECLARE cq_ret CURSOR FOR 
    SELECT cod_retencao      
      FROM tip_desp_x_irrf  
     WHERE cod_empresa = m_cod_emp_ad 
       AND cod_tip_despesa = mr_nota.cod_tip_despesa
   
   FOREACH cq_ret INTO l_cod_retencao

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo cod retencao da tabela tip_desp_x_irrf.'
         RETURN FALSE
      END IF
      
      LET m_cod_retencao = l_cod_retencao
      EXIT FOREACH
   
   END FOREACH      
   
   IF m_cod_retencao IS NULL OR m_cod_retencao = ' ' THEN
      RETURN TRUE
   END IF
   
   IF m_for_juridic = 'J' THEN 
      LET l_ies_irrf = 'J'
   ELSE
      LET l_ies_irrf = 'F'
   END IF
   
   DECLARE cq_tip_val CURSOR FOR
    SELECT cod_tip_val, 
           perc_val_princ 
      FROM tipo_valor  
     WHERE cod_empresa = m_cod_emp_ad
       AND cod_irrf = m_cod_retencao
       AND ies_irrf = l_ies_irrf
       #AND IES_AD_AP = '2'
   
   FOREACH cq_tip_val INTO m_cod_tip_val, m_perc_val_princ
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registro na tabela tipo_valor.'
         RETURN FALSE
      END IF
      
      LET m_irrf = TRUE
      EXIT FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1328_ins_irrf_pg()#
#-----------------------------#

   CALL pol1328_le_dependentes(mr_ad_mestre.cod_fornecedor)
       
   LET m_dat_refer = EXTEND(mr_ad_mestre.dat_venc, YEAR TO MONTH)
   LET m_mes_ref   = MONTH(mr_ad_mestre.dat_venc)
   LET m_ano_ref   = YEAR(mr_ad_mestre.dat_venc)

   IF LENGTH(m_mes_ref) < 2 THEN
      LET m_mes_ref = '0',m_mes_ref CLIPPED
   END IF

   SELECT val_desc_depend,
          val_min_desc_irrf
     INTO m_val_desc_dp,
          m_val_min
     FROM par_folha_mes  
    WHERE to_char(dat_referencia, 'YYYY-MM') = m_dat_refer

   IF STATUS <> 0 OR m_val_desc_dp IS NULL THEN
      LET m_val_desc_dp = 0
   END IF   
   
   LET m_val_desc_tot = m_val_desc_dp * m_qtd_depend
      
   IF m_val_desc_tot IS NULL THEN
      LET m_val_desc_tot = 0
   END IF
   
   LET m_val_base = mr_ad_mestre.val_tot_nf - m_val_desc_tot
   
   LET m_val_parcel_deduz = NULL
   LET m_pct_desc_irrf = NULL
   
   DECLARE cq_tabela_irrf CURSOR FOR
    SELECT lmt_sup_sal, 
           val_parcel_deduz, 
           pct_desc_irrf
      FROM irrf  
     WHERE to_char(ano_ref, 'YYYY') = m_ano_ref 
       AND to_char(mes_ref, 'MM') = m_mes_ref 
     ORDER BY lmt_sup_sal ASC

   FOREACH cq_tabela_irrf INTO 
      m_lmt_sup_sal, m_val_parcel_deduz, m_pct_desc_irrf

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registro na tabela irrf.'
         RETURN FALSE
      END IF

      IF m_lmt_sup_sal >= m_val_base THEN  
         EXIT FOREACH
      END IF
     
   END FOREACH
   
   IF m_val_parcel_deduz IS NULL THEN
      LET m_val_parcel_deduz = 0
   END IF

   IF m_pct_desc_irrf IS NULL THEN
      LET m_pct_desc_irrf = 0
   END IF
                     
   LET m_val_irrf = (m_val_base * m_pct_desc_irrf / 100) - m_val_parcel_deduz
   
   IF m_val_irrf IS NULL THEN
      LET m_val_irrf = 0
   END IF
   
   #IF m_val_irrf < 10 THEN
   #   LET m_val_irrf = 0
   #END IF
   
   INITIALIZE mr_reten_irrf_pg TO NULL        

   LET mr_reten_irrf_pg.cod_empresa = mr_ad_mestre.cod_empresa           
   LET mr_reten_irrf_pg.num_ad = mr_ad_mestre.num_ad     
   LET mr_reten_irrf_pg.num_nf = mr_ad_mestre.num_nf       
   LET mr_reten_irrf_pg.ser_nf = mr_ad_mestre.ser_nf        
   LET mr_reten_irrf_pg.ssr_nf = mr_ad_mestre.ssr_nf       
   LET mr_reten_irrf_pg.ies_especie_nf = m_ies_especie_nf   
   LET mr_reten_irrf_pg.cod_fornecedor = mr_ad_mestre.cod_fornecedor   
   LET mr_reten_irrf_pg.cod_tip_val = m_cod_tip_val  
   LET mr_reten_irrf_pg.val_base_calc = m_val_base 
   LET mr_reten_irrf_pg.val_pensao = 0   
   LET mr_reten_irrf_pg.val_inss = 0     
   LET mr_reten_irrf_pg.val_depend = m_val_desc_tot   
   LET mr_reten_irrf_pg.val_irrf = m_val_irrf      
   
   DELETE FROM reten_irrf_pg
    WHERE cod_empresa = mr_reten_irrf_pg.cod_empresa
      AND num_nf = mr_reten_irrf_pg.num_nf
      AND ser_nf = mr_reten_irrf_pg.ser_nf
      AND ssr_nf = mr_reten_irrf_pg.ssr_nf
      AND cod_fornecedor = mr_reten_irrf_pg.cod_fornecedor
   
   INSERT INTO reten_irrf_pg VALUES(mr_reten_irrf_pg.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela reten_irrf_pg.'
      RETURN FALSE
   END IF

   DELETE FROM cap_irrf_aluguel  
    WHERE empresa = mr_reten_irrf_pg.cod_empresa 
      AND apropr_desp = mr_reten_irrf_pg.num_ad
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro na tabela cap_irrf_aluguel.'
      RETURN FALSE
   END IF
     
   INSERT INTO cap_irrf_aluguel(
     empresa, fornecedor, apropr_desp, val_bas_calc, val_irrf) 
   VALUES(mr_reten_irrf_pg.cod_empresa,
          mr_reten_irrf_pg.cod_fornecedor,
          mr_reten_irrf_pg.num_ad,
          m_val_base,
          m_val_irrf)
  
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela cap_irrf_aluguel.'
      RETURN FALSE
   END IF

   DELETE FROM cap_imposto_complementar  
    WHERE empresa = mr_ad_mestre.cod_empresa 
      AND ad_ap_nf_origem = mr_ad_mestre.num_ad 

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro na tabela cap_imposto_complementar.'
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_cap_imposto('tipo_isencao', 'Tipo de isen��o de rendimentos') THEN
      RETURN FALSE
   END IF

   IF NOT pol1328_ins_cap_imposto('desc_rend_isento', 'Descri��o do rendimento isento/N�o tributado') THEN
      RETURN FALSE
   END IF
    
   LET m_pct_irrf = m_val_irrf / mr_ad_mestre.val_tot_nf
   LET m_pct_desc = m_val_desc_tot / mr_ad_mestre.val_tot_nf
   LET m_ies_ir_ap = TRUE
   
   RETURN TRUE
                                      
END FUNCTION

#------------------------------------------------#
FUNCTION pol1328_ins_cap_imposto(l_param, l_desc)#
#------------------------------------------------#
   
   DEFINE l_param    VARCHAR(20),
          l_desc     VARCHAR(50),
          l_ind      VARCHAR(01)
   
   LET l_ind = '1'
   
   INSERT INTO cap_imposto_complementar (
      empresa, 
      ad_ap_nf_origem, 
      ind_ad_ap_nota_fiscal_origem, 
      serie_nota_fiscal, 
      subserie_nota_fiscal, 
      especie_nota_fiscal, 
      fornecedor, 
      tip_imposto, 
      dat_ocorrencia, 
      parametro, 
      descricao_parametro, 
      parametro_dat) 
   VALUES(mr_ad_mestre.cod_empresa,
          mr_ad_mestre.num_ad,
          l_ind, 
          mr_ad_mestre.ser_nf, 
          mr_ad_mestre.ssr_nf, 
          m_ies_especie_nf,    
          mr_ad_mestre.cod_fornecedor,
          'IRRF',
          m_dat_emissao,
          l_param,
          l_desc,
          m_dat_emissao)
           
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela cap_imposto_complementar.'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1328_ins_irrf_ap()#
#-----------------------------#
   
   DEFINE l_val_ap          DECIMAL(12,2),
          l_base_calc       DECIMAL(12,2),
          l_cod_tip_val     LIKE ap_valores.cod_tip_val,
          l_valor           LIKE ap_valores.valor,
          l_ies_tipo        CHAR(01),
          l_val_juros       DECIMAL(12,2)
   
   IF m_val_sem_ir > 0 THEN
      LET m_val_acres = m_val_sem_ir * (mr_gi_ap.val_nom_ap / m_val_com_ir)
   ELSE
      LET m_val_acres = 0 
   END IF
   
   LET l_val_juros = 0
   
   {DECLARE cq_valor CURSOR FOR                                            
    SELECT cod_tip_val, valor                                                
      FROM ap_valores                                                        
     WHERE cod_empresa = mr_ap.cod_empresa                                   
       AND num_ap = mr_ap.num_ap                                             
       AND ies_versao_atual = 'S'                                            
                                                                          
   FOREACH cq_valor INTO l_cod_tip_val, l_valor                              
                                                                          
      IF STATUS <> 0 THEN                                                    
         LET m_erro = STATUS USING '<<<<<'                                   
         LET m_msg = 'Erro de status: ',m_erro                               
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela ap_valores'      
         RETURN FALSE                                                        
      END IF                                                                 
                                                                             
      SELECT ies_alt_val_pag                                                 
        INTO l_ies_tipo                                                      
        FROM tipo_valor                                                      
       WHERE cod_empresa = mr_ap.cod_empresa                                     
         AND cod_tip_val = l_cod_tip_val                                     
         AND ies_juros = 'S'                                                 
         AND ies_ad_ap = '2'                                                 
                                                                          
      IF STATUS = 0 THEN                                                     
         IF l_ies_tipo = '+' THEN                                            
            LET l_val_juros = l_val_juros + l_valor              
         END IF                                                              
      ELSE                                                                   
         IF STATUS <> 100 THEN                                               
            LET m_erro = STATUS USING '<<<<<'                                
            LET m_msg = 'Erro de status: ',m_erro                            
            LET m_msg = m_msg CLIPPED, ' lendo dados da tabela tipo_valor'   
            RETURN FALSE                                                     
         END IF                                                              
      END IF                                                                 
                                                                             
   END FOREACH    }                                                           
                                                                            
   LET l_val_ap = mr_gi_ap.val_nom_ap + m_val_acres 
   LET l_base_calc = l_val_ap + l_val_juros
   LET m_val_irrf = l_base_calc * m_pct_irrf
   LET m_val_desc_tot = l_val_ap * m_pct_desc   
   LET m_val_base = l_val_ap - m_val_desc_tot
   
   INITIALIZE mr_reten_irrf_ap TO NULL
   
   LET mr_reten_irrf_ap.cod_empresa = mr_ap.cod_empresa  
   LET mr_reten_irrf_ap.num_ap = mr_ap.num_ap           
   LET mr_reten_irrf_ap.num_versao = mr_ap.num_versao      
   LET mr_reten_irrf_ap.ies_versao_atual = mr_ap.ies_versao_atual 
   LET mr_reten_irrf_ap.cod_tip_val = m_cod_tip_val     
   LET mr_reten_irrf_ap.val_base_calc = l_val_ap   
   LET mr_reten_irrf_ap.val_depend = m_val_desc_tot      
   LET mr_reten_irrf_ap.val_pensao = 0      
   LET mr_reten_irrf_ap.val_inss = 0       
   LET mr_reten_irrf_ap.val_irrf = m_val_irrf       

   INSERT INTO reten_irrf_ap VALUES(mr_reten_irrf_ap.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela reten_irrf_ap.'
      RETURN FALSE
   END IF
      
   RETURN TRUE
                                      
END FUNCTION

#----------------------------------------#
FUNCTION pol1328_le_dependentes(l_fornec)#
#----------------------------------------#

   DEFINE l_fornec         LIKE fornec_depen.cod_fornecedor,
          l_data_nasc      LIKE fornec_depen.data_nasc_depen,
          l_grau           LIKE fornec_depen.ies_grau_parent,
          l_idade_dia      INTEGER,
          l_idade_ano      INTEGER
   
   LET m_qtd_depend = 0
   
   DECLARE cq_depend CURSOR FOR   
   SELECT data_nasc_depen, 
          ies_grau_parent
     FROM fornec_depen  
    WHERE cod_fornecedor = l_fornec
      AND ies_grau_parent in ('C','M','U','I')
   
   FOREACH cq_depend INTO l_data_nasc, l_grau
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','fornec_depen')
         LET m_qtd_depend = 0
         RETURN
      END IF
      
      IF l_grau = 'M' THEN
         LET l_idade_dia = TODAY - l_data_nasc
         LET l_idade_ano = l_idade_dia / 365
         IF l_idade_ano < 21 THEN
            LET m_qtd_depend = m_qtd_depend + 1
         END IF
      ELSE
         IF l_grau = 'U' THEN
            LET l_idade_dia = TODAY - l_data_nasc
            LET l_idade_ano = l_idade_dia / 365
            IF l_idade_ano >= 21 AND l_idade_ano <= 24 THEN
               LET m_qtd_depend = m_qtd_depend + 1
            END IF
         ELSE
             LET m_qtd_depend = m_qtd_depend + 1
         END IF
      END IF
       
   END FOREACH
   
END FUNCTION  

#----------------------------#
FUNCTION pol1328_gera_grade()#
#----------------------------#
   
   DEFINE l_cod_uni_funcio  LIKE usu_nivel_aut_cap.cod_uni_funcio
   DEFINE l_ies_aprov       CHAR(01)
   
   IF NOT pol1328_cria_temp() THEN
      RETURN FALSE
   END IF
   
   LET m_ies_aprov = FALSE
   LET l_ies_aprov = 'N'
      
   DECLARE cq_cursor CURSOR FOR
    SELECT * 
      FROM grade_aprov_cap  
     WHERE cod_empresa = m_cod_emp_ad
       AND ies_versao_atual = 'S' 
       AND ies_grade_efetiv = 'E' 
       AND cod_tip_desp_ini <= mr_nota.cod_tip_despesa
       AND cod_tip_desp_fim >= mr_nota.cod_tip_despesa
   
   FOREACH cq_cursor INTO mr_grade_aprov_cap.*
    
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo registros da tabela grade_aprov_cap.'
         RETURN FALSE
      END IF
      
      DECLARE cq_aprov_grade CURSOR FOR
       SELECT cod_nivel_autor 
         FROM aprov_grade 
        WHERE cod_empresa = mr_grade_aprov_cap.cod_empresa  
          AND num_versao = mr_grade_aprov_cap.num_versao
          AND num_linha_grade = mr_grade_aprov_cap.num_linha_grade
          
      FOREACH cq_aprov_grade INTO m_cod_nivel_autor
    
         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' lendo registros da tabela aprov_grade.'
            RETURN FALSE
         END IF
         
         DECLARE ci_busca_usuario CURSOR FOR
          SELECT cod_usuario 
            FROM usu_nivel_aut_cap  
           WHERE ies_versao_atual = 'S' 
             AND cod_empresa = mr_grade_aprov_cap.cod_empresa
             AND cod_uni_funcio = m_cod_uni_funcio 
             AND cod_nivel_autor = m_cod_nivel_autor
             AND ies_ativo = 'S'
         
         FOREACH ci_busca_usuario INTO m_cod_user

            IF STATUS <> 0 THEN
               LET m_erro = STATUS USING '<<<<<'
               LET m_msg = 'Erro de status: ',m_erro
               LET m_msg = m_msg CLIPPED, ' lendo registros da tabela usu_nivel_aut_cap.'
               RETURN FALSE
            END IF

            SELECT nom_funcionario, 
                   e_mail 
              INTO m_nom_user,
                   m_email_user
              FROM usuarios  
             WHERE cod_usuario = m_cod_user     

            IF STATUS <> 0 THEN
               LET m_erro = STATUS USING '<<<<<'
               LET m_msg = 'Erro de status: ',m_erro
               LET m_msg = m_msg CLIPPED, ' lendo registros da tabela usuarios.'
               RETURN FALSE
            END IF
            
            INSERT INTO w_usuario_912
             VALUES(m_cod_user, m_nom_user, m_email_user,' ')

            IF STATUS <> 0 THEN
               LET m_erro = STATUS USING '<<<<<'
               LET m_msg = 'Erro de status: ',m_erro
               LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela w_usuario_912.'
               RETURN FALSE
            END IF
         
         END FOREACH
         
         DELETE FROM aprov_necessaria  
          WHERE cod_empresa = mr_grade_aprov_cap.cod_empresa
            AND num_ad = mr_ad_mestre.num_ad
            AND cod_nivel_autor = m_cod_nivel_autor

         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' deletando registro da tabela aprov_necessaria.'
            RETURN FALSE
         END IF
         
         INSERT INTO aprov_necessaria (
           cod_empresa,      
           num_ad,           
           num_versao,       
           num_linha_grade,  
           cod_nivel_autor,  
           cod_uni_funcio,   
           ies_aprovado)
        VALUES(mr_grade_aprov_cap.cod_empresa,
               mr_ad_mestre.num_ad,
               mr_grade_aprov_cap.num_versao,
               mr_grade_aprov_cap.num_linha_grade,
               m_cod_nivel_autor,
               m_cod_uni_funcio,
               l_ies_aprov)
  
         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' inserindo registro da tabela aprov_necessaria.'
            RETURN FALSE
         END IF
         
         LET m_ies_aprov = TRUE
         
      END FOREACH
         
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1328_cria_temp()#
#---------------------------#
   
   DROP TABLE w_usuario_912;
   CREATE TEMP TABLE w_usuario_912 (
      cod_usuario   CHAR(8), 
      nom_usuario   CHAR(30), 
      e_mail        CHAR(40), 
      cod_cent_cust CHAR(11)
   );
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' criando w_usuario_912.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------#   
FUNCTION pol1328_pgto_ap()#
#-------------------------#
   
   DEFINE l_dat_pgto     DATE,
          l_id_ap        INTEGER, 
          l_cod_empresa  CHAR(02), 
          l_num_ap       INTEGER
          
   DECLARE cq_pgto CURSOR FOR
    SELECT gi_ap_912.id_ap,
           gi_ap_912.cod_empresa,
           gi_ap_912.num_ap
      FROM gi_ap_912, gi_ad_912
     WHERE gi_ad_912.id_ad = gi_ap_912.id_ad
       AND gi_ad_912.cod_situacao <> 'E'
       AND gi_ap_912.dt_pagamento IS NULL 
       AND gi_ap_912.num_ap IS NOT NULL

   FOREACH cq_pgto INTO l_id_ap, l_cod_empresa, l_num_ap
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo gi_ap_912:cq_pgto'
         RETURN FALSE
      END IF
      
      SELECT dat_pgto
        INTO l_dat_pgto
        FROM ap
       WHERE cod_empresa = m_cod_emp_ad
         AND num_ap = l_num_ap
         AND ies_versao_atual = 'S'
     
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo ap: ', l_num_ap USING '<<<<<<', ':cq_pgto'
         RETURN FALSE
      END IF
      
      IF l_dat_pgto IS NOT NULL THEN
         UPDATE gi_ap_912 SET dt_pagamento = l_dat_pgto
          WHERE id_ap = l_id_ap
            AND cod_empresa = l_cod_empresa
            AND num_ap = l_num_ap

         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' ATUALIZANDO gi_ap_912: ', l_num_ap USING '<<<<<<',':cq_pgto'
            RETURN FALSE
         END IF
      
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1328_exclusao()#
#--------------------------#
   
   DEFINE l_ies_deleta SMALLINT
   
   DEFINE l_nota      RECORD
   id_ad              	INTEGER,              
   cod_empresa        	CHAR(2),               
   num_ad               DECIMAL(6,0),           	
   num_ar             	INTEGER,               
   ser_nf             	CHAR(03),              
   ssr_nf             	DECIMAL(2,0),          
   num_nf             	DECIMAL(7),                          
   cod_fornecedor     	CHAR(15),
   ies_gera_nota        CHAR(01)               
   END RECORD
   
   DECLARE cq_exclui CURSOR FOR
    SELECT id_ad,                              
           cod_empresa,    
           num_ad,         
           num_ar,         
           ser_nf,         
           ssr_nf,         
           num_nf,         
           cod_fornecedor,
           ies_gera_nota 
      FROM gi_ad_912
     WHERE cod_situacao = 'S' 
       AND num_ad IS NOT NULL
       AND num_ad > 0

   FOREACH cq_exclui INTO l_nota.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo gi_ad_912:cq_exclui'
         RETURN FALSE
      END IF
      
      LET l_ies_deleta = FALSE
      
      SELECT 1 FROM ad_mestre                                               
       WHERE cod_empresa = l_nota.cod_empresa                               
         AND num_ad = l_nota.num_ad                                 
                                                                         
      IF STATUS = 100 THEN                                                  
         IF NOT pol1328_atu_gi_ad_912(l_nota.cod_empresa, l_nota.id_ad) THEN
            RETURN FALSE
         END IF
      ELSE                                                                  
         IF STATUS <> 0 THEN                                                
            LET m_erro = STATUS USING '<<<<<'                               
            LET m_msg = 'Erro de status: ',m_erro                           
            LET m_msg = m_msg CLIPPED, ' lendo nf_sup:cq_exclui'            
            RETURN FALSE                                                    
         END IF                                                             
      END IF                                                                
         
   END FOREACH

END FUNCTION   

#-------------------------------------------------#
FUNCTION pol1328_atu_gi_ad_912(l_empresa, l_id_ad)#
#-------------------------------------------------#
   
   DEFINE l_empresa      CHAR(02),
          l_id_ad        INTEGER

   UPDATE gi_ad_912 SET cod_situacao = 'E'                                               
    WHERE cod_empresa = l_empresa                               
      AND id_ad = l_id_ad                                  
                                                                         
   IF STATUS <> 0 THEN                                                
      LET m_erro = STATUS USING '<<<<<'                               
      LET m_msg = 'Erro de status: ',m_erro                           
      LET m_msg = m_msg CLIPPED, ' cancelando registro da gi_ad_912'            
      RETURN FALSE                                                    
   END IF                                                             
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1328_del_ad_sem_ap()#
#-------------------------------#
   
   DEFINE l_cod_fatura    INTEGER,
          l_num_seq       INTEGER,
          l_manut         VARCHAR(50),
          l_hora          LIKE audit_cap.hora_manut,
          l_data          LIKE audit_cap.data_manut,
          l_num_ad        INTEGER,
          l_gera_nota     CHAR(01),
          l_num_ar        INTEGER
   
   LET m_msg = 'AD sem a AP '

   DECLARE cq_del_ad CURSOR WITH HOLD FOR
    SELECT a.cod_empresa, 
           a.num_ad,
           a.ser_nf,  
           a.ssr_nf,  
           a.num_nf,
           a.cod_fornecedor,  
           c.id_ad,
           c.cod_fatura,
           c.ies_gera_nota,
           c.num_ar
      FROM ad_mestre a, gi_ad_912 c
     WHERE a.cod_empresa = c.cod_empresa
       AND a.num_ad = c.num_ad
       AND a.dat_venc > '01/01/2018'
       AND a.num_ad NOT IN(
           SELECT b.num_ad FROM ad_ap b   
            WHERE b.cod_empresa = a.cod_empresa)
       
   FOREACH cq_del_ad INTO 
           p_cod_empresa, 
           l_num_ad, 
           mr_ad_mestre.ser_nf,
           mr_ad_mestre.ssr_nf,
           mr_ad_mestre.num_nf,
           mr_ad_mestre.cod_fornecedor,
           m_id_ad, 
           l_cod_fatura,
           l_gera_nota,
           l_num_ar
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
      
      DELETE FROM ad_mestre WHERE cod_empresa = p_cod_empresa AND num_ad = l_num_ad
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF

      DELETE FROM ad_aen_4 WHERE cod_empresa = p_cod_empresa AND num_ad = l_num_ad
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
      
      DELETE FROM ad_valores WHERE cod_empresa = p_cod_empresa AND num_ad = l_num_ad
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF

      DELETE FROM reten_irrf_pg WHERE cod_empresa = p_cod_empresa AND num_ad = l_num_ad
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
      
      DELETE FROM aprov_necessaria WHERE cod_empresa = p_cod_empresa AND num_ad = l_num_ad
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF

      DELETE FROM ctb_lanc_ctbl_cap 
       WHERE empresa = p_cod_empresa 
         AND num_ad_ap = l_num_ad
         AND eh_ad_ap = '1'
        
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF

      DELETE FROM lanc_cont_cap 
       WHERE cod_empresa = p_cod_empresa 
         AND num_ad_ap = l_num_ad
         AND  ies_ad_ap = '1'
      
      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
      
      SELECT MAX(num_seq) INTO l_num_seq
        FROM gi_ad_erro_912
       WHERE id_ad = m_id_ad
      
      IF STATUS <> 0 THEN 
         RETURN FALSE
      END IF
      
      IF l_num_seq IS NULL THEN
         LET l_num_seq = 0
      END IF
      
      LET l_num_seq = l_num_seq + 1  

      INSERT INTO gi_ad_erro_912(
        id_ad, cod_empresa, cod_fatura, num_seq, den_erro)
      VALUES(m_id_ad, p_cod_empresa, l_cod_fatura, l_num_seq, m_msg)

      IF STATUS <> 0 THEN 
         RETURN FALSE
      END IF

      UPDATE gi_ad_912 SET cod_situacao = 'C'
          WHERE id_ad = m_id_ad

      IF STATUS <> 0 THEN 
         RETURN FALSE
      END IF

      LET l_manut = 'POL1328 - EXCLUS�O DA AD No. ', l_num_ad USING '<<<<<<<'                                                                         
      LET l_data = TODAY
      LET l_hora = TIME

      LET l_num_seq = pol1328_le_audit(p_cod_empresa, l_num_ad, '1')

      INSERT INTO audit_cap
      VALUES(p_cod_empresa,
             '1',
             p_user,
             l_num_ad,
             '1',
             mr_ad_mestre.num_nf,
             mr_ad_mestre.ser_nf,
             mr_ad_mestre.ssr_nf,
             mr_ad_mestre.cod_fornecedor,
             'E',
             l_num_seq,
             l_manut,
             l_data,
             l_hora,
             '0')

      IF STATUS <> 0 THEN 
         RETURN FALSE
      END IF
      
      IF l_gera_nota = 'S' AND l_num_ar > 0 THEN
         UPDATE nf_sup SET ies_incl_cap = 'N'
          WHERE cod_empresa = p_cod_empresa
            AND num_aviso_rec = l_num_ar

         IF STATUS <> 0 THEN 
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1328_version_info()#
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/pol1328.4gl $|$Revision: 139 $|$Date: 17/02/21 15:56 $|$Modtime:  $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)
 END FUNCTION
