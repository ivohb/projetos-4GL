###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# SISTEMA.: CONTROLE DE DESPESAS DE VIAGEM                          #
# PROGRAMA: CDV0804                                                 #
# OBJETIVO: FUNCAO RESPONSAVEL PELA GERACAO DA AEN                  #
# AUTOR...: ANA PAULA CASAS DE ALMEIDA                              #
# DATA....: 27/10/2005.                                             #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa

  DEFINE t_aen_309_4           ARRAY[200] OF RECORD
           val_aen              LIKE ad_aen_4.val_aen,
           cod_lin_prod         LIKE ad_aen_4.cod_lin_prod,
           cod_lin_recei        LIKE ad_aen_4.cod_lin_recei,
           cod_seg_merc         LIKE ad_aen_4.cod_seg_merc,
           cod_cla_uso          LIKE ad_aen_4.cod_cla_uso
  END RECORD

END GLOBALS

# MODULARES
  DEFINE ma_ad_aen_4    ARRAY[500] OF RECORD
                           val_aen           LIKE ad_aen_4.val_aen,
                           cod_lin_prod      LIKE ad_aen_4.cod_lin_prod,
                           cod_lin_recei     LIKE ad_aen_4.cod_lin_recei,
                           cod_seg_merc      LIKE ad_aen_4.cod_seg_merc,
                           cod_cla_uso       LIKE ad_aen_4.cod_cla_uso
                        END RECORD

  DEFINE ma_lanc_cont   ARRAY[500] OF RECORD
                           ies_tipo_lanc     LIKE lanc_cont_cap.ies_tipo_lanc,
                           num_conta_cont    LIKE lanc_cont_cap.num_conta_cont,
                           val_lanc          LIKE lanc_cont_cap.val_lanc,
                           tex_hist_lanc     LIKE lanc_cont_cap.tex_hist_lanc,
                           cod_tip_desp_val  LIKE lanc_cont_cap.cod_tip_desp_val,
                           ies_desp_val      LIKE lanc_cont_cap.ies_desp_val,
                           num_seq           LIKE lanc_cont_cap.num_seq,
                           ies_cnd_pgto      LIKE lanc_cont_cap.ies_cnd_pgto
                        END RECORD

  DEFINE ma_ad_aen_c_4  ARRAY[500] OF RECORD
                           cod_empresa       LIKE ad_aen_conta_4.cod_empresa,
                           num_ad            LIKE ad_aen_conta_4.num_ad,
                           num_seq           LIKE ad_aen_conta_4.num_seq,
                           num_seq_lanc      LIKE ad_aen_conta_4.num_seq_lanc,
                           ies_tipo_lanc     LIKE ad_aen_conta_4.ies_tipo_lanc,
                           num_conta_cont    LIKE ad_aen_conta_4.num_conta_cont,
                           ies_fornec_trans  LIKE ad_aen_conta_4.ies_fornec_trans,
                           cod_lin_prod      LIKE ad_aen_conta_4.cod_lin_prod,
                           cod_lin_recei     LIKE ad_aen_conta_4.cod_lin_recei,
                           cod_seg_merc      LIKE ad_aen_conta_4.cod_seg_merc,
                           cod_cla_uso       LIKE ad_aen_conta_4.cod_cla_uso,
                           val_aen           LIKE ad_aen_conta_4.val_aen
                        END RECORD

 DEFINE m_aen_normal_espec   LIKE par_cap_pad.par_ies,
        m_aen_2_4            LIKE par_cap_pad.par_ies

# END MODULARES

#--------------------------------------#
 FUNCTION cdv0804_geracao_aen(l_num_ad)
#--------------------------------------#
 DEFINE l_num_ad         LIKE ad_mestre.num_ad

 CALL cdv0804_cria_temp()

 INITIALIZE ma_ad_aen_4, ma_lanc_cont, ma_ad_aen_c_4 TO NULL

 CALL cdv0804_busca_parametros()

 IF m_aen_normal_espec = "E" AND m_aen_2_4 = "4" THEN
    IF NOT cdv0804_gera_forma_especial(l_num_ad) THEN
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION cdv0804_busca_parametros()
#------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT par_ies
    INTO m_aen_normal_espec
    FROM par_cap_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_area_linha_neg"
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 OR m_aen_normal_espec IS NULL THEN
    CALL log0030_mensagem("Parâmetro utiliza AEN no CAP não cadastrado.","exclamation")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT par_ies
    INTO m_aen_2_4
    FROM par_cap_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_aen_2_4"
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 OR m_aen_2_4 IS NULL THEN
    CALL log0030_mensagem("Parâmetro utiliza AEN cosm 2 ou 4 níveis não cadastrado.","exclamation")
    RETURN FALSE
 END IF

 END FUNCTION

#----------------------------------------------#
 FUNCTION cdv0804_gera_forma_especial(l_num_ad)
#----------------------------------------------#
 DEFINE l_conta_transit        LIKE ad_aen_conta_4.num_conta_cont,
        l_val_tot_nf           LIKE ad_mestre.val_tot_nf,
        lr_ad_aen_4            RECORD LIKE ad_aen_4.*,
        lr_ad_aen_c_4          RECORD LIKE ad_aen_conta_4.*,
        l_soma_prop            DECIMAL(15,2),
        l_difer                DECIMAL(15,2),
        l_proporcao            DECIMAL(15,2),
        l_cont, l_ind          SMALLINT,
        l_c_aen                SMALLINT,
        l_guarda_ult_lanc      SMALLINT,
        l_num_seq_cred         INTEGER,
        l_num_seq_deb          INTEGER,
        l_achou                SMALLINT,
        l_percent              DECIMAL(18,15),
        l_val_aen              DECIMAL(15,2),
        l_valor_aen            DECIMAL(15,2),
        l_num_ad               LIKE ad_mestre.num_ad,
        l_cod_lin_prod         LIKE ad_aen_conta_4.cod_lin_prod ,
        l_cod_lin_recei        LIKE ad_aen_conta_4.cod_lin_recei,
        l_cod_seg_merc         LIKE ad_aen_conta_4.cod_seg_merc ,
        l_cod_cla_uso          LIKE ad_aen_conta_4.cod_cla_uso

 LET l_achou  = FALSE
 LET int_flag = FALSE
 LET l_cont   = 1
 LET l_ind    = 1
 LET l_c_aen  = 0
 LET l_num_seq_cred = 0
 LET l_num_seq_deb  = 0
 LET l_guarda_ult_lanc = 1

 INITIALIZE lr_ad_aen_4.*, lr_ad_aen_c_4.* TO NULL

 CALL cdv0804_carrega_arrays(l_num_ad)

 IF NOT cdv0804_verifica_aen() THEN
    RETURN FALSE
 END IF

 CALL cdv0804_busca_conta_transitoria(l_num_ad) RETURNING l_conta_transit

 IF l_conta_transit IS NULL OR l_conta_transit = " " THEN
    CALL log0030_mensagem("Não existem lançamentos contábeis para esta AD.","exclamation")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT val_tot_nf
    INTO l_val_tot_nf
    FROM ad_mestre
   WHERE cod_empresa = p_cod_empresa
     AND num_ad      = l_num_ad
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  DECLARE cl_ad_aen_4 CURSOR FOR
   SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso, SUM(val_aen)
     FROM ad_aen_4
    WHERE cod_empresa = p_cod_empresa
      AND num_ad      = l_num_ad
    GROUP BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso
    ORDER BY 5
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND SQLCA.SQLCODE <> NOTFOUND THEN
    CALL log003_err_sql("SELECT","AD_AEN_4")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cl_ad_aen_4 INTO l_cod_lin_prod ,
                           l_cod_lin_recei,
                           l_cod_seg_merc ,
                           l_cod_cla_uso  ,
                           l_val_aen
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("FOREACH","CL_AD_AEN_4")
    RETURN FALSE
 END IF

    LET l_percent = (l_val_aen * 100) / l_val_tot_nf
    LET l_cont = 1

    WHENEVER ERROR CONTINUE
     DECLARE cl_lanc_cont CURSOR FOR
      SELECT ies_tipo_lanc,
             num_conta_cont,
             tex_hist_lanc,
             cod_tip_desp_val,
             ies_desp_val,
             num_seq,
             ies_cnd_pgto,
             SUM(val_lanc)
        FROM lanc_cont_cap
       WHERE cod_empresa = p_cod_empresa
         AND num_ad_ap   = l_num_ad
         AND ies_ad_ap   = 1
       GROUP BY ies_tipo_lanc, num_conta_cont, tex_hist_lanc, cod_tip_desp_val,
                ies_desp_val, num_seq, ies_cnd_pgto
       ORDER BY ies_tipo_lanc DESC, 8
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","CL_LANC_CONT")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
     FOREACH cl_lanc_cont INTO ma_lanc_cont[l_cont].ies_tipo_lanc,
                               ma_lanc_cont[l_cont].num_conta_cont,
                               ma_lanc_cont[l_cont].tex_hist_lanc,
                               ma_lanc_cont[l_cont].cod_tip_desp_val,
                               ma_lanc_cont[l_cont].ies_desp_val,
                               ma_lanc_cont[l_cont].num_seq,
                               ma_lanc_cont[l_cont].ies_cnd_pgto,
                               ma_lanc_cont[l_cont].val_lanc

    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
       CALL log003_err_sql("FOREACH","CL_LANC_CONT")
       RETURN FALSE
    END IF

       IF l_val_aen IS NOT NULL AND ma_lanc_cont[l_cont].val_lanc IS NOT NULL THEN
          LET l_valor_aen = (ma_lanc_cont[l_cont].val_lanc * l_percent) / 100
       ELSE
          LET l_valor_aen = 0
       END IF

       IF l_valor_aen > 0 THEN
          IF ma_lanc_cont[l_cont].ies_tipo_lanc = "D" THEN

             LET l_num_seq_deb                   = l_cont + 1
             LET lr_ad_aen_c_4.cod_empresa       = p_cod_empresa
             LET lr_ad_aen_c_4.num_ad            = l_num_ad
             LET lr_ad_aen_c_4.num_seq           = l_cont
             LET lr_ad_aen_c_4.num_seq_lanc      = ma_lanc_cont[l_cont].num_seq
             LET lr_ad_aen_c_4.ies_tipo_lanc     = 'D'
             LET lr_ad_aen_c_4.num_conta_cont    = ma_lanc_cont[l_cont].num_conta_cont
             LET lr_ad_aen_c_4.ies_fornec_trans  = 'N'
             LET lr_ad_aen_c_4.cod_lin_prod      = l_cod_lin_prod
             LET lr_ad_aen_c_4.cod_lin_recei     = l_cod_lin_recei
             LET lr_ad_aen_c_4.cod_seg_merc      = l_cod_seg_merc
             LET lr_ad_aen_c_4.cod_cla_uso       = l_cod_cla_uso
             LET lr_ad_aen_c_4.val_aen           = l_valor_aen

             WHENEVER ERROR CONTINUE
               INSERT INTO w_ad_aen_conta_4(cod_empresa      ,
                                            num_ad           ,
                                            num_seq          ,
                                            num_seq_lanc     ,
                                            ies_tipo_lanc    ,
                                            num_conta_cont   ,
                                            ies_fornec_trans ,
                                            cod_lin_prod     ,
                                            cod_lin_recei    ,
                                            cod_seg_merc     ,
                                            cod_cla_uso      ,
                                            val_aen          )

                                     VALUES(lr_ad_aen_c_4.cod_empresa      ,
                                            lr_ad_aen_c_4.num_ad           ,
                                            lr_ad_aen_c_4.num_seq          ,
                                            lr_ad_aen_c_4.num_seq_lanc     ,
                                            lr_ad_aen_c_4.ies_tipo_lanc    ,
                                            lr_ad_aen_c_4.num_conta_cont   ,
                                            lr_ad_aen_c_4.ies_fornec_trans ,
                                            lr_ad_aen_c_4.cod_lin_prod     ,
                                            lr_ad_aen_c_4.cod_lin_recei    ,
                                            lr_ad_aen_c_4.cod_seg_merc     ,
                                            lr_ad_aen_c_4.cod_cla_uso      ,
                                            lr_ad_aen_c_4.val_aen          )

             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("INSERT","W_AD_AEN_CONTA_4-D")
                RETURN FALSE
             END IF

             LET l_achou = TRUE

          ELSE
             LET l_num_seq_cred                  = l_cont + 1
             LET lr_ad_aen_c_4.cod_empresa       = p_cod_empresa
             LET lr_ad_aen_c_4.num_ad            = l_num_ad
             LET lr_ad_aen_c_4.num_seq           = l_cont
             LET lr_ad_aen_c_4.num_seq_lanc      = ma_lanc_cont[l_cont].num_seq
             LET lr_ad_aen_c_4.ies_tipo_lanc     = 'C'
             LET lr_ad_aen_c_4.num_conta_cont    = ma_lanc_cont[l_cont].num_conta_cont
             LET lr_ad_aen_c_4.ies_fornec_trans  = 'S'
             LET lr_ad_aen_c_4.cod_lin_prod      = l_cod_lin_prod
             LET lr_ad_aen_c_4.cod_lin_recei     = l_cod_lin_recei
             LET lr_ad_aen_c_4.cod_seg_merc      = l_cod_seg_merc
             LET lr_ad_aen_c_4.cod_cla_uso       = l_cod_cla_uso
             LET lr_ad_aen_c_4.val_aen           = l_valor_aen

             WHENEVER ERROR CONTINUE
               INSERT INTO w_ad_aen_conta_4(cod_empresa      ,
                                            num_ad           ,
                                            num_seq          ,
                                            num_seq_lanc     ,
                                            ies_tipo_lanc    ,
                                            num_conta_cont   ,
                                            ies_fornec_trans ,
                                            cod_lin_prod     ,
                                            cod_lin_recei    ,
                                            cod_seg_merc     ,
                                            cod_cla_uso      ,
                                            val_aen          )

                                     VALUES(lr_ad_aen_c_4.cod_empresa      ,
                                            lr_ad_aen_c_4.num_ad           ,
                                            lr_ad_aen_c_4.num_seq          ,
                                            lr_ad_aen_c_4.num_seq_lanc     ,
                                            lr_ad_aen_c_4.ies_tipo_lanc    ,
                                            lr_ad_aen_c_4.num_conta_cont   ,
                                            lr_ad_aen_c_4.ies_fornec_trans ,
                                            lr_ad_aen_c_4.cod_lin_prod     ,
                                            lr_ad_aen_c_4.cod_lin_recei    ,
                                            lr_ad_aen_c_4.cod_seg_merc     ,
                                            lr_ad_aen_c_4.cod_cla_uso      ,
                                            lr_ad_aen_c_4.val_aen          )

             WHENEVER ERROR STOP
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("INSERT","W_AD_AEN_CONTA_4-C")
                RETURN FALSE
             END IF

             LET l_achou = TRUE

          END IF
       END IF

       LET l_cont = l_cont + 1

    END FOREACH

    FOR l_cont = 1 TO 100
       IF l_valor_aen IS NOT NULL OR l_valor_aen = " " THEN
          LET lr_ad_aen_4.cod_empresa      = p_cod_empresa
          LET lr_ad_aen_4.num_ad           = l_num_ad
          LET lr_ad_aen_4.val_aen          = l_valor_aen
          LET lr_ad_aen_4.cod_lin_prod     = l_cod_lin_prod
          LET lr_ad_aen_4.cod_lin_recei    = l_cod_lin_recei
          LET lr_ad_aen_4.cod_seg_merc     = l_cod_seg_merc
          LET lr_ad_aen_4.cod_cla_uso      = l_cod_cla_uso

          WHENEVER ERROR CONTINUE
           INSERT INTO w_ad_aen_4 (cod_empresa  ,
                                   num_ad       ,
                                   val_aen      ,
                                   cod_lin_prod ,
                                   cod_lin_recei,
                                   cod_seg_merc ,
                                   cod_cla_uso  )

                            VALUES(lr_ad_aen_4.cod_empresa  ,
                                   lr_ad_aen_4.num_ad       ,
                                   lr_ad_aen_4.val_aen      ,
                                   lr_ad_aen_4.cod_lin_prod ,
                                   lr_ad_aen_4.cod_lin_recei,
                                   lr_ad_aen_4.cod_seg_merc ,
                                   lr_ad_aen_4.cod_cla_uso  )
          WHENEVER ERROR STOP

          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("INCLUSAO", "AD_AEN_4")
             RETURN FALSE
          END IF
       ELSE
          CONTINUE FOR
       END IF
    END FOR

 END FOREACH

 IF NOT cdv0804_exclui_para_incluir(l_num_ad) THEN
   RETURN FALSE
 END IF

 IF l_achou = TRUE THEN
    IF NOT cdv0804_insere_ad_aen_conta_4() THEN
       RETURN FALSE
    END IF

    IF NOT cdv0804_acerta_diferenca_centavos(l_num_ad) THEN
       RETURN FALSE
    END IF

    IF NOT cdv0804_grava_ctb_lanc_ctbl_cap(l_num_ad) THEN
       RETURN FALSE
    END IF

 ELSE
    MESSAGE "Não existem AD´s ..." ATTRIBUTE(REVERSE)
 END IF

 RETURN TRUE

END FUNCTION
#------------------------------------------#
 FUNCTION cdv0804_grava_ctb_lanc_ctbl_cap(l_num_ad)
#------------------------------------------#
  DEFINE l_num_ad        LIKE ad_mestre.num_ad,
         l_num_seq       INTEGER,
         l_manut_tabela  SMALLINT,
         l_processa      SMALLINT

   WHENEVER ERROR CONTINUE
   DECLARE cq_lanc_cont_cap CURSOR FOR
    SELECT num_seq
      FROM lanc_cont_cap
     WHERE cod_empresa = p_cod_empresa
       AND num_ad_ap   = l_num_ad
       AND ies_ad_ap   = 1
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","cq_lanc_cont_cap")
      RETURN FALSE
   END IF

      WHENEVER ERROR CONTINUE
      FOREACH cq_lanc_cont_cap INTO l_num_seq
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("FOREACH","cq_lanc_cont_cap")
         RETURN FALSE
      END IF

          CALL capr16_manutencao_ctb_lanc_ctbl_cap("I", p_cod_empresa, l_num_ad, 1, l_num_seq)
          RETURNING l_manut_tabela, l_processa
          IF NOT l_processa THEN
             RETURN FALSE
          END IF

      END FOREACH

END FUNCTION
#------------------------------------------#
 FUNCTION cdv0804_carrega_arrays(l_num_ad)
#------------------------------------------#
 DEFINE l_num_ad         LIKE ad_mestre.num_ad,
        l_cont           SMALLINT,
        l_tot_aen        SMALLINT

 LET l_cont = 1

 WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_tot_aen
     FROM ad_aen_4
    WHERE cod_empresa = p_cod_empresa
      AND num_ad      = l_num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 100 OR l_tot_aen = 0 THEN
    LET l_tot_aen = 1
    WHILE TRUE
       IF t_aen_309_4[l_tot_aen].val_aen IS NULL THEN
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
       INSERT INTO ad_aen_4 (cod_empresa, num_ad, val_aen, cod_lin_prod,
                             cod_lin_recei, cod_seg_merc, cod_cla_uso)
                     VALUES (p_cod_empresa, l_num_ad, t_aen_309_4[l_tot_aen].val_aen,
                             t_aen_309_4[l_tot_aen].cod_lin_prod, t_aen_309_4[l_tot_aen].cod_lin_recei,
                             t_aen_309_4[l_tot_aen].cod_seg_merc, t_aen_309_4[l_tot_aen].cod_cla_uso)
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT","ad_aen_4-1")
          EXIT WHILE
       END IF
       LET l_tot_aen = l_tot_aen + 1
    END WHILE
 END IF

END FUNCTION
#-----------------------------------------#
 FUNCTION cdv0804_retorna_valor(l_num_ad)
#-----------------------------------------#
 DEFINE l_valor  LIKE lanc_cont_cap.val_lanc,
        l_num_ad LIKE lanc_cont_cap.num_ad_ap

 LET l_valor = 0

 WHENEVER ERROR CONTINUE
  SELECT SUM(val_lanc)
    INTO l_valor
    FROM lanc_cont_cap
   WHERE cod_empresa = p_cod_empresa
     AND num_ad_ap   = l_num_ad
     AND ies_ad_ap   = "1"
     AND ies_tipo_lanc = "D"
 WHENEVER ERROR STOP

 IF l_valor IS NULL THEN
    LET l_valor = 0
 END IF

 RETURN l_valor

 END FUNCTION

#-----------------------------------------------#
 FUNCTION cdv0804_exclui_para_incluir(l_num_ad)
#-----------------------------------------------#
 DEFINE l_num_ad    LIKE ad_mestre.num_ad

 WHENEVER ERROR CONTINUE
  DELETE FROM ad_aen_4
   WHERE cod_empresa = p_cod_empresa
     AND num_ad      = l_num_ad
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("EXCLUSAO", "AD_AEN_4")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  DELETE FROM ad_aen_conta_4
   WHERE cod_empresa = p_cod_empresa
     AND num_ad      = l_num_ad
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("EXCLUSAO", "AD_AEN_CONTA_4")
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION cdv0804_verifica_aen()
#-------------------------------#
 DEFINE l_cont     SMALLINT

 FOR l_cont = 1 TO 100
     IF ma_ad_aen_4[l_cont].cod_lin_prod IS NOT NULL THEN
        IF NOT cdv0804_verifica_lin_prod(ma_ad_aen_4[l_cont].cod_lin_prod) THEN
           CALL log0030_mensagem("Linha de produto não cadastrada.","exclamation")
           RETURN FALSE
        END IF
     END IF
     IF ma_ad_aen_4[l_cont].cod_lin_recei IS NOT NULL THEN
        IF NOT cdv0804_verifica_lin_recei(ma_ad_aen_4[l_cont].cod_lin_prod,
                                      ma_ad_aen_4[l_cont].cod_lin_recei) THEN
           CALL log0030_mensagem("Linha de receita não cadastrada.","exclamation")
           RETURN FALSE
        END IF
     END IF
     IF ma_ad_aen_4[l_cont].cod_seg_merc IS NOT NULL THEN
        IF NOT cdv0804_verifica_seg_merc(ma_ad_aen_4[l_cont].cod_lin_prod,
                                     ma_ad_aen_4[l_cont].cod_lin_recei,
                                     ma_ad_aen_4[l_cont].cod_seg_merc) THEN
           CALL log0030_mensagem("Segmento de mercado não cadastrado.","exclamation")
           RETURN FALSE
        END IF
     END IF
     IF ma_ad_aen_4[l_cont].cod_cla_uso IS NOT NULL THEN
        IF NOT cdv0804_verifica_cla_uso(ma_ad_aen_4[l_cont].cod_lin_prod,
                                    ma_ad_aen_4[l_cont].cod_lin_recei,
                                    ma_ad_aen_4[l_cont].cod_seg_merc,
                                    ma_ad_aen_4[l_cont].cod_cla_uso) THEN
           CALL log0030_mensagem("Classe de uso não cadastrado.","exclamation")
           RETURN FALSE
        END IF
     END IF
 END FOR

 RETURN TRUE

END FUNCTION

#-------------------------------------------------#
 FUNCTION cdv0804_verifica_lin_prod(l_linha_prod)
#-------------------------------------------------#
 DEFINE l_linha_prod   LIKE linha_prod.cod_lin_prod

 WHENEVER ERROR CONTINUE
  SELECT den_estr_linprod
    FROM linha_prod
   WHERE cod_lin_prod  = l_linha_prod
     AND cod_lin_recei = 0
     AND cod_seg_merc  = 0
     AND cod_cla_uso   = 0
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION cdv0804_verifica_lin_recei(l_linha_prod, l_linha_recei)
#-----------------------------------------------------------------#
 DEFINE l_linha_prod    LIKE linha_prod.cod_lin_prod,
        l_linha_recei   LIKE linha_prod.cod_lin_recei

 WHENEVER ERROR CONTINUE
  SELECT den_estr_linprod
    FROM linha_prod
   WHERE cod_lin_prod  = l_linha_prod
     AND cod_lin_recei = l_linha_recei
     AND cod_seg_merc  = 0
     AND cod_cla_uso   = 0
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION cdv0804_verifica_seg_merc(l_linha_prod, l_linha_recei, l_seg_merc)
#---------------------------------------------------------------------------#
 DEFINE l_linha_prod    LIKE linha_prod.cod_lin_prod,
        l_linha_recei   LIKE linha_prod.cod_lin_recei,
        l_seg_merc      LIKE linha_prod.cod_seg_merc

 WHENEVER ERROR CONTINUE
 SELECT den_estr_linprod
   FROM linha_prod
  WHERE cod_lin_prod  = l_linha_prod
    AND cod_lin_recei = l_linha_recei
    AND cod_seg_merc  = l_seg_merc
    AND cod_cla_uso   = 0
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------------------------------------------------#
 FUNCTION cdv0804_verifica_cla_uso(l_linha_prod, l_linha_recei, l_seg_merc, l_cla_uso)
#--------------------------------------------------------------------------------------#
 DEFINE l_linha_prod    LIKE linha_prod.cod_lin_prod,
        l_linha_recei   LIKE linha_prod.cod_lin_recei,
        l_seg_merc      LIKE linha_prod.cod_seg_merc,
        l_cla_uso       LIKE linha_prod.cod_cla_uso

 WHENEVER ERROR CONTINUE
  SELECT den_estr_linprod
    FROM linha_prod
   WHERE cod_lin_prod  = l_linha_prod
     AND cod_lin_recei = l_linha_recei
     AND cod_seg_merc  = l_seg_merc
     AND cod_cla_uso   = l_cla_uso
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------------------------#
 FUNCTION cdv0804_busca_conta_transitoria(l_num_ad)
#--------------------------------------------------#
 DEFINE l_num_conta     LIKE lanc_cont_cap.num_conta_cont,
        l_num_ad        LIKE ad_mestre.num_ad

 LET l_num_conta = NULL

 DECLARE cl_conta CURSOR FOR
  SELECT UNIQUE num_conta_cont
    FROM lanc_cont_cap
   WHERE cod_empresa = p_cod_empresa
     AND num_ad_ap   = l_num_ad
     AND ies_ad_ap   = "1"
     AND ies_tipo_lanc = "C"
    ORDER BY num_conta_cont

 FOREACH cl_conta INTO l_num_conta

    IF SQLCA.sqlcode <> 0 THEN
       LET l_num_conta = NULL
    END IF

    EXIT FOREACH

 END FOREACH

 RETURN l_num_conta

END FUNCTION

#-----------------------------#
 FUNCTION cdv0804_cria_temp()
#-----------------------------#

  WHENEVER ERROR CONTINUE

  DROP TABLE w_ad_aen_conta_4
  CREATE TEMP TABLE w_ad_aen_conta_4
    (cod_empresa          CHAR(2),
     num_ad               DECIMAL(6,0),
     num_seq              DECIMAL(5,0),
     num_seq_lanc         DECIMAL(3,0),
     ies_tipo_lanc        CHAR(1),
     num_conta_cont       CHAR(23),
     ies_fornec_trans     CHAR(1),
     cod_lin_prod         DECIMAL(2,0),
     cod_lin_recei        DECIMAL(2,0),
     cod_seg_merc         DECIMAL(2,0),
     cod_cla_uso          DECIMAL(2,0),
     val_aen              DECIMAL(15,2))WITH NO LOG;

  WHENEVER ERROR STOP


  WHENEVER ERROR CONTINUE

  DROP TABLE w_ad_aen_4
  CREATE TEMP TABLE w_ad_aen_4
    (cod_empresa     CHAR(02),
     num_ad          DECIMAL(6,0),
     val_aen         DECIMAL(15,2),
     cod_lin_prod    DECIMAL(2,0),
     cod_lin_recei   DECIMAL(2,0),
     cod_seg_merc    DECIMAL(2,0),
     cod_cla_uso     DECIMAL(2,0))WITH NO LOG;
  WHENEVER ERROR STOP

END FUNCTION
#---------------------------------------#
FUNCTION cdv0804_insere_ad_aen_conta_4()
#---------------------------------------#

 DEFINE lr_ad_aen_c_4          RECORD LIKE ad_aen_conta_4.*,
        lr_ad_aen              RECORD LIKE ad_aen_4.*,
        l_empresa              LIKE ad_aen_conta_4.cod_empresa,
        l_num_ad               LIKE ad_aen_conta_4.num_ad,
        l_tipo_lanc            LIKE ad_aen_conta_4.ies_tipo_lanc

   LET lr_ad_aen_c_4.num_seq = 0
   LET l_empresa = 0

   INITIALIZE l_tipo_lanc TO NULL

 WHENEVER ERROR CONTINUE
 DECLARE cq_ad_aen_4 CURSOR FOR
  SELECT cod_empresa,
         num_ad,
         val_aen,
         cod_lin_prod,
         cod_lin_recei,
         cod_seg_merc,
         cod_cla_uso
    FROM w_ad_aen_4
  GROUP BY cod_empresa,
           num_ad,
           val_aen,
           cod_lin_prod,
           cod_lin_recei,
           cod_seg_merc,
           cod_cla_uso
  ORDER BY cod_empresa, num_ad
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELEÇÃO","W_AD_AEN_CONTA_4")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_ad_aen_4 INTO lr_ad_aen.cod_empresa  ,
                           lr_ad_aen.num_ad       ,
                           lr_ad_aen.val_aen      ,
                           lr_ad_aen.cod_lin_prod ,
                           lr_ad_aen.cod_lin_recei,
                           lr_ad_aen.cod_seg_merc ,
                           lr_ad_aen.cod_cla_uso
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","CQ_AD_AEN_4")
    RETURN FALSE
 END IF

    WHENEVER ERROR CONTINUE
      INSERT INTO ad_aen_4 (cod_empresa,
                            num_ad,
                            val_aen,
                            cod_lin_prod,
                            cod_lin_recei,
                            cod_seg_merc,
                            cod_cla_uso)

                     VALUES(lr_ad_aen.cod_empresa,
                            lr_ad_aen.num_ad,
                            lr_ad_aen.val_aen,
                            lr_ad_aen.cod_lin_prod,
                            lr_ad_aen.cod_lin_recei,
                            lr_ad_aen.cod_seg_merc,
                            lr_ad_aen.cod_cla_uso)


    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","AD_AEN_4")
       RETURN FALSE
    END IF

 END FOREACH
 FREE cq_ad_aen_4

 WHENEVER ERROR CONTINUE
  DECLARE cq_ad_aen_conta CURSOR FOR
   SELECT cod_empresa, num_ad, num_seq_lanc,
          ies_tipo_lanc, num_conta_cont,
          ies_fornec_trans, cod_lin_prod, cod_lin_recei,
          cod_seg_merc, cod_cla_uso, SUM(val_aen)
     FROM w_ad_aen_conta_4
   GROUP BY cod_empresa, num_ad, ies_tipo_lanc, num_conta_cont, num_seq_lanc,
            ies_fornec_trans, cod_lin_prod, cod_lin_recei,
            cod_seg_merc, cod_cla_uso
   ORDER BY cod_empresa, num_ad, ies_tipo_lanc, num_conta_cont

   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("SELEÇÃO","W_AD_AEN_CONTA_4")
      RETURN FALSE
   END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_ad_aen_conta INTO lr_ad_aen_c_4.cod_empresa, lr_ad_aen_c_4.num_ad,  lr_ad_aen_c_4.num_seq_lanc,
                               lr_ad_aen_c_4.ies_tipo_lanc, lr_ad_aen_c_4.num_conta_cont,
                               lr_ad_aen_c_4.ies_fornec_trans, lr_ad_aen_c_4.cod_lin_prod,
                               lr_ad_aen_c_4.cod_lin_recei, lr_ad_aen_c_4.cod_seg_merc,
                               lr_ad_aen_c_4.cod_cla_uso, lr_ad_aen_c_4.val_aen

 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","cq_ad_aen_conta")
    RETURN FALSE
 END IF

    LET lr_ad_aen_c_4.num_seq = lr_ad_aen_c_4.num_seq + 1

    IF lr_ad_aen_c_4.ies_tipo_lanc = 'D' THEN

       WHENEVER ERROR CONTINUE
         INSERT INTO ad_aen_conta_4 (cod_empresa, num_ad, num_seq, num_seq_lanc, ies_tipo_lanc,
                                     num_conta_cont, ies_fornec_trans, cod_lin_prod, cod_lin_recei,
                                     cod_seg_merc, cod_cla_uso, val_aen)
                              VALUES(lr_ad_aen_c_4.cod_empresa,    lr_ad_aen_c_4.num_ad, lr_ad_aen_c_4.num_seq,
                                     lr_ad_aen_c_4.num_seq_lanc,   lr_ad_aen_c_4.ies_tipo_lanc,
                                     lr_ad_aen_c_4.num_conta_cont, lr_ad_aen_c_4.ies_fornec_trans,
                                     lr_ad_aen_c_4.cod_lin_prod,   lr_ad_aen_c_4.cod_lin_recei,
                                     lr_ad_aen_c_4.cod_seg_merc,   lr_ad_aen_c_4.cod_cla_uso,
                                     lr_ad_aen_c_4.val_aen)

       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT","AD_AEN_CONTA_4-d")
          RETURN FALSE
       END IF

       LET l_empresa = lr_ad_aen_c_4.cod_empresa
       LET l_num_ad = lr_ad_aen_c_4.num_ad

    ELSE
       IF lr_ad_aen_c_4.ies_tipo_lanc = 'C' THEN

          WHENEVER ERROR CONTINUE
            INSERT INTO ad_aen_conta_4 (cod_empresa, num_ad, num_seq, num_seq_lanc, ies_tipo_lanc,
                                        num_conta_cont, ies_fornec_trans, cod_lin_prod, cod_lin_recei,
                                        cod_seg_merc, cod_cla_uso, val_aen)
                                 VALUES(lr_ad_aen_c_4.cod_empresa,    lr_ad_aen_c_4.num_ad, lr_ad_aen_c_4.num_seq,
                                        lr_ad_aen_c_4.num_seq_lanc,   lr_ad_aen_c_4.ies_tipo_lanc,
                                        lr_ad_aen_c_4.num_conta_cont, lr_ad_aen_c_4.ies_fornec_trans,
                                        lr_ad_aen_c_4.cod_lin_prod,   lr_ad_aen_c_4.cod_lin_recei,
                                        lr_ad_aen_c_4.cod_seg_merc,   lr_ad_aen_c_4.cod_cla_uso,
                                        lr_ad_aen_c_4.val_aen)

          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("INSERT","AD_AEN_CONTA_4-c")
             RETURN FALSE
          END IF

          LET l_empresa = lr_ad_aen_c_4.cod_empresa
          LET l_num_ad = lr_ad_aen_c_4.num_ad
          LET l_tipo_lanc = lr_ad_aen_c_4.ies_tipo_lanc
       END IF
    END IF

    WHENEVER ERROR STOP

   END FOREACH
   FREE cq_ad_aen_conta

   RETURN TRUE

END FUNCTION

#-----------------------------------------------------#
 FUNCTION cdv0804_acerta_diferenca_centavos(l_num_ad)
#-----------------------------------------------------#
   DEFINE l_difer                LIKE ad_aen_4.val_aen,
          l_val_aen              LIKE ad_aen_4.val_aen,
          l_sum_aen_conta        LIKE ad_aen_4.val_aen,
          l_max_val_aen          LIKE ad_aen_4.val_aen,
          l_max_num_seq          LIKE ad_aen_conta_4.num_seq,
          l_num_ad               LIKE ad_mestre.num_ad,
          l_cod_lin_prod         LIKE ad_aen_conta_4.cod_lin_prod ,
          l_cod_lin_recei        LIKE ad_aen_conta_4.cod_lin_recei,
          l_cod_seg_merc         LIKE ad_aen_conta_4.cod_seg_merc ,
          l_cod_cla_uso          LIKE ad_aen_conta_4.cod_cla_uso

  WHENEVER ERROR CONTINUE
  DECLARE cq_w_ad_aen CURSOR FOR
   SELECT cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso, SUM(val_aen)
     FROM ad_aen_4
    WHERE cod_empresa = p_cod_empresa
      AND num_ad      = l_num_ad
    GROUP BY cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso
    ORDER BY 5
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND SQLCA.SQLCODE <> NOTFOUND THEN
    CALL log003_err_sql("SELECT","AD_AEN_4")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_w_ad_aen INTO l_cod_lin_prod ,
                           l_cod_lin_recei,
                           l_cod_seg_merc ,
                           l_cod_cla_uso  ,
                           l_val_aen
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
    CALL log003_err_sql("FOREACH","cq_w_ad_aen")
    RETURN FALSE
 END IF

    WHENEVER ERROR CONTINUE
    SELECT SUM(val_aen)
      INTO l_sum_aen_conta
      FROM ad_aen_conta_4
     WHERE cod_empresa = p_cod_empresa
       AND num_ad = l_num_ad
       AND ies_tipo_lanc = 'D'
       AND cod_lin_prod = l_cod_lin_prod
       AND cod_lin_recei = l_cod_lin_recei
       AND cod_seg_merc = l_cod_seg_merc
       AND cod_cla_uso = l_cod_cla_uso
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('LEITURA','W_AD_AEN_CONTA_4')
       RETURN FALSE
    END IF

    IF l_sum_aen_conta <> l_val_aen THEN
        LET l_difer = l_sum_aen_conta - l_val_aen

        WHENEVER ERROR CONTINUE
        SELECT MAX(val_aen)
          INTO l_max_val_aen
          FROM ad_aen_conta_4
         WHERE cod_empresa = p_cod_empresa
           AND num_ad = l_num_ad
           AND ies_tipo_lanc = 'D'
           AND cod_lin_prod = l_cod_lin_prod
           AND cod_lin_recei = l_cod_lin_recei
           AND cod_seg_merc = l_cod_seg_merc
           AND cod_cla_uso = l_cod_cla_uso
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('LEITURA','W_AD_AEN_CONTA_4')
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        SELECT MAX(num_seq)
          INTO l_max_num_seq
          FROM ad_aen_conta_4
         WHERE cod_empresa = p_cod_empresa
           AND num_ad = l_num_ad
           AND val_aen = l_max_val_aen
           AND ies_tipo_lanc = 'D'
           AND cod_lin_prod = l_cod_lin_prod
           AND cod_lin_recei = l_cod_lin_recei
           AND cod_seg_merc = l_cod_seg_merc
           AND cod_cla_uso = l_cod_cla_uso
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('LEITURA','W_AD_AEN_CONTA_4')
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        UPDATE ad_aen_conta_4
           SET val_aen = val_aen - l_difer #Soma ou diminui conforme o sinal da variável
         WHERE cod_empresa = p_cod_empresa
           AND num_ad = l_num_ad
           AND val_aen = l_max_val_aen
           AND num_seq = l_max_num_seq
           AND ies_tipo_lanc = 'D'
           AND cod_lin_prod = l_cod_lin_prod
           AND cod_lin_recei = l_cod_lin_recei
           AND cod_seg_merc = l_cod_seg_merc
           AND cod_cla_uso = l_cod_cla_uso
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql('UPDATE','W_AD_AEN_CONTA_4')
           RETURN FALSE
        END IF

    END IF

 END FOREACH
 FREE cq_w_ad_aen

 RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION cdv0804_version_info()
#-------------------------------#
  #LOG1700 mostra a versão
  
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/gps_logist_e_gerenc_de_riscos_ltda/financeiro/controle_despesa_viagem/funcoes/cdv0804.4gl $|$Revision: 4 $|$Date: 27/06/12 17:41 $|$Modtime:  $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION