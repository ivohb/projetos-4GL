#-----------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                      #
# PROGRAMA: pol0602                                                     #
# OBJETIVO: ESTOQUE DA MATÉRIA PRIMA DO ITEM                            #
# AUTOR...: POLO INFORMATICA - IVO                                      #
# DATA....: 22/06/2007                                                  #
#-----------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_caminho            CHAR(080),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_rowid              INTEGER,
          p_count              INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          sql_stmt             CHAR(300),
          where_clause         CHAR(300),  
          p_ies_cons           SMALLINT
   
   DEFINE p_cod_cliente        LIKE clientes.cod_cliente,
          p_num_seq            LIKE ped_itens.num_sequencia,
          p_cod_item_compon    LIKE item.cod_item,
          p_cod_compon_aux     LIKE item.cod_item,
          p_qtd_necessaria     LIKE estrutura.qtd_necessaria,
          p_qtd_acumulada      LIKE estrutura.qtd_necessaria,
          p_cod_local_estoq    LIKE item.cod_local_estoq,
          p_ies_oclinha        SMALLINT,
          p_ies_excessao       SMALLINT

   DEFINE p_tela            RECORD
          num_pedido        LIKE pedidos.num_pedido,
          num_pedido_cli    CHAR(15),
          nom_cliente       LIKE clientes.nom_cliente,
          qtd_solic         LIKE ped_itens.qtd_pecas_solic,
          qtd_atend         LIKE ped_itens.qtd_pecas_solic,
          qtd_canc          LIKE ped_itens.qtd_pecas_solic,
          qtd_reser         LIKE ped_itens.qtd_pecas_solic,
          qtd_roman         LIKE ped_itens.qtd_pecas_solic,
          qtd_saldo         LIKE ped_itens.qtd_pecas_solic,
          sit_pedido        LIKE pedidos.ies_sit_pedido
   END RECORD

   DEFINE p_telaa           RECORD
          num_pedido        LIKE pedidos.num_pedido,
          num_pedido_cli    CHAR(15),
          nom_cliente       LIKE clientes.nom_cliente,
          qtd_solic         LIKE ped_itens.qtd_pecas_solic,
          qtd_atend         LIKE ped_itens.qtd_pecas_solic,
          qtd_canc          LIKE ped_itens.qtd_pecas_solic,
          qtd_reser         LIKE ped_itens.qtd_pecas_solic,
          qtd_roman         LIKE ped_itens.qtd_pecas_solic,
          qtd_saldo         LIKE ped_itens.qtd_pecas_solic,
          sit_pedido        LIKE pedidos.ies_sit_pedido
   END RECORD

   DEFINE p_item            ARRAY[100] OF RECORD
          num_sequencia     LIKE ped_itens.num_sequencia,
          cod_item          LIKE item.cod_item,
          den_item          LIKE item.den_item
   END RECORD

   DEFINE p_mp             ARRAY[100] OF RECORD
          cod_compon        LIKE item.cod_item,
          den_compon        LIKE item.den_item_reduz,
          qtd_neces         DECIMAL(12,4),
          qtd_estoque       DECIMAL(11,3),
          qtd_difer         DECIMAL(11,4)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0602-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0602.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0602_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0602_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0602") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0602 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0602_cria_tab_tmp() THEN
      RETURN
   END IF
      
   MENU "OPCAO"
      COMMAND "Consulta" "Consulta dados da tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0602_consulta()
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0602_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0602_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 004
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0602

END FUNCTION

#------------------------------#
FUNCTION pol0602_cria_tab_tmp()
#------------------------------#

   WHENEVER ERROR CONTINUE

   DROP TABLE compon_tmp_1040;

   CREATE  TABLE compon_tmp_1040
     (
      cod_compon     CHAR(15),
      qtd_necessaria DECIMAL(14,7)
      
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","COMPON_TMP_1040")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0602_consulta()
#--------------------------#

   LET p_telaa.* = p_tela.*

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela, p_mp TO NULL

   CONSTRUCT BY NAME where_clause ON 
      pedidos.num_pedido,
      pedidos.num_pedido_cli

   IF INT_FLAG  THEN
      LET INT_FLAG = FALSE
      LET p_tela.* = p_telaa.*
      CALL pol0602_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT num_pedido FROM pedidos ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY num_pedido"

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.num_pedido
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0602_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0602_exibe_dados()
#-------------------------------#

   SELECT num_pedido_cli,
          cod_cliente,
          ies_sit_pedido
     INTO p_tela.num_pedido_cli,
          p_cod_cliente,
          p_tela.sit_pedido
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_tela.num_pedido

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","PEDIDOS")
      RETURN      
   END IF

   DISPLAY BY NAME p_tela.num_pedido, p_tela.sit_pedido, p_tela.num_pedido_cli
   
   SELECT cod_cliente
     FROM cli_c_oclinha_1040
    WHERE cod_cliente = p_cod_cliente
          
   IF STATUS = 0 THEN
      LET p_ies_oclinha = TRUE
   ELSE
      LET p_ies_oclinha = FALSE
   END IF
   
   SELECT nom_cliente
     INTO p_tela.nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","CLIENTES")
      RETURN      
   END IF

   DISPLAY BY NAME p_tela.nom_cliente

   LET p_index = 1
   
   DECLARE cq_itens_ped CURSOR FOR
    SELECT num_sequencia,
           cod_item
      FROM ped_itens
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido  = p_tela.num_pedido
     ORDER BY num_sequencia    

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","PED_ITENS")
      RETURN      
   END IF
 
   FOREACH cq_itens_ped INTO 
           p_item[p_index].num_sequencia,
           p_item[p_index].cod_item

      SELECT den_item
        INTO p_item[p_index].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_item[p_index].cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ITEM")
         RETURN      
      END IF

      LET p_index = p_index + 1         
   
   END FOREACH

   LET p_index = p_index - 1
   
   CALL SET_COUNT(p_index)

   IF p_index > 1 THEN   
      DISPLAY ARRAY p_item TO s_item.*
   
         BEFORE ROW
            LET p_index = ARR_CURR()
            LET s_index = SCR_LINE()
            CALL pol0602_exibe_mp()
      END DISPLAY
   ELSE
      INPUT ARRAY p_item 
         WITHOUT DEFAULTS 
            FROM s_item.* 
         BEFORE INPUT 
            EXIT INPUT
      END INPUT
      CALL pol0602_exibe_mp()
   END IF

 END FUNCTION

#--------------------------#
FUNCTION pol0602_exibe_mp()
#--------------------------#

         SELECT qtd_pecas_solic,
                qtd_pecas_atend,
                qtd_pecas_cancel,
                qtd_pecas_reserv,
                qtd_pecas_romaneio
           INTO p_tela.qtd_solic, 
                p_tela.qtd_atend,
                p_tela.qtd_canc,  
                p_tela.qtd_reser, 
                p_tela.qtd_roman
           FROM ped_itens
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_tela.num_pedido
            AND num_sequencia = p_item[p_index].num_sequencia

         LET p_tela.qtd_saldo = 
             p_tela.qtd_solic -   
             p_tela.qtd_atend -
             p_tela.qtd_canc  -
             p_tela.qtd_reser -
             p_tela.qtd_roman

         DISPLAY BY NAME p_tela.qtd_solic, p_tela.qtd_atend, p_tela.qtd_canc,
                         p_tela.qtd_reser, p_tela.qtd_roman, p_tela.qtd_saldo 
   
         IF pol0602_pega_estrut() THEN
            CALL pol0602_exibe_compons()
         END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0602_pega_estrut()
#------------------------------#

   DELETE FROM compon_tmp_1040

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("DELECAO","COMPON_TMP_1040")
      RETURN
   END IF

   LET p_ind = 1

   LET p_qtd_acumulada = 1

   DECLARE cq_estru_nevel_1 CURSOR FOR
    SELECT cod_item_compon,
           qtd_necessaria
      FROM estrutura
     WHERE cod_empresa  = p_cod_empresa
       AND cod_item_pai = p_item[p_index].cod_item
       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   FOREACH cq_estru_nevel_1 INTO
           p_cod_item_compon,
           p_qtd_necessaria

      LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria

      IF NOT pol0602_tem_estrutura() THEN
         IF NOT pol0602_insere_item() THEN
            RETURN FALSE
         ELSE
            CONTINUE FOREACH
         END IF
      END IF
      
      LET p_cod_compon_aux = p_cod_item_compon
      
      DECLARE cq_estru_nevel_2 CURSOR FOR
        SELECT cod_item_compon,
               qtd_necessaria
          FROM estrutura
         WHERE cod_empresa  = p_cod_empresa
           AND cod_item_pai = p_cod_compon_aux
           AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
      FOREACH cq_estru_nevel_2 INTO
              p_cod_item_compon,
              p_qtd_necessaria

         LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
         
         IF NOT pol0602_tem_estrutura() THEN
            IF NOT pol0602_insere_item() THEN
               RETURN FALSE
            ELSE
               CONTINUE FOREACH
            END IF
         END IF
         
         LET p_cod_compon_aux = p_cod_item_compon
         
         DECLARE cq_estru_nevel_3 CURSOR FOR
           SELECT cod_item_compon,
                  qtd_necessaria
             FROM estrutura
            WHERE cod_empresa  = p_cod_empresa
              AND cod_item_pai = p_cod_compon_aux
              AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                   (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                   (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                   (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
         FOREACH cq_estru_nevel_3 INTO
                 p_cod_item_compon,
                 p_qtd_necessaria

            LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
            
            IF NOT pol0602_tem_estrutura() THEN
               IF NOT pol0602_insere_item() THEN
                  RETURN FALSE
               ELSE
                  CONTINUE FOREACH
               END IF
            END IF
            
            LET p_cod_compon_aux = p_cod_item_compon
            DECLARE cq_estru_nevel_4 CURSOR FOR
              SELECT cod_item_compon,
                     qtd_necessaria
                FROM estrutura
               WHERE cod_empresa  = p_cod_empresa
                 AND cod_item_pai = p_cod_compon_aux
                 AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                      (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                      (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                      (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
            FOREACH cq_estru_nevel_4 INTO
                    p_cod_item_compon,
                    p_qtd_necessaria
      
               LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
               
               IF NOT pol0602_tem_estrutura() THEN
                  IF NOT pol0602_insere_item() THEN
                     RETURN FALSE
                  ELSE
                     CONTINUE FOREACH
                  END IF
               END IF
               
               LET p_cod_compon_aux = p_cod_item_compon
               DECLARE cq_estru_nevel_5 CURSOR FOR
                 SELECT cod_item_compon,
                        qtd_necessaria
                   FROM estrutura
                  WHERE cod_empresa  = p_cod_empresa
                    AND cod_item_pai = p_cod_compon_aux
                    AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                         (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                         (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                         (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
               FOREACH cq_estru_nevel_5 INTO
                       p_cod_item_compon,
                       p_qtd_necessaria

                  LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
                  
                  IF NOT pol0602_tem_estrutura() THEN
                     IF NOT pol0602_insere_item() THEN
                        RETURN FALSE
                     ELSE
                        CONTINUE FOREACH
                     END IF
                  END IF
                  
                  LET p_cod_compon_aux = p_cod_item_compon
                  DECLARE cq_estru_nevel_6 CURSOR FOR
                    SELECT cod_item_compon,
                           qtd_necessaria
                      FROM estrutura
                     WHERE cod_empresa  = p_cod_empresa
                       AND cod_item_pai = p_cod_compon_aux
                       AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
                            (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
                            (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
                            (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))
           
                  FOREACH cq_estru_nevel_6 INTO
                          p_cod_item_compon,
                          p_qtd_necessaria
                          
                     LET p_qtd_acumulada = p_qtd_acumulada * p_qtd_necessaria
                     
                     IF NOT pol0602_insere_item() THEN
                        RETURN FALSE
                     END IF
      
                  END FOREACH

               END FOREACH
               
            END FOREACH
      
         END FOREACH

      END FOREACH

   END FOREACH

   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol0602_tem_estrutura()
#-------------------------------#

   SELECT COUNT(cod_item_compon)
     INTO p_count
     FROM estrutura
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item_pai = p_cod_item_compon
      AND ((dat_validade_ini IS NULL AND dat_validade_fim IS NULL)  OR
           (dat_validade_ini IS NULL AND dat_validade_fim >= TODAY) OR
           (dat_validade_fim IS NULL AND dat_validade_ini <= TODAY )OR
           (TODAY BETWEEN dat_validade_ini AND dat_validade_fim))

   IF p_count = 0 THEN 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0602_insere_item()
#-----------------------------#

   SELECT ies_tip_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item_compon
      AND ies_tip_item IN ('B','C')
      
   IF STATUS <> 0 THEN
      LET p_qtd_acumulada = 1
      RETURN TRUE
   END IF

   SELECT qtd_necessaria
     FROM compon_tmp_1040
    WHERE cod_compon = p_cod_item_compon
   
   IF STATUS = 0 THEN
      UPDATE compon_tmp_1040
         SET qtd_necessaria = qtd_necessaria + p_qtd_acumulada
       WHERE cod_compon = p_cod_item_compon
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql("UPDADTE","COMPON_TMP_1040") 
         RETURN FALSE
      END IF
   ELSE    
      IF STATUS = 100 THEN
         INSERT INTO compon_tmp_1040
          VALUES(p_cod_item_compon,
                 p_qtd_acumulada)
         IF STATUS <> 0 THEN
            CALL log003_err_sql("INCLUSAO","compon_tmp_1040") 
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LEITURA","COMPON_TMP_1040") 
         RETURN FALSE
      END IF
   END IF
   
   LET p_qtd_acumulada = 1
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0602_exibe_compons()
#-------------------------------#

   LET p_ind = 1
   
   DECLARE cq_tmp CURSOR FOR
    SELECT *
      FROM compon_tmp_1040
   
   FOREACH cq_tmp INTO 
           p_mp[p_ind].cod_compon,
           p_qtd_necessaria

      SELECT den_item_reduz,
             cod_local_estoq
        INTO p_mp[p_ind].den_compon,
             p_cod_local_estoq
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_mp[p_ind].cod_compon
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ITEM") 
         RETURN
      END IF
      
      LET p_mp[p_ind].qtd_neces = p_qtd_necessaria * p_tela.qtd_saldo
      
      IF NOT pol0602_pega_estoque() THEN
         RETURN
      END IF

      LET p_ind = p_ind + 1      

   END FOREACH

   CALL SET_COUNT(p_ind - 1)

   IF p_ind > 8 THEN      
      DISPLAY ARRAY p_mp TO s_mp.*
   ELSE
      INPUT ARRAY p_mp 
         WITHOUT DEFAULTS 
            FROM s_mp.* 
         BEFORE INPUT 
            EXIT INPUT
      END INPUT
   END IF

END FUNCTION 

#------------------------------#
FUNCTION pol0602_pega_estoque()
#------------------------------#

   LET p_ies_excessao = FALSE
   
   SELECT cod_item
     FROM ite_s_oclinha_1040
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_mp[p_ind].cod_compon

   IF STATUS = 0 THEN
      LET p_ies_excessao = TRUE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LEITURA","ITE_S_OCLINHA_1040") 
         RETURN FALSE
      END IF
   END IF
   
   IF p_ies_oclinha = TRUE AND p_ies_excessao = FALSE THEN
      SELECT SUM(qtd_saldo) 
        INTO p_mp[p_ind].qtd_estoque
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_mp[p_ind].cod_compon
         AND num_lote      = p_tela.num_pedido_cli
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
   ELSE
      SELECT SUM(qtd_saldo) 
        INTO p_mp[p_ind].qtd_estoque
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_mp[p_ind].cod_compon
         AND cod_local     = p_cod_local_estoq
         AND ies_situa_qtd = 'L'
   END IF

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql("LEITURA","ESTOQUE_LOTE") 
      RETURN FALSE
   END IF

   IF p_mp[p_ind].qtd_estoque IS NULL THEN
      LET p_mp[p_ind].qtd_estoque = 0
   END IF
   
   LET p_mp[p_ind].qtd_difer = p_mp[p_ind].qtd_estoque - p_mp[p_ind].qtd_neces

   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0602_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_telaa.* = p_tela.*
      CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                         p_tela.num_pedido
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                         p_tela.num_pedido
      END CASE

      IF SQLCA.SQLCODE = NOTFOUND THEN
         ERROR "Nao Existem Mais Itens Nesta Direção"
         LET p_tela.* = p_telaa.*
      ELSE
         CALL pol0602_exibe_dados()
      END IF
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION
