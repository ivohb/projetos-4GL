#------------------------------------------------------------------------------#
# OBJETIVO: APONTAMENTO AUTOM�TICO DE PRODU��O                                 #
# DATA....: 02/08/2007                                                         #
# ALTERA��ES MOTIVO                                                            #
# 24/11/08   GRAVAR A TABELA ESTOQUE_TRANS_REV NOS MOVTOS DE REVERS�O          #
# 29/04/09   incluir o campo consumorefugo na consist�ncia de estorno          #
# 30/04/09   verificar, a partir da tabela dat_consumo_885, se poder� ou n�o   #
#            procesar uma determinada data de consumo                          #
# 25/05/09   Checar a exist�ncia de estoque antes de baixar da tab estoque     #
# 08/06/09   Baixar pelo FIFO componente flor de loto  (v37)                   #
# 17/06/09   Acerto na baixa dos componentes           (v38)                   #
# 07/07/09   n�o baixar acess�rio e/ou flor de loto ao refugar/sucatear caixas #
#            n�o apontar cunsumo, pois j� existe o pol0930 para esse fim       # 
# 08/07/09   inserir registro na tab estoque, caso n�o exista                  #
#            atualizar saldos da tab estoque, caso seja diferente das demais   #
# 29/07/09   Inconsistir apontamento com data < data do fechamento             #
# 04/02/10   Gravar a tabela est_trans_relac p/ apontamento x consumo          #
#------------------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_reverte_flor       SMALLINT,
          p_num_sequencia      INTEGER,
          p_op_txt             CHAR(10),
          p_ies_com_detalhe    CHAR(01),
          p_tem_critica        SMALLINT,
          p_inse_trans         SMALLINT,
          p_qtd_integer        INTEGER,
          p_dat_prod           DATE,
          p_qtd_lt_tran        SMALLINT,
          p_ondu               CHAR(01),
          p_flag               CHAR(01),
          p_retorno            SMALLINT,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          p_versao             CHAR(18),
          p_ies_bobina         SMALLINT,
          p_nom_arquivo        CHAR(100),
          sql_stmt             CHAR(900),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080),
          p_cod_item_orig      CHAR(015),
          p_num_transac_dest   INTEGER,
          p_cod_item_dest      CHAR(015),
          p_dat_relac          DATE, 
          p_dat_geracao        CHAR(19),
          p_datageracao        DATE,
          p_dat_proces         DATE,
          p_hor_operac         CHAR(08)
          

   DEFINE p_statusregistro     LIKE apont_trim_885.statusregistro,
          p_cod_bob            LIKE item.cod_item,
          p_cod_item_refugo    LIKE parametros_885.cod_item_refugo,
          p_cod_item_retrab    LIKE parametros_885.cod_item_retrab,
          p_cod_item_sucata    LIKE parametros_885.cod_item_sucata,
          p_num_lote_sucata    LIKE parametros_885.num_lote_sucata,
          p_num_lote_refugo    LIKE parametros_885.num_lote_refugo,
          p_num_lote_retrab    LIKE parametros_885.num_lote_retrab,
          p_cod_local_refug    LIKE man_apont_912.local,
          p_cod_local_sucat    LIKE man_apont_912.local,
          p_cod_local_retrab   LIKE man_apont_912.local,
          p_msg                LIKE apont_erro_885.mensagem,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_qtd_aux            LIKE man_apont_912.qtd_boas,
          p_parametros         LIKE par_pcp.parametros,
          p_qtd_ordem          LIKE ordens.qtd_planej,
          p_item_ant           LIKE item.cod_item,
          p_qtd_trim           LIKE ordens.qtd_planej,
          p_num_neces          LIKE necessidades.num_neces,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_seq_leitura        LIKE man_apont_912.seq_leitura,
          p_cod_item_apon      LIKE item.cod_item,
          p_qtd_a_apontar      LIKE ord_oper.qtd_boas,
          p_cod_tip_movto      LIKE apo_oper.cod_tip_movto,
          p_qtd_ant            LIKE ordens.qtd_boas,
          p_dat_abert          LIKE ordens.dat_abert,
          p_sequencia          LIKE apont_trim_885.numsequencia,
          p_saldo_lote         LIKE estoque_lote.qtd_saldo,
          p_num_seq_pedido     LIKE man_apont_912.num_seq_pedido,
          p_qtd_prod           LIKE estoque_lote.qtd_saldo,
          p_dat_fecha_ult_man  LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup,
          p_ies_custo_medio    LIKE par_estoque.ies_custo_medio,
          p_ies_mao_obra       LIKE par_con.ies_mao_obra,
          p_qtd_necessaria     LIKE ord_compon.qtd_necessaria,
          p_cod_item           LIKE ordens.cod_item,
          p_num_seq_apont      LIKE apont_erro_885.numsequencia,
          p_numlote            LIKE estoque_lote.num_lote,
          p_num_op             LIKE ordens.num_ordem,
          p_num_ordem          LIKE ordens.num_ordem,
          p_num_docum          LIKE ordens.num_docum,
          p_cod_local_baixa    LIKE ord_compon.cod_local_baixa,
          p_num_conta          LIKE estoque_trans.num_conta,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_oper_transf        LIKE estoque_trans.cod_operacao,
          p_cod_operac         LIKE man_apont_912.operacao,
          p_cod_prod           LIKE ordens.cod_item,
          p_qtd_transf         LIKE ordens.qtd_planej,
          p_qtd_pecas          LIKE ordens.qtd_planej,
          p_cod_chapa          LIKE ordens.cod_item,
          p_area_livre         LIKE par_cst.area_livre,
          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_ies_apontado       LIKE desc_nat_oper_885.ies_apontado,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_mcg_empresa        LIKE mcg_filial.empresa,
          p_mcg_filial         LIKE mcg_filial.filial,
          p_cod_roteiro        LIKE ordens.cod_roteiro,
          p_num_altern_roteiro LIKE ordens.num_altern_roteiro,
          p_cod_local          LIKE man_apont_912.local,
          p_cod_ferramenta     LIKE consumo_fer.cod_ferramenta,
          p_parametro          LIKE consumo.parametro,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
          p_cod_recur          LIKE recurso.cod_recur,
          p_num_seq_operac     LIKE ord_oper.num_seq_operac,
          p_cod_cent_trab      LIKE ord_oper.cod_cent_trab,
          p_cod_arranjo        LIKE ord_oper.cod_arranjo,
          p_ies_apontamento    LIKE ord_oper.ies_apontamento,
          p_num_seq_ant        LIKE ord_oper.num_seq_operac,
          p_operacao           LIKE ord_oper.cod_operac,
          p_ies_oper_final     LIKE ord_oper.ies_oper_final,
          p_cod_uni_funcio     LIKE funcionario.cod_uni_funcio,
          p_empresa            LIKE mcg_filial.empresa,
          p_filial             LIKE mcg_filial.filial,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_num_lotea          LIKE estoque_lote.num_lote,
          p_num_lote_orig      LIKE estoque_trans.num_lote_orig,
          p_num_lote_dest      LIKE estoque_trans.num_lote_dest,
          p_num_lote_op        LIKE ordens.num_lote,
          p_qtd_reservada      LIKE estoque.qtd_reservada,
          p_qtd_liberada       LIKE estoque.qtd_liberada,
          p_qtd_lib_excep      LIKE estoque.qtd_lib_excep,
          p_qtd_rejeitada      LIKE estoque.qtd_rejeitada,
          p_qtd_planej         LIKE ord_oper.qtd_planejada, 
          p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
          p_ies_ctr_lote       LIKE item.ies_ctr_lote,
          p_ies_tem_inspecao   LIKE item.ies_tem_inspecao,
          p_cod_familia        LIKE item.cod_familia,
          p_qtd_boas           LIKE ord_oper.qtd_boas,
          p_qtd_refug          LIKE ord_oper.qtd_refugo,
          p_qtd_sucata         LIKE ordens.qtd_sucata,
          p_ies_tip_apont      LIKE item_man.ies_tip_apont,
          p_cod_grade_1        LIKE ordens_complement.cod_grade_1,
          p_cod_grade_2        LIKE ordens_complement.cod_grade_2,
          p_cod_grade_3        LIKE ordens_complement.cod_grade_3,
          p_cod_grade_4        LIKE ordens_complement.cod_grade_4,
          p_cod_grade_5        LIKE ordens_complement.cod_grade_5,
          p_qtd_saldo_apon     LIKE ord_oper.qtd_planejada,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_qtd_baixar         LIKE estoque_trans.qtd_movto,
          p_qtd_baixar_ant     LIKE estoque_trans.qtd_movto,
          p_num_processo       LIKE apo_oper.num_processo,
          p_ies_situa          LIKE ordens.ies_situa,
          p_ies_situa_orig     LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest     LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig     LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest     LIKE estoque_trans.cod_local_est_dest,
          p_num_transac_orig   LIKE estoque_trans.num_transac,
          p_num_transac_normal LIKE estoque_trans.num_transac,
          p_pri_num_transac    LIKE estoque_trans.num_transac,
          p_num_transac_o      LIKE estoque_lote.num_transac,
          p_num_transac_0      LIKE estoque_lote.num_transac,
          p_dat_inicio         LIKE ord_oper.dat_inicio,
          p_ies_forca_apont    LIKE item_man.ies_forca_apont,
          p_cod_cent_cust      LIKE ord_oper.cod_cent_cust,
          p_num_seq_reg        LIKE cfp_apms.num_seq_registro,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_cod_local_insp     LIKE item.cod_local_insp,
          p_num_transac        LIKE estoque_lote.num_transac,
          p_ctr_estoque        LIKE item.ies_ctr_estoque,
          p_ctr_lote           LIKE item.ies_ctr_lote,
          p_sobre_baixa        LIKE item_man.ies_sofre_baixa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_datproducao        LIKE apont_papel_885.datproducao,
          p_tempoproducao      LIKE apont_papel_885.tempoproducao,
          p_estorno            LIKE apont_papel_885.estorno,
          p_num_pedido         LIKE pedidos.num_pedido,
          p_ies_largura        LIKE item_ctr_grade.ies_largura,
          p_ies_altura         LIKE item_ctr_grade.ies_altura,
          p_ies_diametro       LIKE item_ctr_grade.ies_diametro,
          p_ies_comprimento    LIKE item_ctr_grade.ies_comprimento,
          p_ies_serie          LIKE item_ctr_grade.reservado_2,
          p_ies_dat_producao   LIKE item_ctr_grade.ies_dat_producao,
          p_largura            LIKE apont_trim_885.largura,
          p_altura             LIKE apont_trim_885.tubete,
          p_diametro           LIKE apont_trim_885.diametro,
          p_comprimento        LIKE apont_trim_885.comprimento,
          p_gramatura          LIKE gramatura_885.gramatura,
          p_largura_ped        LIKE apont_trim_885.largura,
          p_altura_ped         LIKE apont_trim_885.tubete,
          p_diametro_ped       LIKE apont_trim_885.diametro,
          p_comprimento_ped    LIKE apont_trim_885.comprimento,
          p_num_trans_lote     LIKE estoque_lote.num_transac,
          p_num_trans_ender    LIKE estoque_lote_ender.num_transac,
          p_num_lote_cons      LIKE estoque_lote.num_lote,
          p_cod_item_pai       LIKE item.cod_item,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_saida          LIKE necessidades.qtd_saida,
          p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,
          p_cod_oper_rp        LIKE par_pcp.cod_estoque_rp
          
          
   DEFINE p_cod_turno          CHAR(03),
          p_tem_ficha          SMALLINT,
          p_tem_chapa          SMALLINT,
          p_dim                CHAR(10),
          p_transf_refug       CHAR(01),
          p_trocou_op          SMALLINT,
          p_saldo_txt          CHAR(23),
          p_saldo_tx2          CHAR(11),
          p_pes_prod           DECIMAL(10,5),
          p_ies_onduladeira    CHAR(01),
          p_tipoRegistro       CHAR(01),
          p_baixou_mat         SMALLINT,
          p_tipo_processo      INTEGER,
          p_ies_chapa          SMALLINT,
          p_cod_oper           CHAR(01),
          p_criticou           SMALLINT,
          p_numpedido          CHAR(6),
          p_cod_status         CHAR(01),
          p_ies_par_cst        CHAR(01),
          p_grava_oplote       CHAR(01),
          p_carac              CHAR(01),
          p_rastreia           CHAR(01),
          p_hor_prod           CHAR(10),
          p_dat_char           CHAR(23),
          p_sem_estoque        SMALLINT,
          p_foi_baixado        CHAR(01),
          p_qtd_erro_inter     DECIMAL(6,0),
          p_qtd_erro_logix     DECIMAL(6,0),
          p_qtd_apontado       DECIMAL(6,0),
          p_qtd_erro_consu     DECIMAL(6,0),
          p_qtd_baixa_consu    DECIMAL(6,0),
          p_time               DATETIME HOUR TO SECOND,
          p_date_time          DATETIME YEAR TO SECOND,
          p_qtd_segundo        INTEGER,
          p_dat_ini            DATETIME YEAR TO SECOND,
          p_dat_fim            DATETIME YEAR TO SECOND,
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_ies_flor_deloto    SMALLINT,
          p_num_seq_apon       INTEGER,
          p_ies_proces         CHAR(01)
          
          

   DEFINE p_man                RECORD LIKE man_apont_912.*,
          p_mana               RECORD LIKE man_apont_912.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_audit_logix        RECORD LIKE audit_logix.*,
          p_apont_min          RECORD LIKE apont_min.*,
          p_apo_oper           RECORD LIKE apo_oper.*,
          p_cfp_aptm           RECORD LIKE cfp_aptm.*,
          p_cfp_apms           RECORD LIKE cfp_apms.*,
          p_cfp_appr           RECORD LIKE cfp_appr.*,
          p_chf_compon         RECORD LIKE chf_componente.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*,
          p_est_trans_area_lin RECORD LIKE est_trans_area_lin.*,
          p_ord_oper           RECORD LIKE ord_oper.*,
          p_apont              RECORD LIKE apont_trim_885.*
          
   DEFINE p_aen              RECORD 
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
   END RECORD

   DEFINE pr_erro            ARRAY[200] OF RECORD
          codempresa         CHAR(02),
          numsequencia       INTEGER,
          datconsumo         DATETIME YEAR TO DAY,
          mensagem           CHAR(70),
          dat_hor            DATETIME YEAR TO SECOND       
   END RECORD
     
 END GLOBALS


MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'POL0627-05.10.55' 

   WHENEVER ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
      DEFER INTERRUPT

   LET p_caminho = log140_procura_caminho('pol0627.iem')

  CALL log001_acessa_usuario("VDP","LIC_LIB")
        RETURNING p_status, p_cod_empresa, p_user

  IF p_status = 0  THEN
     CALL pol0627_controle() RETURNING p_status
     UPDATE proces_0627_885 SET ies_proces = 'N'
  END IF

END MAIN       


#--------------------------#
FUNCTION pol0627_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   

   LET p_qtd_apontado = 0   
   LET p_qtd_erro_consu = 0
   LET p_qtd_baixa_consu = 0
   
   LET p_cod_emp_ger = p_cod_empresa
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0627") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0627 AT 4,5 WITH FORM p_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_qtd_erro_inter TO qtd_erro_inter
   DISPLAY p_qtd_apontado TO qtd_apontado
   DISPLAY p_qtd_erro_consu TO qtd_erro_consu
   DISPLAY p_qtd_baixa_consu TO qtd_baixa_consu

   MESSAGE ' '
   
   DELETE  FROM estoque_lote_ender where qtd_saldo <= 0 and cod_empresa = 'O1'
   DELETE  FROM estoque_lote_ender where qtd_saldo <= 0 and cod_empresa = '01'
   DELETE  FROM estoque_lote where qtd_saldo <= 0 and cod_empresa = 'O1'
   DELETE  FROM estoque_lote where qtd_saldo <= 0 and cod_empresa = '01'
   
   # Refresh de tela
   #lds CALL LOG_refresh_display()	

   SELECT ies_proces
     INTO p_ies_proces
     FROM proces_0627_885
   
   IF STATUS = 100 THEN
      INSERT INTO proces_0627_885
       VALUES('S')
   ELSE
      IF STATUS = 0 THEN
         IF p_ies_proces = 'N' THEN
            UPDATE proces_0627_885
               SET ies_proces = 'S'
         ELSE
            MESSAGE 'Aguarde!...processando'
		    # Refresh de tela
		    #lds CALL LOG_refresh_display()	
      	    SLEEP 10
            RETURN TRUE
         END IF
      ELSE
         LET p_msg = 'EERO(',STATUS,')LENDO proces_0627_885'
         INSERT INTO apont_erro_885 
          VALUES(p_cod_empresa,0,0,p_msg)
          RETURN TRUE
      END IF
   END IF

   CREATE TEMP TABLE consumo_tmp_885 (
      cod_empresa      CHAR(02),
      num_transac_dest INTEGER,
      cod_item_dest    CHAR(15)
   );
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('criando','consumo_tmp_885')
      RETURN FALSE
   END IF
   
   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT cod_estoque_sp,
          cod_estoque_rp    
     INTO p_cod_oper_sp,
          p_cod_oper_rp
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_pcp')
      RETURN FALSE
   END IF

   SELECT cod_item_refugo,
          num_lote_refugo,
          cod_item_sucata,
          num_lote_sucata,
          cod_item_retrab,
          num_lote_retrab
     INTO p_cod_item_refugo,
          p_num_lote_refugo,
          p_cod_item_sucata,          
          p_num_lote_sucata,
          p_cod_item_retrab,
          p_num_lote_retrab
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO PARAMETROS_885'
      RETURN FALSE
   END IF
   
   SELECT cod_local_estoq
     INTO p_cod_local_refug
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refugo
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM'
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_sucat
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_sucata
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM'
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_retrab
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_retrab
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM'
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_sucat
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_sucata
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","item:local-refugo")       
      RETURN FALSE
   END IF

   DELETE FROM apont_erro_885
    WHERE mensagem LIKE '%ERRO%'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETANDO","APONT_ERRO_885:ERRO")       
      RETURN FALSE
   END IF

   DELETE FROM apont_erro_912
    WHERE den_critica LIKE '%ERRO%'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETANDO","APONT_ERRO_912:ERRO")       
      RETURN FALSE
   END IF
   
   DELETE FROM man_apont_912

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETANDO","man_apont_912:1")       
      RETURN FALSE
   END IF

   IF NOT pol0627_aponta() THEN
      CALL log0030_mensagem(p_msg,'exclamation')
   END IF  
   
   CLOSE WINDOW w_pol0627

   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0627_aponta()
#-----------------------#
   
   IF NOT pol0627_le_parametros() THEN
      RETURN FALSE
   END IF

   DELETE FROM apont_erro_885
    WHERE codempresa = p_cod_empresa
   
   UPDATE apont_trim_885
      SET statusregistro = 'S'
    WHERE codempresa = p_cod_empresa
      AND statusregistro = '0'
      AND tipmovto = 'S'
   
   IF NOT pol0627_importa_apont() THEN
      CALL log085_transacao("ROLLBACK")
   
      INSERT INTO apont_erro_885
       VALUES(p_cod_empresa, p_sequencia, p_man.ordem_producao, p_msg)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INCLUSAO","apont_erro_885:2")
         RETURN FALSE
      END IF
      
   END IF

   LET p_qtd_lt_tran = 0
   
   IF NOT pol0627_transf_lotes() THEN
      INSERT INTO apont_erro_885
       VALUES(p_cod_empresa, p_sequencia, 0, p_msg)
   END IF

   IF p_qtd_lt_tran > 0 THEN
      IF NOT pol0627_importa_apont() THEN
         CALL log085_transacao("ROLLBACK")
   
         INSERT INTO apont_erro_885
          VALUES(p_cod_empresa, p_sequencia, p_man.ordem_producao, p_msg)
    
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","apont_erro_885:2")
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#-----------------------------#
FUNCTION pol0627_prende_man()
#-----------------------------#

   LOCK TABLE man_apont_912 IN EXCLUSIVE MODE
 
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') BLOQUEANDO MAN_APONT_912'
      LET p_sequencia = 0
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#---------------------------------#
FUNCTION pol0627_calc_dat_hor_fim()
#---------------------------------#

   DEFINE p_hi             CHAR(02),
          p_mi             CHAR(02),
          p_si             CHAR(02),
          p_hf             INTEGER,
          p_mf             INTEGER,
          p_sf             INTEGER,
          p_dat_ini        CHAR(10),
          p_hor_ini        CHAR(8),
          p_hor_fim        CHAR(8),
          p_qtd_segundos   INTEGER,
          p_dat_fim        DATE,
          p_dat_hor        CHAR(19)
          
          
   LET p_dat_ini = EXTEND(p_datproducao, YEAR TO DAY)
   LET p_hor_ini = EXTEND(p_datproducao, HOUR TO SECOND)
   LET p_dat_fim = EXTEND(p_datproducao, YEAR TO DAY)
   
   LET p_hi = p_hor_ini[1,2]
   LET p_mi = p_hor_ini[4,5]
   LET p_si = p_hor_ini[7,8]

   LET p_qtd_segundos = (p_hi * 3600)+(p_mi * 60)+(p_si)
   LET p_qtd_segundos = p_qtd_segundos + p_tempoproducao * 60
   LET p_hf = p_qtd_segundos / 3600
   LET p_qtd_segundos = p_qtd_segundos - p_hf * 3600
   LET p_mf = p_qtd_segundos / 60
   LET p_sf = p_qtd_segundos - p_mf * 60


   WHILE p_hf > 23
      LET p_hf = p_hf - 24
      LET p_dat_fim = p_dat_fim + 1
   END WHILE   
      
   LET p_dat_ini = p_dat_fim USING 'yyyy-mm-dd'
   LET p_hi = p_hf USING '&&'
   LET p_mi = p_mf USING '&&'
   LET p_si = p_sf USING '&&'
   LET p_hor_fim = p_hi,':',p_mi,':',p_si
   
   LET p_dat_hor = p_dat_ini,' ',p_hor_fim
   LET p_apont.fim = p_dat_hor

END FUNCTION


#------------------------------#
FUNCTION pol0627_transf_lotes()
#------------------------------#

   LET p_msg = NULL
   
   DECLARE cq_ignora CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           lote_origem,
           lote_destino,
           qtd_transf
      FROM transf_lote_885
     WHERE cod_empresa = p_cod_empresa
       AND statusregistro IN ('0','2')

   FOREACH cq_ignora INTO 
           p_num_seq_apont,
           p_cod_prod,
           p_num_lote_orig,
           p_num_lote_dest,
           p_qtd_movto
     
	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
   
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TRANSFERENCIAS:1'
         LET p_sequencia = 0
         EXIT FOREACH
      END IF

      LET p_man.num_seq_apont = p_num_seq_apont
      
      IF NOT pol0627_deleta_erro() THEN
         RETURN FALSE
      END IF

      SELECT num_sequencia
        INTO p_sequencia
        FROM transf_lote_885
       WHERE cod_empresa  = p_cod_empresa
         AND statusregistro IN ('0','2')
         AND cod_item     = p_cod_prod
         AND lote_origem  = p_num_lote_dest
         AND lote_destino = p_num_lote_orig
         AND qtd_transf   = p_qtd_movto
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TRANSFERENCIAS:2'
            LET p_sequencia = p_num_seq_apont
            EXIT FOREACH
         END IF
      END IF
      
      UPDATE transf_lote_885
         SET statusregistro = 'I'
       WHERE cod_empresa = p_cod_empresa
         AND (num_sequencia = p_num_seq_apont OR
              num_sequencia = p_sequencia)

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TRANSFERENCIAS'
         LET p_sequencia = p_num_seq_apont
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_msg IS NOT NULL THEN
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   
   
   LET p_dat_movto = TODAY
   
   DECLARE cq_tl CURSOR WITH HOLD FOR
    SELECT num_sequencia,
           cod_item,
           lote_origem,
           lote_destino,
           qtd_transf
      FROM transf_lote_885
     WHERE cod_empresa = p_cod_empresa
       AND statusregistro IN ('0','2')

   FOREACH cq_tl INTO 
           p_num_seq_apont,
           p_cod_prod,
           p_num_lote_orig,
           p_num_lote_dest,
           p_qtd_movto

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
   
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO CURSOR CQ-TL'
         LET p_sequencia = 0
         RETURN FALSE
      END IF

      LET p_man.num_seq_apont = p_num_seq_apont
      
      IF NOT pol0627_deleta_erro() THEN
         RETURN FALSE
      END IF

      LET p_statusregistro = '2'
      LET p_criticou = FALSE
      
      IF NOT pol0627_consiste_lote() THEN
         CONTINUE FOREACH
      END IF

      IF NOT p_criticou THEN         
         CALL log085_transacao("BEGIN")
         
         IF pol0801_efetua_transf() THEN
            CALL log085_transacao("COMMIT")
            LET p_statusregistro = '1'
            LET p_qtd_lt_tran = p_qtd_lt_tran +1
         ELSE
            CALL log085_transacao("ROLLBACK")
            IF NOT pol0627_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      LET p_cod_empresa = p_cod_emp_ger
      
      UPDATE transf_lote_885
         SET statusregistro = p_statusregistro
       WHERE cod_empresa   = p_cod_empresa
         AND num_sequencia = p_num_seq_apont

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TRANSF_LOTE_885'
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0627_consiste_lote()
#-------------------------------#
   
   IF p_qtd_movto IS NULL OR p_qtd_movto = 0 THEN
      LET p_msg = 'QUANTIDADE A TRANSFERIR INVALIDA'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
      LET p_qtd_movto = 0
   END IF
         
   LET p_man.ordem_producao = NULL
   LET p_man.item = p_cod_prod
   
   IF NOT pol0627_le_item() THEN
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_cod_local = p_cod_local_estoq
   LET p_ies_situa = 'L'
   LET p_num_lote = p_num_lote_orig
   
   LET p_saldo_lote = NULL
   CALL pol0627_le_lote()
   
   IF p_saldo_lote IS NULL THEN
      LET p_ies_situa = 'E'
      CALL pol0627_le_lote()
   END IF

   IF p_saldo_lote IS NULL OR p_saldo_lote < p_qtd_movto THEN
      LET p_msg = 'LOTE ORIGEM INEXISTENTE OU SEM SALDO '
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0801_efetua_transf()
#------------------------------#

   LET p_man.ordem_producao = NULL
   LET p_cod_tip_movto = 'N'
   LET p_ies_situa_orig = p_ies_situa
   LET p_ies_situa_dest = p_ies_situa
   LET p_cod_local_orig = p_cod_local
   LET p_cod_local_dest = p_cod_local
   LET p_largura_ped     = 0
   LET p_altura_ped      = 0
   LET p_diametro_ped    = 0
   LET p_comprimento_ped = 0

   IF NOT pol0627_entra_no_dest() THEN
      RETURN FALSE
   END IF
   
   LET p_cod_empresa = p_cod_emp_ger
   LET p_inse_trans = TRUE
   LET p_qtd_movto = -p_qtd_movto
   LET p_num_lote = p_num_lote_orig

   IF NOT pol0627_le_oper_transf() THEN
      RETURN FALSE
   END IF
   
   CALL pol0627_le_lote()

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,') LENDO LOTE'
      RETURN FALSE
   END IF

   IF NOT pol0627_atualiza_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_deleta_lote() THEN
      RETURN FALSE
   END IF

   LET p_cod_operacao = p_oper_transf
   LET p_cod_empresa = p_cod_emp_ofic
   LET p_qtd_movto = -p_qtd_movto

   CALL pol0627_le_lote()

   IF STATUS <> 0 OR p_saldo_lote < p_qtd_movto THEN
      LET p_msg = 'LOTE ORIGEM INEXISTENTE OU SEM SALDO '
      RETURN FALSE
   END IF

   IF NOT pol0627_atualiza_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_deleta_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_le_oper_transf()
#--------------------------------#

   SELECT par_txt
     INTO p_cod_operacao
     FROM par_sup_pad
    WHERE cod_empresa = p_cod_emp_ofic
      AND cod_parametro = 'operac_est_sup879'
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') OPERACAO DE TRANSFERENCIA'
      RETURN FALSE
   END IF

   LET p_oper_transf = p_cod_operacao
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_entra_no_dest()
#-------------------------------#

   LET p_num_lote = p_num_lote_dest
   CALL pol0627_le_lote()
   
   IF STATUS = 0 THEN
      LET p_inse_trans = FALSE
      IF NOT pol0627_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0627_insere_lote('T') THEN
         RETURN FALSE
      END IF
      LET p_num_lote = p_num_lote_orig
      CALL pol0627_le_ender()
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO(',STATUS,') LENDO ESTOQUE_LOTE_ENDER:TL'
         RETURN FALSE
      END IF
      LET p_estoque_lote_ender.num_lote = p_num_lote_dest
      LET p_estoque_lote_ender.qtd_saldo = p_qtd_movto
      IF NOT pol0627_insere_ender() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_cod_empresa = p_cod_emp_ofic
   LET p_num_lote = p_num_lote_dest
   CALL pol0627_le_lote()
   
   IF STATUS = 0 THEN
      LET p_inse_trans = FALSE
      IF NOT pol0627_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0627_insere_lote('T') THEN
         RETURN FALSE
      END IF
      LET p_num_lote = p_num_lote_orig
      CALL pol0627_le_ender()
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO(',STATUS,') LENDO ESTOQUE_LOTE_ENDER:TL'
         RETURN FALSE
      END IF
      LET p_estoque_lote_ender.num_lote = p_num_lote_dest
      LET p_estoque_lote_ender.qtd_saldo = p_qtd_movto
      IF NOT pol0627_insere_ender() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0627_importa_apont()
#------------------------------#

   LET p_sequencia = 0
   LET p_qtd_erro_inter = 0   
   LET p_qtd_erro_logix = 0
   
   DELETE FROM apont_erro_885
    WHERE numsequencia = p_sequencia
       OR numsequencia IS NULL
    
   SELECT COUNT(*)
     INTO p_count
     FROM apont_trim_885
    WHERE (codempresa IS NULL OR codempresa <> p_cod_empresa)
      AND tiporegistro  =  'I'
      AND StatusRegistro IN ('0','2')

   IF p_count > 0 THEN
      LET p_msg = 'EXISTEM: ', p_count, ' APONTAMENTOS COM CODIGO DA EMPRESA INVALIDO'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   INITIALIZE p_man TO NULL
   CALL log085_transacao("BEGIN")  
   
   DECLARE cq_elimina CURSOR FOR
    SELECT numsequencia,
           numpedido,
           coditem,
           numordem,
           codmaquina,
           inicio,
           fim,
           num_lote,
           qtdprod,
           tipmovto
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')

   FOREACH cq_elimina INTO
           p_man.num_seq_apont,
           p_man.num_pedido,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_dat_fim,
           p_man.lote,
           p_man.qtd_boas,
           p_man.tip_movto

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF sqlca.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REGISTROS DESNECESSARIOS'
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF      
      
      SELECT statusregistro
        FROM apont_trim_885
       WHERE codempresa   = p_cod_empresa
         AND numsequencia = p_man.num_seq_apont
         AND statusregistro = 'I'
                                   
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      END IF
      
      DISPLAY p_man.ordem_producao TO num_ordem
      
      DECLARE cq_repetidos CURSOR FOR
       SELECT numsequencia
         FROM apont_trim_885
        WHERE codempresa     = p_cod_empresa
          AND numpedido      = p_man.num_pedido
          AND coditem        = p_man.item
          AND numordem       = p_man.ordem_producao
          AND codmaquina     = p_man.cod_recur
          AND inicio         = p_dat_ini
          AND fim            = p_dat_fim
          AND num_lote       = p_man.lote
          AND tipmovto       = p_man.tip_movto
          AND qtdprod        = -p_man.qtd_boas
          AND StatusRegistro IN ('0','2')
          AND tiporegistro   <> '1'
      
      FOREACH cq_repetidos INTO p_num_seq_apont

	  	 # Refresh de tela
	  	 #lds CALL LOG_refresh_display()	
	         
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REGISTROS REPETIDOS'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF         
         
         UPDATE apont_trim_885
            SET statusregistro = 'I'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_man.num_seq_apont
      
         UPDATE apont_trim_885
            SET statusregistro = 'I'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO REGISTROS REPETIDOS'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF         
      
         EXIT FOREACH
         
      END FOREACH
   
   END FOREACH
   
   CALL log085_transacao("COMMIT")  
   
   SELECT MAX(seq_leitura)
     INTO p_seq_leitura
     FROM man_apont_912
    WHERE empresa = p_cod_empresa
   
   IF p_seq_leitura IS NULL THEN
      LET p_seq_leitura = 0
   END IF
   
   DECLARE cq_op CURSOR WITH HOLD FOR
    SELECT numsequencia,
					 codempresa,
					 coditem,
					 numordem,
					 numpedido,
					 codmaquina,
					 codturno,
					 inicio,
					 fim,
					 qtdprod,
					 tipmovto,
					 num_lote,
					 largura,
					 diametro,
					 tubete,
					 comprimento,
					 pesoteorico,
					 consumorefugo,
					 iesdevolucao,
					 datageracao,
           DATE(datageracao)
      FROM apont_trim_885
     WHERE codempresa     = p_cod_empresa
       AND tiporegistro   <> '1'
       AND StatusRegistro IN ('0','2')
       AND numsequencia   IS NOT NULL
     ORDER BY numordem DESC, codmaquina, tipmovto, qtdprod DESC

   FOREACH cq_op INTO 
           p_man.num_seq_apont,
           p_man.empresa,
           p_man.item,
           p_man.ordem_producao,
           p_man.num_pedido,
           p_man.cod_recur,
           p_cod_turno,
           p_dat_ini,
           p_dat_fim,
           p_man.qtd_boas,
           p_man.tip_movto,
           p_man.lote,
           p_man.largura,
           p_man.diametro,
           p_man.altura,
           p_man.comprimento,
           p_man.peso_teorico,
           p_man.consumo_refugo,
           p_man.ies_devolucao,
           p_dat_geracao,
           p_dat_proces           

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
           
      IF sqlca.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_OP'
         LET p_sequencia = 0
         RETURN FALSE
      END IF                                           

      LET p_hor_operac = p_dat_geracao[12,19]
     
      LET p_cod_operac = p_man.cod_recur

      IF p_man.peso_teorico < 0 THEN
         LET p_man.peso_teorico = p_man.peso_teorico * (-1)
      END IF

      IF p_man.consumo_refugo < 0 THEN
         LET p_man.consumo_refugo = p_man.consumo_refugo * (-1)
      END IF


      IF p_man.ies_devolucao IS NULL THEN
         LET p_man.ies_devolucao = 'N'
      ELSE
         IF p_man.ies_devolucao <> 'N' THEN
            LET p_man.ies_devolucao = 'S'
         END IF
      END IF
      
      CALL log085_transacao("BEGIN")  
      LET p_sequencia = p_man.num_seq_apont

      IF NOT pol0627_deleta_erro() THEN
         RETURN FALSE
      END IF
      
      DISPLAY p_man.ordem_producao TO num_ordem
      
     
      LET p_statusRegistro = '2'
      LET p_tipoRegistro = 'I'
      LET p_criticou = FALSE
         
      IF NOT pol0627_consiste_apont() THEN
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT p_criticou THEN
         IF pol0627_insere_apont() THEN
            IF pol0627_processa_apont() THEN
               LET p_statusRegistro = '1'   
               LET p_tipoRegistro = '1'
               LET p_qtd_apontado = p_qtd_apontado + 1
               DISPLAY p_qtd_apontado TO qtd_apontado
            ELSE
               CALL log085_transacao("ROLLBACK") 
               CALL log085_transacao("BEGIN") 
               IF NOT pol0627_insere_erro() THEN
                  RETURN FALSE
               END IF
            END IF
         ELSE
            CALL log085_transacao("ROLLBACK") 
            CALL log085_transacao("BEGIN") 
            IF NOT pol0627_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      IF NOT pol0627_grava_apont_trim() THEN
         RETURN FALSE
      END IF

      CALL log085_transacao("COMMIT") 
   
      INITIALIZE p_man TO NULL
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0627_deleta_erro()
#----------------------------#

   DELETE FROM apont_erro_885
    WHERE codempresa     = p_cod_empresa
      AND numsequencia   = p_man.num_seq_apont

   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO APONT_ERRO_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_consiste_apont()
#-------------------------------#

   DEFINE p_status_reg CHAR(01)

   IF p_man.tip_movto = 'F' THEN
      IF p_man.ies_devolucao = 'S' THEN
         LET p_msg = 'APONTAMENTO NORMAL DEFINIDO COM DEVOLUCAO'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   SELECT num_seq_apont
     FROM man_apont_hist_912
    WHERE empresa       = p_cod_empresa
      AND num_seq_apont = p_man.num_seq_apont

   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
         LET p_msg = 'UM REGISTRO JA FOI APONTADO COM ESSA SEQUENCIA'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         ELSE
            RETURN TRUE
         END IF
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO MAN_APONT_HIST_912'
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_boas < 0 THEN
      INITIALIZE p_num_sequencia TO NULL
      DECLARE cq_cec_est CURSOR FOR
      SELECT numsequencia
        FROM apont_trim_885
       WHERE codempresa = p_man.empresa
         AND numpedido  = p_man.num_pedido
         AND coditem    = p_man.item
         AND numordem   = p_man.ordem_producao
         AND codmaquina = p_man.cod_recur
         AND inicio     = p_dat_ini
         AND fim        = p_dat_fim
         AND qtdprod    = -p_man.qtd_boas
         AND tipmovto   = p_man.tip_movto
         AND num_lote   = p_man.lote
         AND statusregistro = '1'
         AND numsequencia IN 
             (SELECT DISTINCT num_seq_apont
                FROM apont_trans_885
               WHERE cod_empresa   = p_man.empresa
                 #AND cod_item      = p_man.item
                 AND cod_tip_apon  = 'A'
                 AND cod_tip_movto = 'N')

      FOREACH cq_cec_est INTO p_num_sequencia

		 # Refresh de tela
	  	 #lds CALL LOG_refresh_display()	
	      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTORNO'
            IF NOT pol0627_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      
         EXIT FOREACH
      END FOREACH
            
      IF p_num_sequencia IS NULL THEN
         LET p_msg = 'ESTORNO DE APONTAMENTO NAO ENVIADO AO LOGIX'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         SELECT consumorefugo
           INTO p_man.consumo_refugo
           FROM apont_trim_885
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_sequencia
         
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_TRIM_885'
            IF NOT pol0627_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
            
      END IF
   END IF
   
   IF p_man.cod_recur IS NULL OR p_man.cod_recur = 0 THEN

       LET p_msg = 'O CODIGO DA MAQUINA ENVIADO NAO E VALIDO '
       IF NOT pol0627_insere_erro() THEN
          RETURN FALSE
       END IF

   ELSE

			 LET p_cod_recur = p_man.cod_recur
			
			 SELECT cod_recur,
			        cod_compon,
			        cod_operac,
			        ies_onduladeira,
			        cod_arranjo,
			        cod_cent_cust,
			        cod_cent_trab
			   INTO p_man.cod_recur,
			        p_man.eqpto,
			        p_man.operacao,
			        p_ies_onduladeira,
			        p_cod_arranjo,
			        p_cod_cent_cust,
			        p_cod_cent_trab
			   FROM de_para_maq_885
			  WHERE cod_empresa  = p_cod_empresa
			    AND cod_maq_trim = p_cod_recur
			    
			 IF STATUS = 100 THEN
			    LET p_msg = p_cod_recur CLIPPED, ': MAQUINA NAO CADASTRADA NO DE-PARA-MAQUINA ' 
			    IF NOT pol0627_insere_erro() THEN
			       RETURN FALSE
			    END IF
			 ELSE
			    IF STATUS <> 0 THEN
			       LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB DE_PARA_MAQ'
			       RETURN FALSE
			    ELSE
			       IF p_man.tip_movto = 'F' THEN
    		        IF p_ies_onduladeira = 'S' THEN
			             LET p_statusRegistro = 'I'
			             LET p_tipoRegistro   = 'I'
			             LET p_criticou = TRUE
			             RETURN TRUE
			          END IF
			       END IF
			    END IF
			 END IF

   END IF   

   SELECT num_docum,
          cod_item,
          num_lote,
          ies_situa,
          dat_abert
     INTO p_num_docum,
          p_cod_item,
          p_num_lote,
          p_ies_situa,
          p_dat_abert
	   FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS = 100 THEN
      LET p_msg = 'A ORDEM DE PRODUCAO ENVIADA NAO EXISTE '
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:NUM.DOCUM'
         RETURN FALSE
      ELSE
         CALL pol0627_pega_pedido()
         LET p_man.num_seq_pedido = p_num_seq_pedido
      END IF
   END IF
   
   IF p_ies_situa <> '4' THEN
      IF p_ies_situa = '5' THEN
         LET p_msg = 'A OF ESTA ENCERRADA'
      ELSE
         IF p_ies_situa = '9' THEN
            LET p_msg = 'A OF ESTA CANCELADA'
         ELSE
            LET p_msg = 'A OF NAO ESTA LIBERADA - STATUS ATUAL:', p_ies_situa
         END IF
      END IF
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.num_pedido <> p_num_pedido THEN
      LET p_msg = 'O PEDIDO ENVIADO NAO CORRESPONDE AO PEDIDO DA OF'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   IF p_man.lote IS NULL OR p_man.lote = ' ' THEN
      LET p_msg = 'O LOTE ENVIADO ESTA NULO '
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   IF p_man.lote <> p_num_lote THEN
      LET p_msg = 'LOTE ENVIADO ESTA DIFERENTE DO LOTE PREVISTO P/ A OF'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0627_consiste_turno() THEN
      RETURN FALSE
   END IF
   
   IF p_man.tip_movto MATCHES "[FRSP]" THEN
   ELSE
      LET p_msg = 'O TIPO DE MOVIMENTO ENVIADO NAO E VALIDO'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF p_man.tip_movto MATCHES "[R]" THEN
      IF p_man.peso_teorico IS NULL OR p_man.peso_teorico = 0 THEN
         LET p_msg = 'ENVIO DE APONTAMENTO DE REFUGO SEM PESO TEORICO'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF 
   
   IF p_man.qtd_boas IS NULL OR p_man.qtd_boas = 0 THEN
		  LET p_msg = 'QUANTIDADE A APONTAR ESTA NULA OU COM ZERO'
		  IF NOT pol0627_insere_erro() THEN
		     RETURN FALSE
		  END IF
	 END IF

   IF p_dat_ini IS NULL THEN
      LET p_msg = 'DATA INICIAL DA PRODUCAO ESTA NULA'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fim IS NULL THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO NULA'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_ini IS NOT NULL AND p_dat_fim IS NOT NULL THEN
      CALL pol0627_consiste_datas()
   END IF

   IF p_ies_onduladeira = 'S' AND p_man.ies_devolucao = 'S' THEN
      LET p_msg = 'ENVIO DE ONDULADEIRA P/ APONTAMENTO DE DEVOLUCAO'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF    

   LET p_trocou_op = FALSE
   LET p_ies_chapa = FALSE
   
   IF p_ies_onduladeira = 'S' AND p_man.ies_devolucao = 'N' THEN
      IF NOT pol0627_troca_op('A') THEN
         RETURN FALSE
      END IF
   END IF   

   IF NOT p_trocou_op THEN
      IF p_man.item <> p_cod_item THEN
         LET p_msg = 'O ITEM ENVIADO DIFERE DO ITEM DA OF'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF   

   IF NOT pol627_checa_dimensional() THEN
      RETURN FALSE
   END IF

   IF NOT p_criticou THEN   
      SELECT num_seq_operac
		    FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.ordem_producao
	       AND cod_operac     = p_man.operacao

      IF STATUS = 100 THEN
         IF NOT pol0627_insere_operacao() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO ORD_OPER'
            RETURN FALSE
         END IF
      END IF
      IF NOT pol0627_consiste_qtds() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT ies_forca_apont
     INTO p_ies_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.item

   IF STATUS <> 0 THEN
		  LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM_MAN'
		  RETURN FALSE
   END IF

   IF NOT p_criticou THEN
      IF NOT pol0627_consiste_qtd_apont('T') THEN
         RETURN FALSE
      END IF
   END IF

	 IF p_ies_chapa OR p_man.qtd_boas < 0 OR p_criticou THEN
	 ELSE
	    IF p_man.tip_movto MATCHES '[RS]' OR p_ies_oper_final = 'S' THEN
         IF p_man.ies_devolucao = 'N' THEN
            IF NOT pol0627_material('I') THEN 
	             RETURN FALSE
	          END IF
	       END IF
	    END IF
	 END IF

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.item
      
   IF STATUS = 100 THEN
      LET p_msg = 'ITEM ENVIADO NAO CADASTRADO NO LOGIX. ', p_man.item
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM'
         RETURN FALSE
      END IF
   END IF

   IF p_man.ies_devolucao = 'N' THEN
      IF (p_man.qtd_boas < 0 AND p_ies_oper_final = 'S') OR 
         (p_man.qtd_boas < 0 AND p_man.tip_movto MATCHES '[R]') THEN

         IF p_man.tip_movto = 'F' THEN
            IF NOT pega_dimen() THEN
               RETURN FALSE
            END IF
            LET p_cod_local_orig = p_cod_local_estoq
            LET p_cod_prod       = p_man.item
            LET p_qtd_baixar     = p_man.qtd_boas * (-1)
            LET p_num_lote       = p_man.lote
         ELSE
            LET p_largura_ped     = 0
            LET p_altura_ped      = 0
            LET p_diametro_ped    = 0
            LET p_comprimento_ped = 0
            LET p_cod_prod        = p_cod_item_retrab
            LET p_cod_local_orig  = p_cod_local_retrab
            LET p_qtd_baixar      = p_man.peso_teorico
            LET p_num_lote        = NULL
         END IF
        
         LET p_ies_flor_deloto = FALSE
         IF NOT pol0627_cheka_estoque() THEN
            RETURN FALSE
         END IF
      
         IF p_sem_estoque THEN
            LET p_msg = 'IT:',p_cod_prod
            LET p_msg = p_msg CLIPPED, ' - S/ESTOQ LIB P/ REALIZACAO DO ESTORNO'
            IF NOT pol0627_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF      

      END IF
   END IF

   LET p_num_lote = p_man.lote

   IF p_man.ies_devolucao = 'S' AND p_man.qtd_boas > 0 THEN
         IF NOT pega_dimen() THEN
            RETURN FALSE
         END IF
         LET p_cod_local_orig = p_cod_local_estoq
         LET p_cod_prod       = p_man.item
         LET p_qtd_baixar     = p_man.qtd_boas
      
      LET p_ies_flor_deloto = FALSE
      
      IF NOT pol0627_cheka_estoque() THEN
         RETURN FALSE
      END IF
      
      IF p_sem_estoque THEN
         LET p_msg = 'IT:',p_cod_prod
         LET p_msg = p_msg CLIPPED, ' - S/ESTOQ LIB P/ ENVIAR P/ REFUGO/SUCATA'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF      
   
   END IF

   IF NOT p_criticou AND p_man.ies_devolucao = 'N' THEN
      SELECT COUNT(ies_oper_final)
        INTO p_count
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.ordem_producao
	       AND ies_oper_final = 'S'
      
      IF p_count = 0 THEN
         LET p_msg = 'NO ROTEIRO DA OF NAO CONSTA A OPERACAO FINAL'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
       
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_encerra_ordem()
#--------------------------------#

   DEFINE p_num_of LIKE ordens.num_ordem
   
   UPDATE ordens 
      SET ies_situa = '5'
	  WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
	    AND num_docum   = p_num_docum

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A OF'
      RETURN FALSE
   END IF

   DECLARE cq_enc_nec CURSOR FOR
    SELECT DISTINCT
           num_ordem
      FROM ordens
     WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
	     AND num_docum   = p_num_docum
   
   FOREACH cq_enc_nec INTO p_num_of

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO A OF'
         RETURN FALSE
      END IF
      
      UPDATE necessidades
         SET ies_situa = '5'
    	 WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
	       AND num_ordem   = p_num_of   

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO AS NECESSIDADES DA OF'
         RETURN FALSE
      END IF
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_consiste_turno()
#--------------------------------#

   DEFINE p_minutos    SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04)
   
   LET p_hora = EXTEND(p_dat_ini, HOUR TO MINUTE)
   LET p_minutos = (p_hora[1,2] * 60) + p_hora[4,5]

   IF STATUS <> 0 THEN
      LET p_msg = 'A HORA INICIO NAO E VALIDA'
      CALL pol0627_insere_erro() RETURNING p_status
      RETURN FALSE
   END IF

   LET p_msg = 'HORA DE INICIO DO APONTAMENTO FORA DOS TURNOS LOGIX'
   
   DECLARE cq_turno CURSOR FOR
    SELECT cod_turno,
           hor_ini_normal,
           hor_fim_normal
     FROM turno
    WHERE cod_empresa = p_cod_empresa

   FOREACH cq_turno INTO 
           p_man.turno,
           p_hor_ini,
           p_hor_fim

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
           
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TURNO DO LOGIX'
         RETURN FALSE
      END IF
      
      LET p_min_ini = (p_hor_ini[1,2] * 60) + p_hor_ini[3,4]   
      LET p_min_fim = (p_hor_fim[1,2] * 60) + p_hor_fim[3,4]   
      
      IF p_min_fim < p_min_ini THEN
         LET p_min_fim = p_min_fim + 1440
         IF p_minutos < p_min_ini THEN
            LET p_minutos = p_minutos + 1440
         END IF
      END IF
      
      IF p_minutos >= p_min_ini AND p_minutos < p_min_fim THEN
         LET p_msg = NULL
         EXIT FOREACH
      END IF

   END FOREACH

   IF p_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_consiste_datas()
#--------------------------------#
   
   LET p_man.dat_ini_producao = EXTEND(p_dat_ini, YEAR TO DAY)
   LET p_man.dat_fim_producao = EXTEND(p_dat_fim, YEAR TO DAY)
   LET p_man.hor_inicial = EXTEND(p_dat_ini, HOUR TO SECOND)
   LET p_man.hor_fim     = EXTEND(p_dat_fim, HOUR TO SECOND)
   
   IF p_man.dat_ini_producao > p_man.dat_fim_producao THEN
      LET p_msg = 'DATA INICIAL DA PRODUCAO MAIOR QUE DATA FINAL '
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.dat_fim_producao > TODAY THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO MAIOR QUE DATA ATUAL'
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_man THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_man.dat_fim_producao < p_dat_fecha_ult_sup THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF NOT p_criticou THEN
	   IF p_man.hor_inicial > p_man.hor_fim THEN
	      LET p_hor_prod = '24:00:00' - (p_man.hor_inicial - p_man.hor_fim)
	   ELSE
	      LET p_hor_prod = (p_man.hor_fim - p_man.hor_inicial)
	   END IF
	   
	   LET p_time     = p_hor_prod
	   LET p_hor_prod = p_time
	   
	   LET p_qtd_segundo = (p_hor_prod[1,2] * 3600)+(p_hor_prod[4,5] * 60)+(p_hor_prod[7,8])
	
	   LET p_man.qtd_hor = p_qtd_segundo / 3600
	   LET p_flag = '2'
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol0627_insere_operacao()
#---------------------------------#

   DEFINE p_num_seq LIKE ord_oper.num_seq_operac
   
   SELECT MAX(num_seq_operac)
		 INTO p_num_seq
		 FROM ord_oper
    WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO MAXIMA SEQUENCIA DA ORD_OPER'
      RETURN FALSE
   END IF

   IF p_num_seq IS NULL THEN
      LET p_msg = 'A OF ESTA SEM O ROTEIRO DE PRODUCAO '
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   SELECT *
		 INTO p_ord_oper.*
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.ordem_producao
      AND num_seq_operac = p_num_seq
      AND cod_item       = p_man.item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO INFORMACOES DA TAB ORD_OPER'
      RETURN FALSE
   END IF

   LET p_ord_oper.cod_empresa     = p_cod_empresa
   LET p_ord_oper.num_ordem       = p_man.ordem_producao
   LET p_ord_oper.cod_item        = p_man.item
   LET p_ord_oper.cod_operac      = p_man.operacao
   LET p_ord_oper.num_seq_operac  = p_num_seq + 1
   LET p_ord_oper.cod_cent_trab   = p_cod_cent_trab
   LET p_ord_oper.cod_arranjo     = p_cod_arranjo
   LET p_ord_oper.cod_cent_cust   = p_cod_cent_cust
   LET p_ord_oper.qtd_boas        = 0
   LET p_ord_oper.qtd_refugo      = 0
   LET p_ord_oper.qtd_sucata      = 0
   LET p_ord_oper.ies_apontamento = 'S'
   LET p_ord_oper.ies_impressao   = 'N'
   LET p_ord_oper.ies_oper_final  = 'N'
   LET p_ord_oper.pct_refug       = 0
   
   INSERT INTO ord_oper
    VALUES(p_ord_oper.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO OPERACOES NA TAB ORD_OPER'
      RETURN FALSE
   END IF

   LET p_ord_oper.cod_empresa     = p_cod_emp_ofic

   INSERT INTO ord_oper
    VALUES(p_ord_oper.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO OPERACOES NA TAB ORD_OPER'
      RETURN FALSE
   END IF
   
   LET p_man.sequencia_operacao = p_ord_oper.num_seq_operac
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_consiste_qtds()
#-------------------------------#

   SELECT num_seq_operac,
          cod_cent_trab,
		      cod_arranjo,
		      qtd_boas,
		      qtd_refugo,
		      qtd_sucata 
		 INTO p_man.sequencia_operacao,
		      p_man.centro_trabalho,
		      p_man.arranjo,
		      p_qtd_boas,
		      p_qtd_refug,
		      p_qtd_sucata 
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.ordem_producao
	    AND cod_operac     = p_man.operacao
		
   IF STATUS = 100 THEN
		  LET p_msg = 'OPERACAO NAO PREVISTA PARA A OF'
		  IF NOT pol0627_insere_erro() THEN
		     RETURN FALSE
		  END IF
   ELSE
	    IF STATUS <> 0 THEN
		     LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORD_OPER'
		     RETURN FALSE
      END IF
   END IF                                           

   IF p_man.qtd_boas < 0 AND p_man.ies_devolucao = 'N' THEN
      LET p_qtd_a_apontar = p_man.qtd_boas * (-1)
      IF p_man.tip_movto = 'F' AND p_qtd_a_apontar > p_qtd_boas OR
         p_man.tip_movto = 'R' AND p_qtd_a_apontar > p_qtd_refug OR
         p_man.tip_movto = 'S' AND p_qtd_a_apontar > p_qtd_sucata THEN
         LET p_msg = 'QTD A ESTORNOAR MAIOR QUE A QTD JA APONTADAS'
         IF NOT pol0627_insere_erro() THEN
	          RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#------------------------------------#
FUNCTION pol0627_troca_op(p_parametro)
#------------------------------------#

   DEFINE p_parametro CHAR(01),
          p_qtd_chapa CHAR(02),
          p_qtd_op    LIKE ordens.qtd_planej
   
   LET p_cod_item = p_man.item
   LET p_cod_item_pai = p_man.item
   LET p_trocou_op = FALSE
   LET p_count = 0
   
   IF NOT pol0627_le_item_vdp() THEN
      RETURN FALSE
   END IF
   
   IF p_ies_chapa THEN 
      IF p_parametro = 'E' THEN
         IF NOT pol0627_le_item_chapa() THEN
            RETURN FALSE
         END IF
      END IF
      RETURN TRUE
   ELSE
      IF p_parametro = 'E' THEN
         IF NOT pol0627_le_ft_item() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_parametro = 'A' THEN
      IF NOT pol0627_le_ft_item() THEN
         RETURN FALSE
      END IF
   
      IF NOT p_tem_ficha THEN
         LET p_msg = 'O ITEM:', p_man.item CLIPPED, ' NAO POSSUI FICHA TECNICA'
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF
   END IF   

   SELECT num_docum
     INTO p_num_docum
	   FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:NUM.DOCUM'
      RETURN FALSE
   END IF
	 
	 LET p_ies_chapa = FALSE
	 LET p_tem_chapa = FALSE
	 
   DECLARE cq_op_chapa CURSOR FOR
    SELECT num_ordem,
           cod_item,
           qtd_planej
      FROM ordens
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_man.item
       AND num_docum    = p_num_docum
       AND ies_situa    IN ('4','5')


   FOREACH cq_op_chapa INTO p_num_op, p_cod_item, p_qtd_ordem

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
   
       IF STATUS <> 0 THEN
          LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:OP DA CHAPA'
          RETURN FALSE
      END IF
       
      IF NOT pol0627_le_item_vdp() THEN
         RETURN FALSE
      END IF
   
      IF p_ies_chapa THEN 
         LET p_count = p_count + 1
         LET p_man.ordem_producao = p_num_op
         LET p_man.item = p_cod_item
         LET p_qtd_op = p_qtd_ordem
         LET p_trocou_op = TRUE
         LET p_tem_chapa = TRUE
     END IF
      
   END FOREACH

   IF p_count = 1 THEN
      LET p_ies_chapa = TRUE
      LET p_num_op    = p_man.ordem_producao
      LET p_cod_item  = p_man.item
      LET p_qtd_ordem = p_qtd_op 
   ELSE
      IF p_count = 0 THEN
         LET p_msg = 'A OF DA CHAPA DO ITEM ', p_man.item CLIPPED, ' NAO EXISTE'
      ELSE
         LET p_qtd_chapa = p_count
         LET p_msg = 'EXISTEM ',p_qtd_chapa, ' CHAPAS NA FABRICACAO DO ITEM ',p_man.item CLIPPED
      END IF 
      
      IF p_count > 0 THEN
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF   

   RETURN TRUE
   
END FUNCTION

#--------------------------------------------#
FUNCTION pol0627_le_item_ctr_grade(p_cod_item)
#--------------------------------------------#

   DEFINE p_cod_item   LIKE item.cod_item,
          p_achou      SMALLINT

   LET p_achou = FALSE
   
   DECLARE cq_ctr CURSOR FOR
    SELECT ies_largura,
           ies_altura,
           ies_diametro,
           ies_comprimento,
           reservado_2,
           ies_dat_producao
      FROM item_ctr_grade
     WHERE cod_empresa   = p_cod_emp_ofic
       AND cod_item      = p_cod_item

   FOREACH cq_ctr INTO
           p_ies_largura,
           p_ies_altura,
           p_ies_diametro,
           p_ies_comprimento,
           p_ies_serie,
           p_ies_dat_producao

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
   
      IF STATUS <> 0 THEN
        LET p_msg = p_cod_item CLIPPED,'ERRO:(',STATUS, ') LENDO ITEM_CTR_GRADE'  
        RETURN FALSE
      END IF

      LET p_achou = TRUE
      EXIT FOREACH

   END FOREACH
   
   IF NOT p_achou THEN
      LET p_ies_largura      = 'N'
      LET p_ies_altura       = 'N'
      LET p_ies_diametro     = 'N'
      LET p_ies_comprimento  = 'N'
      LET p_ies_dat_producao = 'N'
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol627_checa_dimensional()
#----------------------------------#

   LET p_man.largura = 0
   LET p_man.altura  = 0
   LET p_man.diametro = 0
   LET p_man.comprimento = 0
   
   IF NOT pol0627_le_item_ctr_grade(p_man.item) THEN
      RETURN FALSE
   END IF

   IF p_ies_largura     = 'N' AND
      p_ies_altura      = 'N' AND
      p_ies_diametro    = 'N' AND
      p_ies_comprimento = 'N' THEN
      RETURN TRUE
   END IF

   IF p_trocou_op THEN
      SELECT largura_chapa,
             compri_chapa
        INTO p_largura_ped,
             p_comprimento_ped
        FROM ft_item_885
       WHERE cod_empresa = p_cod_emp_ger
         AND cod_item    = p_cod_item_pai
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO A FT_ITEM_885'  
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0627_le_item_chapa() THEN
         RETURN FALSE
      END IF
   END IF
      
   LET p_man.largura     = p_largura_ped
   LET p_man.comprimento = p_comprimento_ped
 
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_le_item_chapa()
#-------------------------------#

   SELECT largura,
          comprimento
     INTO p_largura_ped,
          p_comprimento_ped
     FROM item_chapa_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_man.num_pedido
      AND num_sequencia = p_man.num_seq_pedido
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO A ITEM_CHAPA_885'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_le_item_vdp()
#-----------------------------#

   LET p_ies_chapa = FALSE

	  SELECT cod_grupo_item
	    INTO p_cod_grupo_item
	    FROM item_vdp
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM_VDP ', p_cod_item
      RETURN FALSE
   END IF

   SELECT cod_empresa
     FROM grupo_produto_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_grupo   = p_cod_grupo_item
      AND cod_tipo    = '2'
	  
	 IF STATUS = 0 THEN
	    LET p_ies_chapa = TRUE
	    LET p_cod_chapa = p_cod_item
	    LET p_ies_onduladeira = 'S'
   ELSE	 
      IF STATUS <> 100 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO GRUPO_PRODUTO_885'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0627_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO apont_erro_885
      VALUES (p_cod_empresa,
              p_man.num_seq_apont,
              p_man.ordem_producao,
              p_msg)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA APONT_ERRO_885:3'
      RETURN FALSE
   END IF                                           

   LET p_qtd_erro_inter = p_qtd_erro_inter + 1
   DISPLAY p_qtd_erro_inter TO qtd_erro_inter
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_insere_apont()
#-----------------------------#

   IF p_man.qtd_refugo IS NULL THEN
      LET p_man.qtd_refugo = 0
   END IF

   LET p_man.dat_atualiz  = CURRENT YEAR TO SECOND
   LET p_man.nom_prog     = 'pol0627'
   LET p_man.nom_usuario  = p_user
   LET p_man.num_versao   = 1
   LET p_man.versao_atual = 'S'
   LET p_man.cod_status   = '0'

   LET p_mana.* = p_man.*

   IF (p_trocou_op = FALSE AND p_man.consumo_refugo IS NULL AND
       (p_ies_oper_final = 'S' OR (p_ies_onduladeira = 'N' AND 
                                   p_man.tip_movto MATCHES '[RS]'))) THEN

      IF p_man.ies_devolucao = 'N' THEN
         IF p_man.qtd_boas > 0 THEN
            IF NOT pol0627_insere_ond() THEN
               RETURN FALSE
            END IF
            IF NOT pol0627_insere_man() THEN
               RETURN FALSE
            END IF
         ELSE
            IF NOT pol0627_insere_man() THEN
               RETURN FALSE
            END IF
            IF NOT pol0627_insere_ond() THEN
               RETURN FALSE
            END IF
         END IF
      ELSE
         IF NOT pol0627_insere_man() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      IF NOT pol0627_insere_man() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0627_insere_man()
#----------------------------#

   LET p_seq_leitura = p_seq_leitura + 1
   LET p_mana.seq_leitura = p_seq_leitura
   
   INSERT INTO man_apont_912
    VALUES(p_mana.*)
     
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA MAN_APONT_912'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
#---------------------------#
FUNCTION pol0627_insere_ond()
#---------------------------#

   DEFINE p_qtd_horas LIKE ord_oper.qtd_horas

   DEFINE p_qtd_segundo INTEGER,
          p_seg_prod    INTEGER,
          p_seg_ini     INTEGER,
          p_qtd         INTEGER,
          p_hh          CHAR(02),
          p_mm          CHAR(02),
          p_ss          CHAR(02),
          p_hor_txt     CHAR(08)


   IF NOT pol0627_troca_op('E') THEN
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      RETURN TRUE
   ELSE
      IF p_count > 1 THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_man.largura     = p_largura_ped
   LET p_man.comprimento = p_comprimento_ped

   SELECT qtd_necessaria
     INTO p_qtd_necessaria
     FROM ord_compon
    WHERE cod_empresa     = p_cod_empresa
      AND num_ordem       = p_mana.ordem_producao
      AND cod_item_compon = p_man.item

   IF STATUS <> 0 OR p_qtd_necessaria IS NULL OR p_qtd_necessaria <= 0 THEN 
      LET p_msg = 'ITEM:',p_mana.item CLIPPED, ' C/ESTRUTURA INVALIDA NA TAB ORD_COMPON'
      LET p_man.ordem_producao = p_mana.ordem_producao
      RETURN FALSE
   END IF
   
   LET p_man.qtd_boas = p_man.qtd_boas * p_qtd_necessaria

   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_transf = p_man.qtd_boas
   ELSE
      LET p_qtd_transf = -p_man.qtd_boas
   END IF
   
   LET p_qtd_aux = p_qtd_transf
   LET p_qtd_integer = p_qtd_aux
      
   IF p_qtd_integer < p_qtd_aux THEN
      LET p_qtd_integer = p_qtd_integer + 1
   END IF
      
   IF p_man.qtd_boas > 0 THEN
      LET p_man.qtd_boas = p_qtd_integer
   ELSE
      LET p_man.qtd_boas = -p_qtd_integer
   END IF
   
   LET p_man.sequencia_operacao = 1
   
   SELECT qtd_horas,
          cod_operac,
          cod_cent_trab,
          cod_arranjo
     INTO p_qtd_horas,
          p_man.operacao,
          p_man.centro_trabalho,
          p_man.arranjo
     FROM ord_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.ordem_producao
      AND cod_item    = p_man.item
      AND num_seq_operac = p_man.sequencia_operacao 
      
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB. ORD_OPER'
      RETURN FALSE
   END IF
   
   SELECT cod_recur,
		      cod_compon
		 INTO p_man.cod_recur,
			    p_man.eqpto
     FROM de_para_maq_885
	  WHERE cod_empresa  = p_cod_empresa
	    AND cod_maq_trim = p_man.operacao

   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB DE_PARA_MAQ_885'
      RETURN FALSE
   END IF
   
   LET p_qtd_horas = p_qtd_horas * 3600 #transforma em segundos

   LET p_man.dat_fim_producao = p_man.dat_ini_producao
   LET p_man.hor_fim          = p_man.hor_inicial
   
   LET p_hor_txt  = p_man.hor_inicial
   LET p_dat_ini  = p_man.dat_ini_producao
   
   LET p_qtd_segundo = (p_hor_txt[1,2] * 3600)+(p_hor_txt[4,5] * 60)+(p_hor_txt[7,8])
   
   IF p_man.qtd_boas > 0 THEN
      LET p_seg_prod = p_man.qtd_boas * p_qtd_horas
   ELSE
      LET p_seg_prod = - p_man.qtd_boas * p_qtd_horas
   END IF
   
   IF p_seg_prod <= 0 THEN
      LET p_seg_prod = 1
   END IF
   
   IF p_seg_prod <= p_qtd_segundo THEN
      LET p_seg_ini = p_qtd_segundo - p_seg_prod
   ELSE
      LET p_seg_ini = p_seg_prod - p_qtd_segundo 
      LET p_seg_ini = (24 * 3600) - p_seg_ini
      LET p_dat_prod = p_man.dat_ini_producao
      LET p_dat_prod = p_dat_prod - 1
      LET p_man.dat_ini_producao = p_dat_prod
   END IF
   
   IF p_seg_ini < 3600 THEN
      LET p_hh = '00'
   ELSE
      LET p_qtd = p_seg_ini / 3600
      LET p_hh = p_qtd USING '&&'
      LET p_seg_ini = p_seg_ini - p_qtd * 3600
   END IF

   IF p_seg_ini < 60 THEN
      LET p_mm = '00'
   ELSE
      LET p_qtd = p_seg_ini / 60
      LET p_mm = p_qtd USING '&&'
      LET p_seg_ini = p_seg_ini - p_qtd * 60
   END IF
   
   LET p_ss = p_seg_ini USING '&&'
   LET p_hor_txt = p_hh,':',p_mm,':',p_ss
   LET p_man.hor_inicial = p_hor_txt

   LET p_hor_prod = (p_man.hor_fim - p_man.hor_inicial)
	   
	 LET p_time     = p_hor_prod
	 LET p_hor_prod = p_time
	   
	 LET p_qtd_segundo = (p_hor_prod[1,2] * 3600)+(p_hor_prod[4,5] * 60)+(p_hor_prod[7,8])
	
	 LET p_man.qtd_hor = p_qtd_segundo / 3600

   LET p_man.num_seq_apont = p_man.num_seq_apont * (-1)

   LET p_seq_leitura = p_seq_leitura + 1
   LET p_man.seq_leitura = p_seq_leitura
   LET p_man.tip_movto = 'F'
   
   INSERT INTO man_apont_912
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA MAN_APONT_912:OND'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0627_grava_apont_trim()
#---------------------------------#

   UPDATE apont_trim_885
      SET StatusRegistro = p_statusRegistro,
          tiporegistro   = p_tipoRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_sequencia
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A APONT_TRIM_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---Fim da Importa��o dos Apontamentos---#

#---Iniciao da Leitura dos Parametros---#

#------------------------------#
FUNCTION pol0627_le_parametros()
#------------------------------#

   SELECT parametros
     INTO p_parametros
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_PCP'
      RETURN FALSE
   END IF
   
   LET p_grava_oplote = p_parametros[116,116]

   IF p_parametros[79,79] MATCHES "[SV]" THEN
      SELECT empresa,
             filial
        INTO p_empresa,
             p_filial
        FROM mcg_filial
       WHERE empresa_logix = p_cod_empresa
      
      IF SQLCA.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO MCG_FILIAL'
         RETURN FALSE
      END IF
   END IF
   
   SELECT parametros[50,50]
     INTO p_rastreia
     FROM par_logix
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_LOGIX'
      RETURN FALSE
   END IF

   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_emp_ofic

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_ESTOQUE'
      RETURN FALSE
   END IF

   SELECT ies_mao_obra
     INTO p_ies_mao_obra
     FROM par_con
    WHERE cod_empresa = p_cod_empresa    
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_CON'
      RETURN FALSE
   END IF

   SELECT area_livre
     INTO p_area_livre
     FROM par_cst
    WHERE cod_empresa = p_cod_empresa    
    
   IF STATUS = 100 THEN
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_CST'
         RETURN FALSE
      END IF
   END IF
   
   LET p_ies_par_cst = p_area_livre[26,26]

   INITIALIZE p_empresa, p_filial TO NULL
   
   RETURN TRUE

END FUNCTION 

#---Fim da Leitura dos Parametros---#

#--------------------------------#          
FUNCTION pol0627_processa_apont()
#--------------------------------#          

   INITIALIZE p_man, p_num_conta TO NULL
   
   DECLARE cq_apont CURSOR WITH HOLD FOR
    SELECT *
      FROM man_apont_912
     WHERE empresa       = p_cod_empresa
       AND versao_atual  = 'S'
     ORDER BY seq_leitura

   FOREACH cq_apont INTO p_man.*

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_APONT'
         LET p_sequencia = 0
         RETURN FALSE
      END IF                                           

      DELETE FROM consumo_tmp_885
      
      DISPLAY p_man.ordem_producao TO num_ordem
   
      LET p_retorno = FALSE

      LET p_num_lote = p_man.lote
      LET p_dat_movto = p_man.dat_fim_producao

      
      LET p_criticou = FALSE
      LET p_cod_status = 'A'

      IF pol0627_consiste_dados() THEN
         LET p_qtd_trim = p_man.qtd_boas
         LET p_item_ant = p_man.item
         IF pol0627_aponta_op() THEN
            LET p_retorno = TRUE
         END IF
      END IF

      IF NOT pol0627_grava_man() THEN
         LET p_retorno = FALSE
      END IF

      IF p_retorno THEN   
         INITIALIZE p_man TO NULL   
      ELSE
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN(p_retorno)

END FUNCTION

#-------------------------------#
 FUNCTION pol0627_insere_critic()
#-------------------------------#

   LET p_criticou = TRUE
   LET p_cod_status = 'C'   
   LET p_dat_hor = CURRENT YEAR TO SECOND
   
   INSERT INTO apont_erro_912
      VALUES (p_cod_empresa,
              p_man.num_seq_apont,
              p_man.ordem_producao,
              p_msg,
              p_dat_hor,
              'POL0627')

   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF                                           

   LET p_qtd_erro_logix = p_qtd_erro_logix + 1
   DISPLAY p_qtd_erro_logix TO qtd_erro_logix

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_consiste_dados()
#--------------------------------#

   INITIALIZE p_cod_grade_1,
              p_cod_grade_2,
              p_cod_grade_3,
              p_cod_grade_4,
              p_cod_grade_5 TO NULL

   SELECT cod_local_prod,
          cod_roteiro, 
          num_altern_roteiro,
          cod_item,
          cod_local_prod,
          num_docum,
          cod_item_pai
     INTO p_cod_local,
          p_cod_roteiro, 
          p_num_altern_roteiro,
          p_cod_item,
          p_man.local,
          p_num_docum,
          p_cod_item_pai
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.ordem_producao
      AND ies_situa  IN ('4','5')

   IF STATUS = 100 THEN
      LET p_msg = 'ORDEM DE PRODUCAO NAO EXISTE OU NAO ESTA LIBERADA'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORDENS'
         RETURN FALSE
      ELSE
         LET p_num_pedido = p_man.num_pedido
         IF NOT pol0627_le_desc_nat_oper_885() THEN
            RETURN FALSE
         ELSE         
            IF p_ies_apontado <> 'S' THEN
               UPDATE desc_nat_oper_885
                  SET ies_apontado = 'S'
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido  = p_man.num_pedido
               IF STATUS <> 0 THEN
                  LET p_msg = 'ERRO:(',STATUS, ') ATUALIZADO TAB DESC_NAT_OPER_885'
                  RETURN FALSE
               END IF
            END IF
         END IF

         SELECT cod_grade_1,
                cod_grade_2,
                cod_grade_3,
                cod_grade_4,
                cod_grade_5
           INTO p_cod_grade_1,
                p_cod_grade_2,
                p_cod_grade_3,
                p_cod_grade_4,
                p_cod_grade_5
           FROM ordens_complement
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_man.ordem_producao
         IF STATUS = 100 THEN
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORDENS_COMPLEMENT'
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF                                           

   SELECT cod_local_estoq,
          cod_local_insp,
          ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao
     INTO p_cod_local_estoq,
          p_cod_local_insp,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tem_inspecao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM'
      RETURN FALSE
   END IF                                           

   IF NOT pol0627_le_ord_oper() THEN
      RETURN FALSE
   END IF
   
   SELECT ies_forca_apont
     INTO p_ies_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.item

   IF STATUS <> 0 THEN
		  LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM_MAN'
		  RETURN FALSE
   END IF

   LET p_ies_chapa = FALSE
   LET p_ies_onduladeira = 'N'
   
   IF NOT pol0627_le_item_vdp() THEN
	    RETURN FALSE
	 END IF
	 
   IF NOT pol0627_consiste_qtd_apont('L') THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_tem_tab_estoque(p_cod_emp_ger) THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_tem_tab_estoque(p_cod_emp_ofic) THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0627_tem_tab_estoque(p_emp)
#-------------------------------------#

   DEFINE p_emp CHAR(02)
   
   SELECT cod_item
     FROM estoque
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item

   IF STATUS = 100 THEN
      INSERT INTO estoque
       VALUES(p_emp,p_man.item,0,0,0,0,0,0,' ',' ',' ')
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ')INSERINDO',p_man.item CLIPPED, ' NA ESTOQUE'  
         RETURN FALSE
      END IF  
   ELSE
      IF STATUS = 0 THEN
         RETURN TRUE
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ')LENDO',p_man.item CLIPPED, ' NA ESTOQUE' 
         RETURN FALSE
      END IF 
   END IF

   SELECT SUM(qtd_saldo)
     INTO p_qtd_liberada
     FROM estoque_lote
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item
      AND ies_situa_qtd = 'L'
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') SOMANDO ESTOQUE_LIBERADO'  
      RETURN FALSE
   END IF
      
   SELECT SUM(qtd_saldo)
     INTO p_qtd_lib_excep
     FROM estoque_lote
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item
      AND ies_situa_qtd = 'E'
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') SOMANDO ESTOQUE_EXCEPCIONAL'  
      RETURN FALSE
   END IF

   SELECT SUM(qtd_saldo)
     INTO p_qtd_rejeitada
     FROM estoque_lote
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item
      AND ies_situa_qtd = 'R'
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') SOMANDO ESTOQUE_REJEITADA'  
      RETURN FALSE
   END IF

   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') SOMANDO ESTOQUE_REJEITADA'  
      RETURN FALSE
   END IF

   IF p_qtd_lib_excep IS NULL THEN
      LET p_qtd_lib_excep = 0
   END IF
   
   IF p_qtd_liberada IS NULL THEN
      LET p_qtd_liberada = 0
   END IF

   IF p_qtd_rejeitada IS NULL THEN
      LET p_qtd_rejeitada = 0
   END IF

   IF p_qtd_reservada IS NULL THEN
      LET p_qtd_reservada = 0
   END IF
   
   UPDATE estoque
      SET qtd_liberada  = p_qtd_liberada,
          qtd_rejeitada = p_qtd_rejeitada,
          qtd_lib_excep = p_qtd_lib_excep,
          qtd_reservada = p_qtd_reservada
    WHERE cod_empresa = p_emp
      AND cod_item    = p_man.item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') AUTALIZANDO QTDS NA TAB ESTOQUE'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

   
#------------------------------------------------------#
FUNCTION pol0627_le_sdo_refugos(p_cod_item, p_cod_local)
#------------------------------------------------------#

   DEFINE p_cod_item  LIKE item.cod_item, 
          p_cod_local LIKE item.cod_local_estoq
   
   SELECT SUM(qtd_saldo)
	   INTO p_qtd_saldo
	   FROM estoque_lote
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item    = p_cod_item
	    AND cod_local   = p_cod_local
	    AND num_lote    IS NULL

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE:SDO REFUGOS'
	    RETURN FALSE
   END IF
   
   IF p_qtd_saldo IS NULL THEN
      LET p_qtd_saldo = 0
   END IF
      
   IF p_qtd_saldo < p_man.peso_teorico THEN
	    LET p_msg = 'SALDO DO ITEM REFUGO ESTA MENOR QUE QUANTIDADE A ESTORNAR'
      IF NOT pol0627_insere_erro() THEN
	       RETURN FALSE
	    END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_le_ord_oper()
#-----------------------------#

   SELECT ies_oper_final,
		      cod_cent_cust,
		      dat_inicio,
		      qtd_boas,
		      qtd_refugo,
		      qtd_sucata 
		 INTO p_ies_oper_final,
		      p_cod_cent_cust,
		      p_dat_inicio,
		      p_qtd_boas,
		      p_qtd_refug,
		      p_qtd_sucata 
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.ordem_producao
	    AND cod_operac     = p_man.operacao
		
   IF STATUS <> 0 THEN
		  LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_OPER'
		  RETURN FALSE
	 END IF

   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN
      LET p_dat_inicio = CURRENT YEAR TO SECOND
   END IF

   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
FUNCTION pol0627_prepara_dimension()
#-----------------------------------#

   LET p_cod_item = p_cod_prod

   LET p_largura_ped     = 0 
   LET p_comprimento_ped = 0
   LET p_diametro_ped    = 0
   LET p_altura_ped      = 0

   IF p_ies_flor_deloto THEN
      LET p_ies_chapa = FALSE
   ELSE
      IF NOT pol0627_le_item_vdp() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ies_chapa THEN
      IF p_man.consumo_refugo IS NOT NULL AND p_man.consumo_refugo > 0 THEN
         LET p_cod_prod        = p_cod_item_retrab
         LET p_cod_local_baixa = p_cod_local_retrab
         IF p_man.qtd_boas > 0 THEN
            LET p_qtd_baixar = p_man.consumo_refugo
         ELSE
            LET p_qtd_baixar = p_man.consumo_refugo * (-1)
         END IF
         LET p_num_lote        = NULL
      ELSE
         IF NOT pol0627_le_ft_item() THEN
            RETURN FALSE
         END IF
         IF NOT p_tem_ficha THEN
            LET p_msg = 'ITEM:',p_man.item,' SEM FICHA TECNICA'
            CALL pol0627_insere_erro() RETURNING p_status
            RETURN FALSE
         END IF
      END IF
   END IF

   LET p_largura      = p_largura_ped
   LET p_comprimento  = p_comprimento_ped
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0627_le_ft_item()
#----------------------------#
   
   LET p_tem_ficha = FALSE

   DECLARE cq_ft CURSOR FOR
    SELECT largura_chapa,
           compri_chapa
      FROM ft_item_885        
     WHERE cod_empresa = p_cod_emp_ger
       AND cod_item    = p_man.item

   FOREACH cq_ft INTO p_largura_ped, p_comprimento_ped

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DIMENSIONAL FT_ITEM_885'
         RETURN FALSE
      END IF
   
      LET p_tem_ficha = TRUE
      
      EXIT FOREACH
       
   END FOREACH
  
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0627_le_gramatura()
#------------------------------#

   SELECT gramatura
     INTO p_gramatura
     FROM gramatura_885        
    WHERE cod_empresa IN (p_cod_emp_ger, p_cod_emp_ofic)
      AND cod_item    = p_cod_chapa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA GRAMATURA_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0627_material(p_chamada)
#----------------------------------#

   DEFINE p_chamada CHAR(01)
   
   LET p_ondu = p_ies_onduladeira
   
   LET p_cod_local_dest  = NULL
   LET p_ies_situa_orig = 'L'
   LET p_ies_situa      = 'L'
   
   DECLARE cq_structure CURSOR FOR
    SELECT a.cod_item_compon,
           a.qtd_necessaria,
           a.cod_local_baixa
      FROM ord_compon a,
           necessidades b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.num_ordem   = p_man.ordem_producao
       AND b.cod_empresa = p_cod_empresa
       AND b.num_ordem   = a.num_ordem
       AND b.num_neces   = a.cod_item_pai

   FOREACH cq_structure INTO 
           p_cod_prod, 
           p_qtd_necessaria,
           p_cod_local_baixa

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_COMPON:CQ_STRUCTURE'  
         RETURN FALSE
      END IF  

      LET p_qtd_baixar = p_qtd_necessaria * p_man.qtd_boas

      IF NOT pol0627_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item = 'T' THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0627_le_flor_deloto() THEN
         RETURN FALSE
      END IF

      IF p_ies_flor_deloto THEN
         IF p_man.tip_movto MATCHES '[SR]' THEN
            CONTINUE FOREACH
         END IF
      ELSE
         IF p_ies_tip_item = 'C' THEN
            CONTINUE FOREACH
         END IF
      END IF

      IF p_man.tip_movto MATCHES '[SR]' THEN
         IF p_cod_familia = '202' THEN #202 acess�rio
            CONTINUE FOREACH
         END IF
      END IF
      
      SELECT COUNT(cod_familia)
        INTO p_count
        FROM familia_insumo_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
         
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB FAMILIA_INSUMO_885/ITEM_MAN'  
         RETURN FALSE
      END IF
      
      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF

      IF p_ctr_estoque = 'N' OR p_sobre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      IF p_chamada = 'I' AND p_ies_flor_deloto = FALSE THEN 
         IF p_man.consumo_refugo IS NULL OR 
            p_man.consumo_refugo = ' '   OR
            p_man.consumo_refugo = 0   THEN

            LET p_cod_item = p_cod_prod
   
            IF NOT pol0627_le_item_vdp() THEN
               RETURN FALSE
            END IF
   
            IF p_ies_chapa THEN
               CONTINUE FOREACH
            END IF
         END IF
      END IF
   
      IF NOT pol0627_prepara_dimension() THEN
         RETURN FALSE
      END IF

      IF NOT p_ies_flor_deloto THEN
         IF p_qtd_baixar > 0 THEN
            LET p_qtd_pecas = p_qtd_baixar
         ELSE
            LET p_qtd_pecas = -p_qtd_baixar
         END IF
   
         LET p_qtd_aux = p_qtd_pecas
         LET p_qtd_integer = p_qtd_aux
      
         IF p_qtd_integer < p_qtd_aux THEN
            LET p_qtd_integer = p_qtd_integer + 1
         END IF
         IF p_qtd_baixar > 0 THEN
            LET p_qtd_baixar = p_qtd_integer
         ELSE
            LET p_qtd_baixar = -p_qtd_integer
         END IF
      
      END IF

      LET p_cod_local_orig = p_cod_local_baixa
      IF p_chamada MATCHES '[CI]' THEN 
         IF NOT pol0627_cheka_estoque() THEN
            RETURN FALSE
         END IF
         IF p_sem_estoque THEN
            LET p_saldo_txt = p_qtd_saldo
            LET p_saldo_tx2 = p_qtd_baixar
 		        LET p_msg = 'ITEM: ',p_cod_prod CLIPPED,
 		                    ' S ESTOQ P/ BAIXAR - SDO:',p_saldo_txt CLIPPED,' BAIX:',p_saldo_tx2 CLIPPED
 		        IF p_chamada = 'C' THEN
    	         IF NOT pol0627_insere_critic() THEN
	                RETURN FALSE
               END IF
            ELSE
    	         IF NOT pol0627_insere_erro() THEN
	                RETURN FALSE
               END IF
           END IF               
         END IF
      ELSE
         
         IF NOT pol0627_baixa_acessorios() THEN
            RETURN FALSE
         END IF
          
         LET p_cod_empresa = p_cod_emp_ofic

         IF NOT pol0627_baixa_acessorios() THEN
            LET p_cod_empresa = p_cod_emp_ger
            RETURN FALSE
         END IF
            
         LET p_cod_empresa = p_cod_emp_ger
      END IF         
      
   
   END FOREACH
   
   LET p_ies_onduladeira = p_ondu
   LET p_ies_flor_deloto = FALSE
         
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0627_le_flor_deloto()
#-------------------------------#

   SELECT cod_empresa
     FROM familia_baixar_885
    WHERE cod_empresa = p_cod_emp_ofic
      AND cod_familia = p_cod_familia
   
   IF STATUS = 0 THEN
      LET p_ies_flor_deloto = TRUE
   ELSE
      IF STATUS = 100 THEN
         LET p_ies_flor_deloto = FALSE
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB FAMILIA_BAIXAR_885'  
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#---------------------------------#
FUNCTION pol0627_baixa_acessorios()
#---------------------------------#
   
   DEFINE p_num_lote_ant  LIKE estoque_lote.num_lote,
          p_ies_situa_ant LIKE estoque_lote.ies_situa_qtd
          
   SELECT qtd_liberada
     INTO p_qtd_liberada
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_prod

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE LIBERADO - TAB ESTOQUE'  
      RETURN FALSE
   END IF
   
   IF p_qtd_liberada IS NULL THEN
      LET p_qtd_liberada = 0
   END IF
   
   IF p_cod_empresa  = p_cod_emp_ofic THEN
      LET p_qtd_baixar = p_qtd_baixar_ant
   ELSE
      LET p_qtd_baixar_ant = p_qtd_baixar
	 END IF

   IF p_qtd_baixar > 0 THEN
      IF p_qtd_liberada < p_qtd_baixar THEN
         LET p_msg = 'NAO HA ESTOQUE LIBERADO NA TAB ESTOQUE - IT:',p_cod_prod
         RETURN FALSE
      END IF
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_baixar,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   ELSE
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_baixar,
             dat_ult_entrada = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   END IF

   LET p_num_lote_orig  = p_num_lote
   LET p_ies_situa_orig = p_ies_situa
   LET p_cod_local_orig = p_cod_local_baixa
   LET p_num_lote_dest  = NULL
   LET p_ies_situa_dest = NULL 
   LET p_cod_local_dest = NULL

   LET p_cod_local = p_cod_local_baixa
   
   IF p_ies_flor_deloto THEN
      LET p_num_lote_ant  = p_num_lote
      LET p_ies_situa_ant = p_ies_situa
      IF p_qtd_baixar > 0 THEN
         IF NOT pol0627_baixa_pelo_fifo() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_reverte_flor = TRUE
         IF NOT pol0627_reverte_pelo_fifo() THEN
            LET p_reverte_flor = FALSE
            RETURN FALSE
         END IF
         LET p_reverte_flor = FALSE
      END IF      
      LET p_num_lote  = p_num_lote_ant
      LET p_ies_situa = p_ies_situa_ant
   ELSE
      IF NOT pol0627_baixa_estoque_lote() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol0627_deleta_lote() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0627_baixa_estoque_lote()
#------------------------------------#

   LET p_qtd_movto = p_qtd_baixar

   IF p_num_lote IS NOT NULL THEN
		   SELECT *
		     INTO p_estoque_lote_ender.*
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote      = p_num_lote
		      AND ies_situa_qtd = p_ies_situa
		      AND comprimento   = p_comprimento_ped
		      AND largura       = p_largura_ped
		      AND qtd_saldo     > 0
   ELSE
		   SELECT *
		     INTO p_estoque_lote_ender.*
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote        IS NULL
		      AND ies_situa_qtd = p_ies_situa
		      AND comprimento   = p_comprimento_ped
		      AND largura       = p_largura_ped
		      AND qtd_saldo     > 0
   END IF   
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:BEL'  
      RETURN FALSE
   END IF  

   IF STATUS = 100 THEN
      LET p_estorno = TRUE
      LET p_num_lote_orig = p_num_lote
      IF NOT pol0627_insere_lote('B') THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0627_gra_lote_ender() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_gra_lote_ender()
#--------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') BAIXANDO ACESSORIOS ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF  

   IF p_num_lote IS NOT NULL THEN
		   SELECT num_transac, 
		          qtd_saldo
		     INTO p_num_transac,
		          p_qtd_saldo
		     FROM estoque_lote
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote      = p_num_lote
		      AND ies_situa_qtd = p_ies_situa
		      AND qtd_saldo     > 0
   ELSE
		   SELECT num_transac, 
		          qtd_saldo
		     INTO p_num_transac,
		          p_qtd_saldo
		     FROM estoque_lote
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote        IS NULL
		      AND ies_situa_qtd = p_ies_situa
		      AND qtd_saldo     > 0
   END IF
            
   IF STATUS <> 0 THEN
      LET p_msg = 'ITEM:',p_cod_prod CLIPPED,
                  'LT:',p_num_lote CLIPPED,
                  ' S/ SDO NA ESTOQUE_LOTE'
      RETURN FALSE
   END IF  

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo - p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') BAIXANDO ACESSORIOS ESTOQUE_LOTE'  
      RETURN FALSE
   END IF  

   IF NOT pol0627_deleta_lote() THEN
      RETURN FALSE
   END IF

   IF p_reverte_flor THEN
      RETURN TRUE
   END IF
   
   LET p_num_lote_orig = p_num_lote
   
   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0627_grava_estoq_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0627_baixa_pelo_fifo()
#---------------------------------#

   DEFINE p_tot_baixar LIKE estoque_lote.qtd_saldo
   
   LET p_tot_baixar = p_qtd_baixar
   
   DECLARE cq_fifo CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa   = p_cod_empresa
	     AND cod_item      = p_cod_prod
	     AND cod_local     = p_cod_local
	     AND comprimento   = p_comprimento_ped
	     AND largura       = p_largura_ped
	     AND ies_situa_qtd IN ('L','E')
	     AND qtd_saldo     > 0
	   ORDER BY num_transac
	      
   FOREACH cq_fifo INTO p_estoque_lote_ender.*

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ESTOQUE_LOTE_ENDER BAIXANDO FIFO'  
         RETURN FALSE
      END IF  
      
      IF p_estoque_lote_ender.qtd_saldo > p_tot_baixar THEN
         LET p_qtd_movto = p_tot_baixar
         LET p_tot_baixar = 0
      ELSE
         LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
         LET p_tot_baixar = p_tot_baixar - p_qtd_movto
      END IF
     
      LET p_num_lote  = p_estoque_lote_ender.num_lote
      LET p_ies_situa = p_estoque_lote_ender.ies_situa_qtd
      LET p_num_lote_orig  = p_num_lote
      LET p_ies_situa_orig = p_ies_situa
      LET p_cod_local_orig = p_cod_local
      
      IF NOT pol0627_gra_lote_ender() THEN
         RETURN FALSE
      END IF
      
      IF p_tot_baixar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0627_reverte_pelo_fifo()
#-----------------------------------#

   LET p_num_seq_apon = p_num_sequencia
   
   DECLARE cq_rev CURSOR FOR
    SELECT num_transac
      FROM apont_trans_885
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_prod
      AND cod_tip_apon  = p_cod_oper
      AND num_seq_apont = p_num_sequencia
      AND ies_situa     = p_ies_situa
    ORDER BY num_transac

   FOREACH cq_rev INTO p_num_transac_normal

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ')LENDO APONT_TRANS_885'  
         RETURN FALSE
      END IF

      IF NOT pol0627_le_trans_end() THEN
         RETURN FALSE
      END IF

      LET p_num_lote        = p_estoque_trans.num_lote_orig
      LET p_ies_situa       = p_estoque_trans.ies_sit_est_orig
      LET p_cod_local       = p_estoque_trans.cod_local_est_orig
      LET p_comprimento_ped = p_estoque_trans_end.comprimento
      LET p_largura_ped     = p_estoque_trans_end.largura
      LET p_cod_prod        = p_estoque_trans_end.cod_item
      LET p_qtd_baixar      = -p_estoque_trans.qtd_movto

      IF NOT pol0627_baixa_estoque_lote() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0627_add_transacoes() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------#
FUNCTION pol0627_le_item_man()
#-----------------------------#

   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.cod_familia,
          b.ies_sofre_baixa,
          ies_tip_item,
          cod_lin_prod
     INTO p_cod_local_orig,
          p_ctr_estoque,
          p_ctr_lote,
          p_cod_familia,
          p_sobre_baixa,
          p_ies_tip_item,
          p_cod_lin_prod
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_prod
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS = 100 THEN
      LET p_cod_local_orig = 'N'
      LET p_ctr_estoque    = 'N'
      LET p_ctr_lote       = 'N'
      LET p_sobre_baixa    = 'N'
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM/ITEM_MAN'  
         RETURN FALSE
      END IF
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0627_le_equipto(p_equipto)
#-------------------------------------#
   
   DEFINE p_equipto LIKE cfp_equi.cod_equipamento
   
   IF p_parametros[150,150] MATCHES "[12]" THEN
      IF p_parametros[150,150] = '1' THEN
         SELECT cod_empresa
           FROM equipamento
          WHERE cod_empresa = p_cod_empresa
            AND cod_equip   = p_equipto
      ELSE
        SELECT cod_empresa
          FROM cfp_equi
         WHERE cod_empresa     = p_cod_empresa
           AND cod_equipamento = p_equipto
      END IF
      IF STATUS = 100 THEN
         IF NOT pol0627_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB EQUIPAMENTO/CFP_EQUI'
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
 FUNCTION pol0627_consiste_qtd_apont(p_ch)
#----------------------------------------#

   DEFINE p_ch CHAR(01)
   
   INITIALIZE p_msg TO NULL

   SELECT qtd_planejada,
          qtd_boas,
          qtd_refugo,
          qtd_sucata,
          ies_oper_final
     INTO p_qtd_planej,
          p_qtd_boas,
          p_qtd_refug,
          p_qtd_sucata,
          p_ies_oper_final
     FROM ord_oper
    WHERE cod_empresa     = p_cod_empresa
      AND num_ordem       = p_man.ordem_producao
      AND cod_item        = p_man.item
      AND cod_operac      = p_man.operacao
      AND num_seq_operac  = p_man.sequencia_operacao

   IF SQLCA.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB. ORD_OPER.QTD_PLANEJADA'
	    RETURN FALSE
   END IF

   IF p_ch = 'L' OR p_man.ies_devolucao = 'S' THEN
      RETURN TRUE
   END IF

   LET p_qtd_saldo_apon = p_qtd_planej - p_qtd_boas - p_qtd_refug - p_qtd_sucata

   IF p_man.tip_movto MATCHES '[FRS]' AND p_man.qtd_boas > 0 THEN
      IF p_ies_forca_apont MATCHES "[Ss]" THEN
      ELSE
         IF p_qtd_saldo_apon < p_man.qtd_boas THEN
    		    LET p_msg = 'QTD A APONTAR MAIOR QUE SALDO DA OF'
    		 END IF
      END IF
   END IF
   
   IF p_man.qtd_boas < 0 THEN
      LET p_qtd_baixar = p_man.qtd_boas * (-1)
      IF p_man.tip_movto = 'F' THEN
         IF p_qtd_baixar > p_qtd_boas THEN
            LET p_msg = 'QTD BOAS A ESTORNAR MAIOR QUE QTD BOAS APONTADAS'
         END IF
      ELSE
         IF p_man.tip_movto = 'R' THEN
            IF p_qtd_baixar > p_qtd_refug THEN
               LET p_msg = 'QTD REFUGOS A ESTORNAR MAIOR QUE QTD REFUGOS APONTADOS'
            END IF
         ELSE
            IF p_man.tip_movto = 'S' THEN
               IF p_qtd_baixar > p_qtd_sucata THEN
                  LET p_msg = 'QTD SUCATAS A ESTORNAR MAIOR QUE QTD SUCATAS APONTADOS'
               END IF
            END IF
         END IF
      END IF
   END IF

   IF p_msg IS NOT NULL THEN   
      IF NOT pol0627_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
      
END FUNCTION


#---------------------------#
FUNCTION pol0627_grava_man()
#---------------------------#

   LET p_man.dat_atualiz = CURRENT YEAR TO SECOND
   LET p_man.cod_status = p_cod_status
   
   IF p_retorno THEN
      DELETE FROM man_apont_912
       WHERE empresa       = p_cod_empresa
         AND num_seq_apont = p_man.num_seq_apont

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') DELETANDO MAN_APONT_912'
         RETURN FALSE
      END IF
      
      LET p_man.qtd_boas = p_qtd_trim
      
      INSERT INTO man_apont_hist_912
       VALUES(p_man.*)

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') INSERINDO MAN_APONT_HIST_912'
         RETURN FALSE
      END IF
   ELSE
      DELETE FROM man_apont_912
       WHERE empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') DELETANDO MAN_APONT_912'
         RETURN FALSE
      END IF      
   END IF
      
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0627_aponta_op()
#---------------------------#

   LET p_transf_refug = 'N'
   
   IF p_man.ies_devolucao = 'N' THEN
      IF NOT pol0627_grava_ordens() THEN
         RETURN FALSE
      END IF
   END IF 

   IF p_man.tip_movto MATCHES "[FRS]" THEN
      IF p_ies_oper_final = "S"  OR p_man.tip_movto MATCHES '[RS]' THEN
         IF p_man.tip_movto MATCHES '[RS]' AND p_man.ies_devolucao = 'N' THEN
            IF NOT pol0627_le_ft_item() THEN
              RETURN FALSE
            END IF
         END IF
         IF NOT pol0627_move_estoq() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF NOT pol0627_le_desc_nat_oper_885() THEN
      RETURN FALSE
   END IF

   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_ant = p_man.qtd_boas
   ELSE
      LET p_qtd_ant = -p_man.qtd_boas
   END IF
   
   IF p_pct_desc_valor > 0 OR p_cod_item_pai <> '0' THEN
      LET p_qtd_transf = 0
	 ELSE
 	    IF p_pct_desc_qtd = 100 THEN
         LET p_man.item = p_item_ant
 	       RETURN TRUE
 	    END IF
      LET p_qtd_transf = p_qtd_ant * ((100 - p_pct_desc_qtd) / 100)

      LET p_qtd_aux = p_qtd_transf
      
      LET p_qtd_integer = p_qtd_aux
      
      IF p_qtd_integer < p_qtd_aux THEN
         LET p_qtd_integer = p_qtd_integer + 1
      END IF
      
      IF p_man.qtd_boas > 0 THEN
         LET p_man.qtd_boas = p_qtd_integer
      ELSE
         LET p_man.qtd_boas = -p_qtd_integer
      END IF
      
      LET p_qtd_transf = p_qtd_ant - p_qtd_integer
	 END IF      
		
	 LET p_cod_empresa = p_cod_emp_ofic
   LET p_status = TRUE
   
   CALL pol0627_aponta_na_zero() RETURNING p_status
   
   IF p_status AND p_qtd_transf > 0 AND p_man.ies_devolucao = 'N' THEN
      LET p_man.tip_movto = 'R'
      IF p_estorno THEN
         LET p_man.qtd_boas = -p_qtd_transf
      ELSE
         LET p_man.qtd_boas = p_qtd_transf
      END IF
      LET p_transf_refug = 'S'
      CALL pol0627_aponta_na_zero() RETURNING p_status
   END IF

   LET p_cod_empresa  = p_cod_emp_ger
   LET p_man.qtd_boas = p_qtd_ant
   LET p_man.item     = p_item_ant
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_aponta_na_zero()
#--------------------------------#

   IF p_man.tip_movto MATCHES "[FRS]" THEN
      IF p_ies_oper_final = "S"  OR p_man.tip_movto MATCHES '[RS]' THEN
         IF p_man.tip_movto MATCHES "[RS]" THEN
            CALL pol0627_move_estoq() RETURNING p_status
         ELSE
            CALL pol0627_entrada_prod() RETURNING p_status
         END IF
      END IF
   END IF

   IF p_status THEN
      IF p_man.ies_devolucao = 'N' THEN
         CALL pol0627_grava_ordens() RETURNING p_status
      END IF
   END IF

   RETURN(p_status)

END FUNCTION

#------------------------------#
FUNCTION pol0627_grava_ordens()
#------------------------------#

   IF p_man.tip_movto MATCHES '[FRS]' THEN
      IF NOT pol0627_atualiza_ordens() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_boas < 0 THEN
      IF NOT pol0627_deleta_tabs(p_man.operacao, p_man.sequencia_operacao) THEN
         RETURN FALSE
      END IF
      LET p_cod_tip_movto = 'R'
   ELSE
      LET p_cod_tip_movto = 'N'
      IF NOT pol0627_insere_tabs(p_man.operacao, p_man.sequencia_operacao) THEN
         RETURN FALSE
      END IF
      IF p_parametros[128,128] = "S" THEN
         IF NOT pol0627_integra_min() THEN
            RETURN FALSE
          END IF
      END IF
   END IF   
  
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0627_atualiza_ordens()
#---------------------------------#

   LET p_qtd_boas = 0
   LET p_qtd_refug = 0
   LET p_qtd_sucata = 0
   
   IF p_man.tip_movto = 'F' THEN
      LET p_qtd_boas = p_man.qtd_boas
      LET p_cod_item_apon = p_man.item
   ELSE
      IF p_man.tip_movto = 'R' THEN
         LET p_qtd_refug = p_man.qtd_boas
         LET p_cod_item_apon = p_cod_item_retrab
      ELSE
         LET p_qtd_sucata = p_man.qtd_boas
         LET p_cod_item_apon = p_cod_item_sucata
      END IF
   END IF

   IF p_ies_oper_final = 'S' OR p_man.tip_movto MATCHES '[RS]' THEN

      UPDATE ordens
         SET qtd_boas   = qtd_boas + p_qtd_boas,
             qtd_refug  = qtd_refug + p_qtd_refug,
             qtd_sucata = qtd_sucata + p_qtd_sucata,
             dat_ini    = p_dat_inicio
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_man.ordem_producao
            
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A TAB ORDENS'
         RETURN FALSE
      END IF
      
      DECLARE cq_neces CURSOR FOR
       SELECT qtd_necessaria,
              num_neces
         FROM necessidades
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_man.ordem_producao

      FOREACH cq_neces INTO p_qtd_necessaria, p_num_neces

		 # Refresh de tela
	  	 #lds CALL LOG_refresh_display()	
	      
         LET p_qtd_necessaria = p_qtd_necessaria / p_qtd_planej
         LET p_qtd_saida = p_man.qtd_boas * p_qtd_necessaria
         
         UPDATE necessidades
            SET qtd_saida = qtd_saida + p_qtd_saida
          WHERE cod_empresa = p_cod_empresa
            AND num_neces   = p_num_neces
            
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A TAB NECESSIDADES'
            RETURN FALSE
         END IF
      
      END FOREACH
   END IF
   
   UPDATE ord_oper
      SET qtd_boas   = qtd_boas + p_qtd_boas,
          qtd_refugo = qtd_refugo + p_qtd_refug,
          qtd_sucata = qtd_sucata + p_qtd_sucata,
          dat_inicio = p_dat_inicio,
          ies_apontamento = 'F'
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.ordem_producao
	    AND cod_operac     = p_man.operacao
	    AND num_seq_operac = p_man.sequencia_operacao
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A TAB ORD_OPER:1'
      RETURN FALSE
   END IF

   IF p_man.sequencia_operacao > 1 AND p_ies_onduladeira = 'N' THEN
      LET p_num_seq_ant = p_man.sequencia_operacao - 1
      IF NOT pol0627_nao_apontaveis() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ies_oper_final = 'S' AND p_ies_onduladeira = 'N'  THEN
      LET p_num_seq_ant = p_man.sequencia_operacao + 1
      IF NOT pol0627_nao_apontaveis() THEN
         RETURN FALSE
      END IF
   END IF

   SELECT tipo_processo
     INTO p_tipo_processo
     FROM tipo_pedido_885
    WHERE cod_empresa   IN (p_cod_emp_ger, p_cod_emp_ofic)
      AND num_pedido    = p_man.num_pedido         
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB TIPO_PEDIDO_885'
      RETURN FALSE
   END IF

   IF p_tipo_processo = 1 THEN
      UPDATE ped_itens
         SET qtd_pecas_atend = qtd_pecas_atend + p_man.qtd_boas
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_man.num_pedido         
         AND num_sequencia = p_man.num_seq_pedido     

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO PED_ITENS:P�S ATENDIDAS'
         RETURN FALSE
      END IF
             
   END IF
   
   IF p_man.tip_movto <> 'F' THEN
      LET p_qtd_boas = 0
   END IF
         
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_nao_apontaveis()
#--------------------------------#

   SELECT ies_apontamento,
          cod_operac
     INTO p_ies_apontamento,
          p_operacao
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.ordem_producao
     AND num_seq_operac  = p_num_seq_ant
     AND ies_apontamento = 'N'
    	   
   IF STATUS = 0 THEN

      UPDATE ord_oper
         SET qtd_boas   = qtd_boas + p_qtd_boas,
             qtd_refugo = qtd_refugo + p_qtd_refug,
             dat_inicio = p_dat_inicio,
             qtd_sucata = qtd_sucata + p_qtd_sucata
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.ordem_producao
	       AND cod_operac     = p_operacao
	       AND num_seq_operac = p_num_seq_ant
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A TAB ORD_OPER:2'
         RETURN FALSE
      ELSE
         IF p_man.qtd_boas < 0 THEN
            IF NOT pol0627_deleta_tabs(p_operacao,p_num_seq_ant) THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_cod_tip_movto = 'N'
            IF NOT pol0627_insere_tabs(p_operacao,p_num_seq_ant) THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   ELSE
      IF STATUS <> 100 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A TAB ORD_OPER:3'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------------------#
FUNCTION pol0627_deleta_tabs(p_cod_oper, p_num_seq)
#-------------------------------------------------#

   DEFINE p_cod_oper LIKE ORD_OPER.cod_operac,
          p_num_seq  LIKE ORD_OPER.num_seq_operac,
          p_hor_ini  DATETIME HOUR TO SECOND,
          p_hor_fim  DATETIME HOUR TO SECOND,
          p_boas     DECIMAL(10,3),
          p_refug    DECIMAL(10,3),
          p_sucata   DECIMAL(10,3)

   LET p_boas = p_qtd_boas
   LET p_refug = p_qtd_refug
   LET p_sucata = p_qtd_sucata
   
   IF p_boas < 0 THEN
      LET p_boas = p_boas * (-1)
   END IF
   
   IF p_refug < 0 THEN
      LET p_refug = p_refug * (-1)
   END IF
   
   IF p_sucata < 0 THEN
      LET p_sucata = p_sucata * (-1)
   END IF

   LET p_hor_ini = p_man.hor_inicial
   LET p_hor_fim = p_man.hor_fim
   
   DECLARE cq_apo_oper CURSOR FOR
    SELECT num_processo
      FROM apo_oper
     WHERE cod_empresa    = p_cod_empresa
       AND num_ordem      = p_man.ordem_producao
       AND cod_operac     = p_cod_oper
       AND num_seq_operac = p_num_seq
       AND dat_producao   = p_man.dat_fim_producao
       AND hor_inicio     = p_hor_ini
       AND hor_fim        = p_hor_fim
       AND qtd_boas       = p_boas
       AND qtd_refugo     = p_refug
       AND qtd_sucata     = p_sucata

   FOREACH cq_apo_oper INTO p_num_seq_reg

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APO_OPER:CQ_APO_OPER'
         RETURN FALSE
      END IF

      UPDATE apo_oper
         SET cod_tip_movto = 'E'
       WHERE cod_empresa  = p_cod_empresa
         AND num_processo = p_num_seq_reg

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO APO_OPER'
         RETURN FALSE
      END IF

      UPDATE cfp_apms
         SET cod_tip_movto = 'E',
             ies_situa     = 'C'
       WHERE cod_empresa      = p_cod_empresa
         AND num_seq_registro = p_num_seq_reg

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO CFP_APMS'
         RETURN FALSE
      END IF

      UPDATE chf_componente
         SET tip_movto = 'R'
       WHERE empresa            = p_cod_empresa
         AND sequencia_registro = p_num_seq_reg

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO CHF_COMPONENTE'
         RETURN FALSE
      END IF

      EXIT FOREACH
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION deleta_tabs_compl()
#----------------------------#

   DELETE FROM cfp_apms
       WHERE cod_empresa      = p_cod_empresa
         AND num_seq_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO CFP_APMS'
      RETURN FALSE
   END IF

   DELETE FROM chf_componente
       WHERE empresa            = p_cod_empresa
         AND sequencia_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO CHF_COMPONENTE'
      RETURN FALSE
   END IF

   DELETE FROM cfp_appr
       WHERE cod_empresa      = p_cod_empresa
         AND num_seq_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO cfp_appr'
      RETURN FALSE
   END IF

   DELETE FROM cfp_aptm
       WHERE cod_empresa      = p_cod_empresa
         AND num_seq_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO cfp_aptm'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION


#--------------------------------------------------#
FUNCTION pol0627_insere_tabs(p_cod_oper, p_num_seq)
#--------------------------------------------------#

   DEFINE p_cod_oper LIKE ORD_OPER.cod_operac,
          p_num_seq  LIKE ORD_OPER.num_seq_operac

       
  LET p_apo_oper.cod_empresa     = p_cod_empresa
  LET p_apo_oper.dat_producao    = p_man.dat_fim_producao
  LET p_apo_oper.cod_item        = p_man.item
  LET p_apo_oper.num_ordem       = p_man.ordem_producao
  LET p_apo_oper.num_seq_operac  = p_num_seq
  LET p_apo_oper.cod_operac      = p_cod_oper
  LET p_apo_oper.cod_cent_trab   = p_man.centro_trabalho
  LET p_apo_oper.cod_arranjo     = p_man.arranjo
  LET p_apo_oper.cod_cent_cust   = p_cod_cent_cust
  LET p_apo_oper.cod_turno       = p_man.turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial
  LET p_apo_oper.hor_fim         = p_man.hor_fim
  LET p_apo_oper.qtd_boas        = p_qtd_boas
  LET p_apo_oper.qtd_refugo      = p_qtd_refug
  LET p_apo_oper.qtd_sucata      = p_qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.local
  LET p_apo_oper.cod_tip_movto   = p_cod_tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = CURRENT YEAR TO SECOND
  LET p_apo_oper.nom_usuario     = p_user
                   
  # Problemas com calculo de intervalo nos campos datetime
  # verificar
  IF p_man.qtd_hor IS NULL THEN
  	LET p_apo_oper.qtd_horas = 0
  END IF

  INSERT INTO apo_oper(
     cod_empresa,
     dat_producao,
     cod_item,
     num_ordem,
     num_seq_operac,
     cod_operac,
     cod_cent_trab,
     cod_arranjo,
     cod_cent_cust,
     cod_turno,
     hor_inicio,
     hor_fim,
     qtd_boas,
     qtd_refugo,
     qtd_sucata,
     cod_tip_movto,
     num_conta,
     cod_local,
     qtd_horas,
     dat_apontamento,
     nom_usuario)
     
   VALUES(
     p_apo_oper.cod_empresa,
     p_apo_oper.dat_producao,
     p_apo_oper.cod_item,
     p_apo_oper.num_ordem,
     p_apo_oper.num_seq_operac,
     p_apo_oper.cod_operac,
     p_apo_oper.cod_cent_trab,
     p_apo_oper.cod_arranjo,
     p_apo_oper.cod_cent_cust,
     p_apo_oper.cod_turno,
     p_apo_oper.hor_inicio,
     p_apo_oper.hor_fim,
     p_apo_oper.qtd_boas,
     p_apo_oper.qtd_refugo,
     p_apo_oper.qtd_sucata,
     p_apo_oper.cod_tip_movto,
     p_apo_oper.num_conta,
     p_apo_oper.cod_local,
     p_apo_oper.qtd_horas,
     p_apo_oper.dat_apontamento,
     p_apo_oper.nom_usuario)

 
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA APO_OPER'
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2]

  LET p_cfp_apms.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_apms.num_seq_registro = p_num_seq_reg
  LET p_cfp_apms.cod_tip_movto    = p_apo_oper.cod_tip_movto

  IF p_man.tip_movto  = "E" THEN
    LET p_cfp_apms.ies_situa    = "C"
  ELSE
    LET p_cfp_apms.ies_situa    = "A"
  END IF

  LET p_cfp_apms.dat_producao   = p_apo_oper.dat_producao
  LET p_cfp_apms.num_ordem      = p_apo_oper.num_ordem
  
  IF p_man.eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET  p_cfp_apms.cod_cent_trab = p_apo_oper.cod_cent_trab
  
  SELECT cod_unid_prod 
    INTO p_cfp_apms.cod_unid_prod
    FROM cent_trabalho
   WHERE cod_empresa   = p_cod_empresa
     AND cod_cent_trab = p_man.centro_trabalho

  IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB CENT_TRABALHO'
     RETURN FALSE
  END IF

  LET p_cfp_apms.cod_roteiro        = p_cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_num_altern_roteiro
  LET p_cfp_apms.num_seq_operac     = p_apo_oper.num_seq_operac
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = " "
  LET p_cfp_apms.cod_local          = p_man.local
  LET p_cfp_apms.dat_apontamento    = TODAY
  LET p_cfp_apms.hor_apontamento    = TIME
  LET p_cfp_apms.nom_usuario_resp   = p_user
  LET p_cfp_apms.tex_apont          = NULL

  IF p_man.tip_movto = "E"  THEN
    LET p_cfp_apms.dat_estorno     = TODAY
    LET p_cfp_apms.hor_estorno     = TIME
    LET p_cfp_apms.nom_usu_estorno = p_user
  ELSE
    LET p_cfp_apms.dat_estorno     = NULL
    LET p_cfp_apms.hor_estorno     = NULL
    LET p_cfp_apms.nom_usu_estorno = NULL
  END IF

  INSERT INTO cfp_apms VALUES(p_cfp_apms.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA CFP_APMS'
      RETURN FALSE
   END IF


  LET p_cfp_appr.cod_empresa        = p_apo_oper.cod_empresa
  LET p_cfp_appr.num_seq_registro   = p_num_seq_reg
  LET p_cfp_appr.dat_producao       = p_apo_oper.dat_producao
  LET p_cfp_appr.cod_item           = p_apo_oper.cod_item
  LET p_cfp_appr.cod_turno          = p_man.turno
  LET p_cfp_appr.qtd_produzidas     = (p_apo_oper.qtd_boas + p_apo_oper.qtd_refugo)
  LET p_cfp_appr.qtd_pecas_boas     = p_apo_oper.qtd_boas
  LET p_cfp_appr.qtd_sucata         = 0
  LET p_cfp_appr.qtd_defeito_real   = 0
  LET p_cfp_appr.qtd_defeito_padrao = 0
  LET p_cfp_appr.qtd_ciclos         = 0
  LET p_cfp_appr.num_operador       = p_man.matricula

  INSERT INTO cfp_appr VALUES(p_cfp_appr.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA CFP_APPR'
      RETURN FALSE
   END IF

  LET p_cfp_aptm.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_aptm.num_seq_registro = p_num_seq_reg
  LET p_cfp_aptm.dat_producao     = p_apo_oper.dat_producao
  LET p_cfp_aptm.cod_turno        = p_cfp_appr.cod_turno
  LET p_cfp_aptm.ies_periodo      = "A"
  LET p_cfp_aptm.cod_parada       = NULL

  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_fim
  LET p_cfp_aptm.hor_fim_periodo = p_dat_char
  LET p_dat_char = 
      EXTEND(p_apo_oper.dat_producao, YEAR TO DAY), " ", p_apo_oper.hor_inicio
  LET p_cfp_aptm.hor_ini_periodo = p_dat_char

  LET p_cfp_aptm.hor_ini_assumido = p_cfp_aptm.hor_ini_periodo
  LET p_cfp_aptm.hor_fim_assumido = p_cfp_aptm.hor_fim_periodo

  LET p_cfp_aptm.hor_tot_periodo  = p_man.qtd_hor 
  
  # Problema no calculo de horas pelos campos datetime
  IF p_cfp_aptm.hor_tot_periodo IS NULL THEN
  	LET p_cfp_aptm.hor_tot_periodo = 0
  END IF
  LET p_cfp_aptm.hor_tot_assumido = p_cfp_aptm.hor_tot_periodo

  INSERT INTO cfp_aptm VALUES(p_cfp_aptm.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA CFP_APTM'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


##-----------------------------#
 FUNCTION pol0627_integra_min() 
#------------------------------#
  
   DEFINE p_count SMALLINT

   #Aponta a utilizacao do equipamento

   SELECT COUNT(cod_equip)
     INTO p_count
     FROM qtd_acum_ativ_osp
    WHERE cod_equip = p_man.eqpto

    IF STATUS <> 0 THEN
       LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB QTD_ACUM_ATIV_OSP'  
       RETURN FALSE
    END IF  
    
    IF p_count > 0 THEN
       IF NOT pol0627_atualiza_min(p_man.eqpto) THEN
        RETURN FALSE
      END IF
    END IF


    #APONTA A UTILIZACAO DO FERRAMENTAL

   SELECT COUNT(cod_equip)
     INTO p_count
     FROM qtd_acum_ativ_osp
    WHERE cod_equip = p_man.ferramenta

    IF STATUS <> 0 THEN
       LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB QTD_ACUM_ATIV_OSP'  
       RETURN FALSE
    END IF  
    
    IF p_count > 0 THEN
       IF NOT pol0627_atualiza_min(p_man.ferramenta) THEN
        RETURN FALSE
      END IF
    END IF

    RETURN TRUE

END FUNCTION

#------------------------------------------#
 FUNCTION pol0627_atualiza_min(l_cod_equip)
#------------------------------------------#

  DEFINE l_cod_equip       LIKE cfp_equi.cod_equipamento,
         l_qtd_apont       DECIMAL(10,0),
         l_qtd_horas       DECIMAL(10,0)

  LET l_qtd_apont = p_man.qtd_boas + p_man.qtd_refugo
  LET l_qtd_horas = p_apo_oper.qtd_horas

  SELECT qtd_apont 
    FROM apont_min
   WHERE dat_apont = p_apo_oper.dat_producao
     AND cod_equip = l_cod_equip
     AND tip_apont = "Q"

  IF STATUS <> 0 AND STATUS <> 100 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB APONT_MIN:Q'  
     RETURN FALSE
  END IF  

  IF STATUS = 100 THEN
     INSERT INTO apont_min
      VALUES(p_apo_oper.dat_producao, 
             l_cod_equip, "Q", 
             l_qtd_apont)
  ELSE
     UPDATE apont_min
        SET qtd_apont = qtd_apont + l_qtd_apont
      WHERE dat_apont = p_apo_oper.dat_producao
        AND cod_equip = l_cod_equip
        AND tip_apont = "Q"
  END IF

  IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') GRAVANDO TAB APONT_MIN:Q'  
     RETURN FALSE
  END IF  

  SELECT qtd_apont 
    FROM apont_min
   WHERE dat_apont = p_apo_oper.dat_producao
     AND cod_equip = l_cod_equip
     AND tip_apont = "H"

  IF STATUS <> 0 AND STATUS <> 100 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB APONT_MIN:H'  
     RETURN FALSE
  END IF  

  IF STATUS = 100 THEN
     INSERT INTO apont_min
      VALUES(p_apo_oper.dat_producao, 
             l_cod_equip, "H", 
             l_qtd_horas)
  ELSE
     UPDATE apont_min
        SET qtd_apont = qtd_apont + l_qtd_horas
      WHERE dat_apont = p_apo_oper.dat_producao
        AND cod_equip = l_cod_equip
        AND tip_apont = "H"
  END IF

  IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') GRAVANDO TAB APONT_MIN:H'  
     RETURN FALSE
  END IF  

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0627_move_estoq()
#----------------------------#

   LET p_cod_operacao = NULL

   LET p_num_lote_op = p_num_lote
   LET p_cod_oper = 'B'
   LET p_flag = '1'
   
   IF p_cod_empresa = p_cod_emp_ger THEN
      IF NOT pol0627_material('B') THEN 
         RETURN FALSE
      END IF
   END IF

   LET p_num_lote = p_num_lote_op

   LET p_cod_operacao = NULL
   
   IF p_man.ies_devolucao = 'N' THEN
      IF p_man.tip_movto = 'S' THEN #Lu pediu p/ n�o apontar tipo S. 
         RETURN TRUE                #Apenas baixar acess�rios
      END IF
   END IF

   IF NOT pol0627_le_item() THEN
      RETURN FALSE
   END IF

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB ITEM - APON OP ',p_man.ordem_producao
      RETURN FALSE
   END IF

   IF p_ies_ctr_estoque <> 'S' THEN
      RETURN TRUE
   END IF

   LET p_flag = '2'
   
   IF p_man.ies_devolucao = 'N' THEN
      IF NOT pol0627_entrada_prod() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.tip_movto MATCHES '[RS]' THEN
      LET p_cod_oper = 'B'
      LET p_num_lote_orig  = p_num_lote
      LET p_cod_local_orig = p_cod_local

      IF p_man.ies_devolucao = 'N' THEN
         LET p_ies_situa_orig = 'R'
      ELSE
         LET p_ies_situa_orig = 'L'
         LET p_ies_situa      = 'L'
         IF p_man.tip_movto = 'R' THEN
            LET p_cod_item_apon = p_cod_item_retrab
         ELSE
            LET p_cod_item_apon = p_cod_item_sucata
         END IF
      END IF
      
      LET p_num_lote_dest  = NULL
      LET p_cod_local_dest = NULL
      LET p_ies_situa_dest = NULL

      IF p_man.tip_movto = 'R' THEN
         SELECT par_txt 
           INTO p_cod_operacao
           FROM par_sup_pad
          WHERE cod_empresa = p_cod_empresa
            AND den_parametro = 'Operacao de Baixa de estoque itens orig.'        
      ELSE
         SELECT substring(parametros,133,4)
           INTO p_cod_operacao
           FROM par_pcp
          WHERE cod_empresa = p_cod_empresa
      END IF

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELAS PAR_SUP_PAD/PAR_PCP'
         RETURN FALSE
      END IF
      
      IF p_man.qtd_boas < 0 THEN
         LET p_qtd_movto = p_man.qtd_boas * (-1)
      ELSE
         LET p_qtd_movto = p_man.qtd_boas
      END IF

      IF p_man.ies_devolucao = 'S' THEN
         LET p_cod_local = p_cod_local_estoq
         LET p_cod_local_orig = p_cod_local
         LET p_qtd_movto = p_man.qtd_boas
         LET p_cod_prod  = p_man.item
         LET p_largura_ped = p_largura
         LET p_comprimento_ped = p_comprimento
        
         UPDATE estoque 
            SET qtd_liberada = qtd_liberada - p_qtd_movto
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_prod
                  
         IF p_man.qtd_boas < 0 THEN
            LET p_cod_tip_movto = 'R'
            IF NOT pega_dimen() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_cod_tip_movto = 'N'
         END IF
         LET p_qtd_baixar = p_qtd_movto
         IF NOT pol0627_baixa_estoque_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0627_grava_estoq_trans() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_man.tip_movto = 'R' THEN

        LET p_pri_num_transac = p_num_transac_orig
        
	      LET p_cod_item = p_man.item
	      LET p_num_lote_op = p_num_lote
	      LET p_qtd_ant = p_man.qtd_boas
	      
	      IF p_transf_refug = 'S' THEN
	         LET p_man.item = p_cod_item_refugo
    	     LET p_num_lote = p_num_lote_refugo
    	     LET p_cod_local_estoq = p_cod_local_refug 
    	     SELECT peso
    	       INTO p_man.peso_teorico
    	       FROM ft_item_885
    	      WHERE cod_empresa = p_cod_emp_ger
    	        AND cod_item    = p_cod_item
           IF STATUS <> 0 THEN
              LET p_msg = 'ERRO:(',STATUS, ') LENDO PESO DO ITEM'
              RETURN FALSE
           END IF
           IF p_man.peso_teorico IS NULL THEN
              LET p_man.peso_teorico = 0
           ELSE
              LET p_man.peso_teorico = p_man.peso_teorico * p_qtd_ant / 1000
           END IF
	      ELSE
           LET p_man.item = p_cod_item_apon
           LET p_num_lote = NULL
        END IF
        
        LET p_man.qtd_boas = p_man.peso_teorico
	      
	      IF NOT pol0627_le_item() THEN
	         RETURN FALSE
	      END IF
	      
	      LET p_flag = '3'
	
	      SELECT par_txt 
	        INTO p_cod_operacao
	        FROM par_sup_pad
	       WHERE cod_empresa = p_cod_empresa
	         AND den_parametro = 'Operacao de Baixa de estoque itens dest.'        
	            
	      IF NOT pol0627_entrada_prod() THEN
	         RETURN FALSE
	      END IF
	      
	      LET p_man.item = p_cod_item
	      LET p_num_lote = p_num_lote_op
	      LET p_cod_operacao = NULL
	      LET p_man.qtd_boas = p_qtd_ant
	      LET p_flag = '2'

        IF NOT pol0627_insere_est_relac() THEN
           RETURN FALSE
        END IF

      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0627_insere_est_relac()
#----------------------------------#

   LET p_est_trans_relac.cod_empresa      = p_cod_empresa
   LET p_est_trans_relac.num_transac_orig = p_pri_num_transac
   LET p_est_trans_relac.num_transac_dest = p_num_transac_orig
   LET p_est_trans_relac.cod_item_orig    = p_man.item
   LET p_est_trans_relac.cod_item_dest    = p_cod_item_apon
   LET p_est_trans_relac.dat_movto        = TODAY

   SELECT num_nivel
     INTO p_est_trans_relac.num_nivel
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_apon
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'item_man')
      RETURN FALSE
   END IF
   
   INSERT INTO est_trans_relac
     VALUES(p_est_trans_relac.*)
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB EST_TRANS_RELAC - ',p_man.ordem_producao
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION	 

#-----------------------------#
FUNCTION pol0627_grava_relac()
#-----------------------------#

   DECLARE cq_cm_tmp CURSOR FOR
    SELECT num_transac_dest,
           cod_item_dest
      FROM consumo_tmp_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY num_transac_dest

   FOREACH cq_cm_tmp INTO 
           p_num_transac_dest,
           p_cod_item_dest

	 # Refresh de tela
  	 #lds CALL LOG_refresh_display()	
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB CONSUMO_TMP_885 - ',p_man.ordem_producao
         RETURN FALSE
      END IF
      
      IF NOT pol0627_ins_relac() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION      

#---------------------------#
FUNCTION pol0627_ins_relac()
#---------------------------#

   DEFINE p_num_nivel LIKE est_trans_relac.num_nivel
                 
   SELECT num_nivel
     INTO p_num_nivel
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_dest
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM_MAN - ',p_man.ordem_producao
      RETURN FALSE
   END IF
   
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto) 
   VALUES(p_cod_empresa,
          p_num_nivel,
          p_num_transac_orig,
          p_cod_item_orig,
          p_num_transac_dest,
          p_cod_item_dest,
          p_dat_relac)
          
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO TAB EST_TRANS_RELAC - ',p_man.ordem_producao
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_ins_consumo()
#-----------------------------#

   INSERT INTO consumo_tmp_885
    VALUES(p_cod_empresa, p_num_transac_dest, p_cod_item_dest)
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO TAB CONSUMO_TMP_885 - ',p_man.ordem_producao
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION pol0627_le_item()
#--------------------------#

   SELECT cod_local_estoq,
          cod_local_insp,
          ies_ctr_estoque,
          ies_ctr_lote,
          ies_tem_inspecao
     INTO p_cod_local_estoq,
          p_cod_local_insp,
          p_ies_ctr_estoque,
          p_ies_ctr_lote,
          p_ies_tem_inspecao
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.item

   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'ITEM ENVIADO NAO CADASTRADO NO LOGIX ',p_man.ordem_producao
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB ITEM - APON OP ',p_man.ordem_producao
      END IF
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_update_estoque()
#--------------------------------#

   IF p_ies_situa = 'L' THEN
      UPDATE estoque 
         SET qtd_liberada = qtd_liberada - p_qtd_baixar,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   ELSE
      UPDATE estoque
         SET qtd_lib_excep = qtd_lib_excep - p_qtd_baixar,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   END IF
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_deleta_lote()
#-----------------------------#

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      AND qtd_saldo   <= 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE'  
      RETURN FALSE
   END IF   

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac
      AND qtd_saldo   <= 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0627_entrada_prod()
#------------------------------#

   LET p_qtd_movto = p_man.qtd_boas
   LET p_cod_oper = 'A'
   LET p_dat_char = p_man.dat_fim_producao, " ", p_man.hor_fim
   LET p_date_time = EXTEND(p_dat_char, YEAR TO SECOND)
   
   IF p_man.qtd_boas > 0  OR p_flag MATCHES '[230]' THEN
      LET p_cod_prod  = p_man.item
      IF p_man.qtd_boas > 0 THEN
         LET p_estorno = FALSE
      ELSE
         LET p_estorno = TRUE
      END IF
      LET p_cod_local = p_cod_local_estoq
   ELSE
      LET p_estorno   = TRUE
      LET p_qtd_movto = p_qtd_baixar * (-1)
      LET p_cod_local = p_cod_local_baixa
   END IF

   LET p_num_lote_orig  = NULL
   LET p_cod_local_orig = NULL
   LET p_ies_situa_orig = NULL
   LET p_num_lote_dest  = p_num_lote
   LET p_cod_local_dest = p_cod_local
      
   IF P_man.tip_movto MATCHES '[RS]'  AND 
      p_man.item <> p_cod_item_retrab AND
      p_man.item <> p_cod_item_refugo THEN
      LET p_ies_situa_dest = 'R'
      LET p_ies_situa = 'R'
   ELSE
      LET p_ies_situa_dest = 'L'
   END IF
    
   IF p_ies_tem_inspecao = 'S' THEN
      LET p_ies_situa_dest = 'I'
      LET p_cod_local_dest = p_cod_local_insp
   END IF   
    
   IF P_man.tip_movto MATCHES '[RS]'  AND 
      p_man.item <> p_cod_item_retrab AND
      p_man.item <> p_cod_item_refugo  THEN
   ELSE
      IF p_ies_tem_inspecao = 'S' THEN
         UPDATE estoque 
            SET qtd_impedida = qtd_impedida + p_qtd_movto
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_prod
         LET p_ies_situa = 'I'
      ELSE
         IF p_qtd_movto > 0 THEN
            UPDATE estoque
               SET qtd_liberada = qtd_liberada + p_qtd_movto,
                   dat_ult_entrada = getdate()
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_cod_prod
         ELSE
            UPDATE estoque
               SET qtd_liberada = qtd_liberada + p_qtd_movto,
                   dat_ult_saida = getdate()
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = p_cod_prod
         END IF
         LET p_ies_situa = 'L'
      END IF   

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
         RETURN FALSE
      END IF   
   END IF

   IF P_man.tip_movto MATCHES '[RS]'  AND  
      p_man.item <> p_cod_item_retrab AND
      p_man.item <> p_cod_item_refugo THEN

      IF p_man.qtd_boas < 0 THEN
         LET p_qtd_movto = p_man.qtd_boas * (-1)
      END IF

      IF NOT pol0627_carrega_campos() THEN
         RETURN
      END IF
      
      IF NOT pol0627_grava_estoq_trans() THEN
         RETURN FALSE
      END IF
      
   ELSE
      CALL pol0627_le_lote()
 
      IF STATUS = 0 THEN
         IF NOT pol0627_update_lote() THEN
            RETURN FALSE
         END IF
         IF NOT pol0627_deleta_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS = 100 THEN
            IF NOT pol0627_insere_lote('P') THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE'  
            RETURN FALSE
         END IF   
      END IF

   END IF

   RETURN TRUE
  
END FUNCTION

#-------------------------#
FUNCTION pol0627_le_lote()
#-------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT num_transac,
             qtd_saldo
        INTO p_num_transac,
             p_saldo_lote
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND num_lote      = p_num_lote
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
	       AND qtd_saldo     > 0
   ELSE
      SELECT num_transac,
             qtd_saldo
        INTO p_num_transac,
             p_saldo_lote
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
	      AND qtd_saldo     > 0
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol0627_le_ender()
#--------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND num_lote      = p_num_lote
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_largura_ped
         AND altura        = p_altura_ped
         AND diametro      = p_diametro_ped
         AND comprimento   = p_comprimento_ped
	      AND qtd_saldo      > 0
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
         AND largura       = p_largura_ped
         AND altura        = p_altura_ped
         AND diametro      = p_diametro_ped
         AND comprimento   = p_comprimento_ped
	      AND qtd_saldo      > 0
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol0627_atualiza_lote()
#-------------------------------#

   DEFINE p_achou SMALLINT

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   

   LET p_achou = FALSE
   
   IF p_num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND num_lote      = p_num_lote
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
	      AND qtd_saldo     > 0
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
		      AND qtd_saldo     > 0
   END IF
   
   IF STATUS = 100 THEN
      LET p_msg = 'ESTOQUE_LOTE/LOTE_ENDER INCOMPATIVEIS - IT:',
                  p_cod_prod CLIPPED,' LT:',p_num_lote 
      RETURN FALSE
   END IF
   
   IF STATUS <> 0 THEN
      IF STATUS = -284 THEN
         LET p_msg = "LOTE:",p_num_lote
         LET p_msg = p_msg CLIPPED," REPLICADO NA ESTOQUE_LOTE_ENDER"
      ELSE
         LET p_op_txt = p_man.ordem_producao  
         LET p_msg = 'ERRO:(',STATUS, ')LENDO TAB ESTOQUE_LOTE_ENDER - OP:', p_op_txt
      END IF
      RETURN FALSE
   END IF
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_estoque_lote_ender.num_transac

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   

   IF NOT p_inse_trans THEN
      RETURN TRUE
   END IF

   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0627_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0627_update_lote()
#----------------------------#

   DEFINE p_achou SMALLINT

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   

   IF NOT pol0627_le_item_ctr_grade(p_cod_prod) THEN
      RETURN FALSE
   END IF

   IF NOT pega_dimen() THEN
      RETURN FALSE
   END IF

   IF p_ies_largura = 'N' THEN
      LET p_largura_ped = 0
   END IF

   IF p_ies_altura = 'N' THEN
      LET p_altura_ped = 0
   END IF
   
   IF p_ies_diametro = 'N' THEN
      LET p_diametro_ped = 0
   END IF

   IF p_ies_comprimento = 'N' THEN
      LET p_comprimento_ped = 0
   END IF

   LET p_achou = FALSE
   CALL pol0627_le_ender()
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_op_txt = p_man.ordem_producao  
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER - OP:', p_op_txt
      RETURN FALSE
   END IF

   IF STATUS = 0 THEN   
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac

      IF STATUS <> 0 THEN      
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE_LOTE_ENDER'  
         RETURN FALSE
      END IF   
   ELSE
	    IF p_qtd_movto < 0 THEN 
	       LET p_qtd_movto = p_qtd_movto * (-1)
	    END IF

      IF NOT pol0627_carrega_campos() THEN
         RETURN FALSE
      END IF
	   
      IF NOT pol0627_insere_ender() THEN
         RETURN FALSE
      END IF
   END IF 
       
   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0627_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0627_insere_lote(p_carac)
#-----------------------------------#

   DEFINE p_carac CHAR(01)

   IF p_qtd_movto < 0 THEN 
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   LET p_estoque_lote.cod_empresa   = p_cod_empresa
   LET p_estoque_lote.cod_item      = p_cod_prod
   LET p_estoque_lote.cod_local     = p_cod_local
   LET p_estoque_lote.num_lote      = p_num_lote
   LET p_estoque_lote.ies_situa_qtd = p_ies_situa
   LET p_estoque_lote.qtd_saldo     = p_qtd_movto

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_estoque_lote.cod_empresa,
                 p_estoque_lote.cod_item,
                 p_estoque_lote.cod_local,
                 p_estoque_lote.num_lote,
                 p_estoque_lote.ies_situa_qtd,
                 p_estoque_lote.qtd_saldo)
                 
   IF STATUS <> 0 THEN
     LET p_msg = p_carac,'ERRO:(',STATUS, ') INSERINDO ESTOQUE_LOTE/'  
     LET p_msg = p_msg CLIPPED, p_estoque_lote.cod_item
     LET p_msg = p_msg CLIPPED, '/', p_estoque_lote.num_lote
     RETURN FALSE
   END IF
   
   IF p_carac = 'T' THEN
      RETURN TRUE
   END IF

   IF NOT pol0627_carrega_campos() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0627_insere_ender() THEN
      RETURN FALSE
   END IF
   
   IF p_reverte_flor THEN
      RETURN TRUE
   END IF
   
   IF NOT pol0627_grava_estoq_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0627_carrega_campos()
#-------------------------------#

   LET p_estoque_lote.cod_empresa   = p_cod_empresa
	 LET p_estoque_lote.cod_item      = p_cod_prod
	 LET p_estoque_lote.cod_local     = p_cod_local
	 LET p_estoque_lote.num_lote      = p_num_lote
	 LET p_estoque_lote.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote.qtd_saldo     = p_qtd_movto

   IF NOT pol0627_le_item_ctr_grade(p_estoque_lote.cod_item) THEN
      RETURN FALSE
   END IF

   IF NOT p_estorno THEN
      IF NOT pega_dimen() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_ies_largura = 'S' THEN
      LET p_estoque_lote_ender.largura = p_largura
   ELSE
      LET p_estoque_lote_ender.largura = 0
   END IF

   IF p_ies_altura = 'S' THEN
      LET p_estoque_lote_ender.altura = p_altura
   ELSE
      LET p_estoque_lote_ender.altura = 0
   END IF
   
   IF p_ies_serie = 'S' THEN
      LET p_estoque_lote_ender.num_serie = p_man.num_pedido
   ELSE
      LET p_estoque_lote_ender.num_serie = ' '
   END IF

   IF p_ies_diametro = 'S' THEN
      LET p_estoque_lote_ender.diametro = p_diametro
   ELSE
      LET p_estoque_lote_ender.diametro = 0
   END IF

   IF p_ies_comprimento = 'S' THEN
      LET p_estoque_lote_ender.comprimento = p_comprimento
   ELSE
      LET p_estoque_lote_ender.comprimento = 0
   END IF
   
   IF p_ies_dat_producao = 'S' THEN
      LET p_estoque_lote_ender.dat_hor_producao = CURRENT YEAR TO SECOND
   ELSE
      LET p_estoque_lote_ender.dat_hor_producao = "1900-01-01 00:00:00"
   END IF

   LET p_estoque_lote_ender.cod_empresa        = p_cod_empresa
   LET p_estoque_lote_ender.cod_item           = p_estoque_lote.cod_item
   LET p_estoque_lote_ender.cod_local          = p_estoque_lote.cod_local
   LET p_estoque_lote_ender.num_lote           = p_estoque_lote.num_lote
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_situa_qtd      = p_estoque_lote.ies_situa_qtd
   LET p_estoque_lote_ender.qtd_saldo          = p_estoque_lote.qtd_saldo
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_insere_ender()
#-----------------------------#

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
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA ESTOQUE_LOTE_ENDER'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0627_le_operacao()
#-----------------------------#

   IF p_cod_oper = 'B' THEN   
      
      SELECT cod_estoque_sp    
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_cod_empresa
   ELSE                
      SELECT cod_estoque_rp    
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_cod_empresa
   END IF
   
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB PAR_PCP.COD_ESTOQUE_SP/RP'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0627_grava_estoq_trans()
#-----------------------------------#

   IF p_cod_tip_movto = 'R' THEN
      CALL pol0627_le_trans_apont() RETURNING p_status
   ELSE
      CALL pol0627_prepara_trans() RETURNING p_status
   END IF

   IF NOT p_status THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_add_transacoes() THEN
      RETURN FALSE
   END IF
   
   IF p_cod_oper = 'B' THEN
      IF p_flag <> '3' AND p_man.qtd_boas > 0 THEN
         IF NOT pol0627_insere_chf_compon() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_add_transacoes()
#--------------------------------#

   IF NOT pol0627_ins_est_trans() THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0627_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   IF p_cod_tip_movto = 'R' THEN
      IF NOT pol0627_atu_apont_trans() THEN
         RETURN FALSE
      END IF   
   ELSE
      IF NOT pol0627_ins_apont_trans() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0627_prepara_trans()
#-------------------------------#

   INITIALIZE p_estoque_trans.* TO NULL

   IF p_cod_operacao IS NULL THEN
      IF NOT pol0627_le_operacao() THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_OPERAC:', p_cod_operacao
     RETURN FALSE
   END IF

   LET p_num_conta = NULL

   IF p_ies_com_detalhe = 'S' THEN 
      IF p_cod_oper = 'B' THEN
         IF p_num_conta IS NULL THEN
            SELECT num_conta_debito 
              INTO p_num_conta
              FROM estoque_operac_ct
             WHERE cod_empresa  = p_cod_empresa
               AND cod_operacao = p_cod_operacao
         END IF
      ELSE
         IF p_cod_oper = 'A' THEN
            SELECT num_conta_credito 
              INTO p_num_conta
              FROM estoque_operac_ct
             WHERE cod_empresa  = p_cod_empresa
               AND cod_operacao = p_cod_operacao
         END IF
      END IF
      IF STATUS <> 0 THEN
        LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_OPERAC_CT:', p_cod_operacao
        RETURN FALSE
      END IF
   END IF
   
   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.cod_item           = p_cod_prod
   LET p_estoque_trans.dat_movto          = p_dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "POL0627"
   LET p_estoque_trans.num_docum          = p_man.ordem_producao
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = 0
   LET p_estoque_trans_end.cus_unit_movto_f = 0
   LET p_estoque_trans_end.cus_tot_movto_p  = 0
   LET p_estoque_trans_end.cus_tot_movto_f  = 0
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = ' '
   LET p_estoque_trans_end.tex_reservado    = " "
      
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0627_ins_apont_trans()
#---------------------------------#

   INSERT INTO apont_trans_885
      VALUES(p_cod_empresa,
             p_man.num_seq_apont,
             p_cod_prod,
             p_num_transac_orig,
             p_cod_oper,
             p_cod_tip_movto,
             p_ies_situa)
             
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB APONT_TRANS_885'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0627_atu_apont_trans()
#--------------------------------#

   UPDATE apont_trans_885
      SET cod_tip_movto = p_cod_tip_movto
    WHERE cod_empresa   = p_cod_empresa
      AND num_seq_apont = p_num_seq_apon
      AND cod_item      = p_cod_prod
      
   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TABELA APONT_TRANS_885'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
         
#-------------------------------#
FUNCTION pol0627_ins_est_trans()
#-------------------------------#

   LET p_estoque_trans.num_transac   = 0
   LET p_estoque_trans.ies_tip_movto = p_cod_tip_movto
   LET p_estoque_trans.nom_usuario   = p_user

   IF p_dat_proces IS NOT NULL THEN                                                                
      LET p_estoque_trans.dat_proces = p_dat_proces 
   ELSE
      LET p_estoque_trans.dat_proces = TODAY 
   END IF
   
   IF p_hor_operac IS NOT NULL THEN
      LET p_estoque_trans.hor_operac = p_hor_operac                                                              
   ELSE
      LET p_estoque_trans.hor_operac = TIME 
   END IF

    INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS'  
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   IF p_cod_tip_movto = 'N' THEN
      IF p_cod_operacao = p_cod_oper_sp THEN
         LET p_cod_item_dest    = p_estoque_trans.cod_item
         LET p_num_transac_dest = p_num_transac_orig
         IF NOT pol0627_ins_consumo() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_cod_operacao = p_cod_oper_rp THEN
            LET p_cod_item_orig = p_estoque_trans.cod_item
            LET p_dat_relac     = p_estoque_trans.dat_movto
            IF NOT pol0627_grava_relac() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
    
   LET p_cod_operacao = NULL

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0627_ins_est_trans_end()
#------------------------------------#

   LET p_estoque_trans_end.num_transac   = p_num_transac_orig
   LET p_estoque_trans_end.ies_tip_movto = p_estoque_trans.ies_tip_movto

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_END'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0627_insere_chf_compon()
#-----------------------------------#

  LET p_chf_compon.empresa            = p_estoque_lote_ender.cod_empresa
  LET p_chf_compon.sequencia_registro = p_num_seq_reg
  LET p_chf_compon.tip_movto          = p_cod_tip_movto
  LET p_chf_compon.item_componente    = p_estoque_lote_ender.cod_item
  LET p_chf_compon.qtd_movto          = p_qtd_movto
  LET p_chf_compon.local_estocagem    = p_estoque_lote_ender.cod_local
  LET p_chf_compon.endereco           = p_estoque_lote_ender.endereco
  LET p_chf_compon.num_volume         = p_estoque_lote_ender.num_volume
  LET p_chf_compon.grade_1            = p_estoque_lote_ender.cod_grade_1
  LET p_chf_compon.grade_2            = p_estoque_lote_ender.cod_grade_2
  LET p_chf_compon.grade_3            = p_estoque_lote_ender.cod_grade_3
  LET p_chf_compon.grade_4            = p_estoque_lote_ender.cod_grade_4
  LET p_chf_compon.grade_5            = p_estoque_lote_ender.cod_grade_5
  LET p_chf_compon.pedido_venda       = p_estoque_lote_ender.num_ped_ven
  LET p_chf_compon.seq_pedido_venda   = p_estoque_lote_ender.num_seq_ped_ven
  LET p_chf_compon.sit_qtd_item       = p_estoque_lote_ender.ies_situa_qtd
  LET p_chf_compon.peca               = p_estoque_lote_ender.num_peca
  LET p_chf_compon.serie_componente   = p_estoque_lote_ender.num_serie
  LET p_chf_compon.comprimento        = p_estoque_lote_ender.comprimento
  LET p_chf_compon.largura            = p_estoque_lote_ender.largura
  LET p_chf_compon.altura             = p_estoque_lote_ender.altura
  LET p_chf_compon.diametro           = p_estoque_lote_ender.diametro
  LET p_chf_compon.lote               = p_estoque_lote_ender.num_lote
  LET p_chf_compon.dat_hor_producao   = p_estoque_lote_ender.dat_hor_producao
  LET p_chf_compon.dat_hor_validade   = p_estoque_lote_ender.dat_hor_validade
  LET p_chf_compon.reservado          = p_estoque_lote_ender.tex_reservado

  INSERT INTO chf_componente VALUES(p_chf_compon.*)
  
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA chf_componente'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_ins_trans_rev()
#-------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_num_transac_normal,
           p_num_transac_orig)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_REV'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0627_ins_est_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            getdate(),
            'POL0627')

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_AUDITORIA'  
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0627_le_trans_apont()
#--------------------------------#
   
   IF p_man.num_seq_apont > 0 THEN
      LET p_num_seq_apon = p_num_sequencia
   ELSE
      LET p_num_seq_apon = -p_num_sequencia
   END IF
   
   SELECT num_transac
     INTO p_num_transac_normal
     FROM apont_trans_885
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_prod
      AND cod_tip_apon  = p_cod_oper
      AND num_seq_apont = p_num_seq_apon
      AND ies_situa     = p_ies_situa
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_TRANS_885'  
      RETURN FALSE
   END IF

   IF NOT pol0627_le_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0627_le_trans_end()
#------------------------------#

   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_normal   

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE_TRANS'  
      RETURN FALSE
   END IF

   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac_normal   

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF
           
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0627_le_desc_nat_oper_885()
#--------------------------------------#

   SELECT pct_desc_valor,
          pct_desc_qtd, 
          ies_apontado
     INTO p_pct_desc_valor,
          p_pct_desc_qtd,
          p_ies_apontado
    FROM desc_nat_oper_885
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_num_pedido
            
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB desc_nat_oper_885:2'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0627_pega_pedido()
#-------------------------------#

   DEFINE p_carac CHAR(01),
          p_numpedido CHAR(6),
          p_numseq    CHAR(3)

   INITIALIZE p_numpedido, p_numseq TO NULL

   FOR p_ind = 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac = '/' THEN
          EXIT FOR
       END IF
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numpedido = p_numpedido CLIPPED, p_carac
       END IF
   END FOR
   
   FOR p_ind = p_ind + 1 TO LENGTH(p_num_docum)
       LET p_carac = p_num_docum[p_ind]
       IF p_carac MATCHES "[0123456789]" THEN
          LET p_numseq = p_numseq CLIPPED, p_carac
       END IF
   END FOR
   
   LET p_num_pedido     = p_numpedido
   LET p_num_seq_pedido = p_numseq

END FUNCTION

#-------------------------------#
FUNCTION pol0627_cheka_estoque()
#-------------------------------#

   LET p_sem_estoque = FALSE
   LET p_cod_local   = p_cod_local_orig
   LET p_ies_situa   = 'L'
   
   IF p_cod_prod = p_cod_item_retrab OR p_ies_flor_deloto THEN

		   SELECT SUM(qtd_saldo)
		     INTO p_qtd_saldo
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      #AND num_lote        IS NULL
		      #AND ies_situa_qtd = p_ies_situa
		      AND comprimento   = p_comprimento_ped
		      AND largura       = p_largura_ped
		      AND altura        = p_altura_ped
		      AND diametro      = p_diametro_ped
          AND ies_situa_qtd IN ('L','E')
          
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
         RETURN FALSE
      END IF  

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_prod
         AND a.cod_local   = p_cod_local
         AND b.cod_empresa = a.cod_empresa
         AND b.num_reserva = a.num_reserva
         AND b.comprimento = p_comprimento_ped
         AND b.largura     = p_largura_ped
         AND altura        = p_altura_ped
         AND diametro      = p_diametro_ped
         
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
         RETURN FALSE
      END IF  
            
   ELSE		
		   SELECT SUM(qtd_saldo)
		     INTO p_qtd_saldo
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote      = p_num_lote
		      AND ies_situa_qtd = p_ies_situa
		      AND comprimento   = p_comprimento_ped
		      AND largura       = p_largura_ped
		      AND altura        = p_altura_ped
		      AND diametro      = p_diametro_ped

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:SUM'  
         RETURN FALSE
      END IF  

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser a,
             est_loc_reser_end b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_prod
         AND a.cod_local   = p_cod_local
         AND a.num_lote    = p_num_lote
         AND b.cod_empresa = a.cod_empresa
         AND b.num_reserva = a.num_reserva
         AND b.comprimento = p_comprimento_ped
         AND b.largura     = p_largura_ped
         AND altura        = p_altura_ped
         AND diametro      = p_diametro_ped
         
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
         RETURN FALSE
      END IF  

   END IF

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo = 0 OR p_qtd_saldo < p_qtd_baixar THEN
      LET p_sem_estoque = TRUE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------#
FUNCTION pega_dimen()
#--------------------#

   LET p_largura     = p_man.largura
   LET p_altura      = p_man.altura
   LET p_diametro    = p_man.diametro
   LET p_comprimento = p_man.comprimento
   
   IF p_largura IS NULL THEN
      LET p_largura_ped = 0
   ELSE
      LET p_largura_ped = p_largura
   END IF

   IF p_altura IS NULL THEN
      LET p_altura_ped = 0
   ELSE
      LET p_altura_ped = p_altura
   END IF

   IF p_diametro IS NULL THEN
      LET p_diametro_ped = 0
   ELSE
      LET p_diametro_ped = p_diametro
   END IF

   IF p_comprimento IS NULL THEN
      LET p_comprimento_ped = 0
   ELSE
      LET p_comprimento_ped = p_comprimento
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------Fim do Programa------------------------------#