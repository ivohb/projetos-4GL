#PARSER-Não remover esta linha(Framework Logix)###
#--------------------------------------------------------------------#
# SISTEMA.: VDP                                                      #
# OBJETIVO: ESPECIFICO CLIENTE KANAFLEX                              #
# AUTOR...: SEAN PABLO ESCHENBACH                                    #
# DATA....: 14/08/2012                                               #
#--------------------------------------------------------------------#

DATABASE logix

#---------------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_informacoes_especificas(l_empresa,
                                                   l_tipo_nota,
                                                   l_serie_nota,
                                                   l_modo_exibicao_msg)
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
         l_serie_nota         LIKE nf_mestre.ser_nff,
         l_modo_exibicao_msg  SMALLINT,
         l_envia_inf_nfe      CHAR(01),
         l_transacao_nfe      INTEGER,
         l_cod_cliente        CHAR(015)

  DEFINE l_nitem              DECIMAL(3,0),
         l_pedido             DECIMAL(6,0),
         l_seq_ped            DECIMAL(5,0)

  IF NOT vdpy247_declare_cursor(l_modo_exibicao_msg) THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_ident_nfe CURSOR FOR
    SELECT transacao_nfe
      FROM t_ident_nfe
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("declare","cq_ident_nfe",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_ident_nfe INTO l_transacao_nfe
  WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("foreach","cq_ident_nfe",l_modo_exibicao_msg)
        EXIT FOREACH
     END IF

     WHENEVER ERROR CONTINUE
       SELECT cliente
         INTO l_cod_cliente
         FROM fat_nf_mestre
        WHERE trans_nota_fiscal = l_transacao_nfe
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("select","fat_nf_mestre",l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       SELECT texto_parametro
         INTO l_envia_inf_nfe
         FROM vdp_cli_parametro
        WHERE cliente = l_cod_cliente
          AND parametro = 'xPednItemPe_KANAFLEX'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log0030_processa_err_sql("SELECT","VDP_CLI_PARAMETRO(PEDIDO_CLIENTE)",l_modo_exibicao_msg)
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_prod_serv USING l_transacao_nfe INTO l_nitem, l_pedido, l_seq_ped
     WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("FOREACH","CQ_PROD_SERV", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        IF l_envia_inf_nfe = "S" AND l_pedido IS NOT NULL AND l_pedido <> " " AND l_pedido > 0 THEN
           IF NOT vdpy247_busca_item_pedido(l_empresa,l_transacao_nfe,l_cod_cliente,l_nitem,l_pedido,l_seq_ped,l_modo_exibicao_msg) THEN
              RETURN FALSE
           END IF
        END IF
     END FOREACH
  END FOREACH
  FREE cq_ident_nfe
  FREE cq_prod_serv

  RETURN TRUE

 END FUNCTION

#----------------------------------------------------#
 FUNCTION vdpy247_declare_cursor(l_modo_exibicao_msg)
#----------------------------------------------------#
  DEFINE l_modo_exibicao_msg   SMALLINT
  DEFINE l_sql_stmt            CHAR(2000)

  LET l_sql_stmt = " SELECT nitem, ",
                          " pedido, ",
                          " seq_ped ",
                     " FROM t_prod_serv ",
                    " WHERE transacao_nfe = ? ",
                    " ORDER BY nitem"

  WHENEVER ERROR CONTINUE
   PREPARE var_prod_serv FROM l_sql_stmt
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
    CALL log0030_processa_err_sql("PREPARE SQL","VAR_PROD_SERV",l_modo_exibicao_msg)
    RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_prod_serv CURSOR FOR var_prod_serv
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
    CALL log0030_processa_err_sql("DECLARE CURSOR","CQ_PROD_SERV", l_modo_exibicao_msg)
    RETURN FALSE
  END IF

  FREE var_prod_serv

  RETURN TRUE

 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdpy247_busca_item_pedido(l_empresa,
                                    l_transacao_nfe,
                                    l_cod_cliente,
                                    l_nitem,
                                    l_pedido,
                                    l_seq_ped,
                                    l_modo_exibicao_msg)
#---------------------------------------------------------------------#
  DEFINE l_empresa            LIKE empresa.cod_empresa,
         l_transacao_nfe      INTEGER,
         l_cod_cliente        CHAR(015),
         l_nitem               DECIMAL(3,0),
         l_pedido             DECIMAL(6,0),
         l_seq_ped            DECIMAL(5,0),
         l_modo_exibicao_msg  SMALLINT

  DEFINE l_num_pedido_cli     LIKE pedidos.num_pedido_cli,
         l_seq_pedido_cliente DECIMAL(3,0)

  WHENEVER ERROR CONTINUE
    SELECT num_pedido_cli
      INTO l_num_pedido_cli
      FROM pedidos
     WHERE cod_empresa = l_empresa
       AND cod_cliente = l_cod_cliente
       AND num_pedido  = l_pedido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("select","pedidos",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    SELECT seq_pedido_cliente
      INTO l_seq_pedido_cliente
      FROM vdp_seq_ped_cliente_444
     WHERE empresa          = l_empresa
       AND pedido           = l_pedido
       AND seq_pedido_logix = l_seq_ped
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log0030_processa_err_sql("select","vdp_seq_ped_cliente_444",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  IF l_seq_pedido_cliente IS NULL OR l_seq_pedido_cliente = ' ' OR l_seq_pedido_cliente <= 0 THEN
     LET l_seq_pedido_cliente = l_seq_ped
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE t_prod_serv
       SET xPed     = l_num_pedido_cli,
           nItemPed = l_seq_pedido_cliente
     WHERE transacao_nfe = l_transacao_nfe
       AND nItem         = l_nitem
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log0030_processa_err_sql("update","t_prod_serv",l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#-------------------------------#
 FUNCTION vdpy247_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdpy247.4gl $|$Revision: 3 $|$Date: 31/08/12 11:10 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION
