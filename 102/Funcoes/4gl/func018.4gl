#---------------------------------------------------------------#
#-------Objetivo: verificar/gerar pedido de venda --------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150)

END GLOBALS

DEFINE p_cod_empresa          CHAR(02),
       p_user                 CHAR(08)

DEFINE m_erro                 CHAR(10),
       m_msg                  CHAR(150)
       

#----Objetivo: obter pedido de industrialização---------#
#--------------------parâmetros-------------------------#
#empresa pedido, empresa op                             #                     
#--------------------retorno----------------------------#
#Número do pedido ou mensaem de erro                    #
#-------------------------------------------------------# 
#-------------------------------------------------------#
FUNCTION func018_le_ped_indus(l_emp_ped, l_emp_op, l_pv)#
#-------------------------------------------------------#
   
   DEFINE l_emp_ped     LIKE empresa.cod_empresa,
          l_emp_op      LIKE empresa.cod_empresa,
          l_pv          LIKE pedidos.num_pedido,
          l_num_cgc     LIKE empresa.num_cgc,
          l_num_pedido  LIKE pedidos.num_pedido,
          l_cliente     LIKE clientes.cod_cliente,
          l_tipo_pedido LIKE tipo_pedido_885.tipo_pedido, 
          l_tipo_processo LIKE tipo_pedido_885.tipo_processo,
          l_count         INTEGER
   
   LET m_msg = NULL
   
   SELECT num_cgc INTO l_num_cgc
     FROM empresa 
    WHERE cod_empresa = l_emp_ped

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO CNPJ DA EMPRESA ',l_emp_ped
      RETURN m_msg 
   END IF

   SELECT cod_cliente INTO l_cliente
     FROM clientes WHERE num_cgc_cpf = l_num_cgc
     
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO CLIENTE COM CNPJ ',l_cliente
      RETURN m_msg 
   END IF

   SELECT MIN(num_pedido) 
     INTO l_num_pedido
     FROM pedidos
    WHERE cod_empresa = l_emp_op
      AND cod_cliente = l_cliente
      AND ies_sit_pedido <> '9'
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO PEDIDO DE INDUSTRIALIZAÇÃO DO CLIENTE ',l_cliente
      RETURN m_msg 
   END IF
   
   IF l_num_pedido IS NULL THEN
      LET l_num_pedido = 0
   END IF

   IF l_num_pedido = 0 THEN
      LET m_msg = 'ERRO: PEDIDO DE VENDA BENEFICIAMENTO NÃO ENCONTRADO NA EMPRESA ', l_emp_op
      RETURN m_msg 
   END IF
   
   IF l_pv = 0 THEN
      LET m_msg = l_num_pedido
      RETURN m_msg
   END IF
   
   SELECT COUNT(num_pedido) 
     INTO l_count
     FROM tipo_pedido_885
    WHERE cod_empresa = l_emp_op
      AND num_pedido = l_num_pedido
      
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO DADOS DA TAB TIPO_PEDIDO_885 ',l_num_pedido
      RETURN m_msg 
   END IF
   
   IF l_count = 0 THEN
      SELECT tipo_pedido, tipo_processo
        INTO l_tipo_pedido, l_tipo_processo
        FROM tipo_pedido_885
       WHERE cod_empresa = l_emp_ped
         AND num_pedido = l_pv

      IF STATUS <> 0 AND STATUS <> 100 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO DADOS DA TAB TIPO_PEDIDO_885 ',l_pv
         RETURN m_msg 
      END IF
      
      IF STATUS = 0 THEN
         INSERT INTO tipo_pedido_885
          VALUES(l_emp_op, l_num_pedido, l_tipo_pedido, l_tipo_processo)
         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO DADOS NA TAB TIPO_PEDIDO_885 ',l_num_pedido
            RETURN m_msg 
         END IF
      END IF
   END IF
         
   LET m_msg = l_num_pedido
   RETURN m_msg

END FUNCTION

#----Objetivo: verificar pedido de venda -------#
#--------------------parâmetros-----------------#
#empresa, item                                  #                     
#--------------------retorno--------------------#
#Número do pedido ou mensaem de erro            #
#-----------------------------------------------# 
FUNCTION func018_ins_ped_itens(lr_pedido)       #
#-----------------------------------------------#
   
   DEFINE lr_pedido       RECORD
          empresa         LIKE pedidos.cod_empresa,
          pedido          LIKE pedidos.num_pedido,
          item            LIKE item.cod_item,
          quantidade      LIKE ped_itens.qtd_pecas_solic,
          entrega         LIKE ped_itens.prz_entrega          
   END RECORD
    
   DEFINE l_transacao      INTEGER,
          l_num_list_preco INTEGER,
          l_cliente        CHAR(15),
          l_num_seq        INTEGER,
          l_empresa        CHAR(02)
   
   DEFINE l_pre_unit       LIKE ped_itens.pre_unit
   
   DEFINE lr_ped_itens    RECORD LIKE ped_itens.*

   SELECT num_list_preco, cod_cliente 
     INTO l_num_list_preco,
          l_cliente
     FROM pedidos 
    WHERE cod_empresa = lr_pedido.empresa
      AND num_pedido = lr_pedido.pedido

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO LISTA DE PREÇO DO PEDIDO ',lr_pedido.pedido
      RETURN m_msg 
   END IF
   
   LET l_transacao = func016_le_lista(lr_pedido.empresa,
         l_num_list_preco, l_cliente, lr_pedido.item)
      
   IF l_transacao = 0 THEN
      RETURN g_msg
   END IF
      
   SELECT pre_unit 
     INTO l_pre_unit
     FROM desc_preco_item 
    WHERE cod_empresa = lr_pedido.empresa
      AND num_transacao = l_transacao
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO PREÇO UNITÁRIO DO ITEM ',lr_pedido.cod_item
      RETURN m_msg 
   END IF

   SELECT MAX(num_sequencia)
     INTO l_num_seq
     FROM ped_itens
    WHERE cod_empresa = lr_pedido.empresa
      AND num_pedido = lr_pedido.pedido
    
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO NOVA SEQUNCIA DO ITEM DO PEDIDO ',lr_pedido.pedido
      RETURN m_msg 
   END IF
   
   IF l_num_seq IS NULL THEN
      LET l_num_seq = 0
   END IF
   
   LET lr_ped_itens.cod_empresa = lr_pedido.empresa      
   LET lr_ped_itens.num_pedido  = lr_pedido.pedido
   LET lr_ped_itens.num_sequencia = l_num_seq + 1  
   LET lr_ped_itens.cod_item = lr_pedido.item      
   LET lr_ped_itens.pct_desc_adic = 0                
   LET lr_ped_itens.pre_unit = l_pre_unit    
   LET lr_ped_itens.qtd_pecas_solic = lr_pedido.quantidade
   LET lr_ped_itens.qtd_pecas_atend = 0              
   LET lr_ped_itens.qtd_pecas_cancel = 0             
   LET lr_ped_itens.qtd_pecas_reserv = 0             
   LET lr_ped_itens.prz_entrega = lr_pedido.entrega 
   LET lr_ped_itens.val_desc_com_unit = 0            
   LET lr_ped_itens.val_frete_unit = 0               
   LET lr_ped_itens.val_seguro_unit = 0              
   LET lr_ped_itens.qtd_pecas_romaneio = 0           
   LET lr_ped_itens.pct_desc_bruto = 0               

   INSERT INTO ped_itens VALUES(lr_ped_itens.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO ITEM NO PEDIDO ',lr_pedido.pedido
      RETURN m_msg 
   END IF
   
   LET m_msg = 'OK'

   RETURN m_msg

END FUNCTION

