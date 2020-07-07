#------------------------------------------------------------------------------#
# SISTEMA.: Regras de neg�cio logix - vdp                                      #
# OBJETIVO: REGRAS ESPECIFICAS CLIENTE KANAFLEX                                #
# Data....: 26/06/2012                                                         #
#------------------------------------------------------------------------------#
DATABASE logix


#------------------------------------------------#
 FUNCTION vdp1070y_after_insert_ped_itens()
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
                         tip_alteracao      CHAR(1), # I � inclus�o / C-cancelamento / A-altera��o
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
  LET lr_parametros.perc_adic_item     = LOG_getVar('pct_desc_adic')
  LET lr_parametros.preco_unitario     = LOG_getVar('pre_unit')
  LET lr_parametros.prazo_entrega      = LOG_getVar('prz_entrega')
  LET lr_parametros.val_frete_unitario = LOG_getVar('val_frete_unit')
  LET lr_parametros.val_segr_unitario  = LOG_getVar('val_seguro_unit')
  LET lr_parametros.modo_exibicao_msg  = LOG_getVar('modo_exibicao_msg')
  LET lr_parametros.descricao_motivo   = "PEDIDO INCLUIDO ATRAVES DA ROTINA DE INCLUSAO DE PEDIDOS BATCH PARA CARTEIRA - VDP1070."

  LET lr_parametros.tip_alteracao = "I"

  IF lr_parametros.tip_item = "S" THEN
     LET lr_parametros.val_frete_unitario = NULL
     LET lr_parametros.val_segr_unitario  = NULL
  END IF

  IF vdpe0001_grava_auditoria(lr_parametros.*) = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
  ELSE
     CALL LOG_setVar("retorno_epl",TRUE)
  END IF

END FUNCTION

#------------------------------------------------#
 FUNCTION vdp1070y_after_insert_ped_itens_bnf()
#------------------------------------------------#

 CALL vdp1070y_after_insert_ped_itens()

END FUNCTION


#-------------------------------#
FUNCTION vdp1070y_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp1070y.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)
END FUNCTION
