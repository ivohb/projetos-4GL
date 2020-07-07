#------------------------------------------------------------------------------#
# SISTEMA.: Regras de negócio logix - vdp                                      #
# OBJETIVO: REGRAS ESPECIFICAS CLIENTE KANAFLEX                                #
# Data....: 27/06/2012                                                         #
#------------------------------------------------------------------------------#
DATABASE logix

#------------------------------------------------#
 FUNCTION vdp7820y_after_update_ped_itens_desc()
#------------------------------------------------#
  DEFINE l_status                 SMALLINT,
         lr_parametros            RECORD
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

  LET lr_parametros.empresa            = LOG_getVar('empresa')
  LET lr_parametros.pedido             = LOG_getVar('pedido')
  LET lr_parametros.seq_item           = LOG_getVar('num_sequencia')
  LET lr_parametros.usuario_alt        = LOG_getVar('usuario_alt')
  LET lr_parametros.tip_alteracao      = LOG_getVar('tip_alteracao')
  LET lr_parametros.modo_exibicao_msg  = LOG_getVar('modo_exibicao_msg')

  WHENEVER ERROR CONTINUE
  SELECT pct_desc_1, pct_desc_2, pct_desc_3, pct_desc_4, pct_desc_5, pct_desc_6, pct_desc_7, pct_desc_8, pct_desc_9, pct_desc_10
    INTO lr_parametros.pct_desc_1, lr_parametros.pct_desc_2, lr_parametros.pct_desc_3, lr_parametros.pct_desc_4, lr_parametros.pct_desc_5,
         lr_parametros.pct_desc_6, lr_parametros.pct_desc_7, lr_parametros.pct_desc_8, lr_parametros.pct_desc_9, lr_parametros.pct_desc_10
    FROM ped_itens_desc
   WHERE cod_empresa   = lr_parametros.empresa
     AND num_pedido    = lr_parametros.pedido
     AND num_sequencia = lr_parametros.seq_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log0030_processa_err_sql("SELECT","ped_itens_desc",lr_parametros.modo_exibicao_msg)
     CALL LOG_setVar("retorno_epl",FALSE)
     RETURN
  END IF

  IF lr_parametros.tip_alteracao = "I" THEN
     LET lr_parametros.tip_alteracao = "A"
  END IF

  CALL vdpe0001_informa_motivo(lr_parametros.empresa) RETURNING lr_parametros.descricao_motivo, l_status
  CURRENT WINDOW IS w_vdp7820

  IF l_status = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
     RETURN
  END IF

  #IRA GRAVAR TODOS OS CAMPOS E NAO SOMENTE OS QUE FORAM ALTERADOS POIS A TABELA FOI CRIADA COMO NOT NULL
  #IGUAL A PED_ITENS_DESC

  IF vdpe0001_grava_auditoria_desc(lr_parametros.*) = FALSE THEN
     CALL LOG_setVar("retorno_epl",FALSE)
  ELSE
     CALL LOG_setVar("retorno_epl",TRUE)
  END IF

END FUNCTION

#-------------------------------#
FUNCTION vdp7820y_after_insert_ped_itens_desc()
#-------------------------------#
  CALL vdp7820y_after_update_ped_itens_desc()

END FUNCTION

#-------------------------------#
FUNCTION vdp7820y_before_delete_ped_itens_desc()
#-------------------------------#
  CALL vdp7820y_after_update_ped_itens_desc()

END FUNCTION

#-------------------------------#
FUNCTION vdp7820y_version_info()
#-------------------------------#
RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp7820y.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
END FUNCTION
