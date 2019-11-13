#---------------------------------------------------------------#
#-------Objetivo: ler parâmetros fiscais          --------------#
#---------------------------------------------------------------#
#--Obs: os parâmetros encontrados serão gravados na tabela------#
#------ temporária tributo_tmp_912 e pederão ser lidos pelo-----#
#------ programa que chamou essa função.                   -----#
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE g_msg               CHAR(150),
          g_tipo_sgbd         CHAR(003)
END GLOBALS

DEFINE m_cod_empresa          CHAR(02),
       p_user                 CHAR(08),
       p_status               SMALLINT,
       m_erro                 CHAR(10),
       m_msg                  CHAR(600),
       p_msg						      CHAR(600), 
       p_ies_tributo          SMALLINT,
       p_ies_tipo             CHAR(01),
       p_origem               CHAR(01),
       p_count                INTEGER,
       p_chave                CHAR(11),
       p_matriz               CHAR(24),
       p_tem_tributo          SMALLINT,
       p_regiao_fiscal        CHAR(10),
       p_query               CHAR(2000),
       p_trans_config        INTEGER

DEFINE p_cod_cliente          LIKE clientes.cod_cliente,
       p_cod_lin_prod         LIKE item.cod_lin_prod,    
       p_cod_item             LIKE item.cod_item,
       p_cod_lin_recei        LIKE item.cod_lin_recei,         
       p_cod_seg_merc         LIKE item.cod_seg_merc, 
       p_cod_cla_uso          LIKE item.cod_cla_uso,  
       p_cod_familia          LIKE item.cod_familia,  
       p_gru_ctr_estoq        LIKE item.gru_ctr_estoq,
       p_cod_cla_fisc         LIKE item.cod_cla_fisc, 
       p_cod_unid_med         LIKE item.cod_unid_med, 
       p_pes_unit             LIKE item.pes_unit,     
       p_fat_conver           LIKE item.fat_conver,    
       p_cod_uni_feder        LIKE cidades.cod_uni_feder,
       p_cod_cidade           LIKE cidades.cod_cidade,
       p_cod_nat_oper         LIKE obf_oper_fiscal.nat_oper_grp_desp,
       p_tributo_benef        LIKE obf_oper_fiscal.tributo_benef,
       p_seq_acesso           LIKE obf_ctr_acesso.sequencia_acesso,
       p_cod_tip_carteira     LIKE pedidos.cod_tip_carteira,
       p_ies_finalidade       LIKE pedidos.ies_finalidade,
       p_grp_classif_fisc     LIKE obf_grp_cl_fisc.grupo_classif_fisc,
       p_grp_fiscal_item      LIKE obf_grp_fisc_item.grupo_fiscal_item,
       p_micro_empresa        LIKE vdp_cli_parametro.tip_parametro,
       p_grp_fisc_cliente     LIKE obf_grp_fisc_cli.grp_fiscal_cliente


#------------------------------------#
# parãmetros: record abaixo          #
# Retorno: 'OK' para sucesso ou o    #
#   erro contido da variável M_MSG   #
#------------------------------------#
FUNCTION func021_par_fiscal(lr_param)#
#------------------------------------#
   
   DEFINE lr_param            RECORD
          cod_empresa         LIKE empresa.cod_empresa,
          cod_cliente         LIKE clientes.cod_cliente,
          cod_item            LIKE item.cod_item,
          cod_cidade          LIKE cidades.cod_cidade,
          cod_nat_oper        LIKE obf_oper_fiscal.nat_oper_grp_desp,
          origem              LIKE obf_oper_fiscal.origem,
          cod_tip_carteira    LIKE pedidos.cod_tip_carteira, 
          ies_finalidade      LIKE pedidos.ies_finalidade    
   END RECORD       
          
   LET m_cod_empresa = lr_param.cod_empresa
   LET p_cod_cliente = lr_param.cod_cliente
   LET p_cod_item = lr_param.cod_item
   LET p_cod_cidade = lr_param.cod_cidade
   LET p_cod_nat_oper = lr_param.cod_nat_oper
   LET p_origem = lr_param.origem #E/S
   LET p_cod_tip_carteira = lr_param.cod_tip_carteira
   LET p_ies_finalidade = lr_param.ies_finalidade
   
   WHENEVER ANY ERROR CONTINUE
   
   IF NOT func021_cria_tabelas() THEN
      RETURN m_msg
   END IF

   IF NOT func021_le_param_fisc() THEN
      RETURN m_msg
   END IF
   
   RETURN 'OK'
   
END FUNCTION

#-------------------------------#
FUNCTION  func021_cria_tabelas()#
#-------------------------------#

   DROP TABLE chave_tmp_912
   
   CREATE TEMP TABLE chave_tmp_912 (
      chave CHAR(11)
   );

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' criando tabela chave_tmp_912'
      RETURN FALSE
   END IF

   DROP TABLE tributo_tmp_912

   CREATE  TABLE tributo_tmp_912 (
      tributo_benef CHAR(11),
      trans_config  INTEGER
   );

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' criando tabela tributo_tmp_912'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#------------------------------#
FUNCTION func021_le_param_fisc()
#------------------------------#
   
   IF NOT func021_le_item()  THEN 
      RETURN FALSE	
   END IF 
   
   LET p_ies_tributo = TRUE
   LET m_msg = NULL
   
   DELETE FROM tributo_tmp_912
   
   LET p_ies_tipo = 'S'                   #S-Saida

   SELECT cod_uni_feder
     INTO p_cod_uni_feder
     FROM cidades 
    WHERE cod_cidade = p_cod_cidade

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo tabela cidades'
      RETURN FALSE
   END IF
        
   SELECT COUNT(tributo_benef)                 #Verifica se tem tribustos 
     INTO p_count                                #cadastrados
     FROM obf_oper_fiscal  
    WHERE empresa = m_cod_empresa
	  AND origem = p_origem
    AND nat_oper_grp_desp = p_cod_nat_oper

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' verificando tributos na tabela obf_oper_fiscal'
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      RETURN TRUE      
   END IF
   
   LET p_msg = NULL 
	   
   DECLARE cq_tributos	CURSOR FOR    
    SELECT a.tributo_benef
      FROM obf_oper_fiscal a, obf_tributo_benef b
     WHERE a.empresa           = m_cod_empresa
       AND a.origem            = p_origem
       AND a.nat_oper_grp_desp = p_cod_nat_oper
       AND b.empresa           = a.empresa 
       AND b.tributo_benef     = a.tributo_benef 
       AND b.ativo             IN ('S','A') 
     ORDER BY b.tip_config, b.prioridade   
	  
   FOREACH  cq_tributos INTO p_tributo_benef

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, 
             ' lendo tributos nas tabelas obf_oper_fiscal/ obf_tributo_benef'
         RETURN FALSE
      END IF

      LET p_tem_tributo = FALSE   
	 
      DECLARE cq_acesso CURSOR FOR
       SELECT sequencia_acesso
         FROM obf_ctr_acesso
        WHERE empresa         = m_cod_empresa
          AND controle_acesso = p_tributo_benef
          AND origem          = p_origem
        ORDER BY num_ctr_acesso DESC
      
      FOREACH cq_acesso INTO p_seq_acesso
      
         LET p_seq_acesso = p_seq_acesso CLIPPED
         
         IF LENGTH(p_seq_acesso) = 0 THEN
            CONTINUE FOREACH
         END IF
         
         CALL func021_pega_chave()

	       IF NOT func021_checa_tributo()  THEN 
	          RETURN FALSE	
         END IF 

   	     IF p_tem_tributo THEN	
	          EXIT FOREACH
         END IF 		 
                  
      END FOREACH

      IF NOT p_tem_tributo THEN                  
         LET p_msg = p_msg CLIPPED, 'TRIBUTO = ', p_tributo_benef,' SEM PARAMETROS FISCALIS \n'
 	       #LET p_ies_tributo = FALSE 	       
      END IF
      
   END FOREACH
   
   IF p_msg IS NOT NULL THEN
      LET m_msg = p_msg
   END IF
   
   RETURN p_ies_tributo
   
END FUNCTION

#----------------------------#
FUNCTION func021_pega_chave()
#----------------------------#

   DEFINE m_ind       SMALLINT,
          p_letra     CHAR(01)
   
   DELETE FROM chave_tmp_912
   INITIALIZE p_chave TO NULL
   
   FOR m_ind = 2 TO LENGTH(p_seq_acesso)
       
       LET p_letra = p_seq_acesso[m_ind]
       
       IF p_letra = '|' THEN
          IF p_chave IS NOT NULL THEN
             INSERT INTO chave_tmp_912 VALUES(p_chave)
             INITIALIZE p_chave TO NULL
          END IF
       ELSE
          LET p_chave = p_chave CLIPPED, p_letra
       END IF
   
   END FOR
      
END FUNCTION

#-------------------------------#
FUNCTION func021_checa_tributo()
#-------------------------------#

   DEFINE p_cheve_ok SMALLINT
   
   LET p_cheve_ok = FALSE
   LET p_matriz = 'SSSSSSSSSSSSSSSSSSSSSSSS'

   LET p_query = 
       "SELECT trans_config FROM obf_config_fiscal ",
       " WHERE empresa = '",m_cod_empresa,"' ",
       " AND origem  = '",p_origem,"' ",
       " AND tributo_benef = '",p_tributo_benef,"' "
       

   DECLARE cq_chave CURSOR FOR
    SELECT chave
      FROM chave_tmp_912
   
   FOREACH cq_chave INTO p_chave

      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela chave_tmp_912'
         RETURN FALSE
      END IF
         
      LET p_cheve_ok = TRUE
      
      CASE p_chave
      
      WHEN 'NAT_OPER' 
         LET p_query  = p_query CLIPPED, " AND nat_oper_grp_desp = '",p_cod_nat_oper,"' "
         LET p_matriz[1] = 'N'
      
      WHEN 'REGIAO' 
         IF NOT func021_le_obf_regiao() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_regiao = '",p_regiao_fiscal,"' "
         LET p_matriz[2] = 'N'

      WHEN 'ESTADO'
         LET p_query  = p_query CLIPPED, " AND estado = '",p_cod_uni_feder,"' "
         LET p_matriz[3] = 'N'

      WHEN 'MUNICIPIO' 
         LET p_query  = p_query CLIPPED, " AND municipio = '",p_cod_cidade,"' "
         LET p_matriz[4] = 'N'

      WHEN 'CARTEIRA' 
         LET p_query  = p_query CLIPPED, " AND carteira = '",p_cod_tip_carteira,"' "
         LET p_matriz[5] = 'N'

      WHEN 'FINALIDADE' 
         LET p_query  = p_query CLIPPED, " AND finalidade = '",p_ies_finalidade,"' "
         LET p_matriz[6] = 'N'

      WHEN 'FAMILIA_IT' 
         LET p_query  = p_query CLIPPED, " AND familia_item = '",p_cod_familia,"' "
         LET p_matriz[7] = 'N'

      WHEN 'GRP_ESTOQUE' 
         LET p_query  = p_query CLIPPED, " AND grupo_estoque = '",p_gru_ctr_estoq,"' "
         LET p_matriz[8] = 'N'

      WHEN 'GRP_CLASSIF' 
         IF NOT func021_le_obf_cl_fisc() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_classif = '",p_grp_classif_fisc,"' "
         LET p_matriz[9] = 'N'

      WHEN 'CLAS_FISC' 
         LET p_query  = p_query CLIPPED, " AND classif_fisc = '",p_cod_cla_fisc,"' "
         LET p_matriz[10] = 'N'

      WHEN 'LIN_PROD' 
         LET p_query  = p_query CLIPPED, " AND linha_produto = '",p_cod_lin_prod,"' "
         LET p_matriz[11] = 'N'

      WHEN 'LIN_REC' 
         LET p_query  = p_query CLIPPED, " AND linha_receita = '",p_cod_lin_recei,"' "
         LET p_matriz[12] = 'N'

      WHEN 'SEGTO_MERC' 
         LET p_query  = p_query CLIPPED, " AND segmto_mercado = '",p_cod_seg_merc,"' "
         LET p_matriz[13] = 'N'

      WHEN 'CLASSE_USO' 
         LET p_query  = p_query CLIPPED, " AND classe_uso = '",p_cod_cla_uso,"' "
         LET p_matriz[14] = 'N'

      WHEN 'UNID_MED' 
         LET p_query  = p_query CLIPPED, " AND unid_medida = '",p_cod_unid_med,"' "
         LET p_matriz[15] = 'N'

      WHEN 'GRP_ITEM' 
         IF NOT func021_le_obf_fisc_item() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grupo_fiscal_item = '",p_grp_fiscal_item,"' "
         LET p_matriz[17] = 'N'

      WHEN 'ITEM' 
         LET p_query  = p_query CLIPPED, " AND item = '",p_cod_item,"' "
         LET p_matriz[18] = 'N'

      WHEN 'MICRO_EMPR' 
         IF NOT func021_le_me() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND micro_empresa = '",p_micro_empresa,"' "
         LET p_matriz[19] = 'N'

      WHEN 'GRP_CLIENTE' 
         IF NOT func021_le_obf_fisc_cli() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_cliente = '",p_grp_fisc_cliente,"' "
         LET p_matriz[20] = 'N'

      WHEN 'CLIENTE' 
         LET p_query  = p_query CLIPPED, " AND cliente = '",p_cod_cliente,"' "
         LET p_matriz[21] = 'N'

      WHEN 'X'
      WHEN 'BONIF'
      WHEN 'VIA_TRANSP'
      
      OTHERWISE 
         LET p_cheve_ok = FALSE
  
   END CASE
   
   END FOREACH

   IF p_cheve_ok THEN

      LET p_query  = p_query CLIPPED, " AND matriz        = '",p_matriz,"' "
   
      PREPARE var_query FROM p_query   
      DECLARE cq_obf_cfg CURSOR FOR var_query

      FOREACH cq_obf_cfg INTO p_trans_config

         IF STATUS <> 0 THEN 
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' lendo dados da tabela obf_config_fiscal'
            RETURN FALSE
         END IF
         
         INSERT INTO tributo_tmp_912
          VALUES(p_tributo_benef, p_trans_config)

         IF STATUS <> 0 THEN 
            LET m_erro = STATUS USING '<<<<<'
            LET m_msg = 'Erro de status: ',m_erro
            LET m_msg = m_msg CLIPPED, ' inserindo dados na tabela tributo_tmp_912'
            RETURN FALSE
         END IF
      
         LET p_tem_tributo = TRUE
         EXIT FOREACH
      
   
      END FOREACH
   
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION func021_le_obf_regiao()
#-------------------------------#

   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = m_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = m_cod_empresa
         AND tributo_benef = p_tributo_benef
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
      END IF
   END IF

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo dados da tabela obf_regiao_fiscal'
      RETURN FALSE
   END IF
      
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION func021_le_obf_cl_fisc()
#-------------------------------#

   SELECT grupo_classif_fisc
     INTO p_grp_classif_fisc
     FROM obf_grp_cl_fisc
    WHERE empresa       = m_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND classif_fisc  = p_cod_cla_fisc
   
   IF STATUS = 100 THEN
      LET p_grp_classif_fisc = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela obf_grp_cl_fisc'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION func021_le_obf_fisc_item()
#---------------------------------#

   SELECT grupo_fiscal_item
     INTO p_grp_fiscal_item
     FROM obf_grp_fisc_item
    WHERE empresa       = m_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND item          = p_cod_item
   
   IF STATUS = 100 THEN
      LET p_grp_fiscal_item = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela obf_grp_fisc_item'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION func021_le_obf_fisc_cli()
#---------------------------------#

   SELECT grp_fiscal_cliente
     INTO p_grp_fisc_cliente
     FROM obf_grp_fisc_cli
    WHERE empresa       = m_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND cliente       = p_cod_cliente
   
   IF STATUS = 100 THEN
      LET p_grp_fisc_cliente = NULL
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS USING '<<<<<'
         LET m_msg = 'Erro de status: ',m_erro
         LET m_msg = m_msg CLIPPED, ' lendo dados da tabela obf_grp_fisc_cli:2'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------#
FUNCTION func021_le_item()
#-------------------------#

   SELECT cod_lin_prod,                                         
          cod_lin_recei,                                     
          cod_seg_merc,                                      
          cod_cla_uso,                                       
          cod_familia,                                       
          gru_ctr_estoq,                                     
          cod_cla_fisc,                                      
          cod_unid_med,
          pes_unit,
          fat_conver                                      
     INTO p_cod_lin_prod,                                    
          p_cod_lin_recei,                                   
          p_cod_seg_merc,                                    
          p_cod_cla_uso,                                     
          p_cod_familia,                                     
          p_gru_ctr_estoq,                                   
          p_cod_cla_fisc,                                    
          p_cod_unid_med,
          p_pes_unit,
          p_fat_conver                          
     FROM item                                               
    WHERE cod_empresa  = m_cod_empresa                       
      AND cod_item     = p_cod_item          

   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo tabela item'
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------#
FUNCTION func021_le_me()
#-----------------------#

   SELECT tip_parametro
     INTO p_micro_empresa
     FROM vdp_cli_parametro
    WHERE cliente   = p_cod_cliente 
      AND parametro = 'microempresa'
         
   IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo tabela vdp_cli_parametro'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


