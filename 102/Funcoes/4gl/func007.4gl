#-----------------------------------------------------------#
#----------Objetivo: obter saldo de material----------------#
#--------------------------parâmetros-----------------------#
# - código do produto                                       #
#--------------------------retorno lógico-------------------#
# True - operação bem sucedida                              #
# False - erro em alguma leitura                            #
#-----------------------------------------------------------#
#O saldo do produto será armazanado na variável global      #
# g_qtd_saldo e o erro, se houve, na variável g_msg         #
#-----------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          g_id_man_apont         INTEGER,
          g_tem_critica          SMALLINT,
          g_msg                  CHAR(150),
          g_qtd_saldo            DECIMAL(10,3)

END GLOBALS

DEFINE m_erro                   CHAR(10)


#----------------------------------#
FUNCTION func007_le_saldo(l_codigo)#
#----------------------------------#

   DEFINE l_qtd_reservada   DECIMAL(10,3),
          l_codigo          CHAR(15),
          l_qtd_saldo       DECIMAL(10,3),
          l_cod_local       CHAR(10)
   
   SELECT cod_local_estoq
     INTO l_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = l_codigo

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'func006_le_saldo - ERRO ',m_erro,' LENDO LOCAL DO ITEM'  
      RETURN FALSE
   END IF  
                    
   SELECT SUM(qtd_saldo)
     INTO g_qtd_saldo
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_empresa
	    AND cod_item      = l_codigo
	    AND cod_local     = l_cod_local
      AND ies_situa_qtd = 'L'
          
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'func006_le_saldo - ERRO ',m_erro,' LENDO ESTOQUE DO ITEM'  
      RETURN FALSE
   END IF  

   IF g_qtd_saldo IS NULL THEN
      LET g_qtd_saldo = 0
      RETURN TRUE
   END IF

   SELECT SUM(qtd_reservada)
     INTO l_qtd_reservada 
     FROM estoque_loc_reser
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = l_codigo
      AND cod_local   = l_cod_local
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET g_msg = 'func006_le_saldo - ERRO ',m_erro,' LENDO RESERVAS DO ITEM'  
      RETURN FALSE
   END IF  
               
   IF l_qtd_reservada IS NULL OR l_qtd_reservada < 0 THEN
      LET l_qtd_reservada = 0
   END IF
   
   IF g_qtd_saldo > l_qtd_reservada THEN
      LET g_qtd_saldo = g_qtd_saldo - l_qtd_reservada
   ELSE
      LET g_qtd_saldo = 0
   END IF
   
   RETURN TRUE

END FUNCTION

