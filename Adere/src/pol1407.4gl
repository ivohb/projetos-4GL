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
          g_tipo_sgbd            CHAR(003),
          g_msg                  VARCHAR(30)
END GLOBALS

DEFINE m_num_om                  INTEGER,
       m_msg                     VARCHAR(120),
       m_erro                    VARCHAR(120),
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
       m_hor_atu                 VARCHAR(08),
       m_texto                   VARCHAR(200)

MAIN   

   IF NUM_ARGS() > 0  THEN
      LET m_oms = ARG_VAL(1)
      LET g_msg = 'Chamada por outro aplicativo'
      IF LOG_connectDatabase("DEFAULT") THEN
         CALL pol1407_controle()
      END IF
      RETURN
   END IF

   
   CALL log0180_conecta_usuario()
         
   CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN    
      LET g_msg = 'Execu��o a partir do menu Logix'
      CALL pol1407_controle()
      IF m_erro IS NOT NULL THEN
         CALL log0030_mensagem(m_erro,'info')
      END IF
   END IF
         
END MAIN

#------------------------------#
FUNCTION pol1407_job(l_rotina) #
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
      
   LET g_msg = 'Chamada via agendador'      
   LET p_cod_empresa = l_param1_empresa   
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF
   
   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF
   
   CALL pol1407_controle()
   
   RETURN TRUE
   
END FUNCTION   

#-------------------------------#
FUNCTION pol1407_cria_tab_erro()#
#-------------------------------#

   CREATE TABLE pedido_erro_adere (
      empresa      CHAR(02),
      pedido       INTEGER,
      erro         varchar(120)
   );

   IF STATUS <> 0 THEN
      LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' criando tabela pedido_erro_adere'
      RETURN FALSE
   END IF

   CREATE INDEX ix_pedido_erro_adere ON pedido_erro_adere
      (empresa, pedido);

   IF STATUS <> 0 THEN
      LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' criando indice ix_pedido_erro_adere'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#---------------------------------------------#
FUNCTION pol1407_insere_erro(l_pedido, l_erro)#
#---------------------------------------------#
   
   DEFINE l_pedido     INTEGER,
          l_erro       VARCHAR(120)
          
   INSERT INTO pedido_erro_adere
    VALUES(p_cod_empresa, l_pedido, l_erro)

   IF STATUS <> 0 THEN
      LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados na tabela pedido_erro_adere'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1407_controle()#
#--------------------------#
   
   DEFINE l_num_pedido    INTEGER,
          l_count         INTEGER
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 120

   IF NOT log0150_verifica_se_tabela_existe("pedido_erro_adere") THEN 
      IF NOT pol1407_cria_tab_erro() THEN
         RETURN 
      END IF
   END IF

   DROP TABLE w_pedido_tmp 
   CREATE TEMP  TABLE w_pedido_tmp(
      num_pedido      INTEGER
   );

   IF STATUS <> 0 THEN
      LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' criando tabela w_pedido_tmp:controle '
      RETURN 
   END IF
   
   DELETE FROM w_pedido_tmp
      
   LET m_erro = NULL
   
   DECLARE cq_oms CURSOR FOR
    SELECT distinct i.num_pedido
     FROM ordem_montag_item i
      INNER JOIN ordem_montag_mest m
        ON m.cod_empresa = i.cod_empresa
        AND m.num_om = i.num_om
        AND m.ies_sit_om = 'N'
        AND m.num_nff IS NULL
      INNER JOIN om_list l
        ON l.cod_empresa = i.cod_empresa
        AND l.num_om = i.num_om
        AND l.dat_emis >= '01/01/2020'
   WHERE i.cod_empresa = p_cod_empresa

    FOREACH cq_oms INTO l_num_pedido

      IF STATUS <> 0 THEN
         LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ordem_montag_mest:cq_oms '
         RETURN 
      END IF

      SELECT COUNT(*) 
        INTO l_count
        FROM ped_itens 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido = l_num_pedido 
         AND qtd_pecas_atend > 0

      IF STATUS <> 0 THEN
         LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ped_itens:cq_oms '
         RETURN 
      END IF

      IF l_count > 0 THEN
         LET m_erro = 'Pedido j� cont�m faturamento'
         IF NOT pol1407_insere_erro(l_num_pedido, m_erro) THEN
            RETURN
         END IF
         CONTINUE FOREACH
      END IF
      
      SELECT COUNT(*) 
        INTO l_count
        FROM ordem_montag_item 
       WHERE cod_empresa = p_cod_empresa 
         AND num_pedido = l_num_pedido 
         AND qtd_reservada <= 0

      IF STATUS <> 0 THEN
         LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ordem_montag_item:cq_oms '
         RETURN 
      END IF
      
      IF l_count > 0 THEN
         LET m_erro = 'Pedido cont�m OM com quantidade a faturar inv�lida'
         IF NOT pol1407_insere_erro(l_num_pedido, m_erro) THEN
            RETURN
         END IF
         CONTINUE FOREACH
      END IF
      
      INSERT INTO w_pedido_tmp VALUES(l_num_pedido)      
         
      IF STATUS <> 0 THEN
         LET m_erro = 'Erro ', STATUS USING '<<<<<<', ' inserindo pedido na tabela w_pedido_tmp:cq_oms '
         RETURN 
      END IF
   
   END FOREACH
   
   LET m_erro = pol1407_junta_ordens()         

END FUNCTION

#------------------------------#
FUNCTION pol1407_junta_ordens()#
#------------------------------#
   
   DEFINE l_dat_proces     VARCHAR(19)
   
   LET m_hor_atu = TIME
   LET m_dat_atu = TODAY
   LET l_dat_proces = CURRENT
   LET m_msg = NULL
   
   IF g_msg IS NULL THEN
      LET g_msg = 'Chamada pela EPL'
   END IF
   
   INSERT INTO proces_pol1407_adere
    VALUES(l_dat_proces, g_msg)
   
   SELECT COUNT(*) INTO m_count
    FROM w_pedido_tmp
   
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo pedido na tabela w_pedido_tmp:COUNT '
      RETURN m_msg
   END IF

   CALL LOG_progresspopup_set_total("PROCESS",m_count)

   IF m_count = 0 THEN
      RETURN m_msg
   END IF
   
   CALL LOG_transaction_begin()
   
   IF NOT pol1407_processa() THEN
      CALL LOG_transaction_rollback()
   ELSE
      CALL LOG_transaction_commit()
   END IF
   
   RETURN m_msg
   
END FUNCTION

#--------------------------#
FUNCTION pol1407_processa()#
#--------------------------#

   DEFINE m_progres      SMALLINT,
          l_qtd_item     INTEGER,
          l_carteira     CHAR(02)

   DECLARE cq_w_temp CURSOR FOR
    SELECT num_pedido
      FROM w_pedido_tmp
   FOREACH cq_w_temp INTO m_num_pedido

      IF STATUS <> 0 THEN
          LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela w_pedido_tmp:cq_w_temp '
         RETURN FALSE
      END IF
   
      LET m_progres = LOG_progresspopup_increment("PROCESS")   
      
      SELECT cod_tip_carteira
         INTO l_carteira
         FROM pedidos 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
          AND ies_sit_pedido <> '9'
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela pedidos:cq_w_temp '
            RETURN FALSE
         END IF
      END IF

      SELECT 1
         FROM empresa_carteira_adere 
        WHERE empresa = p_cod_empresa
          AND carteira = l_carteira 
      
      IF STATUS = 100 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 0 THEN
            LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela empresa_carteira_adere:cq_w_temp '
            RETURN FALSE
         END IF
      END IF

      SELECT COUNT(DISTINCT num_om)
         INTO m_qtd_om
         FROM ordem_montag_item 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
      
      IF STATUS <> 0 THEN
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ordem_montag_item:cq_w_temp '
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
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ped_itens:cq_w_temp '
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
   
   LET m_msg = NULL
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol1407_exclui_oms()#
#----------------------------#

   DEFINE l_qtd_reser   VARCHAR(10)

   SELECT MAX(processo) INTO m_processo
     FROM om_x_oms_adere
     
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela om_x_oms_adere '
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
         LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ordem_montag_item:cq_exc_om '
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
            LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo tabela ordem_montag_item:cq_le_item '           
            RETURN FALSE                                                              
         END IF                                                                       
                                                                                      
         UPDATE ped_itens
            SET qtd_pecas_romaneio = qtd_pecas_romaneio - m_qtd_reservada
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = m_num_pedido
            AND num_sequencia = m_num_sequencia

         IF STATUS <> 0 THEN
            LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' Atualizando tabela ped_itens:cq_le_item '  
            RETURN FALSE
         END IF

         LET l_qtd_reser = m_qtd_reservada
   
         LET m_texto = 
                 "CANCELAMENTO DA OM Nr. ", m_num_ordem USING '<<<<<<<',
                 " para seq_item_ped ", m_num_sequencia USING '<<<',
                 " qtd reservada ", l_qtd_reser
         
         IF NOT pol1407_ins_audit() THEN
            RETURN FALSE
         END IF         
                                                                                      
      END FOREACH                                                                     

      IF NOT pol1407_del_tabs() THEN                                               
         RETURN FALSE                                                              
      END IF                                                                       

   END FOREACH
            
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1407_grava_hist_oms()#
#--------------------------------#

   INSERT INTO ord_montag_mest_hist
    SELECT * FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados tab ord_montag_mest_hist '
      RETURN FALSE
   END IF

   INSERT INTO ord_montag_item_hist
    SELECT * FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados tab ord_montag_item_hist '
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
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados tab om_x_oms_adere '
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1407_ins_audit()#
#---------------------------#
      
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
           m_num_pedido,
           'I',
           'C', 
           m_texto,
           'POL1407',
           m_dat_atu,
           m_hor_atu,
           p_user)
           
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' inserindo dados tab audit_vdp '
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#--------------------------#
FUNCTION pol1407_del_tabs()#
#--------------------------#
   
   DEFINE l_num_reserva   LIKE ordem_montag_grade.num_reserva,
          l_num_lote_om   LIKE ordem_montag_mest.num_lote_om,
          l_texto         LIKE audit_vdp.texto,
          l_ordem         VARCHAR(07)

   DEFINE m_parametro      RECORD
          cod_empresa      CHAR(02),
          num_reserva      INTEGER
   END RECORD
   
   DELETE FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ordem_montag_item '
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_embal
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ordem_montag_embal '
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
      
      LET m_msg = func003_deleta_reserva(m_parametro) 

      IF m_msg IS NOT NULL THEN
         RETURN FALSE
      END IF
      
   END FOREACH
  
   LET l_ordem = m_num_ordem USING '<<<<<<<'
      
   DELETE FROM ordem_montag_grade
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ordem_montag_grade '
      RETURN FALSE
   END IF

   SELECT num_lote_om
     INTO l_num_lote_om
     FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem

   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' lendo lote da tab ordem_montag_mest '
      RETURN FALSE
   END IF
     
   DELETE FROM ordem_montag_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_lote_om = l_num_lote_om
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ordem_montag_lote '
      RETURN FALSE
   END IF

   DELETE FROM ordem_montag_mest
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ordem_montag_mest '
      RETURN FALSE
   END IF

   DELETE FROM om_list
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab om_list '
      RETURN FALSE
   END IF

   DELETE FROM ldi_om_auditoria
    WHERE empresa = p_cod_empresa
      AND ord_montag = m_num_ordem
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab ldi_om_auditoria '
      RETURN FALSE
   END IF

   DELETE FROM vdp_controle_exec_romaneio
    WHERE empresa = p_cod_empresa
      AND pedido = m_num_pedido
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab vdp_controle_exec_romaneio '
      RETURN FALSE
   END IF

   DELETE FROM wpedido_om
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      
   IF STATUS <> 0 THEN
      LET m_msg = 'Erro ', STATUS USING '<<<<<<', ' deletando dados da tab wpedido_om '
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
      RETURN FALSE
   END IF
   
   IF NOT pol1407_ins_om_adere('I') THEN
      RETURN FALSE
   END IF

   CALL pol1407_insere_erro(m_num_pedido, m_msg) RETURN p_status

   RETURN TRUE

END FUNCTION
   
#LOG1700             
#-------------------------------#
 FUNCTION pol1407_version_info()
#-------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/gps_logist_e_gerenc_de_riscos_ltda/financeiro/solicitacao de faturameto/programas/pol1407.4gl $|$Revision: 4 $|$Date: 08/12/2020 12:00 $|$Modtime: 4/12/2020 12:30 $"

 END FUNCTION
   