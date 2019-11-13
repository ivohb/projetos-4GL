
#-------------------------------------------------------------------#
# PROGRAMA: pol0803                                                 #
# OBJETIVO: APONTAMENTO DE PRODUÇÃO                                 #
# CLIENTE.: PROLIND                                                 #
# DATA....: DESENVOLVIMENTO: 12/05/2008 CONVERSÃO 10.02 28/06/2011  #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       	 p_den_empresa        LIKE empresa.den_empresa,
       	 p_user               LIKE usuario.nom_usuario,
         p_cod_status         CHAR(10),
         p_index              SMALLINT,
         s_index              SMALLINT,
         p_ind                SMALLINT,
         s_ind                SMALLINT,
         p_msg                CHAR(300),
       	 p_nom_arquivo        CHAR(100),
       	 p_count              SMALLINT,
         p_rowid              SMALLINT,
       	 p_houve_erro         SMALLINT,
         p_ies_impressao      CHAR(01),
         g_ies_ambiente       CHAR(01),
       	 p_retorno            SMALLINT,
         p_nom_tela           CHAR(200),
       	 p_status             SMALLINT,
       	 p_caminho            CHAR(100),
       	 comando              CHAR(80),
         p_versao             CHAR(18),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_ies_cons           SMALLINT,
         p_qtd_lote           DECIMAL(10,3),
         p_incompativel       SMALLINT

END GLOBALS

   DEFINE p_cod_nivel         SMALLINT,
          p_date_time         DATETIME YEAR TO SECOND,
          p_data_hora         DATETIME YEAR TO SECOND,
          p_dat_processo      CHAR(20),
          p_nom_usuario       CHAR(08),
          p_nom_funcionario   CHAR(40),
          p_ies_estornado     CHAR(01),
          p_num_seq_apo       INTEGER,
          p_num_seq_apont     INTEGER,
          p_cod_tip_movto     CHAR(01),
          p_sem_estoque       SMALLINT,
          p_sequencia         INTEGER,
          p_criticou          SMALLINT,
          p_dat_char          CHAR(23),
          p_dat_aux           CHAR(10),
          p_gerar             CHAR(02),
          p_fantasma          CHAR(01),
          p_explodiu          CHAR(01),
          p_ies_par_cst       CHAR(01),
          p_grava_oplote      CHAR(01),
          p_rastreia          CHAR(01),
          p_saldo_txt         CHAR(23),
          p_saldo_tx2         CHAR(11),
          p_cod_oper          CHAR(01),
          p_ies_forca_apont   CHAR(01),
          p_num_op            INTEGER,
          p_seq_reg_mestre    INTEGER,
          p_num_transac_pai   INTEGER,
          p_tip_producao      CHAR(01),
          p_tip_movto         CHAR(01),
          p_transf_mat        CHAR(01),
          p_dat_movto         DATE,
          p_opcao             CHAR(01),
          p_qtd_erro          INTEGER,
          p_dat_atu           DATE,
          p_hor_atu           CHAR(08),
          p_qtd_estorno       DECIMAL(10,3),
          p_qtd_ordem         DECIMAL(10,3),
          p_ies_operacao      CHAR(01),
          p_trans_ender       INTEGER,
          p_trans_lote       INTEGER,
          p_obs              CHAR(100),
          p_ies_apontamento  CHAR(01)
          
          
   DEFINE p_cod_local_insp    LIKE item.cod_local_insp,
          p_num_neces         LIKE necessidades.num_neces,
          p_ies_ctr_estoque   LIKE item.ies_ctr_estoque,
          p_ies_ctr_lote      LIKE item.ies_ctr_lote,
          p_ies_tem_inspecao  LIKE item.ies_tem_inspecao,
          p_num_ordem         LIKE ordens.num_ordem,
          p_cod_item          LIKE ordens.cod_item,
          p_cod_item_pai      LIKE ordens.cod_item_pai,
          p_cod_local_estoq   LIKE item.cod_local_estoq,
          p_ies_tip_item      LIKE item.ies_tip_item,
          p_ctr_estoque       LIKE item.ies_ctr_estoque,
          p_ctr_lote          LIKE item.ies_ctr_lote,
          p_sofre_baixa       LIKE item_man.ies_sofre_baixa,
          p_ies_baixa_comp    LIKE item_man.ies_baixa_comp,
          p_cod_compon        LIKE ordens.cod_item,
          p_cod_item_sucata   LIKE ordens.cod_item,
          p_qtd_reservada     LIKE estoque_loc_reser.qtd_reservada,
          p_qtd_saldo         LIKE estoque_lote.qtd_saldo,
          p_tot_saldo         LIKE estoque_lote.qtd_saldo,
          p_qtd_transf        LIKE estoque_lote.qtd_saldo,
          p_qtd_boas          LIKE ordens.qtd_planej,
          p_tot_apont         LIKE ordens.qtd_planej,
          p_qtd_refug         LIKE ordens.qtd_planej,
          p_qtd_apont         LIKE ordens.qtd_planej,
          p_saldo_op          LIKE ordens.qtd_planej,
          p_dat_inicio        LIKE ord_oper.dat_inicio,
          p_cod_roteiro       LIKE ordens.cod_roteiro,
          p_num_altern_roteiro LIKE ordens.num_altern_roteiro,
          p_cod_operacao      LIKE estoque_trans.cod_operacao,
          p_parametros        LIKE par_pcp.parametros,
          p_num_seq_reg       LIKE cfp_apms.num_seq_registro,
          p_empresa           LIKE mcg_filial.empresa,
          p_filial            LIKE mcg_filial.filial,
          p_area_livre        LIKE par_cst.area_livre,
          p_dat_fecha_ult_man LIKE par_estoque.dat_fecha_ult_man,
          p_dat_fecha_ult_sup LIKE par_estoque.dat_fecha_ult_sup,
          p_ies_custo_medio   LIKE par_estoque.ies_custo_medio,
          p_ies_mao_obra      LIKE par_con.ies_mao_obra,
          p_qtd_necessaria    LIKE ord_compon.qtd_necessaria,
          p_num_lote          LIKE estoque_lote.num_lote,
          p_ies_situa         LIKE ordens.ies_situa,
          p_ies_situa_orig    LIKE estoque_trans.ies_sit_est_orig,
          p_ies_situa_dest    LIKE estoque_trans.ies_sit_est_dest,
          p_cod_local_orig    LIKE estoque_trans.cod_local_est_orig,
          p_cod_local_dest    LIKE estoque_trans.cod_local_est_dest,
          p_cod_local_prod    LIKE estoque_trans.cod_local_est_dest,
          p_num_conta         LIKE estoque_trans.num_conta,
          p_num_lote_orig     LIKE estoque_lote.num_lote,
          p_num_lote_dest     LIKE estoque_lote.num_lote,
          p_num_transac_orig  LIKE estoque_trans.num_transac,
          p_num_transac       LIKE estoque_lote_ender.num_transac,
          p_qtd_movto         LIKE estoque_trans.qtd_movto,
          p_qtd_atu           LIKE estoque_trans.qtd_movto,
          p_qtd_prod          LIKE estoque_trans.qtd_movto,
          p_qtd_baixar        LIKE estoque_trans.qtd_movto,
          p_ies_largura       LIKE item_ctr_grade.ies_largura,
          p_ies_altura        LIKE item_ctr_grade.ies_altura,
          p_ies_diametro      LIKE item_ctr_grade.ies_diametro,
          p_ies_comprimento   LIKE item_ctr_grade.ies_comprimento,
          p_ies_serie         LIKE item_ctr_grade.reservado_2,
          p_ies_dat_producao  LIKE item_ctr_grade.ies_dat_producao,
          p_largura           LIKE estoque_lote_ender.largura,
          p_altura            LIKE estoque_lote_ender.altura,
          p_diametro          LIKE estoque_lote_ender.diametro,
          p_comprimento       LIKE estoque_lote_ender.comprimento,
          p_cod_unid_prod     LIKE cent_trabalho.cod_unid_prod,
          p_nom_profis        LIKE tx_profissional.nom_profis,
          p_pct_refug         LIKE ord_compon.pct_refug,
          p_qtd_sucata        LIKE estoque_trans.qtd_movto

   DEFINE p_estoque_lote       RECORD LIKE estoque_lote.*,
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
          p_man_apo_mestre     RECORD LIKE man_apo_mestre.*,
          p_man_apo_detalhe    RECORD LIKE man_apo_detalhe.*,
          p_man_tempo_producao RECORD LIKE man_tempo_producao.*,
          p_man_comp_consumido RECORD LIKE man_comp_consumido.*,
          p_man_item_produzido RECORD LIKE man_item_produzido.*
   

   DEFINE p_tela              RECORD
          num_ordem           LIKE ordens.num_ordem,
          ies_situa           LIKE ordens.ies_situa,
          cod_item            LIKE item.cod_item,
          den_item            LIKE item.den_item,
          num_pedido          LIKE ordens.num_docum,
          qtd_planej          LIKE ordens.qtd_planej,
          qtd_saldo           LIKE ordens.qtd_planej,
          qtd_boas            LIKE ordens.qtd_boas,
          qtd_refug           LIKE ordens.qtd_refug,
          cod_profis          LIKE tx_profissional.cod_profis
   END RECORD

   DEFINE pr_erros            ARRAY[100] OF RECORD
          num_ordem           INTEGER,
          qtd_boas            DECIMAL(10,3),
          den_critica         CHAR(50)
   END RECORD
   
   DEFINE pr_erro_est         ARRAY[100] OF RECORD
          den_erro            CHAR(80)
   END RECORD
          
DEFINE p_num_processo         INTEGER

DEFINE p_man                RECORD 
    cod_empresa char(2),
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    num_lote char(15),
    dat_inicial datetime year to day,
    dat_final datetime year to day,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_movto char(1),
    cod_local char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial datetime hour to second,
    hor_final datetime hour to second,
    unid_funcional char(10),
    dat_atualiz datetime year to second,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_seq_apont integer,
    num_processo integer
END RECORD

   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 7
   DEFER INTERRUPT 
   LET p_versao = "pol0803-10.02.32  "
   CALL func002_versao_prg(p_versao)
   
   OPTIONS
     NEXT KEY control-f,
     PREVIOUS KEY control-b,
     DELETE KEY control-e

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
   
   #LET p_cod_empresa = '21'; LET p_status = 0; LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol0803_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0803_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0803") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0803 AT 2,1 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0803_cria_tab_ordem() THEN
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ o processamento"
         CALL pol0803_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados com sucesso !!!"
            LET p_ies_cons = TRUE
            NEXT OPTION "Processar"
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE
            NEXT OPTION "Fim"
         END IF
      COMMAND "Processar" "Processa o apontamento da produção"
         IF p_ies_cons THEN
            ERROR 'Aguarde!... Procssando.'
            IF log004_confirm(18,35) THEN
               CALL pol0803_processar() RETURNING p_status
               IF p_status THEN
                  ERROR ''
                  LET p_msg = 'PROCESSAMENTO EFETUADO COM SUCESSO'
                  CALL log0030_mensagem(p_msg,'excla')
               ELSE
                  ERROR 'Operação cancelada!'
               END IF
               LET p_ies_cons = FALSE
               MESSAGE ''
               NEXT OPTION "Fim"
            ELSE
               ERROR 'Operação cancelada!'
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!!!'
         END IF
      COMMAND "Estornar" "Estorna apontamentos de um processo selecionado"
         IF pol0803_estornar() THEN
            LET p_msg = 'ESTORNO EFETUADO COM SUCESSO'
            CALL log0030_mensagem(p_msg,'excla')
         ELSE
            ERROR "Operação Cancelada !!!"
         END IF
         IF p_criticou THEN
            CALL pol0803_ins_erro_estorno() RETURNING p_status
            IF p_status THEN
               LET p_opcao = 'E'
               ERROR "Houve críticas no estorno."
               CALL pol0803_exib_erro_estorno() RETURNING p_status
            END IF
         END IF
      COMMAND "Consultar" "Consulta itens/ordens p/ beneficiamento"
         CALL pol0803_itens_bene() RETURNING p_status
         IF p_status THEN
            ERROR "Consulta efetuada com sucesso !!!"
         ELSE
            ERROR "Operação Cancelada !!!"
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol0803

END FUNCTION


#--------------------------#
FUNCTION pol0803_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   LET p_tela.qtd_boas  = 0
   LET p_tela.qtd_refug = 0
   LET p_data_hora = CURRENT
   LET p_dat_processo = p_data_hora
   CALL pol0803_limpa_tela()
   DISPLAY p_dat_processo TO dat_processo
   DISPLAY p_user TO nom_usuario
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_ordem
         IF p_tela.num_ordem IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_ordem
         END IF

         IF NOT pol0803_le_ordens() THEN
            NEXT FIELD num_ordem
         END IF
                  
         DISPLAY BY NAME p_tela.*
         
         IF p_tela.ies_situa MATCHES '[4]' THEN
         ELSE
            ERROR 'Informe um OP com status 4 !!!'
            NEXT FIELD num_ordem
         END IF
         
         IF NOT pol0803_le_man() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF p_tela.qtd_saldo <= 0 THEN
               ERROR 'Ordem sem saldo a apontar !!!'
               NEXT FIELD num_ordem
            END IF
         END IF

      AFTER FIELD qtd_boas
         IF p_tela.qtd_boas IS NULL THEN
            LET p_tela.qtd_boas = 0
         END IF
         
         DISPLAY p_tela.qtd_boas TO qtd_boas
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF p_tela.qtd_boas > p_tela.qtd_saldo THEN
               ERROR 'Apontamento de boas > saldo da ordem!!!'
               NEXT FIELD qtd_boas
            END IF
         END IF

      AFTER FIELD qtd_refug
         IF p_tela.qtd_refug IS NULL THEN
            LET p_tela.qtd_refug = 0
         END IF
         
         DISPLAY p_tela.qtd_refug TO qtd_refug
         
         IF p_ies_forca_apont = 'S' THEN
         ELSE
            IF (p_tela.qtd_boas + p_tela.qtd_refug) > p_tela.qtd_saldo THEN
               ERROR 'Soma das boas e refugos > saldo da ordem!!!'
               NEXT FIELD qtd_boas
            END IF
         END IF
      
      AFTER FIELD cod_profis
         
         IF p_tela.cod_profis IS NOT NULL THEN
            SELECT nom_profis
              INTO p_nom_profis
              FROM tx_profissional
             WHERE cod_empresa = p_cod_empresa
               AND cod_profis  = p_tela.cod_profis
               AND cod_tip_profis = 'F'
            
            IF STATUS <> 0 THEN
               ERROR 'Código não cadastrado ou não é um funcionário (Tipo F) !!!'
               NEXT FIELD cod_profis
            END IF
            DISPLAY p_nom_profis TO nom_profis
         END IF

      ON KEY (control-z)
         CALL pol0803_popup()
      
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF (p_tela.qtd_boas + p_tela.qtd_refug) <= 0 THEN
               ERROR 'Informe as qtds. a apontar!!!'
               NEXT FIELD qtd_boas
            END IF
            IF p_tela.cod_profis IS NULL THEN
               ERROR 'Preencha o campo Cód operador !!!'
               NEXT FIELD cod_profis
            END IF
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      CALL pol0803_limpa_tela()
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0803_popup()
#-----------------------#

   DEFINE p_codigo CHAR(20)

   CASE
 
     WHEN INFIELD(cod_profis)
			CALL log009_popup(8,10,"OPERADORES","tx_profissional",
			     "cod_profis","nom_profis","","S"," cod_tip_profis = 'F' ") 
			RETURNING p_codigo

			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol0803

			IF p_codigo IS NOT NULL THEN
				LET p_tela.cod_profis = p_codigo CLIPPED
				DISPLAY p_codigo TO cod_profis
			END IF 

     WHEN INFIELD(nom_usuario)
			CALL log009_popup(8,10,"USUÁRIOS","usuarios",
			     "cod_usuario","nom_funcionario","","N"," 1=1 ORDER BY cod_usuario ") 
			RETURNING p_codigo

			CALL log006_exibe_teclas("01 02 07", p_versao)
			CURRENT WINDOW IS w_pol08033

			IF p_codigo IS NOT NULL THEN
				LET p_nom_usuario = p_codigo CLIPPED
				DISPLAY p_codigo TO nom_usuario
			END IF 

      WHEN INFIELD(dat_processo)
         CALL pol0803_le_processo() 
            RETURNING p_dat_processo, p_nom_usuario, p_num_op, p_qtd_boas
    
         CURRENT WINDOW IS w_pol08033
    
         DISPLAY p_num_op TO num_op
         DISPLAY p_nom_usuario to nom_usuario
         DISPLAY p_dat_processo TO dat_processo

   END CASE

END FUNCTION

#-----------------------------#
 FUNCTION pol0803_le_processo()
#-----------------------------#
   
   DEFINE p_query      CHAR(800)
   
   DEFINE pr_processo  ARRAY[2000] OF RECORD
          dat_processo CHAR(20),
          num_ordem    INTEGER,
          qtd_boas     DECIMAL(10,3),
          usuario      CHAR(08)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol08034") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol08034 AT 06,20 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DISPLAY p_nom_usuario TO nom_usuario
   
   LET INT_FLAG = FALSE
   LET p_ind = 1

   LET p_query =
    "SELECT dat_processo, num_ordem, qtd_boas, usuario ",
    "  FROM processo_apont_1054 ",
    " WHERE cod_empresa = '",p_cod_empresa,"' ",
    "   AND ies_estornado = 'N' "
   
   IF p_num_op IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND num_ordem = ", p_num_op
   END IF

   IF p_nom_usuario IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND usuario = '",p_nom_usuario,"' "
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY num_ordem, dat_processo DESC "
   
   PREPARE var_query FROM p_query 
    
   DECLARE cq_processo CURSOR FOR var_query

   FOREACH cq_processo
      INTO pr_processo[p_ind].dat_processo,  
           pr_processo[p_ind].num_ordem,
           pr_processo[p_ind].qtd_boas,
           pr_processo[p_ind].usuario

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor: cq_processo')
         EXIT FOREACH
      END IF
            
      LET p_ind = p_ind + 1
      
      IF p_ind > 2000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_processo TO sr_processo.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol08034
   
   IF NOT INT_FLAG THEN
      RETURN pr_processo[p_ind].dat_processo, 
             pr_processo[p_ind].usuario, 
             pr_processo[p_ind].num_ordem,
             pr_processo[p_ind].qtd_boas
   ELSE
      RETURN "", "", "", ""
   END IF
   
END FUNCTION

#------------------------#
FUNCTION pol0803_le_man()
#------------------------#

   SELECT ies_forca_apont
     INTO p_ies_forca_apont
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Item_man')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION      

#----------------------------#
FUNCTION pol0803_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
END FUNCTION

#--------------------------#
FUNCTION pol0803_le_ordens()
#--------------------------#

   SELECT num_docum,
          qtd_planej,
          (qtd_planej - 
           qtd_boas   - 
           qtd_refug  - 
           qtd_sucata),
          ies_situa,
          cod_item
     INTO p_tela.num_pedido,
          p_tela.qtd_planej,
          p_tela.qtd_saldo,
          p_tela.ies_situa,
          p_tela.cod_item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_tela.num_ordem

   IF STATUS = 100 THEN
      LET p_msg = 'Ordem de produção inixistente!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE 
      IF STATUS <> 0 THEN 
         CALL log003_err_sql('Lendo','ordens')
         RETURN FALSE
      END IF    
   END IF      

   SELECT den_item
     INTO p_tela.den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_tela.cod_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF      

   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol0803_processar()
#---------------------------#   

   DELETE FROM  ord_apont_1054
     
   IF NOT pol0803_deleta_erro() THEN
      RETURN FALSE
   END IF

   SELECT parametro_texto
     INTO p_transf_mat
     FROM min_par_modulo
    WHERE empresa = p_cod_empresa
      AND parametro = 'TRANSFERE MATERIAL?'
   
   IF STATUS = 100 THEN
      LET p_transf_mat = 'S'
   ELSE 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MIN_PAR_MODULO')
         RETURN FALSE
      END IF
   END IF
   
   LET p_num_ordem  = p_tela.num_ordem
   LET p_cod_compon = p_tela.cod_item
   LET p_explodiu   = 'N'
   LET p_num_seq_apo  = 0
   LET p_qtd_boas  = p_tela.qtd_boas 
   LET p_qtd_refug = p_tela.qtd_refug
   
   IF NOT pol0803_insere_ordem() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0803_explode_estrutura() THEN
      RETURN FALSE
   END IF

   IF NOT pol0803_le_parametros() THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol0803_processa_apo() THEN
      CALL pol0803_carrega_erros()
      CALL log085_transacao("ROLLBACK")
      IF p_index > 1 THEN
         CALL pol0803_exibe_erros()
      END IF
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0803_carrega_erros()
#-------------------------------#

   INITIALIZE pr_erros TO NULL
   
   LET p_index = 1
   
   DECLARE cq_erros CURSOR FOR
    SELECT num_ordem,
           qtd_boas,
           den_critica
      FROM apont_erro_1054
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = p_man.num_processo

   FOREACH cq_erros INTO pr_erros[p_index].*
      LET p_index = p_index + 1
      IF p_index > 100 THEN
         ERROR 'Limite de linhas da grade ultrapassado !!!'
         EXIT FOREACH
      END IF
   END FOREACH
      
END FUNCTION

#-----------------------------#
FUNCTION pol0803_exibe_erros()
#-----------------------------#

   MESSAGE ''
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol08031") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol08031 AT 6,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_index - 1)

   MESSAGE 'Esc=Sair'

   DISPLAY ARRAY pr_erros TO  sr_erros.*
   
   CLOSE WINDOW w_pol08031
   
END FUNCTION

#--------------------------------#
FUNCTION pol0803_cria_tab_ordem()
#--------------------------------#

   DROP TABLE ord_apont_1054

   CREATE TEMP TABLE ord_apont_1054(
         num_ordem      INTEGER,
         cod_item       CHAR(15),
         qtd_boas       DECIMAL(10,3),
         qtd_refug      DECIMAL(10,3),
         explodiu       CHAR(01),
         num_seq_apo    SMALLINT
    );
         
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","ord_apont_1054")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0803_insere_ordem()
#-----------------------------#

   LET p_num_seq_apo = p_num_seq_apo + 1

   INSERT INTO ord_apont_1054
      VALUES(p_num_ordem, 
             p_cod_compon, 
             p_qtd_boas,
             p_qtd_refug,
             p_explodiu,
             p_num_seq_apo)

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Iserindo","ord_apont_1054")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0803_explode_estrutura()
#-----------------------------------#

   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM ord_apont_1054
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','ord_apont_1054')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT num_ordem,
            cod_item,
            qtd_boas,
            qtd_refug
       FROM ord_apont_1054
      WHERE explodiu = 'N'
    
    FOREACH cq_exp INTO 
            p_num_ordem,
            p_cod_item_pai,
            p_qtd_boas,
            p_qtd_refug
            
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','ord_apont_1054')
          RETURN FALSE
       END IF
       
       LET p_qtd_boas = p_qtd_boas + p_qtd_refug
       LET p_qtd_refug = 0
       LET p_tot_apont = p_qtd_boas
       
       UPDATE ord_apont_1054
          SET explodiu = 'S'
        WHERE num_ordem = p_num_ordem

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','ord_apont_1054')
          RETURN FALSE
       END IF
       
        DECLARE cq_est CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria
          FROM ord_compon
         WHERE cod_empresa  = p_cod_empresa
           AND num_ordem    = p_num_ordem
           AND qtd_necessaria > 0       
             
       FOREACH cq_est INTO p_cod_compon, p_qtd_necessaria

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura')
             RETURN FALSE
          END IF
          
          LET p_qtd_boas = p_tot_apont

          IF NOT pol0803_le_tip_item() THEN
             RETURN FALSE
          END IF
          
          IF p_ies_tip_item MATCHES '[CB]' THEN
             LET p_explodiu = 'S'
          ELSE
             LET p_explodiu = 'N'
             LET p_qtd_apont  = p_qtd_boas * p_qtd_necessaria
                          
             IF NOT pol0803_pega_estoq() THEN
                RETURN FALSE
             END IF
             
             IF p_qtd_apont > p_qtd_saldo THEN
                LET p_qtd_apont = p_qtd_apont - p_qtd_saldo
             ELSE
                LET p_qtd_apont = 0
             END IF
             
             IF p_qtd_apont > 0 THEN
                IF NOT pol0803_pega_ordem('1') THEN
                   RETURN FALSE
                END IF

                IF p_qtd_apont > 0 THEN
                   IF NOT pol0803_pega_ordem('2') THEN
                      RETURN FALSE
                   END IF
                   IF p_qtd_apont > 0 THEN
                      LET p_msg = 'não há ordens nem saldo suficiente,\n',
                                  'para apontar o item ', p_cod_compon
                      CALL log0030_mensagem(p_msg,'excla')
                      RETURN FALSE
                   END IF
                END IF                
             END IF
                          
          END IF
         
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol0803_le_tip_item()
#-----------------------------#
          
   SELECT ies_tip_item, 
          cod_local_estoq
     INTO p_ies_tip_item,
          p_cod_local_orig
     FROM item 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_compon
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0803_pega_estoq()
#----------------------------#

   IF NOT pol0803_le_sdo_estoque() THEN
      RETURN FALSE
   END IF

   IF p_incompativel THEN
      LET p_msg = 'As tabelas de estoque estão desbalanceadas,\n',
                  'para o produto ', p_cod_compon
      CALL log003_err_sql(p_msg,'info')
      RETURN FALSE
   END IF
   
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0803_pega_ordem(p_num_seq)
#-------------------------------------#
   
   DEFINE p_num_seq CHAR(01)
   
   INITIALIZE p_num_ordem TO NULL

  IF p_num_seq = '1' THEN
   DECLARE cq_fpo CURSOR FOR 
    SELECT num_ordem,
          (qtd_planej - 
           qtd_boas   - 
           qtd_refug  - 
           qtd_sucata)
      FROM ordens
     WHERE cod_empresa  = p_cod_empresa
       AND num_docum    = p_tela.num_pedido
       AND cod_item     = p_cod_compon
       AND cod_item_pai = p_cod_item_pai
       AND ies_situa    IN ('4')
  ELSE
   DECLARE cq_fpo CURSOR FOR 
    SELECT num_ordem,
          (qtd_planej - 
           qtd_boas   - 
           qtd_refug  - 
           qtd_sucata)
      FROM ordens
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item     = p_cod_compon
       AND cod_item_pai = p_cod_item_pai
       AND ies_situa    IN ('4')
  
  END IF
  
   FOREACH cq_fpo INTO p_num_ordem, p_saldo_op

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens:fpo')
         RETURN FALSE
      END IF
      
      IF p_saldo_op = 0 THEN
         CONTINUE FOREACH
      END IF

      SELECT num_ordem
        FROM ord_apont_1054
       WHERE num_ordem = p_num_ordem
      
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','ord_apont_1054:fpo')
            RETURN FALSE
         END IF
      END IF
      
      IF p_saldo_op < p_qtd_apont THEN
         LET p_qtd_boas = p_saldo_op
      ELSE
         LET p_qtd_boas = p_qtd_apont
      END IF
      
      IF NOT pol0803_insere_ordem() THEN
         RETURN FALSE
      END IF

      LET p_qtd_apont = p_qtd_apont - p_qtd_boas
      
      IF p_qtd_apont <= 0 THEN
         EXIT FOREACH
      END IF

   END FOREACH
   
   FREE cq_fpo
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0803_le_parametros()
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
   LET p_rastreia     = p_parametros[50,50]
   
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

#------------------------------#
FUNCTION pol0803_processa_apo()
#------------------------------#
      
   INITIALIZE p_man TO NULL
   LET p_num_seq_apo = 0
   LET p_criticou = FALSE
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME

   SELECT MAX(num_processo)
     INTO p_num_processo
     FROM man_apont_1054
    WHERE cod_empresa = p_cod_empresa
   
   IF p_num_processo IS NULL THEN
      LET p_num_processo = 1
   ELSE
      LET p_num_processo = p_num_processo + 1
   END IF
   
   INSERT INTO processo_apont_1054
    VALUES(p_cod_empresa,
           p_user,
           p_dat_processo,
           p_num_processo,'N',
           p_tela.num_ordem,
           p_tela.qtd_boas,
           p_tela.qtd_refug)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('INSERT','processo_apont_1054')
      RETURN FALSE
   END IF                                           
   
   DECLARE cq_aponta CURSOR WITH HOLD FOR
    SELECT num_ordem,
           cod_item,
           qtd_boas,
           qtd_refug,
           num_seq_apo
      FROM ord_apont_1054
     ORDER by num_seq_apo DESC

   FOREACH cq_aponta INTO 
           p_man.num_ordem,
           p_man.cod_item,
           p_man.qtd_boas,
           p_man.qtd_refugo,
           p_man.num_seq_apont
           
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','cq_aponta')
         RETURN FALSE
      END IF                                           
           
      MESSAGE 'Apontando OP ', p_man.num_ordem 
      #lds CALL LOG_refresh_display()	

      IF NOT pol0803_coleta_dados() THEN
         RETURN FALSE
      END IF

   END FOREACH
   
   IF p_criticou THEN
      RETURN FALSE
   END IF

   IF NOT pol0803_proces_aponta() THEN
      RETURN FALSE
   END IF
   
   IF p_criticou THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0803_grava_man() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      

#-----------------------------#
FUNCTION pol0803_deleta_erro()
#-----------------------------#     

   DELETE FROM apont_erro_1054

   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Deletando','apont_erro_1054')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_coleta_dados()
#-------------------------------#

   DEFINE p_ies_recur      SMALLINT,
          p_tem_oper_final SMALLINT,
          p_item           CHAR(15),
          p_ctr_lote       CHAR(01),
          p_hor_ini        CHAR(08)

   LET p_man.cod_empresa = p_cod_empresa
   LET p_man.tip_movto = 'N'
   LET p_man.num_processo = p_num_processo
   
   SELECT cod_local_prod,
          num_lote,
          cod_item
     INTO p_man.cod_local,
          p_man.num_lote,
          p_item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordens:fcd')
      RETURN FALSE
   END IF

   SELECT ies_apontamento
     INTO p_ies_apontamento
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man:fcd')
      RETURN FALSE
   END IF
   
   IF p_man.num_lote IS NULL OR p_man.num_lote = ' ' THEN
      SELECT ies_ctr_lote
        INTO p_ctr_lote
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item:fcd')
         RETURN FALSE
      END IF
      
      IF p_ctr_lote = 'S' THEN
         LET p_msg = 'ORDEM ',p_man.num_ordem, ' SEM CONTEUDO NO CAMPO NUM_LOTE  '
         IF NOT pol0803_insere_erro() THEN
            RETURN FALSE
         END IF
         RETURN TRUE
      END IF
      
      LET p_man.num_lote = ' '
   END IF

   IF p_ies_apontamento = '2' THEN
      LET p_man.cod_operac = '     '
      LET p_man.num_seq_operac = NULL
      LET p_man.cod_cent_trab = '     '
      LET p_man.cod_arranjo = '     '
      LET p_man.cod_cent_cust = 0
      LET p_man.qtd_hor = 0
      LET p_man.oper_final = 'S'
      LET p_man.cod_recur = '     '
      LET p_man.dat_inicial = EXTEND(CURRENT, YEAR TO DAY)
      LET p_man.hor_inicial = EXTEND(CURRENT, HOUR TO SECOND)
      LET p_man.dat_final = p_man.dat_inicial
      LET p_man.hor_final = p_man.hor_inicial

      LET p_hor_ini = EXTEND(CURRENT, HOUR TO SECOND)
  
      CALL pol0803_calcula_turno(p_hor_ini[1,2])

      IF NOT pol0803_insere_man_1054() THEN
         RETURN FALSE
      END IF
      
      RETURN TRUE
   END IF

   SELECT COUNT(cod_operac)
     INTO p_count
     FROM ord_oper
    WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.num_ordem
      AND cod_item    = p_man.cod_item
      AND ies_apontamento = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper:fcd')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'ORDEM ',p_man.num_ordem, ' SEM OPERACOES NA TABELA ORD_OPER'
      IF NOT pol0803_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   LET p_tem_oper_final = 0
   
   DECLARE cq_operacoes CURSOR FOR
   SELECT cod_operac,
          num_seq_operac,
          cod_cent_trab,
          cod_arranjo,
          cod_cent_cust,
          qtd_horas,
          ies_oper_final
		 FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
      AND cod_item       = p_man.cod_item
      AND ies_apontamento = 'S'
    ORDER BY num_seq_operac

   FOREACH cq_operacoes INTO
           p_man.cod_operac,
           p_man.num_seq_operac,
           p_man.cod_cent_trab,
           p_man.cod_arranjo,
           p_man.cod_cent_cust,
           p_man.qtd_hor,
           p_man.oper_final

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_operacoes')
         RETURN FALSE
      END IF

      IF p_man.oper_final MATCHES '[SN]' THEN
         IF p_man.oper_final = 'S' THEN
            LET p_tem_oper_final = p_tem_oper_final + 1
         END IF
      ELSE
         LET p_msg = 'OPERAC:',p_man.cod_operac
         LET p_msg = p_msg CLIPPED, ' C/CONTEUDO INVALIDO NA ORD_OPER'
         IF NOT pol0803_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
            
      LET p_ies_recur = FALSE
      
      DECLARE cq_recurso CURSOR FOR
       SELECT a.cod_recur
         FROM rec_arranjo a,
              recurso b
        WHERE a.cod_empresa   = p_cod_empresa
          AND a.cod_arranjo   = p_man.cod_arranjo
          AND b.cod_empresa   = a.cod_empresa
          AND b.cod_recur     = a.cod_recur
          AND b.ies_tip_recur = '2'
       
      FOREACH cq_recurso INTO p_man.cod_recur

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_recurso')
            RETURN FALSE
         END IF
         
         LET p_ies_recur = TRUE
         
      END FOREACH

      IF NOT p_ies_recur THEN
         LET p_man.cod_recur = ' '
      END IF
      
      LET p_man.qtd_hor = p_man.qtd_hor * (p_man.qtd_boas + p_man.qtd_refugo)

      IF NOT pol0803_calc_data_hora() THEN
         RETURN FALSE
      END IF
      
      IF p_dat_fecha_ult_man IS NOT NULL THEN
         IF p_man.dat_inicial <= p_dat_fecha_ult_man THEN
            LET p_msg = 'A MANUFATURA JA ESTA FECHADA'
            IF NOT pol0803_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF

      IF p_dat_fecha_ult_sup IS NOT NULL THEN
         IF p_man.dat_inicial < p_dat_fecha_ult_sup THEN
            LET p_msg = 'O ESTOQUE JA ESTA FECHADO'
            IF NOT pol0803_insere_erro() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
      
      IF NOT pol0803_insere_man_1054() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   IF p_tem_oper_final = 0 THEN
      LET p_msg = 'ORDEM ', p_man.num_ordem, 'SEM OPERACAO FINAL'
      IF NOT pol0803_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_tem_oper_final > 1 THEN
         LET p_msg = 'ORDEM ', p_man.num_ordem, 'ORDEM COM MAIS DE UMA OPERACAO FINAL'
         IF NOT pol0803_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
      
   RETURN TRUE   

END FUNCTION

#-------------------------------#
FUNCTION pol0803_calc_data_hora()
#-------------------------------#

   DEFINE p_hi             CHAR(02),
          p_mi             CHAR(02),
          p_si             CHAR(02),
          p_hf             INTEGER,
          p_mf             INTEGER,
          p_sf             INTEGER,
          p_dat_ini        CHAR(10),
          p_hor_ini        CHAR(8),
          p_hor_fim        CHAR(8),
          p_segundo_ini    INTEGER,
          p_segundo_fim    INTEGER,
          p_tmp_producao   INTEGER,
          p_dat_fim        DATE,
          p_dat_hor        CHAR(19),
          p_num_seq_ant    SMALLINT
          
   LET p_tmp_producao = p_man.qtd_hor * 3600
   
   {IF p_man.num_seq_operac > 1 THEN
      LET p_num_seq_ant = p_man.num_seq_operac - 1
      INITIALIZE p_dat_ini, p_hor_ini TO NULL

      SELECT dat_final,
             hor_final
        INTO p_dat_fim,
             p_hor_ini
        FROM man_apont_1054
       WHERE cod_empresa    = p_cod_empresa
         AND num_ordem      = p_man.num_ordem
         AND cod_operac     = p_man.cod_operac
         AND num_seq_operac = p_num_seq_ant
         AND num_processo   = p_num_processo
      
      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET p_msg = 'Erro:',STATUS,' lendo man_apont:fcdh'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
      
      IF STATUS = 0 THEN
         LET p_dat_ini = p_dat_fim USING 'yyyy-mm-dd'
      ELSE
         INITIALIZE p_dat_ini TO NULL
      END IF
   END IF}
   
   #IF p_dat_ini IS NULL THEN
      LET p_dat_ini = EXTEND(CURRENT, YEAR TO DAY)
      LET p_hor_ini = EXTEND(CURRENT, HOUR TO SECOND)
      LET p_dat_fim = TODAY
   #END IF
   
   LET p_man.dat_inicial = p_dat_ini
   LET p_man.hor_inicial = p_hor_ini
   
   LET p_hi = p_hor_ini[1,2]
   
   CALL pol0803_calcula_turno(p_hi)
   
   LET p_mi = p_hor_ini[4,5]
   LET p_si = p_hor_ini[7,8]
   LET p_segundo_ini = (p_hi * 3600)+(p_mi * 60)+(p_si)
   LET p_segundo_fim = p_segundo_ini + p_tmp_producao

   LET p_hf = p_segundo_fim / 3600
   LET p_segundo_fim = p_segundo_fim - p_hf * 3600
   LET p_mf = p_segundo_fim / 60
   LET p_sf = p_segundo_fim - p_mf * 60


   WHILE p_hf > 23
      LET p_hf = p_hf - 24
      LET p_dat_fim = p_dat_fim + 1
   END WHILE   
      
   LET p_hi = p_hf USING '&&'
   LET p_mi = p_mf USING '&&'
   LET p_si = p_sf USING '&&'
   LET p_hor_fim = p_hi,':',p_mi,':',p_si

   LET p_man.dat_final = p_dat_fim
   LET p_man.hor_final = p_hor_fim

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_calcula_turno(p_hi)
#-----------------------------------#

   DEFINE p_hi SMALLINT
   
   IF p_hi >= 6 AND p_hi < 14 THEN
      LET p_man.cod_turno = '1'
   ELSE
      IF p_hi >= 14 AND p_hi < 22 THEN
         LET p_man.cod_turno = '2'
      ELSE
         LET p_man.cod_turno = '3'
      END IF
   END IF
   
END FUNCTION

#-----------------------------#
 FUNCTION pol0803_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO apont_erro_1054
      VALUES (p_cod_empresa,
              p_man.num_processo,
              p_man.num_ordem,
              p_man.cod_item,
              p_man.qtd_boas,
              p_man.qtd_refugo,
              p_msg)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','apont_erro_1054')
      RETURN FALSE
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0803_insere_man_1054()
#--------------------------------#
   
   DEFINE p_men CHAR(80)
   
   LET p_men = 'Gravando ordem ', p_man.num_ordem, 
               ' na tabela man_apont_1054 '
               
   LET p_man.nom_prog = 'POL0803'
   LET p_man.nom_usuario = p_user
   LET p_man.cod_status = 'I'
   LET p_man.dat_atualiz = CURRENT
   LET p_num_seq_apo = p_num_seq_apo + 1
   LET p_man.num_seq_apont = p_num_seq_apo
   LET p_man.qtd_sucata = 0
   LET p_man.integr_min = 'N'
   LET p_man.matricula = p_tela.cod_profis

   INSERT INTO man_apont_1054
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('Inserindo','man_apont_1054')
      CALL log0030_mensagem(p_men,'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0803_proces_aponta()
#------------------------------#

   INITIALIZE p_man TO NULL
   LET p_num_op = 0
   
   DECLARE cq_man CURSOR FOR
    SELECT *
      FROM man_apont_1054
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = p_num_processo
       AND cod_status   = 'I'
     ORDER BY num_seq_apont

   FOREACH cq_man INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man')
         RETURN FALSE
      END IF                                           

      LET p_criticou = FALSE
   
      IF NOT pol0803_le_roteiros() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_ins_mestre() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_ins_tempo() THEN
         RETURN FALSE
      END IF

      LET p_num_op = p_man.num_ordem

      IF p_man.num_seq_operac IS NOT NULL THEN
         IF NOT pol0803_atuali_ord_oper() THEN
            RETURN FALSE
         END IF
      END IF
      
      IF NOT pol0803_ins_detalhe() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_gra_tabs_velhas() THEN
         RETURN FALSE 
      END IF
      
      INSERT INTO sequencia_apo_1054
       VALUES(p_cod_empresa, p_num_processo, p_man.num_seq_apont,
              p_num_seq_reg, p_seq_reg_mestre)
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Insert','sequencia_apo_1054')
         RETURN FALSE
      END IF

      IF p_man.oper_final = 'S' THEN

         LET p_qtd_prod = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata
         LET p_cod_oper = 'C'
         
         IF NOT pol0803_material() THEN 
            RETURN FALSE
         END IF
         
         IF p_criticou THEN
            EXIT FOREACH
         END IF

         IF NOT pol0803_move_estoq() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0803_le_roteiros()
#----------------------------#

   SELECT cod_roteiro,                                 
          num_altern_roteiro,                             
          dat_ini                                         
     INTO p_cod_roteiro,                                  
          p_num_altern_roteiro,                           
          p_dat_inicio                                    
     FROM ordens                                          
    WHERE cod_empresa = p_cod_empresa                     
      AND num_ordem   = p_man.num_ordem                   
                                                         
   IF STATUS <> 0 THEN                                    
      CALL log003_err_sql('Lendo','ordens')               
      RETURN FALSE                                        
   END IF                                                 
                                                       
   IF p_dat_inicio IS NULL OR p_dat_inicio = ' ' THEN     
      LET p_dat_inicio = CURRENT YEAR TO SECOND           
   END IF                                                 

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0803_grava_man()
#---------------------------#

   UPDATE man_apont_1054
      SET cod_status = 'A'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = p_num_processo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizado','man_apont_1054')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0803_material()
#--------------------------#

   DECLARE cq_compon CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa,
           cod_item_pai,
           pct_refug
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.num_ordem

   FOREACH cq_compon INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_cod_local_orig,
           p_num_neces,
           p_pct_refug

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_compon')
         RETURN FALSE
      END IF  

      IF p_cod_oper = 'C' THEN
         IF p_qtd_necessaria <= 0 THEN
            CONTINUE FOREACH
         END IF

         SELECT num_neces
           FROM necessidades
          WHERE cod_empresa = p_cod_empresa
            AND num_neces   = p_num_neces

         IF STATUS <> 0 THEN
 		        LET p_msg = 'NECESSIDADE ',p_num_neces, ' NAO CADASTRADA.'
 	          IF NOT pol0803_insere_erro() THEN
	             RETURN FALSE
            END IF 
            RETURN TRUE              
         END IF     
      END IF
      
      IF NOT pol0803_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item MATCHES '[T]' OR 
         p_ctr_estoque = 'N'          OR
         p_sofre_baixa = 'N'        THEN
         CONTINUE FOREACH
      END IF

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_prod

      IF p_cod_oper = 'C' THEN 
         IF NOT pol0803_cheka_estoque() THEN
            RETURN FALSE
         END IF
         IF p_incompativel THEN 
 		        LET p_msg = 'ITEM: ',p_cod_compon CLIPPED,'. TABS DE ESTOQUE DESBALANCEADAS'
 	          IF NOT pol0803_insere_erro() THEN
	             RETURN FALSE
            END IF               
         ELSE
            IF p_sem_estoque THEN
               LET p_saldo_txt = p_qtd_saldo
               LET p_saldo_tx2 = p_qtd_baixar
               LET p_saldo_txt = p_saldo_txt CLIPPED, ' X ',p_saldo_tx2
 		           LET p_msg = 'ITEM: ',p_cod_compon CLIPPED,' S ESTOQ P/ BAIXAR:',p_saldo_txt
 	             IF NOT pol0803_insere_erro() THEN
	                RETURN FALSE
               END IF               
            END IF
         END IF
      ELSE
         
         IF p_qtd_baixar > 0 THEN
            IF NOT pol0803_baixa_compon() THEN
               RETURN FALSE
            END IF
         END IF

         IF p_qtd_baixar < 0 THEN
            
            LET p_qtd_sucata = p_qtd_baixar * (-1)
            
            IF NOT pol0803_aponta_sucata() THEN
               RETURN FALSE
            END IF
         
            IF NOT pol0803_baixa_neces() THEN
               RETURN FALSE
            END IF

         END IF
         
      END IF         
   
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0803_le_it_sucata()#
#------------------------------#

   SELECT cod_item_sucata
     INTO p_cod_item_sucata
     FROM de_para_item_1054
    WHERE cod_empresa = p_cod_empresa
      AND cod_item_compon = p_cod_compon
            
   IF STATUS = 100 THEN
      LET p_msg = 'Componente com pct refugo, porém\n',
                  'não cadastrado no de-para(POL1261).'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol0803_le_item_man()
#-----------------------------#

   SELECT a.cod_local_estoq,
          a.ies_ctr_estoque,
          a.ies_ctr_lote,
          a.ies_tip_item,
          b.ies_sofre_baixa,
          b.ies_baixa_comp
     INTO p_cod_local_estoq,
          p_ctr_estoque,
          p_ctr_lote,
          p_ies_tip_item,
          p_sofre_baixa,
          p_ies_baixa_comp
     FROM item a,
          item_man b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_compon
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ITEM/ITEM_MAN')  
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_cheka_estoque()
#-------------------------------#

   LET p_sem_estoque = FALSE

   IF NOT pol0803_le_sdo_estoque() THEN
      RETURN FALSE
   END IF
   
   IF p_incompativel THEN 
      RETURN TRUE
   END IF
   
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo >= p_qtd_baixar THEN
      RETURN TRUE
   ELSE
      IF p_transf_mat = 'N' THEN
         LET p_sem_estoque = TRUE
         RETURN TRUE
      END IF
   END IF
   
   IF p_cod_local_orig = p_cod_local_estoq THEN
      LET p_sem_estoque = TRUE
      RETURN TRUE
   END IF

   LET p_tot_saldo = p_qtd_saldo
   LET p_qtd_transf = p_qtd_baixar - p_qtd_saldo
   LET p_cod_local_prod = p_cod_local_orig
   LET p_cod_local_orig = p_cod_local_estoq

   IF NOT pol0803_le_sdo_estoque() THEN
      RETURN FALSE
   END IF

   IF p_incompativel THEN 
      RETURN TRUE
   END IF

   IF p_qtd_saldo < p_qtd_transf THEN
      LET p_sem_estoque = TRUE
      RETURN TRUE
   END IF
   
   LET p_cod_oper = 'T'
   
   IF NOT pol0803_transf_local() THEN
      RETURN FALSE
   END IF

   LET p_cod_oper = 'C'
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0803_le_sdo_estoque()
#-------------------------------#
   
   LET p_incompativel = FALSE
   
	 SELECT SUM(qtd_saldo)
		 INTO p_qtd_saldo
		 FROM estoque_lote_ender
		WHERE cod_empresa   = p_cod_empresa
		  AND cod_item      = p_cod_compon
		  AND cod_local     = p_cod_local_orig
      AND ies_situa_qtd IN ('L','E')
      AND qtd_saldo     > 0

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender:fce')
      RETURN FALSE
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
	 SELECT SUM(qtd_saldo)
		 INTO p_qtd_lote
		 FROM estoque_lote
		WHERE cod_empresa   = p_cod_empresa
		  AND cod_item      = p_cod_compon
		  AND cod_local     = p_cod_local_orig
      AND ies_situa_qtd IN ('L','E')
      AND qtd_saldo     > 0

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_lote')
      RETURN FALSE
   END IF  

   IF p_qtd_lote IS NULL OR p_qtd_lote < 0 THEN
      LET p_qtd_lote = 0
   END IF
   
   IF p_qtd_lote <> p_qtd_saldo THEN
      LET p_incompativel = TRUE
      RETURN TRUE
   END IF
   
   SELECT SUM(qtd_reservada)
     INTO p_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_compon
      AND cod_local   = p_cod_local_orig
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser:fce')
      RETURN FALSE
   END IF  

   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0803_transf_local()
#------------------------------#
   
   DEFINE p_qtd_reser DECIMAL(10,3)
   
   DECLARE cq_ftl CURSOR FOR
		SELECT *
      FROM estoque_lote_ender
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = p_cod_compon
       AND cod_local   = p_cod_local_estoq
       AND qtd_saldo   > 0
       AND ies_situa_qtd IN ('L','E')
     ORDER BY dat_hor_producao
     
   FOREACH cq_ftl INTO p_estoque_lote_ender.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender:fptl')
         RETURN FALSE
      END IF  

      IF p_estoque_lote_ender.num_lote IS NULL THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    IS NULL
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
      END IF
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:cq_bel')
         RETURN FALSE
      END IF  

      IF p_qtd_reser IS NULL OR p_qtd_reser < 0 THEN
         LET p_qtd_reser = 0
      END IF
      
      IF p_estoque_lote_ender.qtd_saldo > p_qtd_reser THEN
         LET p_estoque_lote_ender.qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reser
      ELSE
         CONTINUE FOREACH
      END IF

      IF p_estoque_lote_ender.qtd_saldo > p_qtd_transf THEN
         LET p_qtd_movto = p_qtd_transf
         LET p_qtd_transf = 0
      ELSE
         LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
         LET p_qtd_transf = p_qtd_transf - p_qtd_movto
      END IF

      IF NOT pol0803_baixa_lote() THEN
         RETURN FALSE
      END IF
      
      LET p_ies_situa_orig = p_estoque_lote_ender.ies_situa_qtd
      LET p_ies_situa_dest = p_ies_situa_orig
      LET p_num_lote_orig  = p_estoque_lote_ender.num_lote
      LET p_num_lote_dest  = p_num_lote_orig
      LET p_cod_local_orig = p_cod_local_estoq
      LET p_cod_local_dest = p_cod_local_prod
   
      IF NOT pol0803_grava_estoq_trans() THEN
         RETURN FALSE
      END IF
      
      LET p_estoque_lote_ender.cod_local = p_cod_local_prod
      
      IF NOT pol0803_grava_loc_prod() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_transf = 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_grava_loc_prod()
#-------------------------------#

   LET p_estoque_lote_ender.qtd_saldo   = p_qtd_movto
   LET p_estoque_lote_ender.num_transac = 0
   LET p_estoque_lote.cod_empresa   = p_estoque_lote_ender.cod_empresa
   LET p_estoque_lote.cod_item      = p_estoque_lote_ender.cod_item
   LET p_estoque_lote.cod_local     = p_estoque_lote_ender.cod_local
   LET p_estoque_lote.num_lote      = p_estoque_lote_ender.num_lote
   LET p_estoque_lote.ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   LET p_estoque_lote.qtd_saldo     = p_estoque_lote_ender.qtd_saldo
   LET p_estoque_lote.num_transac   = p_estoque_lote_ender.num_transac

   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_estoque_lote_ender.cod_empresa
         AND cod_item         = p_estoque_lote_ender.cod_item
         AND cod_local        = p_estoque_lote_ender.cod_local
         AND num_lote         = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd    = p_estoque_lote_ender.ies_situa_qtd
         AND dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
         AND largura          = p_estoque_lote_ender.largura
         AND altura           = p_estoque_lote_ender.altura
         AND diametro         = p_estoque_lote_ender.diametro
         AND comprimento      = p_estoque_lote_ender.comprimento
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_estoque_lote_ender.cod_empresa
         AND cod_item         = p_estoque_lote_ender.cod_item
         AND cod_local        = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd    = p_estoque_lote_ender.ies_situa_qtd
         AND dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
         AND largura          = p_estoque_lote_ender.largura
         AND altura           = p_estoque_lote_ender.altura
         AND diametro         = p_estoque_lote_ender.diametro
         AND comprimento      = p_estoque_lote_ender.comprimento
         AND num_lote           IS NULL
   END IF
   
   IF STATUS = 0 THEN
      IF NOT pol0803_atualiza_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0803_insere_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote_ender:fglp')
      END IF
   END IF
         
   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND num_lote      = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
         AND num_lote        IS NULL
   END IF
   
   IF STATUS = 0 THEN
      IF NOT pol0803_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0803_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote:fglp')
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0803_baixa_neces()
#-----------------------------#

   UPDATE necessidades
      SET qtd_saida = qtd_saida + p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_neces   = p_num_neces

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','necessidades')
      RETURN FALSE
   END IF     

   RETURN TRUE

END FUNCTION
          
#------------------------------#
FUNCTION pol0803_baixa_compon()
#------------------------------#
   
   DEFINE p_qtd_reser DECIMAL(10,3),
          p_qtd_mat   DECIMAL(10,3)
   
   LET p_cod_oper  = 'B'
   
   IF NOT pol0803_baixa_neces() THEN
      RETURN FALSE
   END IF

   DECLARE cq_bel CURSOR FOR
		SELECT *
      FROM estoque_lote_ender
	   WHERE cod_empresa = p_cod_empresa
	     AND cod_item    = p_cod_compon
       AND cod_local   = p_cod_local_orig
       AND qtd_saldo   > 0
       AND ies_situa_qtd IN ('L','E')
     ORDER BY dat_hor_producao
     
   FOREACH cq_bel INTO p_estoque_lote_ender.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_lote_ender:fbel')
         RETURN FALSE
      END IF  
      
      IF p_estoque_lote_ender.num_lote IS NULL THEN
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    IS NULL
      ELSE
         SELECT SUM(qtd_reservada)
           INTO p_qtd_reser 
           FROM estoque_loc_reser
          WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
            AND cod_item    = p_estoque_lote_ender.cod_item
            AND cod_local   = p_estoque_lote_ender.cod_local
            AND num_lote    = p_estoque_lote_ender.num_lote
      END IF
     
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:cq_bel')
         RETURN FALSE
      END IF  

      IF p_qtd_reser IS NULL OR p_qtd_reser < 0 THEN
         LET p_qtd_reser = 0
      END IF
      
      IF p_estoque_lote_ender.qtd_saldo > p_qtd_reser THEN
         LET p_estoque_lote_ender.qtd_saldo = p_estoque_lote_ender.qtd_saldo - p_qtd_reser
      ELSE
         CONTINUE FOREACH
      END IF

      IF p_estoque_lote_ender.qtd_saldo > p_qtd_baixar THEN
         LET p_qtd_movto = p_qtd_baixar
         LET p_qtd_baixar = 0
      ELSE
         LET p_qtd_movto = p_estoque_lote_ender.qtd_saldo
         LET p_qtd_baixar = p_qtd_baixar - p_qtd_movto
      END IF

      IF NOT pol0803_baixa_lote() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0803_baixa_estoque() THEN
         RETURN FALSE
      END IF

      LET p_ies_situa_orig = p_estoque_lote_ender.ies_situa_qtd
      LET p_ies_situa_dest = NULL 
      LET p_num_lote_orig  = p_estoque_lote_ender.num_lote
      LET p_num_lote_dest  = NULL
      LET p_cod_local_orig = p_estoque_lote_ender.cod_local
      LET p_cod_local_dest = NULL
   
      IF NOT pol0803_grava_estoq_trans() THEN
         RETURN FALSE
      END IF
      
      LET p_tip_movto = 'S'
      
      IF NOT pol0803_insere_man_consumo() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_insere_chf_componente() THEN
         RETURN FALSE
      END IF
      
      IF p_qtd_baixar <= 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH

   IF p_qtd_baixar > 0 THEN
      LET p_msg = 'Item ', p_cod_compon CLIPPED, ' - sem estoque para baixar\n',
                  'no local ', p_cod_local_orig
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0803_baixa_lote()
#----------------------------#

   IF p_estoque_lote_ender.qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque_lote_ender:fal')
      RETURN FALSE
   END IF  

   IF p_estoque_lote_ender.num_lote IS NOT NULL THEN
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND num_lote      = p_estoque_lote_ender.num_lote
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
   ELSE
      SELECT qtd_saldo,
             num_transac
        INTO p_qtd_saldo,
             p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND cod_item      = p_estoque_lote_ender.cod_item
         AND cod_local     = p_estoque_lote_ender.cod_local
         AND ies_situa_qtd = p_estoque_lote_ender.ies_situa_qtd
         AND num_lote        IS NULL
   END IF
   
   IF STATUS <> 0 OR p_qtd_saldo < p_estoque_lote_ender.qtd_saldo THEN
      LET p_msg = 'Divergência entre estoque_lote e estoque_lote_ender.'
      CALL log0030_mensagem(p_msg,'Excla')
      RETURN FALSE
   END IF  

   IF p_qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_num_transac
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_estoque_lote_ender.cod_empresa
         AND num_transac = p_num_transac
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque_lote:fal')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_baixa_estoque()
#-------------------------------#
   
   DEFINE p_qtd_lib_excep like estoque.qtd_lib_excep,
          p_qtd_liberada  like estoque.qtd_liberada
          
   SELECT qtd_liberada,
          qtd_lib_excep
     INTO p_qtd_liberada,
          p_qtd_lib_excep
     FROM estoque
    WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
      AND cod_item    = p_estoque_lote_ender.cod_item
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque:fbe')
      RETURN FALSE
   END IF  

   IF p_estoque_lote_ender.ies_situa_qtd = 'L' THEN
      
      if p_qtd_liberada < p_qtd_movto then
         let p_msg = "Componente ", p_estoque_lote_ender.cod_item
         let p_msg = p_msg CLIPPED, " sem estoque suficiente na tabela estoque!"
         call log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      end if
      
      UPDATE estoque
         SET qtd_liberada = qtd_liberada - p_qtd_movto,
             dat_ult_saida = TODAY
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   ELSE
      if p_qtd_lib_excep < p_qtd_movto then
         let p_msg = "Componente ", p_estoque_lote_ender.cod_item
         let p_msg = p_msg CLIPPED, " sem estoque suficiente na tabela estoque!"
         call log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      end if

      UPDATE estoque
         SET qtd_lib_excep = qtd_lib_excep - p_qtd_movto,
             dat_ult_saida = TODAY
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque:fbe')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_grava_estoq_trans()
#-----------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01)
   
   INITIALIZE p_estoque_trans.* TO NULL

   IF p_cod_operacao IS NULL THEN
      IF NOT pol0803_le_operacao() THEN
         RETURN FALSE
      END IF
   END IF
   
   SELECT ies_com_detalhe
     INTO p_ies_com_detalhe
     FROM estoque_operac
    WHERE cod_empresa  = p_cod_empresa
      AND cod_operacao = p_cod_operacao

   IF STATUS <> 0 THEN
      LET p_cod_status = STATUS
      LET p_msg = 'ERRO:',p_cod_status CLIPPED, ' LENDO OPER:',p_cod_operacao
      LET p_msg = p_msg CLIPPED, ' NA TAB ESTOQUE_OPERAC'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF p_ies_com_detalhe = 'S' THEN 
      IF p_cod_oper = 'B' THEN
         SELECT num_conta_debito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      ELSE
         SELECT num_conta_credito 
           INTO p_num_conta
           FROM estoque_operac_ct
          WHERE cod_empresa  = p_cod_empresa
            AND cod_operacao = p_cod_operacao
      END IF
      IF STATUS <> 0 THEN
         LET p_cod_status = STATUS
         LET p_msg = 'ERRO:',p_cod_status CLIPPED, ' LENDO OPER:',p_cod_operacao
         LET p_msg = p_msg CLIPPED, ' NA TAB ESTOQUE_OPERAC_CT'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   ELSE
      LET p_num_conta = NULL
   END IF

   IF p_man.tip_movto = 'N' THEN
      LET p_cod_tip_movto = 'N'
   ELSE
      LET p_cod_tip_movto = 'R'
   END IF

   LET p_estoque_trans.cod_empresa        = p_estoque_lote_ender.cod_empresa
   LET p_estoque_trans.cod_item           = p_estoque_lote_ender.cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = p_man.nom_prog
   LET p_estoque_trans.num_docum          = p_man.num_ordem
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa_orig
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET p_estoque_trans.cod_local_est_orig = p_cod_local_orig
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET p_estoque_trans.num_lote_orig      = p_num_lote_orig
   LET p_estoque_trans.num_lote_dest      = p_num_lote_dest

   IF NOT pol0803_ins_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0803_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0803_insere_estoq_audit() THEN
      RETURN FALSE
   END IF

   IF NOT pol0803_insere_trans_apont() THEN
      RETURN FALSE
   END IF

   LET p_cod_operacao = NULL

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0803_ins_estoq_trans()#
#---------------------------------#

   LET p_estoque_trans.num_transac   = 0
   LET p_estoque_trans.ies_tip_movto = p_cod_tip_movto
   LET p_estoque_trans.nom_usuario   = p_user
   LET p_estoque_trans.dat_proces    = p_dat_atu
   LET p_estoque_trans.hor_operac    = p_hor_atu

    INSERT INTO estoque_trans(
          cod_empresa,
          num_transac,
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
                  p_estoque_trans.num_transac,
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
     CALL log003_err_sql('Inserindo','estoque_trans:fget')
     RETURN FALSE
   END IF

   LET p_num_transac_orig = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0803_le_operacao()
#-----------------------------#

   IF p_cod_oper = 'B' THEN   
      SELECT cod_estoque_sp    
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_cod_empresa
   ELSE                
      IF p_cod_oper = 'T' THEN
         SELECT cod_estoque_ac
           INTO p_cod_operacao
           FROM par_pcp
          WHERE cod_empresa = p_cod_empresa       
      ELSE
         SELECT cod_estoque_rp    
           INTO p_cod_operacao
           FROM par_pcp
          WHERE cod_empresa = p_cod_empresa
      END IF
   END IF
   
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Lendo','par_pcp:flo')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0803_gra_est_trans_end()
#------------------------------------#

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
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f 
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.tex_reservado    = " "

   IF NOT pol0803_ins_est_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_ins_est_trans_end()#
#-----------------------------------#
  
   LET p_estoque_trans_end.num_transac      = p_num_transac_orig
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_trans_end:fiete')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_insere_estoq_audit()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, 
            p_num_transac_orig, 
            p_user, 
            p_dat_atu,
            p_man.nom_prog)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria:fiea')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_insere_trans_apont()
#-----------------------------------#
  
  DEFINE p_ies_oper CHAR(01)

  IF p_cod_oper = 'B' THEN
     LET p_ies_oper = 'S'
  ELSE
     LET p_ies_oper = 'E'
  END IF
     
  INSERT INTO trans_apont_1054 
     VALUES(p_cod_empresa, 
            p_num_processo,
            p_num_transac_orig, 
            p_man.num_seq_apont,
            p_ies_oper)
            
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','trans_apont_1054')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0803_atuali_ord_oper()
#---------------------------------#
   
   DEFINE p_qtd_sdo_op DECIMAL(10,3)
   
   UPDATE ord_oper
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refugo = qtd_refugo + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_inicio = p_dat_inicio
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ord_oper:qtds')
      RETURN FALSE
   END IF

   SELECT (qtd_planejada - qtd_boas - qtd_refugo - qtd_sucata)
     INTO p_qtd_sdo_op 
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ord_oper')
      RETURN FALSE
   END IF
   
   IF p_qtd_sdo_op IS NULL THEN
      LET p_qtd_sdo_op = 0
   END IF
   
   IF p_qtd_sdo_op <= 0 THEN
      UPDATE ord_oper
         SET ies_apontamento = 'F'
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND cod_operac     = p_man.cod_operac
    	   AND num_seq_operac = p_man.num_seq_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','ord_oper:ies_apontamento')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0803_ins_mestre()
#----------------------------#
   
   DEFINE p_cod_uni_funcio LIKE uni_funcional.cod_uni_funcio
   
   LET p_cod_uni_funcio = ''

   DECLARE cq_funcio CURSOR FOR 
		SELECT cod_uni_funcio 
		  FROM uni_funcional 
		 WHERE cod_empresa     = p_cod_empresa
			AND cod_centro_custo = p_man.cod_cent_cust
   
   FOREACH cq_funcio INTO p_cod_uni_funcio
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','uni_funcional')
      END IF
      
      EXIT FOREACH
   
   END FOREACH
   
   LET p_man_apo_mestre.empresa         = p_cod_empresa
   LET p_man_apo_mestre.seq_reg_mestre  = 0
   LET p_man_apo_mestre.sit_apontamento = 'A'
   LET p_man_apo_mestre.tip_moviment    = 'N'
   LET p_man_apo_mestre.data_producao   = p_man.dat_inicial
   LET p_man_apo_mestre.ordem_producao  = p_man.num_ordem
   LET p_man_apo_mestre.item_produzido  = p_man.cod_item
   LET p_man_apo_mestre.secao_requisn   = p_cod_uni_funcio
   LET p_man_apo_mestre.usu_apontamento = p_user
   LET p_man_apo_mestre.data_apontamento= TODAY  
   LET p_man_apo_mestre.hor_apontamento = TIME
   LET p_man_apo_mestre.usuario_estorno = ''
   LET p_man_apo_mestre.data_estorno    = ''
   LET p_man_apo_mestre.hor_estorno     = ''
   LET p_man_apo_mestre.apo_automatico  = 'N'
   LET p_man_apo_mestre.seq_reg_origem  = ''
   LET p_man_apo_mestre.observacao      = ''
   LET p_man_apo_mestre.seq_registro_integracao = ''

   INSERT INTO man_apo_mestre (
      empresa, 
      seq_reg_mestre,
      sit_apontamento, 
      tip_moviment, 
      data_producao, 
      ordem_producao, 
      item_produzido, 
      secao_requisn, 
      usu_apontamento, 
      data_apontamento, 
      hor_apontamento, 
      usuario_estorno, 
      data_estorno, 
      hor_estorno, 
      apo_automatico, 
      seq_reg_origem, 
      observacao, 
      seq_registro_integracao) 
   VALUES(p_man_apo_mestre.empresa,  
          p_man_apo_mestre.seq_reg_mestre,       
          p_man_apo_mestre.sit_apontamento, 
          p_man_apo_mestre.tip_moviment,    
          p_man_apo_mestre.data_producao,   
          p_man_apo_mestre.ordem_producao,  
          p_man_apo_mestre.item_produzido,  
          p_man_apo_mestre.secao_requisn,   
          p_man_apo_mestre.usu_apontamento, 
          p_man_apo_mestre.data_apontamento,
          p_man_apo_mestre.hor_apontamento, 
          p_man_apo_mestre.usuario_estorno, 
          p_man_apo_mestre.data_estorno,    
          p_man_apo_mestre.hor_estorno,     
          p_man_apo_mestre.apo_automatico,  
          p_man_apo_mestre.seq_reg_origem,  
          p_man_apo_mestre.observacao,      
          p_man_apo_mestre.seq_registro_integracao)
          
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_mestre')
      RETURN FALSE
   END IF

   LET p_seq_reg_mestre = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0803_ins_detalhe()
#----------------------------#
      
   SELECT cod_unid_prod 
     INTO p_cod_unid_prod
     FROM cent_trabalho
    WHERE cod_empresa   = p_cod_empresa
      AND cod_cent_trab = p_man.cod_cent_trab

   IF STATUS <> 0 THEN
      LET p_cod_unid_prod = '     '
   END IF

   LET p_man_apo_detalhe.empresa            = p_cod_empresa
   LET p_man_apo_detalhe.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_apo_detalhe.roteiro_fabr       = p_cod_roteiro
   LET p_man_apo_detalhe.altern_roteiro     = p_num_altern_roteiro
   LET p_man_apo_detalhe.sequencia_operacao = p_man.num_seq_operac
   LET p_man_apo_detalhe.operacao           = p_man.cod_operac
   LET p_man_apo_detalhe.unid_produtiva     = p_cod_unid_prod
   LET p_man_apo_detalhe.centro_trabalho    = p_man.cod_cent_trab
   LET p_man_apo_detalhe.arranjo_fisico     = p_man.cod_arranjo
   LET p_man_apo_detalhe.centro_custo       = p_man.cod_cent_cust
   LET p_man_apo_detalhe.atualiza_eqpto_min = 'N'
   LET p_man_apo_detalhe.eqpto              = p_man.cod_eqpto
   LET p_man_apo_detalhe.atlz_ferr_min      = 'N'
   LET p_man_apo_detalhe.ferramental        = pol0803_le_ferramenta()
   LET p_man_apo_detalhe.operador           = p_man.matricula
   LET p_man_apo_detalhe.observacao         = ''
   LET p_man_apo_detalhe.nome_programa      = p_man.nom_prog

  INSERT INTO man_apo_detalhe (
     empresa, 
     seq_reg_mestre, 
     roteiro_fabr, 
     altern_roteiro, 
     sequencia_operacao, 
     operacao, 
     unid_produtiva, 
     centro_trabalho, 
     arranjo_fisico, 
     centro_custo, 
     atualiza_eqpto_min, 
     eqpto, 
     atlz_ferr_min, 
     ferramental, 
     operador, 
     observacao,
     nome_programa)
  VALUES(p_man_apo_detalhe.empresa,           
         p_man_apo_detalhe.seq_reg_mestre,    
         p_man_apo_detalhe.roteiro_fabr,      
         p_man_apo_detalhe.altern_roteiro,    
         p_man_apo_detalhe.sequencia_operacao,
         p_man_apo_detalhe.operacao,          
         p_man_apo_detalhe.unid_produtiva,    
         p_man_apo_detalhe.centro_trabalho,   
         p_man_apo_detalhe.arranjo_fisico,    
         p_man_apo_detalhe.centro_custo,      
         p_man_apo_detalhe.atualiza_eqpto_min,
         p_man_apo_detalhe.eqpto,             
         p_man_apo_detalhe.atlz_ferr_min,     
         p_man_apo_detalhe.ferramental,       
         p_man_apo_detalhe.operador,    
         p_man_apo_detalhe.observacao,    
         p_man_apo_detalhe.nome_programa)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_detalhe')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0803_gra_tabs_velhas()
#---------------------------------#
  
  LET p_apo_oper.cod_empresa     = p_cod_empresa
  LET p_apo_oper.dat_producao    = p_man.dat_inicial
  LET p_apo_oper.cod_item        = p_man.cod_item
  LET p_apo_oper.num_ordem       = p_man.num_ordem
  
  IF p_man.num_seq_operac IS NULL THEN
     LET p_apo_oper.num_seq_operac  = 0
  ELSE
     LET p_apo_oper.num_seq_operac  = p_man.num_seq_operac
  END IF
  
  LET p_apo_oper.cod_operac      = p_man.cod_operac
  LET p_apo_oper.cod_cent_trab   = p_man.cod_cent_trab
  LET p_apo_oper.cod_arranjo     = p_man.cod_arranjo
  LET p_apo_oper.cod_cent_cust   = p_man.cod_cent_cust
  LET p_apo_oper.cod_turno       = p_man.cod_turno
  LET p_apo_oper.hor_inicio      = p_man.hor_inicial
  LET p_apo_oper.hor_fim         = p_man.hor_final
  LET p_apo_oper.qtd_boas        = p_man.qtd_boas
  LET p_apo_oper.qtd_refugo      = p_man.qtd_refugo
  LET p_apo_oper.qtd_sucata      = p_man.qtd_sucata
  LET p_apo_oper.num_conta       = ' '
  LET p_apo_oper.cod_local       = p_man.cod_local
  LET p_apo_oper.cod_tip_movto   = p_man.tip_movto
  LET p_apo_oper.qtd_horas       = p_man.qtd_hor
  LET p_apo_oper.dat_apontamento = CURRENT YEAR TO SECOND
  LET p_apo_oper.nom_usuario     = p_user

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
      CALL log003_err_sql('Inserindo','apo_oper')
      RETURN FALSE
   END IF
  
  LET p_num_seq_reg = SQLCA.SQLERRD[2] # apo_oper.num_processo

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
  
  IF p_man.cod_eqpto IS NOT NULL THEN
     LET  p_cfp_apms.cod_equip  = p_man.cod_eqpto
  ELSE
     LET  p_cfp_apms.cod_equip  = '0'
  END IF
  
  IF p_man.cod_ferramenta IS NOT NULL THEN
     LET  p_cfp_apms.cod_ferram = p_man.cod_ferramenta
  ELSE
     LET  p_cfp_apms.cod_ferram = '0'
  END IF
  
  LET  p_cfp_apms.cod_cent_trab = p_apo_oper.cod_cent_trab
  LET p_cfp_apms.cod_unid_prod = p_cod_unid_prod
  LET p_cfp_apms.cod_roteiro        = p_cod_roteiro
  LET p_cfp_apms.num_altern_roteiro = p_num_altern_roteiro
  LET p_cfp_apms.num_seq_operac     = p_man.num_seq_operac
  LET p_cfp_apms.cod_operacao       = p_apo_oper.cod_operac
  LET p_cfp_apms.cod_item           = p_apo_oper.cod_item
  LET p_cfp_apms.num_conta          = p_apo_oper.num_conta
  LET p_cfp_apms.cod_local          = p_apo_oper.cod_local
  LET p_cfp_apms.dat_apontamento    = EXTEND(p_apo_oper.dat_apontamento, YEAR TO DAY)
  LET p_cfp_apms.hor_apontamento    = EXTEND(p_apo_oper.dat_apontamento, HOUR TO SECOND)
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
      CALL log003_err_sql('Insert','cfp_apms')
      RETURN FALSE
   END IF

  LET p_qtd_apont = p_apo_oper.qtd_boas+p_apo_oper.qtd_refugo+p_apo_oper.qtd_sucata

  LET p_cfp_appr.cod_empresa        = p_apo_oper.cod_empresa
  LET p_cfp_appr.num_seq_registro   = p_num_seq_reg
  LET p_cfp_appr.dat_producao       = p_apo_oper.dat_producao
  LET p_cfp_appr.cod_item           = p_apo_oper.cod_item
  LET p_cfp_appr.cod_turno          = p_apo_oper.cod_turno
  LET p_cfp_appr.qtd_produzidas     = p_qtd_apont
  LET p_cfp_appr.qtd_pecas_boas     = p_apo_oper.qtd_boas
  LET p_cfp_appr.qtd_sucata         = p_apo_oper.qtd_refugo+p_apo_oper.qtd_sucata
  LET p_cfp_appr.qtd_defeito_real   = 0
  LET p_cfp_appr.qtd_defeito_padrao = 0
  LET p_cfp_appr.qtd_ciclos         = 0
  LET p_cfp_appr.num_operador       = p_man.matricula

  INSERT INTO cfp_appr VALUES(p_cfp_appr.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_appr')
      RETURN FALSE
   END IF

  LET p_cfp_aptm.cod_empresa      = p_apo_oper.cod_empresa
  LET p_cfp_aptm.num_seq_registro = p_num_seq_reg
  LET p_cfp_aptm.dat_producao     = p_apo_oper.dat_producao
  LET p_cfp_aptm.cod_turno        = p_apo_oper.cod_turno
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
  LET p_cfp_aptm.hor_tot_assumido = p_cfp_aptm.hor_tot_periodo

  INSERT INTO cfp_aptm VALUES(p_cfp_aptm.*)
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','cfp_aptm')
      RETURN FALSE
   END IF
   
   INSERT INTO man_relc_tabela
    VALUES(p_cod_empresa,
           p_seq_reg_mestre,
           p_num_seq_reg,
           "B")

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_relc_tabela')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
  
#-------------------------------#
FUNCTION pol0803_le_ferramenta()
#-------------------------------#

   DEFINE p_cod_ferramenta CHAR(15),
          p_seq_processo   INTEGER

   LET p_cod_ferramenta = NULL

   DECLARE cq_consumo CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa             = p_cod_empresa
      AND item                = p_man.cod_item
      AND roteiro             = p_cod_roteiro
      AND roteiro_alternativo = p_num_altern_roteiro
      AND operacao            = p_man.cod_operac
      AND seq_operacao        = p_man.num_seq_operac
   
   FOREACH cq_consumo INTO p_seq_processo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','consumo')
         EXIT FOREACH
      END IF

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = p_seq_processo

      FOREACH cq_fer INTO p_cod_ferramenta
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','man_ferramenta_processo')
            EXIT FOREACH
         END IF
         
         EXIT FOREACH
         
      END FOREACH

   END FOREACH 
   
   IF p_cod_ferramenta IS NULL THEN
      LET p_cod_ferramenta = '0'
   END IF
   
   RETURN (p_cod_ferramenta) 
   
END FUNCTION

#--------------------------#
FUNCTION pol0803_ins_tempo()
#--------------------------#

   LET p_man_tempo_producao.empresa            = p_cod_empresa
   LET p_man_tempo_producao.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_tempo_producao.seq_registro_tempo = 0
   LET p_man_tempo_producao.turno_producao     = p_man.cod_turno
   LET p_man_tempo_producao.data_ini_producao  = p_man.dat_inicial
   LET p_man_tempo_producao.hor_ini_producao   = EXTEND(p_man.hor_inicial, HOUR TO MINUTE)
   LET p_man_tempo_producao.dat_final_producao = p_man.dat_final
   LET p_man_tempo_producao.hor_final_producao = EXTEND(p_man.hor_final, HOUR TO MINUTE)
   LET p_man_tempo_producao.periodo_produtivo  = 'A' # Tipo A=produção Tipo I=parada
   LET p_man_tempo_producao.tempo_tot_producao = p_man.qtd_hor 
   LET p_man_tempo_producao.tmp_ativo_producao = p_man.qtd_hor #descontar tempo de paradas, se houver
   LET p_man_tempo_producao.tmp_inatv_producao = 0 # tempo da parada, se for tipo I
   
   INSERT INTO man_tempo_producao(
      empresa,           
      seq_reg_mestre,    
      seq_registro_tempo,
      turno_producao,    
      data_ini_producao, 
      hor_ini_producao,  
      dat_final_producao,
      hor_final_producao,
      periodo_produtivo, 
      tempo_tot_producao,
      tmp_ativo_producao,
      tmp_inatv_producao)
   VALUES(p_man_tempo_producao.empresa,           
          p_man_tempo_producao.seq_reg_mestre,    
          p_man_tempo_producao.seq_registro_tempo,
          p_man_tempo_producao.turno_producao,    
          p_man_tempo_producao.data_ini_producao, 
          p_man_tempo_producao.hor_ini_producao,  
          p_man_tempo_producao.dat_final_producao,
          p_man_tempo_producao.hor_final_producao,
          p_man_tempo_producao.periodo_produtivo, 
          p_man_tempo_producao.tempo_tot_producao,
          p_man_tempo_producao.tmp_ativo_producao,
          p_man_tempo_producao.tmp_inatv_producao)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Insert','man_apo_detalhe')
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0803_move_estoq()
#----------------------------#

   UPDATE ordens
      SET qtd_boas   = qtd_boas + p_man.qtd_boas,
          qtd_refug  = qtd_refug + p_man.qtd_refugo,
          qtd_sucata = qtd_sucata + p_man.qtd_sucata,
          dat_ini    = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordens')
      RETURN FALSE
   END IF
      
   IF p_man.qtd_boas > 0 THEN
      LET p_qtd_prod = p_man.qtd_boas
      LET p_ies_situa = 'L'
      IF NOT pol0803_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_refugo > 0 THEN
      LET p_qtd_prod = p_man.qtd_refugo
      LET p_ies_situa = 'R'
      IF NOT pol0803_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_sucata > 0 THEN
      LET p_qtd_prod = p_man.qtd_sucata
      LET p_ies_situa = 'R'
      IF NOT pol0803_aponta_estoque() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0803_aponta_estoque()
#--------------------------------#

   IF NOT pol0803_le_item(p_man.cod_item) THEN
      RETURN FALSE
   END IF

   IF p_ies_ctr_estoque = 'S' THEN
      IF NOT pol0803_entrada_prod(p_man.cod_item) THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_cod_oper = 'B'

   IF NOT pol0803_material() THEN 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0803_le_item(p_cod)
#-----------------------------#
   
   DEFINE p_cod  char(15)
   
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
      AND cod_item    = p_cod

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:fli')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0803_aponta_sucata()
#------------------------------#
   
   DEFINE p_qtde_prod DECIMAL(10,3)
   
   LET p_qtde_prod = p_qtd_prod
   LET p_qtd_prod = p_qtd_sucata
   
   IF NOT pol0803_le_item(p_cod_compon) THEN
      RETURN FALSE
   END IF

   IF p_ies_ctr_estoque = 'S' THEN
      IF NOT pol0803_entrada_prod(p_cod_compon) THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_qtd_prod = p_qtde_prod
   
   RETURN TRUE

END FUNCTION   

#---------------------------------------#
FUNCTION pol0803_entrada_prod(p_cod_prod)
#---------------------------------------#
   
   DEFINE p_cod_prod char(15)
   
   LET p_qtd_movto = p_qtd_prod
   LET p_cod_oper  = 'E'

   IF NOT pol0803_le_ctr_grade(p_cod_prod) THEN
      RETURN FALSE
   END IF

   IF p_ies_ctr_lote = 'S' THEN
      LET p_num_lote = p_man.num_lote
   ELSE
      INITIALIZE p_num_lote TO NULL
   END IF
   
   IF p_ies_dat_producao = 'S' THEN
      LET p_dat_aux = p_man.dat_inicial
      LET p_dat_char = p_dat_aux, " ", p_man.hor_inicial
      LET p_date_time = p_dat_char
   ELSE
      LET p_date_time = "1900-01-01 00:00:00"   
   END IF

   LET p_cod_item = p_cod_prod
   
   IF p_num_lote IS NULL THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_cod_empresa
         AND cod_item         = p_cod_prod
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND largura          = p_largura
         AND altura           = p_altura
         AND diametro         = p_diametro
         AND comprimento      = p_comprimento
         AND dat_hor_producao = p_date_time
         AND num_lote           IS NULL
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa      = p_cod_empresa
         AND cod_item         = p_cod_prod
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND largura          = p_largura
         AND altura           = p_altura
         AND diametro         = p_diametro
         AND comprimento      = p_comprimento
         AND dat_hor_producao = p_date_time
         AND num_lote         = p_num_lote
   END IF   

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT pol0803_atualiza_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol0803_ender_carrega()
         IF NOT pol0803_insere_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         ERROR 'Item:', p_cod_prod
         CALL log003_err_sql('Lendo','estoque_lote_ender:fep')
         RETURN FALSE
      END IF
   END IF
   
   IF p_num_lote IS NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa      = p_cod_empresa
         AND cod_item         = p_cod_prod
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND num_lote           IS NULL
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa      = p_cod_empresa
         AND cod_item         = p_cod_prod
         AND cod_local        = p_cod_local_estoq
         AND ies_situa_qtd    = p_ies_situa
         AND num_lote         = p_num_lote
   END IF   

   IF STATUS = 0 THEN
      IF NOT pol0803_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol0803_lote_carrega()
         IF NOT pol0803_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote:fep')
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0803_atualiza_estoque() THEN
      RETURN FALSE
   END IF

   LET p_num_lote_orig  = NULL
   LET p_cod_local_orig = NULL
   LET p_ies_situa_orig = NULL
   LET p_num_lote_dest  = p_num_lote
   LET p_cod_local_dest = p_cod_local_estoq
   LET p_ies_situa_dest = p_ies_situa

   IF NOT pol0803_grava_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   LET p_tip_movto = 'E'
   
   IF NOT pol0803_insere_chf_componente() THEN
      RETURN FALSE
   END IF
   
   LET p_num_transac_pai = p_num_transac_orig
   
   IF NOT pol0803_insere_man_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
  
END FUNCTION
   
#------------------------------------#
FUNCTION pol0803_atualiza_lote_ender()
#------------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque_lote_ender:fal')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_insere_lote_ender()
#-----------------------------------#

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
     CALL log003_err_sql('Inserindo','estoque_lote_ender:file')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0803_insere_man_item()
#---------------------------------#
   
   LET p_tip_producao = "B" #p_estoque_lote_ender.ies_situa_qtd
   
   LET p_man_item_produzido.empresa               = p_cod_empresa
   LET p_man_item_produzido.seq_reg_mestre        = p_seq_reg_mestre
   LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   LET p_man_item_produzido.tip_movto             = 'N'
   LET p_man_item_produzido.item_produzido        = p_estoque_lote_ender.cod_item
   LET p_man_item_produzido.lote_produzido        = p_estoque_lote_ender.num_lote
   LET p_man_item_produzido.grade_1               = p_estoque_lote_ender.cod_grade_1
   LET p_man_item_produzido.grade_2               = p_estoque_lote_ender.cod_grade_2
   LET p_man_item_produzido.grade_3               = p_estoque_lote_ender.cod_grade_3
   LET p_man_item_produzido.grade_4               = p_estoque_lote_ender.cod_grade_4
   LET p_man_item_produzido.grade_5               = p_estoque_lote_ender.cod_grade_5
   LET p_man_item_produzido.num_peca              = p_estoque_lote_ender.num_peca
   LET p_man_item_produzido.serie                 = p_estoque_lote_ender.num_serie
   LET p_man_item_produzido.volume                = p_estoque_lote_ender.num_volume
   LET p_man_item_produzido.comprimento           = p_estoque_lote_ender.comprimento
   LET p_man_item_produzido.largura               = p_estoque_lote_ender.largura
   LET p_man_item_produzido.altura                = p_estoque_lote_ender.altura
   LET p_man_item_produzido.diametro              = p_estoque_lote_ender.diametro
   LET p_man_item_produzido.local                 = p_estoque_lote_ender.cod_local
   LET p_man_item_produzido.endereco              = p_estoque_lote_ender.endereco
   LET p_man_item_produzido.tip_producao          = p_tip_producao
   LET p_man_item_produzido.qtd_produzida         = p_qtd_movto
   LET p_man_item_produzido.qtd_convertida        = 0
   LET p_man_item_produzido.sit_est_producao      = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_item_produzido.data_producao         = p_estoque_lote_ender.dat_hor_producao
   LET p_man_item_produzido.data_valid            = p_estoque_lote_ender.dat_hor_validade
   LET p_man_item_produzido.conta_ctbl            = ''
   LET p_man_item_produzido.moviment_estoque      = p_num_transac_pai
   LET p_man_item_produzido.seq_reg_normal        = ''
   LET p_man_item_produzido.observacao            = p_estoque_lote_ender.tex_reservado
   LET p_man_item_produzido.identificacao_estoque = ' '

   IF NOT pol0803_ins_it_produzido() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0803_ins_it_produzido()#
#----------------------------------#

  INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
     seq_registro_item,    
     tip_movto,            
     item_produzido,       
     lote_produzido,       
     grade_1,              
     grade_2,              
     grade_3,              
     grade_4,              
     grade_5,              
     num_peca,             
     serie,                
     volume,               
     comprimento,          
     largura,              
     altura,               
     diametro,             
     local,                
     endereco,             
     tip_producao,         
     qtd_produzida,        
     qtd_convertida,       
     sit_est_producao,     
     data_producao,        
     data_valid,           
     conta_ctbl,           
     moviment_estoque,     
     seq_reg_normal,       
     observacao,           
     identificacao_estoque)
   VALUES(
     p_man_item_produzido.empresa,              
     p_man_item_produzido.seq_reg_mestre,       
     p_man_item_produzido.seq_registro_item,    
     p_man_item_produzido.tip_movto,            
     p_man_item_produzido.item_produzido,       
     p_man_item_produzido.lote_produzido,       
     p_man_item_produzido.grade_1,              
     p_man_item_produzido.grade_2,              
     p_man_item_produzido.grade_3,              
     p_man_item_produzido.grade_4,              
     p_man_item_produzido.grade_5,              
     p_man_item_produzido.num_peca,             
     p_man_item_produzido.serie,                
     p_man_item_produzido.volume,               
     p_man_item_produzido.comprimento,          
     p_man_item_produzido.largura,              
     p_man_item_produzido.altura,               
     p_man_item_produzido.diametro,             
     p_man_item_produzido.local,                
     p_man_item_produzido.endereco,             
     p_man_item_produzido.tip_producao,         
     p_man_item_produzido.qtd_produzida,        
     p_man_item_produzido.qtd_convertida,       
     p_man_item_produzido.sit_est_producao,     
     p_man_item_produzido.data_producao,        
     p_man_item_produzido.data_valid,           
     p_man_item_produzido.conta_ctbl,           
     p_man_item_produzido.moviment_estoque,     
     p_man_item_produzido.seq_reg_normal,       
     p_man_item_produzido.observacao,           
     p_man_item_produzido.identificacao_estoque)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','man_item_produzido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0803_insere_man_consumo()
#-----------------------------------#

   LET p_man_comp_consumido.empresa            = p_estoque_lote_ender.cod_empresa
   LET p_man_comp_consumido.seq_reg_mestre     = p_seq_reg_mestre
   LET p_man_comp_consumido.seq_registro_item  = 0
   LET p_man_comp_consumido.tip_movto          = p_cod_tip_movto
   LET p_man_comp_consumido.item_componente    = p_estoque_lote_ender.cod_item
   LET p_man_comp_consumido.grade_1            = p_estoque_lote_ender.cod_grade_1  
   LET p_man_comp_consumido.grade_2            = p_estoque_lote_ender.cod_grade_2  
   LET p_man_comp_consumido.grade_3            = p_estoque_lote_ender.cod_grade_3  
   LET p_man_comp_consumido.grade_4            = p_estoque_lote_ender.cod_grade_4  
   LET p_man_comp_consumido.grade_5            = p_estoque_lote_ender.cod_grade_5  
   LET p_man_comp_consumido.num_peca           = p_estoque_lote_ender.num_peca     
   LET p_man_comp_consumido.serie              = p_estoque_lote_ender.num_serie    
   LET p_man_comp_consumido.volume             = p_estoque_lote_ender.num_volume   
   LET p_man_comp_consumido.comprimento        = p_estoque_lote_ender.comprimento  
   LET p_man_comp_consumido.largura            = p_estoque_lote_ender.largura      
   LET p_man_comp_consumido.altura             = p_estoque_lote_ender.altura       
   LET p_man_comp_consumido.diametro           = p_estoque_lote_ender.diametro     
   LET p_man_comp_consumido.lote_componente    = p_estoque_lote_ender.num_lote    
   LET p_man_comp_consumido.local_estoque      = p_estoque_lote_ender.cod_local     
   LET p_man_comp_consumido.endereco           = p_estoque_lote_ender.endereco
   LET p_man_comp_consumido.qtd_baixa_prevista = p_qtd_movto                       
   LET p_man_comp_consumido.qtd_baixa_real     = p_qtd_movto
   LET p_man_comp_consumido.sit_est_componente = p_estoque_lote_ender.ies_situa_qtd
   LET p_man_comp_consumido.data_producao      = p_estoque_lote_ender.dat_hor_producao
   LET p_man_comp_consumido.data_valid         = p_estoque_lote_ender.dat_hor_validade
   LET p_man_comp_consumido.conta_ctbl         = p_num_conta
   LET p_man_comp_consumido.moviment_estoque   = p_num_transac_orig
   LET p_man_comp_consumido.mov_estoque_pai    = p_num_transac_pai
   LET p_man_comp_consumido.seq_reg_normal     = ''
   LET p_man_comp_consumido.observacao         = p_estoque_lote_ender.tex_reservado
   LET p_man_comp_consumido.identificacao_estoque = ''
   LET p_man_comp_consumido.depositante        = ''

   IF NOT pol0803_ins_comp_consumido() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0803_ins_comp_consumido()#
#------------------------------------#

   INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
     seq_registro_item, 
     tip_movto,         
     item_componente,   
     grade_1,           
     grade_2,           
     grade_3,           
     grade_4,           
     grade_5,           
     num_peca,          
     serie,             
     volume,            
     comprimento,       
     largura,           
     altura,            
     diametro,          
     lote_componente,   
     local_estoque,     
     endereco,          
     qtd_baixa_prevista,
     qtd_baixa_real,    
     sit_est_componente,
     data_producao,     
     data_valid,        
     conta_ctbl,        
     moviment_estoque,  
     mov_estoque_pai,   
     seq_reg_normal,    
     observacao,        
     identificacao_estoque,
     depositante)
   VALUES (
     p_man_comp_consumido.empresa,                   
     p_man_comp_consumido.seq_reg_mestre,    
     p_man_comp_consumido.seq_registro_item, 
     p_man_comp_consumido.tip_movto,         
     p_man_comp_consumido.item_componente,   
     p_man_comp_consumido.grade_1,           
     p_man_comp_consumido.grade_2,           
     p_man_comp_consumido.grade_3,           
     p_man_comp_consumido.grade_4,           
     p_man_comp_consumido.grade_5,           
     p_man_comp_consumido.num_peca,         
     p_man_comp_consumido.serie,             
     p_man_comp_consumido.volume,            
     p_man_comp_consumido.comprimento,       
     p_man_comp_consumido.largura,           
     p_man_comp_consumido.altura,            
     p_man_comp_consumido.diametro,          
     p_man_comp_consumido.lote_componente,   
     p_man_comp_consumido.local_estoque,     
     p_man_comp_consumido.endereco,          
     p_man_comp_consumido.qtd_baixa_prevista,
     p_man_comp_consumido.qtd_baixa_real,    
     p_man_comp_consumido.sit_est_componente,
     p_man_comp_consumido.data_producao,     
     p_man_comp_consumido.data_valid,        
     p_man_comp_consumido.conta_ctbl,        
     p_man_comp_consumido.moviment_estoque,  
     p_man_comp_consumido.mov_estoque_pai,   
     p_man_comp_consumido.seq_reg_normal,    
     p_man_comp_consumido.observacao,        
     p_man_comp_consumido.identificacao_estoque,
     p_man_comp_consumido.depositante)     
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','man_comp_consumido')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0803_insere_chf_componente()
#--------------------------------------#

  LET p_chf_compon.empresa            = p_estoque_lote_ender.cod_empresa
  LET p_chf_compon.sequencia_registro = p_num_seq_reg
  LET p_chf_compon.tip_movto          = p_tip_movto
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
      CALL log003_err_sql('Inserindo','chf_componente')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_ender_carrega()
#-------------------------------#

   LET p_estoque_lote_ender.cod_empresa   = p_cod_empresa
	 LET p_estoque_lote_ender.cod_item      = p_cod_item
	 LET p_estoque_lote_ender.cod_local     = p_cod_local_estoq
	 LET p_estoque_lote_ender.num_lote      = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo     = p_qtd_movto
   LET p_estoque_lote_ender.largura       = p_largura
   LET p_estoque_lote_ender.altura        = p_altura
   LET p_estoque_lote_ender.diametro      = p_diametro
   LET p_estoque_lote_ender.comprimento   = p_comprimento
   LET p_estoque_lote_ender.num_serie     = ' '
   LET p_estoque_lote_ender.dat_hor_producao = p_date_time
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
   LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
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
   
END FUNCTION

#-------------------------------#
FUNCTION pol0803_atualiza_lote()
#-------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque_lote:fal')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0803_lote_carrega()
#------------------------------#

   LET p_estoque_lote.cod_empresa   = p_cod_empresa
	 LET p_estoque_lote.cod_item      = p_cod_item
	 LET p_estoque_lote.cod_local     = p_cod_local_estoq
	 LET p_estoque_lote.num_lote      = p_num_lote
	 LET p_estoque_lote.ies_situa_qtd = p_ies_situa
	 LET p_estoque_lote.qtd_saldo     = p_qtd_movto
	 LET p_estoque_lote.num_transac   = 0

END FUNCTION

#-----------------------------#
FUNCTION pol0803_insere_lote()
#-----------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo,
          num_transac)  
          VALUES(p_estoque_lote.cod_empresa,
                 p_estoque_lote.cod_item,
                 p_estoque_lote.cod_local,
                 p_estoque_lote.num_lote,
                 p_estoque_lote.ies_situa_qtd,
                 p_estoque_lote.qtd_saldo,
                 p_estoque_lote.num_transac)
                 
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_lote:fil')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0803_atualiza_estoque()
#---------------------------------#

   IF p_estoque_lote_ender.ies_situa_qtd = 'L' THEN
      UPDATE estoque
         SET qtd_liberada    = qtd_liberada + p_qtd_movto,
             dat_ult_entrada = TODAY
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   ELSE
      UPDATE estoque
         SET qtd_rejeitada   = qtd_rejeitada + p_qtd_movto,
             dat_ult_entrada = TODAY
       WHERE cod_empresa = p_estoque_lote_ender.cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
   END IF

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','estoque:ae')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0803_le_ctr_grade(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item      LIKE item.cod_item,
          p_cod_lin_prod  LIKE item.cod_lin_prod,
          p_cod_lin_recei LIKE item.cod_lin_recei,
          p_cod_seg_merc  LIKE item.cod_seg_merc,
          p_cod_cla_uso   LIKE item.cod_cla_uso,
          p_cod_familia   LIKE item.cod_familia
   
   SELECT cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso,
          cod_familia
     INTO p_cod_lin_prod,
          p_cod_lin_recei,
          p_cod_seg_merc,
          p_cod_cla_uso,
          p_cod_familia
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:flcg')
      RETURN FALSE
   END IF
   
   SELECT ies_largura,
          ies_altura,
          ies_diametro,
          ies_comprimento,
          reservado_2,
          ies_dat_producao
     INTO p_ies_largura,
          p_ies_altura,
          p_ies_diametro,
          p_ies_comprimento,
          p_ies_serie,
          p_ies_dat_producao
     FROM item_ctr_grade
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_item
      AND cod_lin_prod  = p_cod_lin_prod
      AND cod_lin_recei = p_cod_lin_recei
      AND cod_seg_merc  = p_cod_seg_merc
      AND cod_cla_uso   = p_cod_cla_uso
      AND cod_familia   = p_cod_familia

   IF STATUS = 100 THEN
      LET p_ies_largura      = 'N'
      LET p_ies_altura       = 'N'
      LET p_ies_diametro     = 'N'
      LET p_ies_comprimento  = 'N'
      LET p_ies_serie        = 'N'
      LET p_ies_dat_producao = 'N'
   ELSE
      IF STATUS <> 0 THEN
        CALL log003_err_sql('Lendo','item_ctr_grade:flcg')
        RETURN FALSE
      END IF
   END IF

   LET p_largura = 0
   LET p_altura = 0
   LET p_diametro = 0
   LET p_comprimento = 0

   IF p_ies_largura = 'S' THEN
   END IF

   IF p_ies_altura = 'S' THEN
   END IF
   
   IF p_ies_diametro = 'S' THEN
   END IF

   IF p_ies_comprimento = 'S' THEN
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0803_itens_bene()
#---------------------------#

   DEFINE p_num_pedido     LIKE pedidos.num_pedido,
          p_cod_cliente    LIKE clientes.cod_cliente,
          p_nom_cliente    LIKE clientes.nom_cliente,
          p_num_docum      LIKE ordens.num_docum,
          p_cod_menu       INTEGER,
          p_num_pedido_cli CHAR(10),
          p_num_pos        CHAR(03)

   DEFINE pr_bene          ARRAY[50] OF RECORD
          cod_item         LIKE item.cod_item,
          den_item         LIKE item.den_item_reduz,
          cod_compon       LIKE item.cod_item,
          tip_compon       LIKE item.ies_tip_item,
          num_ordem        LIKE ordens.num_ordem
   END RECORD
   
   LET 	INT_FLAG = FALSE
   
   INITIALIZE p_nom_tela, pr_bene, p_num_pedido TO NULL
   CALL log130_procura_caminho("pol08032") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol08032 AT 7,8 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, FORM LINE FIRST)

   INPUT p_num_pedido
         WITHOUT DEFAULTS FROM num_pedido

   AFTER FIELD num_pedido
      
      SELECT cod_cliente
        INTO p_cod_cliente
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_num_pedido
      
      IF STATUS = 100 THEN
         SELECT cod_cliente
           INTO p_cod_cliente
           FROM pedido_dig_mest
          WHERE cod_empresa = p_cod_empresa
            AND num_pedido  = p_num_pedido
         IF STATUS = 100 THEN
            ERROR 'Pedido inexistente !!!'
            NEXT FIELD num_pedido
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','pedido_dig_mest')
               RETURN FALSE
            END IF
         END IF
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','Pedidos')
            RETURN FALSE
         END IF
      END IF
      
      SELECT nom_cliente
        INTO p_nom_cliente
        FROM clientes
       WHERE cod_cliente = p_cod_cliente
      
      IF STATUS = 100 THEN
         LET p_nom_cliente = 'CLIENTE NÃO CADASTRADO'
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','clientes')
            RETURN FALSE
         END IF
      END IF
      
      DISPLAY p_nom_cliente TO nom_cliente
      LET p_num_docum = p_num_pedido
      
      SELECT COUNT(num_ordem)
        INTO p_count 
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_docum   = p_num_docum
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordens')
         RETURN FALSE
      END IF
      
      IF p_count = 0 THEN
         ERROR 'Pedido sem as ordens de produção !!!'
         NEXT FIELD num_pedido
      END IF

      SELECT num_pedido,
             pos
        INTO p_num_pedido_cli,
             p_num_pos
        FROM cfg_cp_amor912
       WHERE cod_empresa   = p_cod_empresa
         AND num_ped_venda = p_num_pedido
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cfg_cp_amor912')
         NEXT FIELD num_pedido
      END IF
           
   END INPUT
   
   IF NOT INT_FLAG = 0 THEN
      RETURN FALSE
   END IF
   
   LET p_houve_erro = FALSE
   LET p_index = 1
   
   DROP TABLE item_repete_1054 

    CREATE TEMP TABLE item_repete_1054(
         num_ordem      INTEGER,
         cod_item       CHAR(15)
       );
         
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","item_repete_1054")
         RETURN FALSE
      END IF
   
   DECLARE cq_bene CURSOR FOR
    SELECT a.cod_menu,
           a.cod_item,
           b.den_item_reduz
      FROM cfg_cp_estr912 a,
           item b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.num_pedido   = p_num_pedido_cli
       AND a.pos          = p_num_pos
       AND b.cod_empresa  = a.cod_empresa
       AND b.cod_item     = a.cod_item
       AND b.ies_tip_item = 'B'

   FOREACH cq_bene INTO 
           p_cod_menu, 
           pr_bene[p_index].cod_item,
           pr_bene[p_index].den_item
   
      SELECT a.cod_item,
             b.ies_tip_item
        INTO pr_bene[p_index].cod_compon,
             pr_bene[p_index].tip_compon
        FROM cfg_cp_estr912 a,
             item b
       WHERE a.cod_empresa  = p_cod_empresa
         AND a.num_pedido   = p_num_pedido_cli
         AND a.pos          = p_num_pos
         AND cod_pai        = p_cod_menu
         AND b.cod_empresa  = a.cod_empresa
         AND b.cod_item     = a.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cfg_cp_estr912')
         LET p_houve_erro = TRUE
         EXIT FOREACH
      END IF
      
      IF pr_bene[p_index].tip_compon = 'P' THEN
         DECLARE cq_op CURSOR FOR
                  SELECT num_ordem
           FROM ordens
          WHERE cod_empresa  = p_cod_empresa
            AND num_docum    = p_num_docum
            AND cod_item     = pr_bene[p_index].cod_compon
            AND cod_item_pai = pr_bene[p_index].cod_item
            AND num_ordem not in(select num_ordem   from item_repete_1054)
            
         FOREACH cq_op  INTO pr_bene[p_index].num_ordem
                 INSERT INTO item_repete_1054 
                   VALUES(pr_bene[p_index].num_ordem, pr_bene[p_index].cod_compon)
                 EXIT FOREACH
         END FOREACH        
      ELSE
         LET pr_bene[p_index].num_ordem = NULL
      END IF
   
      LET p_index = p_index + 1
         
   END FOREACH
   
   IF p_houve_erro THEN
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   MESSAGE 'Esc=Sair'
   
   DISPLAY ARRAY pr_bene TO sr_bene.*
   
   CLOSE WINDOW w_pol08032
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0803_estornar()#
#--------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol08033") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol08033 AT 6,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol0803_sel_processo() RETURNING p_status
   CLOSE WINDOW w_pol08033
   
   RETURN p_status

END FUNCTION

#------------------------------#
FUNCTION pol0803_sel_processo()#
#------------------------------#

   LET INT_FLAG = FALSE
   
   INITIALIZE p_dat_processo, p_nom_usuario, 
              p_num_op, p_num_processo TO NULL
   
   INPUT p_num_op, p_nom_usuario, p_dat_processo 
      WITHOUT DEFAULTS 
    FROM num_op, nom_usuario, dat_processo

      AFTER FIELD num_op
         
         IF p_num_op IS  NOT NULL THEN
         
            SELECT COUNT(num_ordem)
              INTO p_count
              FROM processo_apont_1054
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem = p_num_op
               AND ies_estornado = 'N'
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','processo_apont_1054:num_ordem')
               NEXT FIELD num_op
            END IF
            
            IF p_count = 0 THEN
               LET p_msg = 'Não há apontamento sem estorno, \n para a ordem informada.'
               CALL log0030_mensagem(p_msg,'info')
               NEXT FIELD num_op
            END IF
            
         END IF
            
      AFTER FIELD nom_usuario
         
         IF p_nom_usuario IS NOT NULL THEN
            CALL pol0803_le_user()
            IF p_nom_funcionario IS NULL THEN
               ERROR 'Usuário unválido.'
               NEXT FIELD nom_usuario
            END IF
         ELSE
            LET p_nom_funcionario = NULL
         END IF
                  
         DISPLAY p_nom_funcionario TO nom_funcionario

      BEFORE FIELD dat_processo

         IF p_dat_processo IS NULL THEN
            CALL pol0803_le_processo() 
               RETURNING p_dat_processo, p_nom_usuario, p_num_op, p_qtd_boas
            DISPLAY p_num_op TO num_op
            DISPLAY p_qtd_boas TO qtd_boas
            DISPLAY p_dat_processo TO dat_processo
            DISPLAY p_nom_usuario to nom_usuario
            CALL pol0803_le_user()
            DISPLAY p_nom_funcionario TO nom_funcionario
         END IF
      
   
      AFTER FIELD dat_processo
         
         IF p_dat_processo IS NOT NULL THEN
         
            SELECT ies_estornado,
                   num_ordem,
                   qtd_boas,
                   num_processo
              INTO p_ies_estornado,
                   p_num_op,
                   p_qtd_boas,
                   p_num_processo
              FROM processo_apont_1054
             WHERE cod_empresa = p_cod_empresa
               AND usuario = p_nom_usuario
               AND dat_processo = p_dat_processo
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','processo_apont_1054')
               NEXT FIELD dat_processo
            END IF

            IF p_ies_estornado = 'S' THEN
               ERROR 'Processo já estornado.'
               NEXT FIELD dat_processo
            END IF
         
            DISPLAY p_num_op to num_ordem
            DISPLAY p_qtd_boas to qtd_boas
            DISPLAY p_nom_usuario TO nom_usuario
            CALL pol0803_le_user()
            DISPLAY p_nom_funcionario TO nom_funcionario
         ELSE
            LET p_num_processo = NULL  
         END IF
         
      ON KEY (control-z)
         CALL pol0803_popup()
      
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF p_num_processo IS NULL THEN
               ERROR 'Indforme o processo.'
               NEXT FIELD dat_processo
            END IF
         END IF
         
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   LET p_msg = 'Confirma o estorno dos\n apontamentos do\n programa informado?'

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0803_revert_apon() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION      

#-------------------------#
FUNCTION pol0803_le_user()#
#-------------------------#
            
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM usuarios
    WHERE cod_usuario = p_nom_usuario
         
   IF STATUS <> 0 THEN
      LET p_nom_funcionario = NULL
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0803_eh_possivel()#
#-----------------------------#

   
   SELECT MIN(num_transac) 
     INTO p_num_transac
     FROM trans_apont_1054 
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = p_num_processo
      AND cod_operacao = 'E'
      AND num_seq_apont = p_num_seq_apont
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('FOREACH','cq_stok')
      RETURN FALSE
   END IF
      
   SELECT cod_item, 
          dat_movto,
          qtd_movto,
          cod_local_est_dest,
          num_lote_dest,
          ies_sit_est_dest
     INTO p_cod_item,
          p_dat_movto,
          p_qtd_movto,
          p_cod_local_estoq,
          p_num_lote,
          p_ies_situa
     FROM estoque_trans 
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','estoque_trans')
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
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ESTOQUE_TRANS_END')
      RETURN FALSE
   END IF

   IF NOT pol0803_chek_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION                

#-----------------------------#
FUNCTION pol0803_chek_estoque()
#-----------------------------#

   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_dat_movto <= p_dat_fecha_ult_man THEN
         LET p_msg = 'A DATA DA PRODUCAO EH MENOR QUE A DATA DO FECHEMENTO DA MANUFATURA'
         CALL pol0803_erro_estorno()
      END IF
   END IF

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_dat_movto < p_dat_fecha_ult_sup THEN
         LET p_msg = 'A DATA DA PRODUCAO EH MENOR QUE A DATA DO FECHEMENTO DO ESTOQUE'
         CALL pol0803_erro_estorno()
      END IF
   END IF
   
   CALL pol0803_le_ender()
   
   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_LOTE_ENDER')
         RETURN FALSE
      END IF
   END IF  
   
   IF p_num_lote IS NULL THEN
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_local   = p_cod_local_orig
         AND num_lote IS NULL
   ELSE
      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_local   = p_cod_local_orig
         AND num_lote = p_num_lote
   END IF
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_loc_reser')
      RETURN FALSE
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

   IF p_qtd_saldo < p_qtd_movto THEN   
      LET p_msg = 'ESTOQUE_LOTE_ENDER: NAO HA SALDO NO ITEM ',p_cod_item CLIPPED,' P/ ESTORNO DA PRODUCAO'
      CALL pol0803_erro_estorno()
      RETURN TRUE
   END IF

   CALL pol0803_le_lote()

   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_LOTE')
         RETURN FALSE
      END IF
   END IF  

   IF p_qtd_saldo IS NULL OR p_qtd_saldo < 0 THEN
      LET p_qtd_saldo = 0
   END IF
   
   IF p_qtd_saldo > p_qtd_reservada THEN
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
   ELSE
      LET p_qtd_saldo = 0
   END IF

   IF p_qtd_saldo < p_qtd_movto THEN   
      LET p_msg = 'ESTOQUE_LOTE: NAO HA SALDO NO ITEM ',p_cod_item CLIPPED,' P/ ESTORNO DA PRODUCAO'
      CALL pol0803_erro_estorno()
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0803_le_ender()#
#--------------------------#

   IF p_num_lote IS NULL THEN
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_ender
		    FROM estoque_lote_ender
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_largura
         AND altura        = p_altura        
         AND diametro      = p_diametro      
         AND comprimento   = p_comprimento    
         AND num_lote IS NULL
   ELSE
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_ender
		    FROM estoque_lote_ender
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_largura
         AND altura        = p_altura        
         AND diametro      = p_diametro      
         AND comprimento   = p_comprimento    
         AND num_lote      = p_num_lote
   END IF

END FUNCTION

#-------------------------#
FUNCTION pol0803_le_lote()#
#-------------------------#

   IF p_num_lote IS NULL THEN
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_lote
		    FROM estoque_lote
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote IS NULL
   ELSE
    	SELECT qtd_saldo,
    	       num_transac
		    INTO p_qtd_saldo,
		         p_trans_lote
		    FROM estoque_lote
		   WHERE cod_empresa   = p_cod_empresa
		     AND cod_item      = p_cod_item
		     AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa
         AND num_lote = p_num_lote
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0803_erro_estorno()
#------------------------------#

   LET p_criticou = TRUE

   LET p_qtd_erro = p_qtd_erro + 1
   LET pr_erro_est[p_qtd_erro].den_erro = p_msg
      
END FUNCTION

#----------------------------------#
 FUNCTION pol0803_ins_erro_estorno()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0803_del_estorno_erro() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   FOR p_index = 1 TO p_qtd_erro
       
       IF pr_erro_est[p_index].den_erro IS NOT NULL THEN
       
          INSERT INTO estorno_erro_1054
           VALUES (p_cod_empresa, p_nom_usuario, p_dat_processo, 
                   p_num_processo, pr_erro_est[p_index].den_erro)

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','estorno_erro_1054')
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF                                           
       END IF
   END FOR
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0803_del_estorno_erro()
#----------------------------------#

   DELETE FROM estorno_erro_1054
      WHERE cod_empresa = p_cod_empresa
        AND dat_processo = p_dat_processo
        AND usuario = p_nom_usuario        

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','estorno_erro_1054')
      RETURN FALSE
   END IF                                           

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0803_exib_erro_estorno()
#----------------------------------#

   MESSAGE ''
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol08035") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol08035 AT 6,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol0803_mostra_erro() RETURNING p_status
   CLOSE WINDOW w_pol08035
   
   RETURN p_status

END FUNCTION

#----------------------------#
FUNCTION pol0803_mostra_erro()
#----------------------------#
   
   DEFINE pr_critica ARRAY[10] OF RECORD
          den_critica CHAR(80)
   END RECORD
   
   LET INT_FLAG = FALSE
   
   INPUT p_nom_usuario, p_dat_processo 
      WITHOUT DEFAULTS 
    FROM nom_usuario, dat_processo

      BEFORE INPUT
         IF p_opcao = 'E' THEN
            EXIT INPUT
         END IF
         
      AFTER FIELD nom_usuario
         
         IF p_nom_usuario IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD nom_usuario
         END IF
         
      BEFORE FIELD dat_processo

         IF p_nom_usuario IS NULL THEN
            NEXT FIELD nom_usuario
         END IF
   
      AFTER FIELD dat_processo
         
         IF p_dat_processo IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório.'
            NEXT FIELD dat_processo
         END IF
      
         SELECT num_ordem,
                qtd_boas,
                num_processo
           INTO p_num_op,
                p_qtd_boas,
                p_num_processo
           FROM processo_apont_1054
          WHERE cod_empresa = p_cod_empresa
            AND usuario = p_nom_usuario
            AND dat_processo = p_dat_processo
            
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','processo_apont_1054')
            NEXT FIELD dat_processo
         END IF

      ON KEY (control-z)
         CALL pol0803_popup()

   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   DISPLAY p_num_op to num_ordem
   DISPLAY p_qtd_boas to qtd_boas
   DISPLAY p_num_processo TO num_processo
   
   LET p_index = 1
   
   DECLARE cq_critica CURSOR FOR
    SELECT den_critica
      FROM estorno_erro_1054
     WHERE cod_empresa  = p_cod_empresa
       AND usuario = p_nom_usuario
       AND dat_processo = p_dat_processo

   FOREACH cq_critica INTO pr_critica[p_index].den_critica
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_critica')
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1

      IF p_index > 10 THEN
         ERROR 'Limite de linhas da grade ultrapassado !!!'
         EXIT FOREACH
      END IF

   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não erros de estorno, para\n os parâmetros informados'
      CALL log0030_mensagem(p_msg,'INFO')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)

   DISPLAY ARRAY pr_critica TO  sr_critica.*
      
END FUNCTION

#-----------------------------#
FUNCTION pol0803_checa_apont()#
#-----------------------------#

   DEFINE p_seq_txt     CHAR(15),
          p_qtd_oper    DECIMAL(10,3)

   SELECT empresa
     FROM man_apo_mestre
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_seq_reg_mestre

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_seq_reg_mestre
      LET p_msg = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
                  ' NAO ENCONTRADO NA TAB MAN_APO_MESTRE'
      CALL pol0803_erro_estorno()
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','MAN_APO_MESTRE')
         RETURN FALSE
      END IF
   END IF

   SELECT cod_empresa
     FROM apo_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_processo = p_num_seq_reg

   IF STATUS = 100 THEN   
      LET p_seq_txt = p_num_seq_reg
      LET p_msg = 'APONTAMENTO DE SEQUENCIA ', p_seq_txt CLIPPED, 
                  ' NAO ENCONTRADO NA TAB APO_OPER'
      CALL pol0803_erro_estorno()
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','APO_OPER')
         RETURN FALSE
      END IF
   END IF

   SELECT ies_situa,
          dat_ini,
          (qtd_boas + qtd_refug + qtd_sucata)
     INTO p_ies_situa,
          p_dat_inicio,
          p_qtd_ordem
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_man.num_ordem        

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','APO_OPER')
      RETURN FALSE
   END IF
   
   IF p_ies_situa = '4' THEN
   ELSE
      LET p_seq_txt = p_man.num_ordem        
      LET p_msg = 'ORDEM ', p_seq_txt CLIPPED, 
                  ' NAO ESTA LIBERADA'
      CALL pol0803_erro_estorno()
   END IF
   
   IF p_man.num_seq_operac IS NULL THEN
      RETURN TRUE
   END IF
   
   SELECT qtd_boas + qtd_refugo + qtd_sucata
     INTO p_qtd_oper
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
	    AND num_ordem      = p_man.num_ordem
	    AND cod_operac     = p_man.cod_operac
	    AND num_seq_operac = p_man.num_seq_operac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ord_oper')
      RETURN FALSE
   END IF
   
   LET p_qtd_estorno = p_man.qtd_boas + p_man.qtd_refugo + p_man.qtd_sucata 
   
   IF p_qtd_estorno > p_qtd_oper THEN
      LET p_seq_txt = p_man.num_ordem  
      LET p_seq_txt = p_seq_txt CLIPPED, '/', p_man.cod_operac
      LET p_msg = 'ORDEM/OPERACAO ', p_seq_txt CLIPPED, 
                  ' - QTD APONTADA MENOR QUE QTD A ESTORNAR'
      CALL pol0803_erro_estorno()
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#-----------------------------#
FUNCTION pol0803_revert_apon()#
#-----------------------------#
   
   LET p_dat_atu = TODAY
   LET p_hor_atu = TIME
   LET p_cod_tip_movto = 'R'
   
   LET p_criticou = FALSE
   LET p_qtd_erro = 0
   INITIALIZE pr_erro_est TO NULL
   
   IF NOT pol0803_le_parametros() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_aptos CURSOR FOR
    SELECT * 
      FROM man_apont_1054
     WHERE cod_empresa  = p_cod_empresa
       AND num_processo = p_num_processo
       AND cod_status   = 'A'
     ORDER BY num_seq_apont DESC

   FOREACH cq_aptos INTO p_man.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_man')
         RETURN FALSE
      END IF                                           

      LET p_num_seq_apont = p_man.num_seq_apont

      SELECT seq_apo_oper,  
             seq_apo_mestre
        INTO p_num_seq_reg, 
             p_seq_reg_mestre
        FROM sequencia_apo_1054
       WHERE cod_empresa   = p_cod_empresa
         AND num_processo  = p_num_processo
         AND num_seq_apont = p_num_seq_apont

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','sequencia_apo_1054')
         RETURN FALSE
      END IF                                           

      IF NOT pol0803_checa_apont() THEN
         RETURN FALSE
      END IF       

      IF p_man.oper_final = 'S' THEN
         IF NOT pol0803_eh_possivel() THEN
           RETURN FALSE
         END IF
      END IF

      IF p_criticou THEN
         RETURN FALSE
      END IF
      
      IF NOT pol0803_estorna_novas() THEN
         RETURN FALSE
      END IF       

      IF NOT pol0803_estorna_velhas() THEN
         RETURN FALSE
      END IF       
         
      IF p_man.oper_final = 'S' THEN
         IF NOT pol0803_estorna_estoq() THEN
           RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   UPDATE processo_apont_1054
      SET ies_estornado = 'S'
    WHERE cod_empresa = p_cod_empresa
      AND usuario = p_nom_usuario
      AND dat_processo = p_dat_processo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','processo_apont_1054')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION      

#-------------------------------#
FUNCTION pol0803_estorna_novas()#
#-------------------------------#
   
   UPDATE man_apo_mestre 
      SET sit_apontamento = 'C',
          tip_moviment = 'E',
          usuario_estorno = p_user,
          data_estorno = p_dat_atu,
          hor_estorno = p_hor_atu
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = p_seq_reg_mestre

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','MAN_APO_MESTRE')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0803_estorna_velhas()#
#--------------------------------#
   
   IF p_man.num_seq_operac IS NOT NULL THEN
      UPDATE ord_oper
         SET qtd_boas   = qtd_boas - p_man.qtd_boas,
             qtd_refugo = qtd_refugo - p_man.qtd_refugo,
             qtd_sucata = qtd_sucata - p_man.qtd_sucata,
             ies_apontamento = 'S'
       WHERE cod_empresa    = p_cod_empresa
	       AND num_ordem      = p_man.num_ordem
	       AND cod_operac     = p_man.cod_operac
	       AND num_seq_operac = p_man.num_seq_operac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','ORD_OPER')
         RETURN FALSE
      END IF
   END IF
   
   UPDATE apo_oper
      SET cod_tip_movto = 'E'
    WHERE cod_empresa  = p_cod_empresa
      AND num_processo = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','APO_OPER')
      RETURN FALSE
   END IF

   UPDATE cfp_apms 
      SET cod_tip_movto = 'E',
          ies_situa = 'C', 
          dat_estorno = p_dat_atu,
          hor_estorno = p_hor_atu,
          nom_usu_estorno = p_user
    WHERE cod_empresa      = p_cod_empresa
      AND num_seq_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','CFP_APMS')
      RETURN FALSE
   END IF

   UPDATE chf_componente
      SET tip_movto = 'R'
    WHERE empresa            = p_cod_empresa
      AND sequencia_registro = p_num_seq_reg

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','CHF_COMPONENTE')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol0803_estorna_estoq()#
#-------------------------------#

   IF p_qtd_ordem <= p_qtd_estorno THEN
      LET p_dat_inicio = NULL
   END IF 

   UPDATE ordens
      SET qtd_boas = qtd_boas - p_man.qtd_boas,
          qtd_refug = qtd_refug - p_man.qtd_refugo,
          qtd_sucata = qtd_sucata - p_man.qtd_sucata,
          dat_ini = p_dat_inicio
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_man.num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','ORDENS')
      RETURN FALSE
   END IF

   DECLARE cq_neces CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_item_pai
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_man.num_ordem

   FOREACH cq_neces INTO 
           p_cod_compon, 
           p_qtd_necessaria,
           p_num_neces

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_neces')
         RETURN FALSE
      END IF  

      LET p_qtd_baixar = p_qtd_necessaria * p_qtd_movto

      IF NOT pol0803_le_item_man() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_tip_item MATCHES '[T]' OR 
         p_ctr_estoque = 'N'          OR
         p_sofre_baixa = 'N'        THEN
         CONTINUE FOREACH
      END IF

      UPDATE necessidades
         SET qtd_saida = qtd_saida - p_qtd_baixar
       WHERE cod_empresa = p_cod_empresa
         AND num_neces   = p_num_neces

      IF STATUS <> 0 THEN
         CALL log003_err_sql('update','necessidades')
         RETURN FALSE
      END IF  
         
   END FOREACH

   DECLARE cq_est_produzido CURSOR FOR
    SELECT * 
      FROM man_item_produzido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_seq_reg_mestre
   
   FOREACH cq_est_produzido INTO p_man_item_produzido.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_est_produzido')
         RETURN FALSE
      END IF

      LET p_man_item_produzido.tip_movto = 'E'
      LET p_man_item_produzido.seq_registro_item     = 0 #campo serial
   
      IF NOT pol0803_ins_it_produzido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   DECLARE cq_consumo CURSOR FOR
    SELECT * 
      FROM man_comp_consumido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = p_seq_reg_mestre
   
   FOREACH cq_consumo  INTO p_man_comp_consumido.*   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_CONSUMO')
         RETURN FALSE
      END IF

      LET p_man_comp_consumido.tip_movto = 'E'
      LET p_man_comp_consumido.seq_registro_item = 0 #campo serial
   
      IF NOT pol0803_ins_comp_consumido() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   DECLARE cq_transac CURSOR FOR
    SELECT num_transac,
           cod_operacao
      FROM trans_apont_1054 
     WHERE num_processo = p_num_processo
       AND num_seq_apont = p_num_seq_apont
   
   FOREACH cq_transac INTO p_num_transac, p_ies_operacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_TRANSAC')
         RETURN FALSE
      END IF
      
      SELECT * 
        INTO p_estoque_trans.*
        FROM estoque_trans
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_TRANS')
         RETURN FALSE
      END IF
      
      IF NOT pol0803_ins_estoq_trans() THEN
         RETURN FALSE
      END IF

      SELECT * 
        INTO p_estoque_trans_end.*
        FROM estoque_trans_end
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ESTOQUE_TRANS_END')
         RETURN FALSE
      END IF

      IF NOT pol0803_ins_est_trans_end() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_insere_estoq_audit() THEN
         RETURN FALSE
      END IF

      IF NOT pol0803_ins_trans_rev() THEN
         RETURN FALSE
      END IF
      
      LET p_cod_item = p_estoque_trans.cod_item     

      IF p_ies_operacao = 'E' THEN
         LET p_cod_local_estoq = p_estoque_trans.cod_local_est_dest
         LET p_ies_situa = p_estoque_trans.ies_sit_est_dest      
         LET p_num_lote = p_estoque_trans.num_lote_dest 
      ELSE
         LET p_cod_local_estoq = p_estoque_trans.cod_local_est_orig
         LET p_ies_situa = p_estoque_trans.ies_sit_est_orig
         LET p_num_lote = p_estoque_trans.num_lote_orig
      END IF

      LET p_largura = p_estoque_trans_end.largura             
      LET p_altura = p_estoque_trans_end.altura                
      LET p_diametro = p_estoque_trans_end.diametro              
      LET p_comprimento = p_estoque_trans_end.comprimento           
      LET p_date_time = p_estoque_trans_end.dat_hor_producao          
      LET p_qtd_movto = p_estoque_trans.qtd_movto       
      
      IF p_ies_operacao = 'E' THEN
         
         LET p_qtd_atu = p_qtd_movto * (-1)
         
         CALL pol0803_le_ender() 
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ESTOQUE_LOTE_ENDER')
            RETURN FALSE
         END IF

         IF NOT pol0803_baixa_ender() THEN
            RETURN FALSE
         END IF
         
         CALL pol0803_le_lote() 
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','ESTOQUE_LOTE')
            RETURN FALSE
         END IF
      
         IF NOT pol0803_baixa_est_lote() THEN
            RETURN FALSE
         END IF
      
      ELSE
      
         LET p_qtd_atu = p_qtd_movto

         CALL pol0803_le_ender() 
         
         IF STATUS = 0 THEN
            IF NOT pol0803_atu_ender() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS = 100 THEN
               CALL pol0803_ender_carrega()
               IF NOT pol0803_insere_lote_ender() THEN
                  RETURN FALSE
               END IF
            ELSE
               CALL log003_err_sql('SELECT','ESTOQUE_LOTE_ENDER')
               RETURN FALSE
            END IF
        END IF
        
         CALL pol0803_le_lote() 
         
         IF STATUS = 0 THEN
            IF NOT pol0803_atu_lote() THEN
               RETURN FALSE
            END IF
         ELSE
            IF STATUS = 100 THEN
               CALL pol0803_lote_carrega()
               IF NOT pol0803_insere_lote() THEN
                  RETURN FALSE
               END IF
            ELSE
               CALL log003_err_sql('SELECT','ESTOQUE_LOTE')
               RETURN FALSE
            END IF
        END IF
     END IF
     
     IF NOT pol0803_atu_estoque() THEN
        RETURN FALSE
     END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0803_ins_trans_rev()#
#-------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_cod_empresa,
           p_num_transac,
           p_num_transac_orig)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ESTOQUE_TRANS_REV') 
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0803_baixa_ender()#
#-----------------------------#

   IF p_qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_trans_ender
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_trans_ender
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote_ender')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol0803_baixa_est_lote()#
#--------------------------------#

   IF p_qtd_saldo > p_qtd_movto THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo - p_qtd_movto
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_trans_lote
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_trans_lote
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION pol0803_atu_ender()#
#---------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_trans_ender
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote_ender')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol0803_atu_lote()#
#--------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_trans_lote
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque_lote')
      RETURN FALSE
   END IF  
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol0803_atu_estoque()#
#-----------------------------#

   IF p_ies_situa = 'L' THEN
      UPDATE estoque SET qtd_liberada = qtd_liberada + p_qtd_atu
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
   ELSE
      UPDATE estoque SET qtd_lib_excep = qtd_lib_excep + p_qtd_atu
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = p_cod_item
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','estoque')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   


#-------FIM DO PROGRAMA BI---------#

