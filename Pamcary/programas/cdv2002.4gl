###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2002                                               #
# OBJETIVO: MANUTENCAO DA TABELA CDV_SOLIC_VIAG_781               #
# AUTOR...: ARLINDO CARLESSO                                      #
# DATA....: 06/07/2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_nom_arquivo       CHAR (100)
  DEFINE p_ies_impressao     CHAR(001),
         g_ies_ambiente      CHAR(001),
         g_ies_grafico       SMALLINT,
         p_user1             CHAR(08)

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
  DEFINE m_modifica_inclusao            SMALLINT,
         m_den_empresa_atendida         LIKE empresa.den_empresa,
         m_den_filial_atendida          LIKE empresa.den_empresa

  DEFINE m_den_empresa                  LIKE empresa.den_empresa

  DEFINE m_sql_stmt                   CHAR(1200),
         where_clause                 CHAR(400),
         sql_stmt                     CHAR(1200),
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

  DEFINE m_caminho                      CHAR(150)
  DEFINE m_comando                      CHAR(080)
  DEFINE m_camh_help_cdv2002            CHAR(150),
         m_empresa_atendida_pamcary     LIKE empresa.cod_empresa,
         m_filial_atendida_pamcary      LIKE empresa.cod_empresa

  DEFINE mr_tela  RECORD
                     empresa           LIKE cdv_solic_viag_781.empresa,
                     viagem            LIKE cdv_solic_viag_781.viagem,
                     controle          LIKE cdv_solic_viag_781.controle,
                     dat_adto_viagem   DATE, #LIKE cdv_solic_viag_781.dat_hr_emis_solic,
                     hora              DATETIME HOUR TO SECOND,
                     viajante          LIKE cdv_solic_viag_781.viajante,
                     finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
                     cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
                     cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
                     sequencia_adto    LIKE cdv_solic_adto_781.sequencia_adto,
                     val_adto_viagem   LIKE cdv_solic_adto_781.val_adto_viagem,
                     forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
                     banco             LIKE cdv_solic_adto_781.banco,
                     agencia           LIKE cdv_solic_adto_781.agencia,
                     cta_corrente      LIKE cdv_solic_adto_781.cta_corrente,
                     ad_adiantamento   LIKE ad_mestre.num_ad,
                     ap_adiantamento   LIKE ad_mestre.num_ad
                  END RECORD

  DEFINE mr_telar RECORD
                     empresa           LIKE cdv_solic_viag_781.empresa,
                     viagem            LIKE cdv_solic_viag_781.viagem,
                     controle          LIKE cdv_solic_viag_781.controle,
                     dat_adto_viagem   DATE, #LIKE cdv_solic_viag_781.dat_hr_emis_solic,
                     hora              DATETIME HOUR TO SECOND,
                     viajante          LIKE cdv_solic_viag_781.viajante,
                     finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
                     cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
                     cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
                     sequencia_adto    LIKE cdv_solic_adto_781.sequencia_adto,
                     val_adto_viagem   LIKE cdv_solic_adto_781.val_adto_viagem,
                     forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
                     banco             LIKE cdv_solic_adto_781.banco,
                     agencia           LIKE cdv_solic_adto_781.agencia,
                     cta_corrente      LIKE cdv_solic_adto_781.cta_corrente,
                     ad_adiantamento   LIKE ad_mestre.num_ad,
                     ap_adiantamento   LIKE ad_mestre.num_ad
                  END RECORD

  DEFINE m_den_viajante          LIKE funcionario.nom_funcionario,
         m_den_finalidade_viagem LIKE cdv_solic_viagem.des_find_viagem,
         m_den_cliente_atendido  LIKE clientes.nom_cliente,
         m_den_cc_viajante       LIKE cad_cc.nom_cent_cust,
         m_den_cc_debitar        LIKE cad_cc.nom_cent_cust,
         m_qtd_solic             INTEGER,
         m_qtd_solic_impres      INTEGER,
         m_num_ad                LIKE ad_ap.num_ad,
         m_den_cliente_fatur     LIKE clientes.nom_cliente,
         m_den_banco             LIKE bancos.nom_banco,
         m_chamada_parametro     SMALLINT,
         m_viagem                LIKE cdv_solic_viag_781.viagem

  DEFINE m_arg                 SMALLINT

MAIN

CALL log0180_conecta_usuario()

LET p_versao = "CDV2002-10.02.00p" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP

  DEFER INTERRUPT

  LET m_camh_help_cdv2002 = log140_procura_caminho('cdv2002.iem')
  LET m_chamada_parametro = FALSE
  INITIALIZE m_viagem TO NULL

  OPTIONS
     PREVIOUS  KEY control-b,
     NEXT      KEY control-f,
     HELP     FILE m_camh_help_cdv2002

  CALL log001_acessa_usuario("CDV","LOGERP;LOGLQ2")
       RETURNING p_status, p_cod_empresa, p_user

  LET p_user1 = p_user

  IF NUM_ARGS() > 0 THEN
     LET m_arg = TRUE
     LET p_cod_empresa = ARG_VAL(1)
     LET m_viagem      = ARG_VAL(2)
     IF  m_viagem IS NOT NULL THEN
        LET m_chamada_parametro = TRUE
     END IF
  ELSE
     LET m_arg = FALSE
  END IF

  IF p_status = 0  THEN
     CALL cdv2002_controle()
  END IF

END MAIN

#----------------------------#
 FUNCTION cdv2002_controle()
#----------------------------#

  DEFINE l_viagem  LIKE cdv_solic_viag_781.viagem,
         l_status  SMALLINT

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("CDV2002") RETURNING m_caminho
  OPEN WINDOW w_cdv2002 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CALL cdv2002_inicializa_campos()
  CALL cdv2002_cria_temp()

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

  DISPLAY p_cod_empresa TO empresa

  IF m_arg THEN
     LET l_viagem = ARG_VAL(2)
     LET where_clause = "cdv_solic_viag_781.viagem = ",l_viagem
     IF cdv2002_prepara_consulta("2") THEN
     END IF
  END IF

   MENU "OPÇÃO"
    BEFORE MENU
       IF m_chamada_parametro = TRUE THEN
          HIDE OPTION "Incluir"
          HIDE OPTION "Excluir"
          LET mr_tela.empresa = p_cod_empresa
          LET mr_tela.viagem  = m_viagem
          DISPLAY BY NAME mr_tela.empresa
          DISPLAY BY NAME mr_tela.viagem
          LET m_consulta_ativa = TRUE
       END IF

    COMMAND "Incluir" "Inclui um novo registro na tabela CDV_SOLIC_ADTO_781."
      HELP 001
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2002","IN")  THEN
         CALL cdv2002_inclusao()
         LET m_ies_cons = FALSE
      END IF

    COMMAND "Excluir" "Exclui um registro da tabela CDV_SOLIC_ADTO_781."
      HELP 003
      MESSAGE ""
      IF m_consulta_ativa OR m_modifica_inclusao THEN
         IF log005_seguranca(p_user,"CDV","CDV2002","MO")  THEN
            CALL cdv2002_exclusao()
         END IF
      ELSE
         CALL log0030_mensagem(' Consulte previamente para fazer a exclusão. ','info')
      END IF

    COMMAND "Consultar" "Consulta os registros da tabela CDV_SOLIC_ADTO_781."
      HELP 004
      MESSAGE ""
      IF log005_seguranca(p_user,"CDV","CDV2002","CO") THEN
         CALL cdv2002_consulta()
      END IF

    COMMAND "Seguinte" "Exibe o próximo registro encontrado na pesquisa."
      HELP 005
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2002_paginacao("SEGUINTE")
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND "Anterior" "Exibe o registro anterior encontrado na pesquisa."
      HELP 006
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2002_paginacao("ANTERIOR")
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND "Listar" "Lista os adiantamentos para a viagem em tela."
      HELP 007
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL cdv2002_alimenta_consulta()
         CALL cdv2002_lista()
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF


    COMMAND KEY("R") "apRovantes" "Consulta os aprovantes da solicitação de viagem."
      HELP 009
      MESSAGE ""
      IF m_consulta_ativa OR m_ies_cons THEN
         CALL log120_procura_caminho("cap3450") RETURNING m_comando
         LET m_comando = m_comando CLIPPED, " ", mr_tela.ad_adiantamento,
                                            " ", p_cod_empresa,
                                            " cap0220 "
         RUN m_comando
         CALL log006_exibe_teclas('01 09', p_versao)
         CURRENT WINDOW IS w_cdv2002
      ELSE
         CALL log0030_mensagem(' Não existe nenhuma consulta ativa. ','info')
      END IF

    COMMAND "Autoriz_pgto" "Executa o programa cap0160 para visualizar as informações da AP."
       HELP 012
       MESSAGE " "
       CALL log120_procura_caminho("cap0160") RETURNING m_comando
       LET m_comando = m_comando CLIPPED, " ", mr_tela.ap_adiantamento,
                                          " ", mr_tela.empresa
       RUN m_comando RETURNING p_status
       LET p_status = p_status / 256
       IF p_status = 0 THEN
       ELSE
          PROMPT "Tecle ENTER para continuar" FOR CHAR m_comando
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
  CLOSE WINDOW w_cdv2002
END FUNCTION


#------------------------------------#
 FUNCTION cdv2002_inicializa_campos()
#------------------------------------#

  LET m_consulta_ativa           = FALSE

  INITIALIZE mr_tela.*,
             mr_telar.* TO NULL

  INITIALIZE m_den_viajante,
             m_den_finalidade_viagem,
             m_den_cliente_atendido,
             m_den_cliente_fatur,
             m_den_banco TO NULL

END FUNCTION

#---------------------------#
 FUNCTION cdv2002_consulta()
#---------------------------#

    CALL log006_exibe_teclas('01 02 07 08', p_versao)
    CURRENT WINDOW IS w_cdv2002

    LET where_clause =  NULL

    CLEAR FORM
    DISPLAY p_cod_empresa TO empresa

    LET INT_FLAG = FALSE

    INITIALIZE mr_tela.* TO NULL

    IF m_chamada_parametro = TRUE THEN
       LET mr_tela.empresa = p_cod_empresa
       LET mr_tela.viagem  = m_viagem
       DISPLAY BY NAME mr_tela.empresa
       DISPLAY BY NAME mr_tela.viagem
    END IF

    IF cdv2002_construct() THEN

       IF cdv2002_prepara_consulta("1") THEN END IF

       LET m_modifica_inclusao = FALSE

       CALL log006_exibe_teclas('01 09', p_versao)
       CURRENT WINDOW IS w_cdv2002
       IF m_consulta_ativa = TRUE THEN
          CALL cdv2002_exibe_dados()
       END IF

    END IF

    CALL log006_exibe_teclas('01 09', p_versao)
    CURRENT WINDOW IS w_cdv2002

END FUNCTION

#-----------------------------#
 FUNCTION cdv2002_construct()
#-----------------------------#

    DEFINE l_viagem   like cdv_solic_viag_781.viagem,
           l_controle like cdv_solic_viag_781.controle

    LET INT_FLAG = 0

    CONSTRUCT BY NAME where_clause ON cdv_solic_viag_781.viagem,
                                        cdv_solic_viag_781.controle,
                                        cdv_solic_adto_781.dat_adto_viagem,
                                        cdv_solic_viag_781.viajante,
                                        cdv_solic_viag_781.finalidade_viagem,
                                        cdv_solic_viag_781.cliente_atendido,
                                        cdv_solic_viag_781.cliente_fatur,
                                        cdv_solic_adto_781.val_adto_viagem,
                                        cdv_solic_adto_781.forma_adto_viagem,
                                        cdv_solic_adto_781.banco,
                                        cdv_solic_adto_781.agencia,
                                        cdv_solic_adto_781.cta_corrente

        BEFORE FIELD viagem
           IF m_chamada_parametro = TRUE THEN
              LET mr_tela.empresa = p_cod_empresa
              LET mr_tela.viagem  = m_viagem
              DISPLAY BY NAME mr_tela.empresa
              DISPLAY BY NAME mr_tela.viagem
              LET m_chamada_parametro = FALSE
           END IF

        BEFORE FIELD controle
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', 'Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,68
           END IF
        AFTER FIELD controle
           IF g_ies_grafico THEN
              --# CALL fgl_dialog_setkeylabel('Control-Z', null)
           ELSE
              DISPLAY "--------" AT 3,68
           END IF

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

        AFTER CONSTRUCT
           IF NOT INT_FLAG THEN
              CALL get_fldbuf(viagem)   RETURNING l_viagem
              CALL get_fldbuf(controle) RETURNING l_controle

              IF  l_viagem IS NULL
              AND l_controle IS NULL THEN
                 CALL log0030_mensagem('Viagem ou controle devem ser informados.','exclamation')
                 NEXT FIELD viagem
              END IF

           END IF

        ON KEY (control-w, f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE CONSTRUCT
           #lds END IF
           CALL cdv2002_help()
        ON KEY (control-z, f4)
           CALL cdv2002_popup()
       --# CALL fgl_dialog_setkeylabel('control-z',NULL)

    END CONSTRUCT

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv2002

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

#-----------------------------------------#
 FUNCTION cdv2002_prepara_consulta(l_tipo)
#-----------------------------------------#

    DEFINE l_tipo      CHAR(01),
           l_data_hora CHAR(19),
           l_data      CHAR(10),
           l_hora      CHAR(08)

    IF where_clause IS NULL THEN
       LET where_clause = " 1=1 "
    END IF
    LET m_sql_stmt = "SELECT cdv_solic_viag_781.empresa,",
                           " cdv_solic_viag_781.viagem,",
                           " cdv_solic_viag_781.controle,",
                           " cdv_solic_adto_781.dat_adto_viagem,",
                           " cdv_solic_viag_781.viajante,",
                           " cdv_solic_viag_781.finalidade_viagem,",
                           " cdv_solic_viag_781.cliente_atendido,",
                           " cdv_solic_viag_781.cliente_fatur,",
                           " cdv_solic_adto_781.sequencia_adto,",
                           " cdv_solic_adto_781.val_adto_viagem,",
                           " cdv_solic_adto_781.forma_adto_viagem,",
                           " cdv_solic_adto_781.banco,",
                           " cdv_solic_adto_781.agencia,",
                           " cdv_solic_adto_781.cta_corrente,",
                           " cdv_solic_adto_781.num_ad_adto_viagem",
                      " FROM cdv_solic_viag_781,cdv_solic_adto_781",
                     " WHERE cdv_solic_viag_781.empresa = '",p_cod_empresa CLIPPED,"'",
                       " AND ",where_clause CLIPPED,
                       " AND cdv_solic_adto_781.empresa = '",p_cod_empresa CLIPPED,"'",
                       " AND cdv_solic_adto_781.viagem = cdv_solic_viag_781.viagem",
                     " ORDER BY cdv_solic_viag_781.empresa,cdv_solic_viag_781.viagem,cdv_solic_adto_781.sequencia_adto"

    WHENEVER ERROR CONTINUE
    PREPARE var_query_viagem1 FROM m_sql_stmt
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('PREPARE','CDV_SOLIC_VIAG_781') RETURN FALSE END IF
    WHENEVER ERROR CONTINUE
    DECLARE cq_cdv_solic_viag1_781 SCROLL CURSOR WITH HOLD FOR var_query_viagem1
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('DECLARE','CDV_SOLIC_VIAG_781') RETURN FALSE END IF
    WHENEVER ERROR CONTINUE
    OPEN cq_cdv_solic_viag1_781
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN CALL log003_err_sql('OPEN','CDV_SOLIC_VIAG_781') RETURN FALSE END IF
    WHENEVER ERROR CONTINUE
    FETCH cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                      mr_tela.viagem,
                                      mr_tela.controle,
                                      #l_data_hora,
                                      mr_tela.dat_adto_viagem,
                                      mr_tela.viajante,
                                      mr_tela.finalidade_viagem,
                                      mr_tela.cliente_atendido,
                                      mr_tela.cliente_fatur,
                                      mr_tela.sequencia_adto,
                                      mr_tela.val_adto_viagem,
                                      mr_tela.forma_adto_viagem,
                                      mr_tela.banco,
                                      mr_tela.agencia,
                                      mr_tela.cta_corrente,
                                      mr_tela.ad_adiantamento
    WHENEVER ERROR STOP
    #LET mr_tela.hora = l_data_hora[12,19]
    #LET l_data_hora  = l_data_hora[9,10],"/",
    #                   l_data_hora[6,7], "/",
    #                   l_data_hora[1,4]

    #LET mr_tela.dat_adto_viagem = l_data_hora CLIPPED

    IF sqlca.sqlcode = 0 THEN
       IF l_tipo = "2" THEN
          LET mr_tela.dat_adto_viagem = TODAY
          LET mr_tela.hora = TIME
          CALL cdv2002_exibe_dados()
          RETURN TRUE
       END IF
       CALL cdv2002_busca_hora()
       MESSAGE ' Consulta efetuada com sucesso. ' ATTRIBUTE(REVERSE)
       LET m_consulta_ativa = TRUE
       LET m_ies_cons       = TRUE
    ELSE
       IF l_tipo = "2" THEN
          WHENEVER ERROR CONTINUE
          SELECT empresa,
                 viagem,
                 controle,
                 dat_hr_emis_solic,
                 viajante,
                 finalidade_viagem,
                 cliente_atendido,
                 cliente_fatur
            INTO mr_tela.empresa,
                 mr_tela.viagem,
                 mr_tela.controle,
                 l_data_hora,
                 mr_tela.viajante,
                 mr_tela.finalidade_viagem,
                 mr_tela.cliente_atendido,
                 mr_tela.cliente_fatur
            FROM cdv_solic_viag_781
           WHERE empresa = p_cod_empresa
             AND viagem = mr_tela.viagem
          WHENEVER ERROR STOP

          #LET mr_tela.hora = l_data_hora[12,19]
          LET mr_tela.hora = TIME
          LET l_data_hora  = l_data_hora[9,10],"/",
                             l_data_hora[6,7], "/",
                             l_data_hora[1,4]

          #LET mr_tela.dat_adto_viagem = l_data_hora CLIPPED
          IF SQLCA.sqlcode = 0 THEN
             LET m_consulta_ativa = TRUE
             LET mr_tela.dat_adto_viagem = TODAY
             LET mr_tela.hora = TIME
             CALL cdv2002_exibe_dados()
             RETURN TRUE
          ELSE
             CLOSE cq_cdv_solic_viag1_781
             RETURN FALSE
          END IF
       END IF
       LET m_consulta_ativa = FALSE
       CLEAR FORM
       DISPLAY p_cod_empresa TO empresa
       CALL log0030_mensagem(' Argumentos de pesquisa não encontrados. ','info')
       LET m_ies_cons = FALSE
    END IF

    RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv2002_paginacao(l_funcao)
#------------------------------------#

  DEFINE l_funcao    CHAR(20),
         l_data_hora CHAR(19),
         l_data      CHAR(10),
         l_hora      CHAR(08)

  LET mr_telar.* = mr_tela.*

  WHILE TRUE

     IF l_funcao = 'SEGUINTE' THEN
        WHENEVER ERROR CONTINUE
        FETCH NEXT cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                               mr_tela.viagem,
                                               mr_tela.controle,
                                               #l_data_hora,
                                               mr_tela.dat_adto_viagem,
                                               mr_tela.viajante,
                                               mr_tela.finalidade_viagem,
                                               mr_tela.cliente_atendido,
                                               mr_tela.cliente_fatur,
                                               mr_tela.sequencia_adto,
                                               mr_tela.val_adto_viagem,
                                               mr_tela.forma_adto_viagem,
                                               mr_tela.banco,
                                               mr_tela.agencia,
                                               mr_tela.cta_corrente,
                                               mr_tela.ad_adiantamento
        WHENEVER ERROR STOP
        #LET mr_tela.hora = l_data_hora[12,19]
        CALL cdv2002_busca_hora()
        LET l_data_hora  = l_data_hora[9,10],"/",
                           l_data_hora[6,7], "/",
                           l_data_hora[1,4]

        #LET mr_tela.dat_adto_viagem = l_data_hora CLIPPED

        IF SQLCA.sqlcode = 0 THEN END IF
     ELSE
        WHENEVER ERROR CONTINUE
        FETCH PREVIOUS cq_cdv_solic_viag1_781 INTO mr_tela.empresa,
                                                   mr_tela.viagem,
                                                   mr_tela.controle,
                                                   #l_data_hora,
                                                   mr_tela.dat_adto_viagem,
                                                   mr_tela.viajante,
                                                   mr_tela.finalidade_viagem,
                                                   mr_tela.cliente_atendido,
                                                   mr_tela.cliente_fatur,
                                                   mr_tela.sequencia_adto,
                                                   mr_tela.val_adto_viagem,
                                                   mr_tela.forma_adto_viagem,
                                                   mr_tela.banco,
                                                   mr_tela.agencia,
                                                   mr_tela.cta_corrente,
                                                   mr_tela.ad_adiantamento
        WHENEVER ERROR STOP
        #LET mr_tela.hora = l_data_hora[12,19]
        CALL cdv2002_busca_hora()
        LET l_data_hora  = l_data_hora[9,10],"/",
                           l_data_hora[6,7], "/",
                           l_data_hora[1,4]

        #LET mr_tela.dat_adto_viagem = l_data_hora CLIPPED

        IF SQLCA.sqlcode = 0 THEN END IF
     END IF

     IF SQLCA.sqlcode = 0 THEN
        WHENEVER ERROR CONTINUE
        SELECT cdv_solic_viag_781.empresa,
               cdv_solic_viag_781.viagem,
               cdv_solic_viag_781.controle,
               cdv_solic_adto_781.dat_adto_viagem,
               cdv_solic_viag_781.viajante,
               cdv_solic_viag_781.finalidade_viagem,
               cdv_solic_viag_781.cliente_atendido,
               cdv_solic_viag_781.cliente_fatur,
               cdv_solic_adto_781.sequencia_adto,
               cdv_solic_adto_781.val_adto_viagem,
               cdv_solic_adto_781.forma_adto_viagem,
               cdv_solic_adto_781.banco,
               cdv_solic_adto_781.agencia,
               cdv_solic_adto_781.cta_corrente,
               cdv_solic_adto_781.num_ad_adto_viagem
          INTO mr_tela.empresa,
               mr_tela.viagem,
               mr_tela.controle,
               #l_data_hora,
               mr_tela.dat_adto_viagem,
               mr_tela.viajante,
               mr_tela.finalidade_viagem,
               mr_tela.cliente_atendido,
               mr_tela.cliente_fatur,
               mr_tela.sequencia_adto,
               mr_tela.val_adto_viagem,
               mr_tela.forma_adto_viagem,
               mr_tela.banco,
               mr_tela.agencia,
               mr_tela.cta_corrente,
               mr_tela.ad_adiantamento
          FROM cdv_solic_viag_781,cdv_solic_adto_781
         WHERE cdv_solic_viag_781.empresa  = p_cod_empresa
           AND cdv_solic_viag_781.viagem = mr_tela.viagem
           AND cdv_solic_adto_781.empresa = p_cod_empresa
           AND cdv_solic_adto_781.viagem = mr_tela.viagem
           AND cdv_solic_adto_781.sequencia_adto = mr_tela.sequencia_adto
        WHENEVER ERROR STOP
        #LET mr_tela.hora = l_data_hora[12,19]
        CALL cdv2002_busca_hora()
        LET l_data_hora  = l_data_hora[9,10],"/",
                           l_data_hora[6,7], "/",
                           l_data_hora[1,4]

        #LET mr_tela.dat_adto_viagem = l_data_hora CLIPPED

        IF SQLCA.sqlcode = 0 THEN
           LET mr_telar.* = mr_tela.*
           EXIT WHILE
        END IF
     ELSE
        ERROR ' Não existem mais itens nesta direção. '
        LET mr_tela.* = mr_telar.*
        EXIT WHILE
     END IF

  END WHILE

  CALL cdv2002_exibe_dados()

END FUNCTION

#------------------------------------#
 FUNCTION cdv2002_cursor_for_update()
#------------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_solic_adto_781 CURSOR FOR
    SELECT cdv_solic_adto_781.sequencia_adto,
           cdv_solic_adto_781.val_adto_viagem,
           cdv_solic_adto_781.forma_adto_viagem,
           cdv_solic_adto_781.banco,
           cdv_solic_adto_781.agencia,
           cdv_solic_adto_781.cta_corrente
      FROM cdv_solic_adto_781
     WHERE cdv_solic_adto_781.empresa        = p_cod_empresa
       AND cdv_solic_adto_781.viagem         = mr_tela.viagem
       AND cdv_solic_adto_781.sequencia_adto = mr_tela.sequencia_adto
   #FOR UPDATE
   WHENEVER ERROR STOP
   IF SQLCA.sqlcode = 0 THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      WHENEVER ERROR STOP

      IF SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("BEGIN","CDV_SOLIC_ADTO_781")
      END IF

      WHENEVER ERROR CONTINUE
      OPEN cm_solic_adto_781
      WHENEVER ERROR STOP
      IF SQLCA.sqlcode = 0 THEN
         WHENEVER ERROR CONTINUE
         FETCH cm_solic_adto_781 INTO mr_tela.sequencia_adto,
                                          mr_tela.val_adto_viagem,
                                          mr_tela.forma_adto_viagem,
                                          mr_tela.banco,
                                          mr_tela.agencia,
                                          mr_tela.cta_corrente
         WHENEVER ERROR STOP
         CASE
           WHEN sqlca.sqlcode = 0 RETURN TRUE
           WHEN sqlca.sqlcode = -250 CALL log0030_mensagem("Viagem sendo atualizada por outro usuário. \nAguarde e tente novamente. ","exclamation")
           WHEN sqlca.sqlcode =  100 CALL log0030_mensagem("Viagem não mais existente na tabela. \nExecute a consulta novamente. ","exclamation")
           OTHERWISE CALL log003_err_sql("LEITURA","CDV_SOLIC_VIAG_781")
         END CASE
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION cdv2002_exibe_dados()
#-------------------------------#

  CALL log006_exibe_teclas('01 09', p_versao)
  CURRENT WINDOW IS w_cdv2002

  LET mr_tela.empresa = p_cod_empresa

  CALL cdv2002_busca_num_ap() RETURNING mr_tela.ap_adiantamento

  DISPLAY BY NAME mr_tela.empresa, mr_tela.viagem, mr_tela.controle, mr_tela.dat_adto_viagem,
                  mr_tela.hora, mr_tela.viajante, mr_tela.finalidade_viagem, mr_tela.cliente_atendido,
                  mr_tela.cliente_fatur, mr_tela.val_adto_viagem, mr_tela.forma_adto_viagem,
                  mr_tela.banco, mr_tela.agencia, mr_tela.cta_corrente,
                  mr_tela.ad_adiantamento, mr_tela.ap_adiantamento

  LET m_den_viajante = cdv2002_busca_den_viajante(mr_tela.viajante)
  LET m_den_finalidade_viagem = cdv2002_busca_den_finalidade_viagem(mr_tela.finalidade_viagem)
  LET m_den_cliente_atendido = cdv2002_busca_den_cliente(mr_tela.cliente_atendido)
  LET m_den_cliente_fatur = cdv2002_busca_den_cliente(mr_tela.cliente_fatur)
  LET m_den_banco = cdv2002_busca_den_banco(mr_tela.banco)

  DISPLAY m_den_viajante TO den_viajante
  DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
  DISPLAY m_den_cliente_atendido TO den_cliente_atendido
  DISPLAY m_den_cliente_fatur TO den_cliente_fatur
  DISPLAY m_den_banco TO den_banco

END FUNCTION

#---------------------------#
 FUNCTION cdv2002_exclusao()
#---------------------------#
 DEFINE l_aprovado CHAR(01),
        l_permite  SMALLINT

 LET l_aprovado = NULL
 LET l_permite  = FALSE

  WHENEVER ERROR CONTINUE
  DECLARE cl_aprov_neces CURSOR FOR
   SELECT ies_aprovado
     FROM aprov_necessaria
    WHERE cod_empresa  = p_cod_empresa
      AND num_ad       = mr_tela.ad_adiantamento
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CL_APROV_NECES")
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cl_aprov_neces INTO l_aprovado
  WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
        CALL log003_err_sql("FOREACH","CL_APROV_NECES")
     END IF

     IF l_aprovado = "N"  THEN
        LET l_permite = TRUE
     END IF
  END FOREACH
  FREE cl_aprov_neces

  IF l_aprovado IS NOT NULL  THEN
     IF l_permite = FALSE  THEN
        CALL log0030_mensagem("AD está totalmente aprovada. Exclusão cancelada.","info")
        RETURN
     END IF
  END IF

  IF cdv2002_cursor_for_update() THEN
     IF log0040_confirm(13,10,"Confirma exclusão?") THEN

        IF NOT cdv2002_exclui_ad_ap_adiantamento() THEN
           ERROR ""
           MESSAGE ""
           CALL log085_transacao("ROLLBACK")
        ELSE
           ERROR ""
           MESSAGE ""
           WHENEVER ERROR CONTINUE
           DELETE FROM cdv_solic_adto_781
            WHERE empresa        = p_cod_empresa
              AND viagem         = mr_tela.viagem
              AND sequencia_adto = mr_tela.sequencia_adto
                WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("COMMIT")
              WHENEVER ERROR STOP

              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("COMMIT","CDV_SOLIC_ADTO_781")
              END IF

              CLEAR FORM
              DISPLAY p_cod_empresa TO empresa
              MESSAGE 'Exclusão efetuada com sucesso. '
              CALL log006_exibe_teclas("01", p_versao)
           ELSE
              CALL log003_err_sql('EXCLUSAO','CDV_SOLIC_ADTO_781')
              CALL log085_transacao("ROLLBACK")
           END IF
        END IF
     ELSE
        CLOSE cm_solic_adto_781
        CALL log085_transacao("ROLLBACK")
        ERROR ' Exclusão cancelada. '
     END IF
     CLOSE cm_solic_adto_781
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2002_exclui_ad_ap_adiantamento()
#--------------------------------------------#

 IF mr_tela.ap_adiantamento IS NOT NULL THEN
    MESSAGE "Excluindo AP do contas a pagar . . ." ATTRIBUTE(REVERSE)
    CALL log120_procura_caminho("cap0160") RETURNING m_comando
    LET m_comando = m_comando CLIPPED, " ",mr_tela.ap_adiantamento," ",p_cod_empresa," ","S"
    RUN m_comando

		  WHENEVER ERROR CONTINUE
		   SELECT num_ap
		     FROM ap
		    WHERE cod_empresa = p_cod_empresa
		      AND num_ap      = mr_tela.ap_adiantamento
		  WHENEVER ERROR STOP

		  IF SQLCA.SQLCODE = 0
		  OR SQLCA.SQLCODE = -284 THEN
		     CALL log0030_mensagem("AP não pode ser excluída, exclusão cancelada. Verifique se a mesma não está paga ou exista alguma pendencia a ela.",'exclamation')
		     RETURN FALSE
		  END IF
 END IF

 IF mr_tela.ad_adiantamento IS NOT NULL THEN
    MESSAGE "Excluindo AD do contas a pagar . . ." ATTRIBUTE(REVERSE)
    CALL log120_procura_caminho("cap0220") RETURNING m_comando
    LET m_comando = m_comando CLIPPED," ", mr_tela.ad_adiantamento,
                                      " ", p_cod_empresa,
                                      " ", "EXCLUIR",
                                      " ", "CDV2002"
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
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION cdv2002_inclusao()
#---------------------------#

  LET mr_telar.* = mr_tela.*

  INITIALIZE mr_tela.* TO NULL

  CLEAR FORM
  DISPLAY p_cod_empresa TO empresa

  IF cdv2002_entrada_dados1() THEN
     LET where_clause = "cdv_solic_viag_781.viagem = ",mr_tela.viagem
     IF cdv2002_prepara_consulta("2") THEN
        IF cdv2002_entrada_dados2() THEN
           WHENEVER ERROR CONTINUE
           SELECT MAX(sequencia_adto) + 1
             INTO mr_tela.sequencia_adto
             FROM cdv_solic_adto_781
            WHERE empresa = p_cod_empresa
              AND viagem = mr_tela.viagem
           WHENEVER ERROR STOP
           IF SQLCA.sqlcode <> 0 OR
              mr_tela.sequencia_adto IS NULL OR
              mr_tela.sequencia_adto = 0 THEN
              LET mr_tela.sequencia_adto = 1
           END IF

           WHENEVER ERROR CONTINUE
           CALL log085_transacao("BEGIN")
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("BEGIN","CDV_SOLIC_ADTO_781")
              CALL log085_transacao("ROLLBACK")
              RETURN
           END IF

           CALL cdv2002_gera_informacoes_cap() RETURNING p_status

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
                                          mr_tela.sequencia_adto,
                                          TODAY,
                                          mr_tela.val_adto_viagem,
                                          mr_tela.forma_adto_viagem,
                                          mr_tela.banco,
                                          mr_tela.agencia,
                                          mr_tela.cta_corrente,
                                          mr_tela.ad_adiantamento)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              IF NOT cdv2002_gera_aprovacao_eletronica(mr_tela.viagem,
                                                       mr_tela.ad_adiantamento,
                                                       mr_tela.ap_adiantamento) THEN
                 RETURN
              END IF

              LET m_modifica_inclusao = TRUE
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("COMMIT")
              WHENEVER ERROR STOP
              MESSAGE 'Inclusão efetuada com sucesso. '

              CALL cdv2002_alimenta_consulta()
              CALL cdv2002_lista()

              RETURN
           ELSE
              CALL log003_err_sql('INSERT','CDV_SOLIC_ADTO_781')
              LET mr_tela.* = mr_telar.*
              CALL cdv2002_exibe_dados()
              ERROR ' Inclusão cancelada. '
           END IF
        ELSE
           LET mr_tela.* = mr_telar.*
           CALL cdv2002_exibe_dados()
           ERROR ' Inclusão cancelada. '
        END IF
     ELSE
        CLEAR FORM
        DISPLAY p_cod_empresa TO empresa
        ERROR 'Inclusão cancelada. '
     END IF
  ELSE
     LET mr_tela.* = mr_telar.*
     CALL cdv2002_exibe_dados()
     ERROR ' Inclusão cancelada. '
  END IF

END FUNCTION

#---------------------------------------#
 FUNCTION cdv2002_gera_informacoes_cap()
#---------------------------------------#

  DEFINE l_work         SMALLINT,
         l_msg          CHAR(100),
         l_num_ad       LIKE ad_mestre.num_ad,
         l_num_ap       LIKE ad_mestre.num_ad,
         l_ind_aen      INTEGER

  DEFINE l_aux_cod_fornecedor LIKE cdv_fornecedor_fun.cod_fornecedor,
         l_aux_ies_dep_cred   CHAR(01),
         l_aux_tip_desp       LIKE cdv_par_ctr_viagem.tip_desp_adto_viag,
         l_filial_atendida    LIKE cdv_solic_viag_781.filial_atendida,
         l_num_nf             LIKE audit_cap.num_nf,
         l_hora               CHAR(8)

  LET l_aux_tip_desp = cdv2002_carrega_cdv_par_ctr_viagem()

  LET l_aux_cod_fornecedor = cdv2002_carrega_fornecedor()

  IF mr_tela.forma_adto_viagem = "DC" THEN
     LET l_aux_ies_dep_cred = "S"
  ELSE
     LET l_aux_ies_dep_cred = "N"
  END IF

  CALL cdv2002_monta_aen() RETURNING p_status

  IF p_status THEN
     RETURN FALSE
  END IF

  LET t_aen_309_4[1].val_aen = mr_tela.val_adto_viagem

  CALL cdv2002_monta_aen4()

  CALL cap309_gera_informacoes_cap("S",
                                   l_aux_tip_desp,
                                   mr_tela.viagem,
                                   "V",
                                   mr_tela.sequencia_adto,
                                   TODAY,
                                   l_aux_cod_fornecedor,
                                   mr_tela.val_adto_viagem,
                                   "INCLUSAO VIA CDV2002",
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
     INITIALIZE mr_tela.ad_adiantamento,
                mr_tela.ap_adiantamento TO NULL
     CALL log0030_mensagem(l_msg,'exclamation')
     RETURN FALSE
  ELSE
     LET l_num_nf = mr_tela.viagem
     LET l_hora   = mr_tela.hora
     WHENEVER ERROR CONTINUE
        UPDATE audit_cap
           SET hora_manut     = l_hora
         WHERE cod_empresa    = mr_tela.empresa
           AND num_nf         = l_num_nf
           AND cod_fornecedor = l_aux_cod_fornecedor
           AND ies_manut      = 'I'
           AND ser_nf         = 'V'
           AND ssr_nf         = mr_tela.sequencia_adto
           AND num_seq        = 1
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('UPDATE','AUDIT_CAP')
        RETURN FALSE
     END IF

      LET mr_tela.ad_adiantamento = l_num_ad
      LET mr_tela.ap_adiantamento = l_num_ap
  END IF
  DISPLAY BY NAME mr_tela.ad_adiantamento
  DISPLAY BY NAME mr_tela.ap_adiantamento

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

  RETURN TRUE
END FUNCTION

#------------------------------#
 FUNCTION cdv2002_monta_aen4()
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

#-------------------------------------#
 FUNCTION cdv2002_carrega_fornecedor()
#-------------------------------------#

  DEFINE l_cod_funcio         LIKE cdv_fornecedor_fun.cod_funcio,
         l_aux_cod_fornecedor LIKE cdv_fornecedor_fun.cod_fornecedor

  LET l_cod_funcio = mr_tela.viajante

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_aux_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio # OS 536710 Bira
  WHENEVER ERROR STOP
  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_aux_cod_fornecedor TO NULL
  END IF

  RETURN l_aux_cod_fornecedor

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2002_carrega_cdv_par_ctr_viagem()
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

#---------------------------------#
 FUNCTION cdv2002_entrada_dados1()
#---------------------------------#
  IF NOT m_arg THEN
     CALL log006_exibe_teclas("01 02 07", p_versao)
     CURRENT WINDOW IS w_cdv2002

     LET int_flag = FALSE

     DISPLAY p_cod_empresa TO empresa

     INPUT BY NAME mr_tela.viagem WITHOUT DEFAULTS

       AFTER FIELD viagem
          IF mr_tela.viagem IS NULL OR
             mr_tela.viagem = " " THEN
          ELSE
             IF NOT cdv2002_verifica_viagem(mr_tela.viagem) THEN
                CALL log0030_mensagem(' Viagem não cadastrada. ','info')
                NEXT FIELD viagem
             END IF

             IF cdv2002_verifica_acerto_finalizado(mr_tela.viagem) THEN
                CALL log0030_mensagem('O acerto de despesas dessa viagem já foi finalizado. ','info')
                NEXT FIELD viagem
             END IF
          END IF

       AFTER INPUT
          IF NOT INT_FLAG THEN
             IF mr_tela.viagem IS NULL OR mr_tela.viagem = " " THEN
                CALL log0030_mensagem("Número da viagem não informado.",'info')
                NEXT FIELD viagem
             END IF
          END IF

       ON KEY (control-w, f1)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
          CALL cdv2002_help()
       ON KEY (control-z, f4)
          CALL cdv2002_popup()
      --# CALL fgl_dialog_setkeylabel('control-z',NULL)

     END INPUT

     CALL log006_exibe_teclas("01", p_versao)
     CURRENT WINDOW IS w_cdv2002

     IF INT_FLAG THEN
        LET int_flag = FALSE
        RETURN FALSE
     ELSE
        RETURN TRUE
     END IF
  ELSE
     LET mr_tela.viagem = ARG_VAL(2)
     RETURN TRUE
  END IF

END FUNCTION

#---------------------------------#
 FUNCTION cdv2002_entrada_dados2()
#---------------------------------#
  CALL log006_exibe_teclas('01 02 07', p_versao)
  CURRENT WINDOW IS w_cdv2002

  INITIALIZE mr_tela.val_adto_viagem,
             mr_tela.forma_adto_viagem,
             mr_tela.banco,
             mr_tela.agencia,
             mr_tela.cta_corrente,
             mr_tela.ad_adiantamento,
             mr_tela.ap_adiantamento,
             m_den_banco TO NULL

  DISPLAY m_den_banco TO den_banco

  LET mr_tela.forma_adto_viagem = "DN"
  DISPLAY BY NAME mr_tela.forma_adto_viagem

  LET INT_FLAG = 0

  INPUT BY NAME mr_tela.val_adto_viagem,
                mr_tela.forma_adto_viagem,
                mr_tela.banco,
                mr_tela.agencia,
                mr_tela.cta_corrente,
                mr_tela.ad_adiantamento,
                mr_tela.ap_adiantamento WITHOUT DEFAULTS

    AFTER FIELD val_adto_viagem
       IF mr_tela.val_adto_viagem IS NOT NULL OR
          mr_tela.val_adto_viagem <> " " THEN
          IF mr_tela.val_adto_viagem <= 0 THEN
             CALL log0030_mensagem("Valor deve ser positivo e maior que zero. ",'info')
             NEXT FIELD val_adto_viagem
          END IF
       END IF

    BEFORE FIELD forma_adto_viagem
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

    AFTER FIELD forma_adto_viagem
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD val_adto_viagem
       END IF
       IF mr_tela.forma_adto_viagem IS NULL OR
          mr_tela.forma_adto_viagem = " " THEN
       ELSE
          IF mr_tela.forma_adto_viagem = "DN" THEN
             INITIALIZE mr_tela.banco, mr_tela.agencia, mr_tela.cta_corrente TO NULL
             DISPLAY BY NAME mr_tela.banco, mr_tela.agencia, mr_tela.cta_corrente
             #GOTO final_input
             NEXT FIELD ap_adiantamento
          ELSE
             IF cdv2002_busca_valores(mr_tela.viajante) THEN
                #GOTO final_input
                NEXT FIELD ap_adiantamento
             END IF
          END IF
       END IF
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',"")
       ELSE
          DISPLAY "--------" AT 3,68
       END IF

    BEFORE FIELD banco
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',"Zoom")
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

    AFTER FIELD banco
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD forma_adto_viagem
       END IF
       IF mr_tela.banco IS NULL OR
          mr_tela.banco = " " THEN
       ELSE
          IF NOT cdv2002_verifica_banco(mr_tela.banco) THEN
             CALL log0030_mensagem("Banco não cadastrado. ",'info')
             NEXT FIELD banco
          END IF
          DISPLAY m_den_banco TO den_banco
      END IF
      IF g_ies_grafico THEN
         --# CALL fgl_dialog_setkeylabel('control-z',"")
      ELSE
         DISPLAY "--------" AT 3,68
      END IF

    AFTER FIELD agencia
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD banco
       END IF

    AFTER FIELD cta_corrente
       IF FGL_LASTKEY() = FGL_KEYVAL("up") OR
          FGL_LASTKEY() = FGL_KEYVAL("left") THEN
          NEXT FIELD agencia
       END IF

    AFTER INPUT
       #LABEL final_input:
       IF NOT INT_FLAG THEN
          IF mr_tela.val_adto_viagem IS NULL OR
             mr_tela.val_adto_viagem = " " THEN
             CALL log0030_mensagem("Valor do adiantamento não informado.",'info')
             NEXT FIELD val_adto_viagem
          ELSE
             IF mr_tela.val_adto_viagem <= 0 THEN
                CALL log0030_mensagem(" Valor deve ser positivo e maior que zero. ",'info')
                NEXT FIELD val_adto_viagem
             END IF
          END IF
          IF mr_tela.forma_adto_viagem IS NULL OR
             mr_tela.forma_adto_viagem = " " THEN
             CALL log0030_mensagem("Forma de adiantamento não informada.",'info')
             NEXT FIELD forma_adto_viagem
          ELSE
             IF mr_tela.forma_adto_viagem <> "DC" AND
                mr_tela.forma_adto_viagem <> "DN" THEN
                 CALL log0030_mensagem("Forma de adiantamento inválida.","exclamation")
                 NEXT FIELD forma_adto_viagem
             END IF
          END IF
          IF mr_tela.forma_adto_viagem = 'DC' THEN
             IF mr_tela.banco IS NULL OR mr_tela.banco = " " THEN
                CALL log0030_mensagem('Banco não informado.','info')
                NEXT FIELD banco
             END IF
             IF mr_tela.agencia IS NULL OR mr_tela.agencia = " " THEN
                CALL log0030_mensagem('Agência não informada.','info')
                NEXT FIELD agencia
             END IF
             IF mr_tela.cta_corrente IS NULL OR mr_tela.cta_corrente = " " THEN
                CALL log0030_mensagem('Conta corrente não informada.','info')
                NEXT FIELD cta_corrente
             END IF
          END IF
          IF NOT log0040_confirm(10,20,"Confirma solicitação?") THEN
             NEXT FIELD val_adto_viagem
          END IF
       END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
       CALL cdv2002_help()
    ON KEY (control-z, f4)
       CALL cdv2002_popup()
   --# CALL fgl_dialog_setkeylabel('control-z',NULL)

  END INPUT

  IF INT_FLAG THEN
     LET int_flag = FALSE
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#-----------------------#
 FUNCTION cdv2002_help()
#-----------------------#
  CASE
     WHEN INFIELD(viagem)            CALL showhelp(101)
     WHEN INFIELD(controle)          CALL showhelp(102)
     WHEN INFIELD(dat_hr_emis_solic) CALL showhelp(103)
     WHEN INFIELD(viajante)          CALL showhelp(104)
     WHEN INFIELD(finalidade_viagem) CALL showhelp(105)
     WHEN INFIELD(cliente_atendido)  CALL showhelp(106)
     WHEN INFIELD(cliente_fatur)     CALL showhelp(107)
     WHEN INFIELD(val_adto_viagem)   CALL showhelp(108)
     WHEN INFIELD(forma_adto_viagem) CALL showhelp(109)
     WHEN INFIELD(banco)             CALL showhelp(110)
     WHEN INFIELD(agencia)           CALL showhelp(111)
     WHEN INFIELD(cta_corrente)      CALL showhelp(112)
     WHEN INFIELD(ad_adiantamento)   CALL showhelp(113)
     WHEN INFIELD(ap_adiantamento)   CALL showhelp(114)
  END CASE

  CURRENT WINDOW IS w_cdv2002

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2002_carrega_viajante(l_usuario_logix)
#--------------------------------------------------#

  DEFINE l_usuario_logix LIKE cdv_info_viajante.usuario_logix,
         l_viajante LIKE cdv_solic_viag_781.viajante

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

#------------------------#
 FUNCTION cdv2002_popup()
#------------------------#

  DEFINE l_viagem            LIKE cdv_solic_viag_781.viagem,
         l_controle          LIKE cdv_solic_viag_781.controle,
         l_viajante          LIKE cdv_solic_viag_781.viajante,
         l_usuario_logix     LIKE cdv_info_viajante.usuario_logix,
         l_finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
         l_cliente_atendido  LIKE cdv_solic_viag_781.cliente_atendido,
         l_cliente_fatur     LIKE cdv_solic_viag_781.cliente_fatur,
         l_forma_adto_viagem LIKE cdv_solic_adto_781.forma_adto_viagem,
         l_banco             LIKE cdv_solic_adto_781.banco,
         l_viagem_pesq       LIKE cdv_acer_viag_781.viagem,
         l_controle_pesq     LIKE cdv_acer_viag_781.controle,
         l_first_time        SMALLINT,
         l_parametros        CHAR(3000)

  CASE

    WHEN infield(viagem)
         LET l_viagem = log0091_popup(8,15,"VIAGEM", "cdv_solic_viag_781", "viagem",
                                           "","S","")
         CURRENT WINDOW IS w_cdv2002
         IF l_viagem IS NOT NULL  THEN
            LET mr_tela.viagem = l_viagem
            DISPLAY BY NAME mr_tela.viagem
         END IF

    WHEN infield(controle)
        LET l_first_time = TRUE

        INITIALIZE sql_stmt TO NULL

        LET sql_stmt = 'SELECT UNIQUE controle, viagem FROM cdv_solic_viag_781'

        LET sql_stmt = sql_stmt clipped, " WHERE empresa = '", p_cod_empresa, "' "

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
        FOREACH cq_popup_ctrl INTO l_controle, l_viagem
        WHENEVER ERROR STOP

           IF l_controle IS NULL THEN
              CONTINUE FOREACH
           END IF

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("FOREACH","CQ_POPUP_CTRL")
              EXIT FOREACH
           END IF

           WHENEVER ERROR CONTINUE
           SELECT controle
             FROM cdv_acer_viag_781
            WHERE empresa = p_cod_empresa
              AND controle    = l_controle
           WHENEVER ERROR STOP

           IF sqlca.sqlcode = 0
           OR sqlca.sqlcode = -284 THEN
              CONTINUE FOREACH
           END IF

           IF l_first_time THEN
              LET l_first_time = FALSE
              LET l_parametros = l_viagem,' {', l_controle CLIPPED, '}'
           ELSE
              LET l_parametros = l_parametros CLIPPED, ',', l_viagem, ' {', l_controle CLIPPED, '}'
           END IF
        END FOREACH
        FREE cq_popup_ctrl

        LET l_viagem = log0830_list_box(10,6,l_parametros)

        IF l_viagem IS NOT NULL THEN
           LET l_controle_pesq = cdv2002_recupera_controle(l_viagem)
           LET mr_tela.controle = l_controle_pesq
           DISPLAY BY NAME mr_tela.controle
        END IF

    WHEN infield(viajante)
         LET l_usuario_logix = cap343_popup_usuario_cap("N")
         LET l_viajante = cdv2002_carrega_viajante(l_usuario_logix)
         CURRENT WINDOW IS w_cdv2002
         IF l_viajante IS NOT NULL THEN
            LET mr_tela.viajante = l_viajante
            DISPLAY BY NAME mr_tela.viajante
            LET m_den_viajante = cdv2002_busca_den_viajante(mr_tela.viajante)
            DISPLAY m_den_viajante TO den_viajante
         END IF

    WHEN infield(finalidade_viagem)
         LET l_finalidade_viagem = log009_popup(8,15,"FINALIDADE","cdv_finalidade_781","finalidade","des_finalidade",
                                                      "cdv2006","N","")
         CURRENT WINDOW IS w_cdv2002
         IF l_finalidade_viagem IS NOT NULL  THEN
            LET mr_tela.finalidade_viagem = l_finalidade_viagem
            DISPLAY BY NAME mr_tela.finalidade_viagem
            LET m_den_finalidade_viagem = cdv2002_busca_den_finalidade_viagem(mr_tela.finalidade_viagem)
            DISPLAY m_den_finalidade_viagem TO den_finalidade_viagem
         END IF

    WHEN infield(cliente_atendido)
         LET l_cliente_atendido = vdp372_popup_cliente()
         CURRENT WINDOW IS w_cdv2002
         IF l_cliente_atendido IS NOT NULL  THEN
            LET mr_tela.cliente_atendido = l_cliente_atendido
            DISPLAY BY NAME mr_tela.cliente_atendido
            LET m_den_cliente_atendido = cdv2002_busca_den_cliente(mr_tela.cliente_atendido)
            DISPLAY m_den_cliente_atendido TO den_cliente_atendido
         END IF

    WHEN infield(cliente_fatur)
         LET l_cliente_fatur = vdp372_popup_cliente()
         CURRENT WINDOW IS w_cdv2002
         IF l_cliente_fatur IS NOT NULL  THEN
            LET mr_tela.cliente_fatur = l_cliente_fatur
            DISPLAY BY NAME mr_tela.cliente_fatur
            LET m_den_cliente_fatur = cdv2002_busca_den_cliente(mr_tela.cliente_fatur)
            DISPLAY m_den_cliente_fatur TO den_cliente_fatur
         END IF

    WHEN infield(forma_adto_viagem)
         LET l_forma_adto_viagem = log0830_list_box(10,20,"DC {Depósito em conta corrente}, DN {Pago em dinheiro}" )
         CURRENT WINDOW IS w_cdv2002
         IF l_forma_adto_viagem IS NOT NULL  THEN
            LET mr_tela.forma_adto_viagem = l_forma_adto_viagem
            DISPLAY BY NAME mr_tela.forma_adto_viagem
         END IF

    WHEN infield(banco)
         LET l_banco = cap013_popup_bancos()
         CURRENT WINDOW IS w_cdv2002
         IF l_banco IS NOT NULL  THEN
            LET mr_tela.banco = l_banco
            DISPLAY BY NAME mr_tela.banco
            LET m_den_banco = cdv2002_busca_den_banco(mr_tela.banco)
            DISPLAY m_den_banco TO den_banco
         END IF

  END CASE

  CALL log006_exibe_teclas("01 02 03 07", p_versao)
  CURRENT WINDOW IS w_cdv2002

END FUNCTION

#------------------------------------------#
 FUNCTION cdv2002_verifica_viagem(l_viagem)
#------------------------------------------#

  DEFINE l_viagem LIKE cdv_solic_viag_781.viagem

  WHENEVER ERROR CONTINUE
  SELECT 1
    FROM cdv_solic_viag_781
   WHERE empresa = p_cod_empresa
     AND viagem = l_viagem
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv2002_verifica_acerto_finalizado(l_viagem)
#------------------------------------------------------#
  DEFINE l_viagem LIKE cdv_solic_viag_781.viagem

  WHENEVER ERROR CONTINUE
  SELECT 1
    FROM cdv_acer_viag_781
   WHERE empresa = p_cod_empresa
     AND viagem = l_viagem
     AND status_acer_viagem >= 3
  WHENEVER ERROR STOP

  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2002_busca_den_cliente(l_cliente)
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

#-----------------------------------------------------------------#
 FUNCTION cdv2002_busca_den_finalidade_viagem(l_finalidade_viagem)
#-----------------------------------------------------------------#

 DEFINE l_finalidade_viagem LIKE cdv_solic_viag_781.finalidade_viagem,
        l_den_finalidade_viagem LIKE cdv_finalidade_781.des_finalidade

 WHENEVER ERROR CONTINUE
  SELECT des_finalidade
    INTO l_den_finalidade_viagem
    FROM cdv_finalidade_781
   WHERE finalidade = l_finalidade_viagem
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_den_finalidade_viagem TO NULL
 END IF

 RETURN l_den_finalidade_viagem

END FUNCTION

#----------------------------------------#
 FUNCTION cdv2002_verifica_banco(l_banco)
#----------------------------------------#

  DEFINE l_banco LIKE bancos.cod_banco

  LET m_den_banco = cdv2002_busca_den_banco(l_banco)

  IF m_den_banco IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION
#-----------------------------------------#
 FUNCTION cdv2002_busca_den_banco(l_banco)
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

#-----------------------------#
 FUNCTION cdv2002_busca_num_ap()
#-----------------------------#
 DEFINE l_ap        LIKE ad_ap.num_ap

 INITIALIZE l_ap TO NULL

 WHENEVER ERROR CONTINUE
 DECLARE cq_num_ad_ap CURSOR FOR
 SELECT num_ap
    FROM ad_ap
   WHERE cod_empresa = p_cod_empresa
     AND num_ad      = mr_tela.ad_adiantamento
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
 FREE cq_num_ad_ap

 RETURN l_ap
 END FUNCTION

#-----------------------------------------------------------------------------#
 FUNCTION cdv2002_gera_aprovacao_eletronica(l_num_viagem, l_num_ad, l_num_ap)
#-----------------------------------------------------------------------------#
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

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_cdv2002

  RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION cdv2002_cria_temp()
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
 FUNCTION cdv2002_monta_aen()
#---------------------------#
 DEFINE l_empresa_atendida LIKE cdv_solic_viag_781.empresa_atendida,
        l_filial_atendida  LIKE cdv_solic_viag_781.filial_atendida,
        l_nivel            LIKE item.cod_seg_merc,
        l_empresa          LIKE empresa.cod_empresa,
        l_filial           LIKE empresa.cod_empresa

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

 WHENEVER ERROR CONTINUE
 SELECT empresa_atendida, filial_atendida
   INTO l_empresa, l_filial
   FROM cdv_solic_viag_781
  WHERE empresa = p_cod_empresa
    AND viagem  = mr_tela.viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_empresa = p_cod_empresa
    LET l_filial  = p_cod_empresa
 END IF

 CALL log2250_busca_parametro(l_empresa,'empresa_atendida_pamcary')
    RETURNING l_empresa_atendida, p_status
 IF NOT p_status OR l_empresa_atendida IS NULL THEN
    CALL log0030_mensagem('Parâmetro da empresa atendida não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 #END IF
 #
 #IF cdv0805_verifica_char_empresa(l_filial_atendida) THEN
 CALL log2250_busca_parametro(l_filial,'filial_atendida_pamcary')
    RETURNING l_filial_atendida, p_status
 IF NOT p_status OR l_filial_atendida IS NULL THEN
    CALL log0030_mensagem('Parâmetro da filial atendida não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 #END IF

 LET t_aen_309_4[1].cod_lin_prod  = l_empresa_atendida USING "&&"
 LET t_aen_309_4[1].cod_lin_recei = l_filial_atendida  USING "&&"

 CALL log2250_busca_parametro(p_cod_empresa,'segmto_mercado_pamcary')
    RETURNING l_nivel, p_status
 IF NOT p_status OR l_nivel IS NULL THEN
    CALL log0030_mensagem('Segmento de mercado (AEN) não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 LET t_aen_309_4[1].cod_seg_merc = l_nivel USING "&&"

 CALL log2250_busca_parametro(p_cod_empresa,'classe_uso_pamcary')
    RETURNING l_nivel, p_status
 IF NOT p_status OR l_nivel IS NULL THEN
    CALL log0030_mensagem('Classe de uso (AEN) não cadastrado.','exclamation')
    RETURN TRUE
 END IF

 LET t_aen_309_4[1].cod_cla_uso = l_nivel USING "&&"

 RETURN FALSE
 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2002_busca_valores(l_viajante)
#-----------------------------------------#
 DEFINE l_viajante    LIKE cdv_info_viajante.matricula,
        l_cod_funcio  LIKE cdv_fornecedor_fun.cod_funcio,
        l_fornecedor  LIKE fornecedor.cod_fornecedor

 LET l_cod_funcio = l_viajante

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
 LET m_den_banco = cdv2002_busca_den_banco(mr_tela.banco)
 DISPLAY m_den_banco TO den_banco

 RETURN TRUE
 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2002_recupera_controle(l_viagem)
#------------------------------------------#
  DEFINE l_controle      LIKE cdv_acer_viag_781.controle,
         l_viagem        LIKE cdv_acer_viag_781.viagem

  INITIALIZE l_controle TO NULL

  WHENEVER ERROR CONTINUE
   SELECT controle
     INTO l_controle
     FROM cdv_solic_viag_781
    WHERE empresa = p_cod_empresa
      AND viagem  = l_viagem
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','CDV_SOLIC_VIAG_781')
  END IF

  RETURN l_controle

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2002_alimenta_consulta()
#-----------------------------------#

 INITIALIZE mr_consulta.* TO NULL
 LET mr_consulta.viagem               = mr_tela.viagem
 LET mr_consulta.controle             = mr_tela.controle
 LET mr_consulta.dat_hr_emis_solic    = mr_tela.dat_adto_viagem
 LET mr_consulta.viajante             = mr_tela.viajante
 LET mr_consulta.finalidade_viagem    = mr_tela.finalidade_viagem
 LET mr_consulta.cliente_atendido     = mr_tela.cliente_atendido
 LET mr_consulta.cliente_fatur        = mr_tela.cliente_fatur

 END FUNCTION


#------------------------#
 FUNCTION cdv2002_lista()
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
           START REPORT cdv2002_relat TO PIPE p_nom_arquivo
        ELSE
           CALL log150_procura_caminho("LST") RETURNING m_caminho
           LET m_caminho = m_caminho CLIPPED, "cdv2002.tmp"
           START REPORT cdv2002_relat TO m_caminho
        END IF
     ELSE
        START REPORT cdv2002_relat TO p_nom_arquivo
     END IF

     MESSAGE "Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

     INITIALIZE m_den_empresa TO NULL

     LET m_den_empresa = cdv2002_busca_den_empresa(p_cod_empresa)

     LET l_den_viajanter          = m_den_viajante
     LET l_den_finalidade_viagemr = m_den_finalidade_viagem
     LET l_den_cc_viajanter       = m_den_cc_viajante
     LET l_den_cc_debitarr        = m_den_cc_debitar
     LET l_den_cliente_atendidor  = m_den_cliente_atendido
     LET l_den_cliente_fatur      = m_den_cliente_fatur
     LET l_den_bancor             = m_den_banco

     #LET m_qtd_solic        = 0
     #LET m_qtd_solic_impres = 0

     #WHENEVER ERROR CONTINUE
     #SELECT COUNT(*)
     #  INTO m_qtd_solic
     #  FROM cdv_solic_viag_781
     # WHERE empresa = p_cod_empresa
     #WHENEVER ERROR STOP

     #IF SQLCA.sqlcode <> 0 THEN
     #   LET m_qtd_solic = 0
     #END IF

     #IF m_qtd_solic IS NULL THEN
     #   LET m_qtd_solic = 0
     #END IF

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
     #IF mr_consulta.dat_hr_emis_solic IS NOT NULL
     #AND mr_consulta.dat_hr_emis_solic > '31/12/1900' THEN
     #   LET l_sql_stmt = l_sql_stmt CLIPPED,
     #                    " AND DATE(dat_hr_emis_solic) =  '", DATE(mr_consulta.dat_hr_emis_solic), "' "
     #END IF
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
                       CALL cdv2002_busca_num_ap_por_ad(lr_relat.ad_adiantamento)
                            RETURNING mr_tela.ap_adiantamento
                       LET mr_tela.ad_adiantamento = lr_relat.ad_adiantamento
                       LET l_num_ad = mr_tela.ad_adiantamento
                       LET l_num_ap = mr_tela.ap_adiantamento
                       LET lr_relat.ad_adiantamento = l_num_ad
                       LET lr_relat.ap_adiantamento = l_num_ap
                       LET mr_tela.ad_adiantamento  = l_num_ad
                       LET mr_tela.ap_adiantamento  = l_num_ap
                    ELSE
                       LET lr_relat.ies_solic_adto  = "N"
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

                    LET m_den_viajante = cdv2002_busca_den_viajante(lr_relat.viajante)
                    LET m_den_finalidade_viagem = cdv2002_busca_den_finalidade_viagem(lr_relat.finalidade_viagem)
                    LET m_den_cc_viajante = cdv2002_busca_den_cc(lr_relat.cc_viajante)
                    LET m_den_cc_debitar = cdv2002_busca_den_cc(lr_relat.cc_debitar)
                    LET m_den_cliente_atendido = cdv2002_busca_den_cliente(lr_relat.cliente_atendido)
                    LET m_den_cliente_fatur = cdv2002_busca_den_cliente(lr_relat.cliente_fatur)
                    LET m_den_banco = cdv2002_busca_den_banco(lr_relat.banco)
                    LET m_den_empresa_atendida = cdv2002_busca_den_empresa(lr_relat.empresa_atendida)
                    LET m_den_filial_atendida = cdv2002_busca_den_empresa(lr_relat.filial_atendida)
                    OUTPUT TO REPORT cdv2002_relat(lr_relat.*)
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

                 LET m_den_viajante = cdv2002_busca_den_viajante(lr_relat.viajante)
                 LET m_den_finalidade_viagem = cdv2002_busca_den_finalidade_viagem(lr_relat.finalidade_viagem)
                 LET m_den_cc_viajante = cdv2002_busca_den_cc(lr_relat.cc_viajante)
                 LET m_den_cc_debitar = cdv2002_busca_den_cc(lr_relat.cc_debitar)
                 LET m_den_cliente_atendido = cdv2002_busca_den_cliente(lr_relat.cliente_atendido)
                 LET m_den_cliente_fatur = cdv2002_busca_den_cliente(lr_relat.cliente_fatur)
                 LET m_den_banco = cdv2002_busca_den_banco(lr_relat.banco)
                 LET m_den_empresa_atendida = cdv2002_busca_den_empresa(lr_relat.empresa_atendida)
                 LET m_den_filial_atendida = cdv2002_busca_den_empresa(lr_relat.filial_atendida)
                 OUTPUT TO REPORT cdv2002_relat(lr_relat.*)
              END IF
           END IF
        END FOREACH
     END IF

     FREE cq_solic_viag_781
     FREE cq_solic_adto_781

     DISPLAY l_den_viajanter TO den_viajante
     DISPLAY l_den_finalidade_viagemr TO den_finalidade_viagem
     DISPLAY l_den_cliente_atendidor TO den_cliente_atendido
     DISPLAY l_den_cliente_fatur TO den_cliente_fatur

     LET m_den_viajante = l_den_viajanter
     LET m_den_finalidade_viagem = l_den_finalidade_viagemr
     LET m_den_cc_viajante = l_den_cc_viajanter
     LET m_den_cc_debitar = l_den_cc_debitarr
     LET m_den_cliente_atendido = l_den_cliente_atendidor
     LET m_den_cliente_fatur = l_den_cliente_fatur
     LET m_den_banco =l_den_bancor

     FINISH REPORT cdv2002_relat

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

#-----------------------------#
 REPORT cdv2002_relat(lr_relat)
#-----------------------------#

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
      PRINT COLUMN 001, "cdv2002",
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
      PRINT COLUMN 057, "TOTAL: ",l_total USING "############&.&&"
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

#---------------------------------------------------------------#
 FUNCTION cdv2002_busca_den_viajante(l_viajante)
#---------------------------------------------------------------#
  DEFINE l_viajante        LIKE cdv_solic_viag_781.viajante,
         l_den_funcionario LIKE funcionario.nom_funcionario,
         l_cod_funcio     LIKE cdv_fornecedor_fun.cod_funcio,
         l_cod_fornecedor LIKE fornecedor.cod_fornecedor

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
       INTO l_den_funcionario
       FROM fornecedor
      WHERE cod_fornecedor = l_cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        INITIALIZE l_den_funcionario TO NULL
     END IF
  END IF

 RETURN l_den_funcionario

END FUNCTION

#-----------------------------------#
 FUNCTION cdv2002_busca_den_cc(l_cc)
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

#---------------------------------------------#
 FUNCTION cdv2002_busca_den_empresa(l_empresa)
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


#---------------------------------#
FUNCTION cdv2002_busca_num_ap_por_ad(l_ad)
#---------------------------------#
 DEFINE l_ad        LIKE ad_ap.num_ad,
        l_ap        LIKE ad_ap.num_ap

 WHENEVER ERROR CONTINUE
 DECLARE cq_num_ad_ap2 CURSOR FOR
 SELECT num_ap
   FROM ad_ap
  WHERE cod_empresa = p_cod_empresa
    AND num_ad      = l_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_NUM_AD_AP2")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_num_ad_ap2 INTO l_ap
 WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       EXIT FOREACH
    END IF

    EXIT FOREACH
 END FOREACH

 WHENEVER ERROR CONTINUE
 FREE cq_num_ad_ap2
 WHENEVER ERROR STOP

 RETURN l_ap
 END FUNCTION



#----------------------------#
FUNCTION cdv2002_busca_hora()
#----------------------------#

 DEFINE l_aux_cod_fornecedor LIKE audit_cap.cod_fornecedor
 DEFINE l_hora               CHAR(08),
        l_num_nf             LIKE audit_cap.num_nf


 LET l_aux_cod_fornecedor = cdv2002_carrega_fornecedor()
 LET l_num_nf = mr_tela.viagem

 WHENEVER ERROR CONTINUE
    SELECT MAX(hora_manut)
      INTO l_hora
      FROM audit_cap
     WHERE cod_empresa = mr_tela.empresa
       AND num_nf = l_num_nf
       AND cod_fornecedor = l_aux_cod_fornecedor
       AND ies_manut = 'I'
       AND ser_nf = 'V'
       AND ssr_nf = mr_tela.sequencia_adto
       AND num_seq = 1
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql('SELECT','AUDIT_CAP')
 END IF

 LET mr_tela.hora = l_hora

 END FUNCTION


#-------------------------------#
 FUNCTION cdv2002_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2002.4gl $|$Revision: 11 $|$Date: 23/12/11 10:50 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION