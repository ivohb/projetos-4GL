#------------------------------------------------------------------------------#
# OBJETIVO: APONTAMENTO AUTOMÁTICO DE PRODUÇÃO                                 #
# DATA....: 08/08/2008                                                         #
#------------------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_ies_bobina         SMALLINT,
          p_qtd_integer        INTEGER,
          p_dat_prod           DATE,
          p_ondu               CHAR(01),
          p_flag               CHAR(01),
          p_retorno            SMALLINT,
          p_count              INTEGER,
          p_status             SMALLINT,
          p_ind                SMALLINT,
          p_index              SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_transf_refug       CHAR(01),
          sql_stmt             CHAR(900),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_houve_erro         SMALLINT,
          p_caminho            CHAR(080)

   DEFINE p_statusregistro     LIKE apont_papel_885.statusregistro,
          p_cod_item_refugo    LIKE parametros_885.cod_item_refugo,
          p_cod_item_sucata    LIKE parametros_885.cod_item_sucata,
          p_cod_item_retrab    LIKE parametros_885.cod_item_retrab,
          p_num_lote_sucata    LIKE parametros_885.num_lote_sucata,
          p_num_lote_refugo    LIKE parametros_885.num_lote_refugo,
          p_num_lote_retrab    LIKE parametros_885.num_lote_retrab,
          p_oper_sai_tp_refugo LIKE parametros_885.oper_sai_tp_refugo,
          p_oper_ent_tp_refugo LIKE parametros_885.oper_ent_tp_refugo,
          p_num_lote_impurezas LIKE parametros_885.num_lote_impurezas,
          p_msg                LIKE apont_erro_885.mensagem,
          p_num_transac_normal LIKE estoque_trans.num_transac,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_parametros         LIKE par_pcp.parametros,
          p_saldo_zero         LIKE estoque_lote.qtd_saldo,
          p_qtd_ordem          LIKE ordens.qtd_planej,
          p_qtd_transf         LIKE ordens.qtd_planej,
          p_qtd_aux            LIKE ordens.qtd_boas,
          p_item_ant           LIKE item.cod_item,
          p_qtd_lote           LIKE estoque_lote.qtd_saldo,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_item_apon      LIKE item.cod_item,
          p_qtd_a_apontar      LIKE ord_oper.qtd_boas,
          p_cod_tip_movto      LIKE apo_oper.cod_tip_movto,
          p_qtd_ant            LIKE ordens.qtd_boas,
          p_sequencia          LIKE apont_papel_885.numsequencia,
          p_num_seq_cons       LIKE cons_insumo_885.numsequencia,
          p_num_sequencia      LIKE cons_insumo_885.numsequencia,
          p_qtd_consumo        LIKE estoque_lote.qtd_saldo,
          p_num_seq_pedido     LIKE ped_itens.num_sequencia,
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
          p_cod_operac         LIKE ord_oper.cod_operac,
          p_ies_refugo         LIKE cons_insumo_885.iesrefugo,
          p_cod_prod           LIKE ordens.cod_item,
          p_cod_chapa          LIKE ordens.cod_item,
          p_area_livre         LIKE par_cst.area_livre,
          p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_ies_apontado       LIKE desc_nat_oper_885.ies_apontado,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_mcg_empresa        LIKE mcg_filial.empresa,
          p_mcg_filial         LIKE mcg_filial.filial,
          p_cod_roteiro        LIKE ordens.cod_roteiro,
          p_num_altern_roteiro LIKE ordens.num_altern_roteiro,
          p_cod_local          LIKE estoque_lote.cod_local,
          p_cod_local_refug    LIKE estoque_lote.cod_local,
          p_cod_local_sucat    LIKE estoque_lote.cod_local,
          p_cod_local_retrab   LIKE estoque_lote.cod_local,
          p_cod_ferramenta     LIKE consumo_fer.cod_ferramenta,
          p_parametro          LIKE consumo.parametro,
          p_cod_grupo_item     LIKE item_vdp.cod_grupo_item,
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
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
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
          p_num_versao         LIKE frete_roma_885.num_versao,
          p_num_processo       LIKE apo_oper.num_processo,
          p_ies_situa          LIKE ordens.ies_situa,
          p_ies_situa_orig     LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest     LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig     LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest     LIKE estoque_trans.cod_local_est_dest,
          p_num_transac_orig   LIKE estoque_trans.num_transac,
          p_pri_num_transac    LIKE estoque_trans.num_transac,
          p_num_transac_o      LIKE estoque_lote.num_transac,
          p_num_transac_0      LIKE estoque_lote.num_transac,
          p_dat_inicio         LIKE ord_oper.dat_inicio,
          p_ies_forca_apont    LIKE item_man.ies_forca_apont,
          p_cod_cent_cust      LIKE ord_oper.cod_cent_cust,
          p_num_seq_reg        LIKE cfp_apms.num_seq_registro,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_cod_maquina        LIKE apont_trim_885.codmaquina,
          p_cod_local_insp     LIKE item.cod_local_insp,
          p_num_transac        LIKE estoque_lote.num_transac,
          p_ctr_estoque        LIKE item.ies_ctr_estoque,
          p_ctr_lote           LIKE item.ies_ctr_lote,
          p_sobre_baixa        LIKE item_man.ies_sofre_baixa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_tip_trim           LIKE empresas_885.tip_trim,
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
          p_largura            LIKE apont_papel_885.largura,
          p_altura             LIKE apont_papel_885.tubete,
          p_diametro           LIKE apont_papel_885.diametro,
          p_comprimento        LIKE apont_papel_885.comprimento,
          p_gramatura          LIKE gramatura_885.gramatura,
          p_largura_ped        LIKE apont_papel_885.largura,
          p_altura_ped         LIKE apont_papel_885.tubete,
          p_diametro_ped       LIKE apont_papel_885.diametro,
          p_comprimento_ped    LIKE apont_papel_885.comprimento,
          p_num_trans_lote     LIKE estoque_lote.num_transac,
          p_num_trans_ender    LIKE estoque_lote_ender.num_transac,
          p_num_lote_cons      LIKE estoque_lote.num_lote,
          p_cod_item_pai       LIKE item.cod_item,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_saida          LIKE necessidades.qtd_saida,
          p_num_neces          LIKE necessidades.num_neces,
          p_qtd_liberada       LIKE estoque.qtd_liberada,
          p_qtd_impedida       LIKE estoque.qtd_impedida,
          p_qtd_rejeitada      LIKE estoque.qtd_rejeitada,
          p_qtd_lib_excep      LIKE estoque.qtd_lib_excep,
          p_dat_ult_entrada    LIKE estoque.dat_ult_entrada,
          p_dat_ult_saida      LIKE estoque.dat_ult_saida
          
          
   DEFINE p_tem_ficha          SMALLINT,
          p_ies_proces         CHAR(01),
          p_ies_apon           CHAR(01),
          p_dim                CHAR(10),
          p_trocou_op          SMALLINT,
          p_saldo_txt          CHAR(23),
          p_saldo_tx2          CHAR(11),
          p_pes_prod           DECIMAL(10,5),
          p_ies_onduladeira    CHAR(01),
          p_baixou_mat         SMALLINT,
          p_tipo_processo      INTEGER,
          p_ies_chapa          SMALLINT,
          p_cod_oper           CHAR(01),
          p_criticou           SMALLINT,
          p_ies_apara          CHAR(01),
          p_numpedido          CHAR(6),
          p_cod_status         CHAR(01),
          p_ies_par_cst        CHAR(01),
          p_grava_oplote       CHAR(01),
          p_carac              CHAR(01),
          p_rastreia           CHAR(01),
          p_baixa_retrab       SMALLINT,
          p_hor_prod           CHAR(10),
          p_dat_char           CHAR(23),
          p_sem_estoque        SMALLINT,
          p_cod_registro       INTEGER,
          p_foi_baixado        CHAR(01),
          p_qtd_erro_inter     DECIMAL(6,0),
          p_qtd_erro_logix     DECIMAL(6,0),
          p_qtd_apontado       DECIMAL(6,0),
          p_consu_apontado     DECIMAL(6,0),
          p_consu_criticado    DECIMAL(6,0),
          p_time               DATETIME HOUR TO SECOND,
          p_date_time          DATETIME YEAR TO SECOND,
          p_qtd_segundo        INTEGER,
          p_dat_ini            DATETIME YEAR TO SECOND,
          p_dat_fim            DATETIME YEAR TO SECOND,
          p_dat_hor            DATETIME YEAR TO SECOND
          

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
          p_ord_oper           RECORD LIKE ord_oper.*
          
   DEFINE p_aen              RECORD 
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
   END RECORD

   DEFINE p_consu           RECORD 
          cod_empresa       LIKE cons_insumo_885.codempresa,
          num_sequencia     LIKE cons_insumo_885.numsequencia,
          num_ordem         LIKE cons_insumo_885.numordem,
          cod_item          LIKE cons_insumo_885.coditem,
          num_lote          LIKE cons_insumo_885.numlote,
          codmaqpapel       LIKE cons_insumo_885.codmaqpapel,
          qtd_consumida     LIKE cons_insumo_885.qtdconsumida,
          dat_consumo       LIKE cons_insumo_885.datconsumo,
          qtd_refugada      LIKE cons_insumo_885.qtdrefugada,
          cod_estorno       LIKE cons_insumo_885.estorno,
          ies_refugo        LIKE cons_insumo_885.iesrefugo,
          cod_itemrefugo    LIKE cons_insumo_885.coditemrefugo,
          num_loterefugo    LIKE cons_insumo_885.numloterefugo
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol0828-05.10.14' 

   WHENEVER ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 60
      DEFER INTERRUPT
   WHENEVER ERROR STOP

   LET p_caminho = log140_procura_caminho('pol0828.iem')

  CALL log001_acessa_usuario("VDP","LIC_LIB")
        RETURNING p_status, p_cod_empresa, p_user

   #LET p_status = 0
   #LET p_cod_empresa = 'O2'
   #LET p_user = 'logix'

  IF p_status = 0  THEN
     CALL pol0828_controle()
     UPDATE proces_0828_885 SET ies_proces = 'N'
     CLOSE WINDOW w_pol0828
  END IF

END MAIN       


#--------------------------#
FUNCTION pol0828_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   #WHENEVER ERROR CONTINUE

   LET p_qtd_erro_inter = 0   
   LET p_qtd_apontado = 0   
   LET p_consu_criticado = 0
   LET p_consu_apontado = 0
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0828") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0828 AT 4,5 WITH FORM p_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_qtd_erro_inter TO qtd_erro_inter
   DISPLAY p_qtd_apontado TO qtd_apontado
   DISPLAY p_consu_criticado TO consu_criticado
   DISPLAY p_consu_apontado TO consu_apontado
   
   LET p_msg = NULL

   IF pol0828_le_parametros() THEN
      CALL pol0828_deleta_erros()
   END IF

   IF p_msg IS NOT NULL THEN
      INSERT INTO apont_erro_885 
       VALUES(p_cod_empresa,0,0,p_msg)
      RETURN
   END IF

   LET p_ies_apon = 'P'
   
   IF NOT pol0828_importa_apont() THEN
      CALL pol0828_grava_erro() RETURNING p_status
   END IF

   {LET p_ies_apon = 'C'
   
   IF NOT pol0828_importa_consumo() THEN
      CALL pol0828_grava_erro() RETURNING p_status
   END IF}

   
END FUNCTION

#-----------------------------#
FUNCTION pol0828_prende_man()
#-----------------------------#

   LOCK TABLE man_apont_912 IN EXCLUSIVE MODE
 
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') BLOQUEANDO MAN_APONT_912'
      LET p_sequencia = 0
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol0828_importa_apont()
#------------------------------#

   UPDATE apont_papel_885
      SET largura     = 0,
          diametro    = 0,
          tubete      = 0,
          comprimento = 0
    WHERE codempresa = p_cod_empresa
      AND statusregistro IN ('0','1','2')
      AND largura IS NULL
      AND diametro IS NULL
      AND tubete IS NULL
      AND comprimento IS NULL

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO DIMENSIONAIS'
      RETURN FALSE
   END IF                                           

   INITIALIZE p_man TO NULL
   CALL log085_transacao("BEGIN")  

   DECLARE cq_elimina CURSOR WITH HOLD FOR
    SELECT numsequencia,
           coditem,
           numordem,
           codmaquina,
           datproducao,
           pesobalanca,
           numlote,
           largura,
           tubete,
           diametro,
           tipmovto
      FROM apont_papel_885
     WHERE codempresa = p_cod_empresa
       AND estorno    = 0     
       AND statusregistro IN ('0','2')

   FOREACH cq_elimina INTO
           p_man.num_seq_apont,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_man.qtd_boas,
           p_man.lote,
           p_man.largura,
           p_man.altura,
           p_man.diametro,
           p_man.tip_movto

   # Refresh de tela
   #lds CALL LOG_refresh_display()	

   
      IF sqlca.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO APONTAMENO C/ ESTORNO'
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF                                           
      
      DISPLAY p_man.ordem_producao TO num_ordem
            
      DECLARE cq_repetidos CURSOR FOR
       SELECT numsequencia
         FROM apont_papel_885
        WHERE codempresa     = p_cod_empresa
          AND coditem        = p_man.item
          AND numordem       = p_man.ordem_producao
          AND codmaquina     = p_man.cod_recur
          AND datproducao    = p_dat_ini
          AND numlote        = p_man.lote
          AND largura        = p_man.largura
          AND tubete         = p_man.altura
          AND diametro       = p_man.diametro
          AND pesobalanca    = p_man.qtd_boas
          AND tipmovto       = p_man.tip_movto
          AND estorno        = 1
          AND StatusRegistro IN ('0','2')
      
      FOREACH cq_repetidos INTO p_num_seq_apont

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	         
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REGISTROS C/ ESTORNO'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF         
         
         UPDATE apont_papel_885
            SET statusregistro = 9
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_man.num_seq_apont
      
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO APONTAMENO C/ ESTORNO'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF         

         UPDATE apont_papel_885
            SET statusregistro = 9
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
   
   DECLARE cq_op CURSOR WITH HOLD FOR
    SELECT numsequencia,
           codempresa,
           coditem,
           numordem,
           codmaquina,
           datproducao,
           #(datproducao + tempoproducao UNITS MINUTE),
           datproducao,
           pesobalanca,
           tipmovto,
           numlote,
           largura,
           diametro,
           tubete,
           comprimento,
           estorno
      FROM apont_papel_885
     WHERE codempresa     = p_cod_empresa
       AND StatusRegistro IN ('0','2')
     ORDER BY numordem, numlote, numsequencia

   FOREACH cq_op INTO 
           p_man.num_seq_apont,
           p_man.empresa,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_dat_fim,
           p_man.qtd_boas,
           p_man.tip_movto,
           p_man.lote,
           p_man.largura,
           p_man.diametro,
           p_man.altura,
           p_man.comprimento,
           p_estorno

   # Refresh de tela
   #lds CALL LOG_refresh_display()	
           
      IF sqlca.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONTAMENTO CURSOR:CQ_OP'
         LET p_sequencia = 0
         RETURN FALSE
      END IF                                           
         
      IF p_estorno = 1 THEN
         LET p_man.qtd_boas = -p_man.qtd_boas
      END IF

      LET p_cod_operac = p_man.cod_recur
      
      LET p_sequencia = p_man.num_seq_apont

      DISPLAY p_man.ordem_producao TO num_ordem

      IF NOT pol0828_deleta_erro() THEN
         RETURN FALSE
      END IF

      LET p_statusRegistro = '2'
      LET p_criticou = FALSE

      CALL log085_transacao("BEGIN")  
         
      IF NOT pol0828_consiste_apont() THEN
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF

      IF NOT p_criticou THEN
         IF pol0828_insere_apont() THEN
            IF pol0828_processa_apont() THEN
               LET p_statusRegistro = '1'   
               LET p_qtd_apontado = p_qtd_apontado + 1
               DISPLAY p_qtd_apontado TO qtd_apontado
            ELSE
               CALL log085_transacao("ROLLBACK")    
               CALL log085_transacao("BEGIN")         
               IF NOT pol0828_insere_erro() THEN
                  RETURN FALSE
               END IF
            END IF
         ELSE
            IF NOT pol0828_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF

      IF NOT pol0828_grava_apont_papel() THEN
         RETURN FALSE
      END IF

      CALL log085_transacao("COMMIT")         

      INITIALIZE p_man TO NULL
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0828_deleta_erro()
#----------------------------#

   DELETE FROM apont_erro_885
    WHERE codempresa   = p_cod_empresa
      AND numordem     = p_man.ordem_producao
      AND numsequencia = p_sequencia

   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO APONT_ERRO_885'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0828_consiste_apont()
#-------------------------------#

   SELECT num_docum,
          cod_item,
          ies_situa
     INTO p_num_docum,
          p_cod_item,
          p_ies_situa
     FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS = 100 THEN
      LET p_msg = 'ORDEM DE PRODUCAO NAO EXISTE ', p_man.ordem_producao
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ORDENS:NUM.DOCUM'
         RETURN FALSE
      ELSE
         CALL pol0828_pega_pedido()
         LET p_man.num_pedido = p_num_pedido
         LET p_man.num_seq_pedido = p_num_seq_pedido
      END IF
   END IF
   
   IF p_ies_situa <> '4' THEN
      IF p_ies_situa = '5' THEN
         LET p_msg = 'OF ESTA ENCERRADA'
      ELSE
         IF p_ies_situa = '9' THEN
            LET p_msg = 'OF ESTA CANCELADA'
         ELSE
            LET p_msg = 'OF NAO ESTA LIBERADA - STATUS:', p_ies_situa
         END IF
      END IF
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.lote IS NULL OR p_man.lote = ' ' THEN
      LET p_msg = 'NUM LOTE ESTA NULO '
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   LET p_num_lote = p_man.lote

   IF p_man.num_pedido IS NULL OR p_man.lote = ' ' THEN
      LET p_msg = 'NUM PEDIDO INVALIDO '
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT tipo_processo
        INTO p_tipo_processo
        FROM tipo_pedido_885
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_man.num_pedido         
      
      IF STATUS = 100 THEN
         LET p_msg = 'PEDIDO NAO ENCONTRADO NA TAB TIPO_PEDIDO_885'
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB TIPO_PEDIDO_885'
            RETURN FALSE
         END IF
      END IF
   END IF   

   IF p_man.num_seq_apont IS NULL THEN
      LET p_msg = 'Nº SEQUENCIA ESTA NULA ',p_man.num_seq_apont
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF      

   SELECT num_seq_apont
     FROM man_apont_hist_912
    WHERE empresa       = p_cod_empresa
      AND num_seq_apont = p_man.num_seq_apont

   IF STATUS = 100 THEN
   ELSE
      IF STATUS = 0 THEN
         LET p_msg = 'Nº SEQUENCIA JA ENVIADA AO LOGIX ',p_man.num_seq_apont
         IF NOT pol0828_insere_erro() THEN
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
      IF p_man.tip_movto <> 'S' THEN
       SELECT COUNT(numsequencia)
         INTO p_count
         FROM apont_papel_885
        WHERE codempresa     = p_man.empresa
          AND coditem        = p_man.item
          AND numordem       = p_man.ordem_producao
          AND codmaquina     = p_man.cod_recur
          AND datproducao    = p_dat_ini
          AND numlote        = p_man.lote
          AND largura        = p_man.largura
          AND tubete         = p_man.altura
          AND diametro       = p_man.diametro
          AND tipmovto       = p_man.tip_movto
          AND pesobalanca    = -p_man.qtd_boas
          AND estorno        = 0
          AND StatusRegistro = '1'
      ELSE
       SELECT COUNT(numsequencia)
         INTO p_count
         FROM apont_papel_885
        WHERE codempresa     = p_man.empresa
          AND coditem        = p_man.item
          AND numordem       = p_man.ordem_producao
          AND codmaquina     = p_man.cod_recur
          AND datproducao    = p_dat_ini
          AND numlote        = p_man.lote
          AND tipmovto       = p_man.tip_movto
          AND pesobalanca    = -p_man.qtd_boas
          AND estorno        = 0
          AND StatusRegistro = '1'
      END IF
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_PAPEL_885'
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN
         LET p_msg = 'ESTORNO DE APONTAMENTO NAO ENVIADO AO LOGIX'
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF         
   END IF
   
   IF p_man.cod_recur IS NULL OR p_man.cod_recur = 0 THEN

       LET p_msg = 'CODIGO DA MAQUINA NAO INVALIDO ', p_man.cod_recur
       IF NOT pol0828_insere_erro() THEN
          RETURN FALSE
       END IF

   ELSE

			 SELECT cod_recur,
			        cod_compon,
			        cod_operac,
			        cod_arranjo,
			        cod_cent_cust,
			        cod_cent_trab
			   INTO p_man.cod_recur,
			        p_man.eqpto,
			        p_man.operacao,
			        p_cod_arranjo,
			        p_cod_cent_cust,
			        p_cod_cent_trab
			   FROM de_para_maq_885
			  WHERE cod_empresa  = p_cod_empresa
			    AND cod_maq_trim = p_man.cod_recur
			    
			 IF STATUS = 100 THEN
			    LET p_msg = 'MAQUINA NAO CADASTRADA NO DE-PARA ', p_man.cod_recur
			    IF NOT pol0828_insere_erro() THEN
			       RETURN FALSE
			    END IF
			 ELSE
			    IF STATUS <> 0 THEN
			       LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB DE_PARA_MAQ'
			       RETURN FALSE
			    END IF
			 END IF

   END IF   

   IF NOT pol0828_consiste_turno() THEN
      RETURN FALSE
   END IF
   
   IF p_man.tip_movto MATCHES "[FRESP]" THEN
   ELSE
      LET p_msg = 'TIPO DE MOVIMENTO INVALIDDO - ', p_man.tip_movto
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF p_man.qtd_boas IS NULL OR p_man.qtd_boas = 0 THEN
		  LET p_msg = 'QUANTIDADE A APONTAR ESTA NULA OU COM ZERO'
		  IF NOT pol0828_insere_erro() THEN
		     RETURN FALSE
		  END IF
	 END IF

   IF p_dat_ini IS NULL THEN
      LET p_msg = 'DATA INICIAL DA PRODUCAO ESTA NULA'
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_fim IS NULL THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO NULA'
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_ini IS NOT NULL AND p_dat_fim IS NOT NULL THEN
      CALL pol0828_consiste_datas()
   END IF

   IF p_man.item <> p_cod_item THEN
      LET p_msg = 'ITEM DIFERE DO ITEM DA ORDEM ', p_man.item
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   LET p_cod_prod = p_man.item
   
   IF NOT pol0828_checa_dimensional() THEN
      RETURN FALSE
   END IF

   IF p_man.tip_movto <> 'S' THEN
      IF NOT pol0828_consiste_dimen() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT p_criticou THEN   
      SELECT ies_apontamento
        INTO p_ies_apontamento
		    FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.ordem_producao
	       AND cod_operac     = p_man.operacao

      IF STATUS = 100 THEN
         IF NOT pol0828_insere_operacao() THEN
            RETURN FALSE
         END IF
         LET p_ies_apontamento = 'S'
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO ORD_OPER'
            RETURN FALSE
         END IF
      END IF
      IF p_ies_apontamento = 'N' THEN
         LET p_msg = 'OPERACAO ENVIADA NAO E APONTAVEL - ', p_man.cod_recur
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0828_consiste_qtds() THEN
            RETURN FALSE
         END IF
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
      IF NOT pol0828_consiste_qtd_apont('T') THEN
         RETURN FALSE
      END IF
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_man.item
      
   IF STATUS = 100 THEN
      LET p_msg = 'ITEM ENVIADO NAO CADASTRADO ', p_man.item
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM'
         RETURN FALSE
      END IF
   END IF

   IF (p_man.qtd_boas < 0 AND p_ies_oper_final = 'S') OR 
      (p_man.qtd_boas < 0 AND p_man.tip_movto MATCHES '[RS]') THEN

      LET p_qtd_baixar     = p_man.qtd_boas * (-1)

      IF p_man.tip_movto MATCHES '[FE]' THEN
         IF NOT pega_dimen() THEN
            RETURN FALSE
         END IF
         LET p_cod_local_orig = p_cod_local_estoq
         LET p_cod_prod       = p_man.item
         LET p_num_lote       = p_man.lote
      ELSE
         LET p_largura_ped     = 0
         LET p_altura_ped      = 0
         LET p_diametro_ped    = 0
         LET p_comprimento_ped = 0
         IF p_man.tip_movto = 'R' THEN
            LET p_cod_prod        = p_cod_item_refugo
            LET p_cod_local_orig  = p_cod_local_refug
            LET p_num_lote        = p_num_lote_refugo
         ELSE
            LET p_cod_prod        = p_cod_item_sucata
            LET p_cod_local_orig  = p_cod_local_sucat
            LET p_num_lote        = p_num_lote_sucata
         END IF         
      END IF
        
      IF NOT pol0828_cheka_estoque() THEN
         RETURN FALSE
      END IF
      
      IF p_sem_estoque THEN
         LET p_msg = 'IT:',p_cod_prod, 'LOTE:',p_num_lote
         LET p_msg = p_msg CLIPPED, ' - S/ESTOQUE SUFICIENE P/ESTORNAR'
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF      

   END IF

   LET p_num_lote = p_man.lote

   IF NOT p_criticou THEN
      SELECT COUNT(ies_oper_final)
        INTO p_count
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.ordem_producao
	       AND ies_oper_final = 'S'
      
      IF p_count = 0 THEN
         LET p_msg = 'ORDEM DE PRODUCAO S/ A OPERACAO FINAL'
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
       
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0828_consiste_turno()
#--------------------------------#

   DEFINE p_minutos    SMALLINT,
          p_minu_ant   SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04)
   
   LET p_hora = EXTEND(p_dat_ini, HOUR TO MINUTE)
   LET p_minutos = (p_hora[1,2] * 60) + p_hora[4,5]
   LET p_minu_ant = p_minutos

   IF STATUS <> 0 THEN
      LET p_msg = 'HORA INICIO INVALIDA'
      CALL pol0828_insere_erro() RETURNING p_status
      RETURN FALSE
   END IF

   LET p_msg = 'HORA INICIO APONTAMENTO FORA DOS TURNOS LOGIX'
   
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
      
      LET p_minutos = p_minu_ant
      
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
FUNCTION pol0828_consiste_datas()
#--------------------------------#

   LET p_man.dat_ini_producao = EXTEND(p_dat_ini, YEAR TO DAY)
   LET p_man.dat_fim_producao = EXTEND(p_dat_fim, YEAR TO DAY)
   LET p_man.hor_inicial = EXTEND(p_dat_ini, HOUR TO SECOND)
   LET p_man.hor_fim     = EXTEND(p_dat_fim, HOUR TO SECOND)

   IF p_man.dat_ini_producao > p_man.dat_fim_producao THEN
      LET p_msg = 'DATA INICIAL DA PRODUCAO > DATA FINAL '
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.dat_fim_producao > TODAY THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO > DATA ATUAL'
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_man THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL'
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF      

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_sup THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL'
         IF NOT pol0828_insere_erro() THEN
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
   END IF
         
END FUNCTION

#---------------------------------#
FUNCTION pol0828_insere_operacao()
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
      LET p_msg = 'ORDEM SEM AS OPERACOES DE PRODUCAO '
      IF NOT pol0828_insere_erro() THEN
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

   LET p_ord_oper.cod_empresa = p_cod_emp_ofic

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
FUNCTION pol0828_consiste_qtds()
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
		  LET p_msg = 'OPERACAO NAO PREVISTA PARA A ORDEM PROD'
		  IF NOT pol0828_insere_erro() THEN
		     RETURN FALSE
		  END IF
   ELSE
	    IF STATUS <> 0 THEN
		     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_OPER'
		     RETURN FALSE
      END IF
   END IF                                           

   IF p_man.qtd_boas < 0 THEN
      LET p_qtd_a_apontar = p_man.qtd_boas * (-1)
      IF p_man.tip_movto MATCHES '[FE]' AND p_qtd_a_apontar > p_qtd_boas OR
         p_man.tip_movto = 'R' AND p_qtd_a_apontar > p_qtd_refug OR
         p_man.tip_movto = 'S' AND p_qtd_a_apontar > p_qtd_sucata THEN
         LET p_msg = 'QTD A ESTORNOAR > QTD JA APONTADAS'
         IF NOT pol0828_insere_erro() THEN
	          RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------------------#
FUNCTION pol0828_le_item_ctr_grade(p_cod_item)
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
     WHERE cod_empresa   = p_cod_empresa
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
FUNCTION pol0828_checa_dimensional()
#----------------------------------#
  
   IF NOT pol0828_le_item_ctr_grade(p_cod_prod) THEN
      RETURN FALSE
   END IF

   IF p_ies_largura     = 'N' AND
      p_ies_altura      = 'N' AND
      p_ies_diametro    = 'N' AND
      p_ies_comprimento = 'N' THEN
      RETURN TRUE
   END IF

   SELECT largura,
          diametro,
          tubete
     INTO p_largura_ped,
          p_diametro_ped,
          p_altura_ped
     FROM item_bobina_885        
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_num_pedido
      AND num_sequencia = p_num_seq_pedido
 
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DIMENSIONAL DO PEDIDO'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0828_consiste_dimen()
#--------------------------------#

   LET p_dim = p_largura_ped
   
   IF p_ies_largura = 'S' THEN
      IF p_man.largura IS NULL THEN
            LET p_msg = 'DIMENSIONAL LARGURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.largura
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_man.largura <> p_largura_ped THEN
            LET p_msg = 'DIMENSIONAL LARGURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.largura
            IF NOT pol0828_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF

   LET p_dim = p_altura_ped

   IF p_ies_altura = 'S' THEN
      IF p_man.altura IS NULL THEN
         LET p_msg = 'DIMENSIONAL ALTURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.altura
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_man.altura <> p_altura_ped THEN
         LET p_msg = 'DIMENSIONAL ALTURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.altura
            IF NOT pol0828_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF

   LET p_dim = p_diametro_ped

   IF p_ies_diametro = 'S' THEN
      IF p_man.diametro IS NULL THEN
         LET p_msg = 'DIMENSIONAL DIAMETRO NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.diametro
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_man.diametro <> p_diametro_ped THEN
         LET p_msg = 'DIMENSIONAL DIAMETRO NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.diametro
            IF NOT pol0828_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF

   LET p_dim = p_comprimento_ped

   IF p_ies_comprimento = 'S' THEN
      IF p_man.comprimento IS NULL THEN
         LET p_msg = 'DIMENSIONAL COMPRIMEN NAO ENVIADO PELO TRIM - ', p_dim
         IF NOT pol0828_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         IF p_man.comprimento <> p_comprimento_ped THEN
            LET p_msg = 'DIMENSIONAL COMPRIMENTO DIFERENTE DO PEDIDO:',p_dim
            IF NOT pol0828_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION


#-----------------------------#
 FUNCTION pol0828_insere_erro()
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
FUNCTION pol0828_insere_apont()
#-----------------------------#

   IF p_man.qtd_refugo IS NULL THEN
      LET p_man.qtd_refugo = 0
   END IF

   LET p_man.dat_atualiz  = CURRENT YEAR TO SECOND
   LET p_man.nom_prog     = 'pol0828'
   LET p_man.nom_usuario  = p_user
   LET p_man.num_versao   = 1
   LET p_man.versao_atual = 'S'
   LET p_man.cod_status   = '0'

   INSERT INTO man_apont_912
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA MAN_APONT_912'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol0828_grava_apont_papel()
#----------------------------------#

   UPDATE apont_papel_885
      SET StatusRegistro = p_statusRegistro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_sequencia
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A APONT_PAPEL_885'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0828_le_parametros()
#------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         LET p_msg = 'ERRO(',STATUS,')LENDO EMPRESAS_885'
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO(',STATUS,')LENDO EMPRESAS_885'
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
      END IF
   END IF

   SELECT ies_proces
     INTO p_ies_proces
     FROM proces_0828_885
   
   IF STATUS = 100 THEN
      INSERT INTO proces_0828_885
       VALUES('S')
   ELSE
      IF STATUS = 0 THEN
         IF p_ies_proces = 'N' THEN
            UPDATE proces_0828_885
               SET ies_proces = 'S'
         ELSE
            MESSAGE 'Aguarde!...processando'
            #SLEEP 180
            RETURN TRUE
         END IF
      ELSE
         LET p_msg = 'ERRO(',STATUS,')LENDO proces_0828_885'
         RETURN TRUE
      END IF
   END IF

   SELECT tip_trim
     INTO p_tip_trim
     FROM empresas_885
    WHERE cod_emp_gerencial = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO EMPRESAS_885'
      RETURN TRUE
   END IF

   SELECT cod_item_refugo,
          num_lote_refugo,
          cod_item_sucata,
          num_lote_sucata,
          cod_item_retrab,
          num_lote_retrab,
          oper_sai_tp_refugo,
          oper_ent_tp_refugo,
          num_lote_impurezas
     INTO p_cod_item_refugo,
          p_num_lote_refugo,
          p_cod_item_sucata,          
          p_num_lote_sucata,
          p_cod_item_retrab,
          p_num_lote_retrab,
          p_oper_sai_tp_refugo,
          p_oper_ent_tp_refugo,
          p_num_lote_impurezas
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO PARAMETROS_885'
      RETURN FALSE
   END IF

   DELETE FROM apont_erro_885
    WHERE codempresa = p_cod_empresa
      AND (numordem   = 0 OR numordem IS NULL)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')DELETANDO ERROS CRITICOS'
      RETURN FALSE
   END IF
   
   SELECT cod_local_estoq
     INTO p_cod_local_refug
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refugo
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM REFUGO'
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_sucat
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_sucata
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM SUCATA'
      RETURN FALSE
   END IF

   SELECT cod_local_estoq
     INTO p_cod_local_retrab
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_retrab
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO ITEM RETRABALHO'
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

#-----------------------------#
FUNCTION pol0828_deleta_erros()
#-----------------------------#

   DELETE FROM apont_erro_885
    WHERE mensagem LIKE '%ERRO%'

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO APONT_ERRO_885'
      RETURN
   END IF

END FUNCTION

#--------------------------------#          
FUNCTION pol0828_processa_apont()
#--------------------------------#          

   INITIALIZE p_man, p_num_conta TO NULL
   
   DECLARE cq_apont CURSOR WITH HOLD FOR
    SELECT *
      FROM man_apont_912
     WHERE empresa      = p_cod_empresa
       AND versao_atual = 'S'

   FOREACH cq_apont INTO p_man.*
	
	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_APONT'
         LET p_sequencia = 0
         RETURN FALSE
      END IF                                           

      DISPLAY p_man.ordem_producao TO num_ordem
      
      LET p_dat_movto = p_man.dat_fim_producao

      LET p_retorno = FALSE

      LET p_num_lote = p_man.lote
      
      LET p_criticou = FALSE
      LET p_cod_status = 'A'

      IF pol0828_consiste_dados() THEN
         LET p_item_ant = p_man.item
         IF pol0828_aponta_op() THEN
            LET p_retorno = TRUE
         END IF
      END IF

      IF NOT pol0828_grava_man() THEN
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

#--------------------------------#
FUNCTION pol0828_consiste_dados()
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
      AND ies_situa   = '4'

   IF STATUS = 100 THEN
      LET p_msg = 'ORDEM DE PRODUCAO NAO EXISTE OU NAO ESTA LIBERADA'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORDENS'
         RETURN FALSE
      ELSE
         LET p_num_pedido = p_man.num_pedido
         IF NOT pol0828_le_desc_nat_oper_885() THEN
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

   IF STATUS = 100 THEN
      LET p_msg = 'ITEM NAO CADASTRADO'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM'
         RETURN FALSE
      END IF
   END IF                                           

   IF NOT pol0828_le_ord_oper() THEN
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

   IF NOT pol0828_consiste_qtd_apont('L') THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0828_le_ord_oper()
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


#------------------------------#
FUNCTION pol0828_le_gramatura()
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

#------------------------------#
FUNCTION pol0828_le_oper_orig()
#------------------------------#

   SELECT par_txt
     INTO p_cod_operacao
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND den_parametro = 'Operacao de Baixa de estoque itens orig.'

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO OPERACAO ORIGEM DE PARA'
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#------------------------------#
FUNCTION pol0828_le_oper_dest()
#------------------------------#

   SELECT par_txt
     INTO p_cod_operacao
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
	    AND den_parametro = 'Operacao de Baixa de estoque itens dest.'

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO OPERACAO DESTINO DE PARA'
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#-------------------------#
FUNCTION pol0828_de_para()
#-------------------------#

   IF p_ies_bobina THEN
      IF p_consu.cod_estorno = 1 THEN
         IF NOT pol0850_carrega_dimen() THEN
            RETURN FALSE
         END IF
      END IF
      IF p_consu.ies_refugo = 'N' THEN
         LET p_consu.qtd_refugada = p_consu.qtd_consumida
      END IF
   END IF

   IF NOT pol0828_depara_item() THEN
      RETURN FALSE
   END IF

	 LET p_cod_operacao = NULL
	 LET p_cod_prod  = p_consu.cod_item
	 LET p_num_lote  = p_consu.num_lote
	 LET p_cod_local = p_cod_local_baixa
   
   LET p_cod_empresa = p_cod_emp_ofic

   IF NOT pol0828_depara_item() THEN
      LET p_cod_empresa = p_cod_emp_ger
      RETURN FALSE
   END IF

   LET p_cod_empresa = p_cod_emp_ger

   IF p_consu.ies_refugo = 'S' THEN
      LET p_ies_bobina = FALSE
   END IF
   
   RETURN TRUE   

END FUNCTION

#------------------------------#
FUNCTION pol0850_carrega_dimen()
#------------------------------#

   INITIALIZE p_num_transac TO NULL
   
   DECLARE cq_dimen CURSOR FOR
    SELECT num_transac
      FROM estoque_trans
     WHERE cod_empresa   = p_cod_emp_ger
       AND cod_item      = p_consu.cod_item
       AND num_lote_dest = p_consu.num_lote
    
   FOREACH cq_dimen INTO p_num_transac
	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	

      EXIT FOREACH
   END FOREACH
   
   IF p_num_transac IS NULL THEN
      LET p_msg = 'Item:',p_consu.cod_item
      LET p_msg = p_msg CLIPPED, ' sem movimentacao de estoque'
      RETURN FALSE
   END IF
   
   SELECT largura,
          altura,
          diametro,
          comprimento
     INTO p_largura,
          p_altura,
          p_diametro,
          p_comprimento
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_emp_ger
      AND num_transac = p_num_transac
   
   IF STATUS <> 0 THEN
      LET p_msg = 'Item:',p_consu.cod_item
      LET p_msg = p_msg CLIPPED, ' sem movimentacao de estoque'
      RETURN FALSE
   END IF      
          
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0828_depara_item()
#------------------------------#

   IF NOT pol0828_le_oper_orig() THEN
      RETURN FALSE
   END IF   

   LET p_cod_local_baixa = p_cod_local
   LET p_qtd_baixar = p_consu.qtd_refugada
   
   IF p_consu.cod_estorno = 0 THEN
      LET p_cod_tip_movto = 'N'
   ELSE
      LET p_cod_tip_movto = 'R'
   END IF
   
   IF NOT pol0828_baixa_acessorios() THEN
      RETURN FALSE
   END IF

   LET p_pri_num_transac = p_num_transac_orig
   LET p_man.item = p_cod_prod

   IF NOT pol0828_le_oper_dest() THEN
      RETURN FALSE
   END IF   

   IF p_consu.ies_refugo = 'S' THEN
      LET p_cod_prod  = p_cod_item_refugo
      LET p_num_lote  = p_num_lote_refugo
      LET p_cod_local = p_cod_local_refug
   ELSE
      LET p_cod_prod  = p_cod_item_retrab
      #LET p_num_lote  = p_num_lote_retrab #Manter o mesmo lote da bobina
      LET p_cod_local = p_cod_local_retrab
   END IF
   
   LET p_cod_item_apon = p_cod_prod
   LET p_ies_situa = 'L'
   LET p_qtd_movto = p_consu.qtd_refugada
   LET p_ies_apon = 'P'
   CALL pol0828_seta_orig_dest()
   LET p_ies_apon = 'C'

   IF NOT pol0828_trata_fabricacao() THEN
      RETURN FALSE
   END IF

   IF NOT pol0828_insere_est_relac() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0828_baixa_acessorios()
#---------------------------------#

   IF p_qtd_baixar > 0 THEN
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
   
   IF NOT pol0828_baixa_estoque_lote() THEN
      RETURN FALSE
   END IF
      
   IF NOT pol0828_deleta_lote() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0828_baixa_estoque_lote()
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
		      #AND comprimento   = p_comprimento_ped
		      #AND largura       = p_largura_ped
		      #AND diametro      = p_diametro_ped
		      #AND altura        = p_altura_ped
   ELSE
		   SELECT *
		     INTO p_estoque_lote_ender.*
		     FROM estoque_lote_ender
		    WHERE cod_empresa   = p_cod_empresa
		      AND cod_item      = p_cod_prod
		      AND cod_local     = p_cod_local
		      AND num_lote        IS NULL
		      AND ies_situa_qtd = p_ies_situa
		      #AND comprimento   = p_comprimento_ped
		      #AND largura       = p_largura_ped
		      #AND diametro      = p_diametro_ped
		      #AND altura        = p_altura_ped
   END IF   
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER:BEL'  
      RETURN FALSE
   END IF  

   IF STATUS = 100 THEN
      LET p_estorno = TRUE
      LET p_num_lote_orig = p_num_lote
      IF NOT pol0828_insere_lote() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

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
   END IF
            
   IF STATUS <> 0 THEN
      LET p_msg = 'ITEM:',p_cod_prod CLIPPED,' S/ SDO NA ESTOQUE_LOTE/'
      LET p_msg = p_msg CLIPPED, p_num_lote
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

   LET p_num_lote_orig = p_num_lote
   
   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0828_grava_estoq_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0828_le_item_man()
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
FUNCTION pol0828_le_equipto(p_equipto)
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
         IF NOT pol0828_insere_erro() THEN
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
 FUNCTION pol0828_consiste_qtd_apont(p_ch)
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
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_OPER.QTD_PLANEJADA'
	    RETURN FALSE
   END IF

   IF p_ch = 'L' THEN
      RETURN TRUE
   END IF

   LET p_qtd_saldo_apon = p_qtd_planej - p_qtd_boas - p_qtd_refug - p_qtd_sucata

   IF p_man.tip_movto MATCHES '[FRES]' AND p_man.qtd_boas > 0 THEN
      IF p_ies_forca_apont MATCHES "[Ss]" THEN
      ELSE
         IF p_qtd_saldo_apon < p_man.qtd_boas THEN
    		    LET p_msg = 'QTD APONTAR > O SALDO DA ORDEM', p_man.item
    		 END IF
      END IF
   END IF
   
   IF p_man.qtd_boas < 0 THEN
      LET p_qtd_baixar = p_man.qtd_boas * (-1)
      IF p_man.tip_movto MATCHES '[FE]' THEN
         IF p_qtd_baixar > p_qtd_boas THEN
            LET p_msg = 'QTD A ESTORNAR > QTD JA APONTADAS'
         END IF
      ELSE
         IF p_man.tip_movto = 'R' THEN
            IF p_qtd_baixar > p_qtd_refug THEN
               LET p_msg = 'QTD A ESTORNAR > QTD REFUGOS APONTADOS'
            END IF
         ELSE
            IF p_man.tip_movto = 'S' THEN
               IF p_qtd_baixar > p_qtd_sucata THEN
                  LET p_msg = 'QTD A ESTORNAR > QTD SUCATAS APONTADOS'
               END IF
            END IF
         END IF
      END IF
   END IF

   IF p_msg IS NOT NULL THEN   
      IF NOT pol0828_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
      
END FUNCTION


#---------------------------#
FUNCTION pol0828_grava_man()
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
FUNCTION pol0828_aponta_op()
#---------------------------#

   LET p_transf_refug = 'N'

   IF NOT pol0828_grava_ordens() THEN
      RETURN FALSE
   END IF 

   IF p_man.tip_movto MATCHES "[FRES]" THEN
      IF p_ies_oper_final = "S"  OR p_man.tip_movto MATCHES '[RS]' THEN
         IF NOT pol0828_move_estoq() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF NOT pol0828_le_desc_nat_oper_885() THEN
      RETURN FALSE
   END IF

   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_ant = p_man.qtd_boas
   ELSE
      LET p_qtd_ant = -p_man.qtd_boas
   END IF
   
   IF p_pct_desc_valor > 0 THEN
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
   
   CALL pol0828_aponta_na_zero() RETURNING p_status
   
{   IF p_status AND p_qtd_transf > 0 THEN
      LET p_man.tip_movto = 'R'
      IF p_qtd_ant > 0 THEN
         LET p_man.qtd_boas = p_qtd_transf
      ELSE
         LET p_man.qtd_boas = -p_qtd_transf
      END IF
      LET p_transf_refug = 'S'
      CALL pol0828_aponta_na_zero() RETURNING p_status
   END IF
}

   LET p_cod_empresa  = p_cod_emp_ger
   LET p_man.qtd_boas = p_qtd_ant
   LET p_man.item     = p_item_ant
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0828_aponta_na_zero()
#--------------------------------#

   IF p_man.tip_movto MATCHES "[FERS]" THEN
      IF p_ies_oper_final = "S"  OR p_man.tip_movto MATCHES '[RS]' THEN
         IF p_man.tip_movto MATCHES "[RS]" THEN
            CALL pol0828_move_estoq() RETURNING p_status
         ELSE
            LET p_cod_oper = 'E'
            CALL pol0828_entrada_prod() RETURNING p_status
         END IF
      END IF
   END IF

   IF p_status THEN
      CALL pol0828_grava_ordens() RETURNING p_status
   END IF

   RETURN(p_status)

END FUNCTION

#------------------------------#
FUNCTION pol0828_grava_ordens()
#------------------------------#

   IF p_man.tip_movto MATCHES '[FRES]' THEN
      IF NOT pol0828_atualiza_ordens() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_boas < 0 THEN
      IF NOT pol0828_deleta_tabs(p_man.operacao, p_man.sequencia_operacao) THEN
         RETURN FALSE
      END IF
      LET p_cod_tip_movto = 'R'
   ELSE
      LET p_cod_tip_movto = 'N'
      IF NOT pol0828_insere_tabs(p_man.operacao, p_man.sequencia_operacao) THEN
         RETURN FALSE
      END IF
      IF p_parametros[128,128] = "S" THEN
         IF NOT pol0828_integra_min() THEN
            RETURN FALSE
          END IF
      END IF
   END IF   
  
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0828_atualiza_ordens()
#---------------------------------#

   LET p_qtd_boas = 0
   LET p_qtd_refug = 0
   LET p_qtd_sucata = 0
   
   IF p_man.tip_movto MATCHES '[FE]' THEN
      LET p_qtd_boas = p_man.qtd_boas
      LET p_cod_item_apon = p_man.item
   ELSE
      IF p_man.tip_movto = 'R' THEN
         LET p_qtd_refug = p_man.qtd_boas
         LET p_cod_item_apon = p_cod_item_refugo
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

   IF p_man.sequencia_operacao > 1 THEN
      LET p_num_seq_ant = p_man.sequencia_operacao - 1
      IF NOT pol0828_nao_apontaveis() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ies_oper_final = 'S' THEN
      LET p_num_seq_ant = p_man.sequencia_operacao + 1
      IF NOT pol0828_nao_apontaveis() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_tipo_processo = 1 THEN
      UPDATE ped_itens
         SET qtd_pecas_atend = qtd_pecas_atend + p_man.qtd_boas
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_man.num_pedido         
         AND num_sequencia = p_man.num_seq_pedido     

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO PED_ITENS:PÇS ATENDIDAS'
         RETURN FALSE
      END IF
             
   END IF
   
   IF p_man.tip_movto MATCHES '[FE]' THEN
   ELSE
      LET p_qtd_boas = 0
   END IF
         
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0828_nao_apontaveis()
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
      ELSE #Marcelo pediu p/ não apontar apo_oper e suas parceiras - 27/07/09
         {IF p_man.qtd_boas < 0 THEN
            IF NOT pol0828_deleta_tabs(p_operacao,p_num_seq_ant) THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_cod_tip_movto = 'N'
            IF NOT pol0828_insere_tabs(p_operacao,p_num_seq_ant) THEN
               RETURN FALSE
            END IF
         END IF}
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
FUNCTION pol0828_deleta_tabs(p_cod_oper, p_num_seq)
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
FUNCTION pol0828_insere_tabs(p_cod_oper, p_num_seq)
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
  
  IF p_apo_oper.qtd_horas IS NULL THEN
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
  IF  p_cfp_aptm.hor_tot_periodo IS NULL THEN
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
 FUNCTION pol0828_integra_min() 
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
       IF NOT pol0828_atualiza_min(p_man.eqpto) THEN
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
       IF NOT pol0828_atualiza_min(p_man.ferramenta) THEN
        RETURN FALSE
      END IF
    END IF

    RETURN TRUE

END FUNCTION

#------------------------------------------#
 FUNCTION pol0828_atualiza_min(l_cod_equip)
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
FUNCTION pol0828_move_estoq()
#----------------------------#

   IF p_man.tip_movto = 'S' THEN
      IF NOT pol0828_grava_sucata() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0828_le_item() THEN
         RETURN FALSE
      END IF

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM MANUFATURA - OP:',p_man.ordem_producao
         RETURN FALSE
      END IF

      IF p_ies_ctr_estoque <> 'S' THEN
         RETURN TRUE
      END IF

      LET p_flag = '2'
   
      LET p_cod_oper = 'E'
      IF NOT pol0828_entrada_prod() THEN
         RETURN FALSE
      END IF
      IF p_man.tip_movto = 'R' THEN
         IF NOT pol0828_transf_refugo() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0828_transf_refugo()
#-------------------------------#
      
   LET p_cod_oper = 'B'
   LET p_num_lote_orig  = p_num_lote
   LET p_cod_local_orig = p_cod_local
   LET p_ies_situa_orig = 'R'
   LET p_num_lote_dest  = NULL
   LET p_cod_local_dest = NULL
   LET p_ies_situa_dest = NULL
   LET p_cod_operacao = p_oper_sai_tp_refugo

   IF p_man.qtd_boas < 0 THEN
      LET p_qtd_movto = p_man.qtd_boas * (-1)
   ELSE
      LET p_qtd_movto = p_man.qtd_boas
   END IF

   IF NOT pol0828_grava_estoq_trans() THEN
      RETURN FALSE
   END IF

   LET p_pri_num_transac = p_num_transac_orig
   LET p_cod_item = p_man.item
   LET p_man.item = p_cod_item_apon
   LET p_num_lote_op = p_num_lote
   LET p_num_lote = p_num_lote_refugo
   LET p_qtd_ant = p_man.qtd_boas
	      
	 IF NOT pol0828_le_item() THEN
	    RETURN FALSE
	 END IF
	      
	 LET p_flag = '3'
   LET p_cod_operacao = p_oper_ent_tp_refugo
	 
   LET p_cod_oper = 'E'
	 IF NOT pol0828_entrada_prod() THEN
	    RETURN FALSE
	 END IF
	      
	 LET p_man.item = p_cod_item
	 LET p_num_lote = p_num_lote_op
	 LET p_cod_operacao = NULL
	 LET p_man.qtd_boas = p_qtd_ant
	 LET p_flag = '2'

   IF NOT pol0828_insere_est_relac() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol0828_grava_sucata()
#------------------------------#
      
   LET p_man.item = p_cod_item_sucata
   LET p_num_lote = p_num_lote_sucata
	      
	 IF NOT pol0828_le_item() THEN
	    RETURN FALSE
	 END IF
	      
	 LET p_flag = '3'
   LET p_cod_operacao = NULL
   LET p_cod_oper = 'E'

	 IF NOT pol0828_entrada_prod() THEN
	    RETURN FALSE
	 END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0828_insere_est_relac()
#----------------------------------#

   LET p_est_trans_relac.cod_empresa = p_cod_empresa
   LET p_est_trans_relac.num_transac_orig = p_pri_num_transac
   LET p_est_trans_relac.num_transac_dest = p_num_transac_orig
   LET p_est_trans_relac.num_nivel = 0
   LET p_est_trans_relac.cod_item_orig = p_man.item
   LET p_est_trans_relac.cod_item_dest = p_cod_item_apon
   LET p_est_trans_relac.dat_movto = p_dat_movto

   SELECT num_nivel
     INTO p_est_trans_relac.num_nivel
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_apon
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM_MAN - ',p_man.ordem_producao
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


#--------------------------#
FUNCTION pol0828_le_item()
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

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB ITEM - APON OP ',p_man.ordem_producao
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0828_baixa_consumo()
#------------------------------#

   IF p_cod_empresa  = p_cod_emp_ofic THEN

      LET p_qtd_movto = p_qtd_baixar_ant 
         
      IF p_qtd_movto <= p_saldo_zero THEN
         LET p_qtd_baixar = 0
      ELSE
         LET p_qtd_baixar = p_qtd_movto - p_saldo_zero
         LET p_qtd_movto = p_saldo_zero
      END IF
   ELSE
      LET p_qtd_baixar_ant = p_qtd_baixar
      LET p_qtd_movto = p_qtd_baixar
	 END IF

   IF p_qtd_movto <> 0 THEN
      CALL pol0828_seta_orig_dest()
      IF NOT pol0828_update_estoque() THEN
         RETURN FALSE
      END IF

   END IF
   
	 IF p_cod_empresa = p_cod_emp_ofic THEN
	    
      IF p_qtd_baixar > 0 THEN

         LET p_cod_prod  = p_cod_item_refugo
         LET p_num_lote  = p_num_lote_refugo
         LET p_ies_situa = 'L'
         
         SELECT cod_local_estoq
           INTO p_cod_local
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_prod

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO LOTE DO REFUGO'  
            RETURN FALSE
         END IF

         LET p_ies_situa_orig = p_ies_situa
         LET p_num_lote_orig   = p_num_lote
         
         CALL pol0828_le_lote()

         IF STATUS = 100 THEN
            LET p_qtd_lote = 0
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO SALDO DO LOTE'  
               RETURN FALSE
            END IF
         END IF      

         IF p_qtd_lote < p_qtd_baixar THEN
            LET p_msg = p_cod_prod CLIPPED,': FALTA SALO P/ COMPLETAR A BAIXA'
            RETURN FALSE
         END IF
         
         LET p_qtd_movto = p_qtd_baixar
         
         IF NOT pol0828_update_estoque() THEN
            RETURN FALSE
         END IF

      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0828_update_estoque()
#--------------------------------#

   IF p_ies_situa = 'L' THEN
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_movto,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   ELSE
      UPDATE estoque
         SET qtd_lib_excep = qtd_lib_excep - p_qtd_movto,
             dat_ult_saida = getdate()
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_prod
   END IF
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
      RETURN FALSE
   END IF   

   LET p_qtd_movto = -p_qtd_movto

   IF NOT pol0828_atualiza_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0828_deleta_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0828_insere_baixa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#-----------------------------#
FUNCTION pol0828_insere_baixa()
#-----------------------------#

   IF p_consu.cod_estorno = 0 THEN
      
      INSERT INTO baixa_consu_885
        VALUES(p_cod_empresa, 
               p_sequencia, 
               p_cod_prod, 
               p_num_lote,
               p_cod_local,
               p_ies_situa,
               p_qtd_movto)

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') INSERINDO BAIXA DE CONSUMO'  
         RETURN FALSE
      END IF   
   END IF
   
   RETURN TRUE
      
END FUNCTION

#-----------------------------#
FUNCTION pol0828_deleta_lote()
#-----------------------------#

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND qtd_saldo   = 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE'  
      RETURN FALSE
   END IF   

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND qtd_saldo   = 0

   IF STATUS <> 0 THEN      
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0828_baixa_lote()
#----------------------------#

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

   IF STATUS <> 0 THEN   
      IF p_cod_empresa = p_cod_emp_ofic THEN
         RETURN TRUE
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE:BX'  
         RETURN FALSE
      END IF
   END IF   
      
   IF p_qtd_saldo >= p_qtd_baixar THEN
      LET p_qtd_movto = p_qtd_baixar
      LET p_qtd_baixar = 0
   ELSE
      LET p_qtd_movto = p_qtd_saldo
      LET p_qtd_baixar = p_qtd_baixar - p_qtd_movto
   END IF

   LET p_num_lote_orig = p_num_lote
      
   LET p_qtd_movto = -p_qtd_movto
      
   IF NOT pol0828_atualiza_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0828_entrada_prod()
#------------------------------#

   LET p_qtd_movto = p_man.qtd_boas
   
   IF p_man.qtd_boas > 0  OR p_flag MATCHES '[23]' THEN
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

   IF p_man.tip_movto = 'R'  AND p_man.item <> p_cod_item_refugo THEN
      LET p_ies_situa = 'R'
   ELSE
      IF P_man.tip_movto = 'E' THEN
         LET p_ies_situa = 'E'
      ELSE
         LET p_ies_situa = 'L'
      END IF
   END IF
   
   CALL pol0828_seta_orig_dest()
       
   IF p_ies_situa != 'R' THEN
      LET p_ies_refugo = 'N'
      IF NOT pol0828_trata_fabricacao() THEN
         RETURN FALSE
      END IF
    ELSE
      IF p_man.qtd_boas < 0 THEN
         LET p_qtd_movto = p_man.qtd_boas * (-1)
      END IF

      IF NOT pol0828_carrega_campos() THEN
         RETURN
      END IF
      
      IF NOT pol0828_grava_estoq_trans() THEN
         RETURN FALSE
      END IF

   END IF

   RETURN TRUE
  
END FUNCTION

#--------------------------------#
FUNCTION pol0828_seta_orig_dest()
#--------------------------------#

   IF p_ies_apon = 'P' THEN
      LET p_num_lote_orig  = NULL
      LET p_cod_local_orig = NULL
      LET p_ies_situa_orig = NULL
      LET p_num_lote_dest  = p_num_lote
      LET p_cod_local_dest = p_cod_local
      LET p_ies_situa_dest = p_ies_situa
   ELSE
      LET p_num_lote_orig  = p_num_lote
      LET p_cod_local_orig = p_cod_local
      LET p_ies_situa_orig = p_ies_situa
      LET p_num_lote_dest  = NULL 
      LET p_cod_local_dest = NULL
      LET p_ies_situa_dest = NULL
      LET p_cod_oper = 'B'
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0828_trata_fabricacao()
#----------------------------------#

   IF NOT pol0828_grava_estoque() THEN
      RETURN FALSE
   END IF
   
   CALL pol0828_le_lote()
 
   IF STATUS = 0 THEN
      IF p_ies_refugo THEN
         IF NOT pol0828_atualiza_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0828_update_lote() THEN
            RETURN FALSE
         END IF
      END IF
      IF NOT pol0828_deleta_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0828_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE'  
         RETURN FALSE
      END IF   
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0828_grava_estoque()
#-------------------------------#

   SELECT qtd_liberada,
          qtd_impedida,
          qtd_rejeitada,
          qtd_lib_excep, 
          dat_ult_entrada,
          dat_ult_saida
     INTO p_qtd_liberada,
          p_qtd_impedida,
          p_qtd_rejeitada,
          p_qtd_lib_excep,
          p_dat_ult_entrada,
          p_dat_ult_saida
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_prod

   IF STATUS = 100 THEN
      LET p_qtd_liberada  = 0
      LET p_qtd_impedida  = 0
      LET p_qtd_rejeitada = 0
      LET p_qtd_lib_excep = 0
      LET p_dat_ult_entrada = ''
      LET p_dat_ult_saida   = ''
      INSERT INTO estoque
       VALUES(p_cod_empresa, 
              p_cod_prod, p_qtd_liberada,
              p_qtd_impedida, p_qtd_rejeitada, 
              p_qtd_lib_excep,0,0,'','','')
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') INSERINDO ESTOQUE'  
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE'  
         RETURN FALSE
      END IF   
   END IF
   
   IF p_ies_situa = 'E' THEN
      LET p_qtd_lib_excep = p_qtd_lib_excep + p_qtd_movto
   ELSE
      LET p_qtd_liberada = p_qtd_liberada + p_qtd_movto
   END IF
   
   IF p_qtd_movto > 0 THEN
      LET p_dat_ult_entrada = TODAY
   ELSE
      LET p_dat_ult_saida = TODAY
   END IF
      
   UPDATE estoque
      SET qtd_lib_excep   = p_qtd_lib_excep,
          qtd_liberada    = p_qtd_liberada,
          dat_ult_entrada = p_dat_ult_entrada,
          dat_ult_saida   = p_dat_ult_saida
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = p_cod_prod

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO TAB ESTOQUE'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0828_le_lote()
#-------------------------#

   LET p_num_transac = NULL
   
   IF p_num_lote IS NOT NULL THEN
      SELECT num_transac,
             qtd_saldo
        INTO p_num_transac,
             p_qtd_lote
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND num_lote      = p_num_lote
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
   END IF

END FUNCTION

#-------------------------------#
FUNCTION pol0828_atualiza_lote()
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
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_prod
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
   END IF
   
   IF STATUS = 100 THEN
      LET p_msg = 'TABELAS DE ESTOQUE INCOMPATIVEIS - ITEM:',p_cod_prod
      LET p_msg = p_msg CLIPPED, ' LOT:',p_num_lote
      RETURN FALSE
   END IF
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER - OP', p_man.ordem_producao  
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

   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0828_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0828_update_lote()
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

   IF NOT pol0828_le_item_ctr_grade(p_cod_prod) THEN
      RETURN FALSE
   END IF

   IF NOT pega_dimen() THEN
      RETURN FALSE
   END IF

   CALL pol0828_seta_dimen()
   
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
         AND largura       = p_largura_ped
         AND altura        = p_altura_ped
         AND diametro      = p_diametro_ped
         AND comprimento   = p_comprimento_ped
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
   END IF
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOTE_ENDER - OP', p_man.ordem_producao  
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
	   
      IF NOT pol0828_insere_ender() THEN
         RETURN FALSE
      END IF
   END IF 
       
   IF p_qtd_movto < 0 THEN
      LET p_qtd_movto = p_qtd_movto * (-1)
   END IF
   
   IF NOT pol0828_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0828_seta_dimen()
#----------------------------#

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

END FUNCTION

#----------------------------#
FUNCTION pol0828_insere_lote()
#----------------------------#

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
   
   IF NOT pol0828_insere_ender() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0828_grava_estoq_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0828_carrega_campos()
#-------------------------------#

   LET p_estoque_lote.cod_empresa   = p_cod_empresa
	 LET p_estoque_lote.cod_item      = p_cod_prod
	 LET p_estoque_lote.cod_local     = p_cod_local
	 LET p_estoque_lote.num_lote      = p_num_lote
	 LET p_estoque_lote.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote.qtd_saldo     = p_qtd_movto

   IF NOT pol0828_le_item_ctr_grade(p_estoque_lote.cod_item) THEN
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
FUNCTION pol0828_insere_ender()
#-----------------------------#

   IF NOT pol0828_carrega_campos() THEN
      RETURN FALSE
   END IF
   
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
FUNCTION pol0828_le_operacao()
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
FUNCTION pol0828_grava_estoq_trans()
#-----------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01),
          p_num_docum       CHAR(15)
          
   LET p_num_docum = p_man.ordem_producao
   
   IF p_cod_tip_movto = 'N' THEN
      INITIALIZE p_estoque_trans.* TO NULL                                                                       
                                                                                                                 
      IF p_cod_operacao IS NULL THEN                                                                             
         IF NOT pol0828_le_operacao() THEN                                                                       
            RETURN FALSE                                                                                         
         END IF                                                                                                  
      END IF                                                                                                     
                                                                                                                 
      SELECT ies_com_detalhe                                                                                     
        INTO p_ies_com_detalhe                                                                                   
        FROM estoque_operac                                                                                      
       WHERE cod_empresa  = p_cod_empresa                                                                        
         AND cod_operacao = p_cod_operacao                                                                       
                                                                                                                 
      IF STATUS <> 0 THEN                                                                                        
        LET p_msg = 'ERRO:(',STATUS, ') LENDO OPERACAO DE ESTOQUE:', p_cod_operacao                              
        RETURN FALSE                                                                                             
      END IF                                                                                                     
                                                                                                                 
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
            SELECT num_conta_credito                                                                             
              INTO p_num_conta                                                                                   
              FROM estoque_operac_ct                                                                             
             WHERE cod_empresa  = p_cod_empresa                                                                  
               AND cod_operacao = p_cod_operacao                                                                 
         END IF                                                                                                  
      ELSE                                                                                                       
         LET p_num_conta = NULL                                                                                  
      END IF                                                                                                     
                                                                                                                 
      IF STATUS <> 0 THEN                                                                                        
        LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_OPERAC_CT:', p_cod_operacao                            
        RETURN FALSE                                                                                             
      END IF                                                                                                     
                                                                                                                
      LET p_estoque_trans.dat_proces         = TODAY                                                             
      LET p_estoque_trans.hor_operac         = TIME                                                              
      LET p_estoque_trans.cod_empresa        = p_cod_empresa                                                     
      LET p_estoque_trans.num_transac        = 0                                                                 
      LET p_estoque_trans.cod_item           = p_cod_prod                                                        
      LET p_estoque_trans.dat_movto          = p_dat_movto                                                       
      LET p_estoque_trans.dat_ref_moeda_fort = p_dat_movto                                                       
      LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto                                                   
      LET p_estoque_trans.cod_operacao       = p_cod_operacao                                                    
      LET p_estoque_trans.num_prog           = "pol0828"                                                         
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
   
   ELSE                                                                                                           
      INITIALIZE p_num_transac_normal TO NULL
      DECLARE cq_rev CURSOR FOR
       SELECT num_transac
         FROM estoque_trans
        WHERE cod_empresa        = p_cod_empresa
          AND cod_item           = p_cod_prod
          AND num_lote_dest      = p_num_lote_dest
          AND cod_operacao       = p_cod_operacao
          AND num_docum          = p_num_docum
          AND qtd_movto          = p_qtd_movto
          AND num_prog           = "pol0828" 
          AND ies_tip_movto      = 'N'
        ORDER BY num_transac DESC

      FOREACH cq_rev INTO p_num_transac_normal

		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	
		      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO MOVIMENTO ORIGINAL'  
            RETURN FALSE
         END IF
         
         EXIT FOREACH
      END FOREACH
      
      IF p_num_transac_normal IS NULL THEN
         LET p_msg = 'MOVTO NORMAL CORRESPONDENTE NAO ENCONTRADO'  
         RETURN FALSE
      END IF
    
      SELECT * 
        INTO p_estoque_trans.*
        FROM estoque_trans
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac_normal

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE_TRANS'  
         RETURN FALSE
      END IF

      LET p_estoque_trans.dat_proces         = TODAY                                                             
      LET p_estoque_trans.hor_operac         = TIME                                                              
      LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto                                                   

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

   IF p_cod_tip_movto = 'R' THEN
      INSERT INTO estoque_trans_rev
       VALUES(p_estoque_trans.cod_empresa,
              p_num_transac_normal,
              p_num_transac_orig)

      IF STATUS <> 0 THEN
        LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_REV'  
        RETURN FALSE
      END IF
   END IF

   IF NOT pol0828_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   LET p_cod_operacao = NULL

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0828_ins_est_trans_end()
#------------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   IF p_cod_tip_movto = 'N' THEN
      LET p_estoque_trans_end.num_transac      = p_num_transac_orig                   
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
      LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto            
      LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao         
      LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto        
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
   ELSE
      SELECT * 
        INTO p_estoque_trans_end.*
        FROM estoque_trans_end
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac_normal

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ESTOQUE_TRANS_END'  
         RETURN FALSE
      END IF

      LET p_estoque_trans_end.ies_tip_movto = p_cod_tip_movto                                                   
   
   END IF
   
   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_END'  
     RETURN FALSE
   END IF

{   SELECT cod_lin_prod, 
          cod_lin_recei,
          cod_seg_merc, 
          cod_cla_uso             
     INTO p_aen.*
     FROM item  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_estoque_trans.cod_item

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB ITEM'  
     RETURN FALSE
   END IF

   INSERT INTO est_trans_area_lin 
      VALUES (p_estoque_trans.cod_empresa, p_num_transac, p_aen.*)

   IF SQLCA.SQLCODE <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB EST_TRANS_AREA_LIN'  
      RETURN FALSE
   END IF
}
  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac_orig, p_user, getdate(),'pol0828')

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_AUDITORIA'  
     RETURN FALSE
   END IF

   IF p_flag <> '3' AND p_man.qtd_boas > 0 THEN
      IF NOT pol0828_insere_chf_compon() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0828_insere_chf_compon()
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

#----------------------------------#
FUNCTION pol0828_elimina_estornos()
#----------------------------------#

   DEFINE p_num_seq_at INTEGER

   INITIALIZE p_consu TO NULL

   DECLARE cq_cons_eli CURSOR WITH HOLD FOR
    SELECT numsequencia,
           numordem,
           coditem,
           numlote,
           qtdconsumida,
           datconsumo
      FROM cons_insumo_885
     WHERE codempresa = p_cod_empresa
       AND iesrefugo  = 'N'
       AND estorno    = 0
       AND statusregistro IN (0,2)

   FOREACH cq_cons_eli INTO 
           p_consu.num_sequencia,
           p_consu.num_ordem,
           p_consu.cod_item,
           p_consu.num_lote,
           p_consu.qtd_consumida,
           p_consu.dat_consumo

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO CONSUMO C/ ESTORNO (1)'
         LET p_sequencia = 0
         RETURN FALSE
      END IF

      LET p_sequencia = p_consu.num_sequencia
      
      DECLARE cq_cons_rep CURSOR FOR
       SELECT numsequencia
         FROM cons_insumo_885
        WHERE codempresa   = p_cod_empresa
          AND numordem     = p_consu.num_ordem
          AND coditem      = p_consu.cod_item
          AND numlote      = p_consu.num_lote
          AND qtdconsumida = p_consu.qtd_consumida
          AND datconsumo   = p_consu.dat_consumo
          AND iesrefugo    = 'N'
          AND estorno      = 1
          AND statusregistro IN (0,2)

      FOREACH cq_cons_rep INTO p_num_seq_at

		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	
		
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO CONSUMO C/ ESTORNO (2)'
            RETURN FALSE
         END IF

         CALL log085_transacao("BEGIN")  
      
         UPDATE cons_insumo_885
            SET StatusRegistro = '9'
          WHERE codempresa   = p_consu.cod_empresa
            AND numsequencia IN (p_consu.num_sequencia, p_num_seq_at)
            
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO CONSUMO C/ ESTORNO'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF

         CALL log085_transacao("COMMIT")  
      
         EXIT FOREACH
      
      END FOREACH
   
   END FOREACH      

   DECLARE cq_refu_eli CURSOR WITH HOLD FOR
    SELECT numsequencia,
           coditem,
           numlote,
           qtdrefugada
      FROM cons_insumo_885
     WHERE codempresa = p_cod_empresa
       AND iesrefugo  = 'S'
       AND estorno    = 0
       AND statusregistro IN (0,2)

   FOREACH cq_refu_eli INTO 
           p_consu.num_sequencia,
           p_consu.cod_item,
           p_consu.num_lote,
           p_consu.qtd_refugada

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REFUGO C/ ESTORNO (1)'
         LET p_sequencia = 0
         RETURN FALSE
      END IF

      LET p_sequencia = p_consu.num_sequencia
      
      DECLARE cq_refu_rep CURSOR FOR
       SELECT numsequencia
         FROM cons_insumo_885
        WHERE codempresa   = p_cod_empresa
          AND coditem      = p_consu.cod_item
          AND numlote      = p_consu.num_lote
          AND qtdrefugada  = p_consu.qtd_refugada
          AND iesrefugo    = 'S'
          AND estorno      = 1
          AND statusregistro IN (0,2)

      FOREACH cq_refu_rep INTO p_num_seq_at

		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	
		
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REFUGO C/ ESTORNO (2)'
            RETURN FALSE
         END IF

         CALL log085_transacao("BEGIN")  
      
         UPDATE cons_insumo_885
            SET StatusRegistro = '9'
          WHERE codempresa   = p_consu.cod_empresa
            AND numsequencia IN (p_consu.num_sequencia, p_num_seq_at)
            
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO CONSUMO C/ ESTORNO'
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         END IF

         CALL log085_transacao("COMMIT")  
      
         EXIT FOREACH
      
      END FOREACH
   
   END FOREACH      

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0828_importa_consumo()
#---------------------------------#
   
   IF NOT pol0828_elimina_estornos() THEN
      RETURN FALSE
   END IF
     
   INITIALIZE p_consu TO NULL

   DECLARE cq_baixa CURSOR WITH HOLD FOR
    SELECT codempresa,
           numsequencia,
           numordem,
           coditem,
           numlote,
           codmaqpapel,
           qtdconsumida,
           datconsumo,
           qtdrefugada,
           estorno,
           iesrefugo,
           coditemrefugo,
           numloterefugo
      FROM cons_insumo_885
     WHERE codempresa = p_cod_empresa
       AND statusregistro IN (0,2)
     ORDER BY coditem, numlote

   FOREACH cq_baixa INTO 
           p_consu.cod_empresa,
           p_consu.num_sequencia,
           p_consu.num_ordem,
           p_consu.cod_item,
           p_consu.num_lote,
           p_consu.codmaqpapel,
           p_consu.qtd_consumida,
           p_consu.dat_consumo,
           p_consu.qtd_refugada,
           p_consu.cod_estorno,
           p_consu.ies_refugo,
           p_consu.cod_itemrefugo,
           p_consu.num_loterefugo
           

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO CONSUMOS ENVIADOS PELO TRIM'
         LET p_sequencia = 0
         RETURN FALSE
      END IF
      
      IF p_consu.ies_refugo = 'S' THEN
         LET p_consu.num_ordem = 0
      END IF

      LET p_sequencia = p_consu.num_sequencia
      LET p_cod_registro = 2
      LET p_criticou = FALSE

      DISPLAY p_consu.num_ordem TO num_ordem

      CALL log085_transacao("BEGIN")  

      IF NOT pol0828_apaga_erros() THEN
         RETURN FALSE
      END IF

      IF p_consu.ies_refugo = 'N' THEN
         LET p_qtd_movto = p_consu.qtd_consumida
      ELSE
         IF p_consu.ies_refugo = 'S' THEN
            LET p_qtd_movto = p_consu.qtd_refugada
         ELSE
            LET p_msg = 'IDENTIFICADOR DE CONSUMO/REFUGO INVALIDO'
            IF NOT pol0828_grava_erro() THEN
               RETURN FALSE
            END IF 
            LET p_qtd_movto = 0
         END IF
      END IF

      IF NOT p_criticou THEN  
         IF NOT pol0828_consiste_info() THEN
            IF NOT pol0828_grava_erro() THEN
               CALL log085_transacao("ROLLBACK")  
               RETURN FALSE
            END IF
         END IF
      END IF

      IF NOT p_criticou THEN
         IF NOT pol0828_proces_info() THEN
            CALL log085_transacao("ROLLBACK")  
            CALL log085_transacao("BEGIN")  
            IF NOT pol0828_grava_erro() THEN
               CALL log085_transacao("ROLLBACK")  
               RETURN FALSE
            END IF
         ELSE
            LET p_consu_apontado = p_consu_apontado + 1
            DISPLAY p_consu_apontado TO consu_apontado
            LET p_cod_registro = 1   
         END IF
      END IF
   
      IF NOT pol0828_grava_cons_trim() THEN
         CALL log085_transacao("ROLLBACK")  
      ELSE
         CALL log085_transacao("COMMIT")  
      END IF
   
      INITIALIZE p_consu TO NULL
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0828_apaga_erros()
#----------------------------#

   DELETE FROM cons_erro_885
    WHERE codempresa     = p_cod_empresa
      AND numsequencia   = p_sequencia

   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') DELETANDO CRITICAS DO CONSUMO'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0828_consiste_info()
#-------------------------------#

   IF p_qtd_movto < 0 THEN
      LET p_msg = 'QUANTIDADE CONSUMIDA OU REFUGADA ESTA NEGATIVA'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF 
   END IF

   IF p_consu.Num_Sequencia IS NULL OR p_consu.Num_Sequencia = 0 THEN
      LET p_msg = 'CODIGO DE SEQUENCIA INVALIDO'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_consu.cod_item IS NULL OR p_consu.cod_item = 0 THEN
      LET p_msg = 'CODIGO DO ITEM INVALIDO'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0828_checa_item(p_consu.cod_item) THEN
         RETURN FALSE
      END IF
   END IF

   IF p_consu.num_lote IS NULL THEN
      LET p_msg = 'NUMERO DO LOTE ESTA NULO'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_qtd_movto IS NULL OR p_qtd_movto = 0 THEN
      LET p_msg = 'QUANTIDADE A CONSUMIR/REFUGAR INVALIDA'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_consu.ies_refugo = 'N' THEN
      IF p_consu.num_ordem IS NULL OR p_consu.num_ordem = 0 THEN
         LET p_msg = 'OREM DE PRODUÇÃO INVALIDA'
         IF NOT pol0828_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_cod_item = NULL
         SELECT cod_item,
                num_docum
           INTO p_cod_item,
                p_num_docum
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_consu.num_ordem

         IF STATUS = 100 THEN
            LET p_msg = 'ORDEM DE PRODUCAO INIXISTENTE'
            IF NOT pol0828_grava_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO, P/ VALIDAR, TAB ORDENS'
               RETURN FALSE
            END IF
         END IF
      END IF

      IF p_consu.dat_consumo IS NULL THEN
         LET p_msg = 'DATA DO CONSUMO INVALIDA'
         IF NOT pol0828_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF

   END IF
   
   IF p_criticou THEN 
      RETURN TRUE
   END IF
   
   LET p_num_seq_cons = NULL
   
   IF p_consu.cod_estorno = 1 THEN
      IF p_consu.ies_refugo = 'N' THEN
         DECLARE cq_seqn CURSOR FOR
         SELECT numsequencia
           FROM cons_insumo_885
           WHERE codempresa   = p_consu.cod_empresa
             AND numordem     = p_consu.num_ordem
             AND coditem      = p_consu.cod_item
             AND numlote      = p_consu.num_lote
             AND qtdconsumida = p_consu.qtd_consumida
             AND datconsumo   = p_consu.dat_consumo
             AND estorno      = 0
             AND statusregistro = 1
         FOREACH cq_seqn INTO p_num_seq_cons
		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	
		
            EXIT FOREACH
         END FOREACH
      ELSE
         DECLARE cq_seqs CURSOR FOR
         SELECT numsequencia
           FROM cons_insumo_885
           WHERE codempresa   = p_consu.cod_empresa
             AND coditem      = p_consu.cod_item
             AND numlote      = p_consu.num_lote
             AND qtdrefugada  = p_consu.qtd_refugada
             AND estorno      = 0
             AND statusregistro = 1
         FOREACH cq_seqs INTO p_num_seq_cons
		   # Refresh de tela
		   #lds CALL LOG_refresh_display()	
		         
            EXIT FOREACH
         END FOREACH
      END IF      
      
      IF p_num_seq_cons IS NULL THEN
         LET p_msg = 'ESTORNO DE CONSUMO NAO ENVIADO AO LOGIX'
         IF NOT pol0828_grava_erro() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_consu.qtd_consumida = -p_consu.qtd_consumida
         LET p_consu.qtd_refugada  = -p_consu.qtd_refugada
      END IF
   END IF

   IF NOT p_criticou AND p_consu.ies_refugo = 'N' THEN
   
      IF p_consu.cod_estorno = 1 THEN
      
         SELECT COUNT(num_seq_cons)
           INTO p_count
           FROM baixa_consu_885
          WHERE cod_empresa  = p_cod_empresa
            AND num_seq_cons = p_num_seq_cons
      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO CONSUMO ENVIADO'  
            RETURN FALSE
         END IF
  
         IF p_count = 0 THEN
            LET p_msg = 'DADOS DO CONSUMO ENVIADO NAO LOCALIZADO'
            IF NOT pol0828_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   END IF

   IF p_criticou THEN 
      RETURN TRUE
   END IF

   LET p_cod_prod = p_consu.cod_item
   LET p_num_lote = p_consu.num_lote

   IF p_consu.cod_estorno = 0 THEN
      LET p_qtd_baixar = p_consu.qtd_consumida
      LET p_cod_tip_movto = 'N'
   ELSE
      LET p_qtd_baixar = -p_consu.qtd_consumida
      LET p_cod_tip_movto = 'R'
   END IF
   
   IF NOT pol0828_le_item_man() THEN
      RETURN FALSE
   END IF

   SELECT cod_familia
     FROM familia_insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND ies_bobina  = 'S'
      
   IF STATUS = 100 THEN
      LET p_ies_bobina = FALSE
   ELSE
      IF STATUS = 0 THEN
         LET p_ies_bobina = TRUE
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') LENDO A FAMILIA DA BOBINA'  
         RETURN FALSE
      END IF
   END IF

   SELECT cod_familia
     FROM familia_insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_cod_familia
      AND ies_apara   = 'S'
   
   IF STATUS = 100 THEN
      LET p_ies_apara = 'N'
   ELSE
      IF STATUS = 0 THEN
         LET p_ies_apara = 'S'
      ELSE
         LET p_msg = 'ERRO:(',STATUS, ') TIPO DE INSUMO'  
         RETURN FALSE
      END IF
   END IF
      
   IF (p_ctr_estoque = 'N' OR p_sobre_baixa = 'N') AND p_ies_tip_item <> 'F' THEN
      LET p_msg = p_cod_prod CLIPPED,' - ESSE MATERIAL NAO SOFRE BAIXA'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_cod_local = p_cod_local_orig
      IF p_consu.cod_estorno = 0 THEN
         IF NOT pol0828_checa_estoque() THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_sem_estoque = FALSE
      END IF
      IF p_sem_estoque THEN
         LET p_saldo_txt = p_qtd_saldo
         LET p_saldo_tx2 = p_qtd_baixar
         LET p_saldo_txt = p_saldo_txt CLIPPED, ' X ',p_saldo_tx2
         LET p_msg = p_cod_prod CLIPPED,':S/SALDO PARA REFUGAR/BAIXAR:',p_saldo_txt
         IF NOT pol0828_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_consu.cod_itemrefugo IS NOT NULL THEN
      IF p_ies_apara = 'S' THEN
         IF NOT pol0828_checa_item(p_consu.cod_itemrefugo) THEN
            RETURN FALSE
         END IF
         IF p_consu.num_loterefugo IS NULL THEN
            LET p_consu.num_loterefugo = p_num_lote_impurezas
         END IF
         LET p_cod_item_refugo = p_consu.cod_itemrefugo
         LET p_cod_local_refug = p_cod_local_estoq
         LET p_num_lote_refugo = p_consu.num_loterefugo
      ELSE
         INITIALIZE p_consu.cod_itemrefugo, 
                    p_consu.num_loterefugo TO NULL
      END IF
   END IF

   IF NOT p_criticou AND p_consu.ies_refugo = 'N' THEN
   
      SELECT num_conta
        INTO p_num_conta
		    FROM de_para_maq_885
			 WHERE cod_empresa  = p_cod_empresa
			   AND cod_maq_trim = p_consu.codmaqpapel

      IF STATUS = 100 THEN
         LET p_num_conta = NULL
      ELSE
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO CONTA CONTABIL'  
            RETURN FALSE
         END IF
      END IF

      CALL pol0828_pega_pedido()

      IF NOT pol0828_le_desc_nat_oper_885() THEN
         RETURN FALSE
      END IF
   
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0828_checa_item(p_cod_item)
#--------------------------------------#
   
   DEFINE p_cod_item LIKE item.cod_item
   
   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      LET p_msg = 'ITEM:',p_cod_item CLIPPED,' INIXISTENTE'
      IF NOT pol0828_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO, P/ VALIDAR, TAB ITEM'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
#-------------------------------#
FUNCTION pol0828_checa_estoque()
#-------------------------------#

   LET p_ies_situa   = 'L'

   IF NOT pol0828_ve_estoque() THEN
      RETURN FALSE
   END IF
   
   IF p_sem_estoque THEN 
      RETURN TRUE
   END IF

   LET p_num_transac_o = p_num_transac
   LET p_cod_empresa   = p_cod_emp_ofic
   
   IF NOT pol0828_ve_estoque() THEN
      LET p_cod_empresa = p_cod_emp_ger
      RETURN FALSE
   END IF

   LET p_num_transac_0 = p_num_transac
   LET P_saldo_zero = p_qtd_saldo

   IF p_ies_apara THEN
      LET p_sem_estoque = FALSE
   END IF

   LET p_cod_empresa = p_cod_emp_ger

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0828_ve_estoque()
#-------------------------------#

   LET p_sem_estoque = FALSE
   
   SELECT qtd_saldo,
          num_transac
     INTO p_qtd_saldo,
          p_num_transac
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_prod
      AND cod_local     = p_cod_local
      AND num_lote      = p_num_lote
      AND ies_situa_qtd = p_ies_situa
      #AND comprimento   = p_comprimento_ped
	    #AND largura       = p_largura_ped
	    #AND altura        = p_altura_ped
	    #AND diametro      = p_diametro_ped

   IF STATUS <> 0 THEN
      LET p_qtd_saldo = 0
      IF p_cod_empresa = p_cod_emp_ger THEN
         LET p_ies_situa   = 'E'
   
         SELECT qtd_saldo,
                num_transac
           INTO p_qtd_saldo,
                p_num_transac
           FROM estoque_lote
          WHERE cod_empresa   = p_cod_empresa
            AND cod_item      = p_cod_prod
            AND cod_local     = p_cod_local
            AND num_lote      = p_num_lote
            AND ies_situa_qtd = p_ies_situa
            #AND comprimento   = p_comprimento_ped
    	      #AND largura       = p_largura_ped
	          #AND altura        = p_altura_ped
            #AND diametro      = p_diametro_ped

         IF STATUS <> 0 THEN
            LET p_qtd_saldo = 0
         END IF
      END IF
   END IF  

   SELECT SUM(qtd_reservada - qtd_atendida)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_prod
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') CHECANDO MP NA ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_baixar THEN
      LET p_sem_estoque = TRUE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0828_grava_erro()
#-----------------------------#

   LET p_criticou = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND
   LET p_consu_criticado = p_consu_criticado + 1
   DISPLAY p_consu_criticado TO qtd_erro_consu

   INSERT INTO cons_erro_885
      VALUES (p_cod_empresa,
              p_sequencia,
              p_consu.dat_consumo,
              p_msg,
              p_dat_hor)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO CRITICAS DO CONSUMO'
      RETURN FALSE
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0828_grava_cons_trim()
#---------------------------------#

   UPDATE cons_insumo_885
      SET StatusRegistro = p_cod_registro
    WHERE codempresa   = p_cod_empresa
      AND NumSequencia = p_sequencia
    
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO A CONS_INSUMO_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0828_proces_info()
#----------------------------#

   LET p_man.ordem_producao = p_consu.num_ordem
   LET p_cod_oper   = 'B'
   LET p_dat_movto  = EXTEND(p_consu.dat_consumo, YEAR TO DAY)

   IF p_dat_movto IS NULL THEN
      LET p_dat_movto = TODAY
   END IF

   IF NOT pol0828_procs_baixa() THEN
      RETURN FALSE
   END IF

   IF p_ies_bobina THEN
      LET p_ies_bobina = FALSE
      LET p_cod_operacao = NULL
      LET p_cod_empresa = p_cod_emp_ofic
      CALL pol0828_le_lote()
      IF p_num_transac IS NULL THEN
         LET p_msg = 'Item:',p_cod_prod, ' s/ estoque p/ baixar'
         RETURN FALSE
      END IF
      LET p_num_transac_0 = p_num_transac
      LET p_cod_empresa = p_cod_emp_ger
      CALL pol0828_le_lote()
      IF p_num_transac IS NULL THEN
         LET p_msg = 'Item:',p_cod_prod, ' s/ estoque p/ baixar'
         RETURN FALSE
      END IF
      LET p_num_transac_o = p_num_transac
      IF NOT pol0828_procs_baixa() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0828_procs_baixa()
#-----------------------------#

   IF p_ies_bobina AND p_consu.cod_estorno = 1 THEN
      IF NOT pol0828_estorna_mp() THEN
         RETURN FALSE
      END IF
   	  LET p_cod_operacao = NULL
	    LET p_cod_prod  = p_consu.cod_item
   	  LET p_num_lote  = p_consu.num_lote
      LET p_ies_refugo = 'S'
      LET p_ies_situa = 'L'
      IF NOT pol0828_de_para() THEN
         RETURN FALSE
      END IF
      LET p_ies_bobina = FALSE
      RETURN TRUE
   END IF
            
   IF p_consu.ies_refugo = 'N' AND NOT p_ies_bobina THEN
      IF p_consu.cod_estorno = 0 THEN
         IF NOT pol0828_baixa_mp() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0828_estorna_mp() THEN
            RETURN FALSE
         END IF
      END IF  
   ELSE
      LET p_ies_refugo = 'S'
      LET p_ies_situa = 'L'
      IF NOT pol0828_de_para() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0828_baixa_mp()
#--------------------------#

   LET p_num_transac = p_num_transac_o

   IF NOT pol0828_baixa_consumo() THEN
      RETURN FALSE
   END IF
   
   LET p_cod_empresa  = p_cod_emp_ofic
   LET p_num_transac = p_num_transac_0

   IF NOT pol0828_baixa_consumo() THEN
      LET p_cod_empresa  = p_cod_emp_ger
      RETURN FALSE
   END IF

   LET p_cod_empresa  = p_cod_emp_ger

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0828_estorna_mp()
#---------------------------#

   LET p_cod_oper = 'B'
   LET p_flag = '1'

   DECLARE cq_estorna CURSOR FOR
    SELECT cod_empresa,
           cod_item,
           num_lote,
           cod_local,
           ies_situa,
           qtd_movto
           
      FROM baixa_consu_885
     WHERE cod_empresa IN (p_cod_emp_ger,p_cod_emp_ofic)
       AND num_seq_cons = p_num_seq_cons
     ORDER BY cod_empresa DESC
     
   FOREACH cq_estorna INTO 
           p_cod_empresa,
           p_cod_prod,
           p_num_lote,
           p_cod_local_baixa,
           p_man.tip_movto,
           p_qtd_baixar

	   # Refresh de tela
	   #lds CALL LOG_refresh_display()	
	
      LET p_qtd_baixar = -p_qtd_baixar
      LET p_cod_operacao = NULL
      
      IF NOT pol0828_entrada_prod() THEN
         LET p_cod_empresa  = p_cod_emp_ger
         RETURN FALSE
      END IF
         
   END FOREACH
   
   LET p_cod_empresa  = p_cod_emp_ger
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0828_le_desc_nat_oper_885()
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
      LET p_msg = 'ERRO:(',STATUS, ') LENDO DESCONTOS DO PEDIDO'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0828_pega_pedido()
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
FUNCTION pol0828_cheka_estoque()
#-------------------------------#

   LET p_sem_estoque = FALSE
   LET p_cod_local   = p_cod_local_orig
   IF p_man.tip_movto = 'E' THEN
      LET p_ies_situa   = 'E'
   ELSE
      LET p_ies_situa   = 'L'
   END IF
   
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

   IF p_cod_prod = p_cod_item_refugo OR
      p_cod_prod = p_cod_item_sucata THEN

      LET p_qtd_reservada = 0
   ELSE
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
