#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1157 - MAPA DE SUPRIMENTOS                           #
# OBJETIVO: CANCELAR OU ADICIONAR ORDENS DE COMPRA                  #
# AUTOR...: IVO BL                                                  #
# DATA....: 19/07/2012                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_critica_demis      INTEGER,
          p_linha              DECIMAL(2,0),
          p_men                CHAR(500),
          p_ies_status_oc      CHAR(01),
          p_checa_trava        CHAR(01),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
		      p_ind1               SMALLINT,
          s_ind1               SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_caminho            CHAR(080),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_cpf                CHAR(14),
          p_cod_bco            DECIMAL(3,0),
          p_ano_mes_demis      CHAR(07),
          p_ies_emite_dupl     CHAR (01),
          p_query              CHAR (800),
          comando              CHAR(80),
		      p_chave_processo 	   DEC(12,0),
		      w_cod_item        CHAR(15),
          w_cod_itema          CHAR(15),
          w_den_item           CHAR(40),
          p_index1              SMALLINT,
          s_index1              SMALLINT,
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT,
          p_travou             SMALLINT,
          p_item               CHAR(15)

   DEFINE p_cod_item           CHAR(15),
          p_seq_campo          INTEGER,
          p_sdo_oc             INTEGER,
          p_cod_frequencia     CHAR(01),
          p_qtd_lote_multiplo  INTEGER,
          p_seq_periodo        SMALLINT,
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_num_oc             INTEGER, 
          p_num_versao         INTEGER, 
          p_ies_situa          CHAR(01),
          p_ies_situa_prg      CHAR(01),				  # MANUEL2 04-10-2012
          p_nova_situa         CHAR(01),
          p_nova_situa_prg     CHAR(01),				  # MANUEL 04-10-2012
		      p_num_prog_entrega   DEC(3,0), 
          p_qtd_ajust          INTEGER,
          p_qtd_cancel         INTEGER,
          p_id_registro        INTEGER,
          p_qtd_sdo_oc         INTEGER,
          p_qtd_alterada       INTEGER,
          p_qtd_backup         INTEGER,
          p_ta_travada         SMALLINT,
          p_tip_ajuste         CHAR(01),
          p_dat_proces         DATETIME YEAR TO SECOND,
          p_qtd_proces         INTEGER,
          p_dat_entrega        DATE,
          p_qtd_linha          INTEGER,
          p_ocs                CHAR(30),
          p_txt_oc             CHAR(09),
          p_den_item           CHAR(76),
          p_cod_lin_prod       INTEGER,
          p_cod_lin_recei      INTEGER,   
          p_cod_seg_merc       INTEGER, 
          p_cod_cla_uso        INTEGER,
          p_den_estr_linprod   CHAR(40),
          p_seq_prog           INTEGER,
          p_multi_programacao  SMALLINT,
          p_ies_atu_hist       SMALLINT,
          p_tem_critica        SMALLINT,
          p_ies_situa_oc       CHAR(01),
          p_dat_prev           DATE,
          p_qtd_ajuste         DECIMAL(10,3),
          p_situacao           CHAR(01),
          p_id_prog_ord        INTEGER

          
   DEFINE pr_item      ARRAY[3000] OF RECORD
          cod_item     CHAR(15),
          den_item     CHAR(18),
          ies_alt      CHAR(01),
          seq_periodo  INTEGER,
          sdo_oc       INTEGER, 
          qtd_suger    INTEGER, 
		      qtd_realiz   INTEGER, 
          qtd_ajust    INTEGER, 
          cod_oper     CHAR(01)  
   END RECORD

   DEFINE pr_compl      ARRAY[3000] OF RECORD
          dat_entrega  DATE,
          id_registro  INTEGER,
          sdo_corte    INTEGER
   END RECORD

   DEFINE pr_itens  ARRAY[200] OF RECORD
          codigo    CHAR(15),
          tipo      CHAR(01),
          descricao CHAR(18)
   END RECORD        

   DEFINE pr_periodo   ARRAY[17] OF RECORD
          seq_periodo  INTEGER,
          periodo      CHAR(20),
          sel_periodo  CHAR(01)
   END RECORD        
   
   DEFINE p_tela        RECORD
          sel_item      CHAR(01),
          item_de       CHAR(15),
          item_ate      CHAR(15),
          cod_item      CHAR(15),
          ies_ajustado  CHAR(01),
          sel_periodo   CHAR(01),
          dat_limite    DATE,
          cod_lin_prod  DECIMAL(2,0)
   END RECORD          

   DEFINE pr_men        ARRAY[1] OF RECORD    
          mensagem      CHAR(50)
   END RECORD
   
   DEFINE p_mapa              RECORD LIKE mapa_compras_data_454.*

   DEFINE p_item_man          RECORD LIKE item_man.*,
          p_ordem_sup         RECORD LIKE ordem_sup.*,
          p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*,
          p_dest_ordem_sup    RECORD LIKE dest_ordem_sup.*,
          p_estr_ordem_sup    RECORD LIKE estrut_ordem_sup.*

   DEFINE m_cod_comprador      LIKE item_sup.cod_comprador,
          m_cod_progr          LIKE item_sup.cod_progr,
          m_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
          m_num_conta          LIKE item_sup.num_conta,
          m_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
          m_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
          m_ies_tip_incid_ipi  LIKE item_sup.ies_tip_incid_ipi,
          m_cod_fiscal         LIKE item_sup.cod_fiscal,
          m_pct_ipi            LIKE item.pct_ipi,
          m_cod_unid_med       LIKE item.cod_unid_med,
          p_cod_horizon        LIKE item_man.cod_horizon,
          p_qtd_dias           LIKE horizonte.qtd_dias_horizon,
          m_prx_num_oc         LIKE par_sup.prx_num_oc,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_lote_minimo    LIKE item_sup.qtd_lote_minimo,
          p_qtd_solic          LIKE prog_ordem_sup.qtd_solic,
          p_dat_origem         LIKE prog_ordem_sup.dat_origem,
          p_data_processamento LIKE mapa_dias_mes_454.data_processamento
 
   DEFINE p_par_lst            RECORD
          chave_processo       DECIMAL(12,0),
          dat_ini              DATE, 
          dat_fim              DATE,
          item_de              CHAR(15),
          item_ate             CHAR(15),
          cod_item             CHAR(15),
          ajuste_efetuado      CHAR(01),
          cod_lin_prod         DECIMAL(2,0),
          tip_ajuste           CHAR(01),
          oc_sem_pc            CHAR(01)
   END RECORD

   DEFINE p_relat             RECORD
          chave_processo      CHAR(12),
          cod_item            CHAR(15),
          seq_campo           CHAR(02),
          seq_periodo         CHAR(02),
          qtd_dia             DECIMAL(10,3),
          qtd_ajustada        DECIMAL(10,3),
          dat_entrega         CHAR(10),
          tip_ajuste          CHAR(01),
          dat_ini_periodo     DATE,
          dat_fim_periodo     DATE,
          usuario             CHAR(08),
          dat_proces          CHAR(19),
          num_ocs             CHAR(30),
          num_pedido          CHAR(06)
   END RECORD 
   
   DEFINE pr_txt      ARRAY[15] OF RECORD
          texto       CHAR(60)
   END RECORD
   
END GLOBALS

DEFINE p_parametro         RECORD
       cod_empresa         LIKE ordem_sup.cod_empresa,
       num_oc              LIKE ordem_sup.num_oc,
       nom_programa        CHAR(08),
       dat_programacao     DATE,
       qtd_ajuste          DECIMAL(10,3),
       seq_periodo         INTEGER,
       chave_processo      DECIMAL(12,0),
       id_prog_ord         INTEGER
END RECORD


   DEFINE p_add           RECORD
          chave_processo  CHAR(12),
          cod_item        CHAR(12),
          den_item        CHAR(18),
          seq_periodo     INTEGER,
          seq_campo       INTEGER,
          den_campo       CHAR(10)
   END RECORD

   DEFINE p_calc        RECORD
          qtd_ajuste    INTEGER,
          lote_multiplo INTEGER,
          dat_ini       date,    
          dat_fim       date
   END RECORD
   
  DEFINE pr_prog ARRAY[500] of record
         dat_prog date,             
         qtd_prog INTEGER            
  END RECORD

   DEFINE pr_critica ARRAY[1000] OF RECORD
      processo      DECIMAL(12,0),
      cod_item      CHAR(15),         
      seq_periodo   INTEGER,
      num_oc        INTEGER,
      ies_situa_oc  CHAR(01),
      programacao   DATE,
      qtd_ajust     INTEGER,
      oc_alterada   CHAR(03),
      reverter      CHAR(01)
   END RECORD

   DEFINE pr_id     ARRAY[1000] OF RECORD
      id_prog_ord   INTEGER
   END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol1157-10.02.78"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '21'
   #LET p_status = 0
   #LET p_user = 'admlog'
   
   IF p_status = 0 THEN
      CALL pol1157_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1157_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1157") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1157 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1157_limpa_tela()

   IF NOT pol1157_cria_temp() THEN
      RETURN
   END IF

   MENU "OPCAO"
      {COMMAND "Simulação diária" "Simulação da programação diária"
         CALL pol1157_limpa_tela()
         CALL pol1157_simular()}
      COMMAND "Adicionar" "Adiciona programação no mapa"
         CALL pol1157_limpa_tela()
         IF NOT pol1157_adicionar() THEN
            ERROR 'Operação cancelada!'
         ELSE
            ERROR 'Operação efetuada com sucesso!'
         END IF
      COMMAND "Informar" "Informar parâmetros p/ o processamento"
      CALL pol1157_limpa_tela()
      IF pol1157_verifica_bi()  THEN	 
			   CALL pol1157_informar() RETURNING p_ies_cons
			    CURRENT WINDOW IS w_pol1157
			   IF p_ies_cons THEN
				    ERROR 'Parâmetros informados com sucesso!'
				    NEXT OPTION "Processar"
			   ELSE
				    ERROR 'Operação cancelada !!!'
			   END IF 
		  ELSE
			   ERROR 'Ajuste não permitido, planilha BI não concluída.'
		  END IF 
      COMMAND "Processar" "Processa a operação de corte ou acréscimo de OC"
         IF p_ies_cons THEN
            CALL pol1157_processar() RETURNING p_status
            CLOSE WINDOW w_pol11573      
            CURRENT WINDOW IS w_pol1157
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso!'
               IF p_tem_critica THEN
                  LET p_opcao = 'P'
                  CALL pol1157_exibe_criticas() RETURNING p_status
               END IF
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF 
            NEXT OPTION "Fim"
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION "Informar"
         END IF
         LET p_ies_cons = FALSE
      COMMAND "Histórico" "Acesso aos acertos efetuados em processos anteriores"
         CALL pol1157_historico()
      COMMAND KEY ("V") "Observação" "Acesso às observações por item ou geral"
         IF pol1157_verifica_bi()  THEN	 
			      CALL pol1157_observacao()
		     ELSE
			      ERROR 'Manurtenção de observações não permitida, planilha BI não concluída.'
		     END IF  
      COMMAND "Criticas" "Exibe criticas do processamento"
         LET p_opcao = 'C'
         CALL pol1157_exibe_criticas() RETURNING p_status
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1157_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol1157

END FUNCTION


#-----------------------#
 FUNCTION pol1157_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------#
FUNCTION pol1157_exibe_criticas()#
#--------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1157b") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1157b AT 3,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol1157_le_criticas() RETURNING p_status
   
   CLOSE WINDOW w_pol1157b
   
   RETURN p_status

END FUNCTION
   
#-----------------------------#
FUNCTION pol1157_le_criticas()#
#-----------------------------#

   DEFINE pr_mensagem ARRAY[1000] OF RECORD
          mensagem CHAR(240)
   END RECORD
   
   DEFINE p_mensagem   CHAR(240),
          p_processo   DECIMAL(12,2),
          p_sit_oc     CHAR(01)

   INITIALIZE p_item, p_linha, pr_critica, pr_id TO NULL

   IF p_opcao = 'C' THEN
      SELECT MAX(chave_processo) 
		    INTO p_chave_processo
		    FROM item_criticado_bi_454
		    WHERE cod_empresa = p_cod_empresa
		
		   IF STATUS <> 0 THEN
          LET p_chave_processo = NULL
       END IF
   END IF
          
   INPUT p_chave_processo, p_linha, p_item WITHOUT DEFAULTS
      FROM num_proces, linha, item
          
          AFTER FIELD linha
             
             IF p_linha IS NOT NULL THEN
                SELECT den_estr_linprod
                  INTO p_den_estr_linprod
                  FROM linha_prod
                 WHERE cod_lin_prod = p_linha 
                   AND cod_lin_recei = 0
                   AND cod_seg_merc = 0
                   AND cod_cla_uso = 0

	              if STATUS <> 0 then
	                 call log003_err_sql('Lendo','linha_prod')
	                 NEXT FIELD linha
	              end IF
	              DISPLAY p_den_estr_linprod TO den_linha
	           END IF

          AFTER FIELD item
             
             IF p_item IS NOT NULL THEN
                SELECT den_item_reduz
                  INTO p_den_item
                  FROM item
                 WHERE cod_empresa = p_cod_empresa
                   AND cod_item = p_item

	              IF STATUS <> 0 then
	                 call log003_err_sql('Lendo','item')
	                 NEXT FIELD item
	              END IF
	              DISPLAY p_den_item TO den_item_reduz
	           END IF
       
          ON KEY (control-z)
             CALL pol1157_popup()
             
   END INPUT
   
   LET p_ind = 1
   
   LET p_query = 
    "SELECT chave_processo, cod_item, seq_periodo, num_oc, ",
           "mensagem, id_prog_ord ",  
     " FROM item_criticado_bi_454 ",
     "WHERE cod_empresa = '",p_cod_empresa,"' "
   
   IF p_chave_processo IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND chave_processo = ", p_chave_processo
   END IF

   IF p_linha IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_lin_prod = ", p_linha
   END IF

   IF p_item IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND cod_item = '",p_item,"' "
   END IF   
   
   LET p_query = p_query CLIPPED, " ORDER BY chave_processo DESC, cod_item, seq_periodo "
   
   PREPARE selec FROM p_query    
   DECLARE cq_critica CURSOR FOR selec

   FOREACH cq_critica INTO
     pr_critica[p_ind].processo,     
     pr_critica[p_ind].cod_item,     
     pr_critica[p_ind].seq_periodo,  
     pr_critica[p_ind].num_oc,       
     pr_mensagem[p_ind].mensagem,
     p_id_prog_ord
     
     IF STATUS <> 0 THEN
        CALL log003_err_sql('FOREACH','cq_critica')
        RETURN FALSE
     END IF
     
     LET pr_id[p_ind].id_prog_ord = p_id_prog_ord
     
     SELECT ies_situa_oc
       INTO p_sit_oc
       FROM ordem_sup
      WHERE cod_empresa = p_cod_empresa
        AND num_oc = pr_critica[p_ind].num_oc
        AND ies_versao_atual = 'S'

     IF STATUS <> 0 THEN
        CALL log003_err_sql('SELECT','ordem_sup')
        RETURN FALSE
     END IF
     
     IF p_sit_oc = 'R' THEN
        LET pr_critica[p_ind].oc_alterada = 'NÃO'
     ELSE
        LET pr_critica[p_ind].oc_alterada = 'SIM'
     END IF
     
     LET pr_critica[p_ind].ies_situa_oc = p_sit_oc
     LET pr_critica[p_ind].reverter = 'N'
     
     SELECT dat_entrega_prev,
            qtd_ajuste
       INTO pr_critica[p_ind].programacao,
            pr_critica[p_ind].qtd_ajust  
       FROM prog_ord_sup_454
      WHERE cod_empresa = p_cod_empresa
        AND id_registro = p_id_prog_ord

     IF STATUS <> 0 THEN
        CALL log003_err_sql('SELECT','prog_ord_sup_454')
        RETURN FALSE
     END IF
     
     LET p_ind = p_ind + 1
     
     IF p_ind > 1000 THEN
        LET p_msg = 'limite de linhas da\n grade ultrapassou.'
        CALL log0030_mensagem(p_msg,'info')
        EXIT FOREACH
     END IF
   
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há criticas a\n serem exibidas'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_critica
      WITHOUT DEFAULTS FROM sr_critica.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()

         LET p_mensagem = pr_mensagem[p_ind].mensagem
         DISPLAY p_mensagem TO mensagem
         
         SELECT cod_lin_prod,
                den_item
           INTO p_cod_lin_prod,
                p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = pr_critica[p_ind].cod_item

         DISPLAY p_den_item TO den_item
         
      AFTER FIELD reverter
      
         IF pr_critica[p_ind].reverter = 'S' THEN
            IF pr_critica[p_ind].ies_situa_oc = 'R' THEN
               LET p_msg = 'Esse ajuste não\n foi efetuado!'
               CALL log0030_mensagem(p_msg,'excla')
               LET pr_critica[p_ind].reverter = 'N'
               DISPLAY 'N' TO sr_critica[s_ind].reverter
               NEXT FIELD reverter
            END IF
         END IF
         
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_critica[p_ind+1].processo IS NULL THEN
               ERROR "Não há mais registros nessa direção !!!"
               NEXT FIELD reverter
            END IF
         END IF
   
   END INPUT
   
   IF INT_FLAG  THEN
      RETURN FALSE
   END IF 

   LET p_count = 0
   LET p_index = ARR_COUNT()
   
   FOR p_ind = 1 TO p_index
       IF pr_critica[p_ind].reverter = 'S' THEN
          LET p_count = 1
          EXIT FOR
       END IF   
   END FOR
   
   IF p_count = 0 THEN
      RETURN FALSE
   END IF
   
   LET p_msg = "Confirma a reversão\n",
               "dos ajustes marcados ?"

   IF NOT log0040_confirm(20,15,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")

   FOR p_ind = 1 TO p_index
       IF pr_critica[p_ind].reverter = 'S' THEN
          IF NOT pol1157_reverte_ajuste() THEN
             CALL log085_transacao("ROLLBACK")
             RETURN FALSE
          END IF          
       END IF   
   END FOR

   CALL log085_transacao("COMMIT")
   
   LET p_msg = 'Operação efetuada\n com sucesso.'
   CALL log0030_mensagem(p_msg,'info')
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1157_reverte_ajuste()#
#--------------------------------#

   DEFINE p_id_registro INTEGER,
          p_situacao    CHAR(01),
          p_qtd_oc      DECIMAL(10,3)
   
   LET p_id_registro = pr_id[p_ind].id_prog_ord
   
   SELECT num_oc,
          num_versao,
          num_prog_entrega,
          qtd_ajuste
     INTO p_num_oc,
          p_num_versao,
          p_num_prog_entrega,
          p_qtd_ajuste
     FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = p_id_registro
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','prog_ord_sup_454')
      RETURN FALSE
   END IF
   
   IF pr_critica[p_ind].seq_periodo <> 0 THEN
      LET p_ocs = p_num_oc
      UPDATE mapa_compras_hist_454
         SET qtd_ajustada = qtd_ajustada - p_qtd_ajuste
       WHERE cod_empresa = p_cod_empresa
         AND chave_processo = pr_critica[p_ind].processo
         AND seq_periodo = pr_critica[p_ind].seq_periodo
         AND num_ocs = p_ocs
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE','mapa_compras_hist_454')
         RETURN FALSE
      END IF
   END IF     
   
   SELECT qtd_solic
     INTO p_qtd_oc
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S' 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_sup')
      RETURN FALSE
   END IF

   IF p_qtd_oc <= p_qtd_ajuste THEN
      IF NOT pol1157_exclui_oc() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   DELETE FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND id_registro = p_id_registro
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','prog_ord_sup_454')
      RETURN FALSE
   END IF

   DELETE FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND id_prog_ord = p_id_registro
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_criticado_bi_454')
      RETURN FALSE
   END IF
   
   SELECT COUNT(num_oc)
     INTO p_count
     FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','item_criticado_bi_454')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      DELETE FROM oc_bloqueada_454
       WHERE cod_empresa = p_cod_empresa
         AND num_oc = p_num_oc
      IF STATUS <> 0 THEN
         CALL log003_err_sql('DELETE','oc_bloqueada_454')
         RETURN FALSE
      END IF
      LET p_situacao = 'A'
   ELSE
      LET p_situacao = 'X'
   END IF
      
   UPDATE ordem_sup
      SET qtd_solic = qtd_solic - p_qtd_ajuste,
          ies_situa_oc = p_situacao
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S' 
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup')
      RETURN FALSE
   END IF
      
	 UPDATE prog_ordem_sup
      SET qtd_solic = qtd_solic - p_qtd_ajuste
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
      AND num_versao  = p_num_versao
      AND num_prog_entrega	= p_num_prog_entrega
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1157_exclui_oc()#
#---------------------------#

   DELETE FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','ordem_sup')
      RETURN FALSE
   END IF
      
	 DELETE FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup:03')
      RETURN FALSE
   END IF

   DELETE FROM sup_oc_grade
    WHERE empresa = p_cod_empresa
      AND ordem_compra = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','sup_oc_grade')
      RETURN FALSE
   END IF

   DELETE FROM ordem_sup_compl
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup_compl')
      RETURN FALSE
   END IF

   DELETE FROM dest_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','dest_ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM estrut_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','estrut_ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM sup_estrut_oc_grd
    WHERE empresa      = p_cod_empresa
      AND ordem_compra = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','sup_estrut_oc_grd')
      RETURN FALSE
   END IF

   DELETE FROM ordem_sup_txt
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup_txt')
      RETURN FALSE
   END IF

   DELETE FROM prog_ordem_sup_com
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','prog_ordem_sup_com')
      RETURN FALSE
   END IF

   DELETE FROM dest_ordem_sup4
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','dest_ordem_sup4')
      RETURN FALSE
   END IF

   DELETE FROM aprov_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','aprov_ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM prog_ord_sup_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','prog_ord_sup_454')
      RETURN FALSE
   END IF

   DELETE FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_criticado_bi_454')
      RETURN FALSE
   END IF

   DELETE FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','oc_bloqueada_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1157_adicionar()#
#--------------------------#

   IF p_chave_processo IS NULL THEN
      IF NOT pol1157_verifica_bi()  THEN	 
         RETURN FALSE
		  END IF 
   END IF
   
   LET p_add.chave_processo = p_chave_processo
   LET p_add.seq_campo = 11
   LET p_add.den_campo = 'ACRÉSCIMO'
   LET INT_FLAG = FALSE
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol11579") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol11579 AT 6,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INPUT BY NAME p_add.* WITHOUT DEFAULTS
   
      AFTER FIELD cod_item
         
         IF p_add.cod_item IS NULL THEN
            ERROR 'Informe o item!'
            NEXT FIELD cod_item
         END IF
         
         SELECT den_item_reduz
           INTO p_add.den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_add.cod_item
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'item')
            NEXT FIELD cod_item
         END IF

         DISPLAY p_add.den_item to den_item
                     
      AFTER FIELD seq_periodo
         
         IF p_add.seq_periodo IS NULL OR
               p_add.seq_periodo < 1  OR 
               p_add.seq_periodo > 17 THEN
            CALL log0030_mensagem('Período inválido!', 'excla')
            NEXT FIELD seq_periodo
         END IF

      ON KEY (control-z)
         CALL pol1157_popup_add()

      AFTER INPUT
         IF INT_FLAG THEN
            RETURN FALSE
         END IF

         IF p_add.seq_periodo IS NULL THEN
            NEXT FIELD seq_periodo
         END IF
            
         IF NOT pol1157_valida_add() THEN
            NEXT FIELD cod_item
         END IF

   END INPUT
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1157_valida_add()#
#----------------------------#
 
   DEFINE m_qtd_dia CHAR(12)
   
   LET p_houve_erro = FALSE
   
   SELECT qtd_dia
     INTO m_qtd_dia               
     FROM mapa_compras_data_454
    WHERE cod_empresa = p_cod_empresa
      AND chave_processo = p_add.chave_processo
      AND cod_item = p_add.cod_item
      AND seq_periodo = p_add.seq_periodo
      AND seq_campo = p_add.seq_campo

   IF STATUS = 100 THEN
      LET p_msg = 'Item / período sem registro\n',
                  'de acréscimo!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','mapa_compras_data_454:acréscimo')
         RETURN FALSE
      END IF
   END IF
   
   IF m_qtd_dia <> 0 THEN
      LET p_msg = 'Item / período já possui programação\n',
                  'de acréscimo! - Qtd programada: ', m_qtd_dia
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   SELECT qtd_dia
     INTO m_qtd_dia               
     FROM mapa_compras_data_454
    WHERE cod_empresa = p_cod_empresa
      AND chave_processo = p_add.chave_processo
      AND cod_item = p_add.cod_item
      AND seq_periodo = p_add.seq_periodo
      AND seq_campo = 9

   IF STATUS = 0 THEN
      IF m_qtd_dia <> 0 THEN
         LET p_msg = 'Item / período possui programação\n',
                     'de corte! - Qtd programada: ', m_qtd_dia
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('Lendo','mapa_compras_data_454:corte')
         RETURN FALSE
      END IF
   END IF
   
   UPDATE mapa_compras_data_454
      SET qtd_dia = 0.1
    WHERE cod_empresa = p_cod_empresa
      AND chave_processo = p_add.chave_processo
      AND cod_item = p_add.cod_item
      AND seq_periodo = p_add.seq_periodo
      AND seq_campo = p_add.seq_campo

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','mapa_compras_data_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION         
               
#-------------------------------#
 FUNCTION pol1157_verifica_bi() 
#-------------------------------#

	 DEFINE   l_cod_item  CHAR(15)									  # MANUEL2 04-10-2012			
	
	 INITIALIZE p_chave_processo  TO NULL
	
		SELECT MAX(chave_processo) 
		INTO p_chave_processo
		FROM mapa_compras_data_454
		WHERE COD_EMPRESA = p_cod_empresa
		
		IF STATUS <> 0 THEN
       CALL log003_err_sql('LENDO 2','MAPA_COMPRAS_DATA_454')
		   RETURN FALSE
    END IF
		
		IF (p_chave_processo  IS NULL) OR 
		   (p_chave_processo  = ' ') OR 
		   (p_chave_processo  = '') THEN 
			RETURN FALSE
    END IF

# MANUEL2 04-10-2012  DAQUI 
		
	  DECLARE cq_sem_freq CURSOR FOR									 
    SELECT DISTINCT a.cod_item												
      FROM mapa_compras_data_454 a
     WHERE a.cod_empresa = p_cod_empresa
       AND a.qtd_dia <> 0 
       AND a.seq_campo IN (9,11)
       AND a.cod_item[1,3] <> 'FE.'
	     AND a.cod_item not in (SELECT item from MAN_PAR_PROG_454
			                    WHERE empresa = p_cod_empresa)	
		
	FOREACH cq_sem_freq  INTO l_cod_item
			LET p_msg = 'Item: ', l_cod_item, ' sem frequencia cadastrada no POL1107 ',
		               'PROCESSO CANCELADO'
		   CALL log0030_mensagem(p_msg,'excla')
			RETURN FALSE
		EXIT FOREACH
	END FOREACH

# MANUEL2 04-10-2012  ATE AQUI	
		
		
	RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1157_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa to cod_empresa
   
END FUNCTION

#---------------------------#
FUNCTION pol1157_cria_temp()
#---------------------------#

   DROP TABLE item_tmp_454
   
   CREATE  TABLE item_tmp_454(
		cod_item CHAR(15))

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","item_tmp_454")
			RETURN FALSE
	 END IF
   
   DROP TABLE periodo_tmp_454
   
   CREATE  TABLE periodo_tmp_454(
		seq_periodo INTEGER)

	 IF STATUS <> 0 THEN 
			CALL log003_err_sql("CREATE","periodo_tmp_454")
			RETURN FALSE
	 END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1157_informar()
#--------------------------#

   LET p_query = 
       "SELECT DISTINCT a.cod_item FROM mapa_compras_data_454 a, item b, man_par_prog_454 c",
       " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
       "   AND a.seq_campo IN (9,11) ",
       "   AND a.qtd_dia <> 0 ",
       "   AND b.cod_empresa = a.cod_empresa ",
       "   AND b.cod_item = a.cod_item ",
       "   AND a.cod_empresa = c.empresa ",
       "   AND a.cod_item = c.item ",
       "   AND a.chave_processo = '",p_chave_processo,"' "

   LET INT_FLAG = FALSE
   INITIALIZE p_tela, pr_item, pr_compl, pr_itens TO NULL

   IF NOT pol1157_sel_filtro() THEN
      RETURN FALSE
   END IF
   
   if p_tela.cod_lin_prod is not null then
      LET p_query = p_query CLIPPED, " and  b.cod_lin_prod = ", p_tela.cod_lin_prod
   end if
   
   CASE p_tela.sel_item

      WHEN  'I' CALL pol1157_info_intervalo() RETURNING p_status
      WHEN  'A' CALL pol1157_info_itens() RETURNING p_status
      WHEN  'P' CALL pol1157_info_parte_cod() RETURNING p_status
      WHEN  'T' LET p_status = TRUE
   
   END CASE
   
   IF NOT p_status THEN
      RETURN FALSE
   END IF

   IF p_tela.sel_periodo = 'S' THEN
      IF NOT pol1157_sel_periodo() then
         RETURN FALSE
      END IF
   END IF

   LET p_query = p_query CLIPPED, " ORDER BY a.cod_item "

   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1157_sel_filtro()#
#----------------------------#
   
   DEFINE p_dat_limite date
   
   let p_dat_limite = today + 90
   
   INITIALIZE pr_itens TO NULL
   LET p_tela.ies_ajustado = 'N'
   LET p_tela.sel_periodo = 'N'
   LET p_tela.dat_limite = p_dat_limite
   
   INPUT p_tela.sel_item,
         p_tela.dat_limite,
         p_tela.ies_ajustado,
         p_tela.cod_lin_prod
     WITHOUT DEFAULTS 
        FROM sel_item, dat_limite, ies_ajustado, cod_lin_prod
	  
	  AFTER FIELD dat_limite
	  
	     if p_tela.dat_limite is null then
	        ERROR 'Campo com preenchimento obrigatório!'
	        NEXT FIELD dat_limite
	     end if
	     
	     if p_tela.dat_limite < TODAY or p_tela.dat_limite > (today + 135)  then
	        ERROR 'Informe uma data entre ', today, ' e ', today + 135
	        NEXT FIELD dat_limite
	     end if	     
	  
	  AFTER FIELD cod_lin_prod
	     
	     if p_tela.cod_lin_prod is not null then
	        select count(cod_lin_prod)
	          into p_count
	          from item
	         where cod_empresa = p_cod_empresa
	           and cod_lin_prod = p_tela.cod_lin_prod
	        if STATUS <> 0 then
	           call log003_err_sql('Lendo','item')
	           RETURN false
	        end if
	        if p_count = 0 then
	           error 'Não existe itens com essa linha de produção!'
	           NEXT FIELD cod_lin_prod
	        end if

         SELECT den_estr_linprod
           into p_den_estr_linprod
           from linha_prod
          where cod_lin_prod = p_tela.cod_lin_prod 
            and cod_lin_recei = 0
            and cod_seg_merc = 0
            and cod_cla_uso = 0

	        if STATUS <> 0 then
	           call log003_err_sql('Lendo','linha_prod')
	           RETURN false
	        end if
	       
	       DISPLAY p_den_estr_linprod to den_estr_linprod 
	       
	     END IF

      ON KEY (control-z)
         CALL pol1157_popup()
	     
		AFTER INPUT
      
   END INPUT 

   IF INT_FLAG  THEN
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1157_info_intervalo()#
#--------------------------------#

   INPUT p_tela.item_de, p_tela.item_ate
     WITHOUT DEFAULTS FROM item_de, item_ate

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            IF p_tela.item_de IS NULL THEN
               ERROR 'Informe o item inicial'
               NEXT FIELD item_de
            END IF

            IF p_tela.item_ate IS NULL THEN
               ERROR 'Informe o item final'
               NEXT FIELD item_ate
            END IF
         
            IF p_tela.item_ate < p_tela.item_de THEN
               ERROR 'Item final deve ser maior ou igual ao inicial'
               NEXT FIELD item_de
            END IF
         END IF

      ON KEY (control-z)
         CALL pol1157_popup()

   END INPUT 

  IF INT_FLAG  THEN
      RETURN FALSE
   END IF 

   LET p_query = p_query CLIPPED, 
       " AND a.cod_item >= '",p_tela.item_de,"' ",
       " AND a.cod_item <= '",p_tela.item_ate,"' "
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1157_info_itens()#
#--------------------------------#

   INITIALIZE pr_itens TO NULL
   DELETE FROM item_tmp_454
   LET p_index = 1
   CALL SET_COUNT(p_index)
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
      
      AFTER FIELD codigo
      
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            
            IF pr_itens[p_index].codigo IS NULL THEN
               ERROR "Campo com prenchimento obrigatório !!!"
               NEXT FIELD codigo
            END IF
            
            FOR p_ind = 1 TO ARR_COUNT()  
                IF p_ind = p_index THEN
                ELSE
                   IF pr_itens[p_ind].codigo = pr_itens[p_index].codigo THEN
                      ERROR 'Item já informado!'
                      NEXT FIELD codigo
                   END IF
                END IF
            END FOR
         END IF
         
         IF pr_itens[p_index].codigo IS NOT NULL THEN
            SELECT den_item_reduz, ies_tip_item
              INTO pr_itens[p_index].descricao,
                   pr_itens[p_index].tipo
              FROM item
             WHERE cod_empresa = p_cod_empresa
               AND cod_item    = pr_itens[p_index].codigo
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('LENDO','ITEM')
               NEXT FIELD codigo
            END IF
            
            DISPLAY pr_itens[p_index].tipo TO sr_itens[s_index].tipo
            DISPLAY pr_itens[p_index].descricao TO sr_itens[s_index].descricao
            
            IF pr_itens[p_index].tipo MATCHES '[BC]' THEN
            ELSE
               ERROR 'Informe um item comprado!'
               NEXT FIELD codigo
            END IF
            
            SELECT COUNT(cod_item)
              INTO p_count
              FROM mapa_compras_data_454
             WHERE cod_empresa = p_cod_empresa
               AND qtd_dia <> 0 
               AND seq_campo IN (9,11) 
               AND cod_item = pr_itens[p_index].codigo
			         AND cod_item in (SELECT item from man_par_prog_454
			                    WHERE empresa = p_cod_empresa
								            AND item    = pr_itens[p_index].codigo)
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('LENDO','MAPA_COMPRAS_DATA_454:01')
               NEXT FIELD codigo
            END IF

            IF p_count = 0 THEN
               ERROR 'Item sem informações de ajustes na tab mapa_compras_data_454!'
               NEXT FIELD codigo
            END IF
            
         END IF

      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_ind = 1 TO ARR_COUNT()  
                IF pr_itens[p_ind].codigo IS NOT NULL THEN
                   INSERT INTO item_tmp_454
                      VALUES(pr_itens[p_ind].codigo)
                   LET p_count = 1
                END IF
            END FOR
            IF p_count = 0 THEN
               ERROR 'Informe os itens Itens ou Ctrl+C para cancelar!'
               NEXT FIELD codigo
            END IF
         END IF
      
      ON KEY (control-z)
         CALL pol1157_popup()

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   LET p_query = p_query CLIPPED, 
       " AND a.cod_item IN (SELECT c.cod_item FROM item_tmp_454 c) "
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1157_info_parte_cod()#
#--------------------------------#

   INPUT p_tela.cod_item
     WITHOUT DEFAULTS FROM cod_item

      AFTER INPUT
      
      ON KEY (control-z)
         CALL pol1157_popup()

   END INPUT 

  IF INT_FLAG  THEN
      RETURN FALSE
   END IF 

   LET p_query = p_query CLIPPED, 
         " AND a.cod_item LIKE '","%",p_tela.cod_item CLIPPED,"%","' "
         
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1157_sel_periodo()#
#-----------------------------#

   CURRENT WINDOW IS w_pol1157

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11574") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11574 AT 4,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE pr_periodo TO NULL
   DELETE FROM periodo_tmp_454
   LET p_index = 1
   
   DECLARE cq_per CURSOR FOR
    SELECT seq_periodo, periodo
      FROM mapa_periodos_454 
     WHERE cod_empresa = p_cod_empresa
       AND cod_frequencia = '1'
   
   FOREACH cq_per INTO 
      pr_periodo[p_index].seq_periodo,
      pr_periodo[p_index].periodo
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_per')
         RETURN FALSE
      END IF
      
      LET pr_periodo[p_index].sel_periodo = 'N'
      
      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_periodo
      WITHOUT DEFAULTS FROM sr_periodo.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()
      
      AFTER FIELD sel_periodo
      
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            
            IF pr_periodo[p_index].seq_periodo IS NULL THEN
               ERROR "Não há mais registros nessa direção !!!"
               NEXT FIELD sel_periodo
            END IF
         END IF
         
      AFTER INPUT
         
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_ind = 1 TO ARR_COUNT()  
                IF pr_periodo[p_ind].sel_periodo = 'S' THEN
                   INSERT INTO periodo_tmp_454
                      VALUES(pr_periodo[p_ind].seq_periodo)
                   LET p_count = 1
                END IF
            END FOR
            IF p_count = 0 THEN
               ERROR 'Selecione pelomenos um período ou Ctrl+C para cancelar!'
               NEXT FIELD sel_periodo
            END IF
         END IF
      
   END INPUT
   
   CLOSE WINDOW w_pol11574

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

   
#-----------------------#
FUNCTION pol1157_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(item_de)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
           LET p_tela.item_de = p_codigo
           DISPLAY p_codigo TO item_de
         END IF

      WHEN INFIELD(item_ate)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
           LET p_tela.item_ate = p_codigo
           DISPLAY p_codigo TO item_ate
         END IF

      WHEN INFIELD(codigo)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
           LET pr_itens[p_index].codigo = p_codigo
           DISPLAY p_codigo TO sr_itens[s_index].codigo
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol1157_le_linha()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF

      WHEN INFIELD(linha)
         LET p_codigo = pol1157_le_linha()
         CURRENT WINDOW IS w_pol1157
         IF p_codigo IS NOT NULL THEN
            LET p_linha = p_codigo CLIPPED
            DISPLAY p_codigo TO linha
         END IF

      WHEN INFIELD(item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1157b
         IF p_codigo IS NOT NULL THEN
           LET p_item = p_codigo
           DISPLAY p_codigo TO item
         END IF

         
   END CASE

END FUNCTION

#--------------------------#
FUNCTION pol1157_popup_lst()
#--------------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(item_de)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol11575
         IF p_codigo IS NOT NULL THEN
           LET p_par_lst.item_de = p_codigo
           DISPLAY p_codigo TO item_de
         END IF

      WHEN INFIELD(item_ate)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol11575
         IF p_codigo IS NOT NULL THEN
           LET p_par_lst.item_ate = p_codigo
           DISPLAY p_codigo TO item_ate
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol11575
         IF p_codigo IS NOT NULL THEN
           LET p_par_lst.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

      WHEN INFIELD(chave_processo)
         LET p_codigo = pol1157_le_processo()
         CURRENT WINDOW IS w_pol11575
         IF p_codigo IS NOT NULL THEN
            LET p_par_lst.chave_processo = p_codigo CLIPPED
            DISPLAY p_codigo TO chave_processo
         END IF

      WHEN INFIELD(cod_lin_prod)
         LET p_codigo = pol1157_le_linha()
         CURRENT WINDOW IS w_pol11575
         IF p_codigo IS NOT NULL THEN
            LET p_par_lst.cod_lin_prod = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_lin_prod
         END IF
         
   END CASE

END FUNCTION

#--------------------------#
FUNCTION pol1157_popup_add()
#--------------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = pol1157_le_mapa()
         CURRENT WINDOW IS w_pol11579
         IF p_codigo IS NOT NULL THEN
           LET p_add.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE

END FUNCTION


#-------------------------#
FUNCTION pol1157_le_mapa()#
#-------------------------#

   DEFINE pr_mpop  ARRAY[500] OF RECORD
          cod_item  CHAR(15),
          den_item  CHAR(40)
   END RECORD
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11572") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11572 AT 5,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_mpop CURSOR FOR
    SELECT DISTINCT a.cod_item, b.den_item 
      FROM mapa_compras_data_454 a, item b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.qtd_dia <> 0 
       AND a.seq_campo IN (9,11)
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item = a.cod_item
	   AND b.cod_item in (SELECT item from MAN_PAR_PROG_454
			                    WHERE empresa = p_cod_empresa)
       
     ORDER BY a.cod_item

   FOREACH cq_mpop
      INTO pr_mpop[p_ind].cod_item,
           pr_mpop[p_ind].den_item   

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cursor:cq_mpop')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_mpop TO sr_mpop.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11572
   
   IF NOT INT_FLAG THEN
      RETURN pr_mpop[p_ind].cod_item
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-------------------------#
FUNCTION pol1157_le_linha()#
#-------------------------#

   DEFINE pr_mpop  ARRAY[5000] OF RECORD
          cod_lin_prod      DECIMAL(2,0),
          den_estr_linprod  CHAR(40)
   END RECORD
   
   DEFINE p_ind, s_ind INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11577") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11577 AT 5,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_mlin CURSOR FOR
    SELECT DISTINCT 
           cod_lin_prod
      FROM linha_prod
     WHERE cod_lin_recei = 0
       AND cod_seg_merc = 0
       AND cod_cla_uso = 0
     ORDER by cod_lin_prod       

   FOREACH cq_mlin
      INTO pr_mpop[p_ind].cod_lin_prod

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','linha_prod:cq_mpop')
         EXIT FOREACH
      END IF
      
      SELECT den_estr_linprod
        into pr_mpop[p_ind].den_estr_linprod
        from linha_prod
       where cod_lin_prod = pr_mpop[p_ind].cod_lin_prod
         and cod_lin_recei = 0
         and cod_seg_merc = 0
         and cod_cla_uso = 0

      if STATUS <> 0 then
         let pr_mpop[p_ind].cod_lin_prod = ''
      end if
       
      LET p_ind = p_ind + 1
      
      IF p_ind > 5000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_mpop TO sr_mpop.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11577
   
   IF NOT INT_FLAG THEN
      RETURN pr_mpop[p_ind].cod_lin_prod
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol1157_le_processo()#
#-----------------------------#

   DEFINE pr_mpop  ARRAY[5000] OF RECORD
          chave_processo  DECIMAL(12,0)
   END RECORD
   
   DEFINE p_ind, s_ind INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11578") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11578 AT 09,43 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET p_ind = 1
    
   DECLARE cq_mpro CURSOR FOR
    SELECT DISTINCT 
           chave_processo
      FROM mapa_compras_hist_454
     WHERE cod_empresa = p_cod_empresa
     ORDER by chave_processo DESC       

   FOREACH cq_mpro INTO 
      pr_mpop[p_ind].chave_processo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','mapa_compras_hist_454:cq_mpro')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 5000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_mpop TO sr_mpop.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol11578
   
   IF NOT INT_FLAG THEN
      RETURN pr_mpop[p_ind].chave_processo
   ELSE
      RETURN ""
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol1157_monta_tela()#
#----------------------------#
	
	 DEFINE w_chave_processo  DECIMAL(12)
	
   DECLARE cq_monta CURSOR FOR
    SELECT a.rowid,
           a.cod_item,
           a.seq_periodo,
           a.qtd_dia,
           a.ies_ajustado,
           b.den_item_reduz,
           a.dat_entrega,
           a.seq_campo,
		       a.chave_processo
      FROM mapa_compras_data_454 a, item b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_item    = p_cod_item
       AND a.seq_campo  IN (9,11) 
       AND a.qtd_dia     <> 0
       AND a.cod_item[1,3] <> 'FE.'
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item    = a.cod_item
       AND a.chave_processo = p_chave_processo
	     AND b.cod_item in (SELECT item from man_par_prog_454
			                    WHERE empresa = p_cod_empresa)
							
     ORDER BY a.seq_periodo
     
   FOREACH cq_monta INTO
      pr_compl[p_index].id_registro,
      pr_item[p_index].cod_item,
      pr_item[p_index].seq_periodo,
      pr_item[p_index].qtd_suger,
      pr_item[p_index].ies_alt,
      pr_item[p_index].den_item,
      pr_compl[p_index].dat_entrega,
      p_seq_campo,
	    w_chave_processo 

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_monta')
         RETURN FALSE
      END IF

      IF p_tela.ies_ajustado = 'N' THEN
         IF pr_item[p_index].ies_alt = 'S' THEN
            CONTINUE FOREACH
         END IF
      END IF

      IF p_tela.sel_periodo = 'S' THEN
         SELECT seq_periodo FROM periodo_tmp_454 
          WHERE seq_periodo = p_seq_periodo
         IF STATUS <> 0 THEN
            CONTINUE FOREACH
         END IF
      END IF

      LET p_seq_periodo = pr_item[p_index].seq_periodo

      IF NOT pol1157_le_intervalo() THEN
         RETURN FALSE
      END IF
      
      IF p_dat_fim > p_tela.dat_limite THEN
         CONTINUE FOREACH
      END IF

	    SELECT SUM(qtd_ajustada) 
	      INTO pr_item[p_index].qtd_realiz
	      FROM mapa_compras_hist_454
	     WHERE cod_empresa 	= p_cod_empresa
	       AND cod_item    	= p_cod_item
		     AND seq_campo 		= p_seq_campo
		     AND seq_periodo 	= pr_item[p_index].seq_periodo
	       AND chave_processo = w_chave_processo 
	
	    IF pr_item[p_index].qtd_realiz IS NULL THEN
	       LET pr_item[p_index].qtd_realiz = 0 
	    END IF
    
	    IF pr_item[p_index].qtd_suger <  0 THEN 
	       LET pr_item[p_index].qtd_suger = pr_item[p_index].qtd_suger * -1 
      END IF
      
      LET pr_item[p_index].qtd_ajust = pr_item[p_index].qtd_suger - pr_item[p_index].qtd_realiz
      
      IF NOT pol1157_le_sdo_oc() THEN
         RETURN FALSE
      END IF
      
      LET pr_item[p_index].sdo_oc = p_sdo_oc
      
  
      IF p_seq_campo = 11 THEN
         LET pr_item[p_index].cod_oper = 'A'
      ELSE
         LET pr_item[p_index].cod_oper = 'C'
         IF pr_item[p_index].sdo_oc < pr_item[p_index].qtd_ajust THEN
            LET pr_item[p_index].qtd_ajust = pr_item[p_index].sdo_oc
         END IF
      END IF

  	  IF pr_item[p_index].ies_alt  =   'S'  THEN 
	       LET pr_item[p_index].qtd_ajust = 0
      END IF
	  
      LET p_index = p_index + 1

      IF p_index > 3000 THEN
         LET p_msg = 'Limite de linhas da\n',
                     'grade ultrapassou!'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1157_carrega_dados()#
#-------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11573") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11573 AT 09,22 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   LET pr_men[1].mensagem  = 'Carregando dados'
   CALL pol1157_exib_mensagem()
   
   LET p_index = 1
   
   PREPARE query FROM p_query    
   DECLARE cq_query CURSOR FOR query

   FOREACH cq_query INTO p_cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','CQ_QUERY')
         RETURN FALSE
      END IF

      LET pr_men[1].mensagem  = 'Item:', p_cod_item
      CALL pol1157_exib_mensagem()
      
      IF NOT pol1157_monta_tela() THEN
         RETURN FALSE
      END IF

      IF p_index > 3000 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Naõ a dados a serem processados\n',
                  'para os parâmetros informados!'
      CALL log0030_mensagem(p_msg,'Excla')
      RETURN FALSE
   END IF 
   
   LET p_qtd_linha = p_index - 1

   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1157_exib_mensagem()
#------------------------------#

   CALL SET_COUNT(1)
   
   INPUT ARRAY pr_men 
      WITHOUT DEFAULTS FROM sr_men.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT

END FUNCTION

#----------------------------#
FUNCTION pol1157_aceita_qtd()#
#----------------------------#
   

   CURRENT WINDOW IS w_pol1157

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol11571") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol11571 AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_index - 1)
      
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

         IF pr_item[p_index].cod_item IS NOT NULL THEN
            LET p_seq_periodo = pr_item[p_index].seq_periodo
            LET p_cod_item = pr_item[p_index].cod_item
         
            IF pol1157_le_intervalo() THEN
               DISPLAY p_dat_ini to dat_ini
               DISPLAY p_dat_fim to dat_fim
            END IF
         ELSE
            DISPLAY '' to dat_ini
            DISPLAY '' to dat_fim
         END IF

      AFTER FIELD qtd_ajust

         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_item[p_index].cod_item IS NULL THEN
               LET pr_item[p_index].qtd_ajust = NULL
               DISPLAY '' TO sr_item[s_index].qtd_ajust
               NEXT FIELD qtd_ajust
            ELSE
               IF pr_item[p_index].qtd_ajust IS NULL OR 
                  pr_item[p_index].qtd_ajust < 0 THEN
                  ERROR 'Campo com preenchimento obrigatório!!!'
                  NEXT FIELD qtd_ajust
               END IF
               IF pr_item[p_index].cod_oper = 'C' THEN
                  IF pr_item[p_index].qtd_ajust > pr_item[p_index].sdo_oc THEN
                     ERROR 'Qtd a cancelar não pode ser maior que o saldo do período!'
                     NEXT FIELD qtd_ajust
                  END IF
               END IF
            END IF
         END IF
   
   END INPUT
   
   CLOSE WINDOW w_pol11571
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1157_le_intervalo()#
#------------------------------#

   SELECT cod_frequencia,
          qtd_lote_multiplo
     INTO p_cod_frequencia,
          p_qtd_lote_multiplo
     FROM man_par_prog_454
    WHERE empresa = p_cod_empresa
      AND item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','man_par_prog_454')
      RETURN FALSE
   END IF

   SELECT dat_inicio,
          dat_fim
     INTO p_dat_ini,
          p_dat_fim
     FROM mapa_periodos_454 
    WHERE cod_empresa = p_cod_empresa 
      AND cod_frequencia = p_cod_frequencia
      AND seq_periodo = p_seq_periodo
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','mapa_periodos_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#   
FUNCTION pol1157_le_sdo_oc()#
#---------------------------#   

   SELECT SUM(b.qtd_solic - b.qtd_recebida)
     INTO p_sdo_oc
     FROM ordem_sup a, prog_ordem_sup b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_item
      AND a.ies_versao_atual = 'S' 
      AND a.ies_situa_oc IN ('A', 'R')
	    AND a.cod_empresa   = b.cod_empresa
	    AND a.num_oc        = b.num_oc
	    AND a.num_versao    = b.num_versao
	    AND b.ies_situa_prog <> 'C'									# MANUEL 04-10-2012
	    AND (b.qtd_solic - b.qtd_recebida) > 0						# MANUEL 04-10-2012
      AND b.dat_entrega_prev >= p_dat_ini
      AND b.dat_entrega_prev <= p_dat_fim
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_sup:01')
      RETURN FALSE
   END IF

   IF p_sdo_oc IS NULL THEN
      LET p_sdo_oc = 0
   END IF
   
   RETURN TRUE
      
END FUNCTION

#---------------------------#
FUNCTION pol1157_processar()#
#---------------------------#

   IF NOT pol1157_carrega_dados() THEN
      RETURN FALSE
   END IF
        
   IF NOT pol1157_aceita_qtd() THEN
      RETURN FALSE
   END IF

   LET p_msg = "Confirma a execução dos ajus-\n",
               "tes das ordens de compras ???"
   IF NOT log0040_confirm(20,15,p_msg) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   LET p_dat_proces = CURRENT
   
   IF NOT pol1157_ajusta_oc() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1157_ajusta_oc()#
#---------------------------#
   
   DEFINE p_obs CHAR(100)
   
   SELECT data_processamento
     INTO p_data_processamento
     FROM mapa_dias_mes_454
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','mapa_dias_mes_454')
      RETURN FALSE
   END IF
   
   LET p_dat_origem = DATE(p_data_processamento)
   
   CURRENT WINDOW IS w_pol11573
   LET pr_men[1].mensagem  = 'Ajustando Ordens'
   CALL pol1157_exib_mensagem()
   LET p_qtd_proces = 0
   LET p_tem_critica = FALSE
   LET p_checa_trava = 'S'   
      
   FOR p_ind = 1 TO p_qtd_linha
     
     LET p_obs = 'Operacao: ', pr_item[p_ind].cod_oper, ' qtd ajustar: ', pr_item[p_ind].qtd_ajust,
         ' Linha: ', p_ind
     #CALL log0030_mensagem(p_obs,'info')
     
     LET p_qtd_sdo_oc = pr_item[p_ind].sdo_oc
     LET p_qtd_alterada = pr_item[p_ind].qtd_ajust
     LET p_tip_ajuste = pr_item[p_ind].cod_oper

     IF pr_item[p_ind].qtd_ajust > 0 THEN 

       IF pr_item[p_ind].cod_oper = 'C' THEN
          LET p_checa_trava = 'N'   
          LET p_seq_campo = 9
          LET pr_men[1].mensagem  = 'Cancelado quantidades'
          CALL pol1157_exib_mensagem()

          IF NOT pol1157_cancela_oc() THEN
             RETURN FALSE
          END IF

          LET p_qtd_proces = p_qtd_proces + 1
       ELSE
          IF pr_item[p_ind].cod_oper = 'A' THEN
             LET p_checa_trava = 'S'   
             LET p_seq_campo = 11
             LET pr_men[1].mensagem  = 'Gerando Ordem'
             CALL pol1157_exib_mensagem()
             IF NOT pol1157_acrescimo_oc() THEN
                RETURN FALSE
             END IF
             LET p_qtd_proces = p_qtd_proces + 1
          END IF

       END IF
     ELSE
        IF pr_item[p_ind].qtd_ajust = 0 THEN 
           IF pr_item[p_ind].cod_oper = 'C' AND pr_item[p_ind].sdo_oc = 0 THEN
           ELSE
              IF pr_item[p_ind].ies_alt = 'N' THEN
                 LET p_rowid = pr_compl[p_ind].id_registro
                 LET p_ocs = ''
                 LET p_dat_entrega = pr_compl[p_ind].dat_entrega
                 LET p_ies_atu_hist = FALSE
                 IF NOT pol1157_atualiz_mapa() THEN
                    RETURN FALSE
                 END IF
                 LET p_qtd_proces = p_qtd_proces + 1
              END IF
           END IF
        END IF
     END IF

   END FOR
   
   IF p_qtd_proces = 0 THEN
      LET p_msg = 'Não há dados a serem processados!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#         
FUNCTION pol1157_cancela_oc()#
#----------------------------#
   
   DEFINE p_oc_ant       INTEGER,
          p_versao_atual INTEGER,
		      p_sdo_total_oc  INTEGER
		       									# MANUEL 04-10-2012
   
   LET p_oc_ant = 0
   LET p_rowid = pr_compl[p_ind].id_registro
   LET p_cod_item    = pr_item[p_ind].cod_item
   LET p_seq_periodo = pr_item[p_ind].seq_periodo
   LET p_qtd_ajust   = pr_item[p_ind].qtd_ajust

   IF NOT pol1157_le_intervalo() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE p_ocs to NULL
   
   DECLARE cq_cancel CURSOR FOR
    SELECT a.num_oc,
           a.num_versao,
		       b.num_prog_entrega,
           a.ies_situa_oc,
           b.ies_situa_prog,									# MANUEL2 04-10-2012
          (b.qtd_solic - b.qtd_recebida),
		      (a.qtd_solic - a.qtd_recebida),						# MANUEL 04-10-2012
		      b.dat_entrega_prev,
		      a.ies_situa_oc
     FROM ordem_sup a, prog_ordem_sup b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.cod_item    = p_cod_item
      AND a.ies_versao_atual = 'S' 
      AND a.ies_situa_oc IN ('A', 'R', 'X')
	    AND b.ies_situa_prog <> 'C'									# MANUEL 04-10-2012
	    AND (b.qtd_solic - b.qtd_recebida) > 0						# MANUEL 04-10-2012
	    AND a.cod_empresa   = b.cod_empresa
	    AND a.num_oc        = b.num_oc
	    AND a.num_versao    = b.num_versao
      AND b.dat_entrega_prev >= p_dat_ini
      AND b.dat_entrega_prev <= p_dat_fim
    ORDER BY a.num_oc, b.dat_entrega_prev
      
   FOREACH cq_cancel INTO 
      p_num_oc, p_num_versao, p_num_prog_entrega, p_ies_situa, p_ies_situa_prg,
  	  p_sdo_oc, p_sdo_total_oc, p_dat_prev, p_situacao   												           
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_sup:02')
         RETURN FALSE
      END IF
      
      IF p_sdo_oc <= 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_num_oc <> p_oc_ant THEN
         IF p_ies_situa = 'R' THEN
            IF NOT pol1157_nova_versao() THEN
               RETURN FALSE
            END IF
         END IF 
         LET p_versao_atual = p_num_versao
      ELSE
         LET p_num_versao = p_versao_atual
      END IF

      IF p_sdo_oc > p_qtd_ajust THEN
         LET p_qtd_cancel = p_qtd_ajust
         LET p_qtd_ajust  = 0
         LET p_nova_situa = p_ies_situa
		     LET p_nova_situa_prg = p_ies_situa_prg			# MANUEL2 04-10-2012
      ELSE		                											# MANUEL 04-10-2012
			   LET p_qtd_cancel = p_sdo_oc						    #  MANUEL 04-10-2012
			   LET p_qtd_ajust  = p_qtd_ajust - p_sdo_oc	# MANUEL 04-10-2012
	       IF p_sdo_total_oc > p_qtd_ajust THEN     	# MANUEL 04-10-2012
			      LET p_nova_situa = p_ies_situa					# MANUEL 04-10-2012
			      LET p_nova_situa_prg = 'C'						  # MANUEL 04-10-2012
		     ELSE												                # MANUEL 04-10-2012
			      LET p_nova_situa = 'L'							    # MANUEL 04-10-2012
			      LET p_nova_situa_prg = 'C'						  # MANUEL 04-10-2012
		     END IF												              # MANUEL 04-10-2012
      END IF
      
      UPDATE ordem_sup
         SET qtd_solic = qtd_solic - p_qtd_cancel,
             ies_situa_oc 	= p_nova_situa
       WHERE cod_empresa 		= p_cod_empresa
         AND num_oc      		= p_num_oc
         AND ies_versao_atual = 'S' 
             
      IF STATUS <> 0 THEN
         CALL log003_err_sql('update','ordem_sup:03')
         RETURN FALSE
      END IF
      
	    UPDATE prog_ordem_sup
         SET qtd_solic = qtd_solic - p_qtd_cancel,   # MANUEL 04-10-2012
             ies_situa_prog 	= p_nova_situa_prg   # MANUEL 04-10-2012
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = p_num_oc
         AND num_versao  = p_num_versao
		     AND num_prog_entrega	= p_num_prog_entrega
             
      IF STATUS <> 0 THEN
         CALL log003_err_sql('update','ordem_sup:03')
         RETURN FALSE
      END IF
	    
	    LET p_qtd_solic = p_qtd_cancel
	    LET p_qtd_ajuste = 0
	    LET p_checa_trava = 'N'

	    IF not pol1157_grava_prog_ord() THEN
	       RETURN FALSE
	    END IF

      IF p_num_oc <> p_oc_ant OR p_qtd_ajust <= 0 THEN
         
         IF p_oc_ant <> 0 OR p_qtd_ajust <= 0 THEN
            IF p_situacao = 'X' THEN
               IF NOT pol1157_ve_bloqueio() THEN
                  RETURN FALSE
               END IF
            END IF
         END IF
         
         LET p_oc_ant = p_num_oc
         LET p_txt_oc = p_num_oc
         IF p_ocs IS NULL THEN
            LET p_ocs = p_txt_oc
         ELSE
            LET p_ocs = p_ocs CLIPPED, ';', p_txt_oc
         END IF
      END IF
	    
      IF p_qtd_ajust <= 0 THEN
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   LET p_ies_atu_hist = FALSE
   IF NOT pol1157_atualiz_mapa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol1157_grava_prog_ord()#
#--------------------------------#

   SELECT MAX(id_registro)
     INTO p_id_prog_ord
     FROM prog_ord_sup_454

   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT","prog_ord_sup_454")
      RETURN FALSE
   END IF
   
   IF p_id_prog_ord IS NULL THEN
      LET p_id_prog_ord = 1
   ELSE
      LET p_id_prog_ord = p_id_prog_ord + 1
   END IF
                                                                                                          
   INSERT INTO prog_ord_sup_454 VALUES (                                                            
         p_cod_empresa,   
         p_cod_item,                                                              
         p_num_oc,                                                                      
         p_num_versao,                                                                  
         p_num_prog_entrega,                                                            
         p_qtd_solic,                                                                                   
         p_dat_prev,                                                            
         p_dat_origem,
         p_tip_ajuste,
         p_id_prog_ord)                                                                                 

   IF STATUS <> 0 THEN                                                                              
      CALL log003_err_sql("INCLUSAO","PROG_ORD_SUP_454")                                            
      RETURN FALSE                                                                                  
   END IF                                                                                           

   IF p_checa_trava = 'S' THEN
      IF NOT POL1157_chama_trava() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION POL1157_chama_trava()#
#-----------------------------#

   LET p_parametro.cod_empresa = p_cod_empresa                                                     
   LET p_parametro.num_oc = p_num_oc                                                                  
   LET p_parametro.nom_programa = 'POL1157'                                                            
   LET p_parametro.dat_programacao = p_dat_prev                                 
   LET p_parametro.qtd_ajuste = p_qtd_ajuste
   LET p_parametro.seq_periodo = p_seq_periodo
   LET p_parametro.chave_processo = p_chave_processo
   LET p_parametro.id_prog_ord = p_id_prog_ord
   
   IF NOT pol1234_trava90(p_parametro) THEN                                                            
      RETURN FALSE                                                                                     
   END IF                                                                                              

   IF p_tip_ajuste = 'A' THEN
      CALL pol1157_ve_status_oc()
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1157_ve_bloqueio()#
#-----------------------------#

   SELECT COUNT(*)
     INTO p_count
     FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
                           
   IF p_count = 0 THEN
      UPDATE ordem_sup
         SET ies_situa_oc = 'A'
       WHERE cod_empresa  = p_cod_empresa
         AND num_oc       = p_num_oc
         AND ies_versao_atual = 'S'
      IF STATUS <> 0 THEN
         CALL log003_err_sql('UPDATE', 'ordem_sup:desbloqueando')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#-----------------------------#
FUNCTION pol1157_nova_versao()#
#-----------------------------#

   SELECT *
     INTO p_ordem_sup.*
     FROM ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S'
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_sup')
      RETURN FALSE
   END IF
   
   UPDATE ordem_sup
      SET ies_versao_atual = 'N'
    WHERE cod_empresa 		= p_ordem_sup.cod_empresa
      AND num_oc      		= p_ordem_sup.num_oc
      AND ies_versao_atual= 'S' 
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup:03')
      RETURN FALSE
   END IF
   
   LET p_ordem_sup.num_versao = p_num_versao + 1
   
   INSERT INTO ordem_sup
      VALUES(p_ordem_sup.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ordem_sup:nova_versão')
      RETURN FALSE
   END IF
   
   DECLARE cq_prog CURSOR FOR
    SELECT *
      FROM prog_ordem_sup
    WHERE cod_empresa = p_ordem_sup.cod_empresa
      AND num_oc      = p_ordem_sup.num_oc
      AND num_versao  = p_num_versao
	    AND ies_situa_prog <> 'C'									# MANUEL 04-10-2012
   
   FOREACH cq_prog INTO p_prog_ordem_sup.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','prog_ordem_sup:cq_prog')
         RETURN FALSE
      END IF
      
      LET p_prog_ordem_sup.num_versao = p_ordem_sup.num_versao
      
      INSERT INTO prog_ordem_sup
         VALUES(p_prog_ordem_sup.*)
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','prog_ordem_sup:cq_prog')
         RETURN FALSE
      END IF
   
   END FOREACH
   
   LET p_num_versao = p_num_versao + 1

   RETURN TRUE
   
END FUNCTION
      
#------------------------------#
FUNCTION pol1157_atualiz_mapa()#
#------------------------------#

   LET pr_men[1].mensagem  = 'Ataulizando mapa'
   CALL pol1157_exib_mensagem()

   SELECT *
     INTO p_mapa.*
     FROM mapa_compras_data_454
    WHERE rowid = p_rowid

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','mapa_compras_data_454:02')
      RETURN FALSE
   END IF
   
   UPDATE mapa_compras_data_454
      SET ies_ajustado = 'S'
    WHERE rowid = p_rowid

   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','mapa_compras_data_454:03')
      RETURN FALSE
   END IF
   
   IF p_ies_atu_hist THEN
      IF NOT pol1157_atu_hist() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol1157_grava_hist() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------#
FUNCTION pol1157_atu_hist()#
#--------------------------#

   LET pr_men[1].mensagem  = 'Atualizando histórico'
   CALL pol1157_exib_mensagem()
   
   LET p_ocs = p_num_oc
   
   SELECT id_registro
     INTO p_id_registro
     FROM mapa_compras_hist_454
    WHERE cod_empresa = p_mapa.cod_empresa
      AND cod_item = p_mapa.cod_item
      AND seq_campo = p_mapa.seq_campo
      AND seq_periodo = p_mapa.seq_periodo
      AND num_ocs = p_ocs
      AND chave_processo = p_chave_processo
        
	IF STATUS = 100 THEN											#MANUEL 26-10-2012
		 IF NOT pol1157_grava_hist() THEN							#MANUEL 26-10-2012
			  RETURN FALSE											#MANUEL 26-10-2012
		 ELSE
		    RETURN TRUE
     END IF														#MANUEL 26-10-2012
	ELSE															  #MANUEL 26-10-2012
	   IF STATUS <> 0 THEN
		  CALL log003_err_sql('Lendo','mapa_compras_hist_454')
		  RETURN FALSE
	   END IF
	END IF															#MANUEL 26-10-2012
   
   UPDATE mapa_compras_hist_454
      SET qtd_ajustada = qtd_ajustada + p_qtd_alterada
    WHERE id_registro = p_id_registro

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','mapa_compras_hist_454')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1157_grava_hist()
#----------------------------#

   LET pr_men[1].mensagem  = 'Gravando histórico'
   CALL pol1157_exib_mensagem()
   
   SELECT MAX(id_registro)
     INTO p_id_registro
     FROM mapa_compras_hist_454

   IF p_id_registro IS NULL THEN
      LET p_id_registro = 1
   ELSE
      LET p_id_registro = p_id_registro + 1
   END IF     
   
   
   IF p_mapa.qtd_dia  < 0  THEN 
      LET p_mapa.qtd_dia = p_mapa.qtd_dia * -1 
   END IF 
    
   IF p_tip_ajuste  = 'C'  THEN 
      LET p_mapa.dat_entrega  = p_dat_ini
	    LET p_mapa.campo    	  = 'CORTE'
   ELSE
      LET p_mapa.dat_entrega  = p_dat_entrega
      LET p_mapa.campo    	  = 'ACRESCIMO'
   END IF 	  

   IF	p_mapa.dat_entrega IS NULL OR
		  p_mapa.dat_entrega = ' ' OR p_mapa.dat_entrega = '00/00/0000' THEN
      LET p_mapa.dat_entrega = p_dat_ini
   END IF 
   
   IF p_qtd_alterada = 0 OR p_qtd_alterada = NULL THEN
      LET p_mapa.dat_entrega = p_dat_ini
   END IF
   
   INSERT INTO mapa_compras_hist_454(
      id_registro,    
      cod_empresa,    
      cod_item,       
      seq_campo,      
      campo,          
      seq_periodo,    
      periodo,        
      sdo_oc,         
      qtd_dia,        
      qtd_ajustada,   
      tip_ajuste,     
      dat_entrega,                       
      dat_ini_periodo,
      dat_fim_periodo,
      usuario,        
      dat_proces,
      num_ocs,
	    chave_processo)
   VALUES(p_id_registro,
          p_mapa.cod_empresa,    
          p_mapa.cod_item,       
          p_mapa.seq_campo,      
          p_mapa.campo,          
          p_mapa.seq_periodo,    
          p_mapa.periodo,   
          p_qtd_sdo_oc,         
          p_mapa.qtd_dia,        
          p_qtd_alterada,  
          p_tip_ajuste, 
          p_mapa.dat_entrega,    
          p_dat_ini,
          p_dat_fim,
          p_user,
          p_dat_proces,
          p_ocs,
		      p_chave_processo)
        
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','mapa_compras_hist_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1157_acrescimo_oc()#
#------------------------------#
   
   DEFINE p_ordem        INTEGER,
          p_fornecedor   CHAR(15),
          p_item         CHAR(15),
          p_num_cotacao  DECIMAL(6,0)      
   
   INITIALIZE p_ordem_sup, 
              p_prog_ordem_sup, 
              p_dest_ordem_sup,
              p_estr_ordem_sup TO NULL

   INITIALIZE p_ordem, p_num_oc TO NULL
   
   LET p_rowid = pr_compl[p_ind].id_registro
   LET p_cod_item    = pr_item[p_ind].cod_item
   LET p_dat_entrega = pr_compl[p_ind].dat_entrega
   LET p_seq_periodo = pr_item[p_ind].seq_periodo
   LET p_qtd_solic = p_qtd_alterada
   LET p_qtd_ajuste = p_qtd_alterada
   
   {DELETE FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND chave_processo = p_chave_processo
      AND cod_item = p_cod_item
      AND seq_periodo = p_seq_periodo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','item_criticado_bi_454')
      RETURN FALSE
   END IF}
      
   IF NOT pol1157_le_intervalo() THEN
      RETURN FALSE
   END IF

   IF	p_dat_entrega = '00/00/0000' OR
      p_dat_entrega IS NULL OR
      p_dat_entrega < p_dat_ini    OR
		  p_dat_entrega > p_dat_fim  THEN  
      LET p_dat_entrega = p_dat_ini
   END IF 

   CALL pol1157_checa_dat_entrega()

   LET p_dat_prev = p_dat_entrega

   DECLARE cq_atu CURSOR FOR
    SELECT a.num_oc,
           a.num_versao,
           b.num_prog_entrega,
           a.ies_situa_oc,
           a.cod_fornecedor,
           a.cod_item,
           a.num_cotacao
      FROM ordem_sup a, 
           prog_ordem_sup b
     WHERE a.cod_empresa = p_cod_empresa 
       AND a.cod_item = p_cod_item
       AND a.ies_situa_oc IN ('A','R','X')
       AND a.ies_versao_atual = 'S'
       AND b.dat_entrega_prev = p_dat_entrega
       AND b.cod_empresa = a.cod_empresa
       AND b.num_oc = a.num_oc
       AND b.num_versao = a.num_versao
	     AND b.ies_situa_prog not in('C', 'L')   # MANUEL 05-10-2012
	     ORDER BY a.ies_situa_oc
       
   FOREACH cq_atu INTO p_ordem, p_num_versao, p_num_prog_entrega, 
      p_ies_situa_oc, p_fornecedor, p_item, p_num_cotacao
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ordem_sup:cq_atu')
         RETURN FALSE
      END IF 
      
      IF p_ies_situa_oc = 'R' THEN
         SELECT COUNT(ies_situacao)
           INTO p_count                       
           FROM cotacao_preco                             
          WHERE cod_empresa    = p_cod_empresa                         
            AND cod_fornecedor = p_fornecedor
            AND num_cotacao    = p_num_cotacao                        
            AND cod_item       = p_item
            AND dat_inic_validade <= p_dat_entrega
            AND dat_fim_validade  >= p_dat_entrega
            AND num_versao =                              
            (SELECT MAX(num_versao)                    
               FROM cotacao_preco                      
              WHERE cotacao_preco.cod_empresa    = p_cod_empresa   
                AND cotacao_preco.cod_fornecedor = p_fornecedor   
                AND cotacao_preco.num_cotacao    = p_num_cotacao
                AND cotacao_preco.cod_item       = p_item)  
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cotacao_preco:cq_atu')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            CONTINUE FOREACH
         END IF
      END IF

      LET p_num_oc = p_ordem
      EXIT FOREACH
   
   END FOREACH
   
   IF p_cod_frequencia = 1 AND p_seq_periodo > 14 THEN
      LET p_multi_programacao = TRUE
   ELSE
      LET p_multi_programacao = FALSE
   END IF

   IF p_num_oc IS NULL THEN
      IF p_multi_programacao THEN
         IF NOT pol1157_multi_programacao() THEN  
            RETURN FALSE
         END IF
      ELSE
         IF pol1157_tem_oc_no_mes() THEN

            LET p_ordem_sup.qtd_recebida = 0

            IF NOT pol1157_grava_prog_ord() THEN
               RETURN FALSE
            END IF
            
            IF p_ordem_sup.ies_situa_oc = 'R' THEN
         
               IF NOT p_travou THEN
                  IF NOT pol1157_nova_versao() THEN
                     RETURN FALSE
                  END IF
                  IF NOT pol1157_insere_prog_oc() THEN
                     RETURN FALSE
                  END IF
                  IF NOT pol1157_atu_ordem_sup() THEN
                     RETURN FALSE
                  END IF
                  LET p_ies_atu_hist = FALSE
                  LET p_ocs = p_ordem_sup.num_oc
                  IF NOT pol1157_atualiz_mapa() THEN
                     RETURN FALSE
                  END IF
               ELSE
                  CALL pol1157_del_oc_bloqueada()
                  RETURN TRUE
               END IF
               
            ELSE            
               #--- TEM NO MES  E OC não está realizada (A ou X)
               
               IF NOT pol1157_insere_prog_oc() THEN
                  RETURN FALSE
               END IF
            
               IF NOT pol1157_atu_ordem_sup() THEN
                  RETURN FALSE
               END IF
            
               LET p_ies_atu_hist = FALSE
               LET p_ocs = p_ordem_sup.num_oc
            
               IF NOT pol1157_atualiz_mapa() THEN
                  RETURN FALSE
               END IF
               
            END IF
         ELSE
            #---não tem OC, nem se quer no mês---
            
            IF NOT pol1157_gera_oc() THEN
               RETURN FALSE
            END IF
         END IF
      END IF
   ELSE
      #tem OC com a data da programação

      IF NOT pol1157_grava_prog_ord() THEN
         RETURN FALSE
      END IF
      
      IF p_ies_situa_oc = 'R' THEN
         IF NOT p_travou THEN
            IF NOT pol1157_nova_versao() THEN
               RETURN FALSE
            END IF
            IF NOT pol1157_atualiza_oc() THEN
               RETURN FALSE
            END IF
         ELSE
            CALL pol1157_del_oc_bloqueada()
         END IF
      ELSE
         IF NOT pol1157_atualiza_oc() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1157_del_oc_bloqueada()#
#----------------------------------#

   DELETE FROM oc_bloqueada_454 
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND chave_processo = p_chave_processo
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE','oc_bloqueada_454')
   END IF

   UPDATE ordem_sup
      SET ies_situa_oc = 'R'
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
      AND ies_versao_atual = 'S'
              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup')
      RETURN FALSE
   END IF

   DELETE FROM prog_ord_sup_454
    WHERE id_registro = p_id_prog_ord  

   IF STATUS <> 0 THEN                                                                              
      CALL log003_err_sql("DELETE","PROG_ORD_SUP_454")                                            
   END IF        
                                                                                      
      
END FUNCTION
       
#------------------------------#
FUNCTION pol1157_ve_status_oc()#
#------------------------------#

   SELECT mensagem
     INTO p_msg
     FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND chave_processo = p_chave_processo
   
   IF STATUS = 0 THEN
      LET p_travou = TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','oc_bloqueada_454')
      END IF
      LET p_msg = NULL
      LET p_travou = FALSE
   END IF
   
   SELECT COUNT(id_prog_ord)
     INTO p_count
     FROM item_criticado_bi_454
    WHERE cod_empresa = p_cod_empresa
      AND id_prog_ord = p_id_prog_ord

   IF p_count > 0 THEN
      LET p_tem_critica = TRUE
   END IF      
   
END FUNCTION

#-----------------------------------#
FUNCTION pol1157_checa_dat_entrega()#
#-----------------------------------#
   DEFINE p_dia INTEGER
      
   WHILE TRUE
      IF pol1157_e_feriado(p_dat_entrega) THEN
      ELSE
         LET p_dia = weekday(p_dat_entrega)
         IF p_dia >= 1 AND p_dia <= 5 THEN
            EXIT WHILE
         END IF
      END IF
      LET p_dat_entrega = p_dat_entrega + 1
   END WHILE

END FUNCTION

#-----------------------------#
FUNCTION pol1157_atualiza_oc()#
#-----------------------------#
   
   DEFINE p_situa CHAR(01)
   
   IF NOT pol1157_atu_ordem_sup() THEN
      RETURN FALSE
   END IF
   
   UPDATE prog_ordem_sup
      SET qtd_solic = qtd_solic + p_qtd_alterada
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
      AND num_versao  = p_num_versao
		  AND num_prog_entrega	= p_num_prog_entrega
              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup:atu')
      RETURN FALSE
   END IF
   
   LET p_ies_atu_hist = TRUE

   IF NOT pol1157_atualiz_mapa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#------------------------------#
FUNCTION pol1157_atu_ordem_sup()
#------------------------------#

   UPDATE ordem_sup
      SET qtd_solic = qtd_solic + p_qtd_alterada
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND ies_versao_atual = 'S' 
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('update','ordem_sup:atu')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   

#-------------------------#
FUNCTION pol1157_simular()
#-------------------------#
   
   INITIALIZE p_nom_tela, p_calc TO NULL 
   CALL log130_procura_caminho("pol1157a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1157a AT 2,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INPUT BY NAME p_calc.* WITHOUT DEFAULTS
   
      AFTER FIELD qtd_ajuste
         IF p_calc.qtd_ajuste is null or p_calc.qtd_ajuste <= 0 then
            error 'Informe a qtd a ajustar'
            next field qtd_ajuste
         end if
         
         
      AFTER FIELD lote_multiplo
         IF p_calc.lote_multiplo is null or p_calc.lote_multiplo <= 0 then
            error 'Informe o lote multiplo'
            next field lote_multiplo
         end if
         

      AFTER FIELD dat_ini
         IF p_calc.dat_ini is null then
            error 'Informe a data inicial'
            next field dat_ini
         end if

      AFTER FIELD dat_fim
         IF p_calc.dat_ini is null then
            error 'Informe a data final'
            next field dat_fim
         end if
   
      AFTER INPUT
         if INT_FLAG then
            exit input
         end if
         
         call pol1157_calcula()
         next field qtd_ajuste
   
   END INPUT
   
END FUNCTION

#-------------------------#
FUNCTION pol1157_calcula()#
#-------------------------#

   DEFINE p_dia, p_qtd_data INTEGER,
          p_data            DATE,
          p_qtd_programacao INTEGER,
          p_qtd_prog_calc   INTEGER,
          p_tot_ajuste      INTEGER,
          p_qtd_sobra       INTEGER,
          m_num_prog        INTEGER,
          p_pula_data       SMALLINT,
          p_rateia          INTEGER,
          m_qtd_data        INTEGER,
          l_qtd_data        INTEGER,
          m_salto           INTEGER,
          p_tot_ajustar     INTEGER,
          p_tot_ajustada    INTEGER,
          m_ind             INTEGER,
          ind_prog          INTEGER,
          p_resto           INTEGER,
          p_tot_calc        INTEGER,
          p_tot_prog        INTEGER,
          p_resto_calc      INTEGER,
          p_resto_prog      INTEGER
          
   DEFINE pr_data ARRAY[25] OF RECORD          
          dat_entrega       DATE,
          qtd_calculada     INTEGER,
          tot_calculada     INTEGER,
          qtd_programada    INTEGER,
          tot_programada    INTEGER
   END RECORD

   INITIALIZE pr_data TO NULL
             
   LET p_data = p_calc.dat_ini
   LET p_dat_fim = p_calc.dat_fim
   
   LET p_qtd_data = 0
   LET p_count = 0
   
   WHILE p_data <= p_dat_fim
      IF pol1157_e_feriado(p_data) THEN
      ELSE
         LET p_dia = weekday(p_data)
         IF p_dia >= 1 AND p_dia <= 5 THEN
            LET p_count = p_count + 1
            LET pr_data[p_count].dat_entrega = p_data
            LET pr_data[p_count].qtd_calculada = 0
            LET pr_data[p_count].tot_calculada = 0
            LET pr_data[p_count].qtd_programada = 0
            LET pr_data[p_count].tot_programada = 0
            LET p_qtd_data = p_qtd_data + 1
         END IF
      END IF
      LET p_data = p_data + 1
   END WHILE

   LET p_tot_ajustar = p_calc.qtd_ajuste
   LET p_qtd_prog_calc = p_calc.qtd_ajuste / p_qtd_data
   
   IF p_tot_ajustar < p_calc.lote_multiplo THEN
      LET p_calc.lote_multiplo = p_tot_ajustar
   END IF
   
   LET p_tot_calc = 0
   LET p_tot_prog = 0
   LET ind_prog = 1
   LET p_resto_calc = p_tot_ajustar MOD p_qtd_prog_calc
   
   FOR m_ind = 1 to p_count
       
       IF m_ind = p_count THEN
          LET p_qtd_prog_calc = p_qtd_prog_calc + p_resto_calc
       END IF
       LET pr_data[m_ind].qtd_calculada = p_qtd_prog_calc
       LET p_tot_calc = p_tot_calc + p_qtd_prog_calc
       LET pr_data[m_ind].tot_calculada = p_tot_calc
       
       IF p_tot_prog >= p_tot_calc THEN
          LET p_qtd_programacao = 0
       ELSE
          LET p_qtd_programacao = p_tot_calc - p_tot_prog
          IF p_qtd_programacao < p_calc.lote_multiplo THEN
             LET p_qtd_programacao = p_calc.lote_multiplo
          ELSE
             LET p_resto = p_qtd_programacao MOD p_calc.lote_multiplo
             IF p_resto > 0 THEN
                LET p_qtd_programacao = p_qtd_programacao + (p_calc.lote_multiplo - p_resto)
             END IF
          END IF
       END IF
       
       LET p_tot_prog = p_tot_prog + p_qtd_programacao

       IF p_tot_prog < p_tot_ajustar THEN
          LET p_resto_prog = p_tot_ajustar - p_tot_prog
          IF p_resto_prog < p_calc.lote_multiplo THEN
             LET p_qtd_programacao = p_qtd_programacao + p_resto_prog
             LET p_tot_prog = p_tot_prog + p_resto_prog
          END IF
       ELSE
          IF p_tot_prog > p_tot_ajustar THEN
             LET p_tot_prog = p_tot_prog - p_qtd_programacao
             LET p_qtd_programacao = p_tot_ajustar - p_tot_prog
             LET p_tot_prog = p_tot_prog + p_qtd_programacao
          END IF
       END IF
       
       LET pr_data[m_ind].qtd_programada = p_qtd_programacao
       LET pr_data[m_ind].tot_programada = p_tot_prog
                 
   END FOR

   CALL SET_COUNT(m_ind - 1)
   
   DISPLAY ARRAY pr_data TO sr_data.*
             
END FUNCTION

#-----------------------------------#
FUNCTION pol1157_multi_programacao()#
#-----------------------------------#

   DEFINE p_dia, p_qtd_data INTEGER,
          p_data            DATE,
          p_qtd_programacao INTEGER,
          p_qtd_prog_calc   INTEGER,
          p_tot_ajuste      INTEGER,
          p_qtd_sobra       INTEGER,
          m_num_prog        INTEGER,
          p_pula_data       SMALLINT,
          p_rateia          INTEGER,
          m_qtd_data        INTEGER,
          l_qtd_data        INTEGER,
          m_salto           INTEGER,
          p_tot_ajustar     INTEGER,
          p_tot_ajustada    INTEGER,
          m_ind             INTEGER,
          ind_prog          INTEGER,
          p_resto           INTEGER,
          p_tot_calc        INTEGER,
          p_tot_prog        INTEGER,
          p_resto_calc      INTEGER,
          p_resto_prog      INTEGER
          
   DEFINE pr_data ARRAY[25] OF RECORD          
          dat_entrega       DATE,
          qtd_calculada     INTEGER,
          tot_calculada     INTEGER,
          qtd_programada    INTEGER,
          tot_programada    INTEGER
   END RECORD

   INITIALIZE pr_data TO NULL
             
   LET p_data = p_dat_ini
   
   LET p_qtd_data = 0
   LET p_count = 0
   
   WHILE p_data <= p_dat_fim
      IF pol1157_e_feriado(p_data) THEN
      ELSE
         LET p_dia = weekday(p_data)
         IF p_dia >= 1 AND p_dia <= 5 THEN
            LET p_count = p_count + 1
            LET pr_data[p_count].dat_entrega = p_data
            LET pr_data[p_count].qtd_calculada = 0
            LET pr_data[p_count].tot_calculada = 0
            LET pr_data[p_count].qtd_programada = 0
            LET pr_data[p_count].tot_programada = 0
            LET p_qtd_data = p_qtd_data + 1
         END IF
      END IF
      LET p_data = p_data + 1
   END WHILE

   IF p_qtd_data > 0 THEN
      LET p_dat_entrega = pr_data[1].dat_entrega
   END IF
   
   IF p_qtd_data <= 1 OR  p_qtd_alterada < p_qtd_lote_multiplo THEN
      LET p_multi_programacao = FALSE
   END IF

   IF NOT pol1157_gera_oc() THEN
      RETURN FALSE
   END IF

   IF NOT p_multi_programacao THEN
      RETURN TRUE
   END IF

   LET p_tot_ajustar = p_qtd_alterada
   LET p_qtd_prog_calc = p_tot_ajustar / p_qtd_data
   
   LET p_tot_calc = 0
   LET p_tot_prog = 0
   LET ind_prog = 1
   LET p_resto_calc = p_tot_ajustar MOD p_qtd_prog_calc
   
   FOR m_ind = 1 to p_count
       
       IF m_ind = p_count THEN
          LET p_qtd_prog_calc = p_qtd_prog_calc + p_resto_calc
       END IF
       
       LET pr_data[m_ind].qtd_calculada = p_qtd_prog_calc
       LET p_tot_calc = p_tot_calc + p_qtd_prog_calc
       LET pr_data[m_ind].tot_calculada = p_tot_calc
       
       IF p_tot_prog >= p_tot_calc THEN
          LET p_qtd_programacao = 0
       ELSE
          LET p_qtd_programacao = p_tot_calc - p_tot_prog
          IF p_qtd_programacao < p_qtd_lote_multiplo THEN
             LET p_qtd_programacao = p_qtd_lote_multiplo
          ELSE
             LET p_resto = p_qtd_programacao MOD p_qtd_lote_multiplo
             IF p_resto > 0 THEN
                LET p_qtd_programacao = p_qtd_programacao + (p_qtd_lote_multiplo - p_resto)
             END IF
          END IF
       END IF
       
       LET p_tot_prog = p_tot_prog + p_qtd_programacao

       IF p_tot_prog < p_tot_ajustar THEN
          LET p_resto_prog = p_tot_ajustar - p_tot_prog
          IF p_resto_prog < p_qtd_lote_multiplo THEN
             LET p_qtd_programacao = p_qtd_programacao + p_resto_prog
             LET p_tot_prog = p_tot_prog + p_resto_prog
          END IF
       ELSE
          IF p_tot_prog > p_tot_ajustar THEN
             LET p_tot_prog = p_tot_prog - p_qtd_programacao
             LET p_qtd_programacao = p_tot_ajustar - p_tot_prog
             LET p_tot_prog = p_tot_prog + p_qtd_programacao
          END IF
       END IF
       
       LET pr_data[m_ind].qtd_programada = p_qtd_programacao
       LET pr_data[m_ind].tot_programada = p_tot_prog
                 
   END FOR
   
   LET p_seq_prog = 0
   LET ind_prog = m_ind - 1

   FOR m_ind = 1 TO ind_prog
       
       IF pr_data[m_ind].qtd_programada > 0 THEN
          LET p_dat_entrega  = pr_data[m_ind].dat_entrega 
          LET p_qtd_alterada = pr_data[m_ind].qtd_programada      
          LET p_seq_prog = p_seq_prog + 1
          
          IF NOT pol1157_insere_prog_oc() THEN
             RETURN FALSE
          END IF

          IF NOT pol1157_grava_prog_ord() THEN
             RETURN FALSE
          END IF

          IF p_ies_status_oc = 'X' THEN
             LET p_msg = 'A ORDEM FOI BLOQUEADA PORQUE JA EXITEM ORDENS BLOQUEADAS PARA PERIODOS ANTERIORES'
             IF NOT pol1157_ins_oc_bloqueada() THEN
                RETURN FALSE
             END IF
          END IF

       END IF

   END FOR
   
   RETURN TRUE
                
END FUNCTION

#-------------------------------#
FUNCTION pol1157_e_feriado(p_dt)#
#-------------------------------#
   
   DEFINE p_ies_situa CHAR(01),
          p_dt        DATE
   
   SELECT ies_situa
     INTO p_ies_situa
     FROM feriado
    WHERE cod_empresa = p_cod_empresa
      AND dat_ref = p_dt
   
   IF STATUS <> 0 OR p_ies_situa IS NULL THEN
      LET p_ies_situa = 'N'
   END IF      
   
   IF p_ies_situa = 'S' THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
   
END FUNCTION

#-------------------------#
FUNCTION pol1157_gera_oc()#
#-------------------------#

   SELECT COUNT(a.num_oc)
     INTO p_count
     FROM ordem_sup a, prog_ordem_sup b
    WHERE a.cod_empresa = p_cod_empresa
      AND a.ies_versao_atual = 'S'
      AND a.cod_item = p_cod_item
      AND a.ies_situa_oc = 'X'
      AND b.cod_empresa = a.cod_empresa
      AND b.num_oc = a.num_oc
      AND b.num_versao = a.num_versao
      AND b.ies_situa_prog <> 'C'
      AND (b.qtd_solic - b.qtd_recebida) > 0
      AND b.dat_entrega_prev < p_dat_entrega

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','ordem_sup:count')
      RETURN FALSE
   END IF
      
    IF p_count > 0 THEN
       LET p_ies_status_oc = 'X'
       LET p_checa_trava = 'N'                                               
    ELSE
       LET p_ies_status_oc = 'A'
       LET p_checa_trava = 'S'   
    END IF
   
   IF NOT pol1157_le_item_sup() THEN
      RETURN FALSE
   END IF

   IF pol1157_prx_num_oc() = FALSE THEN
      RETURN FALSE
   END IF
   

   IF pol1157_insere_oc() = FALSE THEN
      RETURN FALSE
   END IF
      
   IF pol1157_insere_dest_oc() = FALSE THEN
      RETURN FALSE
   END IF

   LET p_num_oc = p_ordem_sup.num_oc

   IF NOT p_multi_programacao THEN
      
      LET p_seq_prog = 1
      
      IF pol1157_insere_prog_oc() = FALSE THEN
         RETURN FALSE
      END IF

      IF NOT pol1157_grava_prog_ord() THEN
         RETURN FALSE
      END IF
       
      IF p_ies_status_oc = 'X' THEN
         LET p_msg = 'A ORDEM FOI BLOQUEADA PORQUE JA EXITEM ORDENS BLOQUEADAS PARA PERIODOS ANTERIORES'
         IF NOT pol1157_ins_oc_bloqueada() THEN
            RETURN FALSE
         END IF
      END IF
      
   END IF

   IF p_ies_tip_item = 'B' THEN
      IF pol1157_insere_estrut() = FALSE THEN
         RETURN FALSE
      END IF
   END IF
   
   LET p_ocs = m_prx_num_oc
   
   LET p_ies_atu_hist = FALSE
   IF NOT pol1157_atualiz_mapa() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION pol1157_le_item_sup()
#-----------------------------#
   
   SELECT cod_comprador,
          cod_progr,
          gru_ctr_desp,
          num_conta,
          cod_tip_despesa,
          ies_tip_incid_icms,
          ies_tip_incid_ipi,
          cod_fiscal
     INTO m_cod_comprador,
          m_cod_progr,
          m_gru_ctr_desp,
          m_num_conta,
          m_cod_tip_despesa,
          m_ies_tip_incid_icms,
          m_ies_tip_incid_ipi,
          m_cod_fiscal
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF sqlca.sqlcode = NOTFOUND THEN
      CALL log0030_mensagem("Item Não Localizado na Tab. item_sup","exclamation")
      RETURN FALSE
   END IF

   IF m_num_conta IS NULL THEN
      LET m_num_conta = 0
   END IF

   IF m_gru_ctr_desp IS NULL THEN 
      LET m_gru_ctr_desp = 0
   END IF

   SELECT pct_ipi, 
          cod_unid_med,
          ies_tip_item,
          cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc, 
          cod_cla_uso           
     INTO m_pct_ipi, 
          m_cod_unid_med,
          p_ies_tip_item,
          p_cod_lin_prod,
          p_cod_lin_recei,
          p_cod_seg_merc, 
          p_cod_cla_uso           
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item:und')
      RETURN FALSE
   END IF

   SELECT cod_horizon
     INTO p_cod_horizon
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item_man:oc')
      RETURN FALSE
   END IF
   
   SELECT qtd_dias_horizon
     INTO p_qtd_dias
     FROM horizonte
    WHERE cod_empresa = p_cod_empresa
      AND cod_horizon = p_cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#----------------------------#
 FUNCTION pol1157_prx_num_oc()
#----------------------------#
   LET m_prx_num_oc = 0

   SELECT prx_num_oc
     INTO m_prx_num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','par_sup')
      RETURN FALSE
   END IF

   IF m_prx_num_oc IS NULL THEN
      LET m_prx_num_oc = 0
   END IF

   UPDATE par_sup
      SET prx_num_oc = m_prx_num_oc + 1
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','par_sup')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1157_insere_oc()
#---------------------------#
   
   DEFINE p_cod_secao_receb LIKE ordem_sup.cod_secao_receb
   
   SELECT val_texto
     INTO p_cod_secao_receb
     FROM man_inf_com_item 
    WHERE empresa = p_cod_empresa
      AND item = p_cod_item
      AND des_inf_com = 'Unidade Funcional.'
   
   IF STATUS <> 0 OR p_cod_secao_receb IS NULL THEN
      LET p_cod_secao_receb = ' '
   END IF
   
   LET p_ordem_sup.cod_empresa        = p_cod_empresa
   LET p_ordem_sup.num_oc             = m_prx_num_oc
   LET p_ordem_sup.num_versao         = 1
   LET p_ordem_sup.num_versao_pedido  = 0
   LET p_ordem_sup.ies_versao_atual   = 'S'
   LET p_ordem_sup.cod_item           = p_cod_item
   LET p_ordem_sup.num_pedido         = 0
   LET p_ordem_sup.ies_situa_oc       = p_ies_status_oc
   LET p_ordem_sup.ies_origem_oc      = 'M'
   LET p_ordem_sup.ies_item_estoq     = 'S' 
   LET p_ordem_sup.ies_imobilizado    = 'N'
   LET p_ordem_sup.cod_unid_med       = m_cod_unid_med
   LET p_ordem_sup.dat_emis           = TODAY
   LET p_ordem_sup.qtd_solic          = p_qtd_alterada
   LET p_ordem_sup.dat_entrega_prev   = p_dat_entrega
   LET p_ordem_sup.fat_conver_unid    = 1
   LET p_ordem_sup.qtd_recebida       = 0
   LET p_ordem_sup.pre_unit_oc        = 0
   LET p_ordem_sup.pct_ipi            = m_pct_ipi
   LET p_ordem_sup.cod_moeda          = 1
   LET p_ordem_sup.cod_fornecedor     = ' '
   LET p_ordem_sup.cnd_pgto           = 0
   LET p_ordem_sup.cod_mod_embar      = 0
   LET p_ordem_sup.num_docum          = '0'
   LET p_ordem_sup.gru_ctr_desp       = m_gru_ctr_desp
   LET p_ordem_sup.cod_secao_receb    = p_cod_secao_receb
   LET p_ordem_sup.cod_progr          = m_cod_progr
   LET p_ordem_sup.cod_comprador      = m_cod_comprador
   LET p_ordem_sup.pct_aceite_dif     = 0
   LET p_ordem_sup.ies_tip_entrega    = 'D'
   LET p_ordem_sup.ies_liquida_oc     = '2'
   LET p_ordem_sup.dat_abertura_oc    = TODAY
   LET p_ordem_sup.num_oc_origem      = m_prx_num_oc
   LET p_ordem_sup.qtd_origem         = p_qtd_alterada
   LET p_ordem_sup.ies_tip_incid_ipi  = m_ies_tip_incid_ipi
   LET p_ordem_sup.ies_tip_incid_icms = m_ies_tip_incid_icms
   LET p_ordem_sup.cod_fiscal         = m_cod_fiscal
   LET p_ordem_sup.cod_tip_despesa    = m_cod_tip_despesa
   LET p_ordem_sup.ies_insp_recebto   = '4'
   LET p_ordem_sup.dat_origem         = TODAY

   INSERT INTO ordem_sup VALUES (p_ordem_sup.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inderindo','ordem_sup')
      RETURN  FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1157_insere_prog_oc()
#--------------------------------#

   LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
   LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
   LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao
   LET p_prog_ordem_sup.num_prog_entrega = p_seq_prog
   LET p_prog_ordem_sup.ies_situa_prog   = 'F'							# MANUEL 04-10-2012
   LET p_prog_ordem_sup.dat_entrega_prev = p_dat_entrega
   LET p_prog_ordem_sup.qtd_solic        = p_qtd_alterada
   LET p_prog_ordem_sup.qtd_recebida     = 0
   LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_abertura_oc
   LET p_prog_ordem_sup.dat_origem = TODAY
   
   INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','prog_ordem_sup')
      RETURN FALSE
   END IF

   LET p_num_versao = p_prog_ordem_sup.num_versao                                                                 
   LET p_num_prog_entrega = p_prog_ordem_sup.num_prog_entrega 
   
   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1157_insere_dest_oc()
#--------------------------------#

   LET p_dest_ordem_sup.cod_empresa        = p_ordem_sup.cod_empresa
   LET p_dest_ordem_sup.num_oc             = p_ordem_sup.num_oc
   LET p_dest_ordem_sup.cod_area_negocio   = p_cod_lin_prod
   LET p_dest_ordem_sup.cod_lin_negocio    = p_cod_lin_recei
   LET p_dest_ordem_sup.pct_particip_comp  = 100
   LET p_dest_ordem_sup.cod_secao_receb    = p_ordem_sup.cod_secao_receb
   LET p_dest_ordem_sup.num_conta_deb_desp = m_num_conta
   LET p_dest_ordem_sup.qtd_particip_comp  = p_ordem_sup.qtd_solic
   LET p_dest_ordem_sup.num_transac        = 0
   LET p_dest_ordem_sup.num_docum          = p_ordem_sup.num_docum

   INSERT INTO dest_ordem_sup VALUES (p_dest_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','dest_ordem_sup')
      RETURN  FALSE
   END IF

   RETURN  TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1157_insere_estrut()
#-------------------------------#
   
   DEFINE p_pct_refug   LIKE estrutura.pct_refug
   
   DECLARE cq_estr CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_ordem_sup.cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_estr INTO 
           p_estr_ordem_sup.cod_item_comp,
           p_estr_ordem_sup.qtd_necessaria,
           p_pct_refug

      LET p_estr_ordem_sup.cod_empresa    = p_ordem_sup.cod_empresa
      LET p_estr_ordem_sup.num_oc         = p_ordem_sup.num_oc
      LET p_estr_ordem_sup.qtd_necessaria = p_estr_ordem_sup.qtd_necessaria +
          (p_estr_ordem_sup.qtd_necessaria * p_pct_refug / 100)
      
      SELECT cod_empresa
        FROM estrut_ordem_sup
       WHERE cod_empresa = p_estr_ordem_sup.cod_empresa 
         AND num_oc = p_estr_ordem_sup.num_oc 
         AND cod_item_comp = p_estr_ordem_sup.cod_item_comp
      
      IF STATUS = 100 THEN
         INSERT INTO estrut_ordem_sup VALUES (p_estr_ordem_sup.*)
      ELSE
         IF STATUS = 0 THEN																								
            UPDATE estrut_ordem_sup																				
             	 SET qtd_necessaria = qtd_necessaria + p_estr_ordem_sup.qtd_necessaria
             WHERE cod_empresa = p_estr_ordem_sup.cod_empresa 
               AND num_oc = p_estr_ordem_sup.num_oc 
               AND cod_item_comp = p_estr_ordem_sup.cod_item_comp
         ELSE         
         		CALL log003_err_sql('Lendo','estrut_ordem_sup')
         		RETURN  FALSE
         END IF 
      END IF
      
      IF STATUS <> 0 THEN
      	 CALL log003_err_sql('Gravando','estrut_ordem_sup')
         RETURN  FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION
#---------------------------#
FUNCTION pol1157_historico()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol11575") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol11575 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1157_limpa_tela()
   LET p_chave_processo = NULL
   
   MENU "OPCAO"
      COMMAND "Listar" "Relatório dos acertos efetuados"
         IF pol1157_param_lst() THEN
            CALL pol1157_listagem()
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   
   CLOSE WINDOW w_pol11575

END FUNCTION
#---------------------------#
FUNCTION pol1157_observacao()#
#---------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol11576") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol11576 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   CALL pol1157_limpa_tela()
   DISPLAY p_chave_processo to chave_processo
   
   MENU "OPCAO"
      COMMAND "Incluir" "Incluir observação."
         CALL pol1157_inclusao_obs() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta Observações."
         IF pol1157_consulta_obs() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1157_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1157_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica Observações."
         IF p_ies_cons THEN
            CALL pol1157_modificacao_obs() RETURNING p_status  
            IF p_status THEN
               DISPLAY w_cod_item TO cod_item
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui Observações."
         IF p_ies_cons THEN
            CALL pol1157_exclusao_obs() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol11576

END FUNCTION
#-----------------------#
 FUNCTION pol11576_popup()
#-----------------------#

    DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol11576
         IF p_codigo IS NOT NULL THEN
           LET w_cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
   				 SELECT den_item[1,40]
     			 INTO w_den_item
     			 FROM item
    			 WHERE cod_item = p_codigo
    			 AND cod_empresa = p_cod_empresa
   				 DISPLAY w_den_item TO den_item   
         END IF
   END CASE 

END FUNCTION
#--------------------------------#
 FUNCTION pol1157_inclusao_obs()
#--------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_chave_processo to chave_processo
   INITIALIZE pr_txt TO NULL
   INITIALIZE w_cod_item TO NULL
   LET p_opcao = 'I'
   
   IF pol1157_edita_dados() THEN      
      IF pol1157_edita_obs('I') THEN      
         IF pol1157_grava_dados_obs() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION
#-----------------------------#
 FUNCTION pol1157_edita_dados()
#-----------------------------#
   DEFINE 	l_count smallint,
			l_count1 smallint
   
   LET INT_FLAG = FALSE
   
   INPUT w_cod_item   WITHOUT DEFAULTS
    FROM cod_item 
	  
      AFTER FIELD cod_item
      
      IF w_cod_item IS NULL THEN
   	     LET w_den_item = 'GERAL'
	       LET p_msg = "Já existe texto geral para o processo - Use modificar"
	       SELECT COUNT(*) 
         into l_count		 
		     FROM  mapa_compras_obs_454
		    WHERE cod_empresa    = p_cod_empresa
		      AND chave_processo = p_chave_processo
		      AND (cod_item IS NULL OR cod_item = ' ')
   	  ELSE
	       SELECT COUNT(*) 
           INTO l_count		 
		       FROM  mapa_compras_data_454
		      WHERE cod_empresa    = p_cod_empresa
		        AND chave_processo = p_chave_processo
		        AND cod_item 	  = w_cod_item
		     IF l_count = 0 THEN
		        LET p_msg = 'O processo da tela não contem o item informado!'
		        CALL log0030_mensagem(p_msg, 'excla')
		        NEXT FIELD cod_item
		     END IF

 		     SELECT den_item[1,40]
			    INTO w_den_item
			    FROM item
		     WHERE cod_item = w_cod_item
		       AND cod_empresa = p_cod_empresa
		     IF STATUS <> 0 THEN
			      LET p_msg = "Item não cadastrado !!!"
			      CALL log0030_mensagem(p_msg,'exclamation')
			      NEXT FIELD cod_item 
         END IF
         DISPLAY w_den_item TO den_item  
         
	       LET p_msg = "Já existe texto para o item/processo - Use modificar"
	       SELECT COUNT(*) 
         into l_count		 
		     FROM  mapa_compras_obs_454
		    WHERE cod_empresa    = p_cod_empresa
		      AND chave_processo = p_chave_processo
		      AND cod_item 	  = w_cod_item
      END IF

		  IF STATUS <> 0 THEN
		     CALL log003_err_sql('lendo 1','mapa_compras_obs_454')
			   RETURN FALSE
		  END IF 	  

	    IF l_count > 0 THEN
			   CALL log0030_mensagem(p_msg,'exclamation')
			   NEXT FIELD cod_item  
	 	  END IF
	 	  
      ON KEY (control-z)
         CALL pol11576_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
	  DISPLAY p_chave_processo to chave_processo
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
#-------------------------------------#
 FUNCTION pol1157_edita_obs(p_funcao)
#-------------------------------------#     

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   CALL SET_COUNT(p_index1)
   
   INPUT ARRAY pr_txt
      WITHOUT DEFAULTS FROM sr_txt.*
      
      BEFORE ROW
         LET p_index1 = ARR_CURR()
         LET s_index1 = SCR_LINE()  
         
      AFTER FIELD texto
      
 {     AFTER ROW
         IF NOT INT_FLAG THEN                                    
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN    
            ELSE
               IF pr_txt[p_index1].texto IS NULL THEN
                  ERROR 'Campo com preenchimento obrigatório !!!'
                  NEXT FIELD texto
               END IF
            END IF
         END IF }
                                   
   END INPUT 

   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      IF p_funcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
		     DISPLAY p_chave_processo to chave_processo
      ELSE
        CALL pol1157_carrega_obs() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
         
END FUNCTION

#---------------------------------#
 FUNCTION pol1157_carrega_obs()
#---------------------------------#
   
   DEFINE p_sql CHAR(3000)
   
   INITIALIZE pr_txt TO NULL
   LET p_index1 = 1

   IF w_cod_item IS NULL OR w_cod_item = ' ' THEN
      LET p_sql =
          "SELECT texto, num_seq FROM mapa_compras_obs_454 ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
	        "   AND chave_processo	= ",p_chave_processo," ",
          "     AND (cod_item IS NULL OR cod_item = ' ') ",
          " ORDER BY num_seq "
   ELSE
      LET p_sql =
          "SELECT texto, num_seq FROM mapa_compras_obs_454 ",
          " WHERE cod_empresa = '",p_cod_empresa,"' ",
	        "   AND chave_processo	= ",p_chave_processo," ",
          "   AND cod_item = '",w_cod_item,"' ",
          " ORDER BY num_seq "
   END IF
   
   PREPARE query_obs FROM p_sql    
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Preparando', 'cursor:cq_cons_obs')
      RETURN
   END IF
   
   DECLARE cq_cons_obs CURSOR FOR query_obs
     
   FOREACH cq_cons_obs
      INTO pr_txt[p_index1].texto
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "cursor: cq_array tabela mapa_compras_obs_454 ")
         RETURN FALSE
      END IF
      
      LET p_index1 = p_index1 + 1
      
      IF p_index > 15 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION 

#----------------------------------#
 FUNCTION pol1157_grava_dados_obs()
#----------------------------------#
   
   DEFINE p_incluiu SMALLINT
   
   CALL log085_transacao("BEGIN")
   
   LET p_incluiu = FALSE
   
   IF w_cod_item IS NULL THEN
      DELETE FROM mapa_compras_obs_454
       WHERE cod_empresa 		= p_cod_empresa
	       AND chave_processo	= p_chave_processo
         AND cod_item	IS NULL
   ELSE
      DELETE FROM mapa_compras_obs_454
       WHERE cod_empresa 		= p_cod_empresa
	       AND chave_processo	= p_chave_processo
          AND cod_item			= w_cod_item 
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando 1", "mapa_compras_obs_454")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind1 = 1 TO ARR_COUNT()
       IF pr_txt[p_ind1].texto IS NOT NULL THEN
          
		       INSERT INTO mapa_compras_obs_454
		       VALUES (p_cod_empresa,
		               p_chave_processo,
					         w_cod_item,
					         p_ind1,
		               pr_txt[p_ind1].texto)
			
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "mapa_compras_obs_454")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
		       LET p_incluiu = TRUE
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   IF p_opcao = "I" THEN
      IF NOT p_incluiu THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION
 
#-------------------------------#
 FUNCTION pol1157_consulta_obs()
#-------------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_chave_processo to chave_processo
   LET w_cod_itema = w_cod_item
   LET INT_FLAG = FALSE
   LET p_excluiu = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      mapa_compras_obs_454.cod_item
	  
      ON KEY (control-z)
         CALL pol11576_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET w_cod_item = w_cod_itema
         CALL pol1157_exibe_dados_obs() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_item ",
                  "  FROM mapa_compras_obs_454",
                  " WHERE   ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
				          "   AND chave_processo = ",p_chave_processo

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO w_cod_item

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1157_exibe_dados_obs() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#--------------------------------#
 FUNCTION pol1157_exibe_dados_obs()
#--------------------------------#

   LET p_excluiu = FALSE
   
	 SELECT den_item[1,40]
		 INTO w_den_item
		 FROM item
		WHERE cod_item = w_cod_item
	    AND cod_empresa = p_cod_empresa
       
   IF STATUS <> 0 THEN 
      LET w_den_item= ''
   END IF

   DISPLAY w_cod_item TO cod_item
   DISPLAY w_den_item TO den_item  
        
   LET p_index = 1

   IF NOT pol1157_carrega_obs() THEN
      RETURN FALSE
   END IF

   CALL SET_COUNT(p_index1 - 1)
   
   IF p_index1 > 15 THEN
      DISPLAY ARRAY pr_txt TO sr_txt.*
   ELSE
      INPUT ARRAY pr_txt WITHOUT DEFAULTS FROM sr_txt.*
         BEFORE INPUT
         EXIT INPUT
      END INPUT
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1157_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET w_cod_itema = w_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO w_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO w_cod_item
         
      END CASE

      IF STATUS = 0 THEN
         
         IF w_cod_item IS NULL THEN
            IF w_cod_itema IS NULL THEN
               CONTINUE WHILE
            END IF
         ELSE
            IF w_cod_itema IS NULL THEN
            ELSE
               IF w_cod_item = w_cod_itema THEN
                  CONTINUE WHILE
               END IF
            END IF      
         END IF
         
         LET p_count = 0
         
         IF w_cod_item IS NULL THEN
            SELECT COUNT(chave_processo)
              INTO p_count
              FROM mapa_compras_obs_454
             WHERE chave_processo  = p_chave_processo
		           AND cod_empresa    	= p_cod_empresa
		           AND (cod_item IS NULL OR cod_item = ' ')
         ELSE		           
            SELECT COUNT(chave_processo)
              INTO p_count
              FROM mapa_compras_obs_454
             WHERE chave_processo = p_chave_processo
		           AND cod_empresa = p_cod_empresa
		           AND cod_item  = w_cod_item
         END IF
                                 
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo 4", "mapa_compras_obs_454")
            RETURN
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1157_exibe_dados_obs() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET w_cod_item = w_cod_itema
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#---------------------------------#
 FUNCTION pol1157_modificacao_obs()
#---------------------------------#
   
   IF p_excluiu THEN
      LET p_msg = 'Não há dados na tela, p/ serem excluídos!'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1157_prende_registro() THEN
      IF pol1157_edita_obs('M') THEN
         IF pol1157_grava_dados_obs() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION
#----------------------------------#
 FUNCTION pol1157_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_item 
      FROM mapa_compras_obs_454 
     WHERE cod_empresa = p_cod_empresa 
       AND (cod_item = w_cod_item OR 
            cod_item IS NULL OR
            cod_item = ' ')
	     AND chave_processo = p_chave_processo
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo 5","mapa_compras_obs_454 ")
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol1157_exclusao_obs()
#-------------------------------#

   IF p_excluiu THEN
      LET p_msg = 'Não há dados na tela, p/ serem excluídos!'
      CALL log0030_mensagem(p_msg, 'exclamation')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   
   LET p_excluiu = FALSE
   
   IF pol1157_prende_registro() THEN
      IF w_cod_item IS NULL THEN
         DELETE FROM mapa_compras_obs_454
		   	  WHERE cod_empresa 		= p_cod_empresa
			      AND chave_processo 	= p_chave_processo
			      AND cod_item IS NULL 
      ELSE
         DELETE FROM mapa_compras_obs_454
		   	  WHERE cod_empresa 		= p_cod_empresa
			      AND cod_item    		= w_cod_item
			      AND chave_processo 	= p_chave_processo
      END IF
      
      IF STATUS = 0 THEN               
         INITIALIZE w_cod_item TO NULL
         INITIALIZE pr_txt TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
		     DISPLAY p_chave_processo to chave_processo
         LET p_retorno = TRUE 
      ELSE
         CALL log003_err_sql("Excluindo 2","mapa_compras_obs_454")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      LET p_excluiu = TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  


#---------------------------#
FUNCTION pol1157_param_lst()#
#---------------------------#

   LET INT_FLAG = FALSE
   INITIALIZE p_par_lst TO NULL

   IF p_chave_processo IS NULL THEN
		  SELECT MAX(chave_processo) 
		    INTO p_chave_processo
		    FROM mapa_compras_data_454
		   WHERE cod_empresa = p_cod_empresa

		  IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO','MAPA_COMPRAS_DATA_454:CHAVE_PROCESSO')
		     RETURN FALSE
      END IF
   END IF
   
   LET p_par_lst.chave_processo = p_chave_processo
   LET p_par_lst.tip_ajuste = 'T'
   LET p_par_lst.ajuste_efetuado = 'T'
   
   INPUT BY NAME p_par_lst.*
      WITHOUT DEFAULTS

      AFTER FIELD chave_processo
      
      IF p_par_lst.chave_processo IS NOT NULL THEN
         SELECT COUNT(chave_processo)
           into p_count
           from mapa_compras_hist_454
          where cod_empresa = p_cod_empresa
            and chave_processo = p_par_lst.chave_processo
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','mapa_compras_hist_454')
            NEXT FIELD chave_processo
         END IF
         IF p_count = 0 THEN
            ERROR 'Processo inexistente!'
            NEXT FIELD chave_processo
         END IF
      END IF
      
      AFTER FIELD dat_fim
      
         IF p_par_lst.dat_fim IS NOT NULL THEN
            IF p_par_lst.dat_ini IS NOT NULL THEN
               IF p_par_lst.dat_fim < p_par_lst.dat_ini THEN
                  ERROR 'A data final deve ser maior que a data inicial!'
                  NEXT FIELD dat_ini
               END IF
            END IF
         END IF

      AFTER FIELD item_de
         
         IF p_par_lst.item_de IS NOT NULL THEN
            CALL pol1157_le_den_item(p_par_lst.item_de)
            IF p_den_item IS NULL THEN
               ERROR 'Iem inexistente!'
               NEXT FIELD item_de
            END IF
            DISPLAY p_den_item TO den_item_de
         ELSE
            DISPLAY '' TO den_item_de
         END IF

      AFTER FIELD item_ate
         
         IF p_par_lst.item_ate IS NOT NULL THEN
            CALL pol1157_le_den_item(p_par_lst.item_ate)
            IF p_den_item IS NULL THEN
               ERROR 'Iem inexistente!'
               NEXT FIELD item_ate
            END IF
            DISPLAY p_den_item TO den_item_ate
            IF p_par_lst.item_de IS NOT NULL THEN
               IF p_par_lst.item_ate < p_par_lst.item_de THEN
                  ERROR 'O item final deve ser maior que a item inicial!'
                  NEXT FIELD item_de
               END IF
            END IF
         ELSE
            DISPLAY '' TO den_item_ate
         END IF

      AFTER FIELD ajuste_efetuado
         
         IF p_par_lst.ajuste_efetuado MATCHES '[IDT]' THEN
         ELSE
            ERROR 'Valor inválido para o campo!'
            NEXT FIELD ajuste_efetuado
         END IF

      AFTER FIELD cod_lin_prod

	     if p_par_lst.cod_lin_prod is not null then
	        select count(cod_lin_prod)
	          into p_count
	          from item
	         where cod_empresa = p_cod_empresa
	           and cod_lin_prod = p_par_lst.cod_lin_prod
	        if STATUS <> 0 then
	           call log003_err_sql('Lendo','item')
	           RETURN false
	        end if
	        if p_count = 0 then
	           error 'Não existe itens com essa linha de produção!'
	           NEXT FIELD cod_lin_prod
	        end if

         SELECT den_estr_linprod
           into p_den_estr_linprod
           from linha_prod
          where cod_lin_prod = p_par_lst.cod_lin_prod 
            and cod_lin_recei = 0
            and cod_seg_merc = 0
            and cod_cla_uso = 0

	        if STATUS <> 0 then
	           call log003_err_sql('Lendo','linha_prod')
	           RETURN false
	        end if
	       
	       DISPLAY p_den_estr_linprod to den_estr_linprod 
	       
	     END IF

      AFTER FIELD tip_ajuste
         
         IF p_par_lst.tip_ajuste MATCHES '[ACT]' THEN
            IF p_par_lst.tip_ajuste <> 'A' THEN
               LET p_par_lst.oc_sem_pc = 'N'
               DISPLAY 'N' TO oc_sem_pc
               EXIT INPUT
            END IF
         ELSE
            ERROR 'Valor inválido para o campo!'
            NEXT FIELD tip_ajuste
         END IF

      AFTER FIELD oc_sem_pc
         
         IF p_par_lst.oc_sem_pc MATCHES '[SN]' THEN
         ELSE
            ERROR 'Valor inválido para o campo!'
            NEXT FIELD oc_sem_pc
         END IF
      
      ON KEY (control-z)
         CALL pol1157_popup_lst()
        
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1157_le_den_item(p_item)#
#-----------------------------------#
   DEFINE p_item char(15)
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item
      
   IF STATUS <> 0 THEN
      LET p_den_item = ''
   END IF

END FUNCTION
   
#------------------------------#
FUNCTION pol1157_monta_select()#
#------------------------------#

   LET p_query = 
      "SELECT a.chave_processo, a.cod_item, a.seq_campo, a.seq_periodo, ",
      " a.qtd_dia, a.qtd_ajustada, a.dat_entrega, a.tip_ajuste, ",
      " a.dat_ini_periodo, a.dat_fim_periodo, a.usuario, a.dat_proces, num_ocs, '' ",
      " FROM mapa_compras_hist_454 a, item b ",
   " WHERE a.cod_empresa = '",p_cod_empresa,"' ",
   "   AND a.cod_item LIKE '","%",p_par_lst.cod_item CLIPPED,"%","' ",
   "   AND b.cod_empresa = a.cod_empresa ",
   "   AND b.cod_item = a.cod_item "

   IF p_par_lst.chave_processo IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND chave_processo = ",p_par_lst.chave_processo
   END IF

   IF p_par_lst.dat_ini IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND date(dat_proces) >= '",p_par_lst.dat_ini,"' "
   END IF

   IF p_par_lst.dat_fim IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND date(dat_proces) <= '",p_par_lst.dat_fim,"' "
   END IF

   IF p_par_lst.item_de IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.cod_item >= '",p_par_lst.item_de,"' "
   END IF

   IF p_par_lst.item_ate IS NOT NULL THEN
      LET p_query = p_query CLIPPED, " AND a.cod_item <= '",p_par_lst.item_ate,"' "
   END IF
   
   IF p_par_lst.tip_ajuste <> 'T' THEN
      LET p_query = p_query CLIPPED, " AND tip_ajuste = '",p_par_lst.tip_ajuste,"' "
   END IF

   IF p_par_lst.ajuste_efetuado = 'I' THEN
      LET p_query = p_query CLIPPED, " AND qtd_dia = qtd_ajustada "
   END IF

   IF p_par_lst.ajuste_efetuado = 'D' THEN
      LET p_query = p_query CLIPPED, " AND qtd_dia <> qtd_ajustada "
   END IF

   if p_par_lst.cod_lin_prod is not null then
      LET p_query = p_query CLIPPED, " and  b.cod_lin_prod = ", p_par_lst.cod_lin_prod
   end if
   
   LET p_query = p_query CLIPPED, " ORDER BY chave_processo, a.cod_item, seq_periodo"

END FUNCTION

#-------------------------------#
 FUNCTION pol1157_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1157.tmp"
         START REPORT pol1157_relat TO p_caminho
      ELSE
         START REPORT pol1157_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1157_le_den_empresa()
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

#--------------------------#
FUNCTION pol1157_listagem()#
#--------------------------#
   
   DEFINE p_oc_gerada CHAR(10)
   
   IF NOT pol1157_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1157_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0
   LET p_houve_erro = FALSE
   
   CALL pol1157_monta_select()
      
   PREPARE query FROM p_query    
   DECLARE cq_hist CURSOR FOR query
   
   FOREACH cq_hist INTO p_relat.*
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_hist')
         EXIT FOREACH
      END IF
      
      IF p_relat.tip_ajuste = 'A' THEN
         LET p_oc_gerada = p_relat.num_ocs
         SELECT num_pedido
           INTO p_relat.num_pedido
           FROM ordem_sup
          WHERE cod_empresa = p_cod_empresa
            AND num_oc = p_oc_gerada
            AND ies_versao_atual = 'S'
         
         IF p_relat.num_pedido = 0 THEN
            LET p_relat.num_pedido = NULL
         END IF
         
         IF p_par_lst.oc_sem_pc = 'S' THEN
            IF p_relat.num_pedido IS NOT NULL OR p_oc_gerada IS NULL THEN   
               CONTINUE FOREACH
            END IF
         END IF
      END IF
         
      CALL pol1157_le_den_item(p_relat.cod_item)
      
      IF p_relat.tip_ajuste = 'C' THEN
         LET p_relat.dat_entrega = ''
      END IF
      
      OUTPUT TO REPORT pol1157_relat(p_relat.chave_processo, p_relat.cod_item) 
      
      IF p_houve_erro THEN
         EXIT FOREACH
      END IF
      
      LET p_count = 1

   END FOREACH
         
   FINISH REPORT pol1157_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 
            
#------------------------------------------------#
 REPORT pol1157_relat(p_chave_processo,p_cod_item)
#------------------------------------------------#
    
   DEFINE p_chave_processo CHAR(12),
          p_cod_item       CHAR(15),
          p_texto          CHAR(60),
          p_imp_texto      SMALLINT
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63

   ORDER EXTERNAL BY p_chave_processo, p_cod_item          
   
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 128, "PAG:", PAGENO USING "##&"
               
         PRINT COLUMN 001, p_versao,
               COLUMN 040, "HISTORICO DOS AJUSTES EFETUADOS NO SUPRIMENTO",
               COLUMN 107, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 128, "PAG:", PAGENO USING "##&"
               
         PRINT COLUMN 001, p_versao,
               COLUMN 040, "HISTORICO DOS AJUSTES EFETUADOS NO SUPRIMENTO",
               COLUMN 107, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
      
      BEFORE GROUP OF p_chave_processo
         
         LET p_imp_texto = FALSE
         
         DECLARE cq_obs_ger CURSOR FOR
          SELECT texto
            FROM mapa_compras_obs_454
           WHERE cod_empresa = p_cod_empresa
             AND chave_processo = p_chave_processo
             AND (cod_item IS NULL OR cod_item = ' ')
         FOREACH cq_obs_ger INTO p_texto
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','mapa_compras_obs_454:cq_obs_ger')
               LET p_houve_erro = TRUE
               RETURN
            END IF
            
            IF NOT p_imp_texto THEN
               PRINT COLUMN 001, "Processo: ", p_chave_processo,
                     COLUMN 025, "Obs: ", p_texto
               LET p_imp_texto = TRUE
            ELSE
               PRINT COLUMN 025, "     ", p_texto
            END IF
            
        END FOREACH                       
               
      BEFORE GROUP OF p_cod_item
         
         PRINT
         PRINT COLUMN 001, "Item: ", p_cod_item, " - ", p_den_item
         LET p_imp_texto = FALSE
         
         DECLARE cq_obs_item CURSOR FOR
          SELECT texto
            FROM mapa_compras_obs_454
           WHERE cod_empresa = p_cod_empresa
             AND chave_processo = p_chave_processo
             AND cod_item  = p_cod_item
         FOREACH cq_obs_item INTO p_texto
            
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','mapa_compras_obs_454:cq_obs_item')
               LET p_houve_erro = TRUE
               RETURN
            END IF
            
            IF NOT p_imp_texto THEN
               PRINT
               PRINT COLUMN 001, "Obs: ", p_texto
               LET p_imp_texto = TRUE
            ELSE
               PRINT COLUMN 001, "     ", p_texto
            END IF
            
        END FOREACH                       

         PRINT
         PRINT COLUMN 001, 'SC TA SP QT SUGERIDA QT AJUSTADA DT ENTREGA INI PERIODO FIM PERIODO USUARIO  DATA DO PROCESSO    OCS CANCELADAS OU INSERIDAS    PEDIDO'  
         PRINT COLUMN 001, '-- -- -- ----------- ----------- ---------- ----------- ----------- -------- ------------------- ------------------------------ ------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.seq_campo USING '##',
               COLUMN 004, p_relat.tip_ajuste,
               COLUMN 007, p_relat.seq_periodo USING '##',
               COLUMN 013, p_relat.qtd_dia USING '######',
               COLUMN 025, p_relat.qtd_ajustada USING '######',
               COLUMN 034, p_relat.dat_entrega USING 'dd/mm/yyyy',
               COLUMN 045, p_relat.dat_ini_periodo USING 'dd/mm/yyyy',
               COLUMN 057, p_relat.dat_fim_periodo USING 'dd/mm/yyyy',
               COLUMN 069, p_relat.usuario,
               COLUMN 078, p_relat.dat_proces,
               COLUMN 098, p_relat.num_ocs,
               COLUMN 129, p_relat.num_pedido

      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT
                  
#-------------------------------#
FUNCTION pol1157_tem_oc_no_mes()#
#-------------------------------#

   DEFINE p_tem_oc_mes SMALLINT
   
   LET p_tem_oc_mes = FALSE

   DECLARE cq_ocm CURSOR FOR
    SELECT a.*
      FROM ordem_sup a,
           prog_ordem_sup b
     WHERE a.cod_empresa = p_cod_empresa
       AND a.cod_item = p_cod_item
       AND a.ies_situa_oc IN ('A', 'R','X')
       AND a.ies_versao_atual = 'S'
       AND MONTH(b.dat_entrega_prev) = MONTH(p_dat_entrega)
       AND YEAR(b.dat_entrega_prev) = YEAR(p_dat_entrega)
       AND b.cod_empresa = a.cod_empresa
       AND b.num_oc = a.num_oc
       AND b.num_versao = a.num_versao
       AND b.ies_situa_prog NOT IN ('C')
	   ORDER BY num_oc
   
   FOREACH cq_ocm INTO p_ordem_sup.*
   
      IF STATUS <> 0 then
         CALL log003_err_sql('FOREACH','ordem_sup:cq_ocm')
         RETURN FALSE
      END IF
      
      SELECT MAX(num_prog_entrega)
        INTO p_num_prog_entrega
        FROM prog_ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc = p_ordem_sup.num_oc
         AND num_versao = p_ordem_sup.num_versao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','ordem_sup:cq_ocm')
         RETURN FALSE
      END IF

      IF p_num_prog_entrega IS NULL THEN
         LET p_num_prog_entrega = 0
      END IF
      
      LET p_num_prog_entrega = p_num_prog_entrega + 1
      
      LET p_tem_oc_mes = TRUE
      LET p_num_oc = p_ordem_sup.num_oc
      LET p_num_versao = p_ordem_sup.num_versao               
      LET p_ies_situa_oc = p_ordem_sup.ies_situa_oc
      LET p_seq_prog = p_num_prog_entrega 
      
      EXIT FOREACH
   
   END FOREACH
   
   RETURN p_tem_oc_mes

END FUNCTION

#----------------------------------#
FUNCTION pol1157_ins_oc_bloqueada()#
#----------------------------------#

   SELECT num_oc
     FROM oc_bloqueada_454
    WHERE cod_empresa = p_cod_empresa
      AND num_oc = p_num_oc
      AND chave_processo = p_chave_processo
   
   IF STATUS = 100 THEN 
      INSERT INTO oc_bloqueada_454
       VALUES(p_chave_processo,
              p_cod_empresa,
              p_num_oc,
              p_msg)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('INSERT', 'oc_bloqueada_454')
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT', 'oc_bloqueada_454')
         RETURN FALSE
      END IF      
   END IF         

   SELECT cod_lin_prod
     INTO p_cod_lin_prod
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT', 'item')
      RETURN FALSE
   END IF      

   INSERT INTO item_criticado_bi_454
    VALUES(p_chave_processo,
           p_cod_empresa,
           p_num_oc,
           p_cod_item,
           p_seq_periodo,
           p_msg,
           p_cod_lin_prod,
           p_id_prog_ord)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT', 'item_criticado_bi_454')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION



{login logix polimetri: admlog ch2p31
Alterções necessárias:

Se houver um corte na programação para o Item, não bloquear as OC para períodos futuros 
até a quantidade que foi cortada, a partir daí deve bloquear. 

Exemplo:

itam    qtd   periodo    operação            Analisar a regra
110011   10     11        Acrescentar        Sim
110011   20     12        Cortar
110011   15     01        Acrescentar        nâo, pois tem um saldo de 20 que foi cortado n periodo anterior
110011   15     02        Acrescentar        Sim, más, como tem um saldo de 5 dos 20 cortados no período 12,
                                             sáo analisar nas regras o acréscimo de 10
