#------------------------------------------------------------------------------#
# SISTEMA.: Regras de negócio logix - vdp                                      #
# OBJETIVO: REGRAS ESPECIFICAS CLIENTE KANAFLEX                                #
# Data....: 27/06/2012                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

#------------------------------------------------#
 FUNCTION vdp7070y_after_update_ped_itens()
#------------------------------------------------#
  DEFINE l_qtd_item_ant           DECIMAL(10,3),
         l_qtd                    DECIMAL(10,3),
         l_preco_unitario_ant     DECIMAL(17,8),
         l_prazo_entrega_ant      DATE,
         l_cod_motivo             LIKE mot_cancel.cod_motivo,
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
  LET lr_parametros.tip_item           = LOG_getVar('tip_item')
  LET lr_parametros.usuario_alt        = LOG_getVar('usuario_alt')
  LET lr_parametros.item               = LOG_getVar('item')
  LET lr_parametros.qtd_item           = LOG_getVar('qtd_item')
  LET lr_parametros.preco_unitario     = LOG_getVar('pre_unit')
  LET lr_parametros.prazo_entrega      = LOG_getVar('prz_entrega')
  LET l_qtd_item_ant                   = LOG_getVar('qtd_item_ant')
  LET l_preco_unitario_ant             = LOG_getVar('pre_unit_ant')
  LET l_prazo_entrega_ant              = LOG_getVar('prz_entrega_ant')
  LET lr_parametros.modo_exibicao_msg  = LOG_getVar('modo_exibicao_msg')
  LET l_cod_motivo                     = LOG_getVar('motivo')

  WHENEVER ERROR CONTINUE
  SELECT den_motivo
    INTO lr_parametros.descricao_motivo
    FROM mot_cancel
   WHERE cod_motivo = l_cod_motivo
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("SELECT","mot_cancel",lr_parametros.modo_exibicao_msg)
     CALL LOG_setVar("retorno_epl",FALSE)
     RETURN
  END IF

  LET l_qtd  = l_qtd_item_ant - lr_parametros.qtd_item

  IF l_qtd >= 0 THEN
     #cancelou a quantidade lr_parametros.qtd_item
     LET lr_parametros.tip_alteracao = "C"
     LET lr_parametros.qtd_item      = l_qtd
  ELSE
     #adicionou a quantidade  (-1 * l_qtd)
     LET lr_parametros.tip_alteracao = "A"
     LET lr_parametros.qtd_item      = -1 * l_qtd
  END IF

  #VERIFICA QUAIS CAMPOS FORAM ALTERADOS
  IF l_qtd_item_ant = lr_parametros.qtd_item THEN
     LET lr_parametros.qtd_item = NULL
  END IF

  IF l_preco_unitario_ant = lr_parametros.preco_unitario THEN
     LET lr_parametros.preco_unitario = NULL
  END IF

  IF l_prazo_entrega_ant = lr_parametros.prazo_entrega THEN
     LET lr_parametros.prazo_entrega = NULL
  END IF

  IF vdpe0001_grava_auditoria(lr_parametros.*) = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
  ELSE
     CALL LOG_setVar("retorno_epl",TRUE)
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION vdp7070y_before_qtd_pecas_saldo()
#------------------------------------------------#

 CALL vdpe0001_verifica_parametro()

END FUNCTION

#------------------------------------------------#
 FUNCTION vdp7070y_before_pre_unit()
#------------------------------------------------#

 CALL vdpe0001_verifica_parametro()

END FUNCTION

#-------------------------------#
FUNCTION vdp7070y_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp7070y.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
END FUNCTION
