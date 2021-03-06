#---------------------------------------------------------------#
#-------Objetivo: gerar nota no sup3760           --------------#
#--Obs: a rotina que a chama deve ter uma transa��o aberta------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150),
          g_tipo_sgbd         CHAR(003)
END GLOBALS

DEFINE m_emp_vend             CHAR(02),
       m_emp_benef            CHAR(02),
       p_user                 CHAR(08),
       p_status               SMALLINT,
       m_erro                 CHAR(10),
       m_msg                  CHAR(150),
       m_dat_proces           DATE,
       m_hor_operac           CHAR(08),
       m_num_ar               INTEGER,
       m_cfop                 CHAR(07),
       m_prefixo              CHAR(01),
       m_ind                  INTEGER,
       m_dat_atu              DATE,
       m_cod_fornecedor       CHAR(15),
       m_trans_nf             INTEGER,
       m_num_romaneio         INTEGER,
       m_num_seq_pai          INTEGER,
       m_num_pc               INTEGER,
       m_num_oc               INTEGER,
       m_num_prog             CHAR(08),
       m_nf_com_erro          CHAR(01),
       m_den_erro             CHAR(30),
       m_ies_contag           CHAR(01),
       m_ies_insp             CHAR(01),
       m_qtd_necessaria       DECIMAL(10,3),
       m_qtd_bx_tot           DECIMAL(10,3),
       m_qtd_baixar           DECIMAL(10,3),
       m_cod_item_comp        CHAR(15),
       m_cod_mot_remessa      CHAR(02),
       m_seq_it_em_terc       INTEGER,
       m_qtd_movto            DECIMAL(10,3)
       
DEFINE mr_nf_mestre           RECORD LIKE fat_nf_mestre.*,
       mr_nf_item             RECORD LIKE fat_nf_item.*
       
       
DEFINE m_den_item          LIKE aviso_rec.den_item,
       m_cod_item          LIKE aviso_rec.COD_item,
       m_seq_nf            LIKE aviso_rec.num_seq,
       m_num_seq           LIKE aviso_rec.num_seq,
       m_pre_unit          LIKE aviso_rec.pre_unit_nf,
       m_val_item          LIKE aviso_rec.pre_unit_nf,
       m_qtd_item          LIKE aviso_rec.qtd_declarad_nf,
       m_cod_tip_despesa   LIKE aviso_REC.cod_tip_despesa,
       m_num_conta_deb     LIKE item_sup.num_conta,
       m_cod_local_receb   LIKE item_sup.cod_local_receb,
       m_cod_uni_feder     LIKE fornecedor.cod_uni_feder,
       m_tributo           LIKE obf_config_fiscal.tributo_benef,
       m_trans_config      LIKE obf_config_fiscal.trans_config,
       m_cod_fisc_item     LIKE aviso_rec.cod_fiscal_item,
       m_pct_ipi           LIKE aviso_rec.pct_ipi_tabela,
       m_pct_icms          LIKE aviso_rec.pct_icms_item_c,
       m_tot_icms_dec      LIKE nf_sup.val_tot_icms_nf_d,
       m_tot_ipi_dec       LIKE nf_sup.val_ipi_nf,
       m_dat_inclusao      LIKE aviso_rec.dat_inclusao_seq,
       m_cod_loc_estoq     LIKE local.cod_local,
       m_cod_oper_transf   LIKE estoque_trans.cod_operacao,
       m_cod_oper_baixa    LIKE estoque_trans.cod_operacao,
       m_cod_oper_cont_ar  LIKE estoque_trans.cod_operacao,
       m_cod_oper_grade    LIKE estoque_trans.cod_operacao,
       m_cod_oper_insp     LIKE estoque_trans.cod_operacao

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
       mr_sup_par          RECORD LIKE sup_par_ar.*

DEFINE mr_retr_item        RECORD
       id_registro         INTEGER,
       seq_item_nf         INTEGER,
       nf_entrada          INTEGER, 
       serie_nf_entrada    CHAR(03),
       subserie_nfe        INTEGER,
       especie_nf_entrada  CHAR(03),
       fornecedor          CHAR(15),
       seq_tabulacao       INTEGER,
       cod_item_dev        CHAR(15),
       qtd_devolvida       DECIMAL(10,3)
       num_lote            CHAR(15),                
       ies_situa           CHAR(01),               
       comprimento         INTEGER,             
       largura             INTEGER,                 
       altura              INTEGER,                  
       diametro            INTEGER
END RECORD       

  DEFINE mr_movto      RECORD
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
  END RECORD
       
#--------------------par�metros--------------------#
#Campos dos records abaixo                         #
#--------------------retorno-----------------------#
# 'OK', num_ar -> se sucesso                       #
# mensagem de erro, 0 -> se ocorre erro            #
#--------------------------------------------------# 
FUNCTION func022_gera_nota(lr_nota)                #
#--------------------------------------------------# 

   DEFINE lr_nota             RECORD
         cod_emp_benf         LIKE empresa.cod_empresa,
         cod_emp_vend         LIKE empresa.cod_empresa,
         trans_nota_fiscal    LIKE fat_nf_mestre.trans_nota_fiscal,
         cod_fornecedor       LIKE nf_sup.cod_fornecedor,
         num_romaneio         INTEGER,
         num_seq_pai          INTEGER,
         num_prog             CHAR(08),
         nf_com_erro          CHAR(01),
         den_erro             CHAR(30),
         ies_contag           CHAR(01),
         ies_insp             CHAR(01),
         ies_indus            CHAR(01)
   END RECORD
   
   DEFINE l_cod_fiscal        LIKE fat_nf_item_fisc.cod_fiscal

   WHENEVER ANY ERROR CONTINUE
      
   LET m_emp_benef = lr_nota.cod_emp_benf
   LET m_emp_vend = lr_nota.cod_emp_vend
   LET m_trans_nf = lr_nota.trans_nota_fiscal
   LET m_cod_fornecedor = lr_nota.cod_fornecedor
   LET m_num_romaneio = lr_nota.num_romaneio
   LET m_num_seq_pai = lr_nota.num_seq_pai
   LET m_num_prog = lr_nota.num_prog
   LET m_nf_com_erro = lr_nota.nf_com_erro
   LET m_den_erro = lr_nota.den_erro
   LET m_ies_contag = lr_nota.ies_contag
   LET m_ies_insp = lr_nota.ies_insp
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   SELECT * INTO mr_nf_mestre.*
     FROM fat_nf_mestre
    WHERE empresa = m_emp_benef
      AND trans_nota_fiscal = m_trans_nf
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tab fat_nf_mestre'
      RETURN m_msg
   END IF
   
   LET p_user = mr_nf_mestre.usu_incl_nf
   
   SELECT DISTINCT cod_fiscal
     INTO l_cod_fiscal
     FROM fat_nf_item_fisc
    WHERE empresa = m_emp_benef
      AND trans_nota_fiscal = m_trans_nf
      AND seq_item_nf = 1

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo cod_fiscal da tab fat_nf_item_fisc:cod_fiscal'
      RETURN m_msg
   END IF

   SELECT SUM(val_trib_merc)
     INTO m_tot_icms_dec
     FROM fat_nf_item_fisc
    WHERE empresa = m_emp_benef
      AND trans_nota_fiscal = m_trans_nf
      AND cod_fiscal = l_cod_fiscal
      AND tributo_benef = 'ICMS'

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo cod_fiscal da tab fat_nf_item_fisc:ICMS'
      RETURN m_msg
   END IF
   
   IF m_tot_icms_dec IS NULL THEN
      LET m_tot_icms_dec = 0
   END IF

   SELECT SUM(val_trib_merc)
     INTO m_tot_ipi_dec
     FROM fat_nf_item_fisc
    WHERE empresa = m_emp_benef
      AND trans_nota_fiscal = m_trans_nf
      AND cod_fiscal = l_cod_fiscal
      AND tributo_benef = 'IPI'

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo cod_fiscal da tab fat_nf_item_fisc:IPI'
      RETURN m_msg
   END IF
   
   IF m_tot_ipi_dec IS NULL THEN
      LET m_tot_ipi_dec = 0
   END IF
                  
   LET m_dat_atu = DATE(mr_nf_mestre.dat_hor_emissao)
   LET m_cfop = l_cod_fiscal
   CALL func022_acerta_cfop()

   IF NOT func022_le_num_ar() THEN
      RETURN m_msg
   END IF

   IF NOT func022_ins_sup_par_ar() THEN
      RETURN FALSE
   END IF

   IF NOT func022_grava_itens_nf() THEN
      RETURN m_msg
   END IF
   
   IF NOT func022_grava_nota() THEN
      RETURN m_msg
   END IF

   IF lr_nota.ies_indus = 'S' THEN
      IF NOT func022_baixa_mat_ret() THEN
         RETURN m_msg
      END IF
   END IF
   
   RETURN 'OK'

END FUNCTION    

#------------------------------#
 FUNCTION func022_acerta_cfop()#
#------------------------------#

   DEFINE i, j          SMALLINT,
          l_cod_fiscal  CHAR(07),
          l_cod_fiscal2 CHAR(07)
   
   IF m_cfop IS NULL THEN
      RETURN 
   END IF
   
   LET l_cod_fiscal = m_cfop
   LET l_cod_fiscal2 = NULL
   
   LET i                  = 0
   LET j                  = 0

   FOR i = 1 TO LENGTH(l_cod_fiscal)
      IF  l_cod_fiscal[i] MATCHES '[0123456789]' THEN   
          LET j  =  j  +  1
          IF j  =   1  THEN
             IF l_cod_fiscal[i] = "7" THEN 
                LET l_cod_fiscal2[j] = "3"    
                LET m_cfop[j] = '3'  
                LET m_prefixo = '3'
             ELSE
                IF l_cod_fiscal[i] = "6" THEN 
                   LET l_cod_fiscal2[j] = "2" 
                   LET m_cfop[j] = '6'   
                   LET m_prefixo = '2'  
                ELSE
                   LET l_cod_fiscal2[j] = "1"   
                   LET m_cfop[j] = '5'   
                   LET m_prefixo = '1'
                END IF
             END IF
             LET j  =  j  +  1
             LET l_cod_fiscal2[j] = "."      
             LET m_cfop[j] = "." 
          ELSE
             LET l_cod_fiscal2[j] = l_cod_fiscal[i] 
             LET m_cfop[j] = l_cod_fiscal[i] 
          END IF
      END IF
   END FOR

   LET m_cod_fisc_item = l_cod_fiscal2 CLIPPED
 
END FUNCTION                                                                   

#----------------------------#
 FUNCTION func022_le_num_ar()#
#----------------------------#

   SELECT par_val
     INTO m_num_ar
     FROM par_sup_pad
    WHERE cod_empresa   = m_emp_vend
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo n�mero do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   UPDATE par_sup_pad
      SET par_val = (par_val + 1)
    WHERE cod_empresa   = m_emp_vend
      AND cod_parametro = "num_prx_ar"

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' Atualizando n�mero do AR na tabela par_sup_pad.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func022_grava_itens_nf()#
#--------------------------------#
   
   LET m_num_seq = 0
   
   DECLARE cq_nf_item CURSOR FOR
    SELECT * FROM fat_nf_item
     WHERE empresa = m_emp_benef
       AND trans_nota_fiscal = m_trans_nf
       AND pedido > 0

   FOREACH cq_nf_item INTO mr_nf_item.*       

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tab fat_nf_item_fisc'
         RETURN FALSE
      END IF
      
      LET m_cod_item = mr_nf_item.item
      LET m_num_seq = m_num_seq + 1
      
      IF NOT func022_grava_ar() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
END FUNCTION

#--------------------------#
FUNCTION func022_grava_ar()#
#--------------------------#
   
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

   LET lr_param.cod_empresa = m_emp_vend
   LET lr_param.cod_cliente = m_cod_fornecedor
   LET lr_param.cod_item = m_cod_item
   
   SELECT cod_cidade,
          cod_uni_feder
     INTO lr_param.cod_cidade,
          m_cod_uni_feder
     FROM fornecedor
    WHERE cod_fornecedor = m_cod_fornecedor
    
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados do fornecedor'
      RETURN FALSE
   END IF
   
   SELECT gru_ctr_desp
     INTO lr_param.cod_nat_oper
     FROM item_sup
    WHERE cod_empresa = m_emp_vend
      AND cod_item = m_cod_item
    
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados do item'
      RETURN FALSE
   END IF
      
   LET lr_param.origem = 'E'
   LET lr_param.cod_tip_carteira = mr_nf_mestre.tip_carteira
   LET lr_param.ies_finalidade = mr_nf_mestre.finalidade

   LET l_ret = func021_par_fiscal(lr_param)
   
   IF l_ret = 'OK' THEN
   ELSE
      LET m_msg = l_ret
      RETURN FALSE
   END IF
         
   IF NOT func022_ins_aviso_rec() THEN
      RETURN FALSE
   END IF
   
   IF NOT func022_ins_audit_ar() THEN
      RETURN FALSE
   END IF

   IF NOT func022_ins_dest_ar() THEN
      RETURN FALSE
   END IF

   IF NOT func022_ins_ar_seq() THEN
      RETURN FALSE
   END IF

   IF NOT func022_gra_par_ar() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION func022_ins_aviso_rec()#
#-------------------------------#
            
   LET mr_aviso.cod_empresa        = m_emp_vend
   LET mr_aviso.cod_item           = m_cod_item
   LET mr_aviso.qtd_declarad_nf    = mr_nf_item.qtd_item
   LET mr_aviso.qtd_devolvid       = 0

   IF NOT func022_le_item() THEN
      RETURN FALSE
   END IF

   LET mr_aviso.cod_empresa_estab  = NULL
   LET mr_aviso.num_aviso_rec      = m_num_ar
   LET mr_aviso.num_seq            = m_num_seq
   LET mr_aviso.dat_inclusao_seq   = m_dat_atu 
   LET mr_aviso.ies_situa_ar       = 'E'
   LET mr_aviso.ies_incl_almox     = 'N'
   LET mr_aviso.ies_receb_fiscal   = 'S'
   LET mr_aviso.ies_liberacao_ar   = '1'
   LET mr_aviso.ies_liberacao_cont = m_ies_contag
   LET mr_aviso.ies_liberacao_insp = m_ies_insp
   
   IF mr_aviso.ies_liberacao_cont = 'S' THEN
      LET mr_aviso.qtd_recebida = mr_aviso.qtd_declarad_nf 
   ELSE
      LET mr_aviso.qtd_recebida = 0
   END IF
   
   LET mr_aviso.ies_diverg_listada = 'N'

   IF NOT func022_le_ped_sup() THEN
      RETURN FALSE
   END IF
   
   LET mr_aviso.num_pedido = m_num_pc   
   LET mr_aviso.num_oc = m_num_oc

   IF NOT func022_le_ord_comp() THEN
      RETURN FALSE
   END IF

   LET mr_aviso.pre_unit_nf = m_pre_unit

   #--------------------------------------------------------------------------------#

   LET mr_aviso.cod_fiscal_item = m_cod_fisc_item

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
   
   IF NOT func022_le_incidencia() THEN
      RETURN FALSE
   END IF
   
   LET mr_aviso.pct_ipi_tabela = m_pct_ipi
   LET mr_aviso.pct_icms_item_c = m_pct_icms
   
   LET mr_aviso.val_base_c_item_c  = mr_aviso.qtd_declarad_nf * mr_aviso.pre_unit_nf
   LET mr_aviso.val_base_c_ipi_it  = mr_aviso.val_base_c_item_c 
   
   LET mr_aviso.val_ipi_calc_item  = 
         mr_aviso.val_base_c_ipi_it * (mr_aviso.pct_ipi_tabela / 100)
   LET mr_aviso.val_liquido_item   = mr_aviso.qtd_declarad_nf * mr_aviso.pre_unit_nf
   LET mr_aviso.val_contabil_item  = mr_aviso.val_liquido_item + mr_aviso.val_ipi_calc_item

   LET mr_aviso.val_base_c_item_d  = mr_nf_item.val_liquido_item
   
   IF NOT func022_le_item_fisc() THEN
      RETURN FALSE
   END IF
   
   LET mr_aviso.val_icms_item_c    = mr_aviso.val_liquido_item * (mr_aviso.pct_icms_item_c / 100)
      
   #--------------------------------------------------------------------------------#
   
   LET mr_aviso.val_desc_item      = 0
   LET mr_aviso.dat_devoluc        = NULL
   LET mr_aviso.val_devoluc        = 0
   LET mr_aviso.num_nf_dev         = 0
   LET mr_aviso.qtd_rejeit         = 0
   LET mr_aviso.qtd_liber          = mr_aviso.qtd_recebida
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
FUNCTION func022_ins_audit_ar()#
#------------------------------#

   DEFINE lr_audit_ar       RECORD LIKE audit_ar.*

   LET lr_audit_ar.cod_empresa = mr_aviso.cod_empresa               
   LET lr_audit_ar.num_aviso_rec = mr_aviso.num_aviso_rec    
   LET lr_audit_ar.num_seq = mr_aviso.num_seq                
   LET lr_audit_ar.nom_usuario = mr_nf_mestre.usu_incl_nf                         
   LET lr_audit_ar.dat_hor_proces = CURRENT                     
   LET lr_audit_ar.num_prog = m_num_prog                         
   LET lr_audit_ar.ies_tipo_auditoria = '1'                     
      
   INSERT INTO audit_ar VALUES(lr_audit_ar.*)

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
FUNCTION func022_ins_dest_ar()#
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
      LET mr_dest_ar.cod_secao_receb    = m_cod_local_receb                           
      LET mr_dest_ar.qtd_recebida       = mr_aviso.qtd_recebida     
      LET mr_dest_ar.ies_contagem       = mr_aviso.ies_liberacao_cont                            
      LET mr_dest_ar.cod_seg_merc       = mr_aen.cod_seg_merc           
      LET mr_dest_ar.cod_cla_uso        = mr_aen.cod_cla_uso                      
                                                          
      {INSERT INTO dest_aviso_rec4 VALUES (mr_dest_ar.*)           

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela dest_aviso_rec4.'
         RETURN FALSE
      END IF}
      
      INSERT INTO dest_aviso_rec
       VALUES (
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
         m_num_prog)

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela dest_aviso_rec.'
         RETURN FALSE
      END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION func022_ins_ar_seq()#
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
FUNCTION func022_gra_par_ar()#
#----------------------------#
   
   DEFINE l_tributo             LIKE obf_config_fiscal.tributo_benef,
          l_enquadramento_legal INTEGER
   
   INITIALIZE mr_sup_par.* TO NULL
   
   LET mr_sup_par.empresa = mr_aviso.cod_empresa         
   LET mr_sup_par.aviso_recebto = mr_aviso.num_aviso_rec
   LET mr_sup_par.seq_aviso_recebto = mr_aviso.num_seq

   LET mr_sup_par.parametro = 'calc_st_formula'
   LET mr_sup_par.par_ind_especial = 'U'

   IF NOT func022_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_sup_par.par_ind_especial = ' '
   
   LET mr_sup_par.parametro = 'desconto_fiscal'
   LET mr_sup_par.parametro_val = 0   
   
   IF NOT func022_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_sup_par.parametro = 'bc_dif_aliq_icms'
   LET mr_sup_par.parametro_val = mr_aviso.val_liquido_item   

   IF NOT func022_ins_par_ar() THEN
      RETURN FALSE
   END IF   
 
   LET mr_sup_par.parametro = 'bc_icms_sem_red_fix'

   IF NOT func022_ins_par_ar() THEN
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
      
      LET l_tributo = func022_tributo()
      LET m_tributo = 'cod_cst_',l_tributo CLIPPED
      LET mr_sup_par.parametro = m_tributo
      LET mr_sup_par.par_ind_especial = 'A'
      LET mr_sup_par.parametro_texto = m_trans_config
      LET mr_sup_par.parametro_dat = NULL
      
      IF NOT func022_ins_par_ar() THEN
         RETURN FALSE
      END IF   
      
      IF UPSHIFT(l_tributo) = 'IPI' THEN
         LET mr_sup_par.parametro = 'enquadr_legal_ipi'
         LET mr_sup_par.par_ind_especial = ' '
         LET mr_sup_par.parametro_val = l_enquadramento_legal
      
         IF NOT func022_ins_par_ar() THEN
            RETURN FALSE
         END IF   
      END IF
            
   END FOREACH

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION func022_ins_par_ar()#
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
FUNCTION func022_le_item()#
#-------------------------#
   
   SELECT ies_ctr_estoque,                     
          ies_ctr_lote,                           
          cod_cla_fisc,                           
          cod_unid_med,                           
          cod_local_estoq,
          den_item,
          cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso
     INTO mr_aviso.ies_item_estoq,     
          mr_aviso.ies_controle_lote,        
          mr_aviso.cod_cla_fisc,               
          mr_aviso.cod_unid_med_nf,            
          mr_aviso.cod_local_estoq,
          mr_aviso.den_item,
          mr_aen.cod_lin_prod, 
          mr_aen.cod_lin_recei,
          mr_aen.cod_seg_merc, 
          mr_aen.cod_cla_uso  
     FROM item                                    
    WHERE cod_empresa = mr_aviso.cod_empresa             
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
   
   LET mr_aviso.cod_cla_fisc_nf = ' '
   
   SELECT cod_comprador,                      
          gru_ctr_desp,                          
          cod_tip_despesa,                       
          num_conta,
          ies_tip_incid_ipi,
          ies_tip_incid_icms,
          cod_tip_despesa,
          cod_local_receb
     INTO mr_aviso.cod_comprador,             
          mr_aviso.gru_ctr_desp_item,         
          mr_aviso.cod_tip_despesa,           
          m_num_conta_deb,
          mr_aviso.ies_tip_incid_ipi,
          mr_aviso.ies_incid_icms_ite,
          mr_aviso.cod_tip_despesa,
          m_cod_local_receb        
     FROM item_sup                               
    WHERE cod_empresa = mr_aviso.cod_empresa            
      AND cod_item = mr_aviso.cod_item                   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item_sup, p/ grava��o no AR.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION func022_le_ped_sup()#
#----------------------------#
   
   DEFINE l_tipo_processo    CHAR(01),
          l_num_lote         CHAR(15),
          l_num_pv           INTEGER,
          l_num_seq          INTEGER
   
   SELECT tipo_processo
     INTO l_tipo_processo
     FROM tipo_pedido_885
    WHERE cod_empresa = m_emp_vend
      AND num_pedido = mr_nf_item.pedido

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela tipo_pedido_885'
      RETURN FALSE
   END IF

   LET l_num_pv = mr_nf_item.pedido
   LET l_num_seq = mr_nf_item.seq_item_pedido   
   
   IF l_tipo_processo = '2' THEN #PEDIDO DE FATURAMENTO
      SELECT numlote 
        INTO l_num_lote
        FROM roma_item_885
       WHERE codempresa = m_emp_benef
         AND numromaneio = m_num_romaneio
         AND numseqpai = m_num_seq_pai
         AND numpedido = l_num_pv
         AND numseqitem = l_num_seq

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela roma_item_885'
         RETURN FALSE
      END IF
      
      SELECT num_pv, num_seq
        INTO l_num_pv, l_num_seq
        FROM pedido_lote_885
       WHERE cod_empresa = m_emp_benef
         AND num_num_lote = l_num_lote

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela pedido_lote_885'
         RETURN FALSE
      END IF
   
   END IF

   SELECT num_pc, num_oc
     INTO m_num_pc, m_num_oc
     FROM ped_vend_comp_885
    WHERE cod_empresa = m_emp_vend
      AND num_pv = l_num_pv
      AND num_seq = l_num_seq

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela ped_vend_comp_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func022_le_ord_comp()#
#-----------------------------#

   SELECT pre_unit_oc,
          pct_ipi
     INTO m_pre_unit,
          m_pct_ipi
     FROM ordem_sup
    WHERE cod_empresa = m_emp_vend
      AND num_oc = m_num_oc
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo pre�o da tabela ordem_sup'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
     
   
#-------------------------------#
FUNCTION func022_le_incidencia()#
#-------------------------------#

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

   {SELECT DISTINCT pct_ipi
     INTO mr_aviso.pct_ipi_tabela
     FROM clas_fiscal
    WHERE cod_cla_fisc = mr_aviso.cod_cla_fisc
      AND ies_tributa_ipi = 'S'
      AND cod_unid_med_fisc = mr_aviso.cod_unid_med_nf

   IF STATUS = 100 THEN
      LET mr_aviso.pct_ipi_tabela = 0
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela clas_fiscal.'
         RETURN FALSE
      END IF
   END IF}

   SELECT pct_icms  
     INTO m_pct_icms
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

#------------------------------#
FUNCTION func022_le_item_fisc()#
#------------------------------#

   SELECT val_trib_merc,
          aliquota
     INTO mr_aviso.val_icms_item_d,
          mr_aviso.pct_icms_item_d
     FROM fat_nf_item_fisc 
    WHERE empresa = mr_nf_item.empresa 
      AND trans_nota_fiscal = mr_nf_item.trans_nota_fiscal
      AND seq_item_nf = mr_nf_item.seq_item_nf
      AND tributo_benef = 'ICMS'
   
   IF STATUS = 100 THEN
      LET mr_aviso.val_icms_item_d = 0
      LET mr_aviso.pct_icms_item_d = 0
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela fat_nf_item_fisc:ICMS'
         RETURN FALSE
      END IF
   END IF

   SELECT val_trib_merc,
          aliquota
     INTO mr_aviso.val_ipi_decl_item,
          mr_aviso.pct_ipi_declarad
     FROM fat_nf_item_fisc 
    WHERE empresa = mr_nf_item.empresa 
      AND trans_nota_fiscal = mr_nf_item.trans_nota_fiscal
      AND seq_item_nf = mr_nf_item.seq_item_nf
      AND tributo_benef = 'IPI'
      
   IF STATUS = 100 THEN
      LET mr_aviso.val_ipi_decl_item = 0
      LET mr_aviso.pct_ipi_declarad = 0
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela fat_nf_item_fisc:IPI'
         RETURN FALSE
      END IF
   END IF
       
   RETURN TRUE

END FUNCTION
           
      
#-------------------------#
FUNCTION func022_tributo()#
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
FUNCTION func022_grava_nota()#
#----------------------------#
   
   IF NOT func022_ins_nf_sup() THEN
      RETURN FALSE
   END IF

   IF m_nf_com_erro = 'S' THEN
      IF NOT func022_ins_nf_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT func022_ins_ar_compl() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION func022_ins_nf_sup()#
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
   
   LET mr_nf_sup.cod_empresa         = mr_aviso.cod_empresa       
   LET mr_nf_sup.cod_empresa_estab   = NULL
   LET mr_nf_sup.num_nf              = mr_nf_mestre.nota_fiscal
   LET mr_nf_sup.ser_nf              = mr_nf_mestre.serie_nota_fiscal
   LET mr_nf_sup.ssr_nf              = mr_nf_mestre.subserie_nf
   LET mr_nf_sup.ies_especie_nf      = 'NF'
   LET mr_nf_sup.cod_fornecedor      = m_cod_fornecedor
   LET mr_nf_sup.num_conhec          = 0
   LET mr_nf_sup.ser_conhec          = ' '
   LET mr_nf_sup.ssr_conhec          = 0
   LET mr_nf_sup.cod_transpor        = mr_nf_mestre.transportadora
   
   IF mr_nf_sup.cod_transpor IS NULL THEN
      LET mr_nf_sup.cod_transpor = ' '
   END IF
   
   LET mr_nf_sup.num_aviso_rec       = mr_aviso.num_aviso_rec
   LET mr_nf_sup.dat_emis_nf         = m_dat_atu
   LET mr_nf_sup.dat_entrada_nf      = m_dat_atu
   LET mr_nf_sup.cod_regist_entrada  = 1
   LET mr_nf_sup.val_tot_nf_d        = mr_nf_sup.val_tot_nf_c
   LET mr_nf_sup.val_tot_icms_nf_d   = m_tot_icms_dec
   LET mr_nf_sup.val_tot_desc        = 0
   LET mr_nf_sup.val_tot_acresc      = 0
   LET mr_nf_sup.val_ipi_nf          = m_tot_ipi_dec
   LET mr_nf_sup.val_despesa_aces    = 0
   LET mr_nf_sup.val_adiant          = 0
   LET mr_nf_sup.ies_tip_frete       = '0'
   LET mr_nf_sup.cnd_pgto_nf         = mr_nf_mestre.cond_pagto
   LET mr_nf_sup.cod_mod_embar       = 3
   LET mr_nf_sup.ies_nf_com_erro     = m_nf_com_erro
   LET mr_nf_sup.nom_resp_aceite_er  = mr_nf_mestre.usu_incl_nf
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
   LET mr_nf_sup.ies_nf_aguard_nfe   = '1'
                    
   INSERT INTO nf_sup VALUES(mr_nf_sup.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' inserindo registro na tabela nf_sup.'
      RETURN FALSE
   END IF
         
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION func022_ins_nf_erro()#
#-----------------------------#

   IF g_tipo_sgbd = 'MSV' THEN
      INSERT INTO nf_sup_erro(
         empresa, num_aviso_rec, num_seq,
         des_pendencia_item, ies_origem_erro,
         ies_erro_grave)
        VALUES (mr_nf_sup.cod_empresa,
                mr_nf_sup.num_aviso_rec,
                0,
                m_den_erro,
                '3',
                'N')
   ELSE  
      INSERT INTO nf_sup_erro
        VALUES (mr_nf_sup.cod_empresa,
                mr_nf_sup.num_aviso_rec,
                0,
                m_den_erro,
                '3',
                'N',
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
   
#--------------------------------#
FUNCTION func022_ins_sup_par_ar()#
#--------------------------------#

   DEFINE l_parametro_txt   LIKE sup_par_ar.parametro_texto
   
   INITIALIZE mr_sup_par.* TO NULL
   
   LET l_parametro_txt = EXTEND(CURRENT, YEAR TO SECOND)
   
   LET mr_sup_par.empresa = m_emp_vend       
   LET mr_sup_par.aviso_recebto = m_num_ar 
   LET mr_sup_par.seq_aviso_recebto = 0
   
   LET mr_sup_par.parametro = 'data_hora_nf_entrada'
   LET mr_sup_par.par_ind_especial = ' '
   LET mr_sup_par.parametro_texto = l_parametro_txt
   LET mr_sup_par.parametro_val = NULL   
   LET mr_sup_par.parametro_dat = NULL   

   IF NOT func022_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   LET mr_sup_par.parametro = 'meio_transp_ar'
   LET mr_sup_par.parametro_texto = NULL
   LET mr_sup_par.parametro_val = 1 

   IF NOT func022_ins_par_ar() THEN
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION func022_ins_ar_compl()#
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
      LET lr_ar_compl.filial = NULL
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
FUNCTION func022_baixa_mat_ret()#
#-------------------------------#
   
   DEFINE l_count      INTEGER,
          l_id         INTEGER

   SELECT par_txt FROM par_sup_pad  
     INTO m_cod_oper_transf
    WHERE cod_empresa = m_emp_vend 
      AND cod_parametro = 'contr_local_terc'

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'                                                     
      LET m_msg = 'Erro de status: ',m_erro                                                 
      LET m_msg = m_msg CLIPPED, ' lendo operra��o transf na tabela par_sup_pad.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_oper_transf IS NULL THEN
      LET m_msg = 'Operra��o de transf de terceiro n�o cadastrada na tabela par_sup_pad.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   SELECT cod_operac_benef, 
          cod_operac_retorno  
     INTO m_cod_oper_baixa,
          m_cod_oper_cont_ar
     FROM par_sup_compl 
    WHERE cod_empresa = m_emp_vend
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'                                                     
      LET m_msg = 'Erro de status: ',m_erro                                                 
      LET m_msg = m_msg CLIPPED, ' lendo operra��es na tabela par_sup_compl.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_oper_baixa IS NULL THEN
      LET m_msg = 'Operra��o de baixa n�o cadastrada na tabela par_sup_compl.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_oper_cont_ar IS NULL THEN
      LET m_msg = 'Operra��o de retorno n�o cadastrada na tabela par_sup_compl.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   
   
   SELECT par_txt 
     INTO m_cod_oper_grade
     FROM par_sup_pad  
    WHERE cod_empresa = m_emp_vend
      AND cod_parametro = 'oper_transf_grade'

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'                                                     
      LET m_msg = 'Erro de status: ',m_erro                                                 
      LET m_msg = m_msg CLIPPED, ' lendo operra��o de grade na tabela par_sup_pad.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_oper_grade IS NULL THEN
      LET m_msg = 'Operra��o de grade n�o cadastrada na tabela par_sup_pad.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   
   
   SELECT cod_operac_estoq_l 
     INTO m_cod_oper_insp
     FROM par_sup 
    WHERE cod_empresa = m_emp_vend

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET m_erro = STATUS USING '<<<<<'                                                     
      LET m_msg = 'Erro de status: ',m_erro                                                 
      LET m_msg = m_msg CLIPPED, ' lendo operra��o de inspe��o na tabela par_sup.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_oper_insp IS NULL THEN
      LET m_msg = 'Operra��o de inspe��o n�o cadastrada na tabela par_sup.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   
   
   LET l_id = 0
   
   DROP TABLE w_retr_temp
   
   CREATE TEMP TABLE w_retr_temp (
       id_registro         INTEGER,
       seq_item_nf         INTEGER,
       nf_entrada          INTEGER, 
       serie_nf_entrada    CHAR(03),
       subserie_nfe        INTEGER,
       especie_nf_entrada  CHAR(03),
       fornecedor          CHAR(15),
       seq_tabulacao       INTEGER,
       cod_item_dev        CHAR(15),
       qtd_devolvida       DECIMAL(10,3),
       num_lote            CHAR(15),
       comprimento         INTEGER,
       largura             INTEGER,
       altura              INTEGER,
       diametro            INTEGER,
       ies_situa           CHAR(01)
   );
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' ciando tabela w_retr_temp.'
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX w_retr_temp 
      ON w_retr_temp(id_registro);

   DECLARE cq_mat_ret CURSOR FOR
    SELECT seq_item_nf, item
      FROM fat_nf_item  
     WHERE empresa = m_emp_benef
       AND trans_nota_fiscal = m_trans_nf
       AND pedido = 0

   FOREACH cq_mat_ret INTO 
      mr_retr_item.seq_item_nf, mr_retr_item.cod_item_dev
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo mat delvolvido da tabela fat_nf_item.'
         RETURN FALSE
      END IF
      
      DECLARE cq_nf_ret CURSOR FOR
       SELECT fat_retn_item_nf.nf_entrada, 
              fat_retn_item_nf.serie_nf_entrada,
              fat_retn_item_nf.subserie_nfe, 
              fat_retn_item_nf.especie_nf_entrada,
              fat_retn_item_nf.fornecedor,
              fat_retn_item_nf.seq_tabulacao,
              fat_retn_item_nf.qtd_devolvida,
              sup_item_terc_end.lote,
              sup_item_terc_end.sit_qtd,
              sup_item_terc_end.comprimento,
              sup_item_terc_end.largura,
              sup_item_terc_end.altura,
              sup_item_terc_end.diametro
         FROM fat_retn_item_nf, sup_item_terc_end 
        WHERE fat_retn_item_nf.empresa = m_emp_benef 
          AND fat_retn_item_nf.trans_nota_fiscal = m_trans_nf 
          AND fat_retn_item_nf.seq_item_nf = mr_retr_item.seq_item_nf
          AND sup_item_terc_end.empresa = fat_retn_item_nf.empresa
          AND sup_item_terc_end.nota_fiscal = fat_retn_item_nf.nf_entrada
          AND sup_item_terc_end.serie_nota_fiscal = fat_retn_item_nf.serie_nf_entrada
          AND sup_item_terc_end.subserie_nf = fat_retn_item_nf.subserie_nfe
          AND sup_item_terc_end.espc_nota_fiscal = fat_retn_item_nf.especie_nf_entrada
          AND sup_item_terc_end.fornecedor = fat_retn_item_nf.fornecedor
          AND sup_item_terc_end.aviso_recebto = fat_retn_item_nf.aviso_recebto
          AND sup_item_terc_end.seq_aviso_recebto = fat_retn_item_nf.seq_item_ar
          AND sup_item_terc_end.seq_tabulacao = fat_retn_item_nf.seq_tabulacao
          
      FOREACH cq_nf_ret INTO
         mr_retr_item.nf_entrada,        
         mr_retr_item.serie_nf_entrada,  
         mr_retr_item.subserie_nfe,     
         mr_retr_item.especie_nf_entrada,
         mr_retr_item.fornecedor,        
         mr_retr_item.seq_tabulacao,     
         mr_retr_item.qtd_devolvida,
         mr_retr_item.num_lote,
         mr_retr_item.ies_situa,
         mr_retr_item.comprimento,
         mr_retr_item.largura,    
         mr_retr_item.altura,     
         mr_retr_item.diametro   
                       
         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' lendo mat delvolvido da tabela fat_retn_item_nf.'
            RETURN FALSE
         END IF
         
         LET l_id = l_id + 1         
         LET mr_retr_item.id_registro = l_id
         
         INSERT INTO w_retr_temp
          VALUES(mr_retr_item.*)

         IF STATUS <> 0 THEN
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela w_retr_temp.'
            RETURN FALSE
         END IF
      
      END FOREACH
      
      FREE cq_nf_ret
      
   END FOREACH
   
   FREE cq_mat_ret
   
   SELECT COUNT(*) INTO l_count FROM w_retr_temp
   
   IF l_count = 0 THEN
      RETURN TRUE
   END IF
   
   DECLARE cq_item_ar CURSOR FOR                                                         
    SELECT a.cod_item, a.num_oc, 
           a.qtd_declarad_nf, 
           a.num_seq, dat_inclusao_seq                                           
      FROM aviso_rec a, item i                                                                 
     WHERE a.cod_empresa = m_emp_vend                                                          
       AND a.num_aviso_rec = m_num_ar                                                          
       AND i.cod_empresa = a.cod_empresa                                                       
       AND i.cod_item = a.cod_item                                                             
       AND i.ies_tip_item = 'B'                                                                
                                                                                               
   FOREACH cq_item_ar INTO                                                                     
      m_cod_item, m_num_oc, 
      m_qtd_item, m_num_seq, m_dat_inclusao                               
                                                                                         
      IF STATUS <> 0 THEN                                                                      
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' lendo produtos da tabela aviso_rec.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   

      DECLARE cq_estrut_oc CURSOR FOR                                                                                      
       SELECT cod_item_comp, 
              SUM(qtd_necessaria)                                                                                                                              
         FROM estrut_ordem_sup                                                                  
        WHERE cod_empresa = m_emp_vend                                                          
          AND num_oc = m_num_oc                                                                 
        GROUP BY cod_item_comp
      
      FOREACH cq_estrut_oc INTO 
         m_cod_item_comp, m_qtd_necessaria                                                                                                              
      
         IF STATUS <> 0 THEN                                                                      
            LET m_erro = STATUS USING '<<<<<'                                                     
            LET m_msg = 'Erro de status: ',m_erro                                                 
            LET m_msg = m_msg CLIPPED, ' lendo dados da tabela estrut_ordem_sup.'                 
            RETURN FALSE                                                                          
         END IF                                                                                   
                                                                                               
         IF m_qtd_necessaria IS NULL OR m_qtd_necessaria <= 0 THEN                                                         
            CONTINUE FOREACH                                                                      
         END IF                                                                                   
                                                                                               
         LET m_qtd_bx_tot = m_qtd_item * m_qtd_necessaria                             

         DECLARE cq_w_temp CURSOR FOR
          SELECT * FROM w_retr_temp
           WHERE cod_item_dev = m_cod_item_comp
             AND qtd_devolvida > 0
         
         FOREACH cq_w_temp INTO mr_retr_item.*

            IF STATUS <> 0 THEN                                                                      
               LET m_erro = STATUS USING '<<<<<'                                                     
               LET m_msg = 'Erro de status: ',m_erro                                                 
               LET m_msg = m_msg CLIPPED, ' lendo registros da tabela w_retr_temp.'                 
               RETURN FALSE                                                                          
            END IF                                                                                   
            
            IF m_qtd_bx_tot <= mr_retr_item.qtd_devolvida THEN
               LET m_qtd_baixar = m_qtd_bx_tot
               LET m_qtd_bx_tot = 0
            ELSE
               LET m_qtd_baixar = mr_retr_item.qtd_devolvida
               LET m_qtd_bx_tot = m_qtd_bx_tot - m_qtd_baixar
            END IF

            UPDATE w_retr_temp 
               SET qtd_devolvida = qtd_devolvida - m_qtd_baixar
             WHERE id_registro = mr_retr_item.id_registro

            IF STATUS <> 0 THEN                                                                      
               LET m_erro = STATUS USING '<<<<<'                                                     
               LET m_msg = 'Erro de status: ',m_erro                                                 
               LET m_msg = m_msg CLIPPED, ' atualizano registros da tabela w_retr_temp.'                 
               RETURN FALSE                                                                          
            END IF                                                                                   
            
            IF NOT func022_ret_indus(m_qtd_baixar) THEN
               RETURN FALSE
            END IF
            
            IF m_qtd_bx_tot <= 0 THEN
               EXIT FOREACH
            END IF
            
         END FOREACH
         
         FREE cq_w_temp
                           
      END FOREACH
      
      FREE cq_estrut_oc
      
   END FOREACH
   
   FREE cq_item_ar
   
   RETURN TRUE

END FUNCTION

#------------------------------------#         
FUNCTION func022_ret_indus(l_qtd_dev)#
#------------------------------------#
   
   DEFINE l_qtd_dev       DECIMAL(10,3),
          l_seq_item_nf   INTEGER,
          l_qtd_saldo     DECIMAL(10,3),
          l_cod_for       CHAR(15)
          
   DECLARE cq_ret_ind CURSOR FOR
    SELECT item_em_terc.num_sequencia, item_em_terc.cod_motivo_remessa,
           (item_em_terc.qtd_tot_remessa - item_em_terc.qtd_tot_recebida), 
           item_em_terc.cod_fornecedor, fat_nf_item.seq_item_nf
      FROM item_em_terc, fat_nf_mestre, fat_nf_item
     WHERE item_em_terc.cod_empresa = m_emp_vend 
       AND item_em_terc.num_nf = mr_retr_item.nf_entrada 
       AND item_em_terc.cod_item = mr_retr_item.cod_item_dev
       AND fat_nf_mestre.empresa = item_em_terc.cod_empresa 
       AND fat_nf_mestre.nota_fiscal = item_em_terc.num_nf
       AND fat_nf_mestre.cliente = item_em_terc.cod_fornecedor
       AND fat_nf_item.empresa = fat_nf_mestre.empresa 
       AND fat_nf_item.trans_nota_fiscal = fat_nf_mestre.trans_nota_fiscal
       AND fat_nf_item.item = item_em_terc.cod_item

   FOREACH cq_ret_ind INTO 
      m_seq_it_em_terc, m_cod_mot_remessa, l_qtd_saldo, l_cod_for, l_seq_item_nf
   
      IF STATUS <> 0 THEN                                                                      
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela item_em_terc.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   
            
      IF l_qtd_saldo < l_qtd_dev THEN
         LET m_qtd_movto = l_qtd_saldo
      ELSE
         LET m_qtd_movto = l_qtd_dev
      END IF
      
      UPDATE item_em_terc SET qtd_tot_recebida = qtd_tot_recebida + m_qtd_movto
       WHERE cod_empresa = m_emp_vend
         AND num_nf = mr_retr_item.nf_entrada 
         AND num_sequencia = m_seq_it_em_terc
         AND cod_item = mr_retr_item.cod_item_dev
               
      IF STATUS <> 0 THEN                                                                      
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' atualizando saldo da tabela item_em_terc.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   
 
      SELECT local, lote, sit_qtd,
             comprimento, largura, altura, diametro 
        INTO m_cod_loc_estoq, 
             mr_retr_item.num_lote,
             mr_retr_item.ies_situa,
             mr_retr_item.comprimento,
             mr_retr_item.largura,
             mr_retr_item.altura,
             mr_retr_item.diametro
        FROM sup_itterc_grade  
       WHERE empresa = m_emp_vend
         AND nota_fiscal = mr_retr_item.nf_entrada
         AND seq_item_nf = m_seq_it_em_terc 
         AND fornecedor = l_cod_fiscal
         AND seq_tabulacao = mr_retr_item.seq_tabulacao
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela sup_itterc_grade.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   

      UPDATE sup_itterc_grade SET qtd_tot_receb = qtd_tot_receb + m_qtd_movto
       WHERE empresa = m_emp_vend
         AND nota_fiscal = mr_retr_item.nf_entrada
         AND seq_item_nf = m_seq_it_em_terc 
         AND fornecedor = l_cod_fiscal
         AND seq_tabulacao = mr_retr_item.seq_tabulacao
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' atualizando saldo da tabela sup_itterc_grade.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   
      
      INSERT INTO item_ret_terc(
         cod_empresa,
         num_nf,
         ser_nf,
         ssr_nf,
         ies_especie_nf,
         cod_fornecedor,
         ies_incl_contab,
         num_sequencia_ar,
         dat_emis_nf,
         dat_entrada_nf,
         dat_inclusao_seq,
         num_nf_remessa,
         num_sequencia_nf,
         qtd_devolvida) VALUES(
            m_emp_vend,
            mr_nf_sup.num_nf,
            mr_nf_sup.ser_nf,
            mr_nf_sup.ssr_nf,
            mr_nf_sup.ies_especie_nf,
            mr_nf_sup.cod_fornecedor,
            mr_nf_sup.ies_incl_contab,
            m_num_seq,
            mr_nf_sup.dat_emis_nf,
            mr_nf_sup.dat_entrada_nf,
            m_dat_inclusao,
            mr_retr_item.nf_entrada,
            l_seq_item_nf,
            m_qtd_movto)
            
      IF STATUS <> 0 THEN                                                                      
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela item_ret_terc.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   
         
      
      INSERT INTO sup_retn_item_terc(
         empresa,
         nota_fiscal,
         serie_nota_fiscal,
         subserie_nf,
         espc_nota_fiscal,
         fornecedor,
         seq_aviso_recebto,
         nf_remessa,
         seq_nf_remessa,
         seq_tabulacao,
         qtd_devolvida) VALUES (
            m_emp_vend,
            mr_nf_sup.num_nf,
            mr_nf_sup.ser_nf,
            mr_nf_sup.ssr_nf,
            mr_nf_sup.ies_especie_nf,
            mr_nf_sup.cod_fornecedor,
            m_num_seq,
            mr_retr_item.nf_entrada,
            l_seq_item_nf,
            mr_retr_item.seq_tabulacao,
            m_qtd_movto)

      IF STATUS <> 0 THEN                                                                      
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela sup_retn_item_terc.'                     
         RETURN FALSE                                                                          
      END IF                                                                                   

      IF NOT func022_transf_estoq_terc() THEN
         RETURN FALSE
      END IF

      IF NOT func022_mov_estoq(m_cod_oper_baixa, 'S') THEN
         RETURN FALSE
      END IF
                              
      LET l_qtd_dev = l_qtd_dev - m_qtd_movto
      
      IF l_qtd_dev <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   FREE cq_ret_ind
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION func022_transf_estoq_terc()#   
#-----------------------------------#
   
   DEFINE l_cod_loc_terc      LIKE local.cod_local

   DEFINE lr_item      RECORD
       cod_empresa   LIKE item.cod_empresa,
       num_docum     LIKE estoque_trans.num_docum,
       num_seq       LIKE estoque_trans.num_seq,
       cod_item      LIKE item.cod_item,
       cod_loc_orig  LIKE item.cod_local_estoq,
       cod_loc_dest  LIKE item.cod_local_estoq,
       num_lote      LIKE estoque_lote.num_lote,
       ies_situa_qtd LIKE estoque_lote.ies_situa_qtd,
       qtd_transf    LIKE estoque_lote.qtd_saldo,
       comprimento   LIKE estoque_lote_ender.comprimento,
       largura       LIKE estoque_lote_ender.largura,
       altura        LIKE estoque_lote_ender.altura,
       diametro      LIKE estoque_lote_ender.diametro,
       num_programa  CHAR(08),
       cod_operacao  CHAR(04)
   END RECORD
      
   SELECT cod_local_remessa 
     INTO l_cod_loc_terc
     FROM motivo_remessa  
    WHERE cod_empresa = m_emp_vend
      AND cod_motivo_remessa = m_cod_mot_remessa

   IF STATUS <> 0 THEN                                                                      
      LET m_erro = STATUS USING '<<<<<'                                                     
      LET m_msg = 'Erro de status: ',m_erro                                                 
      LET m_msg = m_msg CLIPPED, ' lendo dados na tabela motivo_remessa.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   
   
   IF l_cod_loc_terc IS NULL THEN
      LET m_msg = m_msg CLIPPED, ' local da remessa inv�lido na tabela motivo_remessa.'                     
      RETURN FALSE                                                                          
   END IF                                                                                   

   IF m_cod_loc_estoq IS NULL THEN
      SELECT cod_local_estoq
        INTO m_cod_loc_estoq
        FROM item
       WHERE cod_empresa = m_emp_vend
         AND cod_item = mr_retr_item.cod_item_dev
        
      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET m_erro = STATUS USING '<<<<<'                                                     
         LET m_msg = 'Erro de status: ',m_erro                                                 
         LET m_msg = m_msg CLIPPED, ' lendo local da tabela item.'                     
         RETURN FALSE                                                                          
      END IF     
   END IF
                                                                                    
   LET lr_item.cod_empresa = m_emp_vend
   LET lr_item.num_docum = m_num_ar
   LET lr_item.num_seq = m_num_seq
   LET lr_item.cod_item = mr_retr_item.cod_item_dev
   LET lr_item.cod_loc_orig = l_cod_loc_terc
   LET lr_item.cod_loc_dest = m_cod_loc_estoq
   LET lr_item.num_lote = mr_retr_item.num_lote
   LET lr_item.ies_situa_qtd = mr_retr_item.ies_situa
   LET lr_item.qtd_transf = m_qtd_movto
   LET lr_item.comprimento  = mr_retr_item.comprimento
   LET lr_item.largura      = mr_retr_item.largura    
   LET lr_item.altura       = mr_retr_item.altura     
   LET lr_item.diametro     = mr_retr_item.diametro   
   LET lr_item.num_programa = m_num_prog
   LET lr_item.cod_operacao = m_cod_oper_transf
   
   IF NOT func014_transf_local(lr_item) THEN
      LET m_msg = g_msg
      RETURN FALSE
   END FUNCTION
   
   RETURN TRUE

END FUNCTION
   
#---------------------------------------------------#
FUNCTION func022_mov_estoq(l_cod_operac, l_tip_oper)#
#---------------------------------------------------#
   
   DEFINE l_cod_operac         LIKE estoque_trans.cod_operacao,
          l_tip_oper           CHAR(01)
          
   LET mr_movto.cod_empresa = m_emp_vend 
   LET mr_movto.cod_item    = mr_retr_item.cod_item_dev
   LET mr_movto.cod_local   = m_cod_loc_estoq
   LET mr_movto.num_lote    = mr_retr_item.num_lote    
   LET mr_movto.comprimento = mr_retr_item.comprimento    
   LET mr_movto.largura     = mr_retr_item.largura   
   LET mr_movto.altura      = mr_retr_item.altura    
   LET mr_movto.diametro    = mr_retr_item.diametro    
   LET mr_movto.cod_operacao = l_cod_operac    
   LET mr_movto.ies_situa    = mr_retr_item.ies_situa   
   LET mr_movto.qtd_movto    = m_qtd_movto   
   LET mr_movto.dat_movto     = TODAY   
   LET mr_movto.ies_tip_movto = 'N'
   LET mr_movto.dat_proces = TODAY
   LET mr_movto.hor_operac = TIME
   LET mr_movto.num_prog = m_num_prog
   LET mr_movto.num_docum = m_num_ar   
   LET mr_movto.num_seq = m_num_seq
   LET mr_movto.tip_operacao = l_tip_oper  
   LET mr_movto.usuario = p_user     
   LET mr_movto.cod_turno = NULL      
   LET mr_movto.trans_origem = 0   
   LET mr_movto.ies_ctr_lote    
   LET mr_movto.num_conta = NULL      
   LET mr_movto.cus_unit  = 0      
   LET mr_movto.cus_tot   = 0   
                                    
   IF NOT func005_insere_movto(mr_movto) THEN
      RETURN FALSE
   END IF

