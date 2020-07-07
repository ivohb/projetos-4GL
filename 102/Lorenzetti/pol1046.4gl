#-------------------------------------------------------------------#
# PROGRAMA: pol1046                                                 #
# OBJETIVO: CONTABILIZACAO NF/FRETE DE IMPORTACAO - LORENZETTI      #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 01/07/2010                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_emp_plano      LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_msg                CHAR(300),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_query              CHAR(600),
          p_where              CHAR(600),
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_ies_erro           char(01),
          p_nom_resp           char(10),
          p_num_transac        INTEGER,
          p_num_conta          CHAR(23),
          p_ies_icms_frete     CHAR(01)

   DEFINE p_tip_nf             DECIMAL(2,0),
          p_tributo            CHAR(30),
          p_conta_cred         CHAR(23),
          p_conta_deb          CHAR(23),
          p_cod_tip_item       DECIMAL(2,0),
          p_amostra            CHAR(01),
          p_flag_cont          CHAR(01),
          p_dat_entrada        date


   DEFINE p_lanc        RECORD LIKE lanc_cont_rec.*

   DEFINE p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_num_nf             LIKE nf_sup.num_nf,
          p_ser_nf             LIKE nf_sup.ser_nf,
          p_ssr_nf             LIKE nf_sup.ssr_nf,
          p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          p_num_ar             LIKE nf_sup.num_aviso_rec,
          p_especie            LIKE nf_sup.ies_especie_nf,
          p_num_conhec         LIKE nf_sup.num_conhec,
          p_ser_conhec         LIKE nf_sup.ser_conhec,
          p_ssr_conhec         LIKE nf_sup.ssr_conhec,
          p_cod_transpor       LIKE nf_sup.cod_transpor,
          p_val_ipi            LIKE aviso_rec.val_ipi_decl_item,
          p_val_ipi_c          LIKE aviso_rec.val_ipi_calc_item,
          p_val_icms           LIKE aviso_rec.val_icms_item_d,
          p_val_icms_c         LIKE aviso_rec.val_icms_item_c,
          p_val_frete          LIKE aviso_rec.val_frete,
          p_val_dif            LIKE aviso_rec.val_frete,
          p_icm_frete          LIKE aviso_rec.val_icms_frete_c,
          p_icm_frete_d        LIKE aviso_rec.val_icms_frete_c,
          p_icm_frete_c        LIKE aviso_rec.val_icms_frete_c,
          p_val_frete_outros   LIKE sup_frete_x_nf_entrada.val_frete,
          p_icms_outros_fr     LIKE sup_frete_x_nf_entrada.val_icms_frete_calculado,
          p_val_icms_da        LIKE aviso_rec.val_icms_desp_aces,
          p_pis_frete          LIKE sup_fr_pis_cofins.val_pis_declarado,
          p_cofins_frete       LIKE sup_fr_pis_cofins.val_cofins_decl,
          p_val_liquido        LIKE aviso_rec.val_liquido_item,
          p_val_contabil       LIKE aviso_rec.val_contabil_item,
          p_item_estoq         LIKE aviso_rec.ies_item_estoq,
          p_tip_despesa        LIKE aviso_rec.cod_tip_despesa,
          p_num_seq            LIKE aviso_rec.num_seq,
          p_val_pis            LIKE ar_pis_cofins.val_pis_d,
          p_val_cofins         LIKE ar_pis_cofins.val_cofins_d,
          p_cod_item           LIKE item.cod_item,
          p_val_lanc           LIKE lanc_cont_rec.val_lanc

   DEFINE pr_contab            ARRAY[4000] OF RECORD
          cod_emp              char(02),
          num_ar               decimal(9,0),
          den_erro             char(80)
   END RECORD

END GLOBALS

   DEFINE m_max_num_relacionto   INTEGER
   DEFINE m_sequencia_registro   INTEGER
   DEFINE m_periodo_contab       LIKE ctb_lanc_ctbl_recb.periodo_contab
   DEFINE m_segmto_periodo       LIKE ctb_lanc_ctbl_recb.segmto_periodo
   DEFINE m_hist_padrao          LIKE ctb_lanc_ctbl_recb.hist_padrao


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1046-10.02.01"
   INITIALIZE p_nom_help TO NULL
   CALL log140_procura_caminho("pol1046.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1046_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1046_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1046") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1046 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informa parâmetros p/ o processamento"
         CALL pol1046_edita_dados() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso!'
            NEXT OPTION 'Processar'
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada!'
            NEXT OPTION 'Fim'
         END IF
      COMMAND "Processar" "Processa a contabilização"
         IF p_ies_cons THEN
            CALL pol1046_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso!'
            ELSE
               ERROR 'Operação cancelada!'
            END IF
            NEXT OPTION 'Fim'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Consultar" "Exibe erros encontrados na contabilização"
         CALL pol1046_erros() RETURNING p_status
         IF p_status THEN
            ERROR 'Consulta efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1046_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol1046

END FUNCTION

#-----------------------#
FUNCTION pol1046_sobre()
#-----------------------#

   DEFINE p_dat DATETIME YEAR TO SECOND

   LET p_dat = CURRENT

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Alteração: ",p_dat,"\n\n",
               " LOGIX 10.02 \n\n",
               " Home page: www.aceex.com.br \n\n",
               " (0xx11) 4991-6667 \n\n"

   CALL log0030_mensagem(p_msg,'excla')

END FUNCTION

#-------------------------------#
FUNCTION pol1046_le_parametros()
#-------------------------------#
   SELECT cod_empresa_plano
     INTO p_cod_emp_plano
     FROM par_con
    WHERE cod_empresa = p_cod_empresa

   if p_cod_emp_plano is null or p_cod_emp_plano = ' ' THEN
      LET p_cod_emp_plano = p_cod_empresa
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','emp_orig_destino')
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
      SELECT par_val
        INTO m_hist_padrao
        FROM par_sup_pad
       WHERE cod_empresa   = p_cod_emp_plano
         AND cod_parametro = "cod_hist_receb"
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("SELECT", "PAR_SUP_PAD")
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#-----------------------------#
FUNCTION pol1046_edita_dados()
#-----------------------------#

   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   LET INT_FLAG = FALSE

   INPUT p_dat_ini, p_dat_fim
      WITHOUT DEFAULTS FROM dat_ini, dat_fim

      AFTER FIELD dat_ini

         IF p_dat_ini IS NULL THEN
            ERROR ' Campo com preenchimento obrigatório!'
            NEXT FIELD dat_ini
         END IF

      AFTER FIELD dat_fim

         IF p_dat_fim IS NULL THEN
            ERROR ' Campo com preenchimento obrigatório!'
            NEXT FIELD dat_fim
         END IF

         IF p_dat_ini > p_dat_fim THEN
            ERROR " Data Inicial nao pode ser maior que data Final"
            NEXT FIELD dat_ini
         END IF

      AFTER INPUT
         IF INT_FLAG = 0 THEN
            IF MONTH(p_dat_ini) <> MONTH(p_dat_fim) THEN
               ERROR " Período deve compreender apenas um mês."
               NEXT FIELD dat_ini
            END IF
         END IF
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1046_prende_registro()
#----------------------------------#

   DECLARE cq_prende CURSOR FOR

    SELECT cod_empresa
      FROM nf_sup
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
       FOR UPDATE

    OPEN cq_prende
   FETCH cq_prende

   IF STATUS = 0 THEN
      RETURN TRUE
   END IF

   LET p_msg = STATUS
   LET p_msg = 'Erro ',p_msg CLIPPED,' bloqueando NF ',p_num_nf,
               ' na tab nf_sup'
   CLOSE cq_prende

   RETURN FALSE

END FUNCTION

#--------------------------#
FUNCTION pol1046_processar()
#--------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL pol1046_proc_notas() RETURNING p_status

   CALL pol1046_proc_frete() RETURNING p_status

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1046_proc_notas()
#----------------------------#
DEFINE l_count_itens_cred SMALLINT 

  LET l_count_itens_cred = 0

   DECLARE cq_nf CURSOR WITH HOLD FOR
    SELECT a.cod_empresa,
           a.num_nf,
           a.ser_nf,
           a.ssr_nf,
           a.dat_entrada_nf,
           a.ies_especie_nf,
           a.num_aviso_rec,
           a.cod_fornecedor,
           b.tiponf,
           b.amostr
      FROM nf_sup a,
           easy:ei10 b,
           aviso_rec_compl c
     WHERE a.cod_empresa   = b.codemp
       AND a.num_aviso_rec = b.nferp
       AND a.num_aviso_rec = c.num_aviso_rec
       AND a.cod_empresa   = c.cod_empresa
       AND a.ies_incl_contab = 'N'
       AND a.dat_entrada_nf >= p_dat_ini
       AND a.dat_entrada_nf <= p_dat_fim
       AND (a.ies_nf_com_erro = "N" OR a.nom_resp_aceite_er <> ' ')
       AND a.ies_nf_aguard_nfe = '6'
       AND c.ies_situacao <> 'C'

   FOREACH cq_nf into
           p_cod_empresa,
           p_num_nf,
           p_ser_nf,
           p_ssr_nf,
           p_dat_entrada,
           p_especie,
           p_num_ar,
           p_cod_fornecedor,
           p_tip_nf,
           p_amostra

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo notas ',
                     'das tabelas logix.nf_sup e easy.ei10'
         CALL pol1046_insere_erro() RETURNING p_status
         RETURN FALSE
      END IF

      SELECT count(num_seq)
        into p_count
        from nf_sup_erro
       where empresa = p_cod_empresa
         and num_aviso_rec = p_num_ar
         and des_pendencia_item = 'Falta imprimir a NFE'

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo erros ',
                     'da tabela logix.nf_sup_erro'
         CALL pol1046_insere_erro() RETURNING p_status
         RETURN FALSE
      END IF

      if p_count > 0 then
         LET p_msg = 'Falta imprimir a NFE do AR ', p_num_ar
         CALL pol1046_insere_erro() RETURNING p_status
         CONTINUE FOREACH
      end if

### Conforme solicitacao do Ze Carlos em 27/01/2012 nf de amostra passa a contabilizar o IPI/ICMS SE A INCIDENCIA FOR CREDITO ###

      IF p_amostra = 'S' THEN
         SELECT COUNT(*)
          INTO  l_count_itens_cred
          FROM  aviso_rec
          WHERE cod_empresa   = p_cod_empresa
          AND   num_aviso_rec = p_num_ar
          AND   (ies_tip_incid_ipi = 'C' OR   
                 ies_incid_icms_ite = 'C')
         IF l_count_itens_cred = 0 THEN 
            IF NOT pol1046_atualiza_nf_sup('L') THEN
                   RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF
      END IF  
      
      IF NOT pol1046_le_parametros() THEN
         RETURN
      END IF

      CALL log085_transacao("BEGIN")

      IF NOT pol1046_prende_registro() THEN
         CALL log085_transacao("ROLLBACK")
         CALL pol1046_insere_erro() RETURNING p_status
         CONTINUE FOREACH
      END IF

      IF NOT pol1046_contabiliza_nf() THEN
         CALL log085_transacao("ROLLBACK")
         CALL pol1046_insere_erro() RETURNING p_status
      ELSE
         CALL log085_transacao("COMMIT")
      END IF

      CLOSE cq_prende

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1046_contabiliza_nf()
#-------------------------------#

   DELETE FROM erro_contab_912
    WHERE cod_empresa = p_cod_empresa
      AND (num_ar = p_num_ar OR num_ar IS NULL)

   LET p_flag_cont          = 'N'
   LET p_num_transac        = 0
   LET m_sequencia_registro = 0
   LET p_ies_icms_frete     = 'N'

   DECLARE cq_ar CURSOR FOR
    SELECT val_ipi_decl_item,
           val_ipi_calc_item,
           val_icms_item_d,
           val_icms_item_c,
           val_icms_desp_aces,
           val_liquido_item,
           val_contabil_item,
           ies_item_estoq,
           cod_tip_despesa,
           num_seq,
           cod_item
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar

   FOREACH cq_ar INTO
           p_val_ipi,
           p_val_ipi_c,
           p_val_icms,
           p_val_icms_c,
           p_val_icms_da,
           p_val_liquido,
           p_val_contabil,
           p_item_estoq,
           p_tip_despesa,
           p_num_seq,
           p_cod_item

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo AR ',p_num_ar,
                     ' da tab aviso_rec'
         RETURN FALSE
      END IF

### Conforme solicitacao do Ze Carlos em 30/01/2012 nf de amostra nao contabiliza PIS/COFINS ###      

      IF p_amostra = 'N' THEN 
         SELECT val_pis_d,
                val_cofins_d
           INTO p_val_pis,
                p_val_cofins
           FROM ar_pis_cofins
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_num_ar
            AND num_seq       = p_num_seq

         IF STATUS = 100 THEN
            LET p_val_pis = 0
            LET p_val_cofins = 0
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = STATUS
               LET p_msg = 'Erro ',p_msg CLIPPED,' lendo pis/cofins do AR ',p_num_ar,
                           ' da tab ar_pis_cofins'
               RETURN FALSE
            END IF
         END IF
      END IF  

      IF NOT pol1046_le_tip_desp() then
         RETURN false
      END IF

      DECLARE cq_contas CURSOR FOR
       SELECT tributo,
              num_conta_cred,
              num_conta_deb
         FROM contas_912
        WHERE cod_empresa  = p_cod_empresa
          AND cod_tip_nf   = p_tip_nf
          AND cod_tip_item = p_cod_tip_item
          AND tributo      <> 'val_frete'
          AND tributo      <> 'val_icms_frete'
          AND (LENGTH(num_conta_cred) > 0  OR
               LENGTH(num_conta_deb)  > 0)

      FOREACH cq_contas INTO
              p_tributo,
              p_conta_cred,
              p_conta_deb

         IF STATUS <> 0 THEN
            LET p_msg = STATUS
            LET p_msg = 'Erro ',p_msg CLIPPED,' lendo tabela contas_912 ',
                        'para tipo_nf ',p_tip_nf,',tipo_item ',p_cod_tip_item
            RETURN FALSE
         END IF

         
         IF p_tributo = 'val_ipi' THEN
            IF p_val_ipi = 0 THEN
               IF  p_val_ipi_c > 0 THEN
                   LET p_val_ipi = p_val_ipi_c
               END IF
            END if
            If p_val_ipi > 0 then
               IF  NOT pol1046_ins_lanc(p_val_ipi) THEN
                   RETURN FALSE
               END IF
            END IF
         END IF

         IF p_tributo = 'val_icms' THEN
            IF p_val_icms = 0 THEN
               LET p_val_icms = p_val_icms_c
            END if
            LET p_val_icms = p_val_icms + p_val_icms_da
            IF p_val_icms > 0 THEN
               IF NOT pol1046_ins_lanc(p_val_icms) THEN
                  RETURN FALSE
               END IF
            END IF
         END IF

         IF p_amostra = 'N' THEN 
            IF p_tributo = 'val_pis' THEN
               IF p_val_pis > 0 THEN
                  IF NOT pol1046_ins_lanc(p_val_pis) THEN
                     RETURN FALSE
                  END IF
               END IF
            END IF
            IF p_tributo = 'val_cofins' THEN
               IF p_val_cofins > 0 THEN
                  IF NOT pol1046_ins_lanc(p_val_cofins) THEN
                     RETURN FALSE
                  END IF
               END IF
            END IF
            IF p_tributo = 'val_liquido' THEN
               IF p_val_liquido > 0 THEN
                  IF NOT pol1046_ins_lanc(p_val_liquido) THEN
                     RETURN FALSE
                  END IF
               END IF
            END IF
            IF p_tributo = 'val_contabil' THEN
               IF p_val_contabil > 0 THEN
                  IF NOT pol1046_ins_lanc(p_val_contabil) THEN
                     RETURN FALSE
                  END IF
               END IF
            END IF
         END IF  
      END FOREACH

   END FOREACH

   IF NOT pol1046_fecha_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT pol1046_atualiza_nf_sup('S') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1046_le_tip_desp()
#-----------------------------#

      SELECT cod_tip_ad
        INTO p_cod_tip_item
        FROM tipo_despesa_compl
       WHERE cod_empresa     = p_cod_emp_plano
         AND cod_tip_despesa = p_tip_despesa

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo tipo de item ',p_tip_despesa,
                     ' da tab tipo_despesa_compl'
         RETURN FALSE
      END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1046_fecha_lanc()
#---------------------------#

   DEFINE p_val_cred LIKE lanc_cont_rec.val_lanc,
          p_val_deb  LIKE lanc_cont_rec.val_lanc,
          p_val_tol  LIKE lanc_cont_rec.val_lanc,
          p_dif      LIKE lanc_cont_rec.val_lanc,
          p_val_lanc LIKE lanc_cont_rec.val_lanc

   select val_tol_contab
     into p_val_tol
     from parametros_912
    where cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' lendo tolerância na tab parametros_912 - empresa:',p_cod_empresa
      RETURN FALSE
   END IF

   if p_val_tol is null then
      let p_val_tol = 0
   end if

   SELECT SUM(val_lanc)
     INTO p_val_cred
     FROM lanc_cont_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND ies_tipo_lanc  = 'C'

   IF p_val_cred IS NULL THEN
      LET p_val_cred = 0
   END IF

   SELECT SUM(val_lanc)
     INTO p_val_deb
     FROM lanc_cont_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND ies_tipo_lanc  = 'D'

   IF p_val_deb IS NULL THEN
      LET p_val_deb = 0
   END IF

   IF p_val_deb = p_val_cred THEN
      RETURN true
   end if

   let p_dif = p_val_deb - p_val_cred

   if p_dif < 0 then
      let p_dif = p_dif * -1
   end if

   IF p_dif > p_val_tol THEN
      IF p_val_deb > p_val_cred THEN
         LET p_msg = 'Lanc a debito maior que a credito - ',p_val_deb
         LET p_msg = p_msg CLIPPED, ' X ', p_val_cred
      ELSE
         LET p_msg = 'Lanc a debito menor que a credito - ',p_val_deb
         LET p_msg = p_msg CLIPPED, ' X ', p_val_cred
      END IF
      CALL pol1046_insere_erro() RETURNING p_status
      RETURN true
   END IF

   SELECT val_lanc
     into p_val_lanc
     from lanc_cont_rec
    where cod_empresa = p_cod_empresa
      and num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' lendo lancamento da mercadoria na tab lanc_cont_rec - AR:',p_num_ar
      RETURN FALSE
   END IF

   IF p_val_deb > p_val_cred THEN
      let p_val_lanc = p_val_lanc - p_dif
   else
      let p_val_lanc = p_val_lanc + p_dif
   end if

   if p_val_lanc < 0 then
      LET p_msg = 'Diferença entre debito e credito maior que valor lanc da mercadoria'
      CALL pol1046_insere_erro() RETURNING p_status
      RETURN true
   END IF

   update lanc_cont_rec
      set val_lanc = p_val_lanc
    where cod_empresa = p_cod_empresa
      and num_transac = p_num_transac

   IF sqlca.sqlcode <> 0 OR sqlca.sqlerrd[3] <> 1 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' atualizando lancamento da mercadoria na tab lanc_cont_rec - AR:',p_num_ar
      RETURN FALSE
   END IF

   WHENEVER ERROR CONTINUE
      UPDATE ctb_lanc_ctbl_recb
         SET val_lancto = p_val_lanc
       WHERE empresa_origem     = p_cod_empresa
         AND sequencia_registro = m_sequencia_registro
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 OR sqlca.sqlerrd[3] <> 1 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' atualizando lancamento da mercadoria na tab ctb_lanc_ctbl_recb - AR:',p_num_ar
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1046_atualiza_nf_sup(p_falg)
#--------------------------------------#

   DEFINE p_falg  CHAR(01)

   UPDATE nf_sup
      SET ies_incl_contab = p_falg
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
   
   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' atualizando NF ',p_num_nf,
                  ' na tab nf_sup'
      RETURN FALSE
   END IF
   
   IF  p_falg = "L" THEN 
       UPDATE aviso_rec
       SET    ies_contabil="N"
       WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_num_ar
   
       IF STATUS <> 0 THEN
          LET p_msg = STATUS
          LET p_msg = 'Erro ',p_msg CLIPPED,' atualizando NF ',p_num_nf,
                      ' na tab aviso_rec'
          RETURN FALSE
       END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1046_atu_frete_sup(p_falg)
#--------------------------------------#

   DEFINE p_falg  CHAR(01)

   UPDATE frete_sup
      SET ies_incl_contab = p_falg
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_cod_transpor
      AND num_conhec   = p_num_conhec
      AND ser_conhec   = p_ser_conhec
      AND ssr_conhec   = p_ssr_conhec

   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' atualizando conhec ',p_num_conhec,
                  ' na tab frete_sup'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1046_troca_conta()
#-----------------------------#

   SELECT num_conta
     INTO p_num_conta
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' lendo conta da tab item_sup ',
                  'p/ empresa ',p_cod_empresa, ' e item ',p_cod_item
      RETURN FALSE
   END IF

   IF p_conta_cred IS NOT NULL THEN
      LET p_conta_cred = p_num_conta
   END IF

   IF p_conta_deb IS NOT NULL THEN
      LET p_conta_deb = p_num_conta
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol1046_ins_lanc(p_val_tributo)
#---------------------------------------#

   DEFINE p_val_tributo LIKE lanc_cont_rec.val_lanc,
          p_tot_lanc    LIKE lanc_cont_rec.val_lanc,
          p_pct_partic  DECIMAL(5,2),
          p_qtd_partic  INTEGER,
          p_troca_cred  SMALLINT,
          p_troca_deb   SMALLINT

   INITIALIZE p_lanc TO NULL

   LET p_tot_lanc   = 0
   LET p_qtd_partic = 0

   LET p_lanc.cod_empresa      = p_cod_empresa

   if p_flag_cont = 'N' then
      LET p_lanc.num_nf           = p_num_nf
      LET p_lanc.ser_nf           = p_ser_nf
      LET p_lanc.ssr_nf           = p_ssr_nf
      LET p_lanc.cod_fornecedor   = p_cod_fornecedor
      LET p_lanc.num_aviso_rec    = p_num_ar
      LET p_lanc.num_seq          = p_num_seq
      LET p_lanc.ies_item_estoq   = p_item_estoq
   else
      LET p_lanc.num_nf           = p_num_conhec
      LET p_lanc.ser_nf           = p_ser_conhec
      LET p_lanc.ssr_nf           = p_ssr_conhec
      LET p_lanc.cod_fornecedor   = p_cod_transpor
      LET p_lanc.num_aviso_rec    = 0
      LET p_lanc.num_seq          = 0
      LET p_lanc.ies_item_estoq   = "N"
   end if

   LET p_lanc.ies_especie      = p_especie
   LET p_lanc.num_lote_lanc    = 0
   LET p_lanc.ies_cnd_pgto     = 'S'
   LET p_lanc.dat_lanc         = p_dat_entrada
   LET p_lanc.num_lote_pat     = 0
   LET p_lanc.num_transac      = 0

   SELECT COUNT(pct_particip_comp)
     INTO p_count
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND num_seq       = p_num_seq

   IF p_count IS NULL OR
      p_count = 0 THEN
      LET p_msg = 'Tabela dest_aviso_rec sem conteudo para ',
                  'empresa ',p_cod_empresa,' AR ',p_num_ar,' e seq ',p_num_seq
      RETURN FALSE
   END IF

   IF p_conta_cred = "ITEM_SUP" THEN
      LET p_troca_cred = TRUE
   END IF

   IF p_conta_deb = "ITEM_SUP" THEN
      LET p_troca_deb = TRUE
   END IF

   DECLARE cq_area CURSOR FOR
    SELECT cod_area_negocio,
           cod_lin_negocio,
           pct_particip_comp,
           num_conta_deb_desp
      FROM dest_aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
       AND num_seq       = p_num_seq

   FOREACH cq_area INTO
           p_lanc.cod_area_negocio,
           p_lanc.cod_lin_negocio,
           p_pct_partic,
           p_num_conta

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo tabela dest_aviso_rec para ',
                     'empresa ',p_cod_empresa,' AR ',p_num_ar,' e seq ',p_num_seq
         RETURN FALSE
      END IF

      IF p_troca_cred THEN
         LET p_conta_cred = p_num_conta
      END IF

      IF p_troca_deb THEN
         LET p_conta_deb = p_num_conta
      END IF

      LET p_qtd_partic = p_qtd_partic + 1

      LET p_val_lanc = p_val_tributo * p_pct_partic / 100
      LET p_tot_lanc = p_tot_lanc + p_val_lanc

      IF p_qtd_partic = p_count THEN
         LET p_lanc.val_lanc = p_val_lanc + (p_val_tributo - p_tot_lanc)
      ELSE
         LET p_lanc.val_lanc = p_val_lanc
      END IF

      IF p_conta_cred IS NULL OR p_conta_cred = ' ' THEN
      ELSE
         LET p_lanc.num_conta_cont = p_conta_cred
         LET p_lanc.ies_tipo_lanc  = 'C'
         IF NOT pol1046_ins_conta() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_conta_deb IS NULL OR p_conta_deb = ' ' THEN
      ELSE
         LET p_lanc.num_conta_cont = p_conta_deb
         LET p_lanc.ies_tipo_lanc  = 'D'
         IF NOT pol1046_ins_conta() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1046_ins_conta()
#---------------------------#
   DEFINE p_texto             CHAR(39),
          p_txt_compl         CHAR(10),
          l_cta_deb           LIKE ctb_lanc_ctbl_recb.cta_deb,
          l_cta_cre           LIKE ctb_lanc_ctbl_recb.cta_cre

   select den_conta
     into p_lanc.tex_hist_lanc
     from plano_contas
    where cod_empresa = p_cod_emp_plano
      and num_conta_reduz = p_lanc.num_conta_cont

   if status <> 0 then
      let p_lanc.tex_hist_lanc = ''
   end if

   let p_txt_compl = p_num_ar using '&&&&&&&', p_num_seq using '&&&'
   let p_texto = p_lanc.tex_hist_lanc
   let p_lanc.tex_hist_lanc = p_texto, p_txt_compl


   INSERT INTO lanc_cont_rec
    VALUES(p_lanc.*)

   IF STATUS <> 0 THEN
      LET p_msg = STATUS
      LET p_msg = 'Erro ',p_msg CLIPPED,' inserindo na tabela lanc_cont_rec'
      RETURN FALSE
   END IF

   IF p_tributo = 'val_liquido' THEN
      if p_num_transac = 0 then
         LET p_num_transac = SQLCA.SQLERRD[2]
      end if
   end if

   IF p_lanc.ies_tipo_lanc = "C" THEN
      LET l_cta_deb = 0
      LET l_cta_cre = p_lanc.num_conta_cont
   ELSE
      LET l_cta_deb = p_lanc.num_conta_cont
      LET l_cta_cre = 0
   END IF

   LET m_periodo_contab = YEAR(p_lanc.dat_lanc)
   LET m_segmto_periodo = MONTH(p_lanc.dat_lanc)

   CALL pol1046_busca_num_relacionto()

   WHENEVER ERROR CONTINUE
      INSERT INTO ctb_lanc_ctbl_recb
         (empresa,
          periodo_contab,
          segmto_periodo,
          cta_deb,
          cta_cre,
          dat_movto,
          dat_vencto,
          dat_conversao,
          val_lancto,
          qtd_outra_moeda,
          hist_padrao,
          compl_hist,
          linha_produto,
          linha_receita,
          segmto_mercado,
          classe_uso,
          num_relacionto,
          lote_contab,
          num_lancto,
          empresa_origem,
          nota_fiscal,
          serie_nota_fiscal,
          subserie_nf,
          espc_nota_fiscal,
          fornec_nota_fiscal,
          aviso_recebto,
          seq_aviso_recebto,
          tip_nota_fiscal,
          eh_item_estoque,
          lote_patrimonio,
          liberado,
          tip_lancamento_contabil)
      VALUES
         (p_cod_emp_plano,
          m_periodo_contab,
          m_segmto_periodo,
          l_cta_deb,
          l_cta_cre,
          p_lanc.dat_lanc,
          NULL,
          NULL,
          p_lanc.val_lanc,
          0,
          m_hist_padrao,
          "S",
          p_lanc.cod_area_negocio,
          p_lanc.cod_lin_negocio,
          0,
          0,
          m_max_num_relacionto,
          p_lanc.num_lote_lanc,
          0,
          p_lanc.cod_empresa,
          p_lanc.num_nf,
          p_lanc.ser_nf,
          p_lanc.ssr_nf,
          p_lanc.ies_especie,
          p_lanc.cod_fornecedor,
          p_lanc.num_aviso_rec,
          p_lanc.num_seq,
          "6", #campo nf_sup.ies_nf_aguard_nfe
          p_lanc.ies_item_estoq,
          0,
          'S',
          'O')
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT", "CTB_LANC_CTBL_RECB")
      RETURN FALSE
   END IF

   IF p_tributo = "val_liquido" THEN
      IF m_sequencia_registro = 0 THEN
         LET m_sequencia_registro = sqlca.sqlerrd[2]
      END IF
   END IF

   IF p_amostra = 'S' THEN 
      LET p_lanc.num_conta_cont = "91042293"
      LET p_lanc.ies_tipo_lanc  = "C"
      
      select den_conta
        into p_lanc.tex_hist_lanc
        from plano_contas
       where cod_empresa = p_cod_emp_plano
         and num_conta_reduz = p_lanc.num_conta_cont
      if status <> 0 then
         let p_lanc.tex_hist_lanc = ''
      end if
      let p_txt_compl = p_num_ar using '&&&&&&&', p_num_seq using '&&&'
      let p_texto = p_lanc.tex_hist_lanc
      let p_lanc.tex_hist_lanc = p_texto, p_txt_compl
      
      INSERT INTO lanc_cont_rec
      VALUES(p_lanc.*)
   
      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' inserindo na tabela lanc_cont_rec cred amostra'
         RETURN FALSE
      END IF
      LET l_cta_deb = 0
      LET l_cta_cre = p_lanc.num_conta_cont

      LET m_periodo_contab = YEAR(p_lanc.dat_lanc)
      LET m_segmto_periodo = MONTH(p_lanc.dat_lanc)

      CALL pol1046_busca_num_relacionto()

      WHENEVER ERROR CONTINUE
        INSERT INTO ctb_lanc_ctbl_recb
           (empresa,
            periodo_contab,
            segmto_periodo,
            cta_deb,
            cta_cre,
            dat_movto,
            dat_vencto,
            dat_conversao,
            val_lancto,
            qtd_outra_moeda,
            hist_padrao,
            compl_hist,
            linha_produto,
            linha_receita,
            segmto_mercado,
            classe_uso,
            num_relacionto,
            lote_contab,
            num_lancto,
            empresa_origem,
            nota_fiscal,
            serie_nota_fiscal,
            subserie_nf,
            espc_nota_fiscal,
            fornec_nota_fiscal,
            aviso_recebto,
            seq_aviso_recebto,
            tip_nota_fiscal,
            eh_item_estoque,
            lote_patrimonio,
            liberado,
            tip_lancamento_contabil)
        VALUES
           (p_cod_emp_plano,
            m_periodo_contab,
            m_segmto_periodo,
            l_cta_deb,
            l_cta_cre,
            p_lanc.dat_lanc,
            NULL,
            NULL,
            p_lanc.val_lanc,
            0,
            m_hist_padrao,
            "S",
            p_lanc.cod_area_negocio,
            p_lanc.cod_lin_negocio,
            0,
            0,
            m_max_num_relacionto,
            p_lanc.num_lote_lanc,
            0,
            p_lanc.cod_empresa,
            p_lanc.num_nf,
            p_lanc.ser_nf,
            p_lanc.ssr_nf,
            p_lanc.ies_especie,
            p_lanc.cod_fornecedor,
            p_lanc.num_aviso_rec,
            p_lanc.num_seq,
            "6", #campo nf_sup.ies_nf_aguard_nfe
            p_lanc.ies_item_estoq,
            0,
            'S',
            'O')
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("INSERT", "CTB_LANC_CTBL_RECB")
        RETURN FALSE
     END IF
   END IF  
   
   RETURN TRUE

END FUNCTION


#------------------------------------------#
 FUNCTION pol1046_busca_num_relacionto()
#------------------------------------------#
   # Procura o relaciondo da NF em questão

   WHENEVER ERROR CONTINUE
    SELECT MAX(num_relacionto)
      INTO m_max_num_relacionto
      FROM ctb_lanc_ctbl_recb
     WHERE empresa_origem      = p_lanc.cod_empresa
       AND nota_fiscal         = p_lanc.num_nf
       AND serie_nota_fiscal   = p_lanc.ser_nf
       AND subserie_nf         = p_lanc.ssr_nf
       AND espc_nota_fiscal    = p_lanc.ies_especie
       AND fornec_nota_fiscal  = p_lanc.cod_fornecedor
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("SELECT", "CTB_LANC_CTBL_RECB")
   END IF

   IF m_max_num_relacionto > 0 THEN
      RETURN
   END IF

  # Se não achou procura o próximo relacionto do período

   WHENEVER ERROR CONTINUE
       SELECT MAX(num_relacionto)
         INTO m_max_num_relacionto
         FROM ctb_lanc_ctbl_recb
        WHERE empresa        = p_cod_emp_plano
          AND periodo_contab = m_periodo_contab
          AND segmto_periodo = m_segmto_periodo
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("SELECT","CTB_LANC_CTBL_RECB_2")
   END IF

   IF m_max_num_relacionto > 0 THEN
      LET m_max_num_relacionto = m_max_num_relacionto + 1

      IF m_max_num_relacionto > 999999 THEN
         LET m_max_num_relacionto = 999999
      END IF
   ELSE
      LET m_max_num_relacionto = 1
   END IF

END FUNCTION


#-----------------------------#
FUNCTION pol1046_insere_erro()
#-----------------------------#

   define p_num integer

   if p_flag_cont = 'F' then
      let p_num = p_num_conhec
   else
      let p_num = p_num_ar
   end if

   INSERT INTO erro_contab_912
    VALUES(p_cod_empresa,p_num, p_msg)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','erro_contab_912')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1046_proc_frete()
#----------------------------#

   DECLARE cq_frete CURSOR WITH HOLD FOR
    SELECT cod_empresa,
           num_conhec,
           ser_conhec,
           ssr_conhec,
           dat_entrada_conhec,
           cod_transpor,
           ies_incid_icms_fre
      FROM frete_sup
     WHERE ies_incl_contab IN("N","L")
       AND dat_entrada_conhec >= p_dat_ini
       AND dat_entrada_conhec <= p_dat_fim
       AND (ies_conhec_erro =  "N" OR
           (nom_resp_aceite_er IS NOT NULL AND
            nom_resp_aceite_er <> "  "))

   FOREACH cq_frete INTO
           p_cod_empresa,
           p_num_conhec,
           p_ser_conhec,
           p_ssr_conhec,
           p_dat_entrada,
           p_cod_transpor,
           p_ies_icms_frete

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo fretes ',
                     'da tabela frete_sup'
         CALL pol1046_insere_erro() RETURNING p_status
         RETURN FALSE
      END IF

      LET p_especie = 'CON'

      DECLARE cq_notas CURSOR WITH HOLD FOR
       SELECT a.num_aviso_rec,
              a.ies_nf_com_erro,
              a.nom_resp_aceite_er,
              b.tiponf,
              b.amostr
         FROM nf_sup a,
              easy:ei10 b
        WHERE a.cod_empresa   = p_cod_empresa
          AND a.num_conhec    = p_num_conhec
          AND a.ser_conhec    = p_ser_conhec
          AND a.ssr_conhec    = p_ssr_conhec
          AND a.cod_transpor  = p_cod_transpor
          AND b.codemp        = a.cod_empresa
          AND b.nferp         = a.num_aviso_rec
          AND a.ies_nf_aguard_nfe = '6'

      FOREACH cq_notas INTO p_num_ar, p_ies_erro, p_nom_resp, p_tip_nf, p_amostra

         IF STATUS <> 0 THEN
            LET p_msg = STATUS
            LET p_msg = 'Erro ',p_msg CLIPPED,' lendo notas ',
                        'da tabela nf_sup'
            CALL pol1046_insere_erro() RETURNING p_status
            RETURN FALSE
         END IF

          if p_ies_erro = "S" then
             if p_nom_resp is null or p_nom_resp = ' ' then
                LET p_msg = 'Conhec: ',  p_num_conhec
                LET p_msg = p_msg CLIPPED, ' - relacionado com NFE com erro - AR: ', p_num_ar
                CALL pol1046_insere_erro() RETURNING p_status
                EXIT FOREACH
             end if
         END IF

         IF p_amostra = 'S' THEN
            IF NOT pol1046_atu_frete_sup('L') THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF

         IF NOT pol1046_le_parametros() THEN
            RETURN
         END IF

         CALL log085_transacao("BEGIN")

         IF NOT pol1046_contabiliza_frete() THEN
            CALL log085_transacao("ROLLBACK")
            CALL pol1046_insere_erro() RETURNING p_status
         ELSE
            CALL log085_transacao("COMMIT")
         END IF

      END FOREACH

   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1046_contabiliza_frete()
#-----------------------------------#

   DEFINE p_conta CHAR(23)

   LET p_val_frete        = 0
   LET p_icm_frete_d      = 0
   LET p_icm_frete_c      = 0
   LET p_item_estoq       = 0
   LET p_tip_despesa      = 0
   LET p_num_seq          = 0
   LET p_cod_item         = 0
   LET p_pis_frete        = 0
   LET p_cofins_frete     = 0
   LET p_val_frete_outros = 0 
   LET p_icms_outros_fr   = 0 


   DELETE FROM erro_contab_912
    WHERE cod_empresa = p_cod_empresa
      AND num_ar      = p_num_conhec

   LET p_flag_cont = 'F'

   DECLARE cq_aviso CURSOR FOR
    SELECT a.val_frete,
           val_icms_frete_d,
           val_icms_frete_c,
           ies_item_estoq,
           cod_tip_despesa,
           num_seq,
           cod_item,
           NVL(val_pis_declarado,0),
           NVL(val_cofins_decl,0),
           NVL(c.val_frete,0) val_frete_outros,
           NVL(c.val_icms_frete_calculado,0) val_icms_outros_fr
      FROM aviso_rec a,    
           OUTER sup_frete_x_nf_entrada c,
           OUTER sup_fr_pis_cofins b
     WHERE a.cod_empresa   = p_cod_empresa
       AND a.num_aviso_rec = p_num_ar
       AND a.cod_empresa   = b.empresa
       AND a.num_aviso_rec = b.aviso_recebto
       AND a.num_seq       = b.seq_aviso_recebto
       AND a.cod_empresa   = c.empresa
       AND a.num_aviso_rec = c.aviso_recebto
       AND a.num_seq       = c.seq_aviso_recebto

   FOREACH cq_aviso INTO
           p_val_frete,
           p_icm_frete_d,
           p_icm_frete_c,
           p_item_estoq,
           p_tip_despesa,
           p_num_seq,
           p_cod_item,
           p_pis_frete,
           p_cofins_frete,
           p_val_frete_outros, 
           p_icms_outros_fr 

      IF STATUS <> 0 THEN
         LET p_msg = STATUS
         LET p_msg = 'Erro ',p_msg CLIPPED,' lendo vr frete do ar ',p_num_ar,' da tab aviso_rec'
         RETURN FALSE
      END IF

      IF p_icm_frete_d = 0 then
         let p_icm_frete = p_icm_frete_c
      ELSE
         let p_icm_frete = p_icm_frete_d
      END IF

      IF NOT pol1046_le_tip_desp() THEN
         RETURN FALSE
      END IF
     
      DECLARE cq_nc CURSOR FOR
       SELECT tributo,
              num_conta_cred,
              num_conta_deb
         FROM contas_912
        WHERE cod_empresa  = p_cod_empresa
          AND cod_tip_nf   = p_tip_nf
          AND cod_tip_item = p_cod_tip_item
          AND (tributo     = 'val_frete'
           OR  tributo     = 'val_icms_frete'
           OR  tributo     = 'val_pis_frete'
           OR  tributo     = 'val_cofins_frete')
          AND (LENGTH(num_conta_cred) > 0
           OR  LENGTH(num_conta_deb)  > 0)

      FOREACH cq_nc INTO
              p_tributo,
              p_conta_cred,
              p_conta_deb

         IF STATUS <> 0 THEN
            LET p_msg = STATUS
            LET p_msg = 'Erro ',p_msg CLIPPED,' lendo tab contas_912 ',
                        'p/ tipo_nf ',p_tip_nf,',tipo_item ',p_cod_tip_item
            RETURN FALSE
         END IF

         IF p_tributo = 'val_icms_frete' THEN
            LET p_icm_frete = p_icm_frete + p_icms_outros_fr
            IF   p_icm_frete > 0
            AND (p_ies_icms_frete = 'C' OR p_ies_icms_frete = ' '
                 OR p_ies_icms_frete = 'O') THEN
               IF NOT pol1046_ins_lanc(p_icm_frete) THEN
                  RETURN FALSE
               END IF
            END IF
         END IF

         IF p_tributo = 'val_pis_frete' THEN
            IF p_pis_frete > 0 THEN 
               IF NOT pol1046_ins_lanc(p_pis_frete) THEN
                  RETURN FALSE
               END IF
            END IF
         END IF

         IF p_tributo = 'val_cofins_frete' THEN
            IF p_cofins_frete > 0 THEN 
               IF NOT pol1046_ins_lanc(p_cofins_frete) THEN
                  RETURN FALSE
               END IF
            END IF
         END IF

         IF p_tributo = 'val_frete' THEN

            LET p_val_frete = p_val_frete + p_val_frete_outros 
                      
            IF p_val_frete > 0 THEN

               IF p_ies_icms_frete = 'C' OR p_ies_icms_frete = ' '
               OR p_ies_icms_frete = 'O' THEN
                  LET p_conta = p_conta_deb
                  LET p_conta_deb = ' '
               END IF

               IF NOT pol1046_ins_lanc(p_val_frete) THEN
                  RETURN FALSE
               END IF

               IF p_ies_icms_frete = 'C' OR p_ies_icms_frete = ' '
               OR p_ies_icms_frete = 'O' THEN
                  LET p_conta_deb = p_conta
                  LET p_conta_cred = ' '
                  LET p_val_dif = p_val_frete - p_icm_frete - p_cofins_frete - p_pis_frete
                  IF p_val_dif > 0 THEN
                     IF NOT pol1046_ins_lanc(p_val_dif) THEN
                        RETURN FALSE
                     END IF
                  END IF
               END IF

            END IF
         END IF

      END FOREACH

   END FOREACH

   {IF NOT pol1046_fecha_lanc() THEN
      RETURN FALSE
   END IF}

   IF NOT pol1046_atu_frete_sup('S') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
 FUNCTION pol1046_erros()
#------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol10461") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol10461 AT 4,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET p_index = 1

   DECLARE cq_itens CURSOR FOR

   SELECT cod_empresa,
          num_ar,
          den_erro
     FROM erro_contab_912
    order by cod_empresa, num_ar

   FOREACH cq_itens
      INTO pr_contab[p_index].cod_emp,
           pr_contab[p_index].num_ar,
           pr_contab[p_index].den_erro

      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo", "Cursor: cq_itens")
         RETURN FALSE
      END IF

      LET p_index = p_index + 1

      IF p_index > 4000 THEN
         ERROR "Limite de grade ultrapassado !!!"
         EXIT FOREACH
      END IF

   END FOREACH

   IF p_index = 1 THEN
      CALL log0030_mensagem("Não há mensagens de erro a serem exibidas!", "Exclamation")
      CLOSE WINDOW w_pol10461
      RETURN true
   END IF

   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_contab TO sr_contab.*

   CLOSE WINDOW w_pol10461

   RETURN TRUE

END FUNCTION

#------------------FIM DO PROGRAMA--------------------#
