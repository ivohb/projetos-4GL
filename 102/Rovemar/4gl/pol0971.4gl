#------------------------------------------------------------------------------#
# SISTEMA.: INTEGRA��O DO LOGIX x EGA - MAN912E                                #
# PROGRAMA: pol0971                                                            #
# OBJETIVO: IMPORTA��O DO EGA x LOGIX                                          #
# DATA....: 18/09/2009                                                         #
#                         														                         #
#------------------------------------------------------------------------------#
  DATABASE logix

 GLOBALS

   DEFINE l_pct_ajus_qtd        DECIMAL(5,2),
          p_aponta_como_boa     CHAR(01),
          p_seq_refug           INTEGER,
          p_refugo              INTEGER,
          p_ja_processou        INTEGER,          
          p_chav_seq            LIKE rovapont_hist_man912.chav_seq,
          l_pct_ajus_insumo     DECIMAL(5,2),
          p_aponta_eqpto_recur  CHAR(01),
          p_aponta_ferramenta   CHAR(01),
          l_qtd_apont_man       LIKE apo_oper.qtd_boas,
          p_ies_oper_final      LIKE ord_oper.ies_oper_final,
          p_texto               LIKE audit_logix.texto,
          p_qtd_plan_orig       LIKE ordens.qtd_planej,
          p_planej              LIKE ordens.qtd_planej,
          p_num_opg             LIKE ordens.num_ordem,
          p_qtd_apont           LIKE ordens.qtd_planej,
          p_processando         LIKE rovproc_apont_man912.processando,
          p_ies_apontamento     LIKE ord_oper.ies_apontamento,
          l_qtd_apont_apo       LIKE apo_oper.qtd_boas,
          p_sobra_gemea         LIKE apo_oper.qtd_boas,
          p_ies_ctr_estoque     LIKE item.ies_ctr_estoque,
          p_ies_sofre_baixa     LIKE item_man.ies_sofre_baixa,
          l_qtd_com_ajus        LIKE apo_oper.qtd_boas,
          p_qtd_aumento         LIKE ordens.qtd_planej,
          p_qtd_possivel        LIKE rovman_apont_454.qtd_refugo,
          p_qtd_tot_txt         LIKE rovman_apont_454.qtd_boas,
          p_qtd_transferir      LIKE estoque_lote.qtd_saldo,
          p_cod_equip           CHAR(15),
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
          p_hist_auto_op_enc    CHAR(01),
          p_compati_op_lote     CHAR(01),
          p_ies_baixa_pc_rej    CHAR(01),
          p_cod_oper_bx_pc_rej  CHAR(04),
          p_op_compati          LIKE ordens.num_ordem,
          p_hora_ini            LIKE rovproc_apont_man912.hor_ini,
          p_hor_atu             LIKE rovproc_apont_man912.hor_ini,
          p_tex_observ          LIKE estoque_obs.tex_observ,
          p_time                DATETIME HOUR TO SECOND,
          p_hor_proces          CHAR(10),
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
          p_saldo_gemea         INTEGER,
          p_qtd_peca_gemea      INTEGER,
          p_dat_producao        CHAR(10),
          p_hora                char(08),
          p_tempo               INTEGER

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
            p_num_op               LIKE rovapont_ega_man912.num_op,
            p_unidade              LIKE item.cod_unid_med,
            p_cod_operac           LIKE operacao.cod_operac,
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
            p_cod_peca_gemea       CHAR(15),
            p_num_op_gemea         LIKE ordens.num_ordem,
            p_saldo_princ          LIKE ordens.qtd_planej,
            p_qtd_planej           LIKE ordens.qtd_planej,
            p_qtd_boas             LIKE ordens.qtd_boas,
            p_qtd_refug            LIKE ordens.qtd_refug,
            p_qtd_sucata           LIKE ordens.qtd_sucata,
            p_cod_mov_logix        CHAR(03),
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
            p_count                SMALLINT,
            p_status               SMALLINT,
            p_retorno              SMALLINT,
            g_usa_visualizador     SMALLINT,
            p_erro_ord_gemea       SMALLINT,
            p_sem_estoque          SMALLINT,
            p_rowid                INTEGER,
            p_chamada              CHAR(01),
            p_tem_gemea            SMALLINT,
            p_consiste             CHAR(01),
            p_qtd_op               SMALLINT,
            p_qtd_gemea            SMALLINT,
            p_op_gemea             INTEGER
            

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
          # p_cont                 INTEGER,
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
            p_cod_operacao         LIKE estoque_trans.cod_operacao,
            m_qtd_item             LIKE ord_oper.qtd_boas,
            p_qtd_item             LIKE ord_oper.qtd_boas,
            m_cod_local_prod       LIKE ordens.cod_local_prod,
            m_cod_local_estoq      LIKE ordens.cod_local_estoq,
            m_contador             SMALLINT,
            mr_estoque_trans       RECORD LIKE estoque_trans.*,
            m_num_conta            LIKE item_sup.num_conta,
            m_num_transac_orig     INTEGER,
            mr_estoque_trans_end   RECORD LIKE estoque_trans_end.*,
            mr_op_lote             RECORD LIKE op_lote.*,
            p_aponta                  RECORD LIKE rovapont_ega_man912.*,
            man_apont                 RECORD LIKE rovman_apont_454.*,
            p_rovapont_hist_man912    RECORD LIKE rovapont_hist_man912.*,
            p_rovman_apont_hist_454   RECORD LIKE rovman_apont_hist_454.*,
            p_rovapont_proc_man912    RECORD LIKE rovapont_ega_man912.*           

 END GLOBALS
            
 DEFINE  p_programa            CHAR(7)
 DEFINE  m_transac            SMALLINT

MAIN
   #CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol0971-12.00.14  ' 
   CALL func002_versao_prg(p_versao)

   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 30
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT

   LET m_caminho = log140_procura_caminho('pol0971.iem')

   OPTIONS
       PREVIOUS KEY control-b,
       NEXT     KEY control-f,
       INSERT   KEY control-i,
       DELETE   KEY control-e,
       HELP    FILE m_caminho

  #CALL log001_acessa_usuario("ESPEC999","")
  #      RETURNING p_status, p_cod_empresa, p_user

   LET p_cod_empresa= '01'
   LET p_user       = 'admlog'    
   LET p_status = 0 

   IF  p_status = 0 THEN
       CALL pol0971_controle()
   END IF
   
END MAIN

#------------------------------#
FUNCTION pol0971_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_status          SMALLINT

   {CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,1) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param2_user
   
   IF l_param1_empresa IS NULL THEN
      RETURN 1
   END IF

   SELECT den_empresa
     INTO l_den_empresa
     FROM empresa
    WHERE cod_empresa = l_param1_empresa
      
   IF STATUS <> 0 THEN
      RETURN 1
   END IF
   }
   
   LET p_cod_empresa= '01'
   LET p_user       = 'admlog'     
   
        
   CALL pol0971_controle() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
 FUNCTION pol0971_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_caminho TO NULL 
   CALL log130_procura_caminho("pol0971") RETURNING m_caminho
   LET m_caminho = m_caminho CLIPPED 
   OPEN WINDOW w_pol0971 AT 2,2 WITH FORM m_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   CALL pol0971_processa()

   CLOSE WINDOW w_pol0971
   
END FUNCTION

#--------------------------------#
FUNCTION pol0971_atu_proc_apont()#
#--------------------------------#

   LET p_hora = TIME
   
   UPDATE proc_apont_man912 
      SET processando = p_processando,
          hor_ini = p_hora
    WHERE cod_empresa = '01'

END FUNCTION

#----------------------------#
FUNCTION pol0971_calc_tempo()#
#----------------------------#

   DEFINE p_hor_atu              CHAR(08),
          p_h_m_s                CHAR(10),
          p_time_hor             DATETIME HOUR TO SECOND,
          p_time_atu             DATETIME HOUR TO SECOND,
          p_hh                   INTEGER,
          p_mm                   INTEGER,
          p_ss                   INTEGER,
          p_hor_proces           CHAR(08)


   LET p_hor_atu = TIME
   
   IF p_hora >= p_hor_atu THEN
      LET p_tempo = 10000
      RETURN
   END IF
   
   LET p_time_hor = p_hora
   LET p_time_atu = p_hor_atu
   
   LET p_h_m_s = (p_time_atu - p_time_hor)

   LET p_hor_proces = p_h_m_s[2,9]
   
   LET p_hh = p_hor_proces[1,2]
   LET p_mm = p_hor_proces[4,5]
   LET p_ss = p_hor_proces[7,8]
      
   LET p_tempo = (p_hh * 3600) + (p_mm * 60) + p_ss
         
END FUNCTION


#---------------------------#
FUNCTION pol0971_processa()
#---------------------------#

   IF NOT pol0971_cria_temp() THEN
      RETURN
   END IF
   
   WHENEVER ERROR CONTINUE

   #CALL log085_transacao("BEGIN")
   BEGIN WORK

   IF NOT pol0971_elimina_duplicidade() THEN
      #CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
      RETURN
   ELSE
   	#CALL log085_transacao("COMMIT")
   	COMMIT WORK
   END IF   
   
   
   #---acerta op_lote para OP's n�o mais liberadas e/ou sem saldo---#   
   
   UPDATE op_lote 
      SET qtd_transf = qtd_cons
    WHERE qtd_cons <> qtd_transf
      AND cod_empresa = p_cod_empresa
      AND num_ordem IN(SELECT num_ordem 
                         FROM ordens where ies_situa = '4'
                          AND (qtd_boas + qtd_refug) >= qtd_planej
                          AND (TODAY - dat_atualiz) > 7 )
                          AND cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","op_lote")
      RETURN 
   END IF

   UPDATE op_lote 
      SET qtd_transf = qtd_cons  
    WHERE cod_empresa = p_cod_empresa
      AND qtd_transf <> qtd_cons 
      AND num_ordem IN (SELECT num_ordem 
                          FROM ordens 
                         WHERE ies_situa IN ('5','9'))
                           AND cod_empresa = p_cod_empresa
                         
   IF STATUS <> 0 THEN
      CALL log003_err_sql("UPDATE","op_lote")
      RETURN 
   END IF

   #----------------------------------------------------------------#                         

   SELECT pct_ajus_insumo,
          aponta_eqpto_recur,
          aponta_ferramenta
     INTO l_pct_ajus_insumo,
          p_aponta_eqpto_recur,
          p_aponta_ferramenta
     FROM rovpct_ajust_man912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","rovpct_ajust_man912")
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
     FROM rovpar_ega_logix_912
    WHERE cod_empresa = p_cod_empresa

   IF STATUS = 100 THEN
      LET p_hist_auto_op_enc = 'N'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","rovpar_ega_logix_912")
         RETURN 
      END IF
   END IF
    
   WHENEVER ERROR CONTINUE

   #CALL log085_transacao("BEGIN")
   BEGIN WORK

   IF NOT pol0971_grava_historico() THEN
      #CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
      RETURN
   END IF

   IF NOT pol0971_monta_seq_oper() THEN
      #CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
      RETURN 
   END IF

   DELETE FROM rovapont_erro_man912

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("DELE��O","rovapont_erro_man912")
      #CALL log085_transacao("ROLLBACK")
      ROLLBACK WORK
      RETURN 
   END IF

   #CALL log085_transacao("COMMIT")
   COMMIT WORK

   LET m_transac = FALSE
   
   IF NOT pol0971_importa_dados() THEN
      RETURN
   END IF

   IF m_transac THEN
      CALL log085_transacao("COMMIT")      
   END IF
   
   CALL pol0971_aponta()

END FUNCTION

#---------------------------#
FUNCTION pol0971_cria_temp()
#---------------------------#

   DROP TABLE apont_temp;

   CREATE TEMP TABLE apont_temp
   (
    dat_producao char(8),
    cod_item char(15),
    num_op char(9),
    cod_operac char(9),
    cod_maquina char(3),
    qtd_refugo char(8),
    qtd_boas char(8),
    tip_mov char(1),
    mat_operador char(8),
    cod_turno char(1),
    hor_ini char(6),
    hor_fim char(6),
    cod_mov char(5),
    num_seq_operac char(3),
    den_erro char(75),
    chav_seq integer,
    arq_orig char(20),
    num_versao decimal(5,0)

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
FUNCTION pol0971_elimina_duplicidade()
#------------------------------------#

   LOCK TABLE rovapont_ega_man912 IN EXCLUSIVE MODE

   IF STATUS <> 0 THEN
      RETURN FALSE
   END IF

   INSERT INTO apont_temp
    SELECT UNIQUE *
      FROM rovapont_ega_man912
     WHERE chav_seq IS NULL

   IF STATUS = 0 THEN
      DELETE FROM rovapont_ega_man912
            WHERE chav_seq IS NULL
      IF STATUS = 0 THEN
         INSERT INTO rovapont_ega_man912
          SELECT * FROM apont_temp
         IF STATUS = 0 THEN
            RETURN TRUE
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0971_grava_historico()
#---------------------------------#

   DISPLAY "Aguarde... limpando tabela rovman_apont_454 !!!" AT 10,15
   
   DELETE FROM rovman_apont_454
    WHERE empresa = p_cod_empresa
     AND (dat_atualiz IS NOT NULL OR dat_atualiz <> ' ')

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("DELE��O","rovman_apont_454:D")
      RETURN FALSE
   END IF

   DISPLAY "Aguarde... gerando hist�rico !!!" AT 12,15

   SELECT MAX(chav_seq)
     INTO p_chav_seq
     FROM rovapont_hist_man912
   
   IF p_chav_seq IS NULL THEN
      LET p_chav_seq = 0
   END IF

   DECLARE cq_hist CURSOR FOR
    SELECT *, rowid
      FROM rovapont_ega_man912
     WHERE (chav_seq IS NULL OR chav_seq = ' ')
     ORDER BY dat_producao, hor_ini, num_op
     
   FOREACH cq_hist INTO p_aponta.*,p_rowid
      
      LET p_chav_seq = p_chav_seq + 1
      
      UPDATE rovapont_ega_man912
         SET chav_seq   = p_chav_seq,
             num_versao = 1
       WHERE rowid = p_rowid
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("UPDATE","rovapont_ega_man912")
         RETURN FALSE
      END IF
      
      INSERT INTO rovapont_hist_man912
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
              NULL,"pol0971","pol0971")

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("INCLUS�O","rovapont_hist_man912")
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE
      
END FUNCTION
   

#--------------------------------#
FUNCTION pol0971_monta_seq_oper()
#--------------------------------#

   DEFINE p_num_op LIKE rovapont_ega_man912.num_op,
          p_cod_op CHAR(9),
          p_seq_op LIKE ord_oper.num_seq_operac,
          p_oper 		CHAR(10),
          p_num_char	SMALLINT

   DECLARE cq_sequenica CURSOR FOR
    SELECT UNIQUE
           num_op,
           cod_operac,
           cod_operac[9]
      FROM rovapont_ega_man912
     ORDER BY 1,2
     
   FOREACH cq_sequenica INTO
           p_num_op,
           p_cod_op,
           p_seq_op

      UPDATE rovapont_ega_man912
         SET num_seq_operac = p_seq_op
       WHERE num_op     = p_num_op
         AND cod_operac = p_cod_op

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("UPDATE","rovapont_ega_man912")
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0971_importa_dados()
#--------------------------------#
         
   DISPLAY "Aguarde... consistindo dados !!!" AT 14,15
           
   LET p_count = 0

   LET p_num_op = '000000000'
   LET p_op_compati = 0
   
   DELETE   FROM  rovapont_proc_man912
   
   IF SQLCA.sqlcode <>  0   THEN 
      CALL log003_err_sql("LENDO","rovapont_proc_man912")
      RETURN FALSE 
   END IF   

   BEGIN WORK
   LET m_transac = TRUE
   
   DECLARE cq_importa CURSOR WITH HOLD FOR 					#Expecifico da rovemar, o cod da opera��o no ega eo numero da 
   																									#opera��o no logix ,mas o numero da sequencia no logix
   
   	SELECT DAT_PRODUCAO, COD_ITEM, NUM_OP,COD_OPERAC, COD_MAQUINA,QTD_REFUGO, QTD_BOAS,TIP_MOV,
		MAT_OPERADOR,COD_TURNO,HOR_INI, HOR_FIM,COD_MOV ,COD_OPERAC[9] SEQUENCIA,DEN_ERRO,
		CHAV_SEQ, ARQ_ORIG, NUM_VERSAO
		FROM ROVAPONT_EGA_MAN912
		ORDER BY TIP_MOV, DAT_PRODUCAO, HOR_INI, NUM_OP, NUM_SEQ_OPERAC
      
   FOREACH cq_importa INTO p_aponta.*

     IF STATUS <> 0 THEN
        RETURN FALSE
     END IF
     
      COMMIT WORK
      LET m_transac = FALSE
      
      BEGIN WORK
      LET m_transac = TRUE

			SELECT ies_situa
			  INTO p_ies_situa
			FROM ORDENS
			WHERE COD_EMPRESA = p_cod_empresa
			AND NUM_ORDEM 		= p_aponta.NUM_OP
			
			IF p_ies_situa = '5' or p_ies_situa = '9' THEN
         DELETE FROM rovapont_ega_man912
          WHERE chav_seq = p_aponta.chav_seq
         UPDATE rovapont_hist_man912
            SET situacao = 'D',
                usuario  = p_user,
                programa = 'pol0971'
          WHERE chav_seq   = p_aponta.chav_seq              
         CONTINUE FOREACH
			END IF

      LET p_tex_observ = NULL
      
      LET p_ja_processou  = 0 
      SELECT COUNT(*)
        INTO p_ja_processou
        FROM rovapont_proc_man912
       WHERE    dat_producao    =  p_aponta.dat_producao 
         AND    cod_item        =  p_aponta.cod_item  
         AND    num_op          =  p_aponta.num_op 
         AND    cod_operac      =  p_aponta.cod_operac
         AND    cod_maquina     =  p_aponta.cod_maquina 
         AND    qtd_refugo      =  p_aponta.qtd_refugo 
         AND    qtd_boas        =  p_aponta.qtd_boas 
         AND    tip_mov         =  p_aponta.tip_mov
         AND    mat_operador    =  p_aponta.mat_operador 
         AND    hor_ini         =  p_aponta.hor_ini
         AND    hor_fim         =  p_aponta.hor_fim  
         AND    cod_mov         =  p_aponta.cod_mov

         IF SQLCA.sqlcode <>  0   THEN 
            CALL log003_err_sql("LENDO","rovapont_proc_man912")
            RETURN FALSE 
         ELSE
            IF p_ja_processou > 0 THEN
               DELETE FROM rovapont_ega_man912
                WHERE chav_seq = p_aponta.chav_seq
                CONTINUE FOREACH
            END IF 
         END IF             
            
         INSERT INTO  rovapont_proc_man912 VALUES (p_aponta.*)
         IF STATUS <> 0 THEN
            CALL log003_err_sql("GRAVANDO","rovapont_proc_man912")
            RETURN FALSE
         END IF          

      IF p_compati_op_lote = 'S' THEN
         IF p_op_compati <> p_aponta.num_op THEN
            LET p_op_compati = p_aponta.num_op
            IF NOT pol0971_compatibiliza_op() THEN
               IF p_sem_estoque THEN
                  LET p_sem_estoque = FALSE
                   LET p_num_ordem = p_aponta.num_op
                  CALL pol0971_insere_erro()
                  CONTINUE FOREACH
               ELSE
                  RETURN FALSE
               END IF
            END IF
         END IF
      END IF
      
      SELECT cod_operac
        INTO p_cod_operac
        FROM rovoper_ega_man912
       WHERE cod_empresa    = p_cod_empresa
         AND cod_operac = p_aponta.cod_operac[6,8] 

      IF sqlca.sqlcode <> 0 THEN
      	 LET p_num_op = p_aponta.num_op
         LET m_msg = 'OPERACAO N�O CADASTRADA NA TAB rovoper_ega_man912 - pol0971'
         CALL pol0971_insere_erro()
         CONTINUE FOREACH
      END IF

      IF pol0971_consiste_ordem() = FALSE THEN
         IF p_envia_hist = 'S' THEN
            IF NOT pol0971_envia_hist() THEN
               RETURN FALSE
            END IF
         END IF
         CONTINUE FOREACH
      END IF

      IF p_aponta.tip_mov = '*' THEN
         IF pol0971_consiste_movto() = FALSE THEN
         		LET p_num_ordem = p_aponta.num_op
            CALL pol0971_insere_erro()
            CONTINUE FOREACH
         END IF
         IF p_aponta_como_boa <> 'S' THEN
            IF NOT pol0971_deleta_apont() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF
      END IF

      LET p_num_ordem = p_aponta.num_op
      DISPLAY 'Ordem: ', p_num_ordem AT 12,20

      {SELECT COUNT(ordem_producao)
        INTO p_qtd_ordem
        FROM rovapont_erro_man912
       WHERE empresa        = p_cod_empresa
         AND ordem_producao = p_aponta.num_op
         AND sequencia_operacao = p_aponta.num_seq_operac

      IF p_qtd_ordem > 0 THEN
      	  LET p_num_op = p_aponta.num_op
         LET m_msg = 'INCONSISTIDO POR CONSEQUENCIA - pol0971'
         LET p_
         CALL pol0971_insere_erro()
         CONTINUE FOREACH
      END IF}    

      IF p_aponta.num_seq_operac IS NULL THEN
      	 LET p_num_ordem = p_aponta.num_op
         LET m_msg = 'OPERACAO SEM NUMERO DE SEQUENCIA - pol0971'
         CALL pol0971_insere_erro()
         CONTINUE FOREACH
      END IF      

      IF p_aponta.tip_mov <> 'P' AND 
         p_aponta.tip_mov <> 'F' AND
         p_aponta.tip_mov <> 'R' AND
         p_aponta.tip_mov <> '*' THEN
          LET p_num_op = p_aponta.num_op
          LET m_msg = 'TIPO DE MOVIMENTO INV�LIDO - pol0971: ', p_aponta.tip_mov
          CALL pol0971_insere_erro()
          CONTINUE FOREACH
      END IF

      IF p_aponta.tip_mov = 'P' THEN
         IF p_aponta.hor_ini = p_aponta.hor_fim THEN
            IF p_aponta.cod_mov <> '01120' THEN
               IF NOT pol0971_deleta_apont() THEN
                  RETURN FALSE
               END IF
               CONTINUE FOREACH
            END IF
         END IF
      END IF   
          
      IF pol0971_consiste_operacao() = FALSE THEN
      		LET p_num_ordem = p_aponta.num_op
         CALL pol0971_insere_erro()
         CONTINUE FOREACH
      END IF

      IF p_aponta.tip_mov = "R" THEN
         IF p_cod_operac <> p_ult_operac THEN
            IF NOT pol0971_deleta_apont() THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF
      END IF

      LET p_count = p_count + 1
      INITIALIZE man_apont.* TO NULL

      CALL pol0971_consiste_dados() RETURNING p_status
      
      IF NOT p_status THEN 
         CONTINUE FOREACH
      END IF

      IF p_aponta.tip_mov = "P" THEN
         LET p_qtd_prod = 0
         LET man_apont.qtd_refugo = 0
         LET man_apont.qtd_boas = 0
      ELSE
         IF p_aponta.tip_mov <> "R" THEN
            LET p_qtd_prod = p_aponta.qtd_boas
            LET man_apont.qtd_refugo = 0
         END IF
      END IF

      LET p_qtd_prod_aux = p_qtd_prod
      
      IF NOT pol0971_consiste_gemeas() THEN
         CONTINUE FOREACH
      END IF

      LET man_apont.qtd_boas = p_qtd_prod

      IF p_aponta.tip_mov = "R" THEN
         IF NOT pol0971_tira_das_boas() THEN
            RETURN FALSE
         ELSE
            LET p_tex_observ = NULL
            IF NOT p_sem_estoque THEN
               IF NOT pol0971_deleta_apont() THEN
                  RETURN FALSE
               ELSE
                  CONTINUE FOREACH
               END IF
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
      END IF

      LET p_tex_observ = NULL

      IF NOT pol0971_acha_qtd_planej() THEN
       LET p_num_op = p_aponta.num_op
         LET m_msg = 'ERRO AO LER A QTD.PLANEJADA DA ORDEM - pol0971'
         CALL pol0971_insere_erro()
         CONTINUE FOREACH
      END IF

      CALL pol0971_calc_dat_hor()
            
      IF p_aponta.tip_mov <> "R" THEN
         LET p_qtd_hor = (p_qtd_seg_fim - p_qtd_seg_ini) / 3600
      END IF
      
      LET man_apont.empresa = p_cod_empresa

      LET man_apont.dat_ini_producao = p_dat_producao
      LET man_apont.dat_fim_producao = man_apont.dat_ini_producao
      LET man_apont.item = p_aponta.cod_item
      LET man_apont.ordem_producao = p_aponta.num_op
      LET man_apont.sequencia_operacao = p_aponta.num_seq_operac
      LET man_apont.operacao = p_cod_operac
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
      IF p_aponta.cod_mov = '01120' THEN
         LET man_apont.terminado = 'S'
      ELSE
      	LET man_apont.terminado = 'N'
      END IF
      IF p_aponta.tip_mov = "P" THEN
        

         LET man_apont.hor_ini_parada = p_hor_min_ini
         LET man_apont.hor_fim_parada = p_hor_min_fim
         LET man_apont.parada = p_cod_mov_logix
         
         LET man_apont.hor_inicial = p_hor_comp_ini
         LET man_apont.hor_fim = p_hor_comp_fim
         
         LET p_chamada = 'P'
         IF NOT pol0971_grava_man() THEN
            RETURN FALSE
         ELSE
            IF p_tem_gemea THEN
               IF NOT pol0971_grava_gem() THEN
                  RETURN FALSE
               END IF
            END IF
         END IF
         CONTINUE FOREACH
      ELSE
         LET man_apont.hor_inicial = p_hor_comp_ini
         LET man_apont.hor_fim = p_hor_comp_fim
      END IF
      
      CALL pol0971_calcula_apontadas() RETURNING l_qtd_tot_apont

      SELECT ies_oper_final
        INTO p_ies_oper_final
        FROM ord_oper
       WHERE cod_empresa    = p_cod_empresa
         AND num_ordem      = man_apont.ordem_producao
         AND cod_operac     = man_apont.operacao
         AND num_seq_operac = p_aponta.num_seq_operac
            
      LET l_qtd_tot_apont = l_qtd_tot_apont + p_qtd_prod
      
      IF l_qtd_tot_apont > m_qtd_item THEN
         IF p_cod_operac = p_pri_operac THEN
            SELECT qtd_planej
              INTO p_qtd_plan_orig
              FROM rovord_ajust_man912
             WHERE cod_empresa = p_cod_empresa
               AND num_ordem   = man_apont.ordem_producao
            IF STATUS = 0 THEN
               LET l_qtd_alter_qtd = p_qtd_plan_orig + p_qtd_plan_orig * l_pct_ajus_insumo / 100
             ELSE
               LET l_qtd_alter_qtd = m_qtd_item + m_qtd_item * l_pct_ajus_insumo / 100
               LET p_qtd_plan_orig = 0
            END IF
            IF l_qtd_tot_apont <= l_qtd_alter_qtd THEN 
               LET p_qtd_aumento = l_qtd_tot_apont - m_qtd_item
               LET p_num_ordem = p_aponta.num_op
               IF NOT pol0971_ajusta_necessidades() THEN
                  IF p_sem_estoque THEN
                     CONTINUE FOREACH
                  ELSE
                     RETURN FALSE
                  END IF
               ELSE
                  IF p_qtd_plan_orig = 0 THEN
                     INSERT INTO rovord_ajust_man912
                      VALUES(p_cod_empresa, man_apont.ordem_producao, m_qtd_item)
                     IF STATUS <> 0 THEN
                        RETURN FALSE
                     END IF
                  END IF
               END IF
               IF p_tem_gemea THEN
                  IF NOT pol0971_ajusta_neces_gem() THEN
                     IF p_sem_estoque THEN
                        CONTINUE FOREACH
                     ELSE
                        RETURN FALSE
                     END IF
                  END IF
               END IF
            ELSE
               LET p_num_ordem = p_aponta.num_op
               LET m_msg = 'QTD.PRODUZIDA > QTD.PLANEJADA + TOLERANCIA - pol0971'
               CALL pol0971_insere_erro()
               CONTINUE FOREACH
            END IF
         ELSE
            LET p_num_ordem = p_aponta.num_op
            LET m_msg = 'QTD.PRODUZIDA > QTD.PLANEJADA - pol0971'
            CALL pol0971_insere_erro()
            CONTINUE FOREACH
         END IF
      END IF

      IF p_ies_oper_final = 'S' THEN
         IF p_aponta.tip_mov = 'F' THEN
            IF NOT pol0971_tem_material() THEN     
               CALL pol0971_insere_erro()
               CONTINUE FOREACH
            END IF
         END IF
      END IF
      
      LET p_chamada = 'P'
      IF NOT pol0971_grava_man() THEN
         RETURN FALSE
      END IF

      IF p_tem_gemea THEN
         IF NOT pol0971_grava_gem() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH  
    
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0971_tem_material()
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
      
      LET p_qtd_apont = l_qtd_apont_man * p_qtd_necessaria
      
      SELECT SUM(qtd_saldo)
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_local_baixa
         AND ies_situa_qtd = "L"

      IF p_qtd_saldo IS NULL OR p_qtd_saldo = 0 THEN
         LET m_msg = 'COMP.',p_cod_item,' S/MATERIAL SUF LOC PROD-pol0971'
         RETURN FALSE
      END IF
      
      LET p_qtd_saldo = p_qtd_saldo - p_qtd_apont

      IF p_qtd_saldo <= 0 THEN
         LET m_msg = 'COMP.',p_cod_item,' S/MATERIAL SUF LOC PROD-pol0971'
         RETURN FALSE
      END IF

      LET p_qtd_possivel = p_qtd_saldo / p_qtd_necessaria

      IF p_qtd_possivel < p_qtd_prod THEN
         LET p_qtd_prod = p_qtd_possivel
      END IF
            
   END FOREACH
   
   LET man_apont.qtd_boas = p_qtd_prod
   
   IF p_tem_gemea THEN
      IF NOT pol0971_gemea_t_estoq() THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_qtd_prod = man_apont.qtd_boas
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0971_gemea_t_estoq()
#-------------------------------#

   DEFINE p_local_baixa   LIKE ord_compon.cod_local_baixa,
          p_mat_empenhado LIKE ord_compon.qtd_necessaria,
          p_qtd_geme_apo  LIKE rovman_apont_454.qtd_boas,
          p_qtd_apontar   LIKE rovman_apont_454.qtd_boas,
          p_qtd_mat_neces LIKE ord_compon.qtd_necessaria
          
   DECLARE cq_est_gem CURSOR FOR
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa    = p_cod_empresa
       AND cod_peca_princ = man_apont.item
     ORDER BY cod_peca_gemea
   
   FOREACH cq_est_gem INTO p_cod_peca_gemea, p_qtd_peca_gemea

      LET p_qtd_apontar = man_apont.qtd_boas * p_qtd_peca_gemea
      
      DECLARE cq_ops_gemeas CURSOR FOR
       SELECT num_opg,
              saldo_gemea
         FROM ordens_gemeas
        WHERE num_opp  = man_apont.ordem_producao
          AND cod_item = p_cod_peca_gemea
        ORDER BY num_opg

      FOREACH cq_ops_gemeas INTO p_num_opg, p_saldo_gemea

         IF p_saldo_gemea > p_qtd_apontar THEN
            LET p_qtd_prod = p_qtd_apontar
            LET p_qtd_apontar = 0
         ELSE
            LET p_qtd_prod = p_saldo_gemea
            LET p_qtd_apontar = p_qtd_apontar - p_saldo_gemea
         END IF

			   DECLARE cq_comp_gemea CURSOR FOR
			    SELECT cod_item_compon,
			           qtd_necessaria,
			           cod_local_baixa
			      FROM ord_compon
			     WHERE cod_empresa = p_cod_empresa
			       AND num_ordem   = p_num_opg

			   FOREACH cq_comp_gemea INTO 
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

            LET p_qtd_mat_neces = p_qtd_prod * p_qtd_necessaria
      
            SELECT SUM(qtd_boas +  qtd_refugo)
              INTO p_qtd_geme_apo
              FROM rovman_apont_454
             WHERE empresa        = p_cod_empresa
               AND ordem_producao = p_num_opg
               AND operacao       = p_cod_operac
               AND sit_apont      = 1 
               AND (dat_atualiz IS NULL OR dat_atualiz = ' ')

            IF p_qtd_geme_apo IS NULL OR p_qtd_geme_apo < 0 THEN
               LET p_qtd_geme_apo = 0
            END IF
            
            LET p_mat_empenhado = p_qtd_geme_apo * p_qtd_necessaria
      
			      SELECT SUM(qtd_saldo)
			        INTO p_qtd_saldo
			        FROM estoque_lote
			       WHERE cod_empresa   = p_cod_empresa
			         AND cod_item      = p_cod_item
			         AND cod_local     = p_local_baixa
			         AND ies_situa_qtd = "L"
			
			      IF p_qtd_saldo IS NULL THEN
			         LET p_qtd_saldo = 0
			      END IF
      
			      LET p_qtd_saldo = p_qtd_saldo - p_mat_empenhado
			
			      IF p_qtd_saldo < p_qtd_mat_neces THEN
			         LET m_msg = 'COMP.',p_cod_item,' S/MATERIAL SUF LOC PROD-pol0971'
			         RETURN FALSE
			      END IF

         END FOREACH

         IF p_qtd_apontar <= 0 THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
            
   END FOREACH
      
   RETURN TRUE      

END FUNCTION


#------------------------------#
FUNCTION pol0971_calc_dat_hor()
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
FUNCTION pol0971_calcula_apontadas()
#----------------------------------#

   DEFINE p_qtd_pecas LIKE apo_oper.qtd_boas
   
      SELECT SUM(qtd_boas + qtd_refugo)
        INTO l_qtd_apont_apo
        FROM apo_oper
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem   = p_aponta.num_op
         AND cod_operac  = p_cod_operac
         AND num_seq_operac = p_aponta.num_seq_operac

      IF l_qtd_apont_apo IS NULL THEN
         LET l_qtd_apont_apo = 0
      END IF

      SELECT SUM(qtd_boas + qtd_refugo)
        INTO l_qtd_apont_man
        FROM rovman_apont_454
       WHERE empresa        = p_cod_empresa
         AND ordem_producao = p_aponta.num_op
         AND operacao       = p_cod_operac
         AND sequencia_operacao = p_aponta.num_seq_operac
         AND sit_apont      = 1
         AND (dat_atualiz IS NULL OR dat_atualiz = ' ')

      IF l_qtd_apont_man IS NULL THEN
         LET l_qtd_apont_man = 0
      END IF

      LET p_qtd_pecas = l_qtd_apont_apo + l_qtd_apont_man
      
   RETURN p_qtd_pecas
   
END FUNCTION

#---------------------------------#
FUNCTION pol0971_acha_qtd_planej()
#---------------------------------#

   SELECT qtd_planej
     INTO m_qtd_item
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_aponta.num_op

   IF STATUS <> 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION pol0971_compatibiliza_op()
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

#----------------------------#
FUNCTION pol0971_envia_hist()
#----------------------------#

   INSERT INTO rovman_apont_hist_454
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
             '','','','','','','','','','','',
             p_user,
             'pol0971')
             
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","rovman_apont_hist_454")
      RETURN FALSE
   END IF

   IF NOT pol0971_deleta_apont() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#----------------------------#
 FUNCTION pol0971_grava_man()
#----------------------------#

   INSERT INTO rovman_apont_454 VALUES (man_apont.*)
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","rovman_apont_454:I")
      RETURN FALSE
   END IF
   
   SELECT MAX(rowid)
     INTO man_apont.refugo
     FROM rovman_apont_454
    WHERE empresa = p_cod_empresa
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("LENDO","rovman_apont_454:L")
      RETURN FALSE
   END IF
   
   INSERT INTO rovman_apont_hist_454
    VALUES(man_apont.*,'I',p_user, 'pol0971')

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("INSERINDO","rovman_apont_hist_454")
      RETURN FALSE
   END IF
   
   IF p_chamada <> 'G' THEN
      IF NOT pol0971_atualiza_tabs() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0971_deleta_apont()
#-----------------------------#

   DELETE FROM rovapont_ega_man912
    WHERE chav_seq = p_aponta.chav_seq

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('DELECAO',"rovapont_ega_man912")
      RETURN FALSE
   END IF

   UPDATE rovapont_hist_man912
      SET situacao = "D"
    WHERE chav_seq   = p_aponta.chav_seq
      AND num_versao = p_aponta.num_versao

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('UPDATE',"rovapont_hist_man912")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0971_atualiza_tabs()
#------------------------------#

   DEFINE p_dif      INTEGER,
          p_qtd_boas CHAR(8),
          p_men      CHAR(7)
          
   IF p_qtd_prod_aux = p_qtd_prod THEN

      LET p_men = 'DELE��O'

      DELETE FROM rovapont_ega_man912
       WHERE chav_seq = p_aponta.chav_seq

      IF STATUS = 0 THEN

         UPDATE rovapont_hist_man912
            SET situacao = "A"
          WHERE chav_seq   = p_aponta.chav_seq
            AND num_versao = p_aponta.num_versao

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('UPDATE',"rovapont_hist_man912")
            RETURN FALSE
         END IF

      END IF

   ELSE

      LET p_men = 'UPDATE'
      LET p_dif = p_qtd_prod_aux - p_qtd_prod
      LET p_qtd_boas = p_dif USING '&&&&&&&&'

      UPDATE rovapont_ega_man912
         SET qtd_boas = p_qtd_boas
       WHERE chav_seq = p_aponta.chav_seq

			LET p_num_ordem = p_aponta.num_op
      LET m_msg = 'APONTAMENTO PARCIAL POR FALTA DE SALDO - pol0971'
      CALL pol0971_insere_erro()
   END IF   

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql(p_men,"rovapont_ega_man912:1530")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0971_grava_gem()
#---------------------------#

   DEFINE p_tot_apontar  LIKE ordens.qtd_planej,
          p_cod_peca     LIKE item.cod_item

   LET p_cod_peca  = man_apont.item
   LET p_qtd_prod  = man_apont.qtd_boas
   
   DECLARE cq_gra_gem CURSOR FOR
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa    = p_cod_empresa
       AND cod_peca_princ = p_cod_peca
     ORDER BY cod_peca_gemea
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","rovpeca_geme_man912")       
      RETURN FALSE
   END IF
   
   FOREACH cq_gra_gem INTO p_cod_peca_gemea, p_qtd_peca_gemea

      LET p_tot_apontar  = p_qtd_prod * p_qtd_peca_gemea

      DECLARE cq_op_gem CURSOR FOR
       SELECT num_opg,
              saldo_gemea
         FROM ordens_gemeas
        WHERE num_opp     = p_aponta.num_op
          AND cod_item    = p_cod_peca_gemea
          AND saldo_gemea > 0
        ORDER BY 1

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LENDO","ordens_gemeas")       
          RETURN FALSE
       END IF
   
      FOREACH cq_op_gem INTO 
              man_apont.ordem_producao,
              p_saldo_gemea

         LET man_apont.item    = p_cod_peca_gemea
         LET p_aponta.cod_item = man_apont.item
         LET p_aponta.num_op   = man_apont.ordem_producao

         IF pol0971_consiste_ordem() = FALSE THEN
         		LET p_num_ordem = p_aponta.num_op
            CALL pol0971_insere_erro()
            CONTINUE FOREACH
         END IF

         LET man_apont.centro_trabalho = p_cod_cent_trab
         LET man_apont.ferramenta      = p_cod_ferramenta
         LET man_apont.local           = m_cod_local_prod    

         IF p_saldo_gemea > p_tot_apontar THEN
            LET man_apont.terminado = NULL
            LET man_apont.qtd_boas = p_tot_apontar
            LET p_tot_apontar = 0
         ELSE
#           LET man_apont.terminado = 'S'
            LET man_apont.terminado = NULL
            LET man_apont.qtd_boas = p_saldo_gemea
            LET p_tot_apontar = p_tot_apontar - man_apont.qtd_boas
         END IF
      
         LET p_chamada = 'G'
         IF NOT pol0971_grava_man() THEN
            RETURN FALSE
         END IF

         IF p_tot_apontar <= 0 THEN
            EXIT FOREACH
         END IF
    
      END FOREACH

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0971_consiste_gemeas()				# verifica a existencia de p�as gemeas
#--------------------------------#				# se houver pe�as gemeas ele apont a pe�a mais de uma vez

   SELECT COUNT(cod_peca_gemea)
     INTO p_qtd_gemea
     FROM rovpeca_geme_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_peca_princ = p_aponta.cod_item

   IF p_qtd_gemea = 0 THEN
      LET p_tem_gemea = FALSE
      RETURN TRUE
   END IF
   
   LET p_tem_gemea = TRUE

   DROP TABLE ordens_gemeas;

   CREATE TEMP TABLE ordens_gemeas
   (
      num_opp         INTEGER,
      num_opg         INTEGER,
      cod_item        CHAR(15),
      saldo_gemea     DECIMAL(10,3),
      qtd_planej      DECIMAL(10,3)
   );

   IF STATUS = -958 THEN
      DELETE FROM ordens_gemeas
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("DELETE","ordens_gemeas:delete")
         RETURN FALSE
      END IF
   ELSE
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CREATE","ordens_gemeas:create")
         RETURN FALSE
      END IF
   END IF
   
   SELECT qtd_planej
     INTO p_qtd_planej
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_aponta.num_op
      AND ies_situa   = 4     
   
   SELECT SUM(qtd_boas +  qtd_refugo)
     INTO l_qtd_apont_apo
     FROM apo_oper
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_aponta.num_op
      AND cod_operac  = p_cod_operac

   IF l_qtd_apont_apo IS NULL THEN
      LET l_qtd_apont_apo = 0
   END IF

   SELECT SUM(qtd_boas +  qtd_refugo)
     INTO l_qtd_apont_man
     FROM rovman_apont_454
    WHERE empresa        = p_cod_empresa
      AND ordem_producao = p_aponta.num_op
      AND operacao       = p_cod_operac
      AND sit_apont      = 1 
      AND (dat_atualiz IS NULL OR dat_atualiz = ' ')

   IF l_qtd_apont_man IS NULL THEN
      LET l_qtd_apont_man = 0
   END IF
         
   LET l_qtd_tot_apont = l_qtd_apont_apo + l_qtd_apont_man
   LET p_saldo_princ   = p_qtd_planej - l_qtd_tot_apont

   IF p_saldo_princ < 0 THEN
      LET p_saldo_princ = 0
   END IF
   
   DECLARE cq_peca CURSOR FOR
    SELECT cod_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa = p_cod_empresa
       AND cod_peca_princ = p_aponta.cod_item

   FOREACH cq_peca INTO p_cod_peca_gemea

      DECLARE cq_op CURSOR FOR
      SELECT num_ordem,
             qtd_planej
        FROM ordens
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_peca_gemea
         AND ies_situa   = 4
         AND qtd_planej > (qtd_boas + qtd_refug + qtd_sucata)
         ORDER BY num_ordem
         
      FOREACH cq_op INTO p_op_gemea, p_qtd_planej

         SELECT SUM(qtd_boas +  qtd_refugo)
           INTO l_qtd_apont_apo
           FROM apo_oper
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_op_gemea
            AND cod_operac  = p_cod_operac

         IF l_qtd_apont_apo IS NULL THEN
            LET l_qtd_apont_apo = 0
         END IF

         SELECT SUM(qtd_boas +  qtd_refugo)
           INTO l_qtd_apont_man
           FROM rovman_apont_454
          WHERE empresa        = p_cod_empresa
            AND ordem_producao = p_op_gemea
            AND operacao       = p_cod_operac
            AND sit_apont      = 1 
            AND (dat_atualiz IS NULL OR dat_atualiz = ' ')

         IF l_qtd_apont_man IS NULL THEN
            LET l_qtd_apont_man = 0
         END IF
         
         LET l_qtd_tot_apont = l_qtd_apont_apo + l_qtd_apont_man
         LET p_saldo_gemea = p_qtd_planej - l_qtd_tot_apont

         IF p_saldo_gemea < 0 THEN
            LET p_saldo_gemea = 0
         END IF

         INSERT INTO ordens_gemeas
            VALUES(p_aponta.num_op, 
                   p_op_gemea, 
                   p_cod_peca_gemea,
                   p_saldo_gemea,
                   p_qtd_planej)

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("inclus�o","ordens_gemeas")
            RETURN FALSE
         END IF      
        
      END FOREACH

   END FOREACH

   IF p_aponta.tip_mov = "P" THEN 
      RETURN TRUE
   END IF

   IF p_saldo_princ < p_qtd_prod THEN 
      RETURN TRUE
   END IF
   
   LET p_retorno = FALSE
   
   DECLARE cq_consist_pecas CURSOR FOR
    SELECT cod_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa = p_cod_empresa
       AND cod_peca_princ = p_aponta.cod_item

   FOREACH cq_consist_pecas INTO p_cod_peca_gemea

      SELECT COUNT(num_opg)
        INTO p_qtd_opg
        FROM ordens_gemeas
       WHERE num_opp  = p_aponta.num_op
         AND cod_item = p_cod_peca_gemea

      IF p_qtd_opg = 0 THEN
      	 LET p_num_ordem = p_aponta.num_op
         LET m_msg = 'PECA PRINC:',p_aponta.cod_item CLIPPED,', ',
                     'SIMETRICA:', p_cod_peca_gemea CLIPPED,' ',
                     'SEM ORDEM PROD - pol0971'
         CALL pol0971_insere_erro()
         LET p_retorno = TRUE
         CONTINUE FOREACH
      END IF

      SELECT SUM(saldo_gemea)
        INTO p_saldo_gemea
        FROM ordens_gemeas
       WHERE num_opp  = p_aponta.num_op
         AND cod_item = p_cod_peca_gemea
      
      IF p_saldo_gemea = 0 AND p_saldo_princ > 0 THEN
      	 LET p_num_ordem = p_aponta.num_op
         LET m_msg = 'PECA PRINC:',p_aponta.cod_item CLIPPED,', ',
                     'SIMETRICA:', p_cod_peca_gemea CLIPPED,' ',
                     'SEM SALDO NA OP - pol0971'
         CALL pol0971_insere_erro()
         LET p_retorno = TRUE
         CONTINUE FOREACH
      END IF
      
   END FOREACH

   IF p_retorno THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_soma_pecas CURSOR FOR
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa = p_cod_empresa
       AND cod_peca_princ = p_aponta.cod_item

   FOREACH cq_soma_pecas INTO p_cod_peca_gemea, p_qtd_peca_gemea

      SELECT SUM(saldo_gemea)
        INTO p_saldo_gemea
        FROM ordens_gemeas
       WHERE num_opp  = p_aponta.num_op
         AND cod_item = p_cod_peca_gemea

      LET p_saldo_gemea = p_saldo_gemea / p_qtd_peca_gemea

      IF p_saldo_gemea < p_qtd_prod THEN
         LET p_qtd_prod = p_saldo_gemea
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
 FUNCTION pol0971_consiste_dados()
#--------------------------------#
      
      LET p_retorno = TRUE
      
      IF pol0971_consiste_item() = FALSE THEN
      		LET p_num_ordem = p_aponta.num_op
         CALL pol0971_insere_erro()
         LET p_retorno = FALSE
      END IF
      
      IF pol0971_consiste_maquina() = FALSE THEN
      		LET p_num_ordem = p_aponta.num_op
         CALL pol0971_insere_erro()
         LET p_retorno = FALSE
      END IF

      IF p_aponta.tip_mov = "R" THEN
      ELSE
         IF pol0971_consiste_matricula() = FALSE THEN
         		LET p_num_ordem = p_aponta.num_op
            CALL pol0971_insere_erro()
            LET p_retorno = FALSE
         END IF
      END IF

      IF p_aponta.tip_mov = "P" THEN 
         IF pol0971_consiste_movto() = FALSE THEN
         		LET p_num_ordem = p_aponta.num_op
            CALL pol0971_insere_erro()
            LET p_retorno = FALSE
         END IF
      END IF

      RETURN (p_retorno)
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0971_consiste_operacao()					#consiste operacao se nao existir nao aponta
#-----------------------------------#					#

   SELECT *
     FROM operacao
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac  = p_cod_operac
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'OPERACAO CORRESPONDENTE N�O CADASTRADA NA TAB OPERACAO - pol0971'
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
      LET m_msg = 'OPERACAO FINAL N�O CADASTRADA - ORD_OPER - pol0971'
      RETURN FALSE
   END IF

   LET p_ies_apontamento = 'F'
   
   SELECT COUNT(cod_operac)
     INTO p_qtd_operac
     FROM ord_oper
    WHERE cod_empresa    = p_cod_empresa
      AND num_ordem      = p_aponta.num_op

   IF p_qtd_operac > 1 AND p_cod_operac <> p_pri_operac THEN
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
   
   #IF p_aponta.cod_mov = '01120' THEN //IVO
   #   IF p_ies_apontamento <> 'F' THEN
   #      LET m_msg = 'TENTATIVA DE ENCERRAR OPER S/ ENCERRAR OPER ANT - pol0971'
   #      RETURN FALSE
   #   END IF
   #END IF
      
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 FUNCTION pol0971_consiste_ordem()				#consiste o numero da op, se na� estiver cadastrado ou
#--------------------------------#				#a op do ega nao bater com a do logix nao aponta
   
   DEFINE p_seq_processo LIKE man_processo_item.seq_processo
   
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
   		LET p_num_ordem = p_aponta.num_op
      LET m_msg = 'ORDEM DE PRODU��O N�O EXISTE - pol0971'
      CALL pol0971_insere_erro()
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
      	 LET p_num_ordem = p_aponta.num_op
         LET m_msg = 'ORDEM DE PRODU��O N�O ESTA LIBERADA - pol0971'
         CALL pol0971_insere_erro()
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
     # AND cod_operac     = p_cod_operac
      AND num_seq_operac = p_aponta.num_seq_operac
   
   DECLARE cq_proces CURSOR FOR
   SELECT seq_processo
     FROM man_processo_item
    WHERE empresa        = p_cod_empresa
      AND item           = p_aponta.cod_item
      AND roteiro        = p_cod_roteiro
      AND roteiro_alternativo = p_num_altern_roteiro
      AND operacao         = p_cod_operac
      
   FOREACH cq_proces INTO p_seq_processo

      DECLARE cq_fer CURSOR FOR
       SELECT ferramenta
         FROM man_ferramenta_processo
        WHERE empresa  = p_cod_empresa
          AND seq_processo = p_seq_processo

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
 FUNCTION pol0971_consiste_item()							#Consiste se item esta cadastrado no logix
#-------------------------------#							#Se nao estiver nao aponta!!
   SELECT cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_aponta.cod_item
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ITEM: ', p_aponta.cod_item, ' N�O CADASTRADO - pol0971'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION


#----------------------------------#
 FUNCTION pol0971_consiste_maquina()				#Faz a consistencia da maquina do logix e do ega se n�o 
#----------------------------------#				#estiver cadastrada n�o aponta.

   SELECT cod_maquina, 
          cod_equip
     INTO p_cod_maquina,
          p_cod_equip
     FROM rovmaq_ega_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_maquina_ega = p_aponta.cod_maquina

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'MAQUINA:',p_aponta.cod_maquina,
                  ' N�O CADASTRADA - rovmaq_ega_man912 - pol0971'
      RETURN FALSE
   END IF

   IF p_cod_equip IS NULL THEN
      LET m_msg = 'COD.EQPTO. NULLO NA TABELA rovmaq_ega_man912 - pol0971'
      RETURN FALSE
   END IF

   SELECT cod_recur
     FROM recurso
    WHERE cod_empresa   = p_cod_empresa
      AND cod_recur     = p_cod_maquina
      AND ies_tip_recur = '2'
      
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'MAQUINA:',p_cod_maquina,' N�O CADASTRADA - RECURSO - pol0971'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0971_consiste_matricula()				# consiste matricula do funcionario 
#------------------------------------#				# se o funcionario nao estiver cadastrado nao aponta
   
   DEFINE p_mat_operador LIKE rovapont_ega_man912.mat_operador,
   				p_mat_convert_oper	DECIMAL(7,0)
   
   INITIALIZE p_cod_uni_funcio TO NULL
   
   SELECT cod_uni_funcio
     INTO p_cod_uni_funcio
     FROM funcionario
    WHERE cod_empresa   = p_cod_empresa
      AND num_matricula = p_aponta.mat_operador
   IF sqlca.sqlcode <> 0 THEN
      SELECT operador_padrao
        INTO p_mat_operador
        FROM rovoperad_pad_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_turno   = p_aponta.cod_turno
      
      IF STATUS <> 0 THEN
         LET m_msg = 'MATRIC.OPERADOR:', p_aponta.mat_operador,
                     ' N�O CADASTRADA - FUNCIONARIO - pol0971'
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
                        ' N�O CADASTRADO - FUNCIONARIO - pol0971'
            RETURN FALSE
         END IF
      END IF
   END IF
		LET p_mat_convert_oper = p_aponta.mat_operador
		LET p_aponta.mat_operador = p_mat_convert_oper
   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0971_consiste_movto()						#Fun��o que faz a compara��o do movmento ega com o movmento 
#--------------------------------#						#do logix se nao estiver o movimento cadastrado ele nao aponta
   
   INITIALIZE p_cod_mov_logix,
              p_aponta_como_boa TO NULL
   
   SELECT UNIQUE 
          cod_mov_logix,
          aponta_como_boa
     INTO p_cod_mov_logix,
          p_aponta_como_boa
     FROM rovmov_ega_man912
    WHERE cod_empresa  = p_cod_empresa
      AND cod_mov_ega  = p_aponta.cod_mov
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'COD. MOVTO:', p_aponta.cod_mov,
                  ' N�O CADASTRADO - RODE POL0968'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol0971_insere_erro()
#-----------------------------#

     INSERT INTO rovapont_erro_man912
      VALUES (p_cod_empresa,
              p_num_ordem,
              p_aponta.cod_operac,
              p_aponta.num_seq_operac,
              m_msg,
              p_aponta.chav_seq,
              'P')

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSAO","rovapont_erro_man912")
   END IF                                           

   UPDATE rovapont_ega_man912
      SET den_erro = m_msg
    WHERE chav_seq = p_aponta.chav_seq
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","rovapont_ega_man912:2208")
   END IF                                           

   UPDATE rovapont_hist_man912
      SET situacao = 'C'
    WHERE chav_seq   = p_aponta.chav_seq
      AND num_versao = p_aponta.num_versao
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","rovapont_hist_man912")
   END IF                                           

   INITIALIZE m_msg TO NULL
   
END FUNCTION
            

#----------------------------------#               
FUNCTION pol0971_ajusta_neces_gem()               
#----------------------------------#               

   DEFINE p_cod_peca_gemea CHAR(15)
   
   LET p_sem_estoque = FALSE
   
   DECLARE cq_pec_gem CURSOR FOR
    SELECT cod_peca_gemea,
           qtd_peca_gemea
      FROM rovpeca_geme_man912
     WHERE cod_empresa    = p_cod_empresa
       AND cod_peca_princ = man_apont.item
     ORDER BY cod_peca_gemea
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","rovpeca_geme_man912")       
      RETURN FALSE
   END IF
   
   FOREACH cq_pec_gem INTO p_cod_peca_gemea, p_qtd_peca_gemea
   
      SELECT SUM(saldo_gemea)
        INTO p_saldo_gemea
        FROM ordens_gemeas
       WHERE num_opp  = p_aponta.num_op
         AND cod_item = p_cod_peca_gemea
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","ordens_gemeas")       
         RETURN FALSE
      END IF
      
      IF p_saldo_gemea IS NULL THEN
         LET p_saldo_gemea = 0
      END IF
      
      LET p_saldo_gemea = p_saldo_gemea / p_qtd_peca_gemea
   
      IF p_saldo_gemea >= p_qtd_prod THEN
         CONTINUE FOREACH
      END IF
      
      LET p_qtd_aumento = (p_qtd_prod - p_saldo_gemea) * p_qtd_peca_gemea
   
      DECLARE cq_neces_gem CURSOR FOR
       SELECT num_opg
         FROM ordens_gemeas
        WHERE cod_item = p_cod_peca_gemea
          AND saldo_gemea > 0
        ORDER BY num_opg DESC
        
      FOREACH cq_neces_gem INTO p_num_ordem

         IF NOT pol0971_ajusta_necessidades() THEN
            RETURN FALSE
         END IF

         UPDATE ordens_gemeas
            SET saldo_gemea = saldo_gemea + p_qtd_aumento
          WHERE num_opg     = p_num_ordem

         EXIT FOREACH

      END FOREACH
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0971_ajusta_necessidades()
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
                     ' S/ ESTOQ  P/ DESLOCAR - pol0971'
         CALL pol0971_insere_erro()
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
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORDENS - pol0971'
      CALL pol0971_insere_erro()
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
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORDENS- pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   INSERT INTO audit_logix
    VALUES(p_cod_empresa, 
           p_texto, 
           'pol0971', 
           TODAY, 
           CURRENT HOUR TO SECOND, 
           p_user)
    
   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' INSERINDO NA AUDIT_LOGIX - pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
           
   UPDATE ord_oper
      SET qtd_planejada = p_planej
    WHERE cod_empresa   = p_cod_empresa
      AND num_ordem     = p_num_ordem

   IF sqlca.sqlcode <> 0 THEN
      LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA ORD_OPER- pol0971'
      CALL pol0971_insere_erro()
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

      IF NOT pol0971_movimenta_estoque() THEN
         RETURN FALSE
      END IF
      
      UPDATE necessidades
         SET qtd_necessaria  = qtd_necessaria + p_qtd_difer
       WHERE cod_empresa     = p_cod_empresa
         AND num_ordem       = p_num_ordem
         AND cod_item        = l_cod_item_compon
           
      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS, ' ATUALIZANDO TABELA NECECIDADES- pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

   END FOREACH
    
   RETURN TRUE


END FUNCTION


#-----------------------------------#
 FUNCTION pol0971_movimenta_estoque()
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
         LET p_qtd_transferir = p_qtd_saldo
      ELSE
         LET p_qtd_transferir = p_qtd_difer
         LET p_qtd_difer = 0
      END IF      

      LET p_novo_saldo = p_novo_saldo - p_qtd_transferir
      LET p_qtd_saldo  = p_qtd_transferir
      
      IF p_novo_saldo = 0 THEN
         IF NOT pol0971_deleta_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0971_atualiza_lote() THEN
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
 FUNCTION pol0971_deleta_lote()
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
      LET m_msg = 'ERRO ',STATUS, ' DELETANDO DA ESTOUQE_LOTE - pol0971'
      CALL pol0971_insere_erro()
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
      LET m_msg = 'ERRO ',STATUS, ' DELETANDO DA ESTOUQE_LOTE_ENDER-pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   IF p_ies_situa_qtd = 'R' THEN
   ELSE
      IF NOT pol0971_atualiza_local_prod() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0971_insere_est_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#------------------------------#
 FUNCTION pol0971_atualiza_lote()
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
         LET m_msg = 'ERRO ',STATUS, ' ATUALISANDO A ESTOUQE_LOTE-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS, ' ATUALISANDO A ESTOUQE_LOTE_ENDER-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE_ENDER-pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

   END IF
   
   IF NOT pol0971_atualiza_local_prod() THEN
      RETURN FALSE
   END IF

   IF NOT pol0971_insere_est_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION        

#--------------------------------------#
FUNCTION  pol0971_atualiza_local_prod()
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
      IF NOT pol0971_insere_local_prod() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0971_altera_local_prod() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION  pol0971_insere_local_prod()
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
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_LOTE-pol0971'
         CALL pol0971_insere_erro()
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
              " ")                                                     

      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_LOTE_ENDER-pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF

      RETURN TRUE
      
END FUNCTION

#-----------------------------------#
FUNCTION  pol0971_altera_local_prod()
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
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE-pol0971'
         CALL pol0971_insere_erro()
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
      LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_LOTE_ENDER-pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0971_insere_est_trans()
#----------------------------------#
   
   DEFINE p_cod_local_dest LIKE estoque_trans.cod_local_est_dest,
          p_num_lote_dest  LIKE estoque_trans.num_lote_dest
   
   INITIALIZE mr_estoque_trans.*, p_cod_operacao TO NULL
   
   LET p_cod_local_dest = m_cod_local_prod
   LET p_num_lote_dest  = p_num_lote
   
   IF p_mov_mat = 'M' THEN   #- transf. mat�ria prima

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


   LET mr_estoque_trans.cod_empresa        = p_cod_empresa
   LET mr_estoque_trans.num_transac        = 0
   LET mr_estoque_trans.cod_item           = l_cod_item_compon 
   LET mr_estoque_trans.dat_movto          = TODAY
   LET mr_estoque_trans.dat_ref_moeda_fort = TODAY
   LET mr_estoque_trans.dat_proces         = TODAY
   LET mr_estoque_trans.hor_operac         = TIME
   LET mr_estoque_trans.ies_tip_movto      = "N"
   LET mr_estoque_trans.cod_operacao       = p_cod_operacao
   LET mr_estoque_trans.num_prog           = "pol0971"
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
      LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_TRANS-pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   LET m_num_transac_orig = SQLCA.SQLERRD[2]

   IF p_tex_observ IS NOT NULL THEN
   
      INSERT INTO estoque_obs
        VALUES(p_cod_empresa, m_num_transac_orig, p_tex_observ)
        
      IF sqlca.sqlcode <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' INSERINDO ESTOQUE_OBS-pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol0971_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF p_mov_mat = 'M' THEN
      IF NOT pol0971_insere_op_lote() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0971_ins_est_trans_end()
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
      LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_TRANS_END-pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, m_num_transac_orig, p_user, TODAY,'pol0971')

  IF SQLCA.SQLCODE <> 0 THEN 
     LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE_AUDITORIA-pol0971'
     CALL pol0971_insere_erro()
     LET p_sem_estoque = TRUE
     RETURN FALSE
  END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
 FUNCTION pol0971_insere_op_lote()
#--------------------------------#

   DEFINE p_row      INTEGER,
          p_endereco LIKE op_lote.endereco
           
   INITIALIZE mr_op_lote.* TO NULL

   IF p_num_lote IS NULL THEN
      SELECT endereco
        INTO p_endereco
        FROM estoque_lote_ender
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item_compon = l_cod_item_compon
         AND cod_local       = m_cod_local_estoq
         AND ies_situa_qtd   = p_ies_situa_qtd
         AND num_lote IS NULL
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO ESTOQUE_LOTE_ENDER-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS,' LENDO OP_LOTE - pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   ELSE   
      SELECT endereco
        INTO p_endereco
        FROM estoque_lote_ender
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item_compon = l_cod_item_compon
         AND cod_local       = m_cod_local_estoq
         AND ies_situa_qtd   = p_ies_situa_qtd
         AND num_lote        = p_num_lote
      IF STATUS <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' LENDO ESTOQUE_LOTE_ENDER-pol0971'
         CALL pol0971_insere_erro()
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
         LET m_msg = 'ERRO ',STATUS,' LENDO OP_LOTE - pol0971'
         CALL pol0971_insere_erro()
         LET p_sem_estoque = TRUE
         RETURN FALSE
      END IF
   END IF

   IF STATUS = 0 THEN         
      UPDATE op_lote
         SET qtd_transf = qtd_transf + p_qtd_saldo
       WHERE rowid = p_row
      IF SQLCA.SQLCODE <> 0 THEN
         LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO OP_LOTE - pol0971'
         CALL pol0971_insere_erro()
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
      LET m_msg = 'ERRO ',STATUS,' INSERINDO NA OP_LOTE - pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0971_tira_das_boas()
#------------------------------#

   LET p_tex_observ = NULL

   SELECT UNIQUE 
          cod_mov_logix
     INTO p_cod_mov_logix
     FROM rovmov_ega_man912
    WHERE cod_empresa  = p_cod_empresa
      AND cod_mov_ega  = p_aponta.cod_mov

   IF sqlca.sqlcode <> 0 THEN
   ELSE
      SELECT des_parada
        INTO p_den_parada
        FROM cfp_para
       WHERE cod_empresa = p_cod_empresa
         AND cod_parada  = p_cod_mov_logix
      
      IF STATUS = 0 THEN
         LET p_tex_observ = p_cod_mov_logix," - ",p_den_parada
      END IF
   END IF

   LET p_tip_peca = 'P'
   LET p_num_lote        = p_num_lote_op
   LET l_cod_item_compon = p_aponta.cod_item
   LET p_qtd_saldo       = p_aponta.qtd_refugo
   LET p_mov_mat         = 'P'
   LET p_ies_situa_qtd   = 'L'
   LET p_ies_situa_dest  = 'R'
   LET m_cod_local_prod  = m_cod_local_estoq
   
   IF NOT pol0971_tem_estoque() THEN
      RETURN TRUE
   END IF

   LET p_novo_saldo = p_saldo - p_qtd_saldo
   
       #se for tratar rejei��o de gemeas, vide
       #bloco comentado no fim do programa
   
   IF NOT pol0971_troca_sit_estoq() THEN
      RETURN FALSE
   END IF

   IF p_ies_baixa_pc_rej <> 'S' THEN
      RETURN TRUE
   END IF

   LET p_ies_situa_qtd  = 'R'

   IF NOT pol0971_tem_estoque() THEN
      RETURN TRUE
   END IF

   LET p_novo_saldo  = p_saldo - p_qtd_saldo

   IF NOT pol0971_troca_sit_estoq() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0971_troca_sit_estoq()
#---------------------------------#

   IF p_saldo = p_qtd_saldo THEN
      IF NOT pol0971_deleta_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0971_atualiza_lote() THEN
         RETURN FALSE
      END IF
   END IF   

   IF p_ies_situa_qtd  = 'R' THEN
      UPDATE estoque
         SET qtd_rejeitada = qtd_rejeitada - p_qtd_saldo
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item_compon
   ELSE
      UPDATE estoque
         SET qtd_liberada  = qtd_liberada  - p_qtd_saldo,
             qtd_rejeitada = qtd_rejeitada + p_qtd_saldo
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = l_cod_item_compon
   END IF
   
   IF STATUS <> 0 THEN
      LET m_msg = 'ERRO ',STATUS,' ATUALIZANDO ESTOQUE-pol0971'
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0971_tem_estoque()      
#-----------------------------#
  
   LET p_sem_estoque = FALSE
   
   IF p_num_lote_op IS NOT NULL THEN
      SELECT qtd_saldo
        INTO p_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_aponta.cod_item
         AND cod_local     = m_cod_local_estoq
         AND num_lote      = p_num_lote_op
         AND ies_situa_qtd = p_ies_situa_qtd
         AND qtd_saldo     > 0
    ELSE
      SELECT qtd_saldo
        INTO p_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_aponta.cod_item
         AND cod_local     = m_cod_local_estoq
         AND ies_situa_qtd = p_ies_situa_qtd
         AND qtd_saldo     > 0
         AND num_lote IS NULL
   END IF
         
    IF SQLCA.sqlcode = NOTFOUND THEN
       LET p_saldo = 0
    END IF

   IF p_ies_situa_qtd = 'R' THEN
      RETURN TRUE
   END IF
   
   IF p_num_lote_op IS NOT NULL THEN
      SELECT SUM(qtd_reservada - qtd_atendida)
        INTO p_qtd_reservada
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_aponta.cod_item
         AND cod_local   = m_cod_local_estoq
         AND num_lote    = p_num_lote_op
   ELSE
      SELECT SUM(qtd_reservada - qtd_atendida)
        INTO p_qtd_reservada
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_aponta.cod_item
         AND cod_local   = m_cod_local_estoq
         AND num_lote IS NULL
   END IF
   
   IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
      LET p_qtd_reservada = 0
   END IF
       
   IF p_saldo > p_qtd_reservada THEN
      LET p_saldo_disp = p_saldo - p_qtd_reservada
   ELSE
      LET p_saldo_disp = 0
   END IF
   
   IF p_saldo_disp < p_aponta.qtd_refugo THEN
      IF p_tip_peca = 'G' THEN
         LET m_msg = 'PECA GEMEA ',p_aponta.cod_item CLIPPED,
                     ' S/ ESTOQ-TRASNF.BOA P/REFUGO-pol0971'
      ELSE         
         LET m_msg = 'PECA ',p_aponta.cod_item CLIPPED,
                     ' S/ ESTOQ-TRASNF.BOA P/ REFUGO - pol0971'
      END IF
      CALL pol0971_insere_erro()
      LET p_sem_estoque = TRUE
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
#----------------------------#
 FUNCTION pol0971_w_defeito()#
#----------------------------#
	WHENEVER ERROR CONTINUE 
	DROP TABLE w_defeito
	CREATE TEMP TABLE w_defeito(
				cod_defeito		DECIMAL(3,0),
				qtd_refugo		DECIMAL(3,0)
		)
	WHENEVER ERROR STOP 
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 
END FUNCTION 
#---------------------------#
 FUNCTION pol0971_w_parada()#
#---------------------------#
	WHENEVER ERROR CONTINUE 
	DROP TABLE w_parada
	CREATE TEMP TABLE w_parada (
				cod_parada char(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO MINUTE,
				hor_fim_periodo 			DATETIME HOUR TO MINUTE,
				hor_tot_periodo 			DECIMAL(7,2)
		)
	WHENEVER ERROR STOP 
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN FALSE
	ELSE 
		RETURN TRUE
	END IF 
END FUNCTION 
#------------------------#
FUNCTION pol0971_aponta()
#------------------------#
DEFINE l_houve_erro						SMALLINT,
				l_hor_ini_periodo 		CHAR(08), 
				l_hor_fim_periodo 		CHAR(08),
			  l_dat_ini_par 				CHAR(08),
				l_dat_fim_par					CHAR(10),
				l_hora								CHAR(10),
				l_teste								INTEGER,
				l_rowid								DECIMAL(15,0)
				
				
				
DEFINE p_w_apont_prod RECORD 													#Foi criado essas registro local pois ele so vai ser
				cod_empresa CHAR(2), 													#usado aqui para receber os dados da tabela rovman_apont_912
				cod_item CHAR(15), 														#para serem apontados
				num_ordem INTEGER, 
				num_docum CHAR(10), 
				cod_roteiro CHAR(15), 
				num_altern DEC(2,0), 
				cod_operacao CHAR(5), 
				num_seq_operac DEC(3,0), 
				cod_cent_trab CHAR(5), 
				cod_arranjo CHAR(5), 
				cod_equip CHAR(15), 
				cod_ferram CHAR(15), 
				num_operador CHAR(15), 
				num_lote CHAR(15), 
				hor_ini_periodo DATETIME HOUR TO MINUTE, 
				hor_fim_periodo DATETIME HOUR TO MINUTE, 
				cod_turno DEC(3,0), 
				qtd_boas DEC(10,3), 
				qtd_refug DEC(10,3), 
				qtd_total_horas DECIMAL(10,2), 
				cod_local CHAR(10), 
				cod_local_est CHAR(10), 
				dat_producao DATE, 
				dat_ini_prod DATE, 
				dat_fim_prod DATE, 
				cod_tip_movto CHAR(1), 
				efetua_estorno_total CHAR(1), 
				ies_parada SMALLINT, 
				ies_defeito SMALLINT, 
				ies_sucata SMALLINT, 
				ies_equip_min CHAR(1), 
				ies_ferram_min CHAR(1), 
				ies_sit_qtd CHAR(1), 
				ies_apontamento CHAR(1), 
				tex_apont CHAR(255), 
				num_secao_requis CHAR(10), 
				num_conta_ent CHAR(23), 
				num_conta_saida CHAR(23), 
				num_programa CHAR(8), 
				nom_usuario CHAR(8), 
				num_seq_registro INTEGER, 
				observacao CHAR(200), 
				cod_item_grade1 CHAR(15), 
				cod_item_grade2 CHAR(15), 
				cod_item_grade3 CHAR(15), 
				cod_item_grade4 CHAR(15), 
				cod_item_grade5 CHAR(15), 
				qtd_refug_ant DECIMAL(10,3), 
				qtd_boas_ant DECIMAL(10,3), 
				tip_servico CHAR(1), 
				abre_transacao SMALLINT,
				modo_exibicao_msg SMALLINT, 
				seq_reg_integra INTEGER, 
				endereco INTEGER, 
				identif_estoque CHAR(30), 
				sku CHAR(25),
				finaliza_operacao CHAR(1)
END RECORD
DEFINE p_w_parada RECORD
				cod_parada 						CHAR(03),
				dat_ini_parada   			DATE,
				dat_fim_parada 				DATE,
				hor_ini_periodo 			DATETIME HOUR TO SECOND ,
				hor_fim_periodo 			DATETIME HOUR TO SECOND,
				hor_tot_periodo 			DECIMAL(7,2)
END RECORD 

DEFINE p_rovapont_erro_man912 RECORD 
    empresa            char(2) ,
    ordem_producao     integer  ,
    operacao           char(9),
    sequencia_operacao decimal(3,0),
    texto_erro         char(250),
    chav_seq           integer,
    ies_apont          char(01)
END RECORD

   DELETE FROM rovman_apont_erro_912
    WHERE empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELE��O","rovman_apont_erro_912")
      RETURN
   END IF
   
   DISPLAY "Aguarde... efetuando o apontamento !!!" AT 16,15
  
   DECLARE cq_apont SCROLL CURSOR WITH HOLD FOR 	
    SELECT	EMPRESA,ITEM,ORDEM_PRODUCAO,OPERACAO,SEQUENCIA_OPERACAO,CENTRO_TRABALHO,
						TURNO,ARRANJO,EQPTO,FERRAMENTA,HOR_INICIAL,HOR_FIM,QTD_REFUGO,QTD_BOAS,
						QTD_HOR,LOCAL,DAT_INI_PRODUCAO,DAT_FIM_PRODUCAO,TIP_MOVTO,MATRICULA,
						To_Char(hor_ini_parada,'%T'),
						To_Char(HOR_FIM_PARADA,'%T'), PARADA ,TERMINADO, ROWID
			FROM rovman_apont_454
     WHERE empresa = p_cod_empresa
      AND (dat_atualiz IS NULL OR dat_atualiz = ' ')			
		 ORDER BY ORDEM_PRODUCAO,SEQUENCIA_OPERACAO, TERMINADO

	 FOREACH cq_apont INTO 	p_w_apont_prod.cod_empresa,
	 												p_w_apont_prod.cod_item,
	 												p_w_apont_prod.num_ordem,
	 												p_w_apont_prod.cod_operacao ,
	 												p_w_apont_prod.num_seq_operac,
	 												p_w_apont_prod.cod_cent_trab ,
	 												p_w_apont_prod.cod_turno ,
	 												p_w_apont_prod.cod_arranjo ,
	 												p_w_apont_prod.cod_equip ,
	 												p_w_apont_prod.cod_ferram ,
	 												p_w_apont_prod.hor_ini_periodo ,#l_hor_ini_periodo, #p_w_apont_prod.hor_ini_periodo ,
													p_w_apont_prod.hor_fim_periodo,#l_hor_fim_periodo, # ,
	 												p_w_apont_prod.qtd_refug ,
													p_w_apont_prod.qtd_boas ,
													p_w_apont_prod.qtd_total_horas ,
													p_w_apont_prod.cod_local ,
													p_w_apont_prod.dat_ini_prod ,#l_dat_ini_producao, #
													p_w_apont_prod.dat_fim_prod ,#l_dat_fim_producao, #
													p_w_apont_prod.cod_tip_movto ,
													p_w_apont_prod.num_operador ,
													p_w_parada.hor_ini_periodo,#l_hora_ini_par, #	
	 												p_w_parada.hor_fim_periodo,#l_hora_fim_par, # 
	 												p_w_parada.cod_parada,
	 												p_w_apont_prod.finaliza_operacao,
	 												l_rowid

   	  IF SQLCA.SQLCODE<> 0 THEN
	 	     CALL log003_err_sql("SELECT","rovman_apont_454" )
	    END IF 
			
			SELECT COD_LOCAL_ESTOQ, NUM_DOCUM, COD_ROTEIRO, NUM_ALTERN_ROTEIRO, ies_situa
			INTO p_w_apont_prod.cod_local_est,
					 p_w_apont_prod.num_docum,
					 p_w_apont_prod.cod_roteiro,
					 p_w_apont_prod.num_altern,
					 p_ies_situa
			FROM ORDENS
			WHERE COD_EMPRESA = p_cod_empresa
			AND NUM_ORDEM 		= p_w_apont_prod.num_ordem
			AND COD_ITEM 			= p_w_apont_prod.cod_item
			
			IF p_ies_situa <> '4' THEN
			   DELETE FROM rovman_apont_454
			    WHERE rowid = l_rowid
			    CONTINUE FOREACH
			END IF
			 
			IF LENGTH(p_w_apont_prod.cod_cent_trab) = 0 THEN 
				LET p_w_apont_prod.cod_cent_trab = 0
			END IF 
			IF LENGTH(p_w_apont_prod.cod_arranjo) = 0 THEN 
				LET p_w_apont_prod.cod_arranjo = 0
			END IF 
			
			IF LENGTH(p_w_apont_prod.cod_ferram) = 0 OR  p_w_apont_prod.cod_ferram IS NULL 
				OR p_w_apont_prod.cod_ferram= "0" THEN 
				LET p_w_apont_prod.cod_ferram = 0
				LET p_w_apont_prod.ies_ferram_min =  "N"
			ELSE 
					LET p_w_apont_prod.ies_ferram_min =  "S"
			END IF 				
			
			IF LENGTH(p_w_apont_prod.cod_equip)>0 OR p_w_apont_prod.cod_equip IS NOT NULL 
				OR p_w_apont_prod.cod_equip <> "0" THEN
				LET p_w_apont_prod.ies_equip_min = "S"
			ELSE
				LET p_w_apont_prod.ies_equip_min = "N"			 
			END IF 
			
			LET p_w_apont_prod.num_lote 						= NULL
			
			LET p_w_apont_prod.dat_producao 				=	p_w_apont_prod.dat_ini_prod
			
			DECLARE cq_funcio CURSOR FOR SELECT COD_UNI_FUNCIO FROM UNIDADE_FUNCIONAL A, ORD_OPER B
																		WHERE A.COD_EMPRESA = B.COD_EMPRESA
																		AND A.COD_CENTRO_CUSTO = B.COD_CENT_CUST
																		AND B.num_ordeM    =  p_w_apont_prod.num_ordem
																		AND B.cod_operac     = p_w_apont_prod.cod_operacao
																		AND B.num_seq_operac = p_w_apont_prod.num_seq_operac
																		
			FOREACH cq_funcio INTO p_w_apont_prod.num_secao_requis 
					IF p_w_apont_prod.cod_cent_trab IS NOT NULL THEN
						EXIT FOREACH
					END IF 
			END FOREACH
			
			LET p_w_apont_prod.efetua_estorno_total = "N"
			IF (p_w_parada.hor_fim_periodo IS NOT NULL) AND (p_w_parada.hor_ini_periodo IS NOT NULL) 
			 AND (p_w_parada.cod_parada IS NOT NULL) THEN 
				LET p_w_apont_prod.ies_parada						= 1
				LET	p_w_parada.dat_ini_parada						= p_w_apont_prod.dat_ini_prod
				LET	p_w_parada.dat_fim_parada						= p_w_apont_prod.dat_ini_prod
				######################################
				#se for parada estou colocando a hora 
				#do apontamento igual a hora da parada
				#aqui nesse local
				#######################################
				LET p_w_apont_prod.hor_ini_periodo = p_w_parada.hor_ini_periodo
				LET p_w_apont_prod.hor_fim_periodo = p_w_parada.hor_fim_periodo
				
				#LET l_hora = '24:00:00' - (p_w_parada.hor_fim_periodo - p_w_parada.hor_ini_periodo)
				LET p_w_parada.hor_tot_periodo = p_w_apont_prod.qtd_total_horas 
				#LET p_w_parada.hor_tot_periodo			=	((l_hora[1,2])+ (l_hora[4,5]/60)+(l_hora[7,8]/360))
			ELSE
				LET p_w_apont_prod.ies_parada						= 0
			END IF
			
			IF p_w_apont_prod.qtd_refug > 0 THEN 
				LET p_w_apont_prod.ies_defeito 					=	1
			ELSE
				LET p_w_apont_prod.ies_defeito 					=	0
			END IF 
			
			LET p_w_apont_prod.ies_sucata 					= 0
			LET p_w_apont_prod.ies_sit_qtd 					=	'L'
			LET p_w_apont_prod.ies_apontamento 			= '1'	
			LET p_w_apont_prod.num_conta_ent				= NULL
			LET p_w_apont_prod.num_conta_saida 			= NULL
			LET p_w_apont_prod.num_programa 				= 'POL0971'
			LET p_w_apont_prod.nom_usuario 					= p_user
			LET p_w_apont_prod.cod_item_grade1 			= NULL
			LET p_w_apont_prod.cod_item_grade2 			= NULL
			LET p_w_apont_prod.cod_item_grade3 			= NULL
			LET p_w_apont_prod.cod_item_grade4 			= NULL
			LET p_w_apont_prod.cod_item_grade5 			= NULL
			LET p_w_apont_prod.qtd_refug_ant 				= NULL
			LET p_w_apont_prod.qtd_boas_ant 				= NULL
			LET p_w_apont_prod.abre_transacao 			= 1
			LET p_w_apont_prod.modo_exibicao_msg 		= 0
			LET p_w_apont_prod.seq_reg_integra 			= NULL
			LET p_w_apont_prod.endereco 						= ' '
			LET p_w_apont_prod.identif_estoque 			= ' '
			LET p_w_apont_prod.sku 									= ' ' 
			
	 	IF manr24_cria_w_apont_prod(0)  THEN 
	 		CALL man8246_cria_temp_fifo()
	 		CALL man8237_cria_tables_man8237()
	 	
	 		IF manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN # incuindo apontamento
	 			
	 			IF p_w_apont_prod.ies_defeito = 1  THEN #apontando defeitos
		 			IF pol0971_w_defeito() THEN 
		 				INSERT INTO w_defeito VALUES('01',p_w_apont_prod.qtd_refug)
		 			END IF 
		 		END IF 
	 			
	 			IF pol0971_w_parada() THEN				#apontando parada
	 			 	IF p_w_parada.cod_parada IS NOT NULL OR  p_w_parada.cod_parada = 0 THEN 
		 				WHENEVER ERROR CONTINUE
		 					INSERT INTO w_parada VALUES (p_w_parada.*)
		 					IF SQLCA.SQLCODE <> 0 THEN 
								CALL log003_err_sql('inserir','w_parada')
							END IF 
		 				WHENEVER ERROR STOP
		 			END IF 
	 			END IF 
				
	 			IF NOT manr27_processa_apontamento(p_w_apont_prod.*)  THEN #processando parada
	 				LET l_houve_erro = TRUE 
	 			ELSE  
	 			
	 				UPDATE rovman_apont_454
	 				SET dat_atualiz = TODAY 
	 				WHERE rowid = l_rowid
	 			END IF 
	 		ELSE
	 			LET l_houve_erro = TRUE 
	 		END IF
	 		LET l_houve_erro = TRUE
	 	END IF 
	 		 		
		 	DECLARE cq_erro CURSOR FOR 	SELECT empresa,ordem_producao,operacao,texto_resumo  	#varre a tabela em busca 
		 															FROM MAN_LOG_APO_PROD																	#os erros do apontameto
		  FOREACH cq_erro INTO 	p_rovapont_erro_man912.empresa,															#e grava na rovapont_erro_man912
		  											p_rovapont_erro_man912.ordem_producao,
		  											p_rovapont_erro_man912.operacao,
		  											p_rovapont_erro_man912.texto_erro
		  	LET p_rovapont_erro_man912.sequencia_operacao = p_w_apont_prod.num_seq_operac
		  	LET p_rovapont_erro_man912.chav_seq = l_rowid
		  	LET p_rovapont_erro_man912.ies_apont = 'F'
		  	INSERT INTO rovapont_erro_man912 VALUES (p_rovapont_erro_man912.*)
		  END FOREACH
			IF STATUS <> 0 THEN
	      CALL log003_err_sql("INCLUS�O","rovapont_erro_man912")
	    ELSE 
      END IF 

	 		LET l_houve_erro = FALSE  					#ele entra na rotina
 																		
	END FOREACH
  

END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#

   #--- Uma pe�a gemea pode ter n OP's e isso teria gerado
   #--- n lotes diferentes no estoque. Se precisar apontar
   #--- refugos em OP's de pe�as gemeas, de qual lote/OP eu
   #--- tiraria das boas????? Manuel pediu p/ n�o apontar.
   {   
   IF p_tem_gemea THEN
      
      LET princ_cod_item  = p_aponta.cod_item
      LET princ_num_op    = p_aponta.num_op
      LET princ_cod_local = m_cod_local_estoq
      LET princ_num_lote  = p_num_lote_op
      LET princ_saldo     = p_saldo
      LET p_tot_apontar  = p_qtd_prod
    
      DECLARE cq_pec_gemea CURSOR FOR
       SELECT cod_peca_gemea,
              qtd_peca_gemea
         FROM rovrovpeca_geme_man912
        WHERE cod_empresa    = p_cod_empresa
          AND cod_peca_princ = princ_cod_item
        ORDER BY cod_peca_gemea
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","rovrovpeca_geme_man912")       
         RETURN FALSE
      END IF
   
      FOREACH cq_pec_gemea INTO p_cod_peca_gemea, p_qtd_peca_gemea

         LET p_qtd_prod = p_qtd_prod * p_qtd_peca_gemea

         DECLARE cq_opg CURSOR FOR
          SELECT num_opg, 
            FROM ordens_gemeas
           WHERE num_opp  = p_aponta.num_op
             AND cod_item = p_cod_peca_gemea

         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","ordens_gemeas")       
            RETURN FALSE
         END IF

         FOREACH cq_opg INTO p_num_opg
                 
            LET p_aponta.cod_item = p_cod_peca_gemea
            LET p_aponta.num_op = p_num_opg
            EXIT FOREACH
            
         END FOREACH
      
         SELECT num_lote,
                cod_local_estoq
           INTO p_num_lote_op,
                m_cod_local_estoq
           FROM ordens
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_aponta.num_op
         
         LET p_tip_peca = 'G'
         
         IF NOT pol0971_tem_estoque() THEN
            RETURN TRUE
         END IF
      
         IF NOT pol0971_troca_sit_estoq() THEN
            RETURN FALSE
         END IF

      END FOREACH
           
      LET p_aponta.cod_item = princ_cod_item
      LET p_aponta.num_op   = princ_num_op    
      LET m_cod_local_estoq = princ_cod_local 
      LET p_num_lote_op     = princ_num_lote
      LET p_saldo           = princ_saldo
      LET p_qtd_prod        = p_tot_apontar
     
   END IF
   }