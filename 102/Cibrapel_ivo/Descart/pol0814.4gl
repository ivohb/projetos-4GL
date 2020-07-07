#-----------------------------------------#
# PROGRAMA: pol0814                       #
# OBJETIVO: CANCELAMENTO DE PEDIDO        #
#-----------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_pedidos          RECORD LIKE pedidos.*,
          p_pedidose         RECORD LIKE pedidos.*,
          p_ped_itens        RECORD LIKE ped_itens.*,
          p_empresas_885     RECORD LIKE empresas_885.*,
          p_ped_itens_orig_885 RECORD LIKE ped_itens_orig_885.*,
          p_ped_itens_peso_885 RECORD LIKE ped_itens_peso_885.*,
          p_cod_empresa      LIKE empresa.cod_empresa,
          p_cod_emp_aux      LIKE empresa.cod_empresa,
          p_den_empresa      LIKE empresa.den_empresa,
          p_user             LIKE usuario.nom_usuario,
          p_nom_cliente      LIKE clientes.nom_cliente,
          p_den_nat_oper     LIKE nat_operacao.den_nat_oper,
          p_den_cnd_pgto     LIKE cond_pgto.den_cnd_pgto,
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
      cod_item       LIKE ped_itens.cod_item,
      den_item_reduz LIKE item.den_item_reduz,        
      qtd_saldo      LIKE ped_itens.qtd_pecas_solic,        
      qtd_kg         DECIMAL(15,6),
      pre_unit       LIKE ped_itens.pre_unit,       
      pre_total      DECIMAL(15,2)
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "POL0814-05.10.01" #Favor nao alterar esta linha (SUPORTE)
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
      CALL pol0814_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0814_controle()
#--------------------------#

   INITIALIZE p_pedidos.*, 
              p_ped_itens.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0814") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0814 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_empresas_885.* TO NULL
       
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Pedido"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0814","CO") THEN 
            CALL pol0814_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
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
   CLOSE WINDOW w_pol0814

END FUNCTION

#--------------------------#
 FUNCTION pol0814_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0814

   LET p_pedidos.num_pedido = NULL 
   
   IF pol0814_entrada_dados() THEN
      CALL pol0814_exibe_dados()
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
 FUNCTION pol0814_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0814

   LET INT_FLAG = FALSE  
   INPUT BY NAME p_pedidos.num_pedido
      WITHOUT DEFAULTS  

      AFTER FIELD num_pedido     
      IF p_pedidos.num_pedido IS NOT NULL THEN
         SELECT * 
           INTO p_empresas_885.*		
           FROM empresas_885 
          WHERE cod_emp_gerencial = p_cod_empresa
         IF SQLCA.sqlcode <> 0 THEN  
            ERROR 'Empresa nao parametrizada para consulta'
            NEXT FIELD num_pedido
         END IF 
         
         SELECT * INTO p_pedidos.*
         FROM pedidos                  
         WHERE cod_empresa = p_cod_empresa            
           AND num_pedido = p_pedidos.num_pedido
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Pedido nao cadastrada" 
            NEXT FIELD num_pedido       
         END IF
      ELSE 
         ERROR "O Campo Pedido nao pode ser Nulo"
         NEXT FIELD num_pedido       
      END IF

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0814
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0814_exibe_dados()
#------------------------------#

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_pedidos.cod_cliente

   DISPLAY BY NAME p_pedidos.num_pedido
   DISPLAY BY NAME p_pedidos.cod_cliente 
   DISPLAY BY NAME p_pedidos.cod_nat_oper
   DISPLAY BY NAME p_pedidos.cod_cnd_pgto

   DISPLAY p_nom_cliente TO nom_cliente

   SELECT den_nat_oper
     INTO p_den_nat_oper
     FROM nat_operacao
    WHERE cod_nat_oper = p_pedidos.cod_nat_oper

   SELECT den_cnd_pgto
     INTO p_den_cnd_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_pedidos.cod_cnd_pgto
 
   DISPLAY p_den_cnd_pgto TO den_cnd_pgto
   
   DISPLAY p_den_nat_oper TO den_nat_oper  

   INITIALIZE t_ped_itens TO NULL
   
   DECLARE c_ped_itens CURSOR FOR
   SELECT *
     FROM ped_itens_orig_885
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial
      AND num_pedido = p_pedidos.num_pedido

   LET p_i = 1
   FOREACH c_ped_itens INTO p_ped_itens_orig_885.*

      LET t_ped_itens[p_i].cod_item      = p_ped_itens_orig_885.cod_item
      LET t_ped_itens[p_i].pre_unit      = p_ped_itens_orig_885.pre_unit_qtd
      
      SELECT qtd_saldo,
             peso_item 
        INTO t_ped_itens[p_i].qtd_saldo,
             t_ped_itens[p_i].qtd_kg
        FROM ped_itens_peso_885
       WHERE cod_empresa   = p_ped_itens_orig_885.cod_empresa
         AND num_pedido    = p_ped_itens_orig_885.num_pedido
         AND cod_item      = p_ped_itens_orig_885.cod_item
         AND num_sequencia = p_ped_itens_orig_885.num_sequencia
      IF SQLCA.sqlcode <> 0 THEN 
         LET t_ped_itens[p_i].qtd_saldo = 0
         LET t_ped_itens[p_i].qtd_kg = 0
      END IF    
      
      LET t_ped_itens[p_i].pre_total = t_ped_itens[p_i].qtd_saldo * t_ped_itens[p_i].pre_unit

      SELECT den_item_reduz
         INTO t_ped_itens[p_i].den_item_reduz   
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_ped_itens_orig_885.cod_item

      LET p_i = p_i + 1

   END FOREACH

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