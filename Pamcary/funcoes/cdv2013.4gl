###PARSER-Não remover esta linha(Framework Logix)###
#---------------------------------------------------------------#
# SISTEMA.: CONTROLE DESPESA VIAGEM (PAMCARY)                   #
# PROGRAMA: CDV2013                                             #
# OBJETIVO: EXCLUSÃO INFORMACÕES CDV A PARTIR EXCLUSÃO AD       #
# AUTOR...: JULIANO TEÓFILO CABRAL DA MAIA                      #
# DATA....: 10/08/2005                                          #
#---------------------------------------------------------------#
DATABASE logix

#MODULARES
  DEFINE m_versao_funcao       CHAR(18) # -- Favor nao apagar esta linha (SUPORTE)
#END MODULARES

#----------------------------------------------------------#
 FUNCTION cdv2013_exclusao_ads_781(l_cod_empresa, l_num_ad)
#----------------------------------------------------------#
  DEFINE l_cod_empresa       LIKE empresa.cod_empresa,
         l_num_ad            LIKE ad_mestre.num_ad,
         l_msg               CHAR(80),
         l_impede_excl       SMALLINT,
         l_usu_aprov_fatura  LIKE cdv_intg_fat_781.usu_aprov_fatura,
         l_dat_aprov_fatura  LIKE cdv_intg_fat_781.dat_aprov_fatura,
         l_hr_aprov_fatura   LIKE cdv_intg_fat_781.hr_aprov_fatura,
         l_usu_aprov_contab  LIKE cdv_intg_fat_781.usu_aprov_contab,
         l_dat_aprov_contab  LIKE cdv_intg_fat_781.dat_aprov_contab,
         l_hr_aprov_contab   LIKE cdv_intg_fat_781.hr_aprov_contab,
         l_viagem            INTEGER,
         l_seq_despesa_km    LIKE cdv_despesa_km_781.seq_despesa_km

  LET m_versao_funcao = "CDV2013-05.10.03p"

  #########################
  LET l_impede_excl = FALSE
  #########################

  WHENEVER ERROR CONTINUE
#OS 401464
#   SELECT empresa
#     FROM cdv_solic_viag_781
#    WHERE empresa = l_cod_empresa
#      AND viagem  IS NOT NULL
#  WHENEVER ANY ERROR STOP
#  IF SQLCA.SQLCODE = -206 THEN #não é pamcary
#     RETURN TRUE, l_msg
#  END IF

  IF NOT log0150_verifica_se_tabela_existe("cdv_solic_viag_781") THEN #Não é pamcary
     RETURN TRUE, l_msg
  END IF
#---------

  WHENEVER ERROR CONTINUE
   DECLARE cq_integr_fat CURSOR FOR
    SELECT UNIQUE usu_aprov_fatura, dat_aprov_fatura, hr_aprov_fatura,
           usu_aprov_contab, dat_aprov_contab, hr_aprov_contab
      FROM cdv_intg_fat_781
     WHERE empresa            = l_cod_empresa
       AND apropr_desp_acerto = l_num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg =  'PROBLEMA DECLARE cq_integr_fat, SQLCA.SQLCODE: ', SQLCA.SQLCODE
     RETURN FALSE, l_msg
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_integr_fat INTO l_usu_aprov_fatura, l_dat_aprov_fatura, l_hr_aprov_fatura,
                              l_usu_aprov_contab, l_dat_aprov_contab, l_hr_aprov_contab

  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        LET l_msg =  'PROBLEMA FOREACH cq_integr_fat, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        LET l_impede_excl = TRUE
        EXIT FOREACH
     END IF

     IF l_usu_aprov_fatura IS NOT NULL AND
        l_dat_aprov_fatura IS NOT NULL AND
        l_hr_aprov_fatura  IS NOT NULL THEN
        LET l_msg =  'Viagem (CDV Pamcary) já aprovada pelo faturamento.'
        LET l_impede_excl = TRUE
     END IF

     IF l_usu_aprov_contab IS NOT NULL AND
        l_dat_aprov_contab IS NOT NULL AND
        l_hr_aprov_contab  IS NOT NULL THEN
        LET l_msg =  'Viagem (CDV Pamcary) já aprovada pela contabilidade.'
        LET l_impede_excl = TRUE
     END IF

  END FOREACH
  FREE cq_integr_fat

  IF l_impede_excl THEN
     RETURN FALSE, l_msg
  END IF

#-------- ADs terceiros e km semanal

  #WHENEVER ERROR CONTINUE
  #SELECT viagem
  #  FROM cdv_desp_terc_781
  # WHERE empresa     = l_cod_empresa
  #   AND ad_terceiro = l_num_ad
  #WHENEVER ERROR STOP
  #
  #IF sqlca.sqlcode = 0
  #OR sqlca.sqlcode = -284 THEN
  #   LET l_msg = 'AD de terceiros.'
  #   RETURN FALSE, l_msg
  #END IF
  
  #OS 585724
  #WHENEVER ERROR CONTINUE
  #SELECT cdv_despesa_km_781.viagem
  #  FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  # WHERE cdv_despesa_km_781.empresa            = l_cod_empresa
  #   AND cdv_tdesp_viag_781.empresa            = l_cod_empresa
  #   AND cdv_despesa_km_781.apropr_desp_km     = l_num_ad
  #   AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_despesa_km_781.tip_despesa_viagem
  #   AND cdv_tdesp_viag_781.grp_despesa_viagem = 3
  #   AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
  #WHENEVER ERROR STOP
  #
  #IF sqlca.sqlcode = 0
  #OR sqlca.sqlcode = -284 THEN
  #   LET l_msg = 'AD pertence ao tipo de despesa de km semanal.'
  #   RETURN FALSE, l_msg
  #END IF

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_viagem
     FROM cdv_solic_adto_781
    WHERE empresa            = l_cod_empresa
      AND num_ad_adto_viagem = l_num_ad
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        CALL cdv2013_viagem_possui_acerto(l_cod_empresa, l_viagem)
           RETURNING l_impede_excl, l_msg
        IF NOT l_impede_excl THEN
           WHENEVER ERROR CONTINUE
            DELETE FROM cdv_solic_adto_781
             WHERE empresa = l_cod_empresa
               AND num_ad_adto_viagem = l_num_ad
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE <> 0 THEN
              LET l_msg = 'PROBLEMA DELETE cdv_solic_adto_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
              RETURN FALSE, l_msg
           END IF
        END IF
     WHEN 100
        LET l_impede_excl = FALSE
     OTHERWISE
        LET l_msg = 'PROBLEMA SELECT cdv_solic_adto_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        LET l_impede_excl = TRUE
  END CASE

  IF l_impede_excl THEN
     RETURN FALSE, l_msg
  END IF

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_viagem
     FROM cdv_acer_viag_781
    WHERE empresa          = l_cod_empresa
      AND ad_acerto_conta  = l_num_ad
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        CALL cdv2013_viagem_possui_transf(l_cod_empresa, l_viagem)
           RETURNING l_impede_excl, l_msg
        IF NOT l_impede_excl THEN
           WHENEVER ERROR CONTINUE
            UPDATE cdv_acer_viag_781
               SET status_acer_viagem = '2',
                   ad_acerto_conta = NULL
             WHERE empresa = l_cod_empresa
               AND viagem  = l_viagem
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE <> 0 THEN
              LET l_msg = 'PROBLEMA DELETE cdv_acer_viag_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
              RETURN FALSE, l_msg
           END IF

           WHENEVER ERROR CONTINUE
            DELETE FROM cdv_dev_transf_781
             WHERE empresa = l_cod_empresa
               AND viagem  = l_viagem
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE <> 0 THEN
              LET l_msg = 'PROBLEMA DELETE cdv_dev_transf_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
              RETURN FALSE, l_msg
           END IF
        END IF
     WHEN 100
        LET l_impede_excl = FALSE
     OTHERWISE
        LET l_msg = 'PROBLEMA SELECT cdv_acer_viag_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        LET l_impede_excl = TRUE
  END CASE

  IF l_impede_excl THEN
     RETURN FALSE, l_msg
  END IF

  WHENEVER ERROR CONTINUE
   UPDATE cdv_desp_terc_781
      SET ad_terceiro = NULL
    WHERE empresa     = l_cod_empresa
      AND ad_terceiro = l_num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'PROBLEMA DELETE cdv_desp_terc_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
     RETURN FALSE, l_msg
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_excl_ad_km CURSOR FOR
    SELECT km.viagem, km.seq_despesa_km
      FROM cdv_despesa_km_781 km, cdv_tdesp_viag_781 td
     WHERE km.empresa            = l_cod_empresa
       AND km.apropr_desp_km     = l_num_ad
       AND td.empresa            = km.empresa
       AND td.tip_despesa_viagem = km.tip_despesa_viagem
#      AND td.grp_despesa_viagem = '3' OS 410817 - Winston
       AND td.grp_despesa_viagem = 3
       AND td.ativ               = km.ativ_km #OS462484
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg =  'PROBLEMA DECLARE cq_excl_ad_km, SQLCA.SQLCODE: ', SQLCA.SQLCODE
     RETURN FALSE, l_msg
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_excl_ad_km INTO l_viagem, l_seq_despesa_km
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        LET l_msg =  'PROBLEMA FOREACH cq_excl_ad_km, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        LET l_impede_excl = TRUE
        EXIT FOREACH
     END IF

     WHENEVER ERROR CONTINUE
      UPDATE cdv_despesa_km_781
         SET apropr_desp_km = NULL
       WHERE empresa        = l_cod_empresa
         AND viagem         = l_viagem
         AND seq_despesa_km = l_seq_despesa_km
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        LET l_msg =  'PROBLEMA UPDATE cdv_despesa_km_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        LET l_impede_excl = TRUE
        EXIT FOREACH
     END IF

  END FOREACH
  FREE cq_excl_ad_km

  IF l_impede_excl THEN
     RETURN FALSE, l_msg
  ELSE
     RETURN TRUE , l_msg
  END IF

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2013_viagem_possui_acerto(l_cod_empresa, l_viagem)
#--------------------------------------------------------------#

  DEFINE l_cod_empresa       LIKE empresa.cod_empresa,
         l_viagem            INTEGER,
         l_msg               CHAR(80)

  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cdv_acer_viag_781
    WHERE empresa = l_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        LET l_msg = 'AD referente a adiantamento já relacionado a acerto de viagem (pamcary)'
        RETURN TRUE, l_msg
     WHEN 100
        RETURN FALSE, l_msg
     OTHERWISE
        LET l_msg =  'PROBLEMA SELECT cdv_acer_viag_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        RETURN TRUE, l_msg
  END CASE

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2013_viagem_possui_transf(l_cod_empresa, l_viagem)
#--------------------------------------------------------------#

  DEFINE l_cod_empresa       LIKE empresa.cod_empresa,
         l_viagem            INTEGER,
         l_msg               CHAR(80)

{  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cdv_dev_transf_781
    WHERE empresa    = l_cod_empresa
      AND viagem     = l_viagem
      AND val_transf IS NOT NULL
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        LET l_msg = 'Este acerto de viagem transferiu valor, exclua 1º a viagem recebedora (pamcary)'
        RETURN TRUE, l_msg
     WHEN 100
        RETURN FALSE, l_msg
     OTHERWISE
        LET l_msg =  'PROBLEMA SELECT cdv_dev_transf_781, SQLCA.SQLCODE: ', SQLCA.SQLCODE
        RETURN TRUE, l_msg
  END CASE
} #acertar esta lógica
RETURN FALSE, l_msg

END FUNCTION

#-------------------------------#
 FUNCTION cdv2013_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv2013.4gl $|$Revision: 3 $|$Date: 23/12/11 12:22 $|$Modtime: 15/07/09 19:59 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

