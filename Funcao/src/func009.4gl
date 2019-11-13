#---------------------------------------------------------------#
#-------Objetivo: gerar  título no CAP--------------------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#--------------------------parâmetros---------------------------#
# Informações básicas, conforme RECORD mr_ad logo abaixo        #
#--------------------------retorno numérico---------------------#
#       número da AD, para sucesso na operação;                 #
#       ou -1, para falha na operação                           #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          p_user                 CHAR(08)

END GLOBALS

DEFINE mr_ad             RECORD
       emissao           DATE,
       valor             DECIMAL(12,2),
       cod_fornecedor    CHAR(15),
       cod_tip_despesa   DECIMAL(4,0),
       num_ad            INTEGER,
       num_nf            INTEGER,
       ser_nf            CHAR(3),
       ssr_nf            DECIMAL(2,0),
       dat_emis_nf       DATE,
       dat_rec_nf        DATE,
       cod_cent_cust     DECIMAL(5,0),
       dat_venc          DATE,
       cod_moeda         INTEGER,
       cod_tip_ad        INTEGER,
       ies_sup_cap       CHAR(03),
       cnd_pgto          INTEGER,
       cod_empresa       CHAR(02),
       cod_aen           CHAR(08),
       nom_programa      CHAR(08),
       tex_hist          CHAR(50)
END RECORD       

DEFINE mr_ad_mestre      RECORD LIKE ad_mestre.*,
       mr_lanc_cont_cap  RECORD LIKE lanc_cont_cap.*,
       mr_ctb_lanc       RECORD LIKE ctb_lanc_ctbl_cap.*,   
       mr_ap             RECORD LIKE ap.*
       
DEFINE m_cod_emp_orig     CHAR(02),
       m_num_ap           INTEGER,
       m_num_parcela      INTEGER,
       m_qtd_parcelas     INTEGER,
       m_msg              CHAR(150),
       m_dat_vencto       DATE,
       m_val_parcela      DECIMAL(12,2),
       m_seql_lanc_cap    INTEGER

DEFINE m_num_conta_deb    LIKE tipo_despesa.num_conta_deb,
       m_num_conta_cred   LIKE tipo_despesa.num_conta_cred,
       m_cod_hist_deb_ap  LIKE tipo_despesa.cod_hist_deb_ap

       

#------------------------------#
FUNCTION func009_gera_ad(lr_ad)#
#------------------------------#

   DEFINE lr_ad          RECORD
       emissao           DATE,
       valor             DECIMAL(12,2),
       cod_fornecedor    CHAR(15),
       cod_tip_despesa   DECIMAL(4,0),
       num_ad            INTEGER,
       num_nf            INTEGER,
       ser_nf            CHAR(3),
       ssr_nf            DECIMAL(2,0),
       dat_emis_nf       DATE,
       dat_rec_nf        DATE,
       cod_cent_cust     DECIMAL(5,0),
       dat_venc          DATE,
       cod_moeda         INTEGER,
       cod_tip_ad        INTEGER,
       ies_sup_cap       CHAR(03),
       cnd_pgto          INTEGER,
       cod_empresa       CHAR(02),
       cod_aen           CHAR(08),
       nom_programa      CHAR(08),
       tex_hist          CHAR(50)
   END RECORD       

   LET mr_ad.* = lr_ad.*
   
   IF NOT func009_processa() THEN
      RETURN -1
   END IF
   
   RETURN mr_ad_mestre.num_ad

END FUNCTION

#--------------------------#
FUNCTION func009_processa()#
#--------------------------#
   
   DEFINE l_msg       LIKE audit_cap.desc_manut
   
   IF NOT func009_le_par_ad() THEN
      RETURN FALSE
   END IF
   
   LET m_cod_emp_orig = func009_le_emp_orig_dest()

   IF NOT func009_insere_ad() THEN
      RETURN FALSE
   END IF

   LET l_msg = mr_ad_mestre.num_ad USING '<<<<<<'
   LET l_msg = mr_ad.nom_programa, ' - INCLUSAO DA AD No. ', l_msg CLIPPED
   
   IF NOT func009_ins_audit(mr_ad_mestre.num_ad, '1', l_msg) THEN
      RETURN FALSE
   END IF

   IF NOT func009_ins_cent_custo() THEN
      RETURN FALSE
   END IF

   IF NOT func009_ins_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT func009_ins_ad_aen() THEN
      RETURN FALSE
   END IF      
   
   IF NOT func009_grava_ap() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION func009_le_par_ad()#
#---------------------------#

   SELECT ult_num_ad
     INTO mr_ad.num_ad
     FROM par_ad
    WHERE cod_empresa = mr_ad.cod_empresa

   IF STATUS = 100 THEN
      LET mr_ad.num_ad = 0
      IF NOT func009_ins_par_ad() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','par_ad')
         RETURN FALSE
      END IF
   END IF

   LET mr_ad.num_ad = mr_ad.num_ad + 1
      
   UPDATE par_ad SET ult_num_ad = mr_ad.num_ad
   WHERE cod_empresa = mr_ad.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_ad')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION func009_ins_par_ad()#
#----------------------------#

   DEFINE lr_par_ad     RECORD LIKE par_ad.*
   
   INITIALIZE lr_par_ad.* TO NULL
   
   LET lr_par_ad.cod_empresa = mr_ad.cod_empresa
   LET lr_par_ad.ies_area_linha_neg = 'N'
   LET lr_par_ad.ult_num_ad = 0
   LET lr_par_ad.ies_complem = 'N'    
   LET lr_par_ad.num_programa = 'POL1318' 
   LET lr_par_ad.tip_val_bx_adiant  = 0
   LET lr_par_ad.cod_tip_des_ad_div = 0
   LET lr_par_ad.set_aplic_ad_div  = 0
   LET lr_par_ad.cod_tip_ad_div = 0
   LET lr_par_ad.cod_tip_desp_comis = 0

   INSERT INTO par_ad
    VALUES(lr_par_ad.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','par_ad')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION       

#----------------------------------#
FUNCTION func009_le_emp_orig_dest()#
#----------------------------------#

   DEFINE l_empresa CHAR(02)
   
   SELECT cod_empresa_orig 
     INTO l_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_destin = mr_ad.cod_empresa
   
   IF STATUS <> 0 THEN
      LET l_empresa = mr_ad.cod_empresa
   END IF

   RETURN (l_empresa)
   
END FUNCTION

#---------------------------#
FUNCTION func009_insere_ad()#
#---------------------------#
   
   INITIALIZE mr_ad_mestre.* TO NULL
   
   LET mr_ad_mestre.cod_empresa       = mr_ad.cod_empresa
   LET mr_ad_mestre.num_ad            = mr_ad.num_ad
   LET mr_ad_mestre.cod_tip_despesa   = mr_ad.cod_tip_despesa 
   LET mr_ad_mestre.ser_nf            = mr_ad.ser_nf
   LET mr_ad_mestre.ssr_nf            = mr_ad.ssr_nf
   LET mr_ad_mestre.num_nf            = mr_ad.num_nf
   LET mr_ad_mestre.dat_emis_nf       = mr_ad.emissao
   LET mr_ad_mestre.dat_rec_nf        = mr_ad.emissao
   LET mr_ad_mestre.cod_empresa_estab = NULL
   LET mr_ad_mestre.mes_ano_compet    = NULL
   LET mr_ad_mestre.num_ord_forn      = NULL
   LET mr_ad_mestre.cnd_pgto          = NULL
   LET mr_ad_mestre.dat_venc          = mr_ad.dat_venc
   LET mr_ad_mestre.cod_fornecedor    = mr_ad.cod_fornecedor
   LET mr_ad_mestre.cod_portador      = NULL
   LET mr_ad_mestre.val_tot_nf        = mr_ad.valor
   LET mr_ad_mestre.val_saldo_ad      = mr_ad.valor
   LET mr_ad_mestre.cod_moeda         = mr_ad.cod_moeda
   LET mr_ad_mestre.set_aplicacao     = NULL
   LET mr_ad_mestre.cod_lote_pgto     = 1
   LET mr_ad_mestre.observ            = NULL
   LET mr_ad_mestre.cod_tip_ad        = mr_ad.cod_tip_ad
   LET mr_ad_mestre.ies_ap_autom      = 'S'
   LET mr_ad_mestre.ies_sup_cap       = mr_ad.ies_sup_cap
   LET mr_ad_mestre.ies_fatura        = 'N'
   LET mr_ad_mestre.ies_ad_cont       = 'N' 
   LET mr_ad_mestre.num_lote_transf   = 0
   LET mr_ad_mestre.ies_dep_cred      = 'N'
   LET mr_ad_mestre.num_lote_pat      = 0
   LET mr_ad_mestre.cod_empresa_orig  = m_cod_emp_orig

   INSERT INTO ad_mestre
      VALUES(mr_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ad_mestre')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------------------------#
FUNCTION func009_ins_audit(l_num, l_ies_ad_ap, l_msg)#
#----------------------------------------------------#

   DEFINE l_num        INTEGER,
          l_ies_ad_ap  CHAR(01),
          l_seq        INTEGER,
          l_msg        LIKE audit_cap.desc_manut

   DEFINE l_audit      RECORD LIKE audit_cap.*

   SELECT MAX(num_seq)
     INTO l_seq
     FROM audit_cap
    WHERE cod_empresa = mr_ad_mestre.cod_empresa
      AND num_ad_ap = l_num
      AND ies_ad_ap = l_ies_ad_ap

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','audit_cap')
      RETURN FALSE
   END IF
   
   IF l_seq IS NULL THEN
      LET l_seq = 0
   END IF
   
   LET l_seq = l_seq + 1    
             
   LET l_audit.cod_empresa = mr_ad_mestre.cod_empresa 
   LET l_audit.ies_tabela = '1'    
   LET l_audit.nom_usuario = p_user
   LET l_audit.num_ad_ap = l_num
   LET l_audit.ies_ad_ap = l_ies_ad_ap
   LET l_audit.num_nf = mr_ad_mestre.num_nf      
   LET l_audit.ser_nf = mr_ad_mestre.ser_nf      
   LET l_audit.ssr_nf = mr_ad_mestre.ssr_nf      
   LET l_audit.cod_fornecedor = mr_ad_mestre.cod_fornecedor
   LET l_audit.ies_manut = 'I'    
   LET l_audit.num_seq = l_seq    
   LET l_audit.desc_manut = l_msg 
   LET l_audit.data_manut = mr_ad_mestre.dat_emis_nf
   LET l_audit.hora_manut = CURRENT HOUR TO SECOND    
   LET l_audit.num_lote_transf = mr_ad_mestre.num_lote_transf

   INSERT INTO audit_cap
      VALUES(l_audit.*)
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','audit_cap')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func009_ins_lanc()#
#--------------------------#
   
   IF NOT func009_le_conta() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE mr_lanc_cont_cap.* TO NULL
   
   LET mr_lanc_cont_cap.cod_empresa        = mr_ad_mestre.cod_empresa
   LET mr_lanc_cont_cap.num_ad_ap          = mr_ad_mestre.num_ad
   LET mr_lanc_cont_cap.ies_ad_ap          = '1'
   LET mr_lanc_cont_cap.num_seq            = 1
   LET mr_lanc_cont_cap.cod_tip_desp_val   = mr_ad_mestre.cod_tip_despesa
   LET mr_lanc_cont_cap.ies_desp_val       = 'D'
   LET mr_lanc_cont_cap.ies_man_aut        = 'A'
   LET mr_lanc_cont_cap.ies_tipo_lanc      = 'D'
   LET mr_lanc_cont_cap.num_conta_cont     = m_num_conta_deb
   LET mr_lanc_cont_cap.val_lanc           = mr_ad_mestre.val_tot_nf
   LET mr_lanc_cont_cap.tex_hist_lanc      = mr_ad.tex_hist
   LET mr_lanc_cont_cap.ies_cnd_pgto       = 'N'
   LET mr_lanc_cont_cap.num_lote_lanc      = 0
   LET mr_lanc_cont_cap.ies_liberad_contab = 'N'
   LET mr_lanc_cont_cap.num_lote_transf    = mr_ad_mestre.num_lote_transf
   LET mr_lanc_cont_cap.dat_lanc           = mr_ad_mestre.dat_rec_nf

   INSERT INTO lanc_cont_cap
      VALUES(mr_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lanc_cont_cap:conta_debito')
      RETURN FALSE
   END IF

   LET mr_lanc_cont_cap.ies_tipo_lanc  = 'C'
   LET mr_lanc_cont_cap.num_conta_cont = m_num_conta_cred
   LET mr_lanc_cont_cap.num_seq = mr_lanc_cont_cap.num_seq + 1

   INSERT INTO lanc_cont_cap
      VALUES(mr_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','lanc_cont_cap:conta_credito')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION func009_le_conta()#
#--------------------------#

   DEFINE l_msg     CHAR(30)

   LET l_msg = 'tipo_despesa:',mr_ad.cod_empresa,'/',mr_ad.cod_tip_despesa
   
   SELECT num_conta_deb,
          num_conta_cred,
          cod_hist_deb_ap
     INTO m_num_conta_deb,
          m_num_conta_cred,
          m_cod_hist_deb_ap
     FROM tipo_despesa
    WHERE cod_empresa     = mr_ad.cod_empresa
      AND cod_tip_despesa = mr_ad.cod_tip_despesa

   IF STATUS = 100 THEN
      SELECT num_conta_deb,
             num_conta_cred,
             cod_hist_deb_ap
        INTO m_num_conta_deb,
             m_num_conta_cred,
             m_cod_hist_deb_ap
        FROM tipo_despesa
       WHERE cod_empresa     = p_cod_empresa
         AND cod_tip_despesa = mr_ad.cod_tip_despesa
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT',l_msg)
      RETURN FALSE
   END IF
   
   IF m_num_conta_deb IS NULL THEN
      LET m_num_conta_deb = 0
   END IF
   
   IF m_num_conta_cred IS NULL THEN
      LET m_num_conta_cred = 0
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION func009_ins_ctb_lanc(l_valor)# 
#-------------------------------------#

   DEFINE l_valor    DECIMAL(12,2)
   
   LET mr_ctb_lanc.empresa             = mr_lanc_cont_cap.cod_empresa                                              
   LET mr_ctb_lanc.periodo_contab      = YEAR(mr_lanc_cont_cap.dat_lanc)                                              
   LET mr_ctb_lanc.segmto_periodo      = MONTH(mr_lanc_cont_cap.dat_lanc)                                             
   LET mr_ctb_lanc.cta_deb             = m_num_conta_deb                                                             
   LET mr_ctb_lanc.cta_cre             = 0                                                                           
   LET mr_ctb_lanc.dat_movto           = mr_lanc_cont_cap.dat_lanc                                                    
   LET mr_ctb_lanc.dat_vencto          = NULL                                                                        
   LET mr_ctb_lanc.dat_conversao       = NULL                                                                        
   LET mr_ctb_lanc.val_lancto          = l_valor                                                                  
   LET mr_ctb_lanc.qtd_outra_moeda     = 0                                                                           
                                                                                                                     
   SELECT par_val                                                                                                 
     INTO mr_ctb_lanc.hist_padrao                                                                                    
     FROM par_cap_pad                                                                                                
    WHERE cod_empresa = mr_ctb_lanc.empresa                                                                          
      AND cod_parametro = 'cod_hist_lanc_anl'                                                                        
                                                                                                                     
   IF STATUS <> 0 THEN                                                                                            
      LET mr_ctb_lanc.hist_padrao = 0                                                                                
   END IF                                                                                                            
                                                                                                                     
   LET mr_ctb_lanc.compl_hist          = mr_lanc_cont_cap.tex_hist_lanc                                            
   LET mr_ctb_lanc.linha_produto       = mr_ad.cod_aen[1,2]                                                             
   LET mr_ctb_lanc.linha_receita       = mr_ad.cod_aen[3,4]
   LET mr_ctb_lanc.segmto_mercado      = mr_ad.cod_aen[5,6]                                                           
   LET mr_ctb_lanc.classe_uso          = mr_ad.cod_aen[7,8]                                                                                                                                                                                                                                                                                                     
   LET mr_ctb_lanc.lote_contab         = mr_lanc_cont_cap.num_lote_lanc                                            
   LET mr_ctb_lanc.num_lancto          = 0                                                                           
   LET mr_ctb_lanc.empresa_origem      = mr_lanc_cont_cap.cod_empresa                                                                                                                                                                                                                                                                                           
   LET mr_ctb_lanc.num_ad_ap           = mr_lanc_cont_cap.num_ad_ap                                                
   LET mr_ctb_lanc.eh_ad_ap            = mr_lanc_cont_cap.ies_ad_ap                                                   
   LET mr_ctb_lanc.seql_lanc_cap       = m_seql_lanc_cap                                                             
   LET mr_ctb_lanc.tip_despesa_val     = mr_lanc_cont_cap.cod_tip_desp_val                                            
   LET mr_ctb_lanc.eh_despesa_val      = mr_lanc_cont_cap.ies_desp_val                                                
   LET mr_ctb_lanc.eh_manual_autom     = mr_lanc_cont_cap.ies_man_aut                                                 
   LET mr_ctb_lanc.eh_cond_pagto       = mr_lanc_cont_cap.ies_cnd_pgto                                                
   LET mr_ctb_lanc.lote_transf         = mr_lanc_cont_cap.num_lote_transf                                             
   LET mr_ctb_lanc.banco_pagador       = NULL #igual ap                                                              
   LET mr_ctb_lanc.cta_bancaria        = NULL #igual ap                                                              
   LET mr_ctb_lanc.docum_pagto         = NULL                                                                        
   LET mr_ctb_lanc.tip_docum_pagto     = NULL                                                                        
   LET mr_ctb_lanc.fornecedor          = mr_ad_mestre.cod_fornecedor                                                  
   LET mr_ctb_lanc.liberado            = 'N'                                                                         

   LET mr_ctb_lanc.num_relacionto      = func009_busca_num_relacionto()                                           
                                                                                                                     
   IF mr_ctb_lanc.num_relacionto < 0 THEN                                                                         
      RETURN FALSE                                                                                                   
   END IF     

   LET mr_ctb_lanc.sequencia_registro  = func009_busca_sequencia_registro()                                       
                                                                                                                     
   IF mr_ctb_lanc.sequencia_registro < 0 THEN                                                                     
      RETURN FALSE                                                                                                   
   END IF                                                                                                            
                                                                                                                                                                                                                               
   INSERT INTO ctb_lanc_ctbl_cap                                                                                  
      VALUES(mr_ctb_lanc.*)                                                                                          
                                                                                                                     
   IF STATUS <> 0 THEN                                                                                            
      CALL log003_err_sql('INSERT','ctb_lanc_ctbl_cap:conta_debto')
      RETURN FALSE                                                                                                   
   END IF                                                                                                            
                                                                                                  
   LET mr_ctb_lanc.cta_deb = 0                                                                        
   LET mr_ctb_lanc.cta_cre = m_num_conta_cred     
   LET m_seql_lanc_cap = m_seql_lanc_cap + 1                                                       
   LET mr_ctb_lanc.seql_lanc_cap = m_seql_lanc_cap                                                                                                                                                                                  
   LET mr_ctb_lanc.sequencia_registro  = mr_ctb_lanc.sequencia_registro + 1                                       
                                                                                                                                                                                                                                     
   INSERT INTO ctb_lanc_ctbl_cap                                                                                  
      VALUES(mr_ctb_lanc.*)                                                                                          
                                                                                                                     
   IF STATUS <> 0 THEN                                                                                            
      CALL log003_err_sql('INSERT','ctb_lanc_ctbl_cap.conta_credito')      
      RETURN FALSE                                                                                                   
   END IF                                                                                                            
                                                                                                                     
   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION func009_busca_num_relacionto()#
#---------------------------------------#

   DEFINE l_num_relacionto DECIMAL(6,0)

   SELECT MAX(num_relacionto)
     INTO l_num_relacionto
     FROM ctb_lanc_ctbl_cap
    WHERE empresa        = mr_ctb_lanc.empresa
      AND periodo_contab = mr_ctb_lanc.periodo_contab
      AND segmto_periodo = mr_ctb_lanc.segmto_periodo

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','ctb_lanc_ctbl_cap')
      RETURN (-1)
   END IF

   IF l_num_relacionto IS NOT NULL THEN
      LET l_num_relacionto = l_num_relacionto + 1

      IF l_num_relacionto > 999999 THEN
         LET l_num_relacionto = 999999
      END IF
   ELSE
      LET l_num_relacionto = 1
   END IF

   RETURN l_num_relacionto

END FUNCTION

#------------------------------------------#
FUNCTION func009_busca_sequencia_registro()
#------------------------------------------#

   DEFINE l_sequencia_registro INTEGER

   SELECT MAX(sequencia_registro)
     INTO l_sequencia_registro
     FROM ctb_lanc_ctbl_cap
    WHERE empresa        = mr_ctb_lanc.empresa
      AND periodo_contab = mr_ctb_lanc.periodo_contab

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('SELECT','ctb_lanc_ctbl_cap')
      RETURN (-1)
   END IF

   IF l_sequencia_registro IS NULL THEN
      LET l_sequencia_registro = 0
   END IF

   LET l_sequencia_registro = l_sequencia_registro + 1

   RETURN (l_sequencia_registro)

END FUNCTION

#----------------------------#
FUNCTION func009_ins_ad_aen()#
#----------------------------#

   DEFINE lr_ad_aen   RECORD LIKE ad_aen_4.*

   LET lr_ad_aen.cod_empresa = mr_ad_mestre.cod_empresa     
   LET lr_ad_aen.num_ad = mr_ad_mestre.num_ad          
   LET m_seql_lanc_cap = 0
   
   DECLARE cq_aen CURSOR FOR
    SELECT cod_aen, 
           SUM(valor)
      FROM cent_cust_tmp_912
     WHERE empresa_dest = mr_ad_mestre.cod_empresa
       AND cod_aen IS NOT NULL
     GROUP BY cod_aen

   FOREACH cq_aen INTO
      mr_ad.cod_aen,
      lr_ad_aen.val_aen

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cent_cust_tmp_912:cq_aen')
         RETURN FALSE
      END IF
      
      IF mr_ad.cod_aen IS NULL OR mr_ad.cod_aen = '' THEN
         CONTINUE FOREACH
      END IF
      
      LET lr_ad_aen.cod_lin_prod = mr_ad.cod_aen[1,2]
      LET lr_ad_aen.cod_lin_recei = mr_ad.cod_aen[3,4]
      LET lr_ad_aen.cod_seg_merc = mr_ad.cod_aen[5,6]
      LET lr_ad_aen.cod_cla_uso = mr_ad.cod_aen[7,8]
   
      INSERT INTO ad_aen_4
       VALUES(lr_ad_aen.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','ad_aen')
         RETURN FALSE
      END IF

      LET m_seql_lanc_cap = m_seql_lanc_cap + 1
      
      IF NOT func009_ins_ctb_lanc(lr_ad_aen.val_aen) THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func009_ins_cent_custo()#
#--------------------------------#

   DEFINE lr_cent_custo   RECORD LIKE cap_ad_centro_custo.*

   LET lr_cent_custo.empresa = mr_ad_mestre.cod_empresa       
   LET lr_cent_custo.num_ad  = mr_ad_mestre.num_ad
   
   DECLARE cq_cent_cust CURSOR FOR
    SELECT cod_cent_cust, 
           valor
      FROM cent_cust_tmp_912
     WHERE empresa_dest = mr_ad_mestre.cod_empresa

   FOREACH cq_cent_cust INTO
      lr_cent_custo.centro_custo,
      lr_cent_custo.val_centro_custo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cent_cust_tmp_912:cq_cent_cust')
         RETURN FALSE
      END IF
   
      INSERT INTO cap_ad_centro_custo
       VALUES(lr_cent_custo.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT','cap_ad_centro_custo')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func009_grava_ap()#
#--------------------------#

   DEFINE l_pct_val_vencto     DECIMAL(5,2),
          l_val_gravado        DECIMAL(12,2),
          l_qtd_dias           INTEGER
          
    LET mr_ap.cod_empresa       = mr_ad_mestre.cod_empresa
    LET mr_ap.num_versao        = 1
    LET mr_ap.ies_versao_atual  = 'S'
    LET mr_ap.cod_portador      = NULL
    LET mr_ap.cod_bco_pagador   = NULL
    LET mr_ap.num_conta_banc    = NULL
    LET mr_ap.cod_fornecedor    = mr_ad_mestre.cod_fornecedor
    LET mr_ap.cod_banco_for     = NULL
    LET mr_ap.num_agencia_for   = NULL
    LET mr_ap.num_conta_bco_for = NULL
    LET mr_ap.num_nf            = mr_ad_mestre.num_nf
    LET mr_ap.num_duplicata     = NULL
    LET mr_ap.num_bl_awb        = NULL
    LET mr_ap.compl_docum       = NULL
    LET mr_ap.val_ap_dat_pgto   = 0
    LET mr_ap.cod_moeda         = mr_ad_mestre.cod_moeda
    LET mr_ap.val_jur_dia       = 0
    LET mr_ap.taxa_juros        = NULL
    LET mr_ap.cod_formula       = NULL
    LET mr_ap.dat_emis          = TODAY
    LET mr_ap.dat_vencto_c_desc = NULL
    LET mr_ap.val_desc          = NULL
    LET mr_ap.dat_pgto          = NULL
    LET mr_ap.dat_proposta      = NULL
    LET mr_ap.cod_lote_pgto     = 1
    LET mr_ap.num_docum_pgto    = NULL
    LET mr_ap.ies_lib_pgto_cap  = 'N'
    LET mr_ap.ies_lib_pgto_sup  = 'S'
    LET mr_ap.ies_baixada       = 'N'
    LET mr_ap.ies_docum_pgto    = NULL
    LET mr_ap.ies_ap_impressa   = 'N'
    LET mr_ap.ies_ap_contab     = 'N'
    LET mr_ap.num_lote_transf   = mr_ad_mestre.num_lote_transf
    LET mr_ap.ies_dep_cred      = 'N'
    LET mr_ap.data_receb        = NULL
    LET mr_ap.num_lote_rem_escr = 0
    LET mr_ap.num_lote_ret_escr = 0
    LET mr_ap.dat_rem           = NULL
    LET mr_ap.dat_ret           = NULL
    LET mr_ap.status_rem        = 0
    LET mr_ap.ies_form_pgto_escr= NULL
   
   IF mr_ad_mestre.cnd_pgto IS NULL THEN 
      LET m_dat_vencto  = mr_ad_mestre.dat_venc
      LET m_val_parcela = mr_ad_mestre.val_tot_nf
      LET m_num_parcela = 1
      IF NOT func009_ins_ap() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   SELECT COUNT(cnd_pgto)
     INTO m_qtd_parcelas
     FROM cond_pg_item_cap
    WHERE cnd_pgto = mr_ad_mestre.cnd_pgto

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cond_pg_item_cap:1')
      RETURN FALSE
   END IF
   
   IF m_qtd_parcelas = 0 THEN
      LET m_msg = 'Condição de pagamento ', mr_ad_mestre.cnd_pgto, '\n',
                  'não cadastrada.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   LET m_num_parcela = 1
   LET l_val_gravado = 0
     
   DECLARE cq_cnd_pagto CURSOR FOR
    SELECT qtd_dias,
           pct_val_vencto
      FROM cond_pg_item_cap
     WHERE cnd_pgto = mr_ad_mestre.cnd_pgto
       
   FOREACH cq_cnd_pagto INTO 
           l_qtd_dias,
           l_pct_val_vencto

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','cond_pg_item_cap')
         RETURN FALSE
      END IF
            
      IF m_num_parcela = m_qtd_parcelas THEN
         LET m_val_parcela = mr_ad_mestre.val_tot_nf - l_val_gravado
      ELSE
         LET m_val_parcela  = 
             mr_ad_mestre.val_tot_nf * l_pct_val_vencto / 100
      END IF
      
      LET l_val_gravado = l_val_gravado + m_val_parcela    
      LET m_dat_vencto  = mr_ad_mestre.dat_emis_nf + l_qtd_dias
      
      IF NOT func009_ins_ap() THEN
         RETURN FALSE
      END IF
      
      LET m_num_parcela = m_num_parcela + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION 
       
#------------------------#       
FUNCTION func009_ins_ap()#
#------------------------#

   DEFINE l_msg       LIKE audit_cap.desc_manut
   
   IF NOT func009_le_par_ap() THEN 
      RETURN FALSE
   END IF

   LET mr_ap.num_ap            = m_num_ap
   LET mr_ap.num_parcela       = m_num_parcela
   LET mr_ap.val_nom_ap        = m_val_parcela
   LET mr_ap.dat_vencto_s_desc = m_dat_vencto
   
   INSERT INTO ap
      VALUES(mr_ap.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ap')
      RETURN FALSE
   END IF
   
   INSERT INTO ap_tip_desp
    VALUES(mr_ap.cod_empresa,
           mr_ap.num_ap,
           m_num_conta_cred,
           m_cod_hist_deb_ap,
           mr_ad_mestre.cod_tip_despesa,
           mr_ap.val_nom_ap)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ap_tip_desp')
      RETURN FALSE
   END IF
      
   INSERT INTO ad_ap
      VALUES(mr_ap.cod_empresa,
             mr_ad_mestre.num_ad,
             mr_ap.num_ap,
             mr_ap.num_lote_transf)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_ap')
      RETURN FALSE
   END IF

   LET l_msg = mr_ap.num_ap USING '<<<<<<'
   LET l_msg = mr_ad.nom_programa, ' - INCLUSAO DA AP No. ', l_msg CLIPPED
   
   IF NOT func009_ins_audit(mr_ap.num_ap, '2', l_msg) THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION func009_le_par_ap()
#---------------------------#

   SELECT ult_num_ap 
     INTO m_num_ap
     FROM par_ap
    WHERE cod_empresa = mr_ad.cod_empresa

   IF STATUS = 100 THEN
      LET m_num_ap = 0
      IF NOT func009_ins_par_ap() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_ap')
         RETURN FALSE
      END IF
   END IF
   
   LET m_num_ap = m_num_ap + 1
   
   UPDATE par_ap SET ult_num_ap = m_num_ap
   WHERE cod_empresa = mr_ad.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ap')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION func009_ins_par_ap()#
#----------------------------#
   
   DEFINE lr_par_ap   RECORD LIKE par_ap.*
   
   LET lr_par_ap.cod_empresa = mr_ad.cod_empresa  
   LET lr_par_ap.taxa_padrao = 0
   LET lr_par_ap.ult_num_ap  = 0
   LET lr_par_ap.cod_formula = 0   
   LET lr_par_ap.cod_tip_val_jur = 0
   LET lr_par_ap.cod_tip_val_des = 0

   INSERT INTO par_ap
    VALUES(lr_par_ap.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','par_ap')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
          