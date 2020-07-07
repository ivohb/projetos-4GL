#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0854                                                 #
# CLIENTE.: GRAUNA                                                  #
# OBJETIVO: TRANSFERE MATERIAL DA TRANSPENDENTE P/ LOCAL DE PRODUÇÃO#
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 29/09/2008                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_erro_critico       SMALLINT,
          p_last_row           SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_6lpp               CHAR(02),
          p_8lpp               CHAR(02),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_msg                CHAR(70),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          
   DEFINE p_cod_item           LIKE item.cod_item,
          p_num_neces          LIKE trans_pendentes.num_neces,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_transf         LIKE estoque_lote.qtd_saldo,
          p_qtd_lote           LIKE estoque_lote.qtd_saldo,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_ies_situa          LIKE estoque_lote.ies_situa_qtd,
          p_num_transac        LIKE estoque_lote.num_transac,
          p_new_transac        LIKE estoque_lote.num_transac,
          p_num_pedido         LIKE pedidos.num_pedido,
          p_cod_local          LIKE item.cod_local_estoq,
          p_cod_local_prod     LIKE ordens.cod_local_prod,
          p_qtd_reservada      LIKE estoque_loc_reser.qtd_reservada,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_cod_local_transf   LIKE parametros_1040.cod_local_transf,
          p_parametros         LIKE par_pcp.parametros,
          p_ies_op_lote        CHAR(01),
          p_qtd_penden         SMALLINT,
          p_item_cambam        SMALLINT,
          p_query              CHAR(600)

   DEFINE p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_op_lote            RECORD LIKE op_lote.*

   
   DEFINE p_tela         RECORD 
          num_ordem      LIKE ordens.num_ordem,
          ies_situa      LIKE ordens.ies_situa,
          cod_item       LIKE ordens.cod_item,
          den_item       LIKE item.den_item,
          qtd_planej     LIKE ordens.qtd_planej,
          qtd_boas       LIKE ordens.qtd_boas,
          qtd_refug      LIKE ordens.qtd_refug,
          qtd_sucata     LIKE ordens.qtd_sucata,
          num_docum      LIKE ordens.num_docum,
          cod_cliente    LIKE pedidos.cod_cliente,
          nom_reduzido   LIKE clientes.nom_reduzido,
          ies_oclinha    CHAR(01),
          cod_oclinha    CHAR(30)
   END RECORD

   DEFINE pr_item        ARRAY[100] OF RECORD
          cod_item       LIKE item.cod_item,
          den_item       LIKE item.den_item,
          qtd_movto      LIKE trans_pendentes.qtd_movto
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0854-05.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0854.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0854_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0854_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0854") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0854 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0854_le_parametros() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros"
         CALL pol0854_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso!!!'
            NEXT OPTION "Processar"
         ELSE
            ERROR 'Operação cancelada!!!'            
         END IF
      COMMAND "Processar" "Processa a mudança de status"
         IF NOT p_ies_cons THEN
            ERROR 'Informar Parâmetros Previamente!!!'
         ELSE
            IF pol0854_processar() THEN
               ERROR "Processamento Efetuado c/ Sucesso"
               LET p_ies_cons = FALSE
            ELSE
               ERROR "Operação Cancelada!!!"
            END IF
         END IF
         NEXT OPTION "Informar"
      COMMAND "Pendências" "Exibe materiais pendentes da Ordem"
         IF NOT p_ies_cons THEN
            ERROR 'Informar Parâmetros Previamente!!!'
         ELSE
            IF pol0854_exibir() THEN
               ERROR "Processamento Efetuado c/ Sucesso"
            ELSE
               ERROR "Operação Cancelada!!!"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Sai do programa"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0854

END FUNCTION

#-------------------------------#
FUNCTION pol0854_le_parametros()
#-------------------------------#

   SELECT cod_local_transf
     INTO p_cod_local_transf
     FROM parametros_1040
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','parametros_1040')
      RETURN FALSE
   END IF

   SELECT parametros
     INTO p_parametros
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('lendo','par_pcp')
      RETURN FALSE
   END IF
   
   LET p_ies_op_lote = p_parametros[116,116]      

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0854_informar()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_ordem
 
         IF p_tela.num_ordem IS NULL THEN
            ERROR 'Campo com preenchimento obrigatário'
            NEXT FIELD num_ordem
         END IF
         
         IF NOT pol0854_le_ordem() THEN
            ERROR p_msg
            NEXT FIELD num_ordem
         END IF
         
         IF p_tela.ies_situa != 4 THEN
            ERROR 'Ordem de produção não está liberada!!!'
            NEXT FIELD num_ordem
         END IF
         
         IF NOT pol0854_le_item(p_tela.cod_item) THEN
            NEXT FIELD num_ordem
         END IF
         
         IF NOT pol0854_le_pendentes() THEN
            NEXT FIELD num_ordem
         END IF

         IF p_qtd_penden = 0 THEN
            ERROR 'Esta ordem não possui material na trans_pendentes!!!'
            NEXT FIELD num_ordem
         END IF

         IF NOT pol0854_le_pedidos() THEN
            NEXT FIELD num_ordem
         END IF

         DISPLAY BY NAME p_tela.*
         
   END INPUT

   IF INT_FLAG = 0 THEN
      LET p_ies_cons = TRUE
   ELSE
      LET p_ies_cons = FALSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN(p_ies_cons)
   
END FUNCTION
         

#--------------------------#
FUNCTION pol0854_le_ordem()
#--------------------------#

   LET p_msg = NULL

   SELECT ies_situa,
          cod_item, 
          qtd_planej,
          qtd_boas,
          qtd_refug,
          qtd_sucata,
          num_docum,
          cod_local_prod
     INTO p_tela.ies_situa,
          p_tela.cod_item,
          p_tela.qtd_planej,
          p_tela.qtd_boas,
          p_tela.qtd_refug,
          p_tela.qtd_sucata,
          p_tela.num_docum,
          p_cod_local_prod
     FROM ordens
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_tela.num_ordem
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'Ordem de produção não existe!!!'
      ELSE
         CALL log003_err_sql('Lendo','dados da ordem')
      END IF
   END IF

   RETURN FALSE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0854_le_item(p_cod_item)
#----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   LET p_tela.den_item = NULL
   
   SELECT den_item,
          cod_local_estoq
     INTO p_tela.den_item,
          p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql('Lendo','Descrição do item')
   END IF

   RETURN FALSE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0854_le_pendentes()
#-----------------------------#

   SELECT SUM(qtd_movto)
     INTO p_qtd_penden
     FROM trans_pendentes
    WHERE cod_empresa = p_cod_empresa
      AND num_ordem   = p_tela.num_ordem
    
   IF STATUS != 0 THEN
      CALL log003_err_sql('Lendo','dados da ordem')
      RETURN FALSE
   END IF

   IF p_qtd_penden IS NULL THEN
      LET p_qtd_penden = 0
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0854_le_pedidos()
#---------------------------#

   LET p_tela.ies_oclinha = 'N'
   LET p_num_pedido = p_tela.num_docum
   
   IF STATUS <> 0 THEN
      RETURN TRUE
   END IF

   SELECT cod_cliente,
          num_pedido_cli
     INTO p_tela.cod_cliente,
          p_tela.cod_oclinha
     FROM pedidos
    WHERE cod_empresa = p_cod_empresa
      AND num_pedido  = p_num_pedido
   
   IF STATUS = 100 THEN
      RETURN TRUE
   END IF
   
   IF STATUS != 0 THEN
      CALL log003_err_sql('Lendo','dados do pedido')
      RETURN FALSE
   END IF

   SELECT cod_cliente
     FROM cli_c_oclinha_1040
    WHERE cod_cliente = p_tela.cod_cliente

   IF STATUS = 100 THEN
      INITIALIZE p_tela.cod_cliente, p_tela.cod_oclinha TO NULL
      RETURN TRUE
   END IF
   
   IF STATUS != 0 THEN
      CALL log003_err_sql('Lendo','cli_c_oclinha_1040')
      RETURN FALSE
   END IF
   
   LET p_tela.ies_oclinha = 'S'
   
   SELECT nom_reduzido
     INTO p_tela.nom_reduzido
     FROM clientes
    WHERE cod_cliente = p_tela.cod_cliente

   IF STATUS != 0 THEN
      LET p_tela.nom_reduzido = NULL
   END IF
    
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0854_le_clientes()
#----------------------------#

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0854_processar()
#---------------------------#

   IF log004_confirm(19,20) THEN
   ELSE
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   IF pol0854_transf_mat() THEN
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol0854_transf_mat()
#----------------------------#

   DECLARE cq_tp CURSOR FOR 
    SELECT cod_item,
           num_neces,
           qtd_movto
      FROM trans_pendentes
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_tela.num_ordem
   
   FOREACH cq_tp INTO 
           p_cod_item, p_num_neces, p_qtd_movto
           
      IF STATUS != 0 THEN
         CALL log003_err_sql('Lendo','trans_pendentes:cq_tm')
         RETURN FALSE
      END IF
      
      LET p_item_cambam = TRUE
      
      IF p_tela.ies_oclinha = 'S' THEN
         SELECT cod_item
           FROM ite_s_oclinha_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item
         IF STATUS = 100 THEN
            LET p_item_cambam = FALSE
         ELSE
            IF STATUS != 0 THEN
               CALL log003_err_sql('Lendo','ite_s_oclinha_1040:cq_tp')
               RETURN FALSE
            END IF
         END IF
      END IF

      IF NOT pol0854_le_item(p_cod_item) THEN
         RETURN FALSE
      END IF
               
      CALL pol0854_monta_select()
      
      IF NOT pol0854_checa_estoque() THEN
         RETURN FALSE
      END IF   
   
      IF p_qtd_movto > 0 THEN
         IF NOT pol0854_atualiza_pendencia() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0854_deleta_pendencia() THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0854_monta_select()
#------------------------------#

   IF p_item_cambam THEN
      LET p_query =
          "SELECT num_transac, num_lote, qtd_saldo, ies_situa_qtd ",
          "  FROM estoque_lote_ender ",
          " WHERE cod_empresa ='",p_cod_empresa,"' ",
          "   AND cod_item    ='",p_cod_item,"' ",
          "   AND cod_local   ='",p_cod_local,"' ",
          "   AND ies_situa_qtd IN ('L','E') ",
          "  ORDER BY dat_hor_producao"
   ELSE
      LET p_query =
          "SELECT num_transac, num_lote, qtd_saldo, ies_situa_qtd ",
          "  FROM estoque_lote_ender ",
          " WHERE cod_empresa ='",p_cod_empresa,"' ",
          "   AND cod_item    ='",p_cod_item,"' ",
          "   AND cod_local   ='",p_cod_local,"' ",
          "   AND num_lote    ='",p_tela.cod_oclinha,"' ",
          "   AND ies_situa_qtd IN ('L','E') ",
          "  ORDER BY dat_hor_producao"
   END IF
   
END FUNCTION

#-------------------------------#
FUNCTION pol0854_checa_estoque()
#-------------------------------#


   PREPARE var_query FROM p_query   
   DECLARE cq_ce CURSOR FOR var_query

   FOREACH cq_ce INTO 
           p_num_transac, p_num_lote, 
           p_qtd_saldo,   p_ies_situa

      SELECT SUM(qtd_reservada)
        INTO p_qtd_reservada 
        FROM estoque_loc_reser
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_local   = p_cod_local
         AND num_lote    = p_num_lote
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','estoque_loc_reser:cq_ce')
         RETURN FALSE
      END IF  

      IF p_qtd_reservada IS NULL OR p_qtd_reservada < 0 THEN
         LET p_qtd_reservada = 0
      END IF

      IF p_qtd_saldo > p_qtd_reservada THEN
         LET p_qtd_saldo = p_qtd_saldo - p_qtd_reservada
         IF p_qtd_saldo >= p_qtd_movto THEN
            LET p_qtd_transf = p_qtd_movto
         ELSE
            LET p_qtd_transf = p_qtd_saldo
         END IF
         IF NOT pol0854_grava_loc_estoq() THEN
            RETURN FALSE
         END IF
         LET p_qtd_lote = p_qtd_transf
         IF NOT pol0854_grava_loc_prod() THEN
            RETURN FALSE
         END IF
         LET p_qtd_movto = p_qtd_movto - p_qtd_lote
         IF p_qtd_movto <= 0 THEN
            EXIT FOREACH
         END IF
      ELSE
         LET p_qtd_saldo = 0
      END IF

   END FOREACH

   RETURN TRUE
   
END FUNCTION
  
#--------------------------------#
FUNCTION pol0854_grava_loc_estoq()
#--------------------------------#

   SELECT *
     INTO p_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
    
   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Lendo','estoque_lote_ender:fet')
      RETURN FALSE
   END IF   

   IF NOT pol0854_atualiza_lote_ender() THEN
      RETURN FALSE
   END IF

   IF NOT pol0854_deleta_lote_ender() THEN
      RETURN FALSE
   END IF

   IF NOT pol0854_grava_lote() THEN
      RETURN FALSE
   END IF

   IF NOT pol0854_deleta_lote() THEN
      RETURN FALSE
   END IF
   
   IF p_qtd_transf < 0 THEN
      LET p_qtd_transf = p_qtd_transf * (-1)
   END IF
   
   IF NOT pol0854_grava_transacoes() THEN
      RETURN FALSE
   END IF

   IF p_ies_op_lote = 'S' THEN
      IF NOT pol0854_grava_op_lote() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0854_atualiza_lote_ender()
#------------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo - p_qtd_transf
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Update','estoque_lote_ender:fet')
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0854_deleta_lote_ender()
#------------------------------------#

   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      AND qtd_saldo   = 0

   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Deletando','estoque_lote_ender:fet')
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0854_grava_lote()
#----------------------------#

   CALL pol0854_le_lote()

   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Lendo','estoque_lote:fet')
      RETURN FALSE
   END IF   
      
   IF p_qtd_saldo < p_qtd_transf THEN
      LET p_msg = 'Item:',p_cod_item
      LET p_msg = p_msg CLIPPED, ' Lote:',p_num_lote
      LET p_msg = p_msg CLIPPED, ' Falta saldo na estoque_lote'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF NOT pol0854_atualiza_lote() THEN
      RETURN TRUE
   END IF
   
   RETURN TRUE

END FUNCTION
   
#-------------------------------#
FUNCTION pol0854_atualiza_lote()
#-------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo - p_qtd_transf
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Update','estoque_lote:fet')
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0854_le_lote()
#-------------------------#

   IF p_num_lote IS NULL THEN
      SELECT num_transac, qtd_saldo
        INTO p_num_transac,
             p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote IS NULL
   ELSE
      SELECT num_transac, qtd_saldo
        INTO p_num_transac,
             p_qtd_saldo
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_empresa
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      = p_num_lote
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0854_deleta_lote()
#-----------------------------#

   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_empresa
      AND num_transac = p_num_transac
      AND qtd_saldo   = 0

   IF STATUS <> 0 THEN      
      CALL log003_err_sql('Deletando','estoque_lote:fet')
      RETURN FALSE
   END IF   

   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol0854_grava_transacoes()
#----------------------------------#

   SELECT cod_estoque_ac
     INTO p_cod_operacao
     FROM par_pcp
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','Operacao de transferencia')
      RETURN FALSE
   END IF

   IF NOT pol0854_ins_estoq_trans() THEN
      RETURN FALSE
   END IF
   
   LET p_num_transac = SQLCA.SQLERRD[2]

   IF NOT pol0854_ins_est_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0854_ins_est_auditoria() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0854_ins_estoq_trans()
#---------------------------------#

   INITIALIZE p_estoque_trans.* TO NULL

   LET p_estoque_trans.cod_empresa        = p_cod_empresa
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_cod_item
   LET p_estoque_trans.dat_movto          = TODAY
   LET p_estoque_trans.dat_ref_moeda_fort = TODAY
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.ies_tip_movto      = 'N'
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_prog           = "pol0854"
   LET p_estoque_trans.num_docum          = p_tela.num_ordem
   LET p_estoque_trans.num_seq            = NULL
   LET p_estoque_trans.cus_unit_movto_p   = 0
   LET p_estoque_trans.cus_tot_movto_p    = 0
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = NULL
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.qtd_movto          = p_qtd_transf
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa
   LET p_estoque_trans.cod_local_est_orig = p_cod_local
   LET p_estoque_trans.cod_local_est_dest = p_cod_local_transf
   LET p_estoque_trans.num_lote_orig      = p_num_lote
   LET p_estoque_trans.num_lote_dest      = p_num_lote

   INSERT INTO estoque_trans VALUES (p_estoque_trans.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","ESTOQUE_TRANS")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
 FUNCTION pol0854_ins_est_trans_end()
#------------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.num_transac      = p_num_transac
   LET p_estoque_trans_end.endereco         = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.cod_grade_1      = p_estoque_lote_ender.cod_grade_1
   LET p_estoque_trans_end.cod_grade_2      = p_estoque_lote_ender.cod_grade_2
   LET p_estoque_trans_end.cod_grade_3      = p_estoque_lote_ender.cod_grade_3
   LET p_estoque_trans_end.cod_grade_4      = p_estoque_lote_ender.cod_grade_4
   LET p_estoque_trans_end.cod_grade_5      = p_estoque_lote_ender.cod_grade_5
   LET p_estoque_trans_end.num_ped_ven      = p_estoque_lote_ender.num_ped_ven
   LET p_estoque_trans_end.num_seq_ped_ven  = p_estoque_lote_ender.num_seq_ped_ven
   LET p_estoque_trans_end.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_estoque_trans_end.dat_hor_validade = p_estoque_lote_ender.dat_hor_validade
   LET p_estoque_trans_end.num_peca         = p_estoque_lote_ender.num_peca
   LET p_estoque_trans_end.num_serie        = p_estoque_lote_ender.num_serie
   LET p_estoque_trans_end.comprimento      = p_estoque_lote_ender.comprimento
   LET p_estoque_trans_end.largura          = p_estoque_lote_ender.largura
   LET p_estoque_trans_end.altura           = p_estoque_lote_ender.altura
   LET p_estoque_trans_end.diametro         = p_estoque_lote_ender.diametro
   LET p_estoque_trans_end.dat_hor_reserv_1 = p_estoque_lote_ender.dat_hor_reserv_1
   LET p_estoque_trans_end.dat_hor_reserv_2 = p_estoque_lote_ender.dat_hor_reserv_2
   LET p_estoque_trans_end.dat_hor_reserv_3 = p_estoque_lote_ender.dat_hor_reserv_3
   LET p_estoque_trans_end.qtd_reserv_1     = p_estoque_lote_ender.qtd_reserv_1
   LET p_estoque_trans_end.qtd_reserv_2     = p_estoque_lote_ender.qtd_reserv_2
   LET p_estoque_trans_end.qtd_reserv_3     = p_estoque_lote_ender.qtd_reserv_3
   LET p_estoque_trans_end.num_reserv_1     = p_estoque_lote_ender.num_reserv_1
   LET p_estoque_trans_end.num_reserv_2     = p_estoque_lote_ender.num_reserv_2
   LET p_estoque_trans_end.num_reserv_3     = p_estoque_lote_ender.num_reserv_3
   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = p_estoque_lote_ender.endereco
   LET p_estoque_trans_end.tex_reservado    = p_estoque_lote_ender.tex_reservado

   INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

   IF STATUS <> 0 THEN
     LET p_msg = 'ERRO:(',STATUS, ') INSERINDO NA TAB ESTOQUE_TRANS_END'  
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0854_ins_est_auditoria()
#-----------------------------------#

  INSERT INTO estoque_auditoria 
     VALUES(p_cod_empresa, p_num_transac, p_user, TODAY,'pol0854')

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0854_grava_loc_prod()
#--------------------------------#

   LET p_qtd_transf = -p_qtd_transf
   LET p_cod_local  = p_cod_local_transf
   
   IF NOT pol0854_le_lote_ender() THEN
      RETURN FALSE
   END IF
   
   IF STATUS = 0 THEN
      IF NOT pol0854_atualiza_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0854_insere_lote_ender() THEN
         RETURN FALSE
      END IF
   END IF   
   
   CALL pol0854_le_lote()
   
   IF STATUS = 0 THEN
      IF NOT pol0854_atualiza_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0854_insere_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('Lendo','estoque_lote:fglp')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0854_le_lote_ender()
#-------------------------------#
   
   IF p_estoque_lote_ender.num_lote IS NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_cod_local
         AND num_lote IS NULL
         AND largura     = p_estoque_lote_ender.largura
         AND altura      = p_estoque_lote_ender.altura
         AND diametro    = p_estoque_lote_ender.diametro
         AND comprimento = p_estoque_lote_ender.comprimento
   ELSE
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_estoque_lote_ender.cod_item
         AND cod_local   = p_cod_local_transf
         AND num_lote    = p_estoque_lote_ender.num_lote
         AND largura     = p_estoque_lote_ender.largura
         AND altura      = p_estoque_lote_ender.altura
         AND diametro    = p_estoque_lote_ender.diametro
         AND comprimento = p_estoque_lote_ender.comprimento
   END IF
      
   IF STATUS = 0 OR STATUS = 100 THEN
      RETURN TRUE
   ELSE
     CALL log003_err_sql('lendo','estoque_lote_ender:flle')
     RETURN FALSE
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0854_insere_lote_ender()
#----------------------------------#

   LET p_estoque_lote_ender.num_transac = 0
   LET p_estoque_lote_ender.cod_local = p_cod_local
   LET p_estoque_lote_ender.qtd_saldo = p_qtd_lote
   
   INSERT INTO estoque_lote_ender
      VALUES(p_estoque_lote_ender.*)
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_lote_ender')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0854_insere_lote()
#-----------------------------#

   LET p_estoque_lote.cod_empresa   = p_cod_empresa
   LET p_estoque_lote.cod_item      = p_cod_item
   LET p_estoque_lote.cod_local     = p_cod_local
   LET p_estoque_lote.num_lote      = p_num_lote
   LET p_estoque_lote.qtd_saldo     = p_qtd_lote
   LET p_estoque_lote.ies_situa_qtd = p_ies_situa
   LET p_estoque_lote.num_transac   = 0
   
   INSERT INTO estoque_lote
      VALUES(p_estoque_lote.*)
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','estoque_lote')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0854_grava_op_lote()
#--------------------------------#

   IF p_num_lote IS NULL THEN
      SELECT rowid
        INTO p_rowid
        FROM op_lote
       WHERE cod_empresa     = p_cod_empresa
         AND num_ordem       = p_tela.num_ordem
         AND cod_item_compon = p_cod_item
         AND ies_origem_info = 'P'
         AND num_lote IS NULL
   ELSE   
      SELECT rowid
        INTO p_rowid
        FROM op_lote
       WHERE cod_empresa     = p_cod_empresa
         AND num_ordem       = p_tela.num_ordem
         AND cod_item_compon = p_cod_item
         AND num_lote        = p_num_lote
         AND ies_origem_info = 'P'
   END IF

   IF STATUS = 0 THEN         
      IF NOT pol0854_atualiza_op_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0854_insere_op_lote() THEN
         RETURN FALSE
      END IF
   END IF   

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0854_atualiza_op_lote()
#---------------------------------#

   UPDATE op_lote
      SET qtd_transf = qtd_transf + p_qtd_transf,
          saldo      = saldo + p_qtd_transf
    WHERE rowid = p_rowid

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','op_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0854_insere_op_lote()
#--------------------------------#

   LET p_op_lote.cod_empresa      = p_cod_empresa
   LET p_op_lote.ies_origem_info  = "P"
   LET p_op_lote.num_ordem        = p_tela.num_ordem
   LET p_op_lote.cod_item_compon  = p_cod_item
   LET p_op_lote.dat_hor_entrada  = "1900-01-01 00:00:00"
   LET p_op_lote.cod_local_baixa  = p_cod_local_prod
   LET p_op_lote.num_lote         = p_num_lote 
   LET p_op_lote.qtd_transf       = p_qtd_transf
   LET p_op_lote.qtd_cons         = 0
   LET p_op_lote.endereco         = p_estoque_lote_ender.endereco
   LET p_op_lote.num_volume       = p_estoque_lote_ender.num_volume
   LET p_op_lote.dat_hor_producao = p_estoque_lote_ender.dat_hor_producao
   LET p_op_lote.dat_hor_valid    = p_estoque_lote_ender.dat_hor_validade
   LET p_op_lote.num_peca         = p_estoque_lote_ender.num_peca
   LET p_op_lote.num_serie        = p_estoque_lote_ender.num_serie
   LET p_op_lote.comprimento      = p_estoque_lote_ender.comprimento
   LET p_op_lote.largura          = p_estoque_lote_ender.largura
   LET p_op_lote.altura           = p_estoque_lote_ender.altura
   LET p_op_lote.diametro         = p_estoque_lote_ender.diametro
   
   INITIALIZE p_op_lote.parametros   TO NULL

   INSERT INTO op_lote VALUES (p_op_lote.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','op_lote')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0854_atualiza_pendencia()
#-----------------------------------#

   UPDATE trans_pendentes
      SET qtd_movto = p_qtd_movto
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      AND num_ordem   = p_tela.num_ordem
      AND num_neces   = p_num_neces

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Autalizando','trans_pendentes')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0854_deleta_pendencia()
#----------------------------------#

   DELETE FROM trans_pendentes
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      AND num_ordem   = p_tela.num_ordem
      AND num_neces   = p_num_neces

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Deletando','trans_pendentes')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------#
FUNCTION pol0854_exibir()
#-----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08541") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08541 AT 7,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL pol0854_exibir_penden() RETURNING p_status
   
   CLOSE WINDOW w_pol08541
   
   RETURN(p_status)
   
END FUNCTION

#-------------------------------#
FUNCTION pol0854_exibir_penden()
#-------------------------------#

   LET p_index = 1
   INITIALIZE pr_item TO NULL
   
   DECLARE cq_ex CURSOR FOR
    SELECT cod_item,
           qtd_movto
      FROM trans_pendentes
     WHERE cod_empresa = p_cod_empresa
       AND num_ordem   = p_tela.num_ordem
       
   FOREACH cq_ex INTO 
           pr_item[p_index].cod_item, 
           pr_item[p_index].qtd_movto
           
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','trans_pendentes:cq_ex')
         RETURN FALSE
      END IF
      
      IF pol0854_le_item(pr_item[p_index].cod_item) THEN
         LET pr_item[p_index].den_item = p_tela.den_item   
      END IF

      LET p_index = p_index + 1
  
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Não há pendência de materias p/ a ordem informada!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_item TO sr_item.*
   
   RETURN TRUE
   
END FUNCTION

###-----------------------FIM DO PROGRAMA-----------------------###
