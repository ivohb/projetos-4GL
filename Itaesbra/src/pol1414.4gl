#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1414                                                            #
# OBJETIVO: EXPORTA��O DE DADOS DE GRUPO PARA OPCENTER                         #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 11/01/2021                                                         #
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
          g_tipo_sgbd            CHAR(003),
          g_msg                  VARCHAR(30)
END GLOBALS

DEFINE m_msg                     VARCHAR(120),
       m_erro                    VARCHAR(10),
       m_count                   INTEGER,
       m_dat_atu                 DATE,
       m_hor_atu                 VARCHAR(08),
       m_dat_proces              VARCHAR(19),
       m_tip_dados               VARCHAR(20)

DEFINE m_qtd_grup                INTEGER,
       m_arq_grup                VARCHAR(120)

DEFINE mr_grup                   RECORD                            
       den_cent_trab             LIKE cent_trabalho.den_cent_trab
END RECORD

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_msg = 'Chamada por outro aplicativo'
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1414_controle()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      LET m_msg = 'Execu��o a partir do menu Logix'
      CALL pol1414_controle()
      
      SELECT COUNT(*) INTO m_count
       FROM export_dados_opcenter_970
      WHERE cod_empresa = p_cod_empresa
        AND tip_dados = m_tip_dados
        AND dat_proces = m_dat_proces
      
      IF m_count > 0 THEN
         LET m_msg = 'Consulte a tabela de mensagem export_dados_opcenter_970'
         CALL log0030_mensagem(m_msg,'info')         
      END IF
      
   END IF
         
END MAIN

#------------------------------#
FUNCTION pol1414_job(l_rotina) #
#------------------------------#

   DEFINE l_rotina          CHAR(06),
          l_den_empresa     CHAR(50),
          l_param1_empresa  CHAR(02),
          l_param2_user     CHAR(08),
          l_param3_user     CHAR(08),
          l_status          SMALLINT

   CALL JOB_get_parametro_gatilho_tarefa(1,0) RETURNING l_status, l_param1_empresa
   CALL JOB_get_parametro_gatilho_tarefa(2,0) RETURNING l_status, l_param2_user
   CALL JOB_get_parametro_gatilho_tarefa(2,2) RETURNING l_status, l_param3_user
      
   LET m_msg = 'Chamada via agendador'      
   LET p_cod_empresa = l_param1_empresa   
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF
   
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
   
   CALL pol1414_controle()
   
   RETURN TRUE
   
END FUNCTION   
   
#--------------------------#
FUNCTION pol1414_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120

   LET m_qtd_grup = 0

   CALL pol1414_insere_mensagem()

   #logica para chamar as rotinas de exporta��o   
   LET p_status = pol1414_exporta_grupo()
   
   LET m_msg = 'Fim do processamento'    
   CALL pol1414_insere_mensagem()

END FUNCTION

#---------------------------------#
FUNCTION pol1414_insere_mensagem()#
#---------------------------------#
      
   INSERT INTO export_dados_opcenter_970
     VALUES(p_cod_empresa, m_tip_dados, m_msg, m_dat_proces)

END FUNCTION

#----------------------------#
FUNCTION pol1414_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = 'CSV'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV n�o cadastrado na LOG1100/LOG00098'
      CALL pol1414_insere_mensagem()
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela path_logix_v2'
         CALL pol1414_insere_mensagem() 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol1414_export_grup(l_qtd_reg)#
#--------------------------------------#
   
   DEFINE l_qtd_reg INTEGER
   
   LET m_qtd_grup = l_qtd_reg
   
   LET p_status = LOG_progresspopup_start(
       "Exportando roteiros...","pol1414_exporta_grupo","PROCESS")  

   RETURN p_status, m_arq_grup

END FUNCTION
   
#-------------------------------#
FUNCTION pol1414_exporta_grupo()#
#-------------------------------#

   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_nom_arq     VARCHAR(30),
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15)

   IF m_qtd_grup > 0 THEN
      CALL LOG_progresspopup_set_total("PROCESS",m_qtd_grup)
   END IF

   LET m_dat_proces = CURRENT
   LET m_tip_dados = 'GRUPO'
   
   IF NOT pol1414_le_caminho() THEN
      RETURN FALSE
   END IF
   
   LET l_nom_arq = '03_grupo.csv'
   LET m_arq_grup = m_caminho CLIPPED, l_nom_arq
               
   START REPORT pol1414_grup_relat TO m_arq_grup    
   
   DECLARE cq_le_grup CURSOR FOR
    SELECT DISTINCT den_cent_trab 
      FROM cent_trabalho
     WHERE cod_empresa = p_cod_empresa
     ORDER BY den_cent_trab
       
   FOREACH cq_le_grup INTO
      mr_grup.den_cent_trab

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro: ',m_erro, ' lendo grupos a exportar'
         CALL pol1414_insere_mensagem()
         RETURN FALSE
      END IF

         
      OUTPUT TO REPORT pol1414_grup_relat() 
      
      IF m_qtd_grup > 0 THEN
         LET l_progres = LOG_progresspopup_increment("PROCESS") 
      END IF
   
   END FOREACH
   
   FINISH REPORT pol1414_grup_relat  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
REPORT pol1414_grup_relat()#
#--------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
      
      FIRST PAGE HEADER
      
      PRINT COLUMN 001, 
             'Grupo;'
                            
      ON EVERY ROW

      PRINT COLUMN 001, 
            mr_grup.den_cent_trab CLIPPED,';'
           
END REPORT

#-------------------------------#
 FUNCTION pol1414_version_info()#
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1414.4gl $|$Revision: 02 $|$Date: 26/01/2021 13:26 $|$Modtime: 06/01/2021 13:26 $" 

 END FUNCTION
