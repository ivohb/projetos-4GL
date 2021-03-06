#---------------------------------------------------------------#
#-------Objetivo: verificar/gerar pedido de venda --------------#
#--Obs: a rotina que a chama deve ter uma transa��o aberta------#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150)

END GLOBALS

DEFINE p_cod_empresa          CHAR(02),
       p_user                 CHAR(08)

DEFINE m_erro                 CHAR(10),
       m_msg                  CHAR(150),
       m_empresa_orig         CHAR(02),
       m_empresa_dest         CHAR(02),
       m_pedido               INTEGER,
       m_cliente              CHAR(15),
       m_num_lista            INTEGER,
       m_cod_nat_oper         INTEGER,
       m_cod_repres           INTEGER,
       m_tip_carteira         CHAR(02),
       m_cnd_pgto             INTEGER


#----Objetivo: obter pedido de industrializa��o---------#
#--------------------par�metros-------------------------#
#empresa pedido, empresa op                             #                     
#--------------------retorno----------------------------#
#N�mero do pedido ou mensaem de erro                    #
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
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO PEDIDO DE INDUSTRIALIZA��O DO CLIENTE ',l_cliente
      RETURN m_msg 
   END IF
   
   IF l_num_pedido IS NULL THEN
      LET l_num_pedido = 0
   END IF

   IF l_num_pedido = 0 THEN
      LET m_msg = 'ERRO: PEDIDO DE VENDA BENEFICIAMENTO N�O ENCONTRADO NA EMPRESA ', l_emp_op
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

#----Objetivo: inserir item no pedido    -------#
#--------------------retorno--------------------#
#OK, se sucesso ou a mesnagem de erro           #
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
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO LISTA DE PRE�O DO PEDIDO ',lr_pedido.pedido
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
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO PRE�O UNIT�RIO DO ITEM ',lr_pedido.cod_item
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

#----Objetivo: copiar pedido da empresa de venda--------#
#  para a empresa que far� o beneficiamento             #
#--------------------par�metros-------------------------#
#empresa venda, empresa beneficiadora e num pedido      #                     
#--------------------retorno----------------------------#
#OK, se sucesso ou a mensagemd de erro                  #
#-------------------------------------------------------# 
#-------------------------------------------------------#
FUNCTION func018_copia_pedido(l_emp_ped, l_emp_op, l_pv)#
#-------------------------------------------------------#
   
   DEFINE l_emp_ped     LIKE empresa.cod_empresa,
          l_emp_op      LIKE empresa.cod_empresa,
          l_pv          LIKE pedidos.num_pedido
   
   LET m_empresa_orig = l_emp_ped
   LET m_empresa_dest = l_emp_op
   LET m_pedido = l_pv
   
   LET m_msg = NULL
 
   IF NOT func018_le_parametros() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_pedido() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_pd_itens() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_info_compl() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_itens_texto() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_item_bobina() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_item_chapa() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_tipo_pedido() THEN
      RETURN m_msg
   END IF

   IF NOT func018_ins_desc_nat() THEN
      RETURN m_msg
   END IF

   RETURN 'OK'
   
END FUNCTION

#-------------------------------#
FUNCTION func018_le_parametros()#
#-------------------------------#

   DEFINE l_num_cgc     LIKE empresa.num_cgc
   
   SELECT num_cgc 
     INTO l_num_cgc
     FROM empresa 
    WHERE cod_empresa = m_empresa_orig

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO CNPJ DA EMPRESA ',m_empresa_orig
      RETURN FALSE 
   END IF

   SELECT cod_cliente 
     INTO m_cliente
     FROM clientes 
    WHERE num_cgc_cpf = l_num_cgc
     
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO CLIENTE COM CNPJ ',l_num_cgc
      RETURN FALSE 
   END IF
         
   SELECT parametro_numerico
     INTO m_num_lista
     FROM min_par_modulo
    WHERE empresa = m_empresa_dest
      AND parametro = 'lista_preco_benef'   

   IF STATUS = 100 THEN
      LET m_msg = 'PAR�METRO lista_preco_benef N�O CADASTRADO.'
      RETURN FALSE 
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE 
      END IF      
   END IF

   SELECT parametro_numerico
     INTO m_cod_nat_oper
     FROM min_par_modulo
    WHERE empresa = m_empresa_dest
      AND parametro = 'nat_oper_benef'   

   IF STATUS = 100 THEN
      LET m_msg = 'PAR�METRO nat_oper_benef N�O CADASTRADO.'
      RETURN FALSE 
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE 
      END IF      
   END IF

   SELECT parametro_numerico
     INTO m_cod_repres
     FROM min_par_modulo
    WHERE empresa = m_empresa_dest
      AND parametro = 'cod_repres_benef'   

   IF STATUS = 100 THEN
      LET m_msg = 'PAR�METRO cod_repres_benef N�O CADASTRADO.'
      RETURN FALSE 
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE 
      END IF      
   END IF

   SELECT parametro_texto
     INTO m_tip_carteira
     FROM min_par_modulo
    WHERE empresa = m_empresa_dest
      AND parametro = 'tip_carteira_benef'   

   IF STATUS = 100 THEN
      LET m_msg = 'PAR�METRO tip_carteira_benef N�O CADASTRADO.'
      RETURN FALSE 
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE 
      END IF      
   END IF

   SELECT parametro_numerico
     INTO m_cnd_pgto
     FROM min_par_modulo
    WHERE empresa = m_empresa_dest
      AND parametro = 'cnd_pgto_benef'   

   IF STATUS = 100 THEN
      LET m_msg = 'PAR�METRO cnd_pgto_benef N�O CADASTRADO.'
      RETURN FALSE 
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA MIN_PAR_MODULO'
         RETURN FALSE 
      END IF      
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION func018_ins_pedido()#
#----------------------------#
 
   DEFINE lr_pedidos      RECORD LIKE pedidos.*
  
   SELECT *
     INTO lr_pedidos.*
     FROM pedidos
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA PEDIDOS'
      RETURN FALSE 
   END IF
   
   LET lr_pedidos.cod_empresa = m_empresa_dest
   LET lr_pedidos.cod_cliente = m_cliente
   LET lr_pedidos.cod_nat_oper = m_cod_nat_oper
   LET lr_pedidos.cod_transpor = NULL
   LET lr_pedidos.cod_cnd_pgto = m_cnd_pgto
   LET lr_pedidos.num_pedido_cli = m_pedido   
   LET lr_pedidos.num_list_preco = m_num_lista
   LET lr_pedidos.cod_repres = m_cod_repres
   LET lr_pedidos.cod_tip_carteira = m_tip_carteira
   LET lr_pedidos.cod_local_estoq = 'PROD_CIB'  

   INSERT INTO pedidos VALUES(lr_pedidos.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA PEDIDOS'
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION func018_ins_pd_itens()#
#-------------------------------#
 
   DEFINE lr_ped_itens      RECORD LIKE ped_itens.*  
   DEFINE l_transacao       INTEGER
   
   DECLARE cq_ped_itens CURSOR FOR  
   SELECT *
     FROM ped_itens
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido
   
   FOREACH cq_ped_itens INTO lr_ped_itens.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA PED_ITENS'
         RETURN FALSE 
      END IF
   
      LET lr_ped_itens.cod_empresa = m_empresa_dest

      LET l_transacao = func016_le_lista(m_empresa_dest,
          m_num_lista, m_cliente, lr_ped_itens.cod_item)
      
      IF l_transacao = 0 THEN
         LET m_msg = g_msg
         RETURN FALSE
      END IF
      
      SELECT pre_unit 
        INTO lr_ped_itens.pre_unit
        FROM desc_preco_item 
       WHERE cod_empresa = m_empresa_dest
         AND num_transacao = l_transacao
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO PRE�O UNIT�RIO DO ITEM '
         RETURN FALSE 
      END IF

      INSERT INTO ped_itens VALUES(lr_ped_itens.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA PED_ITENS'
         RETURN FALSE 
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func018_ins_info_compl()#
#--------------------------------#
 
   DEFINE lr_ped_info_compl      RECORD LIKE ped_info_compl.*  
   
   DECLARE cq_info CURSOR FOR  
   SELECT *
     FROM ped_info_compl
    WHERE empresa = m_empresa_orig
      AND pedido = m_pedido
   
   FOREACH cq_info INTO lr_ped_info_compl.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA PED_INFO_COMPL'
         RETURN FALSE 
      END IF
   
      LET lr_ped_info_compl.empresa = m_empresa_dest

      INSERT INTO ped_info_compl VALUES(lr_ped_info_compl.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA PED_INFO_COMPL'
         RETURN FALSE 
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION func018_ins_itens_texto()#
#---------------------------------#

   DEFINE lr_ins_itens_texto      RECORD LIKE ped_itens_texto.*  
   
   DECLARE cq_texto CURSOR FOR  
   SELECT *
     FROM ped_itens_texto
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido
   
   FOREACH cq_texto INTO lr_ins_itens_texto.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA PED_ITENS_TEXTO'
         RETURN FALSE 
      END IF
   
      LET lr_ins_itens_texto.cod_empresa = m_empresa_dest

      INSERT INTO ped_itens_texto VALUES(lr_ins_itens_texto.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA PED_ITENS_TEXTO'
         RETURN FALSE 
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION func018_ins_item_bobina()#
#---------------------------------#

   DEFINE lr_item_bobina      RECORD LIKE item_bobina_885.*  
   
   DECLARE cq_bobina CURSOR FOR  
   SELECT *
     FROM item_bobina_885
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido
   
   FOREACH cq_bobina INTO lr_item_bobina.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA ITEM_BOBINA_885'
         RETURN FALSE 
      END IF
   
      LET lr_item_bobina.cod_empresa = m_empresa_dest

      INSERT INTO item_bobina_885 VALUES(lr_item_bobina.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA ITEM_BOBINA_885'
         RETURN FALSE 
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION func018_ins_item_chapa()#
#--------------------------------#

   DEFINE lr_item_chapa      RECORD LIKE item_chapa_885.*  
   
   DECLARE cq_chapa CURSOR FOR  
   SELECT *
     FROM item_chapa_885
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido
   
   FOREACH cq_chapa INTO lr_item_chapa.*
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA ITEM_CHAPA_885'
         RETURN FALSE 
      END IF
   
      LET lr_item_chapa.cod_empresa = m_empresa_dest

      INSERT INTO item_chapa_885 VALUES(lr_item_chapa.*)
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA ITEM_CHAPA_885'
         RETURN FALSE 
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION func018_ins_tipo_pedido()#
#---------------------------------#

   DEFINE lr_tipo_pedido      RECORD LIKE tipo_pedido_885.*
  
   SELECT *
     INTO lr_tipo_pedido.*
     FROM tipo_pedido_885
    WHERE cod_empresa = m_empresa_orig
      AND num_pedido = m_pedido

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' LENDO TABELA TIPO_PEDIDO_885'
      RETURN FALSE 
   END IF
   
   LET lr_tipo_pedido.cod_empresa = m_empresa_dest

   INSERT INTO tipo_pedido_885 VALUES(lr_tipo_pedido.*)
   
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA tipo_pedido_885'
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION func018_ins_desc_nat()#
#------------------------------#

   INSERT INTO desc_nat_oper_885
    VALUES(m_empresa_dest, m_pedido,
           0,0,0,'N',0)
     
   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'ERRO ', m_erro CLIPPED,' INSERINDO TABELA DESC_NAT_OPER_885'
      RETURN FALSE 
   END IF
   
   RETURN TRUE

END FUNCTION
 