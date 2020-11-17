#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1397                                                            #
# OBJETIVO: PONTOS DE ENTRADA MAN10021                                         #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 21/07/2020                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_versao               CHAR(18),
          comando                CHAR(080),
          m_comando              CHAR(080),
          p_caminho              CHAR(150),
          m_caminho              CHAR(150),
          g_tipo_sgbd            CHAR(003)
END GLOBALS

DEFINE m_num_om                  INTEGER,
       m_om_padrao               INTEGER,
       m_msg                     VARCHAR(120),
       m_count                   INTEGER

MAIN   

   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      CALL pol1397_controle()
   END IF
         
END MAIN

#--------------------------#
FUNCTION pol1397_controle()#
#--------------------------#

END FUNCTION

#------------------------------------#
FUNCTION vdp30100y_before_processar()#
#------------------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   
   LET m_om_padrao = 0
   
   SELECT val_parametro 
     INTO m_om_padrao
     FROM log_val_parametro 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'num_ult_om'

   IF STATUS = 100 OR m_om_padrao IS NULL THEN
      LET m_om_padrao = 0
   ELSE 
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS USING '<<<<<<<','\n',
                     ' lendo tabela log_val_parametro\n ',
                     'EPL vdp30100y_before_processar.'
         CALL log0030_mensagem(m_msg,'info')
         RETURN
      END IF
   END IF

   SELECT num_ult_om
     INTO m_num_om
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ',STATUS USING '<<<<<<<','\n',
                  ' lendo tabela par_vdp\n ',
                  'EPL vdp30100y_before_processar.'
      CALL log0030_mensagem(m_msg,'info')
      RETURN
   END IF

   IF m_num_om IS NULL THEN
      LET m_num_om = 0
   END IF

   IF m_om_padrao IS NULL THEN
      LET m_om_padrao = 0
   END IF

   IF m_num_om < m_om_padrao THEN
      LET m_num_om = m_om_padrao
   END IF

   UPDATE par_vdp
      SET num_ult_om = m_num_om
    WHERE cod_empresa = p_cod_empresa
         
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ',STATUS USING '<<<<<<<','\n',
                  ' ATUALIZANDO tabela par_vdp\n ',
                  'EPL vdp30100y_before_processar.'
      CALL log0030_mensagem(m_msg,'info')
   END IF

   SELECT val_parametro 
     FROM log_val_parametro 
    WHERE empresa = p_cod_empresa 
      AND parametro = 'num_ult_om'
   
   IF STATUS = 0 THEN
      UPDATE log_val_parametro 
         SET val_parametro = m_num_om
       WHERE empresa = p_cod_empresa
         AND parametro='num_ult_om'
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS USING '<<<<<<<','\n',
                     ' ATUALIZANDO tabela log_val_parametro\n ',
                     'EPL vdp30100y_before_processar.'
         CALL log0030_mensagem(m_msg,'info')
      END IF
   END IF
   
   WHENEVER ANY ERROR STOP
      
END FUNCTION

#-----------------------------------#
FUNCTION vdp30100y_after_processar()#
#-----------------------------------#
   
   DEFINE ma_oms  ARRAY[100] OF RECORD
          num_om      INTEGER
   END RECORD
   
   DEFINE l_ind       INTEGER
   
   WHENEVER ANY ERROR CONTINUE
   
   DROP TABLE w_om_nova 
   CREATE TEMP  TABLE w_om_nova(
      num_om      INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('CREATE','w_om_nova:EPL:vdp30100y_after_processar')
      WHENEVER ANY ERROR STOP
      RETURN 
   END IF
   
   DELETE FROM w_om_nova
   
   LET l_ind = 1
   
   DECLARE cq_epl_om CURSOR FOR
   SELECT num_om 
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om > m_num_om
   FOREACH cq_epl_om INTO ma_oms[l_ind].num_om
   
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ',STATUS USING '<<<<<<<','\n',
                     ' lendo tabela ordem_montag_mest\n ',
                    'EPL vdp30100y_after_processar.'
         CALL log0030_mensagem(m_msg,'info')
         EXIT FOREACH
      END IF

      INSERT INTO w_om_nova VALUES(ma_oms[l_ind].num_om)
      
   END FOREACH
   
   SELECT COUNT(*) INTO m_count
     FROM w_om_nova

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_om_nova.count:EPL:vdp30100y_after_processar')
      WHENEVER ANY ERROR STOP
      RETURN 
   END IF
   
   IF m_count > 0 THEN
      LET p_status = LOG_progresspopup_start(
         "Juntando Ordens...","pol1407_junta_ordens","PROCESS")  
   END IF
   
   WHENEVER ANY ERROR STOP
   
END FUNCTION


#----------------------------------#
FUNCTION man100211y_after_incluir()#
#----------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
          
   LET l_empresa = p_cod_empresa
   LET l_item = LOG_getVar("cod_item") #pega o item incluido no man10021
   

END FUNCTION

#------------------------------------#
FUNCTION man100211y_after_modificar()#
#------------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
   
   LET l_empresa = p_cod_empresa
   LET l_item = LOG_getVar("cod_item") #pega o item alterado no man10021


END FUNCTION

#----------------------------------#
FUNCTION man100211y_after_excluir()#
#----------------------------------#
   
   DEFINE l_empresa VARCHAR(02),
          l_item    VARCHAR(15)
   
   LET l_empresa = p_cod_empresa
   LET l_item = LOG_getVar("cod_item") #pega o item excluido no man10021

END FUNCTION
