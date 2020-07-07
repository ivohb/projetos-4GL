#-----------------------------------------#
# PROGRAMA: pol0825                       #
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
          p_cod_unid_med     LIKE item.cod_unid_med,
          p_msg              CHAR(100)

   DEFINE t_item_chapa_885 ARRAY[500] OF RECORD
          cod_item        LIKE ped_itens.cod_item,
          den_item_reduz  LIKE item.den_item_reduz,        
          qtd_pecas_solic LIKE ped_itens.qtd_pecas_solic,
          pre_unit        DECIMAL(15,6),       
          largura         LIKE item_chapa_885.largura,        
          comprimento     LIKE item_chapa_885.comprimento,       
          pes_unit        LIKE ped_itens.qtd_pecas_atend
   END RECORD

   DEFINE p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

END GLOBALS

MAIN
   LET p_versao = "POL0825-10.02.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho 
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN 
      CALL pol0825_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0825_controle()
#--------------------------#

   INITIALIZE p_pedidos.*, 
              p_ped_itens.* TO NULL

   CALL log006_exibe_teclas("01",p_versao)
   CALL log130_procura_caminho("pol0825") RETURNING p_nom_tela 
   OPEN WINDOW w_pol0825 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   INITIALIZE p_empresas_885.* TO NULL
       
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta Pedido"
         HELP 2010
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0825","CO") THEN 
            CALL pol0825_consulta()                     
            IF p_ies_cons THEN 
               NEXT OPTION "Total"
            END IF
         END IF
       COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0825_sobre()
       COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix
 
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0825

END FUNCTION

#--------------------------#
 FUNCTION pol0825_consulta()
#--------------------------#
 
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0825

   LET p_pedidos.num_pedido = NULL 
   
   IF pol0825_entrada_dados() THEN
      CALL pol0825_exibe_dados()
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
 FUNCTION pol0825_entrada_dados()
#-------------------------------#
 
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0825

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
   CURRENT WINDOW IS w_pol0825
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE 
   END IF
 
END FUNCTION

#------------------------------#
 FUNCTION pol0825_exibe_dados()
#------------------------------#

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_pedidos.cod_cliente

   DISPLAY BY NAME p_pedidos.num_pedido
   DISPLAY BY NAME p_pedidos.cod_cliente 
   DISPLAY p_nom_cliente TO nom_cliente

   INITIALIZE t_item_chapa_885 TO NULL
   
   DECLARE c_ped_itens CURSOR FOR
   SELECT *
     FROM ped_itens_orig_885
    WHERE cod_empresa = p_empresas_885.cod_emp_oficial
      AND num_pedido = p_pedidos.num_pedido

   LET p_i = 1
   FOREACH c_ped_itens INTO p_ped_itens_orig_885.*

      LET t_item_chapa_885[p_i].cod_item        = p_ped_itens_orig_885.cod_item
      LET t_item_chapa_885[p_i].pre_unit        = p_ped_itens_orig_885.pre_unit_qtd
      LET t_item_chapa_885[p_i].qtd_pecas_solic = p_ped_itens_orig_885.qtd_saldo
      LET t_item_chapa_885[p_i].pes_unit        = p_ped_itens_orig_885.peso_item / t_item_chapa_885[p_i].qtd_pecas_solic
      
      SELECT den_item_reduz
         INTO t_item_chapa_885[p_i].den_item_reduz   
      FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item = p_ped_itens_orig_885.cod_item

      SELECT comprimento,
             largura
        INTO t_item_chapa_885[p_i].comprimento,
             t_item_chapa_885[p_i].largura
        FROM item_chapa_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_pedidos.num_pedido
         AND num_sequencia = p_ped_itens_orig_885.num_sequencia

      IF SQLCA.sqlcode <> 0 THEN 
         LET  t_item_chapa_885[p_i].comprimento = 0 
         LET  t_item_chapa_885[p_i].largura = 0
      END IF 
         
      LET p_i = p_i + 1

   END FOREACH

   LET p_i = p_i - 1

   CALL SET_COUNT(p_i)
   DISPLAY ARRAY t_item_chapa_885 TO s_item_chapa_885.*

   END DISPLAY

   IF INT_FLAG THEN 
      LET p_ies_cons = FALSE
   ELSE
      LET p_ies_cons = TRUE  
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0825_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION