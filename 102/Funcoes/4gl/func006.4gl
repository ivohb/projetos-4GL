#-----------------------------------------------------------#
#-------Objetivo: verificar saldo de material---------------#
#--------------------------parâmetros-----------------------#
#        um parâmetro do tipo RECORD contendo:              #
# - Ordem de produção, integer                              #
# - qtd a apontar, decimal(10,3)                            #
#--------------------------retorno texto--------------------#
#Um texto contendo um erro crítico, se ocorrer, ou uma      #
#string vazia, en caso contrário                            #
#-----------------------------------------------------------#
#As mensagens sobre os componentes sem saldo seráo gravadas #
#na tabela APONT_ERRO_912                                   #
#-----------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa        CHAR(02),
          g_id_man_apont       INTEGER,
          g_tem_critica        SMALLINT

END GLOBALS

#--variáveis privadas de uso geral--#

DEFINE m_num_ordem             INTEGER,
       m_cod_empresa           CHAR(02),
       m_msg                   CHAR(150),
       m_qtd_apont             DECIMAL(10,3),
       m_qtd_saldo             DECIMAL(10,3),
       m_erro                  CHAR(10),
       m_status                SMALLINT

DEFINE m_cod_compon            LIKE ord_compon.cod_item_compon,
       m_qtd_necessaria        LIKE ord_compon.qtd_necessaria,
       m_cod_local_baixa       LIKE ord_compon.cod_local_baixa,
       m_ies_ctr_estoque       LIKE item.ies_ctr_estoque,
       m_ies_sofre_baixa       LIKE item_man.ies_sofre_baixa

#----------------------------------------#
FUNCTION func006_checa_saldo(l_parametro)#
#----------------------------------------#

   DEFINE l_parametro      RECORD
          cod_empresa      CHAR(02),
          num_ordem        INTEGER,
          qtd_apont        DECIMAL(10,3)
   END RECORD

   LET m_msg = ''

   IF l_parametro.cod_empresa IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Parâmetro EMPRESA é obrigatório;'
   END IF 

   IF l_parametro.num_ordem IS NULL THEN
      LET m_msg = m_msg CLIPPED, '- Parâmetro OP é obrigatório;'
   END IF 

   IF l_parametro.qtd_apont IS NULL OR l_parametro.qtd_apont <= 0 THEN
      LET m_msg = m_msg CLIPPED, '- Parâmetro QUANTIDADE é obrigatório;'
   END IF 
   
   IF m_msg IS NULL THEN
      SELECT num_ordem
        FROM ordens
       WHERE cod_empresa = l_parametro.cod_empresa
         AND num_ordem = l_parametro.num_ordem
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'func006_checa_saldo: erro ',m_erro,' Lendo tabela ordens;'  
      END IF
   ELSE
      CALL func006_ins_erro() RETURNING m_status
   END IF 

   IF m_msg IS NULL THEN
      LET m_cod_empresa = l_parametro.cod_empresa
      LET m_num_ordem = l_parametro.num_ordem
      LET m_qtd_apont = l_parametro.qtd_apont
      CALL func006_ck_material()
   END IF
   
   RETURN m_msg

END FUNCTION

#-----------------------------#
FUNCTION func006_ck_material()#
#-----------------------------#
   
   DECLARE cq_structure CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           cod_local_baixa
      FROM ord_compon
     WHERE cod_empresa = m_cod_empresa
       AND num_ordem   = m_num_ordem
       AND qtd_necessaria > 0

   FOREACH cq_structure INTO 
           m_cod_compon, 
           m_qtd_necessaria,
           m_cod_local_baixa

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'func006_ck_material - ERRO', m_erro,' LENDO TAB ORD_COMPON'  
         RETURN 
      END IF  

      IF NOT func006_le_man() THEN
         RETURN 
      END IF

      IF m_ies_ctr_estoque = 'N' OR m_ies_sofre_baixa = 'N' THEN
         CONTINUE FOREACH
      END IF
      
      LET m_qtd_necessaria = m_qtd_necessaria * m_qtd_apont

         
      IF NOT func006_le_estoque() THEN
         RETURN
      END IF

      IF m_qtd_saldo < m_qtd_necessaria THEN
         LET m_msg =  'ITEM: ',m_cod_compon CLIPPED, ' SEM SALDO P/ BAIXAR '
         IF NOT func006_ins_erro() THEN
            RETURN 
         END IF
      END IF        
   
   END FOREACH
   
   LET m_msg = ''
   
END FUNCTION

#------------------------#
FUNCTION func006_le_man()#
#------------------------#
   
   DEFINE p_item CHAR(15)
   
   SELECT a.ies_ctr_estoque,
          b.ies_sofre_baixa
     INTO m_ies_ctr_estoque,
          m_ies_sofre_baixa
     FROM item a,
          item_man b
    WHERE a.cod_empresa = m_cod_empresa
      AND a.cod_item    = m_cod_compon
      AND b.cod_empresa = a.cod_empresa
      AND b.cod_item    = a.cod_item

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'func006_le_man - ERRO ',m_erro,' LENDO TAB ITEM/ITEM_MAN'  
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION func006_le_estoque()#
#----------------------------#
   
   DEFINE l_qtd_reservada   DECIMAL(10,3)
   
          
   SELECT SUM(qtd_saldo)
     INTO m_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = m_cod_empresa
	    AND cod_item      = m_cod_compon
	    AND cod_local     = m_cod_local_baixa
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'func006_le_estoque - ERRO ',m_erro,' LENDO TAB ESTOQUE_LOTE_ENDER'  
      RETURN FALSE
   END IF  

   IF m_qtd_saldo IS NULL THEN
      LET m_qtd_saldo = 0
      RETURN TRUE
   END IF

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = m_cod_empresa
      AND cod_item    = m_cod_compon
      AND cod_local   = m_cod_local_baixa
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'func006_le_estoque - ERRO ',m_erro,' LENDO TAB ESTOQUE_LOC_RESER'  
      RETURN FALSE
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   LET m_qtd_saldo = m_qtd_saldo - l_qtd_reservada
   
   RETURN TRUE

END FUNCTION


#--------------------------#
FUNCTION func006_ins_erro()#
#--------------------------#
   
   LET g_tem_critica = TRUE
   
   INSERT INTO apont_erro_912
    VALUES(m_cod_empresa, g_id_man_apont, m_msg)

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' INSERINDO DADOS NA TAB APONT_ERRO_912'
      RETURN FALSE
   END IF 
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION func006_del_erro()#
#--------------------------#
      
   DELETE FROM apont_erro_912
    WHERE cod_empresa = p_cod_empresa
      AND id_man_apont = g_id_man_apont

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ',m_erro CLIPPED, ' DELETANDO DADOS DA TAB APONT_ERRO_912'
      RETURN FALSE
   ELSE 
      LET m_msg = ''
   END IF 
   
   RETURN m_msg

END FUNCTION   
