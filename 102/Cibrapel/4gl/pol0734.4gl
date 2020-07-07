#-------------------------------------------------------------------#
# OBJETIVO: CÓPIA DE PEDIOS                                         #
# CONVERSÃO 10.02: 29/12/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_mensagem           CHAR(60),
          p_num_seq            INTEGER,
          p_num_reg            CHAR(6),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_comando            CHAR(200),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_arq_origem         CHAR(100),
          p_arq_destino        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_cpf                CHAR(14),
          p_ies_tip_controle   CHAR(01)

   DEFINE p_pct_desc_valor     LIKE desc_nat_oper_885.pct_desc_valor,
          p_pct_desc_qtd       LIKE desc_nat_oper_885.pct_desc_qtd,
          p_pct_desc_oper      LIKE desc_nat_oper_885.pct_desc_oper
         
   DEFINE p_tela               RECORD
          num_pedido           INTEGER
   END RECORD

   DEFINE p_pedidos         RECORD LIKE pedidos.*,
          p_ped_itens       RECORD LIKE ped_itens.*,
          p_ped_end_ent     RECORD LIKE ped_end_ent.*,
          p_ped_info_compl  RECORD LIKE ped_info_compl.*,
          p_ped_itens_texto RECORD LIKE ped_itens_texto.*,
          p_ped_item_nat    RECORD LIKE ped_item_nat.*

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "pol0734-10.02.01  "
   CALL func002_versao_prg(p_versao)
   
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol0734_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol0734_menu()
#----------------------#
          
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0734") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0734 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0734_le_parametros() THEN
      RETURN
   END IF
    
   DISPLAY p_cod_emp_ofic TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol0734_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso !'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Processar'
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_cons = FALSE
         END IF 
      COMMAND "Processar" "Processa a cópia do pedido"
         IF p_ies_cons THEN
            CALL log085_transacao("BEGIN")
            CALL pol0734_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso!'
               LET p_ies_cons = FALSE
               CALL log085_transacao("COMMIT")
            ELSE
               ERROR 'Operação cancelada !!!'
               CALL log085_transacao("ROLLBACK")
               NEXT OPTION 'Informar'
            END IF 
         ELSE
            ERROR 'Informe os parâmentors previamente!'
            NEXT OPTION 'Informar'
         END IF
         MESSAGE ''
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0734

END FUNCTION

#-------------------------------#
FUNCTION pol0734_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0734_informar()
#--------------------------#
   
   LET INT_FLAG = FALSE
   INITIALIZE p_tela TO NULL
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

   AFTER INPUT 
      
      IF NOT INT_FLAG THEN
         IF p_tela.num_pedido IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD num_pedido
         END IF
      
         SELECT * 
           INTO p_pedidos.*
           FROM pedidos 
          WHERE cod_empresa =  p_cod_empresa
            AND num_pedido  =  p_tela.num_pedido

         IF STATUS <> 0 THEN
            ERROR 'Pedido não localizado!'
            NEXT FIELD num_pedido
         END IF 
                          
         {SELECT ies_tip_controle
           INTO p_ies_tip_controle
           FROM nat_operacao 
          WHERE cod_nat_oper = p_pedidos.cod_nat_oper
              
         IF p_ies_tip_controle <> '8' THEN
            ERROR "Pedido nao e de faturamento antecipado" 
            NEXT FIELD num_pedido
         END IF }

         SELECT num_pedido
           FROM pedidos 
          WHERE cod_empresa =  p_cod_emp_ofic
            AND num_pedido  =  p_tela.num_pedido

         IF STATUS = 0 THEN
            ERROR 'Pedido já copiado!'
            NEXT FIELD num_pedido
         END IF 
      
      END IF
   
   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_emp_ofic TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0734_processar()
#---------------------------#

   DEFINE p_pre_unit              LIKE ped_itens.pre_unit,
          p_qtd_pecas_solic       INTEGER,
          p_num_pedido            INTEGER
   
   LET p_num_pedido = p_tela.num_pedido

   SELECT pct_desc_valor,             
          pct_desc_qtd,                  
          pct_desc_oper                  
     INTO p_pct_desc_valor,              
          p_pct_desc_qtd,                
          p_pct_desc_oper                
     FROM desc_nat_oper_885              
    WHERE cod_empresa = p_cod_empresa    
      AND num_pedido  = p_num_pedido     

   LET p_pedidos.cod_empresa = p_cod_emp_ofic      
   
   INSERT INTO pedidos
    VALUES(p_pedidos.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','pedido')
      RETURN FALSE
   END IF    
   
   DECLARE cq_pi CURSOR FOR 
    SELECT *
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens')
      RETURN FALSE
   END IF

   FOREACH cq_pi INTO p_ped_itens.*
      
      IF p_pct_desc_qtd > 0 THEN
         LET p_qtd_pecas_solic = 
                p_ped_itens.qtd_pecas_solic * ((100 - p_pct_desc_qtd)/100)
         LET p_pre_unit = p_ped_itens.pre_unit
         LET p_ped_itens.pre_unit = 
                p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_pct_desc_oper/100)
      ELSE
         LET p_qtd_pecas_solic = p_ped_itens.qtd_pecas_solic
         LET p_pre_unit = p_ped_itens.pre_unit * ((100 - p_pct_desc_valor)/100)
         LET p_ped_itens.pre_unit = p_ped_itens.pre_unit - p_pre_unit
         LET p_ped_itens.pre_unit = 
                p_ped_itens.pre_unit - (p_ped_itens.pre_unit * p_pct_desc_oper/100)
      END IF
      
      UPDATE ped_itens
         SET pre_unit = p_ped_itens.pre_unit
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_ped_itens.num_sequencia

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Atualizando','ped_itens')
         RETURN FALSE
      END IF    
    
      LET p_ped_itens.qtd_pecas_solic = p_qtd_pecas_solic
      LET p_ped_itens.pre_unit = p_pre_unit
      LET p_ped_itens.cod_empresa = p_cod_emp_ofic
      
      INSERT INTO ped_itens
       VALUES(p_ped_itens.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_itens')
         RETURN FALSE
      END IF    
      
   END FOREACH

   DECLARE cq_ped_nat CURSOR FOR                                   
    SELECT *                                                          
      FROM ped_item_nat                                               
     WHERE cod_empresa   = p_cod_empresa                              
       AND num_pedido    = p_num_pedido                     
                                                                   
   FOREACH cq_ped_nat INTO p_ped_item_nat.*                           
                                                                   
      IF STATUS <> 0 THEN                                             
         CALL log003_err_sql('Lendo','ped_item_nat')                  
         RETURN FALSE                                                 
      END IF                                                          
                                                                      
      LET p_ped_item_nat.cod_empresa = p_cod_emp_ofic                 
                                                                      
      INSERT INTO ped_item_nat                                        
       VALUES(p_ped_item_nat.*)                                       
                                                                   
      IF sqlca.sqlcode <> 0 THEN                                      
         CALL log003_err_sql('Inserindo','ped_item_nat')              
         RETURN FALSE                                                 
      END IF                                                          
                                                                      
   END FOREACH                                                        
   
   DECLARE cq_pe CURSOR FOR 
    SELECT *
      FROM ped_end_ent
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_end_ent')
      RETURN FALSE
   END IF

   FOREACH cq_pe INTO p_ped_end_ent.*
      
      LET p_ped_end_ent.cod_empresa = p_cod_emp_ofic
      
      INSERT INTO ped_end_ent
       VALUES(p_ped_end_ent.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_end_ent')
         RETURN FALSE
      END IF    

   END FOREACH

   DECLARE cq_pic CURSOR FOR 
    SELECT *
      FROM ped_info_compl
     WHERE empresa = p_cod_empresa
       AND pedido  = p_num_pedido

   FOREACH cq_pic INTO p_ped_info_compl.*

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','ped_info_compl')
         RETURN FALSE
      END IF
      
      DELETE FROM ped_info_compl
       WHERE empresa = p_cod_emp_ofic
         AND pedido  = p_num_pedido

      LET p_ped_info_compl.empresa = p_cod_emp_ofic
         
      INSERT INTO ped_info_compl
       VALUES(p_ped_info_compl.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','ped_info_compl')
         RETURN FALSE
      END IF    

   END FOREACH

   DECLARE cq_pit CURSOR FOR 
    SELECT *
      FROM ped_itens_texto
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_num_pedido

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','ped_itens_texto')
      RETURN FALSE
   END IF

   FOREACH cq_pit INTO p_ped_itens_texto.*
      
      LET p_ped_itens_texto.cod_empresa = p_cod_emp_ofic

      SELECT cod_empresa
        FROM ped_itens_texto
       WHERE cod_empresa   = p_cod_emp_ofic
         AND num_pedido    = p_num_pedido
         AND num_sequencia = p_ped_itens_texto.num_sequencia
 
      IF STATUS = 100 THEN
         INSERT INTO ped_itens_texto
          VALUES(p_ped_itens_texto.*)
      
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Inserindo','ped_itens_texto')
            RETURN FALSE
         END IF    
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ped_itens_texto')
            RETURN FALSE
         END IF         
      END IF
      

   END FOREACH

   RETURN TRUE
   
END FUNCTION
