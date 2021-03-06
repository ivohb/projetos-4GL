#---------------------------------------------------------------#
#--Objetivo: estorno parcial de apontameto de produ��o a partir #
#      do par�metros enviados                                   #          
#--Obs: a rotina que a chama deve ter uma transa��o aberta------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150),
          g_tipo_sgbd         CHAR(003)
END GLOBALS

DEFINE p_cod_empresa          CHAR(02),
       p_user                 CHAR(08),
       p_status               SMALLINT,
       m_seq_reg_mestre       INTEGER,
       m_seq_reg_item         INTEGER,
       m_erro                 CHAR(10),
       m_msg                  CHAR(150),
       m_dat_proces           DATE,
       m_hor_operac           CHAR(08),
       m_num_transac          INTEGER,
       m_transac_rev          INTEGER,
       m_num_prog             CHAR(08),
       m_trans_lot_ender      INTEGER,
       m_trans_lote           INTEGER,
       m_qtd_movto            DECIMAL(10,3),
       m_qtd_estornar         DECIMAL(10,3),
       m_tip_producao         CHAR(01),
       m_prop_estorno         DECIMAL(10,7),
       m_mov_estoque_pai      INTEGER
       
DEFINE mr_item_prodz          RECORD LIKE man_item_produzido.*,     
       mr_comp_consumid       RECORD LIKE man_comp_consumido.*,
       mr_est_trans           RECORD LIKE estoque_trans.*,
       mr_trans_end           RECORD LIKE estoque_trans_end.*,
       m_num_ordem            LIKE ordens.num_ordem,
       m_qtd_produzida        LIKE man_item_produzido.qtd_produzida,
       m_qtd_convertida       LIKE man_item_produzido.qtd_convertida,
       m_qtd_boas             LIKE ord_oper.qtd_boas,
       m_qtd_refugo           LIKE ord_oper.qtd_refugo,
       m_qtd_sucata           LIKE ord_oper.qtd_sucata,
       m_cod_operac           LIKE man_apo_detalhe.operacao,
       m_num_seq_operac       LIKE man_apo_detalhe.sequencia_operacao
          
   DEFINE m_parametro      RECORD
          cod_empresa      CHAR(02),
          cod_item         CHAR(15),
          cod_local        CHAR(10),
          num_lote         CHAR(15), #opcional
          ies_situa_qtd    CHAR(01)          
   END RECORD
       
#--------------------par�metros--------------------#
#Campos do record lr_parm abaixo declarado         #
#--------------------retorno-----------------------#
# TRUE/FALSE                                       #
#--------------------------------------------------# 
# OBS: somente o apontamento da sequencia do item  #
#      ser� estornado;                             #
#      qualquer tipo de erro ser� gravado na       #
#      tabela estorno_erro_f020;                   #
#--------------------------------------------------#
FUNCTION func020_estorna_apto(lr_param)            #
#--------------------------------------------------#
   
   DEFINE lr_param                       RECORD
          empresa                        CHAR(02),
          usuario                        CHAR(08),
          seq_mestre                     INTEGER,
          seq_item                       INTEGER,
          qtd_estornar                   DECIMAL(10,3),
          tip_producao                   CHAR(01),
          nom_programa                   CHAR(08)
   END RECORD
   
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_cod_empresa = lr_param.empresa
   LET p_user = lr_param.usuario
   LET m_seq_reg_mestre = lr_param.seq_mestre
   LET m_seq_reg_item = lr_param.seq_item
   LET m_qtd_estornar = lr_param.qtd_estornar   
   LET m_tip_producao = lr_param.tip_producao   
   LET m_num_prog = lr_param.nom_programa
   
   IF m_seq_reg_item IS NULL THEN
      LET m_seq_reg_item = 0
   END IF
   
   IF m_tip_producao <> 'B' THEN
      IF m_seq_reg_item <= 0 THEN
         LET m_msg = 'Sequencia do item inv�lida'
         LET p_status = func020_ins_erro()
         RETURN FALSE
      END IF
   END IF
            
   DELETE FROM estorno_erro_f020
    WHERE cod_empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED,' deletando tab estorno_erro_f020'
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF

   IF NOT func020_le_apo_mestre() THEN
      RETURN FALSE
   END IF
   
   IF lr_param.seq_item > 0 THEN
      IF NOT func020_estorna_item() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT func020_le_operacao() THEN
         RETURN FALSE
      END IF
   END IF

   IF NOT func020_estorna_mestre() THEN
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
                
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION func020_cria_tab()#
#--------------------------#

   CREATE TABLE estorno_erro_f020 (
      cod_empresa        CHAR(02),
      seq_reg_mestre     INTEGER,
      seq_reg_item       INTEGER,
      mensagem           CHAR(120));

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED,' criando tab estorno_erro_f020'
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF

   CREATE INDEX ix_estorno_erro_f020
    ON estorno_erro_f020(cod_empresa, seq_reg_mestre);

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro:(',STATUS, ') criando index ix_estorno_erro_f020'
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------#
FUNCTION func020_le_apo_mestre()#
#-------------------------------#

   DEFINE l_dat_fecha_ult_man  LIKE par_estoque.dat_fecha_ult_man,                   
          l_dat_fecha_ult_sup  LIKE par_estoque.dat_fecha_ult_sup                   

   DEFINE p_seq_txt     CHAR(15),
          l_tip_mov     CHAR(01),
          l_dat_prod    DATE
   
   LET m_msg = NULL
   
   SELECT tip_moviment,
          data_producao,
          ordem_producao
     INTO l_tip_mov, l_dat_prod, m_num_ordem
     FROM man_apo_mestre
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre

   IF STATUS = 100 THEN   
      LET m_msg = 'Apontamento enexistente no logix '
      LET p_status = func020_ins_erro()
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_apo_mestre' 
         LET p_status = func020_ins_erro()
         RETURN FALSE
      END IF
   END IF
      
   SELECT dat_fecha_ult_man,
          dat_fecha_ult_sup
     INTO l_dat_fecha_ult_man,
          l_dat_fecha_ult_sup
     FROM par_estoque
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela par_estoque' 
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF

   IF l_dat_fecha_ult_man IS NOT NULL THEN
      IF l_dat_prod <= l_dat_fecha_ult_man THEN
         LET m_msg = 'Manufatura j� fechada para a data ', l_dat_prod
         LET p_status = func020_ins_erro()
      END IF
   END IF      

   IF l_dat_fecha_ult_sup IS NOT NULL THEN
      IF l_dat_prod <= l_dat_fecha_ult_sup THEN
         LET m_msg = 'Estoque j� fechado para a data ', l_dat_prod
         LET p_status = func020_ins_erro()
      END IF
   END IF

   IF l_tip_mov = 'E' THEN
      LET m_msg = 'Esee apontamento j� est� estornado '
      LET p_status = func020_ins_erro()
   END IF

   IF m_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#        
FUNCTION func020_ins_erro()#
#--------------------------#    

   INSERT INTO estorno_erro_f020    
    VALUES(p_cod_empresa, m_seq_reg_mestre, m_seq_reg_item, m_msg)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo erros na tab estorno_erro_f020' 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION func020_estorna_item()#
#------------------------------#
   
   DEFINE l_qtd_produzida      LIKE man_item_produzido.qtd_produzida,
          l_qtd_convertida     LIKE man_item_produzido.qtd_convertida,
          l_sdo_apont          LIKE man_item_produzido.qtd_produzida
   
   SELECT * INTO mr_item_prodz.*
     FROM man_item_produzido
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
      AND seq_registro_item = m_seq_reg_item   
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_item_produzido:1' 
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
   
   LET m_tip_producao = mr_item_prodz.tip_producao
   LET m_qtd_produzida = mr_item_prodz.qtd_produzida
   LET m_qtd_convertida = mr_item_prodz.qtd_convertida
   
   IF mr_item_prodz.qtd_produzida = m_qtd_estornar THEN
      LET m_prop_estorno = 1
   ELSE
      LET m_prop_estorno = m_qtd_estornar / mr_item_prodz.qtd_produzida
   END IF
      
   SELECT SUM(qtd_produzida), SUM(qtd_convertida)
     INTO l_qtd_produzida, l_qtd_convertida
     FROM man_item_produzido
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
      AND seq_reg_normal = m_seq_reg_item
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_item_produzido:2' 
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
      
   IF l_qtd_produzida IS NULL THEN
      LET l_qtd_produzida = 0
   END IF

   IF l_qtd_convertida IS NULL THEN
      LET l_qtd_convertida = 0
   END IF

   LET m_qtd_boas = 0
   LET m_qtd_refugo = 0
   LET m_qtd_sucata = 0
      
   IF m_tip_producao = 'B' THEN
      LET m_qtd_boas = m_qtd_estornar
      LET l_sdo_apont = m_qtd_boas -  l_qtd_produzida
   ELSE
      IF m_tip_producao = 'R' THEN
         LET m_qtd_refugo = m_qtd_estornar
         LET l_sdo_apont = m_qtd_refugo -  l_qtd_produzida
      ELSE
         LET m_qtd_sucata = m_qtd_estornar
         LET l_sdo_apont = m_qtd_sucata - l_qtd_convertida
      END IF
   END IF         
            
   IF l_sdo_apont < m_qtd_estornar THEN
       LET m_msg = 'Saldo do apontamento menor que quantidade a estornar' 
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
      
   LET mr_item_prodz.qtd_produzida = m_qtd_estornar

   IF mr_item_prodz.moviment_estoque > 0 THEN
      LET m_num_transac = mr_item_prodz.moviment_estoque
      LET m_mov_estoque_pai = mr_item_prodz.moviment_estoque
      IF NOT func020_estorna_estoque() THEN
         LET p_status = func020_ins_erro()
         RETURN FALSE
      END IF
   ELSE
      LET m_mov_estoque_pai = 0
   END IF

   LET mr_item_prodz.tip_movto = 'E'
   LET mr_item_prodz.seq_reg_normal = mr_item_prodz.seq_registro_item
   LET mr_item_prodz.seq_registro_item = 0 #campo serial
   LET mr_item_prodz.moviment_estoque = m_transac_rev
      
   IF NOT func020_ins_item_produz() THEN
      RETURN FALSE
   END IF      
   
   IF m_mov_estoque_pai > 0 THEN
      IF NOT func020_estorna_consumo() THEN
         LET p_status = func020_ins_erro()
         RETURN FALSE
      END IF
   END IF      

   SELECT DISTINCT
          operacao, 
          sequencia_operacao
     INTO m_cod_operac,
          m_num_seq_operac
     FROM man_apo_detalhe 
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_apo_detalhe:1' 
      LET p_status = func020_ins_erro()
      RETURN FALSE
   END IF
   
   IF NOT func020_estorna_operacao() THEN
      RETURN FALSE
   END IF
   
   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item_prodz.item_produzido
      AND qtd_saldo = 0

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = mr_item_prodz.item_produzido
      AND qtd_saldo = 0
           
   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION func020_ins_item_produz()#
#---------------------------------#
   
   IF g_tipo_sgbd = 'MSV' THEN
     INSERT INTO man_item_produzido(
     empresa,              
     seq_reg_mestre,       
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
     mr_item_prodz.empresa,              
     mr_item_prodz.seq_reg_mestre,       
     mr_item_prodz.tip_movto,            
     mr_item_prodz.item_produzido,       
     mr_item_prodz.lote_produzido,       
     mr_item_prodz.grade_1,              
     mr_item_prodz.grade_2,              
     mr_item_prodz.grade_3,              
     mr_item_prodz.grade_4,              
     mr_item_prodz.grade_5,              
     mr_item_prodz.num_peca,             
     mr_item_prodz.serie,                
     mr_item_prodz.volume,               
     mr_item_prodz.comprimento,          
     mr_item_prodz.largura,              
     mr_item_prodz.altura,               
     mr_item_prodz.diametro,             
     mr_item_prodz.local,                
     mr_item_prodz.endereco,             
     mr_item_prodz.tip_producao,         
     mr_item_prodz.qtd_produzida,        
     mr_item_prodz.qtd_convertida,       
     mr_item_prodz.sit_est_producao,     
     mr_item_prodz.data_producao,        
     mr_item_prodz.data_valid,           
     mr_item_prodz.conta_ctbl,           
     mr_item_prodz.moviment_estoque,     
     mr_item_prodz.seq_reg_normal,       
     mr_item_prodz.observacao,           
     mr_item_prodz.identificacao_estoque)
   
   ELSE
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
     mr_item_prodz.empresa,              
     mr_item_prodz.seq_reg_mestre,       
     mr_item_prodz.seq_registro_item,    
     mr_item_prodz.tip_movto,            
     mr_item_prodz.item_produzido,       
     mr_item_prodz.lote_produzido,       
     mr_item_prodz.grade_1,              
     mr_item_prodz.grade_2,              
     mr_item_prodz.grade_3,              
     mr_item_prodz.grade_4,              
     mr_item_prodz.grade_5,              
     mr_item_prodz.num_peca,             
     mr_item_prodz.serie,                
     mr_item_prodz.volume,               
     mr_item_prodz.comprimento,          
     mr_item_prodz.largura,              
     mr_item_prodz.altura,               
     mr_item_prodz.diametro,             
     mr_item_prodz.local,                
     mr_item_prodz.endereco,             
     mr_item_prodz.tip_producao,         
     mr_item_prodz.qtd_produzida,        
     mr_item_prodz.qtd_convertida,       
     mr_item_prodz.sit_est_producao,     
     mr_item_prodz.data_producao,        
     mr_item_prodz.data_valid,           
     mr_item_prodz.conta_ctbl,           
     mr_item_prodz.moviment_estoque,     
     mr_item_prodz.seq_reg_normal,       
     mr_item_prodz.observacao,           
     mr_item_prodz.identificacao_estoque)
   
   END IF
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados na tab man_item_produzido' 
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION func020_estorna_estoque()#
#--------------------------------#
   
   DEFINE l_qtd_estoq      DECIMAL(10,3)
   
   SELECT * INTO mr_est_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_num_transac
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lenddo dados da tab estoque_trans' 
      RETURN FALSE
   END IF
   
   LET mr_est_trans.qtd_movto     = m_qtd_estornar
   
   LET m_parametro.cod_empresa    = mr_est_trans.cod_empresa     
   LET m_parametro.cod_item       = mr_est_trans.cod_item
   LET m_parametro.cod_local      = mr_est_trans.cod_local_est_dest 
   LET m_parametro.num_lote       = mr_est_trans.num_lote_dest 
   LET m_parametro.ies_situa_qtd  = mr_est_trans.ies_sit_est_dest

   CALL func002_est_lote(m_parametro) RETURNING m_msg, l_qtd_estoq, m_trans_lote
   
   IF m_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   IF l_qtd_estoq < mr_est_trans.qtd_movto THEN
      LET m_msg = 'Item ', mr_est_trans.cod_item, 
                  ' sem saldo dispon�vel na tabela estoque_lote'
      RETURN FALSE
   END IF
   
   CALL func002_est_lot_ender(m_parametro) RETURNING m_msg, l_qtd_estoq, m_trans_lot_ender
   
   IF m_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   IF l_qtd_estoq < mr_est_trans.qtd_movto THEN
      LET m_msg = 'Item ', mr_est_trans.cod_item, 
                  ' sem saldo dispon�vel na tabela estoque_lote_ender'
      RETURN FALSE
   END IF
      
   IF NOT func020_ins_est_tranas() THEN
      RETURN FALSE
   END IF

   IF NOT func020_ins_tranas_end() THEN
      RETURN FALSE
   END IF
   
   LET m_qtd_movto = mr_est_trans.qtd_movto * (-1)
   
   IF NOT func020_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func020_ins_est_tranas()#
#--------------------------------#
   
   LET mr_est_trans.num_transac = 0 #campo auto increment
   LET mr_est_trans.ies_tip_movto = 'R'
   LET mr_est_trans.nom_usuario = p_user
   LET mr_est_trans.dat_proces = m_dat_proces
   LET mr_est_trans.hor_operac = m_hor_operac
   LET mr_est_trans.num_prog =  m_num_prog

   IF g_tipo_sgbd = 'MSV' THEN
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
          VALUES (mr_est_trans.cod_empresa,
                  mr_est_trans.cod_item,
                  mr_est_trans.dat_movto,
                  mr_est_trans.dat_ref_moeda_fort,
                  mr_est_trans.cod_operacao,
                  mr_est_trans.num_docum,
                  mr_est_trans.num_seq,
                  mr_est_trans.ies_tip_movto,
                  mr_est_trans.qtd_movto,
                  mr_est_trans.cus_unit_movto_p,
                  mr_est_trans.cus_tot_movto_p,
                  mr_est_trans.cus_unit_movto_f,
                  mr_est_trans.cus_tot_movto_f,
                  mr_est_trans.num_conta,
                  mr_est_trans.num_secao_requis,
                  mr_est_trans.cod_local_est_orig,
                  mr_est_trans.cod_local_est_dest,
                  mr_est_trans.num_lote_orig,
                  mr_est_trans.num_lote_dest,
                  mr_est_trans.ies_sit_est_orig,
                  mr_est_trans.ies_sit_est_dest,
                  mr_est_trans.cod_turno,
                  mr_est_trans.nom_usuario,
                  mr_est_trans.dat_proces,
                  mr_est_trans.hor_operac,
                  mr_est_trans.num_prog)   
   ELSE
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
          VALUES (mr_est_trans.cod_empresa,
                  mr_est_trans.num_transac,
                  mr_est_trans.cod_item,
                  mr_est_trans.dat_movto,
                  mr_est_trans.dat_ref_moeda_fort,
                  mr_est_trans.cod_operacao,
                  mr_est_trans.num_docum,
                  mr_est_trans.num_seq,
                  mr_est_trans.ies_tip_movto,
                  mr_est_trans.qtd_movto,
                  mr_est_trans.cus_unit_movto_p,
                  mr_est_trans.cus_tot_movto_p,
                  mr_est_trans.cus_unit_movto_f,
                  mr_est_trans.cus_tot_movto_f,
                  mr_est_trans.num_conta,
                  mr_est_trans.num_secao_requis,
                  mr_est_trans.cod_local_est_orig,
                  mr_est_trans.cod_local_est_dest,
                  mr_est_trans.num_lote_orig,
                  mr_est_trans.num_lote_dest,
                  mr_est_trans.ies_sit_est_orig,
                  mr_est_trans.ies_sit_est_dest,
                  mr_est_trans.cod_turno,
                  mr_est_trans.nom_usuario,
                  mr_est_trans.dat_proces,
                  mr_est_trans.hor_operac,
                  mr_est_trans.num_prog)   
   
   END IF
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados da tab estoque_trans' 
      RETURN FALSE
   END IF

   LET m_transac_rev = SQLCA.SQLERRD[2]
   LET mr_est_trans.num_transac = m_transac_rev

   INSERT INTO estoque_trans_rev
    VALUES(p_cod_empresa,
           m_num_transac,
           m_transac_rev)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados da tab estoque_trans_rev' 
      RETURN FALSE
   END IF

  INSERT INTO estoque_auditoria(
   cod_empresa,
   num_transac,
   nom_usuario,
   dat_hor_proces,
   num_programa)
  VALUES(p_cod_empresa, 
      mr_est_trans.num_transac, 
      mr_est_trans.nom_usuario, 
      mr_est_trans.dat_proces, 
      mr_est_trans.num_prog)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados da tab estoque_trans_rev' 
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION func020_ins_tranas_end()#
#--------------------------------#
   
   SELECT * INTO mr_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_num_transac
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lenddo dados da tab estoque_trans_end' 
      RETURN FALSE
   END IF
   
   LET mr_trans_end.num_transac = mr_est_trans.num_transac 
   LET mr_trans_end.ies_tip_movto = mr_est_trans.ies_tip_movto

   INSERT INTO estoque_trans_end VALUES (mr_trans_end.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados na tab estoque_trans_end' 
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func020_atu_estoque()#
#-----------------------------#
   
   DEFINE l_estoque RECORD LIKE estoque.*

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + m_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_trans_lote
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' atalizando dados na tab estoque_lote' 
      RETURN FALSE
   END IF

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + m_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_trans_lot_ender
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' atalizando dados na tab estoque_lote_ender' 
      RETURN FALSE
   END IF

   SELECT *
     INTO l_estoque.*
     FROM estoque
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_parametro.cod_item

   IF STATUS = 100 THEN
      INITIALIZE l_estoque.* TO NULL
      LET l_estoque.cod_empresa = p_cod_empresa
      LET l_estoque.cod_item = m_parametro.cod_item
      LET l_estoque.qtd_liberada  = 0
      LET l_estoque.qtd_impedida  = 0
      LET l_estoque.qtd_rejeitada = 0
      LET l_estoque.qtd_lib_excep = 0
      LET l_estoque.qtd_disp_venda = 0
      LET l_estoque.qtd_reservada = 0
      
      INSERT INTO estoque
       VALUES(l_estoque.*)
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' inserido dados na tab estoque' 
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab estoque'  
         RETURN FALSE
      END IF   
   END IF
   
   IF m_qtd_movto < 0 THEN
      LET l_estoque.dat_ult_saida = TODAY
   ELSE
      LET l_estoque.dat_ult_entrada = TODAY
   END IF
   
   CASE m_parametro.ies_situa_qtd 
      WHEN 'L' LET l_estoque.qtd_liberada = l_estoque.qtd_liberada + m_qtd_movto
      WHEN 'R' LET l_estoque.qtd_rejeitada = l_estoque.qtd_rejeitada + m_qtd_movto
      WHEN 'E' LET l_estoque.qtd_lib_excep = l_estoque.qtd_lib_excep + m_qtd_movto
   END CASE
   
   UPDATE estoque
      SET dat_ult_entrada = l_estoque.dat_ult_entrada,
          dat_ult_saida   = l_estoque.dat_ult_saida,
          qtd_liberada = l_estoque.qtd_liberada,
          qtd_rejeitada = l_estoque.qtd_rejeitada,
          qtd_lib_excep = l_estoque.qtd_lib_excep
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_parametro.cod_item

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' atualizando dados da tabela estoque'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION func020_estorna_consumo()#
#--------------------------------#
      
   DECLARE cq_consumo CURSOR FOR
    SELECT * 
      FROM man_comp_consumido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = m_seq_reg_mestre
       AND mov_estoque_pai = m_mov_estoque_pai
   
   FOREACH cq_consumo  INTO mr_comp_consumid.*   

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_comp_consumido' 
         RETURN FALSE
      END IF

      LET mr_comp_consumid.tip_movto = 'E'
      LET mr_comp_consumid.seq_reg_normal = mr_comp_consumid.seq_registro_item
      LET mr_comp_consumid.seq_registro_item = 0 #campo serial
      LET mr_comp_consumid.qtd_baixa_prevista = mr_comp_consumid.qtd_baixa_prevista * m_prop_estorno
      LET mr_comp_consumid.qtd_baixa_real = mr_comp_consumid.qtd_baixa_real * m_prop_estorno
      LET mr_comp_consumid.mov_estoque_pai = mr_item_prodz.moviment_estoque

      IF mr_comp_consumid.moviment_estoque > 0 THEN
         LET m_num_transac = mr_comp_consumid.moviment_estoque
         IF NOT func020_estorna_baixa(mr_comp_consumid.qtd_baixa_real) THEN
            RETURN FALSE
         END IF
      END IF

      LET mr_comp_consumid.moviment_estoque = m_transac_rev
   
      IF NOT func020_ins_man_consumo() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION func020_ins_man_consumo()#
#----------------------------------#

   IF g_tipo_sgbd = 'MSV' THEN
     INSERT INTO man_comp_consumido(
     empresa,            
     seq_reg_mestre,    
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
     mr_comp_consumid.empresa,                   
     mr_comp_consumid.seq_reg_mestre,    
     mr_comp_consumid.tip_movto,         
     mr_comp_consumid.item_componente,   
     mr_comp_consumid.grade_1,           
     mr_comp_consumid.grade_2,           
     mr_comp_consumid.grade_3,           
     mr_comp_consumid.grade_4,           
     mr_comp_consumid.grade_5,           
     mr_comp_consumid.num_peca,         
     mr_comp_consumid.serie,             
     mr_comp_consumid.volume,            
     mr_comp_consumid.comprimento,       
     mr_comp_consumid.largura,           
     mr_comp_consumid.altura,            
     mr_comp_consumid.diametro,          
     mr_comp_consumid.lote_componente,   
     mr_comp_consumid.local_estoque,     
     mr_comp_consumid.endereco,          
     mr_comp_consumid.qtd_baixa_prevista,
     mr_comp_consumid.qtd_baixa_real,    
     mr_comp_consumid.sit_est_componente,
     mr_comp_consumid.data_producao,     
     mr_comp_consumid.data_valid,        
     mr_comp_consumid.conta_ctbl,        
     mr_comp_consumid.moviment_estoque,  
     mr_comp_consumid.mov_estoque_pai,   
     mr_comp_consumid.seq_reg_normal,    
     mr_comp_consumid.observacao,        
     mr_comp_consumid.identificacao_estoque,
     mr_comp_consumid.depositante)     

   ELSE
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
     mr_comp_consumid.empresa,                   
     mr_comp_consumid.seq_reg_mestre,    
     mr_comp_consumid.seq_registro_item, 
     mr_comp_consumid.tip_movto,         
     mr_comp_consumid.item_componente,   
     mr_comp_consumid.grade_1,           
     mr_comp_consumid.grade_2,           
     mr_comp_consumid.grade_3,           
     mr_comp_consumid.grade_4,           
     mr_comp_consumid.grade_5,           
     mr_comp_consumid.num_peca,         
     mr_comp_consumid.serie,             
     mr_comp_consumid.volume,            
     mr_comp_consumid.comprimento,       
     mr_comp_consumid.largura,           
     mr_comp_consumid.altura,            
     mr_comp_consumid.diametro,          
     mr_comp_consumid.lote_componente,   
     mr_comp_consumid.local_estoque,     
     mr_comp_consumid.endereco,          
     mr_comp_consumid.qtd_baixa_prevista,
     mr_comp_consumid.qtd_baixa_real,    
     mr_comp_consumid.sit_est_componente,
     mr_comp_consumid.data_producao,     
     mr_comp_consumid.data_valid,        
     mr_comp_consumid.conta_ctbl,        
     mr_comp_consumid.moviment_estoque,  
     mr_comp_consumid.mov_estoque_pai,   
     mr_comp_consumid.seq_reg_normal,    
     mr_comp_consumid.observacao,        
     mr_comp_consumid.identificacao_estoque,
     mr_comp_consumid.depositante)     
   
   END IF
        
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados na tab man_comp_consumido' 
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------------------#
FUNCTION func020_estorna_baixa(l_qtd_estornar)#
#---------------------------------------------#
   
   DEFINE l_qtd_estornar   LIKE estoque_trans.qtd_movto
   
   SELECT * INTO mr_est_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = m_num_transac
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lenddo dados da tab estoque_trans' 
      RETURN FALSE
   END IF

   LET mr_est_trans.qtd_movto     = l_qtd_estornar
   
   LET m_parametro.cod_empresa    = mr_est_trans.cod_empresa     
   LET m_parametro.cod_item       = mr_est_trans.cod_item
   LET m_parametro.cod_local      = mr_est_trans.cod_local_est_orig 
   LET m_parametro.num_lote       = mr_est_trans.num_lote_orig 
   LET m_parametro.ies_situa_qtd  = mr_est_trans.ies_sit_est_orig
      
   IF NOT func020_ins_est_tranas() THEN
      RETURN FALSE
   END IF

   IF NOT func020_ins_tranas_end() THEN
      RETURN FALSE
   END IF

   CALL func002_le_lote(m_parametro) RETURNING m_msg, m_trans_lote
   
   IF m_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   LET m_qtd_movto = mr_est_trans.qtd_movto 
      
   IF m_trans_lote = 0 THEN
      IF NOT func020_ins_lote() THEN
         RETURN FALSE
      END IF
   END IF
   
   CALL func002_le_lot_ender(m_parametro) RETURNING m_msg, m_trans_lot_ender
   
   IF m_msg IS NOT NULL THEN
      RETURN FALSE
   END IF

   IF m_trans_lot_ender = 0 THEN
      IF NOT func020_ins_lot_ender() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT func020_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
      
#--------------------------#      
FUNCTION func020_ins_lote()#
#--------------------------#

   IF g_tipo_sgbd = 'MSV' THEN     
      INSERT INTO estoque_lote(
      cod_empresa,  
      cod_item,    
      cod_local,    
      num_lote,     
      ies_situa_qtd,
      qtd_saldo) 
      VALUES(p_cod_empresa,
          m_parametro.cod_item,     
          m_parametro.cod_local,    
          m_parametro.num_lote,     
          m_parametro.ies_situa_qtd,
          m_qtd_movto)
   ELSE
      INSERT INTO estoque_lote(
      cod_empresa,  
      cod_item,    
      cod_local,    
      num_lote,     
      ies_situa_qtd,
      num_transac,
      qtd_saldo) 
      VALUES(p_cod_empresa,
          m_parametro.cod_item,     
          m_parametro.cod_local,    
          m_parametro.num_lote,     
          m_parametro.ies_situa_qtd,
          0,
          m_qtd_movto)
   
   END IF
         
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados na tab estoque_lote' 
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION
   
#-------------------------------#   
FUNCTION func020_ins_lot_ender()#
#-------------------------------#

   DEFINE lr_est_ender RECORD LIKE estoque_lote_ender.*
   
   LET lr_est_ender.cod_empresa        = p_cod_empresa
	 LET lr_est_ender.cod_item           = m_parametro.cod_item     
	 LET lr_est_ender.cod_local          = m_parametro.cod_local    
	 LET lr_est_ender.num_lote           = m_parametro.num_lote     
	 LET lr_est_ender.ies_situa_qtd      = m_parametro.ies_situa_qtd
	 LET lr_est_ender.qtd_saldo          = m_qtd_movto
	 LET lr_est_ender.num_transac        = 0
   LET lr_est_ender.largura            = mr_trans_end.largura
   LET lr_est_ender.altura             = mr_trans_end.altura
   LET lr_est_ender.diametro           = mr_trans_end.diametro
   LET lr_est_ender.comprimento        = mr_trans_end.comprimento
   LET lr_est_ender.dat_hor_producao   = mr_trans_end.dat_hor_producao
   LET lr_est_ender.dat_hor_validade   = mr_trans_end.dat_hor_validade
   LET lr_est_ender.dat_hor_reserv_1   = mr_trans_end.dat_hor_reserv_1
   LET lr_est_ender.dat_hor_reserv_2   = mr_trans_end.dat_hor_reserv_2
   LET lr_est_ender.dat_hor_reserv_3   = mr_trans_end.dat_hor_reserv_3
   LET lr_est_ender.num_serie          = mr_trans_end.num_serie
   LET lr_est_ender.endereco           = mr_trans_end.endereco_origem
   LET lr_est_ender.num_volume         = mr_trans_end.num_volume
   LET lr_est_ender.cod_grade_1        = mr_trans_end.cod_grade_1
   LET lr_est_ender.cod_grade_2        = mr_trans_end.cod_grade_2
   LET lr_est_ender.cod_grade_3        = mr_trans_end.cod_grade_3
   LET lr_est_ender.cod_grade_4        = mr_trans_end.cod_grade_4
   LET lr_est_ender.cod_grade_5        = mr_trans_end.cod_grade_5
   LET lr_est_ender.num_ped_ven        = mr_trans_end.num_ped_ven
   LET lr_est_ender.num_seq_ped_ven    = mr_trans_end.num_seq_ped_ven
   LET lr_est_ender.ies_origem_entrada = ' '
   LET lr_est_ender.num_peca           = mr_trans_end.num_peca
   LET lr_est_ender.qtd_reserv_1       = mr_trans_end.qtd_reserv_1 
   LET lr_est_ender.qtd_reserv_2       = mr_trans_end.qtd_reserv_2 
   LET lr_est_ender.qtd_reserv_3       = mr_trans_end.qtd_reserv_3 
   LET lr_est_ender.num_reserv_1       = mr_trans_end.num_reserv_1 
   LET lr_est_ender.num_reserv_2       = mr_trans_end.num_reserv_2 
   LET lr_est_ender.num_reserv_3       = mr_trans_end.num_reserv_3 
   LET lr_est_ender.tex_reservado      = mr_trans_end.tex_reservado

   IF g_tipo_sgbd = 'MSV' THEN   
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
          VALUES(lr_est_ender.cod_empresa,
                 lr_est_ender.cod_item,
                 lr_est_ender.cod_local,
                 lr_est_ender.num_lote,
                 lr_est_ender.endereco,
                 lr_est_ender.num_volume,
                 lr_est_ender.cod_grade_1,
                 lr_est_ender.cod_grade_2,
                 lr_est_ender.cod_grade_3,
                 lr_est_ender.cod_grade_4,
                 lr_est_ender.cod_grade_5,
                 lr_est_ender.dat_hor_producao,
                 lr_est_ender.num_ped_ven,
                 lr_est_ender.num_seq_ped_ven,
                 lr_est_ender.ies_situa_qtd,
                 lr_est_ender.qtd_saldo,
                 lr_est_ender.ies_origem_entrada,
                 lr_est_ender.dat_hor_validade,
                 lr_est_ender.num_peca,
                 lr_est_ender.num_serie,
                 lr_est_ender.comprimento,
                 lr_est_ender.largura,
                 lr_est_ender.altura,
                 lr_est_ender.diametro,
                 lr_est_ender.dat_hor_reserv_1,
                 lr_est_ender.dat_hor_reserv_2,
                 lr_est_ender.dat_hor_reserv_3,
                 lr_est_ender.qtd_reserv_1,
                 lr_est_ender.qtd_reserv_2,
                 lr_est_ender.qtd_reserv_3,
                 lr_est_ender.num_reserv_1,
                 lr_est_ender.num_reserv_2,
                 lr_est_ender.num_reserv_3,
                 lr_est_ender.tex_reservado)
   ELSE
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
          VALUES(lr_est_ender.cod_empresa,
                 lr_est_ender.cod_item,
                 lr_est_ender.cod_local,
                 lr_est_ender.num_lote,
                 lr_est_ender.endereco,
                 lr_est_ender.num_volume,
                 lr_est_ender.cod_grade_1,
                 lr_est_ender.cod_grade_2,
                 lr_est_ender.cod_grade_3,
                 lr_est_ender.cod_grade_4,
                 lr_est_ender.cod_grade_5,
                 lr_est_ender.dat_hor_producao,
                 lr_est_ender.num_ped_ven,
                 lr_est_ender.num_seq_ped_ven,
                 lr_est_ender.ies_situa_qtd,
                 lr_est_ender.qtd_saldo,
                 lr_est_ender.num_transac,
                 lr_est_ender.ies_origem_entrada,
                 lr_est_ender.dat_hor_validade,
                 lr_est_ender.num_peca,
                 lr_est_ender.num_serie,
                 lr_est_ender.comprimento,
                 lr_est_ender.largura,
                 lr_est_ender.altura,
                 lr_est_ender.diametro,
                 lr_est_ender.dat_hor_reserv_1,
                 lr_est_ender.dat_hor_reserv_2,
                 lr_est_ender.dat_hor_reserv_3,
                 lr_est_ender.qtd_reserv_1,
                 lr_est_ender.qtd_reserv_2,
                 lr_est_ender.qtd_reserv_3,
                 lr_est_ender.num_reserv_1,
                 lr_est_ender.num_reserv_2,
                 lr_est_ender.num_reserv_3,
                 lr_est_ender.tex_reservado)
   
   END IF
                 
   IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET m_msg = 'Erro ',m_erro CLIPPED, ' inserindo dados na tabela estoque_lote_ender'  
     RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION func020_estorna_operacao()#
#----------------------------------#
   
   DEFINE l_ies_oper_final       LIKE ord_oper.ies_oper_final
      
   SELECT ies_oper_final
     INTO l_ies_oper_final 
     FROM ord_oper      
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_operac = m_cod_operac
      AND num_seq_operac = m_num_seq_operac

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab ord_oper'                      
      RETURN FALSE
   END IF
      
   UPDATE ord_oper
      SET qtd_boas  = qtd_boas - m_qtd_boas,  
          qtd_refugo = qtd_refugo - m_qtd_refugo,
          qtd_sucata = qtd_sucata - m_qtd_sucata
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_operac = m_cod_operac
      AND num_seq_operac = m_num_seq_operac

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' atualizadno dados na tab ord_oper'                      
      RETURN FALSE
   END IF
      
   IF l_ies_oper_final = 'S' OR m_tip_producao <> 'B' THEN
         
      UPDATE ordens
         SET qtd_boas = qtd_boas - m_qtd_boas,  
             qtd_refug = qtd_refug - m_qtd_refugo,
             qtd_sucata = qtd_sucata - m_qtd_sucata
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' atualizadno dados na tab ordens'                      
         RETURN FALSE
      END IF
      
   END IF
      
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func020_estorna_mestre()#
#--------------------------------#
   
   DEFINE l_ies_est_mestre    SMALLINT,
          l_qtd_produzida     LIKE man_item_produzido.qtd_produzida,
          l_qtd_convertida    LIKE man_item_produzido.qtd_convertida,
          l_seq_reg_item      LIKE man_item_produzido.seq_registro_item,
          l_qtd_prod_est      LIKE man_item_produzido.qtd_produzida,
          l_qtd_conv_est      LIKE man_item_produzido.qtd_convertida,
          l_tip_producao      LIKE man_item_produzido.tip_producao
          
   LET l_ies_est_mestre = TRUE

   DECLARE cq_est_mestre CURSOR FOR
    SELECT seq_registro_item, qtd_produzida, 
           qtd_convertida, tip_producao
      FROM man_item_produzido
     WHERE empresa = p_cod_empresa
       AND seq_reg_mestre = m_seq_reg_mestre
       AND tip_movto = 'N'
   
   FOREACH cq_est_mestre INTO 
      l_seq_reg_item, l_qtd_produzida, 
      l_qtd_convertida, l_tip_producao
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_item_produzido:1' 
         RETURN FALSE
      END IF

      SELECT SUM(qtd_produzida), SUM(qtd_convertida)
        INTO l_qtd_prod_est, l_qtd_conv_est
        FROM man_item_produzido
       WHERE empresa = p_cod_empresa
         AND seq_reg_mestre = m_seq_reg_mestre
         AND seq_reg_normal = l_seq_reg_item
      
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo dados da tab man_item_produzido:2' 
         RETURN FALSE
      END IF
    
      IF l_qtd_prod_est IS NULL THEN
         LET l_qtd_prod_est = 0
      END IF

      IF l_qtd_conv_est IS NULL THEN
         LET l_qtd_conv_est = 0
      END IF
      
      IF l_tip_producao = 'S' THEN
         IF l_qtd_conv_est < l_qtd_convertida THEN
            LET l_ies_est_mestre = FALSE
            EXIT FOREACH
         END IF
      ELSE
         IF l_qtd_prod_est < l_qtd_produzida THEN
            LET l_ies_est_mestre = FALSE
            EXIT FOREACH
         END IF
      END IF          

   END FOREACH
   
   IF NOT l_ies_est_mestre THEN
      RETURN TRUE
   END IF
   
   LET m_dat_proces = TODAY
   LET m_hor_operac = TIME
   
   UPDATE man_apo_mestre 
      SET sit_apontamento = 'C',
          tip_moviment = 'E',
          usuario_estorno = p_user,
          data_estorno = m_dat_proces,
          hor_estorno = m_hor_operac
    WHERE empresa = p_cod_empresa
      AND seq_reg_mestre = m_seq_reg_mestre

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro ',m_erro CLIPPED, ' estornando tabela man_apo_mestre' 
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

   