###PARSER-Não remover esta linha(Framework Logix)###
 #--------------------------------------------------------------------#
 # SISTEMA.: VDP                                                      #
 # OBJETIVO: FUNCAO RESPONSAVEL POR GRAVAR AS INFORMAÇÕES ESPECÍFICAS #
 #           DOS CLIENTES NA NFE/IMPRESSÃO NOTA.                      #
 # AUTOR...: LUIZ LEONARDO VIEIRA                                     #
 #--------------------------------------------------------------------#

 DATABASE logix

#---------------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_informacoes_especificas(l_empresa,
   l_tipo_nota, l_serie_nota, l_modo_exibicao_msg)
#---------------------------------------------------------------------#
{USO EXTERNO

 OBJETIVO: Esta função tem como objetivo atualizar as informações
 específicas da NFE/IMPRESSÃO DE NOTA nas tabelas temporárias.

 PARÂMETROS:
 1 - Código da empresa.
 2 - Tipo da nota fiscal.
 3 - Série da nota fiscal.
 4 - Modo de exibição de mensagem de erro durante o processamento.
     0 - ON-LINE. A mensagem será exibida ao usuário a partir da uma
         tela centralizada.
     1 - BATCH. A mensagem ficará armazenada na memória, para que o
         programa possa acessar e utilizar seu conteúdo de acordo com
         a necessidade da rotina em execução através das funções
         log0030_mensagem_get_<atributo>() ou exibi-la posteriormente
         em tela utilizando a função log0030_exibe_ultima_mensagem().

 RETORNO:

 1 - Status
     TRUE  - Tabelas atualizadas com sucesso.
     FALSE - Ocorreu erro na atualizadas das tabelas.
}

  DEFINE l_empresa            LIKE empresa.cod_empresa,
         l_tipo_nota          CHAR(1),
         l_serie_nota         LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg  SMALLINT,

         l_transacao_nfe      INTEGER,
         l_nnf                DECIMAL(9,0)

  IF NOT vdpy247_modifica_info_nf(l_modo_exibicao_msg) THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_nota_fiscal CURSOR FOR
  SELECT transacao_nfe,
         nNF
    FROM t_ident_nfe

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_nota_fiscal", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_nota_fiscal INTO l_transacao_nfe, l_nnf

     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_nota_fiscal", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     IF NOT vdpm95_fat_nf_mestre_leitura(l_empresa,
                                         l_transacao_nfe,
                                         TRUE,
                                         l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

     IF NOT vdpy247_atualiza_informacoes_itens(l_empresa,
                                               l_transacao_nfe,
                                               l_nnf,
                                               l_tipo_nota,
                                               l_serie_nota,
                                               l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

  END FOREACH

  RETURN TRUE

 END FUNCTION

#----------------------------------------------------------------#
 FUNCTION vdpy247_modifica_info_nf(l_modo_exibicao_msg)
#----------------------------------------------------------------#
  DEFINE l_modo_exibicao_msg    SMALLINT

  WHENEVER ERROR CONTINUE
  DELETE FROM t_info_adic
   WHERE tipo_texto = "NR_PEDIDO_CLI"

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DELETE","t_info_adic",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DELETE FROM t_info_adic
   WHERE tipo_texto = "NUMERO_PEDIDO"

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DELETE","t_info_adic",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DELETE FROM t_adic_pro
   WHERE tipo_texto = "TEXTO_ITEM_PEDIDO"

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DELETE","t_adic_pro",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#----------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_informacoes_itens(l_empresa,
                                             l_transacao_nfe,
                                             l_nnf,
                                             l_tipo_nota,
                                             l_serie_nota,
                                             l_modo_exibicao_msg)
#----------------------------------------------------------------#
  DEFINE l_empresa            LIKE empresa.cod_empresa,
         l_transacao_nfe      INTEGER,
         l_nnf                DECIMAL(9,0),
         l_tipo_nota          CHAR(1),
         l_serie_nota         LIKE nf_mestre.ser_nff,
         l_modo_exibicao_msg  SMALLINT,

         l_nitem              DECIMAL(3,0),
         l_Cprod              CHAR(60),
         l_Prod               CHAR(120),
         l_Pedido             DECIMAL(6,0),
         l_seq_ped            DECIMAL(5,0),
         l_num_om             DECIMAL(6,0)

  WHENEVER ERROR CONTINUE
  DECLARE cq_itens CURSOR FOR
  SELECT nitem,
         Cprod,
         Prod,
         Pedido,
         seq_ped,
         num_om
    FROM t_prod_serv
   WHERE transacao_nfe = l_transacao_nfe

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_itens", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_itens INTO l_nitem,
                        l_Cprod,
                        l_Prod,
                        l_Pedido,
                        l_seq_ped,
                        l_num_om

     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_itens", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     IF NOT vdpy247_atualiza_den_item(l_empresa,
                                      l_transacao_nfe,
                                      l_nnf,
                                      l_tipo_nota,
                                      l_serie_nota,
                                      l_nitem,
                                      l_Cprod,
                                      l_Prod,
                                      l_Pedido,
                                      l_seq_ped,
                                      l_num_om,
                                      l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF


  END FOREACH

  RETURN TRUE

 END FUNCTION

#--------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_den_item(l_empresa,
                                    l_transacao_nfe,
                                    l_nnf,
                                    l_tipo_nota,
                                    l_serie_nota,
                                    l_nitem,
                                    l_Cprod,
                                    l_Prod,
                                    l_Pedido,
                                    l_seq_ped,
                                    l_num_om,
                                    l_modo_exibicao_msg)
#--------------------------------------------------------------#
  DEFINE l_empresa                LIKE empresa.cod_empresa,
         l_transacao_nfe          INTEGER,
         l_nnf                    DECIMAL(9,0),
         l_tipo_nota              CHAR(1),
         l_serie_nota             LIKE nf_mestre.ser_nff,
         l_modo_exibicao_msg      SMALLINT,
         l_nitem                  DECIMAL(3,0),
         l_Cprod                  CHAR(60),
         l_Prod                   CHAR(120),
         l_Pedido                 DECIMAL(6,0),
         l_seq_ped                DECIMAL(5,0),
         l_num_om                 DECIMAL(6,0),

         l_compl_prod             CHAR(120),
         l_origem_nota_fiscal     LIKE fat_nf_mestre.origem_nota_fiscal,
         l_sql_stmt               CHAR(2000),
         l_num_reserva            LIKE ordem_montag_grade.num_reserva,
         l_num_lot                CHAR(15),
         l_num_lote               CHAR(37)

  CALL vdpy247_busca_texto_ped_it(l_empresa,
                                  l_Cprod,
                                  l_Pedido,
                                  l_seq_ped,
                                  l_transacao_nfe,
                                  l_nitem,
                                  l_modo_exibicao_msg)
     RETURNING l_compl_prod

  IF l_compl_prod IS NOT NULL AND
     l_compl_prod <> " " THEN
     LET l_Prod = l_Prod CLIPPED, l_compl_prod
  END IF

  IF l_Pedido IS NOT NULL AND
     l_Pedido <> 0 THEN
     LET l_Prod = l_Prod CLIPPED, " - PV: ", l_Pedido USING "<<<<<&"
  END IF

  LET l_origem_nota_fiscal = vdpm95_fat_nf_mestre_get_origem_nota_fiscal()

  IF l_origem_nota_fiscal = 'O' THEN
     LET l_sql_stmt =
        "SELECT num_reserva FROM ordem_montag_grade ",
        " WHERE cod_empresa   = '",l_empresa,"' ",
        "   AND num_om        = '",l_num_om,"' ",
        "   AND cod_item      = '",l_Cprod,"' ",
        "   AND num_sequencia = '",l_seq_ped,"' ",
        "   AND num_pedido    = '",l_Pedido,"' "
  ELSE
     LET l_sql_stmt =
        "SELECT reserva_estoque FROM fat_resv_item_nf ",
        " WHERE empresa           = '",l_empresa,"' ",
        "   AND seq_item_nf       = '",l_nitem,"' ",
        "   AND trans_nota_fiscal = '",l_transacao_nfe,"' "
  END IF

  WHENEVER ERROR CONTINUE
  PREPARE cq_cursor FROM l_sql_stmt

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("PREPARE", "cq_cursor", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_lote_rt CURSOR FOR cq_cursor

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE", "cq_lote_rt", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_lote_rt INTO l_num_reserva

     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE", "cq_lote_rt", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
     SELECT num_lote
       INTO l_num_lot
       FROM estoque_loc_reser
      WHERE cod_empresa = l_empresa
        AND num_reserva = l_num_reserva

     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CONTINUE FOREACH
     END IF

     IF l_num_lote IS NULL OR
        l_num_lote = " " THEN
        LET l_num_lote = l_num_lot
     ELSE
        LET l_num_lote = l_num_lote CLIPPED, ", ", l_num_lot
     END IF

  END FOREACH

  IF l_num_lote IS NOT NULL AND
     l_num_lote <> " " THEN
     LET l_Prod = l_Prod CLIPPED, " - LT: ", l_num_lote
  END IF

  WHENEVER ERROR CONTINUE
  UPDATE t_prod_serv
     SET Prod = l_Prod
   WHERE transacao_nfe = l_transacao_nfe
     AND nitem         = l_nitem

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("UPDATE", "t_prod_serv", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#------------------------------------------------#
 FUNCTION vdpy247_busca_texto_ped_it(l_empresa,
                                     l_Cprod,
                                     l_Pedido,
                                     l_seq_ped,
                                     l_transacao_nfe,
                                     l_nitem,
                                     l_modo_exibicao_msg)
#------------------------------------------------#
  DEFINE l_empresa            LIKE empresa.cod_empresa,
         l_Cprod              CHAR(60),
         l_Pedido             DECIMAL(6,0),
         l_seq_ped            DECIMAL(5,0),
         l_transacao_nfe      INTEGER,
         l_nitem              DECIMAL(3,0),
         l_modo_exibicao_msg  SMALLINT,

         l_compl_prod         CHAR(120),
         l_num_pedido_cli     LIKE pedidos.num_pedido_cli,
         l_mensagem           CHAR(2000),
         l_ordem              INTEGER,
         l_den_texto_1        CHAR(76),
         l_den_texto_2        CHAR(76)

  WHENEVER ERROR CONTINUE
  SELECT des_esp_item
    INTO l_compl_prod
    FROM item_esp
   WHERE cod_empresa = l_empresa
     AND cod_item    = l_Cprod
     AND num_seq     = 1

  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
  END IF

  IF l_compl_prod IS NULL OR
     l_compl_prod = " " THEN
     WHENEVER ERROR CONTINUE
     SELECT den_texto_1,
            den_texto_2
       INTO l_den_texto_1,
            l_den_texto_2
       FROM ped_itens_texto
      WHERE cod_empresa   = l_empresa
        AND num_pedido    = l_Pedido
        AND num_sequencia = l_seq_ped

     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
        IF l_den_texto_1 IS NOT NULL AND
           l_den_texto_1 <> " " THEN
           LET l_compl_prod = " - OC/LI: ", l_den_texto_1
        END IF
     END IF
  END IF

  WHENEVER ERROR CONTINUE
  SELECT num_pedido_cli
    INTO l_num_pedido_cli
    FROM pedidos
   WHERE cod_empresa = l_empresa
     AND num_pedido  = l_Pedido

  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

  IF l_num_pedido_cli IS NOT NULL AND
     l_num_pedido_cli <> " " THEN
     LET l_compl_prod = l_compl_prod CLIPPED, " - PC: ", l_num_pedido_cli
  ELSE
     IF l_den_texto_2 IS NOT NULL AND
        l_den_texto_2 <> " " THEN
        LET l_compl_prod = l_compl_prod CLIPPED, " - PC: ", l_den_texto_2
     END IF
  END IF

  RETURN l_compl_prod

 END FUNCTION


