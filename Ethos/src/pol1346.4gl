# PROGRAMA: pol1346       ETHOS METALURGICA                                    #
# OBJETIVO: DATA DE ENCERRAMENTO DAS OPERAÇÕES E LOCAL DE BAIXA                #
# AUTOR...: IVO H BARBOSA                                                      #
# DATA....: 02/07/2018                                                         #
# ALTERADO:                                                                    #
#------------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
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

DEFINE m_nom_tela                CHAR(200)

#variáveis para data limite
DEFINE m_texto           CHAR(10),
       m_num_ordem       INTEGER,
       m_cod_item        CHAR(15),
       m_cod_item_pai    CHAR(15),
       m_dat_entrega     DATE,
       m_dt_entrega_pai  DATE,
       m_ies_situa       CHAR(01),
       m_num_pedido      DECIMAL(6,0),
       m_seq_pedido      DECIMAL(3,0),
       m_cod_operac      CHAR(05),
       m_seq_operac      DECIMAL(3,0),
       m_num_processo    INTEGER,
       m_qtd_dias        DECIMAL(3,0),
       m_dat_proces      CHAR(19),
       m_msg             CHAR(120),
       m_dat_ult_oper    DATE,
       m_tem_erro        SMALLINT,
       m_operacao        CHAR(05),
       m_dat_atu         DATE,
       m_dia_util        SMALLINT,
       m_qtd_dia_oper    INTEGER,
       m_count           INTEGER,
       m_id_registro     INTEGER,
       m_ind_erro        INTEGER,
       m_ind             INTEGER,
       m_op_pai          INTEGER,
       m_qtd_ant         DECIMAL(3,0),
       m_ord_processo    DECIMAL(3,0),
       m_seq_calc        INTEGER ,
       m_dias_subtrair   DECIMAL(3,0),
       p_num_ordem       INTEGER,
       m_id_local        INTEGER,
       m_tem_op          SMALLINT,
       m_houve_erro      SMALLINT

DEFINE ma_erro           ARRAY[300] OF RECORD
       num_pedido        decimal(6,0),
       seq_pedido        decimal(3,0),
       num_ordem         INTEGER,
       den_erro          char(120)
END RECORD

DEFINE m_cod_etapa       LIKE item_man.cod_etapa

#variáveis para local de baixa

DEFINE m_cod_local       LIKE local.cod_local,
       m_num_docum       LIKE ordens.num_docum,
       m_cod_local_prod  LIKE local.cod_local,
       m_cod_local_estoq LIKE local.cod_local,
       m_num_neces       LIKE ordens.num_neces,
       m_cod_compon      LIKE ordens.cod_item,
       m_ies_tip_item    LIKE ordens.ies_situa

DEFINE l_dat_proces      CHAR(19),
       m_execucao        CHAR(15)

MAIN
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND) 
   
   IF NUM_ARGS() > 0  THEN
      LET p_cod_empresa = ARG_VAL(1)
      LET p_status = 0
      LET p_user = 'admlog'
      LET m_execucao = "Via bat"
                                                                                            
      #INSERT INTO porc_pol1346_547                                   
      # VALUES(0,l_dat_proces,"Via bat",p_cod_empresa,p_user)          
      
      CALL pol1346_controle()
      
   ELSE
      CALL log0180_conecta_usuario()                                 
                                                                     
      LET g_tipo_sgbd = LOG_getCurrentDBType()                       
                                                                     
      CALL log001_acessa_usuario("ESPEC999","")                      
         RETURNING p_status, p_cod_empresa, p_user                   
      
      LET m_execucao = "Manual"
                                                                                                                                                
      #INSERT INTO porc_pol1346_547                                   
       #VALUES(0,l_dat_proces,"Manual",p_cod_empresa,p_user)          
                                                                     
      LET m_msg = ''                                                 
                                                                     
      IF p_status = 0 THEN                                           
         CALL pol1346_controle()                                     
      END IF                                                         
                                                                     
      LET m_msg = 'Processamento concluído.'                         
                                                                     
      CALL log0030_mensagem(m_msg,'info')                            
   END IF
         
END MAIN

#------------------------------#
FUNCTION pol1346_job(l_rotina) #
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
   
   LET l_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)
   LET m_execucao = "Agendador loix"
   
   #INSERT INTO porc_pol1346_547
   # VALUES(0,l_dat_proces,"Automatico",l_param1_empresa,l_param2_user)

   LET p_cod_empresa = l_param1_empresa
   LET p_user = l_param2_user
   
   IF p_cod_empresa IS NULL THEN
      LET p_cod_empresa = '01'
   END IF

   IF p_user IS NULL THEN
      LET p_user = 'admlog'
   END IF

   LET m_msg = ''
               
   CALL pol1346_controle()  
   
   IF m_msg IS NULL THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE    
   
END FUNCTION   

#--------------------------#
FUNCTION pol1346_controle()#
#--------------------------#
   
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 300

   LET p_versao = "pol1346-12.00.19  "
   CALL func002_versao_prg(p_versao)

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE m_nom_tela TO NULL
   CALL log130_procura_caminho("pol1346") RETURNING m_nom_tela
   LET  m_nom_tela = m_nom_tela CLIPPED 
   OPEN WINDOW w_pol1346 AT 03,05 WITH FORM m_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   #lds CALL LOG_refresh_display()
   
   LET m_dat_proces = EXTEND(CURRENT, YEAR TO SECOND)

   INSERT INTO porc_pol1346_547                                   
       VALUES(0,m_dat_proces,m_execucao,p_cod_empresa,p_user)          
   
   IF NOT pol1346_proces_data() THEN
      CALL pol1346_grava_erro() RETURNING p_status
   END IF

   INSERT INTO porc_pol1346_547                                   
       VALUES(0,m_dat_proces,"Fim proces limite",p_cod_empresa,p_user)          

   IF NOT pol1346_proces_local() THEN
      CALL pol1346_grv_erro() RETURNING p_status
   END IF

   INSERT INTO porc_pol1346_547                                   
       VALUES(0,m_dat_proces,"Fim proces local",p_cod_empresa,p_user)          
   
   {CALL log085_transacao("BEGIN")
   
   IF NOT pol1346_ajusta_chapa() THEN
      CALL log085_transacao("ROLLBACK")
      CALL pol1346_grv_erro() RETURNING p_status
   END IF
   
   CALL log085_transacao("COMMIT")}
   
   CLOSE WINDOW w_pol1346
    
END FUNCTION

#-----------------------------#
FUNCTION pol1346_guarda_erro()#
#-----------------------------#

   LET m_tem_erro = TRUE
   LET m_ind_erro = m_ind_erro + 1
   LET ma_erro[m_ind_erro].num_pedido = m_num_pedido
   LET ma_erro[m_ind_erro].seq_pedido = m_seq_pedido
   LET ma_erro[m_ind_erro].num_ordem = m_num_ordem
   LET ma_erro[m_ind_erro].den_erro = m_msg

END FUNCTION      
 
#------------------------------#
FUNCTION pol1346_carrega_erro()#
#------------------------------#
      
   FOR m_ind = 1 TO m_ind_erro
       LET m_num_pedido = ma_erro[m_ind].num_pedido
       LET m_seq_pedido = ma_erro[m_ind].seq_pedido
       LET m_num_ordem = ma_erro[m_ind].num_ordem
       LET m_msg = ma_erro[m_ind].den_erro
       
       IF NOT pol1346_grava_erro() THEN
          RETURN FALSE
       END IF
       
   END FOR
   
   RETURN TRUE

END FUNCTION
   
#----------------------------#
FUNCTION pol1346_grava_erro()#
#----------------------------#

   INSERT INTO limite_erro_547(
    cod_empresa,
    num_pedido,
    seq_pedido,
    num_ordem,
    dat_proces,
    den_erro)
   VALUES(p_cod_empresa,
          m_num_pedido,
          m_seq_pedido,
          m_num_ordem,
          m_dat_proces,
          m_msg)
          
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, ' gravando tabela limite_erro_547'
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION          

#--------------------------#
FUNCTION pol1346_grv_erro()#
#--------------------------#

   INSERT INTO local_erro_547 (
     id_local,
     cod_empresa,
     num_ordem,
     dat_proces,
     den_erro)   
    VALUES(m_id_local,
           p_cod_empresa,
           p_num_ordem,
           m_dat_proces,
           m_msg)
   
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
           ' gravando dados na tabela local_erro_547'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol1346_proces_data()#
#-----------------------------#

   DISPLAY 'Processando data... ' AT 5,10
   #lds CALL LOG_refresh_display()
   
   DECLARE cq_ordens CURSOR WITH HOLD FOR
    SELECT o.num_ordem, o.cod_item, o.cod_item_pai, 
           o.dat_entrega, o.ies_situa,
           ord.num_pedido, ord.num_sequencia   
      FROM ordens o, ord_ped_item_547 ord
     WHERE o.cod_empresa = p_cod_empresa
       AND o.ies_situa = '3'
       AND o.cod_item_pai = '0'
       AND o.num_ordem NOT IN
           (SELECT x.num_ordem FROM limite_proces_547 x
             WHERE x.cod_empresa = p_cod_empresa)
       AND o.cod_empresa = ord.cod_empresa
       AND o.num_ordem = ord.num_ordem

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' declarando cursor cq_ordens (DECLARE)'           
      RETURN FALSE
   END IF
        
   FOREACH cq_ordens INTO m_num_ordem, m_cod_item, 
      m_cod_item_pai, m_dat_entrega, m_ies_situa, 
      m_num_pedido, m_seq_pedido     
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' iterando cursor cq_ordens (FOREACH)'           
         RETURN FALSE
      END IF

      DISPLAY m_num_ordem TO num_ordem
      #lds CALL LOG_refresh_display()
      
      LET m_op_pai = m_num_ordem   
      LET m_dt_entrega_pai = m_dat_entrega         
      LET m_tem_erro = FALSE
      LET m_ind_erro = 0
      INITIALIZE ma_erro TO NULL
      
      CALL log085_transacao("BEGIN")
      
      IF NOT pol1346_executa_ajustes() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF

      IF NOT m_tem_erro THEN
         IF NOT pol1346_calcula_data() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      END IF

      IF NOT m_tem_erro THEN
         IF NOT pol1346_ins_ord_limit_proces() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol1346_carrega_erro() THEN
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         END IF         
      END IF
      
      CALL log085_transacao("COMMIT")
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION  
   
#--------------------------------------#
FUNCTION pol1346_ins_ord_limit_proces()#
#--------------------------------------#
   
   INSERT INTO limite_proces_547 (
    cod_empresa,
    num_ordem,  
    dat_proces) 
   VALUES(p_cod_empresa,
          m_op_pai,
          m_dat_proces)
          
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
       ' gravando tabela limite_proces_547 (INSERT)'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1346_executa_ajustes()#
#---------------------------------#

 DEFINE l_qtd_refug, l_qtd_boas, 
        l_qtd_sucata, l_tot_apon  DECIMAL(10,3)
          
   DELETE FROM limite_erro_547 
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = m_num_pedido
      AND seq_pedido = m_seq_pedido

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' deletando registro da tabela limite_erro_547.'           
      RETURN FALSE
   END IF
                                                                                                     
   SELECT COUNT(*) INTO m_count                                                                      
     FROM ordens                                                                                     
    WHERE cod_empresa = p_cod_empresa                                                                
      AND cod_item_pai = '0'                                                                         
      AND ies_situa = '3'                                                                            
      AND num_ordem  IN                                                                              
         (SELECT num_ordem FROM ord_ped_item_547                                                     
           WHERE cod_empresa = p_cod_empresa                                                         
             AND num_pedido = m_num_pedido                                                           
             AND num_sequencia = m_seq_pedido)                                                       
                                                                                                  
   IF STATUS <> 0 THEN                                                                               
      LET m_texto = STATUS                                                                           
      LET m_msg = 'Erro ',m_texto CLIPPED,                                                           
       ' lendo pedido de vendas da tabela ord_ped_item_547.'                                         
      RETURN FALSE                                                                                   
   END IF                                                                                            
                                                                                                     
   IF m_count > 1 THEN                                                                               
      LET m_msg = 'Pedido ',m_num_pedido, ' sequencia ', m_seq_pedido,                               
       ' com mais de uma ordem de produção aberta.'                                                  
       IF NOT pol1346_guarda_erro() THEN                                                             
          RETURN FALSE                                                                               
       END IF                                                                                        
       RETURN TRUE                                                                              
   END IF                                                                                            

      
   DELETE FROM estrut_ordem_547
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = m_num_pedido
      AND seq_pedido = m_seq_pedido

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' deletando registro da tabela estrut_ordem_547.'           
      RETURN FALSE
   END IF

   DELETE FROM sequenc_calc_547
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = m_num_pedido
      AND seq_pedido = m_seq_pedido

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' deletando registro da tabela estrut_ordem_547.'           
      RETURN FALSE
   END IF
   
   LET m_id_registro = 0
   LET m_qtd_ant = 1

   IF NOT pol1346_ins_estrut(999) THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_estrut CURSOR FOR
    SELECT num_ordem, cod_item, cod_item_pai, dat_entrega, ies_situa,
           qtd_refug, qtd_boas, qtd_sucata 
      FROM ordens 
     WHERE cod_empresa = p_cod_empresa 
       AND ies_situa in ('3','4') 
       AND num_ordem <> m_num_ordem
       AND num_ordem IN 
          (SELECT num_ordem FROM ord_ped_item_547 
            WHERE cod_empresa = p_cod_empresa
              AND num_pedido = m_num_pedido AND num_sequencia = m_seq_pedido)
     ORDER BY num_ordem

   FOREACH cq_estrut INTO m_num_ordem, m_cod_item, 
      m_cod_item_pai, m_dat_entrega, m_ies_situa,
      l_qtd_refug, l_qtd_boas, l_qtd_sucata 

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' percorrendo cursor cq_estrut (FOREACH)'           
         RETURN FALSE
      END IF

      IF m_ies_situa = '4' THEN   
         LET m_msg = 'Pedido ',m_num_pedido CLIPPED, ' Sequencia ', m_seq_pedido, 
             ' possui ordens filhas liberadas '
         IF NOT pol1346_guarda_erro() THEN
            RETURN FALSE
         END IF
         EXIT FOREACH
      END IF

      SELECT COUNT(cod_operac) INTO m_count
        FROM ord_oper 
       WHERE cod_empresa = p_cod_empresa 
         AND num_ordem = m_num_ordem
         AND ies_apontamento = 'S' 

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' contando operações da tabela ord_oper'           
         RETURN FALSE
      END IF

      IF m_count = 0 THEN   
         LET m_msg = 'Pedido ',m_num_pedido CLIPPED, ' Sequencia ', m_seq_pedido, 
          ' Ordem ',m_num_ordem, ' sem roteiro de produção.'
         IF NOT pol1346_guarda_erro() THEN
            RETURN FALSE
         END IF
         EXIT FOREACH
      END IF
       
      IF NOT pol1346_ins_estrut(m_count) THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION
   
#--------------------------------------#
FUNCTION pol1346_ins_estrut(l_ord_proc)#
#--------------------------------------#
   
   DEFINE l_seq_info         INTEGER,
          l_des_inf_tecnica  CHAR(80),
          l_cod_pdr_info_tec INTEGER,
          l_ord_proc         decimal(3,0)
   
   SELECT cod_etapa INTO m_cod_etapa
     FROM item_man 
    WHERE cod_empresa = p_cod_empresa
      AND cod_item = m_cod_item

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' lendo item ',m_cod_item,' na tabela item_man.'           
      RETURN FALSE
   END IF

   IF m_cod_etapa IS NULL OR (m_cod_etapa <> 'G' AND m_cod_etapa <> 'P') THEN   
      LET m_msg = 'Item ',m_cod_item CLIPPED, 
          ' com definição de tamanho inválido na manufatura.'
       IF NOT pol1346_guarda_erro() THEN
          RETURN FALSE
       END IF
       RETURN TRUE
   END IF

   DECLARE cq_oper CURSOR FOR
    SELECT cod_operac, 
           num_seq_operac,
           num_processo
      FROM ord_oper 
     WHERE cod_empresa = p_cod_empresa 
       AND num_ordem = m_num_ordem
       AND ies_apontamento = 'S' 
     ORDER BY num_seq_operac  DESC

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' criando cursor cq_oper (DECLARE)'           
      RETURN FALSE
   END IF
   
   FOREACH cq_oper INTO m_cod_operac, m_seq_operac, m_num_processo
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' percorrendo cursor cq_oper (FOREACH)'           
         RETURN FALSE
      END IF
      
      LET l_seq_info = m_cod_operac
      
      IF m_cod_etapa = 'P' THEN
         LET l_cod_pdr_info_tec = 995
      ELSE
         LET l_cod_pdr_info_tec = 993
      END IF

      SELECT des_inf_tecnica 
        INTO l_des_inf_tecnica
        FROM info_tecnicas
       WHERE cod_empresa = p_cod_empresa
         AND cod_compon = 'TODOS'
         AND cod_pdr_info_tec = l_cod_pdr_info_tec
         AND num_seq = l_seq_info        

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' lendo informações técnicas para item ', m_cod_etapa
         RETURN FALSE
      END IF
      
      LET m_qtd_dias = l_des_inf_tecnica
      
      IF m_qtd_dias IS NULL THEN   
         LET m_msg = 'Informações técinicas do item ',m_cod_etapa CLIPPED,' inválida.'      
          IF NOT pol1346_guarda_erro() THEN
             RETURN FALSE
          END IF
          RETURN TRUE
      END IF
                              
      INSERT INTO estrut_ordem_547
       VALUES(m_id_registro,  p_cod_empresa, m_num_pedido,
              m_seq_pedido,   m_num_ordem,   m_cod_item,
              m_cod_item_pai, m_cod_operac,  m_seq_operac,
              m_num_processo, m_qtd_dias,    NULL,          
              l_ord_proc)
           
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' inserindo pedido ',m_num_pedido,' na tabela estrut_ordem_547'           
         RETURN FALSE
      END IF
      
      LET m_qtd_ant = m_qtd_dias
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1346_calcula_data()#
#------------------------------#
   
   DEFINE l_ord_processo     DECIMAL(3,0),
          l_dat_limite       DATE,
          l_dat_repet        DATE

   LET m_dat_entrega = m_dt_entrega_pai
   
   IF NOT pol1346_sequenciamento() THEN
      RETURN FALSE
   END IF

   IF NOT pol1346_grava_sequencia() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
FUNCTION pol1346_sequenciamento()#
#--------------------------------#

   DEFINE l_num_op         INTEGER,
          l_cod_oper       CHAR(05),
          l_op_ant         INTEGER,
          l_oper_igual     CHAR(05),
          l_seq_igual      DECIMAL(3,0),
          l_qtd_dias       DECIMAL(3,0)
   
   LET m_seq_calc = 1
   LET m_dias_subtrair = 1
   
   DECLARE cq_sequen CURSOR FOR
    SELECT id_registro, num_ordem, 
           cod_operac, num_processo,
           qtd_dias, ord_processo 
      FROM estrut_ordem_547 
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = m_num_pedido 
       AND seq_pedido = m_seq_pedido  
     ORDER BY ord_processo DESC, num_ordem, seq_operac DESC   
   
   FOREACH cq_sequen INTO m_id_registro, l_num_op, 
      l_cod_oper, m_num_processo, m_qtd_dias, m_ord_processo
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' iterando cursor cq_sequen (FOREACH)'           
         RETURN FALSE
      END IF
      
      SELECT COUNT(id_registro) INTO m_count
        FROM sequenc_calc_547
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido = m_num_pedido 
         AND seq_pedido = m_seq_pedido  
         AND cod_operac = l_cod_oper 

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' contando registros da tabela sequenc_calc_547)'           
         RETURN FALSE
      END IF
      
      IF m_count > 0 THEN
         CONTINUE FOREACH
      END IF
      
      DECLARE cq_iguais CURSOR FOR
       SELECT num_ordem, seq_operac
         FROM estrut_ordem_547 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
          AND seq_pedido = m_seq_pedido 
          AND cod_operac = l_cod_oper
          AND ord_processo < m_ord_processo

      FOREACH cq_iguais INTO l_op_ant, l_seq_igual
      
         IF STATUS <> 0 THEN
            LET m_texto = STATUS
            LET m_msg = 'Erro ',m_texto CLIPPED, 
             ' iterando cursor cq_iguais (FOREACH)'           
            RETURN FALSE            
         END IF
         
         DECLARE cq_antes CURSOR FOR
          SELECT cod_operac, qtd_dias
            FROM estrut_ordem_547 
           WHERE cod_empresa = p_cod_empresa
             AND num_pedido = m_num_pedido 
             AND seq_pedido = m_seq_pedido 
             AND num_ordem = l_op_ant
             AND seq_operac > l_seq_igual
           ORDER BY seq_operac DESC
          

         FOREACH cq_antes INTO l_oper_igual, l_qtd_dias
      
            IF STATUS <> 0 THEN
               LET m_texto = STATUS
               LET m_msg = 'Erro ',m_texto CLIPPED, 
                ' iterando cursor cq_antes (FOREACH)'           
               RETURN FALSE            
            END IF

            SELECT COUNT(id_registro) INTO m_count                   
              FROM sequenc_calc_547                                  
             WHERE cod_empresa = p_cod_empresa                       
               AND num_pedido = m_num_pedido                         
               AND seq_pedido = m_seq_pedido                         
               AND cod_operac = l_oper_igual                         
                                                                     
            IF STATUS <> 0 THEN                                      
               LET m_texto = STATUS                                  
               LET m_msg = 'Erro ',m_texto CLIPPED,                  
                ' contando registros da tabela sequenc_calc_547:cq_antes)'     
               RETURN FALSE                                          
            END IF                                                   
                                                                     
            IF m_count > 0 THEN                                      
               CONTINUE FOREACH                                      
            END IF                                                   
            
            IF NOT pol1346_ins_sequenc(l_op_ant,l_oper_igual,l_qtd_dias) THEN
               RETURN FALSE
            END IF
         
         END FOREACH
         
      END FOREACH
      
      IF NOT pol1346_ins_sequenc(l_num_op,l_cod_oper,m_qtd_dias) THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   RETURN TRUE
   
END FUNCTION   

#-----------------------------------------------------#
FUNCTION pol1346_ins_sequenc(l_op, l_oper, l_qtd_dias)#
#-----------------------------------------------------#
   
   DEFINE l_op           INTEGER,
          l_oper         CHAR(05),
          l_subtrair     DECIMAL(3,0),
          l_data         DATE,
          l_seq_info     INTEGER,
          l_info_tec     INTEGER,
          l_des_info     CHAR(80),
          l_qtd_dias     DECIMAL(3,0)
             
   IF l_qtd_dias > 0 THEN 
      LET l_subtrair = m_dias_subtrair
      LET m_dias_subtrair = l_qtd_dias
      IF NOT pol1346_checa_data(l_oper, l_subtrair) THEN
         RETURN FALSE
      END IF
      LET l_data = m_dat_entrega
   ELSE
      LET l_subtrair = 0
      LET l_data = NULL
   END IF
      
   INSERT INTO sequenc_calc_547 (
               cod_empresa,
               num_pedido,
               seq_pedido,
               num_ordem,
               cod_operac,
               seq_calculo,
               qtd_dias,
               dat_limite,
               dias_subtrair)
    VALUES(p_cod_empresa, 
           m_num_pedido,
           m_seq_pedido,
           l_op, 
           l_oper, 
           m_seq_calc,
           l_qtd_dias,
           l_data,
           l_subtrair)

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' inserindo registro na tabela sequenc_calc_547'           
      RETURN FALSE            
   END IF
   
   LET m_seq_calc = m_seq_calc + 1
      
   RETURN TRUE

END FUNCTION
           
#------------------------------------------#
FUNCTION pol1346_checa_data(l_oper, l_dias)#
#------------------------------------------#
   
   DEFINE l_oper         CHAR(05),
          l_dias         decimal(3,0)
          
   WHILE l_dias > 0 
   
      LET m_dat_entrega = m_dat_entrega - 1     
              
      WHILE TRUE                               
         IF NOT pol1346_checa_dia() THEN       
            RETURN FALSE                       
         END IF                                
         IF m_dia_util THEN                    
            EXIT WHILE                         
         END IF                                
         LET m_dat_entrega = m_dat_entrega - 1 
      END WHILE  
      
      LET l_dias = l_dias - 1             
                                  
   END WHILE
   
   IF NOT pol1346_upd_estrut(m_dat_entrega, l_oper) THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol1346_checa_dia()#
#---------------------------#

   DEFINE l_dia         INTEGER,
          l_ies_situa   CHAR(01)
   
   LET m_dia_util = FALSE
   LET l_dia = WEEKDAY(m_dat_entrega) 

   SELECT ies_situa 
     INTO l_ies_situa
     FROM semana
    WHERE cod_empresa = p_cod_empresa
      AND ies_dia_semana = l_dia

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED,
       ' lendo a tabela semana - dia = ',l_dia USING '<'       
      RETURN FALSE
   END IF
   
   IF l_ies_situa = '3' THEN
      RETURN TRUE
   END IF

   SELECT ies_situa 
     INTO l_ies_situa
     FROM feriado
    WHERE cod_empresa = p_cod_empresa
      AND dat_ref = m_dat_entrega

   IF STATUS = 100 THEN
      LET m_dia_util = TRUE
   ELSE
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED,
          ' lendo a tabela feriado - data = ',m_dat_entrega    
         RETURN FALSE
      ELSE
         IF l_ies_situa = '3' THEN
         ELSE
            LET m_dia_util = TRUE
         END IF
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION
           
#-----------------------------------------#
FUNCTION pol1346_upd_estrut(l_data,l_oper)#
#-----------------------------------------#
   
   DEFINE l_data       DATE
   DEFINE l_oper       CHAR(05)
      
   UPDATE estrut_ordem_547
      SET dat_limite = l_data
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido = m_num_pedido
      AND seq_pedido = m_seq_pedido
      AND cod_operac = l_oper

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' gravando data limite tabela estrut_ordem_547 (UPDATE)'           
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION   
           
#---------------------------------#           
FUNCTION pol1346_grava_sequencia()#
#---------------------------------#
   
   DEFINE l_dat_limite   DATE,
          l_texto        CHAR(40),
          l_achou        SMALLINT
   
   DECLARE cq_grv_seq CURSOR FOR
    SELECT id_registro, 
           num_ordem, 
           cod_operac,
           seq_operac
      FROM estrut_ordem_547 
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = m_num_pedido 
       AND seq_pedido = m_seq_pedido  
       AND qtd_dias = 0
   
   FOREACH cq_grv_seq INTO 
      m_id_registro, m_num_ordem, m_cod_operac, m_seq_operac
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' iterando cursor cq_grv_seq (FOREACH)'           
         RETURN FALSE
      END IF
      
      LET l_achou = FALSE
      
      DECLARE cq_prox_oper CURSOR FOR
       SELECT dat_limite
         FROM estrut_ordem_547 
        WHERE cod_empresa = p_cod_empresa
          AND num_pedido = m_num_pedido 
          AND seq_pedido = m_seq_pedido 
          AND num_ordem = m_num_ordem
          AND seq_operac > m_seq_operac
        ORDER BY seq_operac 
        
      FOREACH cq_prox_oper INTO l_dat_limite
      
         IF STATUS <> 0 THEN
            LET m_texto = STATUS
            LET m_msg = 'Erro ',m_texto CLIPPED, 
             ' iterando cursor cq_prox_oper (FOREACH:cq_prox_oper)'           
            RETURN FALSE            
         END IF
         
         UPDATE estrut_ordem_547
           SET dat_limite = l_dat_limite
         WHERE cod_empresa = p_cod_empresa
           AND id_registro = m_id_registro

         IF STATUS <> 0 THEN
            LET m_texto = STATUS
            LET m_msg = 'Erro ',m_texto CLIPPED, 
                ' gravando data limite tabela estrut_ordem_547 (UPDATE)'           
            RETURN FALSE
         END IF
         
         LET l_achou = TRUE
         
         EXIT FOREACH
         
      END FOREACH
      
      IF NOT l_achou THEN
         DECLARE cq_ant_oper CURSOR FOR                                    
          SELECT dat_limite                                                 
            FROM estrut_ordem_547                                           
           WHERE cod_empresa = p_cod_empresa                                
             AND num_pedido = m_num_pedido                                  
             AND seq_pedido = m_seq_pedido                                  
             AND num_ordem = m_num_ordem                                    
             AND seq_operac < m_seq_operac                                  
           ORDER BY seq_operac DESC                                        
                                                                            
         FOREACH cq_ant_oper INTO l_dat_limite                             
                                                                            
            IF STATUS <> 0 THEN                                             
               LET m_texto = STATUS                                         
               LET m_msg = 'Erro ',m_texto CLIPPED,                         
                ' iterando cursor cq_prox_oper (FOREACH:cq_ant_oper)'                   
               RETURN FALSE                                                 
            END IF                                                          
                                                                            
            UPDATE estrut_ordem_547                                         
              SET dat_limite = l_dat_limite                                 
            WHERE cod_empresa = p_cod_empresa                               
              AND id_registro = m_id_registro                               
                                                                            
            IF STATUS <> 0 THEN                                             
               LET m_texto = STATUS                                         
               LET m_msg = 'Erro ',m_texto CLIPPED,                         
                   ' gravando data limite tabela estrut_ordem_547 (UPDATE)' 
               RETURN FALSE                                                 
            END IF                                                                 
                                                                            
            LET l_achou = TRUE                                              
                                                                            
            EXIT FOREACH                                                    
                                                                            
         END FOREACH                                                        
        
      END IF
      
   END FOREACH

   DECLARE cq_grv_txt CURSOR FOR
    SELECT num_ordem, 
           cod_operac,
           seq_operac,
           num_processo,
           dat_limite,
           qtd_dias
      FROM estrut_ordem_547 
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = m_num_pedido 
       AND seq_pedido = m_seq_pedido  
   
   FOREACH cq_grv_txt INTO 
      m_num_ordem, m_cod_operac, m_seq_operac, m_num_processo, l_dat_limite, m_qtd_dias
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' iterando cursor cq_grv_txt (FOREACH)'           
         RETURN FALSE
      END IF

      LET l_texto = m_seq_operac USING '<<<','/',m_cod_operac CLIPPED,'/',m_qtd_dias USING '<<<',' dias'
                                                                                    
      DELETE FROM ord_oper_txt                                                      
       WHERE cod_empresa = p_cod_empresa                                            
         AND num_ordem = m_num_ordem                                                
         AND num_processo = m_num_processo                                          
         AND ies_tipo = 'Q'                                                         
                                                                                    
      IF STATUS <> 0 THEN                                                           
         LET m_texto = STATUS                                                       
         LET m_msg = 'Erro ',m_texto CLIPPED,                                       
          ' deletando registro da tabela ord_oper_txt '                             
         RETURN FALSE                                                               
      END IF                                                                        
                                                                                    
      INSERT INTO ord_oper_txt                                                      
       VALUES(p_cod_empresa, m_num_ordem, m_num_processo,                           
              'Q', 1, l_texto , l_dat_limite)                                             
                                                                                    
      IF STATUS <> 0 THEN                                                           
         LET m_texto = STATUS                                                       
         LET m_msg = 'Erro ',m_texto CLIPPED,                                       
          ' gravando data limite tabela ord_oper_txt (INSERT)'                      
         RETURN FALSE                                                               
      END IF                                                                              
              
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION   
              
#------------------------------#      
FUNCTION pol1346_proces_local()#
#------------------------------#

   DISPLAY 'Processando local... ' AT 5,10
   #lds CALL LOG_refresh_display()
   
   IF NOT pol1346_cria_temp() THEN
      RETURN FALSE
   END IF
   
   DECLARE cq_ord_local CURSOR WITH HOLD FOR
    SELECT o.num_ordem FROM ordens o 
     WHERE o.cod_empresa = p_cod_empresa
       AND o.ies_situa = '3'
       AND o.cod_item_pai = '0'
       AND o.num_ordem NOT IN
           (SELECT x.num_ordem FROM local_proces_547 x
             WHERE x.cod_empresa = p_cod_empresa)

   FOREACH cq_ord_local INTO m_num_ordem
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' iterando cursor cq_ord_local (FOREACH)'           
         RETURN FALSE
      END IF
      
      LET m_houve_erro = FALSE
      LET p_num_ordem = m_num_ordem

      DISPLAY m_num_ordem TO num_ordem
      #lds CALL LOG_refresh_display()

      DELETE FROM local_erro_547 
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = p_num_ordem

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' deletando registro da tabela local_erro_547.'           
         CALL pol1346_grv_erro() RETURNING p_status
      END IF

      CALL log085_transacao("BEGIN")

      IF NOT pol1346_ins_local_proces() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF                  
      
      IF NOT pol1346_le_ops_filha() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
      
      IF m_houve_erro THEN
         CALL log085_transacao("ROLLBACK")
         CALL pol1346_grv_erro() RETURNING p_status
         CONTINUE FOREACH
      END IF
      
      IF NOT pol1346_muda_local() THEN
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF            

      IF m_houve_erro THEN
         CALL log085_transacao("ROLLBACK")
         CALL pol1346_grv_erro() RETURNING p_status
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION  

#---------------------------#
FUNCTION pol1346_cria_temp()#
#---------------------------#

   DROP TABLE op_temp_547;
   CREATE TEMP TABLE op_temp_547 (
    num_op      INTEGER,
    processada  CHAR(01)
   );
   
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' criando table temporária op_temp_547'           
      RETURN FALSE
   END IF   
   
   CREATE UNIQUE INDEX ix_op_temp_547 ON op_temp_547(num_op);
   
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ',m_texto CLIPPED, 
       ' criando indice da temporária op_temp_547'           
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION
  
#----------------------------------#
FUNCTION pol1346_ins_local_proces()#
#----------------------------------#

   INSERT INTO local_proces_547(
    cod_empresa, num_ordem, dat_proces)
    VALUES(p_cod_empresa,p_num_ordem,m_dat_proces)

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, ' gravando tabela local_proces_547'
      RETURN FALSE
   END IF
   
   LET m_id_local = SQLCA.SQLERRD[2]
   
   RETURN TRUE

END FUNCTION          

#------------------------------#
FUNCTION pol1346_le_ops_filha()#
#------------------------------#
   
   DEFINE l_qtd_refug, l_qtd_boas, 
          l_qtd_sucata, l_tot_apon  DECIMAL(10,3),
          l_ies_situa               CHAR(01),
          p_count                   INTEGER
   
   DELETE FROM op_temp_547

   SELECT COUNT(*) INTO m_count FROM op_temp_547
   
   IF m_count > 0 THEN
      LET m_msg = 'Não foi possivel limpar a tab op_temp_547 '        
      RETURN FALSE
   END IF
      
   IF NOT pol1074_op_temp_ins() THEN
      RETURN FALSE
   END IF
       
   LET p_count = 1
      
   WHILE p_count > 0
      
      LET p_count = 0
            
      DECLARE cq_op_temp CURSOR FOR
       SELECT num_op
         FROM op_temp_547 WHERE processada = 'N'
      
      FOREACH cq_op_temp INTO m_num_ordem
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_op_temp')  
            RETURN FALSE
         END IF

         UPDATE op_temp_547 SET processada = 'S'
          WHERE num_op = m_num_ordem

         IF STATUS <> 0 THEN
            CALL log003_err_sql('UPDATE','op_temp_547')  
            RETURN FALSE
         END IF
                  
         DECLARE cq_neces_op CURSOR FOR
          SELECT cod_item_pai,
                 cod_item_compon
            FROM ord_compon
           WHERE cod_empresa = p_cod_empresa
             AND num_ordem   = m_num_ordem
             AND ies_tip_item IN ('P','F')
         
         FOREACH cq_neces_op INTO m_num_neces, m_cod_item

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','cq_neces_op')  
               RETURN FALSE
            END IF
            
            LET p_count = 1
            LET m_tem_op = FALSE
            
            DECLARE cq_op_nec CURSOR FOR
             SELECT num_ordem, ies_situa,
               qtd_refug, qtd_boas, qtd_sucata
               FROM ordens 
              WHERE cod_empresa = p_cod_empresa
                AND num_neces = m_num_neces
                AND cod_item = m_cod_item
                AND ies_situa in ('3','4','9')
            
            FOREACH cq_op_nec INTO m_num_ordem, l_ies_situa, 
               l_qtd_refug, l_qtd_boas, l_qtd_sucata

               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo','cq_op_nec')  
                  RETURN FALSE
               END IF

               LET m_tem_op = TRUE
               
               IF l_ies_situa = '4' THEN
                  LET m_msg = 'Ordem pai:', p_num_ordem USING '<<<<<<<<<'
                  LET m_msg = m_msg CLIPPED,' Ordem filha ', m_num_ordem USING '<<<<<<<<<'
                  LET m_msg = m_msg CLIPPED, ' Já está liberada.'
                  LET m_houve_erro = TRUE    
                  RETURN TRUE              
               ELSE
                  IF NOT pol1074_op_temp_ins() THEN
                     RETURN FALSE
                  END IF               
               END IF                                 
               
               EXIT FOREACH

            END FOREACH
            
            IF NOT m_tem_op THEN
               LET m_msg = 'Ordem ', m_num_ordem USING '<<<<<<<<<'
               LET m_msg = m_msg CLIPPED, '. Compon ', m_cod_item
               LET m_msg = m_msg CLIPPED, ' Sem ordem aberta ou cancelada.'
               LET m_houve_erro = TRUE
            END IF
               
         END FOREACH
                  
      END FOREACH
      
   END WHILE

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol1074_op_temp_ins()#
#-----------------------------#

   INSERT INTO op_temp_547
    VALUES(m_num_ordem, 'N')

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, ' inserindo OP na taabela op_temp_547'
      RETURN FALSE
   END IF
  
   RETURN TRUE

END FUNCTION   


#----------------------------#
FUNCTION pol1346_muda_local()#
#----------------------------#   
   
   DECLARE cq_muda CURSOR FOR
    SELECT ordens.num_neces,
           ordens.num_ordem, 
           ordens.cod_item, 
           ordens.cod_item_pai, 
           ordens.cod_local_prod, 
           ordens.cod_local_estoq, 
           ordens.dat_entrega,
           ordens.num_docum   
      FROM ordens, op_temp_547
     WHERE ordens.cod_empresa = p_cod_empresa 
       AND ordens.num_ordem = op_temp_547.num_op
     ORDER BY ordens.num_ordem

   FOREACH cq_muda INTO m_num_neces, m_num_ordem, m_cod_item, 
           m_cod_item_pai, m_cod_local_prod, 
           m_cod_local_estoq, m_dat_entrega, m_num_docum
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' iterando cursor cq_muda.'
         RETURN FALSE
      END IF

      IF NOT pol1346_gera_local() THEN
         RETURN FALSE
      END IF

      IF m_cod_item_pai = '0' THEN
      ELSE      
         LET m_cod_local_estoq = m_cod_local
      END IF

      IF NOT pol1346_conta_compon() THEN
         RETURN FALSE
      END IF
      
      IF m_count > 0 THEN
         LET m_cod_local_prod = m_cod_local
      END IF
            
      INSERT INTO op_local_547 
       VALUES(m_id_local, p_cod_empresa, m_num_neces, m_num_ordem, 
              m_num_docum, m_cod_item, m_cod_item_pai, 
              m_cod_local_prod, m_cod_local_estoq, m_dat_entrega)
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' inserindo OP na taabela op_local_547 - OP ',m_num_ordem
         RETURN FALSE
      END IF
      
   END FOREACH
   
   IF NOT pol1346_local_baixa() THEN
     RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1346_conta_compon()#
#------------------------------#
   
   DEFINE l_cod_familia     LIKE item.cod_familia
   
   LET m_count = 0
   
   DECLARE cq_count CURSOR FOR
    SELECT DISTINCT i.cod_familia 
      FROM ord_compon o, item i
     WHERE o.cod_empresa = p_cod_empresa 
       AND o.num_ordem = m_num_ordem
       AND i.cod_empresa = o.cod_empresa
       AND i.cod_item = o.cod_item_compon
       
   FOREACH cq_count INTO l_cod_familia
         
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' lendo ord_compon.cq_count'
         RETURN FALSE
      END IF

      SELECT 1 
        FROM it_pdr_info_tec 
       WHERE cod_pdr_info_tec = '999'
         AND tit_inf_tecnica = l_cod_familia
      
      IF STATUS = 100 THEN
         LET m_count = 1
         EXIT FOREACH
      END IF

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ',m_texto CLIPPED, 
          ' lendo tabela it_pdr_info_tec'           
         RETURN FALSE
      END IF   
      
   END FOREACH
      
   RETURN TRUE

END FUNCTION
   
#---------------------------#
FUNCTION pol1346_gera_local()#
#---------------------------#

   DEFINE l_den_local   LIKE local.den_local,
          l_num_nivel   LIKE local.num_nivel
   
   LET m_cod_local = 'OP',m_num_ordem USING '<<<<<<<<'
   LET l_den_local = 'UTILIZADO EXCLUS.P/ BAIXAR OP'
   LET l_num_nivel = 0
   
   SELECT 1 FROM local
    WHERE cod_empresa = p_cod_empresa
      AND cod_local = m_cod_local
   
   IF STATUS = 100 THEN

      INSERT INTO local
       VALUES(p_cod_empresa,
              m_cod_local, 
              l_den_local,
              l_num_nivel)              

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' inserindo dados na tabela local'
         RETURN FALSE
      END IF

   ELSE
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' lendo dados da tabela local'
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   

#-----------------------------#
FUNCTION pol1346_local_baixa()#
#-----------------------------#
   
   DEFINE l_cod_local    LIKE item.cod_local_estoq, 
          l_cod_familia  LIKE item.cod_familia
   
   DECLARE cq_loc_baixa CURSOR FOR
    SELECT num_ordem, 
           cod_item,       
           cod_item_pai,   
           cod_local_prod, 
           cod_local_estoq
      FROM op_local_547 
     WHERE id_local = m_id_local
     ORDER BY num_ordem
   
   FOREACH cq_loc_baixa INTO m_num_ordem, m_cod_item, 
      m_cod_item_pai, m_cod_local_prod, m_cod_local_estoq

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' iterando cursor cq_loc_baixa.'
         RETURN FALSE
      END IF
      
      UPDATE ordens
         SET cod_local_prod = m_cod_local_prod,
             cod_local_estoq = m_cod_local_estoq
       WHERE cod_empresa = p_cod_empresa
         AND num_ordem = m_num_ordem

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, ' atualizando locais da tab ordens.'
         RETURN FALSE
      END IF
      
      DECLARE cq_strut_op CURSOR FOR
       SELECT o.cod_item_pai, o.cod_item_compon, o.ies_tip_item
         FROM ord_compon o, item i
        WHERE o.cod_empresa = p_cod_empresa
          AND o.num_ordem = m_num_ordem
          AND i.cod_empresa = o.cod_empresa
          AND i.cod_item = o.cod_item_compon
          AND i.ies_situacao = 'A'
          AND i.ies_ctr_estoque = 'S'
          
      FOREACH cq_strut_op INTO m_num_neces, m_cod_compon, m_ies_tip_item

         IF STATUS <> 0 THEN
            LET m_texto = STATUS
            LET m_msg = 'Erro ', m_texto CLIPPED, ' iterando cursor cq_strut_op.'
            RETURN FALSE
         END IF
         
         LET m_cod_local = m_cod_local_prod
         
         IF m_ies_tip_item MATCHES "[FP]" THEN
            LET m_msg = 'op_local_547.neces =  ',m_num_neces
            SELECT cod_local_estoq
              INTO m_cod_local FROM op_local_547 
             WHERE cod_empresa = p_cod_empresa
               AND num_neces = m_num_neces 
               AND id_local = m_id_local
            IF STATUS <> 0 THEN
               LET m_texto = STATUS
               LET m_msg = m_msg CLIPPED, '- Erro ', m_texto CLIPPED, ' lendo tab op_local_547'
               LET m_houve_erro = TRUE
               RETURN TRUE
            END IF
         ELSE
            SELECT cod_local_estoq, cod_familia 
              INTO l_cod_local, l_cod_familia
              FROM Item  WHERE cod_empresa = p_cod_empresa
               AND cod_item = m_cod_compon
            IF STATUS <> 0 THEN
               LET m_texto = STATUS
               LET m_msg = m_msg CLIPPED, '- Erro ', m_texto CLIPPED, ' lendo tab item'
               RETURN FALSE
            END IF

            SELECT 1 
              FROM it_pdr_info_tec 
             WHERE cod_pdr_info_tec = '999'
               AND tit_inf_tecnica = l_cod_familia
      
            IF STATUS = 0 THEN
               LET m_cod_local = l_cod_local
            ELSE
               IF STATUS <> 100 THEN
                  LET m_texto = STATUS
                  LET m_msg = m_msg CLIPPED, '- Erro ', m_texto CLIPPED, ' lendo tab it_pdr_info_tec'
                  RETURN FALSE
               END IF
            END IF     
         END IF
         
         IF NOT pol1346_atu_local_baixa() THEN
            RETURN FALSE
         END IF
         
      END FOREACH
      
   END FOREACH
   
   LET m_msg = ''
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol1346_atu_local_baixa()#
#---------------------------------#

   UPDATE ord_compon 
      SET cod_local_baixa = m_cod_local
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_item_pai = m_num_neces
            
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
           ' atualizando loca de baixa da tabela ord_compon'
      RETURN FALSE
   END IF

   UPDATE man_op_componente_operacao 
      SET local_baixa = m_cod_local
    WHERE empresa = p_cod_empresa
      AND ordem_producao = m_num_ordem
      AND item_componente = m_cod_compon
      AND sequencia_componente = m_num_neces
            
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
           ' atualizando loca de baixa da tabela man_op_componente_operacao'
      RETURN FALSE
   END IF
   
   DELETE FROM loc_baixa_547
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem = m_num_ordem
      AND cod_item_pai = m_num_neces

   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
           ' deletando registro da tabela loc_baixa_547'
      RETURN FALSE
   END IF
   
   INSERT INTO loc_baixa_547
    VALUES(p_cod_empresa, m_num_ordem, m_num_neces, 
           m_cod_local, m_cod_compon, m_ies_tip_item)
    
   IF STATUS <> 0 THEN
      LET m_texto = STATUS
      LET m_msg = 'Erro ', m_texto CLIPPED, 
           ' inserindo registro da tabela loc_baixa_547'
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol1346_ajusta_chapa()#
#------------------------------#
   
   DEFINE l_cod_item       LIKE item.cod_item,
          l_cod_local      LIKE item.cod_local_estoq,
          l_num_ordem      LIKE ord_compon.num_ordem,
          l_cod_item_pai   LIKE ord_compon.cod_item_pai

   DECLARE cq_chapa CURSOR FOR           
    SELECT ord_compon.num_ordem, ord_compon.cod_item_pai,
           item.cod_item, item.cod_local_estoq
      FROM item, ord_compon, necessidades
     WHERE item.cod_empresa = p_cod_empresa
       AND item.cod_item like '10-510%'
       AND item.cod_empresa = ord_compon.cod_empresa
       AND item.cod_item = ord_compon.cod_item_compon
       AND item.cod_local_estoq <> ord_compon.cod_local_baixa
       AND necessidades.cod_empresa = ord_compon.cod_empresa
       AND necessidades.num_neces = ord_compon.cod_item_pai
       AND necessidades.ies_situa = '3'
                 
   FOREACH cq_chapa INTO l_num_ordem, l_cod_item_pai, l_cod_item, l_cod_local   
      
      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, 
              ' lendo dados do cursor cq_chapa'
         RETURN FALSE
      END IF
      
      UPDATE ord_compon SET cod_local_baixa = l_cod_local
       WHERE cod_empresa = p_cod_empresa
         AND cod_item_compon = l_cod_item
         AND num_ordem = l_num_op
         AND cod_item_pai = l_cod_item_pai

      IF STATUS <> 0 THEN
         LET m_texto = STATUS
         LET m_msg = 'Erro ', m_texto CLIPPED, 
              ' atualizando dados da tabela ord_compon:cq_chapa'
         RETURN FALSE
      END IF
      
   END FOREACH
    
   RETURN TRUE
   
END FUNCTION
