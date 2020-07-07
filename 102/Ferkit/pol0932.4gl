#-------------------------------------------------------------------#
# SISTEMA.: VDP                                                     #
# PROGRAMA: pol0932                                                 #
# OBJETIVO: CANCELAMENTO DE PEDIDO DE VENDA                         #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 13/05/2009                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_fornecedor     CHAR(15),
          p_tip_baixa          CHAR(02),
          p_retorno            SMALLINT,
          p_msg                CHAR(80),
          p_ind                SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500),
          p_explodiu           CHAR(01),
          p_num_seq            SMALLINT,
          p_hoje               DATE 
          

   DEFINE p_num_oc          LIKE ordem_sup.num_oc,
          p_num_op          LIKE ordens.num_ordem,
          p_situa_op        LIKE ordens.ies_situa,
          p_cod_item        LIKE item.cod_item,
          p_num_ped_comp    LIKE pedido_sup.num_pedido,
          p_num_docum       LIKE ordens.num_docum,
          p_ies_situa       LIKE ordens.ies_situa,
          p_saldo           LIKE ordens.qtd_planej,
          p_cod_item_pai    LIKE item.cod_item,
          p_cod_item_compon LIKE item.cod_item,
          p_qtd_compon      LIKE estrutura.qtd_necessaria,
          p_qtd_neces       LIKE estrutura.qtd_necessaria,
          p_pct_refug       LIKE estrutura.pct_refug,
          p_ies_tip_item    LIKE item.ies_tip_item,
          p_den_item        LIKE item.den_item_reduz,
          p_qtd_cancel      LIKE ordens.qtd_planej,
          p_qtd_baixar      LIKE ordens.qtd_planej,
          p_qtd_ord         LIKE ordens.qtd_planej
          

   DEFINE p_tela           RECORD
          num_ped_vend     LIKE pedidos.num_pedido,
          situa_ped_vend   LIKE pedidos.ies_sit_pedido,
          cod_cliente      LIKE clientes.cod_cliente,
          nom_cliente      LIKE clientes.nom_cliente
   END RECORD

   
   DEFINE pr_itens         ARRAY[99] OF RECORD
          num_sequencia    LIKE ped_itens.num_sequencia,
          cod_item         LIKE ped_itens.cod_item,
          dat_entrega      LIKE ped_itens.prz_entrega,
          qtd_solic        LIKE ped_itens.qtd_pecas_solic,
          qtd_saldo        LIKE ped_itens.qtd_pecas_solic,
          qtd_cancelar     LIKE ped_itens.qtd_pecas_solic,
          ies_op           CHAR(01),
          ies_oc           CHAR(01)
   END RECORD
   
   DEFINE pr_ocs          ARRAY[99] OF RECORD
          cod_compon      LIKE item.cod_item,
          den_compon      LIKE item.den_item_reduz,
          qtd_neces       LIKE estrutura.qtd_necessaria,
          num_oc          LIKE ordem_sup.num_oc,
          qtd_saldo       LIKE ordem_sup.qtd_solic,
          ies_situa       LIKE ordem_sup.ies_situa_oc
   END RECORD

   DEFINE pr_ops          ARRAY[99] OF RECORD
          cod_compon      LIKE item.cod_item,
          den_compon      LIKE item.den_item_reduz,
          qtd_neces       LIKE estrutura.qtd_necessaria,
          num_op          LIKE ordens.num_ordem,
          qtd_saldo       LIKE ordens.qtd_planej,
          ies_situa       LIKE ordens.ies_situa
   END RECORD
          
   
   DEFINE p_ped_sup       RECORD LIKE pedido_sup.*
   
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10 
   DEFER INTERRUPT
   LET p_versao = "pol0932-10.02.00"
   OPTIONS
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0932_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0932_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0932") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0932 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol0932_cria_tab_temp() THEN
      RETURN FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar parâmetros para o processamento"
         CALL pol0932_informar() RETURNING p_status
         IF p_status THEN
            ERROR "Parâmetros informados c/ Sucesso !!!"
            LET p_ies_cons = TRUE   
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE   
         END IF      
      COMMAND "Cacelar" "Cancela itens do pedido"
         IF p_ies_cons THEN
            CALL pol0932_cancelar() RETURNING p_status
            IF p_status THEN
               ERROR "Cancelamento Efetuado c/ Sucesso !!!"
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF      
         ELSE
            ERROR "Infrome os parâmetros previamente!!!"
            NEXT OPTION "Informar"
         END IF
         LET p_ies_cons = FALSE
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0932_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0932

END FUNCTION

#-------------------------------#
FUNCTION pol0932_cria_tab_temp()
#-------------------------------#

   DROP TABLE ops_tmp_304;

   CREATE TABLE ops_tmp_304(
      num_pedido     INTEGER,
      num_sequencia  INTEGER,
      num_op         INTEGER,
      cod_compon     CHAR(15),
      qtd_neces      DECIMAL(14,7),     
      sdo_op         DECIMAL(10,3),
      ies_situa      CHAR(01)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','ops_tmp_304')
      RETURN FALSE
   END IF

   DROP TABLE ocs_tmp_304

   CREATE TABLE ocs_tmp_304(
      num_pedido     INTEGER,
      num_sequencia  INTEGER,
      cod_compon     CHAR(15),
      qtd_neces      DECIMAL(14,7),
      num_oc         INTEGER,
      sdo_oc         DECIMAL(10,3),
      ies_situa      CHAR(01)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','ocs_tmp_304')
      RETURN FALSE
   END IF

   DROP TABLE estr_tmp_304
   
   CREATE TABLE estr_tmp_304(
         num_seq       INTEGER,
         cod_item_pai  CHAR(15),
         cod_item      CHAR(15),
         tip_item      CHAR(01),
         qtd_neces     DECIMAL(14,7),
         explodiu      CHAR(01)
       );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','estr_tmp_304')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0932_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#----------------------------#
FUNCTION pol0932_informar()
#----------------------------#

   CALL pol0932_limpa_tela()
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS
        
      AFTER FIELD num_ped_vend

         IF p_tela.num_ped_vend IS NULL THEN
            ERROR "Campo com Preenchimento Obrigatório !!!"
            NEXT FIELD num_ped_vend
         END IF
         
         IF NOT pol0932_le_pedido() THEN
            NEXT FIELD num_ped_vend
         END IF
         
         DISPLAY BY NAME p_tela.*
            
   END INPUT

   IF INT_FLAG THEN
      CALL pol0932_limpa_tela()
      RETURN FALSE
   END IF

   IF NOT pol0932_carrega_itens() THEN
      RETURN FALSE
   END IF
   
   IF p_index > 11 THEN
      DISPLAY ARRAY pr_itens TO sr_itens.*       
   ELSE
      INPUT ARRAY pr_itens 
         WITHOUT DEFAULTS FROM sr_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0932_le_pedido()
#---------------------------#

   SELECT cod_cliente,
          ies_sit_pedido
     INTO p_tela.cod_cliente,
          p_tela.situa_ped_vend
     FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_tela.num_ped_vend
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','Pedido')
      RETURN FALSE
   END IF
       
   IF STATUS = 100 THEN
      ERROR 'Pedido inexistente!'
      RETURN FALSE
   ELSE   
      IF p_tela.situa_ped_vend = '9' THEN
         ERROR 'Pedido cancelado!'
         RETURN FALSE
      END IF
   END IF
   
   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Clientes')
      LET p_tela.nom_cliente = 'NOME DO CLIENTE NAO DISPONIVEL'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0932_carrega_itens()
#------------------------------#

   INITIALIZE pr_itens TO NULL
   
   IF NOT pol0932_del_ordens_tmp() THEN 
      RETURN FALSE
   END IF
   
   LET p_ind = 1
   
   DECLARE cq_it CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           prz_entrega,
           qtd_pecas_solic,
           (qtd_pecas_solic - 
            qtd_pecas_atend - 
            qtd_pecas_cancel -
            qtd_pecas_romaneio)
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_tela.num_ped_vend
   
   FOREACH cq_it INTO
           pr_itens[p_ind].num_sequencia,
           pr_itens[p_ind].cod_item,
           pr_itens[p_ind].dat_entrega,
           pr_itens[p_ind].qtd_solic,
           pr_itens[p_ind].qtd_saldo
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ped_itens')
         RETURN FALSE
      END IF

      LET pr_itens[p_ind].qtd_cancelar = 0

      IF NOT pol0932_carrega_ordens() THEN
         RETURN FALSE
      END IF
      
      LET p_ind = p_ind + 1
      
   END FOREACH      

   LET p_index = p_ind -1
   
   CALL SET_COUNT(p_ind - 1)
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0932_del_ordens_tmp()
#-------------------------------#

   DELETE FROM ops_tmp_304
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando', 'ops_tmp_304')
      RETURN FALSE
   END IF
   
   DELETE FROM ocs_tmp_304
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando', 'ocs_tmp_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0932_carrega_ordens()
#-------------------------------#

   IF NOT pol0932_del_estrut_tmp() THEN
      RETURN FALSE
   END IF

   LET p_cod_item_pai    = '0'
   LET p_cod_item_compon = pr_itens[p_ind].cod_item
   LET p_qtd_compon      = 1
   LET p_explodiu        = 'N'
   LET p_num_seq         = 0

   IF NOT pol0932_le_tip_item(pr_itens[p_ind].cod_item) THEN
      RETURN FALSE
   END IF
      
   IF NOT pol0932_ins_estrut() THEN
      RETURN FALSE
   END IF

   IF NOT pol0932_explode_estrutura() THEN
      RETURN FALSE
   END IF

   SELECT COUNT(cod_empresa)
     INTO p_count
     FROM pedido_mrp_304
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_ped_vend
      AND num_seq     =pr_itens[p_ind].num_sequencia
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'pedido_mrp_304')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET pr_itens[p_ind].ies_oc = 'S'
      LET pr_itens[p_ind].ies_op = 'S'

      IF NOT pol0932_carrega_ocs() THEN
         RETURN FALSE
      END IF
   
      IF NOT pol0932_carrega_ops() THEN
         RETURN FALSE
      END IF
   ELSE
      LET pr_itens[p_ind].ies_oc = 'N'
      LET pr_itens[p_ind].ies_op = 'N'
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0932_del_estrut_tmp()
#--------------------------------#

   DELETE FROM estr_tmp_304

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando', 'estr_tmp_304')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0932_explode_estrutura()
#-----------------------------------#

   DEFINE p_sequencia SMALLINT
   
   WHILE TRUE
    
    SELECT COUNT(cod_item)
      INTO p_count
      FROM estr_tmp_304
     WHERE explodiu = 'N'
     
    IF STATUS <> 0 THEN
       CALL log003_err_sql('Lendo','estr_tmp_304:while')
       RETURN FALSE
    END IF
    
    IF p_count = 0 THEN
       EXIT WHILE
    END IF
    
    DECLARE cq_exp CURSOR FOR
     SELECT num_seq,
            cod_item,
            qtd_neces
       FROM estr_tmp_304
      WHERE explodiu = 'N'
    
    FOREACH cq_exp INTO p_sequencia, p_cod_item_pai, p_qtd_neces
    
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','estr_tmp_304:cq_exp')
          RETURN FALSE
       END IF
       
       UPDATE estr_tmp_304
          SET explodiu = 'S'
        WHERE num_seq = p_sequencia

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Atualizando','estr_tmp_304:cq_exp')
          RETURN FALSE
       END IF
       
       LET p_hoje = TODAY 
       
       DECLARE cq_est CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria,
               pct_refug
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_item_pai
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
               (dat_validade_ini IS NULL AND dat_validade_fim >= p_hoje) OR
               (dat_validade_fim IS NULL AND dat_validade_ini <= p_hoje )OR
               (p_hoje BETWEEN dat_validade_ini AND dat_validade_fim))
       
       FOREACH cq_est INTO p_cod_item_compon, p_qtd_compon, p_pct_refug

          IF STATUS <> 0 THEN
             CALL log003_err_sql('Lendo','estrutura:cq_est')
             RETURN FALSE
          END IF
       
          IF NOT pol0932_le_tip_item(p_cod_item_compon) THEN
             RETURN FALSE
          END IF
          
          LET p_qtd_compon = p_qtd_compon + (p_qtd_compon * p_pct_refug / 100)
          LET p_qtd_compon = p_qtd_compon * p_qtd_neces
          
          IF p_ies_tip_item = 'C' THEN
             LET p_explodiu = 'S'
          ELSE
             LET p_explodiu = 'N'
          END IF
          
          IF p_ies_tip_item MATCHES '[BC]' THEN
             SELECT num_seq
               INTO p_num_seq
               FROM estr_tmp_304
              WHERE cod_item = p_cod_item_compon
                AND tip_item = p_ies_tip_item
             
             IF STATUS = 0 THEN
                IF NOT pol0932_atu_estrut() THEN
                   RETURN FALSE
                END IF
             ELSE
                IF NOT pol0932_ins_estrut() THEN
                   RETURN FALSE
                END IF
             END IF
          ELSE
             IF NOT pol0932_ins_estrut() THEN
                RETURN FALSE
             END IF
          END IF
                    
       END FOREACH
   
    END FOREACH
   
   END WHILE
   
   RETURN TRUE

END FUNCTION 

#---------------------------------------#
FUNCTION pol0932_le_tip_item(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT ies_tip_item
     INTO p_ies_tip_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      ERROR 'Item:',p_cod_item
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

  RETURN TRUE
  
END FUNCTION

#----------------------------#
FUNCTION pol0932_ins_estrut()
#----------------------------#

   LET p_num_seq = p_num_seq + 1

   INSERT INTO estr_tmp_304
      VALUES(p_num_seq,
             p_cod_item_pai,
             p_cod_item_compon,
             p_ies_tip_item,
             p_qtd_compon,
             p_explodiu)
                   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estr_tmp_304:insert')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0932_atu_estrut()
#----------------------------#

   UPDATE estr_tmp_304
      SET qtd_neces = qtd_neces + p_qtd_compon
    WHERE num_seq = p_num_seq
                   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizado','estr_tmp_304:update')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0932_carrega_ocs()
#-----------------------------#

   DECLARE cq_estr CURSOR FOR
    SELECT cod_item,
           qtd_neces
      FROM estr_tmp_304
     WHERE tip_item IN ('B','C')
     
   FOREACH cq_estr INTO p_cod_item, p_qtd_neces
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_estr')
         RETURN FALSE
      END IF
      
      DECLARE cq_ocs CURSOR FOR
       SELECT num_oc,
              ies_situa_oc,
              (qtd_solic - qtd_recebida),
              cod_fornecedor
         FROM ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_cod_item
          AND ies_situa_oc IN ('P','A','R')
          AND qtd_solic   > qtd_recebida
          AND ies_versao_atual = 'S'

      FOREACH cq_ocs INTO p_num_oc, p_ies_situa, p_saldo, p_cod_fornecedor
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cq_ocs')
            RETURN FALSE
         END IF
         
         IF p_cod_fornecedor = ' ' THEN
            LET p_ies_situa = 'S'
         ELSE
            LET p_ies_situa = 'N'
         END IF
         
         INSERT INTO ocs_tmp_304
          VALUES(p_tela.num_ped_vend,
                 pr_itens[p_ind].num_sequencia,
                 p_cod_item,
                 p_qtd_neces,
                 p_num_oc,
                 p_saldo,
                 p_ies_situa)
                 

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','ocs_tmp_304')
            RETURN FALSE
         END IF
      
      END FOREACH

   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0932_carrega_ops()
#-----------------------------#
  
   LET p_num_docum = p_tela.num_ped_vend 
   LET p_num_docum = p_num_docum CLIPPED, '/', 
       pr_itens[p_ind].num_sequencia USING '<<<'

   DECLARE cq_car_op CURSOR FOR
    SELECT cod_item,
           qtd_neces
      FROM estr_tmp_304
     WHERE tip_item IN ('F','P')
     
   FOREACH cq_car_op INTO p_cod_item, p_qtd_neces
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_estr')
         RETURN FALSE
      END IF
      
      DECLARE cq_ops CURSOR FOR
       SELECT num_ordem,
              ies_situa,
             (qtd_planej - qtd_boas - qtd_refug - qtd_sucata)
		     FROM ordens
		    WHERE cod_empresa = p_cod_empresa
	  	    AND ies_situa  <> '9'
		      AND num_docum   = p_num_docum
		      AND cod_item    = p_cod_item

      FOREACH cq_ops INTO
           p_num_op,
           p_ies_situa,
           p_saldo
             
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','ordens')
            RETURN FALSE
         END IF  
         
         IF p_ies_situa < 4 THEN
            LET p_ies_situa = 'S'
         ELSE
            LET p_ies_situa = 'N'
         END IF
         
         INSERT INTO ops_tmp_304
          VALUES(p_tela.num_ped_vend,
                 pr_itens[p_ind].num_sequencia,
                 p_num_op,
                 p_cod_item,
                 p_qtd_neces,
                 p_saldo,
                 p_ies_situa)

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Inserindo','ops_tmp_304')
            RETURN FALSE
         END IF  
      
      END FOREACH
              
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0932_cancelar()
#--------------------------#

   LET p_index = 1
   
   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      BEFORE FIELD qtd_solic
         NEXT FIELD qtd_cancelar
         
      AFTER FIELD qtd_cancelar
         
         IF pr_itens[p_index].num_sequencia IS NULL THEN
            LET pr_itens[p_index].qtd_cancelar = NULL
            DISPLAY '' TO sr_itens[s_index].qtd_cancelar
            IF FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2000 THEN
            ELSE
               NEXT FIELD qtd_cancelar
            END IF
         END IF
         
         IF pr_itens[p_index].qtd_cancelar < 0 OR 
            pr_itens[p_index].qtd_cancelar IS NULL THEN
            IF pr_itens[p_index].num_sequencia IS NULL THEN
               LET pr_itens[p_index].qtd_cancelar = NULL
            ELSE
               LET pr_itens[p_index].qtd_cancelar = 0
            END IF
            DISPLAY pr_itens[p_index].qtd_cancelar TO sr_itens[s_index].qtd_cancelar
         END IF
        
         IF pr_itens[p_index].qtd_cancelar > pr_itens[p_index].qtd_saldo THEN
            ERROR 'Informe uma quantidade menor ou igual ao saldo!'
            NEXT FIELD qtd_cancelar
         END IF

      ON KEY (control-o)
         IF pr_itens[p_index].ies_oc = 'S' THEN
            CALL pol0932_exibe_ocs() RETURNING p_status
         ELSE
            CALL log0030_mensagem('Não há OCs para esse item!','excla')
         END IF
         
      ON KEY (control-p)
         IF pr_itens[p_index].ies_op = 'S' THEN
            CALL pol0932_exibe_ops() RETURNING p_status
         ELSE
            CALL log0030_mensagem('Não há OPs para esse item!','excla')
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      CALL pol0932_limpa_tela()
      RETURN FALSE
   END IF
   
   IF NOT pol0932_processa() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------# 
FUNCTION pol0932_exibe_ocs()
#--------------------------# 

   DEFINE p_ind SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09321") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09321 AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   INITIALIZE pr_ocs TO NULL
   DISPLAY p_tela.num_ped_vend             TO num_pedido
   DISPLAY pr_itens[p_index].num_sequencia TO num_sequencia
   DISPLAY pr_itens[p_index].cod_item      TO cod_item
   
   CALL pol0932_le_den_item(pr_itens[p_index].cod_item)
   
   DISPLAY p_den_item TO den_item
   
   LET p_ind = 1
   
   DECLARE cq_ex_oc CURSOR FOR
    SELECT cod_compon,
           qtd_neces,
           num_oc,
           sdo_oc,
           ies_situa
      FROM ocs_tmp_304
     WHERE num_pedido    = p_tela.num_ped_vend
       AND num_sequencia = pr_itens[p_index].num_sequencia
                 
   FOREACH cq_ex_oc INTO 
           pr_ocs[p_ind].cod_compon,
           pr_ocs[p_ind].qtd_neces,
           pr_ocs[p_ind].num_oc,
           pr_ocs[p_ind].qtd_saldo,
           pr_ocs[p_ind].ies_situa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ex_oc')
         RETURN FALSE
      END IF
      
      CALL pol0932_le_den_item(pr_ocs[p_ind].cod_compon)
      
      LET pr_ocs[p_ind].den_compon = p_den_item
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 99 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_ocs TO sr_ocs.*
   
   
   CLOSE WINDOW w_pol09321
   
   LET INT_FLAG = FALSE
   
   RETURN TRUE
   
END FUNCTION

#--------------------------# 
FUNCTION pol0932_exibe_ops()
#--------------------------# 

   DEFINE p_ind SMALLINT

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol09322") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol09322 AT 5,5 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   INITIALIZE pr_ops TO NULL
   DISPLAY p_tela.num_ped_vend             TO num_pedido
   DISPLAY pr_itens[p_index].num_sequencia TO num_sequencia
   DISPLAY pr_itens[p_index].cod_item      TO cod_item
   
   CALL pol0932_le_den_item(pr_itens[p_index].cod_item)
   
   DISPLAY p_den_item TO den_item
   
   LET p_ind = 1

   DECLARE cq_ex_op CURSOR FOR
    SELECT num_op,
           cod_compon,
           qtd_neces,
           sdo_op,
           ies_situa
      FROM ops_tmp_304
     WHERE num_pedido    = p_tela.num_ped_vend
       AND num_sequencia = pr_itens[p_index].num_sequencia
                 
   FOREACH cq_ex_op INTO 
           pr_ops[p_ind].num_op,
           pr_ops[p_ind].cod_compon,
           pr_ops[p_ind].qtd_neces,
           pr_ops[p_ind].qtd_saldo,
           pr_ops[p_ind].ies_situa

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_ex_op')
         RETURN FALSE
      END IF

      CALL pol0932_le_den_item(pr_ops[p_ind].cod_compon)
      
      LET pr_ops[p_ind].den_compon = p_den_item
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 99 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou!','excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_ops TO sr_ops.*
       
   
   CLOSE WINDOW w_pol09322
   
   LET INT_FLAG = FALSE
   
   RETURN TRUE
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0932_le_den_item(p_cod_item)
#---------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item

   SELECT den_item_reduz
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      ERROR 'Item:',p_den_item
      CALL log003_err_sql('Lendo','item')
      LET p_den_item = NULL
   END IF
   
END FUNCTION
      

#--------------------------#   
FUNCTION pol0932_processa()
#--------------------------#   

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
 
   CALL log085_transacao("BEGIN") 
   
   IF NOT pol0932_atualiza_tabs() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0932_atualiza_tabs()
#-------------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_itens[p_ind].qtd_cancelar > 0 THEN
          
          LET p_num_seq    = pr_itens[p_ind].num_sequencia
          
          IF pr_itens[p_ind].ies_op = 'S' THEN
             IF NOT pol0932_ajusta_op() THEN
                RETURN FALSE
             END IF
          END IF
          
          IF pr_itens[p_ind].ies_oc = 'S' THEN
             IF NOT pol0932_ajusta_oc() THEN
                RETURN FALSE
             END IF
          END IF

          IF NOT pol0932_grava_ped_itens() THEN
             RETURN FALSE
          END IF
       END IF
       
   END FOR

   RETURN TRUE
   
END FUNCTION


#----------------------------#
FUNCTION pol0932_ajusta_op()
#----------------------------#

   DECLARE cq_ajusta_op CURSOR FOR
    SELECT DISTINCT
           cod_compon,
           qtd_neces,
           ies_situa
      FROM ops_tmp_304
     WHERE num_pedido    = p_tela.num_ped_vend
       AND num_sequencia = p_num_seq
       AND sdo_op        > 0
     ORDER BY cod_compon
       
   FOREACH cq_ajusta_op INTO p_cod_item, p_qtd_neces, p_ies_situa

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","cq_ajusta_op")
         RETURN FALSE
      END IF

      LET p_qtd_cancel = pr_itens[p_ind].qtd_cancelar * p_qtd_neces
            
      DECLARE cq_op_item CURSOR FOR 
       SELECT num_op,
              sdo_op
         FROM ops_tmp_304
        WHERE num_pedido    = p_tela.num_ped_vend
          AND num_sequencia = p_num_seq
          AND sdo_op        > 0
          AND cod_compon    = p_cod_item
          AND ies_situa     = 'S'
        ORDER BY num_op
       
      FOREACH cq_op_item INTO p_num_op, p_saldo

         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo","cq_ajusta_op")
            RETURN FALSE
         END IF

         IF p_ies_situa = 'N' THEN
            EXIT FOREACH
         END IF
      
         IF p_saldo > p_qtd_cancel THEN
            LET p_qtd_baixar = p_qtd_cancel
            LET p_qtd_cancel = 0
         ELSE
            LET p_qtd_baixar = p_saldo
            LET p_qtd_cancel = p_qtd_cancel - p_qtd_baixar
         END IF
      
         UPDATE ordens
            SET qtd_planej = qtd_planej - p_qtd_baixar
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_num_op
      
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Atualizando","ordens")
            RETURN FALSE
         END IF
    
         UPDATE necessidades
            SET qtd_necessaria = qtd_necessaria - p_qtd_baixar
          WHERE cod_empresa = p_cod_empresa
            AND num_ordem   = p_num_op

         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Atualizando","necessidades")
            RETURN FALSE
         END IF

         IF p_qtd_cancel <= 0 THEN
            EXIT FOREACH
         END IF
     
      END FOREACH

      IF p_qtd_cancel > 0 THEN
         LET p_tip_baixa = 'OP'
         IF NOT pol0932_grava_ord_bx() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0932_ajusta_oc()
#---------------------------#

   DECLARE cq_ajusta_oc CURSOR FOR
    SELECT DISTINCT
           cod_compon,
           qtd_neces,
           ies_situa
      FROM ocs_tmp_304
     WHERE num_pedido    = p_tela.num_ped_vend
       AND num_sequencia = p_num_seq
       AND sdo_oc        > 0
     ORDER BY cod_compon
       
   FOREACH cq_ajusta_oc INTO p_cod_item, p_qtd_neces, p_ies_situa

      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo","cq_ajusta_oc")
         RETURN FALSE
      END IF

      LET p_qtd_cancel = pr_itens[p_ind].qtd_cancelar * p_qtd_neces
      
      DECLARE cq_oc_item CURSOR FOR 
       SELECT num_oc,
              sdo_oc
         FROM ocs_tmp_304
        WHERE num_pedido    = p_tela.num_ped_vend
          AND num_sequencia = p_num_seq
          AND sdo_oc        > 0
          AND cod_compon    = p_cod_item
          AND ies_situa     = 'S'
        ORDER BY num_oc
       
      FOREACH cq_oc_item INTO p_num_oc, p_saldo

         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo","cq_oc_item")
            RETURN FALSE
         END IF

         IF p_ies_situa = 'N' THEN
            EXIT FOREACH
         END IF
      
         IF p_saldo > p_qtd_cancel THEN
            LET p_qtd_baixar = p_qtd_cancel
            LET p_qtd_cancel = 0
         ELSE
            LET p_qtd_baixar = p_saldo
            LET p_qtd_cancel = p_qtd_cancel - p_qtd_baixar
         END IF
      
         SELECT qtd_solic
           INTO p_qtd_ord
           FROM ordem_sup
          WHERE cod_empresa = p_cod_empresa
            AND num_oc      = p_num_oc
            AND ies_versao_atual = 'S'

         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo","ordem_sup")
            RETURN FALSE
         END IF
         
         IF p_qtd_ord > p_qtd_baixar THEN
            IF NOT pol0932_atu_oc() THEN
               RETURN FALSE
            END IF
         ELSE
            IF NOT pol0932_del_oc() THEN
               RETURN FALSE
            END IF
         END IF
         
         IF p_qtd_cancel <= 0 THEN
            EXIT FOREACH
         END IF
     
      END FOREACH
      
      IF p_qtd_cancel > 0 THEN
         LET p_tip_baixa = 'OC'
         IF NOT pol0932_grava_ord_bx() THEN
            RETURN FALSE
         END IF
      END IF
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0932_grava_ord_bx()
#------------------------------#

   SELECT cod_empresa
     FROM ordem_baixar_304
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_ped_vend
      AND num_seq     = p_num_seq
      AND cod_item    = p_cod_item
   
   IF STATUS = 100 THEN   
    INSERT INTO ordem_baixar_304
    VALUES(p_cod_empresa,
           p_tela.num_ped_vend,
           p_num_seq,
           p_cod_item,
           p_qtd_cancel,
           p_tip_baixa)
   ELSE
      UPDATE ordem_baixar_304
         SET qtd_baixar = qtd_baixar + p_qtd_cancel
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_tela.num_ped_vend
         AND num_seq     = p_num_seq
         AND cod_item    = p_cod_item
   END IF
   
   IF STATUS <> 0 then
      CALL log003_err_sql("Gravando","ordem_baixar_304")
      RETURN FALSE
   END IF
           
   RETURN TRUE

END FUNCTION


#------------------------#
FUNCTION pol0932_atu_oc()
#------------------------#

   UPDATE ordem_sup
      SET qtd_solic = qtd_solic - p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
     
   IF STATUS <> 0 then
      CALL log003_err_sql("Atualizando","ordem_sup")
      RETURN FALSE
   END IF

   UPDATE prog_ordem_sup
      SET qtd_solic = qtd_solic - p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
     
   IF STATUS <> 0 then
      CALL log003_err_sql("Atualizando","prog_ordem_sup")
      RETURN FALSE
   END IF

   UPDATE dest_ordem_sup
      SET qtd_particip_comp = qtd_particip_comp - p_qtd_baixar
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
     
   IF STATUS <> 0 then
      CALL log003_err_sql("Atualizando","dest_ordem_sup")
      RETURN FALSE
   END IF
    
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol0932_del_oc()
#------------------------#

   DELETE FROM ordem_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_oc        = p_num_oc
      AND ies_versao_atual = 'S'
   
     IF STATUS <> 0 THEN
        CALL log003_err_sql('Deletando','ordem_sup')
        RETURN FALSE
     END IF 

   DELETE FROM prog_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','prog_ordem_sup')
      RETURN FALSE
    END IF 

   DELETE FROM dest_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','dest_ordem_sup')
      RETURN FALSE
   END IF 

   DELETE FROM estrut_ordem_sup
    WHERE cod_empresa = p_cod_empresa
      AND num_oc      = p_num_oc

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','estrut_ordem_sup')
      RETURN FALSE
   END IF 

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0932_grava_ped_itens()
#---------------------------------#

   UPDATE ped_itens
      SET qtd_pecas_solic  = pr_itens[p_ind].qtd_solic,
          qtd_pecas_cancel = pr_itens[p_ind].qtd_cancelar
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_tela.num_ped_vend
      AND num_sequencia = pr_itens[p_ind].num_sequencia

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','ped_itens')
      RETURN FALSE
   END IF 
   
   RETURN TRUE
   
END FUNCTION

#-----------------------#
 FUNCTION pol0932_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION