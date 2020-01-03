###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTAS A PAGAR                                        #
# PROGRAMA: CDV2011                                               #
# OBJETIVO: APROVACAO DE COMPROMISSOS CDV                         #
# AUTOR...: JULIANO TEÓFILO CABRAL DA MAIA                        #
# DATA....: 06/08/2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
 DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
        p_den_empresa          LIKE empresa.den_empresa,
        p_user                 LIKE usuario.nom_usuario,
        p_status               SMALLINT,
        p_nom_arquivo          CHAR(100),
        p_cancel               INTEGER,
        sql_stmt               CHAR(500),
        g_ies_ambiente         CHAR(1),
        p_last_row             SMALLINT,
        p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

 DEFINE g_cdv0061              CHAR(01),
        g_funci_autoriz        LIKE funci.nom_funci_reduz,
        g_ambiente_logo        CHAR(03),
        pa_curr                SMALLINT,
        p_ind                  SMALLINT,
        p_user_ant             LIKE usuario.nom_usuario #necessário no cdv0066!

 DEFINE t_ad_aen ARRAY[500] OF RECORD
        val_item         LIKE ad_aen.val_item,
        cod_area_negocio LIKE ad_aen.cod_area_negocio,
        cod_lin_negocio  LIKE ad_aen.cod_lin_negocio
 END RECORD

 DEFINE t_ad_aen_4 ARRAY[500] OF RECORD
        val_aen          LIKE ad_aen_4.val_aen,
        cod_lin_prod     LIKE ad_aen_4.cod_lin_prod,
        cod_lin_recei    LIKE ad_aen_4.cod_lin_recei,
        cod_seg_merc     LIKE ad_aen_4.cod_seg_merc,
        cod_cla_uso      LIKE ad_aen_4.cod_cla_uso
 END RECORD

 DEFINE t_aen_309 ARRAY[200] OF RECORD
        val_aen              LIKE ad_aen.val_item,
        cod_area_negocio     LIKE ad_aen.cod_area_negocio,
        cod_lin_negocio      LIKE ad_aen.cod_lin_negocio
 END RECORD

 DEFINE t_aen_309_4 ARRAY[200] OF RECORD
        val_aen              LIKE ad_aen_4.val_aen,
        cod_lin_prod         LIKE ad_aen_4.cod_lin_prod,
        cod_lin_recei        LIKE ad_aen_4.cod_lin_recei,
        cod_seg_merc         LIKE ad_aen_4.cod_seg_merc,
        cod_cla_uso          LIKE ad_aen_4.cod_cla_uso
 END RECORD
 #utilizadas no cdv0066
 DEFINE l_cod_empresa        CHAR(02)
 DEFINE p_ad_mestre          RECORD LIKE ad_mestre.*

END GLOBALS

#MODULAR
 DEFINE m_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
        m_num_ad              LIKE ad_mestre.num_ad,
        m_cliente_debitar     LIKE cdv_solic_viagem.cliente_debitar,
        m_ies_aprov_eletr     CHAR(01),
        m_comando_cap         CHAR(080),
        m_ies_forma_aprov     LIKE par_cap_pad.par_ies,
        m_cod_lote_pgto_div   LIKE ap.cod_lote_pgto,
        m_comand_mail         CHAR(15),
        m_tip_desp_acer_reem  LIKE cdv_par_ctr_viagem.tip_desp_acer_cta,
        m_hosped_fat_empresa  CHAR(01),
        m_localiz_atual_bilh  CHAR(01),
        m_tip_val_bx_hosped   LIKE ap_valores.cod_tip_val,
        m_nivel_aut_oper      CHAR(02),
        m_niv_autd_agenc      CHAR(02),
        m_tip_desp_acer_cta   LIKE cdv_par_ctr_viagem.tip_desp_acer_cta,
        m_tip_desp_adto_viag  LIKE cdv_par_ctr_viagem.tip_desp_adto_viag,
        m_niv_autd_cc_debt    LIKE cdv_par_ctr_viagem.niv_autd_cc_debt,
        m_desp_solic_viagem   LIKE cdv_par_ctr_viagem.desp_solic_viagem,
        m_tip_val_tr_viag     LIKE cdv_par_ctr_viagem.tip_val_tr_viag,
        m_url_cdv_logo        CHAR(70),
        m_num_viagem          LIKE cdv_acer_viag_781.viagem,
        m_num_controle        LIKE cdv_acer_viag_781.controle,
        m_cancela_aen         SMALLINT,
        m_usu_excecao         SMALLINT,
        m_comand_cap          CHAR(150),
        m_work                SMALLINT,
        m_alterou             SMALLINT,
        m_cod_cc_apr          LIKE uni_funcional.cod_centro_custo,
        m_nom_usuario         LIKE usuarios.nom_funcionario,
        m_ies_usu_tela        LIKE par_cap_pad.par_ies,
        m_aprov               CHAR(01),
        m_ind_gao_adtos       CHAR(01),
        m_area_linha_neg      CHAR(01),
        m_ies_aen_2_4         CHAR(01),
        m_tip_desp_acer_viag  INTEGER, #490535
        m_manut_tabela        SMALLINT,
        m_processa            SMALLINT

 DEFINE mr_cdv_protocol       RECORD LIKE cdv_protocol.*

 DEFINE ma_cod_tip_despesa    ARRAY[3000] OF DECIMAL(4,0)

 DEFINE mr_relat RECORD
        nom_viajante     LIKE funcionario.nom_funcionario,
        nom_cliente      LIKE clientes.nom_cliente,
        data_partida     DATE,
        hora_partida     CHAR(05),
        data_retorno     DATE,
        hora_retorno     CHAR(05),
        des_reembolsavel CHAR(45)
  END RECORD

 DEFINE ma_reg_aprov ARRAY[3000] OF RECORD
        aprova           CHAR(01),
        cod_empresa      CHAR(02),
        viagem           INTEGER,
        controle         DECIMAL(20,0),
        valor_ad         DECIMAL(17,2),
        dat_partida      CHAR(10),
        dat_retorno      CHAR(10),
        funcionario      CHAR(30),
        cli_atendido     CHAR(20),
        finalidade       CHAR(24), #(5)
        cli_faturado     CHAR(20)
 END RECORD

 DEFINE ma_aprov ARRAY[3000] OF RECORD
        aprova           CHAR(01),
        filial           CHAR(10),
        controle         LIKE cdv_solic_viag_781.controle,
        viagem           LIKE cdv_solic_viag_781.viagem,
        viajante         LIKE funcionario.nom_funcionario,
        cc_viajante      LIKE cad_cc.cod_cent_cust,
        qtd_km           DECIMAL(13,0),
        qtd_hor          CHAR(09),
        val_desp         DECIMAL(13,2),
        val_terc         DECIMAL(13,2),
        val_adto         DECIMAL(13,2)
 END RECORD


MAIN

  CALL log0180_conecta_usuario()

  LET p_versao = "CDV2011-10.02.00" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 1200
  WHENEVER ERROR STOP

  INITIALIZE p_cod_empresa,
             p_user,
             p_status,
             m_ies_usu_tela,
             m_nom_usuario,
             ma_reg_aprov,
             ma_cod_tip_despesa,
             m_comand_cap,
             g_ambiente_logo TO NULL

  DEFER INTERRUPT

  CALL log140_procura_caminho("cdv2011.iem")
     RETURNING m_comand_cap

  OPTIONS
     FIELD ORDER UNCONSTRAINED,
     HELP FILE m_comand_cap,
     NEXT KEY control-f,
     PREVIOUS KEY control-b

  CALL log001_acessa_usuario("CDV","LOGERP;LOGLQ2")
     RETURNING p_status, p_cod_empresa, p_user

  LET l_cod_empresa = p_cod_empresa

  IF p_status = 0 THEN
     CALL cdv2011_controle()
  END IF

END MAIN

#---------------------------#
 FUNCTION cdv2011_controle()
#---------------------------#

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CALL log130_procura_caminho("CDV2011") RETURNING m_comand_cap
  OPEN WINDOW w_cdv2011 AT 2,2  WITH FORM m_comand_cap
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF NOT cdv2011_usuario_eh_aprovante_ou_substituto() THEN
     CALL log0030_mensagem("Função não permitida, usuário não é aprovante/substituto. ",'exclamation')
     CLOSE WINDOW w_cdv2011
     RETURN
  END IF

  IF NOT cdv2011_carrega_parametros() THEN
     CLOSE WINDOW w_cdv2011
     RETURN
  END IF

  CALL cdv2011_exibe_dados()
  CALL cdv2011_cria_temporarias()

  MENU "OPÇÃO"
     COMMAND "Processar"  "Efetua a aprovação viagem por viagem."
        HELP 009
        MESSAGE ""

        IF log005_seguranca(p_user,"CDV","CDV2011","MO") THEN
           CLEAR FORM
           CALL cdv2011_exibe_dados()

           IF cdv2011_entra_num_viagem() THEN

              MESSAGE 'Aguarde ... Selecionando títulos...' ATTRIBUTE(REVERSE)

              CALL cdv2011_seleciona_compr_pend_aprov(p_cod_empresa)

              MESSAGE ''

              IF cdv2011_insere_dados() THEN
                 IF cdv2011_efetiva() THEN
                    NEXT OPTION "Fim"
                 END IF
              ELSE
                 CLEAR FORM
                 CALL cdv2011_exibe_dados()
                 CALL log0030_mensagem("Aprovação de compromissos cancelada.",'exclamation')
              END IF
           ELSE
              CALL log0030_mensagem("Aprovação de compromissos cancelada.",'exclamation')
           END IF
        END IF

     COMMAND "Geral"  "Efetua a aprovação geral de viagens."
        HELP 015
        MESSAGE ""

        IF log005_seguranca(p_user,"CDV","CDV2011","MO") THEN

           IF NOT m_usu_excecao THEN
              CALL log0030_mensagem("Usuário não é exceção, utilize a função Processar.",'info')
           ELSE
              CLEAR FORM
              CALL cdv2011_exibe_dados()

              IF cdv2011_entra_num_viagem() THEN

                 MESSAGE "Aguarde ... Selecionando títulos..." ATTRIBUTE(REVERSE)

                 CALL cdv2011_seleciona_aprovacao_excecao(p_cod_empresa)

                 MESSAGE ' '

                 IF cdv2011_insere_dados() THEN
                    IF cdv2011_efetiva() THEN
                       NEXT OPTION "Fim"
                    END IF
                 ELSE
                    CLEAR FORM
                    CALL cdv2011_exibe_dados()
                    CALL log0030_mensagem("Aprovação de compromissos cancelada.",'exclamation')
                 END IF
              ELSE
                 CALL log0030_mensagem("Aprovação de compromissos cancelada.",'exclamation')
              END IF
           END IF
        END IF

     COMMAND "Aprovante Substituto"  "Chama o programa de aprovantes substitutos."
        HELP 016
        MESSAGE ""

        IF log005_seguranca(p_user,"CDV","CDV2011","MO") THEN
           CALL log120_procura_caminho("cdv0068")
              RETURNING m_comand_cap
           LET m_comand_cap = m_comand_cap CLIPPED
           RUN m_comand_cap
        END IF

     COMMAND KEY ("!")
        PROMPT "Digite o comando : " FOR m_comand_cap
        RUN m_comand_cap
        PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comand_cap

     COMMAND "Fim"        "Retorna ao menu anterior."
        HELP 008
        EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv2011

END FUNCTION

#-------------------------------#
 FUNCTION cdv2011_insere_dados()
#-------------------------------#
  DEFINE l_ies_mensagem     CHAR(01),
         l_key              SMALLINT,
         l_scr_line         SMALLINT,
         l_arr_curr         SMALLINT,
         l_ind              SMALLINT

 DEFINE l_partida1       CHAR(19),
        l_partida2       CHAR(19),
        l_partida3       CHAR(19),
        l_retorno1       CHAR(19),
        l_retorno2       CHAR(19),
        l_retorno3       CHAR(19)

  CURRENT WINDOW IS w_cdv2011

  CALL cdv2011_consulta_ordenada()
  #CALL cdv2011_valor_total()

  IF p_ind = 1 THEN
     CALL log0030_mensagem("Não existe nenhuma pendência para aprovação.",'info')
     RETURN FALSE
  END IF

  CALL log006_exibe_teclas("01 02 03 07 19", p_versao)
  CURRENT WINDOW IS w_cdv2011

  MESSAGE 'Para consultar detalhes utilize botão ZOOM.' ATTRIBUTE(REVERSE)

  --# CALL fgl_keysetlabel('control-p','Despesa')
  --# CALL fgl_keysetlabel('control-u','Km')
  --# CALL fgl_keysetlabel('control-o','Horas')
  --# CALL fgl_keysetlabel('control-t','Terceiros')
  --# CALL fgl_keysetlabel('control-n','aprovação Total')

  LET INT_FLAG = FALSE
  CALL SET_COUNT(p_ind-1)
  INPUT ARRAY ma_aprov WITHOUT DEFAULTS FROM s_array_cons.*

     BEFORE INPUT
        --# CALL fgl_dialog_setkeylabel('insert',NULL)
        --# CALL fgl_dialog_setkeylabel('delete',NULL)

     BEFORE FIELD aprova
        LET l_arr_curr = ARR_CURR()
        LET l_scr_line = SCR_LINE()

        IF ma_aprov[l_arr_curr].viagem IS NULL THEN
           LET ma_aprov[l_arr_curr].aprova = NULL
           DISPLAY ma_aprov[l_arr_curr].aprova TO s_array_cons[l_scr_line].aprova
           CURRENT WINDOW IS w_cdv2011
        END IF

        CALL cdv2011_busca_data_hora(ma_reg_aprov[l_arr_curr].cod_empresa,ma_reg_aprov[l_arr_curr].viagem,
                                     ma_reg_aprov[l_arr_curr+1].cod_empresa,ma_reg_aprov[l_arr_curr+1].viagem,
                                     ma_reg_aprov[l_arr_curr+2].cod_empresa,ma_reg_aprov[l_arr_curr+2].viagem)
                                     RETURNING l_partida1, l_retorno1,
                                               l_partida2, l_retorno2,
                                               l_partida3, l_retorno3

        IF l_partida1 IS NOT NULL
        AND l_retorno1 IS NOT NULL THEN
           LET l_partida1[1,10] = l_partida1[9,10], "/",
                                  l_partida1[6,7], "/",
                                  l_partida1[1,4]

           LET l_retorno1[1,10] = l_retorno1[9,10], "/",
                                  l_retorno1[6,7], "/",
                                  l_retorno1[1,4]

           DISPLAY "Partida: ", l_partida1 ,"    ", "Retorno: ", l_retorno1 AT 10,2 ATTRIBUTE(REVERSE)
        END IF

        IF l_partida2 IS NOT NULL
        AND l_retorno2 IS NOT NULL THEN
           LET l_partida2[1,10] = l_partida2[9,10], "/",
                                  l_partida2[6,7], "/",
                                  l_partida2[1,4]

           LET l_retorno2[1,10] = l_retorno2[9,10], "/",
                                  l_retorno2[6,7], "/",
                                  l_retorno2[1,4]

           DISPLAY "Partida: ", l_partida2 , "    ", "Retorno: ", l_retorno2 AT 15,2 ATTRIBUTE(REVERSE)
        END IF

        IF l_partida3 IS NOT NULL
        AND l_retorno3 IS NOT NULL THEN
           LET l_partida3[1,10] = l_partida3[9,10], "/",
                                  l_partida3[6,7], "/",
                                  l_partida3[1,4]

           LET l_retorno3[1,10] = l_retorno3[9,10], "/",
                                  l_retorno3[6,7], "/",
                                  l_retorno3[1,4]

           DISPLAY "Partida: ", l_partida3 , "    ", "Retorno: ", l_retorno3 AT 20,2 ATTRIBUTE(REVERSE)
        END IF

     AFTER FIELD aprova
        LET l_key = FGL_LASTKEY()
        LET l_arr_curr = ARR_CURR()
        LET l_scr_line = SCR_LINE()

        IF ma_aprov[l_arr_curr].viagem IS NULL THEN
           LET ma_aprov[l_arr_curr].aprova = NULL
           DISPLAY ma_aprov[l_arr_curr].aprova TO s_array_cons[l_scr_line].aprova
           CURRENT WINDOW IS w_cdv2011
        END IF

        LET ma_reg_aprov[l_arr_curr].aprova = ma_aprov[l_arr_curr].aprova

        IF ma_aprov[l_arr_curr + 1].aprova IS NULL THEN
           IF (l_key = FGL_KEYVAL("ACCEPT")) OR
              (l_key = FGL_KEYVAL("ESC")   ) OR
              (l_key = FGL_KEYVAL("ESCAPE")) THEN
              EXIT INPUT
           END IF
        END IF

        IF ma_aprov[l_arr_curr + 1].aprova IS NULL THEN
           IF (l_key <> FGL_KEYVAL("UP")    )  AND
              (l_key <> FGL_KEYVAL("LEFT")  ) AND
              (l_key <> FGL_KEYVAL("ACCEPT")) THEN
              ERROR "Não existem mais itens nesta direção." ATTRIBUTE(REVERSE)
              NEXT FIELD aprova
           END IF
        END IF

        IF l_arr_curr  = 1 THEN
           IF (l_key = FGL_KEYVAL("UP")    )  OR
              (l_key = FGL_KEYVAL("LEFT")  )  THEN
              ERROR "Não existem mais itens nesta direção." ATTRIBUTE(REVERSE)
              NEXT FIELD aprova
           END IF
        END IF

    ON KEY(control-w)
       CALL cdv2011_help()
       MESSAGE 'Para consultar detalhes utilize botão ZOOM.' ATTRIBUTE(REVERSE)

    ON KEY (control-z, f4)
       LET l_arr_curr = ARR_CURR()
       CALL cdv2011_zoom_ad(l_arr_curr)
       LET INT_FLAG = FALSE
       MESSAGE 'Para consultar detalhes utilize botão ZOOM.' ATTRIBUTE(REVERSE)

    ON KEY (control-p)
      MESSAGE ""
      CALL cdv2011_exibe_despesas(l_arr_curr)
      CURRENT WINDOW IS w_cdv2011

    ON KEY (control-u)
      MESSAGE ""
      CALL cdv2011_exibe_despesa_km(l_arr_curr)
      CURRENT WINDOW IS w_cdv2011

    ON KEY (control-o)
      MESSAGE ""
      CALL cdv2011_exibe_despesa_hor(l_arr_curr)
      CURRENT WINDOW IS w_cdv2011

    ON KEY (control-t)
      MESSAGE ""
      CALL cdv2011_exibe_despesa_terc(l_arr_curr)
      CURRENT WINDOW IS w_cdv2011

    ON KEY (control-n)
       FOR l_ind = 1 TO 3000
          IF ma_aprov[l_ind].viagem IS NULL THEN
             EXIT FOR
          END IF
          IF m_aprov IS  NULL THEN
             LET ma_aprov[l_ind].aprova = "S"
          ELSE
             LET ma_aprov[l_ind].aprova = "N"
          END IF
          LET ma_reg_aprov[l_ind].aprova = ma_aprov[l_ind].aprova
          IF l_ind <= 3 THEN
             DISPLAY ma_aprov[l_ind].aprova TO s_array_cons[l_ind].aprova
          END IF
       END FOR
       IF m_aprov IS  NULL THEN
          LET m_aprov = "N"
       ELSE
          LET m_aprov = NULL
       END IF

  END INPUT

  MESSAGE ""

  DISPLAY "                                                                 ", l_retorno1 AT 10,2
  DISPLAY "                                                                 ", l_retorno1 AT 15,2
  DISPLAY "                                                                 ", l_retorno1 AT 20,2

  IF INT_FLAG THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#------------------------------------#
 FUNCTION cdv2011_zoom_ad(l_arr_curr)
#------------------------------------#
  DEFINE l_arr_curr           SMALLINT,
         l_tip_desp_aux       DECIMAL(4,0),
         l_num_ad_acer_conta  LIKE ad_mestre.num_ad,
         l_num_ad             DECIMAL(6,0),
         l_fornecedor         LIKE cdv_fornecedor_fun.cod_fornecedor,
         l_ind                SMALLINT

  MENU "OPÇÃO"
    COMMAND "Aprovantes"  "Consulta aprovantes da viagem."
      HELP 010
      MESSAGE ""

      WHENEVER ERROR CONTINUE
       SELECT num_ad
         INTO l_num_ad
         FROM t_consulta_ord
        WHERE empresa    = ma_reg_aprov[l_arr_curr].cod_empresa
          AND viagem     = ma_reg_aprov[l_arr_curr].viagem
      WHENEVER ERROR CONTINUE

      IF SQLCA.SQLCODE = 0 THEN
         CALL log120_procura_caminho("cap3450") RETURNING m_comando_cap
         LET m_comando_cap = m_comando_cap CLIPPED, " ", l_num_ad,
                                            " ", ma_reg_aprov[l_arr_curr].cod_empresa,
                                            " cap0220 "
         RUN m_comando_cap
      END IF
      EXIT MENU

    COMMAND KEY ('P') "adtos Pendentes"  "Consulta adiantamentos pendentes do viajante."
      HELP 011
      MESSAGE ""

      WHENEVER ERROR CONTINUE
       SELECT empresa
         FROM t_consulta_ord
        WHERE empresa   = ma_reg_aprov[l_arr_curr].cod_empresa
          AND num_ad    = ma_reg_aprov[l_arr_curr].viagem
          AND ies_solic = "N"
      WHENEVER ERROR STOP

      IF SQLCA.SQLCODE = 0 THEN
         WHENEVER ERROR CONTINUE
          SELECT cod_fornecedor
            INTO l_fornecedor
            FROM ad_mestre
           WHERE cod_empresa = ma_reg_aprov[l_arr_curr].cod_empresa
             AND num_ad      = ma_reg_aprov[l_arr_curr].viagem
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("SELECAO","ad_mestre1")
            RETURN
         END IF
      ELSE
         WHENEVER ERROR CONTINUE
          SELECT cdv_fornecedor_fun.cod_fornecedor
            INTO l_fornecedor
            FROM cdv_fornecedor_fun, cdv_solic_viag_781, cdv_info_viajante
           WHERE cdv_solic_viag_781.viagem       = ma_reg_aprov[l_arr_curr].viagem
             AND cdv_solic_viag_781.viajante     = cdv_info_viajante.matricula
             AND cdv_info_viajante.usuario_logix = cdv_fornecedor_fun.cod_funcio
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("SELECAO","cod_fonecedor")
            RETURN
         END IF
      END IF

      IF NOT cdv0064_popup_adiant(l_fornecedor) THEN
         CALL log0030_mensagem("Não existem adiantamentos pendentes.",'info')
      END IF
      EXIT MENU

    #COMMAND KEY ('D') "Despesas"  "Consulta despesas."
    #  HELP 019
    #  MESSAGE ""
    #  CALL cdv2011_exibe_despesas(l_arr_curr)
    #  CURRENT WINDOW IS w_cdv2011
    #
    #COMMAND KEY ('K') "Km"  "Consulta despesas de Km."
    #  HELP 020
    #  MESSAGE ""
    #  CALL cdv2011_exibe_despesa_km(l_arr_curr)
    #  CURRENT WINDOW IS w_cdv2011
    #
    #COMMAND KEY ('H') "Horas"  "Consulta despesas de Horas."
    #  HELP 021
    #  MESSAGE ""
    #  CALL cdv2011_exibe_despesa_hor(l_arr_curr)
    #  CURRENT WINDOW IS w_cdv2011
    #
    #COMMAND KEY ('R') "terceiRos"  "Consulta despesas de Terceiros."
    #  HELP 022
    #  MESSAGE ""
    #  CALL cdv2011_exibe_despesa_terc(l_arr_curr)
    #  CURRENT WINDOW IS w_cdv2011

    #COMMAND KEY('T') "aprovação Total"  "Aprovação de todas as pendências."
    #  HELP 012
    #  MESSAGE ""
    #
    #  FOR l_ind = 1 TO 3000
    #     IF ma_reg_aprov[l_ind].viagem IS NULL THEN
    #        EXIT FOR
    #     END IF
    #     IF m_aprov IS  NULL THEN
    #        LET ma_reg_aprov[l_ind].aprova = "S"
    #     ELSE
    #        LET ma_reg_aprov[l_ind].aprova = "N"
    #     END IF
    #     IF l_ind <= 3 THEN
    #        DISPLAY ma_reg_aprov[l_ind].aprova TO s_array_cons[l_ind].aprova
    #     END IF
    #  END FOR
    #
    #  IF m_aprov IS  NULL THEN
    #     LET m_aprov = "N"
    #  ELSE
    #     LET m_aprov = NULL
    #  END IF
    #
    #  CURRENT WINDOW IS w_cdv2011
    #  EXIT MENU

    COMMAND "Workflow"  "Consulta workflow da viagem."
      HELP 013
      MESSAGE ""

      CALL log120_procura_caminho("CDV0057")
         RETURNING m_comand_cap
      LET m_comand_cap = m_comand_cap CLIPPED, ' ',
                         ma_reg_aprov[l_arr_curr].viagem, ' ',
                         ma_cod_tip_despesa[l_arr_curr]
      RUN m_comand_cap
      EXIT MENU

    COMMAND "Consultar"  "Consulta solicitação/acerto da viagem."
      HELP 014
      MESSAGE ""

      WHENEVER ERROR CONTINUE
      SELECT tip_desp_adto_viag
        FROM cdv_par_ctr_viagem
       WHERE empresa            = p_cod_empresa
         AND tip_desp_adto_viag = ma_cod_tip_despesa[l_arr_curr]
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 0 THEN
         CALL log120_procura_caminho("cdv2001") RETURNING m_comand_cap
         LET m_comand_cap = m_comand_cap CLIPPED, " ",
                            ma_reg_aprov[l_arr_curr].viagem, " ",
                            ma_reg_aprov[l_arr_curr].cod_empresa
      ELSE
         CALL log120_procura_caminho("cdv2000") RETURNING m_comand_cap
         LET m_comand_cap = m_comand_cap CLIPPED, " ", "CO", " ",
                            ma_reg_aprov[l_arr_curr].cod_empresa, " ",
                            ma_reg_aprov[l_arr_curr].viagem
      END IF

      RUN m_comand_cap
      EXIT MENU

    COMMAND "Fim"        "Retorna ao menu anterior."
      HELP 008
      EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU

END FUNCTION

#---------------------------------#
 FUNCTION cdv2011_grava_aprovacao()
#---------------------------------#
  DEFINE l_hora_grv          CHAR(08),
         l_qtd               SMALLINT,
         sql_stmt            CHAR(1000),
         l_ind               SMALLINT,
         l_num_ad            LIKE aprov_necessaria.num_ad,
         l_cod_nivel_autor   LIKE aprov_necessaria.cod_nivel_autor,
         l_cod_uni_funcio    LIKE aprov_necessaria.cod_uni_funcio,
         l_cod_tip_despesa   LIKE tipo_despesa.cod_tip_despesa

  DEFINE lr_aprov_necessaria    RECORD LIKE aprov_necessaria.*,
         lr_cdv_aprov_viag_781  RECORD LIKE cdv_aprov_viag_781.*

  WHENEVER ERROR CONTINUE
   DELETE FROM t_envio_email WHERE 1 =1
   DELETE FROM t_email_solic WHERE 1 = 1
   DELETE FROM t_ad_email    WHERE 1 = 1
  WHENEVER ERROR STOP

  LET m_work = TRUE

  FOR l_ind = 1 TO 3000

     IF ma_reg_aprov[l_ind].viagem IS NULL THEN
        EXIT FOR
     END IF

     IF ma_reg_aprov[l_ind].aprova <> "S" AND
        ma_reg_aprov[l_ind].aprova <> "A" THEN
        CONTINUE FOR
     END IF

     WHENEVER ERROR CONTINUE
     DECLARE cq_atual CURSOR FOR
      SELECT num_ad, cod_nivel_autor, cod_uni_funcio, cod_tip_despesa
        FROM t_consulta_ord
       WHERE empresa    = ma_reg_aprov[l_ind].cod_empresa
         AND viagem     = ma_reg_aprov[l_ind].viagem
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     FOREACH cq_atual INTO l_num_ad, l_cod_nivel_autor,
                           l_cod_uni_funcio, l_cod_tip_despesa
     WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CQ_ATUAL")
           CALL log085_transacao("ROLLBACK")
           FREE cq_atual
           EXIT PROGRAM
        END IF

        IF l_num_ad IS NOT NULL THEN
           WHENEVER ERROR CONTINUE
            DELETE FROM t_consulta_ord
             WHERE num_ad     = l_num_ad
               AND viagem     = ma_reg_aprov[l_ind].viagem
               AND empresa    = ma_reg_aprov[l_ind].cod_empresa
           WHENEVER ERROR STOP

           LET m_alterou = TRUE
           LET l_hora_grv = TIME

           INITIALIZE sql_stmt TO NULL
           LET sql_stmt = 'SELECT * FROM aprov_necessaria',
                          ' WHERE cod_empresa = "',ma_reg_aprov[l_ind].cod_empresa,'"',
                            ' AND num_ad = ',l_num_ad

           IF m_ies_forma_aprov = "2" THEN
              LET sql_stmt = sql_stmt CLIPPED,
                             ' AND cod_nivel_autor <= "',l_cod_nivel_autor,'"'
           ELSE
              LET sql_stmt = sql_stmt CLIPPED,
                             ' AND cod_nivel_autor = "',l_cod_nivel_autor,'"',
                             ' AND cod_uni_funcio  = "',l_cod_uni_funcio,'"'
           END IF

           LET sql_stmt = sql_stmt CLIPPED, ' FOR UPDATE'

           PREPARE st_atual FROM sql_stmt
           DECLARE cq_aprov_for_update1 CURSOR FOR st_atual
           OPEN cq_aprov_for_update1
           FETCH cq_aprov_for_update1 INTO lr_aprov_necessaria.*

           WHILE SQLCA.SQLCODE <> NOTFOUND
              CASE
                 WHEN SQLCA.SQLCODE = 0
                 WHEN SQLCA.SQLCODE = -250
                    CALL log0030_mensagem("Registro sendo atualizado por outro usuario.\n Aguarde e tente novamente.","exclamation")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
                 WHEN SQLCA.SQLCODE = 100
                    CALL log0030_mensagem("Registro não mais existe na tabela.\n Execute a consulta novamente.","exclamation")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
                 OTHERWISE
                    CALL log003_err_sql("LEITURA","APROV_NECESSARIA1")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
              END CASE

              LET lr_aprov_necessaria.ies_aprovado      = "S"
              LET lr_aprov_necessaria.cod_usuario_aprov = p_user
              LET lr_aprov_necessaria.dat_aprovacao     = TODAY
              LET lr_aprov_necessaria.hor_aprovacao     = l_hora_grv
              LET lr_aprov_necessaria.observ_aprovacao  = NULL

              UPDATE aprov_necessaria
                 SET aprov_necessaria.* = lr_aprov_necessaria.*
               WHERE CURRENT OF cq_aprov_for_update1

              IF SQLCA.SQLCODE <> 0 THEN
                 CALL log003_err_sql("ATUALIZACAO","APROV_NECESSARIA1")
                 LET m_work = FALSE
              END IF

              IF NOT cdv2011_grava_cdv_protocol(l_ind, l_cod_tip_despesa, l_num_ad) THEN
                 CALL log003_err_sql('INCLUSAO','cdv_protocol1')
                 LET m_work = FALSE
              END IF

              FETCH NEXT cq_aprov_for_update1 INTO lr_aprov_necessaria.*
           END WHILE

           IF NOT cdv2011_gera_email(1, l_ind, l_num_ad, l_cod_nivel_autor) THEN
               CALL log0030_mensagem('Problema no envio de e-mail.','info')
               LET m_work = FALSE
           END IF

           SELECT count(*)
             INTO l_qtd
             FROM aprov_necessaria
            WHERE ies_aprovado = "N"
              AND num_ad      = l_num_ad
              AND cod_empresa = ma_reg_aprov[l_ind].cod_empresa

           IF l_qtd = 0 THEN
              ERROR "LIBERANDO COMPROMISSO AD : ", l_num_ad,
                    " EMP : ", ma_reg_aprov[l_ind].cod_empresa

              IF NOT cdv2011_libera_compromisso(l_ind, l_num_ad, l_cod_tip_despesa) THEN
                 LET m_work = FALSE
                 EXIT FOREACH
              END IF

              CALL cdv2011_protocolo_liberacao(l_ind, l_cod_tip_despesa)
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
            DELETE FROM t_consulta_ord
             WHERE viagem  = ma_reg_aprov[l_ind].viagem
               AND empresa = ma_reg_aprov[l_ind].cod_empresa
           WHENEVER ERROR STOP

           LET m_alterou = TRUE
           LET l_hora_grv = TIME

           INITIALIZE sql_stmt TO NULL
           LET sql_stmt = 'SELECT * FROM cdv_aprov_viag_781',
                          ' WHERE empresa = "',ma_reg_aprov[l_ind].cod_empresa,'"',
                            ' AND viagem  = ',ma_reg_aprov[l_ind].viagem

           IF m_ies_forma_aprov = "2" THEN
              LET sql_stmt = sql_stmt CLIPPED,
                             ' AND nivel_autorid <= "',l_cod_nivel_autor,'"'
           ELSE
              LET sql_stmt = sql_stmt CLIPPED,
                             ' AND nivel_autorid  = "',l_cod_nivel_autor,'"',
                             ' AND unid_funcional = "',l_cod_uni_funcio,'"'
           END IF

           LET sql_stmt = sql_stmt CLIPPED, ' FOR UPDATE'

           PREPARE st_atual1 FROM sql_stmt
           DECLARE cq_aprov_for_update2 CURSOR FOR st_atual1
           OPEN cq_aprov_for_update2
           FETCH cq_aprov_for_update2 INTO lr_cdv_aprov_viag_781.*

           WHILE SQLCA.SQLCODE <> NOTFOUND
              CASE
                 WHEN SQLCA.SQLCODE = 0
                 WHEN SQLCA.SQLCODE = -250
                    CALL log0030_mensagem("Registro sendo atualizado por outro usuario.\n Aguarde e tente novamente.","exclamation")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
                 WHEN SQLCA.SQLCODE = 100
                    CALL log0030_mensagem("Registro não mais existe na tabela.\n Execute a consulta novamente.","exclamation")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
                 OTHERWISE
                    CALL log003_err_sql("LEITURA","cdv_aprov_viag_781")
                    CALL log085_transacao("ROLLBACK")
                    FREE cq_atual
                    EXIT PROGRAM
              END CASE

              LET lr_cdv_aprov_viag_781.eh_aprovado       = "S"
              LET lr_cdv_aprov_viag_781.usuario_aprovacao = p_user
              LET lr_cdv_aprov_viag_781.dat_aprovacao     = TODAY
              LET lr_cdv_aprov_viag_781.hor_aprovacao     = l_hora_grv
              LET lr_cdv_aprov_viag_781.obs_aprovacao     = NULL

              WHENEVER ERROR CONTINUE
              UPDATE cdv_aprov_viag_781
                 SET cdv_aprov_viag_781.* = lr_cdv_aprov_viag_781.*
               WHERE CURRENT OF cq_aprov_for_update2
              WHENEVER ERROR STOP

              IF SQLCA.SQLCODE <> 0 THEN
                 CALL log003_err_sql("ATUALIZACAO","CDV_APROV_VIAG_781")
                 LET m_work = FALSE
              END IF

              IF NOT cdv2011_grava_cdv_protocol(l_ind, l_cod_tip_despesa, l_num_ad) THEN
                 CALL log003_err_sql('INCLUSAO','cdv_protocol1')
                 LET m_work = FALSE
              END IF

              FETCH NEXT cq_aprov_for_update2 INTO lr_cdv_aprov_viag_781.*
           END WHILE

           IF NOT cdv2011_gera_email_viag(1, l_ind, l_cod_nivel_autor) THEN
               CALL log0030_mensagem('Problema no envio de e-mail.','info')
               LET m_work = FALSE
           END IF

           WHENEVER ERROR CONTINUE
           SELECT count(*)
             INTO l_qtd
             FROM cdv_aprov_viag_781
            WHERE eh_aprovado = "N"
              AND viagem      = ma_reg_aprov[l_ind].viagem
              AND empresa     = ma_reg_aprov[l_ind].cod_empresa
           WHENEVER ERROR STOP

           IF l_qtd = 0 THEN
              ERROR "LIBERANDO COMPROMISSO VIAGEM : ", ma_reg_aprov[l_ind].viagem,
                    " EMP : ", ma_reg_aprov[l_ind].cod_empresa

              CALL cdv2011_protocolo_liberacao(l_ind, l_cod_tip_despesa)
           END IF
        END IF

      END FOREACH
      FREE cq_atual
  END FOR

  IF m_alterou THEN
     IF m_work THEN
        RETURN TRUE
     ELSE
        RETURN FALSE
     END IF
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION cdv2011_libera_compromisso(l_ind, l_num_ad, l_cod_tip_despesa)
#-----------------------------------------------------------------------#

  DEFINE lr_ad_ap               RECORD LIKE ad_ap.*

  DEFINE l_ies_quando_contab     LIKE tipo_despesa.ies_quando_contab,
         l_num_seq               INTEGER,
         l_cont                  SMALLINT,
         x_empresa               LIKE empresa.cod_empresa,
         l_val_adto_viagem       LIKE cdv_adto_viagem.val_adto_viagem,
         l_aux_ssr_nf            LIKE ad_mestre.ssr_nf,
         l_aux_cod_fornecedor    LIKE ad_mestre.cod_fornecedor,
         l_aux_observ            LIKE ad_mestre.observ,
         l_aux_ies_dep_cred      LIKE ad_mestre.ies_dep_cred,
         l_aux_banco             LIKE cdv_adto_viagem.banco,
         l_aux_agencia           LIKE cdv_adto_viagem.agencia,
         l_aux_conta             LIKE cdv_adto_viagem.cta_corrente,
         l_work                  SMALLINT,
         l_msg                   CHAR(100),
         l_num_ap                LIKE ap.num_ap,
         l_num_viagem            LIKE cdv_adto_viagem.num_viagem,
         l_cod_lote_pgto         LIKE ap.cod_lote_pgto,
         l_dat_vencto_s_desc     LIKE ap.dat_vencto_s_desc,
         l_dat_atualizada        LIKE ap.dat_vencto_s_desc,
         l_cod_fornecedor        LIKE ad_mestre.cod_fornecedor,
         l_valor_liq_alt         LIKE ap.val_nom_ap,
         l_data_util_ret         DATE,
         l_ind                   SMALLINT,
         l_num_ad                LIKE ad_mestre.num_ad,
         l_cod_tip_despesa       LIKE tipo_despesa.cod_tip_despesa,
         l_num_conta_cont        CHAR(10),
         l_val_lanc              DECIMAL(15,2),
         l_cod_lin_prod          LIKE ad_aen_4.cod_lin_prod,
         l_cod_lin_recei         LIKE ad_aen_4.cod_lin_recei,
         l_cod_seg_merc          LIKE ad_aen_4.cod_seg_merc,
         l_cod_cla_uso           LIKE ad_aen_4.cod_cla_uso,
         l_valor                 DECIMAL(15,2),
         l_valor_gao             DECIMAL(15,2),
         l_status                SMALLINT,
         l_gao_despesas_reemb    CHAR(01)

  CALL log2250_busca_parametro(p_cod_empresa,'gao_despesas_reemb')
     RETURNING l_gao_despesas_reemb, l_status
  IF NOT l_status THEN
     LET m_work = FALSE
     RETURN
  END IF
  IF l_gao_despesas_reemb IS NULL THEN
     LET l_gao_despesas_reemb = 'N'
  END IF

  UPDATE ad_mestre
     SET ies_sup_cap = "C",
         dat_rec_nf  = TODAY
   WHERE num_ad      = l_num_ad
     AND cod_empresa = ma_reg_aprov[l_ind].cod_empresa

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("MODIFICACAO","AD_MESTRE")
     LET m_work = FALSE
  END IF

  LET l_cont = 0
  SELECT COUNT(*)
    INTO l_cont
    FROM benefic_dirf
   WHERE benefic_dirf.cod_empresa = ma_reg_aprov[l_ind].cod_empresa
     AND benefic_dirf.num_ad_ap_orig   = l_num_ad
     AND benefic_dirf.ies_ad_ap_orig   = "1"
     AND benefic_dirf.num_matricula    IS NULL

  IF SQLCA.SQLCODE = 0 AND l_cont > 0 THEN
     CALL cap371_verifica_data_util_imposto(TODAY,ma_reg_aprov[l_ind].cod_empresa, "R","")
        RETURNING l_data_util_ret

     WHENEVER ERROR CONTINUE
      UPDATE benefic_dirf
         SET dat_ocorrencia = TODAY,
             dat_venc_irrf = l_data_util_ret
       WHERE benefic_dirf.cod_empresa    = ma_reg_aprov[l_ind].cod_empresa
         AND benefic_dirf.num_ad_ap_orig = l_num_ad
         AND benefic_dirf.ies_ad_ap_orig = "1"
         AND benefic_dirf.num_matricula  IS NULL
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql("MODIFICACAO","BENEFIC_DIRF")
        LET m_work = FALSE
     END IF
  END IF

  LET l_cont = 0
  SELECT COUNT(*)
    INTO l_cont
    FROM ad_ap
   WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
     AND num_ad      = l_num_ad

  IF l_cont <> 0 THEN

     DECLARE cq_ad_ap CURSOR FOR
      SELECT *
        FROM ad_ap
       WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
         AND num_ad      = l_num_ad

     FOREACH cq_ad_ap INTO lr_ad_ap.*

        SELECT dat_vencto_s_desc
          INTO l_dat_vencto_s_desc
          FROM ap
         WHERE num_ap           = lr_ad_ap.num_ap
           AND cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
           AND ies_versao_atual =  "S"

        IF l_dat_vencto_s_desc IS NOT NULL THEN
           LET l_dat_atualizada = cdv2011_verifica_dia_util(l_ind)
        END IF

        IF l_dat_atualizada IS NULL THEN
           LET l_dat_atualizada = l_dat_vencto_s_desc
        END IF

        UPDATE ap
           SET ies_lib_pgto_cap  = "N",
               dat_vencto_s_desc = l_dat_atualizada,
               dat_proposta      = l_dat_atualizada
         WHERE num_ap           = lr_ad_ap.num_ap
           AND cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
           AND ies_versao_atual =  "S"

        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","AP")
           LET m_work = FALSE
        END IF

        CALL cdv2011_calcula_val_liquido(ma_reg_aprov[l_ind].cod_empresa, lr_ad_ap.num_ap)
           RETURNING l_valor_liq_alt

        IF l_valor_liq_alt = 0  THEN
           UPDATE ap
              SET ies_lib_pgto_cap  = "S"
            WHERE num_ap           = lr_ad_ap.num_ap
              AND cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
              AND ies_versao_atual =  "S"

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","AP ZERADA")
               LET m_work = FALSE
            END IF
        END IF
     END FOREACH
  ELSE
     CALL cdv2011_libera_ad_fatura(l_ind, l_num_ad)
  END IF

  SELECT ies_quando_contab
    INTO l_ies_quando_contab
    FROM tipo_despesa
   WHERE cod_empresa     = ma_reg_aprov[l_ind].cod_empresa
     AND cod_tip_despesa = l_cod_tip_despesa

  IF l_ies_quando_contab = "C" THEN
     WHENEVER ERROR CONTINUE
       UPDATE lanc_cont_cap
          SET ies_liberad_contab = "S",
              dat_lanc = TODAY
        WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
          AND num_ad_ap   = l_num_ad
          AND ies_ad_ap   = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("MODIFICACAO","LANC_CONT_CAP")
        LET m_work = FALSE
     END IF

     CALL capr16_manutencao_ctb_lanc_ctbl_cap("M", ma_reg_aprov[l_ind].cod_empresa, l_num_ad, 1, NULL )
        RETURNING m_manut_tabela, m_processa

     IF m_manut_tabela AND m_processa THEN
        WHENEVER ERROR CONTINUE
          UPDATE ctb_lanc_ctbl_cap
             SET ctb_lanc_ctbl_cap.liberado        = "S",
                 ctb_lanc_ctbl_cap.dat_movto       = TODAY
           WHERE ctb_lanc_ctbl_cap.empresa         = ma_reg_aprov[l_ind].cod_empresa
             AND ctb_lanc_ctbl_cap.num_ad_ap       = l_num_ad
             AND ctb_lanc_ctbl_cap.eh_ad_ap        = "1"
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","LANC_CONT_CAP")
           LET m_work = FALSE
        END IF
     ELSE
        IF NOT m_processa THEN
           LET m_work = FALSE
        END IF
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
       UPDATE lanc_cont_cap
          SET dat_lanc = TODAY
        WHERE lanc_cont_cap.cod_empresa = ma_reg_aprov[l_ind].cod_empresa
          AND lanc_cont_cap.num_ad_ap   = l_num_ad
          AND lanc_cont_cap.ies_ad_ap   = "1"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("MODIFICACAO","LANC_CONT_CAP")
        LET m_work = FALSE
     END IF

     CALL capr16_manutencao_ctb_lanc_ctbl_cap("M", ma_reg_aprov[l_ind].cod_empresa, l_num_ad, 1, NULL )
        RETURNING m_manut_tabela, m_processa

     IF m_manut_tabela AND m_processa THEN
        WHENEVER ERROR CONTINUE
          UPDATE ctb_lanc_ctbl_cap
             SET ctb_lanc_ctbl_cap.dat_movto       = TODAY
           WHERE ctb_lanc_ctbl_cap.empresa         = ma_reg_aprov[l_ind].cod_empresa
             AND ctb_lanc_ctbl_cap.num_ad_ap       = l_num_ad
             AND ctb_lanc_ctbl_cap.eh_ad_ap        = "1"
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","LANC_CONT_CAP")
           LET m_work = FALSE
        END IF
     ELSE
        IF NOT m_processa THEN
           LET m_work = FALSE
        END IF
     END IF
  END IF

  SELECT cod_fornecedor
    INTO l_cod_fornecedor
    FROM ad_mestre
   WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
     AND num_ad      = l_num_ad

  UPDATE adiant
     SET dat_ref = TODAY
   WHERE cod_empresa    = ma_reg_aprov[l_ind].cod_empresa
     AND cod_fornecedor = l_cod_fornecedor
     AND num_ad_nf_orig = l_num_ad

  IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("MODIFICACAO","ADIANT")
      LET m_work = FALSE
  END IF

  UPDATE mov_adiant
     SET dat_mov = TODAY
   WHERE cod_empresa    = ma_reg_aprov[l_ind].cod_empresa
     AND cod_fornecedor = l_cod_fornecedor
     AND num_ad_nf_orig = l_num_ad
     AND ies_ent_bx     = "E"

  IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("MODIFICACAO","MOV_ADIANT")
      LET m_work = FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2011_cria_aprov_necessaria(l_num_viagem)
#---------------------------------------------------#
 DEFINE p_status        SMALLINT,
        l_usuario_logix LIKE cdv_info_viajante.usuario_logix,
        l_num_viagem    LIKE cdv_solic_viag_781.viagem

 LET p_user_ant = p_user

 SELECT usuario_logix
   INTO l_usuario_logix
   FROM cdv_info_viajante
  WHERE empresa   = p_cod_empresa
    AND matricula = m_matricula_viajante

 IF SQLCA.SQLCODE <> 0 THEN
     LET l_usuario_logix = p_user
 END IF

 LET p_user    = l_usuario_logix
 LET g_cdv0061 = 'S'

 ERROR  " Enviando solicitação de adto para aprov. eletrônica... " ATTRIBUTE(REVERSE)
 SLEEP 1

 CALL cdv0066_envia_email_aprov_eletronica(TRUE, "cdv", "S", l_num_viagem)
   RETURNING p_status

 IF p_status THEN
    CALL log0030_mensagem("Problema envio solicitação para aprov. eletrônica 1.",'exclamation')
 END IF

 CALL cdv0066_envia_email_aprov_eletronica(FALSE, "cdv","S", l_num_viagem)
   RETURNING p_status

 IF p_status THEN
    CALL log0030_mensagem("Problema envio solicitação para aprov. eletrônica.",'exclamation')
    LET m_work = FALSE
 END IF

 LET p_user = p_user_ant

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2011_retorna_fornec(l_matricula_viajante)
#-----------------------------------------------------#
  DEFINE l_cod_fornecedor     LIKE ad_mestre.cod_fornecedor
  DEFINE l_cod_funcio         LIKE cdv_fornecedor_fun.cod_funcio
  DEFINE l_matricula_viajante LIKE cdv_info_viajante.matricula

  INITIALIZE l_cod_fornecedor,
             l_cod_funcio  TO NULL

  LET l_cod_funcio = l_matricula_viajante
  WHENEVER ERROR CONTINUE
   SELECT cod_fornecedor
     INTO l_cod_fornecedor
     FROM cdv_fornecedor_fun
    WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     IF SQLCA.SQLCODE = 100 THEN
        CALL log0030_mensagem("Viajante não cadastrado. ",'exclamation')
     ELSE
        CALL log003_err_sql('SELECAO','cdv_cdv_fornecedor_fun_viajante')
     END IF
  END IF

  RETURN l_cod_fornecedor

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2011_retorna_num_ssr_nf(l_tip_adto, l_num_viagem)
#-------------------------------------------------------------#

 DEFINE l_ssr_nf      LIKE ad_mestre.ssr_nf,
        l_tip_adto    CHAR(01),
        l_num_viagem  LIKE cdv_adto_viagem.num_viagem,
        l_num_nf      LIKE ad_mestre.num_nf

 LET l_ssr_nf = 0
 LET l_num_nf = l_num_viagem

 WHENEVER ERROR CONTINUE
  SELECT MAX(ssr_nf)
    INTO l_ssr_nf
    FROM ad_mestre
   WHERE cod_empresa     = p_cod_empresa
     AND cod_tip_despesa = m_tip_desp_adto_viag
     AND num_nf          = l_num_nf
     AND ser_nf          = l_tip_adto
  WHENEVER ERROR STOP

  IF l_ssr_nf <> 0 AND l_ssr_nf IS NOT NULL THEN
     LET l_ssr_nf = l_ssr_nf + 1
  ELSE
     LET l_ssr_nf = 1
  END IF

  RETURN l_ssr_nf

END FUNCTION

#--------------------------------------------------#
FUNCTION cdv2011_libera_ad_fatura(l_ind, l_num_ad)
#--------------------------------------------------#
  DEFINE l_num_adf           LIKE adn_adf.num_adf,
         l_num_adn           LIKE adn_adf.num_adn,
         l_achou             SMALLINT,
         l_num_ap_lib        LIKE ap.num_ap,
         l_dat_vencto_s_desc LIKE ap.dat_vencto_s_desc,
         l_dat_atualizada    LIKE ap.dat_vencto_s_desc,
         l_ind               SMALLINT,
         l_num_ad            LIKE ad_mestre.num_ad

  LET l_achou = FALSE

  SELECT num_adf
    INTO l_num_adf
    FROM adn_adf
   WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
     AND num_adn     = l_num_ad

  IF SQLCA.SQLCODE = 0 THEN

     DECLARE cq_adn_adf CURSOR FOR
      SELECT num_adn
        FROM adn_adf
       WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
         AND num_adf     = l_num_adf

     FOREACH cq_adn_adf INTO l_num_adn

        SELECT * FROM ad_mestre
         WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
           AND num_ad      = l_num_adn
           AND ies_sup_cap = "Q"

        IF SQLCA.SQLCODE = 0 THEN
           LET l_achou = TRUE
           EXIT FOREACH
        END IF

     END FOREACH

     IF l_achou = FALSE THEN
        DECLARE cq_ad_ap_lib CURSOR FOR
         SELECT num_ap
           FROM ad_ap
          WHERE cod_empresa = ma_reg_aprov[l_ind].cod_empresa
            AND num_ad      = l_num_adf

        FOREACH cq_ad_ap_lib INTO l_num_ap_lib

           SELECT dat_vencto_s_desc
             INTO l_dat_vencto_s_desc
             FROM ap
            WHERE num_ap           = l_num_ap_lib
              AND cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
              AND ies_versao_atual =  "S"

           IF l_dat_vencto_s_desc IS NOT NULL THEN
              LET l_dat_atualizada = cdv2011_verifica_dia_util(l_ind)
           END IF

           IF l_dat_atualizada IS NULL THEN
              LET l_dat_atualizada = l_dat_vencto_s_desc
           END IF

           UPDATE ap
              SET ies_lib_pgto_cap  = "N",
                  dat_vencto_s_desc = l_dat_atualizada,
                  dat_proposta      = l_dat_atualizada
            WHERE num_ap            = l_num_ap_lib
              AND cod_empresa       = ma_reg_aprov[l_ind].cod_empresa
              AND ies_versao_atual  =  "S"

           IF SQLCA.SQLCODE <> 0 THEN
              CALL log003_err_sql("MODIFICACAO","AP")
              LET m_work = FALSE
           END IF
        END FOREACH
     END IF
  END IF

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2011_usuario_eh_aprovante_ou_substituto()
#----------------------------------------------------#
  DEFINE l_conta_aprov, l_conta_subs  INTEGER

  LET l_conta_aprov = 0
  LET l_conta_subs  = 0

  SELECT COUNT(*)
    INTO l_conta_aprov
    FROM usu_nivel_aut_cap
   WHERE cod_usuario        = p_user
     AND ies_ativo          = 'S'
     AND ies_versao_atual   = 'S'

  IF l_conta_aprov IS NULL THEN
     LET l_conta_aprov = 0
  END IF

  IF l_conta_aprov = 0 THEN
     SELECT COUNT(*)
       INTO l_conta_subs
       FROM usuario_subs_cap
      WHERE cod_usuario_subs = p_user
     IF l_conta_subs IS NULL THEN
        LET l_conta_subs = 0
     END IF
     IF l_conta_subs = 0 THEN
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION cdv2011_efetiva()
#--------------------------#
  DEFINE l_num_ad     LIKE ad_mestre.num_ad,
         l_num_viagem LIKE cdv_solic_viag_781.viagem,
         l_val_adto   LIKE cdv_adto_viagem.val_adto_viagem,
         l_ind        SMALLINT,
         l_ha_regs    SMALLINT,
         l_cont       SMALLINT

  CALL log085_transacao("BEGIN")

  LET l_ha_regs = FALSE
  FOR l_ind = 1 TO 3000
     IF ma_reg_aprov[l_ind].cod_empresa IS NULL THEN
        EXIT FOR
     END IF
     IF ma_reg_aprov[l_ind].aprova = "S" OR ma_reg_aprov[l_ind].aprova = "A" THEN
        LET l_ha_regs = TRUE
        EXIT FOR
     END IF
  END FOR

  IF NOT l_ha_regs THEN
     MESSAGE "Nenhuma pendência de aprovação foi selecionada."
     CALL log085_transacao("ROLLBACK")
     RETURN FALSE
  END IF

  IF log004_confirm(17,40) = TRUE THEN
     CURRENT WINDOW IS w_cdv2011
     CLEAR FORM

      DISPLAY " " at 10,01
      DISPLAY " " at 13,01
      DISPLAY " " at 16,01
      DISPLAY " " at 19,01

     CALL cdv2011_exibe_dados()

     IF cdv2011_grava_aprovacao() THEN

        CALL cdv2011_consulta_ordenada()
        #CALL cdv2011_valor_total()

        DECLARE cq_ad_email CURSOR FOR
         SELECT *
           FROM t_ad_email
          ORDER BY num_ad

        FOREACH cq_ad_email INTO l_num_ad, l_num_viagem, l_val_adto
           IF l_val_adto > 0 THEN
              CALL cdv0066_envia_email(l_num_ad, 'V', l_num_viagem, l_val_adto)
           ELSE
              CALL cdv0066_envia_email(l_num_ad, 'A', l_num_viagem, 0)
           END IF
        END FOREACH

        CALL cdv2011_envia_email_solic()

        CALL log085_transacao("COMMIT")
        CALL log0030_mensagem("Aprovação de compromissos efetuada com sucesso. ",'exclamation')

        RETURN TRUE
     ELSE
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
     END IF
  ELSE
     CALL log085_transacao("ROLLBACK")
     ERROR "Processamento cancelado. "
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION cdv2011_grava_cdv_protocol(l_ind, l_cod_tip_despesa, l_num_ad)
#-----------------------------------------------------------------------#
  DEFINE l_sequencia_protocol     LIKE cdv_protocol.sequencia_protocol
  DEFINE l_cod_usuario            CHAR(08)
  DEFINE l_matricula              LIKE cdv_info_viajante.matricula
  DEFINE l_protocolo              RECORD LIKE cdv_protocol.*
  DEFINE l_ind                    SMALLINT,
         l_cod_tip_despesa        LIKE tipo_despesa.cod_tip_despesa,
         l_num_ad                 LIKE ad_mestre.num_ad,
         l_ind_for                SMALLINT

  {490535
   IF (l_cod_tip_despesa <> m_tip_desp_acer_cta) AND
     (l_cod_tip_despesa <> m_tip_desp_acer_reem) THEN
     RETURN TRUE
  END IF
  }

  #490535
  IF (l_cod_tip_despesa <> m_tip_desp_acer_viag) THEN
     RETURN TRUE
  END IF

  FOR l_ind_for = 1 TO 2

     LET l_protocolo.empresa              = p_cod_empresa
     LET l_protocolo.num_viagem           = ma_reg_aprov[l_ind].viagem
     LET l_protocolo.sequencia_protocol   = 0
     LET l_protocolo.dat_hor_env_recb     = log0300_current(g_ies_ambiente)

     IF l_ind_for = 1  THEN
        LET l_protocolo.status_protocol = "1"

        WHENEVER ERROR CONTINUE
        SELECT matricula
          INTO l_matricula
          FROM cdv_info_viajante
         WHERE usuario_logix = p_user
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
           LET l_matricula = " "
        END IF

        LET l_protocolo.matr_dest_protocol   = l_matricula
        LET l_protocolo.obs_protocol         = "PROTOCOLO RECEBIDO"
     ELSE
        LET l_protocolo.status_protocol  = "2"
        LET l_cod_usuario                = cdv0065_busca_usuario(p_cod_empresa,l_num_ad,"CDV2011")

        IF l_cod_usuario IS NULL  THEN
           RETURN TRUE
        END IF

        WHENEVER ERROR CONTINUE
        SELECT matricula
          INTO l_matricula
          FROM cdv_info_viajante
         WHERE usuario_logix = l_cod_usuario
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
           LET l_matricula = " "
        END IF

        LET l_protocolo.matr_dest_protocol = l_matricula
        LET l_protocolo.obs_protocol       = "PROTOCOLO ENVIADO"
     END IF

     WHENEVER ERROR CONTINUE
      SELECT viajante
        INTO l_matricula
        FROM cdv_acer_viag_781
       WHERE empresa = p_cod_empresa
         AND viagem  = ma_reg_aprov[l_ind].viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0  THEN
         LET l_matricula = NULL
     END IF

     LET l_protocolo.matr_receb_docum     = l_matricula
     LET l_protocolo.usuario_remetent     = p_user
     LET l_protocolo.dat_hor_remetent     = log0300_current(g_ies_ambiente)
     LET l_protocolo.num_protocol         = l_cod_tip_despesa
     LET l_protocolo.dat_hor_despacho     = log0300_current(g_ies_ambiente)

     WHENEVER ERROR CONTINUE
     INSERT INTO cdv_protocol ( empresa, num_viagem, dat_hor_env_recb, status_protocol, matr_receb_docum, matr_dest_protocol, obs_protocol, usuario_remetent, dat_hor_remetent, num_protocol, dat_hor_despacho )  VALUES ( l_protocolo.empresa, l_protocolo.num_viagem, l_protocolo.dat_hor_env_recb, l_protocolo.status_protocol, l_protocolo.matr_receb_docum, l_protocolo.matr_dest_protocol, l_protocolo.obs_protocol, l_protocolo.usuario_remetent, l_protocolo.dat_hor_remetent, l_protocolo.num_protocol, l_protocolo.dat_hor_despacho)
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE = 0 THEN
        IF l_ind_for = 2  THEN
            RETURN TRUE
        END IF
     ELSE
        RETURN FALSE
     END IF

  END FOR

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2011_calcula_val_liquido(l_cod_empresa, l_num_ap)
#-------------------------------------------------------------#
  DEFINE l_cod_empresa     LIKE empresa.cod_empresa,
         l_num_ap          LIKE ap.num_ap,
         l_val_nom_ap      LIKE ap.val_nom_ap,
         l_num_versao      LIKE ap.num_versao,
         l_ies_alt_val_pag LIKE tipo_valor.ies_alt_val_pag,
         l_valor           LIKE ap_valores.valor

  WHENEVER ERROR CONTINUE
   SELECT val_nom_ap, num_versao
     INTO l_val_nom_ap, l_num_versao
     FROM ap
    WHERE cod_empresa      = l_cod_empresa
      AND num_ap           = l_num_ap
      AND ies_versao_atual = 'S'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELEÇÃO','ap')
     RETURN 0
  END IF

  DECLARE c_mostra_liq_1 CURSOR FOR
   SELECT ies_alt_val_pag, valor
     FROM tipo_valor, ap_valores
    WHERE ap_valores.cod_empresa      = l_cod_empresa
      AND ap_valores.num_ap           = l_num_ap
      AND ap_valores.num_versao       = l_num_versao
      AND ap_valores.ies_versao_atual = 'S'
      AND ap_valores.cod_tip_val      = tipo_valor.cod_tip_val
      AND ap_valores.cod_empresa      = tipo_valor.cod_empresa

  FOREACH c_mostra_liq_1 INTO l_ies_alt_val_pag, l_valor

     IF l_ies_alt_val_pag = "+" THEN
        LET l_val_nom_ap = l_val_nom_ap + l_valor
     ELSE
        IF l_ies_alt_val_pag = "-" THEN
           LET l_val_nom_ap = l_val_nom_ap - l_valor
        END IF
     END IF

  END FOREACH

  RETURN l_val_nom_ap

 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2011_verifica_dia_util(l_ind)
#----------------------------------------#

  DEFINE l_ind               SMALLINT,
         l_dat_vencto_s_desc LIKE ap.dat_vencto_s_desc


   WHENEVER ERROR CONTINUE
     SELECT DATE(dat_hr_emis_solic)
       INTO l_dat_vencto_s_desc
       FROM cdv_solic_viag_781
      WHERE empresa = ma_reg_aprov[l_ind].cod_empresa
        AND viagem  = ma_reg_aprov[l_ind].viagem
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
   END IF

   RETURN l_dat_vencto_s_desc

  {DEFINE l_dat_vencto_s_desc  LIKE ap.dat_vencto_s_desc,
         l_dia_semana         SMALLINT,
         l_ja_calc_feriado    SMALLINT,
         l_ies_dia_util_banc  LIKE calendario.ies_dia_util_banc,
         l_ind                SMALLINT

  LET l_dia_semana = WEEKDAY(l_dat_vencto_s_desc)

  CASE l_dia_semana
      WHEN 5
          LET l_dat_vencto_s_desc = l_dat_vencto_s_desc + 3 UNITS DAY
      WHEN 6
          LET l_dat_vencto_s_desc = l_dat_vencto_s_desc + 2 UNITS DAY
      OTHERWISE
          LET l_dat_vencto_s_desc = l_dat_vencto_s_desc + 1 UNITS DAY
  END CASE

  WHILE TRUE

     SELECT ies_dia_util_banc
       INTO l_ies_dia_util_banc
       FROM calendario
      WHERE dat_calend = l_dat_vencto_s_desc

     IF SQLCA.SQLCODE <> 0 OR
       (SQLCA.SQLCODE =  0 AND l_ies_dia_util_banc = "N") THEN
         EXIT WHILE
     END IF

     LET l_dat_vencto_s_desc = l_dat_vencto_s_desc + 1 UNITS DAY

  END WHILE

  RETURN l_dat_vencto_s_desc}

END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2011_protocolo_liberacao(l_ind, l_cod_tip_despesa)
#--------------------------------------------------------------#
  DEFINE l_matricula_aprovador  LIKE cdv_info_viajante.matricula,
         l_sequencia_protocol   LIKE cdv_protocol.sequencia_protocol,
         l_matricula_viajante   LIKE cdv_solic_viagem.matricula_viajante,
         l_usuario_viajante     LIKE cdv_info_viajante.usuario_logix,
         l_email                LIKE usuarios.e_mail,
         l_ind                  SMALLINT,
         l_cod_tip_despesa      LIKE tipo_despesa.cod_tip_despesa

  IF (l_cod_tip_despesa = m_tip_desp_acer_cta) OR
     (l_cod_tip_despesa = m_tip_desp_acer_reem) THEN
      RETURN
  END IF

  SELECT matricula
    INTO l_matricula_aprovador
    FROM cdv_info_viajante
   WHERE empresa       = p_cod_empresa
     AND usuario_logix = p_user

  IF SQLCA.SQLCODE <> 0 THEN
      LET l_matricula_aprovador = NULL
  END IF

  WHENEVER ERROR CONTINUE
   SELECT viajante
     INTO l_matricula_viajante
     FROM cdv_solic_viag_781
    WHERE empresa  = p_cod_empresa
      AND viagem   = ma_reg_aprov[l_ind].viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_matricula_viajante = NULL
  END IF

  LET mr_cdv_protocol.empresa            = p_cod_empresa
  LET mr_cdv_protocol.num_viagem         = ma_reg_aprov[l_ind].viagem
  LET mr_cdv_protocol.sequencia_protocol = 0
  LET mr_cdv_protocol.dat_hor_env_recb   = log0300_current(g_ies_ambiente) #Rafael - OS317282
  LET mr_cdv_protocol.status_protocol    = 6 # Solicitacao aprovada
  LET mr_cdv_protocol.matr_receb_docum   = l_matricula_viajante
  LET mr_cdv_protocol.matr_dest_protocol = l_matricula_aprovador
  LET mr_cdv_protocol.obs_protocol       = 'APROVADO'
  LET mr_cdv_protocol.usuario_remetent   = p_user
  LET mr_cdv_protocol.dat_hor_remetent   = log0300_current(g_ies_ambiente) #Rafael - OS317282
  LET mr_cdv_protocol.num_protocol       = l_cod_tip_despesa
  LET mr_cdv_protocol.dat_hor_despacho   = log0300_current(g_ies_ambiente) #Rafael - OS317282

  WHENEVER ERROR CONTINUE
  INSERT INTO cdv_protocol ( empresa, num_viagem, dat_hor_env_recb, status_protocol, matr_receb_docum, matr_dest_protocol, obs_protocol, usuario_remetent, dat_hor_remetent, num_protocol, dat_hor_despacho )  VALUES ( mr_cdv_protocol.empresa, mr_cdv_protocol.num_viagem, mr_cdv_protocol.dat_hor_env_recb, mr_cdv_protocol.status_protocol, mr_cdv_protocol.matr_receb_docum, mr_cdv_protocol.matr_dest_protocol, mr_cdv_protocol.obs_protocol, mr_cdv_protocol.usuario_remetent, mr_cdv_protocol.dat_hor_remetent, mr_cdv_protocol.num_protocol, mr_cdv_protocol.dat_hor_despacho)
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql("INCLUSAO", "cdv_protocol")
      LET m_work   = FALSE
      RETURN
  END IF

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION cdv2011_gera_email(l_funcao, l_ind, l_num_ad, l_cod_nivel_autor)
#-------------------------------------------------------------------------#
  DEFINE l_funcao              SMALLINT,
         l_min_nivel_autor     LIKE aprov_necessaria.cod_nivel_autor,
         l_cod_uni_funcio      LIKE aprov_necessaria.cod_uni_funcio,
         l_email               LIKE usuarios.e_mail,
         l_val_adto_viagem     LIKE cdv_adto_viagem.val_adto_viagem,
         l_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
         l_matricula_aprovador LIKE cdv_info_viajante.matricula,
         l_ies_tip_autor       LIKE nivel_autor_cap.ies_tip_autor,
         l_cod_usuario         LIKE usuario_subs_cap.cod_usuario,
         l_num_ad              LIKE ad_mestre.num_ad,
         l_cod_nivel_autor     LIKE aprov_necessaria.cod_nivel_autor,
         l_ind                 SMALLINT

  IF l_funcao = 1 THEN #Adiantamentos

     #Verifica se existe mais algum nível para aprovação para enviar e-mail
     WHENEVER ERROR CONTINUE
      SELECT MIN(cod_nivel_autor)
        INTO l_min_nivel_autor
        FROM aprov_necessaria
       WHERE cod_empresa     = ma_reg_aprov[l_ind].cod_empresa
         AND num_ad          = l_num_ad
         AND cod_nivel_autor > l_cod_nivel_autor
         AND ies_aprovado    = 'N'
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 0 AND l_min_nivel_autor IS NOT NULL THEN
        WHENEVER ERROR CONTINUE
         SELECT UNIQUE cod_uni_funcio
           INTO l_cod_uni_funcio
           FROM aprov_necessaria
          WHERE cod_empresa     = ma_reg_aprov[l_ind].cod_empresa
            AND num_ad          = l_num_ad
            AND cod_nivel_autor = l_min_nivel_autor
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql('SELEÇÃO','aprov_necessaria')
            RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
         SELECT ies_tip_autor
           INTO l_ies_tip_autor
           FROM nivel_autor_cap
          WHERE cod_empresa     = ma_reg_aprov[l_ind].cod_empresa
            AND cod_nivel_autor = l_min_nivel_autor
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
            CALL log0030_mensagem("Nível de autoridade não cadastrado.",'info')
            RETURN FALSE
        END IF

        IF l_ies_tip_autor = 'H' THEN
           WHENEVER ERROR CONTINUE
            SELECT cod_usuario
              INTO l_cod_usuario
              FROM usu_nivel_aut_cap
             WHERE cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
               AND cod_uni_funcio   = l_cod_uni_funcio
               AND cod_nivel_autor  = l_min_nivel_autor
               AND ies_versao_atual = 'S'
               AND ies_ativo        = 'S'
           WHENEVER ERROR STOP
        ELSE
            # Genérico não olha a Unidade Funcional
           WHENEVER ERROR CONTINUE
            SELECT cod_usuario
              INTO l_cod_usuario
              FROM usu_nivel_aut_cap
             WHERE cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
               AND cod_nivel_autor  = l_min_nivel_autor
               AND ies_versao_atual = 'S'
               AND ies_ativo        = 'S'
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = 0 THEN
           WHENEVER ERROR CONTINUE
            SELECT e_mail
              INTO l_email
              FROM usuarios
             WHERE cod_usuario = l_cod_usuario
           WHENEVER ERROR STOP
           IF SQLCA.SQLCODE = 0 THEN
              WHENEVER ERROR CONTINUE
               INSERT INTO t_envio_email VALUES (l_num_ad, NULL, l_email, l_min_nivel_autor)
              WHENEVER ERROR STOP
              IF SQLCA.SQLCODE <> 0 THEN
                 CALL log003_err_sql('INCLUSÃO','t_envio_email')
                 RETURN FALSE
              ELSE
                 WHENEVER ERROR CONTINUE
                  SELECT val_adto_viagem
                    INTO l_val_adto_viagem
                    FROM cdv_solic_adto_781
                   WHERE empresa            = ma_reg_aprov[l_ind].cod_empresa
                     AND viagem             = ma_reg_aprov[l_ind].viagem
                     AND num_ad_adto_viagem = l_num_ad
                     AND val_adto_viagem    > 0
                 WHENEVER ERROR STOP
                 IF SQLCA.SQLCODE <> 0 THEN
                    WHENEVER ERROR CONTINUE
                     SELECT empresa
                       FROM cdv_acer_viag_781
                      WHERE empresa         = ma_reg_aprov[l_ind].cod_empresa
                        AND viagem          = ma_reg_aprov[l_ind].viagem
                        AND ad_acerto_conta = l_num_ad
                    WHENEVER ERROR STOP
                    IF SQLCA.SQLCODE = 0 THEN
                       WHENEVER ERROR CONTINUE
                        INSERT INTO t_ad_email VALUES (l_num_ad, ma_reg_aprov[l_ind].viagem, 0)
                       WHENEVER ERROR STOP
                       IF SQLCA.SQLCODE <> 0 THEN
                          CALL log003_err_sql('INCLUSÃO','t_ad_email')
                          RETURN FALSE
                       END IF
                    END IF
                 ELSE
                    WHENEVER ERROR CONTINUE
                     INSERT INTO t_ad_email VALUES (l_num_ad, ma_reg_aprov[l_ind].viagem, l_val_adto_viagem)
                    WHENEVER ERROR STOP
                    IF SQLCA.SQLCODE <> 0 THEN
                       CALL log003_err_sql('INCLUSÃO','t_ad_email')
                       RETURN FALSE
                    END IF
                 END IF
              END IF
           END IF
        END IF
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2011_envia_email_solic()
#------------------------------------#
  DEFINE l_relat               CHAR(200),
         l_arquivo             CHAR(200),
         l_comando             CHAR(200),
         l_comand_mail_unix    CHAR(15),
         l_email               CHAR(40),
         l_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
         l_cliente_destino     LIKE cdv_solic_viagem.cliente_destino,
         l_dat_hor_partida     LIKE cdv_solic_viagem.dat_hor_partida,
         l_dat_hor_retorno     LIKE cdv_solic_viagem.dat_hor_retorno,
         l_num_viagem          LIKE cdv_solic_viag_781.viagem,
         l_num_ad              LIKE ad_mestre.num_ad,
         l_val_adto            LIKE cdv_adto_viagem.val_adto_viagem,
         l_pend_aprov          CHAR(01)

  MESSAGE 'Enviando e-mail para aprovantes . . .'

  DECLARE cq_email CURSOR FOR
   SELECT *
     FROM t_email_solic

  FOREACH cq_email INTO l_num_viagem, l_email, l_pend_aprov

      INITIALIZE l_relat TO NULL

      CALL log150_procura_caminho('LST') RETURNING l_relat
      LET l_relat = l_relat CLIPPED,
                    "mail_aprov_", cdv2011_tira_espacos(l_num_viagem), ".txt"

      START REPORT cdv2011_relatorio_aprov_cdv TO l_relat

      CALL cdv2011_busca_dados_email(l_num_viagem, 1)

      OUTPUT TO REPORT cdv2011_relatorio_aprov_cdv(l_num_viagem, l_pend_aprov)

      FINISH REPORT cdv2011_relatorio_aprov_cdv

      LET l_comando = "chmod 777 ", l_relat CLIPPED
      RUN l_comando

      LET l_arquivo = l_relat CLIPPED

      LET l_comand_mail_unix = m_comand_mail CLIPPED

      LET l_comando = l_comand_mail_unix, '" Pendências de Aprovação Eletrônica !!!" ',
                      l_email CLIPPED, " < ", l_arquivo CLIPPED
      RUN l_comando

      IF l_arquivo IS NOT NULL THEN
         LET l_comando = "rm ", l_arquivo CLIPPED
         RUN l_comando
      END IF

  END FOREACH

  WHENEVER ERROR CONTINUE
   DELETE FROM t_email_solic
    WHERE 1 = 1
  WHENEVER ERROR STOP

  MESSAGE ' '

END FUNCTION

#--------------------------------------------------------------#
 REPORT cdv2011_relatorio_aprov_cdv(l_num_viagem, l_pend_aprov)
#--------------------------------------------------------------#
  DEFINE l_num_viagem     LIKE cdv_solic_viag_781.viagem,
         l_pend_aprov     CHAR(01),
         l_descricao      CHAR(100)

  OUTPUT TOP    MARGIN 0
         LEFT   MARGIN 0
         BOTTOM MARGIN 0
         PAGE   LENGTH 1

  FORMAT
   ON EVERY ROW
      PRINT
      PRINT COLUMN 001, "***  A T E N Ç Ã O  ***"
      SKIP 2 LINES

      IF l_pend_aprov = 'P' THEN
          LET l_descricao = 'Existe uma pendência de aprovação para a Solicitação da Viagem: ', l_num_viagem USING '#########&'
      ELSE
          IF l_pend_aprov = 'S' THEN
              LET l_descricao = 'Solicitação/Adiantamentos da Viagem ', l_num_viagem USING '#########&', ' foram totalmente aprovados.'
          ELSE
              LET l_descricao = 'Acerto da Viagem ', l_num_viagem USING '#########&', ' foi totalmente aprovado.'
          END IF
      END IF

      PRINT COLUMN 001, l_descricao
      PRINT
      PRINT COLUMN 001, 'Viajante: ', mr_relat.nom_viajante
      PRINT COLUMN 001, 'Cliente: ', mr_relat.nom_cliente
      PRINT COLUMN 001, 'Reembolsável: ', mr_relat.des_reembolsavel
      PRINT COLUMN 001, 'Data/Hora Partida: ', mr_relat.data_partida, ' - ', mr_relat.hora_partida
      PRINT COLUMN 001, 'Data/Hora Retorno: ', mr_relat.data_retorno, ' - ', mr_relat.hora_retorno
      SKIP 2 LINES
      PRINT COLUMN 001, 'Utilize o link abaixo para acessar o programa de Aprovação de Viagens:'
      SKIP 1 LINE
      PRINT COLUMN 010, m_url_cdv_logo CLIPPED
      SKIP 3 LINES
      PRINT COLUMN 001, 'O conteúdo deste e-mail é meramente informativo.'
      PRINT COLUMN 001, 'A responsabilidade pela aprovação das viagens é de cada'
      PRINT COLUMN 001, 'coordenador/gerente/diretor, independente do recebimento deste.'

 END REPORT

#--------------------------------------#
 FUNCTION cdv2011_tira_espacos(l_valor)
#--------------------------------------#
  DEFINE l_tam,i SMALLINT
  DEFINE l_valor CHAR(100)
  DEFINE l_retorno CHAR(100)

  LET l_tam = LENGTH(l_valor)
  LET l_retorno = NULL

  FOR i = 1 TO l_tam

     IF (l_valor[i] <> " ") AND
        (l_valor[i] IS NOT null) THEN
        LET l_retorno = l_retorno CLIPPED, l_valor[i]
     END IF

  END FOR

  RETURN l_retorno CLIPPED

END FUNCTION

#--------------------------------#
 FUNCTION cdv2011_remeter_email()
#--------------------------------#
  DEFINE l_endereco LIKE funci.email,
         l_emissor  LIKE funci.email,
         l_nome     LIKE funci.nom_funci,
         l_respons  CHAR(008),
         l_deleta   CHAR(500),
         l_assunto  CHAR(50),
         l_comando  CHAR(150)

  INITIALIZE l_endereco, l_respons, l_emissor, l_nome TO NULL

  LET l_emissor = p_user CLIPPED, "@logocenter.com.br"
  LET l_assunto = " CDV - INCLUSAO DE PENDÊNCIA DE VIAGEM "

  WHENEVER ERROR CONTINUE
    SELECT email, nom_funci
      INTO l_endereco, l_nome
      FROM funci
     WHERE nom_funci_reduz = g_funci_autoriz
  WHENEVER ERROR STOP

  CALL cdv2011_executa_mail()

  IF l_endereco IS NOT NULL THEN
     LET l_comando  = 'chmod 777 ', p_nom_arquivo
     RUN l_comando
     CALL log5600_envia_email(l_emissor,
                              l_endereco,
                              l_assunto,p_nom_arquivo,1)
  END IF
  LET l_deleta = "rm ", p_nom_arquivo
  RUN l_deleta

END FUNCTION

#-------------------------------#
 FUNCTION cdv2011_executa_mail()
#-------------------------------#
  LET p_nom_arquivo = p_user CLIPPED ,".htm"

  START REPORT cdv2011_mail_lst TO p_nom_arquivo

  CALL cdv2011_busca_dados_email(ma_reg_aprov[pa_curr].viagem, 2)

  OUTPUT TO REPORT cdv2011_mail_lst()

  FINISH REPORT cdv2011_mail_lst
END FUNCTION

#-------------------------#
 REPORT cdv2011_mail_lst()
#-------------------------#
  DEFINE l_user          CHAR(08)

  OUTPUT
     LEFT  MARGIN 0
     RIGHT MARGIN 0
     TOP   MARGIN 1
     PAGE  LENGTH 64

  FORMAT
     ON EVERY ROW
        LET l_user = upshift(p_user) CLIPPED
        PRINT COLUMN 001, '<html>'
        PRINT COLUMN 001, '<head>'
        PRINT COLUMN 001, '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
        PRINT COLUMN 001, '<title></title>'

        PRINT COLUMN 001, '<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">'
        PRINT COLUMN 001, '<STYLE type=text/css>BODY {FONT-SIZE: 10px; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif}'
        PRINT COLUMN 001, 'TD {FONT-SIZE: 10px; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif}'
        PRINT COLUMN 001, '.button {BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-WEIGHT: bold; FONT-SIZE: 10px; BORDER-LEFT: 1px solid; CURSOR: hand; BORDER-BOTTOM: 1px solid; FONT-FAMILY: Verdana, Arial, Helvetica, sans-serif}'
        PRINT COLUMN 001, '.alertas {FONT-WEIGHT: bold; FONT-SIZE: 12px; COLOR: #ff0000}</STYLE>'
        PRINT COLUMN 001, '<META content="MSHTML 6.00.2723.2500" name=GENERATOR>'

        PRINT COLUMN 001, '</head>'
        PRINT COLUMN 001, '<body>'
        PRINT COLUMN 001, '<p><font face="Verdana" size="2" color="#000080">'

        PRINT COLUMN 001, '<b><u>cdv2011</u> &#150; <u>INCLUS&Atilde;O DE PEND&Ecirc;NCIA DE VIAGEM</u></b></font></p>'

        PRINT COLUMN 001, '<p align="right"><font face="Verdana" size="2" color="#000080">Data ',TODAY,' &agrave;s ',TIME,' hrs.</font></p>'

        PRINT COLUMN 001, '<table border="0" cellpadding="2" width="100%">'
        PRINT COLUMN 001, '<tr>'
        PRINT COLUMN 001, '<td width=90><b><font face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">Viajante</b></font></td>'
        PRINT COLUMN 001, '<td><font face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">',mr_relat.nom_viajante,'</font></td>'
        PRINT COLUMN 001, '</tr><tr>'
        PRINT COLUMN 001, '<td width=90><b><font align="right" face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">Cliente</b></font></td>'
        PRINT COLUMN 001, '<td><font align="right" face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">',mr_relat.nom_cliente,'</font></td>'
        PRINT COLUMN 001, '</tr><tr>'
        PRINT COLUMN 001, '<td width=90><b><font face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">Reembols&aacute;vel</b></font></td>'
        PRINT COLUMN 001, '<td><font align="right" face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">',mr_relat.des_reembolsavel,'</font></td>'
        PRINT COLUMN 001, '</tr><tr>'
        PRINT COLUMN 001, '<td width=90><b><font face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">Data/Hora Partida</b></font></td>'
        PRINT COLUMN 001, '<td><font align="right" face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">',mr_relat.data_partida, ' - ', mr_relat.hora_partida,'</font></td>'
        PRINT COLUMN 001, '</tr><tr>'
        PRINT COLUMN 001, '<td width=90><b><font face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">Data/Hora Retorno</b></font></td>'
        PRINT COLUMN 001, '<td><font align="right" face="Verdana" size="1" color="#000080" style="FONT-SIZE: 8pt">',mr_relat.data_retorno, ' - ', mr_relat.hora_retorno,'</font></td>'
        PRINT COLUMN 001, '</table>'

        PRINT COLUMN 001, '<FORM name=form1 action=http://suporte.logocenter.com.br:8080/agenda/pendenciaAutorizacao.jsp method=post>'
        PRINT COLUMN 001, '<TABLE cellSpacing=0 cellPadding=2 width=100>'
        PRINT COLUMN 001, '<TBODY>'
        PRINT COLUMN 001, '<TR align=middle>'
        PRINT COLUMN 001, '<TD noWrap align=right colSpan=2>'
        PRINT COLUMN 001, '<INPUT class=button type=submit value=Liberar name=acao>'
        PRINT COLUMN 001, '<INPUT class=button type=submit value=Rejeitar name=acao>'
        PRINT COLUMN 001, '</TD>'
        PRINT COLUMN 001, '</TR>'
        PRINT COLUMN 001, '</TBODY>'
        PRINT COLUMN 001, '</TABLE>'
        PRINT COLUMN 001, '<INPUT type=hidden value=', ma_reg_aprov[pa_curr].viagem, ' name=num_docum> '
        PRINT COLUMN 001, '<INPUT type=hidden value=', m_cliente_debitar, ' name=cliente> '
        PRINT COLUMN 001, '<INPUT type=hidden value=0 name=contrato> '
        PRINT COLUMN 001, '<INPUT type=hidden value=0 name=projeto> '
        PRINT COLUMN 001, '<INPUT type=hidden value=OS name=tip_docum> '
        PRINT COLUMN 001, '<INPUT type=hidden value=2 name=tip_autoriz> '
        PRINT COLUMN 001, '<INPUT type=hidden value=', g_funci_autoriz,' name=nomeReduzidoDestino> '
        PRINT COLUMN 001, '<INPUT type=hidden value=', l_user, ' name=nomeReduzidoSolicitante>'
        PRINT COLUMN 001, '<INPUT type=hidden name=observacao> '
        PRINT COLUMN 001, '</FORM>'

        PRINT COLUMN 001, '</body>'
        PRINT COLUMN 001, '</html>'
END REPORT

#---------------------------------------------------------#
 FUNCTION cdv2011_busca_dados_email(l_num_viagem, l_opcao)
#---------------------------------------------------------#
  DEFINE l_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
         l_cliente_destino     LIKE cdv_solic_viagem.cliente_destino,
         l_dat_hor_partida     LIKE cdv_solic_viagem.dat_hor_partida,
         l_dat_hor_retorno     LIKE cdv_solic_viagem.dat_hor_retorno,
         l_num_viagem          LIKE cdv_solic_viag_781.viagem,
         l_opcao               SMALLINT,
         l_status              SMALLINT

  IF l_opcao = 1 THEN
     WHENEVER ERROR STOP
      SELECT viajante,
             cliente_atendido,
             dat_hor_partida,
             dat_hor_retorno
        INTO l_matricula_viajante,
             l_cliente_destino,
             l_dat_hor_partida,
             l_dat_hor_retorno
        FROM cdv_solic_viag_781
       WHERE empresa = p_cod_empresa
         AND viagem  = l_num_viagem
     WHENEVER ERROR STOP
  ELSE
     WHENEVER ERROR CONTINUE
      SELECT viajante,
             cliente_fatur,
             dat_hor_partida,
             dat_hor_retorno
        INTO l_matricula_viajante,
             l_cliente_destino,
             l_dat_hor_partida,
             l_dat_hor_retorno
        FROM cdv_solic_viag_781
       WHERE empresa = p_cod_empresa
         AND viagem  = l_num_viagem
     WHENEVER ERROR STOP
  END IF

  IF SQLCA.SQLCODE = 0 THEN
     LET mr_relat.data_partida = EXTEND(l_dat_hor_partida, YEAR TO DAY)
     LET mr_relat.hora_partida = EXTEND(l_dat_hor_partida, HOUR TO MINUTE)

     LET mr_relat.data_retorno = EXTEND(l_dat_hor_retorno, YEAR TO DAY)
     LET mr_relat.hora_retorno = EXTEND(l_dat_hor_retorno, HOUR TO MINUTE)


     LET mr_relat.nom_viajante = cdv2011_busca_viajante(l_matricula_viajante)

     WHENEVER ERROR CONTINUE
     SELECT nom_cliente
       INTO mr_relat.nom_cliente
       FROM clientes
      WHERE cod_cliente = l_cliente_destino
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        LET mr_relat.nom_cliente = NULL
     END IF
  END IF
END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2011_entrada_dados_aen(l_val_adto_viagem)
#-----------------------------------------------------#
  DEFINE l_val_adto_viagem LIKE cdv_adto_viagem.val_adto_viagem

  DEFINE l_cont            SMALLINT

  LET m_cancela_aen = FALSE

  IF NOT cdv0065_verifica_aen() THEN
      RETURN
  END IF

  IF NOT cdv0065_entrada_dados_aen(0, l_val_adto_viagem) THEN
      LET m_cancela_aen = TRUE
      RETURN
  END IF

  INITIALIZE t_aen_309, t_aen_309_4 TO NULL

  FOR l_cont = 1 TO 200

      LET t_aen_309[l_cont].val_aen          = t_ad_aen[l_cont].val_item
      LET t_aen_309[l_cont].cod_area_negocio = t_ad_aen[l_cont].cod_area_negocio
      LET t_aen_309[l_cont].cod_lin_negocio  = t_ad_aen[l_cont].cod_lin_negocio

      LET t_aen_309_4[l_cont].val_aen        = t_ad_aen_4[l_cont].val_aen
      LET t_aen_309_4[l_cont].cod_lin_prod   = t_ad_aen_4[l_cont].cod_lin_prod
      LET t_aen_309_4[l_cont].cod_lin_recei  = t_ad_aen_4[l_cont].cod_lin_recei
      LET t_aen_309_4[l_cont].cod_seg_merc   = t_ad_aen_4[l_cont].cod_seg_merc
      LET t_aen_309_4[l_cont].cod_cla_uso    = t_ad_aen_4[l_cont].cod_cla_uso

  END FOR

 END FUNCTION

#--------------------------------------------------------#
 FUNCTION cdv2011_seleciona_aprovacao_excecao(l_empresa)
#--------------------------------------------------------#
  DEFINE l_empresa             LIKE empresa.cod_empresa,
         l_dat_hor_emis_solic  CHAR(20),
         l_dat_hor_emis_solic1 CHAR(10),
         l_ult_num_ad          LIKE aprov_necessaria.num_ad,
         sql_stmt              CHAR(2000),
         l_status              SMALLINT,
         l_num_viagem          LIKE cdv_solic_viag_781.viagem

  DEFINE lr_aprov_necessaria   RECORD LIKE aprov_necessaria.*

  WHENEVER ERROR CONTINUE
   DELETE FROM t_consulta_ord
    WHERE 1=1
  WHENEVER ERROR CONTINUE

  MESSAGE 'Carregando pendências de aprovação da Empresa: ', l_empresa ATTRIBUTE (REVERSE)

  LET sql_stmt = 'SELECT * FROM aprov_necessaria',
                 ' WHERE cod_empresa = "',l_empresa,'"',
                   ' AND ies_aprovado = "N"',
                   ' AND cod_nivel_autor NOT IN ("',m_nivel_aut_oper,'", "',m_niv_autd_agenc,'")'

  IF m_num_viagem IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND (num_ad IN (SELECT ad_acerto_conta',
                                                       ' FROM cdv_acer_viag_781',
                                                     ' WHERE empresa = "',l_cod_empresa,'"',
                                                       ' AND num_viagem = ',m_num_viagem,')',
                                       ' OR num_ad IN (SELECT num_ad_adto_viagem',
                                                        ' FROM cdv_solic_adto_781',
                                                       ' WHERE empresa = "',l_cod_empresa,'"',
                                                         ' AND viagem = ',m_num_viagem,'))'
  END IF

  PREPARE st_aprov_exc FROM sql_stmt
  DECLARE cq_aprov_necessaria CURSOR FOR st_aprov_exc
  FOREACH cq_aprov_necessaria INTO lr_aprov_necessaria.*

     IF lr_aprov_necessaria.num_ad = l_ult_num_ad  THEN
        CONTINUE FOREACH
     END IF

     LET l_ult_num_ad = lr_aprov_necessaria.num_ad

     WHENEVER ERROR CONTINUE
      SELECT cod_empresa
        FROM ad_mestre
       WHERE cod_empresa = lr_aprov_necessaria.cod_empresa
         AND num_ad      = lr_aprov_necessaria.num_ad
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CONTINUE FOREACH
     END IF

     CALL cdv2011_insercao_aprov_necessaria_temp(lr_aprov_necessaria.*)

  END FOREACH

END FUNCTION

#------------------------------------#
 FUNCTION cdv2011_consulta_ordenada()
#------------------------------------#
  DEFINE l_cod_tip_despesa     LIKE tipo_despesa.cod_tip_despesa,
         l_cont                SMALLINT,
         l_cod_uni_funcio      CHAR(10)

  LET p_ind = 1
  INITIALIZE ma_reg_aprov TO NULL

  LET sql_stmt = "SELECT aprova, empresa, viagem, controle, valor_ad, dat_partida,",
                       " dat_retorno, funcionario, cli_atendido, finalidade, cli_faturado, cod_tip_despesa, ",
                       " cod_uni_funcio ",
                  " FROM t_consulta_ord ",
                  "ORDER BY empresa,viagem "

  PREPARE var_consulta_ord FROM sql_stmt
  DECLARE cq_consulta_ord CURSOR FOR var_consulta_ord

  FOREACH cq_consulta_ord INTO ma_reg_aprov[p_ind].aprova,
                               ma_reg_aprov[p_ind].cod_empresa,
                               ma_reg_aprov[p_ind].viagem,
                               ma_reg_aprov[p_ind].controle,
                               ma_reg_aprov[p_ind].valor_ad,
                               ma_reg_aprov[p_ind].dat_partida,
                               ma_reg_aprov[p_ind].dat_retorno,
                               ma_reg_aprov[p_ind].funcionario,
                               ma_reg_aprov[p_ind].cli_atendido,
                               ma_reg_aprov[p_ind].finalidade,
                               ma_reg_aprov[p_ind].cli_faturado,
                               l_cod_tip_despesa,
                               l_cod_uni_funcio

      WHENEVER ERROR CONTINUE
      SELECT empresa
        FROM w_cdv2011
       WHERE empresa           = ma_reg_aprov[p_ind].cod_empresa
         AND cod_uni_funcional = l_cod_uni_funcio
      WHENEVER ERROR STOP

      IF sqlca.sqlcode = 100 THEN
         INITIALIZE ma_reg_aprov[p_ind].*, l_cod_tip_despesa, l_cod_uni_funcio TO NULL
         CONTINUE FOREACH
      END IF

      LET ma_cod_tip_despesa[p_ind] = l_cod_tip_despesa

      LET ma_aprov[p_ind].aprova    = ma_reg_aprov[p_ind].aprova

      CALL cdv2011_busca_dados_acer(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)
           RETURNING ma_aprov[p_ind].filial,
                     ma_aprov[p_ind].viajante,
                     ma_aprov[p_ind].cc_viajante

      LET ma_aprov[p_ind].controle  = ma_reg_aprov[p_ind].controle
      LET ma_aprov[p_ind].viagem    = ma_reg_aprov[p_ind].viagem

      LET ma_aprov[p_ind].qtd_km    = cdv2011_busca_qtd_km(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)
      LET ma_aprov[p_ind].qtd_hor   = cdv2011_busca_qtd_hor(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)
      LET ma_aprov[p_ind].val_desp  = cdv2011_busca_val_desp(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)
      LET ma_aprov[p_ind].val_terc  = cdv2011_busca_val_terc(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)
      LET ma_aprov[p_ind].val_adto  = cdv2011_busca_val_adto(ma_reg_aprov[p_ind].cod_empresa, ma_reg_aprov[p_ind].viagem)

      LET p_ind = p_ind + 1

  END FOREACH

  CURRENT WINDOW IS w_cdv2011

  IF p_ind > 0 THEN
     FOR l_cont = 1 TO 3
        DISPLAY ma_aprov[l_cont].* TO s_array_cons[l_cont].*
     END FOR
  END IF

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2011_historico_lanc_cont_cap(l_num_ad)
#--------------------------------------------------#
  DEFINE l_num_ad         LIKE ad_mestre.num_ad,
         l_tex_hist_lanc  LIKE lanc_cont_cap.tex_hist_lanc,
         l_num_seq        LIKE lanc_cont_cap.num_seq

  DECLARE cq_lanc_cont_cap CURSOR FOR
   SELECT tex_hist_lanc, num_seq
     FROM lanc_cont_cap
    WHERE cod_empresa = p_cod_empresa
      AND ies_ad_ap   = '1'
      AND num_ad_ap   = l_num_ad

  FOREACH cq_lanc_cont_cap INTO l_tex_hist_lanc, l_num_seq
      LET l_tex_hist_lanc = cap069_ext_hist(l_tex_hist_lanc,l_num_ad,1,0,p_cod_empresa)

      IF l_tex_hist_lanc IS NOT NULL THEN
          WHENEVER ERROR CONTINUE
            UPDATE lanc_cont_cap
               SET tex_hist_lanc = l_tex_hist_lanc
             WHERE cod_empresa   = p_cod_empresa
               AND num_ad_ap     = l_num_ad
               AND ies_ad_ap     = '1'
               AND num_seq       = l_num_seq
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('UPDATE','lanc_cont_cap')
             RETURN FALSE
          END IF

          CALL capr16_manutencao_ctb_lanc_ctbl_cap("M", p_cod_empresa, l_num_ad, 1, l_num_seq )
             RETURNING m_manut_tabela, m_processa

          IF m_manut_tabela AND m_processa THEN
             WHENEVER ERROR CONTINUE
               UPDATE ctb_lanc_ctbl_cap
                  SET ctb_lanc_ctbl_cap.compl_hist      = l_tex_hist_lanc
                WHERE ctb_lanc_ctbl_cap.empresa         = p_cod_empresa
                  AND ctb_lanc_ctbl_cap.num_ad_ap       = l_num_ad
                  AND ctb_lanc_ctbl_cap.eh_ad_ap        = "1"
                  AND ctb_lanc_ctbl_cap.seql_lanc_cap   = l_num_seq
             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql('UPDATE','CTB_LANC_CTBL_CAP')
                RETURN FALSE
             END IF
          ELSE
             IF NOT m_processa THEN
                RETURN FALSE
             END IF
          END IF

      END IF

  END FOREACH

  RETURN TRUE

 END FUNCTION

#------------------------------#
 FUNCTION cdv2011_valor_total()
#------------------------------#
  DEFINE l_ind SMALLINT
  DEFINE l_total LIKE ad_mestre.val_tot_nf

  LET l_total = 0

  FOR l_ind = 1 TO 1000
     IF ma_reg_aprov[l_ind].valor_ad IS NULL THEN
         EXIT FOR
     END IF
     LET l_total = l_total + ma_reg_aprov[l_ind].valor_ad
  END FOR

  DISPLAY l_total TO tot_ap

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2011_entra_num_viagem()
#-----------------------------------#

  INITIALIZE m_num_viagem, m_num_controle TO NULL

  LET INT_FLAG = FALSE
  #INPUT m_num_viagem, m_num_controle WITHOUT DEFAULTS
  # FROM num_viagem, num_controle
  #
  #   ON KEY(control-w)
  #      CALL cdv2011_help()
  #END INPUT

  RETURN NOT INT_FLAG

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2011_cria_temporarias()
#-----------------------------------#

  WHENEVER ERROR CONTINUE
   DROP TABLE t_consulta_ord
   DROP TABLE t_envio_email
   DROP TABLE t_email_solic
   DROP TABLE w_cdv2011
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_consulta_ord
   (aprova           CHAR(01),
    empresa          CHAR(02),
    viagem           INTEGER,
    controle         DECIMAL(20,0),
    valor_ad         DECIMAL(17,2),
    dat_partida      CHAR(10),
    dat_retorno      CHAR(10),
    funcionario      CHAR(30),
    cod_tip_despesa  DECIMAL(4,0),
    cli_atendido     CHAR(30),
    finalidade       CHAR(24),    #(5)
    cli_faturado     CHAR(20),
    num_ad           DECIMAL(6,0),
    cod_nivel_autor  CHAR(02),
    cod_uni_funcio   CHAR(10));

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','t_consulta_ord')
      RETURN FALSE
   END IF

   CREATE TEMP TABLE t_envio_email
   (num_ad          DECIMAL(6,0),
    viagem          INTEGER,
    email           CHAR(40),
    cod_nivel_autor CHAR(02));

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','t_envio_email')
      RETURN FALSE
   END IF

   CREATE TEMP TABLE t_email_solic
   (num_viagem      INTEGER,
    email           CHAR(40),
    pend_aprov      CHAR(01));

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','t_email_solic')
      RETURN FALSE
   END IF

   CREATE TEMP TABLE t_ad_email
   (num_ad     DECIMAL(6,0),
    num_viagem INTEGER,
    val_adto   DECIMAL(17,2));

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','t_ad_email')
      RETURN FALSE
   END IF

   CREATE TEMP TABLE w_cdv2011
     (empresa            CHAR(02),
      cod_uni_funcional  CHAR(10),
      ies_tip_autor      CHAR(01),
      situacao           CHAR(10),
      substituto         CHAR(08),
      cod_nivel_autor    CHAR(02),
      cod_emp_usuario    CHAR(02)) WITH NO LOG;

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','w_cdv2011')
      RETURN FALSE
   END IF

   CREATE INDEX ix_w_cdv2011_1 ON w_cdv2011
     (cod_emp_usuario,
      cod_uni_funcional,
      cod_nivel_autor,
      ies_tip_autor)

   IF SQLCA.SQLCODE <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','ix_w_cdv2011_1')
      RETURN FALSE
   END IF

  WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2011_carrega_parametros()
#-------------------------------------#

  DEFINE l_cod_uni_funcio     LIKE funcionario.cod_uni_funcio,
         l_empresa_rhu        LIKE cdv_info_viajante.empresa_rhu,
         l_matricula          LIKE cdv_info_viajante.matricula,
         l_uni_func_viaj      CHAR(10),
         l_msg                CHAR(80),
         l_status             SMALLINT,
         l_status_par         SMALLINT,
         l_parametro          LIKE cdv_par_viajante.parametro,
         l_parametro_booleano LIKE cdv_par_viajante.parametro_booleano

  WHENEVER ERROR CONTINUE
   SELECT nom_funcionario
     INTO m_nom_usuario
     FROM usuarios
    WHERE cod_usuario = p_user
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','USUARIOS')
     RETURN FALSE
  END IF

  WHENEVER ERROR STOP
   SELECT viaj.empresa_rhu, viaj.matricula
     INTO l_empresa_rhu, l_matricula
     FROM funcionario func, cdv_info_viajante viaj
    WHERE viaj.empresa       = p_cod_empresa
      AND viaj.usuario_logix = p_user
      AND viaj.matricula     = func.num_matricula
      AND func.cod_empresa   = viaj.empresa_rhu
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("select","funcionario")
     ELSE
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM cdv_par_viajante, cdv_info_viajante
           WHERE cdv_par_viajante.empresa = p_cod_empresa
             AND cdv_par_viajante.parametro = 'ind_rh_logix'
             AND cdv_par_viajante.parametro_booleano = 'S'
             AND cdv_par_viajante.matricula = cdv_info_viajante.matricula
             AND cdv_par_viajante.empresa_rhu = cdv_info_viajante.empresa_rhu
             AND cdv_info_viajante.empresa = p_cod_empresa
             AND cdv_info_viajante.usuario_logix = p_user
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
	        IF sqlca.sqlcode <> 100 THEN
	      	  CALL log003_err_sql('select','cdv_par_viajante')
	      	  RETURN FALSE
	        ELSE
	           WHENEVER ERROR CONTINUE
	      	  SELECT cdv_info_viajante.empresa_rhu, cdv_info_viajante.matricula
	      	    INTO l_empresa_rhu, l_matricula
	      	    FROM cdv_info_viajante
	      	   WHERE cdv_info_viajante.empresa = p_cod_empresa
                 AND cdv_info_viajante.usuario_logix = p_user
                 AND cdv_info_viajante.empresa_rhu = p_cod_empresa
	           WHENEVER ERROR STOP
	           IF sqlca.sqlcode <> 0 THEN
	              CALL log003_err_sql('select','cdv_info_viajante')
                 RETURN FALSE
	           END IF
	        END IF
	     ELSE
           CALL log003_err_sql("select","funcionario")
	        RETURN FALSE
	     END IF
	  END IF
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_texto[01,10]
     INTO l_uni_func_viaj
     FROM cdv_par_viajante
    WHERE empresa     = p_cod_empresa
      AND matricula   = l_matricula
      AND empresa_rhu = l_empresa_rhu
      AND parametro   = 'uni_func_viaj'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','CDV_PAR_VIAJANTE')
     RETURN FALSE
  END IF

  WHENEVER ERROR STOP
   SELECT cod_centro_custo
     INTO m_cod_cc_apr
     FROM unidade_funcional
    WHERE cod_empresa      = p_cod_empresa
      AND cod_uni_funcio   = l_uni_func_viaj
      AND dat_validade_fim > TODAY
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 100 THEN
     WHENEVER ERROR STOP
      SELECT cod_centro_custo
        INTO m_cod_cc_apr
        FROM unidade_funcional
       WHERE cod_empresa      = l_empresa_rhu
         AND cod_uni_funcio   = l_uni_func_viaj
         AND dat_validade_fim > TODAY
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','UNIDADE_FUNCIONAL2')
        RETURN FALSE
     END IF
  ELSE
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','UNIDADE_FUNCIONAL')
        RETURN FALSE
     END IF
  END IF

  LET m_usu_excecao = FALSE

  WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cdv_funcio_excecao
    WHERE empresa   = p_cod_empresa
      AND matricula = l_matricula
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     LET m_usu_excecao = TRUE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_ies
     INTO m_ies_usu_tela
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "tip_usu_tela_aprov"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0  THEN
     LET l_msg = 'Problema selec. parâmetro <tip_usu_tela_aprov>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_ies
     INTO m_ies_forma_aprov
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "ies_forma_aprov"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <ies_forma_aprov>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_txt
     INTO m_comand_mail
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "comand_mail_unix"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <comand_mail_unix>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_num
     INTO m_cod_lote_pgto_div
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "cod_lote_pgto_div"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 OR m_cod_lote_pgto_div IS NULL THEN
     LET l_msg = 'Problema selec. parâmetro <cod_lote_pgto_div>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  {490535
  WHENEVER ERROR CONTINUE
   SELECT parametro_val
     INTO m_tip_desp_acer_reem
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = "tip_desp_acer_reem"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <tip_desp_acer_reem>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF
  }

  WHENEVER ERROR CONTINUE
   SELECT parametro_ind
     INTO m_ies_aprov_eletr
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = "aprov_eletro_cdv"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <aprov_eletro_cdv>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_ind
     INTO m_hosped_fat_empresa
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = "hosped_fat_empresa"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <hosped_fat_empresa>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  #WHENEVER ERROR CONTINUE
  # SELECT parametro_ind
  #   INTO m_localiz_atual_bilh
  #   FROM cdv_par_padrao
  #  WHERE empresa   = p_cod_empresa
  #    AND parametro = "localiz_atualiz_bilh"
  #WHENEVER ERROR STOP
  #IF SQLCA.SQLCODE <> 0 THEN
  #   LET l_msg = 'Problema selec. parâmetro <localiz_atualiz_bilh>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
  #   CALL log0030_mensagem(l_msg,'exclamation')
  #   RETURN FALSE
  #END IF

  IF m_hosped_fat_empresa = "S" THEN
     WHENEVER ERROR CONTINUE
      SELECT parametro_val
        INTO m_tip_val_bx_hosped
        FROM cdv_par_padrao
       WHERE empresa   = p_cod_empresa
         AND parametro = "tip_val_bx_hosped"
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 OR m_tip_val_bx_hosped IS NULL THEN
        LET l_msg = 'Problema selec. parâmetro <tip_val_bx_hosped>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
        CALL log0030_mensagem(l_msg,'exclamation')
        RETURN FALSE
     END IF
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_texto
     INTO m_nivel_aut_oper
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = "nivel_aut_oper"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <nivel_aut_oper>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT niv_autd_agenc
     INTO m_niv_autd_agenc
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <niv_autd_agenc>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  {490535
  WHENEVER ERROR CONTINUE
   SELECT tip_desp_acer_cta
     INTO m_tip_desp_acer_cta
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <tip_desp_acer_cta>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF
  }

  WHENEVER ERROR CONTINUE
   SELECT tip_desp_adto_viag
     INTO m_tip_desp_adto_viag
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <tip_desp_adto_viag>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT niv_autd_cc_debt
     INTO m_niv_autd_cc_debt
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <niv_autd_cc_debt>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT desp_solic_viagem
     INTO m_desp_solic_viagem
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET l_msg = 'Problema selec. parâmetro <desp_solic_viagem>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT tip_val_tr_viag
     INTO m_tip_val_tr_viag
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 OR m_tip_val_tr_viag IS NULL THEN
     LET l_msg = 'Problema selec. parâmetro <tip_val_tr_viag>, SQLCA.SQLCODE = ',SQLCA.SQLCODE
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'url_cdv_intranet_logocenter')
     RETURNING m_url_cdv_logo, l_status

  IF NOT l_status THEN
     CALL log0030_mensagem("Problema seleção parâmetro link CDV.",'exclamation')
     RETURN FALSE
  END IF

  #490535
  CALL log2250_busca_parametro(p_cod_empresa,'tip_desp_acer_viag')
     RETURNING m_tip_desp_acer_viag, l_status
  IF NOT l_status OR m_tip_desp_acer_viag IS NULL THEN
     LET m_tip_desp_acer_viag = 0
     CALL log0030_mensagem("Problema seleção parâmetro 'tip_desp_acer_viag'.",'exclamation')
     RETURN FALSE
  END IF


  IF m_url_cdv_logo IS NULL THEN
     LET m_url_cdv_logo = "http://gil.logocenter.com.br/clijava/site/cdvlogixweb6/index.jsp"
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_ind
     INTO m_ind_gao_adtos
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = "ind_gao_adtos"
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 OR m_ind_gao_adtos IS NULL THEN
     LET m_ind_gao_adtos = "N"
  END IF

  WHENEVER ERROR CONTINUE
   SELECT par_ies
     INTO m_area_linha_neg
     FROM par_cap_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "ies_area_linha_neg"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 OR m_area_linha_neg IS NULL THEN
     LET m_area_linha_neg = 'N'
     RETURN FALSE
  END IF

  IF m_area_linha_neg = 'S' THEN
     WHENEVER ERROR CONTINUE
      SELECT par_ies
        INTO m_ies_aen_2_4
        FROM par_cap_pad
       WHERE cod_empresa   = p_cod_empresa
         AND cod_parametro = "ies_aen_2_4"
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 100 OR m_ies_aen_2_4 IS NULL THEN
        CALL log0030_mensagem("Favor cadastrar parâmetro de uso de AEN Normal/Complementar. CAP2360",'info')
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION cdv2011_insercao_aprov_necessaria_temp(lr_aprov_necessaria)
#--------------------------------------------------------------------#

  DEFINE lr_consulta_ord RECORD
         aprova           CHAR(01),
         empresa          LIKE empresa.cod_empresa,
         viagem           LIKE cdv_acer_viag_781.viagem,
         controle         LIKE cdv_acer_viag_781.controle,
         valor_ad         LIKE ad_mestre.val_tot_nf,
         dat_partida      CHAR(10),
         dat_retorno      CHAR(10),
         funcionario      LIKE usuarios.nom_funcionario,
         cod_tip_despesa  DECIMAL(4,0),
         cli_atendido     CHAR(30),
         finalidade       CHAR(24),
         cli_faturado     CHAR(20),
         num_ad           DECIMAL(6,0),
         cod_nivel_autor  CHAR(02),
         cod_uni_funcio   CHAR(10)
  END RECORD

  DEFINE lr_aprov_necessaria RECORD LIKE aprov_necessaria.*,
         lr_usuario_subs_cap RECORD LIKE usuario_subs_cap.*

  DEFINE l_funcionario         LIKE usuarios.nom_funcionario,
         l_num_ap              LIKE ad_ap.num_ap,
         l_cc_viajante         LIKE cdv_solic_viagem.cc_viajante,
         l_cc_debitar          LIKE cdv_solic_viagem.cc_debitar,
         l_apropr_desp_transf  LIKE cap_ad_transf_mut.apropr_desp_transf,
         l_num_viagem          LIKE cdv_acer_viag_781.viagem,
         l_dat_cheg_aux        CHAR(19),
         l_dat_cheg_aux2       DATETIME YEAR TO SECOND,
         l_dat_cheg_aux3       DATETIME YEAR TO SECOND,
         l_status              SMALLINT,
         l_finalidade_viagem   LIKE cdv_solic_viag_781.finalidade_viagem,
         l_cli_atendido        LIKE clientes.cod_cliente,
         l_cli_faturado        LIKE clientes.cod_cliente,
         l_viajante            LIKE cdv_solic_viag_781.viajante

  LET lr_consulta_ord.aprova = 'N'

  CALL cdv2011_procura_viagem(lr_aprov_necessaria.num_ad, lr_aprov_necessaria.cod_empresa)
     RETURNING l_status, lr_consulta_ord.viagem

  IF NOT l_status THEN
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
   SELECT controle
     INTO lr_consulta_ord.controle
     FROM cdv_solic_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = lr_consulta_ord.viagem
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','cdv_solic_viag_781')
     LET m_work = FALSE
  END IF

  LET lr_consulta_ord.empresa = lr_aprov_necessaria.cod_empresa

  WHENEVER ERROR CONTINUE
   SELECT val_tot_nf
     INTO lr_consulta_ord.valor_ad
     FROM ad_mestre
    WHERE cod_empresa = lr_consulta_ord.empresa
      AND num_ad      = lr_aprov_necessaria.num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("SELEÇÃO","ad_mestre")
     LET m_work = FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT ad_acerto_conta
     FROM cdv_acer_viag_781
    WHERE empresa         = lr_consulta_ord.empresa
      AND ad_acerto_conta = lr_aprov_necessaria.num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     WHENEVER ERROR CONTINUE
      SELECT num_ap
        INTO l_num_ap
        FROM ad_ap
       WHERE cod_empresa = lr_consulta_ord.empresa
         AND num_ad      = lr_aprov_necessaria.num_ad
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 0 THEN
        CALL cdv2011_calcula_val_liquido(lr_consulta_ord.empresa, l_num_ap)
           RETURNING lr_consulta_ord.valor_ad
     END IF
  END IF

  IF m_ies_usu_tela = "2"  THEN

     INITIALIZE l_funcionario TO NULL

     DECLARE cq_usu_subst_cap CURSOR FOR
      SELECT *
        FROM usuario_subs_cap
       WHERE cod_empresa      = lr_consulta_ord.empresa
         AND cod_usuario_subs = p_user
         AND ies_versao_atual = "S"
         AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
         AND TODAY BETWEEN dat_ini_validade AND dat_fim_validade

     FOREACH cq_usu_subst_cap INTO lr_usuario_subs_cap.*

        WHENEVER ERROR CONTINUE
         SELECT *
           FROM usu_nivel_aut_cap
          WHERE cod_empresa      = lr_consulta_ord.empresa
            AND cod_usuario      = lr_usuario_subs_cap.cod_usuario
            AND ies_versao_atual = "S"
            AND ies_ativo        = "S"
            AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE = 0  THEN
           WHENEVER ERROR CONTINUE
            SELECT nom_funcionario
              INTO l_funcionario
              FROM usuarios
             WHERE cod_usuario = lr_usuario_subs_cap.cod_usuario
           WHENEVER ERROR CONTINUE
           IF SQLCA.SQLCODE = 0 THEN
             LET lr_consulta_ord.funcionario =  l_funcionario
           END IF
           EXIT FOREACH
        END IF
     END FOREACH
  END IF

  WHENEVER ERROR CONTINUE
   SELECT ad.cod_tip_despesa
     INTO lr_consulta_ord.cod_tip_despesa
     FROM ad_mestre ad
    WHERE ad.cod_empresa = lr_consulta_ord.empresa
      AND ad.num_ad      = lr_aprov_necessaria.num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("SELECAO","ad_mestre/tipo_despesa")
     LET m_work = FALSE
  END IF

  WHENEVER ERROR CONTINUE
   SELECT cliente_fatur, cliente_atendido, finalidade_viagem, dat_hor_partida,
          dat_hor_retorno, viajante
     INTO l_cli_atendido, l_cli_faturado, l_finalidade_viagem,
          l_dat_cheg_aux2, l_dat_cheg_aux3, l_viajante
     FROM cdv_solic_viag_781
    WHERE empresa = lr_consulta_ord.empresa
      AND viagem  = lr_consulta_ord.viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0 THEN
     IF lr_consulta_ord.funcionario IS NULL OR lr_consulta_ord.funcionario = " " THEN
						  LET lr_consulta_ord.funcionario = cdv2011_busca_viajante(l_viajante)

     END IF

     LET l_dat_cheg_aux = l_dat_cheg_aux2
     LET lr_consulta_ord.dat_partida = l_dat_cheg_aux[09,10],"/",
                                       l_dat_cheg_aux[06,07],"/",
                                       l_dat_cheg_aux[01,04]

     LET l_dat_cheg_aux = l_dat_cheg_aux3
     LET lr_consulta_ord.dat_retorno = l_dat_cheg_aux[09,10],"/",
                                       l_dat_cheg_aux[06,07],"/",
                                       l_dat_cheg_aux[01,04]
     WHENEVER ERROR CONTINUE
      SELECT nom_cliente[1,30]
        INTO lr_consulta_ord.cli_atendido
        FROM clientes
       WHERE cod_cliente = l_cli_atendido
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
      SELECT nom_cliente[1,30]
        INTO lr_consulta_ord.cli_faturado
        FROM clientes
       WHERE cod_cliente = l_cli_faturado
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
      SELECT des_finalidade
        INTO lr_consulta_ord.finalidade
        FROM cdv_finalidade_781
       WHERE finalidade = l_finalidade_viagem
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('SELECT','cdv_finalidade_781')
     END IF
  END IF

  LET lr_consulta_ord.num_ad          = lr_aprov_necessaria.num_ad
  LET lr_consulta_ord.cod_nivel_autor = lr_aprov_necessaria.cod_nivel_autor
  LET lr_consulta_ord.cod_uni_funcio  = lr_aprov_necessaria.cod_uni_funcio

  WHENEVER ERROR CONTINUE
   INSERT INTO t_consulta_ord VALUES (lr_consulta_ord.*)
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql("INSERT","t_consulta_ord2")
     LET m_work = FALSE
  END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2011_seleciona_dados(l_cod_empresa)
#----------------------------------------------#
  DEFINE l_cod_empresa      CHAR(02),
         l_aux_uni          LIKE usu_nivel_aut_cap.cod_uni_funcio,
         l_uni_funcio       LIKE usu_nivel_aut_cap.cod_uni_funcio,
         l_aux_ct           SMALLINT,
         l_ult_num_ad       LIKE aprov_necessaria.num_ad,
         l_achou_aprov      SMALLINT,
         l_qtd1             SMALLINT,
         l_qtd2             SMALLINT,
         l_qtd              SMALLINT,
         l_status           SMALLINT,
         l_num_viagem       LIKE cdv_solic_viag_781.viagem,
         sql_stmt           CHAR(2000)

  DEFINE g_w_cdv2011  RECORD
         empresa            LIKE empresa.cod_empresa,
         cod_uni_funcional  CHAR(10),
         ies_tip_autor      CHAR(01),
         situacao           CHAR(10),
         substituto         CHAR(08),
         cod_nivel_autor    CHAR(02),
         cod_emp_usuario    CHAR(02)
  END RECORD

  DEFINE lr_aprov_necessaria     RECORD LIKE aprov_necessaria.*

  LET l_ult_num_ad = 0

  # Rotina para buscar as viagens que não possuem AD de acerto.
  IF NOT cdv2011_busca_aprov_viag(l_cod_empresa) THEN
     RETURN
  END IF

  ##################################
  { Seleciona aprovacoes genericas }
  ##################################

  INITIALIZE sql_stmt TO NULL
  LET sql_stmt = ' SELECT aprov.* FROM aprov_necessaria aprov',
                  ' WHERE aprov.cod_empresa = "',l_cod_empresa,'"',
                    ' AND aprov.ies_aprovado = "N"',
                    ' AND EXISTS (SELECT DISTINCT(cod_empresa)',
                                  ' FROM w_cdv2011 tmp',
                                 ' WHERE tmp.cod_emp_usuario = aprov.cod_empresa',
                                   ' AND (tmp.cod_nivel_autor = aprov.cod_nivel_autor',
                                    ' OR (tmp.cod_nivel_autor >= aprov.cod_nivel_autor AND',
                                        ' tmp.situacao = "Subst."))',
                                   ' AND tmp.ies_tip_autor = "G")'

  IF m_num_viagem IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND (num_ad IN (SELECT ad_acerto_conta',
                                                       ' FROM cdv_acer_viag_781',
                                                     ' WHERE empresa = "',l_cod_empresa,'"',
                                                       ' AND viagem = ',m_num_viagem,')',
                                       ' OR num_ad IN (SELECT num_ad_adto_viagem',
                                                        ' FROM cdv_solic_adto_781',
                                                       ' WHERE empresa = "',l_cod_empresa,'"',
                                                         ' AND viagem = ',m_num_viagem,'))'
  END IF

  LET sql_stmt = sql_stmt CLIPPED, ' ORDER BY aprov.num_ad'

  WHENEVER ERROR CONTINUE
   PREPARE st_aprov_necess FROM sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql_detalhe("PREPARE","st_aprov_necess",sql_stmt)
     RETURN
  END IF

  DECLARE cq_aprov_necess CURSOR FOR st_aprov_necess

  WHENEVER ERROR CONTINUE
   FOREACH cq_aprov_necess INTO lr_aprov_necessaria.*
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql_detalhe("FOREACH","cq_aprov_necess",sql_stmt)
     RETURN
  END IF

     IF lr_aprov_necessaria.num_ad = l_ult_num_ad  THEN
        CONTINUE FOREACH
     END IF
     LET l_ult_num_ad = lr_aprov_necessaria.num_ad

     WHENEVER ERROR CONTINUE
      SELECT cod_empresa
        FROM ad_mestre
       WHERE cod_empresa = l_cod_empresa
         AND num_ad      = lr_aprov_necessaria.num_ad
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 100 THEN
        WHENEVER ERROR CONTINUE
         DELETE FROM aprov_necessaria
          WHERE cod_empresa      = l_cod_empresa
            AND num_ad           = lr_aprov_necessaria.num_ad
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("DELETE","APROV_NECESS")
           EXIT PROGRAM
        END IF
        CONTINUE FOREACH
     ELSE
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("SELECAO","ad_mestre6")
           EXIT PROGRAM
        END IF
     END IF

     CALL cdv2011_insercao_aprov_necessaria_temp(lr_aprov_necessaria.*)

  END FOREACH

  ######################################
  { Seleciona aprovacoes Hierarquicas}
  ######################################

  LET l_ult_num_ad = 0
  INITIALIZE sql_stmt TO NULL

  LET sql_stmt = 'SELECT aprov.* FROM aprov_necessaria aprov',
                 ' WHERE aprov.cod_empresa = "',l_cod_empresa,'"',
                   ' AND aprov.ies_aprovado = "N"',
                   ' AND EXISTS (SELECT DISTINCT(cod_empresa)',
                                 ' FROM w_cdv2011 tmp',
                                ' WHERE tmp.cod_emp_usuario = aprov.cod_empresa',
                                  ' AND tmp.cod_uni_funcional = aprov.cod_uni_funcio',
                                  ' AND (tmp.cod_nivel_autor = aprov.cod_nivel_autor',
                                   ' OR (tmp.cod_nivel_autor >= aprov.cod_nivel_autor AND',
                                       ' tmp.situacao = "Subst."))',
                                  ' AND tmp.ies_tip_autor = "H")'

  IF m_num_viagem IS NOT NULL THEN
     LET sql_stmt = sql_stmt CLIPPED, ' AND (num_ad IN (SELECT ad_acerto_conta',
                                                       ' FROM cdv_acer_viag_781',
                                                     ' WHERE empresa = "',l_cod_empresa,'"',
                                                       ' AND viagem = ',m_num_viagem,')',
                                       ' OR num_ad IN (SELECT num_ad_adto_viagem',
                                                        ' FROM cdv_solic_adto_781',
                                                       ' WHERE empresa = "',l_cod_empresa,'"',
                                                         ' AND viagem = ',m_num_viagem,'))'
  END IF

  LET sql_stmt = sql_stmt CLIPPED, ' ORDER BY aprov.num_ad, aprov.cod_nivel_autor,  aprov.cod_uni_funcio'

  PREPARE st_aprov_hierarq FROM sql_stmt
  DECLARE cq_aprov_hierarq CURSOR FOR st_aprov_hierarq
  FOREACH cq_aprov_hierarq INTO lr_aprov_necessaria.*

     IF lr_aprov_necessaria.num_ad = l_ult_num_ad  AND
        l_achou_aprov = TRUE  THEN
        CONTINUE FOREACH
     END IF

     LET l_ult_num_ad  = lr_aprov_necessaria.num_ad
     LET l_achou_aprov = FALSE

     CALL cdv2011_procura_viagem(lr_aprov_necessaria.num_ad, lr_aprov_necessaria.cod_empresa)
        RETURNING l_status, l_num_viagem

     IF NOT l_status THEN
        CONTINUE FOREACH
     END IF

     IF m_num_viagem IS NOT NULL THEN
        IF m_num_viagem <> l_num_viagem THEN
           CONTINUE FOREACH
        END IF
     END IF

     WHENEVER ERROR CONTINUE
      SELECT cod_empresa
        FROM ad_mestre
       WHERE cod_empresa = l_cod_empresa
         AND num_ad      = lr_aprov_necessaria.num_ad
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = NOTFOUND THEN
        WHENEVER ERROR CONTINUE
         DELETE FROM aprov_necessaria
          WHERE cod_empresa = l_cod_empresa
            AND num_ad      = lr_aprov_necessaria.num_ad
        WHENEVER ERROR CONTINUE
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("DELETE","APROV_NECESS")
           EXIT PROGRAM
        END IF
        CONTINUE FOREACH
     ELSE
        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("SELECAO","ad_mestre5")
           EXIT PROGRAM
        END IF
     END IF

     IF m_ies_forma_aprov = "3"  THEN {So' aprova se inf. ja aprovaram}

        LET l_qtd  = 1
        LET l_qtd1 = 1
        LET l_qtd2 = 1

        INITIALIZE g_w_cdv2011 TO NULL

        DECLARE cq_w_cdv2011 CURSOR FOR
         SELECT *
           FROM w_cdv2011
          WHERE cod_emp_usuario   = lr_aprov_necessaria.cod_empresa
            AND cod_uni_funcional = lr_aprov_necessaria.cod_uni_funcio
            AND (substituto       = "" OR substituto IS NULL)
            AND cod_nivel_autor   = lr_aprov_necessaria.cod_nivel_autor

        FOREACH cq_w_cdv2011 INTO g_w_cdv2011.*

           SELECT COUNT(*)
             INTO l_qtd
             FROM aprov_necessaria
            WHERE aprov_necessaria.ies_aprovado    = "N"
              AND aprov_necessaria.num_ad          = lr_aprov_necessaria.num_ad
              AND aprov_necessaria.cod_empresa     = lr_aprov_necessaria.cod_empresa
              AND aprov_necessaria.cod_nivel_autor < g_w_cdv2011.cod_nivel_autor
              AND ((aprov_necessaria.cod_uni_funcio = lr_aprov_necessaria.cod_uni_funcio AND
                    aprov_necessaria.cod_nivel_autor NOT IN (m_niv_autd_cc_debt)) OR
                   (aprov_necessaria.cod_nivel_autor IN (m_niv_autd_cc_debt)))

           IF l_qtd > 0 THEN
              LET l_qtd1 = l_qtd
              EXIT FOREACH
           ELSE
              LET l_qtd1 = l_qtd
           END IF

        END FOREACH

        IF l_qtd > 0 THEN

           LET l_qtd2 = 1

           INITIALIZE g_w_cdv2011 TO NULL

           DECLARE cq_w_cdv20111 CURSOR FOR
            SELECT *
              FROM w_cdv2011
             WHERE cod_emp_usuario   = lr_aprov_necessaria.cod_empresa
               AND cod_uni_funcional = lr_aprov_necessaria.cod_uni_funcio
               AND substituto        <> ""
               AND substituto        IS NOT NULL

           FOREACH cq_w_cdv20111 INTO g_w_cdv2011.*

              SELECT COUNT(*)
                INTO l_qtd
                FROM aprov_necessaria
               WHERE aprov_necessaria.ies_aprovado    = "N"
                 AND aprov_necessaria.num_ad          = lr_aprov_necessaria.num_ad
                 AND aprov_necessaria.cod_empresa     = lr_aprov_necessaria.cod_empresa
                 AND aprov_necessaria.cod_nivel_autor < g_w_cdv2011.cod_nivel_autor
                 AND ((aprov_necessaria.cod_uni_funcio = lr_aprov_necessaria.cod_uni_funcio
                 AND   aprov_necessaria.cod_nivel_autor NOT IN (m_niv_autd_cc_debt)) OR
                      (aprov_necessaria.cod_nivel_autor IN (m_niv_autd_cc_debt)))

              IF l_qtd > 0 THEN
                  LET l_qtd2 = l_qtd
                  EXIT FOREACH
              ELSE
                  SELECT count(*)
                    INTO l_qtd
                    FROM aprov_necessaria aprov_necessaria
                   WHERE aprov_necessaria.ies_aprovado    = "S"
                     AND aprov_necessaria.num_ad          = lr_aprov_necessaria.num_ad
                     AND aprov_necessaria.cod_empresa     = lr_aprov_necessaria.cod_empresa
                     AND aprov_necessaria.cod_nivel_autor = g_w_cdv2011.cod_nivel_autor
                     AND aprov_necessaria.cod_uni_funcio  = lr_aprov_necessaria.cod_uni_funcio

                  IF l_qtd > 0 THEN
                    LET l_qtd2 = l_qtd
                    EXIT FOREACH
                  ELSE
                    LET l_qtd2 = 0
                  END IF
              END IF

           END FOREACH
        END IF

        IF l_qtd1 <> 0 THEN
          IF l_qtd2 <> 0 THEN
              LET l_qtd = 1
          END IF
        END IF
     ELSE
        LET l_qtd = 0
     END IF

     IF l_qtd > 0 THEN
        CONTINUE FOREACH
     END IF

     IF lr_aprov_necessaria.cod_uni_funcio <> l_uni_funcio THEN
        LET l_aux_uni = lr_aprov_necessaria.cod_uni_funcio
        LET l_aux_ct  = LENGTH(l_aux_uni)
        WHILE TRUE
           LET l_aux_uni[l_aux_ct,l_aux_ct] = "0"
           IF l_aux_ct > 1 THEN
              IF l_aux_uni = l_uni_funcio THEN
                 EXIT WHILE
              ELSE
                 LET l_aux_ct = l_aux_ct -1
              END IF
           ELSE
              EXIT WHILE
           END IF
        END WHILE
        IF l_aux_uni <> l_uni_funcio THEN
           CONTINUE FOREACH
        END IF
     END IF

     LET l_achou_aprov = TRUE

     CALL cdv2011_insercao_aprov_necessaria_temp(lr_aprov_necessaria.*)

  END FOREACH

END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2011_procura_viagem(l_num_ad, l_cod_empresa)
#------------------------------------------------------#
  DEFINE l_num_ad        DECIMAL(6,0),
         l_cod_empresa   CHAR(02),
         l_num_viagem    LIKE cdv_solic_viag_781.viagem

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_num_viagem
     FROM cdv_acer_viag_781
    WHERE empresa         = l_cod_empresa
      AND ad_acerto_conta = l_num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     RETURN TRUE, l_num_viagem
  END IF

  WHENEVER ERROR CONTINUE
   SELECT viagem
     INTO l_num_viagem
     FROM cdv_solic_adto_781
    WHERE empresa            = l_cod_empresa
      AND num_ad_adto_viagem = l_num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     RETURN TRUE, l_num_viagem
  END IF

  RETURN FALSE, l_num_viagem

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv2011_carga_aprovantes(l_cod_empresa)
#------------------------------------------------#
  DEFINE l_cod_empresa        CHAR(02),
         l_subst_de           CHAR(22),
         l_cod_usuario        LIKE usuario_subs_cap.cod_usuario,
         l_cod_uni_funcio     LIKE usuario_subs_cap.cod_uni_funcio

  DEFINE lr_usu_nivel_aut_cap RECORD LIKE usu_nivel_aut_cap.*

  DECLARE cq_usu_nivel CURSOR FOR
   SELECT *
     FROM usu_nivel_aut_cap
    WHERE cod_empresa      = l_cod_empresa
      AND cod_usuario      = p_user
      AND ies_versao_atual = "S"
      AND ies_ativo        = "S"
  FOREACH cq_usu_nivel INTO lr_usu_nivel_aut_cap.*

     WHENEVER ERROR CONTINUE
      INSERT INTO w_cdv2011 VALUES (lr_usu_nivel_aut_cap.cod_empresa,
                                    lr_usu_nivel_aut_cap.cod_uni_funcio,
                                    lr_usu_nivel_aut_cap.ies_tip_autor,
                                    "Princ.","",
                                    lr_usu_nivel_aut_cap.cod_nivel_autor,
                                    lr_usu_nivel_aut_cap.cod_emp_usuario)
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 AND SQLCA.SQLCODE <> -239 THEN
        CALL log003_err_sql("INCLUSAO","w_cdv2011")
        EXIT FOREACH
     END IF
  END FOREACH

  DECLARE cq_subs_nivel CURSOR FOR
   SELECT cod_usuario, cod_uni_funcio
     FROM usuario_subs_cap
    WHERE cod_empresa      = l_cod_empresa
      AND cod_usuario_subs = p_user
      AND ies_versao_atual = "S"
      AND TODAY BETWEEN dat_ini_validade AND dat_fim_validade

  FOREACH cq_subs_nivel INTO l_cod_usuario, l_cod_uni_funcio
     DECLARE cq_acha_princ2 CURSOR FOR
      SELECT *
        FROM usu_nivel_aut_cap
       WHERE cod_empresa      = l_cod_empresa
         AND cod_usuario      = l_cod_usuario
         AND ies_versao_atual = "S"
         AND cod_uni_funcio   = l_cod_uni_funcio

     FOREACH cq_acha_princ2 INTO lr_usu_nivel_aut_cap.*
        LET l_subst_de = "Substituto de ",lr_usu_nivel_aut_cap.cod_usuario

        WHENEVER ERROR CONTINUE
         INSERT INTO w_cdv2011 VALUES (lr_usu_nivel_aut_cap.cod_empresa,
                                       lr_usu_nivel_aut_cap.cod_uni_funcio,
                                       lr_usu_nivel_aut_cap.ies_tip_autor,
                                       "Subst.", lr_usu_nivel_aut_cap.cod_usuario,
                                       lr_usu_nivel_aut_cap.cod_nivel_autor,
                                       lr_usu_nivel_aut_cap.cod_emp_usuario)
        WHENEVER ERROR STOP
        IF SQLCA.SQLCODE <>  0 AND SQLCA.SQLCODE <> -239 THEN
           CALL log003_err_sql("INCLUSAO","w_cdv2011")
           EXIT FOREACH
        END IF
     END FOREACH
  END FOREACH

END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv2011_seleciona_compr_pend_aprov(l_cod_empresa)
#----------------------------------------------------------#

  DEFINE l_cod_empresa LIKE empresa.cod_empresa

  WHENEVER ERROR CONTINUE
   DELETE FROM t_consulta_ord
    WHERE 1=1
  WHENEVER ERROR CONTINUE

  CALL cdv2011_carga_aprovantes(l_cod_empresa)
  CALL cdv2011_seleciona_dados(l_cod_empresa)

END FUNCTION

#------------------------------#
 FUNCTION cdv2011_exibe_dados()
#------------------------------#

  DISPLAY p_user TO cod_usuario
  DISPLAY p_cod_empresa TO cod_empresa_corrente
  DISPLAY m_nom_usuario TO nom_funcionario
  DISPLAY m_cod_cc_apr TO cod_cc_apr

  IF m_ies_usu_tela = "2"  THEN
      DISPLAY "   SUBSTITUTO DE:   " AT 8,57
  END IF

END FUNCTION

#-----------------------#
 FUNCTION cdv2011_help()
#-----------------------#
  CASE
     WHEN INFIELD(ies_aprovado) CALL showhelp(101)
     WHEN INFIELD(num_viagem)   CALL SHOWHELP(102)
     WHEN INFIELD(ordenacao)    CALL SHOWHELP(103)
     WHEN INFIELD(num_controle) CALL SHOWHELP(104)
  END CASE

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2011_busca_aprov_viag(l_cod_empresa)
#--------------------------------------------------#
 DEFINE l_sql_stmt            CHAR(2000),
        lr_cdv_aprov_viag_781 RECORD LIKE cdv_aprov_viag_781.*,
        l_ult_viagem          LIKE cdv_aprov_viag_781.viagem,
        l_funcionario         LIKE usuarios.nom_funcionario,
        lr_usuario_subs_cap   RECORD LIKE usuario_subs_cap.*,
        l_dat_cheg_aux        CHAR(19),
        l_dat_cheg_aux2       DATETIME YEAR TO SECOND,
        l_dat_cheg_aux3       DATETIME YEAR TO SECOND,
        l_status              SMALLINT,
        l_finalidade_viagem   LIKE cdv_solic_viag_781.finalidade_viagem,
        l_cli_atendido        LIKE clientes.cod_cliente,
        l_cli_faturado        LIKE clientes.cod_cliente,
        l_viajante            LIKE cdv_solic_viag_781.viajante,
        l_cod_empresa         LIKE empresa.cod_empresa

  DEFINE lr_consulta_ord RECORD
         aprova           CHAR(01),
         empresa          LIKE empresa.cod_empresa,
         viagem           LIKE cdv_acer_viag_781.viagem,
         controle         LIKE cdv_acer_viag_781.controle,
         valor_ad         LIKE ad_mestre.val_tot_nf,
         dat_partida      CHAR(10),
         dat_retorno      CHAR(10),
         funcionario      LIKE usuarios.nom_funcionario,
         cod_tip_despesa  DECIMAL(4,0),
         cli_atendido     CHAR(30),
         finalidade       CHAR(24),
         cli_faturado     CHAR(20),
         num_ad           DECIMAL(6,0),
         cod_nivel_autor  CHAR(02),
         cod_uni_funcio   CHAR(10)
  END RECORD

 INITIALIZE l_sql_stmt, lr_cdv_aprov_viag_781 TO NULL

 LET l_sql_stmt = " SELECT empresa, viagem, versao, linha_grade, nivel_autorid, ",
                  " unid_funcional, eh_aprovado, usuario_aprovacao, ",
                  " dat_aprovacao, hor_aprovacao, obs_aprovacao ",
                  " FROM cdv_aprov_viag_781 ",
                  " WHERE empresa = '", l_cod_empresa,"' ",
                  " AND eh_aprovado = 'N' "

 IF m_num_viagem IS NOT NULL THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED,
                     " AND  viagem = ", m_num_viagem, " "
 END IF

 LET l_sql_stmt = l_sql_stmt CLIPPED,
                  " ORDER BY viagem, versao "

 WHENEVER ERROR CONTINUE
 PREPARE var_query FROM l_sql_stmt

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_QUERY")
    RETURN FALSE
 END IF

 DECLARE cq_aprov_viag CURSOR FOR var_query
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_APROV_VIAG")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_aprov_viag INTO lr_cdv_aprov_viag_781.empresa,       lr_cdv_aprov_viag_781.viagem,
                            lr_cdv_aprov_viag_781.versao,        lr_cdv_aprov_viag_781.linha_grade,
                            lr_cdv_aprov_viag_781.nivel_autorid, lr_cdv_aprov_viag_781.unid_funcional,
                            lr_cdv_aprov_viag_781.eh_aprovado,   lr_cdv_aprov_viag_781.usuario_aprovacao,
                            lr_cdv_aprov_viag_781.dat_aprovacao, lr_cdv_aprov_viag_781.hor_aprovacao,
                            lr_cdv_aprov_viag_781.obs_aprovacao
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_aprov_viag")
       RETURN FALSE
    END IF

    IF lr_cdv_aprov_viag_781.viagem = l_ult_viagem  THEN
       CONTINUE FOREACH
    END IF
    LET l_ult_viagem = lr_cdv_aprov_viag_781.viagem

    LET lr_consulta_ord.aprova          = 'N'
    LET lr_consulta_ord.empresa         = lr_cdv_aprov_viag_781.empresa
    LET lr_consulta_ord.viagem          = lr_cdv_aprov_viag_781.viagem
    LET lr_consulta_ord.num_ad          = ''
    LET lr_consulta_ord.valor_ad        = ''
    LET lr_consulta_ord.cod_nivel_autor = lr_cdv_aprov_viag_781.nivel_autorid
    LET lr_consulta_ord.cod_uni_funcio  = lr_cdv_aprov_viag_781.unid_funcional
    LET lr_consulta_ord.cod_tip_despesa = ''

    WHENEVER ERROR CONTINUE
     SELECT controle
       INTO lr_consulta_ord.controle
       FROM cdv_solic_viag_781
      WHERE empresa = p_cod_empresa
        AND viagem  = lr_consulta_ord.viagem
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('SELECT','cdv_solic_viag_781')
       RETURN FALSE
    END IF

    IF m_ies_usu_tela = "2"  THEN

       INITIALIZE l_funcionario TO NULL

       WHENEVER ERROR CONTINUE
       DECLARE cq_usu_subst_cap2 CURSOR FOR
        SELECT *
          FROM usuario_subs_cap
         WHERE cod_empresa      = lr_consulta_ord.empresa
           AND cod_usuario_subs = p_user
           AND ies_versao_atual = "S"
           AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
           AND TODAY BETWEEN dat_ini_validade AND dat_fim_validade
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("DECLARE","cq_usu_subst_cap2")
          RETURN FALSE
       END IF

       WHENEVER ERROR CONTINUE
       FOREACH cq_usu_subst_cap2 INTO lr_usuario_subs_cap.*
       WHENEVER ERROR STOP

          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("FOREACH","cq_usu_subst_cap2")
             RETURN FALSE
          END IF

          WHENEVER ERROR CONTINUE
           SELECT *
             FROM usu_nivel_aut_cap
            WHERE cod_empresa      = lr_consulta_ord.empresa
              AND cod_usuario      = lr_usuario_subs_cap.cod_usuario
              AND ies_versao_atual = "S"
              AND ies_ativo        = "S"
              AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
          WHENEVER ERROR STOP

          IF SQLCA.SQLCODE = 0  THEN
             WHENEVER ERROR CONTINUE
              SELECT nom_funcionario
                INTO l_funcionario
                FROM usuarios
               WHERE cod_usuario = lr_usuario_subs_cap.cod_usuario
             WHENEVER ERROR CONTINUE

             IF SQLCA.SQLCODE = 0 THEN
               LET lr_consulta_ord.funcionario =  l_funcionario
             END IF
             EXIT FOREACH
          END IF
       END FOREACH
       FREE cq_usu_subst_cap2
    END IF

    WHENEVER ERROR CONTINUE
     SELECT cliente_fatur, cliente_atendido, finalidade_viagem, dat_hor_partida,
            dat_hor_retorno, viajante
       INTO l_cli_atendido, l_cli_faturado, l_finalidade_viagem,
            l_dat_cheg_aux2, l_dat_cheg_aux3, l_viajante
       FROM cdv_solic_viag_781
      WHERE empresa = lr_consulta_ord.empresa
        AND viagem  = lr_consulta_ord.viagem
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE = 0 THEN

       IF lr_consulta_ord.funcionario IS NULL
       OR lr_consulta_ord.funcionario = " " THEN
		  				  LET lr_consulta_ord.funcionario = cdv2011_busca_viajante(l_viajante)
       END IF

       LET l_dat_cheg_aux = l_dat_cheg_aux2
       LET lr_consulta_ord.dat_partida = l_dat_cheg_aux[09,10],"/",
                                         l_dat_cheg_aux[06,07],"/",
                                         l_dat_cheg_aux[01,04]

       LET l_dat_cheg_aux = l_dat_cheg_aux3
       LET lr_consulta_ord.dat_retorno = l_dat_cheg_aux[09,10],"/",
                                         l_dat_cheg_aux[06,07],"/",
                                         l_dat_cheg_aux[01,04]
       WHENEVER ERROR CONTINUE
        SELECT nom_cliente[1,30]
          INTO lr_consulta_ord.cli_atendido
          FROM clientes
         WHERE cod_cliente = l_cli_atendido
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 THEN
       END IF

       WHENEVER ERROR CONTINUE
        SELECT nom_cliente[1,30]
          INTO lr_consulta_ord.cli_faturado
          FROM clientes
         WHERE cod_cliente = l_cli_faturado
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 THEN
       END IF

       WHENEVER ERROR CONTINUE
        SELECT des_finalidade
          INTO lr_consulta_ord.finalidade
          FROM cdv_finalidade_781
         WHERE finalidade = l_finalidade_viagem
       WHENEVER ERROR STOP

       IF SQLCA.SQLCODE <> 0 THEN
          CALL log003_err_sql('SELECT','cdv_finalidade_781')
          RETURN FALSE
       END IF
    END IF

    WHENEVER ERROR CONTINUE
    INSERT INTO t_consulta_ord VALUES (lr_consulta_ord.*)
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","t_consulta_ord")
       RETURN FALSE
    END IF

 END FOREACH
 FREE cq_aprov_viag

 RETURN TRUE
 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION cdv2011_gera_email_viag(l_funcao, l_ind, l_cod_nivel_autor)
#--------------------------------------------------------------------#
  DEFINE l_funcao              SMALLINT,
         l_min_nivel_autor     LIKE aprov_necessaria.cod_nivel_autor,
         l_cod_uni_funcio      LIKE aprov_necessaria.cod_uni_funcio,
         l_email               LIKE usuarios.e_mail,
         l_val_adto_viagem     LIKE cdv_adto_viagem.val_adto_viagem,
         l_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
         l_matricula_aprovador LIKE cdv_info_viajante.matricula,
         l_ies_tip_autor       LIKE nivel_autor_cap.ies_tip_autor,
         l_cod_usuario         LIKE usuario_subs_cap.cod_usuario,
         l_cod_nivel_autor     LIKE aprov_necessaria.cod_nivel_autor,
         l_ind                 SMALLINT

  IF l_funcao = 1 THEN #Adiantamentos
     #Verifica se existe mais algum nível para aprovação para enviar e-mail
     WHENEVER ERROR CONTINUE
      SELECT MIN(nivel_autorid)
        INTO l_min_nivel_autor
        FROM cdv_aprov_viag_781
       WHERE empresa       = ma_reg_aprov[l_ind].cod_empresa
         AND viagem        = ma_reg_aprov[l_ind].viagem
         AND nivel_autorid > l_cod_nivel_autor
         AND eh_aprovado    = 'N'
     WHENEVER ERROR STOP

     IF SQLCA.SQLCODE = 0 AND l_min_nivel_autor IS NOT NULL THEN
        WHENEVER ERROR CONTINUE
         SELECT UNIQUE unid_funcional
           INTO l_cod_uni_funcio
           FROM cdv_aprov_viag_781
          WHERE empresa       = ma_reg_aprov[l_ind].cod_empresa
            AND viagem        = ma_reg_aprov[l_ind].viagem
            AND nivel_autorid = l_min_nivel_autor
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql('SELEÇÃO','cdv_aprov_viag_781')
            RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
         SELECT ies_tip_autor
           INTO l_ies_tip_autor
           FROM nivel_autor_cap
          WHERE cod_empresa     = ma_reg_aprov[l_ind].cod_empresa
            AND cod_nivel_autor = l_min_nivel_autor
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
            CALL log0030_mensagem("Nível de autoridade não cadastrado.",'info')
            RETURN FALSE
        END IF

        IF l_ies_tip_autor = 'H' THEN
           WHENEVER ERROR CONTINUE
            SELECT cod_usuario
              INTO l_cod_usuario
              FROM usu_nivel_aut_cap
             WHERE cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
               AND cod_uni_funcio   = l_cod_uni_funcio
               AND cod_nivel_autor  = l_min_nivel_autor
               AND ies_versao_atual = 'S'
               AND ies_ativo        = 'S'
           WHENEVER ERROR STOP
        ELSE
            # Genérico não olha a Unidade Funcional
           WHENEVER ERROR CONTINUE
            SELECT cod_usuario
              INTO l_cod_usuario
              FROM usu_nivel_aut_cap
             WHERE cod_empresa      = ma_reg_aprov[l_ind].cod_empresa
               AND cod_nivel_autor  = l_min_nivel_autor
               AND ies_versao_atual = 'S'
               AND ies_ativo        = 'S'
           WHENEVER ERROR STOP
        END IF

        IF SQLCA.SQLCODE = 0 THEN
           WHENEVER ERROR CONTINUE
            SELECT e_mail
              INTO l_email
              FROM usuarios
             WHERE cod_usuario = l_cod_usuario
           WHENEVER ERROR STOP

           IF SQLCA.SQLCODE = 0 THEN
              WHENEVER ERROR CONTINUE
               INSERT INTO t_envio_email VALUES (NULL, ma_reg_aprov[l_ind].viagem, l_email, l_min_nivel_autor)
              WHENEVER ERROR STOP

              IF SQLCA.SQLCODE <> 0 THEN
                 CALL log003_err_sql('INCLUSÃO','t_envio_email')
                 RETURN FALSE
              END IF
           END IF
        END IF
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2011_exibe_despesa_km(l_arr_curr)
#--------------------------------------------#
 DEFINE lr_cdv_despesa_km_781 RECORD LIKE cdv_despesa_km_781.*

 DEFINE l_viajante LIKE cdv_solic_viag_781.viajante,
        l_arr_curr SMALLINT,
        l_status   SMALLINT,
        l_ind      SMALLINT

 DEFINE lr_dados_tela RECORD
    empresa  LIKE cdv_solic_viag_781.empresa,
    controle LIKE cdv_solic_viag_781.controle,
    viagem   LIKE cdv_solic_viag_781.viagem,
    viajante LIKE funcionario.nom_funcionario
 END RECORD

 DEFINE la_array_desp_km ARRAY[999] OF RECORD
    dat_despesa_km LIKE cdv_despesa_km_781.dat_despesa_km,
    des_ativ       LIKE cdv_ativ_781.des_ativ,
    km_inicial     LIKE cdv_despesa_km_781.km_inicial,
    km_final       LIKE cdv_despesa_km_781.km_final,
    qtd_km         LIKE cdv_despesa_km_781.qtd_km,
    trajeto        LIKE cdv_despesa_km_781.trajeto,
    val_km         LIKE cdv_despesa_km_781.val_km
 END RECORD,
 l_tipo_veiculo    CHAR(20),
 l_placa           LIKE cdv_despesa_km_781.placa

 CALL log006_exibe_teclas("01 02 07", p_versao)
 CALL log130_procura_caminho("CDV20112") RETURNING m_comand_cap
 OPEN WINDOW w_cdv20112 AT 2,2  WITH FORM m_comand_cap
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


 INITIALIZE lr_dados_tela TO NULL

 LET lr_dados_tela.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
 LET lr_dados_tela.viagem  = ma_reg_aprov[l_arr_curr].viagem

 WHENEVER ERROR CONTINUE
 SELECT cdv_solic_viag_781.controle,
        cdv_solic_viag_781.viajante
   INTO lr_dados_tela.controle,
        l_viajante
   FROM cdv_solic_viag_781
  WHERE cdv_solic_viag_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_solic_viag_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
 END IF

 LET lr_dados_tela.viajante = cdv2011_busca_viajante(l_viajante)

 WHENEVER ERROR CONTINUE
 DECLARE cl_cdv_despesa_km_781 CURSOR FOR
 SELECT cdv_despesa_km_781.*
   FROM cdv_despesa_km_781
  WHERE cdv_despesa_km_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_despesa_km_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
  ORDER BY cdv_despesa_km_781.seq_despesa_km
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CL_CDV_DESPESA_KM_781")
 END IF

 LET l_ind = 0

 INITIALIZE la_array_desp_km TO NULL

 WHENEVER ERROR CONTINUE
 FOREACH cl_cdv_despesa_km_781 INTO lr_cdv_despesa_km_781.*
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_CDV_DESPESA_KM_781")
    END IF

    LET l_ind = l_ind + 1

    LET la_array_desp_km[l_ind].dat_despesa_km = lr_cdv_despesa_km_781.dat_despesa_km
    LET la_array_desp_km[l_ind].km_inicial     = lr_cdv_despesa_km_781.km_inicial
    LET la_array_desp_km[l_ind].km_final       = lr_cdv_despesa_km_781.km_final
    LET la_array_desp_km[l_ind].qtd_km         = lr_cdv_despesa_km_781.qtd_km
    LET la_array_desp_km[l_ind].trajeto        = lr_cdv_despesa_km_781.trajeto
    LET la_array_desp_km[l_ind].val_km         = lr_cdv_despesa_km_781.val_km

    CALL cdv2011_busca_dados_despesa_km(ma_reg_aprov[l_arr_curr].cod_empresa, ma_reg_aprov[l_arr_curr].viagem, lr_cdv_despesa_km_781.tip_despesa_viagem, lr_cdv_despesa_km_781.ativ_km)
         RETURNING l_tipo_veiculo, l_placa

    CALL cdv2011_busca_des_ativ(lr_cdv_despesa_km_781.ativ_km)
         RETURNING l_status, la_array_desp_km[l_ind].des_ativ

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    IF l_ind = 999 THEN
       CALL log0030_mensagem("Estouro de ARRAY.","exclamation")
       EXIT FOREACH
    END IF

 END FOREACH

 DISPLAY BY NAME lr_dados_tela.*
 DISPLAY l_tipo_veiculo, l_placa TO tipo_veiculo, placa

 IF l_ind > 0 THEN
    CALL set_count(l_ind)
    DISPLAY ARRAY la_array_desp_km TO sr_array_desp_km.*
 ELSE
    CALL log0030_mensagem("Não existem dados para serem consultados.","exclamation")
 END IF

 CLOSE WINDOW w_cdv20112

 END FUNCTION

#--------------------------------------#
 FUNCTION cdv2011_busca_des_ativ(l_ativ)
#--------------------------------------#
 DEFINE l_ativ      LIKE cdv_ativ_781.ativ,
        l_des_ativ  LIKE cdv_ativ_781.des_ativ

 WHENEVER ERROR CONTINUE
  SELECT cdv_ativ_781.des_ativ
    INTO l_des_ativ
    FROM cdv_ativ_781
   WHERE cdv_ativ_781.ativ = l_ativ
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND
    sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("SELECT","CDV_ATIV_781")
    RETURN FALSE, ""
 END IF

 RETURN TRUE, l_des_ativ

 END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2011_busca_viajante(l_viajante)
#----------------------------------------------------#
 DEFINE l_viajante     LIKE funcionario.num_matricula,
        l_nom_viajante LIKE funcionario.nom_funcionario,
        l_cod_funcio      LIKE cdv_fornecedor_fun.cod_funcio,
        l_cod_fornecedor  LIKE fornecedor.cod_fornecedor

  LET l_cod_funcio = l_viajante

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     WHENEVER ERROR CONTINUE
     SELECT raz_social
       INTO l_nom_viajante
       FROM fornecedor
      WHERE cod_fornecedor = l_cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_nom_viajante = NULL
     END IF
  END IF

  RETURN l_nom_viajante

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2011_exibe_despesa_hor(l_arr_curr)
#---------------------------------------------#
 DEFINE lr_cdv_apont_hor_781 RECORD LIKE cdv_apont_hor_781.*

 DEFINE l_viajante LIKE cdv_solic_viag_781.viajante,
        l_arr_curr SMALLINT,
        l_status   SMALLINT,
        l_ind      SMALLINT

 DEFINE lr_dados_tela RECORD
    empresa  LIKE cdv_solic_viag_781.empresa,
    controle LIKE cdv_solic_viag_781.controle,
    viagem   LIKE cdv_solic_viag_781.viagem,
    viajante LIKE funcionario.nom_funcionario
 END RECORD

 DEFINE la_array_desp_hor ARRAY[999] OF RECORD
    dat_apont_hor LIKE cdv_apont_hor_781.dat_apont_hor,
    des_ativ      LIKE cdv_ativ_781.des_ativ,
    hor_inicial   LIKE cdv_apont_hor_781.hor_inicial,
    hor_final     LIKE cdv_apont_hor_781.hor_final,
    hor_diurnas   LIKE cdv_apont_hor_781.hor_diurnas,
    hor_noturnas  LIKE cdv_apont_hor_781.hor_noturnas,
    des_motivo    LIKE cdv_motivo_hor_781.des_motivo
 END RECORD

 CALL log006_exibe_teclas("01 02 07", p_versao)
 CALL log130_procura_caminho("CDV20113") RETURNING m_comand_cap
 OPEN WINDOW w_cdv20113 AT 2,2  WITH FORM m_comand_cap
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


 INITIALIZE lr_dados_tela TO NULL

 LET lr_dados_tela.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
 LET lr_dados_tela.viagem  = ma_reg_aprov[l_arr_curr].viagem

 WHENEVER ERROR CONTINUE
 SELECT cdv_solic_viag_781.controle,
        cdv_solic_viag_781.viajante
   INTO lr_dados_tela.controle,
        l_viajante
   FROM cdv_solic_viag_781
  WHERE cdv_solic_viag_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_solic_viag_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
 END IF

 LET lr_dados_tela.viajante = cdv2011_busca_viajante(l_viajante)

 WHENEVER ERROR CONTINUE
 DECLARE cl_cdv_apont_hor_781 CURSOR FOR
 SELECT cdv_apont_hor_781.*
   FROM cdv_apont_hor_781
  WHERE cdv_apont_hor_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_apont_hor_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
  ORDER BY cdv_apont_hor_781.seq_apont_hor
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CL_CDV_APONT_HOR_781")
 END IF

 LET l_ind = 0

 INITIALIZE la_array_desp_hor TO NULL

 WHENEVER ERROR CONTINUE
 FOREACH cl_cdv_apont_hor_781 INTO lr_cdv_apont_hor_781.*
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_cdv_apont_hor_781")
    END IF

    LET l_ind = l_ind + 1

    LET la_array_desp_hor[l_ind].dat_apont_hor = lr_cdv_apont_hor_781.dat_apont_hor
    LET la_array_desp_hor[l_ind].hor_inicial   = lr_cdv_apont_hor_781.hor_inicial
    LET la_array_desp_hor[l_ind].hor_final     = lr_cdv_apont_hor_781.hor_final
    LET la_array_desp_hor[l_ind].hor_diurnas   = lr_cdv_apont_hor_781.hor_diurnas
    LET la_array_desp_hor[l_ind].hor_noturnas  = lr_cdv_apont_hor_781.hor_noturnas

    CALL cdv2011_busca_des_ativ(lr_cdv_apont_hor_781.ativ)
         RETURNING l_status, la_array_desp_hor[l_ind].des_ativ

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    CALL cdv2011_busca_des_motivo(lr_cdv_apont_hor_781.motivo)
         RETURNING l_status, la_array_desp_hor[l_ind].des_motivo

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    IF l_ind = 999 THEN
       CALL log0030_mensagem("Estouro de ARRAY.","exclamation")
       EXIT FOREACH
    END IF

 END FOREACH

 DISPLAY BY NAME lr_dados_tela.*

 IF l_ind > 0 THEN
    CALL set_count(l_ind)
    DISPLAY ARRAY la_array_desp_hor TO sr_array_desp_hor.*
 ELSE
    CALL log0030_mensagem("Não existem dados para serem consultados.","exclamation")
 END IF

 CLOSE WINDOW w_cdv20113

 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2011_busca_des_motivo(l_motivo)
#------------------------------------------#
 DEFINE l_motivo      LIKE cdv_motivo_hor_781.motivo,
        l_des_motivo  LIKE cdv_motivo_hor_781.des_motivo

 WHENEVER ERROR CONTINUE
 SELECT cdv_motivo_hor_781.des_motivo
   INTO l_des_motivo
   FROM cdv_motivo_hor_781
  WHERE cdv_motivo_hor_781.motivo = l_motivo
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND
    sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("SELECT","CDV_MOTIVO_HOR_781")
    RETURN FALSE, ""
 END IF

 RETURN TRUE, l_des_motivo

 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2011_exibe_despesa_terc(l_arr_curr)
#----------------------------------------------#
 DEFINE lr_cdv_desp_terc_781 RECORD LIKE cdv_desp_terc_781.*

 DEFINE l_viajante LIKE cdv_solic_viag_781.viajante,
        l_arr_curr SMALLINT,
        l_status   SMALLINT,
        l_ind      SMALLINT

 DEFINE lr_dados_tela RECORD
    empresa  LIKE cdv_solic_viag_781.empresa,
    controle LIKE cdv_solic_viag_781.controle,
    viagem   LIKE cdv_solic_viag_781.viagem,
    viajante LIKE funcionario.nom_funcionario
 END RECORD

 DEFINE la_array_desp_terc ARRAY[999] OF RECORD
    dat_inclusao      LIKE cdv_desp_terc_781.dat_inclusao,
    des_ativ          LIKE cdv_ativ_781.des_ativ,
    des_tdesp_viagem  LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
    val_desp_terceiro LIKE cdv_desp_terc_781.val_desp_terceiro,
    dat_vencto        LIKE cdv_desp_terc_781.dat_vencto,
    eh_reembolso      LIKE cdv_tdesp_viag_781.eh_reembolso,
    raz_social        LIKE fornecedor.raz_social,
    observacao        LIKE cdv_desp_terc_781.observacao
 END RECORD

 CALL log006_exibe_teclas("01 02 07", p_versao)
 CALL log130_procura_caminho("CDV20114") RETURNING m_comand_cap
 OPEN WINDOW w_cdv20114 AT 2,2  WITH FORM m_comand_cap
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


 INITIALIZE lr_dados_tela TO NULL

 LET lr_dados_tela.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
 LET lr_dados_tela.viagem  = ma_reg_aprov[l_arr_curr].viagem

 WHENEVER ERROR CONTINUE
 SELECT cdv_solic_viag_781.controle,
        cdv_solic_viag_781.viajante
   INTO lr_dados_tela.controle,
        l_viajante
   FROM cdv_solic_viag_781
  WHERE cdv_solic_viag_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_solic_viag_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
 END IF

 LET lr_dados_tela.viajante = cdv2011_busca_viajante(l_viajante)

 WHENEVER ERROR CONTINUE
 DECLARE cl_cdv_desp_terc_781 CURSOR FOR
 SELECT cdv_desp_terc_781.*
   FROM cdv_desp_terc_781
  WHERE cdv_desp_terc_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_desp_terc_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
  ORDER BY cdv_desp_terc_781.seq_desp_terceiro
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CL_CDV_DESP_TERC_781")
 END IF

 LET l_ind = 0

 INITIALIZE la_array_desp_terc TO NULL

 WHENEVER ERROR CONTINUE
 FOREACH cl_cdv_desp_terc_781 INTO lr_cdv_desp_terc_781.*
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_CDV_DESP_TERC_781")
    END IF

    LET l_ind = l_ind + 1

    LET la_array_desp_terc[l_ind].dat_inclusao      = lr_cdv_desp_terc_781.dat_inclusao
    LET la_array_desp_terc[l_ind].val_desp_terceiro = lr_cdv_desp_terc_781.val_desp_terceiro
    LET la_array_desp_terc[l_ind].dat_vencto        = lr_cdv_desp_terc_781.dat_vencto
    LET la_array_desp_terc[l_ind].observacao        = lr_cdv_desp_terc_781.observacao
    LET la_array_desp_terc[l_ind].raz_social        = cdv2011_busca_raz_social(lr_cdv_desp_terc_781.fornecedor)

    CALL cdv2011_busca_des_ativ(lr_cdv_desp_terc_781.ativ)
         RETURNING l_status, la_array_desp_terc[l_ind].des_ativ

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    CALL cdv2011_busca_tdesp_viag_781(lr_cdv_desp_terc_781.empresa,
                                      lr_cdv_desp_terc_781.tip_despesa,
                                      lr_cdv_desp_terc_781.ativ)
         RETURNING l_status,
                   la_array_desp_terc[l_ind].des_tdesp_viagem,
                   la_array_desp_terc[l_ind].eh_reembolso

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    IF l_ind = 999 THEN
       CALL log0030_mensagem("Estouro de ARRAY.","exclamation")
       EXIT FOREACH
    END IF

 END FOREACH

 DISPLAY BY NAME lr_dados_tela.*

 IF l_ind > 0 THEN
    CALL set_count(l_ind)
    DISPLAY ARRAY la_array_desp_terc TO sr_array_desp_terc.*
 ELSE
    CALL log0030_mensagem("Não existem dados para serem consultados.","exclamation")
 END IF

 CLOSE WINDOW w_cdv20114

 END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2011_busca_tdesp_viag_781(l_empresa,
                                       l_tip_despesa,
                                       l_ativ)
#---------------------------------------------------#
 DEFINE l_empresa           LIKE cdv_tdesp_viag_781.empresa,
        l_tip_despesa       LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_ativ              LIKE cdv_tdesp_viag_781.ativ,
        l_des_tdesp_viagem  LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
        l_eh_reembolso      LIKE cdv_tdesp_viag_781.eh_reembolso

 WHENEVER ERROR CONTINUE
 SELECT cdv_tdesp_viag_781.des_tdesp_viagem,
        cdv_tdesp_viag_781.eh_reembolso
   INTO l_des_tdesp_viagem,
        l_eh_reembolso
   FROM cdv_tdesp_viag_781
  WHERE cdv_tdesp_viag_781.empresa            = l_empresa
    AND cdv_tdesp_viag_781.tip_despesa_viagem = l_tip_despesa
    AND cdv_tdesp_viag_781.ativ               = l_ativ
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND
    sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("SELECT","CDV_TDESP_VIAG_781")
    RETURN FALSE, "", ""
 END IF

 RETURN TRUE, l_des_tdesp_viagem, l_eh_reembolso

 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2011_exibe_despesas(l_arr_curr)
#----------------------------------------------#
 DEFINE lr_cdv_desp_urb_781 RECORD LIKE cdv_desp_urb_781.*

 DEFINE l_viajante LIKE cdv_solic_viag_781.viajante,
        l_arr_curr SMALLINT,
        l_status   SMALLINT,
        l_ind      SMALLINT

 DEFINE lr_dados_tela RECORD
    empresa  LIKE cdv_solic_viag_781.empresa,
    controle LIKE cdv_solic_viag_781.controle,
    viagem   LIKE cdv_solic_viag_781.viagem,
    viajante LIKE funcionario.nom_funcionario
 END RECORD

 DEFINE la_array_desp ARRAY[999] OF RECORD
    dat_despesa_urbana LIKE cdv_desp_urb_781.dat_despesa_urbana,
    des_ativ           LIKE cdv_ativ_781.des_ativ,
    des_tdesp_viagem   LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
    val_despesa_urbana LIKE cdv_desp_urb_781.val_despesa_urbana,
    eh_reembolso       LIKE cdv_tdesp_viag_781.eh_reembolso
 END RECORD

 CALL log006_exibe_teclas("01 02 07", p_versao)
 CALL log130_procura_caminho("CDV20111") RETURNING m_comand_cap
 OPEN WINDOW w_cdv20111 AT 2,2  WITH FORM m_comand_cap
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


 INITIALIZE lr_dados_tela TO NULL

 LET lr_dados_tela.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
 LET lr_dados_tela.viagem  = ma_reg_aprov[l_arr_curr].viagem

 WHENEVER ERROR CONTINUE
 SELECT cdv_solic_viag_781.controle,
        cdv_solic_viag_781.viajante
   INTO lr_dados_tela.controle,
        l_viajante
   FROM cdv_solic_viag_781
  WHERE cdv_solic_viag_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_solic_viag_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
 END IF

 LET lr_dados_tela.viajante = cdv2011_busca_viajante(l_viajante)

 WHENEVER ERROR CONTINUE
 DECLARE cl_cdv_desp_urb_781 CURSOR FOR
 SELECT cdv_desp_urb_781.*
   FROM cdv_desp_urb_781
  WHERE cdv_desp_urb_781.empresa = ma_reg_aprov[l_arr_curr].cod_empresa
    AND cdv_desp_urb_781.viagem  = ma_reg_aprov[l_arr_curr].viagem
  ORDER BY cdv_desp_urb_781.seq_despesa_urbana
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CL_cdv_desp_urb_781")
 END IF

 LET l_ind = 0

 INITIALIZE la_array_desp TO NULL

 WHENEVER ERROR CONTINUE
 FOREACH cl_cdv_desp_urb_781 INTO lr_cdv_desp_urb_781.*
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_cdv_desp_urb_781")
    END IF

    LET l_ind = l_ind + 1

    LET la_array_desp[l_ind].dat_despesa_urbana = lr_cdv_desp_urb_781.dat_despesa_urbana
    LET la_array_desp[l_ind].val_despesa_urbana = lr_cdv_desp_urb_781.val_despesa_urbana

    CALL cdv2011_busca_des_ativ(lr_cdv_desp_urb_781.ativ)
         RETURNING l_status, la_array_desp[l_ind].des_ativ

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    CALL cdv2011_busca_tdesp_viag_781(lr_cdv_desp_urb_781.empresa,
                                      lr_cdv_desp_urb_781.tip_despesa_viagem,
                                      lr_cdv_desp_urb_781.ativ)
         RETURNING l_status,
                   la_array_desp[l_ind].des_tdesp_viagem,
                   la_array_desp[l_ind].eh_reembolso

    IF NOT l_status THEN
       EXIT FOREACH
    END IF

    IF l_ind = 999 THEN
       CALL log0030_mensagem("Estouro de ARRAY.","exclamation")
       EXIT FOREACH
    END IF

 END FOREACH

 DISPLAY BY NAME lr_dados_tela.*

 IF l_ind > 0 THEN
    CALL set_count(l_ind)
    DISPLAY ARRAY la_array_desp TO sr_array_desp.*
 ELSE
    CALL log0030_mensagem("Não existem dados para serem consultados.","exclamation")
 END IF

 CLOSE WINDOW w_cdv20111

 END FUNCTION

#---------------------------------------------------------------------------------------#
 FUNCTION cdv2011_busca_dados_despesa_km(l_cod_empresa, l_viagem, l_tipo_despesa, l_ativ)
#---------------------------------------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_solic_viag_781.viagem,
        l_tipo_despesa  LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_ativ          LIKE cdv_ativ_781.ativ,
        l_tipo_veiculo  CHAR(20),
        l_placa         LIKE cdv_despesa_km_781.placa

 INITIALIZE l_tipo_veiculo, l_placa TO NULL

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE placa
   INTO l_placa
   FROM cdv_despesa_km_781
  WHERE empresa = l_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_placa TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE des_tdesp_viagem
   INTO l_tipo_veiculo
   FROM cdv_tdesp_viag_781
  WHERE empresa             = l_cod_empresa
    AND tip_despesa_viagem  = l_tipo_despesa
    AND ativ                = l_ativ
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_tipo_veiculo TO NULL
 END IF

 RETURN l_tipo_veiculo, l_placa
 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2011_busca_dados_acer(l_cod_empresa, l_viagem)
#---------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_solic_viag_781.viagem,
        l_filial        LIKE empresa.den_reduz,
        l_cc_viajante   LIKE cdv_acer_viag_781.cc_viajante,
        l_viajante      LIKE cdv_acer_viag_781.viajante,
        l_usuario_logix LIKE usuarios.cod_usuario,
        l_nom_usuario   LIKE usuarios.nom_funcionario

 WHENEVER ERROR CONTINUE
 SELECT empresa.den_reduz, cdv_acer_viag_781.cc_viajante, cdv_acer_viag_781.viajante
   INTO l_filial, l_cc_viajante, l_viajante
   FROM cdv_acer_viag_781, empresa
  WHERE cdv_acer_viag_781.empresa         = l_cod_empresa
    AND cdv_acer_viag_781.viagem          = l_viagem
    AND cdv_acer_viag_781.filial_atendida = empresa.cod_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","cdv_acer_viag_781")
 END IF

 LET l_nom_usuario = cdv2011_busca_viajante(l_viajante)

 RETURN l_filial, l_nom_usuario, l_cc_viajante
 END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2011_busca_qtd_km(l_cod_empresa, l_viagem)
#-----------------------------------------------------#

 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_acer_viag_781.viagem,
        l_qtd_km        DECIMAL(13,0)

 LET l_qtd_km = 0

 WHENEVER ERROR CONTINUE
 SELECT SUM(cdv_despesa_km_781.qtd_km)
   INTO l_qtd_km
   FROM cdv_despesa_km_781, cdv_tdesp_viag_781
  WHERE cdv_despesa_km_781.empresa            = l_cod_empresa
    AND cdv_despesa_km_781.viagem             = l_viagem
    AND cdv_tdesp_viag_781.empresa            = l_cod_empresa
    AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
    AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_qtd_km = 0
 END IF

 IF l_qtd_km IS NULL THEN
    LET l_qtd_km = 0
 END IF

 RETURN l_qtd_km
 END FUNCTION


#------------------------------------------------------#
 FUNCTION cdv2011_busca_qtd_hor(l_cod_empresa, l_viagem)
#------------------------------------------------------#
  DEFINE l_cod_empresa      LIKE empresa.cod_empresa,
         l_viagem           LIKE cdv_acer_viag_781.viagem,
         l_qtd_hor_semanal  DECIMAL(17,2),
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
      AND td.grp_despesa_viagem = 5
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','qtd-hor/td')
     RETURN l_horas_total
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
     CALL cdv2011_retorna_tempo(l_horas, l_minutos, l_segundos)
     RETURNING l_horas, l_minutos, l_segundos
  END IF

  LET l_horas_total = l_horas  USING "&&&", ":",
                      l_minutos USING "&&", ":",
                      l_segundos USING "&&"

  IF l_horas_total IS NULL THEN
     LET l_horas_total = '00:00:00'
  END IF

  RETURN l_horas_total

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2011_retorna_tempo(l_horas, l_minutos, l_segundos)
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

#-------------------------------------------------------#
 FUNCTION cdv2011_busca_val_desp(l_cod_empresa, l_viagem)
#-------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_acer_viag_781.viagem,
        l_valor         DECIMAL(17,2)

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_despesa_urbana)
   INTO l_valor
   FROM cdv_desp_urb_781, cdv_tdesp_viag_781
 WHERE cdv_desp_urb_781.empresa              = l_cod_empresa
   AND cdv_desp_urb_781.viagem               = l_viagem
   AND cdv_tdesp_viag_781.empresa            = l_cod_empresa
   AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_urb_781.tip_despesa_viagem
   AND cdv_tdesp_viag_781.ativ               = cdv_desp_urb_781.ativ
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_valor = 0
 END IF

 IF l_valor IS NULL THEN
    LET l_valor = 0
 END IF

 RETURN l_valor
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2011_busca_val_terc(l_cod_empresa, l_viagem)
#-------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_acer_viag_781.viagem,
        l_valor_terc    DECIMAL(17,2)

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_desp_terceiro)
   INTO l_valor_terc
   FROM cdv_desp_terc_781, cdv_tdesp_viag_781
  WHERE cdv_desp_terc_781.empresa             = l_cod_empresa
    AND cdv_desp_terc_781.viagem              = l_viagem
    AND cdv_tdesp_viag_781.empresa            = l_cod_empresa
    AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_terc_781.tip_despesa
    AND cdv_tdesp_viag_781.ativ               = cdv_desp_terc_781.ativ
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_valor_terc = 0
 END IF

 IF l_valor_terc IS NULL THEN
    LET l_valor_terc = 0
 END IF

 RETURN l_valor_terc
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION cdv2011_busca_val_adto(l_cod_empresa, l_viagem)
#-------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_viagem        LIKE cdv_acer_viag_781.viagem,
        l_valor_adto    DECIMAL(17,2)

 WHENEVER ERROR CONTINUE
 SELECT SUM(val_adto_viagem)
   INTO l_valor_adto
   FROM cdv_solic_adto_781
  WHERE empresa   = l_cod_empresa
    AND viagem    = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_valor_adto = 0
 END IF

 IF l_valor_adto IS NULL THEN
    LET l_valor_adto = 0
 END IF

 RETURN l_valor_adto
 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2011_busca_raz_social(l_fornecedor)
#----------------------------------------------#

 DEFINE l_fornecedor   LIKE fornecedor.cod_fornecedor,
        l_raz_social   LIKE fornecedor.raz_social

 WHENEVER ERROR CONTINUE
 SELECT raz_social
   INTO l_raz_social
   FROM fornecedor
  WHERE cod_fornecedor = l_fornecedor
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_raz_social TO NULL
 END IF

 RETURN l_raz_social
 END FUNCTION


#----------------------------------------------------------#
 FUNCTION cdv2011_busca_data_hora(l_cod_empresa1, l_viagem1,
                                  l_cod_empresa2, l_viagem2,
                                  l_cod_empresa3, l_viagem3)
#----------------------------------------------------------#

 DEFINE l_cod_empresa1   LIKE cdv_acer_viag_781.empresa,
        l_viagem1        LIKE cdv_acer_viag_781.viagem,
        l_cod_empresa2   LIKE cdv_acer_viag_781.empresa,
        l_viagem2        LIKE cdv_acer_viag_781.viagem,
        l_cod_empresa3   LIKE cdv_acer_viag_781.empresa,
        l_viagem3        LIKE cdv_acer_viag_781.viagem

 DEFINE l_partida1       LIKE cdv_solic_viag_781.dat_hor_partida,
        l_partida2       LIKE cdv_solic_viag_781.dat_hor_partida,
        l_partida3       LIKE cdv_solic_viag_781.dat_hor_partida,
        l_retorno1       LIKE cdv_solic_viag_781.dat_hor_retorno,
        l_retorno2       LIKE cdv_solic_viag_781.dat_hor_retorno,
        l_retorno3       LIKE cdv_solic_viag_781.dat_hor_retorno

 INITIALIZE l_partida1, l_partida2, l_partida3,
            l_retorno1, l_retorno2, l_retorno3 TO NULL

 WHENEVER ERROR CONTINUE
 SELECT dat_hor_partida, dat_hor_retorno
   INTO l_partida1,      l_retorno1
   FROM cdv_acer_viag_781
  WHERE empresa = l_cod_empresa1
    AND viagem  = l_viagem1
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_partida1, l_retorno1 TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT dat_hor_partida, dat_hor_retorno
   INTO l_partida2,      l_retorno2
   FROM cdv_acer_viag_781
  WHERE empresa = l_cod_empresa2
    AND viagem  = l_viagem2
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_partida2, l_retorno2 TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT dat_hor_partida, dat_hor_retorno
   INTO l_partida3,      l_retorno3
   FROM cdv_acer_viag_781
  WHERE empresa = l_cod_empresa3
    AND viagem  = l_viagem3
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_partida3, l_retorno3 TO NULL
 END IF

 RETURN l_partida1, l_retorno1,
        l_partida2, l_retorno2,
        l_partida3, l_retorno3
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2011_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2011.4gl $|$Revision: 14 $|$Date: 29/05/12 15:51 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION