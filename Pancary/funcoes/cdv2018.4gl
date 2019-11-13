#---------------------------------------------------------------#
#-------Objetivo: gerar nota no sup3760           --------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150),
          g_tipo_sgbd         CHAR(003)
END GLOBALS

DEFINE p_cod_empresa          CHAR(02),
       p_user                 CHAR(08),
       p_status               SMALLINT,
       m_erro                 CHAR(10),
       m_msg                  CHAR(150),
       m_dat_proces           DATE,
       m_hor_operac           CHAR(08),
       m_num_ar               INTEGER,
       m_cfop                 CHAR(07),
       m_ind                  INTEGER,
       m_dat_atu              DATE,
       m_prefixo              CHAR(02)
              
       
DEFINE m_den_item          LIKE aviso_rec.den_item,
       m_cod_item          LIKE aviso_rec.COD_item,
       m_num_seq           LIKE aviso_rec.num_seq,
       m_pre_unit          LIKE aviso_rec.pre_unit_nf,
       m_val_item          LIKE aviso_rec.pre_unit_nf,
       m_qtd_item          LIKE aviso_rec.qtd_declarad_nf,
       m_cod_tip_despesa   LIKE aviso_REC.cod_tip_despesa,
       m_num_conta_deb     LIKE item_sup.num_conta,
       m_cod_uni_feder     LIKE fornecedor.cod_uni_feder,
       m_ies_contrib_ipi   LIKE fornecedor.ies_contrib_ipi,
       m_tributo           LIKE obf_config_fiscal.tributo_benef,
       m_trans_config      LIKE obf_config_fiscal.trans_config,
       m_pct_ipi           LIKE item.pct_ipi,
       m_pct_ipi_d         LIKE item.pct_ipi
       
DEFINE mr_nota             RECORD
         cod_empresa       LIKE empresa.cod_empresa,
         tip_despesa       LIKE cdv_desp_terc_781.tip_despesa,
         nota_fiscal       LIKE cdv_desp_terc_781.nota_fiscal,
         serie_nota_fiscal LIKE cdv_desp_terc_781.serie_nota_fiscal,
         subserie_nf       LIKE cdv_desp_terc_781.subserie_nf,
         ies_especie       LIKE nf_sup.ies_especie_nf,
         fornecedor        LIKE cdv_desp_terc_781.fornecedor,
         dat_inclusao      LIKE cdv_desp_terc_781.dat_inclusao,
         dat_vencto        LIKE cdv_desp_terc_781.dat_inclusao,
         val_desp_terceiro LIKE cdv_desp_terc_781.val_desp_terceiro,  
         cnd_pgto          LIKE nf_sup.cnd_pgto_nf,
         cod_operacao      LIKE nf_sup.cod_operacao,
         tot_ipi           DECIMAL(12,2),
         tot_icms          DECIMAL(12,2),
         nf_com_erro       CHAR(01),
         den_erro          CHAR(30),
         cod_usuario       CHAR(08),
         cc_viajante       INTEGER
END RECORD

DEFINE mr_aen              RECORD
       val_aen             LIKE ad_aen_4.val_aen,
       cod_lin_prod        LIKE ad_aen_4.cod_lin_prod,
       cod_lin_recei       LIKE ad_aen_4.cod_lin_recei,
       cod_seg_merc        LIKE ad_aen_4.cod_seg_merc,
       cod_cla_uso         LIKE ad_aen_4.cod_cla_uso
END RECORD

DEFINE mr_nf_sup           RECORD LIKE nf_sup.*,
       mr_aviso            RECORD LIKE aviso_rec.*,
       mr_dest_ar          RECORD LIKE dest_aviso_rec4.*,
       mr_sup_par          RECORD LIKE sup_par_ar.*,
       mr_audit_ar         RECORD LIKE audit_ar.*


       
#--------------------parâmetros--------------------#
#Campos dos records abaixo                         #
#--------------------retorno-----------------------#
# 'OK', num_ar -> se sucesso                       #
# mensagem de erro, 0 -> se ocorre erro            #
#--------------------------------------------------# 
FUNCTION cdv2018_gera_nota(lr_nota,la_item) #
#--------------------------------------------------# 

   DEFINE lr_nota             RECORD
         cod_empresa       LIKE empresa.cod_empresa,
         tip_despesa       LIKE cdv_desp_terc_781.tip_despesa,
         nota_fiscal       LIKE cdv_desp_terc_781.nota_fiscal,
         serie_nota_fiscal LIKE cdv_desp_terc_781.serie_nota_fiscal,
         subserie_nf       LIKE cdv_desp_terc_781.subserie_nf,
         ies_especie       LIKE nf_sup.ies_especie_nf,
         fornecedor        LIKE cdv_desp_terc_781.fornecedor,
         dat_inclusao      LIKE cdv_desp_terc_781.dat_inclusao,
         dat_vencto        LIKE cdv_desp_terc_781.dat_inclusao,
         val_desp_terceiro LIKE cdv_desp_terc_781.val_desp_terceiro,  
         cnd_pgto          LIKE nf_sup.cnd_pgto_nf,
         cod_operacao      LIKE nf_sup.cod_operacao,
         tot_ipi           DECIMAL(12,2),
         tot_icms          DECIMAL(12,2),
         nf_com_erro       CHAR(01),
         den_erro          CHAR(30),
         cod_usuario       CHAR(08),
         cc_viajante       INTEGER
   END RECORD

  DEFINE la_item          ARRAY[100] OF RECORD
       cod_item          LIKE item.cod_item,
       den_item          LIKE item.den_item_reduz,
       qtd_item          LIKE aviso_rec.qtd_declarad_nf,
       pct_ipi           DECIMAL(5,2),
       pre_unit          LIKE aviso_rec.pre_unit_nf,
       val_tot           LIKE aviso_rec.pre_unit_nf
  END RECORD
  
  WHENEVER ERROR CONTINUE
  
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET mr_nota.* = lr_nota.*
   
   LET m_cfop = mr_nota.cod_operacao

   IF NOT cdv2018_valid_cfop() THEN
      RETURN m_msg, 0
   END IF
   
   IF mr_nota.dat_inclusao IS NULL THEN
      LET mr_nota.dat_inclusao = TODAY
   END IF
   
   LET m_dat_atu = TODAY
   
   IF NOT cdv2018_grava_nota() THEN
      RETURN m_msg, 0
   END IF
   
   FOR m_num_seq = 1 to 100
       IF la_item[m_num_seq].cod_item IS NOT NULL THEN
          LET m_cod_item = la_item[m_num_seq].cod_item
          LET m_qtd_item = la_item[m_num_seq].qtd_item
          LET m_pct_ipi_d = la_item[m_num_seq].qtd_item
          LET m_den_item = la_item[m_num_seq].den_item
          LET m_pre_unit = la_item[m_num_seq].pre_unit
          LET m_val_item = m_qtd_item * m_pre_unit
          IF NOT cdv2018_gera_ar() THEN
             RETURN m_msg, 0
          END IF
       END IF   
   END FOR

   IF NOT cdv2018_atu_nf_sup() THEN
      RETURN FALSE
   END IF
   
   RETURN 'OK', m_num_ar

END FUNCTION    

#----------------------------#
FUNCTION cdv2018_grava_nota()#
#----------------------------#
   
   IF NOT cdv2018_gera_num_ar() THEN
      RETURN FALSE
   END IF

   IF NOT cdv2018_ins_nf_sup() THEN
      RETURN FALSE
   END IF

   IF mr_nota.nf_com_erro = 'S' THEN
      IF NOT cdv2018_ins_nf_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT cdv2018_ins_nf_sup_par_ar() THEN
      RETURN FALSE
   END IF

   IF NOT cdv2018_ins_ar_compl() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION cdv2018_gera_ar()#
#-------------------------#
   
   DEFINE l_ret               CHAR(150)
   
   DEFINE lr_param            RECORD
          cod_empresa         LIKE empresa.cod_empresa,
          cod_cliente         LIKE clientes.cod_cliente,
          cod_item            LIKE item.cod_item,
          cod_cidade          LIKE cidades.cod_cidade,
          cod_nat_oper        LIKE obf_oper_fiscal.nat_oper_grp_desp,
          origem              LIKE obf_oper_fiscal.origem,
          cod_tip_carteira    LIKE pedidos.cod_tip_carteira, 
          ies_finalidade      LIKE pedidos.ies_finalidade    
   END RECORD       

   LET lr_param.cod_empresa = mr_nota.cod_empresa
   LET lr_param.cod_cliente = mr_nota.fornecedor
   LET lr_param.cod_item = m_cod_item
   
   SELECT cod_cidade,
          cod_uni_feder,
          ies_contrib_ipi
     INTO lr_param.cod_cidade,
          m_cod_uni_feder,
          m_ies_contrib_ipi
     FROM fornecedor
    WHERE cod_fornecedor = mr_nota.fornecedor
    
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados do fornecedor'
      RETURN FALSE
   END IF
   
   SELECT gru_ctr_desp
     INTO lr_param.cod_nat_oper
     FROM item_sup
    WHERE cod_empresa = mr_nota.cod_empresa 
      AND cod_item = m_cod_item
    
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados do item'
      RETURN FALSE
   END IF
      
   LET lr_param.origem = 'E'
   LET lr_param.cod_tip_carteira = NULL
   LET lr_param.ies_finalidade = NULL

   LET l_ret = cdv2019_par_fiscal(lr_param)
   
   IF l_ret = 'OK' THEN
   ELSE
      LET m_msg = l_ret
      RETURN FALSE
   END IF
         
   IF NOT cdv2018_ins_aviso_rec() THEN
      RETURN FALSE
   END IF
   
   IF NOT cdv2018_ins_dest_ar() THEN
      RETURN FALSE
   END IF

   IF NOT cdv2018_ins_ar_seq() THEN
      RETURN FALSE
   END IF

   IF NOT cdv2018_gra_par_ar() THEN
      RETURN FALSE
   END IF

   LET mr_audit_ar.num_seq = mr_aviso.num_seq 
   
   IF NOT cdv2018_ins_audit_ar() THEN
      RETURN FALSE
   END IF
      
   {IF NOT cdv2018_contabiliza() THEN
         par_sup e par_sup_compl contem as contas

      RETURN FALSE
   END IF}

   RETURN TRUE

END FUNCTION   

#-----------------------------#
 FUNCTION cdv2018_gera_num_ar()
#-----------------------------#

   SELECT par_val
     INTO m_num_ar
     FROM par_sup_pad
    WHERE cod_empresa   = mr_nota.cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo número do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   UPDATE par_sup_pad
      SET par_val = (par_val + 1)
    WHERE cod_empresa   = mr_nota.cod_empresa
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' Atualizando número do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION cdv2018_ins_nf_sup()#
#----------------------------#
   
   LET mr_nf_sup.cod_empresa         = mr_nota.cod_empresa       
   LET mr_nf_sup.cod_empresa_estab   = NULL
   LET mr_nf_sup.num_nf              = mr_nota.nota_fiscal
   LET mr_nf_sup.ser_nf              = mr_nota.serie_nota_fiscal
   LET mr_nf_sup.ssr_nf              = mr_nota.subserie_nf
   LET mr_nf_sup.ies_especie_nf      = mr_nota.ies_especie
   LET mr_nf_sup.cod_fornecedor      = mr_nota.fornecedor
   LET mr_nf_sup.num_conhec          = 0
   LET mr_nf_sup.ser_conhec          = ' '
   LET mr_nf_sup.ssr_conhec          = 0
   LET mr_nf_sup.cod_transpor        = '0'
   LET mr_nf_sup.num_aviso_rec       = m_num_ar
   LET mr_nf_sup.dat_emis_nf         = mr_nota.dat_inclusao
   LET mr_nf_sup.dat_entrada_nf      = m_dat_atu
   LET mr_nf_sup.cod_regist_entrada  = 2
   LET mr_nf_sup.val_tot_nf_d        = mr_nota.val_desp_terceiro
   LET mr_nf_sup.val_tot_nf_c        = 0
   LET mr_nf_sup.val_tot_icms_nf_d   = mr_nota.tot_icms
   LET mr_nf_sup.val_tot_icms_nf_c   = 0
   LET mr_nf_sup.val_tot_desc        = 0
   LET mr_nf_sup.val_tot_acresc      = 0
   LET mr_nf_sup.val_ipi_nf          = mr_nota.tot_ipi
   LET mr_nf_sup.val_ipi_calc        = 0
   LET mr_nf_sup.val_despesa_aces    = 0
   LET mr_nf_sup.val_adiant          = 0
   LET mr_nf_sup.ies_tip_frete       = '0'
   LET mr_nf_sup.cnd_pgto_nf         = mr_nota.cnd_pgto
   LET mr_nf_sup.cod_mod_embar       = 3
   LET mr_nf_sup.ies_nf_com_erro     = mr_nota.nf_com_erro
   LET mr_nf_sup.nom_resp_aceite_er  = mr_nota.cod_usuario
   LET mr_nf_sup.ies_incl_cap        = 'N'
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
   LET mr_nf_sup.ies_nf_aguard_nfe   = '7'
                    
   INSERT INTO nf_sup VALUES(mr_nf_sup.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela nf_sup.'
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION cdv2018_ins_audit_ar()#
#------------------------------#
      
   INSERT INTO audit_ar VALUES(mr_audit_ar.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","audit_ar")
      RETURN FALSE
   END IF       

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela audit_ar.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION cdv2018_ins_nf_erro()#
#-----------------------------#

   IF g_tipo_sgbd = 'MSV' THEN
      INSERT INTO nf_sup_erro(
         empresa, num_aviso_rec, num_seq,
         des_pendencia_item, ies_origem_erro,
         ies_erro_grave)
        VALUES (mr_nf_sup.cod_empresa,
                mr_nf_sup.num_aviso_rec,
                0,
                mr_nota.den_erro,
                '1',
                'S')
   ELSE  
      INSERT INTO nf_sup_erro
        VALUES (mr_nf_sup.cod_empresa,
                mr_nf_sup.num_aviso_rec,
                0,
                mr_nota.den_erro,
                '1',
                'S',
                0)
   END IF
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela nf_sup_erro.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#-----------------------------------#
FUNCTION cdv2018_ins_nf_sup_par_ar()#
#-----------------------------------#

   DEFINE l_parametro_txt   LIKE sup_par_ar.parametro_texto
   
   INITIALIZE mr_sup_par.* TO NULL
   
   LET l_parametro_txt = EXTEND(mr_nf_sup.dat_emis_nf, YEAR TO DAY)
   LET l_parametro_txt = l_parametro_txt CLIPPED, ' ', TIME
   
   LET mr_sup_par.empresa = mr_nf_sup.cod_empresa         
   LET mr_sup_par.aviso_recebto = mr_nf_sup.num_aviso_rec   
   LET mr_sup_par.seq_aviso_recebto = 0
   
   LET mr_sup_par.parametro = 'data_hora_nf_entrada'
   LET mr_sup_par.par_ind_especial = ' '
   LET mr_sup_par.parametro_texto = l_parametro_txt
   LET mr_sup_par.parametro_val = NULL   
   LET mr_sup_par.parametro_dat = NULL   

   IF NOT cdv2018_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_sup_par.parametro = 'meio_transp_ar'
   LET mr_sup_par.parametro_texto = NULL
   LET mr_sup_par.parametro_val = 1 

   IF NOT cdv2018_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_audit_ar.cod_empresa = mr_nf_sup.cod_empresa               
   LET mr_audit_ar.num_aviso_rec = mr_nf_sup.num_aviso_rec    
   LET mr_audit_ar.num_seq = 0                
   LET mr_audit_ar.nom_usuario = mr_nota.cod_usuario                         
   LET mr_audit_ar.dat_hor_proces = CURRENT                     
   LET mr_audit_ar.num_prog = 'CDV2000'                         
   LET mr_audit_ar.ies_tipo_auditoria = '1'                     

   IF NOT cdv2018_ins_audit_ar() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION cdv2018_ins_ar_compl()#
#------------------------------#

   DEFINE lr_ar_compl      RECORD LIKE aviso_rec_compl.*
   
   DEFINE l_cgc_empresa    LIKE empresa.num_cgc
   
   SELECT num_cgc
     INTO l_cgc_empresa
     FROM empresa
    WHERE cod_empresa = mr_nf_sup.cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo CNPJ da tabela empresa.'
      RETURN FALSE
   END IF

   SELECT filial  
     INTO lr_ar_compl.filial
     FROM log_filial  
    WHERE empresa_logix = mr_nf_sup.cod_empresa
      AND m_dat_atu >= dat_inicial_validade
      AND m_dat_atu <= dat_final_validade
      AND cnpj = l_cgc_empresa
   
   IF STATUS <> 0 THEN
      LET lr_ar_compl.filial = ' '
   END IF
   
   LET lr_ar_compl.cod_empresa       = mr_nf_sup.cod_empresa              
   LET lr_ar_compl.num_aviso_rec     = mr_nf_sup.num_aviso_rec        
   LET lr_ar_compl.cod_fiscal_compl  = 0                           
   LET lr_ar_compl.ies_situacao      = 'N'     
   LET lr_ar_compl.cod_operacao      = ' '                      
                                                                     
   INSERT INTO aviso_rec_compl(
     cod_empresa,
     num_aviso_rec,
     cod_fiscal_compl,
     ies_situacao,
     cod_operacao,
     filial)
    VALUES (lr_ar_compl.cod_empresa,      
            lr_ar_compl.num_aviso_rec,   
            lr_ar_compl.cod_fiscal_compl,
            lr_ar_compl.ies_situacao,    
            lr_ar_compl.cod_operacao,    
            lr_ar_compl.filial)                                             

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec_compl.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION cdv2018_ins_aviso_rec()#
#-------------------------------#
            
   LET mr_aviso.cod_empresa        = mr_nf_sup.cod_empresa
   LET mr_aviso.cod_item           = m_cod_item

   IF NOT cdv2018_le_item() THEN
      RETURN FALSE
   END IF

   LET mr_aviso.cod_empresa_estab  = mr_nf_sup.cod_empresa_estab
   LET mr_aviso.num_aviso_rec      = mr_nf_sup.num_aviso_rec
   LET mr_aviso.num_seq            = m_num_seq
   LET mr_aviso.dat_inclusao_seq   = mr_nf_sup.dat_entrada_nf
   LET mr_aviso.ies_situa_ar       = 'E'
   LET mr_aviso.ies_incl_almox     = 'N'
   LET mr_aviso.ies_receb_fiscal   = 'S'
   LET mr_aviso.ies_liberacao_ar   = '1'
   LET mr_aviso.ies_liberacao_cont = 'N'
   LET mr_aviso.ies_liberacao_insp = 'S'
   LET mr_aviso.ies_diverg_listada = 'N'
   LET mr_aviso.num_pedido         = NULL   
   LET mr_aviso.num_oc             = NULL
   LET mr_aviso.pre_unit_nf        = m_pre_unit

   #--------------------------------------------------------------------------------#

   LET mr_aviso.ies_da_bc_ipi      = 'N'

   IF mr_aviso.ies_tip_incid_ipi = 'O' THEN
      LET mr_aviso.cod_incid_ipi = '3'
   ELSE
      IF mr_aviso.ies_tip_incid_ipi = 'I' then
         LET mr_aviso.cod_incid_ipi = '2'
      ELSE
         LET mr_aviso.cod_incid_ipi = '1'
      END IF
   END IF
   
   IF NOT cdv2018_le_incidencia() THEN
      RETURN FALSE
   END IF

   LET mr_aviso.val_base_c_item_c  = m_val_item
   
   IF mr_aviso.pct_ipi_tabela > 0 AND m_ies_contrib_ipi = 'S' THEN
      LET mr_aviso.val_base_c_ipi_it  = m_val_item
      LET mr_aviso.val_ipi_calc_item  = 
          mr_aviso.val_base_c_ipi_it * (mr_aviso.pct_ipi_tabela / 100)
   ELSE
      LET mr_aviso.val_base_c_ipi_it = 0
      LET mr_aviso.val_ipi_calc_item = 0
   END IF
   
   IF m_pct_ipi_d IS NULL THEN
      LET m_pct_ipi_d = 0
   END IF
   
   LET mr_aviso.val_base_c_item_d  = 0
   LET mr_aviso.pct_ipi_declarad   = m_pct_ipi_d
   LET mr_aviso.val_ipi_decl_item  = m_val_item * m_pct_ipi_d / 100
   
   LET mr_aviso.val_liquido_item   = m_val_item
   LET mr_aviso.val_contabil_item  = m_val_item + mr_aviso.val_ipi_calc_item

   LET mr_aviso.val_icms_item_c    = m_val_item * (mr_aviso.pct_icms_item_c / 100)
   
   LET mr_aviso.pct_icms_item_d    = 0
   LET mr_aviso.val_icms_item_d    = 0
   
   #--------------------------------------------------------------------------------#
   
   LET mr_aviso.val_desc_item      = 0
   LET mr_aviso.qtd_declarad_nf    = m_qtd_item
   LET mr_aviso.qtd_recebida       = m_qtd_item
   LET mr_aviso.qtd_devolvid       = 0
   LET mr_aviso.dat_devoluc        = NULL
   LET mr_aviso.val_devoluc        = 0
   LET mr_aviso.num_nf_dev         = 0
   LET mr_aviso.qtd_rejeit         = 0
   LET mr_aviso.qtd_liber          = m_qtd_item
   LET mr_aviso.qtd_liber_excep    = 0
   LET mr_aviso.cus_tot_item       = 0   
   LET mr_aviso.num_lote           = NULL
   LET mr_aviso.cod_operac_estoq   = ' '   
   LET mr_aviso.pct_red_bc_item_d  = 0
   LET mr_aviso.pct_red_bc_item_c  = 0
   LET mr_aviso.pct_diferen_item_d = 0
   LET mr_aviso.pct_diferen_item_c = 0
   LET mr_aviso.val_icms_diferen_i = 0
   LET mr_aviso.val_ipi_desp_aces  = 0
   LET mr_aviso.val_base_c_ipi_da  = 0
   LET mr_aviso.val_despesa_aces_i = 0
   LET mr_aviso.val_base_c_icms_da = 0
   LET mr_aviso.val_icms_desp_aces = 0
   LET mr_aviso.ies_bitributacao   = 'N'   
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
   LET mr_aviso.cod_tip_despesa    = mr_nota.tip_despesa
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

#-----------------------------#
FUNCTION cdv2018_ins_dest_ar()#
#-----------------------------#

   DEFINE l_sequencia      INTEGER
      
   LET l_sequencia = 1
   
      LET mr_dest_ar.cod_empresa        = mr_aviso.cod_empresa            
      LET mr_dest_ar.num_aviso_rec      = mr_aviso.num_aviso_rec    
      LET mr_dest_ar.num_seq            = mr_aviso.num_seq          
      LET mr_dest_ar.sequencia          = l_sequencia                                  
      LET mr_dest_ar.cod_area_negocio   = mr_aen.cod_lin_prod           
      LET mr_dest_ar.cod_lin_negocio    = mr_aen.cod_lin_recei    
      LET mr_dest_ar.pct_particip_comp  = 100                      
      LET mr_dest_ar.num_conta_deb_desp = m_num_conta_deb
      LET mr_dest_ar.cod_secao_receb    = '  '                           
      LET mr_dest_ar.qtd_recebida       = 0 #mr_aviso.qtd_recebida     
      LET mr_dest_ar.ies_contagem       = 'N'                            
      LET mr_dest_ar.cod_seg_merc       = mr_aen.cod_seg_merc           
      LET mr_dest_ar.cod_cla_uso        = mr_aen.cod_cla_uso                      
                                                          
      {INSERT INTO dest_aviso_rec4 VALUES (mr_dest_ar.*)           

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela dest_aviso_rec4.'
         RETURN FALSE
      END IF}
      
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
      
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION cdv2018_ins_ar_seq()#
#----------------------------#
   
   DEFINE lr_ar_sq       RECORD LIKE aviso_rec_compl_sq.*
   
   LET lr_ar_sq.cod_empresa       =  mr_aviso.cod_empresa             
   LET lr_ar_sq.num_aviso_rec     =  mr_aviso.num_aviso_rec    
   LET lr_ar_sq.num_seq           =  mr_aviso.num_seq          
   LET lr_ar_sq.cod_fiscal_compl  =  0                            
   LET lr_ar_sq.val_base_d_ipi_it =  0                            
                                                               
   INSERT INTO aviso_rec_compl_sq VALUES (lr_ar_sq.*)        
                                                                  
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela aviso_rec_compl_sq.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION cdv2018_gra_par_ar()#
#----------------------------#
   
   DEFINE l_tributo             LIKE obf_config_fiscal.tributo_benef,
          l_enquadramento_legal INTEGER
   
   INITIALIZE mr_sup_par.* TO NULL
   
   LET mr_sup_par.empresa = mr_aviso.cod_empresa         
   LET mr_sup_par.aviso_recebto = mr_aviso.num_aviso_rec
   LET mr_sup_par.seq_aviso_recebto = mr_aviso.num_seq
   
   LET mr_sup_par.parametro = 'desconto_fiscal'
   LET mr_sup_par.parametro_val = 0   
   
   IF NOT cdv2018_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_sup_par.parametro = 'bc_dif_aliq_icms'
   LET mr_sup_par.parametro_val = mr_aviso.val_liquido_item   

   IF NOT cdv2018_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   DECLARE cq_config_fiscal CURSOR FOR
    SELECT tributo_benef, trans_config
      FROM tributo_tmp_912
   
   FOREACH cq_config_fiscal INTO m_tributo, m_trans_config

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 'lendo dados da tabela tributo_tmp_912'
         RETURN FALSE
      END IF
      
      SELECT tributacao, enquadramento_legal
        INTO mr_sup_par.parametro_val,
             l_enquadramento_legal
        FROM obf_config_fiscal
       WHERE empresa = mr_aviso.cod_empresa
         AND trans_config = m_trans_config

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 'lendo dados da tabela obf_config_fiscal'
         RETURN FALSE
      END IF
      
      LET l_tributo = cdv2018_tributo()
      LET m_tributo = 'cod_cst_',l_tributo CLIPPED
      LET mr_sup_par.parametro = m_tributo
      LET mr_sup_par.par_ind_especial = 'A'
      LET mr_sup_par.parametro_texto = m_trans_config
      LET mr_sup_par.parametro_dat = NULL
      
      IF NOT cdv2018_ins_par_ar() THEN
         RETURN FALSE
      END IF   
      
      IF UPSHIFT(l_tributo) = 'IPI' THEN
         LET mr_sup_par.parametro = 'enquadr_legal_ipi'
         LET mr_sup_par.par_ind_especial = ' '
         LET mr_sup_par.parametro_val = l_enquadramento_legal
      
         IF NOT cdv2018_ins_par_ar() THEN
            RETURN FALSE
         END IF   
      END IF
            
   END FOREACH

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION cdv2018_ins_par_ar()#
#----------------------------#

   INSERT INTO sup_par_ar VALUES(mr_sup_par.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, 
          ' inserindo registro na tabela sup_par_ar:',mr_sup_par.parametro
      RETURN FALSE
   END IF
   
   RETURN TRUE   
   
END FUNCTION
   
#-------------------------#
FUNCTION cdv2018_le_item()#
#-------------------------#
   
   DEFINE l_cod_cc     CHAR(15),
          l_tip_desp   CHAR(15),
          l_num_conta  CHAR(15)
   
   SELECT ies_ctr_estoque,                     
          ies_ctr_lote,                           
          cod_cla_fisc,                           
          cod_unid_med,                           
          cod_local_estoq,
          den_item,
          cod_cla_fisc,
          cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso,
          pct_ipi                        
     INTO mr_aviso.ies_item_estoq,     
          mr_aviso.ies_controle_lote,        
          mr_aviso.cod_cla_fisc,               
          mr_aviso.cod_unid_med_nf,            
          mr_aviso.cod_local_estoq,
          mr_aviso.den_item,
          mr_aviso.cod_cla_fisc_nf,
          mr_aen.cod_lin_prod, 
          mr_aen.cod_lin_recei,
          mr_aen.cod_seg_merc, 
          mr_aen.cod_cla_uso,
          m_pct_ipi
     FROM item                                    
    WHERE cod_empresa = mr_aviso.cod_empresa             
      AND cod_item = mr_aviso.cod_item    

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item, p/ gravação no AR.'
      RETURN FALSE
   END IF
   
   IF mr_aviso.cod_local_estoq IS NULL THEN
      LET mr_aviso.cod_local_estoq = ' '
   END IF
   
   SELECT cod_comprador,                      
          gru_ctr_desp,                          
          cod_tip_despesa,                       
          num_conta,
          cod_fiscal,
          ies_tip_incid_ipi,
          ies_tip_incid_icms           
     INTO mr_aviso.cod_comprador,             
          mr_aviso.gru_ctr_desp_item,         
          mr_aviso.cod_tip_despesa,           
          m_num_conta_deb,
          mr_aviso.cod_fiscal_item,
          mr_aviso.ies_tip_incid_ipi,
          mr_aviso.ies_incid_icms_ite                 
     FROM item_sup                               
    WHERE cod_empresa = mr_aviso.cod_empresa            
      AND cod_item = mr_aviso.cod_item                   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item_sup, p/ gravação no AR.'
      RETURN FALSE
   END IF
   
   IF m_num_conta_deb IS NULL THEN
      LET l_cod_cc = mr_nota.cc_viajante
      LET l_cod_cc = func002_strzero(l_cod_cc[1,4], 4)
      LET l_tip_desp = mr_nota.tip_despesa
      LET l_tip_desp = func002_strzero(l_tip_desp[1,4], 4)
      LET l_num_conta = l_cod_cc CLIPPED, l_tip_desp CLIPPED
      
      SELECT num_conta
        INTO m_num_conta_deb
        FROM plano_contas
       WHERE cod_empresa = mr_aviso.cod_empresa
         AND num_conta_reduz = l_num_conta

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo conta ', 
               l_num_conta CLIPPED, ' da tabela plano_contas'
         RETURN FALSE
      END IF
   END IF         
   
   LET mr_aviso.cod_fiscal_item = m_prefixo, mr_aviso.cod_fiscal_item CLIPPED
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION cdv2018_le_incidencia()#
#-------------------------------#

   DEFINE l_pct_part      DECIMAL(12,5)
   
   SELECT pct_direito_cred 
     INTO mr_aviso.pct_direito_cred
     FROM incid_ipi  
    WHERE cod_empresa = mr_aviso.cod_empresa
      AND cod_incid_ipi = mr_aviso.cod_incid_ipi

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela incid_ipi.'
      RETURN FALSE
   END IF

   IF m_pct_ipi = 0 OR m_pct_ipi IS NULL THEN
      SELECT DISTINCT pct_ipi
        INTO m_pct_ipi
        FROM clas_fiscal
       WHERE cod_cla_fisc = mr_aviso.cod_cla_fisc
         AND ies_tributa_ipi = 'S'
         AND cod_unid_med_fisc = mr_aviso.cod_unid_med_nf

      IF STATUS = 100 THEN
         LET m_pct_ipi = 0
      ELSE
         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' lendo dados da tabela clas_fiscal.'
            RETURN FALSE
         END IF
      END IF   
   END IF
   
   LET l_pct_part = m_pct_ipi / 100
   
   LET mr_aviso.pct_ipi_tabela = m_pct_ipi * l_pct_part
      
   SELECT pct_icms  
     INTO mr_aviso.pct_icms_item_c
     FROM icms 
    WHERE cod_empresa = mr_aviso.cod_empresa 
      AND gru_ctr_desp = mr_aviso.gru_ctr_desp_item
      AND cod_uni_feder = m_cod_uni_feder

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela icms.'
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION cdv2018_tributo()#
#-------------------------#
   
   DEFINE l_tributo       LIKE obf_config_fiscal.tributo_benef,
          l_dig           CHAR(01),
          l_ind           INTEGER
   
   LET l_tributo = ''
                 
   FOR l_ind = 1 TO LENGTH(m_tributo)
       LET l_dig = m_tributo[l_ind]
       IF l_dig = '_' THEN
          EXIT FOR
       ELSE
          LET l_tributo = l_tributo, l_dig
       END IF
   END FOR
   
   RETURN l_tributo

END FUNCTION

#----------------------------#
FUNCTION cdv2018_atu_nf_sup()#
#----------------------------#

   SELECT SUM(val_liquido_item), 
          SUM(val_ipi_calc_item), 
          SUM(val_icms_item_c)
     INTO mr_nf_sup.val_tot_nf_c,
          mr_nf_sup.val_ipi_calc,
          mr_nf_sup.val_tot_icms_nf_c
     FROM aviso_rec 
    WHERE cod_empresa = mr_aviso.cod_empresa
      AND num_aviso_rec = mr_aviso.num_aviso_rec
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' somando valores da tabela aviso_rec.'
      RETURN FALSE
   END IF

   UPDATE nf_sup 
      SET val_tot_nf_c = mr_nf_sup.val_tot_nf_c, 
          val_ipi_calc = mr_nf_sup.val_ipi_calc,
          val_tot_icms_nf_c = mr_nf_sup.val_tot_icms_nf_c 
    WHERE cod_empresa = mr_aviso.cod_empresa
      AND num_aviso_rec = mr_aviso.num_aviso_rec

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' atualizando valores da tabela nf_sup.'
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION
   

#----------------------------#
FUNCTION cdv2018_valid_cfop()#
#----------------------------#
   
   DEFINE l_par_ies      CHAR(01),
          l_pais_for     LIKE fornecedor.cod_pais,
          l_uf_for       LIKE fornecedor.cod_uni_feder,
          l_pais_emp     LIKE fornecedor.cod_pais,
          l_uf_emp       LIKE fornecedor.cod_uni_feder
             
   IF m_cfop IS NULL THEN
      IF mr_nota.ies_especie <> 'NFS' THEN
         LET m_msg = 'Informe o CFOP'
         RETURN FALSE
      END IF
      SELECT par_ies 
        INTO l_par_ies
        FROM par_sup_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = 'cfop_nfs'
      IF STATUS = 0 THEN
         IF l_par_ies = 'S' THEN
            LET m_msg = 'Informe o CFOP'
            RETURN FALSE
         END IF
      END IF
   END IF
   
   SELECT cod_pais, cod_uni_feder
     INTO l_pais_for, l_uf_for
     FROM fornecedor
    WHERE cod_fornecedor = mr_nota.fornecedor
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO ', STATUS USING '<<<<<<<', 'LENDO TABELA FORNECEDOR'
      RETURN FALSE
   END IF
   
   SELECT log_empresa_compl.pais, 
          empresa.uni_feder
     INTO l_pais_emp, l_uf_emp
     FROM empresa, log_empresa_compl
    WHERE empresa.cod_empresa = mr_nota.cod_empresa
      AND log_empresa_compl.empresa = empresa.cod_empresa
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO ', STATUS USING '<<<<<<<', 'LENDO TABELA LOG_EMPRESA_COMPL'
      RETURN FALSE
   END IF
   
   LET m_prefixo = '1.'
   
   IF l_pais_emp <> l_pais_for THEN
      LET m_prefixo = '3.'
      IF m_cfop IS NOT NULL AND m_cfop[1] <> '7' THEN
         LET m_msg = 'CFOP inválido para nota de importação'
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   IF l_uf_emp <> l_uf_for THEN
      LET m_prefixo = '2.'
      IF m_cfop IS NOT NULL AND m_cfop[1] <> '6' THEN
         LET m_msg = 'CFOP inválido para nota fora do estado'
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
      
   IF m_cfop IS NOT NULL AND m_cfop[1] <> '5' THEN 
      LET m_msg = 'CFOP inválido para nota dentro do estado'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION  
      