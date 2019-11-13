#-----------------------------------------------------------#
#-------Objetivo: ler lista de preço            ------------#
#--------------------------parâmetros-----------------------#
# númro da lista, cod_cliente e cod_item                    #
#--------------------------retorno texto--------------------#
#número de transação da tabela ou zero se não encontrar     #
#-----------------------------------------------------------#
# no caso de Erro, uma mensagem ficará armazenada na variá- #
# global g_msg e poderá ser exibida pelo programa chamador; #
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

DEFINE p_cod_lin_prod       LIKE item.cod_lin_prod,
       p_cod_lin_recei      LIKE item.cod_lin_recei,
       p_cod_seg_merc       LIKE item.cod_seg_merc,
       p_cod_cla_uso        LIKE item.cod_cla_uso,
       p_num_lista          LIKE desc_preco_item.num_list_preco,
       p_cod_cliente        LIKE desc_preco_item.cod_cliente,
       p_cod_item           LIKE desc_preco_item.cod_item,
       p_cod_uni_feder      LIKE cidades.cod_uni_feder
          
DEFINE m_num_transac        INTEGER 

#-----------------------------------------------------#
FUNCTION func016_le_lista(l_emp, l_num, l_cli, l_item)#
#-----------------------------------------------------#
   
   DEFINE l_emp                CHAR(02),
          l_num                INTEGER,
          l_cli                CHAR(15),
          l_item               CHAR(15)
   
   LET p_cod_empresa = l_emp
   LET p_num_lista = l_num
   LET p_cod_cliente = l_cli
   LET p_cod_item = l_item
   LET g_msg = NULL
   LET m_num_transac = 0

   SELECT a.cod_uni_feder INTO p_cod_uni_feder                
     FROM cidades a, clientes b
    WHERE a.cod_cidade = b.cod_cidade
      AND b.cod_cliente = p_cod_cliente
   
   IF STATUS <> 0 THEN
      LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO UF DO CLIENTE ', p_cod_cliente
   ELSE
      CALL func016_le_desc_preco()
   END IF
   
   RETURN m_num_transac

END FUNCTION

#-------------------------------#
FUNCTION func016_le_desc_preco()#
#-------------------------------#

 LET m_num_transac = 0
 
 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (cod_uni_feder = " " OR cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = 0 
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND desc_preco_item.cod_item       = p_cod_item
     
   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder = " " OR         
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso   
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder = " " OR         
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0               
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder = " " OR         
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0               
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder = " " OR         
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0               
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder = " " OR         
          desc_preco_item.cod_uni_feder IS NULL)
     AND desc_preco_item.cod_lin_prod   = 0             
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0               
     AND desc_preco_item.cod_cliente    = p_cod_cliente
     AND (desc_preco_item.cod_item      IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND desc_preco_item.cod_item       = p_cod_item
 
   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL  OR
          desc_preco_item.cod_uni_feder = "  ") 
     AND desc_preco_item.cod_lin_prod   = 0
     AND desc_preco_item.cod_lin_recei  = 0
     AND desc_preco_item.cod_seg_merc   = 0
     AND desc_preco_item.cod_cla_uso    = 0
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND desc_preco_item.cod_item       = p_cod_item

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ") 
 
   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0             
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0             
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND desc_preco_item.cod_uni_feder  = p_cod_uni_feder
     AND desc_preco_item.cod_lin_prod   = 0             
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL  OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = p_cod_cla_uso
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ") 
 
   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = p_cod_seg_merc
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

  SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = p_cod_lin_recei
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = p_cod_lin_prod
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

 SELECT num_transacao
   INTO m_num_transac
   FROM desc_preco_item
   WHERE desc_preco_item.cod_empresa    = p_cod_empresa
     AND desc_preco_item.num_list_preco = p_num_lista
     AND (desc_preco_item.cod_uni_feder  IS NULL OR
          desc_preco_item.cod_uni_feder = "  ")
     AND desc_preco_item.cod_lin_prod   = 0              
     AND desc_preco_item.cod_lin_recei  = 0              
     AND desc_preco_item.cod_seg_merc   = 0             
     AND desc_preco_item.cod_cla_uso    = 0            
     AND (desc_preco_item.cod_cliente   IS NULL OR
          desc_preco_item.cod_cliente   = "               ")
     AND (desc_preco_item.cod_item       IS NULL OR
          desc_preco_item.cod_item      = "               ") 

   IF STATUS = 0 THEN 
      RETURN 
   ELSE
      IF STATUS <> 100 THEN
         LET g_msg = 'ERRO ',STATUS USING '<<<<<<', 'LENDO TABELA DESC_PRECO_ITEM'
         RETURN
      END IF
   END IF

   LET m_num_transac = 0

   RETURN TRUE
   
 END FUNCTION
