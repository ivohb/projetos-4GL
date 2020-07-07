#-----------------------------------------------------------------------#
# SISTEMA.: VENDAS DISTRIBUICAO DE PRODUTOS                             #
# PROGRAMA: pol0816                                                     #
# MODULOS.: pol0816 - LOG0010 - LOG0030 - LOG0040 - LOG0050             #
#           LOG0060 - LOG0090 - LOG0190 - LOG0270 - LOG1200             #
#           LOG1300 - LOG1400 - VDP0050 - VDP0120 - VDP0140             #
# OBJETIVO: BLOQUEIO DE ROMANEIO AUTOMATICO                             #
# AUTOR...: LOGOCENTER GSP - MANUEL                                     #
# DATA....: 03/06/2008                                                  #
#-----------------------------------------------------------------------# 
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_den_empresa          LIKE empresa.den_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_num_om               LIKE ORdem_montag_mest.num_om,
          p_texto                LIKE audit_logix.texto,
          p_bloqueou             SMALLINT,
          p_msg                  CHAR(300),
          p_erro                 CHAR(01),
          p_houve_erro           SMALLINT,
          p_pula_oc              CHAR(01),
          p_count                SMALLINT,
          p_tem_oc               SMALLINT,          
          p_rowid                INTEGER,
          p_comando              CHAR(80),
          p_caminho              CHAR(80), 
          p_data                 DATE,
          p_hora                 CHAR(08),
          p_nom_tela             CHAR(80),
          p_help                 CHAR(80),
          p_insere               SMALLINT,
          p_last_row             SMALLINT,
          p_status               SMALLINT,
          pa_curr                SMALLINT,
          sc_curr                SMALLINT,
          p_i                    SMALLINT,
          p_cancel               INTEGER 

   DEFINE p_versao               CHAR(18) 

   DEFINE p_par_cliente_159     RECORD LIKE par_cliente_159.*,
          p_ordem_montag_mest   RECORD LIKE ordem_montag_mest.*,
          p_num_pedido          LIKE pedidos.num_pedido,
          p_cod_item            LIKE item.cod_item


                   


END GLOBALS 

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0816-10.02.00"
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 7
   WHENEVER ERROR STOP
   DEFER INTERRUPT
  
   CALL log140_procura_caminho("POL.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP     FILE p_help,
      INSERT   KEY control-i,
      DELETE   KEY control-e,
      PREVIOUS KEY control-b,
      NEXT     KEY control-f
  CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  

   IF p_status = 0 THEN 
      CALL pol0816_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0816_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0816") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0816 AT 06,23 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE   
         
   IF pol0816_bloqueia_om() THEN
      CALL log085_transacao("COMMIT")
      WHENEVER ERROR CONTINUE   
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF
   
    
END FUNCTION   
   
#---------------------------------#
 FUNCTION pol0816_bloqueia_om()
#---------------------------------#
          
   DEFINE p_ies_verifica_item CHAR(01),
          p_cod_cliente       LIKE clientes.cod_cliente
  	         
   DECLARE cq_entrada CURSOR FOR
    SELECT DISTINCT a.num_om 
      FROM ordem_montag_mest a
      WHERE  a.cod_empresa = p_cod_empresa  
        AND  a.ies_sit_om  = 'N' 
        AND  a.num_om  NOT IN 
           (SELECT num_om FROM ver_rom_912  WHERE cod_empresa=p_cod_empresa)
      
   INITIALIZE p_ordem_montag_mest.* TO NULL

   FOREACH cq_entrada INTO p_num_om
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_entrada')
         RETURN FALSE
      END IF
   
      DECLARE cq_it CURSOR FOR
       SELECT DISTINCT num_pedido
         FROM ordem_montag_item
        WHERE cod_empresa = p_cod_empresa 
          AND num_om      = p_num_om
      
      FOREACH cq_it INTO p_num_pedido

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_it')
            RETURN FALSE
         END IF
       
         SELECT cod_cliente
           INTO p_cod_cliente
           FROM pedidos
          WHERE cod_empresa = p_cod_empresa 
            AND num_pedido  = p_num_pedido

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','pedidos')
            RETURN FALSE
         END IF
           
         SELECT ies_verifica_item
           INTO p_ies_verifica_item
           FROM par_cliente_159
          WHERE cod_empresa = p_cod_empresa 
            AND cod_cliente = p_cod_cliente

         IF STATUS = 100 THEN
            EXIT FOREACH
         END IF
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','par_cliente_159')
            RETURN FALSE
         END IF
         
         IF p_ies_verifica_item IS NULL THEN
            IF NOT pol0816_efetua_bloqueio() THEN
               RETURN FALSE
            END IF
            EXIT FOREACH
         ELSE
            IF p_ies_verifica_item <> 'S' THEN
               IF NOT pol0816_efetua_bloqueio() THEN
                  RETURN FALSE
               END IF
               EXIT FOREACH
            ELSE
               IF NOT pol0816_verif_item() THEN
                  RETURN FALSE
               END IF
               EXIT FOREACH
            END IF 
         END IF
                  
       END FOREACH
                
    END FOREACH     
           
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0816_verif_item()
#----------------------------#

   LET p_bloqueou = FALSE
   
   DECLARE cq_itens CURSOR FOR
    SELECT DISTINCT cod_item
      FROM ordem_montag_item
     WHERE cod_empresa = p_cod_empresa 
       AND num_om      = p_num_om

   FOREACH cq_itens INTO p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_itens')
         RETURN FALSE
      END IF
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM item_ppte_159
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item_ppte_159')
         RETURN FALSE
      END IF
         
      IF p_count > 0 THEN
         IF NOT pol0816_efetua_bloqueio() THEN
            RETURN FALSE
         END IF
         LET p_bloqueou = TRUE
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0816_efetua_bloqueio()
#---------------------------------#
      
         LET p_data = TODAY
         LET p_hora = TIME
         INITIALIZE  p_texto TO NULL 
   
         UPDATE ordem_montag_mest 
         SET ies_sit_om = 'B'
         WHERE cod_empresa = p_cod_empresa 
         AND   num_om      = p_num_om 
         
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Atualizando','ordem_montag_mest')  
            RETURN FALSE
         END IF

         LET p_texto = "Romaneio bloqueado: ", p_num_om USING "<<<<<&"

         INSERT INTO audit_logix VALUES (p_cod_empresa,
                                         p_texto,
                                         'POL0816',
                                         p_data,
                                         p_hora,
                                         p_user)

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Inserindo','audit_logix')  
            RETURN FALSE
         END IF
                  
         RETURN TRUE
         
END FUNCTION

