#-------------------------------------------------------------------#
# OBJETIVO: INTEGRAÇÃO DE CONSUMO  - GUAPIMIRIM                     #
# DATA....: 08/08/2008                                              #
# CONVERSÃO 10.02: 12/12/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
# Regras de negócio:                                                #
# - O Trim enviará o consumo de aparas relacionado com a Ordem de   #
#   produção. O numero da OP será gravado na tabela estoque_trans no#
#   campo num_docum. Não será grava a tabela man_comp_consumido, uma#
#   vez que o consumo é enviado em momento diferente do apontamento #
# - O Trim enviará bobinas a serem destruidas. Nesse caso, o pol1273#
#   fará uma transferência da bobina para o item sucata da tabela   #
#   parametros_885.cod_item_refugo. Esse tipo de registro será iden-#
#   tificado pelo fato do campo cons_insumo_885.coditem conter uma  #
#   bobina e o campo cons_insumo_885.iesrefugo estar marcado com S. #
#   Para que o custo da bobina seja repassado para o item refugo,   #
#   será gravada a tabela est_trans_relac.                          #
# - O Trim enviará regitros de aparas a serem descartadas. Trata-se #
#   de pedras, fios, etc que vem misturado nas aparas. Nesse caso, o#
#   pol1273 deverá fazer uma saída do item por uma operação de suca-#
#   teamento.                                                       #
#-------------------------------------------------------------------#

 DATABASE logix

 GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          g_ies_ambiente       CHAR(01),
          p_ies_impressao      CHAR(01),
          p_qtd_dif            DECIMAL(10,3),
          p_comando            CHAR(80),
          comando              CHAR(80),
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
          p_caminho            CHAR(080),
          p_est_relac          SMALLINT,
          p_trans_nobre        INTEGER,
          p_tip_operacao       CHAR(01),
          p_ies_tip_movto      CHAR(01),
          p_tip_reversao       CHAR(01),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_last_row           SMALLINT,
          p_dat_proces         DATE,
          p_hor_operac         CHAR(08),
          p_num_trans_atual    INTEGER,
          p_msg                CHAR(150)
          

END GLOBALS

DEFINE p_assunto                 CHAR(30),
       p_nom_destinatario        CHAR(36),
       p_email_destinatario      CHAR(300),
       p_email_remetente         CHAR(50),
       p_nom_remetente           CHAR(36),
       p_imp_linha               CHAR(80),
       p_titulo1                 CHAR(80),       
       p_titulo2                 CHAR(80),
       p_arquivo                 CHAR(30),
       m_qtd_erro                INTEGER,
       p_den_comando             CHAR(100),
       m_processo                CHAR(20)    

   DEFINE p_statusregistro     LIKE apont_papel_885.statusregistro,
          p_cod_item_refugo    LIKE parametros_885.cod_item_refugo,
          p_cod_item_sucata    LIKE parametros_885.cod_item_sucata,
          p_cod_item_retrab    LIKE parametros_885.cod_item_retrab,
          p_num_lote_sucata    LIKE parametros_885.num_lote_sucata,
          p_num_lote_refugo    LIKE parametros_885.num_lote_refugo,
          p_num_lote_retrab    LIKE parametros_885.num_lote_retrab,
          p_oper_sai_tp_refugo LIKE parametros_885.oper_sai_tp_refugo,
          p_oper_ent_tp_refugo LIKE parametros_885.oper_ent_tp_refugo,
          p_cod_apara_nobre    LIKE item.cod_item,
          p_num_lote_nobre     LIKE estoque_lote.num_lote,
          p_loc_est_nobre      LIKE estoque_lote.cod_local,
          p_num_transac_normal LIKE estoque_trans.num_transac,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_parametros         LIKE par_pcp.parametros,
          p_saldo_zero         LIKE estoque_lote.qtd_saldo,
          p_qtd_bx_oh          LIKE estoque_lote.qtd_saldo,
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
          p_dat_ult_saida      LIKE estoque.dat_ult_saida,
          p_den_item_reduz     LIKE item.den_item_reduz,
          p_den_familia        LIKE familia.den_familia,
          p_cod_oper_sp        LIKE par_pcp.cod_estoque_sp,
          p_cod_turno          LIKE estoque_trans.cod_turno      
          
          
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
          p_dat_hor            DATETIME YEAR TO SECOND,
          p_nom_relat          CHAR(14),
          p_bx_trim            DECIMAL(10,3),
          p_bx_logix           DECIMAL(10,3),
          p_dif_baixa          DECIMAL(10,3),
          p_den_item           CHAR(40),
          p_hor_movto          CHAR(08)
          

   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_audit_logix        RECORD LIKE audit_logix.*,
          p_parametros_885     RECORD LIKE parametros_885.*,
          p_est_trans_relac    RECORD LIKE est_trans_relac.*
          
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
          num_loterefugo    LIKE cons_insumo_885.numloterefugo,
          datregistro       LIKE cons_insumo_885.datregistro
   END RECORD
   
   DEFINE pr_erro           ARRAY[5000] OF RECORD 
          codcorrida        LIKE cons_insumo_885.codcorrida,
          numordem          LIKE cons_insumo_885.numordem,
          coditem           LIKE cons_insumo_885.coditem,
          numlote           LIKE cons_insumo_885.numlote,
          qtdconsumida      LIKE cons_insumo_885.qtdconsumida,
          datconsumo        CHAR(10),
          mensagem          LIKE cons_erro_885.mensagem
   END RECORD 

      
   DEFINE p_numsequencia    LIKE cons_erro_885.numsequencia,
          datconsumo_e      DATETIME YEAR TO SECOND,
          p_datconsumo      DATETIME YEAR TO SECOND 
   
DEFINE p_tela              RECORD
       dat_ini             DATE,
       dat_fim             DATE,
       listar              CHAR(01)
END RECORD

DEFINE m_tela              RECORD
       dat_ini             DATE,
       dat_fim             DATE
END RECORD

DEFINE pr_mes            ARRAY[200] OF RECORD 
       ano_mes           CHAR(20)
END RECORD

DEFINE m_tela               RECORD         
       cod_familia          LIKE item.cod_familia,
       cod_item             LIKE item.cod_item,
       dat_ini              DATE,
       dat_fim              DATE,
       sumarizar            CHAR(01),
       deletar              CHAR(01)
END RECORD 

DEFINE p_relat     RECORD
  cod_item         CHAR(15),
  dat_movto        DATETIME YEAR TO SECOND,
  qtd_bx_trim      DECIMAL(10,3),
  qtd_bx_logix     DECIMAL(10,3)
END RECORD       

DEFINE p_detal     RECORD
  cod_empresa      CHAR(02),
  dat_movto        DATETIME YEAR TO SECOND,
  cod_item         CHAR(15),
  qtd_bx_trim      DECIMAL(10,3),
  qtd_bx_logix     DECIMAL(10,3),
  num_ordem        INTEGER
END RECORD       

   
MAIN

    CALL log0180_conecta_usuario()

    IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_processo = 'Via bat'
      SLEEP 20
      CALL pol1273_exibe_tela()
      CALL pol1273_processar() RETURNING p_status
      CALL pol1273_e_mail()   
      CLOSE WINDOW w_pol1273
   ELSE
      CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
  
     #LET p_cod_empresa = '02'; LET p_user = 'pol1273'; LET p_status = 0
  
     IF p_status = 0  THEN
        LET m_processo = 'Manual'
        CALL pol1273_controle()
     END IF
   END IF
   
END MAIN       

#------------------------------#
FUNCTION pol1273_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL pol1273_exibe_tela()

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '02'
   END IF

   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF      
   
   LET m_processo = 'Automatico'
      
   CALL pol1273_processar() RETURNING p_status
   CALL pol1273_e_mail()   
     
   CLOSE WINDOW w_pol1273
   
   RETURN p_status
   
END FUNCTION   

#------------------------#
FUNCTION pol1273_e_mail()#
#------------------------#

   SELECT COUNT(*) INTO m_qtd_erro
     FROM cons_insumo_885
    WHERE codempresa = p_cod_empresa
      AND statusregistro = 2
         
   IF m_qtd_erro > 0 THEN
      CALL pol1273_envia_email()
   END IF

END FUNCTION

#----------------------------#
FUNCTION pol1273_exibe_tela()#
#----------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1273") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1273 AT 2,2 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1273_controle()
#--------------------------#

   CALL pol1273_exibe_tela()
   
   MENU "OPCAO"
      COMMAND "Processar" "Processa a importação/baixa do consumo"
         ERROR 'Aguarde!... processando.'
         CALL pol1273_processar() RETURNING p_status
         IF p_status THEN
            LET p_msg = 'Operação efetuada com sucesso.'
         ELSE
            IF p_msg IS NULL OR p_msg = ' ' THEN
               LET p_msg =  'Operação cancelada.'
            END IF
         END IF
         CALL log0030_mensagem(p_msg,'info')
      COMMAND "Consultar" "Consulta os erros de integração"
         IF pol1273_verifica_erros() THEN 
            CALL pol1273_consultar() RETURNING p_status
            IF p_status THEN
               ERROR "Consulta efetuada com sucesso !!!" 
            ELSE
               ERROR "Consulta cancelada !!!"
            END IF
         ELSE 
            CALL log0030_mensagem("Não há erros á serem Listados !",'excla') 
         END IF     
      {COMMAND "Pendentes" "Exibe meses que ainda não foram baixados"
         CALL pol1273_exibe_pendentes() RETURNING p_status
         IF NOT p_status THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            ERROR 'Operação cancelada.'
         ELSE
            ERROR 'Operação efetuada com sucesso.'
         END IF }           
      COMMAND "Listar" "Listagem do consumo Enviado X Baixado no Logix"
         IF pol1273_lst_confronto() THEN
            ERROR 'Operação efetuada com sucesso.'
         ELSE
            ERROR 'Operação cancelada.'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1273_versao()
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim" "Retorna ao menu anterior"
         #CALL pol1270_exec_pol1273()
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1273

END FUNCTION

#------------------------------#
FUNCTION pol1270_exec_pol1273()#
#------------------------------#

   DEFINE l_param         CHAR(01),
          l_comando       CHAR(100),
          l_proces        CHAR(01),
          l_carac         CHAR(01)
  
   LET p_caminho = NULL
  
   SELECT nom_caminho INTO p_caminho
      FROM path_logix_v2
     WHERE cod_empresa = p_cod_empresa
       AND ies_ambiente = g_ies_ambiente
       AND cod_sistema = 'bat'
     
   IF STATUS <> 0 OR p_caminho IS NULL THEN
      RETURN
   END IF
                       
   LET l_comando = p_caminho CLIPPED, 'pol1273.bat ', p_cod_empresa
   
   CALL conout(l_comando)                            
   CALL runOnClient(l_comando)

END FUNCTION

#--------------------------------#
 FUNCTION pol1273_verifica_erros()
#--------------------------------#

   SELECT COUNT(numsequencia)
     INTO p_count
     FROM cons_erro_885 
    WHERE codempresa = p_cod_empresa
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'cons_erro_885')
      RETURN FALSE 
   END IF 
      
   IF p_count > 0 THEN 
      RETURN TRUE 
   ELSE 
      RETURN FALSE
   END IF 
   
END FUNCTION     

#---------------------------#
 FUNCTION pol1273_consultar()
#---------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol12731") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol12731 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   INITIALIZE m_tela TO NULL
   LET m_tela.dat_ini = TODAY - 780
   LET m_tela.dat_fim = TODAY
   
   INPUT BY NAME m_tela.* WITHOUT DEFAULTS 
   
      AFTER INPUT
         IF INT_FLAG THEN
            LET p_msg = 'Operação cancelada pelo usuário.'
            CLOSE WINDOW w_pol12731
            RETURN FALSE
         END IF
         
         IF m_tela.dat_ini IS NULL THEN
            LET m_tela.dat_ini = TODAY - 360
         END IF

         IF m_tela.dat_fim IS NULL THEN
            LET m_tela.dat_fim = TODAY
         END IF
         
         IF m_tela.dat_ini > m_tela.dat_fim THEN
            ERROR 'Periodo inválido.'
            NEXT FIELD dat_ini
         END IF
  
   END INPUT
   
   LET p_index = 1
   
   DECLARE cq_erro CURSOR FOR
   
   SELECT mensagem,
          numsequencia,
          datconsumo
     FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
      AND date(datconsumo) >= m_tela.dat_ini
      AND date(datconsumo) <= m_tela.dat_fim
    ORDER BY datconsumo,numsequencia                      
   
   FOREACH cq_erro INTO 
           pr_erro[p_index].mensagem,
           p_numsequencia,
           datconsumo_e
            
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cq_erro')
         RETURN FALSE
      END IF 
      
      SELECT codcorrida,
             numordem,
             coditem,
             numlote,
             qtdconsumida
        INTO pr_erro[p_index].codcorrida,
             pr_erro[p_index].numordem,
             pr_erro[p_index].coditem,
             pr_erro[p_index].numlote,
             pr_erro[p_index].qtdconsumida
        FROM cons_insumo_885
       WHERE codempresa = p_cod_empresa
         AND numsequencia = p_numsequencia
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'cons_insumo_885')
         RETURN FALSE
      END IF 
      
      LET pr_erro[p_index].datconsumo = DATE(datconsumo_e)
      
      LET p_index = p_index + 1

      IF p_index > 5000 THEN
         LET p_msg = 'Limite de erros soperou\n a quantidade máxima esperada',
                     'Alguns erros não serão\n exibidos'
         CALL log0030_mensagem(p_msg, 'info')
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Não há dados para o \n período informado.'
      CALL log0030_mensagem(p_msg, 'info')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY p_cod_empresa TO codempresa 
   
   DISPLAY ARRAY pr_erro TO sr_erro.*
   
   CLOSE WINDOW w_pol12731
   
   RETURN TRUE 

END FUNCTION 

#---------------------------------#
FUNCTION pol1273_exibe_pendentes()
#---------------------------------#

   DEFINE p_ano_mes CHAR(20),
          p_query   CHAR(500)

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1273a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1273a AT 04,14 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
      
   INITIALIZE pr_mes TO NULL
   LET p_ind = 1
   
   LET p_query = "SELECT DISTINCT ",
        " substring(CONVERT(CHAR(10),datconsumo,103),4,7) as ano_mes ",	
        " FROM cons_insumo_885 ",
        "WHERE codempresa = '",p_cod_empresa,"' ",
        "  AND statusregistro = 0 ",
        "ORDER BY ano_mes "
   
   PREPARE var_query FROM p_query   
   DECLARE cq_penden CURSOR FOR var_query
   
   FOREACH cq_penden INTO p_ano_mes
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_penden')
         CLOSE WINDOW w_pol1273a
         RETURN FALSE
      END IF
      
      LET pr_mes[p_ind].ano_mes = p_ano_mes
      LET p_ind = p_ind + 1
      
      IF p_ind > 200 THEN
         LET p_msg = 'Limite de linhas da grade estourou.'
         CALL log0030_mensagem(p_msg, 'info')
         EXIT FOREACH
      END IF          
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_mes TO sr_mes.*

   CLOSE WINDOW w_pol1273a
   
   RETURN TRUE
       
END FUNCTION

#-----------------------------#
FUNCTION pol1273_cria_tabela()#
#-----------------------------#

   CREATE TABLE proces_cons_885 (
     dat_proces        CHAR(19),
     processo          CHAR(20),
     empresa           CHAR(02),
     usuario           CHAR(08),
     mensagem          CHAR(80)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','proces_cons_885')
      RETURN FALSE
   END IF
   
   CREATE INDEX ix_proces_cons_885 ON
    proces_cons_885(empresa);
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','ix_proces_cons_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1273_ins_processo()#
#------------------------------#
   
   DEFINE l_dat_proces  CHAR(19)
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)

   INSERT INTO proces_cons_885
    VALUES(l_dat_proces,m_processo,p_cod_empresa,p_user, p_msg)

END FUNCTION   

#------------------------#
FUNCTION pol1273_versao()#
#------------------------#

   LET p_versao = 'pol1273-10.02.21  ' 

END FUNCTION

#---------------------------#
 FUNCTION pol1273_processar()
#---------------------------#

   CALL pol1273_versao()
   CALL func002_versao_prg(p_versao)

   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300
   DEFER INTERRUPT

   IF NOT log0150_verifica_se_tabela_existe("proces_cons_885") THEN
      IF NOT pol1273_cria_tabela() THEN
         RETURN 
      END IF
   END IF
   
   LET p_msg = 'INICIO do processamento'
   CALL pol1273_ins_processo()
   CALL pol1273_exec_proces() RETURNING p_status
   LET p_msg = 'FIM do processamento'
   CALL pol1273_ins_processo()   
   
   RETURN p_status

END FUNCTION

#-----------------------------#
FUNCTION pol1273_exec_proces()#
#-----------------------------#
   
   LET p_consu_criticado = 0
   LET p_consu_apontado = 0
   
   DISPLAY p_consu_criticado TO consu_criticado
   DISPLAY p_consu_apontado TO consu_apontado
   #lds CALL LOG_refresh_display()	
   
   LET p_msg = NULL

   IF NOT pol1273_le_parametros() THEN
      RETURN FALSE
   END IF

   DELETE FROM cons_erro_885
    WHERE codempresa = p_cod_empresa
      {AND numsequencia NOT IN
           (SELECT numsequencia FROM cons_insumo_885 
             WHERE codempresa = p_cod_empresa)}

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND qtd_saldo   <= 0

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND qtd_saldo   <= 0
    
   IF NOT pol1273_elimina_estornos() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1273_importa_consumo() THEN
      RETURN FALSE
   END IF

   IF NOT pol1273_importa_refugo() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1273_elimina_estornos()
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
     ORDER BY numsequencia

   FOREACH cq_cons_eli INTO 
           p_consu.num_sequencia,
           p_consu.num_ordem,
           p_consu.cod_item,
           p_consu.num_lote,
           p_consu.qtd_consumida,
           p_consu.dat_consumo

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO CONSUMO C/ ESTORNO (1)'
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

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO CONSUMO C/ ESTORNO (2)'
            RETURN FALSE
         END IF

         CALL log085_transacao("BEGIN")  
      
         UPDATE cons_insumo_885
            SET StatusRegistro = '77'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia IN (p_sequencia, p_num_seq_at)
            
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

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REFUGO C/ ESTORNO (1)'
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

         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REFUGO C/ ESTORNO (2)'
            RETURN FALSE
         END IF

         CALL log085_transacao("BEGIN")  
      
         UPDATE cons_insumo_885
            SET StatusRegistro = '77'
          WHERE codempresa   = p_cod_empresa
            AND numsequencia IN (p_sequencia, p_num_seq_at)
            
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

#------------------------------#
FUNCTION pol1273_le_parametros()
#------------------------------#

   SELECT cod_estoque_sp
     INTO p_cod_oper_sp
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO OPERACAO NA TAB PAR_PCP'
      RETURN FALSE
   END IF

   SELECT *
     INTO p_parametros_885.*
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO(',STATUS,')LENDO PARAMETROS_885'
      RETURN FALSE
   END IF
   
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO p_dat_fecha_ult_man,
          p_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_ESTOQUE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#importação do consumo de material

#--------------------------------#
FUNCTION pol1273_importa_consumo()
#--------------------------------#
      
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
           numloterefugo,
           datregistro
      FROM cons_insumo_885
     WHERE codempresa = p_cod_empresa
       AND statusregistro IN (0,2)
       #AND DATE(datconsumo) >= p_tela.dat_ini
       #AND DATE(datconsumo) <= p_tela.dat_fim
       AND iesrefugo = 'N'
     ORDER BY numordem,
              coditem,
              numlote,
              datconsumo,
              qtdconsumida, 
              estorno
 
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
           p_consu.num_loterefugo,
           p_consu.datregistro
           
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO CONSUMOS ENVIADOS PELO TRIM'
         RETURN FALSE
      END IF
      
      IF p_consu.qtd_refugada IS NULL THEN
         LET p_consu.qtd_refugada = 0
      END IF
      
      LET p_sequencia = p_consu.num_sequencia
      LET p_cod_registro = 2
      LET p_criticou = FALSE

      DISPLAY p_consu.cod_item TO cod_item
      #lds CALL LOG_refresh_display()	

      CALL log085_transacao("BEGIN")  

      #IF NOT pol1273_apaga_erros() THEN
      #   RETURN FALSE
      #END IF

      LET p_qtd_movto = p_consu.qtd_consumida
      LET p_dat_movto  = EXTEND(p_consu.dat_consumo, YEAR TO DAY)
      LET p_num_lote = p_consu.num_lote
      LET p_dat_proces = DATE(p_consu.datregistro)
      LET p_hor_operac = EXTEND(p_consu.datregistro, HOUR TO SECOND)
      
      IF p_num_lote = ' ' THEN
         LET p_num_lote = NULL
      END IF
     
      IF NOT pol1273_consiste_info() THEN
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF
      
      SELECT COUNT(*) 
        INTO p_count 
        FROM ord_benef_885
       WHERE cod_empresa = p_consu.cod_empresa
         AND num_ordem = p_consu.num_ordem
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORD_BENEF_885'
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF
      
      IF p_count > 0 THEN
         LET p_cod_local_baixa = 'BENEF_CIB'
      ELSE
         LET p_cod_local_baixa = NULL
      END IF 
      
      LET p_num_lote = p_consu.num_lote

      IF p_criticou THEN
      ELSE
         IF NOT pol1273_proces_consumo() THEN
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         ELSE
            IF NOT p_criticou THEN
               LET p_consu_apontado = p_consu_apontado + 1
               DISPLAY p_consu_apontado TO consu_apontado
               #lds CALL LOG_refresh_display()	
               LET p_cod_registro = 1  
            END IF
         END IF
      END IF
        
      IF NOT pol1273_grava_cons_trim() THEN
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF
   
      CALL log085_transacao("COMMIT")  

      INITIALIZE p_consu TO NULL
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1273_grava_cons_trim()
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
FUNCTION pol1273_apaga_erros()
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

#-----------------------------#
 FUNCTION pol1273_grava_erro()
#-----------------------------#

   LET p_criticou = TRUE
   LET p_dat_hor = CURRENT YEAR TO SECOND
   LET p_consu_criticado = p_consu_criticado + 1
   DISPLAY p_consu_criticado TO consu_criticado
   #lds CALL LOG_refresh_display()	

   INSERT INTO cons_erro_885
      VALUES (p_cod_empresa,
              p_sequencia,
              p_consu.dat_consumo,
              p_msg,
              p_dat_hor)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO CRITICAS DO CONSUMO'
      RETURN FALSE
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1273_pega_turno()#
#----------------------------#

   DEFINE p_minutos    SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04),
          p_tem_turno  SMALLINT
      
   LET p_hora = EXTEND(p_consu.dat_consumo, HOUR TO MINUTE)
   LET p_minutos = (p_hora[1,2] * 60) + p_hora[4,5]

   IF STATUS <> 0 THEN
      LET p_cod_turno = 1
      RETURN
   END IF
   
   LET p_tem_turno = FALSE
   
   DECLARE cq_turno CURSOR FOR
    SELECT cod_turno,
           hor_ini_normal,
           hor_fim_normal
     FROM turno
    WHERE cod_empresa = p_cod_empresa

   FOREACH cq_turno INTO 
           p_cod_turno,
           p_hor_ini,
           p_hor_fim

      IF STATUS <> 0 THEN
         EXIT FOREACH
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
         LET p_tem_turno = TRUE
         EXIT FOREACH
      END IF

   END FOREACH

   IF NOT p_tem_turno THEN
      LET p_cod_turno = 1
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1273_consiste_info()
#-------------------------------#

   DEFINE p_query         CHAR(800),
          l_qtd_consumida CHAR(10)

   IF p_consu.dat_consumo IS NOT NULL THEN

      CALL pol1273_pega_turno()

      IF p_dat_fecha_ult_man IS NOT NULL THEN
         IF p_dat_movto <= p_dat_fecha_ult_man THEN
            LET p_msg = 'CONSUMO APOS FECHAMENTO DA MANUFATURA NAO EH PERMITIDO'
            IF NOT pol1273_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
       END IF      

      IF p_dat_fecha_ult_sup IS NOT NULL THEN
         IF p_dat_movto <= p_dat_fecha_ult_sup THEN
            LET p_msg = 'CONSUMO APOS FECHAMENTO DO ESTOQUE NAO EH PERMITIDO'
            IF NOT pol1273_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   
   END IF

   IF p_qtd_movto IS NULL OR p_qtd_movto <= 0 THEN
      LET p_msg = 'QUANTIDADE ENVIADA NAO EH VALIDA'
      IF NOT pol1273_grava_erro() THEN
         RETURN FALSE
      END IF 
   END IF

   IF p_consu.Num_Sequencia IS NULL OR p_consu.Num_Sequencia = 0 THEN
      LET p_msg = 'CODIGO DE SEQUENCIA INVALIDO'
      IF NOT pol1273_grava_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_consu.cod_item IS NULL OR p_consu.cod_item = 0 THEN
      LET p_msg = 'CODIGO DO ITEM INVALIDO'
      IF NOT pol1273_grava_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1273_checa_item(p_consu.cod_item) THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1273_le_item_man(p_consu.cod_item) THEN
      RETURN FALSE
   END IF
   
   IF p_consu.num_lote = ' ' THEN
      LET p_consu.num_lote = NULL
   END IF
   
   IF p_ctr_lote = 'S' THEN
      IF p_consu.num_lote IS NULL THEN
         LET p_msg = 'NUMERO DO LOTE ESTA NULO'
         IF NOT pol1273_grava_erro() THEN
            RETURN FALSE
         END IF
     END IF
   ELSE
      LET p_consu.num_lote = NULL
   END IF

   IF p_consu.ies_refugo = 'N' THEN
      IF p_consu.num_ordem IS NULL OR p_consu.num_ordem = 0 THEN
         LET p_msg = 'OREM DE PRODUÇÃO INVALIDA'
         IF NOT pol1273_grava_erro() THEN
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
            IF NOT pol1273_grava_erro() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS <> 0 THEN
               LET p_msg = 'ERRO:(',STATUS, ') LENDO, P/ VALIDAR, TAB ORDENS'
               RETURN FALSE
            ELSE
               {SELECT COUNT(ordem_producao) 
                 FROM man_apo_mestre 
                WHERE empresa = p_cod_empresa
                  AND ordem_producao = p_consu.num_ordem
               IF STATUS <> 0 THEN
                  LET p_msg = 'ERRO:(',STATUS, ') CHECANDO APONTAMENTOS NA TAB MAN_APO_MESTRE'
                  RETURN FALSE
               END IF
               IF p_count = 0 THEN
                  LET p_msg = 'O TRIM ENVIOU CONSUMO P/ OF SEM APONTAMENTOS'
                  IF NOT pol1273_grava_erro() THEN
                     RETURN FALSE
                  END IF
               END IF}
            END IF
         END IF
      END IF

      IF p_consu.dat_consumo IS NULL THEN
         LET p_msg = 'DATA DO CONSUMO INVALIDA'
         IF NOT pol1273_grava_erro() THEN
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
         LET l_qtd_consumida = log2260_troca_virgula_por_ponto(p_consu.qtd_consumida)
         LET p_query = 
             "SELECT numsequencia FROM cons_insumo_885 ",
             "WHERE codempresa = '",p_consu.cod_empresa,"' ",
             " AND numordem = '",p_consu.num_ordem,"' ",
             " AND coditem = '",p_consu.cod_item,"' ",
             " AND numlote = '",p_num_lote,"' ",
             " AND qtdconsumida = '",l_qtd_consumida,"' ",
             " AND CONVERT(CHAR(19),datconsumo,120) = '",p_consu.dat_consumo,"' ",
             " AND estorno      = 0 ",
             " AND statusregistro = 1 "
      ELSE
         LET l_qtd_consumida = log2260_troca_virgula_por_ponto(p_consu.qtd_refugada)
         LET p_query = 
             "SELECT numsequencia FROM cons_insumo_885 ",
             "WHERE codempresa = '",p_consu.cod_empresa,"' ",
             " AND coditem = '",p_consu.cod_item,"' ",
             " AND numlote = '",p_num_lote,"' ",
             " AND qtdrefugada = '",l_qtd_consumida,"' ",
             " AND CONVERT(CHAR(19),datconsumo,120) = '",p_consu.dat_consumo,"' ",
             " AND estorno      = 0 ",
             " AND statusregistro = 1 "
      END IF
      
      PREPARE var_query2 FROM p_query   
      DECLARE cq_seqs CURSOR FOR var_query2
      FOREACH cq_seqs INTO p_num_seq_cons
         EXIT FOREACH
      END FOREACH
      
      IF p_num_seq_cons IS NULL THEN
         LET p_msg = 'ESTORNO DE CONSUMO NAO ENVIADO AO LOGIX'
         IF NOT pol1273_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
      
   END IF

   IF NOT p_criticou AND p_consu.ies_refugo = 'N' THEN
   
      IF p_consu.cod_estorno = 1 THEN
      
         SELECT COUNT(num_seq_cons)
           INTO p_count
           FROM trans_consu_885
          WHERE cod_empresa  = p_cod_empresa
            AND num_seq_cons = p_num_seq_cons
            AND tip_movto = 'N'
      
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA TRANS_CONSU_885'  
            RETURN FALSE
         END IF
  
         IF p_count = 0 THEN
            LET p_msg = 'MOVIMENTO DE CONSUMO CORRESPONDENTE AO ESTORNO NAO FOI ENCONTRADO'
            IF NOT pol1273_grava_erro() THEN
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
   
   IF p_ies_apara = 'S' THEN
      IF p_ctr_estoque = 'N' THEN
         LET p_msg = p_cod_prod CLIPPED,' - ESSE MATERIAL NAO SOFRE BAIXA'
         IF NOT pol1273_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
      IF p_sobre_baixa = 'S' THEN
         LET p_msg = p_cod_prod CLIPPED,' - ITEM QUE SOFRE BAIXA DEVE SER BAIXADO PELA ESTRUTURA'
         IF NOT pol1273_grava_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_consu.cod_itemrefugo IS NOT NULL THEN
      IF p_ies_apara = 'S' THEN
         IF NOT pol1273_checa_item(p_consu.cod_itemrefugo) THEN
            RETURN FALSE
         END IF
         IF p_consu.num_loterefugo IS NULL THEN
            LET p_msg = 'FALTA O LOTE PARA O ITEM REFUGO ', p_consu.cod_itemrefug
            IF NOT pol1273_grava_erro() THEN
               RETURN FALSE
            END IF
         END IF
         LET p_cod_item_refugo = p_consu.cod_itemrefugo
         LET p_cod_local_refug = p_cod_local_estoq
         LET p_num_lote_refugo = p_consu.num_loterefugo
      ELSE
         INITIALIZE p_consu.cod_itemrefugo, 
                    p_consu.num_loterefugo TO NULL
      END IF
   ELSE
      IF NOT pol1273_checa_item(p_parametros_885.cod_item_refugo) THEN
         RETURN FALSE
      END IF
      LET p_cod_item_refugo = p_parametros_885.cod_item_refugo
      LET p_cod_local_refug = p_cod_local_estoq
      LET p_num_lote_refugo = p_parametros_885.num_lote_refugo   
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

      CALL pol1273_pega_pedido()
   
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1273_checa_item(p_cod_item)
#--------------------------------------#
   
   DEFINE p_cod_item LIKE item.cod_item
   
   SELECT cod_local_estoq
     INTO p_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS = 100 THEN
      LET p_msg = 'ITEM:',p_cod_item CLIPPED,' INIXISTENTE'
      IF NOT pol1273_grava_erro() THEN
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

#-----------------------------------#
FUNCTION pol1273_le_item_man(p_item)
#-----------------------------------#
   
   DEFINE p_item       LIKE item.cod_item
   
   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.cod_familia,
          b.ies_sofre_baixa,
          ies_tip_item,
          cod_lin_prod
     INTO p_cod_local_estoq,
          p_ctr_estoque,
          p_ctr_lote,
          p_cod_familia,
          p_sobre_baixa,
          p_ies_tip_item,
          p_cod_lin_prod
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_item
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS = 100 THEN
      LET p_msg = p_cod_prod CLIPPED,' - NAO CADASTRADO NA MANUFATURA'
      IF NOT pol1273_grava_erro() THEN
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ITEM/ITEM_MAN'  
         RETURN FALSE
      END IF
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1273_pega_pedido()
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
FUNCTION pol1273_proces_consumo()
#-------------------------------#
            
   IF p_consu.cod_estorno = 0 THEN
      IF NOT pol1273_baixa_consumo() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1273_estorna_conusmo() THEN
         RETURN FALSE
      END IF
   END IF  
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1273_baixa_consumo()
#------------------------------#

   DEFINE p_fat_conversao      DECIMAL(17,10),
          c_fat_conversao      CHAR(20),
          p_tolerancia         DECIMAL(10,3),
          p_diferenca          DECIMAL(10,3)

   LET p_ies_situa = 'L'
   LET p_ies_tip_movto = 'N'
   LET p_tip_operacao = 'S'
   LET p_msg = NULL
   
   CALL pol1273_le_lote_ender()
 
   IF p_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   LET p_bx_trim = p_qtd_movto
   
   IF p_qtd_movto > p_estoque_lote_ender.qtd_saldo THEN
      LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
   END IF
         
   LET p_tolerancia = p_parametros_885.tol_bx_aparas
   
   IF p_tolerancia > 0 THEN
      IF p_qtd_movto < p_estoque_lote_ender.qtd_saldo THEN
         LET p_diferenca = p_estoque_lote_ender.qtd_saldo - p_qtd_movto
         IF p_diferenca <= p_tolerancia THEN
            LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
         END IF
      END IF
   END IF

   LET p_bx_logix = p_qtd_movto
   
   IF NOT pol1273_gra_relac() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_movto <= 0 THEN     
      RETURN TRUE
   END IF
   
   LET p_qtd_baixar = p_qtd_movto
   LET p_qtd_movto = 0

   IF NOT pol1273_efetua_baixa() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1273_gra_relac()#
#---------------------------#

   INSERT INTO baixa_aparas_885 (
      cod_empresa, 
      dat_movto,   
      cod_item,    
      qtd_bx_trim, 
      qtd_bx_logix,
      num_ordem)   
     VALUES(p_cod_empresa,
            p_consu.dat_consumo,
            p_consu.cod_item,
            p_bx_trim,
            p_bx_logix,
            p_consu.num_ordem)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','baixa_aparas_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION                  
   
#-------------------------------#
FUNCTION pol1273_le_lote_ender()
#-------------------------------#

   IF p_cod_local_baixa IS NOT NULL THEN
      LET p_cod_local_estoq = p_cod_local_baixa   
   ELSE
      IF NOT pol1273_checa_item(p_consu.cod_item) THEN
         RETURN FALSE
      END IF
   END IF

   IF p_num_lote IS NOT NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_consu.cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote = p_num_lote 
         AND qtd_saldo > 0
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_consu.cod_item
         AND cod_local = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND (num_lote IS NULL OR num_lote = ' ')
         AND qtd_saldo > 0
   END IF

   IF STATUS = 100 THEN
      LET p_estoque_lote_ender.qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_LOTE_ENDER'
         RETURN
      END IF
   END IF

   IF p_num_lote IS NOT NULL THEN
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item = p_estoque_lote_ender.cod_item
         AND cod_local = p_estoque_lote_ender.cod_local
         AND num_lote = p_estoque_lote_ender.num_lote 
   ELSE
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item = p_estoque_lote_ender.cod_item
         AND cod_local = p_estoque_lote_ender.cod_local
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF
      
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN
   END IF  
   
   IF p_qtd_reservada IS NULL THEN
      LET p_qtd_reservada = 0
   END IF
   
   IF p_estoque_lote_ender.qtd_saldo > p_qtd_reservada THEN
      LET p_estoque_lote_ender.qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reservada
   ELSE
      LET p_estoque_lote_ender.qtd_saldo = 0
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol1273_efetua_baixa()#
#------------------------------#   
   
   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0


   LET p_item.cod_empresa   = p_estoque_lote_ender.cod_empresa
   LET p_item.cod_item      = p_estoque_lote_ender.cod_item
   LET p_item.cod_local     = p_estoque_lote_ender.cod_local   
   LET p_item.num_lote      = p_estoque_lote_ender.num_lote
   LET p_item.comprimento   = p_estoque_lote_ender.comprimento
   LET p_item.largura       = p_estoque_lote_ender.largura    
   LET p_item.altura        = p_estoque_lote_ender.altura     
   LET p_item.diametro      = p_estoque_lote_ender.diametro  
   LET p_item.cod_operacao  = p_cod_oper_sp
   LET p_item.ies_situa     = p_estoque_lote_ender.ies_situa_qtd
   LET p_item.qtd_movto     = p_qtd_baixar
   LET p_item.dat_movto     = p_dat_movto
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.num_prog      = 'POL1273'
   LET p_item.num_docum     = p_consu.num_ordem
   LET p_item.num_seq       = 0   
   LET p_item.tip_operacao  = p_tip_operacao 
   LET p_item.usuario       = p_user
   LET p_item.cod_turno     = p_cod_turno
   LET p_item.trans_origem  = 0
   
   SELECT ies_ctr_lote
     INTO p_item.ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA TRANS_CONSU_885'  
      RETURN FALSE
   END IF   

   IF p_item.ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   END IF
   
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF

   IF NOT pol1273_ins_transacoes() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1273_ins_transacoes()
#-------------------------------#

   IF p_consu.cod_estorno = 0 THEN
      
      INSERT INTO trans_consu_885
        VALUES(p_cod_empresa, 
               p_sequencia, 
               p_num_trans_atual,
               p_tip_operacao,
               p_ies_tip_movto)

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA TRANS_CONSU_885'  
         RETURN FALSE
      END IF   
   END IF
   
   RETURN TRUE
      
END FUNCTION

#----------------------------------#
FUNCTION pol1273_bx_do_alternativo()
#----------------------------------#

   DECLARE cq_alternativo CURSOR FOR
    SELECT a.*
      FROM estoque_lote_ender a,
           apara_alternat_885 b,
           item c
       WHERE a.cod_empresa = p_cod_empresa
         AND b.cod_empresa = a.cod_empresa
         AND b.cod_item = a.cod_item
         AND c.cod_empresa = a.cod_empresa
         AND c.cod_item = a.cod_item
         AND c.cod_local_estoq = a.cod_local
         AND a.ies_situa_qtd = p_ies_situa
         AND a.qtd_saldo > 0

   FOREACH cq_alternativo INTO p_estoque_lote_ender.*

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITENS ALTERNATIVOS/CQ_ALTERNATIVO'
         RETURN FALSE
      END IF

      IF p_qtd_movto <= p_estoque_lote_ender.qtd_saldo THEN
         LET p_qtd_baixar = p_qtd_movto
         LET p_qtd_movto = 0
      ELSE
         LET p_qtd_baixar = p_estoque_lote_ender.qtd_saldo
         LET p_qtd_movto = p_qtd_movto - p_qtd_baixar
      END IF
   
      IF p_qtd_baixar > 0 THEN
         IF NOT pol1273_efetua_baixa() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF p_qtd_movto <= 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1273_estorna_conusmo()
#--------------------------------#

   LET p_tip_operacao = 'S'
   LET p_ies_tip_movto = 'R'
   LET p_tip_reversao = 'S'
   
   DECLARE cq_trans_s CURSOR FOR
    SELECT num_transac
      FROM trans_consu_885
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_cons = p_num_seq_cons
       AND tip_operacao = 'S'
       AND tip_movto = 'N'
   
   FOREACH cq_trans_s INTO p_num_transac
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA TRANS_CONSU_885/CQ_TRANS_S'  
         RETURN FALSE
      END IF
            
      IF NOT pol1273_estorna_estoq() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   UPDATE trans_consu_885
      SET tip_movto = 'R'
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_cons = p_num_seq_cons

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO TABELA TRANS_CONSU_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1273_estorna_estoq()#
#--------------------------------#

   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD
   
   DEFINE p_estoque_trans RECORD LIKE estoque_trans.*

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
   
   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF
         
   LET p_item.cod_empresa   = p_estoque_trans.cod_empresa
   LET p_item.cod_item      = p_estoque_trans.cod_item
   LET p_item.cod_operacao  = p_estoque_trans.cod_operacao
   LET p_item.qtd_movto     = p_estoque_trans.qtd_movto   
   LET p_item.dat_movto     = p_estoque_trans.dat_movto   
   LET p_item.num_prog      = p_estoque_trans.num_prog 
   LET p_item.num_docum     = p_estoque_trans.num_docum
   LET p_item.num_seq       = p_estoque_trans.num_seq  
   LET p_item.trans_origem  = p_estoque_trans.num_transac
      
   IF p_tip_reversao = 'S' THEN
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_orig
      LET p_item.num_lote      = p_estoque_trans.num_lote_orig
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_orig
   ELSE
      LET p_item.cod_local     = p_estoque_trans.cod_local_est_dest
      LET p_item.num_lote      = p_estoque_trans.num_lote_dest
      LET p_item.ies_situa     = p_estoque_trans.ies_sit_est_dest  
   END IF

   SELECT comprimento,
          largura,    
          altura,     
          diametro   
     INTO p_item.comprimento,  
          p_item.largura,      
          p_item.altura,       
          p_item.diametro     
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF
      
   LET p_item.tip_operacao  = p_tip_operacao 
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.usuario       = p_estoque_trans.nom_usuario
   LET p_item.cod_turno     = p_estoque_trans.cod_turno

   SELECT ies_ctr_lote
     INTO p_item.ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA TRANS_CONSU_885'  
      RETURN FALSE
   END IF   

   IF p_item.ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   END IF
         
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#Importação de refugos

#-------------------------------#
FUNCTION pol1273_importa_refugo()
#-------------------------------#

   INITIALIZE p_consu TO NULL
   LET p_cod_local_baixa = NULL
   
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
           numloterefugo,
           datregistro
      FROM cons_insumo_885
     WHERE codempresa = p_cod_empresa
       AND statusregistro IN (0,2)
       #AND DATE(datconsumo) >= p_tela.dat_ini
       #AND DATE(datconsumo) <= p_tela.dat_fim
       AND iesrefugo = 'S'
     ORDER BY numordem,
              coditem,
              numlote,
              datconsumo,
              qtdconsumida, 
              estorno
 
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
           p_consu.num_loterefugo,
           p_consu.datregistro
           
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO CONSUMOS ENVIADOS PELO TRIM'
         RETURN FALSE
      END IF
      
      IF p_consu.qtd_refugada IS NULL THEN
         LET p_consu.qtd_refugada = 0
      END IF
      
      LET p_consu.qtd_consumida = p_consu.qtd_refugada
      LET p_sequencia = p_consu.num_sequencia
      LET p_cod_registro = 2
      LET p_criticou = FALSE

      DISPLAY p_consu.cod_item TO cod_item
      #lds CALL LOG_refresh_display()	

      CALL log085_transacao("BEGIN")  

      #IF NOT pol1273_apaga_erros() THEN
      #   RETURN FALSE
      #END IF

      LET p_qtd_movto = p_consu.qtd_consumida
      LET p_dat_movto  = EXTEND(p_consu.dat_consumo, YEAR TO DAY)
      LET p_num_lote = p_consu.num_lote
      LET p_dat_proces = DATE(p_consu.datregistro)
      LET p_hor_operac = EXTEND(p_consu.datregistro, HOUR TO SECOND)
      
      IF p_num_lote = ' ' THEN
         LET p_num_lote = NULL
      END IF
     
      IF NOT pol1273_consiste_info() THEN
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF

      LET p_num_lote = p_consu.num_lote

      IF p_criticou THEN
      ELSE
         IF NOT pol1273_proces_refugo() THEN
            CALL log085_transacao("ROLLBACK")  
            RETURN FALSE
         ELSE
            IF NOT p_criticou THEN
               LET p_consu_apontado = p_consu_apontado + 1
               DISPLAY p_consu_apontado TO consu_apontado
               #lds CALL LOG_refresh_display()	
               LET p_cod_registro = 1  
            END IF
         END IF
      END IF
        
      IF NOT pol1273_grava_cons_trim() THEN
         CALL log085_transacao("ROLLBACK")  
         RETURN FALSE
      END IF
   
      CALL log085_transacao("COMMIT")  

      INITIALIZE p_consu TO NULL
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1273_proces_refugo()
#------------------------------#
            
   IF p_consu.cod_estorno = 0 THEN
      IF NOT pol1273_baixa_refugo() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1273_estorna_refugo() THEN
         RETURN FALSE
      END IF
   END IF  
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1273_baixa_refugo()
#-----------------------------#

   {IF NOT pol1273_le_oper_orig() THEN
      RETURN FALSE
   END IF}
   
   LET p_cod_operacao = p_parametros_885.oper_sai_tp_refugo   

   LET p_ies_tip_movto = 'N'
   LET p_ies_situa = 'L'
   LET p_tip_operacao = 'S'
   LET p_msg = NULL

   CALL pol1273_le_lote_ender()

   IF p_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_bobina THEN
      IF p_estoque_lote_ender.qtd_saldo < p_qtd_movto THEN
         LET p_ies_situa = 'E'
         CALL pol1273_le_lote_ender()
         IF p_msg IS NOT NULL THEN
            RETURN FALSE
         END IF
      END IF
   END IF

   IF p_estoque_lote_ender.qtd_saldo < p_qtd_movto THEN
      LET p_msg = 'ITEM SEM SALDO SUFICIENTE P/ TRANSFERIR P/ REFUGO'
      IF NOT pol1273_grava_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   LET p_qtd_baixar = p_qtd_movto
   LET p_cod_oper_sp = p_cod_operacao

   IF NOT pol1273_efetua_baixa() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE p_est_trans_relac TO NULL
   
   LET p_est_trans_relac.cod_empresa = p_cod_empresa
   LET p_est_trans_relac.num_nivel = 0
   LET p_est_trans_relac.num_transac_orig = p_num_trans_atual
   LET p_est_trans_relac.cod_item_orig = p_estoque_lote_ender.cod_item
   LET p_est_trans_relac.dat_movto = p_qtd_baixar   
   
   LET p_tip_operacao = 'E'

   {IF NOT pol1273_le_oper_dest() THEN
      RETURN FALSE
   END IF}

   LET p_cod_operacao = p_parametros_885.oper_ent_tp_refugo   

   LET p_cod_item  = p_cod_item_refugo
   LET p_num_lote  = p_num_lote_refugo
   LET p_cod_local = p_cod_local_refug

   LET p_ies_tip_movto = 'N'
   LET p_ies_situa = 'L'
   LET p_tip_operacao = 'E'
   
   IF NOT pol1273_grava_destino() THEN
      RETURN FALSE
   END IF

   LET p_est_trans_relac.num_transac_dest = p_num_trans_atual
   LET p_est_trans_relac.cod_item_dest = p_cod_item

   IF NOT pol1273_ins_est_trans_relac() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1273_ins_est_trans_relac()#
#-------------------------------------#
   
   INSERT INTO est_trans_relac(
      cod_empresa,
      num_nivel,
      num_transac_orig,
      cod_item_orig,
      num_transac_dest,
      cod_item_dest,
      dat_movto)
   VALUES(p_est_trans_relac.*)

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO DADOS NA TABELA EST_TRANS_RELAC'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1273_le_oper_orig()
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
FUNCTION pol1273_le_oper_dest()
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

#-------------------------------#
FUNCTION pol1273_grava_destino()#
#-------------------------------#   
   
   DEFINE p_item       RECORD                   
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote      LIKE estoque_lote.num_lote,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         cod_operacao  LIKE estoque_trans.cod_operacao,  
         ies_situa     LIKE estoque_lote_ender.ies_situa_qtd,
         qtd_movto     LIKE estoque_trans.qtd_movto,
         dat_movto     LIKE estoque_trans.dat_movto,
         ies_tip_movto LIKE estoque_trans.ies_tip_movto,
         dat_proces    LIKE estoque_trans.dat_proces,
         hor_operac    LIKE estoque_trans.hor_operac,
         num_prog      LIKE estoque_trans.num_prog,
         num_docum     LIKE estoque_trans.num_docum,
         num_seq       LIKE estoque_trans.num_seq,
         tip_operacao  CHAR(01),
         usuario       CHAR(08),
         cod_turno     INTEGER,
         trans_origem  INTEGER,
         ies_ctr_lote  CHAR(01),
         num_conta     CHAR(20),
         cus_unit      DECIMAL(12,2),
         cus_tot       DECIMAL(12,2)
   END RECORD

   LET p_item.cus_unit      = 0
   LET p_item.cus_tot       = 0
            
   LET p_item.cod_empresa   = p_cod_empresa
   LET p_item.cod_item      = p_cod_item
   LET p_item.cod_local     = p_cod_local

   SELECT ies_ctr_lote
     INTO p_item.ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_item.cod_empresa
      AND cod_item = p_item.cod_item

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TABELA TRANS_CONSU_885'  
      RETURN FALSE
   END IF   

   IF p_item.ies_ctr_lote = 'N' THEN
      LET p_item.num_lote = NULL
   END IF
         
   LET p_item.comprimento   = 0
   LET p_item.largura       = 0    
   LET p_item.altura        = 0     
   LET p_item.diametro      = 0  
    
   LET p_item.cod_operacao  = p_cod_operacao
   
   LET p_item.ies_situa     = p_ies_situa
   LET p_item.qtd_movto     = p_qtd_movto
   LET p_item.dat_movto     = p_dat_movto
   LET p_item.ies_tip_movto = p_ies_tip_movto
   LET p_item.dat_proces    = p_dat_proces
   LET p_item.hor_operac    = p_hor_operac
   LET p_item.num_prog      = 'POL1273'
   LET p_item.num_docum     = p_consu.num_ordem
   LET p_item.num_seq       = 0
   
   LET p_item.tip_operacao  = p_tip_operacao
   
   LET p_item.usuario       = p_user
   LET p_item.cod_turno     = p_cod_turno
   LET p_item.trans_origem  = 0
   
   IF NOT func005_insere_movto(p_item) THEN
      RETURN FALSE
   END IF

   IF NOT pol1273_ins_transacoes() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1273_estorna_refugo()
#--------------------------------#

   LET p_ies_tip_movto = 'R'
   
   DECLARE cq_est_ref CURSOR FOR
    SELECT num_transac,
           tip_operacao
      FROM trans_consu_885
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_cons = p_num_seq_cons
       AND tip_movto = 'N'
   
   FOREACH cq_est_ref INTO p_num_transac, p_tip_operacao
      
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO DADOS NA TABELA TRANS_CONSU_885/CQ_EST_REF'  
         RETURN FALSE
      END IF

      LET p_tip_reversao = p_tip_operacao
            
      IF NOT pol1273_estorna_estoq() THEN
         RETURN FALSE
      END IF
      
   END FOREACH

   UPDATE trans_consu_885
      SET tip_movto = 'R'
     WHERE cod_empresa = p_cod_empresa
       AND num_seq_cons = p_num_seq_cons

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ESTORNANDO TABELA TRANS_CONSU_885'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-------------------------------#
FUNCTION pol1273_lst_confronto()#
#-------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1273c") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1273c AT 6,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol1273_lista_baixas() RETURNING p_status
   
   CLOSE WINDOW w_pol1273c
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol1273_lista_baixas()#
#------------------------------#


   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   LET p_tela.listar = 'I'
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS 
   
      AFTER INPUT
         IF INT_FLAG THEN
            RETURN FALSE
         END IF
         
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD dat_ini
         END IF

         IF p_tela.dat_fim IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD dat_fim
         END IF
         
         IF p_tela.dat_ini > p_tela.dat_fim THEN
            ERROR 'Periodo inválido.'
            NEXT FIELD dat_ini
         END IF
  
   END INPUT

   IF NOT pol1273_le_den_empresa() THEN
      RETURN FALSE
   END IF

   IF p_tela.listar = 'I' THEN
      IF NOT pol1273_agrupa_item() THEN
         RETURN FALSE
      END IF      
   ELSE
      IF NOT pol1273_detalhado() THEN
         RETURN FALSE
      END IF      
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1273_agrupa_item()#
#-----------------------------#

   IF NOT pol1273_inicializa_relat() THEN
      RETURN FALSE
   END IF
         
   DECLARE cq_confronto CURSOR FOR
    SELECT cod_item, 
           dat_movto, 
           SUM(qtd_bx_trim), 
           SUM(qtd_bx_logix)
      FROM baixa_aparas_885 
     WHERE cod_empresa = p_cod_empresa
      AND DATE(dat_movto) >= p_tela.dat_ini
      AND DATE(dat_movto) <= p_tela.dat_fim
    GROUP BY cod_item, dat_movto
    ORDER BY cod_item, dat_movto

   FOREACH cq_confronto INTO p_relat.*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_confronto')
         EXIT FOREACH
      END IF
      
      DISPLAY p_relat.cod_item TO mensagem
      #lds CALL LOG_refresh_display()	
      
      LET p_dat_movto = DATE(p_relat.dat_movto)
      LET p_hor_movto = EXTEND(p_relat.dat_movto, HOUR TO SECOND)
      
      LET p_dif_baixa = p_relat.qtd_bx_trim - p_relat.qtd_bx_logix
      
      OUTPUT TO REPORT pol1273_relat(p_relat.cod_item) 
      
      LET p_count = 1
      
    END FOREACH

   CALL pol1273_finaliza_relat()
   CALL log0030_mensagem(p_msg, 'excla')
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1273_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol1273_inicializa_relat()#
#----------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1273_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1273.tmp' 
         START REPORT pol1273_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1273_relat TO p_nom_arquivo
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1273_finaliza_relat()
#--------------------------------#

   FINISH REPORT pol1273_relat
   
   IF p_count = 0 THEN
      LET p_msg = "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF
     
END FUNCTION 

#--------------------------------#
 REPORT pol1273_relat(l_cod_item)#
#--------------------------------#
    
   DEFINE l_cod_item        CHAR(15)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
     
      ORDER EXTERNAL BY l_cod_item          
   
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 046, 'CONSUMO DE APARAS',
               COLUMN 073, 'PAG. ', PAGENO USING '##&'
         PRINT COLUMN 001, 'PERIODO DE:',
               COLUMN 013, p_tela.dat_ini USING 'dd/mm/yyyy',
               COLUMN 024, 'ATE:',
               COLUMN 029, p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 053, 'EMISSAO:',
               COLUMN 062, TODAY, ' ', TIME
         PRINT '--------------------------------------------------------------------------------'
        
      PAGE HEADER
	  
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item, 
               COLUMN 073, 'PAG. ', PAGENO USING '##&'               
         PRINT
         PRINT COLUMN 001, '  DATA DO CONSUMO         ENVIADO TRIM      BAIXADO NO LOGIX        DIFERENCA'
         PRINT COLUMN 001, '--------------------     --------------     ----------------    ----------------'

      BEFORE GROUP OF l_cod_item

         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_relat.cod_item
      
         IF STATUS <> 0 THEN
            LET p_den_item = 'NAO CADASTRADO'
         END IF
         
         PRINT
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item
         PRINT
         PRINT COLUMN 001, '  DATA DO CONSUMO         ENVIADO TRIM      BAIXADO NO LOGIX        DIFERENCA'
         PRINT COLUMN 001, '--------------------     --------------     ----------------    ----------------'
      
      ON EVERY ROW
         
         PRINT COLUMN 001, p_dat_movto, ' ', p_hor_movto,
               COLUMN 026, p_relat.qtd_bx_trim USING '##,###,##&.&&&',
               COLUMN 045, p_relat.qtd_bx_logix USING '##,###,##&.&&&',
               COLUMN 065, p_dif_baixa USING '##,###,##&.&&&'

      AFTER GROUP OF l_cod_item
         
         PRINT
         PRINT COLUMN 001, 'Total do item:',
               COLUMN 026, GROUP SUM(p_relat.qtd_bx_trim) USING '##,###,##&.&&&',
               COLUMN 045, GROUP SUM(p_relat.qtd_bx_logix) USING '##,###,##&.&&&',
               COLUMN 065, GROUP SUM(p_dif_baixa) USING '##,###,##&.&&&'
         PRINT
                                             
      ON LAST ROW

         PRINT
         PRINT COLUMN 001, 'Total geral:',
               COLUMN 026, SUM(p_relat.qtd_bx_trim) USING '##,###,##&.&&&',
               COLUMN 045, SUM(p_relat.qtd_bx_logix) USING '##,###,##&.&&&',
               COLUMN 065, SUM(p_dif_baixa) USING '##,###,##&.&&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#---------------------------#
FUNCTION pol1273_detalhado()#
#---------------------------#

   IF NOT pol1273_start_relat() THEN
      RETURN FALSE
   END IF
         
   DECLARE cq_ordem CURSOR FOR
    SELECT *
      FROM baixa_aparas_885 
     WHERE cod_empresa = p_cod_empresa
      AND DATE(dat_movto) >= p_tela.dat_ini
      AND DATE(dat_movto) <= p_tela.dat_fim
    ORDER BY cod_item, dat_movto, num_ordem

   FOREACH cq_ordem INTO p_detal.*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_ordem')
         EXIT FOREACH
      END IF
      
      DISPLAY p_detal.cod_item TO mensagem
      #lds CALL LOG_refresh_display()	
      
      LET p_dat_movto = DATE(p_detal.dat_movto)
      LET p_hor_movto = EXTEND(p_detal.dat_movto, HOUR TO SECOND)
      
      LET p_dif_baixa = p_detal.qtd_bx_trim - p_detal.qtd_bx_logix
      
      OUTPUT TO REPORT pol1273_detal(p_detal.cod_item) 
      
      LET p_count = 1
      
    END FOREACH

   CALL pol1273_stop_relat()
   CALL log0030_mensagem(p_msg, 'excla')
   
   RETURN TRUE


END FUNCTION

#-----------------------------#
FUNCTION pol1273_start_relat()#
#-----------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1273_detal TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1273.tmp' 
         START REPORT pol1273_detal TO p_caminho 
      END IF 
   ELSE
      START REPORT pol1273_detal TO p_nom_arquivo
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1273_stop_relat()#
#----------------------------#

   FINISH REPORT pol1273_detal
   
   IF p_count = 0 THEN
      LET p_msg = "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF
     
END FUNCTION 

#--------------------------------#
 REPORT pol1273_detal(l_cod_item)#
#--------------------------------#
    
   DEFINE l_cod_item        CHAR(15)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
     
      ORDER EXTERNAL BY l_cod_item          
   
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 046, 'CONSUMO DE APARAS',
               COLUMN 073, 'PAG. ', PAGENO USING '##&'
         PRINT COLUMN 001, 'PERIODO DE:',
               COLUMN 013, p_tela.dat_ini USING 'dd/mm/yyyy',
               COLUMN 024, 'ATE:',
               COLUMN 029, p_tela.dat_fim USING 'dd/mm/yyyy',
               COLUMN 053, 'EMISSAO:',
               COLUMN 062, TODAY, ' ', TIME
         PRINT '--------------------------------------------------------------------------------'
        
      PAGE HEADER
	  
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item, 
               COLUMN 073, 'PAG. ', PAGENO USING '##&'               
         PRINT
         PRINT COLUMN 001, '  DATA DO CONSUMO     ORDEM     ENVIADO TRIM  BAIXADO NO LOGIX    DIFERENCA'
         PRINT COLUMN 001, '-------------------- --------- -------------- ---------------- ----------------'

      BEFORE GROUP OF l_cod_item

         SELECT den_item
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_detal.cod_item
      
         IF STATUS <> 0 THEN
            LET p_den_item = 'NAO CADASTRADO'
         END IF
         
         PRINT
         PRINT COLUMN 001,  'Item: ', l_cod_item, ' - ', p_den_item
         PRINT
         PRINT COLUMN 001, '  DATA DO CONSUMO     ORDEM     ENVIADO TRIM  BAIXADO NO LOGIX    DIFERENCA'
         PRINT COLUMN 001, '-------------------- --------- -------------- ---------------- ----------------'

      ON EVERY ROW
         
         PRINT COLUMN 001, p_dat_movto, ' ', p_hor_movto,
               COLUMN 022, p_detal.num_ordem USING '########&',
               COLUMN 032, p_detal.qtd_bx_trim USING '##,###,##&.&&&',
               COLUMN 047, p_detal.qtd_bx_logix USING '##,###,##&.&&&',
               COLUMN 064, p_dif_baixa USING '##,###,##&.&&&'

      AFTER GROUP OF l_cod_item
         
         PRINT
         PRINT COLUMN 001, 'Total do item:',
               COLUMN 032, GROUP SUM(p_detal.qtd_bx_trim) USING '##,###,##&.&&&',
               COLUMN 047, GROUP SUM(p_detal.qtd_bx_logix) USING '##,###,##&.&&&',
               COLUMN 064, GROUP SUM(p_dif_baixa) USING '##,###,##&.&&&'
         PRINT
                                             
      ON LAST ROW

         PRINT
         PRINT COLUMN 001, 'Total geral:',
               COLUMN 032, SUM(p_detal.qtd_bx_trim) USING '##,###,##&.&&&',
               COLUMN 047, SUM(p_detal.qtd_bx_logix) USING '##,###,##&.&&&',
               COLUMN 064, SUM(p_dif_baixa) USING '##,###,##&.&&&'

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-----------------------------#
FUNCTION pol1273_envia_email()#
#-----------------------------#
   
   DEFINE l_email        CHAR(50),
          l_erro         CHAR(10)
   
   CALL log150_procura_caminho("LST") RETURNING p_caminho
   
   LET p_assunto = 'Consumo de aparas'

   SELECT parametro_texto
     INTO p_email_remetente
     FROM min_par_modulo 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'EMITENT_EMAIL_APARAS'

   IF STATUS <> 0 THEN
      RETURN
   END IF
   
   LET p_nom_remetente = 'Não responda - mensagem automática'
   LET p_email_destinatario = ""
   LET p_count = 0
   
   DECLARE cq_envia CURSOR FOR
    SELECT email FROM usuario_notif_885
     WHERE enviar = 'S'
   
   FOREACH cq_envia INTO l_email
      
      IF STATUS <> 0 THEN
         RETURN
      END IF
      
      IF p_count = 0 THEN
         LET p_email_destinatario = p_email_destinatario CLIPPED, l_email CLIPPED
      ELSE
         LET p_email_destinatario = p_email_destinatario CLIPPED, ';', l_email CLIPPED
      END IF
      
      LET p_count = p_count + 1
      
   END FOREACH
      
   LET p_nom_destinatario = ''   

   LET p_titulo1 = 'Prezado Sr.(a): ', p_nom_destinatario
      
   LET l_erro = m_qtd_erro USING '<<<<<<<<<<'
      
   LET p_titulo2 = 
         'Integração de consumo entre Trim Papel e Logix'

   LET p_imp_linha = 'Contem ', l_erro, ' registros criticados'
        
   LET p_arquivo = 'pol1273.lst'
   LET p_den_comando = p_caminho CLIPPED, p_arquivo CLIPPED
         
   START REPORT pol1273_email TO p_den_comando
     
   OUTPUT TO REPORT pol1273_email() 
      
   FINISH REPORT pol1273_email  
      
   CALL log5600_envia_email(p_email_remetente, p_email_destinatario, p_assunto, p_den_comando, 2)

END FUNCTION

#---------------------#
 REPORT pol1273_email()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 60
          
   FORMAT
          
      FIRST PAGE HEADER  
         
         PRINT COLUMN 001, p_titulo1
         PRINT
         PRINT COLUMN 001, p_titulo2
         PRINT
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_imp_linha

      ON LAST ROW
        PRINT
        PRINT COLUMN 001, 'Favor verificar os erros no POL1273.'
        PRINT

        PRINT
        PRINT COLUMN 005, 'Atenciosamente,'
        PRINT
        PRINT COLUMN 005, p_nom_remetente
        
END REPORT
   

 
   