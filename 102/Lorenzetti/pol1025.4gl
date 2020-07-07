#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol1025                                                 #
# OBJETIVO: IMPORTAÇÃO NOTA FISCAL DE ENTRADA DO SITEMA EASY        #
# CLIENTE.: 912 - DOLOMIA                                           #
# DATA....: 18/03/10                                                #
# POR.....: IVO H BARBOSA                                           #
# Alterações solicitadas pela Cris                                  #
# - pana NF mãe, gravar pis/cofins na tabela sup_ar_piscofim        #
# - gravar nf_sup.ies_tipo_import = 'E'
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_aviso_rec          RECORD LIKE aviso_rec.*,
          p_nf_sup             RECORD LIKE nf_sup.*,
          p_ar_sq              RECORD LIKE aviso_rec_compl_sq.*,
          p_ar_compl           RECORD LIKE aviso_rec_compl.*,
          p_dest_ar            RECORD LIKE dest_aviso_rec.*,
          p_audit_ar           RECORD LIKE audit_ar.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_auditoria  RECORD LIKE estoque_auditoria.*,
          p_nf_erro            RECORD LIKE nf_sup_erro.*,
          p_cod_fornec         LIKE fornecedor.cod_fornecedor,
          p_cod_uni_feder      LIKE fornecedor.cod_uni_feder

  DEFINE p_cod_mod_embar      LIKE pedido_sup.cod_mod_embar,
         p_cnd_pgto           LIKE pedido_sup.cnd_pgto,
       	 p_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
       	 p_num_conta          LIKE item_sup.num_conta,
       	 p_cod_comprador      LIKE item_sup.cod_comprador,
       	 p_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
       	 p_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
       	 p_den_item           LIKE item.den_item,
       	 p_cod_cla_fisc       LIKE item.cod_cla_fisc,
       	 p_cod_unid_med       LIKE item.cod_unid_med,
       	 p_cod_local_estoq    LIKE item.cod_local_estoq,
       	 p_cod_lin_recei      LIKE item.cod_lin_recei,
       	 p_cod_lin_prod       LIKE item.cod_lin_prod,
       	 p_cod_tip_desp_frt_c LIKE par_sup.cod_tip_desp_frt_c,
       	 p_cod_operac_estoq_c LIKE par_sup.cod_operac_estoq_c,
       	 p_cod_operac_estoq_l LIKE par_sup.cod_operac_estoq_l,
       	 p_cod_operacao       LIKE tipo_desp_oper_ct.cod_operacao,
       	 p_cod_grp_despesa    LIKE par_sup.cod_grp_despesa,
         p_ies_ctr_estoq      LIKE item.ies_ctr_estoque,
         p_ies_ctr_lote       LIKE item.ies_ctr_lote,
         p_ies_inspecao       LIKE item.ies_tem_inspecao,
         p_num_versao         like ordem_sup.num_versao,
         p_qtd_movto          like estoque_trans.qtd_movto,
         p_ser_nf             like nf_sup.ser_nf,
         p_ssr_nf             like nf_sup.ssr_nf,
         p_cod_cfop           like nf_sup.cod_operacao,
         p_nom_transpor       like fornecedor.raz_social,
         p_num_nf             LIKE nf_sup.num_nf,
         p_num_ser            LIKE nf_sup.ser_nf,
         p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
         p_den_erro           LIKE nf_sup_erro.des_pendencia_item,
         p_val_bc_icms_da     like aviso_rec.val_base_c_icms_da,
         p_num_aviso          LIKE nf_sup.num_aviso_rec,
         p_val_tot_da         LIKE aviso_rec.val_despesa_aces_i

   DEFINE p_aen              RECORD
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
   END RECORD

   DEFINE p_parametros_912     RECORD
          cod_empresa          CHAR(02),
          banco_estancia       CHAR(30),
          cod_pais_br          CHAR(03),
          cod_idioma           INTEGER,
          cod_oper_val         CHAR(04),
          cod_tip_val_mais     DECIMAL(3,0),
          cod_tip_val_menos    DECIMAL(3,0),
          num_lote_deb_con     DECIMAL(5,0),
          num_lote_diversos    DECIMAL(5,0),
          num_lote_bx_adiant   DECIMAL(5,0),
          cod_tip_val_piscof   DECIMAL(3,0),
          cod_tip_val_ir       DECIMAL(3,0),
          cod_oper_estoq       CHAR(04),
          ser_nf_imp           CHAR(03)
  END RECORD


  DEFINE p_cod_fiscal         CHAR(05),
         p_cod_empresa        CHAR(02),
         p_user               CHAR(08),
         p_opest              char(04),
         p_linha              CHAR(699),
         p_numero             DECIMAL(13,2),
         p_num_recno          INTEGER,
         p_imprimiu           SMALLINT,
         p_cod_fiscal2        CHAR(05),
         p_dat_proces         DATE,
         p_num_transac        INTEGER,
         p_dest_seq           INTEGER,
         p_criticou           SMALLINT,
         p_msg                CHAR(80),
         p_inconsiste         SMALLINT,
         p_num_seq            SMALLINT,
         p_seq_ar             SMALLINT,
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_num_cgc_sm         CHAR(09),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
       	 p_posi               SMALLINT,
       	 p_ind                SMALLINT,
         p_nom_tela           CHAR(200),
         p_nom_help           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
       	 p_arquivo            CHAR(15),
       	 p_num                CHAR(05),
       	 p_converte           CHAR (01),
       	 p_conhec_process     INTEGER,
       	 p_contador           INTEGER,
         p_versao             CHAR(18),
         p_num_programa       CHAR(07),
         p_cod_transp         CHAR(02),
         p_dtemis             CHAR(10),
         p_num_prx_ar         INTEGER,
       	 p_ies_com_qtd        CHAR(01),
         p_ies_custo          CHAR(01),
         p_tipo_nf            integer,
         p_cod_lib            char(01),
         p_num_seq_erro       INTEGER,
         p_cod_via            char(02),
         p_num_pedido         INTEGER,
         p_especie            char(03),
         p_par_ind            CHAR(01),
         p_valor              decimal(15,2),
       	 p_ies_situa          CHAR(01),
       	 p_serie              CHAR(03),
       	 p_sserie             CHAR(02),
       	 p_numerario          CHAR(16),
       	 p_marca              CHAR(04),
         p_cod_item           CHAR(15),
         p_qtd_mae            DECIMAL(10,3),
         p_val_mae            DECIMAL(17,2),
         p_qtd_filha          DECIMAL(10,3),
         p_val_filha          DECIMAL(17,2),
         p_qtd_ar             DECIMAL(10,3),
         p_val_ar             DECIMAL(17,2),
         p_qtd_saldo          DECIMAL(10,3),
         p_qtd_recebida       DECIMAL(10,3),
         p_qtd_reservada      DECIMAL(10,3),
         p_qtd_solic          DECIMAL(10,3),
         p_preco_dec8         DECIMAL(15,8),
         p_preco_dec4         DECIMAL(15,4),
         p_preco_txt          char(15),
         p_val_tot_acres      DECIMAL(17,2),
         p_val_acres          DECIMAL(17,2),
         p_num_oc             INTEGER,
         p_seq_prog           INTEGER,
         p_nf_easy            char(10),
         p_cod_fabricante     CHAR(15)

   DEFINE p_nota              RECORD
          flagnf              CHAR(001),
          nfeasy              CHAR(009),
          codemp              CHAR(002),
          sreasy              CHAR(003),
          tiponf              CHAR(001),
          nrhawb              CHAR(017),
          nferp               CHAR(009),
          srerp               CHAR(003),
          cdforn              CHAR(006),
          cdtran              CHAR(006),
          forlog              CHAR(015),
          tralog              CHAR(015),
          nrvolu              CHAR(020),
          qtvolu              CHAR(013),
          especi              CHAR(015),
          pesobr              CHAR(011),
          pesolq              CHAR(011),
          vlrnf               CHAR(015),
          vlrprd              CHAR(015),
          vlrfob              CHAR(015),
          vlrfre              CHAR(015),
          vlrseg              CHAR(015),
          vlrdsc              CHAR(015),
          vdimpo              CHAR(015),
          vlrdsp              CHAR(015),
          vdicms              CHAR(015),
          vlriof              CHAR(015),
          vbipi               CHAR(015),
          vbicms              CHAR(015),
          vbpis               CHAR(015),
          vbcof               CHAR(015),
          vlripi              CHAR(015),
          vlrpis              CHAR(015),
          vlricm              CHAR(015),
          vlrcof              CHAR(015),
          vicdev              CHAR(015),
          vicdif              CHAR(015),
          vicprs              CHAR(015),
          dtemba              CHAR(008),
          dtemis              CHAR(008),
          nfrefe              CHAR(009),
          srrefe              CHAR(003),
          dtrefe              CHAR(008),
          moddrw              CHAR(001),
          msgdrw              CHAR(360),
          numdi               CHAR(010),
          dtdi                CHAR(008),
          ufdese              CHAR(002),
          nmurfd              CHAR(040),
          dtdese              CHAR(008),
          intdsp              CHAR(001),
          flag                CHAR(001),
          msgrej              CHAR(200),
          dtexpo              CHAR(008),
          hrexpo              CHAR(006),
          usexpo              CHAR(025),
          dtimpo              CHAR(008),
          hrimpo              CHAR(006),
          usimpo              CHAR(025),
          recno               INTEGER,
          opest               CHAR(004),
          msgadi              CHAR(240),
          marvol              CHAR(70),
          numvol              CHAR(70),
          amostr              CHAR(01)
   END RECORD

   DEFINE p_item              RECORD
          nfeasy              CHAR(009),
          sreasy              CHAR(003),
          codemp              CHAR(002),
          cdforn              CHAR(006),
          forlog              CHAR(015),
          linha               CHAR(004),
          nferp               CHAR(009),
          srerp               CHAR(003),
          cdprod              CHAR(015),
          numped              CHAR(015),
          sequen              CHAR(004),
          oclog               CHAR(009),
          splog               CHAR(003),
          codncm              CHAR(012),
          cfop                CHAR(005),
          qtde                CHAR(013),
          prcuni              CHAR(018),
          pesolq              CHAR(011),
          prctot              CHAR(015),
          unidad              CHAR(002),
          vlrfob              CHAR(015),
          vlrfre              CHAR(015),
          vlrseg              CHAR(015),
          vlrdsc              CHAR(015),
          vdimpo              CHAR(015),
          vlrdsp              CHAR(015),
          vdicms              CHAR(015),
          vlriof              CHAR(015),
          vlrcif              CHAR(015),
          vbipi               CHAR(015),
          vbicms              CHAR(015),
          vbpis               CHAR(015),
          vbcof               CHAR(015),
          perii               CHAR(006),
          peripi              CHAR(006),
          pericm              CHAR(006),
          perpis              CHAR(006),
          percof              CHAR(006),
          vlrii               CHAR(015),
          vlripi              CHAR(015),
          vlricm              CHAR(015),
          vlrpis              CHAR(015),
          vlrcof              CHAR(015),
          vicdev              CHAR(015),
          vicdif              CHAR(015),
          vicprs              CHAR(015),
          nmfabr              CHAR(040),
          nradic              CHAR(003),
          sqadic              CHAR(003),
          flag                CHAR(001),
          msgrej              CHAR(200),
          dtexpo              CHAR(008),
          hrexpo              CHAR(006),
          usexpo              CHAR(025),
          dtimpo              CHAR(008),
          hrimpo              CHAR(006),
          usimpo              CHAR(025),
          recno               INTEGER,
          bdicms              decimal(15,2),
          vicda               decimal(15,2),
          dscdi               char(60)
   END RECORD

   DEFINE pr_erro              ARRAY[10000] OF RECORD
          cod_empresa          CHAR(02),
          num_registro         INTEGER,
          den_erro             CHAR(80)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1025-10.02.00"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   {CALL log001_acessa_usuario("SUPRIMEN","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user}

    LET p_status      = 0
    LET p_cod_empresa = '10'
    LET p_user 	      = 'easy'

    CALL pol1025_controle()

END MAIN

#---------------------------#
 FUNCTION pol1025_controle()
#---------------------------#

   DEFINE p_proces char(01)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1025") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1025 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   select proces_nota
     into p_proces
     from proces_integra_912

   if p_proces = 'S' then
      ERROR 'Há um processamento em execução! Tente mais tarde.'
      sleep 7
      return
   end if

   update proces_integra_912
      set proces_nota = 'S'

   CALL pol1025_processar() RETURNING p_status

   CALL log085_transacao("BEGIN")
   IF NOT pol1025_ve_nf_excluida() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   CALL log085_transacao("BEGIN")
   IF NOT pol1025_exporta_num_nf() THEN
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
   END IF

   CALL pol1025_grava_erro()

   update proces_integra_912
      set proces_nota = 'N'

   CLOSE WINDOW w_pol1025

END FUNCTION

#-------------------------------#
FUNCTION pol1025_ve_nf_excluida()
#-------------------------------#

   DEFINE p_num_ar INTEGER,
          p_flag   SMALLINT

   DECLARE cq_nf_exc CURSOR FOR
    SELECT codemp,
           recno,
           nferp
      FROM easy:ei10
     WHERE flag = 'S'
       AND LENGTH(nferp) > 0

   FOREACH cq_nf_exc INTO p_cod_empresa, p_nota.recno, p_num_ar

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo a tabela ei10)'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      let p_flag =  false

      SELECT cod_empresa
        FROM nf_sup
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_ar

      IF STATUS = 100 THEN
         let p_flag =  true
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') lendo a tabela nf_sup - NF excluida)'
            CALL pol1025_insere_erro()
            RETURN FALSE
         END IF

         select ies_situacao
           from aviso_rec_compl
          where cod_empresa   = p_cod_empresa
            and num_aviso_rec = p_num_ar
            and ies_situacao  = 'C'

         if STATUS = 0 then
            let p_flag = true
         else
            IF STATUS <> 100 THEN
               LET p_msg = 'Erro(',STATUS,') lendo aviso_rec_compl, checando NF cancelada)'
               CALL pol1025_insere_erro()
               RETURN FALSE
            END IF
         end if

      END IF

      if p_flag then

         UPDATE easy:ei10
            SET flag = 'E'
          WHERE codemp = p_cod_empresa
            AND recno  = p_nota.recno

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') atualizando a tabela ei10 - NF excluida)'
            CALL pol1025_insere_erro()
            RETURN FALSE
         END IF

      end if

   END FOREACH

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1025_exporta_num_nf()
#--------------------------------#

   define p_nfeasy  char(09),
          p_sreasy  char(03),
          p_dat_ent date,
          p_num_ar  INTEGER

   DEFINE p_ei07 RECORD
          dtintg   CHAR(006),
          nrhawb   CHAR(017),
          nfeasy   CHAR(009),
          sreasy   CHAR(003),
          codemp   CHAR(002),
          tiponf   CHAR(001),
          nferp    CHAR(009),
          srerp    CHAR(003),
          dterp    CHAR(006),
          arerp    CHAR(010),
          vlerp    CHAR(015),
          numdi    CHAR(010),
          dtrecb   CHAR(006),
          recno    CHAR(015),
          flag     CHAR(001),
          msgrej   CHAR(200),
          dtexpo   CHAR(008),
          hrexpo   CHAR(006)
   end RECORD

   INITIALIZE p_ei07 to null

   DECLARE cq_exp_nf CURSOR for
    SELECT a.num_nf,
           a.ser_nf,
           a.num_aviso_rec,
           a.ies_especie_nf,
           a.dat_entrada_nf,
           b.codemp,
           b.nfeasy,
           b.sreasy,
           b.nrhawb,
           b.tiponf
      FROM nf_sup a,
           easy:ei10 b
     WHERE a.cod_empresa   = b.codemp
       AND a.num_aviso_rec = b.nferp
       AND a.num_nf       <> a.num_aviso_rec

   FOREACH cq_exp_nf into
           p_num_nf,
           p_ser_nf,
           p_num_ar,
           p_especie,
           p_dat_ent,
           p_cod_empresa,
           p_nfeasy,
           p_sreasy,
           p_ei07.nrhawb,
           p_ei07.tiponf

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo notas com numeros alterados - cq_exp_nf)'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      select codemp
        from easy:ei07
       where codemp = p_cod_empresa
         and arerp  = p_num_ar

      if status = 0 then
         CONTINUE FOREACH
      else
         if status <> 100 then
            LET p_msg = 'Erro(',STATUS,') lendo dados da tabela ei07)'
            CALL pol1025_insere_erro()
            RETURN FALSE
         end if
      end if

      LET p_ei07.nfeasy = p_nfeasy
      LET p_ei07.sreasy = p_sreasy
      LET p_ei07.nferp  = p_num_nf
      LET p_ei07.srerp  = p_ser_nf
      LET p_ei07.dterp  = data_abreviada(p_dat_ent)
      LET p_ei07.arerp  = p_num_ar
      LET p_ei07.dtrecb = p_ei07.dterp
      LET p_ei07.dtintg = data_abreviada(TODAY)
      LET p_ei07.codemp = p_cod_empresa
      LET p_ei07.flag   = 'N'
      LET p_ei07.dtexpo = data_ansi()
      LET p_ei07.hrexpo = hora_atual()

      SELECT MAX(recno)
        INTO p_num_recno
        FROM easy:ei07
       WHERE codemp = p_cod_empresa

      IF p_num_recno IS NULL THEN
         LET p_num_recno = 0
      END IF

      LET p_num_recno = p_num_recno + 1
      LET p_ei07.recno = p_num_recno

      INSERT INTO easy:ei07(
         dtintg,
         nrhawb,
         nfeasy,
         sreasy,
         codemp,
         tiponf,
         nferp,
         srerp,
         dterp,
         arerp,
         vlerp,
         numdi,
         dtrecb,
         recno,
         flag,
         msgrej,
         dtexpo,
         hrexpo) values(p_ei07.*)

      if status <> 0 then
         LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ei07)'
         CALL pol1025_insere_erro()
         RETURN FALSE
      end if

   end FOREACH

   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION data_abreviada(p_data)
#------------------------------#

   DEFINE p_data      CHAR(10),
          p_dat_abrev CHAR(06)

   LET p_data = tira_formato(p_data)
   LET p_dat_abrev = p_data[1,4],p_data[7,8]

   RETURN(p_dat_abrev)

END FUNCTION

#----------------------------#
FUNCTION pol1025_insere_erro()
#----------------------------#

   LET p_num_seq = p_num_seq + 1

   IF p_num_seq = 10000 THEN
      LET p_msg = 'Limite de linhas do array pr_erro ultrapassou'
   ELSE
      IF p_num_seq > 10000 THEN
         RETURN
      END IF
   END IF

   LET pr_erro[p_num_seq].cod_empresa  = p_cod_empresa
   LET pr_erro[p_num_seq].num_registro = p_nota.recno
   LET pr_erro[p_num_seq].den_erro     = p_msg

   LET p_criticou = TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1025_grava_erro()
#----------------------------#

   FOR p_index = 1 TO p_num_seq
       IF pr_erro[p_index].den_erro IS NOT NULL THEN
          INSERT INTO erro_imp_nf_912(
             cod_empresa,
             num_registro,
             den_erro)
          VALUES(pr_erro[p_index].cod_empresa,
                 pr_erro[p_index].num_registro,
                 pr_erro[p_index].den_erro)

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','erro_imp_nf_912')
             EXIT FOR
          END IF
       END IF
   END FOR

END FUNCTION

#----------------------------#
FUNCTION pol1025_le_par_vdp()
#----------------------------#

   SELECT par_vdp_txt[215,216]
     INTO p_cod_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados da tabela par_vdp)'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1025_le_para_sup()
#----------------------------#

   SELECT cod_operac_estoq_c,
          cod_operac_estoq_l,
          cod_grp_despesa,
          cod_tip_desp_frt_c
     INTO p_cod_operac_estoq_c,
          p_cod_operac_estoq_l,
          p_cod_grp_despesa,
          p_cod_tip_desp_frt_c
     FROM par_sup
   WHERE  cod_empresa = p_cod_empresa

    IF sqlca.sqlcode <>  0 THEN
       LET p_msg = 'Erro(',STATUS,') lendo dados da tabela par_sup)'
       CALL pol1025_insere_erro()
       RETURN FALSE
    END IF

    RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1025_processar()
#---------------------------#

   INITIALIZE p_cod_fornec, p_cod_uni_feder  TO NULL

   LET p_cod_empresa = '00'
   LET p_dat_proces = TODAY

   DELETE FROM erro_imp_nf_912
    where num_registro not in
          (select recno from easy:ei10)

    IF STATUS <>  0 THEN
       LET p_msg = 'Erro(',STATUS,') deletando erros da tab erro_imp_nf_912)'
       CALL pol1025_insere_erro()
       RETURN FALSE
    END IF

   CREATE temp  TABLE nf_tmp_912 (
      cod_item    CHAR(15),
      num_oc      integer,
      seq_prog    integer,
      qtd_mae     DECIMAL(10,3),
      val_mae     DECIMAL(17,2),
      qtd_filha   DECIMAL(10,3),
      val_filha   DECIMAL(17,2)
   );

    IF STATUS <>  0 THEN
       LET p_msg = 'Erro(',STATUS,') criando tabela nf_tmp_912)'
       CALL pol1025_insere_erro()
       RETURN FALSE
    END IF

   DECLARE cq_nota CURSOR WITH HOLD FOR
    SELECT *
      FROM easy:ei10
     WHERE flag = 'N'
     order by codemp, recno

   FOREACH cq_nota INTO p_nota.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela de notas ei10)'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      IF p_nota.codemp <> p_cod_empresa THEN
         LET p_cod_empresa = p_nota.codemp
         DISPLAY p_cod_empresa TO cod_empresa
         IF NOT pol1025_le_par_vdp() THEN
            RETURN FALSE
         END IF
         IF NOT pol1025_le_para_sup() THEN
            RETURN FALSE
         END IF
         IF NOT pol1025_le_param() THEN
            RETURN FALSE
         END IF
      END IF

      INITIALIZE p_msg TO NULL
      let p_nota.flag   = 'R'
      LET p_criticou = FALSE

      call pol1025_consiste_nota() RETURNING p_status

      IF p_criticou or p_status = false THEN
         IF NOT pol1025_atu_ei10() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF

      CALL log085_transacao("BEGIN")

      call pol1025_consiste_itens() RETURNING p_status

      IF p_criticou or p_status = false THEN
         IF NOT pol1025_atu_ei10() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
         CONTINUE FOREACH
      END IF

      IF pol1025_insere_nota() THEN
         IF pol1025_insere_itens() THEN
            CALL log085_transacao("COMMIT")
            let p_nota.flag = 'S'
            LET p_nota.nferp = p_num_prx_ar
            LET p_nota.srerp = p_ser_nf
            let p_msg = null
         else
            CALL log085_transacao("ROLLBACK")
         end if
      else
         CALL log085_transacao("ROLLBACK")
      END IF

      CALL log085_transacao("BEGIN")

      IF NOT pol1025_atu_ei10() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      CALL log085_transacao("COMMIT")

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1025_consiste_nota()
#-------------------------------#

   DELETE FROM erro_imp_nf_912
    where num_registro = p_nota.recno

   IF STATUS <>  0 THEN
      LET p_msg = 'Erro(',STATUS,') deletando erros da tab erro_imp_nf_912)'
      CALL pol1025_insere_erro()
      RETURN true
   END IF

   IF LENGTH(p_nota.codemp) = 0 THEN
      LET p_msg = 'O codigo da empresa nao foi enviado'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF p_nota.tiponf = '5' THEN
      LET p_opest = p_parametros_912.cod_oper_estoq
   ELSE
      IF p_nota.tiponf = '2' THEN
         LET p_opest = p_parametros_912.cod_oper_val
      ELSE
         IF LENGTH(p_nota.opest) = 0 THEN
            LET p_msg = 'O código da operação de estoque nao foi enviado'
            CALL pol1025_insere_erro()
         ELSE
            LET p_opest = p_nota.opest
         END IF
      END IF
   END IF

   IF NOT pol1025_emp_existe(p_nota.codemp) THEN
      LET p_msg = 'A empresa enviada nao existe no Logix'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.nfeasy) = 0 THEN
      LET p_msg = 'O numero da nota fiscal easy nao foi enviado'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.sreasy) = 0 THEN
      LET p_msg = 'A serie da nota fiscal easy nao foi enviado'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.forlog) = 0 THEN
      LET p_msg = 'O codigo do fornecedor nao foi enviado'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF p_nota.tiponf matches '[26]' then
      if LENGTH(p_nota.nfrefe) = 0 THEN
         LET p_msg = 'NF complementar ou filha sem o número da NF mãe ou primeira'
         CALL pol1025_insere_erro()
         RETURN TRUE
      end if

      select ser_nf,
             ssr_nf,
             ies_especie_nf,
             num_aviso_rec
        into p_serie,
             p_sserie,
             p_especie,
             p_num_aviso
        from nf_sup
       where num_nf         = p_nota.nfrefe
         and cod_empresa    = p_nota.codemp
         and cod_fornecedor = p_nota.forlog

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') consistindo a existencia ',
                     'da NF mãe na tabela NF_SUP'
         CALL pol1025_insere_erro()
         RETURN FALSE
      end if
   end if

   SELECT cod_fornecedor,
          cod_uni_feder
     INTO p_cod_fornec,
          p_cod_uni_feder
     FROM fornecedor
    WHERE cod_fornecedor = p_nota.forlog

   IF STATUS = 100 THEN
      LET p_msg = 'O fornecedor enviado nao existe no Logix'
      CALL pol1025_insere_erro()
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') consistindo ',
                     'o fornecedor enviado na tabela fornecedor'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF
   END IF

   if  p_nota.tiponf = '2' or p_nota.tiponf = '5'
   OR (p_nota.tiponf = '1' AND p_nota.amostr = 'S') then
   else
      IF LENGTH(p_nota.tralog) = 0 THEN
         LET p_msg = 'O codigo do transportador nao foi enviado'
         CALL pol1025_insere_erro()
         RETURN TRUE
      end if
      SELECT raz_social
        into p_nom_transpor
        FROM fornecedor
       WHERE cod_fornecedor = p_nota.tralog

      IF STATUS = 100 THEN
         LET p_msg = 'O transportador enviado nao existe no Logix'
         CALL pol1025_insere_erro()
         RETURN TRUE
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') consistindo ',
                        'o transportador enviado na tabela clientes'
            CALL pol1025_insere_erro()
            RETURN FALSE
         end if
      END IF
   END IF

   IF NOT pol1025_ies_data(p_nota.dtemis) THEN
      LET p_msg = 'A data de emissao da NF nao e valida'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.vlrnf) = 0 THEN
      LET p_msg = 'O valor total da nota enviado esta nulo'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.vlricm) = 0 THEN
      LET p_msg = 'O valor do icms enviado esta nulo'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.vlripi) = 0 THEN
      LET p_msg = 'O valor do ipi enviado esta nulo'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   IF LENGTH(p_nota.vlrdsc) = 0 THEN
      LET p_msg = 'O valor total do desconto enviado esta nulo'
      CALL pol1025_insere_erro()
      RETURN TRUE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1025_consiste_itens()
#--------------------------------#

   LET p_count    = 0
   let p_cod_cfop = null
   let p_num_pedido = 0

   DECLARE cq_c_its CURSOR FOR
    SELECT *
      FROM easy:ei11
     WHERE codemp = p_cod_empresa
       AND nfeasy = p_nota.nfeasy
       AND sreasy = p_nota.sreasy
       AND forlog = p_nota.forlog
       AND flag   = 'N'
     order by linha

   FOREACH cq_c_its INTO p_item.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela ei11 para consistir '
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      LET p_count = p_count + 1

      if p_cod_cfop is null then
         let p_cod_cfop = p_item.cfop
         call pol1025_troca_cod()
      end if

      IF NOT pol1025_checa_dados() THEN
         RETURN FALSE
      end if

      IF p_criticou THEN
         LET p_item.msgrej = p_msg
         IF NOT pol1025_atu_ei11() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF

   END FOREACH

   IF p_count = 0 THEN
      LET p_msg = 'Os itens da NF nao foram enviados'
      CALL pol1025_insere_erro()
      LET p_criticou = TRUE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1025_troca_cod()
#---------------------------#

   define i, j    integer,
          p_cfop  char(05),
          p_carac char(01)

   let p_cfop = p_cod_cfop[1],'.',p_cod_cfop[2,4]

   if p_cfop[1] = '1' then
      let p_cfop[1] = '5'
   else
      if p_cfop[1] = '2' then
         let p_cfop[1] = '6'
      else
         if p_cfop[1] = '3' then
            let p_cfop[1] = '7'
         end if
      end if
   end if

   let p_cod_cfop = p_cfop

end FUNCTION

#----------------------------#
FUNCTION pol1025_checa_dados()
#----------------------------#

   IF LENGTH(p_item.numped) = 0 THEN
      LET p_msg = 'O numero do pedido nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   if p_num_pedido = 0 then
      let p_num_pedido = p_item.numped
      IF NOT pol1025_chec_pedido() THEN
         RETURN TRUE
      END IF
   end if

   IF LENGTH(p_item.cdprod) = 0 THEN
      LET p_msg = 'O codigo do produto nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.oclog) = 0 THEN
      LET p_msg = 'O numero da ordem nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.splog) = 0 THEN
      LET p_msg = 'A sequencia de programacao da ordem nao foi enviada'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.qtde) = 0 THEN
      LET p_msg = 'A quantidade do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF NOT pol1025_chec_ordem() THEN
      RETURN TRUE
   END IF

   IF NOT pol1025_chec_prog_ent() THEN
      RETURN TRUE
   END IF

   IF LENGTH(p_item.prcuni) = 0 THEN
      LET p_msg = 'O preco unitario do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.peripi) = 0 THEN
      LET p_msg = 'O percentual de IPI do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.vbipi) = 0 THEN
      LET p_msg = 'O valor base de calculo d IPI do item nao foi enviada'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.vlripi) = 0 THEN
      LET p_msg = 'O valor do IPI do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.cfop) = 0 THEN
      LET p_msg = 'O CFOP do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.pericm) = 0 THEN
      LET p_msg = 'O percentual de ICM do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.vlricm) = 0 THEN
      LET p_msg = 'O valor do ICM do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF LENGTH(p_item.vbicms) = 0 THEN
      LET p_msg = 'O valor base de calculo do ICM do item nao foi enviado'
      CALL pol1025_insere_erro()
   END IF

   IF p_nota.tiponf MATCHES '[15]' THEN

      if p_item.perpis > 0 then
         IF LENGTH(p_item.vlrpis) = 0 OR p_item.vlrpis = 0 THEN
            LET p_msg = 'NF mãe ou primeira sem o valor do pis'
            CALL pol1025_insere_erro()
         END IF
      end if

      if p_item.percof > 0 then
         IF LENGTH(p_item.vlrcof) = 0 OR p_item.vlrcof = 0 THEN
            LET p_msg = 'NF mãe ou primeira sem o valor do cofins'
            CALL pol1025_insere_erro()
         END IF
      end if

   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1025_atu_ei10()
#-------------------------#

   LET p_nota.msgrej = p_msg
   LET p_nota.dtimpo = data_ansi()
   LET p_nota.hrimpo = hora_atual()
   LET p_nota.usimpo = p_user

   UPDATE easy:ei10
      SET flag   = p_nota.flag,
          msgrej = p_nota.msgrej,
          dtimpo = p_nota.dtimpo,
          hrimpo = p_nota.hrimpo,
          usimpo = p_nota.usimpo,
          nferp  = p_nota.nferp,
          srerp  = p_nota.srerp
    WHERE codemp = p_nota.codemp
      AND recno  = p_nota.recno

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Atualizando dados na tabela ei10'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol1025_atu_ei11()
#-------------------------#

   LET p_item.dtimpo = data_ansi()
   LET p_item.hrimpo = hora_atual()
   LET p_item.usimpo = p_user

   IF p_criticou THEN
      UPDATE easy:ei11
      SET flag   = 'R',
          msgrej = p_item.msgrej,
          dtimpo = p_item.dtimpo,
          hrimpo = p_item.hrimpo,
          usimpo = p_item.usimpo
    WHERE codemp = p_nota.codemp
      AND nfeasy = p_nota.nfeasy
      AND sreasy = p_nota.sreasy
      AND forlog = p_nota.forlog
   else
      UPDATE easy:ei11
      SET flag   = 'S',
          msgrej = p_item.msgrej,
          dtimpo = p_item.dtimpo,
          hrimpo = p_item.hrimpo,
          usimpo = p_item.usimpo,
          nferp  = p_nf_sup.num_aviso_rec
    WHERE codemp = p_item.codemp
      AND recno  = p_item.recno
   end if

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Atualizando dados na tabela ei11'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------#
 FUNCTION data_ansi()
#-------------------#

   DEFINE p_dat_hoje CHAR(08),
          p_retorno  CHAR(08)

   LET p_dat_hoje = tira_formato(TODAY)
   LET p_retorno  = p_dat_hoje[5,8],p_dat_hoje[3,4],p_dat_hoje[1,2]

   RETURN(p_retorno)

END FUNCTION

#--------------------#
 FUNCTION hora_atual()
#--------------------#

   DEFINE p_hor_hoje CHAR(06)

   LET p_hor_hoje = tira_formato(TIME)

   RETURN(p_hor_hoje)

END FUNCTION

#---------------------------------#
 FUNCTION tira_formato(p_parametro)
#---------------------------------#

   DEFINE p_caractere CHAR(01),
          p_retorno   CHAR(20),
          p_parametro CHAR(20)

   FOR p_index = 1 TO LENGTH(p_parametro)
       LET p_caractere = p_parametro[p_index]
       IF LENGTH(p_caractere) > 0 THEN
          IF p_caractere MATCHES "[-/_,.=:x()]" THEN
          ELSE
             LET p_retorno = p_retorno CLIPPED, p_caractere
          END IF
       END IF
   END FOR

   RETURN(p_retorno)

END FUNCTION

#-------------------------------#
FUNCTION pol1025_ies_data(p_data)
#-------------------------------#

		DEFINE dia, mes, ano, p_qtd_dias INTEGER
    DEFINE p_data CHAR(08)

    IF LENGTH(p_data) <> 8 THEN
       RETURN FALSE
    END IF

    IF NOT pol1025_ies_numeros(p_data) THEN
       RETURN FALSE
    END IF

		LET	dia = p_data[7, 8]
		LET	mes = p_data[5, 6]
		LET	ano = p_data[1, 4]

		IF mes < 1 OR mes > 12 THEN
			RETURN FALSE
		END IF

		IF mes = 4 OR mes = 6 OR mes = 8 OR mes = 11 THEN
			 LET p_qtd_dias = 30;
		ELSE
		   IF mes = 2 THEN
			    IF (ano MOD 4) = 0 THEN
				     LET p_qtd_dias = 29
			    ELSE
				     LET p_qtd_dias = 28
				  END IF
		   ELSE
			    LET p_qtd_dias = 31
			 END IF
	  END IF


		IF dia > 0 AND dia <= p_qtd_dias THEN
			RETURN TRUE
		ELSE
			RETURN FALSE
		END IF

END FUNCTION

#-----------------------------------#
FUNCTION pol1025_ies_numeros(p_data)
#-----------------------------------#

   DEFINE p_data  CHAR(08),
          p_ind   INTEGER,
          p_carac CHAR(01)

   FOR p_ind = 1 TO LENGTH(p_data)
       LET p_carac = p_data[p_ind]
       IF p_carac MATCHES '[0123456789]' THEN
       ELSE
          RETURN FALSE
       END IF
   END FOR

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1025_le_param()
#--------------------------#

   SELECT *
     INTO p_parametros_912.*
     FROM parametros_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo tabela de parametros (parametros_912)'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_ser_nf = p_parametros_912.ser_nf_imp

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_insere_nota()
#-----------------------------#

   LET p_val_tot_da = 0

   if p_nota.tiponf = '6' then
      if not pol1025_ins_da_mae() then
         RETURN false
      end if
   end if

   let p_num_seq_erro = 0

   IF NOT pol1025_gera_num_ar() THEN
      RETURN FALSE
   END IF

   LET p_dtemis = p_nota.dtemis[7,8],'/',
                  p_nota.dtemis[5,6],'/',
                  p_nota.dtemis[1,4]

   select cod_via_transp
     into p_cod_via
     from pedido_compl_912
    where cod_empresa = p_cod_empresa
      and num_pedido  = p_num_pedido

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados complementares na tab pedido_compl_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   if p_nota.tiponf = '2' then
      let p_tipo_nf = 6
      let p_cod_lib = 'S'
   else
      let p_tipo_nf = 7
      let p_cod_lib = 'N'
   end if

   if p_nota.tiponf = '2' or p_nota.tiponf = 5  or p_cod_via = '4' then
      let p_cod_mod_embar = '3'
      let p_nf_sup.ies_tip_frete = '0'
   else
      let p_cod_mod_embar = '2'
      let p_nf_sup.ies_tip_frete = '2'
      let p_den_erro = 'Para frete a pagar é obrigatorio informar o FRETE'
      if not pol1025_ins_nf_erro() then
         RETURN false
      end if
   end if

   LET p_nf_sup.ies_nf_com_erro  =  'S'

   if p_tipo_nf = 7 then
      let p_den_erro = 'Material em transito'
   ELSE
      let p_den_erro = 'Falta imprimir a NFE'
   end if

   if not pol1025_ins_nf_erro() then
      RETURN false
   end if

   LET p_nf_sup.num_aviso_rec       =  p_num_prx_ar
   LET p_nf_sup.cod_empresa         =  p_cod_empresa
   LET p_nf_sup.cod_empresa_estab   =  null
   LET p_nf_sup.num_nf              =  p_num_prx_ar
   LET p_nf_sup.ser_nf              =  p_ser_nf
   LET p_nf_sup.ssr_nf              =  0
   LET p_nf_sup.ser_conhec          =  ' '
   LET p_nf_sup.ssr_conhec          =  0
   LET p_nf_sup.ies_especie_nf      =  pol1025_especie_nf()
   LET p_nf_sup.cod_fornecedor      =  p_nota.forlog
   LET p_nf_sup.num_conhec          =  0

   IF p_nota.tiponf MATCHES '[25]' THEN
      LET p_nf_sup.cod_transpor        = ' '
   ELSE
      LET p_nf_sup.cod_transpor        = p_nota.tralog
   END IF

   LET p_nf_sup.dat_emis_nf         =  p_dtemis
   LET p_nf_sup.dat_entrada_nf      =  p_dat_proces
   LET p_nf_sup.cod_regist_entrada  =  '1'
   LET p_nf_sup.val_tot_nf_c        =  p_nota.vlrnf
   LET p_nf_sup.val_tot_nf_d        =  p_nota.vlrnf
   LET p_nf_sup.val_tot_icms_nf_d   =  p_nota.vlricm
   LET p_nf_sup.val_tot_icms_nf_c   =  p_nota.vlricm
   LET p_nf_sup.val_tot_desc        =  p_nota.vlrdsc
   LET p_nf_sup.val_tot_acresc      =  0
   LET p_nf_sup.val_ipi_nf          =  p_nota.vlripi
   LET p_nf_sup.val_ipi_calc        =  p_nota.vlripi
   LET p_nf_sup.val_despesa_aces    =  p_nota.vdicms
   LET p_nf_sup.val_adiant          =  0
   LET p_nf_sup.cod_mod_embar       =  p_cod_mod_embar
   LET p_nf_sup.cnd_pgto_nf         =  p_cnd_pgto
   LET p_nf_sup.nom_resp_aceite_er  =  ' '
   LET p_nf_sup.ies_incl_cap        =  'S'
   LET p_nf_sup.cod_operacao        =  p_cod_cfop
   LET p_nf_sup.ies_calc_subst      =  " "
   LET p_nf_sup.val_bc_subst_d      =  0
   LET p_nf_sup.val_bc_subst_c      =  0
   LET p_nf_sup.val_icms_subst_c    =  0
   LET p_nf_sup.val_icms_subst_d    =  0
   LET p_nf_sup.val_imp_renda       =  0
   LET p_nf_sup.val_bc_imp_renda    =  0
   LET p_nf_sup.ies_nf_aguard_nfe   =  p_tipo_nf

   IF p_nota.tiponf = '5' THEN
      LET p_nf_sup.ies_situa_import    =  'E'
   ELSE
      LET p_nf_sup.ies_situa_import    =  ' '
   END IF

#### A verificacao da amostra se contabiliza ou nao sera feita no POL1046 ####

{  if p_nota.amostr = 'S' then
      let p_nf_sup.ies_incl_contab = 'L'
   else}

LET p_nf_sup.ies_incl_contab     =  'N'

   INSERT INTO nf_sup VALUES (p_nf_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo NF na tabela nf_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_nf_sup.cod_empresa,
           p_nf_sup.num_aviso_rec,
           0,
           'meio_transp_ar',
           '','',1,'')

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo meio_transp_ar na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_nf_sup.cod_empresa,
           p_nf_sup.num_aviso_rec,
           0,
           'pend_calc_decl',
           'N','','',TODAY)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo pend_calc_decl na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF LENGTH(p_nota.marvol) > 0  THEN

      INSERT INTO sup_par_ar
       VALUES(p_nf_sup.cod_empresa,
              p_nf_sup.num_aviso_rec,
              0,
              'marca_vol_transp',
              '',
              p_nota.marvol,
              '','')

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo marca_vol_transp na tabela sup_par_ar'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END IF

      #IF NOT pol1025_le_nfe() THEN
      #   RETURN FALSE
      #END IF

   IF LENGTH(p_nota.numvol) > 0 THEN

      INSERT INTO sup_par_ar
       VALUES(p_nf_sup.cod_empresa,
              p_nf_sup.num_aviso_rec,
              0,
              'numeracao_vol_transp',
              '',
              p_nota.numvol,
              '','')

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo numeracao_vol_transp na tabela sup_par_ar'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END IF

   IF NOT pol1025_ins_nf_sup_compl() THEN  #para todas
      RETURN FALSE
   END IF

   #Ivo 17/02/2011

   LET p_dtemis = p_nota.dtdi[7,8],'/',
                  p_nota.dtdi[5,6],'/',
                  p_nota.dtdi[1,4]

   INSERT INTO sup_par_ar
    VALUES(p_nf_sup.cod_empresa,
           p_nf_sup.num_aviso_rec,
           0,
           'data_di_nf',
           '','',NULL,p_dtemis)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo data_di_nf na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_nf_sup.cod_empresa,
           p_nf_sup.num_aviso_rec,
           0,
           'local_desemb_nf',
           '',p_nota.nmurfd,NULL,NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo local_desemb_nf na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_nf_sup.cod_empresa,
           p_nf_sup.num_aviso_rec,
           0,
           'uf_desemb_nf',
           '',p_nota.ufdese,NULL,NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo uf_desemb_nf na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   #Fim alteração de 17/02/2011 - Ivo

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1025_ins_nf_sup_compl()
#----------------------------------#
   DEFINE l_cod_embal LIKE embalagem.cod_embal
   DEFINE p_nfe_sup RECORD LIKE nfe_sup_compl.*

   INITIALIZE p_nfe_sup, l_cod_embal TO NULL

   LET p_nfe_sup.cod_empresa      = p_cod_empresa
   LET p_nfe_sup.num_aviso_rec    = p_num_prx_ar
   LET p_nfe_sup.qtd_volumes      = p_nota.qtvolu
   LET p_nfe_sup.peso_bruto       = p_nota.pesobr

### Verifica o Cad.da embalagem, somente se tipo nf FOR <>  mae e compl ###
   IF  p_nota.tiponf <> '2' AND p_nota.tiponf <> '5' THEN
       IF  p_nota.especi IS NOT NULL THEN
           LET p_nfe_sup.den_embal    = p_nota.especi
           SELECT cod_embal
             INTO l_cod_embal
             FROM embalagem
           WHERE den_embal = p_nota.especi
           IF STATUS = 100 THEN
              LET p_msg = 'A especie enviada nao existe no Logix VDP0300'
              CALL pol1025_insere_erro()
              RETURN TRUE
           ELSE
             IF STATUS <> 0 THEN
                LET p_msg = 'Erro(',STATUS,') consistindo ',
                            'especie enviada na tabela embalagem'
                CALL pol1025_insere_erro()
                RETURN FALSE
             END IF
           END IF
         IF l_cod_embal IS NOT NULL THEN
            INSERT INTO sup_par_ar
            VALUES (p_nfe_sup.cod_empresa, p_nfe_sup.num_aviso_rec,"0",       "cod_embalagem_nf","",l_cod_embal,"",TODAY)

            IF sqlca.sqlcode <> 0 THEN
               LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela sup_par_ar.cod_embal'
               CALL pol1025_insere_erro()
               RETURN FALSE
            END IF
         END IF
       END IF
   END IF
   IF p_nota.tiponf = '2' THEN
      LET p_nfe_sup.peso_liquido     = ''
   ELSE
      LET p_nfe_sup.peso_liquido     = p_nota.pesolq
   END IF

#### Conforme solicitacao da Luciana Fiscal, em 13/04/2011 ####
#### Estamos limpando o texto de obs de DIF.ARRED R$ 9,99, pois estava ####
#### c/diferenças em quase todas as notas, notas mae, filha e primeira ####

   IF p_nota.tiponf = '6' OR p_nota.tiponf = '5' THEN
      LET p_nota.msgadi[221,240] = "                   "
   ELSE
     IF p_nota.tiponf = '1' THEN
        LET p_nota.msgadi[201,240]= "                                     "
     END IF
   END IF

   LET p_nfe_sup.texto_compl1     = p_nota.msgadi[1,120]
   LET p_nfe_sup.texto_compl2     = p_nota.msgadi[121,240]
   LET p_nfe_sup.ies_nfe_emit     = 'N'
   LET p_nfe_sup.num_proc_imp_nfs = p_nota.nfeasy
   LET p_nfe_sup.ies_proc_nfs     = '2'

   INSERT INTO nfe_sup_compl
     VALUES(p_nfe_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela nfe_sup_compl'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1025_le_nfe()
#------------------------#

   select nferp
     into p_num_nf
     from easy:ei10
    where codemp = p_nota.codemp
      and forlog = p_nota.forlog
      and nfeasy = p_nota.nfrefe
      and sreasy = p_nota.srrefe

   SELECT cod_fornecedor
          ser_nf,
          ssr_nf
     INTO p_cod_fornecedor,
          p_num_ser,
          p_ssr_nf
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_nf

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo numero da NFE na tabela nf_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1025_ins_nf_erro()
#----------------------------#

   let p_num_seq_erro               = p_num_seq_erro + 1
   let p_nf_erro.empresa            = p_cod_empresa
   let p_nf_erro.num_aviso_rec      = p_num_prx_ar
   let p_nf_erro.num_seq            = 0
   let p_nf_erro.des_pendencia_item = p_den_erro
   let p_nf_erro.ies_origem_erro    = p_num_seq_erro
   let p_nf_erro.ies_erro_grave     = 'N'
   let p_nf_erro.num_transac        = 0

   INSERT INTO nf_sup_erro
      VALUES(p_nf_erro.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela nf_sup_erro'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1025_especie_nf()
#---------------------------#

   case p_nota.tiponf
      when '1' RETURN 'NF'
      when '2' RETURN 'NFC'
      when '5' RETURN 'NFE'
      when '6' RETURN 'NF'
   end case

END FUNCTION


#-----------------------------#
 FUNCTION pol1025_gera_num_ar()
#-----------------------------#

   SELECT par_val
     INTO p_num_prx_ar
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "num_prx_ar"

    IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo proximo numero do AR da tabela par_sup_pad'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   UPDATE par_sup_pad
      SET par_val = (par_val + 1)
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "num_prx_ar"

    IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando numero do AR na tabela par_sup_pad'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1025_insere_itens()
#------------------------------#

   LET p_ar_compl.cod_empresa      = p_cod_empresa
   LET p_ar_compl.num_aviso_rec    = p_nf_sup.num_aviso_rec
   LET p_ar_compl.cod_transpor     = p_nf_sup.cod_transpor
   let p_val_tot_acres = 0

   IF p_nota.tiponf = '2' THEN
      LET p_ar_compl.den_transpor  = ''
   ELSE
      LET p_ar_compl.den_transpor  = p_nom_transpor
   END IF

   LET p_ar_compl.num_di           = p_nota.numdi
   LET p_ar_compl.cod_fiscal_compl = '0'
   LET p_ar_compl.dat_proces       = ' '
   LET p_ar_compl.ies_situacao     = 'N'
   let p_ar_compl.cod_operacao     = p_opest
   let p_ar_compl.nom_usuario      = p_user
   let p_ar_compl.dat_proces       = date
   let p_ar_compl.hor_operac       = time

   INSERT INTO aviso_rec_compl
       VALUES (p_ar_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela aviso_rec_compl'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_seq_ar = 0

   DECLARE cq_ins_it CURSOR FOR
    SELECT *
      FROM easy:ei11
     WHERE codemp = p_cod_empresa
       AND nfeasy = p_nota.nfeasy
       AND sreasy = p_nota.sreasy
       AND forlog = p_nota.forlog
       AND flag   = 'N'
     ORDER BY linha

   FOREACH cq_ins_it INTO p_item.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela ei11 p/ inserir no Logix '
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      IF NOT pol1025_ins_ar() THEN
         RETURN FALSE
      END IF

      if p_tipo_nf = 6 then
         IF NOT pol1025_ins_move_val() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT pol1025_atu_ei11() THEN
         RETURN FALSE
      END IF

   END FOREACH

   IF NOT pol1025_atu_nf_sup() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1025_atu_nf_sup()
#----------------------------#

   IF p_nota.tiponf = '6' THEN

      UPDATE nf_sup
         SET val_despesa_aces = p_val_tot_da,
             val_tot_nf_c   = val_tot_nf_c + p_val_tot_da,
             val_tot_nf_d   = val_tot_nf_d + p_val_tot_da,
             val_tot_acresc = p_val_tot_acres
       WHERE cod_empresa =   p_nf_sup.cod_empresa
         AND num_aviso_rec = p_nf_sup.num_aviso_rec
   else

      UPDATE nf_sup
         SET val_tot_acresc = p_val_tot_acres
       WHERE cod_empresa =   p_nf_sup.cod_empresa
         AND num_aviso_rec = p_nf_sup.num_aviso_rec

   end if

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando val desp acessória na nf_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1025_ins_ar()
#------------------------#
DEFINE l_pct_red_bas_calc LIKE icms.pct_red_base_calc
DEFINE l_ies_obj_entrada  LIKE grupo_ctr_desp.gru_ctr_desp

INITIALIZE l_ies_obf_entrada  TO NULL 

LET l_pct_red_bas_calc = 0

   LET p_seq_ar = p_seq_ar + 1

   LET p_aviso_rec.cod_empresa         = p_cod_empresa
   LET p_aviso_rec.cod_empresa_estab   = p_nf_sup.cod_empresa_estab
   LET p_aviso_rec.num_aviso_rec       = p_num_prx_ar
   LET p_aviso_rec.num_seq             = p_seq_ar
   LET p_aviso_rec.cod_item            = p_item.cdprod
   LET p_aviso_rec.cod_unid_med_nf     = p_item.unidad
   LET p_aviso_rec.dat_inclusao_seq    = p_dat_proces
   LET p_aviso_rec.ies_incl_almox      = "N"
   LET p_aviso_rec.ies_receb_fiscal    = "S"
   LET p_aviso_rec.ies_liberacao_ar    = "1"
   LET p_aviso_rec.ies_diverg_listada  = "N"
   LET p_aviso_rec.ies_controle_lote   = "N"
   LET p_aviso_rec.dat_devoluc         = ' '
   LET p_aviso_rec.dat_ref_val_compl   = ' '
   LET p_aviso_rec.den_item            = p_item.dscdi

   SELECT ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao,
          cod_cla_fisc,
          cod_local_estoq,
          cod_lin_prod,
          cod_lin_recei
     INTO p_ies_ctr_estoq,
          p_ies_ctr_lote,
          p_ies_inspecao,
          p_aviso_rec.cod_cla_fisc,
          p_aviso_rec.cod_local_estoq,
          p_aen.cod_lin_prod,
          p_aen.cod_lin_recei
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item   = p_aviso_rec.cod_item

   IF status <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados do item da tabela item'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_aviso_rec.cod_local_estoq IS NULL THEN
      LET p_aviso_rec.cod_local_estoq = ' '
   END IF

   let p_aen.cod_seg_merc = 0
   let p_aen.cod_cla_uso  = 0

   SELECT cod_comprador,
          gru_ctr_desp,
          cod_tip_despesa,
          ies_tip_incid_ipi
     INTO p_aviso_rec.cod_comprador,
          p_aviso_rec.gru_ctr_desp_item,
          p_aviso_rec.cod_tip_despesa,
          p_aviso_rec.ies_tip_incid_ipi
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_item.oclog
      AND cod_item    = p_item.cdprod
      AND ies_versao_atual = 'S'

   IF status <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados do item da tabela ordem_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_aviso_rec.val_base_c_ipi_it   = p_item.vbipi

   IF p_nota.tiponf = '2' THEN
      LET p_aviso_rec.gru_ctr_desp_item = '17'
   END IF

   IF p_nota.tiponf MATCHES '[26]' THEN
      LET p_aviso_rec.ies_tip_incid_ipi = 'O'
   END IF

   if p_aviso_rec.ies_tip_incid_ipi = 'O' then
      let p_aviso_rec.cod_incid_ipi = '3'
   else
      if p_aviso_rec.ies_tip_incid_ipi = 'I' then
         let p_aviso_rec.cod_incid_ipi = '2'
      else
         let p_aviso_rec.cod_incid_ipi = '1'
      end if
   end if

   LET p_aviso_rec.cod_cla_fisc_nf     = p_aviso_rec.cod_cla_fisc
   LET p_aviso_rec.val_despesa_aces_i  = p_item.vdicms

   IF p_nota.tiponf = '6' THEN
      let p_cod_item = p_aviso_rec.cod_item
      IF NOT pol1025_calc_da_filha() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_aviso_rec.pct_direito_cred    = 100
   LET p_aviso_rec.ies_bitributacao    = "S"
   LET p_aviso_rec.val_base_c_ipi_da   = 0
   LET p_aviso_rec.val_ipi_decl_item   = 0 #p_item.vlripi
   LET p_aviso_rec.pct_ipi_declarad    = p_item.peripi
   LET p_aviso_rec.pct_ipi_tabela      = p_item.peripi
   LET p_aviso_rec.val_ipi_calc_item   = p_item.vlripi
   LET p_aviso_rec.val_ipi_desp_aces   = 0
   LET p_aviso_rec.val_desc_item       = 0
   LET p_aviso_rec.qtd_declarad_nf     = p_item.qtde
   LET p_aviso_rec.qtd_devolvid        = 0
   LET p_aviso_rec.val_devoluc         = 0
   LET p_aviso_rec.num_nf_dev          = 0
   LET p_aviso_rec.qtd_rejeit          = 0
   LET p_aviso_rec.qtd_liber           = 0 #Obs
   LET p_aviso_rec.qtd_liber_excep     = 0
   LET p_aviso_rec.cus_tot_item        = 0
   LET p_aviso_rec.cod_fiscal_item     = p_item.cfop[1],'.',p_item.cfop[2,5]
   LET p_aviso_rec.num_lote            = ''
   LET p_aviso_rec.cod_operac_estoq    = p_opest

   LET p_aviso_rec.qtd_recebida        = p_item.qtde

   IF p_nota.tiponf MATCHES '[16]' THEN
      LET p_aviso_rec.qtd_recebida = 0
   end if

   IF p_nota.tiponf = '6' THEN
      LET p_aviso_rec.cod_incid_ipi = '3'

### Conforme solicitacao da Luciana - Fiscal em 10/01/2012 se FOR nf Filha e o ###
### objetivo entrada FOR = 6 CIAP - ativo alterar o grupo desp para 506        ###

      SELECT ies_obj_entrada
        INTO l_ies_obj_entrada
        FROM grupo_ctr_desp
       WHERE cod_empresa  = p_aviso_rec.cod_empresa
         AND gru_ctr_desp = p_aviso_rec.gru_ctr_desp_item

      IF l_ies_obj_entrada = 6 THEN
         LET p_aviso_rec.gru_ctr_desp_item = 506
      ELSE 
        LET p_aviso_rec.gru_ctr_desp_item  = 99
      END IF  
   
   END IF

   LET p_aviso_rec.ies_item_estoq      = p_ies_ctr_estoq

### Para itens cujo grp desp. tenha reducao de base icms muda vlr contab ###

   SELECT  pct_red_base_calc
     INTO  l_pct_red_bas_calc
     FROM  icms
    WHERE  gru_ctr_desp    = p_aviso_rec.gru_ctr_desp_item
      AND  cod_empresa     = p_aviso_rec.cod_empresa
      AND  cod_uni_feder   = p_cod_uni_feder

   IF l_pct_red_bas_calc <> 0
   THEN
     LET p_aviso_rec.val_contabil_item = p_item.vlrcif + p_item.vlrii + p_item.vlripi + p_item.vlricm + p_item.vlrpis + p_item.vlrcof + p_item.vdicms
   ELSE
     LET p_aviso_rec.val_contabil_item   = p_item.vbicms
   END IF

   IF p_nota.tiponf MATCHES '[56]' THEN
      IF p_nota.tiponf = '5' THEN
         LET p_aviso_rec.ies_item_estoq = p_ies_ctr_estoq
      END IF
      LET p_aviso_rec.val_frete           = 0
      LET p_aviso_rec.val_base_c_frete_d  = 0
      LET p_aviso_rec.val_base_c_frete_c  = 0
   ELSE
      LET p_aviso_rec.val_frete           = p_item.vlrfre
      LET p_aviso_rec.val_base_c_frete_d  = p_item.vlrfre
      LET p_aviso_rec.val_base_c_frete_c  = p_item.vlrfre
   END IF

   IF p_nota.tiponf MATCHES '[156]' THEN
      LET p_aviso_rec.val_liquido_item    = p_item.prctot + p_item.vdicms
      IF p_nota.tiponf = '6' then
         LET p_aviso_rec.val_liquido_item = p_aviso_rec.val_liquido_item + p_aviso_rec.val_despesa_aces_i
      end if
   else
      LET p_aviso_rec.val_liquido_item    = p_item.vbicms
   end if

   if p_nota.tiponf MATCHES '[25]' then
      LET p_aviso_rec.ies_liberacao_insp = 'S'
      LET p_aviso_rec.ies_situa_ar       = "E"
   else
      LET p_aviso_rec.ies_liberacao_insp = 'N'
      LET p_aviso_rec.ies_situa_ar       = "C"
   end if

   LET p_aviso_rec.ies_liberacao_cont  = p_aviso_rec.ies_liberacao_insp

   LET p_preco_txt = p_item.prcuni

   IF p_nota.tiponf = '2' THEN
      LET p_aviso_rec.ies_situa_ar = "E"
      LET p_aviso_rec.num_pedido   = ''
      LET p_aviso_rec.num_oc       = ''
      LET p_preco_txt = p_aviso_rec.val_liquido_item
   ELSE
      LET p_aviso_rec.num_pedido   = p_item.numped
      LET p_aviso_rec.num_oc       = p_item.oclog
   END IF

   call pol1025_calc_acres()

   LET p_aviso_rec.pre_unit_nf = p_preco_dec4
   LET p_aviso_rec.val_acrescimos = p_val_acres
   let p_val_tot_acres = p_val_tot_acres + p_val_acres

   LET p_aviso_rec.ies_da_bc_ipi = "N"

   LET p_aviso_rec.pct_red_bc_item_d   = 0
   LET p_aviso_rec.pct_red_bc_item_c   = 0
   LET p_aviso_rec.pct_diferen_item_d  = 0
   LET p_aviso_rec.pct_diferen_item_c  = 0
   LET p_aviso_rec.val_icms_item_c     = p_item.vlricm

   SELECT ies_tip_incid_icms,
          num_conta
     INTO p_aviso_rec.ies_incid_icms_ite,
          p_num_conta
     FROM item_sup
    WHERE cod_empresa = p_aviso_rec.cod_empresa
      AND cod_item    = p_aviso_rec.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo conta contabil da tabela item_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   if p_nota.tiponf MATCHES '[15]' then
      LET p_aviso_rec.val_base_c_item_d = p_item.vbicms - p_item.bdicms
      LET p_aviso_rec.val_icms_item_d   = p_item.vlricm - p_item.vicda
      LET p_aviso_rec.pct_icms_item_d   = p_item.pericm
      LET p_aviso_rec.val_base_c_item_c = p_aviso_rec.val_base_c_item_d
      LET p_aviso_rec.val_icms_item_c   = p_aviso_rec.val_icms_item_d
      LET p_aviso_rec.pct_icms_item_c   = p_aviso_rec.pct_icms_item_d
   else
      LET p_aviso_rec.val_base_c_item_d = 0
      LET p_aviso_rec.val_icms_item_d   = 0
      LET p_aviso_rec.pct_icms_item_d   = 0
      LET p_aviso_rec.val_base_c_item_c = p_item.vbicms
      LET p_aviso_rec.val_icms_item_c   = p_item.vlricm
      LET p_aviso_rec.pct_icms_item_c   = p_item.pericm
      LET p_aviso_rec.ies_incid_icms_ite = "O"
   end if

   IF p_item.cfop = '3127' THEN
      LET p_aviso_rec.val_base_c_item_c = p_item.prctot
      LET p_aviso_rec.val_base_c_item_d = 0
   END IF


   {if not pol1025_calc_bc_icms_da() then
      RETURN false
   end if}

   LET p_aviso_rec.val_base_c_icms_da   = p_item.bdicms  # p_val_bc_icms_da
   LET p_aviso_rec.val_icms_diferen_i   = 0
   LET p_aviso_rec.val_icms_desp_aces   = p_item.vicda   #p_aviso_rec.val_base_c_icms_da * p_aviso_rec.pct_icms_item_c / 100
   LET p_aviso_rec.val_icms_frete_d     = 0
   LET p_aviso_rec.val_icms_frete_c     = 0
   LET p_aviso_rec.pct_icms_frete_d     = 0
   LET p_aviso_rec.pct_icms_frete_c     = 0
   LET p_aviso_rec.val_icms_diferen_f   = 0
   LET p_aviso_rec.pct_red_bc_frete_d   = 0
   LET p_aviso_rec.pct_red_bc_frete_c   = 0
   LET p_aviso_rec.pct_diferen_fret_d   = 0
   LET p_aviso_rec.pct_diferen_fret_c   = 0
   LET p_aviso_rec.val_enc_financ       = 0
   LET p_aviso_rec.ies_total_nf         = "S"
   LET p_aviso_rec.val_compl_estoque    = 0
   LET p_aviso_rec.pct_enc_financ       = 0

   if p_nota.amostr = 'S' then
      LET p_aviso_rec.ies_contabil         = "N"
   else
      LET p_aviso_rec.ies_contabil         = "S"
   end if


   INSERT INTO aviso_rec    VALUES (p_aviso_rec.*)
   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo o item na tabela aviso_rec'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_audit_ar.cod_empresa    = p_cod_empresa
   LET p_audit_ar.num_aviso_rec  = p_aviso_rec.num_aviso_rec
   LET p_audit_ar.num_seq        = p_aviso_rec.num_seq
   LET p_audit_ar.nom_usuario    = p_user
   LET p_audit_ar.dat_hor_proces = CURRENT
   LET p_audit_ar.num_prog       = 'pol1025'
   LET p_audit_ar.ies_tipo_auditoria = '1'

   INSERT INTO audit_ar VALUES(p_audit_ar.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela audit_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF



   LET p_dest_ar.cod_empresa        = p_cod_empresa
   LET p_dest_ar.num_aviso_rec      = p_aviso_rec.num_aviso_rec
   LET p_dest_ar.num_seq            = p_aviso_rec.num_seq

   LET p_dest_seq = 0

   DECLARE cq_dest_sup CURSOR FOR
    SELECT cod_area_negocio,
           cod_lin_negocio,
           pct_particip_comp,
           num_conta_deb_desp,
           cod_secao_receb
      FROM dest_ordem_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_oc      = p_item.oclog

   FOREACH cq_dest_sup INTO
           p_dest_ar.cod_area_negocio,
           p_dest_ar.cod_lin_negocio,
           p_dest_ar.pct_particip_comp,
           p_dest_ar.num_conta_deb_desp,
           p_dest_ar.cod_secao_receb

      LET p_dest_seq = p_dest_seq + 1
      LET p_dest_ar.sequencia    = p_dest_seq
      LET p_dest_ar.qtd_recebida = p_aviso_rec.qtd_recebida
      LET p_dest_ar.ies_contagem = 'N'

      INSERT INTO dest_aviso_rec VALUES (p_dest_ar.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela dest_aviso_rec'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END FOREACH

   LET p_ar_sq.cod_empresa       =  p_cod_empresa
   LET p_ar_sq.num_aviso_rec     =  p_aviso_rec.num_aviso_rec
   LET p_ar_sq.num_seq           =  p_aviso_rec.num_seq
   LET p_ar_sq.cod_fiscal_compl  =  0
   LET p_ar_sq.val_base_d_ipi_it =  0

   INSERT INTO aviso_rec_compl_sq VALUES (p_ar_sq.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela aviso_rec_compl_sq'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   {IF p_nota.tiponf = '5' THEN
      IF NOT pol1025_ins_nf_pend() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_nota.tiponf = '6' THEN
         IF NOT pol1025_ins_ar_x_nf_pend() THEN
            RETURN FALSE
         END IF
      END IF
   END IF}

   LET p_par_ind = 'S'

   IF p_nota.tiponf MATCHES '[15]' THEN
      IF NOT pol1025_ins_pis_cof() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_nota.tiponf MATCHES '[16]' THEN
      IF NOT pol1025_ins_ar_ped() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1025_ins_par_ar() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1025_calc_acres()
#---------------------------#

   define p_dig   char(01),
          p_int   char(07),
          p_dec   char(05),
          p_tam   INTEGER,
          p_ponto SMALLINT,
          p_qtd   DECIMAL(10,3),
          p_dif   DECIMAL(17,8)

   let p_ponto = false
   let p_tam = LENGTH(p_preco_txt)
   let p_dec = ''
   let p_int = ''

   for p_ind = 1 to p_tam
       let p_dig = p_preco_txt[p_ind]
       if p_dig = '.' then
          let p_ponto = true
       end if
       if p_ponto then
          let p_dec = p_dec CLIPPED, p_dig
       else
          let p_int = p_int CLIPPED, p_dig
       end if
   end for

   let p_preco_dec8 = p_preco_txt
   let p_preco_txt  = p_int
   let p_preco_txt  = p_preco_txt CLIPPED, p_dec
   let p_preco_dec4 = p_preco_txt
   let p_dif        = p_preco_dec8 - p_preco_dec4
   let p_qtd        = p_item.qtde
   let p_val_acres  = p_dif * p_qtd

END FUNCTION

#---------------------------#
FUNCTION pol1025_ins_da_mae()
#---------------------------#

   DELETE FROM nf_tmp_912

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') limpando tabela temporaria nf_tmp_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   declare cq_mae cursor for
    SELECT a.cod_item,
           a.num_oc,
           b.splog,
           SUM(a.qtd_declarad_nf),
           SUM(a.val_despesa_aces_i)
      FROM aviso_rec a,
           easy:ei11 b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_aviso_rec = p_num_aviso
       AND a.cod_empresa   = b.codemp
       AND a.num_aviso_rec = b.nferp
       AND a.num_oc        = b.oclog
       AND a.num_seq       = b.linha
  GROUP BY 1, 2, 3

   FOREACH cq_mae into p_cod_item, p_num_oc, p_seq_prog, p_qtd_mae, p_val_mae

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') sumarizando desp acessoria da NF mae na tab aviso_rec '
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      insert into nf_tmp_912
       values(p_cod_item, p_num_oc, p_seq_prog, p_qtd_mae, p_val_mae, 0, 0)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo desp aces da NF mae na tab nf_tmp_912'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END FOREACH

   RETURN true

END FUNCTION

#------------------------------#
FUNCTION pol1025_calc_da_filha()
#------------------------------#

   DEFINE p_val_da DECIMAL(17,6),
          p_qtde   DECIMAL(10,3)

   let p_qtde      = p_item.qtde
   let p_qtd_filha = p_qtde
   let p_val_filha = 0
   let p_num_oc    = p_item.oclog
   let p_seq_prog  = p_item.splog

   declare cq_filha cursor for
    select nferp
      from easy:ei10
     where codemp = p_cod_empresa
       and nfrefe = p_nota.nfrefe
       and forlog = p_nota.forlog
       and tiponf = '6'
       and LENGTH(nferp) > 0

   FOREACH cq_filha into p_num_aviso

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo notas filhas da tab ei10'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

      SELECT qtd_declarad_nf,
             val_despesa_aces_i
        into p_qtd_ar,
             p_val_ar
        FROM aviso_rec, easy:ei11
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso
         and cod_item      = p_cod_item
         and num_oc        = p_num_oc
         and codemp        = cod_empresa
         and nferp         = num_aviso_rec
         and linha         = num_seq
         and splog         = p_seq_prog

      if status = 100 then
         CONTINUE FOREACH
      else
         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') sumarizando desp acessoria NF filha na tab aviso_rec '
            CALL pol1025_insere_erro()
            RETURN FALSE
         end if
      END IF

      if p_qtd_ar is null then
         let p_qtd_ar = 0
         let p_val_ar = 0
      end if

      let p_qtd_filha = p_qtd_filha + p_qtd_ar
      let p_val_filha = p_val_filha + p_val_ar

   END FOREACH

   UPDATE nf_tmp_912
      set qtd_filha = qtd_filha + p_qtd_filha,
          val_filha = val_filha + p_val_filha
    WHERE cod_item = p_cod_item
      AND num_oc   = p_num_oc
      AND seq_prog = p_seq_prog

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo desp aces da NF filha na tab nf_tmp_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   select qtd_mae,
          val_mae,
          qtd_filha,
          val_filha
     into p_qtd_mae,
          p_val_mae,
          p_qtd_filha,
          p_val_filha
     from nf_tmp_912
    where cod_item = p_cod_item
      AND num_oc   = p_num_oc
      AND seq_prog = p_seq_prog

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo desp aces da tabela nf_tmp_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   if p_qtd_mae = p_qtd_filha then
      let p_val_da = p_val_mae - p_val_filha
   else
      let p_val_da = (p_val_mae / p_qtd_mae) * p_qtde
   end if

   UPDATE nf_tmp_912
      set val_filha = val_filha + p_val_da
    WHERE cod_item = p_cod_item
      AND num_oc   = p_num_oc
      AND seq_prog = p_seq_prog

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando desp aces da NF filha na tab nf_tmp_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_aviso_rec.val_despesa_aces_i = p_val_da

   LET p_val_tot_da = p_val_tot_da + p_aviso_rec.val_despesa_aces_i

   RETURN true

end FUNCTION





#---------------------------------#
FUNCTION pol1025_calc_bc_icms_da()
#---------------------------------#

   define p_val_prop_pis_cof like aviso_rec.val_base_c_icms_da,
          p_par_ies          char(01)

   select par_ies
     into p_par_ies
     from par_sup_pad
    where cod_empresa   = p_cod_empresa
      and cod_parametro = 'icms_ec_33'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo parametro icms_ec_33 da tabela par_sup_pad'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_par_ies MATCHES '[SN]' THEN
   else
      LET p_msg = 'Parametro icms_ec_33 do sup8740 com conteudo invalido'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   let p_val_prop_pis_cof =
       p_aviso_rec.val_despesa_aces_i * (p_item.vlrpis + p_item.vlrcof) / p_aviso_rec.val_liquido_item

   if p_par_ies = 'N' then
      let p_val_bc_icms_da =
          (p_aviso_rec.val_despesa_aces_i + p_val_prop_pis_cof)
   else
      let p_val_bc_icms_da =
          (p_aviso_rec.val_despesa_aces_i + p_val_prop_pis_cof) / ((100 - p_aviso_rec.pct_icms_item_c)/100)
   end if

   RETURN true

end FUNCTION

#-----------------------------#
FUNCTION pol1025_ins_pis_cof()
#-----------------------------#

   define p_sup_ar record like sup_ar_piscofim.*

   let p_sup_ar.empresa            =  p_aviso_rec.cod_empresa
   let p_sup_ar.aviso_recebto      =  p_aviso_rec.num_aviso_rec
   let p_sup_ar.seq_aviso_recebto  =  p_aviso_rec.num_seq
   let p_sup_ar.val_bc_pis_import  =  p_item.vbpis
   let p_sup_ar.val_bc_cofins_imp  =  p_item.vbcof
   let p_sup_ar.pct_pis_import     =  p_item.perpis
   let p_sup_ar.pct_cofins_import  =  p_item.percof
   let p_sup_ar.pct_red_pis_import =  0
   let p_sup_ar.pct_red_cofins_imp =  0
   let p_sup_ar.val_pis_import     =  p_item.vlrpis
   let p_sup_ar.val_cofins_import  =  p_item.vlrcof

   INSERT INTO sup_ar_piscofim
    VALUES(p_sup_ar.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo pis/cofins na tabela sup_ar_piscofim'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   LET p_par_ind = 'S'

   insert into ar_pis_cofins
    values(p_sup_ar.empresa,
           p_sup_ar.aviso_recebto,
           p_sup_ar.seq_aviso_recebto,
           p_sup_ar.val_bc_pis_import,
           p_sup_ar.val_bc_cofins_imp,
           p_sup_ar.pct_pis_import,
           p_sup_ar.pct_cofins_import,
           p_sup_ar.val_pis_import,
           p_sup_ar.val_cofins_import,'U')

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo pis/cofins na tabela ar_pis_cofins'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_ins_ar_ped()
#-----------------------------#

   DEFINE p_ies_tip_entrega char(01)

   SELECT num_versao
     INTO p_num_versao
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_item.oclog
      AND cod_item    = p_item.cdprod
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo versao da OC na tab ordem_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   SELECT qtd_solic
     INTO p_qtd_solic
     FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_item.oclog
      AND num_versao  = p_num_versao
      AND num_prog_entrega = p_item.splog

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo quantidade da OC na tab prog_ordem_sup'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_qtd_solic = p_aviso_rec.qtd_declarad_nf then
      let p_ies_tip_entrega = 'T'
   ELSE
      let p_ies_tip_entrega = 'P'
   END IF

   INSERT INTO ar_ped
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           p_aviso_rec.num_pedido,
           p_aviso_rec.num_oc,
           p_item.splog,
           p_ies_tip_entrega,
           p_aviso_rec.qtd_declarad_nf,   #qtd_reservada
           p_aviso_rec.qtd_recebida,
           p_aviso_rec.qtd_devolvid)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo tabela ar_ped'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION pol1025_ins_par_ar()
#-----------------------------#

   IF p_item.cfop = '3127' THEN
      INSERT INTO sup_par_ar
       VALUES(p_aviso_rec.cod_empresa,
              p_aviso_rec.num_aviso_rec,
              p_aviso_rec.num_seq,
              'calc_piscofins_imp',
              'N','DRAWBACK','','')

   ELSE
      IF p_nota.tiponf = '2' THEN
         INSERT INTO sup_par_ar
          VALUES(p_aviso_rec.cod_empresa,
                 p_aviso_rec.num_aviso_rec,
                 p_aviso_rec.num_seq,
                 'calc_piscofins_imp',
                 'N','NFC',
                 '','')
      ELSE
         INSERT INTO sup_par_ar
          VALUES(p_aviso_rec.cod_empresa,
                 p_aviso_rec.num_aviso_rec,
                 p_aviso_rec.num_seq,
                 'calc_piscofins_imp',
                 p_par_ind,
                 '','','')
      END IF
   END IF

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo calc_piscofins_imp na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_item.vlrii > "0" AND p_nota.tiponf <> '6' THEN

      let p_valor = p_item.vlrii

      INSERT INTO sup_par_ar
       VALUES(p_aviso_rec.cod_empresa,
              p_aviso_rec.num_aviso_rec,
              p_aviso_rec.num_seq,
              'valor_ii',
              '','',
              p_valor,'')

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo valor_ii na tabela sup_par_ar'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END IF

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'cod_municipal_serv',
           '','','','')

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo cod_municipal_serv na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'desconto_fiscal',
           '','',0,'')

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo desconto_fiscal na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF


   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'pct_extravio_granel',
           '','',0,'')

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo pct_extravio_granel na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_nota.tiponf = '2' THEN

      let p_msg = 'NF.ORIG:',p_nota.nfrefe CLIPPED
      let p_msg = p_msg CLIPPED,p_serie
      let p_msg = p_msg CLIPPED,p_sserie
      let p_msg = p_msg CLIPPED, ' ',p_especie

      INSERT INTO sup_par_ar
       VALUES(p_aviso_rec.cod_empresa,
              p_aviso_rec.num_aviso_rec,
              p_aviso_rec.num_seq,
              p_msg,
              '',
              '',
              '',
              '')

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo pct_extravio_granel na tabela sup_par_ar'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF

   END IF

   #Ivo 17/02/2011

   LET p_dtemis = p_nota.dtdese[7,8],'/',
                  p_nota.dtdese[5,6],'/',
                  p_nota.dtdese[1,4]

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'data_desembaraco',
           '','',NULL,p_dtemis)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo data_desembaraco na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'seq_item_adicao',
           '','',p_item.sqadic,NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo seq_item_adicao na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'num_adicao_di',
           '','',p_item.nradic,NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo num_adicao_di na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   SELECT cod_fabric
     INTO p_cod_fabricante
     FROM fabric_item_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_aviso_rec.cod_item
      AND cod_fornec  = p_nf_sup.cod_fornecedor

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo fabricante da tabela fabric_item_912'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO sup_par_ar
    VALUES(p_aviso_rec.cod_empresa,
           p_aviso_rec.num_aviso_rec,
           p_aviso_rec.num_seq,
           'fabricante_item',
           '',p_cod_fabricante,NULL,NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo fabricante_item na tabela sup_par_ar'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   #Fim das alterações de 17/02/2011 - ivo

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_ins_nf_pend()
#-----------------------------#

   DEFINE p_nf_pend RECORD LIKE nf_pend.*

   LET p_nf_pend.cod_empresa      = p_nf_sup.cod_empresa
   LET p_nf_pend.num_nf           = p_nf_sup.num_nf
   LET p_nf_pend.ser_nf           = p_nf_sup.ser_nf
   LET p_nf_pend.ssr_nf           = 0
   LET p_nf_pend.cod_fornecedor   = p_nf_sup.cod_fornecedor
   LET p_nf_pend.cod_item         = p_aviso_rec.cod_item
   LET p_nf_pend.qtd_recebida     = p_aviso_rec.qtd_recebida
   LET p_nf_pend.qtd_regularizada = 0
   LET p_nf_pend.tex_observ       = ''
   LET p_nf_pend.dat_inclusao     = p_nf_sup.dat_entrada_nf

   INSERT INTO nf_pend
      VALUES(p_nf_pend.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela nf_pend'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1025_ins_ar_x_nf_pend()
#----------------------------------#

   DEFINE p_ar_pend RECORD LIKE ar_x_nf_pend.*

   LET p_ar_pend.cod_empresa      = p_nf_sup.cod_empresa
   LET p_ar_pend.num_nf           = p_num_nf
   LET p_ar_pend.ser_nf           = p_num_ser
   LET p_ar_pend.ssr_nf           = 0
   LET p_ar_pend.cod_fornecedor   = p_cod_fornecedor
   LET p_ar_pend.cod_item         = p_aviso_rec.cod_item
   LET p_ar_pend.num_aviso_rec    = p_nf_sup.num_aviso_rec
   LET p_ar_pend.num_seq          = p_aviso_rec.num_seq
   LET p_ar_pend.qtd_regularizada = p_aviso_rec.qtd_recebida
   LET p_ar_pend.dat_inclusao     = p_nf_sup.dat_entrada_nf
   LET p_ar_pend.cod_fornec_nfp   = p_nf_sup.cod_fornecedor

   INSERT INTO ar_x_nf_pend
      VALUES(p_ar_pend.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ar_x_nf_pend'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   UPDATE nf_pend
      SET qtd_regularizada = qtd_regularizada + p_aviso_rec.qtd_recebida
    WHERE cod_empresa    = p_cod_empresa
      AND num_nf         = p_num_nf
      AND ser_nf         = p_num_ser
      AND ssr_nf         = 0
      AND cod_fornecedor = p_cod_fornecedor
      AND cod_item       = p_aviso_rec.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando qtd regularizada na tab nf_pend'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1025_emp_existe(p_codemp)
#------------------------------------#

   DEFINE p_codemp CHAR(02)

   SELECT cod_empresa
     FROM empresa
    WHERE cod_empresa = p_codemp

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_chec_pedido()
#-----------------------------#

   #Obs: ver que status deve estar o pedido, para
   #aceitar a compra

   DEFINE p_ies_situa CHAR(01)

   SELECT ies_situa_ped,
          cnd_pgto,
          cod_mod_embar
     INTO p_ies_situa,
          p_cnd_pgto,
          p_cod_mod_embar
     FROM pedido_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'O pedido enviado nao existe no Logix'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_ies_situa = 'R' or p_nota.tiponf = '2' THEN
   else
      LET p_msg = 'O pedido enviado nao esta liberado para compra'
      CALL pol1025_insere_erro()
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_chec_ordem()
#-----------------------------#

   DEFINE p_ies_situa CHAR(01)

   SELECT ies_situa_oc,
          num_versao
     INTO p_ies_situa,
          p_num_versao
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_item.oclog
      AND cod_item    = p_item.cdprod
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'A ordem enviada nao existe no Logix'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF p_ies_situa MATCHES '[R]' or p_nota.tiponf = '2'
   THEN
   ELSE
      LET p_msg = 'A ordem enviada nao esta liberada para compra'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1025_chec_prog_ent()
#-------------------------------#

   SELECT qtd_solic,
          qtd_recebida
     INTO p_qtd_solic,
          p_qtd_recebida
     FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_item.oclog
      AND num_versao  = p_num_versao
      AND num_prog_entrega = p_item.splog

   IF STATUS <> 0 THEN
      LET p_msg = 'Nao foi possivel encontrar a ',
                  'programacao de entrega correspondente'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   if p_nota.tiponf = '2' then
      RETURN true
   end if

   select sum(qtd_reservada)
     INTO p_qtd_reservada
     from ar_ped, aviso_rec_compl
    where ar_ped.cod_empresa = p_cod_empresa
      AND ar_ped.num_pedido  = p_item.numped
      AND ar_ped.cod_empresa = aviso_rec_compl.cod_empresa
      AND ar_ped.num_aviso_rec = aviso_rec_compl.num_aviso_rec
      AND aviso_rec_compl.ies_situacao <> "C"
      AND num_oc = p_item.oclog
      AND num_prog_entrega = p_item.splog
      AND qtd_recebida = 0
### ies_situacao <> C nao considera qtd proveniente de Danfes Canceladas ###

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') somando qtd reservada da tab ar_pend'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   if p_qtd_reservada is NULL then
      let p_qtd_reservada = 0
   end if

   let p_qtd_saldo = p_qtd_solic - p_qtd_recebida - p_qtd_reservada

   let p_qtd_recebida = p_item.qtde

   if p_qtd_saldo < p_qtd_recebida then
      LET p_msg = 'Qtde adquirida maior que saldo da programacao da OC '
      CALL pol1025_insere_erro()
      RETURN FALSE
   end if

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_ins_move_val()
#-----------------------------#

   INITIALIZE p_estoque_trans to null

   let p_cod_operacao = p_parametros_912.cod_oper_val
   let p_qtd_movto    = 0
   LET p_ies_situa    = 'I'

   IF NOT pol1025_ins_transacao() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1025_ins_transacao()
#-------------------------------#

    LET  p_estoque_trans.cod_empresa        = p_cod_empresa
    LET  p_estoque_trans.num_transac        = "0"
    LET  p_estoque_trans.dat_movto          = TODAY
    LET  p_estoque_trans.dat_proces         = TODAY
    LET  p_estoque_trans.hor_operac         = TIME
    LET  p_estoque_trans.dat_ref_moeda_fort = p_nf_sup.dat_emis_nf
    LET  p_estoque_trans.ies_tip_movto      = "N"
    LET  p_estoque_trans.cod_operacao       = p_cod_operacao
    LET  p_estoque_trans.cod_item           = p_aviso_rec.cod_item
    LET  p_estoque_trans.qtd_movto          = p_qtd_movto
    LET  p_estoque_trans.num_prog           = "POL1025"
    LET  p_estoque_trans.num_docum          = p_aviso_rec.num_aviso_rec
    LET  p_estoque_trans.num_seq            = p_aviso_rec.num_seq
    LET  p_estoque_trans.cus_unit_movto_p   =  0
    LET  p_estoque_trans.cus_tot_movto_p    =  0
    LET  p_estoque_trans.cus_unit_movto_f   =  0
    LET  p_estoque_trans.cus_tot_movto_f    =  0
    LET  p_estoque_trans.num_conta          =  p_num_conta
    LET  p_estoque_trans.ies_sit_est_orig   =  " "
    LET  p_estoque_trans.nom_usuario        =  p_user
    LET  p_estoque_trans.cod_local_est_dest = p_aviso_rec.cod_local_estoq
    LET  p_estoque_trans.ies_sit_est_dest   = p_ies_situa

    INSERT INTO estoque_trans VALUES (p_estoque_trans.*)

    IF sqlca.sqlcode <> 0 THEN
       LET p_msg = 'Erro(',STATUS,') inserindo movimento estoq na tab estoque_trans'
       CALL pol1025_insere_erro()
       RETURN FALSE
    END IF

     LET p_num_transac = SQLCA.SQLERRD[2]


     LET p_estoque_trans_end.cod_empresa      = p_cod_empresa
     LET p_estoque_trans_end.num_transac      = p_num_transac
     LET p_estoque_trans_end.endereco         = " "
     LET p_estoque_trans_end.num_volume       = 0
     LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
     LET p_estoque_trans_end.cod_grade_1      = " "
     LET p_estoque_trans_end.cod_grade_2      = " "
     LET p_estoque_trans_end.cod_grade_3      = " "
     LET p_estoque_trans_end.cod_grade_4      = " "
     LET p_estoque_trans_end.cod_grade_5      = " "
     LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.vlr_temperatura  = 0
     LET p_estoque_trans_end.endereco_origem  = " "
     LET p_estoque_trans_end.num_ped_ven      = 0
     LET p_estoque_trans_end.num_seq_ped_ven  = 0
     LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.num_peca         = " "
     LET p_estoque_trans_end.num_serie        = " "
     LET p_estoque_trans_end.comprimento      = 0
     LET p_estoque_trans_end.largura          = 0
     LET p_estoque_trans_end.altura           = 0
     LET p_estoque_trans_end.diametro         = 0
     LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
     LET p_estoque_trans_end.qtd_reserv_1     = 0
     LET p_estoque_trans_end.qtd_reserv_2     = 0
     LET p_estoque_trans_end.qtd_reserv_3     = 0
     LET p_estoque_trans_end.num_reserv_1     = 0
     LET p_estoque_trans_end.num_reserv_2     = 0
     LET p_estoque_trans_end.num_reserv_3     = 0
     LET p_estoque_trans_end.tex_reservado    = " "
     LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
     LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
     LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
     LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f
     LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
     LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
     LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
     LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
     LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog

     INSERT INTO estoque_trans_end
        VALUES (p_estoque_trans_end.*)

     IF SQLCA.SQLCODE <> 0 THEN
       LET p_msg = 'Erro(',STATUS,') inserindo movimento estoq na tab estoque_trans_end'
       CALL pol1025_insere_erro()
       RETURN FALSE
     END IF

     INSERT INTO est_trans_area_lin
        VALUES (p_cod_empresa, p_num_transac, p_aen.*)

     IF SQLCA.SQLCODE <> 0 THEN
       LET p_msg = 'Erro(',STATUS,') inserindo movimento estoq na tab est_trans_area_lin'
       CALL pol1025_insere_erro()
       RETURN FALSE
     END IF

    LET p_estoque_auditoria.cod_empresa    = p_cod_empresa
    LET p_estoque_auditoria.num_transac    = p_num_transac
    LET p_estoque_auditoria.nom_usuario    = p_user
    LET p_estoque_auditoria.dat_hor_proces = CURRENT
    LET p_estoque_auditoria.num_programa   = p_estoque_trans.num_prog

    INSERT INTO estoque_auditoria
       VALUES(p_estoque_auditoria.*)

     IF SQLCA.SQLCODE <> 0 THEN
       LET p_msg = 'Erro(',STATUS,') inserindo movimento estoq na tab estoque_auditoria'
       CALL pol1025_insere_erro()
       RETURN FALSE
     END IF

     RETURN TRUE

END FUNCTION

{
#----------------------------#
FUNCTION pol1025_move_estoq()
#----------------------------#

   INITIALIZE p_estoque_trans to null

   LET  p_estoque_trans.cod_local_est_dest =  p_aviso_rec.cod_local_estoq
   LET  p_estoque_trans.ies_sit_est_dest = "I"
   let  p_cod_operacao = p_aviso_rec.cod_operac_estoq

   IF p_ies_ctr_lote = 'S' THEN
      LET p_estoque_trans.num_lote_dest = p_aviso_rec.num_aviso_rec
   ELSE
      LET p_estoque_trans.num_lote_dest = NULL
   END IF

   let p_qtd_movto = p_aviso_rec.qtd_recebida

   IF NOT pol1025_ins_transacao() THEN
      RETURN FALSE
   END IF

   LET  p_estoque_trans.ies_sit_est_dest = "L"
   let  p_cod_operacao = p_cod_operac_estoq_l

   IF NOT pol1025_ins_transacao() THEN
      RETURN FALSE
   END IF

   IF NOT pol1025_ins_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1025_ins_estoque()
#-----------------------------#

   DEFINE p_qtd_liberada  LIKE estoque.qtd_liberada,
          p_qtd_impedida  LIKE estoque.qtd_impedida

   SELECT qtd_liberada,
          qtd_impedida
     INTO p_qtd_liberada,
          p_qtd_impedida
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_trans.cod_item

   IF STATUS = 100 THEN
      LET p_qtd_liberada = 0
      LET p_qtd_impedida  = 0
      INSERT INTO estoque
       VALUES(p_cod_empresa,p_estoque_trans.cod_item,0,0,0,0,0,0,' ',' ',' ')
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela estoque'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela estoque'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF
   END IF

   IF p_estoque_trans.ies_sit_est_dest = 'L' THEN
      LET p_qtd_liberada = p_qtd_liberada + p_estoque_trans.qtd_movto
   ELSE
      LET p_qtd_impedida = p_qtd_impedida + p_estoque_trans.qtd_movto
   END IF

   UPDATE estoque
      SET qtd_liberada    = p_qtd_liberada,
          qtd_impedida    = p_qtd_impedida,
          dat_ult_entrada = p_estoque_trans.dat_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_trans.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro:(',STATUS, ') autalizando estoque na tabela estoque'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   IF NOT pol1025_grava_est_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol1025_grava_est_lote_ender() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1025_grava_est_lote()
#--------------------------------#

   IF p_estoque_trans.num_lote_dest IS NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_trans.cod_item
         AND cod_local     = p_estoque_trans.cod_local_est_dest
         AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest
         AND num_lote IS NULL
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_trans.cod_item
         AND cod_local     = p_estoque_trans.cod_local_est_dest
         AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest
         AND num_lote      = p_estoque_trans.num_lote_dest
   END IF

   IF STATUS = 0 THEN
      IF NOT pol1025_atu_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol1025_ins_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_msg = 'Erro:(',STATUS, ') lendo dados da tabela estoque_lote'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1025_atu_lote()
#--------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro:(',STATUS, ') atualizando saldo da tabela estoque_lote'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1025_ins_lote()
#--------------------------#

   INSERT INTO estoque_lote(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          ies_situa_qtd,
          qtd_saldo,
          num_transac)
          VALUES(p_estoque_trans.cod_empresa,
                 p_estoque_trans.cod_item,
                 p_estoque_trans.cod_local_est_dest,
                 p_estoque_trans.num_lote_dest,
                 p_estoque_trans.ies_sit_est_dest,
                 p_estoque_trans.qtd_movto,
                 p_num_transac)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro:(',STATUS, ') inserindo saldadosdo na tabela estoque_lote'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1025_grava_est_lote_ender()
#-------------------------------------#

   IF p_estoque_trans.num_lote_dest IS NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_trans.cod_item
         AND cod_local     = p_estoque_trans.cod_local_est_dest
         AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest
         AND num_lote IS NULL
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_estoque_trans.cod_item
         AND cod_local     = p_estoque_trans.cod_local_est_dest
         AND ies_situa_qtd = p_estoque_trans.ies_sit_est_dest
         AND num_lote      = p_estoque_trans.num_lote_dest
   END IF

   IF STATUS = 0 THEN
      IF NOT pol1025_atu_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol1025_ins_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_msg = 'Erro:(',STATUS, ') lendo dados da tabela estoque_lote_ender'
         CALL pol1025_insere_erro()
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1025_atu_lote_ender()
#--------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_estoque_trans.qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro:(',STATUS, ') atualizando saldo da tabela estoque_lote_ender'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1025_ins_lote_ender()
#--------------------------------#

   LET p_estoque_lote.cod_empresa       = p_estoque_trans.cod_empresa
   LET p_estoque_lote.cod_item          = p_estoque_trans.cod_item
   LET p_estoque_lote.cod_local         = p_estoque_trans.cod_local_est_dest
   LET p_estoque_lote.num_lote          = p_estoque_trans.num_lote_dest
   LET p_estoque_lote.ies_situa_qtd     = p_estoque_trans.ies_sit_est_dest
   LET p_estoque_lote.qtd_saldo         = p_estoque_trans.qtd_movto
   LET p_estoque_lote_ender.largura     = p_estoque_trans_end.largura
   LET p_estoque_lote_ender.altura      = p_estoque_trans_end.altura
   LET p_estoque_lote_ender.num_serie   = p_estoque_trans_end.num_serie
   LET p_estoque_lote_ender.diametro    = p_estoque_trans_end.diametro
   LET p_estoque_lote_ender.comprimento = p_estoque_trans_end.comprimento
   LET p_estoque_lote_ender.dat_hor_producao   = p_estoque_trans_end.dat_hor_producao
   LET p_estoque_lote_ender.cod_item           = p_estoque_trans.cod_item
   LET p_estoque_lote_ender.cod_local          = p_estoque_trans.cod_local_est_dest
   LET p_estoque_lote_ender.num_lote           = p_estoque_trans.num_lote_dest
   LET p_estoque_lote_ender.endereco           = p_estoque_trans_end.endereco
   LET p_estoque_lote_ender.num_volume         = p_estoque_trans_end.num_volume
   LET p_estoque_lote_ender.cod_grade_1        = p_estoque_trans_end.cod_grade_1
   LET p_estoque_lote_ender.cod_grade_2        = p_estoque_trans_end.cod_grade_2
   LET p_estoque_lote_ender.cod_grade_3        = p_estoque_trans_end.cod_grade_3
   LET p_estoque_lote_ender.cod_grade_4        = p_estoque_trans_end.cod_grade_4
   LET p_estoque_lote_ender.cod_grade_5        = p_estoque_trans_end.cod_grade_5
   LET p_estoque_lote_ender.num_ped_ven        = p_estoque_trans_end.num_ped_ven
   LET p_estoque_lote_ender.num_seq_ped_ven    = p_estoque_trans_end.num_seq_ped_ven
   LET p_estoque_lote_ender.ies_situa_qtd      = p_estoque_trans.ies_sit_est_dest
   LET p_estoque_lote_ender.qtd_saldo          = p_estoque_trans.qtd_movto
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = p_estoque_trans_end.dat_hor_validade
   LET p_estoque_lote_ender.num_peca           = p_estoque_trans_end.num_peca
   LET p_estoque_lote_ender.dat_hor_reserv_1   = p_estoque_trans_end.dat_hor_reserv_1
   LET p_estoque_lote_ender.dat_hor_reserv_2   = p_estoque_trans_end.dat_hor_reserv_2
   LET p_estoque_lote_ender.dat_hor_reserv_3   = p_estoque_trans_end.dat_hor_reserv_3
   LET p_estoque_lote_ender.qtd_reserv_1       = p_estoque_trans_end.qtd_reserv_1
   LET p_estoque_lote_ender.qtd_reserv_2       = p_estoque_trans_end.qtd_reserv_2
   LET p_estoque_lote_ender.qtd_reserv_3       = p_estoque_trans_end.qtd_reserv_3
   LET p_estoque_lote_ender.num_reserv_1       = p_estoque_trans_end.num_reserv_1
   LET p_estoque_lote_ender.num_reserv_2       = p_estoque_trans_end.num_reserv_2
   LET p_estoque_lote_ender.num_reserv_3       = p_estoque_trans_end.num_reserv_3
   LET p_estoque_lote_ender.tex_reservado      = p_estoque_trans_end.tex_reservado

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          num_transac,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado)
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.num_transac,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro:(',STATUS, ') insereindo dados na tabela estoque_lote_ender'
      CALL pol1025_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------FIM DO PROGRAMA---------------#
