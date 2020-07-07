#------------------------------------------------------------------------------#
# SISTEMA.: Regras de negócio logix - vdp                                      #
# OBJETIVO: REGRAS ESPECIFICAS CLIENTE KANAFLEX                                #
# Data....: 28/06/2012                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

DEFINE m_tipo        CHAR(10)

#------------------------------------------------#
 FUNCTION vdp1150y_after_update_ped_itens_bnf()
#------------------------------------------------#
  DEFINE l_qtd_item_ant           DECIMAL(10,3),
         l_perc_adic_item_ant     DECIMAL(4,2),
         l_preco_unitario_ant     DECIMAL(17,8),
         l_prazo_entrega_ant      DATE,
         l_status                 SMALLINT,
         lr_parametros            RECORD
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

  LET lr_parametros.empresa            = LOG_getVar('empresa')
  LET lr_parametros.pedido             = LOG_getVar('pedido')
  LET lr_parametros.seq_item           = LOG_getVar('num_sequencia')
  LET lr_parametros.usuario_alt        = LOG_getVar('usuario_alt')
  LET lr_parametros.item               = LOG_getVar('item')
  LET lr_parametros.qtd_item           = LOG_getVar('qtd_item')
  LET lr_parametros.perc_adic_item     = LOG_getVar('pct_desc_adic')
  LET lr_parametros.preco_unitario     = LOG_getVar('pre_unit')
  LET lr_parametros.prazo_entrega      = LOG_getVar('prz_entrega')
  LET l_qtd_item_ant                   = LOG_getVar('qtd_item_ant')
  LET l_perc_adic_item_ant             = LOG_getVar('pct_desc_adic_ant')
  LET l_preco_unitario_ant             = LOG_getVar('pre_unit_ant')
  LET l_prazo_entrega_ant              = LOG_getVar('prz_entrega_ant')
  LET lr_parametros.modo_exibicao_msg  = LOG_getVar('modo_exibicao_msg')

  LET lr_parametros.tip_item           = "S"

  CALL vdpe0001_informa_motivo(lr_parametros.empresa) RETURNING lr_parametros.descricao_motivo, l_status
  CURRENT WINDOW IS w_vdp1150

  IF l_status = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
     RETURN
  END IF

  LET lr_parametros.tip_alteracao = "A"

  IF m_tipo IS NULL THEN #se for nulo é modificacao, entao deve verificar se teve alteracao. Senao grava o que veio dos sets
     #VERIFCA QUAIS CAMPOS FORAM ALTERADOS
     IF l_qtd_item_ant = lr_parametros.qtd_item THEN
        LET lr_parametros.qtd_item = NULL
     END IF

     IF l_perc_adic_item_ant = lr_parametros.perc_adic_item THEN
        LET lr_parametros.perc_adic_item = NULL
     END IF

     IF l_preco_unitario_ant = lr_parametros.preco_unitario THEN
        LET lr_parametros.preco_unitario = NULL
     END IF

     IF l_prazo_entrega_ant = lr_parametros.prazo_entrega THEN
        LET lr_parametros.prazo_entrega = NULL
     END IF
  END IF

  LET m_tipo = NULL

  IF vdpe0001_grava_auditoria(lr_parametros.*) = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
  ELSE
     CALL LOG_setVar("retorno_epl",TRUE)
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION vdp1150y_after_insert_ped_itens_bnf()
#------------------------------------------------#

 LET m_tipo = "INCLUSAO"

 CALL vdp1150y_after_update_ped_itens_bnf()

END FUNCTION

#-------------------------------#
FUNCTION vdp1150y_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp1150y.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
END FUNCTION
