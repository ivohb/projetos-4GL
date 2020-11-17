#-----------------------------------------------------------#
#-------Objetivo: gerar Ordem de montagem total do pedido---#
#--------------------------par�metros-----------------------#
# n�mro do pedido numero do pedido                          #
#--------------------------retorno texto--------------------#
#numero da OM ou zero, no caso de erro, e a mensagem de erro#
#-----------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,          
          g_msg                  CHAR(150),
          g_tipo_sgbd            CHAR(03)

   DEFINE p_user                 LIKE usuarios.cod_usuario

END GLOBALS

DEFINE m_num_pedido              INTEGER,
       m_num_om                  INTEGER,
       m_om_padrao               INTEGER,
       m_msg                     VARCHAR(120),
       m_num_seq                 INTEGER, 
       m_cod_item                CHAR(15), 
       m_qtd_romanear            DECIMAL(10,3),
       m_qtd_reservar            DECIMAL(10,3),
       m_num_lote_om             INTEGER,
       m_dat_atu                 DATE,
       m_hor_atu                 CHAR(08),
       m_dat_hor                 DATETIME year to second,
       m_carteira                CHAR(02),
       m_cod_local_estoq         VARCHAR(10),
       m_num_reserva             INTEGER,
       m_bonific                 CHAR(01),
       m_cod_lin_prod            DECIMAL(2,0), 
       m_cod_lin_recei           DECIMAL(2,0), 
       m_cod_seg_merc            DECIMAL(2,0), 
       m_cod_cla_uso             DECIMAL(2,0),
       m_sit_om                  CHAR(01),
       m_transpor                VARCHAR(15),
       m_num_programa            VARCHAR(08)
       
           
DEFINE mr_ent_ender              RECORD LIKE estoque_lote_ender.*       

DEFINE m_qtd_padr_embal          LIKE item_embalagem.qtd_padr_embal,                                            
       m_cod_embal_int           LIKE item_embalagem.cod_embal,                                             
       m_cod_embal_matriz        LIKE embalagem.cod_embal_matriz,
       m_pes_item                LIKE item.pes_unit,
       m_pes_tot_item            LIKE ordem_montag_item.pes_total_item,
       m_qtd_volume              LIKE ordem_montag_item.qtd_volume_item,
       m_tot_volume              LIKE ordem_montag_mest.qtd_volume_om
       
          
#---------------------------------------------#
FUNCTION func015_gera_om(l_num_pedido, l_prog)#
#---------------------------------------------#
   
   DEFINE l_num_pedido        DECIMAL(6,0),
          l_prog              VARCHAR(08)
   
   LET m_num_pedido = l_num_pedido
   LET m_msg = NULL
   LET m_dat_atu = TODAY
   LET m_hor_atu = TIME
   LET m_dat_hor = CURRENT
   LET g_tipo_sgbd = LOG_getCurrentDBType()
   LET m_bonific = 'N'
   LET m_sit_om = 'N'
   LET m_num_programa = l_prog
   LET m_transpor = ' '
   
   SELECT cod_tip_carteira
     INTO m_carteira
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados da tabela pedidos '
      RETURN FALSE
   END IF
   
   IF NOT func015_proces_om() THEN
      LET m_num_om = 0
   END IF
   
   RETURN m_num_om, m_msg
   
END FUNCTION

#---------------------------#
FUNCTION func015_proces_om()#
#---------------------------#

   IF NOT func015_pega_lote_om() THEN
      RETURN FALSE
   END IF

   DECLARE cq_itens CURSOR FOR
    SELECT num_sequencia, cod_item,
           (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel - qtd_pecas_romaneio)
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido

   FOREACH cq_itens INTO m_num_seq, m_cod_item, m_qtd_romanear
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo itens da tabela ped_itens '
         RETURN FALSE
      END IF
      
      IF NOT func015_gra_item_om() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   IF NOT func015_ins_ord_montag_mest() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func015_gra_item_om()#
#-----------------------------#
   
   IF NOT func015_grava_reserva() THEN
      RETURN FALSE
   END IF

   IF NOT func015_le_embal() THEN
      RETURN FALSE
   END IF
   
   LET m_tot_volume = 0
   
   IF NOT func015_ins_ord_montag_item() THEN
      RETURN FALSE
   END IF

   IF NOT func015_ins_ord_montag_embal() THEN
      RETURN FALSE
   END IF

   IF NOT func015_atu_item() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   
   
#------------------------------#
FUNCTION func015_pega_lote_om()#
#------------------------------#
                                                                                                  
   SELECT MAX(num_lote_om)                                                                           
     INTO m_num_lote_om                                                                              
     FROM ordem_montag_lote                                                                          
    WHERE cod_empresa = p_cod_empresa                                                                
                                                                                                     
   IF m_num_lote_om IS NULL THEN                                                                     
      LET m_num_lote_om = 0                                                                          
   ELSE                                                                                              
      IF STATUS <> 0 THEN                                                                            
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados da tabela ordem_montag_lote '     
         RETURN FALSE                                                                                
      END IF                                                                                         
   END IF                                                                                            
                                                                                                  
   LET m_num_lote_om = m_num_lote_om + 1                                                             
        
   SELECT val_parametro 
     INTO m_om_padrao
     FROM log_val_parametro 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'num_ult_om'

   IF STATUS = 100 OR m_om_padrao IS NULL THEN
      LET m_om_padrao = 0
   ELSE 
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados da tabela log_val_parametro '     
         RETURN FALSE                                                                                
      END IF
   END IF

   SELECT num_ult_om
     INTO m_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados da tabela par_vdp '     
      RETURN FALSE                                                                                
   END IF

   IF m_num_om IS NULL THEN
      LET m_num_om = 0
   END IF

   IF m_om_padrao IS NULL THEN
      LET m_om_padrao = 0
   END IF

   IF m_num_om < m_om_padrao THEN
      LET m_num_om = m_om_padrao
   END IF
   
   LET m_num_om = m_num_om + 1
   
   UPDATE par_vdp
      SET num_ult_om = m_num_om
    WHERE cod_empresa = p_cod_empresa
         
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' atualizando dados da tabela par_vdp '     
      RETURN FALSE                                                                                
   END IF

   SELECT val_parametro 
     FROM log_val_parametro 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'num_ult_om'
   
   IF STATUS = 0 THEN
      UPDATE log_val_parametro 
         SET val_parametro = m_num_om
       WHERE empresa = p_cod_empresa
         AND parametro='num_ult_om'
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' atualizando dados da tabela log_val_parametro '     
         RETURN FALSE                                                                                
      END IF
   END IF
    
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION func015_grava_reserva()#
#-------------------------------#
   
   DEFINE l_a_reservar    DECIMAL(10,3),
          l_reser_atu     DECIMAL(10,3)
   
   SELECT cod_local_estoq,
          cod_lin_prod,
          cod_lin_recei,
          cod_seg_merc,
          cod_cla_uso,
          pes_unit
     INTO m_cod_local_estoq,
          m_cod_lin_prod, 
          m_cod_lin_recei,
          m_cod_seg_merc, 
          m_cod_cla_uso,
          m_pes_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item
   
	 IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados na tabela item '
      RETURN FALSE
	 END IF
   
   LET l_a_reservar = m_qtd_romanear
   
   DECLARE cq_reser CURSOR FOR
    SELECT *
      FROM estoque_lote_ender
     WHERE cod_empresa = p_cod_empresa
       AND cod_item = m_cod_item
       AND cod_local = m_cod_local_estoq
       AND ies_situa_qtd = 'L'
       AND qtd_saldo > 0       
     ORDER BY num_transac

   FOREACH cq_reser INTO mr_ent_ender.*
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados na tabela estoque_lote_ender '
         RETURN FALSE
	    END IF

      SELECT SUM(qtd_reservada)
        INTO l_reser_atu
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = m_cod_item
         AND cod_local   = m_cod_local_estoq
      
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo dados na tabela estoque_loc_reser '
         RETURN FALSE
	    END IF
      
      IF l_reser_atu IS NULL THEN
         LET l_reser_atu = 0
      END IF
      
      LET mr_ent_ender.qtd_saldo = mr_ent_ender.qtd_saldo - l_reser_atu
      
      IF mr_ent_ender.qtd_saldo <= 0 THEN
         CONTINUE FOREACH
      END IF
       
      IF mr_ent_ender.qtd_saldo > l_a_reservar THEN
         LET m_qtd_reservar = l_a_reservar
         LET l_a_reservar = 0
      ELSE
         LET m_qtd_reservar = mr_ent_ender.qtd_saldo
         LET l_a_reservar = l_a_reservar - m_qtd_reservar
      END IF
      
      IF NOT func015_ins_reserva() THEN
         RETURN FALSE
      END IF
      
      IF l_a_reservar <= 0 THEN
         EXIT FOREACH
      END IF
      
   END FOREACH

   IF l_a_reservar > 0 THEN
      LET m_msg = 'Item ', m_cod_item CLIPPED, ' sem estoque suficiente '
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION func015_ins_reserva()#
#-----------------------------#

   IF g_tipo_sgbd = 'MSV' THEN
      INSERT INTO estoque_loc_reser(
             cod_empresa,
             cod_item,
             cod_local,
             qtd_reservada,
             num_lote,
             ies_origem,
             num_docum,
             num_referencia,
             ies_situacao,
             dat_prev_baixa,
             num_conta_deb,
             cod_uni_funcio,
             nom_solicitante,
             dat_solicitacao,
             nom_aprovante,
             dat_aprovacao,
             qtd_atendida,
             dat_ult_atualiz)
           VALUES(p_cod_empresa,
                  m_cod_item,
                  m_cod_local_estoq,
                  m_qtd_reservar,
                  mr_ent_ender.num_lote,
                  'V',
                  m_num_pedido,
                  NULL,
                  'N',
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  m_dat_atu,
                  NULL,
                  NULL,
                  0,
                  NULL)
   ELSE
      INSERT INTO estoque_loc_reser(
             cod_empresa,
             num_reserva,
             cod_item,
             cod_local,
             qtd_reservada,
             num_lote,
             ies_origem,
             num_docum,
             num_referencia,
             ies_situacao,
             dat_prev_baixa,
             num_conta_deb,
             cod_uni_funcio,
             nom_solicitante,
             dat_solicitacao,
             nom_aprovante,
             dat_aprovacao,
             qtd_atendida,
             dat_ult_atualiz)
           VALUES(p_cod_empresa,0,
                  m_cod_item,
                  m_cod_local_estoq,
                  m_qtd_reservar,
                  mr_ent_ender.num_lote,
                  'V',
                  m_num_pedido,
                  NULL,
                  'N',
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  m_dat_atu,
                  NULL,
                  NULL,
                  0,
                  NULL)
   
   END IF
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela estoque_loc_reser '
      RETURN FALSE
   END IF

   LET m_num_reserva = SQLCA.SQLERRD[2]
      
   INSERT INTO est_loc_reser_end (                           
					cod_empresa,                                         	
					num_reserva,                                         	
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
         VALUES(p_cod_empresa,                                  
                m_num_reserva,                                  
                mr_ent_ender.endereco,                  
                mr_ent_ender.num_volume,                
                mr_ent_ender.cod_grade_1,               
                mr_ent_ender.cod_grade_2,               
                mr_ent_ender.cod_grade_3,               
                mr_ent_ender.cod_grade_4,               
                mr_ent_ender.cod_grade_5,               
                mr_ent_ender.dat_hor_producao,          
                mr_ent_ender.num_ped_ven,               
                mr_ent_ender.num_seq_ped_ven,           
                mr_ent_ender.dat_hor_validade,          
                mr_ent_ender.num_peca,                  
                mr_ent_ender.num_serie,                 
                mr_ent_ender.comprimento,               
                mr_ent_ender.largura,                   
                mr_ent_ender.altura,                    
                mr_ent_ender.diametro,                  
                mr_ent_ender.dat_hor_reserv_1,          
                mr_ent_ender.dat_hor_reserv_2,          
                mr_ent_ender.dat_hor_reserv_3,          
                mr_ent_ender.qtd_reserv_1,              
                mr_ent_ender.qtd_reserv_2,              
                mr_ent_ender.qtd_reserv_3,              
                mr_ent_ender.num_reserv_1,              
                mr_ent_ender.num_reserv_2,              
                mr_ent_ender.num_reserv_3,              
                mr_ent_ender.tex_reservado)             
                   
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela est_loc_reser_end '
      RETURN FALSE
   END IF

   INSERT INTO ordem_montag_grade                     
         VALUES(p_cod_empresa,                           
                m_num_om,                                
                m_num_pedido,                            
                m_num_seq,               
                m_cod_item,                    
                m_qtd_reservar,                          
                m_num_reserva,                           
                mr_ent_ender.cod_grade_1,        
                mr_ent_ender.cod_grade_2,        
                mr_ent_ender.cod_grade_3,        
                mr_ent_ender.cod_grade_4,        
                mr_ent_ender.cod_grade_5,        
                NULL)                                    
          
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_grade '
      RETURN FALSE
   END IF
   
   INSERT INTO ldi_om_grade_compl
    VALUES(p_cod_empresa, m_num_om,
           m_num_pedido, m_num_seq, 
           m_num_reserva, m_bonific)

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ldi_om_grade_compl '
      RETURN FALSE
   END IF

   INSERT INTO sup_resv_lote_est
    VALUES(p_cod_empresa, m_num_reserva, 
           mr_ent_ender.num_transac, 
           m_qtd_reservar, 0) 

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela sup_resv_lote_est '
      RETURN FALSE
   END IF

   INSERT INTO est_reser_area_lin
    VALUES(p_cod_empresa, m_num_reserva, 
           m_cod_lin_prod, m_cod_lin_recei, 
           m_cod_seg_merc, m_cod_cla_uso) 

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela est_reser_area_lin '
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func015_le_embal()#
#--------------------------#

   SELECT a.qtd_padr_embal,                                               
          a.cod_embal,                                                 
          b.cod_embal_matriz                                           
     INTO m_qtd_padr_embal,                                            
          m_cod_embal_int,                                             
          m_cod_embal_matriz                                           
     FROM item_embalagem a,                                            
          embalagem b                                                  
    WHERE a.cod_empresa   = p_cod_empresa                              
      AND a.cod_item      = m_cod_item                       
      AND a.cod_embal     = b.cod_embal                                
      AND a.ies_tip_embal IN ('I','N')                                 
                                                                 
   IF STATUS = 100 THEN                                                
      LET m_qtd_padr_embal = 0                                         
      LET m_cod_embal_int = NULL                                      
   ELSE                                                                
      IF STATUS = 0 THEN                                               
         IF m_cod_embal_matriz IS NOT NULL THEN                        
            LET m_cod_embal_int = m_cod_embal_matriz                   
         END IF 	                                                     
      ELSE                                                             
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela item_embalagem '     
         RETURN FALSE                                                  
      END IF                                                           
   END IF                                                              
   
   RETURN TRUE

END FUNCTION
                                       
#-------------------------------------#
FUNCTION func015_ins_ord_montag_item()#
#-------------------------------------#

   LET m_pes_tot_item = m_pes_item * m_qtd_romanear
   
   IF m_qtd_padr_embal IS NOT NULL AND m_qtd_padr_embal > 0 THEN
      LET m_qtd_volume = m_qtd_romanear / m_qtd_padr_embal
   ELSE
      LET m_qtd_volume = m_qtd_romanear 
   END IF
   
   LET m_tot_volume = m_tot_volume + m_qtd_volume
   
   INSERT INTO ordem_montag_item
    VALUES(p_cod_empresa,
           m_num_om,
           m_num_pedido,
           m_num_seq,
           m_cod_item,
           m_qtd_volume,
           m_qtd_romanear,
           m_bonific,
           m_pes_tot_item)   
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_item '
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION func015_ins_ord_montag_embal()#
#--------------------------------------#

   INSERT INTO ordem_montag_embal                   
      VALUES(p_cod_empresa,                            
             m_num_om,              
             m_num_seq,	     
             m_cod_item,            
             m_cod_embal_int,
             m_qtd_volume,     
             NULL,0,'T',1,1,                                        
             m_qtd_romanear)       

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_embal '
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION func015_atu_item()#
#--------------------------#

   UPDATE ped_itens                                                                       
      SET qtd_pecas_romaneio = qtd_pecas_romaneio + m_qtd_romanear    
    WHERE cod_empresa   = p_cod_empresa                                                      
      AND num_pedido    = m_num_pedido                                    
      AND num_sequencia = m_num_seq                             

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' atualizando dados na tabela ped_itens '
      RETURN FALSE
   END IF   
                                                                                          
                                                                                          
   UPDATE estoque                                                                            
      SET qtd_reservada =                                                                    
          qtd_reservada +  m_qtd_romanear                                
    WHERE cod_empresa = p_cod_empresa                                                        
      AND cod_item    = m_cod_item                                        

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' atualizando dados na tabela estoque '
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION func015_ins_ord_montag_mest()#
#-------------------------------------#
   
   DEFINE l_texto       LIKE audit_vdp.texto

   INSERT INTO ordem_montag_lote 
	  VALUES(p_cod_empresa,
	         m_num_lote_om,
	         'N',
	          0,
	          m_dat_atu,
	          0,
	          m_carteira,
	          NULL,
	          0,
	          0,
	          0)
	
	  IF STATUS <> 0 THEN
       LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_lote '
       RETURN FALSE
	  END IF
    
	 INSERT INTO ordem_montag_mest 
	  VALUES(p_cod_empresa,
	         m_num_om,
	         m_num_lote_om,
	         m_sit_om,
	         m_transpor,
	         m_tot_volume,
	         m_dat_atu,
	         NULL)
	
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_mest '
      RETURN FALSE
   END IF   
	  
	 INSERT INTO om_list 
	     VALUES (p_cod_empresa,
	             m_num_om,
	             m_num_pedido,
	             m_dat_atu,
	             p_user)

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ordem_montag_mest '
      RETURN FALSE
   END IF   

	 INSERT INTO ldi_om_auditoria 
	     VALUES (p_cod_empresa,
	             m_num_om, 'I',
	             m_num_programa,
	             p_user,
	             m_dat_atu,
	             ' ')

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela ldi_om_auditoria '
      RETURN FALSE
   END IF   

	 INSERT INTO wpedido_om 
	     VALUES (p_cod_empresa,
	             m_num_pedido,
	             p_user)

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela wpedido_om '
      RETURN FALSE
   END IF   

   LET l_texto = 'INCLUSAO DA OM Nr.', m_num_om USING '<<<<<<<' 
   
   INSERT INTO audit_vdp (
      cod_empresa,
      num_pedido,
      tipo_informacao,
      tipo_movto,
      texto,
      num_programa,
      data,
      hora,
      usuario)
    VALUES(p_cod_empresa,
           m_num_pedido,
           'C',
           'C', 
           l_texto,
           m_num_programa,
           m_dat_atu,
           m_hor_atu,
           p_user)

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela audit_vdp '
      RETURN FALSE
   END IF   
	  
   RETURN TRUE

END FUNCTION
   	             