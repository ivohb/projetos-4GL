#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol1031                                                 #
# OBJETIVO: IMPORTAÇÃO DE TITULOS DO SITEMA EASY                    #
# CLIENTE.:                                                   	    #
# DATA....: 10/04/10                                                #
# POR.....: IVO H BARBOSA                                           #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa,
          p_cod_tip_d_adiant   LIKE ad_mestre.cod_tip_despesa,
          p_qtd_dias_sd        LIKE cond_pgto_item.qtd_dias_sd,
          p_cnd_pgto           LIKE cond_pgto_item.cod_cnd_pgto,
          p_val_gravado        LIKE aviso_rec.val_liquido_item,
          p_pct_valor_liquido  LIKE aviso_rec.val_liquido_item,
          p_num_conta_cred     LIKE grupo_despesa.num_conta_fornec,
          p_num_conta_deb      LIKE dest_aviso_rec.num_conta_deb_desp,
          p_cod_grp_despesa    LIKE grupo_despesa.cod_grp_despesa,
          p_cod_hist_deb_ap    LIKE tipo_despesa.cod_hist_deb_ap,
          p_num_pedido         LIKE aviso_rec.num_pedido,
          p_num_docum          LIKE ap.num_docum_pgto,
          p_sdo_adiant         like adiant.val_saldo_adiant,
          p_num_ap             LIKE ap.num_ap,
          p_oc_tip_desp        like ordem_sup.cod_tip_despesa,
          p_valor              like ap_valores.valor,
          p_val_orig           LIKE ad_mestre.val_tot_nf,
          p_val_novo           LIKE ad_mestre.val_tot_nf,
          p_cod_tip_val        like ap_valores.cod_tip_val,
          p_cod_agen_bco       like agencia_bco.cod_agen_bco,
          p_dat_pgto           like ap.dat_pgto

   DEFINE p_adiant             RECORD LIKE adiant.*,
          p_mov_adiant         RECORD LIKE mov_adiant.*,
          p_ad_mestre          RECORD LIKE ad_mestre.*,
          p_ap                 RECORD LIKE ap.*,
          p_lanc_cont_cap      RECORD LIKE lanc_cont_cap.*,
          p_ctb_lanc           RECORD LIKE ctb_lanc_ctbl_cap.*

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
          ser_nf_imp           CHAR(03),
          cod_tv_sdo_adiant    DECIMAL(3,0)
  END RECORD

  define  p_audit              record
          cod_empresa          char(2),
          ies_tabela           char(2),
          nom_usuario          char(8),
          num_ad_ap            decimal(6,0),
          ies_ad_ap            char(1),
          num_nf               char(7),
          ser_nf               char(3),
          ssr_nf               decimal(2,0),
          cod_fornecedor       char(15),
          ies_manut            char(1),
          num_seq              decimal(3,0),
          desc_manut           char(200),
          data_manut           date,
          hora_manut           char(8),
          num_lote_transf      decimal(3,0)
   end record



  DEFINE p_cod_fiscal         CHAR(05),
         p_cod_empresa        CHAR(02),
         p_user               CHAR(08),
         p_cod_emp_ad         CHAR(02),
         p_numero             DECIMAL(13,2),
         p_num_recno          INTEGER,
         p_dat_proces         DATE,
         p_criticou           SMALLINT,
         p_msg                CHAR(80),
         p_inconsiste         SMALLINT,
         p_num_seq            SMALLINT,
         p_index              SMALLINT,
         s_index              SMALLINT,
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
       	 p_ind                SMALLINT,
         p_nom_tela           CHAR(200),
         p_nom_help           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
       	 p_arquivo            CHAR(15),
         p_versao             CHAR(18),
         p_num_programa       CHAR(07),
         p_num_ad             INTEGER,
         p_dat_vencto         DATE,
         p_qtd_parcelas       INTEGER,
         p_val_ad             DECIMAL(15,2),
         p_num_parcela        SMALLINT,
         p_arelin             CHAR(04),
         p_val_parc           DECIMAL(15,2),
         p_tip_mat            DECIMAL(2,0),
         p_seq_lanc           INTEGER,
         p_hora               DATETIME HOUR TO SECOND,
         p_dat_atu            DATE,
         p_vlcmps             DECIMAL(15,2),
         p_val_ap_compl       DECIMAL(15,2),
         p_valdif             DECIMAL(15,2),
         p_num_lote           DECIMAL(5,0),
         p_val_comp           DECIMAL(15,2),
         p_tot_comp           DECIMAL(15,2),
         p_baixa_titulo       SMALLINT,
         p_num_versao         integer,
         p_versao_ant         integer,
         p_ies_docum_pgto     char(01),
         p_ies_processo       char(01),
         p_ies_ad_ap          char(01),
         p_num_ad_log         INTEGER,
         p_cod_lin_pord       char(2),
         p_cod_lin_recei      char(2)




   DEFINE pr_erro              ARRAY[10000] OF RECORD
          cod_empresa          CHAR(02),
          num_registro         INTEGER,
          den_erro             CHAR(80),
          keyeas               CHAR(100)
   END RECORD

   DEFINE p_titulo             RECORD
          tpintg               CHAR(001),
          cdempr               CHAR(002),
          cdfili               CHAR(002),
          codemp               CHAR(002),
          cdfase               CHAR(003),
          tplanc               CHAR(002),
          nrhawb               CHAR(017),
          cdpodi               CHAR(001),
          invoic               CHAR(015),
          numped               CHAR(015),
          profor               CHAR(015),
          linha                CHAR(004),
          dtemis               CHAR(008),
          cdforn               CHAR(006),
          forlog               CHAR(015),
          ljforn               CHAR(002),
          moeda                CHAR(003),
          keyerp               CHAR(100),
          keyeas               CHAR(100),
          parccb               CHAR(002),
          vldoct               CHAR(015),
          adtdsp               CHAR(001),
          debcon               CHAR(001),
          dtvcto               CHAR(008),
          tptitu               CHAR(001),
          titerp               CHAR(020),
          titvin               CHAR(020),
          vlcmps               DECIMAL(15,2),
          vrcamb               DECIMAL(15,2),
          cdeven               CHAR(003),
          cdbanc               CHAR(003),
          cdagen               CHAR(006),
          cdcont               CHAR(010),
          nravis               CHAR(010),
          dtavis               CHAR(008),
          nrlc                 CHAR(010),
          nrctcb               CHAR(015),
          dtctcb               CHAR(008),
          dtdsmb               CHAR(008),
          dtliqu               CHAR(008),
          txliqu               CHAR(015),
          vcoage               CHAR(015),
          vretid               CHAR(015),
          cdcorr               CHAR(006),
          vcorre               CHAR(015),
          vdspbc               CHAR(015),
          cdbarc               CHAR(003),
          cdagrc               CHAR(005),
          cdccrc               CHAR(010),
          nmbcrc               CHAR(020),
          cswift               CHAR(030),
          alias                CHAR(003),
          campo                CHAR(010),
          recno                INTEGER,
          flag                 CHAR(001),
          flgeas               CHAR(001),
          msgrej               CHAR(200),
          msgre2               CHAR(200),
          msgre3               CHAR(200),
          msgre4               CHAR(200),
          dtexpo               CHAR(008),
          dtexp2               CHAR(008),
          dtexp3               CHAR(008),
          dtexp4               CHAR(008),
          hrexpo               CHAR(006),
          hrexp2               CHAR(006),
          hrexp3               CHAR(006),
          hrexp4               CHAR(006),
          usexpo               CHAR(025),
          usexp2               CHAR(025),
          usexp3               CHAR(025),
          usexp4               CHAR(025),
          dtimpo               CHAR(008),
          dtimp2               CHAR(008),
          dtimp3               CHAR(008),
          dtimp4               CHAR(008),
          hrimpo               CHAR(006),
          hrimp2               CHAR(006),
          hrimp3               CHAR(006),
          hrimp4               CHAR(006),
          usimpo               CHAR(025),
          usimp2               CHAR(025),
          usimp3               CHAR(025),
          usimp4               CHAR(025),
          tdlog                CHAR(004),
          titger               CHAR(020),
          txthis               CHAR(050),
          valpis               DECIMAL(15,2),
          valir                DECIMAL(15,2),
          valdif               DECIMAL(15,2),
          docdes               char(09),
          agelog               char(6),
          conlog               char(15),
          agrlog               char(6),
          ccrlog               char(15)
   END RECORD

END GLOBALS

   DEFINE m_seql_lanc_cap      INTEGER


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1031-05.10.08"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   {CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user}

    LET p_status      = 0
    LET p_cod_empresa = '10'
    LET p_user 	      = 'easy'

    CALL pol1031_controle()

END MAIN

#---------------------------#
 FUNCTION pol1031_controle()
#---------------------------#

   define p_proces char(01)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1031") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1031 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   select proces_titulo
     into p_proces
     from proces_integra_912

   if p_proces = 'S' then
      ERROR 'Há um processamento em execução! Tente mais tarde.'
      sleep 7
      return
   end if

   update proces_integra_912
      set proces_titulo = 'S'

   CALL pol1031_processar() RETURNING p_status

   call pol1031_exporta_exclusao() RETURNING p_status

   call pol1031_exporta_estorno_pgto() RETURNING p_status

   CALL pol1031_grava_erro()

   update proces_integra_912
      set proces_titulo = 'N'

   CLOSE WINDOW w_pol1031

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

#----------------------------#
FUNCTION pol1031_insere_erro()
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
   LET pr_erro[p_num_seq].num_registro = p_titulo.recno
   LET pr_erro[p_num_seq].den_erro     = p_msg
   let pr_erro[p_num_seq].keyeas       = p_titulo.keyeas

   LET p_criticou = TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1031_grava_erro()
#----------------------------#

   FOR p_index = 1 TO p_num_seq

       IF pr_erro[p_index].den_erro IS NOT NULL THEN

          INSERT INTO erro_imp_tit_912(
             cod_empresa,
             num_registro,
             den_erro,
             keyeas)
          VALUES(pr_erro[p_index].cod_empresa,
                 pr_erro[p_index].num_registro,
                 pr_erro[p_index].den_erro,
                 pr_erro[p_index].keyeas)

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','erro_imp_tit_912')
             EXIT FOR
          END IF
       END IF
   END FOR

END FUNCTION

#-------------------------#
FUNCTION pol1031_atu_ei17()
#-------------------------#

   DEFINE p_flag char(01)

   LET p_titulo.flgeas = 'N'

   if p_titulo.flag = 'R' then
      if p_titulo.cdfase = 'CBO' then
         if p_titulo.tplanc = 'LQ'  then
            if p_titulo.titerp is null or p_titulo.titerp = ' ' then
            else
               LET p_titulo.flgeas = 'B'
            end if
         end if
      end if
   end if

   LET p_titulo.msgrej = p_msg
   LET p_titulo.dtimpo = data_ansi()
   LET p_titulo.hrimpo = hora_atual()
   LET p_titulo.usimpo = p_user

   UPDATE easy:ei17
      SET flag   = p_titulo.flag,
          flgeas = p_titulo.flgeas,
          msgrej = p_titulo.msgrej,
          dtimpo = p_titulo.dtimpo,
          hrimpo = p_titulo.hrimpo,
          usimpo = p_titulo.usimpo,
          titger = p_titulo.titger
    WHERE codemp = p_titulo.codemp
      AND recno  = p_titulo.recno

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Atualizando dados na tabela ei17'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   #--- confirmação de atualização de flags, para evitar a replicação de titulos---#

   select flag
     into p_flag
     from easy:ei17
    WHERE codemp = p_titulo.codemp
      AND recno  = p_titulo.recno

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,')checando atualização de flags da tabela ei17'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_flag MATCHES '[SR]' THEN
   ELSE
      LET p_msg = 'Nao foi possivel atualizar flags da tabela ei17'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   #----------------------------------------------------------------------------#

   update easy:eiz2
      SET flag   = p_titulo.flag,
          msgrej = p_titulo.msgrej,
          dtimpo = p_titulo.dtimpo,
          hrimpo = p_titulo.hrimpo,
          usimpo = p_titulo.usimpo,
          ei17rc = p_titulo.recno
    WHERE codemp = p_titulo.codemp
      AND keyeas = p_titulo.keyeas
      AND flag   = "N"

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Atualizando dados na tabela eiz2'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   #--- confirmação de atualização de flags, para evitar a replicação de titulos - Ivo - 30/12/2011---#

   select count(flag)
     into p_count
     from easy:eiz2
    WHERE codemp = p_titulo.codemp
      AND keyeas = p_titulo.keyeas
      AND flag   = "N"

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,')checando atualização de flags da tabela eiz2'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_count > 0 THEN
      LET p_msg = 'Nao foi possivel atualizar flags da tabela eiz2'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   #----------------------------------------------------------------------------#

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1031_le_param()
#--------------------------#

   IF NOT pol1031_le_emp_orig_dest() THEN
      RETURN FALSE
   END IF

   select *
     into p_parametros_912.*
     from parametros_912
    where cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo parametros da tab parametros_912'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#---------------------------#
FUNCTION pol1031_processar()
#---------------------------#

   LET p_cod_empresa = '00'
   LET p_dat_proces = TODAY

   CREATE TEMP TABLE ad_aen_tmp (
     cod_area_negocio DECIMAL(2,0),
     val_item         DECIMAL(15,2)
    );

    IF STATUS <>  0 THEN
       LET p_msg = 'Erro(',STATUS,') criando tabela ad_aen_tmp)'
       CALL pol1031_insere_erro()
       RETURN FALSE
    END IF

   DECLARE cq_titulo CURSOR WITH HOLD FOR
    SELECT *
      FROM easy:ei17
     WHERE flag = 'N'
     ORDER BY codemp, recno

   FOREACH cq_titulo INTO p_titulo.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela de notas ei17)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF p_titulo.codemp <> p_cod_empresa THEN
         LET p_cod_empresa = p_titulo.codemp
         DISPLAY p_cod_empresa TO cod_empresa
         if not pol1031_le_param() then
            RETURN false
         end if
      END IF

      INITIALIZE p_msg TO NULL

      LET p_titulo.flag = 'R'
      LET p_msg = NULL

      CALL pol1031_consiste_titulo() RETURNING p_status

      IF p_msg IS NOT NULL THEN

         IF p_num_ad_log IS NOT NULL THEN
            LET p_titulo.titger = p_num_ad_log
            LET p_titulo.flag   = 'S'
         END IF

         CALL log085_transacao("BEGIN")

         IF NOT pol1031_atu_ei17() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF

         CALL log085_transacao("COMMIT")
         CONTINUE FOREACH
      END IF

      CALL log085_transacao("BEGIN")

      IF NOT pol1031_insere_titulo() THEN
         CALL log085_transacao("ROLLBACK")
         CALL log085_transacao("BEGIN")
         IF NOT pol1031_atu_ei17() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      ELSE
         LET p_msg =  NULL
         IF p_titulo.tplanc = 'CP' AND p_titulo.cdfase = 'DRL' THEN
            LET p_titulo.titger = ""
         else
            LET p_titulo.titger = p_num_ad
         end if
         LET p_titulo.flag   = 'S'

         IF NOT pol1031_atu_ei17() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
         CALL log085_transacao("COMMIT")
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_checa_titulo()
#------------------------------#

   select num_ad
     from ad_mestre
    where cod_empresa = p_cod_emp_ad
      and num_ad      = p_titulo.titerp

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo titulo p/ baixar na tab ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#-------------------------------#
FUNCTION pol1031_checa_banco()
#------------------------------#

   let p_titulo.agelog = p_titulo.agelog CLIPPED
   let p_titulo.cdbanc = p_titulo.cdbanc CLIPPED

   SELECT cod_agen_bco
     into p_cod_agen_bco
     FROM agencia_bco
    WHERE num_agencia = p_titulo.agelog
      AND cod_banco   = p_titulo.cdbanc

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'O banco/agencia enviado nao existe no Logix'
         CALL pol1031_insere_erro()
      ELSE
         LET p_msg = 'Erro(',STATUS,') lendo banco/agencia na tab agencia_bco)'
         CALL pol1031_insere_erro()
      END IF
      RETURN FALSE
   END IF

   SELECT num_conta_banc
     FROM agencia_bc_item
    WHERE cod_agen_bco   = p_cod_agen_bco
      AND num_conta_banc = p_titulo.conlog
      and cod_empresa    = p_cod_emp_ad

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'O numero da conta enviada nao existe no Logix'
         CALL pol1031_insere_erro()
      ELSE
         LET p_msg = 'Erro(',STATUS,') lendo num conta na tab agencia_bc_item)'
         CALL pol1031_insere_erro()
      END IF
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#---------------------------------#
FUNCTION pol1031_consiste_titulo()
#---------------------------------#

   DEFINE p_cod_tp_d_adiant like tipo_despesa.cod_tip_despesa,
          p_cod_tp_despesa  like tipo_despesa.cod_tip_despesa

   DELETE FROM erro_imp_tit_912
    where cod_empresa = p_cod_empresa
      and keyeas      = p_titulo.keyeas

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') deletando erro da tabela erro_imp_tit_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF pol1031_tit_ja_integrado() THEN
      RETURN FALSE
   END IF

   if LENGTH(p_titulo.cdpodi) = 0 then
      let p_titulo.cdpodi = 'D'
   end if

   if p_titulo.cdpodi MATCHES '[DA]' then
   else
      LET p_msg = 'Identificador de processo ou pedido invalido'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF LENGTH(p_titulo.codemp) = 0 THEN
      LET p_msg = 'O codigo da empresa do Logix nao foi enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF LENGTH(p_titulo.cdfase) = 0 THEN
      LET p_msg = 'A do processo nao foi enviada'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF LENGTH(p_titulo.tplanc) = 0 THEN
      LET p_msg = 'O tipo de lancamento nao foi enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_titulo.tplanc = 'CP' AND p_titulo.cdfase = 'DRL' THEN
      if not pol1032_vinculos_ok() then
         RETURN false
      end if
      RETURN true
   end if

   IF p_titulo.debcon = 'S'  or p_titulo.tplanc = 'LQ' THEN
      IF LENGTH(p_titulo.cdbanc) = 0 THEN
         LET p_msg = 'Debito em conta sem o codigo do banco'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF LENGTH(p_titulo.conlog) = 0 THEN
         LET p_msg = 'Debito em conta sem o numero da conta'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF LENGTH(p_titulo.dtliqu) = 0 THEN
         LET p_msg = 'Titulo sem a data de liquidacao'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      if not pol1031_checa_banco() then
         RETURN false
      end if

   end if

   IF p_titulo.tplanc = 'LQ' and  LENGTH(p_titulo.titerp) > 0 THEN
      IF NOT pol1031_checa_titulo() THEN
         RETURN FALSE
      END IF
      RETURN true
   END IF

   IF LENGTH(p_titulo.nrhawb) = 0 THEN
      LET p_msg = 'O numero do processo/pedido nao foi enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   INITIALIZE p_cod_tip_despesa, p_cod_tip_d_adiant to  null

   DECLARE cq_desp CURSOR FOR
    SELECT tipmat
      FROM easy:eiz2
     WHERE codemp = p_cod_empresa
       AND keyeas = p_titulo.keyeas
       AND flag   = "N"
     ORDER BY arelin, tipmat

   FOREACH cq_desp INTO p_tip_mat

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo tipo de material da tab eiz2)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF p_tip_mat is null or  p_tip_mat = ' ' then
         LET p_msg = 'O tipo de material nao foi enviado na tabela eiz2)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      SELECT cod_tip_despesa,
             cod_tip_d_adiant
        INTO p_cod_tp_despesa,
             p_cod_tp_d_adiant
        FROM tipo_item_912
       WHERE cod_empresa  = p_cod_empresa
         AND cod_tip_item = p_tip_mat

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo tipo de despesa da tabela tipo_item_912)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      if p_cod_tip_despesa is null then
         let p_cod_tip_despesa = p_cod_tp_despesa
         let p_cod_tip_d_adiant  = p_cod_tp_d_adiant
      end if

   end FOREACH

   if p_cod_tip_despesa is null then
      IF p_titulo.tplanc = 'CP' THEN
      else
         LET p_msg = 'O rateio por tipo de material nao foi enviado'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   end if

   IF LENGTH(p_titulo.forlog) = 0 THEN
      LET p_msg = 'O fornecedor Logix nao foi enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   SELECT cod_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_titulo.forlog

   IF STATUS = 100 THEN
      LET p_msg = 'O fornecedor enviado nao existe no Logix'
      CALL pol1031_insere_erro()
      RETURN FALSE
   else
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') consistindo ',
                     'o fornecedor enviado na tabela fornecedor'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   END IF

   IF LENGTH(p_titulo.dtvcto) = 0 THEN
      LET p_msg = 'A data de vencimento nao foi enviada'
      CALL pol1031_insere_erro()
      RETURN FALSE
   else
      LET p_dat_vencto = pol1031_dat_normal(p_titulo.dtvcto)
      IF p_titulo.debcon = 'S' THEN
      ELSE
         if p_dat_vencto < today then
            LET p_msg = 'Data de vencimento enviada menor que data atual'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF
      END IF
   END IF

   IF LENGTH(p_titulo.vldoct) = 0 THEN
      LET p_msg = 'O valor do documento nao foi enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_titulo.debcon matches '[SN]' THEN
   else
      LET p_msg = 'O valor do indicador de debito em conta esta invalido'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1031_tit_ja_integrado()
#----------------------------------#

   SELECT num_ad_logix
     INTO p_num_ad_log
     FROM ad_muro_912
    WHERE cod_emp_muro = p_titulo.codemp
      AND num_rec_muro = p_titulo.recno

   IF STATUS = 0 THEN
      LET p_msg = 'Titulo ja integrado com Logix - AD:', p_num_ad_log
      CALL pol1031_insere_erro()
      RETURN TRUE
   ELSE
      INITIALIZE p_num_ad_log TO NULL
      IF STATUS <> 100 THEN
         LET p_msg = 'Erro(',STATUS,') consistindo titulo gerado na tabela ad_muro_912'
         CALL pol1031_insere_erro()
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-----------------------------#
FUNCTION pol1032_vinculos_ok()
#-----------------------------#

   IF LENGTH(p_titulo.titvin) = 0 THEN
      LET p_msg = 'Titulo de vinculo com adiantamento nao enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_num_ad = p_titulo.titvin

   IF NOT pol1031_le_num_ap() THEN
      RETURN FALSE
   END IF

   select dat_pgto
     into p_dat_pgto
     from ap
    WHERE cod_empresa      = p_cod_emp_ad
      AND num_ap           = p_num_ap
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') consistindo pagamento do adiantamento tab AP'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   if p_dat_pgto is null then
      LET p_msg = 'Titulo de compensacao p/ adiantamento nao pago'
      CALL pol1031_insere_erro()
      RETURN FALSE
   end if

   select val_saldo_adiant
     INTO p_sdo_adiant
     from adiant
    where cod_empresa    = p_cod_emp_ad
      and num_ad_nf_orig = p_titulo.titvin

   IF STATUS = 100 THEN
      LET p_msg = 'Titulo de vinculo com adiantamento enviado nao existe no Logix'
      CALL pol1031_insere_erro()
      RETURN FALSE
   else
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') consistindo ',
                     'o titulo ERP enviado na tabela adiant'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   END IF

   IF p_sdo_adiant <= 0 THEN
      LET p_msg = 'Não há mais saldo no adiantamento para baixar'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_valdif = p_titulo.valdif
   LET p_vlcmps = p_titulo.vlcmps

   IF p_vlcmps > p_sdo_adiant THEN
      LET p_msg = 'Valor da compensacao maior que o saldo do adiantamento'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF LENGTH(p_titulo.titerp) = 0 THEN
      LET p_msg = 'Titulo de vinculo com titulo de despesas nao enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   SELECT val_tot_nf,
          cod_tip_despesa
     INTO p_val_ad,
          p_cod_tip_despesa
     FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_ad
      and num_ad      = p_titulo.titerp

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') consistindo titulo de vinculo na tabela ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_valdif IS NULL THEN
      LET p_valdif = 0
   ELSE
      IF p_valdif < 0 THEN
         LET p_valdif = p_valdif * -1
      ELSE
        LET p_valdif = 0
      END IF
   END IF

   IF p_vlcmps IS NULL THEN
      LET p_msg = 'Valor da compensacao de adiantamento nao enviado'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_num_ad = p_titulo.titerp

   IF NOT pol1031_le_num_ap() THEN
      RETURN FALSE
   END IF

   select sum(val_comp)
     into p_val_comp
     from comp_adiant_912
    where cod_empresa = p_cod_emp_ad
      and num_ad      = p_titulo.titerp

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') somando parcelas de compensacao da tabela comp_adiant_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   if p_val_comp is null then
      let p_val_comp = 0
   end if

   LET p_tot_comp = p_vlcmps + p_val_comp + p_valdif
   let p_val_ap_compl = p_vlcmps + p_val_comp

   IF p_tot_comp < p_val_ad THEN
      if not pol1031_ins_comp(p_titulo.titerp, p_vlcmps) then
         RETURN false
      end if
   end if

   IF p_vlcmps > p_val_ad THEN
      LET p_msg = 'Somatoria das compensacoes excede o valor do titulo de despesa'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_tot_comp = p_val_ad or p_vlcmps = p_val_ad THEN
      let p_baixa_titulo = true
      if not pol1031_del_comp() then
         RETURN false
      end if
   else
      let p_baixa_titulo = false
   end if

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1031_ins_comp(p_ad, p_val)
#------------------------------------#

   define p_ad  like ap_valores.num_ap,
          p_val like ap_valores.valor

   insert into comp_adiant_912
    values(p_cod_emp_ad,
           p_ad,
           p_val)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo parcelas de compesacao na tabela comp_adiant_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#--------------------------#
FUNCTION pol1031_del_comp()
#--------------------------#

   delete from comp_adiant_912
    where cod_empresa = p_cod_emp_ad
      and num_ad      = p_titulo.titerp

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') deletando parcelas de compesacao na tabela comp_adiant_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION


#---------------------------#
FUNCTION pol1031_le_par_ad()
#---------------------------#

   SELECT ult_num_ad
     INTO p_num_ad
     FROM par_ad
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ad = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo número da última AD da tab par_ad)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   END IF

   LET p_num_ad = p_num_ad + 1

   UPDATE par_ad SET ult_num_ad = p_num_ad
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando número da AD na tab par_ad)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1031_le_par_ap()
#---------------------------#

   SELECT ult_num_ap
     INTO p_num_ap
     FROM par_ap
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ap = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo número da última AP da tab par_ap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   END IF

   LET p_num_ap = p_num_ap + 1

   UPDATE par_ap SET ult_num_ap = p_num_ap
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando número da AP na tab par_ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1031_le_emp_orig_dest()
#---------------------------------#

   SELECT cod_empresa_destin
     INTO p_cod_emp_ad
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_empresa

   IF STATUS = 100 THEN
      LET p_cod_emp_ad = p_cod_empresa
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo empresa da tabela emp_orig_destino)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1031_le_num_ap()
#---------------------------#

   select num_ap
     into p_num_ap
     from ad_ap
    where cod_empresa = p_cod_emp_ad
      and num_ad      = p_num_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo numero da AP a tabela AD_AP)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#-------------------------------#
FUNCTION pol1031_insere_titulo()
#-------------------------------#

   IF p_titulo.tplanc = 'CP' AND p_titulo.cdfase = 'DRL' THEN

      if not pol1031_baixa_adiant() then
         RETURN false
      end if

      RETURN true

   end if

   LET p_dat_proces = TODAY
   LET p_dat_vencto = pol1031_dat_normal(p_titulo.dtvcto)

   IF p_titulo.tplanc = 'LQ' and  LENGTH(p_titulo.titerp) > 0 THEN
      let p_num_ad = p_titulo.titerp
      IF NOT pol1031_le_num_ap() THEN
         RETURN FALSE
      END IF

      SELECT *
        INTO p_ap.*
        FROM ap
       WHERE cod_empresa = p_cod_emp_ad
         AND num_ap      = p_num_ap
         AND ies_versao_atual = 'S'

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') titulo de despesa na tabela ap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      if not pol1031_nova_versao() then
         RETURN false
      end if

      LET p_num_lote = p_parametros_912.num_lote_diversos
      IF NOT pol1031_baixa_titulo() THEN
         RETURN FALSE
      END IF

      RETURN true

   END IF

   IF NOT pol1031_le_par_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol1031_insere_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol1031_grava_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT pol1031_insere_ap() THEN
      RETURN FALSE
   END IF

   IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN
      IF NOT pol0665_ins_adiantamento() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_titulo.debcon = 'S' THEN
      IF NOT pol1031_le_lote() THEN
         RETURN FALSE
      END IF
      IF NOT pol1031_baixa_titulo() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1031_le_lote()
#------------------------#

   SELECT lote_pgto
     INTO p_num_lote
     FROM lote_pgto_912
    WHERE cod_banc = p_titulo.cdbanc

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo lote pgto da tab lote_pgto_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1031_dat_normal(p_dat_txt)
#------------------------------------#

   DEFINE p_dat_txt CHAR(08),
          p_dat_nor CHAR(10)

   LET p_dat_nor = p_dat_txt[7,8],'/',p_dat_txt[5,6],'/',p_dat_txt[1,4]

   RETURN(p_dat_nor)

END FUNCTION

#---------------------------#
FUNCTION pol1031_insere_ad()
#---------------------------#

   DEFINE p_num_nf       LIKE ad_mestre.num_nf,
          p_ssr_nf       LIKE ad_mestre.ssr_nf

   LET p_num_nf = p_titulo.nrhawb

   IF p_titulo.cdfase = 'DRL' AND p_titulo.tplanc = 'AB' then
      if LENGTH(p_titulo.docdes) > 0 then
         LET p_num_nf = p_titulo.docdes
      end if
      LET p_ad_mestre.cod_tip_ad = 5
   ELSE
      LET p_ad_mestre.cod_tip_ad = 1
   END IF

   SELECT MAX(ssr_nf)
     INTO p_ssr_nf
     FROM ad_mestre
    WHERE cod_empresa    = p_cod_emp_ad
      AND num_nf         = p_num_nf
      AND cod_fornecedor = p_titulo.forlog

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados na tab ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF p_ssr_nf IS NULL THEN
      LET p_ssr_nf = 1
   ELSE
      LET p_ssr_nf = p_ssr_nf + 1
   END IF


   IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN
      let p_cod_tip_despesa = p_cod_tip_d_adiant
   end if

   LET p_ad_mestre.cod_empresa       = p_cod_emp_ad
   LET p_ad_mestre.num_ad            = p_num_ad
   LET p_ad_mestre.cod_tip_despesa   = p_cod_tip_despesa
   LET p_ad_mestre.ser_nf            = 'X'
   LET p_ad_mestre.ssr_nf            = p_ssr_nf
   LET p_ad_mestre.num_nf            = p_num_nf
   LET p_ad_mestre.dat_emis_nf       = p_dat_proces
   LET p_ad_mestre.dat_rec_nf        = p_dat_proces
   LET p_ad_mestre.cod_empresa_estab = ' '
   LET p_ad_mestre.mes_ano_compet    = NULL
   LET p_ad_mestre.num_ord_forn      = NULL
   LET p_ad_mestre.cnd_pgto          = NULL
   LET p_ad_mestre.dat_venc          = p_dat_vencto
   LET p_ad_mestre.cod_fornecedor    = p_titulo.forlog
   LET p_ad_mestre.cod_portador      = p_titulo.cdbanc
   LET p_ad_mestre.val_tot_nf        = p_titulo.vldoct
   LET p_ad_mestre.val_saldo_ad      = 0
   LET p_ad_mestre.cod_moeda         = 1
   LET p_ad_mestre.set_aplicacao     = NULL

   LET p_ad_mestre.cod_lote_pgto     = p_parametros_912.num_lote_diversos

   IF p_titulo.debcon = 'S' THEN
      LET p_ad_mestre.cod_lote_pgto  = p_parametros_912.num_lote_deb_con
   END IF

   LET p_ad_mestre.observ            = NULL
   LET p_ad_mestre.ies_ap_autom      = 'S'
   LET p_ad_mestre.ies_sup_cap       = 'C'
   LET p_ad_mestre.ies_fatura        = 'N'

   IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN #duvida - e despesa/compen ?
      LET p_ad_mestre.ies_ad_cont       = 'S'
   ELSE
      LET p_ad_mestre.ies_ad_cont       = 'N'
   END IF

   LET p_ad_mestre.num_lote_transf   = 0
   LET p_ad_mestre.ies_dep_cred      = 'N'
   LET p_ad_mestre.num_lote_pat      = 0
   LET p_ad_mestre.cod_empresa_orig  = p_cod_empresa

   IF NOT pol1031_ins_ad() THEN
      RETURN FALSE
   END IF

   INSERT INTO ad_muro_912
    VALUES(p_titulo.codemp, p_titulo.recno, p_num_ad)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo AD na tab ad_muro_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1031_ins_ad()
#------------------------#

   INSERT INTO ad_mestre
      VALUES(p_ad_mestre.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo titulo na tab ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_msg     = p_ad_mestre.num_ad
   LET p_msg     = 'pol1031 - INCLUSAO DA AD No. ', p_msg CLIPPED
   LET p_hora    = CURRENT HOUR TO SECOND

   let p_audit.cod_empresa     = p_ad_mestre.cod_empresa
   let p_audit.ies_tabela      = '1'
   let p_audit.nom_usuario     = p_user
   let p_audit.num_ad_ap       = p_ad_mestre.num_ad
   let p_audit.ies_ad_ap       = '1'
   let p_audit.num_nf          = p_ad_mestre.num_nf
   let p_audit.ser_nf          = p_ad_mestre.ser_nf
   let p_audit.ssr_nf          = p_ad_mestre.ssr_nf
   let p_audit.cod_fornecedor  = p_ad_mestre.cod_fornecedor
   let p_audit.ies_manut       = 'I'
   let p_audit.num_seq         = '1'
   let p_audit.desc_manut      = p_msg
   let p_audit.data_manut      = p_ad_mestre.dat_emis_nf
   let p_audit.hora_manut      = p_hora
   let p_audit.num_lote_transf = p_ad_mestre.num_lote_transf

   INSERT INTO audit_cap
      VALUES(p_audit.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela audit_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   if p_titulo.cdpodi = 'D' then
      let p_ies_processo = 'S'
   else
      let p_ies_processo = 'N'
   end if

   IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN
   else
      insert into processo_cap
       values(p_ad_mestre.cod_empresa,
              p_titulo.nrhawb,
              p_ies_processo,
              p_ad_mestre.num_ad)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela processo_cap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      end if
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_ins_ap_valor()
#------------------------------#

   define p_num_seq SMALLINT

   select max(num_seq)
     into p_num_seq
     from ap_valores
    where cod_empresa = p_cod_emp_ad
      and num_ap      = p_num_ap
      and num_versao  = p_ap.num_versao

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo sequencia da tabela ap_valores)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   if p_num_seq is null then
      let p_num_seq = 1
   else
      let p_num_seq = p_num_seq + 1
   end if

   INSERT INTO ap_valores
      VALUES(p_cod_emp_ad,
             p_num_ap,
             p_ap.num_versao,
             'S',
             p_num_seq,
             p_cod_tip_val,
             p_valor)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ap_valores)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

END FUNCTION

#-----------------------------#
FUNCTION pol1031_grava_lanc()
#-----------------------------#

   {IF p_titulo.debcon = 'N' THEN
      IF NOT pol1031_lanc_por_aen() THEN
         RETURN FALSE
      END IF
   ELSE}

      IF NOT pol1031_lanc_por_tipo() THEN
         RETURN FALSE
      END IF

      IF NOT pol1031_grava_aen() THEN
         RETURN FALSE
      END IF

   #END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1031_grava_aen()
#---------------------------#

   DELETE FROM ad_aen_tmp

   DECLARE cq_aen CURSOR FOR
    SELECT arelin,
           SUM(vlparc)
      FROM easy:eiz2
     WHERE codemp = p_cod_empresa
       AND keyeas = p_titulo.keyeas
       AND flag   = "N"
  GROUP BY arelin

   FOREACH cq_aen INTO p_arelin, p_val_parc

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados na tabela eiz2 por area e linha)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF p_val_parc > 0 THEN # Ismael
         let p_cod_lin_pord  = p_arelin[1,2]  #cod_area_negocio
         let p_cod_lin_recei = p_arelin[3,4]  #cod_lin_negocio

         INSERT INTO ad_aen_tmp
          VALUES(p_cod_lin_pord, p_val_parc)

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ad_aen)'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF
      END IF
   END FOREACH

   DECLARE cq_aen_tmp CURSOR FOR
    SELECT cod_area_negocio,
           SUM(val_item)
      FROM ad_aen_tmp
  GROUP BY cod_area_negocio

   FOREACH cq_aen_tmp INTO p_cod_lin_pord, p_val_parc

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados na tabela temporaria ad_aen_tmp)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      insert into ad_aen
       values(p_ad_mestre.cod_empresa,
              p_ad_mestre.num_ad,
              p_val_parc,
              p_cod_lin_pord,
              '0')             #duvida - 0 ou 0000

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ad_aen)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1031_lanc_por_tipo()
#-------------------------------#

   LET p_seq_lanc      = 0
   LET m_seql_lanc_cap = 0

   DECLARE cq_tip CURSOR FOR
    SELECT tipmat,
           SUM(vlparc)
      FROM easy:eiz2
     WHERE codemp = p_cod_empresa
       AND keyeas = p_titulo.keyeas
       AND flag   = "N"
     GROUP BY tipmat
     ORDER BY tipmat

   FOREACH cq_tip INTO p_tip_mat, p_val_parc

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados na tabela eiz2 por tip item)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      SELECT cod_tip_despesa,
             cod_tip_d_adiant
        INTO p_cod_tip_despesa,
             p_cod_tip_d_adiant
        FROM tipo_item_912
       WHERE cod_empresa  = p_cod_empresa
         AND cod_tip_item = p_tip_mat

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo tip despesa da tabela tipo_item_912)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN
         let p_cod_tip_despesa = p_cod_tip_d_adiant
      end if

      IF NOT pol1031_le_conta() THEN
         RETURN FALSE
      END IF

      IF NOT pol1031_ins_lan_cont() THEN
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1031_ins_lan_cont()
#-----------------------------#

   LET p_seq_lanc = p_seq_lanc + 1

   LET p_lanc_cont_cap.cod_empresa        = p_ad_mestre.cod_empresa
   LET p_lanc_cont_cap.num_ad_ap          = p_ad_mestre.num_ad
   LET p_lanc_cont_cap.ies_ad_ap          = 1
   LET p_lanc_cont_cap.num_seq            = p_seq_lanc
   LET p_lanc_cont_cap.cod_tip_desp_val   = p_cod_tip_despesa
   LET p_lanc_cont_cap.ies_desp_val       = 'D'
   LET p_lanc_cont_cap.ies_man_aut        = 'A'
   LET p_lanc_cont_cap.ies_tipo_lanc      = 'D'
   LET p_lanc_cont_cap.num_conta_cont     = p_num_conta_deb
   LET p_lanc_cont_cap.val_lanc           = p_val_parc
   LET p_lanc_cont_cap.tex_hist_lanc      = p_titulo.txthis
   LET p_lanc_cont_cap.ies_cnd_pgto       = 'S'
   LET p_lanc_cont_cap.num_lote_lanc      = 0

   IF p_titulo.tplanc = 'AB' AND p_titulo.cdfase = 'NUM' THEN #duvida - e despesa/compen?
      LET p_lanc_cont_cap.ies_liberad_contab = 'N'
   ELSE
      LET p_lanc_cont_cap.ies_liberad_contab = 'S'
   END IF

   LET p_lanc_cont_cap.num_lote_transf    = p_ad_mestre.num_lote_transf
   LET p_lanc_cont_cap.dat_lanc           = p_ad_mestre.dat_rec_nf

   INSERT INTO lanc_cont_cap
      VALUES(p_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo lancamento contabeis)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_lanc_cont_cap.ies_tipo_lanc  = 'C'
   LET p_lanc_cont_cap.num_conta_cont = p_num_conta_cred
   LET p_seq_lanc = p_seq_lanc + 1
   LET p_lanc_cont_cap.num_seq        = p_seq_lanc

   INSERT INTO lanc_cont_cap
      VALUES(p_lanc_cont_cap.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados da tabela lanc_cont_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF NOT pol1031_ins_ctb_lanc() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1031_ins_ctb_lanc() #Ivo - 06/04/11 ...
#-----------------------------#

   DEFINE p_data_txt    CHAR(10),
          p_gravou      SMALLINT

   LET p_gravou = FALSE

   DECLARE cq_ctb CURSOR FOR
    SELECT arelin,
           vlparc
      FROM easy:eiz2
     WHERE codemp = p_cod_empresa
       AND keyeas = p_titulo.keyeas
       AND flag   = "N"
       AND tipmat = p_tip_mat
       AND vlparc > 0

   FOREACH cq_ctb INTO p_arelin, p_val_parc

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') ',
                     'lendo area e linha da tabela eiz2 por tipo de material)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      LET p_cod_lin_pord  = p_arelin[1,2]  #cod_area_negocio
      LET p_cod_lin_recei = p_arelin[3,4]  #cod_lin_negocio

      LET p_ctb_lanc.empresa             = p_lanc_cont_cap.cod_empresa
      LET p_ctb_lanc.periodo_contab      = YEAR(p_lanc_cont_cap.dat_lanc)
      LET p_ctb_lanc.segmto_periodo      = MONTH(p_lanc_cont_cap.dat_lanc)
      LET p_ctb_lanc.cta_deb             = p_num_conta_deb
      LET p_ctb_lanc.cta_cre             = 0
      LET p_ctb_lanc.dat_movto           = p_lanc_cont_cap.dat_lanc
      LET p_ctb_lanc.dat_vencto          = NULL
      LET p_ctb_lanc.dat_conversao       = NULL
      LET p_ctb_lanc.val_lancto          = p_val_parc
      LET p_ctb_lanc.qtd_outra_moeda     = 0

      SELECT par_val
        INTO p_ctb_lanc.hist_padrao
        FROM par_cap_pad
       WHERE cod_empresa = p_ctb_lanc.empresa
         AND cod_parametro = 'cod_hist_lanc_anl'

      IF STATUS <> 0 THEN
         LET p_ctb_lanc.hist_padrao = 0
      END IF

      LET p_ctb_lanc.compl_hist          = p_lanc_cont_cap.tex_hist_lanc
      LET p_ctb_lanc.linha_produto       = p_cod_lin_pord
      LET p_ctb_lanc.linha_receita       = p_cod_lin_recei
      LET p_ctb_lanc.segmto_mercado      = 0
      LET p_ctb_lanc.classe_uso          = 0

      LET p_ctb_lanc.num_relacionto      = pol1031_busca_num_relacionto()

      IF p_ctb_lanc.num_relacionto < 0 THEN
         RETURN FALSE
      END IF

      LET p_ctb_lanc.lote_contab         = p_lanc_cont_cap.num_lote_lanc
      LET p_ctb_lanc.num_lancto          = 0
      LET p_ctb_lanc.empresa_origem      = p_lanc_cont_cap.cod_empresa

      LET p_ctb_lanc.sequencia_registro  = pol1031_busca_sequencia_registro()

      IF p_ctb_lanc.sequencia_registro < 0 THEN
         RETURN FALSE
      END IF

      LET p_ctb_lanc.num_ad_ap           = p_lanc_cont_cap.num_ad_ap
      LET p_ctb_lanc.eh_ad_ap            = p_lanc_cont_cap.ies_ad_ap
      LET m_seql_lanc_cap                = m_seql_lanc_cap + 1
      LET p_ctb_lanc.seql_lanc_cap       = m_seql_lanc_cap
      LET p_ctb_lanc.tip_despesa_val     = p_lanc_cont_cap.cod_tip_desp_val
      LET p_ctb_lanc.eh_despesa_val      = p_lanc_cont_cap.ies_desp_val
      LET p_ctb_lanc.eh_manual_autom     = p_lanc_cont_cap.ies_man_aut
      LET p_ctb_lanc.eh_cond_pagto       = p_lanc_cont_cap.ies_cnd_pgto
      LET p_ctb_lanc.lote_transf         = p_lanc_cont_cap.num_lote_transf
      LET p_ctb_lanc.banco_pagador       = NULL #igual ap
      LET p_ctb_lanc.cta_bancaria        = NULL #igual ap
      LET p_ctb_lanc.docum_pagto         = NULL
      LET p_ctb_lanc.tip_docum_pagto     = NULL
      LET p_ctb_lanc.fornecedor          = p_ad_mestre.cod_fornecedor
      LET p_ctb_lanc.liberado            = 'N'

      INSERT INTO ctb_lanc_ctbl_cap
         VALUES(p_ctb_lanc.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo conta debito na tab ctb_lanc_ctbl_cap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      LET p_ctb_lanc.cta_deb             = 0
      LET p_ctb_lanc.cta_cre             = p_num_conta_cred
      LET m_seql_lanc_cap                = m_seql_lanc_cap + 1
      LET p_ctb_lanc.seql_lanc_cap       = m_seql_lanc_cap

      LET p_ctb_lanc.sequencia_registro  = pol1031_busca_sequencia_registro()

      IF p_ctb_lanc.sequencia_registro < 0 THEN
         RETURN FALSE
      END IF

      INSERT INTO ctb_lanc_ctbl_cap
         VALUES(p_ctb_lanc.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo conta credito na tab ctb_lanc_ctbl_cap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      LET p_gravou = TRUE
   END FOREACH

   IF p_gravou = FALSE THEN
      LET p_msg = 'Nenhum registro incluído na tab ctb_lanc_ctbl_cap'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol1031_busca_num_relacionto()
#---------------------------------------#

   DEFINE l_num_relacionto DECIMAL(6,0)

   SELECT DISTINCT(num_relacionto)
     INTO l_num_relacionto
     FROM ctb_lanc_ctbl_cap
    WHERE empresa        = p_ctb_lanc.empresa
      AND periodo_contab = p_ctb_lanc.periodo_contab
      AND segmto_periodo = p_ctb_lanc.segmto_periodo
      AND num_ad_ap      = p_ctb_lanc.num_ad_ap
      AND eh_ad_ap       = p_ctb_lanc.eh_ad_ap

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'Erro(',STATUS,') lendo relacionamento da tabela ctb_lanc_ctbl_cap)'
      CALL pol1031_insere_erro()
      RETURN (-1)
   END IF

   IF l_num_relacionto IS NOT NULL THEN
      RETURN l_num_relacionto
   END IF

   SELECT MAX(num_relacionto)
     INTO l_num_relacionto
     FROM ctb_lanc_ctbl_cap
    WHERE empresa        = p_ctb_lanc.empresa
      AND periodo_contab = p_ctb_lanc.periodo_contab
      AND segmto_periodo = p_ctb_lanc.segmto_periodo

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'Erro(',STATUS,') lendo máximo relacionamento da tab ctb_lanc_ctbl_cap)'
      CALL pol1031_insere_erro()
      RETURN (-1)
   END IF

   IF l_num_relacionto IS NOT NULL THEN
      LET l_num_relacionto = l_num_relacionto + 1

      IF l_num_relacionto > 999999 THEN
         LET l_num_relacionto = 999999
      END IF
   ELSE
      LET l_num_relacionto = 1
   END IF

   RETURN l_num_relacionto

END FUNCTION

#------------------------------------------#
FUNCTION pol1031_busca_sequencia_registro()
#------------------------------------------#

   DEFINE l_sequencia_registro INTEGER

   SELECT MAX(sequencia_registro)
     INTO l_sequencia_registro
     FROM ctb_lanc_ctbl_cap
    WHERE empresa        = p_ctb_lanc.empresa
      AND periodo_contab = p_ctb_lanc.periodo_contab

   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'Erro(',STATUS,') lendo máxima sequencia da tab ctb_lanc_ctbl_cap)'
      CALL pol1031_insere_erro()
      RETURN (-1)
   END IF

   IF l_sequencia_registro IS NULL THEN
      LET l_sequencia_registro = 0
   END IF

   LET l_sequencia_registro = l_sequencia_registro + 1

   RETURN (l_sequencia_registro)

END FUNCTION

#---------------------------#
FUNCTION pol1031_insere_ap()
#---------------------------#

    IF NOT pol1031_le_par_ap() THEN
       RETURN FALSE
    END IF

    LET p_ap.cod_empresa       = p_cod_emp_ad
    LET p_ap.num_ap            = p_num_ap
    LET p_ap.num_versao        = 1
    LET p_ap.ies_versao_atual  = 'S'
    LET p_ap.num_parcela       = 1
    LET p_ap.cod_portador      = p_ad_mestre.cod_portador
    LET p_ap.cod_bco_pagador   = NULL
    LET p_ap.num_conta_banc    = NULL
    LET p_ap.cod_fornecedor    = p_ad_mestre.cod_fornecedor
    LET p_ap.cod_banco_for     = NULL
    LET p_ap.num_agencia_for   = NULL
    LET p_ap.num_conta_bco_for = NULL
    LET p_ap.num_nf            = p_ad_mestre.num_nf
    LET p_ap.num_duplicata     = NULL
    LET p_ap.num_bl_awb        = NULL
    LET p_ap.compl_docum       = NULL
    LET p_ap.val_nom_ap        = p_ad_mestre.val_tot_nf
    LET p_ap.val_ap_dat_pgto   = 0
    LET p_ap.cod_moeda         = p_ad_mestre.cod_moeda
    LET p_ap.val_jur_dia       = 0
    LET p_ap.taxa_juros        = NULL
    LET p_ap.cod_formula       = NULL
    LET p_ap.dat_emis          = p_ad_mestre.dat_emis_nf
    LET p_ap.dat_vencto_s_desc = p_ad_mestre.dat_venc
    LET p_ap.dat_vencto_c_desc = NULL
    LET p_ap.val_desc          = NULL
    LET p_ap.dat_pgto          = NULL
    LET p_ap.dat_proposta      = NULL
    LET p_ap.cod_lote_pgto     = p_ad_mestre.cod_lote_pgto
    LET p_ap.num_docum_pgto    = NULL
    LET p_ap.ies_lib_pgto_cap  = 'N'
    LET p_ap.ies_lib_pgto_sup  = 'S'
    LET p_ap.ies_baixada       = 'N'

    LET p_ap.ies_docum_pgto    = NULL

    LET p_ap.ies_ap_impressa   = 'N'
    LET p_ap.ies_ap_contab     = 'N'
    LET p_ap.num_lote_transf   = p_ad_mestre.num_lote_transf
    LET p_ap.ies_dep_cred      = 'N'
    LET p_ap.data_receb        = NULL
    LET p_ap.num_lote_rem_escr = 0
    LET p_ap.num_lote_ret_escr = 0
    LET p_ap.dat_rem           = NULL
    LET p_ap.dat_ret           = NULL
    LET p_ap.status_rem        = 0
    LET p_ap.ies_form_pgto_escr= NULL

   IF NOT pol1031_ins_ap() THEN
      RETURN FALSE
   END IF

   if p_titulo.valpis > 0 THEN
      LET p_cod_tip_val = p_parametros_912.cod_tip_val_piscof
      let p_valor = p_titulo.valpis
      if not pol1031_ins_ap_valor() then
         RETURN false
      end if
      if not pol1031_ins_comp(p_ad_mestre.num_ad, p_valor) then
         RETURN false
      end if
   end if

   if p_titulo.valir > 0 THEN
      LET p_cod_tip_val = p_parametros_912.cod_tip_val_ir
      let p_valor = p_titulo.valir
      if not pol1031_ins_ap_valor() then
         RETURN false
      end if
      if not pol1031_ins_comp(p_ad_mestre.num_ad, p_valor) then
         RETURN false
      end if
   end if

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1031_ins_ap()
#------------------------#

   INSERT INTO ap
      VALUES(p_ap.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_cod_tip_despesa = p_ad_mestre.cod_tip_despesa

   IF NOT pol1031_le_conta() THEN
      RETURN FALSE
   END IF

   INSERT INTO ap_tip_desp
    VALUES(p_ap.cod_empresa,
           p_ap.num_ap,
           p_num_conta_cred,
           p_cod_hist_deb_ap,
           p_cod_tip_despesa,
           p_ap.val_nom_ap)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ap_tip_desp)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO ad_ap
      VALUES(p_ap.cod_empresa,
             p_ad_mestre.num_ad,
             p_ap.num_ap,
             p_ap.num_lote_transf)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ad_ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_msg = p_ap.num_ap
   LET p_msg = 'pol1031 - INCLUSAO DA AP No. ', p_msg CLIPPED
   LET p_hora = CURRENT HOUR TO SECOND

   let p_audit.cod_empresa     = p_ad_mestre.cod_empresa
   let p_audit.ies_tabela      = '2'
   let p_audit.nom_usuario     = p_user
   let p_audit.num_ad_ap       = p_ap.num_ap
   let p_audit.ies_ad_ap       = '2'
   let p_audit.num_nf          = p_ad_mestre.num_nf
   let p_audit.ser_nf          = p_ad_mestre.ser_nf
   let p_audit.ssr_nf          = p_ad_mestre.ssr_nf
   let p_audit.cod_fornecedor  = p_ad_mestre.cod_fornecedor
   let p_audit.ies_manut       = 'I'
   let p_audit.num_seq         = '1'
   let p_audit.desc_manut      = p_msg
   let p_audit.data_manut      = p_dat_proces
   let p_audit.hora_manut      = p_hora
   let p_audit.num_lote_transf = p_ad_mestre.num_lote_transf

   INSERT INTO audit_cap
      VALUES(p_audit.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela audit_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   INSERT INTO ap_favorecido
    VALUES(p_ap.cod_empresa,
           p_ap.num_ap,
           p_ad_mestre.cod_fornecedor)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela ap_favorecido)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0665_ins_adiantamento()
#---------------------------------#

   INITIALIZE p_adiant, p_mov_adiant TO NULL

   LET p_adiant.cod_empresa       = p_cod_emp_ad
   LET p_adiant.cod_fornecedor    = p_ad_mestre.cod_fornecedor
   LET p_adiant.num_pedido        = ""
   LET p_adiant.num_ad_nf_orig    = p_ad_mestre.num_ad
   LET p_adiant.ser_nf            = 'X'
   LET p_adiant.ssr_nf            = p_ad_mestre.ssr_nf
   LET p_adiant.dat_ref           = p_ad_mestre.dat_emis_nf
   LET p_adiant.val_adiant        = p_ad_mestre.val_tot_nf
   LET p_adiant.val_saldo_adiant  = p_adiant.val_adiant
   LET p_adiant.tex_observ_adiant = 'ADIANTAMENTO A DESPACHANTE'
   LET p_adiant.ies_forn_div      = 'F'
   LET p_adiant.ies_adiant_transf = 'N'
   LET p_adiant.ies_bx_automatica = 'N'

   INSERT INTO adiant VALUES(p_adiant.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo adiantamento na tabela adiant)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_mov_adiant.cod_empresa     = p_adiant.cod_empresa
   LET p_mov_adiant.dat_mov         = p_adiant.dat_ref
   LET p_mov_adiant.ies_ent_bx      = 'E'
   LET p_mov_adiant.cod_fornecedor  = p_ad_mestre.cod_fornecedor
   LET p_mov_adiant.num_ad_nf_orig  = p_adiant.num_ad_nf_orig
   LET p_mov_adiant.ser_nf          = p_adiant.ser_nf
   LET p_mov_adiant.ssr_nf          = p_adiant.ssr_nf
   LET p_mov_adiant.val_mov         = p_adiant.val_adiant
   LET p_mov_adiant.val_saldo_novo  = p_mov_adiant.val_mov
   LET p_mov_adiant.ies_ad_ap_mov   = 1
   LET p_mov_adiant.num_ad_ap_mov   = p_mov_adiant.num_ad_nf_orig
   LET p_mov_adiant.cod_tip_val_mov = 3
   LET p_mov_adiant.hor_mov         = CURRENT HOUR TO SECOND

   INSERT INTO mov_adiant VALUES(p_mov_adiant.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo adiantamento na tabela mov_adiant)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1031_le_conta()
#--------------------------#

   SELECT num_conta_deb,
          num_conta_cred,
          cod_hist_deb_ap
     INTO p_num_conta_deb,
          p_num_conta_cred,
          p_cod_hist_deb_ap
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_emp_ad
      AND cod_tip_despesa = p_cod_tip_despesa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo conta débito da tabela tipo_despesa)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_baixa_titulo()
#------------------------------#

   IF p_titulo.tplanc = 'CP' AND p_titulo.cdfase = 'DRL' THEN
      LET p_ies_docum_pgto = '3'
      LET p_num_docum = NULL
   ELSE
      LET p_ies_docum_pgto = '2'

      SELECT par_num
        INTO p_num_docum
        FROM par_cap_pad
       WHERE cod_empresa   = p_cod_emp_ad
         and cod_parametro = 'ult_num_aut_deb'

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo ult_num_aut_deb da tabela par_cap_pad)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      IF p_num_docum IS NULL THEN
         LET p_num_docum = 1
      ELSE
         LET p_num_docum = p_num_docum + 1
      END IF

      UPDATE par_cap_pad
         SET par_num = p_num_docum
       WHERE cod_empresa   = p_cod_emp_ad
         and cod_parametro = 'ult_num_aut_deb'

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') atualizando a tabela par_cap_pad)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      UPDATE par_cap
         SET ult_num_aut_deb = p_num_docum
       WHERE cod_empresa = p_cod_emp_ad

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') atualizando a tabela par_cap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

   END IF

   IF p_titulo.cdfase = 'PA' OR p_titulo.cdfase = 'CBO' THEN
      LET p_dat_proces = pol1031_dat_normal(p_titulo.dtdsmb)
   ELSE
      LET p_dat_proces = TODAY
   END IF

   select *
     into p_ap.*
     from ap
    WHERE cod_empresa      = p_cod_emp_ad
      AND num_ap           = p_num_ap
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo versao da ap na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   let p_num_versao = p_ap.num_versao

   select *
     into p_ad_mestre.*
     from ad_mestre
    where cod_empresa = p_cod_emp_ad
      and num_ad      = p_num_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados da AD na tabela ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   let p_ap.dat_vencto_s_desc  = p_dat_proces
   let p_ap.dat_pgto           = p_dat_proces
   let p_ap.dat_proposta       = p_dat_proces

   IF p_titulo.debcon = 'S' THEN

      IF (p_titulo.cdfase = 'CBO' and p_titulo.tplanc = 'LQ' OR
          p_titulo.cdfase = 'PA'  AND p_titulo.tplanc = 'LQ') AND
         (p_titulo.titerp is null or p_titulo.titerp = ' ') THEN
         LET p_dat_proces   = pol1031_dat_normal(p_titulo.dtdsmb)
         let p_ap.dat_emis           = p_dat_proces
         let p_ap.dat_vencto_s_desc  = p_dat_proces
         let p_ap.dat_pgto           = p_dat_proces
         let p_ap.dat_proposta       = p_dat_proces
         let p_ad_mestre.dat_rec_nf  = p_dat_proces
         let p_ad_mestre.dat_emis_nf = p_dat_proces
         let p_ad_mestre.dat_venc    = p_dat_proces
      else
         IF (p_titulo.cdfase = 'CBO' AND p_titulo.tplanc = 'LQ') OR
            (p_titulo.cdfase = 'PA'  AND p_titulo.tplanc = 'LQ') AND
             p_titulo.titerp <> ' ' THEN
            LET p_dat_proces   = pol1031_dat_normal(p_titulo.dtdsmb)
            let p_ap.dat_pgto           = p_dat_proces
            let p_ap.dat_vencto_s_desc  = p_dat_proces
            let p_ap.dat_proposta       = p_dat_proces
            let p_ad_mestre.dat_venc    = p_dat_proces
         else
            LET p_dat_proces  = pol1031_dat_normal(p_titulo.dtvcto)
            LET p_ap.dat_emis           = p_dat_proces
            let p_ap.dat_vencto_s_desc  = p_dat_proces
            let p_ap.dat_pgto           = p_dat_proces
            let p_ap.dat_proposta       = p_dat_proces
            let p_ad_mestre.dat_rec_nf  = p_dat_proces
            let p_ad_mestre.dat_emis_nf = p_dat_proces
         end if
      end if
   end if

   UPDATE ad_mestre
      SET cod_lote_pgto = p_num_lote,
          dat_emis_nf   = p_ad_mestre.dat_emis_nf,
          dat_rec_nf    = p_ad_mestre.dat_rec_nf,
          dat_venc      = p_ad_mestre.dat_venc
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad      = p_num_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando lote pgto na tabela ad_mestre)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   UPDATE lanc_cont_cap
      SET dat_lanc = p_ad_mestre.dat_rec_nf
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad_ap   = p_num_ad
      AND ies_ad_ap   = 1

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando data lanc na tabela lanc_cont_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   UPDATE ctb_lanc_ctbl_cap
      SET dat_movto = p_ad_mestre.dat_rec_nf
    WHERE empresa   = p_cod_emp_ad
      AND num_ad_ap = p_num_ad
      AND eh_ad_ap  = 1

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando data lanc na tabela ctb_lanc_ctbl_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   UPDATE ap
      SET num_docum_pgto   = p_num_docum,
          ies_docum_pgto   = p_ies_docum_pgto,
          cod_lote_pgto    = p_num_lote,
          ies_lib_pgto_cap = 'S',
          cod_bco_pagador  = p_cod_agen_bco,
          num_conta_banc   = p_titulo.conlog,
          dat_pgto         = p_ap.dat_pgto,
          dat_emis         = p_ap.dat_emis,
          dat_proposta     = p_ap.dat_proposta,
          dat_vencto_s_desc= p_ap.dat_vencto_s_desc
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap      = p_num_ap
      AND num_versao  = p_num_versao

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') baixando titulo na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   if not pol1031_ins_tit_pago() then
      RETURN false
   end if

   IF p_titulo.tplanc = 'CP' AND p_titulo.cdfase = 'DRL' THEN
      RETURN true
   else
      IF NOT pol1031_ins_cheque() then
         RETURN false
      end if
   END IF

   LET p_msg = 'POL1031 - AP NUM.', p_ap.num_ap
   LET p_msg = p_msg CLIPPED, ' - ALTERACAO DA DATA DE PAGAMENTO DE   PARA ', p_ap.dat_pgto

   IF NOT pol1031_ins_audit() then
      RETURN false
   END IF

   LET p_msg = 'POL1031 - AP NUM.', p_ap.num_ap
   LET p_msg = p_msg CLIPPED, ' - ALTERACAO DOCUMENTO DE PAGAMENTO DE  P/ ', p_num_docum

   IF NOT pol1031_ins_audit() then
      RETURN false
   END IF

   if p_titulo.vrcamb is null or p_titulo.vrcamb = ' ' then
   else
      if p_titulo.vrcamb <> 0 THEN

         let p_valor = p_titulo.vrcamb

         if p_valor < 0 then
            let p_valor = p_valor * -1
            let p_cod_tip_val = p_parametros_912.cod_tip_val_menos
         else
            let p_cod_tip_val = p_parametros_912.cod_tip_val_mais
         end IF

         if not pol1031_ins_ap_valor() then
            RETURN false
         end if

      end if

   end if

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_ins_tit_pago()
#------------------------------#

   insert into titulo_pago_912
    values(p_cod_emp_ad, p_num_ap, p_num_versao, p_cod_empresa)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo controle de titulos pago na tabela titulo_pago_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

end FUNCTION

#----------------------------#
FUNCTION pol1031_ins_cheque()
#----------------------------#

   define p_cheque record like cheque_bordero.*

   LET p_cheque.cod_empresa       = p_cod_emp_ad
   LET p_cheque.cod_bco_pagador   = p_cod_agen_bco
   LET p_cheque.num_cheq_bord     = p_num_docum
   LET p_cheque.num_conta_banco   = p_titulo.conlog
   IF p_titulo.debcon = 'S' THEN
      LET p_cheque.ies_cheq_bord  = '2'
   ELSE
      LET p_cheque.ies_cheq_bord  = '1'
   END IF
   LET p_cheque.ies_banc_fornec   = 'B'
   LET p_cheque.banco_favor       = p_titulo.cdbanc
   LET p_cheque.cod_fornec_favor  = ''
   LET p_cheque.ies_aut_man       = 'A'
   LET p_cheque.valor_cheque      = p_titulo.vldoct
   LET p_cheque.cod_lote          = p_num_lote      #antes gravava 12
   LET p_cheque.dat_emissao       = p_dat_proces
   LET p_cheque.dat_proposta      = p_dat_proces
   LET p_cheque.num_lote_conc     = 0               #antes gravava p_num_lote
   LET p_cheque.num_versao        = 1
   LET p_cheque.ies_cancelado     = 'N'
   LET p_cheque.num_seq_conc      = 0
   LET p_cheque.ies_mutuo         = 'N'
   LET p_cheque.cod_emp_ced_tom   = ''
   LET p_cheque.num_ad_ced_mutuo  = ''

   INSERT INTO cheque_bordero values(p_cheque.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela cheque_bordero)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN true

END FUNCTION

#----------------------------#
FUNCTION pol1031_ins_audit()
#----------------------------#

   define p_num_sq    integer

   select max(num_seq)
     into p_num_sq
     from audit_cap
    where cod_empresa = p_cod_emp_ad
      and num_ad_ap   = p_num_ap
      and ies_ad_ap   = '2'

   if p_num_sq is null then
      let p_num_sq = 1
   else
      let p_num_sq = p_num_sq + 1
   end if

   LET p_hora = CURRENT HOUR TO SECOND

   let p_audit.cod_empresa     = p_ad_mestre.cod_empresa
   let p_audit.ies_tabela      = '2'
   let p_audit.nom_usuario     = p_user
   let p_audit.num_ad_ap       = p_ap.num_ap
   let p_audit.ies_ad_ap       = '2'
   let p_audit.num_nf          = p_ad_mestre.num_nf
   let p_audit.ser_nf          = p_ad_mestre.ser_nf
   let p_audit.ssr_nf          = p_ad_mestre.ssr_nf
   let p_audit.cod_fornecedor  = p_ad_mestre.cod_fornecedor
   let p_audit.ies_manut       = 'M'
   let p_audit.num_seq         = p_num_sq
   let p_audit.desc_manut      = p_msg
   let p_audit.data_manut      = TODAY
   let p_audit.hora_manut      = p_hora
   let p_audit.num_lote_transf = p_ad_mestre.num_lote_transf

   INSERT INTO audit_cap
      VALUES(p_audit.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela audit_cap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_baixa_adiant()
#------------------------------#

   LET p_num_ad = p_titulo.titerp

   IF NOT pol1031_le_num_ap() THEN
      RETURN FALSE
   END IF

   IF NOT pol1031_le_tip_val() THEN
      RETURN FALSE
   END IF

   IF not pol1031_atu_adiant() then
      RETURN false
   END if

   SELECT *
     INTO p_ap.*
     FROM ap
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap      = p_num_ap
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') titulo de despesa na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_valor = p_vlcmps

   if p_titulo.valdif > 0 then
      LET p_valor = p_valor + p_titulo.valdif
   end if

   IF NOT pol1031_ins_ap_valor() THEN
      RETURN FALSE
   END IF

   if not p_baixa_titulo then
      RETURN true
   end if

   LET p_ap.val_nom_ap = p_val_ap_compl

   if not pol1031_nova_versao() then
      RETURN false
   end if

   update ap_tip_desp
      set val_tip_despesa = p_ap.val_nom_ap
    where cod_empresa = p_ap.cod_empresa
      and num_ap      = p_ap.num_ap

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando valor da ap_tip_desp)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_num_lote = p_parametros_912.num_lote_bx_adiant

   IF NOT pol1031_baixa_titulo() THEN
      RETURN FALSE
   END IF

   LET p_valdif = p_titulo.valdif

   IF p_valdif < 0 THEN
      let p_valor = p_valdif * -1
      IF NOT pol1031_gera_titulo_compl() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_valdif > 0 THEN
         let p_valor = p_valdif
         LET p_cod_tip_val = p_parametros_912.cod_tv_sdo_adiant
         IF NOT pol1031_ins_ap_valor() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1031_nova_versao()
#----------------------------#

   SELECT *
     INTO p_ad_mestre.*
     FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad      = p_num_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo AD origem para desmembrar em duas)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   UPDATE ap
      SET ies_versao_atual = 'N'
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap      = p_num_ap
      AND ies_versao_atual = 'S'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando versao da ap na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_versao_ant    = p_ap.num_versao
   LET p_ap.num_versao = p_ap.num_versao + 1

   INSERT INTO ap
      VALUES(p_ap.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo nova versao da ap na tabela ap)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_msg = 'POL1031 - AP NUM.', p_ap.num_ap
   LET p_msg = p_msg CLIPPED, ' - ALTERACAO DA VERSAO DE ', p_versao_ant
   LET p_msg = p_msg CLIPPED, ' PARA ', p_ap.num_versao

   if not pol1031_ins_audit() THEN
      RETURN false
   end if

   IF NOT pol1031_copia_ap_val() THEN
      RETURN FALSE
   END IF

   RETURN true

END FUNCTION

#---------------------------#
FUNCTION pol1031_le_tip_val()
#---------------------------#

   SELECT distinct cod_tip_val
     INTO p_cod_tip_val
     FROM tipo_item_912
    WHERE cod_empresa     = p_cod_empresa
      AND cod_tip_despesa = p_cod_tip_despesa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo tipo de valor da tabela tipo_item_912)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1031_copia_ap_val()
#------------------------------#

   DEFINE p_ap_valores RECORD LIKE ap_valores.*

   UPDATE ap_valores
      SET ies_versao_atual = 'N'
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ap      = p_num_ap
      AND num_versao  = p_versao_ant

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando versao original da ap_valores)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   let p_ind = 0

   DECLARE cq_val CURSOR FOR
    SELECT *
      FROM ap_valores
     WHERE cod_empresa = p_cod_emp_ad
       AND num_ap      = p_num_ap
       AND num_versao  = p_versao_ant

   FOREACH cq_val INTO p_ap_valores.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela ap_valores)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      LET p_ap_valores.num_versao = p_ap.num_versao
      LET p_ap_valores.ies_versao_atual = 'S'

      INSERT INTO ap_valores
       VALUES(p_ap_valores.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo nova versao da ap_valores)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1031_atu_adiant()
#----------------------------#

   select *
     into p_adiant.*
     from adiant
    where cod_empresa    = p_cod_emp_ad
      and num_ad_nf_orig = p_titulo.titvin

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo dados do adiantamento da tabela adiant)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   let p_adiant.val_saldo_adiant = p_adiant.val_saldo_adiant - p_vlcmps

   if p_titulo.valdif > 0 then
      let p_adiant.val_saldo_adiant = p_adiant.val_saldo_adiant - p_titulo.valdif
      LET p_mov_adiant.val_mov      = p_vlcmps + p_titulo.valdif
   else
      LET p_mov_adiant.val_mov      = p_vlcmps
   end if

   UPDATE adiant
      set val_saldo_adiant = p_adiant.val_saldo_adiant
    where cod_empresa    = p_cod_emp_ad
      and num_ad_nf_orig = p_titulo.titvin

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') atualizando saldo do adiantamento na tabela adiant)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   LET p_mov_adiant.cod_empresa     = p_cod_emp_ad
   LET p_mov_adiant.dat_mov         = today
   LET p_mov_adiant.ies_ent_bx      = 'B'
   LET p_mov_adiant.cod_fornecedor  = p_adiant.cod_fornecedor
   LET p_mov_adiant.num_ad_nf_orig  = p_titulo.titvin
   LET p_mov_adiant.ser_nf          = p_adiant.ser_nf
   LET p_mov_adiant.ssr_nf          = p_adiant.ssr_nf
   LET p_mov_adiant.val_saldo_novo  = p_adiant.val_saldo_adiant
   LET p_mov_adiant.ies_ad_ap_mov   = 2
   LET p_mov_adiant.num_ad_ap_mov   = p_num_ap
   LET p_mov_adiant.cod_tip_val_mov = p_cod_tip_val
   LET p_mov_adiant.hor_mov         = CURRENT HOUR TO SECOND

   let p_mov_adiant.ies_ent_bx = 'B'

   INSERT INTO mov_adiant
    values(p_mov_adiant.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo dados na tabela mov_adiant)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   sleep 1

   RETURN true

END FUNCTION

#----------------------------------#
FUNCTION pol1031_exporta_exclusao()
#----------------------------------#

   LET p_titulo.dtexp4 = data_ansi()
   LET p_titulo.hrexp4 = hora_atual()
   LET p_titulo.usexp4 = p_user

   DECLARE cq_exc cursor for
    select codemp,
           recno,
           titger
      from easy:ei17
     where flag   = 'S'
       and (dtexp4 is null or dtexp4 = ' ')
       and (titger is not null or titger <> ' ')
       and (titerp is null or titerp = ' ')


   FOREACH cq_exc into p_cod_empresa, p_num_recno, p_num_ad

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados na tabela ei17)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      if p_num_ad is null or p_num_ad = ' ' then
         CONTINUE FOREACH
      end if

      IF NOT pol1031_le_emp_orig_dest() THEN
         RETURN FALSE
      END IF

      select cod_empresa
        from ad_mestre
       where cod_empresa = p_cod_emp_ad
         and num_ad      = p_num_ad

      if status = 100 then
         update easy:ei17
            set flgeas = 'E',
                dtexp4 = p_titulo.dtexp4,
                hrexp4 = p_titulo.hrexp4,
                usexp4 = p_titulo.usexp4
          where codemp = p_cod_empresa
            and recno  = p_num_recno

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') atualizando flag de exclusao na tabela ei17)'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF

         delete from processo_cap
          where cod_empresa = p_cod_emp_ad
            and num_ad      = p_num_ad

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') deletando AD da tabela processo_cap)'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF

      else
         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') verificando ADs excluidas da tabela ad_mestre)'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF
      end if

   end FOREACH

   RETURN true

end FUNCTION

#--------------------------------------#
FUNCTION pol1031_exporta_estorno_pgto()
#--------------------------------------#

   DEFINE p_cd_fase CHAR(10)

   LET p_titulo.dtexp3 = data_ansi()
   LET p_titulo.hrexp3 = hora_atual()
   LET p_titulo.usexp3 = p_user

   DECLARE cq_pgto cursor with hold for
    select a.cod_empresa,
           a.num_ap,
           a.num_versao,
           a.cod_emp_orig
      from titulo_pago_912 a,
           ap b
     where a.cod_empresa = b.cod_empresa
       and a.num_ap      = b.num_ap
       and a.num_versao  = b.num_versao
       and (b.dat_pgto is null or b.dat_pgto = " ")

   FOREACH cq_pgto into p_cod_emp_ad, p_num_ap, p_num_versao, p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo pagamentos estornados da tabela titulo_pago_912)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      select distinct
             num_ad
        into p_num_ad
        from ad_ap
       where cod_empresa = p_cod_emp_ad
         and num_ap      = p_num_ap

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo numero da AD na tabela ad_ap)'
         CALL pol1031_insere_erro()
         RETURN FALSE
      END IF

      select recno,
             cdfase
        INTO p_num_recno,
             p_cd_fase
        from easy:ei17
       where codemp = p_cod_empresa
         and tplanc = 'LQ'
         and (titger = p_num_ad or titerp = p_num_ad)
         and (dtexp3 is null or dtexp3 = ' ')

      if status = 0 THEN
         IF p_cd_fase = 'CBO' THEN
            update easy:ei17
               set flgeas = 'B',
                   dtexp3 = p_titulo.dtexp3,
                   hrexp3 = p_titulo.hrexp3,
                   usexp3 = p_titulo.usexp3
             where codemp = p_cod_empresa
               and recno  = p_num_recno
            IF STATUS <> 0 THEN
               LET p_msg = 'Erro(',STATUS,') atualizando flag de estorno na tabela ei17)'
               CALL pol1031_insere_erro()
               RETURN FALSE
            END IF
         END IF
      else
         IF STATUS <> 100 THEN
            LET p_msg = 'Erro(',STATUS,') lendo flag de estorno da tabela ei17)'
            CALL pol1031_insere_erro()
            RETURN FALSE
         END IF
      end if

   end FOREACH

   RETURN true

END FUNCTION

#-----------------------------------#
FUNCTION pol1031_gera_titulo_compl()
#-----------------------------------#

   SELECT *
     INTO p_ad_mestre.*
     FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_ad
      AND num_ad      = p_num_ad

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo AD origem para desmembrar em duas)'
      CALL pol1031_insere_erro()
      RETURN FALSE
   END IF

   IF NOT pol1031_le_par_ap() THEN
      RETURN FALSE
   END IF

   LET p_ap.num_ap = p_num_ap
   LET p_ap.num_versao = 1
   LET p_ap.val_nom_ap = p_valor
   LET p_ap.ies_docum_pgto = null
   LET p_ap.dat_proposta = NULL
   LET p_ap.dat_pgto = NULL
   LET p_ap.dat_vencto_s_desc = pol1031_dat_normal(p_titulo.dtvcto)

   IF NOT pol1031_ins_ap() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------FIM DO PROGRAMA----------------#
