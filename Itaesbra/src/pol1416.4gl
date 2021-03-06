#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1416                                                            #
# OBJETIVO: EXPORTA��O DE DADOS DE ORDENS PARA OPCENTER                        #
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
       
DEFINE m_qtd_ordem               INTEGER,
       m_arq_ordem               VARCHAR(120),
       m_ies_situa               VARCHAR(30)

DEFINE mr_ordem                  RECORD        
       cod_empresa               VARCHAR(02),  
       ies_planejada             VARCHAR(01),  
       ies_firme                 VARCHAR(01),  
       ies_aberta                VARCHAR(01),  
       ies_liberada              VARCHAR(01),  
       ies_fechada               VARCHAR(01),  
       ies_cancelada             VARCHAR(01),  
       qtd_dias_entr             DECIMAL(3,0)  
END RECORD

DEFINE mr_relat                  RECORD                  
       dat_entrega               LIKE ordens.dat_entrega,
       num_ordem                 LIKE ordens.num_ordem,  
       cod_item                  LIKE ordens.cod_item,   
       ies_situa                 LIKE ordens.ies_situa,  
       qtd_planej                LIKE ordens.qtd_planej,
       den_situa                 VARCHAR(20),
       setor                     VARCHAR(10)  
END RECORD

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_msg = 'Chamada por outro aplicativo'
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1416_controle()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      LET m_msg = 'Execu��o a partir do menu Logix'
      CALL pol1416_controle()
      
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
FUNCTION pol1416_job(l_rotina) #
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
   
   CALL pol1416_controle()
   
   RETURN TRUE
   
END FUNCTION   
   
#--------------------------#
FUNCTION pol1416_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120

   LET m_qtd_ordem = 0

   CALL pol1416_insere_mensagem()

   #logica para chamar as rotinas de exporta��o   
   LET p_status = pol1416_exporta_ordem()
   
   LET m_msg = 'Fim do processamento'    
   CALL pol1416_insere_mensagem()

END FUNCTION

#---------------------------------#
FUNCTION pol1416_insere_mensagem()#
#---------------------------------#
      
   INSERT INTO export_dados_opcenter_970
     VALUES(p_cod_empresa, m_tip_dados, m_msg, m_dat_proces)

END FUNCTION

#----------------------------#
FUNCTION pol1416_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = 'CSV'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV n�o cadastrado na LOG1100/LOG00098'
      CALL pol1416_insere_mensagem()
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela path_logix_v2'
         CALL pol1416_insere_mensagem() 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol1416_export_ordem(l_qtd_reg)#
#---------------------------------------#
   
   DEFINE l_qtd_reg INTEGER
   
   LET m_qtd_ordem = l_qtd_reg
   
   LET p_status = LOG_progresspopup_start(
       "Exportando roteiros...","pol1416_exporta_ordem","PROCESS")  

   RETURN p_status, m_arq_ordem

END FUNCTION

#-------------------------------#
FUNCTION pol1416_exporta_ordem()#
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
          l_dat_entrega DATE,
          l_planj       DECIMAL(10,3),
          l_boas        DECIMAL(10,3),
          l_refug       DECIMAL(10,3),
          l_sucata      DECIMAL(10,3)

   IF m_qtd_ordem > 0 THEN
      CALL LOG_progresspopup_set_total("PROCESS",m_qtd_ordem)
   END IF

   LET m_dat_proces = CURRENT
   LET m_tip_dados = 'ORDENS'
   
   IF NOT pol1416_le_caminho() THEN
      RETURN FALSE
   END IF
   
   LET l_nom_arq = '05_ordens_producao.csv'
   LET m_arq_ordem = m_caminho CLIPPED, l_nom_arq
               
   START REPORT pol1416_ordem_relat TO m_arq_ordem    
      
   SELECT * INTO mr_ordem.*
     FROM ordem_status_970
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      LET m_erro = STATUS
      LET m_msg = 'Erro: ',m_erro, ' lendo parametros da tabela ordem_status_970'
      CALL pol1415_insere_mensagem()
      RETURN FALSE
   END IF
   
   LET m_ies_situa = "('0'"
   
   IF mr_ordem.ies_planejada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'1'"
   END IF
   
   IF mr_ordem.ies_firme = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'2'"
   END IF

   IF mr_ordem.ies_aberta = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'3'"
   END IF

   IF mr_ordem.ies_liberada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'4'"
   END IF

   IF mr_ordem.ies_fechada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'5'"
   END IF

   IF mr_ordem.ies_cancelada = 'S' THEN
      LET m_ies_situa = m_ies_situa CLIPPED,",'9'"
   END IF

   LET m_ies_situa = m_ies_situa CLIPPED,")"
   
   LET l_dat_entrega = TODAY + mr_ordem.qtd_dias_entr
                          
   LET l_sql = 
    "SELECT ordens.dat_entrega, ordens.num_ordem, ordens.cod_item, ordens.ies_situa, ",
    " ordens.qtd_planej, ordens.qtd_boas, ordens.qtd_refug, ordens.qtd_sucata FROM ordens "

   
   LET l_where =
    " WHERE ordens.cod_empresa = '",p_cod_empresa,"' ",
      "AND ordens.ies_situa IN ",m_ies_situa,
      "AND ordens.dat_entrega <= '",l_dat_entrega,"' ",                                 
      "AND ordens.num_ordem NOT IN ",                                          
          "(SELECT ord_oper.num_ordem FROM ord_oper ",                            
            "WHERE ord_oper.cod_empresa = ordens.cod_empresa ",                   
              "AND ord_oper.num_ordem = ordens.num_ordem ",
              "AND cod_operac IN ",                   
                  "(SELECT oper_rot_970.cod_operac FROM oper_rot_970 ",
                    "WHERE oper_rot_970.cod_empresa = ord_oper.cod_empresa)) "
   
   LET l_sql_where = l_sql CLIPPED, l_where CLIPPED
   
   PREPARE var_ordens FROM l_sql_where
                                                                                                                                                              
   IF STATUS <> 0 THEN
      CALL log003_err_sql('PREPARE','ordens:lendo ordens(PREPARE)')
      RETURN FALSE
   END IF
   
   DECLARE cq_ordens CURSOR FOR var_ordens
       
   FOREACH cq_ordens INTO
      mr_relat.dat_entrega, 
      mr_relat.num_ordem,   
      mr_relat.cod_item,    
      mr_relat.ies_situa,   
      l_planj, l_boas, l_refug, l_sucata    

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro: ',m_erro, ' lendo recursos por grupo a exportar'
         CALL pol1416_insere_mensagem()
         RETURN FALSE
      END IF

      LET mr_relat.qtd_planej  = l_planj - l_boas - l_refug - l_sucata

      CASE mr_relat.ies_situa
           WHEN '1' LET mr_relat.den_situa = "PLANEJADA"
           WHEN '2' LET mr_relat.den_situa = "FIRME"    
           WHEN '3' LET mr_relat.den_situa = "ABERTA"   
           WHEN '4' LET mr_relat.den_situa = "LIBERADA" 
           WHEN '5' LET mr_relat.den_situa = "FECHADA"  
           WHEN '9' LET mr_relat.den_situa = "CANCELADA"
      END CASE
      
      OUTPUT TO REPORT pol1416_ordem_relat() 
      
      IF m_qtd_ordem > 0 THEN
         LET l_progres = LOG_progresspopup_increment("PROCESS") 
      END IF
   
   END FOREACH
   
   FINISH REPORT pol1416_ordem_relat  
   
   RETURN TRUE

END FUNCTION

#--------------------------#
REPORT pol1416_ordem_relat()#
#--------------------------#
   
   DEFINE l_num_ordem     VARCHAR(10),
          l_qtd_planej    VARCHAR(12)
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
      
      FIRST PAGE HEADER
      
      PRINT COLUMN 001, 
             'Entrega;',
             'Ordem;',
             'Item;',
             'Cod situacao;',
             'desc situacao;',
             'Sdo a produzir;'
                            
      ON EVERY ROW

      LET l_num_ordem = mr_relat.num_ordem
      LET l_qtd_planej = mr_relat.qtd_planej
      
      PRINT COLUMN 001,  
             mr_relat.dat_entrega CLIPPED,';', 
             l_num_ordem CLIPPED,';',   
             mr_relat.cod_item CLIPPED,';',    
             mr_relat.ies_situa CLIPPED,';',   
             mr_relat.den_situa CLIPPED,';',   
             l_qtd_planej CLIPPED,';'      
                       
END REPORT

#-------------------------------#
 FUNCTION pol1416_version_info()#
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1416.4gl $|$Revision: 02 $|$Date: 26/01/2021 13:26 $|$Modtime: 06/01/2021 13:26 $" 

 END FUNCTION
