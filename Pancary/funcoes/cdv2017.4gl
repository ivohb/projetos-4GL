###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGENS                       #
# PROGRAMA: CDV2017                                               #
# OBJETIVO: POPUP DE ALERTA DE VIAGEM PENDENTE DE ACERTO/APROVAÇÃO#
#           ESPECIFICO CLIENTE 1125 - PAMCARY                     #
# AUTOR...: MAJARA PAULA SCHNEIDER DE SOUZA                       #
# DATA....: 16/09/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS

  DEFINE p_cod_empresa         LIKE empresa.cod_empresa,
         p_user                LIKE usuario.nom_usuario,
         p_status              SMALLINT

  DEFINE g_ies_ambiente        CHAR(1),
         g_ies_grafico         SMALLINT

END GLOBALS

#--# MODULARES #--#
DEFINE ma_pendencias ARRAY[10000] OF RECORD
                              empresa              LIKE empresa.cod_empresa,
                              viagem               LIKE cdv_solic_viag_781.viagem,
                              acerto_aprovacao     CHAR(25)
                              END RECORD

DEFINE m_aprovante_viajante   CHAR(01) # A - aprovante, V - Viajante, T - Todos, N - Nenhum

#CONTROLE DO ARRAY
DEFINE m_ind                 SMALLINT,
       m_empresa             LIKE empresa.cod_empresa,
       m_login               LIKE usuarios.cod_usuario

#--# END MODULARES #--#

MAIN
   CALL LOG_AppSetEnv(arg_val(1), arg_val(2))

   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 60
   DEFER INTERRUPT
   WHENEVER ERROR STOP

   CALL log001_acessa_usuario("CDV","LOGERP;LOGLQ2")
       RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      LET m_empresa = ARG_VAL(2)
      LET m_login = ARG_VAL(1)
      CALL cdv2017_mensagem_cdv_login(m_login,m_empresa)
   END IF
END MAIN


#------------------------------------------------------#
 FUNCTION cdv2017_mensagem_cdv_login(l_login, l_empresa)
#------------------------------------------------------#
 DEFINE l_login      LIKE usuarios.cod_usuario,
        l_empresa    LIKE empresa.cod_empresa


 LET p_cod_empresa = l_empresa

  IF cdv2017_eh_aprovante_viajante(l_login) THEN
     IF cdv2017_existe_pend_viagem(l_login)THEN
        CALL cdv2017_exibe_popup()
     END IF
  END IF

 RETURN
 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv2017_eh_aprovante_viajante(l_login)
#----------------------------------------------#
 DEFINE l_login           LIKE usuarios.cod_usuario

 LET m_aprovante_viajante = 'N' #variável que diz se login é de aprovante ou viajante

 LET m_ind = 1

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM usu_nivel_aut_cap
     WHERE cod_usuario = l_login
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    LET m_aprovante_viajante = 'A'
 END IF

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM cdv_info_viajante
     WHERE usuario_logix = l_login
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    IF m_aprovante_viajante = 'A' THEN
       LET m_aprovante_viajante = 'T'
    END IF
    IF m_aprovante_viajante = 'N' THEN
       LET m_aprovante_viajante = 'V'
    END IF
 END IF

 IF m_aprovante_viajante = 'N' THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2017_existe_pend_viagem(l_login)
#-------------------------------------------#
 DEFINE l_login            LIKE usuarios.cod_usuario,
        l_existe_pendencia  SMALLINT

 LET l_existe_pendencia = FALSE

 #--#CASO SEJA APROVANTE#--#
 IF m_aprovante_viajante = 'A' OR m_aprovante_viajante = 'T'  THEN
    IF cdv2017_existe_param_mensag_aprov(l_login) THEN
       IF cdv2017_existe_pend_aprov(l_login) THEN
          LET  l_existe_pendencia = TRUE
       END IF
    END IF
 END IF

 #--#CASO SEJA VIAJANTE#--#
 IF m_aprovante_viajante = 'V' OR m_aprovante_viajante = 'T'  THEN
    IF cdv2017_existe_param_mensag_viaj(l_login) THEN
       IF cdv2017_existe_pend_acerto(l_login) THEN
          LET l_existe_pendencia = TRUE
       END IF
    END IF
 END IF
 RETURN l_existe_pendencia
 END FUNCTION

#------------------------------------------#
 FUNCTION cdv2017_existe_pend_aprov(l_login)
#------------------------------------------#
 DEFINE l_login                   LIKE usuarios.cod_usuario,
        l_num_ad                  LIKE ad_mestre.num_ad,
        l_empresa                 LIKE empresa.cod_empresa,
        l_eh_ad_gerada_cdv        SMALLINT,
        l_viagem                  LIKE ad_mestre.num_nf,
        l_retorno                 SMALLINT

 LET l_retorno = FALSE

 #BUSCA AS AD'S BLOQUEADAS
 WHENEVER ERROR CONTINUE
 DECLARE cq_ad_mestre CURSOR WITH HOLD FOR
 SELECT num_ad, cod_empresa
   FROM ad_mestre
  WHERE ad_mestre.ies_sup_cap = 'Q'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('DECLARE','cq_ad_mestre')
 END IF


 WHENEVER ERROR CONTINUE
 FOREACH cq_ad_mestre INTO l_num_ad, l_empresa
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FOREACH','cq_ad_mestre')
       LET l_retorno = FALSE
       EXIT FOREACH
    END IF


    #VERIFICA SE ESTÁ NAS TABELAS DO CDV
    CALL cdv2017_ad_gerada_cdv(l_num_ad) RETURNING l_eh_ad_gerada_cdv, l_viagem
    IF NOT l_eh_ad_gerada_cdv THEN

       CONTINUE FOREACH
    END IF

    #CASO A AP EXISTA EM UMA DAS TABELASDO CDV,
    #VERIFICA SE EXISTE PENDÊNCIA DE APROVAÇÃO POR PARTE DO USUÁRIO LOGADO
    IF NOT cdv2017_existe_pend_aprov_usuar(l_login, l_num_ad, l_empresa) THEN
       CONTINUE FOREACH
    END IF

    #CASO ATENDA AMBAS AS CONDIÇÕES ACIMA, INLCUI A VIAGEM NO ARRAY EXIBIDO NA POPUP
    LET ma_pendencias[m_ind].empresa            = l_empresa
    LET ma_pendencias[m_ind].viagem             = l_viagem
    LET ma_pendencias[m_ind].acerto_aprovacao   = "APROVAÇÃO"
    WHENEVER ERROR STOP

    LET m_ind = m_ind+1

    LET l_retorno = TRUE

 END FOREACH
 FREE cq_ad_mestre
 WHENEVER ERROR STOP

 RETURN l_retorno

 END FUNCTION

#----------------------------------------#
 FUNCTION cdv2017_ad_gerada_cdv(l_num_ad)
#----------------------------------------#
 DEFINE l_num_ad   LIKE ad_mestre.num_ad,
        l_viagem   LIKE cdv_solic_adto_781.viagem

 LET l_viagem = 1
 WHENEVER ERROR CONTINUE
 SELECT viagem
  INTO l_viagem
  FROM cdv_despesa_km_781
 WHERE apropr_desp_km = l_num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    RETURN TRUE , l_viagem
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem
  INTO l_viagem
  FROM cdv_solic_adto_781
 WHERE num_ad_adto_viagem = l_num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    RETURN TRUE, l_viagem
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem
  INTO l_viagem
  FROM cdv_acer_viag_781
 WHERE ad_acerto_conta = l_num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    RETURN TRUE, l_viagem
 END IF

 WHENEVER ERROR CONTINUE
 SELECT viagem
  INTO l_viagem
  FROM cdv_desp_terc_781
 WHERE ad_terceiro = l_num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode=-284 THEN
    RETURN TRUE, l_viagem
 END IF

 RETURN FALSE, l_viagem

 END FUNCTION

#---------------------------------------------------#
 FUNCTION cdv2017_existe_pend_aprov_usuar(l_login ,
                                          l_num_ad,
                                          l_empresa)
#---------------------------------------------------#
 DEFINE l_login                 LIKE usuarios.cod_usuario,
        l_num_ad                LIKE ad_mestre.num_ad,
        l_empresa               LIKE empresa.cod_empresa

 DEFINE l_retorno               SMALLINT,
        lr_aprov_necessaria     RECORD LIKE aprov_necessaria.*,
        l_ies_tip_autor         LIKE nivel_autor_cap.ies_tip_autor,
        l_cont                  SMALLINT,
        l_entrou                SMALLINT,
        sql_stmt2               CHAR(500)

 LET l_entrou = FALSE

 DECLARE cq_aprov_necess1 CURSOR FOR
  SELECT *
    FROM aprov_necessaria
   WHERE cod_empresa = l_empresa
     AND num_ad      = l_num_ad

 FOREACH cq_aprov_necess1 INTO lr_aprov_necessaria.*

    DECLARE cq_tip_autor CURSOR FOR
     SELECT ies_tip_autor
       FROM usu_nivel_aut_cap
      WHERE cod_empresa      = l_empresa
        AND cod_emp_usuario  IS NOT NULL
        AND cod_usuario      IS NOT NULL
        AND cod_uni_funcio   IS NOT NULL
        AND ies_versao_atual = "S"
        AND num_versao       IS NOT NULL
        AND ies_tip_autor    IS NOT NULL
        AND ies_ativo        = "S"
        AND cod_nivel_autor = lr_aprov_necessaria.cod_nivel_autor
    FOREACH cq_tip_autor INTO l_ies_tip_autor
       LET l_cont = 0
       LET sql_stmt2 = " SELECT COUNT(*) ",
                       " FROM usu_nivel_aut_cap ",
                       " WHERE cod_empresa   =  """,lr_aprov_necessaria.cod_empresa,""" ",
                       " AND cod_nivel_autor =  """,lr_aprov_necessaria.cod_nivel_autor,""" "


       IF l_ies_tip_autor = "H" THEN
          LET sql_stmt2 = sql_stmt2 CLIPPED ,
          " AND cod_uni_funcio  =  """,lr_aprov_necessaria.cod_uni_funcio,""" "
       END IF
       IF l_login IS NOT NULL THEN
         LET sql_stmt2 = sql_stmt2 CLIPPED ,
              " AND cod_usuario        = """,l_login,""" "
       END IF

       PREPARE var_query2 FROM sql_stmt2
       DECLARE cq_ap2 CURSOR FOR var_query2


       FOREACH cq_ap2 INTO l_cont
          IF l_cont > 0 THEN
            LET l_entrou = TRUE
          END IF
       END FOREACH
    END FOREACH
 END FOREACH

 IF l_entrou = TRUE   THEN
   RETURN TRUE
 ELSE
   SELECT apropr_desp
     FROM cap_ad_susp_aprov
    WHERE apropr_desp = l_num_ad
      AND empresa     = l_empresa

   IF SQLCA.SQLCODE = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
 END IF

 END FUNCTION

#-------------------------------------------#
 FUNCTION cdv2017_existe_pend_acerto(l_login)
#-------------------------------------------#
 DEFINE l_login           LIKE usuarios.cod_usuario,
        l_matricula       LIKE cdv_info_viajante.matricula,
        lr_viagem_pend    RECORD
                          empresa              LIKE empresa.cod_empresa,
                          viagem               LIKE cdv_solic_viag_781.viagem,
                          acerto_aprovacao     CHAR(25)
                          END RECORD,
        l_retorno         SMALLINT

 LET l_retorno = FALSE

 #seleciona a matricula do viajante
 WHENEVER ERROR CONTINUE
    DECLARE cq_matriculas CURSOR FOR
       SELECT UNIQUE(matricula)
       FROM cdv_info_viajante
       WHERE usuario_logix = l_login
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0  AND sqlca.sqlcode <> -284 THEN
    CALL log003_err_sql("DELARE","cq_matriculas")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_matriculas INTO l_matricula
    #seleciona as viagens com data de retorno < data atual
    WHENEVER ERROR CONTINUE
       DECLARE cq_viagens CURSOR FOR
         SELECT empresa, viagem, 'ACERTO' AS acerto_aprovacao
          FROM cdv_solic_viag_781
          WHERE viajante = l_matricula
           AND dat_hor_retorno < TODAY
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DELARE","cq_viagens")
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
    FOREACH cq_viagens INTO lr_viagem_pend.*
       IF cdv2017_existe_adtos_aberto(lr_viagem_pend.viagem, lr_viagem_pend.empresa) THEN
          CONTINUE FOREACH
       END IF
       IF cdv2017_existe_acerto_finalizado(lr_viagem_pend.viagem, lr_viagem_pend.empresa) THEN
          CONTINUE FOREACH
       END IF
       LET l_retorno = TRUE
       LET ma_pendencias[m_ind] = lr_viagem_pend

       LET m_ind = m_ind+1

    END FOREACH
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","cq_viagens")
    END IF
 END FOREACH
 WHENEVER ERROR STOP
 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","cq_viagens")
 END IF

 CALL SET_COUNT(m_ind)

 RETURN l_retorno

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION cdv2017_existe_adtos_aberto(l_viagem, l_empresa)
#---------------------------------------------------------#
 DEFINE l_viagem                LIKE cdv_acer_viag_781.viagem,
        l_empresa               LIKE empresa.cod_empresa,
        l_num_ad_adto_viagem    LIKE ad_mestre.num_ad,
        l_num_ad                LIKE ad_mestre.num_ad,
        m_num_ap                LIKE ap.num_ap,
        m_dat_pgto              LIKE ap.dat_pgto,
        l_retorno               SMALLINT,
        l_status                SMALLINT,
        l_val_liq_ap            LIKE ap.val_nom_ap,
        l_qtd_aps               SMALLINT

 LET l_retorno = FALSE
 #SELECIONA ADIANTAMANTOS DA VIAGEM
 WHENEVER ERROR CONTINUE
 DECLARE cq_adtos_aberto CURSOR FOR
  SELECT num_ad_adto_viagem
    FROM cdv_solic_adto_781
   WHERE empresa = l_empresa
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
       LET l_retorno = FALSE
       EXIT FOREACH
    END IF

    # CASO O FOREACH EM cq_ad_ap JÁ TENHA ENCONTRADO UM ADIANTAMENTO EM ABERTO NO LOOP ANTERIOR
    IF l_retorno = TRUE THEN
       EXIT FOREACH
    END IF

    IF l_num_ad_adto_viagem IS NULL THEN
       LET l_retorno = TRUE
       EXIT FOREACH
    END IF

    # VERIFICA SE EXISTE AP'S PARA AS ADS DE ADIANTAMENTO
    WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_qtd_aps
       FROM ad_ap
      WHERE cod_empresa = l_empresa
        AND num_ad      = l_num_ad_adto_viagem
    WHENEVER ERROR CONTINUE
    IF SQLCA.SQLCODE <> 0 THEN
       LET l_retorno = FALSE
       EXIT FOREACH
    END IF

    #CASO NÃO HAJA AP'S É PORQUE O ADIANTAMENTO NÃO FOI PAGO
    IF l_qtd_aps = 0 OR l_qtd_aps IS NULL THEN
       LET l_retorno = TRUE
       EXIT FOREACH
    END IF

    #SELECIONA AS APS
    WHENEVER ERROR CONTINUE
    DECLARE cq_ad_ap CURSOR FOR
     SELECT num_ap
       FROM ad_ap
      WHERE cod_empresa = l_empresa
        AND num_ad      = l_num_ad_adto_viagem
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","CQ_AD_AP")
       LET l_retorno = FALSE
    END IF

    WHENEVER ERROR CONTINUE
    FOREACH cq_ad_ap INTO m_num_ap
       #VERIFICA SE EXISTE DATA DE PAGAMENTO
       WHENEVER ERROR CONTINUE
        SELECT dat_pgto
          INTO m_dat_pgto
          FROM ap
         WHERE cod_empresa = l_empresa
           AND num_ap      = m_num_ap
           AND ies_versao_atual = "S"
       WHENEVER ERROR CONTINUE

       IF SQLCA.SQLCODE <> 0 THEN
          LET l_retorno = FALSE
          EXIT FOREACH
       END IF

       #CASO A DATA DE PAGAMENTO SEJA NULA É PORQUE NÃO FOI PAGO
       IF m_dat_pgto IS NULL THEN
          CALL cdv2000_calc_val_liquido_ap(l_empresa, m_num_ap, "S", 0)
             RETURNING l_status, l_val_liq_ap

          #CASO A AP TENHA UM VALOR LIQUIDO <> 0  > A AP NÃO FOI PAGA (ADIANTAMENTO ESTÁ EM ABERTO)
          IF l_val_liq_ap <> 0 THEN
             LET l_retorno = TRUE
             EXIT FOREACH
          ELSE
             LET l_retorno = FALSE
          END IF
       ELSE
          LET l_retorno = FALSE
       END IF

    END FOREACH
    WHENEVER ERROR STOP
    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("FOREACH","CQ_AD_AP")
       LET l_retorno = FALSE
    END IF

    FREE cq_ad_ap

 END FOREACH
 FREE cq_adtos_aberto

 RETURN l_retorno
 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION cdv2017_existe_acerto_finalizado(l_viagem, l_empresa)
#-------------------------------------------------------------#
 DEFINE l_viagem       LIKE cdv_acer_viag_781.viagem,
        l_empresa      LIKE empresa.cod_empresa

 WHENEVER ERROR CONTINUE
    SELECT 1
     FROM cdv_acer_viag_781
     WHERE empresa = l_empresa
     AND viagem = l_viagem
     AND ad_acerto_conta IS NOT NULL
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF
 END FUNCTION



#-----------------------------#
 FUNCTION cdv2017_exibe_popup()
#-----------------------------#
 DEFINE l_caminho          CHAR(80)

 CALL log130_procura_caminho("cdv2017") RETURNING l_caminho

 OPEN WINDOW w_cdv2017 AT 2,2 WITH FORM l_caminho
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 CALL cdv2017_exibe_dados()

 MENU "OPCAO"
    COMMAND "Fim"        "Retorna ao Menu Anterior"
    HELP 008
    EXIT MENU

 END MENU
 CLOSE WINDOW w_cdv2017

 END FUNCTION

#------------------------------#
 FUNCTION cdv2017_exibe_dados()
#------------------------------#
 DEFINE l_ind  INTEGER

 CLEAR FORM

 IF m_ind IS NOT NULL THEN
    CALL SET_COUNT(m_ind)
    IF m_ind > 15 THEN
       DISPLAY ARRAY ma_pendencias TO sr_pendencias.*
    ELSE
       FOR l_ind = 1 TO m_ind
          DISPLAY ma_pendencias[l_ind].* TO sr_pendencias[l_ind].*
       END FOR
    END IF
 END IF

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2017_existe_param_mensag_viaj(l_login)
#-------------------------------------------------#
 DEFINE l_login           LIKE usuarios.cod_usuario
 DEFINE l_matricula       LIKE cdv_info_viajante.matricula,
        l_parametro       LIKE cdv_par_viajante.parametro_booleano

 LET  l_matricula = cdv2017_busca_matricula(l_login)

 #CASO USUARIO NÃO ESTEJA CADASTRADO COMO VIAJANTE NO CDV
 IF l_matricula IS NULL THEN
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT parametro_booleano
   INTO l_parametro
   FROM cdv_par_viajante
  WHERE parametro = 'msg_viaj_pend_acerto'
   AND matricula = l_matricula
   AND empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <>100 THEN
    RETURN FALSE
 END IF

 #NÃO ENCONTROU O PARÂMETRO NA TABELA (POR PADRÃO É NÃO)
 IF sqlca.sqlcode = 100 THEN
    RETURN FALSE
 END IF

 #ENCONTROU O PARÂMETRO
 IF l_parametro = 'S' THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv2017_existe_param_mensag_aprov(l_login)
#--------------------------------------------------#
 DEFINE l_login           LIKE usuarios.cod_usuario
 DEFINE l_matricula       LIKE cdv_info_viajante.matricula,
        l_parametro       LIKE cdv_par_viajante.parametro_booleano

 LET  l_matricula = cdv2017_busca_matricula(l_login)

 #CASO USUARIO NÃO ESTEJA CADASTRADO COMO VIAJANTE NO CDV
 IF l_matricula IS NULL THEN
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 SELECT parametro_booleano
   INTO l_parametro
   FROM cdv_par_viajante
  WHERE parametro = 'msg_viaj_pend_aprov'
   AND matricula = l_matricula
   AND empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <>100 THEN
    RETURN FALSE
 END IF

 #NÃO ENCONTROU O PARÂMETRO NA TABELA (POR PADRÃO É NÃO)
 IF sqlca.sqlcode = 100 THEN
    RETURN FALSE
 END IF

 #ENCONTROU O PARÂMETRO
 IF l_parametro = 'S' THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF


 END FUNCTION

#-----------------------------------------#
 FUNCTION cdv2017_busca_matricula(l_login)
#-----------------------------------------#
 DEFINE l_login           LIKE usuarios.cod_usuario
 DEFINE l_matricula       LIKE cdv_info_viajante.matricula

 INITIALIZE l_matricula TO NULL

 WHENEVER ERROR CONTINUE
 SELECT matricula
   INTO l_matricula
   FROM cdv_info_viajante
  WHERE usuario_logix = l_login
   AND empresa = p_cod_empresa
 WHENEVER ERROR STOP
 RETURN l_matricula
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2017_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv2017.4gl $|$Revision: 12 $|$Date: 23/12/11 12:22 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION