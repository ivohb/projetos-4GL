#-----------------------------------------#
# PROGRAMA: POL0811                       #
# OBJETIVO: CANCELAMENTO DE PEDIDO        #
#-----------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_pedidos          RECORD LIKE pedidos.*,
          p_pedidose         RECORD LIKE pedidos.*,
          p_ped_itens        RECORD LIKE ped_itens.*,
          p_empresas_885     RECORD LIKE empresas_885.*,
          p_audit_vdp        RECORD LIKE audit_vdp.*,
          p_ped_itens_cancel RECORD LIKE ped_itens_cancel.*,
          p_mot_cancel       RECORD LIKE mot_cancel.*,
          p_ped_itens_orig_885 RECORD LIKE ped_itens_orig_885.*,
          p_ped_itens_peso_885 RECORD LIKE ped_itens_peso_885.*,
          p_mot_cancel       RECORD LIKE mot_cancel.*,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_cod_emp_aux      LIKE empresa.cod_empresa,
          p_cod_emp_ord      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_cliente      LIKE clientes.nom_cliente,
          p_num_docum        LIKE ordens.num_docum,
          p_ies_can_op       CHAR(1),
          p_num_ped_ch       CHAR(6),
          p_num_seq_ch       CHAR(4),
          p_ies_tem_it       CHAR(1),
          p_ies_cons         SMALLINT,
          p_last_row         SMALLINT,
          p_conta            SMALLINT,
          p_cont             SMALLINT,
          pa_curr            SMALLINT,
          sc_curr            SMALLINT,
          p_status           SMALLINT,
          p_funcao           CHAR(15),
          p_houve_erro       SMALLINT, 
          p_comando          CHAR(80),
          p_caminho          CHAR(80),
          p_help             CHAR(80),
          p_cancel           INTEGER,
          p_nom_tela         CHAR(80),
          p_mensag           CHAR(200),
          w_i                SMALLINT,
          p_i                SMALLINT, 
          p_den_item         LIKE item.den_item,
          p_data_ent         DATE,
          p_cod_unid_med     LIKE item.cod_unid_med

   DEFINE t_ped_itens ARRAY[500] OF RECORD
      ies_cancel     CHAR(01),
      num_sequencia  LIKE ped_itens.num_sequencia,
      cod_item       LIKE ped_itens.cod_item,
      den_item_reduz LIKE item.den_item_reduz,        
      qtd_solic      LIKE ped_itens.qtd_pecas_solic,        
      qtd_atend      LIKE ped_itens.qtd_pecas_solic,       
      qtd_saldo      LIKE ped_itens.qtd_pecas_solic
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "POL0811-05.10.13" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0811_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0811_controle()
#--------------------------#

   INITIALIZE p_pedidos.*, 
              p_ped_itens.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0811") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0811 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_empresas_885.* TO NULL

    SELECT * 
      INTO p_empresas_885.*		
      FROM empresas_885 
     WHERE cod_emp_oficial = p_cod_empresa
    IF SQLCA.sqlcode <> 0 THEN  
       SELECT * 
         INTO p_empresas_885.*		
         FROM empresas_885 
        WHERE cod_emp_gerencial = p_cod_empresa
       IF SQLCA.sqlcode = 0 THEN  
          LET p_cod_emp_aux = p_empresas_885.cod_emp_oficial 
       END IF 
    ELSE
       LET p_cod_emp_aux = p_empresas_885.cod_emp_gerencial 
    END IF 
        
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Pedido"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0811","CO") THEN 
            LET p_ies_tem_it = 'N'
            CALL pol0811_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
            END IF
         END IF

      COMMAND "Total" "Cancela saldo de todos os itens do pedido"
         HELP 2011
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0811","MO") THEN 
            IF p_ies_tem_it = 'S' THEN 
               CALL pol0811_total()
               IF p_houve_erro THEN
                  ERROR "Cancelamento de pedido cancelado " 
                  NEXT OPTION "Consultar"
               ELSE
                  ERROR "Cancelamento efetuado com sucesso" 
                  NEXT OPTION "Consultar"
               END IF 
            ELSE
               ERROR "Pedido nao possui itens com saldo" 
               NEXT OPTION "Consultar"
            END IF    
         END IF

     COMMAND "Parcial" "Cancela saldo de itens do pedido informados"
        HELP 005
        MESSAGE ""
        IF log005_seguranca(p_user,"VDP","pol0811","MO") THEN
           IF p_ies_tem_it = 'S' THEN 
              CALL pol0811_parcial()
              IF p_houve_erro THEN
                  ERROR "Cancelamento de pedido cancelado " 
                  NEXT OPTION "Consultar"
              ELSE
                  ERROR "Cancelamento efetuado com sucesso" 
                  NEXT OPTION "Consultar"
              END IF 
           ELSE
               ERROR "Pedido nao possui itens com saldo" 
               NEXT OPTION "Consultar"
           END IF    
        END IF

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0811

END FUNCTION

#--------------------------#
 FUNCTION pol0811_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0811

   LET p_pedidos.num_pedido = NULL 
   IF pol0811_entrada_dados() THEN
      CALL pol0811_exibe_dados()
   END IF

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_pedidos.num_pedido = NULL 
      LET p_ies_cons = FALSE
      CLEAR FORM
      ERROR "Consulta Cancelada"
   END IF
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0811_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0811

   LET INT_FLAG = FALSE  
   INPUT   p_pedidos.num_pedido,
           p_mot_cancel.cod_motivo,
           p_ies_can_op
   WITHOUT DEFAULTS FROM
           num_pedido,
           cod_motivo,
           ies_can_op 

      AFTER FIELD num_pedido     
      IF p_pedidos.num_pedido IS NOT NULL THEN
         SELECT * INTO p_pedidos.*
         FROM pedidos                  
         WHERE cod_empresa = p_cod_empresa            
           AND num_pedido = p_pedidos.num_pedido
         IF SQLCA.SQLCODE <> 0 THEN
            SELECT * INTO p_pedidos.*
              FROM pedidos                  
             WHERE cod_empresa = p_cod_emp_aux 
               AND num_pedido = p_pedidos.num_pedido
            IF SQLCA.sqlcode <> 0 THEN 
               ERROR "Pedido nao cadastrada" 
               NEXT FIELD num_pedido       
            END IF    
         END IF
      ELSE 
         ERROR "O Campo Pedido nao pode ser Nulo"
         NEXT FIELD num_pedido       
      END IF

      AFTER FIELD cod_motivo     
      IF p_mot_cancel.cod_motivo IS NOT NULL THEN
         SELECT * INTO p_mot_cancel.*
         FROM mot_cancel                
         WHERE cod_motivo = p_mot_cancel.cod_motivo
         IF SQLCA.SQLCODE = 0 THEN
            DISPLAY BY NAME p_mot_cancel.den_motivo 
         ELSE
            ERROR 'Motivo de cancelamento nao cadastrado'
            NEXT FIELD cod_motivo   
         END IF
      ELSE 
         ERROR "O Campo Pedido nao pode ser Nulo"
         NEXT FIELD cod_motivo       
      END IF

     BEFORE FIELD ies_can_op
       LET p_ies_can_op = 'N'

     AFTER FIELD ies_can_op
     IF p_ies_can_op IS NULL THEN
        ERROR 'INFORME SE IRA ENCERRAR ORDEM DE PRODUCAO'
        NEXT FIELD ies_can_op
     ELSE
        IF p_ies_can_op <> 'S' AND 
           p_ies_can_op <> 'N' THEN
           ERROR 'INFORME (S) OU (N)'
           NEXT FIELD ies_can_op
        END IF 
     END IF    
      
   ON KEY (control-z)
        CALL pol0811_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0811
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0811_exibe_dados()
#------------------------------#
DEFINE l_count  INTEGER

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_pedidos.cod_cliente

   DISPLAY BY NAME p_pedidos.num_pedido
   DISPLAY BY NAME p_pedidos.cod_cliente 

   DISPLAY p_nom_cliente TO nom_cliente

   INITIALIZE t_ped_itens TO NULL

   LET l_count = 0 
   SELECT COUNT(*)
     INTO l_count
     FROM ped_itens_orig_885
    WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
      AND num_pedido = p_pedidos.num_pedido
   IF l_count > 0 THEN 
      DECLARE c_ped_itor CURSOR FOR
      SELECT *
        FROM ped_itens_orig_885
       WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
         AND num_pedido = p_pedidos.num_pedido
      
      LET p_i = 1
      FOREACH c_ped_itor INTO p_ped_itens_orig_885.*
         
         LET t_ped_itens[p_i].cod_item      = p_ped_itens_orig_885.cod_item
         LET t_ped_itens[p_i].num_sequencia = p_ped_itens_orig_885.num_sequencia
         LET t_ped_itens[p_i].qtd_solic     = p_ped_itens_orig_885.qtd_saldo
         
         SELECT (qtd_peca_solic-qtd_peca_atend-qtd_peca_cancel)
           INTO t_ped_itens[p_i].qtd_saldo
           FROM ped_itens_peso_885
          WHERE cod_empresa   = p_ped_itens_orig_885.cod_empresa
            AND num_pedido    = p_ped_itens_orig_885.num_pedido
            AND cod_item      = p_ped_itens_orig_885.cod_item
            AND num_sequencia = p_ped_itens_orig_885.num_sequencia
         IF SQLCA.sqlcode <> 0 THEN 
            LET t_ped_itens[p_i].qtd_saldo = (p_ped_itens_orig_885.qtd_peca_solic - p_ped_itens_orig_885.qtd_peca_atend - p_ped_itens_orig_885.qtd_peca_cancel)
         END IF    
         
         LET t_ped_itens[p_i].qtd_atend = t_ped_itens[p_i].qtd_solic - t_ped_itens[p_i].qtd_saldo
     
         IF t_ped_itens[p_i].qtd_saldo <= 0 THEN 
            CONTINUE FOREACH
         END IF 
      
         SELECT den_item_reduz
            INTO t_ped_itens[p_i].den_item_reduz   
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_ped_itens_orig_885.cod_item
      
         LET p_i = p_i + 1
         LET p_ies_tem_it = 'S'
      END FOREACH
   ELSE
      DECLARE c_ped_itens CURSOR FOR
      SELECT DISTINCT cod_item,num_sequencia,qtd_pecas_solic,qtd_pecas_atend,qtd_pecas_cancel
        FROM ped_itens 
       WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
         AND num_pedido = p_pedidos.num_pedido
      
      LET p_i = 1
      FOREACH c_ped_itens INTO p_ped_itens.cod_item,p_ped_itens.num_sequencia,p_ped_itens.qtd_pecas_solic,
                               p_ped_itens.qtd_pecas_atend,p_ped_itens.qtd_pecas_cancel
            
         LET t_ped_itens[p_i].cod_item      = p_ped_itens.cod_item
         LET t_ped_itens[p_i].num_sequencia = p_ped_itens.num_sequencia
         LET t_ped_itens[p_i].qtd_solic     = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_cancel
         LET t_ped_itens[p_i].qtd_atend     = p_ped_itens.qtd_pecas_atend
         LET t_ped_itens[p_i].qtd_saldo     = p_ped_itens.qtd_pecas_solic - p_ped_itens.qtd_pecas_atend - p_ped_itens.qtd_pecas_cancel
         
         IF t_ped_itens[p_i].qtd_saldo <= 0 THEN
            CONTINUE FOREACH
         END IF    
      
         SELECT den_item_reduz
            INTO t_ped_itens[p_i].den_item_reduz   
         FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item = p_ped_itens.cod_item
      
         LET p_i = p_i + 1
         LET p_ies_tem_it = 'S'
      END FOREACH
   END IF 

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_ped_itens TO s_ped_itens.*
   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0811_total()
#-----------------------#
DEFINE l_qtd_saldo   LIKE ped_itens.qtd_pecas_solic,
       l_total       CHAR(01),
       l_tem_itens   CHAR(01),
       l_count       INTEGER  

   MESSAGE "Aguarde Processando Cancelamento...!!!"
      ATTRIBUTE (REVERSE) 

   LET l_count = 0
   
   SELECT COUNT(*) 
     INTO l_count 
     FROM ped_itens 
    WHERE num_pedido =  p_pedidos.num_pedido
      AND cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
      AND qtd_pecas_atend > 0

   IF l_count > 0 THEN
      LET l_total = 'N'   
   ELSE
      LET l_total = 'S'
   END IF 
   
   LET l_tem_itens = 'N'
   
   LET p_houve_erro = FALSE
   #BEGIN WORK
   CALL log085_transacao("BEGIN")

   FOR w_i = 1 TO 500  
     
     IF t_ped_itens[w_i].cod_item IS NULL THEN
        EXIT FOR
     END IF 
     
     LET l_tem_itens = 'S'
     
     LET l_qtd_saldo = 0
     SELECT (qtd_pecas_solic-qtd_pecas_cancel-qtd_pecas_atend)
       INTO l_qtd_saldo
       FROM ped_itens 
      WHERE cod_empresa   = p_cod_empresa
        AND num_pedido    = p_pedidos.num_pedido
        AND cod_item      = t_ped_itens[w_i].cod_item
        AND num_sequencia = t_ped_itens[w_i].num_sequencia
     IF l_qtd_saldo > 0 THEN 
        UPDATE ped_itens SET qtd_pecas_cancel = qtd_pecas_cancel + l_qtd_saldo
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("ATUALIZACAO 1","PED_ITENS")
        END IF 
           
        LET p_audit_vdp.cod_empresa = p_cod_empresa
        LET p_audit_vdp.num_pedido = p_pedidos.num_pedido
        LET p_audit_vdp.tipo_informacao = 'M'
        LET p_audit_vdp.tipo_movto = 'A'
        LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',t_ped_itens[w_i].cod_item,' SEQ. ',t_ped_itens[w_i].num_sequencia,' QTDE ',l_qtd_saldo
        LET p_audit_vdp.num_programa = 'POL0811'
        LET p_audit_vdp.data = TODAY
        LET p_audit_vdp.hora = TIME
        LET p_audit_vdp.usuario = p_user
        INSERT INTO audit_vdp
              (cod_empresa, 
               num_pedido, 
               tipo_informacao, 
               tipo_movto, 
               texto, 
               num_programa,  
               data, 
               hora, 
               usuario) 
        VALUES 
              (p_audit_vdp.cod_empresa, 
               p_audit_vdp.num_pedido, 
               p_audit_vdp.tipo_informacao, 
               p_audit_vdp.tipo_movto, 
               p_audit_vdp.texto, 
               p_audit_vdp.num_programa,  
               p_audit_vdp.data, 
               p_audit_vdp.hora, 
               p_audit_vdp.usuario) 
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO 1","AUDIT_VDP")
        END IF 

        LET p_ped_itens_cancel.cod_empresa    = p_cod_empresa
        LET p_ped_itens_cancel.num_pedido     = p_pedidos.num_pedido
        LET p_ped_itens_cancel.num_sequencia  = t_ped_itens[w_i].num_sequencia
        LET p_ped_itens_cancel.cod_item       = t_ped_itens[w_i].cod_item
        LET p_ped_itens_cancel.dat_cancel     = TODAY
        LET p_ped_itens_cancel.cod_motivo_can = p_mot_cancel.cod_motivo
        LET p_ped_itens_cancel.qtd_pecas_cancel = l_qtd_saldo
        
        INSERT INTO ped_itens_cancel
              (cod_empresa, 
               num_pedido, 
               num_sequencia, 
               cod_item, 
               dat_cancel, 
               cod_motivo_can,  
               qtd_pecas_cancel) 
        VALUES 
              (p_ped_itens_cancel.cod_empresa, 
               p_ped_itens_cancel.num_pedido, 
               p_ped_itens_cancel.num_sequencia, 
               p_ped_itens_cancel.cod_item, 
               p_ped_itens_cancel.dat_cancel, 
               p_ped_itens_cancel.cod_motivo_can, 
               p_ped_itens_cancel.qtd_pecas_cancel)
                
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO 1","PED_ITENS_CANCEL")
        END IF    
           
     END IF 
     
     LET l_qtd_saldo = 0
     SELECT (qtd_pecas_solic-qtd_pecas_cancel-qtd_pecas_atend)
       INTO l_qtd_saldo
       FROM ped_itens 
      WHERE cod_empresa   = p_cod_emp_aux
        AND num_pedido    = p_pedidos.num_pedido
        AND cod_item      = t_ped_itens[w_i].cod_item
        AND num_sequencia = t_ped_itens[w_i].num_sequencia
     IF l_qtd_saldo > 0 THEN 
        UPDATE ped_itens SET qtd_pecas_cancel = qtd_pecas_cancel + l_qtd_saldo
         WHERE cod_empresa   = p_cod_emp_aux
           AND num_pedido    = p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("ATUALIZACAO 2","PED_ITENS")
        END IF    
        
        LET p_audit_vdp.cod_empresa = p_cod_emp_aux
        LET p_audit_vdp.num_pedido = p_pedidos.num_pedido
        LET p_audit_vdp.tipo_informacao = 'M'
        LET p_audit_vdp.tipo_movto = 'A'
        LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',t_ped_itens[w_i].cod_item,' SEQ. ',t_ped_itens[w_i].num_sequencia,' QTDE ',l_qtd_saldo
        LET p_audit_vdp.num_programa = 'POL0811'
        LET p_audit_vdp.data = TODAY
        LET p_audit_vdp.hora = TIME
        LET p_audit_vdp.usuario = p_user
        
        INSERT INTO audit_vdp 
              (cod_empresa, 
               num_pedido, 
               tipo_informacao, 
               tipo_movto, 
               texto, 
               num_programa,  
               data, 
               hora, 
               usuario) 
        VALUES 
              (p_audit_vdp.cod_empresa, 
               p_audit_vdp.num_pedido, 
               p_audit_vdp.tipo_informacao, 
               p_audit_vdp.tipo_movto, 
               p_audit_vdp.texto, 
               p_audit_vdp.num_programa,  
               p_audit_vdp.data, 
               p_audit_vdp.hora, 
               p_audit_vdp.usuario) 
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO 2","AUDIT_VDP")
        END IF   

        LET p_ped_itens_cancel.cod_empresa    = p_cod_emp_aux
        LET p_ped_itens_cancel.num_pedido     = p_pedidos.num_pedido
        LET p_ped_itens_cancel.num_sequencia  = t_ped_itens[w_i].num_sequencia
        LET p_ped_itens_cancel.cod_item       = t_ped_itens[w_i].cod_item
        LET p_ped_itens_cancel.dat_cancel     = TODAY
        LET p_ped_itens_cancel.cod_motivo_can = p_mot_cancel.cod_motivo
        LET p_ped_itens_cancel.qtd_pecas_cancel = l_qtd_saldo

        INSERT INTO ped_itens_cancel
              (cod_empresa, 
               num_pedido, 
               num_sequencia, 
               cod_item, 
               dat_cancel, 
               cod_motivo_can,  
               qtd_pecas_cancel) 
        VALUES 
              (p_ped_itens_cancel.cod_empresa, 
               p_ped_itens_cancel.num_pedido, 
               p_ped_itens_cancel.num_sequencia, 
               p_ped_itens_cancel.cod_item, 
               p_ped_itens_cancel.dat_cancel, 
               p_ped_itens_cancel.cod_motivo_can, 
               p_ped_itens_cancel.qtd_pecas_cancel)
                
        IF SQLCA.sqlcode <> 0 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("INCLUSAO 2","PED_ITENS_CANCEL")
        END IF    
       
     END IF 

     DELETE FROM ped_itens_peso_885
      WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
        AND num_pedido  =  p_pedidos.num_pedido
        AND cod_item    = t_ped_itens[w_i].cod_item
        AND num_sequencia = t_ped_itens[w_i].num_sequencia
        IF SQLCA.sqlcode <> 0 AND 
           SQLCA.sqlcode <> 100 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("DELECAO","PED_ITENS_PESO_885")
        END IF    

     LET p_num_ped_ch  = p_pedidos.num_pedido
     LET p_num_seq_ch  = t_ped_itens[w_i].num_sequencia
     LET p_num_docum   = p_num_ped_ch CLIPPED,'/',p_num_seq_ch

 ##    INSERT INTO ped_at_885 VALUES (p_cod_empresa,p_pedidos.num_pedido,3,'N')  

 ##    IF SQLCA.sqlcode <> 0 AND 
 ##       SQLCA.sqlcode <> 100 THEN 
 ##       LET p_houve_erro = TRUE
 ##       CALL log003_err_sql("INSERT","PED_AT_885")
 ##    END IF    
     
     IF p_ies_can_op = 'S' THEN 
        IF pol0811_encerra_ordens() THEN 
        ELSE
           LET p_houve_erro = TRUE
        END IF
     END IF    

   END FOR 

   IF l_total = 'S' AND 
      l_tem_itens = 'S' THEN 
      UPDATE pedidos SET ies_sit_pedido = '9',
                         dat_cancel=TODAY 
       WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
         AND num_pedido  =  p_pedidos.num_pedido
        IF SQLCA.sqlcode <> 0 AND 
           SQLCA.sqlcode <> 100 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("UPDATE","PEDIDOS")
        END IF    
   END IF

   IF l_tem_itens = 'S' THEN 
      DELETE FROM ped_itens_orig_885 
       WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
         AND num_pedido  =  p_pedidos.num_pedido
        IF SQLCA.sqlcode <> 0 AND 
           SQLCA.sqlcode <> 100 THEN 
           LET p_houve_erro = TRUE
           CALL log003_err_sql("DELECAO","PED_ITENS_ORIG_885")
        END IF    
   END IF 

   IF p_houve_erro = FALSE THEN
      #COMMIT WORK 
      CALL log085_transacao("COMMIT")
   ELSE
      #ROLLBACK WORK  
      CALL log085_transacao("ROLLBACK")
      MESSAGE "Problemas Durante o Processamento"
         ATTRIBUTE (REVERSE)
   END IF
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION    

#-------------------------#
 FUNCTION pol0811_parcial()
#-------------------------#
DEFINE l_qtd_saldo   LIKE ped_itens.qtd_pecas_solic

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0811

   LET INT_FLAG = FALSE
   INPUT ARRAY t_ped_itens WITHOUT DEFAULTS FROM s_ped_itens.*

      BEFORE FIELD ies_cancel    
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD ies_cancel
      IF t_ped_itens[pa_curr].ies_cancel IS NULL THEN
         LET t_ped_itens[pa_curr].ies_cancel = 'N'
         DISPLAY t_ped_itens[pa_curr].ies_cancel TO s_ped_itens[sc_curr].ies_cancel
      END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_ped_itens[pa_curr+1].cod_item IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD ies_cancel
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      CLEAR FORM
      ERROR "Funcao Cancelada"
      RETURN 
   END IF

   MESSAGE "Aguarde Processando Cancelamento Parcial...!!!"
      ATTRIBUTE (REVERSE) 

   LET p_houve_erro = FALSE
   #BEGIN WORK
   CALL log085_transacao("BEGIN")
   FOR w_i = 1 TO 500  

     IF t_ped_itens[w_i].cod_item IS NULL THEN
        EXIT FOR
     END IF 
     IF t_ped_itens[w_i].ies_cancel = 'S' THEN 
        LET l_qtd_saldo = 0
        SELECT (qtd_pecas_solic-qtd_pecas_cancel-qtd_pecas_atend)
          INTO l_qtd_saldo
          FROM ped_itens 
         WHERE cod_empresa   = p_cod_empresa
           AND num_pedido    = p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia
        IF l_qtd_saldo > 0 THEN 
           UPDATE ped_itens SET qtd_pecas_cancel = qtd_pecas_cancel + l_qtd_saldo
            WHERE cod_empresa   = p_cod_empresa
              AND num_pedido    = p_pedidos.num_pedido
              AND cod_item      = t_ped_itens[w_i].cod_item
              AND num_sequencia = t_ped_itens[w_i].num_sequencia
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("ATUALIZACAO 1","PED_ITENS")
           END IF 
           LET p_audit_vdp.cod_empresa = p_cod_empresa
           LET p_audit_vdp.num_pedido = p_pedidos.num_pedido
           LET p_audit_vdp.tipo_informacao = 'M'
           LET p_audit_vdp.tipo_movto = 'A'
           LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',t_ped_itens[w_i].cod_item,' SEQ. ',t_ped_itens[w_i].num_sequencia,' QTDE ',l_qtd_saldo
           LET p_audit_vdp.num_programa = 'POL0811'
           LET p_audit_vdp.data = TODAY
           LET p_audit_vdp.hora = TIME
           LET p_audit_vdp.usuario = p_user
           INSERT INTO audit_vdp
                 (cod_empresa, 
                  num_pedido, 
                  tipo_informacao, 
                  tipo_movto, 
                  texto, 
                  num_programa,  
                  data, 
                  hora, 
                  usuario) 
           VALUES 
                 (p_audit_vdp.cod_empresa, 
                  p_audit_vdp.num_pedido, 
                  p_audit_vdp.tipo_informacao, 
                  p_audit_vdp.tipo_movto, 
                  p_audit_vdp.texto, 
                  p_audit_vdp.num_programa,  
                  p_audit_vdp.data, 
                  p_audit_vdp.hora, 
                  p_audit_vdp.usuario) 
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO 1","AUDIT_VDP")
           END IF    

           LET p_ped_itens_cancel.cod_empresa    = p_cod_empresa
           LET p_ped_itens_cancel.num_pedido     = p_pedidos.num_pedido
           LET p_ped_itens_cancel.num_sequencia  = t_ped_itens[w_i].num_sequencia
           LET p_ped_itens_cancel.cod_item       = t_ped_itens[w_i].cod_item
           LET p_ped_itens_cancel.dat_cancel     = TODAY
           LET p_ped_itens_cancel.cod_motivo_can = p_mot_cancel.cod_motivo
           LET p_ped_itens_cancel.qtd_pecas_cancel = l_qtd_saldo
           
           INSERT INTO ped_itens_cancel
                 (cod_empresa, 
                  num_pedido, 
                  num_sequencia, 
                  cod_item, 
                  dat_cancel, 
                  cod_motivo_can,  
                  qtd_pecas_cancel) 
           VALUES 
                 (p_ped_itens_cancel.cod_empresa, 
                  p_ped_itens_cancel.num_pedido, 
                  p_ped_itens_cancel.num_sequencia, 
                  p_ped_itens_cancel.cod_item, 
                  p_ped_itens_cancel.dat_cancel, 
                  p_ped_itens_cancel.cod_motivo_can, 
                  p_ped_itens_cancel.qtd_pecas_cancel)
                   
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO 1","PED_ITENS_CANCEL")
           END IF    
        END IF 
        
        LET l_qtd_saldo = 0
        SELECT (qtd_pecas_solic-qtd_pecas_cancel-qtd_pecas_atend)
          INTO l_qtd_saldo
          FROM ped_itens 
         WHERE cod_empresa   = p_cod_emp_aux
           AND num_pedido    = p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia
        IF l_qtd_saldo > 0 THEN 
           UPDATE ped_itens SET qtd_pecas_cancel = qtd_pecas_cancel + l_qtd_saldo
            WHERE cod_empresa   = p_cod_emp_aux
              AND num_pedido    = p_pedidos.num_pedido
              AND cod_item      = t_ped_itens[w_i].cod_item
              AND num_sequencia = t_ped_itens[w_i].num_sequencia
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("ATUALIZACAO 2","PED_ITENS")
           END IF    

           LET p_audit_vdp.cod_empresa = p_cod_emp_aux
           LET p_audit_vdp.num_pedido = p_pedidos.num_pedido
           LET p_audit_vdp.tipo_informacao = 'M'
           LET p_audit_vdp.tipo_movto = 'A'
           LET p_audit_vdp.texto = 'CANCELAMENTO ITEM ',t_ped_itens[w_i].cod_item,' SEQ. ',t_ped_itens[w_i].num_sequencia,' QTDE ',l_qtd_saldo
           LET p_audit_vdp.num_programa = 'POL0811'
           LET p_audit_vdp.data = TODAY
           LET p_audit_vdp.hora = TIME
           LET p_audit_vdp.usuario = p_user
           
           INSERT INTO audit_vdp 
                 (cod_empresa, 
                  num_pedido, 
                  tipo_informacao, 
                  tipo_movto, 
                  texto, 
                  num_programa,  
                  data, 
                  hora, 
                  usuario) 
           VALUES 
                 (p_audit_vdp.cod_empresa, 
                  p_audit_vdp.num_pedido, 
                  p_audit_vdp.tipo_informacao, 
                  p_audit_vdp.tipo_movto, 
                  p_audit_vdp.texto, 
                  p_audit_vdp.num_programa,  
                  p_audit_vdp.data, 
                  p_audit_vdp.hora, 
                  p_audit_vdp.usuario) 
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO 2","AUDIT_VDP")
           END IF    

           LET p_ped_itens_cancel.cod_empresa    = p_cod_emp_aux
           LET p_ped_itens_cancel.num_pedido     = p_pedidos.num_pedido
           LET p_ped_itens_cancel.num_sequencia  = t_ped_itens[w_i].num_sequencia
           LET p_ped_itens_cancel.cod_item       = t_ped_itens[w_i].cod_item
           LET p_ped_itens_cancel.dat_cancel     = TODAY
           LET p_ped_itens_cancel.cod_motivo_can = p_mot_cancel.cod_motivo
           LET p_ped_itens_cancel.qtd_pecas_cancel = l_qtd_saldo
           
           INSERT INTO ped_itens_cancel
                 (cod_empresa, 
                  num_pedido, 
                  num_sequencia, 
                  cod_item, 
                  dat_cancel, 
                  cod_motivo_can,  
                  qtd_pecas_cancel) 
           VALUES 
                 (p_ped_itens_cancel.cod_empresa, 
                  p_ped_itens_cancel.num_pedido, 
                  p_ped_itens_cancel.num_sequencia, 
                  p_ped_itens_cancel.cod_item, 
                  p_ped_itens_cancel.dat_cancel, 
                  p_ped_itens_cancel.cod_motivo_can, 
                  p_ped_itens_cancel.qtd_pecas_cancel)
                   
           IF SQLCA.sqlcode <> 0 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("INCLUSAO 2","PED_ITENS_CANCEL")
           END IF    
        END IF 

##        INSERT INTO ped_at_885 VALUES (p_cod_empresa,p_pedidos.num_pedido,3,'N')  
        
##        IF SQLCA.sqlcode <> 0 AND 
##           SQLCA.sqlcode <> 100 THEN 
##           LET p_houve_erro = TRUE
##           CALL log003_err_sql("INSERT","PED_AT_885")
##        END IF    
        
        DELETE FROM ped_itens_peso_885
         WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
           AND num_pedido  =  p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia
           IF SQLCA.sqlcode <> 0 AND 
              SQLCA.sqlcode <> 100 THEN 
              LET p_houve_erro = TRUE
              CALL log003_err_sql("DELECAO","PED_ITENS_PESO_885")
           END IF 

        UPDATE ped_itens_orig_885 SET qtd_peca_cancel = qtd_peca_cancel + l_qtd_saldo
         WHERE cod_empresa   IN (p_cod_empresa, p_cod_emp_aux)
           AND num_pedido    = p_pedidos.num_pedido
           AND cod_item      = t_ped_itens[w_i].cod_item
           AND num_sequencia = t_ped_itens[w_i].num_sequencia

        LET p_num_ped_ch  = p_pedidos.num_pedido
        LET p_num_seq_ch  = t_ped_itens[w_i].num_sequencia
        LET p_num_docum   = p_num_ped_ch CLIPPED,'/',p_num_seq_ch
 
        IF p_ies_can_op = 'S' THEN 
           IF pol0811_encerra_ordens() THEN 
           ELSE
              LET p_houve_erro = TRUE
           END IF
        END IF    
        
     END IF      
   END FOR 

   IF p_houve_erro = FALSE THEN
      COMMIT WORK 
   ELSE
      #ROLLBACK WORK  
      CALL log085_transacao("ROLLBACK")
      MESSAGE "Problemas Durante o Processamento"
         ATTRIBUTE (REVERSE)
   END IF
   LET p_ies_cons = FALSE
   MESSAGE ""
   
END FUNCTION

#-----------------------#
 FUNCTION pol0811_popup()
#-----------------------#
  DEFINE p_cod_motivo      LIKE mot_cancel.cod_motivo
  
  CASE
    WHEN infield(cod_motivo)
         CALL log009_popup(6,25,"MOT. CANCELAMANTO","mot_cancel",
                          "cod_motivo","den_motivo",
                          "vdp0050","N","") RETURNING p_cod_motivo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0811 
         IF   p_cod_motivo IS NOT NULL OR
              p_cod_motivo <> " " THEN 
              LET p_mot_cancel.cod_motivo  = p_cod_motivo
              DISPLAY BY NAME p_mot_cancel.cod_motivo
         END IF
  END CASE
END FUNCTION

#---------------------------------#
 FUNCTION pol0811_encerra_ordens()
#---------------------------------#
 
   UPDATE ordens SET ies_situa = 5
    WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
      AND num_docum  = p_num_docum
   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("ATUALIZACAO","ORDENS")
      RETURN FALSE
   END IF   
      
   UPDATE necessidades SET ies_situa = 5
    WHERE cod_empresa IN (p_cod_empresa, p_cod_emp_aux)
      AND num_docum  = p_num_docum
   IF SQLCA.sqlcode <> 0 THEN 
      CALL log003_err_sql("ATUALIZACAO","NECESSIDADES")
      RETURN FALSE
   END IF   
  
   LET p_audit_vdp.cod_empresa = p_cod_emp_aux
   LET p_audit_vdp.num_pedido  = p_pedidos.num_pedido
   LET p_audit_vdp.tipo_informacao = 'M'
   LET p_audit_vdp.tipo_movto  = 'A'
   LET p_audit_vdp.texto = 'ORDEM  ',p_num_docum,' ENCERRADA NO CANCELAMENTO DO PEDIDO '
   LET p_audit_vdp.num_programa = 'POL0811'
   LET p_audit_vdp.data = TODAY
   LET p_audit_vdp.hora = TIME
   LET p_audit_vdp.usuario = p_user
   
   INSERT INTO audit_vdp 
         (cod_empresa, 
          num_pedido, 
          tipo_informacao, 
          tipo_movto, 
          texto, 
          num_programa,  
          data, 
          hora, 
          usuario) 
   VALUES 
         (p_audit_vdp.cod_empresa, 
          p_audit_vdp.num_pedido, 
          p_audit_vdp.tipo_informacao, 
          p_audit_vdp.tipo_movto, 
          p_audit_vdp.texto, 
          p_audit_vdp.num_programa,  
          p_audit_vdp.data, 
          p_audit_vdp.hora, 
          p_audit_vdp.usuario) 
   IF SQLCA.sqlcode <> 0 THEN 
      LET p_houve_erro = TRUE
      CALL log003_err_sql("INCLUSAO ","AUDIT_VDP ORD")
   END IF    

  RETURN TRUE 
     
END FUNCTION                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            