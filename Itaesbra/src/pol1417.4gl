#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1417                                                            #
# OBJETIVO: EXPORTAÇÃO DE DADOS DE MATERIAIS PARA OPCENTER                     #
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
       m_tip_dados               VARCHAR(20),
       m_mat_situa               VARCHAR(20),
       m_qtd_mat                 INTEGER,
       m_arq_mat                 VARCHAR(120)
       
DEFINE mr_mat                    RECORD                             
       cod_empresa               VARCHAR(02),                       
       ies_produzido             VARCHAR(01),                       
       ies_final                 VARCHAR(01)                        
END RECORD                                                          
                                                                    
                                                                    
DEFINE mr_relat                  RECORD                             
       item_pai                  LIKE item.cod_item,                
       item_compon               LIKE item.cod_item,                
       qtd_necessaria            LIKE estrut_grade.qtd_necessaria,  
       multil                    VARCHAR(03),                      
       ignorar                   VARCHAR(03)                       
END RECORD

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_msg = 'Chamada por outro aplicativo'
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1417_controle()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      LET m_msg = 'Execução a partir do menu Logix'
      CALL pol1417_controle()
      
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
FUNCTION pol1417_job(l_rotina) #
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
   
   CALL pol1417_controle()
   
   RETURN TRUE
   
END FUNCTION   
   
#--------------------------#
FUNCTION pol1417_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120

   LET m_qtd_mat = 0

   CALL pol1417_insere_mensagem()

   #logica para chamar as rotinas de exportação   
   LET p_status = pol1417_exporta_mat()
   
   LET m_msg = 'Fim do processamento'    
   CALL pol1417_insere_mensagem()

END FUNCTION

#---------------------------------#
FUNCTION pol1417_insere_mensagem()#
#---------------------------------#
      
   INSERT INTO export_dados_opcenter_970
     VALUES(p_cod_empresa, m_tip_dados, m_msg, m_dat_proces)

END FUNCTION

#----------------------------#
FUNCTION pol1417_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = 'CSV'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV não cadastrado na LOG1100/LOG00098'
      CALL pol1417_insere_mensagem()
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela path_logix_v2'
         CALL pol1417_insere_mensagem() 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol1417_export_mat(l_qtd_reg)#
#-------------------------------------#
   
   DEFINE l_qtd_reg INTEGER
   
   LET m_qtd_mat = l_qtd_reg
   
   LET p_status = LOG_progresspopup_start(
       "Exportando roteiros...","pol1417_exporta_mat","PROCESS")  

   RETURN p_status, m_arq_mat

END FUNCTION

#-------------------------------#
FUNCTION pol1417_exporta_mat()#
#-------------------------------#

   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_nom_arq     VARCHAR(30),
          l_progres     SMALLINT,
          l_cent_trab   VARCHAR(15),
          l_sql_where   VARCHAR(1000),
          l_sql         VARCHAR(200),
          l_where       VARCHAR(800),
          l_dat_atu     DATE

   IF m_qtd_mat > 0 THEN
      CALL LOG_progresspopup_set_total("PROCESS",m_qtd_mat)
   END IF

   LET m_dat_proces = CURRENT
   LET m_tip_dados = 'MATERIAIS'
   LET l_dat_atu = TODAY
   
   IF NOT pol1417_le_caminho() THEN
      RETURN FALSE
   END IF
   
   LET l_nom_arq = '06_lista_materiais.csv'
   LET m_arq_mat = m_caminho CLIPPED, l_nom_arq
               
   START REPORT pol1417_mat_relat TO m_arq_mat    
      
   LET l_sql_where = 
       " SELECT eg.cod_item_pai, eg.cod_item_compon, eg.qtd_necessaria FROM estrut_grade eg ",
       " LEFT JOIN item i ON i.cod_empresa = eg.cod_empresa AND i.cod_item = eg.cod_item_pai ",
       " LEFT JOIN man_processo_item mp ON mp.empresa = eg.cod_empresa AND mp.item = eg.cod_item_pai ",
       " WHERE eg.cod_empresa = '",p_cod_empresa,"' ",
       " AND i.ies_situacao = 'A' AND i.ies_tip_item = 'P' AND mp.validade_final IS NULL "

   PREPARE var_itens FROM l_sql_where

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ',m_erro, ' preparando query para leitura dos materiais'
      CALL pol1415_insere_mensagem()
      RETURN FALSE
   END IF
      
   DECLARE cq_itens CURSOR FOR var_itens
       
   FOREACH cq_itens INTO
      mr_relat.item_pai, mr_relat.item_compon, mr_relat.qtd_necessaria
   
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro: ',m_erro, ' lendo materiais da tabela item'
         CALL pol1415_insere_mensagem()
         RETURN FALSE
      END IF

      IF m_qtd_mat > 0 THEN
         LET l_progres = LOG_progresspopup_increment("PROCESS") 
      END IF
            
      LET mr_relat.multil = 'SIM'
      LET mr_relat.ignorar = 'NAO'
            
      OUTPUT TO REPORT pol1417_mat_relat() 
      
   END FOREACH
   
   FINISH REPORT pol1417_mat_relat  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
REPORT pol1417_mat_relat()#
#--------------------------#
   
   DEFINE l_qtd_neces  VARCHAR(12)
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
      
      FIRST PAGE HEADER
      
      PRINT COLUMN 001, 
             'Item pai;',
             'Componente;',
             'Necessidade;',
             'Multil;',
             'Ignorar;'
                            
      ON EVERY ROW

      LET l_qtd_neces = mr_relat.qtd_necessaria

      PRINT COLUMN 001,  
             mr_relat.item_pai CLIPPED,';', 
             mr_relat.item_compon CLIPPED,';',   
             l_qtd_neces CLIPPED,';',    
             mr_relat.multil CLIPPED,';',   
             mr_relat.ignorar CLIPPED,';'      
                       
END REPORT

#-------------------------------#
 FUNCTION pol1417_version_info()#
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1417.4gl $|$Revision: 02 $|$Date: 26/01/2021 13:26 $|$Modtime: 06/01/2021 13:26 $" 

 END FUNCTION
