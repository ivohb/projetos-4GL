
#-------------------------------------------------#
#Objetivo: Ordens de produção           ----------#
#-------------------------------------------------#

DATABASE logix
    
DEFINE m_cod_empresa         VARCHAR(02),
       m_num_ordem           INTEGER,
       m_msg                 VARCHAR(120),
       m_erro                VARCHAR(800),
       m_op_gerada           INTEGER,
       m_num_neces           INTEGER,
       m_dat_liberac         DATE,
       m_dat_abertura        DATE,
       m_ies_tip_item        CHAR(01),
       m_cod_local_baixa     CHAR(10)
       
DEFINE mr_ordem              RECORD          
       cod_empresa           VARCHAR(02),    
       cod_item              VARCHAR(15),    
       cod_item_pai          VARCHAR(15),
       qtd_planej            DECIMAL(10,3),  
       dat_entrega           DATE,           
       num_docum             VARCHAR(10),    
       ies_situa             VARCHAR(01),    
       ies_transacao         VARCHAR(01),
       num_programa          VARCHAR(08)
END RECORD

DEFINE mr_iteman             RECORD LIKE item_man.*,
       mr_ordens             RECORD LIKE ordens.*

DEFINE m_cod_local_estoq     LIKE item.cod_local_estoq,
       m_qtd_dias_horizon    LIKE horizonte.qtd_dias_horizon,
       m_cod_cent_trab       LIKE ord_compon.cod_cent_trab       


#----------------------------------------#
#Exclui a ordem de produção enviada      #
#como parâmetro--------------------------#
#---------Retorno------------------------#
#TRUE (sucesso) FALSE (se ocorrer erro)  #
#----------------------------------------#
 FUNCTION func025_exclui_op(lr_parametro)#
#----------------------------------------#

   DEFINE lr_parametro     RECORD 
          cod_empresa     VARCHAR(02),
          num_ordem       INTEGER,
          ies_transacao   CHAR(01)
   END RECORD
   
   DEFINE l_ies_situa   CHAR(01),
          l_status      SMALLINT
   
   LET m_cod_empresa = lr_parametro.cod_empresa
   LET m_num_ordem  = lr_parametro.num_ordem
   
   SELECT ies_situa INTO l_ies_situa
     FROM ordens
    WHERE cod_empresa = m_cod_empresa                                               
      AND num_ordem   = m_num_ordem                                                 
     
   IF STATUS <> 0 THEN                                                       
      CALL log003_err_sql("SELECT","ORDENS")                             
      RETURN FALSE                                                                  
   END IF                                                                            
   
   IF l_ies_situa > '3' THEN
      LET m_msg = 'Status atual da OP ',m_num_ordem,'\n', ' não permite exclusão.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN FALSE
   END IF
   
   IF lr_parametro.ies_transacao = 'S' THEN
      CALL LOG_transaction_begin()
   END IF
   
   LET l_status = func025_del_ordem()
   
   IF lr_parametro.ies_transacao = 'S' THEN
      IF l_status THEN
         CALL LOG_transaction_commit()
      ELSE
         CALL LOG_transaction_rollback()
      END IF
   END IF
   
   RETURN l_status

END FUNCTION   

#---------------------------#
FUNCTION func025_del_ordem()#
#---------------------------#

   DELETE FROM ordens_complement                                            
    WHERE cod_empresa = m_cod_empresa                                               
      AND num_ordem   = m_num_ordem                                                 
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                       
      CALL log003_err_sql("DELETE","ORDENS_COMPLEMENT")                             
      RETURN FALSE                                                                  
   END IF                                                                            
                                                                                                                                                          
   DELETE FROM neces_complement                                                   
     WHERE cod_empresa = m_cod_empresa AND num_neces IN                             
       (SELECT num_neces FROM necessidades                                           
         WHERE cod_empresa = m_cod_empresa                                           
           AND num_ordem   = m_num_ordem)                                            
                                                                                     
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","neces_complement")                                
      RETURN FALSE                                                                    
   END IF                                                                                                                                                                 
                                                                                     
    DELETE FROM necessidades                                                         
     WHERE cod_empresa = m_cod_empresa                                               
       AND num_ordem   = m_num_ordem                                                 
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                        
     CALL log003_err_sql("DELETE","NECESSIDADES")                                    
     RETURN FALSE                                                                    
   END IF                                                                            
                                                                                                                                                                 
   DELETE FROM  man_recurso_operacao_ordem                                           
    WHERE empresa = m_cod_empresa                                                    
      AND seq_processo IN                                                            
      (SELECT seq_processo FROM ord_oper                                             
        WHERE cod_empresa = m_cod_empresa                                            
          AND num_ordem   = m_num_ordem)                                             
                                                                             
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","man_recurso_operacao_ordem")                      
      RETURN FALSE                                                                    
   END IF                                                                            
                                                                                     
   DELETE FROM ord_oper                                                             
     WHERE cod_empresa = m_cod_empresa                                               
       AND num_ordem   = m_num_ordem                                                 
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","ORD_OPER")                                        
      RETURN FALSE                                                                    
   END IF                                                                            
                                                                             
    DELETE FROM ord_oper_txt                                                         
     WHERE cod_empresa = m_cod_empresa                                               
       AND num_ordem   = m_num_ordem                                                 
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","ord_oper_txt")                                    
      RETURN FALSE                                                                    
   END IF                                                                            
                                                                             
   DELETE FROM man_op_componente_operacao                                           
     WHERE empresa = m_cod_empresa                                                   
       AND ordem_producao = m_num_ordem                                              
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","man_op_componente_operacao")                      
      RETURN FALSE                                                                    
   END IF                                                                            
                                                                                     
   DELETE FROM man_oper_compl                                                       
     WHERE empresa        = m_cod_empresa                                        
       AND ordem_producao = m_num_ordem                                          

   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","MAN_OPER_COMPL")                                 
      RETURN FALSE                                                                   
   END IF                                                                            
                                                                             
   DELETE FROM ord_compon                                                           
     WHERE cod_empresa = m_cod_empresa                                               
       AND num_ordem   = m_num_ordem                                                 
                                                                             
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","ORD_COMPON")                                      
      RETURN FALSE                                                                    
   END IF                                                                            
                                                                             
   DELETE FROM ordens                                                              
    WHERE cod_empresa = m_cod_empresa                                         
      AND num_ordem   = m_num_ordem                                           
                                                                                                                                                                  
   IF STATUS <> 0 THEN                                                        
      CALL log003_err_sql("DELETE","ORDENS")                                         
      RETURN FALSE                                                                   
   END IF                                                                            
                                                                             
   RETURN TRUE

END FUNCTION

#----------------------------------------#
#Inclui uma ordem de produção, com base  #
#nos parâmetros enviados                 #
#como parâmetro--------------------------#
#---------Retorno------------------------#
#número da OP (sucesso) ou Zero (se ocor-#
#rer ALGUM erro no processamento)        #
#----------------------------------------#
 FUNCTION func025_inclui_op(lr_parametro)#
#----------------------------------------#

   DEFINE lr_parametro  RECORD
          cod_empresa   VARCHAR(02),
          cod_item      VARCHAR(15),
          cod_item_pai  VARCHAR(15),
          qtd_planej    DECIMAL(10,3),
          dat_entrega   DATE,
          num_docum     VARCHAR(10),
          ies_situa     VARCHAR(01),
          ies_transacao VARCHAR(01),
          num_programa  VARCHAR(08)
   END RECORD
   
   DEFINE l_retorno     INTEGER,
          l_status      SMALLINT
   
   LET mr_ordem.* = lr_parametro.*
   
   LET l_retorno = 0
   LET m_erro = NULL
   
   IF NOT func025_checa_param() THEN
      RETURN l_retorno
   END IF
   
   IF m_erro IS NOT NULL THEN
      CALL log0030_mensagem(m_erro,'info')
      RETURN l_retorno
   END IF
   
   IF mr_ordem.ies_transacao = 'S' THEN
      CALL LOG_transaction_begin()
   END IF
   
   LET l_status = func025_gera_ordem()
   
   IF mr_ordem.ies_transacao = 'S' THEN
      IF l_status THEN
         CALL LOG_transaction_commit()
      ELSE
         CALL LOG_transaction_rollback()
      END IF
   END IF
   
   IF l_status THEN
      LET l_retorno = m_op_gerada
   END IF
   
   RETURN l_retorno

END FUNCTION   
      
#-----------------------------#
FUNCTION func025_checa_param()#
#-----------------------------#
   
   IF mr_ordem.cod_empresa IS NULL THEN
      LET m_erro = m_erro CLIPPED, '- Empresa inválida \n'
   ELSE
      IF NOT func025_valid_empresa() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_ordem.cod_item IS NULL THEN
      LET m_erro = m_erro CLIPPED, '- Item inválido \n'
   ELSE
      IF NOT func025_valid_item() THEN
         RETURN FALSE
      END IF
   END IF

   IF mr_ordem.qtd_planej IS NULL OR mr_ordem.qtd_planej = 0 THEN
      LET m_erro = m_erro CLIPPED, '- Qtd planejada inválida \n'
   END IF
   
   IF mr_ordem.dat_entrega IS NULL OR mr_ordem.dat_entrega < TODAY THEN
      LET m_erro = m_erro CLIPPED, '- Data de entrega inválida \n'
   END IF

   IF mr_ordem.ies_situa MATCHES '[123]' THEN
   ELSE
      LET m_erro = m_erro CLIPPED, '- Status da OP inválido \n'
   END IF

   IF mr_ordem.num_programa IS NULL THEN
      LET mr_ordem.num_programa = 'FUNC025'
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION func025_valid_empresa()#
#-------------------------------# 

   SELECT den_empresa
    FROM empresa
    WHERE cod_empresa = mr_ordem.cod_empresa
   
   IF STATUS = 100 THEN
      LET m_erro = m_erro CLIPPED, '- Empresa não existe \n'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','empresa')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION func025_valid_item()#
#----------------------------# 

   SELECT cod_local_estoq
     INTO m_cod_local_estoq
     FROM item
    WHERE cod_empresa = mr_ordem.cod_empresa
      AND cod_item    = mr_ordem.cod_item
      AND ies_situacao = 'A'
   
   IF STATUS = 100 THEN
      LET m_erro = m_erro CLIPPED, '- Item não existe ou não está ativo \n'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item:local')
         RETURN FALSE
      END IF
   END IF

   IF m_cod_local_estoq IS NULL THEN
      LET m_cod_local_estoq = ' ' 
   END IF
   
   SELECT *
     INTO mr_iteman.*
     FROM item_man
    WHERE cod_empresa = mr_ordem.cod_empresa
      AND cod_item = mr_ordem.cod_item

   IF STATUS = 100 THEN
      LET m_erro = m_erro CLIPPED, '- Item não é de manufatura \n'
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_man')
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION func025_gera_ordem()#
#----------------------------#

   IF NOT func025_ins_ordem() THEN
      RETURN FALSE
   END IF

   IF NOT func025_ins_necessidades() THEN
      RETURN FALSE
   END IF

   IF NOT func025_ins_roteiro() THEN
      RETURN FALSE
   END IF  

   RETURN TRUE

END FUNCTION   

#---------------------------#
FUNCTION func025_ins_ordem()#
#---------------------------#

   DEFINE lr_op_compl RECORD LIKE ordens_complement.*

   #IF NOT func025_le_horizonte() THEN
   #   RETURN FALSE
   #END IF

   IF NOT func025_le_prox_num_op() THEN
      RETURN FALSE
   END IF
         
   LET m_dat_liberac = mr_ordem.dat_entrega  # mr_ordem.dat_entrega - mr_iteman.tmp_ressup
   LET m_dat_abertura = mr_ordem.dat_entrega # m_dat_liberac - m_qtd_dias_horizon
      
   INITIALIZE mr_ordens TO NULL

   LET mr_ordens.cod_empresa        = mr_ordem.cod_empresa
   LET mr_ordens.num_ordem          = m_op_gerada
   LET mr_ordens.num_neces          = 0
   LET mr_ordens.num_versao         = 0
   LET mr_ordens.cod_item           = mr_ordem.cod_item
   LET mr_ordens.cod_item_pai       = mr_ordem.cod_item_pai
   LET mr_ordens.dat_entrega        = mr_ordem.dat_entrega
   LET mr_ordens.dat_liberac        = m_dat_liberac
   LET mr_ordens.dat_abert          = m_dat_abertura 
   LET mr_ordens.qtd_planej         = mr_ordem.qtd_planej
   LET mr_ordens.pct_refug          = 0
   LET mr_ordens.qtd_boas           = 0
   LET mr_ordens.qtd_refug          = 0
   LET mr_ordens.qtd_sucata         = 0
   LET mr_ordens.cod_local_prod     = mr_iteman.cod_local_prod
   LET mr_ordens.cod_local_estoq    = m_cod_local_estoq
   LET mr_ordens.num_docum          = mr_ordem.num_docum
   LET mr_ordens.ies_lista_ordem    = mr_iteman.ies_lista_ordem
   LET mr_ordens.ies_lista_roteiro  = mr_iteman.ies_lista_roteiro
   LET mr_ordens.ies_origem         = '1'
   LET mr_ordens.ies_situa          = mr_ordem.ies_situa
   LET mr_ordens.ies_abert_liber    = mr_iteman.ies_abert_liber
   LET mr_ordens.ies_baixa_comp     = mr_iteman.ies_baixa_comp
   LET mr_ordens.ies_apontamento    = mr_iteman.ies_apontamento
   LET mr_ordens.dat_atualiz        = TODAY
   LET mr_ordens.num_lote           = NULL
   LET mr_ordens.cod_roteiro        = mr_iteman.cod_roteiro
   LET mr_ordens.num_altern_roteiro = mr_iteman.num_altern_roteiro

   INSERT INTO ordens VALUES (mr_ordens.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','Ordens')
      RETURN FALSE
   END IF

   IF mr_ordens.ies_baixa_comp  = "1" THEN                 
      LET m_cod_local_baixa  = mr_ordens.cod_local_prod    
   ELSE                                                    
      LET m_cod_local_baixa  = mr_ordens.cod_local_estoq   
   END IF                                                                                                                   

   INITIALIZE lr_op_compl  TO NULL

   LET lr_op_compl.cod_empresa    = mr_ordens.cod_empresa
   LET lr_op_compl.num_ordem      = mr_ordens.num_ordem
   LET lr_op_compl.cod_grade_1    = " "
   LET lr_op_compl.cod_grade_2    = " "
   LET lr_op_compl.cod_grade_3    = " "
   LET lr_op_compl.cod_grade_4    = " "
   LET lr_op_compl.cod_grade_5    = " "
   LET lr_op_compl.num_lote       = mr_ordens.num_lote
   LET lr_op_compl.ies_tipo       = "N"
   LET lr_op_compl.num_prioridade = 9999
   #LET lr_op_compl.ordem_producao_pai = NULL 

   INSERT INTO ordens_complement VALUES (lr_op_compl.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','ordens_complement')
      RETURN  FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION func025_le_horizonte()#
#------------------------------#

   SELECT qtd_dias_horizon
     INTO m_qtd_dias_horizon
     FROM horizonte
    WHERE cod_empresa = mr_ordem.cod_empresa
      AND cod_horizon = mr_iteman.cod_horizon

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','horizonte')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 FUNCTION func025_le_prox_num_op()#
#---------------------------------#
   
   DEFINE l_max_op       INTEGER
   
   SELECT prx_num_ordem
    INTO m_op_gerada
    FROM par_mrp
   WHERE cod_empresa = mr_ordem.cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_mrp:prx_num_ordem')
      RETURN FALSE
   END IF

   IF m_op_gerada IS NULL THEN
      LET m_op_gerada = 0
   END IF

   SELECT MAX(num_ordem) INTO l_max_op
     FROM ordens 
    WHERE cod_empresa = mr_ordem.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordens:MAX(num_ordem)')
      RETURN FALSE
   END IF
    
   IF l_max_op IS NULL THEN
      LET l_max_op = 0
   END IF
   
   IF m_op_gerada <= l_max_op THEN
      LET m_op_gerada = l_max_op + 1
   END IF

   UPDATE par_mrp
      SET prx_num_ordem = m_op_gerada + 1
    WHERE cod_empresa   = mr_ordem.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','par_mrp:prx_num_ordem')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION func025_le_prox_num_neces()#
#------------------------------------#
   
   DEFINE l_max_neces       INTEGER
   
   SELECT prx_num_neces
    INTO m_num_neces
    FROM par_mrp
   WHERE cod_empresa = mr_ordem.cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_mrp:prx_num_neces')
      RETURN FALSE
   END IF

   IF m_num_neces IS NULL THEN
      LET m_num_neces = 0
   END IF

   SELECT MAX(num_neces) INTO l_max_neces
     FROM necessidades 
    WHERE cod_empresa = mr_ordem.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','necessidades:MAX(num_neces)')
      RETURN FALSE
   END IF
    
   IF l_max_neces IS NULL THEN
      LET l_max_neces = 0
   END IF
   
   IF m_num_neces <= l_max_neces THEN
      LET m_num_neces = l_max_neces + 1
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION func025_ins_necessidades()#
#----------------------------------#

   DEFINE lr_necessidades    RECORD LIKE necessidades.*

   DEFINE l_cod_item_compon LIKE estrutura.cod_item_compon, 
          l_qtd_necessaria  LIKE estrutura.qtd_necessaria,  
          l_pct_refug       LIKE estrutura.pct_refug,
          l_tem_strut       SMALLINT,
          l_num_sequen      INTEGER          

   IF NOT func025_le_prox_num_neces() THEN
      RETURN FALSE
   END IF
   
   INITIALIZE lr_necessidades TO NULL     

   LET lr_necessidades.cod_empresa      = mr_ordens.cod_empresa                   
   LET lr_necessidades.num_versao       = mr_ordens.num_versao                    
   LET lr_necessidades.cod_item_pai     = mr_ordens.cod_item                      
   LET lr_necessidades.num_ordem        = mr_ordens.num_ordem                     
   LET lr_necessidades.qtd_saida        = 0                                      
   LET lr_necessidades.num_docum        = mr_ordens.num_docum                     
   LET lr_necessidades.dat_neces        = mr_ordens.dat_entrega                   
   LET lr_necessidades.ies_origem       = mr_ordens.ies_origem                    
   LET lr_necessidades.ies_situa        = mr_ordens.ies_situa                     
  
   LET l_tem_strut = FALSE           
   LET m_cod_cent_trab = mr_ordens.cod_local_prod
   
   DECLARE cq_estrut CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug,
           num_sequencia
      FROM estrut_grade
     WHERE cod_empresa  = lr_necessidades.cod_empresa
       AND cod_item_pai = lr_necessidades.cod_item_pai       
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)
            OR  (dat_validade_ini IS NULL AND dat_validade_fim >= m_dat_liberac)
            OR  (dat_validade_fim IS NULL AND dat_validade_ini <= m_dat_liberac)
            OR  (dat_validade_ini <= m_dat_liberac AND dat_validade_fim IS NULL)
            OR  (m_dat_liberac BETWEEN dat_validade_ini AND dat_validade_fim))
     ORDER BY num_sequencia

   FOREACH cq_estrut INTO 
           l_cod_item_compon, 
           l_qtd_necessaria,  
           l_pct_refug,
           l_num_sequen       
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estrut_grade:cq_estrut')
         RETURN FALSE
      END IF
      
      
      LET l_tem_strut = TRUE
      LET lr_necessidades.num_neces        = m_num_neces                                                                                                                 
      LET lr_necessidades.cod_item         = l_cod_item_compon                      
      LET lr_necessidades.qtd_necessaria   = mr_ordens.qtd_planej * l_qtd_necessaria 
      LET lr_necessidades.num_neces_consol = 0                                      

      INSERT INTO necessidades  VALUES (lr_necessidades.*)                          
                                                                                   
      IF STATUS <> 0 THEN                                                   
         CALL log003_err_sql('Inserindo','Necessidades')                           
         RETURN FALSE                                                              
      END IF         

      INSERT INTO neces_complement (
        cod_empresa, 
        num_neces, 
        cod_grade_1, 
        cod_grade_2, 
        cod_grade_3, 
        cod_grade_4, 
        cod_grade_5, 
        ordem_producao_pai,
        sequencia_it_operacao, 
        seq_processo) 
      VALUES(lr_necessidades.cod_empresa, lr_necessidades.num_neces ,' ',' ',' ',' ',' ',NULL, 0, 0)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','neces_complement')  
         RETURN FALSE
      END IF
      
      IF lr_necessidades.ies_situa = '3' THEN
         SELECT ies_tip_item                                     
           INTO m_ies_tip_item                                   
           FROM item                                             
          WHERE cod_empresa = lr_necessidades.cod_empresa                      
            AND cod_item = lr_necessidades.cod_item                 
                                                                 
         IF STATUS <> 0 THEN                                                
            CALL log003_err_sql('Lendo','item:tipo')                        
            RETURN FALSE                                                           
         END IF                                                  
                                                                 
         INSERT INTO ord_compon(                                 
            cod_empresa,                                         
            num_ordem,                                           
            cod_item_pai,                                        
            cod_item_compon,                                     
            ies_tip_item,                                        
            dat_entrega,                                         
            qtd_necessaria,                                      
            cod_local_baixa,                                     
            cod_cent_trab,                                       
            pct_refug) VALUES(                                   
                        lr_necessidades.cod_empresa,             
                        lr_necessidades.num_ordem,               
                        lr_necessidades.num_neces,               
                        lr_necessidades.cod_item,                
                        m_ies_tip_item,                          
                        lr_necessidades.dat_neces,               
                        l_qtd_necessaria,                        
                        m_cod_local_baixa,                       
                        m_cod_cent_trab,                         
                        l_pct_refug)                             
                                                                 
         IF STATUS <> 0 THEN                                                
            CALL log003_err_sql('Inserindo','ord_compon')                        
            RETURN FALSE                                                           
         END IF                                                  
      
      END IF
      
      LET m_num_neces = m_num_neces + 1
                                                                          
   END FOREACH       

   IF NOT l_tem_strut THEN
      LET m_msg = 'Item ', lr_necessidades.cod_item_pai CLIPPED, ' sem estrutura!'
      CALL log0030_mensagem(m_msg,'excla')
      RETURN FALSE
   END IF

   UPDATE par_mrp                                          
      SET prx_num_neces = m_num_neces                 
    WHERE cod_empresa   = lr_necessidades.cod_empresa             
                                                                 
   IF STATUS <> 0 THEN                                     
      CALL log003_err_sql('UPDATE','par_mrp:prx_num_neces')
      RETURN FALSE                                         
   END IF                                                  
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func025_ins_roteiro()#
#-----------------------------#

   DEFINE l_num_seq       INTEGER,
          l_seq_processo  INTEGER,
          l_parametro     CHAR(07),
          l_seq_texto     CHAR(20),
          l_tipo          CHAR(01),
          l_linha         INTEGER,
          l_texto         CHAR(70),
          l_seq_comp      INTEGER,       
          l_compon        CHAR(15),          
          l_qtd_neces     DECIMAL(10,3),     
          l_pct_refugo    DECIMAL(5,2),      
          l_ies_tip_item  CHAR(01)           
          
   DEFINE lr_recurso      RECORD LIKE man_recurso_processo.*,
          lr_ord_oper     RECORD LIKE ord_oper.*

   DEFINE lr_man_estrut_oper  RECORD
   			  empresa             char(2),
			    item_componente     char(15),
			    ies_tip_item        char(01),
			    qtd_necess          decimal(14,7),
			    pct_refugo          decimal(6,3),
			    parametro_geral     char(20)
   END RECORD
   
   INITIALIZE lr_ord_oper.* TO NULL
   
   LET lr_ord_oper.cod_empresa   = mr_ordens.cod_empresa        
   LET lr_ord_oper.num_ordem     = mr_ordens.num_ordem      
   LET lr_ord_oper.cod_item      = mr_ordens.cod_item       
   LET lr_ord_oper.dat_entrega   = mr_ordens.dat_entrega    
   LET lr_ord_oper.dat_inicio    = mr_ordens.dat_ini        
   LET lr_ord_oper.qtd_planejada = mr_ordens.qtd_planej     
   LET lr_ord_oper.qtd_boas      = mr_ordens.qtd_boas       
   LET lr_ord_oper.qtd_refugo    = mr_ordens.qtd_refug      
   LET lr_ord_oper.qtd_sucata    = mr_ordens.qtd_sucata      
   
   DECLARE cq_roteiro CURSOR FOR 
    SELECT seq_operacao,
           operacao,
           centro_trabalho,
           arranjo,
           centro_custo,
           qtd_tempo,
           qtd_tempo_setup,
           seq_processo,
           apontar_operacao,
           imprimir_operacao,
           operacao_final,
           pct_retrabalho,
           qtd_tempo
      FROM man_processo_item
        WHERE empresa         = mr_ordens.cod_empresa
          AND item            = mr_ordens.cod_item
          AND roteiro         = mr_ordens.cod_roteiro
          AND roteiro_alternativo  = mr_ordens.num_altern_roteiro
          AND ((validade_inicial IS NULL AND validade_final IS NULL)
           OR  (validade_inicial IS NULL AND validade_final >= m_dat_liberac)
           OR  (validade_final IS NULL AND validade_inicial <= m_dat_liberac)
           OR  (m_dat_liberac BETWEEN validade_inicial AND validade_final))
      
   FOREACH cq_roteiro INTO 
           lr_ord_oper.num_seq_operac,
           lr_ord_oper.cod_operac,
           lr_ord_oper.cod_cent_trab,
           lr_ord_oper.cod_arranjo,
           lr_ord_oper.cod_cent_cust,
           lr_ord_oper.qtd_horas,
           lr_ord_oper.qtd_horas_setup,
           l_seq_processo,
           lr_ord_oper.ies_apontamento,
           lr_ord_oper.ies_impressao,
           lr_ord_oper.ies_oper_final,
           lr_ord_oper.pct_refug,
           lr_ord_oper.tmp_producao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_roteiro')
         RETURN FALSE
      END IF
      
      LET l_parametro = l_seq_processo USING '<<<<<<<'
      LET lr_ord_oper.num_processo = l_parametro      
      LET lr_ord_oper.seq_processo = 0
                               
      INSERT INTO ord_oper(
         cod_empresa,      
         num_ordem,        
         cod_item,         
         cod_operac,       
         num_seq_operac,   
         cod_cent_trab,    
         cod_arranjo,      
         cod_cent_cust,    
         dat_entrega,      
         dat_inicio,       
         qtd_planejada,    
         qtd_boas,         
         qtd_refugo,       
         qtd_sucata,       
         qtd_horas,        
         qtd_horas_setup,  
         ies_apontamento,  
         ies_impressao,    
         ies_oper_final,   
         pct_refug,        
         tmp_producao,     
         num_processo)     
            VALUES(lr_ord_oper.cod_empresa,    
                   lr_ord_oper.num_ordem,      
                   lr_ord_oper.cod_item,       
                   lr_ord_oper.cod_operac,     
                   lr_ord_oper.num_seq_operac, 
                   lr_ord_oper.cod_cent_trab,  
                   lr_ord_oper.cod_arranjo,    
                   lr_ord_oper.cod_cent_cust,  
                   lr_ord_oper.dat_entrega,    
                   lr_ord_oper.dat_inicio,     
                   lr_ord_oper.qtd_planejada,  
                   lr_ord_oper.qtd_boas,       
                   lr_ord_oper.qtd_refugo,     
                   lr_ord_oper.qtd_sucata,     
                   lr_ord_oper.qtd_horas,      
                   lr_ord_oper.qtd_horas_setup,
                   lr_ord_oper.ies_apontamento,
                   lr_ord_oper.ies_impressao,  
                   lr_ord_oper.ies_oper_final, 
                   lr_ord_oper.pct_refug,      
                   lr_ord_oper.tmp_producao,   
                   lr_ord_oper.num_processo)                      
                    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','ord_oper')
         RETURN FALSE
      END IF
      
      LET l_num_seq = SQLCA.SQLERRD[2]

      DECLARE cq_recurso CURSOR FOR                                                        
       SELECT *                                                                               
         FROM man_recurso_processo                                                            
        WHERE empresa = lr_ord_oper.cod_empresa                                                         
          AND seq_processo = l_seq_processo                                                   
      FOREACH cq_recurso INTO lr_recurso.*                                                    
                                                                                              
        IF STATUS <> 0 THEN                                                                   
           CALL log003_err_sql('FOREACH','cq_recurso')       
           RETURN FALSE                                                                       
        END IF                                                                                
                                                                                              
        LET lr_recurso.seq_processo = l_num_seq                                               
                                                                                              
        INSERT INTO man_recurso_operacao_ordem                                                
        VALUES(lr_recurso.*)                                                                  
                                                                                           
        IF STATUS <> 0 THEN                                                                   
           CALL log003_err_sql('Inserindo','man_recurso_operacao_ordem')     
           RETURN FALSE                                                                       
        END IF                                                                                
                                                                                              
      END FOREACH                                                                             
      
      SELECT empresa 
        FROM man_oper_compl
       WHERE empresa = lr_ord_oper.cod_empresa
         AND ordem_producao = lr_ord_oper.num_ordem
         AND operacao = lr_ord_oper.cod_operac
         AND sequencia_operacao = lr_ord_oper.num_seq_operac
      
      IF STATUS = 100 THEN        
         INSERT INTO man_oper_compl(
            empresa,
            ordem_producao,
            operacao,
            sequencia_operacao)
         VALUES (lr_ord_oper.cod_empresa,
                 lr_ord_oper.num_ordem,
                 lr_ord_oper.cod_operac,
                 lr_ord_oper.num_seq_operac)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','man_oper_compl')
            RETURN FALSE
         END IF
      END IF

      DECLARE cq_cons_txt CURSOR FOR
       SELECT tip_texto,                                                                          
              seq_texto_processo,                                                                 
              texto_processo[1,70]                                                                  
         FROM man_texto_processo                                                                    
        WHERE empresa  = lr_ord_oper.cod_empresa                                                              
          AND seq_processo = l_seq_processo                                           
                                                                                                     
      FOREACH cq_cons_txt INTO l_tipo, l_linha, l_texto                                             
                                                                                                     
         IF STATUS <> 0 THEN                                                                      
            CALL log003_err_sql('FOREACH','cq_cons_txt')            
            RETURN FALSE                                                                            
         END IF                                                                                     
                                                                                                    
         INSERT INTO ord_oper_txt                                                                   
           VALUES (lr_ord_oper.cod_empresa,                                                                    
                   lr_ord_oper.num_ordem,                                                              
                   l_parametro,                                                                      
                   l_tipo,                                                                           
                   l_linha,                                                                          
                   l_texto,NULL)                                                                     
                                                                                                     
         IF STATUS <> 0  THEN                                                              
            CALL log003_err_sql('INSERT','ord_oper_txt')   
            RETURN FALSE                                                                         
         END IF                                                                                  
                                                                                                     
      END FOREACH                                                                                   
         
      DECLARE cq_estr_oper CURSOR WITH HOLD FOR                                                           
       SELECT seq_componente,                                                                                
              item_componente,                                                                               
              qtd_necessaria,                                                                                
              pct_refugo                                                                                     
         FROM man_estrutura_operacao                                                                         
        WHERE empresa      = lr_ord_oper.cod_empresa                                                                   
          AND item_pai     = lr_ord_oper.cod_item                                                         
          AND seq_processo = l_seq_processo                                                    
                                                                                                          
      FOREACH cq_estr_oper INTO l_seq_comp, l_compon, l_qtd_neces, l_pct_refugo                                   
                                                                                                          
         IF STATUS <> 0 THEN                                                                                 
            CALL log003_err_sql('FOREACH','cq_estr_oper')                   
            RETURN FALSE                                                                                     
         END IF                                                                                              
                                                                                                             
         SELECT ies_tip_item                                                                                 
           INTO l_ies_tip_item                                                                               
           FROM item                                                                                         
          WHERE cod_empresa = lr_ord_oper.cod_empresa                                                                  
            AND cod_item = l_compon                                                                          
                                                                                                             
         IF STATUS <> 0 THEN                                                                                 
            CALL log003_err_sql('SELECT','item:cq_estr_oper')                                        
            RETURN FALSE                                                                                     
         END IF                                                                                              

         SELECT num_neces INTO l_seq_comp FROM necessidades
          WHERE cod_empresa = lr_ord_oper.cod_empresa
            AND num_ordem = lr_ord_oper.num_ordem
            AND cod_item_pai = lr_ord_oper.cod_item
            AND cod_item = l_compon
                                                    
         INSERT INTO man_op_componente_operacao                                                               
          VALUES (lr_ord_oper.cod_empresa,                                                                              
                  lr_ord_oper.num_ordem,                                                                        
                  mr_ordens.cod_roteiro ,                                                                     
                  mr_ordens.num_altern_roteiro,                                                               
                  lr_ord_oper.num_seq_operac,                                                     
                  lr_ord_oper.cod_item,                                                                   
                  l_compon,                                                                                   
                  l_ies_tip_item,                                                                             
                  mr_ordens.dat_entrega,                                                                      
                  l_qtd_neces,                                                                                
                  m_cod_local_baixa,                                                                   
                  lr_ord_oper.cod_cent_trab,                                                                                  
                  l_pct_refugo,                                                                               
                  l_seq_comp,                                                                                      
                  l_num_seq)                             
                                                                                                             
         IF STATUS <> 0 THEN                                                                          
            CALL log003_err_sql('Inserindo','man_op_componente_operacao') 
            RETURN FALSE                                                                                     
         END IF                                                                                              
                                                                                                             
      END FOREACH                                                                                            

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
