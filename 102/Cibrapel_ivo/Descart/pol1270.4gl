#---------------------------------------------------------------#
#Objetivo...: Integração de apontamento TrimPapel e Logix       #
#Autor......: Ivo HB                                            #
#Funções....: FUNC0002                                          #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,         
          p_status             SMALLINT,
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          sql_stmt             CHAR(900),
          p_caminho            CHAR(080),
          p_tipo_processo      INTEGER,
          p_tip_operacao       CHAR(01),
          p_ies_implant        CHAR(01)
       
DEFINE p_cod_item_refugo    LIKE parametros_885.cod_item_refugo,                  
       p_cod_item_sucata    LIKE parametros_885.cod_item_sucata,                  
       p_cod_item_retrab    LIKE parametros_885.cod_item_retrab,                  
       p_num_lote_sucata    LIKE parametros_885.num_lote_sucata,                  
       p_num_lote_refugo    LIKE parametros_885.num_lote_refugo,                  
       p_num_lote_retrab    LIKE parametros_885.num_lote_retrab,                  
       p_oper_sai_tp_refugo LIKE parametros_885.oper_sai_tp_refugo,               
       p_oper_ent_tp_refugo LIKE parametros_885.oper_ent_tp_refugo,               
       p_num_lote_impurezas LIKE parametros_885.num_lote_impurezas,               
       p_cod_operacao       LIKE estoque_trans.cod_operacao,            
       p_ies_situa          LIKE ordens.ies_situa                                

DEFINE p_cod_oper_sp         LIKE par_pcp.cod_estoque_sp,        
       p_cod_oper_rp         LIKE par_pcp.cod_estoque_rp,   
       p_cod_oper_sucata     LIKE par_pcp.cod_estoque_rn,   
       p_oper_sai_apto_refug LIKE parametros_885.oper_sai_apto_refug,
       p_ies_oper_final      LIKE ord_oper.ies_oper_final                         

DEFINE p_man                RECORD LIKE man_apont_885.*
          
DEFINE p_msg                CHAR(150),     
       p_mensagem           CHAR(150),        
       p_qtd_criticado      INTEGER,          
       p_qtd_apontado       INTEGER,          
       p_qtd_trim           DECIMAL(10,3),    
       p_item_trim          CHAR(15),         
       p_ordem_trim         INTEGER,          
       p_tipoRegistro       CHAR(01),         
       p_criticou           SMALLINT,         
       p_qtd_estoque        DECIMAL(10,3),    
       p_transac_consumo    INTEGER,          
       p_transac_apont      INTEGER,          
       p_num_trans_atual    INTEGER,          
       p_num_seq_orig       INTEGER,          
       p_cod_tip_apon       CHAR(01),         
       p_ies_tip_movto      CHAR(01),         
       p_num_seq_apont      INTEGER,                
       p_cod_item           CHAR(15),                     
       p_dat_abert          DATE,                         
       p_tipo_item          CHAR(02),                     
       p_count              INTEGER,                      
       p_ind                SMALLINT,                     
       p_index              SMALLINT,                     
       p_nom_tela           CHAR(200),                    
       p_nom_help           CHAR(200),                    
       p_houve_erro         SMALLINT,                     
       p_ies_proces         CHAR(01),                     
       p_erro               CHAR(10),                     
       p_dat_ini            DATETIME YEAR TO SECOND,      
       p_dat_fim            DATETIME YEAR TO SECOND,      
       p_datageracao        DATETIME YEAR TO SECOND,      
       p_grava_oplote       CHAR(01),                     
       p_rastreia           CHAR(01),                     
       p_dat_movto          DATE,                         
       p_dat_proces         DATE,                         
       p_hor_operac         CHAR(08),                     
       p_tip_movto          CHAR(01),                     
       p_ies_processando    CHAR(01),
       p_sem_estoque        SMALLINT

END GLOBALS

DEFINE p_statusregistro     LIKE apont_papel_885.statusregistro,                  
       p_num_transac_normal LIKE estoque_trans.num_transac,                       
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
       p_numlote            LIKE estoque_lote.num_lote,                           
       p_num_op             LIKE ordens.num_ordem,                                
       p_num_ordem          LIKE ordens.num_ordem,                                
       p_num_docum          LIKE ordens.num_docum,                                
       p_cod_local_baixa    LIKE ord_compon.cod_local_baixa,                      
       p_num_conta          LIKE estoque_trans.num_conta,                         
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

DEFINE p_qtd_apontar        LIKE estoque_lote.qtd_saldo,       
       p_qtd_refugar        LIKE estoque_lote.qtd_saldo        

MAIN
   CALL log0180_conecta_usuario()
   
   LET p_versao = 'pol1270-10.02.00  ' 
   CALL func002_versao_prg(p_versao)

   WHENEVER ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 90
      DEFER INTERRUPT

   LET p_caminho = log140_procura_caminho('pol1270.iem')

   CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '02'; LET p_user = 'pol1270'; LET p_status = 0

  IF p_status = 0  THEN
     CALL pol1270_controle() RETURNING p_status
  END IF

END MAIN       

#------------------------------#
FUNCTION pol1270_job(l_rotina) #
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
   
   LET p_cod_empresa = '02' #l_param1_empresa
   LET p_user = 'pol1270'  #l_param2_user
      
   CALL pol1270_controle() RETURNING p_status
   
   RETURN p_status
   
END FUNCTION   

#--------------------------#
FUNCTION pol1270_controle()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1270") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1270 AT 4,2 WITH FORM p_caminho
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
  
   LET p_qtd_apontado = 0   
   LET p_qtd_criticado = 0
      
   DISPLAY p_cod_empresa TO cod_empresa
   DISPLAY p_qtd_criticado TO qtd_criticado
   DISPLAY p_qtd_apontado TO qtd_apontado

  #lds CALL LOG_refresh_display()	

   CALL pol1270_processa() RETURNING p_status   
   CALL pol1270_grava_msg()

   UPDATE proces_apont_885 
      SET ies_proces = p_ies_processando
    WHERE cod_empresa = p_cod_empresa
   
   CLOSE WINDOW w_pol1270
   
   RETURN p_status

END FUNCTION

#--------------------------#
FUNCTION pol1270_processa()#
#--------------------------#

   LET p_ies_processando = 'N'
   
   IF NOT pol1270_checa_proces() THEN
      RETURN FALSE
   END IF
   
   IF p_ies_processando = 'S' THEN
      LET p_ies_processando = 'N'
      RETURN TRUE
   END IF

   IF NOT pol1270_le_parametros() THEN
      RETURN FALSE
   END IF

   DELETE FROM apont_erro_885
    WHERE codempresa = p_cod_empresa
    
   DELETE FROM apont_msg_885
    WHERE cod_empresa = p_cod_empresa
  
   CALL pol1270_del_tabs_lote()
   
   CALL pol1270_proces_apto() RETURNING p_status

   CALL pol1270_del_tabs_lote()
   
   RETURN p_status
   
END FUNCTION

#------------------------------#
FUNCTION pol1270_le_parametros()
#------------------------------#

   SELECT cod_estoque_sp,
          cod_estoque_rp,
          cod_estoque_rn
     INTO p_cod_oper_sp,
          p_cod_oper_rp,
          p_cod_oper_sucata
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
          num_lote_retrab,
          oper_sai_tp_refugo,
          oper_ent_tp_refugo,
          num_lote_impurezas,
          oper_sai_apto_refug
     INTO p_cod_item_refugo,
          p_num_lote_refugo,
          p_cod_item_sucata,          
          p_num_lote_sucata,
          p_cod_item_retrab,
          p_num_lote_retrab,
          p_oper_sai_tp_refugo,
          p_oper_ent_tp_refugo,
          p_num_lote_impurezas,
          p_oper_sai_apto_refug
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
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO PAR_ESTOQUE'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#---------------------------#
FUNCTION pol1270_grava_msg()#
#---------------------------#
   
   DEFINE p_dat_hor DATETIME YEAR TO SECOND
   
   LET p_dat_hor = CURRENT
   
   INSERT INTO apont_msg_885
    VALUES(p_cod_empresa, p_dat_hor, p_msg)

   IF p_mensagem IS NOT NULL THEN
      CALL pol1270_insere_erro() RETURNING p_status
   END IF

END FUNCTION      

#------------------------------#
FUNCTION pol1270_checa_proces()#
#------------------------------#

   SELECT ies_proces
     INTO p_ies_proces
     FROM proces_apont_885
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS = 100 THEN
      INSERT INTO proces_apont_885
       VALUES(p_cod_empresa, 'S')
   ELSE
      IF STATUS = 0 THEN
         IF p_ies_proces = 'N' THEN
            UPDATE proces_apont_885
               SET ies_proces = 'S'
             WHERE cod_empresa = p_cod_empresa
         ELSE
            LET p_ies_processando = 'S'
            LET p_msg = 'JA EXISTE UM PROCESSO DE APONTAMENTO EM EXECUCAO'
         END IF
      ELSE
         LET p_msg = 'ERRO(',STATUS,' ) LENDO proces_apont_885'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
      
END FUNCTION

#-------------------------------#
FUNCTION pol1270_del_tabs_lote()#
#-------------------------------#

   DELETE FROM estoque_lote 
    WHERE qtd_saldo <= 0 
      AND cod_empresa = p_cod_empresa
      
   DELETE FROM estoque_lote_ender 
    WHERE qtd_saldo <= 0 
      AND cod_empresa = p_cod_empresa

END FUNCTION

#-----------------------------#
FUNCTION pol1270_proces_apto()#
#-----------------------------#

   UPDATE apont_papel_885
      SET largura     = 0,
          diametro    = 0,
          tubete      = 0,
          comprimento = 0
    WHERE codempresa = p_cod_empresa
      AND statusregistro IN (0,2)
      AND largura IS NULL
      AND diametro IS NULL
      AND tubete IS NULL
      AND comprimento IS NULL

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO DIMENSIONAIS DA TAB APONT_PAPEL_885'
      RETURN FALSE
   END IF                                           

   CALL log085_transacao("BEGIN")  
   
   IF NOT pol1270_eleimina_estornos() THEN
      CALL log085_transacao("ROLLBACK")  
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")  

   IF NOT pol1270_aponta_producao() THEN
      RETURN FALSE
   END IF
   
   LET p_msg = 'APONTAMENTO EFETUADO COM SUCESSO'
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol1270_eleimina_estornos()#
#-----------------------------------#

   INITIALIZE p_man TO NULL

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
       AND statusregistro IN (0,2)

   FOREACH cq_elimina INTO
           p_man.num_seq_apont,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_man.qtd_movto,
           p_man.lote,
           p_man.largura,
           p_man.altura,
           p_man.diametro,
           p_man.tip_movto
   
      IF sqlca.sqlcode <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO APONTAMENO C/ ESTORNO'
         RETURN FALSE
      END IF                                           
      
      DISPLAY p_man.ordem_producao TO num_ordem
      
      #lds CALL LOG_refresh_display()	
            
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
          AND pesobalanca    = p_man.qtd_movto
          AND tipmovto       = p_man.tip_movto
          AND estorno        = 1
          AND StatusRegistro IN (0,2)
      
      FOREACH cq_repetidos INTO p_num_seq_apont

         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ELIMINANDO REGISTROS C/ ESTORNO'
            RETURN FALSE
         END IF         
         
         UPDATE apont_papel_885
            SET statusregistro = 9
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_man.num_seq_apont
      
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO APONTAMENO C/ ESTORNO'
            RETURN FALSE
         END IF         

         UPDATE apont_papel_885
            SET statusregistro = 9
          WHERE codempresa   = p_cod_empresa
            AND numsequencia = p_num_seq_apont

         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') ATUALIZANDO REGISTROS REPETIDOS'
            RETURN FALSE
         END IF         
      
         EXIT FOREACH
         
      END FOREACH
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1270_aponta_producao()#
#---------------------------------#
   
   INITIALIZE p_man TO NULL

   DECLARE cq_op CURSOR WITH HOLD FOR
    SELECT numsequencia,
           codempresa,
           coditem,
           numordem,
           codmaquina,
           datiniproducao,
           datproducao,
           tempoproducao,
           pesobalanca,
           tipmovto,
           numlote,
           largura,
           diametro,
           tubete,
           comprimento,
           estorno,
           datageracao
      FROM apont_papel_885
     WHERE codempresa     = p_cod_empresa
       AND StatusRegistro IN (0,2)
     ORDER BY numordem, numlote, numsequencia

   FOREACH cq_op INTO 
           p_man.num_seq_apont,
           p_man.empresa,
           p_man.item,
           p_man.ordem_producao,
           p_man.cod_recur,
           p_dat_ini,
           p_dat_fim,
           p_tempoproducao,
           p_man.qtd_movto,
           p_man.tip_movto,
           p_man.lote,
           p_man.largura,
           p_man.diametro,
           p_man.altura,
           p_man.comprimento,
           p_estorno,
           p_datageracao

      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_OP'
         RETURN FALSE
      END IF                                           
      
      LET p_man.nom_prog = 'POL1270'
      
      LET p_statusRegistro = 2
      
      DELETE FROM man_apont_885 
       WHERE empresa = p_cod_empresa
      
      SELECT COUNT(empresa)
        INTO p_count
        FROM man_apont_885
       WHERE empresa = p_cod_empresa
        
      IF p_count > 0 THEN
         LET p_msg = 'ERRO: NAO FOI POSSIVEL LIMPAR A TABELA MAN_APONT_885'
         RETURN FALSE
      END IF                                           
      
      LET p_dat_movto  = DATE(p_dat_fim)
      LET p_dat_proces = DATE(p_datageracao)
      LET p_hor_operac = EXTEND(p_datageracao, HOUR TO SECOND)

      IF p_estorno = 1 THEN
         LET p_man.qtd_movto = -p_man.qtd_movto
      END IF

      LET p_cod_operac = p_man.cod_recur
      
      LET p_sequencia = p_man.num_seq_apont

      DISPLAY p_man.ordem_producao TO num_ordem       
       #lds CALL LOG_refresh_display()	           

      CALL log085_transacao("BEGIN")  
      
      IF NOT pol1270_proces_apont() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
      INITIALIZE p_man TO NULL

   END FOREACH

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1270_proces_apont()#
#------------------------------#

   IF NOT pol1270_consiste_apont() THEN
      RETURN FALSE
   END IF

   IF NOT p_criticou THEN
      IF NOT pol1270_insere_apont() THEN
         RETURN FALSE
      END IF
      
      IF NOT pol1270_apontar_op() THEN
         RETURN FALSE
      END IF

      LET p_statusRegistro = 1 
      LET p_qtd_apontado = p_qtd_apontado + 1
      DISPLAY p_qtd_apontado TO qtd_apontado
         #lds CALL LOG_refresh_display()	           
   END IF

   IF NOT pol1270_grava_apont_papel() THEN
      RETURN FALSE
   END IF
         
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1270_insere_erro()
#-----------------------------#

   LET p_criticou = TRUE
   
   INSERT INTO apont_erro_885
      VALUES (p_cod_empresa,
              p_man.num_seq_apont,
              p_man.ordem_producao,
              p_msg)

   IF sqlca.sqlcode <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA APONT_ERRO_885'
      RETURN FALSE
   END IF                                           

   LET p_qtd_criticado = p_qtd_criticado + 1
   DISPLAY p_qtd_criticado TO qtd_criticado
          #lds CALL LOG_refresh_display()	           

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1270_consiste_apont()
#-------------------------------#

   SELECT num_docum,
          cod_item,
          ies_situa,
          cod_roteiro,
          num_altern_roteiro
     INTO p_num_docum,
          p_cod_item,
          p_ies_situa,
          p_man.cod_roteiro,
          p_man.altern_roteiro
     FROM ordens 
	  WHERE cod_empresa = p_cod_empresa
	    AND num_ordem   = p_man.ordem_producao

   IF STATUS = 100 THEN
      LET p_msg = 'ORDEM DE PRODUCAO NAO EXISTE NO LIGIX '
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
      RETURN TRUE
   END IF
   
   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORDENS'
      RETURN FALSE
   END IF
         
   CALL pol1270_pega_pedido()
   LET p_man.num_pedido = p_num_pedido
   LET p_man.num_seq_pedido = p_num_seq_pedido
   
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
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.lote IS NULL OR p_man.lote = ' ' THEN
      LET p_msg = 'NUM LOTE ESTA NULO '
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   LET p_num_lote = p_man.lote

   SELECT tipo_processo
     INTO p_tipo_processo
     FROM tipo_pedido_885
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_man.num_pedido         
      
   IF STATUS = 100 THEN
      LET p_msg = 'PEDIDO NAO ENCONTRADO NA TAB TIPO_PEDIDO_885'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO A TAB TIPO_PEDIDO_885'
         RETURN FALSE
      END IF
   END IF

   IF p_man.num_seq_apont IS NULL THEN
      LET p_msg = 'NUMERO DA SEQUENCIA NA TAB APONT_PAPEL_885 ESTA NULO '
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF      

   SELECT COUNT(num_seq_apont)
     INTO p_count
     FROM apont_trans_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_seq_apont = p_man.num_seq_apont

   IF STATUS <> 0 THEN
      LET p_msg = 'ERRO:(',STATUS, ') LENDO APONT_TRANS_885'
      RETURN FALSE
   END IF

   IF p_count > 0 THEN
      LET p_msg = 'O TRIM REPLICOU O NUMERO DE SEQUENCIA DO APONTAMENTO'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.qtd_movto < 0 THEN
      SELECT numsequencia
        INTO p_num_seq_orig 
        FROM apont_papel_885
       WHERE codempresa     = p_man.empresa
         AND coditem        = p_man.item
         AND numordem       = p_man.ordem_producao
         AND codmaquina     = p_man.cod_recur
         #AND datiniproducao = p_dat_ini
         #AND datproducao    = p_dat_fim
         AND numlote        = p_man.lote
         AND largura        = p_man.largura
         AND tubete         = p_man.altura
         AND diametro       = p_man.diametro
         AND tipmovto       = p_man.tip_movto
         AND pesobalanca    = -p_man.qtd_movto
         AND estorno        = 0
         AND StatusRegistro = 1

      IF STATUS = 100 THEN
         LET p_msg = 'ESTORNO DE APONTAMENTO NAO ENVIADO AO LOGIX'
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      ELSE 
         IF STATUS <> 0 THEN
            LET p_msg = 'ERRO:(',STATUS, ') CHECADO ESTORNO NA TAB APONT_PAPEL_885'
            RETURN FALSE
         END IF
      END IF
      
   END IF
   
   IF p_man.cod_recur IS NULL OR p_man.cod_recur = 0 THEN
       LET p_msg = 'CODIGO DA MAQUINA NAO INVALIDO PELO TRIM '
       IF NOT pol1270_insere_erro() THEN
          RETURN FALSE
       END IF
   ELSE
      IF NOT pol1270_ck_maquina() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_dat_ini IS NULL THEN
      LET p_msg = 'A DATA INICIAL DA PRODUCAO ENVIADA PELO TRIM ESTA NULA'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF   

   IF p_dat_fim IS NULL THEN
      LET p_msg = 'A DATA FINAL DA PRODUCAO ENVIADA PELO TRIM ESTA NULA'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE   
      IF NOT pol1270_consiste_turno() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_man.tip_movto MATCHES "[FRESP]" THEN
   ELSE
      LET p_msg = 'TIPO DE MOVIMENTO INVALIDDO - ', p_man.tip_movto
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF p_man.qtd_movto IS NULL OR p_man.qtd_movto = 0 THEN
		  LET p_msg = 'QUANTIDADE A APONTAR ESTA NULA OU COM ZERO'
		  IF NOT pol1270_insere_erro() THEN
		     RETURN FALSE
		  END IF
	 END IF

   IF p_dat_ini IS NOT NULL AND p_dat_fim IS NOT NULL THEN
      CALL pol1270_consiste_datas()
   END IF
   
   LET p_man.item = p_cod_item
   LET p_cod_prod = p_man.item

   IF NOT pol1270_le_dimensional() THEN
      RETURN FALSE
   END IF

   IF p_man.tip_movto MATCHES "[FEP]" THEN
      IF NOT pol1270_ck_dimencional() THEN
         RETURN FALSE
      END IF
   END IF
      
   IF NOT p_criticou THEN   
      IF NOT pol1270_ck_operacao() THEN
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
      IF NOT pol1270_le_ord_oper() THEN
         RETURN FALSE
      END IF
      IF NOT pol1270_ck_qtd_apont() THEN
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
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO ITEM'
         RETURN FALSE
      END IF
   END IF

   IF (p_man.qtd_movto < 0 AND p_ies_oper_final = 'S') OR 
      (p_man.qtd_movto < 0 AND p_man.tip_movto MATCHES '[RS]') THEN

      LET p_qtd_baixar = p_man.qtd_movto * (-1)

      IF p_man.tip_movto MATCHES '[FE]' THEN
         IF NOT po1270_pega_dimencional() THEN
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
        
      IF NOT pol1270_ck_estoque() THEN
         RETURN FALSE
      END IF
      
      IF p_sem_estoque THEN
         LET p_msg = 'IT:',p_cod_prod CLIPPED, 'LOTE:',p_num_lote 
         LET p_msg = p_msg CLIPPED, ' - S/ESTOQUE SUFICIETNE P/ESTORNAR'
         IF NOT pol1270_insere_erro() THEN
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
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
      IF p_man.qtd_movto > 0 THEN
         IF NOT pol1270_ck_bobina() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
       
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1270_pega_pedido()#
#-----------------------------#

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

#----------------------------#
FUNCTION pol1270_ck_maquina()#
#----------------------------#

   SELECT cod_compon,
		      cod_operac,
		      cod_arranjo,
		      cod_cent_cust,
		      cod_cent_trab
		 INTO p_man.eqpto,
		      p_man.operacao,
		      p_cod_arranjo,
		      p_cod_cent_cust,
		      p_cod_cent_trab
		 FROM de_para_maq_885
		WHERE cod_empresa  = p_cod_empresa
		  AND cod_maq_trim = p_man.cod_recur
			    
   IF STATUS = 100 THEN
		  LET p_msg = 'MAQUINA NAO CADASTRADA NO DE-PARA - ', p_man.cod_recur
		  IF NOT pol1270_insere_erro() THEN
		     RETURN FALSE
		  END IF
   ELSE
		  IF STATUS <> 0 THEN
		     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB DE_PARA_MAQ'
		     RETURN FALSE
		  END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1270_consiste_turno()
#--------------------------------#

   DEFINE p_minutos    SMALLINT,
          p_minu_ant   SMALLINT,
          p_min_ini    SMALLINT,
          p_min_fim    SMALLINT,
          p_hora       CHAR(05),
          p_hor_ini    CHAR(04),
          p_hor_fim    CHAR(04)
   
   LET p_hora = EXTEND(p_dat_fim, HOUR TO MINUTE)
   LET p_minutos = (p_hora[1,2] * 60) + p_hora[4,5]
   LET p_minu_ant = p_minutos

   IF STATUS <> 0 THEN
      LET p_msg = 'HORA DA PRODUCAO INVALIDA'
      CALL pol1270_insere_erro() RETURNING p_status
      IF NOT p_status THEN
         RETURN FALSE
      ELSE
         RETURN TRUE
      END IF
   END IF

   LET p_msg = 'HORA DO APONTAMENTO FORA DOS TURNOS LOGIX'
   
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
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION
      
#--------------------------------#
FUNCTION pol1270_consiste_datas()
#--------------------------------#
   
   DEFINE p_time             DATETIME HOUR TO SECOND,
          p_hor_prod         CHAR(10),
          p_qtd_segundo      INTEGER
          
   LET p_man.dat_ini_producao = EXTEND(p_dat_ini, YEAR TO DAY)
   LET p_man.dat_fim_producao = EXTEND(p_dat_fim, YEAR TO DAY)
   LET p_man.hor_inicial = EXTEND(p_dat_ini, HOUR TO SECOND)
   LET p_man.hor_fim     = EXTEND(p_dat_fim, HOUR TO SECOND)

   IF p_man.dat_ini_producao > p_man.dat_fim_producao THEN
      LET p_msg = 'DATA INICIAL DA PRODUCAO MAIOR QUE A DATA FINAL '
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_man.dat_fim_producao > TODAY THEN
      LET p_msg = 'DATA FINAL DA PRODUCAO MAIOR QUE DATA ATUAL'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_dat_fecha_ult_man IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_man THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DA MANUFATURA - VER C/ SETOR FISCAL'
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   END IF      

   IF p_dat_fecha_ult_sup IS NOT NULL THEN
      IF p_man.dat_fim_producao <= p_dat_fecha_ult_sup THEN
         LET p_msg = 'PRODUCAO APOS FECHAMENTO DO ESTOQUE - VER C/ SETOR FISCAL'
         IF NOT pol1270_insere_erro() THEN
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
	   
	   #considerar o tempo enviado pelo trim
	   LET p_man.qtd_hor = p_tempoproducao / 60
	   
   END IF
         
END FUNCTION

#--------------------------------#
FUNCTION pol1270_le_dimensional()#
#--------------------------------#
  
   IF NOT pol1270_le_item_ctr_grade(p_cod_prod) THEN
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
   
   LET p_comprimento_ped = 0
   
   RETURN TRUE

END FUNCTION

#--------------------------------------------#
FUNCTION pol1270_le_item_ctr_grade(p_coditem)#
#--------------------------------------------#

   DEFINE p_coditem    LIKE item.cod_item,
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
       AND cod_item      = p_coditem

   FOREACH cq_ctr INTO
           p_ies_largura,
           p_ies_altura,
           p_ies_diametro,
           p_ies_comprimento,
           p_ies_serie,
           p_ies_dat_producao

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

#--------------------------------#
FUNCTION pol1270_ck_dimencional()#
#--------------------------------#
   
   DEFINE p_dim      CHAR(10)
   
   LET p_dim = p_largura_ped
   
   IF p_ies_largura = 'S' THEN
      IF p_man.largura <> p_largura_ped THEN
         LET p_msg = 'DIMENSIONAL LARGURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.largura
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_man.largura = 0
   END IF

   LET p_dim = p_altura_ped

   IF p_ies_altura = 'S' THEN
      IF p_man.altura <> p_altura_ped THEN
         LET p_msg = 'DIMENSIONAL ALTURA NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.altura
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_man.altura = 0
   END IF

   LET p_dim = p_diametro_ped

   IF p_ies_diametro = 'S' THEN
      IF p_man.diametro <> p_diametro_ped THEN
         LET p_msg = 'DIMENSIONAL DIAMETRO NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.diametro
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_man.diametro = 0
   END IF

   LET p_dim = p_comprimento_ped

   IF p_ies_comprimento = 'S' THEN
      IF p_man.comprimento <> p_comprimento_ped THEN
         LET p_msg = 'DIMENSIONAL COMPRIMENTO NAO CONFERE - ESPERADO:', p_dim,' RECEBIDO:',p_man.comprimento
         IF NOT pol1270_insere_erro() THEN
            RETURN FALSE
         END IF
      END IF
   ELSE
      LET p_man.comprimento = 0
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1270_ck_operacao()#
#-----------------------------#

   SELECT ies_apontamento                                               
     INTO p_ies_apontamento                                                
		  FROM ord_oper                                                        
    WHERE cod_empresa    = p_cod_empresa                                   
	    AND num_ordem      = p_man.ordem_producao                            
	    AND cod_operac     = p_man.operacao                                  
                                                                        
   IF STATUS = 100 THEN                                                    
      IF NOT pol1270_insere_operacao() THEN                                
         RETURN FALSE                                                      
      END IF                                                               
      LET p_ies_apontamento = 'S'                                          
   ELSE                                                                    
      IF STATUS <> 0 THEN                                                  
         LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA ORD_OPER'                   
         RETURN FALSE                                                      
      END IF                                                               
   END IF       
                                                              
   IF p_ies_apontamento = 'N' THEN                                         
      LET p_msg = 'OPERACAO ENVIADA NAO E APONTAVEL - ', p_man.cod_recur   
      IF NOT pol1270_insere_erro() THEN                                    
         RETURN FALSE                                                      
      END IF                                                               
   ELSE                                                                    
      IF NOT pol1270_ck_quantidade() THEN                                  
         RETURN FALSE                                                      
      END IF                                                               
   END IF                                                                  

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1270_insere_operacao()
#---------------------------------#

   DEFINE p_num_seq     LIKE ord_oper.num_seq_operac
   DEFINE p_ord_oper    RECORD LIKE ord_oper.*
   
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
      IF NOT pol1270_insere_erro() THEN
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

   LET p_man.sequencia_operacao = p_ord_oper.num_seq_operac
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol1270_ck_quantidade()#
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
		  LET p_msg = 'OPERACAO NAO PREVISTA PARA A ORDEM DE PRODUCAO'
		  IF NOT pol1270_insere_erro() THEN
		     RETURN FALSE
		  END IF
   ELSE
	    IF STATUS <> 0 THEN
		     LET p_msg = 'ERRO:(',STATUS, ') LENDO TAB ORD_OPER'
		     RETURN FALSE
      END IF
   END IF                                           

   IF p_man.qtd_movto < 0 THEN
      LET p_qtd_a_apontar = p_man.qtd_movto * (-1)
      IF ((p_man.tip_movto MATCHES '[FE]' AND p_qtd_a_apontar > p_qtd_boas) OR
          (p_man.tip_movto = 'R' AND p_qtd_a_apontar > p_qtd_refug) OR
          (p_man.tip_movto = 'S' AND p_qtd_a_apontar > p_qtd_sucata)) THEN
         LET p_msg = 'QTD A ESTORNOAR MAIOR QUE QTD JA APONTADAS'
         IF NOT pol1270_insere_erro() THEN
	          RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1270_le_ord_oper()#
#-----------------------------#

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

   RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1270_ck_qtd_apont()#
#-------------------------------#

   INITIALIZE p_msg TO NULL

   LET p_qtd_saldo_apon = p_qtd_planej - p_qtd_boas - p_qtd_refug - p_qtd_sucata

   IF p_man.tip_movto MATCHES '[FRES]' AND p_man.qtd_movto > 0 THEN
      IF p_ies_forca_apont MATCHES "[Ss]" THEN
      ELSE
         IF p_qtd_saldo_apon < p_man.qtd_movto THEN
    		    LET p_msg = 'QTD APONTAR > O SALDO DA ORDEM', p_man.item
    		 END IF
      END IF
   END IF
   
   IF p_man.qtd_movto < 0 THEN
      LET p_qtd_baixar = p_man.qtd_movto * (-1)
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
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
      
END FUNCTION

#---------------------------------#
FUNCTION po1270_pega_dimencional()#
#---------------------------------#

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

#----------------------------#
FUNCTION pol1270_ck_estoque()#
#----------------------------#

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

#---------------------------#
FUNCTION pol1270_ck_bobina()#
#---------------------------#
   
   SELECT COUNT(num_transac)
     INTO p_count
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_dest = p_man.lote
      AND ies_tip_movto = 'N'
      AND num_prog = p_man.nom_prog
      AND num_transac NOT IN
         (SELECT num_transac_normal 
           FROM estoque_trans_rev WHERE cod_empresa = p_cod_empresa)
           
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') LENDO NA ESTOQUE_TRANS/ESTOQUE_TRANS_REV'
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'NUMERO DE BOBINA JA APONTADO NO LOGIX'
      IF NOT pol1270_insere_erro() THEN
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1270_insere_apont()
#-----------------------------#

   LET p_man.dat_atualiz  = CURRENT YEAR TO SECOND
   LET p_man.nom_prog     = 'POL1270'
   LET p_man.nom_usuario  = p_user
   LET p_man.num_versao   = 1
   LET p_man.versao_atual = 'S'
   LET p_man.cod_status   = '0'
   LET p_man.unid_produtiva = ' '

   INSERT INTO man_apont_885
    VALUES(p_man.*)
     
   IF STATUS <> 0 THEN 
      LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA MAN_APONT_912'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol1270_grava_apont_papel()
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

#----------------------------#
FUNCTION pol1270_apontar_op()#
#----------------------------#

   DEFINE p_cod_movto     CHAR(01),
          p_tmp_apontar   DECIMAL(11, 7),
          p_tmp_refugar   DECIMAL(11, 7)
   
   INITIALIZE p_man, p_num_conta TO NULL
   
   DECLARE cq_apont CURSOR WITH HOLD FOR
    SELECT *
      FROM man_apont_885
     WHERE empresa      = p_cod_empresa
       AND versao_atual = 'S'

   FOREACH cq_apont INTO p_man.*
		
      IF STATUS <> 0 THEN
         LET p_msg = 'ERRO:(',STATUS, ') LENDO PROXIMO APONTAMENTO DO CURSOR:CQ_APONT'
         RETURN FALSE
      END IF                                           

      DISPLAY p_man.ordem_producao TO num_ordem
        #lds CALL LOG_refresh_display()	
      
      LET p_cod_movto = p_man.tip_movto 
      
      IF p_man.qtd_movto > 0 THEN   #Apontamento 
         
         IF p_man.tip_movto MATCHES '[FE]' THEN  #apto de peças boas ou excepcional
            IF p_ies_oper_final = 'S' THEN
               SELECT pct_desc_qtd            #verifica se o pedido tem desconto de quantidade
                 INTO p_pct_desc_qtd
                 FROM desc_nat_oper_885
                WHERE cod_empresa = p_cod_empresa
                  AND num_pedido = p_man.num_pedido
      
               IF STATUS <> 0 THEN
                  LET p_msg = 'ERRO:(',STATUS, ') LENDO TABELA DESC_NAT_OPER_885'
                  RETURN FALSE
               END IF          
            ELSE
               LET p_pct_desc_qtd = 0
            END IF
            
            IF p_pct_desc_qtd <= 0 THEN
               LET p_qtd_apontar = p_man.qtd_movto
               LET p_qtd_refugar = 0
               LET p_tmp_apontar = p_man.qtd_hor
               LET p_tmp_refugar = 0
            ELSE
               LET p_qtd_refugar = p_man.qtd_movto * p_pct_desc_qtd / 100
               LET p_qtd_apontar = p_man.qtd_movto - p_qtd_refugar
               LET p_tmp_apontar = p_man.qtd_hor * ((100 - p_pct_desc_qtd) / 100)
               LET p_tmp_refugar = p_man.qtd_hor * p_pct_desc_qtd / 100
            END IF
      
            IF p_qtd_apontar > 0 THEN
               LET p_man.qtd_movto = p_qtd_apontar
               LET p_man.qtd_hor = p_tmp_apontar
               IF NOT pol1270a_aponta_producao() THEN #aponta a produção como liberada
                  RETURN FALSE
               END IF
            END IF

            IF p_qtd_refugar > 0 THEN
               LET p_man.qtd_movto = p_qtd_refugar
               LET p_man.qtd_hor = p_tmp_refugar
               LET p_man.tip_movto = 'R'
               IF NOT pol1270a_aponta_producao() THEN  #aponta a produção como refugo
                  RETURN FALSE
               END IF
               LET p_qtd_movto = p_qtd_refugar
               LET p_cod_operacao = p_oper_sai_apto_refug
               LET p_tip_operacao = 'S'
               LET p_cod_tip_apon = 'B'
               IF NOT pol1270a_trans_refugo() THEN     #faz a saída da produção de refugo(operação especial)
                  RETURN FALSE
               END IF
               LET  p_man.tip_movto = p_cod_movto
            END IF
         END IF
         
         IF p_man.tip_movto = 'R' THEN  #apto de refugo
            IF NOT pol1270a_aponta_producao() THEN  #aponta a produção como refugo
               RETURN FALSE
            END IF
            
            #efetua transferência da produção de refugo para o item refugo
            
            LET p_cod_tip_apon = 'B'  #fará a saida do item pai
            LET p_tip_operacao = 'S'
            LET p_cod_operacao = p_oper_sai_tp_refugo
            LET p_ies_situa = 'R'
            LET p_ies_implant = 'N'
            
            IF NOT pol1270a_trans_refugo() THEN  #transfere do item pai p/ o item refugo
               RETURN FALSE
            END IF

            LET p_cod_tip_apon = 'A'  #fará a entrada no item refugo
            LET p_tip_operacao = 'E'
            LET p_cod_operacao = p_oper_ent_tp_refugo
            LET p_man.item = p_cod_item_refugo
            LET p_man.lote = p_num_lote_refugo
            LET p_man.comprimento = 0
            LET p_man.largura = 0    
            LET p_man.altura = 0    
            LET p_man.diametro = 0 
            LET p_ies_situa = 'L' 
            LET p_ies_implant = 'S'
            
            IF NOT pol1270a_trans_refugo() THEN  #transfere do item pai p/ o item refugo
               RETURN FALSE
            END IF

         END IF

         IF p_man.tip_movto = 'S' THEN  #apto de sucata
            LET p_man.item = p_cod_item_sucata          
            LET p_man.lote = p_num_lote_sucata
            IF p_man.lote = ' ' THEN
               LET p_man.lote = NULL
            END IF
            LET p_man.comprimento = 0
            LET p_man.largura = 0
            LET p_man.altura = 0
            LET p_man.diametro = 0
            LET p_cod_oper_rp = p_cod_oper_sucata
            IF NOT pol1270a_aponta_producao() THEN #aponta a produção como liberada no item sucata
               RETURN FALSE
            END IF
         END IF
                  
      END IF
      
      #---estorno---#
      IF p_man.qtd_movto < 0 THEN
         IF NOT pol1270a_estorna_producao() THEN
            RETURN FALSE
         END IF
      END IF
   
   END FOREACH
                                    
   RETURN TRUE

END FUNCTION

  