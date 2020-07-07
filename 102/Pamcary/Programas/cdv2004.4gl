###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS                       #
# PROGRAMA: CDV2004                                               #
# OBJETIVO: MANUTENCAO DOS TIPOS DE DESPESAS DE VIAGENS.          #
#           (ESPECIFICO PAMCARY SIST. GER. RISCO)                 #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 12.07.2005                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
    DEFINE p_cod_empresa             LIKE empresa.cod_empresa,
           p_user                    LIKE usuario.nom_usuario,
           p_status                  SMALLINT,
           g_ies_linha_prod_cmi      CHAR(01)

    DEFINE p_ies_impressao           CHAR(001),
           g_ies_ambiente            CHAR(001),
           p_nom_arquivo             CHAR(100),
           p_nom_arquivo_back        CHAR(100)

    DEFINE g_ies_grafico             SMALLINT

    DEFINE g_tipo_sgbd			CHAR(003)

    DEFINE p_versao                  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

#MODULARES
    DEFINE m_den_empresa             LIKE empresa.den_empresa

    DEFINE m_consulta_ativa          SMALLINT

    DEFINE sql_stmt                  CHAR(800),
           m_last_row                SMALLINT,
           where_clause              CHAR(400)

    DEFINE m_comando                 CHAR(080)

    DEFINE m_caminho                 CHAR(150)

    DEFINE mr_cdv_tdesp_viag_781     RECORD
                                     empresa              LIKE cdv_tdesp_viag_781.empresa,
                                     tip_despesa_viagem   LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
                                     des_tdesp_viagem     LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
                                     grp_despesa_viagem   LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
                                     ativ                 LIKE cdv_tdesp_viag_781.ativ,
                                     eh_reembolso         LIKE cdv_tdesp_viag_781.eh_reembolso,
                                     eh_valz_km           LIKE cdv_tdesp_viag_781.eh_valz_km,
                                     cctbl_contab_ad      LIKE cdv_tdesp_viag_781.cctbl_contab_ad,
                                     tip_despesa_contab   LIKE cdv_tdesp_viag_781.tip_despesa_contab,
                                     hist_padrao_cap      LIKE cdv_tdesp_viag_781.hist_padrao_cap,
                                     item                 LIKE cdv_tdesp_viag_781.item,
                                     item_hor             LIKE cdv_tdesp_viag_781.item_hor,
                                     informa_placa        LIKE cdv_tdesp_viag_781.informa_placa, #OS 487356
                                     cobra_despesa        LIKE cdv_tdesp_viag_781.cobra_despesa
                                     END RECORD

    DEFINE mr_cdv_tdesp_viag_781r    RECORD
                                     empresa              LIKE cdv_tdesp_viag_781.empresa,
                                     tip_despesa_viagem   LIKE cdv_tdesp_viag_781.tip_despesa_viagem,
                                     des_tdesp_viagem     LIKE cdv_tdesp_viag_781.des_tdesp_viagem,
                                     grp_despesa_viagem   LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
                                     ativ                 LIKE cdv_tdesp_viag_781.ativ,
                                     eh_reembolso        LIKE cdv_tdesp_viag_781.eh_reembolso,
                                     eh_valz_km          LIKE cdv_tdesp_viag_781.eh_valz_km,
                                     cctbl_contab_ad      LIKE cdv_tdesp_viag_781.cctbl_contab_ad,
                                     tip_despesa_contab   LIKE cdv_tdesp_viag_781.tip_despesa_contab,
                                     hist_padrao_cap      LIKE cdv_tdesp_viag_781.hist_padrao_cap,
                                     item                 LIKE cdv_tdesp_viag_781.item,
                                     item_hor             LIKE cdv_tdesp_viag_781.item_hor,
                                     informa_placa        LIKE cdv_tdesp_viag_781.informa_placa, #OS 487356
                                     cobra_despesa        LIKE cdv_tdesp_viag_781.cobra_despesa
                                     END RECORD

    DEFINE mr_hist_padrao_cap	       RECORD LIKE hist_padrao_cap.*,
           m_mntg_conta_contab       LIKE cdv_par_ctr_viagem.mntg_conta_contab,
           m_data_ini		              CHAR(12),
           m_data_fim		              CHAR(12),
           m_fdata_ini		             DATE,
           m_fdata_fim		             DATE

#END MODULARES

MAIN

     CALL log0180_conecta_usuario()

    LET p_versao = 'CDV2004-05.10.04p' #Favor nao alterar esta linha (SUPORTE)

    WHENEVER ERROR CONTINUE
    CALL log1400_isolation()
    SET LOCK MODE TO WAIT 120
    DEFER INTERRUPT
    WHENEVER ERROR STOP

    LET m_caminho = log140_procura_caminho('cdv2004.iem')

    OPTIONS
        PREVIOUS KEY control-b,
        NEXT     KEY control-f,
        HELP     FILE m_caminho

    CALL log001_acessa_usuario('CDV','LOGERP')
         RETURNING p_status, p_cod_empresa, p_user

    IF  p_status = 0 THEN
        CALL cdv2004_controle()
    END IF
END MAIN

#---------------------------#
FUNCTION cdv2004_controle()
#---------------------------#

    CALL log006_exibe_teclas('01', p_versao)

    CALL cdv2004_inicia_variaveis()
    #CALL cdv2004_verif_uso_linha_prod_cmi()

    LET m_caminho = log1300_procura_caminho("cdv2004","cdv20041")
    OPEN WINDOW w_cdv20041 AT 2,2 WITH FORM m_caminho
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

    MENU "OPÇÃO"
        COMMAND "Incluir"   "Inclui um novo registro."
            HELP 001
            MESSAGE ""
            IF log005_seguranca(p_user, "CDV", "CDV2004", "IN") THEN
               CALL cdv2004_inclusao_cdv_tdesp_viag_781()
            END IF

        COMMAND "Modificar" "Modifica o registro que está sendo mostrado em tela."
            HELP 002
            MESSAGE ""
            IF  m_consulta_ativa THEN
                IF  log005_seguranca(p_user, "CDV", "CDV2004", "MO") THEN
                    CALL cdv2004_modificacao_cdv_tdesp_viag_781()
                END IF
            ELSE
                CALL log0030_mensagem("Consulte previamente para fazer a modificação.","exclamation")
            END IF

        COMMAND "Excluir"   "Exclui um item existente na tabela cdv_tdesp_viag_781."
            HELP 003
            MESSAGE ""
            IF  m_consulta_ativa THEN
                IF  log005_seguranca(p_user, 'CDV', 'CDV2004', 'EX') THEN
                    CALL cdv2004_exclusao_cdv_tdesp_viag_781()
                END IF
            ELSE
                CALL log0030_mensagem("Consulte previamente para fazer a exclusão.","exclamation")
            END IF

        COMMAND "Consultar" "Consulta os registros cadastrados no sistema."
            HELP 004
            MESSAGE ''
            IF  log005_seguranca(p_user, "CDV" , "CDV2004", "CO") THEN
                CALL cdv2004_consulta_cdv_tdesp_viag_781()
            END IF

        COMMAND "Seguinte"  "Exibe o próximo item encontrado na pesquisa."
            HELP 006
            MESSAGE ""
            IF m_consulta_ativa THEN
               CALL cdv2004_paginacao("SEGUINTE")
            ELSE
                CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
            END IF

        COMMAND "Anterior"  "Exibe o item anterior encontrado na pesquisa."
            HELP 007
            MESSAGE ""
            IF m_consulta_ativa THEN
               CALL cdv2004_paginacao("ANTERIOR")
            ELSE
                CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")
            END IF

        COMMAND "Listar"    "Lista os registros cadastrados no sistema."
            HELP 005
            MESSAGE ""
            IF  log005_seguranca(p_user, 'CDV', 'CDV2004', 'CO') THEN
                IF  log0280_saida_relat(16,30) IS NOT NULL THEN
                    CALL cdv2004_lista_cdv_tdesp_viag_781()
                END IF
            END IF

        COMMAND KEY ("!")
            PROMPT "Digite o comando : " FOR m_comando
            RUN m_comando
            PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando

        COMMAND "Fim"       "Retorna ao menu anterior."
            HELP 008
            EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

    END MENU

    CLOSE WINDOW w_cdv20041
END FUNCTION
#-----------------------------------#
FUNCTION cdv2004_inicia_variaveis()
#-----------------------------------#
 LET m_consulta_ativa           = FALSE

 INITIALIZE mr_cdv_tdesp_viag_781.*  TO NULL
 INITIALIZE mr_cdv_tdesp_viag_781r.* TO NULL
 INITIALIZE mr_hist_padrao_cap.*, m_data_ini, m_data_fim, m_fdata_ini, m_fdata_fim TO NULL

 END FUNCTION

#---------------------------------------------#
 FUNCTION cdv2004_inclusao_cdv_tdesp_viag_781()
#---------------------------------------------#

 DEFINE l_houve_erro  SMALLINT,
        l_replica     CHAR(01),
        l_where_audit CHAR(1000),
        l_cod_empresa LIKE cdv_tdesp_viag_781.empresa

 LET mr_cdv_tdesp_viag_781r.* = mr_cdv_tdesp_viag_781.*

 INITIALIZE mr_cdv_tdesp_viag_781.* TO NULL

 CLEAR FORM
 LET mr_cdv_tdesp_viag_781.empresa = p_cod_empresa
 DISPLAY BY NAME mr_cdv_tdesp_viag_781.empresa

 IF cdv2004_entrada_dados("INCLUSAO") THEN
    WHENEVER ERROR CONTINUE
    CALL log085_transacao("BEGIN")
    WHENEVER ERROR STOP

    LET l_houve_erro = FALSE
    WHENEVER ERROR CONTINUE
    INSERT INTO cdv_tdesp_viag_781 (empresa,
                                    tip_despesa_viagem,
                                    des_tdesp_viagem,
                                    grp_despesa_viagem,
                                    ativ,
                                    eh_reembolso,
                                    eh_valz_km,
                                    cctbl_contab_ad,
                                    tip_despesa_contab,
                                    hist_padrao_cap,
                                    item,
                                    item_hor,
                                    informa_placa, #OS 487356
                                    cobra_despesa)
                            VALUES (mr_cdv_tdesp_viag_781.empresa,
                                    mr_cdv_tdesp_viag_781.tip_despesa_viagem,
                                    mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                                    mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                                    mr_cdv_tdesp_viag_781.ativ,
                                    mr_cdv_tdesp_viag_781.eh_reembolso,
                                    mr_cdv_tdesp_viag_781.eh_valz_km,
                                    mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                    mr_cdv_tdesp_viag_781.tip_despesa_contab,
                                    mr_cdv_tdesp_viag_781.hist_padrao_cap,
                                    mr_cdv_tdesp_viag_781.item,
                                    mr_cdv_tdesp_viag_781.item_hor,
                                    mr_cdv_tdesp_viag_781.informa_placa, #OS 487356
                                    mr_cdv_tdesp_viag_781.cobra_despesa)
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("INCLUSAO","CDV_TDESP_VIAG_781")
       LET l_houve_erro = TRUE
       RETURN
    END IF

    INITIALIZE l_where_audit TO NULL
    LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", mr_cdv_tdesp_viag_781.empresa ,"' ",
                         " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                         " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
    CALL cdv2004_grava_auditoria(mr_cdv_tdesp_viag_781.empresa, l_where_audit, "I", 0)

    CALL log2250_busca_parametro(p_cod_empresa, "replicacao_td_empresas_pamcary")
         RETURNING l_replica, p_status

    IF  p_status = TRUE
    AND l_replica = 'S' THEN
       WHENEVER ERROR CONTINUE
       DECLARE cq_empresa CURSOR FOR
        SELECT DISTINCT empresa
          FROM cdv_tdesp_viag_781
         WHERE empresa            <> mr_cdv_tdesp_viag_781.empresa
           AND tip_despesa_viagem <> mr_cdv_tdesp_viag_781.tip_despesa_viagem
           AND ativ               <> mr_cdv_tdesp_viag_781.ativ
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DECLARE","CQ_EMPRESA")
       END IF

       WHENEVER ERROR CONTINUE
       FOREACH cq_empresa INTO l_cod_empresa
       WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("CQ_EMPRESA","FOREACH")
             EXIT FOREACH
          END IF

        WHENEVER ERROR CONTINUE
        SELECT DISTINCT empresa
          FROM cdv_tdesp_viag_781
         WHERE empresa            = l_cod_empresa
           AND tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
           AND ativ               = mr_cdv_tdesp_viag_781.ativ
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode = 0 THEN
             CONTINUE FOREACH
          END IF

          WHENEVER ERROR CONTINUE
          INSERT INTO cdv_tdesp_viag_781 (empresa,
                                          tip_despesa_viagem,
                                          des_tdesp_viagem,
                                          grp_despesa_viagem,
                                          ativ,
                                          eh_reembolso,
                                          eh_valz_km,
                                          cctbl_contab_ad,
                                          tip_despesa_contab,
                                          hist_padrao_cap,
                                          item,
                                          item_hor,
                                          informa_placa, #OS 487356
                                          cobra_despesa)
                                  VALUES (l_cod_empresa,
                                          mr_cdv_tdesp_viag_781.tip_despesa_viagem,
                                          mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                                          mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                                          mr_cdv_tdesp_viag_781.ativ,
                                          mr_cdv_tdesp_viag_781.eh_reembolso,
                                          mr_cdv_tdesp_viag_781.eh_valz_km,
                                          mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                          mr_cdv_tdesp_viag_781.tip_despesa_contab,
                                          mr_cdv_tdesp_viag_781.hist_padrao_cap,
                                          mr_cdv_tdesp_viag_781.item,
                                          mr_cdv_tdesp_viag_781.item_hor,
                                          mr_cdv_tdesp_viag_781.informa_placa, #OS 487356
                                          mr_cdv_tdesp_viag_781.cobra_despesa)
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("INCLUSAO","CDV_TDESP_VIAG_781")
             LET l_houve_erro = TRUE
             EXIT FOREACH
          END IF

          INITIALIZE l_where_audit TO NULL
          LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", l_cod_empresa ,"' ",
                               " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                               " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
          CALL cdv2004_grava_auditoria(l_cod_empresa, l_where_audit, "I", 0)

       END FOREACH
       WHENEVER ERROR CONTINUE
       FREE cq_empresa
       WHENEVER ERROR STOP
    END IF

    IF l_houve_erro = FALSE THEN
       WHENEVER ERROR CONTINUE
       CALL log085_transacao("COMMIT")
       WHENEVER ERROR STOP

       MESSAGE "Inclusão efetuada com sucesso."          ATTRIBUTE(REVERSE)
    ELSE
       WHENEVER ERROR CONTINUE
       CALL log085_transacao("ROLLBACK")
       WHENEVER ERROR STOP

       MESSAGE "Problemas durante a gravação dos dados." ATTRIBUTE(REVERSE)
    END IF
 ELSE
    LET mr_cdv_tdesp_viag_781.* = mr_cdv_tdesp_viag_781r.*
    CALL cdv2004_exibe_dados()
    ERROR "Inclusão cancelada."
 END IF

END FUNCTION

#--------------------------------------#
FUNCTION cdv2004_entrada_dados(l_funcao)
#--------------------------------------#
    DEFINE l_funcao              CHAR(015),
           lr_plano_contas       RECORD LIKE plano_contas.*

    DEFINE l_des_tipo_desp       CHAR(50),
           l_des_tipo_despesa    CHAR(50),
           l_grp_ant             LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
           l_historico           LIKE hist_padrao_cap.historico

    IF l_funcao = 'INCLUSAO' THEN
       CALL log006_exibe_teclas('01 02 03 07', p_versao)
       CURRENT WINDOW IS w_cdv20041
       LET mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
       LET mr_cdv_tdesp_viag_781.eh_valz_km   = 'N'
    ELSE
       CALL log006_exibe_teclas('01 02 07', p_versao)
    END IF
    CURRENT WINDOW IS w_cdv20041

    LET int_flag = 0
    INPUT BY NAME mr_cdv_tdesp_viag_781.tip_despesa_viagem,
                  mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                  mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                  mr_cdv_tdesp_viag_781.ativ,
                  mr_cdv_tdesp_viag_781.eh_reembolso,
                  mr_cdv_tdesp_viag_781.eh_valz_km,
                  mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                  mr_cdv_tdesp_viag_781.tip_despesa_contab,
                  mr_cdv_tdesp_viag_781.hist_padrao_cap,
                  mr_cdv_tdesp_viag_781.item,
                  mr_cdv_tdesp_viag_781.item_hor,
                  mr_cdv_tdesp_viag_781.informa_placa,#OS 487356
                  mr_cdv_tdesp_viag_781.cobra_despesa,
                  mr_cdv_tdesp_viag_781.empresa WITHOUT DEFAULTS

    BEFORE INPUT
       IF mr_cdv_tdesp_viag_781.informa_placa IS NULL THEN
          LET mr_cdv_tdesp_viag_781.informa_placa = 'N'
       END IF
       IF mr_cdv_tdesp_viag_781.cobra_despesa IS NULL THEN
          LET mr_cdv_tdesp_viag_781.cobra_despesa = 'N'
       END IF

       BEFORE FIELD tip_despesa_viagem
           IF  l_funcao = 'MODIFICACAO' THEN
               NEXT FIELD des_tdesp_viagem
           END IF

       #AFTER FIELD tip_despesa_viagem
       #    IF l_funcao = 'INCLUSAO' THEN
       #        IF cdv2004_verifica_inclusao() THEN
       #           CALL log0030_mensagem("Tipo de despesa já cadastrada.","exclamation")
       #           NEXT FIELD tip_despesa_viagem
       #        END IF
       #    END IF

       BEFORE FIELD grp_despesa_viagem
           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,66
           END IF
           IF l_funcao = "MODIFICACAO" THEN
              LET l_grp_ant = mr_cdv_tdesp_viag_781.grp_despesa_viagem
           END IF

       AFTER FIELD grp_despesa_viagem
           IF mr_cdv_tdesp_viag_781.grp_despesa_viagem IS NULL
           OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = " " THEN
           ELSE
              IF NOT cdv2004_verifica_cdv_grp_desp_viag(mr_cdv_tdesp_viag_781.grp_despesa_viagem) THEN
                 CALL log0030_mensagem("Grupo da despesa não cadastrado.","exclamation")
                 NEXT FIELD grp_despesa_viagem
              END IF

              IF   mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5"
              AND (mr_cdv_tdesp_viag_781.cctbl_contab_ad    IS NOT NULL
              OR   mr_cdv_tdesp_viag_781.tip_despesa_contab IS NOT NULL
              OR   mr_cdv_tdesp_viag_781.hist_padrao_cap    IS NOT NULL ) THEN
                 INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                            mr_cdv_tdesp_viag_781.tip_despesa_contab,
                            l_des_tipo_despesa, l_historico, mr_cdv_tdesp_viag_781.hist_padrao_cap TO NULL
                  DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                  mr_cdv_tdesp_viag_781.tip_despesa_contab,
                                  mr_cdv_tdesp_viag_781.hist_padrao_cap
                  DISPLAY l_des_tipo_despesa TO des_tip_despesa_contab
                  DISPLAY l_historico TO des_hist_padrao_cap
              END IF

              IF l_grp_ant = "5" AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> "5" THEN
                 INITIALIZE mr_cdv_tdesp_viag_781.item_hor TO NULL
                 DISPLAY BY NAME mr_cdv_tdesp_viag_781.item_hor
              END IF

           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF

       BEFORE FIELD ativ
           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,66
           END IF

       AFTER FIELD ativ
          IF  mr_cdv_tdesp_viag_781.ativ IS NULL
          OR  mr_cdv_tdesp_viag_781.ativ = " " THEN
          ELSE
             IF NOT cdv2004_verifica_atividade(mr_cdv_tdesp_viag_781.ativ) THEN
                CALL log0030_mensagem("Atividade não cadastrada.","exclamation")
                NEXT FIELD ativ
             END IF
          END IF
          IF l_funcao = 'INCLUSAO' THEN
             IF cdv2004_verifica_inclusao() THEN
                CALL log0030_mensagem("Tipo de despesa já cadastrado para esta atividade.","exclamation")
                NEXT FIELD tip_despesa_viagem
             END IF
          END IF


       AFTER FIELD eh_reembolso
          IF mr_cdv_tdesp_viag_781.eh_reembolso IS NULL
          OR mr_cdv_tdesp_viag_781.eh_reembolso = " " THEN
             LET mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
             DISPLAY BY NAME mr_cdv_tdesp_viag_781.eh_reembolso
          END IF
          IF mr_cdv_tdesp_viag_781.eh_reembolso = 'N' THEN
             INITIALIZE mr_cdv_tdesp_viag_781.item, mr_cdv_tdesp_viag_781.cctbl_contab_ad TO NULL
             DISPLAY BY NAME mr_cdv_tdesp_viag_781.item, mr_cdv_tdesp_viag_781.cctbl_contab_ad
          END IF

       BEFORE FIELD eh_valz_km
          IF (fgl_lastkey() = fgl_keyval("UP")
          OR  fgl_lastkey() = fgl_keyval("LEFT"))
          AND (mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '2'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '3') THEN
              NEXT FIELD eh_reembolso
           END IF

          IF mr_cdv_tdesp_viag_781.grp_despesa_viagem IS NULL AND
          (fgl_lastkey() <> fgl_keyval("UP") AND
           fgl_lastkey() <> fgl_keyval("LEFT")) THEN
             NEXT FIELD cctbl_contab_ad
          END IF

          IF mr_cdv_tdesp_viag_781.grp_despesa_viagem IS NULL AND
           (fgl_lastkey() = fgl_keyval("UP") OR
            fgl_lastkey() = fgl_keyval("LEFT")) THEN
             NEXT FIELD eh_reembolso
          END IF

          IF  mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '2'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '3'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '6'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '7'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '8'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '9'
          AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '10'
           THEN #Alterado espec.2
             NEXT FIELD cctbl_contab_ad
          END IF

       AFTER FIELD eh_valz_km
          IF  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '5'
          AND mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
          AND (fgl_lastkey() <> fgl_keyval("UP")
          AND fgl_lastkey()  <> fgl_keyval("LEFT")) THEN
             NEXT FIELD item_hor
          END IF

          IF fgl_lastkey() = fgl_keyval("UP")
          OR fgl_lastkey() = fgl_keyval("LEFT") THEN
             NEXT FIELD eh_reembolso
          END IF

          IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = '6'
          OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '7'
          OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '8'
          OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '9'
          OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '10' THEN #Alterado espec.2
             #GOTO final_input
             NEXT FIELD empresa
          END IF

          IF mr_cdv_tdesp_viag_781.eh_valz_km IS NULL
          OR mr_cdv_tdesp_viag_781.eh_valz_km = " " THEN
             LET mr_cdv_tdesp_viag_781.eh_valz_km = 'N'
             DISPLAY BY NAME mr_cdv_tdesp_viag_781.eh_valz_km
          END IF

          IF  (mr_cdv_tdesp_viag_781.grp_despesa_viagem = '2'
          OR  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3')
          AND mr_cdv_tdesp_viag_781.eh_valz_km = 'N' THEN
             INITIALIZE mr_cdv_tdesp_viag_781.tip_despesa_contab,
                        l_des_tipo_despesa,
                        mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                        mr_cdv_tdesp_viag_781.hist_padrao_cap TO NULL
             DISPLAY l_des_tipo_despesa TO des_tip_despesa_contab
             DISPLAY '' TO des_hist_padrao_cap
             DISPLAY BY NAME mr_cdv_tdesp_viag_781.tip_despesa_contab,
                             mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                             mr_cdv_tdesp_viag_781.hist_padrao_cap

             IF mr_cdv_tdesp_viag_781.eh_reembolso = "S" THEN
                NEXT FIELD item
             ELSE
                #GOTO final_input
                NEXT FIELD empresa
             END IF
          END IF

          IF  (mr_cdv_tdesp_viag_781.grp_despesa_viagem = '2'
          OR  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3')
          AND mr_cdv_tdesp_viag_781.eh_valz_km = 'S' THEN
             INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad TO NULL
             DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad
             NEXT FIELD tip_despesa_contab
          END IF

       BEFORE FIELD cctbl_contab_ad
           IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5" THEN
              NEXT FIELD tip_despesa_contab
           END IF

           IF (fgl_lastkey() = fgl_keyval("UP")
           OR fgl_lastkey() = fgl_keyval("LEFT")) THEN
              NEXT FIELD eh_valz_km
           END IF

           IF mr_cdv_tdesp_viag_781.eh_reembolso = "N"
           AND mr_cdv_tdesp_viag_781.eh_valz_km = 'N' THEN
              NEXT FIELD tip_despesa_contab
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,66
           END IF

       AFTER FIELD cctbl_contab_ad
           IF mr_cdv_tdesp_viag_781.eh_reembolso = 'S' THEN
              IF  mr_cdv_tdesp_viag_781.cctbl_contab_ad IS NOT NULL
              AND mr_cdv_tdesp_viag_781.cctbl_contab_ad <> " " THEN
                 CALL con088_verifica_cod_conta(p_cod_empresa, mr_cdv_tdesp_viag_781.cctbl_contab_ad, "S", TODAY)
                      RETURNING lr_plano_contas.*, p_status
                 IF p_status = FALSE THEN
                    CALL log0030_mensagem("Conta contábil não cadastrada.","exclamation")
                    NEXT FIELD cctbl_contab_ad
                 END IF
              END IF
           END IF
           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF

       BEFORE FIELD tip_despesa_contab
           IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5" THEN
              NEXT FIELD hist_padrao_cap
           END IF

           IF (fgl_lastkey() = fgl_keyval("UP")
           OR fgl_lastkey() = fgl_keyval("LEFT"))
           AND mr_cdv_tdesp_viag_781.eh_reembolso = "S" THEN
              IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = "2"
              OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3' THEN
                 NEXT FIELD eh_valz_km
              ELSE
                 NEXT FIELD cctbl_contab_ad
              END IF
           END IF

           IF mr_cdv_tdesp_viag_781.eh_reembolso = "S"
           AND mr_cdv_tdesp_viag_781.eh_valz_km = "N" THEN
              NEXT FIELD hist_padrao_cap
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,66
           END IF

        AFTER FIELD tip_despesa_contab
           IF mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
           OR mr_cdv_tdesp_viag_781.eh_valz_km   = 'S' THEN
              IF  mr_cdv_tdesp_viag_781.tip_despesa_contab IS NOT NULL
              AND mr_cdv_tdesp_viag_781.tip_despesa_contab <> " " THEN
                 IF NOT cdv2004_verifica_tipo_despesa(mr_cdv_tdesp_viag_781.tip_despesa_contab) THEN
                    CALL log0030_mensagem("Tipo de despesa não cadastrado.","exclamation")
                    NEXT FIELD tip_despesa_contab
                 END IF
              END IF
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF

        BEFORE FIELD hist_padrao_cap
           IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5" THEN
              NEXT FIELD item
           END IF

           IF (fgl_lastkey() = fgl_keyval("UP")
           OR  fgl_lastkey() = fgl_keyval("LEFT")) THEN
              IF mr_cdv_tdesp_viag_781.eh_valz_km = 'S' THEN
                 NEXT FIELD tip_despesa_contab
              ELSE
                 NEXT FIELD eh_valz_km
              END IF
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
           ELSE
              DISPLAY "( Zoom )" AT 3,66
           END IF

       AFTER FIELD hist_padrao_cap
           IF  mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
           AND fgl_lastkey() <> fgl_keyval("ACCEPT") THEN
              #GOTO final_input
              NEXT FIELD informa_placa #OS 487356
           END IF

           IF  mr_cdv_tdesp_viag_781.hist_padrao_cap IS NOT NULL
           AND mr_cdv_tdesp_viag_781.hist_padrao_cap <> " " THEN
	              IF NOT cdv2004_verifica_hist_padrao_cap(mr_cdv_tdesp_viag_781.hist_padrao_cap) THEN
                 CALL log0030_mensagem("Histórico padrão não cadastrado.","exclamation")
                 NEXT FIELD hist_padrao_cap
              END IF
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF

       BEFORE FIELD item
          IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,66
          END IF

       AFTER FIELD item
           IF mr_cdv_tdesp_viag_781.eh_reembolso = 'S' THEN
              IF  mr_cdv_tdesp_viag_781.item IS NOT NULL
              AND mr_cdv_tdesp_viag_781.item <> " " THEN
                 IF NOT cdv2004_verifica_item(mr_cdv_tdesp_viag_781.item) THEN
                    CALL log0030_mensagem("Item não cadastrado.","exclamation")
                    NEXT FIELD item
                 END IF
              END IF
           END IF

           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF

       BEFORE FIELD item_hor
          IF mr_cdv_tdesp_viag_781.grp_despesa_viagem <> "5" THEN
             #GOTO final_input
             NEXT FIELD informa_placa #OS 487356
          END IF
          IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,66
          END IF

       AFTER FIELD item_hor
           IF (fgl_lastkey() = fgl_keyval("UP")
           OR fgl_lastkey() = fgl_keyval("LEFT"))
           AND mr_cdv_tdesp_viag_781.eh_reembolso = 'N' THEN
              NEXT FIELD eh_valz_km
           END IF

           IF  mr_cdv_tdesp_viag_781.item_hor IS NOT NULL
           AND mr_cdv_tdesp_viag_781.item_hor <> " " THEN
              IF NOT cdv2004_verifica_item(mr_cdv_tdesp_viag_781.item_hor) THEN
                 CALL log0030_mensagem("Item não cadastrado.","exclamation")
                 NEXT FIELD item
              END IF
           END IF
           IF g_ies_grafico THEN
              --#CALL fgl_dialog_setkeylabel('control-z','')
           ELSE
              DISPLAY "--------" AT 3,66
           END IF



       ON KEY (f1, control-w)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE INPUT
          #lds END IF
           CALL cdv2004_help()

       ON KEY (control-z, f4)
           CALL cdv2004_popup()

       AFTER INPUT
         #LABEL final_input:
         IF INT_FLAG = 0 THEN
            IF l_funcao = 'INCLUSAO' THEN
               IF cdv2004_verifica_inclusao() THEN
                  CALL log0030_mensagem("Tipo de despesa já cadastrado para esta atividade.","exclamation")
                  NEXT FIELD tip_despesa_viagem
               END IF
            END IF

            IF mr_cdv_tdesp_viag_781.tip_despesa_viagem IS NULL
            OR mr_cdv_tdesp_viag_781.tip_despesa_viagem = " " THEN
               CALL log0030_mensagem("Tipo de despesa de viagem não informado.","exclamation")
               NEXT FIELD tip_despesa_viagem
            END IF

            IF mr_cdv_tdesp_viag_781.des_tdesp_viagem IS NULL
            OR mr_cdv_tdesp_viag_781.des_tdesp_viagem = " " THEN
               CALL log0030_mensagem("Descrição da despesa de viagem não informada.","exclamation")
               NEXT FIELD des_tdesp_viagem
            END IF

            IF mr_cdv_tdesp_viag_781.grp_despesa_viagem IS NULL
            OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = " " THEN
                CALL log0030_mensagem("Grupo da despesa não informado.","exclamation")
                NEXT FIELD grp_despesa_viagem
            END IF

            IF NOT cdv2004_verifica_cdv_grp_desp_viag(mr_cdv_tdesp_viag_781.grp_despesa_viagem) THEN
               CALL log0030_mensagem("Grupo da despesa não cadastrado.","exclamation")
               NEXT FIELD grp_despesa_viagem
            END IF

            IF  mr_cdv_tdesp_viag_781.ativ IS NULL
            OR  mr_cdv_tdesp_viag_781.ativ = " " THEN
                CALL log0030_mensagem("Atividade não informada.","exclamation")
                NEXT FIELD ativ
            END IF

            IF NOT cdv2004_verifica_atividade(mr_cdv_tdesp_viag_781.ativ) THEN
               CALL log0030_mensagem("Atividade não cadastrada.","exclamation")
               NEXT FIELD ativ
            END IF

            IF mr_cdv_tdesp_viag_781.eh_reembolso IS NULL
            OR mr_cdv_tdesp_viag_781.eh_reembolso = " " THEN
               LET mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
               DISPLAY BY NAME mr_cdv_tdesp_viag_781.eh_reembolso
            END IF

            IF mr_cdv_tdesp_viag_781.eh_valz_km IS NULL
            OR mr_cdv_tdesp_viag_781.eh_valz_km = " " THEN
               LET mr_cdv_tdesp_viag_781.eh_valz_km = 'N'
               DISPLAY BY NAME mr_cdv_tdesp_viag_781.eh_valz_km
            END IF

            IF  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '2'
            OR  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3'
            AND mr_cdv_tdesp_viag_781.eh_valz_km = "N" THEN
                EXIT INPUT
            END IF

            IF  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '2'
            OR  mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3'
            AND mr_cdv_tdesp_viag_781.eh_valz_km = "S" THEN
				            IF mr_cdv_tdesp_viag_781.tip_despesa_contab IS NULL
				            OR mr_cdv_tdesp_viag_781.tip_despesa_contab = ' ' THEN
				               CALL log0030_mensagem('Tipo de despesa não informado.','exclamation')
				               NEXT FIELD tip_despesa_contab
				            END IF
				            IF mr_cdv_tdesp_viag_781.hist_padrao_cap IS NULL
				            OR mr_cdv_tdesp_viag_781.hist_padrao_cap = ' ' THEN
				               CALL log0030_mensagem('Histórico padrão não informado.','exclamation')
				               NEXT FIELD hist_padrao_cap
				            END IF
            END IF

            IF mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '6'
            AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '7'
            AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '8'
            AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '9'
            AND mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '10' THEN
               IF mr_cdv_tdesp_viag_781.eh_reembolso = 'S' THEN
                  IF  mr_cdv_tdesp_viag_781.cctbl_contab_ad IS NOT NULL
                  AND mr_cdv_tdesp_viag_781.cctbl_contab_ad <> " " THEN
                     CALL con088_verifica_cod_conta(p_cod_empresa, mr_cdv_tdesp_viag_781.cctbl_contab_ad, "S", TODAY)
                          RETURNING lr_plano_contas.*, p_status
                     IF p_status = FALSE THEN
                        CALL log0030_mensagem("Conta contábil não cadastrada.","exclamation")
                        NEXT FIELD cctbl_contab_ad
                     END IF
                  ELSE
                     IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = '2'
                     OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '3'
                     OR mr_cdv_tdesp_viag_781.grp_despesa_viagem = '5' THEN
                     ELSE
                        CALL log0030_mensagem("Conta contábil não informada. ","exclamation")
                        NEXT FIELD cctbl_contab_ad
                     END IF
                  END IF
               END IF

               IF  mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
               AND mr_cdv_tdesp_viag_781.eh_valz_km   = 'N'
               AND (mr_cdv_tdesp_viag_781.cctbl_contab_ad IS NOT NULL
               AND   mr_cdv_tdesp_viag_781.cctbl_contab_ad <> " " )THEN
                     INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad TO NULL
                     DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad
                     INITIALIZE mr_cdv_tdesp_viag_781.item TO NULL
                     DISPLAY BY NAME mr_cdv_tdesp_viag_781.item
               END IF

               IF mr_cdv_tdesp_viag_781.eh_reembolso = 'N' THEN
                  IF  mr_cdv_tdesp_viag_781.tip_despesa_contab IS NOT NULL
                  AND mr_cdv_tdesp_viag_781.tip_despesa_contab <> " " THEN
                     IF NOT cdv2004_verifica_tipo_despesa(mr_cdv_tdesp_viag_781.tip_despesa_contab) THEN
                        CALL log0030_mensagem("Tipo de despesa não cadastrado.","exclamation")
                        NEXT FIELD tip_despesa_contab
                     END IF
                  ELSE
                     IF  mr_cdv_tdesp_viag_781.grp_despesa_viagem <> '5'
                     AND mr_cdv_tdesp_viag_781.eh_valz_km = "S" THEN
                        CALL log0030_mensagem("Tipo de despesa não informado.","exclamation")
                        NEXT FIELD tip_despesa_contab
                     END IF
                  END IF
               END IF

               IF   mr_cdv_tdesp_viag_781.eh_reembolso = 'S'
               AND (mr_cdv_tdesp_viag_781.tip_despesa_contab IS NOT NULL
               AND  mr_cdv_tdesp_viag_781.tip_despesa_contab <> " " )
               AND  mr_cdv_tdesp_viag_781.eh_valz_km = "N" THEN    #Inclusao 25.11.2005 - clausula 'eh_val_km = N'
                  INITIALIZE mr_cdv_tdesp_viag_781.tip_despesa_contab, l_des_tipo_desp TO NULL
                  DISPLAY BY NAME mr_cdv_tdesp_viag_781.tip_despesa_contab
                  DISPLAY l_des_tipo_desp TO des_tip_despesa_contab
               END IF

               IF mr_cdv_tdesp_viag_781.eh_reembolso = 'S' THEN
                  IF  mr_cdv_tdesp_viag_781.item IS NOT NULL
                  AND mr_cdv_tdesp_viag_781.item <> " " THEN
                     IF NOT cdv2004_verifica_item(mr_cdv_tdesp_viag_781.item) THEN
                        CALL log0030_mensagem("Item não cadastrado.","exclamation")
                        NEXT FIELD item
                     END IF
                  ELSE
                     CALL log0030_mensagem("Item não informado. ","exclamation")
                     NEXT FIELD item
                  END IF
               END IF

               IF   mr_cdv_tdesp_viag_781.eh_reembolso = 'N'
               AND (mr_cdv_tdesp_viag_781.item IS NOT NULL
               AND  mr_cdv_tdesp_viag_781.item <> " " ) THEN
                  INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad TO NULL
                  DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad
                  INITIALIZE mr_cdv_tdesp_viag_781.item TO NULL
                  DISPLAY BY NAME mr_cdv_tdesp_viag_781.item
               END IF

               IF   mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5"
               AND (mr_cdv_tdesp_viag_781.cctbl_contab_ad    IS NOT NULL
               OR   mr_cdv_tdesp_viag_781.tip_despesa_contab IS NOT NULL
               OR   mr_cdv_tdesp_viag_781.hist_padrao_cap    IS NOT NULL ) THEN
                  INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                             mr_cdv_tdesp_viag_781.tip_despesa_contab,
                             mr_cdv_tdesp_viag_781.hist_padrao_cap TO NULL
                   DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                   mr_cdv_tdesp_viag_781.tip_despesa_contab,
                                   mr_cdv_tdesp_viag_781.hist_padrao_cap
               END IF

               IF   mr_cdv_tdesp_viag_781.grp_despesa_viagem = "5"
               AND (mr_cdv_tdesp_viag_781.item_hor IS NULL
               OR   mr_cdv_tdesp_viag_781.item_hor = " ") THEN
                  CALL log0030_mensagem("Item horas não informado. ","exclamation")
                  NEXT FIELD item_hor
               END IF
               IF mr_cdv_tdesp_viag_781.eh_reembolso = 'N' THEN
                  IF  mr_cdv_tdesp_viag_781.eh_valz_km = "N" THEN     #Inclusao 25.11.2005 IF....
                     INITIALIZE mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                mr_cdv_tdesp_viag_781.item TO NULL
                     DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                                     mr_cdv_tdesp_viag_781.item
                  END IF
               ELSE
                  IF  mr_cdv_tdesp_viag_781.eh_valz_km = "N" THEN     #Inclusao 25.11.2005 IF....
                     INITIALIZE mr_cdv_tdesp_viag_781.tip_despesa_contab TO NULL
                     DISPLAY BY NAME mr_cdv_tdesp_viag_781.tip_despesa_contab
                  END IF
               END IF

               IF   mr_cdv_tdesp_viag_781.grp_despesa_viagem <> "5"
               AND (mr_cdv_tdesp_viag_781.hist_padrao_cap IS NULL
               OR   mr_cdv_tdesp_viag_781.hist_padrao_cap = " ") THEN
                  IF mr_cdv_tdesp_viag_781.eh_valz_km = "S" THEN
                     CALL log0030_mensagem("Histórico padrão não informado. ","exclamation")
                     NEXT FIELD hist_padrao_cap
                  END IF
               END IF
            END IF

         END IF

    END INPUT

    DISPLAY '--------' AT 3,66
    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv20041

    IF  int_flag THEN
        LET int_flag = FALSE
        RETURN FALSE
    ELSE
        RETURN TRUE
    END IF

END FUNCTION

#------------------------------------------------------#
 FUNCTION cdv2004_verifica_hist_padrao_cap(l_hist_padrao)
#------------------------------------------------------#
 DEFINE l_hist_padrao LIKE cdv_tdesp_viag_781.hist_padrao_cap,
        l_historico   LIKE hist_padrao_cap.historico

 WHENEVER ERROR CONTINUE
 SELECT historico
   INTO l_historico
   FROM hist_padrao_cap
  WHERE cod_hist = l_hist_padrao
    AND ies_ad_ap = "1"
 WHENEVER ERROR STOP

 DISPLAY l_historico TO des_hist_padrao_cap

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-----------------------------------#
 FUNCTION cdv2004_verifica_inclusao()
#-----------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT tip_despesa_viagem
   FROM cdv_tdesp_viag_781
  WHERE empresa            = mr_cdv_tdesp_viag_781.empresa
    AND tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
    AND ativ               = mr_cdv_tdesp_viag_781.ativ
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------------------------------------#
 FUNCTION cdv2004_verifica_cdv_grp_desp_viag(l_grp_despesa_viagem)
#------------------------------------------------------------------#
DEFINE l_grp_despesa_viagem   LIKE cdv_tdesp_viag_781.grp_despesa_viagem,
       l_des_grp_desp_viag    CHAR(100)

   LET l_des_grp_desp_viag = NULL

   IF  l_grp_despesa_viagem <> "1"
   AND l_grp_despesa_viagem <> "2"
   AND l_grp_despesa_viagem <> "3"
   AND l_grp_despesa_viagem <> "4"
   AND l_grp_despesa_viagem <> "5"
   AND l_grp_despesa_viagem <> "6"
   AND l_grp_despesa_viagem <> "7"
   AND l_grp_despesa_viagem <> "8"
   AND l_grp_despesa_viagem <> "9"
   AND l_grp_despesa_viagem <> "10"
   AND l_grp_despesa_viagem <> "11" #OS 487356
   AND l_grp_despesa_viagem <> "12"
    THEN
       RETURN FALSE
   ELSE
      IF l_grp_despesa_viagem = "1" THEN
         LET l_des_grp_desp_viag = "Despesa urbana"
      END IF

      IF l_grp_despesa_viagem = "2" THEN
         LET l_des_grp_desp_viag = "Despesa de quilometragem"
      END IF

      IF l_grp_despesa_viagem = "3" THEN
         LET l_des_grp_desp_viag = "Despesa de quilometragem semanal"
      END IF

      IF l_grp_despesa_viagem = "4" THEN
         LET l_des_grp_desp_viag = "Despesa de terceiros"
      END IF

      IF l_grp_despesa_viagem = "5" THEN
         LET l_des_grp_desp_viag = "Apontamento de horas"
      END IF

      IF l_grp_despesa_viagem = "6" THEN
         LET l_des_grp_desp_viag = "Certificado"
      END IF

      IF l_grp_despesa_viagem = "7" THEN
         LET l_des_grp_desp_viag = "Km ASLE"
      END IF

      IF l_grp_despesa_viagem = "8" THEN
         LET l_des_grp_desp_viag = "Horas ASLE"
      END IF

      IF l_grp_despesa_viagem = "9" THEN
         LET l_des_grp_desp_viag = "Horas ADM ASLE"
      END IF

      IF l_grp_despesa_viagem = "10" THEN
         LET l_des_grp_desp_viag = "Auditoria"
      END IF

      IF l_grp_despesa_viagem = "11" THEN #OS 487356
         LET l_des_grp_desp_viag = "Salvados"
      END IF

      IF l_grp_despesa_viagem = "12" THEN #OS 487356
         LET l_des_grp_desp_viag = "Recuperação Cargas"
      END IF
   END IF

   DISPLAY l_des_grp_desp_viag TO des_grp_desp_viag

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION cdv2004_help()
#------------------------#

    CASE
        WHEN infield(tip_despesa_viagem) CALL SHOWHELP(101)
        WHEN infield(des_tdesp_viagem)   CALL SHOWHELP(102)
        WHEN infield(grp_despesa_viagem) CALL SHOWHELP(103)
        WHEN infield(ativ)               CALL SHOWHELP(104)
        WHEN infield(eh_reembolso)       CALL SHOWHELP(105)
        WHEN infield(cctbl_contab_ad)    CALL SHOWHELP(106)
        WHEN infield(hist_padrao_cap)    CALL SHOWHELP(107)
        WHEN infield(tip_despesa_contab) CALL SHOWHELP(109)
        WHEN infield(eh_valz_km)         CALL SHOWHELP(110)
        WHEN infield(item)               CALL SHOWHELP(111)
        WHEN infield(item_hor)           CALL SHOWHELP(112)
        WHEN infield(informa_placa)      CALL SHOWHELP(113) #OS 487356
        WHEN infield(cobra_despesa)      CALL SHOWHELP(114)

    END CASE

END FUNCTION

#----------------------#
FUNCTION cdv2004_popup()
#----------------------#
 DEFINE l_grp_despesa_viagem LIKE cdv_tdesp_viag_781.grp_despesa_viagem
 DEFINE l_condicao           CHAR(300),
        l_cctbl_contab_ad    LIKE cdv_tdesp_viag_781.cctbl_contab_ad,
        l_hist_padrao_cap    LIKE cdv_tdesp_viag_781.hist_padrao_cap,
        l_cod_ativ           LIKE cdv_tdesp_viag_781.ativ,
        l_tip_despesa_contab LIKE cdv_tdesp_viag_781.tip_despesa_contab,
        l_item               LIKE cdv_tdesp_viag_781.item

    LET l_condicao = NULL

    CASE
       WHEN infield(grp_despesa_viagem) #OS 487356
            LET l_grp_despesa_viagem = log0830_list_box(12,30,
            "1 {Despesa urbana},2 {Despesa quilometragem},3 {Despesa de km semanal},4 {Despesa de terceiros},5 {Apontamento de horas},6 {Certificado},7 {Km ASLE},8 {Horas ASLE},9 {Horas ADM ASLE},10 {Auditoria},11 {Salvados},12 {Recuperação Cargas}")

            IF  l_grp_despesa_viagem IS NOT NULL
            AND l_grp_despesa_viagem <> " " THEN
               LET mr_cdv_tdesp_viag_781.grp_despesa_viagem = l_grp_despesa_viagem
               CURRENT WINDOW IS w_cdv20041
               DISPLAY BY NAME mr_cdv_tdesp_viag_781.grp_despesa_viagem
            END IF
            CURRENT WINDOW IS w_cdv20041

       WHEN infield(cctbl_contab_ad)
         LET l_cctbl_contab_ad  = con010_popup_selecao_plano_contas(p_cod_empresa)
         CURRENT WINDOW IS w_cdv20041

         IF l_cctbl_contab_ad IS NOT NULL  THEN
            LET mr_cdv_tdesp_viag_781.cctbl_contab_ad = l_cctbl_contab_ad
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.cctbl_contab_ad
         END IF

       WHEN INFIELD(ativ)
          LET l_cod_ativ = log009_popup(5,25,"ATIVIDADES",
                                              "cdv_ativ_781",
                                              "ativ",
                                              "des_ativ",
                                              "cdv2005",
                                              "N","")
         CURRENT WINDOW IS w_cdv20041
         IF l_cod_ativ IS NOT NULL THEN
            LET mr_cdv_tdesp_viag_781.ativ = l_cod_ativ
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.ativ
         END IF

       WHEN infield(hist_padrao_cap)
         LET l_hist_padrao_cap = cap040_popup_historico_padrao("1")
         CURRENT WINDOW IS w_cdv20041

         IF l_hist_padrao_cap IS NOT NULL THEN
            LET mr_cdv_tdesp_viag_781.hist_padrao_cap = l_hist_padrao_cap
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.hist_padrao_cap
         END IF

       WHEN INFIELD(tip_despesa_contab)
         LET l_tip_despesa_contab = cap058_popup_tipo_despesa()
         CURRENT WINDOW IS w_cdv20041

         IF l_tip_despesa_contab IS NOT NULL THEN
            LET mr_cdv_tdesp_viag_781.tip_despesa_contab = l_tip_despesa_contab
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.tip_despesa_contab
         END IF

       WHEN INFIELD(item)
         LET l_item = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_cdv20041

         IF l_item IS NOT NULL THEN
            LET mr_cdv_tdesp_viag_781.item = l_item
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.item
         END IF

       WHEN INFIELD(item_hor)
         LET l_item = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_cdv20041

         IF l_item IS NOT NULL THEN
            LET mr_cdv_tdesp_viag_781.item_hor = l_item
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.item_hor
         END IF

       {WHEN INFIELD(tip_despesa_cap)
         LET l_tip_despesa_cap = con074_popup_cod_tip_desp(p_cod_empresa)
         IF l_tip_despesa_cap IS NOT NULL THEN
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_cdv20041
            LET mr_cdv_tdesp_viag_781.tip_despesa_cap = l_tip_despesa_cap
            DISPLAY BY NAME mr_cdv_tdesp_viag_781.tip_despesa_cap
         END IF}

    END CASE

    CALL log006_exibe_teclas('01 02 03 07', p_versao)
    CURRENT WINDOW IS w_cdv20041
END FUNCTION

#--------------------------------------------#
FUNCTION cdv2004_bloqueia_cdv_tdesp_viag_781()
#--------------------------------------------#

    WHENEVER ERROR CONTINUE
    DECLARE cm_cdv_viag_781 CURSOR FOR
     SELECT empresa,
            tip_despesa_viagem,
            des_tdesp_viagem,
            grp_despesa_viagem,
            ativ,
            eh_reembolso,
            eh_valz_km,
            cctbl_contab_ad,
            tip_despesa_contab,
            hist_padrao_cap,
            item,
            item_hor,
            informa_placa, #OS 487356
            cobra_despesa
      FROM cdv_tdesp_viag_781
     WHERE empresa            = mr_cdv_tdesp_viag_781.empresa
       AND tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
       AND ativ               = mr_cdv_tdesp_viag_781.ativ
    FOR UPDATE
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","CDV_TDESP_VIAG_781")
    END IF

    WHENEVER ERROR CONTINUE
    CALL log085_transacao("BEGIN")
    WHENEVER ERROR STOP

    WHENEVER ERROR CONTINUE
    OPEN cm_cdv_viag_781
    WHENEVER ERROR STOP

    IF  SQLCA.sqlcode = 0 THEN

       WHENEVER ERROR CONTINUE
       FETCH cm_cdv_viag_781 INTO mr_cdv_tdesp_viag_781.*
       WHENEVER ERROR STOP

       CASE
           WHEN sqlca.sqlcode = 0
               RETURN TRUE

           WHEN sqlca.sqlcode = NOTFOUND
               CALL log0030_mensagem(" Registro não mais existe na tabela.\nExecute a consulta novamente. ",
                                     "exclamation")
           OTHERWISE
               CALL log003_err_sql("LEITURA","CDV_TDESP_VIAG_781")
       END CASE

       WHENEVER ERROR CONTINUE
       CLOSE cm_cdv_viag_781
       FREE  cm_cdv_viag_781
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("FREE","cm_cdv_viag_781")
       END IF

    ELSE
        CALL log003_err_sql("LEITURA","cdv_tdesp_viag_781")
    END IF

    CALL log085_transacao("ROLLBACK")

    RETURN FALSE
END FUNCTION

#-----------------------------------------------#
FUNCTION cdv2004_modificacao_cdv_tdesp_viag_781()
#-----------------------------------------------#
 DEFINE l_where_audit    CHAR(1000),
        l_houve_erro     SMALLINT,
        l_replica        CHAR(01),
        l_cod_empresa    LIKE cdv_tdesp_viag_781.empresa

 #IF mr_cdv_tdesp_viag_781.grp_despesa_viagem = '6' THEN
 #   CALL log0030_mensagem('Modificação não permitida para este grupo.','exclamation')
 #   RETURN
 #END IF

 LET mr_cdv_tdesp_viag_781r.* = mr_cdv_tdesp_viag_781.*

 IF  cdv2004_bloqueia_cdv_tdesp_viag_781() THEN

     CALL cdv2004_exibe_dados()
     IF cdv2004_entrada_dados("MODIFICACAO") THEN
           INITIALIZE l_where_audit TO NULL
           LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", mr_cdv_tdesp_viag_781.empresa ,"' ",
                                " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                                " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
           CALL cdv2004_grava_auditoria(mr_cdv_tdesp_viag_781.empresa, l_where_audit, "M", 1)

           LET l_houve_erro = FALSE
           WHENEVER ERROR CONTINUE
           UPDATE cdv_tdesp_viag_781
              SET empresa            = mr_cdv_tdesp_viag_781.empresa,
                  tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem,
                  des_tdesp_viagem   = mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                  grp_despesa_viagem = mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                  ativ               = mr_cdv_tdesp_viag_781.ativ,
                  eh_reembolso       = mr_cdv_tdesp_viag_781.eh_reembolso,
                  eh_valz_km         = mr_cdv_tdesp_viag_781.eh_valz_km,
                  cctbl_contab_ad    = mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                  tip_despesa_contab = mr_cdv_tdesp_viag_781.tip_despesa_contab,
                  hist_padrao_cap    = mr_cdv_tdesp_viag_781.hist_padrao_cap,
                  item               = mr_cdv_tdesp_viag_781.item,
                  item_hor           = mr_cdv_tdesp_viag_781.item_hor,
                  informa_placa      = mr_cdv_tdesp_viag_781.informa_placa, #OS 487356
                  cobra_despesa      = mr_cdv_tdesp_viag_781.cobra_despesa
            WHERE CURRENT OF cm_cdv_viag_781
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode <> 0 THEN
              CALL log003_err_sql("UPDATE","CDV_TDESP_VIAG_781-1")
              LET l_houve_erro = TRUE
           ELSE
              CALL cdv2004_grava_auditoria(mr_cdv_tdesp_viag_781.empresa, l_where_audit, "M", 2)

              CALL log2250_busca_parametro(p_cod_empresa, "replicacao_td_empresas_pamcary")
                   RETURNING l_replica, p_status

              IF  p_status = TRUE
              AND l_replica = 'S' THEN
                 WHENEVER ERROR CONTINUE
                 DECLARE cq_empresa2 CURSOR FOR
                  SELECT DISTINCT empresa
                    FROM cdv_tdesp_viag_781
                   WHERE empresa  <> mr_cdv_tdesp_viag_781.empresa
                 WHENEVER ERROR STOP

                 IF SQLCA.sqlcode <> 0 THEN
                    CALL log003_err_sql("DECLARE","CQ_EMPRESA2")
                 END IF

                 WHENEVER ERROR CONTINUE
                 FOREACH cq_empresa2 INTO l_cod_empresa
                 WHENEVER ERROR STOP

                    IF SQLCA.sqlcode <> 0 THEN
                       CALL log003_err_sql("CQ_EMPRESA2","FOREACH")
                       EXIT FOREACH
                    END IF

                    INITIALIZE l_where_audit TO NULL
                    LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", l_cod_empresa ,"' ",
                                         " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                                         " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
                    CALL cdv2004_grava_auditoria(l_cod_empresa, l_where_audit, "M", 1)

                    WHENEVER ERROR CONTINUE
                    UPDATE cdv_tdesp_viag_781
                       SET des_tdesp_viagem   = mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                           grp_despesa_viagem = mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                           ativ               = mr_cdv_tdesp_viag_781.ativ,
                           eh_reembolso       = mr_cdv_tdesp_viag_781.eh_reembolso,
                           eh_valz_km         = mr_cdv_tdesp_viag_781.eh_valz_km,
                           cctbl_contab_ad    = mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                           tip_despesa_contab = mr_cdv_tdesp_viag_781.tip_despesa_contab,
                           hist_padrao_cap    = mr_cdv_tdesp_viag_781.hist_padrao_cap,
                           item               = mr_cdv_tdesp_viag_781.item,
                           item_hor           = mr_cdv_tdesp_viag_781.item_hor,
                           informa_placa      = mr_cdv_tdesp_viag_781.informa_placa, #OS 487356
                           cobra_despesa      = mr_cdv_tdesp_viag_781.cobra_despesa
                     WHERE empresa            = l_cod_empresa
                       AND tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
                       AND ativ               = mr_cdv_tdesp_viag_781.ativ
                    WHENEVER ERROR STOP

                    IF SQLCA.sqlcode <> 0 THEN
                       CALL log003_err_sql("UPDATE","CDV_TDESP_VIAG_781-2")
                       LET l_houve_erro = TRUE
                       EXIT FOREACH
                    END IF

                    INITIALIZE l_where_audit TO NULL
                    LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", l_cod_empresa ,"' ",
                                         " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                                         " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
                    CALL cdv2004_grava_auditoria(l_cod_empresa, l_where_audit, "M", 2)

                 END FOREACH
                 WHENEVER ERROR CONTINUE
                 FREE cq_empresa2
                 WHENEVER ERROR STOP

              END IF
           END IF

           IF l_houve_erro = FALSE THEN
              CALL log085_transacao("COMMIT")
              MESSAGE "Modificação efetuada com sucesso." ATTRIBUTE(REVERSE)
           ELSE
              CALL log003_err_sql("MODIFICACAO","CDV_TDESP_VIAG_781")
              CALL log085_transacao("ROLLBACK")
              LET mr_cdv_tdesp_viag_781.* = mr_cdv_tdesp_viag_781r.*
              CALL cdv2004_exibe_dados()
           END IF
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP

        LET mr_cdv_tdesp_viag_781.* = mr_cdv_tdesp_viag_781r.*

        CALL cdv2004_exibe_dados()
        ERROR "Modificação cancelada." ATTRIBUTE(REVERSE)
     END IF

     WHENEVER ERROR CONTINUE
     CLOSE cm_cdv_viag_781
     WHENEVER ERROR STOP
 ELSE
    CALL log0030_mensagem("Não existe nenhuma consulta ativa.","exclamation")

    WHENEVER ERROR CONTINUE
    CLOSE cm_cdv_viag_781
    WHENEVER ERROR STOP
 END IF

END FUNCTION

#--------------------------------------------#
FUNCTION cdv2004_exclusao_cdv_tdesp_viag_781()
#--------------------------------------------#
    DEFINE l_houve_erro          SMALLINT,
           l_where_audit         CHAR(1000),
           l_replica             CHAR(01),
           l_cod_empresa         LIKE cdv_tdesp_viag_781.empresa

    IF  cdv2004_bloqueia_cdv_tdesp_viag_781() THEN
        CALL cdv2004_exibe_dados()

        IF  log0040_confirm(5,10,"Confirma exclusão do registro?") THEN

            INITIALIZE l_where_audit TO NULL
            LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", mr_cdv_tdesp_viag_781.empresa ,"' ",
                                 " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                                 " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
            CALL cdv2004_grava_auditoria(mr_cdv_tdesp_viag_781.empresa, l_where_audit, "E", 0)

            LET l_houve_erro = FALSE

            WHENEVER ERROR CONTINUE
            DELETE FROM cdv_tdesp_viag_781
            WHERE CURRENT OF cm_cdv_viag_781
            WHENEVER ERROR STOP

            IF SQLCA.sqlcode <> 0 THEN
               CALL log003_err_sql("DELETE","CDV_TDESP_VIAG_781-1")
               LET l_houve_erro = TRUE
            ELSE
              CALL log2250_busca_parametro(p_cod_empresa, "replicacao_td_empresas_pamcary")
                   RETURNING l_replica, p_status

              IF  p_status = TRUE
              AND l_replica = 'S' THEN
                 WHENEVER ERROR CONTINUE
                 DECLARE cq_empresa3 CURSOR FOR
                  SELECT DISTINCT empresa
                    FROM cdv_tdesp_viag_781
                   WHERE empresa  <> mr_cdv_tdesp_viag_781.empresa
                 WHENEVER ERROR STOP

                 IF SQLCA.sqlcode <> 0 THEN
                    CALL log003_err_sql("DECLARE","CQ_EMPRESA3")
                 END IF

                 WHENEVER ERROR CONTINUE
                 FOREACH cq_empresa3 INTO l_cod_empresa
                 WHENEVER ERROR STOP

                    IF SQLCA.sqlcode <> 0 THEN
                       CALL log003_err_sql("CQ_EMPRESA3","FOREACH")
                       EXIT FOREACH
                    END IF

                    INITIALIZE l_where_audit TO NULL
                    LET l_where_audit =  " cdv_tdesp_viag_781.empresa                = '", l_cod_empresa ,"' ",
                                         " AND cdv_tdesp_viag_781.tip_despesa_viagem =  ", mr_cdv_tdesp_viag_781.tip_despesa_viagem, " ",
                                         " AND cdv_tdesp_viag_781.ativ               =  ", mr_cdv_tdesp_viag_781.ativ, " "
                    CALL cdv2004_grava_auditoria(l_cod_empresa, l_where_audit, "E", 0)

                    WHENEVER ERROR CONTINUE
                    DELETE FROM cdv_tdesp_viag_781
                    WHERE empresa            = l_cod_empresa
                      AND tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
                      AND ativ               = mr_cdv_tdesp_viag_781.ativ
                    WHENEVER ERROR STOP

                    IF SQLCA.sqlcode <> 0 THEN
                       CALL log003_err_sql("DELETE","CDV_TDESP_VIAG_781-2")
                       LET l_houve_erro = TRUE
                       EXIT FOREACH
                    END IF

                 END FOREACH
                 WHENEVER ERROR CONTINUE
                 FREE cq_empresa3
                 WHENEVER ERROR STOP

              END IF
            END IF

            IF l_houve_erro = FALSE THEN
                WHENEVER ERROR CONTINUE
                CLOSE cm_cdv_viag_781
                WHENEVER ERROR STOP

                WHENEVER ERROR CONTINUE
                CALL log085_transacao("COMMIT")
                WHENEVER ERROR STOP

                MESSAGE " Exclusão efetuada com sucesso." ATTRIBUTE(REVERSE)

                INITIALIZE mr_cdv_tdesp_viag_781.* TO NULL

                CALL cdv2004_exibe_dados()
            ELSE
                CALL log003_err_sql("EXCLUSAO","cdv_tdesp_viag_781")

                WHENEVER ERROR CONTINUE
                CLOSE cm_cdv_viag_781
                WHENEVER ERROR STOP

                WHENEVER ERROR CONTINUE
                CALL log085_transacao("ROLLBACK")
                WHENEVER ERROR STOP
            END IF
        ELSE
            WHENEVER ERROR CONTINUE
            CLOSE cm_cdv_viag_781
            WHENEVER ERROR STOP

            WHENEVER ERROR CONTINUE
            CALL log085_transacao("ROLLBACK")
            WHENEVER ERROR STOP
            ERROR "Exclusão cancelada."
        END IF
    END IF
END FUNCTION


#--------------------------------------------#
FUNCTION cdv2004_consulta_cdv_tdesp_viag_781()
#--------------------------------------------#
    CALL log006_exibe_teclas('01 02 07 08', p_versao)
    CURRENT WINDOW IS w_cdv20041

    INITIALIZE where_clause TO NULL

    CLEAR FORM
    DISPLAY p_cod_empresa TO empresa
    LET int_flag           = FALSE

    CONSTRUCT BY NAME where_clause ON cdv_tdesp_viag_781.tip_despesa_viagem,
                                      cdv_tdesp_viag_781.des_tdesp_viagem,
                                      cdv_tdesp_viag_781.grp_despesa_viagem,
                                      cdv_tdesp_viag_781.ativ,
                                      cdv_tdesp_viag_781.eh_reembolso,
                                      cdv_tdesp_viag_781.eh_valz_km,
                                      cdv_tdesp_viag_781.cctbl_contab_ad,
                                      cdv_tdesp_viag_781.tip_despesa_contab,
                                      cdv_tdesp_viag_781.hist_padrao_cap,
                                      cdv_tdesp_viag_781.item,
                                      cdv_tdesp_viag_781.item_hor,
                                      cdv_tdesp_viag_781.informa_placa, #OS 487356
                                      cdv_tdesp_viag_781.cobra_despesa

       ON KEY (f1, control-w)
          #lds IF NOT LOG_logix_versao5() THEN
          #lds CONTINUE CONSTRUCT
          #lds END IF
           CALL cdv2004_help()

       ON KEY (control-z, f4)
           CALL cdv2004_popup()

    END CONSTRUCT

    CALL log006_exibe_teclas('01', p_versao)
    CURRENT WINDOW IS w_cdv20041

    IF  int_flag THEN
        LET int_flag         = FALSE
        ERROR ' Consulta cancelada. '
    ELSE
        CALL cdv2004_prepara_consulta()
    END IF

    CALL cdv2004_exibe_dados()

    CALL log006_exibe_teclas('01 09', p_versao)
    CURRENT WINDOW IS w_cdv20041
END FUNCTION

#---------------------------------#
FUNCTION cdv2004_prepara_consulta()
#---------------------------------#
    LET sql_stmt = "SELECT empresa, tip_despesa_viagem, des_tdesp_viagem, grp_despesa_viagem, ",
                         " ativ, eh_reembolso, eh_valz_km, cctbl_contab_ad, ",
                         " tip_despesa_contab, hist_padrao_cap, item, item_hor, informa_placa, cobra_despesa",
                     " FROM cdv_tdesp_viag_781  ",
                     " WHERE empresa = '", p_cod_empresa, "' ",
                     " AND ", where_clause CLIPPED,
                     " ORDER BY empresa, tip_despesa_viagem "

    WHENEVER ERROR CONTINUE
    PREPARE var_cdv_tdesp_viag_781 FROM sql_stmt
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","VAR_CDV_TDESP_VIAG_781")
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cq_cdv_tdesp_viag_781 SCROLL CURSOR WITH HOLD FOR var_cdv_tdesp_viag_781
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("cq_cdv_tdesp_viag_781","PREPARE")
    END IF

    WHENEVER ERROR CONTINUE
    OPEN  cq_cdv_tdesp_viag_781
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("cq_cdv_tdesp_viag_781","OPEN")
    END IF

    WHENEVER ERROR CONTINUE
    FETCH cq_cdv_tdesp_viag_781 INTO mr_cdv_tdesp_viag_781.*
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0 THEN
       MESSAGE " Consulta efetuada com sucesso. " ATTRIBUTE (REVERSE)
       LET m_consulta_ativa = TRUE
    ELSE
       LET m_consulta_ativa = FALSE
       CALL log0030_mensagem("Argumentos de pesquisa não encontrados. ","info")
    END IF

END FUNCTION

#----------------------------------#
FUNCTION cdv2004_paginacao(l_funcao)
#----------------------------------#
    DEFINE l_funcao            CHAR(010)

    LET mr_cdv_tdesp_viag_781r.* = mr_cdv_tdesp_viag_781.*

    WHILE TRUE
        IF  l_funcao = 'SEGUINTE' THEN
            WHENEVER ERROR CONTINUE
            FETCH NEXT     cq_cdv_tdesp_viag_781 INTO mr_cdv_tdesp_viag_781.*
            WHENEVER ERROR STOP
            IF SQLCA.sqlcode <> 0 THEN
            END IF
        ELSE
            WHENEVER ERROR CONTINUE
            FETCH PREVIOUS cq_cdv_tdesp_viag_781 INTO mr_cdv_tdesp_viag_781.*
            WHENEVER ERROR STOP
            IF SQLCA.sqlcode <> 0 THEN
            END IF
        END IF

        IF sqlca.sqlcode = 0 THEN
           WHENEVER ERROR CONTINUE
           SELECT empresa,             tip_despesa_viagem,
                  des_tdesp_viagem,    grp_despesa_viagem,
                  ativ,                eh_reembolso,
                  eh_valz_km,          cctbl_contab_ad,
                  tip_despesa_contab,  hist_padrao_cap,
                  item,                item_hor,
                  informa_placa, #OS 487356
                  cobra_despesa
             INTO mr_cdv_tdesp_viag_781.empresa,
                  mr_cdv_tdesp_viag_781.tip_despesa_viagem,
                  mr_cdv_tdesp_viag_781.des_tdesp_viagem,
                  mr_cdv_tdesp_viag_781.grp_despesa_viagem,
                  mr_cdv_tdesp_viag_781.ativ,
                  mr_cdv_tdesp_viag_781.eh_reembolso,
                  mr_cdv_tdesp_viag_781.eh_valz_km,
                  mr_cdv_tdesp_viag_781.cctbl_contab_ad,
                  mr_cdv_tdesp_viag_781.tip_despesa_contab,
                  mr_cdv_tdesp_viag_781.hist_padrao_cap,
                  mr_cdv_tdesp_viag_781.item,
                  mr_cdv_tdesp_viag_781.item_hor,
                  mr_cdv_tdesp_viag_781.informa_placa, #OS 487356
                  mr_cdv_tdesp_viag_781.cobra_despesa
             FROM cdv_tdesp_viag_781
            WHERE cdv_tdesp_viag_781.empresa            = mr_cdv_tdesp_viag_781.empresa
              AND cdv_tdesp_viag_781.tip_despesa_viagem = mr_cdv_tdesp_viag_781.tip_despesa_viagem
              AND cdv_tdesp_viag_781.ativ               = mr_cdv_tdesp_viag_781.ativ
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode = 0 THEN
              LET mr_cdv_tdesp_viag_781r.* = mr_cdv_tdesp_viag_781.*
              EXIT WHILE
           END IF
        ELSE
           ERROR "Não existem mais itens nesta direção."
           LET mr_cdv_tdesp_viag_781.* = mr_cdv_tdesp_viag_781r.*
           EXIT WHILE
        END IF
    END WHILE

    CALL cdv2004_exibe_dados()
END FUNCTION

#------------------------------#
FUNCTION cdv2004_exibe_dados()
#------------------------------#
    DEFINE l_status              SMALLINT

    DISPLAY BY NAME mr_cdv_tdesp_viag_781.*

    CALL cdv2004_verifica_cdv_grp_desp_viag(mr_cdv_tdesp_viag_781.grp_despesa_viagem) RETURNING p_status
    CALL cdv2004_verifica_atividade(mr_cdv_tdesp_viag_781.ativ)                       RETURNING p_status
    CALL cdv2004_verifica_tipo_despesa(mr_cdv_tdesp_viag_781.tip_despesa_contab)      RETURNING p_status
    CALL cdv2004_verifica_hist_padrao_cap(mr_cdv_tdesp_viag_781.hist_padrao_cap)      RETURNING p_status

END FUNCTION


#-----------------------------------------#
FUNCTION cdv2004_lista_cdv_tdesp_viag_781()
#-----------------------------------------#

    DEFINE lr_relat      RECORD LIKE cdv_tdesp_viag_781.*
    DEFINE l_mensagem    CHAR(100),
           l_tot_reg     INTEGER

    LET l_tot_reg = 0
    MESSAGE " Processando a extração do relatório ... " ATTRIBUTE(REVERSE)

    WHENEVER ERROR CONTINUE
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       INITIALIZE m_den_empresa TO NULL
    END IF

    IF  p_ies_impressao = 'S' THEN
        IF  g_ies_ambiente = 'U' THEN
            START REPORT cdv2004_relat TO PIPE p_nom_arquivo
        ELSE
            CALL log150_procura_caminho('LST') RETURNING m_caminho
            LET m_caminho = m_caminho CLIPPED, 'cdv2004.tmp'
            START REPORT cdv2004_relat TO m_caminho
        END IF
    ELSE
        START REPORT cdv2004_relat TO p_nom_arquivo
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cl_cdv_tdesp_viag_781 SCROLL CURSOR FOR
    SELECT  empresa,            tip_despesa_viagem,
            des_tdesp_viagem,   grp_despesa_viagem,
            ativ,               eh_reembolso,
            eh_valz_km,         cctbl_contab_ad,
            tip_despesa_contab, hist_padrao_cap,
            item,               item_hor,
            informa_placa,      cobra_despesa
      INTO mr_cdv_tdesp_viag_781.empresa,
           mr_cdv_tdesp_viag_781.tip_despesa_viagem,
           mr_cdv_tdesp_viag_781.des_tdesp_viagem,
           mr_cdv_tdesp_viag_781.grp_despesa_viagem,
           mr_cdv_tdesp_viag_781.ativ,
           mr_cdv_tdesp_viag_781.eh_reembolso,
           mr_cdv_tdesp_viag_781.eh_valz_km,
           mr_cdv_tdesp_viag_781.cctbl_contab_ad,
           mr_cdv_tdesp_viag_781.tip_despesa_contab,
           mr_cdv_tdesp_viag_781.hist_padrao_cap,
           mr_cdv_tdesp_viag_781.item,
           mr_cdv_tdesp_viag_781.item_hor,
           mr_cdv_tdesp_viag_781.informa_placa,
           mr_cdv_tdesp_viag_781.cobra_despesa
      FROM cdv_tdesp_viag_781
     WHERE empresa = p_cod_empresa
     ORDER BY tip_despesa_viagem
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("cl_cdv_tdesp_viag_781","DECLARE")
    END IF

    WHENEVER ERROR CONTINUE
    OPEN  cl_cdv_tdesp_viag_781
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("cl_cdv_tdesp_viag_781","OPEN")
    END IF

    WHENEVER ERROR CONTINUE
    FETCH cl_cdv_tdesp_viag_781 INTO lr_relat.*
    WHENEVER ERROR STOP

    IF sqlca.sqlcode = 0 THEN
       WHILE sqlca.sqlcode = 0
           OUTPUT TO REPORT cdv2004_relat(lr_relat.*)
           LET l_tot_reg = l_tot_reg + 1
           WHENEVER ERROR CONTINUE
           FETCH cl_cdv_tdesp_viag_781 INTO lr_relat.*
           WHENEVER ERROR STOP
           IF SQLCA.sqlcode <> 0 THEN
           END IF
       END WHILE
    ELSE
       INITIALIZE lr_relat.* TO NULL
       OUTPUT TO REPORT cdv2004_relat(lr_relat.*)
       CALL log0030_mensagem(" Nao existem dados para serem listados. " ,"info")
    END IF

    WHENEVER ERROR CONTINUE
    CLOSE cl_cdv_tdesp_viag_781
    WHENEVER ERROR STOP

    FINISH REPORT cdv2004_relat

    IF l_tot_reg > 0 THEN
       IF  g_ies_ambiente = "W"   AND
           p_ies_impressao = "S"  THEN
           LET m_comando = "lpdos.bat ", m_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
           RUN m_comando
       END IF

       IF  p_ies_impressao = "S" THEN
           CALL log0030_mensagem("Relatório gravado com sucesso.","info")
       ELSE
           LET  l_mensagem = "Relatório gravado no arquivo ",p_nom_arquivo CLIPPED
           CALL log0030_mensagem(l_mensagem,'info')
       END IF
    END IF
END FUNCTION

#-----------------------------------------#
REPORT cdv2004_relat(lr_cdv_tdesp_viag_781)
#-----------------------------------------#
 DEFINE lr_cdv_tdesp_viag_781    RECORD LIKE cdv_tdesp_viag_781.*,
        l_des_tipo_despesa       LIKE tipo_despesa.nom_tip_despesa,
        l_den_grupo              CHAR(25)
 DEFINE l_historico              LIKE hist_padrao_cap.historico

   OUTPUT
        LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
{
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CDV2004                         LISTAGEM DE TIPOS DE DESPESAS DE VIAGENS                          FL. ###&
                                                                   EXTRAIDO EM DD/MM/YYYY AS &&.&&.&& HRS.

TIPO   DESCRICAO DESPESA VIAGEM     GRUPO    VALIDADE INICIAL     VALIDADE FINAL      CONTA CONTABIL AD.
---- ------------------------------ -----  ------------------- ------------------- -----------------------
 XXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXX   XXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXX



* * * ULTIMA FOLHA * * *
}

    FORMAT
        PAGE HEADER
            PRINT log5211_retorna_configuracao(PAGENO,66,205) CLIPPED;
            PRINT COLUMN 001, m_den_empresa
            PRINT COLUMN 001, 'CDV2004                                              RELATORIO DE TIPOS DE DESPESAS DE VIAGENS ',
                  COLUMN 195, 'FL. ', PAGENO USING '###&'
            PRINT COLUMN 164, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy',
                              ' AS ', TIME, ' HRS.'
            SKIP 1 LINE
            PRINT COLUMN 001, '                                                                                            REEM  VALOR                                                                                                    INFO. COBRA'
            PRINT COLUMN 001, 'DESP  DESCRICAO TIPO DESPESA        GRUPO                     CONTA CONTABIL          ATIV  BOLSO QUILO TIPO DESPESA CONTABIL                 HISTORICO PADRAO             ITEM            ITEM HORAS      PLACA DESP.'
            PRINT COLUMN 001, '----- ----------------------------- ------------------------- ----------------------- ----- ----- ----- ------------------------------------- ---------------------------- --------------- --------------- ----- -----'

         ON EVERY ROW
            LET l_des_tipo_despesa = cdv2004_busca_tipo_despesa(lr_cdv_tdesp_viag_781.tip_despesa_contab)
            LET l_historico        = cdv2004_busca_historico_padrao(lr_cdv_tdesp_viag_781.hist_padrao_cap)
            LET l_den_grupo        = cdv2004_busca_grupo_despesa(lr_cdv_tdesp_viag_781.grp_despesa_viagem)
            PRINT COLUMN 001, lr_cdv_tdesp_viag_781.tip_despesa_viagem USING "####&",
                  COLUMN 007, lr_cdv_tdesp_viag_781.des_tdesp_viagem   CLIPPED,
                  COLUMN 037, lr_cdv_tdesp_viag_781.grp_despesa_viagem USING "&&", "- ",
                              l_den_grupo CLIPPED,
                  COLUMN 063, lr_cdv_tdesp_viag_781.cctbl_contab_ad    CLIPPED,
                  COLUMN 087, lr_cdv_tdesp_viag_781.ativ;
            IF lr_cdv_tdesp_viag_781.eh_reembolso = 'S' THEN
               PRINT COLUMN 093, "SIM";
            ELSE
               PRINT COLUMN 093, "NAO";
            END IF
            IF lr_cdv_tdesp_viag_781.eh_valz_km = 'S' THEN
               PRINT COLUMN 099, "SIM";
            ELSE
               PRINT COLUMN 099, "NAO";
            END IF

            IF lr_cdv_tdesp_viag_781.tip_despesa_contab IS NULL THEN
               PRINT COLUMN 105, ' ';
            ELSE
               PRINT COLUMN 105, lr_cdv_tdesp_viag_781.tip_despesa_contab USING "<<&",
                                 " - ",
                                 l_des_tipo_despesa CLIPPED;
            END IF
            IF lr_cdv_tdesp_viag_781.hist_padrao_cap IS NOT NULL THEN
               PRINT COLUMN 143, lr_cdv_tdesp_viag_781.hist_padrao_cap USING "<<#", " - ",
                                 l_historico[1,23];
            ELSE
               PRINT COLUMN 143, ' ';
            END IF

            PRINT COLUMN 172, lr_cdv_tdesp_viag_781.item CLIPPED,
                  COLUMN 188, lr_cdv_tdesp_viag_781.item_hor;

            IF lr_cdv_tdesp_viag_781.informa_placa = 'S' THEN
               PRINT COLUMN 204, "SIM";
            ELSE
               PRINT COLUMN 204, "NAO";
            END IF

            IF lr_cdv_tdesp_viag_781.cobra_despesa = 'S' THEN
               PRINT COLUMN 210, "SIM"
            ELSE
               PRINT COLUMN 210, "NAO"
            END IF

         ON LAST ROW
            LET m_last_row = true

         PAGE TRAILER
            IF  m_last_row = true
              THEN PRINT '* * * ULTIMA FOLHA * * *'
            ELSE PRINT ' '
            END IF
END REPORT

 #---------------------------------------------#
 FUNCTION cdv2004_verif_uso_linha_prod_cmi()
#---------------------------------------------#

  WHENEVER ERROR CONTINUE
  SELECT par_ies INTO g_ies_linha_prod_cmi
    FROM par_cap_pad
   WHERE par_cap_pad.cod_empresa    = p_cod_empresa
     AND par_cap_pad.cod_parametro  = "ies_linha_prod_cmi"
  WHENEVER ERROR STOP

  IF (SQLCA.sqlcode <> 0) OR ( g_ies_linha_prod_cmi IS NULL) THEN
     LET g_ies_linha_prod_cmi = "N"
  END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2004_verifica_atividade(l_cod_ativ)
#----------------------------------------------#
 DEFINE l_cod_ativ     LIKE cdv_ativ_781.ativ,
        l_des_ativ     LIKE cdv_ativ_781.des_ativ

 INITIALIZE l_des_ativ TO NULL

 WHENEVER ERROR CONTINUE
 SELECT des_ativ
   INTO l_des_ativ
   FROM cdv_ativ_781
  WHERE ativ  = l_cod_ativ
 WHENEVER ERROR STOP

 DISPLAY l_des_ativ TO des_ativ

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-----------------------------------------------------------#
 FUNCTION cdv2004_verifica_tipo_despesa(l_tip_despesa_contab)
#-----------------------------------------------------------#
 DEFINE l_tip_despesa_contab  LIKE cdv_tdesp_viag_781.tip_despesa_contab,
        l_den_tip_desp        LIKE tipo_despesa.nom_tip_despesa

 INITIALIZE l_den_tip_desp TO NULL

 WHENEVER ERROR CONTINUE
 SELECT nom_tip_despesa
   INTO l_den_tip_desp
   FROM tipo_despesa
  WHERE cod_empresa     = p_cod_empresa
    AND cod_tip_despesa = l_tip_despesa_contab
 WHENEVER ERROR STOP

 DISPLAY l_den_tip_desp TO des_tip_despesa_contab

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2004_verifica_item(l_item)
#-------------------------------------#
 DEFINE l_item           LIKE cdv_tdesp_viag_781.item

 WHENEVER ERROR CONTINUE
 SELECT cod_item
   FROM item
  WHERE cod_empresa  = p_cod_empresa
    AND cod_item     = l_item
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#--------------------------------------------------------------#
 FUNCTION cdv2004_grava_auditoria(l_cod_empresa,l_where_audit, l_opcao, l_num)
#--------------------------------------------------------------#
 DEFINE l_where_audit CHAR(1000),
        l_opcao       CHAR(01),
        l_num         SMALLINT,
        l_cod_empresa LIKE empresa.cod_empresa

 IF NOT cdv0801_geracao_auditoria(l_cod_empresa, "cdv_tdesp_viag_781", l_where_audit, l_opcao, "CDV2004", l_num) THEN
    CALL log003_err_sql('INSERT','CDV_AUDITORIA_781')
 END IF

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2004_busca_tipo_despesa(l_tipo_despesa)
#--------------------------------------------------#
 DEFINE l_tipo_despesa  LIKE cdv_tdesp_viag_781.tip_despesa_contab,
        l_nom_tip_desp  LIKE tipo_despesa.nom_tip_despesa

 WHENEVER ERROR CONTINUE
 SELECT nom_tip_despesa
   INTO l_nom_tip_desp
   FROM tipo_despesa
  WHERE cod_empresa     = p_cod_empresa
    AND cod_tip_despesa = l_tipo_despesa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_nom_tip_desp TO NULL
 END IF

 RETURN l_nom_tip_desp
 END FUNCTION


#-----------------------------------------------#
FUNCTION cdv2004_busca_historico_padrao(l_hist)
#-----------------------------------------------#

 DEFINE l_hist      LIKE cdv_tdesp_viag_781.hist_padrao_cap,
        l_historico LIKE hist_padrao_cap.historico

 WHENEVER ERROR CONTINUE
 SELECT historico
   INTO l_historico
   FROM hist_padrao_cap
  WHERE cod_hist  = l_hist
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    INITIALIZE l_historico TO NULL
 END IF

 RETURN l_historico
 END FUNCTION

#--------------------------------------------#
 FUNCTION cdv2004_busca_grupo_despesa(l_grupo)
#--------------------------------------------#
 DEFINE l_grupo     SMALLINT,
        l_den_grupo CHAR(25)

 CASE l_grupo
    WHEN 1
       LET l_den_grupo = 'DESPESA URBANA'
    WHEN 2
       LET l_den_grupo = 'DESPESA QUILOMETRAGEM'
    WHEN 3
       LET l_den_grupo = 'DESPESA KM SEMANAL'
    WHEN 4
       LET l_den_grupo = 'DESPESA TERCEIROS'
    WHEN 5
       LET l_den_grupo = 'APONTAMENTO HORAS'
    WHEN 6
       LET l_den_grupo = 'CERTIFICADO'
    WHEN 7
       LET l_den_grupo = 'KM ASLE'
    WHEN 8
       LET l_den_grupo = 'HORAS ASLE'
    WHEN 9
       LET l_den_grupo = 'HORAS ADM ASLE'
    WHEN 10
       LET l_den_grupo = 'AUDITORIA'

 END CASE

 RETURN l_den_grupo

 END FUNCTION

#-------------------------------#
 FUNCTION cdv2004_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2004.4gl $|$Revision: 9 $|$Date: 23/12/11 12:23 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION