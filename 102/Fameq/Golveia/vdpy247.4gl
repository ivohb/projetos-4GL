###PARSER-Não remover esta linha(Framework Logix)###
 #--------------------------------------------------------------------#
 # SISTEMA.: VDP                                                      #
 # OBJETIVO: FUNCAO RESPONSAVEL POR GRAVAR AS INFORMAÇÕES ESPECÍFICAS #
 #           DOS CLIENTES NA NFE/IMPRESSÃO NOTA.                      #
 # AUTOR...: DOUGLAS XAVIER                                           #
 #--------------------------------------------------------------------#

 DATABASE logix

 DEFINE m_ordem_impressao  SMALLINT

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
         l_tipo_nota          CHAR(8),
         l_serie_nota         LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg  SMALLINT,
         l_transacao_nfe      INTEGER,
         l_transacao_nfe_old  INTEGER,
         l_qtrib              DECIMAL(15,0),
         l_nNF                DECIMAL(10,0)


  LET l_transacao_nfe_old = 0

  IF NOT vdpy247_cria_temp_t_ped_cli_item(l_modo_exibicao_msg) THEN
     RETURN FALSE
  END IF

  IF NOT vdpy247_inclui_pedido_cliente(l_empresa,
                                       l_tipo_nota,
                                       l_serie_nota,
                                       l_modo_exibicao_msg) THEN
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_agrup CURSOR FOR
    SELECT transacao_nfe,
           nNF
      FROM t_ident_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_agrup", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_agrup INTO l_transacao_nfe,
                         l_nNF
  WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_agrup", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     IF l_transacao_nfe <> l_transacao_nfe_old THEN
        LET m_ordem_impressao   = 0
        LET l_transacao_nfe_old = l_transacao_nfe

        WHENEVER ERROR CONTINUE
          SELECT MAX(ordem)
            INTO m_ordem_impressao
            FROM t_info_adic
           WHERE transacao_nfe = l_transacao_nfe
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql('SELECT','t_info_adic',l_modo_exibicao_msg)
           RETURN FALSE
        END IF
        IF m_ordem_impressao IS NULL THEN
           LET m_ordem_impressao = 0
        END IF
     END IF

     IF NOT vdpy247_ajusta_msg_trib_ipi(l_empresa,
                                        l_transacao_nfe,
                                        l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

     IF NOT vdpy247_agrupa_itens_nfe(l_empresa,
                                     l_tipo_nota,
                                     l_serie_nota,
                                     l_transacao_nfe,
                                     l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

     IF NOT vdpy247_reordena_itens_nfe(l_empresa,
                                       l_tipo_nota,
                                       l_serie_nota,
                                       l_transacao_nfe,
                                       l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

     IF NOT vdpy247_texto_adicional_reajuste(l_empresa,
                                             l_transacao_nfe,
                                             l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

  END FOREACH

  IF NOT vdpy247_atualiza_prod(l_empresa,
                               l_tipo_nota,
                               l_serie_nota,
                               l_modo_exibicao_msg) THEN
     RETURN FALSE
  END IF

  FREE cq_agrup

  RETURN TRUE

 END FUNCTION

#-------------------------------------------------------#
 FUNCTION vdpy247_grava_msg_retorno(l_empresa,
                                    l_tipo_nota,
                                    l_serie_nota,
                                    l_transacao_nfe,
                                    l_nNF,
                                    l_modo_exibicao_msg)
#-------------------------------------------------------#
  DEFINE l_empresa             LIKE empresa.cod_empresa,
         l_tipo_nota           CHAR(1),
         l_serie_nota          LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg   SMALLINT,
         l_transacao_nfe       INTEGER,
         l_nitem               DECIMAL(3,0),
         l_cprod               CHAR(60),
         l_nNF                 DECIMAL(9,0),
         l_mensagem            CHAR(500),
         l_num_nf              LIKE item_dev_terc.num_nf,
         l_qtd_devolvida       LIKE item_dev_terc.qtd_devolvida,
         l_unid_terc           LIKE item_de_terc.cod_unid_med

  WHENEVER ERROR CONTINUE
   DECLARE cq_msg_retorno CURSOR FOR
    SELECT nitem,
           cprod
      FROM t_prod_serv
     WHERE transacao_nfe = l_transacao_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_msg_retorno", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_msg_retorno INTO l_nitem,
                               l_cprod
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_msg_retorno", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

     INITIALIZE l_mensagem TO NULL

     WHENEVER ERROR CONTINUE
      DECLARE cq_retorno CURSOR FOR
       SELECT a.num_nf,
              a.qtd_devolvida,
              b.cod_unid_med
         FROM item_dev_terc a,
              item_de_terc b
        WHERE a.cod_empresa    = l_empresa
          AND a.num_nf_retorno = l_nNF
          AND b.cod_empresa    = a.cod_empresa
          AND b.num_nf         = a.num_nf
          AND b.ser_nf         = a.ser_nf
          AND b.ssr_nf         = a.ssr_nf
          AND b.ies_especie_nf = a.ies_especie_nf
          AND b.cod_fornecedor = a.cod_fornecedor
          AND b.num_sequencia  = a.num_sequencia
          AND b.cod_item       = l_cprod
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_retorno", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_retorno INTO l_num_nf,
                              l_qtd_devolvida,
                              l_unid_terc
     WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_retorno", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        IF l_mensagem IS NULL OR l_mensagem = " " THEN
           LET l_mensagem = "NFE:",l_num_nf USING "&&&&&&&&&&",'=',l_qtd_devolvida USING "<<<&",l_unid_terc
        ELSE
           LET l_mensagem = l_mensagem CLIPPED, ' - ',l_num_nf USING "&&&&&&",'=',l_qtd_devolvida USING "<<<&",l_unid_terc
        END IF

     END FOREACH

     FREE cq_retorno

     IF  l_mensagem IS NOT NULL
     AND l_mensagem <> " " THEN
        CALL vdpr129_t_info_adic_prod_set_null()
        CALL vdpr129_t_info_adic_prod_set_transacao_nfe(l_transacao_nfe)
        CALL vdpr129_t_info_adic_prod_set_nitem(l_nitem)
        CALL vdpr129_t_info_adic_prod_set_ordem(0)
        CALL vdpr129_t_info_adic_prod_set_local_impr("A")
        CALL vdpr129_t_info_adic_prod_set_local_impr_danfe("CORPO")
        CALL vdpr129_t_info_adic_prod_set_tipo_texto("MSG_RET_UN_TERC")
        CALL vdpr129_t_info_adic_prod_set_Infadprod(l_mensagem)

        IF NOT vdpr129_t_info_adic_prod_inclui(l_modo_exibicao_msg) THEN
           RETURN FALSE
        END IF
     END IF

  END FOREACH

  FREE cq_msg_retorno

  RETURN TRUE

 END FUNCTION


#--------------------------------------------------------#
 FUNCTION vdpy247_reordena_itens_nfe(l_empresa,
                                     l_tipo_nota,
                                     l_serie_nota,
                                     l_transacao_nfe,
                                     l_modo_exibicao_msg)
#--------------------------------------------------------#
  DEFINE l_empresa             LIKE empresa.cod_empresa,
         l_tipo_nota           CHAR(8),
         l_serie_nota          LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg   SMALLINT,
         l_transacao_nfe       INTEGER,
         l_nitem               DECIMAL(3,0),
         l_nitem_ant           DECIMAL(3,0)

  WHENEVER ERROR CONTINUE
    UPDATE t_prod_serv
       SET nitem = nitem + 500
     WHERE transacao_nfe = l_transacao_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("UPDATE", "t_prod_serv", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE t_trib_ben
       SET nitem = nitem + 500
     WHERE transacao_nfe = l_transacao_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("UPDATE", "t_trib_ben", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
    UPDATE t_adic_pro
       SET nitem = nitem + 500
     WHERE transacao_nfe = l_transacao_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("UPDATE", "t_trib_ben", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  LET l_nitem = 0

  WHENEVER ERROR CONTINUE
   DECLARE cq_itens_reordena CURSOR FOR
    SELECT nitem
      FROM t_prod_serv
     WHERE transacao_nfe = l_transacao_nfe
     ORDER BY cprod
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DEFINE", "cq_itens", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_itens_reordena INTO l_nitem_ant
  WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_itens", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     LET l_nitem = l_nitem + 1

     WHENEVER ERROR CONTINUE
       UPDATE t_prod_serv
          SET nitem = l_nitem
        WHERE transacao_nfe = l_transacao_nfe
          AND nitem         = l_nitem_ant
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("UPDATE", "t_prod_serv", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE t_trib_ben
          SET nitem = l_nitem
        WHERE transacao_nfe = l_transacao_nfe
          AND nitem         = l_nitem_ant
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("UPDATE", "t_trib_ben", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       UPDATE t_adic_pro
          SET nitem = l_nitem
        WHERE transacao_nfe = l_transacao_nfe
          AND nitem         = l_nitem_ant
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("UPDATE", "t_trib_ben", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

  END FOREACH

  FREE cq_itens_reordena

  RETURN TRUE

 END FUNCTION

#--------------------------------------------------------------#
 FUNCTION vdpy247_cria_temp_t_ped_cli_item(l_modo_exibicao_msg)
#--------------------------------------------------------------#

  DEFINE l_modo_exibicao_msg SMALLINT

  WHENEVER ERROR CONTINUE
    CREATE TEMP TABLE t_ped_cli_item
    (
       transacao_nfe  INTEGER       NOT NULL,
       nitem          DECIMAL(3,0)  NOT NULL,
       num_pedido_cli CHAR(25)      NOT NULL
    )WITH NO LOG;
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     IF log0030_err_sql_tabela_duplicada() THEN
        WHENEVER ERROR CONTINUE
          DELETE FROM t_ped_cli_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("DELETE", "t_ped_cli_item", l_modo_exibicao_msg)
           RETURN FALSE
        END IF
     ELSE
        CALL log0030_processa_err_sql("CREATE TEMP", "t_ped_cli_item", l_modo_exibicao_msg)
        RETURN FALSE
     END IF
  ELSE
     WHENEVER ERROR CONTINUE
       CREATE UNIQUE INDEX ix_cli_item ON t_ped_cli_item
       (
          transacao_nfe,
          nitem
       );
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("CREATE INDEX", "t_ped_cli_item", l_modo_exibicao_msg)
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

 END FUNCTION

#-----------------------------------------------------------#
 FUNCTION vdpy247_inclui_pedido_cliente(l_empresa,
                                        l_tipo_nota,
                                        l_serie_nota,
                                        l_modo_exibicao_msg)
#-----------------------------------------------------------#
  DEFINE l_empresa           LIKE empresa.cod_empresa,
         l_tipo_nota         CHAR(8),
         l_serie_nota        LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg SMALLINT

  DEFINE l_transacao_nfe     INTEGER,
         l_nitem             DECIMAL(3,0),
         l_prod              CHAR(120),
         l_pedido            DECIMAL(6,0)

  DEFINE l_num_pedido_cli    CHAR(25),
         l_den_item          CHAR(120),
         l_ind               SMALLINT

  WHENEVER ERROR CONTINUE
   DECLARE cq_pedido_cli CURSOR FOR
    SELECT transacao_nfe,
           nitem,
           prod,
           pedido
      FROM t_prod_serv
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_pedido_cli", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_pedido_cli INTO l_transacao_nfe,
                              l_nitem,
                              l_prod,
                              l_pedido
  WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_pedido_cli", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     LET l_num_pedido_cli = " "
     LET l_den_item       = " "

     IF l_pedido > 0 THEN
        WHENEVER ERROR CONTINUE
          SELECT num_pedido_cli
            INTO l_num_pedido_cli
            FROM pedidos
           WHERE cod_empresa = l_empresa
             AND num_pedido  = l_pedido
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("SELECT", "pedidos", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        IF  l_num_pedido_cli IS NOT NULL
        AND l_num_pedido_cli <> " " THEN
           FOR l_ind = 1 TO 25
              IF l_num_pedido_cli[l_ind] = "-" THEN
                 LET l_num_pedido_cli = l_num_pedido_cli[1,l_ind-1]
                 EXIT FOR
              END IF
           END FOR

           LET l_den_item = l_num_pedido_cli CLIPPED, " - ", l_prod

           WHENEVER ERROR CONTINUE
             UPDATE t_prod_serv
                SET prod = l_den_item
              WHERE transacao_nfe = l_transacao_nfe
                AND nitem         = l_nitem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_processa_err_sql("UPDATE", "t_prod_serv", l_modo_exibicao_msg)
              RETURN FALSE
           END IF
        END IF
     END IF

     IF l_num_pedido_cli IS NULL THEN
        LET l_num_pedido_cli = " "
     END IF

     WHENEVER ERROR CONTINUE
       INSERT INTO t_ped_cli_item(transacao_nfe,
                                  nitem,
                                  num_pedido_cli) VALUES (l_transacao_nfe,
                                                          l_nitem,
                                                          l_num_pedido_cli)
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("INSERT", "t_ped_cli_item", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

  END FOREACH

  FREE cq_pedido_cli

  RETURN TRUE

 END FUNCTION

#------------------------------------------------------#
 FUNCTION vdpy247_agrupa_itens_nfe(l_empresa,
                                   l_tipo_nota,
                                   l_serie_nota,
                                   l_transacao_nfe,
                                   l_modo_exibicao_msg)
#------------------------------------------------------#

  DEFINE l_empresa             LIKE empresa.cod_empresa,
         l_tipo_nota           CHAR(8),
         l_serie_nota          LIKE fat_nf_mestre.serie_nota_fiscal,
         l_modo_exibicao_msg   SMALLINT,
         l_transacao_nfe       INTEGER

  DEFINE l_cprod               CHAR(60),
         l_prod                CHAR(120),
         l_nitem               DECIMAL(3,0),
         l_imposto             CHAR(20),
         l_Aliquota            DECIMAL(5,2),
         l_sum_qtrib           DECIMAL(12,4),
         l_sum_vprod           DECIMAL(15,2),
         l_sum_Valor           DECIMAL(15,2),
         l_sum_VBC             DECIMAL(15,2),
         l_vUnCom              DECIMAL(15,2),
         l_ncm                 CHAR(08),
         l_cfop                CHAR(04),
         l_utrib               CHAR(06),
         l_vUnTrib             DECIMAL(17,6)

  DEFINE l_num_pedido_cli      CHAR(25)

  WHENEVER ERROR CONTINUE
   DECLARE cq_itens CURSOR FOR
    SELECT DISTINCT cprod
      FROM t_prod_serv
     WHERE transacao_nfe = l_transacao_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DEFINE", "cq_itens", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_itens INTO l_cprod
  WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_itens", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
     DROP TABLE t_agrup_item
     CREATE TEMP TABLE t_agrup_item (nitem INTEGER, imposto CHAR(20)) WITH NO LOG
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("create", "t_agrup_item", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     # agrupa os itens com mesmo imposto, valor e alíquota
     WHENEVER ERROR CONTINUE
      DECLARE cq_agrupamento CURSOR FOR
       SELECT t_trib_ben.transacao_nfe,
              t_prod_serv.cprod,
              t_prod_serv.prod,
              t_trib_ben.imposto,
              t_trib_ben.Aliquota,
              t_prod_serv.ncm,
              t_prod_serv.cfop,
              t_prod_serv.utrib,
              t_prod_serv.vUnTrib,
              t_ped_cli_item.num_pedido_cli,
              SUM(t_prod_serv.qtrib),
              SUM(t_prod_serv.vprod),
              SUM(t_trib_ben.Valor),
              SUM(t_trib_ben.VBC)
         FROM t_trib_ben , t_prod_serv, t_ped_cli_item
        WHERE t_trib_ben.transacao_nfe     = l_transacao_nfe
          AND t_trib_ben.transacao_nfe     = t_prod_serv.transacao_nfe
          AND t_prod_serv.cprod            = l_cprod
          AND t_prod_serv.nitem            = t_trib_ben.nitem
          AND t_ped_cli_item.transacao_nfe = l_transacao_nfe
          AND t_ped_cli_item.nitem         = t_prod_serv.nitem
     GROUP BY t_trib_ben.transacao_nfe,
              t_prod_serv.cprod,
              t_prod_serv.prod,
              t_trib_ben.imposto,
              t_trib_ben.Aliquota,
              t_prod_serv.ncm,
              t_prod_serv.cfop,
              t_prod_serv.utrib,
              t_prod_serv.vUnTrib,
              t_ped_cli_item.num_pedido_cli
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("SELECT", "cq_agrupamento", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_agrupamento INTO l_transacao_nfe,
                                  l_cprod,
                                  l_prod,
                                  l_imposto,
                                  l_Aliquota,
                                  l_ncm,
                                  l_cfop,
                                  l_utrib,
                                  l_vUnTrib,
                                  l_num_pedido_cli,
                                  l_sum_qtrib,
                                  l_sum_vprod,
                                  l_sum_Valor,
                                  l_sum_VBC
     WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("SELECT", "cq_agrupamento", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
         DECLARE cq_item CURSOR FOR
          SELECT nitem
            FROM t_prod_serv
           WHERE cprod          = l_cprod
             AND transacao_nfe  = l_transacao_nfe
             AND ncm            = l_ncm
             AND cfop           = l_cfop
             AND utrib          = l_utrib
             AND vUnTrib        = l_vUnTrib
             AND prod           = l_prod
             AND nitem NOT IN (SELECT nitem
                                 FROM t_agrup_item
                                WHERE t_agrup_item.imposto = l_imposto)
           ORDER BY nitem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("select", "cq_item", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        OPEN cq_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("open", "cq_item", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        FETCH cq_item INTO l_nitem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           IF sqlca.sqlcode = NOTFOUND THEN
              CLOSE cq_item
              FREE cq_item
              CONTINUE FOREACH
           ELSE
              CALL log0030_processa_err_sql("fetch", "cq_item", l_modo_exibicao_msg)
              RETURN FALSE
           END IF
        END IF

        WHENEVER ERROR CONTINUE
          INSERT INTO t_agrup_item (nitem , imposto) VALUES (l_nitem,l_imposto )
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("insert", "t_agrup_item", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        #agrupa os valores do mesmo produto na t_prod_serv para o primeiro item (l_nitem)
        WHENEVER ERROR CONTINUE
          UPDATE t_prod_serv
             SET qtrib = l_sum_qtrib,
                 vprod = l_sum_vprod,
                 qcom  = l_sum_qtrib
           WHERE transacao_nfe = l_transacao_nfe
             AND cprod         = l_cprod
             AND nitem         = l_nitem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("update", "t_prod_serv", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
          UPDATE t_trib_ben
             SET Valor = l_sum_Valor,
                 VBC   = l_sum_VBC
           WHERE transacao_nfe = l_transacao_nfe
             AND nitem         = l_nitem
             AND imposto       = l_imposto
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("update", "t_trib_ben", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        #deleta os outros registros da t_prod_serv e t_trib_ben
        WHENEVER ERROR CONTINUE
        FETCH cq_item INTO l_nitem
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
           CALL log0030_processa_err_sql("FETCH", "cq_item", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHILE sqlca.sqlcode = 0

           #exclui da t_trib_ben deixando somente uma vez cada item (exclui as demais sequancias do item para o imposto)
           WHENEVER ERROR CONTINUE
             DELETE
               FROM t_trib_ben
              WHERE transacao_nfe   = l_transacao_nfe
                AND nitem           = l_nitem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_processa_err_sql("delete", "t_trib_ben", l_modo_exibicao_msg)
              RETURN FALSE
           END IF

           #exclui as demais sequancias do item (o primeiro item agrupou os valores dos demais)
           WHENEVER ERROR CONTINUE
             DELETE
               FROM t_prod_serv
              WHERE transacao_nfe = l_transacao_nfe
                AND cprod         = l_cprod
                AND nitem         = l_nitem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_processa_err_sql("delete", "t_prod_serv", l_modo_exibicao_msg)
              RETURN FALSE
           END IF

           WHENEVER ERROR CONTINUE
           FETCH cq_item INTO l_nitem
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
              CALL log0030_processa_err_sql("FETCH", "cq_item", l_modo_exibicao_msg)
              RETURN FALSE
           END IF
        END WHILE

        CLOSE cq_item
        FREE cq_item

     END FOREACH

  END FOREACH

  FREE cq_itens

  WHENEVER ERROR CONTINUE
  DROP TABLE t_agrup_item
  WHENEVER ERROR STOP

  RETURN TRUE

 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdpy247_atualiza_prod(l_empresa, l_tipo_nota, l_serie_nota,
                                l_modo_exibicao_msg)
#---------------------------------------------------------------------#
{USO INTERNO

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
         l_modo_exibicao_msg  SMALLINT

  DEFINE l_num_nff            LIKE fat_nf_mestre.nota_fiscal,
         l_transacao_nfe      INTEGER,
         l_nitem              DECIMAL(3,0),
         l_cprod              CHAR(60),
         l_ucom               CHAR(06),
         l_utrib              CHAR(06),
         l_qcom               DECIMAL(12,4),
         l_qtrib              DECIMAL(12,4),
         l_vUnCom             DECIMAL(17,6),
         l_vUnTrib            DECIMAL(17,6)

  DEFINE l_cod_item_cliente   LIKE cliente_item.cod_item_cliente,
         l_tex_complementar   LIKE cliente_item.tex_complementar,
         l_cliente            LIKE fat_nf_mestre.cliente

  DEFINE l_qtd_volumes        LIKE fat_nf_embalagem.qtd_volume,
         l_Qvol               DECIMAL(15,0)

  DEFINE l_fat_conver         LIKE ctr_unid_med.fat_conver,
         l_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
         l_num_pedido_cliente LIKE pedidos.num_pedido_cli,
         l_pedido             LIKE pedidos.num_pedido,
         l_prod               CHAR(120)

  WHENEVER ERROR CONTINUE
   DECLARE cq_info_item CURSOR FOR
    SELECT transacao_nfe,
           nNF
      FROM t_ident_nfe
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_info_item", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_info_item INTO l_transacao_nfe,
                             l_num_nff

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_info_item", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     LET l_qtd_volumes = 0

     WHENEVER ERROR CONTINUE
       SELECT cliente
         INTO l_cliente
         FROM fat_nf_mestre
        WHERE empresa           = l_empresa
          AND trans_nota_fiscal = l_transacao_nfe
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("SELECT", "fat_nf_mestre vdpy247", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       SELECT SUM(qtd_volume)
         INTO l_qtd_volumes
         FROM fat_nf_embalagem
        WHERE empresa           = l_empresa
          AND trans_nota_fiscal = l_transacao_nfe
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("SELECT", "fat_nf_embalagem", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     IF NOT vdpy247_grava_msg_retorno(l_empresa,
                                      l_tipo_nota,
                                      l_serie_nota,
                                      l_transacao_nfe,
                                      l_num_nff,
                                      l_modo_exibicao_msg) THEN
        RETURN FALSE
     END IF

     LET l_Qvol = 0

     WHENEVER ERROR CONTINUE
       SELECT SUM(Qvol)
         INTO l_Qvol
         FROM t_volumes
        WHERE transacao_nfe = l_transacao_nfe
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("SELECT", "t_volumes", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     IF l_Qvol IS NULL
     OR l_Qvol <= 0 THEN
        WHENEVER ERROR CONTINUE
          SELECT SUM(qtrib)
            INTO l_Qvol
            FROM t_prod_serv
           WHERE transacao_nfe = l_transacao_nfe
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("SELECT", "t_prod_serv", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        IF  l_Qvol IS NOT NULL
        AND l_Qvol > 0 THEN
           WHENEVER ERROR CONTINUE
             UPDATE t_volumes
                SET Qvol = l_Qvol
              WHERE transacao_nfe = l_transacao_nfe
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log0030_processa_err_sql("UPDATE", "t_volumes", l_modo_exibicao_msg)
              RETURN FALSE
           END IF
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
          UPDATE t_volumes
             SET Qvol = l_qtd_volumes
           WHERE transacao_nfe = l_transacao_nfe
        WHENEVER ERROR STOP

        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("UPDATE", "t_volumes", l_modo_exibicao_msg)
           RETURN FALSE
        END IF
     END IF


     WHENEVER ERROR CONTINUE
      DECLARE cq_itens_danfe CURSOR FOR
       SELECT nitem,
              cprod,
              ucom,
              utrib,
              qcom,
              qtrib,
              vUnCom,
              vUnTrib,
              pedido,
              prod
         FROM t_prod_serv
        WHERE transacao_nfe = l_transacao_nfe
     WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_itens_danfe", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_itens_danfe INTO l_nitem,
                                  l_cprod,
                                  l_ucom,
                                  l_utrib,
                                  l_qcom,
                                  l_qtrib,
                                  l_vUnCom,
                                  l_vUnTrib,
                                  l_pedido,
                                  l_prod
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR", "cq_itens_danfe", l_modo_exibicao_msg)
        RETURN FALSE
     END IF

           INITIALIZE l_cod_item_cliente TO NULL

           WHENEVER ERROR CONTINUE
             SELECT cod_item_cliente,
                    tex_complementar
               INTO l_cod_item_cliente,
                    l_tex_complementar
               FROM cliente_item
              WHERE cod_empresa        = l_empresa
                AND cod_cliente_matriz = l_cliente
                AND cod_item           = l_cprod
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log0030_processa_err_sql("SELECT", "CLIENTE_ITEM", l_modo_exibicao_msg)
             RETURN FALSE
           END IF

           IF l_cod_item_cliente IS NOT NULL AND l_cod_item_cliente <> " " THEN

              WHENEVER ERROR CONTINUE
                UPDATE t_prod_serv
                   SET cprod = l_cod_item_cliente
                 WHERE transacao_nfe  = l_transacao_nfe
                   AND nitem          = l_nitem
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 CALL log0030_processa_err_sql("UPDATE", "T_PROD_SERV", l_modo_exibicao_msg)
                 RETURN FALSE
              END IF

              #IF vdpr125_t_prod_serv_leitura(l_transacao_nfe, l_nitem, l_modo_exibicao_msg) THEN
              #
              #   CALL vdpr125_t_prod_serv_set_cprod(l_cod_item_cliente)
              #   CALL vdpr125_t_prod_serv_set_prod(l_tex_complementar)
              #
              #   IF NOT vdpr125_t_prod_serv_modifica(l_modo_exibicao_msg) THEN
              #      RETURN FALSE
              #   END IF
              #END IF

           ELSE
              IF l_num_pedido_cliente IS NOT NULL AND l_num_pedido_cliente <> 0 THEN
                 LET l_prod = l_num_pedido_cliente USING "<<<<<<", " ", l_prod
                 WHENEVER ERROR CONTINUE
                   UPDATE t_prod_serv
                      SET prod = l_prod
                    WHERE transacao_nfe  = l_transacao_nfe
                      AND nitem          = l_nitem
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                    CALL log0030_processa_err_sql("UPDATE", "T_PROD_SERV", l_modo_exibicao_msg)
                    RETURN FALSE
                 END IF
              END IF
           END IF

      WHENEVER ERROR CONTINUE
      END FOREACH
      WHENEVER ERROR STOP

      FREE cq_itens_danfe

  WHENEVER ERROR CONTINUE
  END FOREACH
  WHENEVER ERROR STOP

  FREE cq_info_item

  RETURN TRUE

END FUNCTION


#----------------------------------------------------#
 FUNCTION vdpy247_texto_adicional_reajuste(l_empresa, l_transacao_nfe, l_modo_exibicao_msg)
#----------------------------------------------------#
  DEFINE l_empresa               LIKE empresa.cod_empresa,
         l_transacao_nfe         INTEGER,
         l_houve_erro            SMALLINT,
         l_sql_stmt              CHAR(500),
         l_seq_item_nf           LIKE fat_nf_reaj_preco.seq_item_nf,
         l_trans_nf_mestre       LIKE fat_nf_reaj_preco.trans_nota_fiscal,
         l_trans_nf_mestre_ant   LIKE fat_nf_reaj_preco.trans_nota_fiscal,
         l_qtd_item_orig         LIKE fat_nf_item.qtd_item,
         l_num_nff2              LIKE dev_mestre.num_nff,
         l_qtd_item_dev          LIKE dev_item.qtd_item,
         l_qtd_item              LIKE dev_item.qtd_item,
         l_des_texto             CHAR(300),
         l_cod_cliente           LIKE fat_nf_mestre.cliente,
         l_modo_exibicao_msg     SMALLINT,
         l_pedido_ant            LIKE pedidos.num_pedido,
         l_num_pedido_cli        LIKE pedidos.num_pedido_cli,
         l_den_item              CHAR(120),
         l_ind                   SMALLINT,
         l_num_seq_reaj_comp     LIKE nf_reaj_comp_pre.num_seq_reaj_comp,
         l_cod_item              LIKE fat_nf_item.item,
         l_nota_fiscal           LIKE fat_nf_mestre.nota_fiscal,
         l_serie_nf              LIKE fat_nf_mestre.serie_nota_fiscal,
         l_num_ped_item          LIKE fat_nf_item.pedido

  LET l_pedido_ant = 0
  LET l_trans_nf_mestre_ant = 0
  WHENEVER ERROR CONTINUE
    DELETE
      FROM t_info_adic
     WHERE transacao_nfe = l_transacao_nfe
       AND tipo_texto    = "TEXTO_REAJUSTE"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DELETE", "T_INFO_ADIC", l_modo_exibicao_msg)
     RETURN FALSE
  END IF


  LET l_sql_stmt = " SELECT seq_item_nf, ",
                    "       pedido       ",
                    "  FROM fat_nf_item  ",
                    " WHERE empresa           = '", l_empresa CLIPPED, "'",
                    "   AND trans_nota_fiscal = ? "

  WHENEVER ERROR CONTINUE
  PREPARE var_query_item FROM l_sql_stmt
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("PREPARE SQL","var_query_item", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
  DECLARE cq_fat_nf_item CURSOR FOR var_query_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_fat_nf_item", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  FREE var_query_item

  WHENEVER ERROR CONTINUE
   DECLARE cq_wfat_compl CURSOR FOR
    SELECT UNIQUE trans_nota_fiscal
      FROM fat_nf_reaj_preco
     WHERE empresa           = l_empresa
       AND trans_nf_reaj_pre = l_transacao_nfe
  ORDER BY trans_nota_fiscal
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "CQ_WFAT_COMPL", l_modo_exibicao_msg)
     RETURN FALSE
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_wfat_compl  INTO l_trans_nf_mestre
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("FOREACH CURSOR", "CQ_WFAT_COMPL", l_modo_exibicao_msg)
     EXIT FOREACH
  END IF

     IF l_trans_nf_mestre <> l_trans_nf_mestre_ant THEN
        WHENEVER ERROR CONTINUE
          SELECT cliente,
                 nota_fiscal,
                 serie_nota_fiscal
            INTO l_cod_cliente,
                 l_nota_fiscal,
                 l_serie_nf
            FROM fat_nf_mestre
           WHERE empresa           = l_empresa
             AND trans_nota_fiscal = l_trans_nf_mestre
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
           CALL log0030_processa_err_sql("SELECT", "FAT_NF_MESTRE", l_modo_exibicao_msg)
           RETURN FALSE
        END IF

        WHENEVER ERROR CONTINUE
        FOREACH cq_fat_nf_item USING l_trans_nf_mestre INTO l_seq_item_nf,
                                                            l_num_ped_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("FOREACH CURSOR","cq_fat_nf_item", l_modo_exibicao_msg)
           LET l_houve_erro = TRUE
           EXIT FOREACH
        END IF

           WHENEVER ERROR CONTINUE
           SELECT seq_item_reaj_pre
             INTO l_num_seq_reaj_comp
             FROM fat_nf_reaj_preco
            WHERE empresa           = l_empresa
              AND trans_nota_fiscal = l_trans_nf_mestre
              AND seq_item_nf       = l_seq_item_nf
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              IF sqlca.sqlcode <> 100 THEN
                 CALL log0030_processa_err_sql("SELECT","fat_nf_reaj_preco", l_modo_exibicao_msg)
                 LET l_houve_erro = TRUE
                 EXIT FOREACH
              END IF

              CONTINUE FOREACH
           END IF

           IF l_trans_nf_mestre <> l_trans_nf_mestre_ant THEN

              LET l_qtd_item_orig = 0
              WHENEVER ERROR CONTINUE
              SELECT SUM(qtd_item)
                INTO l_qtd_item_orig
                FROM fat_nf_item
               WHERE empresa           = l_empresa
                 AND trans_nota_fiscal = l_trans_nf_mestre
                 AND pedido            = l_num_ped_item
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                 CALL log0030_processa_err_sql("SELECT", "WFAT_ITEM", l_modo_exibicao_msg)
                 LET l_houve_erro = TRUE
                 EXIT FOREACH
              END IF

              LET l_qtd_item_dev = 0
              WHENEVER ERROR CONTINUE
                SELECT UNIQUE num_nff
                  INTO l_num_nff2
                  FROM dev_mestre
                 WHERE cod_empresa    = l_empresa
                   AND cod_cliente    = l_cod_cliente
                   AND num_nff_origem = l_nota_fiscal
             WHENEVER ERROR STOP
             IF sqlca.sqlcode = 0 THEN
                WHENEVER ERROR CONTINUE
                SELECT SUM(qtd_item)
                  INTO l_qtd_item_dev
                  FROM sup_nf_devol_cli
                 WHERE empresa            = l_empresa
                   AND aviso_recebto      = l_num_nff2
                   AND nota_fiscal_fatura = l_nota_fiscal
                   AND ped_nf_fatura      = l_num_ped_item
                WHENEVER ERROR STOP
                IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                   CALL log0030_processa_err_sql("SELECT", "SUP_NF_DEVOL_CLI", l_modo_exibicao_msg)
                END IF

                IF l_qtd_item_dev IS NULL THEN
                   LET l_qtd_item_dev = 0
                END IF
             END IF

             LET l_qtd_item = l_qtd_item_orig - l_qtd_item_dev
             LET l_des_texto = '*CONF NF ',l_nota_fiscal USING '&&&&&&&&&&', ' QTDE = ', l_qtd_item USING '<<<<#&'

             CALL vdpy247_insere_t_info_adic(l_transacao_nfe,"TEXTO_REAJUSTE", l_des_texto, l_modo_exibicao_msg)
           END IF

           IF l_pedido_ant <> l_num_ped_item AND l_num_ped_item <> 0 THEN
              WHENEVER ERROR CONTINUE
                SELECT item
                  INTO l_cod_item
                  FROM fat_nf_item
                 WHERE empresa           = l_empresa
                   AND trans_nota_fiscal = l_trans_nf_mestre
                   AND seq_item_nf       = l_seq_item_nf
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                 CALL log0030_processa_err_sql("SELECT", "fat_nf_item", l_modo_exibicao_msg)
                 LET l_houve_erro = TRUE
                 EXIT FOREACH
              END IF

              WHENEVER ERROR CONTINUE
                SELECT num_pedido_cli
                  INTO l_num_pedido_cli
                  FROM pedidos
                 WHERE cod_empresa = l_empresa
                   AND num_pedido  = l_num_ped_item
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                 CALL log0030_processa_err_sql("SELECT", "PEDIDOS", l_modo_exibicao_msg)
                 LET l_houve_erro = TRUE
                 EXIT FOREACH
              END IF

              IF l_num_pedido_cli IS NOT NULL
              AND l_num_pedido_cli <> " " THEN
                  FOR l_ind = 1 TO 25
                     IF l_num_pedido_cli[l_ind] = "-" THEN
                        LET l_num_pedido_cli = l_num_pedido_cli[1,l_ind-1]
                        EXIT FOR
                     END IF
                  END FOR

                  WHENEVER ERROR CONTINUE
                    SELECT UNIQUE prod
                      INTO l_den_item
                      FROM t_prod_serv
                     WHERE transacao_nfe = l_transacao_nfe
                       AND cprod         = l_cod_item
                       AND nitem         = l_num_seq_reaj_comp
                  WHENEVER ERROR STOP
                  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                     CALL log0030_processa_err_sql("SELECT", "T_PROD_SERV", l_modo_exibicao_msg)
                     LET l_houve_erro = TRUE
                     EXIT FOREACH
                  END IF

                  LET l_den_item = l_num_pedido_cli CLIPPED, " - ", l_den_item

                  WHENEVER ERROR CONTINUE
                    UPDATE t_prod_serv
                       SET prod = l_den_item
                     WHERE transacao_nfe = l_transacao_nfe
                       AND cprod         = l_cod_item
                       AND nitem         = l_num_seq_reaj_comp
                  WHENEVER ERROR STOP

                  IF sqlca.sqlcode <> 0 THEN
                     CALL log0030_processa_err_sql("UPDATE", "t_prod_serv", l_modo_exibicao_msg)
                     RETURN FALSE
                  END IF
              END IF
           END IF
           LET l_pedido_ant = l_num_ped_item
           LET l_trans_nf_mestre_ant = l_trans_nf_mestre
        END FOREACH

        IF l_houve_erro THEN
           EXIT FOREACH
        END IF
     END IF

  END FOREACH
  FREE cq_wfat_compl
  FREE cq_fat_nf_item

  IF l_houve_erro THEN
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#----------------------------------------------------#
 FUNCTION vdpy247_insere_t_info_adic(l_transacao_nfe, l_tipo_texto, l_mensagem, l_modo_exibicao_msg)
#----------------------------------------------------#
  DEFINE l_transacao_nfe     INTEGER,
         l_tipo_texto        CHAR(40),
         l_mensagem          CHAR(2000),
         l_modo_exibicao_msg SMALLINT

  #
  # 0. Inicializando as variáveis
  #

    CALL vdpr138_t_info_adic_set_null()

  #
  # 1. Grava o número da transação da NFE (Chave unica NFE)
  #

  #
  # Gravando a transação da NFE
  #
    CALL vdpr138_t_info_adic_set_transacao_nfe(l_transacao_nfe)

  #
  # 2. TAG Z0 - Grava as informações adicionais
  #

    LET m_ordem_impressao = m_ordem_impressao + 1

  #
  # Se houver necessidade de ordenacao, devera ser tratado via EPL
  #
    CALL vdpr138_t_info_adic_set_ordem(m_ordem_impressao)

  #
  # Define o local de impressao ( X-XML, D-DANFE, A-AMBOS )
  #
    CALL vdpr138_t_info_adic_set_local_impr("A")

  #
  # Define o local de impressao na DANFE (CORPO, INFO_ADIC)
  #
    CALL vdpr138_t_info_adic_set_local_impr_danfe("CORPO")

  #
  # Define um nome para as informações adicionais
  #
    CALL vdpr138_t_info_adic_set_tipo_texto(l_tipo_texto)

  #
  # Busca o texto que devera ser impresso
  #
    CALL vdpr138_t_info_adic_set_Cpl(l_mensagem)

  #
  # 3. Inclui nas tabelas temporárias
  #

    IF NOT vdpr138_t_info_adic_inclui(l_modo_exibicao_msg) THEN
       RETURN FALSE
    END IF

 END FUNCTION

#------------------------------------------------------------------------------------#
 FUNCTION vdpy247_ajusta_msg_trib_ipi(l_empresa, l_transacao_nfe, l_modo_exibicao_msg)
#------------------------------------------------------------------------------------#
  DEFINE l_empresa           LIKE empresa.cod_empresa,
         l_transacao_nfe     INTEGER,
         l_modo_exibicao_msg SMALLINT,
         l_seq_item_nf       INTEGER,
         l_des_texto         CHAR(300),
         l_sequencia_texto   INTEGER,
         l_texto             CHAR(2000),
         l_hist_fiscal       LIKE fat_nf_item_fisc.hist_fiscal,
         l_ordem             INTEGER

  WHENEVER ERROR CONTINUE
    SELECT UNIQUE(empresa)
      FROM fat_nf_item_fisc
     WHERE empresa           = l_empresa
       AND trans_nota_fiscal = l_transacao_nfe
       AND tributo_benef     = 'IPI'
       AND tributacao        = 55
  GROUP BY empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 100 THEN
     RETURN TRUE
  END IF

  WHENEVER ERROR CONTINUE
    DELETE
      FROM t_info_adic
     WHERE transacao_nfe = l_transacao_nfe
       AND tipo_texto    = 'FISCAL'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DELETE","t_info_adic", l_modo_exibicao_msg)
  END IF

  WHENEVER ERROR CONTINUE
   DECLARE cq_fat_nf_texto_hist CURSOR FOR
    SELECT des_texto,
           sequencia_texto
      FROM fat_nf_texto_hist
     WHERE empresa           = l_empresa
       AND trans_nota_fiscal = l_transacao_nfe
       AND texto NOT IN (SELECT DISTINCT hist_fiscal
                           FROM fat_nf_item_fisc
                          WHERE empresa           = l_empresa
                            AND trans_nota_fiscal = l_transacao_nfe
                            AND tributo_benef IN ('PIS_REC_ZF','COFINS_REC_ZF','ICMS_ZF','ICMS_DESC_ESP','PIS_ST','COFINS_ST','CSLL_RET', 'PIS_RET', 'COFINS_RET', 'IRRF_RET','IPI')
                            AND hist_fiscal IS NOT NULL)
       AND fat_nf_texto_hist.tip_txt_nf = '2'
     UNION
    SELECT des_texto,
           sequencia_texto
      FROM fat_nf_texto_hist
     WHERE empresa           = l_empresa
       AND trans_nota_fiscal = l_transacao_nfe
       AND texto NOT IN (SELECT DISTINCT hist_fiscal
                           FROM fat_nf_item_fisc
                          WHERE empresa           = l_empresa
                            AND trans_nota_fiscal = l_transacao_nfe
                            AND tributo_benef     = 'IPI'
                            AND tributacao        = 55
                            AND hist_fiscal IS NOT NULL)
       AND fat_nf_texto_hist.tip_txt_nf = '2'
     UNION
    SELECT des_texto,
           sequencia_texto
      FROM fat_nf_texto_hist
     WHERE empresa           = l_empresa
       AND trans_nota_fiscal = l_transacao_nfe
       AND fat_nf_texto_hist.tip_txt_nf <> '2'
  ORDER BY sequencia_texto
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_fat_nf_texto_hist", l_modo_exibicao_msg)
     RETURN FALSE
  END IF
  WHENEVER ERROR CONTINUE
   FOREACH cq_fat_nf_texto_hist INTO l_des_texto, l_sequencia_texto
  WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR","cq_fat_nf_texto_hist", l_modo_exibicao_msg)
        EXIT FOREACH
     END IF

     IF  l_des_texto IS NOT NULL
     AND l_des_texto <> " " THEN
         IF NOT vdpy247_insere_t_info_adic(l_transacao_nfe, "FISCAL", l_des_texto, l_modo_exibicao_msg) THEN
            RETURN FALSE
         END IF
     END IF

  WHENEVER ERROR CONTINUE
  END FOREACH
  FREE cq_fat_nf_texto_hist
  WHENEVER ERROR STOP

  INITIALIZE l_seq_item_nf,
             l_des_texto TO NULL
  WHENEVER ERROR CONTINUE
   DECLARE cq_fat_nf_item_fisc_2 CURSOR FOR
    SELECT DISTINCT hist_fiscal,
           seq_item_nf
      FROM fat_nf_item_fisc
     WHERE empresa           = l_empresa
       AND trans_nota_fiscal = l_transacao_nfe
       AND tributo_benef     = 'IPI'
       AND tributacao        = 55
       AND hist_fiscal IS NOT NULL
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_fat_nf_item_fisc_2", l_modo_exibicao_msg)
     RETURN FALSE
  END IF
  WHENEVER ERROR CONTINUE
   FOREACH cq_fat_nf_item_fisc_2 INTO l_hist_fiscal, l_seq_item_nf
  WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("FOREACH CURSOR","cq_fat_nf_item_fisc_2", l_modo_exibicao_msg)
        EXIT FOREACH
     END IF

     WHENEVER ERROR CONTINUE
       SELECT MAX(ordem)
         INTO l_ordem
         FROM t_adic_pro
        WHERE transacao_nfe = l_transacao_nfe
          AND nitem         = l_seq_item_nf
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql('SELECT','t_adic_pro',l_modo_exibicao_msg)
        RETURN FALSE
     END IF
     IF l_ordem IS NULL THEN
        LET l_ordem = 0
     END IF

     INITIALIZE l_texto TO NULL
     WHENEVER ERROR CONTINUE
      DECLARE cq_fat_nf_texto_hist_2 CURSOR FOR
       SELECT des_texto
         FROM fat_nf_texto_hist
        WHERE empresa           = l_empresa
          AND trans_nota_fiscal = l_transacao_nfe
          AND texto             = l_hist_fiscal
        ORDER BY sequencia_texto ASC
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log0030_processa_err_sql("DECLARE CURSOR", "cq_fat_nf_texto_hist_2", l_modo_exibicao_msg)
        RETURN FALSE
     END IF
     WHENEVER ERROR CONTINUE
      FOREACH cq_fat_nf_texto_hist_2 INTO l_des_texto
     WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log0030_processa_err_sql("FOREACH CURSOR","cq_fat_nf_texto_hist_2", l_modo_exibicao_msg)
           EXIT FOREACH
        END IF

        IF l_texto IS NOT NULL AND l_texto <> ' ' THEN
           LET l_texto = l_texto CLIPPED, " ", l_des_texto
        ELSE
           LET l_texto = l_des_texto
        END IF

     WHENEVER ERROR CONTINUE
     END FOREACH
     FREE cq_fat_nf_texto_hist_2
     WHENEVER ERROR STOP

     IF l_texto IS NOT NULL AND l_texto <> ' ' THEN
        CALL vdpr129_t_info_adic_prod_set_null()
        CALL vdpr129_t_info_adic_prod_set_transacao_nfe(l_transacao_nfe)
        CALL vdpr129_t_info_adic_prod_set_nitem(l_seq_item_nf)
        LET l_ordem = l_ordem + 1
        CALL vdpr129_t_info_adic_prod_set_ordem(l_ordem)
        CALL vdpr129_t_info_adic_prod_set_local_impr("A")
        CALL vdpr129_t_info_adic_prod_set_local_impr_danfe("CORPO")
        CALL vdpr129_t_info_adic_prod_set_tipo_texto("ITEM_HIST_TRIB")
        CALL vdpr129_t_info_adic_prod_set_Infadprod(l_texto)
        IF NOT vdpr129_t_info_adic_prod_inclui(l_modo_exibicao_msg) THEN
           RETURN FALSE
        END IF
        INITIALIZE l_texto TO NULL
     END IF

  WHENEVER ERROR CONTINUE
  END FOREACH
  FREE cq_fat_nf_item_fisc_2
  WHENEVER ERROR STOP

  RETURN TRUE

 END FUNCTION

#-------------------------------#
 FUNCTION vdpy247_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/fab_de_maquinas_e_equip_fameq_ltda/vendas/vendas/funcoes/vdpy247.4gl $|$Revision: 15 $|$Date: 08/12/11 11:04 $|$Modtime: 24/11/09 13:46 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION
