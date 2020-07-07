#---------------------------------------------------------------#
#-------Objetivo: Excluir nota de entrada         --------------#
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
       m_num_ar               INTEGER,
       m_num_nf               INTEGER,           
       m_ser_nf               CHAR(03),           
       m_ssr_nf               INTEGER,           
       m_ies_especie_nf       CHAR(03),   
       m_cod_fornecedor       CHAR(15)
          
#-------------------------------------#
# parãmetros: empresa e num_aviso_rec #
# Retorno: 'OK' para sucesso ou o     #
#   erro contido da variável M_MSG    #
#-------------------------------------#
FUNCTION cdv2020_exclui_nota(lr_param)#
#-------------------------------------#

   DEFINE lr_param            RECORD
          cod_empresa         LIKE empresa.cod_empresa,
          num_ar              LIKE nf_sup.num_aviso_rec
   END RECORD
   
   LET m_cod_empresa = lr_param.cod_empresa
   LET m_num_ar = lr_param.num_ar
   
   IF NOT cdv2020_checa_nf() THEN
      RETURN m_msg
   END IF
   
   IF NOT cdv2020_deleta_tabs() THEN
      RETURN m_msg
   END IF
   
   RETURN 'OK'

END FUNCTION
   
#--------------------------#
FUNCTION cdv2020_checa_nf()#
#--------------------------#
   
   DEFINE l_ies_incl_cap CHAR(01)
   
   SELECT ies_incl_cap,
          num_nf,          
          ser_nf,          
          ssr_nf,          
          ies_especie_nf,  
          cod_fornecedor    
     INTO l_ies_incl_cap,
          m_num_nf,          
          m_ser_nf,          
          m_ssr_nf,          
          m_ies_especie_nf,  
          m_cod_fornecedor       
     FROM nf_sup 
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' lendo registro na tabela nf_sup.'
      RETURN FALSE
   END IF
   
   IF l_ies_incl_cap = 'S' THEN
      LET m_msg = 'NF já foi integrada com o CAP.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION cdv2020_deleta_tabs()#
#-----------------------------#

   DELETE FROM nf_sup
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela nf_sup.'
      RETURN FALSE
   END IF

   DELETE FROM vencimento_nff
    WHERE cod_empresa = m_cod_empresa
      AND num_nf = m_num_nf                     
      AND ser_nf = m_ser_nf          
      AND ssr_nf = m_ssr_nf                    
      AND espc_nota_fiscal = m_ies_especie_nf
      AND cod_fornecedor = m_cod_fornecedor

    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela vencimento_nff.'
      RETURN FALSE
   END IF

   DELETE FROM audit_ar
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela audit_ar.'
      RETURN FALSE
   END IF

   DELETE FROM nf_sup_erro
    WHERE empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela nf_sup_erro.'
      RETURN FALSE
   END IF

   DELETE FROM aviso_rec_compl
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela aviso_rec_compl.'
      RETURN FALSE
   END IF
   
   DELETE FROM aviso_rec
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela aviso_rec.'
      RETURN FALSE
   END IF

   DELETE FROM dest_aviso_rec
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela dest_aviso_rec.'
      RETURN FALSE
   END IF

   DELETE FROM aviso_rec_compl_sq
    WHERE cod_empresa = m_cod_empresa
      AND num_aviso_rec = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela aviso_rec_compl_sq.'
      RETURN FALSE
   END IF

   DELETE FROM sup_par_ar
    WHERE empresa = m_cod_empresa
      AND aviso_recebto = m_num_ar
 
    IF STATUS <> 0 THEN
      LET m_erro = STATUS USING '<<<<<'
      LET m_msg = 'Erro de status: ',m_erro
      LET m_msg = m_msg CLIPPED, ' deletando registro da tabela sup_par_ar.'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
   