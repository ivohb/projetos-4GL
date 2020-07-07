#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDPE0009                                              #
# OBJETIVO: AUDITORIA DE PEDIDOS                                  #
# AUTOR...: LUCIANA NAOMI KANEKO                                  #
# DATA....: 5/07/2012                                             #
#-----------------------------------------------------------------#

 DATABASE logix

 GLOBALS
    DEFINE p_cod_empresa LIKE empresa.cod_empresa,
           p_user        LIKE usuario.nom_usuario
 END GLOBALS

 DEFINE m_form                   VARCHAR(50),
        m_progress_bar_reference VARCHAR(50),
        m_cod_unid_med           CHAR(03),
        m_den_item               CHAR(18),
        m_last_row               SMALLINT,
        m_status                 SMALLINT,
        m_cont                   SMALLINT,
        m_den_empresa            LIKE empresa.den_empresa,
        m_pedido_param           LIKE pedidos.num_pedido

 DEFINE mr_tela RECORD
        dat_pedido_ini           DATE,
        dat_pedido_fim           DATE,
        ies_saldo                CHAR(01),
        ies_opcao                CHAR(01),
        ies_opcao_periodo        CHAR(01)
                END RECORD

 DEFINE ma_tela ARRAY[999] OF RECORD
                              num_pedido   LIKE pedidos.num_pedido,
                              cod_cliente  LIKE pedidos.cod_cliente,
                              nom_cliente  CHAR(36)
                              END RECORD

 DEFINE mr_vdp_aud_it_ped_444   RECORD
           empresa              CHAR(02),
           transacao            INTEGER,
           pedido               INTEGER,
           seq_item             INTEGER,
           tip_item             CHAR(01),
           dat_alteracao        DATE,
           hor_alteracao        CHAR(08),
           usuario_alt          CHAR(08),
           item                 CHAR(15),
           tip_alteracao        CHAR(01),
           descricao_motivo     CHAR(30),
           perc_adic_item       DECIMAL(4,2),
           preco_unitario       DECIMAL(17,6),
           qtd_item             DECIMAL(10,3),
           prazo_entrega        DATE,
           val_frete_unitario   DECIMAL(17,6),
           val_segr_unitario    DECIMAL(17,6)
           END RECORD

 DEFINE mr_vdp_audit_desc  RECORD
        empresa                 CHAR(02),
        transacao               INTEGER,
        pedido                  INTEGER,
        seq_item                INTEGER,
        dat_alteracao           DATE,
        hor_alteracao           CHAR(08),
        usuario_alt             CHAR(08),
        tip_alteracao           CHAR(01),
        descricao_motivo        CHAR(30),
        perc_desconto_1         DECIMAL(05,2),
        perc_desconto_2         DECIMAL(05,2),
        perc_desconto_3         DECIMAL(05,2),
        perc_desconto_4         DECIMAL(05,2),
        perc_desconto_5         DECIMAL(05,2),
        perc_desconto_6         DECIMAL(05,2),
        perc_desconto_7         DECIMAL(05,2),
        perc_desconto_8         DECIMAL(05,2),
        perc_desconto_9         DECIMAL(05,2),
        perc_desconto_10        DECIMAL(05,2)
           END RECORD



 DEFINE m_page_length        SMALLINT
 DEFINE m_impressao_externa   SMALLINT


#-------------------#
 FUNCTION vdpe0009()
#-------------------#

   DEFINE l_ind SMALLINT

   CALL fgl_setenv("ADVPL","1")
   CALL LOG_connectDatabase('DEFAULT')
   CALL log1400_isolation()
   CALL log0180_conecta_usuario()

   CALL log001_acessa_usuario("VDP","LOGERP")
        RETURNING m_status, p_cod_empresa, p_user

   IF NOT m_status THEN
      INITIALIZE mr_tela TO NULL
      FOR l_ind = 1 TO 999
         INITIALIZE ma_tela[l_ind].* TO NULL
      END FOR
      LET m_form = _ADVPL_create_component(NULL,"LPARMETADATA")
      CALL _ADVPL_set_property(m_form,"INIT_PARAMETER","vdpe0009",mr_tela,ma_tela)
   END IF

 END FUNCTION

#------------------------------#
 FUNCTION vdpe0009_after_load()
#------------------------------#
   DEFINE l_status               SMALLINT

   WHENEVER ERROR CONTINUE
   SELECT empresa.den_empresa
     INTO m_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = NOTFOUND THEN
      LET m_den_empresa = "NÃO CADASTRADA"
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("LEITURA","empresa")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

 END FUNCTION


#---------------------------------------#
 FUNCTION vdpe0009_before_input_inform()
#---------------------------------------#

   DEFINE l_referencia VARCHAR(10)

   LET mr_tela.ies_saldo       = 'N'

   IF m_pedido_param IS NOT NULL THEN
      LET ma_tela[1].num_pedido = m_pedido_param
      LET l_referencia = _ADVPL_get_property(m_form,"COMPONENT_REFERENCE","pedidos","num_pedido")
      CALL _ADVPL_set_property(l_referencia,"VALUE",ma_tela[1].num_pedido)
   END IF

   RETURN TRUE

 END FUNCTION


#------------------------------------#
 FUNCTION vdpe0009_valid_num_pedido()
#------------------------------------#

   RETURN vdpe0009_valida_pedido()

 END FUNCTION

#-----------------------------------------#
 FUNCTION vdpe0009_after_zoom_num_pedido()
#-----------------------------------------#

   RETURN vdpe0009_valida_pedido()

 END FUNCTION

#----------------------------------#
 FUNCTION vdpe0009_valida_pedido()
#----------------------------------#

   DEFINE l_multi_valued_table_reference VARCHAR(10),
          l_arr_curr                     SMALLINT,
          l_status                       SMALLINT

   LET l_multi_valued_table_reference = _ADVPL_get_property(m_form,"MULTI_VALUED_TABLE_REFERENCE")

   IF  l_multi_valued_table_reference IS NULL THEN
      LET l_arr_curr = 1
   ELSE
      LET l_arr_curr = _ADVPL_get_property(l_multi_valued_table_reference,"ROW_SELECTED")
   END IF

   IF ma_tela[l_arr_curr].num_pedido IS NOT NULL THEN

      CALL vdpe0009_verifica_num_pedido(ma_tela[l_arr_curr].num_pedido)
           RETURNING ma_tela[l_arr_curr].nom_cliente,
                     l_status

      IF l_status THEN
         INITIALIZE mr_tela.dat_pedido_ini,
                    mr_tela.dat_pedido_fim TO NULL

         CALL log_enable_component(m_form," ","pedidos","dat_pedido_ini",FALSE)
         CALL log_enable_component(m_form," ","pedidos","dat_pedido_fim",FALSE)
      ELSE
         CALL log_show_status_bar_text(m_form,"Pedido não cadastrado.","WARNING_TEXT")
         RETURN FALSE
      END IF
   END IF

   CALL log_show_status_bar_text(m_form," ","INFO_TEXT")
   RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION vdpe0009_after_field_num_pedido()
#------------------------------------------#

   DEFINE l_reference                    VARCHAR(10),
          l_multi_valued_table_reference VARCHAR(10),
          l_arr_curr                     SMALLINT,
          l_habilitado                   SMALLINT,
          l_status                       SMALLINT,
          l_ind                          SMALLINT

   LET l_multi_valued_table_reference = _ADVPL_get_property(m_form,"MULTI_VALUED_TABLE_REFERENCE")

   IF  l_multi_valued_table_reference IS NULL THEN
      LET l_arr_curr = 1
   ELSE
      LET l_arr_curr = _ADVPL_get_property(l_multi_valued_table_reference,"ROW_SELECTED")
   END IF

   IF ma_tela[l_arr_curr].num_pedido IS NULL THEN

      INITIALIZE ma_tela[l_arr_curr].nom_cliente TO NULL

      IF l_arr_curr = 1 THEN
         FOR l_ind = 2 TO 999
            IF ma_tela[l_ind].num_pedido IS NULL THEN
               EXIT FOR
            END IF
            INITIALIZE ma_tela[l_ind].num_pedido,
                       ma_tela[l_ind].nom_cliente TO NULL
         END FOR
      END IF

      LET l_reference = _ADVPL_get_property(m_form,"COMPONENT_REFERENCE","pedidos","dat_pedido_ini")
      LET l_habilitado = _ADVPL_get_property(l_reference,"ENABLE")
      IF NOT l_habilitado THEN
         CALL log_enable_component(m_form," ","pedidos","dat_pedido_ini",TRUE)
      END IF
      LET l_reference = _ADVPL_get_property(m_form,"COMPONENT_REFERENCE","pedidos","dat_pedido_fim")
      LET l_habilitado = _ADVPL_get_property(l_reference,"ENABLE")
      IF NOT l_habilitado THEN
         CALL log_enable_component(m_form," ","pedidos","dat_pedido_fim",TRUE)
      END IF
   END IF

   RETURN TRUE

 END FUNCTION

#---------------------------------------------------#
 FUNCTION vdpe0009_verifica_num_pedido(l_num_pedido)
#---------------------------------------------------#

   DEFINE l_num_pedido     LIKE pedidos.num_pedido,
          l_nom_cliente    CHAR(36)

      WHENEVER ERROR CONTINUE
      SELECT DISTINCT clientes.nom_cliente
        INTO l_nom_cliente
        FROM pedidos, clientes,
             vdp_aud_it_ped_444
       WHERE pedidos.cod_empresa        = p_cod_empresa
         AND vdp_aud_it_ped_444.empresa = p_cod_empresa
         AND pedidos.num_pedido         = l_num_pedido
         AND vdp_aud_it_ped_444.pedido  = l_num_pedido
         AND clientes.cod_cliente       = pedidos.cod_cliente
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         RETURN l_nom_cliente,FALSE
      END IF

   RETURN l_nom_cliente,TRUE

 END FUNCTION

#----------------------------------------#
 FUNCTION vdpe0009_valid_dat_pedido_fim()
#----------------------------------------#

   DEFINE l_ind SMALLINT

   IF mr_tela.dat_pedido_ini IS NOT NULL AND
      mr_tela.dat_pedido_ini > mr_tela.dat_pedido_fim THEN
      CALL log_show_status_bar_text(m_form,"A data final deve ser maior ou igual a data inicial.","ERROR_TEXT")
      RETURN FALSE
   END IF

   FOR l_ind = 1 TO 999
      IF ma_tela[l_ind].num_pedido IS NULL THEN
         EXIT FOR
      END IF
      INITIALIZE ma_tela[l_ind].num_pedido,
                 ma_tela[l_ind].cod_cliente,
                 ma_tela[l_ind].nom_cliente TO NULL
   END FOR
   CALL log_enable_component(m_form," ","pedidos","num_pedido",FALSE)

   RETURN TRUE

 END FUNCTION

#----------------------------------------------#
 FUNCTION vdpe0009_after_field_dat_pedido_fim()
#----------------------------------------------#

   DEFINE l_habilitado SMALLINT,
          l_reference  VARCHAR(10)

   IF mr_tela.dat_pedido_fim IS NULL THEN
      LET l_reference = _ADVPL_get_property(m_form,"COMPONENT_REFERENCE","pedidos","num_pedido")
      LET l_habilitado = _ADVPL_get_property(l_reference,"ENABLE")
      IF NOT l_habilitado THEN
         CALL log_enable_component(m_form," ","pedidos","num_pedido",TRUE)
      END IF
   END IF
   RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION vdpe0009_confirm_inform()
#----------------------------------#

   IF (mr_tela.dat_pedido_ini IS NULL) <> (mr_tela.dat_pedido_fim IS NULL) THEN
      CALL log_show_status_bar_text(m_form,"As datas inicial e final devem ser preenchidas.","ERROR_TEXT")
      CALL log_focus_component(m_form," ","pedidos","dat_pedido_ini")
      RETURN FALSE
   END IF

   IF mr_tela.dat_pedido_ini IS NOT NULL AND
      mr_tela.dat_pedido_ini > mr_tela.dat_pedido_fim THEN
      CALL log_show_status_bar_text(m_form,"A data inicial deve ser menor ou igual a data final.","ERROR_TEXT")
      CALL log_focus_component(m_form," ","pedidos","dat_pedido_ini")
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#-----------------------------------#
 FUNCTION vdpe0009_confirm_process()
#-----------------------------------#

   LET m_status = TRUE

   IF NOT m_impressao_externa THEN
      LET m_progress_bar_reference = _ADVPL_get_property(m_form,"PROGRESS_BAR_REFERENCE")
      CALL _ADVPL_set_property(m_progress_bar_reference,"INCREMENT_TYPE","PROCESS","PERCENT")
   END IF

   CALL StartReport("vdpe0009_lista_auditoria","vdpe0009","Pedidos",220,TRUE,TRUE)
   CALL FinishReport("vdpe0009")

   IF NOT m_status THEN
      CALL log0030_mensagem("Ocorreram erros durante a execução do relatório.","stop")
      RETURN FALSE
   END IF

   RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION vdpe0009_lista_auditoria(l_reportfile)
#--------------------------------------------#

   DEFINE l_reportfile          VARCHAR(50),
          l_sql_select          VARCHAR(2000),
          l_sql_select_2        VARCHAR(2000),
          l_sql_count           VARCHAR(2000),
          l_sql_count_2         VARCHAR(2000),
          l_sql_stmt            VARCHAR(2000),
          l_sql_stmt_2          VARCHAR(2000),
          l_gerou_relat         SMALLINT,
          l_primeira_vez        SMALLINT,
          l_pedido_ant          INTEGER,
          l_total_registros     SMALLINT,
          l_erro                SMALLINT,
          l_ind                 SMALLINT,
          l_cancelado           SMALLINT

   INITIALIZE l_sql_stmt,
              l_sql_stmt_2,
              l_sql_select,
              l_sql_select_2,
              l_sql_count,
              l_sql_count_2 TO NULL

   LET l_erro      = FALSE
   LET l_cancelado = FALSE
   LET m_status    = TRUE
   LET m_last_row  = FALSE
   LET m_cont      = 0
   LET l_primeira_vez = TRUE
   LET l_pedido_ant = 0

   LET l_sql_count  = " SELECT COUNT(*) "

   LET l_sql_select = " SELECT vdp_aud_it_ped_444.empresa, ",
                             " vdp_aud_it_ped_444.transacao, ",
                             " vdp_aud_it_ped_444.pedido, ",
                             " vdp_aud_it_ped_444.seq_item, ",
                             " vdp_aud_it_ped_444.item, ",
                             " item.den_item_reduz, ",
                             " vdp_aud_it_ped_444.tip_item, ",
                             " vdp_aud_it_ped_444.dat_alteracao, ",
                             " vdp_aud_it_ped_444.hor_alteracao, ",
                             " vdp_aud_it_ped_444.tip_alteracao, ",
                             " vdp_aud_it_ped_444.descricao_motivo, ",
                             " vdp_aud_it_ped_444.perc_adic_item, ",
                             " vdp_aud_it_ped_444.preco_unitario, ",
                             " vdp_aud_it_ped_444.qtd_item, ",
                             " vdp_aud_it_ped_444.prazo_entrega, ",
                             " vdp_aud_it_ped_444.val_frete_unitario, ",
                             " vdp_aud_it_ped_444.val_segr_unitario "
   LET l_sql_stmt   = "   FROM vdp_aud_it_ped_444, item "

   IF mr_tela.ies_opcao_periodo = 'I' THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " ,pedidos "
   END IF

   IF mr_tela.ies_saldo = 'S' THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED, " ,ped_itens "
   END IF


   LET l_sql_stmt = l_sql_stmt CLIPPED,
                       " WHERE item.cod_empresa = '",p_cod_empresa,"' ",
                         " AND vdp_aud_it_ped_444.empresa = '",p_cod_empresa,"' ",
                         " AND vdp_aud_it_ped_444.item = item.cod_item "

   IF ma_tela[1].num_pedido IS NOT NULL THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED,
                    "    AND (vdp_aud_it_ped_444.pedido = ",ma_tela[1].num_pedido
      FOR l_ind = 2 TO 999
         IF ma_tela[l_ind].num_pedido IS NULL THEN
            EXIT FOR
         END IF
         LET l_sql_stmt = l_sql_stmt CLIPPED,
                          " OR vdp_aud_it_ped_444.pedido = ",ma_tela[l_ind].num_pedido
      END FOR

      LET l_sql_stmt = l_sql_stmt CLIPPED,")"
   END IF

   IF mr_tela.ies_opcao_periodo = 'I' THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED,
                       " AND pedidos.cod_empresa = '",p_cod_empresa,"' ",
                       " AND pedidos.num_pedido = vdp_aud_it_ped_444.pedido "
      IF mr_tela.dat_pedido_ini IS NOT NULL AND
         mr_tela.dat_pedido_fim IS NOT NULL THEN
         LET l_sql_stmt = l_sql_stmt CLIPPED,
                       " AND pedidos.dat_pedido BETWEEN '",mr_tela.dat_pedido_ini,"' AND '",mr_tela.dat_pedido_fim,"' "
      END IF
   ELSE
      IF mr_tela.dat_pedido_ini IS NOT NULL AND
         mr_tela.dat_pedido_fim IS NOT NULL THEN
         LET l_sql_stmt = l_sql_stmt CLIPPED," AND vdp_aud_it_ped_444.dat_alteracao BETWEEN '",mr_tela.dat_pedido_ini,"' AND '",mr_tela.dat_pedido_fim,"' "
      END IF
   END IF


   IF mr_tela.ies_saldo = 'S' THEN
      LET l_sql_stmt = l_sql_stmt CLIPPED,
                       " AND ped_itens.cod_empresa = '",p_cod_empresa,"' ",
                       " AND ped_itens.num_pedido = vdp_aud_it_ped_444.pedido ",
                       " AND ped_itens.cod_item = vdp_aud_it_ped_444.item ",
                       " AND ped_itens.num_sequencia = vdp_aud_it_ped_444.seq_item ",
                       " AND (ped_itens.qtd_pecas_solic - ped_itens.qtd_pecas_atend - ",
                       "      ped_itens.qtd_pecas_cancel ) > 0 "
   END IF

   LET l_sql_count = l_sql_count CLIPPED,l_sql_stmt

   LET l_sql_stmt = l_sql_stmt CLIPPED,
                   " order by vdp_aud_it_ped_444.pedido, vdp_aud_it_ped_444.seq_item, ",
                   " vdp_aud_it_ped_444.dat_alteracao, vdp_aud_it_ped_444.hor_alteracao"
   LET l_sql_select = l_sql_select CLIPPED, l_sql_stmt

   CALL vdpe0009_retorna_total_registros(l_sql_count)
        RETURNING l_total_registros,m_status
   IF NOT m_status THEN
      RETURN
   END IF

   CALL LOG_progresspopup_set_total('PROCESS',l_total_registros)


   WHENEVER ERROR CONTINUE
   PREPARE var_query FROM l_sql_select
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("PREPARE","var_query")
      LET m_status = FALSE
      RETURN
   END IF

   WHENEVER ERROR CONTINUE
   DECLARE cq_pedido_list_1 CURSOR FOR var_query
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DECLARE","CQ_PEDIDO_LIST_1")
      LET m_status = FALSE
      RETURN
   END IF



      LET l_sql_count_2  = ' SELECT COUNT(*) '
      LET l_sql_select_2 =
          ' SELECT vdp_audit_desc_444.empresa      , ',
          '        vdp_audit_desc_444.transacao    , ',
          '        vdp_audit_desc_444.pedido       , ',
          '        vdp_audit_desc_444.seq_item     , ',
          '        vdp_audit_desc_444.dat_alteracao, ',
          '        vdp_audit_desc_444.hor_alteracao, ',
          '        vdp_audit_desc_444.usuario_alt  , ',
          '        vdp_audit_desc_444.tip_alteracao, ',
          '        vdp_audit_desc_444.descricao_motivo,  ',
          '        vdp_audit_desc_444.perc_desconto_1 ,  ',
          '        vdp_audit_desc_444.perc_desconto_2 ,  ',
          '        vdp_audit_desc_444.perc_desconto_3 ,  ',
          '        vdp_audit_desc_444.perc_desconto_4 ,  ',
          '        vdp_audit_desc_444.perc_desconto_5 ,  ',
          '        vdp_audit_desc_444.perc_desconto_6 ,  ',
          '        vdp_audit_desc_444.perc_desconto_7 ,  ',
          '        vdp_audit_desc_444.perc_desconto_8 ,  ',
          '        vdp_audit_desc_444.perc_desconto_9 ,  ',
          '        vdp_audit_desc_444.perc_desconto_10  '

      LET l_sql_stmt_2 =
            ' FROM vdp_audit_desc_444 ',
           ' WHERE vdp_audit_desc_444.empresa = ?',
             ' AND vdp_audit_desc_444.pedido  =  ?'


      LET l_sql_select_2 = l_sql_select_2 CLIPPED,
                           l_sql_stmt_2

      WHENEVER ERROR CONTINUE
      PREPARE var_query2 FROM l_sql_select_2
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("PREPARE","VAR_QUERY2")
        LET l_erro = TRUE
        RETURN
      END IF

      WHENEVER ERROR CONTINUE
      DECLARE cq_vdp_audit_desc CURSOR FOR var_query2
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DECLARE","CQ_vdp_audit_desc")
         LET l_erro = TRUE
         RETURN
      END IF

   LET l_gerou_relat = FALSE

   LET m_page_length = ReportPageLength("vdpe0009")

   START REPORT vdpe0009_relat TO l_reportfile

   WHENEVER ERROR CONTINUE
   FOREACH cq_pedido_list_1 INTO mr_vdp_aud_it_ped_444.empresa,
                                 mr_vdp_aud_it_ped_444.transacao,
                                 mr_vdp_aud_it_ped_444.pedido,
                                 mr_vdp_aud_it_ped_444.seq_item,
                                 mr_vdp_aud_it_ped_444.item,
                                 m_den_item,
                                 mr_vdp_aud_it_ped_444.tip_item,
                                 mr_vdp_aud_it_ped_444.dat_alteracao,
                                 mr_vdp_aud_it_ped_444.hor_alteracao,
                                 mr_vdp_aud_it_ped_444.tip_alteracao,
                                 mr_vdp_aud_it_ped_444.descricao_motivo,
                                 mr_vdp_aud_it_ped_444.perc_adic_item,
                                 mr_vdp_aud_it_ped_444.preco_unitario,
                                 mr_vdp_aud_it_ped_444.qtd_item,
                                 mr_vdp_aud_it_ped_444.prazo_entrega,
                                 mr_vdp_aud_it_ped_444.val_frete_unitario,
                                 mr_vdp_aud_it_ped_444.val_segr_unitario
   WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("FOREACH","CQ_PEDIDO_LIST_1")
         LET l_erro = TRUE
         EXIT FOREACH
      END IF

      IF log_progresspopup_stop() THEN
         LET l_cancelado = TRUE
         EXIT FOREACH
      END IF


      IF l_primeira_vez OR
         l_pedido_ant <> mr_vdp_aud_it_ped_444.pedido  THEN
         IF l_primeira_vez = FALSE THEN
            IF NOT vdpe0009_imprime_desc(l_pedido_ant) THEN
               LET l_erro = TRUE
               EXIT FOREACH
            END IF
         END IF

         OUTPUT TO REPORT vdpe0009_relat("MESTRE")
         LET l_primeira_vez = FALSE
         LET l_pedido_ant = mr_vdp_aud_it_ped_444.pedido
      END IF

      OUTPUT TO REPORT vdpe0009_relat("ITENS")

      LET l_gerou_relat = TRUE


      IF l_erro OR l_cancelado THEN
         EXIT FOREACH
      END IF

      IF NOT m_impressao_externa THEN
         IF NOT log_progress_increment("PROCESS") THEN
            RETURN FALSE
         END IF
      END IF

   END FOREACH
   IF NOT vdpe0009_imprime_desc(l_pedido_ant) THEN
      LET l_erro = TRUE
   END IF

   FREE cq_pedido_list_1
   FINISH REPORT vdpe0009_relat


 END FUNCTION
#-----------------------------------#
 FUNCTION vdpe0009_imprime_desc(l_pedido)
#-----------------------------------#
 DEFINE l_pedido             INTEGER

      WHENEVER ERROR CONTINUE
      OPEN cq_vdp_audit_desc USING p_cod_empresa,
                                   l_pedido
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0  THEN
         CALL log003_err_sql("DECLARE","CQ_vdp_audit_desc")
         RETURN FALSE
      END IF

      WHENEVER ERROR CONTINUE
      FETCH cq_vdp_audit_desc INTO mr_vdp_audit_desc.empresa      ,
                                mr_vdp_audit_desc.transacao    ,
                                mr_vdp_audit_desc.pedido       ,
                                mr_vdp_audit_desc.seq_item     ,
                                mr_vdp_audit_desc.dat_alteracao,
                                mr_vdp_audit_desc.hor_alteracao,
                                mr_vdp_audit_desc.usuario_alt  ,
                                mr_vdp_audit_desc.tip_alteracao,
                                mr_vdp_audit_desc.descricao_motivo,
                                mr_vdp_audit_desc.perc_desconto_1 ,
                                mr_vdp_audit_desc.perc_desconto_2 ,
                                mr_vdp_audit_desc.perc_desconto_3 ,
                                mr_vdp_audit_desc.perc_desconto_4 ,
                                mr_vdp_audit_desc.perc_desconto_5 ,
                                mr_vdp_audit_desc.perc_desconto_6 ,
                                mr_vdp_audit_desc.perc_desconto_7 ,
                                mr_vdp_audit_desc.perc_desconto_8 ,
                                mr_vdp_audit_desc.perc_desconto_9 ,
                                mr_vdp_audit_desc.perc_desconto_10

      WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
            CALL log003_err_sql("FOREACH","CQ_vdp_audit_desc")
            RETURN FALSE
         END IF
         IF sqlca.sqlcode = 0 THEN
            IF log_progresspopup_stop() THEN
               RETURN FALSE
            END IF

            OUTPUT TO REPORT vdpe0009_relat("DESC")
         END IF
 RETURN TRUE
END FUNCTION

#-----------------------------#
REPORT vdpe0009_relat(l_relat)
#-----------------------------#

   DEFINE l_relat               CHAR(15),
          l_qtd_pecas_saldo     LIKE ped_itens.qtd_pecas_solic,
          l_valor_total_tot     DECIMAL(15,2),
          l_item_onu            CHAR(27),
          l_min                 SMALLINT,
          l_max                 SMALLINT,
          l_posicao             SMALLINT   ,
          l_tamanhos            CHAR(100)

   DEFINE lr_kit                RECORD
                                   seq_kit             LIKE ped_kit_pedido.seq_kit,
                                   kit                 CHAR(30),
                                   qtd_kit             LIKE ped_kit_pedido.qtd_kit,
                                   prazo_entrega       LIKE ped_kit_pedido.prazo_entrega,
                                   qtd_kits_atend      LIKE ped_itens.qtd_pecas_atend,
                                   qtd_kits_cancel     LIKE ped_itens.qtd_pecas_cancel,
                                   qtd_kits_saldo      LIKE ped_itens.qtd_pecas_solic,
                                   qtd_kits_solic      LIKE ped_itens.qtd_pecas_solic,
                                   pre_kits_unit       LIKE ped_itens.pre_unit,
                                   pre_kits_liq        LIKE ped_itens.pre_unit,
                                   pct_kits_desc_adic  LIKE ped_itens.pct_desc_adic,
                                   pct_kits_desc_bruto LIKE ped_itens.pct_desc_bruto,
                                   pes_kits            LIKE item.pes_unit
                                END RECORD

   DEFINE l_descricao_kit       LIKE vdp_configuracao_kit.descricao_kit,
          l_qtd_itens_kit       SMALLINT,
          l_valor_total_liqr    DECIMAL(15,2),
          l_valor_total_brur    DECIMAL(15,2)

   DEFINE l_ind                 SMALLINT

   DEFINE l_sql_stmt            CHAR(1000),
          la_desconto_pedido    ARRAY[10] OF DECIMAL(5,2)


   OUTPUT TOP    MARGIN  0
          LEFT   MARGIN  0
          BOTTOM MARGIN  0
          PAGE   LENGTH  m_page_length
#   ORDER EXTERNAL BY l_relat

   FORMAT

   PAGE HEADER
      CALL ReportPageHeader("vdpe0009")


   ON EVERY ROW
      IF l_relat = "MESTRE" THEN
         SKIP TO TOP OF PAGE
         PRINT COLUMN 001, " ",
               COLUMN 003, "       EMPRESA:",
               COLUMN 019, mr_vdp_aud_it_ped_444.empresa
         PRINT COLUMN 001, " ",
               COLUMN 003, "PEDIDO NUMERO:",
               COLUMN 019, mr_vdp_aud_it_ped_444.pedido  USING "########"

            IF mr_tela.ies_opcao = "A" THEN
               PRINT COLUMN   1, "  SEQ ITEM            DESCRICAO           TIPO   DATA   HORA     USUARIO  TIPO ALT %DESC        PRECO   QUANTIDADE PRZ ENTR  VALOR FRETE  VALOR SEGURO"
               PRINT COLUMN   1, "MOTIVO"
               PRINT COLUMN   1, "----- --------------- ------------------- ---- -------- -------- -------- -------- ----- ------------ ------------ --------- ------------ ------------"
            ELSE
               PRINT COLUMN   1, "  SEQ ITEM            DESCRICAO           TIPO   DATA   TIPO ALT %DESC        PRECO   QUANTIDADE PRZ ENTR  VALOR FRETE  VALOR SEGURO"
               PRINT COLUMN   1, "----- --------------- ------------------- ---- -------- -------- ----- ------------ ------------ --------- ------------ ------------"
            END IF
      END IF

      IF l_relat = "ITENS" THEN
         IF mr_tela.ies_opcao = "A" THEN
            PRINT COLUMN   1, mr_vdp_aud_it_ped_444.seq_item USING "#####",
                  COLUMN   7, mr_vdp_aud_it_ped_444.item,
                  COLUMN  23, m_den_item,
                  COLUMN  46, mr_vdp_aud_it_ped_444.tip_item ,
                  COLUMN  48, mr_vdp_aud_it_ped_444.dat_alteracao USING "dd/mm/yy",
                  COLUMN  57, mr_vdp_aud_it_ped_444.hor_alteracao,
                  COLUMN  66, mr_vdp_aud_it_ped_444.usuario_alt,
                  COLUMN  82, mr_vdp_aud_it_ped_444.tip_alteracao,
                  COLUMN  84, mr_vdp_aud_it_ped_444.perc_adic_item USING "#&.&&",
                  COLUMN  90, mr_vdp_aud_it_ped_444.preco_unitario USING "####&.&&&&&&",
                  COLUMN 103, mr_vdp_aud_it_ped_444.qtd_item       USING "#######&.&&&",
                  COLUMN 116, mr_vdp_aud_it_ped_444.prazo_entrega  USING "dd/mm/yy",
                  COLUMN 126, mr_vdp_aud_it_ped_444.val_frete_unitario USING "####&.&&&&&&",
                  COLUMN 139, mr_vdp_aud_it_ped_444.val_segr_unitario  USING "####&.&&&&&&"
            PRINT COLUMN   1, mr_vdp_aud_it_ped_444.descricao_motivo

         ELSE
            PRINT COLUMN   1, mr_vdp_aud_it_ped_444.seq_item USING "#####",
                  COLUMN   7, mr_vdp_aud_it_ped_444.item,
                  COLUMN  23, m_den_item,
                  COLUMN  46, mr_vdp_aud_it_ped_444.tip_item,
                  COLUMN  48, mr_vdp_aud_it_ped_444.dat_alteracao USING "dd/mm/yy",
                  COLUMN  64, mr_vdp_aud_it_ped_444.tip_alteracao,
                  COLUMN  66, mr_vdp_aud_it_ped_444.perc_adic_item USING "#&.&&",
                  COLUMN  72, mr_vdp_aud_it_ped_444.preco_unitario USING "####&.&&&&&&",
                  COLUMN  85, mr_vdp_aud_it_ped_444.qtd_item       USING "#######&.&&&",
                  COLUMN  98, mr_vdp_aud_it_ped_444.prazo_entrega  USING "dd/mm/yy",
                  COLUMN 108, mr_vdp_aud_it_ped_444.val_frete_unitario USING "####&.&&&&&&",
                  COLUMN 121, mr_vdp_aud_it_ped_444.val_segr_unitario  USING "####&.&&&&&&"
         END IF
      END IF

      IF l_relat = "DESC" THEN
         NEED 2 LINES
            PRINT " "
            PRINT " "
            PRINT COLUMN 1, "-------------------------------DESCONTOS----------------------------------------------"
            PRINT COLUMN 1, "SEQ ITEM SEQ DESC DATA     HORA     USUARIO  TIPO %DESC MOTIVO"
            PRINT COLUMN 1, "-------- -------- -------- -------- -------- ---- ----- ------------------------------"
            PRINT COLUMN   4, mr_vdp_audit_desc.seq_item USING "#####",
                  COLUMN  16, "01 ",
                  COLUMN  19, mr_vdp_audit_desc.dat_alteracao USING "dd/mm/yy",
                  COLUMN  28, mr_vdp_audit_desc.hor_alteracao ,
                  COLUMN  37, mr_vdp_audit_desc.usuario_alt,
                  COLUMN  49, mr_vdp_audit_desc.tip_alteracao,
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_1 USING "#&.&&",
                  COLUMN  57, mr_vdp_audit_desc.descricao_motivo
            PRINT COLUMN  16, "02 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_2 USING "#&.&&"
            PRINT COLUMN  16, "03 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_3 USING "#&.&&"
            PRINT COLUMN  16, "04 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_4 USING "#&.&&"
            PRINT COLUMN  16, "05 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_5 USING "#&.&&"
            PRINT COLUMN  16, "06 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_6 USING "#&.&&"
            PRINT COLUMN  16, "07 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_7 USING "#&.&&"
            PRINT COLUMN  16, "08 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_8 USING "#&.&&"
            PRINT COLUMN  16, "09 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_9 USING "#&.&&"
            PRINT COLUMN  16, "10 ",
                  COLUMN  51, mr_vdp_audit_desc.perc_desconto_10 USING "#&.&&"

      END IF


   ON LAST ROW
      LET m_last_row = TRUE

   PAGE TRAILER
      IF m_last_row = true THEN
         PRINT "* * * ULTIMA FOLHA * * *";
         PRINT log5211_termino_impressao() CLIPPED
         LET m_last_row = FALSE
      ELSE
         PRINT " "
      END IF

 END REPORT


#-----------------------------------------------------#
 FUNCTION vdpe0009_retorna_total_registros(l_sql_stmt)
#-----------------------------------------------------#

   DEFINE l_sql_stmt VARCHAR(50000),
          l_total    SMALLINT,
          l_status   SMALLINT

   LET l_total  = 0
   LET l_status = TRUE

   WHENEVER ERROR CONTINUE
   PREPARE var_query3 FROM l_sql_stmt
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('PREPARE','var_query3')
      RETURN l_total,FALSE
   END IF

   WHENEVER ERROR CONTINUE
   DECLARE cq_total_registros CURSOR WITH HOLD FOR var_query3
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('LEITURA','cq_total_registros')
      RETURN l_total,FALSE
   END IF

   WHENEVER ERROR CONTINUE
   OPEN cq_total_registros
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('OPEN','cq_total_registros')
      RETURN l_total,FALSE
   END IF

   WHENEVER ERROR CONTINUE
   FETCH cq_total_registros INTO l_total
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('FETCH','cq_total_registros')
      LET l_status = FALSE
   END IF

   WHENEVER ERROR CONTINUE
   CLOSE cq_total_registros
   FREE cq_total_registros
   WHENEVER ERROR STOP

   RETURN l_total,l_status

 END FUNCTION


#--------------------------------------------------------#
 FUNCTION vdpe0009_seta_impressao_externa()
#--------------------------------------------------------#

  LET m_impressao_externa = TRUE

END FUNCTION


#--------------------------------#
 FUNCTION vdpe0009_version_info()
#--------------------------------#

RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/kanaflex_sa_industria_de_plasticos/vendas/vendas/programas/vdpe0009.4gl $|$Revision: 3 $|$Date: 14/08/12 15:46 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION
