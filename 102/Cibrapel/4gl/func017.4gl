#---------------------------------------------------------------#
#-------Objetivo: Gerar ordem de compa -------------------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#--------------------------parâmetros---------------------------#
#empresa, usuario, item, dt entrega, dt_abertura, qtd planej    #
# e dt emissão                                                  #                     
#--------------------------retorno texto -----------------------#
#       número da OC, para sucesso na operação;                 #
#       ou mensagem de erro, para falha na operação             #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   

END GLOBALS

DEFINE p_cod_empresa          CHAR(02),
       p_user                 CHAR(08)

DEFINE m_cod_item          CHAR(30),
       m_dat_entrega       DATE,
	     m_dat_abertura      DATE,
       m_qtd_planej        DECIMAL(10,3),
       m_dat_emissao       DATE,
       p_msg               CHAR(150),
       m_status            SMALLINT,
       p_erro              CHAR(10)

DEFINE p_dat_proces        DATE,
       p_hor_proces        CHAR(08),
       p_num_oc            INTEGER,
       p_num_processo      CHAR(19),
       m_gerar             CHAR(01)

DEFINE p_ordem_sup         RECORD LIKE ordem_sup.*

DEFINE m_gru_ctr_desp       LIKE item_sup.gru_ctr_desp,
       m_num_conta          LIKE item_sup.num_conta,
       m_cod_tip_despesa    LIKE item_sup.cod_tip_despesa,
       m_ies_tip_item       LIKE item.ies_tip_item,
       m_cod_progr          LIKE item_sup.cod_progr,
       m_cod_comprador      LIKE item_sup.cod_comprador,
       m_ies_tip_incid_ipi  LIKE item_sup.ies_tip_incid_ipi,
       m_cod_fiscal         LIKE item_sup.cod_fiscal,
       m_prx_num_oc         LIKE par_sup.prx_num_oc,
       m_pct_ipi            LIKE item.pct_ipi,
       m_ies_tip_incid_icms LIKE item_sup.ies_tip_incid_icms,
       m_cod_unid_med       LIKE item.cod_unid_med,
       m_qtd_lote_minimo    LIKE item_sup.qtd_lote_minimo,
       m_qtd_estoq_seg      LIKE item_sup.qtd_estoq_seg,
       p_qtd_dias           LIKE horizonte.qtd_dias_horizon,
       p_cod_horizon        LIKE item_man.cod_horizon,
       p_num_docum          LIKE ordem_sup.num_docum, 
       p_cod_fiscal_compl   LIKE item_sup_compl.cod_fiscal_compl,
       m_cod_local_estoq    LIKE item.cod_local_estoq,
       m_pct_refug          LIKE estrut_grade.pct_refug,
       m_grup_desp          LIKE item_sup.gru_ctr_desp,
       m_tip_desp           LIKE item_sup.cod_tip_despesa            

#--------------------------------#
FUNCTION func017_gera_oc(l_param)#
#--------------------------------#

   DEFINE l_param          RECORD
          cod_empresa       CHAR(02),
          cod_user          CHAR(08),
          cod_item          CHAR(15),
          dat_entrega       DATE,                   
          dat_abertura      DATE,                   
          qtd_planej        DECIMAL(10,3),          
          dat_emissao       DATE,
          gru_ctr_desp      LIKE item_sup.gru_ctr_desp,
          cod_tip_despesa   LIKE item_sup.cod_tip_despesa            
   END RECORD

   LET p_cod_empresa  = l_param.cod_empresa 
   LET p_user         = l_param.cod_user
   LET m_cod_item     = l_param.cod_item    
   LET m_dat_entrega  = l_param.dat_entrega 
   LET m_dat_abertura = l_param.dat_abertura
   LET m_qtd_planej   = l_param.qtd_planej  
   LET m_dat_emissao  = l_param.dat_emissao 
   LET m_grup_desp    = l_param.gru_ctr_desp
   LET m_tip_desp     = l_param.cod_tip_despesa

   LET p_msg = func017_consiste()
   
   IF p_msg IS NOT NULL THEN
      RETURN p_msg
   END IF
   
   IF func017_gerar() THEN
      LET p_msg = p_ordem_sup.num_oc
   END IF
   
   RETURN p_msg

END FUNCTION   

#--------------------------#
FUNCTION func017_consiste()#
#--------------------------#

   DEFINE l_ctr_estoq CHAR(01)
   
   IF p_cod_empresa IS NULL OR 
      m_cod_item IS NULL OR 
      m_dat_entrega IS NULL OR 
      m_qtd_planej IS NULL OR 
      m_qtd_planej = 0 OR 
      m_dat_emissao IS NULL THEN
      RETURN 'PARÂMETRO OBRIGATÓRIO NÃO ENVIADO.'    
   END IF

   SELECT ies_ctr_estoque                                              
     INTO l_ctr_estoq                                                      
     FROM item                                                             
    WHERE cod_empresa = p_cod_empresa                                      
      AND cod_item = m_cod_item                                            
      AND ies_situacao =  'A'                                              
                                                                       
   IF STATUS = 100 THEN                                                    
      RETURN 'PRODUTO INATIVO OU INEXISTENTE NO LOGIX.'               
   END IF                                                                  
                                                                       
   IF STATUS <> 0 THEN                                                     
      LET p_erro = STATUS                                                  
      LET p_msg = '	ITEM:',m_cod_item CLIPPED,                             
                  ' ERRO ', p_erro CLIPPED,' LENDO TABELA ITEM.'            
      RETURN p_msg                                                         
   END IF                                                                  
                                                                           
   IF l_ctr_estoq = 'N' THEN                                               
      RETURN 'PRODUTO NÃO É UM ITEM DE ESTOQUE.'                      
   END IF                                                                  
                                           
   RETURN NULL

END FUNCTION   

#-----------------------#
FUNCTION func017_gerar()#
#-----------------------#

   IF NOT func017_le_item_sup() THEN
      RETURN FALSE
   END IF
   
   IF m_grup_desp IS NOT NULL THEN
      LET m_gru_ctr_desp = m_grup_desp
   END IF

   IF m_tip_desp IS NOT NULL THEN
      LET m_cod_tip_despesa = m_tip_desp
   END IF
   
   IF NOT func017_le_par_compl() THEN
      RETURN FALSE
   END IF 
   
   IF NOT func017_prx_num_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT func017_insere_estrut_oc() THEN
      RETURN FALSE
   END IF

   IF m_pct_refug IS NULL THEN
      LET m_pct_refug = 0
   END IF
   
   LET m_qtd_planej = m_qtd_planej + m_pct_refug
   
   IF NOT func017_insere_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT func017_insere_prog_oc() THEN
      RETURN FALSE
   END IF

   IF NOT func017_insere_dest_oc() THEN
      RETURN FALSE
   END IF
   
   IF NOT func017_ins_ordem_sup_compl() THEN
      RETURN FALSE
   END IF

   IF NOT func017_ins_orden_sup_audit() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------#
 FUNCTION func017_le_item_sup()
#-----------------------------#
   
   SELECT cod_comprador,
          cod_progr,
          gru_ctr_desp,
          num_conta,
          cod_tip_despesa,
          ies_tip_incid_icms,
          ies_tip_incid_ipi,
          cod_fiscal,
          qtd_lote_minimo,
          qtd_estoq_seg
     INTO m_cod_comprador,
          m_cod_progr,
          m_gru_ctr_desp,
          m_num_conta,
          m_cod_tip_despesa,
          m_ies_tip_incid_icms,
          m_ies_tip_incid_ipi,
          m_cod_fiscal,
          m_qtd_lote_minimo,
          m_qtd_estoq_seg
     FROM item_sup
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS = 100 THEN
      LET p_msg = 'ITEM ',m_cod_item, ' NAO CADASTRADO NA TABELA ITEM_SUP.'
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET p_erro = STATUS
         LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA ITEM_SUP'
         RETURN FALSE
      END IF
   END IF

   IF m_num_conta IS NULL THEN
      LET m_num_conta = 0
   END IF

   IF m_gru_ctr_desp IS NULL THEN 
      LET m_gru_ctr_desp = 0
   END IF

   SELECT cod_fiscal_compl
     INTO p_cod_fiscal_compl
     FROM item_sup_compl
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET p_cod_fiscal_compl = NULL
   END IF

   SELECT cod_local_estoq
     INTO m_cod_local_estoq
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET m_cod_local_estoq = NULL
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION func017_le_par_compl()
#------------------------------#

   SELECT pct_ipi, 
          cod_unid_med
     INTO m_pct_ipi, 
          m_cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS DA TABELA ITEM'
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
 FUNCTION func017_prx_num_oc()
#----------------------------#

   SELECT prx_num_oc
     INTO m_prx_num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS NA TABELA PAR_SUP'
      RETURN FALSE
   END IF

   IF m_prx_num_oc IS NULL THEN
      LET m_prx_num_oc = 0
   END IF
   
   UPDATE par_sup
      SET prx_num_oc = prx_num_oc + 1
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' ATUALIZANDO DADOS NA TABELA PAR_SUP'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION func017_insere_estrut_oc()
#-----------------------------------#


   DEFINE l_pct_refug          LIKE estrut_grade.pct_refug,
          p_cod_item_compon    LIKE estrutura.cod_item_compon,
          p_qtd_necessaria     LIKE estrutura.qtd_necessaria,
		      p_estrut_ordem_sup   RECORD LIKE estrut_ordem_sup.*

   
   LET m_pct_refug = null
      
   DECLARE cq_temp CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria,
           pct_refug
      FROM estrut_grade
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = m_cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= today) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= today )OR
            (today BETWEEN dat_validade_ini AND dat_validade_fim))
     ORDER BY parametros
       
   FOREACH cq_temp INTO 
           p_cod_item_compon,
           p_qtd_necessaria,
           l_pct_refug

	   IF STATUS <> 0 THEN
		  LET p_erro = STATUS
		  LET p_msg = 'ERRO ', p_erro CLIPPED,' LENDO DADOS NA TABELA ESTRUT_GRADE'
		  RETURN FALSE 
	   END IF
     
     IF m_pct_refug IS NULL THEN
        LET m_pct_refug = l_pct_refug
     END IF
     
	   LET p_estrut_ordem_sup.cod_empresa      = p_cod_empresa
	   LET p_estrut_ordem_sup.num_oc           = m_prx_num_oc
	   LET p_estrut_ordem_sup.cod_item_comp    = p_cod_item_compon
	   LET p_estrut_ordem_sup.qtd_necessaria   = p_qtd_necessaria + l_pct_refug
	   LET p_estrut_ordem_sup.cus_unit_compon  = NULL
	   
	   INSERT INTO estrut_ordem_sup VALUES (p_estrut_ordem_sup.*)

	   IF STATUS <> 0 THEN
		  LET p_erro = STATUS
		  LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ESTRUT_ORDEM_SUP'
		  RETURN FALSE 
	   END IF
           
   END FOREACH
      
   RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION func017_insere_oc()
#---------------------------#
   
   DEFINE l_cod_progr   LIKE programador.cod_progr
   
   LET p_ordem_sup.cod_empresa        = p_cod_empresa
   LET p_ordem_sup.num_oc             = m_prx_num_oc
   LET p_ordem_sup.num_versao         = 1
   LET p_ordem_sup.dat_ref_cotacao    = NULL
   LET p_ordem_sup.num_versao_pedido  = 0
   LET p_ordem_sup.ies_versao_atual   = 'S'
   LET p_ordem_sup.cod_item           = m_cod_item
   LET p_ordem_sup.num_pedido         = 0
   LET p_ordem_sup.ies_situa_oc       = 'A'
   LET p_ordem_sup.ies_origem_oc      = 'C'
   LET p_ordem_sup.ies_item_estoq     = 'S' 
   LET p_ordem_sup.ies_imobilizado    = 'N'
   LET p_ordem_sup.cod_unid_med       = m_cod_unid_med
   LET p_ordem_sup.dat_emis           = m_dat_emissao
   LET p_ordem_sup.qtd_solic          = m_qtd_planej
   LET p_ordem_sup.dat_entrega_prev   = m_dat_entrega
   LET p_ordem_sup.fat_conver_unid    = 1
   LET p_ordem_sup.qtd_recebida       = 0
   LET p_ordem_sup.pre_unit_oc        = 0
   LET p_ordem_sup.pct_ipi            = m_pct_ipi
   LET p_ordem_sup.cod_moeda          = 0
   LET p_ordem_sup.cod_fornecedor     = ' '
   LET p_ordem_sup.cnd_pgto           = 0
   LET p_ordem_sup.cod_mod_embar      = 0
   LET p_ordem_sup.num_docum          = 'POL0654'
   LET p_ordem_sup.gru_ctr_desp       = m_gru_ctr_desp
   LET p_ordem_sup.cod_secao_receb    = m_cod_local_estoq
   LET p_ordem_sup.cod_progr          = m_cod_progr
   LET p_ordem_sup.cod_comprador      = m_cod_comprador
   LET p_ordem_sup.pct_aceite_dif     = 0
   LET p_ordem_sup.ies_tip_entrega    = 'D'
   LET p_ordem_sup.ies_liquida_oc     = '2'
   LET p_ordem_sup.dat_abertura_oc    = m_dat_abertura
   LET p_ordem_sup.num_oc_origem      = m_prx_num_oc
   LET p_ordem_sup.qtd_origem         = m_qtd_planej
   LET p_ordem_sup.ies_tip_incid_ipi  = m_ies_tip_incid_ipi
   LET p_ordem_sup.ies_tip_incid_icms = m_ies_tip_incid_icms
   LET p_ordem_sup.cod_fiscal         = m_cod_fiscal
   LET p_ordem_sup.cod_tip_despesa    = m_cod_tip_despesa
   LET p_ordem_sup.ies_insp_recebto   = '4'
   LET p_ordem_sup.dat_origem         = p_ordem_sup.dat_entrega_prev

   INSERT INTO ordem_sup VALUES (p_ordem_sup.*)

   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION


#--------------------------------#
 FUNCTION func017_insere_prog_oc()
#--------------------------------#

   DEFINE p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*

   LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
   LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
   LET p_prog_ordem_sup.num_versao       = p_ordem_sup.num_versao
   LET p_prog_ordem_sup.num_prog_entrega = 1
   LET p_prog_ordem_sup.ies_situa_prog   = 'F'
   LET p_prog_ordem_sup.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.qtd_solic        = p_ordem_sup.qtd_solic
   LET p_prog_ordem_sup.qtd_recebida     = p_ordem_sup.qtd_recebida
   LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_entrega_prev
   LET p_prog_ordem_sup.dat_palpite      = NULL

   INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA PROG_ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------#
 FUNCTION func017_insere_dest_oc()
#--------------------------------#

   DEFINE p_dest_ordem_sup    RECORD LIKE dest_ordem_sup.*
   DEFINE l_tipo_sgbd         CHAR(03)
   
   LET l_tipo_sgbd = LOG_getCurrentDBType()
   
   LET p_dest_ordem_sup.cod_empresa        = p_ordem_sup.cod_empresa
   LET p_dest_ordem_sup.num_oc             = p_ordem_sup.num_oc
   LET p_dest_ordem_sup.cod_area_negocio   = 0
   LET p_dest_ordem_sup.cod_lin_negocio    = 0
   LET p_dest_ordem_sup.pct_particip_comp  = 100
   LET p_dest_ordem_sup.cod_secao_receb    = p_ordem_sup.cod_secao_receb
   LET p_dest_ordem_sup.num_conta_deb_desp = m_num_conta
   LET p_dest_ordem_sup.qtd_particip_comp  = p_ordem_sup.qtd_solic
   LET p_dest_ordem_sup.num_docum          = p_ordem_sup.num_docum
   LET p_dest_ordem_sup.num_transac        = 0
   
   IF l_tipo_sgbd <> 'MSV' THEN
      INSERT INTO dest_ordem_sup VALUES (p_dest_ordem_sup.*)
   ELSE
      INSERT INTO dest_ordem_sup(
         cod_empresa,       
         num_oc,            
         cod_area_negocio,  
         cod_lin_negocio,   
         pct_particip_comp, 
         cod_secao_receb,   
         num_conta_deb_desp,
         qtd_particip_comp, 
         num_docum) 
      VALUES(p_dest_ordem_sup.cod_empresa,        
             p_dest_ordem_sup.num_oc,            
             p_dest_ordem_sup.cod_area_negocio,  
             p_dest_ordem_sup.cod_lin_negocio,   
             p_dest_ordem_sup.pct_particip_comp, 
             p_dest_ordem_sup.cod_secao_receb,   
             p_dest_ordem_sup.num_conta_deb_desp,
             p_dest_ordem_sup.qtd_particip_comp, 
             p_dest_ordem_sup.num_docum)         
   END IF                  
   
   IF STATUS <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA DEST_ORDEM_SUP'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#-------------------------------------#
FUNCTION func017_ins_ordem_sup_compl()#
#-------------------------------------#

   DEFINE p_ordem_sup_compl RECORD LIKE ordem_sup_compl.*
   
   LET p_ordem_sup_compl.cod_empresa        = p_ordem_sup.cod_empresa #   char(2)        
   LET p_ordem_sup_compl.num_oc             = p_ordem_sup.num_oc      #   decimal(9,0)   
   LET p_ordem_sup_compl.val_item_moeda     = 0                       #   decimal(17,6)  
   LET p_ordem_sup_compl.num_lista          = NULL                    #   decimal(9,0)   
   LET p_ordem_sup_compl.nom_fabricante     = NULL                    #   char(30)       
   LET p_ordem_sup_compl.cod_ref_item       = NULL                    #   char(25)       
   LET p_ordem_sup_compl.nom_apelido        = NULL                    #   char(20)       
   LET p_ordem_sup_compl.cod_subregiao      = NULL                    #   decimal(5,0)   
   LET p_ordem_sup_compl.ins_estadual       = NULL                    #   char(16)       
   LET p_ordem_sup_compl.ies_tip_contrat_mp = NULL                    #   char(1)        
   LET p_ordem_sup_compl.cod_praca          = NULL                    #   decimal(5,0)   
   LET p_ordem_sup_compl.cod_fiscal_compl   = 0                       #   integer        
   LET p_ordem_sup_compl.possui_remito      = NULL                    #   char(1)        
   LET p_ordem_sup_compl.tip_compra         = NULL                    #   char(1)        
   LET p_ordem_sup_compl.oc_contrato        = NULL                    #   decimal(9,0)   
   LET p_ordem_sup_compl.val_tot_contrato   = NULL                    #   decimal(17,20 

   IF p_cod_fiscal_compl IS NULL THEN
      LET p_ordem_sup_compl.cod_fiscal_compl = 0
   ELSE
      LET p_ordem_sup_compl.cod_fiscal_compl = p_cod_fiscal_compl
   END IF

   IF sup0290_sistema_argentino() THEN
      LET p_ordem_sup_compl.possui_remito = "S"
      LET p_ordem_sup_compl.tip_compra    = "S"
   END IF

   INSERT INTO ordem_sup_compl VALUES (p_ordem_sup_compl.*)
   
   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP_COMPL'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

#--------------------------------------#
 FUNCTION func017_ins_orden_sup_audit()#
#--------------------------------------#

   DEFINE p_ordem_sup_audit RECORD LIKE ordem_sup_audit.*
   
   LET p_ordem_sup_audit.cod_empresa    = p_ordem_sup.cod_empresa
   LET p_ordem_sup_audit.num_oc         = p_ordem_sup.num_oc
   LET p_ordem_sup_audit.ies_tipo_audit = 1
   LET p_ordem_sup_audit.nom_usuario    = p_user  
   LET p_ordem_sup_audit.dat_proces     = p_dat_proces
   LET p_ordem_sup_audit.hor_operac     = p_hor_proces

   INSERT INTO ordem_sup_audit VALUES (p_ordem_sup_audit.*)

   IF sqlca.sqlcode <> 0 THEN
      LET p_erro = STATUS
      LET p_msg = 'ERRO ', p_erro CLIPPED,' INSERINDO DADOS NA TABELA ORDEM_SUP_AUDIT'
      RETURN FALSE 
   END IF

   RETURN  TRUE

END FUNCTION

