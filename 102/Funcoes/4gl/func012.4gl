#---------------------------------------------------------------#
#-------Objetivo: excluir título do CAP-------------------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#--------------------------parâmetros---------------------------#
# empresa centralizadora e numero do titulo                     #
#--------------------------retorno texto -----------------------#
#       null, para sucesso na operação;                         #
#       ou mensagem de erro, para falha na operação             #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          p_user                 CHAR(08)

END GLOBALS

DEFINE m_cod_empresa    LIKE ad_mestre.cod_empresa,
       m_num_ad         LIKE ad_mestre.num_ad,
       m_erro           CHAR(150),
       m_status         CHAR(10),
       m_count          INTEGER

DEFINE mr_ad_mestre     RECORD LIKE ad_mestre.*

#-----------------------------------------#
FUNCTION func012_estorna_cap(l_emp, l_num)#
#-----------------------------------------#

   DEFINE l_emp            LIKE ad_mestre.cod_empresa,
          l_num            LIKE ad_mestre.num_ad

   LET m_cod_empresa = l_emp
   LET m_num_ad = l_num

   SELECT * 
     INTO mr_ad_mestre.*
     FROM ad_mestre
    WHERE cod_empresa = m_cod_empresa
      AND num_ad = m_num_ad

   IF STATUS = 0 THEN
   ELSE
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' LENDO TABELA AD_MESTRE.'
      RETURN m_erro
   END IF

   LET m_erro = NULL
   
   CALL func012_deleta_titulo() 
   
   RETURN m_erro

END FUNCTION

#-------------------------------#
FUNCTION func012_deleta_titulo()#
#-------------------------------#
   
   DEFINE l_dat_pgto    LIKE ap.dat_pgto,
          l_num_ap      LIKE ap.num_ap,
          l_msg         LIKE audit_cap.desc_manut
   
   DECLARE cq_ad_ap CURSOR FOR
     SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = m_cod_empresa
       AND num_ad      = m_num_ad
      
   FOREACH cq_ad_ap INTO l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' LENDO TABELA AD_AP.'
         RETURN
      END IF
      
      SELECT dat_pgto
        INTO l_dat_pgto
        FROM ap
       WHERE cod_empresa = m_cod_empresa
         AND num_ap = l_num_ap
         AND ies_versao_atual = 'S'

      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET m_erro = 'Erro: ', STATUS USING '<<<<<<', ' Empresa: ', m_cod_empresa,
             'AD: ', m_num_ad USING '<<<<<<<<<', ' AP: ', l_num_ap USING '<<<<<<<<<'
            RETURN
         END IF
      END IF
         
      IF l_dat_pgto IS NOT NULL THEN
         LET m_status = l_num_ap
         LET m_erro = 'A AP ',m_status CLIPPED, ' JÁ ESTÁ PAGA. ESTORNO NÃO PERMITIDO'
         RETURN 
      END IF
      
      DELETE FROM ap
       WHERE cod_empresa = m_cod_empresa
         AND num_ap = l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AP.'
         RETURN
      END IF

      DELETE FROM ap_valores
       WHERE cod_empresa = m_cod_empresa
         AND num_ap = l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AP_VALORES.'
         RETURN
      END IF

      DELETE FROM ap_tip_desp
       WHERE cod_empresa = m_cod_empresa
         AND num_ap = l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AP_TIP_DESP.'
         RETURN
      END IF

      DELETE FROM lanc_cont_cap
       WHERE cod_empresa = m_cod_empresa
         AND ies_ad_ap   = '2'
         AND ies_tipo_lanc = 'C'
         AND num_ad_ap = l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA LANC_CONT_CAP.'
         RETURN
      END IF

      DELETE FROM ctb_lanc_ctbl_cap
       WHERE empresa = m_cod_empresa
         AND eh_ad_ap   = '2'
         AND num_ad_ap = l_num_ap

      IF STATUS <> 0 THEN
         LET m_status = STATUS
         LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CTB_LANC_CTBL_CAP.'
         RETURN
      END IF            
      
      LET m_status = l_num_ap
      LET l_msg = 'DELECAO DA AP ', m_status CLIPPED
      
      IF NOT func012_ins_audit(l_num_ap, '2', l_msg) THEN
         RETURN
      END IF
      
   END FOREACH
   
   DELETE FROM ad_ap
    WHERE cod_empresa = m_cod_empresa
      AND num_ad      = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AD_AP.'
      RETURN
   END IF

   DELETE FROM ad_mestre
    WHERE cod_empresa = m_cod_empresa
      AND num_ad      = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AD_MESTRE.'
      RETURN
   END IF

   LET m_status = m_num_ad
   LET l_msg = 'DELECAO DA AD ', m_status CLIPPED
      
   IF NOT func012_ins_audit(m_num_ad, '1', l_msg) THEN
      RETURN
   END IF

   DELETE FROM cap_ad_centro_custo
    WHERE empresa = m_cod_empresa
      AND num_ad      = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CAP_AD_CENTRO_CUSTO.'
      RETURN
   END IF

   DELETE FROM lanc_cont_cap
    WHERE cod_empresa = m_cod_empresa
      AND ies_ad_ap   = '1'
      AND ies_tipo_lanc = 'D'
      AND num_ad_ap = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA LANC_CONT_CAP.'
      RETURN
   END IF

   DELETE FROM ctb_lanc_ctbl_cap
    WHERE empresa = m_cod_empresa
      AND eh_ad_ap   = '1'
      AND num_ad_ap = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CTB_LANC_CTBL_CAP.'
      RETURN
   END IF            

   DELETE FROM ad_aen_4
    WHERE cod_empresa = m_cod_empresa
      AND num_ad      = m_num_ad

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA AD_AEN_4.'
      RETURN
   END IF

END FUNCTION

#----------------------------------------------------#
FUNCTION func012_ins_audit(l_num, l_ies_ad_ap, l_msg)#
#----------------------------------------------------#

   DEFINE l_num        INTEGER,
          l_ies_ad_ap  CHAR(01),
          l_seq        INTEGER,
          l_msg        LIKE audit_cap.desc_manut

   DEFINE l_audit      RECORD LIKE audit_cap.*
 
   SELECT MAX(num_seq)
     INTO l_seq
     FROM audit_cap
    WHERE cod_empresa = mr_ad_mestre.cod_empresa
      AND num_ad_ap = l_num
      AND ies_ad_ap = l_ies_ad_ap

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' LENDO TABELA AUDIT_CAP.'
      RETURN FALSE
   END IF
   
   IF l_seq IS NULL THEN
      LET l_seq = 0
   END IF
   
   LET l_seq = l_seq + 1    
            
   LET l_audit.cod_empresa = mr_ad_mestre.cod_empresa 
   LET l_audit.ies_tabela = '1'    
   LET l_audit.nom_usuario = p_user
   LET l_audit.num_ad_ap = l_num
   LET l_audit.ies_ad_ap = l_ies_ad_ap   
   LET l_audit.num_nf = mr_ad_mestre.num_nf      
   LET l_audit.ser_nf = mr_ad_mestre.ser_nf      
   LET l_audit.ssr_nf = mr_ad_mestre.ssr_nf      
   LET l_audit.cod_fornecedor = mr_ad_mestre.cod_fornecedor
   LET l_audit.data_manut = mr_ad_mestre.dat_emis_nf
   LET l_audit.num_lote_transf = mr_ad_mestre.num_lote_transf   
   LET l_audit.ies_manut = 'I'    
   LET l_audit.num_seq = l_seq    
   LET l_audit.desc_manut = l_msg 
   LET l_audit.hora_manut = CURRENT HOUR TO SECOND    

   INSERT INTO audit_cap
      VALUES(l_audit.*)
             
   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' INSERINDO TABELA AUDIT_CAP.'
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
