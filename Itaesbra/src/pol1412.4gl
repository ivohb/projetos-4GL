#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1412                                                            #
# OBJETIVO: GERA��O DE DADOS DE ROTEIRO PARA OPCENTER                          #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 06/01/2021                                                         #
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

DEFINE m_qtd_rot                 INTEGER,
       m_arq_rot                 VARCHAR(120)

DEFINE mr_rot                    RECORD                                         
       cod_item                  LIKE item.cod_item,                            
       den_item_reduz            LIKE item.den_item_reduz,                      
       seq_operacao              LIKE man_processo_item.seq_operacao,
       cod_operac                LIKE man_processo_item.operacao,               
       den_operac                LIKE operacao.den_operac,                      
       den_cent_trab             LIKE cent_trabalho.den_cent_trab,              
       qtd_tempo_setup           LIKE man_processo_item.qtd_tempo_setup,        
       tipo                      VARCHAR(15), #'Taxa por Hora'                  
       qtd_pecas_ciclo           LIKE man_processo_item.qtd_pecas_ciclo,        
       descricao                 VARCHAR(30), #item_2dig_clientes_970.descricao 
       horas                     VARCHAR(15), #'Horas 00 Mins'                   
       cod_peca_princ            LIKE peca_geme_man912.cod_peca_princ,
       cod_item_cliente          LIKE cliente_item.cod_item_cliente
END RECORD

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_msg = 'Chamada por outro aplicativo'
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1412_controle()
      END IF
      RETURN
   END IF
   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      LET m_msg = 'Execu��o a partir do menu Logix'
      CALL pol1412_controle()
      
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
FUNCTION pol1412_job(l_rotina) #
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
   
   CALL pol1412_controle()
   
   RETURN TRUE
   
END FUNCTION   
   
#--------------------------#
FUNCTION pol1412_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120

   LET m_qtd_rot = 0

   CALL pol1412_insere_mensagem()

   #logica para chamar as rotinas de exporta��o   
   LET p_status = pol1412_exporta_roteiro()
   
   LET m_msg = 'Fim do processamento'    
   CALL pol1412_insere_mensagem()

END FUNCTION

#---------------------------------#
FUNCTION pol1412_insere_mensagem()#
#---------------------------------#
      
   INSERT INTO export_dados_opcenter_970
    VALUES(p_cod_empresa, m_tip_dados, m_msg, m_dat_proces)

END FUNCTION

#----------------------------#
FUNCTION pol1412_le_caminho()#
#----------------------------#

   SELECT nom_caminho
     INTO m_caminho
   FROM path_logix_v2
   WHERE cod_empresa = p_cod_empresa 
     AND cod_sistema = 'CSV'

   IF STATUS = 100 THEN
      LET m_msg = 'Caminho do sistema CSV n�o cadastrado na LOG1100/LOG00098'
      CALL pol1412_insere_mensagem()
      RETURN FALSE
   ELSE
      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro ',m_erro CLIPPED, ' lendo tabela path_logix_v2'
         CALL pol1412_insere_mensagem() 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------------------#
FUNCTION pol1412_export_prod_rot(l_qtd_reg)#
#------------------------------------------#
   
   DEFINE l_qtd_reg INTEGER
   
   LET m_qtd_rot = l_qtd_reg
   
   LET p_status = LOG_progresspopup_start(
       "Exportando roteiros...","pol1412_exporta_roteiro","PROCESS")  

   RETURN p_status, m_arq_rot

END FUNCTION
   
#---------------------------------#
FUNCTION pol1412_exporta_roteiro()#
#---------------------------------#

   DEFINE l_codigo      VARCHAR(02),
          l_desc        VARCHAR(30),
          l_ind         INTEGER,
          l_nom_arq     VARCHAR(30),
          l_progres     SMALLINT

   LET m_dat_proces = CURRENT
   LET m_tip_dados = 'ROTEIRO'
   
   IF m_qtd_rot > 0 THEN
      CALL LOG_progresspopup_set_total("PROCESS",m_qtd_rot)
   END IF
   
   IF NOT pol1412_le_caminho() THEN
      RETURN FALSE
   END IF
   
   LET l_nom_arq = '01_produto_roteiro.csv'
   LET m_arq_rot = m_caminho CLIPPED, l_nom_arq
               
   START REPORT pol1412_relat TO m_arq_rot     
   
   DECLARE cq_le_rot CURSOR FOR
   SELECT man_processo_item.item,           
          item.den_item_reduz,              
          man_processo_item.seq_operacao,       
          man_processo_item.operacao,       
          operacao.den_operac,              
          cent_trabalho.den_cent_trab,      
          man_processo_item.qtd_tempo_setup,
          man_processo_item.qtd_pecas_ciclo 
     FROM man_processo_item
          INNER JOIN item
                 ON  item.cod_empresa=man_processo_item.empresa
                AND item.cod_item=man_processo_item.item
                AND item.ies_situacao='A'
          INNER JOIN operacao
                  ON operacao.cod_empresa=man_processo_item.empresa
                 AND operacao.cod_operac=man_processo_item.operacao
          LEFT JOIN cent_trabalho
                 ON cent_trabalho.cod_empresa=man_processo_item.empresa
                AND cent_trabalho.cod_cent_trab=man_processo_item.centro_trabalho
    WHERE man_processo_item.empresa = p_cod_empresa
      AND man_processo_item.validade_final IS NULL
      AND man_processo_item.operacao NOT IN 
          (SELECT cod_operac FROM oper_rot_970 WHERE cod_empresa = p_cod_empresa)
   
   FOREACH cq_le_rot INTO
      mr_rot.cod_item,       
      mr_rot.den_item_reduz, 
      mr_rot.seq_operacao,
      mr_rot.cod_operac,     
      mr_rot.den_operac,     
      mr_rot.den_cent_trab,  
      mr_rot.qtd_tempo_setup,
      mr_rot.qtd_pecas_ciclo

      IF STATUS <> 0 THEN
         LET m_erro = STATUS
         LET m_msg = 'Erro: ',m_erro, ' lendo roteiros a exportar'
         CALL pol1412_insere_mensagem()
         RETURN FALSE
      END IF

      LET mr_rot.tipo = 'Taxa por Hora'
      LET mr_rot.horas = 'Horas 00 Mins'
      
      LET l_codigo = mr_rot.cod_item[1,2]
      LET mr_rot.descricao = NULL
      
      DECLARE cq_desc CURSOR FOR
      SELECT descricao 
        FROM item_2dig_clientes_970
       WHERE codigo = l_codigo
      FOREACH cq_desc INTO l_desc

         IF STATUS <> 0 THEN
            LET m_erro = STATUS
            LET m_msg = 'Erro: ',m_erro, ' lendo tabela item_2dig_clientes_970'
            CALL pol1412_insere_mensagem()
            LET l_desc = NULL
         END IF
         
         LET mr_rot.descricao = l_desc
         EXIT FOREACH
      
      END FOREACH

      LET mr_rot.cod_item_cliente = NULL
      
      DECLARE cq_it_cli CURSOR FOR
      SELECT cod_item_cliente 
        FROM cliente_item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = mr_rot.cod_item
      FOREACH cq_it_cli INTO l_desc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','cliente_item')
            RETURN FALSE
         END IF
         
         LET mr_rot.cod_item_cliente = l_desc
         EXIT FOREACH
      
      END FOREACH
      
      LET mr_rot.cod_peca_princ = NULL
      
      DECLARE cq_gemea CURSOR FOR
      SELECT cod_peca_princ 
        FROM peca_geme_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_peca_gemea = mr_rot.cod_item
      FOREACH cq_gemea INTO l_desc

         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','peca_geme_man912')
            RETURN FALSE
         END IF
         
         LET mr_rot.cod_peca_princ = l_desc
         EXIT FOREACH
      
      END FOREACH
      
      OUTPUT TO REPORT pol1412_relat() 
      
      IF m_qtd_rot > 0 THEN
         LET l_progres = LOG_progresspopup_increment("PROCESS") 
      END IF
   
   END FOREACH
   
   FINISH REPORT pol1412_relat  
   
   RETURN TRUE

END FUNCTION

#---------------------#
REPORT pol1412_relat()#
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 1
          
   FORMAT
      
      FIRST PAGE HEADER
      
      PRINT COLUMN 001, 
             'Item;',
             'Decri��o;',
             'Sequencia;',
             'Opera��o;',
             'Decri��o;',          
             'Grupo;',         
             'Setup;',        
             'Tipo;',     
             'Pe�as/ciclo;',          
             'Descri��o;',       
             'Horas;',
             'Gemea(Principal);',
             'Cod do cliente;'
                            
      ON EVERY ROW

      PRINT COLUMN 001, 
            mr_rot.cod_item CLIPPED,';',       
            mr_rot.den_item_reduz CLIPPED,';',  
            mr_rot.seq_operacao,';',  
            mr_rot.cod_operac CLIPPED,';',      
            mr_rot.den_operac CLIPPED,';',      
            mr_rot.den_cent_trab CLIPPED,';',   
            mr_rot.qtd_tempo_setup CLIPPED,';', 
            mr_rot.tipo CLIPPED,';',            
            mr_rot.qtd_pecas_ciclo CLIPPED,';', 
            mr_rot.descricao CLIPPED,';',       
            mr_rot.horas CLIPPED,';', 
            mr_rot.cod_peca_princ,';', 
            mr_rot.cod_item_cliente,';'
           
END REPORT

   
#-------------------------------#
 FUNCTION pol1412_version_info()#
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1412.4gl $|$Revision: 02 $|$Date: 26/01/2021 13:26 $|$Modtime: 06/01/2021 13:26 $" 

 END FUNCTION
