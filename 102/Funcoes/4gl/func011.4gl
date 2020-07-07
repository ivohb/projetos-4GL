#---------------------------------------------------------------#
#-------Objetivo: excluir título do CRE-------------------------#
#--Obs: a rotina que a chama deve ter uma transação aberta------#
#--------------------------parâmetros---------------------------#
# empresa centralizadora, numero do titulo e tipo               #
#--------------------------retorno texto -----------------------#
#       null, para sucesso na operação;                         #
#       ou mensagem de erro, para falha na operação             #
#---------------------------------------------------------------#

DATABASE logix

GLOBALS
   
   DEFINE p_cod_empresa          CHAR(02),
          p_user                 CHAR(08)

END GLOBALS

DEFINE m_cod_empresa    LIKE docum.cod_empresa,
       m_num_docum      LIKE docum.num_docum,
       m_tipo           LIKE docum.ies_tip_docum,
       m_erro           CHAR(150),
       m_status         CHAR(10),
       m_count          INTEGER


#-------------------------------------------------#
FUNCTION func011_estorna_cre(l_emp, l_num, l_tipo)#
#-------------------------------------------------#

   DEFINE l_emp            LIKE docum.cod_empresa,
          l_num            LIKE docum.num_docum,
          l_tipo           LIKE docum.ies_tip_docum

   LET m_cod_empresa = l_emp
   LET m_num_docum = l_num
   LET m_tipo = l_tipo
   
   SELECT 1 FROM docum
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS = 0 THEN
   ELSE
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' LENDO TABELA DOCUM.'
      RETURN m_erro
   END IF
      
   SELECT COUNT(*)
     INTO m_count
     FROM docum_pgto
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS = 0 THEN
   ELSE
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' LENDO TABELA DOCUM_PGTO.'
      RETURN m_erro
   END IF
   
   IF m_count > 0 THEN
      LET m_erro = 'TITULO QUE CONTÉM PAGAMENTO NÃO PODE SER ESTORNADO.'
      RETURN m_erro
   END IF

   LET m_erro = NULL
   
   CALL func011_deleta_titulo() 
   
   RETURN m_erro

END FUNCTION

#-------------------------------#
FUNCTION func011_deleta_titulo()#
#-------------------------------#

   DELETE FROM docum
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA DOCUM.'
      RETURN
   END IF
      
   DELETE FROM docum_port
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA DOCUM_PORT.'
      RETURN
   END IF
      
   DELETE FROM cre_doc_port_compl
    WHERE empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CRE_DOC_PORT_COMPL.'
      RETURN
   END IF
   
   DELETE FROM cre_info_adic_doc
    WHERE empresa = m_cod_empresa
      AND docum = m_num_docum
      AND tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CRE_INFO_ADIC_DOC.'
      RETURN
   END IF

   DELETE FROM credcad_cod_cli
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA CREDCAD_COD_CLI.'
      RETURN
   END IF

   DELETE FROM docum_aen
    WHERE cod_empresa = m_cod_empresa
      AND num_docum = m_num_docum
      AND ies_tip_docum = m_tipo

   IF STATUS <> 0 THEN
      LET m_status = STATUS
      LET m_erro = 'ERRO ',m_status, ' DELETANDO TABELA DOCUM_AEN.'
      RETURN
   END IF

END FUNCTION
 
   
