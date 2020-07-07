#------------------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO DO LOGIX x pw1                                          #
# PROGRAMA: pol1122                                                            #
# OBJETIVO: IMPORTAÇÃO DO apontamento do sistema pw1                           #
# DATA....: 13/12/2011                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#
 DATABASE logix

 GLOBALS

   DEFINE l_pct_ajus_qtd        DECIMAL(5,2),
          p_seq_refug           INTEGER,
          p_refugo              INTEGER,
          p_ja_processou        INTEGER,       
          p_msg                 char(300),
          p_aponta_parada       char(01),   
          p_chav_seq            LIKE apont_hist_pw912.chav_seq,
          l_pct_ajus_insumo     LIKE pct_ajust_man912.pct_ajus_insumo,
          p_aponta_eqpto_recur  LIKE pct_ajust_man912.aponta_eqpto_recur,
          p_aponta_ferramenta   LIKE pct_ajust_man912.aponta_ferramenta,
    		  p_finaliza            LIKE pct_ajust_man912.finaliza,
    		  p_aponta_refugo       LIKE pct_ajust_man912.aponta_refugo,
          l_qtd_apont_man       LIKE apo_oper.qtd_boas,
          p_ies_oper_final      LIKE ord_oper.ies_oper_final,
          p_texto               LIKE audit_logix.texto,
          p_qtd_plan_orig       LIKE ordens.qtd_planej,
          p_planej              LIKE ordens.qtd_planej,
          p_num_opg             LIKE ordens.num_ordem,
          p_qtd_baixar          LIKE ordens.qtd_planej,
          p_processando         LIKE proc_apont_man912.processando,
          p_ies_apontamento     LIKE ord_oper.ies_apontamento,
          l_qtd_apont_apo       LIKE apo_oper.qtd_boas,
          p_ies_ctr_estoque     LIKE item.ies_ctr_estoque,
          p_ies_sofre_baixa     LIKE item_man.ies_sofre_baixa,
          l_qtd_com_ajus        LIKE apo_oper.qtd_boas,
          p_qtd_aumento         LIKE ordens.qtd_planej,
          p_qtd_possivel        LIKE man_apont_454.qtd_refugo,
          p_qtd_tot_txt         LIKE man_apont_454.qtd_boas,
          p_qtd_transf          LIKE ordens.qtd_refug,
          p_cod_equip           LIKE maq_pw1_man912.cod_equip,
          p_pri_operac          LIKE ord_oper.cod_operac,
          p_cod_operac_ant      LIKE ord_oper.cod_operac,
          p_ult_operac          LIKE ord_oper.cod_operac,
          p_seq_oper_ant        LIKE ord_oper.num_seq_operac,
          p_ies_situa_dest      LIKE estoque_lote.ies_situa_qtd,
          p_ies_situa           LIKE ordens.ies_situa,
          p_qtd_horas           LIKE ord_oper.qtd_horas,
          p_saldo               LIKE estoque_lote.qtd_saldo,
          p_saldo_disp          LIKE estoque_lote.qtd_saldo,
          princ_cod_item        LIKE item.cod_item,
          princ_num_op          LIKE ordens.num_ordem,
          p_cod_local           LIKE item.cod_local_estoq,
          princ_cod_local       LIKE ordens.cod_local_estoq,
          princ_num_lote        LIKE ordens.num_lote,
          princ_saldo           LIKE estoque_lote.qtd_saldo,
          p_num_ord_prod        LIKE ordens.num_ordem,
          p_cod_prod            LIKE item.cod_item,
          p_hist_auto_op_enc    LIKE par_ega_logix_912.hist_auto_op_enc,
          p_compati_op_lote     LIKE par_ega_logix_912.compati_op_lote,
          p_ies_baixa_pc_rej    LIKE par_ega_logix_912.ies_baixa_pc_rej,
          p_cod_oper_bx_pc_rej  LIKE par_ega_logix_912.cod_oper_bx_pc_rej,          
          p_op_compati          LIKE ordens.num_ordem,
          p_hora_ini            LIKE proc_apont_man912.hor_ini,
          p_hor_atu             LIKE proc_apont_man912.hor_ini,
          p_tex_observ          LIKE estoque_obs.tex_observ,
          p_num_lote_refug      LIKE estoque_lote.num_lote,
          p_cod_local_refug     LIKE estoque_lote.cod_local,
          p_cod_item_refug      LIKE item.cod_item,
          p_time                DATETIME HOUR TO SECOND,
          p_hor_proces          CHAR(08),
          p_hor_dif             CHAR(10),
          p_qtd_segundo         INTEGER,
          l_parametro           CHAR(50),
          p_tip_peca            CHAR(01),
          p_qtd_opg             SMALLINT,
          p_hor_parada          CHAR(20),
          p_envia_hist          CHAR(01),
          p_mov_mat             CHAR(01),
          p_hor_ini             CHAR(2),
          sql_stmt              CHAR(400),
          p_qtd_ordem           SMALLINT,
          p_qtd_operac          SMALLINT,
          p_nom_prog            CHAR(7),
          p_estourou_qtd        SMALLINT,
          p_min_ini             CHAR(2),
          p_qtd_prod            INTEGER,
          p_qtd_prod_aux        INTEGER,
          p_seg_ini             CHAR(2),
          p_hor_fim             CHAR(2),
          p_min_fim             CHAR(2),
          p_deletado            CHAR(01),
          p_seg_fim             CHAR(2),
          p_qtd_seg_ini         INTEGER,
          p_qtd_seg_fim         INTEGER,
          p_insere_audit        SMALLINT,
          p_qtd_hor             DECIMAL(11,7),
          p_hor_min_ini         CHAR(05),
          p_hor_min_fim         CHAR(05),
          p_hor_comp_ini        CHAR(08),
          p_hor_comp_fim        CHAR(08),
          p_dat_producao        CHAR(10),
          p_qtd_nivel_aen       integer,
          l_qtd_boas            DEC(8,0),
          l_qtd_refugo          DEC(8,0)

     DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
            p_user                 LIKE usuario.nom_usuario,
            p_parametro            LIKE consumo.parametro,
            p_cod_fer_princ        LIKE consumo_fer.cod_ferramenta,
            p_cod_ferramenta       LIKE consumo_fer.cod_ferramenta,
            p_cod_item             LIKE item.cod_item,
            p_qtd_necessaria       LIKE ord_compon.qtd_necessaria,
            l_qtd_alter_qtd        LIKE apo_oper.qtd_boas,
            p_num_ordem            LIKE ordens.num_ordem,
            p_num_lote_op          LIKE ordens.num_lote,
            p_num_op               LIKE apont_pw1_man912.num_op,
            p_unidade              LIKE item.cod_unid_med,
            p_cod_maquina          LIKE recurso.cod_recur,
            p_num_lote             LIKE estoque_lote.num_lote,
            p_ies_situa_qtd        LIKE estoque_lote.ies_situa_qtd,
            p_qtd_saldo            LIKE estoque_lote.qtd_saldo,
            p_qtd_reservada        LIKE estoque_lote.qtd_saldo,
            p_tot_saldo            LIKE estoque_lote.qtd_saldo,
            p_novo_saldo           LIKE estoque_lote.qtd_saldo,
            p_cod_roteiro          LIKE ordens.cod_roteiro,
            p_num_altern_roteiro   LIKE ordens.num_altern_roteiro,
            p_cod_cent_trab_princ  LIKE consumo.cod_cent_trab,
            p_cod_cent_trab        LIKE consumo.cod_cent_trab,
            p_cod_arranjo          LIKE consumo.cod_arranjo,
            p_cod_uni_funcio       LIKE funcionario.cod_uni_funcio,
            p_saldo_princ          LIKE ordens.qtd_planej,
            p_qtd_planej           LIKE ordens.qtd_planej,
            p_qtd_boas             LIKE ordens.qtd_boas,
            p_qtd_refug            LIKE ordens.qtd_refug,
            p_qtd_sucata           LIKE ordens.qtd_sucata,
            p_cod_lin_prod         decimal(2,0),
	          p_cod_lin_recei        decimal(2,0),
	          p_cod_seg_merc         decimal(2,0),
	          p_cod_cla_uso          decimal(2,0),
            p_den_parada           CHAR(30)
            

   DEFINE l_qtd_necessaria  LIKE ord_compon.qtd_necessaria,
          l_nova_qtd_nec    LIKE ord_compon.qtd_necessaria,
          l_cod_item_compon LIKE ord_compon.cod_item_compon,
          p_qtd_difer       LIKE necessidades.qtd_necessaria
            

     DEFINE p_ies_impressao        CHAR(001),
            g_ies_ambiente         CHAR(001),
            p_nom_arquivo          CHAR(100),
            p_nom_arquivo_back     CHAR(100),
            p_nom_tela             CHAR(200),
            p_contador             SMALLINT,
            p_status               SMALLINT,
            p_retorno              SMALLINT,
            g_usa_visualizador     SMALLINT,
            p_sem_estoque          SMALLINT,
            p_rowid                INTEGER,
            p_chamada              CHAR(01),
            p_consiste             CHAR(01),
            p_qtd_op               SMALLINT
           

     DEFINE g_ies_grafico          SMALLINT
     DEFINE p_versao               CHAR(18) 

     DEFINE m_den_empresa          LIKE empresa.den_empresa,
            m_consulta_ativa       SMALLINT,
            m_esclusao_ativa       SMALLINT,
            comando                CHAR(080),
            m_comando              CHAR(080),
            p_caminho              CHAR(150),
            m_caminho              CHAR(150),
            p_last_row             SMALLINT,
            m_processa             SMALLINT,
            m_primeira_vez         SMALLINT, 
            m_arquivo_nf           CHAR(150),
            m_arquivo_ud           CHAR(150),
            m_msg                  CHAR(250),
            p_den_empresa          LIKE empresa.den_empresa,
            m_importou             SMALLINT,
            m_qtd_mvto_est         LIKE ord_oper.qtd_boas,
            l_qtd_tot_apont        LIKE apo_oper.qtd_boas,
            m_dat_ini_prod         DATE,
            m_dat_fim_prod         DATE,
            m_item                 CHAR(15),
            m_cod_maquina          CHAR(5),
            m_qtd_refugo           DECIMAL(10,3),
            m_qtd_boas             DECIMAL(10,3),
            m_tip_movto            CHAR(1),
            m_qtd_hor              DECIMAL(11,7),
            m_operador             CHAR(8),
            m_turno                CHAR(1),
            m_hor_inicial          CHAR(5),
            m_hor_fim              CHAR(5),
            m_refugo               CHAR(9),
            m_parada               CHAR(3),
            m_hor_ini_par          CHAR(5),
            m_hor_fim_par          CHAR(5),
            m_unid_func            CHAR(10),
            m_sucata               CHAR(10),
            m_cod_equip            CHAR(15),
            m_cod_ferram           CHAR(15),
            p_num_transac          INTEGER,
            p_cod_operacao         LIKE estoque_trans.cod_operacao,
            m_qtd_planej           LIKE ord_oper.qtd_boas,
            p_qtd_item             LIKE ord_oper.qtd_boas,
            m_cod_local_prod       LIKE ordens.cod_local_prod,
            m_cod_local_estoq      LIKE ordens.cod_local_estoq,
            m_contador             SMALLINT,
            mr_estoque_trans       RECORD LIKE estoque_trans.*,
            m_num_conta            LIKE estoque_operac_ct.num_conta_debito,
            m_num_transac_orig     INTEGER,
            mr_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
            mr_op_lote             RECORD LIKE op_lote.*,
            p_aponta               RECORD LIKE apont_pw1_man912.*,
            man_apont              RECORD LIKE man_apont_454.*,
            p_apont_hist_pw912    RECORD LIKE apont_hist_pw912.*,
            p_man_apont_hist_454   RECORD LIKE man_apont_hist_454.*,
            p_apont_proc_pw912     RECORD LIKE apont_pw1_man912.*,
            p_estoque_trans        RECORD LIKE estoque_trans.*,
            p_estoque_trans_end    RECORD LIKE estoque_trans_end.*,
            p_estoque_lote_ender   RECORD LIKE estoque_lote_ender.*

 END GLOBALS
            

MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol1122-10.02.02' 

   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT

   LET m_caminho = log140_procura_caminho('pol1122.iem')

   OPTIONS
       PREVIOUS KEY control-b,
       NEXT     KEY control-f,
       INSERT   KEY control-i,
       DELETE   KEY control-e,
       HELP    FILE m_caminho
      
   LET p_cod_empresa= '01'
   LET p_user       = 'admlog'     

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_caminho TO NULL 
   CALL log130_procura_caminho("pol1122") RETURNING m_caminho
   LET m_caminho = m_caminho CLIPPED 
   OPEN WINDOW w_pol1122 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF  p_status = 0 THEN
       CALL pol1122_controle()
   END IF

   CLOSE WINDOW w_pol1122
   
END MAIN

#--------------------------#
 FUNCTION pol1122_controle()
#--------------------------#
	DEFINE p_hora_atu            LIKE proc_apont_man912.hor_ini

   IF NUM_ARGS() > 0  THEN
      LET p_nom_prog = ARG_VAL(1)
   ELSE
      LET p_nom_prog = NULL
   END IF

   SELECT processando,
          hor_ini
     INTO p_processando,
          p_hora_ini
     FROM proc_apont_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      INSERT INTO proc_apont_man912 VALUES('S', CURRENT HOUR TO SECOND, p_cod_empresa)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERT","proc_apont_man912")
         RETURN 
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF p_processando = 'S' THEN
		    LET p_hor_atu = CURRENT HOUR TO SECOND
            IF p_hora_ini > p_hor_atu THEN
               LET p_hor_dif = '24:00:00' - (p_hora_ini - p_hor_atu)
            ELSE
               LET p_hor_dif = (p_hor_atu - p_hora_ini)
            END IF
            LET p_hor_proces = p_hor_dif[2,9]
            LET p_qtd_segundo = (p_hor_proces[1,2] * 3600) + 
                                (p_hor_proces[4,5] * 60)   + (p_hor_proces[7,8])
            IF p_qtd_segundo <= 3600 THEN
               RETURN
            END IF
         END IF
         
         UPDATE proc_apont_man912 
            SET processando = 'S',
                hor_ini = CURRENT YEAR TO SECOND
          WHERE cod_empresa = p_cod_empresa
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql("UPDATE","proc_apont_man912")
            RETURN 
         END IF
         
         SELECT processando
           INTO p_processando
           FROM proc_apont_man912
          WHERE cod_empresa = p_cod_empresa
         
         IF STATUS <> 0 OR p_processando <> 'S' THEN
            RETURN
         END IF
      ELSE
         CALL log003_err_sql("LEITURA","proc_apont_man912")
         RETURN 
      END IF
   END IF

   CALL pol1122_processa()

   IF p_nom_prog IS NULL THEN

      CALL log085_transacao("BEGIN")

      UPDATE proc_apont_man912 
         SET processando = 'N'
       WHERE cod_empresa = p_cod_empresa
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDATE","proc_apont_man912")
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END IF
   
END FUNCTION

#---------------------------#
FUNCTION pol1122_processa()
#---------------------------#

   IF NOT pol1122_cria_temp() THEN
      RETURN
   END IF
   
   CALL log085_transacao("BEGIN")

   IF NOT pol1122_elimina_duplicidade() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF
   
   CALL log085_transacao("COMMIT")
               
   
   INITIALIZE p_finaliza   TO NULL
   SELECT pct_ajus_insumo,
          aponta_eqpto_recur,
          aponta_ferramenta,
		      finaliza,
		      aponta_refugo,
		      qtd_nivel_aen,
		      aponta_parada
     INTO l_pct_ajus_insumo,
          p_aponta_eqpto_recur,
          p_aponta_ferramenta,
		      p_finaliza,
		      p_aponta_refugo,
		      p_qtd_nivel_aen,
		      p_aponta_parada
     FROM pct_ajust_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","pct_ajust_man912")
      RETURN 
   END IF

   SELECT hist_auto_op_enc,
          compati_op_lote,
          ies_baixa_pc_rej,
          cod_oper_bx_pc_rej
     INTO p_hist_auto_op_enc,
          p_compati_op_lote,
          p_ies_baixa_pc_rej,
          p_cod_oper_bx_pc_rej
     FROM par_pw1_logix_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET p_hist_auto_op_enc = 'N' #enviar p/ histórico OP encerradas
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","par_pw1_logix_912")
         RETURN 
      END IF
   END IF
    
   CALL log085_transacao("BEGIN")

   IF NOT pol1122_grava_historico() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN
   END IF

   IF NOT pol1122_monta_seq_oper() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN 
   END IF

   DELETE FROM man_apont_erro_454 WHERE empresa = p_cod_empresa
   DELETE FROM apont_erro_man912  WHERE empresa = p_cod_empresa

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","APONT_ERRO_MAN912")
      CALL log085_transacao("ROLLBACK")
      RETURN 
   END IF

   CALL log085_transacao("COMMIT")

   CALL log085_transacao("BEGIN")

   IF NOT pol1122_importa_dados() THEN  #Consiste e carrpw1 os apontamento para
      CALL log085_transacao("ROLLBACK") #a tabela man_apont_454
      RETURN
   END IF

   CALL log085_transacao("COMMIT")
   
   CALL pol1122_aponta()
   

END FUNCTION

#---------------------------#
FUNCTION pol1122_cria_temp()
#---------------------------#

   DROP TABLE apont_temp;

   CREATE TEMP TABLE apont_temp
   (
    dat_producao   char(8),
    cod_item       char(14),
    num_op         char(9),
    cod_operac     char(9),
    cod_maquina    char(3),
    qtd_refugo     char(8),
    qtd_boas       char(8),
    tip_mov        char(1),
    mat_operador   char(8),
    cod_turno      char(1),
    hor_ini        char(6),
    hor_fim        char(6),
    cod_mov        CHAR(5),
    num_seq_operac char(3),
    den_erro       char(75),
    chav_seq       integer,
    arq_orig       char(20),
    num_versao     decimal(5,0),
    cod_empresa    CHAR(02),
	status_operacao  char(01)

   );

   IF STATUS = -958 THEN
      DELETE FROM apont_temp
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELETE","apont_temp:delete")
         RETURN FALSE
      END IF
   ELSE
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CREATE","apont_temp:create")
         RETURN FALSE
      END IF
   END IF
 
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol1122_elimina_duplicidade()
#------------------------------------#

   LOCK TABLE apont_pw1_man912 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   INSERT INTO apont_temp
    SELECT DISTINCT *
      FROM apont_pw1_man912
     WHERE chav_seq IS NULL
       AND cod_empresa = p_cod_empresa

   IF STATUS = 0 THEN
   
      DELETE FROM apont_pw1_man912
            WHERE chav_seq IS NULL
              AND cod_empresa = p_cod_empresa
    
      IF STATUS = 0 THEN
      
         INSERT INTO apont_pw1_man912
          SELECT * FROM apont_temp
           WHERE cod_empresa = p_cod_empresa
           
         IF STATUS = 0 THEN
            RETURN TRUE
         END IF
         
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION
{
#-----------------------------#
FUNCTION pol1122_prende_tabs()
#-----------------------------#

   LOCK TABLE apont_pw1_man912 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   LOCK TABLE man_apont_454 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
}
#---------------------------------#
FUNCTION pol1122_grava_historico()
#---------------------------------#

   DISPLAY "Aguarde... limpando tabela man_apont_454 !!!" AT 10,15
   
   DELETE FROM man_apont_454
    WHERE empresa = p_cod_empresa
      AND LENGTH(dat_atualiz) > 0

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","MAN_APONT_454:D")
      RETURN FALSE
   END IF

   DISPLAY "Aguarde... gerando histórico !!!" AT 12,15

   SELECT MAX(chav_seq)
     INTO p_chav_seq
     FROM apont_hist_pw912
    WHERE cod_empresa = p_cod_empresa
   
   IF p_chav_seq IS NULL THEN
      LET p_chav_seq = 0
   END IF

   DECLARE cq_hist CURSOR FOR
    SELECT *, rowid
      FROM apont_pw1_man912
     WHERE (chav_seq IS NULL OR chav_seq = ' ')
       AND cod_empresa = p_cod_empresa
     ORDER BY dat_producao, hor_ini, num_op
     
   FOREACH cq_hist INTO p_aponta.*,p_rowid
      
      LET p_chav_seq = p_chav_seq + 1
	  
      #ivo - 20/09/2011 - pw1 não manda o item
      select cod_item
        into p_cod_item
        from ordens
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem  = p_aponta.num_op
         
      IF STATUS <> 0 THEN
         let p_cod_item = ''
      END IF #ivo - 20/09/2011 - até aqui
	  
	  IF    p_aponta.cod_turno  IS NULL   THEN        
	           LET p_aponta.cod_turno = '1'
	  END IF 	 
	  
      UPDATE apont_pw1_man912
         SET chav_seq   = p_chav_seq,
             num_versao = 1,
			 cod_item	= p_cod_item,        #ivo - 20/09/2011
             cod_turno  = p_aponta.cod_turno #Manuel - 20/10/2011
			 WHERE rowid = p_rowid
         AND cod_empresa = p_cod_empresa
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("UPDATE","APONT_pw1_MAN912")
         RETURN FALSE
      END IF
      
      INSERT INTO apont_hist_pw912
       VALUES(p_chav_seq,1,
              p_aponta.dat_producao,
              p_aponta.cod_item,
              p_aponta.num_op,
              p_aponta.cod_operac,
              p_aponta.cod_maquina,
              p_aponta.qtd_refugo,
              p_aponta.qtd_boas,
              p_aponta.tip_mov,
              p_aponta.mat_operador,
              p_aponta.cod_turno,
              p_aponta.hor_ini,
              p_aponta.hor_fim,
              p_aponta.cod_mov,
              p_aponta.arq_orig,
              NULL,"pol1122","pol1122",p_cod_empresa)

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","apont_hist_pw912")
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE
      
END FUNCTION
   

#--------------------------------#
FUNCTION pol1122_monta_seq_oper()
#--------------------------------#

   DEFINE p_num_op LIKE apont_pw1_man912.num_op,
          p_cod_op LIKE apont_pw1_man912.cod_operac,
          p_seq_op LIKE ord_oper.num_seq_operac

   DECLARE cq_sequenica CURSOR FOR
    SELECT DISTINCT 
           num_op,
           cod_operac
      FROM apont_pw1_man912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY num_op, cod_operac
     
   FOREACH cq_sequenica INTO
           p_num_op,
           p_cod_op

     
      INITIALIZE p_seq_op TO NULL
              
      DECLARE cq_ord CURSOR FOR
       SELECT num_seq_operac
         FROM ord_oper
        WHERE cod_empresa = p_cod_empresa
          AND num_ordem   = p_num_op
          AND cod_operac  = p_cod_op
       ORDER BY 1
      
      FOREACH cq_ord INTO p_seq_op
         EXIT FOREACH
      END FOREACH
      
      IF p_seq_op IS NULL THEN
         CONTINUE FOREACH
      END IF
      
      UPDATE apont_pw1_man912
         SET num_seq_operac = p_seq_op
       WHERE num_op     = p_num_op
         AND cod_operac = p_cod_op
         AND cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("UPDATE","apont_pw1_man912")
         RETURN FALSE
      END IF

	   UPDATE apont_pw1_man912
         SET cod_turno = '1'
       WHERE cod_turno is null
      

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("UPDATE","apont_pw1_man912 2")
         RETURN FALSE
      END IF
	  
	  
	  
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1122_importa_dados()
#--------------------------------#

   DISPLAY "Aguarde... consistindo dados !!!" AT 14,15
           
   LET p_contador = 0

   LET p_num_op = '000000000'
   LET p_op_compati = 0
   
   DELETE FROM apont_proc_pw912 WHERE cod_empresa = p_cod_empresa
   
   IF SQLCA.sqlcode <>  0   THEN 
      CALL log003_err_sql("LENDO","apont_proc_pw912")
      RETURN FALSE 
   END IF   
   
   DECLARE cq_importa CURSOR WITH HOLD FOR 
    SELECT    	dat_producao,
				cod_item,
				num_op,
				cod_operac,
				cod_maquina,
				qtd_refugo,
				qtd_boas,
				tip_mov,
				mat_operador,
				cod_turno,
				hor_ini,
				hor_fim,
				cod_mov,
				num_seq_operac,
				den_erro,
				chav_seq,
				arq_orig,
				num_versao,
				cod_empresa
      FROM apont_pw1_man912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY tip_mov, dat_producao, hor_ini, num_op, num_seq_operac
      
   FOREACH cq_importa INTO p_aponta.*

      CALL log085_transacao("COMMIT") 
      CALL log085_transacao("BEGIN")  
      LET p_tex_observ = NULL
	  
	    IF   p_aponta.num_op  = '000000000'   THEN 
			IF NOT pol1122_deleta_apont() THEN
				RETURN FALSE
			END IF
	        CONTINUE FOREACH
	    END IF 	 
	
		IF   p_aponta.cod_operac  =  '000000000'        THEN 
			IF NOT pol1122_deleta_apont() THEN
				RETURN FALSE
			END IF
			 CONTINUE FOREACH
	    END IF 	 
	
		IF   (p_aponta.qtd_refugo  = '00000000')   AND
			 (p_aponta.qtd_boas  = '00000000')     THEN 
			IF NOT pol1122_deleta_apont() THEN
				RETURN FALSE
			END IF
			 CONTINUE FOREACH
	    END IF 	 	
		
		 IF (p_aponta.tip_mov = '*') OR 
		    (p_aponta.tip_mov = 'P') THEN
			IF pol1122_consiste_parada() = FALSE THEN
				CALL pol1122_insere_erro()
				CONTINUE FOREACH
			END IF
		ELSE	
			IF  p_aponta.tip_mov  <> 'F'       THEN 
				IF NOT pol1122_deleta_apont() THEN
				RETURN FALSE
				END IF
				CONTINUE FOREACH
			END IF 	 
		END IF 	 
		
		
	    IF    p_aponta.cod_turno  is null    THEN        
	           LET p_aponta.cod_turno = '1'
	    END IF 	 
    
	    if p_qtd_nivel_aen > 0 then #filtra apontamento por area e linha
         
         select cod_lin_prod,
	              cod_lin_recei,
	              cod_seg_merc,
	              cod_cla_uso
	         into p_cod_lin_prod,
	              p_cod_lin_recei,
	              p_cod_seg_merc,
	              p_cod_cla_uso
	          from item
	         where cod_empresa = p_cod_empresa
	           and cod_item    = p_aponta.cod_item
	    
	       if status <> 0 then
            CALL log003_err_sql("LENDO","item")
            RETURN FALSE 
	       end if
	       
	       if p_qtd_nivel_aen < 4 then
	          let p_cod_cla_uso = 0
	       end if

	       if p_qtd_nivel_aen < 3 then
	          let p_cod_seg_merc = 0
	       end if

	       if p_qtd_nivel_aen < 2 then
	          let p_cod_lin_recei = 0
	       end if
	       
	       select cod_lin_prod
	         from aen_pw1_logix_912
	        where cod_lin_prod  = p_cod_lin_prod
	          and cod_lin_recei = p_cod_lin_recei
	          and cod_seg_merc  = p_cod_seg_merc
	          and cod_cla_uso   = p_cod_cla_uso
	       
	       if status = 100 then
            IF NOT pol1122_envia_hist() THEN
               RETURN FALSE
            END IF
	          CONTINUE FOREACH
	       else
	          if status <> 0 then
               CALL log003_err_sql("LENDO","item")
               RETURN FALSE 
	          end if      
	       end if
	       
	    end if
	    	    
      LET p_ja_processou  = 0 
      
      SELECT COUNT(*)
        INTO p_ja_processou
        FROM apont_proc_pw912
       WHERE    dat_producao    =  p_aponta.dat_producao 
         AND    cod_item        =  p_aponta.cod_item  
         AND    num_op          =  p_aponta.num_op 
         AND    cod_operac      =  p_aponta.cod_operac
         AND    qtd_refugo      =  p_aponta.qtd_refugo 
         AND    qtd_boas        =  p_aponta.qtd_boas 
         AND    tip_mov         =  p_aponta.tip_mov
         AND    hor_ini         =  p_aponta.hor_ini
         AND    hor_fim         =  p_aponta.hor_fim  
         AND    cod_mov         =  p_aponta.cod_mov
         AND    cod_empresa     =  p_cod_empresa

      IF SQLCA.sqlcode <>  0   THEN 
         CALL log003_err_sql("LENDO","apont_proc_pw912")
         RETURN FALSE 
      ELSE
         IF p_ja_processou > 0 THEN
            DELETE FROM apont_pw1_man912
             WHERE chav_seq = p_aponta.chav_seq
               AND cod_empresa = p_cod_empresa
             CONTINUE FOREACH
         END IF 
      END IF             
            
      INSERT INTO  apont_proc_pw912 VALUES (p_aponta.*)
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql("GRAVANDO","apont_proc_pw912")
         RETURN FALSE
      END IF          

	  LET p_num_ordem 			= p_aponta.num_op
	  LET l_qtd_refugo         	= p_aponta.qtd_refugo
 	  LET l_qtd_boas           	= p_aponta.qtd_boas   
      
    
      IF pol1122_consiste_ordem() = FALSE THEN
         IF p_envia_hist = 'S' THEN
            IF NOT pol1122_envia_hist() THEN
               RETURN FALSE
            END IF
         END IF
         CONTINUE FOREACH
      END IF

      LET p_num_ordem = p_aponta.num_op
   #   DISPLAY 'Ordem: ', p_num_ordem AT 12,20

      SELECT COUNT(ordem_producao)
        INTO p_qtd_ordem
        FROM apont_erro_man912
       WHERE empresa        = p_cod_empresa
         AND ordem_producao = p_aponta.num_op

      IF p_qtd_ordem > 0 THEN
         LET m_msg = 'INCONSISTIDO POR CONSEQUENCIA DE ERRO ANTERIOR - pol1122'
         CALL pol1122_insere_erro()
         CONTINUE FOREACH
      END IF      

      IF p_aponta.num_seq_operac IS NULL THEN
         LET m_msg = 'OPERACAO SEM NUMERO DE SEQUENCIA - pol1122'
         CALL pol1122_insere_erro()
         CONTINUE FOREACH
      END IF      

      #ivo - 20/09/2011 - pw1 só mada fabricação
      IF  (p_aponta.tip_mov <> 'F') 
	  AND (p_aponta.tip_mov <> '*')  
	  AND (p_aponta.tip_mov <> 'P') THEN
          LET m_msg = 'TIPO DE MOVIMENTO INVÁLIDO - pol1122: ', p_aponta.tip_mov
          CALL pol1122_insere_erro()
          CONTINUE FOREACH
      END IF 
      
      IF p_aponta.tip_mov = 'P' THEN
         IF p_aponta.hor_ini = p_aponta.hor_fim THEN
            IF p_aponta.cod_mov <> '01120' THEN
               IF NOT pol1122_deleta_apont() THEN
                  RETURN FALSE
               END IF
               CONTINUE FOREACH
            END IF
         END IF
      END IF   

	  
      IF pol1122_consiste_operacao() = FALSE THEN
         CALL pol1122_insere_erro()
         CONTINUE FOREACH
      END IF

      LET p_contador = p_contador + 1
      INITIALIZE man_apont.* TO NULL

      CALL pol1122_consiste_dados() RETURNING p_status
      
      IF NOT p_status THEN 
         CONTINUE FOREACH
      END IF
      
	  IF p_aponta.tip_mov = "P" THEN
         LET p_qtd_prod = 0
         LET man_apont.qtd_refugo = 0
         LET man_apont.qtd_boas = 0
      ELSE
		LET man_apont.qtd_refugo = l_qtd_refugo
		LET man_apont.qtd_boas   = l_qtd_boas  
		LET p_qtd_prod           = man_apont.qtd_boas
	  END IF 	
  
      LET p_qtd_prod_aux = p_qtd_prod
      
      LET p_tex_observ = NULL

      IF NOT pol1122_le_qtd_planej() THEN
         LET m_msg = 'ERRO AO LER A QTD.PLANEJADA DA ORDEM - pol1122'
         CALL pol1122_insere_erro()
         CONTINUE FOREACH
      END IF

      CALL pol1122_calc_dat_hor()
            
      LET p_qtd_hor = (p_qtd_seg_fim - p_qtd_seg_ini) / 3600
      
      LET man_apont.empresa = p_cod_empresa

      LET man_apont.dat_ini_producao = p_dat_producao
      LET man_apont.dat_fim_producao = man_apont.dat_ini_producao
      LET man_apont.item = p_aponta.cod_item
      LET man_apont.ordem_producao = p_aponta.num_op
      LET man_apont.sequencia_operacao = p_aponta.num_seq_operac
      LET man_apont.operacao = p_aponta.cod_operac
      LET man_apont.arranjo = p_cod_arranjo
      IF p_aponta_eqpto_recur = 'S' THEN
         LET man_apont.eqpto = p_cod_equip
      ELSE
         LET man_apont.eqpto = NULL
      END IF
      LET man_apont.unid_funcional = p_cod_uni_funcio
      LET man_apont.centro_trabalho = p_cod_cent_trab
      LET man_apont.ferramenta = p_cod_ferramenta
      LET man_apont.tip_movto = "N"
      LET man_apont.local  = m_cod_local_prod 
      LET man_apont.qtd_hor = p_qtd_hor
      LET man_apont.matricula = p_aponta.mat_operador
      LET man_apont.sit_apont = 1
      LET man_apont.turno = p_aponta.cod_turno
      LET man_apont.dat_atualiz = ' '
	  IF  p_aponta.status_operacao = '2' AND
	        p_finaliza       = 'S' THEN
            LET man_apont.terminado = 'S'
      END IF

      IF p_aponta.tip_mov = "P" THEN
         LET man_apont.hor_ini_parada = p_hor_comp_ini 
         LET man_apont.hor_fim_parada = p_hor_comp_fim 
         LET man_apont.parada = p_aponta.cod_mov
         LET p_chamada = 'P'
         IF NOT pol1122_grava_man() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      ELSE
         LET man_apont.hor_inicial = p_hor_comp_ini
         LET man_apont.hor_fim = p_hor_comp_fim
      END IF
      
      SELECT ies_oper_final
        INTO p_ies_oper_final
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
         AND num_ordem      = man_apont.ordem_producao
         AND cod_operac     = man_apont.operacao
         AND num_seq_operac = p_aponta.num_seq_operac
      
      let p_qtd_prod = l_qtd_refugo
      
      IF p_ies_oper_final = 'S' THEN
         IF p_aponta.tip_mov = 'F' THEN
            let p_qtd_prod = p_qtd_prod + l_qtd_boas
         END IF
      END IF

      LET p_chamada = 'P'

      if p_qtd_prod > 0 then
         IF NOT pol1122_tem_material() THEN     
            CALL pol1122_insere_erro()
            CONTINUE FOREACH
         END IF
      end if
        
      IF NOT pol1122_grava_man() THEN
         RETURN FALSE
      END IF

 
   END FOREACH  
    
   RETURN TRUE

END FUNCTION
#------------------------------#
FUNCTION pol1122_consiste_parada()
#------------------------------#
   SELECT des_parada
     INTO p_den_parada
     FROM cfp_para
    WHERE cod_empresa = p_cod_empresa
      AND cod_parada  = p_aponta.cod_mov
	  
   IF SQLCA.sqlcode <> 0  THEN
         LET m_msg = 'COD. MOVTO:', p_aponta.cod_mov,
                  ' NÃO CADASTRADO - RODE POL0453'
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION
#------------------------------#
FUNCTION pol1122_tem_material()
#------------------------------#

   DEFINE p_local_baixa LIKE ord_compon.cod_local_baixa

   DECLARE cq_comp CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = man_apont.ordem_producao

   FOREACH cq_comp INTO 
           p_cod_item,
           p_qtd_necessaria,
           p_local_baixa
      
      SELECT a.ies_ctr_estoque,
             b.ies_sofre_baixa
        INTO p_ies_ctr_estoque,
             p_ies_sofre_baixa
        FROM item a,
             item_man b
       WHERE a.cod_empresa = p_cod_empresa
         AND a.cod_item    = p_cod_item
         AND b.cod_empresa = a.cod_empresa
         AND b.cod_item    = a.cod_item
         
      IF p_ies_ctr_estoque = 'N' OR p_ies_sofre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      LET p_qtd_baixar = p_qtd_prod * p_qtd_necessaria
      
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_local_baixa
         AND ies_situa_qtd = "L"

      IF p_qtd_saldo IS NULL OR p_qtd_saldo = 0 THEN
         LET m_msg = 'COMP.',p_cod_item,' SEM MATERIAL SUF LOC PROD-pol1122'
         RETURN FALSE
      END IF
      
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_apont

      IF p_qtd_saldo < p_qtd_baixar THEN
         LET m_msg = 'COMP.',p_cod_item,' S/MATERIAL SUF LOC PROD-pol1122'
         RETURN FALSE
      END IF
           
   END FOREACH
      
   RETURN TRUE
   
END FUNCTION


#------------------------------#
FUNCTION pol1122_calc_dat_hor()
#------------------------------#

      LET p_hor_ini = p_aponta.hor_ini[1,2]
      LET p_min_ini = p_aponta.hor_ini[3,4]
      LET p_seg_ini = p_aponta.hor_ini[5,6]
      LET p_hor_fim = p_aponta.hor_fim[1,2]
      LET p_min_fim = p_aponta.hor_fim[3,4]
      LET p_seg_fim = p_aponta.hor_fim[5,6]

      LET p_qtd_seg_ini = (p_hor_ini * 3600)+(p_min_ini * 60)+(p_seg_ini)
      LET p_qtd_seg_fim = (p_hor_fim * 3600)+(p_min_fim * 60)+(p_seg_fim)


      LET p_hor_min_ini = p_hor_ini,':',p_min_ini
      LET p_hor_min_fim = p_hor_fim,':',p_min_fim
      LET p_hor_comp_ini = p_hor_ini,':',p_min_ini,':',p_seg_ini
      LET p_hor_comp_fim = p_hor_fim,':',p_min_fim,':',p_seg_fim

      LET p_dat_producao = p_aponta.dat_producao[1,2],"/",
                           p_aponta.dat_producao[3,4],"/",
                           p_aponta.dat_producao[5,8]

END FUNCTION

#----------------------------------#
FUNCTION pol1122_calcula_apontadas()
#----------------------------------#

   DEFINE p_qtd_pecas LIKE apo_oper.qtd_boas
   
      SELECT SUM(qtd_boas + qtd_refugo)
        INTO l_qtd_apont_apo
        FROM apo_oper
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_aponta.num_op
         AND cod_operac  = p_aponta.cod_operac

      IF l_qtd_apont_apo IS NULL THEN
         LET l_qtd_apont_apo = 0
      END IF

      SELECT SUM(qtd_boas + qtd_refugo)
        INTO l_qtd_apont_man
        FROM man_apont_454
       WHERE empresa        = p_cod_empresa
         AND ordem_producao = p_aponta.num_op
         AND operacao       = p_aponta.od_operac
         AND sit_apont      = 1
         AND (dat_atualiz IS NULL OR dat_atualiz = ' ')

      IF l_qtd_apont_man IS NULL THEN
         LET l_qtd_apont_man = 0
      END IF

      LET p_qtd_pecas = l_qtd_apont_apo + l_qtd_apont_man
      
   RETURN p_qtd_pecas
   
END FUNCTION

#---------------------------------#
FUNCTION pol1122_le_qtd_planej()
#---------------------------------#

   SELECT qtd_planej
     INTO m_qtd_planej
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_aponta.num_op

   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

   #ivo - 20/09/2011 - Polimetri não usa op_lote
{
#--------------------------------#
FUNCTION pol1122_compatibiliza_op()
#--------------------------------#

   DEFINE p_cod_compon      LIKE item.cod_item,
          p_cod_local_baixa LIKE op_lote.cod_local_baixa,
          p_num_lote        LIKE op_lote.num_lote,
          p_endereco_op     LIKE op_lote.endereco,
          p_endereco        LIKE estoque_lote_ender.endereco
          
   DEFINE p_rowid           INTEGER
   
   LET p_sem_estoque = FALSE
   
   DECLARE cq_cmpon CURSOR FOR
    SELECT cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_op_compati

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("LENDO","ord_compon")
      RETURN FALSE
   END IF
       
   FOREACH cq_cmpon INTO p_cod_compon
   
      DECLARE cq_opl CURSOR FOR
       SELECT cod_local_baixa,
              num_lote,
              endereco,
              rowid
         FROM op_lote
        WHERE cod_empresa     = p_cod_empresa
          AND num_ordem       = p_op_compati
          AND cod_item_compon = p_cod_compon
          AND qtd_transf      > qtd_cons

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("LENDO","op_lote")
         RETURN FALSE
      END IF
   
      FOREACH cq_opl INTO 
              p_cod_local_baixa,
              p_num_lote,
              p_endereco_op,
              p_rowid
         
         IF p_num_lote IS NOT NULL THEN
            SELECT qtd_saldo
              FROM estoque_lote_ender
             WHERE cod_empresa   = p_cod_empresa
               AND cod_item      = p_cod_compon
               AND num_lote      = p_num_lote
               AND cod_local     = p_cod_local_baixa
               AND ies_situa_qtd = 'L'
               AND endereco      = p_endereco_op
               AND qtd_saldo     > 0
         ELSE
            SELECT qtd_saldo
              FROM estoque_lote_ender
             WHERE cod_empresa   = p_cod_empresa
               AND cod_item      = p_cod_compon
               AND cod_local     = p_cod_local_baixa
               AND ies_situa_qtd = 'L'
               AND endereco      = p_endereco_op
               AND qtd_saldo     > 0
               AND num_lote      IS NULL
         END IF

         IF STATUS = 0 THEN
            CONTINUE FOREACH
         END IF
         
         IF sqlca.sqlcode <> 100 THEN
            CALL log003_err_sql("LENDO","estoque_lote_ender")
            RETURN FALSE
         END IF
         
         LET p_endereco = NULL
         
         IF p_num_lote IS NOT NULL THEN
            DECLARE cq_cur_1 CURSOR FOR
            SELECT endereco
              FROM estoque_lote_ender
             WHERE cod_empresa   = p_cod_empresa
               AND cod_item      = p_cod_compon
               AND num_lote      = p_num_lote
               AND cod_local     = p_cod_local_baixa
               AND ies_situa_qtd = 'L'
               AND qtd_saldo     > 0
            FOREACH cq_cur_1 INTO p_endereco
               EXIT FOREACH
            END FOREACH
         ELSE
            DECLARE cq_cur_2 CURSOR FOR
            SELECT endereco
              INTO p_endereco
              FROM estoque_lote_ender
             WHERE cod_empresa   = p_cod_empresa
               AND cod_item      = p_cod_compon
               AND cod_local     = p_cod_local_baixa
               AND ies_situa_qtd = 'L'
               AND qtd_saldo     > 0
               AND num_lote      IS NULL
            FOREACH cq_cur_2 INTO p_endereco
               EXIT FOREACH
            END FOREACH
         END IF

         IF p_endereco IS NOT NULL THEN
            UPDATE op_lote
               SET endereco = p_endereco
             WHERE rowid = p_rowid
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("UPDATE","OP_LOTE")
               RETURN FALSE
            END IF
         ELSE
            LET m_msg = 'ITEM:',p_cod_compon,' SEM MATERIAL NO LOCAL DA DA BAIXA'
            LET p_sem_estoque = TRUE
            LET p_num_ordem = p_op_compati
            RETURN FALSE
         END IF
           
      END FOREACH
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
}#ivo - 20/09/2011 - até aqui#

#----------------------------#
FUNCTION pol1122_envia_hist()
#----------------------------#

   INSERT INTO man_apont_hist_454
      VALUES(p_cod_empresa,
             p_aponta.dat_producao,
             p_aponta.dat_producao,
             p_aponta.cod_item,
             p_aponta.num_op,
             p_aponta.num_seq_operac,
             p_aponta.cod_operac,
             ' ',
             ' ',
             p_aponta.qtd_refugo,
             p_aponta.qtd_boas,
             p_aponta.tip_mov,
             '',
             '',
             p_aponta.mat_operador,
             '',
             p_aponta.cod_turno,
             p_aponta.hor_ini,
             p_aponta.hor_fim,
             '','','','','','','','','','','D',
             p_user,
             'pol1122')
             
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","MAN_APONT_HIST_454")
      RETURN FALSE
   END IF

   IF NOT pol1122_deleta_apont() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#----------------------------#
 FUNCTION pol1122_grava_man()
#----------------------------#

   INSERT INTO man_apont_454 VALUES (man_apont.*)
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","MAN_APONT_454:I")
      RETURN FALSE
   END IF
   
   SELECT MAX(rowid)
     INTO man_apont.refugo
     FROM man_apont_454
    WHERE empresa = p_cod_empresa
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("LENDO","MAN_APONT_454:L")
      RETURN FALSE
   END IF
   
   INSERT INTO man_apont_hist_454
    VALUES(man_apont.*,'I','pol1122', 'pol1122')

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("INSERINDO","MAN_APONT_HIST_454")
      RETURN FALSE
   END IF
   
   IF p_chamada <> 'G' THEN
      IF NOT pol1122_atualiza_tabs() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1122_deleta_apont()
#-----------------------------#

   DELETE FROM apont_pw1_man912
    WHERE chav_seq = p_aponta.chav_seq
      AND cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DELECAO',"APONT_pw1_MAN912")
      RETURN FALSE
   END IF

   UPDATE apont_hist_pw912
      SET situacao = "D"
    WHERE chav_seq   = p_aponta.chav_seq
      AND num_versao = p_aponta.num_versao
      AND cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('UPDATE',"apont_hist_pw912")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1122_atualiza_tabs()
#------------------------------#

   DEFINE p_dif      INTEGER,
          p_qtd_boas CHAR(8),
          p_men      CHAR(7)
          

      LET p_men = 'DELEÇÃO'

      DELETE FROM apont_pw1_man912
       WHERE chav_seq = p_aponta.chav_seq
         AND cod_empresa = p_cod_empresa

      IF STATUS = 0 THEN

         UPDATE apont_hist_pw912
            SET situacao = "A"
          WHERE chav_seq   = p_aponta.chav_seq
            AND num_versao = p_aponta.num_versao
            AND cod_empresa = p_cod_empresa

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('UPDATE',"apont_hist_pw912")
            RETURN FALSE
         END IF

      END IF


   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql(p_men,"APONT_pw1_MAN912")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
 FUNCTION pol1122_consiste_dados()
#--------------------------------#
      
      LET p_retorno = TRUE
      
      IF pol1122_consiste_item() = FALSE THEN
         CALL pol1122_insere_erro()
         LET p_retorno = FALSE
      END IF
      
	  IF p_aponta_ferramenta   = 'S'   THEN
		IF pol1122_consiste_maquina() = FALSE THEN
			CALL pol1122_insere_erro()
			LET p_retorno = FALSE
		END IF
	  END IF
      
      IF pol1122_consiste_matricula() = FALSE THEN
         CALL pol1122_insere_erro()
         LET p_retorno = FALSE
      END IF

	  IF p_aponta.tip_mov = "P" THEN 
         IF pol1122_consiste_movto() = FALSE THEN
            CALL pol0456_insere_erro()
            LET p_retorno = FALSE
         END IF
      END IF
	  
	  
      RETURN (p_retorno)
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol1122_consiste_operacao()
#-----------------------------------#

   SELECT cod_empresa
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac  = p_aponta.cod_operac
      
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'OPERACAO ',p_aponta.cod_operac CLIPPED, 
                  ' NÃO CADASTRADA NA TAB OPERACAO - pol1122'
      RETURN FALSE
   END IF
   
   DECLARE cq_pri_oper CURSOR FOR
    SELECT cod_operac
      FROM ord_oper
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_aponta.num_op
     ORDER BY num_seq_operac
   
   FOREACH cq_pri_oper INTO p_pri_operac
      EXIT FOREACH
   END FOREACH

   SELECT cod_operac
     INTO p_ult_operac
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
      AND num_ordem      = p_aponta.num_op
      AND ies_oper_final = 'S'
      
   IF STATUS <> 0 THEN
      LET m_msg = 'OPERACAO FINAL NÃO CADASTRADA - ORD_OPER - pol1122'
      RETURN FALSE
   END IF

   LET p_ies_apontamento = 'F'
   
   SELECT COUNT(cod_operac)
     INTO p_qtd_operac
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
      AND num_ordem      = p_aponta.num_op

   IF p_qtd_operac > 1 AND p_aponta.cod_operac <> p_pri_operac THEN
      DECLARE cd_op_ante CURSOR FOR
       SELECT ies_apontamento
         FROM ord_oper
        WHERE cod_empresa    = p_cod_empresa
          AND num_ordem      = p_aponta.num_op
          AND num_seq_operac < p_aponta.num_seq_operac
        ORDER BY 1 DESC
      
      FOREACH cd_op_ante INTO p_ies_apontamento
         EXIT FOREACH
      END FOREACH
   END IF
   
   IF p_aponta.status_operacao= '2' AND
      p_finaliza       = 'S' THEN
      IF p_ies_apontamento <> 'F' THEN
         LET m_msg = 'TENTATIVA DE ENCERRAR OPER S/ ENCERRAR OPER ANT - pol1122'
         RETURN FALSE
      END IF
   END IF 
      
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol1122_consiste_ordem()
#--------------------------------#

   LET p_envia_hist = 'N'

   SELECT cod_local_prod,
          cod_local_estoq,
          cod_roteiro, 
          num_altern_roteiro,
          num_lote,
          ies_situa
     INTO m_cod_local_prod,
          m_cod_local_estoq,
          p_cod_roteiro, 
          p_num_altern_roteiro,
          p_num_lote_op, 
          p_ies_situa
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_aponta.num_op

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ORDEM DE PRODUÇÃO NÃO EXISTE - pol1122'
      CALL pol1122_insere_erro()
      RETURN FALSE
   END IF
   
   IF p_ies_situa = '4' THEN
   ELSE
      IF p_ies_situa MATCHES '[59]' THEN
         IF p_hist_auto_op_enc = 'S' THEN
            LET p_envia_hist = 'S'
         END IF
      END IF
      IF p_envia_hist = 'N' THEN
         LET m_msg = 'ORDEM DE PRODUÇÃO NÃO ESTA EM PRODUCAO - pol1122'
         CALL pol1122_insere_erro()
      END IF
      RETURN FALSE
   END IF
         
   INITIALIZE p_cod_ferramenta, p_cod_cent_trab, p_parametro TO NULL
   
   SELECT cod_cent_trab,
          cod_arranjo
     INTO p_cod_cent_trab,
          p_cod_arranjo
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
      AND num_ordem      = p_aponta.num_op
      AND cod_operac     = p_aponta.cod_operac
      AND num_seq_operac = p_aponta.num_seq_operac
   
   IF LENGTH(p_cod_cent_trab) = 0 THEN
      LET m_msg = 'CENTRO DE TRABALHO INVALIDO NA ORD_OPER NA OP ', p_aponta.num_op, ' - pol1122'
      CALL pol1122_insere_erro()
      RETURN FALSE
   END IF
      
   IF LENGTH(p_cod_arranjo) = 0 or p_cod_arranjo = ' ' THEN
      LET m_msg = 'ARRANJO INVALIDO NA ORD_OPER - pol1122'
      CALL pol1122_insere_erro()
      RETURN FALSE
   END IF
 
 
    IF p_aponta.cod_maquina  IS  NULL THEN 
		let p_cod_maquina = ' '
  
		DECLARE cq_recur CURSOR FOR
			SELECT cod_recur
			FROM rec_arranjo
			WHERE cod_empresa = p_cod_empresa
			AND cod_arranjo = p_cod_arranjo
         
		FOREACH cq_recur INTO p_cod_maquina
         
			SELECT ies_tip_recur
				FROM recurso
			WHERE cod_empresa = p_cod_empresa
				AND cod_recur = p_cod_maquina
				AND ies_tip_recur = '2'

			IF STATUS = 0 THEN
				EXIT FOREACH
			END IF 
        
		END FOREACH
   		LET p_aponta.cod_maquina = p_cod_maquina
	END IF
     
   DECLARE cq_consumo CURSOR FOR
   SELECT parametro
     FROM consumo
    WHERE cod_empresa        = p_cod_empresa
      AND cod_item           = p_aponta.cod_item
      AND cod_roteiro        = p_cod_roteiro
      AND num_altern_roteiro = p_num_altern_roteiro
      AND cod_operac         = p_aponta.cod_operac
      
   FOREACH cq_consumo INTO p_parametro

      DECLARE cq_fer CURSOR FOR
       SELECT cod_ferramenta
         FROM consumo_fer
        WHERE cod_empresa  = p_cod_empresa
          AND num_processo = p_parametro
          AND cod_ferramenta LIKE "%PL%"

      FOREACH cq_fer INTO p_cod_ferramenta
         EXIT FOREACH
      END FOREACH

      EXIT FOREACH

   END FOREACH 

   IF p_aponta_ferramenta <> 'S' THEN
      INITIALIZE p_cod_ferramenta TO NULL
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1122_consiste_item()
#-------------------------------#
   
   SELECT cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_aponta.cod_item
      
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ITEM: ', p_aponta.cod_item, ' NÃO CADASTRADO - pol1122'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION


#----------------------------------#
 FUNCTION pol1122_consiste_maquina()
#----------------------------------#
  
  INITIALIZE p_cod_equip TO NULL

  SELECT cod_equip
     INTO p_cod_equip
     FROM maq_pw1_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_maquina = p_aponta.cod_maquina

   
   IF SQLCA.sqlcode = NOTFOUND THEN
	  IF p_aponta_eqpto_recur = 'S'  THEN 
	     LET m_msg = 'EQUIPAMENTO:',p_aponta.cod_maquina,' NÃO CADASTRADA NO PROGRAMA POL1123 - pol1122'
         RETURN FALSE
	  END IF
   ELSE
		IF sqlca.sqlcode <> 0 THEN
			LET m_msg = 'MAQUINA:',p_aponta.cod_maquina,
						' NÃO CADASTRADA - MAQ_PW1_MAN912 - POL1122'
			RETURN FALSE
		END IF
   END IF
   
  { SELECT cod_recur
     FROM recurso
    WHERE cod_empresa   = p_cod_empresa
      AND cod_recur     = p_aponta.cod_maquina
      AND ies_tip_recur = '2'
      
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'MAQUINA:',p_aponta.cod_maquina,' NÃO CADASTRADA - RECURSO - pol1122'
      RETURN FALSE
   END IF}

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol1122_consiste_matricula()
#------------------------------------#
   
   DEFINE p_mat_operador LIKE apont_pw1_man912.mat_operador
   
   INITIALIZE p_cod_uni_funcio TO NULL
   
   SELECT cod_uni_funcio
     INTO p_cod_uni_funcio
     FROM funcionario
    WHERE cod_empresa   = p_cod_empresa
      AND num_matricula = p_aponta.mat_operador
      
   IF sqlca.sqlcode <> 0 or p_aponta.mat_operador is null or p_aponta.mat_operador = ' ' THEN #ivo - 20/09/2011
      
      SELECT operador_padrao
        INTO p_mat_operador
        FROM operad_pad_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_turno   = p_aponta.cod_turno
      
      IF STATUS <> 0 THEN
         LET m_msg = 'MATRIC.OPERADOR:', p_aponta.mat_operador,
                     ' NÃO CADASTRADA - FUNCIONARIO - pol1122'
         RETURN FALSE
      ELSE
         LET p_aponta.mat_operador = p_mat_operador
         SELECT cod_uni_funcio
           INTO p_cod_uni_funcio
           FROM funcionario
          WHERE cod_empresa   = p_cod_empresa
            AND num_matricula = p_aponta.mat_operador
            
         IF STATUS <> 0 THEN
            LET m_msg = 'OPERADOR PADRAO:', p_aponta.mat_operador,
                        ' NÃO CADASTRADO - FUNCIONARIO - pol1122'
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE

END FUNCTION



#-----------------------------#
 FUNCTION pol1122_insere_erro()
#-----------------------------#

     INSERT INTO apont_erro_man912
      VALUES (p_cod_empresa,
              p_num_ordem,
              p_aponta.cod_operac,
              p_aponta.num_seq_operac,
              m_msg)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","man_apont_erro_454")
   END IF                                           

   UPDATE apont_pw1_man912
      SET den_erro = m_msg
    WHERE chav_seq = p_aponta.chav_seq
      AND cod_empresa = p_cod_empresa
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","APONT_ERRO_MAN912")
   END IF                                           

   UPDATE apont_hist_pw912
      SET situacao = 'C'
    WHERE chav_seq   = p_aponta.chav_seq
      AND num_versao = p_aponta.num_versao
      AND cod_empresa = p_cod_empresa
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","apont_hist_pw912")
   END IF                                           

   INITIALIZE m_msg TO NULL
   
END FUNCTION
            
#--------------------------------------#
FUNCTION pol1122_ajusta_necessidades()
#--------------------------------------#

   DEFINE p_qtd_compon      LIKE ord_compon.qtd_necessaria
          
   ## veifica se tem estoque p/ o(s) componente(s)

   DECLARE cq_comp_neces CURSOR FOR
    SELECT qtd_necessaria, 
           cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem

   FOREACH cq_comp_neces INTO 
           p_qtd_compon,
           l_cod_item_compon

      LET p_qtd_difer    = p_qtd_aumento * p_qtd_compon

      SELECT cod_local_estoq
        INTO m_cod_local_estoq
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item_compon

       SELECT SUM(qtd_saldo)
         INTO p_qtd_saldo
         FROM estoque_lote
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = l_cod_item_compon
          AND cod_local   = m_cod_local_estoq
          AND ies_situa_qtd = "L"

       SELECT SUM(qtd_reservada - qtd_atendida)
         INTO p_qtd_reservada
         FROM estoque_loc_reser
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = l_cod_item_compon
          AND cod_local   = m_cod_local_estoq
          AND ies_origem  = 'V'
      
       IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
          LET p_qtd_reservada = 0
       END IF
       
       IF p_qtd_saldo > p_qtd_reservada THEN
          LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
       ELSE
          LET p_qtd_saldo = 0
       END IF

      IF p_qtd_saldo < p_qtd_difer THEN
         LET m_msg = 'ITEM:', l_cod_item_compon CLIPPED, 
                     ' S/ ESTOQ  P/ DESLOCAR - pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
      
   END FOREACH
         
   LET p_sem_estoque = FALSE 
   
   ## altera qtd. planejada
   
   SELECT qtd_planej
     INTO p_planej
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem
     
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORDENS - pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
   
   LET p_texto = 'OP: ',p_num_ordem
   LET p_texto = p_texto CLIPPED, ' QTD. PLANEJ ALTERADA DE: ', p_planej
   
   LET p_planej = p_planej + p_qtd_aumento

   LET p_texto = p_texto CLIPPED, ' PARA', p_planej
   
   UPDATE ordens
      SET qtd_planej  = p_planej
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_num_ordem

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORDENS- pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   INSERT INTO audit_logix
    VALUES(p_cod_empresa, 
           p_texto, 
           'pol1122', 
           TODAY, 
           CURRENT HOUR TO SECOND, 
           p_user)
    
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' INSERINDO NA AUDIT_LOGIX - pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
           
   UPDATE ord_oper
      SET qtd_planejada = p_planej
    WHERE cod_empresa   = p_cod_empresa
      AND num_ordem     = p_num_ordem

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORD_OPER- pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
      
   ## desloca material

    SELECT qtd_necessaria, 
           cod_item_compon
      FROM ord_compon
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_num_ordem

   FOREACH cq_comp_neces INTO 
           p_qtd_compon,
           l_cod_item_compon

      LET p_qtd_difer = p_qtd_aumento * p_qtd_compon

      SELECT cod_local_estoq
        INTO m_cod_local_estoq
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item_compon
      
      LET p_mov_mat = 'M'

      IF NOT pol1122_movimenta_estoque() THEN
         RETURN FALSE
      END IF
      
      UPDATE necessidades
         SET qtd_necessaria  = qtd_necessaria + p_qtd_difer
       WHERE cod_empresa     = p_cod_empresa
         AND num_ordem       = p_num_ordem
         AND cod_item        = l_cod_item_compon
           
      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA NECECIDADES- pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

   END FOREACH
    
   RETURN TRUE


END FUNCTION


#-----------------------------------#
 FUNCTION pol1122_movimenta_estoque()
#-----------------------------------#

   LET p_tot_saldo = 0
   LET p_status = FALSE
   LET p_ies_situa_qtd  = 'L'
   LET p_ies_situa_dest = p_ies_situa_qtd

   DECLARE cq_lot CURSOR WITH HOLD FOR
    SELECT num_lote, 
           qtd_saldo
      FROM estoque_lote
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = l_cod_item_compon
       AND cod_local     = m_cod_local_estoq
       AND ies_situa_qtd = "L"
       AND qtd_saldo     > 0

   FOREACH cq_lot INTO 
           p_num_lote, 
           p_qtd_saldo

      LET p_novo_saldo = p_qtd_saldo

      IF p_num_lote IS NOT NULL THEN
         SELECT SUM(qtd_reservada - qtd_atendida)
           INTO p_qtd_reservada
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = l_cod_item_compon
            AND cod_local   = m_cod_local_estoq
            AND num_lote    = p_num_lote
      ELSE
         SELECT SUM(qtd_reservada - qtd_atendida)
           INTO p_qtd_reservada
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = l_cod_item_compon
            AND cod_local   = m_cod_local_estoq
            AND num_lote IS NULL
      END IF      
      
      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF
       
      IF p_qtd_saldo > p_qtd_reservada THEN
         LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
      ELSE
         CONTINUE FOREACH
      END IF

      IF p_qtd_saldo <= p_qtd_difer THEN
         LET p_qtd_difer = p_qtd_difer - p_qtd_saldo
         LET p_qtd_transf = p_qtd_saldo
      ELSE
         LET p_qtd_transf = p_qtd_difer
         LET p_qtd_difer = 0
      END IF      

      LET p_novo_saldo = p_novo_saldo - p_qtd_transf
      LET p_qtd_saldo  = p_qtd_transf
      
      IF p_novo_saldo = 0 THEN
         IF NOT pol1122_deleta_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1122_atualiza_lote() THEN
            RETURN FALSE
         END IF
      END IF

      IF p_qtd_difer = 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION


#------------------------------#
 FUNCTION pol1122_deleta_lote()
#------------------------------#
   
   IF p_num_lote IS NULL THEN
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa_qtd
         AND num_lote IS NULL
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_qtd
   END IF
   
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' DELETANDO DA ESTOUQE_LOTE - pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
   
   IF p_num_lote IS NULL THEN
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa_qtd
         AND num_lote IS NULL
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_qtd
   END IF
   
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' DELETANDO DA ESTOUQE_LOTE_ENDER-pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   IF p_ies_situa_qtd = 'R' THEN
   ELSE
      IF NOT pol1122_atualiza_local_prod() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol1122_insere_est_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#------------------------------#
 FUNCTION pol1122_atualiza_lote()
#------------------------------#
   
   IF p_num_lote IS NULL THEN

      UPDATE estoque_lote
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa_qtd
         AND num_lote IS NULL

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS, ' ATUALISANDO A ESTOUQE_LOTE-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      UPDATE estoque_lote_ender
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa_qtd
         AND num_lote IS NULL

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS, ' ATUALISANDO A ESTOUQE_LOTE_ENDER-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   
   ELSE

      UPDATE estoque_lote
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_qtd

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      UPDATE estoque_lote_ender
         SET qtd_saldo = p_novo_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_estoq
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_qtd

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE_ENDER-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

   END IF
   
   IF NOT pol1122_atualiza_local_prod() THEN
      RETURN FALSE
   END IF

   IF NOT pol1122_insere_est_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#--------------------------------------#
FUNCTION  pol1122_atualiza_local_prod()
#--------------------------------------#

   IF p_num_lote IS NOT NULL THEN
    SELECT num_lote
      FROM estoque_lote
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = l_cod_item_compon
       AND cod_local     = m_cod_local_prod
       AND num_lote      = p_num_lote
       AND ies_situa_qtd = p_ies_situa_dest
   ELSE
    SELECT num_lote
      FROM estoque_lote
     WHERE cod_empresa   = p_cod_empresa
       AND cod_item      = l_cod_item_compon
       AND cod_local     = m_cod_local_prod
       AND ies_situa_qtd = p_ies_situa_dest
       AND num_lote IS NULL
   END IF   
   
   IF SQLCA.sqlcode = NOTFOUND THEN
      IF NOT pol1122_insere_local_prod() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1122_altera_local_prod() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION  pol1122_insere_local_prod()
#-----------------------------------#

      INSERT INTO estoque_lote
          VALUES (p_cod_empresa,
                  l_cod_item_compon,
                  m_cod_local_prod,
                  p_num_lote,
                  p_ies_situa_dest,
                  p_qtd_saldo,
                  0)
      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_LOTE-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
      
      INSERT INTO estoque_lote_ender
      VALUES (p_cod_empresa,
              l_cod_item_compon,
              m_cod_local_prod,
              p_num_lote,
              " ",
              0,
              " ",
              " ",
              " ",
              " ",
              " ",
              "1900-01-01 00:00:00",
              0,
              0,
              p_ies_situa_dest,
              p_qtd_saldo,
              0,
              " ",
              "1900-01-01 00:00:00",
              " ",
              " ",
              0,
              0,
              0,
              0,
              "1900-01-01 00:00:00",
              "1900-01-01 00:00:00",
              "1900-01-01 00:00:00",
              0,
              0,
              0,
              0,
              0,
              0,
              " "," "," ")                                                     

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_LOTE_ENDER-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      RETURN TRUE
      
END FUNCTION

#-----------------------------------#
FUNCTION  pol1122_altera_local_prod()
#-----------------------------------#

   IF p_num_lote IS NOT NULL THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo + p_qtd_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_prod
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_dest

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_prod
         AND num_lote      = p_num_lote
         AND ies_situa_qtd = p_ies_situa_dest
    
    ELSE
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo + p_qtd_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_prod
         AND ies_situa_qtd = p_ies_situa_dest
         AND num_lote IS NULL

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_saldo
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = l_cod_item_compon
         AND cod_local     = m_cod_local_prod
         AND ies_situa_qtd = p_ies_situa_dest
         AND num_lote IS NULL

   END IF    

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE_ENDER-pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1122_insere_est_trans()
#----------------------------------#
   
   DEFINE p_cod_local_dest LIKE estoque_trans.cod_local_est_dest,
          p_num_lote_dest  LIKE estoque_trans.num_lote_dest
   
   INITIALIZE mr_estoque_trans.*, p_cod_operacao TO NULL
   
   LET p_cod_local_dest = m_cod_local_prod
   LET p_num_lote_dest  = p_num_lote
   
   IF p_mov_mat = 'M' THEN   #- transf. matéria prima

      SELECT cod_estoque_ac
        INTO p_cod_operacao
        FROM par_pcp
       WHERE cod_empresa = p_cod_empresa
    
      IF sqlca.sqlcode <> 0 THEN
         LET p_cod_operacao = 0
      END IF
   
   ELSE                      #- apontamento de refugo
      IF p_ies_situa_qtd = 'R' THEN
         LET p_cod_operacao   = p_cod_oper_bx_pc_rej
         LET p_ies_situa_dest = NULL
         LET p_num_lote_dest  = NULL
         LET p_cod_local_dest = NULL
      ELSE
         SELECT par_txt 
           INTO p_cod_operacao        
           FROM par_sup_pad  
          WHERE cod_empresa   = p_cod_empresa
            AND cod_parametro = 'operac_est_sup879'      

         IF sqlca.sqlcode <> 0 THEN
            LET p_cod_operacao = 0
         END IF
      END IF

   END IF
   
   INITIALIZE m_num_conta TO NULL
   
   SELECT num_conta_debito
     INTO m_num_conta
     FROM estoque_operac_ct                          
    WHERE cod_empresa   = p_cod_empresa
      AND cod_operacao  = p_cod_operacao 


   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE m_num_conta TO NULL
   END IF


   LET mr_estoque_trans.cod_empresa        = p_cod_empresa
   LET mr_estoque_trans.num_transac        = 0
   LET mr_estoque_trans.cod_item           = l_cod_item_compon 
   LET mr_estoque_trans.dat_movto          = TODAY
   LET mr_estoque_trans.dat_ref_moeda_fort = TODAY
   LET mr_estoque_trans.dat_proces         = TODAY
   LET mr_estoque_trans.hor_operac         = TIME
   LET mr_estoque_trans.ies_tip_movto      = "N"
   LET mr_estoque_trans.cod_operacao       = p_cod_operacao
   LET mr_estoque_trans.num_prog           = "pol1122"
   LET mr_estoque_trans.num_docum          = p_num_ordem
   LET mr_estoque_trans.num_seq            = NULL
   LET mr_estoque_trans.cus_unit_movto_p   = 0
   LET mr_estoque_trans.cus_tot_movto_p    = 0
   LET mr_estoque_trans.cus_unit_movto_f   = 0
   LET mr_estoque_trans.cus_tot_movto_f    = 0
   LET mr_estoque_trans.num_conta          = m_num_conta
   LET mr_estoque_trans.num_secao_requis   = NULL
   LET mr_estoque_trans.nom_usuario        = p_user
   LET mr_estoque_trans.qtd_movto          = p_qtd_saldo
   LET mr_estoque_trans.ies_sit_est_orig   = p_ies_situa_qtd
   LET mr_estoque_trans.ies_sit_est_dest   = p_ies_situa_dest
   LET mr_estoque_trans.cod_local_est_orig = m_cod_local_estoq
   LET mr_estoque_trans.cod_local_est_dest = p_cod_local_dest
   LET mr_estoque_trans.num_lote_orig      = p_num_lote
   LET mr_estoque_trans.num_lote_dest      = p_num_lote_dest

   INSERT INTO estoque_trans VALUES (mr_estoque_trans.*)

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_TRANS-pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   LET m_num_transac_orig = SQLCA.SQLERRD[2]

   IF p_tex_observ IS NOT NULL THEN
   
      INSERT INTO estoque_obs
        VALUES(p_cod_empresa, m_num_transac_orig, p_tex_observ)
        
      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_OBS-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol1122_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF p_mov_mat = 'M' THEN
      IF NOT pol1122_insere_op_lote() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol1122_ins_est_trans_end()
#------------------------------------#

   INITIALIZE mr_estoque_trans_end.*   TO NULL

   LET mr_estoque_trans_end.cod_empresa      = mr_estoque_trans.cod_empresa
   LET mr_estoque_trans_end.num_transac      = m_num_transac_orig
   LET mr_estoque_trans_end.endereco         =  " "
   LET mr_estoque_trans_end.num_volume       = 0
   LET mr_estoque_trans_end.qtd_movto        = mr_estoque_trans.qtd_movto
   LET mr_estoque_trans_end.cod_grade_1      = " "
   LET mr_estoque_trans_end.cod_grade_2      = " "
   LET mr_estoque_trans_end.cod_grade_3      = " "
   LET mr_estoque_trans_end.cod_grade_4      = " "
   LET mr_estoque_trans_end.cod_grade_5      = " "
   LET mr_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.vlr_temperatura  = 0
   LET mr_estoque_trans_end.endereco_origem  = " "
   LET mr_estoque_trans_end.num_ped_ven      = 0
   LET mr_estoque_trans_end.num_seq_ped_ven  = 0
   LET mr_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.num_peca         = " "
   LET mr_estoque_trans_end.num_serie        = " "
   LET mr_estoque_trans_end.comprimento      = 0
   LET mr_estoque_trans_end.largura          = 0
   LET mr_estoque_trans_end.altura           = 0
   LET mr_estoque_trans_end.diametro         = 0
   LET mr_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET mr_estoque_trans_end.qtd_reserv_1     = 0
   LET mr_estoque_trans_end.qtd_reserv_2     = 0
   LET mr_estoque_trans_end.qtd_reserv_3     = 0
   LET mr_estoque_trans_end.num_reserv_1     = 0
   LET mr_estoque_trans_end.num_reserv_2     = 0
   LET mr_estoque_trans_end.num_reserv_3     = 0
   LET mr_estoque_trans_end.tex_reservado    = " "
   LET mr_estoque_trans_end.cus_unit_movto_p = 0
   LET mr_estoque_trans_end.cus_unit_movto_f = 0
   LET mr_estoque_trans_end.cus_tot_movto_p  = 0
   LET mr_estoque_trans_end.cus_tot_movto_f  = 0
   LET mr_estoque_trans_end.cod_item         = mr_estoque_trans.cod_item
   LET mr_estoque_trans_end.dat_movto        = mr_estoque_trans.dat_movto
   LET mr_estoque_trans_end.dat_movto        = mr_estoque_trans.dat_movto
   LET mr_estoque_trans_end.cod_operacao     = mr_estoque_trans.cod_operacao
   LET mr_estoque_trans_end.ies_tip_movto    = mr_estoque_trans.ies_tip_movto
   LET mr_estoque_trans_end.num_prog         = mr_estoque_trans.num_prog

   INSERT INTO estoque_trans_end VALUES (mr_estoque_trans_end.*)

   IF SQLCA.SQLCODE <> 0 THEN
      LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_TRANS_END-pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, m_num_transac_orig, p_user, TODAY,'pol1122')

  IF SQLCA.SQLCODE <> 0 THEN 
     LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_AUDITORIA-pol1122'
     CALL pol1122_insere_erro()
     LET p_sem_estoque = TRUE
     RETURN FALSE
  END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
 FUNCTION pol1122_insere_op_lote()
#--------------------------------#

   DEFINE p_row      INTEGER,
          p_endereco LIKE op_lote.endereco
           
   INITIALIZE mr_op_lote.* TO NULL

   IF p_num_lote IS NULL THEN
      SELECT endereco
        INTO p_endereco
        FROM estoque_lote_ender
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item        = l_cod_item_compon
         AND cod_local       = m_cod_local_estoq
         AND ies_situa_qtd   = p_ies_situa_qtd
         AND num_lote IS NULL
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO ESTOQUE_LOTE_ENDER-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
      SELECT rowid 
        INTO p_row
        FROM op_lote
       WHERE cod_empresa     = p_cod_empresa
         AND ies_origem_info = 'P'
         AND num_ordem       = p_num_ordem
         AND cod_item_compon = l_cod_item_compon
         AND endereco        = p_endereco
         AND num_lote IS NULL
      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO OP_LOTE - pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   ELSE   
      SELECT endereco
        INTO p_endereco
        FROM estoque_lote_ender
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item        = l_cod_item_compon
         AND cod_local       = m_cod_local_estoq
         AND ies_situa_qtd   = p_ies_situa_qtd
         AND num_lote        = p_num_lote
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO ESTOQUE_LOTE_ENDER-pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
      SELECT rowid 
        INTO p_row
        FROM op_lote
       WHERE cod_empresa     = p_cod_empresa
         AND ies_origem_info = 'P'
         AND num_ordem       = p_num_ordem
         AND cod_item_compon = l_cod_item_compon
         AND endereco        = p_endereco
         AND num_lote        = p_num_lote
      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO OP_LOTE - pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   END IF

   IF STATUS = 0 THEN         
      UPDATE op_lote
         SET qtd_transf = qtd_transf + p_qtd_saldo
       WHERE rowid = p_row
      IF SQLCA.SQLCODE <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO OP_LOTE - pol1122'
         CALL pol1122_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF

   LET mr_op_lote.cod_empresa      = p_cod_empresa
   LET mr_op_lote.ies_origem_info  = "P"
   LET mr_op_lote.num_ordem        = p_num_ordem
   LET mr_op_lote.cod_item_compon  = l_cod_item_compon
   LET mr_op_lote.dat_hor_entrada  = "1900-01-01 00:00:00"
   LET mr_op_lote.cod_local_baixa  = m_cod_local_prod
   LET mr_op_lote.num_lote         = p_num_lote 
   LET mr_op_lote.qtd_transf       = p_qtd_saldo 
   LET mr_op_lote.qtd_cons         = 0
   LET mr_op_lote.endereco         = p_endereco
   LET mr_op_lote.num_volume       = 0  
   LET mr_op_lote.dat_hor_producao = "1900-01-01 00:00:00"
   LET mr_op_lote.dat_hor_valid    = "1900-01-01 00:00:00"
   LET mr_op_lote.num_peca         = ' '
   LET mr_op_lote.num_serie        = ' '
   LET mr_op_lote.comprimento      = 0  
   LET mr_op_lote.largura          = 0  
   LET mr_op_lote.altura           = 0  
   LET mr_op_lote.diametro         = 0 

   INSERT INTO op_lote VALUES (mr_op_lote.*)

   IF SQLCA.SQLCODE <> 0 THEN
      LET m_msg = 'ERRO ',STATUS,' INSERINDO NA OP_LOTE - pol1122'
      CALL pol1122_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------#
FUNCTION pol1122_aponta()
#------------------------#

   DEFINE	l_rowid	DECIMAL(15,0),
          p_num_reg INTEGER,
          p_indice  INTEGER,
          p_ind     INTEGER,
          x_hor_ini  CHAR(10),
	        x_hor_fim  CHAR(10),
	        p_cod_parada CHAR(5)						

   DEFINE p_registro ARRAY[100] OF RECORD
          rowid      INTEGER
   END RECORD
				
   DEFINE p_w_apont_prod   RECORD 													
				cod_empresa     CHAR(2), 													
				cod_item        CHAR(15), 														
				num_ordem       INTEGER, 
				num_docum       CHAR(10), 
				cod_roteiro     CHAR(15), 
				num_altern      DEC(2,0), 
				cod_operacao    CHAR(5), 
				num_seq_operac  DEC(3,0), 
				cod_cent_trab   CHAR(5), 
				cod_arranjo     CHAR(5), 
				cod_equip       CHAR(15), 
				cod_ferram      CHAR(15), 
				num_operador    CHAR(15), 
				num_lote        CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno       DEC(3,0), 
				qtd_boas        DEC(10,3), 
				qtd_refug       DEC(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local       CHAR(10), 
				cod_local_est   CHAR(10), 
				dat_producao    DATE, 
				dat_ini_prod    DATE, 
				dat_fim_prod    DATE, 
				cod_tip_movto   CHAR(1), 
				estorno_total   CHAR(1), 
				ies_parada      SMALLINT, 
				ies_defeito     SMALLINT, 
				ies_sucata      SMALLINT, 
				ies_equip_min   CHAR(1), 
				ies_ferram_min  CHAR(1), 
				ies_sit_qtd     CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont       CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent   CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa    CHAR(8), 
				nom_usuario     CHAR(8), 
				num_seq_registro INTEGER, 
				observacao      CHAR(200), 
				cod_item_grade1 CHAR(15), 
				cod_item_grade2 CHAR(15), 
				cod_item_grade3 CHAR(15), 
				cod_item_grade4 CHAR(15), 
				cod_item_grade5 CHAR(15), 
				qtd_refug_ant   DECIMAL(10,3), 
				qtd_boas_ant    DECIMAL(10,3), 
				tip_servico     CHAR(1), 
				abre_transacao  SMALLINT,
				modo_exibicao_msg SMALLINT, 
				seq_reg_integra INTEGER, 
				endereco        INTEGER, 
				identif_estoque CHAR(30), 
				sku             CHAR(25),
				finaliza_operacao CHAR(1)
   END RECORD

   DEFINE  p_w_parada RECORD
				cod_parada 						CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO SECOND ,
				hor_fim_periodo 			DATETIME HOUR TO SECOND,
				hor_tot_periodo 			DECIMAL(7,2)
   END RECORD 

   DEFINE p_apont_erro_man912 RECORD LIKE apont_erro_man912.*

   CALL log085_transacao("BEGIN")

   IF NOT pol1122_cria_w_parada() THEN
      RETURN
   END IF
   
   DELETE FROM man_log_apo_prod	
         WHERE empresa = p_cod_empresa   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","man_log_apo_prod")
   END IF

   CALL log085_transacao("COMMIT")
		
   DISPLAY "Aguarde... efetuando o apontamento !!!" AT 16,15
  
   DECLARE cq_apont SCROLL CURSOR WITH HOLD FOR 	
    SELECT empresa,
           item,
           ordem_producao,
           operacao,
           sequencia_operacao,
           centro_trabalho,
           turno,
           arranjo,
           eqpto,
           ferramenta,
           hor_inicial,
           hor_fim,
           parada,
           qtd_refugo,
           qtd_boas,
           qtd_hor,
           local,
           dat_ini_producao,
           dat_fim_producao,
           tip_movto,
           matricula,
					 hor_ini_parada,
					 hor_fim_parada, 
					 parada,
					 terminado, 
					 rowid
			FROM man_apont_454
		 WHERE empresa = p_cod_empresa
		   AND (dat_atualiz IS NULL  OR dat_atualiz = ' ')
			ORDER BY ordem_producao,
			         sequencia_operacao, 
			         rowid
	 
	 FOREACH cq_apont INTO 	
	    p_w_apont_prod.cod_empresa,
			p_w_apont_prod.cod_item,
			p_w_apont_prod.num_ordem,
			p_w_apont_prod.cod_operacao ,
			p_w_apont_prod.num_seq_operac,
			p_w_apont_prod.cod_cent_trab ,
			p_w_apont_prod.cod_turno ,
			p_w_apont_prod.cod_arranjo ,
			p_w_apont_prod.cod_equip ,
			p_w_apont_prod.cod_ferram ,
			x_hor_ini,
			x_hor_fim,
			p_cod_parada,
			p_w_apont_prod.qtd_refug ,
			p_w_apont_prod.qtd_boas ,
			p_w_apont_prod.qtd_total_horas ,
			p_w_apont_prod.cod_local ,
			p_w_apont_prod.dat_ini_prod ,
			p_w_apont_prod.dat_fim_prod ,
			p_w_apont_prod.cod_tip_movto ,
			p_w_apont_prod.num_operador ,
			p_w_parada.hor_ini_periodo,
			p_w_parada.hor_fim_periodo,
			p_w_parada.cod_parada,
			p_w_apont_prod.finaliza_operacao,
			l_rowid

	    IF SQLCA.SQLCODE<> 0 THEN
	    	 CALL log003_err_sql("Lendo","cq_apont:1" )
	    END IF 

			LET p_w_apont_prod.num_lote = pol1122_calcula_lote(p_w_apont_prod.num_ordem)
			
			SELECT cod_local_estoq, 
			       num_docum, 
			       cod_roteiro, 
			       num_altern_roteiro
			  INTO p_w_apont_prod.cod_local_est,
				  	 p_w_apont_prod.num_docum,
					   p_w_apont_prod.cod_roteiro,
					   p_w_apont_prod.num_altern
			  FROM ordens
			 WHERE cod_empresa = p_cod_empresa
			   AND num_ordem   = p_w_apont_prod.num_ordem
			   AND cod_item 	 = p_w_apont_prod.cod_item

	    IF SQLCA.SQLCODE<> 0 THEN
	    	 CALL log003_err_sql("Lendo","cq_apont:2" )
	    END IF 

			IF p_w_apont_prod.cod_cent_trab IS NULL OR
			   p_w_apont_prod.cod_cent_trab = ' '   THEN 
				 LET p_w_apont_prod.cod_cent_trab = 0
			END IF 
			
			IF p_w_apont_prod.cod_arranjo = ' '   OR
			   p_w_apont_prod.cod_arranjo IS NULL THEN 
				 LET p_w_apont_prod.cod_arranjo = 0
			END IF 
			
			IF p_w_apont_prod.cod_ferram = ' '   OR  
			   p_w_apont_prod.cod_ferram IS NULL THEN 
				 INITIALIZE p_w_apont_prod.cod_ferram  TO NULL
				 LET p_w_apont_prod.ies_ferram_min =  "N"
			ELSE 
					LET p_w_apont_prod.ies_ferram_min =  "S"
			END IF 				
			
			IF p_w_apont_prod.cod_equip = ' '   OR 
			   p_w_apont_prod.cod_equip IS NULL THEN
				 LET p_w_apont_prod.ies_equip_min = "N"
         INITIALIZE p_w_apont_prod.cod_equip  TO NULL		 
			ELSE
				 LET p_w_apont_prod.ies_equip_min = "S"	
			END IF 

			LET p_num_lote_refug = p_w_apont_prod.num_lote 
			LET p_cod_item_refug = p_w_apont_prod.cod_item
			
			LET p_w_apont_prod.dat_producao	=	p_w_apont_prod.dat_ini_prod
			
			DECLARE cq_funcio CURSOR FOR 
			 SELECT cod_uni_funcio 
			   FROM uni_funcional a, ord_oper b
				WHERE a.cod_empresa      = p_cod_empresa
				  AND a.cod_empresa      = b.cod_empresa
					AND a.cod_centro_custo = b.cod_cent_cust
					AND b.num_ordem        =  p_w_apont_prod.num_ordem
					AND b.cod_operac       = p_w_apont_prod.cod_operacao
					AND b.num_seq_operac   = p_w_apont_prod.num_seq_operac
																		
			FOREACH cq_funcio INTO p_w_apont_prod.num_secao_requis 

    	   IF SQLCA.SQLCODE<> 0 THEN
	       	  CALL log003_err_sql("Lendo","cq_funcio" )
	       END IF 
					
					IF p_w_apont_prod.cod_cent_trab IS NOT NULL THEN
						EXIT FOREACH
					END IF 
					
			END FOREACH
			
			LET p_w_apont_prod.estorno_total = "N"

			IF p_w_apont_prod.qtd_refug > 0 THEN 
	       LET p_qtd_transf = p_w_apont_prod.qtd_refug
				 LET p_w_apont_prod.ies_defeito = 1
			ELSE
				LET p_w_apont_prod.ies_defeito = 0
				LET p_qtd_transf = 0
			END IF 
			
			LET p_w_apont_prod.ies_sucata 					= 0
      LET p_w_apont_prod.ies_sit_qtd	        =	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL
			LET p_w_apont_prod.num_programa 				= 'pol1122'
			LET p_w_apont_prod.nom_usuario 					= p_user
			LET p_w_apont_prod.cod_item_grade1 			= NULL
			LET p_w_apont_prod.cod_item_grade2 			= NULL
			LET p_w_apont_prod.cod_item_grade3 			= NULL
			LET p_w_apont_prod.cod_item_grade4 			= NULL
			LET p_w_apont_prod.cod_item_grade5 			= NULL
			LET p_w_apont_prod.qtd_refug_ant 				= NULL
			LET p_w_apont_prod.qtd_boas_ant 				= NULL
			LET p_w_apont_prod.abre_transacao 			= 1
			LET p_w_apont_prod.modo_exibicao_msg 		= 1
			LET p_w_apont_prod.seq_reg_integra 			= NULL
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
			
	 	  IF manr24_cria_w_apont_prod(0)  THEN 

	 		   CALL man8246_cria_temp_fifo()
	 		   CALL man8237_cria_tables_man8237()

			   DELETE FROM w_parada
            
         IF (x_hor_ini IS NULL) OR (x_hor_ini = ' ') OR (x_hor_ini = '0') THEN
            LET p_w_apont_prod.ies_parada = 1
         	  LET p_w_apont_prod.hor_ini_periodo = p_w_parada.hor_ini_periodo
         		LET p_w_apont_prod.hor_fim_periodo = p_w_parada.hor_fim_periodo
            LET p_w_parada.cod_parada          = p_cod_parada
            LET p_w_parada.dat_ini_parada      = p_w_apont_prod.dat_ini_prod
            LET p_w_parada.dat_fim_parada      = p_w_apont_prod.dat_ini_prod
            LET p_w_parada.hor_tot_periodo     = p_w_apont_prod.qtd_total_horas

 		 				INSERT INTO w_parada VALUES (p_w_parada.*)    
 		 				   
 		 				IF SQLCA.SQLCODE <> 0 THEN 
						   CALL log003_err_sql('inserir','w_parada')
							 RETURN
						END IF 
         ELSE
            LET p_w_apont_prod.ies_parada = 0
         	  LET p_w_apont_prod.hor_ini_periodo = x_hor_ini
         		LET p_w_apont_prod.hor_fim_periodo = x_hor_fim
         END IF
				
				 DELETE FROM w_apont_prod #ivo - 14/06/11
				 	
	 		   IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incuindo apontamento
	 			
 	 			    IF p_w_apont_prod.ies_defeito = 1  THEN             #apontando defeitos
		 			     IF pol1122_cria_w_defeito() THEN 
		 				      INSERT INTO w_defeito 
		 				        VALUES(p_cod_empresa,
		 				               p_w_apont_prod.qtd_refug)
		 			     END IF 
		 		    END IF 
	 				  
	 			    IF manr27_processa_apontamento(p_w_apont_prod.*)  THEN #processando apontamento
	 				     UPDATE man_apont_454
	 				        SET dat_atualiz = TODAY
	 				      WHERE rowid = l_rowid

						 UPDATE  man_apont_hist_454 
						 	SET dat_atualiz = TODAY, 
							    situacao    = 'P'
	 				      WHERE empresa 	   	 	= p_w_apont_prod.cod_empresa
						    AND ordem_producao 	 	= p_w_apont_prod.num_ordem
							and sequencia_operacao 	= p_w_apont_prod.num_seq_operac
							AND qtd_boas 			= p_w_apont_prod.qtd_boas
							AND dat_ini_producao 	= p_w_apont_prod.dat_ini_prod 
							AND dat_fim_producao 	= p_w_apont_prod.dat_fim_prod
							AND hor_inicial      	= p_w_apont_prod.hor_ini_periodo 
							AND hor_fim        		= p_w_apont_prod.hor_fim_periodo
					  
#	 				  ELSE
#	 				     LET p_qtd_transf = 0  
	 			    END IF 
	 	     END IF 
	 	  END IF
	 	  
	 	  DELETE FROM w_apont_prod #ivo - 14/06/11

      #ivo - 20/09/2011 ...
	 	  IF p_qtd_transf > 0 THEN
	 	     CALL log085_transacao("BEGIN")
	 	     IF NOT pol1122_transf_refugo() THEN
	 	        CALL log085_transacao("ROLLBACK")
	 	     ELSE
	 	        CALL log085_transacao("COMMIT")
	 	     END IF
	 	  END IF #ivo - 20/09/2011 até aqui

	 	  
	 		CALL log085_transacao("BEGIN")
	 		
		 	DECLARE cq_erro CURSOR FOR 	
		 	 SELECT ordem_producao,
		 	        operacao,
		 	        texto_resumo  	
		 		 FROM man_log_apo_prod	
		 		WHERE empresa = p_cod_empresa
		  
		  FOREACH cq_erro INTO 	
		  				p_num_ordem,
		  				p_cod_operacao,
		  				m_msg

			   IF STATUS <> 0 THEN
	          CALL log003_err_sql("Lendo","cq_erro")
	          CALL log085_transacao("ROLLBACK")
	          EXIT FOREACH
	       END IF
		  	
         INSERT INTO apont_erro_man912
          VALUES (p_cod_empresa,
                  p_num_ordem,
                  p_cod_operacao,
                  p_w_apont_prod.num_seq_operac,
                  m_msg)


  			 IF STATUS <> 0 THEN
	          CALL log003_err_sql("Inclusao","apont_erro_man912")
	       END IF  

		  END FOREACH

      DELETE FROM man_log_apo_prod	
		 	 WHERE empresa = p_cod_empresa

  		IF STATUS <> 0 THEN
	       CALL log003_err_sql("Deletando","man_log_apo_prod")
	    END IF  

     	CALL log085_transacao("COMMIT")
 																		
   END FOREACH
  
  
    INSERT INTO man_apont_erro_454
    SELECT * FROM apont_erro_man912   

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INCLUSÃO","man_apont_erro_454")
   END IF
  
END FUNCTION

#----------------------------------#
FUNCTION pol1122_calcula_lote(p_op)
#----------------------------------#

   DEFINE p_op   INTEGER,
          p_dia  INTEGER,
          p_lote CHAR(15),
          p_dig  CHAR(02)
   
   LET p_dia = DAY(TODAY)
   
   IF p_dia <= 5 THEN
      LET p_dig = '-1'
   ELSE
      IF p_dia <= 10 THEN
         LET p_dig = '-2'
      ELSE
         IF p_dia <= 15 THEN
            LET p_dig = '-3'
         ELSE
            IF p_dia <= 20 THEN
               LET p_dig = '-4'
            ELSE
               IF p_dia <= 25 THEN
                  LET p_dig = '-5'
               ELSE
                  LET p_dig = '-6'
               END IF
            END IF
         END IF
      END IF
   END IF
   
   LET p_lote = p_op USING '<<<<<<<<<', p_dig
   
   RETURN(p_lote)
   
END FUNCTION

#---------------------------------#
 FUNCTION pol1122_cria_w_defeito()#
#---------------------------------#

	DROP TABLE w_defeito

	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(3,0)
		)

	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 

END FUNCTION 

#-------------------------------#
 FUNCTION pol1122_cria_w_parada()
#-------------------------------#

	DROP TABLE w_parada

	CREATE TEMP TABLE w_parada (
				cod_parada            CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)

	IF SQLCA.SQLCODE <> 0 THEN
	  CALL log003_err_sql('criando','w_parada')
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 

END FUNCTION 

#ivo - 20/09/2011 ... até o fim
#ver possibilidade de gravar a mensagem anaixo em uma tabela de erro

#------------------------------#
FUNCTION pol1122_transf_refugo()
#------------------------------#
   
   DEFINE p_dat_hoje DATE
   
   LET p_dat_hoje = TODAY
   LET p_cod_local_refug = '03'
   
   SELECT MAX(num_transac)
     INTO p_num_transac
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item_refug
      AND num_lote_dest = p_num_lote_refug
      AND qtd_movto = p_qtd_transf
      AND ies_tip_movto = 'N'
      AND dat_proces = p_dat_hoje
      AND ies_sit_est_dest = 'R'

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('lendo','estoque_trans.num_transac') 
      RETURN FALSE
   END IF
   
   #ver possibilidade de gravar a mensagem anaixo em uma tabela de erro
   IF p_num_transac IS NULL THEN
      LET p_msg = 'Não foi possível ler o movimento de\n ',
                  'apontamento das peças refugadas, na\n',
                  'tablea estoque_trans!'
      #CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF NOT pol1122_transf_movto() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1122_transf_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1122_transf_movto()
#------------------------------#

   SELECT cod_estoque_ac    
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
     #CALL log003_err_sql('Lendo','par_pcp.cod_estoque_ac') 
     RETURN FALSE
   END IF

   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('lendo','estoque_trans') 
      RETURN FALSE
   END IF
   
   LET p_cod_local = p_estoque_trans.cod_local_est_dest
   
   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('lendo','estoque_trans_end') 
      RETURN FALSE
   END IF
   
   LET p_estoque_trans.cod_local_est_orig = p_estoque_trans.cod_local_est_dest
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_refug
   LET p_estoque_trans.num_lote_orig = p_estoque_trans.num_lote_dest
   LET p_estoque_trans.ies_sit_est_orig = p_estoque_trans.ies_sit_est_dest
   LET p_estoque_trans.num_prog = 'pol1122'
   LET p_estoque_trans.dat_proces = TODAY
   LET p_estoque_trans.hor_operac = TIME
   LET p_estoque_trans.cod_operacao = p_cod_operacao
   LET p_estoque_trans.num_transac = 0
   
   INSERT INTO estoque_trans
    VALUES(p_estoque_trans.*)
    
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Inserindo','estoque_trans') 
      RETURN FALSE
   END IF
   
   LET p_num_transac = SQLCA.SQLERRD[2]
   LET p_estoque_trans_end.num_transac = p_num_transac
   LET p_estoque_trans_end.cod_operacao = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.num_prog = p_estoque_trans.num_prog
    
   INSERT INTO estoque_trans_end
    VALUES(p_estoque_trans_end.*)
    
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Inserindo','estoque_trans_end') 
      RETURN FALSE
   END IF
    
  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa, 
            p_num_transac, 
            p_user, 
            p_estoque_trans.dat_proces,
            p_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Inserindo','estoque_auditoria') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1122_transf_estoque()
#--------------------------------#

   SELECT *
     INTO p_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 100 THEN
      LET p_estoque_lote_ender.qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         #CALL log003_err_sql('Lendo','estoque_lote_ender') 
         RETURN FALSE
      END IF
   END IF
   
   IF p_estoque_lote_ender.qtd_saldo < p_qtd_transf THEN
      LET p_msg = 'Tabela estoque_lote_ender sem saldo\n',
                  'de refugo suficiente, para efetuar\n',
                  'a transferência de local!\n'
      #CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF NOT pol1122_atu_lote_ender() THEN
      RETURN FALSE
   END IF

   SELECT num_transac,
          qtd_saldo
     INTO p_num_transac,
          p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 100 THEN
      LET p_qtd_saldo = 0
   ELSE
      IF STATUS <> 0 THEN
         #CALL log003_err_sql('Lendo','estoque_lote') 
         RETURN FALSE
      END IF
   END IF
   
   IF p_qtd_saldo < p_qtd_transf THEN
      LET p_msg = 'Tabela estoque_lote sem saldo\n',
                  'de refugo suficiente, para \n',
                  'efetuar a transferência de local!\n'
      #CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF NOT pol1122_atu_estoque_lote() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol1122_atu_lote_ender()
#--------------------------------#
   
   IF p_estoque_lote_ender.qtd_saldo > p_qtd_transf THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo - p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   ELSE
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_estoque_lote_ender.num_transac
   END IF
   
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Atualizando','estoque_lote_ender.local_padrao') 
      RETURN FALSE
   END IF
      
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local_refug
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 0 THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      IF STATUS = 100 THEN
         LET p_estoque_lote_ender.cod_local = p_cod_local_refug
         LET p_estoque_lote_ender.qtd_saldo = p_qtd_transf
         LET p_estoque_lote_ender.num_transac = 0
         INSERT INTO estoque_lote_ender
          VALUES(p_estoque_lote_ender.*)
      ELSE
         #CALL log003_err_sql('Lendo','estoque_lote_ender') 
         RETURN FALSE
      END IF
   END IF

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Atualizando','estoque_lote_ender.local_refugo') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1122_atu_estoque_lote()
#---------------------------------#
   
   IF p_qtd_saldo > p_qtd_transf THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo - p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      DELETE FROM estoque_lote
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   END IF
   
   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Atualizando','estoque_lote.local_padrao') 
      RETURN FALSE
   END IF
      
   SELECT num_transac
     INTO p_num_transac
     FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_refug
      AND cod_local   = p_cod_local_refug
      AND num_lote    = p_num_lote_refug
      AND ies_situa_qtd = 'R'
      
   IF STATUS = 0 THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo + p_qtd_transf
       WHERE cod_empresa = p_cod_empresa
         AND num_transac = p_num_transac
   ELSE
      IF STATUS = 100 THEN
         LET p_estoque_lote_ender.cod_local = p_cod_local_refug
         LET p_estoque_lote_ender.num_transac = 0
         INSERT INTO estoque_lote
          VALUES(p_cod_empresa,
                 p_cod_item_refug,
                 p_cod_local_refug,
                 p_num_lote_refug,'R',
                 p_qtd_transf,0)
      ELSE
         #CALL log003_err_sql('Lendo','estoque_lote.local_refugo') 
         RETURN FALSE
      END IF
   END IF

   IF STATUS <> 0 THEN
      #CALL log003_err_sql('Atualizando','estoque_lote.local_refugo') 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#
