###PARSER-N�o remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS                         #
# PROGRAMA: CDV2000                                                 #
# OBJETIVO: MANUTEN��O ACERTO DESPESA DE VIAGENS - PAMCARY          #
# AUTOR...: JULIANO TE�FILO CABRAL DA MAIA                          #
# DATA....: 05/07/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa               LIKE empresa.cod_empresa,
         g_ies_ambiente              LIKE w_log0250.ies_ambiente,
         p_user                      LIKE usuario.nom_usuario,
         p_ies_impressao             CHAR(01),
         p_status                    SMALLINT,
         p_nom_arquivo               CHAR(100),
         p_versao                    CHAR(18),
         g_ies_grafico               SMALLINT,
         g_ies_forn_lanc_mut_cap069  CHAR(01),
         g_cdv0060                   CHAR(01), #Alterado spec.2
         p_user1                     CHAR(08)

  DEFINE g_lote_pgto_div             LIKE lote_pagamento.cod_lote_pgto,
         g_cond_pgto_km              LIKE cond_pgto_cap.cnd_pgto,
         g_linha_grade               SMALLINT, #Alterado spec.2
         g_num_versao_grade          SMALLINT  #Alterado spec.2

  DEFINE t_aen_309_4  ARRAY[200] OF RECORD
         val_aen             LIKE ad_aen_4.val_aen,
         cod_lin_prod        LIKE ad_aen_4.cod_lin_prod,
         cod_lin_recei       LIKE ad_aen_4.cod_lin_recei,
         cod_seg_merc        LIKE ad_aen_4.cod_seg_merc,
         cod_cla_uso         LIKE ad_aen_4.cod_cla_uso
  END RECORD

 DEFINE t_aen_309_conta_4     ARRAY[200] OF RECORD
                                 num_seq              LIKE ad_aen_conta_4.num_seq,
                                 num_seq_lanc         LIKE ad_aen_conta_4.num_seq_lanc,
                                 ies_tipo_lanc        LIKE ad_aen_conta_4.ies_tipo_lanc,
                                 num_conta_cont       LIKE ad_aen_conta_4.num_conta_cont,
                                 ies_fornec_trans     LIKE ad_aen_conta_4.ies_fornec_trans,
                                 cod_lin_prod         LIKE ad_aen_conta_4.cod_lin_prod,
                                 cod_lin_recei        LIKE ad_aen_conta_4.cod_lin_recei,
                                 cod_seg_merc         LIKE ad_aen_conta_4.cod_seg_merc,
                                 cod_cla_uso          LIKE ad_aen_conta_4.cod_cla_uso,
                                 val_aen              LIKE ad_aen_conta_4.val_aen
                              END RECORD

  DEFINE t_wlancon323  ARRAY[500] OF RECORD
         cod_empresa         LIKE lanc_cont_cap.cod_empresa,
         num_ad_ap           LIKE lanc_cont_cap.num_ad_ap,
         ies_tipo_lanc       LIKE lanc_cont_cap.ies_tipo_lanc,
         num_conta_cont      LIKE lanc_cont_cap.num_conta_cont,
         val_lanc            LIKE lanc_cont_cap.val_lanc,
         tex_hist_lanc       LIKE lanc_cont_cap.tex_hist_lanc,
         ies_cnd_pgto        LIKE lanc_cont_cap.ies_cnd_pgto,
         dat_lanc            LIKE lanc_cont_cap.dat_lanc
  END RECORD

  #INICIO OS.470958
  DEFINE g_last_row         SMALLINT,
         g_comando          CHAR(500)
  #FIM OS.470958

END GLOBALS

#MODULARES
  DEFINE m_caminho                      CHAR(150),
         m_comando                      CHAR(150),
         m_path_help                    CHAR(150),
         m_excl_cons                    CHAR(02),
         m_funcao                       CHAR(10),
         m_atividade_bloqueada          LIKE cdv_ativ_781.ativ,
         m_consulta_ativa               SMALLINT,
         m_show_option                  SMALLINT,
         m_cod_emp_plano                LIKE empresa.cod_empresa,
         m_urbanas_ativa                SMALLINT,
         m_km_ativa                     SMALLINT,
         m_terc_ativa                   SMALLINT,
         m_origem                       CHAR(01),
         m_resumo_ativo                 SMALLINT,
         m_den_empresa                  LIKE empresa.den_reduz,
         m_inicia_acerto                SMALLINT,
         m_alterou_viagem               SMALLINT,
         m_tip_desp_reem                LIKE tipo_despesa.cod_tip_despesa,
         m_tip_desp_rest                LIKE tipo_despesa.cod_tip_despesa,
         m_tip_desp_acerto              LIKE tipo_despesa.cod_tip_despesa,
         m_ult_viag_terc                LIKE cdv_desp_terc_781.viagem,
         m_tip_desp_adto_viag           LIKE tipo_despesa.cod_tip_despesa,
         m_hor_ini_diurna               DATETIME HOUR TO SECOND,
         m_hor_ini_noturna              DATETIME HOUR TO SECOND,
         m_td_km_semanal                LIKE tipo_despesa.cod_tip_despesa,
         m_segmto_mercado_pamcary       LIKE ad_aen_4.cod_seg_merc,
         m_classe_uso_pamcary           LIKE ad_aen_4.cod_cla_uso,
         m_empresa_atendida_pamcary     LIKE empresa.cod_empresa,
         m_segundo_nivel_aen            LIKE ad_aen_4.cod_lin_recei,
         m_controle_minimo              LIKE cdv_acer_viag_781.controle,
         m_h_pad_restitui_cap           LIKE cdv_par_ctr_viagem.h_pad_restitui_cap,
         m_tip_val_transf               LIKE cdv_par_ctr_viagem.tip_val_transf,
         m_cliente_atendido             LIKE cdv_acer_viag_781.cliente_destino,
         m_cliente_fatur                LIKE cdv_acer_viag_781.cliente_destino,
         m_emite_solic_viagem           LIKE cdv_par_ctr_viagem.emite_solic_viagem,
         m_den_acerto                   CHAR(25),
         m_consulta_desp_km_ativa       SMALLINT,
         m_data                         DATE,
         m_viagem_urbanas               LIKE cdv_acer_viag_781.viagem,
         m_den_empresa_atendida         LIKE empresa.den_reduz,
         m_den_filial_atendida          LIKE empresa.den_reduz,
         m_tip_processo                 LIKE cdv_controle_781.tip_processo,
         m_des_cidade_origem            LIKE cidades.den_cidade,
         m_des_cidade_destino           LIKE cidades.den_cidade

  DEFINE mr_input, mr_inputr  RECORD
         empresa              LIKE cdv_acer_viag_781.empresa,
         viagem               LIKE cdv_acer_viag_781.viagem,
         controle             LIKE cdv_acer_viag_781.controle,
         dat_emis_relat       DATE,
         hr_emis_relat        DATETIME HOUR TO MINUTE,
         des_status           CHAR(25),
         viajante             LIKE cdv_acer_viag_781.viajante,
         nom_viajante         CHAR(30),
         finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
         des_fin_viagem       CHAR(45),
         cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
         des_cc_viajante      CHAR(25),
         ad_acerto_conta      LIKE ad_mestre.num_ad,
         cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
         des_cc_debitar       CHAR(25),
         ap_acerto_conta      LIKE ap.num_ap,
         cliente_destino      LIKE cdv_acer_viag_781.cliente_destino,
         des_cli_destino      CHAR(36),
         cliente_debitar      LIKE cdv_acer_viag_781.cliente_debitar,
         des_cli_debitar      CHAR(36),
         empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
         filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
         trajeto_principal    CHAR(54),
         dat_partida          DATE,
         hor_partida          DATETIME HOUR TO MINUTE,
         dat_retorno          DATE,
         hor_retorno          DATETIME HOUR TO MINUTE,
         motivo_viagem1       CHAR(50),
         motivo_viagem2       CHAR(50),
         motivo_viagem3       CHAR(50),
         motivo_viagem4       CHAR(50)
  END RECORD

  DEFINE mr_consulta    RECORD
         viagem_de            LIKE cdv_acer_viag_781.viagem,
         viagem_ate           LIKE cdv_acer_viag_781.viagem,
         controle_de          LIKE cdv_acer_viag_781.controle,
         controle_ate         LIKE cdv_acer_viag_781.controle,
         viajante             LIKE cdv_acer_viag_781.viajante,
         nom_viajante         CHAR(30),
         cliente_destino      LIKE cdv_acer_viag_781.cliente_destino,
         des_cli_destino      CHAR(36),
         cliente_debitar      LIKE cdv_acer_viag_781.cliente_debitar,
         des_cli_debitar      CHAR(36),
         status_acer          LIKE cdv_acer_viag_781.status_acer_viagem,
         des_status           CHAR(30),
         dat_partida_de       DATE,
         dat_partida_ate      DATE,
         dat_retorno_de       DATE,
         dat_retorno_ate      DATE
  END RECORD

  DEFINE mr_viag_terc RECORD
                      viagem               LIKE cdv_acer_viag_781.viagem,
                      controle             LIKE cdv_acer_viag_781.controle
                      END RECORD

  DEFINE mr_solic RECORD
         viagem               LIKE cdv_acer_viag_781.viagem,
         controle             LIKE cdv_acer_viag_781.controle,
         viajante             LIKE cdv_acer_viag_781.viajante,
         finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
         cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
         cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
         cliente_atendido     LIKE cdv_acer_viag_781.cliente_destino,
         cliente_fatur        LIKE cdv_acer_viag_781.cliente_debitar,
         empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
         filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
         trajeto_principal    LIKE cdv_acer_viag_781.trajeto_principal,
         dat_hor_partida      LIKE cdv_acer_viag_781.dat_hor_partida,
         dat_hor_retorno      LIKE cdv_acer_viag_781.dat_hor_retorno,
         motivo_viagem        LIKE cdv_acer_viag_781.motivo_viagem,
         tip_cliente          LIKE cdv_controle_781.tip_cliente #OS 487356

  END RECORD

  DEFINE mr_desp_urbana RECORD
         controle       LIKE cdv_acer_viag_781.controle,
         viagem         LIKE cdv_acer_viag_781.viagem,
         tot_geral      DECIMAL(12,2)
  END RECORD

  DEFINE mr_dev_transf, mr_dev_transfr  RECORD
                       controle            LIKE cdv_dev_transf_781.controle_receb,
                       viagem              LIKE cdv_dev_transf_781.viagem,
                       tot_adiant          LIKE cdv_dev_transf_781.val_devolucao,
                       tot_desp            LIKE cdv_dev_transf_781.val_devolucao,
                       status              LIKE cdv_dev_transf_781.eh_status_acerto,
                       den_status          CHAR(50),
                       val_devolucao       LIKE cdv_dev_transf_781.val_devolucao,
                       dat_devolucao       LIKE cdv_dev_transf_781.dat_devolucao,
                       forma               LIKE cdv_dev_transf_781.forma_devolucao,
                       den_forma           CHAR(50),
                       doc_devolucao       LIKE cdv_dev_transf_781.docum_devolucao,
                       dat_doc_devolucao   LIKE cdv_dev_transf_781.dat_doc_devolucao,
                       caixa               LIKE cdv_dev_transf_781.caixa,
                       den_caixa           LIKE ctrl_caixa.den_caixa,
                       cta_corrente        LIKE cdv_dev_transf_781.cta_corrente,
                       banco               LIKE cdv_dev_transf_781.banco,
                       den_banco           LIKE bancos.nom_banco,
                       val_transf          LIKE cdv_dev_transf_781.val_transf,
                       dat_transf          LIKE cdv_dev_transf_781.dat_transf,
                       viagem_receb        LIKE cdv_dev_transf_781.viagem_receb,
                       controle_receb      LIKE cdv_dev_transf_781.controle_receb,
                       agencia             LIKE cdv_dev_transf_781.agencia,
                       observacao          LIKE cdv_dev_transf_781.observacao
                       END RECORD

  DEFINE mr_desp_km RECORD
         controle         LIKE cdv_acer_viag_781.controle,
         viagem           LIKE cdv_acer_viag_781.viagem,
         preco_km         DECIMAL(12,2)
  END RECORD

  DEFINE mr_desp_terc, mr_desp_tercr RECORD
         controle          LIKE cdv_acer_viag_781.controle,
         viagem            LIKE cdv_acer_viag_781.viagem,
         viagem_origem     LIKE cdv_desp_terc_781.viagem_origem,
         ad_terceiro       LIKE cdv_desp_terc_781.ad_terceiro,
         previsao          CHAR(01),
         ap_terceiro       DECIMAL(6,0),
         sequencia         LIKE cdv_desp_terc_781.seq_desp_terceiro,
         ativ              LIKE cdv_desp_terc_781.ativ,
         des_ativ          LIKE cdv_ativ_781.des_ativ,
         tip_despesa       LIKE cdv_desp_terc_781.tip_despesa,
         des_tip_despesa   LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
         nota_fiscal       LIKE cdv_desp_terc_781.nota_fiscal,
         serie_nota_fiscal LIKE cdv_desp_terc_781.serie_nota_fiscal,
         subserie_nf       LIKE cdv_desp_terc_781.subserie_nf,
         fornecedor        LIKE cdv_desp_terc_781.fornecedor,
         den_fornecedor    CHAR(30),
         dat_inclusao      LIKE cdv_desp_terc_781.dat_inclusao,
         dat_vencto        LIKE cdv_desp_terc_781.dat_vencto,
         val_desp_terceiro LIKE cdv_desp_terc_781.val_desp_terceiro,
         observacao        LIKE cdv_desp_terc_781.observacao,
         tot_desp_terceiro LIKE cdv_desp_terc_781.val_desp_terceiro
  END RECORD

  DEFINE mr_resumo, mr_resumor   RECORD
         controle            LIKE cdv_acer_viag_781.controle,
         viagem              LIKE cdv_acer_viag_781.viagem,
         viajante            LIKE cdv_acer_viag_781.viajante,
         nom_viajante        CHAR(30),
         cliente_debitar     LIKE cdv_acer_viag_781.cliente_debitar,
         des_cli_debitar     CHAR(30),
         dat_partida         CHAR(10),
         dat_retorno         CHAR(10),
         cc_debitar          LIKE cdv_acer_viag_781.cc_debitar,
         finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         des_fin_viagem      CHAR(45),
         tot_km_semanal      DECIMAL(17,2),
         tot_terceiros       DECIMAL(17,2),
         tot_adtos           DECIMAL(17,2),
         tot_desp_urbanas    DECIMAL(17,2),
         tot_desp_km         DECIMAL(17,2),
         qtd_km_semanal      DECIMAL(17,2),
         qtd_hor_semanal     CHAR(09),
         tot_despesas        DECIMAL(17,2),
         saldo               DECIMAL(17,2),
         saldo_transf        DECIMAL(17,2),
         dat_dev_transf      DATE,
         controle_receb      LIKE cdv_acer_viag_781.controle,
         viagem_receb        LIKE cdv_acer_viag_781.viagem
  END RECORD

  DEFINE ma_desp_urbana ARRAY[200] OF RECORD
         ativ           LIKE cdv_desp_urb_781.ativ,
         des_ativ       CHAR(20),
         tipo_despesa   LIKE cdv_desp_urb_781.tip_despesa_viagem,
         des_tip_desp   CHAR(35),
         num_documento  LIKE cdv_desp_urb_781.docum_viagem,
         dat_documento  LIKE cdv_desp_urb_781.dat_despesa_urbana,
         val_documento  LIKE cdv_desp_urb_781.val_despesa_urbana,
         placa          LIKE cdv_desp_urb_781.placa, #OS 487356
         observacao     LIKE cdv_desp_urb_781.obs_despesa_urbana
  END RECORD

  DEFINE ma_desp_km ARRAY[200] OF RECORD
         ativ             LIKE cdv_despesa_km_781.ativ_km,
         des_ativ         CHAR(20),
         tipo_despesa_km  LIKE cdv_despesa_km_781.tip_despesa_viagem,
         des_tip_desp_km  CHAR(31),
         trajeto          LIKE cdv_despesa_km_781.trajeto,
         placa            LIKE cdv_despesa_km_781.placa,
         cidade_origem      CHAR(05), #OS 520395
         des_cidade_origem  LIKE cidades.den_cidade, #OS 520395
         cidade_destino     CHAR(05), #OS 520395
         des_cidade_destino LIKE cidades.den_cidade, #OS 520395
         km_inicial       LIKE cdv_despesa_km_781.km_inicial,
         km_final         LIKE cdv_despesa_km_781.km_final,
         qtd_km           LIKE cdv_despesa_km_781.qtd_km,
         val_km           LIKE cdv_despesa_km_781.val_km,
         ad_km            LIKE cdv_despesa_km_781.apropr_desp_km,
         ap_km            DECIMAL(6,0),
         tipo_despesa_hr  LIKE cdv_apont_hor_781.tdesp_apont_hor,
         des_tip_desp_hr  CHAR(19),
         hor_inicial      LIKE cdv_apont_hor_781.hor_inicial,
         hor_final        LIKE cdv_apont_hor_781.hor_final,
         motivo           LIKE cdv_apont_hor_781.motivo,
         des_motivo       CHAR(19),
         hor_diurnas      LIKE cdv_apont_hor_781.hor_diurnas,
         hor_noturnas     LIKE cdv_apont_hor_781.hor_noturnas,
         dat_apont_hor    LIKE cdv_apont_hor_781.dat_apont_hor,
         obs_apont_hor    LIKE cdv_apont_hor_781.obs_apont_hor
  END RECORD

  DEFINE mr_proc_dev_transf RECORD
         val_devolucao       LIKE cdv_dev_transf_781.val_devolucao,
         val_transf          LIKE cdv_dev_transf_781.val_transf,
         viagem_receb        LIKE cdv_dev_transf_781.viagem_receb ,
         forma_devolucao     LIKE cdv_dev_transf_781.forma_devolucao,
         caixa               LIKE cdv_dev_transf_781.caixa,
         dat_doc_devolucao   LIKE cdv_dev_transf_781.dat_doc_devolucao,
         banco               LIKE cdv_dev_transf_781.banco,
         agencia             LIKE cdv_dev_transf_781.agencia,
         cta_corrente        LIKE cdv_dev_transf_781.cta_corrente
  END RECORD

  DEFINE ma_atividades ARRAY[200] OF RECORD
                          ativ       LIKE cdv_ativ_781.ativ
                       END RECORD

  DEFINE m_tot_adiant            LIKE cdv_solic_adto_781.val_adto_viagem,
         m_tot_desp              LIKE cdv_solic_adto_781.val_adto_viagem,
         m_empresa               LIKE cdv_solic_viag_781.empresa,
         m_viagem                LIKE cdv_solic_viag_781.viagem,
         m_previa_viagem         LIKE cdv_solic_viag_781.viagem,
         m_previa_controle       LIKE cdv_solic_viag_781.controle,
         m_consulta_urb_aut      SMALLINT,
         m_consulta_km_aut       SMALLINT,
         m_msg                   CHAR(100)

  #INICIO OS.470958
  DEFINE m_tipo_despesa           LIKE tipo_despesa.cod_tip_despesa
  DEFINE m_val_total              LIKE cdv_despesa_km_781.val_km,
         m_data_p                 DATE,
         m_data_r                 DATE

  DEFINE mr_apont_km              RECORD
                                  cod_empresa     LIKE empresa.cod_empresa,
                                  den_empresa     LIKE empresa.den_empresa,
                                  num_matricula   LIKE cdv_info_viajante.matricula,
                                  nom_viajante    LIKE usuarios.nom_funcionario,
                                  periodo_ini     DATE,
                                  periodo_fim     DATE
                                  END RECORD
  #FIM OS.470958

  DEFINE m_lote_pgto_km_sem   DECIMAL(2,0) # 743235
#END MODULARES

MAIN

  CALL log0180_conecta_usuario()

  LET p_versao = "CDV2000-10.02.00p"

  WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 120
  WHENEVER ERROR STOP

  DEFER INTERRUPT

  LET m_path_help = log140_procura_caminho("cdv2000.iem")

  OPTIONS
    FIELD    ORDER UNCONSTRAINED,
    DELETE   KEY  control-e,
     INSERT   KEY control-i,
    PREVIOUS KEY  control-b,
    NEXT     KEY  control-f,
    HELP FILE m_path_help

  CALL log001_acessa_usuario("CDV","LOGERP;LOGLQ2")
     RETURNING p_status, p_cod_empresa, p_user

  LET p_user1 = p_user
  INITIALIZE m_empresa, m_viagem  TO NULL

  IF p_status = 0  THEN
     CALL cdv2000_controle()
  END IF

END MAIN

#--------------------------#
 FUNCTION cdv2000_controle()
#--------------------------#
  DEFINE l_ad_acerto_conta    LIKE cdv_acer_viag_781.ad_acerto_conta,
         l_usuario_logix      LIKE cdv_info_viajante.usuario_logix

  CALL log006_exibe_teclas("01", p_versao)

  LET m_caminho = log1300_procura_caminho('cdv2000','cdv2000')
  OPEN WINDOW w_cdv2000 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa

  CALL cdv2000_cria_temp()
  IF NOT cdv2000_carrega_parametros() THEN
     RETURN
  END IF

  IF NUM_ARGS() > 0 THEN
     LET m_excl_cons     = ARG_VAL(1)
     LET m_empresa       = arg_val(2)
     LET m_viagem        = arg_val(3)

     IF m_empresa IS NOT NULL THEN
        LET p_cod_empresa = m_empresa
     END IF

     IF m_excl_cons IS NULL OR m_excl_cons = 'CO' THEN
        #CALL cdv2000_consulta()
        #RETURN
     ELSE
        LET mr_input.viagem = m_viagem
        CALL cdv2000_exclusao()
     END IF
  END IF

  INITIALIZE mr_input.*, mr_inputr.* TO NULL

  LET m_show_option    = TRUE
  LET m_inicia_acerto  = FALSE
  LET m_consulta_ativa = FALSE
  #LET m_alterou_viagem = FALSE

  MENU "OP��O"

    BEFORE MENU
      IF m_excl_cons = 'CO' THEN
         CALL cdv2000_consulta()
      END IF

    COMMAND "Incluir" "Inclus�o de acerto de viagem."
      HELP 001
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV",'CDV2000',"IN")  THEN
         SHOW OPTION "iNiciar acerto"
         SHOW OPTION "1-apont desp/SOS"
         SHOW OPTION "apont Km/horas"
         SHOW OPTION "apont Terceiros"
         SHOW OPTION "Resumo"
         SHOW OPTION "finalizar acertO"
         LET m_inicia_acerto = TRUE
         CALL cdv2000_inclusao_acerto_sem_solic()
      END IF

    COMMAND "Modificar" "Modifica��o de acerto de viagem."
      HELP 002
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV",'CDV2000',"MO")  THEN
         IF m_consulta_ativa THEN
            CALL cdv2000_busca_viajante(mr_input.viagem) RETURNING l_usuario_logix

            IF p_user = l_usuario_logix THEN
               LET m_inicia_acerto = FALSE
               CALL cdv2000_modificacao_acerto_sem_solic()
            ELSE
               IF m_emite_solic_viagem = "N" THEN
                  LET m_inicia_acerto = FALSE
                  CALL cdv2000_modificacao_acerto_sem_solic()
               ELSE
                  CALL log0030_mensagem("Apenas o viajante pode alterar o seu pr�prio acerto.","exclamation")
               END IF
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND "Excluir" "Exclus�o de acerto de viagem."
      HELP 003
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV",'CDV2000',"EX")  THEN
         IF m_consulta_ativa THEN
            CALL cdv2000_busca_viajante(mr_input.viagem) RETURNING l_usuario_logix
            IF p_user = l_usuario_logix THEN
               CALL cdv2000_exclusao()
            ELSE
               IF m_emite_solic_viagem = "N" THEN
                  CALL cdv2000_exclusao()
               ELSE
                  CALL log0030_mensagem("Apenas o viajante pode excluir o seu pr�prio acerto.","exclamation")
               END IF
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND "Consultar" "Consulta acertos de viagem."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"CO")  THEN
         SHOW OPTION "iNiciar acerto"
         SHOW OPTION "1-apont desp/SOS"
         SHOW OPTION "apont Km/horas"
         SHOW OPTION "apont Terceiros"
         SHOW OPTION "Resumo"
         SHOW OPTION "finalizar acertO"
         CALL cdv2000_consulta()
      END IF

    COMMAND "Seguinte"   "Exibe o pr�ximo acerto encontrado na consulta."
      HELP 005
      MESSAGE ""
      SHOW OPTION "iNiciar acerto"
      SHOW OPTION "1-apont desp/SOS"
      SHOW OPTION "apont Km/horas"
      SHOW OPTION "apont Terceiros"
      SHOW OPTION "Resumo"
      SHOW OPTION "finalizar acertO"
      CALL cdv2000_paginacao("SEGUINTE")

    COMMAND "Anterior"   "Exibe o acerto anterior encontrado na consulta."
      HELP 006
      MESSAGE ""
      SHOW OPTION "iNiciar acerto"
      SHOW OPTION "1-apont desp/SOS"
      SHOW OPTION "apont Km/horas"
      SHOW OPTION "apont Terceiros"
      SHOW OPTION "Resumo"
      SHOW OPTION "finalizar acertO"
      CALL cdv2000_paginacao("ANTERIOR")

    COMMAND "Listar"   "Emite o relat�rio de acerto de viagem."
      HELP 007
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"CO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' THEN
               CALL log0030_mensagem("N�o � permitida impress�o de viagem com status pendente.","exclamation")
            END IF

            IF mr_input.des_status = 'ACERTO VIAGEM INICIADO' THEN
               CALL log0030_mensagem("N�o � permitida impress�o de viagem com status iniciado.","exclamation")
            END IF

            IF  mr_input.des_status <> 'ACERTO VIAGEM PENDENTE'
            AND mr_input.des_status <> 'ACERTO VIAGEM INICIADO' THEN
               CALL cdv2000_lista_despesa_viagem()
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('N') "iNiciar acerto"   "Inicia confec��o acerto de viagem."
      HELP 009
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"IN")  THEN
         IF m_consulta_ativa THEN
            CALL cdv2000_busca_viajante(mr_input.viagem) RETURNING l_usuario_logix

            IF p_user = l_usuario_logix THEN
               LET m_inicia_acerto = TRUE
               CALL cdv2000_inicia_acerto()
               IF NOT m_show_option THEN
                  HIDE OPTION "iNiciar acerto"
                  HIDE OPTION "1-apont desp/SOS"
                  HIDE OPTION "apont Km/horas"
                  HIDE OPTION "apont Terceiros"
                  HIDE OPTION "finalizar acertO"
               END IF
            ELSE
               IF m_emite_solic_viagem = "N" THEN
			               LET m_inicia_acerto = TRUE
			               CALL cdv2000_inicia_acerto()
			               IF NOT m_show_option THEN
			                  HIDE OPTION "iNiciar acerto"
			                  HIDE OPTION "1-apont desp/SOS"
			                  HIDE OPTION "apont Km/horas"
			                  HIDE OPTION "apont Terceiros"
			                  HIDE OPTION "finalizar acertO"
			               END IF
               ELSE
                  CALL log0030_mensagem("Apenas o viajante pode iniciar o seu pr�prio acerto.","exclamation")
               END IF
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('1') "1-apont desp/SOS"   "Manuten��o despesas urbanas."
      HELP 010
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"MO") THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               IF NOT cdv2000_eh_viagem_terc(mr_input.viagem) THEN
                  CALL cdv2000_manut_despesas_urbanas()
               ELSE
                  CALL log0030_mensagem("Esta viagem � de terceiros e n�o pode possuir outros apontamentos.","exclamation")
               END IF
            ELSE
               CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('K') "apont Km/horas"   "Manuten��o despesas quilometragem."
      HELP 011
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"MO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               IF NOT cdv2000_eh_viagem_terc(mr_input.viagem) THEN
                  CALL cdv2000_manut_despesas_km()
               ELSE
                  CALL log0030_mensagem("Esta viagem � de terceiros e n�o pode possuir outros apontamentos.","exclamation")
               END IF
            ELSE
               CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('T') "apont Terceiros"   "Manuten��o despesas terceiros."
      HELP 012
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"MO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               IF NOT cdv2000_existe_outros_apont(mr_input.viagem) THEN
                  LET m_origem = 'N'
                  CALL cdv2000_manut_despesas_terceiros()
               ELSE
                  IF log0040_confirm(5,10,'Viagem j� possui apontamentos, deseja criar uma nova viagem para o apontamento de terceiro?') THEN
                     LET m_origem = 'S'
                  ELSE
                     LET m_origem = 'N'
                  END IF
                  CALL cdv2000_manut_despesas_terceiros()
               END IF
            ELSE
               CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('R') "Resumo"   "Apresenta��o resumo das despesas X adiantamentos."
      HELP 013
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"CO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               CALL cdv2000_exibe_resumo()
            ELSE
               CALL log0030_mensagem('Viagem n�o possui acerto.','exclamation')
               NEXT OPTION "iNiciar acerto"
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('D') "Dev. transf."   "Manuten��o da devolu��o / transfer�ncia."
      HELP 014
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"CO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               IF cdv2000_verifica_saldo() THEN
                  CALL log0030_mensagem('N�o existe saldo para devolu��o/adiantamento.','exclamation')
               ELSE
                  CALL cdv2000_busca_viajante(mr_input.viagem) RETURNING l_usuario_logix

                  IF p_user = l_usuario_logix THEN
                     CALL cdv2000_dev_transf()
                  ELSE
                     IF m_emite_solic_viagem = "N" THEN
                        CALL cdv2000_dev_transf()
                     ELSE
                        CALL log0030_mensagem("Apenas o viajante pode efetuar a devolu��o/transfer�ncia do seu pr�prio acerto.","exclamation")
                     END IF
                  END IF
               END IF
            ELSE
               CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY('O') "finalizar acertO"   "Finaliza acerto de viagem."
      HELP 015
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV", 'cdv2000',"MO")  THEN
         IF m_consulta_ativa THEN
            IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
               #IF m_alterou_viagem THEN
                  CALL cdv2000_busca_viajante(mr_input.viagem) RETURNING l_usuario_logix

                  IF p_user = l_usuario_logix THEN
                     CALL cdv2000_finaliza_acerto()
                  ELSE
                     IF m_emite_solic_viagem = "N" THEN
                        CALL cdv2000_finaliza_acerto()
                     ELSE
                        CALL log0030_mensagem("Apenas o viajante pode efetuar a finaliza��o do seu pr�prio acerto.","exclamation")
                     END IF
                  END IF

               #ELSE
               #   CALL log0030_mensagem("Somente � permitido finalizar viagens que foram inclu�das, iniciadas ou modificadas nesse momento.","exclamation")
               #END IF
            ELSE
               CALL log0030_mensagem('Viagem n�o possui acerto.','exclamation')
               NEXT OPTION "iNiciar acerto"
            END IF
         ELSE
            CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
            NEXT OPTION "Consultar"
         END IF
      END IF

    COMMAND KEY("P") "aProvantes" "Informa��es complementares."
      HELP 019
      MESSAGE ""
      IF m_consulta_ativa THEN
         WHENEVER ERROR CONTINUE
          SELECT ad_acerto_conta
            INTO l_ad_acerto_conta
            FROM cdv_acer_viag_781
           WHERE empresa = p_cod_empresa
             AND viagem  = mr_solic.viagem
         WHENEVER ERROR STOP

         IF SQLCA.sqlcode = 0 THEN
            IF l_ad_acerto_conta IS NOT NULL
            OR l_ad_acerto_conta <> " " THEN
               CALL log120_procura_caminho("cap3450") RETURNING m_comando
               LET m_comando = m_comando CLIPPED, " ", l_ad_acerto_conta, " ", p_cod_empresa, " cap0220 "
               RUN m_comando
            ELSE
               CALL log120_procura_caminho("cap0309") RETURNING m_comando
               LET m_comando = m_comando CLIPPED, " ", mr_input.viagem, " ", p_cod_empresa, " "
               RUN m_comando
            END IF
         ELSE
            CALL log0030_mensagem("Acerto ainda n�o finalizado.","exclamation")
         END IF
         CALL log006_exibe_teclas('01 09', p_versao)
         CURRENT WINDOW IS w_cdv2000
      ELSE
         CALL log0030_mensagem(' N�o existe nenhuma consulta ativa. ','info')
      END IF

    #INICIO OS.470958
    COMMAND KEY ("2") "2-Autoriz_pgto" "Executa o programa cap0160 para visualizar as informa��es da AP."
       HELP 021
       MESSAGE " "
       CALL log120_procura_caminho("cap0160") RETURNING m_comando
       LET m_comando = m_comando CLIPPED, " ", mr_input.ap_acerto_conta,
                                          " ", mr_input.empresa

       RUN m_comando RETURNING p_status
       LET p_status = p_status / 256
       IF p_status = 0 THEN
       ELSE
          PROMPT "Tecle ENTER para continuar" FOR m_comando
       END IF
    #FIM OS.470958

    COMMAND KEY ('!')
      PROMPT "Digite o m_comando : " FOR m_comando
      RUN m_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
      DATABASE logix

    COMMAND "Fim" "Retorna ao menu anterior."
      HELP 008
      EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_cdv2000

END FUNCTION

#----------------------------#
 FUNCTION cdv2000_cria_temp()
#----------------------------#

  WHENEVER ERROR CONTINUE
   DROP TABLE w_solic
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE w_solic
   (viagem               INTEGER,
    controle             DECIMAL(20,0),
    viajante             INTEGER,
    finalidade_viagem    CHAR(05),
    cc_viajante          INTEGER,
    cc_debitar           INTEGER,
    cliente_atendido     CHAR(15),
    cliente_fatur        CHAR(15),
    empresa_atendida     CHAR(2),
    filial_atendida      CHAR(2),
    trajeto_principal    CHAR(200),
    dat_hor_partida      DATETIME YEAR TO SECOND,
    dat_hor_retorno      DATETIME YEAR TO SECOND,
    motivo_viagem        CHAR(200)) WITH NO LOG;
  WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_carrega_parametros()
#-------------------------------------#
  DEFINE l_status    SMALLINT

 WHENEVER ERROR CONTINUE
  SELECT emite_solic_viagem
    INTO m_emite_solic_viagem
    FROM cdv_par_ctr_viagem
   WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET m_emite_solic_viagem = "N"
 END IF

  WHENEVER ERROR CONTINUE
   SELECT cod_empresa_plano
     INTO m_cod_emp_plano
     FROM par_con
    WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','par_con')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT tip_desp_acer_cta, tip_desp_adto_viag, tip_val_transf, h_pad_restitui_cap
     INTO m_tip_desp_rest, m_tip_desp_adto_viag, m_tip_val_transf, m_h_pad_restitui_cap
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','cdv_par_ctr_viagem')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_val
     INTO m_tip_desp_reem
     FROM cdv_par_padrao
    WHERE empresa = p_cod_empresa
      AND parametro = "tip_desp_acer_reem"
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     LET m_tip_desp_reem = m_tip_desp_rest
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_num
     INTO g_lote_pgto_div
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "cod_lote_pgto_div"
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cod_lote_pgto_div')
     RETURN FALSE
  END IF

  #--inicio--OS 743235 #
  CALL log2250_busca_parametro(p_cod_empresa,'lote_pgto_km_sem')
     RETURNING m_lote_pgto_km_sem, l_status
  IF NOT l_status OR m_lote_pgto_km_sem IS NULL THEN
     INITIALIZE m_lote_pgto_km_sem TO NULL
  END IF
  #---fim----OS 743235 #

  CALL log2250_busca_parametro(p_cod_empresa,'hora_inicial_diurna_pamcary')
     RETURNING m_hor_ini_diurna, l_status
  IF NOT l_status OR m_hor_ini_diurna IS NULL THEN
     LET m_hor_ini_diurna = '06:00:00'
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'hora_inicial_noturna_pamcary')
     RETURNING m_hor_ini_noturna, l_status
  IF NOT l_status OR m_hor_ini_noturna IS NULL THEN
     LET m_hor_ini_noturna = '18:00:00'
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'td_km_semanal_pamcary')
     RETURNING m_td_km_semanal, l_status
  IF NOT l_status OR m_td_km_semanal IS NULL THEN
     CALL log0030_mensagem('Tipo de despesa para gera��o AD KM semanal n�o cadastrado.','exclamation')
     RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'cond_pgto_pamcary')
     RETURNING g_cond_pgto_km, l_status
  IF NOT l_status OR g_cond_pgto_km IS NULL THEN
     CALL log0030_mensagem('Condi��o de pagamento para gera��o AD KM semanal n�o cadastrada.','exclamation')
     RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'segmto_mercado_pamcary')
     RETURNING m_segmto_mercado_pamcary, l_status
  IF NOT l_status OR m_segmto_mercado_pamcary IS NULL THEN
     CALL log0030_mensagem('Segmento de mercado (AEN para devolu��o) n�o cadastrado.','exclamation')
     RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'classe_uso_pamcary')
     RETURNING m_classe_uso_pamcary, l_status
  IF NOT l_status OR m_classe_uso_pamcary IS NULL THEN
     CALL log0030_mensagem('Classe de uso (AEN para devolu��o) n�o cadastrado.','exclamation')
     RETURN FALSE
  END IF

  INITIALIZE m_tipo_despesa TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"td_refeicao")
       RETURNING m_tipo_despesa, p_status

  IF p_status = FALSE
  OR m_tipo_despesa IS NULL
  OR m_tipo_despesa = " " THEN
     CALL log0030_mensagem('Tipo de despesa de refei��o n�o cadastrada (LOG2240).','exclamation')
     RETURN FALSE
  END IF

  INITIALIZE m_tipo_despesa TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"tip_desp_acer_viag")
       RETURNING m_tip_desp_acerto, p_status

  IF p_status = FALSE
  OR m_tip_desp_acerto IS NULL
  OR m_tip_desp_acerto = " " THEN
     CALL log0030_mensagem('Tipo de despesa do acerto n�o cadastrado (LOG2240).','exclamation')
     RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'td_despesa_terceiro_pamcary')
     RETURNING m_controle_minimo, l_status
  IF NOT l_status OR m_controle_minimo IS NULL THEN
     LET m_controle_minimo = 0
     #CALL log0030_mensagem('Tipo de despesa para ADs despesas de terceiros n�o cadastrada.','exclamation')
     #RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'ativ_bloq_apont_hm')
     RETURNING m_atividade_bloqueada, l_status
  IF NOT l_status
  OR m_atividade_bloqueada IS NULL
  OR m_atividade_bloqueada = ' ' THEN
     CALL log0030_mensagem('Atividade bloqueada n�o cadastrada (LOG2240).','exclamation')
     #RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_cursor_for_update()
#------------------------------------#
  WHENEVER ERROR CONTINUE
   DECLARE cm_cr_viagem CURSOR FOR
     SELECT empresa
       FROM cdv_acer_viag_781
      WHERE empresa = p_cod_empresa
        AND viagem  = mr_input.viagem
   FOR UPDATE
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cm_cr_viagem')
     RETURN FALSE
  END IF

  CALL log085_transacao("BEGIN")

  WHENEVER ERROR CONTINUE
   OPEN cm_cr_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('OPEN','cm_cr_viagem')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FETCH cm_cr_viagem
  WHENEVER ERROR STOP

  CASE SQLCA.SQLCODE
    WHEN 0
       RETURN TRUE
    WHEN -250
       CALL log0030_mensagem('Registro sendo atualizado por outro usu�rio. Aguarde e tente novamente.','exclamation')
    WHEN 100
       CALL log0030_mensagem('Registro n�o existe ou n�o esta liberado. Execute a CONSULTA novamente.','exclamation')
    OTHERWISE
       CALL log003_err_sql("LEITURA","cdv_acer_viag_781")
  END CASE

  CALL log085_transacao("ROLLBACK")

  CLOSE cm_cr_viagem
  FREE cm_cr_viagem

  RETURN FALSE

END FUNCTION


#--------------------------------#
 FUNCTION cdv2000_consiste_ex_mo()
#--------------------------------#

  DEFINE l_work                SMALLINT,
         l_ad_terceiro         LIKE ad_mestre.num_ad,
         l_ad_km_semanal       LIKE ad_mestre.num_ad,
         l_ap_terceiro         LIKE ap.num_ap,
         l_ap_km_semanal       LIKE ap.num_ap,
         l_status              SMALLINT,
         l_val_transf          DECIMAL(17,2),
         l_controle_receb      LIKE cdv_dev_transf_781.controle_receb,
         l_viagem_receb        LIKE cdv_dev_transf_781.viagem_receb,
         l_viagem_orig         LIKE cdv_dev_transf_781.viagem_receb,
         l_ad_acer_viag_orig   LIKE ad_mestre.num_ad,
         l_msg                 CHAR(100)

 IF cdv2000_verifica_acerto_fat() THEN #Alterado spec.2
    RETURN FALSE
 END IF

 # Verifica as AD's de terceiro.
 WHENEVER ERROR CONTINUE
  DECLARE cq_desp_terc_ex SCROLL CURSOR FOR
   SELECT ad_terceiro
     FROM cdv_desp_terc_781
    WHERE empresa = mr_input.empresa
      AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP
 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('DECLARE','cq_desp_terc_ex')
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_desp_terc_ex INTO l_ad_terceiro
 WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('FOREACH','cq_desp_terc_ex')
       EXIT FOREACH
    END IF

    IF cdv2000_verifica_ad_ap_paga(l_ad_terceiro, 1) THEN
       LET l_msg = "Viagem faturada ou em processo de pagamento, n�o � permitida manuten��o."  #"A AD ", l_ad_terceiro, " de terceiros j� possui pagamento(s) efetivado(s)."
       CALL log0030_mensagem(l_msg,"exclamation")
       RETURN FALSE
    END IF

 END FOREACH

 # Verifica as AD's de km semanal.
 WHENEVER ERROR CONTINUE
  DECLARE cq_km_semanal_ex CURSOR FOR
   SELECT apropr_desp_km
     FROM cdv_despesa_km_781
    WHERE empresa = mr_input.empresa
      AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP
 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('DECLARE','cq_km_semanal_ex')
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_km_semanal_ex INTO l_ad_km_semanal
 WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('FOREACH','cq_km_semanal_ex')
       EXIT FOREACH
    END IF

    IF cdv2000_verifica_ad_ap_paga(l_ad_km_semanal, 2) THEN
       LET l_msg = "Viagem faturada ou em processo de pagamento, n�o � permitida manuten��o." #"A AD ", l_ad_km_semanal, " de KM est� em processo de pagamento."
       CALL log0030_mensagem(l_msg,"exclamation")
       RETURN FALSE
    END IF

 END FOREACH

 IF cdv2000_verifica_ad_ap_paga(mr_input.ad_acerto_conta, 1) THEN
    LET l_msg = "Viagem faturada ou em processo de pagamento, n�o � permitida manuten��o." #"A AD ", mr_input.ad_acerto_conta, " de acerto j� possui pagamento(s) efetivado(s)."
    CALL log0030_mensagem(l_msg,"exclamation")
    RETURN FALSE
 END IF

 CALL cdv2000_verifica_viagem_possui_transferencia(mr_input.viagem)
    RETURNING l_viagem_orig, l_ad_acer_viag_orig

 IF l_viagem_orig IS NOT NULL THEN #viagem a qual transferiu valor para a viagem corrente

    IF cdv2000_verifica_ad_ap_paga(l_ad_acer_viag_orig, 2) THEN
       LET l_msg = "Viagem faturada ou em processo de pagamento, n�o � permitida manuten��o." #"A AD ", l_ad_acer_viag_orig, " de transfer�ncia est� em processo de pagamento."
       CALL log0030_mensagem(l_msg,"exclamation")
       RETURN FALSE
    END IF

 END IF

 RETURN TRUE
 END FUNCTION

#---------------------------#
 FUNCTION cdv2000_exclusao()
#---------------------------#
  DEFINE l_work                SMALLINT,
         l_ad_terceiro         LIKE ad_mestre.num_ad,
         l_ad_km_semanal       LIKE ad_mestre.num_ad,
         l_ap_terceiro         LIKE ap.num_ap,
         l_ap_km_semanal       LIKE ap.num_ap,
         l_status              SMALLINT,
         l_val_transf          DECIMAL(17,2),
         l_controle_receb      LIKE cdv_dev_transf_781.controle_receb,
         l_viagem_receb        LIKE cdv_dev_transf_781.viagem_receb,
         l_viagem_orig         LIKE cdv_dev_transf_781.viagem_receb,
         l_ad_acer_viag_orig   LIKE ad_mestre.num_ad,
         l_msg                 CHAR(100)

  IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' THEN
     CALL log0030_mensagem("N�o existe acerto de despesa para esta viagem.",'exclamation')
     RETURN
  END IF

  IF cdv2000_eh_viagem_terc(mr_input.viagem) THEN
     CALL log0030_mensagem("Exclus�o n�o permitida pois esta � uma viagem exclusiva de terceiros. Manuten��o atrav�s do apontamento.","exclamation")
     RETURN
  END IF

  IF NOT cdv2000_consiste_ex_mo() THEN
     RETURN
  END IF

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2000

  IF m_excl_cons IS NULL THEN
     IF NOT log0040_confirm(19,34,"Confirma exclus�o do acerto ?") THEN
        ERROR "Exclus�o cancelada."
        RETURN
     END IF
  END IF

  # Excluir AD's terceiro.
  WHENEVER ERROR CONTINUE
   FOREACH cq_desp_terc_ex INTO l_ad_terceiro
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_desp_terc_ex')
        EXIT FOREACH
     END IF

     CALL cdv2000_recupera_primeira_ap(l_ad_terceiro)
        RETURNING l_status, l_ap_terceiro

     IF NOT cdv2000_exclui_despesa_no_cap(l_ad_terceiro, l_ap_terceiro) THEN
        ERROR "Exclus�o cancelada."
        RETURN
     END IF
  END FOREACH

  # Excluir AD's km semanal.
  WHENEVER ERROR CONTINUE
   FOREACH cq_km_semanal_ex INTO l_ad_km_semanal
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_km_semanal_ex')
        EXIT FOREACH
     END IF

     CALL cdv2000_recupera_primeira_ap(l_ad_km_semanal)
        RETURNING l_status, l_ap_km_semanal

     IF NOT cdv2000_exclui_despesa_no_cap(l_ad_km_semanal, l_ap_km_semanal) THEN
        ERROR "Exclus�o cancelada."
        RETURN
     END IF
  END FOREACH

  IF NOT cdv2000_exclui_despesa_no_cap(mr_input.ad_acerto_conta, mr_input.ap_acerto_conta) THEN
     ERROR "Exclus�o cancelada."
     RETURN
  ELSE
     INITIALIZE mr_input.ad_acerto_conta TO NULL
     DISPLAY BY NAME mr_input.ad_acerto_conta
  END IF

  IF l_viagem_orig IS NOT NULL THEN
     CALL cdv2000_recupera_primeira_ap(l_ad_acer_viag_orig)
        RETURNING l_status, l_ap_terceiro
     IF NOT cdv2000_exclui_despesa_no_cap(l_ad_acer_viag_orig, l_ap_terceiro) THEN
        ERROR "Exclus�o cancelada."
        RETURN
     END IF
  END IF

  IF cdv2000_cursor_for_update() THEN

     LET l_work = TRUE

     MESSAGE "Excluindo acerto de despesa de viagem . . ." ATTRIBUTE(REVERSE)

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_desp_urb_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_desp_urb_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_despesa_km_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_despesa_km_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_apont_hor_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_despesa_km_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_desp_terc_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_desp_terc_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_dev_transf_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_dev_transf_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_aprov_viag_781
       WHERE empresa = mr_input.empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_aprov_viag_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE             #Alterado spec.2
      DELETE FROM cdv_intg_fat_781
       WHERE empresa             = mr_input.empresa
         AND viagem              = mr_input.viagem
         AND grp_despesa_viagem <> '6'
         #OS 487356
         AND grp_despesa_viagem <> '11'
         AND grp_despesa_viagem <> '12'
         #---
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_intg_fat_781")
        LET l_work = FALSE
     END IF

     WHENEVER ERROR CONTINUE
     SELECT empresa
       FROM cdv_solic_viag_781
      WHERE empresa = mr_input.empresa
        AND viagem  = mr_input.viagem
        AND viagem IN (SELECT viagem
                        FROM cdv_solic_adto_781
                       WHERE empresa = mr_input.empresa
                         AND viagem  = mr_input.viagem)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 100 THEN
        WHENEVER ERROR CONTINUE
        DELETE FROM cdv_solic_viag_781
         WHERE empresa = mr_input.empresa
           AND viagem  = mr_input.viagem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("DELETE","cdv_solic_viag_781")
           LET l_work = FALSE
        END IF

     ELSE
        CALL log0030_mensagem("Solicita��o dever� ser excluida pelo CDV2001 pois possui adiantamento(s).","info")
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_acer_viag_781
       WHERE CURRENT OF cm_cr_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
        CALL log003_err_sql("DELETE","cdv_relat_viagem")
        LET l_work = FALSE
     END IF

     IF NOT cdv2000_insere_cdv_protocol("Relat�rio de acerto de despesas cancelado.") THEN
        LET l_work = FALSE
     END IF

     IF l_work THEN
        CALL log085_transacao("COMMIT")
        MESSAGE "Exclus�o efetuada com sucesso." ATTRIBUTE(REVERSE)
        INITIALIZE mr_input.* TO NULL
        DISPLAY BY NAME mr_input.*

        DISPLAY '' TO den_empresa_atendida
        DISPLAY '' TO den_filial_atendida

        LET m_consulta_ativa = FALSE
     ELSE
        CALL log085_transacao("ROLLBACK")
        ERROR 'Exclus�o cancelada.'
     END IF
  ELSE
     ERROR 'Exclus�o cancelada.'
  END IF

  ERROR ""

  CLOSE cm_cr_viagem
  FREE cm_cr_viagem

END FUNCTION

#---------------------------#
 FUNCTION cdv2000_consulta()
#---------------------------#

  LET m_caminho = log1300_procura_caminho('cdv20001','cdv20001')
  OPEN WINDOW w_cdv20001 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL log006_exibe_teclas("01 02 07 ",p_versao)
  CURRENT WINDOW IS w_cdv20001

  DISPLAY p_cod_empresa TO empresa

  IF m_excl_cons = 'CO' THEN
     INITIALIZE m_excl_cons TO NULL

     INITIALIZE mr_consulta.* TO NULL

     LET mr_consulta.viagem_de  = m_viagem
     LET mr_consulta.viagem_ate = m_viagem

     DISPLAY BY NAME mr_consulta.viagem_de,
                     mr_consulta.viagem_ate

     IF NOT cdv2000_efetua_consulta() THEN
        ERROR 'Consulta cancelada.'
        RETURN
     ELSE

        CLOSE WINDOW w_cdv20001
        CURRENT WINDOW IS w_cdv2000

        CALL cdv2000_paginacao("SEGUINTE")
        #OS 459347
        #PROMPT "Tecle ENTER para voltar a tela anterior." FOR m_comando
        RETURN
     END IF
  END IF

  IF NOT cdv2000_entrada_dados_consulta() THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF

  CURRENT WINDOW IS w_cdv2000
  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa
  CURRENT WINDOW IS w_cdv20001
  LET m_consulta_ativa = FALSE

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv20001

  CLOSE WINDOW w_cdv20001
  CURRENT WINDOW IS w_cdv2000

  IF NOT cdv2000_efetua_consulta() THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF

  CALL cdv2000_paginacao("SEGUINTE")

  LET m_show_option = TRUE

END FUNCTION

#-----------------------#
 FUNCTION cdv2000_help()
#-----------------------#

  OPTIONS HELP FILE m_path_help

  CASE
     WHEN INFIELD(controle)           CALL SHOWHELP(101)
     WHEN INFIELD(viajante)           CALL SHOWHELP(102)
     WHEN INFIELD(finalidade_viagem)  CALL SHOWHELP(103)
     WHEN INFIELD(cc_debitar)         CALL SHOWHELP(104)
     WHEN INFIELD(cliente_destino)    CALL SHOWHELP(105)
     WHEN INFIELD(cliente_debitar)    CALL SHOWHELP(106)
     WHEN INFIELD(empresa_atendida)   CALL SHOWHELP(107)
     WHEN INFIELD(filial_atendida)    CALL SHOWHELP(108)
     WHEN INFIELD(trajeto_principal)  CALL SHOWHELP(109)
     WHEN INFIELD(dat_partida)        CALL SHOWHELP(110)
     WHEN INFIELD(hor_partida)        CALL SHOWHELP(111)
     WHEN INFIELD(dat_retorno)        CALL SHOWHELP(112)
     WHEN INFIELD(hor_retorno)        CALL SHOWHELP(113)
     WHEN INFIELD(motivo_viagem1)     CALL SHOWHELP(114)
     WHEN INFIELD(motivo_viagem2)     CALL SHOWHELP(114)
     WHEN INFIELD(motivo_viagem3)     CALL SHOWHELP(114)
     WHEN INFIELD(motivo_viagem4)     CALL SHOWHELP(114)

     WHEN INFIELD(viagem_de)          CALL SHOWHELP(115)
     WHEN INFIELD(viagem_ate)         CALL SHOWHELP(116)
     WHEN INFIELD(controle_de)        CALL SHOWHELP(117)
     WHEN INFIELD(controle_ate)       CALL SHOWHELP(118)
     WHEN INFIELD(status_acer)        CALL SHOWHELP(122)
     WHEN INFIELD(dat_partida_de)     CALL SHOWHELP(123)
     WHEN INFIELD(dat_partida_ate)    CALL SHOWHELP(124)
     WHEN INFIELD(dat_retorno_de)     CALL SHOWHELP(123)
     WHEN INFIELD(dat_retorno_ate)    CALL SHOWHELP(124)

     WHEN INFIELD(viagem)             CALL SHOWHELP(127)
     WHEN INFIELD(ativ)               CALL SHOWHELP(128)
     WHEN INFIELD(tipo_despesa)       CALL SHOWHELP(129)
     WHEN INFIELD(num_documento)      CALL SHOWHELP(130)
     WHEN INFIELD(dat_documento)      CALL SHOWHELP(131)
     WHEN INFIELD(val_documento)      CALL SHOWHELP(132)
     WHEN INFIELD(placa)              CALL SHOWHELP(166)#OS 487356
     WHEN INFIELD(observacao)         CALL SHOWHELP(133)

     WHEN INFIELD(tipo_despesa_km)    CALL SHOWHELP(134)
     WHEN INFIELD(trajeto)            CALL SHOWHELP(135)
     WHEN INFIELD(placa)              CALL SHOWHELP(136)
     WHEN INFIELD(cidade_origem)      CALL SHOWHELP(167) #OS 520395
     WHEN INFIELD(cidade_destino)     CALL SHOWHELP(168) #OS 520395
     WHEN INFIELD(km_inicial)         CALL SHOWHELP(137)
     WHEN INFIELD(km_final)           CALL SHOWHELP(138)
     WHEN INFIELD(tipo_despesa_hr)    CALL SHOWHELP(139)
     WHEN INFIELD(hor_inicial)        CALL SHOWHELP(140)
     WHEN INFIELD(hor_final)          CALL SHOWHELP(141)
     WHEN INFIELD(motivo)             CALL SHOWHELP(142)
     WHEN INFIELD(dat_apont_hor)      CALL SHOWHELP(143)
     WHEN INFIELD(obs_apont_hor)      CALL SHOWHELP(144)

     WHEN INFIELD(tip_despesa)        CALL SHOWHELP(129)
     WHEN INFIELD(nota_fiscal)        CALL SHOWHELP(145)
     WHEN INFIELD(serie_nota_fiscal)  CALL SHOWHELP(146)
     WHEN INFIELD(subserie_nf)        CALL SHOWHELP(147)
     WHEN INFIELD(fornecedor)         CALL SHOWHELP(148)
     WHEN INFIELD(dat_inclusao)       CALL SHOWHELP(149)
     WHEN INFIELD(dat_vencto)         CALL SHOWHELP(150)
     WHEN INFIELD(val_desp_terceiro)  CALL SHOWHELP(151)

     WHEN INFIELD(status)             CALL SHOWHELP(154)
     WHEN INFIELD(dat_devolucao)      CALL SHOWHELP(155)
     WHEN INFIELD(forma)              CALL SHOWHELP(156)
     WHEN INFIELD(doc_devolucao)      CALL SHOWHELP(157)
     WHEN INFIELD(dat_doc_devolucao)  CALL SHOWHELP(158)
     WHEN INFIELD(caixa)              CALL SHOWHELP(159)
     WHEN INFIELD(observacao)         CALL SHOWHELP(160)
     WHEN INFIELD(dat_transf)         CALL SHOWHELP(161)
     WHEN INFIELD(viagem_receb)       CALL SHOWHELP(162)

     WHEN INFIELD(cod_empresa)        CALL SHOWHELP(163)
     WHEN INFIELD(num_matricula)      CALL SHOWHELP(164)
     WHEN INFIELD(periodo_ini)        CALL SHOWHELP(165)
     WHEN INFIELD(periodo_fim)        CALL SHOWHELP(165)

  END CASE

END FUNCTION

#--------------------------------#
 FUNCTION cdv2000_popup(l_funcao)
#--------------------------------#
  DEFINE l_funcao            CHAR(10),
         l_viajante          LIKE cdv_acer_viag_781.viajante,
         l_cliente           LIKE cdv_acer_viag_781.cliente_debitar,
         l_empresa           LIKE empresa.cod_empresa,
         l_finalidade_viagem LIKE cdv_acer_viag_781.finalidade_viagem,
         l_parametros        CHAR(3000),
         l_controle          LIKE cdv_acer_viag_781.controle,
         l_viagem            LIKE cdv_acer_viag_781.viagem,
         l_first_time        SMALLINT,
         l_string_procurada  CHAR(20),
         sql_stmt            CHAR(1000),
         l_tipo_despesa_km   LIKE cdv_despesa_km_781.tip_despesa_viagem,
         l_where_clause      CHAR(300),
         l_ind               SMALLINT,
         l_viagem_pesq       LIKE cdv_acer_viag_781.viagem,
         l_controle_pesq     LIKE cdv_acer_viag_781.controle,
         l_ativ              LIKE cdv_ativ_781.ativ,
         l_tip_despesa       LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_fornecedor        LIKE fornecedor.cod_fornecedor,
         l_status            CHAR(01)

#OS 520395
  DEFINE l_cidade_origem     CHAR(05),
         l_cidade_destino    CHAR(05)
#---------

  IF INFIELD(controle) AND l_funcao = 'INCLUSAO' THEN
     RETURN
  END IF

  CASE l_funcao
     WHEN 'INCLUSAO'
        LET l_viagem_pesq   = mr_input.viagem
        LET l_controle_pesq = mr_input.controle
     WHEN 'URBANAS'
        LET l_viagem_pesq   = mr_desp_urbana.viagem
        LET l_controle_pesq = mr_desp_urbana.controle
     WHEN 'KM'
        LET l_viagem_pesq   = mr_desp_km.viagem
        LET l_controle_pesq = mr_desp_km.controle
     WHEN 'TERC'
        LET l_viagem_pesq   = mr_desp_terc.viagem
        LET l_controle_pesq = mr_desp_terc.controle
     WHEN 'RESUMO'
        LET l_viagem_pesq   = mr_resumo.viagem
        LET l_controle_pesq = mr_resumo.controle
     WHEN 'DEV'
        LET l_viagem_pesq   = mr_dev_transf.viagem
        LET l_controle_pesq = mr_dev_transf.controle
  END CASE

  CASE
     WHEN infield(viajante)
        LET l_viajante = cdv0033_popup_matricula_viaj(p_cod_empresa)
        IF l_funcao = 'CONSULTA' THEN
           CURRENT WINDOW IS w_cdv20001
           IF l_viajante IS NOT NULL THEN
              LET mr_consulta.viajante = l_viajante
              DISPLAY BY NAME mr_consulta.viajante
           END IF
        ELSE
           CURRENT WINDOW IS w_cdv2000
           IF l_viajante IS NOT NULL THEN
              LET mr_input.viajante = l_viajante
              DISPLAY BY NAME mr_input.viajante
           END IF
        END IF

     WHEN infield(cliente_destino)
        LET l_cliente = vdp372_popup_cliente()
        IF l_funcao = 'CONSULTA' THEN
           CURRENT WINDOW IS w_cdv20001
           IF l_cliente IS NOT NULL THEN
              LET mr_consulta.cliente_destino = l_cliente
              DISPLAY BY NAME mr_consulta.cliente_destino
           END IF
        ELSE
           CURRENT WINDOW IS w_cdv2000
           IF l_cliente IS NOT NULL THEN
              LET mr_input.cliente_destino = l_cliente
              DISPLAY BY NAME mr_input.cliente_destino
           END IF
        END IF

     WHEN infield(cliente_debitar)
        LET l_cliente = vdp372_popup_cliente()
        IF l_funcao = 'CONSULTA' THEN
           CURRENT WINDOW IS w_cdv20001
           IF l_cliente IS NOT NULL THEN
              LET mr_consulta.cliente_debitar = l_cliente
              DISPLAY BY NAME mr_consulta.cliente_debitar
           END IF
        ELSE
           CURRENT WINDOW IS w_cdv2000
           IF l_cliente IS NOT NULL THEN
              LET mr_input.cliente_debitar = l_cliente
              DISPLAY BY NAME mr_input.cliente_debitar
           END IF
        END IF

      WHEN INFIELD(status_acer)
         LET mr_consulta.status_acer = log0830_list_box(10,6,
        '1 {ACERTO PENDENTE},2 {ACERTO INICIADO},3 {PENDENTE/INICIADO},4 {ACERTO FINALIZADO},5 {ACERTO LIBERADO},6 {TODOS}')
         CURRENT WINDOW IS w_cdv20001
         DISPLAY BY NAME mr_consulta.status_acer

      WHEN INFIELD(empresa_atendida)
         LET l_empresa = cdv0084_popup_cod_empresa(FALSE, "MAT", '')
         CURRENT WINDOW IS w_cdv2000
         IF l_empresa IS NOT NULL THEN
            LET mr_input.empresa_atendida = l_empresa
            DISPLAY BY NAME mr_input.empresa_atendida
         END IF

      WHEN INFIELD(filial_atendida)
         LET l_empresa = cdv0084_popup_cod_empresa(FALSE, "FIL", mr_input.empresa_atendida)
         CURRENT WINDOW IS w_cdv2000
         IF l_empresa IS NOT NULL THEN
            LET mr_input.filial_atendida = l_empresa
            DISPLAY BY NAME mr_input.filial_atendida
         END IF

      WHEN INFIELD(finalidade_viagem)
         LET l_finalidade_viagem = log009_popup(07,05,               -- Linha/Coluna da Janela
                                               "FINALIDADE VIAGEM",  -- Cabecalho da Janela
                                               "cdv_finalidade_781", -- Nome da Tabela no Sistema
                                               "finalidade",         -- Nome da Primeira Coluna
                                               "des_finalidade",     -- Nome da Segunda  Coluna
                                               "cdv2006",            -- Nome do Prog.Manutencao
                                               "S",                  -- Testa cod_empresa (S/N) ?
                                               "")                   -- Where Clause do Select

         CURRENT WINDOW IS w_cdv2000
         IF l_finalidade_viagem IS NOT NULL THEN
            LET mr_input.finalidade_viagem = l_finalidade_viagem
            DISPLAY BY NAME mr_input.finalidade_viagem
         END IF

     WHEN INFIELD(cc_debitar)
        LET l_viajante = cdv0072_popup_cod_cad_cc(p_cod_empresa)
        IF l_viajante IS NOT NULL THEN
           CURRENT WINDOW IS w_cdv2000
           LET mr_input.cc_debitar = l_viajante
           DISPLAY BY NAME mr_input.cc_debitar
        END IF

     WHEN INFIELD(controle)
        LET l_first_time = TRUE

        LET sql_stmt = 'SELECT UNIQUE controle FROM w_solic'
        #IF l_viagem_pesq IS NOT NULL THEN
        #   LET sql_stmt = sql_stmt clipped, ' WHERE viagem = ', l_viagem_pesq
        #ELSE
           LET sql_stmt = sql_stmt clipped, ' WHERE 1=1'
        #END IF

        WHENEVER ERROR CONTINUE
        PREPARE var_popup_ctrl FROM sql_stmt
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("PREPARE","VAR_POPUP_CTRL")
        END IF

        WHENEVER ERROR CONTINUE
        DECLARE cq_popup_ctrl CURSOR FOR var_popup_ctrl
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("DECLARE","CQ_POPUP_CTRL")
        END IF

        WHENEVER ERROR CONTINUE
        FOREACH cq_popup_ctrl INTO l_controle
        WHENEVER ERROR STOP

           IF l_controle IS NULL THEN
              CONTINUE FOREACH
           END IF

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("FOREACH","CQ_POPUP_CTRL")
              EXIT FOREACH
           END IF

           WHENEVER ERROR CONTINUE
            SELECT MIN(viagem)
              INTO l_viagem
              FROM w_solic
             WHERE controle = l_controle
           WHENEVER ERROR STOP

           LET l_string_procurada = '%',l_controle USING "<<<<<<<<<<<<<<<<<<&",'%'
           IF (l_parametros LIKE l_string_procurada CLIPPED) THEN
              CONTINUE FOREACH
           END IF

           IF l_first_time THEN
              LET l_first_time = FALSE
              LET l_parametros = l_viagem,' {', l_controle USING "<<<<<<<<<<<<<<<<<<&", '}'
           ELSE
              LET l_parametros = l_parametros CLIPPED, ',', l_viagem,' {',
                                 l_controle USING "<<<<<<<<<<<<<<<<<<&", '}'
           END IF
        END FOREACH
        FREE cq_popup_ctrl

        IF l_parametros IS NOT NULL THEN
           LET l_viagem = log0830_list_box(10,6,l_parametros CLIPPED)
        END IF

        IF l_viagem IS NOT NULL THEN
           LET l_controle_pesq = cdv2000_recupera_controle(l_viagem)
        END IF

        CASE l_funcao
           WHEN 'INCLUSAO'
              LET mr_input.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv2000
              DISPLAY BY NAME mr_input.controle
           WHEN 'URBANAS'
              LET mr_desp_urbana.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv20002
              DISPLAY BY NAME mr_desp_urbana.controle
           WHEN 'KM'
              LET mr_desp_km.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv20003
              DISPLAY BY NAME mr_desp_km.controle
           WHEN 'TERC'
              LET mr_desp_terc.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv20004
              DISPLAY BY NAME mr_desp_terc.controle
           WHEN 'RESUMO'
              LET mr_resumo.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv20005
              DISPLAY BY NAME mr_resumo.controle
           WHEN 'DEV'
              LET mr_dev_transf.controle = l_controle_pesq
              CURRENT WINDOW IS w_cdv20006
              DISPLAY BY NAME mr_dev_transf.controle
        END CASE

     WHEN INFIELD(viagem)
        LET l_first_time = TRUE

        LET sql_stmt = 'SELECT UNIQUE viagem FROM w_solic'
        #IF l_controle_pesq IS NOT NULL THEN
        #   LET sql_stmt = sql_stmt clipped, ' WHERE controle = "',l_controle_pesq,'"'
        #ELSE
           LET sql_stmt = sql_stmt clipped, ' WHERE "1" = "1"'
        #END IF

        WHENEVER ERROR CONTINUE
        PREPARE var_popup_viag FROM sql_stmt
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("PREPARE","VAR_POPUP_VIAG")
        END IF

        WHENEVER ERROR CONTINUE
        DECLARE cq_popup_viagem CURSOR FOR var_popup_viag
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("DECLARE","CQ_POPUP_VIAGEM")
        END IF

        WHENEVER ERROR CONTINUE
        FOREACH cq_popup_viagem INTO l_viagem
        WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("FOREACH","CQ_POPUP_VIAGEM")
              EXIT FOREACH
           END IF

           LET l_string_procurada = '%',l_viagem,'%'
           IF (l_parametros LIKE l_string_procurada CLIPPED) THEN
              CONTINUE FOREACH
           END IF

           IF l_first_time THEN
              LET l_first_time = FALSE
              LET l_parametros = l_viagem,' {', l_viagem, '}'
           ELSE
              LET l_parametros = l_parametros CLIPPED, ',', l_viagem, ' {', l_viagem, '}'
           END IF
        END FOREACH
        FREE cq_popup_viagem

        IF l_parametros IS NOT NULL THEN
           LET l_viagem_pesq = log0830_list_box(10,6,l_parametros)
        END IF

        CASE l_funcao
           WHEN 'INCLUSAO'
              LET mr_input.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv2000
              DISPLAY BY NAME mr_input.viagem
           WHEN 'URBANAS'
              LET mr_desp_urbana.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv20002
              DISPLAY BY NAME mr_desp_urbana.viagem
           WHEN 'KM'
              LET mr_desp_km.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv20003
              DISPLAY BY NAME mr_desp_km.viagem
           WHEN 'TERC'
              LET mr_desp_terc.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv20004
              DISPLAY BY NAME mr_desp_terc.viagem
           WHEN 'RESUMO'
              LET mr_resumo.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv20005
              DISPLAY BY NAME mr_resumo.viagem
           WHEN 'DEV'
              LET mr_dev_transf.viagem = l_viagem_pesq
              CURRENT WINDOW IS w_cdv20006
              DISPLAY BY NAME mr_dev_transf.viagem
        END CASE

     WHEN INFIELD(ativ)
        LET l_ativ = cdv2000_popup_ativ()
        CURRENT WINDOW IS w_cdv20004
        IF l_ativ IS NOT NULL THEN
           LET mr_desp_terc.ativ = l_ativ
           DISPLAY BY NAME mr_desp_terc.ativ
        END IF

     WHEN INFIELD(tip_despesa)
        LET l_where_clause = ' grp_despesa_viagem = "4"',
                             ' AND ativ = ',mr_desp_terc.ativ

        LET l_tipo_despesa_km = cdv0802_popup_tip_desp_versus_ativ(p_cod_empresa, l_where_clause)
        CURRENT WINDOW IS w_cdv20004
        IF l_tipo_despesa_km IS NOT NULL THEN
           LET mr_desp_terc.tip_despesa = l_tipo_despesa_km
           DISPLAY BY NAME mr_desp_terc.tip_despesa
        END IF

     WHEN INFIELD(fornecedor)
        LET l_fornecedor = sup162_popup_fornecedor()
        CURRENT WINDOW IS w_cdv20004
        IF l_fornecedor IS NOT NULL THEN
           LET mr_desp_terc.fornecedor = l_fornecedor
           DISPLAY BY NAME mr_desp_terc.fornecedor
        END IF

     #POPUP DEV. TRANSF.#
     WHEN INFIELD(status)
         LET mr_dev_transf.status = log0830_list_box(10,6, 'D {Devolu��o},T {Transfer�ncia}')
         CURRENT WINDOW IS w_cdv20006
         DISPLAY BY NAME mr_dev_transf.status

     WHEN INFIELD(forma)
         LET mr_dev_transf.forma = log0830_list_box(10,6, '1 {Devolu��o banco},2 {Devolu��o caixa}')
         CURRENT WINDOW IS w_cdv20006
         DISPLAY BY NAME mr_dev_transf.forma

     WHEN INFIELD(caixa)
        LET mr_dev_transf.caixa  = cap431_popup_ctrl_caixa()
         CURRENT WINDOW IS w_cdv20006
        IF mr_dev_transf.caixa IS NOT NULL THEN
            DISPLAY BY NAME mr_dev_transf.caixa
        END IF
     #POPUP DEV. TRANSF.#

  END CASE

  LET INT_FLAG = FALSE
  CALL log006_exibe_teclas("01", p_versao)

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_valida_viajante(l_viajante)
#--------------------------------------------#

  DEFINE l_viajante         LIKE cdv_acer_viag_781.viajante,
         l_nom_funcionario  CHAR(30)
  DEFINE l_cod_funcio     LIKE cdv_fornecedor_fun.cod_funcio,
         l_cod_fornecedor LIKE fornecedor.cod_fornecedor

  LET l_cod_funcio = l_viajante

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_mensagem('Viajante n�o cadastrado.','exclamation')
     RETURN FALSE, ''
  END IF

  WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO l_nom_funcionario
    FROM fornecedor
   WHERE cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode = 100 THEN
        CALL log0030_mensagem('Fornecedor n�o cadastrado para este viajante.','exclamation')
        RETURN FALSE, ''
     ELSE
        CALL log003_err_sql('SELECT','fornecedor/cdv_info_viajante')
        RETURN FALSE, ''
     END IF
  END IF

  RETURN TRUE, l_nom_funcionario

END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2000_valida_cliente(l_cliente, l_mostra)
#---------------------------------------------------#
  DEFINE l_cliente       LIKE cdv_acer_viag_781.cliente_debitar,
         l_mostra        CHAR(01),
         l_nom_cliente   CHAR(36)

  WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cliente
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE, l_nom_cliente
     WHEN 100
        IF l_mostra = "S" THEN
           CALL log0030_mensagem('Cliente n�o cadastrado.','exclamation')
        END IF
        RETURN FALSE, ''
     OTHERWISE
        IF l_mostra = "S" THEN
           CALL log003_err_sql('SELECT','clientes')
        END IF
        RETURN FALSE, ''
  END CASE

END FUNCTION

#------------------------------------------#
 FUNCTION cdv2000_entrada_dados_consulta()
#------------------------------------------#

  DEFINE l_status  SMALLINT

  INITIALIZE mr_consulta.* TO NULL

  CALL log006_exibe_teclas("01 02 07 ",p_versao)
  CURRENT WINDOW IS w_cdv20001

  LET mr_consulta.status_acer = '6'
  CALL cdv2000_recupera_matricula_viajante()
       RETURNING p_status, mr_consulta.viajante

  LET INT_FLAG = 0
  INPUT BY NAME mr_consulta.* WITHOUT DEFAULTS

     BEFORE FIELD viagem_ate
        IF mr_consulta.viagem_ate IS NULL AND mr_consulta.viagem_de IS NOT NULL THEN
           LET mr_consulta.viagem_ate = mr_consulta.viagem_de
           DISPLAY BY NAME mr_consulta.viagem_ate
        END IF

     BEFORE FIELD controle_ate
        IF mr_consulta.controle_ate IS NULL AND mr_consulta.controle_de IS NOT NULL THEN
           LET mr_consulta.controle_ate = mr_consulta.controle_de
           DISPLAY BY NAME mr_consulta.controle_ate
        END IF

     BEFORE FIELD viajante
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     BEFORE FIELD cliente_destino
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     BEFORE FIELD cliente_debitar
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     BEFORE FIELD dat_partida_ate
        IF mr_consulta.dat_partida_ate IS NULL AND mr_consulta.dat_partida_de IS NOT NULL THEN
           LET mr_consulta.dat_partida_ate = mr_consulta.dat_partida_de
           DISPLAY BY NAME mr_consulta.dat_partida_ate
        END IF

     BEFORE FIELD dat_retorno_ate
        IF mr_consulta.dat_retorno_ate IS NULL AND mr_consulta.dat_retorno_de IS NOT NULL THEN
           LET mr_consulta.dat_retorno_ate = mr_consulta.dat_retorno_de
           DISPLAY BY NAME mr_consulta.dat_retorno_ate
        END IF

     AFTER FIELD viagem_ate
        IF mr_consulta.viagem_ate IS NOT NULL THEN
           IF mr_consulta.viagem_ate < mr_consulta.viagem_de THEN
              CALL log0030_mensagem("Viagem final deve ser igual/maior que viagem inicial.","exclamation")
              NEXT FIELD viagem_ate
           END IF
           IF mr_consulta.viagem_de IS NULL THEN
              CALL log0030_mensagem("Informe o limite inferior para a faixa de viagens.","exclamation")
              NEXT FIELD viagem_de
           END IF
        ELSE
           IF mr_consulta.viagem_de IS NOT NULL THEN
              CALL log0030_mensagem("Informe o limite superior para a faixa de viagens.","exclamation")
              NEXT FIELD viagem_ate
           END IF
        END IF

     AFTER FIELD controle_ate
        IF mr_consulta.controle_ate IS NOT NULL THEN
           IF mr_consulta.controle_ate < mr_consulta.controle_de THEN
              CALL log0030_mensagem("Controle final deve ser igual/maior que controle inicial.","exclamation")
              NEXT FIELD controle_ate
           END IF
           IF mr_consulta.controle_de IS NULL THEN
              CALL log0030_mensagem("Informe o limite inferior para a faixa de controles.","exclamation")
              NEXT FIELD controle_de
           END IF
        ELSE
           IF mr_consulta.controle_de IS NOT NULL THEN
              CALL log0030_mensagem("Informe o limite superior para a faixa de controles.","exclamation")
              NEXT FIELD controle_ate
           END IF
        END IF

     AFTER FIELD viajante
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_consulta.viajante IS NOT NULL THEN
           CALL cdv2000_valida_viajante(mr_consulta.viajante)
              RETURNING l_status, mr_consulta.nom_viajante
           IF NOT l_status THEN
              NEXT FIELD viajante
           ELSE
              DISPLAY BY NAME mr_consulta.nom_viajante
           END IF
        ELSE
           INITIALIZE mr_consulta.nom_viajante TO NULL
           DISPLAY BY NAME mr_consulta.nom_viajante
        END IF

     AFTER FIELD cliente_destino
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_consulta.cliente_destino IS NOT NULL THEN
           CALL cdv2000_valida_cliente(mr_consulta.cliente_destino, "N")
              RETURNING l_status, mr_consulta.des_cli_destino
           IF NOT l_status THEN
              NEXT FIELD cliente_destino
           ELSE
              DISPLAY BY NAME mr_consulta.des_cli_destino
           END IF
        ELSE
           INITIALIZE mr_consulta.des_cli_destino TO NULL
           DISPLAY BY NAME mr_consulta.des_cli_destino
        END IF

     AFTER FIELD cliente_debitar
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_consulta.cliente_debitar IS NOT NULL THEN
           CALL cdv2000_valida_cliente(mr_consulta.cliente_debitar, "S")
              RETURNING l_status, mr_consulta.des_cli_debitar
           IF NOT l_status THEN
              NEXT FIELD cliente_debitar
           ELSE
              DISPLAY BY NAME mr_consulta.des_cli_debitar
           END IF
        ELSE
           INITIALIZE mr_consulta.des_cli_debitar TO NULL
           DISPLAY BY NAME mr_consulta.des_cli_debitar
        END IF

     AFTER FIELD status_acer
        IF mr_consulta.status_acer IS NULL THEN
           LET mr_consulta.status_acer = 3
           DISPLAY BY NAME mr_consulta.status_acer
        ELSE
           IF NOT mr_consulta.status_acer MATCHES "[123456]" THEN
              CALL log0030_mensagem("Status inv�lido.","exclamation")
              NEXT FIELD status_acer
           END IF
        END IF
        CASE mr_consulta.status_acer
           WHEN 1 LET mr_consulta.des_status = 'ACERTO PENDENTE'
           WHEN 2 LET mr_consulta.des_status = 'ACERTO INICIADO'
           WHEN 3 LET mr_consulta.des_status = 'PENDENTE/INICIADO'
           WHEN 4 LET mr_consulta.des_status = 'ACERTO FINALIZADO'
           WHEN 5 LET mr_consulta.des_status = 'ACERTO LIBERADO'
           WHEN 6 LET mr_consulta.des_status = 'TODOS'
        END CASE
        DISPLAY BY NAME mr_consulta.des_status

     AFTER FIELD dat_partida_ate
        IF mr_consulta.dat_partida_ate IS NOT NULL THEN
           IF mr_consulta.dat_partida_ate < mr_consulta.dat_partida_de THEN
              CALL log0030_mensagem("Data partida final deve ser igual/maior que data partida inicial.","exclamation")
              NEXT FIELD dat_partida_ate
           END IF
           IF mr_consulta.dat_partida_de IS NULL THEN
              CALL log0030_mensagem("Informe o limite inferior para a faixa de data de partida.","exclamation")
              NEXT FIELD dat_partida_de
           END IF
        ELSE
           IF mr_consulta.dat_partida_de IS NOT NULL THEN
              CALL log0030_mensagem("Informe o limite superior para a faixa de data de partida.","exclamation")
              NEXT FIELD dat_partida_ate
           END IF
        END IF

     AFTER FIELD dat_retorno_ate
        IF mr_consulta.dat_retorno_ate IS NOT NULL THEN
           IF mr_consulta.dat_retorno_ate < mr_consulta.dat_retorno_de THEN
              CALL log0030_mensagem("Data retorno final deve ser igual/maior que data retorno inicial.","exclamation")
              NEXT FIELD dat_retorno_ate
           END IF
           IF mr_consulta.dat_retorno_de IS NULL THEN
              CALL log0030_mensagem("Informe o limite inferior para a faixa de data de retorno.","exclamation")
              NEXT FIELD dat_retorno_de
           END IF
        ELSE
           IF mr_consulta.dat_retorno_ate IS NOT NULL THEN
              CALL log0030_mensagem("Informe o limite superior para a faixa de data de retorno.","exclamation")
              NEXT FIELD dat_retorno_ate
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_consulta.viagem_ate IS NOT NULL THEN
              IF mr_consulta.viagem_ate < mr_consulta.viagem_de THEN
                 CALL log0030_mensagem("Viagem final deve ser igual/maior que viagem inicial.","exclamation")
                 NEXT FIELD viagem_ate
              END IF
              IF mr_consulta.viagem_de IS NULL THEN
                 CALL log0030_mensagem("Informe o limite inferior para a faixa de viagens.","exclamation")
                 NEXT FIELD viagem_de
              END IF
           ELSE
              IF mr_consulta.viagem_de IS NOT NULL THEN
                 CALL log0030_mensagem("Informe o limite superior para a faixa de viagens.","exclamation")
                 NEXT FIELD viagem_ate
              END IF
           END IF

           IF mr_consulta.controle_ate IS NOT NULL THEN
              IF mr_consulta.controle_ate < mr_consulta.controle_de THEN
                 CALL log0030_mensagem("Controle final deve ser igual/maior que controle inicial.","exclamation")
                 NEXT FIELD controle_ate
              END IF
              IF mr_consulta.controle_de IS NULL THEN
                 CALL log0030_mensagem("Informe o limite inferior para a faixa de controles.","exclamation")
                 NEXT FIELD controle_de
              END IF
           ELSE
              IF mr_consulta.controle_de IS NOT NULL THEN
                 CALL log0030_mensagem("Informe o limite superior para a faixa de controles.","exclamation")
                 NEXT FIELD controle_ate
              END IF
           END IF

           IF mr_consulta.viajante IS NOT NULL THEN
              CALL cdv2000_valida_viajante(mr_consulta.viajante)
                 RETURNING l_status, mr_consulta.nom_viajante
              IF NOT l_status THEN
                 NEXT FIELD viajante
              ELSE
                 DISPLAY BY NAME mr_consulta.nom_viajante
              END IF
           ELSE
              INITIALIZE mr_consulta.nom_viajante TO NULL
              DISPLAY BY NAME mr_consulta.nom_viajante
           END IF

           IF mr_consulta.cliente_destino IS NOT NULL THEN
              CALL cdv2000_valida_cliente(mr_consulta.cliente_destino, "N")
                 RETURNING l_status, mr_consulta.des_cli_destino
              IF NOT l_status THEN
                 #NEXT FIELD cliente_destino
              ELSE
                 DISPLAY BY NAME mr_consulta.des_cli_destino
              END IF
           ELSE
              INITIALIZE mr_consulta.des_cli_destino TO NULL
              DISPLAY BY NAME mr_consulta.des_cli_destino
           END IF

           IF mr_consulta.cliente_debitar IS NOT NULL THEN
              CALL cdv2000_valida_cliente(mr_consulta.cliente_debitar, "S")
                 RETURNING l_status, mr_consulta.des_cli_debitar
              IF NOT l_status THEN
                 NEXT FIELD cliente_debitar
              ELSE
                 DISPLAY BY NAME mr_consulta.des_cli_debitar
              END IF
           ELSE
              INITIALIZE mr_consulta.des_cli_debitar TO NULL
              DISPLAY BY NAME mr_consulta.des_cli_debitar
           END IF

           IF mr_consulta.status_acer IS NULL THEN
              LET mr_consulta.status_acer = 6
           ELSE
              IF NOT mr_consulta.status_acer MATCHES "[123456]" THEN
                 CALL log0030_mensagem("Status inv�lido.","exclamation")
                 NEXT FIELD status_acer
              END IF
           END IF
           CASE mr_consulta.status_acer
              WHEN 1 LET mr_consulta.des_status = 'VIAGEM PENDENTE'
              WHEN 2 LET mr_consulta.des_status = 'ACERTO INICIADO'
              WHEN 3 LET mr_consulta.des_status = 'PENDENTE/INICIADO'
              WHEN 4 LET mr_consulta.des_status = 'ACERTO FINALIZADO'
              WHEN 5 LET mr_consulta.des_status = 'ACERTO LIBERADO'
              WHEN 6 LET mr_consulta.des_status = 'TODOS'
           END CASE
           DISPLAY BY NAME mr_consulta.des_status

           IF mr_consulta.dat_partida_ate IS NOT NULL THEN
              IF mr_consulta.dat_partida_ate < mr_consulta.dat_partida_de THEN
                 CALL log0030_mensagem("Data partida final deve ser igual/maior que data partida inicial.","exclamation")
                 NEXT FIELD dat_partida_ate
              END IF
              IF mr_consulta.dat_partida_de IS NULL THEN
                 CALL log0030_mensagem("Informe o limite inferior para a faixa de data de partida.","exclamation")
                 NEXT FIELD dat_partida_de
              END IF
           ELSE
              IF mr_consulta.dat_partida_de IS NOT NULL THEN
                 CALL log0030_mensagem("Informe o limite superior para a faixa de data de partida.","exclamation")
                 NEXT FIELD dat_partida_ate
              END IF
           END IF

           IF mr_consulta.dat_retorno_ate IS NOT NULL THEN
              IF mr_consulta.dat_retorno_ate < mr_consulta.dat_retorno_de THEN
                 CALL log0030_mensagem("Data retorno final deve ser igual/maior que data retorno inicial.","exclamation")
                 NEXT FIELD dat_retorno_ate
              END IF
              IF mr_consulta.dat_retorno_de IS NULL THEN
                 CALL log0030_mensagem("Informe o limite inferior para a faixa de data de retorno.","exclamation")
                 NEXT FIELD dat_retorno_de
              END IF
           ELSE
              IF mr_consulta.dat_retorno_ate IS NOT NULL THEN
                 CALL log0030_mensagem("Informe o limite superior para a faixa de data de retorno.","exclamation")
                 NEXT FIELD dat_retorno_ate
              END IF
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup("CONSULTA")

  END INPUT

  RETURN NOT INT_FLAG

END FUNCTION

#----------------------------------#
 FUNCTION cdv2000_efetua_consulta()
#----------------------------------#
  DEFINE sql_stmt              CHAR(1000),
         l_data_char           CHAR(19),
         l_data_de             DATETIME YEAR TO SECOND,
         l_data_ate            DATETIME YEAR TO SECOND,
         l_status_acer_viagem  CHAR(02),
         l_qtd_solics          SMALLINT

  WHENEVER ERROR CONTINUE
   DELETE FROM w_solic
    WHERE 1 = 1
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','w_solic')
     RETURN FALSE
  END IF

  LET sql_stmt = 'SELECT viagem, controle, viajante, finalidade_viagem, cc_viajante,',
                       ' cc_debitar, cliente_atendido, cliente_fatur, empresa_atendida,',
                       ' filial_atendida, trajeto_principal, dat_hor_partida,',
                       ' dat_hor_retorno, motivo_viagem',
                  ' FROM cdv_solic_viag_781',
                 ' WHERE empresa = "',p_cod_empresa,'"'

  IF mr_consulta.viagem_de IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED,
                    ' AND (viagem BETWEEN ', mr_consulta.viagem_de, ' AND ', mr_consulta.viagem_ate, ' ',
                    '      OR viagem IN (SELECT UNIQUE viagem FROM cdv_desp_terc_781 ',
                    '                     WHERE empresa = "', p_cod_empresa, '" ',
                    '                       AND viagem_origem BETWEEN ', mr_consulta.viagem_de, ' AND ', mr_consulta.viagem_ate, ')) '
  END IF

  IF mr_consulta.controle_de IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED,
                    ' AND controle BETWEEN ', mr_consulta.controle_de, ' AND ', mr_consulta.controle_ate
  END IF

  IF mr_consulta.viajante IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND viajante = ', mr_consulta.viajante
  END IF

  IF mr_consulta.cliente_destino IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND cliente_atendido = "', mr_consulta.cliente_destino,'"'
  END IF

  IF mr_consulta.cliente_debitar IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND cliente_fatur = "', mr_consulta.cliente_debitar,'"'
  END IF

  IF mr_consulta.dat_partida_de IS NOT NULL THEN
     LET l_data_char = mr_consulta.dat_partida_de
     LET l_data_char = l_data_char[7,10],'-',
                       l_data_char[4,5],'-',
                       l_data_char[1,2],' 00:00:00'
     LET l_data_de = l_data_char

     LET l_data_char = mr_consulta.dat_partida_ate
     LET l_data_char = l_data_char[7,10],'-',
                       l_data_char[4,5],'-',
                      #l_data_char[1,2],' 23:59:59'
                      #OS 459347
                       l_data_char[1,2],' 24:00:00'
     LET l_data_ate = l_data_char

     LET sql_stmt = sql_stmt CLIPPED,
                    ' AND dat_hor_partida BETWEEN "',l_data_de,'" AND "',l_data_ate,'"'
  END IF

  IF mr_consulta.dat_retorno_de IS NOT NULL THEN
     LET l_data_char = mr_consulta.dat_retorno_de
     LET l_data_char = l_data_char[7,10],'-',
                       l_data_char[4,5],'-',
                       l_data_char[1,2],' 00:00:00'
     LET l_data_de = l_data_char

     LET l_data_char = mr_consulta.dat_retorno_ate
     LET l_data_char = l_data_char[7,10],'-',
                       l_data_char[4,5],'-',
                      #l_data_char[1,2],' 23:59:59'
                      #OS459347
                       l_data_char[1,2],' 24:00:00'
     LET l_data_ate = l_data_char

     LET sql_stmt = sql_stmt CLIPPED,
                    ' AND dat_hor_retorno BETWEEN "',l_data_de,'" AND "',l_data_ate,'"'
  END IF

  LET sql_stmt = sql_stmt CLIPPED,
                 ' ORDER BY dat_hor_retorno, viagem '

  WHENEVER ERROR CONTINUE
   PREPARE var_query FROM sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql_detalhe("PREPARE","var_query",sql_stmt)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_query CURSOR FOR var_query
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_query')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_query INTO mr_solic.*
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_query')
        RETURN FALSE
     END IF

     LET l_status_acer_viagem = cdv2000_recupera_status_viag(mr_solic.viagem)

     IF l_status_acer_viagem IS NOT NULL THEN
        IF (l_status_acer_viagem = '1') AND (mr_consulta.status_acer MATCHES "[245]") THEN
           CONTINUE FOREACH
        END IF
        IF (l_status_acer_viagem = '2') AND (mr_consulta.status_acer MATCHES "[145]") THEN
           CONTINUE FOREACH
        END IF
        IF (l_status_acer_viagem = '3') AND (mr_consulta.status_acer MATCHES "[1235]") THEN
           CONTINUE FOREACH
        END IF
        IF (l_status_acer_viagem = '4') AND (mr_consulta.status_acer MATCHES "[1234]") THEN
           CONTINUE FOREACH
        END IF
     ELSE
        IF NOT mr_consulta.status_acer MATCHES "[136]" THEN
           CONTINUE FOREACH
        END IF
     END IF

     IF NOT cdv2000_insert_w_solic() THEN
        RETURN FALSE
     END IF

  END FOREACH
  FREE cq_query

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_solics
     FROM w_solic
    WHERE 1 = 1
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','w_solic')
     RETURN FALSE
  END IF
  IF NOT l_qtd_solics > 0 THEN
     CALL log0030_mensagem('Nenhuma solicita��o/acerto encontrado para os dados informados.','exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR
    SELECT viagem, controle, viajante, finalidade_viagem, cc_viajante,
           cc_debitar, cliente_atendido, cliente_fatur, empresa_atendida,
           filial_atendida, trajeto_principal, dat_hor_partida, dat_hor_retorno,
           motivo_viagem
      FROM w_solic
     WHERE 1 =1
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_consulta')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   OPEN cq_consulta
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('OPEN','cq_consulta')
     RETURN FALSE
  END IF

  LET m_consulta_ativa = TRUE
  LET m_funcao = "COM_SOLIC"
  RETURN TRUE

END FUNCTION

#--------------------------------------------------#
  FUNCTION cdv2000_possui_adtos_em_aberto(l_viagem)
#--------------------------------------------------#

  DEFINE l_viagem                LIKE cdv_acer_viag_781.viagem,
         l_num_ad_adto_viagem    LIKE ad_mestre.num_ad,
         l_num_ad                LIKE ad_mestre.num_ad,
         m_num_ap                LIKE ap.num_ap,
         m_dat_pgto              LIKE ap.dat_pgto,
         l_trava                 SMALLINT,
         l_status                SMALLINT,
         l_val_liq_ap            LIKE ap.val_nom_ap,
         l_qtd_aps               SMALLINT

  LET l_trava = FALSE
  WHENEVER ERROR CONTINUE
  DECLARE cq_adtos_aberto CURSOR FOR
   SELECT num_ad_adto_viagem
     FROM cdv_solic_adto_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_ADTOS_ABERTO")
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_adtos_aberto INTO l_num_ad_adto_viagem
  WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("FOREACH","CQ_ADTOS_ABERTO")
     END IF

     IF l_num_ad_adto_viagem IS NULL THEN
        LET l_trava = TRUE
        EXIT FOREACH
     END IF

     WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_qtd_aps
        FROM ad_ap
       WHERE cod_empresa = p_cod_empresa
         AND num_ad      = l_num_ad_adto_viagem
     WHENEVER ERROR CONTINUE
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECAO','count-ap')
        LET l_trava = TRUE
        EXIT FOREACH
     END IF

     IF l_qtd_aps = 0 OR l_qtd_aps IS NULL THEN
        LET l_trava = TRUE
        EXIT FOREACH
     END IF

     WHENEVER ERROR CONTINUE
     DECLARE cq_ad_ap CURSOR FOR
      SELECT num_ap
        FROM ad_ap
       WHERE cod_empresa = p_cod_empresa
         AND num_ad      = l_num_ad_adto_viagem
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","CQ_AD_AP")
     END IF

     WHENEVER ERROR CONTINUE
     FOREACH cq_ad_ap INTO m_num_ap
     WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("FOREACH","CQ_AD_AP")
        END IF

        WHENEVER ERROR CONTINUE
         SELECT dat_pgto
           INTO m_dat_pgto
           FROM ap
          WHERE cod_empresa = p_cod_empresa
            AND num_ap      = m_num_ap
            AND ies_versao_atual = "S"
        WHENEVER ERROR CONTINUE

        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('SELECAO','ap')
           LET l_trava = TRUE
           EXIT FOREACH
        END IF

        IF m_dat_pgto IS NULL THEN
           CALL cdv2000_calc_val_liquido_ap(p_cod_empresa, m_num_ap, "S", 0)
              RETURNING l_status, l_val_liq_ap
           IF l_val_liq_ap <> 0 THEN
              LET l_trava = TRUE
              EXIT FOREACH
           END IF
        END IF
     END FOREACH
     FREE cq_ad_ap

  END FOREACH
  FREE cq_adtos_aberto

  RETURN l_trava

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_paginacao(l_funcao)
#------------------------------------#
  DEFINE l_funcao           CHAR(20)

  IF m_consulta_ativa THEN

     LET mr_inputr.* = mr_input.*

     WHILE TRUE
        IF l_funcao = "SEGUINTE" THEN
           WHENEVER ERROR CONTINUE
            FETCH NEXT cq_consulta INTO mr_solic.*
           WHENEVER ERROR STOP
        ELSE
           WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_consulta INTO mr_solic.*
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR 'N�o existem mais itens nesta dire��o.'
           EXIT WHILE
        ELSE
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql('FETCH','cq_consulta')
           ELSE
              WHENEVER ERROR CONTINUE
               SELECT viagem
                 FROM w_solic
                WHERE viagem = mr_solic.viagem
              WHENEVER ERROR STOP
              IF SQLCA.SQLCODE = 0 THEN
                 CALL cdv2000_carrega_record_input()
                 DISPLAY BY NAME mr_input.*

                 DISPLAY m_den_empresa_atendida TO den_empresa_atendida
                 DISPLAY m_den_filial_atendida  TO den_filial_atendida

                 EXIT WHILE
              END IF
           END IF
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_carrega_record_input()
#---------------------------------------#
  DEFINE l_datetime_char      CHAR(19),
         l_date_char          CHAR(10),
         l_status             SMALLINT,
         l_dat_hr_emis_relat  DATETIME YEAR TO SECOND,
         l_status_acer_viagem CHAR(02)

  LET mr_inputr.* = mr_input.*
  INITIALIZE mr_input.* TO NULL

  LET mr_input.empresa   = p_cod_empresa
  LET mr_input.viagem    = mr_solic.viagem
  LET mr_input.controle  = mr_solic.controle

  LET mr_input.viajante = mr_solic.viajante

  CALL cdv2000_valida_viajante(mr_input.viajante)
     RETURNING l_status, mr_input.nom_viajante

  LET mr_input.finalidade_viagem = mr_solic.finalidade_viagem

  CALL cdv2000_valida_finalidade(mr_input.finalidade_viagem)
     RETURNING l_status, mr_input.des_fin_viagem

  LET mr_input.cc_viajante = mr_solic.cc_viajante

  CALL cdv2000_valida_centro_custo(mr_input.cc_viajante)
     RETURNING l_status, mr_input.des_cc_viajante

  LET mr_input.cc_debitar = mr_solic.cc_debitar

  CALL cdv2000_valida_centro_custo(mr_input.cc_debitar)
     RETURNING l_status, mr_input.des_cc_debitar

  LET mr_input.cliente_destino = mr_solic.cliente_atendido

  CALL cdv2000_valida_cliente(mr_input.cliente_destino, "N")
     RETURNING l_status, mr_input.des_cli_destino

  LET mr_input.cliente_debitar = mr_solic.cliente_fatur

  CALL cdv2000_valida_cliente(mr_input.cliente_debitar, "S")
     RETURNING l_status, mr_input.des_cli_debitar

  LET mr_input.empresa_atendida  = mr_solic.empresa_atendida
  LET mr_input.filial_atendida   = mr_solic.filial_atendida

  LET m_den_empresa_atendida     = cdv2000_busca_raz_social_reduz(mr_input.empresa_atendida)
  LET m_den_filial_atendida      = cdv2000_busca_raz_social_reduz(mr_input.filial_atendida)

  LET mr_input.trajeto_principal = mr_solic.trajeto_principal

  LET l_datetime_char = mr_solic.dat_hor_partida
  LET l_date_char     = l_datetime_char[9,10], "/", l_datetime_char[6,7], "/", l_datetime_char[1,4]

  LET mr_input.dat_partida = l_date_char
  LET mr_input.hor_partida = l_datetime_char[12,16]

  LET l_datetime_char = mr_solic.dat_hor_retorno
  LET l_date_char     = l_datetime_char[9,10], "/", l_datetime_char[6,7], "/", l_datetime_char[1,4]

  LET mr_input.dat_retorno = l_date_char
  LET mr_input.hor_retorno = l_datetime_char[12,16]

  LET mr_input.motivo_viagem1 = mr_solic.motivo_viagem[001,050]
  LET mr_input.motivo_viagem2 = mr_solic.motivo_viagem[051,100]
  LET mr_input.motivo_viagem3 = mr_solic.motivo_viagem[101,150]
  LET mr_input.motivo_viagem4 = mr_solic.motivo_viagem[151,200]

  WHENEVER ERROR CONTINUE
   SELECT dat_hr_emis_relat, status_acer_viagem, ad_acerto_conta
     INTO l_dat_hr_emis_relat, l_status_acer_viagem, mr_input.ad_acerto_conta
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = mr_solic.viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     LET l_datetime_char = l_dat_hr_emis_relat
     LET l_date_char     = l_datetime_char[9,10], "/", l_datetime_char[6,7], "/", l_datetime_char[1,4]

     LET mr_input.dat_emis_relat = l_date_char
     LET mr_input.hr_emis_relat  = l_datetime_char[12,16]

     CASE l_status_acer_viagem
        WHEN 1
           LET mr_input.des_status = 'ACERTO VIAGEM PENDENTE'
        WHEN 2
           LET mr_input.des_status = 'ACERTO VIAGEM INICIADO'
        WHEN 3
           LET mr_input.des_status = 'ACERTO VIAGEM FINALIZADO'
        WHEN 4
           LET mr_input.des_status = 'ACERTO VIAGEM LIBERADO'
     END CASE

     IF mr_input.ad_acerto_conta IS NOT NULL THEN
        CALL cdv2000_recupera_primeira_ap(mr_input.ad_acerto_conta)
           RETURNING l_status, mr_input.ap_acerto_conta
     END IF
  ELSE
     IF SQLCA.SQLCODE <> 100 THEN
        CALL log003_err_sql('SELECT','cdv_acer_viag_781')
     END IF

     LET l_datetime_char = log0300_current(g_ies_ambiente)
     LET l_date_char     = l_datetime_char[9,10], "/", l_datetime_char[6,7], "/", l_datetime_char[1,4]

     LET mr_input.dat_emis_relat = l_date_char
     LET mr_input.hr_emis_relat  = l_datetime_char[12,16]

     LET mr_input.ad_acerto_conta = NULL
     LET mr_input.ap_acerto_conta = NULL
     LET mr_input.des_status = 'ACERTO VIAGEM PENDENTE'
  END IF

END FUNCTION

#-------------------------------------------------------#
FUNCTION cdv2000_valida_centro_custo(l_cod_centro_custo)
#-------------------------------------------------------#
  DEFINE l_cod_centro_custo   LIKE cad_cc.cod_cent_cust,
         l_nom_cent_cust      LIKE cad_cc.nom_cent_cust


 DEFINE l_cc LIKE cdv_solic_viagem.cc_debitar,
        lr_cad_cc RECORD LIKE cad_cc.*

 CALL con200_verifica_cod_ccusto(p_cod_empresa,l_cod_centro_custo,TODAY) RETURNING lr_cad_cc.*,p_status

 IF p_status = FALSE THEN
    INITIALIZE l_nom_cent_cust TO NULL
    RETURN FALSE, l_nom_cent_cust
 END IF

  WHENEVER ERROR CONTINUE
   SELECT nom_cent_cust
     INTO l_nom_cent_cust
     FROM cad_cc
    WHERE cod_empresa    = p_cod_empresa
      AND cod_cent_cust  = l_cod_centro_custo
      AND ies_cod_versao = 0
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 100
        WHENEVER ERROR CONTINUE
         SELECT nom_cent_cust
           INTO l_nom_cent_cust
           FROM cad_cc
          WHERE cod_empresa      = m_cod_emp_plano
            AND cod_cent_cust    = l_cod_centro_custo
            AND ies_cod_versao   = 0
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('SELECAO','cad_cc1')
           RETURN FALSE, ''
        ELSE
           RETURN TRUE, l_nom_cent_cust
        END IF
     WHEN 0
        RETURN TRUE, l_nom_cent_cust
     OTHERWISE
        CALL log003_err_sql('SELECAO','cad_cc2')
        RETURN FALSE, ''
  END CASE

END FUNCTION

#-------------------------------------------------------#
FUNCTION cdv2000_valida_finalidade(l_finalidade_viagem)
#-------------------------------------------------------#
  DEFINE l_finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         l_des_finalidade      LIKE cdv_finalidade_781.des_finalidade

  WHENEVER ERROR CONTINUE
   SELECT des_finalidade
     INTO l_des_finalidade
     FROM cdv_finalidade_781
    WHERE finalidade = l_finalidade_viagem
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE, l_des_finalidade
     WHEN 100
        CALL log0030_mensagem('Finalidade de viagem n�o cadastrada.','exclamation')
        RETURN FALSE, ''
     OTHERWISE
        CALL log003_err_sql('SELECT','cdv_finalidade_781')
        RETURN FALSE, ''
  END CASE

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2000_insere_cdv_protocol(l_obs_protocol)
#----------------------------------------------------#
  DEFINE l_sequencia_protocol     LIKE cdv_protocol.sequencia_protocol,
         l_obs_protocol           LIKE cdv_protocol.obs_protocol,
         l_datetime               DATETIME YEAR TO SECOND

  WHENEVER ERROR CONTINUE
   SELECT MAX(sequencia_protocol)
     INTO l_sequencia_protocol
     FROM cdv_protocol
    WHERE empresa    = p_cod_empresa
      AND num_viagem = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECT","CDV_PROTOCOL")
     RETURN FALSE
  END IF

  IF l_sequencia_protocol IS NULL THEN
      LET l_sequencia_protocol = 0
  ELSE
     LET l_sequencia_protocol = l_sequencia_protocol + 1
  END IF

  LET l_datetime = log0300_current(g_ies_ambiente)

  WHENEVER ERROR CONTINUE
   INSERT INTO cdv_protocol (empresa,
                             num_viagem,
                             sequencia_protocol,
                             dat_hor_env_recb,
                             status_protocol,
                             matr_receb_docum,
                             matr_dest_protocol,
                             obs_protocol,
                             usuario_remetent,
                             dat_hor_remetent,
                             num_protocol,
                             dat_hor_despacho)
                     VALUES (p_cod_empresa,
                             mr_input.viagem,
                             l_sequencia_protocol,
                             l_datetime,
                             '4',
                             mr_input.viajante,
                             mr_input.viajante,
                             l_obs_protocol,
                             p_user,
                             l_datetime,
                             mr_input.viagem,
                             l_datetime)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('INSERT','cdv_protocol')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2000_carrega_numero_viagem()
#----------------------------------------#
  DEFINE l_numero_viagem LIKE cdv_solic_viag_781.viagem

  INITIALIZE l_numero_viagem TO NULL

  CALL log2250_busca_parametro(p_cod_empresa,"numero_viagem_pamcary")
       RETURNING l_numero_viagem, p_status

  IF p_status = FALSE OR l_numero_viagem IS NULL OR l_numero_viagem = " " THEN
     LET l_numero_viagem = 1
  END IF

  RETURN l_numero_viagem

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_inclusao_acerto_sem_solic()
#--------------------------------------------#
  DEFINE l_status             SMALLINT,
         l_time               CHAR(8)

  LET mr_inputr.* = mr_input.*
  INITIALIZE mr_input.* TO NULL

  LET mr_input.empresa    = p_cod_empresa
  LET mr_input.des_status = 'ACERTO VIAGEM INICIADO'
  LET mr_input.dat_emis_relat = TODAY
  LET l_time = TIME
  LET mr_input.hr_emis_relat = l_time[1,5]

  DISPLAY '' TO den_empresa_atendida
  DISPLAY '' TO den_filial_atendida

  LET m_funcao = "SEM_SOLIC"

  IF NOT cdv2000_entrada_dados_in_mo('INCLUSAO') THEN
     ERROR 'Inclus�o cancelada.'
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*

     LET m_den_empresa_atendida     = cdv2000_busca_raz_social_reduz(mr_input.empresa_atendida)
     LET m_den_filial_atendida      = cdv2000_busca_raz_social_reduz(mr_input.filial_atendida)
     DISPLAY m_den_empresa_atendida TO den_empresa_atendida
     DISPLAY m_den_filial_atendida  TO den_filial_atendida

     RETURN
  END IF

  CALL log085_transacao("BEGIN")

  LET mr_input.viagem = cdv2000_carrega_numero_viagem()

  IF cdv2000_processa_atualizacoes('INCLUSAO') AND
     cdv2000_atualiza_cursor_viagens_ativas() THEN
     CALL log085_transacao("COMMIT")
     MESSAGE 'Inclus�o efetuada com sucesso.' ATTRIBUTE(REVERSE)
     DISPLAY BY NAME mr_input.viagem
     LET m_consulta_ativa = TRUE
     #LET m_alterou_viagem = TRUE
  ELSE
     CALL log085_transacao("ROLLBACK")
     ERROR 'Inclus�o cancelada.'
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*
  END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_recupera_matricula_viajante()
#----------------------------------------------#
  DEFINE l_matricula     LIKE cdv_info_viajante.matricula
  INITIALIZE l_matricula TO NULL

  WHENEVER ERROR CONTINUE
   SELECT matricula
     INTO l_matricula
     FROM cdv_info_viajante
    WHERE empresa       = p_cod_empresa
      AND usuario_logix = p_user
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','cdv_info_viajante')
     RETURN FALSE, ''
  END IF

  RETURN TRUE, l_matricula

END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION cdv2000_possui_solic_pendente_acerto(l_viajante, l_data_corte)
#-----------------------------------------------------------------------#
  DEFINE l_viajante          LIKE cdv_acer_viag_781.viajante,
         l_data_corte        DATETIME YEAR TO SECOND,
         l_qtd_viagens_pend  SMALLINT

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_viagens_pend
     FROM cdv_solic_viag_781
    WHERE empresa         = p_cod_empresa
      AND viajante        = l_viajante
      AND dat_hor_retorno <= l_data_corte
      AND NOT EXISTS (SELECT viagem
                        FROM cdv_acer_viag_781
                       WHERE empresa = cdv_solic_viag_781.empresa
                         AND viagem  = cdv_solic_viag_781.viagem)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','count-cdv_solic_viag_781')
     RETURN TRUE
  END IF

  IF l_qtd_viagens_pend > 0 AND l_qtd_viagens_pend IS NOT NULL THEN
     RETURN TRUE
  END IF

  RETURN FALSE

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_entrada_dados_in_mo(l_funcao)
#----------------------------------------------#
  DEFINE l_funcao             CHAR(11),
         l_status             SMALLINT,
         l_eh_controle_obrig  LIKE cdv_finalidade_781.eh_controle_obrig,
         l_eh_periodo_viagem  LIKE cdv_finalidade_781.eh_periodo_viagem,
         l_msg                CHAR(200),
         l_eh_servico_interno CHAR(01)

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv2000

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_input.empresa,            mr_input.viagem,
                mr_input.dat_emis_relat,     mr_input.hr_emis_relat,
                mr_input.des_status,         mr_input.viajante,
                mr_input.nom_viajante,       mr_input.finalidade_viagem,
                mr_input.des_fin_viagem,     mr_input.controle,
                mr_input.cc_viajante,        mr_input.des_cc_viajante,
                mr_input.ad_acerto_conta,    mr_input.cc_debitar,
                mr_input.des_cc_debitar,     mr_input.ap_acerto_conta,
                mr_input.cliente_destino,    mr_input.des_cli_destino,
                mr_input.cliente_debitar,    mr_input.des_cli_debitar,
                mr_input.empresa_atendida,   mr_input.filial_atendida,
                mr_input.trajeto_principal,  mr_input.dat_partida,
                mr_input.hor_partida,        mr_input.dat_retorno,
                mr_input.hor_retorno,        mr_input.motivo_viagem1,
                mr_input.motivo_viagem2,     mr_input.motivo_viagem3,
                mr_input.motivo_viagem4 WITHOUT DEFAULTS

      AFTER FIELD controle
         WHENEVER ERROR CONTINUE
          SELECT eh_controle_obrig, eh_periodo_viagem, eh_servico_interno
            INTO l_eh_controle_obrig, l_eh_periodo_viagem, l_eh_servico_interno
            FROM cdv_finalidade_781
           WHERE finalidade = mr_input.finalidade_viagem
         WHENEVER ERROR STOP

         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql('SELECT','cdv_finalidade_781')
            LET INT_FLAG = TRUE
            EXIT INPUT
         END IF

         IF mr_input.controle IS NOT NULL THEN
            IF mr_input.controle < m_controle_minimo THEN
               LET l_msg = 'Somente podera ser utilizado controle maior ou igual a ', m_controle_minimo USING "<<<<<<<<<<"
               CALL log0030_mensagem(l_msg,"exclamation")
               NEXT FIELD controle
            END IF

            IF NOT cdv2000_valida_controle_finalidade(mr_input.controle, mr_input.finalidade_viagem) THEN
               NEXT FIELD controle
            END IF

            IF l_eh_servico_interno = 'S' THEN

            #------------------------------------------------------------------------#
            # OS 571112 - quando se tratar de servico interno, o tipo de             #
            # processo do controle (cdv2008) deve ser igual a 4 - Servicos Internos. #
            #------------------------------------------------------------------------#
               IF m_tip_processo <> 4 THEN
                  CALL log0030_mensagem("Finalidade exige que controle seja tipo de processo 4 - Servi�os Internos", "exclamation")
                  NEXT FIELD controle
               END IF
            ELSE
               IF m_tip_processo = 4 THEN
                  CALL log0030_mensagem("Controle n�o pode ser tipo de processo 4 - Servi�os Internos, pois viagem n�o possui esta finalidade", "exclamation")
                  NEXT FIELD controle
               END IF
            END IF

            IF l_funcao = "MODIFICACAO" THEN
               IF (l_eh_controle_obrig = 'N') THEN
                  NEXT FIELD cc_viajante
               END IF
            END IF
         ELSE
            IF  fgl_lastkey() <> FGL_KEYVAL("UP")
            AND fgl_lastkey() <> FGL_KEYVAL("LEFT") THEN
               IF l_eh_controle_obrig = 'S' THEN
                  LET m_msg = 'Finalidade da viagem exige que seja informado controle.'
                  CALL log0030_mensagem(m_msg,'exclamation')
                  NEXT FIELD controle
               END IF
            END IF
         END IF

      BEFORE FIELD viajante
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

         IF l_funcao = 'INCLUSAO' THEN
            IF m_funcao = "COM_SOLIC" THEN
               CALL cdv2000_valida_viajante(mr_input.viajante)
                  RETURNING l_status, mr_input.nom_viajante
               DISPLAY BY NAME mr_input.nom_viajante
               NEXT FIELD finalidade_viagem
            END IF
         ELSE
			         IF m_funcao = "COM_SOLIC" THEN
			            NEXT FIELD finalidade_viagem
			         END IF
         END IF

      AFTER FIELD viajante
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.viajante IS NOT NULL THEN
               CALL cdv2000_valida_viajante(mr_input.viajante)
                  RETURNING l_status, mr_input.nom_viajante

               IF l_status THEN
                  DISPLAY BY NAME mr_input.nom_viajante
                  IF m_funcao = "SEM_SOLIC" THEN
                     #IF cdv2000_possui_solic_pendente_acerto(mr_input.viajante, log0300_current(g_ies_ambiente)) THEN
                     #   CALL log0030_mensagem('Inclus�o n�o permitida, viajante possui viagens pendentes de acerto.','exclamation')
                     #   NEXT FIELD viajante
                     #END IF
                  END IF
               ELSE
                  NEXT FIELD viajante
               END IF
            ELSE
               CALL log0030_mensagem('Informe o viajante.','exclamation')
               NEXT FIELD viajante
            END IF
         END IF

      BEFORE FIELD finalidade_viagem
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

      AFTER FIELD finalidade_viagem
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.finalidade_viagem IS NOT NULL THEN
               CALL cdv2000_valida_finalidade(mr_input.finalidade_viagem)
                  RETURNING l_status, mr_input.des_fin_viagem

               IF l_status THEN
                  DISPLAY BY NAME mr_input.des_fin_viagem
                  WHENEVER ERROR CONTINUE
                   SELECT eh_controle_obrig, eh_periodo_viagem
                     INTO l_eh_controle_obrig, l_eh_periodo_viagem
                     FROM cdv_finalidade_781
                    WHERE finalidade = mr_input.finalidade_viagem
                  WHENEVER ERROR STOP
                  IF SQLCA.SQLCODE <> 0 THEN
                     CALL log003_err_sql('SELECT','cdv_finalidade_781')
                     LET INT_FLAG = TRUE
                     EXIT INPUT
                  END IF

                  #CASE mr_input.finalidade_viagem[1,2]
                  #   WHEN "02"
                  #      DISPLAY "Processo:" AT 5,41
                  #   WHEN "03"
                  #      DISPLAY " Projeto:" AT 5,41
                  #   OTHERWISE
                  #      DISPLAY "Controle:" AT 5,41
                  #END CASE

                  #IF l_eh_controle_obrig = 'S' AND mr_input.controle IS NULL THEN
                  #   #CASE mr_input.finalidade_viagem[1,2]
                  #      #WHEN "02"
                  #      #   LET m_msg = 'Finalidade da viagem exige que seja informado processo.'
                  #      #WHEN "03"
                  #      #   LET m_msg = 'Finalidade da viagem exige que seja informado projeto.'
                  #      #OTHERWISE
                  #         LET m_msg = 'Finalidade da viagem exige que seja informado controle.'
                  #   #END CASE
                  #
                  #   CALL log0030_mensagem(m_msg,'exclamation')
                  #   NEXT FIELD controle
                  #END IF
               ELSE
                  NEXT FIELD finalidade_viagem
               END IF

               IF mr_input.controle IS NOT NULL THEN
                  IF NOT cdv2000_valida_controle_finalidade(mr_input.controle, mr_input.finalidade_viagem) THEN
                     #CALL log0030_mensagem('Controle n�o cadastrado para essa finalidade ou encerrado.','exclamation')
                     NEXT FIELD finalidade_viagem
                  END IF
               END IF

               #IF NOT cdv2000_verifica_ativ_relacionada() THEN
               #   CALL log0030_mensagem("N�o existem atividades relacionadas � viagem, efetue devolu��o.",'exclamation')
               #   NEXT FIELD finalidade_viagem
               #END IF

            ELSE
               CALL log0030_mensagem('Informe a finalidade da viagem.','exclamation')
               NEXT FIELD finalidade_viagem
            END IF
         END IF

      BEFORE FIELD cc_viajante
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

         IF l_funcao = 'INCLUSAO' THEN
            LET mr_input.cc_viajante = cdv2000_resgata_cc_viajante(mr_input.viajante)
            CALL cdv2000_valida_centro_custo(mr_input.cc_viajante)
               RETURNING l_status, mr_input.des_cc_viajante
            DISPLAY BY NAME mr_input.cc_viajante
            DISPLAY BY NAME mr_input.des_cc_viajante
         END IF
         NEXT FIELD cc_debitar

      AFTER FIELD cc_viajante
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

      BEFORE FIELD cc_debitar
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

         IF mr_input.cc_debitar IS NULL THEN
            LET mr_input.cc_debitar = cdv2000_carrega_cc_debitar()
            DISPLAY BY NAME mr_input.cc_debitar
         END IF

      AFTER FIELD cc_debitar
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
            FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
            NEXT FIELD finalidade_viagem
         END IF

         IF mr_input.cc_debitar IS NOT NULL THEN
            CALL cdv2000_valida_centro_custo(mr_input.cc_debitar)
               RETURNING l_status, mr_input.des_cc_debitar
            IF l_status THEN
               DISPLAY BY NAME mr_input.des_cc_debitar
            ELSE
               CALL log0030_mensagem('Centro de custo inativo ou n�o cadastrado.','exclamation')
               NEXT FIELD cc_debitar
            END IF
         ELSE
            CALL log0030_mensagem('Informe o centro de custo a debitar.','exclamation')
            NEXT FIELD cc_debitar
         END IF

      BEFORE FIELD cliente_destino
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

         IF l_eh_controle_obrig = 'S' THEN
            IF m_cliente_atendido IS NOT NULL THEN

            #--------------------------------------------------------------#
            # OS 571112 - n�o permitir alterar cliente atendido e cliente  #
            # debitar se o controle for obrigat�rio.                       #
            #--------------------------------------------------------------#

               LET mr_input.cliente_destino = m_cliente_atendido

               CALL cdv2000_valida_cliente(mr_input.cliente_destino, "N")
                  RETURNING l_status, mr_input.des_cli_destino

               DISPLAY BY NAME mr_input.cliente_destino
               DISPLAY BY NAME mr_input.des_cli_destino

               NEXT FIELD cliente_debitar
            END IF
         ELSE
            IF m_cliente_atendido IS NOT NULL THEN
               LET mr_input.cliente_destino = m_cliente_atendido
               DISPLAY BY NAME mr_input.cliente_destino
            END IF
         END IF

      AFTER FIELD cliente_destino
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.cliente_destino IS NOT NULL THEN
               CALL cdv2000_valida_cliente(mr_input.cliente_destino, "N")
                  RETURNING l_status, mr_input.des_cli_destino
               IF NOT l_status THEN
                  #NEXT FIELD cliente_destino
                  DISPLAY '' TO des_cli_destino
               ELSE
                  DISPLAY BY NAME mr_input.des_cli_destino
               END IF
            ELSE
               CALL log0030_mensagem('Informe o cliente atendido.','exclamation')
               NEXT FIELD cliente_destino
            END IF
         END IF

      BEFORE FIELD cliente_debitar
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

         IF l_eh_controle_obrig = 'S' THEN
            IF (fgl_lastkey() = FGL_KEYVAL("UP") OR FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN
               NEXT FIELD cc_debitar
            ELSE
               IF m_cliente_fatur IS NOT NULL THEN

               #--------------------------------------------------------------#
               # OS 571112 - n�o permitir alterar cliente atendido e cliente  #
               # debitar se o controle for obrigat�rio.                       #
               #--------------------------------------------------------------#

                  LET mr_input.cliente_debitar = m_cliente_fatur

                  CALL cdv2000_valida_cliente(mr_input.cliente_debitar, "N")
                     RETURNING l_status, mr_input.des_cli_debitar

                  DISPLAY BY NAME mr_input.cliente_debitar
                  DISPLAY BY NAME mr_input.des_cli_debitar

                  NEXT FIELD empresa_atendida
               END IF
            END IF
         ELSE
            IF m_cliente_fatur IS NOT NULL THEN
               LET mr_input.cliente_debitar = m_cliente_fatur
               DISPLAY BY NAME mr_input.cliente_debitar
            END IF
         END IF

      AFTER FIELD cliente_debitar
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.cliente_debitar IS NOT NULL THEN
               CALL cdv2000_valida_cliente(mr_input.cliente_debitar, "S")
                  RETURNING l_status, mr_input.des_cli_debitar
               IF NOT l_status THEN
                  NEXT FIELD cliente_debitar
                  DISPLAY '' TO des_cli_debitar
               ELSE
                  DISPLAY BY NAME mr_input.des_cli_debitar
               END IF
            ELSE
               CALL log0030_mensagem('Informe o cliente a faturar.','exclamation')
               NEXT FIELD cliente_debitar
            END IF
         END IF

      BEFORE FIELD empresa_atendida
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

      AFTER FIELD empresa_atendida
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.empresa_atendida IS NOT NULL THEN
               IF NOT cdv2000_valida_empresa(mr_input.empresa_atendida, 'M', '') THEN
                  NEXT FIELD empresa_atendida
               END IF
            ELSE
               CALL log0030_mensagem('Informe a empresa atendida.','exclamation')
               NEXT FIELD cliente_debitar
            END IF
         END IF

      BEFORE FIELD filial_atendida
         --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
         IF NOT g_ies_grafico THEN
             DISPLAY '( Zoom )' AT 3,68
         END IF

      AFTER FIELD filial_atendida
         --# CALL fgl_dialog_setkeylabel('control-z', '')
         IF NOT g_ies_grafico THEN
             DISPLAY '--------' AT 3,68
         END IF

         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.filial_atendida IS NOT NULL THEN
               IF mr_input.filial_atendida <> mr_input.empresa_atendida THEN
                  IF NOT cdv2000_valida_empresa(mr_input.filial_atendida, 'F', mr_input.empresa_atendida) THEN
                     NEXT FIELD filial_atendida
                  END IF
               END IF
            ELSE
               CALL log0030_mensagem('Informe a empresa filial atendida.','exclamation')
               NEXT FIELD cliente_debitar
            END IF
         END IF

      AFTER FIELD trajeto_principal
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.trajeto_principal IS NULL THEN
               CALL log0030_mensagem('Informe o trajeto principal da viagem.','exclamation')
               NEXT FIELD trajeto_principal
            END IF
         END IF

      BEFORE FIELD dat_partida
         IF cdv2000_verifica_despesas() THEN
            NEXT FIELD motivo_viagem1
         END IF
         IF mr_input.dat_partida IS NULL THEN
            LET mr_input.dat_partida = TODAY
            DISPLAY BY NAME mr_input.dat_partida
         END IF

      AFTER FIELD dat_partida
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.dat_partida IS NULL THEN
               CALL log0030_mensagem('Informe a data de partida da viagem.','exclamation')
               NEXT FIELD dat_partida
            END IF
         END IF

      BEFORE FIELD hor_partida
         IF mr_input.hor_partida IS NULL THEN
            LET mr_input.hor_partida = '08:00'
            DISPLAY BY NAME mr_input.hor_partida
         END IF

      AFTER FIELD hor_partida
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.hor_partida IS NULL THEN
               CALL log0030_mensagem('Informe a hora de partida da viagem.','exclamation')
               NEXT FIELD hor_partida
            END IF
         END IF

      BEFORE FIELD dat_retorno
         IF mr_input.dat_retorno IS NULL THEN
            LET mr_input.dat_retorno = TODAY
            DISPLAY BY NAME mr_input.dat_retorno
         END IF

      AFTER FIELD dat_retorno
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.dat_retorno IS NULL THEN
               CALL log0030_mensagem('Informe a data de retorno da viagem.','exclamation')
               NEXT FIELD dat_retorno
            ELSE
               IF mr_input.dat_retorno < mr_input.dat_partida THEN
                  CALL log0030_mensagem('A data de retorno deve ser igual/superior � data de partida.','exclamation')
                  NEXT FIELD dat_retorno
               END IF
            END IF
         END IF

      BEFORE FIELD hor_retorno
         IF mr_input.hor_retorno IS NULL THEN
            LET mr_input.hor_retorno = '18:00'
            DISPLAY BY NAME mr_input.hor_retorno
         END IF

      AFTER FIELD hor_retorno
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.hor_retorno IS NULL THEN
               CALL log0030_mensagem('Informe a hora de retorno da viagem.','exclamation')
               NEXT FIELD hor_retorno
            ELSE
               IF (mr_input.dat_retorno = mr_input.dat_partida) AND
                  (mr_input.hor_retorno <= mr_input.hor_partida)THEN
                  CALL log0030_mensagem('o hor�rio de retorno deve ser maior que o hor�rio de partida.','exclamation')
                  NEXT FIELD hor_retorno
               END IF
               IF cdv2000_consiste_periodo(l_funcao, mr_input.finalidade_viagem) THEN
                  CALL log0030_mensagem('Viajante j� possui viagem agendada nesse per�odo.', 'exclamation')
                  NEXT FIELD dat_partida
               END IF
            END IF
         END IF

      BEFORE FIELD motivo_viagem1
         IF (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
             FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN
            IF cdv2000_verifica_despesas() THEN
               NEXT FIELD trajeto_principal
            END IF
         END IF

      AFTER FIELD motivo_viagem1
         IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                 FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

            IF mr_input.motivo_viagem1 IS NULL OR mr_input.motivo_viagem1 = " " THEN
               CALL log0030_mensagem('Informe o motivo da viagem.','exclamation')
               NEXT FIELD motivo_viagem1
            END IF
         END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF m_inicia_acerto THEN
              IF NOT log0040_confirm(19,34,"Confirma inicia��o do acerto?") THEN
                 NEXT FIELD controle
              END IF
           ELSE
              IF NOT log0040_confirm(19,34,"Confirma modifica��o do acerto?") THEN
                 NEXT FIELD controle
              END IF
           END IF

           IF mr_input.controle IS NOT NULL THEN
              #IF NOT cdv2000_valida_controle(mr_input.controle) THEN
              IF NOT cdv2000_valida_controle_finalidade(mr_input.controle, mr_input.finalidade_viagem) THEN
                 #CALL log0030_mensagem('Controle inv�lido ou encerrado.','exclamation')
                 NEXT FIELD controle
              END IF

              IF l_eh_servico_interno = 'S' THEN

              #------------------------------------------------------------------------#
              # OS 571112 - quando se tratar de servico interno, o tipo de             #
              # processo do controle (cdv2008) deve ser igual a 4 - Servicos Internos. #
              #------------------------------------------------------------------------#
                 IF m_tip_processo <> 4 THEN
                    CALL log0030_mensagem("Finalidade exige que controle seja tipo de processo 4 - Servi�os Internos", "exclamation")
                    NEXT FIELD controle
                 END IF
              ELSE
                 IF m_tip_processo = 4 THEN
                    CALL log0030_mensagem("Controle n�o pode ser tipo de processo 4 - Servi�os Internos, pois viagem n�o possui esta finalidade", "exclamation")
                    NEXT FIELD controle
                 END IF
              END IF
           END IF

           IF mr_input.viajante IS NOT NULL THEN
              CALL cdv2000_valida_viajante(mr_input.viajante)
                 RETURNING l_status, mr_input.nom_viajante
              IF l_status THEN
                 DISPLAY BY NAME mr_input.nom_viajante
                 IF m_funcao = "SEM_SOLIC" THEN
                    #IF cdv2000_possui_solic_pendente_acerto(mr_input.viajante, log0300_current(g_ies_ambiente)) THEN
                    #   CALL log0030_mensagem('Inclus�o n�o permitida, viajante possui viagens pendentes de acerto.','exclamation')
                    #   NEXT FIELD viajante
                    #END IF
                 END IF
              ELSE
                 NEXT FIELD viajante
              END IF
           ELSE
              CALL log0030_mensagem('Informe o viajante.','exclamation')
              NEXT FIELD viajante
           END IF

           IF mr_input.finalidade_viagem IS NOT NULL THEN
              CALL cdv2000_valida_finalidade(mr_input.finalidade_viagem)
                 RETURNING l_status, mr_input.des_fin_viagem
              IF l_status THEN
                 DISPLAY BY NAME mr_input.des_fin_viagem
                 WHENEVER ERROR CONTINUE
                  SELECT eh_controle_obrig, eh_periodo_viagem
                    INTO l_eh_controle_obrig, l_eh_periodo_viagem
                    FROM cdv_finalidade_781
                   WHERE finalidade = mr_input.finalidade_viagem
                 WHENEVER ERROR STOP
                 IF SQLCA.SQLCODE <> 0 THEN
                    CALL log003_err_sql('SELECT','cdv_finalidade_781')
                    LET INT_FLAG = TRUE
                    EXIT INPUT
                 END IF
                 IF l_eh_controle_obrig = 'S' AND mr_input.controle IS NULL THEN
                     #CASE mr_input.finalidade_viagem[1,2]
                        #WHEN "02"
                        #   LET m_msg = 'Finalidade da viagem exige que seja informado processo.'
                        #WHEN "03"
                        #   LET m_msg = 'Finalidade da viagem exige que seja informado projeto.'
                        #OTHERWISE
                           LET m_msg = 'Finalidade da viagem exige que seja informado controle.'
                     #END CASE

                    CALL log0030_mensagem(m_msg,'exclamation')
                    NEXT FIELD controle
                 END IF
              ELSE
                 NEXT FIELD finalidade_viagem
              END IF
           ELSE
              CALL log0030_mensagem('Informe a finalidade da viagem.','exclamation')
              NEXT FIELD finalidade_viagem
           END IF

           IF mr_input.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_finalidade(mr_input.controle, mr_input.finalidade_viagem) THEN
                 #CALL log0030_mensagem('Controle n�o cadastrado para essa finalidade ou encerrado.','exclamation')
                 NEXT FIELD finalidade_viagem
              END IF
           END IF

           IF mr_input.cc_debitar IS NOT NULL THEN
              CALL cdv2000_valida_centro_custo(mr_input.cc_debitar)
                 RETURNING l_status, mr_input.des_cc_debitar
              IF l_status THEN
                 DISPLAY BY NAME mr_input.des_cc_debitar
              ELSE
                 NEXT FIELD cc_debitar
              END IF
           ELSE
              CALL log0030_mensagem('Informe o centro de custo a debitar.','exclamation')
              NEXT FIELD cc_debitar
           END IF

           IF m_cliente_atendido IS NOT NULL THEN
              LET mr_input.cliente_destino = m_cliente_atendido
              DISPLAY BY NAME mr_input.cliente_destino
           END IF

           IF mr_input.cliente_destino IS NOT NULL THEN
              CALL cdv2000_valida_cliente(mr_input.cliente_destino, "N")
                 RETURNING l_status, mr_input.des_cli_destino
              IF NOT l_status THEN
                 #NEXT FIELD cliente_destino
              ELSE
                 DISPLAY BY NAME mr_input.des_cli_destino
              END IF
           ELSE
              CALL log0030_mensagem('Informe o cliente atendido.','exclamation')
              NEXT FIELD cliente_destino
           END IF

           IF mr_input.cliente_debitar IS NOT NULL THEN
              CALL cdv2000_valida_cliente(mr_input.cliente_debitar, "S")
                 RETURNING l_status, mr_input.des_cli_debitar
              IF NOT l_status THEN
                 NEXT FIELD cliente_debitar
              ELSE
                 DISPLAY BY NAME mr_input.des_cli_debitar
              END IF
           ELSE
              CALL log0030_mensagem('Informe o cliente a faturar.','exclamation')
              NEXT FIELD cliente_debitar
           END IF

           IF mr_input.empresa_atendida IS NOT NULL THEN
              IF NOT cdv2000_valida_empresa(mr_input.empresa_atendida, 'M', '') THEN
                 NEXT FIELD empresa_atendida
              END IF
           ELSE
              CALL log0030_mensagem('Informe a empresa atendida.','exclamation')
              NEXT FIELD cliente_debitar
           END IF

           IF mr_input.filial_atendida IS NOT NULL THEN
              IF mr_input.filial_atendida <> mr_input.empresa_atendida THEN
                 IF NOT cdv2000_valida_empresa(mr_input.filial_atendida, 'F', mr_input.empresa_atendida) THEN
                    NEXT FIELD filial_atendida
                 END IF
              END IF
           ELSE
              CALL log0030_mensagem('Informe a empresa filial atendida.','exclamation')
              NEXT FIELD cliente_debitar
           END IF

           IF mr_input.trajeto_principal IS NULL THEN
              CALL log0030_mensagem('Informe o trajeto principal da viagem.','exclamation')
              NEXT FIELD trajeto_principal
           END IF

           IF mr_input.dat_partida IS NULL THEN
              CALL log0030_mensagem('Informe a data de partida da viagem.','exclamation')
              NEXT FIELD dat_partida
           END IF

           IF mr_input.hor_partida IS NULL THEN
              CALL log0030_mensagem('Informe a hora de partida da viagem.','exclamation')
              NEXT FIELD hor_partida
           END IF

           IF mr_input.dat_retorno IS NULL THEN
              CALL log0030_mensagem('Informe a data de retorno da viagem.','exclamation')
              NEXT FIELD dat_retorno
           ELSE
              IF mr_input.dat_retorno < mr_input.dat_partida THEN
                 CALL log0030_mensagem('A data de retorno deve ser igual/superior � data de partida.','exclamation')
                 NEXT FIELD dat_retorno
              END IF
           END IF

           IF mr_input.hor_retorno IS NULL THEN
              CALL log0030_mensagem('Informe a hora de retorno da viagem.','exclamation')
              NEXT FIELD hor_retorno
           ELSE
              IF (mr_input.dat_retorno = mr_input.dat_partida) AND
                 (mr_input.hor_retorno <= mr_input.hor_partida)THEN
                 CALL log0030_mensagem('o hor�rio de retorno deve ser maior que o hor�rio de partida.','exclamation')
                 NEXT FIELD hor_retorno
              END IF
              IF cdv2000_consiste_periodo(l_funcao, mr_input.finalidade_viagem) THEN
                 CALL log0030_mensagem('Viajante j� possui viagem agendada nesse per�odo.', 'exclamation')
                 NEXT FIELD dat_partida
              END IF
           END IF

           IF mr_input.motivo_viagem1 IS NULL OR mr_input.motivo_viagem1 = " " THEN
              CALL log0030_mensagem('Informe o motivo da viagem.','exclamation')
              NEXT FIELD motivo_viagem1
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup("INCLUSAO")

  END INPUT

  RETURN NOT INT_FLAG

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_verifica_despesas()
#------------------------------------#
 DEFINE l_cont    SMALLINT

 # Verificar se a viagem possui qqer tipo de despesa.
 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM cdv_desp_urb_781
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_DESP_URB_781")
    RETURN TRUE
 END IF

 IF l_cont > 0 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM cdv_apont_hor_781
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","cdv_apont_hor_781")
    RETURN TRUE
 END IF

 IF l_cont > 0 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM cdv_despesa_km_781
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_DESPESA_KM_781")
    RETURN TRUE
 END IF

 IF l_cont > 0 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*)
    INTO l_cont
    FROM cdv_desp_terc_781
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_DESP_TERC_781")
    RETURN TRUE
 END IF

 IF l_cont > 0 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#---------------------------------#
 FUNCTION cdv2000_insert_w_solic()
#---------------------------------#

  WHENEVER ERROR CONTINUE
   INSERT INTO w_solic (viagem,
                        controle,
                        viajante,
                        finalidade_viagem,
                        cc_viajante,
                        cc_debitar,
                        cliente_atendido,
                        cliente_fatur,
                        empresa_atendida,
                        filial_atendida,
                        trajeto_principal,
                        dat_hor_partida,
                        dat_hor_retorno,
                        motivo_viagem)
                VALUES (mr_solic.viagem,
                        mr_solic.controle,
                        mr_solic.viajante,
                        mr_solic.finalidade_viagem,
                        mr_solic.cc_viajante,
                        mr_solic.cc_debitar,
                        mr_solic.cliente_atendido,
                        mr_solic.cliente_fatur,
                        mr_solic.empresa_atendida,
                        mr_solic.filial_atendida,
                        mr_solic.trajeto_principal,
                        mr_solic.dat_hor_partida,
                        mr_solic.dat_hor_retorno,
                        mr_solic.motivo_viagem)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('INSERT','w_solic')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_atualiza_cursor_viagens_ativas()
#-------------------------------------------------#
  #Chamado 801668
  WHENEVER ERROR CONTINUE
   DECLARE cq_consulta2 SCROLL CURSOR WITH HOLD FOR
    SELECT viagem,
           controle,
           viajante,
           finalidade_viagem,
           cc_viajante,
           cc_debitar,
           cliente_atendido,
           cliente_fatur,
           empresa_atendida,
           filial_atendida,
           trajeto_principal,
           dat_hor_partida,
           dat_hor_retorno,
           motivo_viagem
      FROM w_solic
     WHERE 1 =1
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_consulta2')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   OPEN cq_consulta2
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('OPEN','cq_consulta2')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FETCH NEXT cq_consulta2 INTO mr_solic.*
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('FETCH','cq_consulta2')
     RETURN FALSE
  END IF

  WHILE mr_solic.viagem <> mr_input.viagem
     WHENEVER ERROR CONTINUE
      FETCH NEXT cq_consulta2 INTO mr_solic.*
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        RETURN FALSE
     END IF
  END WHILE

  RETURN TRUE

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_valida_controle(l_controle)
#--------------------------------------------#
  DEFINE l_controle    LIKE cdv_acer_viag_781.controle

  WHENEVER ERROR CONTINUE
   SELECT cliente_atendido, cliente_fatur
     INTO m_cliente_atendido, m_cliente_fatur
     FROM cdv_controle_781
    WHERE controle = l_controle
      AND encerrado = 'N'
  WHENEVER ERROR STOP

  IF  SQLCA.SQLCODE <> 0
  AND SQLCA.SQLCODE <> -284 THEN
     IF SQLCA.SQLCODE <> 100 THEN
        CALL log003_err_sql('SELECT','cdv_controle_781')
     END IF
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_resgata_cc_viajante(l_viajante)
#------------------------------------------------#

  DEFINE l_viajante         LIKE cdv_acer_viag_781.viajante,
         l_empresa_rhu      LIKE empresa.cod_empresa,
         l_uni_func_viaj    CHAR(10),
         l_cod_centro_custo LIKE unidade_funcional.cod_centro_custo

  WHENEVER ERROR CONTINUE
   SELECT empresa_rhu
     INTO l_empresa_rhu
     FROM cdv_info_viajante
    WHERE empresa   = p_cod_empresa
      AND matricula = l_viajante
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','cdv_info_viajante')
     RETURN ''
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_texto[01,10]
     INTO l_uni_func_viaj
     FROM cdv_par_viajante
    WHERE empresa     = p_cod_empresa
      AND matricula   = l_viajante
      AND empresa_rhu = l_empresa_rhu
      AND parametro   = 'uni_func_viaj'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','cdv_par_viajante')
     RETURN ''
  END IF

  WHENEVER ERROR CONTINUE
   SELECT cod_centro_custo
     INTO l_cod_centro_custo
     FROM unidade_funcional
    WHERE cod_empresa      = p_cod_empresa
      AND cod_uni_funcio   = l_uni_func_viaj
      AND dat_validade_fim > TODAY
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 100 THEN
     WHENEVER ERROR CONTINUE
      SELECT cod_centro_custo
        INTO l_cod_centro_custo
        FROM unidade_funcional
       WHERE cod_empresa      = l_empresa_rhu
         AND cod_uni_funcio   = l_uni_func_viaj
         AND dat_validade_fim > TODAY
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECAO','unidade_funcional1')
        RETURN ''
     END IF
  ELSE
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECAO','unidade_funcional2')
        RETURN ''
     END IF
  END IF

  RETURN l_cod_centro_custo

END FUNCTION

#-----------------------------------------------------------------------------#
 FUNCTION cdv2000_valida_empresa(l_empresa, l_matriz_filial, l_empresa_matriz)
#-----------------------------------------------------------------------------#
  DEFINE l_matriz_filial       CHAR(01),
         l_empresa             LIKE empresa.cod_empresa,
         l_empresa_matriz      LIKE empresa.cod_empresa,
         l_cod_empresa_matriz  LIKE empresa.cod_empresa,
         l_den_reduz           LIKE empresa.den_reduz

  INITIALIZE l_den_reduz TO NULL
  WHENEVER ERROR CONTINUE
   SELECT den_reduz
     INTO l_den_reduz
     FROM empresa
    WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
     WHEN 100
        CALL log0030_mensagem('Empresa n�o cadastrada.','exclamation')
        RETURN FALSE
     OTHERWISE
        CALL log003_err_sql('SELECT','empresa')
        RETURN FALSE
  END CASE

  IF l_matriz_filial = "M" THEN
     DISPLAY l_den_reduz TO den_empresa_atendida
  ELSE
     DISPLAY l_den_reduz TO den_filial_atendida
  END IF

  INITIALIZE l_cod_empresa_matriz TO NULL
  WHENEVER ERROR CONTINUE
   SELECT cod_empresa_mestre
     INTO l_cod_empresa_matriz
     FROM par_con
    WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','par_con')
     RETURN FALSE
  END IF

  IF l_matriz_filial = 'M'
  AND l_cod_empresa_matriz IS NOT NULL
  AND l_cod_empresa_matriz <> " " THEN
        CALL log0030_mensagem("Empresa atendida n�o � uma empresa matriz.","info")
     RETURN FALSE
  END IF

  IF l_matriz_filial = 'F' AND (l_cod_empresa_matriz <> l_empresa_matriz) THEN
     CALL log0030_mensagem("Filial atendida n�o est� relacionada a empresa atendida (matriz).","info")
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2000_consiste_periodo(l_funcao, l_finalidade)
#---------------------------------------------------------#
  DEFINE l_funcao             CHAR(11),
         l_data_char          CHAR(19),
         l_dat_hor_partida    DATETIME YEAR TO SECOND,
         l_dat_hor_retorno    DATETIME YEAR TO SECOND,
         l_finalidade         LIKE cdv_acer_viag_781.finalidade_viagem,
         l_eh_periodo_viagem  LIKE cdv_finalidade_781.eh_periodo_viagem

  WHENEVER ERROR CONTINUE
   SELECT eh_periodo_viagem
     INTO l_eh_periodo_viagem
     FROM cdv_finalidade_781
    WHERE finalidade = l_finalidade
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_finalidade_781')
     RETURN TRUE
  END IF

  IF l_eh_periodo_viagem = 'N' THEN
     RETURN FALSE
  END IF

  LET l_data_char = mr_input.dat_partida
  LET l_data_char = l_data_char[7,10],'-',
                    l_data_char[4,5],'-',
                    l_data_char[1,2],' ',
                    mr_input.hor_partida,':00'

  LET l_dat_hor_partida = l_data_char

  LET l_data_char = mr_input.dat_retorno
  LET l_data_char = l_data_char[7,10],'-',
                    l_data_char[4,5],'-',
                    l_data_char[1,2],' ',
                    mr_input.hor_retorno,':00'

  LET l_dat_hor_retorno = l_data_char

  IF mr_input.viagem IS NULL THEN
     LET mr_input.viagem = 0
  END IF

  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cdv_solic_viag_781
    WHERE empresa  = p_cod_empresa
      AND viajante = mr_input.viajante
      AND viagem   NOT IN (mr_input.viagem)
      AND ((dat_hor_partida <= l_dat_hor_partida AND dat_hor_retorno >= l_dat_hor_partida) OR
           (dat_hor_partida <= l_dat_hor_retorno AND dat_hor_retorno >= l_dat_hor_retorno) OR
           (dat_hor_partida <= l_dat_hor_retorno AND dat_hor_partida >= l_dat_hor_partida) OR
           (dat_hor_retorno <= l_dat_hor_retorno AND dat_hor_retorno >= l_dat_hor_partida))
  WHENEVER ERROR STOP

  IF mr_input.viagem = 0 THEN
     LET mr_input.viagem = NULL
  END IF

  IF SQLCA.SQLCODE = 0 OR SQLCA.SQLCODE = -284 THEN
     RETURN TRUE
  ELSE
     IF SQLCA.SQLCODE = 100 THEN
        RETURN FALSE
     ELSE
        CALL log003_err_sql('SELECAO','cdv_solic_viagem')
        RETURN TRUE
     END IF
  END IF

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_modificacao_acerto_sem_solic()
#-----------------------------------------------#
  LET mr_inputr.* = mr_input.*

  IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' THEN
     CALL log0030_mensagem("N�o existe acerto de despesa para esta viagem.",'exclamation')
     RETURN
  END IF

  IF cdv2000_eh_viagem_terc(mr_input.viagem) THEN
     CALL log0030_mensagem("Modifica��o n�o permitida pois esta � uma viagem exclusiva de terceiros. Manuten��o atrav�s do apontamento.","exclamation")
     RETURN
  END IF

  IF mr_input.ad_acerto_conta IS NOT NULL THEN
  ELSE
     IF cdv2000_verifica_viag_tot_aprov() THEN
        IF NOT cdv2000_verifica_fat_viag() THEN
           CALL log0030_mensagem("Acerto n�o pode ser modificado pois j� foi totalmente aprovado.",'exclamation')
           RETURN
        END IF
     END IF
  END IF

  IF NOT cdv2000_consiste_ex_mo() THEN
     RETURN
  END IF

  #IF cdv2000_verifica_acer_tot_aprov() THEN #Alterado spec.2
  #   CALL log0030_mensagem('Acerto de despesa j� foi totalmente aprovado.','exclamation')
  #   RETURN
  #END IF

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2000

  IF NOT cdv2000_exclui_despesa_no_cap(mr_input.ad_acerto_conta, mr_input.ap_acerto_conta) THEN
     ERROR "Exclus�o cancelada."
     RETURN
  ELSE
     INITIALIZE mr_input.ad_acerto_conta TO NULL
     DISPLAY BY NAME mr_input.ad_acerto_conta
  END IF

  LET mr_input.des_status = 'ACERTO VIAGEM INICIADO'
  DISPLAY BY NAME mr_input.des_status

  IF NOT cdv2000_entrada_dados_in_mo('MODIFICACAO') THEN
     ERROR 'Modifica��o cancelada.'
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*
     RETURN
  END IF

  IF cdv2000_cursor_for_update() THEN
     IF cdv2000_processa_atualizacoes('MODIFICACAO') AND
        cdv2000_atualiza_cursor_viagens_ativas() THEN

        IF cdv2000_deleta_tabelas() THEN
           CALL log085_transacao("COMMIT")
           MESSAGE 'Modifica��o efetuada com sucesso.' ATTRIBUTE(REVERSE)
           #LET m_alterou_viagem = TRUE
        ELSE
           CALL log085_transacao("ROLLBACK")
           ERROR 'Modifica��o cancelada.'
           LET mr_input.* = mr_inputr.*
           DISPLAY BY NAME mr_input.*
        END IF
     ELSE
        CALL log085_transacao("ROLLBACK")
        ERROR 'Modifica��o cancelada.'
        LET mr_input.* = mr_inputr.*
        DISPLAY BY NAME mr_input.*
     END IF
  ELSE
     ERROR 'Modifica��o cancelada.'
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*
     RETURN
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_verifica_viag_tot_aprov()
#--------------------------------------------#
  DEFINE l_count   SMALLINT

  LET l_count = 0

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_count
     FROM cdv_aprov_viag_781
    WHERE empresa  = p_cod_empresa
      AND viagem   = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','CDV_APROV_VIAG_781')
     RETURN TRUE
  END IF

  IF l_count = 0 THEN
     RETURN FALSE
  ELSE
     WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_count
        FROM cdv_aprov_viag_781
       WHERE empresa  = p_cod_empresa
         AND viagem   = mr_input.viagem
         AND eh_aprovado = "N"
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','CDV_APROV_VIAG_781')
        RETURN TRUE
     END IF

     IF l_count = 0 THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
     END IF
  END IF

 END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_deleta_tabelas()
#------------------------------------#
 WHENEVER ERROR CONTINUE
  DELETE FROM cdv_intg_fat_781
   WHERE empresa = mr_input.empresa
     AND viagem  = mr_input.viagem
     AND grp_despesa_viagem <> '6'
     #OS 487356
     AND grp_despesa_viagem <> '11'
     AND grp_despesa_viagem <> '12'
     #---

 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","CDV_INTG_FAT_781")
    RETURN FALSE
 END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM cdv_aprov_viag_781
    WHERE empresa = mr_input.empresa
      AND viagem  = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0  THEN
     CALL log003_err_sql("DELETE","cdv_aprov_viag_781")
     RETURN FALSE
  END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2000_exclui_viagem_no_contas_a_pagar()
#--------------------------------------------------#

  IF mr_input.ap_acerto_conta IS NOT NULL THEN
     IF NOT cdv2000_exclui_ap(mr_input.ap_acerto_conta) THEN
        RETURN FALSE
     END IF
  END IF

  IF mr_input.ad_acerto_conta IS NOT NULL THEN
     IF NOT cdv2000_exclui_ad(mr_input.ad_acerto_conta) THEN
        RETURN FALSE
     END IF
  END IF

  INITIALIZE mr_input.ad_acerto_conta TO NULL
  DISPLAY BY NAME mr_input.ad_acerto_conta

  RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION cdv2000_inicia_acerto()
#--------------------------------#

  IF cdv2000_possui_adtos_em_aberto(mr_input.viagem) THEN
     CALL log0030_mensagem("Viagem n�o pode ser iniciada pois n�o possui AP paga.","exclamation")
     RETURN
  END IF

  IF mr_input.des_status <> 'ACERTO VIAGEM PENDENTE' THEN
     CALL log0030_mensagem("Esta viagem j� possui acerto de despesas de viagem, utilize a op��o modifica��o.",'exclamation')
     RETURN
  END IF

  LET mr_inputr.* = mr_input.*
  LET mr_input.des_status = 'ACERTO VIAGEM INICIADO'
  DISPLAY BY NAME mr_input.des_status

  LET m_funcao = "COM_SOLIC"

  IF NOT cdv2000_entrada_dados_in_mo('MODIFICACAO') THEN
     CALL log0030_mensagem('Processo de in�cio do acerto cancelado.','exclamation')
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*
     RETURN
  END IF

  CALL log085_transacao("BEGIN")

  IF cdv2000_processa_atualizacoes('INICIO') AND
     cdv2000_atualiza_cursor_viagens_ativas() THEN
     CALL log085_transacao("COMMIT")
     CALL log0030_mensagem('Acerto iniciado com sucesso.','exclamation')
     #LET m_alterou_viagem = TRUE
  ELSE
     CALL log085_transacao("ROLLBACK")
     CALL log0030_mensagem('Processo de in�cio do acerto cancelado.','exclamation')
     LET mr_input.* = mr_inputr.*
     DISPLAY BY NAME mr_input.*
  END IF

END FUNCTION


#-------------------------------------------------#
 FUNCTION cdv2000_verifica_ativ_relacionada()
#-------------------------------------------------#
  DEFINE l_count   SMALLINT

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_count
     FROM cdv_find_ativ_781
    WHERE finalidade = mr_input.finalidade_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_find_ativ_781')
     RETURN FALSE
  END IF

  IF l_count > 0
  AND l_count IS NOT NULL THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_processa_atualizacoes(l_funcao)
#------------------------------------------------#

  DEFINE l_data_char          CHAR(19),
         l_dat_hr_emis_solic  DATETIME YEAR TO SECOND,
         l_dat_hor_partida    DATETIME YEAR TO SECOND,
         l_dat_hor_retorno    DATETIME YEAR TO SECOND,
         l_motivo_viagem      CHAR(200),
         l_funcao             CHAR(11),
         l_msg                CHAR(100),
         l_ad_km_semanal      LIKE ad_ap.num_ad,
         l_ap_km_semanal      LIKE ad_ap.num_ap,
         l_status             SMALLINT

  LET l_dat_hr_emis_solic = log0300_current(g_ies_ambiente)

  LET l_data_char = mr_input.dat_partida
  LET l_data_char = l_data_char[7,10],'-',
                    l_data_char[4,5],'-',
                    l_data_char[1,2],' ',
                    mr_input.hor_partida,':00'

  LET l_dat_hor_partida = l_data_char

  LET l_data_char = mr_input.dat_retorno
  LET l_data_char = l_data_char[7,10],'-',
                    l_data_char[4,5],'-',
                    l_data_char[1,2],' ',
                    mr_input.hor_retorno,':00'

  LET l_dat_hor_retorno = l_data_char
  LET l_motivo_viagem = mr_input.motivo_viagem1,
                        mr_input.motivo_viagem2,
                        mr_input.motivo_viagem3,
                        mr_input.motivo_viagem4

  IF l_funcao = 'INCLUSAO' THEN
     WHENEVER ERROR CONTINUE
      INSERT INTO cdv_solic_viag_781 (empresa,
                                      viagem,
                                      controle,
                                      dat_hr_emis_solic,
                                      viajante,
                                      finalidade_viagem,
                                      cc_viajante,
                                      cc_debitar,
                                      cliente_atendido,
                                      cliente_fatur,
                                      empresa_atendida,
                                      filial_atendida,
                                      trajeto_principal,
                                      dat_hor_partida,
                                      dat_hor_retorno,
                                      motivo_viagem)
                              VALUES (mr_input.empresa,
                                      mr_input.viagem,
                                      mr_input.controle,
                                      l_dat_hr_emis_solic,
                                      mr_input.viajante,
                                      mr_input.finalidade_viagem,
                                      mr_input.cc_viajante,
                                      mr_input.cc_debitar,
                                      mr_input.cliente_destino,
                                      mr_input.cliente_debitar,
                                      mr_input.empresa_atendida,
                                      mr_input.filial_atendida,
                                      mr_input.trajeto_principal,
                                      l_dat_hor_partida,
                                      l_dat_hor_retorno,
                                      l_motivo_viagem)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('INSERT','cdv_solic_viag_781')
        RETURN FALSE
     END IF
  END IF

  IF l_funcao = 'MODIFICACAO' OR l_funcao = 'INICIO' THEN
     WHENEVER ERROR CONTINUE
      UPDATE cdv_solic_viag_781
         SET controle          = mr_input.controle,
             finalidade_viagem = mr_input.finalidade_viagem,
             cc_debitar        = mr_input.cc_debitar,
             cliente_atendido  = mr_input.cliente_destino,
             cliente_fatur     = mr_input.cliente_debitar,
             empresa_atendida  = mr_input.empresa_atendida,
             filial_atendida   = mr_input.filial_atendida,
             trajeto_principal = mr_input.trajeto_principal,
             dat_hor_partida   = l_dat_hor_partida,
             dat_hor_retorno   = l_dat_hor_retorno,
             motivo_viagem     = l_motivo_viagem
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','cdv_solic_viag_781')
        RETURN FALSE
     END IF
  END IF

  IF l_funcao = 'INCLUSAO' OR l_funcao = 'INICIO' THEN
     WHENEVER ERROR CONTINUE
      INSERT INTO cdv_acer_viag_781 (empresa,
                                     viagem,
                                     controle,
                                     dat_hr_emis_relat,
                                     status_acer_viagem,
                                     viajante,
                                     finalidade_viagem,
                                     cc_viajante,
                                     cc_debitar,
                                     ad_acerto_conta,
                                     cliente_destino,
                                     cliente_debitar,
                                     empresa_atendida,
                                     filial_atendida,
                                     trajeto_principal,
                                     dat_hor_partida,
                                     dat_hor_retorno,
                                     motivo_viagem)
                             VALUES (mr_input.empresa,
                                     mr_input.viagem,
                                     mr_input.controle,
                                     l_dat_hr_emis_solic,
                                     '2',
                                     mr_input.viajante,
                                     mr_input.finalidade_viagem,
                                     mr_input.cc_viajante,
                                     mr_input.cc_debitar,
                                     NULL,
                                     mr_input.cliente_destino,
                                     mr_input.cliente_debitar,
                                     mr_input.empresa_atendida,
                                     mr_input.filial_atendida,
                                     mr_input.trajeto_principal,
                                     l_dat_hor_partida,
                                     l_dat_hor_retorno,
                                     l_motivo_viagem)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('INSERT','cdv_acer_viag_781')
        RETURN FALSE
     END IF
  END IF

  IF l_funcao = 'MODIFICACAO' THEN
     WHENEVER ERROR CONTINUE
      UPDATE cdv_acer_viag_781
         SET controle           = mr_input.controle,
             status_acer_viagem = '2',
             finalidade_viagem  = mr_input.finalidade_viagem,
             cc_viajante        = mr_input.cc_viajante,
             cc_debitar         = mr_input.cc_debitar,
             cliente_destino    = mr_input.cliente_destino,
             cliente_debitar    = mr_input.cliente_debitar,
             empresa_atendida   = mr_input.empresa_atendida,
             filial_atendida    = mr_input.filial_atendida,
             trajeto_principal  = mr_input.trajeto_principal,
             dat_hor_partida    = l_dat_hor_partida,
             dat_hor_retorno    = l_dat_hor_retorno,
             motivo_viagem      = l_motivo_viagem
       WHERE CURRENT OF cm_cr_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','cdv_acer_viag_781')
        RETURN FALSE
     END IF
  END IF

  CASE l_funcao
     WHEN 'MODIFICACAO'
        LET l_msg = "Relatorio de acerto de despesas modificado."
     WHEN 'INICIO'
        LET l_msg = "Relatorio de acerto de despesas iniciado."
     WHEN 'INCLUSAO'
        LET l_msg = "Relatorio de acerto de despesas inclu�do."
  END CASE

  IF NOT cdv2000_insere_cdv_protocol(l_msg) THEN
     RETURN FALSE
  END IF

  IF l_funcao = 'INCLUSAO' THEN
     LET mr_solic.viagem            = mr_input.viagem
     LET mr_solic.controle          = mr_input.controle
     LET mr_solic.viajante          = mr_input.viajante
     LET mr_solic.finalidade_viagem = mr_input.finalidade_viagem
     LET mr_solic.cc_viajante       = mr_input.cc_viajante
     LET mr_solic.cc_debitar        = mr_input.cc_debitar
     LET mr_solic.cliente_atendido  = mr_input.cliente_destino
     LET mr_solic.cliente_fatur     = mr_input.cliente_debitar
     LET mr_solic.empresa_atendida  = mr_input.empresa_atendida
     LET mr_solic.filial_atendida   = mr_input.filial_atendida
     LET mr_solic.trajeto_principal = mr_input.trajeto_principal
     LET mr_solic.dat_hor_partida   = l_dat_hor_partida
     LET mr_solic.dat_hor_retorno   = l_dat_hor_retorno
     LET mr_solic.motivo_viagem     = l_motivo_viagem

     IF NOT cdv2000_insert_w_solic() THEN
        RETURN FALSE
     END IF
  END IF

  IF l_funcao = 'MODIFICACAO' OR l_funcao = 'INICIO' THEN
     WHENEVER ERROR CONTINUE
      UPDATE w_solic
         SET controle          = mr_input.controle,
             finalidade_viagem = mr_input.finalidade_viagem,
             cc_debitar        = mr_input.cc_debitar,
             cliente_atendido  = mr_input.cliente_destino,
             cliente_fatur     = mr_input.cliente_debitar,
             empresa_atendida  = mr_input.empresa_atendida,
             filial_atendida   = mr_input.filial_atendida,
             trajeto_principal = mr_input.trajeto_principal,
             dat_hor_partida   = l_dat_hor_partida,
             dat_hor_retorno   = l_dat_hor_retorno,
             motivo_viagem     = l_motivo_viagem
       WHERE viagem = mr_input.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','w_solic')
        RETURN FALSE
     END IF
  END IF

  IF l_funcao = 'MODIFICACAO' THEN

     WHENEVER ERROR CONTINUE
      DECLARE cq_km_semanal_mod CURSOR FOR
       SELECT apropr_desp_km
         FROM cdv_despesa_km_781
        WHERE empresa            = mr_input.empresa
          AND viagem             = mr_input.viagem
          AND tip_despesa_viagem IN
           (SELECT cdv_tdesp_viag_781.tip_despesa_viagem
              FROM cdv_tdesp_viag_781
             WHERE cdv_tdesp_viag_781.empresa            = p_cod_empresa
               AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_despesa_km_781.tip_despesa_viagem
               AND cdv_tdesp_viag_781.grp_despesa_viagem = 3)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('DECLARE','cq_km_semanal_mod')
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
     FOREACH cq_km_semanal_mod INTO l_ad_km_semanal
     WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('FOREACH','cq_km_semanal_mod')
           RETURN FALSE
        END IF

        CALL cdv2000_recupera_primeira_ap(l_ad_km_semanal)
           RETURNING l_status, l_ap_km_semanal

        IF NOT cdv2000_exclui_despesa_no_cap(l_ad_km_semanal, l_ap_km_semanal) THEN
           ERROR "Exclus�o cancelada."
           RETURN FALSE
        END IF
     END FOREACH
     FREE cq_km_semanal_mod

     WHENEVER ERROR CONTINUE
     UPDATE cdv_despesa_km_781
        SET cdv_despesa_km_781.apropr_desp_km = ''
      WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
        AND cdv_despesa_km_781.viagem             = mr_input.viagem
        AND cdv_despesa_km_781.tip_despesa_viagem IN
            (SELECT cdv_tdesp_viag_781.tip_despesa_viagem
              FROM cdv_tdesp_viag_781
             WHERE cdv_tdesp_viag_781.empresa            = p_cod_empresa
               AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_despesa_km_781.tip_despesa_viagem
               AND cdv_tdesp_viag_781.grp_despesa_viagem = 3)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("UPDATE","cdv_despesa_km_781")
        RETURN FALSE
     END IF

  END IF

  RETURN TRUE

END FUNCTION

########################
### DESPESAS URBANAS ###
########################

#-----------------------------------------#
 FUNCTION cdv2000_manut_despesas_urbanas()
#-----------------------------------------#

  DEFINE l_den_viagem    CHAR(50)

  CALL log006_exibe_teclas('01', p_versao)

  LET m_caminho = log1300_procura_caminho('cdv20002','cdv20002')
  OPEN WINDOW w_cdv20002 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  LET m_urbanas_ativa = FALSE

  CALL cdv2000_consulta_previa()

  IF NOT cdv2000_carrega_ativs(mr_input.viagem) THEN
     CALL log0030_mensagem('Manuten��o cancelada.','exclamation')
     RETURN
  END IF

  INITIALIZE mr_desp_urbana.*, ma_desp_urbana TO NULL

  MENU 'URBANAS'
     BEFORE MENU
        IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' OR
           mr_input.des_status = 'ACERTO VIAGEM FINALIZADO' OR
           mr_input.des_status = 'ACERTO VIAGEM LIBERADO' THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
        END IF
        CALL cdv2000_carrega_urbanas_ja_informadas(mr_input.viagem, 'AUTOMATICO')
             RETURNING p_status

        LET mr_desp_urbana.viagem   = mr_input.viagem
        LET mr_desp_urbana.controle = mr_input.controle

        DISPLAY BY NAME mr_desp_urbana.*
        CALL cdv2000_exibe_desp_urbanas(1)

        IF cdv2000_verifica_usuario_viajante(mr_input.viagem) THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
			     END IF

     COMMAND 'Incluir' 'Inclui novas despesas urbanas.'
        HELP 001
        MESSAGE ''
        LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_urbana.viagem)
        IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
           IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'IN') THEN
              IF cdv2000_inclusao_modificacao_desp_urbanas('INCLUSAO') THEN
                 MESSAGE 'Inclus�o efetuada com sucesso.' ATTRIBUTE(REVERSE)
              END IF
           END IF
        ELSE
           CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
        END IF

     COMMAND 'Modificar' 'Modifica despesas urbanas.'
        HELP 002
        MESSAGE ''
        IF m_urbanas_ativa THEN
           LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_urbana.viagem)
           IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
              IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'MO') THEN
                 IF cdv2000_inclusao_modificacao_desp_urbanas('MODIFICACAO') THEN
                    MESSAGE 'Modifica��o efetuada com sucesso.' ATTRIBUTE(REVERSE)
                 END IF
              END IF
           ELSE
              CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
           END IF
        ELSE
           CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
           NEXT OPTION "Consultar"
        END IF

     COMMAND 'Consultar' 'Pesquisa despesas urbanas.'
        HELP 004
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'CO') THEN
           CALL cdv2000_consulta_desp_urbana()
        END IF

     COMMAND "Seguinte"   "Exibe a pr�xima despesa encontrada na consulta."
       HELP 005
       MESSAGE ""
       CALL cdv2000_paginacao_desp_urb("SEGUINTE")
       IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
          m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
          m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
          SHOW OPTION 'Incluir'
          SHOW OPTION 'Modificar'
       ELSE
          HIDE OPTION 'Incluir'
          HIDE OPTION 'Modificar'
       END IF

     COMMAND "Anterior"   "Exibe a despesa anterior encontrado na consulta."
       HELP 006
       MESSAGE ""
       CALL cdv2000_paginacao_desp_urb("ANTERIOR")
       IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
          m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
          m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
          SHOW OPTION 'Incluir'
          SHOW OPTION 'Modificar'
       ELSE
          HIDE OPTION 'Incluir'
          HIDE OPTION 'Modificar'
       END IF

     COMMAND KEY ('!')
        PROMPT 'Digite o m_comando : ' FOR m_comando
        RUN m_comando
        PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

     COMMAND 'Fim'       'Retorna ao menu anterior.'
        HELP 008
        EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv20002
  CURRENT WINDOW IS w_cdv2000

END FUNCTION

#-----------------------------------------------------------#
 FUNCTION cdv2000_inclusao_modificacao_desp_urbanas(l_funcao)
#-----------------------------------------------------------#
  DEFINE l_funcao  CHAR(11)

  IF l_funcao = 'INCLUSAO' THEN
     IF NOT cdv2000_entrada_desp_urbanas(l_funcao) THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO empresa
        ERROR "Inclus�o cancelada."
        RETURN FALSE
     END IF
  ELSE
     IF NOT cdv2000_entrada_array_desp_urbanas(l_funcao) THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO empresa
        LET m_urbanas_ativa = FALSE
        ERROR "Modifica��o cancelada."
        RETURN FALSE
     END IF
  END IF

  CALL log085_transacao("BEGIN")

  IF cdv2000_atualiza_desp_urbanas(l_funcao) THEN
     CALL log085_transacao("COMMIT")
     LET mr_desp_urbana.tot_geral = cdv2000_recupera_tot_desp_urbanas()
     DISPLAY BY NAME mr_desp_urbana.tot_geral
     LET m_urbanas_ativa = TRUE
     RETURN TRUE
  ELSE
     CALL log085_transacao("ROLLBACK")
     CLEAR FORM
     DISPLAY p_cod_empresa TO empresa
     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_consulta_desp_urbana()
#---------------------------------------#
  IF NOT cdv2000_entrada_desp_urbanas('CONSULTA') THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF

  IF NOT cdv2000_carrega_urbanas_ja_informadas(mr_desp_urbana.viagem, 'MANUAL') THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF

  CALL cdv2000_exibe_desp_urbanas(2)

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_exibe_desp_urbanas(l_cont)
#--------------------------------------------#
  DEFINE l_ind       SMALLINT,
         l_cont      SMALLINT

 FOR l_ind = 1 TO 200
    IF ma_desp_urbana[l_ind].ativ IS NULL THEN
       EXIT FOR
    END IF
 END FOR

 IF (l_ind -1) = 0 THEN
    IF l_cont = 2 THEN
       CALL log0030_mensagem('Argumentos de pesquisa n�o encontrados.','exclamation')
    ELSE
       FOR l_ind = 1 TO 3
          DISPLAY ma_desp_urbana[l_ind].* TO s_desp_urbana[l_ind].*
       END FOR
    END IF
 ELSE
    LET l_ind = l_ind - 1
    CALL SET_COUNT(l_ind)
    LET mr_desp_urbana.tot_geral = cdv2000_recupera_total_desp_urbanas()
    DISPLAY BY NAME mr_desp_urbana.tot_geral

    IF l_ind > 3 THEN
       DISPLAY ARRAY ma_desp_urbana TO s_desp_urbana.*
       END DISPLAY
    ELSE
       FOR l_ind = 1 TO 3
          DISPLAY ma_desp_urbana[l_ind].* TO s_desp_urbana[l_ind].*
       END FOR
    END IF
    LET m_urbanas_ativa = TRUE
 END IF

 END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_atualiza_desp_urbanas(l_funcao)
#------------------------------------------------#
  DEFINE l_funcao       CHAR(11),
         l_max_seq      SMALLINT,
         l_ind          SMALLINT

  IF l_funcao = 'INCLUSAO' THEN
     WHENEVER ERROR CONTINUE
      SELECT MAX(seq_despesa_urbana)
        INTO l_max_seq
        FROM cdv_desp_urb_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_urbana.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT-MAX','cdv_desp_urb_781')
        RETURN FALSE
     END IF
     IF l_max_seq IS NULL OR l_max_seq = 0 THEN
        LET l_max_seq = 1
     ELSE
        LET l_max_seq = l_max_seq + 1
     END IF
  ELSE
     LET l_max_seq = 1
  END IF

  IF l_funcao = 'MODIFICACAO' THEN
     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_desp_urb_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_urbana.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('DELETE','cdv_desp_urb_781')
        RETURN FALSE
     END IF
  END IF

  FOR l_ind = 1 TO 200
     IF ma_desp_urbana[l_ind].ativ IS NULL THEN
        EXIT FOR
     END IF

     WHENEVER ERROR CONTINUE
      INSERT INTO cdv_desp_urb_781 (empresa,
                                    viagem,
                                    seq_despesa_urbana,
                                    ativ,
                                    tip_despesa_viagem,
                                    docum_viagem,
                                    dat_despesa_urbana,
                                    val_despesa_urbana,
                                    placa, #OS 487356
                                    obs_despesa_urbana)
                            VALUES (p_cod_empresa,
                                    mr_desp_urbana.viagem,
                                    l_max_seq,
                                    ma_desp_urbana[l_ind].ativ,
                                    ma_desp_urbana[l_ind].tipo_despesa,
                                    ma_desp_urbana[l_ind].num_documento,
                                    ma_desp_urbana[l_ind].dat_documento,
                                    ma_desp_urbana[l_ind].val_documento,
                                    ma_desp_urbana[l_ind].placa, #OS 487356
                                    ma_desp_urbana[l_ind].observacao)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('INSERT','cdv_desp_urb_781')
        RETURN FALSE
     END IF

     LET l_max_seq = l_max_seq + 1
  END FOR

  RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_entrada_desp_urbanas(l_funcao)
#-----------------------------------------------#
  DEFINE l_funcao         CHAR(11),
         l_informa_placa  LIKE cdv_tdesp_viag_781.informa_placa #OS 487356

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv20002

  INITIALIZE {mr_desp_urbana.*,} ma_desp_urbana TO NULL
  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa

  IF m_viagem_urbanas IS NOT NULL
  AND m_viagem_urbanas <> 0
  AND l_funcao = 'INCLUSAO' THEN
     LET mr_desp_urbana.viagem   = m_viagem_urbanas
  END IF
  #LET mr_desp_urbana.controle = mr_input.controle

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_desp_urbana.* WITHOUT DEFAULTS

     BEFORE FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_desp_urbana.controle IS NOT NULL THEN
           IF NOT cdv2000_valida_controle_ativo(mr_desp_urbana.controle, mr_desp_urbana.viagem) THEN
              CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
              NEXT FIELD controle
           END IF
        END IF

     BEFORE FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

        IF mr_desp_urbana.controle IS NOT NULL
        AND ( mr_desp_urbana.viagem IS NULL
              OR mr_desp_urbana.viagem = 0 )THEN
           LET mr_desp_urbana.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_urbana.controle)
           DISPLAY BY NAME mr_desp_urbana.viagem
        END IF

     AFTER FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF mr_desp_urbana.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_desp_urbana.viagem, mr_desp_urbana.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_desp_urbana.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem a qual as despesas se referem.','exclamation')
                 NEXT FIELD controle
              ELSE
                 LET mr_desp_urbana.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_urbana.controle)
                 IF mr_desp_urbana.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_urbana.viagem
                 END IF
              END IF
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_desp_urbana.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_ativo(mr_desp_urbana.controle, mr_desp_urbana.viagem) THEN
                 CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF
           IF mr_desp_urbana.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_desp_urbana.viagem, mr_desp_urbana.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_desp_urbana.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem a qual as despesas se referem.','exclamation')
                 NEXT FIELD controle
              ELSE
                 LET mr_desp_urbana.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_urbana.controle)
                 IF mr_desp_urbana.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_urbana.viagem
                 END IF
              END IF
           END IF

           LET mr_desp_urbana.tot_geral = cdv2000_recupera_tot_desp_urbanas()
           DISPLAY BY NAME mr_desp_urbana.tot_geral

        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup("URBANAS")

  END INPUT

  IF INT_FLAG THEN
     RETURN FALSE
  ELSE
     IF l_funcao <> 'CONSULTA' THEN
        RETURN cdv2000_entrada_array_desp_urbanas(l_funcao)
     ELSE
        RETURN TRUE
     END IF
  END IF

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2000_entrada_array_desp_urbanas(l_funcao)
#-----------------------------------------------------#
  DEFINE l_funcao         CHAR(11),
         l_arr_curr       SMALLINT,
         l_scr_line       SMALLINT,
         l_status         SMALLINT,
         l_ind            SMALLINT,
         l_informa_placa  LIKE cdv_tdesp_viag_781.informa_placa #OS 487356

  LET mr_desp_urbana.tot_geral = cdv2000_recupera_total_desp_urbanas()

  FOR l_ind = 1 TO 200
     IF ma_desp_urbana[l_ind].ativ IS NULL THEN
        EXIT FOR
     END IF
  END FOR

  CALL SET_COUNT(l_ind -1)
  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_cdv20002

  LET INT_FLAG = 0
  INPUT ARRAY ma_desp_urbana WITHOUT DEFAULTS FROM s_desp_urbana.*
  --# ATTRIBUTE (INSERT ROW=FALSE)

     BEFORE ROW
        LET l_arr_curr = ARR_CURR()
        LET l_scr_line = SCR_LINE()

     BEFORE FIELD ativ
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

        IF ma_atividades[2].ativ IS NULL THEN
           LET ma_desp_urbana[l_arr_curr].ativ = ma_atividades[1].ativ
           DISPLAY ma_desp_urbana[l_arr_curr].des_ativ TO s_desp_urbana[l_scr_line].ativ
        END IF

     AFTER FIELD ativ
        IF ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
           CALL cdv2000_valida_ativ(ma_desp_urbana[l_arr_curr].ativ)
              RETURNING l_status, ma_desp_urbana[l_arr_curr].des_ativ
           IF NOT l_status THEN
              NEXT FIELD ativ
           END IF
        ELSE
           IF ma_desp_urbana[l_arr_curr].tipo_despesa IS NOT NULL THEN
              CALL log0030_mensagem("Atividade deve ser informada.","info")
              NEXT FIELD ativ
           ELSE
              LET ma_desp_urbana[l_arr_curr].des_ativ = NULL
           END IF
        END IF
        DISPLAY ma_desp_urbana[l_arr_curr].des_ativ TO s_desp_urbana[l_scr_line].des_ativ

     BEFORE FIELD tipo_despesa
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF
        IF l_funcao = "INCLUSAO"
        OR ma_desp_urbana[l_arr_curr].tipo_despesa IS NULL THEN
           LET ma_desp_urbana[l_arr_curr].tipo_despesa = cdv2000_recupera_tip_desp_por_ativ(l_arr_curr)
        END IF

     AFTER FIELD tipo_despesa
        IF ma_desp_urbana[l_arr_curr].tipo_despesa IS NOT NULL THEN
           CALL cdv2000_valida_tipo_despesa(ma_desp_urbana[l_arr_curr].tipo_despesa, 'URBANAS', l_arr_curr, ma_desp_urbana[l_arr_curr].ativ)
              RETURNING l_status, ma_desp_urbana[l_arr_curr].des_tip_desp
           IF NOT l_status THEN
              NEXT FIELD tipo_despesa
           END IF
        ELSE
           LET ma_desp_urbana[l_arr_curr].des_tip_desp = NULL
        END IF
        DISPLAY ma_desp_urbana[l_arr_curr].des_tip_desp TO s_desp_urbana[l_scr_line].des_tip_desp

        #INICIO OS.470958
        IF ma_desp_urbana[l_arr_curr].tipo_despesa = m_tipo_despesa THEN
           CALL log0030_mensagem("Aplicar regra de refei��o.","info")
        END IF
        #FIM OS.470958

     BEFORE FIELD dat_documento
        IF l_funcao = "INCLUSAO"
        OR ma_desp_urbana[l_arr_curr].dat_documento IS NULL THEN
           LET ma_desp_urbana[l_arr_curr].dat_documento = cdv2000_busca_data_viagem(mr_desp_urbana.viagem)
           DISPLAY ma_desp_urbana[l_arr_curr].dat_documento TO s_desp_urbana[l_scr_line].dat_documento
        END IF

     #OS 487356
     AFTER FIELD placa
       WHENEVER ERROR CONTINUE
        SELECT informa_placa
          INTO l_informa_placa
          FROM cdv_tdesp_viag_781
         WHERE empresa            = p_cod_empresa
           AND tip_despesa_viagem = ma_desp_urbana[l_arr_curr].tipo_despesa
           AND ativ               = ma_desp_urbana[l_arr_curr].ativ
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_informa_placa = "N"
       END IF

       IF ma_desp_urbana[l_arr_curr].placa IS NULL AND l_informa_placa = "S" THEN
          CALL log0030_mensagem ("O campo placa est� parametrizado no CDV2004 para ser informado.","info")
          NEXT FIELD placa
       ELSE
          NEXT FIELD observacao
       END IF
     #---

     AFTER FIELD observacao
        LET mr_desp_urbana.tot_geral = cdv2000_recupera_total_desp_urbanas()
        DISPLAY BY NAME mr_desp_urbana.tot_geral

     AFTER DELETE
        LET mr_desp_urbana.tot_geral = cdv2000_recupera_total_desp_urbanas()
        DISPLAY BY NAME mr_desp_urbana.tot_geral

     AFTER INPUT
        IF NOT INT_FLAG THEN
           FOR l_arr_curr = 1 TO 200
              IF ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
                 CALL cdv2000_valida_ativ(ma_desp_urbana[l_arr_curr].ativ)
                    RETURNING l_status, ma_desp_urbana[l_arr_curr].des_ativ
                 IF l_status THEN
                    DISPLAY ma_desp_urbana[l_arr_curr].des_ativ TO s_desp_urbana[l_scr_line].des_ativ
                 ELSE
                    NEXT FIELD ativ
                 END IF
              END IF

              IF ma_desp_urbana[l_arr_curr].tipo_despesa IS NOT NULL THEN
                 CALL cdv2000_valida_tipo_despesa(ma_desp_urbana[l_arr_curr].tipo_despesa, 'URBANAS', l_arr_curr, ma_desp_urbana[l_arr_curr].ativ)
                    RETURNING l_status, ma_desp_urbana[l_arr_curr].des_tip_desp
                 IF l_status THEN
                    DISPLAY ma_desp_urbana[l_arr_curr].des_tip_desp TO s_desp_urbana[l_scr_line].des_tip_desp
                 ELSE
                    NEXT FIELD tipo_despesa
                 END IF
              ELSE
                 IF ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
                    CALL log0030_mensagem('Informe o tipo de despesa relacionado � despesa.','exclamation')
                    NEXT FIELD tipo_despesa
                 END IF
              END IF

              IF ma_desp_urbana[l_arr_curr].num_documento IS NULL AND
                 ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
                  CALL log0030_mensagem('Informe o n�mero do documento relacionado � despesa.','exclamation')
                  NEXT FIELD num_documento
              END IF

              IF ma_desp_urbana[l_arr_curr].dat_documento IS NOT NULL THEN
                 IF NOT cdv2000_verifica_data_viagem(mr_desp_urbana.viagem,
                                                     ma_desp_urbana[l_arr_curr].dat_documento) THEN
                    CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                    NEXT FIELD dat_documento
                 END IF
              ELSE
                 IF ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
                    CALL log0030_mensagem('Informe a data na qual aconteceu a despesa.','exclamation')
                    NEXT FIELD dat_documento
                 END IF
              END IF

              IF ma_desp_urbana[l_arr_curr].val_documento IS NOT NULL THEN
                 IF ma_desp_urbana[l_arr_curr].val_documento <= 0 THEN
                    CALL log0030_mensagem('Valor da despesa deve ser maior que 0 (zero).','exclamation')
                    NEXT FIELD val_documento
                 END IF
                 IF NOT cdv2000_verifica_limite_despesa_refeicao(ma_desp_urbana[l_arr_curr].tipo_despesa,
                                                                 ma_desp_urbana[l_arr_curr].val_documento) THEN
                    NEXT FIELD tipo_despesa
                 END IF
              ELSE
                 IF ma_desp_urbana[l_arr_curr].ativ IS NOT NULL THEN
                    CALL log0030_mensagem('Informe o valor da despesa.','exclamation')
                    NEXT FIELD val_documento
                 END IF
              END IF
           END FOR

           IF NOT log0040_confirm(19,34,"Confirma dados informados?") THEN
              NEXT FIELD ativ
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup_array(l_arr_curr, l_scr_line, 'UR')

  END INPUT

  RETURN NOT INT_FLAG

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2000_verifica_data_viagem(l_viagem, l_dat_docum)
#--------------------------------------------------------------#
 DEFINE l_dat_hor_partida  CHAR(19),
        l_dat_hor_retorno  CHAR(19),
        l_dat_docum        DATE,
        l_dat_partida      CHAR(10),
        l_dat_retorno      CHAR(10),
        l_viagem           LIKE cdv_acer_viag_781.viagem

 WHENEVER ERROR CONTINUE
  SELECT dat_hor_partida, dat_hor_retorno
    INTO l_dat_hor_partida, l_dat_hor_retorno
    FROM cdv_acer_viag_781
   WHERE empresa = p_cod_empresa
     AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_ACER_VIAG_781")
    RETURN FALSE
 END IF

 LET l_dat_partida = l_dat_hor_partida[9,10],"/",l_dat_hor_partida[6,7],"/",l_dat_hor_partida[1,4]
 LET l_dat_retorno = l_dat_hor_retorno[9,10],"/",l_dat_hor_retorno[6,7],"/",l_dat_hor_retorno[1,4]

 IF l_dat_docum > l_dat_retorno OR
    l_dat_docum < l_dat_partida THEN
     RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------------------------------------#
 FUNCTION cdv2000_verifica_limite_despesa_refeicao(l_tip_desp, l_val_desp)
#--------------------------------------------------------------------------#
 DEFINE l_tip_desp          LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_tip_desp_refeicao LIKE cdv_par_ctr_viagem.tip_desp_refeicao,
        l_tipo_desp_ref     LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_val_desp          LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_val_max_refeicao  LIKE cdv_par_ctr_viagem.val_max_refeicao

 WHENEVER ERROR CONTINUE
  SELECT tip_desp_refeicao, val_max_refeicao
    INTO l_tip_desp_refeicao, l_val_max_refeicao
    FROM cdv_par_ctr_viagem
   WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

 LET l_tipo_desp_ref = l_tip_desp_refeicao

 IF SQLCA.sqlcode = 0 THEN
    IF l_tip_desp_refeicao = l_tip_desp THEN
       IF l_val_desp > l_val_max_refeicao THEN
          CALL log0030_mensagem("Valor da despesa com refei��o maior que o limite definido no CDV0010.","info")
          RETURN FALSE
       END IF
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2000_recupera_viagem_por_controle(l_controle)
#---------------------------------------------------------#
  DEFINE l_controle    LIKE cdv_acer_viag_781.controle,
         l_viagem      LIKE cdv_acer_viag_781.viagem,
         l_qtd_regs    SMALLINT

  INITIALIZE l_viagem TO NULL

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_regs
     FROM w_solic
    WHERE controle = l_controle
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode = 0 AND l_qtd_regs = 1 THEN
     WHENEVER ERROR CONTINUE
      SELECT viagem INTO l_viagem
        FROM w_solic
       WHERE controle = l_controle
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','w_solic')
     END IF
  END IF

  RETURN l_viagem

END FUNCTION

#------------------------------------------------------------#
 FUNCTION cdv2000_valida_controle_ativo(l_controle, l_viagem)
#------------------------------------------------------------#
  DEFINE l_viagem    LIKE cdv_acer_viag_781.viagem,
         l_controle  LIKE cdv_acer_viag_781.controle,
         sql_stmt    CHAR(500)

  LET sql_stmt = 'SELECT unique controle FROM w_solic WHERE controle = "',l_controle,'"'

  WHENEVER ERROR CONTINUE
   PREPARE var_valida_ctrl FROM sql_stmt
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","VAR_VALIDA_CTRL")
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_valida_ctrl CURSOR FOR var_valida_ctrl
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_VALIDA_CTRL")
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_valida_ctrl
   WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN","CQ_VALIDA_CTRL")
  END IF

  WHENEVER ERROR CONTINUE
   FETCH cq_valida_ctrl INTO l_controle
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     RETURN FALSE
  END IF

   WHENEVER ERROR CONTINUE
   CLOSE cq_valida_ctrl
   FREE  cq_valida_ctrl
   WHENEVER ERROR STOP

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv2000_valida_viagem_ativa(l_viagem, l_controle)
#----------------------------------------------------------#
  DEFINE l_viagem    LIKE cdv_acer_viag_781.viagem,
         l_controle  LIKE cdv_acer_viag_781.controle,
         sql_stmt    CHAR(500)

  LET sql_stmt = 'SELECT UNIQUE viagem FROM w_solic WHERE viagem = ',l_viagem

  IF l_controle IS NOT NULL THEN
     LET sql_stmt = sql_stmt clipped, ' AND controle = "',l_controle,'"'
  END IF

  WHENEVER ERROR CONTINUE
   PREPARE var_valida_viag FROM sql_stmt
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","VAR_VALIDA_VALIDA")
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_valida_valida CURSOR FOR var_valida_viag
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_VALIDA_VALIDA")
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_valida_valida
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("OPEN","CQ_VALIDA_VALIDA")
   END IF

  WHENEVER ERROR CONTINUE
   FETCH cq_valida_valida INTO l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  CLOSE cq_valida_valida
  FREE cq_valida_valida
  WHENEVER ERROR STOP

  RETURN TRUE

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_recupera_tot_desp_urbanas()
#--------------------------------------------#
  DEFINE l_tot_geral    DECIMAL(12,2)

  LET l_tot_geral = 0

  WHENEVER ERROR CONTINUE
   SELECT SUM(val_despesa_urbana)
     INTO l_tot_geral
     FROM cdv_desp_urb_781
    WHERE empresa = p_cod_empresa
      AND viagem  = mr_desp_urbana.viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_desp_urb_781')
  END IF

  RETURN l_tot_geral

END FUNCTION

#------------------------------------------------------------------------#
 FUNCTION cdv2000_carrega_urbanas_ja_informadas(l_viagem, l_modo_consulta)
#------------------------------------------------------------------------#
  DEFINE l_ind                  SMALLINT,
         l_status               SMALLINT,
         l_viagem               LIKE cdv_desp_urb_781.viagem,
         l_modo_consulta        CHAR(15),
         l_sql_stmt             CHAR(2000),
         l_viagem_registro      LIKE cdv_desp_urb_781.viagem,
         l_achou_mesmo_registro SMALLINT,
         l_ativ_ant             LIKE cdv_desp_urb_781.ativ,
         l_tipo_despesa_ant     LIKE cdv_desp_urb_781.tip_despesa_viagem,
         l_num_documento_ant    LIKE cdv_desp_urb_781.docum_viagem,
         l_dat_documento_ant    LIKE cdv_desp_urb_781.dat_despesa_urbana,
         l_val_documento_ant    LIKE cdv_desp_urb_781.val_despesa_urbana,
         l_placa                LIKE cdv_desp_urb_781.placa, #OS 487356
         l_observacao_ant       LIKE cdv_desp_urb_781.obs_despesa_urbana

  INITIALIZE l_sql_stmt, ma_desp_urbana TO NULL

  LET l_ind = 1

  IF l_modo_consulta = 'AUTOMATICO' THEN

     LET m_consulta_urb_aut = FALSE

     WHENEVER ERROR CONTINUE
     DECLARE cq_desp_urb_aut SCROLL CURSOR WITH HOLD FOR
     SELECT UNIQUE viagem
       FROM cdv_desp_urb_781
      WHERE empresa = p_cod_empresa
        AND viagem  IN (SELECT UNIQUE viagem FROM w_solic )
     UNION ALL
      SELECT UNIQUE viagem
        FROM w_solic
       WHERE viagem NOT IN (SELECT UNIQUE viagem
                            FROM cdv_desp_urb_781
                           WHERE empresa = p_cod_empresa
                             AND viagem  IN (SELECT UNIQUE viagem FROM w_solic ))
      ORDER BY 1
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","CQ_DESP_URB_AUT")
     ELSE
        WHENEVER ERROR CONTINUE
        OPEN cq_desp_urb_aut
        WHENEVER ERROR STOP

        LET m_consulta_urb_aut = TRUE
     END IF
  END IF

  LET l_sql_stmt =  " SELECT ativ, tip_despesa_viagem, docum_viagem, ",
                    " dat_despesa_urbana, val_despesa_urbana, placa, obs_despesa_urbana ", #OS 487356
                    " FROM cdv_desp_urb_781 ",
                    " WHERE empresa = '",p_cod_empresa,"' ",
                    " AND viagem    = ",l_viagem," "

  WHENEVER ERROR CONTINUE
  PREPARE var_desp_urb FROM l_sql_stmt
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","exclamation")
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_desp_urbanas CURSOR FOR var_desp_urb
  WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_DESP_URBANAS")
   END IF

   LET l_achou_mesmo_registro = FALSE
   WHENEVER ERROR CONTINUE
   FOREACH cq_desp_urbanas INTO ma_desp_urbana[l_ind].ativ,
                                ma_desp_urbana[l_ind].tipo_despesa,
                                ma_desp_urbana[l_ind].num_documento,
                                ma_desp_urbana[l_ind].dat_documento,
                                ma_desp_urbana[l_ind].val_documento,
                                ma_desp_urbana[l_ind].placa, #OS 487356
                                ma_desp_urbana[l_ind].observacao
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_desp_urbanas')
        RETURN FALSE
     END IF

     CALL cdv2000_valida_ativ(ma_desp_urbana[l_ind].ativ)
        RETURNING l_status, ma_desp_urbana[l_ind].des_ativ
     CALL cdv2000_valida_tipo_despesa(ma_desp_urbana[l_ind].tipo_despesa, 'URBANAS', l_ind, ma_desp_urbana[l_ind].ativ)
        RETURNING l_status, ma_desp_urbana[l_ind].des_tip_desp

     LET l_ind = l_ind + 1
  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_desp_urbanas
  WHENEVER ERROR STOP

  RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_valida_ativ(l_ativ)
#-----------------------------------------#
  DEFINE l_ativ      LIKE cdv_ativ_781.ativ,
         l_des_ativ  LIKE cdv_ativ_781.des_ativ,
         l_ind       SMALLINT

  FOR l_ind = 1 TO 200
     IF ma_atividades[l_ind].ativ IS NULL THEN
        CALL log0030_mensagem('Atividade n�o relacionada a viagem.','exclamation')
        RETURN FALSE, ''
     END IF
     IF ma_atividades[l_ind].ativ = l_ativ THEN
        EXIT FOR
     END IF
  END FOR

  WHENEVER ERROR CONTINUE
   SELECT des_ativ
     INTO l_des_ativ
     FROM cdv_ativ_781
    WHERE ativ = l_ativ
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_ativ_781')
     RETURN FALSE, ''
  END IF

  RETURN TRUE, l_des_ativ

END FUNCTION

#---------------------------------------------------------------------------------#
 FUNCTION cdv2000_valida_tipo_despesa(l_tipo_despesa, l_km_urb, l_ind, l_atividade)
#---------------------------------------------------------------------------------#
  DEFINE l_tipo_despesa        LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_des_tip_desp        LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
         l_ind                 SMALLINT,
         l_atividade           LIKE cdv_tdesp_viag_781.ativ,
         l_grp_despesa_viagem  SMALLINT,
         l_ativ           LIKE cdv_ativ_781.ativ,
         l_km_urb              CHAR(07)

  INITIALIZE l_des_tip_desp TO NULL

  WHENEVER ERROR CONTINUE
   SELECT des_tdesp_viagem, grp_despesa_viagem, ativ
     INTO l_des_tip_desp, l_grp_despesa_viagem, l_ativ
     FROM cdv_tdesp_viag_781
    WHERE empresa            = p_cod_empresa
      AND tip_despesa_viagem = l_tipo_despesa
      AND ativ               = l_atividade
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     IF SQLCA.SQLCODE = 100 THEN
        CALL log0030_mensagem('Tipo de despesa n�o cadastrado.','exclamation')
        RETURN FALSE, l_des_tip_desp
     ELSE
        CALL log003_err_sql('SELECT','cdv_tdesp_viag_781')
        RETURN FALSE, l_des_tip_desp
     END IF
  END IF

  IF (l_km_urb = 'URBANAS' AND l_grp_despesa_viagem <> 1) OR
     (l_km_urb = 'KM' AND (l_grp_despesa_viagem <> 2 AND l_grp_despesa_viagem <> 3)) OR
     (l_km_urb = 'APONT' AND l_grp_despesa_viagem <> 5) OR
     (l_km_urb = 'TERC' AND l_grp_despesa_viagem <> 4) THEN
     CALL log0030_mensagem('Tipo de despesa n�o pertence ao grupo de despesa correspondente.','exclamation')
     RETURN FALSE, ''
  END IF

  ##Chamado 801668
  IF l_km_urb = 'URBANAS' THEN
     IF l_ativ <> ma_desp_urbana[l_ind].ativ THEN
        CALL log0030_mensagem('Tipo de despesa relacionado a atividade inv�lida.','exclamation')
        RETURN FALSE, ''
     END IF
  END IF

  IF l_km_urb = 'APONT' THEN
     IF l_ativ <> ma_desp_km[l_ind].ativ THEN
        CALL log0030_mensagem('Tipo de despesa relacionado a atividade inv�lida.','exclamation')
        RETURN FALSE, ''
     END IF
  END IF

  IF l_km_urb = 'TERC' THEN
     IF l_ativ <> mr_desp_terc.ativ THEN
        CALL log0030_mensagem('Tipo de despesa relacionado a atividade inv�lida.','exclamation')
        RETURN FALSE, ''
     END IF
  END IF

  IF l_km_urb = 'KM' THEN
     FOR l_ind = 1 TO 200
        IF ma_atividades[l_ind].ativ IS NULL THEN
           CALL log0030_mensagem('Tipo de despesa relacionado a atividade inv�lida.','exclamation')
           RETURN FALSE, ''
        END IF
        IF ma_atividades[l_ind].ativ = l_ativ THEN
           EXIT FOR
        END IF
     END FOR
  END IF

  IF l_grp_despesa_viagem = 7
  OR l_grp_despesa_viagem = 8
  OR l_grp_despesa_viagem = 9
  OR l_grp_despesa_viagem = 10 THEN
     CALL log0030_mensagem('Tipo de despesa relacionado ao sistema LEGADO.','exclamation')
     RETURN FALSE, ''
  END IF

  RETURN TRUE, l_des_tip_desp

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_carrega_ativs(l_viagem)
#---------------------------------------#
  DEFINE l_viagem LIKE cdv_solic_viag_781.viagem,
         l_ind    SMALLINT

  INITIALIZE ma_atividades TO NULL
  LET l_ind = 1

  WHENEVER ERROR CONTINUE
   DECLARE cq_atividades CURSOR FOR
    SELECT cdv_find_ativ_781.ativ
      FROM cdv_find_ativ_781, cdv_acer_viag_781
     WHERE cdv_acer_viag_781.empresa    = p_cod_empresa
       AND cdv_acer_viag_781.viagem     = l_viagem
       AND cdv_find_ativ_781.finalidade = cdv_acer_viag_781.finalidade_viagem
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_ATIVIDADES")
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_atividades INTO ma_atividades[l_ind].ativ
   WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_atividades')
        RETURN FALSE
     END IF
     LET l_ind = l_ind + 1
  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_atividades
  WHENEVER ERROR STOP

  RETURN TRUE

END FUNCTION


#----------------------------------------------------#
 FUNCTION cdv2000_popup_array(l_curr, l_scr, l_ur_km)
#----------------------------------------------------#
  DEFINE l_curr, l_ind      SMALLINT,
         l_scr              SMALLINT,
         l_ativ             LIKE cdv_ativ_781.ativ,
         where_clause       CHAR(500),
         l_tipo_despesa_km  LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_motivo           LIKE cdv_motivo_hor_781.motivo,
         l_ur_km            CHAR(02)

#OS 520395
  DEFINE l_cidade_origem    CHAR(05),
         l_cidade_destino   CHAR(05)
#---------

  CASE
     WHEN INFIELD(ativ)
        LET l_ativ = cdv2000_popup_ativ()

        IF l_ur_km = 'UR' THEN
           CURRENT WINDOW IS w_cdv20002
           IF l_ativ IS NOT NULL THEN
              LET ma_desp_urbana[l_curr].ativ = l_ativ
              DISPLAY ma_desp_urbana[l_curr].ativ TO s_desp_urbana[l_scr].ativ
           END IF
        ELSE
           CURRENT WINDOW IS w_cdv20003
           IF l_ativ IS NOT NULL THEN
              LET ma_desp_km[l_curr].ativ = l_ativ
              DISPLAY ma_desp_km[l_curr].ativ TO s_desp_km[l_scr].ativ
           END IF
        END IF

#OS 520395
     WHEN INFIELD(cidade_origem)
        LET l_cidade_origem = vdp309_popup_cidades()
        CURRENT WINDOW IS w_cdv20003
        IF l_cidade_origem IS NOT NULL THEN
           LET ma_desp_km[l_curr].cidade_origem = l_cidade_origem
           DISPLAY ma_desp_km[l_curr].cidade_origem TO s_desp_km[l_scr].cidade_origem
        END IF

     WHEN INFIELD(cidade_destino)
        LET l_cidade_destino = vdp309_popup_cidades()
        CURRENT WINDOW IS w_cdv20003
        IF l_cidade_destino IS NOT NULL THEN
           LET ma_desp_km[l_curr].cidade_destino = l_cidade_destino
           DISPLAY ma_desp_km[l_curr].cidade_destino TO s_desp_km[l_scr].cidade_destino
        END IF
#---------

     WHEN INFIELD(tipo_despesa_km)
        #LET where_clause = ' grp_despesa_viagem IN ("2", "3")',
        #                   ' AND ativ IN ( ', ma_desp_km[l_curr].ativ, ' ) '

        IF ma_desp_km[l_curr].ativ IS NOT NULL THEN
           LET where_clause = ' grp_despesa_viagem IN ("2", "3")',
                              ' AND ativ IN ( ', ma_desp_km[l_curr].ativ, ' ) '

        ELSE
          LET where_clause = ' grp_despesa_viagem IN ("2", "3")',
                  ' AND ativ IN ( '

           FOR l_ind = 1 TO 200
              IF ma_atividades[l_ind].ativ IS NULL THEN
                 LET where_clause = where_clause CLIPPED, ')'
                 EXIT FOR
              END IF
              IF l_ind = 1 THEN
                 LET where_clause = where_clause CLIPPED, ma_atividades[l_ind].ativ
              ELSE
                 LET where_clause = where_clause CLIPPED, ', ',ma_atividades[l_ind].ativ
              END IF
           END FOR
        END IF

        LET l_tipo_despesa_km = cdv0802_popup_tip_desp_versus_ativ(p_cod_empresa, where_clause)
        CURRENT WINDOW IS w_cdv20003
        IF l_tipo_despesa_km IS NOT NULL THEN
           LET ma_desp_km[l_curr].tipo_despesa_km = l_tipo_despesa_km
           DISPLAY ma_desp_km[l_curr].tipo_despesa_km TO s_desp_km[l_scr].tipo_despesa_km
        END IF

     WHEN INFIELD(tipo_despesa)
        LET where_clause = ' grp_despesa_viagem = "1"',
                           ' AND ativ = ',ma_desp_urbana[l_curr].ativ

        LET l_tipo_despesa_km = cdv0802_popup_tip_desp_versus_ativ(p_cod_empresa, where_clause)
        CURRENT WINDOW IS w_cdv20002
        IF l_tipo_despesa_km IS NOT NULL THEN
           LET ma_desp_urbana[l_curr].tipo_despesa = l_tipo_despesa_km
           DISPLAY ma_desp_urbana[l_curr].tipo_despesa TO s_desp_urbana[l_scr].tipo_despesa
        END IF

     WHEN INFIELD(tipo_despesa_hr)
        LET where_clause = ' grp_despesa_viagem = "5"',
                           ' AND ativ = ',ma_desp_km[l_curr].ativ

        LET l_tipo_despesa_km = cdv0802_popup_tip_desp_versus_ativ(p_cod_empresa, where_clause)
        CURRENT WINDOW IS w_cdv20003
        IF l_tipo_despesa_km IS NOT NULL THEN
           LET ma_desp_km[l_curr].tipo_despesa_hr = l_tipo_despesa_km
           DISPLAY ma_desp_km[l_curr].tipo_despesa_hr TO s_desp_km[l_scr].tipo_despesa_hr
        END IF

     WHEN INFIELD(motivo)
        LET l_motivo = log009_popup(07,05,                -- Linha/Coluna da Janela
                                   "MOTIVO APONTAMENTO",  -- Cabecalho da Janela
                                   "cdv_motivo_hor_781",  -- Nome da Tabela no Sistema
                                   "motivo",              -- Nome da Primeira Coluna
                                   "des_motivo",          -- Nome da Segunda  Coluna
                                   "cdv2009",             -- Nome do Prog.Manutencao
                                   "N",                   -- Testa cod_empresa (S/N) ?
                                   "")                    -- Where Clause do SELECT
        CURRENT WINDOW IS w_cdv20003
        IF l_motivo IS NOT NULL THEN
           LET ma_desp_km[l_curr].motivo = l_motivo
           DISPLAY ma_desp_km[l_curr].motivo TO s_desp_km[l_scr].motivo
        END IF

  END CASE

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_recupera_total_desp_urbanas()
#----------------------------------------------#
   DEFINE l_ind        SMALLINT,
          l_tot_tela   DECIMAL(12,2)

   LET l_tot_tela = 0

   FOR l_ind = 1 TO 200
      IF ma_desp_urbana[l_ind].val_documento IS NULL THEN
         EXIT FOR
      END IF
      LET l_tot_tela = l_tot_tela + ma_desp_urbana[l_ind].val_documento
   END FOR

   IF l_tot_tela IS NULL THEN
      LET l_tot_tela = 0
   END IF

   RETURN l_tot_tela

END FUNCTION

#------------------------------------------------------------#
 FUNCTION cdv2000_recupera_tip_desp_por_ativ(l_arr_curr)
#------------------------------------------------------------#
  DEFINE l_arr_curr    SMALLINT,
         l_tip_despesa LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_qtd_regs    SMALLINT

  INITIALIZE l_tip_despesa TO NULL

  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_regs
     FROM cdv_tdesp_viag_781
    WHERE empresa            = p_cod_empresa
      AND ativ          = ma_desp_urbana[l_arr_curr].ativ
      AND grp_despesa_viagem = 1
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0
  AND l_qtd_regs = 1 THEN
     WHENEVER ERROR CONTINUE
      SELECT tip_despesa_viagem
        INTO l_tip_despesa
        FROM cdv_tdesp_viag_781
       WHERE empresa   = p_cod_empresa
         AND ativ      = ma_desp_urbana[l_arr_curr].ativ
         AND grp_despesa_viagem = 1
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','cdv_tdesp_viag_781')
     END IF
  END IF

  RETURN l_tip_despesa

END FUNCTION

##############################
### DESPESAS QUILOMETRAGEM ###
##############################

#------------------------------------#
 FUNCTION cdv2000_manut_despesas_km()
#------------------------------------#
  DEFINE l_den_viagem    CHAR(50)

  CALL log006_exibe_teclas('01', p_versao)

  LET m_caminho = log1300_procura_caminho('cdv20003','cdv20003')
  OPEN WINDOW w_cdv20003 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  LET m_km_ativa = FALSE

  CALL cdv2000_consulta_previa()

  IF NOT cdv2000_carrega_ativs(mr_input.viagem) THEN
     CALL log0030_mensagem('Manuten��o cancelada.','exclamation')
     RETURN
  END IF

  INITIALIZE mr_desp_km.*, ma_desp_km TO NULL
  LET m_consulta_desp_km_ativa = FALSE

  MENU 'KM'
     BEFORE MENU
        IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' OR
           mr_input.des_status = 'ACERTO VIAGEM FINALIZADO' OR
           mr_input.des_status = 'ACERTO VIAGEM LIBERADO' THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
        END IF
        CALL cdv2000_carrega_km_ja_informadas(mr_input.viagem, 'AUTOMATICO')
             RETURNING p_status

        LET mr_desp_km.viagem   = mr_input.viagem
        LET mr_desp_km.controle = mr_input.controle

        LET m_consulta_desp_km_ativa = TRUE
        DISPLAY BY NAME mr_desp_km.*
        CALL cdv2000_exibe_desp_km(1)

        IF cdv2000_verifica_usuario_viajante(mr_input.viagem) THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
        END IF

     COMMAND 'Incluir' 'Inclui novas despesas de quilometragem.'
        HELP 001
        MESSAGE ''
        LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_km.viagem)
        IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
           IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'IN') THEN
              IF cdv2000_inclusao_modificacao_desp_km('INCLUSAO') THEN
                 MESSAGE 'Inclus�o efetuada com sucesso.' ATTRIBUTE(REVERSE)
                 #LET m_consulta_desp_km_ativa = FALSE
              END IF
           END IF
        ELSE
           CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
        END IF

     COMMAND 'Modificar' 'Modifica despesas de quilometragem.'
        HELP 002
        MESSAGE ''
        IF m_km_ativa THEN
           LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_km.viagem)
           IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
              IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'MO') THEN
                 IF cdv2000_inclusao_modificacao_desp_km('MODIFICACAO') THEN
                    MESSAGE 'Modifica��o efetuada com sucesso.' ATTRIBUTE(REVERSE)
                    #LET m_consulta_desp_km_ativa = FALSE
                 END IF
              END IF
           ELSE
              CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
           END IF
        ELSE
           CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
           NEXT OPTION "Consultar"
        END IF

     COMMAND 'Consultar' 'Pesquisa despesas de quilometragem.'
        HELP 004
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'CO') THEN
           CALL cdv2000_consulta_desp_km()
        END IF

     COMMAND "Seguinte"   "Exibe a pr�xima despesa encontrada na consulta."
       HELP 005
       MESSAGE ""
       IF m_consulta_desp_km_ativa = TRUE THEN
          CALL cdv2000_paginacao_desp_km("SEGUINTE")
          IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
             m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
             m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
             SHOW OPTION 'Incluir'
             SHOW OPTION 'Modificar'
          ELSE
             HIDE OPTION 'Incluir'
             HIDE OPTION 'Modificar'
          END IF
       ELSE
          CALL log0030_mensagem('N�o existe consulta ativa.','exclamation')
       END IF

     COMMAND "Anterior"   "Exibe a despesa anterior encontrado na consulta."
       HELP 006
       MESSAGE ""
       IF m_consulta_desp_km_ativa = TRUE THEN
          CALL cdv2000_paginacao_desp_km("ANTERIOR")
          IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
             m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
             m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
             SHOW OPTION 'Incluir'
             SHOW OPTION 'Modificar'
          ELSE
             HIDE OPTION 'Incluir'
             HIDE OPTION 'Modificar'
          END IF
       ELSE
          CALL log0030_mensagem('N�o existe consulta ativa.','exclamation')
       END IF

     COMMAND KEY ('!')
        PROMPT 'Digite o m_comando : ' FOR m_comando
        RUN m_comando
        PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

     COMMAND 'Fim'       'Retorna ao menu anterior.'
        HELP 008
        EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv20003
  CURRENT WINDOW IS w_cdv2000

END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2000_inclusao_modificacao_desp_km(l_funcao)
#-------------------------------------------------------#
  DEFINE l_funcao  CHAR(11)

  IF l_funcao = 'INCLUSAO' THEN
     IF NOT cdv2000_entrada_desp_km(l_funcao) THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO empresa
        ERROR "Inclus�o cancelada."
        RETURN FALSE
     END IF
  ELSE
     IF NOT cdv2000_entrada_array_desp_km(l_funcao) THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO empresa
        LET m_urbanas_ativa = FALSE
        ERROR "Modifica��o cancelada."
        RETURN FALSE
     END IF
  END IF

  CALL log085_transacao("BEGIN")

  IF cdv2000_atualiza_desp_km(l_funcao) THEN
     CALL log085_transacao("COMMIT")
     LET m_km_ativa = TRUE
     RETURN TRUE
  ELSE
     CALL log085_transacao("ROLLBACK")
     CLEAR FORM
     DISPLAY p_cod_empresa TO empresa
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_entrada_desp_km(l_funcao)
#-----------------------------------------------#
  DEFINE l_funcao       CHAR(11),
         l_status       SMALLINT

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv20003

  INITIALIZE {mr_desp_km.*,} ma_desp_km TO NULL
  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa

  WHENEVER ERROR CONTINUE
   SELECT preco_km_empresa
     INTO mr_desp_km.preco_km
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_par_ctr_viagem')
     RETURN FALSE
  END IF

  #LET mr_desp_km.viagem   = mr_input.viagem
  #LET mr_desp_km.controle = mr_input.controle

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_desp_km.* WITHOUT DEFAULTS

     BEFORE FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_desp_km.controle IS NOT NULL THEN
           IF NOT cdv2000_valida_controle_ativo(mr_desp_km.controle, mr_desp_km.viagem) THEN
              CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
              NEXT FIELD controle
           END IF
        END IF

     BEFORE FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

        IF mr_desp_km.controle IS NOT NULL
        AND ( mr_desp_km.viagem IS NULL
              OR mr_desp_km.viagem = 0  ) THEN
           LET mr_desp_km.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_km.controle)
           DISPLAY BY NAME mr_desp_km.viagem
        END IF

     AFTER FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF mr_desp_km.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_desp_km.viagem, mr_desp_km.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_desp_km.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem a qual as despesas se referem.','exclamation')
                 NEXT FIELD controle
              ELSE
                 LET mr_desp_km.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_km.controle)
                 IF mr_desp_km.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_km.viagem
                 END IF
              END IF
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_desp_km.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_ativo(mr_desp_km.controle, mr_desp_km.viagem) THEN
                 CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF
           IF mr_desp_km.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_desp_km.viagem, mr_desp_km.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_desp_km.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem a qual as despesas se referem.','exclamation')
                 NEXT FIELD controle
              ELSE
                 LET mr_desp_km.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_km.controle)
                 IF mr_desp_km.viagem IS NULL THEN
                    CALL log0030_mensagem('Informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_km.viagem
                 END IF
              END IF
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup("KM")

  END INPUT

  IF INT_FLAG THEN
     RETURN FALSE
  ELSE
     IF l_funcao <> 'CONSULTA' THEN
        RETURN cdv2000_entrada_array_desp_km(l_funcao)
     ELSE
        RETURN TRUE
     END IF
  END IF

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2000_busca_grupo(l_tip_despesa, l_ativ)
#--------------------------------------------------#
 DEFINE l_tip_despesa      LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_ativ             LIKE cdv_tdesp_viag_781.ativ,
        l_grp_desp_viagem  LIKE cdv_tdesp_viag_781.grp_despesa_viagem

 WHENEVER ERROR CONTINUE
  SELECT grp_despesa_viagem
    INTO l_grp_desp_viagem
    FROM cdv_tdesp_viag_781
   WHERE empresa            = p_cod_empresa
     AND tip_despesa_viagem = l_tip_despesa
     AND ativ               = l_ativ
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_grp_desp_viagem = NULL
 END IF

 RETURN l_grp_desp_viagem

 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION cdv2000_verifica_grupo_despesa(l_grp_despesa, l_tip_despesa, l_ativ)
#---------------------------------------------------------------------#
 DEFINE l_tip_despesa      LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_grp_desp_viagem  LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
        l_grp_despesa      LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
        l_ativ             LIKE cdv_tdesp_viag_781.ativ

 WHENEVER ERROR CONTINUE
  SELECT grp_despesa_viagem
    INTO l_grp_desp_viagem
    FROM cdv_tdesp_viag_781
   WHERE empresa            = p_cod_empresa
     AND tip_despesa_viagem = l_tip_despesa
     AND ativ               = l_ativ
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_grp_desp_viagem = NULL
 END IF

 # Fazer esta consist�ncia pois o usu�rio somente poder� informar
 # tipos de despesa que perten�am ao mesmo grupo.

 IF l_grp_desp_viagem <> l_grp_despesa THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_entrada_array_desp_km(l_funcao)
#------------------------------------------------#
  DEFINE l_funcao               CHAR(11),
         l_arr_curr             SMALLINT,
         l_scr_line             SMALLINT,
         l_status               SMALLINT,
         l_ind                  SMALLINT,
         m_total_km             DECIMAL(5,0),
         l_val_tot_km           DECIMAL(8,2),
         l_eh_obs_apont_hor     CHAR(01),
         l_hor_inicial          DATETIME HOUR TO SECOND,
         l_hor_final            DATETIME HOUR TO SECOND,
         l_hor_diurnas          DATETIME HOUR TO SECOND,
         l_cont                 SMALLINT,
         l_cont2                SMALLINT,
         l_hor_noturnas         DATETIME HOUR TO SECOND,
         l_tot_hor_diurnas      CHAR(08),
         l_tot_hor_noturnas     CHAR(08),
         l_cancela_excl         SMALLINT,
         l_new_position         SMALLINT,
         l_num_ad               LIKE ad_mestre.num_ad,
         l_ativ                 LIKE cdv_ativ_781.ativ,
         l_tip_despesa          LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_grp_despesa          LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
         l_hor_noturnas_char    CHAR(08),
         l_hor_diurnas_char     CHAR(08),
         l_hor_aux              DATETIME HOUR TO SECOND,
         l_hor_partida          CHAR(08),
         l_hor_retorno          CHAR(08)

  DEFINE l_vldar_hor_noturnas LIKE cdv_ativ_781.vldar_hor_noturnas #OS.470958

  FOR l_ind = 1 TO 200
     {IF ma_desp_km[l_ind].ativ IS NULL THEN
        EXIT FOR
     END IF}
    IF  ma_desp_km[l_ind].tipo_despesa_km IS NULL
    AND ma_desp_km[l_ind].tipo_despesa_hr IS NULL THEN
       EXIT FOR
    END IF
  END FOR

  CALL SET_COUNT(l_ind -1)

  WHILE TRUE

     CALL cdv2000_recupera_total_desp_km()
        RETURNING m_total_km, l_val_tot_km, l_tot_hor_diurnas, l_tot_hor_noturnas

     DISPLAY m_total_km   TO total_km
     DISPLAY l_val_tot_km TO val_tot_km
     DISPLAY l_tot_hor_diurnas  TO tot_hor_diurnas
     DISPLAY l_tot_hor_noturnas TO tot_hor_noturnas

     LET l_cancela_excl = FALSE

     CALL log006_exibe_teclas("01 02 07 ",p_versao)
     CURRENT WINDOW IS w_cdv20003

     LET INT_FLAG = 0
     INPUT ARRAY ma_desp_km WITHOUT DEFAULTS FROM s_desp_km.*
     --# ATTRIBUTE (INSERT ROW=FALSE)

        BEFORE ROW
           LET l_arr_curr = ARR_CURR()
           LET l_scr_line = SCR_LINE()

     BEFORE FIELD tipo_despesa_km
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF
        IF l_arr_curr > 1 THEN
           LET l_grp_despesa = cdv2000_busca_grupo(ma_desp_km[l_arr_curr-1].tipo_despesa_km, ma_desp_km[l_arr_curr-1].ativ)
        END IF

     AFTER FIELD tipo_despesa_km
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF ma_desp_km[l_arr_curr].tipo_despesa_km IS NOT NULL THEN
           IF l_arr_curr > 1 THEN
              IF NOT cdv2000_verifica_grupo_despesa(l_grp_despesa,
                                                    ma_desp_km[l_arr_curr].tipo_despesa_km,
                                                    ma_desp_km[l_arr_curr].ativ) THEN
                 CALL log0030_mensagem("N�o � permitido informar despesas de grupos diferentes (KM normal X KM semanal.","exclamation")
                 NEXT FIELD tipo_despesa_km
              END IF

              LET ma_desp_km[l_arr_curr].placa = ma_desp_km[l_arr_curr - 1].placa

           END IF
           CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_arr_curr].tipo_despesa_km, 'KM', 0, ma_desp_km[l_arr_curr].ativ)
              RETURNING l_status, ma_desp_km[l_arr_curr].des_tip_desp_km

           IF l_status THEN
              DISPLAY ma_desp_km[l_arr_curr].des_tip_desp_km
                   TO s_desp_km[l_scr_line].des_tip_desp_km
           ELSE
              NEXT FIELD tipo_despesa_km
           END IF

           IF  m_atividade_bloqueada IS NOT NULL
           AND m_atividade_bloqueada <> " " THEN
              IF m_atividade_bloqueada = ma_desp_km[l_arr_curr].ativ THEN
                 IF NOT cdv2000_valida_ativ_bloqueda(mr_desp_km.viagem, mr_desp_km.controle ,ma_desp_km[l_arr_curr].ativ, ma_desp_km[l_arr_curr].tipo_despesa_km) THEN
                    NEXT FIELD tipo_despesa_km
                 END IF
              END IF
           END IF

           IF cdv2000_verifica_td_km_digitada(mr_desp_km.viagem, ma_desp_km[l_arr_curr].tipo_despesa_km) THEN
              CALL log0030_mensagem("J� existem apontamentos de KM com tipo de despesa diferente para esta viagem.","exclamation")
              NEXT FIELD tipo_despesa_km
           END IF

        ELSE
           INITIALIZE ma_desp_km[l_arr_curr].tipo_despesa_km, ma_desp_km[l_arr_curr].des_tip_desp_km,
                      ma_desp_km[l_arr_curr].trajeto,         ma_desp_km[l_arr_curr].placa,
                      ma_desp_km[l_arr_curr].cidade_origem,   ma_desp_km[l_arr_curr].cidade_destino, #OS 520395
                      ma_desp_km[l_arr_curr].km_inicial,      ma_desp_km[l_arr_curr].km_final,
                      ma_desp_km[l_arr_curr].qtd_km,          ma_desp_km[l_arr_curr].val_km,
                      ma_desp_km[l_arr_curr].ad_km,           ma_desp_km[l_arr_curr].ap_km TO NULL

            DISPLAY ma_desp_km[l_arr_curr].tipo_despesa_km, ma_desp_km[l_arr_curr].des_tip_desp_km,
                    ma_desp_km[l_arr_curr].trajeto,         ma_desp_km[l_arr_curr].placa,
                    ma_desp_km[l_arr_curr].cidade_origem,   ma_desp_km[l_arr_curr].cidade_destino, #OS 520395
                    ma_desp_km[l_arr_curr].km_inicial,      ma_desp_km[l_arr_curr].km_final,
                    ma_desp_km[l_arr_curr].qtd_km,          ma_desp_km[l_arr_curr].val_km,
                    ma_desp_km[l_arr_curr].ad_km,           ma_desp_km[l_arr_curr].ap_km TO

                    s_desp_km[l_scr_line].tipo_despesa_km, s_desp_km[l_scr_line].des_tip_desp_km,
                    s_desp_km[l_scr_line].trajeto,         s_desp_km[l_scr_line].placa,
                    s_desp_km[l_scr_line].cidade_origem,   s_desp_km[l_scr_line].cidade_destino, #OS 520395
                    s_desp_km[l_scr_line].km_inicial,      s_desp_km[l_scr_line].km_final,
                    s_desp_km[l_scr_line].qtd_km,          s_desp_km[l_scr_line].val_km,
                    s_desp_km[l_scr_line].ad_km,           s_desp_km[l_scr_line].ap_km
           NEXT FIELD tipo_despesa_hr
        END IF

        BEFORE FIELD ativ
           --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           IF NOT g_ies_grafico THEN
               DISPLAY '( Zoom )' AT 3,68
           END IF

           INITIALIZE l_ativ TO NULL
           IF ma_desp_km[l_arr_curr].ad_km IS NOT NULL THEN
              IF cdv0803_verifica_ad_tot_aprovada(ma_desp_km[l_arr_curr].ad_km) THEN
                 CALL log0030_mensagem('Despesa n�o pode ser modificada, AD totalmente aprovada.','info')
                 LET l_ativ = ma_desp_km[l_arr_curr].ativ
              END IF
           END IF
           CALL log006_exibe_teclas("01", p_versao)
           CURRENT WINDOW IS w_cdv20003

#OS 520395
           IF NOT cdv2000_busca_des_cidade_origem(ma_desp_km[l_arr_curr].cidade_origem) THEN
              NEXT FIELD cidade_origem
           END IF
           DISPLAY m_des_cidade_origem TO s_desp_km[l_scr_line].des_cidade_origem

           IF NOT cdv2000_busca_des_cidade_destino(ma_desp_km[l_arr_curr].cidade_destino) THEN
              NEXT FIELD cidade_destino
           END IF
           DISPLAY m_des_cidade_destino TO s_desp_km[l_scr_line].des_cidade_destino
#---------

        AFTER FIELD ativ
           --# CALL fgl_dialog_setkeylabel('control-z', '')
           IF NOT g_ies_grafico THEN
               DISPLAY '--------' AT 3,68
           END IF

           IF FGL_LASTKEY() = FGL_KEYVAL("UP") OR
              FGL_LASTKEY() = FGL_KEYVAL("LEFT") OR
              FGL_LASTKEY() = FGL_KEYVAL("ACCEPT") THEN
              IF ma_desp_km[l_arr_curr].trajeto IS NULL THEN
                 #INITIALIZE ma_desp_km[l_arr_curr].* TO NULL
                 INITIALIZE ma_desp_km[l_arr_curr].tipo_despesa_km, ma_desp_km[l_arr_curr].des_tip_desp_km,
                            ma_desp_km[l_arr_curr].trajeto,         ma_desp_km[l_arr_curr].placa,
                            ma_desp_km[l_arr_curr].cidade_origem,   ma_desp_km[l_arr_curr].cidade_destino, #OS 520395
                            ma_desp_km[l_arr_curr].km_inicial,      ma_desp_km[l_arr_curr].km_final,
                            ma_desp_km[l_arr_curr].qtd_km,          ma_desp_km[l_arr_curr].val_km,
                            ma_desp_km[l_arr_curr].ad_km,           ma_desp_km[l_arr_curr].ap_km TO NULL
              END IF
           ELSE
              IF l_ativ IS NOT NULL THEN
                 IF l_ativ <> ma_desp_km[l_arr_curr].ativ THEN
                    LET ma_desp_km[l_arr_curr].ativ = l_ativ
                    NEXT FIELD ativ
                 END IF
                 IF FGL_LASTKEY() = FGL_KEYVAL("RIGHT") THEN
                    NEXT FIELD ativ
                 END IF
              ELSE
                 IF ma_desp_km[l_arr_curr].ativ IS NOT NULL THEN
                    CALL cdv2000_valida_ativ(ma_desp_km[l_arr_curr].ativ)
                       RETURNING l_status, ma_desp_km[l_arr_curr].des_ativ
                    IF l_status THEN
                       DISPLAY ma_desp_km[l_arr_curr].des_ativ TO s_desp_km[l_scr_line].des_ativ
                    ELSE
                       NEXT FIELD ativ
                    END IF

                 ELSE
                    CALL log0030_mensagem('Informe a atividade relacionada � despesa.','exclamation')
                    NEXT FIELD ativ
                 END IF
              END IF
           END IF

        AFTER FIELD trajeto
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN
              IF ma_desp_km[l_arr_curr].trajeto IS NULL THEN
                 CALL log0030_mensagem('Informe trajeto que gerou a despesa.','exclamation')
                 NEXT FIELD trajeto
              END IF
           END IF

        BEFORE FIELD placa
           IF l_arr_curr = 1 THEN
              IF ma_desp_km[l_arr_curr].placa IS NULL THEN
                 LET ma_desp_km[l_arr_curr].placa = cdv2000_busca_placa(mr_desp_km.viagem)
                 DISPLAY ma_desp_km[l_arr_curr].placa TO s_desp_km[l_scr_line].placa
              END IF
           END IF

        AFTER FIELD placa
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].placa IS NULL THEN
                 CALL log0030_mensagem('Informe a placa do ve�culo utilizado.','exclamation')
                 NEXT FIELD placa
              END IF

              FOR l_cont = 1 TO 100
                 IF ma_desp_km[l_cont].tipo_despesa_km IS NULL THEN
                    CONTINUE FOR
                 ELSE
                    FOR l_cont2 = 1 TO 100
                       IF ma_desp_km[l_cont2].placa IS NULL THEN
                          CONTINUE FOR
                       ELSE
                          IF ma_desp_km[l_cont2].placa <> ma_desp_km[l_cont].placa THEN
                             CALL log0030_mensagem("Existem apontamentos de KM com n�meros de placas diferentes.","exclamation")
                             NEXT FIELD placa
                          END IF
                       END IF
                    END FOR
                 END IF

              END FOR
           END IF
           IF cdv2000_verifica_placa(mr_desp_km.viagem, ma_desp_km[l_arr_curr].placa) THEN
              CALL log0030_mensagem("J� existem apontamentos de km com placa diferente para esta viagem.","exclamation")
              NEXT FIELD placa
           END IF

#OS 520395
        BEFORE FIELD cidade_origem
           --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           IF NOT g_ies_grafico THEN
               DISPLAY '( Zoom )' AT 3,68
           END IF

        AFTER FIELD cidade_origem
           --# CALL fgl_dialog_setkeylabel('control-z', '')
           IF NOT g_ies_grafico THEN
               DISPLAY '--------' AT 3,68
           END IF

           IF ma_desp_km[l_arr_curr].cidade_origem IS NULL THEN
              CALL log0030_mensagem("Cidade origem n�o informada.","exclamation")
              NEXT FIELD cidade_origem
           END IF

#OS 520395
            IF NOT cdv2000_busca_des_cidade_origem(ma_desp_km[l_arr_curr].cidade_origem) THEN
               NEXT FIELD cidade_origem
            END IF
            DISPLAY m_des_cidade_origem TO s_desp_km[l_scr_line].des_cidade_origem


        BEFORE FIELD cidade_destino
           --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           IF NOT g_ies_grafico THEN
               DISPLAY '( Zoom )' AT 3,68
           END IF

        AFTER FIELD cidade_destino
           --# CALL fgl_dialog_setkeylabel('control-z', '')
           IF NOT g_ies_grafico THEN
               DISPLAY '--------' AT 3,68
           END IF

           IF ma_desp_km[l_arr_curr].cidade_destino IS NULL THEN
              CALL log0030_mensagem("Cidade destino n�o informada.","exclamation")
              NEXT FIELD cidade_destino
           END IF

           IF NOT cdv2000_busca_des_cidade_destino(ma_desp_km[l_arr_curr].cidade_destino) THEN
              NEXT FIELD cidade_destino
           END IF
           DISPLAY m_des_cidade_destino TO s_desp_km[l_scr_line].des_cidade_destino
#---------

        BEFORE FIELD km_inicial
           IF l_arr_curr > 1 THEN
              IF ma_desp_km[l_arr_curr - 1].tipo_despesa_km IS NOT NULL THEN
                 IF ma_desp_km[l_arr_curr].km_inicial IS NULL
                 OR ma_desp_km[l_arr_curr].km_inicial = ' ' THEN
                    LET ma_desp_km[l_arr_curr].km_inicial = ma_desp_km[l_arr_curr - 1].km_final
                    DISPLAY ma_desp_km[l_arr_curr].km_inicial TO s_desp_km[l_scr_line].km_inicial
                 END IF
              END IF
           ELSE
              IF ma_desp_km[l_arr_curr].km_inicial IS NULL
              OR ma_desp_km[l_arr_curr].km_inicial = ' ' THEN
                 LET ma_desp_km[l_arr_curr].km_inicial = cdv2000_busca_km_inicial(mr_desp_km.viagem)
                 DISPLAY ma_desp_km[l_arr_curr].km_inicial TO s_desp_km[l_scr_line].km_inicial
              END IF
           END IF

        AFTER FIELD km_inicial
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].km_inicial IS NULL THEN
                 CALL log0030_mensagem('Informe a quilometragem inicial.','exclamation')
                 NEXT FIELD km_inicial
              END IF

              IF l_arr_curr > 1 THEN
                 IF ma_desp_km[l_arr_curr - 1].km_final > ma_desp_km[l_arr_curr].km_inicial THEN
                    CALL log0030_mensagem("KM inicial maior que KM final digitado anteriormente.","exclamation")
                    NEXT FIELD km_inicial
                 END IF
              END IF

           END IF

           IF l_funcao = "INCLUSAO" THEN
              IF cdv2000_valida_km_inicial(mr_desp_km.viagem, ma_desp_km[l_arr_curr].km_inicial) THEN
                 CALL log0030_mensagem("J� existem apontamentos de KM com KMF maior para esta viagem.","exclamation")
                 NEXT FIELD km_inicial
              END IF
           END IF

        AFTER FIELD km_final
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].km_final IS NULL THEN
                 CALL log0030_mensagem('Informe a quilometragem final.','exclamation')
                 NEXT FIELD km_final
              ELSE
                 IF ma_desp_km[l_arr_curr].km_final <= ma_desp_km[l_arr_curr].km_inicial THEN
                    CALL log0030_mensagem('Quilometragem final n�o pode ser menor/igual quilometragem inicial.','exclamation')
                    NEXT FIELD km_final
                 END IF
                 LET ma_desp_km[l_arr_curr].qtd_km = ma_desp_km[l_arr_curr].km_final - ma_desp_km[l_arr_curr].km_inicial
                 DISPLAY ma_desp_km[l_arr_curr].qtd_km TO s_desp_km[l_scr_line].qtd_km

                 IF cdv2000_valoriza_km(ma_desp_km[l_arr_curr].tipo_despesa_km, ma_desp_km[l_arr_curr].ativ) THEN
                    LET ma_desp_km[l_arr_curr].val_km = ma_desp_km[l_arr_curr].qtd_km * mr_desp_km.preco_km
                 END IF
                 IF ma_desp_km[l_arr_curr].val_km IS NULL THEN
                    LET ma_desp_km[l_arr_curr].val_km = 0
                 END IF
                 DISPLAY ma_desp_km[l_arr_curr].val_km TO s_desp_km[l_scr_line].val_km
              END IF
           END IF

        ############################
        ### APONTAMENTO DE HORAS ###
        ############################

        BEFORE FIELD tipo_despesa_hr
           IF l_arr_curr > 1 THEN
              IF ma_desp_km[1].tipo_despesa_hr IS NOT NULL THEN
                 LET ma_desp_km[l_arr_curr].tipo_despesa_hr = ma_desp_km[1].tipo_despesa_hr
                 DISPLAY ma_desp_km[l_arr_curr].tipo_despesa_hr TO s_desp_km[l_scr_line].tipo_despesa_hr
              END IF
           END IF

        AFTER FIELD tipo_despesa_hr
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].tipo_despesa_hr IS NOT NULL THEN
                 CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_arr_curr].tipo_despesa_hr, 'APONT', l_arr_curr, ma_desp_km[l_arr_curr].ativ)
                    RETURNING l_status, ma_desp_km[l_arr_curr].des_tip_desp_hr
                 IF l_status THEN
                    DISPLAY ma_desp_km[l_arr_curr].des_tip_desp_hr TO s_desp_km[l_scr_line].des_tip_desp_hr
                 ELSE
                    NEXT FIELD tipo_despesa_hr
                 END IF

                 IF  m_atividade_bloqueada IS NOT NULL
                 AND m_atividade_bloqueada <> " " THEN
                    IF m_atividade_bloqueada = ma_desp_km[l_arr_curr].ativ
                    AND (ma_desp_km[l_arr_curr].tipo_despesa_km IS NULL
                      OR ma_desp_km[l_arr_curr].tipo_despesa_km = " ") THEN

                       CALL log0030_mensagem("Atividade n�o permite apontamento de horas para despesa de KM n�o informada.","exclamation")
                       NEXT FIELD tipo_despesa_km

                       #IF NOT cdv2000_valida_ativ_bloqueda(mr_desp_km.viagem, mr_desp_km.controle, ma_desp_km[l_arr_curr].ativ, ma_desp_km[l_arr_curr].tipo_despesa_hr) THEN
                       #   NEXT FIELD tipo_despesa_hr
                       #END IF
                    END IF
                 END IF

                 IF cdv2000_verifica_td_hr_digitada(mr_desp_km.viagem, ma_desp_km[l_arr_curr].tipo_despesa_hr) THEN
                    CALL log0030_mensagem("J� existem apontamentos de HR com tipo de despesa diferente para esta viagem.","exclamation")
                    NEXT FIELD tipo_despesa_hr
                 END IF

              ELSE
                 IF ma_desp_km[l_arr_curr].tipo_despesa_km IS NULL THEN
                    CALL log0030_mensagem('Nenhum tipo de despesa informado.','exclamation')
                    NEXT FIELD tipo_despesa_km
                 END IF

                 INITIALIZE ma_desp_km[l_arr_curr].tipo_despesa_hr,  ma_desp_km[l_arr_curr].des_tip_desp_hr,
                            ma_desp_km[l_arr_curr].hor_inicial,      ma_desp_km[l_arr_curr].hor_final,
                            ma_desp_km[l_arr_curr].motivo,           ma_desp_km[l_arr_curr].des_motivo,
                            ma_desp_km[l_arr_curr].hor_diurnas,      ma_desp_km[l_arr_curr].hor_noturnas TO NULL

                 DISPLAY ma_desp_km[l_arr_curr].tipo_despesa_hr,  ma_desp_km[l_arr_curr].des_tip_desp_hr,
                         ma_desp_km[l_arr_curr].hor_inicial,      ma_desp_km[l_arr_curr].hor_final,
                         ma_desp_km[l_arr_curr].motivo,           ma_desp_km[l_arr_curr].des_motivo,
                         ma_desp_km[l_arr_curr].hor_diurnas,      ma_desp_km[l_arr_curr].hor_noturnas TO
                         s_desp_km[l_scr_line].tipo_despesa_hr,   s_desp_km[l_scr_line].des_tip_desp_hr,
                         s_desp_km[l_scr_line].hor_inicial,       s_desp_km[l_scr_line].hor_final,
                         s_desp_km[l_scr_line].motivo,            s_desp_km[l_scr_line].des_motivo,
                         s_desp_km[l_scr_line].hor_diurnas,       s_desp_km[l_scr_line].hor_noturnas

                 NEXT FIELD dat_apont_hor
              END IF
           END IF
           IF (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
              fgl_lastkey() = FGL_KEYVAL("LEFT"))
              AND ma_desp_km[l_arr_curr].tipo_despesa_km IS NULL THEN
                 NEXT FIELD tipo_despesa_km
              END IF

        AFTER FIELD hor_inicial
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].hor_inicial IS NULL THEN
                 CALL log0030_mensagem('Informe a hora inicial do apontamento.','exclamation')
                 NEXT FIELD hor_inicial
              ELSE
                #IF ma_desp_km[l_arr_curr].hor_inicial > '23:59:59' THEN
                #OS459347
                 IF ma_desp_km[l_arr_curr].hor_inicial > '24:00:00' THEN
                   #CALL log0030_mensagem('Hora inicial n�o pode ser maior que 23:59:59.','exclamation')
                   #OS459347
                    CALL log0030_mensagem('Hora inicial n�o pode ser maior que 24:00:00.','exclamation')
                    NEXT FIELD hor_inicial
                 END IF

                 #CALL cdv2000_busca_hora(mr_desp_km.viagem)
                 #     RETURNING l_hor_partida,
                 #               l_hor_retorno
                 #
                 #IF ma_desp_km[l_arr_curr].hor_inicial < l_hor_partida
                 #OR ma_desp_km[l_arr_curr].hor_inicial > l_hor_retorno THEN
                 #   CALL log0030_mensagem("Hora inicial n�o est� no intervalo de partida e retorno da viagem.","exclamation")
                 #   NEXT FIELD hor_inicial
                 #END IF

              END IF
           END IF

        AFTER FIELD hor_final
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].hor_final IS NULL THEN
                 CALL log0030_mensagem('Informe a hora final do apontamento.','exclamation')
                 NEXT FIELD hor_final
              ELSE
                #IF ma_desp_km[l_arr_curr].hor_final > '23:59:59' THEN
                #OS459347

                #Altera��o LUIZ MIRANDA para n�o aceitar a digita��o de 24:00:00, pois j� considera outra data.
                 IF ma_desp_km[l_arr_curr].hor_final = '24:00:00' THEN
                    let ma_desp_km[l_arr_curr].hor_final = '23:59:59'
                 END IF
                 IF ma_desp_km[l_arr_curr].hor_final > '24:00:00' THEN
                   #CALL log0030_mensagem('Hora final n�o pode ser maior que 23:59:59.','exclamation')
                   #OS459347
                    CALL log0030_mensagem('Hora final n�o pode ser maior que 24:00:00.','exclamation')
                    NEXT FIELD hor_final
                 END IF
                 IF ma_desp_km[l_arr_curr].hor_final <= ma_desp_km[l_arr_curr].hor_inicial THEN
                    CALL log0030_mensagem('Hora final n�o pode ser menor/igual hora inicial.','exclamation')
                    NEXT FIELD hor_final
                 END IF
              END IF

              #CALL cdv2000_busca_hora(mr_desp_km.viagem)
              #     RETURNING l_hor_partida,
              #               l_hor_retorno
              #
              #IF ma_desp_km[l_arr_curr].hor_final < l_hor_partida
              #OR ma_desp_km[l_arr_curr].hor_final > l_hor_retorno THEN
              #   CALL log0030_mensagem("Hora final n�o est� no intervalo de partida e retorno da viagem.","exclamation")
              #   NEXT FIELD hor_inicial
              #END IF

              LET l_hor_inicial = ma_desp_km[l_arr_curr].hor_inicial
              LET l_hor_final   = ma_desp_km[l_arr_curr].hor_final

              IF ma_desp_km[l_arr_curr].hor_final = '24:00:00' THEN
                 LET l_hor_final = '23:59:59'
              END IF

              LET l_hor_diurnas       = '00:00:00'
              LET l_hor_noturnas      = '00:00:00'
              LET l_hor_noturnas_char = '00:00:00'
              LET l_hor_diurnas_char  = '00:00:00'
              LET l_hor_aux           = '00:00:01'

              LET l_hor_diurnas  = cdv2000_calcula_hr_diurnas(l_hor_inicial, l_hor_final)
              LET l_hor_noturnas = cdv2000_calcula_hr_noturnas(l_hor_inicial, l_hor_final)

              LET l_hor_noturnas_char = l_hor_noturnas
              IF l_hor_noturnas_char[7,8] = '59' THEN
                 LET l_hor_noturnas_char = l_hor_noturnas_char + (l_hor_aux - '00:00:00')
              END IF

              LET ma_desp_km[l_arr_curr].hor_diurnas  = l_hor_diurnas
              LET ma_desp_km[l_arr_curr].hor_noturnas = l_hor_noturnas

              IF NOT cdv2000_valida_horas_not(ma_desp_km[l_arr_curr].ativ) THEN
                 LET l_hor_diurnas = "00:00:00"
                 LET l_hor_diurnas = l_hor_diurnas + (l_hor_final - l_hor_inicial)

                 LET l_hor_diurnas_char = l_hor_diurnas
                 IF l_hor_diurnas_char[7,8] = '59' THEN
                    LET l_hor_diurnas = l_hor_diurnas + (l_hor_aux - '00:00:00')
                 END IF

                 LET ma_desp_km[l_arr_curr].hor_diurnas  = l_hor_diurnas
                 LET ma_desp_km[l_arr_curr].hor_noturnas = "00:00:00"
              END IF

              DISPLAY ma_desp_km[l_arr_curr].hor_diurnas  TO s_desp_km[l_scr_line].hor_diurnas
              DISPLAY ma_desp_km[l_arr_curr].hor_noturnas TO s_desp_km[l_scr_line].hor_noturnas
           END IF

        AFTER FIELD motivo
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].motivo IS NOT NULL THEN
                 CALL cdv2000_valida_morivo_apont(ma_desp_km[l_arr_curr].motivo)
                    RETURNING l_status, ma_desp_km[l_arr_curr].des_motivo, l_eh_obs_apont_hor
                 IF l_status THEN
                    DISPLAY ma_desp_km[l_arr_curr].des_motivo TO s_desp_km[l_scr_line].des_motivo
                 ELSE
                    NEXT FIELD motivo
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o motivo do apontamento.','exclamation')
                 NEXT FIELD motivo
              END IF
           END IF

        BEFORE FIELD dat_apont_hor
			        IF l_funcao = "INCLUSAO"
			        OR ma_desp_km[l_arr_curr].dat_apont_hor IS NULL THEN
			           #IF mr_input.dat_retorno = mr_input.dat_partida THEN
			           LET ma_desp_km[l_arr_curr].dat_apont_hor = cdv2000_busca_data_viagem(mr_desp_km.viagem) #mr_input.dat_retorno
			           DISPLAY ma_desp_km[l_arr_curr].dat_apont_hor TO s_desp_km[l_scr_line].dat_apont_hor
			        END IF

        AFTER FIELD dat_apont_hor
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              IF ma_desp_km[l_arr_curr].dat_apont_hor IS NOT NULL THEN
                 IF NOT cdv2000_verifica_data_viagem(mr_desp_km.viagem,
                                                     ma_desp_km[l_arr_curr].dat_apont_hor) THEN
                    CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                    NEXT FIELD dat_apont_hor
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe a data do apontamento/despesa.','exclamation')
                 NEXT FIELD dat_apont_hor
              END IF

              CALL cdv2000_busca_hora(mr_desp_km.viagem)
                   RETURNING l_hor_partida,
                             l_hor_retorno



              IF ma_desp_km[l_arr_curr].dat_apont_hor = m_data_p THEN
                 IF ma_desp_km[l_arr_curr].hor_inicial < l_hor_partida THEN
                    CALL log0030_mensagem("Hora inicial n�o est� no intervalo de partida e retorno da viagem.","exclamation")
                    NEXT FIELD hor_inicial
                 END IF
              END IF

              IF ma_desp_km[l_arr_curr].dat_apont_hor = m_data_r THEN
                 IF ma_desp_km[l_arr_curr].hor_final > l_hor_retorno THEN
                    CALL log0030_mensagem("Hora final n�o est� no intervalo de partida e retorno da viagem.","exclamation")
                    NEXT FIELD hor_inicial
                 END IF
              END IF

              FOR l_ind = 1 TO 200

                 IF  ma_desp_km[l_ind].tipo_despesa_km IS NULL
                 AND ma_desp_km[l_ind].tipo_despesa_hr IS NULL THEN
                    EXIT FOR
                 END IF
                 IF l_ind = l_arr_curr THEN
                    CONTINUE FOR
                 END IF
                 IF ma_desp_km[l_ind].dat_apont_hor = ma_desp_km[l_arr_curr].dat_apont_hor THEN
                    IF (ma_desp_km[l_ind].hor_inicial < ma_desp_km[l_arr_curr].hor_inicial AND
                        ma_desp_km[l_ind].hor_final > ma_desp_km[l_arr_curr].hor_inicial) OR
                       (ma_desp_km[l_ind].hor_inicial < ma_desp_km[l_arr_curr].hor_final AND
                        ma_desp_km[l_ind].hor_final > ma_desp_km[l_arr_curr].hor_final) OR
                       (ma_desp_km[l_ind].hor_inicial < ma_desp_km[l_arr_curr].hor_final AND
                        ma_desp_km[l_ind].hor_final > ma_desp_km[l_arr_curr].hor_inicial) OR
                       (ma_desp_km[l_ind].hor_final < ma_desp_km[l_arr_curr].hor_final AND
                        ma_desp_km[l_ind].hor_final > ma_desp_km[l_arr_curr].hor_inicial) THEN
                       CALL log0030_mensagem('Per�odo j� informado.','exclamation')
                       NEXT FIELD hor_inicial
                    END IF
                 END IF
              END FOR
           END IF
           IF (FGL_LASTKEY() = FGL_KEYVAL("UP")
           OR fgl_lastkey() = FGL_KEYVAL("LEFT"))
           AND ma_desp_km[l_arr_curr].tipo_despesa_hr IS NULL THEN
              NEXT FIELD tipo_despesa_hr
           END IF

        AFTER FIELD obs_apont_hor
           IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                   FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

              CALL cdv2000_recupera_total_desp_km()
                 RETURNING m_total_km, l_val_tot_km, l_tot_hor_diurnas, l_tot_hor_noturnas

              DISPLAY m_total_km   TO total_km
              DISPLAY l_val_tot_km TO val_tot_km
              DISPLAY l_tot_hor_diurnas  TO tot_hor_diurnas
              DISPLAY l_tot_hor_noturnas TO tot_hor_noturnas

              IF ma_desp_km[l_arr_curr].motivo IS NOT NULL THEN
                 CALL cdv2000_valida_morivo_apont(ma_desp_km[l_arr_curr].motivo)
                    RETURNING l_status, ma_desp_km[l_arr_curr].des_motivo, l_eh_obs_apont_hor

                 IF l_eh_obs_apont_hor = 'S' THEN
                    IF ma_desp_km[l_arr_curr].obs_apont_hor IS NULL THEN
                       CALL log0030_mensagem('Motivo apontamento obriga que se informe observa��o.','exclamation')
                       NEXT FIELD obs_apont_hor
                    END IF
                 END IF
              END IF
           END IF

        BEFORE DELETE
           INITIALIZE l_num_ad TO NULL
           IF ma_desp_km[l_arr_curr].ad_km IS NOT NULL THEN
              IF cdv0803_verifica_ad_tot_aprovada(ma_desp_km[l_arr_curr].ad_km) THEN
                 CALL log0030_mensagem('Despesa n�o pode ser exclu�da, AD relacionada totalmente aprovada.','exclamation')
                 LET l_cancela_excl = TRUE
                 EXIT INPUT
              ELSE
                 CALL log006_exibe_teclas("01", p_versao)
                 CURRENT WINDOW IS w_cdv20003

                 IF cdv2000_ad_relac_varias_despesas(l_arr_curr) THEN
                    IF cdv2000_confirma_exclusao_despesas() = 'N' THEN
                       LET l_cancela_excl = TRUE
                       EXIT INPUT
                    ELSE
                       LET l_num_ad = ma_desp_km[l_arr_curr].ad_km
                       IF NOT cdv2000_exclui_despesa_no_cap(ma_desp_km[l_arr_curr].ad_km, ma_desp_km[l_arr_curr].ap_km) THEN
                          LET l_cancela_excl = TRUE
                          EXIT INPUT
                       END IF
                    END IF
                 ELSE
                    IF NOT cdv2000_exclui_despesa_no_cap(ma_desp_km[l_arr_curr].ad_km, ma_desp_km[l_arr_curr].ap_km) THEN
                       LET l_cancela_excl = TRUE
                       EXIT INPUT
                    END IF
                 END IF
              END IF
           END IF

        AFTER DELETE
           IF l_num_ad IS NOT NULL THEN
              FOR l_ind = 1 TO 200
                 IF (ma_desp_km[l_ind].ad_km = l_num_ad) AND
                     ma_desp_km[l_ind].ad_km IS NOT NULL THEN
                    INITIALIZE ma_desp_km[l_ind].* TO NULL
                 END IF
              END FOR

              ## reorganiza array ##
              LET l_new_position = 1
              FOR l_ind = 1 TO 200
                 IF ma_desp_km[l_ind].ativ IS NOT NULL THEN
                    LET ma_desp_km[l_new_position].* = ma_desp_km[l_ind].*
                    LET l_new_position = l_new_position + 1
                 END IF
              END FOR

              FOR l_ind = l_new_position TO 200
                 INITIALIZE ma_desp_km[l_ind].* TO NULL
              END FOR

              CALL SET_COUNT(l_new_position - 1)
              EXIT INPUT
              ## fim reorganiza array ##
           END IF

           CALL cdv2000_recupera_total_desp_km()
              RETURNING m_total_km, l_val_tot_km, l_tot_hor_diurnas, l_tot_hor_noturnas

           DISPLAY m_total_km   TO total_km
           DISPLAY l_val_tot_km TO val_tot_km
           DISPLAY l_tot_hor_diurnas  TO tot_hor_diurnas
           DISPLAY l_tot_hor_noturnas TO tot_hor_noturnas

        AFTER INPUT
           IF NOT INT_FLAG THEN
#OS 520395
              CALL cdv2000_busca_des_cidade_origem(ma_desp_km[l_arr_curr].cidade_origem)
                   RETURNING l_status
              DISPLAY m_des_cidade_origem TO s_desp_km[l_scr_line].des_cidade_origem

              CALL cdv2000_busca_des_cidade_destino(ma_desp_km[l_arr_curr].cidade_destino)
                   RETURNING l_status
              DISPLAY m_des_cidade_destino TO s_desp_km[l_scr_line].des_cidade_destino
#---------
              IF ma_desp_km[l_arr_curr].motivo IS NOT NULL THEN
                 CALL cdv2000_valida_morivo_apont(ma_desp_km[l_arr_curr].motivo)
                    RETURNING l_status, ma_desp_km[l_arr_curr].des_motivo, l_eh_obs_apont_hor

                 IF l_eh_obs_apont_hor = 'S' THEN
                    IF ma_desp_km[l_arr_curr].obs_apont_hor IS NULL THEN
                       CALL log0030_mensagem('Motivo apontamento obriga que se informe observa��o.','exclamation')
                       NEXT FIELD obs_apont_hor
                    END IF
                 END IF
              END IF

              IF ma_desp_km[l_arr_curr].tipo_despesa_km IS NOT NULL THEN
                 IF l_arr_curr > 1 THEN
                    IF NOT cdv2000_verifica_grupo_despesa(l_grp_despesa,
                                                          ma_desp_km[l_arr_curr].tipo_despesa_km,
                                                          ma_desp_km[l_arr_curr].ativ) THEN
                       CALL log0030_mensagem("N�o � permitido informar despesas de grupos diferentes (KM normal X KM semanal.","exclamation")
                       NEXT FIELD tipo_despesa_km
                    END IF
                 END IF
                 CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_arr_curr].tipo_despesa_km, 'KM', 0, ma_desp_km[l_arr_curr].ativ)
                    RETURNING l_status, ma_desp_km[l_arr_curr].des_tip_desp_km

                 IF l_status THEN
                    DISPLAY ma_desp_km[l_arr_curr].des_tip_desp_km
                         TO s_desp_km[l_scr_line].des_tip_desp_km
                 ELSE
                    NEXT FIELD tipo_despesa_km
                 END IF
              END IF

              FOR l_cont = 1 TO 100
                 IF ma_desp_km[l_cont].tipo_despesa_km IS NULL THEN
                    CONTINUE FOR
                 ELSE
                    FOR l_cont2 = 1 TO 100
                       IF ma_desp_km[l_cont2].placa IS NULL THEN
                          CONTINUE FOR
                       ELSE
                          IF ma_desp_km[l_cont2].placa <> ma_desp_km[l_cont].placa THEN
                             CALL log0030_mensagem("Existem apontamentos de KM com n�meros de placas diferentes.","exclamation")
                             NEXT FIELD placa
                          END IF
                       END IF
                    END FOR
                 END IF
              END FOR

              IF NOT log0040_confirm(19,34,"Confirma dados informados?") THEN
                 NEXT FIELD tipo_despesa_km
              END IF
           END IF
           IF NOT l_cancela_excl THEN
              EXIT WHILE
           END IF

        ON KEY (control-w, f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE INPUT
           #lds END IF
           CALL cdv2000_help()
        ON KEY (control-z, f4)
           CALL cdv2000_popup_array(l_arr_curr, l_scr_line, 'KM')

     END INPUT
  END WHILE

  RETURN NOT INT_FLAG

END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2000_atualiza_desp_km(l_funcao)
#-------------------------------------------#
  DEFINE l_funcao       CHAR(11),
         l_max_seq_km   SMALLINT,
         l_max_seq_hr   SMALLINT,
         l_ind          SMALLINT

  IF l_funcao = 'INCLUSAO' THEN
     WHENEVER ERROR CONTINUE
      SELECT MAX(seq_despesa_km)
        INTO l_max_seq_km
        FROM cdv_despesa_km_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_km.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT-MAX','cdv_despesa_km_781')
        RETURN FALSE
     END IF
     IF l_max_seq_km IS NULL OR l_max_seq_km = 0 THEN
        LET l_max_seq_km = 1
     ELSE
        LET l_max_seq_km = l_max_seq_km + 1
     END IF

     WHENEVER ERROR CONTINUE
      SELECT MAX(seq_apont_hor)
        INTO l_max_seq_hr
        FROM cdv_apont_hor_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_km.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT-MAX','cdv_apont_hor_781')
        RETURN FALSE
     END IF
     IF l_max_seq_hr IS NULL OR l_max_seq_hr = 0 THEN
        LET l_max_seq_hr = 1
     ELSE
        LET l_max_seq_hr = l_max_seq_hr + 1
     END IF

  ELSE
     LET l_max_seq_km = 1
     LET l_max_seq_hr = 1
  END IF

  IF l_funcao = 'MODIFICACAO' THEN
     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_despesa_km_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_km.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('DELETE','cdv_despesa_km_781')
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      DELETE FROM cdv_apont_hor_781
       WHERE empresa = p_cod_empresa
         AND viagem  = mr_desp_km.viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('DELETE','cdv_apont_hor_781')
        RETURN FALSE
     END IF
  END IF

  FOR l_ind = 1 TO 200
     IF ma_desp_km[l_ind].tipo_despesa_km IS NOT NULL THEN
        WHENEVER ERROR CONTINUE
         INSERT INTO cdv_despesa_km_781 (empresa,
                                         viagem,
                                         tip_despesa_viagem,
                                         seq_despesa_km,
                                         ativ_km,
                                         trajeto,
                                         cidade_origem, #OS 520395
                                         cidade_destino, #OS 520395
                                         placa,
                                         km_inicial,
                                         km_final,
                                         qtd_km,
                                         val_km,
                                         apropr_desp_km,
                                         dat_despesa_km,
                                         obs_despesa_km)
                                 VALUES (p_cod_empresa,
                                         mr_desp_km.viagem,
                                         ma_desp_km[l_ind].tipo_despesa_km,
                                         l_max_seq_km,
                                         ma_desp_km[l_ind].ativ,
                                         ma_desp_km[l_ind].trajeto,
                                         ma_desp_km[l_ind].cidade_origem, #OS 520395
                                         ma_desp_km[l_ind].cidade_destino, #OS 520395
                                         ma_desp_km[l_ind].placa,
                                         ma_desp_km[l_ind].km_inicial,
                                         ma_desp_km[l_ind].km_final,
                                         ma_desp_km[l_ind].qtd_km,
                                         ma_desp_km[l_ind].val_km,
                                         NULL,
                                         ma_desp_km[l_ind].dat_apont_hor,
                                         ma_desp_km[l_ind].obs_apont_hor)

        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('INSERT','cdv_despesa_km_781')
           RETURN FALSE
        END IF
     END IF

     IF ma_desp_km[l_ind].tipo_despesa_hr IS NOT NULL THEN
        WHENEVER ERROR CONTINUE
         INSERT INTO cdv_apont_hor_781 (empresa,
                                        viagem,
                                        seq_apont_hor,
                                        tdesp_apont_hor,
                                        hor_inicial,
                                        hor_final,
                                        motivo,
                                        hor_diurnas,
                                        hor_noturnas,
                                        dat_apont_hor,
                                        obs_apont_hor,
                                        ativ)
                                VALUES (p_cod_empresa,
                                        mr_desp_km.viagem,
                                        l_max_seq_hr,
                                        ma_desp_km[l_ind].tipo_despesa_hr,
                                        ma_desp_km[l_ind].hor_inicial,
                                        ma_desp_km[l_ind].hor_final,
                                        ma_desp_km[l_ind].motivo,
                                        ma_desp_km[l_ind].hor_diurnas,
                                        ma_desp_km[l_ind].hor_noturnas,
                                        ma_desp_km[l_ind].dat_apont_hor,
                                        ma_desp_km[l_ind].obs_apont_hor,
                                        ma_desp_km[l_ind].ativ)
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('INSERT','cdv_apont_hor_781')
           RETURN FALSE
        END IF
     END IF

     IF ma_desp_km[l_ind].tipo_despesa_km IS NOT NULL THEN
        LET l_max_seq_km = l_max_seq_km + 1
     END IF
     IF ma_desp_km[l_ind].tipo_despesa_hr IS NOT NULL THEN
        LET l_max_seq_hr = l_max_seq_hr + 1
     END IF
  END FOR

  RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2000_consulta_desp_km()
#-----------------------------------#
  IF NOT cdv2000_entrada_desp_km('CONSULTA') THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF

  IF NOT cdv2000_carrega_km_ja_informadas(mr_desp_km.viagem,'MANUAL') THEN
     ERROR 'Consulta cancelada.'
     RETURN
  END IF
  LET m_consulta_desp_km_ativa = TRUE

  CALL cdv2000_exibe_desp_km(2)

END FUNCTION

#--------------------------------------#
 FUNCTION cdv2000_exibe_desp_km(l_cont)
#--------------------------------------#
 DEFINE l_ind, l_cont, l_ind1  SMALLINT,
        m_total_km             DECIMAL(5,0),
        l_val_tot_km           LIKE cdv_despesa_km_781.val_km,
        l_tot_hor_diurnas      CHAR(08),
        l_tot_hor_noturnas     CHAR(08),
        l_tip_despesa_viagem   LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_status               SMALLINT #OS 520395

 FOR l_ind = 1 TO 200
    IF  ma_desp_km[l_ind].tipo_despesa_km IS NULL
    AND ma_desp_km[l_ind].tipo_despesa_hr IS NULL THEN
       EXIT FOR
    END IF

 END FOR

 IF (l_ind -1) = 0 THEN
    IF l_cont = 2 THEN
       CALL log0030_mensagem('Argumentos de pesquisa n�o encontrados.','exclamation')
    END IF
 ELSE
    CALL cdv2000_recupera_total_desp_km()
       RETURNING m_total_km, l_val_tot_km, l_tot_hor_diurnas, l_tot_hor_noturnas

    WHENEVER ERROR CONTINUE
     SELECT tip_despesa_viagem
       INTO l_tip_despesa_viagem
       FROM cdv_despesa_km_781
      WHERE empresa        = p_cod_empresa
        AND viagem         = mr_desp_km.viagem
        AND seq_despesa_km = 1
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
       CALL log003_err_sql('SELECT','cdv_despesa_km_781')
    END IF

    DISPLAY l_tip_despesa_viagem TO tipo_despesa_km
    DISPLAY m_total_km           TO total_km
    DISPLAY l_val_tot_km         TO val_tot_km
    DISPLAY l_tot_hor_diurnas    TO tot_hor_diurnas
    DISPLAY l_tot_hor_noturnas   TO tot_hor_noturnas

    LET l_ind = l_ind - 1
    CALL SET_COUNT(l_ind)

    IF l_ind > 2 THEN
       DISPLAY ARRAY ma_desp_km TO s_desp_km.*
       END DISPLAY
    ELSE
       FOR l_ind1 = 1 TO 2
#OS 520395 - Carrega descri��o cidade origem e destino
           CALL cdv2000_busca_des_cidade_origem(ma_desp_km[l_ind1].cidade_origem)
                RETURNING l_status
           LET ma_desp_km[l_ind1].des_cidade_origem = m_des_cidade_origem
           CALL cdv2000_busca_des_cidade_destino(ma_desp_km[l_ind1].cidade_destino)
                RETURNING l_status
           LET ma_desp_km[l_ind1].des_cidade_destino = m_des_cidade_destino
#-----------------------------------------------------
          DISPLAY ma_desp_km[l_ind1].* TO s_desp_km[l_ind1].*
       END FOR
    END IF
    LET m_km_ativa = TRUE
 END IF

 END FUNCTION

#-------------------------------------------------------------------#
 FUNCTION cdv2000_carrega_km_ja_informadas(l_viagem, l_modo_consulta)
#-------------------------------------------------------------------#
  DEFINE l_ind               SMALLINT,
         l_status            SMALLINT,
         l_seq               SMALLINT,
         l_eh_obs_apont_hor  CHAR(01),
         l_viagem            LIKE cdv_despesa_km_781.viagem,
         l_modo_consulta     CHAR(15),
         l_tipo_despesa_km   LIKE cdv_despesa_km_781.tip_despesa_viagem,
         l_ativ              LIKE cdv_despesa_km_781.ativ_km,
         l_trajeto           LIKE cdv_despesa_km_781.trajeto,
         l_cidade_origem     CHAR(05), #OS 520395
         l_cidade_destino    CHAR(05), #OS 520395
         l_placa             LIKE cdv_despesa_km_781.placa,
         l_km_inicial        LIKE cdv_despesa_km_781.km_inicial,
         l_km_final          LIKE cdv_despesa_km_781.km_final,
         l_qtd_km            LIKE cdv_despesa_km_781.qtd_km,
         l_val_km            LIKE cdv_despesa_km_781.val_km,
         l_ad_km             LIKE cdv_despesa_km_781.apropr_desp_km,
         l_dat_apont_hor     LIKE cdv_despesa_km_781.dat_despesa_km,
         l_obs_apont_hor     LIKE cdv_despesa_km_781.obs_despesa_km,
         l_tipo_despesa_hr   LIKE cdv_apont_hor_781.tdesp_apont_hor,
         l_hor_inicial       LIKE cdv_apont_hor_781.hor_inicial,
         l_hor_final         LIKE cdv_apont_hor_781.hor_final,
         l_motivo            LIKE cdv_apont_hor_781.motivo,
         l_hor_diurnas       LIKE cdv_apont_hor_781.hor_diurnas,
         l_hor_noturnas      LIKE cdv_apont_hor_781.hor_noturnas

  INITIALIZE ma_desp_km TO NULL
  LET l_ind = 1

  WHENEVER ERROR CONTINUE
   SELECT preco_km_empresa
     INTO mr_desp_km.preco_km
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_par_ctr_viagem')
     RETURN FALSE
  END IF

  IF l_modo_consulta = 'AUTOMATICO' THEN

     LET m_consulta_km_aut = FALSE

     WHENEVER ERROR CONTINUE
     DECLARE cq_desp_km_aut SCROLL CURSOR WITH HOLD FOR
     SELECT UNIQUE viagem
       FROM cdv_despesa_km_781
      WHERE empresa = p_cod_empresa
        AND viagem  IN (SELECT UNIQUE viagem FROM w_solic )
     UNION ALL
     SELECT UNIQUE viagem
       FROM w_solic
      WHERE viagem NOT IN (SELECT UNIQUE viagem
                           FROM cdv_despesa_km_781
                          WHERE empresa = p_cod_empresa
                            AND viagem  IN (SELECT UNIQUE viagem FROM w_solic ))
      ORDER BY 1
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","cq_desp_km_aut")
     ELSE
        WHENEVER ERROR CONTINUE
        OPEN cq_desp_km_aut
        WHENEVER ERROR STOP

        LET m_consulta_km_aut = TRUE
     END IF
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_desp_km CURSOR FOR
    SELECT cdv_despesa_km_781.tip_despesa_viagem,
           cdv_despesa_km_781.ativ_km,
           cdv_despesa_km_781.trajeto,
           cdv_despesa_km_781.cidade_origem, #OS 520395
           cdv_despesa_km_781.cidade_destino, #OS 520395
           cdv_despesa_km_781.placa,
           cdv_despesa_km_781.km_inicial,
           cdv_despesa_km_781.km_final,
           cdv_despesa_km_781.qtd_km,
           cdv_despesa_km_781.val_km,
           cdv_despesa_km_781.apropr_desp_km,
           cdv_despesa_km_781.dat_despesa_km,
           cdv_despesa_km_781.obs_despesa_km,
           cdv_despesa_km_781.seq_despesa_km
      FROM cdv_despesa_km_781
     WHERE cdv_despesa_km_781.empresa      = p_cod_empresa
       AND cdv_despesa_km_781.viagem       = l_viagem
     ORDER BY cdv_despesa_km_781.seq_despesa_km

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_DESP_KM")
   END IF

   FOREACH cq_desp_km INTO l_tipo_despesa_km,
                           l_ativ,
                           l_trajeto,
                           l_cidade_origem, #OS 520395
                           l_cidade_destino, #OS 520395
                           l_placa,
                           l_km_inicial,
                           l_km_final,
                           l_qtd_km,
                           l_val_km,
                           l_ad_km,
                           l_dat_apont_hor,
                           l_obs_apont_hor,
                           l_seq
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_desp_urbanas')
        RETURN FALSE
     END IF

     LET ma_desp_km[l_seq].tipo_despesa_km = l_tipo_despesa_km
     LET ma_desp_km[l_seq].ativ            = l_ativ
     LET ma_desp_km[l_seq].trajeto         = l_trajeto
     LET ma_desp_km[l_seq].cidade_origem   = l_cidade_origem #OS 520395
     LET ma_desp_km[l_seq].cidade_destino  = l_cidade_destino #OS 520395
     LET ma_desp_km[l_seq].placa           = l_placa
     LET ma_desp_km[l_seq].km_inicial      = l_km_inicial
     LET ma_desp_km[l_seq].km_final        = l_km_final
     LET ma_desp_km[l_seq].qtd_km          = l_qtd_km
     LET ma_desp_km[l_seq].val_km          = l_val_km
     LET ma_desp_km[l_seq].ad_km           = l_ad_km

     IF l_dat_apont_hor IS NOT NULL THEN
        LET ma_desp_km[l_seq].dat_apont_hor = l_dat_apont_hor
     END IF

     IF l_obs_apont_hor IS NOT NULL THEN
        LET ma_desp_km[l_seq].obs_apont_hor = l_obs_apont_hor
     END IF

     IF ma_desp_km[l_seq].tipo_despesa_km IS NOT NULL THEN
        CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_seq].tipo_despesa_km, 'KM', 0, ma_desp_km[l_seq].ativ)
           RETURNING l_status, ma_desp_km[l_seq].des_tip_desp_km
     END IF

     CALL cdv2000_valida_ativ(ma_desp_km[l_seq].ativ)
        RETURNING l_status, ma_desp_km[l_seq].des_ativ

     CALL cdv2000_recupera_primeira_ap(ma_desp_km[l_seq].ad_km)
        RETURNING l_status, ma_desp_km[l_seq].ap_km

     {CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_ind].tipo_despesa_hr, 'APONT', l_ind)
        RETURNING l_status, ma_desp_km[l_ind].des_tip_desp_hr

     IF ma_desp_km[l_ind].motivo IS NOT NULL THEN
        CALL cdv2000_valida_morivo_apont(ma_desp_km[l_ind].motivo)
           RETURNING l_status, ma_desp_km[l_ind].des_motivo, l_eh_obs_apont_hor
     END IF}

     #LET l_ind = l_ind + 1
  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_desp_km
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   DECLARE cq_desp_hr CURSOR FOR
    SELECT cdv_apont_hor_781.tdesp_apont_hor,
           cdv_apont_hor_781.hor_inicial,
           cdv_apont_hor_781.hor_final,
           cdv_apont_hor_781.motivo,
           cdv_apont_hor_781.hor_diurnas,
           cdv_apont_hor_781.hor_noturnas,
           cdv_apont_hor_781.dat_apont_hor,
           cdv_apont_hor_781.obs_apont_hor,
           cdv_apont_hor_781.seq_apont_hor,
           cdv_apont_hor_781.ativ
      FROM cdv_apont_hor_781
     WHERE cdv_apont_hor_781.empresa = p_cod_empresa
       AND cdv_apont_hor_781.viagem  = l_viagem
     ORDER BY cdv_apont_hor_781.seq_apont_hor

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_DESP_HR")
   END IF

   FOREACH cq_desp_hr INTO l_tipo_despesa_hr,
                           l_hor_inicial,
                           l_hor_final,
                           l_motivo,
                           l_hor_diurnas,
                           l_hor_noturnas,
                           l_dat_apont_hor,
                           l_obs_apont_hor,
                           l_seq,
                           l_ativ
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_desp_hr')
        RETURN FALSE
     END IF

     IF ma_desp_km[l_seq].ativ IS NULL THEN
        LET ma_desp_km[l_seq].ativ = l_ativ #cdv2000_busca_ativ_por_tdesp(l_tipo_despesa_hr)
        CALL cdv2000_valida_ativ(ma_desp_km[l_seq].ativ)
        RETURNING l_status, ma_desp_km[l_seq].des_ativ
     END IF

     LET ma_desp_km[l_seq].tipo_despesa_hr = l_tipo_despesa_hr
     LET ma_desp_km[l_seq].hor_inicial     = l_hor_inicial
     LET ma_desp_km[l_seq].hor_final       = l_hor_final
     LET ma_desp_km[l_seq].motivo          = l_motivo
     LET ma_desp_km[l_seq].hor_diurnas     = l_hor_diurnas
     LET ma_desp_km[l_seq].hor_noturnas    = l_hor_noturnas

     IF ma_desp_km[l_seq].dat_apont_hor IS NULL
     OR ma_desp_km[l_seq].dat_apont_hor = ' ' THEN
        LET ma_desp_km[l_seq].dat_apont_hor   = l_dat_apont_hor
     END IF

     IF ma_desp_km[l_seq].obs_apont_hor IS NULL
     OR ma_desp_km[l_seq].obs_apont_hor = ' ' THEN
        LET ma_desp_km[l_seq].obs_apont_hor   = l_obs_apont_hor
     END IF

     CALL cdv2000_valida_tipo_despesa(ma_desp_km[l_seq].tipo_despesa_hr, 'APONT', l_seq, ma_desp_km[l_seq].ativ)
        RETURNING l_status, ma_desp_km[l_seq].des_tip_desp_hr

     IF ma_desp_km[l_seq].motivo IS NOT NULL THEN
        CALL cdv2000_valida_morivo_apont(ma_desp_km[l_seq].motivo)
           RETURNING l_status, ma_desp_km[l_seq].des_motivo, l_eh_obs_apont_hor
     END IF

  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_desp_hr
  WHENEVER ERROR STOP

  RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_recupera_primeira_ap(l_num_ad)
#-----------------------------------------------#
  DEFINE l_num_ad    LIKE ad_mestre.num_ad,
         m_num_ap    LIKE ap.num_ap

  INITIALIZE m_num_ap TO NULL

  WHENEVER ERROR CONTINUE
   DECLARE cq_busca_ap CURSOR FOR
    SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = p_cod_empresa
       AND num_ad      = l_num_ad

   IF SQLCA.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_BUSCA_AP")
   END IF

   FOREACH cq_busca_ap INTO m_num_ap
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','ad_ap')
        RETURN FALSE, m_num_ap
     END IF
     EXIT FOREACH
  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_busca_ap
  WHENEVER ERROR STOP

  RETURN TRUE, m_num_ap

END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2000_valoriza_km(l_tipo_despesa, l_ativ)
#---------------------------------------------------#
  DEFINE l_tipo_despesa  LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_ativ          LIKE cdv_tdesp_viag_781.ativ

  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cdv_tdesp_viag_781
    WHERE empresa            = p_cod_empresa
      AND tip_despesa_viagem = l_tipo_despesa
      AND ativ               = l_ativ
      AND eh_valz_km         = 'S'
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE
     WHEN 100
        RETURN FALSE
     OTHERWISE
        CALL log003_err_sql('SELECT','cdv_tdesp_viag_781')
        RETURN FALSE
  END CASE

END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_recupera_total_desp_km()
#-----------------------------------------#
  DEFINE l_ind               SMALLINT,
         m_total_km          DECIMAL(5,0),
         l_val_tot_km        LIKE cdv_despesa_km_781.val_km,
         l_hor_inicial       DATETIME HOUR TO SECOND,
         l_hor_final         DATETIME HOUR TO SECOND,
         l_tot_hor_diurnas   DATETIME HOUR TO SECOND,
         l_tot_hor_noturnas  DATETIME HOUR TO SECOND,
         l_teste             DATETIME HOUR TO SECOND

  LET m_total_km   = 0
  LET l_val_tot_km = 0
  LET l_tot_hor_diurnas  = '00:00:00'
  LET l_tot_hor_noturnas = '00:00:00'
  LET l_teste = '00:00:00'

  FOR l_ind = 1 TO 200
     {IF ma_desp_km[l_ind].ativ IS NULL THEN
        EXIT FOR
     END IF}
     IF  ma_desp_km[l_ind].tipo_despesa_km IS NULL
     AND ma_desp_km[l_ind].tipo_despesa_hr IS NULL THEN
       EXIT FOR
    END IF

     IF ma_desp_km[l_ind].qtd_km IS NOT NULL THEN
        LET m_total_km   = m_total_km   + ma_desp_km[l_ind].qtd_km
     END IF

     IF ma_desp_km[l_ind].val_km IS NOT NULL THEN
        LET l_val_tot_km = l_val_tot_km + ma_desp_km[l_ind].val_km
     END IF

     IF ma_desp_km[l_ind].hor_diurnas IS NOT NULL THEN
        LET l_hor_inicial = ma_desp_km[l_ind].hor_diurnas
     END IF

     IF ma_desp_km[l_ind].hor_noturnas IS NOT NULL THEN
        LET l_hor_final   = ma_desp_km[l_ind].hor_noturnas
     END IF

     LET l_tot_hor_diurnas  = l_tot_hor_diurnas + (l_hor_inicial - l_teste)
     LET l_tot_hor_noturnas = l_tot_hor_noturnas + (l_hor_final - l_teste)
  END FOR

  IF m_total_km IS NULL THEN
     LET m_total_km = 0
  END IF
  IF l_val_tot_km IS NULL THEN
     LET l_val_tot_km = 0
  END IF
  IF l_tot_hor_diurnas IS NULL THEN
     LET l_tot_hor_diurnas = '00:00:00'
  END IF
  IF l_tot_hor_noturnas IS NULL THEN
     LET l_tot_hor_noturnas = '00:00:00'
  END IF

  RETURN m_total_km, l_val_tot_km, l_tot_hor_diurnas, l_tot_hor_noturnas

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_valida_morivo_apont(l_motivo)
#----------------------------------------------#
  DEFINE l_motivo            LIKE cdv_motivo_hor_781.motivo,
         l_des_motivo        LIKE cdv_motivo_hor_781.des_motivo,
         l_eh_obs_apont_hor  LIKE cdv_motivo_hor_781.eh_obs_apont_hor

  INITIALIZE l_des_motivo, l_eh_obs_apont_hor TO NULL

  WHENEVER ERROR CONTINUE
   SELECT des_motivo, eh_obs_apont_hor
     INTO l_des_motivo, l_eh_obs_apont_hor
     FROM cdv_motivo_hor_781
    WHERE cdv_motivo_hor_781.motivo = l_motivo
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE, l_des_motivo, l_eh_obs_apont_hor
     WHEN 100
        CALL log0030_mensagem('Motivo n�o cadastrado.','exclamation')
        RETURN FALSE, l_des_motivo, l_eh_obs_apont_hor
     OTHERWISE
        CALL log003_err_sql('SELECT','cdv_motivo_hor_781')
        RETURN FALSE, l_des_motivo, l_eh_obs_apont_hor
  END CASE

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_recupera_tip_desp_km()
#---------------------------------------#
  DEFINE l_tip_despesa_viagem   LIKE cdv_tdesp_viag_781.tip_despesa_viagem

  WHENEVER ERROR CONTINUE
   SELECT tip_despesa_viagem
     INTO l_tip_despesa_viagem
     FROM cdv_despesa_km_781
    WHERE empresa        = p_cod_empresa
      AND viagem         = mr_desp_km.viagem
      AND seq_despesa_km = 1
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     INITIALIZE l_tip_despesa_viagem TO NULL
  END IF

  RETURN l_tip_despesa_viagem

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2000_ad_relac_varias_despesas(l_arr_curr)
#-----------------------------------------------------#
  DEFINE l_arr_curr    SMALLINT,
         l_ind         SMALLINT

  FOR l_ind = 1 TO 200
     {IF ma_desp_km[l_ind].ativ IS NULL THEN
        EXIT FOR
     END IF}
    IF  ma_desp_km[l_ind].tipo_despesa_km IS NULL
    AND ma_desp_km[l_ind].tipo_despesa_hr IS NULL THEN
       EXIT FOR
    END IF


     IF l_ind = l_arr_curr THEN
        CONTINUE FOR
     END IF

     IF (ma_desp_km[l_ind].ad_km = ma_desp_km[l_arr_curr].ad_km) AND
         ma_desp_km[l_ind].ad_km IS NOT NULL THEN
        RETURN TRUE
     END IF

  END FOR

  RETURN FALSE

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2000_confirma_exclusao_despesas()
#---------------------------------------------#
  DEFINE l_resp  CHAR(01)

  LET l_resp = '@'

  WHILE UPSHIFT(l_resp) <> 'N' AND UPSHIFT(l_resp) <> 'S'

     OPEN WINDOW w_aviso_acesso AT 6,10 WITH 9 ROWS,60 COLUMNS
          ATTRIBUTE (BORDER,PROMPT LINE LAST)
     DISPLAY "                           AVISO!                           " AT 1,1
      DISPLAY "                           ------                           " AT 2,1
      DISPLAY "   AD de quilometragem relacionada a mais de uma despesa.   " AT 4,1
      DISPLAY "  A exclus�o desta despesa resultar� na exclus�o de todas   " AT 5,1
      DISPLAY "  as despesas relacionadas a esta AD.                       " AT 6,1
      DISPLAY "                                                         " AT 7,1
     PROMPT " Confirma exclus�o da despesa (S/N)? "  FOR CHAR l_resp
     CLOSE WINDOW w_aviso_acesso
  END WHILE

  CURRENT WINDOW IS w_cdv20003

  RETURN UPSHIFT(l_resp)

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_exclui_ad(l_num_ad)
#------------------------------------#
  DEFINE l_num_ad    LIKE ad_mestre.num_ad

  ERROR "Excluindo AD . . ." ATTRIBUTE(REVERSE)
  SLEEP 1

  CALL log120_procura_caminho("cap0220")
     RETURNING m_caminho

  LET m_caminho = m_caminho CLIPPED, " ", l_num_ad,
                                     " ", p_cod_empresa,
                                     " EXCLUIR CDV2000"
  RUN m_caminho

  WHENEVER ERROR CONTINUE
   SELECT num_ad
     FROM ad_mestre
    WHERE num_ad      = l_num_ad
      AND cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     CALL log0030_mensagem("AD n�o pode ser exclu�da, exclus�o cancelada.",'exclamation')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_exclui_ap(m_num_ap)
#------------------------------------#
  DEFINE m_num_ap        LIKE ap.num_ap,
         l_status_rem    LIKE ap.status_rem,
         m_dat_pgto      LIKE ap.dat_pgto

  WHENEVER ERROR CONTINUE
   SELECT status_rem, dat_pgto
     INTO l_status_rem, m_dat_pgto
     FROM ap
    WHERE cod_empresa      = p_cod_empresa
      AND num_ap           = m_num_ap
      AND ies_versao_atual = 'S'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','ap')
     RETURN FALSE
  END IF

  IF l_status_rem IS NOT NULL AND l_status_rem <> 0 THEN
     CALL log0030_mensagem("AP est� em PGE, n�o pode ser exclu�da.",'exclamation')
     RETURN FALSE
  END IF

  IF m_dat_pgto IS NOT NULL THEN
     CALL log0030_mensagem("AP paga, n�o pode ser exclu�da.",'exclamation')
     RETURN FALSE
  END IF

  ERROR "Excluindo AP . . ." ATTRIBUTE(REVERSE)
  SLEEP 1

  CALL log120_procura_caminho("cap0160")
     RETURNING m_caminho
  LET m_caminho = m_caminho CLIPPED, " ",m_num_ap,
                                     " ",p_cod_empresa,
                                     " S"
  RUN m_caminho

  WHENEVER ERROR CONTINUE
   SELECT num_ap
     FROM ap
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = m_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     CALL log0030_mensagem("AP n�o pode ser exclu�da, exclus�o cancelada.",'exclamation')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv2000_exclui_despesa_no_cap(l_num_ad, m_num_ap)
#----------------------------------------------------------#
  DEFINE l_num_ad     LIKE ad_mestre.num_ad,
         m_num_ap     LIKE ap.num_ap

  IF m_num_ap IS NOT NULL THEN
     IF NOT cdv2000_exclui_ap(m_num_ap) THEN
        RETURN FALSE
     END IF
  END IF

  IF l_num_ad IS NOT NULL THEN
     IF NOT cdv2000_exclui_ad(l_num_ad) THEN
        RETURN FALSE
     END IF
  END IF
  RETURN TRUE

END FUNCTION

#------------------------------------------#
 FUNCTION cdv2000_manut_despesas_terceiros()
#------------------------------------------#

  DEFINE l_den_viagem    CHAR(50),
         l_viagem        LIKE cdv_solic_viag_781.viagem

  CALL log006_exibe_teclas('01', p_versao)

  LET m_caminho = log1300_procura_caminho('cdv20004','cdv20004')
  OPEN WINDOW w_cdv20004 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  LET m_terc_ativa    = FALSE

  CALL cdv2000_consulta_previa()
  DISPLAY m_previa_viagem   TO viagem
  DISPLAY m_previa_controle TO controle

  IF NOT cdv2000_carrega_ativs(mr_input.viagem) THEN
     CALL log0030_mensagem('Manuten��o cancelada.','exclamation')
     RETURN
  END IF

  INITIALIZE mr_desp_terc.*, mr_desp_tercr.* TO NULL

  MENU 'TERCEIRAS'
     BEFORE MENU
        IF mr_input.des_status = 'ACERTO VIAGEM PENDENTE' OR
           mr_input.des_status = 'ACERTO VIAGEM FINALIZADO' OR
           mr_input.des_status = 'ACERTO VIAGEM LIBERADO' THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

        IF  m_origem = 'S' THEN
           HIDE OPTION 'Anterior'
           HIDE OPTION 'Seguinte'
           HIDE OPTION 'Consultar'
        END IF

        IF  mr_input.des_status = 'ACERTO VIAGEM FINALIZADO'
        AND cdv2000_eh_viagem_terc(mr_input.viagem) THEN
           SHOW OPTION 'Modificar'
           SHOW OPTION 'Excluir'
        END IF

        IF  m_origem = 'N'
        AND NOT cdv2000_viagem_eh_origem(mr_input.viagem) THEN
           LET m_ult_viag_terc = 0
           CALL cdv2000_carrega_desp_terc_ja_informadas(mr_input.viagem, 2)
           LET mr_desp_terc.viagem   = mr_input.viagem
        ELSE
           LET l_viagem = cdv2000_procura_viagem_terc(mr_input.viagem)
           LET m_ult_viag_terc = l_viagem
           CALL cdv2000_carrega_desp_terc_ja_informadas(l_viagem, 1)
           IF l_viagem <> 0 THEN
              LET mr_desp_terc.viagem_origem   = mr_input.viagem
           END IF

        END IF

        LET mr_desp_terc.controle = mr_input.controle

        DISPLAY BY NAME mr_desp_terc.*

        IF cdv2000_verifica_usuario_viajante(mr_input.viagem) THEN
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

        IF m_origem = 'S' THEN
           CALL cdv2000_inclusao_desp_terc()
        END IF

     COMMAND 'Incluir' 'Inclui novas despesas de terceiros.'
        HELP 001
        MESSAGE ''
        LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_terc.viagem)
        IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
           IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'IN') THEN
              CALL cdv2000_inclusao_desp_terc()
           END IF
        ELSE
           CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
        END IF

     COMMAND 'Modificar' 'Modifica despesas de terceiros.'
        HELP 002
        MESSAGE ''
        IF m_terc_ativa THEN
           LET l_den_viagem = cdv2000_busca_den_viagem(mr_desp_terc.viagem)
           IF l_den_viagem <> 'ACERTO VIAGEM PENDENTE' THEN
              IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'MO') THEN
                 CALL cdv2000_modificacao_desp_terc()
              END IF
           ELSE
              CALL log0030_mensagem('Acerto de viagem n�o inicializado.','exclamation')
           END IF
        ELSE
           CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
           NEXT OPTION "Consultar"
        END IF

     COMMAND "Excluir" "Exclus�o de despesas de terceiros."
        HELP 003
        MESSAGE ""
        IF m_terc_ativa THEN
           IF log005_seguranca(p_user, 'CDV', 'CDV2000', 'EX') THEN
              CALL cdv2000_exclusao_desp_terc()
           END IF
        ELSE
           CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
           NEXT OPTION "Consultar"
        END IF

     COMMAND 'Consultar' 'Pesquisa despesas terceiros.'
        HELP 004
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'CO') THEN
           CALL cdv2000_consulta_desp_terc()
        END IF

     COMMAND "Seguinte"   "Exibe o pr�ximo acerto encontrado na consulta."
       HELP 005
       MESSAGE ""
       CALL cdv2000_paginacao_terc("SEGUINTE")
        IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
           m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
           m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
           SHOW OPTION 'Incluir'
           SHOW OPTION 'Modificar'
           SHOW OPTION 'Excluir'
        ELSE
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

        IF  m_den_acerto = 'ACERTO VIAGEM FINALIZADO'
        AND cdv2000_eh_viagem_terc(mr_desp_terc.viagem) THEN
           SHOW OPTION 'Modificar'
           SHOW OPTION 'Excluir'
        END IF

     COMMAND "Anterior"   "Exibe o acerto anterior encontrado na consulta."
       HELP 006
       MESSAGE ""
       CALL cdv2000_paginacao_terc("ANTERIOR")
        IF m_den_acerto <> 'ACERTO VIAGEM PENDENTE' AND
           m_den_acerto <> 'ACERTO VIAGEM FINALIZADO' AND
           m_den_acerto <> 'ACERTO VIAGEM LIBERADO' THEN
           SHOW OPTION 'Incluir'
           SHOW OPTION 'Modificar'
           SHOW OPTION 'Excluir'
        ELSE
           HIDE OPTION 'Incluir'
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

        IF  m_den_acerto = 'ACERTO VIAGEM FINALIZADO'
        AND cdv2000_eh_viagem_terc(mr_desp_terc.viagem) THEN
           SHOW OPTION 'Modificar'
           SHOW OPTION 'Excluir'
        END IF

     COMMAND KEY('T') "manuTen��o ADs"   "Executa o cap0220."
       HELP 016
       MESSAGE ""
       IF m_terc_ativa THEN
          CALL cdv2000_manutencao_ads('N')
       ELSE
          CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
          NEXT OPTION "Consultar"
       END IF

     COMMAND KEY ('!')
        PROMPT 'Digite o m_comando : ' FOR m_comando
        RUN m_comando
        PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

     COMMAND 'Fim'       'Retorna ao menu anterior.'
        HELP 008
        EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv20004
  CURRENT WINDOW IS w_cdv2000

END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_inclusao_desp_terc()
#------------------------------------#
  DEFINE l_seq_desp_terceiro     SMALLINT,
         l_work                  SMALLINT,
         lr_cdv_solic_viag_781   RECORD LIKE cdv_solic_viag_781.*,
         lr_cdv_acer_viag_781    RECORD LIKE cdv_acer_viag_781.*,
         l_viagem                LIKE cdv_solic_viag_781.viagem

  LET mr_desp_tercr.* = mr_desp_terc.*

  IF NOT cdv2000_entrada_desp_terc('INCLUSAO') THEN
     ERROR 'Inclus�o cancelada.'
     LET mr_desp_terc.* = mr_desp_tercr.*
     DISPLAY BY NAME mr_desp_terc.*
     RETURN
  END IF

  #IF  mr_desp_terc.viagem_origem IS NOT NULL
  #AND mr_desp_terc.viagem_origem <> 0 THEN
  #   LET l_viagem = cdv2000_carrega_numero_viagem()
  #ELSE
  LET l_viagem = mr_desp_terc.viagem
  #END IF

  WHENEVER ERROR CONTINUE
   SELECT MAX(seq_desp_terceiro)
     INTO l_seq_desp_terceiro
     FROM cdv_desp_terc_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_desp_terc_781')
  END IF
  IF l_seq_desp_terceiro IS NULL OR l_seq_desp_terceiro = 0 THEN
     LET l_seq_desp_terceiro = 1
  ELSE
     LET l_seq_desp_terceiro = l_seq_desp_terceiro + 1
  END IF

  CALL log085_transacao("BEGIN")
  LET l_work = TRUE

  IF  mr_desp_terc.viagem_origem IS NOT NULL
  AND mr_desp_terc.viagem_origem <> 0 THEN
     INITIALIZE lr_cdv_solic_viag_781.*, lr_cdv_acer_viag_781.* TO NULL

     CALL cdv2000_recupera_solic_acer_viag(mr_desp_terc.viagem_origem)
          RETURNING lr_cdv_solic_viag_781.*,
                    lr_cdv_acer_viag_781.*

     LET lr_cdv_solic_viag_781.viagem            = l_viagem
     LET lr_cdv_acer_viag_781.viagem             = l_viagem
     LET lr_cdv_solic_viag_781.dat_hr_emis_solic = EXTEND(CURRENT, YEAR TO SECOND)
     LET lr_cdv_acer_viag_781.dat_hr_emis_relat  = EXTEND(CURRENT, YEAR TO SECOND)
     LET lr_cdv_acer_viag_781.status_acer_viagem = '2'
     INITIALIZE lr_cdv_acer_viag_781.ad_acerto_conta TO NULL

     WHENEVER ERROR CONTINUE
     SELECT UNIQUE empresa
       FROM cdv_solic_viag_781
      WHERE empresa = p_cod_empresa
        AND viagem  = lr_cdv_solic_viag_781.viagem
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 100 THEN
        WHENEVER ERROR CONTINUE
        INSERT INTO cdv_solic_viag_781 (empresa,           viagem,
                                        controle,          dat_hr_emis_solic,
                                        viajante,          finalidade_viagem,
                                        cc_viajante,       cc_debitar,
                                        cliente_atendido,  cliente_fatur,
                                        empresa_atendida,  filial_atendida,
                                        trajeto_principal, dat_hor_partida,
                                        dat_hor_retorno,   motivo_viagem)
                                VALUES (lr_cdv_solic_viag_781.empresa,           lr_cdv_solic_viag_781.viagem,
                                        lr_cdv_solic_viag_781.controle,          lr_cdv_solic_viag_781.dat_hr_emis_solic,
                                        lr_cdv_solic_viag_781.viajante,          lr_cdv_solic_viag_781.finalidade_viagem,
                                        lr_cdv_solic_viag_781.cc_viajante,       lr_cdv_solic_viag_781.cc_debitar,
                                        lr_cdv_solic_viag_781.cliente_atendido,  lr_cdv_solic_viag_781.cliente_fatur,
                                        lr_cdv_solic_viag_781.empresa_atendida,  lr_cdv_solic_viag_781.filial_atendida,
                                        lr_cdv_solic_viag_781.trajeto_principal, lr_cdv_solic_viag_781.dat_hor_partida,
                                        lr_cdv_solic_viag_781.dat_hor_retorno,   lr_cdv_solic_viag_781.motivo_viagem)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INSERT","CDV_SOLIC_VIAG_781")
           LET l_work = FALSE
        END IF
     END IF

     WHENEVER ERROR CONTINUE
     SELECT UNIQUE empresa
       FROM cdv_acer_viag_781
      WHERE empresa = p_cod_empresa
        AND viagem  = lr_cdv_acer_viag_781.viagem
     WHENEVER ERROR STOP

     IF sqlca.sqlcode = 100 THEN
        WHENEVER ERROR CONTINUE
        INSERT INTO cdv_acer_viag_781 (empresa,            viagem,
                                       controle,           dat_hr_emis_relat,
                                       status_acer_viagem, viajante,
                                       finalidade_viagem,  cc_viajante,
                                       cc_debitar,         ad_acerto_conta,
                                       cliente_destino,    cliente_debitar,
                                       empresa_atendida,   filial_atendida,
                                       trajeto_principal,  dat_hor_partida,
                                       dat_hor_retorno,    motivo_viagem)
                               VALUES (lr_cdv_acer_viag_781.empresa,            lr_cdv_acer_viag_781.viagem,
                                       lr_cdv_acer_viag_781.controle,           lr_cdv_acer_viag_781.dat_hr_emis_relat,
                                       lr_cdv_acer_viag_781.status_acer_viagem, lr_cdv_acer_viag_781.viajante,
                                       lr_cdv_acer_viag_781.finalidade_viagem,  lr_cdv_acer_viag_781.cc_viajante,
                                       lr_cdv_acer_viag_781.cc_debitar,         lr_cdv_acer_viag_781.ad_acerto_conta,
                                       lr_cdv_acer_viag_781.cliente_destino,    lr_cdv_acer_viag_781.cliente_debitar,
                                       lr_cdv_acer_viag_781.empresa_atendida,   lr_cdv_acer_viag_781.filial_atendida,
                                       lr_cdv_acer_viag_781.trajeto_principal,  lr_cdv_acer_viag_781.dat_hor_partida,
                                       lr_cdv_acer_viag_781.dat_hor_retorno,    lr_cdv_acer_viag_781.motivo_viagem)
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INSERT","CDV_ACER_VIAG_781")
           LET l_work = FALSE
        END IF
     END IF

  END IF

  IF mr_desp_terc.ad_terceiro IS NULL THEN
     CALL cdv2000_gera_ad_desp_terc(l_viagem)
          RETURNING l_work, mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro
  END IF

  IF l_work THEN

     LET mr_desp_terc.previsao = cdv2000_recupera_ind_previsao(mr_desp_terc.ad_terceiro)
     DISPLAY BY NAME mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro,
                     mr_desp_terc.previsao

     WHENEVER ERROR CONTINUE
      INSERT INTO cdv_desp_terc_781 (empresa,
                                     viagem,
                                     seq_desp_terceiro,
                                     ativ,
                                     tip_despesa,
                                     nota_fiscal,
                                     serie_nota_fiscal,
                                     subserie_nf,
                                     fornecedor,
                                     dat_inclusao,
                                     dat_vencto,
                                     val_desp_terceiro,
                                     observacao,
                                     ad_terceiro,
                                     viagem_origem)
                             VALUES (p_cod_empresa,
                                     l_viagem,
                                     l_seq_desp_terceiro,
                                     mr_desp_terc.ativ,
                                     mr_desp_terc.tip_despesa,
                                     mr_desp_terc.nota_fiscal,
                                     mr_desp_terc.serie_nota_fiscal,
                                     mr_desp_terc.subserie_nf,
                                     mr_desp_terc.fornecedor,
                                     mr_desp_terc.dat_inclusao,
                                     mr_desp_terc.dat_vencto,
                                     mr_desp_terc.val_desp_terceiro,
                                     mr_desp_terc.observacao,
                                     mr_desp_terc.ad_terceiro,
                                     mr_desp_terc.viagem_origem)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('INSERT','cdv_desp_terc_781')
        LET l_work = FALSE
     END IF

  END IF

  IF l_work THEN
     CALL log085_transacao("COMMIT")
     MESSAGE 'Inclus�o efetuada com sucesso.' ATTRIBUTE(REVERSE)
     LET m_terc_ativa = FALSE
     IF mr_desp_terc.ad_terceiro IS NULL THEN
        CALL cdv2000_manutencao_ads('S')
     END IF
  ELSE
     CALL log085_transacao("ROLLBACK")
     ERROR 'Inclus�o cancelada.'
     LET mr_desp_terc.* = mr_desp_tercr.*
     DISPLAY BY NAME mr_desp_terc.*
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2000_modificacao_desp_terc()
#----------------------------------------#
  DEFINE l_work     SMALLINT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv20004

  IF NOT cdv2000_exclui_despesa_no_cap(mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro) THEN
     ERROR "Exclus�o AD despesa de terceiros cancelada."
     RETURN
  END IF

  INITIALIZE mr_desp_terc.ad_terceiro, mr_desp_terc.previsao, mr_desp_terc.ap_terceiro TO NULL

  LET mr_desp_tercr.* = mr_desp_terc.*

  IF NOT cdv2000_entrada_desp_terc('MODIFICACAO') THEN
     ERROR 'Modifica��o cancelada.'
     LET mr_desp_terc.* = mr_desp_tercr.*
     DISPLAY BY NAME mr_desp_terc.*
     RETURN
  END IF

  IF cdv2000_cursor_for_update_desp_terc() THEN

     IF mr_desp_terc.ad_terceiro IS NULL THEN
        CALL cdv2000_gera_ad_desp_terc(mr_desp_terc.viagem)
             RETURNING l_work, mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro
     END IF

     IF l_work THEN
        LET mr_desp_terc.previsao = cdv2000_recupera_ind_previsao(mr_desp_terc.ad_terceiro)
        DISPLAY BY NAME mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro,
                        mr_desp_terc.previsao
     END IF

     WHENEVER ERROR CONTINUE
      UPDATE cdv_desp_terc_781
         SET ativ              = mr_desp_terc.ativ,
             tip_despesa       = mr_desp_terc.tip_despesa,
             nota_fiscal       = mr_desp_terc.nota_fiscal,
             serie_nota_fiscal = mr_desp_terc.serie_nota_fiscal,
             subserie_nf       = mr_desp_terc.subserie_nf,
             fornecedor        = mr_desp_terc.fornecedor,
             dat_inclusao      = mr_desp_terc.dat_inclusao,
             dat_vencto        = mr_desp_terc.dat_vencto,
             val_desp_terceiro = mr_desp_terc.val_desp_terceiro,
             observacao        = mr_desp_terc.observacao,
             ad_terceiro       = mr_desp_terc.ad_terceiro
       WHERE CURRENT OF cm_desp_terc
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 0 THEN
        CALL log085_transacao("COMMIT")
        MESSAGE 'Modifica��o efetuada com sucesso.' ATTRIBUTE(REVERSE)
        LET m_terc_ativa = FALSE
        IF mr_desp_terc.ad_terceiro IS NULL THEN
           CALL cdv2000_manutencao_ads('S')
        END IF
     ELSE
        CALL log003_err_sql('UPDATE','cdv_desp_terc_781')
        CALL log085_transacao("ROLLBACK")
        ERROR 'Modifica��o cancelada.'
        LET mr_desp_terc.* = mr_desp_tercr.*
        DISPLAY BY NAME mr_desp_terc.*
     END IF
  ELSE
     ERROR 'Modifica��o cancelada.'
     LET mr_desp_terc.* = mr_desp_tercr.*
     DISPLAY BY NAME mr_desp_terc.*
  END IF

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_exclusao_desp_terc()
#-------------------------------------#
  DEFINE l_viagem_de_terc    SMALLINT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv20004

  IF log0040_confirm(19,34,"Confirma exclus�o?") THEN

     IF NOT cdv2000_exclui_despesa_no_cap(mr_desp_terc.ad_terceiro, mr_desp_terc.ap_terceiro) THEN
        ERROR "Exclus�o cancelada."
        RETURN
     END IF

     LET l_viagem_de_terc = FALSE
     IF cdv2000_eh_viagem_terc(mr_desp_terc.viagem) THEN
        LET l_viagem_de_terc = TRUE
     END IF

     IF cdv2000_cursor_for_update_desp_terc() THEN
        WHENEVER ERROR CONTINUE
         DELETE FROM cdv_desp_terc_781
          WHERE CURRENT OF cm_desp_terc
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE = 0 THEN

           WHENEVER ERROR CONTINUE
           SELECT empresa
             FROM cdv_desp_terc_781
            WHERE empresa = p_cod_empresa
              AND viagem  = mr_desp_terc.viagem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode = 100
           AND l_viagem_de_terc = TRUE THEN      #se a viagem possuir somente um apontamento e ser de terceiro
                                                 #devera entao excluir toda a viagem de terceiro.
              WHENEVER ERROR CONTINUE
              DELETE FROM cdv_solic_viag_781
               WHERE empresa = p_cod_empresa
                 AND viagem  = mr_desp_terc.viagem
              WHENEVER ERROR STOP

              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("DELETE","cdv_solic_viag_781")
              END IF

              WHENEVER ERROR CONTINUE
              DELETE FROM cdv_acer_viag_781
               WHERE empresa = p_cod_empresa
                 AND viagem  = mr_desp_terc.viagem
              WHENEVER ERROR STOP

              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("DELETE","cdv_acer_viag_781")
              END IF

           END IF

           CALL log085_transacao("COMMIT")
           MESSAGE "Exclus�o efetuada com sucesso." ATTRIBUTE(REVERSE)
           CLEAR FORM
           DISPLAY p_cod_empresa TO empresa
           INITIALIZE mr_desp_terc.* TO NULL
        ELSE
           CALL log085_transacao("ROLLBACK")
           ERROR 'Exclus�o cancelada.'
        END IF
     ELSE
        ERROR 'Exclus�o cancelada.'
     END IF
  ELSE
     ERROR 'Exclus�o cancelada.'
  END IF

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_consulta_desp_terc()
#-------------------------------------#
  LET mr_desp_tercr.* = mr_desp_terc.*

  IF NOT cdv2000_entrada_desp_terc('CONSULTA') THEN
     ERROR 'Consulta cancelada.'
     LET mr_desp_terc.* = mr_desp_tercr.*
     DISPLAY BY NAME mr_desp_terc.*
     RETURN
  END IF

  CALL cdv2000_carrega_desp_terc_ja_informadas(mr_desp_terc.viagem, 1)

END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION cdv2000_carrega_desp_terc_ja_informadas(l_viagem, l_cont)
#-----------------------------------------------------------------#
 DEFINE l_viagem   LIKE cdv_desp_terc_781.viagem,
        l_cont     SMALLINT,
        l_sql_stmt CHAR(2000)

 INITIALIZE l_sql_stmt TO NULL

 WHENEVER ERROR CONTINUE
 DECLARE cq_viag_terc SCROLL CURSOR WITH HOLD FOR
  SELECT UNIQUE w_solic.viagem, w_solic.controle, cdv_desp_terc_781.seq_desp_terceiro
    FROM w_solic, cdv_desp_terc_781
   WHERE cdv_desp_terc_781.empresa = p_cod_empresa
     AND w_solic.viagem = cdv_desp_terc_781.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("declare","cq_viag_terc")
 END IF

 WHENEVER ERROR CONTINUE
 OPEN cq_viag_terc
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('OPEN','cq_viag_terc')
    RETURN
 END IF

 IF l_cont = 2 THEN
    LET l_sql_stmt = " SELECT viagem, seq_desp_terceiro, ",
                     " ativ, tip_despesa, ",
                     " nota_fiscal, serie_nota_fiscal, subserie_nf, ",
                     " fornecedor, dat_inclusao, dat_vencto, ",
                     " val_desp_terceiro, observacao, ad_terceiro, viagem_origem ",
                     " FROM cdv_desp_terc_781 ",
                     " WHERE empresa = '",p_cod_empresa,"' ",
                     " AND viagem  = ",l_viagem," "
 ELSE
    LET l_sql_stmt = " SELECT cdv_desp_terc_781.viagem, cdv_desp_terc_781.seq_desp_terceiro, ",
                     " cdv_desp_terc_781.ativ, cdv_desp_terc_781.tip_despesa, ",
                     " cdv_desp_terc_781.nota_fiscal, cdv_desp_terc_781.serie_nota_fiscal, cdv_desp_terc_781.subserie_nf, ",
                     " cdv_desp_terc_781.fornecedor, cdv_desp_terc_781.dat_inclusao, cdv_desp_terc_781.dat_vencto, ",
                     " cdv_desp_terc_781.val_desp_terceiro, cdv_desp_terc_781.observacao, cdv_desp_terc_781.ad_terceiro, cdv_desp_terc_781.viagem_origem, ",
                     " cdv_acer_viag_781.controle ",
                     " FROM cdv_desp_terc_781, cdv_acer_viag_781 ",
                     " WHERE cdv_desp_terc_781.empresa = '",p_cod_empresa,"' ",
                     " AND cdv_acer_viag_781.empresa = '",p_cod_empresa,"' ",
                     " AND cdv_desp_terc_781.viagem  IN (SELECT UNIQUE viagem FROM w_solic) ",
                     " AND cdv_desp_terc_781.viagem    = cdv_acer_viag_781.viagem ",
                     " ORDER BY cdv_desp_terc_781.viagem, cdv_desp_terc_781.seq_desp_terceiro "
 END IF

 WHENEVER ERROR CONTINUE
 PREPARE var_query_terc FROM l_sql_stmt
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 DECLARE cq_consulta_terc SCROLL CURSOR WITH HOLD FOR var_query_terc
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('DECLARE','cq_consulta_terc')
    LET mr_desp_terc.* = mr_desp_tercr.*
    DISPLAY BY NAME mr_desp_terc.*
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  OPEN cq_consulta_terc
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('OPEN','cq_consulta_terc')
    LET mr_desp_terc.* = mr_desp_tercr.*
    DISPLAY BY NAME mr_desp_terc.*
    RETURN
 END IF


 IF l_viagem <> 0
 AND l_cont = 1 THEN
    LET sqlca.sqlcode   = 0

    IF mr_desp_terc.viagem_origem IS NULL THEN
       LET mr_desp_terc.viagem = 0
    END IF

    WHILE sqlca.sqlcode = 0
    AND mr_desp_terc.viagem <> l_viagem
       WHENEVER ERROR CONTINUE
       FETCH cq_consulta_terc INTO mr_desp_terc.viagem,
                                   mr_desp_terc.sequencia,
                                   mr_desp_terc.ativ,
                                   mr_desp_terc.tip_despesa,
                                   mr_desp_terc.nota_fiscal,
                                   mr_desp_terc.serie_nota_fiscal,
                                   mr_desp_terc.subserie_nf,
                                   mr_desp_terc.fornecedor,
                                   mr_desp_terc.dat_inclusao,
                                   mr_desp_terc.dat_vencto,
                                   mr_desp_terc.val_desp_terceiro,
                                   mr_desp_terc.observacao,
                                   mr_desp_terc.ad_terceiro,
                                   mr_desp_terc.viagem_origem,
                                   mr_desp_terc.controle
       WHENEVER ERROR STOP
    END WHILE
 ELSE
       WHENEVER ERROR CONTINUE
       FETCH cq_consulta_terc INTO mr_desp_terc.viagem,
                                   mr_desp_terc.sequencia,
                                   mr_desp_terc.ativ,
                                   mr_desp_terc.tip_despesa,
                                   mr_desp_terc.nota_fiscal,
                                   mr_desp_terc.serie_nota_fiscal,
                                   mr_desp_terc.subserie_nf,
                                   mr_desp_terc.fornecedor,
                                   mr_desp_terc.dat_inclusao,
                                   mr_desp_terc.dat_vencto,
                                   mr_desp_terc.val_desp_terceiro,
                                   mr_desp_terc.observacao,
                                   mr_desp_terc.ad_terceiro,
                                   mr_desp_terc.viagem_origem,
                                   mr_desp_terc.controle
       WHENEVER ERROR STOP
       LET m_ult_viag_terc = mr_desp_terc.viagem
 END IF

 IF sqlca.SQLCODE = 100 THEN
     IF l_cont = 1 THEN
       CALL log0030_mensagem('Argumentos de pesquisa n�o encontrados.','exclamation')
    END IF
    LET mr_desp_terc.* = mr_desp_tercr.*
    DISPLAY BY NAME mr_desp_terc.*
    LET m_terc_ativa = FALSE
    RETURN
 ELSE
    WHENEVER ERROR CONTINUE #Somente pula para o primeiro registro se o programa achar algum dado.
    FETCH cq_viag_terc      #Desta forma nao ira dar problema na paginacao.
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
    END IF
 END IF

 IF NOT cdv2000_carrega_ativs(mr_desp_terc.viagem) THEN
 END IF

 LET m_terc_ativa = TRUE
 CALL cdv2000_exibe_dados_desp_terc()

 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_paginacao_terc(l_funcao)
#-----------------------------------------#
  DEFINE l_funcao           CHAR(20),
         l_achou            CHAR(01),
         l_sql_stmt         CHAR(3000),
         l_sequencia        LIKE cdv_desp_terc_781.seq_desp_terceiro

  LET l_achou = 'N'
  WHILE TRUE
     IF l_funcao = "SEGUINTE" THEN
        WHENEVER ERROR CONTINUE
        FETCH NEXT cq_viag_terc INTO mr_viag_terc.viagem,
                                     mr_viag_terc.controle
        WHENEVER ERROR STOP
     ELSE
        WHENEVER ERROR CONTINUE
        FETCH PREVIOUS cq_viag_terc INTO mr_viag_terc.viagem,
                                         mr_viag_terc.controle
        WHENEVER ERROR STOP
     END IF

     IF SQLCA.SQLCODE = NOTFOUND THEN
        ERROR 'N�o existem mais itens nesta dire��o.'
        EXIT WHILE
     ELSE
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql('FETCH','cq_viag_terc')
           EXIT WHILE
        ELSE
           DISPLAY BY NAME mr_viag_terc.viagem,
                           mr_viag_terc.controle

           LET m_den_acerto = cdv2000_busca_den_acerto(mr_viag_terc.viagem)

           LET l_achou = 'S'
           EXIT WHILE
        END IF
     END IF
  END WHILE

  IF l_achou = 'S' THEN

     LET mr_desp_terc.viagem   = mr_viag_terc.viagem
     LET mr_desp_terc.controle = mr_viag_terc.controle

     LET mr_desp_tercr.* = mr_desp_terc.*

     LET l_sql_stmt = " SELECT viagem, seq_desp_terceiro, ",
                      " ativ, tip_despesa, ",
                      " nota_fiscal, serie_nota_fiscal, subserie_nf, ",
                      " fornecedor, dat_inclusao, dat_vencto, ",
                      " val_desp_terceiro, observacao, ad_terceiro, viagem_origem ",
                      " FROM cdv_desp_terc_781 ",
                      " WHERE empresa = '",p_cod_empresa,"' ",
                      " AND viagem  = ",mr_desp_terc.viagem," "



     IF mr_desp_terc.sequencia IS NOT NULL THEN
        IF l_funcao = "SEGUINTE" THEN

           LET l_sequencia = mr_desp_terc.sequencia            #Quando for viagens diferentes ele muda a sequencia
           IF m_ult_viag_terc <> mr_desp_terc.viagem THEN      #para conseguir resgatar os dados de apontamentos
              LET l_sequencia = 0                              #de terceiros
           END IF

           LET l_sql_stmt = l_sql_stmt CLIPPED,
                            " AND seq_desp_terceiro > ", l_sequencia
        ELSE

           LET l_sequencia = mr_desp_terc.sequencia            #Quando for viagens diferentes ele muda a sequencia
           IF m_ult_viag_terc <> mr_desp_terc.viagem THEN      #para conseguir resgatar os dados de apontamentos
              LET l_sequencia = 9999                           #de terceiros
           END IF

           LET l_sql_stmt = l_sql_stmt CLIPPED,
                            " AND seq_desp_terceiro < ", l_sequencia, " ",
                            " ORDER BY seq_desp_terceiro DESC "
        END IF
     END IF

     WHENEVER ERROR CONTINUE
     PREPARE var_query_terc2 FROM l_sql_stmt
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DECLARE cq_consulta_terc2 SCROLL CURSOR WITH HOLD FOR var_query_terc2
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('DECLARE','cq_consulta_terc2')
        LET mr_desp_terc.* = mr_desp_tercr.*
        DISPLAY BY NAME mr_desp_terc.*
        RETURN
     END IF

     WHENEVER ERROR CONTINUE
     OPEN cq_consulta_terc2
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('OPEN','cq_consulta_terc2')
        LET mr_desp_terc.* = mr_desp_tercr.*
        DISPLAY BY NAME mr_desp_terc.*
        RETURN
     END IF

     WHENEVER ERROR CONTINUE
      FETCH cq_consulta_terc2 INTO mr_desp_terc.viagem,
                                   mr_desp_terc.sequencia,
                                   mr_desp_terc.ativ,
                                   mr_desp_terc.tip_despesa,
                                   mr_desp_terc.nota_fiscal,
                                   mr_desp_terc.serie_nota_fiscal,
                                   mr_desp_terc.subserie_nf,
                                   mr_desp_terc.fornecedor,
                                   mr_desp_terc.dat_inclusao,
                                   mr_desp_terc.dat_vencto,
                                   mr_desp_terc.val_desp_terceiro,
                                   mr_desp_terc.observacao,
                                   mr_desp_terc.ad_terceiro,
                                   mr_desp_terc.viagem_origem
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE = 100
     {OR mr_desp_terc.viagem <> mr_viag_terc.viagem} THEN
        #IF l_cont = 2 THEN
        #   CALL log0030_mensagem('Argumentos de pesquisa n�o encontrados.','exclamation')
        #END IF
        LET mr_desp_terc.* = mr_desp_tercr.*
        INITIALIZE mr_desp_terc.* TO NULL
        LET mr_desp_terc.viagem   = mr_viag_terc.viagem
        LET mr_desp_terc.controle = mr_viag_terc.controle
        DISPLAY BY NAME mr_desp_terc.*
        LET m_terc_ativa = FALSE
        RETURN
     END IF

     LET m_ult_viag_terc = mr_desp_terc.viagem
     IF NOT cdv2000_carrega_ativs(mr_desp_terc.viagem) THEN
     END IF

     LET m_terc_ativa = TRUE
     CALL cdv2000_exibe_dados_desp_terc()
  END IF

  ##IF m_terc_ativa THEN
  #IF l_achou = 'S' THEN
  #
  #   LET mr_desp_tercr.* = mr_desp_terc.*
  #
  #   WHILE TRUE
  #      IF l_funcao = "SEGUINTE" THEN
  #         WHENEVER ERROR CONTINUE
  #          FETCH NEXT cq_consulta_terc INTO mr_desp_terc.viagem,
  #                                           mr_desp_terc.sequencia,
  #                                           mr_desp_terc.ativ,
  #                                           mr_desp_terc.tip_despesa,
  #                                           mr_desp_terc.nota_fiscal,
  #                                           mr_desp_terc.serie_nota_fiscal,
  #                                           mr_desp_terc.subserie_nf,
  #                                           mr_desp_terc.fornecedor,
  #                                           mr_desp_terc.dat_inclusao,
  #                                           mr_desp_terc.dat_vencto,
  #                                           mr_desp_terc.val_desp_terceiro,
  #                                           mr_desp_terc.observacao,
  #                                           mr_desp_terc.ad_terceiro
  #         WHENEVER ERROR STOP
  #      ELSE
  #         WHENEVER ERROR CONTINUE
  #          FETCH PREVIOUS cq_consulta_terc INTO mr_desp_terc.viagem,
  #                                               mr_desp_terc.sequencia,
  #                                               mr_desp_terc.ativ,
  #                                               mr_desp_terc.tip_despesa,
  #                                               mr_desp_terc.nota_fiscal,
  #                                               mr_desp_terc.serie_nota_fiscal,
  #                                               mr_desp_terc.subserie_nf,
  #                                               mr_desp_terc.fornecedor,
  #                                               mr_desp_terc.dat_inclusao,
  #                                               mr_desp_terc.dat_vencto,
  #                                               mr_desp_terc.val_desp_terceiro,
  #                                               mr_desp_terc.observacao,
  #                                               mr_desp_terc.ad_terceiro
  #         WHENEVER ERROR STOP
  #      END IF
  #
  #      IF SQLCA.SQLCODE = NOTFOUND THEN
  #         ERROR 'N�o existem mais itens nesta dire��o.'
  #         EXIT WHILE
  #      ELSE
  #         IF SQLCA.SQLCODE <> 0 THEN
  #            CALL log003_err_sql('FETCH','cq_consulta_terc')
  #            EXIT WHILE
  #         ELSE
  #            WHENEVER ERROR CONTINUE
  #             SELECT viagem
  #               FROM cdv_desp_terc_781
  #              WHERE empresa = p_cod_empresa
  #                AND viagem  = mr_desp_terc.viagem
  #                AND seq_desp_terceiro= mr_desp_terc.sequencia
  #            WHENEVER ERROR STOP
  #            IF SQLCA.SQLCODE = 0 THEN
  #               INITIALIZE m_den_acerto TO NULL
  #
  #               LET m_den_acerto = cdv2000_busca_den_acerto(mr_desp_terc.viagem)
  #
  #               CALL cdv2000_exibe_dados_desp_terc()
  #               EXIT WHILE
  #            END IF
  #         END IF
  #      END IF
  #   END WHILE
  #ELSE
  #   CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
  #END IF

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_manutencao_ads(l_faz_pergunta)
#-----------------------------------------------#
  DEFINE l_faz_pergunta    CHAR(01),
         l_resp            CHAR(01)

  IF l_faz_pergunta = 'S' THEN
     WHILE TRUE
        PROMPT 'Deseja incluir AD (cap0220) para a despesa informada ? (S/N)'
           FOR CHAR l_resp
        IF UPSHIFT(l_resp) = 'N' OR UPSHIFT(l_resp) = 'S' THEN
           EXIT WHILE
        END IF
     END WHILE
  END IF

  IF UPSHIFT(l_resp) = 'S' OR l_faz_pergunta = 'N' THEN
     CALL log120_procura_caminho("cap0220")
        RETURNING m_caminho

     IF mr_desp_terc.ad_terceiro IS NULL THEN
        LET m_caminho = m_caminho CLIPPED, " "
     ELSE
        LET m_caminho = m_caminho CLIPPED, " ",mr_desp_terc.ad_terceiro,
                                             " ",p_cod_empresa
     END IF
     RUN m_caminho
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_entrada_desp_terc(l_funcao)
#--------------------------------------------#
  DEFINE l_funcao              CHAR(11),
         l_status              SMALLINT,
         l_msg                 CHAR(200)

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv20004

  IF l_funcao <> 'MODIFICACAO' THEN
     INITIALIZE mr_desp_terc.ad_terceiro,    mr_desp_terc.previsao,
                mr_desp_terc.ap_terceiro,    mr_desp_terc.sequencia,
                mr_desp_terc.ativ,           mr_desp_terc.des_ativ,
                mr_desp_terc.tip_despesa,    mr_desp_terc.des_tip_despesa,
                mr_desp_terc.nota_fiscal,    mr_desp_terc.serie_nota_fiscal,
                mr_desp_terc.subserie_nf,    mr_desp_terc.fornecedor,
                mr_desp_terc.den_fornecedor, mr_desp_terc.dat_inclusao,
                mr_desp_terc.dat_vencto,     mr_desp_terc.val_desp_terceiro,
                mr_desp_terc.observacao,     mr_desp_terc.tot_desp_terceiro TO NULL
     CLEAR FORM

     DISPLAY p_cod_empresa TO empresa
     LET mr_desp_terc.tot_desp_terceiro = 0
     DISPLAY BY NAME mr_desp_terc.tot_desp_terceiro
  END IF

  #LET mr_desp_terc.viagem   = mr_input.viagem
  #LET mr_desp_terc.controle = mr_input.controle

  IF mr_viag_terc.viagem IS NOT NULL
  AND mr_viag_terc.viagem <> 0 THEN
     LET mr_desp_terc.viagem   = mr_viag_terc.viagem
  END IF
  IF mr_viag_terc.controle IS NOT NULL THEN
     LET mr_desp_terc.controle = mr_viag_terc.controle
  END IF

  IF  m_origem = 'S'
  AND l_funcao = 'INCLUSAO' THEN
     LET mr_desp_terc.viagem = cdv2000_procura_viagem_terc(mr_input.viagem)

     IF mr_desp_terc.viagem = 0 THEN
        LET mr_desp_terc.viagem        = cdv2000_carrega_numero_viagem()
     END IF

     LET mr_desp_terc.viagem_origem = mr_input.viagem
  END IF

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_desp_terc.* WITHOUT DEFAULTS
     BEFORE INPUT
        IF mr_desp_terc.viagem_origem IS NULL
        OR mr_desp_terc.viagem_origem = 0 THEN
           LET mr_desp_terc.viagem_origem = cdv2000_procura_viagem_origem(mr_desp_terc.viagem)
           DISPLAY BY NAME mr_desp_terc.viagem_origem
        END IF

        IF m_origem = 'N' THEN
           IF NOT cdv2000_carrega_ativs(mr_desp_terc.viagem) THEN
           END IF
        ELSE
           IF NOT cdv2000_carrega_ativs(mr_desp_terc.viagem_origem) THEN
           END IF
        END IF

     BEFORE FIELD controle
        IF l_funcao = 'MODIFICACAO' THEN
           NEXT FIELD ativ
        END IF

        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_desp_terc.controle IS NOT NULL THEN
           IF NOT cdv2000_valida_controle_ativo(mr_desp_terc.controle, mr_desp_terc.viagem) THEN
              CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
              NEXT FIELD controle
           END IF
        END IF

     BEFORE FIELD viagem
        IF l_funcao = 'MODIFICACAO' THEN
           NEXT FIELD ativ
        END IF

        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

        IF mr_desp_terc.controle IS NOT NULL
        AND (mr_desp_terc.viagem IS NULL
             OR mr_desp_terc.viagem = 0 ) THEN
           LET mr_desp_terc.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_terc.controle)
           DISPLAY BY NAME mr_desp_terc.viagem
        END IF

     AFTER FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF mr_desp_terc.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_desp_terc.viagem, mr_desp_terc.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF

              LET mr_desp_terc.tot_desp_terceiro = cdv2000_recupera_tot_desp_terc(mr_desp_terc.viagem)
              DISPLAY BY NAME mr_desp_terc.tot_desp_terceiro
           ELSE
              IF mr_desp_terc.controle IS NULL THEN
                 #CALL log0030_mensagem('Informe o controle e/ou viagem a qual as despesas se referem.','exclamation')
                 #NEXT FIELD controle
              ELSE
                 LET mr_desp_terc.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_terc.controle)
                 IF mr_desp_terc.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_terc.viagem
                 END IF
              END IF
           END IF
           IF l_funcao = 'CONSULTA' THEN
              EXIT INPUT
           END IF
        END IF

     BEFORE FIELD ativ
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
           DISPLAY '( Zoom )' AT 3,68
        END IF

        IF ma_atividades[2].ativ IS NULL THEN
           LET mr_desp_terc.ativ = ma_atividades[1].ativ
           DISPLAY BY NAME mr_desp_terc.ativ
        END IF
#---------

     AFTER FIELD ativ
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.ativ IS NOT NULL THEN
                 CALL cdv2000_valida_ativ(mr_desp_terc.ativ)
                    RETURNING l_status, mr_desp_terc.des_ativ
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.des_ativ
                 ELSE
                    NEXT FIELD ativ
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe a atividade relacionada � despesa.','exclamation')
                 NEXT FIELD ativ
              END IF
           END IF
        END IF

     BEFORE FIELD tip_despesa
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD tip_despesa
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.tip_despesa IS NOT NULL THEN
                 CALL cdv2000_valida_tipo_despesa(mr_desp_terc.tip_despesa, 'TERC', 0, mr_desp_terc.ativ)
                    RETURNING l_status, mr_desp_terc.des_tip_despesa
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.des_tip_despesa
                 ELSE
                    NEXT FIELD tip_despesa
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o tipo de despesa para a despesa de terceiros.','exclamation')
                 NEXT FIELD tip_despesa
              END IF
           END IF
        END IF

     AFTER FIELD nota_fiscal
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.nota_fiscal IS NULL THEN
                 CALL log0030_mensagem('Informe a nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD nota_fiscal
              END IF
           END IF
        END IF

     AFTER FIELD serie_nota_fiscal
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.serie_nota_fiscal IS NULL THEN
                 CALL log0030_mensagem('Informe s�rie da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD serie_nota_fiscal
              END IF
           END IF
        END IF

     AFTER FIELD subserie_nf
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.subserie_nf IS NULL THEN
                 CALL log0030_mensagem('Informe sub-s�rie da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD subserie_nf
              END IF
           END IF
        END IF

     AFTER FIELD fornecedor
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.fornecedor IS NOT NULL THEN
                 CALL cdv2000_valida_fornecedor(mr_desp_terc.fornecedor)
                    RETURNING l_status, mr_desp_terc.den_fornecedor
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.den_fornecedor
                 ELSE
                    NEXT FIELD fornecedor
                 END IF

                 IF NOT cdv2000_valida_documento_existente(mr_desp_terc.nota_fiscal, mr_desp_terc.serie_nota_fiscal,
                                                           mr_desp_terc.subserie_nf, mr_desp_terc.fornecedor) THEN
                    LET l_msg = "Numero do documento ", mr_desp_terc.nota_fiscal USING "<<<<<<<", "-",mr_desp_terc.serie_nota_fiscal CLIPPED," ja existente no contas a pagar."
                    CALL log0030_mensagem(l_msg,"exclamation")
                    NEXT FIELD fornecedor
                 END IF

              ELSE
                 CALL log0030_mensagem('Informe o fornecedor da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD fornecedor
              END IF
           END IF
        END IF

     BEFORE FIELD dat_inclusao
        IF m_origem = 'N' THEN
           LET mr_desp_terc.dat_inclusao = cdv2000_busca_data_viagem(mr_desp_terc.viagem)
        ELSE
           LET mr_desp_terc.dat_inclusao = cdv2000_busca_data_viagem(mr_desp_terc.viagem_origem)
        END IF
        DISPLAY BY NAME mr_desp_terc.dat_inclusao

     AFTER FIELD dat_inclusao
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.dat_inclusao IS NOT NULL THEN
                 IF m_origem = 'N' THEN
                    IF NOT cdv2000_verifica_data_viagem(mr_desp_terc.viagem,
                                                        mr_desp_terc.dat_inclusao) THEN
                       CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                       NEXT FIELD dat_inclusao
                    END IF
                 ELSE
                    IF NOT cdv2000_verifica_data_viagem(mr_desp_terc.viagem_origem,
                                                        mr_desp_terc.dat_inclusao) THEN
                       CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                       NEXT FIELD dat_inclusao
                    END IF
                 END IF
              ELSE
                 IF m_origem = 'N' THEN
                    LET mr_desp_terc.dat_inclusao = cdv2000_busca_data_viagem(mr_desp_terc.viagem)
                 ELSE
                    LET mr_desp_terc.dat_inclusao = cdv2000_busca_data_viagem(mr_desp_terc.viagem_origem)
                 END IF

                 DISPLAY BY NAME mr_desp_terc.dat_inclusao
              END IF
           END IF
        END IF

     AFTER FIELD dat_vencto
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.dat_vencto IS NULL THEN
                 CALL log0030_mensagem('Informe a data vencimento da despesa de terceiros.','exclamation')
                 NEXT FIELD dat_vencto
              ELSE
                 IF mr_desp_terc.dat_vencto < mr_desp_terc.dat_inclusao THEN
                    CALL log0030_mensagem('Data de vencimento n�o pode ser inferior a data de inclus�o.','exclamation')
                    NEXT FIELD dat_vencto
                 END IF
              END IF
           END IF
        END IF

     AFTER FIELD val_desp_terceiro
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.val_desp_terceiro IS NOT NULL THEN
                 IF mr_desp_terc.val_desp_terceiro <= 0 THEN
                    CALL log0030_mensagem('Valor da despesa deve ser maior que 0 (zero).','exclamation')
                    NEXT FIELD val_desp_terceiro
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o valor da despesa.','exclamation')
                 NEXT FIELD val_desp_terceiro
              END IF
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF l_funcao <> 'CONSULTA' THEN
              IF NOT log0040_confirm(19,34,"Confirma dados informados?") THEN
                 NEXT FIELD ativ
              END IF
           END IF

           IF mr_desp_terc.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_ativo(mr_desp_terc.controle, mr_desp_terc.viagem) THEN
                 CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF

           IF mr_desp_terc.viagem IS NOT NULL THEN
              #IF NOT cdv2000_valida_viagem_ativa(mr_desp_terc.viagem, mr_desp_terc.controle) THEN
              #   CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
              #   NEXT FIELD viagem
              #END IF
           ELSE
              IF mr_desp_terc.controle IS NULL THEN
              ELSE
                 IF mr_desp_terc.viagem IS NULL
                 OR mr_desp_terc.viagem = 0 THEN
                    LET mr_desp_terc.viagem = cdv2000_recupera_viagem_por_controle(mr_desp_terc.controle)
                 END IF
                 IF mr_desp_terc.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_desp_terc.viagem
                 END IF
              END IF
           END IF

           IF l_funcao <> 'CONSULTA' THEN
              IF mr_desp_terc.ativ IS NOT NULL THEN
                 CALL cdv2000_valida_ativ(mr_desp_terc.ativ)
                    RETURNING l_status, mr_desp_terc.des_ativ
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.des_ativ
                 ELSE
                    NEXT FIELD ativ
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe a atividade relacionada � despesa.','exclamation')
                 NEXT FIELD ativ
              END IF

              IF mr_desp_terc.tip_despesa IS NOT NULL THEN
                 CALL cdv2000_valida_tipo_despesa(mr_desp_terc.tip_despesa, 'TERC', 0, mr_desp_terc.ativ)
                    RETURNING l_status, mr_desp_terc.des_tip_despesa
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.des_tip_despesa
                 ELSE
                    NEXT FIELD tip_despesa
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o tipo de despesa para a despesa de terceiros.','exclamation')
                 NEXT FIELD tip_despesa
              END IF

              IF mr_desp_terc.nota_fiscal IS NULL THEN
                 CALL log0030_mensagem('Informe a nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD nota_fiscal
              END IF

              IF mr_desp_terc.serie_nota_fiscal IS NULL THEN
                 CALL log0030_mensagem('Informe s�rie da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD serie_nota_fiscal
              END IF

              IF mr_desp_terc.subserie_nf IS NULL THEN
                 CALL log0030_mensagem('Informe sub-s�rie da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD subserie_nf
              END IF

              IF mr_desp_terc.fornecedor IS NOT NULL THEN
                 CALL cdv2000_valida_fornecedor(mr_desp_terc.fornecedor)
                    RETURNING l_status, mr_desp_terc.den_fornecedor
                 IF l_status THEN
                    DISPLAY BY NAME mr_desp_terc.den_fornecedor
                 ELSE
                    NEXT FIELD fornecedor
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o fornecedor da nota fiscal relacionada � despesa de terceiros.','exclamation')
                 NEXT FIELD fornecedor
              END IF

              IF NOT cdv2000_valida_documento_existente(mr_desp_terc.nota_fiscal, mr_desp_terc.serie_nota_fiscal,
                                                        mr_desp_terc.subserie_nf, mr_desp_terc.fornecedor) THEN
                 LET l_msg = "Numero do documento ", mr_desp_terc.nota_fiscal USING "<<<<<<<", "-",mr_desp_terc.serie_nota_fiscal CLIPPED," ja existente no contas a pagar."
                 CALL log0030_mensagem(l_msg,"exclamation")
                 NEXT FIELD fornecedor
              END IF

              IF mr_desp_terc.dat_inclusao IS NOT NULL THEN
                 IF m_origem = 'N' THEN
                    IF NOT cdv2000_verifica_data_viagem(mr_desp_terc.viagem,
                                                        mr_desp_terc.dat_inclusao) THEN
                       CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                       NEXT FIELD dat_inclusao
                    END IF
                 ELSE
                    IF NOT cdv2000_verifica_data_viagem(mr_desp_terc.viagem_origem,
                                                        mr_desp_terc.dat_inclusao) THEN
                       CALL log0030_mensagem('Data informada n�o corresponde ao per�odo da viagem.','exclamation')
                       NEXT FIELD dat_inclusao
                    END IF
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe a data de Inclus�o da despesa de terceiros.','exclamation')
                 NEXT FIELD dat_inclusao
              END IF

              IF mr_desp_terc.val_desp_terceiro IS NOT NULL THEN
                 IF mr_desp_terc.val_desp_terceiro <= 0 THEN
                    CALL log0030_mensagem('Valor da despesa deve ser maior que 0 (zero).','exclamation')
                    NEXT FIELD val_desp_terceiro
                 END IF
              ELSE
                 CALL log0030_mensagem('Informe o valor da despesa.','exclamation')
                 NEXT FIELD val_desp_terceiro
              END IF

              IF mr_desp_terc.observacao IS NULL THEN
                 CALL log0030_mensagem('Informe a observa��o da despesa.','exclamation')
                 NEXT FIELD observacao
              END IF

              IF l_funcao <> 'INCLUSAO' THEN
                 IF mr_desp_terc.val_desp_terceiro <> mr_desp_tercr.val_desp_terceiro THEN
                    LET mr_desp_terc.tot_desp_terceiro = mr_desp_terc.tot_desp_terceiro + (mr_desp_terc.val_desp_terceiro - mr_desp_tercr.val_desp_terceiro)
                 END IF
              ELSE
                 LET mr_desp_terc.tot_desp_terceiro = mr_desp_terc.tot_desp_terceiro + mr_desp_terc.val_desp_terceiro
              END IF
              DISPLAY BY NAME mr_desp_terc.tot_desp_terceiro
           END IF

           LET mr_desp_terc.ad_terceiro = cdv2000_retorna_ad_por_dados_nf(mr_desp_terc.nota_fiscal,
                                                                          mr_desp_terc.serie_nota_fiscal,
                                                                          mr_desp_terc.subserie_nf,
                                                                          mr_desp_terc.fornecedor)
           IF mr_desp_terc.ad_terceiro IS NOT NULL THEN
              LET mr_desp_terc.previsao = cdv2000_recupera_ind_previsao(mr_desp_terc.ad_terceiro)
              IF mr_desp_terc.previsao = 'N' THEN
                 #CALL log0030_mensagem('AD relacionada a NF informada n�o � de previs�o.','exclamation')
                 INITIALIZE mr_desp_terc.ad_terceiro, mr_desp_terc.previsao TO NULL
              ELSE
                 CALL cdv2000_recupera_primeira_ap(mr_desp_terc.ad_terceiro)
                    RETURNING l_status, mr_desp_terc.ap_terceiro
              END IF
              DISPLAY BY NAME mr_desp_terc.ad_terceiro, mr_desp_terc.previsao, mr_desp_terc.ap_terceiro
           ELSE
              IF SQLCA.SQLCODE <> 100 THEN
                 CALL log003_err_sql('SELECT','ad_mestre')
              END IF
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup('TERC')

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv20004

  RETURN NOT INT_FLAG

END FUNCTION

#----------------------------------#
 FUNCTION cdv2000_popup_ativ()
#----------------------------------#
  DEFINE where_clause       CHAR(500),
         l_ind              SMALLINT,
         l_ativ             LIKE cdv_ativ_781.ativ

  IF ma_atividades[1].ativ IS NOT NULL THEN
     FOR l_ind = 1 TO 200
        IF ma_atividades[l_ind].ativ IS NULL THEN
           LET where_clause = where_clause CLIPPED, ')'
           EXIT FOR
        END IF
        IF l_ind = 1 THEN
           LET where_clause = ' ativ IN (',ma_atividades[l_ind].ativ
        ELSE
           LET where_clause = where_clause CLIPPED, ', ',ma_atividades[l_ind].ativ
        END IF
     END FOR

     LET l_ativ = log009_popup(07,05,          -- Linha/Coluna da Janela
                               "ATIVIDADES",   -- Cabecalho da Janela
                               "cdv_ativ_781", -- Nome da Tabela no Sistema
                               "ativ",         -- Nome da Primeira Coluna
                               "des_ativ",     -- Nome da Segunda  Coluna
                               "cdv2006",      -- Nome do Prog.Manutencao
                               "N",            -- Testa cod_empresa (S/N) ?
                               where_clause)   -- Where Clause do Select
  ELSE
     CALL log0030_mensagem('A finalidade da viagem n�o possui nenhuma atividade relacionada.','exclamation')
  END IF

  RETURN l_ativ

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_valida_fornecedor(l_fornecedor)
#------------------------------------------------#
  DEFINE l_status              SMALLINT,
         l_fornecedor          LIKE fornecedor.cod_fornecedor,
         l_den_fornecedor      CHAR(30)

  WHENEVER ERROR CONTINUE
   SELECT raz_social
     INTO l_den_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = l_fornecedor
  WHENEVER ERROR STOP
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE, l_den_fornecedor
     WHEN 100
        CALL log0030_mensagem('Fornecedor n�o cadastrado.','exclamation')
        RETURN FALSE, l_den_fornecedor
     OTHERWISE
        CALL log003_err_sql('SELECT','fornecedor')
        RETURN FALSE, l_den_fornecedor
  END CASE

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2000_recupera_tot_desp_terc(l_viagem)
#-----------------------------------------------------#
  DEFINE l_viagem         LIKE cdv_acer_viag_781.viagem,
         l_tot_desp_terceiro  LIKE cdv_desp_terc_781.val_desp_terceiro

  WHENEVER ERROR CONTINUE
   SELECT SUM(val_desp_terceiro)
     INTO l_tot_desp_terceiro
     FROM cdv_desp_terc_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_desp_terc_781')
     RETURN 0
  END IF

  IF l_tot_desp_terceiro IS NULL THEN
     LET l_tot_desp_terceiro = 0
  END IF

  RETURN l_tot_desp_terceiro

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2000_exibe_dados_desp_terc()
#----------------------------------------#
  DEFINE l_status     SMALLINT

  LET mr_desp_terc.controle = cdv2000_recupera_controle(mr_desp_terc.viagem)

  IF mr_desp_terc.ad_terceiro IS NOT NULL THEN
     LET mr_desp_terc.previsao = cdv2000_recupera_ind_previsao(mr_desp_terc.ad_terceiro)

     CALL cdv2000_recupera_primeira_ap(mr_desp_terc.ad_terceiro)
        RETURNING l_status, mr_desp_terc.ap_terceiro
  ELSE
     INITIALIZE mr_desp_terc.previsao, mr_desp_terc.ap_terceiro TO NULL
  END IF

  CALL cdv2000_valida_ativ(mr_desp_terc.ativ)
     RETURNING l_status, mr_desp_terc.des_ativ

  CALL cdv2000_valida_tipo_despesa(mr_desp_terc.tip_despesa, 'TERC', 0, mr_desp_terc.ativ)
     RETURNING l_status, mr_desp_terc.des_tip_despesa

  CALL cdv2000_valida_fornecedor(mr_desp_terc.fornecedor)
     RETURNING l_status, mr_desp_terc.den_fornecedor

  LET mr_desp_terc.tot_desp_terceiro = cdv2000_recupera_tot_desp_terc(mr_desp_terc.viagem)

  DISPLAY BY NAME mr_desp_terc.*

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_recupera_controle(l_viagem)
#------------------------------------------#
  DEFINE l_controle      LIKE cdv_acer_viag_781.controle,
         l_viagem        LIKE cdv_acer_viag_781.viagem

  INITIALIZE l_controle TO NULL

  WHENEVER ERROR CONTINUE
   SELECT controle
     INTO l_controle
     FROM w_solic
    WHERE viagem = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','w_solic')
  END IF

  RETURN l_controle

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_cursor_for_update_desp_terc()
#----------------------------------------------#

  WHENEVER ERROR CONTINUE
   DECLARE cm_desp_terc CURSOR FOR
    SELECT empresa
      FROM cdv_desp_terc_781
     WHERE empresa           = p_cod_empresa
       AND viagem            = mr_desp_terc.viagem
       AND seq_desp_terceiro = mr_desp_terc.sequencia
   FOR UPDATE
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cm_desp_terc')
     RETURN FALSE
  END IF

  CALL log085_transacao("BEGIN")

  WHENEVER ERROR CONTINUE
   OPEN cm_desp_terc
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('OPEN','cm_desp_terc')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FETCH cm_desp_terc
  WHENEVER ERROR STOP

  CASE SQLCA.SQLCODE
    WHEN 0
       RETURN TRUE
    WHEN -250
       CALL log0030_mensagem('Registro sendo atualizado por outro usu�rio. Aguarde e tente novamente.','exclamation')
    WHEN 100
       CALL log0030_mensagem('Registro n�o existe ou n�o esta liberado. Execute a CONSULTA novamente.','exclamation')
    OTHERWISE
       CALL log003_err_sql("LEITURA","cdv_desp_terc_781")
  END CASE

  CALL log085_transacao("ROLLBACK")

  CLOSE cm_desp_terc
  FREE cm_desp_terc

  RETURN FALSE

END FUNCTION

#-------------------------------#
 FUNCTION cdv2000_exibe_resumo()
#-------------------------------#

  CALL log006_exibe_teclas('01', p_versao)

  LET m_caminho = log1300_procura_caminho('cdv20005','cdv20005')
  OPEN WINDOW w_cdv20005 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  LET m_resumo_ativo = FALSE

  CALL cdv2000_consulta_previa()

  MENU 'RESUMO'
     BEFORE MENU
        CALL cdv2000_carrega_resumo_ja_informados(mr_input.viagem, mr_input.controle, 1)
        LET mr_resumo.viagem   = mr_input.viagem
        LET mr_resumo.controle = mr_input.controle
        DISPLAY BY NAME mr_resumo.*

     #COMMAND 'Consultar' 'Pesquisa resumo.'
     #   HELP 004
     #   MESSAGE ''
     #   IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'CO') THEN
     #      CALL cdv2000_consulta_resumo()
     #   END IF

    COMMAND "Seguinte"   "Exibe o pr�ximo acerto encontrado na consulta."
      HELP 005
      MESSAGE ""
      CALL cdv2000_paginacao_resumo("SEGUINTE")

    COMMAND "Anterior"   "Exibe o acerto anterior encontrado na consulta."
      HELP 006
      MESSAGE ""
      CALL cdv2000_paginacao_resumo("ANTERIOR")

     COMMAND KEY ('!')
        PROMPT 'Digite o m_comando : ' FOR m_comando
        RUN m_comando
        PROMPT '\nTecle ENTER para continuar' FOR CHAR m_comando

     COMMAND 'Fim'       'Retorna ao menu anterior.'
        HELP 008
        EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv20005
  CURRENT WINDOW IS w_cdv2000

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION cdv2000_carrega_resumo_ja_informados(l_viagem, l_controle, l_cont)
#----------------------------------------------------------------------------#
 DEFINE sql_stmt       CHAR(1000),
        l_dat_partida  CHAR(19),
        l_dat_retorno  CHAR(19),
        l_viagem       LIKE cdv_acer_viag_781.viagem,
        l_controle     LIKE cdv_acer_viag_781.controle,
        l_cont         SMALLINT

 IF l_cont = 2 THEN
    LET sql_stmt = 'SELECT viagem, controle, viajante, cliente_debitar,',
                         ' dat_hor_partida, dat_hor_retorno, cc_debitar,',
                         ' finalidade_viagem',
                    ' FROM cdv_acer_viag_781',
                   ' WHERE empresa = "',p_cod_empresa,'"'

    IF l_controle IS NOT NULL THEN
       LET sql_stmt = sql_stmt CLIPPED, ' AND controle = "',l_controle,'"'
    END IF
    IF l_viagem IS NOT NULL THEN
       LET sql_stmt = sql_stmt CLIPPED, ' AND viagem = ',l_viagem
    END IF
 ELSE
   LET sql_stmt = 'SELECT viagem, controle, viajante, cliente_debitar,',
                         ' dat_hor_partida, dat_hor_retorno, cc_debitar,',
                         ' finalidade_viagem',
                    ' FROM cdv_acer_viag_781',
                   ' WHERE empresa = "',p_cod_empresa,'"',
                   ' AND viagem IN (SELECT viagem FROM w_solic) '
 END IF

 WHENEVER ERROR CONTINUE
  PREPARE var_resumo FROM sql_stmt
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('PREPARE','var_resumo')
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_resumo SCROLL CURSOR WITH HOLD FOR var_resumo
 WHENEVER ERROR STOP
 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('DECLARE','cq_resumo')
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  OPEN cq_resumo
 WHENEVER ERROR STOP
 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql('OPEN','cq_resumo')
    RETURN
 END IF

 WHILE TRUE
    WHENEVER ERROR CONTINUE
     FETCH cq_resumo INTO mr_resumo.viagem,
                          mr_resumo.controle,
                          mr_resumo.viajante,
                          mr_resumo.cliente_debitar,
                          l_dat_partida,
                          l_dat_retorno,
                          mr_resumo.cc_debitar,
                          mr_resumo.finalidade_viagem
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE = 100 THEN
       IF l_cont = 2 THEN
          CALL log0030_mensagem('Argumentos de pesquisa n�o encontrados.','exclamation')
       END IF
       RETURN
    END IF

    IF mr_resumo.viagem = mr_input.viagem THEN
       EXIT WHILE
    END IF

 END WHILE

 LET m_resumo_ativo = TRUE

 CALL cdv2000_exibe_dados_resumo(l_dat_partida, l_dat_retorno)

 END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_entrada_dados_resumo()
#---------------------------------------#

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv20005

  INITIALIZE mr_resumo.* TO NULL
  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_resumo.* WITHOUT DEFAULTS

     BEFORE FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD controle
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_resumo.controle IS NOT NULL THEN
           IF NOT cdv2000_valida_controle_ativo(mr_resumo.controle, mr_resumo.viagem) THEN
              CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
              NEXT FIELD controle
           END IF
        END IF

     BEFORE FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

        IF mr_resumo.controle IS NOT NULL THEN
           LET mr_resumo.viagem = cdv2000_recupera_viagem_por_controle(mr_resumo.controle)
           DISPLAY BY NAME mr_resumo.viagem
        END IF

     AFTER FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF
        IF NOT (FGL_LASTKEY() = FGL_KEYVAL("UP") OR
                FGL_LASTKEY() = FGL_KEYVAL("LEFT")) THEN

           IF mr_resumo.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_resumo.viagem, mr_resumo.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_resumo.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           IF mr_resumo.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_ativo(mr_resumo.controle, mr_resumo.viagem) THEN
                 CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF

           IF mr_resumo.viagem IS NOT NULL THEN
              IF NOT cdv2000_valida_viagem_ativa(mr_resumo.viagem, mr_resumo.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_resumo.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem.','exclamation')
                 NEXT FIELD controle
              ELSE
                 LET mr_resumo.viagem = cdv2000_recupera_viagem_por_controle(mr_resumo.controle)
                 IF mr_resumo.viagem IS NULL THEN
                    CALL log0030_mensagem('informe o n�mero da viagem.','exclamation')
                    NEXT FIELD viagem
                 ELSE
                    DISPLAY BY NAME mr_resumo.viagem
                 END IF
              END IF
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()
     ON KEY (control-z, f4)
        CALL cdv2000_popup("RESUMO")

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv20005

  RETURN NOT INT_FLAG

END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION cdv2000_exibe_dados_resumo(l_dat_partida, l_dat_retorno)
#-----------------------------------------------------------------#
  DEFINE l_status       SMALLINT,
         l_dat_partida  CHAR(19),
         l_dat_retorno  CHAR(19),
         l_data         LIKE cdv_dev_transf_781.dat_devolucao

  LET mr_resumo.dat_partida = l_dat_partida[9,10],"/",l_dat_partida[6,7],"/",l_dat_partida[1,4]
  LET mr_resumo.dat_retorno = l_dat_retorno[9,10],"/",l_dat_retorno[6,7],"/",l_dat_retorno[1,4]

  CALL cdv2000_valida_viajante(mr_resumo.viajante)
     RETURNING l_status, mr_resumo.nom_viajante

  CALL cdv2000_valida_cliente(mr_resumo.cliente_debitar, "S")
     RETURNING l_status, mr_resumo.des_cli_debitar

  CALL cdv2000_valida_finalidade(mr_resumo.finalidade_viagem)
     RETURNING l_status, mr_resumo.des_fin_viagem

  CALL cdv2000_recupera_total_despesas_km(mr_resumo.viagem, '3')
     RETURNING l_status, mr_resumo.tot_km_semanal

  CALL cdv2000_recupera_qtd_km_despesas_km(mr_resumo.viagem, '3')
     RETURNING l_status, mr_resumo.qtd_km_semanal

  CALL cdv2000_recupera_qtd_hor_despesas_km(mr_resumo.viagem, '5')
     RETURNING l_status, mr_resumo.qtd_hor_semanal

  CALL cdv2000_recupera_total_terceiros(mr_resumo.viagem)
     RETURNING l_status, mr_resumo.tot_terceiros

  CALL cdv2000_recupera_total_adiantamentos(mr_resumo.viagem)
     RETURNING l_status, mr_resumo.tot_adtos

  CALL cdv2000_recupera_total_urbanas(mr_resumo.viagem)
     RETURNING l_status, mr_resumo.tot_desp_urbanas

  CALL cdv2000_recupera_total_despesas_km(mr_resumo.viagem, '2')
     RETURNING l_status, mr_resumo.tot_desp_km

  LET mr_resumo.tot_despesas = mr_resumo.tot_desp_urbanas + mr_resumo.tot_desp_km

  IF mr_resumo.tot_despesas > mr_resumo.tot_adtos THEN
     LET mr_resumo.saldo = mr_resumo.tot_despesas - mr_resumo.tot_adtos
      DISPLAY 'Saldo a receber da empresa:'   AT 19,33
  ELSE
     LET mr_resumo.saldo = mr_resumo.tot_adtos - mr_resumo.tot_despesas
      DISPLAY 'Saldo a restituir � empresa:'   AT 19,32
  END IF

  CALL cdv2000_recupera_dados_transf(mr_resumo.viagem)
     RETURNING mr_resumo.saldo_transf, mr_resumo.controle_receb,
               mr_resumo.viagem_receb, mr_resumo.dat_dev_transf

  DISPLAY BY NAME mr_resumo.*

END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2000_paginacao_resumo(l_funcao)
#-------------------------------------------#
  DEFINE l_funcao       CHAR(20),
         l_dat_partida  CHAR(19),
         l_dat_retorno  CHAR(19)

  IF m_resumo_ativo THEN
     LET mr_resumor.* = mr_resumo.*
     INITIALIZE mr_resumo.* TO NULL

     WHILE TRUE
        IF l_funcao = "SEGUINTE" THEN
           WHENEVER ERROR CONTINUE
            FETCH NEXT cq_resumo INTO mr_resumo.viagem,
                                      mr_resumo.controle,
                                      mr_resumo.viajante,
                                      mr_resumo.cliente_debitar,
                                      l_dat_partida,
                                      l_dat_retorno,
                                      mr_resumo.cc_debitar,
                                      mr_resumo.finalidade_viagem
           WHENEVER ERROR STOP
        ELSE
           WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_resumo INTO mr_resumo.viagem,
                                          mr_resumo.controle,
                                          mr_resumo.viajante,
                                          mr_resumo.cliente_debitar,
                                          l_dat_partida,
                                          l_dat_retorno,
                                          mr_resumo.cc_debitar,
                                          mr_resumo.finalidade_viagem
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR 'N�o existem mais itens nesta dire��o.'
           EXIT WHILE
        ELSE
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql('FETCH','cq_resumo')
           END IF
           CALL cdv2000_exibe_dados_resumo(l_dat_partida, l_dat_retorno)
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     CALL log0030_mensagem('N�o existe nenhuma consulta ativa.','exclamation')
  END IF

END FUNCTION

#------------------------------------------------------------#
 FUNCTION cdv2000_recupera_total_despesas_km(l_viagem, l_grp)
#------------------------------------------------------------#
  DEFINE l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_tot_km_semanal   DECIMAL(17,2),
         l_grp              LIKE cdv_tdesp_viag_781.grp_despesa_viagem

  LET l_tot_km_semanal = 0
  WHENEVER ERROR CONTINUE
   SELECT SUM(km.val_km)
     INTO l_tot_km_semanal
     FROM cdv_despesa_km_781 km, cdv_tdesp_viag_781 td
    WHERE km.empresa            = p_cod_empresa
      AND km.viagem             = l_viagem
      AND td.empresa            = km.empresa
      AND td.tip_despesa_viagem = km.tip_despesa_viagem
      AND km.ativ_km            = td.ativ
      AND td.grp_despesa_viagem = l_grp
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','km/td')
     RETURN FALSE, l_tot_km_semanal
  END IF

  IF l_tot_km_semanal IS NULL THEN
     LET l_tot_km_semanal = 0
  END IF

  RETURN TRUE, l_tot_km_semanal

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2000_recupera_dados_transf(l_viagem)
#------------------------------------------------#
  DEFINE l_viagem            LIKE cdv_acer_viag_781.viagem,
         l_val_transf        LIKE cdv_dev_transf_781.val_transf,
         l_controle_receb    LIKE cdv_acer_viag_781.controle,
         l_viagem_receb      LIKE cdv_acer_viag_781.viagem,
         l_status            LIKE cdv_dev_transf_781.eh_status_acerto,
         l_dat_devolucao     LIKE cdv_dev_transf_781.dat_devolucao,
         l_dat_transferencia LIKE cdv_dev_transf_781.dat_transf,
         l_data_retorno      LIKE cdv_dev_transf_781.dat_transf

  LET l_val_transf = 0
  INITIALIZE l_controle_receb, l_viagem_receb, l_data_retorno, l_dat_transferencia,
             l_dat_devolucao TO NULL

  WHENEVER ERROR CONTINUE
   SELECT val_transf, controle_receb, viagem_receb, eh_status_acerto,
          dat_devolucao, dat_transf
     INTO l_val_transf, l_controle_receb, l_viagem_receb, l_status,
          l_dat_devolucao, l_dat_transferencia
     FROM cdv_dev_transf_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','cdv_dev_transf_781')
  END IF

  IF l_status = 'D' THEN
     LET l_data_retorno = l_dat_devolucao
  ELSE
     LET l_data_retorno = l_dat_transferencia
  END IF

  RETURN l_val_transf, l_controle_receb, l_viagem_receb, l_data_retorno

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2000_recupera_total_terceiros(l_viagem)
#----------------------------------------------------#
  DEFINE l_viagem             LIKE cdv_acer_viag_781.viagem,
         l_val_desp_terceiro  LIKE cdv_desp_terc_781.val_desp_terceiro

  LET l_val_desp_terceiro = 0
  WHENEVER ERROR CONTINUE
   SELECT SUM(val_desp_terceiro)
     INTO l_val_desp_terceiro
     FROM cdv_desp_terc_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_desp_terc_781')
     RETURN FALSE, l_val_desp_terceiro
  END IF

  IF l_val_desp_terceiro IS NULL THEN
     LET l_val_desp_terceiro = 0
  END IF

  RETURN TRUE, l_val_desp_terceiro

END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2000_recupera_total_adiantamentos(l_viagem)
#-------------------------------------------------------#
  DEFINE l_viagem             LIKE cdv_acer_viag_781.viagem,
         l_val_adto_viagem    LIKE cdv_solic_adto_781.val_adto_viagem

  WHENEVER ERROR CONTINUE
   SELECT SUM(val_adto_viagem)
     INTO l_val_adto_viagem
     FROM cdv_solic_adto_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_solic_adto_781')
     RETURN FALSE, l_val_adto_viagem
  END IF

  IF l_val_adto_viagem IS NULL THEN
     LET l_val_adto_viagem = 0
  END IF

  RETURN TRUE, l_val_adto_viagem

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_recupera_total_urbanas(l_viagem)
#-------------------------------------------------#
  DEFINE l_viagem               LIKE cdv_acer_viag_781.viagem,
         l_val_despesa_urbana   LIKE cdv_desp_urb_781.val_despesa_urbana

  WHENEVER ERROR CONTINUE
     SELECT SUM(val_despesa_urbana)
       INTO l_val_despesa_urbana
       FROM cdv_desp_urb_781
      WHERE empresa = p_cod_empresa
        AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_desp_urb_781')
     RETURN FALSE, l_val_despesa_urbana
  END IF

  IF l_val_despesa_urbana IS NULL THEN
     LET l_val_despesa_urbana = 0
  END IF

  RETURN TRUE, l_val_despesa_urbana

END FUNCTION

#--------------------------------------#
 FUNCTION cdv2000_lista_despesa_viagem()
#--------------------------------------#
 IF cdv2012_controle(mr_solic.*) THEN
 ELSE
    ERROR 'Impress�o cancelada.'
 END IF

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2000_recupera_ind_previsao(l_ad_terceiro)
#-----------------------------------------------------#
  DEFINE l_ad_terceiro  LIKE ad_mestre.num_ad,
         l_ies_previsao CHAR(01)

  WHENEVER ERROR CONTINUE
   SELECT td.ies_previsao
     INTO l_ies_previsao
     FROM tipo_despesa td, ad_mestre ad
    WHERE ad.cod_empresa     = p_cod_empresa
      AND ad.num_ad          = l_ad_terceiro
      AND td.cod_empresa     = ad.cod_empresa
      AND td.cod_tip_despesa = ad.cod_tip_despesa
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','td/ad')
     LET l_ies_previsao = 'N'
  END IF

  RETURN l_ies_previsao

END FUNCTION

#----------------------------#
 FUNCTION cdv2000_dev_transf()
#----------------------------#
  DEFINE l_ies_dev    SMALLINT,
         l_finalizado SMALLINT

  LET l_ies_dev   = FALSE
  CALL log006_exibe_teclas('01', p_versao)

  LET m_caminho = log1300_procura_caminho('cdv20006','cdv20006')
  OPEN WINDOW w_cdv20006 AT 2,2 WITH FORM m_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  LET m_terc_ativa = FALSE

  LET m_previa_viagem   = mr_input.viagem
  LET m_previa_controle = mr_input.controle

  DISPLAY m_previa_viagem   TO viagem
  DISPLAY m_previa_controle TO controle

  CALL cdv2000_busca_tot_adiant()
  CALL cdv2000_busca_tot_desp()

  IF cdv2000_existe_devolucao() THEN
     LET l_ies_dev = TRUE
  ELSE
     LET l_ies_dev = FALSE
  END IF

  IF cdv2000_acerto_finalizado() THEN
     LET l_finalizado = TRUE
  ELSE
     LET l_finalizado = FALSE
  END IF

  MENU 'DEVOLU��O'
     BEFORE MENU
        IF l_ies_dev THEN
           DISPLAY BY NAME mr_dev_transf.*
        ELSE
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

        IF l_finalizado THEN
           HIDE OPTION 'Modificar'
           HIDE OPTION 'Excluir'
        END IF

     COMMAND 'Processar' 'Processa a devolu��o.'
        HELP 018
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'IN') THEN
           IF cdv2000_informa_dev_transf('INCLUSAO') THEN
              IF log0040_confirm(05,10,'Confirma processamento de devolu��o/transfer�ncia?') THEN
                 IF cdv2000_processa_dev_transf() THEN
                    CALL log0030_mensagem('Processamento efetuado com sucesso.','info')
                    SHOW OPTION 'Modificar'
                    SHOW OPTION 'Excluir'
                 ELSE
                    ERROR 'Processamento cancelado.'
                 END IF
              ELSE
                 ERROR 'Processamento cancelado.'
              END IF
           END IF
           NEXT OPTION "Fim"
        END IF

     COMMAND 'Modificar' 'Modifica os dados que est�o sendo exibidos.'
        HELP 002
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'MO') THEN
           IF cdv2000_informa_dev_transf('MODIFICACAO') THEN
              IF log0040_confirm(05,10,"Confirma atualiza��o?") THEN
                 IF cdv2000_atualiza_dev_transf() THEN
                    MESSAGE "Modifica��o efetuada com sucesso." ATTRIBUTE(REVERSE)
                 END IF
              ELSE
                 ERROR "Modifica��o cancelada."
              END IF
           END IF
           NEXT OPTION "Fim"
        END IF

     COMMAND 'Excluir' 'Exclui os dados que est�o sendo exibidos.'
        HELP 003
        MESSAGE ''
        IF log005_seguranca(p_user, 'CDV' , 'CDV2000', 'EX') THEN
           IF log0040_confirm(05,10,"Confirma exclus�o da devolu��o") THEN
              IF cdv2000_exclui_dev_transf() THEN
                 MESSAGE "Exclus�o efetuada com sucesso." ATTRIBUTE(REVERSE)
                 HIDE OPTION 'Modificar'
                 HIDE OPTION 'Excluir'
              END IF
           ELSE
              ERROR "Exlus�o cancelada."
           END IF
           NEXT OPTION "Fim"
        END IF

     COMMAND 'Fim'  'Retorna ao menu anterior.'
        HELP 008
        EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_cdv20006

  CURRENT WINDOW IS w_cdv2000

 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_informa_dev_transf(l_funcao)
#--------------------------------------------#
  DEFINE sql_stmt       CHAR(1000),
         l_funcao       CHAR(15)

  LET mr_dev_transfr.* = mr_dev_transf.*
  IF l_funcao = 'INCLUSAO' THEN
     INITIALIZE mr_dev_transf.* TO NULL
  END IF

  IF NOT cdv2000_entrada_dados_dev_transf(l_funcao) THEN
     INITIALIZE mr_dev_transf.* TO NULL
     DISPLAY BY NAME mr_dev_transf.*
     IF l_funcao = "INCLUSAO" THEN
        ERROR "Inclus�o cancelada."
     ELSE
        ERROR "Modifica��o cancelada."
     END IF
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2000_entrada_dados_dev_transf(l_funcao)
#--------------------------------------------------#
  DEFINE l_tot     LIKE cdv_solic_adto_781.val_adto_viagem,
         l_funcao  CHAR(15)

 CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_cdv20006

  IF l_funcao = 'INCLUSAO' THEN
     INITIALIZE mr_dev_transf.* TO NULL
     CLEAR FORM
  END IF

  DISPLAY p_cod_empresa TO empresa
  LET mr_dev_transf.tot_adiant = m_tot_adiant
  LET mr_dev_transf.tot_desp   = m_tot_desp

  IF l_funcao = 'MODIFICACAO' THEN
     LET l_tot = mr_dev_transf.tot_adiant - mr_dev_transf.tot_desp
     IF mr_dev_transf.status = 'T' THEN
        LET mr_dev_transf.val_transf    = l_tot
     ELSE
        LET mr_dev_transf.val_devolucao = l_tot
     END IF
  END IF

  LET mr_dev_transf.viagem   = m_previa_viagem
  LET mr_dev_transf.controle = m_previa_controle

  LET INT_FLAG = FALSE
  INPUT BY NAME mr_dev_transf.* WITHOUT DEFAULTS

     {BEFORE FIELD controle
        IF l_funcao = 'MODIFICACAO' THEN
           NEXT FIELD status
        END IF
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

     AFTER FIELD controle
        IF mr_dev_transf.controle IS NOT NULL THEN
           IF NOT cdv2000_valida_controle_ativo(mr_dev_transf.controle, mr_dev_transf.viagem) THEN
              CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
              NEXT FIELD controle
           END IF
        END IF

     BEFORE FIELD viagem
        IF mr_dev_transf.controle IS NOT NULL THEN
           LET mr_dev_transf.viagem = cdv2000_recupera_viagem_por_controle(mr_dev_transf.controle)
           DISPLAY BY NAME mr_dev_transf.viagem
        END IF

     AFTER FIELD viagem
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF

        IF mr_dev_transf.viagem IS NOT NULL THEN
           IF cdv2000_verifica_devolucao() THEN
              CALL log0030_mensagem("Devolu��o/transfer�ncia j� feita para esta viagem.","info")
              NEXT FIELD controle
           END IF

           IF NOT cdv2000_valida_viagem_ativa(mr_dev_transf.viagem, mr_dev_transf.controle) THEN
              CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
              NEXT FIELD viagem
           END IF
        ELSE
           IF mr_dev_transf.controle IS NULL THEN
              CALL log0030_mensagem('Informe o controle e/ou viagem.','exclamation')
              NEXT FIELD controle
           END IF
        END IF}

     BEFORE FIELD status
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF

     AFTER FIELD status
        IF  mr_dev_transf.status IS NOT NULL AND mr_dev_transf.status <> " " THEN
           IF NOT cdv2000_verifica_status(mr_dev_transf.status) THEN
              CALL log0030_mensagem('Status n�o cadastrado.','exclamation')
              NEXT FIELD status
           END IF
        ELSE
           CALL log0030_mensagem('Status n�o informado.','exclamation')
           NEXT FIELD status
        END IF
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF
        IF mr_dev_transf.status = 'T' THEN
           INITIALIZE mr_dev_transf.banco             TO NULL
           INITIALIZE mr_dev_transf.den_banco         TO NULL
           INITIALIZE mr_dev_transf.caixa             TO NULL
           INITIALIZE mr_dev_transf.den_caixa         TO NULL
           INITIALIZE mr_dev_transf.agencia           TO NULL
           INITIALIZE mr_dev_transf.cta_corrente      TO NULL
           INITIALIZE mr_dev_transf.dat_devolucao     TO NULL
           INITIALIZE mr_dev_transf.val_devolucao     TO NULL
           INITIALIZE mr_dev_transf.forma             TO NULL
           INITIALIZE mr_dev_transf.den_forma         TO NULL
           INITIALIZE mr_dev_transf.doc_devolucao     TO NULL
           INITIALIZE mr_dev_transf.dat_doc_devolucao TO NULL

           DISPLAY BY NAME mr_dev_transf.*

           LET l_tot = mr_dev_transf.tot_adiant - mr_dev_transf.tot_desp
           LET mr_dev_transf.val_transf = l_tot
           DISPLAY BY NAME mr_dev_transf.val_transf
           NEXT FIELD dat_transf
        ELSE
           INITIALIZE mr_dev_transf.val_transf        TO NULL
           INITIALIZE mr_dev_transf.dat_transf        TO NULL
           INITIALIZE mr_dev_transf.viagem_receb      TO NULL
           INITIALIZE mr_dev_transf.controle_receb    TO NULL

           DISPLAY BY NAME mr_dev_transf.*

           LET l_tot = mr_dev_transf.tot_adiant - mr_dev_transf.tot_desp
           LET mr_dev_transf.val_devolucao = l_tot
           DISPLAY BY NAME mr_dev_transf.val_devolucao
           NEXT FIELD dat_devolucao
        END IF

     BEFORE FIELD dat_transf
        LET mr_dev_transf.dat_transf = TODAY
        DISPLAY BY NAME mr_dev_transf.dat_transf

     AFTER FIELD dat_transf
        IF  fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD status
        END IF

        IF  mr_dev_transf.dat_transf IS NOT NULL
        AND mr_dev_transf.dat_transf <> " " THEN
           NEXT FIELD viagem_receb
        ELSE
           CALL log0030_mensagem('Data de transfer�ncia n�o informada.','exclamation')
           NEXT FIELD dat_transf
        END IF

     AFTER FIELD viagem_receb
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD dat_transf
        END IF

        IF  mr_dev_transf.viagem_receb IS NOT NULL
        AND mr_dev_transf.viagem_receb <> " " THEN
           IF mr_dev_transf.viagem_receb = mr_input.viagem THEN
              CALL log0030_mensagem('Viagem recebedora igual a viagem corrente.','exclamation')
              NEXT FIELD viagem_receb
           END IF
           IF NOT cdv2000_verifica_viagem_receb(mr_dev_transf.viagem_receb) THEN
              NEXT FIELD viagem_receb
           END IF
        ELSE
           CALL log0030_mensagem('Viagem recebedora n�o informada.','exclamation')
           NEXT FIELD viagem_receb
        END IF

        IF mr_dev_transf.status = 'T' THEN
           LET mr_dev_transf.controle_receb = cdv2000_busca_controle_receb(mr_dev_transf.viagem_receb)
           DISPLAY BY NAME  mr_dev_transf.controle_receb
        END IF

     BEFORE FIELD controle_receb
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD viagem_receb
        ELSE
           NEXT FIELD observacao
        END IF

     #AFTER FIELD controle_receb
     #   IF mr_dev_transf.status = 'T' THEN
     #      NEXT FIELD observacao
     #   END IF

     BEFORE FIELD dat_devolucao
        LET mr_dev_transf.dat_devolucao = TODAY
        DISPLAY BY NAME mr_dev_transf.dat_devolucao

     AFTER FIELD dat_devolucao
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD status
        END IF

     BEFORE FIELD forma
        --# CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
        IF NOT g_ies_grafico THEN
            DISPLAY '( Zoom )' AT 3,68
        END IF
        IF mr_dev_transf.forma IS NULL
        OR mr_dev_transf.forma = " " THEN
           LET mr_dev_transf.forma = "2"
           DISPLAY BY NAME mr_dev_transf.forma
        END IF

     AFTER FIELD forma
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD dat_devolucao
        END IF

        IF  mr_dev_transf.forma IS NOT NULL
        AND mr_dev_transf.forma <> " " THEN
           IF NOT cdv2000_verifica_forma(mr_dev_transf.forma) THEN
              CALL log0030_mensagem('Forma n�o cadastrada.','exclamation')
              NEXT FIELD forma
           END IF
           IF mr_dev_transf.forma = "2" THEN
              INITIALIZE mr_dev_transf.banco, mr_dev_transf.agencia,
                         mr_dev_transf.cta_corrente, mr_dev_transf.den_banco TO NULL
              DISPLAY BY NAME mr_dev_transf.banco, mr_dev_transf.agencia,
                         mr_dev_transf.cta_corrente, mr_dev_transf.den_banco
           ELSE
	             INITIALIZE mr_dev_transf.caixa, mr_dev_transf.den_caixa TO NULL
	             DISPLAY BY NAME mr_dev_transf.caixa, mr_dev_transf.den_caixa
           END IF
        ELSE
           CALL log0030_mensagem('Forma n�o informada.','exclamation')
           NEXT FIELD forma
        END IF
        --# CALL fgl_dialog_setkeylabel('control-z', '')
        IF NOT g_ies_grafico THEN
            DISPLAY '--------' AT 3,68
        END IF
        NEXT FIELD doc_devolucao

     AFTER FIELD doc_devolucao
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD forma
        END IF

     AFTER FIELD dat_doc_devolucao
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           NEXT FIELD doc_devolucao
        END IF
        IF mr_dev_transf.forma = '1' THEN
           NEXT FIELD banco
        ELSE
           NEXT FIELD caixa
        END IF

     AFTER FIELD caixa
        IF mr_dev_transf.forma = "2" THEN
           IF  mr_dev_transf.caixa IS NOT NULL
           AND mr_dev_transf.caixa <> " " THEN
              IF NOT cdv2000_verifica_caixa(mr_dev_transf.caixa) THEN
                 NEXT FIELD caixa
              END IF
           END IF
           NEXT FIELD observacao
        END IF

     BEFORE FIELD banco
        IF mr_dev_transf.forma = "1" THEN
           IF cdv2000_busca_banco() THEN
              NEXT FIELD agencia
           END IF
           NEXT FIELD banco
        END IF

     BEFORE FIELD agencia
        IF mr_dev_transf.forma = "1" THEN
           IF cdv2000_busca_agencia() THEN
              NEXT FIELD cta_corrente
           END IF
           NEXT FIELD agencia
        END IF

     BEFORE FIELD cta_corrente
        IF mr_dev_transf.forma = "1" THEN
           IF cdv2000_busca_cta_corrente() THEN
              NEXT FIELD observacao
           END IF
           NEXT FIELD cta_corrente
        END IF

     AFTER FIELD observacao
        IF fgl_lastkey() = fgl_keyval("UP")
        OR fgl_lastkey() = fgl_keyval("LEFT") THEN
           IF mr_dev_transf.status = 'T' THEN
              NEXT FIELD viagem_receb
           ELSE
              NEXT FIELD cta_corrente
           END IF
        END IF

     AFTER INPUT
        IF NOT INT_FLAG THEN
           {IF mr_dev_transf.controle IS NOT NULL THEN
              IF NOT cdv2000_valida_controle_ativo(mr_dev_transf.controle, mr_dev_transf.viagem) THEN
                 CALL log0030_mensagem('Controle inexistente ou relacionado fora da sele��o.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF

           IF mr_dev_transf.viagem IS NOT NULL THEN
              IF l_funcao = "INCLUSAO" THEN
                 IF cdv2000_verifica_devolucao() THEN
                    CALL log0030_mensagem("Devolu��o/transfer�ncia j� feita para esta viagem.","info")
                    NEXT FIELD controle
                 END IF
              END IF

              IF NOT cdv2000_valida_viagem_ativa(mr_dev_transf.viagem, mr_dev_transf.controle) THEN
                 CALL log0030_mensagem('Viagem inexistente ou relacionada a controle fora da sele��o.','exclamation')
                 NEXT FIELD viagem
              END IF
           ELSE
              IF mr_dev_transf.controle IS NULL THEN
                 CALL log0030_mensagem('Informe o controle e/ou viagem.','exclamation')
                 NEXT FIELD controle
              END IF
           END IF}

			        IF mr_dev_transf.status IS NOT NULL AND mr_dev_transf.status <> " " THEN
			           IF NOT cdv2000_verifica_status(mr_dev_transf.status) THEN
			              CALL log0030_mensagem('Status n�o cadastrado.','exclamation')
			              NEXT FIELD status
			           END IF
			        ELSE
			           CALL log0030_mensagem('Status n�o informado.','exclamation')
			           NEXT FIELD status
			        END IF

           IF mr_dev_transf.status = 'T' THEN
              IF mr_dev_transf.dat_transf IS NULL
              OR mr_dev_transf.dat_transf =  " " THEN
                 CALL log0030_mensagem('Data de transfer�ncia n�o informada.','exclamation')
                 NEXT FIELD dat_transf
              END IF

              IF mr_dev_transf.viagem_receb IS NULL
              OR mr_dev_transf.viagem_receb = " " THEN
                 CALL log0030_mensagem('Viagem recebedora n�o informada.','exclamation')
                 NEXT FIELD viagem_receb
              ELSE
						           IF mr_dev_transf.viagem_receb = mr_input.viagem THEN
						              CALL log0030_mensagem('Viagem recebedora igual a viagem corrente.','exclamation')
						              NEXT FIELD viagem_receb
						           END IF
						           IF NOT cdv2000_verifica_viagem_receb(mr_dev_transf.viagem_receb) THEN
						              NEXT FIELD viagem_receb
						           END IF
              END IF

              IF mr_dev_transf.controle_receb IS NULL
              OR mr_dev_transf.controle_receb = " " THEN
                 CALL log0030_mensagem('Controle recebedor n�o informado.','exclamation')
                 NEXT FIELD controle_receb
              END IF
           ELSE
              IF mr_dev_transf.dat_devolucao IS NULL
              OR mr_dev_transf.dat_devolucao = " " THEN
                 CALL log0030_mensagem('Data de devolu��o n�o informada.','exclamation')
                 NEXT FIELD dat_devolucao
              END IF

              IF mr_dev_transf.doc_devolucao IS NULL
              OR mr_dev_transf.doc_devolucao = " " THEN
                 #CALL log0030_mensagem('Documento de devolu��o n�o informado.','exclamation')
                 #NEXT FIELD doc_devolucao
              END IF

              IF mr_dev_transf.dat_doc_devolucao IS NULL
              OR mr_dev_transf.dat_doc_devolucao = " " THEN
                 #CALL log0030_mensagem('Data do documento de devolu��o n�o informada.','exclamation')
                 #NEXT FIELD dat_doc_devolucao
              END IF

              IF  mr_dev_transf.forma IS NOT NULL
              AND mr_dev_transf.forma <> " " THEN
                 IF NOT cdv2000_verifica_forma(mr_dev_transf.forma) THEN
                    CALL log0030_mensagem('Forma n�o cadastrada.','exclamation')
                    NEXT FIELD forma
                 END IF
                 IF mr_dev_transf.forma = "2" THEN
                    INITIALIZE mr_dev_transf.banco, mr_dev_transf.agencia,
                               mr_dev_transf.cta_corrente, mr_dev_transf.den_banco TO NULL
                    DISPLAY BY NAME mr_dev_transf.banco, mr_dev_transf.agencia,
                               mr_dev_transf.cta_corrente, mr_dev_transf.den_banco
                 ELSE
	                   INITIALIZE mr_dev_transf.caixa, mr_dev_transf.den_caixa TO NULL
	                   DISPLAY BY NAME mr_dev_transf.caixa, mr_dev_transf.den_caixa
                 END IF
              ELSE
                 CALL log0030_mensagem('Forma n�o informada.','exclamation')
                 NEXT FIELD forma
              END IF

              IF mr_dev_transf.forma = '2' THEN
                 IF mr_dev_transf.caixa IS NULL
                 OR mr_dev_transf.caixa = " " THEN
                    CALL log0030_mensagem('Caixa n�o informado.','exclamation')
                    NEXT FIELD caixa
                 ELSE
									           IF NOT cdv2000_verifica_caixa(mr_dev_transf.caixa) THEN
									              NEXT FIELD caixa
									           END IF
                 END IF
              END IF
           END IF
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2000_help()

     ON KEY (control-z, f4)
        CALL cdv2000_popup("DEV")

  END INPUT

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_cdv20006

  IF INT_FLAG THEN
     CLEAR FORM
     RETURN FALSE
  END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION cdv2000_verifica_devolucao()
#--------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT viagem FROM cdv_dev_transf_781
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_dev_transf.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_processa_dev_transf()
#-------------------------------------#
 WHENEVER ERROR CONTINUE
 CALL log085_transacao("BEGIN")
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 DELETE FROM cdv_dev_transf_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_dev_transf.viagem
 WHENEVER ERROR STOP

 IF  SQLCA.sqlcode <> 0 AND SQLCA.sqlcode <> 100 THEN
    CALL log003_err_sql("DELETE","CDV_DEV_TRANSF_781")

    WHENEVER ERROR CONTINUE
    CALL log085_transacao("ROLLBACK")
    WHENEVER ERROR STOP
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 INSERT INTO cdv_dev_transf_781 (empresa,
                                 viagem,
                                 eh_status_acerto,
                                 val_devolucao,
                                 dat_devolucao,
                                 val_transf,
                                 dat_transf,
                                 viagem_receb,
                                 controle_receb,
                                 forma_devolucao,
                                 docum_devolucao,
                                 caixa,
                                 dat_doc_devolucao,
                                 banco,
                                 agencia,
                                 cta_corrente,
                                 observacao)
                         VALUES (p_cod_empresa,
                                 mr_dev_transf.viagem,
                                 mr_dev_transf.status,
                                 mr_dev_transf.val_devolucao,
                                 mr_dev_transf.dat_devolucao,
                                 mr_dev_transf.val_transf,
                                 mr_dev_transf.dat_transf,
                                 mr_dev_transf.viagem_receb,
                                 mr_dev_transf.controle_receb,
                                 mr_dev_transf.forma,
                                 mr_dev_transf.doc_devolucao,
                                 mr_dev_transf.caixa,
                                 mr_dev_transf.dat_doc_devolucao,
                                 mr_dev_transf.banco,
                                 mr_dev_transf.agencia,
                                 mr_dev_transf.cta_corrente,
                                 mr_dev_transf.observacao)
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT","CDV_DEV_TRANSF_781")

    WHENEVER ERROR CONTINUE
    CALL log085_transacao("ROLLBACK")
    WHENEVER ERROR STOP
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 CALL log085_transacao("COMMIT")
 WHENEVER ERROR STOP

 RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION cdv2000_atualiza_dev_transf()
#--------------------------------------#
 WHENEVER ERROR CONTINUE
 CALL log085_transacao("BEGIN")
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  UPDATE cdv_dev_transf_781
     SET eh_status_acerto  = mr_dev_transf.status,
         val_devolucao     = mr_dev_transf.val_devolucao,
         dat_devolucao     = mr_dev_transf.dat_devolucao,
         val_transf        = mr_dev_transf.val_transf,
         dat_transf        = mr_dev_transf.dat_transf,
         viagem_receb      = mr_dev_transf.viagem_receb,
         controle_receb    = mr_dev_transf.controle_receb,
         forma_devolucao   = mr_dev_transf.forma,
         docum_devolucao   = mr_dev_transf.doc_devolucao,
         caixa             = mr_dev_transf.caixa,
         dat_doc_devolucao = mr_dev_transf.dat_doc_devolucao,
         banco             = mr_dev_transf.banco,
         agencia           = mr_dev_transf.agencia,
         cta_corrente      = mr_dev_transf.cta_corrente,
         observacao        = mr_dev_transf.observacao
   WHERE empresa = p_cod_empresa
     AND viagem  = mr_dev_transf.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("UPDATE","CDV_DEV_TRANSF_781")

    WHENEVER ERROR CONTINUE
    CALL log085_transacao("ROLLBACK")
    WHENEVER ERROR STOP

    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 CALL log085_transacao("COMMIT")
 WHENEVER ERROR STOP

 RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2000_verifica_status(l_status)
#------------------------------------------#
 DEFINE l_status      CHAR(01),
        l_den_status  CHAR(30)

 CASE l_status
 WHEN 'D'
    LET mr_dev_transf.den_status = 'DEVOLU��O'
    DISPLAY mr_dev_transf.den_status TO den_status
    RETURN TRUE
 WHEN 'T'
    LET mr_dev_transf.den_status = 'TRANSFER�NCIA'
    DISPLAY mr_dev_transf.den_status TO den_status
    RETURN TRUE
 OTHERWISE
    LET mr_dev_transf.den_status = ''
    DISPLAY mr_dev_transf.den_status TO den_status
    RETURN FALSE
 END CASE

 END FUNCTION

#-----------------------------------#
 FUNCTION  cdv2000_busca_tot_adiant()
#-----------------------------------#
 DEFINE l_tot     LIKE cdv_solic_adto_781.val_adto_viagem

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_adto_viagem)
   INTO l_tot
   FROM cdv_solic_adto_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot = 0
 END IF

 DISPLAY l_tot TO tot_adiant

 END FUNCTION

#---------------------------------#
 FUNCTION  cdv2000_busca_tot_desp()
#---------------------------------#
 DEFINE l_tot      LIKE cdv_solic_adto_781.val_adto_viagem,
        l_tot_urb  LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_tot_km   LIKE cdv_despesa_km_781.val_km

 WHENEVER ERROR CONTINUE
 SELECT SUM(cdv_despesa_km_781.val_km)
   INTO l_tot_km
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
    AND cdv_despesa_km_781.viagem             = mr_input.viagem
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
    AND cdv_despesa_km_781.ativ_km            = cdv_tdesp_viag_781.ativ
    AND cdv_tdesp_viag_781.empresa            = cdv_despesa_km_781.empresa
    AND cdv_tdesp_viag_781.grp_despesa_viagem = '2'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot_km = 0
 END IF

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_despesa_urbana)
   INTO l_tot_urb
   FROM cdv_desp_urb_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot_urb = 0
 END IF

 IF l_tot_urb IS NULL THEN
    LET l_tot_urb = 0
 END IF

 IF l_tot_km IS NULL  THEN
    LET l_tot_km = 0
 END IF

 LET l_tot = l_tot_km + l_tot_urb
 DISPLAY l_tot TO tot_desp

 END FUNCTION

#--------------------------------#
 FUNCTION cdv2000_verifica_saldo()
#--------------------------------#
 DEFINE l_tot_desp LIKE cdv_solic_adto_781.val_adto_viagem,
        l_tot_urb  LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_tot_km   LIKE cdv_despesa_km_781.val_km

 DEFINE l_tot_adto LIKE cdv_solic_adto_781.val_adto_viagem
 DEFINE l_tot      LIKE cdv_solic_adto_781.val_adto_viagem

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_adto_viagem)
   INTO l_tot_adto
   FROM cdv_solic_adto_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot_adto = 0
 END IF

 WHENEVER ERROR CONTINUE
 SELECT SUM(cdv_despesa_km_781.val_km)
   INTO l_tot_km
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
    AND cdv_despesa_km_781.viagem             = mr_input.viagem
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
    AND cdv_despesa_km_781.ativ_km            = cdv_tdesp_viag_781.ativ
    AND cdv_tdesp_viag_781.empresa            = cdv_despesa_km_781.empresa
    AND cdv_tdesp_viag_781.grp_despesa_viagem = '2'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot_km = 0
 END IF

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_despesa_urbana)
   INTO l_tot_urb
   FROM cdv_desp_urb_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_tot_urb = 0
 END IF

 IF l_tot_desp is NULL THEN
    LET l_tot_desp = 0
 END IF
 IF l_tot_urb  is NULL THEN
    LET l_tot_urb = 0
 END IF
 IF l_tot_km   is NULL then
    LET l_tot_km = 0
 END IF
 IF l_tot_adto is NULL THEN
    LET l_tot_adto = 0
 END IF

 LET l_tot_desp = l_tot_km + l_tot_urb

 LET l_tot = l_tot_adto - l_tot_desp

 LET m_tot_adiant = l_tot_adto
 LET m_tot_desp   = l_tot_desp

 IF l_tot > 0 THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2000_finaliza_acerto()
#-----------------------------------#
  DEFINE l_filial_atendida     LIKE empresa.cod_empresa,
         l_finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         l_msg                 CHAR(100),
         l_ind_valid           CHAR(01),
         l_work                SMALLINT,
         l_tot_despesas        DECIMAL(17,2),
         l_tot_adtos           DECIMAL(17,2),
         l_tot_desp_urbanas    DECIMAL(17,2),
         l_tot_desp_km         DECIMAL(17,2),
         l_status              SMALLINT,
         l_cod_fornecedor      LIKE fornecedor.cod_fornecedor,
         l_status_acer_viagem  LIKE cdv_acer_viag_781.status_acer_viagem,
         l_controle            LIKE cdv_acer_viag_781.controle,
         l_viagem_origem       LIKE cdv_acer_viag_781.viagem,
         l_caminho             CHAR(300)

  #################
  LET l_work = TRUE
  #################

  INITIALIZE m_empresa_atendida_pamcary, m_segundo_nivel_aen TO NULL

  CALL log2250_busca_parametro(mr_input.empresa_atendida,'empresa_atendida_pamcary')
     RETURNING m_empresa_atendida_pamcary, l_status
  IF NOT l_status OR m_empresa_atendida_pamcary IS NULL THEN
     CALL log0030_mensagem('Primeiro n�vel empresa atendida n�o cadastrado.','exclamation')
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
   SELECT c.parametro_numerico
     INTO m_segundo_nivel_aen
     FROM cdv_par_viajante a, cdv_info_viajante b, cdv_par_padrao c
    WHERE a.empresa   = p_cod_empresa
      AND a.matricula = mr_input.viajante
      AND b.empresa   = p_cod_empresa
      AND b.matricula = mr_input.viajante
      AND b.empresa_rhu = a.empresa_rhu
      AND a.parametro   = 'uni_func_viaj'
      AND c.empresa = p_cod_empresa
      AND c.parametro[01,10] = a.parametro_texto[01,10]

  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 OR m_segundo_nivel_aen IS NULL THEN
     CALL log2250_busca_parametro(mr_input.filial_atendida,'filial_atendida_pamcary')
        RETURNING m_segundo_nivel_aen, l_status
     IF NOT l_status OR m_segundo_nivel_aen IS NULL THEN
        CALL log0030_mensagem('Segundo n�vel filial atendida n�o cadastrado.','exclamation')
        RETURN
     END IF
  END IF

  WHENEVER ERROR CONTINUE
   SELECT filial_atendida, finalidade_viagem, controle
     INTO l_filial_atendida, l_finalidade_viagem, l_controle
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','CDV_ACER_VIAG_781')
     RETURN
  END IF

  LET l_status_acer_viagem = cdv2000_recupera_status_viag(mr_input.viagem)

  IF l_status_acer_viagem = 1 OR l_status_acer_viagem IS NULL THEN
     LET l_msg = 'O acerto da viagem ', mr_input.viagem USING "<<<<<<<<<<", ' n�o foi iniciado.'
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN
  ELSE
     IF l_status_acer_viagem = 3 OR l_status_acer_viagem = 4 THEN
        LET l_msg = 'O acerto da viagem ', mr_input.viagem USING "<<<<<<<<<<", ' j� foi finalizado.'
        CALL log0030_mensagem(l_msg,'exclamation')
        RETURN
     END IF
  END IF

  LET l_ind_valid = cdv2000_existe_desp_terc_sem_ad_ou_previsao(mr_input.viagem)
  IF l_ind_valid = 'N' THEN
     LET l_msg = 'Viagem ', mr_input.viagem USING "<<<<<<<<<<", ' possui despesa de terceiro sem AD.'
     CALL log0030_mensagem(l_msg,'exclamation')
  END IF
  IF l_ind_valid = 'P' THEN
     LET l_msg = 'Viagem ', mr_input.viagem USING "<<<<<<<<<<", ' possui desp. terc. com AD de previs�o, efetue a efetiva��o da AD.'
     CALL log0030_mensagem(l_msg,'exclamation')
  END IF
  IF l_ind_valid = 'E' OR l_ind_valid = 'N' OR l_ind_valid = 'P'THEN
     RETURN
  END IF

  IF cdv2000_existe_viagem_sem_dev_transf(mr_input.viagem) THEN
     LET l_msg = 'N�o foi informada devolu��o/transfer�ncia para a viagem ', mr_input.viagem USING "<<<<<<<<<<", '.'
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_viagem_origem
     FROM cdv_dev_transf_781
    WHERE empresa      = p_cod_empresa
      AND viagem_receb = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode = 0 THEN
     WHENEVER ERROR CONTINUE
      SELECT status_acer_viagem
        INTO l_status_acer_viagem
        FROM cdv_acer_viag_781
       WHERE empresa = p_cod_empresa
         AND viagem  = l_viagem_origem
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("SELECT","CDV_ACER_VIAG_781")
        RETURN
     END IF

     IF l_status_acer_viagem = "1" OR l_status_acer_viagem = "2" THEN
        LET l_msg = "Viagem origem ",l_viagem_origem USING "<<<<<<<<<<",
                    ", da transfer�ncia ainda n�o est� finalizada."
        CALL log0030_mensagem(l_msg,"exclamation")
        RETURN
     END IF
  END IF

  IF cdv2000_grupo_tdesp_certificado(mr_input.viagem) THEN #Alterado spec.2
     CALL log0030_mensagem('Finaliza��o de acerto n�o permitida. \nPossui despesa do tipo certificado.','exclamation')
     RETURN
  END IF

  IF NOT log0040_confirm(19,34,"Confirma finaliza��o do(s) acerto(s)?") THEN
     RETURN
  END IF

  ##############################
  CALL log085_transacao("BEGIN")
  ##############################

  CALL cdv2000_recupera_total_urbanas(mr_input.viagem)
     RETURNING l_status, l_tot_desp_urbanas

  CALL cdv2000_recupera_total_despesas_km(mr_input.viagem, '2')
     RETURNING l_status, l_tot_desp_km

  LET l_tot_despesas = l_tot_desp_urbanas + l_tot_desp_km

  CALL cdv2000_recupera_total_adiantamentos(mr_input.viagem)
     RETURNING l_status, l_tot_adtos

  LET l_cod_fornecedor = cdv2000_retorna_fornec(mr_input.viagem)

  #SO EXISTE KM SEMANAL E/OU TERCEIROS; NAO GERA AD ACERTO!!!

  # verificar acerto sem 1-apont desp/SOS e sem apont Km/horas normal reembolsada (grupo = 2)
  # e aprova��o eletronica ativa = criar uma funcao semelhante ao cdv0803.

  IF cdv2000_existe_desp_urb()
  OR cdv2000_existe_desp_km_norm_reeb()
  OR cdv2000_existe_dev_total(l_tot_adtos) THEN               #Alterado spec.2

     IF l_tot_despesas = 0 AND l_tot_adtos = 0 THEN
        LET l_work = cdv0803_atualiza_dados_ad_acerto('', mr_input.viagem, '', 'A')
        CALL log006_exibe_teclas("01", p_versao)
        CURRENT WINDOW IS w_cdv2000
     ELSE
        IF l_tot_despesas < l_tot_adtos THEN
           LET l_work = cdv2000_processa_acerto(mr_input.viagem, l_tot_adtos, m_tip_desp_acerto, l_cod_fornecedor,
                                                l_filial_atendida, l_finalidade_viagem, l_controle)

        ELSE
           LET l_work = cdv2000_processa_acerto(mr_input.viagem, l_tot_despesas, m_tip_desp_acerto, l_cod_fornecedor,
                                                l_filial_atendida, l_finalidade_viagem, l_controle)
        END IF
     END IF

  ELSE

     IF cdv2000_aprov_eletronica() THEN
        CALL cdv0803_gera_aprov_eletr_viag(TRUE, "cdv", "S", mr_input.viagem)
             RETURNING p_status

        IF NOT p_status THEN
           CALL log085_transacao("ROLLBACK")
           CALL log0030_mensagem('Problema envio acerto para aprova��o eletr�nica.','exclamation')
           RETURN
        END IF
     END IF
  END IF

  IF NOT l_work THEN
     CALL log085_transacao("ROLLBACK")
     CALL log0030_mensagem('Finaliza��o do(s) acerto(s) cancelada.','info')
     RETURN
  END IF

  LET mr_input.des_status = 'ACERTO VIAGEM FINALIZADO'
  DISPLAY BY NAME mr_input.des_status

  WHENEVER ERROR CONTINUE
   UPDATE cdv_acer_viag_781
      SET status_acer_viagem = '3'
    WHERE empresa = p_cod_empresa
      AND viagem  = mr_input.viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log085_transacao("ROLLBACK")
     CALL log003_err_sql('UPDATE','cdv_acer_viag_781')
     RETURN
  END IF

  LET l_work = cdv2000_gera_ads_quilometragem_semanal(mr_input.viagem, l_cod_fornecedor, l_filial_atendida, l_finalidade_viagem)

  IF NOT l_work THEN
     CALL log085_transacao("ROLLBACK")
     CALL log0030_mensagem('Finaliza��o do(s) acerto(s) cancelada.','info')
     RETURN
  END IF

  CALL cdv2000_insere_cdv_fat_781() RETURNING l_status

  IF NOT l_status THEN
     CALL log085_transacao("ROLLBACK")
     CALL log0030_mensagem('Finaliza��o do(s) acerto(s) cancelada.','info')
     RETURN
  END IF

  CALL log085_transacao("COMMIT")
  CALL log0030_mensagem('Finaliza��o do(s) acerto(s) efetuada com sucesso.','info')
  LET m_consulta_ativa = FALSE
  CALL cdv2000_lista_despesa_viagem()


END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2000_existe_desp_terc_sem_ad_ou_previsao(l_viagem)
#--------------------------------------------------------------#
  DEFINE l_viagem         LIKE cdv_acer_viag_781.viagem,
         l_ad_terceiro    LIKE ad_mestre.num_ad

  WHENEVER ERROR CONTINUE
   DECLARE cq_valida_terc CURSOR FOR
    SELECT ad_terceiro
      INTO l_ad_terceiro
      FROM cdv_desp_terc_781
     WHERE empresa     = p_cod_empresa
       AND viagem      = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('FOREACH','cdv_desp_terc_781')
     RETURN TRUE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_valida_terc INTO l_ad_terceiro
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','cdv_desp_terc_781')
        RETURN 'E'
     END IF
     IF l_ad_terceiro IS NULL THEN
        RETURN 'N'
     END IF

     IF cdv2000_recupera_ind_previsao(l_ad_terceiro) = 'P' THEN
        RETURN 'P'
     END IF

  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_valida_terc
  WHENEVER ERROR STOP

  RETURN 'S'

END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2000_existe_viagem_sem_dev_transf(l_viagem)
#-------------------------------------------------------#
  DEFINE l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_tot_desp_urbanas    DECIMAL(17,2),
         l_tot_desp_km         DECIMAL(17,2),
         l_tot_despesas        DECIMAL(17,2),
         l_tot_adtos           DECIMAL(17,2),
         l_saldo_transf        DECIMAL(17,2),
         l_controle_receb      LIKE cdv_acer_viag_781.controle,
         l_viagem_receb        LIKE cdv_acer_viag_781.viagem,
         l_status              SMALLINT

  CALL cdv2000_recupera_total_urbanas(l_viagem)
     RETURNING l_status, l_tot_desp_urbanas

  CALL cdv2000_recupera_total_despesas_km(l_viagem, '2')
     RETURNING l_status, l_tot_desp_km

  LET l_tot_despesas = l_tot_desp_urbanas + l_tot_desp_km

  CALL cdv2000_recupera_total_adiantamentos(l_viagem)
     RETURNING l_status, l_tot_adtos

  IF l_tot_despesas < l_tot_adtos THEN
     IF NOT cdv2000_existe_dev(l_viagem) THEN
        RETURN TRUE
     END IF
  END IF

  RETURN FALSE

END FUNCTION

#---------------------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_retorna_ad_por_dados_nf(l_nota_fiscal, l_serie_nota_fiscal, l_subserie_nf, l_fornecedor)
#---------------------------------------------------------------------------------------------------------#
  DEFINE l_nota_fiscal                 LIKE ad_mestre.num_nf,
         l_serie_nota_fiscal           LIKE ad_mestre.ser_nf,
         l_subserie_nf                 LIKE ad_mestre.ssr_nf,
         l_fornecedor                  LIKE ad_mestre.cod_fornecedor,
         l_num_ad                      LIKE ad_mestre.num_ad

  INITIALIZE l_num_ad TO NULL
  WHENEVER ERROR CONTINUE
   SELECT num_ad
     INTO l_num_ad
     FROM ad_mestre
    WHERE cod_empresa     = p_cod_empresa
      AND num_nf          = l_nota_fiscal
      AND ser_nf          = l_serie_nota_fiscal
      AND ssr_nf          = l_subserie_nf
      AND cod_fornecedor  = l_fornecedor
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','ad_mestre')
  END IF

  RETURN l_num_ad

END FUNCTION

#------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_processa_acerto(l_viagem, l_val_tot_nf, l_cod_tip_desp, l_cod_fornecedor,
                                  l_filial_atendida, l_finalidade_viagem, l_controle)
#------------------------------------------------------------------------------------------#
  DEFINE l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_val_tot_nf          DECIMAL(17,2),
         l_cod_fornecedor      LIKE fornecedor.cod_fornecedor,
         l_banco               LIKE cdv_dev_transf_781.banco,
         l_agencia             LIKE cdv_dev_transf_781.agencia,
         l_cta_corrente        LIKE cdv_dev_transf_781.cta_corrente,
         l_ies_dep_cred        CHAR(01),
         l_msg                 CHAR(100),
         l_num_ad              LIKE ad_ap.num_ad,
         m_num_ap              LIKE ad_ap.num_ap,
         l_work                SMALLINT,
         l_cod_tip_desp        LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
         l_filial_atendida     LIKE empresa.cod_empresa,
         l_finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         l_controle            LIKE cdv_acer_viag_781.controle

  DEFINE l_val_desp_propria   LIKE cdv_desp_det_781.val_desp_propria,
         l_val_desp_reembolso LIKE cdv_desp_det_781.val_desp_reembolso,
         l_val_despesa_km     LIKE cdv_desp_det_781.val_despesa_km

  IF NOT cdv2000_gera_contabilizacao_aen_fat(l_num_ad, l_viagem, l_cod_tip_desp, l_val_tot_nf,
                                             l_filial_atendida, l_finalidade_viagem, l_controle) THEN
     RETURN FALSE
  END IF

  CALL cdv2000_recupera_dados_bancarios_fornec(l_cod_fornecedor)
     RETURNING l_banco, l_agencia, l_cta_corrente, l_ies_dep_cred

  CALL cdv2000_monta_aen4()

  CALL cap309_gera_informacoes_cap("S", l_cod_tip_desp,
                                   l_viagem,'A',1,
                                   TODAY,
                                   l_cod_fornecedor,
                                   l_val_tot_nf,
                                   'INCLUSAO VIA CDV2000',
                                   l_ies_dep_cred,
                                   l_banco, l_agencia, l_cta_corrente,
                                   '','','','','','',
                                   TODAY)

     RETURNING l_work, l_msg, l_num_ad, m_num_ap

  IF NOT l_work THEN
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN l_work
  END IF

  #--# Grava detalhamento das despesas #--#

  #--# Busca Despesas Pr�prias #--#
  WHENEVER ERROR CONTINUE
    SELECT SUM(val_despesa_urbana)
      INTO l_val_desp_propria
      FROM cdv_tdesp_viag_781, cdv_desp_urb_781
     WHERE cdv_tdesp_viag_781.empresa          = p_cod_empresa
       AND cdv_desp_urb_781.empresa            = p_cod_empresa
       AND cdv_desp_urb_781.viagem             = l_viagem
       AND cdv_desp_urb_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
       AND cdv_desp_urb_781.ativ               = cdv_tdesp_viag_781.ativ
       AND cdv_tdesp_viag_781.eh_reembolso     = 'N'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_mensagem('Problema busca pelo valor de despesas pr�prias.','exclamation')
     RETURN FALSE
  ELSE
     IF l_val_desp_propria IS NULL THEN
        LET l_val_desp_propria = 0
     END IF
  END IF

  #--# Busca Despesas Reembolso #--#
  WHENEVER ERROR CONTINUE
    SELECT SUM(val_despesa_urbana)
      INTO l_val_desp_reembolso
      FROM cdv_tdesp_viag_781, cdv_desp_urb_781
     WHERE cdv_tdesp_viag_781.empresa          = p_cod_empresa
       AND cdv_desp_urb_781.empresa            = p_cod_empresa
       AND cdv_desp_urb_781.viagem             = l_viagem
       AND cdv_desp_urb_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
       AND cdv_desp_urb_781.ativ               = cdv_tdesp_viag_781.ativ
       AND cdv_tdesp_viag_781.eh_reembolso     = 'S'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_mensagem('Problema busca pelo valor de despesas urbanas.','exclamation')
     RETURN FALSE
  ELSE
     IF l_val_desp_reembolso IS NULL THEN
        LET l_val_desp_reembolso = 0
     END IF
  END IF

  #--# Busca Despesas Quilometragem #--#
  WHENEVER ERROR CONTINUE
    SELECT SUM(val_km)
      INTO l_val_despesa_km
      FROM cdv_tdesp_viag_781, cdv_despesa_km_781
     WHERE cdv_tdesp_viag_781.empresa            = p_cod_empresa
       AND cdv_despesa_km_781.empresa            = p_cod_empresa
       AND cdv_despesa_km_781.viagem             = l_viagem
       AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
       AND cdv_despesa_km_781.ativ_km            = cdv_tdesp_viag_781.ativ
       AND cdv_tdesp_viag_781.grp_despesa_viagem = '2'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_mensagem('Problema busca pelo valor de despesas quilometragem.','exclamation')
     RETURN FALSE
  ELSE
     IF l_val_despesa_km IS NULL THEN
        LET l_val_despesa_km = 0
     END IF
  END IF

  #--# Inclui registro de detalhamento da despesa #--#
  WHENEVER ERROR CONTINUE
    INSERT INTO cdv_desp_det_781 (empresa,
                                  apropriacao_desp,
                                  val_desp_propria,
                                  val_desp_reembolso,
                                  val_despesa_km)
                          VALUES (p_cod_empresa,
                                  l_num_ad,
                                  l_val_desp_propria,
                                  l_val_desp_reembolso,
                                  l_val_despesa_km)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('INSERT','cdv_desp_det_781')
     RETURN FALSE
  END IF
  #--# Fim Grava detalhamento das despesas #--#

  IF mr_input.viagem = l_viagem THEN
     LET mr_input.ad_acerto_conta = l_num_ad
     LET mr_input.ap_acerto_conta = m_num_ap
     LET mr_input.des_status = 'ACERTO VIAGEM FINALIZADO'
     DISPLAY BY NAME mr_input.ad_acerto_conta, mr_input.ap_acerto_conta, mr_input.des_status
  END IF

  IF NOT cdv0804_geracao_aen(l_num_ad) THEN
     RETURN FALSE
  END IF

  IF NOT cdv2000_gera_aprovacao_eletronica(l_viagem, l_num_ad, m_num_ap, 'A') THEN
     RETURN FALSE
  END IF

  IF NOT cdv2000_efetua_baixa_adtos_relac_viagem(l_viagem, l_val_tot_nf, m_num_ap) THEN
     RETURN FALSE
  END IF

  IF NOT cdv2000_gera_dev_transf(l_viagem, l_num_ad, m_num_ap) THEN
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2000_retorna_fornec(l_viagem)
#---------------------------------------------#
  DEFINE l_cod_fornecedor LIKE ad_mestre.cod_fornecedor,
         l_cod_funcio     LIKE cdv_fornecedor_fun.cod_funcio,
         l_matricula      LIKE cdv_info_viajante.matricula,
         l_viagem         LIKE cdv_solic_viag_781.viagem

  INITIALIZE l_cod_fornecedor, l_matricula, l_cod_funcio  TO NULL

  WHENEVER ERROR CONTINUE
   SELECT cdv_info_viajante.matricula
     INTO l_matricula
     FROM cdv_info_viajante, cdv_solic_viag_781
    WHERE cdv_solic_viag_781.empresa   = p_cod_empresa
      AND cdv_solic_viag_781.viagem    = l_viagem
      AND cdv_info_viajante.empresa   = cdv_solic_viag_781.empresa
      AND cdv_info_viajante.matricula = cdv_solic_viag_781.viajante
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECAO','cdv_info_viajante2')
  END IF

  LET l_cod_funcio = l_matricula

  WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO l_cod_fornecedor
     FROM cdv_fornecedor_fun
    WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','cdv_fornecedor_fun')
  END IF

  RETURN l_cod_fornecedor

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION cdv2000_recupera_dados_bancarios_fornec(l_cod_fornecedor)
#------------------------------------------------------------------#
  DEFINE l_cod_fornecedor      LIKE fornecedor.cod_fornecedor,
         l_ies_dep_cred        LIKE ad_mestre.ies_dep_cred,
         l_cod_banco           LIKE fornecedor.cod_banco,
         l_num_agencia         LIKE fornecedor.num_agencia,
         l_num_conta_banco     LIKE fornecedor.num_conta_banco

  WHENEVER ERROR CONTINUE
   SELECT cod_banco, num_agencia, num_conta_banco, ies_dep_cred
     INTO l_cod_banco, l_num_agencia, l_num_conta_banco, l_ies_dep_cred
     FROM fornecedor
    WHERE cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','fornecedor')
  END IF

  IF l_ies_dep_cred IS NULL THEN
     INITIALIZE l_cod_banco, l_num_agencia, l_num_conta_banco TO NULL
  END IF

  RETURN l_cod_banco, l_num_agencia, l_num_conta_banco, l_ies_dep_cred

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_verifica_viagem_receb(l_viagem)
#-----------------------------------------------#
 DEFINE l_viagem       LIKE cdv_dev_transf_781.viagem_receb,
        l_dat_hor      LIKE cdv_solic_viag_781.dat_hor_partida,
        l_dat_hor_curr LIKE cdv_solic_viag_781.dat_hor_partida,
        l_status       LIKE cdv_acer_viag_781.status_acer_viagem,
        l_controle     LIKE cdv_solic_viag_781.controle

 WHENEVER ERROR CONTINUE
 SELECT dat_hor_partida, controle
   INTO l_dat_hor, l_controle
   FROM cdv_solic_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 LET mr_dev_transf.controle_receb = l_controle
 DISPLAY BY NAME mr_dev_transf.controle_receb

 IF SQLCA.sqlcode = NOTFOUND THEN
    CALL log0030_mensagem('Viagem n�o cadastrada.','exclamation')
    RETURN FALSE
 END IF

 LET l_dat_hor_curr = cdv2000_data_hora(mr_input.dat_partida, mr_input.hor_partida)

 IF l_dat_hor < l_dat_hor_curr THEN
    CALL log0030_mensagem("Data da viagem recebedora anterior a data da viagem corrente.","info")
    RETURN FALSE
 END IF

 LET l_status = cdv2000_recupera_status_viag(l_viagem)

 IF l_status = '3' THEN
    CALL log0030_mensagem('Viagem j� possui acerto finalizado.','exclamation')
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_data_hora(l_data, l_hora)
#-----------------------------------------#
 DEFINE l_data      CHAR(10),
        l_hora      CHAR(10),
        l_data_hr   CHAR(20)

 LET l_data_hr = l_data[7,10],'-',
                 l_data[4,5], '-',
                #l_data[1,2], ' ','23:59:59'
                #OS459347
                 l_data[1,2], ' ','24:00:00'

 RETURN l_data_hr
 END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_verifica_forma(l_forma)
#---------------------------------------#
 DEFINE l_forma      CHAR(1),
        l_den_forma  CHAR(25)

 CASE l_forma
 WHEN '1'
    LET mr_dev_transf.den_forma = 'DEVOLU��O BANCO'
    DISPLAY mr_dev_transf.den_forma TO den_forma
    RETURN TRUE
 WHEN '2'
    LET mr_dev_transf.den_forma = 'DEVOLU��O CAIXA'
    DISPLAY mr_dev_transf.den_forma TO den_forma
    RETURN TRUE
 OTHERWISE
    LET mr_dev_transf.den_forma = ''
    DISPLAY mr_dev_transf.den_forma TO den_forma
    RETURN FALSE
 END CASE

 END FUNCTION

#---------------------------------------#
 FUNCTION cdv2000_verifica_caixa(l_caixa)
#---------------------------------------#
 DEFINE l_caixa     LIKE cdv_dev_transf_781.caixa,
        l_den_caixa LIKE ctrl_caixa.den_caixa,
        l_dat_fech  LIKE saldo_caixa_cap.dat_saldo

 INITIALIZE mr_dev_transf.den_caixa TO NULL

 WHENEVER ERROR CONTINUE
 SELECT den_caixa
   INTO mr_dev_transf.den_caixa
   FROM ctrl_caixa
  WHERE cod_empresa = p_cod_empresa
    AND cod_caixa   = l_caixa
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_dev_transf.den_caixa

 IF SQLCA.sqlcode <> 0 THEN
    CALL log0030_mensagem('Caixa n�o cadastrado.','exclamation')
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_caixa CURSOR FOR
 SELECT dat_saldo
   FROM saldo_caixa_cap
  WHERE cod_empresa = p_cod_empresa
    AND cod_caixa   = l_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_CAIXA")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_caixa INTO l_dat_fech
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_CAIXA")
    END IF

    IF l_dat_fech <= mr_dev_transf.dat_devolucao THEN
       RETURN TRUE
    END IF
 END FOREACH
 WHENEVER ERROR CONTINUE
 FREE cq_caixa
 WHENEVER ERROR STOP

 CALL log0030_mensagem('Data de fechamento do caixa inferior a data de devolu��o.','exclamation')

 RETURN FALSE
 END FUNCTION

#-----------------------------#
 FUNCTION cdv2000_busca_banco()
#-----------------------------#
 INITIALIZE mr_dev_transf.banco, mr_dev_transf.den_banco TO NULL

 WHENEVER ERROR CONTINUE
 SELECT banco_empresa
   INTO mr_dev_transf.banco
   FROM cdv_par_ctr_viagem
  WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_dev_transf.banco

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT nom_banco
   INTO mr_dev_transf.den_banco
   FROM bancos
  WHERE cod_banco = mr_dev_transf.banco
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE mr_dev_transf.den_banco TO NULL
    RETURN FALSE
 END IF

 DISPLAY mr_dev_transf.den_banco TO den_banco

 RETURN TRUE

 END FUNCTION

#-----------------------------#
 FUNCTION cdv2000_busca_agencia()
#-----------------------------#
 INITIALIZE mr_dev_transf.agencia TO NULL

 WHENEVER ERROR CONTINUE
 SELECT agencia_empresa
   INTO mr_dev_transf.agencia
   FROM cdv_par_ctr_viagem
  WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_dev_transf.agencia

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_busca_cta_corrente()
#------------------------------------#
 INITIALIZE mr_dev_transf.cta_corrente TO NULL

 WHENEVER ERROR CONTINUE
 SELECT ccorr_empresa
   INTO mr_dev_transf.cta_corrente
   FROM cdv_par_ctr_viagem
  WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_dev_transf.cta_corrente

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_existe_dev(l_viagem)
#-------------------------------------#
  DEFINE l_viagem  LIKE cdv_acer_viag_781.viagem

  WHENEVER ERROR CONTINUE
   SELECT viagem
     FROM cdv_dev_transf_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#----------------------------------------------------------------------------------#
 FUNCTION cdv2000_efetua_baixa_adtos_relac_viagem(l_viagem, l_val_baixar, m_num_ap)
#----------------------------------------------------------------------------------#
  DEFINE l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_val_baixar          LIKE ad_mestre.val_tot_nf,
         m_num_ap              LIKE ap.num_ap,
         l_val_saldo_adiant    LIKE adiant.val_saldo_adiant,
         l_num_ad_nf_orig      LIKE adiant.num_ad_nf_orig,
         l_ser_nf              LIKE adiant.ser_nf,
         l_ssr_nf              LIKE adiant.ssr_nf,
         l_cod_fornecedor      LIKE adiant.cod_fornecedor,
         l_tip_val_adiant      LIKE tipo_despesa.cod_tip_val_adiant,
         l_val_mov             LIKE mov_adiant.val_mov,
         l_hor_mov             LIKE mov_adiant.hor_mov,
         l_num_seq             SMALLINT

  INITIALIZE l_hor_mov TO NULL
  LET l_num_seq = 0

  WHENEVER ERROR CONTINUE
   DECLARE cq_bx_adtos CURSOR FOR
    SELECT val_saldo_adiant, num_ad_nf_orig, ser_nf, ssr_nf, cod_fornecedor
      FROM adiant
     WHERE cod_empresa     = p_cod_empresa
       AND num_ad_nf_orig IN (SELECT num_ad_adto_viagem
                                FROM cdv_solic_adto_781
                               WHERE empresa = p_cod_empresa
                                 AND viagem  = l_viagem)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_bx_adtos')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_bx_adtos INTO l_val_saldo_adiant, l_num_ad_nf_orig, l_ser_nf, l_ssr_nf, l_cod_fornecedor
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_bx_adtos')
        RETURN FALSE
     END IF

     IF l_val_baixar = 0 THEN
        EXIT FOREACH
     END IF

     IF l_val_saldo_adiant >= l_val_baixar THEN
        LET l_val_mov = l_val_baixar
        LET l_val_baixar = 0
     ELSE
        LET l_val_mov = l_val_saldo_adiant
        LET l_val_baixar = l_val_baixar - l_val_saldo_adiant
     END IF

     WHENEVER ERROR CONTINUE
      UPDATE adiant
         SET val_saldo_adiant = val_saldo_adiant - l_val_mov
       WHERE cod_empresa    = p_cod_empresa
         AND num_ad_nf_orig = l_num_ad_nf_orig
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','adiant')
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      SELECT cod_tip_val_adiant
        INTO l_tip_val_adiant
        FROM tipo_despesa, ad_mestre
       WHERE tipo_despesa.cod_empresa     = p_cod_empresa
         AND tipo_despesa.cod_tip_despesa = ad_mestre.cod_tip_despesa
         AND ad_mestre.cod_empresa        = tipo_despesa.cod_empresa
         AND ad_mestre.num_ad             = l_num_ad_nf_orig
     WHENEVER ERROR CONTINUE
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','tipo_despesa/ad_mestre')
        RETURN FALSE
     END IF

     IF l_hor_mov IS NOT NULL THEN
        SLEEP 1
     END IF

     LET l_hor_mov = log0300_current(g_ies_ambiente)
     LET l_val_saldo_adiant = l_val_saldo_adiant - l_val_mov

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
                      VALUES (p_cod_empresa,
                              TODAY,
                              'B',
                              l_cod_fornecedor,
                              l_num_ad_nf_orig,
                              l_ser_nf,
                              l_ssr_nf,
                              l_val_mov,
                              l_val_saldo_adiant,
                              '2',
                              m_num_ap,
                              l_tip_val_adiant,
                              l_hor_mov)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('INSERT','adiant')
        RETURN FALSE
     END IF

     LET l_num_seq = l_num_seq + 1

     IF NOT cdv2000_insert_ap_valores(p_cod_empresa, m_num_ap, 1, 'S', l_num_seq, l_tip_val_adiant, l_val_mov) THEN
        RETURN FALSE
     END IF

  END FOREACH
  FREE cq_bx_adtos

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_gera_aprovacao_eletronica(l_viagem, l_num_ad, m_num_ap, l_acerto_transf)
#---------------------------------------------------------------------------------------------#
  DEFINE l_viagem         LIKE cdv_acer_viag_781.viagem,
         l_num_ad         LIKE ad_mestre.num_ad,
         m_num_ap         LIKE ap.num_ap,
         l_acerto_transf  CHAR(01)

  ERROR "Enviando acerto de despesa de viagem para aprova��o eletr�nica ..." ATTRIBUTE(REVERSE)
  SLEEP 1

  CALL cdv0803_envia_email_aprov_eletronica(TRUE, "cdv", "S", l_viagem, l_num_ad,
                                            m_num_ap, l_acerto_transf)
     RETURNING p_status

  IF p_status THEN
     CALL log0030_mensagem('Problema envio acerto para aprova��o eletr�nica (1).','exclamation')
     RETURN FALSE
  END IF

  CALL cdv0803_envia_email_aprov_eletronica(FALSE, "cdv", "S", l_viagem, l_num_ad,
                                            m_num_ap, l_acerto_transf)
    RETURNING p_status

  IF p_status THEN
     CALL log0030_mensagem('Problema envio acerto para aprova��o eletr�nica (2).','exclamation')
     RETURN FALSE
  END IF

  IF NOT cdv0803_atualiza_dados_ad_acerto(l_num_ad, m_num_ap, l_viagem, l_acerto_transf) THEN
     RETURN TRUE
  END IF

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2000

  RETURN TRUE

END FUNCTION


#--------------------------------------------------------------#
 FUNCTION cdv2000_gera_dev_transf(l_viagem, l_num_ad, m_num_ap)
#--------------------------------------------------------------#
  DEFINE l_viagem             LIKE cdv_acer_viag_781.viagem,
         l_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
         l_observ             LIKE ad_mestre.observ,
         l_msg                CHAR(100),
         l_num_ad             LIKE ad_mestre.num_ad,
         m_num_ap             LIKE ap.num_ap,
         l_work               SMALLINT,
         l_ssr_nf             LIKE ad_mestre.ssr_nf,
         l_sequencia_adto     SMALLINT,
         l_num_dep            LIKE par_cap_pad.par_num,
         l_ies_favorecido     CHAR(01),
         l_banco_favor        LIKE deposito_cap.banco_favor,
         l_num_agencia_favor  LIKE deposito_cap.num_agencia_favor,
         l_num_conta_favor    LIKE deposito_cap.num_conta_favor,
         l_num_ad_transf      LIKE ad_mestre.num_ad,
         m_num_ap_transf      LIKE ad_mestre.num_ad

  IF NOT cdv2000_carrega_devolucao(l_viagem) THEN
     RETURN FALSE
  END IF

  IF mr_proc_dev_transf.val_devolucao IS NOT NULL THEN

     WHENEVER ERROR CONTINUE # OS 536710 Bira
     UPDATE cdv_dev_transf_781
        SET ad_dev_transf = l_num_ad
      WHERE empresa       = p_cod_empresa
        AND viagem        = l_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE  <> 0 THEN
        CALL log003_err_sql("UPDATE","CDV_DEV_TRANSF_781_DEV")
        RETURN FALSE
     END IF # OS 536710---

     WHENEVER ERROR CONTINUE
      SELECT par_num
        INTO l_num_dep
        FROM par_cap_pad
       WHERE cod_empresa   = p_cod_empresa
         AND cod_parametro = "num_ult_dep"
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 0 THEN

        LET l_num_dep = l_num_dep + 1

        WHENEVER ERROR CONTINUE
         UPDATE par_cap_pad
            SET par_num = l_num_dep
          WHERE cod_empresa   = p_cod_empresa
            AND cod_parametro = "num_ult_dep"
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE  <> 0 THEN
           CALL log003_err_sql("UPDATE","num_ult_dep")
           RETURN FALSE
        END IF
     ELSE
        CALL log003_err_sql("SELECT","num_ult_dep")
        RETURN FALSE
     END IF

     IF mr_proc_dev_transf.forma_devolucao = 2 THEN
         LET l_ies_favorecido    = "C"
         LET l_banco_favor       = mr_proc_dev_transf.caixa
         LET l_num_agencia_favor = NULL
         LET l_num_conta_favor   = NULL
     ELSE
         LET l_ies_favorecido    = "B"
         LET l_banco_favor       = mr_proc_dev_transf.banco
         LET l_num_agencia_favor = mr_proc_dev_transf.agencia
         LET l_num_conta_favor   = mr_proc_dev_transf.cta_corrente
     END IF

     IF mr_proc_dev_transf.dat_doc_devolucao IS NULL OR mr_proc_dev_transf.dat_doc_devolucao = " "
        OR mr_proc_dev_transf.dat_doc_devolucao = '31/12/1899' THEN
        LET mr_proc_dev_transf.dat_doc_devolucao = mr_dev_transf.dat_devolucao
     END IF

     WHENEVER ERROR CONTINUE
      INSERT INTO deposito_cap (cod_empresa,
                                num_ad,
                                num_deposito,
                                ies_favorecido,
                                banco_favor,
                                num_agencia_favor,
                                num_conta_favor,
                                val_deposito,
                                dat_deposito)
                        VALUES (p_cod_empresa,
                                l_num_ad,
                                l_num_dep,
                                l_ies_favorecido,
                                l_banco_favor,
                                l_num_agencia_favor,
                                l_num_conta_favor,
                                mr_proc_dev_transf.val_devolucao,
                                mr_proc_dev_transf.dat_doc_devolucao)
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql("INSERT","deposito_cap")
        RETURN FALSE
     END IF

     IF mr_proc_dev_transf.forma_devolucao = 1 THEN
        WHENEVER ERROR CONTINUE
         INSERT INTO cheque_bordero (cod_empresa,
                                     cod_bco_pagador,
                                     num_cheq_bord,
                                     num_conta_banco,
                                     ies_cheq_bord,
                                     ies_banc_fornec,
                                     banco_favor,
                                     cod_fornec_favor,
                                     ies_aut_man,
                                     valor_cheque,
                                     cod_lote,
                                     dat_emissao,
                                     dat_proposta,
                                     num_lote_conc,
                                     num_versao,
                                     ies_cancelado,
                                     num_seq_conc,
                                     ies_mutuo,
                                     cod_emp_ced_tom,
                                     num_ad_ced_mutuo)
                             VALUES (p_cod_empresa,
                                     mr_proc_dev_transf.banco,
                                     l_num_dep,
                                     mr_proc_dev_transf.cta_corrente,
                                     0,
                                     'B',
                                     mr_proc_dev_transf.banco,
                                     NULL,
                                     'A',
                                     mr_proc_dev_transf.val_devolucao,
                                     1,
                                     mr_proc_dev_transf.dat_doc_devolucao,
                                     mr_proc_dev_transf.dat_doc_devolucao,
                                     0,
                                     NULL,
                                     'N',
                                     0,
                                     'N',
                                     NULL,
                                     NULL)
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE  <> 0 THEN
           CALL log003_err_sql("insert","cheque_bordero")
           RETURN FALSE
        END IF
     END IF
  END IF

  IF mr_proc_dev_transf.val_transf IS NOT NULL THEN

     LET l_cod_fornecedor = cdv2000_retorna_fornec(mr_proc_dev_transf.viagem_receb)
     LET l_observ = "AD DE TRANSFERENCIA DE VALOR DA VIAGEM ",l_viagem
     LET l_ssr_nf = cdv2000_retorna_sub_serie(mr_proc_dev_transf.viagem_receb, l_cod_fornecedor, 'V')

     INITIALIZE t_aen_309_4, t_wlancon323 TO NULL
     LET t_aen_309_4[1].val_aen       = mr_proc_dev_transf.val_transf
     LET t_aen_309_4[1].cod_lin_prod  = m_empresa_atendida_pamcary
     LET t_aen_309_4[1].cod_lin_recei = m_segundo_nivel_aen
     LET t_aen_309_4[1].cod_seg_merc  = m_segmto_mercado_pamcary
     LET t_aen_309_4[1].cod_cla_uso   = m_classe_uso_pamcary

     CALL cdv2000_monta_aen4()

     CALL cap309_gera_informacoes_cap("S",
                                      m_tip_desp_adto_viag,
                                      mr_proc_dev_transf.viagem_receb, "V",l_ssr_nf,
                                      TODAY,
                                      l_cod_fornecedor,
                                      mr_proc_dev_transf.val_transf,
                                      l_observ,
                                      'N','','','','','','','','','',
                                      TODAY)

        RETURNING l_work, l_msg, l_num_ad_transf, m_num_ap_transf

     IF NOT l_work THEN
        CALL log0030_mensagem(l_msg,'exclamation')
        RETURN FALSE
     END IF

     IF NOT cdv0804_geracao_aen(l_num_ad_transf) THEN
        RETURN FALSE
     END IF

     IF NOT cdv0803_atualiza_dados_ad_acerto(l_num_ad_transf, l_viagem, m_num_ap_transf, 'T') THEN
        RETURN FALSE
     END IF

     IF NOT cdv2000_insert_ap_valores(p_cod_empresa, m_num_ap_transf, 1, 'S', 1,
                                      m_tip_val_transf, mr_proc_dev_transf.val_transf) THEN
        RETURN FALSE
     END IF

     LET l_sequencia_adto = cdv2000_recupera_mx_seq_adto(mr_proc_dev_transf.viagem_receb)

     WHENEVER ERROR CONTINUE # OS 536710 Bira
     UPDATE cdv_dev_transf_781
        SET ad_dev_transf  = l_num_ad_transf
      WHERE empresa        = p_cod_empresa
        AND viagem         = l_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE  <> 0 THEN
        CALL log003_err_sql("UPDATE","CDV_DEV_TRANSF_781_TRANSF")
        RETURN FALSE
     END IF # OS 536710---



     WHENEVER ERROR CONTINUE
      INSERT INTO cdv_solic_adto_781 (empresa,
                                      viagem,
                                      sequencia_adto,
                                      dat_adto_viagem,
                                      val_adto_viagem,
                                      forma_adto_viagem,
                                      banco,
                                      agencia,
                                      cta_corrente,
                                      num_ad_adto_viagem)
                              VALUES (p_cod_empresa,
                                      mr_proc_dev_transf.viagem_receb,
                                      l_sequencia_adto,
                                      TODAY,
                                      mr_proc_dev_transf.val_transf,
                                      'DN',
                                      NULL,
                                      NULL,
                                      NULL,
                                      l_num_ad_transf)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('','cdv_solic_adto_781')
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION cdv2000_retorna_sub_serie(l_viagem, l_cod_fornecedor, l_ser_nf)
#----------------------------------------------------------------------------#
  DEFINE l_ssr_nf           LIKE ad_mestre.ssr_nf,
         l_viagem           LIKE ad_mestre.num_nf,
         l_cod_fornecedor   LIKE fornecedor.cod_fornecedor,
         l_ser_nf           LIKE ad_mestre.ser_nf

  LET l_ssr_nf = 0

  WHENEVER ERROR CONTINUE
   SELECT MAX(ssr_nf)
     INTO l_ssr_nf
     FROM ad_mestre
    WHERE cod_empresa     = p_cod_empresa
      AND num_nf          = l_viagem
      AND ser_nf          = l_ser_nf
      AND cod_fornecedor  = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','ad_mestre')
     RETURN FALSE
  END IF

  IF l_ssr_nf <> 0 AND l_ssr_nf IS NOT NULL THEN
     LET l_ssr_nf = l_ssr_nf + 1
  ELSE
     LET l_ssr_nf = 1
  END IF

  RETURN l_ssr_nf

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_insert_ap_valores(lr_ap_valores)
#-------------------------------------------------#
  DEFINE lr_ap_valores    RECORD LIKE ap_valores.*

  WHENEVER ERROR CONTINUE
   INSERT INTO ap_valores (cod_empresa,
                           num_ap,
                           num_versao,
                           ies_versao_atual,
                           num_seq,
                           cod_tip_val,
                           valor)
                   VALUES (lr_ap_valores.cod_empresa,
                           lr_ap_valores.num_ap,
                           lr_ap_valores.num_versao,
                           lr_ap_valores.ies_versao_atual,
                           lr_ap_valores.num_seq,
                           lr_ap_valores.cod_tip_val,
                           lr_ap_valores.valor)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('INSERT','ap_valores')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_recupera_mx_seq_adto(l_viagem)
#-----------------------------------------------#
  DEFINE l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_sequencia_adto   SMALLINT

  WHENEVER ERROR CONTINUE
   SELECT MAX(sequencia_adto)
     INTO l_sequencia_adto
     FROM cdv_solic_adto_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_solic_adto_781')
     RETURN l_sequencia_adto
  END IF

  IF l_sequencia_adto IS NULL THEN
     LET l_sequencia_adto = 1
  ELSE
     LET l_sequencia_adto = l_sequencia_adto + 1
  END IF

  RETURN l_sequencia_adto

END FUNCTION

#------------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_gera_contabilizacao_aen_fat(l_num_ad, l_viagem, l_cod_tip_desp, l_val_tot_nf,
                                              l_filial_atendida, l_finalidade_viagem, l_controle)
#------------------------------------------------------------------------------------------------#
  DEFINE l_cod_tip_desp          LIKE tipo_despesa.cod_tip_despesa,
         l_status                SMALLINT,
         l_ies_quando_contab     LIKE tipo_despesa.ies_quando_contab,
         l_num_conta_cred        LIKE tipo_despesa.num_conta_cred,
         l_cod_hist_cred         LIKE tipo_despesa.cod_hist_cred,
         l_cc_debitar            LIKE cad_cc.cod_cent_cust,
         l_val_tot_nf            LIKE ad_mestre.val_tot_nf,
         l_num_ad                LIKE ad_mestre.num_ad,
         l_viagem                LIKE cdv_acer_viag_781.viagem,
         l_filial_atendida       LIKE empresa.cod_empresa,
         l_finalidade_viagem     LIKE cdv_acer_viag_781.finalidade_viagem,
         l_char1                 CHAR(04),
         l_char2                 CHAR(04),
         l_ind_lanc              SMALLINT,
         l_ind_aen               SMALLINT,
         l_ind                   SMALLINT,
         l_cod_hist              LIKE hist_padrao_cap.cod_hist,
         l_controle              LIKE cdv_acer_viag_781.controle,
         l_eh_valorizado_km      LIKE cdv_tdesp_viag_781.eh_valz_km

  DEFINE lr_campos_lanc RECORD
         val_despesa             LIKE cdv_desp_urb_781.val_despesa_urbana,
         eh_reembolso            LIKE cdv_tdesp_viag_781.eh_reembolso,
         cctbl_contab_ad         LIKE cdv_tdesp_viag_781.cctbl_contab_ad,
         tip_despesa_contab      LIKE cdv_tdesp_viag_781.tip_despesa_contab,
         hist_padrao_cap         LIKE cdv_tdesp_viag_781.hist_padrao_cap,
         item                    LIKE cdv_tdesp_viag_781.item,
         ativ                    LIKE cdv_ativ_781.ativ
  END RECORD

  DEFINE lr_cdv_intg_fat_781 RECORD
         viagem              LIKE cdv_intg_fat_781.viagem,
         controle            LIKE cdv_intg_fat_781.controle,
         apropr_desp_acert   LIKE cdv_intg_fat_781.apropr_desp_acerto,
         grp_despesa_viage   LIKE cdv_intg_fat_781.grp_despesa_viagem,
         tip_despesa_viage   LIKE cdv_intg_fat_781.tip_despesa_viagem,
         sequencia_despesa   LIKE cdv_intg_fat_781.sequencia_despesa,
         item                LIKE cdv_intg_fat_781.item,
         item_hor            LIKE cdv_intg_fat_781.item_hor,
         qtd_km_faturada     LIKE cdv_intg_fat_781.qtd_km_faturada,
         qtd_hor_diurnas     LIKE cdv_intg_fat_781.qtd_hor_diurnas,
         qtd_hor_noturnas    LIKE cdv_intg_fat_781.qtd_hor_noturnas
  END RECORD

  LET l_ind_lanc = 1
  LET l_ind_aen  = 1
  INITIALIZE t_aen_309_4, t_wlancon323 TO NULL

  LET lr_cdv_intg_fat_781.viagem            = l_viagem
  LET lr_cdv_intg_fat_781.controle          = l_controle
  LET lr_cdv_intg_fat_781.apropr_desp_acert = l_num_ad

  WHENEVER ERROR CONTINUE
   SELECT ies_quando_contab, num_conta_cred, cod_hist_cred
     INTO l_ies_quando_contab, l_num_conta_cred, l_cod_hist_cred
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_empresa
      AND cod_tip_despesa = l_cod_tip_desp
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','tipo_despesa')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT cc_debitar
     INTO l_cc_debitar
     FROM w_solic
    WHERE viagem = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','w_solic')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_contab_urb CURSOR FOR
     SELECT val_despesa_urbana, eh_reembolso, cctbl_contab_ad, tip_despesa_contab,
            hist_padrao_cap, item, cdv_desp_urb_781.ativ
       FROM cdv_desp_urb_781, cdv_tdesp_viag_781
      WHERE cdv_desp_urb_781.empresa            = p_cod_empresa
        AND cdv_desp_urb_781.viagem             = l_viagem
        AND cdv_desp_urb_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
        AND cdv_desp_urb_781.ativ               = cdv_tdesp_viag_781.ativ
        AND cdv_tdesp_viag_781.empresa          = cdv_desp_urb_781.empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_contab_urb')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_contab_urb INTO lr_campos_lanc.*
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_contab_urb')
        RETURN FALSE
     END IF
     IF lr_campos_lanc.val_despesa = 0 THEN
        CONTINUE FOREACH
     END IF

     LET t_wlancon323[l_ind_lanc].cod_empresa   = p_cod_empresa
     LET t_wlancon323[l_ind_lanc].num_ad_ap     = l_viagem
     LET t_wlancon323[l_ind_lanc].val_lanc      = lr_campos_lanc.val_despesa
     LET t_wlancon323[l_ind_lanc].ies_tipo_lanc = 'D'
     LET t_wlancon323[l_ind_lanc].dat_lanc      = TODAY
     LET t_wlancon323[l_ind_lanc].ies_cnd_pgto  = 'S'

     IF lr_campos_lanc.eh_reembolso = 'S'THEN
        LET t_wlancon323[l_ind_lanc].num_conta_cont = lr_campos_lanc.cctbl_contab_ad
     ELSE
        LET l_char1 = l_cc_debitar
        LET l_char2 = lr_campos_lanc.tip_despesa_contab USING "&&&&"
        LET t_wlancon323[l_ind_lanc].num_conta_cont = l_char1 CLIPPED, l_char2 CLIPPED
     END IF

     LET t_wlancon323[l_ind_lanc].tex_hist_lanc = lr_campos_lanc.hist_padrao_cap

     LET t_aen_309_4[l_ind_aen].val_aen = lr_campos_lanc.val_despesa

     CALL cdv2000_recupera_aen(lr_campos_lanc.item, l_filial_atendida, lr_campos_lanc.ativ, l_finalidade_viagem)
        RETURNING t_aen_309_4[l_ind_aen].cod_lin_prod, t_aen_309_4[l_ind_aen].cod_lin_recei,
                  t_aen_309_4[l_ind_aen].cod_seg_merc, t_aen_309_4[l_ind_aen].cod_cla_uso

     IF t_aen_309_4[l_ind_aen].cod_lin_prod IS NULL OR
        t_aen_309_4[l_ind_aen].cod_lin_recei IS NULL OR
        t_aen_309_4[l_ind_aen].cod_seg_merc IS NULL OR
        t_aen_309_4[l_ind_aen].cod_cla_uso IS NULL THEN
        RETURN FALSE
     END IF

     LET l_ind_lanc = l_ind_lanc + 1
     LET l_ind_aen  = l_ind_aen + 1

  END FOREACH
  WHENEVER ERROR CONTINUE
  FREE cq_contab_urb
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   DECLARE cq_contab_km CURSOR FOR
    SELECT val_km, eh_reembolso, cctbl_contab_ad, tip_despesa_contab,
           hist_padrao_cap, item, ativ, eh_valz_km
      FROM cdv_despesa_km_781, cdv_tdesp_viag_781
     WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
       AND cdv_despesa_km_781.viagem             = l_viagem
       AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
       AND cdv_despesa_km_781.ativ_km            = cdv_tdesp_viag_781.ativ
       AND cdv_tdesp_viag_781.empresa            = cdv_despesa_km_781.empresa
       AND cdv_tdesp_viag_781.grp_despesa_viagem = '2'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('FOREACH','cq_contab_km')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   OPEN cq_contab_km
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('OPEN','cq_contab_km')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FETCH cq_contab_km INTO lr_campos_lanc.*, l_eh_valorizado_km
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('FOREACH','cq_contab_km')
     RETURN FALSE
  END IF

  WHILE SQLCA.SQLCODE = 0
     IF lr_campos_lanc.val_despesa = 0 THEN
        WHENEVER ERROR CONTINUE
         FETCH cq_contab_km INTO lr_campos_lanc.*, l_eh_valorizado_km
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
           CALL log003_err_sql('FOREACH','cq_contab_km')
           RETURN FALSE
        END IF
        CONTINUE WHILE
     END IF

     IF l_eh_valorizado_km = 'N' THEN
        WHENEVER ERROR CONTINUE
         FETCH cq_contab_km INTO lr_campos_lanc.*, l_eh_valorizado_km
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
           CALL log003_err_sql('FOREACH','cq_contab_km')
           RETURN FALSE
        END IF
        CONTINUE WHILE
     END IF

     LET t_wlancon323[l_ind_lanc].cod_empresa   = p_cod_empresa
     LET t_wlancon323[l_ind_lanc].num_ad_ap     = l_viagem
     LET t_wlancon323[l_ind_lanc].val_lanc      = lr_campos_lanc.val_despesa
     LET t_wlancon323[l_ind_lanc].ies_tipo_lanc = 'D'
     LET t_wlancon323[l_ind_lanc].dat_lanc      = TODAY
     LET t_wlancon323[l_ind_lanc].ies_cnd_pgto  = 'S'

     IF lr_campos_lanc.eh_reembolso = 'S'THEN
        LET t_wlancon323[l_ind_lanc].num_conta_cont = lr_campos_lanc.cctbl_contab_ad
     ELSE
        LET l_char1 = l_cc_debitar
        LET l_char2 = lr_campos_lanc.tip_despesa_contab USING "&&&&"
        LET t_wlancon323[l_ind_lanc].num_conta_cont = l_char1 CLIPPED, l_char2 CLIPPED
     END IF

     IF l_eh_valorizado_km = 'S' THEN    #Monta conta_contab
        LET l_char1 = l_cc_debitar
        LET l_char2 = lr_campos_lanc.tip_despesa_contab USING "&&&&"
        LET t_wlancon323[l_ind_lanc].num_conta_cont = l_char1 CLIPPED, l_char2 CLIPPED
     END IF

     LET t_wlancon323[l_ind_lanc].tex_hist_lanc = lr_campos_lanc.hist_padrao_cap

     LET t_aen_309_4[l_ind_aen].val_aen = lr_campos_lanc.val_despesa

     CALL cdv2000_recupera_aen(lr_campos_lanc.item, l_filial_atendida, lr_campos_lanc.ativ, l_finalidade_viagem)
        RETURNING t_aen_309_4[l_ind_aen].cod_lin_prod, t_aen_309_4[l_ind_aen].cod_lin_recei,
                  t_aen_309_4[l_ind_aen].cod_seg_merc, t_aen_309_4[l_ind_aen].cod_cla_uso

     IF t_aen_309_4[l_ind_aen].cod_lin_prod IS NULL OR
        t_aen_309_4[l_ind_aen].cod_lin_recei IS NULL OR
        t_aen_309_4[l_ind_aen].cod_seg_merc IS NULL OR
        t_aen_309_4[l_ind_aen].cod_cla_uso IS NULL THEN
        RETURN FALSE
     END IF

     LET l_ind_lanc = l_ind_lanc + 1
     LET l_ind_aen  = l_ind_aen + 1

     WHENEVER ERROR CONTINUE
      FETCH cq_contab_km INTO lr_campos_lanc.*, l_eh_valorizado_km
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
        CALL log003_err_sql('FOREACH','cq_contab_km')
        RETURN FALSE
     END IF
  END WHILE
  CLOSE cq_contab_km
  FREE cq_contab_km

  ### CREDITO ###
  LET t_wlancon323[l_ind_lanc].cod_empresa    = p_cod_empresa
  LET t_wlancon323[l_ind_lanc].num_ad_ap      = l_viagem
  LET t_wlancon323[l_ind_lanc].ies_tipo_lanc  = 'C'
  LET t_wlancon323[l_ind_lanc].dat_lanc       = TODAY
  LET t_wlancon323[l_ind_lanc].ies_cnd_pgto   = 'S'
  LET t_wlancon323[l_ind_lanc].val_lanc       = l_val_tot_nf
  LET t_wlancon323[l_ind_lanc].num_conta_cont = l_num_conta_cred
  LET t_wlancon323[l_ind_lanc].tex_hist_lanc  = l_cod_hist_cred

  ### D�BITO CASO HAJA DEVOLU��O/TRANSFER�NCIA ###
  IF NOT cdv2000_carrega_devolucao(l_viagem) THEN
     RETURN FALSE
  END IF

  IF mr_proc_dev_transf.val_devolucao IS NOT NULL OR mr_proc_dev_transf.val_transf IS NOT NULL THEN

     LET l_ind_lanc = l_ind_lanc + 1
     LET t_wlancon323[l_ind_lanc].cod_empresa    = p_cod_empresa
     LET t_wlancon323[l_ind_lanc].num_ad_ap      = l_viagem
     LET t_wlancon323[l_ind_lanc].ies_tipo_lanc  = 'D'
     LET t_wlancon323[l_ind_lanc].dat_lanc       = TODAY
     LET t_wlancon323[l_ind_lanc].ies_cnd_pgto   = 'S'
     LET t_wlancon323[l_ind_lanc].tex_hist_lanc  = m_h_pad_restitui_cap

     LET t_aen_309_4[l_ind_aen].cod_lin_prod  = m_empresa_atendida_pamcary
     LET t_aen_309_4[l_ind_aen].cod_lin_recei = m_segundo_nivel_aen
     LET t_aen_309_4[l_ind_aen].cod_seg_merc  = m_segmto_mercado_pamcary
     LET t_aen_309_4[l_ind_aen].cod_cla_uso   = m_classe_uso_pamcary

     IF mr_proc_dev_transf.val_devolucao IS NOT NULL THEN

        LET t_wlancon323[l_ind_lanc].val_lanc = mr_proc_dev_transf.val_devolucao
        LET t_aen_309_4[l_ind_aen].val_aen = mr_proc_dev_transf.val_devolucao

        IF mr_proc_dev_transf.forma_devolucao = '2' THEN
           WHENEVER ERROR CONTINUE
            SELECT conta_cont_caixa
              INTO t_wlancon323[l_ind_lanc].num_conta_cont
              FROM ctrl_caixa
             WHERE cod_empresa = p_cod_empresa
               AND cod_caixa   = mr_proc_dev_transf.caixa
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql('SELECT','ctrl_caixa')
              RETURN FALSE
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
            SELECT agencia_bc_item.num_conta_cont
              INTO t_wlancon323[l_ind_lanc].num_conta_cont
              FROM agencia_bco,agencia_bc_item
             WHERE agencia_bco.cod_banco          = mr_proc_dev_transf.banco
               AND agencia_bco.num_agencia        = mr_proc_dev_transf.agencia
               AND agencia_bc_item.cod_agen_bco   = agencia_bco.cod_agen_bco
               AND agencia_bc_item.cod_empresa    = p_cod_empresa
               AND agencia_bc_item.num_conta_banc = mr_proc_dev_transf.cta_corrente
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql("SELECT", "agencia_bco")
              RETURN FALSE
           END IF
        END IF
      ELSE
        LET t_wlancon323[l_ind_lanc].val_lanc = mr_proc_dev_transf.val_transf
        LET t_aen_309_4[l_ind_aen].val_aen = mr_proc_dev_transf.val_transf

        WHENEVER ERROR CONTINUE
         SELECT num_conta_cred
           INTO t_wlancon323[l_ind_lanc].num_conta_cont
           FROM tipo_valor
          WHERE cod_empresa = p_cod_empresa
            AND cod_tip_val = m_tip_val_transf
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 OR t_wlancon323[l_ind_lanc].num_conta_cont IS NULL THEN # OS 536710 Bira
           CALL log0030_mensagem("Conta cr�dito tipo valor transfer�ncia n�o informada.",'exclamation')
           RETURN FALSE
        END IF
     END IF

  END IF

  FOR l_ind = 1 TO l_ind_lanc
     LET l_cod_hist = t_wlancon323[l_ind].tex_hist_lanc CLIPPED
     WHENEVER ERROR CONTINUE
      SELECT historico
        INTO t_wlancon323[l_ind].tex_hist_lanc
        FROM hist_padrao_cap
       WHERE cod_hist  = l_cod_hist
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECAO','hist_padrao_cap')
        RETURN FALSE
     END IF
  END FOR

  RETURN TRUE

END FUNCTION

#-------------------------------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_gera_ads_quilometragem_semanal(l_viagem, l_cod_fornecedor, l_filial_atendida, l_finalidade_viagem)
#-------------------------------------------------------------------------------------------------------------------#
  DEFINE l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_cod_fornecedor      LIKE fornecedor.cod_fornecedor,
         l_filial_atendida     LIKE empresa.cod_empresa,
         l_finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         l_val_km              LIKE cdv_despesa_km_781.val_km,
         l_dat_despesa_km      LIKE cdv_despesa_km_781.dat_despesa_km,
         l_banco               LIKE cdv_dev_transf_781.banco,
         l_agencia             LIKE cdv_dev_transf_781.agencia,
         l_cta_corrente        LIKE cdv_dev_transf_781.cta_corrente,
         l_cc_debitar          LIKE cad_cc.cod_cent_cust,
         l_ies_dep_cred        CHAR(01),
         l_ssr_nf              LIKE ad_mestre.ssr_nf,
         l_work                SMALLINT,
         l_msg                 CHAR(100),
         l_char1               CHAR(04),
         l_char2               CHAR(04),
         l_num_ad              LIKE ad_mestre.num_ad,
         l_for                 INTEGER,
         m_num_ap              LIKE ap.num_ap,
         l_item                LIKE cdv_tdesp_viag_781.item,
         l_ativ                LIKE cdv_tdesp_viag_781.ativ,
         l_eh_valorizado_km    LIKE cdv_tdesp_viag_781.eh_valz_km,
         l_conta_contab        LIKE cdv_tdesp_viag_781.cctbl_contab_ad,
         l_tipo_despesa_contab LIKE cdv_tdesp_viag_781.tip_despesa_contab,
         l_hist_padrao_cap     LIKE cdv_tdesp_viag_781.hist_padrao_cap,
         l_ind                 INTEGER,
         l_texto_historico     LIKE lanc_cont_cap.tex_hist_lanc,
         l_eh_reembolso        LIKE cdv_tdesp_viag_781.eh_reembolso,
         l_status              SMALLINT

  WHENEVER ERROR CONTINUE
   DECLARE cq_km_semanal CURSOR FOR
    SELECT SUM(km.val_km), km.dat_despesa_km, td.item, td.ativ,
           td.eh_valz_km, td.cctbl_contab_ad, td.tip_despesa_contab,
           td.hist_padrao_cap, td.eh_reembolso
      FROM cdv_despesa_km_781 km, cdv_tdesp_viag_781 td
     WHERE km.empresa            = p_cod_empresa
       AND km.viagem             = l_viagem
       AND td.empresa            = km.empresa
       AND km.ativ_km            = td.ativ
       AND td.tip_despesa_viagem = km.tip_despesa_viagem
       AND td.grp_despesa_viagem = '3'
     GROUP BY km.dat_despesa_km, td.item, td.ativ,
              td.eh_valz_km, td.cctbl_contab_ad, td.tip_despesa_contab,
              td.hist_padrao_cap, td.eh_reembolso
     ORDER BY km.dat_despesa_km, td.item, td.ativ
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_km_semanal')
     RETURN FALSE
  END IF

  LET l_for = 0
  WHENEVER ERROR CONTINUE
   FOREACH cq_km_semanal INTO l_val_km, l_dat_despesa_km, l_item, l_ativ,
           l_eh_valorizado_km, l_conta_contab, l_tipo_despesa_contab,
           l_hist_padrao_cap, l_eh_reembolso
  WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_km_semanal')
        RETURN FALSE
     END IF

     IF l_eh_valorizado_km = 'N' THEN #Continua la�o para despesa nao valorizadas
        CONTINUE FOREACH
     END IF

     LET l_ssr_nf = cdv2000_retorna_sub_serie(l_viagem, l_cod_fornecedor, 'S')

     CALL cdv2000_recupera_dados_bancarios_fornec(l_cod_fornecedor)
        RETURNING l_banco, l_agencia, l_cta_corrente, l_ies_dep_cred

     INITIALIZE t_aen_309_4, t_wlancon323 TO NULL

     LET l_ind = 0

     WHENEVER ERROR CONTINUE   #Busca cc_debitar
      SELECT cc_debitar
        INTO l_cc_debitar
        FROM w_solic
       WHERE viagem = l_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','w_solic')
        RETURN FALSE
     END IF

     LET l_for = l_ind #Quando l_ind = l_for alimenta DEB. quando diferente alimenta CRE.

     FOR l_ind = 1 TO 2

        LET t_wlancon323[l_ind].cod_empresa   = p_cod_empresa
        LET t_wlancon323[l_ind].num_ad_ap     = l_viagem
        LET t_wlancon323[l_ind].val_lanc      = l_val_km
        LET t_wlancon323[l_ind].dat_lanc      = TODAY
        LET t_wlancon323[l_ind].ies_cnd_pgto  = 'S'

        IF l_ind = 1 THEN #DEB.
           LET t_wlancon323[l_ind].ies_tipo_lanc = 'D'
           IF l_eh_reembolso = 'S'THEN
              LET t_wlancon323[l_ind].num_conta_cont = l_conta_contab
           ELSE
              LET l_char1 = l_cc_debitar
              LET l_char2 = l_tipo_despesa_contab USING "&&&&"
              LET t_wlancon323[l_ind].num_conta_cont = l_char1 CLIPPED, l_char2 CLIPPED
           END IF

           IF l_eh_valorizado_km = 'S' THEN    #Monta conta_contab
              LET l_char1 = l_cc_debitar
              LET l_char2 = l_tipo_despesa_contab USING "&&&&"
              LET t_wlancon323[l_ind].num_conta_cont = l_char1 CLIPPED, l_char2 CLIPPED
           END IF
        ELSE            #CRE.
           LET t_wlancon323[l_ind].ies_tipo_lanc = 'C'

           WHENEVER ERROR CONTINUE
           SELECT num_conta_cred, cod_hist_cred
             INTO t_wlancon323[l_ind].num_conta_cont, l_hist_padrao_cap
             FROM tipo_despesa
            WHERE cod_empresa     = p_cod_empresa
              AND cod_tip_despesa = m_td_km_semanal
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("select","tipo_despesa-km-sem")
              RETURN FALSE
           END IF

        END IF

        INITIALIZE l_texto_historico TO NULL
        CALL cap0690_valida_historico(p_cod_empresa, l_hist_padrao_cap, '')
           RETURNING l_status, l_texto_historico

        IF NOT l_status THEN
           RETURN FALSE
        END IF

        LET t_wlancon323[l_ind].tex_hist_lanc = l_texto_historico
     END FOR

     LET t_aen_309_4[1].val_aen = l_val_km

     CALL cdv2000_recupera_aen(l_item, l_filial_atendida, l_ativ, l_finalidade_viagem)
        RETURNING t_aen_309_4[1].cod_lin_prod, t_aen_309_4[1].cod_lin_recei,
                  t_aen_309_4[1].cod_seg_merc, t_aen_309_4[1].cod_cla_uso

     CALL cdv2000_monta_aen4()

     CALL cap309_gera_informacoes_cap("S", m_td_km_semanal,
                                      l_viagem,'S',l_ssr_nf,
                                      TODAY,
                                      l_cod_fornecedor,
                                      l_val_km,
                                      'INCLUS�O VIA CDV2000',
                                      l_ies_dep_cred,
                                      l_banco, l_agencia, l_cta_corrente,
                                      '','','','','','',
                                      TODAY)

        RETURNING l_work, l_msg, l_num_ad, m_num_ap

     IF NOT l_work THEN
        CALL log0030_mensagem(l_msg,'exclamation')
        RETURN l_work
     END IF

     #--inicio--OS 743235 #
     IF NOT cdv2000_atualiza_lote_pagto_km_semanal(l_num_ad, m_num_ap) THEN
        RETURN FALSE
     END IF
     #---fim----OS 743235 #

     IF NOT cdv0804_geracao_aen(l_num_ad) THEN
        RETURN FALSE
     END IF

     IF NOT cdv2000_gera_aprovacao_eletronica(l_viagem, l_num_ad, m_num_ap, 'S') THEN
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      UPDATE cdv_despesa_km_781
         SET apropr_desp_km = l_num_ad
       WHERE empresa        = p_cod_empresa
         AND viagem         = l_viagem
         AND dat_despesa_km = l_dat_despesa_km
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','cdv_despesa_km_781')
        RETURN FALSE
     END IF

  END FOREACH
  FREE cq_km_semanal

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION cdv2000_verifica_viagem_possui_transferencia(l_viagem)
#---------------------------------------------------------------#
  DEFINE l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_viagem_orig      LIKE cdv_acer_viag_781.viagem,
         l_ad_acerto_conta  LIKE ad_mestre.num_ad

  INITIALIZE l_viagem_orig, l_ad_acerto_conta TO NULL

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_viagem_orig
     FROM cdv_dev_transf_781
    WHERE empresa      = p_cod_empresa
      AND viagem_receb = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','cdv_dev_transf_7812')
  END IF

  IF l_viagem_orig IS NOT NULL THEN
     WHENEVER ERROR CONTINUE
      SELECT ad_acerto_conta
        INTO l_ad_acerto_conta
        FROM cdv_acer_viag_781
       WHERE empresa = p_cod_empresa
         AND viagem  = l_viagem_orig
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','cdv_acer_viag_781')
     END IF
  END IF

  RETURN l_viagem_orig, l_ad_acerto_conta

END FUNCTION

#-------------------------------------------------------------------------------------#
 FUNCTION cdv2000_recupera_aen(l_item, l_filial_atendida, l_ativ, l_finalidade_viagem)
#-------------------------------------------------------------------------------------#
  DEFINE l_item              LIKE cdv_tdesp_viag_781.item,
         l_cod_lin_prod      LIKE item.cod_lin_prod,
         l_cod_lin_recei     LIKE item.cod_lin_recei,
         l_cod_seg_merc      LIKE item.cod_seg_merc,
         l_cod_cla_uso       LIKE item.cod_cla_uso,
         l_filial_atendida   LIKE empresa.cod_empresa,
         l_ativ         LIKE cdv_ativ_781.ativ,
         l_finalidade_viagem LIKE cdv_acer_viag_781.finalidade_viagem,
         l_length            SMALLINT

  INITIALIZE l_cod_lin_prod, l_cod_lin_recei, l_cod_seg_merc, l_cod_cla_uso TO NULL

  IF l_item IS NOT NULL THEN
     WHENEVER ERROR CONTINUE
      SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso
        INTO l_cod_lin_prod, l_cod_lin_recei, l_cod_seg_merc, l_cod_cla_uso
        FROM item
       WHERE cod_empresa = l_filial_atendida
         AND cod_item    = l_item
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','item')
        RETURN l_cod_lin_prod, l_cod_lin_recei, l_cod_seg_merc, l_cod_cla_uso
     END IF
  ELSE
     LET l_cod_lin_prod  = m_empresa_atendida_pamcary
     LET l_cod_lin_recei = m_segundo_nivel_aen


     LET l_length = LENGTH(l_finalidade_viagem)
     IF l_length > 2 THEN
        LET l_cod_seg_merc  = l_finalidade_viagem[1, 2] #l_finalidade_viagem[l_length -1, l_length]
     ELSE
        LET l_cod_seg_merc  = l_finalidade_viagem
     END IF

     LET l_length = LENGTH(l_ativ)
     IF l_length > 2 THEN
        LET l_cod_cla_uso = l_ativ[l_length - 1, l_length]
     ELSE
        LET l_cod_cla_uso = l_ativ
     END IF
  END IF

  RETURN l_cod_lin_prod, l_cod_lin_recei, l_cod_seg_merc, l_cod_cla_uso

END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2000_gera_ad_desp_terc(l_viagem)
#-------------------------------------------#
  DEFINE l_viagem              LIKE cdv_solic_viag_781.viagem,
         l_ies_dat_base        LIKE cond_pg_item_cap.ies_dat_base,
         l_qtd_parcelas        SMALLINT,
         l_valor_saldo         LIKE ap.val_nom_ap,
         l_val_perc            LIKE cond_pg_item_cap.pct_val_vencto,
         l_ind                 SMALLINT,
         l_qtd_dias            LIKE cond_pg_item_cap.qtd_dias,
         l_msg                 CHAR(100),
         l_num_ad              LIKE ad_ap.num_ad,
         m_num_ap              LIKE ad_ap.num_ap,
         l_work                SMALLINT,
         l_status              SMALLINT,
         l_banco               LIKE cdv_dev_transf_781.banco,
         l_agencia             LIKE cdv_dev_transf_781.agencia,
         l_cta_corrente        LIKE cdv_dev_transf_781.cta_corrente,
         l_ies_dep_cred        CHAR(01),
         l_filial_atendida     LIKE empresa.cod_empresa,
         l_finalidade_viagem   LIKE cdv_acer_viag_781.finalidade_viagem,
         l_item                LIKE cdv_tdesp_viag_781.item

  CALL cdv2000_recupera_dados_bancarios_fornec(mr_desp_terc.fornecedor)
     RETURNING l_banco, l_agencia, l_cta_corrente, l_ies_dep_cred

  INITIALIZE t_aen_309_4, t_wlancon323 TO NULL

  LET t_aen_309_4[1].val_aen = mr_desp_terc.val_desp_terceiro

  WHENEVER ERROR CONTINUE
   SELECT filial_atendida, finalidade_viagem
     INTO l_filial_atendida, l_finalidade_viagem
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_acer_viag_781')
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  WHENEVER ERROR CONTINUE
   SELECT item
     INTO l_item
     FROM cdv_tdesp_viag_781
    WHERE empresa            = p_cod_empresa
      AND tip_despesa_viagem = mr_desp_terc.tip_despesa
      AND ativ               = mr_desp_terc.ativ
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_tdesp_viag_781')
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  CALL log2250_busca_parametro(mr_input.empresa_atendida,'empresa_atendida_pamcary')
     RETURNING m_empresa_atendida_pamcary, l_status
  IF NOT l_status OR m_empresa_atendida_pamcary IS NULL THEN
     CALL log0030_mensagem('Primeiro n�vel empresa atendida (AEN para devolu��o) n�o cadastrado.','exclamation')
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  CALL log2250_busca_parametro(mr_input.filial_atendida,'filial_atendida_pamcary')
     RETURNING m_segundo_nivel_aen, l_status
  IF NOT l_status OR m_segundo_nivel_aen IS NULL THEN
     CALL log0030_mensagem('Segundo n�vel filial atendida (AEN para devolu��o) n�o cadastrado.','exclamation')
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  CALL cdv2000_recupera_aen(l_item, l_filial_atendida, mr_desp_terc.ativ, l_finalidade_viagem)
     RETURNING t_aen_309_4[1].cod_lin_prod, t_aen_309_4[1].cod_lin_recei,
               t_aen_309_4[1].cod_seg_merc, t_aen_309_4[1].cod_cla_uso

  CALL cdv2000_monta_aen4()

  CALL cap309_gera_informacoes_cap("S",
                                   mr_desp_terc.tip_despesa,
                                   mr_desp_terc.nota_fiscal,
                                   mr_desp_terc.serie_nota_fiscal,
                                   mr_desp_terc.subserie_nf,
                                   mr_desp_terc.dat_vencto,
                                   mr_desp_terc.fornecedor,
                                   mr_desp_terc.val_desp_terceiro,
                                   'INCLUS�O VIA CDV2000',
                                   l_ies_dep_cred,
                                   l_banco, l_agencia, l_cta_corrente,
                                   '','','','','','',
                                   mr_desp_terc.dat_inclusao)

     RETURNING l_work, l_msg, l_num_ad, m_num_ap

  IF NOT l_work THEN
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  # AD de previs�o n�o tem lan�amentos cont�beis nem ad_aen_conta_4,
  # por isso elas precisam ser eliminadas para ter certeza de que o
  # cap3090 n�o tenha gerado essas tabelas.

  #IF NOT cdv2000_elimina_informacoes(l_num_ad) THEN
  #   RETURN FALSE, l_num_ad, m_num_ap
  #END IF

  IF NOT cdv0804_geracao_aen(l_num_ad) THEN
     RETURN FALSE
  END IF

  IF NOT cdv0803_atualiza_dados_ad_acerto(l_num_ad, l_viagem, m_num_ap, 'D') THEN
     RETURN FALSE, l_num_ad, m_num_ap
  END IF

  RETURN TRUE, l_num_ad, m_num_ap

END FUNCTION

##-----------------------------------------------#
# FUNCTION cdv2000_elimina_informacoes(l_num_ad)
##-----------------------------------------------#
# DEFINE l_num_ad       LIKE ad_mestre.num_ad
#
# WHENEVER ERROR CONTINUE
#  DELETE FROM ad_aen_conta_4
#   WHERE cod_empresa = p_cod_empresa
#     AND num_ad      = l_num_ad
# WHENEVER ERROR STOP
#
# IF SQLCA.sqlcode <> 0 THEN
#    CALL log003_err_sql("DELETE","AD_AEN_CONTA_4")
#    RETURN FALSE
# END IF
#
# WHENEVER ERROR CONTINUE
#  DELETE FROM lanc_cont_cap
#   WHERE cod_empresa = p_cod_empresa
#     AND num_ad_ap   = l_num_ad
#     AND ies_ad_ap   = "1"
# WHENEVER ERROR STOP
#
# IF SQLCA.sqlcode <> 0 THEN
#    CALL log003_err_sql("DELETE","LANC_CONT_CAP")
#    RETURN FALSE
# END IF
#
# RETURN TRUE
#
# END FUNCTION
#
#--------------------------------------------#
 FUNCTION cdv2000_carrega_devolucao(l_viagem)
#--------------------------------------------#
  DEFINE l_viagem   LIKE cdv_acer_viag_781.viagem

  INITIALIZE mr_proc_dev_transf.* TO NULL

  WHENEVER ERROR CONTINUE
   SELECT val_devolucao, val_transf, viagem_receb, forma_devolucao,
          caixa, dat_doc_devolucao, banco, agencia, cta_corrente
     INTO mr_proc_dev_transf.val_devolucao,
          mr_proc_dev_transf.val_transf,
          mr_proc_dev_transf.viagem_receb,
          mr_proc_dev_transf.forma_devolucao,
          mr_proc_dev_transf.caixa,
          mr_proc_dev_transf.dat_doc_devolucao,
          mr_proc_dev_transf.banco,
          mr_proc_dev_transf.agencia,
          mr_proc_dev_transf.cta_corrente
     FROM cdv_dev_transf_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','cdv_dev_transf_781')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_recupera_status_viag(l_viagem)
#-----------------------------------------------#
  DEFINE l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_status_acer_viagem  LIKE cdv_acer_viag_781.status_acer_viagem

  INITIALIZE l_status_acer_viagem TO NULL

  WHENEVER ERROR CONTINUE
   SELECT status_acer_viagem
     INTO l_status_acer_viagem
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
     CALL log003_err_sql('SELECT','cdv_acer_viag_781')
  END IF

  RETURN l_status_acer_viagem

END FUNCTION

#----------------------------------#
 FUNCTION cdv2000_existe_devolucao()
#----------------------------------#
 WHENEVER ERROR CONTINUE
 SELECT cdv_dev_transf_781.viagem,            cdv_acer_viag_781.controle,
        cdv_dev_transf_781.eh_status_acerto,  cdv_dev_transf_781.val_devolucao,
        cdv_dev_transf_781.dat_devolucao,     cdv_dev_transf_781.val_transf,
        cdv_dev_transf_781.dat_transf,        cdv_dev_transf_781.viagem_receb,
        cdv_dev_transf_781.controle_receb,    cdv_dev_transf_781.forma_devolucao,
        cdv_dev_transf_781.docum_devolucao,   cdv_dev_transf_781.caixa,
        cdv_dev_transf_781.dat_doc_devolucao, cdv_dev_transf_781.banco,
        cdv_dev_transf_781.agencia,           cdv_dev_transf_781.cta_corrente,
        cdv_dev_transf_781.observacao
   INTO mr_dev_transf.viagem,                 mr_dev_transf.controle,
        mr_dev_transf.status,                 mr_dev_transf.val_devolucao,
        mr_dev_transf.dat_devolucao,          mr_dev_transf.val_transf,
        mr_dev_transf.dat_transf,             mr_dev_transf.viagem_receb,
        mr_dev_transf.controle_receb,         mr_dev_transf.forma,
        mr_dev_transf.doc_devolucao,          mr_dev_transf.caixa,
        mr_dev_transf.dat_doc_devolucao,      mr_dev_transf.banco,
        mr_dev_transf.agencia,                mr_dev_transf.cta_corrente,
        mr_dev_transf.observacao
   FROM cdv_dev_transf_781, cdv_acer_viag_781
  WHERE cdv_dev_transf_781.empresa = p_cod_empresa
    AND cdv_dev_transf_781.viagem  = mr_solic.viagem
    AND cdv_acer_viag_781.empresa  = p_cod_empresa
    AND cdv_acer_viag_781.viagem   = mr_solic.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 ELSE
    CASE mr_dev_transf.status
    WHEN 'D'  LET mr_dev_transf.den_status = 'DEVOLU��O'
    WHEN 'T'  LET mr_dev_transf.den_status = 'TRANSFER�NCIA'
    OTHERWISE LET mr_dev_transf.den_status = ''
    END CASE
    DISPLAY mr_dev_transf.den_status TO den_status

    CASE mr_dev_transf.forma
    WHEN '1'  LET mr_dev_transf.den_forma = 'DEVOLU��O BANCO'
    WHEN '2'  LET mr_dev_transf.den_forma = 'DEVOLU��O CAIXA'
    OTHERWISE LET mr_dev_transf.den_forma = ''
    END CASE
    DISPLAY mr_dev_transf.den_forma TO den_forma

    WHENEVER ERROR CONTINUE
    SELECT den_caixa
      INTO mr_dev_transf.den_caixa
      FROM ctrl_caixa
     WHERE cod_empresa = p_cod_empresa
       AND cod_caixa   = mr_dev_transf.caixa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       INITIALIZE mr_dev_transf.den_caixa TO NULL
    END IF

    WHENEVER ERROR CONTINUE
    SELECT nom_banco
      INTO mr_dev_transf.den_banco
      FROM bancos
     WHERE cod_banco = mr_dev_transf.banco
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       LET mr_dev_transf.den_banco = NULL
    END IF

    LET mr_dev_transf.tot_adiant = m_tot_adiant
    LET mr_dev_transf.tot_desp   = m_tot_desp

    RETURN TRUE
 END IF

 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2000_acerto_finalizado()
#-----------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT status_acer_viagem
   FROM cdv_acer_viag_781
  WHERE empresa            = p_cod_empresa
    AND viagem             = mr_dev_transf.viagem
    AND status_acer_viagem IN ('3','4')
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#---------------------------------#
 FUNCTION cdv2000_consulta_previa()
#---------------------------------#
 DEFINE l_cont    SMALLINT

 LET l_cont = 0

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO l_cont
   FROM w_solic
  WHERE 1=1
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE m_previa_viagem, m_previa_controle TO NULL
    RETURN
 END IF

 IF l_cont IS NULL THEN
    INITIALIZE m_previa_viagem, m_previa_controle TO NULL
    RETURN
 END IF

 IF l_cont > 1
 OR l_cont = 0 THEN
    INITIALIZE m_previa_viagem, m_previa_controle TO NULL
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem,          controle
   INTO m_previa_viagem, m_previa_controle
   FROM w_solic
  WHERE 1=1
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE m_previa_viagem, m_previa_controle TO NULL
 END IF

 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_grupo_tdesp_certificado(l_viagem)
#-------------------------------------------------#
 DEFINE l_viagem       LIKE cdv_desp_urb_781.viagem,
        l_tipo_despesa LIKE cdv_desp_urb_781.tip_despesa_viagem,
        l_ativ         LIKE cdv_tdesp_viag_781.ativ

 WHENEVER ERROR CONTINUE
 DECLARE cq_tip_desp_urb CURSOR FOR
  SELECT DISTINCT tip_despesa_viagem, ativ
    FROM cdv_desp_urb_781
   WHERE empresa     = p_cod_empresa
     AND viagem      = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cq_tip_desp_urb")
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_tip_desp_urb INTO l_tipo_despesa, l_ativ
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_TIP_DESP_URB")
       RETURN TRUE
    END IF

    IF cdv2000_tipo_desp_certificado(l_tipo_despesa, l_ativ) THEN
       RETURN TRUE
    END IF

 END FOREACH
 FREE cq_tip_desp_urb

 WHENEVER ERROR CONTINUE
 DECLARE cq_tip_desp_terc CURSOR FOR
  SELECT DISTINCT tip_despesa, ativ
    FROM cdv_desp_terc_781
   WHERE empresa = p_cod_empresa
     AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_TIP_DESP_TERC")
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_tip_desp_terc INTO l_tipo_despesa, l_ativ
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_tip_desp_terc")
       RETURN TRUE
    END IF

    IF cdv2000_tipo_desp_certificado(l_tipo_despesa, l_ativ) THEN
       RETURN TRUE
    END IF

 END FOREACH
 FREE cq_tip_desp_terc

 WHENEVER ERROR CONTINUE
 DECLARE cq_tip_desp_km CURSOR FOR
  SELECT DISTINCT tip_despesa_viagem, ativ_km
    FROM cdv_despesa_km_781
   WHERE empresa = p_cod_empresa
     AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_TIP_DESP_KM")
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_tip_desp_km INTO l_tipo_despesa, l_ativ
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_TIP_DESP_KM")
       RETURN TRUE
    END IF

    IF cdv2000_tipo_desp_certificado(l_tipo_despesa, l_ativ) THEN
       RETURN TRUE
    END IF

 END FOREACH
 FREE cq_tip_desp_km

 RETURN FALSE
 END FUNCTION


#-------------------------------------------------------------#
 FUNCTION cdv2000_tipo_desp_certificado(l_tipo_despesa, l_ativ)
#-------------------------------------------------------------#
 DEFINE l_tipo_despesa      LIKE cdv_desp_urb_781.tip_despesa_viagem,
        l_ativ              LIKE cdv_tdesp_viag_781.ativ

 WHENEVER ERROR CONTINUE
 SELECT tip_despesa_viagem
   FROM cdv_tdesp_viag_781
  WHERE empresa            = p_cod_empresa
    AND tip_despesa_viagem = l_tipo_despesa
    AND ativ               = l_ativ
    AND grp_despesa_viagem = '6'
    #OS 487356
    AND grp_despesa_viagem = '11'
    AND grp_despesa_viagem = '12'
    #---

 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_insere_cdv_fat_781()
#------------------------------------#
 DEFINE lr_cdv_intg_fat_781         RECORD
                                       empresa           	  CHAR(2),
                                       viagem            	  INTEGER,
                                       controle          	  DECIMAL(20,0),
                                       apropr_desp_acerto	  DECIMAL(6,0),
                                       grp_despesa_viagem	  SMALLINT,
                                       tip_despesa_viagem	  DECIMAL(5,0),
                                       sequencia_despesa 	  SMALLINT,
                                       seq_alteracao     	  SMALLINT,
                                       item              	  CHAR(15),
                                       item_hor          	  CHAR(15),
                                       eh_liberacao_pagto	  CHAR(1),
                                       eh_desp_aprovada  	  CHAR(1),
                                       usu_aprov_contab  	  CHAR(8),
                                       dat_aprov_contab  	  DATE,
                                       hr_aprov_contab   	  CHAR(8),
                                       eh_desp_reembols  	  CHAR(1),
                                       motivo_reembolso  	  CHAR(70),
                                       qtd_km_faturada   	  DECIMAL(5,0),
                                       mot_alteracao_km  	  CHAR(70),
                                       qtd_hor_diurnas   	  CHAR(9),
                                       qtd_hor_noturnas  	  CHAR(9),
                                       mot_alteracao_hor 	  CHAR(70),
                                       usu_aprov_fatura  	  CHAR(8),
                                       dat_aprov_fatura  	  DATE,
                                       hr_aprov_fatura   	  CHAR(8),
                                       dat_envio_bilhete 	  DATE,
                                       hor_envio_bilhete 	  CHAR(8),
                                       origem_integr     	  CHAR(3),
                                       certificado       	  DECIMAL(9,0),
                                       ativ              	  CHAR(5),
                                       sistema           	  CHAR(5),
                                       dat_apontamento   	  DATE,
                                       val_salvados      	  DECIMAL(12,2),
                                       val_gratificacao  	  DECIMAL(12,2),
                                       qtd_certif        	  DECIMAL(5,0),
                                       docum_fisico      	  VARCHAR(1),
                                       docum_data        	  DATE,
                                       idbilhete         	  INTEGER
                                    END RECORD

 DEFINE l_gerar_tab_fat             CHAR(01),
        l_cobra_despesa             CHAR(01)

 INITIALIZE lr_cdv_intg_fat_781.*   TO NULL

 LET lr_cdv_intg_fat_781.empresa             = p_cod_empresa
 LET lr_cdv_intg_fat_781.viagem              = mr_input.viagem
 LET lr_cdv_intg_fat_781.controle            = mr_input.controle
 LET lr_cdv_intg_fat_781.apropr_desp_acerto  = cdv2000_busca_ad_acerto()
 LET lr_cdv_intg_fat_781.seq_alteracao       = 0
 LET lr_cdv_intg_fat_781.eh_liberacao_pagto  = 'N'
 LET lr_cdv_intg_fat_781.eh_desp_aprovada    = 'N'
 LET lr_cdv_intg_fat_781.usu_aprov_contab    = ''
 LET lr_cdv_intg_fat_781.dat_aprov_contab    = ''
 LET lr_cdv_intg_fat_781.hr_aprov_contab     = ''
 LET lr_cdv_intg_fat_781.motivo_reembolso    = ''
 LET lr_cdv_intg_fat_781.mot_alteracao_km    = ''
 LET lr_cdv_intg_fat_781.usu_aprov_fatura    = ''
 LET lr_cdv_intg_fat_781.dat_aprov_fatura    = ''
 LET lr_cdv_intg_fat_781.hr_aprov_fatura     = ''
 LET lr_cdv_intg_fat_781.dat_envio_bilhete   = ''
 LET lr_cdv_intg_fat_781.hor_envio_bilhete   = ''
 LET lr_cdv_intg_fat_781.origem_integr       = 'CDV'
 LET lr_cdv_intg_fat_781.certificado         = ''
 LET lr_cdv_intg_fat_781.ativ                = ''
 LET lr_cdv_intg_fat_781.sistema             = cdv2000_busca_finalidade_acer(mr_input.viagem)
 LET lr_cdv_intg_fat_781.dat_apontamento     = ''
 LET lr_cdv_intg_fat_781.tip_despesa_viagem  = ''
 LET lr_cdv_intg_fat_781.grp_despesa_viagem  = ''
 LET lr_cdv_intg_fat_781.eh_desp_reembols    = ''
 LET lr_cdv_intg_fat_781.item                = ''
 LET lr_cdv_intg_fat_781.item_hor            = ''
 LET lr_cdv_intg_fat_781.sequencia_despesa   = ''
 LET lr_cdv_intg_fat_781.mot_alteracao_hor   = ''
 LET lr_cdv_intg_fat_781.qtd_hor_diurnas     = ''
 LET lr_cdv_intg_fat_781.qtd_hor_noturnas    = ''
 LET lr_cdv_intg_fat_781.qtd_km_faturada     = ''
 LET lr_cdv_intg_fat_781.idbilhete           = NULL

 WHENEVER ERROR CONTINUE
 SELECT gerar_tab_fat
   INTO l_gerar_tab_fat
   FROM cdv_finalidade_781
  WHERE finalidade = mr_input.finalidade_viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","cdv_finalidade_781")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_apont_hor_tdesp CURSOR FOR
  SELECT cdv_tdesp_viag_781.tip_despesa_viagem,
         cdv_tdesp_viag_781.grp_despesa_viagem,
         cdv_tdesp_viag_781.eh_reembolso,
         cdv_tdesp_viag_781.item,
         cdv_tdesp_viag_781.item_hor,
         cdv_apont_hor_781.seq_apont_hor,
         cdv_apont_hor_781.hor_diurnas,
         cdv_apont_hor_781.hor_noturnas,
         cdv_tdesp_viag_781.ativ,
         cdv_apont_hor_781.dat_apont_hor,
         cdv_tdesp_viag_781.cobra_despesa
    FROM cdv_tdesp_viag_781,  cdv_apont_hor_781
   WHERE cdv_tdesp_viag_781.empresa        = p_cod_empresa
     AND cdv_apont_hor_781.empresa         = p_cod_empresa
     AND cdv_apont_hor_781.viagem          = mr_input.viagem
     AND cdv_apont_hor_781.tdesp_apont_hor = cdv_tdesp_viag_781.tip_despesa_viagem
     AND cdv_apont_hor_781.ativ            = cdv_tdesp_viag_781.ativ
     #AND cdv_tdesp_viag_781.eh_reembolso   = 'S'
   ORDER BY cdv_apont_hor_781.seq_apont_hor
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_APONT_HOR_TDESP")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_apont_hor_tdesp INTO lr_cdv_intg_fat_781.tip_despesa_viagem,
                                 lr_cdv_intg_fat_781.grp_despesa_viagem,
                                 lr_cdv_intg_fat_781.eh_desp_reembols,
                                 lr_cdv_intg_fat_781.item,
                                 lr_cdv_intg_fat_781.item_hor,
                                 lr_cdv_intg_fat_781.sequencia_despesa,
                                 lr_cdv_intg_fat_781.qtd_hor_diurnas,
                                 lr_cdv_intg_fat_781.qtd_hor_noturnas,
                                 lr_cdv_intg_fat_781.ativ,
                                 lr_cdv_intg_fat_781.dat_apontamento,
                                 l_cobra_despesa
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_APONT_HOR_TDESP")
       RETURN FALSE
    END IF

    IF lr_cdv_intg_fat_781.eh_desp_reembols IS NULL THEN
       LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
    END IF

    IF NOT (l_gerar_tab_fat = 'S' OR lr_cdv_intg_fat_781.eh_desp_reembols = 'S') THEN
       CONTINUE FOREACH
    END IF

    IF l_gerar_tab_fat = 'S' THEN
       IF l_cobra_despesa = 'S' THEN
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'S'
       ELSE
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
       END IF
    END IF

    IF lr_cdv_intg_fat_781.qtd_hor_noturnas = '00:00:00' THEN
       INITIALIZE lr_cdv_intg_fat_781.item_hor TO NULL
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO cdv_intg_fat_781 (empresa,
                                  viagem,
                                  controle,
                                  apropr_desp_acerto,
                                  grp_despesa_viagem,
                                  tip_despesa_viagem,
                                  sequencia_despesa,
                                  seq_alteracao,
                                  item,
                                  item_hor,
                                  eh_liberacao_pagto,
                                  eh_desp_aprovada,
                                  usu_aprov_contab,
                                  dat_aprov_contab,
                                  hr_aprov_contab,
                                  eh_desp_reembols,
                                  motivo_reembolso,
                                  qtd_km_faturada,
                                  mot_alteracao_km,
                                  qtd_hor_diurnas,
                                  qtd_hor_noturnas,
                                  mot_alteracao_hor,
                                  usu_aprov_fatura,
                                  dat_aprov_fatura,
                                  hr_aprov_fatura,
                                  dat_envio_bilhete,
                                  hor_envio_bilhete,
                                  origem_integr,
                                  certificado,
                                  ativ,
                                  sistema,
                                  dat_apontamento)
                          VALUES (lr_cdv_intg_fat_781.empresa,
                                  lr_cdv_intg_fat_781.viagem,
                                  lr_cdv_intg_fat_781.controle,
                                  lr_cdv_intg_fat_781.apropr_desp_acerto,
                                  lr_cdv_intg_fat_781.grp_despesa_viagem,
                                  lr_cdv_intg_fat_781.tip_despesa_viagem,
                                  lr_cdv_intg_fat_781.sequencia_despesa,
                                  lr_cdv_intg_fat_781.seq_alteracao,
                                  lr_cdv_intg_fat_781.item,
                                  lr_cdv_intg_fat_781.item_hor,
                                  lr_cdv_intg_fat_781.eh_liberacao_pagto,
                                  lr_cdv_intg_fat_781.eh_desp_aprovada,
                                  lr_cdv_intg_fat_781.usu_aprov_contab,
                                  lr_cdv_intg_fat_781.dat_aprov_contab,
                                  lr_cdv_intg_fat_781.hr_aprov_contab,
                                  lr_cdv_intg_fat_781.eh_desp_reembols,
                                  lr_cdv_intg_fat_781.motivo_reembolso,
                                  lr_cdv_intg_fat_781.qtd_km_faturada,
                                  lr_cdv_intg_fat_781.mot_alteracao_km,
                                  lr_cdv_intg_fat_781.qtd_hor_diurnas,
                                  lr_cdv_intg_fat_781.qtd_hor_noturnas,
                                  lr_cdv_intg_fat_781.mot_alteracao_hor,
                                  lr_cdv_intg_fat_781.usu_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_aprov_fatura,
                                  lr_cdv_intg_fat_781.hr_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_envio_bilhete,
                                  lr_cdv_intg_fat_781.hor_envio_bilhete,
                                  lr_cdv_intg_fat_781.origem_integr,
                                  lr_cdv_intg_fat_781.certificado,
                                  lr_cdv_intg_fat_781.ativ,
                                  lr_cdv_intg_fat_781.sistema,
                                  lr_cdv_intg_fat_781.dat_apontamento)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","CDV_INTG_FAT_781")
       RETURN FALSE
    END IF
 END FOREACH
 FREE cq_apont_hor_tdesp

 INITIALIZE lr_cdv_intg_fat_781.qtd_hor_diurnas,
            lr_cdv_intg_fat_781.qtd_hor_noturnas TO NULL


 WHENEVER ERROR CONTINUE
 DECLARE cq_desp_urb_tdesp CURSOR FOR
  SELECT cdv_tdesp_viag_781.tip_despesa_viagem,
         cdv_tdesp_viag_781.grp_despesa_viagem,
         cdv_tdesp_viag_781.eh_reembolso,
         cdv_tdesp_viag_781.item,
         cdv_tdesp_viag_781.item_hor,
         cdv_desp_urb_781.seq_despesa_urbana,
         cdv_tdesp_viag_781.ativ,
         cdv_desp_urb_781.dat_despesa_urbana,
         cdv_tdesp_viag_781.cobra_despesa
    FROM cdv_tdesp_viag_781,  cdv_desp_urb_781
   WHERE cdv_tdesp_viag_781.empresa          = p_cod_empresa
     AND cdv_desp_urb_781.empresa            = p_cod_empresa
     AND cdv_desp_urb_781.viagem             = mr_input.viagem
     AND cdv_desp_urb_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
     AND cdv_desp_urb_781.ativ               = cdv_tdesp_viag_781.ativ
     #AND cdv_tdesp_viag_781.eh_reembolso     = 'S'
   ORDER BY cdv_desp_urb_781.seq_despesa_urbana
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_DESP_URB_TDESP")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_desp_urb_tdesp INTO lr_cdv_intg_fat_781.tip_despesa_viagem,
                                lr_cdv_intg_fat_781.grp_despesa_viagem,
                                lr_cdv_intg_fat_781.eh_desp_reembols,
                                lr_cdv_intg_fat_781.item,
                                lr_cdv_intg_fat_781.item_hor,
                                lr_cdv_intg_fat_781.sequencia_despesa,
                                lr_cdv_intg_fat_781.ativ,
                                lr_cdv_intg_fat_781.dat_apontamento,
                                l_cobra_despesa
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_desp_urb_tdesp")
       RETURN FALSE
    END IF

    IF lr_cdv_intg_fat_781.eh_desp_reembols IS NULL THEN
       LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
    END IF

    IF NOT (l_gerar_tab_fat = 'S' OR lr_cdv_intg_fat_781.eh_desp_reembols = 'S') THEN
       CONTINUE FOREACH
    END IF

    IF l_gerar_tab_fat = 'S' THEN
       IF l_cobra_despesa = 'S' THEN
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'S'
       ELSE
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
       END IF
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO cdv_intg_fat_781 (empresa,
                                  viagem,
                                  controle,
                                  apropr_desp_acerto,
                                  grp_despesa_viagem,
                                  tip_despesa_viagem,
                                  sequencia_despesa,
                                  seq_alteracao,
                                  item,
                                  item_hor,
                                  eh_liberacao_pagto,
                                  eh_desp_aprovada,
                                  usu_aprov_contab,
                                  dat_aprov_contab,
                                  hr_aprov_contab,
                                  eh_desp_reembols,
                                  motivo_reembolso,
                                  qtd_km_faturada,
                                  mot_alteracao_km,
                                  qtd_hor_diurnas,
                                  qtd_hor_noturnas,
                                  mot_alteracao_hor,
                                  usu_aprov_fatura,
                                  dat_aprov_fatura,
                                  hr_aprov_fatura,
                                  dat_envio_bilhete,
                                  hor_envio_bilhete,
                                  origem_integr,
                                  certificado,
                                  ativ,
                                  sistema,
                                  dat_apontamento)
                          VALUES (lr_cdv_intg_fat_781.empresa,
                                  lr_cdv_intg_fat_781.viagem,
                                  lr_cdv_intg_fat_781.controle,
                                  lr_cdv_intg_fat_781.apropr_desp_acerto,
                                  lr_cdv_intg_fat_781.grp_despesa_viagem,
                                  lr_cdv_intg_fat_781.tip_despesa_viagem,
                                  lr_cdv_intg_fat_781.sequencia_despesa,
                                  lr_cdv_intg_fat_781.seq_alteracao,
                                  lr_cdv_intg_fat_781.item,
                                  lr_cdv_intg_fat_781.item_hor,
                                  lr_cdv_intg_fat_781.eh_liberacao_pagto,
                                  lr_cdv_intg_fat_781.eh_desp_aprovada,
                                  lr_cdv_intg_fat_781.usu_aprov_contab,
                                  lr_cdv_intg_fat_781.dat_aprov_contab,
                                  lr_cdv_intg_fat_781.hr_aprov_contab,
                                  lr_cdv_intg_fat_781.eh_desp_reembols,
                                  lr_cdv_intg_fat_781.motivo_reembolso,
                                  lr_cdv_intg_fat_781.qtd_km_faturada,
                                  lr_cdv_intg_fat_781.mot_alteracao_km,
                                  lr_cdv_intg_fat_781.qtd_hor_diurnas,
                                  lr_cdv_intg_fat_781.qtd_hor_noturnas,
                                  lr_cdv_intg_fat_781.mot_alteracao_hor,
                                  lr_cdv_intg_fat_781.usu_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_aprov_fatura,
                                  lr_cdv_intg_fat_781.hr_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_envio_bilhete,
                                  lr_cdv_intg_fat_781.hor_envio_bilhete,
                                  lr_cdv_intg_fat_781.origem_integr,
                                  lr_cdv_intg_fat_781.certificado,
                                  lr_cdv_intg_fat_781.ativ,
                                  lr_cdv_intg_fat_781.sistema,
                                  lr_cdv_intg_fat_781.dat_apontamento)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","CDV_INTG_FAT_781")
       RETURN FALSE
    END IF


 END FOREACH
 FREE cq_desp_urb_tdesp

 WHENEVER ERROR CONTINUE
 DECLARE cq_desp_km_tdesp CURSOR FOR
  SELECT cdv_tdesp_viag_781.tip_despesa_viagem,
         cdv_tdesp_viag_781.grp_despesa_viagem,
         cdv_tdesp_viag_781.eh_reembolso,
         cdv_tdesp_viag_781.item,
         cdv_tdesp_viag_781.item_hor,
         cdv_despesa_km_781.seq_despesa_km,
         cdv_despesa_km_781.qtd_km,
         cdv_tdesp_viag_781.ativ,
         cdv_despesa_km_781.dat_despesa_km,
         cdv_tdesp_viag_781.cobra_despesa
    FROM cdv_tdesp_viag_781,  cdv_despesa_km_781
   WHERE cdv_tdesp_viag_781.empresa            = p_cod_empresa
     AND cdv_despesa_km_781.empresa            = p_cod_empresa
     AND cdv_despesa_km_781.viagem             = mr_input.viagem
     AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
     AND cdv_despesa_km_781.ativ_km            = cdv_tdesp_viag_781.ativ
     #AND cdv_tdesp_viag_781.eh_reembolso       = 'S'
   ORDER BY cdv_despesa_km_781.seq_despesa_km
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cq_desp_km_tdesp")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_desp_km_tdesp INTO lr_cdv_intg_fat_781.tip_despesa_viagem,
                               lr_cdv_intg_fat_781.grp_despesa_viagem,
                               lr_cdv_intg_fat_781.eh_desp_reembols,
                               lr_cdv_intg_fat_781.item,
                               lr_cdv_intg_fat_781.item_hor,
                               lr_cdv_intg_fat_781.sequencia_despesa,
                               lr_cdv_intg_fat_781.qtd_km_faturada,
                               lr_cdv_intg_fat_781.ativ,
                               lr_cdv_intg_fat_781.dat_apontamento,
                               l_cobra_despesa
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_desp_km_tdesp")
       RETURN FALSE
    END IF

    IF lr_cdv_intg_fat_781.eh_desp_reembols IS NULL THEN
       LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
    END IF

    IF NOT (l_gerar_tab_fat = 'S' OR lr_cdv_intg_fat_781.eh_desp_reembols = 'S') THEN
       CONTINUE FOREACH
    END IF

    IF l_gerar_tab_fat = 'S' THEN
       IF l_cobra_despesa = 'S' THEN
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'S'
       ELSE
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
       END IF
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO cdv_intg_fat_781 (empresa,
                                  viagem,
                                  controle,
                                  apropr_desp_acerto,
                                  grp_despesa_viagem,
                                  tip_despesa_viagem,
                                  sequencia_despesa,
                                  seq_alteracao,
                                  item,
                                  item_hor,
                                  eh_liberacao_pagto,
                                  eh_desp_aprovada,
                                  usu_aprov_contab,
                                  dat_aprov_contab,
                                  hr_aprov_contab,
                                  eh_desp_reembols,
                                  motivo_reembolso,
                                  qtd_km_faturada,
                                  mot_alteracao_km,
                                  qtd_hor_diurnas,
                                  qtd_hor_noturnas,
                                  mot_alteracao_hor,
                                  usu_aprov_fatura,
                                  dat_aprov_fatura,
                                  hr_aprov_fatura,
                                  dat_envio_bilhete,
                                  hor_envio_bilhete,
                                  origem_integr,
                                  certificado,
                                  ativ,
                                  sistema,
                                  dat_apontamento)
                          VALUES (lr_cdv_intg_fat_781.empresa,
                                  lr_cdv_intg_fat_781.viagem,
                                  lr_cdv_intg_fat_781.controle,
                                  lr_cdv_intg_fat_781.apropr_desp_acerto,
                                  lr_cdv_intg_fat_781.grp_despesa_viagem,
                                  lr_cdv_intg_fat_781.tip_despesa_viagem,
                                  lr_cdv_intg_fat_781.sequencia_despesa,
                                  lr_cdv_intg_fat_781.seq_alteracao,
                                  lr_cdv_intg_fat_781.item,
                                  lr_cdv_intg_fat_781.item_hor,
                                  lr_cdv_intg_fat_781.eh_liberacao_pagto,
                                  lr_cdv_intg_fat_781.eh_desp_aprovada,
                                  lr_cdv_intg_fat_781.usu_aprov_contab,
                                  lr_cdv_intg_fat_781.dat_aprov_contab,
                                  lr_cdv_intg_fat_781.hr_aprov_contab,
                                  lr_cdv_intg_fat_781.eh_desp_reembols,
                                  lr_cdv_intg_fat_781.motivo_reembolso,
                                  lr_cdv_intg_fat_781.qtd_km_faturada,
                                  lr_cdv_intg_fat_781.mot_alteracao_km,
                                  lr_cdv_intg_fat_781.qtd_hor_diurnas,
                                  lr_cdv_intg_fat_781.qtd_hor_noturnas,
                                  lr_cdv_intg_fat_781.mot_alteracao_hor,
                                  lr_cdv_intg_fat_781.usu_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_aprov_fatura,
                                  lr_cdv_intg_fat_781.hr_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_envio_bilhete,
                                  lr_cdv_intg_fat_781.hor_envio_bilhete,
                                  lr_cdv_intg_fat_781.origem_integr,
                                  lr_cdv_intg_fat_781.certificado,
                                  lr_cdv_intg_fat_781.ativ,
                                  lr_cdv_intg_fat_781.sistema,
                                  lr_cdv_intg_fat_781.dat_apontamento)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","CDV_INTG_FAT_781")
       RETURN FALSE
    END IF

 END FOREACH
 FREE cq_desp_km_tdesp

 INITIALIZE lr_cdv_intg_fat_781.qtd_hor_diurnas,
            lr_cdv_intg_fat_781.qtd_hor_noturnas TO NULL


 WHENEVER ERROR CONTINUE
 DECLARE cq_desp_terc CURSOR FOR
  SELECT cdv_tdesp_viag_781.tip_despesa_viagem,
         cdv_tdesp_viag_781.grp_despesa_viagem,
         cdv_tdesp_viag_781.eh_reembolso,
         cdv_tdesp_viag_781.item,
         cdv_tdesp_viag_781.item_hor,
         cdv_desp_terc_781.seq_desp_terceiro,
         cdv_tdesp_viag_781.ativ,
         cdv_desp_terc_781.dat_inclusao,
         cdv_tdesp_viag_781.cobra_despesa
    FROM cdv_tdesp_viag_781,  cdv_desp_terc_781
   WHERE cdv_tdesp_viag_781.empresa           = p_cod_empresa
     AND cdv_desp_terc_781.empresa            = p_cod_empresa
     AND cdv_desp_terc_781.viagem             = mr_input.viagem
     AND cdv_desp_terc_781.tip_despesa        = cdv_tdesp_viag_781.tip_despesa_viagem
     AND cdv_desp_terc_781.ativ               = cdv_tdesp_viag_781.ativ
     #AND cdv_tdesp_viag_781.eh_reembolso      = 'S'
   ORDER BY cdv_desp_terc_781.seq_desp_terceiro
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_DESP_URB_TDESP")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_desp_terc INTO lr_cdv_intg_fat_781.tip_despesa_viagem,
                           lr_cdv_intg_fat_781.grp_despesa_viagem,
                           lr_cdv_intg_fat_781.eh_desp_reembols,
                           lr_cdv_intg_fat_781.item,
                           lr_cdv_intg_fat_781.item_hor,
                           lr_cdv_intg_fat_781.sequencia_despesa,
                           lr_cdv_intg_fat_781.ativ,
                           lr_cdv_intg_fat_781.dat_apontamento,
                           l_cobra_despesa
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_desp_terc")
       RETURN FALSE
    END IF

    IF lr_cdv_intg_fat_781.eh_desp_reembols IS NULL THEN
       LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
    END IF

    IF NOT (l_gerar_tab_fat = 'S' OR lr_cdv_intg_fat_781.eh_desp_reembols = 'S') THEN
       CONTINUE FOREACH
    END IF

    IF l_gerar_tab_fat = 'S' THEN
       IF l_cobra_despesa = 'S' THEN
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'S'
       ELSE
          LET lr_cdv_intg_fat_781.eh_desp_reembols = 'N'
       END IF
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO cdv_intg_fat_781 (empresa,
                                  viagem,
                                  controle,
                                  apropr_desp_acerto,
                                  grp_despesa_viagem,
                                  tip_despesa_viagem,
                                  sequencia_despesa,
                                  seq_alteracao,
                                  item,
                                  item_hor,
                                  eh_liberacao_pagto,
                                  eh_desp_aprovada,
                                  usu_aprov_contab,
                                  dat_aprov_contab,
                                  hr_aprov_contab,
                                  eh_desp_reembols,
                                  motivo_reembolso,
                                  qtd_km_faturada,
                                  mot_alteracao_km,
                                  qtd_hor_diurnas,
                                  qtd_hor_noturnas,
                                  mot_alteracao_hor,
                                  usu_aprov_fatura,
                                  dat_aprov_fatura,
                                  hr_aprov_fatura,
                                  dat_envio_bilhete,
                                  hor_envio_bilhete,
                                  origem_integr,
                                  certificado,
                                  ativ,
                                  sistema,
                                  dat_apontamento)
                          VALUES (lr_cdv_intg_fat_781.empresa,
                                  lr_cdv_intg_fat_781.viagem,
                                  lr_cdv_intg_fat_781.controle,
                                  lr_cdv_intg_fat_781.apropr_desp_acerto,
                                  lr_cdv_intg_fat_781.grp_despesa_viagem,
                                  lr_cdv_intg_fat_781.tip_despesa_viagem,
                                  lr_cdv_intg_fat_781.sequencia_despesa,
                                  lr_cdv_intg_fat_781.seq_alteracao,
                                  lr_cdv_intg_fat_781.item,
                                  lr_cdv_intg_fat_781.item_hor,
                                  lr_cdv_intg_fat_781.eh_liberacao_pagto,
                                  lr_cdv_intg_fat_781.eh_desp_aprovada,
                                  lr_cdv_intg_fat_781.usu_aprov_contab,
                                  lr_cdv_intg_fat_781.dat_aprov_contab,
                                  lr_cdv_intg_fat_781.hr_aprov_contab,
                                  lr_cdv_intg_fat_781.eh_desp_reembols,
                                  lr_cdv_intg_fat_781.motivo_reembolso,
                                  lr_cdv_intg_fat_781.qtd_km_faturada,
                                  lr_cdv_intg_fat_781.mot_alteracao_km,
                                  lr_cdv_intg_fat_781.qtd_hor_diurnas,
                                  lr_cdv_intg_fat_781.qtd_hor_noturnas,
                                  lr_cdv_intg_fat_781.mot_alteracao_hor,
                                  lr_cdv_intg_fat_781.usu_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_aprov_fatura,
                                  lr_cdv_intg_fat_781.hr_aprov_fatura,
                                  lr_cdv_intg_fat_781.dat_envio_bilhete,
                                  lr_cdv_intg_fat_781.hor_envio_bilhete,
                                  lr_cdv_intg_fat_781.origem_integr,
                                  lr_cdv_intg_fat_781.certificado,
                                  lr_cdv_intg_fat_781.ativ,
                                  lr_cdv_intg_fat_781.sistema,
                                  lr_cdv_intg_fat_781.dat_apontamento)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","CDV_INTG_FAT_781")
       RETURN FALSE
    END IF


 END FOREACH
 FREE cq_desp_terc

 RETURN TRUE
 END FUNCTION


#-------------------------------------#
 FUNCTION cdv2000_verifica_acerto_fat()
#-------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_intg_fat_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
    AND usu_aprov_contab IS NOT NULL
    AND dat_aprov_contab IS NOT NULL
    AND hr_aprov_contab  IS NOT NULL
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    CALL log0030_mensagem('Viagem j� possui libera��o cont�bil.','exclamation')
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_intg_fat_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
    AND usu_aprov_fatura IS NOT NULL
    AND dat_aprov_fatura IS NOT NULL
    AND hr_aprov_fatura  IS NOT NULL
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    CALL log0030_mensagem('Viagem j� possui libera��o de faturamento.','exclamation')
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION


#-------------------------------------#
 FUNCTION cdv2000_verifica_fat_viag()
#-------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_intg_fat_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 100 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_intg_fat_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
    AND usu_aprov_fatura IS NULL
    AND dat_aprov_fatura IS NULL
    AND hr_aprov_fatura  IS NULL
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION


#---------------------------------#
 FUNCTION cdv2000_busca_ad_acerto()
#---------------------------------#
 DEFINE l_num_ad      LIKE cdv_acer_viag_781.ad_acerto_conta

 WHENEVER ERROR CONTINUE
 SELECT ad_acerto_conta
   INTO l_num_ad
   FROM cdv_acer_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_num_ad TO NULL
 END IF

 RETURN l_num_ad
 END FUNCTION

#---------------------------------#
 FUNCTION cdv2000_existe_desp_urb()
#---------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_desp_urb_781
 WHERE empresa = p_cod_empresa
   AND viagem  = mr_input.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_existe_desp_km_norm_reeb()
#-----------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT cdv_despesa_km_781.viagem
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa = p_cod_empresa
    AND cdv_tdesp_viag_781.empresa = p_cod_empresa
    AND cdv_despesa_km_781.viagem  = mr_input.viagem
    AND cdv_despesa_km_781.ativ_km = cdv_tdesp_viag_781.ativ
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
   # AND cdv_tdesp_viag_781.eh_reembolso = 'S' OS 516735 Bira
    AND cdv_tdesp_viag_781.eh_valz_km   = 'N'
    AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT cdv_despesa_km_781.viagem
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa = p_cod_empresa
    AND cdv_tdesp_viag_781.empresa = p_cod_empresa
    AND cdv_despesa_km_781.viagem  = mr_input.viagem
    AND cdv_despesa_km_781.ativ_km = cdv_tdesp_viag_781.ativ
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
    #AND cdv_tdesp_viag_781.eh_reembolso = 'S' OS 516735 Bira
    AND cdv_tdesp_viag_781.eh_valz_km   = 'S'
    AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#----------------------------------#
 FUNCTION cdv2000_aprov_eletronica()
#----------------------------------#
  DEFINE l_usa_aprovacao    LIKE cdv_par_padrao.parametro_ind,
         l_ies_forma_aprov  LIKE par_cap_pad.par_ies

  WHENEVER ERROR CONTINUE
  SELECT parametro_ind
    INTO l_usa_aprovacao
    FROM cdv_par_padrao
   WHERE empresa   = p_cod_empresa
     AND parametro = "aprov_eletro_cdv"
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     LET l_usa_aprovacao = "S"
  END IF

  IF l_usa_aprovacao = "S" THEN

     WHENEVER ERROR CONTINUE
     SELECT par_ies
       INTO l_ies_forma_aprov
       FROM par_cap_pad
      WHERE cod_empresa = p_cod_empresa
        AND cod_parametro = "ies_forma_aprov"
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
        ERROR "Problema sele��o PAR_CAP_PAD PARAM:'IES_FORMA_APROV'"
        SLEEP 1
        RETURN FALSE
      END IF

  END IF

 IF l_usa_aprovacao = 'S' THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_verifica_acer_tot_aprov()
#-----------------------------------------#
 DEFINE l_count_tot       INTEGER,
        l_count_aprov     INTEGER

 LET l_count_aprov = 0
 LET l_count_tot   = 0

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO l_count_tot
   FROM cdv_aprov_viag_781
  WHERE empresa     = p_cod_empresa
    AND viagem      = mr_input.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_count_tot = 0
 END IF

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO l_count_aprov
   FROM cdv_aprov_viag_781
  WHERE empresa     = p_cod_empresa
    AND viagem      = mr_input.viagem
    AND eh_aprovado = 'S'
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    LET l_count_aprov = 0
 END IF

 IF l_count_tot > 0 THEN
    IF l_count_tot = l_count_aprov THEN
       RETURN TRUE
    END IF
 END IF

 RETURN FALSE

 END FUNCTION

#------------------------------#
 FUNCTION cdv2000_monta_aen4()
#------------------------------#
  LET t_aen_309_conta_4[1].num_seq          = 1
  LET t_aen_309_conta_4[1].num_seq_lanc     = 1
  LET t_aen_309_conta_4[1].ies_tipo_lanc    = "D"
  LET t_aen_309_conta_4[1].num_conta_cont   = "X"
  LET t_aen_309_conta_4[1].ies_fornec_trans = "S"
  LET t_aen_309_conta_4[1].cod_lin_prod     = t_aen_309_4[1].cod_lin_prod
  LET t_aen_309_conta_4[1].cod_lin_recei    = t_aen_309_4[1].cod_lin_recei
  LET t_aen_309_conta_4[1].cod_seg_merc     = t_aen_309_4[1].cod_seg_merc
  LET t_aen_309_conta_4[1].cod_cla_uso      = t_aen_309_4[1].cod_cla_uso
  LET t_aen_309_conta_4[1].val_aen          = t_aen_309_4[1].val_aen

  LET t_aen_309_conta_4[2].num_seq          = 2
  LET t_aen_309_conta_4[2].num_seq_lanc     = 2
  LET t_aen_309_conta_4[2].ies_tipo_lanc    = "C"
  LET t_aen_309_conta_4[2].num_conta_cont   = "X"
  LET t_aen_309_conta_4[2].ies_fornec_trans = "S"
  LET t_aen_309_conta_4[2].cod_lin_prod     = t_aen_309_4[1].cod_lin_prod
  LET t_aen_309_conta_4[2].cod_lin_recei    = t_aen_309_4[1].cod_lin_recei
  LET t_aen_309_conta_4[2].cod_seg_merc     = t_aen_309_4[1].cod_seg_merc
  LET t_aen_309_conta_4[2].cod_cla_uso      = t_aen_309_4[1].cod_cla_uso
  LET t_aen_309_conta_4[2].val_aen          = t_aen_309_4[1].val_aen

 END FUNCTION

#-------------------------------------------------------------------------------------------#
 FUNCTION cdv2000_calc_val_liquido_ap(l_cod_empresa, m_num_ap, l_versao_atual, l_num_versao)
#-------------------------------------------------------------------------------------------#
  DEFINE l_cod_empresa      LIKE ap.cod_empresa,
         m_num_ap           LIKE ap.num_ap,
         l_versao_atual     LIKE ap.ies_versao_atual,
         l_num_versao       LIKE ap.num_versao

  DEFINE sql_stmt           CHAR(500),
         l_cod_moeda_padrao LIKE par_cap.cod_moeda_padrao,
         l_val_liquido      LIKE ap.val_nom_ap,
         l_cod_moeda        LIKE ap.cod_moeda,
         l_val_ap_dat_pgto  LIKE ap.val_ap_dat_pgto,
         l_val_nom_ap       LIKE ap.val_nom_ap,
         l_valor            LIKE ap_valores.valor,
         l_ies_alt_val_pag  LIKE tipo_valor.ies_alt_val_pag

  LET l_val_liquido = 0

  WHENEVER ERROR CONTINUE
   SELECT cod_moeda_padrao
     INTO l_cod_moeda_padrao
     FROM par_cap
    WHERE cod_empresa = l_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log0030_mensagem("Problema sele��o moeda padr�o Contas a Pagar.","exclamation")
     RETURN FALSE, l_val_liquido
  END IF

  INITIALIZE sql_stmt TO NULL
  LET sql_stmt = 'SELECT cod_moeda, val_ap_dat_pgto, val_nom_ap',
                  ' FROM ap',
                 ' WHERE cod_empresa = "',l_cod_empresa,'"',
                   ' AND num_ap = ',m_num_ap

  IF l_versao_atual = 'S' THEN
     LET sql_stmt = sql_stmt CLIPPED,  ' AND ies_versao_atual = "S"'
  ELSE
     LET sql_stmt = sql_stmt CLIPPED,  ' AND num_versao = ', l_num_versao
  END IF

  WHENEVER ERROR CONTINUE
   PREPARE var_dados_ap FROM sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("PREPARE","var_dados_ap")
     RETURN FALSE, l_val_liquido
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_dados_ap CURSOR FOR var_dados_ap
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_DADOS_AP")
     RETURN FALSE, l_val_liquido
  END IF

  WHENEVER ERROR CONTINUE
   OPEN cq_dados_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("OPEN","cq_dados_ap")
     RETURN FALSE, l_val_liquido
  END IF

  WHENEVER ERROR CONTINUE
   FETCH cq_dados_ap INTO l_cod_moeda, l_val_ap_dat_pgto, l_val_nom_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("FETCH","cq_dados_ap")
     RETURN FALSE, l_val_liquido
  END IF

  IF l_cod_moeda <> l_cod_moeda_padrao THEN
     LET l_val_liquido = l_val_ap_dat_pgto
  ELSE
     LET l_val_liquido = l_val_nom_ap
  END IF

  INITIALIZE sql_stmt TO NULL
  LET sql_stmt = 'SELECT valor, ies_alt_val_pag',
                  ' FROM ap_valores, tipo_valor',
                 ' WHERE ap_valores.cod_empresa = "',l_cod_empresa,'"',
                   ' AND ap_valores.num_ap = ',m_num_ap,
                   ' AND tipo_valor.cod_empresa = ap_valores.cod_empresa',
                   ' AND tipo_valor.cod_tip_val = ap_valores.cod_tip_val'

  IF l_versao_atual = 'S' THEN
     LET sql_stmt = sql_stmt CLIPPED,  ' AND ap_valores.ies_versao_atual = "S"'
  ELSE
     LET sql_stmt = sql_stmt CLIPPED,  ' AND ap_valores.num_versao = ', l_num_versao
  END IF

  WHENEVER ERROR CONTINUE
   PREPARE var_ajustes FROM sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("PREPARE","var_ajustes")
     RETURN FALSE, l_val_liquido
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_ajustes CURSOR FOR var_ajustes
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_AJUSTES")
     RETURN FALSE, l_val_liquido
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_ajustes INTO l_valor, l_ies_alt_val_pag
  WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_AJUSTES")
       RETURN FALSE, l_val_liquido
    END IF

    IF l_ies_alt_val_pag = "+" THEN
       LET l_val_liquido = l_val_liquido + l_valor
    END IF
    IF l_ies_alt_val_pag = "-" THEN
       LET l_val_liquido = l_val_liquido - l_valor
    END IF

 END FOREACH
 CLOSE cq_dados_ap
  FREE cq_dados_ap

 CLOSE cq_ajustes
  FREE cq_ajustes

 RETURN TRUE, l_val_liquido

END FUNCTION


#---------------------------------------------#
 FUNCTION cdv2000_paginacao_desp_urb(l_funcao)
#---------------------------------------------#
  DEFINE l_funcao           CHAR(20),
         l_viagem           LIKE cdv_desp_terc_781.viagem,
         l_controle         LIKE cdv_solic_viag_781.controle

  IF m_consulta_urb_aut = TRUE THEN
     WHILE TRUE
        IF l_funcao = "SEGUINTE" THEN
           WHENEVER ERROR CONTINUE
            FETCH NEXT cq_desp_urb_aut INTO l_viagem
           WHENEVER ERROR STOP
        ELSE
           WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_desp_urb_aut INTO l_viagem
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR 'N�o existem mais itens nesta dire��o.'
           EXIT WHILE
        ELSE
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql('FETCH','cq_desp_urbanas')
              EXIT WHILE
           ELSE
              IF mr_desp_urbana.viagem = l_viagem THEN
                 IF l_funcao = "SEGUINTE" THEN
                    WHENEVER ERROR CONTINUE
                     FETCH NEXT cq_desp_urb_aut INTO l_viagem
                    WHENEVER ERROR STOP
                 END IF
              END IF

              WHENEVER ERROR CONTINUE
               SELECT cdv_solic_viag_781.viagem, cdv_solic_viag_781.controle
                 INTO l_viagem, l_controle
                 FROM cdv_solic_viag_781
                WHERE cdv_solic_viag_781.empresa = p_cod_empresa
                  AND cdv_solic_viag_781.viagem  = l_viagem
              WHENEVER ERROR STOP

              IF SQLCA.SQLCODE = 0
              OR SQLCA.SQLCODE = -284 THEN
                   LET mr_desp_urbana.viagem   = l_viagem
                   LET mr_desp_urbana.controle = l_controle
                   INITIALIZE m_den_acerto TO NULL

                   IF NOT cdv2000_carrega_ativs(mr_desp_urbana.viagem) THEN
                   END IF

                   LET m_den_acerto = cdv2000_busca_den_acerto(l_viagem)
                   DISPLAY BY NAME mr_desp_urbana.*
                   DISPLAY '' TO tot_geral
                   LET m_viagem_urbanas = mr_desp_urbana.viagem

                   IF NOT cdv2000_carrega_urbanas_ja_informadas(mr_desp_urbana.viagem, 'MANUAL') THEN
                      RETURN
                   END IF

                   CALL cdv2000_exibe_desp_urbanas(1)

                 EXIT WHILE
              END IF
           END IF
        END IF
     END WHILE
  ELSE
     ERROR 'N�o existem mais itens nesta dire��o.'
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_busca_den_acerto(l_viagem)
#-----------------------------------------#

 DEFINE l_viagem             LIKE cdv_solic_viag_781.viagem,
        l_status_acer_viagem LIKE cdv_acer_viag_781.status_acer_viagem

  WHENEVER ERROR CONTINUE
   SELECT status_acer_viagem
     INTO l_status_acer_viagem
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0 THEN
     CASE l_status_acer_viagem
        WHEN 1
           RETURN 'ACERTO VIAGEM PENDENTE'
        WHEN 2
           RETURN 'ACERTO VIAGEM INICIADO'
        WHEN 3
           RETURN 'ACERTO VIAGEM FINALIZADO'
        WHEN 4
           RETURN 'ACERTO VIAGEM LIBERADO'
     END CASE
  ELSE
     RETURN '   '
  END IF

 END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2000_paginacao_desp_km(l_funcao)
#-------------------------------------------#
  DEFINE l_funcao           CHAR(20),
         l_viagem           LIKE cdv_desp_terc_781.viagem,
         l_controle         LIKE cdv_solic_viag_781.controle

  INITIALIZE ma_desp_km TO NULL #
  IF m_consulta_km_aut = TRUE THEN

     WHILE TRUE
        IF l_funcao = "SEGUINTE" THEN
           WHENEVER ERROR CONTINUE
            FETCH NEXT cq_desp_km_aut INTO l_viagem
           WHENEVER ERROR STOP
        ELSE
           WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_desp_km_aut INTO l_viagem
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = NOTFOUND THEN
           ERROR 'N�o existem mais itens nesta dire��o.'
           EXIT WHILE
        ELSE
           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql('FETCH','cq_desp_km_aut')
              EXIT WHILE
           ELSE
              IF mr_desp_km.viagem = l_viagem THEN
                 IF l_funcao = "SEGUINTE" THEN
                    WHENEVER ERROR CONTINUE
                     FETCH NEXT cq_desp_km_aut INTO l_viagem
                    WHENEVER ERROR STOP
                 END IF
              END IF

              WHENEVER ERROR CONTINUE
               SELECT viagem, controle
                 INTO l_viagem, l_controle
                 FROM cdv_solic_viag_781
                WHERE empresa = p_cod_empresa
                  AND viagem  = l_viagem
              WHENEVER ERROR STOP

              IF SQLCA.SQLCODE = 0
              OR SQLCA.SQLCODE = -284 THEN
                   CLEAR FORM
                   LET mr_desp_km.viagem   = l_viagem
                   LET mr_desp_km.controle = l_controle
                   INITIALIZE m_den_acerto TO NULL

                   IF NOT cdv2000_carrega_ativs(mr_desp_km.viagem) THEN
                   END IF

                   LET m_den_acerto = cdv2000_busca_den_acerto(l_viagem)
                   DISPLAY p_cod_empresa TO empresa
                   DISPLAY BY NAME mr_desp_km.*

                   IF NOT cdv2000_carrega_km_ja_informadas(mr_desp_km.viagem, 'MANUAL') THEN
                      RETURN
                   END IF

                   CALL cdv2000_exibe_desp_km(1)

                 EXIT WHILE
              END IF
           END IF
        END IF
     END WHILE
  ELSE
     ERROR 'N�o existem mais itens nesta dire��o.'
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2000_busca_viajante(l_viagem)
#--------------------------------------------#
 DEFINE l_usuario_logix    LIKE cdv_info_viajante.usuario_logix,
        l_viagem           LIKE cdv_solic_viag_781.viagem

 LET l_usuario_logix = NULL

 WHENEVER ERROR CONTINUE
  SELECT usuario_logix
    INTO l_usuario_logix
    FROM cdv_info_viajante, cdv_solic_viag_781
   WHERE cdv_solic_viag_781.empresa   = p_cod_empresa
     AND cdv_solic_viag_781.viagem    = l_viagem
     AND cdv_info_viajante.empresa   = cdv_solic_viag_781.empresa
     AND cdv_info_viajante.matricula = cdv_solic_viag_781.viajante
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> 100 THEN
    CALL log003_err_sql('SELECAO','cdv_info_viajante2')
 END IF

 RETURN l_usuario_logix

 END FUNCTION

#--------------------------------------------------------#
 FUNCTION cdv2000_verifica_usuario_viajante(l_viagem)
#--------------------------------------------------------#
 DEFINE l_usuario_logix    LIKE cdv_info_viajante.usuario_logix,
        l_viagem           LIKE cdv_solic_viag_781.viagem

 CALL cdv2000_busca_viajante(l_viagem) RETURNING l_usuario_logix

 IF p_user <> l_usuario_logix THEN
    IF m_emite_solic_viagem = "S" THEN
       RETURN TRUE
    END IF
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_carrega_cc_debitar()
#-------------------------------------#

  DEFINE l_cc_debitar LIKE cdv_solic_viag_781.cc_debitar

  INITIALIZE l_cc_debitar TO NULL

  CALL log2250_busca_parametro(p_cod_empresa,"cc_debitar_pamcary") RETURNING l_cc_debitar, p_status
  IF p_status = FALSE OR
     l_cc_debitar IS NULL OR
     l_cc_debitar = " " THEN
     INITIALIZE l_cc_debitar TO NULL
  END IF

  RETURN l_cc_debitar

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2000_busca_ativ_por_tdesp(l_tipo_despesa)
#----------------------------------------------------#

 DEFINE l_tipo_despesa      LIKE cdv_apont_hor_781.tdesp_apont_hor,
        l_ativ              LIKE cdv_tdesp_viag_781.ativ

 WHENEVER ERROR CONTINUE
 SELECT ativ
   INTO l_ativ
   FROM cdv_tdesp_viag_781
  WHERE empresa            = p_cod_empresa
    AND tip_despesa_viagem = l_tipo_despesa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_TDESP_VIAG_781")
    INITIALIZE l_ativ TO NULL
 END IF

 RETURN l_ativ
 END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2000_busca_data_viagem(l_viagem)
#-------------------------------------------#

 DEFINE l_viagem LIKE cdv_solic_viag_781.viagem,
        l_data   DATE


 INITIALIZE l_data TO NULL

 WHENEVER ERROR CONTINUE
 SELECT DATE(dat_hor_partida)
  INTO l_data
  FROM cdv_solic_viag_781
 WHERE empresa = p_cod_empresa
   AND viagem  = l_viagem
 WHENEVER ERROR STOP

 RETURN l_data
 END FUNCTION

#------------------------------------------------------------#
 FUNCTION cdv2000_recupera_qtd_km_despesas_km(l_viagem, l_grp)
#------------------------------------------------------------#
  DEFINE l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_qtd_km_semanal   DECIMAL(17,2),
         l_grp              LIKE cdv_tdesp_viag_781.grp_despesa_viagem

  LET l_qtd_km_semanal = 0
  WHENEVER ERROR CONTINUE
   SELECT SUM(km.qtd_km)
     INTO l_qtd_km_semanal
     FROM cdv_despesa_km_781 km, cdv_tdesp_viag_781 td
    WHERE km.empresa            = p_cod_empresa
      AND km.viagem             = l_viagem
      AND td.empresa            = km.empresa
      AND km.ativ_km            = td.ativ
      AND td.tip_despesa_viagem = km.tip_despesa_viagem
      AND td.grp_despesa_viagem IN ('2','3')
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','qtd-km/td')
     RETURN FALSE, l_qtd_km_semanal
  END IF

  IF l_qtd_km_semanal IS NULL THEN
     LET l_qtd_km_semanal = 0
  END IF

  RETURN TRUE, l_qtd_km_semanal

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2000_recupera_qtd_hor_despesas_km(l_viagem, l_grp)
#-------------------------------------------------------------#
  DEFINE l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_qtd_hor_semanal  DECIMAL(17,2),
         l_grp              LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
         l_noturnas         CHAR(08),
         l_diurnas          CHAR(08),
         l_horas_total      CHAR(09),
         l_horas            DECIMAL(3,0),
         l_minutos          DECIMAL(3,0),
         l_segundos         DECIMAL(3,0),
         l_resultado        DECIMAL(17,5),
         l_resultado_i      INTEGER

  LET l_horas_total = '000:00:00'
  WHENEVER ERROR CONTINUE
   DECLARE cq_soma_hor CURSOR FOR
   SELECT hor.hor_diurnas, hor.hor_noturnas
     FROM cdv_apont_hor_781 hor, cdv_tdesp_viag_781 td
    WHERE hor.empresa           = p_cod_empresa
      AND hor.viagem            = l_viagem
      AND td.empresa            = hor.empresa
      AND hor.ativ              = td.ativ
      AND td.tip_despesa_viagem = hor.tdesp_apont_hor
      AND td.grp_despesa_viagem = l_grp
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','qtd-hor/td')
     RETURN FALSE, l_horas_total
  END IF

  LET l_horas    = 0
  LET l_minutos  = 0
  LET l_segundos = 0
  WHENEVER ERROR CONTINUE
  FOREACH cq_soma_hor INTO l_diurnas, l_noturnas
  WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        EXIT FOREACH
     END IF

     LET l_horas    = l_horas    + l_diurnas[1,2] + l_noturnas[1,2]
     LET l_minutos  = l_minutos  + l_diurnas[4,5] + l_noturnas[4,5]
     LET l_segundos = l_segundos + l_diurnas[7,8] + l_noturnas[7,8]

  END FOREACH
  FREE cq_soma_hor

  LET l_resultado   = 0
  LET l_resultado_i = 0

  IF l_segundos >= 60
  OR l_minutos >= 60 THEN
     CALL cdv2000_retorna_tempo(l_horas, l_minutos, l_segundos)
     RETURNING l_horas, l_minutos, l_segundos
  END IF

  LET l_horas_total = l_horas  USING "&&&", ":",
                      l_minutos USING "&&", ":",
                      l_segundos USING "&&"

  IF l_horas_total IS NULL THEN
     LET l_horas_total = '00:00:00'
  END IF

  RETURN TRUE, l_horas_total

END FUNCTION


#-------------------------------------------------------------#
 FUNCTION cdv2000_retorna_tempo(l_horas, l_minutos, l_segundos)
#-------------------------------------------------------------#

 DEFINE l_horas       DECIMAL(17,5),
        l_minutos     DECIMAL(17,5),
        l_segundos    DECIMAL(17,5),
        l_resultado   DECIMAL(17,5),
        l_resultado_i DECIMAL(17,5),
        l_resto       DECIMAL(5,5)

 LET l_resultado    = 0
 LET l_resultado_i  = 0
 LET l_resto        = 0

 IF l_segundos >= 60 THEN

    LET l_resultado   = l_segundos / 60
    LET l_resultado_i = l_resultado USING "############"
    LET l_resto       = l_resultado - l_resultado_i
    LET l_minutos     = l_minutos   + l_resultado_i

    IF l_resto < 0 THEN
       LET l_segundos    = 0
    ELSE
       LET l_segundos    = (60 * l_resto)
    END IF

 END IF

 LET l_resultado    = 0
 LET l_resultado_i  = 0
 LET l_resto        = 0

 IF l_minutos >= 60 THEN

    LET l_resultado   = l_minutos / 60
    LET l_resultado_i = l_resultado USING "############"
    LET l_resto       = l_resultado - l_resultado_i
    LET l_horas       = l_horas     + l_resultado_i

    IF l_resto < 0 THEN
       LET l_minutos     = 0
    ELSE
       LET l_minutos     = (60 * l_resto)
    END IF

 END IF

 IF l_horas IS NULL THEN
    LET l_horas    = 0
 END IF

 IF l_minutos IS NULL THEN
    LET l_minutos  = 0
 END IF

 IF l_segundos IS NULL THEN
    LET l_segundos = 0
 END IF

 RETURN l_horas, l_minutos, l_segundos
 END FUNCTION

#------------------------------------------------------------------------#
 FUNCTION cdv2000_valida_ativ_bloqueda(l_viagem, l_controle, l_ativ, l_tipo_despesa)
#------------------------------------------------------------------------#

 DEFINE l_viagem        LIKE cdv_solic_viag_781.viagem,
        l_controle      LIKE cdv_controle_781.controle,
        l_ativ          LIKE cdv_tdesp_viag_781.ativ,
        l_tipo_despesa  LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_controle_pai  LIKE cdv_controle_781.controle_pai,
        l_msg           CHAR(200),
        l_finalidade    LIKE cdv_solic_viag_781.finalidade_viagem

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM cdv_tdesp_viag_781
  WHERE empresa            = p_cod_empresa
    AND tip_despesa_viagem = l_tipo_despesa
    AND ativ               = l_ativ
    AND eh_valz_km         = "N"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    CALL log0030_mensagem("Km/Horas ASLE pelo AUTOTRAC para veiculo frota/alugado, est� bloqueada a digita��o pelo CDV nestes casos.","exclamation")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT empresa
    FROM cdv_tdesp_viag_781
   WHERE empresa            = p_cod_empresa
     AND tip_despesa_viagem = l_tipo_despesa
     AND ativ               = l_ativ
     AND eh_valz_km         = "S"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN

    INITIALIZE l_finalidade TO NULL
    WHENEVER ERROR CONTINUE
    SELECT finalidade_viagem
      INTO l_finalidade
      FROM cdv_solic_viag_781
     WHERE empresa = p_cod_empresa
       AND viagem  = l_viagem
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("SELECT","CDV_SOLIC_VIAG_781")
       RETURN TRUE
    END IF

    LET l_finalidade = l_finalidade[1,2]
    WHENEVER ERROR CONTINUE
     SELECT controle_pai
       INTO l_controle_pai
       FROM cdv_controle_781
      WHERE controle     = l_controle
        AND tip_processo = 2
        AND sistema[1,2] = l_finalidade
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0
    OR sqlca.sqlcode = -284 THEN
       LET l_msg = "Apontamento permitido somente para controle n. ", l_controle_pai USING "<<<<<<<<<<<<<<<<<<&&"
       CALL log0030_mensagem(l_msg,"exclamation")
       RETURN FALSE
    END IF

 END IF

 RETURN TRUE
 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2000_busca_controle_receb(l_viagem)
#----------------------------------------------#

 DEFINE l_viagem     LIKE cdv_solic_viag_781.viagem,
        l_controle   LIKE cdv_solic_viag_781.controle

 INITIALIZE l_controle TO NULL
 WHENEVER ERROR CONTINUE
 SELECT controle
   INTO l_controle
   FROM cdv_solic_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_controle TO NULL
 END IF

 RETURN l_controle
 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION cdv2000_valida_controle_finalidade(l_controle, l_finalidade)
#--------------------------------------------------------------------#
 DEFINE l_controle       LIKE cdv_controle_781.controle,
        l_finalidade     LIKE cdv_finalidade_781.finalidade,
        l_encerrado      CHAR(01),
        l_sqlca          SMALLINT,
        l_finalidade_enc LIKE cdv_finalidade_781.finalidade

 LET l_finalidade_enc = l_finalidade
 LET l_finalidade     = l_finalidade[1,2]
 WHENEVER ERROR CONTINUE
 SELECT UNIQUE encerrado, cliente_atendido,   cliente_fatur, tip_processo
   INTO l_encerrado,      m_cliente_atendido, m_cliente_fatur, m_tip_processo
   FROM cdv_controle_781
  WHERE controle = l_controle
    AND sistema[1,2]  = l_finalidade
    #AND encerrado = 'N'
 WHENEVER ERROR STOP

 LET l_sqlca = sqlca.sqlcode

 IF cdv2000_finalidade_valida_ctr_encerrado(l_finalidade_enc) THEN
    IF l_encerrado = "S" THEN
       CALL log0030_mensagem("Controle encerrado n�o pode ser utilizado.","exclamation")
       RETURN FALSE
    END IF
 END IF

 IF l_sqlca = 100 THEN
    CALL log0030_mensagem("Controle n�o cadastrado para esta finalidade.","exclamation")
    RETURN FALSE
 END IF

 IF m_tip_processo IS NULL THEN
    LET m_tip_processo = 99
 END IF

 IF l_sqlca = 0
 OR l_sqlca = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv2000_busca_finalidade_acer(l_viagem)
#-----------------------------------------------#
 DEFINE l_viagem      LIKE cdv_solic_viag_781.viagem,
        l_finalidade  LIKE cdv_acer_viag_781.finalidade_viagem

 WHENEVER ERROR CONTINUE
 SELECT finalidade_viagem
   INTO l_finalidade
   FROM cdv_acer_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN ''
 END IF

 RETURN l_finalidade
 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_busca_raz_social_reduz(l_empresa)
#-------------------------------------------------#
 DEFINE l_empresa   LIKE empresa.cod_empresa,
        l_den_reduz LIKE empresa.den_reduz

 WHENEVER ERROR CONTINUE
 SELECT den_reduz
   INTO l_den_reduz
   FROM empresa
  WHERE cod_empresa = l_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
 END IF

 RETURN l_den_reduz
 END FUNCTION


#------------------------------------------#
 FUNCTION cdv2000_busca_den_viagem(l_viagem)
#------------------------------------------#
  DEFINE l_viagem             LIKE cdv_solic_viag_781.viagem,
         l_status_acer_viagem LIKE cdv_acer_viag_781.status_acer_viagem,
         l_den_viagem         CHAR(50)

  WHENEVER ERROR CONTINUE
   SELECT status_acer_viagem
     INTO l_status_acer_viagem
     FROM cdv_acer_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0 THEN
     CASE l_status_acer_viagem
        WHEN 1
           LET l_den_viagem = 'ACERTO VIAGEM PENDENTE'
        WHEN 2
           LET l_den_viagem = 'ACERTO VIAGEM INICIADO'
        WHEN 3
           LET l_den_viagem = 'ACERTO VIAGEM FINALIZADO'
        WHEN 4
           LET l_den_viagem = 'ACERTO VIAGEM LIBERADO'
     END CASE
  END IF

 RETURN l_den_viagem
 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2000_verifica_ad_ap_paga(l_num_ad, l_situacao)
#---------------------------------------------------------#
 DEFINE l_num_ad        LIKE ad_mestre.num_ad,
        l_situacao      SMALLINT

 IF l_situacao = 1 THEN
    WHENEVER ERROR CONTINUE
    SELECT ad_ap.num_ap
      FROM ad_ap, ap
     WHERE ad_ap.cod_empresa   = p_cod_empresa
       AND ap.cod_empresa      = p_cod_empresa
       AND ad_ap.num_ad        = l_num_ad
       AND ad_ap.num_ap        = ap.num_ap
       AND ap.ies_versao_atual = "S"
       AND ap.dat_pgto         IS NOT NULL
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0
    OR sqlca.sqlcode = -284 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
    SELECT ad_ap.num_ap
      FROM ad_ap
     WHERE ad_ap.cod_empresa   = p_cod_empresa
       AND ad_ap.num_ad        = l_num_ad
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0
    OR sqlca.sqlcode = -284 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF
 END IF

 END FUNCTION

#----------------------------------------------------------------#
 FUNCTION cdv2000_calcula_hr_diurnas(l_hora_inicial, l_hora_final)
#----------------------------------------------------------------#

 DEFINE l_hora_inicial          DATETIME HOUR TO SECOND,
        l_hora_final            DATETIME HOUR TO SECOND,
        l_hora_diurna           DATETIME HOUR TO SECOND,
        l_status                SMALLINT

 LET l_status = FALSE
 LET l_hora_diurna = '00:00:00'

 IF (l_hora_inicial   >= m_hor_ini_noturna    #Esta fora do periodo diurno
     AND l_hora_final >= m_hor_ini_noturna)
 OR (l_hora_inicial   <= m_hor_ini_diurna
     AND l_hora_final <= m_hor_ini_diurna) THEN
    RETURN l_hora_diurna
 END IF

 IF l_hora_inicial >= m_hor_ini_diurna
 AND NOT (l_hora_inicial >= m_hor_ini_diurna AND l_hora_final <= m_hor_ini_noturna) #se for diurno e noturno
 AND l_hora_final <= m_hor_ini_noturna THEN #
    LET l_hora_diurna = l_hora_diurna + (l_hora_inicial - m_hor_ini_diurna)
 END IF

 IF l_hora_inicial >= m_hor_ini_diurna                                              ###
 AND NOT (l_hora_inicial >= m_hor_ini_diurna AND l_hora_final <= m_hor_ini_noturna) ### se for diurno e noturno
 AND l_hora_final >= m_hor_ini_noturna THEN                                         ###
    LET l_status = TRUE
    LET l_hora_diurna = l_hora_diurna + (m_hor_ini_noturna - l_hora_inicial)
 END IF

 IF  l_hora_final >= m_hor_ini_diurna
 AND l_hora_final <= m_hor_ini_noturna
 AND NOT (l_hora_inicial >= m_hor_ini_diurna AND l_hora_final <= m_hor_ini_noturna) THEN
    LET l_status = TRUE
    LET l_hora_diurna = l_hora_diurna + (l_hora_final - m_hor_ini_diurna)
 END IF

 IF  l_hora_inicial >= m_hor_ini_diurna
 AND l_hora_final <= m_hor_ini_noturna THEN
    LET l_status = TRUE
    LET l_hora_diurna = l_hora_diurna + (l_hora_final - l_hora_inicial)
 END IF

 IF  l_hora_inicial <= m_hor_ini_diurna
 AND l_hora_final   >= m_hor_ini_noturna
 AND l_status        = FALSE THEN
    LET l_hora_diurna = l_hora_diurna + (m_hor_ini_noturna - m_hor_ini_diurna)
 END IF

 RETURN l_hora_diurna
 END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION cdv2000_calcula_hr_noturnas(l_hora_inicial, l_hora_final)
#-----------------------------------------------------------------#
 DEFINE l_hora_inicial          DATETIME HOUR TO SECOND,
        l_hora_final            DATETIME HOUR TO SECOND,
        l_hora_noturna          DATETIME HOUR TO SECOND,
        l_status                SMALLINT

 LET l_status = FALSE
 LET l_hora_noturna = '00:00:00'

 IF  l_hora_inicial >= m_hor_ini_diurna  #fora do periodo noturno
 AND l_hora_final   <= m_hor_ini_noturna THEN
    RETURN l_hora_noturna
 END IF

 IF (l_hora_inicial <= m_hor_ini_diurna
   AND l_hora_final <= m_hor_ini_diurna)
 OR (l_hora_inicial >= m_hor_ini_noturna
  AND l_hora_final  >= m_hor_ini_noturna) THEN
     LET l_hora_noturna = l_hora_noturna + (l_hora_final - l_hora_inicial)
     RETURN l_hora_noturna
  END IF

 IF l_hora_inicial <= m_hor_ini_diurna THEN
    LET l_hora_noturna = l_hora_noturna + (m_hor_ini_diurna - l_hora_inicial)
 END IF

 IF l_hora_final >= m_hor_ini_noturna THEN
    LET l_status = TRUE
    LET l_hora_noturna = l_hora_noturna + (l_hora_final - m_hor_ini_noturna)
 END IF

 IF  l_hora_inicial <= m_hor_ini_noturna
 AND l_hora_final   >= m_hor_ini_noturna
 AND l_status        = FALSE THEN
    LET l_hora_noturna = l_hora_noturna + (m_hor_ini_noturna - l_hora_final)
 END IF

 RETURN l_hora_noturna
 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2000_finalidade_valida_ctr_encerrado(l_finalidade)
#-------------------------------------------------------------#
 DEFINE l_finalidade   LIKE cdv_finalidade_781.finalidade

 WHENEVER ERROR CONTINUE
 SELECT finalidade
   FROM cdv_finalidade_781
  WHERE finalidade = l_finalidade
    AND eh_ctr_encerram = 'S'
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2000_exclui_dev_transf()
#-----------------------------------#

 WHENEVER ERROR CONTINUE
 DELETE FROM cdv_dev_transf_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_dev_transf.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","CDV_DEV_TRANSF_781")
    RETURN FALSE
 END IF

 CLEAR FORM
 INITIALIZE mr_dev_transf.status,          mr_dev_transf.den_status,        mr_dev_transf.val_devolucao,
            mr_dev_transf.dat_devolucao,   mr_dev_transf.forma,             mr_dev_transf.den_forma,
            mr_dev_transf.doc_devolucao,   mr_dev_transf.dat_doc_devolucao, mr_dev_transf.caixa,
            mr_dev_transf.den_caixa,       mr_dev_transf.cta_corrente,      mr_dev_transf.banco,
            mr_dev_transf.den_banco,       mr_dev_transf.val_transf,        mr_dev_transf.dat_transf,
            mr_dev_transf.viagem_receb,    mr_dev_transf.controle_receb,    mr_dev_transf.agencia,
            mr_dev_transf.observacao TO NULL

 CALL cdv2000_exibe_dados_dev_transf()

 RETURN TRUE
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2000_exibe_dados_dev_transf()
#-----------------------------------------#

 DISPLAY p_cod_empresa TO empresa
 DISPLAY BY NAME mr_dev_transf.*

 END FUNCTION

#-----------------------------------------------------------------------------------------#
 FUNCTION cdv2000_valida_documento_existente(l_num_nf, l_serie,  l_sub_serie, l_fornecedor)
#-----------------------------------------------------------------------------------------#

 DEFINE l_num_nf      LIKE cdv_desp_terc_781.nota_fiscal,
        l_serie       LIKE cdv_desp_terc_781.serie_nota_fiscal,
        l_sub_serie   LIKE cdv_desp_terc_781.subserie_nf,
        l_fornecedor  LIKE cdv_desp_terc_781.fornecedor

 IF  l_serie IS NULL
 AND l_sub_serie IS NULL THEN
    WHENEVER ERROR CONTINUE
    SELECT ad_mestre.cod_empresa FROM ad_mestre
     WHERE ad_mestre.cod_empresa    = p_cod_empresa
       AND ad_mestre.cod_fornecedor = l_fornecedor
       AND ad_mestre.num_nf         = l_num_nf
       AND ad_mestre.ser_nf         IS NULL
       AND ad_mestre.ssr_nf         IS NULL
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0 THEN
       RETURN FALSE
    END IF
 ELSE
    IF  l_serie IS NOT NULL
    AND l_sub_serie IS NOT NULL THEN
       WHENEVER ERROR CONTINUE
       SELECT ad_mestre.cod_empresa FROM ad_mestre
        WHERE ad_mestre.cod_empresa    = p_cod_empresa
          AND ad_mestre.cod_fornecedor = l_fornecedor
          AND ad_mestre.num_nf         = l_num_nf
          AND ad_mestre.ser_nf         = l_serie
          AND ad_mestre.ssr_nf         = l_sub_serie
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
          RETURN FALSE
       END IF
    ELSE
       IF l_sub_serie IS NULL THEN
          WHENEVER ERROR CONTINUE
          SELECT ad_mestre.cod_empresa FROM ad_mestre
           WHERE ad_mestre.cod_empresa    = p_cod_empresa
             AND ad_mestre.cod_fornecedor = l_fornecedor
             AND ad_mestre.num_nf         = l_num_nf
             AND ad_mestre.ser_nf         = l_serie
             AND ad_mestre.ssr_nf         IS NULL
          WHENEVER ERROR STOP

          IF sqlca.sqlcode = 0 THEN
             RETURN FALSE
          END IF
       END IF
       IF l_serie IS NULL THEN
          WHENEVER ERROR CONTINUE
          SELECT ad_mestre.cod_empresa FROM ad_mestre
           WHERE ad_mestre.cod_empresa    = p_cod_empresa
             AND ad_mestre.cod_fornecedor = l_fornecedor
             AND ad_mestre.num_nf         = l_num_nf
             AND ad_mestre.ser_nf         IS NULL
             AND ad_mestre.ssr_nf         = l_sub_serie
          WHENEVER ERROR STOP

          IF sqlca.sqlcode = 0 THEN
             RETURN FALSE
          END IF
       END IF
    END IF
 END IF

 RETURN TRUE
 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2000_busca_km_inicial(l_viagem)
#------------------------------------------#
 DEFINE l_viagem     LIKE cdv_solic_viag_781.viagem,
        l_km_final LIKE cdv_despesa_km_781.km_inicial

 INITIALIZE l_km_final TO NULL

 WHENEVER ERROR CONTINUE
 SELECT MAX(km_final)
   INTO l_km_final
   FROM cdv_despesa_km_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_km_final TO NULL
 END IF

 RETURN l_km_final
 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_busca_placa(l_viagem)
#-------------------------------------#
 DEFINE l_viagem     LIKE cdv_solic_viag_781.viagem,
        l_placa      LIKE cdv_despesa_km_781.placa

 INITIALIZE l_placa TO NULL

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE placa
   INTO l_placa
   FROM cdv_despesa_km_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_placa TO NULL
 END IF

 RETURN l_placa
 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2000_verifica_placa(l_viagem, l_placa)
#-------------------------------------------------#
 DEFINE l_viagem    LIKE cdv_solic_viag_781.viagem,
        l_placa     LIKE cdv_despesa_km_781.placa

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM cdv_despesa_km_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
    AND placa  <> l_placa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2000_valida_km_inicial(l_viagem, l_km_inicial)
#---------------------------------------------------------#
 DEFINE l_viagem      LIKE cdv_solic_viag_781.viagem,
        l_km_inicial  LIKE cdv_despesa_km_781.km_inicial

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM cdv_despesa_km_781
  WHERE empresa   = p_cod_empresa
    AND viagem    = l_viagem
    AND km_final  > l_km_inicial
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION cdv2000_verifica_td_km_digitada(l_viagem, l_tipo_despesa_km)
#--------------------------------------------------------------------#
 DEFINE l_viagem           LIKE cdv_solic_viag_781.viagem,
        l_tipo_despesa_km  LIKE cdv_despesa_km_781.tip_despesa_viagem

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM cdv_despesa_km_781
  WHERE empresa             = p_cod_empresa
    AND viagem              = l_viagem
    AND tip_despesa_viagem  <> l_tipo_despesa_km
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION cdv2000_verifica_td_hr_digitada(l_viagem, l_tipo_despesa_hr)
#--------------------------------------------------------------------#
 DEFINE l_viagem          LIKE cdv_solic_viag_781.viagem,
        l_tipo_despesa_hr LIKE cdv_apont_hor_781.tdesp_apont_hor

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM cdv_apont_hor_781
  WHERE empresa           = p_cod_empresa
    AND viagem            = l_viagem
    AND tdesp_apont_hor  <> l_tipo_despesa_hr
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

 END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_verifica_empresa()
#------------------------------------#
 LET mr_apont_km.den_empresa = NULL

 WHENEVER ERROR CONTINUE
   SELECT den_empresa
     INTO mr_apont_km.den_empresa
     FROM empresa
    WHERE empresa.cod_empresa = mr_apont_km.cod_empresa
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_apont_km.den_empresa

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2000_valida_horas_not(l_ativ)
#----------------------------------------#
 DEFINE l_ativ               LIKE cdv_ativ_781.ativ,
        l_vldar_hor_noturnas CHAR(01)

 WHENEVER ERROR CONTINUE
  SELECT vldar_hor_noturnas
    INTO l_vldar_hor_noturnas
    FROM cdv_ativ_781
   WHERE ativ = l_ativ
 WHENEVER ERROR STOP

 IF sqlca.SQLCODE <> 0
 OR l_vldar_hor_noturnas IS NULL
 OR l_vldar_hor_noturnas = ' ' THEN
    LET l_vldar_hor_noturnas = "S"
 END IF

 IF l_vldar_hor_noturnas = "S" THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2000_busca_ativ(l_ativ_km)
#-------------------------------------#
 DEFINE l_ativ_km     LIKE cdv_ativ_781.ativ,
        l_den_ativ    LIKE cdv_ativ_781.des_ativ

 WHENEVER ERROR CONTINUE
 SELECT des_ativ
   INTO l_den_ativ
   FROM cdv_ativ_781
  WHERE ativ = l_ativ_km
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_den_ativ TO NULL
 END IF

 RETURN l_den_ativ[1,29]
 END FUNCTION

#------------------------------------#
 FUNCTION cdv2000_busca_hora(l_viagem)
#------------------------------------#
 DEFINE l_viagem       LIKE cdv_acer_viag_781.viagem,
        l_data_partida CHAR(19),
        l_data_retorno CHAR(19)

 WHENEVER ERROR CONTINUE
 SELECT dat_hor_partida,
        dat_hor_retorno,
        DATE(dat_hor_partida),
        DATE(dat_hor_retorno)
   INTO l_data_partida,
        l_data_retorno,
        m_data_p,
        m_data_r
   FROM cdv_acer_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_data_partida, l_data_retorno TO NULL
 END IF

 RETURN l_data_partida[12,19], l_data_retorno[12,19]
 END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2000_existe_outros_apont(l_viagem)
#---------------------------------------------#
 DEFINE l_viagem    LIKE cdv_solic_viag_781.viagem

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem
   FROM cdv_desp_urb_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem
   FROM cdv_despesa_km_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem
   FROM cdv_apont_hor_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2000_recupera_solic_acer_viag(l_viagem_origem)
#---------------------------------------------------------#
 DEFINE l_viagem_origem        LIKE cdv_solic_viag_781.viagem,
        lr_cdv_solic_viag_781  RECORD LIKE cdv_solic_viag_781.*,
        lr_cdv_acer_viag_781   RECORD LIKE cdv_acer_viag_781.*

 INITIALIZE lr_cdv_solic_viag_781.*, lr_cdv_acer_viag_781.* TO NULL

 WHENEVER ERROR CONTINUE
 SELECT empresa,           viagem,
        controle,          dat_hr_emis_solic,
        viajante,          finalidade_viagem,
        cc_viajante,       cc_debitar,
        cliente_atendido,  cliente_fatur,
        empresa_atendida,  filial_atendida,
        trajeto_principal, dat_hor_partida,
        dat_hor_retorno,   motivo_viagem
   INTO lr_cdv_solic_viag_781.empresa,           lr_cdv_solic_viag_781.viagem,
        lr_cdv_solic_viag_781.controle,          lr_cdv_solic_viag_781.dat_hr_emis_solic,
        lr_cdv_solic_viag_781.viajante,          lr_cdv_solic_viag_781.finalidade_viagem,
        lr_cdv_solic_viag_781.cc_viajante,       lr_cdv_solic_viag_781.cc_debitar,
        lr_cdv_solic_viag_781.cliente_atendido,  lr_cdv_solic_viag_781.cliente_fatur,
        lr_cdv_solic_viag_781.empresa_atendida,  lr_cdv_solic_viag_781.filial_atendida,
        lr_cdv_solic_viag_781.trajeto_principal, lr_cdv_solic_viag_781.dat_hor_partida,
        lr_cdv_solic_viag_781.dat_hor_retorno,   lr_cdv_solic_viag_781.motivo_viagem
   FROM cdv_solic_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem_origem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_SOLIC_VIAG_781")
 END IF

 WHENEVER ERROR CONTINUE
 SELECT empresa,            viagem,
        controle,           dat_hr_emis_relat,
        status_acer_viagem, viajante,
        finalidade_viagem,  cc_viajante,
        cc_debitar,         ad_acerto_conta,
        cliente_destino,    cliente_debitar,
        empresa_atendida,   filial_atendida,
        trajeto_principal,  dat_hor_partida,
        dat_hor_retorno,    motivo_viagem
   INTO lr_cdv_acer_viag_781.empresa,            lr_cdv_acer_viag_781.viagem,
        lr_cdv_acer_viag_781.controle,           lr_cdv_acer_viag_781.dat_hr_emis_relat,
        lr_cdv_acer_viag_781.status_acer_viagem, lr_cdv_acer_viag_781.viajante,
        lr_cdv_acer_viag_781.finalidade_viagem,  lr_cdv_acer_viag_781.cc_viajante,
        lr_cdv_acer_viag_781.cc_debitar,         lr_cdv_acer_viag_781.ad_acerto_conta,
        lr_cdv_acer_viag_781.cliente_destino,    lr_cdv_acer_viag_781.cliente_debitar,
        lr_cdv_acer_viag_781.empresa_atendida,   lr_cdv_acer_viag_781.filial_atendida,
        lr_cdv_acer_viag_781.trajeto_principal,  lr_cdv_acer_viag_781.dat_hor_partida,
        lr_cdv_acer_viag_781.dat_hor_retorno,    lr_cdv_acer_viag_781.motivo_viagem
   FROM cdv_acer_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem_origem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","CDV_ACER_VIAG_781")
 END IF

 RETURN lr_cdv_solic_viag_781.*, lr_cdv_acer_viag_781.*
 END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2000_procura_viagem_terc(l_viagem)
#---------------------------------------------#
 DEFINE l_viagem          LIKE cdv_solic_viag_781.viagem,
        l_viagem_corrente LIKE cdv_solic_viag_781.viagem

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem
   INTO l_viagem_corrente
   FROM cdv_desp_terc_781
  WHERE empresa       = p_cod_empresa
    AND viagem_origem = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_viagem_corrente = 0
 END IF

 IF l_viagem_corrente IS NULL THEN
    LET l_viagem_corrente = 0
 END IF

 RETURN l_viagem_corrente
 END FUNCTION


#-----------------------------------------------#
 FUNCTION cdv2000_procura_viagem_origem(l_viagem)
#-----------------------------------------------#
 DEFINE l_viagem        LIKE cdv_desp_terc_781.viagem,
        l_viagem_origem LIKE cdv_desp_terc_781.viagem_origem

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem_origem
   INTO l_viagem_origem
   FROM cdv_desp_terc_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_viagem_origem TO NULL
 END IF

 IF l_viagem_origem IS NULL THEN
    INITIALIZE l_viagem_origem TO NULL
 END IF

 RETURN l_viagem_origem
 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2000_viagem_eh_origem(l_viagem)
#------------------------------------------#
 DEFINE l_viagem    LIKE cdv_solic_viag_781.viagem

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_desp_terc_781
  WHERE empresa       = p_cod_empresa
    AND viagem_origem = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2000_eh_viagem_terc(l_viagem)
#----------------------------------------#
 DEFINE l_viagem   LIKE cdv_desp_terc_781.viagem

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE viagem
   FROM cdv_desp_terc_781
  WHERE empresa = p_cod_empresa
    AND viagem  = l_viagem
    AND viagem_origem IS NOT NULL
    AND viagem_origem <> 0
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2000_existe_dev_total(l_tot_adtos)
#---------------------------------------------#

 DEFINE l_tot_adtos             DECIMAL(17,2),
        l_tot_dev               DECIMAL(17,2)

 INITIALIZE l_tot_dev TO NULL
 WHENEVER ERROR CONTINUE
 SELECT val_devolucao
   INTO l_tot_dev
   FROM cdv_dev_transf_781
  WHERE empresa          = p_cod_empresa
    AND viagem           = mr_input.viagem
    AND eh_status_acerto = "D"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 IF l_tot_dev IS NULL THEN
    LET l_tot_dev = 0
 END IF

 IF  l_tot_adtos = 0
 AND l_tot_dev = 0 THEN
    RETURN FALSE
 END IF

 IF l_tot_adtos = l_tot_dev THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION
##OS 520395-----------------------------------------------#
 FUNCTION cdv2000_busca_des_cidade_origem(l_cidade_origem)
##--------------------------------------------------------#
  DEFINE l_cidade_origem CHAR(05)

    IF l_cidade_origem IS NOT NULL THEN
       WHENEVER ERROR CONTINUE
         SELECT den_cidade
           INTO m_des_cidade_origem
           FROM cidades
          WHERE cod_cidade = l_cidade_origem
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log0030_mensagem("Cidade origem n�o cadastrado.","exclamation")
          RETURN FALSE
       END IF
    ELSE
       LET m_des_cidade_origem = ""
    END IF

    RETURN TRUE
 END FUNCTION
#
##OS 520395-------------------------------------------------#
 FUNCTION cdv2000_busca_des_cidade_destino(l_cidade_destino)
##----------------------------------------------------------#
  DEFINE l_cidade_destino     LIKE cidades.cod_cidade

    IF l_cidade_destino IS NOT NULL THEN
       WHENEVER ERROR CONTINUE
         SELECT den_cidade
           INTO m_des_cidade_destino
           FROM cidades
          WHERE cod_cidade = l_cidade_destino
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log0030_mensagem("Cidade destino n�o cadastrado.","exclamation")
          RETURN FALSE
       END IF
     ELSE
        LET m_des_cidade_destino = ""
     END IF

     RETURN TRUE
 END FUNCTION


#--------------------------------------------------------------------#
FUNCTION cdv2000_atualiza_lote_pagto_km_semanal(l_num_ad,l_num_ap)
#--------------------------------------------------------------------#
  DEFINE l_num_ad       LIKE ad_mestre.num_ad,
         l_num_ap       LIKE ap.num_ap


  IF m_lote_pgto_km_sem IS NULL THEN
     RETURN TRUE
  END IF

  WHENEVER ERROR CONTINUE
  UPDATE ad_mestre
     SET cod_lote_pgto = m_lote_pgto_km_sem
   WHERE cod_empresa   = p_cod_empresa
     AND num_ad        = l_num_ad
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("ATUALIZACAO","ad_mestre")
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  UPDATE ap
     SET cod_lote_pgto    = m_lote_pgto_km_sem
   WHERE cod_empresa      = p_cod_empresa
     AND num_ap           = l_num_ap
     AND ies_versao_atual = 'S'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("ATUALIZACAO","ap")
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION cdv2000_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2000.4gl $|$Revision: 22 $|$Date: 23/02/2015 11:30 $|$Modtime: 22/05/11 14:00 $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)

 END FUNCTION
