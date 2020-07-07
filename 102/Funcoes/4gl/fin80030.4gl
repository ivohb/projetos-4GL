#--------------------------------------------------------------------#
# SISTEMA.......: CONTAS A PAGAR                                     #
# FUNCAO .......: FIN80030 (ANTIGO CAP3090)                          #
# OBJETIVO......: GERAR AD E AP NO CONTAS A PAGAR A PARTIR DAS       #
#                 DESPESAS  ORIGINADAS EM OUTROS SISTEMAS            #
# AUTOR.........: EDUARDO FILIPE GOMES                               #
# DATA..........: 11/05/2009                                         #
#--------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_user                  LIKE usuario.nom_usuario,
         g_tipo_sgbd             CHAR(003)

END GLOBALS

#--# MODULARES #--#

  DEFINE m_status       SMALLINT,
         m_msg          CHAR(300),
         m_den          CHAR(300),
         m_ind          SMALLINT,
         m_manut_tabela SMALLINT,
         m_processa     SMALLINT

  DEFINE ma_lanc_cont_cap_integr  ARRAY[500] OF RECORD
                                                   ies_tipo_lanc          LIKE lanc_cont_cap.ies_tipo_lanc,
                                                   num_conta_cont         LIKE lanc_cont_cap.num_conta_cont,
                                                   val_lanc               LIKE lanc_cont_cap.val_lanc,
                                                   tex_hist_lanc          LIKE lanc_cont_cap.tex_hist_lanc,
                                                   ies_desp_val           LIKE lanc_cont_cap.ies_desp_val,
                                                   cod_tip_desp_val       LIKE lanc_cont_cap.cod_tip_desp_val,
                                                   dat_lanc               LIKE lanc_cont_cap.dat_lanc
                                                END RECORD

  DEFINE ma_tipo_valor_integr     ARRAY[100] OF RECORD
                                                   cod_tip_val            DECIMAL(3,0),
                                                   valor                  DECIMAL(15,2),

                                                   num_seq                LIKE ad_valores.num_seq, #--# Necessário apenas para a modificação #--#
                                                   ind_alteracao          CHAR(01),                #--# Necessário apenas para a modificação #--#
                                                   ind_existencia         CHAR(01)                 #--# Controle interno                     #--#
                                                END RECORD

  DEFINE ma_adiantamentos_integr  ARRAY[500] OF RECORD
                                                   cod_tip_val      LIKE ad_valores.cod_tip_val,
                                                   valor            LIKE ad_valores.valor,
                                                   num_ad_nf_orig   LIKE adiant.num_ad_nf_orig,
                                                   ser_nf           LIKE adiant.ser_nf,
                                                   ssr_nf           LIKE adiant.ssr_nf,
                                                   cod_fornecedor   LIKE adiant.cod_fornecedor,
                                                   dat_mov          LIKE mov_adiant.dat_mov,       #--# Apenas na exclusão #--#
                                                   hor_mov          LIKE mov_adiant.hor_mov,       #--# Apenas na exclusão #--#
                                                   num_item         LIKE dev_fornec.num_item,      #--# Opcional - Carta ao fornecedor #--#
                                                   num_aviso_rec    LIKE dev_fornec.num_aviso_rec, #--# Opcional - Carta ao fornecedor #--#
                                                   num_seq          LIKE dev_fornec.num_seq        #--# Opcional - Carta ao fornecedor #--#
                                                END RECORD

  DEFINE ma_impostos_integr       ARRAY[100] OF RECORD
                                                   cod_tip_val            DECIMAL(3,0),
                                                   val_base_calc          DECIMAL(15,2),
                                                   valor                  DECIMAL(15,2)
                                                END RECORD

  DEFINE ma_ad_aen_integr         ARRAY[200] OF RECORD
                                                   val_item               LIKE ad_aen.val_item,
                                                   cod_area_negocio       LIKE ad_aen.cod_area_negocio,
                                                   cod_lin_negocio        LIKE ad_aen.cod_lin_negocio
                                                END RECORD

  DEFINE ma_ad_aen_4_integr       ARRAY[200] OF RECORD
                                                   val_aen                LIKE ad_aen_4.val_aen,
                                                   cod_lin_prod           LIKE ad_aen_4.cod_lin_prod,
                                                   cod_lin_recei          LIKE ad_aen_4.cod_lin_recei,
                                                   cod_seg_merc           LIKE ad_aen_4.cod_seg_merc,
                                                   cod_cla_uso            LIKE ad_aen_4.cod_cla_uso
                                                END RECORD

  DEFINE ma_ad_aen_conta_integr   ARRAY[200] OF RECORD
                                                   num_seq_lanc           LIKE ad_aen_conta.num_seq_lanc,
                                                   ies_tipo_lanc          LIKE ad_aen_conta.ies_tipo_lanc,
                                                   num_conta_cont         LIKE ad_aen_conta.num_conta_cont,
                                                   ies_fornec_trans       LIKE ad_aen_conta.ies_fornec_trans,
                                                   cod_area_negocio       LIKE ad_aen_conta.cod_area_negocio,
                                                   cod_lin_negocio        LIKE ad_aen_conta.cod_lin_negocio,
                                                   val_item               LIKE ad_aen_conta.val_item
                                                END RECORD

  DEFINE ma_ad_aen_conta_4_integr ARRAY[200] OF RECORD
                                                   num_seq_lanc           LIKE ad_aen_conta_4.num_seq_lanc,
                                                   ies_tipo_lanc          LIKE ad_aen_conta_4.ies_tipo_lanc,
                                                   num_conta_cont         LIKE ad_aen_conta_4.num_conta_cont,
                                                   ies_fornec_trans       LIKE ad_aen_conta_4.ies_fornec_trans,
                                                   cod_lin_prod           LIKE ad_aen_conta_4.cod_lin_prod,
                                                   cod_lin_recei          LIKE ad_aen_conta_4.cod_lin_recei,
                                                   cod_seg_merc           LIKE ad_aen_conta_4.cod_seg_merc,
                                                   cod_cla_uso            LIKE ad_aen_conta_4.cod_cla_uso,
                                                   val_aen                LIKE ad_aen_conta_4.val_aen
                                                END RECORD

  DEFINE mr_dados_integr RECORD
                            sistema_gerador    CHAR(01),
                            cod_empresa        LIKE ad_mestre.cod_empresa,
                            cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
                            num_nf             LIKE ad_mestre.num_nf,
                            ser_nf             LIKE ad_mestre.ser_nf,
                            ssr_nf             LIKE ad_mestre.ssr_nf,
                            ies_especie_nf     CHAR(03),
                            dat_venc           LIKE ad_mestre.dat_venc,
                            cnd_pgto           LIKE ad_mestre.cnd_pgto,
                            cod_fornecedor     LIKE ad_mestre.cod_fornecedor,
                            val_tot_nf         LIKE ad_mestre.val_tot_nf,
                            ies_dep_cred       LIKE ad_mestre.ies_dep_cred,
                            dat_rec_nf         LIKE ad_mestre.dat_rec_nf
                         END RECORD

  DEFINE mr_dados_adic   RECORD
                            programa_orig        CHAR(10),
                            ind_modif_ad         CHAR(01),
                            ind_valid_dados      CHAR(01),
                            num_ad_exist         LIKE ad_mestre.num_ad,
                            ind_inform_trib      CHAR(01),
                            ind_inform_lanc      CHAR(01),
                            ind_inform_aprov     CHAR(01),
                            ind_inform_unid_func CHAR(01),
                            ind_inform_aen       CHAR(01),
                            ind_inform_ct_perm   CHAR(01),
                            cod_banco            LIKE agencia_bco.cod_banco,
                            num_agencia          LIKE agencia_bco.num_agencia,
                            num_conta_banc       LIKE agencia_bc_item.num_conta_banc,
                            cod_portador         LIKE agencia_bco.cod_banco,
                            cod_lote_pgto        LIKE ap.cod_lote_pgto,
                            cod_empresa_estab    LIKE ad_mestre.cod_empresa_estab,
                            mes_ano_compet       LIKE ad_mestre.mes_ano_compet,
                            num_ord_forn         LIKE ad_mestre.num_ord_forn,
                            cod_moeda            LIKE ad_mestre.cod_moeda,
                            set_aplicacao        LIKE ad_mestre.set_aplicacao,
                            cod_tip_ad           LIKE ad_mestre.cod_tip_ad,
                            dat_emis_nf          LIKE ad_mestre.dat_emis_nf,
                            ies_ap_autom         LIKE ad_mestre.ies_ap_autom,
                            ies_ap_proposta      CHAR(01),
                            ies_bx_automatica    CHAR(01),
                            cod_emp_cntr_perm    LIKE empresa.cod_empresa,
                            cod_contrato_perm    LIKE cre_contr_permuta.contrato,
                            observacao           CHAR(5000),
                            observacao_ap        CHAR(5000),
                            ies_ajus_cnd_pgto    CHAR(01),
                            num_proc_export      CHAR(12)
                         END RECORD

  DEFINE m_cod_empresa_dest    LIKE empresa.cod_empresa

  DEFINE mr_ad_mestre          RECORD LIKE ad_mestre.*,
         mr_tipo_despesa       RECORD LIKE tipo_despesa.*,
         m_num_ap              LIKE ap.num_ap

  DEFINE mr_parametros         RECORD
                                  ies_online_fcl               CHAR(01),
                                  controla_gao                 CHAR(01),
                                  orcamento_periodo            CHAR(01),
                                  gao_forma_controle           CHAR(01),
                                  usa_cond_pagto               CHAR(01),
                                  ies_gao_contabilizacao       CHAR(01),
                                  ies_area_linha_neg           CHAR(01),
                                  ies_aen_2_4                  CHAR(01),
                                  estorna_lanc_incluso_contab  CHAR(01),
                                  par_utiliza_irrf_adiant      CHAR(01),
                                  tip_desp_carta_frete         LIKE par_cap_pad.par_num,
                                  ies_cons_pg_trib             LIKE par_cap_pad.par_ies,
                                  cnsl_pagto_matriz            LIKE par_cap_pad.par_ies,
                                  limite_inferior_inclusao_ads SMALLINT,
                                  limite_superior_inclusao_ads SMALLINT,
                                  ies_incl_dat_retro           CHAR(01),
                                  ctr_data_incl_ad             CHAR(01),
                                  qtd_dia_ent_vencto           SMALLINT,
                                  ies_aprov_eletro             CHAR(01),
                                  busca_cctbl_cta_fornec       CHAR(01),
                                  qtd_dias_incl_venc           LIKE par_cap_pad.par_num,
                                  nom_bas_dad_aces_tab_exp     CHAR(70)
                               END RECORD

  DEFINE m_index_lanc      INTEGER,
         m_index_imp       INTEGER,
         m_index_tip_val   INTEGER,
         m_index_aen       INTEGER,
         m_index_aen_4     INTEGER,
         m_index_aen_cta   INTEGER,
         m_index_aen_cta_4 INTEGER,
         m_alterou         SMALLINT

  DEFINE m_ind_alt_tipo_desp CHAR(01)

  DEFINE ma_ad_aen_conta_integr_val   ARRAY[200] OF RECORD
                                                       num_seq_lanc           LIKE ad_aen_conta.num_seq_lanc,
                                                       ies_tipo_lanc          LIKE ad_aen_conta.ies_tipo_lanc,
                                                       num_conta_cont         LIKE ad_aen_conta.num_conta_cont,
                                                       ies_fornec_trans       LIKE ad_aen_conta.ies_fornec_trans,
                                                       cod_area_negocio       LIKE ad_aen_conta.cod_area_negocio,
                                                       cod_lin_negocio        LIKE ad_aen_conta.cod_lin_negocio,
                                                       val_item               LIKE ad_aen_conta.val_item
                                                    END RECORD

  DEFINE ma_ad_aen_conta_4_integr_val ARRAY[200] OF RECORD
                                                       num_seq_lanc           LIKE ad_aen_conta_4.num_seq_lanc,
                                                       ies_tipo_lanc          LIKE ad_aen_conta_4.ies_tipo_lanc,
                                                       num_conta_cont         LIKE ad_aen_conta_4.num_conta_cont,
                                                       ies_fornec_trans       LIKE ad_aen_conta_4.ies_fornec_trans,
                                                       cod_lin_prod           LIKE ad_aen_conta_4.cod_lin_prod,
                                                       cod_lin_recei          LIKE ad_aen_conta_4.cod_lin_recei,
                                                       cod_seg_merc           LIKE ad_aen_conta_4.cod_seg_merc,
                                                       cod_cla_uso            LIKE ad_aen_conta_4.cod_cla_uso,
                                                       val_aen                LIKE ad_aen_conta_4.val_aen
                                                    END RECORD


  #--# Cálculo do GAO #--#
  DEFINE ma_val_por_aen     ARRAY[500] OF RECORD
                                             perc_val             DECIMAL(12,9),
                                             cod_lin_prod         LIKE ad_aen_4.cod_lin_prod,
                                             cod_lin_recei        LIKE ad_aen_4.cod_lin_recei,
                                             cod_seg_merc         LIKE ad_aen_4.cod_seg_merc,
                                             cod_cla_uso          LIKE ad_aen_4.cod_cla_uso
                                          END RECORD

  DEFINE ma_val_por_aen_esp ARRAY[500] OF RECORD
                                             val_aen              LIKE ad_aen_conta_4.val_aen,
                                             cod_lin_prod         LIKE ad_aen_conta_4.cod_lin_prod,
                                             cod_lin_recei        LIKE ad_aen_conta_4.cod_lin_recei,
                                             cod_seg_merc         LIKE ad_aen_conta_4.cod_seg_merc,
                                             cod_cla_uso          LIKE ad_aen_conta_4.cod_cla_uso
                                          END RECORD

#--# END MODULARES #--#

#-------------------------------#
 FUNCTION fin80030_version_info()
#-------------------------------#

  RETURN "$Archive: /logix11R0/financeiro/financeiro/funcoes/fin80030.4gl $|$Revision: 15 $|$Date: 25/03/11 10:47 $|$Modtime: 14/03/11 17:27 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_gera_informacoes_cap(l_sistema_gerador,
                                        l_cod_empresa,
                                        l_cod_tip_despesa,
                                        l_num_nf,
                                        l_ser_nf,
                                        l_ssr_nf,
                                        l_ies_especie_nf,
                                        l_dat_venc,
                                        l_cnd_pgto,
                                        l_cod_fornecedor,
                                        l_val_tot_nf,
                                        l_ies_dep_cred,
                                        l_dat_rec_nf)
#--------------------------------------------------------#

  DEFINE  l_sistema_gerador    CHAR(01),
          l_cod_empresa        LIKE ad_mestre.cod_empresa,
          l_cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
          l_num_nf             LIKE ad_mestre.num_nf,
          l_ser_nf             LIKE ad_mestre.ser_nf,
          l_ssr_nf             LIKE ad_mestre.ssr_nf,
          l_ies_especie_nf     CHAR(03),
          l_dat_venc           LIKE ad_mestre.dat_venc,
          l_cnd_pgto           LIKE ad_mestre.cnd_pgto,
          l_cod_fornecedor     LIKE ad_mestre.cod_fornecedor,
          l_val_tot_nf         LIKE ad_mestre.val_tot_nf,
          l_ies_dep_cred       LIKE ad_mestre.ies_dep_cred,
          l_dat_rec_nf         LIKE ad_mestre.dat_rec_nf

  CALL fin80030_inicializa()

  LET mr_dados_integr.sistema_gerador    = l_sistema_gerador
  LET mr_dados_integr.cod_empresa        = l_cod_empresa
  LET mr_dados_integr.cod_tip_despesa    = l_cod_tip_despesa
  LET mr_dados_integr.num_nf             = l_num_nf
  LET mr_dados_integr.ser_nf             = l_ser_nf
  LET mr_dados_integr.ssr_nf             = l_ssr_nf
  LET mr_dados_integr.ies_especie_nf     = l_ies_especie_nf
  LET mr_dados_integr.dat_venc           = l_dat_venc
  LET mr_dados_integr.cnd_pgto           = l_cnd_pgto
  LET mr_dados_integr.cod_fornecedor     = l_cod_fornecedor
  LET mr_dados_integr.val_tot_nf         = l_val_tot_nf
  LET mr_dados_integr.ies_dep_cred       = l_ies_dep_cred
  LET mr_dados_integr.dat_rec_nf         = l_dat_rec_nf


  #--# Efetua a integração #--#
  CALL fin80030_integracao_dados()
     RETURNING m_status, m_msg

  CALL fin80030_inicializa_dados()

  IF NOT m_status THEN
     RETURN FALSE, m_msg, 0, 0
  ELSE
     RETURN TRUE,  m_msg, mr_ad_mestre.num_ad, m_num_ap
  END IF

END FUNCTION

#------------------------------------------------------#
 FUNCTION fin80030_valida_dados_cap(l_sistema_gerador,
                                    l_cod_empresa,
                                    l_cod_tip_despesa,
                                    l_num_nf,
                                    l_ser_nf,
                                    l_ssr_nf,
                                    l_ies_especie_nf,
                                    l_dat_venc,
                                    l_cnd_pgto,
                                    l_cod_fornecedor,
                                    l_val_tot_nf,
                                    l_ies_dep_cred,
                                    l_dat_rec_nf)
#------------------------------------------------------#

  DEFINE  l_sistema_gerador    CHAR(01),
          l_cod_empresa        LIKE ad_mestre.cod_empresa,
          l_cod_tip_despesa    LIKE tipo_despesa.cod_tip_despesa,
          l_num_nf             LIKE ad_mestre.num_nf,
          l_ser_nf             LIKE ad_mestre.ser_nf,
          l_ssr_nf             LIKE ad_mestre.ssr_nf,
          l_ies_especie_nf     CHAR(03),
          l_dat_venc           LIKE ad_mestre.dat_venc,
          l_cnd_pgto           LIKE ad_mestre.cnd_pgto,
          l_cod_fornecedor     LIKE ad_mestre.cod_fornecedor,
          l_val_tot_nf         LIKE ad_mestre.val_tot_nf,
          l_ies_dep_cred       LIKE ad_mestre.ies_dep_cred,
          l_dat_rec_nf         LIKE ad_mestre.dat_rec_nf

  CALL fin80030_inicializa()

  LET mr_dados_integr.sistema_gerador    = l_sistema_gerador
  LET mr_dados_integr.cod_empresa        = l_cod_empresa
  LET mr_dados_integr.cod_tip_despesa    = l_cod_tip_despesa
  LET mr_dados_integr.num_nf             = l_num_nf
  LET mr_dados_integr.ser_nf             = l_ser_nf
  LET mr_dados_integr.ssr_nf             = l_ssr_nf
  LET mr_dados_integr.ies_especie_nf     = l_ies_especie_nf
  LET mr_dados_integr.dat_venc           = l_dat_venc
  LET mr_dados_integr.cnd_pgto           = l_cnd_pgto
  LET mr_dados_integr.cod_fornecedor     = l_cod_fornecedor
  LET mr_dados_integr.val_tot_nf         = l_val_tot_nf
  LET mr_dados_integr.ies_dep_cred       = l_ies_dep_cred
  LET mr_dados_integr.dat_rec_nf         = l_dat_rec_nf

  #--# Consiste os parâmetros de integração #--#
  CALL fin80030_consiste_integridade_variaveis()
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  IF NOT m_status THEN
     RETURN FALSE, m_msg
  ELSE
     RETURN TRUE,  m_msg
  END IF

END FUNCTION

#-----------------------------------#
 FUNCTION fin80030_integracao_dados()
#-----------------------------------#

  #--# Consiste os parâmetros de integração #--#
  CALL fin80030_consiste_integridade_variaveis()
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Inclui o registro de AD #--#
  CALL fin80030_inclui_ad()
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Gera lançamentos #--#
  IF mr_tipo_despesa.ies_contab <> "N" AND mr_tipo_despesa.ies_previsao = "N" THEN
     CALL fin80030_gera_lanc_pelo_tipo_despesa()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Carregar e atualizar ajustes financeiros para efetivação no caso de modificação #--#
  IF mr_tipo_despesa.ies_previsao <> "P" THEN
     IF mr_dados_adic.ind_modif_ad = 'S' THEN
        CALL fin80030_carrega_atualiza_ad_valores_existentes()
           RETURNING m_status, m_msg
        IF NOT m_status THEN

           RETURN FALSE, m_msg
        END IF
     ELSE
        #--# Inclui adiantamentos para os novos ajustes #--#
        CALL fin80030_baixa_adiantamentos_ad_valores()
           RETURNING m_status, m_msg
        IF NOT m_status THEN

           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  #--# Efetua a integração dos impostos #--#
  IF mr_tipo_despesa.ies_previsao <> "P" THEN
     IF mr_dados_adic.ind_modif_ad = 'N' OR mr_dados_adic.ind_inform_trib <> 'I' THEN #--# Ignora #--#
        CALL fin80030_integra_impostos()
           RETURNING m_status, m_msg
        IF NOT m_status THEN

           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  #--# Verifica se foi informado tipos de valor no array #--#
  IF mr_tipo_despesa.ies_previsao <> "P" THEN
     IF ma_tipo_valor_integr[1].cod_tip_val IS NOT NULL THEN
        #--# Grava ajustes #--#
        CALL fin80030_inclui_ad_valores()
           RETURNING m_status, m_msg
        IF NOT m_status THEN

           RETURN FALSE, m_msg
        END IF

        #--# Gera lançamentos dos ajustes financeiros #--#
        CALL fin80030_gera_lanc_cont_ad_valores()
           RETURNING m_status, m_msg
        IF NOT m_status THEN

           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  #--# Inclui adiantamento conforme tipo de despesa #--#
  IF mr_tipo_despesa.ies_adiant = "F" OR mr_tipo_despesa.ies_adiant = "D" AND mr_tipo_despesa.ies_previsao = "N" THEN
     CALL fin80030_inclui_adiant()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Verifica consistências de relacionamento de tipo de valor com adiantamentos #--#
  CALL fin80030_verifica_ad_valores_adiant()
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Abre a interface de lançamentos #--#
  IF mr_dados_adic.ind_inform_lanc = 'S' AND mr_tipo_despesa.ies_previsao = "N" AND mr_tipo_despesa.ies_contab = "M" THEN
     CALL fin80030_manutencao_lancamentos()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Grava os lançamentos que estão no array #--#
  IF mr_tipo_despesa.ies_previsao = "N" AND mr_tipo_despesa.ies_contab <> "N" THEN
     CALL fin80030_contabiliza_lanc_array()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Carrega AEN existente para a modificação #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN
     CALL fin80030_gera_carga_aen_existente()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Gera AEN da contabilização do tipo de valor #--#
  IF mr_tipo_despesa.ies_previsao = "N" THEN
     CALL fin80030_gera_aen_contabilz_ad_valores()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Verifica se fornecedor gera AP #--#
  IF mr_ad_mestre.ies_ap_autom = 'S' THEN

     #--# Atualiza saldo da AD na criação #--#
     CALL fin80030_atualiza_saldo_ad()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF

     #--# Inclusão de AP #--#
     CALL fin80030_inclui_ap()
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Inclusão de AEN #--#
  CALL fin80030_inclui_aen()
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Atualiza informações da AD (valores) #--#
  CALL fin80030_atualiza_ad()
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Integração Fluxo de Caixa #--#
  IF mr_parametros.ies_online_fcl = "S" THEN
     CALL fcl1160_integracao_cap_fcx(mr_ad_mestre.cod_empresa,"AD", mr_ad_mestre.num_ad,"EX")
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF

     CALL fcl1160_integracao_cap_fcx(mr_ad_mestre.cod_empresa,"AD", mr_ad_mestre.num_ad,"IN")
        RETURNING m_status, m_msg
     IF NOT m_status THEN

        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Aprovação eletrônica #--#
  CALL fin80059_aprov_eletronica(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_dados_adic.ind_inform_aprov, mr_dados_adic.ind_inform_unid_func, 'N')
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Verifica lançamentos, liberando ou não, conforme aprovação eletrônica #--#
  CALL fin80030_ajusta_lib_lanc_conf_aprov_eletron(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad)
     RETURNING m_status, m_msg
  IF NOT m_status THEN

     RETURN FALSE, m_msg
  END IF

  #--# Atualiza indicadores de aprovação eletrônica #--#
  CALL fin80030_verifica_aprovacao_eletron(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  RETURN TRUE, " Compromisso incluído no CAP com sucesso!"

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_busca_parametros(l_cod_empresa)
#------------------------------------------------#

  DEFINE l_cod_empresa    LIKE empresa.cod_empresa

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_online_fcl", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_online_fcl = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_online_fcl = "N"
  END IF

  #--# Busca parâmetro de controle do GAO #--#
  WHENEVER ERROR CONTINUE
    SELECT par_ind_especial
      INTO mr_parametros.controla_gao
      FROM gao_par_padrao
     WHERE empresa    = l_cod_empresa
       AND parametro = "controla_gao"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR mr_parametros.controla_gao IS NULL OR mr_parametros.controla_gao =  ' ' THEN
     LET mr_parametros.controla_gao = 'N'
  END IF

  #--# Busca parâmetro de controle de orçamento por período GAO #--#
  CALL log2250_busca_parametro(l_cod_empresa,"gao_forma_controle")
     RETURNING mr_parametros.gao_forma_controle, m_status
  IF NOT m_status OR m_gao_forma_controle IS NULL THEN
     LET mr_parametros.gao_forma_controle = 5
  END IF

  IF mr_parametros.gao_forma_controle = 9 THEN
     LET mr_parametros.orcamento_periodo = 'S'
  ELSE
     LET mr_parametros.orcamento_periodo = 'N'
  END IF

  #--# Verifica se utiliza o GAO com condição de pagamento #--#
  WHENEVER ERROR CONTINUE
    SELECT par_ind_especial
      INTO mr_parametros.usa_cond_pagto
      FROM gao_par_padrao
     WHERE empresa   = l_cod_empresa
       AND parametro = "usa_cond_pagto_cap"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR mr_parametros.usa_cond_pagto IS NULL OR mr_parametros.usa_cond_pagto = ' ' THEN
     LET mr_parametros.usa_cond_pagto = "N"
  END IF

  #--# Verifica a contabilização do GAO #--#
  CALL log2250_busca_parametro(l_cod_empresa,"ies_gao_contabilizacao")
       RETURNING mr_parametros.ies_gao_contabilizacao, m_status
  IF NOT m_status OR mr_parametros.ies_gao_contabilizacao IS NULL THEN
     LET mr_parametros.ies_gao_contabilizacao = 'N'
  END IF

  #--# Busca parâmetros de utilização de AEN #--#
  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_area_linha_neg", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_area_linha_neg = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_area_linha_neg = 'N'
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_aen_2_4", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_aen_2_4 = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_aen_2_4 = '2'
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "tip_desp_carta_frete", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.tip_desp_carta_frete = capm8_par_cap_pad_get_par_num()
  ELSE
     LET mr_parametros.tip_desp_carta_frete = NULL
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "qtd_dias_incl_venc", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.qtd_dias_incl_venc = capm8_par_cap_pad_get_par_num()
  ELSE
     LET mr_parametros.qtd_dias_incl_venc = NULL
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'estorna_lanc_incluso_contab')
     RETURNING mr_parametros.estorna_lanc_incluso_contab, m_status
  IF mr_parametros.estorna_lanc_incluso_contab IS NULL OR m_status = FALSE THEN
     LET mr_parametros.estorna_lanc_incluso_contab = 'N'
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'par_utiliza_irrf_adiant')
     RETURNING mr_parametros.par_utiliza_irrf_adiant, m_status
  IF mr_parametros.par_utiliza_irrf_adiant IS NULL OR m_status = FALSE THEN
     LET mr_parametros.par_utiliza_irrf_adiant = 'N'
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_cons_pg_trib", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_cons_pg_trib = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_cons_pg_trib = "N"
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "cnsl_pagto_matriz", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.cnsl_pagto_matriz = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.cnsl_pagto_matriz = "N"
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'limite_inferior_inclusao_ads')
       RETURNING mr_parametros.limite_inferior_inclusao_ads, m_status
  IF mr_parametros.limite_inferior_inclusao_ads IS NULL OR m_status = FALSE THEN
     LET mr_parametros.limite_inferior_inclusao_ads = FALSE
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'limite_superior_inclusao_ads')
       RETURNING mr_parametros.limite_superior_inclusao_ads, m_status
  IF mr_parametros.limite_superior_inclusao_ads IS NULL OR m_status = FALSE THEN
     LET mr_parametros.limite_superior_inclusao_ads = FALSE
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_incl_dat_retro", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_incl_dat_retro = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_incl_dat_retro = "N"
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'ctr_data_incl_ad')
       RETURNING mr_parametros.ctr_data_incl_ad, m_status
  IF mr_parametros.ctr_data_incl_ad IS NULL OR m_status = FALSE THEN
     LET mr_parametros.ctr_data_incl_ad = "N"
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'qtd_dia_ent_vencto')
       RETURNING mr_parametros.qtd_dia_ent_vencto, m_status
  IF mr_parametros.qtd_dia_ent_vencto IS NULL OR m_status = FALSE THEN
     LET mr_parametros.qtd_dia_ent_vencto = 0
  END IF

  CALL log2250_busca_parametro(l_cod_empresa,'busca_cctbl_cta_fornec')
       RETURNING mr_parametros.busca_cctbl_cta_fornec, m_status
  IF mr_parametros.busca_cctbl_cta_fornec IS NULL OR m_status = FALSE THEN
     LET mr_parametros.busca_cctbl_cta_fornec = 'N'
  END IF

  CALL capm8_par_cap_pad_leitura(l_cod_empresa, "ies_aprov_eletro", FALSE, TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     LET mr_parametros.ies_aprov_eletro = capm8_par_cap_pad_get_par_ies()
  ELSE
     LET mr_parametros.ies_aprov_eletro = "N"
  END IF

END FUNCTION

#-------------------------------------------------#
 FUNCTION fin80030_consiste_integridade_variaveis()
#-------------------------------------------------#
  DEFINE lr_ad_mestre RECORD LIKE ad_mestre.*
  DEFINE l_dias_venc INTEGER

  IF mr_dados_adic.ind_valid_dados IS NULL THEN
     LET mr_dados_adic.ind_valid_dados = 'S'
  END IF

  #--# Valida empresa origem #--#
  CALL fin80030_carrega_valida_empresa(mr_dados_integr.cod_empresa)
     RETURNING m_status, m_msg, m_den
  IF NOT m_status THEN
     RETURN FALSE, 'Empresa origem não cadastrada!'
  END IF

  #--# Busca empresa origem e destino #--#
  CALL capm123_emp_orig_destino_leitura(mr_dados_integr.cod_empresa,TRUE,TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     LET m_cod_empresa_dest = mr_dados_integr.cod_empresa
  ELSE
     LET m_cod_empresa_dest = capm123_emp_orig_destino_get_cod_empresa_destin()
  END IF

  #--# Busca os parâmetros para integração #--#
  CALL fin80030_busca_parametros(m_cod_empresa_dest)

  #--# Valida empresa destino #--#
  CALL fin80030_carrega_valida_empresa(m_cod_empresa_dest)
     RETURNING m_status, m_msg, m_den
  IF NOT m_status THEN
     RETURN FALSE, 'Empresa não cadastrada!'
  END IF

  #--# Valida valores negativos e zerados #--#
  IF mr_dados_integr.val_tot_nf <= 0 OR mr_dados_integr.val_tot_nf IS NULL THEN
     RETURN FALSE, 'O valor total da AD deve ser maior que 0 (zero)!'
  END IF

  #--# Valida variável de controle de modificação de ADs #--#
  IF mr_dados_adic.ind_modif_ad IS NULL THEN
     LET mr_dados_adic.ind_modif_ad = 'N'
     INITIALIZE mr_dados_adic.num_ad_exist TO NULL
  ELSE
     IF mr_dados_adic.ind_modif_ad = 'S' THEN

        #--# Verifica se ad_mestre existe #--#
        CALL capm1_ad_mestre_leitura(m_cod_empresa_dest,
                                     mr_dados_adic.num_ad_exist,
                                     TRUE,
                                     TRUE)
           RETURNING m_status
        IF NOT m_status THEN
           RETURN FALSE, 'AD não encontrada!'
        END IF
        CALL capm1_ad_mestre_get_all()
           RETURNING lr_ad_mestre.*

        IF mr_dados_integr.num_nf IS NULL THEN
           LET m_alterou = FALSE
        ELSE
           IF lr_ad_mestre.cod_fornecedor <> mr_dados_integr.cod_fornecedor
           OR lr_ad_mestre.num_nf         <> mr_dados_integr.num_nf
           OR lr_ad_mestre.ser_nf         <> mr_dados_integr.ser_nf
           OR lr_ad_mestre.ssr_nf         <> mr_dados_integr.ssr_nf THEN
              LET m_alterou = TRUE
           ELSE
              LET m_alterou = FALSE
           END IF
        END IF


        #--# Verifica se pode modificar a AD #--#
        CALL fin80030_verifica_pode_modificar(m_cod_empresa_dest,
                                              mr_dados_adic.num_ad_exist)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF

        #--# Carrega dados da AD #--#
        CALL fin80030_carrega_dados_ad()

        #--# Verifica se houve mudança do tipo de despesa #--#
        IF capm1_ad_mestre_get_cod_tip_despesa() <> mr_dados_integr.cod_tip_despesa THEN
           LET m_ind_alt_tipo_desp = TRUE
        ELSE
           LET m_ind_alt_tipo_desp = FALSE
        END IF
     END IF
  END IF

  #--# Carrega série padrão #--#
  IF mr_dados_integr.ser_nf IS NULL THEN
     LET mr_dados_integr.ser_nf = 'X'
  END IF

  #--# Valida moeda #--#
  IF mr_dados_adic.cod_moeda IS NOT NULL THEN
     CALL fin80030_carrega_valida_moeda(mr_dados_adic.cod_moeda)
        RETURNING m_status, m_msg, m_den
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  ELSE
     LET mr_dados_adic.cod_moeda = fin80028_busca_moeda_padrao(m_cod_empresa_dest)
  END IF

  #--# Valida setor de aplicação #--#
  CALL fin80030_carrega_valida_setor_aplicacao(m_cod_empresa_dest, mr_dados_adic.set_aplicacao)
     RETURNING m_status, m_msg, m_den
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Verifica data de vencimento / condição de pagamento #--#
  IF mr_dados_integr.dat_venc IS NOT NULL AND mr_dados_integr.cnd_pgto IS NOT NULL THEN
     LET m_msg  = " Data do vencimento e condição de pagamento da AD não podem ser informadas ao mesmo tempo! "
     RETURN FALSE, m_msg
  END IF

  #--# Valida condição de pagamento #--#
  IF mr_dados_integr.cnd_pgto IS NOT NULL THEN
     CALL fin80030_carrega_valida_condicao_pgto(mr_dados_integr.cnd_pgto)
        RETURNING m_status, m_msg, m_den
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  ELSE
     #--# Valida indicador de ajuste de condição de pagamento x condição de pagamento #--#
     IF mr_dados_adic.ies_ajus_cnd_pgto = 'S' THEN
        LET m_msg  = " O indicador de ajuste de condição de pagamento está ativado porem não foi informado condição de pagamento!"
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Verifica variável de geração de AP #--#
  IF mr_dados_adic.ies_ap_autom IS NULL THEN
     LET mr_dados_adic.ies_ap_autom = 'S'
  END IF

  #--# Verifica variável de geração de AP #--#
  IF mr_dados_adic.ies_ap_autom = 'S' THEN

     IF mr_dados_adic.ind_valid_dados = 'S' THEN
        IF NOT fin80028_verifica_gera_ap_fornecedor(mr_dados_integr.cod_fornecedor) THEN
           LET m_msg  = " O indicador de geração de AP automático está ativo porém fornecedor não está parametrizado para gerar AP!"
           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  #--# Verifica variável de geração de proposta para AP #--#
  IF mr_dados_adic.ies_ap_proposta IS NULL THEN
     LET mr_dados_adic.ies_ap_proposta = 'N'
  END IF

  #--# Verifica condição de pagamento já paga #--#
  IF mr_dados_integr.cnd_pgto IS NOT NULL THEN
     IF capm90_cond_pgto_cap_get_ies_pagamento() = "1" THEN
        IF mr_dados_adic.ies_ap_autom = 'S' THEN
           RETURN FALSE, 'Quando for condição de pagamento já paga, não deverá gerar AP!'
        END IF
     END IF
  END IF

  #--# Validar apenas inclusões #--#
  IF mr_dados_adic.ind_modif_ad = 'N' THEN
     IF mr_dados_adic.ies_ap_autom = 'N' AND mr_dados_adic.observacao_ap IS NOT NULL THEN
        RETURN FALSE, 'É necessário gerar AP automática para incluir observação na AP!'
     END IF
  END IF

  #--# Verifica variável de baixa automatica #--#
  IF mr_dados_adic.ies_bx_automatica IS NULL THEN
     LET mr_dados_adic.ies_bx_automatica = 'N'
  END IF

  IF mr_dados_integr.cod_tip_despesa IS NOT NULL THEN

     #--# Busca tipo de despesa #--#
     CALL capm111_tipo_despesa_leitura(m_cod_empresa_dest,mr_dados_integr.cod_tip_despesa,TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        LET m_msg = "Tipo de despesa ",mr_dados_integr.cod_tip_despesa CLIPPED," não cadastrado para a empresa ",m_cod_empresa_dest CLIPPED," !"
        RETURN FALSE, m_msg
     ELSE

        #--# Verifica tipo de AD está informado #--#
        IF capm115_tipo_despesa_compl_leitura(m_cod_empresa_dest, mr_dados_integr.cod_tip_despesa,TRUE,FALSE) THEN
           IF capm115_tipo_despesa_compl_get_cod_tip_ad() IS NULL THEN
              LET m_msg = "Código do tipo de AD não cadastrado para o tipo de despesa ", mr_dados_integr.cod_tip_despesa
              RETURN FALSE, m_msg
           ELSE
              LET mr_dados_adic.cod_tip_ad = capm115_tipo_despesa_compl_get_cod_tip_ad()
           END IF
        ELSE
           LET m_msg = "Tipo de despesa complementar não encontrado! ", mr_dados_integr.cod_tip_despesa
           RETURN FALSE, m_msg
        END IF

        #--# Verifica se tipo de despesa está ativo #--#
        IF capm115_tipo_despesa_compl_get_ies_ativo() <> 'S' THEN
           LET m_msg = "Tipo de despesa não está ativo! ", mr_dados_integr.cod_tip_despesa
           RETURN FALSE, m_msg
        END IF

        #--# Verifica tipo de despesa caso baixa automática está setada #--#
        IF mr_dados_adic.ies_bx_automatica = 'S' AND capm111_tipo_despesa_get_ies_adiant() <> 'F' THEN
           LET m_msg = "Foi selecionado o indicador de baixa automática de adiantamento, porém o tipo de despesa da AD não é de adiantamento"
           RETURN FALSE, m_msg
        END IF

        #--# Verifica tipo de despesa caso numero do pedido seja informado #--#
        IF mr_dados_adic.num_ord_forn IS NOT NULL AND capm111_tipo_despesa_get_ies_adiant() <> 'F' THEN
           LET m_msg = "Foi informado número de pedido, porém o tipo de despesa da AD não é de adiantamento"
           RETURN FALSE, m_msg
        END IF

        #--# Verifica tipo de despesa exclusivo para suprimentos #--#
        CALL fin80030_valida_tipo_despesa_excl_sup(m_cod_empresa_dest, mr_dados_integr.cod_tip_despesa)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF

        #--# Verifica inclusões em outra moeda #--#
        IF capm111_tipo_despesa_get_ies_outra_moeda() = "N" THEN
           IF (mr_dados_adic.cod_moeda <> fin80028_busca_moeda_padrao(m_cod_empresa_dest)) THEN
              RETURN FALSE, "Moeda difere da padrão, o tipo de despesa não permite inclusões em moeda diferente!"
           END IF
        END IF

        #--# Verifica tipo de despesa quando moeda difere do padrão #--#
        IF capm111_tipo_despesa_get_ies_contab() = "N" THEN
            IF capm111_tipo_despesa_get_ies_previsao() <> "P" THEN

              #--# Moeda difere do padrão #--#
              IF (mr_dados_adic.cod_moeda <> fin80028_busca_moeda_padrao(m_cod_empresa_dest)) THEN
                 RETURN FALSE, "Moeda difere da padrão, o tipo de despesa deve ser de contabilização!"
              END IF
           END IF
        END IF

        #--# Tipo de despesa de adiantamento #--#
        IF (capm111_tipo_despesa_get_ies_adiant() = "F") OR
           (capm111_tipo_despesa_get_ies_adiant() = "D") THEN

           #--# Moeda difere do padrão #--#
           IF (mr_dados_adic.cod_moeda <> fin80028_busca_moeda_padrao(m_cod_empresa_dest)) THEN

              RETURN FALSE, "AD de adiantamento não pode ser gerada em outra moeda!"
           END IF
        END IF

        #--# Garrega todos os campos do tipo de despesa #--#
        CALL capm111_tipo_despesa_get_all()
           RETURNING mr_tipo_despesa.*

        #--# Verifica permissão do usuário quanto ao tipo de despesa #--#
        IF NOT fin80018_verifica_permissao_usuario_x_tipo_despesa(m_cod_empresa_dest,mr_tipo_despesa.cod_tip_despesa,"3",FALSE) THEN
           LET m_msg  = "Usuário ",p_user," não tem permissão para o tipo de despesa ",mr_tipo_despesa.cod_tip_despesa,". Verificar cadastro no FIN30136."
           RETURN FALSE, m_msg
        END IF

        ##--# Valida tipo de despesa quanto a transferência de caixa #--#
        #IF mr_tipo_despesa.ies_transf_num = "C" THEN
        #   LET m_msg  = "Tipo de desp. ",mr_dados_integr.cod_tip_despesa," não pode ser de transferência p/ caixa. "
        #   RETURN FALSE, m_msg
        #END IF

        #--# Carrega indicador dep_cred automático quando nulo #--#
        IF mr_dados_integr.ies_dep_cred IS NULL THEN

           IF supm2_fornecedor_get_cod_banco() IS NULL THEN

              LET mr_dados_integr.ies_dep_cred = "N"
           ELSE
              LET mr_dados_integr.ies_dep_cred = "S"
           END IF
        END IF

        #--# Caso foi informado depósito deve ser passado as informações de banco/agência/conta do fornecedor #--#
        IF mr_dados_integr.ies_dep_cred = "N" THEN

           LET mr_dados_adic.cod_banco       = NULL
           LET mr_dados_adic.num_agencia     = NULL
           LET mr_dados_adic.num_conta_banc  = NULL
        ELSE
           IF mr_dados_integr.ies_dep_cred = "S" THEN

              #--# Carrega informações do fornecedor #--#
              IF mr_dados_adic.cod_banco IS NULL THEN
                 LET mr_dados_adic.cod_banco = supm2_fornecedor_get_cod_banco()
              END IF

              IF mr_dados_adic.num_agencia IS NULL THEN
                 LET mr_dados_adic.num_agencia = supm2_fornecedor_get_num_agencia()
              END IF

              IF mr_dados_adic.num_conta_banc IS NULL THEN
                 LET mr_dados_adic.num_conta_banc = supm2_fornecedor_get_num_conta_banco()
              END IF

              IF mr_dados_adic.cod_portador IS NULL THEN
                 LET mr_dados_adic.cod_portador = fin80042_localiza_portador(m_cod_empresa_dest,
                                                                             mr_dados_integr.cod_tip_despesa,
                                                                             mr_dados_integr.ies_dep_cred,
                                                                             mr_dados_adic.cod_lote_pgto)
              END IF
           ELSE
              LET m_msg  = " Indicador de depósito/crédito nao pode ser diferente de 'S' ou 'N'. "
              RETURN FALSE, m_msg
           END IF
        END IF

        #--# Valida tipo de transferencia e depósito em conta #--#
        IF mr_tipo_despesa.ies_transf_num = "B" THEN
           IF mr_dados_integr.ies_dep_cred = "N" THEN
              LET m_msg  = "Para o tipo de despesa de transferência, a AD deve ser de depósito em conta"
              RETURN FALSE, m_msg
           END IF
        END IF
     END IF

     #--# Adiantamento #--#
     IF mr_tipo_despesa.ies_adiant = "F" OR mr_tipo_despesa.ies_adiant = "D" THEN
        LET mr_dados_integr.dat_venc  = mr_dados_integr.dat_rec_nf
        LET mr_dados_adic.dat_emis_nf = mr_dados_integr.dat_rec_nf
     END IF
  ELSE
     RETURN FALSE, "Tipo de despesa não informado, AD/AP no CAP não podem ser geradas."
  END IF

  #--# Verifica condição de pagamento parcelada x tipo de despesa com contabilização na baixa #--#
  IF mr_dados_integr.cnd_pgto IS NOT NULL THEN
     IF fin80030_condicao_pagamento_parcelada(mr_dados_integr.cnd_pgto) AND mr_tipo_despesa.ies_quando_contab = "B" THEN
        RETURN FALSE,'Tipo de despesa com contabilização na baixa não poderá ser utilizado com condição de pagamento parcelada!'
     END IF
  END IF

  #--# Valida grade de aprovação - APR #--#
  IF mr_parametros.ies_aprov_eletro <> 'N' AND mr_tipo_despesa.ies_previsao <> 'S' THEN

     CALL fin80059_verifica_grade_aprov(m_cod_empresa_dest,
                                        mr_dados_integr.cod_tip_despesa,
                                        mr_dados_integr.dat_rec_nf,
                                        mr_dados_adic.cod_moeda,
                                        mr_dados_integr.val_tot_nf)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Valida portador #--#
  CALL fin80030_carrega_valida_portador(mr_dados_adic.cod_portador)
     RETURNING m_status, m_msg, m_den
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Valida tipo de ad #--#
  IF mr_dados_adic.cod_tip_ad IS NOT NULL THEN
     CALL fin80030_carrega_valida_tipo_ad(mr_dados_adic.cod_tip_ad)
        RETURNING m_status, m_msg, m_den
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Valida empresa estabelecimento #--#
  IF mr_dados_adic.cod_empresa_estab IS NOT NULL THEN
     CALL fin80030_carrega_valida_empresa(mr_dados_adic.cod_empresa_estab)
        RETURNING m_status, m_msg, m_den
     IF NOT m_status THEN
        RETURN FALSE, 'Empresa estabelecimento não cadastrada!'
     END IF
  ELSE
     IF capm111_tipo_despesa_get_ies_cod_estab() = 'S' THEN
        RETURN FALSE, 'Tipo de despesa exige a informação de empresa estabelecimento!'
     END IF
  END IF

  #--# Valida se foi informado o período de competencia caso necessário #--#
  IF capm111_tipo_despesa_get_ies_cod_estab() = 'S' THEN
     IF mr_dados_adic.mes_ano_compet IS NULL THEN
        RETURN FALSE, 'Tipo de despesa exige a informação de período de competência!'
     ELSE
        IF NOT fin80030_verifica_mes_ano_compet(mr_dados_adic.mes_ano_compet) THEN
           RETURN FALSE, 'Período de competência inválido!'
        END IF
     END IF
  END IF

  #--# Verifica data de vencimento / condição de pagamento #--#
  IF mr_dados_integr.dat_venc IS NULL AND mr_dados_integr.cnd_pgto IS NULL THEN
     LET m_msg  = " Data do vencimento e condição de pagamento da AD não pode estar nulo ao mesmo tempo! "
     RETURN FALSE, m_msg
  END IF

  #--# Valida número da nota fiscal nulo #--#
  IF (mr_dados_integr.num_nf IS NULL OR mr_dados_integr.num_nf = '*')
    AND mr_dados_integr.sistema_gerador <> 'C'
    AND mr_dados_integr.sistema_gerador <> 'M'
    AND mr_dados_integr.sistema_gerador <> 'J' THEN

     LET m_msg  = " Número da nota fiscal nâo pode estar nulo. "
     RETURN FALSE, m_msg
  END IF

  #--# Valida espécie da nota fiscal #--#
  IF mr_dados_integr.ies_especie_nf IS NULL THEN
     LET mr_dados_integr.ies_especie_nf = 'NF'
  END IF

  #--# Valida código do fornecedor #--#
  IF mr_dados_integr.cod_fornecedor IS NOT NULL THEN
     IF NOT supm2_fornecedor_leitura(mr_dados_integr.cod_fornecedor,TRUE,TRUE) THEN
        RETURN FALSE, "Fornecedor não cadastrado!"
     ELSE
        IF supm2_fornecedor_get_ies_fornec_ativo() = 'I' THEN
           RETURN FALSE, "Fornecedor não pode ser utilizado pois está inativo!"
        END IF
     END IF
  ELSE
     RETURN FALSE, "Fornecedor da AD não pode ser nulo!"
  END IF

  #--# Valida número do pedido em caso de adiantamento #--#
  IF mr_dados_adic.num_ord_forn IS NOT NULL THEN
     CALL fin80030_carrega_valida_num_ord_forn(m_cod_empresa_dest, mr_dados_integr.cod_fornecedor, mr_dados_adic.num_ord_forn)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF

     #--# Valida valor da AD contra valor do Pedido #--#
     CALL fin80030_valida_valor_ad_contra_valor_pedido(mr_dados_integr.cod_empresa, mr_dados_adic.num_ord_forn, mr_dados_integr.val_tot_nf)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Valida tipo de pessoa do fornecedor x tipo de despesa #--#
  CALL fin80030_valida_tipo_despesa_contra_tipo_fornec(m_cod_empresa_dest, mr_dados_integr.cod_tip_despesa, mr_dados_integr.cod_fornecedor)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Valida baixas de adiantamentos e adiantamentos na modificação do fornecedor #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN
     CALL fin80030_valida_adiantamentos_existentes(m_cod_empresa_dest, mr_dados_adic.num_ad_exist, mr_dados_integr.cod_fornecedor)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Verifica se existem adiantamentos baixados #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN
     IF NOT fin80030_verifica_adiantamento_baixados(m_cod_empresa_dest, mr_dados_adic.num_ad_exist, mr_dados_integr.ser_nf, mr_dados_integr.ssr_nf) THEN

        IF (capm1_ad_mestre_get_val_tot_nf()      <> mr_dados_integr.val_tot_nf)      OR
           (capm1_ad_mestre_get_cod_tip_despesa() <> mr_dados_integr.cod_tip_despesa) THEN
           RETURN FALSE, 'O adiantamento gerado por esta AD já foi baixado, não permitindo modificação do tipo de despesa e valor!'
        END IF
     END IF
  END IF

  #--# Carrega data de emissão caso não informada #--#
  IF mr_dados_adic.dat_emis_nf IS NULL THEN
     LET mr_dados_adic.dat_emis_nf = mr_dados_integr.dat_rec_nf
  END IF

  #--# Verifica datas limites de inclusão de ADs #--#
  CALL fin80030_verifica_limite_inclusao_datas(m_cod_empresa_dest, mr_dados_adic.dat_emis_nf, 'EMI')
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     LET m_msg = m_msg CLIPPED, ' (Data de emissão) '
     RETURN FALSE, m_msg
  END IF

  #--# Verifica datas limites de inclusão de ADs #--#
  CALL fin80030_verifica_limite_inclusao_datas(m_cod_empresa_dest, mr_dados_integr.dat_rec_nf, 'REC')
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     LET m_msg = m_msg CLIPPED, ' (Data de recebimento) '
     RETURN FALSE, m_msg
  END IF

  #--# Valida data de vencimento #--#
  IF mr_dados_integr.dat_venc IS NOT NULL THEN

     #--# Quantidade de dias - quando adiantamento somar datas adicionais #--#
     IF mr_tipo_despesa.ies_adiant <> "N" THEN

        IF mr_parametros.qtd_dia_ent_vencto > 0 THEN
           LET mr_dados_integr.dat_venc = mr_dados_integr.dat_venc + mr_parametros.qtd_dia_ent_vencto UNITS DAY
        END IF
     END IF

     IF mr_dados_integr.dat_venc < mr_dados_adic.dat_emis_nf THEN
        RETURN FALSE, ' Data de vencimento deve ser maior ou igual a data de emissão!'
     END IF
  END IF

  #--# Valida data de vencimento - quantidade de dias entre a entrada e o vencimento #--#
  IF mr_parametros.qtd_dias_incl_venc > 0 AND mr_dados_integr.dat_venc IS NOT NULL THEN

     LET l_dias_venc = mr_dados_integr.dat_venc - TODAY

     IF l_dias_venc < mr_parametros.qtd_dias_incl_venc AND mr_dados_adic.ind_valid_dados = "S" THEN
        RETURN FALSE, 'Quantidade de dias entre data entrada/vencimento menor que o parametrizado!'
     END IF
  END IF

  #--# Valida valor da AD #--#
  IF mr_dados_integr.val_tot_nf IS NULL THEN
     RETURN FALSE,' Valor da despesa não pode ser nula!'
  ELSE
     IF mr_dados_integr.val_tot_nf < 0 THEN
        RETURN FALSE,' Valor da despesa não pode ser negativo!'
     ELSE
        IF mr_dados_integr.val_tot_nf = 0 THEN
           RETURN FALSE,' Valor da despesa não pode ser igual a Zero!'
        END IF
     END IF
  END IF

  #--# Verifica se o documento já existe no contas a pagar com série e subsérie nulas #--#
  IF mr_dados_adic.ind_modif_ad = 'N' THEN
     IF mr_dados_integr.ser_nf IS NULL AND mr_dados_integr.ssr_nf IS NULL THEN
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM ad_mestre
           WHERE cod_empresa    = m_cod_empresa_dest
             AND cod_fornecedor = mr_dados_integr.cod_fornecedor
             AND num_nf         = mr_dados_integr.num_nf
             AND ser_nf         IS NULL
             AND ssr_nf         IS NULL
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,' já existe no Contas a Pagar. '
           RETURN FALSE, m_msg
        END IF
     ELSE
        #--# Verifica se o documento já existe no contas a pagar #--#
        IF mr_dados_integr.ser_nf IS NOT NULL AND mr_dados_integr.ssr_nf IS NOT NULL THEN
           WHENEVER ERROR CONTINUE
             SELECT 1
               FROM ad_mestre
              WHERE cod_empresa    = m_cod_empresa_dest
                AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                AND num_nf         = mr_dados_integr.num_nf
                AND ser_nf         = mr_dados_integr.ser_nf
                AND ssr_nf         = mr_dados_integr.ssr_nf
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-',mr_dados_integr.ser_nf CLIPPED,'/',mr_dados_integr.ssr_nf CLIPPED,' já existe no Contas a Pagar. '
              RETURN FALSE, m_msg
           END IF
        ELSE
           #--# Verifica se o documento já existe no contas a pagar com subsérie nula #--#
           IF mr_dados_integr.ssr_nf IS NULL THEN
              WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM ad_mestre
                 WHERE cod_empresa    = m_cod_empresa_dest
                   AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                   AND num_nf         = mr_dados_integr.num_nf
                   AND ser_nf         = mr_dados_integr.ser_nf
                   AND ssr_nf         IS NULL
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
                 LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-',mr_dados_integr.ser_nf CLIPPED,'/XX já existe no Contas a Pagar. '
                 RETURN FALSE, m_msg
              END IF
           END IF

           #--# Verifica se o documento já existe no contas a pagar com série nula #--#
           IF mr_dados_integr.ser_nf IS NULL THEN
              WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM ad_mestre
                 WHERE cod_empresa    = m_cod_empresa_dest
                   AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                   AND num_nf         = mr_dados_integr.num_nf
                   AND ser_nf         IS NULL
                   AND ssr_nf         = mr_dados_integr.ssr_nf
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
                 LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-X/',mr_dados_integr.ser_nf CLIPPED,' já existe no Contas a Pagar. '
                 RETURN FALSE, m_msg
              END IF
           END IF
        END IF
     END IF
  ELSE
     IF mr_dados_integr.ser_nf IS NULL AND mr_dados_integr.ssr_nf IS NULL THEN
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM ad_mestre
           WHERE cod_empresa    = m_cod_empresa_dest
             AND cod_fornecedor = mr_dados_integr.cod_fornecedor
             AND num_nf         = mr_dados_integr.num_nf
             AND ser_nf         IS NULL
             AND ssr_nf         IS NULL
             AND num_ad        <> mr_dados_adic.num_ad_exist
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,' já existe no Contas a Pagar. '
           RETURN FALSE, m_msg
        END IF
     ELSE
        #--# Verifica se o documento já existe no contas a pagar #--#
        IF mr_dados_integr.ser_nf IS NOT NULL AND mr_dados_integr.ssr_nf IS NOT NULL THEN
           WHENEVER ERROR CONTINUE
             SELECT 1
               FROM ad_mestre
              WHERE cod_empresa    = m_cod_empresa_dest
                AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                AND num_nf         = mr_dados_integr.num_nf
                AND ser_nf         = mr_dados_integr.ser_nf
                AND ssr_nf         = mr_dados_integr.ssr_nf
                AND num_ad        <> mr_dados_adic.num_ad_exist
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-',mr_dados_integr.ser_nf CLIPPED,'/',mr_dados_integr.ssr_nf CLIPPED,' já existe no Contas a Pagar. '
              RETURN FALSE, m_msg
           END IF
        ELSE
           #--# Verifica se o documento já existe no contas a pagar com subsérie nula #--#
           IF mr_dados_integr.ssr_nf IS NULL THEN
              WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM ad_mestre
                 WHERE cod_empresa    = m_cod_empresa_dest
                   AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                   AND num_nf         = mr_dados_integr.num_nf
                   AND ser_nf         = mr_dados_integr.ser_nf
                   AND ssr_nf         IS NULL
                   AND num_ad        <> mr_dados_adic.num_ad_exist
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
                 LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-',mr_dados_integr.ser_nf CLIPPED,'/XX já existe no Contas a Pagar. '
                 RETURN FALSE, m_msg
              END IF
           END IF

           #--# Verifica se o documento já existe no contas a pagar com série nula #--#
           IF mr_dados_integr.ser_nf IS NULL THEN
              WHENEVER ERROR CONTINUE
                SELECT 1
                  FROM ad_mestre
                 WHERE cod_empresa    = m_cod_empresa_dest
                   AND cod_fornecedor = mr_dados_integr.cod_fornecedor
                   AND num_nf         = mr_dados_integr.num_nf
                   AND ser_nf         IS NULL
                   AND ssr_nf         = mr_dados_integr.ssr_nf
                   AND num_ad        <> mr_dados_adic.num_ad_exist
              WHENEVER ERROR STOP
              IF sqlca.sqlcode = 0 THEN
                 LET m_msg  = ' Número de documento: ',mr_dados_integr.num_nf CLIPPED,'-X/',mr_dados_integr.ser_nf CLIPPED,' já existe no Contas a Pagar. '
                 RETURN FALSE, m_msg
              END IF
           END IF
        END IF
     END IF
  END IF

  #--# Verifica se a AD já não existe em histórico #--#
  IF mr_dados_integr.num_nf IS NOT NULL AND mr_dados_integr.num_nf <> '*' THEN
     IF fin80030_existe_ad_historico(m_cod_empresa_dest,
                                     mr_dados_integr.num_nf,
                                     mr_dados_integr.cod_fornecedor,
                                     mr_dados_integr.ser_nf,
                                     mr_dados_integr.ssr_nf) THEN
        RETURN FALSE, "AD já inclusa em histórico! "
     END IF
  END IF

  #--# Verifica lote de pagamento #--#
  IF mr_dados_adic.cod_lote_pgto IS NULL THEN

     LET mr_dados_adic.cod_lote_pgto = fin80028_localiza_lote(m_cod_empresa_dest, mr_dados_integr.cod_tip_despesa, mr_dados_integr.ies_dep_cred, mr_dados_adic.cod_portador)

     IF mr_dados_adic.cod_lote_pgto IS NULL THEN
        LET mr_dados_adic.cod_lote_pgto = fin80028_localiza_lote_fornecedor(mr_dados_adic.cod_lote_pgto,mr_dados_integr.cod_fornecedor)
     END IF
     IF mr_dados_integr.ies_dep_cred = "S" THEN
        IF mr_dados_adic.cod_lote_pgto IS NULL THEN

           #--# Codigo do Lote de Banco Especifico #--#
           LET mr_dados_adic.cod_lote_pgto  = fin80028_busca_lote_pgto(m_cod_empresa_dest, "ESPECIF")
           IF mr_dados_adic.cod_lote_pgto IS NULL THEN
              RETURN FALSE, ' Lote de pagamento não informado! '
           END IF
        END IF
     ELSE
        IF mr_dados_adic.cod_lote_pgto IS NULL THEN

           #--# Codigo do Lote de Compensacao #--#
           LET mr_dados_adic.cod_lote_pgto  = fin80028_busca_lote_pgto(m_cod_empresa_dest, "COMPENS")
           IF mr_dados_adic.cod_lote_pgto IS NULL THEN
              RETURN FALSE, ' Lote de pagamento não informado! '
           END IF
        END IF
     END IF
  END IF

  #--# Valida lote de pagamento #--#
  CALL fin80030_carrega_valida_lote_pgto(mr_dados_adic.cod_lote_pgto)
     RETURNING m_status, m_msg, m_den
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Valida portador para lote de pagamento escritural #--#
  IF capm88_lote_pagamento_get_ies_escritural() = 'S' THEN
     IF mr_dados_adic.cod_portador IS NULL THEN
        RETURN FALSE, 'Obrigatório informar o código do portador pois o lote de pgto é do tipo escritural!'
     END IF
  END IF

  #--# Verifica variável de abertura de interface de lançamentos #--#
  IF mr_dados_adic.ind_inform_lanc IS NULL THEN
     LET mr_dados_adic.ind_inform_lanc = 'N'
  END IF

  #--# Verifica variável de abertura de interface de aprovação eletrônica #--#
  IF mr_dados_adic.ind_inform_aprov IS NULL THEN
     LET mr_dados_adic.ind_inform_aprov = 'N'
  END IF

  #--# Verifica variável de abertura de interface de escolhe de unidade funcional aprovação eletrônica #--#
  IF mr_dados_adic.ind_inform_unid_func IS NULL THEN
     LET mr_dados_adic.ind_inform_unid_func = 'N'
  END IF

  #--# Verifica variável de abertura de interface de AEN #--#
  IF mr_dados_adic.ind_inform_aen IS NULL THEN
     LET mr_dados_adic.ind_inform_aen = 'N'
  END IF

  #--# Verifica variável de abertura de interface de Contrato de permuta #--#
  IF mr_dados_adic.ind_inform_ct_perm IS NULL THEN
     LET mr_dados_adic.ind_inform_ct_perm = 'N'
  END IF

  #--# Verifica variável de abertura de interface de impostos #--#
  IF mr_dados_adic.ind_inform_trib IS NULL THEN
     LET mr_dados_adic.ind_inform_trib = 'N'
  END IF

  #--# Valida num processo exortação na tabela 'lk_processos_dad' Sistema comex #--#
  CALL fin80030_valida_proc_exportacao(m_cod_empresa_dest, mr_dados_adic.num_proc_export)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  RETURN TRUE, ' '

END FUNCTION

#----------------------------#
 FUNCTION fin80030_inclui_ad()
#----------------------------#

  DEFINE l_val_cotacao    LIKE ad_corr.val_cotacao,
         l_val_moeda_padr LIKE ad_corr.val_moeda_padr,
         l_nom_tabela     CHAR(16)

  LET mr_ad_mestre.cod_empresa       = m_cod_empresa_dest

  IF mr_dados_adic.num_ad_exist IS NULL THEN
     LET mr_ad_mestre.num_ad         = fin80013_busca_proximo_num_ad(m_cod_empresa_dest)
  ELSE
     LET mr_ad_mestre.num_ad         = mr_dados_adic.num_ad_exist
  END IF

  LET mr_ad_mestre.cod_tip_despesa   = mr_dados_integr.cod_tip_despesa
  LET mr_ad_mestre.ser_nf            = mr_dados_integr.ser_nf
  LET mr_ad_mestre.ssr_nf            = mr_dados_integr.ssr_nf

  #--# Caso não exista nota na entrada do documento pelo CAP assumir o número da AD #--#
  IF (mr_dados_integr.num_nf IS NULL OR mr_dados_integr.num_nf = "*")
     AND (mr_dados_integr.sistema_gerador = 'C' OR
          mr_dados_integr.sistema_gerador = 'M' OR
          mr_dados_integr.sistema_gerador = 'J') THEN
     LET mr_ad_mestre.num_nf         = mr_ad_mestre.num_ad
  ELSE
     LET mr_ad_mestre.num_nf         = mr_dados_integr.num_nf
  END IF

  LET mr_ad_mestre.dat_emis_nf       = mr_dados_adic.dat_emis_nf
  LET mr_ad_mestre.dat_rec_nf        = mr_dados_integr.dat_rec_nf
  LET mr_ad_mestre.cod_empresa_estab = mr_dados_adic.cod_empresa_estab
  LET mr_ad_mestre.mes_ano_compet    = mr_dados_adic.mes_ano_compet
  LET mr_ad_mestre.num_ord_forn      = mr_dados_adic.num_ord_forn
  LET mr_ad_mestre.cnd_pgto          = mr_dados_integr.cnd_pgto
  LET mr_ad_mestre.dat_venc          = mr_dados_integr.dat_venc
  LET mr_ad_mestre.cod_fornecedor    = mr_dados_integr.cod_fornecedor
  LET mr_ad_mestre.val_tot_nf        = mr_dados_integr.val_tot_nf
  LET mr_ad_mestre.cod_moeda         = mr_dados_adic.cod_moeda
  LET mr_ad_mestre.cod_tip_ad        = mr_dados_adic.cod_tip_ad

  #--# Verifica se existe o parâmetro de moeda padrão cadastrado #--#
  IF mr_ad_mestre.cod_moeda IS NULL THEN
     RETURN FALSE, 'Moeda padrão não cadastrada para a empresa!'
  END IF

  #--# Verifica se será gerado AP automática #--#
  IF fin80028_verifica_gera_ap_fornecedor(mr_ad_mestre.cod_fornecedor) AND mr_dados_adic.ies_ap_autom = 'S' THEN
     LET mr_ad_mestre.ies_ap_autom      = "S"
     LET mr_ad_mestre.val_saldo_ad      = 0
  ELSE
     LET mr_ad_mestre.ies_ap_autom      = "N"
     LET mr_ad_mestre.val_saldo_ad      = fin80014_calc_val_liquido_ad(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_ad_mestre.val_tot_nf)
  END IF

  LET mr_ad_mestre.ies_sup_cap       = mr_dados_integr.sistema_gerador
  LET mr_ad_mestre.ies_fatura        = "N"
  LET mr_ad_mestre.ies_ad_cont       = "N"
  LET mr_ad_mestre.num_lote_transf   = 0
  LET mr_ad_mestre.ies_dep_cred      = mr_dados_integr.ies_dep_cred
  LET mr_ad_mestre.num_lote_pat      = 0
  LET mr_ad_mestre.cod_empresa_orig  = mr_dados_integr.cod_empresa
  LET mr_ad_mestre.set_aplicacao     = mr_dados_adic.set_aplicacao
  LET mr_ad_mestre.cod_portador      = mr_dados_adic.cod_portador
  LET mr_ad_mestre.cod_lote_pgto     = mr_dados_adic.cod_lote_pgto

  IF mr_dados_adic.observacao IS NOT NULL THEN
     LET mr_ad_mestre.observ = mr_dados_adic.observacao[1,40]
  END IF

  #--# Seta valores para inclusão da AD #--#
  CALL capm1_ad_mestre_set_all(mr_ad_mestre.*)

  #--# Inclui AD #--#
  IF mr_dados_adic.ind_modif_ad = 'N' THEN
     CALL capt1_ad_mestre_inclui(TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  ELSE
  #--# Modifica AD #--#
     CALL capt1_ad_mestre_modifica(TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Elimina registro de observação antes de incluir novamente #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_obs_ad
        WHERE empresa          = mr_ad_mestre.cod_empresa
          AND apropriacao_desp = mr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na modificação da observação da AD!'
     END IF
  END IF

  #--# Inclui observacao AD #--#
  IF mr_dados_adic.observacao IS NOT NULL THEN
     IF NOT fin80028_inclui_ad_obser(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_dados_adic.observacao) THEN
        RETURN FALSE, 'Problema na inclusão da observação da AD!'
     END IF
  END IF

  #--# Atualiza fornecedor #--#
  CALL _ADVPL_RunBackground('fin80030_atualiza_fornecedor',mr_ad_mestre.cod_empresa,p_user,TRUE,mr_ad_mestre.cod_fornecedor)

  #--# Inclui espécie da AD #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM cap_par_compl
     WHERE empresa    = mr_ad_mestre.cod_empresa
       AND parametro  = 'ies_especie_nf_ad'
       AND nom_tabela = mr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação das informações de espécie da AD!'
  END IF

  CALL capm11_cap_par_compl_set_nom_tabela(mr_ad_mestre.num_ad)
  CALL capm11_cap_par_compl_set_empresa(mr_ad_mestre.cod_empresa)
  CALL capm11_cap_par_compl_set_parametro("ies_especie_nf_ad")
  CALL capm11_cap_par_compl_set_des_parametro("Espécie da nota referente a AD")
  CALL capm11_cap_par_compl_set_parametro_texto(mr_dados_integr.ies_especie_nf)

  CALL capm11_cap_par_compl_inclui(FALSE,TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Inclui número processo exportação #--#
  LET l_nom_tabela = 'ad_mestre_' CLIPPED, mr_ad_mestre.num_ad  USING '&&&&&&'
  WHENEVER ERROR CONTINUE
    DELETE FROM cap_par_compl
     WHERE empresa    = mr_ad_mestre.cod_empresa
       AND parametro  = 'nr_proc_exportacao'
       AND nom_tabela = l_nom_tabela
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação das informações do processo de exportação!'
  END IF

  CALL capm11_cap_par_compl_set_nom_tabela(l_nom_tabela)
  CALL capm11_cap_par_compl_set_empresa(mr_ad_mestre.cod_empresa)
  CALL capm11_cap_par_compl_set_parametro("nr_proc_exportacao")
  CALL capm11_cap_par_compl_set_des_parametro("Número do processo de exportação")
  CALL capm11_cap_par_compl_set_parametro_texto(mr_dados_adic.num_proc_export)

  CALL capm11_cap_par_compl_inclui(FALSE,TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Inclui registro de correção #--#
  IF (mr_ad_mestre.cod_moeda <> fin80028_busca_moeda_padrao(m_cod_empresa_dest)) AND (mr_tipo_despesa.ies_quando_contab = "C") THEN

     WHENEVER ERROR CONTINUE
       DELETE FROM ad_corr
        WHERE cod_empresa  = mr_ad_mestre.cod_empresa
          AND num_ad       = mr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de correção!'
     END IF

     LET l_val_cotacao      =  fin80030_cotacao(mr_ad_mestre.cod_moeda, mr_ad_mestre.dat_rec_nf)
     LET l_val_moeda_padr   =  mr_ad_mestre.val_tot_nf * l_val_cotacao

     WHENEVER ERROR CONTINUE
       INSERT INTO ad_corr (cod_empresa,
                            num_ad,
                            dat_contab,
                            val_cotacao,
                            val_moeda_padr)
                    VALUES (mr_ad_mestre.cod_empresa,
                            mr_ad_mestre.num_ad,
                            mr_ad_mestre.dat_rec_nf,
                            l_val_cotacao,
                            l_val_moeda_padr)
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na inclusão do registro de correção!'
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------------------------#
 FUNCTION fin80030_atualiza_fornecedor(l_cod_fornecedor)
#------------------------------------------------------#

  DEFINE l_cod_fornecedor LIKE fornecedor.cod_fornecedor

  CALL LOG_connectDatabase('DEFAULT')

  CALL log085_transacao("BEGIN")

  #--# Atualiza fornecedor #--#
  WHENEVER ERROR CONTINUE
    UPDATE fornecedor
       SET dat_movto_ult = TODAY
   WHERE fornecedor.cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP

  CALL log085_transacao("COMMIT")

END FUNCTION

#------------------------------------#
 FUNCTION fin80030_atualiza_saldo_ad()
#------------------------------------#

  DEFINE l_val_liquido_ad LIKE ad_mestre.val_tot_nf

  LET l_val_liquido_ad = fin80014_calc_val_liquido_ad(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_ad_mestre.val_tot_nf)

  #--# Atualiza o saldo da AD #--#
  WHENEVER ERROR CONTINUE
    UPDATE ad_mestre
       SET val_saldo_ad = l_val_liquido_ad
     WHERE cod_empresa  = mr_ad_mestre.cod_empresa
       AND num_ad       = mr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do saldo da AD'
  END IF

  RETURN TRUE, ' '

END FUNCTION

#------------------------------#
 FUNCTION fin80030_atualiza_ad()
#------------------------------#

  DEFINE l_val_liquido_ad LIKE ad_mestre.val_tot_nf

  DEFINE lr_lanc_cont_cap RECORD LIKE lanc_cont_cap.*

  LET l_val_liquido_ad = fin80014_calc_val_liquido_ad(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_ad_mestre.val_tot_nf)

  #--# Atualiza o saldo da AD #--#
  IF mr_ad_mestre.ies_ap_autom = "N" THEN
     CALL fin80030_atualiza_saldo_ad()
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Integra ctb_lanc_ctbl dos registros de lançamentos da AD (Necessário existir AEN e lançamentos pra integrar) #--#
  WHENEVER ERROR CONTINUE
   DECLARE cq_atz_ctb_lanc CURSOR FOR
    SELECT *
      FROM lanc_cont_cap
     WHERE cod_empresa = mr_ad_mestre.cod_empresa
       AND num_ad_ap   = mr_ad_mestre.num_ad
       AND ies_ad_ap   = '1'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na busca dos lançamentos contábeis!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_atz_ctb_lanc INTO lr_lanc_cont_cap.*
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na busca dos lançamentos contábeis!'
      END IF

      #--# Integra ctb_lanc_ctbl_cap #--#
      CALL fin80024_manutencao_ctb_lanc_ctbl_cap("I", lr_lanc_cont_cap.cod_empresa, lr_lanc_cont_cap.num_ad_ap, lr_lanc_cont_cap.ies_ad_ap, lr_lanc_cont_cap.num_seq)
         RETURNING m_manut_tabela, m_processa
      IF NOT m_processa THEN
         RETURN FALSE, 'Problema na integração da contabilização on-line'
      END IF

      WHENEVER ERROR CONTINUE
   END FOREACH
   FREE cq_atz_ctb_lanc
  WHENEVER ERROR STOP

  #--# Gera a depósito CAP #--#
  IF l_val_liquido_ad = 0 OR mr_tipo_despesa.ies_transf_num = "C" THEN

     CALL fin80030_inclui_deposito_cap(mr_ad_mestre.cod_empresa,
                                       mr_ad_mestre.num_ad,
                                       mr_ad_mestre.cod_tip_despesa,
                                       mr_ad_mestre.val_tot_nf,
                                       mr_ad_mestre.dat_rec_nf)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Inicializa GAO #--#
  CALL gao10001_inicializa_gao()

  IF mr_dados_adic.ind_modif_ad = 'S' THEN
     #--# Integra GAO #--#
     CALL fin80030_exclui_gao(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad)
        RETURNING m_status
     IF NOT m_status THEN
        RETURN FALSE, 'Problema na exclusão da integração do GAO!'
     END IF
  END IF

  #--# Integra GAO #--#
  CALL fin80030_inclui_gao()
     RETURNING m_status
  IF NOT m_status THEN
     RETURN FALSE, 'Problema na integração do documento com o GAO!'
  END IF



############################################################################

  #--# Verifica se tipo de AD é de permuta #--#
  IF mr_ad_mestre.cod_tip_ad IS NOT NULL THEN

     IF mr_dados_adic.cod_emp_cntr_perm IS NULL AND
        mr_dados_adic.cod_contrato_perm IS NULL AND
        mr_dados_adic.ind_inform_ct_perm = 'S' THEN

        IF fin80030_tipo_ad_permuta('I', mr_ad_mestre.cod_empresa,  mr_ad_mestre.num_ad, mr_ad_mestre.cod_tip_ad) THEN

           CALL fin80037_recupera_contrato_permuta(mr_ad_mestre.cod_empresa,
                                                   mr_ad_mestre.num_ad,
                                                   'S')
              RETURNING m_status, mr_dados_adic.cod_emp_cntr_perm, mr_dados_adic.cod_contrato_perm
           IF NOT m_status THEN
              RETURN FALSE, 'Contrato de permuta não encontrado!'
           END IF
        END IF
     END IF
  END IF

  #--# Inclui contrato de permuta #--#
  IF mr_dados_adic.cod_emp_cntr_perm IS NOT NULL AND
     mr_dados_adic.cod_contrato_perm IS NOT NULL THEN

     #--# Valida se AP de permuta possui AP #--#
     IF mr_ad_mestre.ies_ap_autom = 'N' THEN
        RETURN FALSE, 'AD de contrato de permuta sem AP!'
     END IF

     CALL fin80037_insere_movimentacao_permuta(mr_ad_mestre.cod_empresa,
                                               mr_ad_mestre.num_ad,
                                               mr_dados_adic.cod_emp_cntr_perm,
                                               mr_dados_adic.cod_contrato_perm,
                                               mr_dados_adic.programa_orig)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF


  RETURN TRUE, ' '

END FUNCTION

#--------------------------------#
 FUNCTION fin80030_inclui_adiant()
#--------------------------------#

  DEFINE lr_adiant      RECORD LIKE adiant.*,
         lr_mov_adiant  RECORD LIKE mov_adiant.*


  DEFINE l_val_liquido_ad LIKE ad_mestre.val_tot_nf

  LET l_val_liquido_ad = fin80014_calc_val_liquido_ad(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_ad_mestre.val_tot_nf)

  #--# Seta valores do adiantamento #--#
  LET lr_adiant.cod_empresa       = mr_ad_mestre.cod_empresa
  LET lr_adiant.cod_fornecedor    = mr_ad_mestre.cod_fornecedor
  LET lr_adiant.num_ad_nf_orig    = mr_ad_mestre.num_ad
  LET lr_adiant.ser_nf            = mr_ad_mestre.ser_nf
  LET lr_adiant.ssr_nf            = mr_ad_mestre.ssr_nf
  LET lr_adiant.dat_ref           = mr_ad_mestre.dat_rec_nf
  LET lr_adiant.val_adiant        = l_val_liquido_ad
  LET lr_adiant.val_saldo_adiant  = l_val_liquido_ad
  LET lr_adiant.tex_observ_adiant = mr_dados_adic.observacao[1,50]
  LET lr_adiant.ies_adiant_transf = "N"
  LET lr_adiant.num_pedido        = mr_dados_adic.num_ord_forn
  LET lr_adiant.ies_bx_automatica = mr_dados_adic.ies_bx_automatica

  IF mr_tipo_despesa.ies_adiant = "F" THEN

     LET lr_adiant.ies_forn_div = "F"
  ELSE
     LET lr_adiant.ies_forn_div = "D"
  END IF

  CALL capm114_adiant_set_all(lr_adiant.*)

  CALL capm114_adiant_existe(lr_adiant.cod_empresa,
                             lr_adiant.cod_fornecedor,
                             lr_adiant.num_ad_nf_orig,
                             lr_adiant.ser_nf,
                             lr_adiant.ssr_nf,
                             TRUE)
     RETURNING m_status, m_msg
  IF m_status THEN
     #--# Modifica o adiantamento #--#
     CALL capt114_adiant_modifica(TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  ELSE
     #--# Inclui o adiantamento #--#
     CALL capt114_adiant_inclui(TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  LET lr_mov_adiant.cod_empresa     = mr_ad_mestre.cod_empresa
  LET lr_mov_adiant.dat_mov         = mr_ad_mestre.dat_rec_nf
  LET lr_mov_adiant.ies_ent_bx      = "E"
  LET lr_mov_adiant.cod_fornecedor  = mr_ad_mestre.cod_fornecedor
  LET lr_mov_adiant.num_ad_nf_orig  = mr_ad_mestre.num_ad
  LET lr_mov_adiant.ser_nf          = mr_ad_mestre.ser_nf
  LET lr_mov_adiant.ssr_nf          = mr_ad_mestre.ssr_nf
  LET lr_mov_adiant.val_mov         = l_val_liquido_ad
  LET lr_mov_adiant.val_saldo_novo  = l_val_liquido_ad
  LET lr_mov_adiant.ies_ad_ap_mov   = "1"
  LET lr_mov_adiant.num_ad_ap_mov   = mr_ad_mestre.num_ad
  LET lr_mov_adiant.cod_tip_val_mov = 0
  LET lr_mov_adiant.hor_mov         = CURRENT HOUR TO SECOND

  #--# Elimina para incluir #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM mov_adiant
     WHERE cod_empresa    = mr_ad_mestre.cod_empresa
       AND num_ad_nf_orig = mr_ad_mestre.num_ad
       AND ies_ad_ap_mov  = '1'
       AND ies_ent_bx     = 'E'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização dos movimentos do adiantamento!'
  END IF

  #--# Seta valores do movimento do adiantamento #--#
  CALL capm113_mov_adiant_set_all(lr_mov_adiant.*)

  #--# Inclui o movimento do adiantamento #--#
  CALL capt113_mov_adiant_inclui(TRUE,TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF


  RETURN TRUE,' '

END FUNCTION

#----------------------------------------------#
 FUNCTION fin80030_gera_lanc_pelo_tipo_despesa()
#----------------------------------------------#

  DEFINE l_ult_lanc  SMALLINT

  DEFINE lr_lanc_cont_cap  RECORD LIKE lanc_cont_cap.*,
         lr_cap_lanc_tdesp RECORD LIKE cap_lanc_tdesp.*

  DEFINE l_existe_lanc SMALLINT

  DEFINE l_num_conta_cred  LIKE lanc_cont_cap.num_conta_cont

  #--# Verifica última numeração de lançamento do array #--#
  IF ma_lanc_cont_cap_integr[1].num_conta_cont IS NOT NULL THEN
     FOR l_ult_lanc = 1 TO 500
        IF ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont IS NULL THEN
           EXIT FOR
        END IF
     END FOR

     #--# Não contabilizar de forma automática quando existir lançamentos de despesa #--#
     IF ma_lanc_cont_cap_integr[1].ies_desp_val = 'D' THEN
        RETURN TRUE, ' '
     END IF
  ELSE
     LET l_ult_lanc = 1
  END IF

  #--# Modificação #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN

     #--# Não houve alteração do tipo de despesa #--#
     IF NOT m_ind_alt_tipo_desp THEN

        LET l_existe_lanc = FALSE

        #--# Carrega lançamentos já existentes #--#
        WHENEVER ERROR CONTINUE
         DECLARE cq_carrega_lanc CURSOR FOR
          SELECT *
            FROM lanc_cont_cap
           WHERE cod_empresa  = mr_ad_mestre.cod_empresa
             AND num_ad_ap    = mr_ad_mestre.num_ad
             AND ies_ad_ap    = '1'
             AND ies_desp_val = 'D'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na carga dos lançamentos contábeis!'
        END IF

        WHENEVER ERROR CONTINUE
         FOREACH cq_carrega_lanc INTO lr_lanc_cont_cap.*
            IF sqlca.sqlcode <> 0 THEN
               RETURN FALSE, 'Problema na carga dos lançamentos contábeis!'
            END IF

            LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc  = lr_lanc_cont_cap.ies_tipo_lanc
            LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont = lr_lanc_cont_cap.num_conta_cont
            LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc       = lr_lanc_cont_cap.val_lanc
            LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val   = "D"
            LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc       = lr_lanc_cont_cap.dat_lanc
            LET ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc  = lr_lanc_cont_cap.tex_hist_lanc

            LET l_ult_lanc = l_ult_lanc + 1

            LET l_existe_lanc = TRUE

            WHENEVER ERROR CONTINUE
         END FOREACH
         FREE cq_carrega_lanc
        WHENEVER ERROR STOP

        #--# Caso não exista lançamento carregar o padrão do tipo de despesa #--#
        IF l_existe_lanc THEN
           RETURN TRUE, ' '
        END IF
     END IF
  END IF

  #--# Busca conta do fornecedor #--#
  IF mr_parametros.busca_cctbl_cta_fornec = 'S' THEN

     WHENEVER ERROR CONTINUE
       SELECT num_conta_fornec
         INTO l_num_conta_cred
         FROM conta_fornec
        WHERE cod_empresa     = mr_ad_mestre.cod_empresa
          AND cod_fornecedor  = mr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_num_conta_cred = mr_tipo_despesa.num_conta_cred
     END IF
  ELSE
     LET l_num_conta_cred = mr_tipo_despesa.num_conta_cred
  END IF

  #--# Grava débito #--#
  LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc  = "D"
  LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont = mr_tipo_despesa.num_conta_deb
  LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc       = mr_ad_mestre.val_tot_nf
  LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val   = "D"
  LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc       = mr_ad_mestre.dat_rec_nf

  CALL fin80036_valida_historico(m_cod_empresa_dest, mr_tipo_despesa.cod_hist_deb, '')
     RETURNING m_status, ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc
  IF NOT m_status OR ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc IS NULL THEN
     LET m_msg  = ' Histórico: ',mr_tipo_despesa.cod_hist_deb,' não cadastrado!'
     RETURN FALSE, m_msg
  END IF
  LET l_ult_lanc = l_ult_lanc + 1

  #--# Grava crédito #--#
  LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc  = "C"
  LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont = l_num_conta_cred
  LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc       = mr_ad_mestre.val_tot_nf
  LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val   = "D"
  LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc       = mr_ad_mestre.dat_rec_nf

  CALL fin80036_valida_historico(m_cod_empresa_dest, mr_tipo_despesa.cod_hist_cred, '')
     RETURNING m_status, ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc
  IF NOT m_status OR ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc IS NULL THEN
     LET m_msg  = ' Histórico: ',mr_tipo_despesa.cod_hist_cred,' não cadastrado!'
     RETURN FALSE, m_msg
  END IF
  LET l_ult_lanc = l_ult_lanc + 1

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------#
 FUNCTION fin80030_inclui_aen()
#-----------------------------#

  DEFINE l_inform_aen  CHAR(01)

  #--# Verifica se foi informado array de AEN ou se deve abrir a tela #--#
  IF ma_ad_aen_integr[1].val_item        IS NULL AND
     ma_ad_aen_4_integr[1].val_aen       IS NULL AND
     ma_ad_aen_conta_integr[1].val_item  IS NULL AND
     ma_ad_aen_conta_4_integr[1].val_aen IS NULL THEN

     LET l_inform_aen = 'S'
  ELSE
     IF mr_dados_adic.ind_inform_aen = 'N' THEN
        LET l_inform_aen = 'N'
     ELSE
        LET l_inform_aen = 'S'
     END IF
  END IF

  #--# Passa AEN via parâmetros #--#
  IF l_inform_aen = 'N' THEN
     #--# Carrega arrays de AEN para inclusão #--#
     CALL fin80030_carrega_aen(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad)
  END IF

  #--# Integra AENs #--#
  CALL fin80001_processa_aen(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, l_inform_aen, 0, 'N')
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  RETURN TRUE, ' '

END FUNCTION

#----------------------------#
 FUNCTION fin80030_inclui_ap()
#----------------------------#

  DEFINE l_num_ad_fatura LIKE ad_mestre.num_ad

  DEFINE l_val_liq_ad    DECIMAL(17,2)

  DEFINE l_ind SMALLINT

  DEFINE lr_ad_aps  RECORD
                        cod_empresa       LIKE ap.cod_empresa,
                        ies_ad_ap         SMALLINT,
                        num_ad_ap         LIKE ad_mestre.num_ad
                    END RECORD

  DEFINE l_qtd_reg INTEGER,
         l_cont    INTEGER

  #--# Valida para não incluir AP com valor zerado #--#
  LET l_val_liq_ad = fin80014_calc_val_liquido_ad(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, mr_ad_mestre.val_tot_nf)

  IF l_val_liq_ad <= 0 THEN
     WHENEVER ERROR CONTINUE
       UPDATE ad_mestre
          SET ies_ap_autom = 'N'
        WHERE cod_empresa  = mr_ad_mestre.cod_empresa
          AND num_ad       = mr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do indicador de geração de AP!'
     END IF
     RETURN TRUE, ' '
  END IF

  #--# Inicializa dados #--#
  CALL fin80039_inicializa_dados()

  CALL fin80039_ads_set_num_ad(mr_ad_mestre.num_ad)
  CALL fin80039_inclui_ad_solic()

  IF mr_dados_adic.observacao_ap IS NULL THEN
     LET mr_dados_adic.observacao_ap = fin80030_busca_observ_ap()
  END IF

  CALL fin80039_adic_set_observacao(mr_dados_adic.observacao_ap)
  CALL fin80039_adic_set_ies_dep_cred(mr_ad_mestre.ies_dep_cred)
  CALL fin80039_adic_set_cod_banco_for(mr_dados_adic.cod_banco)
  CALL fin80039_adic_set_num_agencia_for(mr_dados_adic.num_agencia)
  CALL fin80039_adic_set_num_conta_bco_for(mr_dados_adic.num_conta_banc)
  CALL fin80039_adic_set_cod_portador(mr_dados_adic.cod_portador)
  CALL fin80039_adic_set_cod_lote_pgto(mr_dados_adic.cod_lote_pgto)
  CALL fin80039_adic_set_ies_ajus_cnd_pgto(mr_dados_adic.ies_ajus_cnd_pgto)

  #--# Efetiva inclusão da AP #--#
  CALL fin80039_inclui_ap(mr_ad_mestre.cod_empresa,
                          mr_ad_mestre.cnd_pgto,
                          mr_ad_mestre.dat_venc)
     RETURNING m_status, m_msg, m_num_ap, l_num_ad_fatura
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Inclui na proposta - Modifica AP #--#
  IF mr_dados_adic.ies_ap_proposta = 'S' THEN

     #--# Adiciona na proposta todas as APs relacionadas a AD #--#
     CALL fin80027_retorna_relac_ad_ap(mr_ad_mestre.cod_empresa,'1',mr_ad_mestre.num_ad)
        RETURNING m_status, l_qtd_reg

     FOR l_cont = 1 TO l_qtd_reg

        CALL fin80027_retorna_prox_ad_ap(l_cont)
           RETURNING lr_ad_aps.cod_empresa, lr_ad_aps.ies_ad_ap, lr_ad_aps.num_ad_ap

        IF lr_ad_aps.ies_ad_ap = '2' THEN #--# AP #--#

           #--# Inicializa dados #--#
           CALL fin80039_inicializa_dados()

           #--# Dados adicionais #--#
           CALL fin80039_adic_set_ind_modif_ap('S')
           CALL fin80039_adic_set_num_ap_exist(lr_ad_aps.num_ad_ap)
           CALL fin80039_adic_set_ies_incl_prop('S')
           CALL fin80039_adic_set_ind_valid_modif("N") #Indicador para não barrar no FIN80039

           #--# Efetiva modificação da AP #--#
           CALL fin80039_inclui_ap(mr_ad_mestre.cod_empresa,
                                   mr_ad_mestre.cnd_pgto,
                                   mr_ad_mestre.dat_venc)
              RETURNING m_status, m_msg, lr_ad_aps.num_ad_ap, l_num_ad_fatura
           IF NOT m_status THEN
              RETURN FALSE, m_msg
           END IF
        END IF
     END FOR
  END IF

  RETURN TRUE, ' '

END FUNCTION

#----------------------------------#
 FUNCTION fin80030_busca_observ_ap()
#----------------------------------#

  DEFINE l_observ      CHAR(40)

  CASE mr_dados_integr.sistema_gerador
    WHEN "V"
       LET l_observ  =  " AP INCLUIDA PELO MÓDULO CDV"
    WHEN "C"
       LET l_observ  =  " AP INCLUIDA PELO CONTAS A PAGAR"
    WHEN "I"
       LET l_observ  =  " AP INCLUIDA PELO IMPORTACAO"
    WHEN "H"
       LET l_observ  =  " AP INCLUIDA PELO MÓDULO RHU"
    WHEN "F"
       LET l_observ  =  " AP INCLUIDA PELO FRETES INTERNACIONAIS"
    WHEN "O"
       LET l_observ  =  " AP INCLUIDA PELO CONTRATOS FINANCEIROS"
    WHEN "A"
       LET l_observ  =  " AP INCLUIDA PELO CONTRATOS DE ALUGUEIS"
    WHEN "R"
       LET l_observ  =  " AP INCLUIDA PELO CONTAS A RECEBER"
    WHEN "P"
       LET l_observ  =  " AP INCLUIDA PELO MÓDULO SIP"
    WHEN "E"
       LET l_observ  =  " AP INCLUIDA PELO CONTRATOS DE SERVICOS"
    WHEN "N"
       LET l_observ  =  " AP INCLUIDA PELO ASSISTENCIA TECNICA"
    WHEN "X"
       LET l_observ  =  " AP INCLUIDA PELO CAP3230"
    WHEN "Z"
       LET l_observ  =  " AP INCLUIDA PELO MATÉRIA PRIMA"
    OTHERWISE
       LET l_observ  =  " AP INCLUIDA POR OUTROS SISTEMAS"
  END CASE

  RETURN l_observ

END FUNCTION

#-----------------------------------#
 FUNCTION fin80030_carrega_dados_ad()
#-----------------------------------#

  IF mr_dados_integr.cod_tip_despesa IS NULL THEN
     LET mr_dados_integr.cod_tip_despesa = capm1_ad_mestre_get_cod_tip_despesa()
  END IF

  IF mr_dados_integr.num_nf IS NULL THEN
     LET mr_dados_integr.num_nf          = capm1_ad_mestre_get_num_nf()
  END IF

  IF mr_dados_integr.ser_nf IS NULL THEN
     LET mr_dados_integr.ser_nf          = capm1_ad_mestre_get_ser_nf()
  END IF

  IF mr_dados_integr.ssr_nf IS NULL THEN
     LET mr_dados_integr.ssr_nf          = capm1_ad_mestre_get_ssr_nf()
  END IF

  IF mr_dados_integr.dat_venc IS NULL THEN
     LET mr_dados_integr.dat_venc        = capm1_ad_mestre_get_dat_venc()
  END IF

  IF mr_dados_integr.cnd_pgto IS NULL THEN
     LET mr_dados_integr.cnd_pgto        = capm1_ad_mestre_get_cnd_pgto()
  END IF

  IF mr_dados_integr.cod_fornecedor IS NULL THEN
     LET mr_dados_integr.cod_fornecedor  = capm1_ad_mestre_get_cod_fornecedor()
  END IF

  IF mr_dados_integr.val_tot_nf IS NULL THEN
     LET mr_dados_integr.val_tot_nf      = capm1_ad_mestre_get_val_tot_nf()
  END IF

  IF mr_dados_integr.ies_dep_cred IS NULL THEN
     LET mr_dados_integr.ies_dep_cred    = capm1_ad_mestre_get_ies_dep_cred()
  END IF

  IF mr_dados_integr.dat_rec_nf IS NULL THEN
     LET mr_dados_integr.dat_rec_nf      = capm1_ad_mestre_get_dat_rec_nf()
  END IF

  IF mr_dados_adic.cod_empresa_estab IS NULL THEN
     LET mr_dados_adic.cod_empresa_estab = capm1_ad_mestre_get_cod_empresa_estab()
  END IF

  IF mr_dados_adic.mes_ano_compet IS NULL THEN
     LET mr_dados_adic.mes_ano_compet = capm1_ad_mestre_get_mes_ano_compet()
  END IF

  IF mr_dados_adic.num_ord_forn IS NULL THEN
     LET mr_dados_adic.num_ord_forn = capm1_ad_mestre_get_num_ord_forn()
  END IF

  IF mr_dados_adic.cod_moeda IS NULL THEN
     LET mr_dados_adic.cod_moeda = capm1_ad_mestre_get_cod_moeda()
  END IF

  IF mr_dados_adic.set_aplicacao IS NULL THEN
     LET mr_dados_adic.set_aplicacao = capm1_ad_mestre_get_set_aplicacao()
  END IF

  IF mr_dados_adic.cod_tip_ad IS NULL THEN
     LET mr_dados_adic.cod_tip_ad = capm1_ad_mestre_get_cod_tip_ad()
  END IF

  IF mr_dados_adic.dat_emis_nf IS NULL THEN
     LET mr_dados_adic.dat_emis_nf = capm1_ad_mestre_get_dat_emis_nf()
  END IF

  IF mr_dados_adic.ies_ap_autom IS NULL THEN
     LET mr_dados_adic.ies_ap_autom = capm1_ad_mestre_get_ies_ap_autom()
  END IF

END FUNCTION

#---------------------------------------------------------#
 FUNCTION fin80030_carrega_atualiza_ad_valores_existentes()
#---------------------------------------------------------#

  DEFINE l_ind  SMALLINT,
         l_cont SMALLINT

  DEFINE lr_ad_valores RECORD LIKE ad_valores.*

  DEFINE la_tipo_valor_integr ARRAY[100] OF RECORD
                                               cod_tip_val            DECIMAL(3,0),
                                               valor                  DECIMAL(15,2),

                                               num_seq                LIKE ad_valores.num_seq, #--# Necessário apenas para a modificação #--#
                                               ind_alteracao          CHAR(01),                #--# Necessário apenas para a modificação #--#
                                               ind_existencia         CHAR(01)                 #--# Controle interno                     #--#
                                            END RECORD

  DEFINE l_sql_stmt CHAR(9000)

  #--# Transfere dados para o array temporário #--#
  FOR l_ind = 1 TO 100
     IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     END IF

     LET la_tipo_valor_integr[l_ind].* = ma_tipo_valor_integr[l_ind].*
  END FOR

  #--# Inicializa array de ajustes principais #--#
  FOR l_ind = 1 TO 100
     INITIALIZE ma_tipo_valor_integr[l_ind].* TO NULL
  END FOR

  #--# Inicializa contagem dos ajustes principais #--#
  LET l_cont = 1

  #--# Carrega a interface básica de impostos para busca pelos tipo de valor a desconsiderar #--#
  CALL fin80038_carrega_interface_basica_tipo_valor(mr_ad_mestre.cod_empresa,
                                                    mr_ad_mestre.cod_tip_despesa,
                                                    mr_ad_mestre.cod_fornecedor)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  LET l_sql_stmt = ' SELECT * ',
                   '   FROM ad_valores  ',
                   '  WHERE cod_empresa = "',mr_ad_mestre.cod_empresa,'"',
                   '    AND num_ad      =  ',mr_ad_mestre.num_ad

  #--# Ignora tipos de valor de impostos caso a opção de ignorar o processamento de imposto esteja setado #--#
  IF mr_dados_adic.ind_inform_trib <> 'I' THEN #--# Ignora #--#
     LET l_sql_stmt = l_sql_stmt CLIPPED, '    AND cod_tip_val NOT IN (',fin80054_retorna_tipo_valor_impostos() CLIPPED,')'
  END IF

  WHENEVER ERROR CONTINUE
   PREPARE var_query_tip_val_ad FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema ao efetuar a carga dos ajustes financeiros existentes!'
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_carrega_ad_valores CURSOR FOR var_query_tip_val_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema ao efetuar a carga dos ajustes financeiros existentes!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_carrega_ad_valores INTO lr_ad_valores.*
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema ao efetuar a carga dos ajustes financeiros existentes!'
      END IF

      #--# Busca registros excluídos #--#
      FOR l_ind = 1 TO 100
         IF la_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
            EXIT FOR
         END IF

         #--# Exclusão de um registro #--#
         IF la_tipo_valor_integr[l_ind].num_seq        = lr_ad_valores.num_seq AND
            la_tipo_valor_integr[l_ind].ind_alteracao  = 'E'                   THEN

            IF ma_adiantamentos_integr[l_ind].cod_tip_val IS NOT NULL THEN

               #--# Elimina baixa do adiantamento #--#
               CALL fin80030_elimina_baixa_adiantamento(mr_ad_mestre.cod_empresa, '1', mr_ad_mestre.num_ad, ma_adiantamentos_integr[l_ind].*)
                  RETURNING m_status, m_msg
               IF NOT m_status THEN
                  RETURN FALSE, m_msg
               END IF
            END IF

            LET ma_tipo_valor_integr[l_cont].cod_tip_val    = lr_ad_valores.cod_tip_val
            LET ma_tipo_valor_integr[l_cont].valor          = lr_ad_valores.valor
            LET ma_tipo_valor_integr[l_cont].ind_existencia = 'S'
            LET ma_tipo_valor_integr[l_cont].ind_alteracao  = 'E'

            LET l_cont = l_cont + 1

            #--# Elimina registro do array principal #--#
            CONTINUE FOREACH
         END IF

         #--# Modificação de um registro #--#
         IF la_tipo_valor_integr[l_ind].num_seq = lr_ad_valores.num_seq AND
            la_tipo_valor_integr[l_ind].ind_alteracao = 'M' THEN

            LET ma_tipo_valor_integr[l_cont].cod_tip_val    = la_tipo_valor_integr[l_ind].cod_tip_val
            LET ma_tipo_valor_integr[l_cont].valor          = la_tipo_valor_integr[l_ind].valor

            CONTINUE FOREACH
         END IF
      END FOR

      #--# Carrega os tipos de valores já existentes #--#
      LET ma_tipo_valor_integr[l_cont].cod_tip_val    = lr_ad_valores.cod_tip_val
      LET ma_tipo_valor_integr[l_cont].valor          = lr_ad_valores.valor
      LET ma_tipo_valor_integr[l_cont].ind_existencia = 'S'

      LET l_cont = l_cont + 1

      WHENEVER ERROR CONTINUE
   END FOREACH
   FREE cq_carrega_ad_valores
  WHENEVER ERROR STOP

  #--# Adiciona os novos ajustes (I) #--#
  FOR l_ind = 1 TO 100
     IF la_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     END IF

     IF la_tipo_valor_integr[l_ind].ind_alteracao = 'I' THEN

        LET ma_tipo_valor_integr[l_cont].cod_tip_val = la_tipo_valor_integr[l_ind].cod_tip_val
        LET ma_tipo_valor_integr[l_cont].valor       = la_tipo_valor_integr[l_ind].valor

        #--# Inclui a baixa de adiantamento #--#
        IF la_tipo_valor_integr[l_ind].ind_alteracao = 'I' AND
           ma_adiantamentos_integr[l_ind].cod_tip_val IS NOT NULL THEN

           #--# Inclui a baixa de adiantamento #--#
           CALL fin80030_baixa_adiantamento(mr_ad_mestre.cod_empresa, '1', mr_ad_mestre.num_ad, mr_ad_mestre.dat_rec_nf, ma_adiantamentos_integr[l_ind].*)
              RETURNING m_status, m_msg
           IF NOT m_status THEN
              RETURN FALSE, m_msg
           END IF
        END IF

        LET l_cont = l_cont + 1
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------------#
 FUNCTION fin80030_baixa_adiantamentos_ad_valores()
#-------------------------------------------------#

  DEFINE l_ind SMALLINT

  #--# Verifica a necessidade da baixa de adiantamentos #--#
  FOR l_ind = 1 TO 100
     IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     END IF

     #--# Inclui a baixa de adiantamento #--#
     IF ma_adiantamentos_integr[l_ind].cod_tip_val IS NOT NULL THEN
        CALL fin80030_baixa_adiantamento(mr_ad_mestre.cod_empresa, '1', mr_ad_mestre.num_ad, mr_ad_mestre.dat_rec_nf, ma_adiantamentos_integr[l_ind].*)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------#
 FUNCTION fin80030_inclui_ad_valores()
#------------------------------------#

  DEFINE l_ind                 SMALLINT

  DEFINE lr_ad_valores         RECORD LIKE ad_valores.*

  #--# Elimina registros antes de incluir #--#
  CALL fin80039_manut_cap_dat_ajuste_fin('E', mr_ad_mestre.cod_empresa, '1', mr_ad_mestre.num_ad, NULL)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_valores
     WHERE cod_empresa = mr_ad_mestre.cod_empresa
       AND num_ad      = mr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação dos ajustes financeiros!'
  END IF

  FOR l_ind = 1 TO 100
     IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     ELSE
        #--# Ignorar registros excluídos #--#
        IF ma_tipo_valor_integr[l_ind].ind_alteracao IS NOT NULL AND
           ma_tipo_valor_integr[l_ind].ind_alteracao = 'E' THEN
           CONTINUE FOR
        END IF

        #--# Tipo de valor #--#
        LET lr_ad_valores.cod_empresa   = m_cod_empresa_dest
        LET lr_ad_valores.num_ad        = mr_ad_mestre.num_ad
        LET lr_ad_valores.num_seq       = capt4_ad_valores_get_max_num_seq(lr_ad_valores.cod_empresa, lr_ad_valores.num_ad)
        LET lr_ad_valores.cod_tip_val   = ma_tipo_valor_integr[l_ind].cod_tip_val
        LET lr_ad_valores.valor         = ma_tipo_valor_integr[l_ind].valor

        CALL fin80039_manut_cap_dat_ajuste_fin('I', lr_ad_valores.cod_empresa, '1', lr_ad_valores.num_ad, lr_ad_valores.cod_tip_val)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF

        CALL capm4_ad_valores_set_all(lr_ad_valores.*)

        #--# Grava AD valores #--#
        CALL capt4_ad_valores_inclui(TRUE,TRUE)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#---------------------------------------------#
 FUNCTION fin80030_verifica_ad_valores_adiant()
#---------------------------------------------#

  DEFINE l_sql_stmt            CHAR(9000)

  DEFINE l_cod_tip_val         LIKE tipo_valor.cod_tip_val

  #--# Verificação para que não existam baixas de adiantamento utilizando tipo de valor de impostos #--#

  #--# Carrega a interface básica de impostos para busca pelos tipo de valor a desconsiderar #--#
  CALL fin80038_carrega_interface_basica_tipo_valor(mr_ad_mestre.cod_empresa,
                                                    mr_ad_mestre.cod_tip_despesa,
                                                    mr_ad_mestre.cod_fornecedor)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  LET l_sql_stmt = ' SELECT cod_tip_val ',
                   '   FROM ad_valores  ',
                   '  WHERE cod_empresa = "',mr_ad_mestre.cod_empresa,'"',
                   '    AND num_ad      =  ',mr_ad_mestre.num_ad,
                   '    AND cod_tip_val IN (',fin80054_retorna_tipo_valor_impostos() CLIPPED,')',
                   '    AND EXISTS (SELECT 1 ',
                   '                  FROM mov_adiant ',
                   '                 WHERE cod_empresa = "',mr_ad_mestre.cod_empresa,'"',
                   '                   AND num_ad_ap_mov = ',mr_ad_mestre.num_ad,
                   '                   AND ies_ad_ap_mov = "1" ',
                   '                   AND cod_tip_val_mov = ad_valores.cod_tip_val) '

  WHENEVER ERROR CONTINUE
   PREPARE var_query_ver_tip_imp FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema ao efetuar a inclusão dos ajustes financeiros!'
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_ver_tip_imp CURSOR WITH HOLD FOR var_query_ver_tip_imp
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema ao efetuar a inclusão dos ajustes financeiros!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_ver_tip_imp INTO l_cod_tip_val
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema ao efetuar a inclusão dos ajustes financeiros!'
      END IF

      LET m_msg = 'O tipo de valor (',l_cod_tip_val,') utilizado para efetuar uma movimentação de adiantamento não poderá ser de impostos!'
      RETURN FALSE, m_msg

   END FOREACH
   FREE cq_ver_tip_imp
  WHENEVER ERROR STOP

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------------------#
 FUNCTION fin80030_contabiliza_lanc_array()
#-----------------------------------------#

  DEFINE l_ind_lanc SMALLINT

  DEFINE lr_lanc_cont_cap RECORD LIKE lanc_cont_cap.*,
         lr_plano_contas  RECORD LIKE plano_contas.*

  #--# Elimina registros antes de incluir #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM lanc_cont_cap
     WHERE cod_empresa = mr_ad_mestre.cod_empresa
       AND num_ad_ap   = mr_ad_mestre.num_ad
       AND ies_ad_ap   = "1"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação dos lançamentos contábeis!'
  END IF

  #--# Elimina registros antes de incluir #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM ctb_lanc_ctbl_cap
     WHERE empresa     = mr_ad_mestre.cod_empresa
       AND num_ad_ap   = mr_ad_mestre.num_ad
       AND eh_ad_ap    = "1"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação dos lançamentos contábeis on-line!'
  END IF

  FOR l_ind_lanc = 1 TO 500
     IF ma_lanc_cont_cap_integr[l_ind_lanc].ies_tipo_lanc IS NULL THEN
        EXIT FOR
     END IF

     LET lr_lanc_cont_cap.cod_empresa       = m_cod_empresa_dest
     LET lr_lanc_cont_cap.num_ad_ap         = mr_ad_mestre.num_ad
     LET lr_lanc_cont_cap.ies_ad_ap         = "1"
     LET lr_lanc_cont_cap.ies_tipo_lanc     = ma_lanc_cont_cap_integr[l_ind_lanc].ies_tipo_lanc
     LET lr_lanc_cont_cap.num_seq           = capt6_lanc_cont_cap_get_max_num_seq(lr_lanc_cont_cap.cod_empresa, lr_lanc_cont_cap.num_ad_ap, lr_lanc_cont_cap.ies_ad_ap)
     LET lr_lanc_cont_cap.num_conta_cont    = ma_lanc_cont_cap_integr[l_ind_lanc].num_conta_cont
     LET lr_lanc_cont_cap.val_lanc          = ma_lanc_cont_cap_integr[l_ind_lanc].val_lanc
     LET lr_lanc_cont_cap.ies_desp_val      = ma_lanc_cont_cap_integr[l_ind_lanc].ies_desp_val
     LET lr_lanc_cont_cap.ies_man_aut       = "A"
     LET lr_lanc_cont_cap.ies_cnd_pgto      = "S"
     LET lr_lanc_cont_cap.num_lote_transf   = 0
     LET lr_lanc_cont_cap.num_lote_lanc     = 0
     LET lr_lanc_cont_cap.dat_lanc          = ma_lanc_cont_cap_integr[l_ind_lanc].dat_lanc
     LET lr_lanc_cont_cap.tex_hist_lanc     = ma_lanc_cont_cap_integr[l_ind_lanc].tex_hist_lanc
     LET lr_lanc_cont_cap.tex_hist_lanc     = fin80036_ext_hist(lr_lanc_cont_cap.tex_hist_lanc,mr_ad_mestre.num_ad,1,0,m_cod_empresa_dest)

     IF lr_lanc_cont_cap.ies_desp_val = "D" THEN
        LET lr_lanc_cont_cap.cod_tip_desp_val = mr_ad_mestre.cod_tip_despesa
        LET lr_lanc_cont_cap.ies_man_aut      = mr_tipo_despesa.ies_contab
     ELSE
        LET lr_lanc_cont_cap.cod_tip_desp_val = ma_lanc_cont_cap_integr[l_ind_lanc].cod_tip_desp_val
        LET lr_lanc_cont_cap.ies_man_aut      = "M"
     END IF

     IF (mr_tipo_despesa.ies_quando_contab = "C") OR (mr_tipo_despesa.ies_quando_contab IS NULL) THEN
        LET lr_lanc_cont_cap.ies_liberad_contab = "S"
     ELSE
        LET lr_lanc_cont_cap.ies_liberad_contab = "N"
     END IF

     #--# Busca a conta reduzida #--#
     CALL con088_verifica_cod_conta(lr_lanc_cont_cap.cod_empresa, lr_lanc_cont_cap.num_conta_cont, "S"," ")
        RETURNING lr_plano_contas.*, m_status
     IF NOT m_status THEN
        LET m_msg = 'Conta contábil inválida ',lr_lanc_cont_cap.num_conta_cont CLIPPED,' (',lr_plano_contas.den_conta CLIPPED,')'
        RETURN FALSE, m_msg
     END IF

     #--# Consiste lançamento zerado #--#
     IF lr_lanc_cont_cap.val_lanc <= 0 THEN
        LET m_msg = 'Valor do lançamento deverá ser maior que zero! Conta: ',lr_lanc_cont_cap.num_conta_cont CLIPPED,' (',lr_plano_contas.den_conta CLIPPED,')'
        RETURN FALSE, m_msg
     END IF

     IF lr_plano_contas.num_conta_reduz IS NOT NULL THEN
        LET lr_lanc_cont_cap.num_conta_cont = lr_plano_contas.num_conta_reduz
     END IF

     #--# Grava lançamentos #--#
     CALL capm6_lanc_cont_cap_set_all(lr_lanc_cont_cap.*)
     CALL capt6_lanc_cont_cap_inclui(TRUE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------#
 FUNCTION fin80030_gera_lanc_cont_ad_valores()
#--------------------------------------------#

  DEFINE lr_tipo_val       RECORD LIKE tipo_valor.*,
         l_ult_lanc        SMALLINT,
         l_ind             SMALLINT,
         l_ind_lanc        SMALLINT,
         l_val_lanc        DECIMAL(17,2)

  DEFINE l_ind_descn       SMALLINT

  DEFINE lr_lanc_cont_cap  RECORD LIKE lanc_cont_cap.*

  INITIALIZE lr_tipo_val.* TO NULL

  #--# Verifica última numeração de lançamento do array #--#
  IF ma_lanc_cont_cap_integr[1].num_conta_cont IS NOT NULL THEN
     FOR l_ult_lanc = 1 TO 500
        IF ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_lanc = 1
  END IF

  #--# Modificação #--#
  IF mr_dados_adic.ind_modif_ad = 'S' THEN

     #--# Carrega lançamentos já existentes #--#
     WHENEVER ERROR CONTINUE
      DECLARE cq_carrega_lanc_val CURSOR FOR
       SELECT *
         FROM lanc_cont_cap
        WHERE cod_empresa  = mr_ad_mestre.cod_empresa
          AND num_ad_ap    = mr_ad_mestre.num_ad
          AND ies_ad_ap    = '1'
          AND ies_desp_val = 'V'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na carga dos lançamentos contábeis!'
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_carrega_lanc_val INTO lr_lanc_cont_cap.*
         IF sqlca.sqlcode <> 0 THEN
            RETURN FALSE, 'Problema na carga dos lançamentos contábeis!'
         END IF

         #--# Ignora tipos de valores que serão integrados #--#
         FOR l_ind = 1 TO 1000
            IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
               EXIT FOR
            END IF

            IF ma_tipo_valor_integr[l_ind].cod_tip_val = lr_lanc_cont_cap.cod_tip_desp_val THEN
               CONTINUE FOREACH
            END IF
         END FOR

         LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc    = lr_lanc_cont_cap.ies_tipo_lanc
         LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont   = lr_lanc_cont_cap.num_conta_cont
         LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc         = lr_lanc_cont_cap.val_lanc
         LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val     = "V"
         LET ma_lanc_cont_cap_integr[l_ult_lanc].cod_tip_desp_val = lr_lanc_cont_cap.cod_tip_desp_val
         LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc         = lr_lanc_cont_cap.dat_lanc
         LET ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc    = lr_lanc_cont_cap.tex_hist_lanc

         LET l_ult_lanc = l_ult_lanc + 1

         WHENEVER ERROR CONTINUE
      END FOREACH
      FREE cq_carrega_lanc_val
     WHENEVER ERROR STOP
  END IF

  FOR l_ind = 1 TO 1000
     IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     END IF

     #--# Ignorar registros excluídos #--#
     IF ma_tipo_valor_integr[l_ind].ind_alteracao IS NOT NULL AND
        ma_tipo_valor_integr[l_ind].ind_alteracao = 'E' THEN
        CONTINUE FOR
     END IF

     #--# Verifica se deve desconsiderar o lançamento automâtico pois já existe no array de lançamentos #--#
     LET l_ind_descn = FALSE

     FOR l_ind_lanc = 1 TO 500
        IF ma_lanc_cont_cap_integr[l_ind_lanc].num_conta_cont IS NULL THEN
           EXIT FOR
        END IF

        IF ma_lanc_cont_cap_integr[l_ind_lanc].cod_tip_desp_val = ma_tipo_valor_integr[l_ind].cod_tip_val AND
           ma_lanc_cont_cap_integr[l_ind_lanc].ies_desp_val     = 'V' THEN

           LET l_ind_descn = TRUE
        END IF
     END FOR

     IF l_ind_descn THEN
        CONTINUE FOR
     END IF

     #--# Efetua a leitura do tipo de valor #--#
     IF capm87_tipo_valor_leitura(m_cod_empresa_dest,ma_tipo_valor_integr[l_ind].cod_tip_val,TRUE,FALSE) THEN
        CALL capm87_tipo_valor_get_all()
           RETURNING lr_tipo_val.*
     ELSE
        RETURN FALSE, 'Tipo de valor não encontrado!'
     END IF

     #--# Efetua a leitura da AD valores #--#
     CALL capm4_ad_valores_leitura(m_cod_empresa_dest,mr_ad_mestre.num_ad,ma_tipo_valor_integr[l_ind].cod_tip_val,TRUE,TRUE)
        RETURNING m_status, m_msg
     IF m_status THEN
        LET l_val_lanc = capm4_ad_valores_get_valor()
     ELSE
        CONTINUE FOR
     END IF

     IF lr_tipo_val.ies_contab <> 'N' THEN
        IF lr_tipo_val.num_conta_deb IS NOT NULL THEN

           #--# Grava débito #--#
           LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc    = "D"
           LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont   = lr_tipo_val.num_conta_deb
           LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc         = l_val_lanc
           LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val     = "V"
           LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc         = mr_ad_mestre.dat_rec_nf
           LET ma_lanc_cont_cap_integr[l_ult_lanc].cod_tip_desp_val = lr_tipo_val.cod_tip_val

           CALL fin80036_valida_historico(m_cod_empresa_dest, lr_tipo_val.cod_hist_deb, '')
              RETURNING m_status, ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc
           IF NOT m_status OR ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc IS NULL THEN
              LET m_msg  = ' Histórico: ',lr_tipo_val.cod_hist_deb,' não cadastrado!'
              RETURN FALSE, m_msg
           END IF

           LET l_ult_lanc = l_ult_lanc + 1
        END IF

        IF lr_tipo_val.num_conta_cred IS NOT NULL THEN

           #--# Grava débito #--#
           LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_tipo_lanc    = "C"
           LET ma_lanc_cont_cap_integr[l_ult_lanc].num_conta_cont   = lr_tipo_val.num_conta_cred
           LET ma_lanc_cont_cap_integr[l_ult_lanc].val_lanc         = l_val_lanc
           LET ma_lanc_cont_cap_integr[l_ult_lanc].ies_desp_val     = "V"
           LET ma_lanc_cont_cap_integr[l_ult_lanc].dat_lanc         = mr_ad_mestre.dat_rec_nf
           LET ma_lanc_cont_cap_integr[l_ult_lanc].cod_tip_desp_val = lr_tipo_val.cod_tip_val

           CALL fin80036_valida_historico(m_cod_empresa_dest, lr_tipo_val.cod_hist_cred, '')
              RETURNING m_status, ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc
           IF NOT m_status OR ma_lanc_cont_cap_integr[l_ult_lanc].tex_hist_lanc IS NULL THEN
              LET m_msg  = ' Histórico: ',lr_tipo_val.cod_hist_cred,' não cadastrado!'
              RETURN FALSE, m_msg
           END IF

           LET l_ult_lanc = l_ult_lanc + 1
        END IF
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_gera_aen_contabilz_ad_valores()
#------------------------------------------------#

  DEFINE l_ind       SMALLINT

  DEFINE l_cont      SMALLINT

  DEFINE l_ind_inc     SMALLINT,
         l_ind_aen     SMALLINT

  INITIALIZE ma_ad_aen_conta_integr_val,
             ma_ad_aen_conta_4_integr_val TO NULL

  FOR l_ind = 1 TO 1000
     IF ma_tipo_valor_integr[l_ind].cod_tip_val IS NULL THEN
        EXIT FOR
     END IF

     #--# Ignorar registros excluídos #--#
     IF ma_tipo_valor_integr[l_ind].ind_alteracao IS NOT NULL AND
        ma_tipo_valor_integr[l_ind].ind_alteracao = 'E' THEN
        CONTINUE FOR
     END IF

     #--# Ignora registros de ad_valores já existentes (serão carregados via carga de AEN) #--#
     IF ma_tipo_valor_integr[l_ind].ind_existencia IS NULL OR
        ma_tipo_valor_integr[l_ind].ind_existencia = 'N' THEN

        FOR l_cont = 1 TO 500
           IF ma_lanc_cont_cap_integr[l_cont].ies_tipo_lanc IS NULL THEN
              EXIT FOR
           END IF

            IF ma_lanc_cont_cap_integr[l_cont].cod_tip_desp_val = ma_tipo_valor_integr[l_ind].cod_tip_val AND
               ma_lanc_cont_cap_integr[l_cont].ies_desp_val     = 'V' THEN

               #--# Grava os registros de AEN da ad_valores #--#
               IF NOT fin80030_inclui_aen_ad_valores(m_cod_empresa_dest,
                                                     mr_ad_mestre.num_ad,
                                                     ma_lanc_cont_cap_integr[l_cont].val_lanc,
                                                     l_cont,
                                                     ma_lanc_cont_cap_integr[l_cont].ies_tipo_lanc,
                                                     ma_lanc_cont_cap_integr[l_cont].num_conta_cont) THEN
        	         RETURN FALSE, ' Problema ao gerar AENs dos ajustes financeiros e impostos!'
               END IF
            END IF
        END FOR
     END IF
  END FOR

  #--# Transfere AENs de tipo de valor para o array principal - 2 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_integr[l_ind].val_item IS NULL THEN

        LET l_ind_inc = l_ind

        #--# Varre todas as AENs dos tipos de valores #--#
        FOR l_ind_aen = 1 TO 200
           IF ma_ad_aen_conta_integr_val[l_ind_aen].val_item IS NULL THEN
              EXIT FOR
           END IF

           LET ma_ad_aen_conta_integr[l_ind_inc].num_seq_lanc     = ma_ad_aen_conta_integr_val[l_ind_aen].num_seq_lanc
           LET ma_ad_aen_conta_integr[l_ind_inc].ies_tipo_lanc    = ma_ad_aen_conta_integr_val[l_ind_aen].ies_tipo_lanc
           LET ma_ad_aen_conta_integr[l_ind_inc].num_conta_cont   = ma_ad_aen_conta_integr_val[l_ind_aen].num_conta_cont
           LET ma_ad_aen_conta_integr[l_ind_inc].ies_fornec_trans = ma_ad_aen_conta_integr_val[l_ind_aen].ies_fornec_trans
           LET ma_ad_aen_conta_integr[l_ind_inc].cod_area_negocio = ma_ad_aen_conta_integr_val[l_ind_aen].cod_area_negocio
           LET ma_ad_aen_conta_integr[l_ind_inc].cod_lin_negocio  = ma_ad_aen_conta_integr_val[l_ind_aen].cod_lin_negocio
           LET ma_ad_aen_conta_integr[l_ind_inc].val_item         = ma_ad_aen_conta_integr_val[l_ind_aen].val_item

           LET l_ind_inc = l_ind_inc + 1
        END FOR

        EXIT FOR
     END IF
  END FOR

  #--# Transfere AENs de tipo de valor para o array principal - 4 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_4_integr[l_ind].val_aen IS NULL THEN

        LET l_ind_inc = l_ind

        #--# Varre todas as AENs dos tipos de valores #--#
        FOR l_ind_aen = 1 TO 200
           IF ma_ad_aen_conta_4_integr_val[l_ind_aen].val_aen IS NULL THEN
              EXIT FOR
           END IF

           LET ma_ad_aen_conta_4_integr[l_ind_inc].num_seq_lanc     = ma_ad_aen_conta_4_integr_val[l_ind_aen].num_seq_lanc
           LET ma_ad_aen_conta_4_integr[l_ind_inc].ies_tipo_lanc    = ma_ad_aen_conta_4_integr_val[l_ind_aen].ies_tipo_lanc
           LET ma_ad_aen_conta_4_integr[l_ind_inc].num_conta_cont   = ma_ad_aen_conta_4_integr_val[l_ind_aen].num_conta_cont
           LET ma_ad_aen_conta_4_integr[l_ind_inc].ies_fornec_trans = ma_ad_aen_conta_4_integr_val[l_ind_aen].ies_fornec_trans
           LET ma_ad_aen_conta_4_integr[l_ind_inc].cod_lin_prod     = ma_ad_aen_conta_4_integr_val[l_ind_aen].cod_lin_prod
           LET ma_ad_aen_conta_4_integr[l_ind_inc].cod_lin_recei    = ma_ad_aen_conta_4_integr_val[l_ind_aen].cod_lin_recei
           LET ma_ad_aen_conta_4_integr[l_ind_inc].cod_seg_merc     = ma_ad_aen_conta_4_integr_val[l_ind_aen].cod_seg_merc
           LET ma_ad_aen_conta_4_integr[l_ind_inc].cod_cla_uso      = ma_ad_aen_conta_4_integr_val[l_ind_aen].cod_cla_uso
           LET ma_ad_aen_conta_4_integr[l_ind_inc].val_aen          = ma_ad_aen_conta_4_integr_val[l_ind_aen].val_aen

           LET l_ind_inc = l_ind_inc + 1
        END FOR

        EXIT FOR
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------#
 FUNCTION fin80030_gera_carga_aen_existente()
#-------------------------------------------#

  DEFINE l_ult_aen          SMALLINT

  DEFINE l_ult_ad_aen         SMALLINT,
         l_ult_ad_aen_4       SMALLINT,
         l_ult_ad_aen_conta   SMALLINT,
         l_ult_ad_aen_conta_4 SMALLINT

  DEFINE l_num_conta_cont   CHAR(23),
         l_cod_aen          CHAR(08),
         l_val_item         LIKE ad_aen.val_item,
         l_num_seq_lanc     INTEGER,
         l_ies_tipo_lanc    LIKE ad_aen_conta.ies_tipo_lanc

  DEFINE l_cod_lin_prod     LIKE ad_aen_4.cod_lin_prod,
         l_cod_lin_recei    LIKE ad_aen_4.cod_lin_recei,
         l_cod_seg_merc     LIKE ad_aen_4.cod_seg_merc,
         l_cod_cla_uso      LIKE ad_aen_4.cod_cla_uso

  DEFINE la_ad_aen_tela    ARRAY[500] OF RECORD
                                            num_conta_cont   CHAR(23),
                                            cod_aen          CHAR(08),
                                            val_item         LIKE ad_aen.val_item,
                                            num_seq_lanc     INTEGER,
                                            ies_tipo_lanc    LIKE ad_aen_conta.ies_tipo_lanc
                                         END RECORD

  #--# Carrega os dados caso já exista na AD #--#
  CALL fin80001_pre_carrega_dados_aen(m_cod_empresa_dest, mr_ad_mestre.num_ad)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  LET l_ult_aen = 1

  #--# Carrega AENs existentes #--#
  FOR m_ind = 1 TO 500

     CALL fin80001_get_ad_aen_carga(m_ind)
        RETURNING m_status, l_num_conta_cont, l_cod_aen, l_val_item, l_num_seq_lanc, l_ies_tipo_lanc

     IF m_status THEN
        LET la_ad_aen_tela[l_ult_aen].num_conta_cont  = l_num_conta_cont
        LET la_ad_aen_tela[l_ult_aen].cod_aen         = l_cod_aen
        LET la_ad_aen_tela[l_ult_aen].val_item        = l_val_item
        LET la_ad_aen_tela[l_ult_aen].num_seq_lanc    = l_num_seq_lanc
        LET la_ad_aen_tela[l_ult_aen].ies_tipo_lanc   = l_ies_tipo_lanc
        LET l_ult_aen = l_ult_aen + 1
     ELSE
        EXIT FOR
     END IF
  END FOR

  #--# Verifica última numeração do array #--#
  IF ma_ad_aen_integr[1].val_item IS NOT NULL THEN
     FOR l_ult_ad_aen = 1 TO 500
        IF ma_ad_aen_integr[l_ult_ad_aen].val_item IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_ad_aen = 1
  END IF

  #--# Verifica última numeração do array #--#
  IF ma_ad_aen_4_integr[1].val_aen IS NOT NULL THEN
     FOR l_ult_ad_aen_4 = 1 TO 500
        IF ma_ad_aen_4_integr[l_ult_ad_aen_4].val_aen IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_ad_aen_4 = 1
  END IF

  #--# Verifica última numeração do array #--#
  IF ma_ad_aen_conta_integr[1].val_item IS NOT NULL THEN
     FOR l_ult_ad_aen_conta = 1 TO 500
        IF ma_ad_aen_conta_integr[l_ult_ad_aen_conta].val_item IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_ad_aen_conta = 1
  END IF

  #--# Verifica última numeração do array #--#
  IF ma_ad_aen_conta_integr[1].val_item IS NOT NULL THEN
     FOR l_ult_ad_aen_conta_4 = 1 TO 500
        IF ma_ad_aen_conta_integr[l_ult_ad_aen_conta_4].val_item IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_ad_aen_conta_4 = 1
  END IF

  FOR m_ind = 1 TO 500
     IF la_ad_aen_tela[m_ind].val_item IS NULL THEN
        EXIT FOR
     END IF

     LET l_cod_lin_prod  = la_ad_aen_tela[m_ind].cod_aen[1,2]
     LET l_cod_lin_recei = la_ad_aen_tela[m_ind].cod_aen[3,4]
     LET l_cod_seg_merc  = la_ad_aen_tela[m_ind].cod_aen[5,6]
     LET l_cod_cla_uso   = la_ad_aen_tela[m_ind].cod_aen[7,8]

     LET ma_ad_aen_integr[l_ult_ad_aen].val_item          = la_ad_aen_tela[m_ind].val_item
     LET ma_ad_aen_integr[l_ult_ad_aen].cod_area_negocio  = l_cod_lin_prod
     LET ma_ad_aen_integr[l_ult_ad_aen].cod_lin_negocio   = l_cod_lin_recei

     LET ma_ad_aen_4_integr[l_ult_ad_aen_4].val_aen       = la_ad_aen_tela[m_ind].val_item
     LET ma_ad_aen_4_integr[l_ult_ad_aen_4].cod_lin_prod  = l_cod_lin_prod
     LET ma_ad_aen_4_integr[l_ult_ad_aen_4].cod_lin_recei = l_cod_lin_recei
     LET ma_ad_aen_4_integr[l_ult_ad_aen_4].cod_seg_merc  = l_cod_seg_merc
     LET ma_ad_aen_4_integr[l_ult_ad_aen_4].cod_cla_uso   = l_cod_cla_uso

     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].val_item         = la_ad_aen_tela[m_ind].val_item
     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].num_seq_lanc     = la_ad_aen_tela[m_ind].num_seq_lanc
     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].ies_tipo_lanc    = la_ad_aen_tela[m_ind].ies_tipo_lanc
     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].num_conta_cont   = la_ad_aen_tela[m_ind].num_conta_cont
     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].cod_area_negocio = l_cod_lin_prod
     LET ma_ad_aen_conta_integr[l_ult_ad_aen_conta].cod_lin_negocio  = l_cod_lin_recei


     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].val_aen          = la_ad_aen_tela[m_ind].val_item
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].num_seq_lanc     = la_ad_aen_tela[m_ind].num_seq_lanc
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].ies_tipo_lanc    = la_ad_aen_tela[m_ind].ies_tipo_lanc
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].num_conta_cont   = la_ad_aen_tela[m_ind].num_conta_cont
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].cod_lin_prod     = l_cod_lin_prod
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].cod_lin_recei    = l_cod_lin_recei
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].cod_seg_merc     = l_cod_seg_merc
     LET ma_ad_aen_conta_4_integr[l_ult_ad_aen_conta_4].cod_cla_uso      = l_cod_cla_uso

     LET l_ult_ad_aen         = l_ult_ad_aen         + 1
     LET l_ult_ad_aen_4       = l_ult_ad_aen_4       + 1
     LET l_ult_ad_aen_conta   = l_ult_ad_aen_conta   + 1
     LET l_ult_ad_aen_conta_4 = l_ult_ad_aen_conta_4 + 1

  END FOR

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------------------#
 FUNCTION fin80030_manutencao_lancamentos()
#-----------------------------------------#

  DEFINE l_ind_lanc SMALLINT

  DEFINE lr_lanc_cont_cap RECORD LIKE lanc_cont_cap.*,
         lr_plano_contas  RECORD LIKE plano_contas.*

  #--# Não abrir tela caso não exista lançamentos #--#
  IF ma_lanc_cont_cap_integr[1].ies_tipo_lanc IS NULL THEN
     RETURN TRUE, ' '
  END IF

  CALL fin30027_inicializa_dados()

  FOR l_ind_lanc = 1 TO 500
     IF ma_lanc_cont_cap_integr[l_ind_lanc].ies_tipo_lanc IS NULL THEN
        EXIT FOR
     END IF

     LET lr_lanc_cont_cap.cod_empresa       = m_cod_empresa_dest
     LET lr_lanc_cont_cap.num_ad_ap         = mr_ad_mestre.num_ad
     LET lr_lanc_cont_cap.ies_ad_ap         = "1"
     LET lr_lanc_cont_cap.ies_tipo_lanc     = ma_lanc_cont_cap_integr[l_ind_lanc].ies_tipo_lanc
     LET lr_lanc_cont_cap.num_seq           = l_ind_lanc
     LET lr_lanc_cont_cap.num_conta_cont    = ma_lanc_cont_cap_integr[l_ind_lanc].num_conta_cont
     LET lr_lanc_cont_cap.val_lanc          = ma_lanc_cont_cap_integr[l_ind_lanc].val_lanc
     LET lr_lanc_cont_cap.ies_desp_val      = ma_lanc_cont_cap_integr[l_ind_lanc].ies_desp_val
     LET lr_lanc_cont_cap.ies_cnd_pgto      = "S"
     LET lr_lanc_cont_cap.num_lote_transf   = 0
     LET lr_lanc_cont_cap.num_lote_lanc     = 0
     LET lr_lanc_cont_cap.dat_lanc          = ma_lanc_cont_cap_integr[l_ind_lanc].dat_lanc
     LET lr_lanc_cont_cap.tex_hist_lanc     = ma_lanc_cont_cap_integr[l_ind_lanc].tex_hist_lanc
     LET lr_lanc_cont_cap.tex_hist_lanc     = fin80036_ext_hist(lr_lanc_cont_cap.tex_hist_lanc,mr_ad_mestre.num_ad,1,0,m_cod_empresa_dest)

     IF lr_lanc_cont_cap.ies_desp_val = "D" THEN
        LET lr_lanc_cont_cap.cod_tip_desp_val = mr_ad_mestre.cod_tip_despesa
        LET lr_lanc_cont_cap.ies_man_aut      = mr_tipo_despesa.ies_contab
     ELSE
        LET lr_lanc_cont_cap.cod_tip_desp_val = ma_lanc_cont_cap_integr[l_ind_lanc].cod_tip_desp_val
        LET lr_lanc_cont_cap.ies_man_aut      = "M"
     END IF

     IF (mr_tipo_despesa.ies_quando_contab = "C") OR (mr_tipo_despesa.ies_quando_contab IS NULL) THEN
        LET lr_lanc_cont_cap.ies_liberad_contab = "S"
     ELSE
        LET lr_lanc_cont_cap.ies_liberad_contab = "N"
     END IF

     #--# Busca a conta reduzida #--#
     CALL con088_verifica_cod_conta(lr_lanc_cont_cap.cod_empresa, lr_lanc_cont_cap.num_conta_cont, "S"," ")
        RETURNING lr_plano_contas.*, m_status
     IF lr_plano_contas.num_conta_reduz IS NOT NULL THEN
        LET lr_lanc_cont_cap.num_conta_cont = lr_plano_contas.num_conta_reduz
     END IF

     CALL fin30027_inclui_lanc_cont_cap_integr(lr_lanc_cont_cap.*)

  END FOR


  CALL fin30027_manut_lanc_param(lr_lanc_cont_cap.cod_empresa,
                                 lr_lanc_cont_cap.ies_ad_ap,
                                 lr_lanc_cont_cap.num_ad_ap,
                                 mr_dados_adic.ind_inform_lanc)
     RETURNING m_status
  IF NOT m_status THEN
     RETURN FALSE, 'Informação de lançamentos cancelada!'
  END IF

  FOR m_ind = 1 TO 500

     CALL fin30027_get_lanc_cont_cap_integr(m_ind)
        RETURNING m_status, lr_lanc_cont_cap.*

     IF m_status THEN

        LET ma_lanc_cont_cap_integr[m_ind].ies_tipo_lanc      = lr_lanc_cont_cap.ies_tipo_lanc
        LET ma_lanc_cont_cap_integr[m_ind].num_conta_cont     = lr_lanc_cont_cap.num_conta_cont
        LET ma_lanc_cont_cap_integr[m_ind].val_lanc           = lr_lanc_cont_cap.val_lanc
        LET ma_lanc_cont_cap_integr[m_ind].ies_desp_val       = lr_lanc_cont_cap.ies_desp_val
        LET ma_lanc_cont_cap_integr[m_ind].dat_lanc           = lr_lanc_cont_cap.dat_lanc
        LET ma_lanc_cont_cap_integr[m_ind].tex_hist_lanc      = lr_lanc_cont_cap.tex_hist_lanc
        LET ma_lanc_cont_cap_integr[m_ind].cod_tip_desp_val   = lr_lanc_cont_cap.cod_tip_desp_val
     ELSE
        EXIT FOR
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------#
 FUNCTION fin80030_inicializa()
#-----------------------------#

  INITIALIZE mr_ad_mestre.*,
             mr_tipo_despesa.*,
             m_num_ap TO NULL

END FUNCTION

#------------------------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_inclui_aen_ad_valores(l_cod_empresa, l_num_ad, l_val_lanc, l_num_seq_lanc, l_ies_tipo_lanc, l_num_conta_cont)
#------------------------------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa      LIKE ad_mestre.cod_empresa,
         l_num_ad           LIKE ad_mestre.num_ad,
         l_val_lanc         LIKE lanc_cont_cap.val_lanc,
         l_num_seq_lanc     INTEGER,
         l_ies_tipo_lanc    LIKE lanc_cont_cap.ies_tipo_lanc,
         l_num_conta_cont   LIKE lanc_cont_cap.num_conta_cont

  DEFINE l_ind         SMALLINT,
         l_ult_aen     SMALLINT,
         l_ult_aen_4   SMALLINT,
         l_perc        DECIMAL(15,8)

  #--# Verifica última numeração de AEN do array #--#
  IF ma_ad_aen_conta_integr_val[1].num_seq_lanc IS NOT NULL THEN
     FOR l_ult_aen = 1 TO 200
        IF ma_ad_aen_conta_integr_val[l_ult_aen].num_seq_lanc IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_aen = 1
  END IF

  #--# Verifica última numeração de AEN do array #--#
  IF ma_ad_aen_conta_4_integr_val[1].num_seq_lanc IS NOT NULL THEN
     FOR l_ult_aen_4 = 1 TO 200
        IF ma_ad_aen_conta_4_integr_val[l_ult_aen_4].num_seq_lanc IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_aen_4 = 1
  END IF

  #--# AEN Conta 2 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_integr[l_ind].val_item IS NULL THEN
        EXIT FOR
     END IF

     LET ma_ad_aen_conta_integr_val[l_ult_aen].num_seq_lanc     = l_num_seq_lanc
     LET ma_ad_aen_conta_integr_val[l_ult_aen].ies_tipo_lanc    = l_ies_tipo_lanc
     LET ma_ad_aen_conta_integr_val[l_ult_aen].num_conta_cont   = l_num_conta_cont
     LET ma_ad_aen_conta_integr_val[l_ult_aen].ies_fornec_trans = 'N'
     LET ma_ad_aen_conta_integr_val[l_ult_aen].cod_area_negocio = ma_ad_aen_conta_integr[l_ind].cod_area_negocio
     LET ma_ad_aen_conta_integr_val[l_ult_aen].cod_lin_negocio  = ma_ad_aen_conta_integr[l_ind].cod_lin_negocio

     LET l_perc = ma_ad_aen_conta_integr[l_ind].val_item / mr_ad_mestre.val_tot_nf
     LET ma_ad_aen_conta_integr_val[l_ult_aen].val_item = l_val_lanc * l_perc

     LET l_ult_aen = l_ult_aen + 1
  END FOR

  #--# AEN Conta 4 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_4_integr[l_ind].val_aen IS NULL THEN
        EXIT FOR
     END IF

     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].num_seq_lanc     = l_num_seq_lanc
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].ies_tipo_lanc    = l_ies_tipo_lanc
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].num_conta_cont   = l_num_conta_cont
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].ies_fornec_trans = 'N'
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].cod_lin_prod     = ma_ad_aen_conta_4_integr[l_ind].cod_lin_prod
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].cod_lin_recei    = ma_ad_aen_conta_4_integr[l_ind].cod_lin_recei
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].cod_seg_merc     = ma_ad_aen_conta_4_integr[l_ind].cod_seg_merc
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].cod_cla_uso      = ma_ad_aen_conta_4_integr[l_ind].cod_cla_uso

     LET l_perc = ma_ad_aen_conta_4_integr[l_ind].val_aen / mr_ad_mestre.val_tot_nf
     LET ma_ad_aen_conta_4_integr_val[l_ult_aen_4].val_aen = l_val_lanc * l_perc

     LET l_ult_aen_4 = l_ult_aen_4 + 1
  END FOR

  RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION fin80030_integra_impostos()
#-----------------------------------#

  DEFINE l_ult_tip_val    INTEGER

  DEFINE l_cod_tip_val    LIKE tipo_valor.cod_tip_val,
         l_valor          DECIMAL(17,2)

  #--# Efetua a gravação dos tipos de valores como preview para o cálculo do valor líquido dos impostos #--#
  #--# Será feito a re-gravação posteriormente de forma definitiva                                      #--#
  #--# Grava ajustes #--#
  CALL fin80030_inclui_ad_valores()
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  CALL fin80038_inicializa_dados()
  CALL fin80038_adic_set_programa_orig('FIN80030')

  IF mr_dados_adic.ind_inform_trib = 'S' THEN

     #--# Interface de impostos #--#
     CALL fin80043_manutencao_impostos('AD',
                                       mr_ad_mestre.cod_empresa,
                                       mr_ad_mestre.num_ad,
                                       mr_ad_mestre.ser_nf,
                                       mr_ad_mestre.ssr_nf,
                                       'AD',
                                       mr_ad_mestre.cod_fornecedor,
                                       'N')
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  ELSE
     FOR m_ind = 1 TO 100
        IF ma_impostos_integr[m_ind].cod_tip_val IS NULL THEN
           EXIT FOR
        END IF

        CALL fin80038_trib_set_cod_tip_val(ma_impostos_integr[m_ind].cod_tip_val)
        CALL fin80038_trib_set_val_base_calc(ma_impostos_integr[m_ind].val_base_calc)
        CALL fin80038_trib_set_valor(ma_impostos_integr[m_ind].valor)
        CALL fin80038_inclui_impostos_integr()

     END FOR

     #--# Efetiva a integração dos impostos carregados #--#
     CALL fin80038_integra_impostos('AD',
                                    mr_ad_mestre.cod_empresa,
                                    mr_ad_mestre.num_ad,
                                    mr_ad_mestre.ser_nf,
                                    mr_ad_mestre.ssr_nf,
                                    'AD',
                                    mr_ad_mestre.cod_fornecedor)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Verifica última numeração de tipo de valor do array #--#
  IF ma_tipo_valor_integr[1].cod_tip_val IS NOT NULL THEN
     FOR l_ult_tip_val = 1 TO 100
        IF ma_tipo_valor_integr[l_ult_tip_val].cod_tip_val IS NULL THEN
           EXIT FOR
        END IF
     END FOR
  ELSE
     LET l_ult_tip_val = 1
  END IF

  #--# Carrega tipo de valores dos impostos para criação das ad_valores #--#
  FOR m_ind = 1 TO 100

     CALL fin80038_get_ad_val(m_ind)
        RETURNING m_status, l_cod_tip_val, l_valor

     IF m_status THEN
        LET ma_tipo_valor_integr[l_ult_tip_val].cod_tip_val = l_cod_tip_val
        LET ma_tipo_valor_integr[l_ult_tip_val].valor       = l_valor
        LET l_ult_tip_val = l_ult_tip_val + 1

     ELSE
        EXIT FOR
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------------------------------#
 FUNCTION fin80030_carrega_aen(l_cod_empresa, l_num_ad)
#-----------------------------------------------------#

  DEFINE l_cod_empresa LIKE empresa.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE l_ind INTEGER

  DEFINE lr_ad_aen         RECORD LIKE ad_aen.*,
         lr_ad_aen_4       RECORD LIKE ad_aen_4.*,
         lr_ad_aen_conta   RECORD LIKE ad_aen_conta.*,
         lr_ad_aen_conta_4 RECORD LIKE ad_aen_conta_4.*

  #--# AEN 2 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_integr[l_ind].val_item IS NULL THEN
        EXIT FOR
     END IF

     LET lr_ad_aen.cod_empresa      = l_cod_empresa
     LET lr_ad_aen.num_ad           = l_num_ad
     LET lr_ad_aen.val_item         = ma_ad_aen_integr[l_ind].val_item
     LET lr_ad_aen.cod_area_negocio = ma_ad_aen_integr[l_ind].cod_area_negocio
     LET lr_ad_aen.cod_lin_negocio  = ma_ad_aen_integr[l_ind].cod_lin_negocio

     CALL fin80001_carrega_ad_aen(lr_ad_aen.*, l_ind)

  END FOR

  #--# AEN 4 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_4_integr[l_ind].val_aen IS NULL THEN
        EXIT FOR
     END IF

     LET lr_ad_aen_4.cod_empresa    = l_cod_empresa
     LET lr_ad_aen_4.num_ad         = l_num_ad
     LET lr_ad_aen_4.val_aen        = ma_ad_aen_4_integr[l_ind].val_aen
     LET lr_ad_aen_4.cod_lin_prod   = ma_ad_aen_4_integr[l_ind].cod_lin_prod
     LET lr_ad_aen_4.cod_lin_recei  = ma_ad_aen_4_integr[l_ind].cod_lin_recei
     LET lr_ad_aen_4.cod_seg_merc   = ma_ad_aen_4_integr[l_ind].cod_seg_merc
     LET lr_ad_aen_4.cod_cla_uso    = ma_ad_aen_4_integr[l_ind].cod_cla_uso

     CALL fin80001_carrega_ad_aen_4(lr_ad_aen_4.*, l_ind)

  END FOR

  #--# AEN Conta 2 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_integr[l_ind].val_item IS NULL THEN
        EXIT FOR
     END IF

     LET lr_ad_aen_conta.cod_empresa      = l_cod_empresa
     LET lr_ad_aen_conta.num_ad           = l_num_ad
     LET lr_ad_aen_conta.num_seq          = l_ind
     LET lr_ad_aen_conta.num_seq_lanc     = ma_ad_aen_conta_integr[l_ind].num_seq_lanc
     LET lr_ad_aen_conta.ies_tipo_lanc    = ma_ad_aen_conta_integr[l_ind].ies_tipo_lanc
     LET lr_ad_aen_conta.num_conta_cont   = ma_ad_aen_conta_integr[l_ind].num_conta_cont
     LET lr_ad_aen_conta.ies_fornec_trans = ma_ad_aen_conta_integr[l_ind].ies_fornec_trans
     LET lr_ad_aen_conta.val_item         = ma_ad_aen_conta_integr[l_ind].val_item
     LET lr_ad_aen_conta.cod_area_negocio = ma_ad_aen_conta_integr[l_ind].cod_area_negocio
     LET lr_ad_aen_conta.cod_lin_negocio  = ma_ad_aen_conta_integr[l_ind].cod_lin_negocio

     CALL fin80001_carrega_ad_aen_conta(lr_ad_aen_conta.*, l_ind)

  END FOR

  #--# AEN Conta 4 níveis #--#
  FOR l_ind = 1 TO 200
     IF ma_ad_aen_conta_4_integr[l_ind].val_aen IS NULL THEN
        EXIT FOR
     END IF

     LET lr_ad_aen_conta_4.cod_empresa      = l_cod_empresa
     LET lr_ad_aen_conta_4.num_ad           = l_num_ad
     LET lr_ad_aen_conta_4.num_seq          = l_ind
     LET lr_ad_aen_conta_4.num_seq_lanc     = ma_ad_aen_conta_4_integr[l_ind].num_seq_lanc
     LET lr_ad_aen_conta_4.ies_tipo_lanc    = ma_ad_aen_conta_4_integr[l_ind].ies_tipo_lanc
     LET lr_ad_aen_conta_4.num_conta_cont   = ma_ad_aen_conta_4_integr[l_ind].num_conta_cont
     LET lr_ad_aen_conta_4.ies_fornec_trans = ma_ad_aen_conta_4_integr[l_ind].ies_fornec_trans
     LET lr_ad_aen_conta_4.val_aen          = ma_ad_aen_conta_4_integr[l_ind].val_aen
     LET lr_ad_aen_conta_4.cod_lin_prod     = ma_ad_aen_conta_4_integr[l_ind].cod_lin_prod
     LET lr_ad_aen_conta_4.cod_lin_recei    = ma_ad_aen_conta_4_integr[l_ind].cod_lin_recei
     LET lr_ad_aen_conta_4.cod_seg_merc     = ma_ad_aen_conta_4_integr[l_ind].cod_seg_merc
     LET lr_ad_aen_conta_4.cod_cla_uso      = ma_ad_aen_conta_4_integr[l_ind].cod_cla_uso

     CALL fin80001_carrega_ad_aen_conta_4(lr_ad_aen_conta_4.*, l_ind)

  END FOR

END FUNCTION

#-------------------------------------------------------#
 FUNCTION fin80030_verifica_pode_modificar(l_cod_empresa,
                                           l_num_ad)
#-------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE lr_ad_mestre RECORD LIKE ad_mestre.*

  DEFINE lr_ad_aps  RECORD
                        cod_empresa       LIKE ap.cod_empresa,
                        ies_ad_ap         SMALLINT,
                        num_ad_ap         LIKE ad_mestre.num_ad
                    END RECORD

  DEFINE l_qtd_reg INTEGER,
         l_cont    INTEGER

  #--# Busca registro da AD #--#
  CALL capm1_ad_mestre_leitura(l_cod_empresa,
                               l_num_ad,
                               TRUE,
                               TRUE)
     RETURNING m_status
  IF m_status THEN
     CALL capm1_ad_mestre_get_all()
        RETURNING lr_ad_mestre.*
  END IF

  #--# Veririca se está bloqueada pelo SUP #--#
  IF lr_ad_mestre.ies_sup_cap = "B"  THEN
     LET m_msg = "AD bloqueada pelo SUP nao pode ser modificada!"
     RETURN FALSE, m_msg
  END IF

  #--# AD incluída via integração não pode ser modificada #--#

  IF m_alterou IS NULL THEN
     LET m_alterou = FALSE
  END IF

  IF lr_ad_mestre.ies_sup_cap <> "B" AND lr_ad_mestre.ies_sup_cap <> "C" AND lr_ad_mestre.ies_sup_cap <> "J" THEN
     IF lr_ad_mestre.ies_sup_cap = "Q" THEN
        RETURN FALSE, "AD bloqueada pelo módulo de aprovação eletrônica, a mesma não pode ser modificada no contas a pagar!"
     ELSE
        IF m_alterou THEN
           RETURN FALSE, "AD incluída via integração não pode ser modificada no contas a pagar!"
        END IF
     END IF
  END IF

  #--# Verifica se é uma AD de mutuo #--#
  IF lr_ad_mestre.ies_sup_cap = "M" THEN
     LET m_msg = " AD incluída pelo processo de MUTUO.  Não pode ser alterada."
     RETURN FALSE, m_msg
  END IF

  #--# Verifica se é uma AD Fatura #--#
  IF lr_ad_mestre.ies_fatura <> "N"  THEN
     LET m_msg = "AD Fatura nao pode ser modificada."
     RETURN FALSE, m_msg
  END IF

  #--# Verifica se AD está contabilizada #--#
  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM lanc_cont_cap
     WHERE cod_empresa = lr_ad_mestre.cod_empresa
       AND num_ad_ap   = lr_ad_mestre.num_ad
       AND ies_ad_ap   = "1"
       AND num_lote_lanc > 0
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     LET m_msg = "AD contabilizada não pode ser modificada."
     RETURN FALSE, m_msg
  END IF

  #--# Verifica se AD possui AP #--#
  CALL fin80027_retorna_relac_ad_ap(lr_ad_mestre.cod_empresa,'1',lr_ad_mestre.num_ad)
     RETURNING m_status, l_qtd_reg

  FOR l_cont = 1 TO l_qtd_reg

     CALL fin80027_retorna_prox_ad_ap(l_cont)
        RETURNING lr_ad_aps.cod_empresa, lr_ad_aps.ies_ad_ap, lr_ad_aps.num_ad_ap

     IF lr_ad_aps.ies_ad_ap = '2' THEN #--# AP #--#
        LET m_msg = "AD possui AP e não pode ser modificada."
        RETURN FALSE, m_msg
     END IF
  END FOR

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_baixa_adiantamento(l_cod_empresa, l_ies_ad_ap_mov, l_num_ad_ap_mov, l_dat_mov, lr_adiantamentos_integr)
#------------------------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa     LIKE mov_adiant.cod_empresa,
         l_ies_ad_ap_mov   LIKE mov_adiant.ies_ad_ap_mov,
         l_num_ad_ap_mov   LIKE mov_adiant.num_ad_ap_mov,
         l_dat_mov         LIKE mov_adiant.dat_mov

  DEFINE lr_adiantamentos_integr  RECORD
                                     cod_tip_val      LIKE ad_valores.cod_tip_val,
                                     valor            LIKE ad_valores.valor,
                                     num_ad_nf_orig   LIKE adiant.num_ad_nf_orig,
                                     ser_nf           LIKE adiant.ser_nf,
                                     ssr_nf           LIKE adiant.ssr_nf,
                                     cod_fornecedor   LIKE adiant.cod_fornecedor,
                                     dat_mov          LIKE mov_adiant.dat_mov,       #--# Apenas na exclusão #--#
                                     hor_mov          LIKE mov_adiant.hor_mov,       #--# Apenas na exclusão #--#
                                     num_item         LIKE dev_fornec.num_item,      #--# Opcional - Carta ao fornecedor #--#
                                     num_aviso_rec    LIKE dev_fornec.num_aviso_rec, #--# Opcional - Carta ao fornecedor #--#
                                     num_seq          LIKE dev_fornec.num_seq        #--# Opcional - Carta ao fornecedor #--#
                                  END RECORD

  DEFINE lr_adiant     RECORD LIKE adiant.*,
         lr_mov_adiant RECORD LIKE mov_adiant.*

  DEFINE l_cod_empresa_orig LIKE nf_sup.cod_empresa

  DEFINE l_nf_deb_devolucao LIKE cap_relc_adto_cart.nf_deb_devolucao,
         l_ser_nf_deb_dev   LIKE cap_relc_adto_cart.ser_nf_deb_dev,
         l_subserie_deb_dev LIKE cap_relc_adto_cart.subserie_deb_dev,
         l_fornec_deb_dev   LIKE cap_relc_adto_cart.fornec_deb_dev

  DEFINE l_num_nf           LIKE ad_mestre.num_nf

  DEFINE l_ies_ad_nf        CHAR(02)

  WHENEVER ERROR CONTINUE
    SELECT *
      INTO lr_adiant.*
      FROM adiant
     WHERE cod_empresa    = l_cod_empresa
       AND cod_fornecedor = lr_adiantamentos_integr.cod_fornecedor
       AND num_ad_nf_orig = lr_adiantamentos_integr.num_ad_nf_orig
       AND ser_nf         = lr_adiantamentos_integr.ser_nf
       AND ssr_nf         = lr_adiantamentos_integr.ssr_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Adiantamento não encontrado!'
  END IF

  LET lr_adiant.val_saldo_adiant = lr_adiant.val_saldo_adiant - lr_adiantamentos_integr.valor

  #--# Atualiza valor do adiantamento #--#
  WHENEVER ERROR CONTINUE
    UPDATE adiant
       SET val_saldo_adiant = lr_adiant.val_saldo_adiant
     WHERE cod_fornecedor   = lr_adiant.cod_fornecedor
       AND cod_empresa      = lr_adiant.cod_empresa
       AND num_ad_nf_orig   = lr_adiant.num_ad_nf_orig
       AND ser_nf           = lr_adiant.ser_nf
       AND ssr_nf           = lr_adiant.ssr_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do saldo do adiantamento!'
  END IF

  LET lr_mov_adiant.cod_empresa     = l_cod_empresa
  LET lr_mov_adiant.dat_mov         = l_dat_mov
  LET lr_mov_adiant.ies_ent_bx      = 'B'
  LET lr_mov_adiant.cod_fornecedor  = lr_adiant.cod_fornecedor
  LET lr_mov_adiant.num_ad_nf_orig  = lr_adiant.num_ad_nf_orig
  LET lr_mov_adiant.ser_nf          = lr_adiant.ser_nf
  LET lr_mov_adiant.ssr_nf          = lr_adiant.ssr_nf
  LET lr_mov_adiant.val_mov         = lr_adiantamentos_integr.valor
  LET lr_mov_adiant.val_saldo_novo  = lr_adiant.val_saldo_adiant
  LET lr_mov_adiant.ies_ad_ap_mov   = l_ies_ad_ap_mov
  LET lr_mov_adiant.num_ad_ap_mov   = l_num_ad_ap_mov
  LET lr_mov_adiant.cod_tip_val_mov = lr_adiantamentos_integr.cod_tip_val
  LET lr_mov_adiant.hor_mov         = CURRENT HOUR TO SECOND

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM adiant
     WHERE cod_empresa    = lr_adiant.cod_empresa
       AND num_ad_nf_orig = lr_adiant.num_ad_nf_orig
       AND ser_nf         = lr_adiant.ser_nf
       AND ssr_nf         = lr_adiant.ssr_nf
       AND cod_fornecedor = lr_adiant.cod_fornecedor
       AND (ies_forn_div   = "V"
         OR ies_forn_div   = "E")
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET l_ies_ad_nf = "NF"
  ELSE
     LET l_ies_ad_nf = "AD"
  END IF

  IF l_ies_ad_nf = "AD" THEN
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM mov_adiant
        WHERE cod_empresa    = lr_mov_adiant.cod_empresa
          AND num_ad_nf_orig = lr_mov_adiant.num_ad_nf_orig
          AND ies_ent_bx     = 'E'
          AND ies_ad_ap_mov <> '3'
          AND cod_fornecedor = lr_mov_adiant.cod_fornecedor
     WHENEVER ERROR STOP
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM mov_adiant
        WHERE cod_empresa    = lr_mov_adiant.cod_empresa
          AND num_ad_nf_orig = lr_mov_adiant.num_ad_nf_orig
          AND ies_ent_bx     = 'E'
          AND cod_fornecedor = lr_mov_adiant.cod_fornecedor
     WHENEVER ERROR STOP
  END IF

  IF sqlca.sqlcode <> NOTFOUND THEN
     WHENEVER ERROR CONTINUE
       INSERT INTO mov_adiant (cod_empresa,
                               dat_mov,
                               ies_ent_bx,
                               cod_fornecedor,
                               num_ad_nf_orig,
                               ser_nf,
                               ssr_nf,
                               val_mov,
                               val_saldo_novo,
                               ies_ad_ap_mov,
                               num_ad_ap_mov,
                               cod_tip_val_mov,
                               hor_mov)
                        VALUES(lr_mov_adiant.cod_empresa,
                               lr_mov_adiant.dat_mov,
                               lr_mov_adiant.ies_ent_bx,
                               lr_mov_adiant.cod_fornecedor,
                               lr_mov_adiant.num_ad_nf_orig,
                               lr_mov_adiant.ser_nf,
                               lr_mov_adiant.ssr_nf,
                               lr_mov_adiant.val_mov,
                               lr_mov_adiant.val_saldo_novo,
                               lr_mov_adiant.ies_ad_ap_mov,
                               lr_mov_adiant.num_ad_ap_mov,
                               lr_mov_adiant.cod_tip_val_mov,
                               lr_mov_adiant.hor_mov)
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        IF ((lr_adiant.ies_forn_div = "E") OR (lr_adiant.ies_forn_div = "V")) THEN

           LET lr_mov_adiant.ser_nf = 'W'

           WHENEVER ERROR CONTINUE
             INSERT INTO cap_mov_adto_compl (empresa,
                                             ad_nota_fiscal,
                                             serie_nota_fiscal,
                                             subserie_nf,
                                             fornecedor,
                                             empresa_compl,
                                             ad_nf_compl,
                                             ser_nf_compl,
                                             subserie_nf_compl,
                                             fornecedor_compl,
                                             tip_adto,
                                             ad_ap_movto,
                                             tip_ad_ap_movto)
                                      VALUES(lr_mov_adiant.cod_empresa,
                                             lr_mov_adiant.num_ad_nf_orig,
                                             lr_mov_adiant.ser_nf,
                                             lr_mov_adiant.ssr_nf,
                                             lr_mov_adiant.cod_fornecedor,
                                             lr_mov_adiant.cod_empresa,
                                             lr_mov_adiant.num_ad_nf_orig,
                                             lr_mov_adiant.ser_nf,
                                             lr_mov_adiant.ssr_nf,
                                             lr_mov_adiant.cod_fornecedor,
                                             lr_adiant.ies_forn_div,
                                             lr_mov_adiant.num_ad_ap_mov,
                                             lr_mov_adiant.ies_ad_ap_mov)
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
            RETURN FALSE, 'Problema na inclusão do movimento de baixa do adiantamento!'
          END IF

          WHENEVER ERROR CONTINUE
            INSERT INTO mov_adiant (cod_empresa,
                                    dat_mov,
                                    ies_ent_bx,
                                    cod_fornecedor,
                                    num_ad_nf_orig,
                                    ser_nf,
                                    ssr_nf,
                                    val_mov,
                                    val_saldo_novo,
                                    ies_ad_ap_mov,
                                    num_ad_ap_mov,
                                    cod_tip_val_mov,
                                    hor_mov)
                             VALUES(lr_mov_adiant.cod_empresa,
                                    lr_mov_adiant.dat_mov,
                                    lr_mov_adiant.ies_ent_bx,
                                    lr_mov_adiant.cod_fornecedor,
                                    lr_mov_adiant.num_ad_nf_orig,
                                    lr_mov_adiant.ser_nf,
                                    lr_mov_adiant.ssr_nf,
                                    lr_mov_adiant.val_mov,
                                    lr_mov_adiant.val_saldo_novo,
                                    lr_mov_adiant.ies_ad_ap_mov,
                                    lr_mov_adiant.num_ad_ap_mov,
                                    lr_mov_adiant.cod_tip_val_mov,
                                    lr_mov_adiant.hor_mov)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
             RETURN FALSE, 'Problema na inclusão do movimento de baixa do adiantamento!'
           END IF

           #--# Atualiza série do adiantamento #--#
           WHENEVER ERROR CONTINUE
             UPDATE adiant
                SET ser_nf           = lr_mov_adiant.ser_nf
              WHERE cod_fornecedor   = lr_adiant.cod_fornecedor
                AND cod_empresa      = lr_adiant.cod_empresa
                AND num_ad_nf_orig   = lr_adiant.num_ad_nf_orig
                AND ser_nf           = lr_adiant.ser_nf
                AND ssr_nf           = lr_adiant.ssr_nf
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              RETURN FALSE, 'Problema na atualização do saldo do adiantamento!'
           END IF
        ELSE
           RETURN FALSE, 'Problema na inclusão do movimento de baixa do adiantamento!'
        END IF
     END IF
  END IF

  IF lr_adiantamentos_integr.num_item      IS NOT NULL AND
     lr_adiantamentos_integr.num_aviso_rec IS NOT NULL AND
     lr_adiantamentos_integr.num_seq       IS NOT NULL THEN

     #--# Busca informações para gerar o registro da carta de alteração #--#
     LET l_num_nf = lr_adiant.num_ad_nf_orig

     WHENEVER ERROR CONTINUE
       SELECT cod_empresa
         INTO l_cod_empresa_orig
         FROM nf_sup
        WHERE num_nf         = l_num_nf
          AND ser_nf         = lr_adiant.ser_nf
          AND ssr_nf         = lr_adiant.ssr_nf
          AND cod_fornecedor = lr_adiant.cod_fornecedor
          AND num_aviso_rec  = lr_adiantamentos_integr.num_aviso_rec
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na inclusão do relacionamento de alteração de carta ao fornecedor (busca da nota fiscal)!'
     END IF

     IF lr_adiant.ies_forn_div = 'V' THEN

        WHENEVER ERROR CONTINUE
          SELECT num_nf,
                 ser_nf,
                 ssr_nf,
                 cod_fornecedor
            INTO l_nf_deb_devolucao,
                 l_ser_nf_deb_dev,
                 l_subserie_deb_dev,
                 l_fornec_deb_dev
            FROM dev_fornec
           WHERE cod_empresa   = l_cod_empresa_orig
             AND num_aviso_rec = lr_adiantamentos_integr.num_aviso_rec
             AND num_seq       = lr_adiantamentos_integr.num_seq
             AND num_item      = lr_adiantamentos_integr.num_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na inclusão do relacionamento de alteração de carta ao fornecedor (busca da nota de devolução)!'
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
          SELECT num_nota_debito,
                 'X',
                 '0',
                 cod_fornecedor
            INTO l_nf_deb_devolucao,
                 l_ser_nf_deb_dev,
                 l_subserie_deb_dev,
                 l_fornec_deb_dev
            FROM deb_fornec
           WHERE cod_empresa   = l_cod_empresa_orig
             AND num_aviso_rec = lr_adiantamentos_integr.num_aviso_rec
             AND num_seq       = lr_adiantamentos_integr.num_seq
             AND num_item      = lr_adiantamentos_integr.num_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na inclusão do relacionamento de alteração de carta ao fornecedor (busca da nota de devolução)!'
        END IF
     END IF

     WHENEVER ERROR CONTINUE
      INSERT INTO cap_relc_adto_cart (empresa,
                                      num_item,
                                      aviso_recebto,
                                      seq_dev_nota_deb,
                                      dev_forn_nota_deb,
                                      dat_movto,
                                      hor_movto,
                                      entrada_baixa,
                                      nf_deb_devolucao,
                                      ser_nf_deb_dev,
                                      subserie_deb_dev,
                                      fornec_deb_dev,
                                      ad_nf_origem,
                                      serie_nota_fiscal,
                                      subserie_nf,
                                      fornecedor,
                                      num_ad_ap,
                                      ad_autoriz_pagto)
                              VALUES (lr_mov_adiant.cod_empresa,
                                      lr_adiantamentos_integr.num_item,
                                      lr_adiantamentos_integr.num_aviso_rec,
                                      lr_adiantamentos_integr.num_seq,
                                      lr_adiant.ies_forn_div,
                                      lr_mov_adiant.dat_mov,
                                      lr_mov_adiant.hor_mov,
                                      lr_mov_adiant.ies_ent_bx,
                                      l_nf_deb_devolucao,
                                      l_ser_nf_deb_dev,
                                      l_subserie_deb_dev,
                                      l_fornec_deb_dev,
                                      lr_mov_adiant.num_ad_nf_orig,
                                      lr_mov_adiant.ser_nf,
                                      lr_mov_adiant.ssr_nf,
                                      lr_mov_adiant.cod_fornecedor,
                                      lr_mov_adiant.num_ad_ap_mov,
                                      '2')
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> -206 THEN
        RETURN FALSE, 'Problema na inclusão do relacionamento de alteração de carta ao fornecedor (baixa de adiantamento)!'
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#---------------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_elimina_baixa_adiantamento(l_cod_empresa, l_ies_ad_ap_mov, l_num_ad_ap_mov, lr_adiantamentos_integr)
#---------------------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa     LIKE mov_adiant.cod_empresa,
         l_ies_ad_ap_mov   LIKE mov_adiant.ies_ad_ap_mov,
         l_num_ad_ap_mov   LIKE mov_adiant.num_ad_ap_mov

  DEFINE lr_adiantamentos_integr  RECORD
                                     cod_tip_val      LIKE ad_valores.cod_tip_val,
                                     valor            LIKE ad_valores.valor,
                                     num_ad_nf_orig   LIKE adiant.num_ad_nf_orig,
                                     ser_nf           LIKE adiant.ser_nf,
                                     ssr_nf           LIKE adiant.ssr_nf,
                                     cod_fornecedor   LIKE adiant.cod_fornecedor,
                                     dat_mov          LIKE mov_adiant.dat_mov,       #--# Apenas na exclusão #--#
                                     hor_mov          LIKE mov_adiant.hor_mov,       #--# Apenas na exclusão #--#
                                     num_item         LIKE dev_fornec.num_item,      #--# Opcional - Carta ao fornecedor #--#
                                     num_aviso_rec    LIKE dev_fornec.num_aviso_rec, #--# Opcional - Carta ao fornecedor #--#
                                     num_seq          LIKE dev_fornec.num_seq        #--# Opcional - Carta ao fornecedor #--#
                                  END RECORD

  WHENEVER ERROR CONTINUE
    UPDATE adiant
       SET val_saldo_adiant = val_saldo_adiant + lr_adiantamentos_integr.valor
     WHERE cod_empresa      = l_cod_empresa
       AND num_ad_nf_orig   = lr_adiantamentos_integr.num_ad_nf_orig
       AND cod_fornecedor   = lr_adiantamentos_integr.cod_fornecedor
       AND ser_nf           = lr_adiantamentos_integr.ser_nf
       AND ssr_nf           = lr_adiantamentos_integr.ssr_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do adiantamento da baixa!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM mov_adiant
     WHERE cod_empresa     = l_cod_empresa
       AND dat_mov         = lr_adiantamentos_integr.dat_mov
       AND hor_mov         = lr_adiantamentos_integr.hor_mov
       AND ies_ent_bx      = 'B'
       AND num_ad_nf_orig  = lr_adiantamentos_integr.num_ad_nf_orig
       AND ser_nf          = lr_adiantamentos_integr.ser_nf
       AND ssr_nf          = lr_adiantamentos_integr.ssr_nf
       AND cod_fornecedor  = lr_adiantamentos_integr.cod_fornecedor
       AND num_ad_ap_mov   = l_num_ad_ap_mov
       AND val_mov         = lr_adiantamentos_integr.valor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação do movimento da baixa de adiantamento!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_mov_adto_compl
     WHERE empresa            = l_cod_empresa
       AND ad_nota_fiscal     = lr_adiantamentos_integr.num_ad_nf_orig
       AND serie_nota_fiscal  = 'W'
       AND subserie_nf        = lr_adiantamentos_integr.ssr_nf
       AND (tip_adto          = "E"
         OR tip_adto          = "V")
       AND ad_ap_movto        = l_num_ad_ap_mov
       AND tip_ad_ap_movto    = l_ies_ad_ap_mov
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação do movimento da baixa de adiantamento (movimento complementar)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_relc_adto_cart
     WHERE empresa            = l_cod_empresa
       AND entrada_baixa      = 'B'
       AND ad_nf_origem       = lr_adiantamentos_integr.num_ad_nf_orig
       AND serie_nota_fiscal  = lr_adiantamentos_integr.ser_nf
       AND subserie_nf        = lr_adiantamentos_integr.ssr_nf
       AND fornecedor         = lr_adiantamentos_integr.cod_fornecedor
       AND dat_movto          = lr_adiantamentos_integr.dat_mov
       AND hor_movto          = lr_adiantamentos_integr.hor_mov
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação do movimento da baixa de adiantamento (Itens alteração de carta ao fornecedor)!'
  END IF

  #--# Recalcula os saldos das outras movimentações #--#
  CALL fin80030_recalcula_saldo_outras_mov_adiant(l_cod_empresa,
                                                  lr_adiantamentos_integr.num_ad_nf_orig,
                                                  lr_adiantamentos_integr.cod_fornecedor,
                                                  lr_adiantamentos_integr.ser_nf,
                                                  lr_adiantamentos_integr.ssr_nf)
  RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_recalcula_saldo_outras_mov_adiant(l_cod_empresa,    l_num_ad_nf_orig,       l_cod_fornecedor,
                                                     l_ser_nf,         l_ssr_nf)
#--------------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa    LIKE mov_adiant.cod_empresa,
         l_num_ad_nf_orig LIKE mov_adiant.num_ad_nf_orig,
         l_cod_fornecedor LIKE mov_adiant.cod_fornecedor,
         l_ser_nf         LIKE mov_adiant.ser_nf,
         l_ssr_nf         LIKE mov_adiant.ssr_nf

  DEFINE lr_mov_adiant RECORD LIKE mov_adiant.*

  DEFINE l_saldo_orig  LIKE mov_adiant.val_mov

  #--# Recalcula os saldos das outras movimentações #--#
  WHENEVER ERROR CONTINUE
   DECLARE cq_recalc_mov_adiant CURSOR FOR
    SELECT *
      FROM mov_adiant
     WHERE cod_empresa    = l_cod_empresa
       AND num_ad_nf_orig = l_num_ad_nf_orig
       AND cod_fornecedor = l_cod_fornecedor
       AND ser_nf         = l_ser_nf
       AND ssr_nf         = l_ssr_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema no recálculo das movimentações do adiantamento (relacionado ao adiantamento eliminado)!'
  END IF

  LET l_saldo_orig = 0

  WHENEVER ERROR CONTINUE
   FOREACH cq_recalc_mov_adiant INTO lr_mov_adiant.*
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema no recálculo das movimentações do adiantamento (relacionado ao adiantamento eliminado)!'
      END IF

      IF lr_mov_adiant.ies_ent_bx = "E"  THEN
         LET l_saldo_orig = l_saldo_orig + lr_mov_adiant.val_mov
         CONTINUE FOREACH
      ELSE
         LET l_saldo_orig = l_saldo_orig - lr_mov_adiant.val_mov
      END IF

      WHENEVER ERROR CONTINUE
       UPDATE mov_adiant
          SET val_saldo_novo = l_saldo_orig
        WHERE mov_adiant.cod_empresa        = lr_mov_adiant.cod_empresa
          AND mov_adiant.dat_mov            = lr_mov_adiant.dat_mov
          AND mov_adiant.ies_ent_bx         = lr_mov_adiant.ies_ent_bx
          AND mov_adiant.num_ad_nf_orig     = lr_mov_adiant.num_ad_nf_orig
          AND mov_adiant.cod_fornecedor     = lr_mov_adiant.cod_fornecedor
          AND mov_adiant.ser_nf             = lr_mov_adiant.ser_nf
          AND mov_adiant.ssr_nf             = lr_mov_adiant.ssr_nf
          AND mov_adiant.ies_ad_ap_mov      = lr_mov_adiant.ies_ad_ap_mov
          AND mov_adiant.num_ad_ap_mov      = lr_mov_adiant.num_ad_ap_mov
          AND mov_adiant.hor_mov            = lr_mov_adiant.hor_mov
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema no recálculo das movimentações do adiantamento (relacionado ao adiantamento eliminado)!'
      END IF

      WHENEVER ERROR CONTINUE
   END FOREACH
   FREE cq_recalc_mov_adiant
  WHENEVER ERROR STOP

  RETURN TRUE, ' '

END FUNCTION

#---------------------------------------------------#
 FUNCTION fin80030_cotacao(l_cod_moeda, l_dat_rec_nf)
#---------------------------------------------------#

  DEFINE l_cod_moeda   LIKE ad_mestre.cod_moeda,
         l_dat_rec_nf  LIKE ad_mestre.dat_rec_nf

  DEFINE l_val_cotacao     LIKE ad_corr.val_cotacao

  WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO l_val_cotacao
      FROM cotacao
     WHERE cod_moeda  =  l_cod_moeda
       AND dat_ref    =  l_dat_rec_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_val_cotacao = 0
  END IF

  RETURN l_val_cotacao

END FUNCTION

#------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_empresa(l_cod_empresa)
#------------------------------------------------------#

  DEFINE l_cod_empresa LIKE empresa.cod_empresa

  DEFINE l_den_empresa CHAR(36)

  #--# Busca a descrição da empresa #--#
  IF logm2_empresa_leitura(l_cod_empresa,TRUE,TRUE) THEN
     LET l_den_empresa = logm2_empresa_get_den_empresa()
  ELSE
     LET l_den_empresa = ' '
     RETURN FALSE, "Empresa não cadastrada!", ' '
  END IF

  RETURN TRUE, ' ', l_den_empresa

END FUNCTION

#------------------------------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_tipo_despesa(l_cod_empresa, l_cod_tip_despesa)
#------------------------------------------------------------------------------#

  DEFINE l_cod_empresa     LIKE ad_mestre.cod_empresa,
         l_cod_tip_despesa LIKE ad_mestre.cod_tip_despesa

  DEFINE l_nom_tip_despesa LIKE tipo_despesa.nom_tip_despesa

  #--# Busca a descrição do tipo de despesa #--#
  CALL capm111_tipo_despesa_leitura(l_cod_empresa, l_cod_tip_despesa,TRUE,TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     LET l_nom_tip_despesa = ' '
     RETURN FALSE, 'Tipo de despesa não cadastrado!', ' '
  ELSE
     LET l_nom_tip_despesa = capm111_tipo_despesa_get_nom_tip_despesa()
  END IF

  RETURN TRUE, ' ', l_nom_tip_despesa

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_fornecedor(l_cod_fornecedor)
#------------------------------------------------------------#

  DEFINE l_cod_fornecedor LIKE fornecedor.cod_fornecedor

  DEFINE l_raz_social     LIKE fornecedor.raz_social

  #--# Busca a descrição do fornecedor #--#
  IF NOT supm2_fornecedor_leitura(l_cod_fornecedor,TRUE,TRUE) THEN
     LET l_raz_social = ' '
     RETURN FALSE, 'Fornecedor não cadastrado!', ' '
  ELSE
     LET l_raz_social = supm2_fornecedor_get_raz_social()
  END IF

  RETURN TRUE, ' ', l_raz_social

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_portador(l_cod_portador)
#--------------------------------------------------------#

  DEFINE l_cod_portador LIKE ad_mestre.cod_portador

  DEFINE l_nom_banco    LIKE bancos.nom_banco

  #--# Não validar campo nulo #--#
  IF l_cod_portador IS NULL THEN
     RETURN TRUE, ' ', ' '
  END IF

  #--# Busca a descrição do portador #--#
  WHENEVER ERROR CONTINUE
    SELECT nom_banco
      INTO l_nom_banco
      FROM bancos
     WHERE cod_banco = l_cod_portador
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_nom_banco = ' '
     RETURN FALSE, 'Portador não cadastrado!', ' '
  END IF

  RETURN TRUE, ' ', l_nom_banco

END FUNCTION

#--------------------------------------------------#
 FUNCTION fin80030_carrega_valida_moeda(l_cod_moeda)
#--------------------------------------------------#

  DEFINE l_cod_moeda LIKE ad_mestre.cod_moeda

  DEFINE l_den_moeda LIKE moeda.den_moeda

  #--# Busca a descrição da moeda #--#
  WHENEVER ERROR CONTINUE
    SELECT den_moeda
      INTO l_den_moeda
      FROM moeda
     WHERE cod_moeda = l_cod_moeda
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_den_moeda = ' '
     RETURN FALSE, 'Moeda não cadastrada!', ' '
  END IF

  RETURN TRUE, ' ', l_den_moeda

END FUNCTION

#----------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_lote_pgto(l_cod_lote_pgto)
#----------------------------------------------------------#

  DEFINE l_cod_lote_pgto LIKE ad_mestre.cod_lote_pgto

  DEFINE l_nom_lote      LIKE lote_pagamento.nom_lote

  CALL capm88_lote_pagamento_leitura(l_cod_lote_pgto, TRUE, TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg, ' '
  ELSE
     LET l_nom_lote = capm88_lote_pagamento_get_nom_lote()
  END IF

  RETURN TRUE, ' ', l_nom_lote

END FUNCTION

#-------------------------------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_setor_aplicacao(l_cod_empresa, l_set_aplicacao)
#-------------------------------------------------------------------------------#

  DEFINE l_cod_empresa   LIKE ad_mestre.cod_empresa,
         l_set_aplicacao LIKE ad_mestre.set_aplicacao

  DEFINE l_nom_set_aplic LIKE setor_aplicacao.nom_set_aplic,
         l_log_bloqueado CHAR(01)

  #--# Não validar campo nulo #--#
  IF l_set_aplicacao IS NULL THEN
     RETURN TRUE, ' ', ' '
  END IF

  #--# Busca a descrição do setor de aplicação #--#
  WHENEVER ERROR CONTINUE
    SELECT nom_set_aplic,
           log_bloqueado,
      INTO l_nom_set_aplic,
           l_log_bloqueado
      FROM setor_aplicacao
     WHERE empresa       = l_cod_empresa
       AND cod_set_aplic = l_set_aplicacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_nom_set_aplic = ' '
     RETURN FALSE, 'Setor de aplicação não cadastrado!',' '
  END IF

  #--# Verifica setor de aplicação bloqueado #--#
  IF l_log_bloqueado = 'S' THEN
     RETURN FALSE, 'Setor de aplicação bloqueado!',' '
  END IF

  RETURN TRUE, ' ', l_nom_set_aplic

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION fin80030_valida_proc_exportacao(l_cod_empresa, l_num_proc_export)
#-------------------------------------------------------------------------#
  DEFINE l_cod_empresa                   CHAR(02),
         l_num_proc_export               CHAR(12),
         l_sql_stmt                      CHAR(500)

  #--# Não validar campo nulo #--#
  IF l_num_proc_export IS NULL THEN
     RETURN TRUE, ' '
  END IF

  #--# Busca parâmetro do nome do banco #--#
  CALL log2250_busca_parametro(l_cod_empresa,'nom_bas_dad_aces_tab_exp')
     RETURNING mr_parametros.nom_bas_dad_aces_tab_exp, m_status
  IF mr_parametros.nom_bas_dad_aces_tab_exp IS NULL OR m_status = FALSE THEN
     INITIALIZE mr_parametros.nom_bas_dad_aces_tab_exp TO NULL
  END IF

  #--# Valida valor informado em tela #--#
  LET l_sql_stmt = "SELECT cod_empresa",
                    " FROM  " , mr_parametros.nom_bas_dad_aces_tab_exp

  CASE g_tipo_sgbd
     WHEN "MSV" LET l_sql_stmt = l_sql_stmt CLIPPED, ".dbo.lk_processos_dad"
     WHEN "IFX" LET l_sql_stmt = l_sql_stmt CLIPPED, ":lk_processos_dad"
     WHEN "ORA" LET l_sql_stmt = l_sql_stmt CLIPPED, ".lk_processos_dad"
  END CASE

  LET l_sql_stmt = l_sql_stmt CLIPPED, " WHERE cod_empresa       = '", l_cod_empresa CLIPPED, "'",
                                       "   AND num_fatura_export = '", l_num_proc_export CLIPPED , "'"

  WHENEVER ERROR CONTINUE
   PREPARE var_exportacao FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na busca das informações fatura de exportação!'
  END IF

  WHENEVER ERROR CONTINUE
   EXECUTE var_exportacao
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode = 100 THEN
        RETURN FALSE, 'Fatura de exportação não cadastrada!'
     END IF

     RETURN FALSE, 'Problema na validação do Processo exportação! '
  END IF

  WHENEVER ERROR CONTINUE
      FREE var_exportacao
  WHENEVER ERROR STOP

  RETURN TRUE , ' '

END FUNCTION

#-----------------------------------------------------#
 FUNCTION fin80030_carrega_valida_tipo_ad(l_cod_tip_ad)
#-----------------------------------------------------#

  DEFINE l_cod_tip_ad  LIKE ad_mestre.cod_tip_ad

  DEFINE l_denominacao LIKE tipo_ad.denominacao

  #--# Busca a descrição do tipo ad #--#
  WHENEVER ERROR CONTINUE
    SELECT denominacao
      INTO l_denominacao
      FROM tipo_ad
     WHERE cod_tip_ad = l_cod_tip_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     LET l_denominacao = ' '
     RETURN FALSE, 'Tipo de AD não cadastrado!',' '
  END IF

  RETURN TRUE, ' ', l_denominacao

END FUNCTION

#---------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_condicao_pgto(l_cnd_pgto)
#---------------------------------------------------------#

  DEFINE l_cnd_pgto LIKE ad_mestre.cnd_pgto

  DEFINE l_des_cnd_pgto LIKE cond_pgto_cap.des_cnd_pgto

  #--# Não validar campo nulo #--#
  IF l_cnd_pgto IS NULL THEN
     RETURN TRUE, ' ', ' '
  END IF

  #--# Busca a descrição da condição de pagamento #--#
  CALL capm90_cond_pgto_cap_leitura(l_cnd_pgto, TRUE, TRUE)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg, ' '
  ELSE
     LET l_des_cnd_pgto = capm90_cond_pgto_cap_get_des_cnd_pgto()
  END IF

  RETURN TRUE, ' ', l_des_cnd_pgto

END FUNCTION

#------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_valida_valor_ad_contra_valor_pedido(l_cod_empresa_orig, l_num_ord_forn, l_val_tot_nf)
#------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa_orig LIKE ad_mestre.cod_empresa_orig,
         l_num_ord_forn     LIKE ad_mestre.num_ord_forn,
         l_val_tot_nf       LIKE ad_mestre.val_tot_nf

  DEFINE l_val_tot_ped       DECIMAL(15,2)
  DEFINE l_val_tot_ped_1     DECIMAL(15,2)
  DEFINE l_val_tot_ped_2     DECIMAL(15,2)

  LET l_val_tot_ped   = 0
  LET l_val_tot_ped_1 = 0
  LET l_val_tot_ped_2 = 0

  WHENEVER ERROR CONTINUE
    SELECT SUM(qtd_solic*pre_unit_oc*(pct_ipi/100+1))
      INTO l_val_tot_ped_1
      FROM ordem_sup
     WHERE ordem_sup.cod_empresa      = l_cod_empresa_orig
       AND ordem_sup.num_pedido       = l_num_ord_forn
       AND ordem_sup.ies_versao_atual = "S"
       AND ordem_sup.qtd_solic        > 0
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_val_tot_ped_1 = 0
  END IF

  WHENEVER ERROR CONTINUE
    SELECT SUM(1*pre_unit_oc*(pct_ipi/100+1))
      INTO l_val_tot_ped_2
      FROM ordem_sup
     WHERE ordem_sup.cod_empresa      = l_cod_empresa_orig
       AND ordem_sup.num_pedido       = l_num_ord_forn
       AND ordem_sup.ies_versao_atual = "S"
       AND ordem_sup.qtd_solic        = 0
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_val_tot_ped_2 = 0
  END IF

  LET l_val_tot_ped = l_val_tot_ped_1 + l_val_tot_ped_2

  IF l_val_tot_ped < l_val_tot_nf  THEN
     RETURN FALSE, ' Valor da AD de adiantamento não pode ser maior que o valor do pedido de compra!'
  END IF

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------------------------------------------------------#
 FUNCTION fin80030_carrega_valida_num_ord_forn(l_cod_empresa, l_cod_fornecedor, l_num_pedido)
#-------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa    LIKE ad_mestre.cod_empresa,
         l_cod_fornecedor LIKE ad_mestre.cod_fornecedor,
         l_num_pedido     LIKE pedido_sup.num_pedido

  DEFINE l_ies_situa_ped LIKE pedido_sup.ies_situa_ped

  #--# Busca situação do pedido #--#
  WHENEVER ERROR CONTINUE
    SELECT ies_situa_ped
      INTO l_ies_situa_ped
      FROM pedido_sup
     WHERE cod_empresa      = l_cod_empresa
       AND num_pedido       = l_num_pedido
       AND ies_versao_atual = "S"
       AND cod_fornecedor   = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     RETURN FALSE, 'Pedido não cadastrado para este fornecedor!'
  ELSE
     CASE l_ies_situa_ped
       WHEN  "C"
          RETURN FALSE, 'Pedido de compra cancelado. Registro de adiantamento não permitido. '
       WHEN  "L"
          RETURN FALSE, 'Pedido de compra liquidado. Registro de adiantamento nao permitido.'
     END CASE
  END IF

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_carrega_especie_ad(l_cod_empresa, l_num_ad)
#------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE l_ies_especie_nf CHAR(03)

  WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO l_ies_especie_nf
      FROM cap_par_compl
     WHERE empresa     = l_cod_empresa
       AND parametro   = 'ies_especie_nf_ad'
       AND nom_tabela  = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_ies_especie_nf = 'NF'
  END IF

  RETURN l_ies_especie_nf

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION fin80030_carrega_processo_exportacao(l_cod_empresa, l_num_ad)
#---------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad,
         l_nom_tabela  CHAR(16)

  DEFINE l_num_proc_export CHAR(03)

  LET l_nom_tabela = 'ad_mestre_' CLIPPED , l_num_ad USING '&&&&&&'

  WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO l_num_proc_export
      FROM cap_par_compl
     WHERE empresa     = l_cod_empresa
       AND parametro   = 'nr_proc_exportacao'
       AND nom_tabela  = l_nom_tabela
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE l_num_proc_export TO NULL
  END IF

  RETURN l_num_proc_export

END FUNCTION

#------------------------------------------------------------------------------------#
 FUNCTION fin80030_carrega_baixa_automatica(l_cod_empresa, l_num_ad, l_cod_fornecedor)
#------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa    LIKE ad_mestre.cod_empresa,
         l_num_ad         LIKE ad_mestre.num_ad,
         l_cod_fornecedor LIKE ad_mestre.cod_fornecedor

  DEFINE l_ies_bx_automatica LIKE adiant.ies_bx_automatica

  WHENEVER ERROR CONTINUE
    SELECT ies_bx_automatica
      INTO l_ies_bx_automatica
      FROM adiant
     WHERE cod_empresa    = l_cod_empresa
       AND num_ad_nf_orig = l_num_ad
       AND cod_fornecedor = l_cod_fornecedor
       AND ies_forn_div  <> "V"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_ies_bx_automatica = 'N'
  END IF

  RETURN l_ies_bx_automatica

END FUNCTION

#-----------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_valida_tipo_despesa_contra_tipo_fornec(l_cod_empresa, l_cod_tip_despesa, l_cod_fornecedor)
#-----------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa        LIKE ad_mestre.cod_empresa,
         l_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa,
         l_cod_fornecedor     LIKE ad_mestre.cod_fornecedor

  DEFINE l_pf_pj_fornecedor   CHAR(01),
         l_pf_pj_tipo_despesa CHAR(01)

  #--# Busca tipo de pessoa está relacionado o tipo de despesa #--#
  WHENEVER ERROR CONTINUE
    SELECT parametro_booleano
      INTO l_pf_pj_tipo_despesa
      FROM cap_par_tip_desp
     WHERE empresa      = l_cod_empresa
       AND parametro    = 'tip_despesa_pf_pj'
       AND tip_despesa  = l_cod_tip_despesa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_pf_pj_tipo_despesa = "A"
  END IF

  IF l_pf_pj_tipo_despesa <> "A" THEN

     #--# Busca tipo de pessoa está relacionado o fornecedor #--#
     WHENEVER ERROR CONTINUE
       SELECT ies_fis_juridica
         INTO l_pf_pj_fornecedor
         FROM fornecedor
        WHERE cod_fornecedor = l_cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET m_msg = 'Fornecedor: ',l_cod_fornecedor,' não cadastrado!'
        RETURN FALSE, m_msg
     END IF
     IF l_pf_pj_tipo_despesa <> l_pf_pj_fornecedor THEN
        IF l_pf_pj_fornecedor = "F" THEN
           RETURN FALSE, 'Este fornecedor é PF e o tipo de despesa é exclusivo para PJ!'
        ELSE
           RETURN FALSE, 'Este fornecedor é PJ e o tipo de despesa é exclusivo para PF!'
        END IF
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------------------------------------------#
 FUNCTION fin80030_valida_tipo_despesa_excl_sup(l_cod_empresa, l_cod_tip_despesa)
#-------------------------------------------------------------------------------#

  DEFINE l_cod_empresa        LIKE ad_mestre.cod_empresa,
         l_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa

  #--# Valida se o tipo de despesa é exclusivo do módulo de suprimentos #--#
  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_par_tip_desp
     WHERE empresa            = l_cod_empresa
       AND parametro          = 'usa_ctrl_trava_sup'
       AND tip_despesa        = l_cod_tip_despesa
       AND parametro_booleano = 'S'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN FALSE, 'Tipo de despesa exclusivo do módulo de Suprimentos.'
  END IF

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------------------------------------------------------#
 FUNCTION fin80030_valida_adiantamentos_existentes(l_cod_empresa, l_num_ad, l_cod_fornecedor)
#-------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa    LIKE ad_mestre.cod_empresa,
         l_num_ad         LIKE ad_mestre.num_ad,
         l_cod_fornecedor LIKE ad_mestre.cod_fornecedor

  DEFINE l_raiz_cgc_cpf    CHAR(11)

  #--# Busca a raiz do fornecedor #--#
  CALL fin80054_busca_raiz_fornecedor(l_cod_fornecedor)
     RETURNING l_raiz_cgc_cpf

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM mov_adiant
     WHERE cod_empresa     = l_cod_empresa
       AND num_ad_ap_mov   = l_num_ad
       AND cod_fornecedor NOT IN (SELECT fornecedor.cod_fornecedor
                                    FROM fornecedor
                                   WHERE fornecedor.num_cgc_cpf[1,11] = l_raiz_cgc_cpf)
       AND ies_ad_ap_mov   = '1'
       AND ies_ent_bx      = 'B'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE, 'AD possui baixa de adiantamento, não é permitido alterar o fornecedor. Favor eliminar a baixa e efetivar a AD para efetuar a modificação!'
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM mov_adiant
     WHERE cod_empresa    = l_cod_empresa
       AND num_ad_nf_orig = l_num_ad
       AND ies_ent_bx     = 'B'
       AND cod_fornecedor NOT IN (SELECT fornecedor.cod_fornecedor
                                    FROM fornecedor
                                   WHERE fornecedor.num_cgc_cpf[1,11] = l_raiz_cgc_cpf)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE, 'O adiantamento (gerados por esta AD) já possui baixas, não é permitido alterar o fornecedor. Favor eliminar as baixa para efetuar a modificação!'
  END IF

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------------------------------------------------------#
 FUNCTION fin80030_verifica_adiantamento_baixados(l_cod_empresa, l_num_ad, l_ser_nf, l_ssr_nf)
#--------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE adiant.cod_empresa,
         l_num_ad      LIKE adiant.num_ad_nf_orig,
         l_ser_nf      LIKE adiant.ser_nf,
         l_ssr_nf      LIKE adiant.ssr_nf

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM adiant
     WHERE cod_empresa    = l_cod_empresa
       AND num_ad_nf_orig = l_num_ad
       AND ser_nf         = l_ser_nf
       AND ssr_nf         = l_ssr_nf
       AND ies_forn_div  <> "V"
       AND ies_forn_div  <> "E"
       AND val_adiant    <> val_saldo_adiant
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------------------------------------------------------------------#
 FUNCTION fin80030_verifica_limite_inclusao_datas(l_cod_empresa, l_data_dig, l_ind_data)
#--------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE empresa.cod_empresa,
         l_data_dig    DATE,
         l_ind_data    CHAR(03)

  DEFINE l_data_limite DATE

  #--# Verifica datas conforme parâmetro #--#

  IF mr_parametros.ctr_data_incl_ad = 'S' THEN
     IF mr_parametros.limite_superior_inclusao_ads IS NOT NULL THEN
        LET l_data_limite = TODAY + mr_parametros.limite_superior_inclusao_ads UNITS DAY
        IF l_data_limite < l_data_dig THEN
           LET m_msg = "Data informada maior que limite superior de ",mr_parametros.limite_superior_inclusao_ads USING "##"
           LET m_msg = m_msg CLIPPED," dia(s)."
           RETURN FALSE, m_msg
        END IF
     END IF

     IF mr_parametros.limite_inferior_inclusao_ads IS NOT NULL THEN
       LET l_data_limite = TODAY -  mr_parametros.limite_inferior_inclusao_ads UNITS DAY
       IF l_data_limite > l_data_dig THEN
          LET m_msg = "Data informada menor que limite inferior de ",mr_parametros.limite_inferior_inclusao_ads USING "##"
          LET m_msg = m_msg CLIPPED," dia(s)."
          RETURN FALSE, m_msg
       END IF
     END IF
  END IF

  IF mr_parametros.ies_incl_dat_retro = 'N' THEN
     IF l_data_dig < TODAY THEN
        LET m_msg = "Data informada é menor que a data atual!"
        RETURN FALSE, m_msg
     END IF
  END IF

  IF l_ind_data = 'REC' THEN
     IF mr_parametros.ies_incl_dat_retro = 'N' AND mr_parametros.ctr_data_incl_ad = 'N' THEN
        IF l_data_dig <> TODAY THEN
           LET m_msg = "A Data informada é diferente da data atual."
           RETURN FALSE, m_msg
        END IF
     END IF

     IF NOT con2900_valida_periodo_sistema(l_cod_empresa,'CAP',l_data_dig) THEN
        LET m_msg = "Data anterior ao último período contábil fechado!"
        RETURN FALSE, m_msg
     END IF

     #--# Valida fechamento do contas a pagar #--#
     CALL fin80035_valida_dat_fech_cap(l_cod_empresa, l_data_dig)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#---------------------------------------------------------#
 FUNCTION fin80030_condicao_pagamento_parcelada(l_cnd_pgto)
#---------------------------------------------------------#

  DEFINE l_cnd_pgto LIKE cond_pg_item_cap.cnd_pgto

  DEFINE l_qtd_parc INTEGER

  #--# Busca a quantidade de parcelas #--#
  WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_qtd_parc
      FROM cond_pg_item_cap
     WHERE cond_pg_item_cap.cnd_pgto = l_cnd_pgto
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR l_qtd_parc IS NULL THEN
     RETURN FALSE
  ELSE
     IF l_qtd_parc > 1 THEN
        RETURN TRUE
     END IF
  END IF

  RETURN FALSE

END FUNCTION

#----------------------------------------------------------#
 FUNCTION fin80030_verifica_mes_ano_compet(l_mes_ano_compet)
#----------------------------------------------------------#

  DEFINE l_mes_ano_compet CHAR(04)

  DEFINE l_mes_compet     DECIMAL(2,0),
         l_ano_compet     DECIMAL(2,0)

  INITIALIZE l_mes_compet, l_ano_compet  TO NULL

  IF l_mes_ano_compet[4] = " "  THEN
     LET l_mes_ano_compet = "0",l_mes_ano_compet
  END IF

  LET l_mes_compet     = l_mes_ano_compet[1,2]
  LET l_ano_compet     = l_mes_ano_compet[3,4]

  IF (l_mes_compet < 1 OR l_mes_compet > 12)  THEN
     RETURN TRUE
  END IF

  IF (l_ano_compet < 0 OR l_ano_compet > 99)  THEN
     RETURN TRUE
  END IF

  RETURN FALSE

END FUNCTION

#---------------------------------------------------------#
 FUNCTION fin80030_existe_ad_historico(l_empresa,
                                       l_nota_fiscal,
                                       l_fornecedor,
                                       l_serie_nota_fiscal,
                                       l_subserie_nf)
#---------------------------------------------------------#

  DEFINE l_empresa           LIKE cap_h_ad_mestre.empresa,
         l_nota_fiscal       LIKE cap_h_ad_mestre.nota_fiscal,
         l_fornecedor        LIKE cap_h_ad_mestre.fornecedor,
         l_serie_nota_fiscal LIKE cap_h_ad_mestre.serie_nota_fiscal,
         l_subserie_nf       LIKE cap_h_ad_mestre.subserie_nf

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_h_ad_mestre
     WHERE empresa            = l_empresa
       AND nota_fiscal        = l_nota_fiscal
       AND fornecedor         = l_fornecedor
       AND serie_nota_fiscal  = l_serie_nota_fiscal
       AND subserie_nf        = l_subserie_nf
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN TRUE
  END IF

  RETURN FALSE

END FUNCTION

#----------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_inclui_deposito_cap(l_cod_empresa, l_num_ad, l_cod_tip_despesa, l_val_deposito, l_dat_deposito)
#----------------------------------------------------------------------------------------------------------------#


  DEFINE l_cod_empresa      LIKE empresa.cod_empresa,
         l_num_ad           LIKE deposito_cap.num_ad,
         l_cod_tip_despesa  LIKE ad_mestre.cod_tip_despesa,
         l_val_deposito     LIKE deposito_cap.val_deposito,
         l_dat_deposito     LIKE deposito_cap.dat_deposito

  DEFINE l_num_deposito     LIKE deposito_cap.num_deposito,
         l_cod_caixa        LIKE tipo_despesa_compl.cod_caixa

  DEFINE lr_deposito_cap    RECORD LIKE deposito_cap.*

  WHENEVER ERROR CONTINUE
    SELECT par_num
      INTO l_num_deposito
      FROM par_cap_pad
     WHERE cod_empresa     = l_cod_empresa
       AND cod_parametro   = "num_ult_dep"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Parâmetro de númeração de depósito para o contas a pagar não cadastrado!'
  ELSE
     IF sqlca.sqlcode = 0 THEN
        LET l_num_deposito = l_num_deposito + 1
        WHENEVER ERROR CONTINUE
          UPDATE par_cap_pad SET par_num   = l_num_deposito
           WHERE par_cap_pad.cod_empresa   = l_cod_empresa
             AND par_cap_pad.cod_parametro = "num_ult_dep"
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na atualização do último número de depósito para o contas a pagar!'
        END IF
     END IF
  END IF

  #--# Busca código do caixa #--#
  WHENEVER ERROR CONTINUE
    SELECT cod_caixa
      INTO l_cod_caixa
      FROM tipo_despesa_compl
     WHERE cod_empresa      = l_cod_empresa
       AND cod_tip_despesa  = l_cod_tip_despesa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na seleção do caixa relacionado ao tipo de despesa!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM deposito_cap
     WHERE cod_empresa = l_cod_empresa
       AND num_ad      = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do último número de depósito para o contas a pagar!'
  END IF

  CALL capm150_deposito_cap_set_cod_empresa(l_cod_empresa)
  CALL capm150_deposito_cap_set_num_ad(l_num_ad)
  CALL capm150_deposito_cap_set_num_deposito(l_num_deposito)
  CALL capm150_deposito_cap_set_ies_favorecido("C")
  CALL capm150_deposito_cap_set_banco_favor(l_cod_caixa)
  CALL capm150_deposito_cap_set_num_agencia_favor(NULL)
  CALL capm150_deposito_cap_set_num_conta_favor(NULL)
  CALL capm150_deposito_cap_set_val_deposito(l_val_deposito)
  CALL capm150_deposito_cap_set_dat_deposito(l_dat_deposito)

  CALL capm150_deposito_cap_inclui(TRUE,TRUE)
     RETURNING m_status
  IF NOT m_status THEN
     RETURN FALSE, 'Problema na inclusão do registro de depósito para o documento!'
  END IF

  RETURN TRUE, ' '

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION fin80030_ajusta_lib_lanc_conf_aprov_eletron(l_cod_empresa, l_num_ad)
#----------------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  WHENEVER ERROR CONTINUE
    SELECT ies_aprovado
      FROM aprov_necessaria
     WHERE cod_empresa  = l_cod_empresa
       AND num_ad       = l_num_ad
       AND ies_aprovado = "N"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN

     WHENEVER ERROR CONTINUE
       UPDATE lanc_cont_cap
          SET ies_liberad_contab = "N"
        WHERE cod_empresa = l_cod_empresa
          AND num_ad_ap   = l_num_ad
          AND ies_ad_ap   = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema ao atualizar os lançamentos da AD para não liberados conforme bloqueio da aprovação eletrônica!'
     END IF

     CALL fin80024_manutencao_ctb_lanc_ctbl_cap("M", l_cod_empresa, l_num_ad, 1, NULL)
        RETURNING m_manut_tabela, m_processa
     IF m_manut_tabela AND m_processa THEN
        WHENEVER ERROR CONTINUE
          UPDATE ctb_lanc_ctbl_cap
             SET ctb_lanc_ctbl_cap.liberado       = "N"
           WHERE ctb_lanc_ctbl_cap.empresa_origem = l_cod_empresa
             AND ctb_lanc_ctbl_cap.num_ad_ap      = l_num_ad
             AND ctb_lanc_ctbl_cap.eh_ad_ap       = '1'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema ao atualizar os lançamentos da AD para não liberados conforme bloqueio da aprovação eletrônica!'
        END IF
     ELSE
        IF NOT m_processa THEN
           RETURN FALSE, 'Problema ao atualizar os lançamentos da AD para não liberados conforme bloqueio da aprovação eletrônica!'
        END IF
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION fin80030_verifica_aprovacao_eletron(l_cod_empresa, l_num_ad)
#--------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE l_count INTEGER

  DEFINE lr_ad_aps  RECORD
                        cod_empresa       LIKE ap.cod_empresa,
                        ies_ad_ap         SMALLINT,
                        num_ad_ap         LIKE ad_mestre.num_ad
                    END RECORD

  DEFINE l_qtd_reg INTEGER,
         l_cont    INTEGER

  DEFINE l_ies_sup_cap LIKE ad_mestre.ies_sup_cap

  WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_count
      FROM aprov_necessaria
     WHERE cod_empresa  = l_cod_empresa
       AND num_ad       = l_num_ad
       AND ies_aprovado = 'N'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na contagem de aprovações da AD!'
  END IF

  IF l_count > 0 THEN

     WHENEVER ERROR CONTINUE
       SELECT ies_sup_cap
         INTO l_ies_sup_cap
         FROM ad_mestre
        WHERE cod_empresa = l_cod_empresa
          AND num_ad      = l_num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na busca da AD para atualização de aprovações pendentes!'
     END IF

     #--# Grava origem da AD #--#
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_par_compl
        WHERE empresa    = l_cod_empresa
          AND parametro  = 'ies_sup_cap_aprov'
          AND nom_tabela = l_num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação das informações de origem da AD!'
     END IF

     CALL capm11_cap_par_compl_set_nom_tabela(l_num_ad)
     CALL capm11_cap_par_compl_set_empresa(l_cod_empresa)
     CALL capm11_cap_par_compl_set_parametro("ies_sup_cap_aprov")
     CALL capm11_cap_par_compl_set_des_parametro("Origem da AD para aprovação")
     CALL capm11_cap_par_compl_set_parametro_texto(l_ies_sup_cap)

     CALL capm11_cap_par_compl_inclui(FALSE,TRUE)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF

     #--# Atualiza a AD e APs para status de bloqueio #--#
     WHENEVER ERROR CONTINUE
       UPDATE ad_mestre
          SET ies_sup_cap = "Q"
        WHERE cod_empresa = l_cod_empresa
          AND num_ad      = l_num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do bloqueio de aprovação eletrônica'
     END IF

     #--# Busca todas as ADs da AP, caso alguma delas tenha ordem de compra, não permitir alterar
     CALL fin80027_retorna_relac_ad_ap(l_cod_empresa,'1',l_num_ad)
          RETURNING m_status, l_qtd_reg

     FOR l_cont = 1 TO l_qtd_reg

        CALL fin80027_retorna_prox_ad_ap(l_cont)
           RETURNING lr_ad_aps.cod_empresa, lr_ad_aps.ies_ad_ap, lr_ad_aps.num_ad_ap

        IF lr_ad_aps.ies_ad_ap = '2' THEN #--# AP #--#
           WHENEVER ERROR CONTINUE
             UPDATE ap
                SET ies_lib_pgto_cap = "B"
              WHERE cod_empresa      = lr_ad_aps.cod_empresa
                AND num_ap           = lr_ad_aps.num_ad_ap
                AND ies_versao_atual = "S"
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              RETURN FALSE, 'Problem na atualização do indicador de liberado da AD!'
           END IF
        END IF
     END FOR
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM ad_mestre
        WHERE cod_empresa = l_cod_empresa
          AND num_ad      = l_num_ad
          AND ies_sup_cap = "Q"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        #--# Atualiza a AD e APs para status de incluída pelo CAP #--#
        WHENEVER ERROR CONTINUE
          UPDATE ad_mestre
             SET ies_sup_cap = "C"
           WHERE cod_empresa = l_cod_empresa
             AND num_ad      = l_num_ad
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problem na atualização do indicador de liberado da AD!'
        END IF
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------#
 FUNCTION fin80030_inclui_gao()
#-----------------------------#

  DEFINE l_valor_gao         LIKE ad_mestre.val_tot_nf,
         l_centro_custo      CHAR(04),
         l_dat_vencto_s_desc LIKE ap.dat_vencto_s_desc

  DEFINE l_ind               SMALLINT,
         l_ind_lan           SMALLINT,
         l_ind_aen           SMALLINT,
         l_ind_ads           SMALLINT

  DEFINE l_qtd_reg           INTEGER

  DEFINE lr_ad_aps RECORD
                       cod_empresa LIKE ap.cod_empresa,
                       ies_ad_ap   SMALLINT,
                       num_ad_ap   LIKE ad_mestre.num_ad
                   END RECORD

  #--# Não utiliza o controle do GAO #--#
  IF mr_parametros.controla_gao <> "S" THEN
     RETURN TRUE
  END IF

  #--# Verifica se registro está na tabela de exceção para o tipo de despesa #--#
  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_tdesp_ctr_gao, ad_mestre
     WHERE cod_empresa = mr_ad_mestre.cod_empresa
       AND num_ad      = mr_ad_mestre.num_ad
       AND empresa     = ad_mestre.cod_empresa
       AND tip_despesa = ad_mestre.cod_tip_despesa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  END IF

  FOR l_ind = 1 TO 500
     INITIALIZE ma_val_por_aen[l_ind].* TO NULL
  END FOR

  FOR l_ind = 1 TO 500
     INITIALIZE ma_val_por_aen_esp[l_ind].* TO NULL
  END FOR

  #--# Condição de pagamento #--#
  IF mr_parametros.usa_cond_pagto = "S" OR (mr_parametros.ies_gao_contabilizacao = 'S'AND mr_tipo_despesa.ies_quando_contab = 'B')THEN

     #--# Busca todas as APs relacionadas a AD #--#
     CALL fin80027_retorna_relac_ad_ap(mr_ad_mestre.cod_empresa, '1', mr_ad_mestre.num_ad)
        RETURNING m_status, l_qtd_reg

     FOR l_ind_ads = 1 TO l_qtd_reg

        CALL fin80027_retorna_prox_ad_ap(l_ind_ads)
           RETURNING lr_ad_aps.cod_empresa, lr_ad_aps.ies_ad_ap, lr_ad_aps.num_ad_ap

        IF lr_ad_aps.ies_ad_ap = '2' THEN #--# AP #--#

           #--# Busca a data de vencimento relacionada a AP #--#
           WHENEVER ERROR CONTINUE
             SELECT dat_vencto_s_desc
               INTO l_dat_vencto_s_desc
               FROM ap
              WHERE cod_empresa      = lr_ad_aps.cod_empresa
                AND num_ap           = lr_ad_aps.num_ad_ap
                AND ies_versao_atual = 'S'
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN

              #--# Integra com o GAO utilizando condição de pagamento #--#
              IF NOT fin80134_recalcula_orcamento_gao(lr_ad_aps.cod_empresa,
                                                      lr_ad_aps.num_ad_ap,
                                                      l_dat_vencto_s_desc,
                                                      l_dat_vencto_s_desc,
                                                      "FIN30058",
                                                      "IN") THEN
                 RETURN FALSE
              END IF
           END IF
        END IF
     END FOR
  ELSE
     FOR l_ind_lan = 1 TO 500
        IF ma_lanc_cont_cap_integr[l_ind_lan].ies_tipo_lanc IS NULL THEN
           EXIT FOR
        END IF

        #--# Não verificar lançamentos de crédito #--#
        IF ma_lanc_cont_cap_integr[l_ind_lan].ies_tipo_lanc <> 'D' THEN
           CONTINUE FOR
        END IF

        #--# Carrega informações de AEN em relação a conta #--#
        IF NOT fin80030_carrega_aen_gao(mr_ad_mestre.cod_empresa, mr_ad_mestre.num_ad, ma_lanc_cont_cap_integr[l_ind_lan].num_conta_cont) THEN
           RETURN FALSE
        END IF

        LET l_centro_custo = 0

        #--# Carrega centro de custo conforme parâmetro #--#
        IF mr_parametros.orcamento_periodo = "N" THEN
           LET l_centro_custo = ma_lanc_cont_cap_integr[l_ind_lan].num_conta_cont[1,4]
        END IF

        #--# Busca todos os registros de AEN #--#
        FOR l_ind_aen = 1 TO 500

           #--# Utiliza AEN simples #--#
           IF mr_parametros.ies_area_linha_neg = "S" THEN
              IF ma_val_por_aen[l_ind_aen].perc_val IS NULL THEN
                 EXIT FOR
              END IF
              LET l_valor_gao = ma_lanc_cont_cap_integr[l_ind_lan].val_lanc * ma_val_por_aen[l_ind_aen].perc_val
           END IF

           #--# Utiliza AEN Especial #--#
           IF mr_parametros.ies_area_linha_neg = "E" THEN
              IF ma_val_por_aen_esp[l_ind_aen].val_aen IS NULL THEN
                 EXIT FOR
              END IF

              IF ma_val_por_aen_esp[l_ind_aen].val_aen = 0 THEN
                 LET l_valor_gao = ma_lanc_cont_cap_integr[l_ind_lan].val_lanc
              ELSE
                 LET l_valor_gao = ma_val_por_aen_esp[l_ind_aen].val_aen
              END IF

              LET ma_val_por_aen[l_ind_aen].cod_lin_prod  = ma_val_por_aen_esp[l_ind_aen].cod_lin_prod
              LET ma_val_por_aen[l_ind_aen].cod_lin_recei = ma_val_por_aen_esp[l_ind_aen].cod_lin_recei
              LET ma_val_por_aen[l_ind_aen].cod_seg_merc  = ma_val_por_aen_esp[l_ind_aen].cod_seg_merc
              LET ma_val_por_aen[l_ind_aen].cod_cla_uso   = ma_val_por_aen_esp[l_ind_aen].cod_cla_uso
           END IF

           #--# Não utiliza AEN #--#
           IF mr_parametros.ies_area_linha_neg = "N" THEN
              LET l_valor_gao = ma_lanc_cont_cap_integr[l_ind_lan].val_lanc
           END IF

           #--# Integra com o GAO #--#
           IF NOT gao10001_verifica_saldo_conta("IN",
                                                ma_lanc_cont_cap_integr[l_ind_lan].num_conta_cont,
                                                l_centro_custo,
                                                " ",
                                                mr_ad_mestre.num_ad,
                                                '1',
                                                ma_lanc_cont_cap_integr[l_ind_lan].dat_lanc,
                                                l_valor_gao,
                                                "FIN30058",
                                                ma_val_por_aen[l_ind_aen].cod_lin_prod,
                                                ma_val_por_aen[l_ind_aen].cod_lin_recei,
                                                ma_val_por_aen[l_ind_aen].cod_seg_merc,
                                                ma_val_por_aen[l_ind_aen].cod_cla_uso) THEN
              RETURN FALSE
           END IF

           #--# Caso não utiliza AEN integra apenas uma vez (valor integral) #--#
           IF mr_parametros.ies_area_linha_neg = "N" THEN
              EXIT FOR
           END IF
        END FOR
     END FOR
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------------#
 FUNCTION fin80030_exclui_gao(l_cod_empresa, l_num_ad)
#----------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE l_centro_custo           CHAR(04),
         l_valor_gao              LIKE ad_mestre.val_tot_nf,
         l_dat_vencto_s_desc      LIKE ap.dat_vencto_s_desc,
         l_ies_quando_contab      LIKE tipo_despesa.ies_quando_contab

  DEFINE lr_lanc_cont_cap         RECORD LIKE lanc_cont_cap.*,
         lr_plano_contas          RECORD LIKE plano_contas.*

  DEFINE l_ind                    SMALLINT,
         l_ind_ads                SMALLINT,
         l_ind_aen                SMALLINT,
         l_qtd_reg                INTEGER

  DEFINE lr_ad_aps RECORD
                       cod_empresa LIKE ap.cod_empresa,
                       ies_ad_ap   SMALLINT,
                       num_ad_ap   LIKE ad_mestre.num_ad
                   END RECORD

  #--# Não utiliza o controle do GAO #--#
  IF mr_parametros.controla_gao <> "S" THEN
     RETURN TRUE
  END IF

  #--# Verifica se registro está na tabela de exceção para o tipo de despesa #--#
  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_tdesp_ctr_gao, ad_mestre
     WHERE cod_empresa = l_cod_empresa
       AND num_ad      = l_num_ad
       AND empresa     = ad_mestre.cod_empresa
       AND tip_despesa = ad_mestre.cod_tip_despesa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  END IF

  #--# Verifica quando contabiliza o tipo de despesa da AD #--#
  IF fin30027_verif_quando_contabilz(l_cod_empresa, '1', l_num_ad) THEN
     LET l_ies_quando_contab = 'B'
  END IF

  FOR l_ind = 1 TO 500
     INITIALIZE ma_val_por_aen[l_ind].* TO NULL
  END FOR

  FOR l_ind = 1 TO 500
     INITIALIZE ma_val_por_aen_esp[l_ind].* TO NULL
  END FOR

  #--# Condição de pagamento #--#
  IF mr_parametros.usa_cond_pagto = "S" OR (mr_parametros.ies_gao_contabilizacao = 'S'AND l_ies_quando_contab = 'B')THEN

     #--# Busca todas as APs relacionadas a AD #--#
     CALL fin80027_retorna_relac_ad_ap(l_cod_empresa, '1',l_num_ad)
        RETURNING m_status, l_qtd_reg

     FOR l_ind_ads = 1 TO l_qtd_reg

        CALL fin80027_retorna_prox_ad_ap(l_ind_ads)
           RETURNING lr_ad_aps.cod_empresa, lr_ad_aps.ies_ad_ap, lr_ad_aps.num_ad_ap

        IF lr_ad_aps.ies_ad_ap = '2' THEN #--# AP #--#

           #--# Busca a data de vencimento relacionada a AP #--#
           WHENEVER ERROR CONTINUE
             SELECT dat_vencto_s_desc
               INTO l_dat_vencto_s_desc
               FROM ap
              WHERE cod_empresa      = lr_ad_aps.cod_empresa
                AND num_ap           = lr_ad_aps.num_ad_ap
                AND ies_versao_atual = 'S'
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN

              #--# Integra com o GAO utilizando condição de pagamento #--#
              IF NOT fin80134_recalcula_orcamento_gao(lr_ad_aps.cod_empresa,
                                                      lr_ad_aps.num_ad_ap,
                                                      l_dat_vencto_s_desc,
                                                      l_dat_vencto_s_desc,
                                                      "FIN30058",
                                                      "EX") THEN
                 RETURN FALSE
              END IF
           END IF
        END IF
     END FOR
  ELSE
     WHENEVER ERROR CONTINUE
      DECLARE cq_ex_lanc_gao CURSOR WITH HOLD FOR
       SELECT *
         FROM lanc_cont_cap
        WHERE cod_empresa   = l_cod_empresa
          AND num_ad_ap     = l_num_ad
          AND ies_ad_ap     = '1'
          AND ies_tipo_lanc = 'D'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_ex_lanc_gao INTO lr_lanc_cont_cap.*
         IF sqlca.sqlcode <> 0 THEN
            RETURN FALSE
         END IF

         #--# Carrega informações de AEN em relação a conta #--#
         IF NOT fin80030_carrega_aen_gao(lr_lanc_cont_cap.cod_empresa, lr_lanc_cont_cap.num_ad_ap, lr_lanc_cont_cap.num_conta_cont) THEN
            RETURN FALSE
         END IF

         LET l_centro_custo = 0

         #--# Carrega centro de custo conforme parâmetro #--#
         IF mr_parametros.orcamento_periodo = "N" THEN
            LET l_centro_custo = lr_lanc_cont_cap.num_conta_cont[1,4]
         END IF

         #--# Busca todos os registros de AEN #--#
         FOR l_ind_aen = 1 TO 500

            #--# Utiliza AEN simples #--#
            IF mr_parametros.ies_area_linha_neg = "S" THEN
               IF ma_val_por_aen[l_ind_aen].perc_val IS NULL THEN
                  EXIT FOR
               END IF
               LET l_valor_gao = lr_lanc_cont_cap.val_lanc * ma_val_por_aen[l_ind_aen].perc_val
            END IF

            #--# Utiliza AEN Especial #--#
            IF mr_parametros.ies_area_linha_neg = "E" THEN
               IF ma_val_por_aen_esp[l_ind_aen].val_aen IS NULL THEN
                  EXIT FOR
               END IF

               IF ma_val_por_aen_esp[l_ind_aen].val_aen = 0 THEN
                  LET l_valor_gao = lr_lanc_cont_cap.val_lanc
               ELSE
                  LET l_valor_gao = ma_val_por_aen_esp[l_ind_aen].val_aen
               END IF

               LET ma_val_por_aen[l_ind_aen].cod_lin_prod  = ma_val_por_aen_esp[l_ind_aen].cod_lin_prod
               LET ma_val_por_aen[l_ind_aen].cod_lin_recei = ma_val_por_aen_esp[l_ind_aen].cod_lin_recei
               LET ma_val_por_aen[l_ind_aen].cod_seg_merc  = ma_val_por_aen_esp[l_ind_aen].cod_seg_merc
               LET ma_val_por_aen[l_ind_aen].cod_cla_uso   = ma_val_por_aen_esp[l_ind_aen].cod_cla_uso
            END IF

            #--# Não utiliza AEN #--#
            IF mr_parametros.ies_area_linha_neg = "N" THEN
               LET l_valor_gao = lr_lanc_cont_cap.val_lanc
            END IF

            #--# Integra com o GAO #--#
            IF NOT gao10001_verifica_saldo_conta("EX",
                                                 lr_lanc_cont_cap.num_conta_cont,
                                                 l_centro_custo,
                                                 " ",
                                                 lr_lanc_cont_cap.num_ad_ap,
                                                 lr_lanc_cont_cap.ies_ad_ap,
                                                 lr_lanc_cont_cap.dat_lanc,
                                                 l_valor_gao,
                                                 "FIN30058",
                                                 ma_val_por_aen[l_ind_aen].cod_lin_prod,
                                                 ma_val_por_aen[l_ind_aen].cod_lin_recei,
                                                 ma_val_por_aen[l_ind_aen].cod_seg_merc,
                                                 ma_val_por_aen[l_ind_aen].cod_cla_uso) THEN
               RETURN FALSE
            END IF

            #--# Caso não utiliza AEN integra apenas uma vez (valor integral) #--#
            IF mr_parametros.ies_area_linha_neg = "N" THEN
               EXIT FOR
            END IF
         END FOR

      END FOREACH
      FREE cq_ex_lanc_gao
     WHENEVER ERROR STOP
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------------------------------------------------#
 FUNCTION fin80030_carrega_aen_gao(l_cod_empresa, l_num_ad_ap, l_num_conta_cont)
#------------------------------------------------------------------------------#

  DEFINE l_cod_empresa     LIKE lanc_cont_cap.cod_empresa,
         l_num_ad_ap       LIKE lanc_cont_cap.num_ad_ap,
         l_num_conta_cont  LIKE lanc_cont_cap.num_conta_cont

  DEFINE l_sql_stmt        CHAR(3000)

  DEFINE l_val_aen         LIKE ad_aen_4.val_aen,
         l_lin_prod        LIKE ad_aen_4.cod_lin_prod,
         l_lin_recei       LIKE ad_aen_4.cod_lin_recei,
         l_seg_merc        LIKE ad_aen_4.cod_seg_merc,
         l_cla_uso         LIKE ad_aen_4.cod_cla_uso,
         l_percentual      DECIMAL(12,9),
         l_tot_percs       DECIMAL(12,9),
         l_dif_percs       DECIMAL(12,9),
         l_val_tot_nf      LIKE ad_mestre.val_tot_nf,
         l_ind             SMALLINT

  INITIALIZE ma_val_por_aen, ma_val_por_aen_esp TO NULL

  #--# Busca todas as AENs relacionadas a AD #--#
  IF mr_parametros.ies_area_linha_neg = "S" THEN

     IF mr_parametros.ies_aen_2_4 = "2" THEN
        LET l_sql_stmt = 'SELECT val_item, cod_area_negocio, cod_lin_negocio, "0", "0" ',
                         '  FROM ad_aen '
     ELSE
        LET l_sql_stmt = 'SELECT val_aen, cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso ',
                         '  FROM ad_aen_4 '
     END IF

     LET l_sql_stmt = l_sql_stmt CLIPPED, ' WHERE cod_empresa = "',l_cod_empresa,'"',
                                          '   AND num_ad      =  ',l_num_ad_ap

     WHENEVER ERROR CONTINUE
      PREPARE st_div_aen_gao FROM l_sql_stmt
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       SELECT val_tot_nf
         INTO l_val_tot_nf
         FROM ad_mestre
        WHERE cod_empresa = l_cod_empresa
          AND num_ad      = l_num_ad_ap
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_div_aen_gao CURSOR FOR st_div_aen_gao
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE
     END IF

     LET l_ind = 1

     #--# Carrega o array com os valores das AENs #--#
     WHENEVER ERROR CONTINUE
      FOREACH cq_div_aen_gao INTO l_val_aen, l_lin_prod, l_lin_recei, l_seg_merc, l_cla_uso
         IF sqlca.sqlcode <> 0 THEN
            RETURN FALSE
         END IF

         LET l_percentual = l_val_aen / l_val_tot_nf

         LET ma_val_por_aen[l_ind].perc_val      = l_percentual
         LET ma_val_por_aen[l_ind].cod_lin_prod  = l_lin_prod
         LET ma_val_por_aen[l_ind].cod_lin_recei = l_lin_recei
         LET ma_val_por_aen[l_ind].cod_seg_merc  = l_seg_merc
         LET ma_val_por_aen[l_ind].cod_cla_uso   = l_cla_uso

         LET l_ind = l_ind + 1

      END FOREACH
      FREE cq_div_aen_gao
     WHENEVER ERROR STOP

     LET l_tot_percs = 0

     #--# Calcula total do valor de AENs #--#
     FOR l_ind = 1 TO 500
        IF ma_val_por_aen[l_ind].perc_val IS NULL THEN
           EXIT FOR
        END IF

        LET l_tot_percs = l_tot_percs + ma_val_por_aen[l_ind].perc_val
     END FOR

     #--# Acerta valor percentual #--#
     IF l_tot_percs <> 1 THEN
        LET l_dif_percs = 1 - l_tot_percs
        LET ma_val_por_aen[1].perc_val = ma_val_por_aen[1].perc_val + l_dif_percs
     END IF

     #--# Caso não exista AEN, carrega um item de controle #--#
     IF ma_val_por_aen[1].perc_val IS NULL THEN
        LET ma_val_por_aen[1].perc_val      = 1
        LET ma_val_por_aen[1].cod_lin_prod  = 0
        LET ma_val_por_aen[1].cod_lin_recei = 0
        LET ma_val_por_aen[1].cod_seg_merc  = 0
        LET ma_val_por_aen[1].cod_cla_uso   = 0
     END IF
  ELSE
     IF mr_parametros.ies_area_linha_neg = "E" THEN

        IF mr_parametros.ies_aen_2_4 = "2" THEN
           LET l_sql_stmt = 'SELECT val_item, cod_area_negocio, cod_lin_negocio, "0", "0"',
                            '  FROM ad_aen_conta'
        ELSE
           LET l_sql_stmt = 'SELECT val_aen, cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso',
                            '  FROM ad_aen_conta_4'
        END IF

        LET l_sql_stmt = l_sql_stmt CLIPPED, ' WHERE cod_empresa    = "',l_cod_empresa,'"',
                                             '   AND num_ad         =  ',l_num_ad_ap,
                                             '   AND num_conta_cont = "',l_num_conta_cont,'"',
                                             '   AND ies_tipo_lanc  = "D"'

        WHENEVER ERROR CONTINUE
         PREPARE st_div_aen_cta_gao FROM l_sql_stmt
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
         DECLARE cq_aen_esp_gao CURSOR FOR st_div_aen_cta_gao
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE
        END IF

        LET l_ind = 1

        #--# Carrega o array com os valores das AENs #--#
        WHENEVER ERROR CONTINUE
         FOREACH cq_aen_esp_gao INTO l_val_aen, l_lin_prod, l_lin_recei, l_seg_merc, l_cla_uso
            IF sqlca.sqlcode <> 0 THEN
               RETURN FALSE
            END IF

            LET ma_val_por_aen_esp[l_ind].val_aen       = l_val_aen
            LET ma_val_por_aen_esp[l_ind].cod_lin_prod  = l_lin_prod
            LET ma_val_por_aen_esp[l_ind].cod_lin_recei = l_lin_recei
            LET ma_val_por_aen_esp[l_ind].cod_seg_merc  = l_seg_merc
            LET ma_val_por_aen_esp[l_ind].cod_cla_uso   = l_cla_uso

            LET l_ind = l_ind + 1

         END FOREACH
         FREE cq_aen_esp_gao
        WHENEVER ERROR STOP

        #--# Caso não exista AEN, carrega um item de controle #--#
        IF ma_val_por_aen_esp[1].val_aen IS NULL THEN
           LET ma_val_por_aen_esp[1].val_aen       = 0
           LET ma_val_por_aen_esp[1].cod_lin_prod  = 0
           LET ma_val_por_aen_esp[1].cod_lin_recei = 0
           LET ma_val_por_aen_esp[1].cod_seg_merc  = 0
           LET ma_val_por_aen_esp[1].cod_cla_uso   = 0
        END IF
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------------------------------------------------------------------#
# FUNÇÕES EXCLUSÃO DE AD                                                                                               #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------#
 FUNCTION fin80030_exclui_ad(l_cod_empresa, l_num_ad, l_consiste)
#---------------------------------------------------------------#

  DEFINE l_cod_empresa    LIKE ad_mestre.cod_empresa,
         l_num_ad         LIKE ad_mestre.num_ad

  DEFINE lr_ad_mestre      RECORD LIKE ad_mestre.*,
         lr_tipo_despesa   RECORD LIKE tipo_despesa.*,
         lr_nf_sup_aux     RECORD LIKE nf_sup_aux.*,
         lr_deposito_cap   RECORD LIKE deposito_cap.*,
         l_num_nf_dec      LIKE nf_sup.num_nf,
         l_num_aviso_rec   LIKE nf_sup.num_aviso_rec,
         l_nom_tabela      CHAR(16)

  DEFINE l_ies_sup_cap_aprov CHAR(01)

  DEFINE l_consiste CHAR(01)

  #--# Busca parâmetros #--#
  CALL fin80030_busca_parametros(l_cod_empresa)

  #--# Busca dados AD #--#
  WHENEVER ERROR CONTINUE
    SELECT *
      INTO lr_ad_mestre.*
      FROM ad_mestre
     WHERE cod_empresa = l_cod_empresa
       AND num_ad      = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_msg = 'Problema na busca de informações da AD ',l_num_ad
     RETURN FALSE, m_msg
  END IF

  #--# Busca dados do tipo de despesa #--#
  WHENEVER ERROR CONTINUE
    SELECT *
      INTO lr_tipo_despesa.*
      FROM tipo_despesa
     WHERE cod_empresa     = lr_ad_mestre.cod_empresa
       AND cod_tip_despesa = lr_ad_mestre.cod_tip_despesa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET m_msg = 'Problema na busca de informações de tipo de despesa da AD ',lr_ad_mestre.cod_tip_despesa
     RETURN FALSE, m_msg
  END IF

  IF l_consiste = 'S' THEN

     #--# Verifica se é AD de mútuo #--#
     IF lr_ad_mestre.ies_sup_cap = "M" THEN
        RETURN FALSE, ' AD incluída pelo processo de mútuo. Não pode ser excluída.'
     END IF

     #--# Verifica se é AD de contrato de permuta #--#
     IF fin80030_tipo_ad_permuta('E', lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad, lr_ad_mestre.cod_tip_ad) THEN
        RETURN FALSE, ' Não é possível excluir ADs do tipo permuta. Utilize o processo de cancelamento de permuta CRE01205!'
     END IF

     #--# Verifica data de fechamento CAP #--#
     CALL fin80035_valida_dat_fech_cap(lr_ad_mestre.cod_empresa, lr_ad_mestre.dat_rec_nf)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF

     #--# Específico #--#
     IF find4GLFunction('rhuy34_permite_exclusao_ad_fgts') THEN
        IF NOT rhuy34_permite_exclusao_ad_fgts() THEN
           IF rhu0072_verifica_se_ad_pertence_fgts(lr_ad_mestre.cod_empresa,
                                                   lr_ad_mestre.num_ad) THEN
              LET m_msg = 'Não é possível excluir ADs de FGTS. Utilize o processo RHU0637.'
              RETURN FALSE, m_msg CLIPPED
           END IF
        END IF
     END IF

     #--# Verifica adiantamentos da AD #--#
     IF lr_tipo_despesa.ies_adiant = "F" OR lr_tipo_despesa.ies_adiant = "D" THEN

        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM adiant
           WHERE adiant.cod_empresa    = lr_ad_mestre.cod_empresa
             AND adiant.num_ad_nf_orig = lr_ad_mestre.num_ad
             AND adiant.ies_forn_div   <> "V"
             AND adiant.val_adiant     <> adiant.val_saldo_adiant
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET m_msg = ' Existem baixas para o adiantamento desta AD. Exclua primeiro as baixas. AD ', lr_ad_mestre.num_ad
           RETURN FALSE, m_msg
        END IF
     END IF

     #--# AD não é fatura #--#
     IF lr_ad_mestre.ies_fatura = "N"  THEN

        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM lanc_cont_cap
           WHERE cod_empresa   = lr_ad_mestre.cod_empresa
             AND num_ad_ap     = lr_ad_mestre.num_ad
             AND ies_ad_ap     = "1"
             AND num_lote_lanc > 0
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> NOTFOUND THEN
           IF mr_parametros.estorna_lanc_incluso_contab  = 'N' THEN
              LET m_msg = ' A AD nao pode ser excluida, esta contabilizada. AD: ',lr_ad_mestre.num_ad
              RETURN FALSE, m_msg
           END IF
        END IF
     END IF

     #--# Verifica se AD está relacionada a uma ad fatura #--#
     IF lr_ad_mestre.ies_fatura = "N"  THEN
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM adn_adf
           WHERE cod_empresa = lr_ad_mestre.cod_empresa
             AND num_adn     = lr_ad_mestre.num_ad
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> NOTFOUND THEN
           LET m_msg = ' Esta AD está relacionada a uma AD Fatura, exclua a AD fatura primeiramente! AD: ',lr_ad_mestre.num_ad
           RETURN FALSE, m_msg
        END IF
     END IF

     #--# Verifica se AD está relacionada a uma AP #--#
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM ad_ap
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> NOTFOUND THEN
        IF mr_parametros.estorna_lanc_incluso_contab  = 'N' THEN
           LET m_msg = ' Esta AD está relacionada a uma AP, exclua a AP primeiramente! AD: ',lr_ad_mestre.num_ad
           RETURN FALSE, m_msg
        END IF
     END IF

     WHENEVER ERROR CONTINUE
       SELECT parametro_texto
         INTO l_ies_sup_cap_aprov
         FROM cap_par_compl
        WHERE empresa          = lr_ad_mestre.cod_empresa
          AND parametro        = 'ies_sup_cap_aprov'
          AND nom_tabela       = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        RETURN FALSE, 'Problema na busca das informações de origem da AD!'
     END IF

     IF l_ies_sup_cap_aprov IS NULL THEN
        LET l_ies_sup_cap_aprov = ' '
     END IF

     #--# Problema na integração com o RHU #--#
     IF (lr_ad_mestre.ies_sup_cap = "H") OR (l_ies_sup_cap_aprov = 'H') THEN

        IF NOT rhu0072_cancelar_integracao_cap(lr_ad_mestre.cod_empresa_orig,
                                               lr_ad_mestre.num_ad,
                                               lr_ad_mestre.cod_fornecedor) THEN
           RETURN FALSE, 'Problemas na exclusao dos movimentos desta AD pelo RHU.'
        END IF
     END IF

     #--# Verifica se o documento teve origem no contas a receber #--#
     IF lr_ad_mestre.ies_sup_cap = "R" THEN
        CALL fin80030_verifica_documento_credito_vinculado(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad)
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg CLIPPED
        END IF
     END IF

     #--# Verifica se existem impostos já pagos #--#
     IF NOT fin80030_verifica_imposto_ret_recol_ja_pago(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad, lr_ad_mestre.cod_empresa_orig, lr_ad_mestre.cod_fornecedor) THEN
        RETURN FALSE, 'Há impostos Retidos/Recolh. nesta AD, já pagos. Não é permitido excluir a AD.'
     END IF

     #--# Lançamento de INSS #--#
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM lanc_cont_cap
        WHERE cod_empresa   = lr_ad_mestre.cod_empresa
          AND num_ad_ap     = lr_ad_mestre.num_ad
          AND ies_ad_ap     = "1"
          AND tex_hist_lanc = "EXTOR.LANC.,EXISTE 2o.LANC.INSS DESTE FORN.NO MES."
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> NOTFOUND THEN
        RETURN FALSE, 'Existe outro lançamento de INSS Autônomo para este fornecedor no mês. Exclua-o primeiro.'
     END IF

     #--# Verifica permissão do usuário quanto ao tipo de despesa #--#
     IF NOT fin80018_verifica_permissao_usuario_x_tipo_despesa(lr_ad_mestre.cod_empresa, lr_ad_mestre.cod_tip_despesa,"3",TRUE) THEN
        LET m_msg  = "Usuário ",p_user," não tem permissão para o tipo de despesa ",lr_ad_mestre.cod_tip_despesa,". Verificar cadastro no FIN30136."
        RETURN FALSE, m_msg
     END IF

     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM cheque_bordero, deposito_cap
        WHERE cheque_bordero.cod_empresa     = lr_ad_mestre.cod_empresa
          AND cheque_bordero.num_cheq_bord   = deposito_cap.num_deposito
          AND cheque_bordero.num_conta_banco = deposito_cap.num_conta_favor
          AND cheque_bordero.dat_emissao     = deposito_cap.dat_deposito
          AND cheque_bordero.ies_cheq_bord  <> '0'
          AND deposito_cap.cod_empresa       = lr_ad_mestre.cod_empresa
          AND deposito_cap.num_ad            = lr_ad_mestre.num_ad
          AND deposito_cap.ies_favorecido    = 'B'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> NOTFOUND THEN
        RETURN FALSE, 'AD não pode ser excluída pois o depósito bancário já foi transferido para o TRB!'
     END IF

     IF mr_dados_adic.programa_orig IS NULL OR
        mr_dados_adic.programa_orig <> 'FIN30032' THEN

        #--# Verifica se adiantamento é de transferência #--#
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM cap_ad_transf_mut
           WHERE empresa_recebto = lr_ad_mestre.cod_empresa
             AND ad_recebto      = lr_ad_mestre.num_ad
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET m_msg = 'Esta AD está relacionada a uma transferência de adiantamento. A exclusão deverá ser feita pelo programa FIN30032.'
           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  #--# Inicializa GAO #--#
  CALL gao10001_inicializa_gao()

  #--# Integra GAO #--#
  CALL fin80030_exclui_gao(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad)
     RETURNING m_status
  IF NOT m_status THEN
     RETURN FALSE, 'Problema na exclusão da integração do GAO!'
  END IF

  #--# Atualiza saldos das ADs relacionas a ADF #--#
  IF lr_ad_mestre.ies_fatura = 'F' THEN
     CALL fin80030_atualiza_ads_relac_adf(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad, lr_ad_mestre.val_saldo_ad)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Elimina e recalcula adiantamentos #--#
  CALL fin80030_elimina_baixa_adiantamento_geral(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  #--# Elimina e recalcula IR adiantamentos #--#
  IF mr_parametros.par_utiliza_irrf_adiant = 'S' THEN
     CALL fin80030_atualiza_saldo_ir_adiantameno(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad)
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  LET l_num_nf_dec = lr_ad_mestre.num_nf

  WHENEVER ERROR CONTINUE
    UPDATE frete_sup
       SET ies_incl_cap = "N"
     WHERE cod_empresa  = lr_ad_mestre.cod_empresa_orig
       AND num_conhec   = l_num_nf_dec
       AND ser_conhec   = lr_ad_mestre.ser_nf
       AND ssr_conhec   = lr_ad_mestre.ssr_nf
       AND cod_transpor = lr_ad_mestre.cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0  THEN
     RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Fretes para o Contas a Pagar!'
  END IF

  #--# Integração Fluxo de Caixa #--#
  IF mr_parametros.ies_online_fcl = "S" THEN
     #--# Inclui movimento FRETE no fluxo de caixa quando excluida AD #--#
     CALL fcl1150_integracao_frete_fcx(lr_ad_mestre.cod_empresa_orig,
                                       l_num_nf_dec,
                                       lr_ad_mestre.ser_nf,
                                       lr_ad_mestre.ssr_nf,
                                       lr_ad_mestre.cod_fornecedor,
                                       "IN")
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE nf_sup
       SET ies_incl_cap   = "N"
     WHERE cod_empresa    = lr_ad_mestre.cod_empresa_orig
       AND num_nf         = l_num_nf_dec
       AND ser_nf         = lr_ad_mestre.ser_nf
       AND ssr_nf         = lr_ad_mestre.ssr_nf
       AND cod_fornecedor = lr_ad_mestre.cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0  THEN
     RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Suprimentos para o Contas a Pagar!'
  END IF


  WHENEVER ERROR CONTINUE
    SELECT num_aviso_rec
      INTO l_num_aviso_rec
      FROM nf_sup
     WHERE nf_sup.cod_empresa    = lr_ad_mestre.cod_empresa_orig
       AND nf_sup.num_nf         = l_num_nf_dec
       AND nf_sup.ser_nf         = lr_ad_mestre.ser_nf
       AND nf_sup.ssr_nf         = lr_ad_mestre.ssr_nf
       AND nf_sup.cod_fornecedor = lr_ad_mestre.cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN

     #--# Integração Fluxo de Caixa #--#
     IF mr_parametros.ies_online_fcl = "S" THEN
        #--# Inclui movimento NF no fluxo de caixa quando excluida AD #--#
        CALL fcl1150_integracao_ar_fcx(lr_ad_mestre.cod_empresa_orig,
                                       l_num_aviso_rec,
                                       "IN")
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF
     END IF

     #--# Nota Materia Prima #--#
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM sup_par_ar
        WHERE empresa       = lr_ad_mestre.cod_empresa_orig
          AND aviso_recebto = l_num_aviso_rec
          AND parametro     = "Nf_rural"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> NOTFOUND THEN

        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM ar_entrada_mp, nf_sup_aux
           WHERE ar_entrada_mp.cod_empresa   = nf_sup_aux.cod_empresa
             AND ar_entrada_mp.num_aviso_rec = nf_sup_aux.num_aviso_rec
             AND nf_sup_aux.cod_empresa      = lr_ad_mestre.cod_empresa_orig
             AND nf_sup_aux.num_nf           = l_num_nf_dec
             AND nf_sup_aux.ser_nf           = lr_ad_mestre.ser_nf
             AND nf_sup_aux.ssr_nf           = lr_ad_mestre.ssr_nf
             AND nf_sup_aux.cod_fornecedor   = lr_ad_mestre.cod_fornecedor
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> NOTFOUND THEN

            WHENEVER ERROR CONTINUE
              SELECT *
                INTO lr_nf_sup_aux.*
                FROM nf_sup_aux
               WHERE nf_sup_aux.cod_empresa     = lr_ad_mestre.cod_empresa_orig
                 AND nf_sup_aux.num_nf          = l_num_nf_dec
                 AND nf_sup_aux.ser_nf          = lr_ad_mestre.ser_nf
                 AND nf_sup_aux.ssr_nf          = lr_ad_mestre.ssr_nf
                 AND nf_sup_aux.cod_fornecedor  = lr_ad_mestre.cod_fornecedor
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> NOTFOUND THEN

               WHENEVER ERROR CONTINUE
                UPDATE nf_sup
                   SET ies_incl_cap   = "P"
                 WHERE cod_empresa    = lr_nf_sup_aux.cod_empresa
                   AND num_nf         = lr_nf_sup_aux.num_nf
                   AND ser_nf         = lr_nf_sup_aux.ser_nf
                   AND ssr_nf         = lr_nf_sup_aux.ssr_nf
                   AND cod_fornecedor = lr_nf_sup_aux.cod_fornecedor
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0  THEN
                 RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Suprimentos para o Contas a Pagar!'
              END IF

               WHENEVER ERROR CONTINUE
                UPDATE nf_sup_aux
                   SET ies_incl_cap   = "P"
                 WHERE cod_empresa    = lr_nf_sup_aux.cod_empresa
                   AND num_nf         = lr_nf_sup_aux.num_nf
                   AND ser_nf         = lr_nf_sup_aux.ser_nf
                   AND ssr_nf         = lr_nf_sup_aux.ssr_nf
                   AND cod_fornecedor = lr_nf_sup_aux.cod_fornecedor
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0  THEN
                 RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Suprimentos para o Contas a Pagar!'
              END IF

              WHENEVER ERROR CONTINUE
                UPDATE frete_sup
                   SET ies_incl_cap = "F"
                 WHERE cod_empresa  = lr_nf_sup_aux.cod_empresa
                   AND num_conhec   = lr_nf_sup_aux.num_conhec
                   AND ser_conhec   = lr_nf_sup_aux.ser_conhec
                   AND ssr_conhec   = lr_nf_sup_aux.ssr_conhec
                   AND cod_transpor = lr_nf_sup_aux.cod_transpor
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0  THEN
                 RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Suprimentos para o Contas a Pagar!'
              END IF
           END IF
        END IF
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("fretes_recebidos") THEN
     WHENEVER ERROR CONTINUE
       UPDATE fretes_recebidos
          SET ies_incl_cap = "N",
              num_ad       = NULL
        WHERE cod_empresa  = lr_ad_mestre.cod_empresa_orig
          AND num_ad       = lr_ad_mestre.num_ad
          AND cod_armador  = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0  THEN
        RETURN FALSE, 'Problema na atualização no indicador de integração de registros de Suprimentos para o Contas a Pagar!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("cap_doc_incl_sicl") THEN
     IF lr_ad_mestre.ies_sup_cap = "X" THEN
        WHENEVER ERROR CONTINUE
          UPDATE cap_doc_incl_sicl
             SET status_movto = "F"
           WHERE empresa     = lr_ad_mestre.cod_empresa_orig
             AND apropr_desp = lr_ad_mestre.num_ad
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0  THEN
           RETURN FALSE, 'Problema na atualização no indicador de movimento (cap_doc_incl_sicl)!'
        END IF
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("docum_comis_pagas") THEN
     WHENEVER ERROR CONTINUE
       UPDATE docum_comis_pagas
          SET apropr_desp = NULL
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND apropr_desp = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0  THEN
        RETURN FALSE, 'Problema na atualização de documentos de comissões (docum_comis_pagas)!'
     END IF
  END IF

  #--# Integra carta frete #--#
  IF mr_parametros.tip_desp_carta_frete IS NOT NULL AND mr_parametros.tip_desp_carta_frete <> "9999" THEN

     IF log0150_verifica_se_tabela_existe("integ_carta_cap") THEN
        WHENEVER ERROR CONTINUE
          UPDATE integ_carta_cap
             SET num_ad        = NULL,
                 val_irrf      = NULL,
                 val_base_calc = NULL,
                 cod_tip_val   = NULL
           WHERE cod_empresa     = lr_ad_mestre.cod_empresa
             AND num_carta_frete = l_num_nf_dec
             AND num_ad          = lr_ad_mestre.num_ad
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na atualização da carta de alteração ao fornecedor (integ_carta_cap)!'
        END IF
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("fat_conh_fret_c") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM fat_conh_fret_c
        WHERE empresa       = lr_ad_mestre.cod_empresa
          AND parametro_val = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização da integração do conhecimento de frete do faturamento (fat_conh_fret_c)!'
     END IF
  END IF

  #--# Integração Fluxo de Caixa #--#
  IF mr_parametros.ies_online_fcl = "S" THEN
     CALL fcl1160_integracao_cap_fcx(lr_ad_mestre.cod_empresa,"AD", lr_ad_mestre.num_ad,"EX")
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  #--# Elimina adiantamento #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM adiant
     WHERE adiant.cod_empresa    = lr_ad_mestre.cod_empresa
       AND adiant.num_ad_nf_orig = lr_ad_mestre.num_ad
       AND adiant.ies_forn_div  <> "V"
       AND adiant.ies_forn_div  <> "E"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro adiantamento da AD. (adiant)!'
  END IF

  #--# Elimina movimentos do adiantamento #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM mov_adiant
     WHERE cod_empresa    = lr_ad_mestre.cod_empresa
       AND num_ad_nf_orig = lr_ad_mestre.num_ad
       AND ies_ad_ap_mov  = '1'
       AND ies_ent_bx     = 'E'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro adiantamento da AD. (mov_adiant)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_mestre
     WHERE ad_mestre.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_mestre.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de AD. (ad_mestre)!'
  END IF

  #--# Delete origem da AD #--#
  WHENEVER ERROR CONTINUE
    DELETE FROM cap_par_compl
     WHERE empresa    = lr_ad_mestre.cod_empresa
       AND parametro  = 'ies_sup_cap_aprov'
       AND nom_tabela = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão das informações de origem da AD!'
  END IF


   #--# Delete Processo exportação #--#
  LET l_nom_tabela = 'ad_mestre_' CLIPPED, lr_ad_mestre.num_ad  USING '&&&&&&'
  WHENEVER ERROR CONTINUE
    DELETE FROM cap_par_compl
     WHERE empresa    = lr_ad_mestre.cod_empresa
       AND parametro  = 'nr_proc_exportacao'
       AND nom_tabela = l_nom_tabela
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão das informações de origem da AD!'
  END IF

  IF log0150_verifica_se_tabela_existe("cap_ctr_inss_rhu") THEN
     WHENEVER ERROR CONTINUE
      DELETE FROM cap_ctr_inss_rhu
       WHERE empresa            = lr_ad_mestre.cod_empresa
         AND apropr_desp_gerado = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de integração do INSS / RHU. (cap_ctr_inss_rhu)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("irrf_pf_mov") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM irrf_pf_mov
        WHERE irrf_pf_mov.cod_empresa = lr_ad_mestre.cod_empresa
          AND irrf_pf_mov.num_ad_ap   = lr_ad_mestre.num_ad
          AND irrf_pf_mov.ies_ad_ap   = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de IRRF. (irrf_pf_mov)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("ad_item") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM ad_item
        WHERE ad_item.cod_empresa = lr_ad_mestre.cod_empresa
          AND ad_item.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de item da AD. (ad_item)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("obf_nf_eletr_receb") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM obf_nf_eletr_receb
        WHERE empresa            = lr_ad_mestre.cod_empresa
          AND nf_eletronica      = l_num_nf_dec
          AND fornecedor         = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de integração de nota fiscal eletrônica. (obf_nf_eletr_receb)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("ad_compl1") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM ad_compl1
        WHERE ad_compl1.cod_empresa = lr_ad_mestre.cod_empresa
          AND ad_compl1.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de AD complementar. (ad_compl1)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("conta_ad") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM conta_ad
        WHERE conta_ad.cod_empresa = lr_ad_mestre.cod_empresa
          AND conta_ad.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de conta AD. (conta_ad)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("pre_lanc") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM pre_lanc
        WHERE pre_lanc.cod_empresa = lr_ad_mestre.cod_empresa
          AND pre_lanc.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de pré-lançamento. (pre_lanc)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("recib_txt") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM recib_txt
        WHERE recib_txt.cod_empresa = lr_ad_mestre.cod_empresa
          AND recib_txt.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de recibo. (recib_txt)!'
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_ap
     WHERE ad_ap.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_ap.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de relacionamento AD/AP. (ad_ap)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM adn_adf
     WHERE adn_adf.cod_empresa = lr_ad_mestre.cod_empresa
       AND adn_adf.num_adn     = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de relacionamento AD Fatura. (adn_adf)!'
  END IF

  CALL fin80024_manutencao_ctb_lanc_ctbl_cap("E", lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad, 1, NULL)
     RETURNING m_manut_tabela, m_processa
  IF m_manut_tabela AND m_processa THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM ctb_lanc_ctbl_cap
        WHERE empresa     = lr_ad_mestre.cod_empresa
          AND num_ad_ap   = lr_ad_mestre.num_ad
          AND eh_ad_ap    = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de lançamentos. (ctb_lanc_ctbl_cap)!'
     END IF
  ELSE
     IF NOT m_processa THEN
        RETURN FALSE, 'Existem restrições para a exclusão desta AD devido a seus lançamentos contábeis!'
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM lanc_cont_cap
     WHERE lanc_cont_cap.cod_empresa = lr_ad_mestre.cod_empresa
       AND lanc_cont_cap.num_ad_ap   = lr_ad_mestre.num_ad
       AND lanc_cont_cap.ies_ad_ap   = "1"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de lançamentos. (lanc_cont_cap)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_ad_centro_custo
     WHERE empresa = lr_ad_mestre.cod_empresa
       AND num_ad  = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema ao excluir o rateio de centro de custo da AD (cap_ad_centro_custo)'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_obs_ad
     WHERE cap_obs_ad.empresa          = lr_ad_mestre.cod_empresa
       AND cap_obs_ad.apropriacao_desp = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na eliminação do registro de observação da AD. (cap_obs_ad)!'
  END IF

  CALL fin80039_manut_cap_dat_ajuste_fin('E', lr_ad_mestre.cod_empresa, '1', lr_ad_mestre.num_ad, NULL)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_valores
     WHERE ad_valores.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_valores.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de ajustes financeiros. (ad_valores)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_ad_transf_mut
     WHERE cap_ad_transf_mut.empresa_transf     = lr_ad_mestre.cod_empresa
       AND cap_ad_transf_mut.apropr_desp_transf = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de transferência de mútuo. (cap_ad_transf_mut)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM irrf_pf_pend
     WHERE irrf_pf_pend.cod_empresa = lr_ad_mestre.cod_empresa
       AND irrf_pf_pend.num_ad_ap   = lr_ad_mestre.num_ad
       AND irrf_pf_pend.ies_ad_ap   = "1"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de IRRF PF. (irrf_pf_pend)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM inss_auton
     WHERE inss_auton.cod_empresa    = lr_ad_mestre.cod_empresa
       AND inss_auton.num_ad_nf_orig = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de Rec. INSS Aut. (inss_auton)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_aen_conta
     WHERE ad_aen_conta.cod_empresa  = lr_ad_mestre.cod_empresa
       AND ad_aen_conta.num_ad       = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de AEN (ad_aen_conta)!'
  END IF

  IF log0150_verifica_se_tabela_existe("ad_corr") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM ad_corr
        WHERE ad_corr.cod_empresa = lr_ad_mestre.cod_empresa
          AND ad_corr.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de correção (ad_corr)!'
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM benefic_dirf
     WHERE benefic_dirf.cod_empresa    = lr_ad_mestre.cod_empresa
       AND benefic_dirf.num_ad_ap_orig = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de IRRF (benefic_dirf)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_aen_4
     WHERE ad_aen_4.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_aen_4.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de AEN (ad_aen_4)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_aen
     WHERE ad_aen.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_aen.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de AEN (ad_aen)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM ad_aen_conta_4
     WHERE ad_aen_conta_4.cod_empresa = lr_ad_mestre.cod_empresa
       AND ad_aen_conta_4.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de AEN (ad_aen_conta_4)!'
  END IF


  WHENEVER ERROR CONTINUE
   DECLARE cq_deposito_excl CURSOR FOR
    SELECT *
      INTO lr_deposito_cap.*
      FROM deposito_cap
     WHERE deposito_cap.cod_empresa = lr_ad_mestre.cod_empresa
       AND deposito_cap.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de depósito (deposito_cap)!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_deposito_excl INTO lr_deposito_cap.*
      IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
      END IF

      WHENEVER ERROR CONTINUE
        DELETE FROM cheque_bordero
         WHERE cheque_bordero.cod_empresa   = lr_ad_mestre.cod_empresa
           AND cheque_bordero.num_cheq_bord = lr_deposito_cap.num_deposito
           AND cheque_bordero.dat_emissao   = lr_deposito_cap.dat_deposito
           AND cheque_bordero.ies_cheq_bord = 0
        WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na exclusão do registro de pagamento do depósito (cheque_bordero)!'
      END IF
   END FOREACH
   FREE cq_deposito_excl
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
    DELETE FROM deposito_cap
     WHERE deposito_cap.cod_empresa = lr_ad_mestre.cod_empresa
       AND deposito_cap.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de depósito (deposito_cap)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM aprov_necessaria
     WHERE aprov_necessaria.cod_empresa = lr_ad_mestre.cod_empresa
       AND aprov_necessaria.num_ad      = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE, 'Problema na exclusão do registro de aprovação eletrônica (aprov_necessaria)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_msg_susp_aprov
     WHERE empresa     = lr_ad_mestre.cod_empresa
       AND apropr_desp = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE, 'Problema na exclusão do registro de aprovação eletrônica (cap_msg_susp_aprov)!'
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR
     lr_ad_mestre.ies_sup_cap = "B" THEN

     LET l_num_nf_dec = lr_ad_mestre.num_nf

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_inss_rur
        WHERE reten_inss_rur.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_inss_rur.num_ad_nf_orig = l_num_nf_dec
          AND reten_inss_rur.ser_nf         = lr_ad_mestre.ser_nf
          AND reten_inss_rur.ssr_nf         = lr_ad_mestre.ssr_nf
          AND reten_inss_rur.cod_fornecedor = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS Rural (reten_inss_rur)!'
     END IF
  ELSE

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_inss_rur
        WHERE reten_inss_rur.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_inss_rur.num_ad_nf_orig = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS Rural (reten_inss_rur)!'
     END IF
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR
     lr_ad_mestre.ies_sup_cap = "B" THEN

     LET l_num_nf_dec = lr_ad_mestre.num_nf

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_inss
        WHERE reten_inss.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_inss.num_ad_nf_orig = l_num_nf_dec
          AND reten_inss.ser_nf         = lr_ad_mestre.ser_nf
          AND reten_inss.ssr_nf         = lr_ad_mestre.ssr_nf
          AND reten_inss.cod_fornecedor = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS (reten_inss)!'
     END IF
  ELSE

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_inss
        WHERE reten_inss.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_inss.num_ad_nf_orig = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS (reten_inss)!'
     END IF
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR
     lr_ad_mestre.ies_sup_cap = "B" THEN

     LET l_num_nf_dec = lr_ad_mestre.num_nf

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_iss
        WHERE reten_iss.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_iss.num_ad_nf_orig = l_num_nf_dec
          AND reten_iss.ser_nf         = lr_ad_mestre.ser_nf
          AND reten_iss.ssr_nf         = lr_ad_mestre.ssr_nf
          AND reten_iss.cod_fornecedor = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. ISS (reten_iss)!'
     END IF
  ELSE

     WHENEVER ERROR CONTINUE
       DELETE FROM reten_iss
        WHERE reten_iss.cod_empresa    = lr_ad_mestre.cod_empresa
          AND reten_iss.num_ad_nf_orig = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. ISS (reten_iss)!'
     END IF
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR
     lr_ad_mestre.ies_sup_cap = "B" THEN

     LET l_num_nf_dec = lr_ad_mestre.num_nf

     WHENEVER ERROR CONTINUE
       DELETE FROM cap_ret_inss_auton
        WHERE empresa           = lr_ad_mestre.cod_empresa
          AND ad_nf_origem      = l_num_nf_dec
          AND serie_nota_fiscal = lr_ad_mestre.ser_nf
          AND subserie_nf       = lr_ad_mestre.ssr_nf
          AND fornecedor        = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS Aut. (cap_ret_inss_auton)!'
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_ret_inss_auton
        WHERE empresa      = lr_ad_mestre.cod_empresa
          AND ad_nf_origem = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de Ret. INSS Aut. (cap_ret_inss_auton)!'
     END IF
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR
     lr_ad_mestre.ies_sup_cap = "B" THEN

     LET l_num_nf_dec = lr_ad_mestre.num_nf

     WHENEVER ERROR CONTINUE
       DELETE FROM cap_sest_senat
        WHERE empresa           = lr_ad_mestre.cod_empresa
          AND ad_nf_origem      = l_num_nf_dec
          AND serie_nota_fiscal = lr_ad_mestre.ser_nf
          AND subserie_nf       = lr_ad_mestre.ssr_nf
          AND fornecedor        = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de SEST/SENAT (cap_sest_senat)!'
     END IF
  ELSE

     WHENEVER ERROR CONTINUE
       DELETE FROM cap_sest_senat
        WHERE empresa      = lr_ad_mestre.cod_empresa
          AND ad_nf_origem = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de SEST/SENAT (cap_sest_senat)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("base_calc_irrf") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM base_calc_irrf
        WHERE base_calc_irrf.cod_empresa = lr_ad_mestre.cod_empresa
          AND base_calc_irrf.num_ad_ap   = lr_ad_mestre.num_ad
          AND base_calc_irrf.ies_ad_ap   = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de base cálculo de IRRF (base_calc_irrf)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_cof_logix") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM integ_cof_logix
        WHERE integ_cof_logix.cod_empresa = lr_ad_mestre.cod_empresa
          AND integ_cof_logix.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de integração COF (integ_cof_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_cos_logix") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM integ_cos_logix
        WHERE integ_cos_logix.cod_empresa = lr_ad_mestre.cod_empresa
          AND integ_cos_logix.num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de integração COS (integ_cos_logix)!'
     END IF
  END IF

  IF lr_ad_mestre.ies_sup_cap = "S" OR lr_ad_mestre.ies_sup_cap = "B" OR lr_ad_mestre.ies_sup_cap = "E" THEN

     WHENEVER ERROR CONTINUE
       UPDATE reten_irrf_pg
          SET num_ad      = NULL,
              cod_empresa = lr_ad_mestre.cod_empresa_orig
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do registro de IRRF (reten_irrf_pg)!'
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
       DELETE FROM reten_irrf_pg
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de IRRF (reten_irrf_pg)!'
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_cre_pis_cofins
     WHERE empresa     = lr_ad_mestre.cod_empresa
       AND apropr_desp = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de crédito PIS/COFINS (cap_cre_pis_cofins)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_adto_piscofin
     WHERE empresa          = lr_ad_mestre.cod_empresa
       AND ad_autoriz_pagto = lr_ad_mestre.num_ad
       AND tip_ad_ap        = '1'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do adiantamento de PIS/COFINS (cap_adto_piscofin)!'
  END IF

  WHENEVER ERROR CONTINUE
    DELETE FROM cap_iss_eletronico
     WHERE empresa          = lr_ad_mestre.cod_empresa
       AND ad_nota_fiscal   = lr_ad_mestre.num_ad
       AND (espc_nota_fiscal  = "AD" OR tip_doc_nf_ad  = "1")
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na exclusão do registro de ISS eletrônico (cap_iss_eletronico)!'
  END IF

  IF log0150_verifica_se_tabela_existe("cheque_colig_cap") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cheque_colig_cap
        WHERE cod_empresa        =  lr_ad_mestre.cod_empresa
          AND num_ad             =  lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na exclusão do registro de cheque coligadas (cheque_colig_cap)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("sup_adua_mestre") THEN
     IF lr_ad_mestre.ies_sup_cap = "S" OR lr_ad_mestre.ies_sup_cap = "B" THEN
        WHENEVER ERROR CONTINUE
          UPDATE sup_adua_mestre
             SET inclusao_cap = NULL
           WHERE empresa           = lr_ad_mestre.cod_empresa
             AND fornecedor        = lr_ad_mestre.cod_fornecedor
             AND nota_fiscal       = lr_ad_mestre.num_nf
             AND serie_nota_fiscal = lr_ad_mestre.ser_nf
             AND subserie_nf       = lr_ad_mestre.ssr_nf
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           RETURN FALSE, 'Problema na atualização do registro de aduaneiros (sup_adua_mestre)!'
        END IF
     END IF
  END IF

  #--# IVAI #--#
  IF find4GLFunction('finy00002_atualiza_imposto_ivai') THEN
     IF NOT finy00002_atualiza_imposto_ivai(lr_ad_mestre.*) THEN
        RETURN FALSE, 'Problema na atualização de impostos (Ivai)!'
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE inss_auton
       SET num_ad_pg_inss = NULL
     WHERE cod_empresa_proc = lr_ad_mestre.cod_empresa
       AND num_ad_pg_inss   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto INSS Aut. (inss_auton)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_ret_inss_auton
       SET ad_pagto_inss = NULL
     WHERE emp_proc_inss   = lr_ad_mestre.cod_empresa_orig
       AND ad_pagto_inss   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Aut. (cap_ret_inss_auton)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE benefic_dirf
       SET num_ad_pg_irrf = NULL
     WHERE cod_empresa_proc = lr_ad_mestre.cod_empresa_orig
       AND num_ad_pg_irrf   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Aut. (cap_ret_inss_auton)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_sest_senat
       SET apropr_desp_pagto = NULL
     WHERE emp_processamento   = lr_ad_mestre.cod_empresa_orig
       AND apropr_desp_pagto   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto SEST/SENAT. (cap_sest_senat)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_iss
       SET num_ad_pg_iss = NULL
     WHERE cod_empresa_proc   = lr_ad_mestre.cod_empresa_orig
       AND num_ad_pg_iss = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Rur. (reten_inss_rur)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_inss
       SET num_ad_pg_inss = NULL
     WHERE cod_empresa_proc = lr_ad_mestre.cod_empresa_orig
       AND num_ad_pg_inss   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret.INSS. (reten_inss)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_inss_rur
       SET num_ad_pg_inss_rur = NULL
     WHERE cod_empresa_proc   = lr_ad_mestre.cod_empresa_orig
       AND num_ad_pg_inss_rur = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Rur. (reten_inss_rur)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_iss
       SET num_ad_pg_iss = NULL
     WHERE cod_empresa_proc   = lr_ad_mestre.cod_empresa
       AND num_ad_pg_iss = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Rur. (reten_inss_rur)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_inss
       SET num_ad_pg_inss   = NULL
     WHERE cod_empresa_proc = lr_ad_mestre.cod_empresa
       AND num_ad_pg_inss   = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret.ISS. (reten_inss)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE reten_inss_rur
       SET num_ad_pg_inss_rur = NULL
     WHERE cod_empresa_proc   = lr_ad_mestre.cod_empresa
       AND num_ad_pg_inss_rur = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto Ret. INSS Rur. (reten_inss_rur)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_pis_cofins_csl
       SET ad_pagto_pis = NULL
     WHERE empresa      = lr_ad_mestre.cod_empresa
       AND ad_pagto_pis = lr_ad_mestre.num_ad
       AND versao_atual = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_pis_cofins_csl
       SET ad_pagto_cofins = NULL
     WHERE empresa         = lr_ad_mestre.cod_empresa
       AND ad_pagto_cofins = lr_ad_mestre.num_ad
       AND versao_atual    = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_pis_cofins_csl
       SET ad_pagto_csl = NULL
     WHERE empresa         = lr_ad_mestre.cod_empresa
       AND ad_pagto_csl    = lr_ad_mestre.num_ad
       AND versao_atual    = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_piscofin_prod
       SET ad_pagto_pis = NULL
     WHERE empresa         = lr_ad_mestre.cod_empresa
       AND ad_pagto_pis    = lr_ad_mestre.num_ad
       AND versao_atual    = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL Prod. (cap_piscofin_prod)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cap_piscofin_prod
       SET ad_pagto_cofins = NULL
     WHERE empresa         = lr_ad_mestre.cod_empresa
       AND ad_pagto_cofins = lr_ad_mestre.num_ad
       AND versao_atual    = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL Prod. (cap_piscofin_prod)!'
  END IF

  IF mr_parametros.cnsl_pagto_matriz = "S" OR mr_parametros.ies_cons_pg_trib = "S" THEN

     WHENEVER ERROR CONTINUE
       UPDATE cap_pis_cofins_csl
          SET ad_pagto_pis = NULL
        WHERE empresa      = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_pis = lr_ad_mestre.num_ad
          AND versao_atual = "S"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE cap_pis_cofins_csl
          SET ad_pagto_cofins = NULL
        WHERE empresa         = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_cofins = lr_ad_mestre.num_ad
          AND versao_atual    = "S"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE cap_pis_cofins_csl
          SET ad_pagto_csl = NULL
        WHERE empresa         = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_csl    = lr_ad_mestre.num_ad
          AND versao_atual    = "S"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL. (cap_pis_cofins_csl)!'
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE cap_piscofin_prod
          SET ad_pagto_pis = NULL
        WHERE empresa         = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_pis    = lr_ad_mestre.num_ad
          AND versao_atual    = "S"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL Prod. (cap_piscofin_prod)!'
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE cap_piscofin_prod
          SET ad_pagto_cofins = NULL
        WHERE empresa         = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_cofins = lr_ad_mestre.num_ad
          AND versao_atual    = "S"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do imposto PIS/COFINS/CSL Prod. (cap_piscofin_prod)!'
     END IF
  END IF

  #--# CDV #--#
  WHENEVER ERROR CONTINUE
    UPDATE cdv_relat_viagem
       SET num_ad_acer_conta = NULL
     WHERE empresa           = lr_ad_mestre.cod_empresa
       AND num_ad_acer_conta = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do registro de viagem. (cdv_relat_viagem)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cdv_adto_viagem
       SET num_ad_adto_viagem = NULL
     WHERE empresa            = lr_ad_mestre.cod_empresa
       AND num_ad_adto_viagem = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do registro de viagem. (cdv_adto_viagem)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cdv_adto_viagem
       SET num_ad_adto_pasg  = NULL,
           num_bilhete       = NULL,
           localiz_reserva   = NULL,
           dat_valid_bilhete = NULL
     WHERE empresa           = lr_ad_mestre.cod_empresa
       AND num_ad_adto_pasg  = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do registro de viagem. (cdv_adto_viagem)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cdv_adto_viagem
       SET num_ad_adto_hosped = NULL
     WHERE empresa            = lr_ad_mestre.cod_empresa
       AND num_ad_adto_hosped = lr_ad_mestre.num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do registro de viagem. (cdv_adto_viagem)!'
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE cdv_trajeto
       SET trajeto_utiliz     = "N",
           trch_transf_viagem = NULL
     WHERE empresa            = lr_ad_mestre.cod_empresa
       AND trch_transf_viagem = lr_ad_mestre.num_ad
       AND trajeto_utiliz     = "R"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do registro de viagem. (cdv_trajeto)!'
  END IF

  IF log0150_verifica_se_tabela_existe("integ_lcc_logix") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM integ_lcc_logix
        WHERE cod_empresa    = lr_ad_mestre.cod_empresa
          AND num_nf         = lr_ad_mestre.num_nf
          AND ser_nf         = lr_ad_mestre.ser_nf
          AND ssr_nf         = lr_ad_mestre.ssr_nf
          AND cod_fornecedor = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração LCC. (integ_lcc_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_orion_logix") THEN
     WHENEVER ERROR CONTINUE
       UPDATE integ_orion_logix
          SET num_ad = NULL
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do registro de integração ORION. (integ_orion_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_cos_logix") THEN
     WHENEVER ERROR CONTINUE
       UPDATE integ_cos_logix
          SET num_ad = NULL
        WHERE cod_empresa = lr_ad_mestre.cod_empresa_orig
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do registro de integração COS. (integ_cos_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("cof_ad_aen") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cof_ad_aen
        WHERE empresa           = lr_ad_mestre.cod_empresa_orig
          AND nota_fiscal       = lr_ad_mestre.num_nf
          AND serie_nota_fiscal = lr_ad_mestre.ser_nf
          AND subserie_nf       = lr_ad_mestre.ssr_nf
          AND fornecedor        = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração COF. (cof_ad_aen)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("cof_integr_logix_2") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cof_integr_logix_2
        WHERE empresa           = lr_ad_mestre.cod_empresa_orig
          AND nota_fiscal       = lr_ad_mestre.num_nf
          AND serie_nota_fiscal = lr_ad_mestre.ser_nf
          AND subserie_nf       = lr_ad_mestre.ssr_nf
          AND fornecedor        = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração COF. (cof_integr_logix_2)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_cof_logix") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM integ_cof_logix
        WHERE cod_empresa = lr_ad_mestre.cod_empresa_orig
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração COF. (integ_cof_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("lcc_ad_aen") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM lcc_ad_aen
        WHERE empresa            = lr_ad_mestre.cod_empresa_orig
          AND nota_fiscal        = lr_ad_mestre.num_nf
          AND serie_nota_fiscal  = lr_ad_mestre.ser_nf
          AND subserie_nf        = lr_ad_mestre.ssr_nf
          AND fornecedor         = lr_ad_mestre.cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração LCC. (lcc_ad_aen)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("sup_ar_imp_cana") THEN
     WHENEVER ERROR CONTINUE
       UPDATE sup_ar_imp_cana
          SET ad_pagto_imp_cana = NULL
        WHERE empresa           = lr_ad_mestre.cod_empresa_orig
          AND ad_pagto_imp_cana = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do registro de integração SUP/CANA. (sup_ar_imp_cana)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("integ_cof_logix") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM integ_cof_logix
        WHERE cod_empresa = lr_ad_mestre.cod_empresa_orig
          AND num_ad      = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de integração COF. (integ_cof_logix)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("cap_gnre_emitido") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_gnre_emitido
        WHERE empresa       = lr_ad_mestre.cod_empresa
          AND ad_pagto_gnre = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de GNRE emitido. (cap_gnre_emitido)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("cap_darf_emitido") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_darf_emitido
        WHERE empresa       = lr_ad_mestre.cod_empresa
          AND ad_pagto_darf = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de DARF emitido. (cap_darf_emitido)!'
     END IF
  END IF

  IF find4GLFunction('capy43_grava_cap_estr_adto_922') THEN
     IF NOT capy43_grava_cap_estr_adto_922(lr_ad_mestre.cod_empresa,
                                           lr_ad_mestre.cod_fornecedor,
                                           lr_ad_mestre.num_ad,
                                           lr_ad_mestre.ser_nf,
                                           lr_ad_mestre.ssr_nf,
                                           1,
                                           "CAP0220") THEN
        RETURN FALSE, 'Problema na gravação do registro de integração. (cap_estr_adto_922)!'
     END IF
  END IF

  IF log0150_verifica_se_tabela_existe("solic_adiant") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM solic_adiant
        WHERE cod_empresa = lr_ad_mestre.cod_empresa
          AND num_ad_orig = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de solicitação de adiantamento. (solic_adiant)!'
     END IF
  END IF

  IF find4GLFunction('capy72_verifica_excl_ad_prod') THEN
     IF NOT capy72_verifica_excl_ad_prod(lr_ad_mestre.cod_empresa,lr_ad_mestre.num_ad) THEN
        RETURN FALSE, 'Problema na exclusão da AD de produtor!'
     END IF
  END IF

  IF find4GLFunction('capy72_verifica_excl_ad_forn') THEN
     IF NOT capy72_verifica_excl_ad_forn(lr_ad_mestre.cod_empresa,lr_ad_mestre.num_ad) THEN
        RETURN FALSE, 'Problema na exclusão da AD de fornecedor!'
     END IF
  END IF

  #--# Verifica e exclui ads de permuta relacionadas #--#
  CALL fin80030_verifica_situacao_permuta(lr_ad_mestre.cod_empresa, lr_ad_mestre.num_ad)
     RETURNING m_status, m_msg
  IF NOT m_status THEN
     RETURN FALSE, m_msg
  END IF

  IF log0150_verifica_se_tabela_existe("cap_ad_nrml_prmt") THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cap_ad_nrml_prmt
        WHERE empresa            = lr_ad_mestre.cod_empresa
          AND apropr_desp_normal = lr_ad_mestre.num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na eliminação do registro de relacionamento Permuta. (cap_ad_nrml_prmt)!'
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------------------------------------------#
 FUNCTION fin80030_atualiza_ads_relac_adf(l_cod_empresa, l_num_ad, l_val_saldo_ad)
#--------------------------------------------------------------------------------#

  DEFINE l_cod_empresa   LIKE ad_mestre.cod_empresa,
         l_num_ad        LIKE ad_mestre.num_ad,
         l_val_saldo_ad  LIKE ad_mestre.val_saldo_ad

  DEFINE l_val_saldo_adn LIKE ad_mestre.val_saldo_ad,
         l_val_liq       LIKE ad_mestre.val_tot_nf,
         l_val_tot_nf    LIKE ad_mestre.val_tot_nf,
         l_num_adn       LIKE adn_adf.num_adn

  #--# Busca os parâmetros #--#
  CALL fin80030_busca_parametros(l_cod_empresa)

  WHENEVER ERROR CONTINUE
   DECLARE cm_adn_adf CURSOR FOR
    SELECT num_adn
      FROM adn_adf
     WHERE adn_adf.cod_empresa = l_cod_empresa
       AND adn_adf.num_adf     = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na atualização do saldo da AD'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cm_adn_adf INTO l_num_adn
      IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
      END IF

      WHENEVER ERROR CONTINUE
        SELECT val_tot_nf,
               val_saldo_ad
          INTO l_val_tot_nf,
               l_val_saldo_adn
          FROM ad_mestre
         WHERE cod_empresa = l_cod_empresa
           AND num_ad      = l_num_adn
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na busca da AD relacionada a AD Fatura!'
      END IF

      LET l_val_liq = fin80014_calc_val_liquido_ad(l_cod_empresa, l_num_adn, l_val_tot_nf)

      IF l_val_saldo_ad >= l_val_liq THEN
         LET l_val_saldo_ad  = l_val_saldo_ad - l_val_liq
         LET l_val_saldo_adn = l_val_liq
      ELSE
         LET l_val_saldo_adn = l_val_saldo_adn + l_val_saldo_ad
         LET l_val_saldo_ad = 0
      END IF

     WHENEVER ERROR CONTINUE
       UPDATE ad_mestre
          SET val_saldo_ad = l_val_saldo_adn
        WHERE num_ad       = l_num_adn
          AND cod_empresa  = l_cod_empresa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE, 'Problema na atualização do saldo da AD relacionada  a AD Fatura!'
     END IF

     #--# Integração Fluxo de Caixa #--#
     IF mr_parametros.ies_online_fcl = "S" THEN
        CALL fcl1160_integracao_cap_fcx(l_cod_empresa,"AD", l_num_adn,"IN")
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF
     END IF
  END FOREACH

  #--# Integração Fluxo de Caixa #--#
  IF mr_parametros.ies_online_fcl = "S" THEN
     CALL fcl1160_integracao_cap_fcx(l_cod_empresa,"AD", l_num_ad,"EX")
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF

     CALL fcl1160_integracao_cap_fcx(l_cod_empresa,"AD", l_num_ad,"IN")
        RETURNING m_status, m_msg
     IF NOT m_status THEN
        RETURN FALSE, m_msg
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#--------------------------------------------------------------------------#
 FUNCTION fin80030_elimina_baixa_adiantamento_geral(l_cod_empresa, l_num_ad)
#--------------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE lr_ad_valores RECORD LIKE ad_valores.*

  WHENEVER ERROR CONTINUE
   DECLARE cq_ad_val_adiant CURSOR FOR
    SELECT ad_valores.*
      FROM ad_valores, tipo_valor
     WHERE ad_valores.cod_empresa      = l_cod_empresa
       AND ad_valores.num_ad           = l_num_ad
       AND tipo_valor.cod_empresa      = ad_valores.cod_empresa
       AND tipo_valor.cod_tip_val      = ad_valores.cod_tip_val
       AND tipo_valor.ies_baixa_adiant = "S"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na busca de ajustes de baixas de adiantamento!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_ad_val_adiant INTO lr_ad_valores.*
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na busca de ajustes de baixas de adiantamento!'
      END IF

      #--# Elimina e recalcula adiantamentos #--#
      CALL fin80030_recalcula_saldo_adiant_individual(lr_ad_valores.cod_empresa,
                                                      '1',
                                                      lr_ad_valores.num_ad,
                                                      lr_ad_valores.valor,
                                                      lr_ad_valores.cod_tip_val)
         RETURNING m_status, m_msg
      IF NOT m_status THEN
         RETURN FALSE, m_msg
      END IF

      WHENEVER ERROR CONTINUE
   END FOREACH
   FREE cq_ad_val_adiant
  WHENEVER ERROR STOP

  RETURN TRUE, ' '

END FUNCTION

#----------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_recalcula_saldo_adiant_individual(l_cod_empresa,    l_ies_ad_ap,       l_num_ad_ap,
                                                     l_valor_anterior, l_cod_tip_val)
#----------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa     LIKE ad_valores.cod_empresa,
         l_ies_ad_ap       LIKE mov_adiant.ies_ad_ap_mov,
         l_num_ad_ap       LIKE mov_adiant.num_ad_ap_mov,
         l_valor_anterior  DECIMAL(17,2),
         l_cod_tip_val     LIKE ad_valores.cod_tip_val

  DEFINE lr_mov_adiant     RECORD LIKE mov_adiant.*

  DEFINE l_raiz_cgc_cpf    CHAR(11)

  WHENEVER ERROR CONTINUE
    DECLARE cq_ad_nf_orig CURSOR FOR
     SELECT *
       FROM mov_adiant
      WHERE mov_adiant.cod_empresa     = l_cod_empresa
        AND mov_adiant.ies_ad_ap_mov   = l_ies_ad_ap
        AND mov_adiant.num_ad_ap_mov   = l_num_ad_ap
        AND mov_adiant.val_mov         = l_valor_anterior
        AND mov_adiant.ies_ent_bx      = "B"
        AND mov_adiant.cod_tip_val_mov = l_cod_tip_val
        FOR UPDATE
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE, 'Problema na busca dos movimentos de baixa de adiantamentos eliminados!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_ad_nf_orig INTO lr_mov_adiant.*
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na busca dos movimentos de baixa de adiantamentos eliminados!'
      END IF

      #--# Busca a raiz do fornecedor #--#
      CALL fin80054_busca_raiz_fornecedor(lr_mov_adiant.cod_fornecedor)
         RETURNING l_raiz_cgc_cpf

      WHENEVER ERROR CONTINUE
        UPDATE adiant
           SET val_saldo_adiant = val_saldo_adiant + lr_mov_adiant.val_mov
         WHERE cod_empresa    = lr_mov_adiant.cod_empresa
           AND num_ad_nf_orig = lr_mov_adiant.num_ad_nf_orig
           AND cod_fornecedor IN (SELECT fornecedor.cod_fornecedor
                                    FROM fornecedor
                                   WHERE fornecedor.num_cgc_cpf[1,11] = l_raiz_cgc_cpf)
           AND ser_nf         = lr_mov_adiant.ser_nf
           AND ssr_nf         = lr_mov_adiant.ssr_nf
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na atualização do adiantamento do documento eliminado!'
      END IF

      WHENEVER ERROR CONTINUE
        DELETE FROM mov_adiant
         WHERE CURRENT OF cq_ad_nf_orig
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na atualização dos movimentos de baixa de adiantamentos eliminados!'
      END IF

      WHENEVER ERROR CONTINUE
        DELETE FROM cap_mov_adto_compl
         WHERE empresa           = lr_mov_adiant.cod_empresa
           AND ad_nota_fiscal    = lr_mov_adiant.num_ad_nf_orig
           AND serie_nota_fiscal = lr_mov_adiant.ser_nf
           AND subserie_nf       = lr_mov_adiant.ssr_nf
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na atualização dos movimentos complementares de baixa de adiantamentos eliminados!'
      END IF

      #--# Recalcula os saldos das outras movimentações #--#
      CALL fin80030_recalcula_saldo_outras_mov_adiant(lr_mov_adiant.cod_empresa,
                                                      lr_mov_adiant.num_ad_nf_orig,
                                                      lr_mov_adiant.cod_fornecedor,
                                                      lr_mov_adiant.ser_nf,
                                                      lr_mov_adiant.ssr_nf)
      RETURNING m_status, m_msg
      IF NOT m_status THEN
         RETURN FALSE, m_msg
      END IF

   END FOREACH
   FREE cq_ad_nf_orig
  WHENEVER ERROR STOP

  RETURN TRUE, ' '

END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION fin80030_atualiza_saldo_ir_adiantameno(l_cod_empresa, l_num_ad)
#-----------------------------------------------------------------------#

  DEFINE l_cod_empresa LIKE ad_mestre.cod_empresa,
         l_num_ad      LIKE ad_mestre.num_ad

  DEFINE l_versao           LIKE cap_sld_irrf_adto.versao,
         l_apropr_desp_adto LIKE cap_sld_irrf_adto.apropr_desp_adto

  WHENEVER ERROR CONTINUE
   DECLARE cq_exclui_sld_adt CURSOR FOR
    SELECT apropr_desp_adto
      FROM cap_sld_irrf_adto
     WHERE empresa     = l_cod_empresa
       AND apropr_desp = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     RETURN FALSE, 'Problema na seleção dos registros de IR no adiantamento!'
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_exclui_sld_adt INTO l_apropr_desp_adto
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na seleção dos registros de IR no adiantamento!'
      END IF

      WHENEVER ERROR CONTINUE
        SELECT empresa
          FROM cap_sld_irrf_adto
         WHERE empresa          = l_cod_empresa
           AND apropr_desp      = l_num_ad
           AND apropr_desp_adto = l_apropr_desp_adto
           AND versao_atual     = "S"
      WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN

         WHENEVER ERROR CONTINUE
           SELECT MAX(versao)
             INTO l_versao
             FROM cap_sld_irrf_adto
            WHERE empresa          = l_cod_empresa
              AND apropr_desp_adto = l_apropr_desp_adto
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
            RETURN FALSE, 'Problema na seleção dos registros de IR no adiantamento!'
         ELSE
            WHENEVER ERROR CONTINUE
              UPDATE cap_sld_irrf_adto
                 SET versao_atual     = "S"
               WHERE empresa          = l_cod_empresa
                 AND apropr_desp_adto = l_apropr_desp_adto
                 AND versao           = l_versao
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               RETURN FALSE, 'Problema na atualização dos registros de IR no adiantamento!'
            END IF
         END IF
      END IF

      WHENEVER ERROR CONTINUE
        DELETE FROM cap_sld_irrf_adto
         WHERE empresa          = l_cod_empresa
           AND apropr_desp      = l_num_ad
           AND apropr_desp_adto = l_apropr_desp_adto
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN FALSE, 'Problema na eliminação dos registros de IR no adiantamento!'
      END IF

      WHENEVER ERROR CONTINUE
   END FOREACH
   FREE cq_exclui_sld_adt
  WHENEVER ERROR STOP

  RETURN TRUE, ' '

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION fin80030_verifica_documento_credito_vinculado(l_empresa,l_num_ad)
#-------------------------------------------------------------------------#

  DEFINE l_empresa    LIKE cre_info_adic_doc.empresa,
         l_num_ad     LIKE ad_mestre.num_ad

  DEFINE l_docum      LIKE cre_info_adic_doc.docum,
         l_tip_docum  LIKE cre_info_adic_doc.tip_docum

  WHENEVER ERROR CONTINUE
    SELECT docum,
           tip_docum
      INTO l_docum,
           l_tip_docum
      FROM cre_info_adic_doc
     WHERE empresa       = l_empresa
       AND parametro_val = l_num_ad
       AND campo         = "AD_docto_credito"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET m_msg =  "Exclua a baixa do documento ",l_docum CLIPPED," - ",l_tip_docum," pelo CRE0150."
     RETURN FALSE, m_msg
  ELSE
     IF sqlca.sqlcode <> 100 THEN
        RETURN FALSE, 'Problema ao verificar documento de crédito do Contas a Receber!.'
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#------------------------------------------------------------------------------------------------------------------#
 FUNCTION fin80030_verifica_imposto_ret_recol_ja_pago(l_cod_empresa, l_num_ad, l_cod_empresa_orig, l_cod_fornecedor)
#------------------------------------------------------------------------------------------------------------------#

  DEFINE l_cod_empresa      LIKE ad_mestre.cod_empresa,
         l_num_ad           LIKE ad_mestre.num_ad,
         l_cod_empresa_orig LIKE ad_mestre.cod_empresa_orig,
         l_cod_fornecedor   LIKE ad_mestre.cod_fornecedor

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM benefic_dirf
     WHERE cod_empresa    = l_cod_empresa_orig
       AND num_ad_ap_orig = l_num_ad
       AND ies_ad_ap_orig = "1"
       AND num_ad_pg_irrf IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM inss_auton
     WHERE cod_empresa    = l_cod_empresa_orig
       AND num_ad_nf_orig = l_num_ad
       AND ies_especie_nf = "AD"
       AND num_ad_pg_inss IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM reten_inss
     WHERE cod_empresa     = l_cod_empresa_orig
       AND cod_fornecedor  = l_cod_fornecedor
       AND num_ad_nf_orig  = l_num_ad
       AND ies_especie_nf  = "AD"
       AND num_ad_pg_inss  IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM reten_iss
     WHERE cod_empresa     = l_cod_empresa_orig
       AND cod_fornecedor  = l_cod_fornecedor
       AND num_ad_nf_orig  = l_num_ad
       AND ies_especie_nf  = "AD"
       AND num_ad_pg_iss   IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_ret_inss_auton
     WHERE empresa           = l_cod_empresa_orig
       AND ad_nf_origem      = l_num_ad
       AND espc_nota_fiscal  = 'AD'
       AND ad_pagto_inss    IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> NOTFOUND THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------------------#
 FUNCTION fin80030_tipo_ad_permuta(l_funcao, l_cod_empresa, l_num_ad, l_cod_tip_ad)
#---------------------------------------------------------------------------------#

  DEFINE l_funcao       CHAR(01),
         l_cod_empresa  LIKE ad_mestre.cod_empresa,
         l_num_ad       LIKE ad_mestre.num_ad,
         l_cod_tip_ad   LIKE ad_mestre.cod_tip_ad

  DEFINE l_num_docum LIKE cre_movto_permuta.docum

  LET l_num_docum = l_num_ad

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cap_tip_ad_permuta
     WHERE empresa        = l_cod_empresa
       AND tip_ad_permuta = l_cod_tip_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     IF l_funcao =  "I" THEN
        RETURN TRUE
     ELSE
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM cre_movto_permuta
           WHERE docum         = l_num_docum
             AND empresa_docum = l_cod_empresa
             AND tip_docum     = "AD"
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           RETURN TRUE
        END IF
     END IF
  END IF

  RETURN FALSE

END FUNCTION

#-------------------------------------------------------------------#
 FUNCTION fin80030_verifica_situacao_permuta(l_cod_empresa, l_num_ad)
#-------------------------------------------------------------------#

  DEFINE l_cod_empresa  LIKE ad_mestre.cod_empresa,
         l_num_ad       LIKE ad_mestre.num_ad

  DEFINE l_num_ad_perm  LIKE ad_mestre.num_ad

  INITIALIZE l_num_ad_perm TO NULL

  #--# Verifica relacionamento de permuta #--#
  WHENEVER ERROR CONTINUE
   SELECT ad_permuta
     INTO l_num_ad_perm
     FROM cap_ad_nrml_prmt
    WHERE empresa            = l_cod_empresa
      AND apropr_desp_normal = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
     WHENEVER ERROR CONTINUE
       SELECT apropr_desp_normal
         INTO l_num_ad_perm
         FROM cap_ad_nrml_prmt
        WHERE empresa    = l_cod_empresa
          AND ad_permuta = l_num_ad
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = NOTFOUND THEN
        RETURN TRUE, ' '
     END IF
  END IF

  IF l_num_ad_perm IS NOT NULL THEN

     IF log_question('AD está associada a uma AD de permuta. Para efetuar a exclusão, ambas serão excluídas, deseja continuar?') THEN
        #--# Exclui a AD de permuta relacionada #--#
        CALL fin80030_exclui_ad(l_cod_empresa, l_num_ad_perm, 'S')
           RETURNING m_status, m_msg
        IF NOT m_status THEN
           RETURN FALSE, m_msg
        END IF
     END IF
  END IF

  RETURN TRUE, ' '

END FUNCTION

#----------------------------------------------------------------------------------------------------------------------#
# FUNÇÕES ATRIBUIDORAS DE VALORES                                                                                      #
#                                                                                                                      #
#                                                                                                                      #
#----------------------------------------------------------------------------------------------------------------------#

#-----------------------------------#
 FUNCTION fin80030_inicializa_dados()
#-----------------------------------#

  FOR m_ind = 1 TO 500
     INITIALIZE ma_lanc_cont_cap_integr[m_ind].* TO NULL
  END FOR

  FOR m_ind = 1 TO 100
     INITIALIZE ma_tipo_valor_integr[m_ind].*,
                ma_impostos_integr[m_ind].*,
                ma_adiantamentos_integr[m_ind].*    TO NULL
  END FOR

  FOR m_ind = 1 TO 200
     INITIALIZE ma_ad_aen_integr[m_ind].*,
                ma_ad_aen_4_integr[m_ind].*,
                ma_ad_aen_conta_integr[m_ind].*,
                ma_ad_aen_conta_4_integr[m_ind].* TO NULL
  END FOR

  INITIALIZE mr_dados_integr.*,
             mr_dados_adic.*    TO NULL

  LET m_index_lanc      = 1
  LET m_index_imp       = 1
  LET m_index_tip_val   = 1
  LET m_index_aen       = 1
  LET m_index_aen_4     = 1
  LET m_index_aen_cta   = 1
  LET m_index_aen_cta_4 = 1
  LET m_alterou         = FALSE

END FUNCTION

#------------# LANÇAMENTOS #------------#

#--------------------------------------------------------#
 FUNCTION fin80030_lanc_set_ies_tipo_lanc(l_ies_tipo_lanc)
#--------------------------------------------------------#

  DEFINE l_ies_tipo_lanc LIKE lanc_cont_cap.ies_tipo_lanc

  LET ma_lanc_cont_cap_integr[m_index_lanc].ies_tipo_lanc = l_ies_tipo_lanc

END FUNCTION

#----------------------------------------------------------#
 FUNCTION fin80030_lanc_set_num_conta_cont(l_num_conta_cont)
#----------------------------------------------------------#

  DEFINE l_num_conta_cont LIKE lanc_cont_cap.num_conta_cont

  LET ma_lanc_cont_cap_integr[m_index_lanc].num_conta_cont = l_num_conta_cont

END FUNCTION

#----------------------------------------------#
 FUNCTION fin80030_lanc_set_val_lanc(l_val_lanc)
#----------------------------------------------#

  DEFINE l_val_lanc LIKE lanc_cont_cap.val_lanc

  LET ma_lanc_cont_cap_integr[m_index_lanc].val_lanc = l_val_lanc

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_lanc_set_tex_hist_lanc(l_tex_hist_lanc)
#--------------------------------------------------------#

  DEFINE l_tex_hist_lanc LIKE lanc_cont_cap.tex_hist_lanc

  LET ma_lanc_cont_cap_integr[m_index_lanc].tex_hist_lanc = l_tex_hist_lanc

END FUNCTION

#-------------------------------------------------------#
 FUNCTION fin80030_lanc_set_ies_desp_val(l_ies_desp_val)
#-------------------------------------------------------#

  DEFINE l_ies_desp_val LIKE lanc_cont_cap.ies_desp_val

  LET ma_lanc_cont_cap_integr[m_index_lanc].ies_desp_val = l_ies_desp_val

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION fin80030_lanc_set_cod_tip_desp_val(l_cod_tip_desp_val)
#---------------------------------------------------------------#

  DEFINE l_cod_tip_desp_val LIKE lanc_cont_cap.cod_tip_desp_val

  LET ma_lanc_cont_cap_integr[m_index_lanc].cod_tip_desp_val = l_cod_tip_desp_val

END FUNCTION

#----------------------------------------------------#
 FUNCTION fin80030_lanc_set_dat_lanc(l_dat_lanc)
#----------------------------------------------------#

  DEFINE l_dat_lanc LIKE lanc_cont_cap.dat_lanc

  LET ma_lanc_cont_cap_integr[m_index_lanc].dat_lanc = l_dat_lanc

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_lanc_cont_cap_integr()
#------------------------------------------------#

  LET m_index_lanc = m_index_lanc + 1

END FUNCTION

#------------# TIPO DE VALOR #------------#

#--------------------------------------------------------#
 FUNCTION fin80030_tip_val_set_cod_tip_val(l_cod_tip_val)
#--------------------------------------------------------#

  DEFINE l_cod_tip_val DECIMAL(3,0)

  LET ma_tipo_valor_integr[m_index_tip_val].cod_tip_val = l_cod_tip_val

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_tip_val_set_valor(l_valor)
#--------------------------------------------------------#

  DEFINE l_valor DECIMAL(15,2)

  LET ma_tipo_valor_integr[m_index_tip_val].valor = l_valor

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_tip_val_set_num_seq(l_num_seq)
#--------------------------------------------------------#

  DEFINE l_num_seq LIKE ad_valores.num_seq

  LET ma_tipo_valor_integr[m_index_tip_val].num_seq = l_num_seq

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_tip_val_set_ind_alteracao(l_ind_alteracao)
#------------------------------------------------------------#

  DEFINE l_ind_alteracao CHAR(01)

  LET ma_tipo_valor_integr[m_index_tip_val].ind_alteracao = l_ind_alteracao

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_cod_tip_val(l_cod_tip_val)
#------------------------------------------------------------#

  DEFINE l_cod_tip_val LIKE ad_valores.cod_tip_val

  LET ma_adiantamentos_integr[m_index_tip_val].cod_tip_val = l_cod_tip_val

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_valor(l_valor)
#------------------------------------------------------------#

  DEFINE l_valor LIKE ad_valores.valor

  LET ma_adiantamentos_integr[m_index_tip_val].valor = l_valor

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_num_ad_nf_orig(l_num_ad_nf_orig)
#------------------------------------------------------------#

  DEFINE l_num_ad_nf_orig LIKE adiant.num_ad_nf_orig

  LET ma_adiantamentos_integr[m_index_tip_val].num_ad_nf_orig = l_num_ad_nf_orig

END FUNCTION

#---------------------------------------------#
 FUNCTION fin80030_adiant_set_ser_nf(l_ser_nf)
#---------------------------------------------#

  DEFINE l_ser_nf LIKE adiant.ser_nf

  LET ma_adiantamentos_integr[m_index_tip_val].ser_nf = l_ser_nf

END FUNCTION

#---------------------------------------------#
 FUNCTION fin80030_adiant_set_ssr_nf(l_ssr_nf)
#---------------------------------------------#

  DEFINE l_ssr_nf LIKE adiant.ssr_nf

  LET ma_adiantamentos_integr[m_index_tip_val].ssr_nf = l_ssr_nf

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_cod_fornecedor(l_cod_fornecedor)
#-------------------------------------------------------------#

  DEFINE l_cod_fornecedor LIKE adiant.cod_fornecedor

  LET ma_adiantamentos_integr[m_index_tip_val].cod_fornecedor = l_cod_fornecedor

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_hor_mov(l_hor_mov)
#-------------------------------------------------------------#

  DEFINE l_hor_mov LIKE mov_adiant.hor_mov

  LET ma_adiantamentos_integr[m_index_tip_val].hor_mov = l_hor_mov

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_dat_mov(l_dat_mov)
#-------------------------------------------------------------#

  DEFINE l_dat_mov LIKE mov_adiant.dat_mov

  LET ma_adiantamentos_integr[m_index_tip_val].dat_mov = l_dat_mov

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_num_item(l_num_item)
#-------------------------------------------------------------#

  DEFINE l_num_item LIKE dev_fornec.num_item

  LET ma_adiantamentos_integr[m_index_tip_val].num_item = l_num_item

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_num_aviso_rec(l_num_aviso_rec)
#-------------------------------------------------------------#

  DEFINE l_num_aviso_rec LIKE dev_fornec.num_aviso_rec

  LET ma_adiantamentos_integr[m_index_tip_val].num_aviso_rec = l_num_aviso_rec

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adiant_set_num_seq(l_num_seq)
#-------------------------------------------------------------#

  DEFINE l_num_seq LIKE dev_fornec.num_seq

  LET ma_adiantamentos_integr[m_index_tip_val].num_seq = l_num_seq

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_tipo_valor_integr()
#------------------------------------------------#

  LET m_index_tip_val = m_index_tip_val + 1

END FUNCTION

#------------# IMPOSTOS #------------#

#--------------------------------------------------------#
 FUNCTION fin80030_trib_set_cod_tip_val(l_cod_tip_val)
#--------------------------------------------------------#

  DEFINE l_cod_tip_val DECIMAL(3,0)

  LET ma_impostos_integr[m_index_imp].cod_tip_val = l_cod_tip_val

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_trib_set_val_base_calc(l_val_base_calc)
#--------------------------------------------------------#

  DEFINE l_val_base_calc DECIMAL(15,2)

  LET ma_impostos_integr[m_index_imp].val_base_calc = l_val_base_calc

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_trib_set_valor(l_valor)
#--------------------------------------------------------#

  DEFINE l_valor DECIMAL(15,2)

  LET ma_impostos_integr[m_index_imp].valor = l_valor

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_impostos_integr()
#------------------------------------------------#

  LET m_index_imp = m_index_imp + 1

END FUNCTION

#------------# AEN #------------#

#--------------------------------------------------------#
 FUNCTION fin80030_aen_set_val_item(l_val_item)
#--------------------------------------------------------#

  DEFINE l_val_item LIKE ad_aen.val_item

  LET ma_ad_aen_integr[m_index_aen].val_item = l_val_item

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_set_cod_area_negocio(l_cod_area_negocio)
#--------------------------------------------------------------#

  DEFINE l_cod_area_negocio LIKE ad_aen.cod_area_negocio

  LET ma_ad_aen_integr[m_index_aen].cod_area_negocio = l_cod_area_negocio

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_set_cod_lin_negocio(l_cod_lin_negocio)
#--------------------------------------------------------------#

  DEFINE l_cod_lin_negocio LIKE ad_aen.cod_lin_negocio

  LET ma_ad_aen_integr[m_index_aen].cod_lin_negocio = l_cod_lin_negocio

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_ad_aen_integr()
#------------------------------------------------#

  LET m_index_aen = m_index_aen + 1

END FUNCTION

#------------# AEN 4 #------------#

#--------------------------------------------------------#
 FUNCTION fin80030_aen_4_set_val_aen(l_val_aen)
#--------------------------------------------------------#

  DEFINE l_val_aen LIKE ad_aen_4.val_aen

  LET ma_ad_aen_4_integr[m_index_aen_4].val_aen = l_val_aen

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_aen_4_set_cod_lin_prod(l_cod_lin_prod)
#--------------------------------------------------------#

  DEFINE l_cod_lin_prod LIKE ad_aen_4.cod_lin_prod

  LET ma_ad_aen_4_integr[m_index_aen_4].cod_lin_prod = l_cod_lin_prod

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_aen_4_set_cod_lin_recei(l_cod_lin_recei)
#--------------------------------------------------------#

  DEFINE l_cod_lin_recei LIKE ad_aen_4.cod_lin_recei

  LET ma_ad_aen_4_integr[m_index_aen_4].cod_lin_recei = l_cod_lin_recei

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_aen_4_set_cod_seg_merc(l_cod_seg_merc)
#--------------------------------------------------------#

  DEFINE l_cod_seg_merc LIKE ad_aen_4.cod_seg_merc

  LET ma_ad_aen_4_integr[m_index_aen_4].cod_seg_merc = l_cod_seg_merc

END FUNCTION

#--------------------------------------------------------#
 FUNCTION fin80030_aen_4_set_cod_cla_uso(l_cod_cla_uso)
#--------------------------------------------------------#

  DEFINE l_cod_cla_uso LIKE ad_aen_4.cod_cla_uso

  LET ma_ad_aen_4_integr[m_index_aen_4].cod_cla_uso = l_cod_cla_uso

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_ad_aen_4_integr()
#------------------------------------------------#

  LET m_index_aen_4 = m_index_aen_4 + 1

END FUNCTION

#------------# AEN CONTA #------------#
#--------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_num_seq_lanc(l_num_seq_lanc)
#--------------------------------------------------------#

  DEFINE l_num_seq_lanc LIKE ad_aen_conta.num_seq_lanc

  LET ma_ad_aen_conta_integr[m_index_aen_cta].num_seq_lanc = l_num_seq_lanc

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_ies_tipo_lanc(l_ies_tipo_lanc)
#------------------------------------------------------------#

  DEFINE l_ies_tipo_lanc LIKE ad_aen_conta.ies_tipo_lanc

  LET ma_ad_aen_conta_integr[m_index_aen_cta].ies_tipo_lanc = l_ies_tipo_lanc

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_num_conta_cont(l_num_conta_cont)
#--------------------------------------------------------------#

  DEFINE l_num_conta_cont LIKE ad_aen_conta.num_conta_cont

  LET ma_ad_aen_conta_integr[m_index_aen_cta].num_conta_cont = l_num_conta_cont

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_ies_fornec_trans(l_ies_fornec_trans)
#------------------------------------------------------------------#

  DEFINE l_ies_fornec_trans LIKE ad_aen_conta.ies_fornec_trans

  LET ma_ad_aen_conta_integr[m_index_aen_cta].ies_fornec_trans = l_ies_fornec_trans

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_cod_area_negocio(l_cod_area_negocio)
#------------------------------------------------------------------#

  DEFINE l_cod_area_negocio LIKE ad_aen_conta.cod_area_negocio

  LET ma_ad_aen_conta_integr[m_index_aen_cta].cod_area_negocio = l_cod_area_negocio

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_cod_lin_negocio(l_cod_lin_negocio)
#------------------------------------------------------------------#

  DEFINE l_cod_lin_negocio LIKE ad_aen_conta.cod_lin_negocio

  LET ma_ad_aen_conta_integr[m_index_aen_cta].cod_lin_negocio = l_cod_lin_negocio

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_set_val_item(l_val_item)
#------------------------------------------------------------------#

  DEFINE l_val_item LIKE ad_aen_conta.val_item

  LET ma_ad_aen_conta_integr[m_index_aen_cta].val_item = l_val_item

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_ad_aen_conta_integr()
#------------------------------------------------#

  LET m_index_aen_cta = m_index_aen_cta + 1

END FUNCTION

#------------# AEN CONTA 4 #------------#
#------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_num_seq_lanc(l_num_seq_lanc)
#------------------------------------------------------------#

  DEFINE l_num_seq_lanc LIKE ad_aen_conta_4.num_seq_lanc

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].num_seq_lanc = l_num_seq_lanc

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_ies_tipo_lanc(l_ies_tipo_lanc)
#--------------------------------------------------------------#

  DEFINE l_ies_tipo_lanc LIKE ad_aen_conta_4.ies_tipo_lanc

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].ies_tipo_lanc = l_ies_tipo_lanc

END FUNCTION

#----------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_num_conta_cont(l_num_conta_cont)
#----------------------------------------------------------------#

  DEFINE l_num_conta_cont LIKE ad_aen_conta_4.num_conta_cont

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].num_conta_cont = l_num_conta_cont

END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_ies_fornec_trans(l_ies_fornec_trans)
#--------------------------------------------------------------------#

  DEFINE l_ies_fornec_trans LIKE ad_aen_conta_4.ies_fornec_trans

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].ies_fornec_trans = l_ies_fornec_trans

END FUNCTION

#------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_cod_lin_prod(l_cod_lin_prod)
#------------------------------------------------------------#

  DEFINE l_cod_lin_prod LIKE ad_aen_conta_4.cod_lin_prod

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].cod_lin_prod = l_cod_lin_prod

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_cod_lin_recei(l_cod_lin_recei)
#--------------------------------------------------------------#

  DEFINE l_cod_lin_recei LIKE ad_aen_conta_4.cod_lin_recei

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].cod_lin_recei = l_cod_lin_recei

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_cod_seg_merc(l_cod_seg_merc)
#--------------------------------------------------------------#

  DEFINE l_cod_seg_merc LIKE ad_aen_conta_4.cod_seg_merc

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].cod_seg_merc = l_cod_seg_merc

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_cod_cla_uso(l_cod_cla_uso)
#--------------------------------------------------------------#

  DEFINE l_cod_cla_uso LIKE ad_aen_conta_4.cod_cla_uso

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].cod_cla_uso = l_cod_cla_uso

END FUNCTION

#------------------------------------------------------#
 FUNCTION fin80030_aen_cta_4_set_val_aen(l_val_aen)
#------------------------------------------------------#

  DEFINE l_val_aen LIKE ad_aen_conta_4.val_aen

  LET ma_ad_aen_conta_4_integr[m_index_aen_cta_4].val_aen = l_val_aen

END FUNCTION

#------------------------------------------------#
 FUNCTION fin80030_inclui_ad_aen_conta_4_integr()
#------------------------------------------------#

  LET m_index_aen_cta_4 = m_index_aen_cta_4 + 1

END FUNCTION

#---# Dados adicionais #---#
#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_programa_orig(l_programa_orig)
#-------------------------------------------------------------#

  DEFINE l_programa_orig CHAR(10)

  LET mr_dados_adic.programa_orig = l_programa_orig

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_modif_ad(l_ind_modif_ad)
#-------------------------------------------------------------#

  DEFINE l_ind_modif_ad CHAR(01)

  LET mr_dados_adic.ind_modif_ad = l_ind_modif_ad

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_valid_dados(l_ind_valid_dados)
#-------------------------------------------------------------#

  DEFINE l_ind_valid_dados CHAR(01)

  LET mr_dados_adic.ind_valid_dados = l_ind_valid_dados

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_num_ad_exist(l_num_ad_exist)
#-------------------------------------------------------------#

  DEFINE l_num_ad_exist LIKE ad_mestre.num_ad

  LET mr_dados_adic.num_ad_exist = l_num_ad_exist

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_trib(l_ind_inform_trib)
#-------------------------------------------------------------#

  DEFINE l_ind_inform_trib CHAR(01)

  LET mr_dados_adic.ind_inform_trib = l_ind_inform_trib

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_lanc(l_ind_inform_lanc)
#-------------------------------------------------------------#

  DEFINE l_ind_inform_lanc CHAR(01)

  LET mr_dados_adic.ind_inform_lanc = l_ind_inform_lanc

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_aprov(l_ind_inform_aprov)
#-------------------------------------------------------------#

  DEFINE l_ind_inform_aprov CHAR(01)

  LET mr_dados_adic.ind_inform_aprov = l_ind_inform_aprov

END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_unid_func(l_ind_inform_unid_func)
#-----------------------------------------------------------------------#

  DEFINE l_ind_inform_unid_func CHAR(01)

  LET mr_dados_adic.ind_inform_unid_func = l_ind_inform_unid_func

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_aen(l_ind_inform_aen)
#-------------------------------------------------------------#

  DEFINE l_ind_inform_aen CHAR(01)

  LET mr_dados_adic.ind_inform_aen = l_ind_inform_aen

END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ind_inform_ct_perm(l_ind_inform_ct_perm)
#--------------------------------------------------------------------#

  DEFINE l_ind_inform_ct_perm CHAR(01)

  LET mr_dados_adic.ind_inform_ct_perm = l_ind_inform_ct_perm

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_banco(l_cod_banco)
#-------------------------------------------------------------#

  DEFINE l_cod_banco LIKE agencia_bco.cod_banco

  LET mr_dados_adic.cod_banco = l_cod_banco

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_num_agencia(l_num_agencia)
#-------------------------------------------------------------#

  DEFINE l_num_agencia LIKE agencia_bco.num_agencia

  LET mr_dados_adic.num_agencia = l_num_agencia

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_num_conta_banc(l_num_conta_banc)
#-------------------------------------------------------------#

  DEFINE l_num_conta_banc LIKE agencia_bc_item.num_conta_banc

  LET mr_dados_adic.num_conta_banc = l_num_conta_banc

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_portador(l_cod_portador)
#-------------------------------------------------------------#

  DEFINE l_cod_portador LIKE agencia_bco.cod_banco

  LET mr_dados_adic.cod_portador = l_cod_portador

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_lote_pgto(l_cod_lote_pgto)
#-------------------------------------------------------------#

  DEFINE l_cod_lote_pgto LIKE ap.cod_lote_pgto

  LET mr_dados_adic.cod_lote_pgto = l_cod_lote_pgto

END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_empresa_estab(l_cod_empresa_estab)
#-----------------------------------------------------------------#

  DEFINE l_cod_empresa_estab LIKE ad_mestre.cod_empresa_estab

  LET mr_dados_adic.cod_empresa_estab = l_cod_empresa_estab

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_mes_ano_compet(l_mes_ano_compet)
#-------------------------------------------------------------#

  DEFINE l_mes_ano_compet LIKE ad_mestre.mes_ano_compet

  LET mr_dados_adic.mes_ano_compet = l_mes_ano_compet

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_num_ord_forn(l_num_ord_forn)
#-------------------------------------------------------------#

  DEFINE l_num_ord_forn LIKE ad_mestre.num_ord_forn

  LET mr_dados_adic.num_ord_forn = l_num_ord_forn

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_moeda(l_cod_moeda)
#-------------------------------------------------------------#

  DEFINE l_cod_moeda LIKE ad_mestre.cod_moeda

  LET mr_dados_adic.cod_moeda = l_cod_moeda

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_set_aplicacao(l_set_aplicacao)
#-------------------------------------------------------------#

  DEFINE l_set_aplicacao LIKE ad_mestre.set_aplicacao

  LET mr_dados_adic.set_aplicacao = l_set_aplicacao

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_tip_ad(l_cod_tip_ad)
#-------------------------------------------------------------#

  DEFINE l_cod_tip_ad LIKE ad_mestre.cod_tip_ad

  LET mr_dados_adic.cod_tip_ad = l_cod_tip_ad

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_dat_emis_nf(l_dat_emis_nf)
#-------------------------------------------------------------#

  DEFINE l_dat_emis_nf LIKE ad_mestre.dat_emis_nf

  LET mr_dados_adic.dat_emis_nf = l_dat_emis_nf

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ies_ap_autom(l_ies_ap_autom)
#-------------------------------------------------------------#

  DEFINE l_ies_ap_autom LIKE ad_mestre.ies_ap_autom

  LET mr_dados_adic.ies_ap_autom = l_ies_ap_autom

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ies_ap_proposta(l_ies_ap_proposta)
#-------------------------------------------------------------#

  DEFINE l_ies_ap_proposta CHAR(01)

  LET mr_dados_adic.ies_ap_proposta = l_ies_ap_proposta

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ies_bx_automatica(l_ies_bx_automatica)
#------------------------------------------------------------------#

  DEFINE l_ies_bx_automatica CHAR(01)

  LET mr_dados_adic.ies_bx_automatica = l_ies_bx_automatica

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_emp_cntr_perm(l_cod_emp_cntr_perm)
#------------------------------------------------------------------#

  DEFINE l_cod_emp_cntr_perm LIKE empresa.cod_empresa

  LET mr_dados_adic.cod_emp_cntr_perm = l_cod_emp_cntr_perm

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION fin80030_adic_set_cod_contrato_perm(l_cod_contrato_perm)
#------------------------------------------------------------------#

  DEFINE l_cod_contrato_perm LIKE empresa.cod_empresa

  LET mr_dados_adic.cod_contrato_perm = l_cod_contrato_perm

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_observacao(l_observacao)
#-------------------------------------------------------------#

  DEFINE l_observacao CHAR(5000)

  LET mr_dados_adic.observacao = l_observacao

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION fin80030_adic_set_observacao_ap(l_observacao_ap)
#-------------------------------------------------------------#

  DEFINE l_observacao_ap CHAR(5000)

  LET mr_dados_adic.observacao_ap = l_observacao_ap

END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION fin80030_adic_set_ies_ajus_cnd_pgto(l_ies_ajus_cnd_pgto)
#-----------------------------------------------------------------#

  DEFINE l_ies_ajus_cnd_pgto CHAR(01)

  LET mr_dados_adic.ies_ajus_cnd_pgto = l_ies_ajus_cnd_pgto

END FUNCTION


#-----------------------------------------------------------------#
 FUNCTION fin80030_adic_set_num_proc_export(l_num_proc_export)
#-----------------------------------------------------------------#

  DEFINE l_num_proc_export CHAR(12)

  LET mr_dados_adic.num_proc_export = l_num_proc_export

END FUNCTION




