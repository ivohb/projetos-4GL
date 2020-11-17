#------------------------------------------------------------------------------#
# colocar no agendador do windows: taskschd.msc                                #
#------------------------------------------------------------------------------#
# PROGRAMA: pol1407                                                            #
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
       m_msg                     VARCHAR(120),
       m_oms                     VARCHAR(120),
       m_count                   INTEGER,
       m_num_pedido              INTEGER,
       m_qtd_om                  INTEGER,
       m_num_ordem               INTEGER,
       m_num_sequencia           INTEGER, 
       m_qtd_reservada           DECIMAL(10,3),
       m_cod_item                VARCHAR(15),
       m_processo                INTEGER,
       m_dat_atu                 DATE,
       m_hor_atu                 CHAR(08)

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_oms = ARG_VAL(1)
      
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1407_controle()
      END IF
      RETURN
   END IF

   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      CALL pol1407_controle()
   END IF
         
END MAIN

#--------------------------#
FUNCTION pol1407_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120
   
   LET m_msg = 'Oms ', m_oms
   
   CALL log0030_mensagem(m_msg,'info')
   
   SELECT COUNT(*) INTO m_count
    FROM w_om_nova
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_om_nova')
      RETURN
   END IF
   
   CALL log0030_mensagem(m_count,'info')

END FUNCTION

#------------------------------#
FUNCTION pol1407_junta_ordens()#
#------------------------------#
   
   SELECT COUNT(*) INTO m_count
    FROM w_om_nova
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','w_om_nova')
      RETURN
   END IF

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   IF m_count = 0 THEN
      RETURN
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1407_processa() THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
   END IF

END FUNCTION

#--------------------------#
FUNCTION pol1407_processa()#
#--------------------------#

   DEFINE m_progres      SMALLINT,
          l_qtd_item     INTEGER,
          l_carteira     CHAR(02)

   DECLARE cq_w_temp CURSOR FOR
    SELECT num_om
      FROM w_om_nova
   FOREACH cq_w_temp INTO m_num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','w_om_nova:cq_w_temp')
         RETURN FALSE
      END IF
   
      LET m_progres = LOG_progresspopup_increment("PROCESS")   
      
      SELECT DISTINCT num_pedido 
         INTO m_num_pedido
         FROM ordem_montag_item 
        WHERE cod_empresa = p_cod_empresa
          AND num_om = m_num_om 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_item:DISTINCT:cq_w_temp')
         RETURN FALSE
      END IF

      SELECT cod_tip_carteira
         INTO l_carteira
         FROM pedidos 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','pedidos:cq_w_temp')
         RETURN FALSE
      END IF

      SELECT 1
         FROM empresa_carteira_adere 
        WHERE empresa = p_cod_empresa
          AND carteira = l_carteira 
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('SELECT','pedidos:cq_w_temp')
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(DISTINCT num_om)
         INTO m_qtd_om
         FROM ordem_montag_item 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_item:COUNT:cq_w_temp')
         RETURN FALSE
      END IF
      
      IF m_qtd_om < 2 THEN
         CONTINUE FOREACH
      END IF

      SELECT COUNT(*) 
        INTO l_qtd_item
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido
         AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > qtd_pecas_romaneio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ped_itens:COUNT:cq_w_temp')
         RETURN FALSE
      END IF
      
      IF l_qtd_item > 0 THEN
         CONTINUE FOREACH
      END IF

      IF NOT pol1407_exclui_oms() THEN
         RETURN FALSE
      END IF

      IF NOT pol1407_cria_om_unica() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
END FUNCTION

#--------------------------------#
FUNCTION pol1407_grava_hist_oms()#
#--------------------------------#

   INSERT INTO ord_montag_mest_hist
    SELECT * FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ord_montag_mest_hist')
      RETURN FALSE
   END IF

   INSERT INTO ord_montag_item_hist
    SELECT * FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','ord_montag_item_hist')
      RETURN FALSE
   END IF

   IF NOT pol1407_ins_om_adere('E') THEN
      RETURN FALSE
   END IF
       
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1407_ins_om_adere(l_op)#
#----------------------------------#

   DEFINE l_op CHAR(01)
   
   INSERT INTO om_x_oms_adere
    VALUES(m_processo, p_cod_empresa, m_num_ordem, l_op)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','om_x_oms_adere')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol1407_exclui_oms()#
#----------------------------#

   SELECT MAX(processo) INTO m_processo
     FROM om_x_oms_adere
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','om_x_oms_adere:max')
      RETURN FALSE
   END IF
   
   IF m_processo IS NULL THEN
      LET m_processo = 0
   END IF

   LET m_processo = m_processo + 1
      
   DECLARE cq_exc_om CURSOR FOR
    SELECT DISTINCT i.num_om
      FROM ordem_montag_item i
      INNER JOIN ordem_montag_mest m on
         m.cod_empresa = i.cod_empresa
         and m.num_om = i.num_om
         and m.ies_sit_om = 'N'
     WHERE i.cod_empresa = p_cod_empresa
       AND i.num_pedido = m_num_pedido
             
   FOREACH cq_exc_om INTO m_num_ordem
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('SELECT','ordem_montag_item:cq_exc_om')
         RETURN FALSE
      END IF

      IF NOT pol1407_grava_hist_oms() THEN
         RETURN FALSE
      END IF
             
      DECLARE cq_le_item CURSOR FOR                                                    
       SELECT num_sequencia, cod_item,  qtd_reservada
         FROM ordem_montag_item                                                       
        WHERE cod_empresa = p_cod_empresa 
          AND num_om = m_num_ordem
                                                                                      
      FOREACH cq_le_item INTO m_num_sequencia, m_cod_item, m_qtd_reservada
                                                                                      
         IF STATUS <> 0 THEN                                                          
            CALL log003_err_sql('SELECT','ordem_montag_item:cq_exc_om')               
            RETURN FALSE                                                              
         END IF                                                                       
                                                                                      
         UPDATE ped_itens
            SET qtd_pecas_romaneio = qtd_pecas_romaneio - m_qtd_reservada
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = m_num_pedido
            AND num_sequencia = m_num_sequencia

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Atualizando','ped_itens:at')
            RETURN FALSE
         END IF
                                                                                      
      END FOREACH                                                                     

      IF NOT pol1407_del_tabs() THEN                                               
         RETURN FALSE                                                              
      END IF                                                                       

   END FOREACH
            
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1407_del_tabs()#
#--------------------------#
   
   DEFINE l_num_reserva   LIKE ordem_montag_grade.num_reserva,
          l_num_lote_om   LIKE ordem_montag_mest.num_lote_om,
          l_texto         LIKE audit_vdp.texto

   DEFINE m_parametro      RECORD
          cod_empresa      CHAR(02),
          num_reserva      INTEGER
   END RECORD
   
   DELETE FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_item:dt')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_embal
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_embal')
      RETURN FALSE
   END IF

   DECLARE cq_reser CURSOR FOR
    SELECT num_reserva
      FROM ordem_montag_grade
     WHERE cod_empresa = p_cod_empresa
       AND num_om      = m_num_ordem
      
   FOREACH cq_reser INTO l_num_reserva
        
      LET m_parametro.cod_empresa = p_cod_empresa
      LET m_parametro.num_reserva = l_num_reserva
      
      IF NOT func003_deleta_reserva(m_parametro) THEN
         RETURN FALSE
      END IF
      
   END FOREACH
  
   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_grade:dt')
      RETURN FALSE
   END IF

   SELECT num_lote_om
     INTO l_num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ordem_montag_mest:dt')
      RETURN FALSE
   END IF
     
   DELETE FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = l_num_lote_om
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_lote:dt')
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ordem_montag_mest:dt')
      RETURN FALSE
   END IF

   DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','om_list:dt')
      RETURN FALSE
   END IF

   DELETE FROM ldi_om_auditoria
    WHERE empresa = p_cod_empresa
      AND ord_montag = m_num_ordem
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ldi_om_auditoria:dt')
      RETURN FALSE
   END IF

   DELETE FROM vdp_controle_exec_romaneio
    WHERE empresa = p_cod_empresa
      AND pedido = m_num_pedido
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','vdp_controle_exec_romaneio:dt')
      RETURN FALSE
   END IF

   DELETE FROM wpedido_om
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','wpedido_om:dt')
      RETURN FALSE
   END IF
      
   LET m_hor_atu = TIME
   LET m_dat_atu = TODAY
   
   LET l_texto = "CANCELAMENTO DA OM Nr.", m_num_ordem USING '&&&&&&&&&&'
   
   INSERT INTO audit_vdp (
      cod_empresa,
      num_pedido,
      tipo_informacao,
      tipo_movto,
      texto,
      num_programa,
      data,
      hora,
      usuario)
    VALUES(p_cod_empresa,
           0,
           'C',
           'C', 
           l_texto,
           'POL1407',
           m_dat_atu,
           m_hor_atu,
           p_user)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_vdp:dt')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1407_cria_om_unica()#
#-------------------------------#
   
   LET m_msg = NULL
   
   CALL func015_gera_om(m_num_pedido, 'POL1407') RETURNING m_num_ordem, m_msg
   
   IF m_num_ordem = 0 THEN
      IF m_msg IS NOT NULL THEN
         CALL log0030_mensagem(m_msg,'info')
      END IF
      RETURN FALSE
   END IF
   
   IF NOT pol1407_ins_om_adere('I') THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
   