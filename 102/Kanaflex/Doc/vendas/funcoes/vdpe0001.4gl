#------------------------------------------------------------------------------#
# SISTEMA.: Regras de negócio logix - vdp                                      #
# OBJETIVO: FUNÇÃO PARA GRAVAR AUDITORIA DA PED_ITENS E TRATAR PARAMETRO       #
#           impedir_alt_qtd_preco_vdp1090                                      #
# Data....: 26/06/2012                                                         #
#------------------------------------------------------------------------------#
DATABASE logix


#------------------------------------------------#
 FUNCTION vdpe0001_grava_auditoria(lr_parametros)
#------------------------------------------------#
  DEFINE lr_parametros RECORD
                         empresa            LIKE ped_itens.cod_empresa,
                         pedido             LIKE ped_itens.num_pedido,
                         seq_item           LIKE ped_itens.num_sequencia,
                         tip_item           CHAR(1),
                         dat_alteracao      DATE,
                         hor_alteracao      CHAR(8),
                         usuario_alt        CHAR(8),
                         item               LIKE ped_itens.cod_item,
                         tip_alteracao      CHAR(1), # I – inclusão / C-cancelamento / A-alteração
                         descricao_motivo   CHAR(500),
                         perc_adic_item     DECIMAL(4,2),
                         preco_unitario     DECIMAL(17,8),
                         qtd_item           DECIMAL(10,3),
                         prazo_entrega      DATE,
                         val_frete_unitario DECIMAL(17,6),
                         val_segr_unitario  DECIMAL(17,6),
                         modo_exibicao_msg  SMALLINT
                       END RECORD

 LET lr_parametros.dat_alteracao = TODAY
 LET lr_parametros.hor_alteracao = CURRENT HOUR TO SECOND

 WHENEVER ERROR CONTINUE
 INSERT INTO vdp_aud_it_ped_444 (empresa,
                                 pedido,
                                 seq_item,
                                 tip_item,
                                 dat_alteracao,
                                 hor_alteracao,
                                 usuario_alt,
                                 item,
                                 tip_alteracao,
                                 descricao_motivo,
                                 perc_adic_item,
                                 preco_unitario,
                                 qtd_item,
                                 prazo_entrega,
                                 val_frete_unitario,
                                 val_segr_unitario)
                         VALUES (lr_parametros.empresa,
                                 lr_parametros.pedido,
                                 lr_parametros.seq_item,
                                 lr_parametros.tip_item,
                                 lr_parametros.dat_alteracao,
                                 lr_parametros.hor_alteracao,
                                 lr_parametros.usuario_alt,
                                 lr_parametros.item,
                                 lr_parametros.tip_alteracao,
                                 lr_parametros.descricao_motivo,
                                 lr_parametros.perc_adic_item,
                                 lr_parametros.preco_unitario,
                                 lr_parametros.qtd_item,
                                 lr_parametros.prazo_entrega,
                                 lr_parametros.val_frete_unitario,
                                 lr_parametros.val_segr_unitario)
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log0030_processa_err_sql("INSERT","vdp_aud_it_ped_444",lr_parametros.modo_exibicao_msg)
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#------------------------------------------------#
 FUNCTION vdpe0001_grava_auditoria_desc(lr_parametros)
#------------------------------------------------#
  DEFINE lr_parametros RECORD
                         empresa            LIKE ped_itens.cod_empresa,
                         pedido             LIKE ped_itens.num_pedido,
                         seq_item           LIKE ped_itens.num_sequencia,
                         dat_alteracao      DATE,
                         hor_alteracao      CHAR(8),
                         usuario_alt        CHAR(8),
                         pct_desc_1         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_2         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_3         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_4         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_5         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_6         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_7         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_8         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_9         LIKE ped_itens_desc.pct_desc_1,
                         pct_desc_10        LIKE ped_itens_desc.pct_desc_1,
                         tip_alteracao      CHAR(1), # I – inclusão / C-cancelamento / A-alteração
                         descricao_motivo   CHAR(500),
                         modo_exibicao_msg  SMALLINT
                       END RECORD

 LET lr_parametros.dat_alteracao = TODAY
 LET lr_parametros.hor_alteracao = CURRENT HOUR TO SECOND

 WHENEVER ERROR CONTINUE
 INSERT INTO vdp_audit_desc_444 (empresa,
                                 pedido,
                                 seq_item,
                                 dat_alteracao,
                                 hor_alteracao,
                                 usuario_alt,
                                 tip_alteracao,
                                 descricao_motivo,
                                 perc_desconto_1,
                                 perc_desconto_2,
                                 perc_desconto_3,
                                 perc_desconto_4,
                                 perc_desconto_5,
                                 perc_desconto_6,
                                 perc_desconto_7,
                                 perc_desconto_8,
                                 perc_desconto_9,
                                 perc_desconto_10)
                         VALUES (lr_parametros.empresa,
                                 lr_parametros.pedido,
                                 lr_parametros.seq_item,
                                 lr_parametros.dat_alteracao,
                                 lr_parametros.hor_alteracao,
                                 lr_parametros.usuario_alt,
                                 lr_parametros.tip_alteracao,
                                 lr_parametros.descricao_motivo,
                                 lr_parametros.pct_desc_1,
                                 lr_parametros.pct_desc_2,
                                 lr_parametros.pct_desc_3,
                                 lr_parametros.pct_desc_4,
                                 lr_parametros.pct_desc_5,
                                 lr_parametros.pct_desc_6,
                                 lr_parametros.pct_desc_7,
                                 lr_parametros.pct_desc_8,
                                 lr_parametros.pct_desc_9,
                                 lr_parametros.pct_desc_10)
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log0030_processa_err_sql("INSERT","vdp_audit_desc_444",lr_parametros.modo_exibicao_msg)
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION vdpe0001_informa_motivo(l_empresa)
#-------------------------------#
  DEFINE l_nom_tela         CHAR(80),
         l_empresa          LIKE empresa.cod_empresa,
         l_descricao_motivo CHAR(500)

  CALL log130_procura_caminho("VDPE0001") RETURNING l_nom_tela

  OPEN WINDOW w_vdpe0001 AT 5,10 WITH FORM l_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  DISPLAY l_empresa TO empresa

  INPUT l_descricao_motivo WITHOUT DEFAULTS FROM descricao_motivo
    AFTER FIELD descricao_motivo
      IF l_descricao_motivo IS NULL THEN
         CALL log0030_mensagem("Obrigatório informar um motivo para a alteração.","exclamation")
         NEXT FIELD descricao_motivo
      END IF

    AFTER INPUT
      IF int_flag = 0 THEN
         IF l_descricao_motivo IS NULL THEN
            CALL log0030_mensagem("Obrigatório informar um motivo para a alteração.","exclamation")
            NEXT FIELD descricao_motivo
         END IF
      END IF
  END INPUT

  CLOSE WINDOW w_vdpe0001

  IF int_flag = 1 THEN
     RETURN NULL, FALSE
  ELSE
    RETURN l_descricao_motivo, TRUE
  END IF

END FUNCTION

#-------------------------------#
FUNCTION vdpe0001_verifica_parametro()
#-------------------------------#
 DEFINE l_empresa   LIKE empresa.cod_empresa,
        l_pedido    LIKE pedidos.num_pedido,
        l_funcao    CHAR(20),
        l_parametro SMALLINT,
        l_status    SMALLINT

 LET l_empresa = LOG_getVar('empresa')
 LET l_pedido  = LOG_getVar('pedido')
 LET l_funcao  = LOG_getVar('funcao')

 CALL LOG_setVar("permite_alterar_qtd",TRUE)
 CALL LOG_setVar("permite_alterar_preco",TRUE)

 IF l_funcao = "INCLUSAO" THEN
    CALL LOG_setVar("retorno_epl",TRUE)
    RETURN
 END IF

 CALL log2250_busca_parametro(l_empresa, "impedir_alt_qtd_preco_vdp1090") RETURNING l_parametro, l_status

 CASE l_parametro
   WHEN 1
      CALL LOG_setVar("permite_alterar_qtd",FALSE)
   WHEN 2
      CALL LOG_setVar("permite_alterar_preco",FALSE)
   WHEN 3
      CALL LOG_setVar("permite_alterar_qtd",FALSE)
      CALL LOG_setVar("permite_alterar_preco",FALSE)
 END CASE

 CALL vdpe0001_busca_ies_preco(l_empresa, l_pedido)

 CALL LOG_setVar("retorno_epl",TRUE)

END FUNCTION

#-------------------------------#
FUNCTION vdpe0001_busca_ies_preco(l_empresa, l_pedido)
#-------------------------------#
 DEFINE l_empresa        LIKE empresa.cod_empresa,
        l_pedido         LIKE pedidos.num_pedido,
        l_ies_preco      LIKE pedidos.ies_preco,
        l_ies_alt_pedido CHAR(01)

  #verifica se preço é firme
  WHENEVER ERROR CONTINUE
  SELECT ies_preco
    INTO l_ies_preco
    FROM pedidos
   WHERE num_pedido  = l_pedido
     AND cod_empresa = l_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_ies_preco = " "
  END IF

  WHENEVER ERROR CONTINUE
  SELECT par_vdp.par_vdp_txt[183,183]
    INTO l_ies_alt_pedido
    FROM par_vdp
   WHERE cod_empresa = l_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0
  OR l_ies_alt_pedido IS NULL THEN
     LET l_ies_alt_pedido = "N"
  END IF

  IF  l_ies_preco = "F"
  AND l_ies_alt_pedido = "S" THEN
     CALL LOG_setVar("permite_alterar_preco",TRUE)
  END IF

END FUNCTION

#-------------------------------#
FUNCTION vdpe0001_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdpe0001.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
END FUNCTION
