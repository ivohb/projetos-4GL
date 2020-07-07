#-----------------------------------------------------------------#
# SISTEMA.: VENDA E DISTRIBUIÇÃO DE PRODUTOS                      #
# PROGRAMA: VDPe0007                                              #
# OBJETIVO: CONSULTA AUDITORIA PED_ITENS                          #
# AUTOR...: LUCIANE D´ALMEIDA GABOARDI                            #
# DATA....: 29/06/2012                                            #
#-----------------------------------------------------------------#

DATABASE logix

GLOBALS

  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario

END GLOBALS

#--# MODULARES #--#

  DEFINE m_form    VARCHAR(10),
         m_status  SMALLINT,
         m_msg     CHAR(300)

  DEFINE mr_vdp_aud_it_ped_444 RECORD
                         empresa     LIKE vdp_aud_it_ped_444.empresa,
                         pedido      LIKE vdp_aud_it_ped_444.pedido,
                         transacao   LIKE vdp_aud_it_ped_444.transacao
                      END RECORD

  DEFINE ma_vdp_aud_it_ped_444 ARRAY[2000] OF RECORD
                                        empresa            LIKE vdp_aud_it_ped_444.empresa,
                                        pedido             LIKE vdp_aud_it_ped_444.pedido,
                                        seq_item           LIKE vdp_aud_it_ped_444.seq_item,
                                        item               LIKE vdp_aud_it_ped_444.item,
                                        tip_item           LIKE vdp_aud_it_ped_444.tip_item,
                                        dat_alteracao      LIKE vdp_aud_it_ped_444.dat_alteracao,
                                        hor_alteracao      LIKE vdp_aud_it_ped_444.hor_alteracao,
                                        tip_alteracao      LIKE vdp_aud_it_ped_444.tip_alteracao,
                                        usuario_alt        LIKE vdp_aud_it_ped_444.usuario_alt,
                                        perc_adic_item     LIKE vdp_aud_it_ped_444.perc_adic_item,
                                        preco_unitario     LIKE vdp_aud_it_ped_444.preco_unitario,
                                        qtd_item           LIKE vdp_aud_it_ped_444.qtd_item,
                                        prazo_entrega      LIKE vdp_aud_it_ped_444.prazo_entrega,
                                        val_frete_unitario LIKE vdp_aud_it_ped_444.val_frete_unitario,
                                        val_segr_unitario  LIKE vdp_aud_it_ped_444.val_segr_unitario,
                                        descricao_motivo   LIKE vdp_aud_it_ped_444.descricao_motivo,
                                        transacao          LIKE vdp_aud_it_ped_444.transacao
                                     END RECORD

#--# MODULARES #--#

#---------------------------------------------#
 FUNCTION vdpe0007_version_info()
#---------------------------------------------#

  RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/programas/vdpe0007.4gl $|$Revision: 1 $|$Date: 05/07/12 13:39 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION

#-------------------#
 FUNCTION vdpe0007()
#-------------------#

  DEFINE l_ind SMALLINT

  CALL fgl_setenv("ADVPL","1")

  CALL LOG_connectDatabase('DEFAULT')

  CALL log1400_isolation()

  CALL log0180_conecta_usuario()

  IF NOT LOG_initApp("VDPCON") THEN

     FOR l_ind = 1 TO 2000
        INITIALIZE ma_vdp_aud_it_ped_444[l_ind].* TO NULL
     END FOR

     INITIALIZE mr_vdp_aud_it_ped_444.* TO NULL

     LET m_form = _ADVPL_create_component(NULL,"LFORMMETADATA")
     CALL _ADVPL_set_property(m_form,"INIT_FORM","vdpe0007",mr_vdp_aud_it_ped_444, ma_vdp_aud_it_ped_444)
  END IF

END FUNCTION

#------------------------------#
 FUNCTION vdpe0007_after_load()
#------------------------------#

  DEFINE l_where_clause CHAR(100)

  LET l_where_clause = ' b.empresa = "',p_cod_empresa CLIPPED,'"'
  CALL _ADVPL_set_property(m_form,"WHERE_CLAUSE",l_where_clause)

  CALL _ADVPL_set_property(m_form,"ORDER_BY","b","pedido","DESC")
  CALL _ADVPL_set_property(m_form,"ORDER_BY","b","seq_item","ASC")
  CALL _ADVPL_set_property(m_form,"ORDER_BY","b","dat_alteracao","ASC")
  CALL _ADVPL_set_property(m_form,"ORDER_BY","b","hor_alteracao","ASC")

  RETURN TRUE

END FUNCTION
