###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: CONTROLE DE VIAGENS                                   #
# PROGRAMA: CDV2014                                               #
# OBJETIVO: MANUTENCAO DA TABELA CDV_ATIV_781                     #
# AUTOR...: FABIANO PEDRO ESPINDOLA                               #
# DATA....: 22.01.2007                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         g_last_row          SMALLINT,
         p_ies_impressao     CHAR(01),
         g_ies_ambiente      CHAR(001),
         p_nom_arquivo       CHAR(100),
         g_ies_cons          SMALLINT,
         g_comando           CHAR(80),
         g_comand_cdv_rel    CHAR(150),
         g_comand_cdv        CHAR(100),
         g_ies_ordem         CHAR(01)

DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

  DEFINE sql_stmt           CHAR(500),
         sql_stmt2          CHAR(500),
         where_clause       CHAR(500),
         m_den_empresa      LIKE empresa.den_empresa,
         m_caminho          CHAR(150)

  DEFINE m_houve_erro       SMALLINT,
         m_ies_cons         SMALLINT,
         mr_cdv_ativ_781    RECORD LIKE cdv_ativ_781.*,
         mr_cdv_ativ_781r   RECORD LIKE cdv_ativ_781.*,
         m_informou         SMALLINT,
         m_val_total LIKE cdv_despesa_km_781.val_km

  DEFINE mr_apont_km              RECORD
                                  cod_empresa     LIKE empresa.cod_empresa,
                                  den_empresa     LIKE empresa.den_empresa,
                                  num_matricula   LIKE cdv_info_viajante.matricula,
                                  nom_viajante    LIKE usuarios.nom_funcionario,
                                  periodo_ini     DATE,
                                  periodo_fim     DATE,
                                  dat_limite      DATE
                                  END RECORD

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "CDV2014-05.10.01p" #Favor nao alterar esta linha (SUPORTE)
INITIALIZE p_status TO NULL

  WHENEVER ERROR CONTINUE
     CALL log1400_isolation()
     SET LOCK MODE TO WAIT  120
  WHENEVER ERROR STOP
  DEFER INTERRUPT

  CALL log140_procura_caminho("cdv2014.iem") RETURNING g_comand_cdv

  OPTIONS
    FIELD ORDER UNCONSTRAINED,
    HELP    FILE g_comand_cdv,
     INSERT   KEY control-i,
    DELETE   KEY control-e,
    NEXT     KEY control-f,
    PREVIOUS KEY control-b
  CALL log001_acessa_usuario("CDV","LOGERP")
    RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0
    THEN CALL cdv2014_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION cdv2014_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  CALL log130_procura_caminho("cdv2014") RETURNING g_comand_cdv

  OPEN WINDOW w_cdv2014 AT 2,2 WITH FORM g_comand_cdv
       ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

  MENU "OPÇÃO"
    COMMAND "Informar" "Informa os parametros para extração do relatório."
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      LET m_informou = FALSE
      IF log005_seguranca(p_user,"CDV","CDV2014","CO") THEN
         CALL cdv2014_input_relatorio_km()
      END IF

    COMMAND "Processar"     "Processa o relatório conforme parametros informados."
      HELP 002
      MESSAGE ""
      LET int_flag = 0
      IF m_informou = TRUE THEN
         IF log005_seguranca(p_user,"CDV","CDV2014","CO") THEN
            CALL cdv2014_select_relatorio_km()
         END IF
      ELSE
         CALL log0030_mensagem("Parâmetros não informados.","exclamation")
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR g_comando
      RUN g_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR g_comando
      LET int_flag = 0

    COMMAND "Fim"        "Retorna ao menu anterior."
      HELP 008
      MESSAGE  ""
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

 CLOSE WINDOW w_cdv2014

END FUNCTION

#-----------------------------#
 FUNCTION cdv2014_exibe_dados()
#-----------------------------#
  CLEAR FORM
  DISPLAY BY NAME mr_cdv_ativ_781.*

END FUNCTION

#----------------------#
 FUNCTION cdv2014_help()
#----------------------#

  CASE
     WHEN INFIELD(cod_empresa)        CALL SHOWHELP(100)
     WHEN INFIELD(num_matricula)      CALL SHOWHELP(101)
     WHEN INFIELD(periodo_ini)        CALL SHOWHELP(102)
     WHEN INFIELD(periodo_fim)        CALL SHOWHELP(103)
 END CASE

END FUNCTION


#-----------------------------------#
 FUNCTION cdv2014_input_relatorio_km()
#-----------------------------------#
 INITIALIZE mr_apont_km.* TO NULL

 INPUT BY NAME mr_apont_km.* WITHOUT DEFAULTS

    AFTER FIELD cod_empresa
       IF mr_apont_km.cod_empresa IS NOT NULL
       AND mr_apont_km.cod_empresa <> " " THEN
          IF NOT cdv2014_verifica_empresa() THEN
             CALL log0030_mensagem("Empresa não cadastrada.","exclamation")
             NEXT FIELD cod_empresa
          END IF
       ELSE
          DISPLAY '' TO cod_empresa
       END IF

    AFTER FIELD num_matricula
       IF mr_apont_km.num_matricula IS NOT NULL
       AND mr_apont_km.num_matricula <> " " THEN
          CALL cdv2014_valida_viajante(mr_apont_km.num_matricula)
               RETURNING p_status, mr_apont_km.nom_viajante

          IF p_status = FALSE THEN
             CALL log0030_mensagem("Matrícula não cadastrada.","exclamation")
             NEXT FIELD num_matricula
          END IF
          DISPLAY BY NAME mr_apont_km.nom_viajante
       ELSE
          DISPLAY '' TO num_matricula
       END IF

    #AFTER FIELD periodo_ini
       #IF mr_apont_km.periodo_ini IS NULL THEN
       #   CALL log0030_mensagem("Período inicial não informado.","exclamation")
       #   NEXT FIELD periodo_ini
       #END IF

    AFTER FIELD periodo_fim
       #IF mr_apont_km.periodo_fim IS NULL THEN
       #   CALL log0030_mensagem("Período final não informado.","exclamation")
       #   NEXT FIELD periodo_fim
       #END IF

       IF  mr_apont_km.periodo_fim IS NOT NULL
       AND mr_apont_km.periodo_ini IS NULL THEN
          CALL log0030_mensagem("Período inicial não informado.","exclamation")
          NEXT FIELD periodo_ini
       END IF

       IF  mr_apont_km.periodo_fim IS NULL
       AND mr_apont_km.periodo_ini IS NOT NULL THEN
          CALL log0030_mensagem("Período final não informado.","exclamation")
          NEXT FIELD periodo_ini
       END IF

       IF mr_apont_km.periodo_fim IS NOT NULL AND mr_apont_km.periodo_fim <> " " THEN
          IF mr_apont_km.periodo_ini IS NOT NULL AND mr_apont_km.periodo_ini <> " " THEN
             IF mr_apont_km.periodo_fim < mr_apont_km.periodo_ini THEN
                CALL log0030_mensagem("Período final deve ser maior que o período inicial.","exclamation")
                NEXT FIELD periodo_ini
             END IF
          END IF
       END IF

    AFTER FIELD dat_limite
       IF  mr_apont_km.dat_limite IS NOT NULL
       AND mr_apont_km.periodo_ini IS NOT NULL THEN
          CALL log0030_mensagem("Informe somente o período ou a data de limite.","exclamation")
          NEXT FIELD periodo_ini
       END IF

    AFTER INPUT
       IF NOT int_flag THEN


          IF  mr_apont_km.periodo_fim IS NOT NULL
          AND mr_apont_km.periodo_ini IS NULL THEN
             CALL log0030_mensagem("Período inicial não informado.","exclamation")
             NEXT FIELD periodo_ini
          END IF

          IF  mr_apont_km.periodo_fim IS NULL
          AND mr_apont_km.periodo_ini IS NOT NULL THEN
             CALL log0030_mensagem("Período final não informado.","exclamation")
             NEXT FIELD periodo_ini
          END IF

          #IF mr_apont_km.periodo_ini IS NULL THEN
          #   CALL log0030_mensagem("Período inicial não informado.","exclamation")
          #   NEXT FIELD periodo_ini
          #END IF
          #
          #IF mr_apont_km.periodo_fim IS NULL THEN
          #   CALL log0030_mensagem("Período final não informado.","exclamation")
          #   NEXT FIELD periodo_fim
          #END IF

          IF mr_apont_km.cod_empresa IS NOT NULL AND mr_apont_km.cod_empresa <> " " THEN
             IF NOT cdv2014_verifica_empresa() THEN
                CALL log0030_mensagem("Empresa não cadastrada.","exclamation")
                NEXT FIELD cod_empresa
             END IF
          END IF

          IF mr_apont_km.num_matricula IS NOT NULL AND mr_apont_km.num_matricula <> " " THEN
             CALL cdv2014_valida_viajante(mr_apont_km.num_matricula)
                  RETURNING p_status, mr_apont_km.nom_viajante

             IF p_status = FALSE THEN
                CALL log0030_mensagem("Matrícula não cadastrada.","exclamation")
                NEXT FIELD num_matricula
             END IF
             DISPLAY BY NAME mr_apont_km.nom_viajante
          END IF

          IF mr_apont_km.periodo_fim IS NOT NULL AND mr_apont_km.periodo_fim <> " " THEN
             IF mr_apont_km.periodo_ini IS NOT NULL AND mr_apont_km.periodo_ini <> " " THEN
                IF mr_apont_km.periodo_fim < mr_apont_km.periodo_ini THEN
                   CALL log0030_mensagem("Período final deve ser maior que o período inicial.","exclamation")
                   NEXT FIELD periodo_ini
                END IF
             END IF
          END IF

          IF  mr_apont_km.dat_limite IS NULL
          AND mr_apont_km.periodo_ini IS NULL THEN
             CALL log0030_mensagem("Devera ser informado o período ou a data limite.","exclamation")
             NEXT FIELD periodo_ini
          END IF

          IF  mr_apont_km.dat_limite IS NOT NULL
          AND mr_apont_km.periodo_ini IS NOT NULL THEN
             CALL log0030_mensagem("Informe somente o período ou a data de limite.","exclamation")
             NEXT FIELD periodo_ini
          END IF

       ELSE
           ERROR "Impressão cancelada."
           RETURN
       END IF

     ON KEY (control-w, f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CALL cdv2014_help()

     ON KEY (control-z, f4)
        CALL cdv2014_popup1()

 END INPUT

 LET m_informou = TRUE
END FUNCTION

#------------------------------------#
 FUNCTION cdv2014_select_relatorio_km()
#------------------------------------#
 DEFINE l_sql_stmt       CHAR(2000),
        l_msg            CHAR(100),
        l_tot_reg        SMALLINT

 DEFINE lr_relat         RECORD
                            viajante                LIKE cdv_acer_viag_781.viajante,
                            nom_viajante            LIKE usuarios.nom_funcionario,
                            apropr_desp_km          LIKE cdv_despesa_km_781.apropr_desp_km,
                            dat_rec_nf              LIKE ad_mestre.dat_rec_nf,
                            num_ap                  LIKE ap.num_ap,
                            dat_pgto                LIKE ap.dat_pgto,
                            viagem                  LIKE cdv_despesa_km_781.viagem,
                            controle                LIKE cdv_solic_viag_781.controle,
                            dat_apont_hor           LIKE cdv_apont_hor_781.dat_apont_hor,
                            ativ_km                 LIKE cdv_despesa_km_781.ativ_km,
                            km_inicial              LIKE cdv_despesa_km_781.km_inicial,
                            km_final                LIKE cdv_despesa_km_781.km_final,
                            qtd_km                  LIKE cdv_despesa_km_781.qtd_km,
                            val_km                  LIKE cdv_despesa_km_781.val_km
                         END RECORD,
                         l_cod_empresa              LIKE empresa.cod_empresa,
                         l_seq                      SMALLINT

 IF log0280_saida_relat(17,35) IS NOT NULL THEN

    MESSAGE "Processando a extração do relatório . . . " ATTRIBUTE(REVERSE)

    WHENEVER ERROR CONTINUE
    SELECT den_reduz
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
    END IF

    IF g_ies_ambiente = "W" THEN
       IF p_ies_impressao = "S" THEN
          CALL log150_procura_caminho("LST") RETURNING g_comando
          LET g_comando = g_comando CLIPPED, "cdv2014.tmp"
          START REPORT cdv2014_relatorio_km TO g_comando
       ELSE
          START REPORT cdv2014_relatorio_km TO p_nom_arquivo
       END IF
    ELSE
        IF p_ies_impressao = "S" THEN
           START REPORT cdv2014_relatorio_km TO PIPE p_nom_arquivo
        ELSE
           START REPORT cdv2014_relatorio_km TO p_nom_arquivo
        END IF
    END IF

    INITIALIZE l_sql_stmt TO NULL

    LET l_sql_stmt = "SELECT f.viajante, a.apropr_desp_km, c.dat_rec_nf, a.viagem, e.controle, a.dat_despesa_km, ",
                     "       a.ativ_km, a.km_inicial, a.km_final, a.qtd_km, a.val_km, a.seq_despesa_km, ",
                     "       a.empresa ",
                     "  FROM cdv_despesa_km_781 a, cdv_tdesp_viag_781 b, ad_mestre c, ",
                     "       cdv_solic_viag_781 e, cdv_acer_viag_781 f "

    #IF  mr_apont_km.dat_limite IS NOT NULL
    #AND mr_apont_km.dat_limite <> " " THEN
    #   LET l_sql_stmt = l_sql_stmt CLIPPED,
    #                 ", ad_ap g, ap h "
    #END IF

    LET l_sql_stmt = l_sql_stmt CLIPPED,
                     " WHERE a.apropr_desp_km IS NOT NULL ",
                     "   AND a.empresa = c.cod_empresa ",
                     "   AND e.empresa = a.empresa ",
                     "   AND f.empresa = a.empresa ",
                     "   AND a.empresa = b.empresa",
                     "   AND e.viagem  = a.viagem ",
                     "   AND f.viagem  = a.viagem ",
                     "   AND a.tip_despesa_viagem = b.tip_despesa_viagem ",
                     "   AND a.ativ_km = b.ativ ",
                     "   AND b.grp_despesa_viagem = 3 ",
                     "   AND a.apropr_desp_km  = c.num_ad"

    IF  mr_apont_km.dat_limite IS NOT NULL
    AND mr_apont_km.dat_limite <> " " THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                     " AND c.dat_rec_nf <= '", mr_apont_km.dat_limite, "' ",
                     " AND (c.num_ad NOT IN (SELECT UNIQUE g.num_ad FROM ad_ap g ",
                     "                        WHERE g.cod_empresa = c.cod_empresa) ",
                     " OR   c.num_ad IN (SELECT UNIQUE h.num_ad FROM ad_ap h, ap i ",
                     "                           WHERE h.cod_empresa = c.cod_empresa ",
                     "                             AND i.cod_empresa = c.cod_empresa ",
                     "                             AND i.num_ap      = h.num_ap ",
                     "                             AND i.ies_versao_atual = 'S' ",
                     "                             AND i.dat_pgto IS NULL)) "
    END IF

    IF mr_apont_km.cod_empresa IS NOT NULL AND mr_apont_km.cod_empresa <> " " THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                     "   AND a.empresa = '", mr_apont_km.cod_empresa, "' "
    END IF

    IF mr_apont_km.num_matricula IS NOT NULL AND mr_apont_km.num_matricula <> " " THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                     "   AND f.viajante = ",mr_apont_km.num_matricula
    END IF

    IF mr_apont_km.periodo_ini IS NOT NULL AND mr_apont_km.periodo_ini <> " " THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                     "   AND c.dat_rec_nf >= '", mr_apont_km.periodo_ini, "' "
    END IF

    IF mr_apont_km.periodo_fim IS NOT NULL AND mr_apont_km.periodo_fim <> " " THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                     "   AND c.dat_rec_nf <= '", mr_apont_km.periodo_fim, "' "
    END IF

    LET l_sql_stmt = l_sql_stmt CLIPPED,
       " ORDER BY a.empresa, f.viajante, c.dat_rec_nf, a.seq_despesa_km "

    WHENEVER ERROR CONTINUE
     PREPARE var_relatorio_km FROM l_sql_stmt
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("PREPARE","VAR_RELATORIO_KM")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
     DECLARE cl_relatorio_km CURSOR FOR var_relatorio_km
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","CQ_RELATORIO_KM")
       RETURN
    END IF

    LET l_tot_reg   = FALSE
    LET m_val_total = 0

    WHENEVER ERROR CONTINUE
     FOREACH cl_relatorio_km INTO lr_relat.viajante,
                                  lr_relat.apropr_desp_km,
                                  lr_relat.dat_rec_nf,
                                  lr_relat.viagem,
                                  lr_relat.controle,
                                  lr_relat.dat_apont_hor,
                                  lr_relat.ativ_km,
                                  lr_relat.km_inicial,
                                  lr_relat.km_final,
                                  lr_relat.qtd_km,
                                  lr_relat.val_km,
                                  l_seq,
                                  l_cod_empresa
    WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("FOREACH","CL_RELATORIO_KM")
          RETURN
       END IF

       CALL cdv2014_valida_viajante(lr_relat.viajante)
            RETURNING p_status, lr_relat.nom_viajante

       INITIALIZE lr_relat.num_ap, lr_relat.dat_pgto TO NULL

       WHENEVER ERROR CONTINUE
         SELECT UNIQUE num_ap
           INTO lr_relat.num_ap
           FROM ad_ap
          WHERE cod_empresa  = l_cod_empresa #mr_apont_km.cod_empresa
            AND ad_ap.num_ad = lr_relat.apropr_desp_km
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("SELECT","AD_AP")
          RETURN
       END IF

       WHENEVER ERROR CONTINUE
         SELECT UNIQUE dat_pgto
           INTO lr_relat.dat_pgto
           FROM ap
          WHERE cod_empresa      = l_cod_empresa #mr_apont_km.cod_empresa
            AND num_ap           = lr_relat.num_ap
            AND ies_versao_atual = "S"
       WHENEVER ERROR STOP

       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("SELECT","AP")
          RETURN
       END IF

       OUTPUT TO REPORT cdv2014_relatorio_km(lr_relat.*, l_cod_empresa)

       LET l_tot_reg = TRUE

    END FOREACH

    FINISH REPORT cdv2014_relatorio_km

    FREE cl_relatorio_km

    IF g_ies_ambiente = "W" AND p_ies_impressao = "S"  THEN
       LET g_comando = "lpdos.bat ", g_comando CLIPPED, " ", p_nom_arquivo CLIPPED
       RUN g_comando
    END IF

    IF l_tot_reg THEN
       IF p_ies_impressao = "S" THEN
          CALL log0030_mensagem("Relatório impresso com sucesso.","info")
       ELSE
          LET l_msg = "Relatório gravado no arquivo " ,p_nom_arquivo CLIPPED,"."
          CALL log0030_mensagem(l_msg,"info")
       END IF
    ELSE
       CALL log0030_mensagem("Não existem dados para serem listados.","info")
    END IF
 END IF

 END FUNCTION

#----------------------------------------------------------#
 FUNCTION cdv2014_valida_viajante(l_viajante)
#----------------------------------------------------------#
  DEFINE l_viajante         LIKE cdv_acer_viag_781.viajante,
         l_nom_funcionario  CHAR(30),
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
     RETURN FALSE, ''
  END IF

  WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO l_nom_funcionario
    FROM fornecedor
   WHERE cod_fornecedor = l_cod_fornecedor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF
  CASE SQLCA.SQLCODE
     WHEN 0
        RETURN TRUE, l_nom_funcionario
     WHEN 100
        #CALL log0030_mensagem('Funcionário não cadastrado ou não é viajante.','exclamation')
        RETURN FALSE, ''
     OTHERWISE
        #CALL log003_err_sql('SELECT','cdv_fornecedor_fun')
        RETURN FALSE, ''
  END CASE

END FUNCTION

#----------------------------------#
 FUNCTION cdv2014_verifica_empresa()
#----------------------------------#
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


#---------------------------------------------------#
 REPORT cdv2014_relatorio_km(lr_relat, l_cod_empresa)
#---------------------------------------------------#
 DEFINE lr_relat          RECORD
                          viajante                LIKE cdv_acer_viag_781.viajante,
                          nom_viajante            LIKE usuarios.nom_funcionario,
                          apropr_desp_km          LIKE cdv_despesa_km_781.apropr_desp_km,
                          dat_rec_nf              LIKE ad_mestre.dat_rec_nf,
                          num_ap                  LIKE ap.num_ap,
                          dat_pgto                LIKE ap.dat_pgto,
                          viagem                  LIKE cdv_despesa_km_781.viagem,
                          controle                LIKE cdv_solic_viag_781.controle,
                          dat_apont_hor           LIKE cdv_apont_hor_781.dat_apont_hor,
                          ativ_km                 LIKE cdv_despesa_km_781.ativ_km,
                          km_inicial              LIKE cdv_despesa_km_781.km_inicial,
                          km_final                LIKE cdv_despesa_km_781.km_final,
                          qtd_km                  LIKE cdv_despesa_km_781.qtd_km,
                          val_km                  LIKE cdv_despesa_km_781.val_km
                          END RECORD,
         l_cod_empresa    LIKE empresa.cod_empresa

 DEFINE l_matricula_aprov LIKE cdv_info_viajante.matricula,
        l_data_aprov      LIKE cdv_aprov_viag_781.dat_aprovacao,
        l_hora_aprov      LIKE cdv_aprov_viag_781.hor_aprovacao,
        l_aprovacao       CHAR(200),
        l_preco_km_emp    LIKE cdv_par_ctr_viagem.preco_km_empresa

  OUTPUT LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
         PAGE LENGTH 66

{
                                         APONTAMENTO KM SEMANAL

                                    PERIODO - 04/11/2006 A 10/11/2006

                              MATRICULA: XXXXX       VIAJANTE: TATIANA MENEGUETI

  ================================================APONTAMENTOS=========================================
  AD   ENTRADA     AP  PAGAMENTO  VIAGEM CONTROLE DATA APONT ATIVIDADE KM INICIAL KM FINAL QTD.KM R$ KM
  -----------------------------------------------------------------------------------------------------
  5623 01/01/2006 5860 15/12/2006     10   214156 04/12/2006 ASLE          154000   154050     50  0,53
  5623 01/01/2006 5860 15/12/2006     10   214156 04/12/2006 ASLE          154000   154050     50  0,53

                                                                                    TOTAL:       121,90
}

  FORMAT

  PAGE HEADER
     PRINT log5211_retorna_configuracao(PAGENO,66,172) CLIPPED;
     PRINT COLUMN 001, m_den_empresa
     PRINT COLUMN 001, "CDV2014",
           COLUMN 163, "FL. ",PAGENO USING "####"

     PRINT COLUMN 131, " EXTRAIDO EM ", TODAY USING "dd/mm/yyyy",
                       " AS ", TIME, " HRS."
     PRINT COLUMN 149, "PELO USUARIO: ", UPSHIFT(p_user)

     PRINT COLUMN 053, "APONTAMENTO KM SEMANAL"
     PRINT COLUMN 047, "PERIODO: ", mr_apont_km.periodo_ini, " ATE ", mr_apont_km.periodo_fim

  BEFORE GROUP OF l_cod_empresa
     SKIP 1 LINE
     PRINT COLUMN 047, "EMPRESA  : ", l_cod_empresa, " - ", cdv2014_busca_den_empresa(l_cod_empresa)

  BEFORE GROUP OF lr_relat.viajante
     #SKIP TO TOP OF PAGE
     PRINT COLUMN 047, "MATRICULA: ", lr_relat.viajante USING "#########&", " - VIAJANTE: ", lr_relat.nom_viajante CLIPPED
     SKIP 1 LINE
     PRINT COLUMN 001, "================================================================ APONTAMENTOS ============================================================================================"
     PRINT COLUMN 001, " AD    ENTRADA      AP    PAGAMENTO VIAGEM  CONTROLE  DATA APONT  ATIVIDADE                     KM INICIAL  KM FINAL  QTD.KM   R$ KM   R$TOTAL  APROVACAO                 "
     PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
     LET m_val_total = 0

  ON EVERY ROW
     CALL cdv2014_busca_dados_aprovacao(l_cod_empresa, lr_relat.apropr_desp_km, lr_relat.viagem)
          RETURNING l_aprovacao

     LET l_preco_km_emp = cdv2014_busca_preco_km_emp(l_cod_empresa)

     PRINT COLUMN 001, lr_relat.apropr_desp_km  USING "#####&",
           COLUMN 008, lr_relat.dat_rec_nf      USING "dd/mm/yyyy",
           COLUMN 018, lr_relat.num_ap          USING "#####&",
           COLUMN 025, lr_relat.dat_pgto        USING "dd/mm/yyyy",
           COLUMN 036, lr_relat.viagem          USING "######&",
           COLUMN 045, lr_relat.controle        USING "#######&",
           COLUMN 055, lr_relat.dat_apont_hor   USING "dd/mm/yyyy",
           COLUMN 067, cdv2014_busca_ativ(lr_relat.ativ_km),
           COLUMN 097, lr_relat.km_inicial      USING "#########&",
           COLUMN 109, lr_relat.km_final        USING "#######&",
           COLUMN 119, lr_relat.qtd_km          USING "#####&",
           COLUMN 127, l_preco_km_emp           USING "##&.&&",
           COLUMN 135, lr_relat.val_km          USING "####&.&&",
           COLUMN 144, l_aprovacao[1,26]

     LET m_val_total = m_val_total + lr_relat.val_km

  AFTER GROUP OF lr_relat.viajante
     PRINT " "
     PRINT COLUMN 122, "TOTAL: ", m_val_total USING "###,###,##&.##"

  ON LAST ROW
     LET g_last_row = TRUE

  PAGE TRAILER
  	IF g_last_row = TRUE THEN
      PRINT "                                     ------------------------     ------------------------     ------------------------                "
      PRINT "                                          COLABORADOR                     GERENTE                     TESOURARIA                       "
      PRINT "                                                                                                                                       "
      PRINT "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  	ELSE
  	   PRINT " "
  	   PRINT " "
  	   PRINT " "
  	   PRINT " "
  	END IF

 END REPORT
 #FIM OS.470958

#------------------------------------------------#
 FUNCTION cdv2014_busca_den_empresa(l_cod_empresa)
#------------------------------------------------#
 DEFINE l_cod_empresa  LIKE empresa.cod_empresa,
        l_den_empresa  LIKE empresa.den_reduz

 WHENEVER ERROR CONTINUE
 SELECT den_reduz
   INTO l_den_empresa
   FROM empresa
  WHERE cod_empresa = l_cod_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_den_empresa TO NULL
 END IF

 RETURN l_den_empresa
 END FUNCTION

#-------------------------------------#
 FUNCTION cdv2014_busca_ativ(l_ativ_km)
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

#------------------------------------------------------------------------#
 FUNCTION cdv2014_busca_dados_aprovacao(l_cod_empresa, l_num_ad, l_viagem)
#------------------------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE empresa.cod_empresa,
        l_num_ad        LIKE ad_mestre.num_ad,
        l_viagem        LIKE cdv_solic_viag_781.viagem,
        l_data          LIKE cdv_aprov_viag_781.dat_aprovacao,
        l_hora          LIKE cdv_aprov_viag_781.hor_aprovacao,
        l_matricula     LIKE cdv_info_viajante.matricula,
        l_retorno       CHAR(200)

 WHENEVER ERROR CONTINUE
 SELECT UNIQUE dat_aprovacao, hor_aprovacao
   INTO l_data, l_hora
   FROM cdv_aprov_viag_781
  WHERE empresa = l_cod_empresa
    AND viagem  = l_viagem
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_data, l_hora TO NULL
 END IF

 WHENEVER ERROR CONTINUE
 SELECT cdv_info_viajante.matricula
   INTO l_matricula
   FROM cdv_info_viajante, cdv_aprov_viag_781
  WHERE cdv_info_viajante.empresa   = l_cod_empresa
    AND cdv_aprov_viag_781.empresa  = l_cod_empresa
    AND cdv_aprov_viag_781.viagem   = l_viagem
    AND cdv_info_viajante.usuario_logix = cdv_aprov_viag_781.usuario_aprovacao
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    INITIALIZE l_matricula TO NULL
 END IF

 LET l_retorno = l_matricula USING "##&&&&", " ",
                 l_data USING "dd/mm/yyyy", " ",
                 l_hora

 RETURN l_retorno
 END FUNCTION

#------------------------#
 FUNCTION cdv2014_popup1()
#------------------------#

 DEFINE l_cod_empresa  LIKE empresa.cod_empresa,
        l_matricula    LIKE cdv_info_viajante.matricula

 CASE
    WHEN infield(cod_empresa)
       LET l_cod_empresa = sup110_popup_empresa()
       CURRENT WINDOW IS w_cdv2014

       IF l_cod_empresa IS NOT NULL THEN
          LET mr_apont_km.cod_empresa = l_cod_empresa
          DISPLAY BY NAME mr_apont_km.cod_empresa
       END IF

    WHEN infield(num_matricula)
       LET l_matricula = cdv0033_popup_matricula_viaj(mr_apont_km.cod_empresa)
       CURRENT WINDOW IS w_cdv2014

       IF l_matricula IS NOT NULL THEN
          LET mr_apont_km.num_matricula = l_matricula
          DISPLAY BY NAME mr_apont_km.num_matricula
       END IF
 END CASE

 END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv2014_busca_preco_km_emp(l_cod_empresa)
#-------------------------------------------------#
 DEFINE l_cod_empresa  LIKE empresa.cod_empresa,
        l_preco        LIKE cdv_par_ctr_viagem.preco_km_empresa

 LET l_preco = 0

 WHENEVER ERROR CONTINUE
 SELECT preco_km_empresa
   INTO l_preco
   FROM cdv_par_ctr_viagem
  WHERE empresa = p_cod_empresa
 WHENEVER ERROR STOP

  IF SQLCA.SQLCODE <> 0 THEN
     LET l_preco = 0
  END IF

  IF l_preco IS NULL THEN
     LET l_preco = 0
  END IF

 RETURN l_preco
 END FUNCTION

#-------------------------------#
 FUNCTION cdv2014_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/programas/cdv2014.4gl $|$Revision: 3 $|$Date: 23/12/11 12:23 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION