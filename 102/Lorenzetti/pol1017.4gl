#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1017                                                 #
# OBJETIVO: EXPORTAÇÃO DE DADOS PARA O EASY                         #
# DATA....: 01/03/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_emp_consol         LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_estatus            char(5),
          p_situa_ped          char(01),
          p_tem_erro           SMALLINT,
          p_dat_atu            CHAR(08),
          p_num_reg            INTEGER,
          p_recno_ei01         INTEGER,
          p_exporta            SMALLINT,
          p_achou              SMALLINT,
          p_num_seq            INTEGER,
          po_num_seq           INTEGER,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_chave              CHAR(700),
          p_ponto              CHAR(01),
          p_den_texto          CHAR(600)

   DEFINE p_cod_fabricante     CHAR(15),
          p_cod_tipo           CHAR(02),
          p_cod_aplic          CHAR(01),
          p_num_pedido         CHAR(15),
          p_recno              INTEGER,
          p_flag_oc            CHAR(01),
          p_num_versao         INTEGER,
          p_num_oc             INTEGER,
          p_pre_unit           DECIMAL(15,5),
          p_dat_abrev          CHAR(06),
          p_cdprod             CHAR(15),
          p_dtpven             CHAR(06),
          p_prcuni             DECIMAL(15,5),
          p_prcuni_txt         CHAR(15),
          p_qtde_txt           CHAR(13),
          p_oclog              CHAR(09),
          p_splog              CHAR(03),
          p_numped             CHAR(15),
          p_dat_expo           CHAR(08),
          p_hor_expo           CHAR(06),
          p_ja_exportou        SMALLINT,
          p_cdpagt             DECIMAL(3,0),
          p_incote             DECIMAL(2,0),
          p_qtd_item           INTEGER,
          p_qtd_expo           INTEGER,
          p_situa_prog         char(01),
          p_tip_frete          char(02),
          p_ies_tip_frete      char(01)


   DEFINE p_pedido             RECORD LIKE pedido_sup.*,
          p_ordem              RECORD LIKE ordem_sup.*,
          p_ped_compl          RECORD LIKE pedido_compl_912.*

   DEFINE p_param              RECORD
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
          cod_tip_val_ir       DECIMAL(3,0)
  END RECORD


   DEFINE p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_cod_pais           LIKE fornecedor.cod_pais,
          p_cod_cla_fisc       LIKE item.cod_cla_fisc,
          p_cod_item_fornec    LIKE item_fornec.cod_item_fornec,
          p_cod_familia        LIKE familia.cod_familia,
          p_cod_item           LIKE item.cod_item,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_moeda          LIKE ordem_sup.cod_moeda,
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_pes_unit           LIKE item.pes_unit,
          p_cod_fornecedor_2   LIKE fornecedor.cod_fornecedor,
          p_cod_cep            LIKE fornecedor.cod_cep,
          p_cod_cidade         LIKE fornecedor.cod_cidade,
          p_dat_entrega_ult    LIKE item_fornec.dat_entrega_ult,
          p_num_prog_entrega   LIKE prog_ordem_sup.num_prog_entrega,
          p_dat_entrega_prev   LIKE prog_ordem_sup.dat_entrega_prev,
          p_qtd_solic          LIKE prog_ordem_sup.qtd_solic,
          p_qtde               LIKE prog_ordem_sup.qtd_solic,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_local_desembarq    LIKE pedido_compl_912.local_desembarq,
          p_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
          p_cod_comprador      like pedido_sup.cod_comprador,
          p_fat_conver_unid    like ordem_sup.fat_conver_unid,
          p_den_esp            like esp_item_int.des_esp_item



   DEFINE pr_erro              ARRAY[10000] OF RECORD
          cod_empresa          CHAR(02),
          num_pedido           INTEGER,
          num_oc               INTEGER,
          den_erro             CHAR(80)
   END RECORD

   DEFINE p_ei02 RECORD
        numped      CHAR(15),
	cdprod      CHAR(15),
	codemp      CHAR(02),
	unrequ      CHAR(05),
	numsi       CHAR(06),
	cdfabr      CHAR(06),
	fablog      CHAR(15),
	qtde        CHAR(13),
	dtpvem      CHAR(06),
	dtpven      CHAR(06),
	prcuni      CHAR(15),
	classi      CHAR(01),
	cdfab2      CHAR(06),
	cdfab3      CHAR(06),
	cdfab4      CHAR(06),
	cdfab5      CHAR(06),
	cdfab6      CHAR(06),
	sequen      CHAR(04),
	oclog       CHAR(09),
	ocvers      CHAR(03),
	splog       CHAR(03),
	cclog       CHAR(04),
	sqexpd      CHAR(15),
	sqexit      CHAR(06),
	anuent      CHAR(01),
	tpintg      CHAR(01),
	codncm      CHAR(08),
	exncm       CHAR(03),
	exnbm       CHAR(03),
	recno       INTEGER,
	flag        CHAR(01),
	msgrej      CHAR(200),
	dtexpo      CHAR(08),
	hrexpo      CHAR(06),
	usexpo      CHAR(25),
	dtimpo      CHAR(08),
	hrimpo      CHAR(06),
	usimpo      CHAR(25),
	tdlog       CHAR(04),
	tipmat      CHAR(02)
   END RECORD


END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1017-05.10.06"
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

    CALL pol1017_controle()

END MAIN

#---------------------------#
 FUNCTION pol1017_controle()
#---------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1017") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1017 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET p_cod_empresa = '00'

   CALL pol1017_exporta_pedidos() RETURNING p_status

   DELETE FROM erro_export_912
   CALL pol1017_grava_erro()

   call pol1017_exp_cadastros() RETURNING p_status

   CALL pol1017_grava_erro()

   CLOSE WINDOW w_pol1017

END FUNCTION

#-----------------------------#
FUNCTION pol1017_bloqueia_ped()
#-----------------------------#

   DECLARE cq_bloq CURSOR FOR
    SELECT cod_empresa
      FROM pedido_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = p_pedido.num_pedido
       FOR UPDATE

    OPEN cq_bloq
   FETCH cq_bloq

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CLOSE cq_bloq
      LET p_msg = 'Nao foi possivel bloquear o registro, para exportacao de seus dados'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1017_le_param()
#--------------------------#

   SELECT *
     INTO p_param.*
     FROM parametros_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo tabela de parametros (parametros_912)'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   SELECT cod_empresa_destin
     INTO p_emp_consol
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_empresa

   IF STATUS = 100 THEN
      LET p_emp_consol = p_cod_empresa
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo empresa da tabela emp_orig_destino)'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
 FUNCTION pol1017_exporta_pedidos()
#----------------------------------#

   MESSAGE "  Aguarde! Exportando pedidos..."

   INITIALIZE p_pedido, p_ordem, pr_erro TO NULL

   LET p_dat_atu = data_ansi()
   LET p_num_seq = 0

   DECLARE cq_ped_sup CURSOR WITH HOLD FOR
    SELECT a.*
      FROM pedido_sup a,
           pedido_compl_912 b,
           parametros_912 c
     WHERE a.ies_situa_ped IN ('A','R','C')
       AND a.ies_versao_atual = 'S'
       AND a.cod_empresa = b.cod_empresa
       AND a.num_pedido  = b.num_pedido
       and c.cod_empresa = a.cod_empresa
     ORDER BY a.cod_empresa, a.num_pedido

   FOREACH cq_ped_sup INTO p_pedido.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo pedidos da tabela pedido_sup'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      let p_situa_ped = p_pedido.ies_situa_ped

      IF p_pedido.cod_empresa <> p_cod_empresa THEN
         LET p_cod_empresa = p_pedido.cod_empresa
         DISPLAY p_cod_empresa TO cod_empresa
         IF NOT pol1017_le_param() THEN
            RETURN FALSE
         END IF
      END IF

      DISPLAY p_pedido.num_pedido TO num_pedido

      IF NOT pol1017_le_ped_compl() THEN
         CONTINUE FOREACH
      END IF

      LET p_achou = FALSE

      DECLARE cq_cod_for CURSOR FOR
       SELECT cod_moeda,
              cod_fornecedor
         FROM ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido  = p_pedido.num_pedido
          AND ies_versao_atual = 'S'
          AND ies_situa_oc <> 'C'

      FOREACH cq_cod_for INTO p_cod_moeda, p_cod_fornecedor

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') lendo fornecedor da ordem_sup'
            CALL pol1017_insere_erro()
            RETURN FALSE
         END IF

         LET p_achou = TRUE
         EXIT FOREACH
      END FOREACH

      IF NOT p_achou THEN
         #LET p_msg = 'Pedido sem ordens de compra abertas ou liberadas'
         #CALL pol1017_insere_erro()
         CONTINUE FOREACH
      END IF

      SELECT cod_pais
        INTO p_cod_pais
        FROM fornecedor
       WHERE cod_fornecedor = p_cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo pais do fornecedor'
         CALL pol1017_insere_erro()
         CONTINUE FOREACH
      END IF

      IF p_cod_pais = p_param.cod_pais_br THEN
         CONTINUE FOREACH
      END IF

      LET p_num_pedido = p_pedido.num_pedido

      LET p_exporta = TRUE

      IF NOT pol1017_ve_se_exporta() THEN
         RETURN FALSE
      END IF

      IF NOT p_ja_exportou and p_situa_ped = 'C' then
         CONTINUE FOREACH
      END IF

      IF p_ped_compl.exporta_ped = 'S' then
         LET p_exporta = TRUE
      END IF

      IF NOT p_exporta THEN
         CONTINUE FOREACH
      END IF

      CALL log085_transacao("BEGIN")

      IF NOT pol1017_bloqueia_ped() THEN
         CALL log085_transacao("ROLLBACK")
      ELSE
         LET p_tem_erro = FALSE
         CALL pol1017_exporta_dados() RETURNING p_status
         IF p_tem_erro then
            CALL log085_transacao("ROLLBACK")
         ELSE
            CALL log085_transacao("COMMIT")
         END IF
      END IF

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1017_exporta_dados()
#-------------------------------#

   IF NOT pol1017_del_ped_nao_lido() THEN
      RETURN FALSE
   END IF

   DECLARE cq_ocs CURSOR FOR
    SELECT *
      FROM ordem_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedido.num_pedido
       AND ies_versao_atual = 'S'
       AND ies_situa_oc <> 'C'
     ORDER BY dat_entrega_prev

   FOREACH cq_ocs INTO p_ordem.*

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo ocs do pedido'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      let p_fat_conver_unid = p_ordem.fat_conver_unid

      SELECT cod_cla_fisc,
             cod_familia
        INTO p_cod_cla_fisc,
             p_cod_familia
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_ordem.cod_item

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo classificacao fiscal do item'
         CALL pol1017_insere_erro()
      END IF

      IF NOT pol1017_exp_ordem() THEN
         #RETURN FALSE
      END IF

      LET p_cod_item = p_ordem.cod_item
      let p_cod_tip_despesa = p_ordem.cod_tip_despesa

      SELECT cod_item_fornec
        INTO p_cod_item_fornec
        FROM item_fornec
       WHERE cod_empresa    = p_cod_empresa
         AND cod_item       = p_ordem.cod_item
         AND cod_fornecedor = p_ordem.cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo cod item do fornecedor'
         CALL pol1017_insere_erro()
         #RETURN FALSE
      END IF

      IF NOT pol1017_exp_item(p_ordem.cod_item) THEN
         #RETURN FALSE
      END IF

      IF NOT pol1017_exp_tip_desp(p_cod_tip_despesa) THEN
         #RETURN FALSE
      END IF

      IF NOT pol1017_unid_req(p_ordem.cod_item) THEN
         #RETURN FALSE
      END IF

      IF NOT pol1017_exp_fornec(p_ordem.cod_fornecedor) THEN
         #RETURN FALSE
      END IF

      IF p_cod_fabricante <> p_ordem.cod_fornecedor THEN
         IF NOT pol1017_exp_fornec(p_cod_fabricante) THEN
            #RETURN FALSE
         END IF
      END IF

      IF NOT pol1017_exp_cla_fisc(p_cod_cla_fisc) THEN
         #RETURN FALSE
      END IF

      IF NOT pol1017_exp_item_fornec(
             p_ordem.cod_item,p_ordem.cod_fornecedor) THEN
         #RETURN FALSE
      END IF

   END FOREACH

   IF NOT pol1017_exp_pedido() THEN
      RETURN FALSE
   END IF

   IF p_tem_erro THEN
      RETURN FALSE
   END IF

   update pedido_compl_912
      set exporta_ped = 'N'
    where cod_empresa = p_cod_empresa
      and num_pedido  = p_pedido.num_pedido

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Atualixzando flag de exportacao da tabela pedido_compl_912'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1017_insere_erro()
#----------------------------#

   LET p_num_seq = p_num_seq + 1

   IF p_num_seq = 10000 THEN
      LET p_msg = 'Limite de linhas do array pr_erro ultrapassou'
   ELSE
      IF p_num_seq > 10000 THEN
         RETURN
      END IF
   END IF

   LET pr_erro[p_num_seq].cod_empresa = p_cod_empresa
   LET pr_erro[p_num_seq].num_pedido  = p_pedido.num_pedido
   LET pr_erro[p_num_seq].num_oc      = p_ordem.num_oc
   LET pr_erro[p_num_seq].den_erro    = p_msg

   LET p_exporta = FALSE
   LET p_tem_erro = TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1017_grava_erro()
#----------------------------#

   FOR p_index = 1 TO p_num_seq
       IF pr_erro[p_index].den_erro IS NOT NULL THEN
          INSERT INTO erro_export_912(
             cod_empresa,
             num_seq,
             num_pedido,
             num_oc,
             den_erro)
          VALUES(pr_erro[p_index].cod_empresa,
                 p_index,
                 pr_erro[p_index].num_pedido,
                 pr_erro[p_index].num_oc,
                 pr_erro[p_index].den_erro)

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','erro_export_912')
          END IF
       END IF
   END FOR

   INITIALIZE pr_erro TO NULL
   LET p_num_seq = 0

END FUNCTION

#---------------------------#
FUNCTION pol1017_exp_ordem()
#---------------------------#

   SELECT MAX(recno)
     INTO p_recno_ei01
     FROM easy:ei01
    WHERE codemp = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo numero do registro da tabela ei01'
      CALL pol1017_insere_erro()
      #RETURN FALSE
    END IF

   IF p_recno_ei01 IS NULL THEN
      LET p_recno_ei01 = 0
   END IF

   LET p_recno_ei01 = p_recno_ei01 + 1
   LET po_num_seq   = 0

   DISPLAY p_ordem.num_oc TO num_oc

   INITIALIZE p_ei02 TO NULL

   LET p_ei02.numped = p_pedido.num_pedido
   LET p_ei02.cdprod = p_ordem.cod_item
   LET p_ei02.codemp = p_cod_empresa

   IF NOT pol1017_le_linha() THEN
      #RETURN FALSE
   END IF

   LET p_ei02.unrequ = p_cod_lin_prod USING '&&', p_cod_lin_recei USING '&&'

   IF NOT pol1017_le_fabric() THEN
      #RETURN FALSE
   END IF

   LET p_ei02.fablog = p_cod_fabricante

   IF NOT pol1017_le_tip_item() THEN
      #RETURN FALSE
   END IF

   LET p_ei02.classi = p_cod_aplic

   LET p_ei02.numsi  = p_pedido.num_pedido
   LET p_ei02.oclog  = p_ordem.num_oc
   LET p_ei02.ocvers = p_ordem.num_versao
   LET p_ei02.cclog  = p_ordem.cod_secao_receb
   LET p_ei02.codncm = p_cod_cla_fisc[1,8]
   LET p_ei02.exncm  = p_cod_cla_fisc[9,10]

   LET p_count = 0

   DECLARE cq_prog CURSOR FOR
    SELECT num_prog_entrega,
           dat_entrega_prev,
           qtd_solic,
           ies_situa_prog
      FROM prog_ordem_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_oc      = p_ordem.num_oc
       AND num_versao  = p_ordem.num_versao

   FOREACH cq_prog INTO
           p_num_prog_entrega,
           p_dat_entrega_prev,
           p_qtd_solic,
           p_situa_prog

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo programacao de entrega da OC da tab prog_ordem_sup '
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      IF NOT p_ja_exportou THEN
         if p_situa_prog = 'C' then
            CONTINUE FOREACH
         end if
         LET p_flag_oc = 'I'
      ELSE
         LET p_pre_unit = p_ordem.pre_unit_oc
         if p_situa_ped = 'C' then
            LET p_flag_oc = 'E'
         else
            IF NOT pol1017_seta_flag_oc() THEN
               #RETURN FALSE
            END IF
            if p_flag_oc = 'N' then
               CONTINUE FOREACH
            end if
         end if
      END IF

      LET p_qtd_solic = p_qtd_solic / p_fat_conver_unid
      LET p_ei02.qtde = p_qtd_solic  USING '&&&&&&&&&.&&&'
      LET p_ei02.qtde[LENGTH(p_ei02.qtde)-3] = '.'
      LET p_ei02.dtpven = data_abreviada(p_dat_entrega_prev)
      LET p_pre_unit = p_ordem.pre_unit_oc * p_fat_conver_unid
      LET p_ei02.prcuni = p_pre_unit USING '&&&&&&&&&.&&&&&'
      LET p_ei02.prcuni[LENGTH(p_ei02.prcuni)-5] = '.'
      LET p_ei02.splog  = p_num_prog_entrega
      LET p_ei02.tdlog  = p_ordem.cod_tip_despesa

      SELECT cod_tip_ad
        INTO p_ei02.tipmat
        FROM tipo_despesa_compl
       WHERE cod_empresa     = p_emp_consol
         AND cod_tip_despesa = p_ordem.cod_tip_despesa

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo tipo de material de da tab tipo_despesa_compl'
         CALL pol1017_insere_erro()
         #RETURN FALSE
      END IF

      IF NOT p_tem_erro THEN
         IF NOT pol1017_ins_ei02() THEN
            #RETURN FALSE
         END IF
      END IF

      LET p_count = p_count + 1

   END FOREACH

   IF p_count = 0 THEN
      LET p_msg = 'Ordem de compra sem programacao de entrega na tabela prog_ordem_sup'
      CALL pol1017_insere_erro()
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------# #tem por objetivo identificar se houve alteração ou
FUNCTION pol1017_seta_flag_oc()  #inclusão de programação de entrega
#------------------------------#

   LET p_dat_abrev = data_abreviada(p_dat_entrega_prev)
   LET p_cod_item  = p_ordem.cod_item

   SELECT cdprod,
          qtde,
          dtpven,
          prcuni
     INTO p_cdprod,
          p_qtde_txt,
          p_dtpven,
          p_prcuni_txt
     FROM easy:ei02
    WHERE codemp = p_cod_empresa
      AND numped = p_pedido.num_pedido
      AND oclog  = p_ordem.num_oc
      AND splog  = p_num_prog_entrega
      AND sqexpd = p_recno

   IF STATUS = 100 THEN
      if p_situa_prog <> 'C' then
         LET p_flag_oc = 'I'
      else
         LET p_flag_oc  = 'N'  #seta flag p/ indicar que não deve exportar essa programação
      end if
   ELSE
      IF STATUS = 0 THEN
         if p_situa_prog = 'C' then
            LET p_flag_oc = 'E'
         else
            LET p_flag_oc = 'A'
         end if
      ELSE
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela ei02'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1017_ins_ei02()
#--------------------------#

      SELECT MAX(recno)
        INTO p_num_reg
        FROM easy:ei02
       WHERE codemp = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo numero do registro da tabela ei02'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      IF p_num_reg IS NULL THEN
         LET p_num_reg = 0
      END IF

      LET p_num_reg     = p_num_reg + 1
      LET p_ei02.recno  = p_num_reg
      LET po_num_seq    = po_num_seq + 1
      LET p_ei02.sqexit = po_num_seq USING '&&&&&&'
      LET p_ei02.tpintg = p_flag_oc
      LET p_ei02.flag   = 'N'
      LET p_ei02.dtexpo = data_ansi()
      LET p_ei02.hrexpo = hora_atual()
      LET p_ei02.usexpo = p_user
      LET p_ei02.sqexpd = p_recno_ei01 USING '&&&&&&&&&&&&&&&'

      INSERT INTO easy:ei02(
							numped,
							cdprod,
							codemp,
							unrequ,
							numsi,
							cdfabr,
							fablog,
							qtde,
							dtpvem,
							dtpven,
							prcuni,
							classi,
							cdfab2,
							cdfab3,
							cdfab4,
							cdfab5,
							cdfab6,
							sequen,
							oclog,
							ocvers,
							splog,
							cclog,
							sqexpd,
							sqexit,
							anuent,
							tpintg,
							codncm,
							exncm,
							exnbm,
							recno,
							flag,
							msgrej,
							dtexpo,
							hrexpo,
							usexpo,
							dtimpo,
							hrimpo,
							usimpo,
							tdlog,
							tipmat)
      			VALUES(p_ei02.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') inserindo programacao de entrega da OC na tabela EI02'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol1017_le_linha()
#--------------------------#

   SELECT cod_lin_prod,
          cod_lin_recei
     INTO p_cod_lin_prod,
          p_cod_lin_recei
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ordem.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo area e linha da na tabela item'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1017_le_fabric()
#--------------------------#

   SELECT cod_fabric
     INTO p_cod_fabricante
     FROM fabric_item_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_ordem.cod_item
      AND cod_fornec  = p_cod_fornecedor

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo fabricante da tabela fabric_item_912'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   SELECT cod_fornecedor
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fabricante

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') consistindo fabricante na tabela fornecedor'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1017_le_tip_item()
#-----------------------------#

   SELECT campo_texto
     INTO p_cod_tipo
     FROM obf_parametro_item
    WHERE empresa = p_cod_empresa
      AND item    = p_ordem.cod_item
      AND campo   = 'tipo_item_sped'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo tipo de item da tabela obf_parametro_item'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   SELECT cod_aplic
     INTO p_cod_aplic
     FROM aplicacao_item_912
    WHERE cod_tipo = p_cod_tipo

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo tipo de aplicacao do item da tab aplicacao_item_912'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION pol1017_exp_item(p_cod_item)
#------------------------------------#

   DEFINE p_cod_item  LIKE item.cod_item

   DEFINE p_ei03      RECORD
          tpintg      CHAR(01),
          dtintg      CHAR(06),
          codemp      CHAR(02),
          cdprod      CHAR(15),
          unidad      CHAR(02),
          dscpor      CHAR(360),
          dscing      CHAR(360),
          dscli       CHAR(480),
          codncm      CHAR(08),
          pesolq      CHAR(11),
          vrfusd      CHAR(15),
          cdfami      CHAR(04),
          anuent      CHAR(01),
          exncm       CHAR(03),
          recno       INTEGER,
          flag        CHAR(01),
          msgrej      CHAR(200),
          dtexpo      CHAR(08),
          hrexpo      CHAR(06),
          usexpo      CHAR(25),
          dtimpo      CHAR(08),
          hrimpo      CHAR(06),
          usimpo      CHAR(25)
   END RECORD

   DISPLAY p_cod_item TO cod_item

   INITIALIZE p_ei03.* TO NULL

   LET p_ei03.tpintg = 'A'
   LET p_ei03.dtintg = data_abreviada(TODAY)
   LET p_ei03.codemp = p_cod_empresa

   SELECT den_item,
          pes_unit,
          cod_unid_med,
          cod_cla_fisc
     INTO p_ei03.dscpor,
          p_pes_unit,
          p_cod_unid_med,
          p_cod_cla_fisc
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,') lendo tabela item - Item:',p_cod_item
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   LET p_ei03.cdprod = p_cod_item

   IF NOT p_tem_erro THEN
      DELETE FROM easy:ei03
       WHERE codemp = p_cod_empresa
         AND cdprod = p_ei03.cdprod
         AND flag   = 'N'

      IF STATUS <> 0 THEN
         let p_estatus = STATUS USING '<<<<<'
         LET p_msg = 'Erro(',p_estatus,') deletando item da tab ei03 - Item:', p_cod_item
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF
   END if

   LET p_ei03.codncm = p_cod_cla_fisc[1,8]
   LET p_ei03.exncm  = p_cod_cla_fisc[9,10]
   LET p_ei03.pesolq = p_pes_unit USING '&&&&&&.&&&&'
   LET p_ei03.pesolq[7] = '.'

   SELECT cod_unid_easy
     INTO p_ei03.unidad
     FROM de_para_unid_912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_unid_logix = p_cod_unid_med

   IF STATUS <> 0 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,') lendo tab de_para_unid_912 - Item:', p_cod_item
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   SELECT den_item
     INTO p_ei03.dscing
     FROM den_item_int
    WHERE cod_empresa = p_cod_empresa
      AND cod_idioma  = p_param.cod_idioma
      AND cod_item    = p_cod_item

   IF STATUS <> 0 AND STATUS <> 100 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,') lendo tab den_item_int - Item:', p_cod_item
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   let p_count = 0

   DECLARE cq_esp CURSOR for
    select des_esp_item
      from esp_item_int
     where cod_empresa = p_cod_empresa
       and cod_item    = p_cod_item
       and cod_idioma  = p_param.cod_idioma

   FOREACH cq_esp into p_den_esp

      IF STATUS <> 0 AND STATUS <> 100 THEN
         let p_estatus = STATUS USING '<<<<<'
         LET p_msg = 'Erro(',p_estatus,') lendo tab esp_item_int - Item:', p_cod_item
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      if LENGTH(p_den_esp) > 0 then
         let p_ei03.dscing = p_ei03.dscing CLIPPED, ' ', p_den_esp
         let p_count = p_count + 1
         if p_count >= 4 then
            exit FOREACH
         end if
      end if

   end FOREACH
   
   LET p_tem_erro = FALSE

   SELECT cod_tip_despesa
     INTO p_ei03.cdfami
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 AND STATUS <> 100 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,') lendo tab item_sup - Item:', p_cod_item
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   IF p_tem_erro then
      RETURN false
   END if

   LET p_ei03.vrfusd = "000000000.00000"
   LET p_ei03.flag   = 'N'
   LET p_ei03.dtexpo = data_ansi()
   LET p_ei03.hrexpo = hora_atual()
   LET p_ei03.usexpo = p_user

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei03
    WHERE codemp = p_cod_empresa

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei03.recno = p_num_reg

   INSERT INTO easy:ei03(
          tpintg,
          dtintg,
          codemp,
          cdprod,
          unidad,
          dscpor,
          dscing,
          dscli,
          codncm,
          pesolq,
          vrfusd,
          cdfami,
          anuent,
          exncm,
          recno,
          flag,
          msgrej,
          dtexpo,
          hrexpo,
          usexpo,
          dtimpo,
          hrimpo,
          usimpo)
 	  VALUES (p_ei03.*)

	 IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,') inserindo o produto na tabela ei03'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------------#
 FUNCTION pol1017_exp_tip_desp(p_tip_desp)
#-----------------------------------------#

   DEFINE p_tip_desp  LIKE item_sup.cod_tip_despesa

   DEFINE p_ei18      RECORD
          tpintg      CHAR(01),
          dtintg      CHAR(06),
          codemp      CHAR(02),
          cdfami      CHAR(04),
          nomefm      CHAR(45),
          recno       INTEGER,
          flag        CHAR(01),
          msgrej      CHAR(200),
          dtexpo      CHAR(08),
          hrexpo      CHAR(06),
          usexpo      CHAR(25),
          dtimpo      CHAR(08),
          hrimpo      CHAR(06),
          usimpo      CHAR(25)
   END RECORD

   select cdfami
     from easy:ei18
    where codemp = p_cod_empresa
      and cdfami = p_tip_desp
      and flag   = 'N'

   IF STATUS = 0 then
      RETURN TRUE
   ELSE
      IF STATUS <> 100 THEN
         LET p_msg = 'Erro(',STATUS,') Lendo dados da tabela ei18'
	       CALL pol1017_insere_erro()
	       #RETURN FALSE
      end if
   end if

   DISPLAY p_tip_desp TO tip_desp

   INITIALIZE p_ei18.* TO NULL

   LET p_ei18.cdfami  = p_tip_desp
   LET p_ei18.tpintg = 'A'
   LET p_ei18.dtintg = data_abreviada(TODAY)
   LET p_ei18.codemp = p_cod_empresa
   LET p_ei18.flag   = 'N'
   LET p_ei18.dtexpo = data_ansi()
   LET p_ei18.hrexpo = hora_atual()
   LET p_ei18.usexpo = p_user

   SELECT nom_tip_despesa
     INTO p_ei18.nomefm
     FROM tipo_despesa
    WHERE cod_empresa     = p_emp_consol
      AND cod_tip_despesa = p_tip_desp

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,') Lendo dados da tabela tipo_despesa'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   IF p_tem_erro then
     RETURN false
   END if

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei18
    WHERE codemp = p_cod_empresa

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei18.recno = p_num_reg

   INSERT INTO easy:ei18(
          tpintg,
          dtintg,
          codemp,
          cdfami,
          nomefm,
          recno,
          flag,
          msgrej,
          dtexpo,
          hrexpo,
          usexpo,
          dtimpo,
          hrimpo,
          usimpo) VALUES (p_ei18.*)

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,') inserindo tipo de despesas na tabela ei18'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
 FUNCTION pol1017_unid_req(p_cod_item)
#------------------------------------#

   DEFINE p_cod_item  LIKE item.cod_item

   DEFINE p_ei19      RECORD
          tpintg      CHAR(01),
          dtintg      CHAR(06),
          codemp      CHAR(02),
          cdunrq      CHAR(05),
          nomecc      CHAR(50),
          locent      CHAR(02),
          entlog      CHAR(03),
          recno       INTEGER,
          flag        CHAR(01),
          msgrej      CHAR(200),
          dtexpo      CHAR(08),
          hrexpo      CHAR(06),
          usexpo      CHAR(25),
          dtimpo      CHAR(08),
          hrimpo      CHAR(06),
          usimpo      CHAR(25)
   END RECORD

   DISPLAY p_cod_item TO cod_item

   INITIALIZE p_ei19.* TO NULL


   LET p_ei19.tpintg = 'A'
   LET p_ei19.dtintg = data_abreviada(TODAY)
   LET p_ei19.codemp = p_cod_empresa

   SELECT cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso
     INTO p_cod_lin_prod,
          p_cod_lin_recei,
          p_cod_seg_merc,
          p_cod_cla_uso
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') Lendo dados da tabela item'
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   LET p_ei19.cdunrq  = p_cod_lin_prod USING "&&", p_cod_lin_recei USING "&&"

   select cdunrq
     from easy:ei19
    where codemp = p_cod_empresa
      and cdunrq = p_ei19.cdunrq
      and flag   = 'N'

   if status = 0 then
      return true
   else
      if status <> 100 then
         LET p_msg = 'Erro(',STATUS,') Lendo dados da tabela ei19'
	       CALL pol1017_insere_erro()
	       #RETURN FALSE
      end if
   end if

   SELECT den_estr_linprod
     INTO p_ei19.nomecc
     FROM linha_prod
    WHERE cod_lin_prod  = p_cod_lin_prod
      AND cod_lin_recei = p_cod_lin_recei
      AND cod_seg_merc  = p_cod_seg_merc
      AND cod_cla_uso   = p_cod_cla_uso

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,') Lendo dados da tabela linha_prod'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   IF p_tem_erro then
      RETURN false
   END IF

   LET p_ei19.entlog = p_pedido.num_texto_loc_entr
   LET p_ei19.flag   = 'N'
   LET p_ei19.dtexpo = data_ansi()
   LET p_ei19.hrexpo = hora_atual()
   LET p_ei19.usexpo = p_user

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei19
    WHERE codemp = p_cod_empresa

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei19.recno = p_num_reg

   INSERT INTO easy:ei19(
          tpintg,
          dtintg,
          codemp,
          cdunrq,
          nomecc,
          locent,
          entlog,
          recno,
          flag,
          msgrej,
          dtexpo,
          hrexpo,
          usexpo,
          dtimpo,
          hrimpo,
          usimpo) VALUES (p_ei19.*)

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,') inserindo a unidade requisitante na tabela ei19'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------------#
 FUNCTION pol1017_exp_fornec(p_cod_fornecedor)
#--------------------------------------------#

   DEFINE p_cod_fornecedor LIKE fornecedor.cod_fornecedor

   DEFINE p_ei04      RECORD
          tpintg      CHAR(01),
          dtintg      CHAR(06),
          cdfofb      CHAR(06),
          forlog      CHAR(15),
          razsoc      CHAR(40),
          nreduz      CHAR(20),
          endere      CHAR(40),
          nrend	      CHAR(06),
          bairro      CHAR(20),
          cidade      CHAR(15),
          nestad      CHAR(20),
          cdpais      CHAR(03),
          cep	      CHAR(08),
          cxpost      CHAR(05),
          contat      CHAR(15),
          depart      CHAR(30),
          telefo      CHAR(50),
          telex	      CHAR(10),
          fax	      CHAR(15),
          identi      CHAR(01),
          homolo      CHAR(01),
          nmrepr      CHAR(52),
          enrepr      CHAR(52),
          idrepr      CHAR(01),
          bcrepr      CHAR(03),
          agrepr	CHAR(05),
          ccrepr	CHAR(10),
          cgrepr	CHAR(14),
          bcforn	CHAR(03),
          agforn	CHAR(05),
          ccforn	CHAR(10),
          comiss	CHAR(01),
          comret	CHAR(01),
          orig01	CHAR(03),
          orig02	CHAR(03),
          orig03	CHAR(03),
          tfrepr	CHAR(50),
          fxrepr	CHAR(30),
          corepr	CHAR(50),
          cirepr	CHAR(30),
          ufrepr	CHAR(02),
          parepr	CHAR(03),
          cprepr	CHAR(08),
          swift		CHAR(30),
          barepr	CHAR(30),
          emrepr	CHAR(30),
          emforn	CHAR(30),
          cep2		CHAR(10),
          cconta	CHAR(150),
          recno		INTEGER,
          flag		CHAR(01),
          msgrej	CHAR(200),
          dtexpo	CHAR(08),
          hrexpo	CHAR(06),
          usexpo	CHAR(25),
          dtimpo	CHAR(08),
          hrimpo	CHAR(06),
          usimpo	CHAR(25)
   END RECORD

   DISPLAY p_cod_fornecedor TO cod_fornecedor

   INITIALIZE p_ei04.* TO NULL

   LET p_ei04.forlog = p_cod_fornecedor

   DELETE FROM easy:ei04
    WHERE forlog = p_ei04.forlog
      AND flag   = 'N'

   IF STATUS <> 0 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,') deletando fornecedor da tabela ei04'
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   LET p_ei04.tpintg = 'A'
   LET p_ei04.dtintg = data_abreviada(TODAY)

   SELECT raz_social,
          raz_social_reduz,
          end_fornec,
          den_bairro,
          cod_uni_feder,
          cod_pais,
          cod_cep,
          nom_contato,
          num_telefone,
          num_telex,
          num_fax,
          cod_cidade
     INTO p_ei04.razsoc,
          p_ei04.nreduz,
          p_ei04.endere,
          p_ei04.bairro,
          p_ei04.nestad,
          p_cod_pais,
          p_cod_cep,
          p_ei04.contat,
          p_ei04.telefo,
          p_ei04.telex,
          p_ei04.fax,
          p_cod_cidade
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      let p_estatus = STATUS  USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,
                  ') lendo fornecedor/fabricante ',p_cod_fornecedor,' na tabela fornecedor'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   SELECT cod_siscomex
     INTO p_ei04.cdpais
     FROM paises
    WHERE cod_pais = p_cod_pais

   IF STATUS <> 0 THEN
      let p_estatus = STATUS USING '<<<<<'
      LET p_msg = 'Erro(',p_estatus,
                  ') lendo siscomex da tab paises - Fornec:',p_cod_fornecedor
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   LET p_ei04.cep    = tira_formato(p_cod_cep)
   LET p_ei04.telefo = tira_formato(p_ei04.telefo)
   LET p_ei04.telex  = tira_formato(p_ei04.telex)
   LET p_ei04.fax    = tira_formato(p_ei04.fax)

   SELECT den_cidade
     INTO p_ei04.cidade
     FROM cidades
    WHERE cod_cidade = p_cod_cidade

   IF STATUS <> 0 THEN
            let p_estatus = STATUS USING '<<<<<'
	    LET p_msg = 'Erro(',p_estatus,
                  ') lendo tab cidades - Fornec:',p_cod_fornecedor
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   LET p_ei04.identi = '3'
   LET p_ei04.homolo = '2'

   SELECT e_mail
     INTO p_ei04.emforn
     FROM fornec_compl
    WHERE cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
            let p_estatus = STATUS USING '<<<<<'
	    LET p_msg = 'Erro(',p_estatus,
                  ') lendo email na tabela fornec_compl - Fornec:',p_cod_fornecedor
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   IF p_tem_erro then
      RETURN false
   END if

   LET p_ei04.flag   = 'N'
   LET p_ei04.dtexpo = data_ansi()
   LET p_ei04.hrexpo = hora_atual()
   LET p_ei04.usexpo = p_user

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei04

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei04.recno = p_num_reg

   INSERT INTO easy:ei04(
			tpintg,
			dtintg,
			cdfofb,
			forlog,
			razsoc,
			nreduz,
			endere,
			nrend,
			bairro,
			cidade,
			nestad,
			cdpais,
			cep,
			cxpost,
			contat,
			depart,
			telefo,
			telex,
			fax,
			identi,
			homolo,
			nmrepr,
			enrepr,
			idrepr,
			bcrepr,
			agrepr,
			ccrepr,
			cgrepr,
			bcforn,
			agforn,
			ccforn,
			comiss,
			comret,
			orig01,
			orig02,
			orig03,
			tfrepr,
			fxrepr,
			corepr,
			cirepr,
			ufrepr,
			parepr,
			cprepr,
			swift,
			barepr,
			emrepr,
			emforn,
			cep2,
			cconta,
			recno,
			flag,
			msgrej,
			dtexpo,
			hrexpo,
			usexpo,
			dtimpo,
			hrimpo,
			usimpo) VALUES (p_ei04.*)

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') inserindo dados do fornecedor na tabela EI04'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------------#
FUNCTION pol1017_exp_cla_fisc(p_cod_cla_fisc)
#-------------------------------------------#

   DEFINE p_cod_cla_fisc  LIKE item.cod_cla_fisc

   DEFINE p_ei05        RECORD
          tpintg      CHAR(01),
          dtintg      CHAR(06),
          codncm      CHAR(08),
          nancca      CHAR(07),
          nash        CHAR(08),
          descri      CHAR(40),
          aladi       CHAR(03),
          perii       CHAR(06),
          peripi      CHAR(06),
          pericm      CHAR(06),
          unidad      CHAR(02),
          dlnala      CHAR(10),
          dlgatt      CHAR(10),
          exncm       CHAR(03),
          destaq      CHAR(03),
          recno       INTEGER,
          flag        CHAR(01),
          msgrej      CHAR(200),
          dtexpo      CHAR(08),
          hrexpo      CHAR(06),
          usexpo      CHAR(25),
          dtimpo      CHAR(08),
          hrimpo      CHAR(06),
          usimpo      CHAR(25)
   END RECORD

   INITIALIZE p_ei05.* TO NULL

   LET p_ei05.codncm = p_cod_cla_fisc[1,8]
   LET p_ei05.exncm  = p_cod_cla_fisc[9,10]

   DELETE FROM easy:ei05
    WHERE codncm = p_ei05.codncm
      AND exncm  = p_ei05.exncm
      AND flag   = 'N'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') deletando classificacao fiscal da tabela ei05'
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   LET p_ei05.tpintg = 'A'
   LET p_ei05.dtintg = data_abreviada(TODAY)

   DECLARE cq_und_fis cursor for
    SELECT DISTINCT cod_unid_med_fisc
      FROM clas_fiscal
     WHERE cod_cla_fisc = p_cod_cla_fisc

   FOREACH cq_und_fis INTO p_cod_unid_med

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,
                     ') lendo classificação fiscal da tabela clas_fiscal'
	        CALL pol1017_insere_erro()
	        #RETURN FALSE
      END IF

      IF p_cod_cla_fisc[1,8]="99999999" THEN 
         LET p_msg = 'Erro(',STATUS,
                     ') classif.fiscal inválida, nao pode ser generica 99999999'
	        CALL pol1017_insere_erro()
	        #RETURN FALSE
      END IF

      EXIT FOREACH
   END FOREACH

   SELECT cod_unid_easy
     INTO p_ei05.unidad
     FROM de_para_unid_912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_unid_logix = p_cod_unid_med

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo undade de medida da tab de_para_unid_912'
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   IF p_tem_erro then
      RETURN false
   END IF

   LET p_ei05.flag   = 'N'
   LET p_ei05.dtexpo = data_ansi()
   LET p_ei05.hrexpo = hora_atual()
   LET p_ei05.usexpo = p_user

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei05

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei05.recno = p_num_reg

   DATABASE logix

   INSERT INTO easy:ei05(
           tpintg,
           dtintg,
           codncm,
           nancca,
           nash,
           descri,
           aladi,
           perii,
           peripi,
           pericm,
           unidad,
           dlnala,
           dlgatt,
           exncm,
           destaq,
           recno,
           flag,
           msgrej,
           dtexpo,
           hrexpo,
           usexpo,
           dtimpo,
           hrimpo,
           usimpo)
   VALUES (p_ei05.*)

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') inserindo dados da classificacao fiscal na tabela EI04'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION pol1017_exp_item_fornec(
                p_cod_item, p_cod_fornecedor)
#--------------------------------------------#

   DEFINE p_cod_item       LIKE item.cod_item,
          p_cod_fornecedor LIKE fornecedor.cod_fornecedor,
          p_tmp_ressup     DECIMAL(4,0),
          p_qtd_lote_min   DECIMAL(12,3),
          p_qtd_lote_mult  DECIMAL(12,3)

   DEFINE p_ei14    RECORD
  tpintg      CHAR(01),
	dtintg      CHAR(06),
	codemp      CHAR(02),
	cdprod      CHAR(15),
	cdfabr      CHAR(06),
	fablog      CHAR(15),
	cdforn      CHAR(06),
	forlog      CHAR(15),
	pnumbe      CHAR(20),
	homolo      CHAR(01),
	vlrcot      CHAR(15),
	ltforn      CHAR(05),
	qtdcot      CHAR(13),
	dtuent      CHAR(06),
	vlufob      CHAR(15),
	qtltmn      CHAR(08),
	qtltmx      CHAR(08),
	pnumb2      CHAR(48),
	moeda       CHAR(03),
	moelog      CHAR(02),
	unidad      CHAR(02),
	recno       INTEGER,
	flag        CHAR(01),
	msgrej      CHAR(200),
	dtexpo      CHAR(08),
	hrexpo      CHAR(06),
	usexpo      CHAR(25),
	dtimpo      CHAR(08),
	hrimpo      CHAR(06),
	usimpo      CHAR(25)
   END RECORD

   INITIALIZE p_ei14.* TO NULL

   LET p_ei14.tpintg = 'A'
   LET p_ei14.dtintg = data_abreviada(TODAY)
   LET p_ei14.codemp = p_cod_empresa

   SELECT cod_item_fornec,
          dat_entrega_ult
     INTO p_cod_item_fornec,
          p_dat_entrega_ult
     FROM item_fornec
    WHERE cod_empresa    = p_cod_empresa
      AND cod_item       = p_cod_item
      AND cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') lendo informacoes do item do fornecedor na tabela item_fornec'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   LET p_ei14.dtuent = data_abreviada(p_dat_entrega_ult)
   LET p_ei14.cdprod = p_cod_item
   LET p_ei14.pnumbe = p_cod_item_fornec

   IF NOT pol1017_le_fabric() THEN
      #RETURN FALSE
   END IF

   LET p_ei14.fablog     = p_cod_fabricante
   LET p_ei14.forlog     = p_cod_fornecedor
   LET p_ei14.homolo     = "1"
   LET p_ei14.vlrcot     = p_ordem.pre_unit_oc USING "&&&&&&&&&.&&&&&"
   LET p_ei14.vlrcot[10] = "."

   IF NOT p_tem_erro THEN
      DELETE FROM easy:ei14
       WHERE codemp = p_cod_empresa
         AND cdprod = p_ei14.cdprod
         AND forlog = p_ei14.forlog
         AND flag   = 'N'

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') deletando item da tabela ei14'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF
   END IF

   SELECT tmp_ressup
     INTO p_tmp_ressup
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') lendo informacoes do item na tabela item_man'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   LET p_ei14.ltforn = p_tmp_ressup USING '&&&&&'
   LET p_ei14.qtdcot = p_ordem.qtd_solic    USING '&&&&&&&&&.&&&'
   LET p_ei14.qtdcot[10] = '.'
   LET p_ei14.vlufob = p_ordem.pre_unit_oc  USING '&&&&&&&&&.&&&&&'
   LET p_ei14.vlufob[10] = '.'

   SELECT qtd_lote_minimo,
          qtd_lote_multiplo
     INTO p_qtd_lote_min,
          p_qtd_lote_mult
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') lendo dados do lote da tabela item_sup'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   LET p_ei14.qtltmn = p_qtd_lote_min  USING '&&&&&.&&'
   LET p_ei14.qtltmn[6] = '.'
   LET p_ei14.qtltmx = p_qtd_lote_mult USING '&&&&&.&&'
   LET p_ei14.qtltmx[6] = '.'
   LET p_ei14.moelog = p_ordem.cod_moeda

   SELECT cod_unid_easy
     INTO p_ei14.unidad
     FROM de_para_unid_912
    WHERE cod_empresa    = p_cod_empresa
      AND cod_unid_logix = p_ordem.cod_unid_med

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') lendo a unidade de medida da tabela de_para_unid_912'
	    CALL pol1017_insere_erro()
	    #RETURN FALSE
	 END IF

   IF p_tem_erro then
      RETURN false
   END if

   LET p_ei14.flag   = 'N'
   LET p_ei14.dtexpo = data_ansi()
   LET p_ei14.hrexpo = hora_atual()
   LET p_ei14.usexpo = p_user

   SELECT MAX(recno)
     INTO p_num_reg
     FROM easy:ei14
    WHERE codemp = p_cod_empresa

   IF p_num_reg IS NULL THEN
      LET p_num_reg = 0
   END IF

   LET p_num_reg = p_num_reg + 1

   LET p_ei14.recno = p_num_reg

   INSERT INTO easy:ei14(
           tpintg,
           dtintg,
           codemp,
           cdprod,
           cdfabr,
           fablog,
           cdforn,
           forlog,
           pnumbe,
           homolo,
           vlrcot,
           ltforn,
           qtdcot,
           dtuent,
           vlufob,
           qtltmn,
           qtltmx,
           pnumb2,
           moeda,
           moelog,
           unidad,
           recno,
           flag,
           msgrej,
           dtexpo,
           hrexpo,
           usexpo,
           dtimpo,
           hrimpo,
           usimpo) VALUES(p_ei14.*)

   IF STATUS <> 0 THEN
	    LET p_msg = 'Erro(',STATUS,
                  ') inserindo parâmetros do item do fornecedor na tabela EI14'
	    CALL pol1017_insere_erro()
	    RETURN FALSE
	 END IF

   RETURN TRUE

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

#-------------------#
 FUNCTION data_ansi()
#-------------------#

   DEFINE p_dat_hoje CHAR(08),
          p_retorno  CHAR(08)

   LET p_dat_hoje = tira_formato(TODAY)
   LET p_retorno  = p_dat_hoje[5,8],p_dat_hoje[3,4],p_dat_hoje[1,2]

   RETURN(p_retorno)

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


#--------------------#
 FUNCTION hora_atual()
#--------------------#

   DEFINE p_hor_hoje CHAR(06)

   LET p_hor_hoje = tira_formato(TIME)

   RETURN(p_hor_hoje)

END FUNCTION

#----------------------------#
FUNCTION pol1017_exp_pedido()
#----------------------------#

   DEFINE p_ei01 RECORD
        tpintg      CHAR(01),
	dtintg      CHAR(06),
	codemp      CHAR(02),
	modelo      CHAR(02),
	numped      CHAR(15),
	versao      CHAR(03),
	dtpedi      CHAR(06),
	locent      CHAR(02),
	entlog      CHAR(03),
	compra      CHAR(03),
	via         CHAR(02),
	origem      CHAR(03),
	destin      CHAR(03),
	cdpagt      CHAR(05),
	ddpagt      CHAR(03),
	agente      CHAR(03),
	import      CHAR(02),
	moeda       CHAR(03),
	moelog      CHAR(02),
	inland      CHAR(15),
	packin      CHAR(15),
	descon      CHAR(15),
	freint      CHAR(15),
	tpfret      CHAR(02),
	consig      CHAR(02),
	cdforn      CHAR(06),
	forlog      CHAR(15),
	profor      CHAR(15),
	dtprof      CHAR(06),
	uspari      CHAR(13),
	dtpari      CHAR(06),
	pesobr      CHAR(13),
	client      CHAR(06),
	forwar      CHAR(03),
	incote      CHAR(03),
	observ      CHAR(420),
	obsfim      CHAR(420),
	sqexpd      CHAR(15),
	recno       INTEGER,
	flag        CHAR(01),
	msgrej      CHAR(200),
	dtexpo      CHAR(08),
	hrexpo      CHAR(06),
	usexpo      CHAR(25),
	dtimpo      CHAR(08),
	hrimpo      CHAR(06),
	usimpo      CHAR(25)
   END RECORD

   INITIALIZE p_ei01 TO NULL

   select ies_tip_frete
     into p_ies_tip_frete
     from mod_embar_imp
    where cod_mod_embar = p_pedido.cod_mod_embar

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') lendo tipo de frete da tabela mod_embar_imp'
      CALL pol1017_insere_erro()
      #RETURN FALSE
   END IF

   if p_ies_tip_frete = '1' then
      let p_tip_frete = 'PP'
   else
      let p_tip_frete = 'CC'
   end if


   IF p_ja_exportou THEN
      LET p_ei01.tpintg = 'A'
   ELSE
      LET p_ei01.tpintg = 'I'
   END IF

   LET p_ei01.dtintg = data_abreviada(TODAY)
   LET p_ei01.codemp = p_cod_empresa
   LET p_ei01.numped = p_pedido.num_pedido
   LET p_ei01.versao = p_pedido.num_versao
   LET p_ei01.dtpedi = data_abreviada(p_pedido.dat_emis)
   LET p_ei01.entlog = p_pedido.num_texto_loc_entr
   LET p_ei01.compra = p_pedido.cod_comprador
   LET p_ei01.via    = p_ped_compl.cod_via_transp
   LET p_ei01.origem = p_ped_compl.local_embarq
   LET p_ei01.destin = p_ped_compl.local_desembarq
   LET p_ei01.cdpagt = p_pedido.cnd_pgto
   LET p_ei01.import = p_cod_empresa
   LET p_ei01.moelog = p_cod_moeda
   LET p_ei01.inland = p_ped_compl.desp_frete USING '&&&&&&&&&&&&.&&'
   LET p_ei01.inland[LENGTH(p_ei01.inland)-2] = '.'
   LET p_ei01.packin = p_ped_compl.desp_embal USING '&&&&&&&&&&&&.&&'
   LET p_ei01.packin[LENGTH(p_ei01.packin)-2] = '.'
   LET p_ei01.descon = p_ped_compl.desc_pedido USING '&&&&&&&&&&&&.&&'
   LET p_ei01.descon[LENGTH(p_ei01.descon)-2] = '.'
   LET p_ei01.freint = p_ped_compl.frete_inter USING '&&&&&&&&&&&&.&&'
   LET p_ei01.freint[LENGTH(p_ei01.freint)-2] = '.'
   LET p_ei01.tpfret = p_tip_frete
   LET p_ei01.forlog = p_cod_fornecedor
   LET p_ei01.incote = p_pedido.cod_mod_embar

   IF NOT pol1017_le_txt_ped(p_ped_compl.cod_txt_ini) THEN
      #RETURN FALSE
   END IF

   LET p_ei01.observ = p_den_texto

   IF NOT pol1017_le_txt_ped(p_ped_compl.cod_txt_fim) THEN
      #RETURN FALSE
   END IF

   IF p_tem_erro THEN
      RETURN FALSE
   END IF

   LET p_ei01.obsfim = p_den_texto

   LET p_ei01.sqexpd = p_recno_ei01 USING '&&&&&&&&&&&&&&&'
   LET p_ei01.recno  = p_recno_ei01 USING '&&&&&&&&&&&&&&&'
   LET p_ei01.flag   = 'N'
   LET p_ei01.dtexpo = data_ansi()
   LET p_ei01.hrexpo = hora_atual()
   LET p_ei01.usexpo = p_user

   INSERT INTO easy:ei01(
			tpintg,
			dtintg,
			codemp,
			modelo,
			numped,
			versao,
			dtpedi,
			locent,
			entlog,
			compra,
			via,
			origem,
			destin,
			cdpagt,
			ddpagt,
			agente,
			import,
			moeda,
			moelog,
			inland,
			packin,
			descon,
			freint,
			tpfret,
			consig,
			cdforn,
			forlog,
			profor,
			dtprof,
			uspari,
			dtpari,
			pesobr,
			client,
			forwar,
			incote,
			observ,
			obsfim,
			sqexpd,
			recno,
			flag,
			msgrej,
			dtexpo,
			hrexpo,
			usexpo,
			dtimpo,
			hrimpo,
			usimpo) VALUES(p_ei01.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,') inserindo pedido na tabela EI01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1017_le_ped_compl()
#-----------------------------#

   SELECT *
     INTO p_ped_compl.*
     FROM pedido_compl_912
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_pedido.num_pedido

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo dados complementares do pedido da tab pedido_compl_912'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1017_le_txt_ped(p_cod_txt)
#-------------------------------------#

   DEFINE p_texto   LIKE txt_pad_det.texto,
          p_cod_txt LIKE txt_pad_det.cod_texto

   INITIALIZE p_den_texto TO NULL

   DECLARE cq_txt_ped CURSOR FOR
    SELECT texto
      FROM txt_pad_det
     WHERE cod_empresa = p_cod_empresa
       AND cod_idioma  = p_param.cod_idioma
       AND cod_texto   = p_cod_txt

   FOREACH cq_txt_ped INTO p_texto

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,
                     ') lendo textos do pedido da tab pedido_sup_txt'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      LET p_den_texto = p_den_texto CLIPPED, ' ', p_texto

   END FOREACH

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1017_ve_se_exporta()
#-------------------------------#

   LET p_qtd_item = 0
   LET p_qtd_expo = 0

   {IF NOT pol1017_del_ped_nao_lido() THEN
      RETURN FALSE
   END IF}

   LET p_ja_exportou = FALSE

   IF NOT pol1017_le_dat_expo() THEN
      RETURN FALSE
   END IF

   IF p_dat_expo IS NULL THEN #se o pedido ainda não foi exportado,
      RETURN TRUE             #então devemos exportar
   END IF

   IF NOT pol1017_le_hor_expo() THEN
      RETURN FALSE
   END IF

   IF p_hor_expo IS NULL THEN
      LET p_msg = 'Nao foi possivel ler a hora da ultima exportacao do pedido'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   IF NOT pol1017_ver_recno() THEN
      RETURN FALSE
   END IF

   LET p_ja_exportou = TRUE #significa que na tabela de muro já existe uma versão do
                            #pedido, a qual já foi lida pelo easy

   IF p_pedido.num_versao < p_num_versao THEN
      LET p_msg = 'Ja foi exportada uma versao superior do pedido'
      CALL pol1017_insere_erro()
      LET p_exporta = FALSE
      RETURN TRUE
   END IF

   IF p_pedido.num_versao = p_num_versao THEN #Se a versãp for a mesma e
      IF p_pedido.ies_situa_ped = 'R' THEN    #o pedido já estáiver realizado,
         LET p_exporta = FALSE                #então não há necessidade de nova exportação
         RETURN TRUE
      END IF
   END IF

   SELECT COUNT(num_prog_entrega)    #verifica quantos itens de programação tem o pedido
     INTO p_qtd_item
     FROM prog_ordem_sup a,
          ordem_sup b
    WHERE b.cod_empresa = p_cod_empresa
      AND b.num_pedido  = p_pedido.num_pedido
      AND b.ies_versao_atual = 'S'
      AND a.cod_empresa = b.cod_empresa
      AND a.num_oc      = b.num_oc
      AND a.num_versao  = b.num_versao
      AND a.ies_situa_prog <> 'C'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo quantidade de itens do pedido da tabela prog_ordem_sup'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   SELECT COUNT(sqexpd)    #verifica quantos itens de programação foram exportados
     INTO p_qtd_expo
     FROM easy:ei02
    WHERE codemp = p_cod_empresa
      AND sqexpd = p_recno
      AND tpintg <> 'E'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo quantidade de itens do pedido exportada na tab ei02'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   IF p_qtd_item <> p_qtd_expo THEN  #se o pedido tiver mais itens, houve inclusão de OC
      RETURN TRUE                    #se tiver menos itens, houve exclusção de OC
   END IF                            #nesses casos, devemos exportar novamente o pedido


   IF p_pedido.num_versao > p_num_versao THEN #sempre que a versão do pedido for maior
      RETURN TRUE                    #que a versão já exportada, exportaremos denovo
   END IF

   SELECT cdpagt,
          incote,
          compra
     INTO p_cdpagt,
          p_incote,
          p_cod_comprador
     FROM easy:ei01
    WHERE codemp = p_cod_empresa
      AND recno  = p_recno

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo icoterms da tabela ei01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   IF p_pedido.cnd_pgto      <> p_cdpagt   OR    #se houve alteração no pedido,
      p_pedido.cod_mod_embar <> p_incote   OR    #então vamos exporta-lo novamente
      p_pedido.cod_comprador <> p_cod_comprador THEN
      RETURN TRUE
   END IF

   #o bloco de código a seguir, lê as programações de entrega de cada OC do pedido e compara
   #com os dados que já foram exportados. Se algum dado estiver diferente, então o pedido
   #terá que ser exportado novamente

   DECLARE cq_sup CURSOR FOR
    SELECT num_oc,
           num_versao,
           cod_item,
           pre_unit_oc,
           fat_conver_unid
      FROM ordem_sup
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_pedido.num_pedido
       AND ies_versao_atual = 'S'
       AND ies_situa_oc <> 'C'

   FOREACH cq_sup INTO
           p_num_oc,
           p_num_versao,
           p_cod_item,
           p_pre_unit,
           p_fat_conver_unid

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados do pedido da tabela ordem_sup'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      let p_pre_unit = p_pre_unit * p_fat_conver_unid

      DECLARE cq_dts CURSOR FOR
       SELECT num_prog_entrega,
              qtd_solic,
              dat_entrega_prev
         FROM prog_ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND num_oc      = p_num_oc
          AND num_versao  = p_num_versao

      FOREACH cq_dts INTO
              p_num_prog_entrega,
              p_qtd_solic,
              p_dat_entrega_prev

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') lendo dados do pedido da tabela ordem_sup'
            CALL pol1017_insere_erro()
            RETURN FALSE
         END IF

         LET p_qtd_solic = p_qtd_solic / p_fat_conver_unid
         LET p_dat_abrev = data_abreviada(p_dat_entrega_prev)

         SELECT cdprod,
                qtde,
                dtpven,
                prcuni
           INTO p_cdprod,
                p_qtde_txt,
                p_dtpven,
                p_prcuni_txt
           FROM easy:ei02
          WHERE codemp = p_cod_empresa
            AND numped = p_pedido.num_pedido
            AND oclog  = p_num_oc
            AND splog  = p_num_prog_entrega
            AND sqexpd = p_recno

         IF STATUS <> 0 THEN
            LET p_msg = 'Erro(',STATUS,') lendo dados da OC da tabela ei02'
            CALL pol1017_insere_erro()
            RETURN FALSE
         END IF

         LET p_qtde_txt[10]   = ','
         LET p_qtde = p_qtde_txt
         LET p_prcuni_txt[10] = ','
         LET p_prcuni = p_prcuni_txt

         IF p_cod_item  <> p_cdprod OR    #se houve alteração de um desses dados,
            p_dat_abrev <> p_dtpven OR     #então devemos exportar novamente o pedido
            p_qtd_solic <> p_qtde   OR
            p_pre_unit  <> p_prcuni THEN
            RETURN TRUE
         END IF

      END FOREACH

   END FOREACH

   LET p_exporta = FALSE  #seta flag de controle de exportação p/ não exportar
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1017_del_ped_nao_lido()
#----------------------------------#

   DELETE FROM easy:ei01
    WHERE codemp = p_cod_empresa
      AND numped = p_num_pedido
      AND flag   = 'N'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') deletando pedido nao lido da tab ei01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   DELETE FROM easy:ei02
    WHERE codemp = p_cod_empresa
      AND numped = p_num_pedido
      AND flag   = 'N'

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') deletando pedido nao lido da tab ei02'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1017_le_dat_expo()
#-----------------------------#

   SELECT MAX(dtexpo)
     INTO p_dat_expo
     FROM easy:ei01
    WHERE codemp = p_cod_empresa
      AND numped = p_num_pedido

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo ultima data de exportacao do pedido da tab ei01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1017_le_hor_expo()
#-----------------------------#

   SELECT MAX(hrexpo)
     INTO p_hor_expo
     FROM easy:ei01
    WHERE codemp = p_cod_empresa
      AND numped = p_num_pedido
      AND dtexpo = p_dat_expo

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo ultima hora de exportacao do pedido da tab ei01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1017_ver_recno()
#---------------------------#

   SELECT versao,
          recno
     INTO p_num_versao,
          p_recno
     FROM easy:ei01
    WHERE codemp = p_cod_empresa
      AND numped = p_num_pedido
      AND dtexpo = p_dat_expo
      AND hrexpo = p_hor_expo

   IF STATUS <> 0 THEN
      LET p_msg = 'Erro(',STATUS,
                  ') lendo versao do pedido exportado da tab ei01'
      CALL pol1017_insere_erro()
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1017_exp_cadastros()
#-------------------------------#

   if not pol1017_trig_item() then
      return false
   end if

   if not pol1017_trig_fornec() then
      return false
   end if

   return true

end FUNCTION

#---------------------------#
FUNCTION pol1017_trig_item()
#---------------------------#

   INITIALIZE p_pedido.num_pedido, p_ordem.num_oc to null

   DECLARE cq_tg_item CURSOR WITH HOLD FOR
    select DISTINCT
           cod_empresa,
           cod_item
      from tg_item_912

   FOREACH cq_tg_item into p_cod_empresa, p_cod_item

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela tg_item_912(trigger do item)'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      IF NOT pol1017_le_param() THEN
         RETURN FALSE
      END IF

      CALL log085_transacao("BEGIN")

      select ies_origem
        from lor_item
       where cod_empresa = p_cod_empresa
         and cod_item    = p_cod_item
         and ies_origem  = '1'

      if status = 0 then
         if not pol1017_exp_item(p_cod_item) then
            CALL log085_transacao("ROLLBACK")
            CONTINUE FOREACH
         end if
      else
         IF STATUS < 0 THEN
            LET p_msg = 'Erro(',STATUS,') origem da tabela lor_item(trigger do item)'
            CALL pol1017_insere_erro()
            RETURN FALSE
         END IF
      end if

      delete from tg_item_912
       where cod_empresa = p_cod_empresa
         and cod_item    = p_cod_item

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') deletando registros da tabela tg_item_912(trigger do item)'
         CALL pol1017_insere_erro()
         CALL log085_transacao("ROLLBACK")
      END IF

      CALL log085_transacao("COMMIT")

    END FOREACH

   return true

END FUNCTION

#-----------------------------#
FUNCTION pol1017_trig_fornec()
#-----------------------------#

   DECLARE cq_tg_for CURSOR WITH HOLD FOR
    select DISTINCT
           cod_fornecedor
      from tg_fornec_912

   FOREACH cq_tg_for into p_cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo dados da tabela tg_fornec_912'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      select cod_pais
        into p_cod_pais
        from fornecedor
       where cod_fornecedor = p_cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') lendo pais da tabela fornecedor'
         CALL pol1017_insere_erro()
         RETURN FALSE
      END IF

      if p_cod_pais is null or p_cod_pais = ' ' then
         let p_cod_pais = '001'
      end if

      CALL log085_transacao("BEGIN")

      if p_cod_pais <> '001' then
         if not pol1017_exp_fornec(p_cod_fornecedor) then
            CALL log085_transacao("ROLLBACK")
            CONTINUE FOREACH
         end if
      end if

      delete from tg_fornec_912
       where cod_fornecedor = p_cod_fornecedor

      IF STATUS <> 0 THEN
         LET p_msg = 'Erro(',STATUS,') deletando registros da tabela tg_fornec_912'
         CALL pol1017_insere_erro()
         CALL log085_transacao("ROLLBACK")
      END IF

      CALL log085_transacao("COMMIT")

    END FOREACH

   return true

END FUNCTION

