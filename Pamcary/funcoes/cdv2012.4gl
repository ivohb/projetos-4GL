###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                     #
# PROGRAMA: CDV2012   (FUNCAO)                                      #
# OBJETIVO: RELATORIO ACERTO DESPESAS VIAGEM                        #
# AUTOR...: FABIANO PEDRO ESPINDOLA                                 #
# DATA....: 25.07.2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
         g_ies_ambiente       LIKE w_log0250.ies_ambiente,
         p_user               LIKE usuario.nom_usuario,
         p_ies_impressao      CHAR(01),
       	 p_status             SMALLINT,
         p_nom_arquivo        CHAR(100),
         g_ies_grafico        SMALLINT,
         g_caminho            CHAR(80)

  DEFINE g_nao_exclui_par    SMALLINT

END GLOBALS

#MODULARES
    DEFINE m_versao_funcao        CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
    DEFINE m_den_empresa          LIKE empresa.den_empresa,
           m_last_row             SMALLINT,
           m_comando              CHAR(200),
           m_comando2             CHAR(200),
           m_caminho              CHAR(150),
           sql_stmt               CHAR(1000),
           m_tipo_relatorio       CHAR(09),
           m_impr_empresa_rhu     CHAR(01),
	          m_tip_impressao        CHAR(01)

  DEFINE m_var_ambiente         CHAR(030),
         m_cidade_origem        CHAR(15),
         m_cidade_destino       CHAR(15),
         m_prim_percurso        SMALLINT,
         m_percurso_avulsa      LIKE cdv_desp_passagem.percurso

  DEFINE m_tipo_impressao       CHAR(02),
         m_houve_erro           SMALLINT,
         m_houve_adto           SMALLINT,
         m_houve_desp_urb       SMALLINT,
         m_houve_desp_km        SMALLINT

#END MODULARES

#----------------------------------#
 FUNCTION cdv2012_controle(lr_solic)
#----------------------------------#
  DEFINE lr_solic RECORD
         viagem               LIKE cdv_acer_viag_781.viagem,
         controle             LIKE cdv_acer_viag_781.controle,
         viajante             LIKE cdv_acer_viag_781.viajante,
         finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
         cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
         cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
         cliente_atendido     LIKE cdv_acer_viag_781.cliente_debitar,
         cliente_fatur        LIKE cdv_acer_viag_781.cliente_debitar,
         empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
         filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
         trajeto_principal    LIKE cdv_acer_viag_781.trajeto_principal,
         dat_hor_partida      DATETIME YEAR TO SECOND,
         dat_hor_retorno      DATETIME YEAR TO SECOND,
         motivo_viagem        LIKE cdv_acer_viag_781.motivo_viagem,
         tip_cliente          LIKE cdv_controle_781.tip_cliente #OS 487356
  END RECORD

  INITIALIZE m_tipo_impressao TO NULL
  LET m_versao_funcao = "CDV2012-05.10.07p" #Favor nao alterar esta linha (SUPORTE)
  LET m_caminho = log140_procura_caminho("cdv2012.iem")

  OPTIONS
    PREVIOUS KEY  control-b,
    NEXT     KEY  control-f,
    HELP     FILE m_caminho

  CALL log2250_busca_parametro(p_cod_empresa, "impr_via_cli_caixa")
     RETURNING m_tipo_impressao, p_status

  IF p_status = FALSE OR
     m_tipo_impressao IS NULL OR
     m_tipo_impressao = " " THEN
     INITIALIZE m_tipo_impressao TO NULL
  END IF

  IF m_tipo_impressao = 1 THEN
     LET m_tipo_impressao = "CA"
  END IF

  IF m_tipo_impressao = 2 THEN
     LET m_tipo_impressao = "CL"
  END IF

  IF m_tipo_impressao = 3 THEN
     LET m_tipo_impressao = "AM"
  END IF

  IF m_tipo_impressao IS NOT NULL
  AND m_tipo_impressao <> " " THEN
     CALL cdv2012_lista(lr_solic.*)
     IF m_houve_erro = TRUE THEN
        ERROR ""
        RETURN FALSE
     ELSE
        IF NOT g_ies_grafico THEN
           SLEEP 3
        END IF
        ERROR ""
        RETURN TRUE
     END IF
  END IF

  LET m_caminho = log1300_procura_caminho('cdv2012','cdv20121')
  CALL log006_exibe_teclas("01", m_versao_funcao)
  OPEN WINDOW w_cdv20121 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  CURRENT WINDOW IS w_cdv20121
  DISPLAY p_cod_empresa TO empresa

  LET m_tipo_impressao = "CA"
  LET m_houve_erro     = FALSE
  LET g_nao_exclui_par = TRUE

  LET int_flag = 0
  CALL log006_exibe_teclas("01 02 07", m_versao_funcao)
  CURRENT WINDOW IS w_cdv20121

  INPUT m_tipo_impressao WITHOUT DEFAULTS FROM tipo_impressao

     AFTER FIELD tipo_impressao
        IF m_tipo_impressao IS NULL
        OR m_tipo_impressao = " " THEN
           CALL log0030_mensagem('Tipo de impressão não informado.','exclamation')
           NEXT FIELD tipo_impressao
        END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2012_help()

  END INPUT

  IF INT_FLAG = 0 THEN
     CALL cdv2012_lista(lr_solic.*)
     IF m_houve_erro = TRUE THEN
        ERROR ""
        CLOSE WINDOW w_cdv20121
        RETURN FALSE
     ELSE
        IF NOT g_ies_grafico THEN
           SLEEP 3
        END IF
        ERROR ""
        CLOSE WINDOW w_cdv20121
        RETURN TRUE
     END IF
  ELSE
     ERROR ""
     CLOSE WINDOW w_cdv20121
     RETURN FALSE
  END IF

END FUNCTION

#---------------------------------#
 FUNCTION cdv2012_lista(lr_solic)
#---------------------------------#
 DEFINE lr_solic RECORD
                 viagem               LIKE cdv_acer_viag_781.viagem,
                 controle             LIKE cdv_acer_viag_781.controle,
                 viajante             LIKE cdv_acer_viag_781.viajante,
                 finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
                 cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
                 cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
                 cliente_atendido     LIKE cdv_acer_viag_781.cliente_debitar,
                 cliente_fatur        LIKE cdv_acer_viag_781.cliente_debitar,
                 empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
                 filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
                 trajeto_principal    LIKE cdv_acer_viag_781.trajeto_principal,
                 dat_hor_partida      DATETIME YEAR TO SECOND,
                 dat_hor_retorno      DATETIME YEAR TO SECOND,
                 motivo_viagem        LIKE cdv_acer_viag_781.motivo_viagem,
                 tip_cliente          LIKE cdv_controle_781.tip_cliente #OS 487356
                 END RECORD

 DEFINE sql_stmt       CHAR(3000),
        where_clause   CHAR(2000),
        l_nom_arquivo  CHAR(500),
        l_nom_arquivo2 CHAR(500),
        l_caminho      CHAR(80),
        l_msg          CHAR(150)

 INITIALIZE l_nom_arquivo,
            l_nom_arquivo2,
            l_caminho TO NULL

 LET m_houve_adto      = false
 LET m_houve_desp_urb  = false
 LET m_houve_desp_km   = false

   IF log0280_saida_relat(16,35) IS NOT NULL THEN
      CASE m_tipo_impressao
      WHEN 'CA'
         IF g_ies_ambiente = "W" THEN
            IF p_ies_impressao = "S" THEN
                 CALL log150_procura_caminho("LST") RETURNING g_caminho
                 LET g_caminho = g_caminho CLIPPED, "cdv2012.tmp"
                 START REPORT cdv2012_relat_ca TO g_caminho
             ELSE
                 START REPORT cdv2012_relat_ca TO p_nom_arquivo
             END IF
         ELSE
            IF p_ies_impressao = "S" THEN
               START REPORT cdv2012_relat_ca TO PIPE p_nom_arquivo
            ELSE
               START REPORT cdv2012_relat_ca TO p_nom_arquivo
            END IF
         END IF

      WHEN 'CL'
        IF g_ies_ambiente = "W" THEN
           IF p_ies_impressao = "S" THEN
               CALL log150_procura_caminho("LST") RETURNING g_caminho
               LET g_caminho = g_caminho CLIPPED, "cdv2012.tmp"
               START REPORT cdv2012_relat_cl TO g_caminho
           ELSE
               START REPORT cdv2012_relat_cl TO p_nom_arquivo
           END IF
        ELSE
           IF p_ies_impressao = "S" THEN
              START REPORT cdv2012_relat_cl TO PIPE p_nom_arquivo
           ELSE
              START REPORT cdv2012_relat_cl TO p_nom_arquivo
           END IF
        END IF

      WHEN 'AM'
         IF g_ies_ambiente = "W" THEN
            IF p_ies_impressao = "S" THEN
                CALL log150_procura_caminho("LST") RETURNING g_caminho
                LET l_caminho = g_caminho CLIPPED, "cdv2012_cl.tmp"
                LET g_caminho = g_caminho CLIPPED, "cdv2012_ca.tmp"
                START REPORT cdv2012_relat_ca TO g_caminho
                START REPORT cdv2012_relat_cl TO l_caminho
            ELSE
                LET l_nom_arquivo = p_nom_arquivo CLIPPED
                LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_1"
                LET l_nom_arquivo = l_nom_arquivo CLIPPED, "_2"
                START REPORT cdv2012_relat_ca TO p_nom_arquivo
                START REPORT cdv2012_relat_cl TO l_nom_arquivo
            END IF
         ELSE
            IF p_ies_impressao = "S" THEN
               LET l_nom_arquivo = p_nom_arquivo CLIPPED
               LET p_nom_arquivo = p_nom_arquivo CLIPPED #, "_1"
               LET l_nom_arquivo = l_nom_arquivo CLIPPED #, "_2"
               START REPORT cdv2012_relat_ca TO PIPE l_nom_arquivo
               START REPORT cdv2012_relat_cl TO PIPE l_nom_arquivo
            ELSE
               LET l_nom_arquivo = p_nom_arquivo CLIPPED
               LET p_nom_arquivo = p_nom_arquivo CLIPPED, "_1"
               LET l_nom_arquivo = l_nom_arquivo CLIPPED, "_2"
               START REPORT cdv2012_relat_ca TO p_nom_arquivo
               START REPORT cdv2012_relat_cl TO l_nom_arquivo
            END IF
         END IF
      END CASE


        ERROR "Processando a extração do relatório... "

        WHENEVER ERROR CONTINUE
        SELECT den_empresa
          INTO m_den_empresa
          FROM empresa
         WHERE empresa.cod_empresa = p_cod_empresa
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           INITIALIZE m_den_empresa TO NULL
        END IF

        CASE m_tipo_impressao
           WHEN 'CA'
              LET m_last_row = FALSE
              OUTPUT TO REPORT cdv2012_relat_ca(lr_solic.*)
           WHEN 'CL'
              LET m_last_row = FALSE
              OUTPUT TO REPORT cdv2012_relat_cl(lr_solic.*)
           WHEN 'AM'
              LET m_last_row = FALSE
              OUTPUT TO REPORT cdv2012_relat_ca(lr_solic.*)

              LET m_last_row = FALSE
              OUTPUT TO REPORT cdv2012_relat_cl(lr_solic.*)
        END CASE

        CASE m_tipo_impressao

           WHEN 'CA'
              FINISH REPORT cdv2012_relat_ca
              IF  g_ies_ambiente = "W"
              AND p_ies_impressao = "S"  THEN
                 LET m_comando = "lpdos.bat ",
                     g_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
                 RUN m_comando
              END IF
              IF p_ies_impressao = "S" THEN
                 LET l_msg = "Relatório impresso na impressora. ", p_nom_arquivo CLIPPED
                 CALL log0030_mensagem(l_msg,"info")
              ELSE
                 LET l_msg = "Relatório gravado no arquivo ", p_nom_arquivo CLIPPED
                 CALL log0030_mensagem(l_msg,"info")
              END IF

           WHEN 'CL'
              FINISH REPORT cdv2012_relat_cl
              IF  g_ies_ambiente = "W"
              AND p_ies_impressao = "S"  THEN
                 LET m_comando = "lpdos.bat ",
                     g_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
                 RUN m_comando
              END IF
              IF p_ies_impressao = "S" THEN
                 LET l_msg = "Relatório impresso na impressora. ", p_nom_arquivo CLIPPED
                 CALL log0030_mensagem(l_msg,"info")
              ELSE
                 LET l_msg = "Relatório gravado no arquivo ", p_nom_arquivo CLIPPED
                 CALL log0030_mensagem(l_msg,"info")
              END IF

           WHEN 'AM'
              FINISH REPORT cdv2012_relat_ca
              FINISH REPORT cdv2012_relat_cl
              IF  g_ies_ambiente = "W"
                 AND p_ies_impressao = "S"  THEN
                 LET m_comando = "lpdos.bat ",
                     g_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
                 RUN m_comando
                 LET m_comando2 = "lpdos.bat ",
                     l_caminho CLIPPED, " ", l_nom_arquivo CLIPPED
                 RUN m_comando2
              END IF
              IF p_ies_impressao = "S" THEN
                 LET l_msg = "Relatórios impressos na impressora. ", p_nom_arquivo CLIPPED
                 CALL log0030_mensagem(l_msg,"info")
              ELSE
                 LET l_msg = "Relatórios gravados com sucesso."
                 CALL log0030_mensagem(l_msg,"info")
              END IF
        END CASE
   ELSE
      CALL log0030_mensagem('Impressão cancelada.','info')
   END IF

END FUNCTION

#--------------------------------#
 REPORT cdv2012_relat_ca(lr_solic)
#--------------------------------#

   DEFINE lr_solic            RECORD
                                 viagem               LIKE cdv_acer_viag_781.viagem,
                                 controle             LIKE cdv_acer_viag_781.controle,
                                 viajante             LIKE cdv_acer_viag_781.viajante,
                                 finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
                                 cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
                                 cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
                                 cliente_atendido     LIKE cdv_acer_viag_781.cliente_debitar,
                                 cliente_fatur        LIKE cdv_acer_viag_781.cliente_debitar,
                                 empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
                                 filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
                                 trajeto_principal    LIKE cdv_acer_viag_781.trajeto_principal,
                                 dat_hor_partida      DATETIME YEAR TO SECOND,
                                 dat_hor_retorno      DATETIME YEAR TO SECOND,
                                 motivo_viagem        LIKE cdv_acer_viag_781.motivo_viagem,
                                 tip_cliente          LIKE cdv_controle_781.tip_cliente #OS 487356
                              END RECORD


 DEFINE lr_cdv_acer_viag_781  RECORD LIKE cdv_acer_viag_781.*,
        lr_cdv_despesa_km_781 RECORD LIKE cdv_despesa_km_781.*,
        lr_cdv_desp_terc_781  RECORD LIKE cdv_desp_terc_781.*,
        lr_cdv_solic_adto_781 RECORD LIKE cdv_solic_adto_781.*,
        lr_cdv_desp_urb_781   RECORD LIKE cdv_desp_urb_781.*,
        lr_cdv_apont_hor_781  RECORD LIKE cdv_apont_hor_781.*

 DEFINE l_trajeto1            CHAR(55),
        l_trajeto2            CHAR(55),
        l_trajeto3            CHAR(55),
        l_trajeto4            CHAR(55),
        l_motivo1             CHAR(55),
        l_motivo2             CHAR(55),
        l_motivo3             CHAR(55),
        l_motivo4             CHAR(55),
        l_cont                INTEGER,
        l_data                DATE,
        l_num_ap              LIKE ad_ap.num_ap,
        l_num_ad              LIKE ad_ap.num_ad

 DEFINE l_qtd_adiant          INTEGER,
        l_qtd_desp_urb        INTEGER,
        l_qtd_desp_km         INTEGER,
        l_qtd_desp_km2        INTEGER,
        l_qtd_desp_terc       INTEGER,
        l_qtd_apont           INTEGER,
        l_tip_cliente         LIKE cdv_controle_781.tip_cliente #OS 487356

 DEFINE l_nom_viajante        LIKE usuarios.nom_funcionario,
        l_nom_cc_viajante     LIKE cad_cc.nom_cent_cust,
        l_nom_cc_deb          LIKE cad_cc.nom_cent_cust,
        l_nom_cliente_aten    CHAR(36),
        l_nom_cliente_fat     CHAR(36),
        l_den_empresa_aten    LIKE empresa.den_empresa,
        l_den_empresa_fatur   LIKE empresa.den_empresa,
        l_des_finalidade      LIKE cdv_finalidade_781.des_finalidade,
        l_despesa             LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
        l_tot_adiant          LIKE cdv_solic_adto_781.val_adto_viagem,
        l_tot_desp_urb        LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_tot_desp_km         like cdv_despesa_km_781.val_km,
        l_tot_desp_km2        like cdv_despesa_km_781.val_km,
        l_tot_desp_terc       LIKE cdv_desp_terc_781.val_desp_terceiro,
        l_atividade           LIKE cdv_ativ_781.des_ativ,
        l_motivo              LIKE cdv_motivo_hor_781.des_motivo,
        l_des_motivo          LIKE cdv_motivo_hor_781.des_motivo,
        l_saldo               DECIMAL(17,2),
        l_des_status          CHAR(50)

 DEFINE l_status_acer_viagem LIKE cdv_acer_viag_781.status_acer_viagem,
        l_viagem_rec         like cdv_dev_transf_781.viagem_receb,
        l_controle_rec       like cdv_dev_transf_781.controle_receb

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE   LENGTH 66

  FORMAT
     PAGE HEADER
        PRINT COLUMN 001, log5211_retorna_configuracao(PAGENO,66,118) CLIPPED;
        PRINT COLUMN 001, m_den_empresa CLIPPED

        PRINT COLUMN 001, "CDV2012 - DETALHADO",
              COLUMN 107, "FL. ",PAGENO USING "####"

        PRINT COLUMN 075, " EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
                          " AS ", TIME, " HRS."
        PRINT COLUMN 093, "PELO USUARIO: ", UPSHIFT(p_user),
                          log5211_negrito("ATIVA") CLIPPED

        PRINT COLUMN 041, "RELATORIO DE DESPESA DE VIAGEM"

        PRINT COLUMN 001, log5211_negrito("DESATIVA") CLIPPED

    ON EVERY ROW
        WHENEVER ERROR CONTINUE
        SELECT DATE(dat_hr_emis_relat), ad_acerto_conta
          INTO l_data, l_num_ad
          FROM cdv_acer_viag_781
         WHERE empresa = p_cod_empresa
           AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           INITIALIZE l_data, l_num_ad TO NULL
        END IF

       #OS 487356
       WHENEVER ERROR CONTINUE
        SELECT tip_cliente
         INTO l_tip_cliente
         FROM cdv_controle_781
        WHERE controle   = lr_solic.controle
          AND sistema    = lr_solic.finalidade_viagem
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
         INITIALIZE l_tip_cliente TO NULL
       END IF
        #OS 487356
        LET l_tip_cliente  = lr_solic.tip_cliente
        PRINT COLUMN 003, "TIPO CLIENTE: ", l_tip_cliente CLIPPED
        #---

        PRINT COLUMN 012, "VIAGEM: ",   lr_solic.viagem   USING "<<<<<<<<<",
              COLUMN 030, "CONTROLE: ", lr_solic.controle USING "<<<<<<<<<<<<<<<<<<<<",
              COLUMN 065, "DATA: ", l_data

        LET l_nom_viajante = cdv2012_busca_viajante(lr_solic.viajante)
        PRINT COLUMN 010, "VIAJANTE: ", l_nom_viajante CLIPPED

        LET l_nom_cc_viajante = cdv2012_busca_cc(lr_solic.cc_viajante)
        LET l_nom_cc_deb      = cdv2012_busca_cc(lr_solic.cc_debitar)
        PRINT COLUMN 003, "C.C. (viajante): ", lr_solic.cc_viajante USING "####&", " - ",
                                               l_nom_cc_viajante CLIPPED,
              COLUMN 096, "DATA/HORA PARTIDA"
        PRINT COLUMN 002, "C.C. (a debitar): ", lr_solic.cc_debitar USING "####&", " - ",
                          l_nom_cc_deb CLIPPED,
              COLUMN 096, "-------------------"
        PRINT COLUMN 096, lr_solic.dat_hor_partida

        LET l_nom_cliente_aten = cdv2012_busca_nom_cliente(lr_solic.cliente_atendido)
        PRINT COLUMN 002, "CLIENTE ATENDIDO: ", lr_solic.cliente_atendido CLIPPED,
              COLUMN 022, " - ", l_nom_cliente_aten CLIPPED

        LET l_nom_cliente_fat  = cdv2012_busca_nom_cliente(lr_solic.cliente_fatur)
        PRINT COLUMN 003, "CLIENTE FATURAR: ", lr_solic.cliente_fatur CLIPPED,
              COLUMN 022, " - ", l_nom_cliente_fat CLIPPED,
              COLUMN 096, "DATA/HORA RETORNO"

        LET l_den_empresa_aten = cdv2012_busca_den_empresa(lr_solic.empresa_atendida)
        PRINT COLUMN 002, "EMPRESA ATENDIDA: ", lr_solic.empresa_atendida CLIPPED, " - ",
                          l_den_empresa_aten CLIPPED,
              COLUMN 096, "-------------------"
        LET l_den_empresa_fatur = cdv2012_busca_den_empresa(lr_solic.filial_atendida)
        PRINT COLUMN 003, "FILIAL ATENDIDA: ", lr_solic.filial_atendida CLIPPED, " - ",
                          l_den_empresa_fatur CLIPPED,
              COLUMN 096, lr_solic.dat_hor_retorno

        LET l_des_finalidade = cdv2012_busca_finalidade(lr_solic.finalidade_viagem)
        PRINT COLUMN 001, "FINALIDADE VIAGEM: ", lr_solic.finalidade_viagem USING "####&", " - ",
                          l_des_finalidade CLIPPED

        INITIALIZE l_trajeto1, l_trajeto2,
                   l_trajeto3, l_trajeto4,
                   l_motivo1,  l_motivo2,
                   l_motivo3,  l_motivo4 TO NULL

        LET l_trajeto1 = lr_solic.trajeto_principal[1,50]
        LET l_trajeto2 = lr_solic.trajeto_principal[51,100]
        LET l_trajeto3 = lr_solic.trajeto_principal[101,150]
        LET l_trajeto4 = lr_solic.trajeto_principal[151,200]
        LET l_motivo1  = lr_solic.motivo_viagem[1,50]
        LET l_motivo2  = lr_solic.motivo_viagem[51,100]
        LET l_motivo3  = lr_solic.motivo_viagem[101,150]
        LET l_motivo4  = lr_solic.motivo_viagem[151,200]

        PRINT COLUMN 001, "TRAJETO PRINCIPAL: ", l_trajeto1 CLIPPED,
                          l_trajeto2 CLIPPED
        PRINT COLUMN 020, l_trajeto3,
                          l_trajeto4

        PRINT COLUMN 005, "MOTIVO VIAGEM: ", l_motivo1 CLIPPED,
                          l_motivo2
        PRINT COLUMN 020, l_motivo3,
                          l_motivo4,
                          log5211_negrito("ATIVA") CLIPPED

        WHENEVER ERROR CONTINUE
         SELECT status_acer_viagem
           INTO l_status_acer_viagem
           FROM cdv_acer_viag_781
          WHERE empresa = p_cod_empresa
            AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           INITIALIZE l_status_acer_viagem TO NULL
        END IF

        LET l_des_status = cdv2012_busca_status_viagem(l_status_acer_viagem)

        PRINT COLUMN 012, "STATUS: ", l_des_status CLIPPED,
                          log5211_negrito("DESATIVA") CLIPPED

        LET l_qtd_adiant    = 0
        LET l_qtd_desp_urb  = 0
        LET l_qtd_desp_km   = 0
        LET l_qtd_desp_km2  = 0
        LET l_qtd_desp_terc = 0
        LET l_qtd_apont     = 0
        LET l_tot_adiant    = 0


        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_adiant
          FROM cdv_solic_adto_781
         WHERE empresa = p_cod_empresa
           AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_SOLIC_ADTO_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_adiant IS NULL THEN
           LET l_qtd_adiant = 0
        END IF

       IF l_qtd_adiant > 0 THEN
          WHENEVER ERROR CONTINUE
          DECLARE cq_solic_adto_781 CURSOR FOR
          SELECT empresa,          viagem,
                 sequencia_adto,   dat_adto_viagem,
                 val_adto_viagem,  forma_adto_viagem,
                 banco,            agencia,
                 cta_corrente,     num_ad_adto_viagem
            FROM cdv_solic_adto_781
           WHERE empresa = p_cod_empresa
             AND viagem  = lr_solic.viagem
            ORDER BY sequencia_adto
           WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("DECLARE","CQ_SOLIC_ADTO_781")
             LET m_houve_erro = TRUE
          END IF

          SKIP 1 LINES
          PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
          PRINT COLUMN 001, "================================================= ADIANTAMENTOS ==================================================",
                            log5211_negrito("DESATIVA") CLIPPED
          PRINT COLUMN 001, "TIPO DE ADIANTAMENTO                   VIAG.ORIG.    DATA        VALOR                    "
          PRINT COLUMN 001, "-------------------------------------- ------------- ----------  --------------           "
          LET l_cont       = 0
          LET l_tot_adiant = 0
          WHENEVER ERROR CONTINUE
          FOREACH cq_solic_adto_781 INTO lr_cdv_solic_adto_781.*
          WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_SOLIC_ADTO_781")
                 EXIT FOREACH
              END IF

             LET l_cont = l_cont + 1
             LET m_houve_adto = TRUE
             PRINT COLUMN 001, "ADIANTAMENTO DE VALOR",
                   COLUMN 040, "",
                   COLUMN 054, lr_cdv_solic_adto_781.dat_adto_viagem,
                   COLUMN 066, lr_cdv_solic_adto_781.val_adto_viagem USING "###,###,##&.&&"
             IF lr_cdv_solic_adto_781.val_adto_viagem IS NOT NULL THEN
                LET l_tot_adiant = l_tot_adiant + lr_cdv_solic_adto_781.val_adto_viagem
             END IF
             IF l_cont = l_qtd_adiant THEN
                SKIP 1 LINE
                PRINT COLUMN 059, "TOTAL: ",l_tot_adiant USING "###,###,##&.&&"
             END IF

          END FOREACH
          WHENEVER ERROR CONTINUE
          FREE cq_solic_adto_781
          WHENEVER ERROR STOP
       END IF

       WHENEVER ERROR CONTINUE
       SELECT COUNT(*)
         INTO l_qtd_desp_urb
         FROM cdv_desp_urb_781
        WHERE empresa = p_cod_empresa
          AND viagem  = lr_solic.viagem
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("SELECT","CDV_DESP_URB_781")
          LET m_houve_erro = TRUE
       END IF

       IF l_qtd_desp_urb IS NULL THEN
          LET l_qtd_desp_urb = 0
       END IF

        LET l_tot_desp_urb = 0

        IF l_qtd_desp_urb > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_desp_urb_781 CURSOR FOR
           SELECT empresa,            viagem,
                 seq_despesa_urbana, ativ,
                 tip_despesa_viagem, docum_viagem,
                 dat_despesa_urbana, val_despesa_urbana,
                 obs_despesa_urbana
            FROM cdv_desp_urb_781
           WHERE empresa = p_cod_empresa
             AND viagem  = lr_solic.viagem
           ORDER BY seq_despesa_urbana
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_DESP_URB_781")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "==================================================== DESPESAS ===================================================="
           PRINT COLUMN 001, "------------------------------------------------ DESPESAS URBANAS ------------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "DENOMINACAO DA DESPESA         ATIVIDADE                                   DOCUMENTO     DATA       VALOR         "
           PRINT COLUMN 001, "------------------------------ ------------------------------------------- ------------- ---------- --------------"

           LET l_cont         = 0
           LET l_tot_desp_urb = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_desp_urb_781 INTO lr_cdv_desp_urb_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESP_URB")
                 EXIT FOREACH
              END IF

              LET l_cont       = l_cont + 1
              LET m_houve_desp_urb = TRUE
              LET l_despesa    = cdv2012_busca_tipo_despesa(lr_cdv_desp_urb_781.tip_despesa_viagem, lr_cdv_desp_urb_781.ativ)
              LET l_atividade  = cdv2012_busca_atividade(lr_cdv_desp_urb_781.ativ)
              PRINT COLUMN 001, l_despesa CLIPPED,
                    COLUMN 032, l_atividade[1,43],
                    COLUMN 076, lr_cdv_desp_urb_781.docum_viagem CLIPPED,
                    COLUMN 090, lr_cdv_desp_urb_781.dat_despesa_urbana,
                    COLUMN 101, lr_cdv_desp_urb_781.val_despesa_urbana USING "###,###,##&.&&"
              IF lr_cdv_desp_urb_781.val_despesa_urbana IS NOT NULL THEN
                 LET l_tot_desp_urb = l_tot_desp_urb + lr_cdv_desp_urb_781.val_despesa_urbana
              END IF
              IF  lr_cdv_desp_urb_781.obs_despesa_urbana IS NOT NULL
              AND lr_cdv_desp_urb_781.obs_despesa_urbana <> " " THEN
                 PRINT COLUMN 001, lr_cdv_desp_urb_781.obs_despesa_urbana CLIPPED
              END IF
              IF l_cont = l_qtd_desp_urb THEN
                 SKIP 1 LINE
                 PRINT COLUMN 094, "TOTAL: ", l_tot_desp_urb USING "###,###,##&.&&"
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_desp_urb_781
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(cdv_despesa_km_781.empresa)
          INTO l_qtd_desp_km
          FROM cdv_despesa_km_781, cdv_tdesp_viag_781
         WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.viagem             = lr_solic.viagem
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
           AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
           AND cdv_despesa_km_781.val_km             > 0
           AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
# OS 459347 linha acima
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_QTD_DESP_KM")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_km IS NULL THEN
           LET l_qtd_desp_km = 0
        END IF

        LET l_tot_desp_km     = 0

        IF l_qtd_desp_km > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_despesa_km_781 CURSOR FOR
           SELECT cdv_despesa_km_781.empresa,            cdv_despesa_km_781.viagem,
                  cdv_despesa_km_781.tip_despesa_viagem, cdv_despesa_km_781.seq_despesa_km,
                  cdv_despesa_km_781.ativ_km,            cdv_despesa_km_781.trajeto,
                  cdv_despesa_km_781.placa,              cdv_despesa_km_781.km_inicial,
                  cdv_despesa_km_781.km_final,           cdv_despesa_km_781.qtd_km,
                  cdv_despesa_km_781.val_km,             cdv_despesa_km_781.apropr_desp_km,
                  cdv_despesa_km_781.dat_despesa_km,     cdv_despesa_km_781.obs_despesa_km
             FROM cdv_despesa_km_781, cdv_tdesp_viag_781
            WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#              AND cdv_despesa_km_781.tip_despesa_viagem = 2
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
              AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
              AND cdv_despesa_km_781.val_km             > 0
              AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
            ORDER BY seq_despesa_km
# OS 459347 segun linha de baixo pra acima
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_DESPESA_KM_781")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           IF m_houve_desp_urb = FALSE THEN
              PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
              PRINT COLUMN 001, "==================================================== DESPESAS ====================================================",
                                log5211_negrito("DESATIVA") CLIPPED
           END IF
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "--------------------------------------------- DESPESAS QUILOMETRAGEM ---------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                              KM     KM     QTD                                                   "
           PRINT COLUMN 001, "ATIVIDADE                            PLACA    INIC   FIN    KM    TRAJETO                  DATA       VALOR       "
           PRINT COLUMN 001, "------------------------------------ -------- ------ ------ ----- ------------------------ ---------- ------------"
           LET l_cont            = 0
           LET l_tot_desp_km     = 0

           WHENEVER ERROR CONTINUE
           FOREACH cq_despesa_km_781 INTO lr_cdv_despesa_km_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESPESA_KM_781")
                 EXIT FOREACH
              END IF

              LET l_cont          = l_cont + 1
              LET m_houve_desp_km = TRUE
              LET l_atividade     = cdv2012_busca_atividade(lr_cdv_despesa_km_781.ativ_km)

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_despesa_km_781.placa CLIPPED,
                    COLUMN 047, lr_cdv_despesa_km_781.km_inicial USING "#####&",
                    COLUMN 054, lr_cdv_despesa_km_781.km_final   USING "#####&",
                    COLUMN 061, lr_cdv_despesa_km_781.qtd_km     USING "####&",
                    COLUMN 067, lr_cdv_despesa_km_781.trajeto[1,24],
                    COLUMN 092, lr_cdv_despesa_km_781.dat_despesa_km,
                    COLUMN 103, lr_cdv_despesa_km_781.val_km USING "#,###,##&.&&"
              IF lr_cdv_despesa_km_781.val_km IS NOT NULL THEN
                 LET l_tot_desp_km = l_tot_desp_km + lr_cdv_despesa_km_781.val_km
              END IF
              IF  lr_cdv_despesa_km_781.obs_despesa_km IS NOT NULL
              AND lr_cdv_despesa_km_781.obs_despesa_km <> " " THEN
                 PRINT COLUMN 001, lr_cdv_despesa_km_781.obs_despesa_km CLIPPED
              END IF

              IF l_cont = l_qtd_desp_km THEN
                 SKIP 1 LINE
                 PRINT COLUMN 094, "TOTAL: ", l_tot_desp_km USING "#,###,##&.&&"
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_despesa_km_781
           WHENEVER ERROR STOP
        END IF

        IF m_houve_adto     = TRUE
        OR m_houve_desp_urb = TRUE
        OR m_houve_desp_km  = TRUE THEN
           SKIP 1 LINE
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "===================================================== RESUMO =====================================================",
                             log5211_negrito("DESATIVA") CLIPPED

           IF l_tot_desp_urb IS NULL THEN
              LET l_tot_desp_urb = 0
           END IF

           IF l_tot_desp_km IS NULL THEN
              LET l_tot_desp_km = 0
           END IF

           IF l_tot_adiant IS NULL THEN
              LET l_tot_adiant = 0
           END IF

           PRINT COLUMN 001, "TOTAL ADIANTAMENTOS: ", l_tot_adiant USING "###,###,##&.&&",
                 COLUMN 065, "TOTAL DESPESAS: ", l_tot_desp_urb + l_tot_desp_km  USING "###,###,##&.&&"

           LET l_saldo = l_tot_adiant - (l_tot_desp_urb + l_tot_desp_km)
           IF l_saldo < 0 THEN
              LET l_saldo = l_saldo * (-1)
              PRINT COLUMN 064, "SALDO A RECEBER: ", l_saldo USING "###,###,##&.&&"
#              PRINT COLUMN 065, "SALDO A RESTIT: "
#              PRINT COLUMN 067, "VIAGEM RECEB: "
#              PRINT COLUMN 065, "CONTROLE RECEB: "

           ELSE
              CALL cdv2012_busca_dados_viag(lr_solic.viagem)
                   RETURNING l_viagem_rec, l_controle_rec
 #             PRINT COLUMN 064, "SALDO A RECEBER: "
              PRINT COLUMN 065, "SALDO A RESTIT: ", l_saldo USING "###,###,##&.&&"
              PRINT COLUMN 067, "VIAGEM RECEB: ",   l_viagem_rec USING "#####&"
              PRINT COLUMN 065, "CONTROLE RECEB: ", l_controle_rec CLIPPED
           END IF
        END IF


        WHENEVER ERROR CONTINUE
        SELECT COUNT(cdv_despesa_km_781.empresa)
          INTO l_qtd_desp_km2
          FROM cdv_despesa_km_781, cdv_tdesp_viag_781
         WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#           AND cdv_despesa_km_781.tip_despesa_viagem = 3
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
           AND cdv_tdesp_viag_781.grp_despesa_viagem = 3
           AND cdv_despesa_km_781.val_km             > 0
           AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
# OS 459347 linha acima
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_DESPESA_KM_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_km2 IS NULL THEN
           LET l_qtd_desp_km2 = 0
        END IF

        IF l_qtd_desp_km2 > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_despesa_km2_781 CURSOR FOR
           SELECT cdv_despesa_km_781.empresa,            cdv_despesa_km_781.viagem,
                  cdv_despesa_km_781.tip_despesa_viagem, cdv_despesa_km_781.seq_despesa_km,
                  cdv_despesa_km_781.ativ_km,            cdv_despesa_km_781.trajeto,
                  cdv_despesa_km_781.placa,              cdv_despesa_km_781.km_inicial,
                  cdv_despesa_km_781.km_final,           cdv_despesa_km_781.qtd_km,
                  cdv_despesa_km_781.val_km,             cdv_despesa_km_781.apropr_desp_km,
                  cdv_despesa_km_781.dat_despesa_km,     cdv_despesa_km_781.obs_despesa_km
             FROM cdv_despesa_km_781, cdv_tdesp_viag_781
            WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#              AND cdv_despesa_km_781.tip_despesa_viagem = 3
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
              AND cdv_tdesp_viag_781.grp_despesa_viagem = 3
              AND cdv_despesa_km_781.val_km             > 0
              AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
            ORDER BY seq_despesa_km
# OS 459347 segun linha de baixo pra acima
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_DESPESA_KM2_781")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "================================================ DESPESAS EXTRAS ================================================"
           PRINT COLUMN 001, "----------------------------------------- DESPESAS QUILOMETRAGEM SEMANAL ----------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                              KM     KM     QTD                                                  "
           PRINT COLUMN 001, "ATIVIDADE                            PLACA    INIC   FIN    KM    TRAJETO                 DATA       VALOR       "
           PRINT COLUMN 001, "------------------------------------ -------- ------ ------ ----- ----------------------- ---------- ------------"

           LET l_cont            = 0
           LET l_tot_desp_km = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_despesa_km2_781 INTO lr_cdv_despesa_km_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESPESA_KM2_781")
                 EXIT FOREACH
              END IF

              LET l_cont      = l_cont + 1
              LET l_atividade = cdv2012_busca_atividade(lr_cdv_despesa_km_781.ativ_km)

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_despesa_km_781.placa CLIPPED,
                    COLUMN 047, lr_cdv_despesa_km_781.km_inicial USING "#####&",
                    COLUMN 054, lr_cdv_despesa_km_781.km_final   USING "#####&",
                    COLUMN 061, lr_cdv_despesa_km_781.qtd_km     USING "####&",
                    COLUMN 067, lr_cdv_despesa_km_781.trajeto[1,24],
                    COLUMN 091, lr_cdv_despesa_km_781.dat_despesa_km,
                    COLUMN 102, lr_cdv_despesa_km_781.val_km USING "#,###,##&.&&"
              LET l_tot_desp_km = l_tot_desp_km + lr_cdv_despesa_km_781.val_km

              IF  lr_cdv_despesa_km_781.obs_despesa_km IS NOT NULL
              AND lr_cdv_despesa_km_781.obs_despesa_km <> " " THEN
                 PRINT COLUMN 001, lr_cdv_despesa_km_781.obs_despesa_km CLIPPED
              END IF

              IF l_cont = l_qtd_desp_km2 THEN
                 SKIP 1 LINE
                 PRINT COLUMN 040, "AD: ", lr_cdv_despesa_km_781.apropr_desp_km USING "#####&",
                       COLUMN 095, "TOTAL: ", l_tot_desp_km USING "#,###,##&.&&"
                 SKIP 1 LINE
              END IF

           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_despesa_km2_781
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_desp_terc
          FROM cdv_desp_terc_781
         WHERE empresa  = p_cod_empresa
           AND viagem   = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_DESP_TERC_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_terc IS NULL THEN
           LET l_qtd_desp_terc = 0
        END IF

        IF l_qtd_desp_terc > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_desp_terc_781 CURSOR FOR
           SELECT empresa,           viagem,
                  seq_desp_terceiro, ativ,
                  tip_despesa,       nota_fiscal,
                  serie_nota_fiscal, subserie_nf,
                  fornecedor,        dat_inclusao,
                  dat_vencto,        val_desp_terceiro,
                  observacao,        ad_terceiro
             FROM cdv_desp_terc_781
            WHERE empresa  = p_cod_empresa
              AND viagem   = lr_solic.viagem
            ORDER BY seq_desp_terceiro
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_DESP_TERC_781")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "--------------------------------------------- DESPESAS DE TERCEIROS ----------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "DENOMINACAO DA DESPESA         ATIVIDADE                                   NF/DOC        DATA       VALOR         "
           PRINT COLUMN 001, "------------------------------ ------------------------------------------- ------------- ---------- --------------"
           LET l_cont          = 0
           LET l_tot_desp_terc = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_desp_terc_781 INTO lr_cdv_desp_terc_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESP_TERC_781")
                 EXIT FOREACH
              END IF

              LET l_cont      = l_cont + 1
              LET l_despesa   = cdv2012_busca_tipo_despesa(lr_cdv_desp_terc_781.tip_despesa, lr_cdv_desp_terc_781.ativ)
              LET l_atividade = cdv2012_busca_atividade(lr_cdv_desp_terc_781.ativ)
              PRINT COLUMN 001, l_despesa CLIPPED,
                    COLUMN 032, l_atividade[1,43],
                    COLUMN 081, lr_cdv_desp_terc_781.nota_fiscal USING "#######&",
                    COLUMN 090, lr_cdv_desp_terc_781.dat_inclusao,
                    COLUMN 101, lr_cdv_desp_terc_781.val_desp_terceiro USING "###,###,##&.&&"

              LET l_tot_desp_terc = l_tot_desp_terc + lr_cdv_desp_terc_781.val_desp_terceiro

              PRINT COLUMN 001, "FORNECEDOR: ",
                                lr_cdv_desp_terc_781.fornecedor,
                    COLUMN 035, "DATA VENC: ", lr_cdv_desp_terc_781.dat_vencto

              #IF l_cont = l_qtd_desp_terc THEN

                 LET l_num_ap = cdv2012_busca_numero_ap(lr_cdv_desp_terc_781.ad_terceiro)
                 PRINT COLUMN 045, "AD: ", lr_cdv_desp_terc_781.ad_terceiro USING "#####&",
                       COLUMN 094, "TOTAL: ", l_tot_desp_terc USING "###,###,##&.&&"
                 PRINT COLUMN 045, "AP: ", l_num_ap USING "#####&"
                 SKIP 1 LINE
              #END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_desp_terc_781
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_apont
          FROM cdv_apont_hor_781
         WHERE empresa = p_cod_empresa
           AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_APONT_HOR_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_apont IS NULL THEN
           LET l_qtd_apont = 0
        END IF

        # OS 459347
        LET l_qtd_apont = 0

        IF l_qtd_apont > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_apont_hor_781 CURSOR FOR
           SELECT empresa,       viagem,
                  seq_apont_hor, tdesp_apont_hor,
                  hor_inicial,   hor_final,
                  motivo,        hor_diurnas,
                  hor_noturnas,  dat_apont_hor,
                  obs_apont_hor
             FROM cdv_apont_hor_781
            WHERE empresa = p_cod_empresa
              AND viagem  = lr_solic.viagem
            ORDER BY seq_apont_hor
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_APONT_HOR_781")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "============================================== APONTAMENTO DE HORAS ==============================================",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                     HORA     HORA                                               QTD        QTD   "
           PRINT COLUMN 001, "ATIVIDADE                            INICIAL  FIM      MOTIVO                         DATA       HOR.DIU. HOR.NOT "
           PRINT COLUMN 001, "------------------------------------ -------- -------- ------------------------------ ---------- -------- --------"

           LET l_cont      = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_apont_hor_781 INTO lr_cdv_apont_hor_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_APONT_HOR_781")
                 EXIT FOREACH
              END IF

              LET l_cont = l_cont + 1
              CALL cdv2012_busca_dados(lr_cdv_apont_hor_781.tdesp_apont_hor, lr_cdv_apont_hor_781.motivo)
                   RETURNING l_atividade, l_des_motivo

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_apont_hor_781.hor_inicial,
                    COLUMN 047, lr_cdv_apont_hor_781.hor_final,
                    COLUMN 056, l_des_motivo CLIPPED,
                    COLUMN 087, lr_cdv_apont_hor_781.dat_apont_hor,
                    COLUMN 098, lr_cdv_apont_hor_781.hor_diurnas,
                    COLUMN 107, lr_cdv_apont_hor_781.hor_noturnas
              IF l_cont = l_qtd_apont THEN
#                 PRINT COLUMN 001, "=================================================================================================================="
#                 PRINT COLUMN 001, "OBSERVACOES: ",
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_apont_hor_781
           WHENEVER ERROR STOP
        END IF

     ON LAST ROW
        LET m_last_row = TRUE

     PAGE TRAILER
        IF m_last_row = TRUE THEN
           LET l_num_ap = cdv2012_busca_numero_ap(l_num_ad)
           PRINT COLUMN 001, "------------------------     ------------------------     ------------------------     ------------------------"
           PRINT COLUMN 001, "  ASS. COLABORADOR             VISTO CHEFIA                    SERVICOS ADM./FAT             AUTORIZADO        "
           PRINT COLUMN 001, "                                                            AD ACERTO: ", l_num_ad USING "#####&"
           PRINT COLUMN 001, "                                                            AP ACERTO: ", l_num_ap USING "#####&"
           PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------ VIA CAIXA -"
        ELSE
           PRINT ""
           PRINT ""
           PRINT ""
           PRINT ""
           PRINT ""
        END IF

END REPORT

#--------------------------------#
 REPORT cdv2012_relat_cl(lr_solic)
#--------------------------------#

 DEFINE lr_cdv_acer_viag_781  RECORD LIKE cdv_acer_viag_781.*,
        lr_cdv_despesa_km_781 RECORD LIKE cdv_despesa_km_781.*,
        lr_cdv_desp_terc_781  RECORD LIKE cdv_desp_terc_781.*,
        lr_cdv_solic_adto_781 RECORD LIKE cdv_solic_adto_781.*,
        lr_cdv_desp_urb_781   RECORD LIKE cdv_desp_urb_781.*,
        lr_cdv_apont_hor_781  RECORD LIKE cdv_apont_hor_781.*

  DEFINE lr_solic             RECORD
                                 viagem               LIKE cdv_acer_viag_781.viagem,
                                 controle             LIKE cdv_acer_viag_781.controle,
                                 viajante             LIKE cdv_acer_viag_781.viajante,
                                 finalidade_viagem    LIKE cdv_acer_viag_781.finalidade_viagem,
                                 cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
                                 cc_debitar           LIKE cdv_acer_viag_781.cc_debitar,
                                 cliente_atendido     LIKE cdv_acer_viag_781.cliente_debitar,
                                 cliente_fatur        LIKE cdv_acer_viag_781.cliente_debitar,
                                 empresa_atendida     LIKE cdv_acer_viag_781.empresa_atendida,
                                 filial_atendida      LIKE cdv_acer_viag_781.filial_atendida,
                                 trajeto_principal    LIKE cdv_acer_viag_781.trajeto_principal,
                                 dat_hor_partida      DATETIME YEAR TO SECOND,
                                 dat_hor_retorno      DATETIME YEAR TO SECOND,
                                 motivo_viagem        LIKE cdv_acer_viag_781.motivo_viagem,
                                 tip_cliente          LIKE cdv_controle_781.tip_cliente #OS 487356
                              END RECORD

 DEFINE l_trajeto1            CHAR(55),
        l_trajeto2            CHAR(55),
        l_trajeto3            CHAR(55),
        l_trajeto4            CHAR(55),
        l_motivo1             CHAR(55),
        l_motivo2             CHAR(55),
        l_motivo3             CHAR(55),
        l_motivo4             CHAR(55),
        l_cont                INTEGER,
        l_ind                 SMALLINT,
        l_viagem_origem       LIKE cdv_solic_viag_781.viagem,
        l_data                DATE,
        l_num_ap              LIKE ad_ap.num_ap,
        l_num_ad              LIKE ad_ap.num_ad,
        l_tip_cliente         LIKE cdv_controle_781.tip_cliente #OS 487356

 DEFINE l_qtd_adiant          INTEGER,
        l_qtd_desp_urb        INTEGER,
        l_qtd_desp_km         INTEGER,
        l_qtd_desp_km2        INTEGER,
        l_qtd_desp_terc       INTEGER,
        l_qtd_apont           INTEGER

 DEFINE l_nom_viajante        LIKE usuarios.nom_funcionario,
        l_nom_cc_viajante     LIKE cad_cc.nom_cent_cust,
        l_nom_cc_deb          LIKE cad_cc.nom_cent_cust,
        l_nom_cliente_aten    CHAR(36),
        l_nom_cliente_fat     CHAR(36),
        l_den_empresa_aten    LIKE empresa.den_empresa,
        l_den_empresa_fatur   LIKE empresa.den_empresa,
        l_des_finalidade      LIKE cdv_finalidade_781.des_finalidade,
        l_despesa             LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
        l_tot_adiant          LIKE cdv_solic_adto_781.val_adto_viagem,
        l_tot_desp_urb        LIKE cdv_desp_urb_781.val_despesa_urbana,
        l_tot_desp_km         like cdv_despesa_km_781.val_km,
        l_tot_desp_km2        like cdv_despesa_km_781.val_km,
        l_tot_desp_terc       LIKE cdv_desp_terc_781.val_desp_terceiro,
        l_atividade           LIKE cdv_ativ_781.des_ativ,
        l_motivo              LIKE cdv_motivo_hor_781.des_motivo,
        l_des_motivo          LIKE cdv_motivo_hor_781.des_motivo,
        l_saldo               DECIMAL(17,2),
        l_des_status          CHAR(50)

 DEFINE l_status_acer_viagem LIKE cdv_acer_viag_781.status_acer_viagem,
        l_viagem_rec         like cdv_dev_transf_781.viagem_receb,
        l_controle_rec       like cdv_dev_transf_781.controle_receb

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE   LENGTH 66

  FORMAT
     PAGE HEADER
        PRINT COLUMN 001, log5211_retorna_configuracao(PAGENO,66,118) CLIPPED;
        PRINT COLUMN 001, m_den_empresa CLIPPED

        PRINT COLUMN 001, "CDV2012 - DETALHADO",
              COLUMN 107, "FL. ",PAGENO USING "####"

        PRINT COLUMN 075, " EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
                          " AS ", TIME, " HRS."
        PRINT COLUMN 093, "PELO USUARIO: ", UPSHIFT(p_user),
                          log5211_negrito("ATIVA") CLIPPED

        PRINT COLUMN 041, "RELATORIO DE DESPESA DE VIAGEM"

        PRINT COLUMN 001, log5211_negrito("DESATIVA") CLIPPED

    ON EVERY ROW
        WHENEVER ERROR CONTINUE
        SELECT DATE(dat_hr_emis_relat), ad_acerto_conta
          INTO l_data, l_num_ad
          FROM cdv_acer_viag_781
         WHERE empresa = p_cod_empresa
           AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           INITIALIZE l_data, l_num_ad TO NULL
        END IF

       #OS 487356
       WHENEVER ERROR CONTINUE
        SELECT tip_cliente
         INTO l_tip_cliente
         FROM cdv_controle_781
        WHERE controle   = lr_solic.controle
          AND sistema    = lr_solic.finalidade_viagem
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
         INITIALIZE l_tip_cliente TO NULL
       END IF

       #OS 459347
       #PRINT COLUMN 012, "VIAGEM: ",   lr_solic.viagem USING "####&",
       #      COLUMN 030, "CONTROLE: ", lr_solic.controle CLIPPED,
        PRINT COLUMN 012, "VIAGEM: ",   lr_solic.viagem   USING "<<<<<<<<<",
              COLUMN 030, "CONTROLE: ", lr_solic.controle USING "<<<<<<<<<<<<<<<<<<<<",
              COLUMN 065, "DATA: ", l_data

        LET l_nom_viajante = cdv2012_busca_viajante(lr_solic.viajante)
        PRINT COLUMN 010, "VIAJANTE: ", l_nom_viajante CLIPPED

        LET l_nom_cc_viajante = cdv2012_busca_cc(lr_solic.cc_viajante)
        LET l_nom_cc_deb      = cdv2012_busca_cc(lr_solic.cc_debitar)
        PRINT COLUMN 003, "C.C. (viajante): ", lr_solic.cc_viajante USING "####&", " - ",
                                               l_nom_cc_viajante CLIPPED,
              COLUMN 096, "DATA/HORA PARTIDA"
        PRINT COLUMN 002, "C.C. (a debitar): ", lr_solic.cc_debitar USING "####&", " - ",
                          l_nom_cc_deb CLIPPED,
              COLUMN 096, "-------------------"
        PRINT COLUMN 096, lr_solic.dat_hor_partida

        LET l_nom_cliente_aten = cdv2012_busca_nom_cliente(lr_solic.cliente_atendido)
        PRINT COLUMN 002, "CLIENTE ATENDIDO: ", lr_solic.cliente_atendido CLIPPED,
              COLUMN 022, " - ", l_nom_cliente_aten CLIPPED

        LET l_nom_cliente_fat  = cdv2012_busca_nom_cliente(lr_solic.cliente_fatur)
        PRINT COLUMN 003, "CLIENTE FATURAR: ", lr_solic.cliente_fatur CLIPPED,
              COLUMN 022, " - ", l_nom_cliente_fat CLIPPED,
              COLUMN 096, "DATA/HORA RETORNO"

       #OS 487356
       WHENEVER ERROR CONTINUE
        SELECT tip_cliente
         INTO l_tip_cliente
         FROM cdv_controle_781
        WHERE controle   = lr_solic.controle
          AND sistema    = lr_solic.finalidade_viagem
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
         INITIALIZE l_tip_cliente TO NULL
       END IF
        #OS 487356
        LET l_tip_cliente  = lr_solic.tip_cliente
        PRINT COLUMN 003, "TIPO CLIENTE: ", l_tip_cliente CLIPPED
        #---

        LET l_den_empresa_aten = cdv2012_busca_den_empresa(lr_solic.empresa_atendida)
        PRINT COLUMN 002, "EMPRESA ATENDIDA: ", lr_solic.empresa_atendida CLIPPED, " - ",
                          l_den_empresa_aten CLIPPED,
              COLUMN 096, "-------------------"
        LET l_den_empresa_fatur = cdv2012_busca_den_empresa(lr_solic.filial_atendida)
        PRINT COLUMN 003, "FILIAL ATENDIDA: ", lr_solic.filial_atendida CLIPPED, " - ",
                          l_den_empresa_fatur CLIPPED,
              COLUMN 096, lr_solic.dat_hor_retorno

        LET l_des_finalidade = cdv2012_busca_finalidade(lr_solic.finalidade_viagem)
        PRINT COLUMN 001, "FINALIDADE VIAGEM: ", lr_solic.finalidade_viagem USING "####&", " - ",
                          l_des_finalidade CLIPPED

        INITIALIZE l_trajeto1, l_trajeto2,
                   l_trajeto3, l_trajeto4,
                   l_motivo1,  l_motivo2,
                   l_motivo3,  l_motivo4 TO NULL

        LET l_trajeto1 = lr_solic.trajeto_principal[1,50]
        LET l_trajeto2 = lr_solic.trajeto_principal[51,100]
        LET l_trajeto3 = lr_solic.trajeto_principal[101,150]
        LET l_trajeto4 = lr_solic.trajeto_principal[151,200]
        LET l_motivo1  = lr_solic.motivo_viagem[1,50]
        LET l_motivo2  = lr_solic.motivo_viagem[51,100]
        LET l_motivo3  = lr_solic.motivo_viagem[101,150]
        LET l_motivo4  = lr_solic.motivo_viagem[151,200]

        PRINT COLUMN 001, "TRAJETO PRINCIPAL: ", l_trajeto1 CLIPPED,
                          l_trajeto2 CLIPPED
        PRINT COLUMN 020, l_trajeto3,
                          l_trajeto4

        PRINT COLUMN 005, "MOTIVO VIAGEM: ", l_motivo1 CLIPPED,
                          l_motivo2
        PRINT COLUMN 020, l_motivo3,
                          l_motivo4,
                          log5211_negrito("ATIVA") CLIPPED

        WHENEVER ERROR CONTINUE
         SELECT status_acer_viagem
           INTO l_status_acer_viagem
           FROM cdv_acer_viag_781
          WHERE empresa = p_cod_empresa
            AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           INITIALIZE l_status_acer_viagem TO NULL
        END IF

        LET l_des_status = cdv2012_busca_status_viagem(l_status_acer_viagem)

        PRINT COLUMN 012, "STATUS: ", l_des_status,
                          log5211_negrito("DESATIVA") CLIPPED

        LET l_qtd_adiant    = 0
        LET l_qtd_desp_urb  = 0
        LET l_qtd_desp_km   = 0
        LET l_qtd_desp_km2  = 0
        LET l_qtd_desp_terc = 0
        LET l_qtd_apont     = 0


        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_adiant
          FROM cdv_solic_adto_781
         WHERE empresa = p_cod_empresa
           AND viagem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_SOLIC_ADTO_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_adiant IS NULL THEN
           LET l_qtd_adiant = 0
        END IF

       IF l_qtd_adiant > 0 THEN
          WHENEVER ERROR CONTINUE
          DECLARE cq_solic_adto_7812 CURSOR FOR
          SELECT empresa,          viagem,
                 sequencia_adto,   dat_adto_viagem,
                 val_adto_viagem,  forma_adto_viagem,
                 banco,            agencia,
                 cta_corrente,     num_ad_adto_viagem
            FROM cdv_solic_adto_781
           WHERE empresa = p_cod_empresa
             AND viagem  = lr_solic.viagem
            ORDER BY sequencia_adto
           WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("DECLARE","cq_solic_adto_7812")
             LET m_houve_erro = TRUE
          END IF

#          SKIP 1 LINES
#          PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
#          PRINT COLUMN 001, "================================================= ADIANTAMENTOS ==================================================",
#                            log5211_negrito("DESATIVA") CLIPPED
#          PRINT COLUMN 001, "TIPO DE ADIANTAMENTO                   VIAG.ORIG.    DATA        VALOR                    "
#          PRINT COLUMN 001, "-------------------------------------- ------------- ----------  --------------           "
          LET l_cont       = 0
          LET l_tot_adiant = 0
          WHENEVER ERROR CONTINUE
          FOREACH cq_solic_adto_7812 INTO lr_cdv_solic_adto_781.*
          WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_SOLIC_ADTO_7812")
                 EXIT FOREACH
              END IF

             LET l_cont = l_cont + 1
             LET m_houve_adto = TRUE
#             PRINT COLUMN 001, "ADIANTAMENTO DE VALOR",
#                   COLUMN 040, "",
#                   COLUMN 054, lr_cdv_solic_adto_781.dat_adto_viagem,
#                   COLUMN 066, lr_cdv_solic_adto_781.val_adto_viagem USING "###,###,##&.&&"
             LET l_tot_adiant = l_tot_adiant + lr_cdv_solic_adto_781.val_adto_viagem

#             IF l_cont = l_qtd_adiant THEN
#                PRINT COLUMN 066, l_tot_adiant USING "###,###,##&.&&"
#             END IF

          END FOREACH
          WHENEVER ERROR CONTINUE
          FREE cq_solic_adto_7812
          WHENEVER ERROR STOP
       END IF

       WHENEVER ERROR CONTINUE
       SELECT COUNT(*)
         INTO l_qtd_desp_urb
         FROM cdv_desp_urb_781, cdv_tdesp_viag_781
        WHERE cdv_desp_urb_781.empresa = p_cod_empresa
          AND cdv_desp_urb_781.viagem  = lr_solic.viagem
          AND cdv_tdesp_viag_781.empresa = p_cod_empresa
          AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_urb_781.tip_despesa_viagem
          AND cdv_tdesp_viag_781.eh_reembolso = "S"
          AND cdv_tdesp_viag_781.ativ               = cdv_desp_urb_781.ativ #OS462484
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("SELECT","CDV_DESP_URB_781")
          LET m_houve_erro = TRUE
       END IF

       IF l_qtd_desp_urb IS NULL THEN
          LET l_qtd_desp_urb = 0
       END IF

        IF l_qtd_desp_urb > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_desp_urb_7812 CURSOR FOR
           SELECT cdv_desp_urb_781.empresa,     cdv_desp_urb_781.viagem,
                 cdv_desp_urb_781.seq_despesa_urbana, cdv_desp_urb_781.ativ,
                 cdv_desp_urb_781.tip_despesa_viagem, cdv_desp_urb_781.docum_viagem,
                 cdv_desp_urb_781.dat_despesa_urbana, cdv_desp_urb_781.val_despesa_urbana,
                 cdv_desp_urb_781.obs_despesa_urbana
            FROM cdv_desp_urb_781, cdv_tdesp_viag_781
           WHERE cdv_desp_urb_781.empresa              = p_cod_empresa
             AND cdv_desp_urb_781.viagem               = lr_solic.viagem
             AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
             AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_urb_781.tip_despesa_viagem
             AND cdv_tdesp_viag_781.eh_reembolso       = "S"
             AND cdv_tdesp_viag_781.ativ               = cdv_desp_urb_781.ativ #OS462484
           ORDER BY seq_despesa_urbana
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","cq_desp_urb_7812")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "==================================================== DESPESAS ===================================================="
           PRINT COLUMN 001, "------------------------------------------------ DESPESAS URBANAS ------------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "DENOMINACAO DA DESPESA         ATIVIDADE                                   DOCUMENTO     DATA       VALOR         "
           PRINT COLUMN 001, "------------------------------ ------------------------------------------- ------------- ---------- --------------"

           LET l_cont         = 0
           LET l_tot_desp_urb = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_desp_urb_7812 INTO lr_cdv_desp_urb_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESP_URB_7812")
                 EXIT FOREACH
              END IF

              LET l_cont       = l_cont + 1
              LET m_houve_desp_urb = TRUE
              LET l_despesa    = cdv2012_busca_tipo_despesa(lr_cdv_desp_urb_781.tip_despesa_viagem, lr_cdv_desp_urb_781.ativ)
              LET l_atividade  = cdv2012_busca_atividade(lr_cdv_desp_urb_781.ativ)
              PRINT COLUMN 001, l_despesa CLIPPED,
                    COLUMN 032, l_atividade[1,43],
                    COLUMN 076, lr_cdv_desp_urb_781.docum_viagem CLIPPED,
                    COLUMN 090, lr_cdv_desp_urb_781.dat_despesa_urbana,
                    COLUMN 101, lr_cdv_desp_urb_781.val_despesa_urbana USING "###,###,##&.&&"
              LET l_tot_desp_urb = l_tot_desp_urb + lr_cdv_desp_urb_781.val_despesa_urbana
              IF  lr_cdv_desp_urb_781.obs_despesa_urbana IS NOT NULL
              AND lr_cdv_desp_urb_781.obs_despesa_urbana <> " " THEN
                 PRINT COLUMN 001, lr_cdv_desp_urb_781.obs_despesa_urbana CLIPPED
              END IF
              IF l_cont = l_qtd_desp_urb THEN
                 SKIP 1 LINE
                 PRINT COLUMN 094, "TOTAL: ", l_tot_desp_urb USING "###,###,##&.&&"
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_desp_urb_7812
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(cdv_despesa_km_781.empresa)
          INTO l_qtd_desp_km
          FROM cdv_despesa_km_781, cdv_tdesp_viag_781
         WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#           AND cdv_despesa_km_781.tip_despesa_viagem = 2
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
           AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
           AND cdv_tdesp_viag_781.eh_reembolso       = "S"
           AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_QTD_DESP_KM")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_km IS NULL THEN
           LET l_qtd_desp_km = 0
        END IF

        LET l_tot_desp_km = 0

        IF l_qtd_desp_km > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_despesa_km_7812 CURSOR FOR
           SELECT cdv_despesa_km_781.empresa,            cdv_despesa_km_781.viagem,
                  cdv_despesa_km_781.tip_despesa_viagem, cdv_despesa_km_781.seq_despesa_km,
                  cdv_despesa_km_781.ativ_km,            cdv_despesa_km_781.trajeto,
                  cdv_despesa_km_781.placa,              cdv_despesa_km_781.km_inicial,
                  cdv_despesa_km_781.km_final,           cdv_despesa_km_781.qtd_km,
                  cdv_despesa_km_781.val_km,             cdv_despesa_km_781.apropr_desp_km,
                  cdv_despesa_km_781.dat_despesa_km,     cdv_despesa_km_781.obs_despesa_km
             FROM cdv_despesa_km_781, cdv_tdesp_viag_781
            WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#              AND cdv_despesa_km_781.tip_despesa_viagem = 2
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
              AND cdv_tdesp_viag_781.grp_despesa_viagem = 2
              AND cdv_tdesp_viag_781.eh_reembolso       = "S"
              AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
            ORDER BY seq_despesa_km
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","cq_despesa_km_7812")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           IF m_houve_desp_urb = FALSE THEN
              PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
              PRINT COLUMN 001, "==================================================== DESPESAS ====================================================",
                                log5211_negrito("DESATIVA") CLIPPED
           END IF
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "--------------------------------------------- DESPESAS QUILOMETRAGEM ---------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                              KM     KM     QTD                                                   "
           PRINT COLUMN 001, "ATIVIDADE                            PLACA    INIC   FIN    KM    TRAJETO                  DATA       VALOR       "
           PRINT COLUMN 001, "------------------------------------ -------- ------ ------ ----- ------------------------ ---------- ------------"
           LET l_cont            = 0
           LET l_tot_desp_km = 0

           WHENEVER ERROR CONTINUE
           FOREACH cq_despesa_km_7812 INTO lr_cdv_despesa_km_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESPESA_KM_7812")
                 EXIT FOREACH
              END IF

              LET l_cont          = l_cont + 1
              LET m_houve_desp_km = TRUE
              LET l_atividade     = cdv2012_busca_atividade(lr_cdv_despesa_km_781.ativ_km)

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_despesa_km_781.placa CLIPPED,
                    COLUMN 047, lr_cdv_despesa_km_781.km_inicial USING "#####&",
                    COLUMN 054, lr_cdv_despesa_km_781.km_final   USING "#####&",
                    COLUMN 061, lr_cdv_despesa_km_781.qtd_km     USING "####&",
                    COLUMN 067, lr_cdv_despesa_km_781.trajeto[1,24],
                    COLUMN 092, lr_cdv_despesa_km_781.dat_despesa_km,
                    COLUMN 103, lr_cdv_despesa_km_781.val_km USING "#,###,##&.&&"
              LET l_tot_desp_km = l_tot_desp_km + lr_cdv_despesa_km_781.val_km

              IF  lr_cdv_despesa_km_781.obs_despesa_km IS NOT NULL
              AND lr_cdv_despesa_km_781.obs_despesa_km <> " " THEN
                 PRINT COLUMN 001, lr_cdv_despesa_km_781.obs_despesa_km CLIPPED
              END IF

              IF l_cont = l_qtd_desp_km THEN
                 SKIP 1 LINE
                 PRINT COLUMN 094, "TOTAL: ", l_tot_desp_km USING "#,###,##&.&&"
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_despesa_km_7812
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(cdv_despesa_km_781.empresa)
          INTO l_qtd_desp_km2
          FROM cdv_despesa_km_781, cdv_tdesp_viag_781
         WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#           AND cdv_despesa_km_781.tip_despesa_viagem = 3
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
           AND cdv_tdesp_viag_781.grp_despesa_viagem = 3
           AND cdv_tdesp_viag_781.eh_reembolso       = "S"
           AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_DESPESA_KM_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_km2 IS NULL THEN
           LET l_qtd_desp_km2 = 0
        END IF

        IF l_qtd_desp_km2 > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_desp_km2_7812 CURSOR FOR
           SELECT cdv_despesa_km_781.empresa,            cdv_despesa_km_781.viagem,
                  cdv_despesa_km_781.tip_despesa_viagem, cdv_despesa_km_781.seq_despesa_km,
                  cdv_despesa_km_781.ativ_km,            cdv_despesa_km_781.trajeto,
                  cdv_despesa_km_781.placa,              cdv_despesa_km_781.km_inicial,
                  cdv_despesa_km_781.km_final,           cdv_despesa_km_781.qtd_km,
                  cdv_despesa_km_781.val_km,             cdv_despesa_km_781.apropr_desp_km,
                  cdv_despesa_km_781.dat_despesa_km,     cdv_despesa_km_781.obs_despesa_km
             FROM cdv_despesa_km_781, cdv_tdesp_viag_781
            WHERE cdv_despesa_km_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.viagem             = lr_solic.viagem
#             AND cdv_despesa_km_781.tip_despesa_viagem = 3
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_despesa_km_781.tip_despesa_viagem = cdv_tdesp_viag_781.tip_despesa_viagem
              AND cdv_tdesp_viag_781.grp_despesa_viagem = 3
              AND cdv_tdesp_viag_781.eh_reembolso       = "S"
              AND cdv_tdesp_viag_781.ativ               = cdv_despesa_km_781.ativ_km #OS462484
            ORDER BY seq_despesa_km
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","cq_desp_km2_7812")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "================================================ DESPESAS EXTRAS ================================================"
           PRINT COLUMN 001, "----------------------------------------- DESPESAS QUILOMETRAGEM SEMANAL ----------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                              KM     KM     QTD                                                  "
           PRINT COLUMN 001, "ATIVIDADE                            PLACA    INIC   FIN    KM    TRAJETO                 DATA       VALOR       "
           PRINT COLUMN 001, "------------------------------------ -------- ------ ------ ----- ----------------------- ---------- ------------"

           LET l_cont            = 0
           LET l_tot_desp_km = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_desp_km2_7812 INTO lr_cdv_despesa_km_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","cq_desp_km2_7812")
                 EXIT FOREACH
              END IF

              LET l_cont      = l_cont + 1
              LET l_atividade = cdv2012_busca_atividade(lr_cdv_despesa_km_781.ativ_km)

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_despesa_km_781.placa CLIPPED,
                    COLUMN 047, lr_cdv_despesa_km_781.km_inicial USING "#####&",
                    COLUMN 054, lr_cdv_despesa_km_781.km_final   USING "#####&",
                    COLUMN 061, lr_cdv_despesa_km_781.qtd_km     USING "####&",
                    COLUMN 067, lr_cdv_despesa_km_781.trajeto[1,24],
                    COLUMN 091, lr_cdv_despesa_km_781.dat_despesa_km,
                    COLUMN 102, lr_cdv_despesa_km_781.val_km USING "#,###,##&.&&"
              LET l_tot_desp_km = l_tot_desp_km + lr_cdv_despesa_km_781.val_km

              IF  lr_cdv_despesa_km_781.obs_despesa_km IS NOT NULL
              AND lr_cdv_despesa_km_781.obs_despesa_km <> " " THEN
                 PRINT COLUMN 001, lr_cdv_despesa_km_781.obs_despesa_km CLIPPED
              END IF

              IF l_cont = l_qtd_desp_km2 THEN
                 SKIP 1 LINE
                 PRINT COLUMN 040, "AD: ", lr_cdv_despesa_km_781.apropr_desp_km USING "#####&",
                       COLUMN 095, "TOTAL: ", l_tot_desp_km USING "#,###,##&.&&"
                 SKIP 1 LINE
              END IF

           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_desp_km2_7812
           WHENEVER ERROR STOP
        END IF

        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_desp_terc
          FROM cdv_desp_terc_781, cdv_tdesp_viag_781
         WHERE cdv_desp_terc_781.empresa             = p_cod_empresa
           AND cdv_desp_terc_781.viagem              = lr_solic.viagem
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_terc_781.tip_despesa
           AND cdv_tdesp_viag_781.eh_reembolso       = "S"
           AND cdv_tdesp_viag_781.ativ               = cdv_desp_terc_781.ativ #OS462484
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_DESP_TERC_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_desp_terc IS NULL THEN
           LET l_qtd_desp_terc = 0
        END IF

        IF l_qtd_desp_terc > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_desp_terc_7812 CURSOR FOR
           SELECT cdv_desp_terc_781.empresa,           cdv_desp_terc_781.viagem,
                  cdv_desp_terc_781.seq_desp_terceiro, cdv_desp_terc_781.ativ,
                  cdv_desp_terc_781.tip_despesa,       cdv_desp_terc_781.nota_fiscal,
                  cdv_desp_terc_781.serie_nota_fiscal, cdv_desp_terc_781.subserie_nf,
                  cdv_desp_terc_781.fornecedor,        cdv_desp_terc_781.dat_inclusao,
                  cdv_desp_terc_781.dat_vencto,        cdv_desp_terc_781.val_desp_terceiro,
                  cdv_desp_terc_781.observacao,        cdv_desp_terc_781.ad_terceiro
             FROM cdv_desp_terc_781, cdv_tdesp_viag_781
            WHERE cdv_desp_terc_781.empresa             = p_cod_empresa
              AND cdv_desp_terc_781.viagem              = lr_solic.viagem
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_desp_terc_781.tip_despesa
              AND cdv_tdesp_viag_781.eh_reembolso       = "S"
              AND cdv_tdesp_viag_781.ativ               = cdv_desp_terc_781.ativ #OS462484
            ORDER BY cdv_desp_terc_781.seq_desp_terceiro
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","cq_desp_terc_7812")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "--------------------------------------------- DESPESAS DE TERCEIROS ----------------------------------------------",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "DENOMINACAO DA DESPESA         ATIVIDADE                                   NF/DOC        DATA       VALOR         "
           PRINT COLUMN 001, "------------------------------ ------------------------------------------- ------------- ---------- --------------"
           LET l_cont          = 0
           LET l_tot_desp_terc = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_desp_terc_7812 INTO lr_cdv_desp_terc_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_DESP_TERC_7812")
                 EXIT FOREACH
              END IF

              LET l_cont      = l_cont + 1
              LET l_despesa   = cdv2012_busca_tipo_despesa(lr_cdv_desp_terc_781.tip_despesa, lr_cdv_desp_terc_781.ativ)
              LET l_atividade = cdv2012_busca_atividade(lr_cdv_desp_terc_781.ativ)
              PRINT COLUMN 001, l_despesa CLIPPED,
                    COLUMN 032, l_atividade[1,43],
                    COLUMN 081, lr_cdv_desp_terc_781.nota_fiscal USING "#######&",
                    COLUMN 090, lr_cdv_desp_terc_781.dat_inclusao,
                    COLUMN 101, lr_cdv_desp_terc_781.val_desp_terceiro USING "###,###,##&.&&"

              LET l_tot_desp_terc = l_tot_desp_terc + lr_cdv_desp_terc_781.val_desp_terceiro

              PRINT COLUMN 001, "FORNECEDOR: ",
                                lr_cdv_desp_terc_781.fornecedor,
                    COLUMN 035, "DATA VENC: ", lr_cdv_desp_terc_781.dat_vencto

              #IF l_cont = l_qtd_desp_terc THEN

                 LET l_num_ap = cdv2012_busca_numero_ap(lr_cdv_desp_terc_781.ad_terceiro)
                 PRINT COLUMN 045, "AD: ", lr_cdv_desp_terc_781.ad_terceiro USING "#####&",
                       COLUMN 094, "TOTAL: ", l_tot_desp_terc USING "###,###,##&.&&"
                 PRINT COLUMN 045, "AP: ", l_num_ap USING "#####&"
                 SKIP 1 LINE
              #END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_desp_terc_7812
           WHENEVER ERROR STOP

           WHENEVER ERROR CONTINUE
           DECLARE cq_viagem_origem CURSOR FOR
            SELECT UNIQUE viagem_origem
              FROM cdv_desp_terc_781
             WHERE empresa = p_cod_empresa
               AND viagem  = lr_solic.viagem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","CQ_VIAGEM_ORIGEM")
              LET m_houve_erro = TRUE
           END IF

           LET l_ind = 1
           WHENEVER ERROR CONTINUE
           FOREACH cq_viagem_origem INTO l_viagem_origem
           WHENEVER ERROR STOP

              IF sqlca.sqlcode <> 0 THEN
              END IF

              PRINT COLUMN 001, "OBS: ESTA VIAGEM POSSUI COMO ORIGEM A VIAGEM ", l_viagem_origem
              EXIT FOREACH

           END FOREACH

        END IF

        WHENEVER ERROR CONTINUE
        DECLARE cq_viagem CURSOR FOR
         SELECT UNIQUE viagem
           FROM cdv_desp_terc_781
          WHERE empresa = p_cod_empresa
            AND viagem_origem  = lr_solic.viagem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("DECLARE","CQ_VIAGEM")
           LET m_houve_erro = TRUE
        END IF

        WHENEVER ERROR CONTINUE
        FOREACH cq_viagem INTO l_viagem_origem
        WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
           END IF

           PRINT COLUMN 001, "OBS: ESTA VIAGEM EH A ORIGEM DA VIAGEM ", l_viagem_origem
           EXIT FOREACH

        END FOREACH

        WHENEVER ERROR CONTINUE
        SELECT COUNT(*)
          INTO l_qtd_apont
          FROM cdv_apont_hor_781, cdv_tdesp_viag_781
         WHERE cdv_apont_hor_781.empresa             = p_cod_empresa
           AND cdv_apont_hor_781.viagem              = lr_solic.viagem
           AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
           AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_apont_hor_781.tdesp_apont_hor
           AND cdv_tdesp_viag_781.eh_reembolso       = "S"
           AND cdv_tdesp_viag_781.ativ               = cdv_apont_hor_781.ativ #OS462484
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("SELECT","CDV_APONT_HOR_781")
           LET m_houve_erro = TRUE
        END IF

        IF l_qtd_apont IS NULL THEN
           LET l_qtd_apont = 0
        END IF

        IF l_qtd_apont > 0 THEN
           WHENEVER ERROR CONTINUE
           DECLARE cq_apont_hor_7812 CURSOR FOR
           SELECT cdv_apont_hor_781.empresa,       cdv_apont_hor_781.viagem,
                  cdv_apont_hor_781.seq_apont_hor, cdv_apont_hor_781.tdesp_apont_hor,
                  cdv_apont_hor_781.hor_inicial,   cdv_apont_hor_781.hor_final,
                  cdv_apont_hor_781.motivo,        cdv_apont_hor_781.hor_diurnas,
                  cdv_apont_hor_781.hor_noturnas,  cdv_apont_hor_781.dat_apont_hor,
                  cdv_apont_hor_781.obs_apont_hor
             FROM cdv_apont_hor_781, cdv_tdesp_viag_781
            WHERE cdv_apont_hor_781.empresa             = p_cod_empresa
              AND cdv_apont_hor_781.viagem              = lr_solic.viagem
              AND cdv_tdesp_viag_781.empresa            = p_cod_empresa
              AND cdv_tdesp_viag_781.tip_despesa_viagem = cdv_apont_hor_781.tdesp_apont_hor
              AND cdv_tdesp_viag_781.eh_reembolso       = "S"
              AND cdv_tdesp_viag_781.ativ               = cdv_apont_hor_781.ativ #OS462484
            ORDER BY cdv_apont_hor_781.seq_apont_hor
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("DECLARE","cq_apont_hor_7812")
              LET m_houve_erro = TRUE
           END IF

           SKIP 1 LINES
           PRINT COLUMN 001, log5211_negrito("ATIVA") CLIPPED
           PRINT COLUMN 001, "============================================== APONTAMENTO DE HORAS ==============================================",
                             log5211_negrito("DESATIVA") CLIPPED
           PRINT COLUMN 001, "                                     HORA     HORA                                               QTD        QTD   "
           PRINT COLUMN 001, "ATIVIDADE                            INICIAL  FIM      MOTIVO                         DATA       HOR.DIU. HOR.NOT "
           PRINT COLUMN 001, "------------------------------------ -------- -------- ------------------------------ ---------- -------- --------"

           LET l_cont      = 0
           WHENEVER ERROR CONTINUE
           FOREACH cq_apont_hor_7812 INTO lr_cdv_apont_hor_781.*
           WHENEVER ERROR STOP
              IF SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("FOREACH","CQ_APONT_HOR_7812")
                 EXIT FOREACH
              END IF

              LET l_cont = l_cont + 1
              CALL cdv2012_busca_dados(lr_cdv_apont_hor_781.tdesp_apont_hor, lr_cdv_apont_hor_781.motivo)
                   RETURNING l_atividade, l_des_motivo

              PRINT COLUMN 001, l_atividade[1,36],
                    COLUMN 038, lr_cdv_apont_hor_781.hor_inicial,
                    COLUMN 047, lr_cdv_apont_hor_781.hor_final,
                    COLUMN 056, l_des_motivo CLIPPED,
                    COLUMN 087, lr_cdv_apont_hor_781.dat_apont_hor,
                    COLUMN 098, lr_cdv_apont_hor_781.hor_diurnas,
                    COLUMN 107, lr_cdv_apont_hor_781.hor_noturnas
              IF l_cont = l_qtd_apont THEN
#                 PRINT COLUMN 001, "=================================================================================================================="
#                 PRINT COLUMN 001, "OBSERVACOES: ",
              END IF
           END FOREACH
           WHENEVER ERROR CONTINUE
           FREE cq_apont_hor_7812
           WHENEVER ERROR STOP
        END IF

     ON LAST ROW
        LET m_last_row = TRUE

     PAGE TRAILER
        IF m_last_row = TRUE THEN
           LET l_num_ap = cdv2012_busca_numero_ap(l_num_ad)
           PRINT COLUMN 001, "------------------------     ------------------------     ------------------------     ------------------------"
           PRINT COLUMN 001, "  ASS. COLABORADOR             VISTO CHEFIA                    SERVICOS ADM./FAT             AUTORIZADO        "
           PRINT COLUMN 001, "                                                            AD ACERTO: ", l_num_ad USING "#####&"
           PRINT COLUMN 001, "                                                            AP ACERTO: ", l_num_ap USING "#####&"
           PRINT COLUMN 001, "------------------------------------------------------------------------------------------------ VIA FATURAMENTO -"
        ELSE
           PRINT ""
           PRINT ""
           PRINT ""
           PRINT ""
           PRINT ""
        END IF

END REPORT

#------------------------------------------#
 FUNCTION cdv2012_busca_viajante(l_viajante)
#------------------------------------------#
   DEFINE l_viajante        INTEGER,
          l_nom_funcionario LIKE usuarios.nom_funcionario
   DEFINE l_cod_funcio     LIKE cdv_fornecedor_fun.cod_funcio,
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
       INTO l_nom_funcionario
       FROM fornecedor
      WHERE cod_fornecedor = l_cod_fornecedor
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        INITIALIZE l_nom_funcionario TO NULL
     END IF
  END IF

  RETURN l_nom_funcionario

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2012_busca_cc(l_cod_centro_custo)
#--------------------------------------------#
  DEFINE l_cod_centro_custo   LIKE cad_cc.cod_cent_cust,
         l_nom_cent_cust      LIKE cad_cc.nom_cent_cust,
         l_cod_emp_plano      LIKE empresa.cod_empresa

  WHENEVER ERROR CONTINUE
   SELECT cod_empresa_plano
     INTO l_cod_emp_plano
     FROM par_con
    WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP

  IF SQLCA.sqlcode <> 0 THEN
     INITIALIZE l_cod_emp_plano TO NULL
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
          WHERE cod_empresa      = l_cod_emp_plano
            AND cod_cent_cust    = l_cod_centro_custo
            AND ies_cod_versao   = 0
        WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
           RETURN ''
        ELSE
           RETURN l_nom_cent_cust
        END IF

     WHEN 0
        RETURN l_nom_cent_cust
     OTHERWISE
        CALL log003_err_sql('SELECAO','cad_cc2')
        RETURN ''
  END CASE

 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2012_busca_nom_cliente(l_cliente)
#--------------------------------------------#
   DEFINE l_cliente       CHAR(15),
          l_nom_cliente   CHAR(36)

  WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = l_cliente
  WHENEVER ERROR STOP

  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN l_nom_cliente
     WHEN 100
        RETURN ''
     OTHERWISE
        CALL log003_err_sql('SELECT','clientes')
        RETURN ''
  END CASE

 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2012_busca_den_empresa(l_empresa)
#--------------------------------------------#
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

#----------------------------------------------#
 FUNCTION cdv2012_busca_finalidade(l_finalidade)
#----------------------------------------------#
 DEFINE l_finalidade     LIKE cdv_finalidade_781.finalidade,
        l_des_finalidade LIKE cdv_finalidade_781.des_finalidade

 WHENEVER ERROR CONTINUE
 SELECT des_finalidade
   INTO l_des_finalidade
   FROM cdv_finalidade_781
  WHERE finalidade = l_finalidade
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_des_finalidade TO NULL
 END IF

 RETURN l_des_finalidade
 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2012_busca_tipo_despesa(l_tip_desp, l_ativ)
#------------------------------------------------------#
 DEFINE l_tip_desp   LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_ativ       LIKE cdv_tdesp_viag_781.ativ,
        l_despesa    LIKE cdv_tdesp_viag_781.des_tdesp_viagem

 WHENEVER ERROR CONTINUE
 SELECT des_tdesp_viagem
   INTO l_despesa
   FROM cdv_tdesp_viag_781
  WHERE empresa            = p_cod_empresa
    AND tip_despesa_viagem = l_tip_desp
    AND ativ               = l_ativ
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_despesa TO NULL
 END IF

 RETURN l_despesa
 END FUNCTION

#---------------------------------------#
 FUNCTION cdv2012_busca_atividade(l_ativ)
#---------------------------------------#
 DEFINE l_ativ     LIKE cdv_ativ_781.ativ,
        l_des_ativ LIKE cdv_ativ_781.des_ativ

 WHENEVER ERROR CONTINUE
 SELECT des_ativ
   INTO l_des_ativ
   FROM cdv_ativ_781
  WHERE ativ = l_ativ
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_des_ativ TO NULL
 END IF

 RETURN l_des_ativ
 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2012_busca_dados(l_tip_desp, l_motivo)
#-------------------------------------------------#
 DEFINE l_tip_desp   LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
        l_des_ativ   LIKE cdv_ativ_781.des_ativ,
        l_motivo     LIKE cdv_motivo_hor_781.motivo,
        l_des_motivo LIKE cdv_motivo_hor_781.des_motivo

 WHENEVER ERROR CONTINUE
 SELECT cdv_ativ_781.des_ativ
   INTO l_des_ativ
   FROM cdv_ativ_781,  cdv_tdesp_viag_781
  WHERE cdv_tdesp_viag_781.empresa            = p_cod_empresa
    AND cdv_tdesp_viag_781.tip_despesa_viagem = l_tip_desp
    AND cdv_tdesp_viag_781.grp_despesa_viagem = 5
    AND cdv_ativ_781.ativ                     = cdv_tdesp_viag_781.ativ #OS452484
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_des_ativ TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT des_motivo
   INTO l_des_motivo
   FROM cdv_motivo_hor_781
  WHERE motivo = l_motivo
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_des_motivo TO NULL
 END IF

 RETURN l_des_ativ, l_des_motivo
 END FUNCTION

#----------------------#
 FUNCTION cdv2012_help()
#----------------------#
 CASE
    WHEN INFIELD (tipo_impressao) CALL SHOWHELP(101)
 END CASE
 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2012_busca_numero_ap(l_ad)
#-------------------------------------#
 DEFINE l_ad    LIKE ad_ap.num_ad,
        l_ap    LIKE ad_ap.num_ap

 WHENEVER ERROR CONTINUE
 DECLARE cq_ad_ap CURSOR FOR
 SELECT num_ap
   FROM ad_ap
  WHERE cod_empresa = p_cod_empresa
    AND num_ad      = l_ad
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_AD_AP")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_ad_ap INTO l_ap
 WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_AD_AP")
       EXIT FOREACH
    END IF
    EXIT FOREACH
 END FOREACH
 WHENEVER ERROR CONTINUE
 FREE cq_ad_ap
 WHENEVER ERROR STOP

 RETURN l_ap
 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2012_busca_dados_viag(l_viagem)
#------------------------------------------#
 DEFINE l_viagem        LIKE cdv_dev_transf_781.viagem,
        l_viagem_rec    LIKE  cdv_dev_transf_781.viagem_receb,
        l_controle_rec  LIKE  cdv_dev_transf_781.controle_receb

 WHENEVER ERROR CONTINUE
 SELECT viagem_receb,
        controle_receb
   INTO l_viagem_rec,
        l_controle_rec
   FROM cdv_dev_transf_781
  WHERE empresa   = p_cod_empresa
    AND viagem    = l_viagem
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_viagem_rec, l_controle_rec TO NULL
 END IF

 RETURN l_viagem_rec, l_controle_rec
 END FUNCTION


#---------------------------------------------#
 FUNCTION cdv2012_busca_status_viagem(l_status)
#---------------------------------------------#
 DEFINE l_status           CHAR(01)

 CASE l_status
    WHEN '1'
       RETURN 'PENDENTE'
    WHEN '2'
       RETURN 'ACERTO DE DESPESA INICIADO'
    WHEN '3'
       RETURN 'ACERTO DE DESPESA FINALIZADO'
    WHEN '4'
       RETURN 'ACERTO DE DESPESA LIBERADO'
    OTHERWISE
       RETURN 'STATUS NAO CADASTRADO'
 END CASE

 END FUNCTION

#-------------------------------#
 FUNCTION cdv2012_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv2012.4gl $|$Revision: 2 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION