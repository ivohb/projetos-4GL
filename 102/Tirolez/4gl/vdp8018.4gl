#------------------------------------------------------------------------------#
# SISTEMA.: VENDA DISTRIBUICAO DE PRODUTOS                                     #
# PROGRAMA: VDP8018                                                            #
# MODULOS.: VDP8018 - LOG0010 - LOG0030 - LOG0040 - LOG0050                    #
#           LOG0060 - LOG1300 - LOG1400                                        #
# OBJETIVO: CANCELAMENTO DE ORDEM DE MONTAGEM                                  #
# AUTOR...: MARCIO KLAHR                                                       #
# DATA....: 27/07/1992                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_om_grade              RECORD LIKE ordem_montag_grade.*,
         p_om_mest               RECORD LIKE ordem_montag_mest.*,
         p_om_mestr              RECORD LIKE ordem_montag_mest.*,
         p_om_item               RECORD LIKE ordem_montag_item.*,
         p_om_itemr              RECORD LIKE ordem_montag_item.*,
         p_prest_cta_r           RECORD LIKE prest_cta_retorno.*,
         p_par_prest_contas      RECORD LIKE par_prest_contas.*,
         p_ped_itens_bnf         RECORD LIKE ped_itens_bnf.*,
         p_estrutura_vdp         RECORD LIKE estrutura_vdp.*,
         p_ped_itens             RECORD LIKE ped_itens.*,
         p_estoque               RECORD LIKE estoque.*,
         p_estoque_trans         RECORD LIKE estoque_trans.*,
         p_estoque_trans_end     RECORD LIKE estoque_trans_end.*,
         p_cod_tip_carteira      LIKE usuario_carteira.cod_tip_carteira,
         p_montag_coletor        LIKE tipo_carteira.ies_montag_coletor,
         p_qtd_reservar          LIKE ordem_montag_item.qtd_reservada,
         p_ies_tip_controle      LIKE nat_operacao.ies_tip_controle,
         p_num_inicio            LIKE ordem_montag_mest.num_om,
         p_num_fim               LIKE ordem_montag_mest.num_om,
         p_num_om                LIKE ordem_montag_mest.num_om,
         p_cod_local             LIKE pedidos.cod_local_estoq,
         p_cod_empresa           LIKE empresa.cod_empresa,
         p_den_empresa           LIKE empresa.den_empresa,
         p_par_vdp_txt           LIKE par_vdp.par_vdp_txt,
         p_user                  LIKE usuario.nom_usuario,
         p_cod_movto_estoq       LIKE nat_operacao.cod_movto_estoq,
         p_ies_ctr_estoque       CHAR(0001),
         p_cod_est_tran_ent      CHAR(0004),
         p_cod_est_tran_sai      CHAR(0004),
         p_ies_opera_estoq       CHAR(0001),
         p_ies_uti_end_vol       CHAR(0001),
         sql_stmt                CHAR(1000),
         p_comando               CHAR(0100),
         p_caminho               CHAR(0080),
         p_nom_tela              CHAR(0080),
         p_msg                    CHAR(300),
         p_help                  CHAR(0080),
         p_par_ies               CHAR(01),
         p_houve_erro            SMALLINT,
         p_ies_cons, p_last_row  SMALLINT,
         p_count                 SMALLINT,
         p_ies_parametros        SMALLINT,
         pa_curr                 SMALLINT,
         sc_curr                 SMALLINT,
         p_status                SMALLINT,
         p_cancel                INTEGER,
         p_dat_ini               DATE,
         p_dat_fim               DATE,
         m_par                   SMALLINT

  DEFINE p_tela                  RECORD
                                   num_lote_ini     LIKE ordem_montag_mest.num_lote_om,
                                   num_lote_fim     LIKE ordem_montag_mest.num_lote_om,
                                   num_inicial      LIKE ordem_montag_mest.num_om,
                                   num_final        LIKE ordem_montag_mest.num_om,
                                   data_inicial     DATE,
                                   data_final       DATE,
                                   cod_tip_carteira LIKE pedidos.cod_tip_carteira
                                 END RECORD

  DEFINE p_wvdp8018        RECORD
         cod_empresa        CHAR(02),
         num_om             DECIMAL(06,0),
         nom_usuario        CHAR(20)
                           END RECORD

DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

  DEFINE m_om_lote                SMALLINT ,
         m_carteira_om            LIKE pedidos.cod_tip_carteira,
         m_carteira_usuario       LIKE usuario_carteira.cod_tip_carteira,
         m_cancelou               SMALLINT

{   OS 98653 - INICIO   }
   DEFINE m_txt_audit_vdp LIKE audit_vdp.texto, m_brancos CHAR(50)
{   OS 98653 - FINAL   }

DEFINE mr_audit_logix            RECORD LIKE audit_logix.*

DEFINE p_vdp4258                 SMALLINT

MAIN

     CALL log0180_conecta_usuario()

 LET p_versao = "VDP8018-10.02.03"
 WHENEVER ANY ERROR CONTINUE
 CALL log1400_isolation()
 SET LOCK MODE TO WAIT 600
 WHENEVER ERROR STOP
 DEFER INTERRUPT

 CALL log140_procura_caminho("VDP8018.IEM") RETURNING p_caminho
 LET p_help = p_caminho CLIPPED
 OPTIONS
   HELP    FILE p_help

 CALL log001_acessa_usuario("VDP","LOGERP")
      RETURNING p_status, p_cod_empresa, p_user
  #ANDREI - ALTERACAO
     IF num_args() > 0 THEN
        LET p_vdp4258         = arg_val(1)
     END IF
     IF p_vdp4258 = 1 THEN
         LET m_par = 0
         CALL   vdp8018_processa_cancelamento()
     END IF
# ANDREI - ALTERACAO
  IF   p_status = 0 AND p_vdp4258 <> 1 THEN
   {IF p_vdp4258 = 1 THEN
      CLOSE WINDOW w_vdp8018
      CALL log120_procura_caminho("VDP4258") RETURNING p_comando
      LET p_comando = p_comando CLIPPED
      RUN p_comando RETURNING p_cancel RETURN
   END IF  }
   CALL vdp8018_controle()
 END IF
END MAIN

#--------------------------#
 FUNCTION vdp8018_controle()
#--------------------------#
 INITIALIZE p_om_mest.* TO NULL

  SELECT * INTO p_par_prest_contas.*
    FROM par_prest_contas
   WHERE cod_empresa = p_cod_empresa

  IF  sqlca.sqlcode = NOTFOUND
  THEN INITIALIZE p_par_prest_contas.* TO NULL
  END IF

 CALL log006_exibe_teclas("01", p_versao)
 CALL log130_procura_caminho("VDP8018") RETURNING p_nom_tela
 OPEN WINDOW w_vdp8018 AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, COMMENT LINE LAST -1, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
 MENU "OPCAO"
   COMMAND "Informar"    "Informar parametros"
     HELP 009
     MESSAGE ""
     IF log005_seguranca(p_user,"VDP","VDP8018","MO")
     THEN IF vdp8018_informar()
          THEN NEXT OPTION "Processar"
          ELSE NEXT OPTION "Informar"
          END IF
     END IF
   COMMAND "Processar"    "Processa cancelamento Ordem de Montagem"
     HELP 010
     MESSAGE ""
     IF p_ies_parametros
     THEN CALL vdp8018_processa_cancelamento()
     ELSE ERROR "Informar par�metros"
          NEXT OPTION "Informar"
     END IF
     COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL vdp8018_sobre()
   COMMAND KEY ("!")
     PROMPT "Digite o comando : " FOR p_comando
     RUN p_comando
     PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
   COMMAND "Fim"        "Retorna ao Menu Anterior"
     HELP 008
     EXIT MENU
 END MENU
 CLOSE WINDOW w_vdp8018
END FUNCTION

#-----------------------#
 FUNCTION vdp8018_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION vdp8018_informar()
#--------------------------#
 INITIALIZE p_tela.* TO NULL

 DISPLAY BY NAME p_tela.*

 INPUT BY NAME p_tela.* WITHOUT DEFAULTS

   BEFORE FIELD num_lote_ini
      IF vdp8018_carteira_usuario() = FALSE THEN
         ERROR " Usu�rio sem carteira. "
         NEXT FIELD cod_tip_carteira
      ELSE
        DISPLAY m_carteira_usuario TO cod_tip_carteira
      END IF

   AFTER FIELD num_lote_ini
      IF p_tela.num_lote_ini IS NULL THEN
         LET p_tela.num_lote_fim = NULL
         DISPLAY BY NAME p_tela.num_lote_fim
         NEXT FIELD num_inicial
      END IF

   AFTER FIELD num_lote_fim
      IF p_tela.num_lote_ini IS NULL OR
         p_tela.num_lote_ini = ' ' THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_lote_ini
         ELSE
            NEXT FIELD num_inicial
         END IF
      END IF

      IF p_tela.num_lote_fim < p_tela.num_lote_ini THEN
         ERROR " N�mero de lote final menor que lote inicial. "
         NEXT FIELD num_lote_ini
      END IF

   BEFORE FIELD num_inicial
      IF p_tela.num_lote_ini IS NOT NULL THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_lote_ini
         ELSE
            NEXT FIELD cod_tip_carteira
         END IF
      END IF

      IF vdp8018_carteira_usuario() = FALSE THEN
         ERROR " Usu�rio sem carteira. "
         NEXT FIELD cod_tip_carteira
      ELSE
         DISPLAY m_carteira_usuario TO cod_tip_carteira
      END IF

   AFTER FIELD num_inicial
      IF p_tela.num_inicial IS NULL THEN
         LET p_tela.num_final = NULL
         DISPLAY BY NAME p_tela.num_final
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_lote_fim
         ELSE
            NEXT FIELD data_inicial
         END IF
      END IF

   AFTER FIELD num_final
      IF p_tela.num_inicial > p_tela.num_final THEN
         ERROR " N�mero final menor que inicial. "
         NEXT FIELD num_final
      END IF

      IF p_tela.num_final IS NOT NULL THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_inicial
         ELSE
            NEXT FIELD cod_tip_carteira
         END IF
      END IF

   BEFORE FIELD data_inicial
      IF p_tela.num_lote_ini IS NOT NULL THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_lote_ini
         ELSE
            NEXT FIELD cod_tip_carteira
         END IF
      ELSE
         IF p_tela.num_inicial IS NOT NULL THEN
            IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
                FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
               NEXT FIELD num_inicial
            ELSE
               NEXT FIELD cod_tip_carteira
            END IF
         END IF
      END IF

   AFTER FIELD data_inicial
      IF p_tela.data_inicial IS NULL THEN
         LET p_tela.data_final = NULL
         DISPLAY BY NAME p_tela.data_final
      END IF

   BEFORE FIELD data_final
      IF p_tela.data_inicial IS NULL THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_inicial
         ELSE
            NEXT FIELD cod_tip_carteira
         END IF
      END IF

   AFTER FIELD data_final
      IF p_tela.num_final    IS NOT NULL OR
         p_tela.num_lote_ini IS NOT NULL THEN
         IF (FGL_LASTKEY() = FGL_KEYVAL('UP') OR
             FGL_LASTKEY() = FGL_KEYVAL('LEFT'))  THEN
            NEXT FIELD num_inicial
         ELSE
            NEXT FIELD cod_tip_carteira
         END IF
      END IF

   BEFORE FIELD cod_tip_carteira
      IF p_tela.cod_tip_carteira IS NULL THEN
         CALL vdp8018_busca_carteira_usuario()
            RETURNING p_tela.cod_tip_carteira
         DISPLAY BY NAME p_tela.cod_tip_carteira
         IF p_tela.cod_tip_carteira IS NULL THEN
            LET int_flag = TRUE
         END IF
         ## Para n�o permitir informar a carteira ###
         EXIT INPUT
      END IF

      IF (p_tela.num_lote_ini  IS NULL OR
          p_tela.num_lote_ini  = ' ') AND
         (p_tela.num_lote_fim  IS NULL OR
          p_tela.num_lote_fim  = ' ') AND
         (p_tela.num_inicial   IS NULL OR
          p_tela.num_inicial   = ' ') AND
         (p_tela.num_final     IS NULL OR
          p_tela.num_final     = ' ') AND
         (p_tela.data_inicial  IS NULL OR
          p_tela.data_inicial  = ' ') AND
         (p_tela.data_final    IS NULL OR
          p_tela.data_final    = ' ') THEN
         ERROR ' Informe par�metros para sele��o das Ordens de Montagens/Romaneios. '
         NEXT FIELD num_lote_ini
      END IF

      IF (p_tela.num_lote_ini  IS NULL OR
          p_tela.num_lote_ini  = ' ') AND
         (p_tela.num_lote_fim  IS NULL OR
          p_tela.num_lote_fim  = ' ') AND
         (p_tela.num_inicial   IS NULL OR
          p_tela.num_inicial   = ' ') AND
         (p_tela.num_final     IS NULL OR
          p_tela.num_final     = ' ') THEN
          EXIT INPUT
      END IF

   AFTER FIELD cod_tip_carteira
      IF p_tela.cod_tip_carteira IS NOT NULL THEN
         IF vdp8018_verifica_carteira(p_tela.cod_tip_carteira) = FALSE THEN
            ERROR " C�digo Tipo Carteira n�o cadastrado. "
            NEXT FIELD cod_tip_carteira
         END IF
      ELSE
         ERROR " Informe o c�digo do Tipo de Carteira. "
         NEXT FIELD cod_tip_carteira
      END IF

      IF vdp8018_busca_carteira() = FALSE THEN
         ERROR " Carteira deve ser igual a Carteira da O.M. - ", m_carteira_om
         NEXT FIELD cod_tip_carteira
      END IF

      IF ((FGL_LASTKEY() = FGL_KEYVAL("UP")) OR
          (FGL_LASTKEY() = FGL_KEYVAL("LEFT"))) THEN
          IF p_tela.num_inicial IS NOT NULL THEN
             NEXT FIELD num_final
          ELSE
             NEXT FIELD data_final
          END IF
      END IF

   AFTER INPUT
     IF INT_FLAG = FALSE THEN
        IF p_tela.num_lote_ini > p_tela.num_lote_fim THEN
            ERROR " N�mero lote final menor que lote inicial. "
           NEXT FIELD num_lote_ini
        END IF

        IF p_tela.num_inicial > p_tela.num_final THEN
           ERROR " N�mero final menor que inicial. "
           NEXT FIELD num_inicial
        END IF

        IF p_tela.num_inicial IS NULL THEN
           IF p_tela.data_inicial IS NULL THEN
              ERROR " Data inicial n�o pode ser nula. "
              NEXT FIELD data_inicial
           END IF
           IF p_tela.data_final IS NULL THEN
              ERROR " Data final n�o pode ser nula. "
              NEXT FIELD data_final
           END IF

           IF p_tela.data_inicial > p_tela.data_final THEN
              ERROR " Data final menor que inicial. "
              NEXT FIELD data_final
           END IF
        END IF

        IF p_tela.cod_tip_carteira IS NULL THEN
           ERROR " Informe o c�digo do tipo de carteira. "
           NEXT FIELD cod_tip_carteira
        END IF
     END IF

   ON KEY (control-w)
   CALL vdp8018_help()

 END INPUT

 IF INT_FLAG THEN
    LET INT_FLAG = 0
    LET p_ies_parametros = FALSE
    CLEAR FORM
    RETURN FALSE
 ELSE
    LET p_ies_parametros = TRUE
    RETURN TRUE
 END IF

END FUNCTION

#----------------------------------#
 FUNCTION vdp8018_carteira_usuario()
#----------------------------------#
 DECLARE cq_usuario CURSOR FOR
 SELECT cod_tip_carteira
   FROM usuario_carteira
  WHERE cod_empresa = p_cod_empresa
    AND nom_usuario = p_user

 OPEN cq_usuario
 FETCH cq_usuario INTO m_carteira_usuario
 IF sqlca.sqlcode = 0 THEN
    LET p_tela.cod_tip_carteira = m_carteira_usuario
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION

#--------------------------------#
 FUNCTION vdp8018_busca_carteira()
#--------------------------------#
 DEFINE l_num_pedido    LIKE ordem_montag_item.num_pedido
 DEFINE sql_stmt_cart   CHAR(500)
 DEFINE l_num_ini       DECIMAL(6,0)
 DEFINE l_num_fim       DECIMAL(6,0)

 INITIALIZE sql_stmt_cart TO NULL

 {verifica qual dos filtros de tela que foram informados.}
 IF p_tela.num_inicial IS NULL THEN
    LET l_num_ini = p_tela.num_lote_ini
 ELSE
    LET l_num_ini = p_tela.num_inicial
 END IF

 {verifica qual dos filtros de tela que foram informados.}
 IF p_tela.num_final IS NULL THEN
    LET l_num_fim = p_tela.num_lote_fim
 ELSE
    LET l_num_fim = p_tela.num_final
 END IF

 IF p_tela.num_inicial > 0 THEN
    LET sql_stmt_cart =
    ' SELECT num_pedido ',
      ' FROM ordem_montag_item ',
     ' WHERE cod_empresa = "',p_cod_empresa,'" ',
       ' AND num_om     >= ',l_num_ini,' ',
       ' AND num_om     <= ',l_num_fim,' '
 ELSE
    LET sql_stmt_cart =
    ' SELECT ordem_montag_item.num_pedido ',
      ' FROM ordem_montag_item, ordem_montag_mest ',
     ' WHERE ordem_montag_mest.cod_empresa  = "',p_cod_empresa,'" ',
       ' AND ordem_montag_mest.num_lote_om >= ',l_num_ini,' ',
       ' AND ordem_montag_mest.num_lote_om <= ',l_num_fim,' ',
       ' AND ordem_montag_item.cod_empresa  = ordem_montag_mest.cod_empresa ',
       ' AND ordem_montag_item.num_om       = ordem_montag_mest.num_om '
 END IF

 PREPARE var_query_cart FROM sql_stmt_cart
 DECLARE cq_pedido CURSOR FOR var_query_cart
 OPEN cq_pedido
 FETCH cq_pedido INTO l_num_pedido

 IF sqlca.sqlcode = 0 THEN
    SELECT cod_tip_carteira
      INTO m_carteira_om
      FROM pedidos
     WHERE cod_empresa      = p_cod_empresa
       AND num_pedido       = l_num_pedido
    IF m_carteira_om <> p_tela.cod_tip_carteira THEN
       RETURN FALSE
    ELSE
       #LET p_tela.cod_tip_carteira = m_carteira_om
       RETURN TRUE
    END IF
 END IF
 RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION vdp8018_processa_cancelamento()
#---------------------------------------#
 INITIALIZE mr_audit_logix.*     TO NULL
 LET m_par = 1
 LET m_om_lote                   = FALSE
 LET mr_audit_logix.hora         = TIME
 LET mr_audit_logix.data         = TODAY
 LET mr_audit_logix.cod_empresa  = p_cod_empresa
 LET mr_audit_logix.usuario      = p_user
 LET mr_audit_logix.num_programa = "VDP8018"
 LET m_cancelou                  = FALSE

 IF p_vdp4258 = 1 THEN
 ELSE
    IF log004_confirm(15,43) THEN
    ELSE
       RETURN
    END IF
 END IF

 IF vdp8018_verifica_om() THEN
   CALL vdp8018_cancela_om()

        IF mr_audit_logix.texto IS NOT NULL THEN {-- Se gravou audit_logix --}
         CALL vdp8018_consulta_audit_logix()
        END IF

        IF p_houve_erro OR
           m_cancelou = FALSE THEN
             CALL log085_transacao("ROLLBACK")
        ELSE
             CALL log085_transacao("COMMIT")
                IF sqlca.sqlcode = 0 THEN
                  IF  m_om_lote = FALSE THEN
                      CALL log0030_mensagem("Cancelamento efetuado com sucesso", "info")
                  ELSE
                     CALL log0030_mensagem("Verificar numero do lote da O.M.", "info")
                  END IF
                ELSE
                  CALL log003_err_sql("CANCELAMENTO","ORDEM_MONTAG")
                  CALL log085_transacao("ROLLBACK")
                END IF
                IF p_vdp4258 = 1 THEN
                   CLOSE WINDOW w_vdp8018
                END IF
        END IF
 ELSE
        IF mr_audit_logix.texto IS NOT NULL THEN {-- Se gravou audit_logix --}
         CALL vdp8018_consulta_audit_logix()
        END IF
 END IF

END FUNCTION

#----------------------#
 FUNCTION vdp8018_help()
#----------------------#
 CASE
   WHEN INFIELD(num_lote_ini)      CALL SHOWHELP(101)
   WHEN INFIELD(num_lote_fim)      CALL SHOWHELP(102)
   WHEN INFIELD(num_inicial)       CALL SHOWHELP(103)
   WHEN INFIELD(num_final)         CALL SHOWHELP(104)
   WHEN INFIELD(data_inicial)      CALL SHOWHELP(105)
   WHEN INFIELD(data_final)        CALL SHOWHELP(106)
   WHEN INFIELD(cod_tip_carteira)  CALL SHOWHELP(107)
 END CASE
END FUNCTION

#-----------------------------#
 FUNCTION vdp8018_verifica_om()
#-----------------------------#
 DEFINE l_ies_sucesso_sql       SMALLINT,
        l_ies_om_enviada_wms    SMALLINT,
        l_num_om                DECIMAL(6,00)

 INITIALIZE sql_stmt TO NULL


IF p_vdp4258 <> 1 THEN
 LET sql_stmt =
    ' SELECT ordem_montag_mest.* FROM ordem_montag_mest ',
     ' WHERE cod_empresa = "',p_cod_empresa,'" '

 IF p_tela.num_inicial > 0 THEN
    LET sql_stmt = sql_stmt CLIPPED,
       ' AND ordem_montag_mest.num_om >= ',p_tela.num_inicial,' ',
       ' AND ordem_montag_mest.num_om <= ',p_tela.num_final,' '
 ELSE
    IF p_tela.num_lote_ini > 0 THEN
       LET sql_stmt = sql_stmt CLIPPED,
       ' AND ordem_montag_mest.num_lote_om >= ',p_tela.num_lote_ini,' ',
       ' AND ordem_montag_mest.num_lote_om <= ',p_tela.num_lote_fim,' '
    ELSE
       LET sql_stmt = sql_stmt CLIPPED,
       ' AND ordem_montag_mest.dat_emis   >= "',p_tela.data_inicial,'" ',
       ' AND ordem_montag_mest.dat_emis <= "',p_tela.data_final,'" '
    END IF
 END IF
ELSE
 LET sql_stmt = "SELECT ordem_montag_mest.* FROM wvdp8018, ordem_montag_mest ",
                "  WHERE wvdp8018.cod_empresa = """,p_cod_empresa,""" ",
                "  AND wvdp8018.nom_usuario = """,p_user,""" ",
                "  AND wvdp8018.num_om = ordem_montag_mest.num_om      ",
                "  AND ordem_montag_mest.cod_empresa = """,p_cod_empresa,""" "
END IF
 LET sql_stmt = sql_stmt CLIPPED
 PREPARE var_query FROM sql_stmt
 DECLARE cq_ordem_mont_ver CURSOR FOR var_query
 OPEN  cq_ordem_mont_ver
 FETCH cq_ordem_mont_ver INTO p_om_mest.*

 IF sqlca.sqlcode <> 0 THEN
    IF sqlca.sqlcode = NOTFOUND THEN
       CALL log0030_mensagem("Ordem de Montagem informada n�o existe.","info")
    ELSE
       CALL log003_err_sql("LEITURA","ORDEM_MONTAG_MEST")
    END IF
    RETURN FALSE
 END IF

 FOREACH cq_ordem_mont_ver INTO p_om_mest.*
   IF p_om_mest.ies_sit_om = "F" THEN
      IF p_vdp4258 = 1 THEN
         CLOSE WINDOW w_vdp8018
         {CALL log120_procura_caminho("VDP4258") RETURNING p_comando
         LET p_comando = p_comando CLIPPED
         RUN p_comando RETURNING p_cancel}RETURN
      END IF
      PROMPT " OM ",p_om_mest.num_om," j� Faturada. Tecle ENTER para continuar" FOR CHAR p_comando
      CONTINUE FOREACH
   END IF

{-- OS 95689 - Integracao LOGIX x WIS ----------------------------------------}

   IF vdp3188_wis_instalado(p_cod_empresa) THEN
      CALL vdp3188_om_enviada_ao_wis(p_cod_empresa, p_om_mest.num_om)
                    RETURNING l_ies_sucesso_sql, l_ies_om_enviada_wms
      IF l_ies_sucesso_sql THEN
         IF l_ies_om_enviada_wms THEN

            IF NOT vdp8018_insert_audit_logix(1) THEN
               RETURN FALSE
            END IF

            CONTINUE FOREACH
         END IF
      ELSE
        RETURN FALSE
      END IF
   ELSE

     {-- OS 118709 - Integracao LOGIX-ERP <<-->> LOGIX-WMS -------------}
     IF wms0004_wms_instalado(p_cod_empresa) THEN
        CALL wms0004_om_enviada_ao_wms(p_cod_empresa, p_om_mest.num_om)
                      RETURNING l_ies_sucesso_sql, l_ies_om_enviada_wms
        IF l_ies_sucesso_sql THEN
           IF l_ies_om_enviada_wms THEN

              IF NOT vdp8018_insert_audit_logix(2) THEN
                 RETURN FALSE
              END IF

              CONTINUE FOREACH
           END IF
        ELSE
          RETURN FALSE
        END IF
     END IF

   END IF
 {-----------------------------------------------------------------------------}

   DECLARE cl_ped1 CURSOR FOR
   SELECT num_pedido INTO p_om_item.num_pedido
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_om_mest.num_om
    ORDER BY num_pedido DESC

   FOREACH cl_ped1 INTO p_om_item.num_pedido

      EXIT FOREACH

   END FOREACH


   SELECT cod_tip_carteira INTO p_cod_tip_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_om_item.num_pedido

   IF sqlca.sqlcode <> 0 THEN
    PROMPT " N�o Encontrou o Pedido da OM ",p_om_mest.num_om," \nTecle ENTER para continuar" FOR CHAR p_comando
        RETURN FALSE
   END IF

   SELECT par_ies
     INTO p_par_ies
     FROM par_vdp_pad
    WHERE par_vdp_pad.cod_empresa   = p_cod_empresa
      AND par_vdp_pad.cod_parametro = "cancela_om_lote"

   IF p_par_ies = "N" THEN
     IF p_om_mest.num_lote_om > 0 THEN
       LET m_om_lote = TRUE
       PROMPT " OM ",p_om_mest.num_om," em lote ", p_om_mest.num_lote_om,
              " n�o pode ser cancelada.\nTecle ENTER para continuar" FOR CHAR p_comando
     END IF
   END IF

   IF p_tela.cod_tip_carteira IS NOT NULL AND
      p_tela.cod_tip_carteira <> " "
   THEN IF p_cod_tip_carteira <> p_tela.cod_tip_carteira
        THEN CONTINUE FOREACH
        END IF
   END IF

   SELECT * FROM usuario_carteira
    WHERE nom_usuario      = p_user
      AND cod_tip_carteira = p_cod_tip_carteira
      AND cod_empresa      = p_cod_empresa

   IF sqlca.sqlcode = 0 THEN
   ELSE PROMPT " Usu�rio n�o autorizado a cancelar a OM ",p_om_mest.num_om,"\nTecle ENTER para continuar\nTecle ENTER para continuar" FOR CHAR p_comando
       IF p_vdp4258 = 1 THEN
          CLOSE WINDOW w_vdp8018
         { CALL log120_procura_caminho("VDP4258") RETURNING p_comando
          LET p_comando = p_comando CLIPPED
          RUN p_comando RETURNING p_cancel} RETURN
       ELSE
          CONTINUE FOREACH
       END IF
   END IF

   LET p_num_om = NULL

   SELECT UNIQUE num_om INTO p_num_om
     FROM relac_conteudo
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_om_mest.num_om

   IF sqlca.sqlcode = 0
   THEN IF p_num_om IS NOT NULL
        THEN PROMPT " OM ",p_om_mest.num_om," com rela��o de conte�do \nTecle ENTER para continuar" FOR CHAR p_comando
             RETURN FALSE
        END IF
   END IF
   RETURN TRUE
 END FOREACH
 RETURN TRUE
END FUNCTION

#---------------------------------------------#
 FUNCTION vdp8018_insert_audit_logix(l_sistema)
#---------------------------------------------#
 DEFINE l_sistema              SMALLINT

 IF l_sistema = 1 THEN
    LET mr_audit_logix.texto = "OM ",p_om_mest.num_om USING "<<<<<<",
                               " j� enviada ao WIS - Cancelamento n�o permitido. "
 END IF
 IF l_sistema = 2 THEN
    LET mr_audit_logix.texto = "OM ",p_om_mest.num_om USING "<<<<<<",
                               " j� enviada ao WMS - Cancelamento n�o permitido. "
 END IF

 WHENEVER ERROR CONTINUE
 INSERT INTO audit_logix VALUES (mr_audit_logix.*)
 IF SQLCA.SQLCODE <> 0 THEN
   CALL log003_err_sql("INSERT","AUDIT_LOGIX")
   RETURN FALSE
 END IF
 WHENEVER ERROR STOP

 RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION vdp8018_consulta_audit_logix()
#-------------------------------------#
 CALL log120_procura_caminho("man4340") RETURNING p_comando

 LET p_comando = p_comando CLIPPED," ", mr_audit_logix.num_programa," ",
                                        mr_audit_logix.data," ",
                                        mr_audit_logix.hora," ",
                                        mr_audit_logix.usuario

  RUN p_comando RETURNING p_cancel

  LET p_cancel = p_cancel / 256
  IF  p_cancel = 0 THEN
    ELSE
    PROMPT "Tecle ENTER para continuar" FOR p_comando
  END IF

 END FUNCTION

#----------------------------#
 FUNCTION vdp8018_cancela_om()
#----------------------------#
 DEFINE l_ies_sucesso_sql       SMALLINT,
        l_ies_om_enviada_wms    SMALLINT

 CALL log085_transacao("BEGIN")

 SELECT par_vdp_txt INTO p_par_vdp_txt
   FROM par_vdp
  WHERE cod_empresa = p_cod_empresa

 IF sqlca.sqlcode = NOTFOUND
 THEN PROMPT "PAR�METROS n�o cadastrados. Tecle ENTER." FOR p_comando
      LET p_houve_erro = TRUE
      RETURN
 ELSE LET p_ies_opera_estoq  = p_par_vdp_txt[157,157]
      LET p_cod_est_tran_sai = p_par_vdp_txt[164,167]
      LET p_cod_est_tran_ent = p_par_vdp_txt[160,163]
      LET p_ies_uti_end_vol  = p_par_vdp_txt[401,401]
      IF   p_ies_uti_end_vol IS NULL OR
           p_ies_uti_end_vol = " "
      THEN LET p_ies_uti_end_vol = "S"
      END IF
 END IF

 WHENEVER ERROR CONTINUE
 LET p_houve_erro = FALSE
 FOREACH cq_ordem_mont_ver INTO p_om_mest.*

   SELECT par_ies
     INTO p_par_ies
     FROM par_vdp_pad
    WHERE par_vdp_pad.cod_empresa   = p_cod_empresa
      AND par_vdp_pad.cod_parametro = "cancela_om_lote"

   IF p_par_ies = "N" THEN
     IF p_om_mest.num_lote_om > 0 THEN
       CONTINUE FOREACH
     END IF
   END IF

   IF p_om_mest.ies_sit_om = "F"
   THEN CONTINUE FOREACH
   END IF

   LET  p_num_om = p_om_mest.num_om

   DECLARE cl_ped2 CURSOR FOR
   SELECT num_pedido INTO p_om_item.num_pedido
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_om_mest.num_om
    ORDER BY num_pedido DESC

   FOREACH cl_ped2 INTO p_om_item.num_pedido

      EXIT FOREACH

   END FOREACH

   SELECT cod_tip_carteira INTO p_cod_tip_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_om_item.num_pedido

   IF sqlca.sqlcode <> 0
   THEN CONTINUE FOREACH
   END IF

   IF p_vdp4258 = 1 THEN
   ELSE
   IF p_tela.cod_tip_carteira IS NOT NULL AND
      p_tela.cod_tip_carteira <> " "
   THEN IF p_cod_tip_carteira <> p_tela.cod_tip_carteira
        THEN CONTINUE FOREACH
        END IF
   END IF
   END IF


   SELECT * FROM usuario_carteira
    WHERE nom_usuario      = p_user
      AND cod_tip_carteira = p_cod_tip_carteira
      AND cod_empresa      = p_cod_empresa

   IF sqlca.sqlcode = 0 THEN
   ELSE CONTINUE FOREACH
   END IF

 {-- OS 95689 - Integracao LOGIX x WIS ----------------------------------------}
   IF vdp3188_wis_instalado(p_cod_empresa) THEN
      CALL vdp3188_om_enviada_ao_wis(p_cod_empresa, p_num_om)
                    RETURNING l_ies_sucesso_sql, l_ies_om_enviada_wms
      IF l_ies_sucesso_sql THEN
         IF l_ies_om_enviada_wms THEN
            IF NOT vdp8018_insert_audit_logix(1) THEN
               LET p_houve_erro = TRUE
               RETURN
            END IF

            CONTINUE FOREACH

         END IF
      ELSE
        LET p_houve_erro = TRUE
        RETURN
      END IF

   ELSE

     {-- OS 118709 - Integracao LOGIX-ERP <<-->> LOGIX-WMS -------------}
     IF wms0004_wms_instalado(p_cod_empresa) THEN
        CALL wms0004_om_enviada_ao_wms(p_cod_empresa, p_num_om)
                      RETURNING l_ies_sucesso_sql, l_ies_om_enviada_wms
        IF l_ies_sucesso_sql THEN
           IF l_ies_om_enviada_wms THEN
              IF NOT vdp8018_insert_audit_logix(2) THEN
                 LET p_houve_erro = TRUE
                 RETURN
              END IF

              CONTINUE FOREACH

           END IF
        ELSE
          LET p_houve_erro = TRUE
          RETURN
        END IF
     END IF
   END IF

   IF vdp8018_verifica_solicit_fat() THEN
      MESSAGE "O.M. Nr. ", p_om_mest.num_om,
              " com Solicitacao de faturamento "  ATTRIBUTE(REVERSE)
      SLEEP 2
      CONTINUE FOREACH
   END IF

 {-----------------------------------------------------------------------------}

   SELECT ies_montag_coletor INTO p_montag_coletor
     FROM tipo_carteira
    WHERE cod_tip_carteira = p_cod_tip_carteira

   IF p_montag_coletor = "S"
   THEN IF p_om_mest.ies_sit_om <> "L" AND
           p_om_mest.ies_sit_om <> "N"
        THEN PROMPT " OM ",p_om_mest.num_om," n�o pode ser cancelado \nTecle ENTER para continuar" FOR CHAR p_comando
         IF p_vdp4258 = 1 THEN
            CLOSE WINDOW w_vdp8018
            {CALL log120_procura_caminho("VDP4258") RETURNING p_comando
            LET p_comando = p_comando CLIPPED
            RUN p_comando RETURNING p_cancel} RETURN
         END IF
             LET p_houve_erro = TRUE
             RETURN
        ELSE DELETE FROM ordem_montag_colet
              WHERE cod_empresa = p_cod_empresa
                AND num_om      = p_om_mest.num_om

             IF sqlca.sqlcode <> 0
             THEN CALL log003_err_sql("DELECAO","OM_COLET")
                  LET p_houve_erro = TRUE
                  RETURN
             END IF

             DELETE FROM ordem_montag_busca
              WHERE cod_empresa = p_cod_empresa
                AND num_om      = p_om_mest.num_om

             IF sqlca.sqlcode <> 0
             THEN CALL log003_err_sql("DELECAO","OM_BUSCA")
                  LET p_houve_erro = TRUE
                  RETURN
             END IF
        END IF
   END IF

{   OS 98653 - INICIO   }
   LET m_brancos = " "
   INITIALIZE m_txt_audit_vdp TO NULL
   IF NOT vdp8018_insert_audit_vdp("M") THEN
      RETURN
   END IF
{   OS 98653 - FINAL   }

   CALL vdp8018_retorna_reserva()

   IF p_houve_erro = FALSE THEN
   ELSE LET p_houve_erro = TRUE
        RETURN
   END IF

   CALL vdp8018_deleta_ordem_montagens()
   WHENEVER ERROR CONTINUE
   SELECT par_ies
     FROM par_vdp_pad
    WHERE cod_empresa = p_cod_empresa
     AND cod_parametro = 'ies_qea_instal'
     AND par_ies = 'S'
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      CALL vdp8018_deleta_qualidade() #OS 192396
   END IF

   IF p_houve_erro = FALSE THEN
   ELSE
    MESSAGE "O.M. Nr. ", p_om_mest.num_om, " NAO CANCELADA " ATTRIBUTE(REVERSE)
        CALL log003_err_sql("DELECAO","ORDEM_MONTAGEM")
        LET p_houve_erro = TRUE
        RETURN
   END IF

   DISPLAY "O.M. CANCELADA NUMERO - " AT 13,03
#4gl    DISPLAY p_om_mest.num_om           AT 13,27
#gen    ERROR p_om_mest.num_om #TECNOLOGIA - PROBLEMA DISPLAY AT
   LET m_cancelou = TRUE
 END FOREACH
 RETURN
 WHENEVER ERROR STOP
END FUNCTION

#--------------------------------------#
 FUNCTION vdp8018_verifica_solicit_fat()
#--------------------------------------#
  SELECT * FROM nf_solicit
   WHERE cod_empresa = p_cod_empresa
     AND num_om      = p_om_mest.num_om

  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

 END FUNCTION


#-----------------------------------------------------#
 FUNCTION vdp8018_verifica_carteira(p_cod_tip_carteira)
#-----------------------------------------------------#
 DEFINE p_cod_tip_carteira  LIKE tipo_carteira.cod_tip_carteira

 SELECT cod_tip_carteira
   FROM tipo_carteira
  WHERE cod_tip_carteira = p_cod_tip_carteira

 IF sqlca.sqlcode = 0
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF
END FUNCTION

#---------------------------------#
 FUNCTION vdp8018_retorna_reserva()
#---------------------------------#
 DEFINE p_qtd_reservada       LIKE estoque_loc_reser.qtd_reservada,
        p_qtd_refer_reserv    LIKE ordem_montag_itref.qtd_reservada,
        p_ped_itens1          RECORD LIKE ped_itens.*,
        p_ped_itens_bnf1      RECORD LIKE ped_itens_bnf.*,
        p_ped_itens_adic1     RECORD LIKE ped_itens_adic.*

 DEFINE l_qtd_reservada       LIKE ordem_montag_item.qtd_reservada

 DEFINE l_count               SMALLINT

 DECLARE cm_itens CURSOR FOR
  SELECT * FROM ordem_montag_item
   WHERE ordem_montag_item.cod_empresa = p_cod_empresa
     AND ordem_montag_item.num_om      = p_om_mest.num_om
 FOREACH cm_itens INTO p_om_item.*

    IF vdp8018_verifica_ped_item_comp() THEN
       CONTINUE FOREACH
    END IF

  {executa processo para tirar o status de OM do pedido do coletor
  conforme  OS 341649}
  WHENEVER ERROR CONTINUE

  SELECT vdp_pedido_575.pedido
    FROM vdp_pedido_575
   WHERE empresa = p_cod_empresa
     AND pedido = p_om_item.num_pedido

  WHENEVER ERROR STOP

  {se a tabela existe e o registro tamb�m, o programa ir� atualizar
  a situa��o do pedido para R}
  IF sqlca.sqlcode = 0 THEN

     UPDATE vdp_pedido_575
        SET sit_pedido = 'R'
      WHERE empresa = p_cod_empresa
        AND pedido = p_om_item.num_pedido

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("UPDATE","VDP_PEDIDO_575")
        LET p_houve_erro = TRUE
        RETURN
     END IF

     UPDATE ped_itens
        SET qtd_pecas_cancel = 0
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido = p_om_item.num_pedido
        AND num_sequencia = p_om_item.num_sequencia

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("UPDATE-575","PED_ITENS")
        LET p_houve_erro = TRUE
        RETURN
     END IF

     DELETE FROM ped_itens_cancel
      WHERE cod_empresa = p_cod_empresa
        AND num_pedido = p_om_item.num_pedido
        AND num_sequencia = p_om_item.num_sequencia

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DELETE-575","PED_ITENS_CANCEL")
        LET p_houve_erro = TRUE
        RETURN
     END IF
  END IF




{   OS 98653 - INICIO   }
   LET m_txt_audit_vdp =
     "      ITEM : ", p_om_item.cod_item, m_brancos[1,22],
     "QUANTIDADE : ", p_om_item.qtd_reservada USING "###,###,##&.&&&"

   IF NOT vdp8018_insert_audit_vdp("I") THEN
      RETURN
   END IF
{   OS 98653 - FINAL   }

   CALL vdp8018_verifica_ctr_estoque()

   IF p_ies_ctr_estoque = "S"
   THEN IF p_ies_tip_controle = "7"
        THEN CALL vdp8018_retorna_estoque_prest()
        ELSE DECLARE cq_estoque CURSOR FOR
              SELECT cod_item
                FROM estoque
               WHERE estoque.cod_empresa = p_cod_empresa
                 AND estoque.cod_item    = p_om_item.cod_item
                 FOR UPDATE
             OPEN cq_estoque
             FETCH cq_estoque INTO p_om_item.cod_item

             IF sqlca.sqlcode = 0
             THEN UPDATE estoque
                     SET qtd_reservada = qtd_reservada -  p_om_item.qtd_reservada
                   WHERE CURRENT OF cq_estoque

                  IF sqlca.sqlcode <> 0
                  THEN CALL log003_err_sql("UPDATE","ESTOQUE-1")
                       LET p_houve_erro = TRUE
                       RETURN
                  END IF
             ELSE CALL log003_err_sql("UPDATE","ESTOQUE-2")
                  LET p_houve_erro = TRUE
                  RETURN
             END IF

             SELECT COUNT(*)
               INTO l_count
               FROM ldi_est_comp_vdp
              WHERE empresa        = p_cod_empresa
                AND ord_montag     = p_om_item.num_om
                AND sequencia_item = p_om_item.num_sequencia
                AND pedido         = p_om_item.num_pedido

             IF l_count > 0 THEN
                IF vdp8018_retorna_comp_estr_vdp() AND
                   p_cod_movto_estoq <> ' '        AND
                   p_cod_movto_estoq IS NOT NULL   THEN
                   CALL vdp8018_movimenta_estoque(p_om_item.cod_item,
                                                 p_om_item.qtd_reservada,
                                                 "A")
                END IF
             ELSE
                IF vdp8018_verifica_item_compon() AND
                   p_cod_movto_estoq <> ' ' AND
                   p_cod_movto_estoq IS NOT NULL
                THEN CALL vdp8018_movimenta_estoque(p_om_item.cod_item,
                                                   p_om_item.qtd_reservada,
                                                   "A")
                END IF
             END IF
        END IF
#---------
        IF   p_ies_opera_estoq         = "S"   AND
             vdp8018_existe_om_grade() = FALSE THEN  #Qdo Grade movto abaixo.
             CALL vdp8018_busca_local_estoque()

             IF p_ies_tip_controle = '7' THEN
                LET l_qtd_reservada = (p_om_item.qtd_reservada -
                                       p_prest_cta_r.qtd_retornada)
             ELSE
                LET l_qtd_reservada = p_om_item.qtd_reservada
             END IF

             DECLARE cq_estoque_loc CURSOR FOR
              SELECT qtd_reservada INTO p_qtd_reservada
                FROM estoque_loc_reser
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item    = p_om_item.cod_item
                 AND cod_local   = p_cod_local
                 AND ies_origem  = "V"
                 AND qtd_reservada >= l_qtd_reservada
                 FOR UPDATE
             OPEN  cq_estoque_loc
             FETCH cq_estoque_loc
             IF sqlca.sqlcode = 0
             THEN IF p_ies_tip_controle = "7"
                  THEN LET  p_qtd_reservada = p_qtd_reservada -
                                            ( p_om_item.qtd_reservada  -
                                              p_prest_cta_r.qtd_retornada )
                  ELSE LET  p_qtd_reservada = p_qtd_reservada -
                                              p_om_item.qtd_reservada
                  END IF
                  UPDATE estoque_loc_reser
                     SET qtd_reservada = p_qtd_reservada
                   WHERE CURRENT OF cq_estoque_loc
                  IF sqlca.sqlcode <> 0
                  THEN CALL log003_err_sql("ATUALIZACAO", "ESTOQUE_LOC_RESER")
                       LET p_houve_erro = TRUE
                       RETURN
                  END IF
                  # nao deletar a estoque_loc_reser pois o cancelamento da nota
                  # precisa do registro na estoque_loc_reser (mesmo zerado) para
                  # poder somar a qtd na qtd_reservada
             ELSE CALL log003_err_sql("UPDATE","ESTOQUE-3")
                  LET p_houve_erro = TRUE
                  ERROR "Chave: Emp:",p_cod_empresa, " Item:",p_om_item.cod_item,
                  " Local:",p_cod_local," Origem:V"," Qtd:>=",p_om_item.qtd_reservada
                  RETURN
             END IF
        END IF
   END IF

   IF p_om_item.ies_bonificacao = "N"
   THEN DECLARE cm_ped_itens1 CURSOR FOR
          SELECT ped_itens.*
            FROM ped_itens
            WHERE ped_itens.cod_empresa   = p_cod_empresa
              AND ped_itens.num_pedido    = p_om_item.num_pedido
              AND ped_itens.num_sequencia = p_om_item.num_sequencia
              AND ped_itens.cod_item      = p_om_item.cod_item
            FOR UPDATE
        OPEN cm_ped_itens1
        FETCH cm_ped_itens1 INTO p_ped_itens1.*
        IF   sqlca.sqlcode = 0 THEN
        ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS")
             LET p_houve_erro = TRUE
             CLOSE cm_ped_itens1
             RETURN
        END IF
        UPDATE ped_itens
          SET ped_itens.qtd_pecas_romaneio = ped_itens.qtd_pecas_romaneio
                                           - p_om_item.qtd_reservada
          WHERE CURRENT OF cm_ped_itens1
        IF sqlca.sqlcode = 0 THEN
        ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS")
             LET p_houve_erro = TRUE
             CLOSE cm_ped_itens1
             RETURN
        END IF
        CLOSE cm_ped_itens1
        SELECT qtd_reservada INTO p_qtd_refer_reserv
          FROM ordem_montag_itref
         WHERE cod_empresa     = p_cod_empresa
           AND num_om          = p_om_item.num_om
           AND num_pedido      = p_om_item.num_pedido
           AND num_sequencia   = p_om_item.num_sequencia

        IF sqlca.sqlcode = NOTFOUND
        THEN LET p_qtd_refer_reserv = 0
        ELSE DECLARE cm_ped_itens_adic1 CURSOR FOR
               SELECT ped_itens_adic.*
                 FROM ped_itens_adic
                WHERE cod_empresa    = p_cod_empresa
                  AND num_pedido     = p_om_item.num_pedido
                  AND num_sequencia  = p_om_item.num_sequencia
                 FOR UPDATE
             OPEN cm_ped_itens_adic1
             FETCH cm_ped_itens_adic1 INTO p_ped_itens_adic1.*
             IF sqlca.sqlcode = 0 THEN
             ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS_ADIC")
                  LET p_houve_erro = TRUE
                  CLOSE cm_ped_itens_adic1
                  RETURN
             END IF
             UPDATE ped_itens_adic
               SET qtd_refer_romaneio  = qtd_refer_romaneio - p_qtd_refer_reserv
               WHERE CURRENT OF cm_ped_itens_adic1
             IF sqlca.sqlcode = 0 THEN
             ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS_ADIC")
                  LET p_houve_erro = TRUE
                  CLOSE cm_ped_itens_adic1
                  RETURN
             END IF
             CLOSE cm_ped_itens_adic1
        END IF
   ELSE DECLARE cm_ped_itens_bnf1 CURSOR FOR
          SELECT ped_itens_bnf.*
            FROM ped_itens_bnf
           WHERE ped_itens_bnf.cod_empresa   = p_cod_empresa
             AND ped_itens_bnf.num_pedido    = p_om_item.num_pedido
             AND ped_itens_bnf.num_sequencia = p_om_item.num_sequencia
             AND ped_itens_bnf.cod_item      = p_om_item.cod_item
            FOR UPDATE
        OPEN cm_ped_itens_bnf1
        FETCH cm_ped_itens_bnf1 INTO p_ped_itens_bnf1.*
        IF sqlca.sqlcode = 0 THEN
        ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS_BNF")
             LET p_houve_erro = TRUE
             CLOSE cm_ped_itens_bnf1
             RETURN
        END IF
        UPDATE ped_itens_bnf
          SET ped_itens_bnf.qtd_pecas_romaneio = ped_itens_bnf.qtd_pecas_romaneio
                                               - p_om_item.qtd_reservada
          WHERE CURRENT OF cm_ped_itens_bnf1
        IF sqlca.sqlcode = 0 THEN
        ELSE CALL log003_err_sql("ATUALIZACAO","PED_ITENS_BNF")
             LET p_houve_erro = TRUE
             CLOSE cm_ped_itens_bnf1
             RETURN
        END IF
        CLOSE cm_ped_itens_bnf1
   END IF

   IF vdp8018_verifica_om_grade() THEN
   ELSE RETURN
   END IF
 END FOREACH
END FUNCTION

#--------------------------------------#
 FUNCTION vdp8018_verifica_ctr_estoque()
#--------------------------------------#
 SELECT ies_ctr_estoque INTO p_ies_ctr_estoque
   FROM item
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = p_om_item.cod_item

 INITIALIZE p_cod_movto_estoq TO NULL

 SELECT nat_operacao.cod_movto_estoq,
        nat_operacao.ies_tip_controle
   INTO p_cod_movto_estoq,
        p_ies_tip_controle
   FROM nat_operacao,pedidos
  WHERE pedidos.cod_empresa       = p_cod_empresa
    AND pedidos.num_pedido        = p_om_item.num_pedido
    AND nat_operacao.cod_nat_oper = pedidos.cod_nat_oper

 IF (p_cod_movto_estoq IS NULL OR
     p_cod_movto_estoq = "    ") AND
     p_ies_tip_controle <> '1' AND
     p_ies_tip_controle <> '2'
 THEN LET p_ies_ctr_estoque = "N"
 END IF
END FUNCTION

#--------------------------------------#
 FUNCTION vdp8018_verifica_item_compon()
#--------------------------------------#
 DEFINE l_cod_local     LIKE pedidos.cod_local_estoq,
        l_qtd_reservada LIKE estoque.qtd_reservada

 DECLARE c_estrutura_vdp CURSOR FOR
  SELECT * INTO p_estrutura_vdp.*
    FROM estrutura_vdp
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_om_item.cod_item

 OPEN  c_estrutura_vdp
 FETCH c_estrutura_vdp
 IF sqlca.sqlcode = NOTFOUND
 THEN RETURN FALSE
 END IF

 FOREACH c_estrutura_vdp
      IF p_ies_tip_controle = '1' OR
         p_ies_tip_controle = '2' THEN
         LET l_qtd_reservada = p_om_item.qtd_reservada * p_estrutura_vdp.qtd_necessaria
         UPDATE estoque set qtd_reservada = qtd_reservada - l_qtd_reservada
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_estrutura_vdp.cod_item_compon

        IF p_ies_opera_estoq     = "S" THEN

           WHENEVER ERROR CONTINUE
           SELECT cod_local_estoq
             INTO l_cod_local
             FROM pedidos
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido  = p_om_item.num_pedido
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode = NOTFOUND THEN
              SELECT cod_local_estoq
                INTO l_cod_local
                FROM item
               WHERE cod_empresa = p_cod_empresa
                 AND cod_item    = p_estrutura_vdp.cod_item_compon
           END IF

           DECLARE cm_estoq_loc_reser CURSOR FOR
            SELECT estoque_loc_reser.cod_item
              FROM estoque_loc_reser
             WHERE estoque_loc_reser.cod_empresa = p_cod_empresa
               AND estoque_loc_reser.cod_item    = p_estrutura_vdp.cod_item_compon
               AND estoque_loc_reser.cod_local   = l_cod_local
               AND estoque_loc_reser.ies_origem  = "V"
               FOR UPDATE
          OPEN  cm_estoq_loc_reser
          FETCH cm_estoq_loc_reser INTO p_estrutura_vdp.cod_item_compon
          IF sqlca.sqlcode = 0 THEN

             UPDATE estoque_loc_reser
                SET estoque_loc_reser.qtd_reservada =
                    estoque_loc_reser.qtd_reservada - l_qtd_reservada
              WHERE CURRENT OF cm_estoq_loc_reser
             IF sqlca.sqlcode = 0 THEN
             ELSE
                LET p_houve_erro = TRUE
                CALL log003_err_sql("ATUALIZACAO","ESTOQ_LOC_RESERV")
             END IF
          ELSE
             INSERT INTO estoque_loc_reser VALUES (p_cod_empresa,0,
                                                   p_estrutura_vdp.cod_item,
                                                   l_cod_local,
                                                   l_qtd_reservada,"","V","","","N",
                                               "","","","",TODAY,"","",0,"")
             IF sqlca.sqlcode = 0 THEN
             ELSE
                LET p_houve_erro = TRUE
                CALL log003_err_sql("INCLUSAO","ESTOQ_LOC_RESERV")
             END IF
          END IF
        END IF
      ELSE
        CALL vdp8018_movimenta_estoque(p_estrutura_vdp.cod_item_compon,
                                      p_om_item.qtd_reservada *
                                      p_estrutura_vdp.qtd_necessaria,
                                      "C" )
      END IF
 END FOREACH
 RETURN TRUE
END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION vdp8018_movimenta_estoque(p_cod_item,p_qtd_movto,p_indic)
#-----------------------------------------------------------------#
 DEFINE p_estoque_operac                RECORD LIKE estoque_operac.*,
        p_estoque_obs                   RECORD LIKE estoque_obs.*,
        p_item                          RECORD LIKE item.*,
        p_cod_item                      LIKE item.cod_item,
        p_qtd_movto                     LIKE estoque_trans.qtd_movto,
        p_indic                         CHAR(01),
        p_valor1                        DECIMAL(15,3),
        p_valor2                        DECIMAL(15,3)

# ------- MOVIMENTA INFORMACOES PARA ESTOQUE_TRANS -------- #
 LET  p_estoque_trans.cod_empresa   = p_cod_empresa
 LET  p_estoque_trans.dat_movto     = TODAY
 LET  p_estoque_trans.dat_proces    = TODAY
 LET  p_estoque_trans.hor_operac    = TIME

 IF p_indic = "C" THEN
    LET p_estoque_trans.cod_operacao  = p_cod_est_tran_sai
 ELSE
    LET p_estoque_trans.cod_operacao  = p_cod_est_tran_ent
 END IF

 IF p_estoque_trans.cod_operacao IS NULL OR
    p_estoque_trans.cod_operacao = "    "
 THEN RETURN
 END IF

 SELECT * INTO p_estoque_operac.*
   FROM estoque_operac
  WHERE cod_operacao   = p_estoque_trans.cod_operacao
    AND cod_empresa    = p_cod_empresa

 IF sqlca.sqlcode = NOTFOUND THEN
      LET p_houve_erro = TRUE
      ERROR " Opera��o de estoque n�o cadastrada para o item. "
      RETURN
 END IF

 LET p_estoque_trans.ies_tip_movto = "R"

 SELECT * INTO p_item.*
   FROM item
  WHERE cod_item       = p_cod_item
    AND cod_empresa    = p_cod_empresa

 IF sqlca.sqlcode = NOTFOUND THEN
      LET p_houve_erro = TRUE
      ERROR " C�digo de produto n�o cadastrado. "
      RETURN
 END IF

 INITIALIZE p_estoque.* TO NULL

 SELECT * INTO p_estoque.*
   FROM estoque
  WHERE estoque.cod_empresa = p_cod_empresa
    AND estoque.cod_item    = p_cod_item

 IF sqlca.sqlcode = 0 THEN
 ELSE LET p_estoque.qtd_liberada  = 0
      LET p_estoque.qtd_lib_excep = 0
      LET p_estoque.qtd_reservada = 0
 END IF
# aqui - Ju
 LET p_estoque_obs.tex_observ = " Lib.: ",p_estoque.qtd_liberada CLIPPED,
                                " Movto: ",p_qtd_movto CLIPPED,
                                " Lib.Ex.: ",p_estoque.qtd_lib_excep CLIPPED
# fim - Ju
 LET p_estoque_trans.cod_item           = p_cod_item
 LET p_estoque_trans.num_transac        = "0"
 LET p_estoque_trans.num_prog           = "VDP8018"
 LET p_estoque_trans.num_docum          =  p_om_item.num_pedido
 LET p_estoque_trans.num_seq            =  NULL
 LET p_estoque_trans.cus_unit_movto_p   =  0
 LET p_estoque_trans.cus_tot_movto_p    =  0
 LET p_estoque_trans.cus_unit_movto_f   =  0
 LET p_estoque_trans.cus_tot_movto_f    =  0
 LET p_estoque_trans.num_conta          =  NULL
 LET p_estoque_trans.num_secao_requis   =  NULL
 LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
 LET p_estoque_trans.cod_local_est_dest =  NULL
 LET p_estoque_trans.num_lote_orig      =  NULL
 LET p_estoque_trans.num_lote_dest      =  NULL
 LET p_estoque_trans.ies_sit_est_dest   = " "
 LET p_estoque_trans.cod_turno          =  NULL
 LET p_estoque_trans.nom_usuario        = p_user

 IF (p_estoque_operac.ies_tipo     = "E"  AND
     p_estoque_trans.ies_tip_movto = "N") OR
    (p_estoque_operac.ies_tipo     = "S"  AND
     p_estoque_trans.ies_tip_movto = "R")
 THEN LET p_estoque_trans.qtd_movto = p_qtd_movto

      IF p_estoque_operac.ies_tipo = "E"
      THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
           LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
           LET p_estoque_trans.cod_local_est_orig = NULL
      ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
           LET p_estoque_trans.cod_local_est_dest = NULL
           LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
      END IF

      WHENEVER ERROR CONTINUE
      CALL vdp8018_carrega_estoque_trans_end()
      CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                p_estoque_trans_end.*,0) RETURNING p_status
      IF p_status = FALSE
      THEN LET p_houve_erro = TRUE
      END IF
 ELSE LET p_valor1 = p_estoque.qtd_liberada - p_qtd_movto

      IF p_valor1 >= 0
      THEN LET p_estoque_trans.qtd_movto = p_qtd_movto

           IF p_estoque_operac.ies_tipo = "E"
           THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                LET p_estoque_trans.cod_local_est_orig = NULL
           ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                LET p_estoque_trans.cod_local_est_dest = NULL
                LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
           END IF

           WHENEVER ERROR CONTINUE
           CALL vdp8018_carrega_estoque_trans_end()
           CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                     p_estoque_trans_end.*,0) RETURNING p_status
           IF p_status = FALSE
           THEN LET p_houve_erro = TRUE
           END IF
      ELSE IF p_estoque.qtd_liberada <= 0
           THEN IF p_estoque.qtd_lib_excep <= 0
                THEN LET p_estoque_trans.qtd_movto = p_valor1 * -1

                     IF p_estoque_operac.ies_tipo = "E"
                     THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                          LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                          LET p_estoque_trans.cod_local_est_orig = NULL
                     ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                          LET p_estoque_trans.cod_local_est_dest = NULL
                          LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                     END IF

                     WHENEVER ERROR CONTINUE
                     CALL vdp8018_carrega_estoque_trans_end()
                     CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                               p_estoque_trans_end.*, 0) RETURNING p_status
                     IF p_status = FALSE
                     THEN LET p_houve_erro = TRUE
                     END IF
                ELSE LET p_valor1 = p_qtd_movto - p_estoque.qtd_liberada
                     LET p_valor2 = p_estoque.qtd_lib_excep - p_valor1

                     IF p_valor2 >= 0
                     THEN LET p_estoque_trans.qtd_movto = p_valor1
                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "E"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "E"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF
                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                                    p_estoque_trans_end.*, 0) RETURNING p_status
                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF
                     ELSE LET  p_estoque_trans.qtd_movto = p_estoque.qtd_lib_excep

                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "E"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "E"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF

                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*,
                                                    p_estoque_obs.*,
                                                    p_estoque_trans_end.*,
                                                    0) RETURNING p_status
                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF

                          LET p_estoque_trans.qtd_movto = p_valor2 * -1
                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF

                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*,
                                                    p_estoque_obs.*,
                                                    p_estoque_trans_end.*,
                                                    0) RETURNING p_status
                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF
                     END IF
                END IF
           ELSE LET p_estoque_trans.qtd_movto = p_estoque.qtd_liberada
                IF p_estoque_operac.ies_tipo = "E"
                THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                     LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                     LET p_estoque_trans.cod_local_est_orig = NULL
                ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                     LET p_estoque_trans.cod_local_est_dest = NULL
                     LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                END IF

                WHENEVER ERROR CONTINUE
                CALL vdp8018_carrega_estoque_trans_end()
                CALL sup097_movto_estoque(p_estoque_trans.*,
                                          p_estoque_obs.*,
                                          p_estoque_trans_end.*,0) RETURNING p_status
                IF p_status = FALSE
                THEN LET p_houve_erro = TRUE
                END IF

                LET p_valor1 = p_qtd_movto - p_estoque.qtd_liberada
                LET p_valor2 = p_estoque.qtd_lib_excep - p_valor1

                IF p_valor2 >= 0
                THEN LET p_estoque_trans.qtd_movto = p_valor1

                     IF p_estoque_operac.ies_tipo = "E"
                     THEN LET p_estoque_trans.ies_sit_est_dest   = "E"
                          LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                          LET p_estoque_trans.cod_local_est_orig = NULL
                     ELSE LET p_estoque_trans.ies_sit_est_orig   = "E"
                          LET p_estoque_trans.cod_local_est_dest = NULL
                          LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                     END IF

                     WHENEVER ERROR CONTINUE
                     CALL vdp8018_carrega_estoque_trans_end()
                     CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                               p_estoque_trans_end.*,0) RETURNING p_status

                     IF p_status = FALSE
                     THEN LET p_houve_erro = TRUE
                     END IF
                ELSE IF p_estoque.qtd_lib_excep <= 0
                     THEN LET p_estoque_trans.qtd_movto = p_valor2 * -1
                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF

                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*,
                                                    p_estoque_obs.*,
                                                    p_estoque_trans_end.*,0) RETURNING p_status
                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF
                     ELSE LET p_estoque_trans.qtd_movto = p_estoque.qtd_lib_excep

                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "E"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "E"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF

                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                                    p_estoque_trans_end.*, 0) RETURNING p_status

                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF

                          LET p_estoque_trans.qtd_movto = p_valor2 * -1
                          IF p_estoque_operac.ies_tipo = "E"
                          THEN LET p_estoque_trans.ies_sit_est_dest   = "L"
                               LET p_estoque_trans.cod_local_est_dest = p_item.cod_local_estoq
                               LET p_estoque_trans.cod_local_est_orig = NULL
                          ELSE LET p_estoque_trans.ies_sit_est_orig   = "L"
                               LET p_estoque_trans.cod_local_est_dest = NULL
                               LET p_estoque_trans.cod_local_est_orig = p_item.cod_local_estoq
                          END IF

                          WHENEVER ERROR CONTINUE
                          CALL vdp8018_carrega_estoque_trans_end()
                          CALL sup097_movto_estoque(p_estoque_trans.*, p_estoque_obs.*,
                                                    p_estoque_trans_end.*,0) RETURNING p_status

                          IF p_status = FALSE
                          THEN LET p_houve_erro = TRUE
                          END IF
                     END IF
                END IF
           END IF
      END IF
 END IF
 WHENEVER ERROR STOP
END FUNCTION

#---------------------------------------#
 FUNCTION vdp8018_retorna_estoque_prest()
#---------------------------------------#
 DEFINE p_prest      SMALLINT

 LET p_prest_cta_r.qtd_retornada = 0
 LET p_prest = FALSE

 DECLARE cq_retorna CURSOR FOR
 SELECT *
   FROM prest_cta_retorno
  WHERE cod_empresa   = p_cod_empresa
    AND num_pedido    = p_om_item.num_pedido
    AND num_sequencia = p_om_item.num_sequencia
    AND cod_item      = p_om_item.cod_item
    AND num_om        = p_om_item.num_om
  FOREACH cq_retorna INTO p_prest_cta_r.*
      LET p_prest = TRUE
      UPDATE prest_cta_retorno SET num_om = 0
       WHERE prest_cta_retorno.cod_empresa   = p_cod_empresa
         AND prest_cta_retorno.num_pedido    = p_om_item.num_pedido
         AND prest_cta_retorno.num_sequencia = p_om_item.num_sequencia
         AND prest_cta_retorno.cod_item      = p_om_item.cod_item
         AND prest_cta_retorno.num_om        = p_om_item.num_om

     IF p_par_prest_contas.par_prt_cta_txt[139] = "S" AND
        p_par_prest_contas.par_prt_cta_txt[151] = "N" THEN
        LET p_prest_cta_r.qtd_retornada = 0
     END IF

    DECLARE cq_estoque1 CURSOR FOR
     SELECT cod_item
       FROM estoque
      WHERE estoque.cod_empresa = p_cod_empresa
        AND estoque.cod_item    = p_om_item.cod_item
        FOR UPDATE
    OPEN cq_estoque1
    FETCH cq_estoque1 INTO p_om_item.cod_item

    IF sqlca.sqlcode = 0
    THEN IF p_om_item.qtd_reservada >= p_prest_cta_r.qtd_retornada
         THEN UPDATE estoque SET qtd_reservada = qtd_reservada -
                           (p_om_item.qtd_reservada - p_prest_cta_r.qtd_retornada )
               WHERE CURRENT OF cq_estoque1
         ELSE UPDATE estoque SET qtd_reservada = qtd_reservada - p_om_item.qtd_reservada
               WHERE CURRENT OF cq_estoque1
         END IF

         IF sqlca.sqlcode <> 0
         THEN CALL log003_err_sql("UPDATE","ESTOQUE-4")
              LET  p_houve_erro = TRUE
              RETURN
         END IF
    END IF
  END FOREACH
  IF p_prest = FALSE THEN
    DECLARE cq_estoque2 CURSOR FOR
     SELECT cod_item
       FROM estoque
      WHERE estoque.cod_empresa = p_cod_empresa
        AND estoque.cod_item    = p_om_item.cod_item
        FOR UPDATE
    OPEN cq_estoque2
    FETCH cq_estoque2 INTO p_om_item.cod_item

    IF sqlca.sqlcode = 0
    THEN UPDATE estoque SET qtd_reservada = qtd_reservada -
                                            p_om_item.qtd_reservada
          WHERE CURRENT OF cq_estoque2

         IF sqlca.sqlcode <> 0
         THEN CALL log003_err_sql("UPDATE","ESTOQUE-5")
              LET  p_houve_erro = TRUE
              RETURN
         END IF
    END IF
  END IF
END FUNCTION

#-------------------------------------#
 FUNCTION vdp8018_busca_local_estoque()
#-------------------------------------#
 INITIALIZE p_cod_local TO NULL

 IF p_par_vdp_txt[492] = 'S' THEN
     LET p_cod_local = p_om_item.num_pedido USING "&&&&&&" CLIPPED,
                       "/",
                       p_om_item.num_sequencia USING "&&&" CLIPPED
     RETURN
 END IF

 SELECT local_estoque INTO p_cod_local
   FROM ped_item_loc_est
  WHERE empresa        = p_cod_empresa
    AND pedido         = p_om_item.num_pedido
    AND sequencia_item = p_om_item.num_sequencia
 IF p_cod_local IS NULL OR
    p_cod_local = " " THEN
    SELECT cod_local_estoq INTO p_cod_local
      FROM pedidos
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_om_item.num_pedido
    IF p_cod_local IS NULL OR
       p_cod_local = " " THEN
       SELECT cod_local_estoq INTO p_cod_local
         FROM item
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_om_item.cod_item
    END IF
 END IF
END FUNCTION

#----------------------------------------#
 FUNCTION vdp8018_deleta_ordem_montagens()
#----------------------------------------#
 DEFINE l_num_nfe    INTEGER,
        l_ser_nfe    CHAR(01)

 DELETE FROM ordem_montag_mest
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_obs
  WHERE cod_empresa = p_cod_empresa
           AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_ender
   WHERE cod_empresa = p_cod_empresa
     AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_item
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_embal
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_itref
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM ordem_montag_grade
   WHERE cod_empresa = p_cod_empresa
     AND num_om      = p_om_mest.num_om

 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

  DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_om_mest.num_om
  IF   sqlca.sqlcode <> 0
  THEN LET p_houve_erro = TRUE
       RETURN
  END IF

 WHENEVER ERROR CONTINUE
 SELECT ldi_om_nf_entrada.nf_entrada,
        ldi_om_nf_entrada.serie_nf_entrada
   INTO l_num_nfe,
        l_ser_nfe
   FROM ldi_om_nf_entrada
  WHERE ldi_om_nf_entrada.empresa    = p_cod_empresa
    AND ldi_om_nf_entrada.ord_montag = p_om_mest.num_om
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN

   #PROMPT ' ATENCAO: Excluir NF Entrada Nr. ',l_num_nfe USING '<<<<<<<',
   #       ' Serie ',l_ser_nfe,' .' ATTRIBUTE(REVERSE) FOR CHAR l_char
   #NAO IRA MAIS EXCLUIR A NOTA FISCAL DE ENTRADA

    WHENEVER ERROR CONTINUE
    DELETE FROM ldi_om_nf_entrada
     WHERE empresa    = p_cod_empresa
       AND ord_montag = p_om_mest.num_om
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 AND
       sqlca.sqlcode <> -206 THEN
       CALL log003_err_sql('DELETE','LDI_OM_NF_ENTRADA')
       LET p_houve_erro = TRUE
       RETURN
    END IF
 END IF
END FUNCTION

#----------------------------------------#
 FUNCTION vdp8018_deleta_qualidade()
#----------------------------------------#
DEFINE l_num_certif_anl INTEGER

 DECLARE cq_qea CURSOR FOR
 SELECT UNIQUE num_certif_anl
   FROM qea_emis_ca
   WHERE empresa        = p_cod_empresa
     AND num_ord_montag = p_om_mest.num_om

 INITIALIZE l_num_certif_anl TO NULL
 FOREACH cq_qea INTO l_num_certif_anl
   DELETE FROM qea_obs_certif_anl
     WHERE empresa        = p_cod_empresa
       AND num_certif_anl = l_num_certif_anl
   IF sqlca.sqlcode <> 0
   THEN LET p_houve_erro = TRUE
        RETURN
   END IF
 END FOREACH

 DELETE FROM qea_emis_ca_erro
   WHERE empresa        = p_cod_empresa
     AND num_ord_montag = p_om_mest.num_om
 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF

 DELETE FROM qea_emis_ca
   WHERE empresa        = p_cod_empresa
     AND num_ord_montag = p_om_mest.num_om
 IF sqlca.sqlcode <> 0
 THEN LET p_houve_erro = TRUE
      RETURN
 END IF
END FUNCTION

#-----------------------------------#
 FUNCTION vdp8018_verifica_om_grade()
#-----------------------------------#
 DEFINE p_est_loc_res      RECORD LIKE estoque_loc_reser.*,
        p_est_loc_res_end  RECORD LIKE est_loc_reser_end.*,
        p_ender_vol        RECORD LIKE endereco_volume.*

 DEFINE l_canc_total       SMALLINT

 INITIALIZE p_om_grade.*, p_est_loc_res.* TO NULL

 DECLARE c_om_grade CURSOR FOR
  SELECT *
    FROM ordem_montag_grade
   WHERE cod_empresa    = p_om_item.cod_empresa
     AND num_om         = p_om_item.num_om
     AND num_pedido     = p_om_item.num_pedido
     AND num_sequencia  = p_om_item.num_sequencia
 FOREACH c_om_grade INTO p_om_grade.*

   IF p_ies_ctr_estoque = "S" THEN

      SELECT *
        INTO p_est_loc_res.*
        FROM estoque_loc_reser
       WHERE cod_empresa = p_om_item.cod_empresa
         AND num_reserva = p_om_grade.num_reserva

         IF STATUS <> 0 THEN
            CALL log003_err_sql("DELECAO","ESTOQUE_LOC_RESER")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

      SELECT *
        INTO p_est_loc_res_end.*
        FROM est_loc_reser_end
       WHERE cod_empresa = p_om_item.cod_empresa
         AND num_reserva = p_om_grade.num_reserva

         IF STATUS <> 0 THEN
            CALL log003_err_sql("DELECAO","EST_LOC_RESER_END")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

      IF NOT vdp8018_cancela_transferencia(p_est_loc_res_end.*,
                                           p_est_loc_res.num_lote, 0) THEN
         RETURN FALSE
      END IF

      IF p_est_loc_res.qtd_reservada = p_om_grade.qtd_reservada THEN
         LET l_canc_total = TRUE
      ELSE
         LET l_canc_total = FALSE
      END IF

      IF l_canc_total = TRUE THEN
         DELETE FROM estoque_loc_reser
          WHERE cod_empresa = p_om_item.cod_empresa
            AND num_reserva = p_om_grade.num_reserva

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("DELECAO","ESTOQUE_LOC_RESER")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

         DELETE FROM est_loc_reser_end
          WHERE est_loc_reser_end.cod_empresa = p_om_item.cod_empresa
            AND est_loc_reser_end.num_reserva = p_om_grade.num_reserva

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("DELECAO","EST_LOC_RESER_END")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

         DELETE FROM ped_itens_textil
          WHERE cod_empresa    = p_om_item.cod_empresa
            AND num_pedido     = p_om_item.num_pedido
            AND num_sequencia  = p_om_item.num_sequencia
            AND cod_item       = p_om_item.cod_item
            AND cod_grade_1    = p_om_grade.cod_grade_1
            AND cod_grade_2    = p_om_grade.cod_grade_2
            AND cod_grade_3    = p_om_grade.cod_grade_3
            AND cod_grade_4    = p_om_grade.cod_grade_4
            AND cod_grade_5    = p_om_grade.cod_grade_5
            AND num_reserva    = p_om_grade.num_reserva

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("DELECAO","PED_ITENS_TEXTIL")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

         IF vdp8018_atualiza_estoque_lote_ender(p_est_loc_res.*,
                                                p_est_loc_res_end.*) = FALSE THEN
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF
      ELSE
         {a reserva foi quebrada em mais de uma OM}
         UPDATE estoque_loc_reser
            SET qtd_reservada = qtd_reservada - p_om_grade.qtd_reservada
          WHERE cod_empresa = p_om_item.cod_empresa
            AND num_reserva = p_om_grade.num_reserva

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("UPDATE","ESTOQUE_LOC_RESER")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF
      END IF

      IF p_est_loc_res_end.cod_grade_1 IS NOT NULL THEN

         UPDATE ped_itens_grade
            SET qtd_pecas_romaneio = ( qtd_pecas_romaneio
                                     - p_om_grade.qtd_reservada )
          WHERE cod_empresa   = p_om_item.cod_empresa
            AND num_pedido    = p_om_item.num_pedido
            AND num_sequencia = p_om_item.num_sequencia
            AND cod_item      = p_om_item.cod_item
            AND cod_grade_1   = p_om_grade.cod_grade_1
            AND cod_grade_2   = p_om_grade.cod_grade_2
            AND cod_grade_3   = p_om_grade.cod_grade_3
            AND cod_grade_4   = p_om_grade.cod_grade_4
            AND cod_grade_5   = p_om_grade.cod_grade_5

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("MODIFICACAO","PED_ITENS_GRADE")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF
      END IF

      IF l_canc_total      = TRUE AND
         p_ies_uti_end_vol = "S" THEN

         DECLARE c_ender_vol CURSOR FOR
          SELECT endereco_volume.*
            FROM endereco_volume
           WHERE endereco_volume.cod_empresa  = p_est_loc_res.cod_empresa
             AND endereco_volume.cod_local    = p_est_loc_res.cod_local
             AND endereco_volume.endereco     = p_est_loc_res_end.endereco
             AND endereco_volume.num_volume   = p_est_loc_res_end.num_volume
             AND endereco_volume.status       = "E"
             FOR UPDATE

         OPEN  c_ender_vol
         FETCH c_ender_vol INTO p_ender_vol.*

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LEITURA","ENDERECO_VOLUME")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF

         UPDATE endereco_volume
            SET endereco_volume.status = "L"
          WHERE CURRENT OF c_ender_vol

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("MODIFICACAO","ENDERECO_VOLUME")
            LET p_houve_erro = TRUE
            RETURN FALSE
         END IF
      END IF
   ELSE
      IF p_om_grade.cod_grade_1 IS NOT NULL THEN

         UPDATE ped_itens_grade
            SET qtd_pecas_romaneio = ( qtd_pecas_romaneio
                                     - p_om_grade.qtd_reservada )
          WHERE cod_empresa   = p_om_item.cod_empresa
            AND num_pedido    = p_om_item.num_pedido
            AND num_sequencia = p_om_item.num_sequencia
            AND cod_item      = p_om_item.cod_item
            AND cod_grade_1   = p_om_grade.cod_grade_1
            AND cod_grade_2   = p_om_grade.cod_grade_2
            AND cod_grade_3   = p_om_grade.cod_grade_3
            AND cod_grade_4   = p_om_grade.cod_grade_4
            AND cod_grade_5   = p_om_grade.cod_grade_5

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("MODIFICACAO-2","PED_ITENS_GRADE")
            LET  p_houve_erro = TRUE
            RETURN FALSE
         END IF
      END IF
   END IF
 END FOREACH
 RETURN TRUE
END FUNCTION

{   OS 98653 - INICIO   }
#----------------------------------------------------#
 FUNCTION vdp8018_insert_audit_vdp(l_tipo_informacao)
#----------------------------------------------------#
   DEFINE lr_audit_vdp RECORD LIKE audit_vdp.*
   DEFINE
      l_texto            LIKE  audit_vdp.texto,
      l_tipo_informacao  LIKE  audit_vdp.tipo_informacao

   LET l_texto =
     "CANCELAMENTO DA ORDEM DE MONTAGEM ", p_om_mest.num_om USING "&&&&&&",
      m_brancos[1,10], m_txt_audit_vdp

   INITIALIZE lr_audit_vdp.* TO NULL
   LET lr_audit_vdp.cod_empresa     = p_cod_empresa
   LET lr_audit_vdp.num_pedido      = p_om_item.num_pedido
   LET lr_audit_vdp.tipo_informacao = l_tipo_informacao
   LET lr_audit_vdp.tipo_movto      = "C"
   LET lr_audit_vdp.texto           = l_texto CLIPPED
   LET lr_audit_vdp.num_programa    = "VDP8018"
   LET lr_audit_vdp.data            = TODAY
   LET lr_audit_vdp.hora            = TIME
   LET lr_audit_vdp.usuario         = p_user
   LET lr_audit_vdp.num_transacao   = 0

   WHENEVER ERROR CONTINUE
   INSERT INTO audit_vdp VALUES ( lr_audit_vdp.* )
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT", "audit_vdp")
      LET p_houve_erro = TRUE
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION
{   OS 98653 - FINAL   }

#----------------------------------------------#
 FUNCTION vdp8018_carrega_estoque_trans_end()
#----------------------------------------------#
 LET p_estoque_trans_end.cod_empresa = p_cod_empresa
 LET p_estoque_trans_end.num_transac = 0
 LET p_estoque_trans_end.endereco    = " "
 LET p_estoque_trans_end.qtd_movto   = p_estoque_trans.qtd_movto
 LET p_estoque_trans_end.cod_grade_1 = " "
 LET p_estoque_trans_end.cod_grade_2 = " "
 LET p_estoque_trans_end.cod_grade_3 = " "
 LET p_estoque_trans_end.cod_grade_4 = " "
 LET p_estoque_trans_end.cod_grade_5 = " "
 LET p_estoque_trans_end.dat_hor_prod_ini = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.dat_hor_prod_fim = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.vlr_temperatura = 0
 LET p_estoque_trans_end.endereco_origem = " "
 LET p_estoque_trans_end.num_ped_ven =  0
 LET p_estoque_trans_end.num_seq_ped_ven =  0
 LET p_estoque_trans_end.dat_hor_producao = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.dat_hor_validade = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.num_peca         = " "
 LET p_estoque_trans_end.num_serie        = " "
 LET p_estoque_trans_end.comprimento      = 0
 LET p_estoque_trans_end.largura          = 0
 LET p_estoque_trans_end.altura           = 0
 LET p_estoque_trans_end.diametro         = 0
 LET p_estoque_trans_end.dat_hor_reserv_1 = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.dat_hor_reserv_2 = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.dat_hor_reserv_3 = extend("1900-01-01 00:00:00",year TO second)
 LET p_estoque_trans_end.qtd_reserv_1     = 0
 LET p_estoque_trans_end.qtd_reserv_2     = 0
 LET p_estoque_trans_end.qtd_reserv_3     = 0
 LET p_estoque_trans_end.num_reserv_1     = 0
 LET p_estoque_trans_end.num_reserv_2     = 0
 LET p_estoque_trans_end.num_reserv_3     = 0
 LET p_estoque_trans_end.tex_reservado    = " "
 LET p_estoque_trans_end.cus_unit_movto_p = 0
 LET p_estoque_trans_end.cus_unit_movto_f = 0
 LET p_estoque_trans_end.cus_tot_movto_p = 0
 LET p_estoque_trans_end.cus_tot_movto_f = 0

 END FUNCTION

#--------------------------------#
FUNCTION vdp8018_existe_om_grade()
#--------------------------------#

   SELECT UNIQUE cod_empresa
     FROM ordem_montag_grade
    WHERE cod_empresa    = p_om_item.cod_empresa
      AND num_om         = p_om_item.num_om
      AND num_pedido     = p_om_item.num_pedido
      AND num_sequencia  = p_om_item.num_sequencia
   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   END IF

   RETURN FALSE
END FUNCTION

#--------------------------------------------------------------#
FUNCTION vdp8018_atualiza_estoque_lote_ender(lr_est_loc_res,
                                             lr_est_loc_res_end)
#--------------------------------------------------------------#
   DEFINE lr_est_loc_res            RECORD LIKE estoque_loc_reser.*,
          lr_est_loc_res_end        RECORD LIKE est_loc_reser_end.*

   IF lr_est_loc_res.num_lote IS NULL THEN

      UPDATE estoque_lote_ender
         SET num_ped_ven     = 0,
             num_seq_ped_ven = 0
       WHERE estoque_lote_ender.cod_empresa     = p_cod_empresa
         AND estoque_lote_ender.cod_item        = p_om_item.cod_item
         AND estoque_lote_ender.cod_local       = lr_est_loc_res.cod_local
         AND estoque_lote_ender.num_lote        IS NULL
         AND estoque_lote_ender.endereco        = lr_est_loc_res_end.endereco
         AND estoque_lote_ender.num_volume      = lr_est_loc_res_end.num_volume
         AND estoque_lote_ender.cod_grade_1     = lr_est_loc_res_end.cod_grade_1
         AND estoque_lote_ender.cod_grade_2     = lr_est_loc_res_end.cod_grade_2
         AND estoque_lote_ender.cod_grade_3     = lr_est_loc_res_end.cod_grade_3
         AND estoque_lote_ender.cod_grade_4     = lr_est_loc_res_end.cod_grade_4
         AND estoque_lote_ender.cod_grade_5     = lr_est_loc_res_end.cod_grade_5
         AND estoque_lote_ender.num_ped_ven     = lr_est_loc_res_end.num_ped_ven
         AND estoque_lote_ender.num_seq_ped_ven =
             lr_est_loc_res_end.num_seq_ped_ven
         AND estoque_lote_ender.ies_situa_qtd   = "L"
         AND estoque_lote_ender.num_peca        = lr_est_loc_res_end.num_peca
         AND estoque_lote_ender.num_serie       = lr_est_loc_res_end.num_serie
         AND estoque_lote_ender.comprimento     = lr_est_loc_res_end.comprimento
         AND estoque_lote_ender.largura         = lr_est_loc_res_end.largura
         AND estoque_lote_ender.altura          = lr_est_loc_res_end.altura
         AND estoque_lote_ender.diametro        = lr_est_loc_res_end.diametro
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("MODIFICACAO", "ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
   ELSE
      UPDATE estoque_lote_ender
         SET num_ped_ven     = 0,
             num_seq_ped_ven = 0
       WHERE estoque_lote_ender.cod_empresa     = p_cod_empresa
         AND estoque_lote_ender.cod_item        = p_om_item.cod_item
         AND estoque_lote_ender.cod_local       = lr_est_loc_res.cod_local
         AND estoque_lote_ender.num_lote        = lr_est_loc_res.num_lote
         AND estoque_lote_ender.endereco        = lr_est_loc_res_end.endereco
         AND estoque_lote_ender.num_volume      = lr_est_loc_res_end.num_volume
         AND estoque_lote_ender.cod_grade_1     = lr_est_loc_res_end.cod_grade_1
         AND estoque_lote_ender.cod_grade_2     = lr_est_loc_res_end.cod_grade_2
         AND estoque_lote_ender.cod_grade_3     = lr_est_loc_res_end.cod_grade_3
         AND estoque_lote_ender.cod_grade_4     = lr_est_loc_res_end.cod_grade_4
         AND estoque_lote_ender.cod_grade_5     = lr_est_loc_res_end.cod_grade_5
         AND estoque_lote_ender.num_ped_ven     = lr_est_loc_res_end.num_ped_ven
         AND estoque_lote_ender.num_seq_ped_ven =
             lr_est_loc_res_end.num_seq_ped_ven
         AND estoque_lote_ender.ies_situa_qtd   = "L"
         AND estoque_lote_ender.num_peca        = lr_est_loc_res_end.num_peca
         AND estoque_lote_ender.num_serie       = lr_est_loc_res_end.num_serie
         AND estoque_lote_ender.comprimento     = lr_est_loc_res_end.comprimento
         AND estoque_lote_ender.largura         = lr_est_loc_res_end.largura
         AND estoque_lote_ender.altura          = lr_est_loc_res_end.altura
         AND estoque_lote_ender.diametro        = lr_est_loc_res_end.diametro
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("MODIFICACAO", "ESTOQUE_LOTE_ENDER")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp8018_busca_carteira_usuario()
#-----------------------------------------#
 DEFINE l_cod_tip_carteira    LIKE usuario_carteira.cod_tip_carteira,
        l_contador            SMALLINT,
        l_ind                 SMALLINT

 DEFINE la_array              ARRAY[50] OF RECORD
                              cod_tip_carteira   LIKE tipo_carteira.cod_tip_carteira,
                              den_tip_carteira   LIKE tipo_carteira.den_tip_carteira
                              END RECORD

 LET l_cod_tip_carteira = NULL

 LET l_contador = NULL

 SELECT COUNT(*)
   INTO l_contador
   FROM usuario_carteira
  WHERE usuario_carteira.cod_empresa = p_cod_empresa
    AND usuario_carteira.nom_usuario = p_user

 IF sqlca.sqlcode <> 0 OR
    l_contador IS NULL THEN
    LET l_contador = 0
 END IF

 IF l_contador > 1 THEN

    CALL log130_procura_caminho("VDP80181") RETURNING p_nom_tela
    OPEN WINDOW w_vdp80181 AT 07,41 WITH FORM p_nom_tela
         ATTRIBUTE(BORDER, COMMENT LINE LAST -1, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

   CALL log0010_close_window_screen()
    INITIALIZE la_array TO NULL

    LET l_ind = 1

    DECLARE cq_carteiras CURSOR FOR
     SELECT usuario_carteira.cod_tip_carteira,
            tipo_carteira.den_tip_carteira
       FROM usuario_carteira, tipo_carteira
      WHERE usuario_carteira.cod_empresa   = p_cod_empresa
        AND usuario_carteira.nom_usuario   = p_user
        AND tipo_carteira.cod_tip_carteira = usuario_carteira.cod_tip_carteira
      ORDER BY usuario_carteira.cod_tip_carteira

    FOREACH cq_carteiras INTO la_array[l_ind].cod_tip_carteira,
                              la_array[l_ind].den_tip_carteira
       LET l_ind = l_ind + 1
       IF l_ind > 50 THEN
          ERROR " Estouro de ARRAY. "
          EXIT FOREACH
       END IF
    END FOREACH

    CALL SET_COUNT(l_ind - 1)

    DISPLAY ARRAY la_array TO s_array.*

       ON KEY (control-z, f4)
          CALL log120_procura_caminho("vdp6330") RETURNING p_comando
          RUN p_comando RETURNING p_cancel

    END DISPLAY

    IF int_flag = TRUE THEN
       LET int_flag           = FALSE
       LET l_cod_tip_carteira = NULL
    ELSE
       LET l_ind = ARR_CURR()
       LET l_cod_tip_carteira = la_array[l_ind].cod_tip_carteira
    END IF

    CLOSE WINDOW w_vdp80181
    CURRENT WINDOW IS w_vdp8018

 ELSE
    SELECT usuario_carteira.cod_tip_carteira
      INTO l_cod_tip_carteira
      FROM usuario_carteira
     WHERE usuario_carteira.cod_empresa = p_cod_empresa
       AND usuario_carteira.nom_usuario = p_user

    IF sqlca.sqlcode <> 0 THEN
       LET l_cod_tip_carteira = NULL
       ERROR " Carteira n�o encontrada para o usuario. "
    END IF

 END IF

 RETURN l_cod_tip_carteira

 END FUNCTION

#--------------------------------------#
FUNCTION vdp8018_retorna_comp_estr_vdp()
#--------------------------------------#
   DEFINE lr_ldi_est_comp_vdp          RECORD LIKE ldi_est_comp_vdp.*,
          lr_est_lot_end               RECORD LIKE estoque_lote_ender.*,
          lr_est_trans_end             RECORD LIKE estoque_trans_end.*,
          lr_estoque_trans             RECORD LIKE estoque_trans.*,
          lr_estoque_obs               RECORD LIKE estoque_obs.*

   DEFINE l_cod_local_est              LIKE item.cod_local_estoq

   DECLARE cq_compon CURSOR FOR
    SELECT *
      FROM ldi_est_comp_vdp
     WHERE empresa        = p_cod_empresa
       AND ord_montag     = p_om_item.num_om
       AND sequencia_item = p_om_item.num_sequencia
       AND pedido         = p_om_item.num_pedido

   FOREACH cq_compon INTO lr_ldi_est_comp_vdp.*
      INITIALIZE lr_estoque_trans.* TO NULL
      INITIALIZE lr_est_trans_end.* TO NULL
      INITIALIZE lr_estoque_obs.*   TO NULL

      SELECT *
        INTO lr_estoque_trans.*
        FROM estoque_trans
       WHERE cod_empresa = lr_ldi_est_comp_vdp.empresa
         AND num_transac = lr_ldi_est_comp_vdp.num_trans_estoque

      SELECT *
        INTO lr_est_trans_end.*
        FROM estoque_trans_end
       WHERE cod_empresa = lr_ldi_est_comp_vdp.empresa
         AND num_transac = lr_ldi_est_comp_vdp.num_trans_estoque

      SELECT *
        INTO lr_estoque_obs.*
        FROM estoque_obs
       WHERE cod_empresa = lr_ldi_est_comp_vdp.empresa
         AND num_transac = lr_ldi_est_comp_vdp.num_trans_estoque

      LET lr_estoque_trans.ies_tip_movto = 'R'
      LET lr_est_trans_end.ies_tip_movto = 'R'

      CALL sup097_movto_estoque(lr_estoque_trans.*,
                                lr_estoque_obs.*,
                                lr_est_trans_end.*,0) RETURNING p_status

      IF NOT p_status THEN
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      DELETE FROM ldi_est_comp_vdp
       WHERE empresa           = lr_ldi_est_comp_vdp.empresa
         AND num_trans_estoque = lr_ldi_est_comp_vdp.num_trans_estoque
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('DELETE','LDI_EST_COMP_VDP')
         LET p_houve_erro = TRUE
         EXIT FOREACH
      END IF

      WHENEVER ERROR CONTINUE
      DELETE
        FROM man_moviment_serie
       WHERE serie             = lr_est_trans_end.num_serie
         AND item              = lr_est_trans_end.cod_item
         AND dat_processamento = lr_estoque_trans.dat_proces
         AND hor_processamento = lr_estoque_trans.hor_operac
      WHENEVER ERROR STOP

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('DELETE','MAN_MOVIMENT_SERIE')
         LET p_houve_erro = TRUE
         EXIT FOREACH
      END IF
   END FOREACH
   FREE cq_compon

   RETURN TRUE
END FUNCTION

#----------------------------------------#
 FUNCTION vdp8018_verifica_ped_item_comp()
#----------------------------------------#
{ OS 275302 - QUANDO EXISTIR REGISTRO NA TABELA PED_ITEM_COMP, NAO }
{             DESFAZER A RESERVA, POIS A MESMA FOI EFETUADA PELA   }
{             MANUFATURA. APENAS EXCLUIR A ORDEM DE MONTAGEM.      }

 WHENEVER ERROR CONTINUE

 SELECT UNIQUE empresa
   FROM ped_item_comp
  WHERE ped_item_comp.empresa         = p_om_item.cod_empresa
    AND ped_item_comp.pedido          = p_om_item.num_pedido
    AND ped_item_comp.seq_item_pedido = p_om_item.num_sequencia

 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN

    CALL vdp8018_retorna_qtd_pecas_reserv()
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION

#------------------------------------------#
 FUNCTION vdp8018_retorna_qtd_pecas_reserv()
#------------------------------------------#
 IF p_om_item.ies_bonificacao = 'N' THEN

    UPDATE ped_itens
       SET qtd_pecas_romaneio = qtd_pecas_romaneio - p_om_item.qtd_reservada,
           qtd_pecas_reserv   = qtd_pecas_reserv   + p_om_item.qtd_reservada
     WHERE ped_itens.cod_empresa   = p_om_item.cod_empresa
       AND ped_itens.num_pedido    = p_om_item.num_pedido
       AND ped_itens.num_sequencia = p_om_item.num_sequencia

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('UPDATE','PED_ITENS')
       LET p_houve_erro = TRUE
    END IF
 ELSE

    UPDATE ped_itens_bnf
       SET qtd_pecas_romaneio = qtd_pecas_romaneio - p_om_item.qtd_reservada,
           qtd_pecas_reserv   = qtd_pecas_reserv   + p_om_item.qtd_reservada
     WHERE ped_itens_bnf.cod_empresa   = p_om_item.cod_empresa
       AND ped_itens_bnf.num_pedido    = p_om_item.num_pedido
       AND ped_itens_bnf.num_sequencia = p_om_item.num_sequencia

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('UPDATE','PED_ITENS_BNF')
       LET p_houve_erro = TRUE
    END IF
 END IF

 CALL vdp8018_atualiza_num_docum_referencia()

END FUNCTION

#-----------------------------------------------#
 FUNCTION vdp8018_atualiza_num_docum_referencia()
#-----------------------------------------------#
 DEFINE l_num_reserva      LIKE estoque_loc_reser.num_reserva,
        l_num_docum        LIKE estoque_loc_reser.num_docum,
        l_num_referencia   LIKE estoque_loc_reser.num_referencia

 INITIALIZE l_num_reserva TO NULL

 LET l_num_docum      = p_om_item.num_pedido    USING '&&&&&&'
 LET l_num_referencia = p_om_item.num_sequencia USING '&&&&&'

 DECLARE cq_reserva CURSOR FOR
  SELECT ordem_montag_grade.num_reserva
    FROM ordem_montag_grade
   WHERE ordem_montag_grade.cod_empresa   = p_om_item.cod_empresa
     AND ordem_montag_grade.num_pedido    = p_om_item.num_pedido
     AND ordem_montag_grade.num_sequencia = p_om_item.num_sequencia

 FOREACH cq_reserva INTO l_num_reserva

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_RESERVA')
       LET p_houve_erro = TRUE
       RETURN
    END IF

    UPDATE estoque_loc_reser
       SET num_docum      = l_num_docum,
           num_referencia = l_num_referencia
     WHERE estoque_loc_reser.cod_empresa = p_om_item.cod_empresa
       AND estoque_loc_reser.num_reserva = l_num_reserva

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('UPDATE','ESTOQUE_LOC_RESER')
       LET p_houve_erro = TRUE
       RETURN
    END IF

 END FOREACH
 FREE cq_reserva

END FUNCTION

#------------------------------------------------------------#
 FUNCTION vdp8018_cancela_transferencia(lr_est_loc_reser_end,
                                        l_lote,
                                        l_qtd_reservada)
#------------------------------------------------------------#
 DEFINE l_qtd_reservada        LIKE estoque_loc_reser.qtd_reservada,
        lr_est_loc_reser_end   RECORD LIKE est_loc_reser_end.*,
        l_lote                 LIKE estoque_lote_ender.num_lote

 DEFINE l_status               SMALLINT,
        l_cliente              LIKE clientes.cod_cliente,
        l_empresa_destino      CHAR(02),
        l_num_controle         INTEGER

 DEFINE lr_dados_estoque       RECORD
           local                  LIKE estoque_lote_ender.cod_local,
           lote                   LIKE estoque_lote_ender.num_lote,
           endereco               LIKE estoque_lote_ender.endereco,
           num_volume             LIKE estoque_lote_ender.num_volume,
           grade_1                LIKE estoque_lote_ender.cod_grade_1,
           grade_2                LIKE estoque_lote_ender.cod_grade_2,
           grade_3                LIKE estoque_lote_ender.cod_grade_3,
           grade_4                LIKE estoque_lote_ender.cod_grade_4,
           grade_5                LIKE estoque_lote_ender.cod_grade_5,
           dat_hor_producao       LIKE estoque_lote_ender.dat_hor_producao,
           pedido_venda           LIKE estoque_lote_ender.num_ped_ven,
           seq_pedido_venda       LIKE estoque_lote_ender.num_seq_ped_ven,
           sit_qtd                LIKE estoque_lote_ender.ies_situa_qtd,
           origem_entrada         LIKE estoque_lote_ender.ies_origem_entrada,
           dat_hor_valid          LIKE estoque_lote_ender.dat_hor_validade,
           peca                   LIKE estoque_lote_ender.num_peca,
           serie_peca             LIKE estoque_lote_ender.num_serie,
           comprimento            LIKE estoque_lote_ender.comprimento,
           largura                LIKE estoque_lote_ender.largura,
           altura                 LIKE estoque_lote_ender.altura,
           diametro               LIKE estoque_lote_ender.diametro,
           dat_hor_reserva_1      LIKE estoque_lote_ender.dat_hor_reserv_1,
           dat_hor_reserva_2      LIKE estoque_lote_ender.dat_hor_reserv_2,
           dat_hor_reserva_3      LIKE estoque_lote_ender.dat_hor_reserv_3,
           qtd_reservada_1        LIKE estoque_lote_ender.qtd_reserv_1,
           qtd_reservada_2        LIKE estoque_lote_ender.qtd_reserv_2,
           qtd_reservada_3        LIKE estoque_lote_ender.qtd_reserv_3,
           reserva_1              LIKE estoque_lote_ender.num_reserv_1,
           reserva_2              LIKE estoque_lote_ender.num_reserv_2,
           reserva_3              LIKE estoque_lote_ender.num_reserv_3,
           texto_reservado        LIKE estoque_lote_ender.tex_reservado,
           identif_estoque        LIKE estoque_lote_ender.identif_estoque,
           deposit                LIKE estoque_lote_ender.deposit
                               END RECORD
 INITIALIZE l_cliente TO NULL

 SELECT cod_cliente
   INTO l_cliente
   FROM pedidos
  WHERE pedidos.cod_empresa = p_cod_empresa
    AND pedidos.num_pedido  = p_om_grade.num_pedido

 CALL sup1166_busca_empresa_destino(l_cliente,FALSE)
    RETURNING l_status, l_empresa_destino

 IF l_empresa_destino IS NOT NULL AND
    l_empresa_destino <> ' ' THEN
 ELSE
    RETURN TRUE {nao tem empresa destino para transferencia}
 END IF

 LET lr_dados_estoque.local             = ' '
 LET lr_dados_estoque.lote              = l_lote
 LET lr_dados_estoque.endereco          = lr_est_loc_reser_end.endereco
 LET lr_dados_estoque.num_volume        = lr_est_loc_reser_end.num_volume
 LET lr_dados_estoque.grade_1           = lr_est_loc_reser_end.cod_grade_1
 LET lr_dados_estoque.grade_2           = lr_est_loc_reser_end.cod_grade_2
 LET lr_dados_estoque.grade_3           = lr_est_loc_reser_end.cod_grade_3
 LET lr_dados_estoque.grade_4           = lr_est_loc_reser_end.cod_grade_4
 LET lr_dados_estoque.grade_5           = lr_est_loc_reser_end.cod_grade_5
 LET lr_dados_estoque.dat_hor_producao  = lr_est_loc_reser_end.dat_hor_producao
 LET lr_dados_estoque.pedido_venda      = lr_est_loc_reser_end.num_ped_ven
 LET lr_dados_estoque.seq_pedido_venda  = lr_est_loc_reser_end.num_seq_ped_ven
 LET lr_dados_estoque.sit_qtd           = 'L'
 LET lr_dados_estoque.origem_entrada    = ' '
 LET lr_dados_estoque.dat_hor_valid     = lr_est_loc_reser_end.dat_hor_validade
 LET lr_dados_estoque.peca              = lr_est_loc_reser_end.num_peca
 LET lr_dados_estoque.serie_peca        = lr_est_loc_reser_end.num_serie
 LET lr_dados_estoque.comprimento       = lr_est_loc_reser_end.comprimento
 LET lr_dados_estoque.largura           = lr_est_loc_reser_end.largura
 LET lr_dados_estoque.altura            = lr_est_loc_reser_end.altura
 LET lr_dados_estoque.diametro          = lr_est_loc_reser_end.diametro
 LET lr_dados_estoque.dat_hor_reserva_1 = lr_est_loc_reser_end.dat_hor_reserv_1
 LET lr_dados_estoque.dat_hor_reserva_2 = lr_est_loc_reser_end.dat_hor_reserv_2
 LET lr_dados_estoque.dat_hor_reserva_3 = lr_est_loc_reser_end.dat_hor_reserv_3
 LET lr_dados_estoque.qtd_reservada_1   = lr_est_loc_reser_end.qtd_reserv_1
 LET lr_dados_estoque.qtd_reservada_2   = lr_est_loc_reser_end.qtd_reserv_2
 LET lr_dados_estoque.qtd_reservada_3   = lr_est_loc_reser_end.qtd_reserv_3
 LET lr_dados_estoque.reserva_1         = lr_est_loc_reser_end.num_reserv_1
 LET lr_dados_estoque.reserva_2         = lr_est_loc_reser_end.num_reserv_2
 LET lr_dados_estoque.reserva_3         = lr_est_loc_reser_end.num_reserv_3
 LET lr_dados_estoque.texto_reservado   = lr_est_loc_reser_end.tex_reservado
 LET lr_dados_estoque.identif_estoque   = lr_est_loc_reser_end.identif_estoque
 LET lr_dados_estoque.deposit           = lr_est_loc_reser_end.deposit

 CALL sup1166_transferencia(p_cod_empresa,
                            l_empresa_destino,
                            p_om_item.cod_item,
                            l_qtd_reservada,
                            lr_est_loc_reser_end.num_reserva,
                            ' ', {num_documento}
                            'V',
                            'E',
                            lr_dados_estoque.*,
                            'VDP8018')
    RETURNING l_status, l_num_controle

 IF l_status = FALSE THEN
    LET p_houve_erro = TRUE
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION
