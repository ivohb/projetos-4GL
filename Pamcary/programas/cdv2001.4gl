###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2001                                               #
# OBJETIVO: MANUTENCAO DA TABELA CDV_SOLIC_VIAG_781               #
# AUTOR...: ARLINDO CARLESSO                                      #
# DATA....: 06/07/2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_nom_arquivo       CHAR (100),
         p_user1             CHAR(08)

  DEFINE p_ies_impressao     CHAR(001),
         g_ies_ambiente      CHAR(001),
         g_ies_grafico       SMALLINT

  DEFINE p_versao            CHAR(018)

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

END GLOBALS

  DEFINE m_consulta_ativa               SMALLINT
  DEFINE m_ies_cons                     SMALLINT
  DEFINE m_modifica_inclusao            SMALLINT
  DEFINE m_den_empresa                  LIKE empresa.den_empresa
  DEFINE m_sql_stmt                     CHAR(1200),
         m_where_clause1                CHAR(400),
         m_where_clause2                CHAR(400),
         m_controle_minimo              LIKE cdv_acer_viag_781.controle
  DEFINE m_caminho                      CHAR(150)
  DEFINE m_comando                      CHAR(080)
  DEFINE m_camh_help_cdv2001            CHAR(150),
         m_empresa_atendida_pamcary     LIKE empresa.cod_empresa,
         m_filial_atendida_pamcary      LIKE empresa.cod_empresa

  DEFINE mr_tela  RECORD
                     empresa              LIKE cdv_solic_viag_781.empresa,
                     viagem               LIKE cdv_solic_viag_781.viagem,
                     controle             LIKE cdv_solic_viag_781.controle,
                     dat_hr_emis_solic    DATE,
                     hora                 DATETIME HOUR TO SECOND,
                     viajante             LIKE cdv_solic_viag_781.viajante,
                     finalidade_viagem    LIKE cdv_solic_viag_781.finalidade_viagem,
                     cc_viajante          LIKE cdv_solic_viag_781.cc_viajante,
                     cc_debitar           LIKE cdv_solic_viag_781.cc_debitar,
                     cliente_atendido     LIKE cdv_solic_viag_781.cliente_atendido,
                     cliente_fatur        LIKE cdv_solic_viag_781.cliente_fatur,
                     empresa_atendida     LIKE cdv_solic_viag_781.empresa_atendida,
                     den_empresa_atendida LIKE empresa.den_empresa,
                     filial_atendida      LIKE cdv_solic_viag_781.filial_atendida,
                     den_filial_atendida  LIKE empresa.den_empresa,
                     trajeto_principal    LIKE cdv_solic_viag_781.trajeto_principal,
                     dat_hor_partida      DATE,
                     hora_partida         DATETIME HOUR TO SECOND,
                     dat_hor_retorno      DATE,
                     hora_retorno         DATETIME HOUR TO SECOND,
                     motivo_viagem        LIKE cdv_solic_viag_781.motivo_viagem,
                     ies_solic_adto       CHAR(01),
                     val_adto_viagem      LIKE cdv_solic_adto_781.val_adto_viagem,
                     forma_adto_viagem    LIKE cdv_solic_adto_781.forma_adto_viagem,
                     banco                LIKE cdv_solic_adto_781.banco,
                     agencia              LIKE cdv_solic_adto_781.agencia,
                     cta_corrente         LIKE cdv_solic_adto_781.cta_corrente,
                     ad_adiantamento      LIKE ad_mestre.num_ad,
                     ap_adiantamento      LIKE ad_mestre.num_ad
                  END RECORD

  DEFINE mr_telar  RECORD
                     empresa              LIKE cdv_solic_viag_781.empresa,
                     viagem               LIKE cdv_solic_viag_781.viagem,
                     controle             LIKE cdv_solic_viag_781.controle,
                     dat_hr_emis_solic    DATE,
                     hora                 DATETIME HOUR TO SECOND,
                     viajante             LIKE cdv_solic_viag_781.viajante,
                     finalidade_viagem    LIKE cdv_solic_viag_781.finalidade_viagem,
                     cc_viajante          LIKE cdv_solic_viag_781.cc_viajante,
                     cc_debitar           LIKE cdv_solic_viag_781.cc_debitar,
                     cliente_atendido     LIKE cdv_solic_viag_781.cliente_atendido,
                     cliente_fatur        LIKE cdv_solic_viag_781.cliente_fatur,
                     empresa_atendida     LIKE cdv_solic_viag_781.empresa_atendida,
                     den_empresa_atendida LIKE empresa.den_empresa,
                     filial_atendida      LIKE cdv_solic_viag_781.filial_atendida,
                     den_filial_atendida  LIKE empresa.den_empresa,
                     trajeto_principal    LIKE cdv_solic_viag_781.trajeto_principal,
                     dat_hor_partida      DATE,
                     hora_partida         DATETIME HOUR TO SECOND,
                     dat_hor_retorno      DATE,
                     hora_retorno         DATETIME HOUR TO SECOND,
                     motivo_viagem        LIKE cdv_solic_viag_781.motivo_viagem,
                     ies_solic_adto       CHAR(01),
                     val_adto_viagem      LIKE cdv_solic_adto_781.val_adto_viagem,
                     forma_adto_viagem    LIKE cdv_solic_adto_781.forma_adto_viagem,
                     banco                LIKE cdv_solic_adto_781.banco,
                     agencia              LIKE cdv_solic_adto_781.agencia,
                     cta_corrente         LIKE cdv_solic_adto_781.cta_corrente,
                     ad_adiantamento      LIKE ad_mestre.num_ad,
                     ap_adiantamento      LIKE ad_mestre.num_ad
                  END RECORD

  DEFINE m_den_viajante                LIKE funcionario.nom_funcionario,
         m_den_finalidade_viagem       LIKE cdv_solic_viagem.des_find_viagem,
         m_den_cc_viajante             LIKE cad_cc.nom_cent_cust,
         m_den_cc_debitar              LIKE cad_cc.nom_cent_cust,
         m_den_cliente_atendido        LIKE clientes.nom_cliente,
         m_den_cliente_fatur           LIKE clientes.nom_cliente,
         m_den_banco                   LIKE bancos.nom_banco,
         m_den_empresa_atendida        LIKE empresa.den_empresa,
         m_den_filial_atendida         LIKE empresa.den_empresa,
         m_chamada_parametro           SMALLINT,
         m_viagem                      LIKE cdv_solic_viag_781.viagem,
         m_empresa                     LIKE cdv_solic_viag_781.empresa,
         m_qtd_solic                   INTEGER,
         m_qtd_solic_impres            INTEGER,
         m_num_ad                      LIKE ad_ap.num_ad,
         m_verifica_periodo_viagem     CHAR(01),
         mr_consulta                   RECORD
                                       viagem                LIKE cdv_solic_viag_781.viagem,
                                       controle              LIKE cdv_solic_viag_781.controle,
                                       dat_hr_emis_solic     DATE,
                                       viajante              LIKE cdv_solic_viag_781.viajante,
                                       finalidade_viagem     LIKE cdv_solic_viag_781.finalidade_viagem,
                                       cc_viajante           LIKE cdv_solic_viag_781.cc_viajante,
                                       cc_debitar            LIKE cdv_solic_viag_781.cc_debitar,
                                       cliente_atendido      LIKE cdv_solic_viag_781.cliente_atendido,
                                       cliente_fatur         LIKE cdv_solic_viag_781.cliente_fatur,
                                       empresa_atendida      LIKE cdv_solic_viag_781.empresa_atendida,
                                       den_empresa_atendida  LIKE empresa.den_empresa,
                                       filial_atendida       LIKE cdv_solic_viag_781.filial_atendida,
                                       den_filial_atendida   LIKE empresa.den_empresa
                                       END RECORD

   DEFINE m_val_tv_cpmf LIKE tipo_valor.cod_tip_val #OS.470958

MAIN

CALL log0180_conecta_usuario()

LET p_versao = "CDV2001-10.02.00p" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP

  DEFER INTERRUPT

  LET m_camh_help_cdv2001 = log140_procura_caminho('cdv2001.iem')
  LET m_chamada_parametro = FALSE
  INITIALIZE m_viagem TO NULL

  OPTIONS
     PREVIOUS  KEY control-b,
     NEXT      KEY control-f,
     HELP     FILE m_camh_help_cdv2001

  CALL log001_acessa_usuario("CDV","LOGERP;LOGLQ2")
       RETURNING p_status, p_cod_empresa, p_user

  LET p_user1 = p_user

  IF NUM_ARGS() > 0  THEN
     LET m_viagem  = ARG_VAL(1)
     LET m_empresa = ARG_VAL(2)
     LET p_cod_empresa = m_empresa
     IF  m_viagem  IS NOT NULL
     AND m_empresa IS NOT NULL THEN
        LET m_chamada_parametro = TRUE
     END IF
  ELSE
     LET m_chamada_parametro = FALSE
  END IF

  IF p_status = 0  THEN
     CALL cdv2001_controle()
  END IF
END MAIN

#----------------------------#
 FUNCTION cdv2001_controle()
#----------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("CDV2001") RETURNING m_caminho
  OPEN WINDOW w_cdv2001 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL cdv2001_inicializa_campos()
  CALL cdv2001_cria_temp()

  DISPLAY p_cod_empresa TO empresa

  CALL cdv2001_busca_parametros()

   MENU "OPÇÃO"
    BEFORE MENU
       IF m_chamada_parametro THEN
          HIDE OPTION "Incluir"
          HIDE OPTION "Modificar"
          HIDE OPTION "Excluir"
          HIDE OPTION "Listar"
          HIDE OPTION "adTos. adicionais"
          HIDE OPTION "apRovantes"
#          HIDE OPTION "iNf. compl."
          LET mr_tela.empresa = m_empresa
          LET mr_tela.viagem  = m_viagem
          DISPLAY BY NAME mr_tela.empresa
          DISPLAY BY NAME mr_tela.viagem
          INITIALIZE m_where_clause1 TO NULL
          LET m_where_clause1 = " cdv_solic_viag_781.viagem = ", m_viagem
          LET m_where_clause2 = " 1=1 "
          CALL cdv2001_prepara_consulta()
          CALL cdv2001_exibe_dados1()
       END IF

    COMMAND "Incluir" "Inclui um novo registro na tabela CDV_SOLIC_VIAG_781."
      HELP 001
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2001","IN")  THEN
         CALL cdv2001_inclusao()
         LET m_ies_cons = FALSE
      END IF

    COMMAND "Modificar" "Modifica um registro da tabela CDV_SOLIC_VIAG_781."
      HELP 002
      MESSAGE ""
      IF m_consulta_ativa OR m_modifica_inclusao THEN
         IF log005_seguranca(p_user,"CDV","CDV2001","MO")  THEN
            CALL cdv2001_modificacao()
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente para fazer a modificação. ','info')
      END IF

    COMMAND "Excluir" "Exclui um registro da tabela CDV_SOLIC_VIAG_781."
      HELP 003
      MESSAGE ""
      IF m_consulta_ativa OR m_modifica_inclusao THEN
         IF log005_seguranca(p_user,"CDV","CDV2001","MO")  THEN
            LET m_where_clause2 = " 1=1 "
            CALL cdv2001_exclusao()
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente para fazer a exclusão. ','info')
      END IF

    COMMAND "Consultar" "Consulta os registros da tabela CDV_SOLIC_VIAG_781."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2001","CO") THEN
         CALL cdv2001_consulta()
      END IF

    COMMAND "Seguinte" "Exibe o próximo registro encontrado na pesquisa."
      HELP 005
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2001_paginacao("SEGUINTE")
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND "Anterior" "Exibe o registro anterior encontrado na pesquisa."
      HELP 006
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2001_paginacao("ANTERIOR")
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND "Listar" "Lista os registro da tabela CDV_SOLIC_VIAG_781."
      HELP 007
      MESSAGE ""
      IF  log005_seguranca(p_user, "CDV", "CDV2001", "CO") THEN
          #IF log0280_saida_relat(19,17) IS NOT NULL THEN
          CALL cdv2001_lista()
          #END IF
      END IF

    COMMAND KEY("N") "iNf. compl." "Informações complementares."
      HELP 009
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2001_controle2()
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND KEY("T") "adTos. adicionais" "Adiantamentos adicionais."
      HELP 010
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2001_processa_cdv2002()
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND KEY("R") "apRovantes" "Informações complementares."
      HELP 011
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL log120_procura_caminho("cap3450") RETURNING m_comando
         LET m_comando = m_comando CLIPPED, " ", mr_tela.ad_adiantamento,
                                            " ", p_cod_empresa,
                                            " cap0220 "
         RUN m_comando
         CALL log006_exibe_teclas('01 09', p_versao)
         CURRENT WINDOW IS w_cdv2001
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR m_comando
      RUN m_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

    COMMAND "Fim" "Retorna ao menu anterior."
      HELP 008
      EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_cdv2001
END FUNCTION

#------------------------------------#
 FUNCTION cdv2001_inicializa_campos()
#------------------------------------#
 LET m_consulta_ativa           = FALSE

 INITIALIZE mr_tela.*, mr_telar.* TO NULL

 INITIALIZE m_den_viajante,
            m_den_finalidade_viagem,
            m_den_cc_viajante,
            m_den_cc_debitar,
            m_den_cliente_atendido,
            m_den_cliente_fatur,
            m_den_banco,
            m_den_empresa_atendida,
            m_den_filial_atendida TO NULL

END FUNCTION

#----------------------------------#
 FUNCTION cdv2001_busca_parametros()
#----------------------------------#
 DEFINE l_status_par  SMALLINT,
        l_status      SMALLINT

  CALL log2250_busca_parametro(p_cod_empresa,'empresa_atendida_pamcary')
     RETURNING m_empresa_atendida_pamcary, l_status
  IF NOT l_status OR m_empresa_atendida_pamcary IS NULL THEN
     CALL log0030_mensagem('Classe de uso (AEN para devolução) não cadastrado.','exclamation')
     RETURN
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'filial_atendida_pamcary')
     RETURNING m_filial_atendida_pamcary, l_status
  IF NOT l_status OR m_filial_atendida_pamcary IS NULL THEN
     CALL log0030_mensagem('Classe de uso (AEN para devolução) não cadastrado.','exclamation')
     RETURN
  END IF

  CALL log2250_busca_parametro(p_cod_empresa,'td_despesa_terceiro_pamcary')
     RETURNING m_controle_minimo, l_status
  IF NOT l_status OR m_controle_minimo IS NULL THEN
     LET m_controle_minimo = 0
     #CALL log0030_mensagem('Tipo de despesa para ADs despesas de terceiros não cadastrada.','exclamation')
     #RETURN FALSE
  END IF

 END FUNCTION

#---------------------------#
 FUNCTION cdv2001_consulta()
#---------------------------#

    INITIALIZE mr_consulta.* TO NULL
    CALL log006_exibe_teclas('01 02 07 08', p_versao)
    CURRENT WINDOW IS w_cdv2001

    LET m_where_clause1 =  NULL

    CLEAR FORM
    DISPLAY p_cod_empresa TO empresa

    LET INT_FLAG = FALSE

    INITIALIZE mr_tela.* TO NULL

    IF m_chamada_parametro = TRUE THEN
       LET mr_tela.empresa = m_empresa
       LET mr_tela.viagem  = m_viagem
       DISPLAY BY NAME mr_tela.empresa
       DISPLAY BY NAME mr_tela.viagem
    END IF

    IF cdv2001_construct1() THEN

       #IF m_where_clause1 IS NOT NULL
       #AND m_where_clause1[2,4] <> "1=1" THEN
       #   IF cdv2001_construct2() THEN
       #
       #      CALL cdv2001_prepara_consulta()
       #      LET m_modifica_inclusao = FALSE
       #      IF m_consulta_ativa = TRUE THEN
       #         CALL cdv2001_exibe_dados1()
       #      END IF
       #
       #   END IF
       #ELSE
       LET m_where_clause2 = ' 1=1'
       CALL cdv2001_prepara_consulta()
       LET m_modifica_inclusao = FALSE
       IF m_consulta_ativa = TRUE THEN
          CALL cdv2001_exibe_dados1()
       END IF

       #END IF

    END IF

    CALL log006_exibe_teclas('01 09', p_versao)
    CURRENT WINDOW IS w_cdv2001

END FUNCTION

#-----------------------------#
 FUNCTION cdv2001_construct1()
#-----------------------------#

    DEFINE l_data_hr   DATETIME YEAR TO SECOND,
           l_data_hora CHAR(20)

    LET INT_FLAG = 0


    INPUT mr_consulta.viagem,            mr_consulta.controle,
           mr_consulta.dat_hr_emis_solic, mr_consulta.viajante,
           mr_consulta.finalidade_viagem, mr_consulta.cc_viajante,
           mr_consulta.cc_debitar,        mr_consulta.cliente_atendido,
           mr_consulta.cliente_fatur,     mr_consulta.empresa_atendida,
           mr_consulta.den_empresa_atendida, mr_consulta.filial_atendida,
           mr_consulta.den_filial_atendida FROM viagem,  controle,  dat_hr_emis_solic,
                                                viajante,           finalidade_viagem,
                                                cc_viajante,        cc_debitar,
                                                cliente_atendido,   cliente_fatur,
                                                empresa_atendida,   den_empresa_atendida,
                                                filial_atendida,    den_filial_atendida


        BEFORE FIELD viagem
           IF m_chamada_parametro = TRUE THEN
              LET mr_tela.empresa = m_empresa
              LET mr_tela.viagem  = m_viagem
              DISPLAY BY NAME mr_tela.empresa
              DISPLAY BY NAME mr_tela.viagem
              LET m_chamada_parametro = FALSE
           END IF

#        AFTER FIELD viagem
#           CALL get_fldbuf(viagem) RETURNING mr_consulta.viagem

        BEFORE FIELD controle
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF

        AFTER FIELD controle
#           CALL get_fldbuf(controle) RETURNING mr_consulta.controle
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

#        AFTER FIELD dat_hr_emis_solic
#           CALL get_fldbuf(dat_hr_emis_solic) RETURNING mr_consulta.dat_hr_emis_solic

#           IF mr_consulta.dat_hr_emis_solic IS NOT NULL THEN
#              LET l_data_hr = mr_consulta.dat_hr_emis_solic
#              IF l_data_hr IS NULL THEN
#                 CALL log0030_mensagem('Formato da data/hora inválido.','info')
#                 NEXT FIELD dat_hr_emis_solic
#              END IF
#           END IF

        BEFORE FIELD viajante
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF

        AFTER FIELD viajante
#           CALL get_fldbuf(viajante) RETURNING mr_consulta.viajante
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD finalidade_viagem
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF

        AFTER FIELD finalidade_viagem
#           CALL get_fldbuf(finalidade_viagem) RETURNING mr_consulta.finalidade_viagem
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD cc_viajante
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF

        AFTER FIELD cc_viajante
#           CALL get_fldbuf(cc_viajante) RETURNING mr_consulta.cc_viajante
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD cc_debitar
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD cc_debitar
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD cliente_atendido
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD cliente_atendido
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD cliente_fatur
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD cliente_fatur
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD empresa_atendida
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD empresa_atendida
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD filial_atendida
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD filial_atendida
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        ON KEY (control-w, f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE INPUT
           #lds END IF
           CALL cdv2001_help()
           CURRENT WINDOW IS w_cdv2001
        ON KEY (control-z, f4)
           CALL cdv2001_popup()
       --# CALL fgl_dialog_setkeylabel('control-z',NULL)
           CALL log006_exibe_teclas("01 02 03 07", p_versao)
           CURRENT WINDOW IS w_cdv2001

    END INPUT

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv2001

    IF INT_FLAG THEN
       LET INT_FLAG = FALSE
       ERROR ' Consulta cancelada. '
       CLEAR FORM
       DISPLAY p_cod_empresa TO empresa
       RETURN FALSE
    ELSE
        RETURN TRUE
    END IF

END FUNCTION

#-----------------------------#
 FUNCTION cdv2001_construct2()
#-----------------------------#

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("CDV20011") RETURNING m_caminho
  OPEN WINDOW w_cdv20011 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_cdv20011

  LET int_flag = FALSE

    CONSTRUCT BY NAME m_where_clause2 ON cdv_solic_viag_781.trajeto_principal,
                                         cdv_solic_viag_781.dat_hor_partida,
                                         cdv_solic_viag_781.dat_hor_retorno,
                                         cdv_solic_viag_781.motivo_viagem,
                                         cdv_solic_adto_781.val_adto_viagem,
                                         cdv_solic_adto_781.forma_adto_viagem,
                                         cdv_solic_adto_781.banco,
                                         cdv_solic_adto_781.agencia,
                                         cdv_solic_adto_781.cta_corrente

        BEFORE FIELD forma_adto_viagem
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD forma_adto_viagem
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        BEFORE FIELD banco
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD banco
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

        ON KEY (control-w, f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE CONSTRUCT
           #lds END IF
           CALL cdv2001_help()
           CURRENT WINDOW IS w_cdv20011
        ON KEY (control-z, f4)
           CALL cdv2001_popup()
       --# CALL fgl_dialog_setkeylabel('control-z',NULL)
           CALL log006_exibe_teclas("01 02 03 07", p_versao)
           CURRENT WINDOW IS w_cdv20011

    END CONSTRUCT

    CLOSE WINDOW w_cdv20011

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv2001

    IF INT_FLAG THEN
       LET INT_FLAG = FALSE
       ERROR ' Consulta cancelada. '
       CLEAR FORM
       DISPLAY p_cod_empresa TO empresa
       RETURN FALSE
    ELSE
        RETURN TRUE
    END IF

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2001_prepara_consulta()
#-----------------------------------#

    DEFINE l_data_hora         CHAR(19),
           l_data              CHAR(10),
           l_hora              CHAR(08),
           l_data_hora_partida CHAR(19),
           l_data_hora_retorno CHAR(19)

    LET m_sql_stmt = "SELECT cdv_solic_viag_781.empresa,",
                           " cdv_solic_viag_781.viagem,",
                           " cdv_solic_viag_781.controle,",
                           " cdv_solic_viag_781.dat_hr_emis_solic,",
                           " cdv_solic_viag_781.viajante,",
                           " cdv_solic_viag_781.finalidade_viagem,",
                           " cdv_solic_viag_781.cc_viajante,",
                           " cdv_solic_viag_781.cc_debitar,",
                           " cdv_solic_viag_781.cliente_atendido,",
                           " cdv_solic_viag_781.cliente_fatur,",
                           " cdv_solic_viag_781.empresa_atendida,",
                           " cdv_solic_viag_781.filial_atendida,",
                           " cdv_solic_viag_781.trajeto_principal,",
                           " cdv_solic_viag_781.dat_hor_partida,",
                           " cdv_solic_viag_781.dat_hor_retorno,",
                           " cdv_solic_viag_781.motivo_viagem",
                      " FROM cdv_solic_viag_781",
                     " WHERE cdv_solic_viag_781.empresa = '",p_cod_empresa CLIPPED,"'"
#                       " AND ",m_where_clause1 CLIPPED,

# OS459347
    IF m_chamada_parametro  THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                        " AND cdv_solic_viag_781.viagem = ", m_viagem
    ELSE
       IF mr_consulta.viagem IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND viagem = ", mr_consulta.viagem, " "
       END IF
       IF mr_consulta.controle IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND controle = '", mr_consulta.controle, "' "
       END IF
       IF mr_consulta.dat_hr_emis_solic IS NOT NULL THEN
          LET l_data_hora = mr_consulta.dat_hr_emis_solic
          LET l_data_hora = l_data_hora[7,10],'-',
                            l_data_hora[4,5],'-',
                            l_data_hora[1,2],' 00:00:00'

          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND dat_hr_emis_solic BETWEEN '", l_data_hora, "' "

          LET l_data_hora = l_data_hora[1,10], " ",
                                        "23:59:59"

          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND '", l_data_hora, "' "
       END IF
       IF mr_consulta.viajante IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND viajante = ", mr_consulta.viajante, " "
       END IF
       IF mr_consulta.finalidade_viagem IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND finalidade_viagem = ", mr_consulta.finalidade_viagem, " "
       END IF
       IF mr_consulta.cc_viajante IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND cc_viajante = ", mr_consulta.cc_viajante, " "
       END IF
       IF mr_consulta.cc_debitar IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND cc_debitar = ", mr_consulta.cc_debitar, " "
       END IF
       IF mr_consulta.cliente_atendido IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND cliente_atendido = '", mr_consulta.cliente_atendido, "' "
       END IF
       IF mr_consulta.cliente_fatur IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND cliente_fatur = '", mr_consulta.cliente_fatur, "' "
       END IF
       IF mr_consulta.empresa_atendida IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND empresa_atendida = '", mr_consulta.empresa_atendida, "' "
       END IF
       IF mr_consulta.filial_atendida IS NOT NULL THEN
          LET m_sql_stmt = m_sql_stmt CLIPPED,
                           " AND filial_atendida = '", mr_consulta.filial_atendida, "' "
       END IF

       LET m_sql_stmt = m_sql_stmt CLIPPED,
                        " ORDER BY cdv_solic_viag_781.empresa,cdv_solic_viag_781.viagem"
    END IF

    INITIALIZE l_data_hora TO NULL
    WHENEVER ERROR CONTINUE
    PREPARE var_query_viagem1 FROM m_sql_stmt
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN      CALL log003_err_sql_detalhe("PREPARE","var_query_viagem1",m_sql_stmt) RETURN END IF
    WHENEVER ERROR CONTINUE
    DECLARE cq_cdv_solic_viag1_781 SCROLL CURSOR WITH HOLD FOR var_query_viagem1
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('DECLARE','CDV_SOLIC_VIAG_781') RETURN END IF
    WHENEVER ERROR CONTINUE
    OPEN cq_cdv_solic_viag1_781
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('OPEN','CDV_SOLIC_VIAG_781') RETURN END IF
    WHENEVER ERROR CONTINUE
    FETCH cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                      mr_tela.viagem,
                                      mr_tela.controle,
                                      l_data_hora,
                                      mr_tela.viajante,
                                      mr_tela.finalidade_viagem,
                                      mr_tela.cc_viajante,
                                      mr_tela.cc_debitar,
                                      mr_tela.cliente_atendido,
                                      mr_tela.cliente_fatur,
                                      mr_tela.empresa_atendida,
                                      mr_tela.filial_atendida,
                                      mr_tela.trajeto_principal,
                                      l_data_hora_partida,
                                      l_data_hora_retorno,
                                      mr_tela.motivo_viagem
    WHENEVER ERROR STOP
    CALL cdv2001_monta_datas(l_data_hora, l_data_hora_partida, l_data_hora_retorno)

    IF sqlca.sqlcode = 0 THEN
       MESSAGE ' Consulta efetuada com sucesso. ' ATTRIBUTE(REVERSE)
       LET m_consulta_ativa = TRUE
       LET m_ies_cons = TRUE
       CALL cdv2001_carrega_cdv_solic_adto_781()
    ELSE
       LET m_consulta_ativa = FALSE
       CLEAR FORM
       DISPLAY p_cod_empresa TO empresa
       CALL log0030_mensagem(' Argumentos de pesquisa não encontrados. ','info')
       LET m_ies_cons = FALSE
    END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2001_carrega_cdv_solic_adto_781()
#---------------------------------------------#
 DEFINE l_seq   LIKE cdv_solic_adto_781.sequencia_adto

  LET m_sql_stmt = "SELECT cdv_solic_adto_781.val_adto_viagem,",
                         " cdv_solic_adto_781.forma_adto_viagem,",
                         " cdv_solic_adto_781.banco,",
                         " cdv_solic_adto_781.agencia,",
                         " cdv_solic_adto_781.cta_corrente,",
                         " cdv_solic_adto_781.num_ad_adto_viagem,",
                         " cdv_solic_adto_781.sequencia_adto ",
                    " FROM cdv_solic_adto_781",
                   " WHERE cdv_solic_adto_781.empresa = '",p_cod_empresa CLIPPED,"'",
                     " AND ",m_where_clause2 CLIPPED,
                     " AND cdv_solic_adto_781.viagem = ",mr_tela.viagem,
                   " ORDER BY sequencia_adto "

  WHENEVER ERROR CONTINUE
  PREPARE var_query_viagem2 FROM m_sql_stmt
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('PREPARE','CDV_SOLIC_ADTO_781')RETURN END IF
  WHENEVER ERROR CONTINUE
  DECLARE cq_cdv_solic_viag2_781 SCROLL CURSOR WITH HOLD FOR var_query_viagem2
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('DECLARE','CDV_SOLIC_ADTO_781') RETURN END IF
  WHENEVER ERROR CONTINUE
  OPEN cq_cdv_solic_viag2_781
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('OPEN','CDV_SOLIC_ADTO_781') RETURN END IF
  WHENEVER ERROR CONTINUE
  FETCH cq_cdv_solic_viag2_781 INTO mr_tela.val_adto_viagem,
                                    mr_tela.forma_adto_viagem,
                                    mr_tela.banco,
                                    mr_tela.agencia,
                                    mr_tela.cta_corrente,
                                    mr_tela.ad_adiantamento,
                                    l_seq
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET mr_tela.ies_solic_adto = "S"
     CALL cdv2001_busca_num_ap(mr_tela.ad_adiantamento)
          RETURNING mr_tela.ap_adiantamento
  ELSE
     LET mr_tela.ies_solic_adto = "N"
     INITIALIZE mr_tela.val_adto_viagem,
                mr_tela.forma_adto_viagem,
                mr_tela.banco,
                mr_tela.agencia,
                mr_tela.cta_corrente,
                mr_tela.ad_adiantamento,
                mr_tela.ap_adiantamento,
                m_den_banco TO NULL
  END IF

END FUNCTION

#------------------------------------------------------------------------------------#
 FUNCTION cdv2001_monta_datas(l_data_hora, l_data_hora_partida, l_data_hora_retorno)
#------------------------------------------------------------------------------------#
  DEFINE l_data_hora         CHAR(19),
         l_data_hora_retorno CHAR(19),
         l_data_hora_partida CHAR(19)

 LET mr_tela.hora = l_data_hora[12,19]
 LET l_data_hora  = l_data_hora[9,10],"/",
                    l_data_hora[6,7], "/",
                    l_data_hora[1,4]

 LET mr_tela.dat_hr_emis_solic = l_data_hora

 LET mr_tela.hora_partida = l_data_hora_partida[12,19]
 LET l_data_hora_partida  = l_data_hora_partida[9,10],"/",
                            l_data_hora_partida[6,7], "/",
                            l_data_hora_partida[1,4]

 LET mr_tela.dat_hor_partida = l_data_hora_partida

 LET mr_tela.hora_retorno = l_data_hora_retorno[12,19]
 LET l_data_hora_retorno  = l_data_hora_retorno[9,10],"/",
                            l_data_hora_retorno[6,7], "/",
                            l_data_hora_retorno[1,4]

 LET mr_tela.dat_hor_retorno = l_data_hora_retorno

 END FUNCTION

#------------------------------------#
 FUNCTION cdv2001_paginacao(l_funcao)
#------------------------------------#
  DEFINE l_funcao            CHAR(20),
         l_data_hora         CHAR(19),
         l_data              CHAR(10),
         l_hora              CHAR(08),
         l_data_hora_retorno CHAR(19),
         l_data_hora_partida CHAR(19)

  LET mr_telar.* = mr_tela.*

  WHILE TRUE

     IF l_funcao = 'SEGUINTE' THEN
        WHENEVER ERROR CONTINUE
        FETCH NEXT cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                               mr_tela.viagem,
                                               mr_tela.controle,
                                               l_data_hora,
                                               mr_tela.viajante,
                                               mr_tela.finalidade_viagem,
                                               mr_tela.cc_viajante,
                                               mr_tela.cc_debitar,
                                               mr_tela.cliente_atendido,
                                               mr_tela.cliente_fatur,
                                               mr_tela.empresa_atendida,
                                               mr_tela.filial_atendida,
                                               mr_tela.trajeto_principal,
                                               l_data_hora_partida,
                                               l_data_hora_retorno,
                                               mr_tela.motivo_viagem
        WHENEVER ERROR STOP
        IF SQLCA.sqlcode <> 0 THEN END IF
     ELSE
        WHENEVER ERROR CONTINUE
        FETCH PREVIOUS cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                                   mr_tela.viagem,
                                                   mr_tela.controle,
                                                   l_data_hora,
                                                   mr_tela.viajante,
                                                   mr_tela.finalidade_viagem,
                                                   mr_tela.cc_viajante,
                                                   mr_tela.cc_debitar,
                                                   mr_tela.cliente_atendido,
                                                   mr_tela.cliente_fatur,
                                                   mr_tela.empresa_atendida,
                                                   mr_tela.filial_atendida,
                                                   mr_tela.trajeto_principal,
                                                   l_data_hora_partida,
                                                   l_data_hora_retorno,
                                                   mr_tela.motivo_viagem
        WHENEVER ERROR STOP
        IF SQLCA.sqlcode <> 0 THEN END IF
     END IF
     CALL cdv2001_monta_datas(l_data_hora, l_data_hora_partida, l_data_hora_retorno)

     IF SQLCA.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
        SELECT empresa,
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
               motivo_viagem
          INTO mr_tela.empresa,
               mr_tela.viagem,
               mr_tela.controle,
               l_data_hora,
               mr_tela.viajante,
               mr_tela.finalidade_viagem,
               mr_tela.cc_viajante,
               mr_tela.cc_debitar,
               mr_tela.cliente_atendido,
               mr_tela.cliente_fatur,
               mr_tela.empresa_atendida,
               mr_tela.filial_atendida,
               mr_tela.trajeto_principal,
               l_data_hora_partida,
               l_data_hora_retorno,
               mr_tela.motivo_viagem
          FROM cdv_solic_viag_781
         WHERE cdv_solic_viag_781.empresa  = p_cod_empresa
           AND cdv_solic_viag_781.viagem = mr_tela.viagem
        WHENEVER ERROR STOP

        CALL cdv2001_monta_datas(l_data_hora, l_data_hora_partida, l_data_hora_retorno)

        IF SQLCA.sqlcode = 0 THEN
           CALL cdv2001_carrega_cdv_solic_adto_781()
           LET mr_telar.* = mr_tela.*
           EXIT WHILE
        END IF
     ELSE
        ERROR ' Não existem mais itens nesta direção. '
        LET mr_tela.* = mr_telar.*
        EXIT WHILE
     END IF

  END WHILE

  CALL cdv2001_exibe_dados1()

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2001_cursor_for_update()
#-----------------------------------#
  DEFINE l_data_hora         CHAR(19),
         l_data_hora_retorno CHAR(19),
         l_data_hora_partida CHAR(19)

   WHENEVER ERROR CONTINUE
   DECLARE cm_solic_viag_781 CURSOR FOR
    SELECT empresa, viagem, controle, dat_hr_emis_solic,
           viajante, finalidade_viagem, cc_viajante, cc_debitar, cliente_atendido,
           cliente_fatur, empresa_atendida, filial_atendida, trajeto_principal,
           dat_hor_partida, dat_hor_retorno, motivo_viagem
      FROM cdv_solic_viag_781
     WHERE cdv_solic_viag_781.empresa = p_cod_empresa
       AND cdv_solic_viag_781.viagem  = mr_tela.viagem
   FOR UPDATE
   WHENEVER ERROR STOP
   IF SQLCA.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      WHENEVER ERROR STOP

      IF SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("BEGIN","CDV_SOLIC_VIAG_781")
      END IF

      WHENEVER ERROR CONTINUE
      OPEN  cm_solic_viag_781
      WHENEVER ERROR STOP
      IF SQLCA.sqlcode = 0 THEN
         WHENEVER ERROR CONTINUE
         FETCH cm_solic_viag_781 INTO mr_tela.empresa,
                                      mr_tela.viagem,
                                      mr_tela.controle,
                                      l_data_hora,
                                      mr_tela.viajante,
                                      mr_tela.finalidade_viagem,
                                      mr_tela.cc_viajante,
                                      mr_tela.cc_debitar,
                                      mr_tela.cliente_atendido,
                                      mr_tela.cliente_fatur,
                                      mr_tela.empresa_atendida,
                                      mr_tela.filial_atendida,
                                      mr_tela.trajeto_principal,
                                      l_data_hora_partida,
                                      l_data_hora_retorno,
                                      mr_tela.motivo_viagem
         WHENEVER ERROR STOP
         CASE
           WHEN sqlca.sqlcode = 0
                CALL cdv2001_monta_datas(l_data_hora, l_data_hora_partida, l_data_hora_retorno)
                CALL cdv2001_carrega_cdv_solic_adto_781()
                RETURN TRUE
           WHEN sqlca.sqlcode = -250 CALL log0030_mensagem("Viagem sendo atualizada por outro usuário. \nAguarde e tente novamente. ","exclamation")
           WHEN sqlca.sqlcode =  100 CALL log0030_mensagem("Viagem não mais existente na tabela. \nExecute a consulta novamente. ","exclamation")
           OTHERWISE CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
         END CASE
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   ELSE
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION cdv2001_exibe_dados1()
#-------------------------------#
 DEFINE l_empresa_rhu   LIKE cdv_info_viajante.empresa_rhu

  LET mr_tela.empresa = p_cod_empresa

  DISPLAY BY NAME mr_tela.empresa,
                  mr_tela.viagem,
                  mr_tela.controle,
                  mr_tela.dat_hr_emis_solic,
                  mr_tela.hora,
                  mr_tela.viajante,
                  mr_tela.finalidade_viagem,
                  mr_tela.cc_viajante,
                  mr_tela.cc_debitar,
                  mr_tela.cliente_atendido,
                  mr_tela.cliente_fatur,
                  mr_tela.empresa_atendida,
                  mr_tela.filial_atendida

  WHENEVER ERROR CONTINUE
  SELECT empresa_rhu
    INTO l_empresa_rhu
    FROM cdv_info_viajante
   WHERE empresa   = p_cod_empresa
     AND matricula = mr_tela.viajante
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     LET l_empresa_rhu = p_cod_empresa
  END IF

  LET m_den_viajante          = cdv2001_busca_den_viajante(mr_tela.viajante, l_empresa_rhu)
  LET m_den_finalidade_viagem = cdv2001_busca_den_finalidade_viagem(mr_tela.finalidade_viagem)
  LET m_den_cc_viajante       = cdv2001_busca_den_cc(mr_tela.cc_viajante)
  LET m_den_cc_debitar        = cdv2001_busca_den_cc(mr_tela.cc_debitar)
  LET m_den_cliente_atendido  = cdv2001_busca_den_cliente(mr_tela.cliente_atendido)
  LET m_den_cliente_fatur     = cdv2001_busca_den_cliente(mr_tela.cliente_fatur)
  LET m_den_empresa_atendida  = cdv2001_busca_den_empresa_reduz(mr_tela.empresa_atendida)
  LET m_den_filial_atendida   = cdv2001_busca_den_empresa_reduz(mr_tela.filial_atendida)

  DISPLAY m_den_viajante          TO den_viajante
  DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
  DISPLAY m_den_cc_viajante       TO den_cc_viajante
  DISPLAY m_den_cc_debitar        TO den_cc_debitar
  DISPLAY m_den_cliente_atendido  TO den_cliente_atendido
  DISPLAY m_den_cliente_fatur     TO den_cliente_fatur
  DISPLAY m_den_empresa_atendida  TO den_empresa_atendida
  DISPLAY m_den_filial_atendida   TO den_filial_atendida

END FUNCTION

#----------------------------#
 FUNCTION cdv2001_controle2()
#----------------------------#

  DEFINE m_comand CHAR(100) #OS.470958

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("CDV20011") RETURNING m_caminho
  OPEN WINDOW w_cdv20011 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY p_cod_empresa TO empresa
  DISPLAY BY NAME mr_tela.controle

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_cdv20011

  CALL cdv2001_exibe_dados2()

  MENU "OPÇÃO"

    COMMAND "Modificar" "Modifica um registro da tabela CDV_SOLIC_ADTO_781."
      HELP 002
      MESSAGE ""
      IF m_consulta_ativa OR m_modifica_inclusao THEN
         IF log005_seguranca(p_user,"CDV","CDV2001","MO")  THEN
            CALL cdv2001_modificacao2()
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente para fazer a modificação. ','info')
      END IF

    #INICIO OS.470958
    COMMAND "Autoriz_pgto" "Executa o programa cap0160 para visualizar as informações da AP."
       HELP 012
       MESSAGE " "
       CALL log120_procura_caminho("cap0160") RETURNING m_comand
       LET m_comand = m_comand CLIPPED, " ", mr_tela.ap_adiantamento,
                                        " ", mr_tela.empresa
       RUN m_comand RETURNING p_status
       LET p_status = p_status / 256
       IF p_status = 0 THEN
       ELSE
          PROMPT "Tecle ENTER para continuar" FOR m_comand
       END IF
    #FIM OS.470958

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR m_comando
      RUN m_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

    COMMAND "Fim" "Retorna ao menu anterior."
      HELP 008
      EXIT MENU



  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_cdv20011
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2001

END FUNCTION

#-------------------------------#
 FUNCTION cdv2001_exibe_dados2()
#-------------------------------#

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_cdv20011

  LET mr_tela.empresa = p_cod_empresa

  DISPLAY BY NAME mr_tela.empresa,
                  mr_tela.viagem,
                  mr_tela.trajeto_principal,
                  mr_tela.dat_hor_partida,
                  mr_tela.hora_partida,
                  mr_tela.dat_hor_retorno,
                  mr_tela.hora_retorno,
                  mr_tela.motivo_viagem,
                  mr_tela.ies_solic_adto,
                  mr_tela.val_adto_viagem,
                  mr_tela.forma_adto_viagem,
                  mr_tela.banco,
                  mr_tela.agencia,
                  mr_tela.cta_corrente,
                  mr_tela.ad_adiantamento,
                  mr_tela.ap_adiantamento

  LET m_den_banco = cdv2001_busca_den_banco(mr_tela.banco)
  DISPLAY m_den_banco TO den_banco

END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2001_verifica_ad_tot_aprovada(l_num_ad)
#---------------------------------------------------#
 DEFINE l_aprovado    CHAR(01),
        l_permite     SMALLINT,
        l_num_ad      LIKE ad_mestre.num_ad

 LET l_aprovado = NULL
 LET l_permite  = FALSE

 WHENEVER ERROR CONTINUE
 DECLARE cl_aprov_neces CURSOR FOR
  SELECT ies_aprovado
    FROM aprov_necessaria
   WHERE cod_empresa  = p_cod_empresa
     AND num_ad       = l_num_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CL_APROV_NECES")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cl_aprov_neces INTO l_aprovado
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CL_APROV_NECES")
       RETURN FALSE
    END IF

    IF l_aprovado = "N" THEN
       LET l_permite = TRUE
    END IF
 END FOREACH
 FREE cl_aprov_neces

 IF l_aprovado IS NOT NULL THEN
    IF l_permite = FALSE THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------#
 FUNCTION cdv2001_exclusao()
#---------------------------#

 IF NOT cdv2001_status_pendente() THEN
    RETURN
 END IF

 IF cdv2001_cursor_for_update() THEN

     CALL cdv2001_exibe_dados1()
     IF log0040_confirm(5,10,"Confirma a exclusão da solicitação?") THEN
        WHENEVER ERROR CONTINUE
        DELETE FROM cdv_solic_viag_781
        WHERE CURRENT OF cm_solic_viag_781
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           CLOSE cm_solic_viag_781
           WHENEVER ERROR CONTINUE
           DELETE
             FROM cdv_solic_adto_781
            WHERE empresa = p_cod_empresa
              AND viagem = mr_tela.viagem
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              IF  mr_tela.ad_adiantamento IS NOT NULL
              AND mr_tela.ap_adiantamento IS NOT NULL THEN
                 IF NOT cdv2001_exclui_ad_ap_adiantamento() THEN
                    CALL log085_transacao("ROLLBACK")
                 ELSE
                    CALL log085_transacao("COMMIT")
                    CLEAR FORM
                    DISPLAY p_cod_empresa TO empresa
                    MESSAGE ' Exclusão efetuada com sucesso. '
                    ERROR " "
                 END IF
              ELSE
                 WHENEVER ERROR CONTINUE
                 CALL log085_transacao("COMMIT")
                 WHENEVER ERROR STOP

                 IF SQLCA.sqlcode <> 0 THEN
                    CALL log003_err_sql("COMMIT","CDV_SOLIC_ADTO_781")
                 END IF
                 CLEAR FORM
                 DISPLAY p_cod_empresa TO empresa
                 MESSAGE ' Exclusão efetuada com sucesso. '
              END IF
           ELSE
              CALL log003_err_sql('EXCLUSAO','CDV_SOLIC_ADTO_781')
              CALL log085_transacao("ROLLBACK")
           END IF
        ELSE
            CALL log003_err_sql('EXCLUSAO','CDV_SOLIC_VIAG_781')
            CLOSE cm_solic_viag_781
            CALL log085_transacao("ROLLBACK")
        END IF
     ELSE
        CLOSE cm_solic_viag_781
        CALL log085_transacao("ROLLBACK")
        ERROR ' Exclusão cancelada. '
     END IF

  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2001_exclui_ad_ap_adiantamento()
#--------------------------------------------#

  ERROR "Excluindo AP do contas a pagar . . ."
  CALL log120_procura_caminho("cap0160") RETURNING m_comando
  LET m_comando = m_comando CLIPPED, " ",mr_tela.ap_adiantamento," ",p_cod_empresa," ","S"
  RUN m_comando

  WHENEVER ERROR CONTINUE
   SELECT num_ap
     FROM ap
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = mr_tela.ap_adiantamento
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     CALL log0030_mensagem("AP não pode ser excluída, exclusão cancelada.",'exclamation')
     RETURN FALSE
  END IF

  ERROR "Excluindo AD do contas a pagar . . ."
  CALL log120_procura_caminho("cap0220") RETURNING m_comando
  LET m_comando = m_comando CLIPPED," ", mr_tela.ad_adiantamento,
                                    " ", p_cod_empresa,
                                    " ", "EXCLUIR",
                                    " ", "CDV2001"
  RUN m_comando

  WHENEVER ERROR CONTINUE
   SELECT num_ad
     FROM ad_mestre
    WHERE num_ad      = mr_tela.ad_adiantamento
      AND cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE = 0 THEN
     CALL log0030_mensagem("AD não pode ser excluída, exclusão cancelada.",'exclamation')
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION cdv2001_modificacao()
#------------------------------#
  DEFINE l_ad                LIKE ad_ap.num_ad,
         l_data              CHAR(10),
         l_hora              CHAR(08),
         l_data_hora_emissao CHAR(19)

 LET mr_telar.* = mr_tela.*

 IF NOT cdv2001_verifica_ad_tot_aprovada(mr_tela.ad_adiantamento) THEN
    CALL log0030_mensagem("AD está totalmente aprovada. Modificação cancelada.","info")
    RETURN
 END IF

 IF cdv2001_cursor_for_update() THEN
    CALL cdv2001_exibe_dados1()
    IF cdv2001_entrada_dados1("MODIFICACAO") THEN
       LET l_data = mr_tela.dat_hr_emis_solic
       LET l_hora = mr_tela.hora
       LET l_data_hora_emissao = l_data[7,10],"-",
                                 l_data[4,5],"-",
                                 l_data[1,2], " ",
                                 l_hora CLIPPED

       WHENEVER ERROR CONTINUE
       UPDATE cdv_solic_viag_781
          SET cdv_solic_viag_781.empresa           = mr_tela.empresa,
              cdv_solic_viag_781.viagem            = mr_tela.viagem,
              cdv_solic_viag_781.controle          = mr_tela.controle,
              cdv_solic_viag_781.dat_hr_emis_solic = l_data_hora_emissao,
              cdv_solic_viag_781.viajante          = mr_tela.viajante,
              cdv_solic_viag_781.finalidade_viagem = mr_tela.finalidade_viagem,
              cdv_solic_viag_781.cc_viajante       = mr_tela.cc_viajante,
              cdv_solic_viag_781.cc_debitar        = mr_tela.cc_debitar,
              cdv_solic_viag_781.cliente_atendido  = mr_tela.cliente_atendido,
              cdv_solic_viag_781.cliente_fatur     = mr_tela.cliente_fatur,
              cdv_solic_viag_781.empresa_atendida  = mr_tela.empresa_atendida,
              cdv_solic_viag_781.filial_atendida   = mr_tela.filial_atendida
        WHERE CURRENT OF cm_solic_viag_781
       WHENEVER ERROR STOP
       IF sqlca.sqlcode = 0 THEN
          WHENEVER ERROR CONTINUE
          CLOSE cm_solic_viag_781

          CALL log085_transacao("COMMIT")
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("COMMIT","CDV_SOLIC_VIAG_781")
          END IF
          MESSAGE ' Modificação efetuada com sucesso.'
       ELSE
           CALL log003_err_sql('MODIFICACAO','CDV_SOLIC_VIAG_781')
           CLOSE cm_solic_viag_781
           CALL log085_transacao("ROLLBACK")
           LET mr_tela.* = mr_telar.*
           CALL cdv2001_exibe_dados1()
       END IF

    ELSE
       CLOSE cm_solic_viag_781
       CALL log085_transacao("ROLLBACK")
       LET mr_tela.* = mr_telar.*
       CALL cdv2001_exibe_dados1()
       ERROR ' Modificação cancelada. '
    END IF

 END IF

END FUNCTION

#-------------------------------#
 FUNCTION cdv2001_modificacao2()
#-------------------------------#

  DEFINE l_data_hora_retorno CHAR(19),
         l_data_hora_partida CHAR(19),
         l_data              CHAR(10),
         l_hora              CHAR(09)

  LET mr_telar.* = mr_tela.*

  IF cdv2001_cursor_for_update() THEN
     CALL cdv2001_exibe_dados2()
     IF cdv2001_entrada_dados2('MODIFICACAO') THEN
        LET l_data = mr_tela.dat_hor_partida
        LET l_hora = mr_tela.hora_partida
        LET l_data_hora_partida = l_data[7,10],"-",
                                  l_data[4,5],"-",
                                  l_data[1,2], " ",
                                  l_hora CLIPPED

        LET l_data = mr_tela.dat_hor_retorno
        LET l_hora = mr_tela.hora_retorno
        LET l_data_hora_retorno = l_data[7,10],"-",
                                  l_data[4,5],"-",
                                  l_data[1,2], " ",
                                  l_hora CLIPPED

        WHENEVER ERROR CONTINUE
        UPDATE cdv_solic_viag_781
           SET cdv_solic_viag_781.trajeto_principal = mr_tela.trajeto_principal,
               cdv_solic_viag_781.dat_hor_partida   = l_data_hora_partida,
               cdv_solic_viag_781.dat_hor_retorno   = l_data_hora_retorno,
               cdv_solic_viag_781.motivo_viagem     = mr_tela.motivo_viagem
         WHERE CURRENT OF cm_solic_viag_781
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           WHENEVER ERROR CONTINUE
           CLOSE cm_solic_viag_781

           CALL log085_transacao("COMMIT")

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("COMMIT","CDV_SOLIC_VIAG_781")
           END IF
           WHENEVER ERROR STOP
           MESSAGE ' Modificação efetuada com sucesso. '
        ELSE
            CALL log003_err_sql('MODIFICACAO','CDV_SOLIC_VIAG_781')
            CLOSE cm_solic_viag_781
            CALL log085_transacao("ROLLBACK")
            LET mr_tela.* = mr_telar.*
            CALL cdv2001_exibe_dados2()
        END IF
     ELSE
        CLOSE cm_solic_viag_781
        CALL log085_transacao("ROLLBACK")
        LET mr_tela.* = mr_telar.*
        CALL cdv2001_exibe_dados2()
        ERROR ' Modificação cancelada. '
     END IF

  END IF

END FUNCTION

#---------------------------#
 FUNCTION cdv2001_inclusao()
#---------------------------#
  DEFINE l_data_hora_emissao CHAR(19), #LIKE cdv_solic_viag_781.dat_hr_emis_solic,
         l_data_hora_partida CHAR(19), #LIKE cdv_solic_viag_781.dat_hor_partida,
         l_data_hora_retorno CHAR(19), #LIKE cdv_solic_viag_781.dat_hor_retorno,
         l_data              CHAR(10),
         l_hora              CHAR(08),
         l_data_hora_ret     DATETIME YEAR TO SECOND,
         l_data_hora_emis    DATETIME YEAR TO SECOND,
         l_data_hora_part    DATETIME YEAR TO SECOND

  #INICIO OS.470958
  DEFINE l_observ            CHAR(200),
         l_perc_val_princ    LIKE tipo_valor.perc_val_princ,
         l_num_seq           LIKE ap_valores.num_seq,
         l_val_nom_ap        LIKE ap.val_nom_ap,
         l_valor             LIKE ap.val_nom_ap
  #FIM OS.470958

  LET mr_telar.* = mr_tela.*

  INITIALIZE mr_tela.* TO NULL

  #INICIO OS.470958
  INITIALIZE l_observ,
             l_perc_val_princ,
             l_num_seq,
             l_val_nom_ap,
             l_valor          TO NULL
  #FIM OS.470958

  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa

  IF cdv2001_entrada_dados1('INCLUSAO') THEN
     IF cdv2001_entrada_dados2('INCLUSAO') THEN
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("BEGIN")
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("BEGIN","INCLUSÃO")
        END IF

        LET l_data = mr_tela.dat_hr_emis_solic
        LET l_hora = mr_tela.hora
        LET l_data_hora_emissao = l_data[7,10],"-",
                                  l_data[4,5],"-",
                                  l_data[1,2], " ",
                                  l_hora CLIPPED

        LET l_data = mr_tela.dat_hor_partida
        LET l_hora = mr_tela.hora_partida
        LET l_data_hora_partida = l_data[7,10],"-",
                                  l_data[4,5],"-",
                                  l_data[1,2], " ",
                                  l_hora CLIPPED

        LET l_data = mr_tela.dat_hor_retorno
        LET l_hora = mr_tela.hora_retorno
        LET l_data_hora_retorno = l_data[7,10],"-",
                                  l_data[4,5],"-",
                                  l_data[1,2], " ",
                                  l_hora CLIPPED

        LET l_data_hora_ret =  l_data_hora_retorno
        LET l_data_hora_emis =  l_data_hora_emissao
        LET l_data_hora_part = l_data_hora_partida

        WHENEVER ERROR CONTINUE
        INSERT INTO cdv_solic_viag_781(empresa,
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
                               VALUES (mr_tela.empresa,
                                       mr_tela.viagem,
                                       mr_tela.controle,
                                       l_data_hora_emis,
                                       mr_tela.viajante,
                                       mr_tela.finalidade_viagem,
                                       mr_tela.cc_viajante,
                                       mr_tela.cc_debitar,
                                       mr_tela.cliente_atendido,
                                       mr_tela.cliente_fatur,
                                       mr_tela.empresa_atendida,
                                       mr_tela.filial_atendida,
                                       mr_tela.trajeto_principal,
                                       l_data_hora_part,
                                       l_data_hora_ret,
                                       mr_tela.motivo_viagem)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('INCLUSAO','CDV_SOLIC_VIAG_781')
           CALL log085_transacao("ROLLBACK")
           RETURN
        END IF

        IF mr_tela.ies_solic_adto = "S" THEN
           CALL cdv2001_gera_informacoes_cap() RETURNING p_status

           IF NOT p_status THEN
              CALL log0030_mensagem('Problemas durante geração de AD.','exclamation')
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP
              RETURN
           END IF

           WHENEVER ERROR CONTINUE
           INSERT INTO cdv_solic_adto_781(empresa,
                                          viagem,
                                          sequencia_adto,
                                          dat_adto_viagem,
                                          val_adto_viagem,
                                          forma_adto_viagem,
                                          banco,
                                          agencia,
                                          cta_corrente,
                                          num_ad_adto_viagem)
                                  VALUES (mr_tela.empresa,
                                          mr_tela.viagem,
                                          1,
                                          TODAY,
                                          mr_tela.val_adto_viagem,
                                          mr_tela.forma_adto_viagem,
                                          mr_tela.banco,
                                          mr_tela.agencia,
                                          mr_tela.cta_corrente,
                                          mr_tela.ad_adiantamento)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN

              IF mr_tela.forma_adto_viagem = "DC" THEN
                 #INICIO OS.470958
                 CALL log2250_busca_parametro(mr_tela.empresa, "tv_cpmf")
                      RETURNING m_val_tv_cpmf, p_status

                 IF p_status = FALSE OR m_val_tv_cpmf IS NULL THEN
                    LET l_observ = "Parametro tipo valor de CPMF no log2240 não cadastrado."
                    IF NOT cdv2001_insere_ap_observ(l_observ) THEN
                       RETURN
                    END IF
                 ELSE
                    WHENEVER ERROR CONTINUE
                      SELECT perc_val_princ
                        INTO l_perc_val_princ
                        FROM tipo_valor
                       WHERE cod_empresa = mr_tela.empresa
                         AND cod_tip_val = m_val_tv_cpmf
                    WHENEVER ERROR STOP

                    IF sqlca.sqlcode = 0 THEN
                       IF l_perc_val_princ IS NOT NULL THEN
                          IF l_perc_val_princ > 0 THEN
                             WHENEVER ERROR CONTINUE
                               SELECT MAX (num_seq)
                                 INTO l_num_seq
                                 FROM ap_valores
                                WHERE cod_empresa      = mr_tela.empresa
                                  AND num_ap           = mr_tela.ap_adiantamento
                                  AND ies_versao_atual = "S"
                             WHENEVER ERROR STOP

                             IF l_num_seq = 0 OR l_num_seq IS NULL THEN
                                LET l_num_seq = 1
                             ELSE
                                LET l_num_seq = l_num_seq + 1
                             END IF

                             WHENEVER ERROR CONTINUE
                               SELECT val_nom_ap
                                 INTO l_val_nom_ap
                                 FROM ap
                                WHERE cod_empresa      = mr_tela.empresa
                                  AND num_ap           = mr_tela.ap_adiantamento
                                  AND ies_versao_atual = "S"
                             WHENEVER ERROR STOP

                             LET l_valor = l_val_nom_ap * l_perc_val_princ / 100

                             WHENEVER ERROR CONTINUE
                               INSERT INTO ap_valores (cod_empresa,
                                                       num_ap,
                                                       num_versao,
                                                       ies_versao_atual,
                                                       num_seq,
                                                       cod_tip_val,
                                                       valor)
                                               VALUES  (mr_tela.empresa,
                                                        mr_tela.ap_adiantamento,
                                                        1, "S",
                                                        l_num_seq,
                                                        m_val_tv_cpmf,
                                                        l_valor)
                             WHENEVER ERROR STOP

                             IF sqlca.sqlcode <> 0 THEN
                                CALL log003_err_sql("INSERT", "AP_VALORES")
                                RETURN
                             END IF
                          END IF
                       ELSE
                          LET l_observ = "Tipo valor ", m_val_tv_cpmf USING "##&", " não cadastrado."
                          IF NOT cdv2001_insere_ap_observ(l_observ) THEN
                             RETURN
                          END IF
                       END IF
                    END IF
                 END IF
                 #FIM OS.470958
              END IF

              IF NOT cdv2001_gera_aprovacao_eletronica(mr_tela.viagem,
                                                       mr_tela.ad_adiantamento,
                                                       mr_tela.ap_adiantamento) THEN
                 RETURN
              END IF
              LET m_modifica_inclusao = TRUE
           ELSE
              CALL log003_err_sql('INCLUSAO','CDV_SOLIC_ADTO_781')
              CALL log085_transacao("ROLLBACK")
              RETURN
           END IF
        END IF
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP
        MESSAGE 'Inclusão efetuada com sucesso. '
        ERROR " "
        CALL cdv2001_alimenta_consulta()
        CALL cdv2001_lista()

     ELSE
        LET mr_tela.* = mr_telar.*
        CALL cdv2001_exibe_dados1()
        ERROR ' Inclusão cancelada. '
     END IF
  ELSE
     LET mr_tela.* = mr_telar.*
     CALL cdv2001_exibe_dados1()
     ERROR ' Inclusão cancelada. '
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2001_gera_informacoes_cap()
#---------------------------------------#
  DEFINE l_work               SMALLINT,
         l_msg                CHAR(100),
         l_num_ad             LIKE ad_mestre.num_ad,
         l_num_ap             LIKE ad_mestre.num_ad,
         l_ind_aen            INTEGER,
         l_ies_sup_cap        LIKE ad_mestre.ies_sup_cap

  DEFINE l_aux_cod_fornecedor LIKE cdv_fornecedor_fun.cod_fornecedor,
         l_aux_ies_dep_cred   CHAR(01),
         l_aux_tip_desp       LIKE cdv_par_ctr_viagem.tip_desp_adto_viag

  LET l_aux_tip_desp = cdv2001_carrega_cdv_par_ctr_viagem()

  LET l_aux_cod_fornecedor = cdv2001_carrega_fornecedor()

  IF mr_tela.forma_adto_viagem = "DC" THEN
     LET l_aux_ies_dep_cred = "S"
  ELSE
     LET l_aux_ies_dep_cred = "N"
  END IF

  CALL cdv2001_monta_aen() RETURNING p_status

  IF p_status THEN
     RETURN FALSE
  END IF

  LET t_aen_309_4[1].val_aen = mr_tela.val_adto_viagem

  CALL cdv2001_monta_aen4()

  CALL cap309_gera_informacoes_cap("S",
                                   l_aux_tip_desp,
                                   mr_tela.viagem,
                                   "V",
                                   1,
                                   TODAY,
                                   l_aux_cod_fornecedor,
                                   mr_tela.val_adto_viagem,
                                   "INCLUSAO VIA CDV2001",
                                   l_aux_ies_dep_cred,
                                   mr_tela.banco,
                                   mr_tela.agencia,
                                   mr_tela.cta_corrente,
                                   "",
                                   "",
                                   "",
                                   "",
                                   "",
                                   "",
                                   TODAY) RETURNING l_work, l_msg, l_num_ad, l_num_ap
  IF NOT l_work THEN
     INITIALIZE mr_tela.ad_adiantamento, mr_tela.ap_adiantamento TO NULL
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  ELSE
     LET mr_tela.ad_adiantamento = l_num_ad
     LET mr_tela.ap_adiantamento = l_num_ap
  END IF

  IF NOT cdv0804_geracao_aen(l_num_ad) THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM ap_obser
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
      AND observ = " AP INCLUIDA PELO SUPRIMENTOS"
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('UPDATE','ap_obser')
     RETURN FALSE
  END IF

  IF NOT cdv2001_verifica_ad_tot_aprovada(l_num_ad) THEN
     LET l_ies_sup_cap = 'Q'
  ELSE
     LET l_ies_sup_cap = 'C'
  END IF

  IF l_num_ad IS NOT NULL THEN
     WHENEVER ERROR CONTINUE
      UPDATE ad_mestre
         SET ies_sup_cap = l_ies_sup_cap
       WHERE cod_empresa = p_cod_empresa
         AND num_ad      = l_num_ad
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','ad_mestre')
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION cdv2001_carrega_fornecedor()
#-------------------------------------#

  DEFINE l_cod_funcio LIKE cdv_fornecedor_fun.cod_funcio,
         l_aux_cod_fornecedor LIKE cdv_fornecedor_fun.cod_fornecedor

  LET l_cod_funcio = mr_tela.viajante

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_aux_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_aux_cod_fornecedor TO NULL
  END IF

  RETURN l_aux_cod_fornecedor

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2001_carrega_cdv_par_ctr_viagem()
#---------------------------------------------#

  DEFINE l_aux_tip_desp LIKE cdv_par_ctr_viagem.tip_desp_adto_viag

  WHENEVER ERROR CONTINUE
  SELECT tip_desp_adto_viag
    INTO l_aux_tip_desp
    FROM cdv_par_ctr_viagem
   WHERE empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_aux_tip_desp TO NULL
  END IF

  RETURN l_aux_tip_desp

END FUNCTION

#------------------------------#
 FUNCTION cdv2001_monta_aen4()
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

#----------------------------------------#
 FUNCTION cdv2001_entrada_dados1(l_funcao)
#----------------------------------------#

  DEFINE l_funcao CHAR(12),
         l_hora   DATETIME HOUR TO SECOND,
         l_msg    CHAR(200)

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_cdv2001

  LET int_flag = FALSE

  DISPLAY p_cod_empresa TO empresa

  IF l_funcao = "INCLUSAO" THEN
     LET mr_tela.empresa = p_cod_empresa
     LET mr_tela.viagem = cdv2001_carrega_numero_viagem()
     LET mr_tela.dat_hr_emis_solic = TODAY #CURRENT YEAR TO SECOND
     LET mr_tela.hora              = TIME
     LET mr_tela.cc_debitar = cdv2001_carrega_cc_debitar()
     DISPLAY BY NAME mr_tela.empresa,
                     mr_tela.viagem,
                     mr_tela.dat_hr_emis_solic,
                     mr_tela.cc_debitar,
                     mr_tela.hora

     CALL cdv2001_busca_clientes()
     RETURNING mr_tela.cliente_atendido,
               mr_tela.cliente_fatur
     DISPLAY BY NAME mr_tela.cliente_atendido,
                     mr_tela.cliente_fatur
  END IF

  INPUT BY NAME mr_tela.viajante,
                mr_tela.finalidade_viagem,
                mr_tela.controle,
                mr_tela.cc_viajante,
                mr_tela.cc_debitar,
                mr_tela.cliente_atendido,
                mr_tela.cliente_fatur,
                mr_tela.empresa_atendida,
                mr_tela.den_empresa_atendida,
                mr_tela.den_filial_atendida,
                mr_tela.filial_atendida WITHOUT DEFAULTS


    BEFORE FIELD viajante
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    AFTER FIELD viajante
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF mr_tela.viajante IS NULL OR mr_tela.viajante = " " THEN
          INITIALIZE m_den_viajante TO NULL
          DISPLAY m_den_viajante TO den_viajante
       ELSE
          IF NOT cdv2001_verifica_viajante() THEN
             CALL log0030_mensagem("Viajante não cadastrado. ","info")
             NEXT FIELD viajante
          END IF
          DISPLAY m_den_viajante TO den_viajante
       END IF

    BEFORE FIELD finalidade_viagem
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    AFTER FIELD finalidade_viagem
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD viajante
       END IF
       LET m_verifica_periodo_viagem = FALSE
       IF mr_tela.finalidade_viagem IS NULL OR
          mr_tela.finalidade_viagem = " " THEN
          INITIALIZE m_den_finalidade_viagem TO NULL
          DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
       ELSE
          IF NOT cdv2001_verifica_finalidade_viagem(mr_tela.finalidade_viagem) THEN
             CALL log0030_mensagem("Finalidade não cadastrada. ","info")
             NEXT FIELD finalidade_viagem
          END IF
          DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
       END IF
       #CASE mr_tela.finalidade_viagem[1,2]
       #   WHEN "02"
       #      DISPLAY "Processo:" AT 6,46
       #   WHEN "03"
       #      DISPLAY " Projeto:" AT 6,46
       #   OTHERWISE
       #      DISPLAY "Controle:" AT 6,46
       #END CASE


    BEFORE FIELD controle
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
       IF NOT cdv2001_verifica_eh_controle_obrig() THEN
          IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
             FGL_LASTKEY() = FGL_KEYVAL("left") THEN
             NEXT FIELD finalidade_viagem
          END IF
       END IF

    AFTER FIELD controle
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD finalidade_viagem
       END IF

       IF mr_tela.controle IS NOT NULL
       AND mr_tela.controle <> " " THEN
          IF mr_tela.controle < m_controle_minimo THEN
             LET l_msg = 'Somente podera ser utilizado controle maior ou igual a ', m_controle_minimo USING "<<<<<<<<<<"
             CALL log0030_mensagem(l_msg,"exclamation")
             NEXT FIELD controle
          END IF
       END IF

       IF cdv2001_verifica_eh_controle_obrig() THEN
          IF mr_tela.controle IS NOT NULL OR mr_tela.controle <> " " THEN
             IF mr_tela.cliente_atendido IS NOT NULL AND mr_tela.cliente_fatur IS NOT NULL THEN
                IF NOT cdv2001_verifica_controle(mr_tela.controle, mr_tela.cliente_atendido, mr_tela.cliente_fatur) THEN
                   NEXT FIELD controle
                END IF
             ELSE
                IF NOT cdv2001_verifica_controle(mr_tela.controle,"","") THEN
                   NEXT FIELD controle
                END IF
             END IF

             CALL cdv2001_busca_clientes_ate_fat(mr_tela.controle)
                  RETURNING mr_tela.cliente_atendido, mr_tela.cliente_fatur

             LET m_den_cliente_atendido = cdv2001_busca_den_cliente(mr_tela.cliente_atendido)
             DISPLAY BY NAME mr_tela.cliente_atendido
             DISPLAY m_den_cliente_atendido TO den_cliente_atendido

             IF NOT cdv2001_verifica_cliente_faturar(mr_tela.cliente_fatur) THEN END IF
             DISPLAY BY NAME mr_tela.cliente_fatur
             DISPLAY m_den_cliente_fatur TO den_cliente_fatur

          END IF

          IF mr_tela.controle IS NOT NULL
          AND mr_tela.finalidade_viagem IS NOT NULL THEN
             IF NOT cdv2001_verifica_controle_finalidade(mr_tela.controle, mr_tela.finalidade_viagem) THEN
                  CALL log0030_mensagem('Controle não cadastrado para essa finalidade ou encerrado.','exclamation')
                  NEXT FIELD finalidade_viagem
             END IF
          END IF

       END IF

    BEFORE FIELD cc_viajante
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
       IF mr_tela.cc_viajante IS NULL OR
          mr_tela.cc_viajante = " " THEN
          LET mr_tela.cc_viajante = cdv2001_carrega_cc_viajante(mr_tela.viajante)
          DISPLAY BY NAME mr_tela.cc_viajante
          DISPLAY m_den_cc_viajante TO den_cc_viajante
       END IF
       IF  mr_tela.cc_viajante IS NOT NULL
       AND mr_tela.cc_viajante <> " " THEN
          IF FGL_LASTKEY() = FGL_KEYVAL("UP")
          OR FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
             NEXT FIELD finalidade_viagem
          ELSE
             NEXT FIELD cc_debitar
          END IF
       END IF


    AFTER FIELD cc_viajante
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD controle
       END IF
       IF mr_tela.cc_viajante IS NULL OR
          mr_tela.cc_viajante = " " THEN
          INITIALIZE m_den_cc_viajante TO NULL
          DISPLAY m_den_cc_viajante TO den_cc_viajante
       ELSE
          IF NOT cdv2001_verifica_cc_viajante(mr_tela.cc_viajante) THEN
             CALL log0030_mensagem("Centro de custo não cadastrado. ","info")
             NEXT FIELD cc_viajante
          END IF
          DISPLAY m_den_cc_viajante TO den_cc_viajante
      END IF

    BEFORE FIELD cc_debitar
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    AFTER FIELD cc_debitar
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD cc_viajante
       END IF
       IF mr_tela.cc_debitar IS NULL OR
          mr_tela.cc_debitar = " " THEN
          INITIALIZE m_den_cc_debitar TO NULL
          DISPLAY m_den_cc_debitar TO den_cc_debitar
       ELSE
          IF NOT cdv2001_verifica_cc_debitar(mr_tela.cc_debitar) THEN
             CALL log0030_mensagem("Centro de custo não cadastrado. ","info")
             NEXT FIELD cc_debitar
          END IF
          DISPLAY m_den_cc_debitar TO den_cc_debitar
       END IF

    BEFORE FIELD cliente_atendido
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

    AFTER FIELD cliente_atendido
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD cc_debitar
       END IF
       IF mr_tela.cliente_atendido IS NULL OR
          mr_tela.cliente_atendido = " " THEN
          INITIALIZE m_den_cliente_atendido TO NULL
          DISPLAY m_den_cliente_atendido TO den_cliente_atendido
       ELSE
          LET m_den_cliente_atendido = cdv2001_busca_den_cliente(mr_tela.cliente_atendido)
          DISPLAY m_den_cliente_atendido TO den_cliente_atendido
       END IF

    BEFORE FIELD cliente_fatur
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

    AFTER FIELD cliente_fatur
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD cliente_atendido
       END IF
       IF mr_tela.cliente_fatur IS NULL OR
          mr_tela.cliente_fatur = " " THEN
          INITIALIZE m_den_cliente_fatur TO NULL
          DISPLAY m_den_cliente_fatur TO den_cliente_fatur
       ELSE
          IF NOT cdv2001_verifica_cliente_faturar(mr_tela.cliente_fatur) THEN
             CALL log0030_mensagem("Cliente não cadastrado. ","info")
             NEXT FIELD cliente_fatur
          END IF
          DISPLAY m_den_cliente_fatur TO den_cliente_fatur
       END IF

    BEFORE FIELD empresa_atendida
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    AFTER FIELD empresa_atendida
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD cliente_fatur
       END IF
       IF mr_tela.empresa_atendida IS NULL OR
          mr_tela.empresa_atendida = " " THEN
       ELSE
          IF NOT cdv2001_verifica_empresa_filial_atendida(mr_tela.empresa_atendida, "MAT") THEN
             NEXT FIELD empresa_atendida
          ELSE
             LET mr_tela.den_empresa_atendida = cdv2001_busca_den_empresa_reduz(mr_tela.empresa_atendida)
             DISPLAY BY NAME mr_tela.den_empresa_atendida
          END IF
       END IF

    BEFORE FIELD filial_atendida
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    AFTER FIELD filial_atendida
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z', null)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD empresa_atendida
       END IF
       IF mr_tela.filial_atendida IS NULL OR
          mr_tela.filial_atendida = " " THEN
       ELSE
          IF NOT cdv2001_verifica_empresa_filial_atendida(mr_tela.filial_atendida,"FIL") THEN
             NEXT FIELD filial_atendida
          ELSE
             LET mr_tela.den_filial_atendida = cdv2001_busca_den_empresa_reduz(mr_tela.filial_atendida)
             DISPLAY BY NAME mr_tela.den_filial_atendida
          END IF
      END IF

    AFTER INPUT
       IF NOT INT_FLAG THEN
          IF mr_tela.viajante IS NULL OR
             mr_tela.viajante = " " THEN
             CALL log0030_mensagem("Viajante não informado.","info")
             NEXT FIELD viajante
          END IF
          IF mr_tela.finalidade_viagem IS NULL OR
             mr_tela.finalidade_viagem = " " THEN
             CALL log0030_mensagem("Finalidade não informada.","info")
             NEXT FIELD finalidade_viagem
          END IF
          IF cdv2001_verifica_eh_controle_obrig() THEN
             IF mr_tela.controle IS NOT NULL OR mr_tela.controle <> " " THEN
                IF mr_tela.cliente_atendido IS NOT NULL AND mr_tela.cliente_fatur IS NOT NULL THEN
                   IF NOT cdv2001_verifica_controle(mr_tela.controle, mr_tela.cliente_atendido, mr_tela.cliente_fatur) THEN
                      NEXT FIELD controle
                   END IF
                ELSE
                   IF NOT cdv2001_verifica_controle(mr_tela.controle,"","") THEN
                      NEXT FIELD controle
                   END IF
                END IF

                IF NOT cdv2001_verifica_controle_finalidade(mr_tela.controle, mr_tela.finalidade_viagem) THEN
                     CALL log0030_mensagem('Controle não cadastrado para essa finalidade ou encerrado.','exclamation')
                     NEXT FIELD finalidade_viagem
                END IF

             END IF
          END IF
          IF mr_tela.cc_viajante IS NULL OR
             mr_tela.cc_viajante = " " THEN
             CALL log0030_mensagem("Centro de custo viajante não informado.","info")
             NEXT FIELD cc_viajante
          END IF
          IF mr_tela.cc_debitar IS NULL OR
             mr_tela.cc_debitar = " " THEN
             CALL log0030_mensagem("Centro de custo debitar não informado.","info")
             NEXT FIELD cc_debitar
          END IF
          IF mr_tela.cliente_atendido IS NULL OR
             mr_tela.cliente_atendido = " " THEN
             CALL log0030_mensagem("Cliente atendido não informado.","info")
             NEXT FIELD cliente_atendido
          END IF
          IF mr_tela.cliente_fatur IS NULL OR
             mr_tela.cliente_fatur = " " THEN
             CALL log0030_mensagem("Cliente faturar não informado.","info")
             NEXT FIELD cliente_fatur
          END IF
          IF mr_tela.empresa_atendida IS NULL OR
             mr_tela.empresa_atendida = " " THEN
             CALL log0030_mensagem("Empresa atendida não informada.","info")
             NEXT FIELD empresa_atendida
          END IF
          IF mr_tela.filial_atendida IS NULL OR
             mr_tela.filial_atendida = " " THEN
             CALL log0030_mensagem("Filial não informada.","info")
             NEXT FIELD filial_atendida
          END IF
       END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
       CALL cdv2001_help()
       CURRENT WINDOW IS w_cdv2001

    ON KEY (control-z, f4)
       CALL cdv2001_popup()
   --# CALL fgl_dialog_setkeylabel('control-z',NULL)
       CALL log006_exibe_teclas("01 02 03 07", p_versao)
       CURRENT WINDOW IS w_cdv2001
  END INPUT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2001

  IF INT_FLAG THEN
     LET int_flag = FALSE
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2001_entrada_dados2(l_funcao)
#----------------------------------------#
  DEFINE l_funcao CHAR(12)

  IF l_funcao = "INCLUSAO" THEN
     CALL log006_exibe_teclas("01", p_versao)
     CALL log130_procura_caminho("CDV20011") RETURNING m_caminho
     OPEN WINDOW w_cdv20011 AT 2,2 WITH FORM m_caminho
          ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  END IF

  DISPLAY p_cod_empresa TO empresa
  DISPLAY BY NAME mr_tela.controle

  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_cdv20011

  LET int_flag = FALSE

  DISPLAY p_cod_empresa TO empresa

  IF l_funcao = "INCLUSAO" THEN
     DISPLAY BY NAME mr_tela.empresa,
                     mr_tela.viagem
     LET mr_tela.ies_solic_adto = "S"
     DISPLAY BY NAME mr_tela.ies_solic_adto
     LET mr_tela.forma_adto_viagem = "DN"
     DISPLAY BY NAME mr_tela.forma_adto_viagem
  END IF

  INPUT BY NAME mr_tela.trajeto_principal,
                mr_tela.dat_hor_partida,
                mr_tela.hora_partida,
                mr_tela.dat_hor_retorno,
                mr_tela.hora_retorno,
                mr_tela.motivo_viagem,
                mr_tela.ies_solic_adto,
                mr_tela.val_adto_viagem,
                mr_tela.forma_adto_viagem,
                mr_tela.banco,
                mr_tela.agencia,
                mr_tela.cta_corrente,
                mr_tela.ad_adiantamento,
                mr_tela.ap_adiantamento WITHOUT DEFAULTS

    BEFORE FIELD dat_hor_partida
       IF mr_tela.dat_hor_partida IS NULL THEN
          LET mr_tela.dat_hor_partida = TODAY
          DISPLAY BY NAME mr_tela.dat_hor_partida
       END IF

    AFTER FIELD dat_hor_partida
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD trajeto_principal
       END IF

    BEFORE FIELD hora_partida
       IF mr_tela.hora_partida IS NULL THEN
          LET mr_tela.hora_partida = '08:00:00'
          DISPLAY BY NAME mr_tela.hora_partida
       END IF

    AFTER FIELD hora_partida
       IF mr_tela.dat_hor_partida IS NOT NULL THEN
          IF m_verifica_periodo_viagem = 'S' THEN
             IF cdv2001_verifica_dat_hor_periodo(mr_tela.dat_hor_partida, mr_tela.hora_partida, "P") THEN
                NEXT FIELD dat_hor_partida
             END IF
          END IF
          IF mr_tela.dat_hor_partida < mr_tela.dat_hr_emis_solic THEN
             CALL log0030_mensagem("Data de partida anterior a data de solicitação.","info")
             NEXT FIELD dat_hor_partida
          END IF
       END IF

    BEFORE FIELD dat_hor_retorno
       IF mr_tela.dat_hor_retorno IS NULL THEN
          LET mr_tela.dat_hor_retorno = TODAY
          DISPLAY BY NAME mr_tela.dat_hor_retorno
       END IF

    AFTER FIELD dat_hor_retorno
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD dat_hor_partida
       END IF
       IF mr_tela.dat_hor_retorno IS NOT NULL THEN
          IF mr_tela.dat_hor_retorno < mr_tela.dat_hr_emis_solic THEN
             CALL log0030_mensagem("Data de retorno anterior a data de solcitação.","info")
             NEXT FIELD dat_hor_retorno
          END IF
       END IF

    BEFORE FIELD hora_retorno
       IF mr_tela.hora_retorno IS NULL THEN
          LET mr_tela.hora_retorno = '18:00:00'
          DISPLAY BY NAME mr_tela.hora_retorno
       END IF

    AFTER FIELD hora_retorno
       IF mr_tela.dat_hor_retorno IS NOT NULL THEN
          IF m_verifica_periodo_viagem = 'S' THEN
             IF cdv2001_verifica_dat_hor_periodo(mr_tela.dat_hor_retorno, mr_tela.hora_retorno, "R") THEN
                NEXT FIELD dat_hor_retorno
             END IF
          END IF
          IF mr_tela.dat_hor_partida > mr_tela.dat_hor_retorno THEN
             CALL log0030_mensagem("Data de partida posterior a data de retorno.","info")
             NEXT FIELD dat_hor_partida
          END IF
       END IF

    AFTER FIELD motivo_viagem
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD dat_hor_retorno
       END IF

    BEFORE FIELD ies_solic_adto
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF
    AFTER FIELD ies_solic_adto
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD motivo_viagem
       END IF
       IF mr_tela.ies_solic_adto IS NULL OR
          mr_tela.ies_solic_adto = " " THEN
          INITIALIZE m_den_banco TO NULL
          DISPLAY m_den_banco TO den_banco
       ELSE
          IF mr_tela.ies_solic_adto NOT MATCHES "[SN]" THEN
             NEXT FIELD ies_solic_adto
          END IF
          IF mr_tela.ies_solic_adto = "N" THEN
             INITIALIZE mr_tela.val_adto_viagem,
                        mr_tela.forma_adto_viagem,
                        mr_tela.banco,
                        mr_tela.agencia,
                        mr_tela.cta_corrente,
                        mr_tela.ad_adiantamento,
                        mr_tela.ap_adiantamento,
                        m_den_banco TO NULL
             DISPLAY BY NAME mr_tela.val_adto_viagem,
                             mr_tela.forma_adto_viagem,
                             mr_tela.banco,
                             mr_tela.agencia,
                             mr_tela.cta_corrente,
                             mr_tela.ad_adiantamento,
                             mr_tela.ap_adiantamento
             DISPLAY m_den_banco TO den_banco
             #EXIT INPUT
             #GOTO final_input
             NEXT FIELD ap_adiantamento
          END IF
       END IF

    BEFORE FIELD val_adto_viagem
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF

    AFTER FIELD val_adto_viagem
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD ies_solic_adto
       END IF
       IF mr_tela.val_adto_viagem IS NULL OR
          mr_tela.val_adto_viagem = " " THEN
             CALL log0030_mensagem('Valor do adiantamento não informado.','exclamation')
             NEXT FIELD val_adto_viagem
       ELSE
          IF mr_tela.val_adto_viagem > 0 THEN
          ELSE
             CALL log0030_mensagem("Valor deve ser positivo. ","info")
             NEXT FIELD val_adto_viagem
          END IF
       END IF
       {IF cdv2001_busca_valores(mr_tela.viajante) THEN
       END IF}

    BEFORE FIELD forma_adto_viagem
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF

    AFTER FIELD forma_adto_viagem
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD val_adto_viagem
       END IF
       IF mr_tela.forma_adto_viagem IS NULL OR
          mr_tela.forma_adto_viagem = " " THEN
       ELSE
          IF mr_tela.forma_adto_viagem <> "DC" AND
             mr_tela.forma_adto_viagem <> "DN" THEN
             MESSAGE "DC - Depósito em conta corrente   DN - Pago em dinheiro"
             NEXT FIELD forma_adto_viagem
          END IF
          IF mr_tela.forma_adto_viagem = "DN" THEN
             INITIALIZE mr_tela.banco,
                        mr_tela.agencia,
                        mr_tela.cta_corrente TO NULL
             DISPLAY BY NAME mr_tela.banco,
                             mr_tela.agencia,
                             mr_tela.cta_corrente

             #EXIT INPUT
             #GOTO final_input
             NEXT FIELD ap_adiantamento
          END IF
       END IF
       MESSAGE ''
       IF cdv2001_busca_valores(mr_tela.viajante) THEN
          #GOTO final_input
          NEXT FIELD ap_adiantamento
       END IF

    BEFORE FIELD banco
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF
    AFTER FIELD banco
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD forma_adto_viagem
       END IF
       IF mr_tela.banco IS NULL OR
          mr_tela.banco = " " THEN
          INITIALIZE m_den_banco TO NULL
          DISPLAY m_den_banco TO den_banco
       ELSE
          IF NOT cdv2001_verifica_banco(mr_tela.banco) THEN
             CALL log0030_mensagem("Banco não cadastrado. ","info")
             NEXT FIELD banco
          END IF
          DISPLAY m_den_banco TO den_banco
       END IF

    BEFORE FIELD agencia
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF
    AFTER FIELD agencia
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD banco
       END IF

    BEFORE FIELD cta_corrente
       IF l_funcao = "MODIFICACAO" THEN
          NEXT FIELD motivo_viagem
       END IF
    AFTER FIELD cta_corrente
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD agencia
       END IF

    AFTER INPUT
      #LABEL final_input:
       IF NOT INT_FLAG THEN
          IF mr_tela.trajeto_principal IS NULL OR
             mr_tela.trajeto_principal = " " THEN
             CALL log0030_mensagem("Trajeto principal não informado.","info")
             NEXT FIELD trajeto_principal
          END IF
          IF mr_tela.dat_hor_partida IS NULL THEN
             CALL log0030_mensagem("Data de partida não informada.","info")
             NEXT FIELD dat_hor_partida
          END IF
          IF mr_tela.dat_hor_retorno IS NULL THEN
             CALL log0030_mensagem("Data de retorno não informada.","info")
             NEXT FIELD dat_hor_retorno
          END IF

          IF m_verifica_periodo_viagem = 'S' THEN
             IF cdv2001_verifica_dat_hor_periodo(mr_tela.dat_hor_partida, mr_tela.hora_partida, "P") THEN
                NEXT FIELD dat_hor_partida
             END IF
             IF cdv2001_verifica_dat_hor_periodo(mr_tela.dat_hor_retorno, mr_tela.hora_retorno,"R") THEN
                NEXT FIELD dat_hor_retorno
             END IF
          END IF

          IF mr_tela.dat_hor_partida > mr_tela.dat_hor_retorno THEN
             CALL log0030_mensagem("Data de partida posterior a data de retorno.","info")
             NEXT FIELD dat_hor_partida
          END IF

          IF mr_tela.dat_hor_partida < mr_tela.dat_hr_emis_solic THEN
             CALL log0030_mensagem("Data de partida anterior a data de solicitação.","info")
             NEXT FIELD dat_hor_partida
          END IF

          IF mr_tela.dat_hor_retorno < mr_tela.dat_hr_emis_solic THEN
             CALL log0030_mensagem("Data de retorno anterior a data de solcitação.","info")
             NEXT FIELD dat_hor_retorno
          END IF

          IF mr_tela.motivo_viagem IS NULL OR
             mr_tela.motivo_viagem = " " THEN
             CALL log0030_mensagem("Motivo da viagem não informado.","info")
             NEXT FIELD motivo_viagem
          END IF
          IF mr_tela.ies_solic_adto IS NULL OR
             mr_tela.ies_solic_adto = " " THEN
             CALL log0030_mensagem("Solicitação de adiantamento não informada.","info")
             NEXT FIELD ies_solic_adto
          END IF
          IF mr_tela.ies_solic_adto = 'S' THEN
             IF mr_tela.val_adto_viagem IS NULL OR
                mr_tela.val_adto_viagem = " " THEN
                CALL log0030_mensagem("Valor do adiantamento não informado.","info")
                NEXT FIELD val_adto_viagem
             END IF
             IF mr_tela.forma_adto_viagem IS NULL OR
                mr_tela.forma_adto_viagem = " " THEN
                CALL log0030_mensagem("Forma de adiantamento não informada.","info")
                NEXT FIELD forma_adto_viagem
             END IF
             IF mr_tela.forma_adto_viagem = 'DC' THEN
                IF mr_tela.banco IS NULL
                OR mr_tela.banco = " " THEN
                   CALL log0030_mensagem('Banco não informado.','exclamation')
                   NEXT FIELD banco
                END IF
                IF mr_tela.agencia IS NULL
                OR mr_tela.agencia = " " THEN
                   CALL log0030_mensagem('Agência não informada.','exclamation')
                   NEXT FIELD agencia
                END IF
                IF mr_tela.cta_corrente IS NULL
                OR mr_tela.cta_corrente = " " THEN
                   CALL log0030_mensagem('Conta corrente não informada.','exclamation')
                   NEXT FIELD cta_corrente
                END IF
             END IF
          END IF
          IF NOT log0040_confirm(10,20,"Confirma solicitação?") THEN
             NEXT FIELD trajeto_principal
          END IF
       END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
       CALL cdv2001_help()
       CURRENT WINDOW IS w_cdv20011
    ON KEY (control-z, f4)
       CALL cdv2001_popup()
   --# CALL fgl_dialog_setkeylabel('control-z',NULL)
       CALL log006_exibe_teclas("01 02 03 07", p_versao)
       CURRENT WINDOW IS w_cdv20011

  END INPUT

  IF l_funcao = "INCLUSAO" THEN
     CLOSE WINDOW w_cdv20011
     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_cdv2001
  END IF

  IF INT_FLAG THEN
     LET int_flag = FALSE
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#-----------------------#
 FUNCTION cdv2001_help()
#-----------------------#

  CASE
     WHEN INFIELD(viagem)            CALL showhelp(101)
     WHEN INFIELD(controle)          CALL showhelp(102)
     WHEN INFIELD(dat_hr_emis_solic) CALL showhelp(103)
     WHEN INFIELD(viajante)          CALL showhelp(104)
     WHEN INFIELD(finalidade_viagem) CALL showhelp(105)
     WHEN INFIELD(cc_viajante)       CALL showhelp(106)
     WHEN INFIELD(cc_debitar)        CALL showhelp(107)
     WHEN INFIELD(cliente_atendido)  CALL showhelp(108)
     WHEN INFIELD(cliente_fatur)     CALL showhelp(109)
     WHEN INFIELD(empresa_atendida)  CALL showhelp(110)
     WHEN INFIELD(filial_atendida)   CALL showhelp(111)
     WHEN INFIELD(trajeto_principal) CALL showhelp(112)
     WHEN INFIELD(dat_hor_partida)   CALL showhelp(113)
     WHEN INFIELD(dat_hor_retorno)   CALL showhelp(114)
     WHEN INFIELD(motivo_viagem)     CALL showhelp(115)
     WHEN INFIELD(ies_solic_adto)    CALL showhelp(116)
     WHEN INFIELD(val_adto_viagem)   CALL showhelp(117)
     WHEN INFIELD(forma_adto_viagem) CALL showhelp(118)
     WHEN INFIELD(banco)             CALL showhelp(119)
     WHEN INFIELD(agencia)           CALL showhelp(120)
     WHEN INFIELD(cta_corrente)      CALL showhelp(121)
     WHEN INFIELD(ad_adiantamento)   CALL showhelp(122)
     WHEN INFIELD(ap_adiantamento)   CALL showhelp(123)
  END CASE

END FUNCTION


#----------------------------------------#
 FUNCTION cdv2001_carrega_numero_viagem()
#----------------------------------------#

  DEFINE l_numero_viagem LIKE cdv_solic_viag_781.viagem

  INITIALIZE l_numero_viagem TO NULL

  CALL log2250_busca_parametro(p_cod_empresa,"numero_viagem_pamcary") RETURNING l_numero_viagem, p_status
  IF p_status = FALSE OR
     l_numero_viagem IS NULL OR
     l_numero_viagem = " " THEN
     LET l_numero_viagem = 1
  END IF

  RETURN l_numero_viagem

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2001_carrega_viajante(l_usuario_logix)
#--------------------------------------------------#

  DEFINE l_usuario_logix LIKE cdv_info_viajante.usuario_logix,
         l_viajante      LIKE cdv_solic_viag_781.viajante

  WHENEVER ERROR CONTINUE
  SELECT matricula
    INTO l_viajante
    FROM cdv_info_viajante
   WHERE empresa = p_cod_empresa
     AND usuario_logix = l_usuario_logix
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_viajante TO NULL
  END IF

  RETURN l_viajante

END FUNCTION


#-------------------------------------#
 FUNCTION cdv2001_carrega_cc_debitar()
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

#----------------------------------------------------------#
 FUNCTION cdv2001_carrega_cc_viajante(l_matricula_viajante)
#----------------------------------------------------------#

  DEFINE l_matricula_viajante LIKE cdv_relat_viagem.matricula_viajante,
         l_cod_centro_custo   LIKE unidade_funcional.cod_centro_custo,
         l_nom_cent_cust      LIKE cad_cc.nom_cent_cust,
         l_empresa_rhu        LIKE cdv_info_viajante.empresa_rhu,
         l_uni_func_viaj      CHAR(10),
         l_cod_empresa_plano  LIKE par_con.cod_empresa_plano

  INITIALIZE l_cod_centro_custo, l_nom_cent_cust TO NULL

  WHENEVER ERROR CONTINUE
   SELECT empresa_rhu
     INTO l_empresa_rhu
     FROM cdv_info_viajante
    WHERE empresa   = p_cod_empresa
      AND matricula = l_matricula_viajante
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     INITIALIZE l_cod_centro_custo,
                m_den_cc_viajante TO NULL
     RETURN l_cod_centro_custo
  END IF

  WHENEVER ERROR CONTINUE
   SELECT parametro_texto[01,10]
     INTO l_uni_func_viaj
     FROM cdv_par_viajante
    WHERE empresa     = p_cod_empresa
      AND matricula   = l_matricula_viajante
      AND empresa_rhu = l_empresa_rhu
      AND parametro   = 'uni_func_viaj'
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     INITIALIZE l_cod_centro_custo,
                m_den_cc_viajante TO NULL
     RETURN l_cod_centro_custo
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
       WHERE cod_empresa      = l_empresa_rhu  #p_cod_empresa
         AND cod_uni_funcio   = l_uni_func_viaj
         AND dat_validade_fim > TODAY
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        INITIALIZE l_cod_centro_custo,
                   m_den_cc_viajante TO NULL
        RETURN l_cod_centro_custo
     END IF
  ELSE
     IF SQLCA.SQLCODE <> 0 THEN
        INITIALIZE l_cod_centro_custo,
                   m_den_cc_viajante TO NULL
        RETURN l_cod_centro_custo
     END IF
  END IF

  WHENEVER ERROR CONTINUE
   SELECT nom_cent_cust
     INTO l_nom_cent_cust
     FROM cad_cc
    WHERE cod_empresa    = p_cod_empresa
      AND cod_cent_cust  = l_cod_centro_custo
      AND ies_cod_versao = 0
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 100 THEN
     WHENEVER ERROR CONTINUE
      SELECT cod_empresa_plano
        INTO l_cod_empresa_plano
        FROM par_con
       WHERE cod_empresa = p_cod_empresa
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        INITIALIZE l_cod_centro_custo,
                   m_den_cc_viajante TO NULL
        RETURN l_cod_centro_custo
     END IF

     WHENEVER ERROR CONTINUE
      SELECT nom_cent_cust
        INTO l_nom_cent_cust
        FROM cad_cc
       WHERE cod_empresa      = l_cod_empresa_plano
         AND cod_cent_cust    = l_cod_centro_custo
         AND ies_cod_versao   = 0
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        INITIALIZE l_cod_centro_custo,
                   m_den_cc_viajante TO NULL
        RETURN l_cod_centro_custo
     END IF
  ELSE
     IF SQLCA.SQLCODE <> 0 THEN
        INITIALIZE l_cod_centro_custo,
                   m_den_cc_viajante TO NULL
        RETURN l_cod_centro_custo
     END IF
  END IF

  LET m_den_cc_viajante = l_nom_cent_cust
  RETURN l_cod_centro_custo

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2001_carrega_den_cargo(l_viajante)
#----------------------------------------------#

  DEFINE l_viajante LIKE cdv_solic_viag_781.viajante,
         l_den_cargo LIKE cargo.den_cargo

  WHENEVER ERROR CONTINUE
   SELECT UNIQUE(cargo.den_cargo)
     INTO l_den_cargo
     FROM funcionario, cargo
    WHERE funcionario.cod_empresa = p_cod_empresa
      AND funcionario.num_matricula = l_viajante
      AND cargo.cod_empresa = p_cod_empresa
      AND cargo.cod_cargo = funcioario.cod_cargo
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_den_cargo TO NULL
  END IF

  RETURN l_den_cargo

END FUNCTION

#------------------------#
 FUNCTION cdv2001_popup()
#------------------------#

  DEFINE l_controle          LIKE cdv_solic_viag_781.controle,
         l_viajante          LIKE cdv_solic_viag_781.viajante,
         l_usuario_logix     LIKE cdv_info_viajante.usuario_logix,
         l_finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
         l_cc_viajante       LIKE cdv_solic_viag_781.cc_viajante,
         l_cc_debitar        LIKE cdv_solic_viag_781.cc_debitar,
         l_cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
         l_cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
         l_empresa_atendida  LIKE cdv_solic_viag_781.empresa_atendida,
         l_filial_atendida   LIKE cdv_solic_viag_781.filial_atendida,
         l_forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
         l_banco             LIKE cdv_solic_adto_781.banco

  CASE

    WHEN infield(controle)
         LET l_controle = log0091_popup(8,15,"CONTROLE", "cdv_controle_781", "controle",
                                             "","N","")
         CURRENT WINDOW IS w_cdv2001
         IF l_controle IS NOT NULL  THEN
            LET mr_tela.controle = l_controle
            DISPLAY BY NAME mr_tela.controle
         END IF

    WHEN infield(viajante)
         LET l_viajante = cdv0033_popup_matricula_viaj(p_cod_empresa)
         CURRENT WINDOW IS w_cdv2001
         IF l_viajante IS NOT NULL THEN
            LET mr_tela.viajante = l_viajante
            DISPLAY BY NAME mr_tela.viajante
         END IF

    WHEN infield(finalidade_viagem)
         LET l_finalidade_viagem = log009_popup(8,15,"FINALIDADE","cdv_finalidade_781","finalidade","des_finalidade",
                                                      "cdv2006","N","")
         CURRENT WINDOW IS w_cdv2001
         IF l_finalidade_viagem IS NOT NULL  THEN
            LET mr_tela.finalidade_viagem = l_finalidade_viagem
            DISPLAY BY NAME mr_tela.finalidade_viagem
            LET m_den_finalidade_viagem = cdv2001_busca_den_finalidade_viagem(mr_tela.finalidade_viagem)
            DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
         END IF

    WHEN infield(cc_viajante)
         LET l_cc_viajante = con075_popup_cod_cad_cc(p_cod_empresa)
         CURRENT WINDOW IS w_cdv2001
         IF l_cc_viajante IS NOT NULL  THEN
            LET mr_tela.cc_viajante = l_cc_viajante
            DISPLAY BY NAME mr_tela.cc_viajante
            LET m_den_cc_viajante = cdv2001_busca_den_cc(mr_tela.cc_viajante)
            DISPLAY m_den_cc_viajante TO den_cc_viajante
         END IF

    WHEN infield(cc_debitar)
         LET l_cc_debitar = con075_popup_cod_cad_cc(p_cod_empresa)
         CURRENT WINDOW IS w_cdv2001
         IF l_cc_debitar IS NOT NULL  THEN
            LET mr_tela.cc_debitar = l_cc_debitar
            DISPLAY BY NAME mr_tela.cc_debitar
            LET m_den_cc_debitar = cdv2001_busca_den_cc(mr_tela.cc_debitar)
            DISPLAY m_den_cc_debitar TO den_cc_debitar
         END IF

    WHEN infield(cliente_atendido)
         LET l_cliente_atendido = vdp372_popup_cliente()
         CURRENT WINDOW IS w_cdv2001
         IF l_cliente_atendido IS NOT NULL  THEN
            LET mr_tela.cliente_atendido = l_cliente_atendido
            DISPLAY BY NAME mr_tela.cliente_atendido
            LET m_den_cliente_atendido = cdv2001_busca_den_cliente(mr_tela.cliente_atendido)
            DISPLAY m_den_cliente_atendido TO den_cliente_atendido
         END IF

    WHEN infield(cliente_fatur)
         LET l_cliente_fatur = vdp372_popup_cliente()
         CURRENT WINDOW IS w_cdv2001
         IF l_cliente_fatur IS NOT NULL  THEN
            LET mr_tela.cliente_fatur = l_cliente_fatur
            DISPLAY BY NAME mr_tela.cliente_fatur
            LET m_den_cliente_fatur = cdv2001_busca_den_cliente(mr_tela.cliente_fatur)
            DISPLAY m_den_cliente_fatur TO den_cliente_fatur
         END IF

    WHEN infield(empresa_atendida)
         LET l_empresa_atendida = cdv0084_popup_cod_empresa(FALSE, "MAT", '')
         CURRENT WINDOW IS w_cdv2001
         IF l_empresa_atendida IS NOT NULL  THEN
            LET mr_tela.empresa_atendida = l_empresa_atendida
            DISPLAY BY NAME mr_tela.empresa_atendida
         END IF

    WHEN infield(filial_atendida)
         LET l_filial_atendida = cdv0084_popup_cod_empresa(FALSE, "FIL", mr_tela.empresa_atendida)
         CURRENT WINDOW IS w_cdv2001
         IF l_filial_atendida IS NOT NULL  THEN
            LET mr_tela.filial_atendida = l_filial_atendida
            DISPLAY BY NAME mr_tela.filial_atendida
         END IF

    WHEN infield(forma_adto_viagem)
         LET l_forma_adto_viagem = log0830_list_box(10,20,"DC {Depósito em conta corrente}, DN {Pago em dinheiro}" )
         CURRENT WINDOW IS w_cdv20011
         IF l_forma_adto_viagem IS NOT NULL  THEN
            LET mr_tela.forma_adto_viagem = l_forma_adto_viagem
            DISPLAY BY NAME mr_tela.forma_adto_viagem
         END IF

    WHEN infield(banco)
         LET l_banco = cap013_popup_bancos()
         CURRENT WINDOW IS w_cdv20011
         IF l_banco IS NOT NULL  THEN
            LET mr_tela.banco = l_banco
            DISPLAY BY NAME mr_tela.banco
            LET m_den_banco = cdv2001_busca_den_banco(mr_tela.banco)
            DISPLAY m_den_banco TO den_banco
         END IF

  END CASE

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2001_busca_den_empresa(l_empresa)
#---------------------------------------------#
  DEFINE l_empresa     LIKE empresa.cod_empresa,
         l_den_empresa LIKE empresa.den_empresa

  WHENEVER ERROR CONTINUE
   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_den_empresa TO NULL
  END IF

 RETURN l_den_empresa

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2001_verifica_eh_controle_obrig()
#---------------------------------------------#

 DEFINE l_eh_controle_obrig LIKE cdv_finalidade_781.eh_controle_obrig

 WHENEVER ERROR CONTINUE
 SELECT eh_controle_obrig
   INTO l_eh_controle_obrig
   FROM cdv_finalidade_781
  WHERE finalidade = mr_tela.finalidade_viagem
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    LET l_eh_controle_obrig = "N"
 END IF

 IF l_eh_controle_obrig = "S" THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION

#-----------------------------------------------------------------------------------#
 FUNCTION cdv2001_verifica_controle(l_controle, l_cliente_atendido, l_cliente_fatur)
#-----------------------------------------------------------------------------------#
 DEFINE l_controle          LIKE cdv_solic_viag_781.controle,
        l_cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
        l_cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur

  IF l_cliente_atendido IS NOT NULL AND l_cliente_fatur IS NOT NULL THEN
     #WHENEVER ERROR CONTINUE
     #  SELECT 1
     #    FROM cdv_controle_781
     #   WHERE controle         = l_controle
     #     AND cliente_atendido = l_cliente_atendido
     #     AND cliente_fatur    = l_cliente_fatur
     #WHENEVER ERROR STOP
     #IF  SQLCA.sqlcode <> 0
     #AND SQLCA.sqlcode <> -284 THEN
     #   CALL log0030_mensagem("Controle não cadastrado para os clientes informados.","info")
     #   RETURN FALSE
     #END IF
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT 1
         FROM cdv_controle_781
        WHERE controle         = l_controle
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0
     AND SQLCA.sqlcode <> -284  THEN
        CALL log0030_mensagem("Controle não cadastrado.","info")
        RETURN FALSE
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    SELECT 1
      FROM cdv_controle_781
     WHERE controle         = l_controle
       AND encerrado        = "S"
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode = 0 THEN
     CALL log0030_mensagem("Controle encerrado, não pode ser utilizado para incluir novos registros.","info")
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2001_verifica_viajante()
#------------------------------------#
 DEFINE l_empresa_rhu  LIKE cdv_info_viajante.empresa_rhu

 WHENEVER ERROR CONTINUE
 SELECT empresa_rhu
   INTO l_empresa_rhu
   FROM cdv_info_viajante
  WHERE empresa   = p_cod_empresa
    AND matricula = mr_tela.viajante
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    LET l_empresa_rhu = p_cod_empresa
 END IF

 LET m_den_viajante = cdv2001_busca_den_viajante(mr_tela.viajante, l_empresa_rhu)

 IF m_den_viajante IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION cdv2001_busca_den_viajante(l_viajante, l_empresa_rhu)
#---------------------------------------------------------------#
  DEFINE l_viajante        LIKE cdv_solic_viag_781.viajante,
         l_den_funcionario LIKE funcionario.nom_funcionario,
         l_empresa_rhu     LIKE cdv_info_viajante.empresa_rhu,
         l_cod_funcio     LIKE cdv_fornecedor_fun.cod_funcio,
         l_cod_fornecedor LIKE fornecedor.cod_fornecedor

  LET l_cod_funcio = l_viajante

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO l_den_funcionario
    FROM fornecedor
   WHERE cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_den_funcionario TO NULL
  END IF

 RETURN l_den_funcionario

END FUNCTION

#----------------------------------------------------------------#
 FUNCTION cdv2001_verifica_finalidade_viagem(l_finalidade_viagem)
#----------------------------------------------------------------#

 DEFINE l_finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem

 LET m_den_finalidade_viagem = cdv2001_busca_den_finalidade_viagem(l_finalidade_viagem)

 IF m_den_finalidade_viagem IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#-----------------------------------------------------------------#
 FUNCTION cdv2001_busca_den_finalidade_viagem(l_finalidade_viagem)
#-----------------------------------------------------------------#

 DEFINE l_finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
        l_den_finalidade_viagem LIKE cdv_finalidade_781.des_finalidade

 WHENEVER ERROR CONTINUE
  SELECT des_finalidade, eh_periodo_viagem
    INTO l_den_finalidade_viagem, m_verifica_periodo_viagem
    FROM cdv_finalidade_781
   WHERE finalidade = l_finalidade_viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_den_finalidade_viagem TO NULL
 END IF

 RETURN l_den_finalidade_viagem

END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2001_verifica_cc_viajante(l_cc)
#-------------------------------------------#

 DEFINE l_cc LIKE cdv_solic_viagem.cc_debitar,
        lr_cad_cc RECORD LIKE cad_cc.*

 CALL con200_verifica_cod_ccusto(p_cod_empresa,l_cc,TODAY) RETURNING lr_cad_cc.*,p_status

 IF p_status = FALSE THEN
    INITIALIZE m_den_cc_viajante TO NULL
    RETURN FALSE
 END IF

 LET m_den_cc_viajante = cdv2001_busca_den_cc(l_cc)

 IF m_den_cc_viajante IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#-------------------------------------------#
 FUNCTION cdv2001_verifica_cc_debitar(l_cc)
#-------------------------------------------#

 DEFINE l_cc LIKE cdv_solic_viagem.cc_debitar,
        lr_cad_cc RECORD LIKE cad_cc.*

 CALL con200_verifica_cod_ccusto(p_cod_empresa,l_cc,TODAY) RETURNING lr_cad_cc.*,p_status

 IF p_status = FALSE THEN
    INITIALIZE m_den_cc_viajante TO NULL
    RETURN FALSE
 END IF

 LET m_den_cc_debitar = cdv2001_busca_den_cc(l_cc)

 IF m_den_cc_debitar IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#-----------------------------------#
 FUNCTION cdv2001_busca_den_cc(l_cc)
#-----------------------------------#

  DEFINE l_cc LIKE cdv_solic_viagem.cc_debitar,
         l_nom_cent_cust LIKE cad_cc.nom_cent_cust,
         l_status SMALLINT,
         l_cod_empresa_plano LIKE par_con.cod_empresa_plano

  INITIALIZE l_nom_cent_cust TO NULL

  WHENEVER ERROR CONTINUE
   SELECT cod_empresa_plano
     INTO l_cod_empresa_plano
     FROM par_con
    WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECAO','PAR_CON')
     RETURN FALSE, l_nom_cent_cust
  END IF

  WHENEVER ERROR CONTINUE
   SELECT nom_cent_cust
     INTO l_nom_cent_cust
     FROM cad_cc
    WHERE cod_empresa      = p_cod_empresa
      AND cod_cent_cust    = l_cc
      AND ies_cod_versao   = 0
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE = 0 THEN
     LET l_status = TRUE
  ELSE
     WHENEVER ERROR CONTINUE
      SELECT nom_cent_cust
        INTO l_nom_cent_cust
        FROM cad_cc
       WHERE cod_empresa      = l_cod_empresa_plano
         AND cod_cent_cust    = l_cc
         AND ies_cod_versao   = 0
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE = 0 THEN
        LET l_status = TRUE
     ELSE
        LET l_status = FALSE
     END IF
  END IF

  IF l_status = FALSE THEN
     INITIALIZE l_nom_cent_cust TO NULL
  END IF

  RETURN l_nom_cent_cust

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv2001_verifica_cliente_faturar(l_cliente)
#----------------------------------------------------#

  DEFINE l_cliente LIKE cdv_solic_viag_781.cliente_atendido

  LET m_den_cliente_fatur = cdv2001_busca_den_cliente(l_cliente)

  IF m_den_cliente_fatur IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#---------------------------------------------#
 FUNCTION cdv2001_busca_den_cliente(l_cliente)
#---------------------------------------------#

  DEFINE l_cliente LIKE cdv_solic_viag_781.cliente_atendido,
         l_den_cliente LIKE clientes.nom_cliente

  WHENEVER ERROR CONTINUE
  SELECT nom_cliente
    INTO l_den_cliente
    FROM clientes
   WHERE cod_cliente = l_cliente
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE l_den_cliente TO NULL
  END IF

  RETURN l_den_cliente

END FUNCTION

#------------------------------------------------------------------#
 FUNCTION cdv2001_verifica_empresa_filial_atendida(l_empresa, l_emp)
#------------------------------------------------------------------#

  DEFINE l_empresa LIKE empresa.cod_empresa,
         l_emp     CHAR(03)

  WHENEVER ERROR CONTINUE
  SELECT 1
    FROM empresa
   WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     CALL log0030_mensagem("Código da empresa não cadastrado. ","info")
     RETURN FALSE
  END IF

  IF l_emp = 'FIL' THEN
     IF mr_tela.empresa_atendida = mr_tela.filial_atendida THEN
        RETURN TRUE
     END IF
  END IF

  IF l_emp = 'MAT' THEN
     WHENEVER ERROR CONTINUE
     SELECT 1
       FROM par_con
      WHERE cod_empresa = l_empresa
        AND (cod_empresa_mestre IS NULL
            OR cod_empresa_mestre = ' ')
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        CALL log0030_mensagem("Empresa atendida não é uma empresa matriz.","info")
        RETURN FALSE
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
     SELECT 1
       FROM par_con
      WHERE cod_empresa        = l_empresa
        AND cod_empresa_mestre = mr_tela.empresa_atendida
     WHENEVER ERROR STOP
     IF SQLCA.sqlcode <> 0 THEN
        CALL log0030_mensagem("Filial atendida não está relacionada a empresa atendida (matriz).","info")
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#----------------------------------------------------------------#
 FUNCTION cdv2001_verifica_dat_hor_periodo(l_data, l_hora, l_ind)
#----------------------------------------------------------------#
  DEFINE l_data            CHAR(10),
         l_hora            CHAR(08),
         l_ind             CHAR(01),
         l_count           SMALLINT,
         l_data_hora       CHAR(19),
         l_data_hora_part  CHAR(19)

  IF l_hora IS NULL OR l_hora = ' ' THEN
     LET l_hora = '00:00:00'
  END IF

  LET l_data_hora = l_data[7,10],"-",
                    l_data[4,5],"-",
                    l_data[1,2], " ",
                    l_hora CLIPPED

  IF l_ind = "R" THEN
     LET l_data = mr_tela.dat_hor_partida
     LET l_hora = mr_tela.hora_partida

     LET l_data_hora_part = l_data[7,10],"-",
                            l_data[4,5],"-",
                            l_data[1,2], " ",
                            l_hora CLIPPED
  END IF

  LET l_count = 0

  IF l_ind = "P" THEN
     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_count
       FROM cdv_solic_viag_781
      WHERE empresa  = p_cod_empresa
        AND viajante = mr_tela.viajante
        AND viagem   <> mr_tela.viagem
        AND dat_hor_partida <= l_data_hora
        AND dat_hor_retorno >= l_data_hora
     WHENEVER ERROR STOP
  ELSE
     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_count
       FROM cdv_solic_viag_781
      WHERE empresa  = p_cod_empresa
        AND viajante = mr_tela.viajante
        AND viagem   <> mr_tela.viagem
        AND (dat_hor_partida BETWEEN l_data_hora_part AND l_data_hora)
         OR (dat_hor_retorno BETWEEN l_data_hora_part AND l_data_hora)
     WHENEVER ERROR STOP
  END IF

  IF SQLCA.sqlcode <> 0 THEN
     LET l_count = 0
  END IF

  IF l_count > 0 THEN
     CALL log0030_mensagem("Viajante possui outra viagem no período informado. ","info")
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2001_verifica_banco(l_banco)
#----------------------------------------#

  DEFINE l_banco LIKE bancos.cod_banco

  LET m_den_banco = cdv2001_busca_den_banco(l_banco)

  IF m_den_banco IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#-----------------------------------------#
 FUNCTION cdv2001_busca_den_banco(l_banco)
#-----------------------------------------#

  DEFINE l_banco LIKE bancos.cod_banco,
         l_den_banco LIKE bancos.nom_banco

  WHENEVER ERROR CONTINUE
  SELECT nom_banco
    INTO l_den_banco
    FROM bancos
   WHERE cod_banco = l_banco
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     INITIALIZE l_den_banco TO NULL
  END IF

  RETURN l_den_banco

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2001_processa_cdv2002()
#-----------------------------------#

  DEFINE l_comando_cdv CHAR(200),
         l_cancel INTEGER

  IF NOT cdv2001_verifica_existencia_adto() THEN
     CALL log120_procura_caminho("cdv2002") RETURNING l_comando_cdv

     IF mr_tela.viagem IS NOT NULL THEN
        LET l_comando_cdv = l_comando_cdv CLIPPED," ",
                            p_cod_empresa CLIPPED," ",
                            mr_tela.viagem USING "<<<<<<<<<"
        RUN l_comando_cdv RETURNING l_cancel
        LET l_cancel = l_cancel / 256
        IF l_cancel <> 0 THEN
           PROMPT "Tecle ENTER para continuar" FOR m_comando
        END IF
        LET INT_FLAG = FALSE
     ELSE
        ERROR "Falta de parâmetros. Efetue a consulta novamente."
        RETURN
     END IF
  ELSE
     CALL log0030_mensagem('Esta solicitação não possui adiantamento de viagem.','info')
  END IF

END FUNCTION

#------------------------#
 FUNCTION cdv2001_lista()
#------------------------#

  DEFINE lr_relat RECORD
                     empresa           LIKE cdv_solic_viag_781.empresa,
                     viagem            LIKE cdv_solic_viag_781.viagem,
                     controle          LIKE cdv_solic_viag_781.controle,
                     dat_hr_emis_solic LIKE cdv_solic_viag_781.dat_hr_emis_solic,
                     viajante          LIKE cdv_solic_viag_781.viajante,
                     finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
                     cc_viajante       LIKE cdv_solic_viag_781.cc_viajante,
                     cc_debitar        LIKE cdv_solic_viag_781.cc_debitar,
                     cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
                     cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
                     empresa_atendida  LIKE cdv_solic_viag_781.empresa_atendida,
                     filial_atendida   LIKE cdv_solic_viag_781.filial_atendida,
                     trajeto_principal LIKE cdv_solic_viag_781.trajeto_principal,
                     dat_hor_partida   LIKE cdv_solic_viag_781.dat_hor_partida,
                     dat_hor_retorno   LIKE cdv_solic_viag_781.dat_hor_retorno,
                     motivo_viagem     LIKE cdv_solic_viag_781.motivo_viagem,
                     sequencia_adto    LIKE cdv_solic_adto_781.sequencia_adto,
                     dat_adto_viagem   LIKE cdv_solic_adto_781.dat_adto_viagem,
                     ies_solic_adto    CHAR(01),
                     val_adto_viagem   LIKE cdv_solic_adto_781.val_adto_viagem,
                     forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
                     banco             LIKE cdv_solic_adto_781.banco,
                     agencia           LIKE cdv_solic_adto_781.agencia,
                     cta_corrente      LIKE cdv_solic_adto_781.cta_corrente,
                     ad_adiantamento   LIKE ad_mestre.num_ad,
                     ap_adiantamento   LIKE ad_mestre.num_ad
                  END RECORD

  DEFINE l_den_viajanter          LIKE funcionario.nom_funcionario,
         l_den_finalidade_viagemr LIKE cdv_solic_viagem.des_find_viagem,
         l_den_cc_viajanter       LIKE cad_cc.nom_cent_cust,
         l_den_cc_debitarr        LIKE cad_cc.nom_cent_cust,
         l_den_cliente_atendidor  LIKE clientes.nom_cliente,
         l_den_cliente_fatur      LIKE clientes.nom_cliente,
         l_den_bancor             LIKE bancos.nom_banco,
         l_empresa_rhu            LIKE cdv_info_viajante.empresa_rhu

  DEFINE l_mensagem          CHAR(100),
         l_reg               SMALLINT,
         l_relat             SMALLINT,
         l_sql_stmt          CHAR(3000)

  DEFINE l_num_ad LIKE ad_mestre.num_ad,
         l_num_ap LIKE ad_mestre.num_ad

  IF log0280_saida_relat(19,17) IS NOT NULL THEN

     LET l_reg = 0

     IF p_ies_impressao = "S" THEN
        IF g_ies_ambiente = "U" THEN
           START REPORT cdv2001_relat TO PIPE p_nom_arquivo
        ELSE
           CALL log150_procura_caminho("LST") RETURNING m_caminho
           LET m_caminho = m_caminho CLIPPED, "cdv2001.tmp"
           START REPORT cdv2001_relat TO m_caminho
        END IF
     ELSE
        START REPORT cdv2001_relat TO p_nom_arquivo
     END IF

     MESSAGE "Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

     INITIALIZE m_den_empresa TO NULL

     LET m_den_empresa = cdv2001_busca_den_empresa(p_cod_empresa)

     LET l_den_viajanter = m_den_viajante
     LET l_den_finalidade_viagemr = m_den_finalidade_viagem
     LET l_den_cc_viajanter = m_den_cc_viajante
     LET l_den_cc_debitarr = m_den_cc_debitar
     LET l_den_cliente_atendidor = m_den_cliente_atendido
     LET l_den_cliente_fatur = m_den_cliente_fatur
     LET l_den_bancor = m_den_banco

     LET m_qtd_solic        = 0
     LET m_qtd_solic_impres = 0

     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO m_qtd_solic
       FROM cdv_solic_viag_781
      WHERE empresa = p_cod_empresa
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        LET m_qtd_solic = 0
     END IF

     IF m_qtd_solic IS NULL THEN
        LET m_qtd_solic = 0
     END IF

     LET m_num_ad = 0

     INITIALIZE l_sql_stmt TO NULL

     LET l_sql_stmt = " SELECT empresa, viagem, controle, dat_hr_emis_solic, viajante, finalidade_viagem, ",
                      " cc_viajante, cc_debitar, cliente_atendido, cliente_fatur, empresa_atendida, ",
                      " filial_atendida, trajeto_principal, dat_hor_partida, dat_hor_retorno, ",
                      " motivo_viagem ",
                      " FROM cdv_solic_viag_781 ",
                      " WHERE empresa = '",p_cod_empresa,"' "

     IF mr_consulta.viagem IS NOT NULL
     AND  mr_consulta.viagem <> 0 THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND viagem = ", mr_consulta.viagem, " "

     END IF
     IF mr_consulta.controle IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         "AND controle = ", mr_consulta.controle, " "
     END IF
     IF mr_consulta.dat_hr_emis_solic IS NOT NULL
     AND mr_consulta.dat_hr_emis_solic > '31/12/1900' THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND DATE(dat_hr_emis_solic) =  '", DATE(mr_consulta.dat_hr_emis_solic), "' "
     END IF
     IF mr_consulta.viajante IS NOT NULL
     AND mr_consulta.viajante <> 0  THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND viajante =  ", mr_consulta.viajante, " "
     END IF
     IF mr_consulta.finalidade_viagem IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND finalidade_viagem = '", mr_consulta.finalidade_viagem, "' "
     END IF
     IF mr_consulta.cc_viajante IS NOT NULL
     AND mr_consulta.cc_viajante <> 0 THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND cc_viajante = ", mr_consulta.cc_viajante, " "
     END IF
     IF mr_consulta.cc_debitar IS NOT NULL
     AND mr_consulta.cc_debitar <> 0  THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND cc_debitar = ", mr_consulta.cc_debitar, " "
     END IF
     IF mr_consulta.cliente_atendido IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND cliente_atendido = '", mr_consulta.cliente_atendido, "' "
     END IF
     IF mr_consulta.cliente_fatur IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND cliente_fatur = '", mr_consulta.cliente_fatur, "' "
     END IF
     IF mr_consulta.empresa_atendida IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND empresa_atendida = '",mr_consulta.empresa_atendida, "' "
     END IF
     IF mr_consulta.filial_atendida IS NOT NULL THEN
        LET l_sql_stmt = l_sql_stmt CLIPPED,
                         " AND filial_atendida = '", mr_consulta.filial_atendida, "' "
     END IF

     LET l_sql_stmt = l_sql_stmt CLIPPED,
                      " ORDER BY 1,2 "

     WHENEVER ERROR CONTINUE
     PREPARE var_relat FROM l_sql_stmt
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
     END IF

     WHENEVER ERROR CONTINUE
     DECLARE cq_solic_viag_781 CURSOR FOR var_relat
      #SELECT empresa, viagem, controle, dat_hr_emis_solic, viajante, finalidade_viagem,
      #       cc_viajante, cc_debitar, cliente_atendido, cliente_fatur, empresa_atendida,
      #       filial_atendida, trajeto_principal, dat_hor_partida, dat_hor_retorno,
      #       motivo_viagem
      #  FROM cdv_solic_viag_781
      # WHERE empresa = p_cod_empresa
      # ORDER BY 1,2
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
        FOREACH cq_solic_viag_781 INTO lr_relat.empresa,
                                       lr_relat.viagem,
                                       lr_relat.controle,
                                       lr_relat.dat_hr_emis_solic,
                                       lr_relat.viajante,
                                       lr_relat.finalidade_viagem,
                                       lr_relat.cc_viajante,
                                       lr_relat.cc_debitar,
                                       lr_relat.cliente_atendido,
                                       lr_relat.cliente_fatur,
                                       lr_relat.empresa_atendida,
                                       lr_relat.filial_atendida,
                                       lr_relat.trajeto_principal,
                                       lr_relat.dat_hor_partida,
                                       lr_relat.dat_hor_retorno,
                                       lr_relat.motivo_viagem
         WHENEVER ERROR STOP
           IF SQLCA.sqlcode = 0 THEN
              LET l_relat = 0
              LET l_reg = 1
              LET lr_relat.ies_solic_adto = "N"
              INITIALIZE lr_relat.val_adto_viagem,
                         lr_relat.forma_adto_viagem,
                         lr_relat.banco,
                         lr_relat.agencia,
                         lr_relat.cta_corrente,
                         lr_relat.ad_adiantamento,
                         lr_relat.ap_adiantamento TO NULL
              WHENEVER ERROR CONTINUE
              DECLARE cq_solic_adto_781 CURSOR FOR
              SELECT cdv_solic_adto_781.sequencia_adto,
                     cdv_solic_adto_781.dat_adto_viagem,
                     cdv_solic_adto_781.val_adto_viagem,
                     cdv_solic_adto_781.forma_adto_viagem,
                     cdv_solic_adto_781.banco,
                     cdv_solic_adto_781.agencia,
                     cdv_solic_adto_781.cta_corrente,
                     cdv_solic_adto_781.num_ad_adto_viagem
                FROM cdv_solic_adto_781
               WHERE cdv_solic_adto_781.empresa = p_cod_empresa
                 AND cdv_solic_adto_781.viagem = lr_relat.viagem
              WHENEVER ERROR STOP
              IF SQLCA.sqlcode = 0 THEN
                 WHENEVER ERROR CONTINUE
                 FOREACH cq_solic_adto_781 INTO lr_relat.sequencia_adto,
                                                lr_relat.dat_adto_viagem,
                                                lr_relat.val_adto_viagem,
                                                lr_relat.forma_adto_viagem,
                                                lr_relat.banco,
                                                lr_relat.agencia,
                                                lr_relat.cta_corrente,
                                                lr_relat.ad_adiantamento
                 WHENEVER ERROR STOP

                    LET l_relat = 1
                    IF sqlca.sqlcode = 0 THEN
                       LET lr_relat.ies_solic_adto = "S"
                       CALL cdv2001_busca_num_ap(lr_relat.ad_adiantamento)
                            RETURNING mr_tela.ap_adiantamento
                       LET mr_tela.ad_adiantamento = lr_relat.ad_adiantamento
                       LET l_num_ad = mr_tela.ad_adiantamento
                       LET l_num_ap = mr_tela.ap_adiantamento
                       LET lr_relat.ad_adiantamento = l_num_ad
                       LET lr_relat.ap_adiantamento = l_num_ap
                       LET mr_tela.ad_adiantamento = l_num_ad
                       LET mr_tela.ap_adiantamento = l_num_ap
                    ELSE
                       LET lr_relat.ies_solic_adto = "N"
                       INITIALIZE lr_relat.dat_adto_viagem,
                                  lr_relat.val_adto_viagem,
                                  lr_relat.forma_adto_viagem,
                                  lr_relat.banco,
                                  lr_relat.agencia,
                                  lr_relat.cta_corrente,
                                  lr_relat.ad_adiantamento,
                                  lr_relat.ap_adiantamento TO NULL
                    END IF

                    WHENEVER ERROR CONTINUE
                    SELECT empresa_rhu
                      INTO l_empresa_rhu
                      FROM cdv_info_viajante
                     WHERE empresa   = p_cod_empresa
                       AND matricula = lr_relat.viajante
                    WHENEVER ERROR STOP
                    IF SQLCA.sqlcode <> 0 THEN
                       LET l_empresa_rhu = p_cod_empresa
                    END IF

                    LET m_den_viajante = cdv2001_busca_den_viajante(lr_relat.viajante, l_empresa_rhu)
                    LET m_den_finalidade_viagem = cdv2001_busca_den_finalidade_viagem(lr_relat.finalidade_viagem)
                    LET m_den_cc_viajante = cdv2001_busca_den_cc(lr_relat.cc_viajante)
                    LET m_den_cc_debitar = cdv2001_busca_den_cc(lr_relat.cc_debitar)
                    LET m_den_cliente_atendido = cdv2001_busca_den_cliente(lr_relat.cliente_atendido)
                    LET m_den_cliente_fatur = cdv2001_busca_den_cliente(lr_relat.cliente_fatur)
                    LET m_den_banco = cdv2001_busca_den_banco(lr_relat.banco)
                    LET m_den_empresa_atendida = cdv2001_busca_den_empresa(lr_relat.empresa_atendida)
                    LET m_den_filial_atendida = cdv2001_busca_den_empresa(lr_relat.filial_atendida)
                    OUTPUT TO REPORT cdv2001_relat(lr_relat.*)
                 END FOREACH
              END IF

              IF l_relat = 0 THEN
                 WHENEVER ERROR CONTINUE
                 SELECT empresa_rhu
                   INTO l_empresa_rhu
                   FROM cdv_info_viajante
                  WHERE empresa   = p_cod_empresa
                    AND matricula = lr_relat.viajante
                 WHENEVER ERROR STOP
                 IF SQLCA.sqlcode <> 0 THEN
                    LET l_empresa_rhu = p_cod_empresa
                 END IF

                 LET m_den_viajante = cdv2001_busca_den_viajante(lr_relat.viajante, l_empresa_rhu)
                 LET m_den_finalidade_viagem = cdv2001_busca_den_finalidade_viagem(lr_relat.finalidade_viagem)
                 LET m_den_cc_viajante = cdv2001_busca_den_cc(lr_relat.cc_viajante)
                 LET m_den_cc_debitar = cdv2001_busca_den_cc(lr_relat.cc_debitar)
                 LET m_den_cliente_atendido = cdv2001_busca_den_cliente(lr_relat.cliente_atendido)
                 LET m_den_cliente_fatur = cdv2001_busca_den_cliente(lr_relat.cliente_fatur)
                 LET m_den_banco = cdv2001_busca_den_banco(lr_relat.banco)
                 LET m_den_empresa_atendida = cdv2001_busca_den_empresa(lr_relat.empresa_atendida)
                 LET m_den_filial_atendida = cdv2001_busca_den_empresa(lr_relat.filial_atendida)
                 OUTPUT TO REPORT cdv2001_relat(lr_relat.*)
              END IF
           END IF
        END FOREACH
     END IF

     FREE cq_solic_viag_781
     FREE cq_solic_adto_781

     DISPLAY l_den_viajanter TO den_viajante
     DISPLAY l_den_finalidade_viagemr TO den_finalidade_viagem
     DISPLAY l_den_cc_viajanter TO den_cc_viajante
     DISPLAY l_den_cc_debitarr TO den_cc_debitar
     DISPLAY l_den_cliente_atendidor TO den_cliente_atendido
     DISPLAY l_den_cliente_fatur TO den_cliente_fatur

     LET m_den_viajante = l_den_viajanter
     LET m_den_finalidade_viagem = l_den_finalidade_viagemr
     LET m_den_cc_viajante = l_den_cc_viajanter
     LET m_den_cc_debitar = l_den_cc_debitarr
     LET m_den_cliente_atendido = l_den_cliente_atendidor
     LET m_den_cliente_fatur = l_den_cliente_fatur
     LET m_den_banco =l_den_bancor

     FINISH REPORT cdv2001_relat

     IF g_ies_ambiente = "W" AND p_ies_impressao = "S" THEN
        LET m_comando = "lpdos.bat ", m_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
        RUN m_comando
     END IF

     IF l_reg = 1 THEN
        IF p_ies_impressao = "S" THEN
           CALL log0030_mensagem("Relatório impresso com sucesso.","info")
        ELSE
           LET  l_mensagem = "Relatório gravado no arquivo ",p_nom_arquivo CLIPPED
           CALL log0030_mensagem(l_mensagem,"info")
        END IF
     ELSE
        CALL log0030_mensagem("Não existem dados para serem listados.","info")
     END IF
  END IF

END FUNCTION

#------------------------------#
 REPORT cdv2001_relat(lr_relat)
#------------------------------#

 DEFINE lr_relat RECORD
                    empresa           LIKE cdv_solic_viag_781.empresa,
                    viagem            LIKE cdv_solic_viag_781.viagem,
                    controle          LIKE cdv_solic_viag_781.controle,
                    dat_hr_emis_solic LIKE cdv_solic_viag_781.dat_hr_emis_solic,
                    viajante          LIKE cdv_solic_viag_781.viajante,
                    finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
                    cc_viajante       LIKE cdv_solic_viag_781.cc_viajante,
                    cc_debitar        LIKE cdv_solic_viag_781.cc_debitar,
                    cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
                    cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
                    empresa_atendida  LIKE cdv_solic_viag_781.empresa_atendida,
                    filial_atendida   LIKE cdv_solic_viag_781.filial_atendida,
                    trajeto_principal LIKE cdv_solic_viag_781.trajeto_principal,
                    dat_hor_partida   LIKE cdv_solic_viag_781.dat_hor_partida,
                    dat_hor_retorno   LIKE cdv_solic_viag_781.dat_hor_retorno,
                    motivo_viagem     LIKE cdv_solic_viag_781.motivo_viagem,
                    sequencia_adto    LIKE cdv_solic_adto_781.sequencia_adto,
                    dat_adto_viagem   LIKE cdv_solic_adto_781.dat_adto_viagem,
                    ies_solic_adto    CHAR(01),
                    val_adto_viagem   LIKE cdv_solic_adto_781.val_adto_viagem,
                    forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
                    banco             LIKE cdv_solic_adto_781.banco,
                    agencia           LIKE cdv_solic_adto_781.agencia,
                    cta_corrente      LIKE cdv_solic_adto_781.cta_corrente,
                    ad_adiantamento   LIKE ad_mestre.num_ad,
                    ap_adiantamento   LIKE ad_mestre.num_ad
                 END RECORD

 DEFINE l_texto CHAR(100)
 DEFINE l_total LIKE cdv_solic_adto_781.val_adto_viagem,
        l_data  CHAR(19),
        l_data1 CHAR(10),
        l_data2 CHAR(19)

 DEFINE l_last_row          SMALLINT

 OUTPUT
     LEFT   MARGIN 0
     TOP    MARGIN 0
     BOTTOM MARGIN 1

  ORDER EXTERNAL BY lr_relat.empresa, lr_relat.viagem, lr_relat.sequencia_adto

  FORMAT
  PAGE HEADER
      PRINT log5211_retorna_configuracao(PAGENO,66,80) CLIPPED;
      PRINT COLUMN 001, m_den_empresa,
            COLUMN 073, "FL. ", PAGENO USING "####"
      PRINT COLUMN 001, "CDV2001",
            COLUMN 042, "EXTRAIDO EM ",TODAY," AS ",TIME," HRS."
      SKIP 1 LINE
      PRINT COLUMN 025, "RELATORIO DE SOLICITACAO DE VIAGEM"
      SKIP 1 LINES

  BEFORE GROUP OF lr_relat.viagem
      SKIP TO TOP OF PAGE
      LET l_total = 0
      LET m_qtd_solic_impres = m_qtd_solic_impres + 1
      INITIALIZE m_num_ad TO NULL
      SKIP 1 LINE
      LET l_data  = lr_relat.dat_hr_emis_solic
      LET l_data1 = l_data[9,10],"/",l_data[6,7],"/",l_data[1,4]
      PRINT COLUMN 013, "VIAGEM: ",lr_relat.viagem     USING "<<<<<<<<<",
            COLUMN 031, "CONTROLE: ",lr_relat.controle USING "<<<<<<<<<<<<<<<<<<<<",
            COLUMN 062, "DATA: ",l_data1
      SKIP 1 LINE
      PRINT COLUMN 011, "VIAJANTE: ", m_den_viajante CLIPPED
      SKIP 1 LINE
      LET l_texto = lr_relat.cc_viajante USING "<<<<<<<<<"," - ",m_den_cc_viajante CLIPPED
      PRINT COLUMN 004, "C.C. (VIAJANTE): ",l_texto[1,37],
            COLUMN 059, "DATA/HORA PARTIDA"
      LET l_texto = lr_relat.cc_debitar USING "<<<<<<<<<"," - ",m_den_cc_debitar CLIPPED
      PRINT COLUMN 004, "C.C.(A DEBITAR): ",l_texto[1,37],
            COLUMN 059, "-------------------"

      LET l_data  = lr_relat.dat_hor_partida
      LET l_data2 = l_data[9,10],"/",l_data[6,7],"/",l_data[1,4], " ", l_data[12,19]

      PRINT COLUMN 059, l_data2
      LET l_texto = lr_relat.cliente_atendido CLIPPED," - ",m_den_cliente_atendido CLIPPED
      PRINT COLUMN 003, "CLIENTE ATENDIDO: ",l_texto[1,37]
      LET l_texto = lr_relat.cliente_fatur CLIPPED," - ",m_den_cliente_fatur CLIPPED
      PRINT COLUMN 004, "CLIENTE FATURAR: ",l_texto[1,37],
            COLUMN 059, "DATA/HORA RETORNO"
      LET l_texto = lr_relat.empresa_atendida CLIPPED," - ",m_den_empresa_atendida CLIPPED
      PRINT COLUMN 003, "EMPRESA ATENDIDA: ",l_texto[1,37],
            COLUMN 059, "-------------------"
      LET l_texto = lr_relat.filial_atendida CLIPPED," - ",m_den_filial_atendida CLIPPED

      LET l_data  = lr_relat.dat_hor_retorno
      LET l_data2 = l_data[9,10],"/",l_data[6,7],"/",l_data[1,4], " ", l_data[12,19]

      PRINT COLUMN 004, "FILIAL ATENDIDA: ",l_texto[1,37],
            COLUMN 059, l_data2
      LET l_texto = lr_relat.finalidade_viagem USING "<<<<<<<<<"," - ",m_den_finalidade_viagem CLIPPED
      PRINT COLUMN 002, "FINALIDADE VIAGEM: ",l_texto[1,37]
      PRINT COLUMN 002, "TRAJETO PRINCIPAL: ",lr_relat.trajeto_principal[1,37]
      SKIP 1 LINE
      PRINT COLUMN 006, "MOTIVO VIAGEM: ",lr_relat.motivo_viagem[1,53]
      IF LENGTH(lr_relat.motivo_viagem[54,106]) > 0 THEN
         PRINT COLUMN 021, lr_relat.motivo_viagem[54,106]
      END IF
      IF LENGTH(lr_relat.motivo_viagem[107,159]) > 0 THEN
         PRINT COLUMN 021, lr_relat.motivo_viagem[107,159]
      END IF
      IF LENGTH(lr_relat.motivo_viagem[160,200]) > 0 THEN
         PRINT COLUMN 021, lr_relat.motivo_viagem[160,200]
      END IF
      SKIP 1 LINES
      PRINT COLUMN 002, "=============================== ADIANTAMENTOS ================================"
      PRINT COLUMN 002, "  TIPO DE ADIANTAMENTO             VIAG.ORIG.   DATA                     VALOR"
      PRINT COLUMN 002, "  ------------------------------   ----------   ----------       -------------"

   ON EVERY ROW
      IF lr_relat.ies_solic_adto = "S" THEN
         PRINT COLUMN 002, "  ADIANTAMENTO DE VALOR",
               COLUMN 050, lr_relat.dat_adto_viagem USING "dd/mm/yyyy",
               COLUMN 067, lr_relat.val_adto_viagem USING "#########&.&&"
         IF lr_relat.val_adto_viagem IS NOT NULL THEN
            LET l_total = l_total + lr_relat.val_adto_viagem
         END IF
         IF lr_relat.ad_adiantamento IS NOT NULL THEN
            PRINT COLUMN 002, "  AD: ", lr_relat.ad_adiantamento USING "<<<<<<<<<";

            IF lr_relat.ap_adiantamento IS NOT NULL THEN
               PRINT COLUMN 020, "AP: ", lr_relat.ap_adiantamento USING "<<<<<<<<<"
            ELSE
               PRINT
            END IF

            LET m_num_ad           = lr_relat.ad_adiantamento
         END IF
      END IF

  AFTER GROUP OF lr_relat.viagem
      SKIP 1 LINE
      PRINT #COLUMN 037, "AD: ", lr_relat.ad_adiantamento USING "<<<<<<<<<",
            COLUMN 057, "TOTAL: ",l_total USING "############&.&&"
      #PRINT COLUMN 037, "AP: ", lr_relat.ap_adiantamento USING "<<<<<<<<<"
      PRINT COLUMN 002, "------------------------------------------------------------------------------"
      #IF m_qtd_solic_impres <> m_qtd_solic THEN
      #   SKIP TO TOP OF PAGE
      #END IF

  ON LAST ROW
      LET l_last_row = TRUE

  PAGE TRAILER
      IF l_last_row = TRUE THEN
         PRINT "* * * ULTIMA FOLHA * * *"
      ELSE
         PRINT ""
      END IF

END REPORT


#--------------------------------#
 FUNCTION cdv2001_ajusta_clausula()
#--------------------------------#
 DEFINE l_where_clause CHAR(400),
        l_ind          INTEGER

 LET l_where_clause = m_where_clause2

 FOR l_ind = 1 TO 400
    IF l_where_clause[l_ind,l_ind] = "/"
    OR l_where_clause[l_ind,l_ind] = "'\'"  THEN
       LET l_where_clause[l_ind,l_ind] = ' '
    END IF
    LET m_where_clause2[l_ind,l_ind] = l_where_clause[l_ind,l_ind]
 END FOR

 END FUNCTION

#--------------------------------#
 FUNCTION cdv2001_busca_clientes()
#--------------------------------#
 DEFINE l_cliente_aten like clientes.cod_cliente,
        l_cliente_fat  like clientes.cod_cliente

 CALL log2250_busca_parametro(p_cod_empresa,"cliente_atendido_pamcary")
      RETURNING l_cliente_aten, p_status

 IF p_status = FALSE OR l_cliente_aten IS NULL OR l_cliente_aten = " " THEN
 END IF

 CALL log2250_busca_parametro(p_cod_empresa,"cliente_faturar_pamcary")
      RETURNING l_cliente_fat, p_status

 IF p_status = FALSE OR l_cliente_fat IS NULL OR l_cliente_fat = " " THEN
 END IF

 RETURN l_cliente_aten, l_cliente_fat
 END FUNCTION

#---------------------------------#
FUNCTION cdv2001_busca_num_ap(l_ad)
#---------------------------------#
 DEFINE l_ad        LIKE ad_ap.num_ad,
        l_ap        LIKE ad_ap.num_ap

 WHENEVER ERROR CONTINUE
 DECLARE cq_num_ad_ap CURSOR FOR
 SELECT num_ap
   FROM ad_ap
  WHERE cod_empresa = p_cod_empresa
    AND num_ad      = l_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_NUM_AD_AP")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_num_ad_ap INTO l_ap
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       EXIT FOREACH
    END IF

    EXIT FOREACH
 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_num_ad_ap
 WHENEVER ERROR STOP

 RETURN l_ap
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2001_verifica_existencia_adto()
#-----------------------------------------#
 DEFINE l_cont       INTEGER

 WHENEVER ERROR CONTINUE
 SELECT viagem
   FROM cdv_solic_adto_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_tela.viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = NOTFOUND THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------------------------------------------------#
 FUNCTION cdv2001_gera_aprovacao_eletronica(l_num_viagem, l_num_ad, l_num_ap)
#------------------------------------------------------------------------------#
  DEFINE l_num_viagem     INTEGER,
         l_num_ad         LIKE ad_mestre.num_ad,
         l_num_ap         LIKE ap.num_ap

  ERROR "Enviando acerto de despesa de viagem para aprovação eletrônica ..." ATTRIBUTE(REVERSE)
  SLEEP 1

  CALL cdv0803_envia_email_aprov_eletronica(TRUE, "cdv", "S", l_num_viagem, l_num_ad,
                                            l_num_ap, 'V')
     RETURNING p_status

  IF p_status THEN
     CALL log0030_mensagem('Problema envio acerto para aprovação eletrônica (1)','exclamation')
     RETURN FALSE
  END IF

  CALL cdv0803_envia_email_aprov_eletronica(FALSE, "cdv", "S", l_num_viagem, l_num_ad,
                                            l_num_ap, 'V')
    RETURNING p_status

  IF p_status THEN
     CALL log0030_mensagem('Problema envio acerto para aprovação eletrônica (1)','exclamation')
     RETURN FALSE
  END IF

  IF NOT cdv0803_atualiza_dados_ad_acerto(l_num_ad, l_num_ap, l_num_viagem, "V") THEN
     RETURN TRUE
  END IF

  #CALL log006_exibe_teclas("01", p_versao)
  #CURRENT WINDOW IS w_cdv2002

  RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION cdv2001_cria_temp()
#--------------------------#

 WHENEVER ERROR CONTINUE
 DROP TABLE t_envio_email;
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  CREATE TEMP TABLE t_envio_email
 (num_ad          DECIMAL(6,0),
  email           CHAR(40),
  cod_nivel_autor CHAR(02));
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("CREATE","T_ENVIO_EMAIL")
 END IF

 END FUNCTION

#---------------------------#
 FUNCTION cdv2001_monta_aen()
#---------------------------#
 DEFINE l_empresa_atendida LIKE cdv_solic_viag_781.empresa_atendida,
        l_filial_atendida  LIKE cdv_solic_viag_781.filial_atendida,
        l_nivel            LIKE item.cod_seg_merc

 #WHENEVER ERROR CONTINUE
 #SELECT empresa_atendida,   filial_atendida
 #  INTO l_empresa_atendida, l_filial_atendida
 #  FROM cdv_solic_viag_781
 # WHERE empresa = p_cod_empresa
 #   AND viagem      = mr_tela.viagem
 #WHENEVER ERROR STOP
 #
 #IF SQLCA.sqlcode <> 0 THEN
 #   CALL log003_err_sql("SELECT","CDV_SOLIC_VIAG_781")
 #   RETURN TRUE
 #END IF

 #IF cdv0805_verifica_char_empresa(l_empresa_atendida) THEN
 CALL log2250_busca_parametro(mr_tela.empresa_atendida,'empresa_atendida_pamcary')
    RETURNING l_empresa_atendida, p_status
 IF NOT p_status OR l_empresa_atendida IS NULL THEN
    CALL log0030_mensagem('Parâmetro da empresa atendida não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 #END IF
 #
 #IF cdv0805_verifica_char_empresa(l_filial_atendida) THEN
 CALL log2250_busca_parametro(mr_tela.filial_atendida,'filial_atendida_pamcary')
    RETURNING l_filial_atendida, p_status
 IF NOT p_status OR l_filial_atendida IS NULL THEN
    CALL log0030_mensagem('Parâmetro da filial atendida não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 #END IF

 LET t_aen_309_4[1].cod_lin_prod  = l_empresa_atendida
 LET t_aen_309_4[1].cod_lin_recei = l_filial_atendida

 CALL log2250_busca_parametro(p_cod_empresa,'segmto_mercado_pamcary')
    RETURNING l_nivel, p_status
 IF NOT p_status OR l_nivel IS NULL THEN
    CALL log0030_mensagem('Segmento de mercado (AEN) não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 LET t_aen_309_4[1].cod_seg_merc = l_nivel

 CALL log2250_busca_parametro(p_cod_empresa,'classe_uso_pamcary')
    RETURNING l_nivel, p_status
 IF NOT p_status OR l_nivel IS NULL THEN
    CALL log0030_mensagem('Classe de uso (AEN) não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 LET t_aen_309_4[1].cod_cla_uso = l_nivel

 RETURN FALSE
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2001_busca_valores(l_viajante)
#-----------------------------------------#
 DEFINE l_viajante    LIKE cdv_info_viajante.matricula,
        l_cod_funcio  LIKE cdv_fornecedor_fun.cod_funcio,
        l_fornecedor  LIKE fornecedor.cod_fornecedor

 LET l_cod_funcio = l_viajante #integer to char

 WHENEVER ERROR CONTINUE
 SELECT cod_fornecedor
   INTO l_fornecedor
   FROM cdv_fornecedor_fun
  WHERE empresa    = p_cod_empresa
    AND cod_funcio = l_cod_funcio
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE mr_tela.banco,
               mr_tela.agencia,
               mr_tela.cta_corrente, m_den_banco TO NULL
    DISPLAY BY NAME mr_tela.banco,
                    mr_tela.agencia,
                    mr_tela.cta_corrente
    DISPLAY m_den_banco TO den_banco
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT cod_banco,
        num_agencia,
        num_conta_banco
   INTO mr_tela.banco,
        mr_tela.agencia,
        mr_tela.cta_corrente
   FROM fornecedor
  WHERE cod_fornecedor = l_fornecedor
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE mr_tela.banco,
               mr_tela.agencia,
               mr_tela.cta_corrente, m_den_banco TO NULL
    DISPLAY BY NAME mr_tela.banco,
                    mr_tela.agencia,
                    mr_tela.cta_corrente
    DISPLAY m_den_banco TO den_banco
    RETURN FALSE

 END IF

 DISPLAY BY NAME mr_tela.banco,
                 mr_tela.agencia,
                 mr_tela.cta_corrente
 LET m_den_banco = cdv2001_busca_den_banco(mr_tela.banco)
 DISPLAY m_den_banco TO den_banco

 RETURN TRUE

 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2001_alimenta_consulta()
#-----------------------------------#

 LET mr_consulta.viagem               = mr_tela.viagem
 LET mr_consulta.controle             = mr_tela.controle
 LET mr_consulta.dat_hr_emis_solic    = mr_tela.dat_hr_emis_solic
 LET mr_consulta.viajante             = mr_tela.viajante
 LET mr_consulta.finalidade_viagem    = mr_tela.finalidade_viagem
 LET mr_consulta.cc_viajante          = mr_tela.cc_viajante
 LET mr_consulta.cc_debitar           = mr_tela.cc_debitar
 LET mr_consulta.cliente_atendido     = mr_tela.cliente_atendido
 LET mr_consulta.cliente_fatur        = mr_tela.cliente_fatur
 LET mr_consulta.empresa_atendida     = mr_tela.empresa_atendida
 LET mr_consulta.filial_atendida      = mr_tela.filial_atendida

 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2001_busca_clientes_ate_fat(l_controle)
#------------------------------------------#

 DEFINE l_controle         LIKE cdv_controle_781.controle,
        l_cliente_atendido LIKE cdv_controle_781.cliente_atendido,
        l_cliente_fatur    LIKE cdv_controle_781.cliente_fatur

 WHENEVER ERROR CONTINUE
 DECLARE cq_busca_clientes CURSOR FOR
 SELECT cliente_atendido, cliente_fatur
   FROM cdv_controle_781
  WHERE controle = l_controle
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_BUSCA_CLIENTES")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_busca_clientes INTO l_cliente_atendido, l_cliente_fatur
 WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       EXIT FOREACH
    END IF
    EXIT FOREACH

 END FOREACH

 RETURN l_cliente_atendido, l_cliente_fatur
 END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION cdv2001_verifica_controle_finalidade(l_controle, l_finalidade)
#----------------------------------------------------------------------#
 DEFINE l_controle    LIKE cdv_controle_781.controle,
        l_finalidade  LIKE cdv_finalidade_781.finalidade

 LET l_finalidade = l_finalidade[1,2]
 WHENEVER ERROR CONTINUE
 SELECT controle
   FROM cdv_controle_781
  WHERE controle      = l_controle
    AND sistema[1,2]  = l_finalidade
    AND encerrado = "N"
 WHENEVER ERROR STOP


 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2001_busca_den_empresa_reduz(l_empresa)
#--------------------------------------------------#
  DEFINE l_empresa     LIKE empresa.cod_empresa,
         l_den_empresa LIKE empresa.den_empresa

  WHENEVER ERROR CONTINUE
   SELECT den_reduz
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_den_empresa TO NULL
  END IF

 RETURN l_den_empresa

 END FUNCTION

 #INICIO OS.470958
 #-----------------------------------------#
 FUNCTION cdv2001_insere_ap_observ(l_observ)
 #-----------------------------------------#

 DEFINE l_num_seq LIKE ap_obser.num_seq,
        l_observ  CHAR(200)

 WHENEVER ERROR CONTINUE
   SELECT MAX(num_seq)
     INTO l_num_seq
     FROM ap_obser
    WHERE cod_empresa = mr_tela.empresa
      AND num_ap      = mr_tela.ap_adiantamento
 WHENEVER ERROR STOP

 IF l_num_seq = 0 OR l_num_seq IS NULL THEN
    LET l_num_seq = 1
 ELSE
    LET l_num_seq = l_num_seq + 1
 END IF

 WHENEVER ERROR CONTINUE
   INSERT INTO ap_obser (cod_empresa,
                         num_ap,
                         num_seq,
                         observ)
                 VALUES (mr_tela.empresa,
                         mr_tela.ap_adiantamento,
                         l_num_seq,
                         l_observ)
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT", "AP_OBSER")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION
 #FIM OS.470958

#---------------------------------#
 FUNCTION cdv2001_status_pendente()
#---------------------------------#
 DEFINE l_status    LIKE cdv_acer_viag_781.status_acer_viagem

 WHENEVER ERROR CONTINUE
 SELECT status_acer_viagem
   INTO l_status
   FROM cdv_acer_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_tela.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN TRUE
 END IF

 IF l_status = "1" THEN
    RETURN TRUE
 END IF

 IF l_status = "2" THEN
    CALL log0030_mensagem("Exclusão deve ser efetuada pelo CDV2000 pois o acerto está iniciado.","stop")
    RETURN FALSE
 END IF

 IF l_status = "3" THEN
    CALL log0030_mensagem("Exclusão deve ser efetuada pelo CDV2000 pois o acerto está finalizado.","stop")
    RETURN FALSE
 END IF

 IF l_status = "4" THEN
    CALL log0030_mensagem("Exclusão deve ser efetuada pelo CDV2000 pois o acerto está liberado.","stop")
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2001_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2001.4gl $|$Revision: 10 $|$Date: 23/12/11 12:23 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION
