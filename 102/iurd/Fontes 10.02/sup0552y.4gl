###PARSER-Não remover esta linha(Framework Logix)###
#----------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                                #
# PROGRAMA: SUP0552Y                                                   #
# OBJETIVO: EPL INTERNA SUP0552 - CLIENTE 55                           #
# AUTOR...: JANAINA SOMBRIO                                            #
# DATA....: 25/08/2010                                                 #
#----------------------------------------------------------------------#

DATABASE logix

 GLOBALS

  DEFINE p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         g_comando              CHAR(100),
         p_cod_empresa          LIKE empresa.cod_empresa

 END GLOBALS

 DEFINE m_versao_funcao             CHAR(18)
 DEFINE m_dir_arq_proc_sup0552      CHAR(100),
        m_dir_arq_erro_sup0552      CHAR(100)




#------------------------------------------------#
 FUNCTION sup0552y_after_process_importacao_nf()
#------------------------------------------------#
 DEFINE l_nom_arquivo              CHAR(200),
        l_seq_inclusao             SMALLINT,
        l_arquivo_importacao_aux   CHAR(200),
        l_msg                      CHAR(100),
        l_cont                     SMALLINT,
        l_dir_arq_sup0552          CHAR(100),
        l_arquivo_ret              CHAR(200),
        l_email                    CHAR(100),
        l_email2                   CHAR(100),
        l_email_aux                CHAR(200),
        l_sequencia                DECIMAL(3,0),
        l_txt_consistencia         CHAR(59),
        l_txt                      CHAR(59),
        l_transacao                INTEGER,
        l_hora                     CHAR(08),
        l_data                     CHAR(10),
        l_nome_arquivo             CHAR(100)

  DEFINE lr_consistencia   RECORD
                             nota_fiscal       DECIMAL(6,0),
                             serie_nota_fiscal CHAR(03),
                             subserie_nf       DECIMAL(2,0),
                             espc_nota_fiscal  CHAR(03),
                             fornecedor        CHAR(15)
                          END RECORD

  DEFINE lr_importados    RECORD
                             nota_fiscal         DECIMAL(6,0),
                             serie_nota_fiscal   CHAR(03),
                             subserie_nf         DECIMAL(2,0),
                             espc_nota_fiscal    CHAR(03),
                             fornecedor          CHAR(15),
                             num_aviso_rec       DECIMAL(7,0)
                           END RECORD

   INITIALIZE lr_consistencia.*,
              lr_importados.* TO NULL

   LET l_dir_arq_sup0552 = LOG_getVar("caminho")

   INITIALIZE m_dir_arq_proc_sup0552 TO NULL
   CALL log2250_busca_parametro(p_cod_empresa,"dir_arq_proc_sup0552")
      RETURNING m_dir_arq_proc_sup0552, p_status
   CALL sup0552_edita_dir(m_dir_arq_proc_sup0552) RETURNING m_dir_arq_proc_sup0552

   INITIALIZE m_dir_arq_erro_sup0552 TO NULL
   CALL log2250_busca_parametro(p_cod_empresa,"dir_arq_erro_sup0552")
      RETURNING m_dir_arq_erro_sup0552, p_status
   CALL sup0552_edita_dir(m_dir_arq_erro_sup0552) RETURNING m_dir_arq_erro_sup0552


   WHENEVER ERROR CONTINUE
    DECLARE cq_w_sup0552_1 CURSOR WITH HOLD FOR
     SELECT UNIQUE nota_fiscal,
            serie_nota_fiscal,
            subserie_nf,
            espc_nota_fiscal,
            fornecedor
       FROM w_sup0552_1
      ORDER BY w_sup0552_1.nota_fiscal,
               w_sup0552_1.serie_nota_fiscal,
               w_sup0552_1.subserie_nf,
               w_sup0552_1.espc_nota_fiscal,
               w_sup0552_1.fornecedor
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FOREACH cq_w_sup0552_1 INTO lr_consistencia.nota_fiscal,
                               lr_consistencia.serie_nota_fiscal,
                               lr_consistencia.subserie_nf,
                               lr_consistencia.espc_nota_fiscal,
                               lr_consistencia.fornecedor
   WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
      END IF

     LET l_hora = TIME
     LET l_data = TODAY

     WHENEVER ERROR CONTINUE
       SELECT MAX(transacao)
         INTO l_transacao
         FROM com_err_port_909
     WHENEVER ERROR STOP

     LET l_transacao = l_transacao + 1

     WHENEVER ERROR CONTINUE
       INSERT INTO com_err_port_909(empresa,
                                    fornecedor,
                                    num_nf,
                                    ies_espc_nf,
                                    ser_nf,
                                    ssr_nf,
                                    arquivo,
                                    situacao,
                                    data,
                                    hora,
                                    transacao,
                                    sit_export)
                            VALUES (p_cod_empresa,
                                    lr_consistencia.fornecedor,
                                    lr_consistencia.nota_fiscal,
                                    lr_consistencia.espc_nota_fiscal,
                                    lr_consistencia.serie_nota_fiscal,
                                    lr_consistencia.subserie_nf,
                                    "Arquivo NF",
                                    "I",
                                    l_data,
                                    l_hora,
                                    l_transacao,
                                    'N')
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CONTINUE FOREACH
     END IF

     INITIALIZE l_arquivo_ret,
                l_email,
                l_email2,
                l_email_aux,
                l_sequencia,
                l_txt_consistencia TO NULL

      LET l_arquivo_ret = l_dir_arq_sup0552 CLIPPED,
                          lr_consistencia.nota_fiscal USING "<<<<<<","_",
                          lr_consistencia.fornecedor CLIPPED,".html"

      LET l_arquivo_ret  = l_arquivo_ret CLIPPED

      LET l_nome_arquivo = lr_consistencia.nota_fiscal USING "<<<<<<","_",
                           lr_consistencia.fornecedor CLIPPED,".html"
      LET l_nome_arquivo = l_nome_arquivo CLIPPED

      START REPORT sup0552y_relat_ret TO l_arquivo_ret

      WHENEVER ERROR CONTINUE
       DECLARE cq_w_sup0552_txt CURSOR FOR
        SELECT UNIQUE sequencia,
               txt_consistencia
          FROM w_sup0552_1
         WHERE nota_fiscal       = lr_consistencia.nota_fiscal
           AND serie_nota_fiscal = lr_consistencia.serie_nota_fiscal
           AND subserie_nf       = lr_consistencia.subserie_nf
           AND espc_nota_fiscal  = lr_consistencia.espc_nota_fiscal
           AND fornecedor        = lr_consistencia.fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

      WHENEVER ERROR CONTINUE
      FOREACH cq_w_sup0552_txt INTO l_sequencia,
                                    l_txt_consistencia
      WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            EXIT FOREACH
         END IF

         WHENEVER ERROR CONTINUE
           INSERT INTO com_err_obs_pt_909 (empresa,
                                           transacao,
                                           sequencia,
                                           texto)
                                    VALUES(p_cod_empresa,
                                           l_transacao,
                                           l_sequencia,
                                           l_txt_consistencia)
         WHENEVER ERROR STOP

         OUTPUT TO REPORT sup0552y_relat_ret(lr_consistencia.*,l_sequencia, l_txt_consistencia)

      END FOREACH
      FREE cq_w_sup0552_txt

      FINISH REPORT sup0552y_relat_ret

      WHENEVER ERROR CONTINUE
        SELECT a.e_mail, a.email_secund
          INTO l_email, l_email2
          FROM fornec_compl a, fornecedor b
         WHERE b.cod_fornecedor = lr_consistencia.fornecedor
           AND a.cod_fornecedor = b.cod_fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

      #IF l_email2 IS NULL OR
      #   l_email2 = ' ' THEN
         LET l_email_aux = l_email
      #ELSE
      #   LET l_email_aux = l_email CLIPPED,"','",l_email2 CLIPPED
      #END IF

      #WHENEVER ERROR CONTINUE
      # SELECT num_aviso_rec
      #   INTO lr_importados.num_aviso_rec
      #   FROM nf_sup
      #  WHERE cod_empresa    = p_cod_empresa
      #    AND num_nf         = lr_importados.nota_fiscal
      #    AND ser_nf         = lr_importados.serie_nota_fiscal
      #    AND ssr_nf         = lr_importados.subserie_nf
      #    AND ies_especie_nf = lr_importados.espc_nota_fiscal
      #    AND cod_fornecedor = lr_importados.fornecedor
      #WHENEVER ERROR STOP
      #IF sqlca.sqlcode <> 0 THEN
      #   CONTINUE FOREACH
      #END IF

      CALL sup0552y_envia_email(l_email_aux,
                                l_arquivo_ret,
                                lr_importados.num_aviso_rec,
                                m_dir_arq_erro_sup0552,
                                l_nome_arquivo)
      INITIALIZE lr_importados.num_aviso_rec TO NULL

   END FOREACH
   FREE cq_w_sup0552_1

   # ABAIXO IRÁ ENVIAR EMAIL DAS NOTAS IMPORTADAS COM SUCESSO

   WHENEVER ERROR CONTINUE
    DECLARE cq_w_sup0552_2 CURSOR WITH HOLD FOR
     SELECT UNIQUE w_sup0552_2.nota_fiscal,
            w_sup0552_2.serie_nota_fiscal,
            w_sup0552_2.subserie_nf,
            w_sup0552_2.espc_nota_fiscal,
            w_sup0552_2.fornecedor
       FROM w_sup0552_2
      ORDER BY w_sup0552_2.nota_fiscal,
               w_sup0552_2.serie_nota_fiscal,
               w_sup0552_2.subserie_nf,
               w_sup0552_2.espc_nota_fiscal,
               w_sup0552_2.fornecedor
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
        RETURN
    END IF

    WHENEVER ERROR CONTINUE
    FOREACH cq_w_sup0552_2 INTO lr_importados.nota_fiscal,
                                lr_importados.serie_nota_fiscal,
                                lr_importados.subserie_nf,
                                lr_importados.espc_nota_fiscal,
                                lr_importados.fornecedor
    WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         EXIT FOREACH
      END IF

     LET l_hora = TIME
     LET l_data = TODAY

     WHENEVER ERROR CONTINUE
       SELECT MAX(transacao)
         INTO l_transacao
         FROM com_err_port_909
     WHENEVER ERROR STOP

     LET l_transacao = l_transacao + 1

     WHENEVER ERROR CONTINUE
       INSERT INTO com_err_port_909
       VALUES (p_cod_empresa,
               lr_importados.fornecedor,
               lr_importados.nota_fiscal,
               lr_importados.espc_nota_fiscal,
               lr_importados.serie_nota_fiscal,
               lr_importados.subserie_nf,
               "Arquivo NF",
               "S",
               l_data,
               l_hora,
               l_transacao,
               'N')
     WHENEVER ERROR STOP

      LET l_arquivo_ret = l_dir_arq_sup0552 CLIPPED,
                          lr_importados.nota_fiscal USING "<<<<<<","_",
                          lr_importados.fornecedor CLIPPED,".html"

      LET l_arquivo_ret = l_arquivo_ret CLIPPED

      LET l_nome_arquivo = lr_consistencia.nota_fiscal USING "<<<<<<","_",
                           lr_consistencia.fornecedor CLIPPED,".html"
      LET l_nome_arquivo = l_nome_arquivo CLIPPED

      START REPORT sup0552y_relat2 TO l_arquivo_ret

      WHENEVER ERROR CONTINUE
        SELECT num_aviso_rec
          INTO lr_importados.num_aviso_rec
          FROM nf_sup
         WHERE cod_empresa    = p_cod_empresa
           AND num_nf         = lr_importados.nota_fiscal
           AND ser_nf         = lr_importados.serie_nota_fiscal
           AND ssr_nf         = lr_importados.subserie_nf
           AND ies_especie_nf = lr_importados.espc_nota_fiscal
           AND cod_fornecedor = lr_importados.fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

     LET l_txt = "NOTA FISCAL IMPORTADA COM SUCESSO. AR GERADO: ",lr_importados.num_aviso_rec
     LET l_txt = l_txt CLIPPED

     WHENEVER ERROR CONTINUE
       INSERT INTO com_err_obs_pt_909
       VALUES(p_cod_empresa, l_transacao, 1 ,l_txt)
     WHENEVER ERROR STOP

      INITIALIZE l_email,
                 l_email2,
                 l_email_aux TO NULL

      OUTPUT TO REPORT sup0552y_relat2(lr_importados.*)

      FINISH REPORT sup0552y_relat2

      WHENEVER ERROR CONTINUE
        SELECT a.e_mail, a.email_secund
          INTO l_email, l_email2
          FROM fornec_compl a, fornecedor b
         WHERE b.cod_fornecedor = lr_importados.fornecedor
           AND a.cod_fornecedor = b.cod_fornecedor
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

      #IF l_email2 IS NULL OR
      #   l_email2 = ' ' THEN
         LET l_email_aux = l_email
      #ELSE
      #   LET l_email_aux = l_email CLIPPED,"','",l_email2 CLIPPED
      #END IF

      LET l_email = l_email CLIPPED

      CALL sup0552y_envia_email(l_email,
                                l_arquivo_ret,
                                lr_importados.num_aviso_rec,
                                m_dir_arq_proc_sup0552,
                                l_nome_arquivo)

   END FOREACH
   FREE cq_w_sup0552_2

   WHENEVER ERROR CONTINUE
       DROP TABLE w_sup0552_1
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
       DROP TABLE w_sup0552_2
   WHENEVER ERROR STOP

   RETURN TRUE


END FUNCTION

#-------------------------------------------------------------#
 FUNCTION sup0552y_before_process_importacao_nf()
#-------------------------------------------------------------#
  DEFINE lr_nf_sup RECORD LIKE nf_sup.*,
         l_acao_nf CHAR(02)

  LET lr_nf_sup.cod_empresa    = LOG_getVar("empresa")
  LET lr_nf_sup.cod_fornecedor = LOG_getVar("fornecedor")
  LET lr_nf_sup.num_nf         = LOG_getVar("num_nf")
  LET lr_nf_sup.ser_nf         = LOG_getVar("ser_nf")
  LET lr_nf_sup.ssr_nf         = LOG_getVar("ssr_nf")
  LET lr_nf_sup.ies_especie_nf = LOG_getVar("ies_especie_nf")
  LET l_acao_nf                = LOG_getVar("acao_nf")

  WHENEVER ERROR CONTINUE
   SELECT *
     INTO lr_nf_sup.*
     FROM nf_sup
    WHERE nf_sup.cod_empresa    = lr_nf_sup.cod_empresa
      AND nf_sup.cod_fornecedor = lr_nf_sup.cod_fornecedor
      AND nf_sup.num_nf         = lr_nf_sup.num_nf
      AND nf_sup.ser_nf         = lr_nf_sup.ser_nf
      AND nf_sup.ssr_nf         = lr_nf_sup.ssr_nf
      AND nf_sup.ies_especie_nf = lr_nf_sup.ies_especie_nf
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      IF lr_nf_sup.ies_nf_aguard_nfe = "7" THEN
         IF sup0552y_exclusao_nota(lr_nf_sup.cod_empresa, lr_nf_sup.num_aviso_rec) THEN
            RETURN TRUE
         END IF
      ELSE
         WHENEVER ERROR CONTINUE
           INSERT INTO w_sup0552_1(nota_fiscal,
                                   serie_nota_fiscal,
                                   subserie_nf,
                                   espc_nota_fiscal,
                                   fornecedor,
                                   sequencia,
                                   txt_consistencia)
                           VALUES (lr_nf_sup.num_nf        ,
                                   lr_nf_sup.ser_nf        ,
                                   lr_nf_sup.ssr_nf        ,
                                   lr_nf_sup.ies_especie_nf,
                                   lr_nf_sup.cod_fornecedor,
                                   0,
                                   "SOMENTE NOTA FISCAL EM TRANSIÇÃO PODE SER ALTERADA OU EXCLUIDA.")
         WHENEVER ERROR STOP
      END IF
   ELSE
      WHENEVER ERROR CONTINUE
        INSERT INTO w_sup0552_1(nota_fiscal,
                                serie_nota_fiscal,
                                subserie_nf,
                                espc_nota_fiscal,
                                fornecedor,
                                sequencia,
                                txt_consistencia)
                        VALUES (lr_nf_sup.num_nf        ,
                                lr_nf_sup.ser_nf        ,
                                lr_nf_sup.ssr_nf        ,
                                lr_nf_sup.ies_especie_nf,
                                lr_nf_sup.cod_fornecedor,
                                0,
                                "NÃO HÁ NOTA FISCAL À SER ALTERADA OU EXCLUIDA.")
      WHENEVER ERROR STOP
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION sup0552y_exclusao_nota(l_empresa, l_num_aviso_rec)
#-------------------------------------------------------------------------#
  DEFINE l_empresa LIKE empresa.cod_empresa

  DEFINE lr_ar_x_nf_pend RECORD LIKE ar_x_nf_pend.*

  DEFINE l_num_aviso_rec  LIKE nf_sup.num_aviso_rec,
         lr_nf_sup        RECORD LIKE nf_sup.*,
         lr_item_ret_terc RECORD LIKE item_ret_terc.*

  WHENEVER ERROR CONTINUE
  SELECT *
    INTO lr_nf_sup.*
    FROM nf_sup
   WHERE nf_sup.cod_empresa   = l_empresa
     AND nf_sup.num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DELETE
    FROM nf_sup_erro
   WHERE nf_sup_erro.empresa       = l_empresa
     AND nf_sup_erro.num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM nfe_sup_compl
   WHERE nfe_sup_compl.cod_empresa   = l_empresa
     AND nfe_sup_compl.num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM dest_aviso_rec
   WHERE dest_aviso_rec.cod_empresa   = l_empresa
     AND dest_aviso_rec.num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_ped
   WHERE ar_ped.cod_empresa   = l_empresa
     AND ar_ped.num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_nf_item
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_diverg
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_diverg_provid
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM dev_item
   WHERE cod_empresa = l_empresa
     AND num_nff     = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM sup_nf_devol_cli
   WHERE empresa       = l_empresa
     AND aviso_recebto = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM sup_par_ar
   WHERE empresa       = l_empresa
     AND aviso_recebto = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM sup_complr_nf_sup
   WHERE empresa       = l_empresa
     AND aviso_recebto = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_subst_tribut
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_os_esp
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM aviso_rec
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     WHENEVER ERROR CONTINUE
       INSERT INTO w_sup0552_1(nota_fiscal,
                               serie_nota_fiscal,
                               subserie_nf,
                               espc_nota_fiscal,
                               fornecedor,
                               sequencia,
                               txt_consistencia)
                       VALUES (lr_nf_sup.num_nf        ,
                               lr_nf_sup.ser_nf        ,
                               lr_nf_sup.ssr_nf        ,
                               lr_nf_sup.ies_especie_nf,
                               lr_nf_sup.cod_fornecedor,
                               0,
                               "NOTA FISCAL A SER ALTERADA/EXCLUÍDA NAO ENCONTRADA NA NF_SUP.")
     WHENEVER ERROR STOP
     RETURN FALSE
  END IF

  CALL LOG_setVar("empresa",l_empresa)
  IF sup1031_grava_audit_ar(l_num_aviso_rec,
                              0, ##EXCLUSAO TOTAL DA NOTA FISCAL
                              "SUP0552",
                              "5") THEN
  END IF

  WHENEVER ERROR CONTINUE
  DELETE
    FROM aviso_rec_compl_sq
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM aviso_rec_aux
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM dev_mestre
   WHERE cod_empresa = l_empresa
     AND num_nff     = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM audit_sup_cre
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM ar_frete_cesta
   WHERE cod_empresa   = l_empresa
     AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM item_de_terc
   WHERE cod_empresa    = l_empresa
     AND num_nf         = lr_nf_sup.num_nf
     AND ser_nf         = lr_nf_sup.ser_nf
     AND ssr_nf         = lr_nf_sup.ssr_nf
     AND ies_especie_nf = lr_nf_sup.ies_especie_nf
     AND cod_fornecedor = lr_nf_sup.cod_fornecedor
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE FROM item_de_terc_compl
   WHERE cod_empresa    = l_empresa
     AND num_nf         = lr_nf_sup.num_nf
     AND ser_nf         = lr_nf_sup.ser_nf
     AND ssr_nf         = lr_nf_sup.ssr_nf
     AND ies_especie_nf = lr_nf_sup.ies_especie_nf
     AND cod_fornec_nf  = lr_nf_sup.cod_fornecedor
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE FROM item_de_terc_area
   WHERE cod_empresa    = l_empresa
     AND num_nf         = lr_nf_sup.num_nf
     AND ser_nf         = lr_nf_sup.ser_nf
     AND ssr_nf         = lr_nf_sup.ssr_nf
     AND ies_especie_nf = lr_nf_sup.ies_especie_nf
     AND cod_fornecedor = lr_nf_sup.cod_fornecedor
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM item_dev_terc_comp
   WHERE item_dev_terc_comp.cod_empresa = l_empresa
     AND item_dev_terc_comp.num_nf      = lr_nf_sup.num_nf
     AND item_dev_terc_comp.ser_nf      = lr_nf_sup.ser_nf
     AND item_dev_terc_comp.ssr_nf      = lr_nf_sup.ssr_nf
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  DELETE
    FROM sup_nf_reajus
   WHERE sup_nf_reajus.empresa   = l_empresa
     AND sup_nf_reajus.ar_reajus = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
    DELETE
      FROM sup_nf_fat_remessa
     WHERE sup_nf_fat_remessa.empresa           = l_empresa
       AND sup_nf_fat_remessa.nota_fiscal       = lr_nf_sup.num_nf
       AND sup_nf_fat_remessa.serie_nota_fiscal = lr_nf_sup.ser_nf
       AND sup_nf_fat_remessa.subserie_nf       = lr_nf_sup.ssr_nf
       AND sup_nf_fat_remessa.espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
       AND sup_nf_fat_remessa.fornecedor        = lr_nf_sup.cod_fornecedor
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
    DELETE FROM ar_iss
     WHERE cod_empresa   = l_empresa
       AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
    DELETE FROM nf_sup
     WHERE cod_empresa   = l_empresa
       AND num_aviso_rec = l_num_aviso_rec
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0  THEN

     WHENEVER ERROR CONTINUE
     DELETE
       FROM sup_infc_strib_nfe
      WHERE empresa            = l_empresa
        AND nf_entrada         = lr_nf_sup.num_nf
        AND serie_nf_entrada   = lr_nf_sup.ser_nf
        AND subserie_nfe       = lr_nf_sup.ssr_nf
        AND especie_nf_entrada = lr_nf_sup.ies_especie_nf
        AND fornecedor         = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM vencimento_nff
      WHERE cod_empresa     = l_empresa
        AND num_nf          = lr_nf_sup.num_nf
        AND ser_nf          = lr_nf_sup.ser_nf
        AND ssr_nf          = lr_nf_sup.ssr_nf
        AND cod_fornecedor  = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM nf_sup_aux
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR STOP

     IF lr_nf_sup.ies_especie_nf = "NFM" THEN
        WHENEVER ERROR CONTINUE
        DELETE FROM nf_pend
         WHERE cod_empresa    = l_empresa
           AND num_nf         = lr_nf_sup.num_nf
           AND ser_nf         = lr_nf_sup.ser_nf
           AND ssr_nf         = lr_nf_sup.ssr_nf
           AND cod_fornecedor = lr_nf_sup.cod_fornecedor
        WHENEVER ERROR STOP
     END IF

     IF lr_nf_sup.ies_especie_nf = "NFP" THEN
        WHENEVER ERROR CONTINUE
        DECLARE cq_ar_x_nf_pend4 CURSOR FOR
        SELECT *
          FROM ar_x_nf_pend
         WHERE cod_empresa   = l_empresa
           AND num_aviso_rec = l_num_aviso_rec
        WHENEVER ERROR STOP

        WHENEVER ERROR CONTINUE
        FOREACH cq_ar_x_nf_pend4 INTO lr_ar_x_nf_pend.*
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           EXIT FOREACH
        END IF
           WHENEVER ERROR CONTINUE
             UPDATE nf_pend
                SET qtd_regularizada = qtd_regularizada -
                                       lr_ar_x_nf_pend.qtd_regularizada
              WHERE cod_empresa    = lr_ar_x_nf_pend.cod_empresa
                AND num_nf         = lr_ar_x_nf_pend.num_nf
                AND ser_nf         = lr_ar_x_nf_pend.ser_nf
                AND ssr_nf         = lr_ar_x_nf_pend.ssr_nf
                AND cod_fornecedor = lr_ar_x_nf_pend.cod_fornecedor
                AND cod_item       = lr_ar_x_nf_pend.cod_item
           WHENEVER ERROR STOP

        END FOREACH

        WHENEVER ERROR CONTINUE
          DELETE FROM ar_x_nf_pend
           WHERE cod_empresa    = l_empresa
             AND num_aviso_rec  = l_num_aviso_rec
        WHENEVER ERROR STOP
     END IF

     IF lr_nf_sup.ies_especie_nf = "CON" THEN
        WHENEVER ERROR CONTINUE
        DELETE
          FROM pedagio_frete
         WHERE cod_empresa    = l_empresa
           AND num_nf_conhec  = lr_nf_sup.num_nf
           AND ser_nf_conhec  = lr_nf_sup.ser_nf
           AND ssr_nf_conhec  = lr_nf_sup.ssr_nf
           AND ies_especie_nf = lr_nf_sup.ies_especie_nf
           AND cod_fornecedor = lr_nf_sup_nf_sup.cod_fornecedor
        WHENEVER ERROR STOP
     END IF

     WHENEVER ERROR CONTINUE
     DELETE
       FROM reten_iss
      WHERE cod_empresa    = l_empresa
        AND num_ad_nf_orig = lr_nf_sup.num_nf
        AND ser_nf         = lr_nf_sup.ser_nf
        AND ssr_nf         = lr_nf_sup.ssr_nf
        AND ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM reten_inss
      WHERE cod_empresa    = l_empresa
        AND num_ad_nf_orig = lr_nf_sup.num_nf
        AND ser_nf         = lr_nf_sup.ser_nf
        AND ssr_nf         = lr_nf_sup.ssr_nf
        AND ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_sest_senat
      WHERE empresa           = l_empresa
        AND ad_nf_origem      = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_ret_inss_auton
      WHERE empresa           = l_empresa
        AND ad_nf_origem      = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_ret_inss_compl
      WHERE empresa           = l_empresa
        AND ad_nf_origem      = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_ret_proalminas
      WHERE empresa           = l_empresa
        AND ad_nf_origem      = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_iss_compl
      WHERE empresa           = l_empresa
        AND ad_nota_fiscal    = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM cap_iss_eletronico
      WHERE empresa           = l_empresa
        AND ad_nota_fiscal    = lr_nf_sup.num_nf
        AND serie_nota_fiscal = lr_nf_sup.ser_nf
        AND subserie_nf       = lr_nf_sup.ssr_nf
        AND espc_nota_fiscal  = lr_nf_sup.ies_especie_nf
        AND fornecedor        = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM reten_inss_rur
      WHERE cod_empresa    = l_empresa
        AND num_ad_nf_orig = lr_nf_sup.num_nf
        AND ser_nf         = lr_nf_sup.ser_nf
        AND ssr_nf         = lr_nf_sup.ssr_nf
        AND ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM item_de_terc
      WHERE item_de_terc.cod_empresa    = lr_nf_sup.cod_empresa
        AND item_de_terc.num_nf         = lr_nf_sup.num_nf
        AND item_de_terc.ser_nf         = lr_nf_sup.ser_nf
        AND item_de_terc.ssr_nf         = lr_nf_sup.ssr_nf
        AND item_de_terc.ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND item_de_terc.cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DECLARE cq_ret CURSOR FOR
     SELECT *
       FROM item_ret_terc
      WHERE item_ret_terc.cod_empresa    = lr_nf_sup.cod_empresa
        AND item_ret_terc.num_nf         = lr_nf_sup.num_nf
        AND item_ret_terc.ser_nf         = lr_nf_sup.ser_nf
        AND item_ret_terc.ssr_nf         = lr_nf_sup.ssr_nf
        AND item_ret_terc.ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND item_ret_terc.cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     FOREACH cq_ret INTO lr_item_ret_terc.*
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        EXIT FOREACH
     END IF

         WHENEVER ERROR CONTINUE
           UPDATE item_em_terc
              SET item_em_terc.qtd_tot_recebida = item_em_terc.qtd_tot_recebida -
                                                  lr_item_ret_terc.qtd_devolvida
            WHERE item_em_terc.cod_empresa      = lr_item_ret_terc.cod_empresa
              AND item_em_terc.num_nf           = lr_item_ret_terc.num_nf_remessa
              AND item_em_terc.num_sequencia    = lr_item_ret_terc.num_sequencia_nf
        WHENEVER ERROR STOP

        WHENEVER ERROR CONTINUE
        DELETE
          FROM item_ret_terc
         WHERE item_ret_terc.cod_empresa = lr_item_ret_terc.cod_empresa
           AND num_nf                    = lr_item_ret_terc.num_nf
           AND ser_nf                    = lr_item_ret_terc.ser_nf
           AND ssr_nf                    = lr_item_ret_terc.ssr_nf
           AND ies_especie_nf            = lr_item_ret_terc.ies_especie_nf
           AND cod_fornecedor            = lr_item_ret_terc.cod_fornecedor
           AND num_sequencia_ar          = lr_item_ret_terc.num_sequencia_ar
        WHENEVER ERROR STOP

     END FOREACH

     WHENEVER ERROR CONTINUE
     DELETE
       FROM reten_inss_rur
      WHERE cod_empresa    = l_empresa
        AND num_ad_nf_orig = lr_nf_sup.num_nf
        AND ser_nf         = lr_nf_sup.ser_nf
        AND ssr_nf         = lr_nf_sup.ssr_nf
        AND ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM reten_irrf_pg
      WHERE cod_empresa    = l_empresa
        AND num_nf         = lr_nf_sup.num_nf
        AND ser_nf         = lr_nf_sup.ser_nf
        AND ssr_nf         = lr_nf_sup.ssr_nf
        AND ies_especie_nf = lr_nf_sup.ies_especie_nf
        AND cod_fornecedor = lr_nf_sup.cod_fornecedor
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM nf_sup
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM aviso_rec_compl
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM ar_pis_cofins
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR CONTINUE

     WHENEVER ERROR CONTINUE
       DELETE
         FROM obf_dvcli_piscofin
        WHERE empresa           = l_empresa
          AND aviso_recebto     = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
       DELETE
         FROM obf_p_dvcli_cofins
        WHERE empresa           = l_empresa
          AND aviso_recebto     = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM sup_ar_piscofim
      WHERE empresa       = l_empresa
        AND aviso_recebto = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM sup_fr_pis_cofins
      WHERE empresa       = l_empresa
        AND aviso_recebto = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE
       FROM aviso_rec_proc_imp
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR STOP

     WHENEVER ERROR CONTINUE
     DELETE FROM ar_iss
      WHERE cod_empresa   = l_empresa
        AND num_aviso_rec = l_num_aviso_rec
     WHENEVER ERROR STOP
  END IF

  RETURN TRUE

END FUNCTION


#---------------------------------------------------------------------------#
 FUNCTION sup0552y_envia_email(l_email,
                               l_arquivo_importacao_aux,
                               l_num_aviso_rec,
                               l_dir_arquivo_sup0552,
                               l_nome_arquivo)
#---------------------------------------------------------------------------#
  DEFINE l_comando                              CHAR(300),
         l_servidor_smtp                        CHAR(100),
         l_email                                CHAR(100),
         l_texto                                CHAR(100),
         l_arq_txt                              CHAR(150),
         l_arquivo_importacao_aux               CHAR(200),
         l_anexo                                CHAR(100),
         l_ind                                  SMALLINT,
         l_anexo2                               CHAR(100),
         l_remetente                            CHAR(100),
         l_assunto                              CHAR(100),
         l_arq2                                 CHAR(100),
         l_num_aviso_rec                        LIKE aviso_rec.num_aviso_rec,
         l_dir_arquivo_sup0552                  CHAR(100),
         l_nome_arquivo                         CHAR(100)


   LET l_ind  = 100

   CALL log2250_busca_parametro(p_cod_empresa,"remet_envio_email_erro_sup0552")
      RETURNING l_remetente, p_status

   IF p_status = FALSE
   OR l_remetente IS NULL
   OR l_remetente = " " THEN
      LET l_remetente = "portaltupy@tupy.com.br"
   END IF

   LET l_assunto   = "Retorno de Envio Notas Fiscais"
   LET l_servidor_smtp = fgl_getenv("SMTP_SERVER")


   CALL sup0552Y_grava_audit_email(l_email,l_num_aviso_rec, l_nome_arquivo)
   ##JAVA ENVIA PARA RELATÓRIOS EM HTML
   LET l_comando = "java Envia ",
                   l_servidor_smtp CLIPPED," ",
                   "'",l_remetente CLIPPED,"' ",
                   "'",l_email CLIPPED,"'  ",
                   "'",l_assunto CLIPPED,"' ",
                   "'",l_arquivo_importacao_aux CLIPPED,"'",
                   "  1  "

   CALL CONOUT ("## l_comando: ", l_comando)


   RUN l_comando CLIPPED

   #move arquivo para pasta de arquivos processados ou com erros

   LET l_comando = "mv ", l_arquivo_importacao_aux CLIPPED, " ", l_dir_arquivo_sup0552 CLIPPED
   RUN l_comando
   #COMANDO ABAIXO APAGAVA OS HTMLS GERADOS.
   #WHENEVER ERROR CONTINUE
   #   LET g_comando = "rm ", l_arquivo_importacao_aux
   #   RUN g_comando
   #WHENEVER ERROR STOP

END FUNCTION

#----------------------------------------#
 FUNCTION sup0552y_before_insert_nf_sup()
#----------------------------------------#

  RETURN TRUE

END FUNCTION

#--------------------------------------#
 REPORT sup0552y_relat2(lr_importados)
#--------------------------------------#
   DEFINE lr_importados     RECORD
                               nota_fiscal         DECIMAL(6,0),
                               serie_nota_fiscal   CHAR(03),
                               subserie_nf         DECIMAL(2,0),
                               espc_nota_fiscal    CHAR(03),
                               fornecedor          CHAR(15),
                               num_aviso_rec       DECIMAL(7,0)
                            END RECORD

   DEFINE l_den_empresa     LIKE empresa.den_empresa


   OUTPUT LEFT   MARGIN  0
          TOP    MARGIN  0
          BOTTOM MARGIN  1
   FORMAT
   PAGE HEADER

        LET l_den_empresa = NULL
        WHENEVER ERROR CONTINUE
          SELECT empresa.den_empresa
            INTO l_den_empresa
            FROM empresa
           WHERE empresa.cod_empresa = p_cod_empresa
        WHENEVER ERROR STOP

        PRINT "<HTML> <HEAD> <TITLE>Retorno </TITLE>"
        PRINT "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
        PRINT "<META content='MSHTML 6.00.2900.2912' name=GENERATOR>"
        PRINT "</HEAD><BODY> <TABLE border=0> <TBODY>"
        PRINT "<TR>"
        PRINT "<TD width='100%'&nbsp;>"
        PRINT "</TR></TBODY></TABLE>"
        PRINT "<P align=middle>"
        PRINT "<TABLE borderColor=#0000a0 cellSpacing=0 cellPadding=4 width='100%' bgColor=#c1e0ff border=2>"
        PRINT "<TBODY>"
        PRINT "<TR><TD align=middle>"
        PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=#0000a0 size=2>"
        PRINT "<STRONG>NOTAS FISCAIS IMPORTADAS</STRONG>"
        PRINT "</FONT> </TD> </TR> </TBODY> </TABLE>"
        PRINT "<P align=middle>"
        PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=navy size=2>"
        PRINT " SR. FORNECEDOR INFORMAMOS QUE A NOTA FISCAL ABAIXO FOI RECEBIDA"
        PRINT " COM EXITO, SEM INCONSISTÊNCIAS E JÁ CONSTA EM NOSSO BANCO DE DADOS</BR>"
        PRINT "<HR> <STRONG> <PRE> <FONT color=navy size=3>"

        PRINT COLUMN 001,"NOTA FISCAL..: ",lr_importados.nota_fiscal USING "#####&"
        PRINT COLUMN 001,"SERIE........: ",lr_importados.serie_nota_fiscal
        PRINT COLUMN 001,"SUB-SERIE....: ",lr_importados.subserie_nf USING "#&"
        PRINT COLUMN 001,"ESPECIE......: ",lr_importados.espc_nota_fiscal
        PRINT COLUMN 001,"TIPO DE REG..: NOTA/FRETE"
        PRINT COLUMN 001,"EMPRESA......: ",p_cod_empresa," - ",l_den_empresa
        PRINT COLUMN 001,"FORNECEDOR...: ",lr_importados.fornecedor
        PRINT COLUMN 001,"SITUAÇÃO.....: NOTA FISCAL IMPORTADA COM SUCESSO"

        PRINT "</FONT> </PRE> </STRONG> </FONT>"
        PRINT "<TABLE borderColor=#0000a0 cellSpacing=0 cellPadding=4 width='100%'bgColor=#c1e0ff border=2>"
        PRINT "<TBODY> <TR>"
        PRINT "<TD align=left><FONT face='Verdana, Arial, Helvetica, sans-serif'color=#0000a0 size=2>"
        PRINT "<STRONG>O NUMERO DE AR GERADO FOI: "
        PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=#0000a0 size=4>",lr_importados.num_aviso_rec,"</STRONG>"
        PRINT "</FONT> </TD> </TR> </TBODY> </TABLE> </FONT>"
        PRINT "<BR><BR>"
        PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=red size=2>"
        PRINT "<STRONG>IMPORTANTE: Anexe este à Nota Fiscal para facilitar a entrega do seu material.</STRONG>"
        PRINT "</FONT>"
        PRINT "<BR><BR>"
        PRINT "</HEAD> </HTML>"


END REPORT

#------------------------------------------#
 REPORT sup0552y_relat_ret(lr_consistencia)
#------------------------------------------#
DEFINE lr_consistencia   RECORD
                          nota_fiscal       DECIMAL(6,0),
                          serie_nota_fiscal CHAR(03),
                          subserie_nf       DECIMAL(2,0),
                          espc_nota_fiscal  CHAR(03),
                          fornecedor        CHAR(15),
                          sequencia         DECIMAL(3,0),
                          txt_consistencia  CHAR(59)
                          END RECORD

 DEFINE l_den_empresa  LIKE empresa.den_empresa,
        l_last_row     SMALLINT

 OUTPUT LEFT   MARGIN  0
        TOP    MARGIN  0
        BOTTOM MARGIN  1


 FORMAT
 PAGE HEADER

      LET l_den_empresa = NULL
      WHENEVER ERROR CONTINUE
        SELECT empresa.den_empresa
          INTO l_den_empresa
          FROM empresa
         WHERE empresa.cod_empresa = p_cod_empresa
      WHENEVER ERROR STOP

      PRINT "<HTML> <HEAD> <TITLE>Retorno </TITLE>"
      PRINT "<META http-equiv=Content-Type content='text/html; charset=windows-1252'>"
      PRINT "<META content='MSHTML 6.00.2900.2912' name=GENERATOR>"
      PRINT "</HEAD><BODY> <TABLE border=0> <TBODY>"
      PRINT "<TR>"
      PRINT "<TD width='100%'&nbsp;>"
      PRINT "</TR></TBODY></TABLE>"
      PRINT "<P align=middle>"
      PRINT "<TABLE borderColor=#0000a0 cellSpacing=0 cellPadding=4 width='100%' bgColor=#c1e0ff border=2>"
      PRINT "<TBODY>"
      PRINT "<TR><TD align=middle>"
      PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=#0000a0 size=2>"
      PRINT "<STRONG>CONSISTENCIAS NA IMPORTACAO DE NOTAS FISCAIS</STRONG>"
      PRINT "</FONT> </TD> </TR> </TBODY> </TABLE>"
      PRINT "<P align=middle>"
      PRINT "<FONT face='Verdana, Arial, Helvetica, sans-serif'color=NAVY size=2>"
      PRINT " SR. FORNECEDOR INFORMAMOS QUE A NOTA FISCAL FOI RECEBIDA"
      PRINT " POREM NAO PODE SER IMPORTADA DEVIDO OS ERROS ABAIXO:</BR>"
      PRINT "<HR> <STRONG> <PRE> <FONT color=navy size=3>"

      PRINT COLUMN 001,"NOTA FISCAL..: ",lr_consistencia.nota_fiscal USING "<<<<<<<"
      PRINT COLUMN 001,"SERIE........: ",lr_consistencia.serie_nota_fiscal
      PRINT COLUMN 001,"SUB-SERIE....: ",lr_consistencia.subserie_nf
      PRINT COLUMN 001,"ESPECIE......: ",lr_consistencia.espc_nota_fiscal
      PRINT COLUMN 001,"EMPRESA......: ",p_cod_empresa," - ",l_den_empresa
      PRINT COLUMN 001,"FORNECEDOR...: ",lr_consistencia.fornecedor

 ON EVERY ROW
      PRINT COLUMN 001,"</BR>ERRO.........: ",lr_consistencia.sequencia USING "&&&"," - ",
                         lr_consistencia.txt_consistencia

 ON LAST ROW
      PRINT "</FONT> </PRE> </STRONG> </FONT>"
      PRINT "<TABLE borderColor=#0000a0 cellSpacing=0 cellPadding=4 width='100%'bgColor=#c1e0ff border=2>"
      PRINT "<TBODY> <TR>"
      PRINT "<TD align=left><FONT face='Verdana, Arial, Helvetica, sans-serif'color=#0000a0 size=2>"
      PRINT "<STRONG>FIM</STRONG>"
      PRINT "</TD> </TR> </TBODY> </TABLE> </FONT>"
      PRINT "</HEAD> </HTML>"

END REPORT

#-------------------------------#
 FUNCTION sup0552y_version_info()
#-------------------------------#

  RETURN "$Archive: /especificos/logix10R2/tupy_sa/suprimentos/suprimentos/funcoes/sup0552y.4gl $|$Revision: 3 $|$Date: 17/03/11 14:33 $|$Modtime: 16/03/11 17:03 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION

#------------------------------------------------------------#
FUNCTION sup0552Y_grava_audit_email(l_email, l_num_aviso_rec, l_nome_arquivo)
#------------------------------------------------------------#
DEFINE l_email         CHAR(100),
       l_cod_parametro LIKE par_sup_pad.cod_parametro,
       l_num_aviso_rec LIKE aviso_rec.num_aviso_rec,
       l_nome_arquivo  CHAR(100),
       l_msg           LIKE par_sup_pad.par_txt


 IF l_num_aviso_rec IS NOT NULL AND
    l_num_aviso_rec <> ' ' THEN
    LET l_cod_parametro = 'sup0552_email', l_num_aviso_rec CLIPPED
    LET l_msg =  'AR COM ENVIO DE EMAIL EFETIVADO' CLIPPED
 ELSE
    LET l_cod_parametro = 'sup0552_',l_nome_arquivo CLIPPED
    LET l_msg =  'ENVIO DE E-MAIL COM ERRO' CLIPPED
 END IF


 WHENEVER ERROR CONTINUE
 INSERT INTO par_sup_pad(cod_empresa  ,
                         cod_parametro,
                         den_parametro,
                         par_ies      ,
                         par_txt      ,
                         par_val      ,
                         par_num      ,
                         par_data)
                 VALUES (p_cod_empresa,
                         l_cod_parametro,
                         l_msg,
                         NULL,
                         l_email[1,60],
                         l_num_aviso_rec,
                         NULL,
                         CURRENT)
 WHENEVER ERROR STOP


END FUNCTION
