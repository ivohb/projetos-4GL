
#------------------------------------#
FUNCTION estoque_insere_movto(p_item)#
#------------------------------------#

#---parâmetros recebidos com visibilidade local

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
         ies_ctr_lote  CHAR(01)
  END RECORD

   LET p_msg = ''
      
   LET p_movto.* = p_item.*

   CASE p_movto.tip_operacao
      WHEN 'E' #entrada
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'E'
            IF NOT estoque_grava_entrada() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'S'
            IF NOT estoque_reverte_entrada() THEN
               RETURN FALSE
            END IF
         END IF
      WHEN 'S' #saida
         IF p_movto.ies_tip_movto = 'N' THEN
            LET p_ies_estoque = 'S'
            IF NOT estoque_grava_saida() THEN
               RETURN FALSE
            END IF
         ELSE
            LET p_ies_estoque = 'E'
            IF NOT estoque_reverte_saida() THEN
               RETURN FALSE
            END IF
         END IF

   END CASE

   IF NOT estoque_atu_estoque() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_atu_estoque()#
#-----------------------------#

   DEFINE p_qtd_liberada       DECIMAL(10,3),
          p_qtd_lib_excep      DECIMAL(10,3),
          p_qtd_rejeitada      DECIMAL(10,3),
          p_qtd_impedida       DECIMAL(10,3)

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_liberada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'L' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_liberada IS NULL THEN
      LET p_qtd_liberada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_lib_excep
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'E' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO LIBERADO EXCEPCIONAL DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_lib_excep IS NULL THEN
      LET p_qtd_lib_excep = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_rejeitada
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'R' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO REJEITADO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_rejeitada IS NULL THEN
      LET p_qtd_rejeitada = 0
   END IF

   SELECT SUM(qtd_saldo) 
     INTO p_qtd_impedida
     FROM estoque_lote_ender
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
      AND ies_situa_qtd = 'I' 
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, 
                  ' SOMANDO SALDO IMPEDIDO DA TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF
   
   IF p_qtd_impedida IS NULL THEN
      LET p_qtd_impedida = 0
   END IF
   
   UPDATE estoque
      SET qtd_liberada = p_qtd_liberada,
          qtd_lib_excep = p_qtd_lib_excep,
          qtd_rejeitada = p_qtd_rejeitada,
          qtd_impedida  = p_qtd_impedida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item
     
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED, ' ATUALIZANDO SALDO DA TABELA ESTOQUE'  
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_grava_entrada()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION estoque_gra_lote()#
#--------------------------#

   CALL estoque_le_lote()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         IF NOT estoque_atu_lote(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION estoque_le_lote()#
#-------------------------#
      
   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF   

END FUNCTION

#--------------------------#
FUNCTION estoque_ins_lote()#
#--------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_movto.cod_empresa,
                 p_movto.cod_item,
                 p_movto.cod_local,
                 p_movto.num_lote,
                 p_movto.ies_situa,
                 p_movto.qtd_movto)
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------------#
FUNCTION estoque_atu_lote(p_qtd_movto)#
#-------------------------------------#
   
   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)

   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)
      
      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-------------------------------#
FUNCTION estoque_gra_lot_ender()#
#-------------------------------#
      
   CALL estoque_le_lot_ender()
      
   IF STATUS = 100 THEN
      IF NOT estoque_ins_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 0 THEN
         LET p_num_transac = p_estoque_lote_ender.num_transac
         IF NOT estoque_atu_lote_ender(p_movto.qtd_movto) THEN
            RETURN FALSE
         END IF
      ELSE
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER'  
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION estoque_le_lot_ender()#
#------------------------------#

   IF p_movto.ies_ctr_lote = 'S' THEN
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND num_lote = p_movto.num_lote 
   ELSE
      SELECT *
        INTO p_estoque_lote_ender.*
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND cod_item = p_movto.cod_item
         AND cod_local = p_movto.cod_local
         AND ies_situa_qtd = p_movto.ies_situa
         AND comprimento = p_movto.comprimento
         AND largura = p_movto.largura
         AND altura = p_movto.altura
         AND diametro = p_movto.diametro
         AND (num_lote IS NULL OR num_lote = ' ')
   END IF
   
END FUNCTION

#--------------------------------#
FUNCTION estoque_ins_lote_ender()#
#--------------------------------#

   CALL estoque_carrega_campos() 

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
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_carrega_campos()
#-------------------------------#
   
   INITIALIZE p_estoque_lote_ender TO NULL
   
   LET p_estoque_lote_ender.cod_empresa        = p_movto.cod_empresa
	 LET p_estoque_lote_ender.cod_item           = p_movto.cod_item 
	 LET p_estoque_lote_ender.cod_local          = p_movto.cod_local
	 LET p_estoque_lote_ender.num_lote           = p_movto.num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_movto.ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_movto.qtd_movto
   LET p_estoque_lote_ender.largura            = p_movto.largura
   LET p_estoque_lote_ender.altura             = p_movto.altura
   LET p_estoque_lote_ender.diametro           = p_movto.diametro
   LET p_estoque_lote_ender.comprimento        = p_movto.comprimento
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION
         
#-------------------------------------------#
FUNCTION estoque_atu_lote_ender(p_qtd_movto)#
#-------------------------------------------#

   DEFINE p_qtd_movto DECIMAL(10,3),
          p_qtd_saldo DECIMAL(10,3),
          p_saldo     DECIMAL(10,3)
   
   IF p_qtd_movto < 0 THEN
      SELECT qtd_saldo
        INTO p_qtd_saldo
        FROM estoque_lote_ender
       WHERE cod_empresa = p_movto.cod_empresa
         AND num_transac = p_num_transac

      IF STATUS <> 0 THEN
        LET p_erro = STATUS
        LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO ESTOQUE_LOTE_ENDER.'  
        RETURN FALSE
      END IF
      
      LET p_saldo = p_qtd_movto * (-1)

      IF p_qtd_saldo < p_saldo THEN
         LET p_msg = 'TABELA ESTOQUE_LOTE_ENDER SEM SALDO PARA BAIXAR'  
         RETURN FALSE
      END IF
   END IF
   
   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_num_transac
                 
   IF STATUS <> 0 THEN
     LET p_erro = STATUS
     LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO ESTOQUE_LOTE_ENDER.'  
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
         
#-----------------------------#         
FUNCTION estoque_gra_estoque()#
#-----------------------------#
   
   DEFINE p_qtd_estoq      DECIMAL(10,3)
   DEFINE p_estoque record LIKE estoque.*
   
   SELECT *
     INTO p_estoque.*
     FROM estoque
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS = 100 THEN
      INITIALIZE p_estoque.* TO NULL
      LET p_estoque.cod_empresa = p_movto.cod_empresa
      LET p_estoque.cod_item = p_movto.cod_item
      LET p_estoque.qtd_liberada  = 0
      LET p_estoque.qtd_impedida  = 0
      LET p_estoque.qtd_rejeitada = 0
      LET p_estoque.qtd_lib_excep = 0
      LET p_estoque.qtd_disp_venda = 0
      LET p_estoque.qtd_reservada = 0
      
      INSERT INTO estoque
       VALUES(p_estoque.*)
      
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO ESTOQUE.'  
         RETURN FALSE
      END IF   
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ',p_erro CLIPPED, ' LENDO TABELA ESTOQUE.'  
         RETURN FALSE
      END IF   
   END IF
   
   IF p_ies_estoque = 'S' THEN
      LET p_estoque.dat_ult_saida = p_movto.dat_movto
   ELSE
      LET p_estoque.dat_ult_entrada = p_movto.dat_movto
   END IF
         
   UPDATE estoque
      SET dat_ult_entrada = p_estoque.dat_ult_entrada,
          dat_ult_saida   = p_estoque.dat_ult_saida
    WHERE cod_empresa = p_movto.cod_empresa
      AND cod_item = p_movto.cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' ATUALIZANDO TABELA ESTOQUE.'  
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_gra_estoq_trans()#
#---------------------------------#

   DEFINE p_ies_com_detalhe CHAR(01),
          p_num_conta       CHAR(20)

   INITIALIZE p_estoque_trans.* TO NULL      
                                                                                       
   SELECT ies_com_detalhe                                                                                     
     INTO p_ies_com_detalhe                                                                                   
     FROM estoque_operac                                                                                      
    WHERE cod_empresa  = p_movto.cod_empresa                                                                        
      AND cod_operacao = p_movto.cod_operacao                                                                       
                                                                                                                 
   IF STATUS <> 0 THEN   
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC - OPER:',p_movto.cod_operacao
      RETURN FALSE                                                                                             
   END IF                                                                                                     
                                                                                                                 
   IF p_ies_com_detalhe = 'S' THEN                                                                            
      IF p_movto.tip_operacao = 'S' THEN        #operação de saida                                                                        
         SELECT num_conta_debito                                                                           
           INTO p_num_conta                                                                                
           FROM estoque_operac_ct                                                                          
          WHERE cod_empresa  = p_movto.cod_empresa                                                               
            AND cod_operacao = p_movto.cod_operacao                                                              
      ELSE                                                                                                    
         SELECT num_conta_credito                                                                             
           INTO p_num_conta                                                                                  
           FROM estoque_operac_ct                                                                             
          WHERE cod_empresa  = p_movto.cod_empresa                                                                  
            AND cod_operacao = p_movto.cod_operacao                                                                 
      END IF                                                                                                  
   ELSE                                                                                                       
      LET p_num_conta = NULL                                                                                  
   END IF                                                                                                     
                                                                                                                 
   IF STATUS <> 0 THEN                                                                                        
     LET p_erro =  STATUS                                                                                     
     LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_OPERAC_CT - OPER:', p_movto.cod_operacao
     RETURN FALSE                                                                                             
   END IF                                                                                                     

   LET p_estoque_trans.cod_empresa        = p_movto.cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_movto.cod_item
   LET p_estoque_trans.dat_movto          = p_movto.dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_movto.dat_movto
   LET p_estoque_trans.cod_operacao       = p_movto.cod_operacao
   LET p_estoque_trans.num_docum          = p_movto.num_docum
   LET p_estoque_trans.num_seq            = p_movto.num_seq
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto
   LET p_estoque_trans.qtd_movto          = p_movto.qtd_movto
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL

   IF p_movto.tip_operacao = 'S' THEN      #se for uma operação de saída
      LET p_estoque_trans.cod_local_est_orig = p_movto.cod_local
      LET p_estoque_trans.num_lote_orig = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_orig = p_movto.ies_situa
   ELSE
      LET p_estoque_trans.cod_local_est_dest = p_movto.cod_local
      LET p_estoque_trans.num_lote_dest = p_movto.num_lote
      LET p_estoque_trans.ies_sit_est_dest = p_movto.ies_situa
   END IF
   
   LET p_estoque_trans.cod_turno   = p_movto.cod_turno
   LET p_estoque_trans.nom_usuario = p_movto.usuario
   LET p_estoque_trans.dat_proces  = p_movto.dat_proces
   LET p_estoque_trans.hor_operac  = p_movto.hor_operac
   LET p_estoque_trans.num_prog    = p_movto.num_prog

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION estoque_ins_estoq_trans()#
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
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS'  
      RETURN FALSE
   END IF

   LET p_num_trans_atual = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION estoque_rev_estoq_trans()#
#---------------------------------#
    
   SELECT * 
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro =  STATUS                                                                                     
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_TRANS'
      RETURN FALSE
   END IF

   LET p_estoque_trans.dat_proces         = p_movto.dat_proces
   LET p_estoque_trans.hor_operac         = p_movto.hor_operac
   LET p_estoque_trans.ies_tip_movto      = p_movto.ies_tip_movto

   IF NOT estoque_ins_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_ins_estoque_trans_rev() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION estoque_gra_est_trans_end()#
#-----------------------------------#

 #---para chamar essa rotina é necessário ter lido a estoque_lote_ender previamente---#
   INITIALIZE p_estoque_trans_end.*  TO NULL
 
   LET p_estoque_trans_end.num_transac      = p_num_trans_atual                        
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
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao                
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto               
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog                    
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p                                           
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f                                            
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p                                           
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f                                            
   LET p_estoque_trans_end.num_volume       = 0                                           
   LET p_estoque_trans_end.dat_hor_prod_ini = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.dat_hor_prod_fim = '1900-01-01 00:00:00'                       
   LET p_estoque_trans_end.vlr_temperatura  = 0                                           
   LET p_estoque_trans_end.endereco_origem  = ' '                                         
   LET p_estoque_trans_end.tex_reservado    = ' '                                        
   
   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION estoque_ins_est_trans_end()#
#-----------------------------------#
      
   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO NA TAB ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION estoque_rev_trans_end()#
#-------------------------------#

   SELECT * 
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_movto.cod_empresa
      AND num_transac = p_movto.trans_origem

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_TRANS_END'  
      RETURN FALSE
   END IF

   LET p_estoque_trans_end.num_transac = p_num_trans_atual
   LET p_estoque_trans_end.ies_tip_movto = p_movto.ies_tip_movto    

   IF NOT estoque_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION estoque_gra_estoq_auditoria()#
#-------------------------------------#
  
  INSERT INTO estoque_auditoria(
   cod_empresa,
   num_transac,
   nom_usuario,
   dat_hor_proces,
   num_programa)
  VALUES(p_movto.cod_empresa, 
      p_num_trans_atual, 
      p_movto.usuario, 
      p_movto.dat_proces, 
      p_movto.num_prog)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO MOVTO NORMAL DA ESTOQUE_AUDITORIA'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#---------------------------------#
FUNCTION estoque_reverte_entrada()#
#---------------------------------#

   CALL estoque_le_lote()

   IF STATUS = 0 THEN
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION estoque_ins_estoque_trans_rev()#
#---------------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_estoque_trans.num_transac,
           p_num_trans_atual)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED, ' INSERINDO TABELA ESTOQUE_TRANS_REV'  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION estoque_grava_saida()#
#-----------------------------#
   
   DEFINE p_qtd_saldo DECIMAL(10,3)
   
   CALL estoque_le_lote()

   IF STATUS = 0 THEN               
      IF NOT estoque_atu_lote(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF
   
   CALL estoque_le_lot_ender()

   IF STATUS = 0 THEN
      LET p_num_transac = p_estoque_lote_ender.num_transac
      IF NOT estoque_atu_lote_ender(-p_movto.qtd_movto) THEN
         RETURN FALSE
      END IF
   ELSE
      LET p_erro = STATUS
      LET p_msg = 'ERRO ',p_erro CLIPPED,' LENDO TABELA ESTOQUE_LOTE'  
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION estoque_reverte_saida()#
#-------------------------------#

   IF NOT estoque_gra_lote() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_lot_ender() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoque() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_estoq_trans() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_rev_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT estoque_gra_estoq_auditoria() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

