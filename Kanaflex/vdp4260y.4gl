###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP4260                                               #
# OBJETIVO: EPL DE CONSULTA DE PEDIDOS                            #
# AUTOR...: LUCIANA NAOMI KANEKO                                  #
# DATA....: 26/01/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS
  DEFINE g_ies_grafico       SMALLINT

END GLOBALS

   DEFINE m_empresa         LIKE empresa.cod_empresa
   DEFINE sql_stmt          CHAR(3000)
   DEFINE where_clause      CHAR(1500)

  DEFINE m_user                    LIKE usuarios.cod_usuario,
         m_comando                 CHAR(080),
         m_sc_curr                 SMALLINT,
         m_curr                    SMALLINT,
         m_trans_nota_fiscal       LIKE fat_nf_mestre.trans_nota_fiscal,
         m_nom_tela                CHAR(80),
         m_versao_funcao           CHAR(18),
         m_status                  SMALLINT,
         m_parte                   SMALLINT,
         m_texto_parte1            CHAR(026),
         m_texto_parte2            CHAR(026),
         m_texto_parte3            CHAR(026),
         m_tip_ord_consulta        CHAR(01)

  DEFINE mr_pedidos1          RECORD
                             cod_empresa       LIKE pedidos.cod_empresa,
                             num_pedido        LIKE pedidos.num_pedido,
                             dat_pedido        LIKE pedidos.dat_pedido,
                             cod_cliente       LIKE pedidos.cod_cliente,
                             ies_sit_pedido    LIKE pedidos.ies_sit_pedido,
                             cod_repres        LIKE pedidos.cod_repres,
                             cod_repres_adic   LIKE pedidos.cod_repres_adic,
                             ies_comissao      LIKE pedidos.ies_comissao,
                             parametro_texto   LIKE ped_info_compl.parametro_texto,
                             pct_comissao      LIKE pedidos.pct_comissao,
                             num_pedido_repres LIKE pedidos.num_pedido_repres,
                             dat_emis_repres   LIKE pedidos.dat_emis_repres,
                             num_pedido_cli    LIKE pedidos.num_pedido_cli,
                             cod_nat_oper      LIKE pedidos.cod_nat_oper,
                             cod_transpor      LIKE pedidos.cod_transpor,
                             cod_consig        LIKE pedidos.cod_consig,
                             cod_cnd_pgto      LIKE pedidos.cod_cnd_pgto,
                             forma_pagto       LIKE ped_compl_pedido.forma_pagto,
                             cod_tip_venda     LIKE pedidos.cod_tip_venda,
                             cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
                             nom_cliente       LIKE clientes.nom_cliente,
                             den_cidade        LIKE cidades.den_cidade,
                             cod_uni_feder     LIKE cidades.cod_uni_feder,
                             raz_social        LIKE representante.raz_social,
                             raz_social_adic   LIKE representante.raz_social,
                             den_nat_oper      LIKE nat_operacao.den_nat_oper,
                             den_transpor      LIKE transport.den_transpor,
                             den_consig        LIKE transport.den_transpor,
                             den_cnd_pgto      LIKE cond_pgto.den_cnd_pgto,
                             den_tip_venda     LIKE tipo_venda.den_tip_venda,
                             den_tip_carteira  LIKE tipo_carteira.den_tip_carteira,
                             des_forma_pagto    CHAR(008)
                             END RECORD
  DEFINE mr_pedidos1r         RECORD
                             cod_empresa       LIKE pedidos.cod_empresa,
                             num_pedido        LIKE pedidos.num_pedido,
                             dat_pedido        LIKE pedidos.dat_pedido,
                             cod_cliente       LIKE pedidos.cod_cliente,
                             ies_sit_pedido    LIKE pedidos.ies_sit_pedido,
                             cod_repres        LIKE pedidos.cod_repres,
                             cod_repres_adic   LIKE pedidos.cod_repres_adic,
                             ies_comissao      LIKE pedidos.ies_comissao,
                             parametro_texto   LIKE ped_info_compl.parametro_texto,
                             pct_comissao      LIKE pedidos.pct_comissao,
                             num_pedido_repres LIKE pedidos.num_pedido_repres,
                             dat_emis_repres   LIKE pedidos.dat_emis_repres,
                             num_pedido_cli    LIKE pedidos.num_pedido_cli,
                             cod_nat_oper      LIKE pedidos.cod_nat_oper,
                             cod_transpor      LIKE pedidos.cod_transpor,
                             cod_consig        LIKE pedidos.cod_consig,
                             cod_cnd_pgto      LIKE pedidos.cod_cnd_pgto,
                             forma_pagto       LIKE ped_compl_pedido.forma_pagto,
                             cod_tip_venda     LIKE pedidos.cod_tip_venda,
                             cod_tip_carteira  LIKE pedidos.cod_tip_carteira,
                             nom_cliente       LIKE clientes.nom_cliente,
                             den_cidade        LIKE cidades.den_cidade,
                             cod_uni_feder     LIKE cidades.cod_uni_feder,
                             raz_social        LIKE representante.raz_social,
                             raz_social_adic   LIKE representante.raz_social,
                             den_nat_oper      LIKE nat_operacao.den_nat_oper,
                             den_transpor      LIKE transport.den_transpor,
                             den_consig        LIKE transport.den_transpor,
                             den_cnd_pgto      LIKE cond_pgto.den_cnd_pgto,
                             den_tip_venda     LIKE tipo_venda.den_tip_venda,
                             den_tip_carteira  LIKE tipo_carteira.den_tip_carteira,
                             des_forma_pagto   CHAR(008)
                             END RECORD

  DEFINE mr_ped_itens1        RECORD
                             cod_empresa        LIKE ped_itens.cod_empresa,
                             num_pedido         LIKE ped_itens.num_pedido,
                             num_sequencia      LIKE ped_itens.num_sequencia,
                             cod_item           LIKE ped_itens.cod_item,
                             den_item           LIKE item.den_item,
                             pre_unit           LIKE ped_itens.pre_unit,
                             pct_desc_adic      LIKE ped_itens.pct_desc_adic,
                             pct_desc_bruto     LIKE ped_itens.pct_desc_bruto,
                             val_seguro_unit    LIKE ped_itens.val_seguro_unit,
                             val_frete_unit     LIKE ped_itens.val_frete_unit,
                             qtd_pecas_solic    LIKE ped_itens.qtd_pecas_solic,
                             qtd_pecas_atend    LIKE ped_itens.qtd_pecas_atend,
                             qtd_pecas_cancel   LIKE ped_itens.qtd_pecas_cancel,
                             qtd_pecas_reserv   LIKE ped_itens.qtd_pecas_reserv,
                             qtd_pecas_romaneio LIKE ped_itens.qtd_pecas_romaneio,
                             prz_entrega        LIKE ped_itens.prz_entrega,
                             parametro_dat      LIKE  vdp_ped_item_compl.parametro_dat
                             END RECORD

  DEFINE ar_ped_itens   ARRAY[1000] OF RECORD
                        num_pedido        LIKE  ped_itens.num_pedido,
                        num_sequencia     LIKE  ped_itens.num_sequencia,
                        cod_item          LIKE  ped_itens.cod_item,
                        den_item    LIKE  item.den_item,
                        pre_unit          LIKE  ped_itens.pre_unit,
                        pct_desc_adic     LIKE  ped_itens.pct_desc_adic,
                        pct_desc_bruto    LIKE  ped_itens.pct_desc_bruto,
                        val_seguro_unit   LIKE  ped_itens.val_seguro_unit,
                        val_frete_unit    LIKE  ped_itens.val_frete_unit,
                        qtd_pecas_solic   LIKE  ped_itens.qtd_pecas_solic,
                        qtd_pecas_atend   LIKE  ped_itens.qtd_pecas_atend,
                        qtd_pecas_cancel  LIKE  ped_itens.qtd_pecas_cancel,
                        qtd_pecas_reserv  LIKE  ped_itens.qtd_pecas_reserv,
                        qtd_pecas_romaneio LIKE ped_itens.qtd_pecas_romaneio,
                        saldo             LIKE  ped_itens.qtd_pecas_solic,
                        prz_entrega       LIKE  ped_itens.prz_entrega,
                        parametro_dat     LIKE  ped_itens.prz_entrega,
                        ies_texto         CHAR(01),
                        pre_liquido       LIKE  ped_itens.pre_unit,
                        pct_desc_total    DECIMAL(6,2)
                        END RECORD


 #----------------------------------------------------------#
 FUNCTION vdp4260y_before_open_window_vdp42601()   #os 773477
#----------------------------------------------------------#
  DEFINE l_tela_padrao             SMALLINT

  LET m_empresa             = LOG_getVar("empresa")
  LET m_user                = LOG_getVar("usuario")
  LET m_versao_funcao       = LOG_getVar("versao")

  LET l_tela_padrao  = FALSE

  CALL log130_procura_caminho("vdp42601y") RETURNING m_nom_tela

  CALL LOG_setVar("tela_padrao",l_tela_padrao)
  #EPL Identifica se a tela é padrão
  #EPL Tipo: number(1)
  #EPL Valores: 0-False  1-True

  CALL LOG_setVar("nom_tela",m_nom_tela)
  #EPL Caminho da tela
  #EPL Tipo: char(80)

  RETURN TRUE
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp4260y_before_menu_w_vdp42601()
#-----------------------------------------#

   CALL LOG_setVar("hide_outros",FALSE)

   RETURN TRUE

 END FUNCTION

#--------------------------------#
 FUNCTION vdp4260y_open_window()
#--------------------------------#
   DEFINE l_cod_empresa LIKE empresa.cod_empresa,
          l_cod_cliente LIKE clientes.cod_cliente,
          l_pedido      LIKE pedidos.num_pedido

   DEFINE lr_ped_info_compl    RECORD
          texto_1       CHAR(076),
          texto_2       CHAR(076),
          texto_3       CHAR(076),
          texto_4       CHAR(076)
                               END RECORD

   LET l_cod_empresa = LOG_getVar("empresa")
   LET l_cod_cliente = LOG_getVar("cliente")
   LET l_pedido      = LOG_getVar("pedido")

   IF l_pedido IS NULL THEN
      CALL log0030_mensagem("Consulte pedido previamente. ","excl")
      RETURN
   END IF

   LET m_versao_funcao = "VDPY154-10.02.00p"

   CALL log006_exibe_teclas("01", m_versao_funcao)

   CALL log130_procura_caminho("VDPY154") RETURNING m_nom_tela

   OPEN WINDOW w_vdpy154 AT 2,2 WITH FORM m_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   LET INT_FLAG = FALSE
   INITIALIZE lr_ped_info_compl.* TO NULL

   CALL vdp4260y_carrega_txt_exped(l_pedido, 'ped_inf_cpl')
      RETURNING lr_ped_info_compl.*

   DISPLAY BY NAME lr_ped_info_compl.texto_1,
                   lr_ped_info_compl.texto_2,
                   lr_ped_info_compl.texto_3,
                   lr_ped_info_compl.texto_4

   MENU "OPÇÃO"
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR m_comando
         RUN m_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR m_comando
      COMMAND "Fim"        "Retorna ao menu anterior"
         HELP 008
         EXIT MENU


  #lds COMMAND KEY ("control-F1") "Sobre" "Informações sobre a aplicação (CTRL-F1)."
  #lds CALL LOG_info_sobre(sourceName(),m_versao_funcao)

   END MENU


   CLOSE WINDOW w_vdpy154

 END FUNCTION
#--------------------------------------------#
 FUNCTION vdp4260y_carrega_txt_exped(l_pedido,
                                    l_tabela)
#--------------------------------------------#
     DEFINE l_pedido        LIKE pedidos.num_pedido,
            l_tabela        CHAR(014)

     DEFINE l_texto         CHAR(026),
            l_campo         CHAR(024),
            l_linha         CHAR(001),
            l_sql_stmt      CHAR(1000)

     DEFINE lr_txt_exped    RECORD
                                texto_1   CHAR(076),
                                texto_2   CHAR(076),
                                texto_3   CHAR(076),
                                texto_4   CHAR(076)
                            END RECORD

     LET m_parte = 0
     INITIALIZE m_texto_parte1, m_texto_parte2, m_texto_parte3 TO NULL

     IF  l_tabela = "w_ped_inf_cpl" THEN
         LET l_sql_stmt = "SELECT texto, campo FROM w_ped_inf_cpl"
     ELSE
         LET l_sql_stmt = "SELECT parametro_texto, campo FROM ped_info_compl"
     END IF

     LET l_sql_stmt = l_sql_stmt CLIPPED,
                    " WHERE empresa = '", m_empresa CLIPPED, "'",
                      " AND pedido  = ", l_pedido,
                      " AND campo   LIKE 'OBSERVACAO EXPEDICAO%' ",
                    " ORDER BY campo "

     WHENEVER ERROR CONTINUE
     PREPARE l_var_query FROM l_sql_stmt
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("PREPARE", "VAR_QUERY")
     END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_carrega_texto CURSOR WITH HOLD FOR l_var_query
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("DECLARE", "CQ_CARREGA_TEXTO")
     END IF

     WHENEVER ERROR CONTINUE
         OPEN cq_carrega_texto
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         IF  SQLCA.sqlcode = NOTFOUND THEN
             RETURN lr_txt_exped.*
         ELSE
             CALL log003_err_sql('DECLARE','CQ_CARREGA_TEXTO')
         END IF
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_carrega_texto INTO l_texto, l_campo
     WHENEVER ERROR STOP
         IF  SQLCA.sqlcode <> 0   AND
             SQLCA.sqlcode <> 100 THEN
             CALL log003_err_sql('DECLARE','CQ_CARREGA_TEXTO')
         END IF

         LET l_linha = l_campo[22,22]

         CASE l_linha
              WHEN '1'
                   CALL vdp4260y_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_1
              WHEN '2'
                   CALL vdp4260y_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_2
              WHEN '3'
                   CALL vdp4260y_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_3
              WHEN '4'
                   CALL vdp4260y_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_4
         END CASE

     END FOREACH

     RETURN lr_txt_exped.*

 END FUNCTION

#------------------------------------------------#
 FUNCTION vdp4260y_carrega_variavel_texto(l_texto)
#------------------------------------------------#
     DEFINE l_texto         CHAR(026),
            l_texto_total   CHAR(076)

     INITIALIZE l_texto_total TO NULL

     LET m_parte = m_parte + 1

     CASE m_parte
          WHEN 1
               LET m_texto_parte1 = l_texto

          WHEN 2
               LET m_texto_parte2 = l_texto

          WHEN 3
               LET m_texto_parte3 = l_texto
               LET l_texto_total = m_texto_parte1, m_texto_parte2, m_texto_parte3
               LET m_parte = 0
     END CASE

     RETURN l_texto_total

 END FUNCTION

#------------------------------------------------#
 FUNCTION vdp4260y_before_construct_mestre()
#------------------------------------------------#
   DEFINE l_cod_empresa LIKE empresa.cod_empresa,
          l_cod_cliente LIKE clientes.cod_cliente,
          l_pedido      LIKE pedidos.num_pedido

DEFINE l_cod_repres       LIKE pedido_comis.cod_repres_3,
       l_forma_pgto       LIKE ped_compl_pedido.forma_pagto

   LET l_cod_empresa = LOG_getVar("empresa")
   LET l_cod_cliente = LOG_getVar("cliente")
   LET l_pedido      = LOG_getVar("pedido")
   LET m_tip_ord_consulta = LOG_getVar("tip_ord_consulta")

  LET mr_pedidos1r.* = mr_pedidos1.*
  LET int_flag = 0
  CALL log006_exibe_teclas("02 03 07", m_versao_funcao)
  INITIALIZE mr_pedidos1.parametro_texto TO NULL

       CONSTRUCT BY NAME where_clause ON pedidos.cod_empresa,
                                         pedidos.num_pedido,
                                         pedidos.ies_sit_pedido,
                                         pedidos.dat_pedido,
                                         pedidos.cod_cliente,
                                         pedidos.ies_comissao,
                                         ped_info_compl.parametro_texto,
                                         pedidos.cod_repres,
                                         pedidos.pct_comissao,
                                         pedidos.cod_repres_adic,
                                         pedido_comis.pct_comissao_2,
                                         pedido_comis.cod_repres_3,
                                         pedido_comis.pct_comissao_3,
                                         pedidos.num_pedido_repres,
                                         pedidos.dat_emis_repres,
                                         pedidos.num_pedido_cli,
                                         pedidos.cod_nat_oper,
                                         pedidos.cod_transpor,
                                         pedidos.cod_consig,
                                         pedidos.cod_cnd_pgto ,
                                         ped_compl_pedido.forma_pagto,
                                         pedidos.cod_tip_venda,
                                         pedidos.cod_tip_carteira

           BEFORE FIELD cod_empresa
                  CALL vdp4260y_ativa_zoom(FALSE)

           BEFORE FIELD ies_sit_pedido
                  CALL vdp4260y_ativa_zoom(TRUE)

           AFTER  FIELD ies_sit_pedido
                  CALL vdp4260y_ativa_zoom(FALSE)

           BEFORE FIELD cod_cliente
                  CALL vdp4260y_ativa_zoom(TRUE)

           AFTER  FIELD cod_cliente
                  CALL vdp4260y_ativa_zoom(FALSE)

           AFTER  FIELD parametro_texto
                  LET mr_pedidos1.parametro_texto = GET_FLDBUF(parametro_texto)

           ON KEY (control-z, f4)
             CALL vdp4260y_zoom()

           AFTER CONSTRUCT
              CALL vdp4260y_ativa_zoom(FALSE)
              LET l_cod_repres = get_fldbuf(cod_repres_3)
              LET l_forma_pgto = get_fldbuf(forma_pagto)

       END CONSTRUCT


       LET sql_stmt = "SELECT pedidos.cod_empresa,     pedidos.num_pedido,        ",
                            " pedidos.dat_pedido,      pedidos.cod_cliente, pedidos.ies_sit_pedido,      ",
                            " pedidos.cod_repres,      pedidos.cod_repres_adic,   ",
                            " pedidos.ies_comissao,  ",
                            " pedidos.pct_comissao,    pedidos.num_pedido_repres, ",
                            " pedidos.dat_emis_repres, pedidos.num_pedido_cli,    ",
                            " pedidos.cod_nat_oper,    pedidos.cod_transpor,      ",
                            " pedidos.cod_consig,      pedidos.cod_cnd_pgto,  ped_compl_pedido.forma_pagto,  ",
                            " pedidos.cod_tip_venda,   pedidos.cod_tip_carteira   ",
                            " FROM pedidos "

       IF  l_cod_repres IS NULL OR 
           l_cod_repres = " "   THEN
           LET sql_stmt = sql_stmt CLIPPED, 
                " LEFT OUTER JOIN pedido_comis ",
                "  ON pedido_comis.cod_empresa = pedidos.cod_empresa ",
                " AND pedido_comis.num_pedido = pedidos.num_pedido "       
       ELSE
           LET sql_stmt = sql_stmt CLIPPED, 
                " INNER JOIN pedido_comis ",
                "  ON pedido_comis.cod_empresa = pedidos.cod_empresa ",
                " AND pedido_comis.num_pedido = pedidos.num_pedido "       
       END IF

       
       IF  l_forma_pgto IS NULL OR
           l_forma_pgto = " " THEN
           LET sql_stmt = sql_stmt CLIPPED, 
                " LEFT OUTER JOIN ped_compl_pedido ",
                "  ON ped_compl_pedido.empresa = pedidos.cod_empresa ",
                " AND ped_compl_pedido.pedido = pedidos.num_pedido "
       ELSE
           LET sql_stmt = sql_stmt CLIPPED, 
                " INNER JOIN ped_compl_pedido ",
                "  ON ped_compl_pedido.empresa = pedidos.cod_empresa ",
                " AND ped_compl_pedido.pedido = pedidos.num_pedido "
       END IF

       IF  mr_pedidos1.parametro_texto <> ' '      AND
           mr_pedidos1.parametro_texto IS NOT NULL THEN
           LET sql_stmt = sql_stmt CLIPPED,
               " INNER JOIN ped_info_compl ",
               "  ON ped_info_compl.empresa = pedidos.cod_empresa ",
               " AND ped_info_compl.pedido =  pedidos.num_pedido ",
               " AND ped_info_compl.campo = 'linha_produto' "
       END IF
       
       LET sql_stmt = sql_stmt CLIPPED," WHERE ", where_clause CLIPPED
      

       IF m_tip_ord_consulta = 1 THEN
          LET sql_stmt = sql_stmt CLIPPED, " ORDER BY pedidos.dat_pedido, pedidos.num_pedido "
       ELSE
          IF m_tip_ord_consulta = 2 THEN
             LET sql_stmt = sql_stmt CLIPPED, " ORDER BY pedidos.dat_pedido desc, pedidos.num_pedido desc"
          ELSE
             IF m_tip_ord_consulta = 3 THEN
                LET sql_stmt = sql_stmt CLIPPED, " ORDER BY pedidos.num_pedido"
             ELSE
                LET sql_stmt = sql_stmt CLIPPED, " ORDER BY pedidos.num_pedido desc"
             END IF
          END IF
       END IF

       CALL LOG_setVar("sql_stmt",sql_stmt)
       #EPL Sql preparado
       #EPL TIPO: char(3000)

RETURN TRUE
END FUNCTION

#------------------------------------------------#
 FUNCTION vdp4260y_before_exibe_dados()
#------------------------------------------------#
   DEFINE l_cod_empresa LIKE empresa.cod_empresa,
          l_cod_cliente LIKE clientes.cod_cliente,
          l_pedido      LIKE pedidos.num_pedido,
          l_parametro_texto LIKE ped_info_compl.parametro_texto


   LET l_cod_empresa = LOG_getVar("empresa")
   LET l_cod_cliente = LOG_getVar("cliente")
   LET l_pedido      = LOG_getVar("pedido")

   WHENEVER ERROR CONTINUE
   SELECT parametro_texto
   INTO l_parametro_texto
   FROM ped_info_compl
   WHERE empresa = l_cod_empresa
   AND   pedido  = l_pedido
   AND   campo   = 'linha_produto'
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      LET l_parametro_texto = " "
   END IF

   DISPLAY l_parametro_texto TO parametro_texto

RETURN TRUE
END FUNCTION

#------------------------------------#
FUNCTION vdp4260y_ativa_zoom(l_ativa)
#------------------------------------#
 DEFINE l_ativa SMALLINT
 IF l_ativa THEN
    IF g_ies_grafico THEN
       #Ativação do botão de zoom no ambiente gráfico
       --# CALL fgl_dialog_setkeylabel('control-z','Zoom')
    ELSE
       #Apresentação fixa no canto superior direito da tela
       DISPLAY "( Zoom )" AT 3,60
    END IF
 ELSE
    IF g_ies_grafico THEN
       #Desativação do botão de zoom no ambiente gráfico
       --# CALL fgl_dialog_setkeylabel('control-z',NULL)
    ELSE
       #Retirar texto fixo de zoom no canto superior direito da tela
       DISPLAY "--------" AT 3,60
    END IF
 END IF
 END FUNCTION

#-------------------------#
 FUNCTION vdp4260y_zoom()
#------------------------#
DEFINE  l_cod_cliente      LIKE clientes.cod_cliente,
        l_ies_sit_pedido   LIKE pedidos.ies_sit_pedido,
        l_ies_finalidade   LIKE pedidos.ies_finalidade,
        l_ies_frete        LIKE pedidos.ies_frete,
        l_ies_preco        LIKE pedidos.ies_preco,
        l_ies_tip_entrega  LIKE pedidos.ies_tip_entrega,
        l_ies_aceite       LIKE pedidos.ies_aceite
 CASE
    WHEN infield(cod_cliente)
         LET l_cod_cliente = vdp372_popup_cliente()
         CURRENT WINDOW IS w_vdp42601
         IF l_cod_cliente IS NOT NULL THEN
            LET mr_pedidos1.cod_cliente = l_cod_cliente
            DISPLAY mr_pedidos1.cod_cliente TO cod_cliente
         END IF

    WHEN infield(ies_sit_pedido)
         LET l_ies_sit_pedido = log0830_list_box(12, 20,'N {Normal}, F {Liberacao Financeira}, C {Liberacao Comercial}, A {Liberacao Comerc e Financ}, S {Suspenso}, B {Bloqueado}, P {Pedido Provisorio}, 9 {Cancelado}')
         CURRENT WINDOW IS w_vdp42601
         IF l_ies_sit_pedido IS NOT NULL THEN
            LET mr_pedidos1.ies_sit_pedido = l_ies_sit_pedido
            DISPLAY mr_pedidos1.ies_sit_pedido TO ies_sit_pedido
         END IF

 END CASE

END FUNCTION

 #----------------------------------------------------------#
 FUNCTION vdp4260y_before_open_window_vdp42603()   #os 773477
#----------------------------------------------------------#
  DEFINE l_tela_padrao             SMALLINT

  LET m_empresa             = LOG_getVar("empresa")
  LET m_user                = LOG_getVar("usuario")
  LET m_versao_funcao       = LOG_getVar("versao")

  LET l_tela_padrao  = FALSE

  CALL log130_procura_caminho("vdp42603y") RETURNING m_nom_tela

  CALL LOG_setVar("tela_padrao_2",l_tela_padrao)
  #EPL Identifica se a tela é padrão
  #EPL Tipo: number(1)
  #EPL Valores: 0-False  1-True

  CALL LOG_setVar("nom_tela",m_nom_tela)
  #EPL Caminho da tela
  #EPL Tipo: char(80)

  RETURN TRUE
END FUNCTION

#------------------------------------------------#
 FUNCTION vdp4260y_before_construct_itens()
#------------------------------------------------#
   DEFINE l_empresa LIKE empresa.cod_empresa,
          l_pedido      LIKE pedidos.num_pedido

   LET INT_FLAG = 0
   LET l_empresa = LOG_getVar("empresa")
   LET l_pedido      = LOG_getVar("pedido")
   LET m_tip_ord_consulta = LOG_getVar("tip_ord_consulta")


   IF l_pedido = 0 OR l_pedido IS NULL THEN
           CONSTRUCT BY NAME where_clause ON ped_itens.cod_empresa,
                                             ped_itens.num_pedido,
                                             ped_itens.num_sequencia,
                                             ped_itens.cod_item,
                                             ped_itens.pre_unit,
                                             ped_itens.pct_desc_adic,
                                             ped_itens.pct_desc_bruto,
                                             ped_itens.val_seguro_unit,
                                             ped_itens.val_frete_unit,
                                             ped_itens.qtd_pecas_solic,
                                             ped_itens.qtd_pecas_atend,
                                             ped_itens.qtd_pecas_cancel,
                                             ped_itens.qtd_pecas_reserv,
                                             ped_itens.qtd_pecas_romaneio,
                                             ped_itens.prz_entrega,
                                             vdp_ped_item_compl.parametro_dat
           AFTER  FIELD parametro_dat
                  LET mr_ped_itens1.parametro_dat = GET_FLDBUF(parametro_dat)

           ON KEY (control-z, f4)
              CALL vdp4260y_zoom()
           END CONSTRUCT
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              CURRENT WINDOW IS w_vdp42601
              RETURN
         ELSE
              MESSAGE "Aguarde processamento... "
         END IF
         LET sql_stmt = " SELECT ped_itens.cod_empresa, ",
                    " ped_itens.num_pedido, ped_itens.num_sequencia, ",
                    " ped_itens.cod_item,   item.den_item,     ",
                    " ped_itens.pre_unit, ped_itens.pct_desc_adic,  ",
                    " ped_itens.pct_desc_bruto, ",
                    " ped_itens.val_seguro_unit, ped_itens.val_frete_unit,  ",
                    " ped_itens.qtd_pecas_solic, ped_itens.qtd_pecas_atend, ",
                    " ped_itens.qtd_pecas_cancel, ped_itens.qtd_pecas_reserv,",
                    " ped_itens.qtd_pecas_romaneio, ",
                    " ped_itens.prz_entrega FROM ped_itens,  item "
         
         IF mr_ped_itens1.parametro_dat IS NOT NULL AND
            mr_ped_itens1.parametro_dat <> '31/12/1899' AND
            mr_ped_itens1.parametro_dat <> " " THEN
            LET sql_stmt = sql_stmt CLIPPED," ,vdp_ped_item_compl"
         END IF

         LET sql_stmt = sql_stmt CLIPPED,
                    " WHERE ", where_clause CLIPPED,
                    "  AND item.cod_empresa = ped_itens.cod_empresa",
                    "  AND item.cod_item    = ped_itens.cod_item"," "

         IF mr_ped_itens1.parametro_dat IS NOT NULL AND
            mr_ped_itens1.parametro_dat <> '31/12/1899' AND
            mr_ped_itens1.parametro_dat <> " " THEN
            LET sql_stmt = sql_stmt CLIPPED,
                " and ped_itens.cod_empresa = vdp_ped_item_compl.empresa ",
                " and ped_itens.num_pedido  = vdp_ped_item_compl.pedido ",
                " and ped_itens.num_sequencia = vdp_ped_item_compl.sequencia_pedido ",
                " and vdp_ped_item_compl.campo = 'data_cliente' "
         END IF

         IF m_tip_ord_consulta = 1 OR
            m_tip_ord_consulta = 3 THEN
            LET sql_stmt = sql_stmt CLIPPED, " ORDER BY ped_itens.num_pedido , ped_itens.num_sequencia, ped_itens.cod_item"
         ELSE
            LET sql_stmt = sql_stmt CLIPPED, " ORDER BY ped_itens.num_pedido desc , ped_itens.num_sequencia, ped_itens.cod_item"
         END IF
    ELSE
          LET sql_stmt = " SELECT ped_itens.cod_empresa, ",
                     " ped_itens.num_pedido, ped_itens.num_sequencia, ",
                     " ped_itens.cod_item,   item.den_item,     ",
                     " ped_itens.pre_unit, ped_itens.pct_desc_adic,  ",
                     " ped_itens.pct_desc_bruto, ",
                     " ped_itens.val_seguro_unit, ped_itens.val_frete_unit,  ",
                     " ped_itens.qtd_pecas_solic, ped_itens.qtd_pecas_atend, ",
                     " ped_itens.qtd_pecas_cancel, ped_itens.qtd_pecas_reserv,",
                     " ped_itens.qtd_pecas_romaneio, ",
                     " ped_itens.prz_entrega FROM ped_itens, OUTER item "
         
         IF mr_ped_itens1.parametro_dat IS NOT NULL AND
            mr_ped_itens1.parametro_dat <> '31/12/1899' AND
            mr_ped_itens1.parametro_dat <> " " THEN
            LET sql_stmt = sql_stmt CLIPPED," ,vdp_ped_item_compl"
         END IF

         LET sql_stmt = sql_stmt CLIPPED,
               " WHERE ped_itens.cod_empresa = \"", l_empresa ,"\"",
                     "  AND ped_itens.num_pedido  = ", l_pedido,
                     "  AND item.cod_empresa = ped_itens.cod_empresa",
                     "  AND item.cod_item    = ped_itens.cod_item"," "

         IF mr_ped_itens1.parametro_dat IS NOT NULL AND
            mr_ped_itens1.parametro_dat <> '31/12/1899' AND
            mr_ped_itens1.parametro_dat <> " " THEN
            LET sql_stmt = sql_stmt CLIPPED,
                " and ped_itens.cod_empresa = vdp_ped_item_compl.empresa ",
                " and ped_itens.num_pedido  = vdp_ped_item_compl.pedido ",
                " and ped_itens.num_sequencia = vdp_ped_item_compl.sequencia_pedido ",
                " and vdp_ped_item_compl.campo = 'data_cliente' "
         END IF

          IF m_tip_ord_consulta = 1 OR
             m_tip_ord_consulta = 3 THEN
             LET sql_stmt = sql_stmt CLIPPED, " ORDER BY ped_itens.num_pedido , ped_itens.num_sequencia, ped_itens.cod_item"
          ELSE
             LET sql_stmt = sql_stmt CLIPPED, " ORDER BY ped_itens.num_pedido desc , ped_itens.num_sequencia, ped_itens.cod_item"
          END IF
    END IF

       CALL LOG_setVar("sql_stmt",sql_stmt)
       #EPL Sql preparado
       #EPL TIPO: char(3000)

RETURN TRUE
END FUNCTION

#------------------------------------------------#
 FUNCTION vdp4260y_before_display_array_itens()
#------------------------------------------------#
   DEFINE l_empresa LIKE empresa.cod_empresa,
          l_pedido      LIKE pedidos.num_pedido,
          l_ind         SMALLINT,
          l_qtd_array   SMALLINT

   LET INT_FLAG = 0
   LET l_empresa     = LOG_getVar("empresa")
   LET l_pedido      = LOG_getVar("pedido")
   LET l_qtd_array   = LOG_getVar("qtd_array")

   FOR l_ind = 1 TO l_qtd_array
       CALL vdp4260_get_ped_itens(l_ind)
         RETURNING ar_ped_itens[l_ind].num_pedido,
                   ar_ped_itens[l_ind].num_sequencia,
                   ar_ped_itens[l_ind].cod_item,
                   ar_ped_itens[l_ind].den_item,
                   ar_ped_itens[l_ind].pre_unit,
                   ar_ped_itens[l_ind].pct_desc_adic,
                   ar_ped_itens[l_ind].pct_desc_bruto,
                   ar_ped_itens[l_ind].val_seguro_unit,
                   ar_ped_itens[l_ind].val_frete_unit,
                   ar_ped_itens[l_ind].qtd_pecas_solic,
                   ar_ped_itens[l_ind].qtd_pecas_atend,
                   ar_ped_itens[l_ind].qtd_pecas_cancel,
                   ar_ped_itens[l_ind].qtd_pecas_reserv,
                   ar_ped_itens[l_ind].qtd_pecas_romaneio,
                   ar_ped_itens[l_ind].saldo,
                   ar_ped_itens[l_ind].prz_entrega,
                   ar_ped_itens[l_ind].ies_texto,
                   ar_ped_itens[l_ind].pre_liquido,
                   ar_ped_itens[l_ind].pct_desc_total
       WHENEVER ERROR CONTINUE
       SELECT parametro_dat
       INTO  ar_ped_itens[l_ind].parametro_dat
       FROM  vdp_ped_item_compl
       WHERE empresa          = l_empresa
       AND   pedido           = ar_ped_itens[l_ind].num_pedido
       AND   sequencia_pedido = ar_ped_itens[l_ind].num_sequencia
       AND   campo            = 'data_cliente'
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET ar_ped_itens[l_ind].parametro_dat = " "
       END IF

   END FOR

#  OPEN WINDOW w_vdp42603 AT 2,2 WITH FORM m_nom_tela
#       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

     CALL set_count(l_qtd_array)

     DISPLAY l_empresa TO cod_empresa
#     DISPLAY ARRAY ar_ped_itens TO s_ar_itens.*
     CALL log006_exibe_teclas('01 02 23', m_versao_funcao)
     CURRENT WINDOW IS w_vdp42603

     INPUT ARRAY ar_ped_itens WITHOUT DEFAULTS FROM s_ar_itens.*
        BEFORE ROW
           LET m_curr    = ARR_CURR()
           LET m_sc_curr = SCR_LINE()

        ON KEY (control-t)
           IF log005_seguranca(p_user,"VDP","VDP4260","CO")  THEN
              CALL log120_procura_caminho("VDP2500") RETURNING m_comando
              IF l_empresa IS NOT NULL THEN
                 LET m_comando = m_comando CLIPPED," ",l_empresa," ",ar_ped_itens[m_curr].num_pedido," ",ar_ped_itens[m_curr].num_sequencia," ",1
              END IF
              RUN m_comando
           END IF


       CURRENT WINDOW IS w_vdp42603
     END INPUT

END FUNCTION
#-------------------------------#
 FUNCTION vdp4260y_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdp4260y.4gl $|$Revision: 6 $|$Date: 28/10/11 09:24 $|$Modtime: 31/05/11 11:08 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
