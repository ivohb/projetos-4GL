#-----------------------------------------------------------#
#-------Objetivo: transferência entre lote   ---------------#
#--------------------------parâmetros-----------------------#
# Um record compativel com mr_item abaixo                   #
#--------------------------retorno texto--------------------#
#True = Operação bem sucedida / False = Erro na operação    #
#-----------------------------------------------------------#
# no caso de Erro, uma mensagem ficará armazenada na variá- #
# global g_msg e poderá ser exibida pelo programa chamador  #
#-----------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,          
          g_msg                  CHAR(150)

   DEFINE p_user                 LIKE usuarios.cod_usuario

END GLOBALS

DEFINE mr_item           RECORD
       cod_empresa   LIKE item.cod_empresa,
       cod_item      LIKE item.cod_item,
       cod_local     LIKE item.cod_local_estoq,
       num_lote_orig LIKE estoque_lote.num_lote,
       num_lote_dest LIKE estoque_lote.num_lote,
       ies_situa_qtd LIKE estoque_lote.ies_situa_qtd,
       qtd_transf    LIKE estoque_lote.qtd_saldo,
       comprimento   LIKE estoque_lote_ender.comprimento,
       largura       LIKE estoque_lote_ender.largura,
       altura        LIKE estoque_lote_ender.altura,
       diametro      LIKE estoque_lote_ender.diametro,
       num_programa  CHAR(08),
       opcao         CHAR(01),
       cod_operacao  CHAR(04)
END RECORD

DEFINE m_ies_ctr_estoque CHAR(01),
       m_ies_ctr_lote    CHAR(01),
       m_erro            CHAR(10),
       m_transac_lote    INTEGER,
       m_transac_ender   INTEGER,
       m_qtd_movto       DECIMAL(10,3),
       m_cod_operacao    CHAR(05),
       m_tip_operacao    CHAR(01),
       m_del_lote        SMALLINT,
       m_num_transac     INTEGER

DEFINE m_estoque_trans       RECORD LIKE estoque_trans.*,
       l_estoque_lote_ender  RECORD LIKE estoque_lote_ender.*

#------------------------------------#
FUNCTION func013_transf_lote(lr_item)#
#------------------------------------#

   DEFINE lr_item      RECORD
         cod_empresa   LIKE item.cod_empresa,
         cod_item      LIKE item.cod_item,
         cod_local     LIKE item.cod_local_estoq,
         num_lote_orig LIKE estoque_lote.num_lote,
         num_lote_dest LIKE estoque_lote.num_lote,
         ies_situa_qtd LIKE estoque_lote.ies_situa_qtd,
         qtd_saldo     LIKE estoque_lote.qtd_saldo,
         comprimento   LIKE estoque_lote_ender.comprimento,
         largura       LIKE estoque_lote_ender.largura,
         altura        LIKE estoque_lote_ender.altura,
         diametro      LIKE estoque_lote_ender.diametro,
         num_programa  CHAR(08),
         opcao         CHAR(01),
         cod_operacao  CHAR(04)
   END RECORD
   
   LET g_msg = ''
   LET mr_item.* = lr_item.*
   LET m_del_lote = FALSE
   
   IF mr_item.cod_empresa IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - O código da empresa está nulo'
   END IF
   
   IF mr_item.cod_item IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - O código do item está nulo'
   END IF

   IF mr_item.cod_local IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - O código do local está nulo'
   END IF

   IF mr_item.ies_situa_qtd IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - A situação do estoq está nula'
   END IF

   IF g_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
      
   IF NOT func013_le_item() THEN
      RETURN FALSE
   END IF 
   
   IF m_ies_ctr_estoque = 'N' THEN
      LET g_msg = 'Item ',mr_item.cod_item CLIPPED,' não controla estoque.'
      RETURN FALSE
   END IF
   
   IF m_ies_ctr_lote = 'N' THEN
      LET g_msg = 'Item ',mr_item.cod_item CLIPPED,' não controla lote.'
      RETURN FALSE
   END IF

   IF mr_item.num_lote_orig  IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - O lote origem está nulo.'
   END IF

   IF mr_item.num_lote_dest  IS NULL THEN
      LET g_msg = g_msg CLIPPED, ' - O lote destino está nulo.'
   END IF

   IF mr_item.qtd_transf IS NULL OR mr_item.qtd_transf <=0 THEN
      LET g_msg = g_msg CLIPPED, ' - Quantidade a transferir inválida.'
   END IF

   IF g_msg IS NOT NULL THEN
      RETURN FALSE
   END IF
   
   #-valida lote origem-#
   IF NOT func013_checa_lote() THEN
      RETURN FALSE
   END IF 
   
   #-faz saída do lote origem-#
   IF NOT func013_baixa_lot() THEN
      RETURN FALSE
   END IF 

   LET m_qtd_movto =  mr_item.qtd_transf

   #-faz entrada do lote destino-#
   IF NOT func013_grava_lot() THEN
      RETURN FALSE
   END IF 

   LET m_cod_operacao = mr_item.cod_operacao

   #-insere movimento de estoque-#
   IF NOT func013_ins_transacao() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION func013_le_item()#
#-------------------------#

   SELECT ies_ctr_estoque,
          ies_ctr_lote
     INTO m_ies_ctr_estoque,
          m_ies_ctr_lote
     FROM item 
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA ITEM'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#----------------------------#
FUNCTION func013_checa_lote()#
#----------------------------#

   DEFINE l_qtd_saldo      DECIMAL(10,3),
          l_qtd_reservada  DECIMAL(10,3)

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada
     FROM estoque_loc_reser
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item    = mr_item.cod_item
      AND cod_local   = mr_item.cod_local
      AND num_lote = mr_item.num_lote_orig  
      AND qtd_reservada > 0
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ', m_erro CLIPPED, 
          ' LENDO TABELA ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF
      
   IF l_qtd_reservada IS NULL THEN
      LET l_qtd_reservada = 0
   END IF

   SELECT *
     INTO l_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item
      AND cod_local = mr_item.cod_local
      AND ies_situa_qtd = mr_item.ies_situa_qtd
      AND comprimento = mr_item.comprimento
      AND largura = mr_item.largura
      AND diametro = mr_item.diametro
      AND altura = mr_item.altura
      AND num_lote = mr_item.num_lote_orig 
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ', m_erro CLIPPED, 
          ' LENDO TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
    
   LET l_qtd_saldo = l_estoque_lote_ender.qtd_saldo - l_qtd_reservada

   IF l_qtd_saldo < mr_item.qtd_transf THEN
      LET g_msg = 'estoque_lote_ender - o saldo a transferir e maior que saldo do lote'
      RETURN FALSE
   ELSE
      IF l_estoque_lote_ender.qtd_saldo = mr_item.qtd_transf THEN
         LET m_del_lote = TRUE
      END IF
   END IF
   
   LET m_transac_ender = l_estoque_lote_ender.num_transac
   
   SELECT num_transac, qtd_saldo
     INTO m_transac_lote, l_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item
      AND cod_local = mr_item.cod_local
      AND ies_situa_qtd = mr_item.ies_situa_qtd
      AND num_lote = mr_item.num_lote_orig

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ', m_erro CLIPPED, 
          ' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   LET l_qtd_saldo = l_qtd_saldo - l_qtd_reservada
   
   IF l_qtd_saldo < mr_item.qtd_transf THEN
      LET g_msg = 'estoque_lote - o saldo a transferir e maior que saldo do lote'
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION func013_baixa_lot()#
#---------------------------#
   
   DEFINE l_insere     SMALLINT
   
   LET m_qtd_movto =  mr_item.qtd_transf * (-1)

   IF NOT func013_atu_estoque() THEN
      RETURN FALSE
   END IF

   IF m_del_lote THEN
      DELETE FROM estoque_lote_ender
       WHERE cod_empresa = mr_item.cod_empresa
         AND num_transac = m_transac_ender
      DELETE FROM estoque_lote
       WHERE cod_empresa = mr_item.cod_empresa
         AND num_transac = m_transac_lote
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION func013_grava_lot()#
#---------------------------#

   LET m_qtd_movto =  mr_item.qtd_transf
   
   SELECT *
     INTO l_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item
      AND cod_local = mr_item.cod_local
      AND ies_situa_qtd = mr_item.ies_situa_qtd
      AND comprimento = mr_item.comprimento
      AND largura = mr_item.largura
      AND diametro = mr_item.diametro
      AND altura = mr_item.altura
      AND num_lote = mr_item.num_lote_dest

   IF STATUS = 0 THEN
      LET m_transac_ender = l_estoque_lote_ender.num_transac
      IF NOT func013_atu_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT func013_ins_ender() THEN
            RETURN FALSE
          END IF
      ELSE
         LET m_erro = STATUS
         LET g_msg = 'ERRO ', m_erro CLIPPED, 
          ' LENDO TABELA ESTOQUE_LOTE_ENDER'  
         RETURN FALSE
      END IF
   END IF
   
   SELECT num_transac
     INTO m_transac_lote
     FROM estoque_lote
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item
      AND cod_local = mr_item.cod_local
      AND ies_situa_qtd = mr_item.ies_situa_qtd
      AND num_lote = mr_item.num_lote_dest

   IF STATUS = 0 THEN
      IF NOT func013_atu_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT func013_ins_lote() THEN
            RETURN FALSE
          END IF
      ELSE
         LET m_erro = STATUS
         LET g_msg = 'ERRO ', m_erro CLIPPED, 
          ' LENDO TABELA ESTOQUE_LOTE'  
         RETURN FALSE
      END IF
   END IF
   
   IF NOT func013_gra_estoque() THEN
      RETURN FALSE
   END IF

   LET m_cod_operacao = mr_item.cod_operacao
   LET m_tip_operacao = 'E'
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION func013_atu_estoque()#
#-----------------------------#

   IF NOT func013_atu_ender() THEN
      RETURN FALSE
   END IF

   IF NOT func013_atu_lote() THEN
      RETURN FALSE
   END IF

   IF NOT func013_gra_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION func013_atu_ender()#
#---------------------------#
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + m_qtd_movto
    WHERE cod_empresa = mr_item.cod_empresa
      AND num_transac = m_transac_ender

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE_LOTE_ENDER'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func013_atu_lote()#
#--------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + m_qtd_movto
    WHERE cod_empresa = mr_item.cod_empresa
      AND num_transac = m_transac_lote

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE_LOTE'
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------#   
FUNCTION func013_gra_estoque()#
#-----------------------------#

   DEFINE l_estoque      RECORD LIKE estoque.*
   
   SELECT * 
     INTO l_estoque.*
     FROM estoque
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' LENDO TABELA ESTOQUE'
      RETURN FALSE
   END IF

   CASE mr_item.ies_situa_qtd
      WHEN 'L'
         LET l_estoque.qtd_liberada = l_estoque.qtd_liberada + m_qtd_movto
      WHEN 'I'
         LET l_estoque.qtd_impedida = l_estoque.qtd_impedida + m_qtd_movto
      WHEN 'E'
         LET l_estoque.qtd_lib_excep = l_estoque.qtd_lib_excep + m_qtd_movto
      WHEN 'R'
         LET l_estoque.qtd_rejeitada = l_estoque.qtd_rejeitada + m_qtd_movto
   END CASE
   
   IF m_qtd_movto > 0 THEN
      LET l_estoque.dat_ult_entrada = TODAY
   ELSE
      LET l_estoque.dat_ult_saida = TODAY
   END IF
   
   UPDATE estoque
      SET qtd_liberada = l_estoque.qtd_liberada,
          qtd_lib_excep = l_estoque.qtd_lib_excep,
          qtd_rejeitada = l_estoque.qtd_rejeitada,
          qtd_impedida  = l_estoque.qtd_impedida,
          dat_ult_entrada = l_estoque.dat_ult_entrada,
          dat_ult_saida = l_estoque.dat_ult_saida
    WHERE cod_empresa = mr_item.cod_empresa
      AND cod_item = mr_item.cod_item
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION func013_ins_transacao()#
#-------------------------------#

   DEFINE l_ies_com_detalhe CHAR(01),
          l_num_conta       CHAR(20)

   INITIALIZE m_estoque_trans.* TO NULL      
                                                                                       
   SELECT ies_com_detalhe                                                                                     
     INTO l_ies_com_detalhe                                                                                   
     FROM estoque_operac                                                                                      
    WHERE cod_empresa  = mr_item.cod_empresa                                                                        
      AND cod_operacao = m_cod_operacao                                                                       
                                                                                                                 
   IF STATUS <> 0 THEN   
      LET m_erro =  STATUS                                                                                     
      LET g_msg = 'ERRO ',m_erro CLIPPED,
          ' LENDO TABELA ESTOQUE_OPERAC - OPER:',m_cod_operacao
      RETURN FALSE                                                                                             
   END IF                                                                                                     
                                                                                                                 
   IF l_ies_com_detalhe = 'S' THEN                                                                            
      IF m_tip_operacao = 'S' THEN                                                                              
         SELECT num_conta_debito                                                                           
           INTO l_num_conta                                                                                
           FROM estoque_operac_ct                                                                          
          WHERE cod_empresa  = mr_item.cod_empresa                                                               
            AND cod_operacao = m_cod_operacao                                                              
      ELSE                                                                                                    
         SELECT num_conta_credito                                                                             
           INTO l_num_conta                                                                                  
           FROM estoque_operac_ct                                                                             
          WHERE cod_empresa  = mr_item.cod_empresa                                                                  
            AND cod_operacao = m_cod_operacao                                                               
      END IF                                                                                                  
   ELSE                                                                                                       
      LET l_num_conta = NULL                                                                                  
   END IF                                                                                                     
                                                                                                                 
   IF STATUS <> 0 THEN                                                                                        
     LET m_erro =  STATUS                                                                                     
     LET g_msg = 'ERRO ',m_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC_CT - OPER:', m_cod_operacao
     RETURN FALSE                                                                                             
   END IF                                                                                                     

   LET m_estoque_trans.cod_empresa        = mr_item.cod_empresa
   LET m_estoque_trans.num_transac        = 0
   LET m_estoque_trans.cod_item           = mr_item.cod_item
   LET m_estoque_trans.dat_movto          = TODAY
   LET m_estoque_trans.dat_ref_moeda_fort = TODAY
   LET m_estoque_trans.cod_operacao       = m_cod_operacao
   LET m_estoque_trans.ies_tip_movto      = 'N'
   LET m_estoque_trans.qtd_movto          = m_qtd_movto
   LET m_estoque_trans.cus_unit_movto_p   = 0
   LET m_estoque_trans.cus_tot_movto_p    = 0
   LET m_estoque_trans.cus_unit_movto_f   = 0
   LET m_estoque_trans.cus_tot_movto_f    = 0
   LET m_estoque_trans.num_conta          = l_num_conta
   LET m_estoque_trans.num_secao_requis   = NULL

   LET m_estoque_trans.cod_local_est_orig = mr_item.cod_local
   LET m_estoque_trans.num_lote_orig = mr_item.num_lote_orig
   LET m_estoque_trans.ies_sit_est_orig = mr_item.ies_situa_qtd
   LET m_estoque_trans.cod_local_est_dest = mr_item.cod_local
   LET m_estoque_trans.num_lote_dest = mr_item.num_lote_dest
   LET m_estoque_trans.ies_sit_est_dest = mr_item.ies_situa_qtd
   
   LET m_estoque_trans.num_docum   = mr_item.num_lote_orig
   LET m_estoque_trans.nom_usuario = p_user
   LET m_estoque_trans.dat_proces  = TODAY
   LET m_estoque_trans.hor_operac  = TIME
   LET m_estoque_trans.num_prog    = mr_item.num_programa

   IF NOT func013_ins_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT func013_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT func013_ins_estoq_auditoria() THEN
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION func013_ins_estoq_trans()#
#---------------------------------#

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
          VALUES (m_estoque_trans.cod_empresa,
                  m_estoque_trans.cod_item,
                  m_estoque_trans.dat_movto,
                  m_estoque_trans.dat_ref_moeda_fort,
                  m_estoque_trans.cod_operacao,
                  m_estoque_trans.num_docum,
                  m_estoque_trans.num_seq,
                  m_estoque_trans.ies_tip_movto,
                  m_estoque_trans.qtd_movto,
                  m_estoque_trans.cus_unit_movto_p,
                  m_estoque_trans.cus_tot_movto_p,
                  m_estoque_trans.cus_unit_movto_f,
                  m_estoque_trans.cus_tot_movto_f,
                  m_estoque_trans.num_conta,
                  m_estoque_trans.num_secao_requis,
                  m_estoque_trans.cod_local_est_orig,
                  m_estoque_trans.cod_local_est_dest,
                  m_estoque_trans.num_lote_orig,
                  m_estoque_trans.num_lote_dest,
                  m_estoque_trans.ies_sit_est_orig,
                  m_estoque_trans.ies_sit_est_dest,
                  m_estoque_trans.cod_turno,
                  m_estoque_trans.nom_usuario,
                  m_estoque_trans.dat_proces,
                  m_estoque_trans.hor_operac,
                  m_estoque_trans.num_prog)   

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF

   LET m_num_transac = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION func013_ins_est_trans_end()#
#-----------------------------------#

   DEFINE l_estoque_trans_end   RECORD LIKE estoque_trans_end.*   
 
   LET l_estoque_trans_end.num_transac      = m_num_transac                        
   LET l_estoque_trans_end.endereco         = l_estoque_lote_ender.endereco               
   LET l_estoque_trans_end.cod_grade_1      = l_estoque_lote_ender.cod_grade_1            
   LET l_estoque_trans_end.cod_grade_2      = l_estoque_lote_ender.cod_grade_2            
   LET l_estoque_trans_end.cod_grade_3      = l_estoque_lote_ender.cod_grade_3            
   LET l_estoque_trans_end.cod_grade_4      = l_estoque_lote_ender.cod_grade_4            
   LET l_estoque_trans_end.cod_grade_5      = l_estoque_lote_ender.cod_grade_5            
   LET l_estoque_trans_end.num_ped_ven      = l_estoque_lote_ender.num_ped_ven            
   LET l_estoque_trans_end.num_seq_ped_ven  = l_estoque_lote_ender.num_seq_ped_ven        
   LET l_estoque_trans_end.dat_hor_producao = l_estoque_lote_ender.dat_hor_producao       
   LET l_estoque_trans_end.dat_hor_validade = l_estoque_lote_ender.dat_hor_validade       
   LET l_estoque_trans_end.num_peca         = l_estoque_lote_ender.num_peca               
   LET l_estoque_trans_end.num_serie        = l_estoque_lote_ender.num_serie              
   LET l_estoque_trans_end.comprimento      = l_estoque_lote_ender.comprimento            
   LET l_estoque_trans_end.largura          = l_estoque_lote_ender.largura                
   LET l_estoque_trans_end.altura           = l_estoque_lote_ender.altura                 
   LET l_estoque_trans_end.diametro         = l_estoque_lote_ender.diametro               
   LET l_estoque_trans_end.dat_hor_reserv_1 = l_estoque_lote_ender.dat_hor_reserv_1       
   LET l_estoque_trans_end.dat_hor_reserv_2 = l_estoque_lote_ender.dat_hor_reserv_2       
   LET l_estoque_trans_end.dat_hor_reserv_3 = l_estoque_lote_ender.dat_hor_reserv_3       
   LET l_estoque_trans_end.qtd_reserv_1     = l_estoque_lote_ender.qtd_reserv_1           
   LET l_estoque_trans_end.qtd_reserv_2     = l_estoque_lote_ender.qtd_reserv_2           
   LET l_estoque_trans_end.qtd_reserv_3     = l_estoque_lote_ender.qtd_reserv_3           
   LET l_estoque_trans_end.num_reserv_1     = l_estoque_lote_ender.num_reserv_1           
   LET l_estoque_trans_end.num_reserv_2     = l_estoque_lote_ender.num_reserv_2           
   LET l_estoque_trans_end.num_reserv_3     = l_estoque_lote_ender.num_reserv_3           
   LET l_estoque_trans_end.cod_empresa      = m_estoque_trans.cod_empresa                 
   LET l_estoque_trans_end.cod_item         = m_estoque_trans.cod_item                    
   LET l_estoque_trans_end.qtd_movto        = m_estoque_trans.qtd_movto                   
   LET l_estoque_trans_end.dat_movto        = m_estoque_trans.dat_movto                   
   LET l_estoque_trans_end.cod_operacao     = m_estoque_trans.cod_operacao                
   LET l_estoque_trans_end.ies_tip_movto    = m_estoque_trans.ies_tip_movto               
   LET l_estoque_trans_end.num_prog         = m_estoque_trans.num_prog                    
   LET l_estoque_trans_end.cus_unit_movto_p = m_estoque_trans.cus_unit_movto_p                                           
   LET l_estoque_trans_end.cus_unit_movto_f = m_estoque_trans.cus_unit_movto_f                                            
   LET l_estoque_trans_end.cus_tot_movto_p  = m_estoque_trans.cus_tot_movto_p                                           
   LET l_estoque_trans_end.cus_tot_movto_f  = m_estoque_trans.cus_tot_movto_f                                            
   LET l_estoque_trans_end.num_volume       = 0                                           
   LET l_estoque_trans_end.dat_hor_prod_ini = '1900-01-01 00:00:00'                       
   LET l_estoque_trans_end.dat_hor_prod_fim = '1900-01-01 00:00:00'                       
   LET l_estoque_trans_end.vlr_temperatura  = 0                                           
   LET l_estoque_trans_end.endereco_origem  = ' '                                         
   LET l_estoque_trans_end.tex_reservado    = ' '                                        
   
   INSERT INTO estoque_trans_end VALUES (l_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO NA TAB ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION func013_ins_estoq_auditoria()#
#-------------------------------------#
  
  INSERT INTO estoque_auditoria(
   cod_empresa,
   num_transac,
   nom_usuario,
   dat_hor_proces,
   num_programa)
  VALUES(m_estoque_trans.cod_empresa, 
      m_num_transac, 
      m_estoque_trans.nom_usuario, 
      m_estoque_trans.dat_proces, 
      m_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'ERRO ',m_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_AUDITORIA'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION func013_ins_ender()#
#---------------------------#
   
   LET l_estoque_lote_ender.cod_empresa        = mr_item.cod_empresa
	 LET l_estoque_lote_ender.cod_item           = mr_item.cod_item 
	 LET l_estoque_lote_ender.cod_local          = mr_item.cod_local
	 LET l_estoque_lote_ender.num_lote           = mr_item.num_lote_dest
	 LET l_estoque_lote_ender.ies_situa_qtd      = mr_item.ies_situa_qtd
	 LET l_estoque_lote_ender.qtd_saldo          = m_qtd_movto
   LET l_estoque_lote_ender.largura            = mr_item.largura
   LET l_estoque_lote_ender.altura             = mr_item.altura
   LET l_estoque_lote_ender.diametro           = mr_item.diametro
   LET l_estoque_lote_ender.comprimento        = mr_item.comprimento
   LET l_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET l_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET l_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET l_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET l_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET l_estoque_lote_ender.num_serie          = ' '
   LET l_estoque_lote_ender.endereco           = ' '
   LET l_estoque_lote_ender.num_volume         = '0'
   LET l_estoque_lote_ender.cod_grade_1        = ' '
   LET l_estoque_lote_ender.cod_grade_2        = ' '
   LET l_estoque_lote_ender.cod_grade_3        = ' '
   LET l_estoque_lote_ender.cod_grade_4        = ' '
   LET l_estoque_lote_ender.cod_grade_5        = ' '
   LET l_estoque_lote_ender.num_ped_ven        = 0
   LET l_estoque_lote_ender.num_seq_ped_ven    = 0
   LET l_estoque_lote_ender.ies_origem_entrada = ' '
   LET l_estoque_lote_ender.num_peca           = ' '
   LET l_estoque_lote_ender.qtd_reserv_1       = 0
   LET l_estoque_lote_ender.qtd_reserv_2       = 0
   LET l_estoque_lote_ender.qtd_reserv_3       = 0
   LET l_estoque_lote_ender.num_reserv_1       = 0
   LET l_estoque_lote_ender.num_reserv_2       = 0
   LET l_estoque_lote_ender.num_reserv_3       = 0
   LET l_estoque_lote_ender.tex_reservado      = ' '

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
          VALUES(l_estoque_lote_ender.cod_empresa,
                 l_estoque_lote_ender.cod_item,
                 l_estoque_lote_ender.cod_local,
                 l_estoque_lote_ender.num_lote,
                 l_estoque_lote_ender.endereco,
                 l_estoque_lote_ender.num_volume,
                 l_estoque_lote_ender.cod_grade_1,
                 l_estoque_lote_ender.cod_grade_2,
                 l_estoque_lote_ender.cod_grade_3,
                 l_estoque_lote_ender.cod_grade_4,
                 l_estoque_lote_ender.cod_grade_5,
                 l_estoque_lote_ender.dat_hor_producao,
                 l_estoque_lote_ender.num_ped_ven,
                 l_estoque_lote_ender.num_seq_ped_ven,
                 l_estoque_lote_ender.ies_situa_qtd,
                 l_estoque_lote_ender.qtd_saldo,
                 l_estoque_lote_ender.ies_origem_entrada,
                 l_estoque_lote_ender.dat_hor_validade,
                 l_estoque_lote_ender.num_peca,
                 l_estoque_lote_ender.num_serie,
                 l_estoque_lote_ender.comprimento,
                 l_estoque_lote_ender.largura,
                 l_estoque_lote_ender.altura,
                 l_estoque_lote_ender.diametro,
                 l_estoque_lote_ender.dat_hor_reserv_1,
                 l_estoque_lote_ender.dat_hor_reserv_2,
                 l_estoque_lote_ender.dat_hor_reserv_3,
                 l_estoque_lote_ender.qtd_reserv_1,
                 l_estoque_lote_ender.qtd_reserv_2,
                 l_estoque_lote_ender.qtd_reserv_3,
                 l_estoque_lote_ender.num_reserv_1,
                 l_estoque_lote_ender.num_reserv_2,
                 l_estoque_lote_ender.num_reserv_3,
                 l_estoque_lote_ender.tex_reservado)
              
   IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET g_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func013_ins_lote()#
#--------------------------#
   
   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(mr_item.cod_empresa,
                 mr_item.cod_item,
                 mr_item.cod_local,
                 mr_item.num_lote_dest,
                 mr_item.ies_situa_qtd,
                 m_qtd_movto)
                 
   IF STATUS <> 0 THEN
     LET m_erro = STATUS
     LET g_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------FIM-------------------#
