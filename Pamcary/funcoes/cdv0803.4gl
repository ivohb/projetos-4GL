###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGEM                          #
# PROGRAMA: CDV0803                                                 #
# MODULOS.: CDV0803                                                 #
# OBJETIVO: FUNCAO RESPONSSAVEL PELA CRIACAO DA LOGICA DE APROVACAO #
#.........: ELETRONICA DE VIAGEM.(COPIA cap5560).                   #
# AUTOR...: JULIANO TEOFILO CABRAL DA MAIA                          #
# DATA....: 02/08/2005.                                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_aprov_eletr       CHAR(01),
         g_ies_ambiente      CHAR(01),
         p_work              SMALLINT,
         p_existe_apr        CHAR(01)

  DEFINE g_lote_pgto_div     LIKE lote_pagamento.cod_lote_pgto,
         g_cond_pgto_km      LIKE cond_pgto_cap.cnd_pgto

  DEFINE p_ad_mestre         RECORD LIKE ad_mestre.*,
         p_par_cap           RECORD LIKE par_cap.*,
         p_tip_desp          RECORD LIKE tipo_despesa.*,
         p_raz_social        LIKE fornecedor.raz_social,
         g_uni_funcional     LIKE usu_cap_uni_func.cod_uni_funcio,
         p_usa_aprovacao     CHAR(01),
         p_status            SMALLINT,

         p_plano_contas      RECORD LIKE plano_contas.*,
         p_uni_funcional     LIKE usu_cap_uni_func.cod_uni_funcio,
         g_linha_grade       SMALLINT,
         g_num_versao_grade  SMALLINT,

         p_cod_nivel_autor   CHAR(02),
         p_ies_forma_aprov   CHAR(01),
         g_cod_usuario       CHAR(08),
         g_nom_usuario       CHAR(30),
         g_e_mail            CHAR(40),
         g_cent_cust         CHAR(11),
         g_cod_usuario_ccd   CHAR(08),
         g_nom_usuario_ccd   CHAR(30),
         g_e_mail_ccd        CHAR(40),

         g_input             SMALLINT,
         p_flagx             SMALLINT,
         g_par_aprov_topo    CHAR(01),
         g_par_envia_email   CHAR(01),
         g_contador          SMALLINT,
         g_pula              SMALLINT,
         g_aprov_raiz_uni_fun CHAR(01),
         p_status_cap        SMALLINT,
         g_tipo_mascara      CHAR(1),
         g_cc_div_plan_con   SMALLINT,
         g_nom_usu_cc        CHAR(30),
         g_mail              CHAR(40),
         g_prim_vez_aprov    SMALLINT

  DEFINE g_env_apr_niv_sup   CHAR(01),
         comand_cap          CHAR(150),
         g_env_nivel_sup     CHAR(01),
         g_env_nivel_sup_ant CHAR(01),
         g_email_aprovante   CHAR(01),
         g_email_cc_diverg   CHAR(01),
         p_arr               SMALLINT,
         p_scr               SMALLINT,
         g_text_email_aprov1 CHAR(70),
         g_text_email_aprov2 CHAR(70),
         g_text_email_cc1    CHAR(70),
         g_text_email_cc2    CHAR(70)

  DEFINE t_lanc_cont   ARRAY[500] OF RECORD
                        ies_tipo_lanc         LIKE lanc_cont_cap.ies_tipo_lanc,
                        num_conta_cont        LIKE lanc_cont_cap.num_conta_cont,
                        val_lanc              LIKE lanc_cont_cap.val_lanc,
                        tex_hist_lanc         LIKE lanc_cont_cap.tex_hist_lanc,
                        cod_tip_desp_val      LIKE lanc_cont_cap.cod_tip_desp_val,
                        ies_desp_val          LIKE lanc_cont_cap.ies_desp_val,
                        num_seq               LIKE lanc_cont_cap.num_seq,
                        ies_cnd_pgto          LIKE lanc_cont_cap.ies_cnd_pgto,
                        aux                   CHAR(001)
                       END RECORD

  DEFINE t_dados_aprov ARRAY[99] OF RECORD
                        l_ies_email_aprov       CHAR(01),
                        l_login_usuario         CHAR(08),
                        l_nom_usuario           CHAR(25),
                        l_email_usuario         CHAR(38)
                       END RECORD

  DEFINE t_dados_ccd   ARRAY[99] OF RECORD
                        cc_usu_aprovante_ccd  CHAR(11),
                        ies_email_ccd         CHAR(01),
                        login_usuario_ccd     CHAR(08),
                        nom_usuario_ccd       CHAR(25),
                        email_usuario_ccd     CHAR(30)
                       END RECORD

   DEFINE  g_ind              SMALLINT
   DEFINE p_aprov_necessaria  RECORD LIKE aprov_necessaria.*
   DEFINE p_user              CHAR(08),
          p_user1             CHAR(08),
          p_user_ant          LIKE usuario.nom_usuario

   DEFINE g_progr_aprov_eletr CHAR(07)
   DEFINE g_cdv0061           CHAR(01)

   DEFINE m_versao_funcao     CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

  DEFINE p_aux_ct  SMALLINT,
         g_cdv0060 CHAR(01)

END GLOBALS

# MODULARES
  DEFINE mr_relat              RECORD
                               num_viagem       LIKE cdv_solic_viagem.num_viagem,
                               nom_viajante     LIKE funcionario.nom_funcionario,
                               nom_cliente      LIKE clientes.nom_cliente,
                               data_partida     DATE,
                               hora_partida     CHAR(05),
                               data_retorno     DATE,
                               hora_retorno     CHAR(05),
                               des_reembolsavel CHAR(45),
                               val_adto         DECIMAL(8,2)
                               END RECORD

   DEFINE m_num_viagem         LIKE cdv_solic_viagem.num_viagem,
          m_viagem             LIKE cdv_solic_viagem.num_viagem,
          m_matricula_viajante LIKE cdv_info_viajante.matricula,
          m_tip_desp           RECORD LIKE tipo_despesa.*,
          m_url_cdv_logo       CHAR(70),
          m_manut_tabela        SMALLINT,
          m_processa            SMALLINT

   DEFINE mr_cdv_protocol      RECORD LIKE cdv_protocol.*
   DEFINE m_usuario_aprovante  LIKE usuario.nom_usuario

#----------------------------------------------------------------------------------------#
 FUNCTION cdv0803_email_aprov_eletronica(l_dispara_email, l_progr_aprov_eletr,
                                               l_ies_aprov_aut, l_num_viagem, l_num_ad,
                                               l_num_ap, l_status)
#----------------------------------------------------------------------------------------#
DEFINE l_dispara_email     SMALLINT,
       l_progr_aprov_eletr CHAR(07),
       l_ies_aprov_aut     CHAR(01),
       l_status            CHAR(01),
       l_num_viagem        LIKE cdv_solic_viagem.num_viagem,
       l_num_ad            LIKE ad_mestre.num_ad,
       l_num_ap            LIKE ap.num_ap

 LET p_user1             = p_user
 LET g_progr_aprov_eletr = l_progr_aprov_eletr
 LET m_num_viagem        = l_num_viagem

 LET p_aux_ct = 0

 CALL cdv0803_carrega_parametros(l_num_viagem)

 LET m_versao_funcao = "CDV0803-10.02.00p"

 IF p_usa_aprovacao = "N" AND  p_aprov_eletr = "S"  THEN
    ERROR "Parâmetro de uso da aprov. eletr. não está ativo."
    SLEEP(3)
 END IF

  WHENEVER ERROR CONTINUE
   SELECT ad_mestre.*
     INTO p_ad_mestre.*
     FROM ad_mestre
    WHERE cod_empresa = p_cod_empresa
      AND num_ad      = l_num_ad
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','ad_mestre')
     RETURN TRUE
  END IF

 IF l_dispara_email THEN
    WHENEVER ERROR CONTINUE
     DROP TABLE t_envio_email;

     CREATE TEMP TABLE t_envio_email (num_ad          DECIMAL(6,0),
                                      email           CHAR(40),
                                      cod_nivel_autor CHAR(02));
    WHENEVER ERROR STOP
 END IF

 IF p_usa_aprovacao = "S" THEN
    CALL cdv0803_carrega_tip_despesa()

    IF l_dispara_email = TRUE THEN
       IF p_aprov_eletr = "S" THEN
          CALL cdv0803_dispara_email_aprovantes()
          CALL cdv0803_dispara_email_cc_divergentes()
       END IF
       IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) <> 0 THEN
          CALL cdv0803_atualiz_aprov_necessaria(l_ies_aprov_aut)
       ELSE
          LET p_status = 1
          LET p_flagx  = 0
       END IF
    ELSE
       IF cdv0803_busca_parametros_aprov_eletro() = TRUE THEN
          CALL log130_procura_caminho("cap02217") RETURNING comand_cap
          OPEN WINDOW w_cap02217 AT 2,2 WITH FORM comand_cap
          ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)
       END IF

       IF p_ad_mestre.cod_fornecedor IS NOT NULL THEN
          WHENEVER ERROR CONTINUE
          SELECT raz_social
            INTO p_raz_social
            FROM fornecedor
           WHERE cod_fornecedor = p_ad_mestre.cod_fornecedor
          WHENEVER ERROR STOP
       END IF

       CALL cdv0803_inicializa()

       LET g_input  = 1
       LET p_flagx  = 1
       LET g_pula   = FALSE

       LET g_env_apr_niv_sup   = "N"
       LET g_env_nivel_sup_ant = "N"
       LET g_prim_vez_aprov    = TRUE

       ERROR " Verificando a existência de aprovantes para esta AD. "

       IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) = 0 THEN
          LET p_status = 1
          LET p_flagx  = 0
       ELSE
          LET p_existe_apr = "S"
       END IF

       WHILE p_flagx = 1
          CASE
              WHEN g_input = 1 CALL cdv0803_entrada_dados()
              WHEN g_input = 2 CALL cdv0803_entra_dados_array_aprovantes()
              WHEN g_input = 3 CALL cdv0803_entrada_dados_email_aprovantes()
              WHEN g_input = 4 CALL cdv0803_verifica_dados_centro_custo_divergentes()
                               CALL cdv0803_entrada_dados_2()
              WHEN g_input = 5 CALL cdv0803_entra_dados_array_cc_divergentes()
              WHEN g_input = 6 CALL cdv0803_entrada_dados_email_cc_divergentes()
              WHEN g_input = 7
                   IF p_aprov_eletr = "S" THEN
                      CALL cdv0803_carrega_email_aprovantes()
                      CALL cdv0803_carrega_email_cc_divergentes()

                      IF g_par_envia_email = "N" AND g_par_aprov_topo  = "N" THEN
                         LET p_flagx  = 0
                         LET g_input  = 0
                      ELSE
                         IF cap098_confirm(21,44) THEN
                            LET p_flagx  = 0
                            LET g_input  = 0
                         ELSE
                            INITIALIZE t_dados_aprov, t_dados_ccd TO NULL
                            DISPLAY t_dados_aprov[1].* TO s_dados_aprov[1].*
                            DISPLAY t_dados_aprov[2].* TO s_dados_aprov[2].*
                            DISPLAY t_dados_ccd[1].* TO s_dados_ccd[1].*
                            DISPLAY t_dados_ccd[2].* TO s_dados_ccd[2].*
                            LET g_input  = 1
                            LET p_flagx  = 1
                         END IF
                      END IF
                   ELSE
                      LET p_flagx  = 0
                      LET g_input  = 0
                   END IF
          END CASE
       END WHILE

       IF g_par_envia_email = "N" AND g_par_aprov_topo  = "N" THEN
          LET p_status = 0
          LET p_flagx  = 0
       ELSE
          CLOSE WINDOW w_cap02217
          LET p_status = 0
          LET p_flagx  = 0
       END IF

       IF int_flag = TRUE  THEN
          LET p_status = 1
          RETURN p_status
       ELSE
          RETURN p_status
       END IF
    END IF
 END IF

 LET p_user1 = p_user_ant
 LET p_status = 0
 RETURN p_status

END FUNCTION

#-------------------------------------------------#
 FUNCTION  cdv0803_busca_parametros_aprov_eletro()
#-------------------------------------------------#
 IF p_aprov_eletr = "N" THEN
    LET g_par_envia_email = "N"
    LET g_par_aprov_topo  = "N"
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT par_ies INTO g_par_envia_email
   FROM par_cap_pad
  WHERE cod_empresa   = p_cod_empresa
    AND cod_parametro = "ies_envia_email"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD3")
    LET p_work = FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT par_ies INTO g_par_aprov_topo
   FROM par_cap_pad
  WHERE cod_empresa   = p_cod_empresa
    AND cod_parametro = "ies_envia_aprov"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD4")
    LET p_work = FALSE
 END IF

 IF g_par_envia_email = "S" THEN
    RETURN TRUE
 ELSE
    IF g_par_aprov_topo = "S" THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF
 END IF

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv0803_entrada_dados()   ### g_input = 1
#-------------------------------------------------#
  CALL log006_exibe_teclas("01 02 03",m_versao_funcao)

  IF g_par_envia_email = "N" AND
     g_par_aprov_topo  = "N" THEN
     LET g_env_nivel_sup = "N"
     LET g_email_aprovante = "N"
  ELSE
     CURRENT WINDOW IS w_cap02217
     CLEAR FORM

   INPUT g_env_nivel_sup,
         g_email_aprovante
    FROM ies_env_nivel_sup,
         ies_email_aprovant

    BEFORE FIELD ies_env_nivel_sup
       IF g_par_aprov_topo = "S" THEN { parametro }
          LET g_env_nivel_sup = "N"
          DISPLAY g_env_nivel_sup TO ies_env_nivel_sup
       ELSE
          IF g_prim_vez_aprov  THEN
             LET g_env_apr_niv_sup = "N"
             ERROR "Verificando a existência de aprovantes para esta AD. "
             IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) = 0 THEN
                LET p_flagx = 0
                LET g_input = 0
             END IF
             LET g_prim_vez_aprov = FALSE
           END IF
           LET g_env_nivel_sup = "N"
           DISPLAY g_env_nivel_sup TO ies_env_nivel_sup
           NEXT FIELD ies_email_aprovant
       END IF

    AFTER FIELD ies_env_nivel_sup
       IF g_env_nivel_sup IS NULL THEN
          ERROR " É obrigatório informar esse campo. "
          NEXT FIELD ies_env_nivel_sup
       END IF

        IF g_env_nivel_sup_ant = "N" AND
           g_env_nivel_sup = "N"  THEN
           IF g_prim_vez_aprov  THEN
              LET g_env_apr_niv_sup = "N"
              ERROR "Verificando a existência de aprovantes para esta AD. "
              IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) = 0 THEN
                 LET p_flagx = 0
                 LET g_input = 0
              END IF
              LET g_prim_vez_aprov = FALSE
           END IF
        END IF
        IF g_env_nivel_sup_ant = "N" AND
           g_env_nivel_sup = "S"  THEN
           LET g_env_apr_niv_sup = "S"
           ERROR "Verificando a existência de aprovantes (nível superior) para esta AD. "
           IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) = 0 THEN
              LET p_flagx = 0
              LET g_input = 0
           END IF
        END IF
        IF g_env_nivel_sup_ant = "S" AND
           g_env_nivel_sup = "N"  THEN
           LET g_env_apr_niv_sup = "N"
           ERROR "Verificando a existência de aprovantes para esta AD. "
           IF cdv0803_verifica_se_existe_grade_aprov(g_env_apr_niv_sup) = 0 THEN
              LET p_flagx = 0
              LET g_input = 0
           END IF
        END IF
        IF g_env_nivel_sup_ant = "S" AND
           g_env_nivel_sup = "S"  THEN
        END IF
        LET g_env_nivel_sup_ant = g_env_nivel_sup

    BEFORE FIELD ies_email_aprovant
      IF g_par_envia_email = "S" THEN  { parametro }
         LET g_email_aprovante = "S"
         DISPLAY g_email_aprovante TO ies_email_aprovant
      ELSE
         LET g_email_aprovante = "N"
         DISPLAY g_email_aprovante TO ies_email_aprovant
         EXIT INPUT
         LET g_input  = 0
         LET p_flagx  = 0
      END IF

    AFTER FIELD ies_email_aprovant
      IF g_email_aprovante IS NULL THEN
         ERROR " É obrigatório informar esse campo."
         NEXT FIELD ies_email_aprovant
      END IF

      IF g_email_aprovante = "N" THEN
         LET g_pula = TRUE
         EXIT INPUT
      END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv0803_help()

   END INPUT
   CALL log006_exibe_teclas("01",m_versao_funcao)
   CURRENT WINDOW IS w_cap02217
 END IF

 IF int_flag = 0  THEN
    IF g_pula = TRUE THEN
       LET g_input = 4
       LET g_pula = FALSE
    ELSE
       LET g_input  = 2
    END IF
 ELSE
    LET p_status = 0
    LET g_input  = 0
    LET p_flagx  = 0
 END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv0803_entra_dados_array_aprovantes()     { g_input = 2 }
#----------------------------------------------#

 DEFINE l_saida  SMALLINT

 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
 ELSE
    CURRENT WINDOW IS w_cap02217
    CALL cdv0803_insere_dados_array_aprov()

    LET l_saida   = FALSE
    ERROR "DIGITE ESC P/ SAIR ..."

    CALL SET_COUNT(g_contador)

    WHILE l_saida = FALSE
       INPUT ARRAY t_dados_aprov WITHOUT DEFAULTS FROM s_dados_aprov.*

      BEFORE FIELD ies_email_aprov
         LET p_arr = arr_curr()
         LET p_scr = scr_line()
         IF t_dados_aprov[p_arr].l_login_usuario IS NULL  THEN
            LET t_dados_aprov[p_arr].l_ies_email_aprov = "N"
         END IF

      BEFORE FIELD login_usuario
         LET p_arr = arr_curr()
         LET p_scr = scr_line()

      AFTER FIELD login_usuario
        IF t_dados_aprov[p_arr].l_login_usuario IS NULL THEN
           CALL cdv0803_popup()
        END IF
        IF  t_dados_aprov[p_arr].l_login_usuario IS NOT NULL THEN
            CALL cdv0803_verifica_cod_usuario(t_dados_aprov[p_arr].l_login_usuario)  RETURNING g_nom_usu_cc, g_mail
            LET t_dados_aprov[p_arr].l_nom_usuario   = g_nom_usu_cc
            LET t_dados_aprov[p_arr].l_email_usuario = g_mail
            DISPLAY t_dados_aprov[p_arr].l_nom_usuario TO s_dados_aprov[p_scr].nom_usuario
            DISPLAY t_dados_aprov[p_arr].l_email_usuario   TO s_dados_aprov[p_scr].email_usuario
        END IF

      AFTER  FIELD ies_email_aprov
         LET p_arr = arr_curr()
         LET p_scr = scr_line()
         IF t_dados_aprov[p_arr].l_ies_email_aprov IS NULL THEN
            ERROR "Este campo deve ser preenchido."
            NEXT FIELD ies_email_aprov
         END IF

      AFTER INPUT
         LET p_arr = arr_curr()
         LET p_scr = scr_line()

         LET l_saida = TRUE
         EXIT INPUT

      END INPUT
    END WHILE
 END IF
 IF int_flag = 0  THEN
    LET g_input = 3
 ELSE
   LET p_status = 0
   LET g_input  = 0
   LET p_flagx  = 0
 END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION cdv0803_entrada_dados_email_aprovantes()  { g_input = 3 }
#------------------------------------------------#
 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
 ELSE
    CALL log006_exibe_teclas("01 02 03",m_versao_funcao)
    CURRENT WINDOW IS w_cap02217

    CALL cdv0803_dados_email_aprov() RETURNING g_text_email_aprov1, g_text_email_aprov2

    INPUT g_text_email_aprov1, g_text_email_aprov2 WITHOUT DEFAULTS
      FROM text_email_aprov1,   text_email_aprov2

       ON KEY (control-w, f1)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
          CALL cdv0803_help()

    END INPUT
    CALL log006_exibe_teclas("01",m_versao_funcao)
    CURRENT WINDOW IS w_cap02217
 END IF

 IF int_flag = 0  THEN
    LET g_input  = 4
 ELSE
   LET p_status = 0
   LET g_input  = 0
   LET p_flagx  = 0
 END IF

END FUNCTION

#--------------------------------#
 FUNCTION cdv0803_entrada_dados_2()  { g_input = 4 }
#--------------------------------#
 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
    LET g_email_cc_diverg = "N"
 ELSE
   CALL log006_exibe_teclas("01 02 03",m_versao_funcao)
   CURRENT WINDOW IS w_cap02217
   INPUT g_email_cc_diverg
    FROM ies_email_cc_diverg

   BEFORE FIELD ies_email_cc_diverg
    LET g_email_cc_diverg = "N"
    DISPLAY g_email_cc_diverg TO ies_email_cc_diverg

    IF t_dados_ccd[1].cc_usu_aprovante_ccd IS NULL THEN
       LET g_pula = TRUE
       EXIT INPUT
    END IF

   AFTER FIELD ies_email_cc_diverg
     IF g_email_cc_diverg IS NULL THEN
        ERROR " É obrigatório informar esse campo."
        NEXT FIELD ies_email_cc_diverg
     END IF

     IF g_email_cc_diverg = "N" THEN
        LET g_pula = TRUE
        EXIT INPUT
     END IF

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL cdv0803_help()

  END INPUT
  CALL log006_exibe_teclas("01",m_versao_funcao)
   CURRENT WINDOW IS w_cap02217
 END IF
  IF int_flag = 0  THEN
     IF g_pula = TRUE  THEN
        LET g_input = 7
        LET g_pula  = FALSE
     ELSE
        LET g_input = 5
     END IF
  ELSE
    LET p_status = 0
    LET g_input  = 0
    LET p_flagx  = 0
  END IF

END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv0803_entra_dados_array_cc_divergentes()  { g_input = 5 }
#--------------------------------------------------#
 DEFINE l_saida   SMALLINT

 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
 ELSE
   CURRENT WINDOW IS w_cap02217
   CALL cdv0803_verifica_dados_centro_custo_divergentes()

    LET l_saida = FALSE
    ERROR "DIGITE ESC P/ SAIR ..."

   WHILE l_saida = FALSE
    INPUT ARRAY t_dados_ccd WITHOUT DEFAULTS FROM s_dados_ccd.*

    BEFORE FIELD ies_email_ccd
       LET p_arr = arr_curr()
       LET p_scr = scr_line()
       IF t_dados_ccd[p_arr].login_usuario_ccd IS NULL  THEN
          LET t_dados_ccd[p_arr].ies_email_ccd = "N"
       END IF

    BEFORE FIELD login_usuario_ccd
       LET p_arr = arr_curr()
       LET p_scr = scr_line()

    AFTER FIELD login_usuario_ccd
      IF t_dados_ccd[p_arr].login_usuario_ccd IS NULL THEN
         CALL cdv0803_popup()
      END IF
      IF  t_dados_ccd[p_arr].login_usuario_ccd IS NOT NULL THEN
          CALL cdv0803_verifica_cod_usuario(t_dados_ccd[p_arr].login_usuario_ccd)  RETURNING g_nom_usu_cc, g_mail
          LET t_dados_ccd[p_arr].nom_usuario_ccd   = g_nom_usu_cc
          LET t_dados_ccd[p_arr].email_usuario_ccd = g_mail
          DISPLAY t_dados_ccd[p_arr].nom_usuario_ccd TO s_dados_ccd[p_scr].nom_usuario_ccd
          DISPLAY t_dados_ccd[p_arr].email_usuario_ccd   TO s_dados_ccd[p_scr].email_usuario_ccd
      END IF

    AFTER  FIELD ies_email_ccd
       LET p_arr = arr_curr()
       LET p_scr = scr_line()
       IF t_dados_ccd[p_arr].ies_email_ccd IS NULL THEN
          ERROR "Este campo deve ser preenchido."
          NEXT FIELD ies_email_ccd
       END IF

    AFTER INPUT
       LET p_arr = arr_curr()
       LET p_scr = scr_line()
          LET l_saida = TRUE
          EXIT INPUT

    ON KEY (control-z, f4)

    END INPUT
  END WHILE

 END IF
  IF int_flag = 0  THEN
     LET g_input = 6
  ELSE
    LET p_status = 0
    LET g_input  = 0
    LET p_flagx  = 0
  END IF

END FUNCTION

#----------------------------------------------------#
 FUNCTION cdv0803_entrada_dados_email_cc_divergentes()
#----------------------------------------------------#
 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
 ELSE
   CALL log006_exibe_teclas("01 02 03",m_versao_funcao)
   CURRENT WINDOW IS w_cap02217

   CALL cdv0803_busca_dados_email_ccd() RETURNING g_text_email_cc1, g_text_email_cc2

   INPUT g_text_email_cc1, g_text_email_cc2 WITHOUT DEFAULTS
    FROM text_email_cc1,   text_email_cc2

    ON KEY (control-w, f1)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CALL cdv0803_help()

  END INPUT
  CALL log006_exibe_teclas("01",m_versao_funcao)
  CURRENT WINDOW IS w_cap02217
 END IF

  IF int_flag = 0  THEN
     LET g_input = 7
  ELSE
    LET p_status = 0
    LET g_input  = 0
    LET p_flagx  = 0
  END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION cdv0803_dados_email_aprov()
#-----------------------------------------#
 DEFINE l_text_1, l_text_2    CHAR(70)

 WHENEVER ERROR CONTINUE
 SELECT par_txt INTO l_text_1
   FROM par_cap_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "text_email_aprov1"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD1")
     LET p_work = FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT par_txt INTO l_text_2
   FROM par_cap_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "text_email_aprov2"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD2")
     LET p_work = FALSE
 END IF

RETURN l_text_1, l_text_2

END FUNCTION

#-----------------------------------------#
 FUNCTION cdv0803_busca_dados_email_ccd()
#-----------------------------------------#
 DEFINE l_text_1, l_text_2    CHAR(70)

 WHENEVER ERROR CONTINUE
 SELECT par_txt INTO l_text_1
   FROM par_cap_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "text_email_cc1"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD1")
     LET p_work = FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT par_txt INTO l_text_2
   FROM par_cap_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "text_email_cc2"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD2")
     LET p_work = FALSE
 END IF

RETURN l_text_1, l_text_2
END FUNCTION

#---------------------------------------------------------------#
 FUNCTION cdv0803_verifica_se_existe_grade_aprov(l_env_nivel_sup)
#---------------------------------------------------------------#
 DEFINE p_grade_aprov_cap  RECORD LIKE grade_aprov_cap.*,
        p_val_cotacao      LIKE cotacao.val_cotacao,
        p_val_grade_1      DECIMAL(15,2),
        p_val_grade_2      DECIMAL(15,2),
        p_valor_convert    DECIMAL(15,2),
        p_qtd              SMALLINT
 DEFINE l_env_nivel_sup       CHAR(01)

 IF NOT p_ad_mestre.cod_moeda = p_par_cap.cod_moeda_padrao THEN
    WHENEVER ERROR CONTINUE
    SELECT val_cotacao INTO p_valor_convert
      FROM cotacao
     WHERE cod_moeda = p_ad_mestre.cod_moeda
       AND dat_ref = p_ad_mestre.dat_rec_nf
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       ERROR "Não há cotação para a moeda -> ",p_ad_mestre.cod_moeda CLIPPED," no dia ",p_ad_mestre.dat_rec_nf
       SLEEP 2
       RETURN 0
    END IF
    LET p_valor_convert = p_valor_convert * p_ad_mestre.val_tot_nf
 ELSE
    LET p_valor_convert = p_ad_mestre.val_tot_nf
 END IF

 DECLARE cq_cursor CURSOR FOR
  SELECT *
    FROM grade_aprov_cap
   WHERE cod_empresa = p_cod_empresa
     AND ies_versao_atual = "S"
     AND ies_grade_efetiv = "E"
     AND cod_tip_desp_ini <= p_ad_mestre.cod_tip_despesa
     AND cod_tip_desp_fim >= p_ad_mestre.cod_tip_despesa

 LET p_qtd = 0
 FOREACH cq_cursor INTO p_grade_aprov_cap.*
    LET g_num_versao_grade = p_grade_aprov_cap.num_versao
    IF p_grade_aprov_cap.cod_moeda <> p_par_cap.cod_moeda_padrao THEN
       WHENEVER ERROR CONTINUE
       SELECT val_cotacao INTO p_val_grade_1
         FROM cotacao
        WHERE cod_moeda = p_grade_aprov_cap.cod_moeda
          AND dat_ref = p_ad_mestre.dat_rec_nf
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          ERROR "Não há cotação para a moeda -> ",p_grade_aprov_cap.cod_moeda CLIPPED," no dia ",p_ad_mestre.dat_rec_nf
          SLEEP 2
          EXIT FOREACH
       END IF
       LET p_val_grade_2 = p_val_grade_1
       LET p_val_grade_1 = p_val_grade_1 * p_grade_aprov_cap.val_inicial
       LET p_val_grade_2 = p_val_grade_2 * p_grade_aprov_cap.val_final
    ELSE
       LET p_val_grade_1 = p_grade_aprov_cap.val_inicial
       LET p_val_grade_2 = p_grade_aprov_cap.val_final
    END IF
    IF (p_valor_convert >= p_val_grade_1) AND (p_valor_convert <= p_val_grade_2) THEN
       LET p_qtd = p_qtd + 1
       LET g_linha_grade = p_grade_aprov_cap.num_linha_grade
    END IF
 END FOREACH
 IF p_qtd > 1 THEN
    ERROR "Existe mais de uma linha de grade de aprovação para este compromisso."
    SLEEP 2
    RETURN 0
 END IF
 IF p_qtd = 0 THEN
    ERROR "Não existe linha na grade de aprovação para este compromisso."
    SLEEP 2
    RETURN 0
 END IF
 IF l_env_nivel_sup = "S" THEN
    WHENEVER ERROR CONTINUE
    SELECT MAX(num_linha_grade) INTO g_linha_grade
      FROM grade_aprov_cap
     WHERE cod_empresa = p_cod_empresa
       AND ies_versao_atual = "S"
       AND ies_grade_efetiv = "E"
       AND cod_tip_desp_ini <= p_ad_mestre.cod_tip_despesa
       AND cod_tip_desp_fim >= p_ad_mestre.cod_tip_despesa
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE = 0 THEN
    ELSE
       CALL log003_err_sql("SELECAO", "GRADE_APROV_CAP")
        LET p_work = FALSE
    END IF
 END IF
 IF cdv0803_tem_todos_aprovantes() THEN
    RETURN g_linha_grade
 ELSE
    RETURN 0
 END IF

END FUNCTION

#--------------------------------------#
FUNCTION cdv0803_tem_todos_aprovantes()
#--------------------------------------#
   DEFINE p_cod_uni_funcio   CHAR(10),
          p_den_nivel_autor  CHAR(30),
          p_ies_tip_autor    CHAR(01),
          p_uni_funcio_var   CHAR(10),
          p_tamanho          SMALLINT,
          p_qtd              SMALLINT,
          p_uni_func         SMALLINT,
          sql_stmt1          CHAR(400),
          l_cod_usuario      LIKE usu_cap_uni_func.cod_usuario,
          l_niv_autd_cc_debt LIKE cdv_par_ctr_viagem.niv_autd_cc_debt

   DEFINE p_arr_uni ARRAY[200] OF RECORD
                          cod_uni_funcio LIKE uni_funcional.cod_uni_funcio,
                          den_uni_funcio LIKE uni_funcional.den_uni_funcio,
                          cod_centro_custo LIKE uni_funcional.cod_centro_custo
                    END RECORD

   LET p_uni_func  = 0
   LET g_cent_cust = NULL
   LET p_aux_ct = 0

   {Seleciona Unidade Funcional do usuario   awc}
   LET l_cod_usuario = m_matricula_viajante

   DECLARE cq_unifun CURSOR FOR
    SELECT cod_uni_funcio
      FROM usu_cap_uni_func
     WHERE cod_empresa = p_cod_empresa
       AND cod_usuario = p_user1 #l_cod_usuario #p_user1

   FOREACH cq_unifun INTO p_cod_uni_funcio

      LET p_aux_ct = p_aux_ct + 1
      LET p_arr_uni[p_aux_ct].cod_uni_funcio = p_cod_uni_funcio

      DECLARE cq_den_uni_func CURSOR FOR
       SELECT den_uni_funcio, cod_centro_custo, dat_validade_ini
         FROM uni_funcional
        WHERE cod_uni_funcio = p_cod_uni_funcio
          AND cod_empresa    = p_cod_empresa
          AND dat_validade_fim > TODAY
        ORDER BY dat_validade_ini DESC

       FOREACH cq_den_uni_func INTO p_arr_uni[p_aux_ct].den_uni_funcio,
                                    p_arr_uni[p_aux_ct].cod_centro_custo
           EXIT FOREACH
       END FOREACH

       WHENEVER ERROR CONTINUE
       SELECT count(*)
         INTO p_uni_func
         FROM uni_funcional
        WHERE cod_uni_funcio = p_cod_uni_funcio
          AND cod_empresa    = p_cod_empresa
       WHENEVER ERROR STOP

       IF p_uni_func > 0 THEN
          CONTINUE FOREACH
       END IF

   END FOREACH

   IF p_aux_ct = 0 THEN
      ERROR "Não existe unidade funcional cadastrada para este usuário."
      SLEEP 2
      RETURN FALSE
   END IF

   IF p_aux_ct = 1 THEN
      LET p_uni_funcional = p_cod_uni_funcio
   END IF

   IF g_progr_aprov_eletr = "cap3230" AND
      g_uni_funcional IS NOT NULL THEN
       LET p_aux_ct = 1
   END IF

   IF g_progr_aprov_eletr = "cap3230" AND
      g_uni_funcional IS NOT NULL THEN
       LET p_uni_funcional = g_uni_funcional
   ELSE
       IF p_uni_funcional IS NULL THEN

           WHENEVER ERROR CONTINUE
           SELECT niv_autd_cc_debt
             INTO l_niv_autd_cc_debt
             FROM cdv_par_ctr_viagem
            WHERE empresa = p_cod_empresa
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
               LET l_niv_autd_cc_debt = NULL
           END IF

           IF m_num_viagem IS NOT NULL THEN
              WHENEVER ERROR CONTINUE
              SELECT UNIQUE unid_funcional
                INTO p_uni_funcional
                FROM cdv_aprov_necess
               WHERE empresa        = p_cod_empresa
                 AND num_viagem     = m_num_viagem
                 AND nivel_autorid <> l_niv_autd_cc_debt
              WHENEVER ERROR STOP

              IF SQLCA.sqlcode <> 0 THEN
                  CALL log130_procura_caminho("cap33801") RETURNING comand_cap
                  OPEN WINDOW w_cap33801 AT 07,10 WITH FORM comand_cap
                     ATTRIBUTE(BORDER, FORM LINE 1, MESSAGE LINE LAST, PROMPT LINE LAST)

                  CURRENT WINDOW IS w_cap33801

                  CALL set_count(p_aux_ct)
                  DISPLAY ARRAY p_arr_uni TO s_uni_funcional.*

                  CLOSE WINDOW w_cap33801

                  IF int_flag <> 0 THEN
                     LET int_flag = 1
                     RETURN FALSE
                  ELSE
                     LET p_aux_ct = arr_curr()
                     LET p_uni_funcional = p_arr_uni[p_aux_ct].cod_uni_funcio
                     IF p_arr_uni[p_aux_ct].cod_uni_funcio IS NULL THEN
                       LET int_flag = 1
                       RETURN FALSE
                     END IF
                  END IF
              END IF
           ELSE
              CALL log130_procura_caminho("cap33801") RETURNING comand_cap
              OPEN WINDOW w_cap33801 AT 07,10 WITH FORM comand_cap
                 ATTRIBUTE(BORDER, FORM LINE 1, MESSAGE LINE LAST, PROMPT LINE LAST)

              CURRENT WINDOW IS w_cap33801

              CALL set_count(p_aux_ct)
              DISPLAY ARRAY p_arr_uni TO s_uni_funcional.*

              CLOSE WINDOW w_cap33801

              IF int_flag <> 0 THEN
                 LET int_flag = 1
                 RETURN FALSE
              ELSE
                 LET p_aux_ct = arr_curr()
                 LET p_uni_funcional = p_arr_uni[p_aux_ct].cod_uni_funcio
                 IF p_arr_uni[p_aux_ct].cod_uni_funcio IS NULL THEN
                   LET int_flag = 1
                   RETURN FALSE
                 END IF
              END IF
           END IF
       END IF
   END IF

   IF p_uni_funcional IS NULL THEN
      RETURN FALSE
   ELSE
      LET g_uni_funcional = p_uni_funcional
   END IF

   CALL cdv0803_cria_temp_usuario()

   IF p_ies_forma_aprov = "2" THEN {aprovante nivel superior aprova inferiores}
      LET sql_stmt1 = "SELECT MAX(cod_nivel_autor) FROM aprov_grade"
   ELSE
      LET sql_stmt1 = "SELECT cod_nivel_autor FROM aprov_grade"
   END IF

   LET sql_stmt1 = sql_stmt1 CLIPPED,
                   " WHERE cod_empresa     = """,p_cod_empresa,""" ",
                   "   AND num_versao      = """,g_num_versao_grade,""" ",
                   "   AND num_linha_grade = """,g_linha_grade,""" "

   PREPARE var_query1 FROM sql_stmt1
   DECLARE cq_aprov_grade CURSOR FOR var_query1

   FOREACH cq_aprov_grade INTO p_cod_nivel_autor

      LET p_tamanho        = LENGTH(p_uni_funcional)
      LET p_uni_funcio_var = p_uni_funcional

      WHILE TRUE
         WHENEVER ERROR CONTINUE
         SELECT count(*)
           INTO p_qtd
           FROM usu_nivel_aut_cap
          WHERE ies_versao_atual = "S"
            AND cod_empresa      = p_cod_empresa
            AND cod_uni_funcio   = p_uni_funcio_var
            AND cod_nivel_autor  = p_cod_nivel_autor
            AND ies_versao_atual = "S"
            AND ies_ativo = "S"
         WHENEVER ERROR STOP

         IF p_qtd > 0 THEN
            EXIT WHILE
         ELSE
            IF g_aprov_raiz_uni_fun = "N" THEN
               EXIT WHILE
            ELSE
               LET p_uni_funcio_var[p_tamanho,p_tamanho] = "0"
            END IF
         END IF

         IF p_tamanho > 1 THEN
            LET p_tamanho = p_tamanho -1
         ELSE
            EXIT WHILE
         END IF
      END WHILE

      IF p_qtd = 0 THEN
         WHENEVER ERROR CONTINUE
         SELECT den_nivel_autor, ies_tip_autor
           INTO p_den_nivel_autor, p_ies_tip_autor
           FROM nivel_autor_cap
          WHERE cod_empresa     = p_cod_empresa
            AND cod_nivel_autor = p_cod_nivel_autor
         WHENEVER ERROR STOP

         IF p_ies_tip_autor = "G" THEN
            WHENEVER ERROR CONTINUE
            SELECT count(*) INTO p_qtd FROM usu_nivel_aut_cap
             WHERE ies_versao_atual = "S"
               AND cod_empresa     = p_cod_empresa
               AND cod_nivel_autor = p_cod_nivel_autor
               AND ies_ativo       = "S"
            WHENEVER ERROR STOP
         END IF

         IF p_qtd = 0 THEN
            ERROR "Nenhum usuário com nível ",p_cod_nivel_autor, " ",
                  p_den_nivel_autor CLIPPED," encontrado. (",
                  p_cod_empresa, ")-", p_uni_funcio_var, "."
            SLEEP 2
            #ERROR "Cod.Tipo Despesa: ",p_ad_mestre.cod_tip_despesa
            #SLEEP 10
            ERROR "Favor contactar Administrador do Sistema."
            SLEEP 2
            EXIT PROGRAM
         ELSE
            DECLARE ci_usuario CURSOR FOR
             SELECT cod_usuario
               FROM usu_nivel_aut_cap
              WHERE ies_versao_atual = "S"
                AND cod_empresa      = p_cod_empresa
                AND cod_nivel_autor  = p_cod_nivel_autor
                AND ies_ativo        = "S"

            FOREACH ci_usuario INTO g_cod_usuario

                WHENEVER ERROR CONTINUE
                SELECT nom_funcionario, e_mail
                  INTO g_nom_usuario, g_e_mail
                  FROM usuarios
                 WHERE cod_usuario = g_cod_usuario
                WHENEVER ERROR STOP

                IF SQLCA.SQLCODE = 0 THEN
                    INSERT INTO w_uni_func_e_niv VALUES (p_cod_nivel_autor,p_uni_funcio_var)
                    INSERT INTO w_usuario VALUES(g_cod_usuario, g_nom_usuario, g_e_mail, g_cent_cust)
                ELSE
                    CALL log003_err_sql("SELECAO", "USUARIOS")
                    LET p_work = FALSE
                END IF

            END FOREACH
         END IF
      ELSE
         DECLARE ci_busca_usuario CURSOR FOR
         SELECT cod_usuario FROM usu_nivel_aut_cap
          WHERE ies_versao_atual = "S"
            AND cod_empresa      = p_cod_empresa
            AND cod_uni_funcio   = p_uni_funcio_var
            AND cod_nivel_autor  = p_cod_nivel_autor
            AND ies_ativo = "S"

         FOREACH ci_busca_usuario INTO g_cod_usuario

             WHENEVER ERROR CONTINUE
             SELECT nom_funcionario, e_mail
               INTO g_nom_usuario, g_e_mail
               FROM usuarios
              WHERE cod_usuario = g_cod_usuario
             WHENEVER ERROR STOP

             IF SQLCA.SQLCODE = 0 THEN
                INSERT INTO w_uni_func_e_niv VALUES (p_cod_nivel_autor,p_uni_funcio_var)
                INSERT INTO w_usuario VALUES(g_cod_usuario, g_nom_usuario, g_e_mail, g_cent_cust)
             ELSE
                CALL log003_err_sql("SELECAO", "USUARIOS")
                 LET p_work = FALSE
             END IF

         END FOREACH
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION cdv0803_cria_temp_usuario()
#-----------------------------------#

WHENEVER ERROR CONTINUE
 DROP TABLE w_usuario
WHENEVER ERROR STOP

CREATE TEMP TABLE w_usuario
  (cod_usuario      CHAR(08),
   nom_usuario      CHAR(30),
   e_mail           CHAR(40),
   cod_cent_cust    CHAR(11)) WITH NO LOG;

WHENEVER ERROR CONTINUE
 DROP TABLE w_unid_s_apr
 DROP TABLE w_uni_func_e_niv
WHENEVER ERROR STOP

CREATE TEMP TABLE w_unid_s_apr
   (cod_nivel_autor CHAR(02))

 CREATE TEMP TABLE w_uni_func_e_niv
  (
  cod_nivel_autor CHAR(02),
  cod_uni_funcio char(10)
  )

END FUNCTION

#------------------------------------------#
 FUNCTION cdv0803_insere_dados_array_aprov()
#------------------------------------------#
 DEFINE l_ies_env_email     CHAR(01)

 DEFINE l_w_usuario  RECORD
                      cod_usuario      CHAR(08),
                      nom_usuario      CHAR(30),
                      e_mail           CHAR(40)
                     END RECORD

 INITIALIZE l_w_usuario.* TO NULL

 IF g_email_aprovante = "T" THEN
    LET l_ies_env_email = "N"
 ELSE
    IF g_email_aprovante = "S" THEN
       LET l_ies_env_email = "N"
    END IF
 END IF

 LET g_contador = 0

 DECLARE cq_busca_dados CURSOR FOR
  SELECT * FROM w_usuario

 FOREACH cq_busca_dados INTO l_w_usuario.*
      LET g_contador = g_contador + 1
      LET t_dados_aprov[g_contador].l_ies_email_aprov   = l_ies_env_email
      LET t_dados_aprov[g_contador].l_login_usuario     = l_w_usuario.cod_usuario
      LET t_dados_aprov[g_contador].l_nom_usuario       = l_w_usuario.nom_usuario
      LET t_dados_aprov[g_contador].l_email_usuario     = l_w_usuario.e_mail

      IF g_contador < 3  THEN
         DISPLAY t_dados_aprov[g_contador].* TO s_dados_aprov[g_contador].*
      END IF
 END FOREACH


END FUNCTION

#------------------------------------------#
 FUNCTION cdv0803_carrega_email_aprovantes()
#------------------------------------------#
 DEFINE l_texto_default   CHAR(200),
        l_relat           CHAR(25),
        l_comando         CHAR(200) #carloszen 29/01/2002

 LET l_texto_default = g_text_email_aprov1 CLIPPED, g_text_email_aprov2

 # carloszen 29/01/2002
 LET l_relat = "mail_aprov_" , cdv0803_tira_espacos(p_ad_mestre.num_ad) , ".txt"

 START REPORT cdv0803_relatorio_aprov TO l_relat

 OUTPUT TO REPORT cdv0803_relatorio_aprov(l_texto_default)

 FINISH REPORT cdv0803_relatorio_aprov

 # carloszen 29/01/2002
 LET l_comando = "chmod 777 ", l_relat CLIPPED
 RUN l_comando

END FUNCTION

#-----------------------------------------------#
 REPORT cdv0803_relatorio_aprov(p_texto_def_aprov)
#------------------------------------------------#
 DEFINE  p_texto_def_aprov  CHAR(200)
 OUTPUT TOP    MARGIN 0
        LEFT   MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH 1

 FORMAT
  ON EVERY ROW
     PRINT
     PRINT COLUMN 001, "***  A T E N C A O  ***"
     PRINT
     PRINT
     PRINT COLUMN 001, p_texto_def_aprov
     PRINT
     PRINT
     PRINT COLUMN 001, "Numero AD : ", p_ad_mestre.num_ad USING "######"
     PRINT COLUMN 001, "Tipo Desp.: ", p_tip_desp.nom_tip_despesa CLIPPED
     PRINT COLUMN 001, "Fornecedor: ", p_raz_social CLIPPED
     PRINT COLUMN 006,      "Valor: ", p_ad_mestre.val_tot_nf USING "######,###,##&.&&" CLIPPED
     PRINT
     PRINT COLUMN 001, "Pendente de Aprovacao para a Empresa: ", p_ad_mestre.cod_empresa
 END REPORT

#------------------------------------------#
FUNCTION cdv0803_dispara_email_aprovantes()
#------------------------------------------#
DEFINE  l_conta             SMALLINT,
        l_comando           CHAR(500),
        l_comand_mail_unix  CHAR(15),
        l_comand_mail       CHAR(15),
        l_arquivo           CHAR(30) ##carloszen

 IF p_ad_mestre.num_ad IS NOT NULL THEN
    LET l_arquivo = "mail_aprov_" ,cdv0803_tira_espacos(p_ad_mestre.num_ad) ,".txt"
 ELSE
    LET l_arquivo = "mail_aprov_" ,cdv0803_tira_espacos(m_viagem) ,".txt"
 END IF

 INITIALIZE l_comando TO NULL
 CALL cdv0803_busca_comando_email_unix() RETURNING l_comand_mail
 LET l_comand_mail_unix = l_comand_mail CLIPPED
 FOR l_conta = 1 TO 99
    IF t_dados_aprov[l_conta].l_ies_email_aprov = "S" THEN
       IF t_dados_aprov[l_conta].l_nom_usuario IS NOT NULL THEN

         #carloszen 29/01/2002


         LET l_comando =  l_comand_mail_unix ,'" Pendencias de Aprovacao Eletronica !!!" ',
                          t_dados_aprov[l_conta].l_email_usuario CLIPPED," < ", l_arquivo CLIPPED

         RUN l_comando

       ELSE
         ERROR " E-mail não cadastrado para o aprovante: ", t_dados_aprov[l_conta].l_nom_usuario  ATTRIBUTE(REVERSE)
         SLEEP 3
       END IF
    END IF
 END FOR

 LET l_arquivo = l_arquivo CLIPPED

 IF l_arquivo IS NOT NULL
 AND l_comando IS NOT NULL THEN
   LET l_comando = "rm ", l_arquivo CLIPPED
   RUN l_comando
 END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION cdv0803_busca_comando_email_unix()
#-------------------------------------------#
 DEFINE l_comand_mail_unix   CHAR(15)

 WHENEVER ERROR CONTINUE
 SELECT par_txt  INTO l_comand_mail_unix
   FROM par_cap_pad
  WHERE cod_empresa = p_cod_empresa
    AND cod_parametro = "comand_mail_unix"
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD3")
     LET p_work = FALSE
 END IF

RETURN l_comand_mail_unix

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv0803_carrega_email_cc_divergentes()
#----------------------------------------------#
DEFINE p_texto_default   CHAR(200),
       l_relat           CHAR(25),
       l_comando         CHAR(200) #carloszen 29/01/2002

 LET p_texto_default = g_text_email_cc1, g_text_email_cc2

 #carloszen 29/01/2002
 #LET l_relat = "mail_ccd.txt"
 LET l_relat = "mail_ccd_",cdv0803_tira_espacos(p_ad_mestre.num_ad) ,".txt"
 START REPORT cdv0803_relatorio_aprov TO l_relat

 OUTPUT TO REPORT cdv0803_relatorio_aprov(p_texto_default)

 FINISH REPORT cdv0803_relatorio_aprov

 #carloszen 29/01/2002
 #RUN "chmod 777 mail_ccd.txt"
 LET l_comando = "chmod 777 ", l_relat CLIPPED
 RUN l_comando


END FUNCTION

#-----------------------------------------------#
 REPORT cdv0803_relatorio_ccd(p_texto_def_ccd)
#------------------------------------------------#
 DEFINE  p_texto_def_ccd  CHAR(200)
 OUTPUT TOP    MARGIN 0
        LEFT   MARGIN 0
        BOTTOM MARGIN 0
        PAGE   LENGTH 1

 FORMAT
  ON EVERY ROW
     PRINT
     PRINT COLUMN 001, "***  A T E N C A O  ***"
     PRINT
     PRINT
     PRINT COLUMN 001, p_texto_def_ccd
     PRINT
     PRINT
     PRINT COLUMN 001, "Numero AD : ", p_ad_mestre.num_ad USING "######"
     PRINT COLUMN 001, "Tipo Desp.: ", p_tip_desp.nom_tip_despesa CLIPPED
     PRINT COLUMN 001, "Fornecedor: ", p_raz_social CLIPPED
     PRINT COLUMN 006,      "Valor: ", p_ad_mestre.val_tot_nf USING "######,###,##&.&&" CLIPPED
     PRINT
     PRINT COLUMN 001, "Pendente de Aprovacao para a Empresa: ", p_ad_mestre.cod_empresa
 END REPORT

#-----------------------------------------------#
 FUNCTION cdv0803_dispara_email_cc_divergentes()
#-----------------------------------------------#
 DEFINE l_conta           SMALLINT,
        l_comando         CHAR(500),
        l_comand_mail_unix  CHAR(15),
        l_comand_mail       CHAR(15),
        l_arquivo           CHAR(30) #carloszen

 IF p_ad_mestre.num_ad IS NOT NULL THEN
    LET l_arquivo = "mail_ccd_" , cdv0803_tira_espacos(p_ad_mestre.num_ad), ".txt"
 ELSE
    LET l_arquivo = "mail_ccd_" , cdv0803_tira_espacos(m_viagem), ".txt"
 END IF

 INITIALIZE l_comando TO NULL
 CALL cdv0803_busca_comando_email_unix() RETURNING l_comand_mail
 LET l_comand_mail_unix = l_comand_mail CLIPPED

 FOR l_conta = 1 TO 99
    IF t_dados_ccd[l_conta].ies_email_ccd = "S" THEN
       IF t_dados_ccd[l_conta].email_usuario_ccd IS NOT NULL THEN
          {LET l_comando =  l_comand_mail_unix ,'" Aprovantes de C.C. Divergentes !!!" ',
                           t_dados_ccd[l_conta].email_usuario_ccd CLIPPED," < mail_ccd.txt"}

          LET l_comando =  l_comand_mail_unix ,'" Aprovantes de C.C. Divergentes !!!" ',
                           t_dados_ccd[l_conta].email_usuario_ccd CLIPPED," < ",l_arquivo CLIPPED

          RUN l_comando

       ELSE
         ERROR " E-mail não cadastrado para o aprovante: ", t_dados_ccd[l_conta].nom_usuario_ccd  ATTRIBUTE(REVERSE)
         SLEEP 3
       END IF
    END IF
 END FOR

   #carloszen 29/01/2001
  LET l_arquivo = l_arquivo CLIPPED

 IF l_arquivo IS NOT NULL
 AND l_comando IS NOT NULL THEN
   LET l_comando = "rm ", l_arquivo CLIPPED
   RUN l_comando
 END IF
  #


END FUNCTION
#---------------------#
 FUNCTION cdv0803_help()
#---------------------#
  CASE
     WHEN infield(ies_env_nivel_sup)    CALL showhelp(0001)
     WHEN infield(ies_email_aprovant)   CALL showhelp(0001)
     WHEN infield(text_email_aprov1)    CALL showhelp(0001)
     WHEN infield(text_email_aprov2)    CALL showhelp(0001)
     WHEN infield(ies_email_cc_diverg)  CALL showhelp(0001)
     WHEN infield(text_email_cc1)       CALL showhelp(0001)
     WHEN infield(text_email_cc2)       CALL showhelp(0001)
  END CASE

END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv0803_verifica_dados_centro_custo_divergentes()
#---------------------------------------------------------#
 DEFINE l_indice   SMALLINT,
        l_indice_2 smallint


 CALL cdv0803_busca_mascara_cc_par_con()

 FOR l_indice = 1 TO 500
   IF t_lanc_cont[l_indice].num_conta_cont IS NULL THEN
      EXIT FOR
   ELSE
     CALL con088_verifica_cod_conta(p_cod_empresa, t_lanc_cont[l_indice].num_conta_cont, "S"," ")
     RETURNING p_plano_contas.*, p_status_cap
     IF p_plano_contas.ies_tip_conta <> 8 THEN
        CONTINUE FOR
     ELSE
        IF g_tipo_mascara = "S" THEN
           LET g_cc_div_plan_con = p_plano_contas.num_conta[6,9]
           FOR l_indice_2 = 1 TO 99
               IF g_cc_div_plan_con = t_dados_ccd[l_indice_2].cc_usu_aprovante_ccd THEN
                  EXIT FOR
               ELSE
                  LET t_dados_ccd[l_indice].cc_usu_aprovante_ccd = g_cc_div_plan_con
               END IF
           END FOR
        ELSE
           LET g_cc_div_plan_con = p_plano_contas.num_conta[3,6]
           FOR l_indice_2 = 1 TO 99
               IF g_cc_div_plan_con = t_dados_ccd[l_indice_2].cc_usu_aprovante_ccd THEN
                  EXIT FOR
               ELSE
                  LET t_dados_ccd[l_indice].cc_usu_aprovante_ccd = g_cc_div_plan_con
               END IF
           END FOR
        END IF
     END IF
   END IF
 END FOR
 CALL set_count(l_indice)

END FUNCTION

#------------------------------------------#
 FUNCTION cdv0803_busca_mascara_cc_par_con()
#------------------------------------------#
 WHENEVER ERROR CONTINUE
 SELECT ies_mao_obra INTO g_tipo_mascara
   FROM par_con
  WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
   CALL log003_err_sql("SELECAO", "PAR_CON")
   LET p_work = FALSE
 END IF

END FUNCTION

#------------------------#
 FUNCTION cdv0803_popup()
#------------------------#
 DEFINE l_log_usu_ccd     CHAR(08)
 IF g_par_envia_email = "N" AND
    g_par_aprov_topo  = "N" THEN
 ELSE
   CALL log006_exibe_teclas("02 08 17 18 10", m_versao_funcao)
   CURRENT WINDOW IS w_cap02217

   CASE
     WHEN infield(login_usuario_ccd)
         #LET l_log_usu_ccd = cap534_popup_usuario_subs_cap_novo()
          LET l_log_usu_ccd = cap343_popup_usuario_cap(TRUE)
          IF l_log_usu_ccd IS NOT NULL  THEN
             LET t_dados_ccd[p_arr].login_usuario_ccd = l_log_usu_ccd
             CALL log006_exibe_teclas("02 08 17 18 10", m_versao_funcao)
             CURRENT WINDOW IS w_cap02217
             DISPLAY t_dados_ccd[p_arr].login_usuario_ccd   TO s_dados_ccd[p_scr].login_usuario_ccd
          END IF
     WHEN infield(login_usuario)
          LET l_log_usu_ccd = cap343_popup_usuario_cap(TRUE)
          IF l_log_usu_ccd IS NOT NULL  THEN
             LET t_dados_aprov[p_arr].l_login_usuario = l_log_usu_ccd
             CALL log006_exibe_teclas("02 08 17 18 10", m_versao_funcao)
             CURRENT WINDOW IS w_cap02217
             DISPLAY t_dados_aprov[p_arr].l_login_usuario TO s_dados_aprov[p_scr].login_usuario
          END IF
   END CASE
   CALL log006_exibe_teclas("01 02 07", m_versao_funcao)
   CURRENT WINDOW IS w_cap02217
 END IF
END FUNCTION

#-------------------------------------------#
 FUNCTION cdv0803_verifica_cod_usuario(l_login_usu)
#-------------------------------------------#
 DEFINE  l_nom_usu_cc  CHAR(30),
         l_mail        CHAR(40),
         l_login_usu   CHAR(08)

 WHENEVER ERROR CONTINUE
 SELECT nom_funcionario, e_mail INTO l_nom_usu_cc, l_mail
   FROM usuarios
  WHERE cod_usuario = l_login_usu
 WHENEVER ERROR STOP

 IF  sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("SELECAO", "USUARIOS")
     LET p_work = FALSE
 END IF

 RETURN l_nom_usu_cc, l_mail

 END FUNCTION

#-----------------------------#
 FUNCTION cdv0803_inicializa()
#-----------------------------#
 INITIALIZE g_cod_usuario, g_nom_usuario, g_e_mail, g_cent_cust, g_cod_usuario_ccd,
            g_nom_usuario_ccd, g_e_mail_ccd, g_tipo_mascara, g_cc_div_plan_con,
            g_nom_usu_cc, t_dados_aprov, g_mail TO NULL

 END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv0803_verifica_aprov_aut(l_nivel_autorid)
#------------------------------------------------------#
   DEFINE l_count               SMALLINT
   DEFINE l_count2              SMALLINT
   DEFINE l_cod_nivel_autor     LIKE usu_nivel_aut_cap.cod_nivel_autor
   DEFINE l_niv_autd_cc_debt    LIKE cdv_par_ctr_viagem.niv_autd_cc_debt
   DEFINE l_niv_max_acresc      CHAR(02)
   DEFINE l_nivel_autorid       LIKE aprov_necessaria.cod_nivel_autor
   DEFINE l_nivel_autorid1      LIKE aprov_necessaria.cod_nivel_autor
   DEFINE l_cod_usuario         LIKE usu_nivel_aut_cap.cod_usuario
   DEFINE l_matricula_aprovador LIKE cdv_info_viajante.matricula
   DEFINE l_nivel_aut_oper      CHAR(02)
   DEFINE l_niv_autd_agenc      CHAR(02)

   LET l_count  = 0
   LET l_count2 = 0

   WHENEVER ERROR CONTINUE
   SELECT niv_autd_cc_debt
     INTO l_niv_autd_cc_debt
     FROM cdv_par_ctr_viagem
    WHERE empresa = p_cod_empresa
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
       LET l_niv_autd_cc_debt = NULL
   END IF

   WHENEVER ERROR CONTINUE
   SELECT parametro_texto
     INTO l_niv_max_acresc
     FROM cdv_par_padrao
    WHERE empresa   = p_cod_empresa
      AND parametro = 'ult_niv_atualiz'
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      LET l_niv_max_acresc = NULL
   END IF

   WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO l_nivel_aut_oper
      FROM cdv_par_padrao
     WHERE empresa   = p_cod_empresa
       AND parametro = "nivel_aut_oper"
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      LET l_nivel_aut_oper = NULL
   END IF

   WHENEVER ERROR CONTINUE
    SELECT niv_autd_agenc
      INTO l_niv_autd_agenc
      FROM cdv_par_ctr_viagem
     WHERE empresa = p_cod_empresa
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode <> 0 THEN
      LET l_niv_autd_agenc = NULL
   END IF

   INITIALIZE l_cod_nivel_autor TO NULL

   WHENEVER ERROR CONTINUE
    SELECT matricula
      INTO l_matricula_aprovador
      FROM cdv_info_viajante
     WHERE empresa       = p_cod_empresa
       AND usuario_logix = p_user_ant
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode = 0 THEN
       WHENEVER ERROR CONTINUE
       SELECT *
         FROM cdv_funcio_excecao
        WHERE empresa   = p_cod_empresa
          AND matricula = l_matricula_aprovador
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 AND l_nivel_autorid <> l_nivel_aut_oper AND l_nivel_autorid <> l_niv_autd_agenc THEN
          LET m_usuario_aprovante = p_user_ant
          RETURN TRUE
       END IF
   END IF

   WHENEVER ERROR CONTINUE
   SELECT cod_nivel_autor
     FROM usu_nivel_aut_cap
    WHERE cod_empresa      = p_cod_empresa
      AND cod_uni_funcio   = p_uni_funcional
      AND ies_versao_atual = "S"
      AND ies_ativo        = "S"
      AND cod_usuario      = p_user1
      AND cod_nivel_autor  = l_nivel_autorid
      AND cod_nivel_autor  NOT IN (l_niv_autd_cc_debt)
   WHENEVER ERROR STOP

   IF SQLCA.sqlcode = 0 THEN
       IF l_nivel_autorid > l_niv_max_acresc THEN
          LET m_usuario_aprovante = p_user1
          RETURN TRUE
       END IF

       WHILE TRUE
           LET l_nivel_autorid1 = l_nivel_autorid + 1
           LET l_nivel_autorid = l_nivel_autorid1 USING "&&"

           WHENEVER ERROR CONTINUE
           SELECT cod_usuario
             INTO l_cod_usuario
             FROM usu_nivel_aut_cap
            WHERE cod_empresa      = p_cod_empresa
              AND cod_uni_funcio   = p_uni_funcional
              AND ies_versao_atual = "S"
              AND ies_ativo        = "S"
              AND cod_nivel_autor  = l_nivel_autorid
              AND cod_nivel_autor  NOT IN (l_niv_autd_cc_debt)
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode = 0 THEN
               IF l_cod_usuario = p_user_ant THEN
                  LET m_usuario_aprovante = p_user_ant
                  RETURN TRUE
               ELSE
                   RETURN FALSE
               END IF
           ELSE
               IF l_nivel_autorid >= l_niv_max_acresc THEN
                   LET l_nivel_autorid1 = l_nivel_autorid - 1
                   LET l_nivel_autorid  = l_nivel_autorid1 USING "&&"
                   LET m_usuario_aprovante = p_user1
                   RETURN TRUE
               END IF
           END IF
       END WHILE
   ELSE
       WHENEVER ERROR CONTINUE
       SELECT cod_nivel_autor
         FROM usu_nivel_aut_cap
        WHERE cod_empresa      = p_cod_empresa
          AND cod_uni_funcio   = p_uni_funcional
          AND ies_versao_atual = "S"
          AND ies_ativo        = "S"
          AND cod_usuario      = p_user_ant
          AND cod_nivel_autor  = l_nivel_autorid
          AND cod_nivel_autor  NOT IN (l_niv_autd_cc_debt)
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 THEN
          LET m_usuario_aprovante = p_user_ant
          RETURN TRUE
       ELSE
           RETURN FALSE
       END IF
   END IF

END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv0803_atualiz_aprov_necessaria(l_ies_aprov_aut)
#----------------------------------------------------------#
  DEFINE l_data                 DATE,
         l_ies_aprov_aut        CHAR(01),
         l_ies_tip_autor        LIKE nivel_autor_cap.ies_tip_autor,
         l_cod_usuario          LIKE usu_nivel_aut_cap.cod_usuario,
         l_email                LIKE usuarios.e_mail,
         l_matricula_aprovador  LIKE cdv_info_viajante.matricula,
         l_sequencia_protocol   LIKE cdv_protocol.sequencia_protocol,
         l_matricula_viajante   LIKE cdv_solic_viagem.matricula_viajante,
         l_usuario_viajante     LIKE cdv_info_viajante.usuario_logix,
         l_min_nivel_autor      CHAR(02),
         l_cc_viajante          LIKE cdv_relat_viagem.cc_viajante,
         l_cc_debitar           LIKE cdv_relat_viagem.cc_debitar,
         l_cc_divergente        SMALLINT,
         l_nivel_inf            SMALLINT,
         l_matricula_remetente  LIKE cdv_info_viajante.matricula

  IF p_usa_aprovacao = "S" THEN
      DECLARE cq_insere_necess1 CURSOR FOR
       SELECT cod_nivel_autor
         FROM aprov_grade
        WHERE cod_empresa     = p_cod_empresa
          AND num_versao      = g_num_versao_grade
          AND num_linha_grade = g_linha_grade
        ORDER BY cod_nivel_autor

      FOREACH cq_insere_necess1 INTO p_aprov_necessaria.cod_nivel_autor

         WHENEVER ERROR CONTINUE
         SELECT cod_uni_funcio
           INTO p_aprov_necessaria.cod_uni_funcio
           FROM w_uni_func_e_niv
          WHERE cod_nivel_autor = p_aprov_necessaria.cod_nivel_autor
         WHENEVER ERROR STOP

         LET p_aprov_necessaria.cod_empresa     = p_cod_empresa
         LET p_aprov_necessaria.num_ad          = p_ad_mestre.num_ad
         LET p_aprov_necessaria.num_versao      = g_num_versao_grade
         LET p_aprov_necessaria.num_linha_grade = g_linha_grade
         LET p_aprov_necessaria.ies_aprovado    = "N"
         LET p_aprov_necessaria.dat_aprovacao   = NULL

         IF cdv0803_verifica_aprov_aut(p_aprov_necessaria.cod_nivel_autor) AND l_ies_aprov_aut = "S" THEN
            LET l_data                               = TODAY
            LET p_aprov_necessaria.ies_aprovado      = "S"
            LET p_aprov_necessaria.cod_usuario_aprov = m_usuario_aprovante
            LET p_aprov_necessaria.dat_aprovacao     = l_data
            LET p_aprov_necessaria.hor_aprovacao     = TIME
            LET p_aprov_necessaria.observ_aprovacao  = "Aprovado Automatico"
         ELSE
            LET p_aprov_necessaria.cod_usuario_aprov = NULL
            LET p_aprov_necessaria.dat_aprovacao     = NULL
            LET p_aprov_necessaria.hor_aprovacao     = NULL
            LET p_aprov_necessaria.observ_aprovacao  = NULL
         END IF

         WHENEVER ERROR CONTINUE
         SELECT *
           FROM aprov_necessaria
          WHERE cod_empresa     = p_aprov_necessaria.cod_empresa
            AND num_ad          = p_aprov_necessaria.num_ad
            AND cod_nivel_autor = p_aprov_necessaria.cod_nivel_autor
         WHENEVER ERROR STOP

         IF SQLCA.sqlcode = 0 THEN
            CONTINUE FOREACH
         END IF

         WHENEVER ERROR CONTINUE
          INSERT INTO aprov_necessaria VALUES(p_aprov_necessaria.*)
         WHENEVER ERROR STOP

         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO", "APROV_NECESSARIA1")
            LET p_work = FALSE
         END IF

         # GERAÇÃO DO PROTOCOLO
         IF p_aprov_necessaria.ies_aprovado = 'N' THEN

             LET l_cc_divergente = FALSE

             WHENEVER ERROR CONTINUE
             SELECT cc_viajante, cc_debitar
               INTO l_cc_viajante, l_cc_debitar
               FROM cdv_acer_viag_781
              WHERE empresa         = p_aprov_necessaria.cod_empresa
                AND ad_acerto_conta = p_ad_mestre.num_ad
             WHENEVER ERROR STOP

             IF SQLCA.SQLCODE = 0 THEN
                 IF l_cc_viajante <> l_cc_debitar THEN
                     LET l_cc_divergente = TRUE
                 END IF
             END IF

             LET l_nivel_inf = FALSE

             WHENEVER ERROR CONTINUE
             SELECT UNIQUE cod_empresa
               FROM aprov_necessaria
              WHERE cod_empresa     = p_aprov_necessaria.cod_empresa
                AND num_ad          = p_ad_mestre.num_ad
                AND cod_nivel_autor < p_aprov_necessaria.cod_nivel_autor
                AND ies_aprovado    = 'N'
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode = 0 THEN
                 LET l_nivel_inf = TRUE
             END IF

             WHENEVER ERROR CONTINUE
             SELECT ies_tip_autor
               INTO l_ies_tip_autor
               FROM nivel_autor_cap
              WHERE cod_empresa     = p_aprov_necessaria.cod_empresa
                AND cod_nivel_autor = p_aprov_necessaria.cod_nivel_autor
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode <> 0 THEN
                CALL log0030_mensagem("Nível de autoridade não cadastrado.",'info')
                LET p_work   = FALSE
                LET p_status = 0
                RETURN FALSE
             END IF

             IF l_ies_tip_autor = 'H' THEN
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = p_aprov_necessaria.cod_empresa
                    AND cod_uni_funcio   = p_aprov_necessaria.cod_uni_funcio
                    AND cod_nivel_autor  = p_aprov_necessaria.cod_nivel_autor
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             ELSE
                 # Genérico não olha a Unidade Funcional
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = p_aprov_necessaria.cod_empresa
                    AND cod_nivel_autor  = p_aprov_necessaria.cod_nivel_autor
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             END IF

             WHENEVER ERROR CONTINUE
             SELECT matricula
               INTO l_matricula_aprovador
               FROM cdv_info_viajante
              WHERE empresa       = p_aprov_necessaria.cod_empresa
                AND usuario_logix = l_cod_usuario
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode = 0 THEN

                 WHENEVER ERROR CONTINUE
                 SELECT MAX(sequencia_protocol)
                   INTO l_sequencia_protocol
                   FROM cdv_protocol
                  WHERE empresa    = p_aprov_necessaria.cod_empresa
                    AND num_viagem = m_num_viagem
                 WHENEVER ERROR STOP

                 IF l_sequencia_protocol IS NULL THEN
                     LET l_sequencia_protocol = 1
                 ELSE
                     LET l_sequencia_protocol = l_sequencia_protocol + 1
                 END IF

                 ## Se for o CDV0060 o Rementente deve ser o Agenciador
                 IF g_cdv0060 = 'S' THEN
                     WHENEVER ERROR CONTINUE
                     SELECT matricula
                       INTO l_matricula_remetente
                       FROM cdv_info_viajante
                      WHERE empresa       = p_aprov_necessaria.cod_empresa
                        AND usuario_logix = p_user_ant
                     WHENEVER ERROR STOP
                 ELSE # Os outros programas o Rementente é o viajante
                     WHENEVER ERROR CONTINUE
                     SELECT viajante
                       INTO l_matricula_remetente
                       FROM cdv_solic_viag_781
                      WHERE empresa  = p_aprov_necessaria.cod_empresa
                        AND viagem   = m_num_viagem
                     WHENEVER ERROR STOP
                 END IF

                 IF g_cdv0061 = 'S' THEN
                     LET mr_cdv_protocol.usuario_remetent = p_user_ant
                 ELSE
                     LET mr_cdv_protocol.usuario_remetent = p_user1
                 END IF

                 # Protocolo de Envio
                 LET mr_cdv_protocol.empresa            = p_aprov_necessaria.cod_empresa
                 LET mr_cdv_protocol.num_viagem         = m_num_viagem
                 LET mr_cdv_protocol.sequencia_protocol = l_sequencia_protocol
                 LET mr_cdv_protocol.dat_hor_env_recb   = log0300_current(g_ies_ambiente) #Rafael - OS317282
                 LET mr_cdv_protocol.status_protocol    = 5 #Enviado para Aprovação Eletrônica
                 LET mr_cdv_protocol.matr_receb_docum   = l_matricula_remetente
                 LET mr_cdv_protocol.matr_dest_protocol = l_matricula_aprovador
                 LET mr_cdv_protocol.obs_protocol       = 'ENVIADO PARA APROVACAO'
                 LET mr_cdv_protocol.dat_hor_remetent   = log0300_current(g_ies_ambiente) #Rafael - OS317282
                 LET mr_cdv_protocol.num_protocol       = p_ad_mestre.cod_tip_despesa
                 LET mr_cdv_protocol.dat_hor_despacho   = log0300_current(g_ies_ambiente) #Rafael - OS317282

                 IF l_cc_divergente = FALSE AND l_nivel_inf = FALSE THEN
                     WHENEVER ERROR CONTINUE
                     INSERT INTO cdv_protocol ( empresa, num_viagem, dat_hor_env_recb, status_protocol, matr_receb_docum, matr_dest_protocol, obs_protocol, usuario_remetent, dat_hor_remetent, num_protocol, dat_hor_despacho )  VALUES ( mr_cdv_protocol.empresa, mr_cdv_protocol.num_viagem, mr_cdv_protocol.dat_hor_env_recb, mr_cdv_protocol.status_protocol, mr_cdv_protocol.matr_receb_docum, mr_cdv_protocol.matr_dest_protocol, mr_cdv_protocol.obs_protocol, mr_cdv_protocol.usuario_remetent, mr_cdv_protocol.dat_hor_remetent, mr_cdv_protocol.num_protocol, mr_cdv_protocol.dat_hor_despacho)
                     WHENEVER ERROR STOP

                     IF SQLCA.sqlcode <> 0 THEN
                         CALL log003_err_sql("INCLUSAO", "cdv_protocol")
                         LET p_work   = FALSE
                         LET p_status = 0
                         RETURN FALSE
                     END IF
                 END IF
             END IF
         END IF
         # TÉRMINO GERAÇÃO DO PROTOCOLO

         # Geração de tabela temporária para envio de EMAIL
         IF p_aprov_necessaria.ies_aprovado = 'N' THEN
             WHENEVER ERROR CONTINUE
             SELECT ies_tip_autor
               INTO l_ies_tip_autor
               FROM nivel_autor_cap
              WHERE cod_empresa     = p_aprov_necessaria.cod_empresa
                AND cod_nivel_autor = p_aprov_necessaria.cod_nivel_autor
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode <> 0 THEN
                 CONTINUE FOREACH
             END IF

             IF l_ies_tip_autor = 'H' THEN
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = p_aprov_necessaria.cod_empresa
                    AND cod_uni_funcio   = p_aprov_necessaria.cod_uni_funcio
                    AND cod_nivel_autor  = p_aprov_necessaria.cod_nivel_autor
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             ELSE
                 # Genérico não olha a Unidade Funcional
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = p_aprov_necessaria.cod_empresa
                    AND cod_nivel_autor  = p_aprov_necessaria.cod_nivel_autor
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             END IF

             IF SQLCA.sqlcode = 0 THEN

                 SELECT e_mail
                   INTO l_email
                   FROM usuarios
                  WHERE cod_usuario = l_cod_usuario

                 IF SQLCA.sqlcode = 0 THEN
                     INSERT INTO t_envio_email VALUES
                     (p_aprov_necessaria.num_ad, l_email, p_aprov_necessaria.cod_nivel_autor)

                     IF SQLCA.sqlcode <> 0 THEN
                         CONTINUE FOREACH
                     END IF
                 END IF
             END IF
         END IF
         # Término - Geração de tabela temporária para envio de EMAIL

      END FOREACH
     WHENEVER ERROR STOP

     CALL cdv0803_verifica_se_altera_status_ad()
     #CALL cdv0803_cria_regs_cc_a_debitar(p_cod_empresa, p_ad_mestre.num_ad,
     #                                    g_num_versao_grade, g_linha_grade)
     CALL cdv0803_verifica_excecao()

     SELECT MIN(cod_nivel_autor)
       INTO l_min_nivel_autor
       FROM t_envio_email

     IF SQLCA.sqlcode = 0 AND l_min_nivel_autor IS NOT NULL THEN
         DELETE FROM t_envio_email
          WHERE cod_nivel_autor > l_min_nivel_autor
     END IF
  END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv0803_tira_espacos(l_valor)
#--------------------------------------------#

 DEFINE l_tam,l_cont   SMALLINT
 DEFINE l_valor        CHAR(100)
 DEFINE l_retorno      CHAR(100)

  LET l_tam = LENGTH(l_valor)
  LET l_retorno = NULL

  FOR l_cont = 1 TO l_tam
     IF (l_valor[l_cont] <> " ") AND (l_valor[l_cont] IS NOT null) THEN
        LET l_retorno = l_retorno CLIPPED, l_valor[l_cont]
     END IF
  END FOR

  RETURN l_retorno CLIPPED

END FUNCTION

#--------------------------------------#
  FUNCTION cdv0803_carrega_tip_despesa()
#--------------------------------------#

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO p_tip_desp.*
    FROM tipo_despesa
   WHERE cod_empresa     = p_cod_empresa
     AND cod_tip_despesa = p_ad_mestre.cod_tip_despesa
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     ERROR "APROV. ELETR. PROB. SELECAO TIPO DE DESPESA"
     SLEEP 3
  END IF

END FUNCTION

#-----------------------------------------------#
  FUNCTION cdv0803_verifica_se_altera_status_ad()
#-----------------------------------------------#

  DEFINE l_contador SMALLINT
  LET l_contador = 0

  SELECT COUNT(*)
    INTO l_contador
    FROM aprov_necessaria
   WHERE cod_empresa     = p_cod_empresa
     AND num_ad          = p_ad_mestre.num_ad
     AND ies_aprovado = "N"

  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("INCLUSAO", "APROV_NECESSARIA2")
     LET p_work = FALSE
     RETURN
  END IF

  IF l_contador = 0 THEN
     LET p_ad_mestre.ies_sup_cap = "C"
  END IF

END FUNCTION

#--------------------------------------------------------------------------------------------------#
 FUNCTION cdv0803_cria_regs_cc_a_debitar(p_cod_empresa, l_num_ad,l_num_versao, l_num_linha_grade)
#--------------------------------------------------------------------------------------------------#
 DEFINE p_cod_empresa          CHAR(02),
        l_num_ad               LIKE ad_mestre.num_ad,
        l_num_versao           LIKE aprov_necessaria.num_versao,
        l_num_linha_grade      LIKE aprov_necessaria.num_linha_grade,
        l_matr_dono_cc         LIKE cdv_resp_cc.matricula,
        l_usuario_logix        LIKE cdv_info_viajante.usuario_logix,
        l_cod_nivel_autor      LIKE usu_nivel_aut_cap.cod_nivel_autor,
        l_cod_uni_funcio       LIKE usu_nivel_aut_cap.cod_uni_funcio,
        l_ies_tip_autor        LIKE nivel_autor_cap.ies_tip_autor,
        l_cod_usuario          LIKE usu_nivel_aut_cap.cod_usuario,
        l_email                LIKE usuarios.e_mail,
        l_matricula_aprovador  LIKE cdv_info_viajante.matricula,
        l_sequencia_protocol   LIKE cdv_protocol.sequencia_protocol,
        l_matricula_viajante   LIKE cdv_solic_viagem.matricula_viajante,
        l_usuario_viajante     LIKE cdv_info_viajante.usuario_logix,
        l_cc_viajante          LIKE cdv_acer_viag_781.cc_viajante,
        l_cc_debitar           LIKE cdv_acer_viag_781.cc_debitar

 DEFINE lr_aprov_necessaria RECORD LIKE aprov_necessaria.*

 INITIALIZE lr_aprov_necessaria TO NULL

 WHENEVER ERROR CONTINUE
 SELECT cc_viajante, cc_debitar
   INTO l_cc_viajante, l_cc_debitar
   FROM cdv_acer_viag_781
  WHERE empresa         = p_cod_empresa
    AND ad_acerto_conta = l_num_ad
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
			 WHENEVER ERROR CONTINUE
			 SELECT a.cc_viajante, a.cc_debitar
			   INTO l_cc_viajante, l_cc_debitar
			   FROM cdv_solic_viag_781 a, cdv_solic_adto_781 b
			  WHERE a.empresa       = p_cod_empresa
			    AND b.empresa       = p_cod_empresa
			    AND a.viagem        = b.viagem
			    AND b.num_ad_adto_viagem = l_num_ad
			 WHENEVER ERROR STOP

			 IF SQLCA.sqlcode <> 0 THEN
       RETURN
    END IF
 END IF

 IF l_cc_viajante = l_cc_debitar THEN
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 SELECT matricula
   INTO l_matr_dono_cc
   FROM cdv_resp_cc
  WHERE empresa      = p_cod_empresa
    AND centro_custo = l_cc_debitar
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 SELECT usuario_logix
   INTO l_usuario_logix
   FROM cdv_info_viajante
  WHERE empresa   = p_cod_empresa
    AND matricula = l_matr_dono_cc
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "cdv_info_viajante")
    LET p_work = FALSE
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_usu_nivel_aut1 CURSOR FOR
  SELECT cod_nivel_autor, cod_uni_funcio
    FROM usu_nivel_aut_cap
   WHERE cod_empresa      = p_cod_empresa
     AND ies_versao_atual = "S"
     AND ies_ativo        = "S"
     AND cod_usuario      = l_usuario_logix
  ORDER BY cod_nivel_autor

  FOREACH cq_usu_nivel_aut1 INTO l_cod_nivel_autor, l_cod_uni_funcio
    EXIT FOREACH
  END FOREACH
  FREE cq_usu_nivel_aut1
 WHENEVER ERROR CONTINUE

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECAO", "usu_nivel_aut_cap")
    LET p_work = FALSE
    RETURN
 END IF

 LET lr_aprov_necessaria.cod_empresa     = p_cod_empresa
 LET lr_aprov_necessaria.num_ad          = l_num_ad
 LET lr_aprov_necessaria.num_versao      = l_num_versao
 LET lr_aprov_necessaria.num_linha_grade = l_num_linha_grade
 LET lr_aprov_necessaria.cod_nivel_autor = l_cod_nivel_autor
 LET lr_aprov_necessaria.cod_uni_funcio  = l_cod_uni_funcio
 LET lr_aprov_necessaria.ies_aprovado    = "N"

 WHENEVER ERROR CONTINUE
  INSERT INTO aprov_necessaria VALUES(lr_aprov_necessaria.*)
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("INCLUSAO", "aprov_necessaria3")
    LET p_work = FALSE
    RETURN
 END IF

 # GERAÇÃO DO PROTOCOLO
 SELECT ies_tip_autor
   INTO l_ies_tip_autor
   FROM nivel_autor_cap
  WHERE cod_empresa     = lr_aprov_necessaria.cod_empresa
    AND cod_nivel_autor = lr_aprov_necessaria.cod_nivel_autor

 IF SQLCA.sqlcode <> 0 THEN
    CALL log0030_mensagem("Nível de autoridade não cadastrado.",'info')
    LET p_work   = FALSE
    LET p_status = 0
    RETURN FALSE
 END IF

 IF l_ies_tip_autor = 'H' THEN
     SELECT cod_usuario
       INTO l_cod_usuario
       FROM usu_nivel_aut_cap
      WHERE cod_empresa      = lr_aprov_necessaria.cod_empresa
        AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
        AND cod_nivel_autor  = lr_aprov_necessaria.cod_nivel_autor
        AND ies_versao_atual = 'S'
        AND ies_ativo        = 'S'
 ELSE
     # Genérico não olha a Unidade Funcional
     SELECT cod_usuario
       INTO l_cod_usuario
       FROM usu_nivel_aut_cap
      WHERE cod_empresa      = lr_aprov_necessaria.cod_empresa
        AND cod_nivel_autor  = lr_aprov_necessaria.cod_nivel_autor
        AND ies_versao_atual = 'S'
        AND ies_ativo        = 'S'
 END IF

 WHENEVER ERROR CONTINUE
 SELECT matricula
   INTO l_matricula_aprovador
   FROM cdv_info_viajante
  WHERE empresa       = lr_aprov_necessaria.cod_empresa
    AND usuario_logix = l_cod_usuario
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN

     WHENEVER ERROR CONTINUE
     SELECT MAX(sequencia_protocol)
       INTO l_sequencia_protocol
       FROM cdv_protocol
      WHERE empresa    = lr_aprov_necessaria.cod_empresa
        AND num_viagem = m_num_viagem
     WHENEVER ERROR STOP

     IF l_sequencia_protocol IS NULL THEN
         LET l_sequencia_protocol = 1
     ELSE
         LET l_sequencia_protocol = l_sequencia_protocol + 1
     END IF

     WHENEVER ERROR CONTINUE
     SELECT viajante
       INTO l_matricula_viajante
       FROM cdv_solic_viag_781
      WHERE empresa  = lr_aprov_necessaria.cod_empresa
        AND viagem   = m_num_viagem
     WHENEVER ERROR STOP

     IF g_cdv0061 = 'S' THEN
         LET mr_cdv_protocol.usuario_remetent = p_user_ant
     ELSE
         LET mr_cdv_protocol.usuario_remetent = p_user1
     END IF

     # Protocolo de Envio
     LET mr_cdv_protocol.empresa            = lr_aprov_necessaria.cod_empresa
     LET mr_cdv_protocol.num_viagem         = m_num_viagem
     LET mr_cdv_protocol.sequencia_protocol = l_sequencia_protocol
     LET mr_cdv_protocol.dat_hor_env_recb   = log0300_current(g_ies_ambiente) #Rafael - OS317282
     LET mr_cdv_protocol.status_protocol    = 5 #Enviado para Aprovação Eletrônica
     LET mr_cdv_protocol.matr_receb_docum   = l_matricula_viajante
     LET mr_cdv_protocol.matr_dest_protocol = l_matricula_aprovador
     LET mr_cdv_protocol.obs_protocol       = 'ENVIADO PARA APROVACAO - C.C. DIVERGENTE'
     LET mr_cdv_protocol.dat_hor_remetent   = log0300_current(g_ies_ambiente) #Rafael - OS317282
     LET mr_cdv_protocol.num_protocol       = p_ad_mestre.cod_tip_despesa
     LET mr_cdv_protocol.dat_hor_despacho   = log0300_current(g_ies_ambiente) #Rafael - OS317282

     WHENEVER ERROR CONTINUE
     INSERT INTO cdv_protocol ( empresa, num_viagem, dat_hor_env_recb, status_protocol, matr_receb_docum, matr_dest_protocol, obs_protocol, usuario_remetent, dat_hor_remetent, num_protocol, dat_hor_despacho )  VALUES ( mr_cdv_protocol.empresa, mr_cdv_protocol.num_viagem, mr_cdv_protocol.dat_hor_env_recb, mr_cdv_protocol.status_protocol, mr_cdv_protocol.matr_receb_docum, mr_cdv_protocol.matr_dest_protocol, mr_cdv_protocol.obs_protocol, mr_cdv_protocol.usuario_remetent, mr_cdv_protocol.dat_hor_remetent, mr_cdv_protocol.num_protocol, mr_cdv_protocol.dat_hor_despacho)
     WHENEVER ERROR STOP

     IF SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("INCLUSAO", "cdv_protocol")
         LET p_work   = FALSE
         LET p_status = 0
         RETURN FALSE
     END IF

 END IF
 # TÉRMINO GERAÇÃO DO PROTOCOLO

 # Geração de tabela temporária para envio de EMAIL
 WHENEVER ERROR CONTINUE
 SELECT ies_tip_autor
   INTO l_ies_tip_autor
   FROM nivel_autor_cap
  WHERE cod_empresa     = lr_aprov_necessaria.cod_empresa
    AND cod_nivel_autor = lr_aprov_necessaria.cod_nivel_autor
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
     RETURN
 END IF

 IF l_ies_tip_autor = 'H' THEN
     WHENEVER ERROR CONTINUE
     SELECT cod_usuario
       INTO l_cod_usuario
       FROM usu_nivel_aut_cap
      WHERE cod_empresa      = lr_aprov_necessaria.cod_empresa
        AND cod_uni_funcio   = lr_aprov_necessaria.cod_uni_funcio
        AND cod_nivel_autor  = lr_aprov_necessaria.cod_nivel_autor
        AND ies_versao_atual = 'S'
        AND ies_ativo        = 'S'
     WHENEVER ERROR STOP
 ELSE
     # Genérico não olha a Unidade Funcional
     WHENEVER ERROR CONTINUE
     SELECT cod_usuario
       INTO l_cod_usuario
       FROM usu_nivel_aut_cap
      WHERE cod_empresa      = lr_aprov_necessaria.cod_empresa
        AND cod_nivel_autor  = lr_aprov_necessaria.cod_nivel_autor
        AND ies_versao_atual = 'S'
        AND ies_ativo        = 'S'
     WHENEVER ERROR STOP
 END IF

 IF SQLCA.sqlcode = 0 THEN
     SELECT e_mail
       INTO l_email
       FROM usuarios
      WHERE cod_usuario = l_cod_usuario

     IF SQLCA.sqlcode = 0 THEN

         WHENEVER ERROR CONTINUE
         INSERT INTO t_envio_email VALUES
         (p_aprov_necessaria.num_ad, l_email, l_cod_nivel_autor)
         WHENEVER ERROR STOP

         IF SQLCA.sqlcode <> 0 THEN
             RETURN
         END IF

     END IF
 END IF
 # Término - Geração de tabela temporária para envio de EMAIL

END FUNCTION

#-----------------------------------------------------------------------------#
 FUNCTION cdv0803_envia_email(l_num_ad, l_tip_adto, l_num_viagem, l_val_adto)
#-----------------------------------------------------------------------------#
    DEFINE l_num_ad              LIKE ad_mestre.num_ad,
           l_tip_adto            CHAR(01),
           l_num_viagem          LIKE cdv_solic_viagem.num_viagem,
           l_val_adto            DECIMAL(17,2)
    DEFINE l_relat               CHAR(200),
           l_arquivo             CHAR(200),
           l_comando             CHAR(200),
           l_comand_mail_unix    CHAR(15),
           l_comand_mail         CHAR(15),
           l_email               CHAR(40),
           l_matricula_viajante  LIKE cdv_solic_viagem.matricula_viajante,
           l_cliente_destino     LIKE cdv_solic_viagem.cliente_destino,
           l_dat_hor_partida     LIKE cdv_solic_viagem.dat_hor_partida,
           l_dat_hor_retorno     LIKE cdv_solic_viagem.dat_hor_retorno,
           l_desp_viag_reemb     LIKE cdv_solic_viagem.desp_viag_reemb,
           l_status              SMALLINT

 LET p_user1             = p_user
 CALL cdv0803_carrega_parametros(l_num_viagem)

 SELECT UNIQUE num_ad
   FROM t_envio_email
  WHERE num_ad = l_num_ad

 IF SQLCA.sqlcode <> 0 THEN
     RETURN
 END IF

 CALL log2250_busca_parametro(p_cod_empresa,'url_cdv_intranet_logocenter')
    RETURNING m_url_cdv_logo, l_status

 IF NOT l_status THEN
    CALL log0030_mensagem("Problema seleção parâmetro link CDV.",'info')
    LET m_url_cdv_logo = "http://portal.logocenter.com.br/clijava/site/cdvlogixweb6/index.jsp"
 END IF

 MESSAGE 'Enviando e-mail para aprovantes...'

 CALL log150_procura_caminho('LST') RETURNING l_relat
 LET l_relat = l_relat CLIPPED,
               "mail_aprov_", cdv0803_tira_espacos(l_num_ad), ".txt"

 START REPORT cdv08032__relatorio_aprov TO l_relat

 SELECT viajante, cliente_atendido, dat_hor_partida, dat_hor_retorno
    INTO l_matricula_viajante, l_cliente_destino,
         l_dat_hor_partida, l_dat_hor_retorno
    FROM cdv_solic_viag_781
   WHERE empresa   = p_cod_empresa
     AND viagem    = l_num_viagem

 IF SQLCA.sqlcode = 0 THEN

    LET mr_relat.data_partida = EXTEND(l_dat_hor_partida, YEAR TO DAY)
    LET mr_relat.hora_partida = EXTEND(l_dat_hor_partida, HOUR TO MINUTE)

    LET mr_relat.data_retorno = EXTEND(l_dat_hor_retorno, YEAR TO DAY)
    LET mr_relat.hora_retorno = EXTEND(l_dat_hor_retorno, HOUR TO MINUTE)

    CASE l_desp_viag_reemb
        WHEN '1'
            LET mr_relat.des_reembolsavel = "VIAGEM/PASSAGEM NÃO REEMBOLSÁVEL PELO CLIENTE"
        WHEN '2'
            LET mr_relat.des_reembolsavel = "APENAS VIAGEM REEMBOLSÁVEL PELO CLIENTE"
        WHEN '3'
            LET mr_relat.des_reembolsavel = "APENAS PASSAGEM REEMBOLSÁVEL PELO CLIENTE"
        WHEN '4'
            LET mr_relat.des_reembolsavel = "VIAGEM/PASSAGEM REEMBOLSÁVEL PELO CLIENTE"
    END CASE

    LET mr_relat.nom_viajante = cdv0803_busca_nom_funcionario(l_matricula_viajante)
    WHENEVER ERROR CONTINUE
     SELECT nom_cliente
       INTO mr_relat.nom_cliente
       FROM clientes
      WHERE cod_cliente = l_cliente_destino
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN
       LET mr_relat.nom_cliente = NULL
    END IF

    LET mr_relat.val_adto   = l_val_adto
    LET mr_relat.num_viagem = l_num_viagem

 END IF

 OUTPUT TO REPORT cdv08032__relatorio_aprov(l_tip_adto)

 FINISH REPORT cdv08032__relatorio_aprov

 LET l_comando = "chmod 777 ", l_relat CLIPPED
 RUN l_comando

 LET l_arquivo = l_relat CLIPPED

 SELECT par_txt
   INTO l_comand_mail
   FROM par_cap_pad
  WHERE cod_empresa   = p_cod_empresa
    AND cod_parametro = "comand_mail_unix"

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO", "PAR_CAP_PAD3")
    CALL log0030_mensagem('Envio de e-mail interrompido.','info')
    RETURN
 END IF

 LET l_comand_mail_unix = l_comand_mail CLIPPED

 DECLARE cq_email CURSOR FOR
  SELECT UNIQUE email
    FROM t_envio_email
   WHERE num_ad = l_num_ad

 INITIALIZE l_comando TO NULL
 FOREACH cq_email INTO l_email

      LET l_comando = l_comand_mail_unix, '" Pendências de Aprovação Eletrônica !!!" ',
                      l_email CLIPPED, " < ", l_arquivo CLIPPED
      RUN l_comando

 END FOREACH

 IF l_arquivo IS NOT NULL
 AND l_comando IS NOT NULL THEN
    LET l_comando = "rm ", l_arquivo CLIPPED
    RUN l_comando
 END IF

 DELETE FROM t_envio_email WHERE num_ad = l_num_ad;

 MESSAGE ' '

 LET p_user1 = p_user_ant

 END FUNCTION

 #-----------------------------------------#
 REPORT cdv08032__relatorio_aprov(l_tip_adto)
#------------------------------------------#
    DEFINE l_tip_adto            CHAR(01),
           l_des_adto            CHAR(10)

    OUTPUT TOP    MARGIN 0
           LEFT   MARGIN 0
           BOTTOM MARGIN 0
           PAGE   LENGTH 1

    FORMAT
     ON EVERY ROW
        PRINT
        PRINT COLUMN 001, "***  A T E N Ç Ã O  ***"
        SKIP 2 LINES
        CASE l_tip_adto
           WHEN 'V'
               LET l_des_adto = 'Valor'
           WHEN 'H'
               LET l_des_adto = 'Hospedagem'
           WHEN 'P'
               LET l_des_adto = 'Passagem'
        END CASE
        IF l_tip_adto = 'A' THEN
            PRINT COLUMN 001, 'Existe uma pendência de aprovação para a Viagem ', mr_relat.num_viagem USING '#########&',
                              ' referente ao Acerto das Despesas da Viagem.'
        ELSE
            PRINT COLUMN 001, 'Existe uma pendência de aprovação para a Viagem ', mr_relat.num_viagem USING '#########&',
                              ' referente a um Adiantamento de ', l_des_adto CLIPPED,
                              ' de R$ ', mr_relat.val_adto USING '###,##&.&&'
        END IF
        SKIP 2 LINES
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

#-----------------------------------#
 FUNCTION cdv0803_verifica_excecao()
#-----------------------------------#
   DEFINE l_matricula        LIKE cdv_info_viajante.matricula,
          l_niv_autd_cc_debt LIKE cdv_par_ctr_viagem.niv_autd_cc_debt,
          l_cod_nivel_autor  LIKE usu_nivel_aut_cap.cod_nivel_autor,
          l_hora             LIKE aprov_necessaria.hor_aprovacao

   SELECT matricula
     INTO l_matricula
     FROM cdv_info_viajante
    WHERE empresa       = p_cod_empresa
      AND usuario_logix = p_user1

   IF SQLCA.SQLCODE <> 0 THEN
       RETURN
   END IF

  SELECT empresa
    FROM cdv_funcio_excecao
   WHERE empresa   = p_cod_empresa
     AND matricula = l_matricula

  IF SQLCA.sqlcode = 0 THEN

      SELECT niv_autd_cc_debt
        INTO l_niv_autd_cc_debt
        FROM cdv_par_ctr_viagem
       WHERE empresa = p_cod_empresa

      IF SQLCA.sqlcode <> 0 THEN
          LET l_niv_autd_cc_debt = NULL
      END IF

      INITIALIZE l_cod_nivel_autor TO NULL

      SELECT MAX(cod_nivel_autor)
        INTO l_cod_nivel_autor
        FROM usu_nivel_aut_cap
       WHERE cod_empresa      = p_aprov_necessaria.cod_empresa
         AND cod_uni_funcio   = p_aprov_necessaria.cod_uni_funcio
         AND ies_versao_atual = "S"
         AND ies_ativo        = "S"
         AND cod_usuario      = p_user1
         AND cod_nivel_autor  NOT IN (l_niv_autd_cc_debt)

      IF l_cod_nivel_autor IS NOT NULL THEN

          LET l_hora = TIME

          WHENEVER ERROR CONTINUE
           UPDATE aprov_necessaria
              SET ies_aprovado      = "S",
                  cod_usuario_aprov = p_user1,
                  dat_aprovacao     = TODAY,
                  hor_aprovacao     = l_hora,
                  observ_aprovacao  = "Aprovado Automatico - Usuario Excecao"
            WHERE cod_empresa       = p_aprov_necessaria.cod_empresa
              AND num_ad            = p_aprov_necessaria.num_ad
              AND cod_nivel_autor   < l_cod_nivel_autor
              AND ies_aprovado      = 'N'
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("ALTERAÇÃO",'aprov_necessaria')
              LET p_status = TRUE
              RETURN
          END IF

      END IF

  END IF

 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv0803_carrega_parametros(l_num_viagem)
#-------------------------------------------------#

  DEFINE l_usuario_logix     LIKE cdv_info_viajante.usuario_logix,
         l_num_viagem        INTEGER

  WHENEVER ERROR CONTINUE
  SELECT parametro_ind
    INTO p_usa_aprovacao
    FROM cdv_par_padrao
   WHERE empresa   = p_cod_empresa
     AND parametro = "aprov_eletro_cdv"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     LET p_usa_aprovacao = "S"
  END IF

  IF p_usa_aprovacao = "S" THEN
     SELECT par_ies INTO p_ies_forma_aprov
       FROM par_cap_pad
      WHERE cod_empresa = p_cod_empresa
        AND cod_parametro = "ies_forma_aprov"
      IF sqlca.sqlcode <> 0 THEN
        ERROR "Problema selecao PAR_CAP_PAD PARAM:'IES_FORMA_APROV'"
        SLEEP 4
      END IF

      SELECT par_ies INTO g_aprov_raiz_uni_fun
        FROM par_cap_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = "aprov_raiz_uni_fun"
      IF sqlca.sqlcode <> 0 THEN
         LET g_aprov_raiz_uni_fun = "N"
      END IF

      IF g_aprov_raiz_uni_fun IS NULL THEN
         LET g_aprov_raiz_uni_fun = "N"
      END IF
  END IF

  LET p_user_ant = p_user1

  WHENEVER ERROR CONTINUE
   SELECT cdv_info_viajante.usuario_logix, cdv_info_viajante.matricula
     INTO l_usuario_logix, m_matricula_viajante
     FROM cdv_info_viajante, cdv_solic_viag_781
    WHERE cdv_solic_viag_781.empresa   = p_cod_empresa
      AND cdv_solic_viag_781.viagem    = l_num_viagem
      AND cdv_info_viajante.empresa   = cdv_solic_viag_781.empresa
      AND cdv_info_viajante.matricula = cdv_solic_viag_781.viajante
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     WHENEVER ERROR CONTINUE
      SELECT cdv_info_viajante.usuario_logix, cdv_info_viajante.matricula
        INTO l_usuario_logix, m_matricula_viajante
        FROM cdv_info_viajante, cdv_acer_viag_781
       WHERE cdv_acer_viag_781.empresa   = p_cod_empresa
         AND cdv_acer_viag_781.viagem    = l_num_viagem
         AND cdv_info_viajante.empresa   = cdv_acer_viag_781.empresa
         AND cdv_info_viajante.matricula = cdv_acer_viag_781.viajante
     WHENEVER ERROR STOP
     IF SQLCA.SQLCODE <> 0 THEN
        LET l_usuario_logix = p_user1
     END IF
  END IF

  LET p_user1 = l_usuario_logix

END FUNCTION

#---------------------------------------------------------------------------------#
 FUNCTION cdv0803_atualiza_dados_ad_acerto(l_num_ad, l_num_ap, l_viagem, l_status)
#---------------------------------------------------------------------------------#
  DEFINE l_num_ad              LIKE ad_mestre.num_ad,
         l_num_ap              LIKE ap.num_ap,
         l_viagem              LIKE cdv_acer_viag_781.viagem,
         l_observ              LIKE ad_mestre.observ,
         l_ies_sup_cap         LIKE ad_mestre.ies_sup_cap,
         l_status              CHAR(01)

 LET p_user1             = p_user
 IF l_status = 'A' OR l_status = 'S' OR l_status = 'D' OR l_status = 'V' THEN
    IF l_num_ad IS NOT NULL THEN
       IF cdv0803_verifica_ad_tot_aprovada(l_num_ad) THEN
          LET l_ies_sup_cap = 'C'
       ELSE
          LET l_ies_sup_cap = 'Q'

          WHENEVER ERROR CONTINUE
           UPDATE ap
              SET ies_lib_pgto_cap = "B"
            WHERE cod_empresa      = p_cod_empresa
              AND num_ap           = l_num_ap
              AND ies_versao_atual = "S"
          WHENEVER ERROR STOP
          IF SQLCA.SQLCODE <> 0 THEN
             CALL log003_err_sql('UPDATE','ap')
             RETURN FALSE
          END IF
       END IF
    END IF
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

 IF l_status = 'A' THEN
    WHENEVER ERROR CONTINUE
     UPDATE cdv_acer_viag_781
        SET ad_acerto_conta = l_num_ad,
            status_acer_viagem = '3'
      WHERE empresa = p_cod_empresa
        AND viagem  = l_viagem
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('UPDATE','cdv_acer_viag_781')
       RETURN FALSE
    END IF
 END IF

 IF l_status = 'T' THEN
    WHENEVER ERROR CONTINUE
     UPDATE ap
        SET cod_lote_pgto    = g_lote_pgto_div,
            dat_proposta     = TODAY
      WHERE cod_empresa      = p_cod_empresa
        AND num_ap           = l_num_ap
        AND ies_versao_atual = "S"
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('UPDATE','ap')
       RETURN FALSE
    END IF
 END IF

 IF l_status = 'S' THEN
    #Não foi possivel utilizar o cap0160, pois a transação esta aberta#
    IF NOT cdv0803_exclui_tabelas_ap(l_num_ad, l_num_ap) THEN
       RETURN FALSE
    END IF
 END IF

 IF l_status = 'S' THEN
    WHENEVER ERROR CONTINUE
     UPDATE ad_mestre
        SET cnd_pgto = g_cond_pgto_km,
            dat_venc = NULL
      WHERE cod_empresa = p_cod_empresa
        AND num_ad      = l_num_ad
    WHENEVER ERROR STOP
    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql('UPDATE','ad_mestre')
       RETURN FALSE
    END IF
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

 IF l_num_ad IS NOT NULL THEN
    IF NOT cdv0803_descriptografa_textos_lanctos_contab(l_num_ad, '1') THEN
       RETURN FALSE
    END IF
 END IF
 IF l_num_ap IS NOT NULL THEN
    IF NOT cdv0803_descriptografa_textos_lanctos_contab(l_num_ap, '2') THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------------------------------------------------------#
 FUNCTION cdv0803_descriptografa_textos_lanctos_contab(l_num_ad_ap, l_ind_ad_ap)
#-------------------------------------------------------------------------------#
  DEFINE l_num_ad_ap          LIKE lanc_cont_cap.num_ad_ap,
         l_ind_ad_ap          LIKE lanc_cont_cap.ies_ad_ap,
         l_tex_hist_lanc      LIKE lanc_cont_cap.tex_hist_lanc,
         l_num_seq            LIKE lanc_cont_cap.num_seq

  WHENEVER ERROR CONTINUE
   DECLARE cq_desc_txt_lanc CURSOR FOR
    SELECT tex_hist_lanc, num_seq
      FROM lanc_cont_cap
     WHERE cod_empresa = p_cod_empresa
       AND num_ad_ap   = l_num_ad_ap
       AND ies_ad_ap   = l_ind_ad_ap
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DECLARE','cq_desc_txt_lanc')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_desc_txt_lanc INTO l_tex_hist_lanc, l_num_seq
  WHENEVER ERROR STOP

     IF SQLCA.SQLCODE <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_desc_txt_lanc')
        RETURN FALSE
     END IF

     LET l_tex_hist_lanc = cap069_ext_hist(l_tex_hist_lanc, l_num_ad_ap, l_ind_ad_ap, 0, p_cod_empresa)

     WHENEVER ERROR CONTINUE
      UPDATE lanc_cont_cap
         SET tex_hist_lanc = l_tex_hist_lanc
       WHERE cod_empresa   = p_cod_empresa
         AND num_ad_ap     = l_num_ad_ap
         AND ies_ad_ap     = l_ind_ad_ap
         AND num_seq       = l_num_seq
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('UPDATE','lanc_cont_cap')
        RETURN FALSE
     END IF

     CALL capr16_manutencao_ctb_lanc_ctbl_cap("M", p_cod_empresa, l_num_ad_ap, l_ind_ad_ap, l_num_seq )
        RETURNING m_manut_tabela, m_processa

     IF m_manut_tabela AND m_processa THEN
        WHENEVER ERROR CONTINUE
          UPDATE ctb_lanc_ctbl_cap
             SET ctb_lanc_ctbl_cap.compl_hist    = l_tex_hist_lanc
           WHERE ctb_lanc_ctbl_cap.empresa       = p_cod_empresa
             AND ctb_lanc_ctbl_cap.num_ad_ap     = l_num_ad_ap
             AND ctb_lanc_ctbl_cap.eh_ad_ap      = l_ind_ad_ap
             AND ctb_lanc_ctbl_cap.seql_lanc_cap = l_num_seq
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","CTB_LANC_CTBL_CAP")
           RETURN FALSE
        END IF
     ELSE
        IF NOT m_processa THEN
           RETURN FALSE
        END IF
     END IF



  END FOREACH
  FREE cq_desc_txt_lanc

  RETURN TRUE

END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv0803_verifica_ad_tot_aprovada(l_num_ad)
#---------------------------------------------------#
  DEFINE l_count   SMALLINT,
         l_num_ad  LIKE ad_mestre.num_ad

  IF l_num_ad IS NULL THEN
     RETURN FALSE
  END IF

  LET l_count = 0
  WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_count
     FROM aprov_necessaria
    WHERE cod_empresa  = p_cod_empresa
      AND num_ad       = l_num_ad
      AND ies_aprovado = "N"
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('SELECT','aprov_necessaria')
     RETURN TRUE
  END IF

  IF l_count = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv0803_exclui_tabelas_ap(l_num_ad, l_num_ap)
#-----------------------------------------------------#
  DEFINE l_num_ad LIKE ad_mestre.num_ad,
         l_num_ap LIKE ap.num_ap

  WHENEVER ERROR CONTINUE
   DELETE FROM lanc_cont_cap
    WHERE cod_empresa = p_cod_empresa
      AND num_ad_ap   = l_num_ap
      AND ies_ad_ap   = "2"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('DELETE','lanc_cont_cap')
     RETURN FALSE
  END IF

  CALL capr16_manutencao_ctb_lanc_ctbl_cap("E", p_cod_empresa, l_num_ap, 2, NULL)
     RETURNING m_manut_tabela, m_processa

  IF m_manut_tabela AND m_processa THEN

     WHENEVER ERROR CONTINUE
       DELETE FROM ctb_lanc_ctbl_cap
        WHERE empresa   = p_cod_empresa
          AND num_ad_ap = l_num_ap
          AND eh_ad_ap  = "2"
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('DELETE','CTB_LANC_CTBL_CAP')
        RETURN FALSE
     END IF
  ELSE
     IF NOT m_processa THEN
        RETURN FALSE
     END IF
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM ap_obser
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','ap_obser')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM ap_valores
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','ap_valores')
     RETURN FALSE
  END IF

  WHENEVER ERROR STOP
   DELETE FROM ap_tip_desp
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','ap_tip_desp')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM ad_ap
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','ad_ap')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM ap
    WHERE cod_empresa = p_cod_empresa
      AND num_ap      = l_num_ap
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','ap')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DELETE FROM audit_cap
    WHERE cod_empresa = p_cod_empresa
      AND num_ad_ap   = l_num_ap
      AND ies_ad_ap   = '2'
      AND num_seq     IS NOT NULL
  WHENEVER ERROR STOP
  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('DELETE','audit_cap')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  UPDATE ad_mestre
    SET val_saldo_ad = val_tot_nf
  WHERE cod_empresa  = p_cod_empresa
    AND num_ad       = l_num_ad
  WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     CALL log003_err_sql('update','ad_mestre')
     RETURN FALSE
  END IF


  RETURN TRUE

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION cdv0803_gera_aprov_eletr_viag(l_dispara_email, l_progr_aprov_eletr,
                                        l_ies_aprov_aut, l_num_viagem)
#----------------------------------------------------------------------------#
DEFINE l_dispara_email     SMALLINT,
       l_progr_aprov_eletr CHAR(07),
       l_ies_aprov_aut     CHAR(01),
       l_status            CHAR(01),
       l_num_viagem        LIKE cdv_solic_viagem.num_viagem,
       l_caminho           CHAR(300)

 LET p_user1             = p_user
 LET p_status = TRUE
 INITIALIZE p_ad_mestre.* TO NULL

 CALL cdv0803_carrega_parametros(l_num_viagem)

 LET m_versao_funcao = "CDV0803-05.10.05p"

 IF p_usa_aprovacao = "N" AND  p_aprov_eletr = "S"  THEN
    ERROR "Parâmetro de uso da aprov. eletr. não está ativo."
    SLEEP 2
 END IF

 LET m_viagem = l_num_viagem

 IF l_dispara_email THEN
    WHENEVER ERROR CONTINUE
     DROP TABLE t_envio_email;

     CREATE TEMP TABLE t_envio_email (num_viagem      INTEGER,
                                      email           CHAR(40),
                                      cod_nivel_autor CHAR(02));
    WHENEVER ERROR STOP
 END IF

 IF NOT cdv0803_carrega_tip_despesa_viag() THEN
    LET p_status = FALSE
 END IF

 IF p_usa_aprovacao = "S" THEN
    CALL cdv0803_dispara_email_aprovantes()
    CALL cdv0803_dispara_email_cc_divergentes()

    IF cdv0803_verifica_se_existe_grade_aprov_viag() <> 0 THEN
       CALL cdv0803_atualiz_aprovacao_viag()
    END IF
 END IF

 IF p_user_ant IS NOT NULL
 AND p_user_ant <> " " THEN
    LET p_user1 = p_user_ant
 END IF

 RETURN p_status

END FUNCTION

#--------------------------------------------#
 FUNCTION cdv0803_carrega_tip_despesa_viag()
#--------------------------------------------#
  DEFINE l_t_desp_viag_s_ad LIKE tipo_despesa.cod_tip_despesa,
         l_status           SMALLINT

  #WHENEVER ERROR CONTINUE
  # SELECT tip_desp_acer_cta
  #   INTO l_t_desp_viag_s_ad
  #   FROM cdv_par_ctr_viagem
  #  WHERE empresa = p_cod_empresa
  #WHENEVER ERROR STOP
  #
  #IF SQLCA.sqlcode <> 0 THEN
  #   CALL log003_err_sql('SELECAO','cdv_par_ctr_viagem')
  #   RETURN FALSE
  #END IF

  INITIALIZE l_t_desp_viag_s_ad TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"tip_desp_acer_viag")
       RETURNING l_t_desp_viag_s_ad, l_status

  IF l_status = FALSE
  OR l_t_desp_viag_s_ad IS NULL
  OR l_t_desp_viag_s_ad = " " THEN
     CALL log0030_mensagem('Tipo de despesa do acerto não cadastrado (LOG2240).','exclamation')
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO m_tip_desp.*
    FROM tipo_despesa
   WHERE cod_empresa     = p_cod_empresa
     AND cod_tip_despesa = l_t_desp_viag_s_ad
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     ERROR "APROV. ELETR. PROB. SELEÇÃO TIPO DE DESPESA."
     SLEEP 1
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv0803_verifica_se_existe_grade_aprov_viag()
#------------------------------------------------------#
 DEFINE p_grade_aprov_cap  RECORD LIKE grade_aprov_cap.*,
        p_val_cotacao      LIKE cotacao.val_cotacao,
        p_val_grade_1      DECIMAL(15,2),
        p_val_grade_2      DECIMAL(15,2),
        p_valor_convert    DECIMAL(15,2),
        p_qtd              SMALLINT,
        l_dia_corrente     DATE

 DEFINE l_env_nivel_sup       CHAR(01)

 LET p_valor_convert = 0.01

 DECLARE cq_cursor1 CURSOR FOR
  SELECT *
    FROM grade_aprov_cap
   WHERE cod_empresa = p_cod_empresa
     AND ies_versao_atual = "S"
     AND ies_grade_efetiv = "E"
     AND cod_tip_desp_ini <= m_tip_desp.cod_tip_despesa
     AND cod_tip_desp_fim >= m_tip_desp.cod_tip_despesa

 LET p_qtd = 0
 FOREACH cq_cursor1 INTO p_grade_aprov_cap.*

    LET g_num_versao_grade = p_grade_aprov_cap.num_versao

    IF p_grade_aprov_cap.cod_moeda <> p_par_cap.cod_moeda_padrao THEN
       LET l_dia_corrente = TODAY

       WHENEVER ERROR CONTINUE
       SELECT val_cotacao INTO p_val_grade_1
         FROM cotacao
        WHERE cod_moeda = p_grade_aprov_cap.cod_moeda
          AND dat_ref   = l_dia_corrente
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          ERROR "Não há cotação para a moeda -> ",p_grade_aprov_cap.cod_moeda CLIPPED," no dia ",l_dia_corrente
          SLEEP 2
          EXIT FOREACH
       END IF
       LET p_val_grade_2 = p_val_grade_1
       LET p_val_grade_1 = p_val_grade_1 * p_grade_aprov_cap.val_inicial
       LET p_val_grade_2 = p_val_grade_2 * p_grade_aprov_cap.val_final
    ELSE
       LET p_val_grade_1 = p_grade_aprov_cap.val_inicial
       LET p_val_grade_2 = p_grade_aprov_cap.val_final
    END IF

    IF (p_valor_convert >= p_val_grade_1) AND (p_valor_convert <= p_val_grade_2) THEN
       LET p_qtd = p_qtd + 1
       LET g_linha_grade = p_grade_aprov_cap.num_linha_grade
    END IF

 END FOREACH

 IF p_qtd > 1 THEN
    ERROR "Existe mais de uma linha de grade de aprovação para este compromisso."
    SLEEP 2
    RETURN 0
 END IF

 IF p_qtd = 0 THEN
    ERROR "Não existe linha na grade de aprovação para este compromisso."
    SLEEP 2
    RETURN 0
 END IF

 LET m_num_viagem = NULL
 IF cdv0803_tem_todos_aprovantes() THEN
    RETURN g_linha_grade
 ELSE
    RETURN 0
 END IF

END FUNCTION

#------------------------------------------#
 FUNCTION cdv0803_atualiz_aprovacao_viag()
#------------------------------------------#
  DEFINE l_data                 DATE,
         l_ies_aprov_aut        CHAR(01),
         l_ies_tip_autor        LIKE nivel_autor_cap.ies_tip_autor,
         l_cod_usuario          LIKE usu_nivel_aut_cap.cod_usuario,
         l_email                LIKE usuarios.e_mail,
         l_matricula_aprovador  LIKE cdv_info_viajante.matricula,
         l_sequencia_protocol   LIKE cdv_protocol.sequencia_protocol,
         l_matricula_viajante   LIKE cdv_solic_viagem.matricula_viajante,
         l_usuario_viajante     LIKE cdv_info_viajante.usuario_logix,
         l_min_nivel_autor      CHAR(02),
         l_cc_viajante          LIKE cdv_relat_viagem.cc_viajante,
         l_cc_debitar           LIKE cdv_relat_viagem.cc_debitar,
         l_cc_divergente        SMALLINT,
         l_nivel_inf            SMALLINT,
         l_matricula_remetente  LIKE cdv_info_viajante.matricula,
         lr_cdv_aprov_viag_781  RECORD LIKE cdv_aprov_viag_781.*,
         lr_cdv_protocol        RECORD LIKE cdv_protocol.*

  #IF p_usa_aprovacao = "S" THEN
      DECLARE cq_insere_necess2 CURSOR FOR
       SELECT cod_nivel_autor
         FROM aprov_grade
        WHERE cod_empresa     = p_cod_empresa
          AND num_versao      = g_num_versao_grade
          AND num_linha_grade = g_linha_grade
        ORDER BY cod_nivel_autor

      FOREACH cq_insere_necess2 INTO lr_cdv_aprov_viag_781.nivel_autorid

         WHENEVER ERROR CONTINUE
         SELECT cod_uni_funcio
           INTO lr_cdv_aprov_viag_781.unid_funcional
           FROM w_uni_func_e_niv
          WHERE cod_nivel_autor = lr_cdv_aprov_viag_781.nivel_autorid
         WHENEVER ERROR STOP

         LET lr_cdv_aprov_viag_781.empresa        = p_cod_empresa
         LET lr_cdv_aprov_viag_781.versao         = g_num_versao_grade
         LET lr_cdv_aprov_viag_781.viagem         = m_viagem
         LET lr_cdv_aprov_viag_781.linha_grade    = g_linha_grade
         LET lr_cdv_aprov_viag_781.eh_aprovado    = "N"
         LET lr_cdv_aprov_viag_781.dat_aprovacao  = NULL
         LET lr_cdv_aprov_viag_781.hor_aprovacao  = NULL

         IF cdv0803_verifica_aprov_aut(lr_cdv_aprov_viag_781.nivel_autorid) THEN
            LET l_data                                  = TODAY
            LET lr_cdv_aprov_viag_781.eh_aprovado       = "S"
            LET lr_cdv_aprov_viag_781.usuario_aprovacao = p_user1
            LET lr_cdv_aprov_viag_781.dat_aprovacao     = l_data
            LET lr_cdv_aprov_viag_781.hor_aprovacao     = TIME
            LET lr_cdv_aprov_viag_781.obs_aprovacao     = "Aprovado Automatico"
         ELSE
            LET lr_cdv_aprov_viag_781.usuario_aprovacao = NULL
            LET lr_cdv_aprov_viag_781.dat_aprovacao     = NULL
            LET lr_cdv_aprov_viag_781.hor_aprovacao     = NULL
            LET lr_cdv_aprov_viag_781.obs_aprovacao     = NULL
         END IF

         WHENEVER ERROR CONTINUE
         SELECT viagem
           FROM cdv_aprov_viag_781
          WHERE empresa       = lr_cdv_aprov_viag_781.empresa
            AND viagem        = lr_cdv_aprov_viag_781.viagem
            AND nivel_autorid = lr_cdv_aprov_viag_781.nivel_autorid
         WHENEVER ERROR STOP

         IF SQLCA.sqlcode = 0 THEN
            CONTINUE FOREACH
         END IF

         WHENEVER ERROR CONTINUE
          INSERT INTO cdv_aprov_viag_781 VALUES(lr_cdv_aprov_viag_781.*)
         WHENEVER ERROR STOP

         IF SQLCA.SQLCODE <> 0 THEN
            CALL log003_err_sql("INCLUSAO", "cdv_aprov_viag_781")
            RETURN FALSE
         END IF

         # GERAÇÃO DO PROTOCOLO
         IF lr_cdv_aprov_viag_781.eh_aprovado = 'N' THEN

             LET l_cc_divergente = FALSE

             WHENEVER ERROR CONTINUE
             SELECT cc_viajante, cc_debitar
               INTO l_cc_viajante, l_cc_debitar
               FROM cdv_acer_viag_781
              WHERE empresa         = lr_cdv_aprov_viag_781.empresa
                AND viagem          = m_viagem
             WHENEVER ERROR STOP

             IF SQLCA.SQLCODE = 0 THEN
                 IF l_cc_viajante <> l_cc_debitar THEN
                     LET l_cc_divergente = TRUE
                 END IF
             END IF

             LET l_nivel_inf = FALSE

             WHENEVER ERROR CONTINUE
             SELECT UNIQUE empresa
               FROM cdv_aprov_viag_781
              WHERE empresa       = lr_cdv_aprov_viag_781.empresa
                AND viagem        = lr_cdv_aprov_viag_781.viagem
                AND nivel_autorid < lr_cdv_aprov_viag_781.nivel_autorid
                AND eh_aprovado   = 'N'
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode = 0 THEN
                 LET l_nivel_inf = TRUE
             END IF

             WHENEVER ERROR CONTINUE
             SELECT ies_tip_autor
               INTO l_ies_tip_autor
               FROM nivel_autor_cap
              WHERE cod_empresa     = lr_cdv_aprov_viag_781.empresa
                AND cod_nivel_autor = lr_cdv_aprov_viag_781.nivel_autorid
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode <> 0 THEN
                CALL log0030_mensagem("Nível de autoridade não cadastrado.",'info')
                LET p_status = FALSE
                RETURN FALSE
             END IF

             IF l_ies_tip_autor = 'H' THEN
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = lr_cdv_aprov_viag_781.empresa
                    AND cod_uni_funcio   = lr_cdv_aprov_viag_781.unid_funcional
                    AND cod_nivel_autor  = lr_cdv_aprov_viag_781.nivel_autorid
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             ELSE
                 # Genérico não olha a Unidade Funcional
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = lr_cdv_aprov_viag_781.empresa
                    AND cod_nivel_autor  = lr_cdv_aprov_viag_781.nivel_autorid
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             END IF

             WHENEVER ERROR CONTINUE
             SELECT matricula
               INTO l_matricula_aprovador
               FROM cdv_info_viajante
              WHERE empresa       = lr_cdv_aprov_viag_781.empresa
                AND usuario_logix = l_cod_usuario
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode = 0 THEN

                 WHENEVER ERROR CONTINUE
                 SELECT MAX(sequencia_protocol)
                   INTO l_sequencia_protocol
                   FROM cdv_protocol
                  WHERE empresa    = lr_cdv_aprov_viag_781.empresa
                    AND num_viagem = m_viagem
                 WHENEVER ERROR STOP

                 IF l_sequencia_protocol IS NULL THEN
                     LET l_sequencia_protocol = 1
                 ELSE
                     LET l_sequencia_protocol = l_sequencia_protocol + 1
                 END IF

                 ## Se for o CDV0060 o Rementente deve ser o Agenciador
                 IF g_cdv0060 = 'S' THEN
                     WHENEVER ERROR CONTINUE
                     SELECT matricula
                       INTO l_matricula_remetente
                       FROM cdv_info_viajante
                      WHERE empresa       = lr_cdv_aprov_viag_781.empresa
                        AND usuario_logix = p_user1
                     WHENEVER ERROR STOP
                 ELSE # Os outros programas o Rementente é o viajante
                     WHENEVER ERROR CONTINUE
                     SELECT viajante
                       INTO l_matricula_remetente
                       FROM cdv_solic_viag_781
                      WHERE empresa  = lr_cdv_aprov_viag_781.empresa
                        AND viagem   = m_viagem
                     WHENEVER ERROR STOP
                 END IF

                 #IF g_cdv0061 = 'S' THEN
                 #    LET lr_cdv_protocol.usuario_remetent = p_user_ant
                 #ELSE
                     LET lr_cdv_protocol.usuario_remetent = p_user1
                 #END IF

                 # Protocolo de Envio
                 LET lr_cdv_protocol.empresa            = lr_cdv_aprov_viag_781.empresa
                 LET lr_cdv_protocol.num_viagem         = m_viagem
                 LET lr_cdv_protocol.sequencia_protocol = l_sequencia_protocol
                 LET lr_cdv_protocol.dat_hor_env_recb   = log0300_current(g_ies_ambiente) #Rafael - OS317282
                 LET lr_cdv_protocol.status_protocol    = 5 #Enviado para Aprovação Eletrônica
                 LET lr_cdv_protocol.matr_receb_docum   = l_matricula_remetente
                 LET lr_cdv_protocol.matr_dest_protocol = l_matricula_aprovador
                 LET lr_cdv_protocol.obs_protocol       = 'ENVIADO PARA APROVACAO'
                 LET lr_cdv_protocol.dat_hor_remetent   = log0300_current(g_ies_ambiente) #Rafael - OS317282
                 LET lr_cdv_protocol.num_protocol       = lr_cdv_aprov_viag_781.viagem
                 LET lr_cdv_protocol.dat_hor_despacho   = log0300_current(g_ies_ambiente) #Rafael - OS317282

                 IF l_cc_divergente = FALSE AND l_nivel_inf = FALSE THEN
                     WHENEVER ERROR CONTINUE
                     INSERT INTO cdv_protocol ( empresa, num_viagem, dat_hor_env_recb, status_protocol, matr_receb_docum, matr_dest_protocol, obs_protocol, usuario_remetent, dat_hor_remetent, num_protocol, dat_hor_despacho )  VALUES ( lr_cdv_protocol.empresa, lr_cdv_protocol.num_viagem, lr_cdv_protocol.dat_hor_env_recb, lr_cdv_protocol.status_protocol, lr_cdv_protocol.matr_receb_docum, lr_cdv_protocol.matr_dest_protocol, lr_cdv_protocol.obs_protocol, lr_cdv_protocol.usuario_remetent, lr_cdv_protocol.dat_hor_remetent, lr_cdv_protocol.num_protocol, lr_cdv_protocol.dat_hor_despacho)
                     WHENEVER ERROR STOP

                     IF SQLCA.sqlcode <> 0 THEN
                         CALL log003_err_sql("INCLUSAO", "cdv_protocol")
                         LET p_status = FALSE
                         RETURN FALSE
                     END IF
                 END IF
             END IF
         END IF
         # TÉRMINO GERAÇÃO DO PROTOCOLO

         # Geração de tabela temporária para envio de EMAIL
         IF lr_cdv_aprov_viag_781.eh_aprovado = 'N' THEN
             WHENEVER ERROR CONTINUE
             SELECT ies_tip_autor
               INTO l_ies_tip_autor
               FROM nivel_autor_cap
              WHERE cod_empresa     = lr_cdv_aprov_viag_781.empresa
                AND cod_nivel_autor = lr_cdv_aprov_viag_781.nivel_autorid
             WHENEVER ERROR STOP

             IF SQLCA.sqlcode <> 0 THEN
                 CONTINUE FOREACH
             END IF

             IF l_ies_tip_autor = 'H' THEN
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = lr_cdv_aprov_viag_781.empresa
                    AND cod_uni_funcio   = lr_cdv_aprov_viag_781.unid_funcional
                    AND cod_nivel_autor  = lr_cdv_aprov_viag_781.nivel_autorid
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             ELSE
                 # Genérico não olha a Unidade Funcional
                 WHENEVER ERROR CONTINUE
                 SELECT cod_usuario
                   INTO l_cod_usuario
                   FROM usu_nivel_aut_cap
                  WHERE cod_empresa      = lr_cdv_aprov_viag_781.empresa
                    AND cod_nivel_autor  = lr_cdv_aprov_viag_781.nivel_autorid
                    AND ies_versao_atual = 'S'
                    AND ies_ativo        = 'S'
                 WHENEVER ERROR STOP
             END IF

             IF SQLCA.sqlcode = 0 THEN

                 SELECT e_mail
                   INTO l_email
                   FROM usuarios
                  WHERE cod_usuario = l_cod_usuario

                 IF SQLCA.sqlcode = 0 THEN
                     INSERT INTO t_envio_email VALUES
                     (lr_cdv_aprov_viag_781.viagem, l_email, lr_cdv_aprov_viag_781.nivel_autorid)

                     IF SQLCA.sqlcode <> 0 THEN
                         CONTINUE FOREACH
                     END IF
                 END IF
             END IF
         END IF
         # Término - Geração de tabela temporária para envio de EMAIL

      END FOREACH
     WHENEVER ERROR STOP

     CALL cdv0803_cria_regs_cc_a_debitar(p_cod_empresa, lr_cdv_aprov_viag_781.viagem,
                                         g_num_versao_grade, g_linha_grade)

     CALL cdv0803_verifica_excecao_viag(lr_cdv_aprov_viag_781.unid_funcional)

     SELECT MIN(cod_nivel_autor)
       INTO l_min_nivel_autor
       FROM t_envio_email

     IF SQLCA.sqlcode = 0 AND l_min_nivel_autor IS NOT NULL THEN
         DELETE FROM t_envio_email
          WHERE cod_nivel_autor > l_min_nivel_autor
     END IF
  #END IF

END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv0803_verifica_excecao_viag(l_cod_uni_funcio)
#----------------------------------------------------------#
   DEFINE l_matricula        LIKE cdv_info_viajante.matricula,
          l_niv_autd_cc_debt LIKE cdv_par_ctr_viagem.niv_autd_cc_debt,
          l_cod_nivel_autor  LIKE usu_nivel_aut_cap.cod_nivel_autor,
          l_hora             LIKE aprov_necessaria.hor_aprovacao,
          l_cod_uni_funcio   LIKE cdv_aprov_viag_781.unid_funcional

   SELECT matricula
     INTO l_matricula
     FROM cdv_info_viajante
    WHERE empresa       = p_cod_empresa
      AND usuario_logix = p_user1

   IF SQLCA.SQLCODE <> 0 THEN
       RETURN
   END IF

  SELECT empresa
    FROM cdv_funcio_excecao
   WHERE empresa   = p_cod_empresa
     AND matricula = l_matricula

  IF SQLCA.sqlcode = 0 THEN

      SELECT niv_autd_cc_debt
        INTO l_niv_autd_cc_debt
        FROM cdv_par_ctr_viagem
       WHERE empresa = p_cod_empresa

      IF SQLCA.sqlcode <> 0 THEN
          LET l_niv_autd_cc_debt = NULL
      END IF

      INITIALIZE l_cod_nivel_autor TO NULL

      SELECT MAX(cod_nivel_autor)
        INTO l_cod_nivel_autor
        FROM usu_nivel_aut_cap
       WHERE cod_empresa      = p_cod_empresa
         AND cod_uni_funcio   = l_cod_uni_funcio
         AND ies_versao_atual = "S"
         AND ies_ativo        = "S"
         AND cod_usuario      = p_user1
         AND cod_nivel_autor  NOT IN (l_niv_autd_cc_debt)

      IF l_cod_nivel_autor IS NOT NULL THEN

          LET l_hora = TIME

          WHENEVER ERROR CONTINUE
           UPDATE cdv_aprov_viag_781
              SET eh_aprovado       = "S",
                  usuario_aprovacao = p_user1,
                  dat_aprovacao     = TODAY,
                  hor_aprovacao     = l_hora,
                  obs_aprovacao     = "Aprovado Automatico - Usuario Excecao"
            WHERE empresa           = p_cod_empresa
              AND viagem            = m_viagem
              AND nivel_autorid   < l_cod_nivel_autor
              AND eh_aprovado       = 'N'
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("ALTERAÇÃO",'CDV_APROV_VIAG_781')
              LET p_status = FALSE
              RETURN
          END IF

      END IF

  END IF

 END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv0803_busca_nom_funcionario(l_matricula)
#---------------------------------------------------#

  DEFINE l_matricula       LIKE cdv_info_viajante.matricula,
         l_cod_funcio      LIKE cdv_fornecedor_fun.cod_funcio,
         l_cod_fornecedor  LIKE fornecedor.cod_fornecedor,
         l_nom_funcionario LIKE fornecedor.raz_social

  INITIALIZE l_nom_funcionario TO NULL

  LET l_cod_funcio = l_matricula

  WHENEVER ERROR CONTINUE
  SELECT cod_fornecedor
    INTO l_cod_fornecedor
    FROM cdv_fornecedor_fun
   WHERE cod_funcio = l_cod_funcio
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN l_nom_funcionario
  END IF

  WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO l_nom_funcionario
    FROM fornecedor
   WHERE cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN l_nom_funcionario
  END IF

  RETURN l_nom_funcionario

END FUNCTION

#-------------------------------#
 FUNCTION cdv0803_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0803.4gl $|$Revision: 8 $|$Date: 21/02/13 18:57 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION