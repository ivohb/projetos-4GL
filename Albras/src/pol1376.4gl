#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1376                                                            #
# OBJETIVO: ESTORNAR APTO DE REFUGO E APONTAR SUCATA                           #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 30/08/2019                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#
# Ver parâmetros de exibição de tela e item sucata na LOG00087                 #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,
          g_msg                  CHAR(150)         
END GLOBALS

DEFINE m_processo           CHAR(30),
       m_dat_fec_man        DATE,
       m_seq_reg_mestre     INTEGER, 
       m_seq_reg_item       INTEGER,
       m_num_transac        INTEGER,
       m_qtd_produzida      DECIMAL(10,3),
       m_qtd_erro           INTEGER,
       m_tot_erro           INTEGER,
       m_msg                CHAR(120),
       m_qtd_movto          DECIMAL(10,3),
       m_cod_it_sucata      CHAR(15),
       m_cod_item           CHAR(15),
       m_mov_estoque_pai    INTEGER

DEFINE ma_erro           ARRAY[100] OF RECORD
      cod_empresa        CHAR(02),
      seq_reg_mestre     INTEGER,
      seq_reg_item       INTEGER,
      mensagem           CHAR(120)
END RECORD      

DEFINE p_w_apont_prod   RECORD 													
   cod_empresa         char(2),                         
   cod_item            char(15), 
   num_ordem           integer, 
   num_docum           char(10), 
   cod_roteiro         char(15), 
   num_altern          dec(2,0), 
   cod_operacao        char(5), 
   num_seq_operac      dec(3,0), 
   cod_cent_trab       char(5), 
   cod_arranjo         char(5), 
   cod_equip           char(15), 
   cod_ferram          char(15), 
   num_operador        char(15), 
   num_lote            char(15), 
   hor_ini_periodo     datetime hour to minute, 
   hor_fim_periodo     datetime hour to minute, 
   cod_turno           dec(3,0), 
   qtd_boas            dec(10,3), 
   qtd_refug           dec(10,3), 
   qtd_total_horas     dec(10,2), 
   cod_local           char(10), 
   cod_local_est       char(10), 
   dat_producao        date, 
   dat_ini_prod        date, 
   dat_fim_prod        date, 
   cod_tip_movto       char(1), 
   estorno_total       char(1), 
   ies_parada          smallint, 
   ies_defeito         smallint, 
   ies_sucata          smallint, 
   ies_equip_min       char(1), 
   ies_ferram_min      char(1), 
   ies_sit_qtd         char(1), 
   ies_apontamento     char(1), 
   tex_apont           char(255), 
   num_secao_requis    char(10), 
   num_conta_ent       char(23), 
   num_conta_saida     char(23), 
   num_programa        char(8), 
   nom_usuario         char(8), 
   num_seq_registro    integer, 
   observacao          char(200), 
   cod_item_grade1     char(15), 
   cod_item_grade2     char(15), 
   cod_item_grade3     char(15), 
   cod_item_grade4     char(15), 
   cod_item_grade5     char(15), 
   qtd_refug_ant       dec(10,3), 
   qtd_boas_ant        dec(10,3), 
   tip_servico         char(1), 
   abre_transacao      smallint, 
   modo_exibicao_msg   smallint, 
   seq_reg_integra     integer, 
   endereco            integer, 
   identif_estoque     char(30), 
   sku                 char(25), 
   finaliza_operacao   char(1)
END RECORD

MAIN
      
   IF NUM_ARGS() > 0  THEN
      CALL LOG_connectDatabase("DEFAULT")
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_processo = 'Via bat ou outra aplicação'
      CALL pol1376_processar() 
   ELSE
      CALL log0180_conecta_usuario()
      CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
      
      IF p_status = 0  THEN
         LET m_processo = 'Manualmente pelo menu logix'
         CALL pol1376_processar()
         CALL log0030_mensagem(m_msg,'INFO')
      END IF
     
   END IF
      
END MAIN       

#------------------------------#
FUNCTION pol1376_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
   
   IF l_param1_empresa IS NULL THEN
      LET l_param1_empresa = '01'
   END IF

   IF l_param2_user IS NULL THEN
      LET l_param2_user = 'job0003'
   END IF
      
   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   LET m_processo = 'Executando via JOB0003'

   CALL pol1376_processar()
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#          
FUNCTION pol1376_processar()#
#---------------------------#
   
   DEFINE l_dat_proces    CHAR(20)
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "pol1376-12.00.00  "
   CALL func002_versao_prg(p_versao)
   LET m_qtd_erro = 0
   
   IF NOT log0150_verifica_se_tabela_existe("proces_pol1376") THEN 
      IF NOT pol1356_cria_proces_pol1376() THEN
         RETURN 
      END IF
   END IF

   IF NOT log0150_verifica_se_tabela_existe("estorno_erro_f020") THEN 
      IF NOT func020_cria_tab() THEN
         RETURN FALSE
      END IF
   END IF

   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   
   LET m_msg = 'Inico do processo'
   
   INSERT INTO proces_pol1376 VALUES(p_cod_empresa,l_dat_proces,m_processo, m_msg)
   
   LET m_msg = NULL
   
   IF pol1376_exec_processo() THEN
      IF m_qtd_erro = 0 THEN
         LET m_msg = 'Fim do processo'
      ELSE
         LET m_msg = 'Houve erro. Consulte-os no pol1377.'
      END IF
   END IF

   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)

   INSERT INTO proces_pol1376 VALUES(p_cod_empresa,l_dat_proces,m_processo, m_msg)
             
END FUNCTION

#-------------------------------------#
FUNCTION pol1356_cria_proces_pol1376()#
#-------------------------------------#

   CREATE TABLE proces_pol1376(
    id                  SERIAL,
    cod_empresa         CHAR(02),
    dat_proces          CHAR(20),
    processo            CHAR(30),
    mensagem            CHAR(120));

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') criando tab proces_pol1376'
      RETURN FALSE
   END IF

   CREATE UNIQUE INDEX ix_proces_pol1376
    ON proces_pol1376(id);

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') criando index ix_proces_pol1376'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1376_exec_processo()#
#-------------------------------#
               
   SELECT dat_fecha_ult_man
     INTO m_dat_fec_man
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo tab par_estoque'
      RETURN FALSE
   END IF
   
   LET m_dat_fec_man = m_dat_fec_man + 1
   
   DECLARE cq_le_apont CURSOR WITH HOLD FOR
    SELECT m.seq_reg_mestre, p.seq_registro_item, 
           p.moviment_estoque, p.qtd_produzida
      FROM man_apo_mestre m, man_item_produzido p, ordens o
     WHERE m.empresa = p_cod_empresa
       AND m.sit_apontamento = 'A'
       AND m.data_producao >= m_dat_fec_man
       AND m.empresa = p.empresa
       AND m.seq_reg_mestre = p.seq_reg_mestre
       AND p.tip_producao = 'R'
       AND p.tip_movto = 'N'
       AND m.empresa = o.cod_empresa
       AND m.ordem_producao = o.num_ordem
       AND o.ies_situa = '4'

   FOREACH cq_le_apont INTO 
      m_seq_reg_mestre, m_seq_reg_item, m_num_transac, m_qtd_produzida
     
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro:(',STATUS, ') lendo apontamentos:cq_le_apont'
         RETURN FALSE
      END IF 
      
      SELECT 1 FROM man_item_produzido
       WHERE empresa = p_cod_empresa
         AND seq_reg_mestre = m_seq_reg_mestre
         AND seq_reg_normal = m_seq_reg_item

      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            LET m_msg = 'Erro:(',STATUS, ') lendo tab man_item_produzido:cq_le_apont'
            RETURN FALSE
         END IF
      END IF 

      CALL log085_transacao("BEGIN")
      
      IF NOT pol1376_estorna_refugo() THEN
         LET m_qtd_erro = m_qtd_erro + 1
         CALL pol1376_le_erros() RETURNING p_status
         CALL log085_transacao("ROLLBACK")
         IF NOT p_status THEN
            RETURN FALSE
         END IF
         IF NOT pol1376_ins_erros() THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF
      
      LET m_qtd_erro = 0
      
      IF NOT pol1376_aponta_sucata() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF m_qtd_erro > 0 THEN
         CALL log085_transacao("ROLLBACK")
         IF NOT pol1376_ins_erros() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log085_transacao("COMMIT")
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1376_estorna_refugo()#
#--------------------------------#

   DEFINE lr_param                       RECORD
          empresa                        CHAR(02),
          usuario                        CHAR(08),
          seq_mestre                     INTEGER,
          seq_item                       INTEGER,
          qtd_estornar                   DECIMAL(10,3),
          tip_producao                   CHAR(01),
          nom_programa                   CHAR(08)
   END RECORD

   LET lr_param.empresa = p_cod_empresa
   LET lr_param.usuario = p_user  
   LET lr_param.seq_mestre = m_seq_reg_mestre
   LET lr_param.seq_item = m_seq_reg_item
   LET lr_param.qtd_estornar = m_qtd_produzida
   LET lr_param.tip_producao = 'R'
   LET lr_param.nom_programa = 'POL1376'
   
   LET p_status = func020_estorna_apto(lr_param)
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1376_le_erros()#
#--------------------------#
   
   DEFINE l_ind          INTEGER
   
   LET l_ind = 1
   LET m_tot_erro = 0
   
   DECLARE cq_erros CURSOR FOR
    SELECT * FROM estorno_erro_f020
   
   FOREACH cq_erros INTO ma_erro[l_ind].*
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro:(',STATUS, ') lendo tab estorno_erro_f020'
         RETURN FALSE
      END IF
      
      LET l_ind = l_ind + 1
      
      IF l_ind > 100 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET m_tot_erro = l_ind - 1
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1376_ins_erros()#
#---------------------------#
   
   DEFINE l_ind         INTEGER
   
   FOR l_ind = 1 TO m_tot_erro
   
       INSERT INTO estorno_erro_f020    
        VALUES(ma_erro[l_ind].*)

       IF STATUS <> 0 THEN
          LET m_msg = 'Erro:(',STATUS, ') inserindo erros na tab estorno_erro_f020:2' 
          RETURN FALSE
       END IF       
       
   END FOR
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1376_aponta_sucata()#
#-------------------------------#
   
   DEFINE l_ies_ctr_lote     CHAR(01)
   
   INITIALIZE p_w_apont_prod TO NULL
   
   SELECT
    man_apo_mestre.empresa,                   
    man_apo_mestre.seq_reg_mestre,
    man_apo_mestre.ordem_producao,
    man_apo_mestre.data_producao,
    man_apo_mestre.usu_apontamento,
    man_apo_mestre.secao_requisn,   
    man_tempo_producao.data_ini_producao,  
    man_tempo_producao.hor_ini_producao,  
    man_tempo_producao.dat_final_producao,  
    man_tempo_producao.hor_final_producao,  
    man_tempo_producao.tempo_tot_producao,
    man_tempo_producao.turno_producao,
    man_apo_detalhe.roteiro_fabr,
    man_apo_detalhe.altern_roteiro,
    man_apo_detalhe.operacao,  
    man_apo_detalhe.sequencia_operacao,
    man_apo_detalhe.centro_trabalho,
    man_apo_detalhe.arranjo_fisico,
    man_apo_detalhe.ferramental,  
    man_apo_detalhe.atlz_ferr_min,      
    man_apo_detalhe.eqpto,  
    man_apo_detalhe.atualiza_eqpto_min,  
    man_apo_detalhe.operador,
    man_item_produzido.item_produzido,
    man_item_produzido.lote_produzido,
    man_item_produzido.local,
    man_item_produzido.qtd_produzida,
    man_item_produzido.moviment_estoque    
   INTO p_w_apont_prod.cod_empresa,               
        p_w_apont_prod.num_seq_registro,  	      
        p_w_apont_prod.num_ordem,                 
        p_w_apont_prod.dat_producao,              
        p_w_apont_prod.nom_usuario,               
        p_w_apont_prod.num_secao_requis,          
        p_w_apont_prod.dat_ini_prod,              
        p_w_apont_prod.hor_ini_periodo,           
        p_w_apont_prod.dat_fim_prod,              
        p_w_apont_prod.hor_fim_periodo,           
        p_w_apont_prod.qtd_total_horas,           
        p_w_apont_prod.cod_turno,                 
 	      p_w_apont_prod.cod_roteiro,               
        p_w_apont_prod.num_altern,                
        p_w_apont_prod.cod_operacao,              
        p_w_apont_prod.num_seq_operac,            
        p_w_apont_prod.cod_cent_trab,             
        p_w_apont_prod.cod_arranjo,               
        p_w_apont_prod.cod_ferram,                
        p_w_apont_prod.ies_ferram_min,            
        p_w_apont_prod.cod_equip,                 
        p_w_apont_prod.ies_equip_min,       
        p_w_apont_prod.num_operador,        
        p_w_apont_prod.cod_item,        		 
        p_w_apont_prod.num_lote,            
        p_w_apont_prod.cod_local,
        m_qtd_movto,
        m_mov_estoque_pai
    FROM man_apo_mestre, 
        man_tempo_producao,
        man_apo_detalhe,
        man_item_produzido    
   WHERE man_apo_mestre.empresa = p_cod_empresa
     AND man_apo_mestre.seq_reg_mestre = m_seq_reg_mestre
     AND man_tempo_producao.empresa = man_apo_mestre.empresa
     AND man_tempo_producao.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_apo_detalhe.empresa = man_apo_mestre.empresa  
     AND man_apo_detalhe.seq_reg_mestre = man_apo_mestre.seq_reg_mestre  
     AND man_item_produzido.empresa = man_apo_mestre.empresa
     AND man_item_produzido.seq_reg_mestre = man_apo_mestre.seq_reg_mestre
     AND man_item_produzido.seq_registro_item = m_seq_reg_item
     
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados do apontamento:1'
      RETURN FALSE
   END IF 
   
   LET m_cod_item = p_w_apont_prod.cod_item
   
   SELECT cod_item
     INTO m_cod_it_sucata
     FROM item_sucata_304
    WHERE cod_empresa = p_cod_empresa
      AND cod_operac = p_w_apont_prod.cod_operacao

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados da tab item_sucata_304:1'
      RETURN FALSE
   END IF 
      
   SELECT cod_local_prod
     INTO p_w_apont_prod.cod_local
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = p_w_apont_prod.num_ordem

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados da tab ordens:1'
      RETURN FALSE
   END IF 

   SELECT cod_local_estoq,
          ies_ctr_lote
     INTO p_w_apont_prod.cod_local_est,
          l_ies_ctr_lote
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = p_w_apont_prod.cod_item

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados da tab item:1'
      RETURN FALSE
   END IF 
   
   IF l_ies_ctr_lote = 'N' THEN
      LET p_w_apont_prod.num_lote = NULL
   END IF
   
   LET p_w_apont_prod.qtd_boas = 0
   LET p_w_apont_prod.ies_defeito = 0
   LET p_w_apont_prod.qtd_refug = 0
 	 LET p_w_apont_prod.ies_sucata = 1

   IF NOT pol1376_gra_sucata() THEN
      RETURN FALSE
   END IF
   
   LET p_w_apont_prod.cod_tip_movto        = 'N'       
   LET p_w_apont_prod.ies_sit_qtd 					=	'L'      
   LET p_w_apont_prod.ies_apontamento 			= '1'	     
   LET p_w_apont_prod.num_conta_ent				= NULL       
   LET p_w_apont_prod.num_conta_saida 			= NULL     
   LET p_w_apont_prod.num_programa 				= 'POL1376'  
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
   LET p_w_apont_prod.ies_parada = 0
   
   CALL man8246_cria_temp_fifo()
   CALL man8237_cria_tables_man8237()
   CALL pol1376_cria_w_alt_comp_wms()
      
   IF NOT manr24_cria_w_apont_prod(1) THEN 
      LET m_msg = 'Não foi possivel criar a tabela w_apont_prod'      
      RETURN FALSE
   END IF                                           
   
   IF NOT pol1376_cria_w_compon() THEN
      RETURN FALSE
   END IF
   
   IF NOT manr24_cria_w_comp_baixa (1) THEN   
		  LET m_msg = 'Não foi possivel criar a tabela w_comp_baixa' 	                      	
      RETURN FALSE                                                          	                    	                                                            
   END IF                                                                                             

   IF NOT pol1376_carrega_baixa() THEN 
      RETURN FALSE
   END IF      
   
   IF NOT manr24_inclui_w_apont_prod(p_w_apont_prod.*,1) THEN   
      LET m_msg = 'Erro:(',STATUS, ') incluindo dados na tab w_apont_prod'   
      RETURN FALSE
   END IF
   
   DELETE FROM man_log_apo_prod 
    WHERE empresa = p_cod_empresa
      AND ordem_producao = p_w_apont_prod.num_ordem
         
	 IF NOT manr27_processa_apontamento()  THEN 
      IF NOT pol1376_le_man_log() THEN
	 		   RETURN FALSE
	 		END IF			
   END IF
   
   RETURN TRUE   

END FUNCTION

#----------------------------#
FUNCTION pol1376_gra_sucata()#
#----------------------------#

   DEFINE l_cod_item          LIKE item.cod_item,
          l_cod_motivo        LIKE man_def_producao.motivo_defeito,
          l_pes_unit          LIKE item.pes_unit,
          l_unid_item         LIKE item.cod_unid_med,
          l_unid_sucata       LIKE item.cod_unid_med,
          l_fat_conver        DECIMAL(12,5),
          l_qtd_conver        DECIMAL(15,3)
          
   SELECT motivo_defeito
     INTO l_cod_motivo
     FROM man_def_producao 
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados da tab man_def_producao'
      RETURN FALSE
   END IF 

   SELECT pes_unit,
          cod_unid_med
     INTO l_pes_unit, 
          l_unid_item
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_item
	        
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') lendo dados do produto na tab item'
	    RETURN FALSE
	 END IF

   SELECT cod_unid_med
     INTO l_unid_sucata
     FROM item
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item = m_cod_it_sucata
	        
   IF STATUS <> 0 THEN
	    LET m_msg = 'Erro:(',STATUS, ') lendo dados da sucata na tab item'
	    RETURN FALSE
	 END IF
                                                                                  
   IF l_unid_item = l_unid_sucata THEN                                            
      LET l_fat_conver = 1                                                        
      LET l_qtd_conver = m_qtd_movto                                              
   ELSE                                                                           
      LET l_fat_conver = l_pes_unit                                               
      LET l_qtd_conver = m_qtd_movto * l_fat_conver                               
   END IF                                                                         
                                                                                  
	 IF NOT pol1376_w_sucata() THEN                                                		 
		  RETURN FALSE
	 END IF
		
	 INSERT INTO w_sucata                                                   		 
		  VALUES(m_cod_it_sucata, l_qtd_conver, 
		         l_fat_conver, m_qtd_movto, l_cod_motivo  )    		 
    
   IF STATUS <> 0 THEN                                                    	   
      LET m_msg = 'Erro:(',STATUS, ') inserindo na tab w_sucata'   	   
      RETURN FALSE
	 END IF                                                                    		 
   
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1376_w_sucata()
#---------------------------#
	
	DROP TABLE w_sucata

  CREATE TEMP TABLE w_sucata	(	
     cod_sucata      	CHAR(15),
     qtd_apont	      DECIMAL(15,3),
     fat_conversao	  DECIMAL(12,5),
     qtd_convertida  	DECIMAL(15,3),
     motivo_sucata 	  DECIMAL(3,0)
   );	

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') criando tabela w_sucata'
      RETURN FALSE
   END IF 

   RETURN TRUE

END FUNCTION 

#-------------------------------------#
FUNCTION pol1376_cria_w_alt_comp_wms()#
#-------------------------------------#
  
  DROP TABLE w_alt_comp_wms
  
  CREATE TEMP TABLE w_alt_comp_wms (
  componente     CHAR(15), 
  local_baixa    CHAR(10), 
  qtd_necessaria DEC(14,7), 
  qtd_baixa      DEC(15,3), 
  tip_movto      CHAR(1))

END FUNCTION

#-------------------------------#
FUNCTION pol1376_cria_w_compon()#
#-------------------------------#

   DROP TABLE w_compon
   
   CREATE TEMP TABLE w_compon (
   cod_item    CHAR(15), 
   qtd_movto   DEC(15,3), 
   num_docum   CHAR(10), 
   grade_1     CHAR(15), 
   grade_2     CHAR(15), 
   grade_3     CHAR(15), 
   grade_4     CHAR(15), 
   grade_5     CHAR(15))

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') criando tabela w_compon'
      RETURN FALSE
   END IF 
      
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1376_carrega_baixa()#																						
#-------------------------------#

   DEFINE l_compon    RECORD                                      
     cod_item_pai 		LIKE estoque_lote_ender.cod_item,         
     cod_item 		    LIKE estoque_lote_ender.cod_item,         
     num_lote 		    LIKE estoque_lote_ender.num_lote,         
     cod_local 		    LIKE estoque_lote_ender.cod_local,          
     endereco 		    LIKE estoque_lote_ender.endereco,         
     num_serie 		  	LIKE estoque_lote_ender.num_serie,          
     num_volume 		  LIKE estoque_lote_ender.num_volume,       
     comprimento		 	LIKE estoque_lote_ender.comprimento,		  
     largura 		     	LIKE estoque_lote_ender.largura, 		        
     altura 			    LIKE estoque_lote_ender.altura, 			    
     diametro 		    LIKE estoque_lote_ender.diametro, 		    
     num_peca 		    LIKE estoque_lote_ender.num_peca, 		    
     dat_producao 		DATE, 		                                
     hor_producao 		CHAR(08), 		                            
     dat_valid 		    DATE, 		                                  
     hor_valid 		    CHAR(08), 		                              
     identif_estoque 	LIKE estoque_lote_ender.identif_estoque,    
     deposit 		     	LIKE estoque_lote_ender.deposit, 		        
     qtd_transf 		  DECIMAL(15,3), 		                        
     cod_grade_1      LIKE estoque_lote_ender.cod_grade_1,       
     cod_grade_2      LIKE estoque_lote_ender.cod_grade_2,       
     cod_grade_3      LIKE estoque_lote_ender.cod_grade_3,       
     cod_grade_4      LIKE estoque_lote_ender.cod_grade_4,       
     cod_grade_5      LIKE estoque_lote_ender.cod_grade_5        
   END RECORD                                                     

   LET l_compon.cod_item_pai = m_cod_item                                                  
   
   DECLARE cq_cod_compon CURSOR FOR
    SELECT item_componente,
           lote_componente,
           local_estoque,
           endereco,
           serie,
           volume,
           comprimento, 
           largura, 		
           altura, 			
           diametro, 		
           num_peca,
           data_producao,
           data_valid,
           identificacao_estoque,
           depositante,
           qtd_baixa_real  
      FROM man_comp_consumido 
     WHERE empresa = p_cod_empresa 
       AND seq_reg_mestre = m_seq_reg_mestre
       AND mov_estoque_pai = m_mov_estoque_pai
       
   FOREACH cq_cod_compon INTO                                                                   
		    l_compon.cod_item,                                                                    
		    l_compon.num_lote,                                                                    
		    l_compon.cod_local, 		                                                               
		    l_compon.endereco, 		                                                               
		    l_compon.num_serie, 		                                                               
		    l_compon.num_volume,                                                                  
		    l_compon.comprimento,                                                                 
		    l_compon.largura, 				                                                             
		    l_compon.altura, 			                                                               
		    l_compon.diametro, 		                                                               
		    l_compon.num_peca, 		 
		    l_compon.dat_producao,
		    l_compon.dat_valid,                                                              
		    l_compon.identif_estoque,                                                             
		    l_compon.deposit,       
		    l_compon.qtd_transf
                                                                                           				                                                                                     	
      IF STATUS <> 0 THEN                                                                     
         LET m_msg = 'Erro:(',STATUS, ') lendo componetnetes a baixar'                   
         RETURN FALSE                                                                         
      END IF		                                                                              
                                                                                                                                                                                      
      INSERT INTO w_comp_baixa                                                                
      	VALUES (l_compon.*)                                                                   
      	                                                                                      
      IF STATUS <> 0 THEN                                                                     
	       LET m_msg = 'Erro:(',STATUS, ') inserindo dados na tab w_comp_baixa' 
	    	 RETURN FALSE                                                                        
      END IF	                                                                                
                                                                                                                                                                                            
   END FOREACH                                                                                
                                                                                                    
   RETURN TRUE
				
END FUNCTION
     
#----------------------------#
FUNCTION pol1376_le_man_log()#
#----------------------------#
   
   DEFINE l_erro  CHAR(500)
   
   DECLARE cq_erro CURSOR FOR 	
		SELECT texto_detalhado  	
		 	FROM man_log_apo_prod	
     WHERE empresa = p_cod_empresa
       AND ordem_producao = p_w_apont_prod.num_ordem
		  
   FOREACH cq_erro INTO l_erro	
  				
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro:(',STATUS, ') lendo tab man_log_apo_prod'
         RETURN FALSE
      END IF 
      
      LET m_qtd_erro = m_qtd_erro + 1

      IF m_qtd_erro > 100 THEN
         EXIT FOREACH
      END IF
      
      LET ma_erro[m_qtd_erro].cod_empresa = p_cod_empresa
      LET ma_erro[m_qtd_erro].seq_reg_mestre = m_seq_reg_mestre
      LET ma_erro[m_qtd_erro].seq_reg_item = m_seq_reg_item
      LET ma_erro[m_qtd_erro].mensagem = l_erro
      
   END FOREACH
   
   LET m_tot_erro = m_qtd_erro
   
   IF m_qtd_erro > 100 THEN
      LET m_qtd_erro = 100
   END IF
   
   RETURN TRUE

END FUNCTION
