#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: kpi10016y.4gl                                           #
# OBJETIVO: GRAVA TIPO DE DESPESA NA TABELA HLD                     #
# AUTOR...: IVO                                                     #
# DATA....: 05/05/17                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
    DEFINE p_cod_empresa   LIKE empresa.cod_empresa,
           p_user          LIKE usuarios.cod_usuario,
           p_status        SMALLINT,
           p_den_empresa   VARCHAR(36),
           p_versao        CHAR(18)
END GLOBALS

DEFINE m_num_ad            INTEGER,
       m_num_doc           CHAR(40),
       m_cod_empresa       CHAR(02)

#-------------------#
FUNCTION kpi10016y()#
#-------------------#
          
   IF LOG_initApp("PADRAO") <> 0 THEN
      RETURN
   END IF

   #CALL LOG_connectDatabase("DEFAULT")

   WHENEVER ANY ERROR CONTINUE

   LET p_versao = "kpi10016y-12.00   "
   
   CALL kpi10016y_processa()
    
END FUNCTION

#----------------------------#
FUNCTION kpi10016y_processa()#
#----------------------------#
      
   DECLARE cq_hld CURSOR WITH HOLD FOR
    SELECT hld_numdoc, hld_empres
      FROM hld
     WHERE hld_livre0 IS NULL
   
   FOREACH cq_hld INTO m_num_doc, m_cod_empresa
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','HLD')
         EXIT FOREACH
      END IF
              
      CALL log085_transacao("BEGIN")
      
      LET m_num_ad = m_num_doc
      
      IF NOT kpi10016y_atualiza_hld() THEN
         CALL log085_transacao("ROLLBACK")
         EXIT FOREACH
      END IF
      
      CALL log085_transacao("COMMIT")
      
   END FOREACH
   
END FUNCTION

#--------------------------------#
FUNCTION kpi10016y_atualiza_hld()#
#--------------------------------#
   
   DEFINE l_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa
   
   SELECT cod_tip_despesa
     INTO l_cod_tip_despesa
     FROM ad_mestre
    WHERE cod_empresa = m_cod_empresa
      AND num_ad = m_num_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','AD_MESTRE')
      RETURN FALSE
   END IF
    
   UPDATE hld
      SET hld_livre0 = l_cod_tip_despesa
    WHERE hld_empres = m_cod_empresa
      AND hld_numdoc = m_num_doc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','HLD')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
      