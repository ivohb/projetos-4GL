###PARSER-Não remover esta linha(Framework Logix)###
#-------------------------------------------------------------------#
# PROGRAMA: VDPY154                                                 #
# OBJETIVO: FUNCAO PARA ENTRADA E RETORO DO TEXTO DE OBSERVACAO DE #
#           EXPEDICAO                                               #
# AUTOR...: EDUARDO LUIS PRIM                                       #
# DATA....: 03/12/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

# Função utilizada pelos programas de digitação de pedidos on-line e batch
# (VDP4283/VDP3135) e tambem pelos programas de impressão de pedido interno
# (VDP1361/VDP1362) para entrada e/ou retorno do texto de observação de expedição
#
# Caso seja cliente:
# KANAFLEX (444) - Disponibiliza entrada do texto de observação de expedição.
#
# OUTROS         - Não disponibiliza entrada do texto de observação de expedição.

GLOBALS
  DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
         p_user                   LIKE usuario.nom_usuario,
         g_ies_grafico            SMALLINT,
         p_nom_tela               CHAR(80)
END GLOBALS

    DEFINE m_versao_funcao      CHAR(018)

    DEFINE m_parte              SMALLINT,
           m_texto_parte1       CHAR(026),
           m_texto_parte2       CHAR(026),
           m_texto_parte3       CHAR(026),
           sql_stmt             CHAR(300)

 DEFINE m_usar_modular_texto    SMALLINT,
        m_tipo                  CHAR(11)
 DEFINE mr_ped_info_compl    RECORD
        texto_1   CHAR(070),
        texto_2   CHAR(070),
        texto_3   CHAR(070),
        texto_4   CHAR(070)
 END RECORD

#-----------------------------------#
 FUNCTION vdpy154_consiste_cliente()
#-----------------------------------#

   RETURN TRUE

 END FUNCTION

#-------------------------------------#
 FUNCTION vdpy154_cria_w_ped_inf_cpl()
#-------------------------------------#
     WHENEVER ERROR CONTINUE
      CREATE TEMP TABLE w_ped_inf_cpl (empresa    CHAR(02),
                                       pedido     INTEGER,
                                       campo      CHAR(030),
                                       texto      CHAR(070)) WITH NO LOG;
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         IF  log0030_err_sql_tabela_duplicada() THEN
             WHENEVER ERROR CONTINUE
               DELETE FROM w_ped_inf_cpl
                WHERE 1 = 1
             WHENEVER ERROR STOP
             IF  SQLCA.sqlcode <> 0 THEN
                 CALL log003_err_sql("DELETE","W_PED_INF_CPL")
             END IF
         ELSE
             CALL log003_err_sql("CREATE","W_PED_INF_CPL")
         END IF
     END IF

 END FUNCTION

#--------------------------------------------------------#
 FUNCTION vdpy154_digita_texto_exped(l_num_pedido,l_tipo)
#--------------------------------------------------------#
     DEFINE l_num_pedido         LIKE pedidos.num_pedido,
            l_tipo               CHAR(11)

     DEFINE lr_ped_info_compl    RECORD
                                     texto_1   CHAR(070),
                                     texto_2   CHAR(070),
                                     texto_3   CHAR(070),
                                     texto_4   CHAR(070)
                                 END RECORD

     DEFINE l_contador           SMALLINT,
            l_campo              CHAR(024),
            l_texto_aux          CHAR(070),
            l_texto              CHAR(026),
            l_inicio             SMALLINT,
            l_ind                SMALLINT,
            l_status             SMALLINT

     LET m_versao_funcao = 'VDPY154-10.02.00'
     LET m_tipo = l_tipo
     LET INT_FLAG = FALSE
     CALL log006_exibe_teclas("01 02 07", m_versao_funcao)
     CALL log130_procura_caminho("VDPY154") RETURNING p_nom_tela

     OPEN WINDOW w_vdpy154 AT 2,2 WITH FORM p_nom_tela
          ATTRIBUTE(BORDER, PROMPT LINE LAST, MESSAGE LINE LAST)

     IF l_tipo = 'MODIFICACAO' THEN
        LET INT_FLAG = FALSE
        INITIALIZE lr_ped_info_compl.* TO NULL

        CALL vdpy154_carrega_txt_exped(l_num_pedido, 'ped_info_compl')
           RETURNING lr_ped_info_compl.*

        IF m_usar_modular_texto IS NOT NULL AND
           m_usar_modular_texto THEN
           LET lr_ped_info_compl.* = mr_ped_info_compl.*
        END IF

        DISPLAY BY NAME lr_ped_info_compl.texto_1,
                        lr_ped_info_compl.texto_2,
                        lr_ped_info_compl.texto_3,
                        lr_ped_info_compl.texto_4

        MENU "OPCAO"
           COMMAND "Modificar"    "Modifica texto expedição"
              MESSAGE ""
              CALL vdpy154_modificao(l_num_pedido, lr_ped_info_compl.*) RETURNING l_status
              LET lr_ped_info_compl.* = mr_ped_info_compl.*
           COMMAND "Fim"        "Retorna ao Menu Anterior"
              EXIT MENU
        END MENU

        CLOSE WINDOW w_vdpy154

        RETURN TRUE
     ELSE
        LET INT_FLAG = FALSE
        INITIALIZE lr_ped_info_compl.* TO NULL

     CALL vdpy154_carrega_txt_exped(l_num_pedido, 'w_ped_inf_cpl')
           RETURNING lr_ped_info_compl.*

        IF m_usar_modular_texto IS NOT NULL AND
           m_usar_modular_texto THEN
           LET lr_ped_info_compl.* = mr_ped_info_compl.*
        END IF

        INPUT BY NAME lr_ped_info_compl.texto_1,
                      lr_ped_info_compl.texto_2,
                      lr_ped_info_compl.texto_3,
                      lr_ped_info_compl.texto_4 WITHOUT DEFAULTS

        CLOSE WINDOW w_vdpy154

        IF  NOT INT_FLAG THEN
            IF  NOT vdpy154_processa_gravacao_w_ped_inf_cpl(l_num_pedido,
                                                            lr_ped_info_compl.texto_1,
                                                            lr_ped_info_compl.texto_2,
                                                            lr_ped_info_compl.texto_3,
                                                            lr_ped_info_compl.texto_4) THEN
                RETURN FALSE
            END IF
            LET mr_ped_info_compl.* = lr_ped_info_compl.*
        ELSE
            ERROR " Inclusão de texto cancelada "
            LET INT_FLAG = FALSE
            RETURN FALSE
        END IF

        RETURN TRUE
     END IF

 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION vdpy154_modificao(l_num_pedido, l_texto_1,l_texto_2,
                                          l_texto_3,l_texto_4)
#-------------------------------------------------------------#
     DEFINE l_num_pedido         LIKE pedidos.num_pedido

     DEFINE l_texto_1   CHAR(070),
            l_texto_2   CHAR(070),
            l_texto_3   CHAR(070),
            l_texto_4   CHAR(070)

     INPUT l_texto_1,
           l_texto_2,
           l_texto_3,
           l_texto_4 WITHOUT DEFAULTS
      FROM texto_1,
           texto_2,
           texto_3,
           texto_4

     IF  NOT INT_FLAG THEN
         IF  NOT vdpy154_processa_gravacao_w_ped_inf_cpl(l_num_pedido,
                                                         l_texto_1,
                                                         l_texto_2,
                                                         l_texto_3,
                                                         l_texto_4) THEN
             CALL log0030_mensagem( " Erro na alteração ","excl")
             RETURN FALSE
         END IF
         LET mr_ped_info_compl.texto_1 = l_texto_1
         LET mr_ped_info_compl.texto_2 = l_texto_2
         LET mr_ped_info_compl.texto_3 = l_texto_3
         LET mr_ped_info_compl.texto_4 = l_texto_4
         DISPLAY BY NAME mr_ped_info_compl.texto_1,
                         mr_ped_info_compl.texto_2,
                         mr_ped_info_compl.texto_3,
                         mr_ped_info_compl.texto_4
         CALL log0030_mensagem( 'Modificacao efetuada com sucesso.','excl')
     ELSE
         CALL log0030_mensagem( " Inclusão de texto cancelada ","excl")
         LET INT_FLAG = FALSE
         RETURN FALSE
     END IF

     RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION vdpy154_carrega_txt_exped(l_pedido,
                                    l_tabela)
#--------------------------------------------#
     DEFINE l_pedido        LIKE pedidos.num_pedido,
            l_tabela        CHAR(014)

     DEFINE l_texto         CHAR(070),
            l_campo         CHAR(024),
            l_linha         CHAR(001)

     DEFINE lr_txt_exped    RECORD
                                texto_1   CHAR(070),
                                texto_2   CHAR(070),
                                texto_3   CHAR(070),
                                texto_4   CHAR(070)
                            END RECORD

     LET m_parte = 0
     INITIALIZE m_texto_parte1, m_texto_parte2, m_texto_parte3 TO NULL
     INITIALIZE lr_txt_exped.* TO NULL

     IF  l_tabela = "w_ped_inf_cpl" THEN
         LET sql_stmt = "SELECT texto, campo FROM w_ped_inf_cpl"
     ELSE
         LET sql_stmt = "SELECT parametro_texto, campo FROM ped_info_compl"
     END IF

     LET sql_stmt = sql_stmt CLIPPED,
                    " WHERE empresa = '", p_cod_empresa CLIPPED, "'",
                      " AND pedido  = ", l_pedido,
                      " AND campo   LIKE 'OBSERVACAO EXPEDICAO%' ",
                    " ORDER BY campo "

     WHENEVER ERROR CONTINUE
      PREPARE var_query FROM sql_stmt
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql("PREPARE", "VAR_QUERY")
     END IF

     WHENEVER ERROR CONTINUE
      DECLARE cq_carrega_texto CURSOR WITH HOLD FOR var_query
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
#                   CALL vdpy154_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_1
                    LET lr_txt_exped.texto_1 = lr_txt_exped.texto_1 CLIPPED, ' ', l_texto CLIPPED
              WHEN '2'
#                   CALL vdpy154_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_2
                    LET lr_txt_exped.texto_2 = lr_txt_exped.texto_2 CLIPPED, ' ', l_texto CLIPPED
              WHEN '3'
#                   CALL vdpy154_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_3
                    LET lr_txt_exped.texto_3 = lr_txt_exped.texto_3 CLIPPED, ' ', l_texto CLIPPED
              WHEN '4'
#                   CALL vdpy154_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_4
                    LET lr_txt_exped.texto_4 = lr_txt_exped.texto_4 CLIPPED,' ', l_texto CLIPPED
         END CASE

     END FOREACH

     RETURN lr_txt_exped.*

 END FUNCTION

##------------------------------------------------#
# FUNCTION vdpy154_carrega_variavel_texto(l_texto)
##------------------------------------------------#
#     DEFINE l_texto         CHAR(026),
#            l_texto_total   CHAR(070)
#
#     INITIALIZE l_texto_total TO NULL
#
#     LET m_parte = m_parte + 1
#
#     CASE m_parte
#          WHEN 1
#               LET m_texto_parte1 = l_texto
#
#          WHEN 2
#               LET m_texto_parte2 = l_texto
#
#          WHEN 3
#               LET m_texto_parte3 = l_texto
#               LET l_texto_total = m_texto_parte1, m_texto_parte2, m_texto_parte3
#               LET m_parte = 0
#     END CASE
#
#     RETURN l_texto_total
#
# END FUNCTION


##--------------------------------------------------------------------#
# FUNCTION vdpy154_processa_gravacao_w_ped_inf_cpl(l_num_pedido,
#                                                  lr_ped_info_compl)
##--------------------------------------------------------------------#
#     DEFINE l_num_pedido        LIKE pedidos.num_pedido
#     DEFINE lr_ped_info_compl   RECORD
#                                    texto_1   CHAR(076),
#                                    texto_2   CHAR(076),
#                                    texto_3   CHAR(076),
#                                    texto_4   CHAR(076)
#                                END RECORD
#
#     DEFINE l_contador           SMALLINT,
#            l_campo              CHAR(024),
#            l_campo_aux          CHAR(023),
#            l_texto_aux          CHAR(078),
#            l_texto              CHAR(026),
#            l_inicio             SMALLINT,
#            l_ind                SMALLINT
#
#     FOR l_contador = 1 TO 4
#         CASE l_contador
#              WHEN 1
#                   LET l_campo = 'OBSERVACAO EXPEDICAO 1-'
#                   LET l_texto_aux = lr_ped_info_compl.texto_1
#
#              WHEN 2
#                   LET l_campo = 'OBSERVACAO EXPEDICAO 2-'
#                   LET l_texto_aux = lr_ped_info_compl.texto_2
#
#              WHEN 3
#                   LET l_campo = 'OBSERVACAO EXPEDICAO 3-'
#                   LET l_texto_aux = lr_ped_info_compl.texto_3
#
#              WHEN 4
#                   LET l_campo = 'OBSERVACAO EXPEDICAO 4-'
#                   LET l_texto_aux = lr_ped_info_compl.texto_4
#         END CASE
#
#         LET l_inicio = 0
#
#         FOR l_ind = 1 TO 3
#             LET l_campo_aux = l_campo
#
#             LET l_campo = l_campo_aux CLIPPED, l_ind
#             LET l_texto = l_texto_aux[l_inicio + 1, l_inicio + 26]
#
#             LET l_inicio = l_inicio + 26
#
#             IF  NOT vdpy154_grava_w_ped_inf_cpl(l_num_pedido, l_campo, l_texto) THEN
#                 RETURN FALSE
#             END IF
#         END FOR
#     END FOR
#
#     RETURN TRUE
#
# END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION vdpy154_processa_gravacao_w_ped_inf_cpl(l_num_pedido,
                                                  lr_ped_info_compl)
#--------------------------------------------------------------------#
     DEFINE l_num_pedido        LIKE pedidos.num_pedido
     DEFINE lr_ped_info_compl   RECORD
                                    texto_1   CHAR(070),
                                    texto_2   CHAR(070),
                                    texto_3   CHAR(070),
                                    texto_4   CHAR(070)
                                END RECORD

     DEFINE l_contador           SMALLINT,
            l_campo              CHAR(030),
            l_campo_aux          CHAR(023),
            l_texto_aux          CHAR(078),
            l_texto              CHAR(026),
            l_inicio             SMALLINT,
            l_ind                SMALLINT

     WHENEVER ERROR CONTINUE
     DELETE ped_info_compl
     WHERE empresa = p_cod_empresa
             AND pedido  = l_num_pedido
             AND campo   LIKE 'OBSERVACAO EXPEDICAO%'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DELETE", "PED_INFO_COMPL")
        RETURN FALSE
     END IF

     FOR l_contador = 1 TO 4
         CASE l_contador
              WHEN 1
                   LET l_campo = 'OBSERVACAO EXPEDICAO 1-'
                   LET l_texto_aux = lr_ped_info_compl.texto_1

              WHEN 2
                   LET l_campo = 'OBSERVACAO EXPEDICAO 2-'
                   LET l_texto_aux = lr_ped_info_compl.texto_2

              WHEN 3
                   LET l_campo = 'OBSERVACAO EXPEDICAO 3-'
                   LET l_texto_aux = lr_ped_info_compl.texto_3

              WHEN 4
                   LET l_campo = 'OBSERVACAO EXPEDICAO 4-'
                   LET l_texto_aux = lr_ped_info_compl.texto_4
         END CASE

#         LET l_campo = l_campo CLIPPED, l_contador

         IF  NOT vdpy154_grava_w_ped_inf_cpl(l_num_pedido, l_campo, l_texto_aux) THEN
             RETURN FALSE
         END IF
     END FOR

     RETURN TRUE

 END FUNCTION

#-----------------------------------------------------------------#
 FUNCTION vdpy154_grava_w_ped_inf_cpl(l_pedido, l_campo, l_texto)
#-----------------------------------------------------------------#
     DEFINE l_pedido  LIKE pedidos.num_pedido,
            l_campo   CHAR(030),
            l_texto   CHAR(070)

     IF m_tipo = 'MODIFICACAO' THEN

        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM ped_info_compl
           WHERE empresa = p_cod_empresa
             AND pedido  = l_pedido
             AND campo   = l_campo
        WHENEVER ERROR CONTINUE
        IF  SQLCA.sqlcode = NOTFOUND THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO ped_info_compl (empresa,
                                       pedido,
                                       campo,
                                       parametro_texto)
                               VALUES (p_cod_empresa,
                                       l_pedido,
                                       l_campo,
                                       l_texto)
            WHENEVER ERROR STOP
            IF  SQLCA.sqlcode <> 0 THEN
                CALL log003_err_sql("INCLUSAO","PED_INFO_COMPL")
                RETURN FALSE
            END IF
        ELSE
            WHENEVER ERROR CONTINUE
              UPDATE ped_info_compl
                 SET parametro_texto = l_texto
               WHERE empresa = p_cod_empresa
                 AND pedido  = l_pedido
                 AND campo   = l_campo
            WHENEVER ERROR STOP
            IF  SQLCA.sqlcode <> 0 THEN
                CALL log003_err_sql("ATUALIZACAO","PED_INFO_COMPL")
                RETURN FALSE
            END IF
        END IF

        RETURN TRUE

     ELSE
        WHENEVER ERROR CONTINUE
          SELECT 1
            FROM w_ped_inf_cpl
           WHERE empresa = p_cod_empresa
             AND pedido  = l_pedido
             AND campo   = l_campo
        WHENEVER ERROR CONTINUE
        IF  SQLCA.sqlcode = NOTFOUND THEN
            WHENEVER ERROR CONTINUE
            INSERT INTO w_ped_inf_cpl (empresa,
                                       pedido,
                                       campo,
                                       texto)
                               VALUES (p_cod_empresa,
                                       l_pedido,
                                       l_campo,
                                       l_texto)
            WHENEVER ERROR STOP
            IF  SQLCA.sqlcode <> 0 THEN
                CALL log003_err_sql("INCLUSAO","W_PED_INF_CPL")
                RETURN FALSE
            END IF
        ELSE
            WHENEVER ERROR CONTINUE
              UPDATE w_ped_inf_cpl
                 SET texto = l_texto
               WHERE empresa = p_cod_empresa
                 AND pedido  = l_pedido
                 AND campo   = l_campo
            WHENEVER ERROR STOP
            IF  SQLCA.sqlcode <> 0 THEN
                CALL log003_err_sql("ATUALIZACAO","W_PED_INF_CPL")
                RETURN FALSE
            END IF
        END IF

        RETURN TRUE
     END IF

 END FUNCTION

#--------------------------------------------------#
 FUNCTION vdpy154_grava_txt_obs_exped(l_num_pedido)
#--------------------------------------------------#
     DEFINE l_num_pedido      LIKE pedidos.num_pedido

     DEFINE l_pedido_selecao  LIKE pedidos.num_pedido

     DEFINE lr_grava_compl   RECORD
                                 empresa   LIKE ped_info_compl.empresa,
                                 pedido    LIKE ped_info_compl.pedido,
                                 campo     LIKE ped_info_compl.campo,
                                 texto     LIKE ped_info_compl.parametro_texto
                             END RECORD

#  IF m_tipo = 'MODIFICACAO' THEN
#
#        WHENEVER ERROR CONTINUE
#      DECLARE cq_grava_compl CURSOR FOR
#       SELECT empresa,
#              pedido,
#              campo,
#              parametro_texto
#            FROM ped_info_compl
#           WHERE empresa = p_cod_empresa
#             AND pedido  = l_num_pedido
#        ORDER BY campo
#
#  ELSE
     CALL vdpy154_retorna_pedido_selecao(l_num_pedido) RETURNING l_pedido_selecao

     WHENEVER ERROR CONTINUE
      DECLARE cq_grava_compl CURSOR FOR
       SELECT empresa,
              pedido,
              campo,
              texto
         FROM w_ped_inf_cpl
        WHERE empresa = p_cod_empresa
          AND pedido  = l_pedido_selecao
        ORDER BY campo
# END IF
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode <> 0 THEN
         CALL log003_err_sql('DECLARE','CQ_GRAVA_COMPL')
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_grava_compl INTO lr_grava_compl.*
     WHENEVER ERROR STOP
         IF  SQLCA.sqlcode <> 0   AND
             SQLCA.sqlcode <> 100 THEN
             CALL log003_err_sql('FOREACH','CQ_GRAVA_COMPL')
         END IF

         IF  lr_grava_compl.texto IS NULL THEN
             LET lr_grava_compl.texto = ' '
         END IF

         WHENEVER ERROR CONTINUE
         SELECT 1
          FROM ped_info_compl
         WHERE empresa = lr_grava_compl.empresa
           AND pedido = l_num_pedido
           AND campo  = lr_grava_compl.campo
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = 0 THEN
            WHENEVER ERROR CONTINUE
            UPDATE ped_info_compl
               SET parametro_texto = lr_grava_compl.texto
             WHERE empresa = lr_grava_compl.empresa
               AND pedido = l_num_pedido
               AND campo  = lr_grava_compl.campo
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("UPDATE","PED_INFO_COMPL")
               RETURN
            END IF
         ELSE
            WHENEVER ERROR CONTINUE
              INSERT INTO ped_info_compl (empresa,
                                          pedido,
                                          campo,
                                          parametro_texto)
                                  VALUES (lr_grava_compl.empresa,
                                          l_num_pedido,               # GRAVA COM O PEDIDO ENVIADO A FUNCAO
                                          lr_grava_compl.campo,
                                          lr_grava_compl.texto)
            WHENEVER ERROR STOP
            IF  SQLCA.sqlcode <> 0 THEN
                CALL log003_err_sql("INCLUSAO2","PED_INFO_COMPL")
                RETURN FALSE
            END IF
         END IF

     END FOREACH

     INITIALIZE mr_ped_info_compl.* TO NULL

     RETURN TRUE

 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_retorna_pedido_selecao(l_pedido)
#-------------------------------------------------#
     DEFINE l_pedido      LIKE pedidos.num_pedido

     DEFINE l_ped_selecao LIKE pedidos.num_pedido

     LET l_ped_selecao = 0

     WHENEVER ERROR CONTINUE
       SELECT DISTINCT 1
         FROM w_ped_inf_cpl
        WHERE empresa = p_cod_empresa
          AND pedido  = l_pedido
     WHENEVER ERROR STOP
     IF  SQLCA.sqlcode = 100 THEN
         WHENEVER ERROR CONTINUE
           SELECT DISTINCT 1               # TESTA PEDIDO = 0, POR QUE NO MOMENTO DA GRAVACAO
             FROM w_ped_inf_cpl            # DA TABELA TEMPORARIA (w_ped_inf_cpl) O PEDIDO FOI
            WHERE empresa = p_cod_empresa  # USADO COMO 0 (ZERO) - VDP3135.
              AND pedido  = 0
         WHENEVER ERROR STOP
         IF  SQLCA.sqlcode = 0 THEN
             LET l_ped_selecao = 0
         END IF
     ELSE
         IF  SQLCA.sqlcode = 0 THEN
             LET l_ped_selecao = l_pedido
         END IF
     END IF

     RETURN l_ped_selecao

 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_exclui_ped_info_txt_expedicao(l_pedido)
#-------------------------------------------------#
  DEFINE l_pedido LIKE pedidos.num_pedido

     WHENEVER ERROR CONTINUE
       DELETE FROM ped_info_compl
        WHERE empresa    = p_cod_empresa
          AND pedido = l_pedido
          AND campo LIKE 'OBSERVACAO EXPEDICAO %'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
     END IF
 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_possui_texto_expedicao(l_pedido)
#-------------------------------------------------#
  DEFINE l_pedido   LIKE pedidos.num_pedido
  DEFINE l_contador SMALLINT

  WHENEVER ERROR CONTINUE
  SELECT COUNT(parametro_texto)
    INTO l_contador
    FROM ped_info_compl
   WHERE empresa = p_cod_empresa
     AND pedido  = l_pedido
     AND campo LIKE 'OBSERVACAO EXPEDICAO%'
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

  IF l_contador IS NULL OR l_contador = 0 THEN
     RETURN 'N'
  ELSE
     RETURN 'S'
  END IF

 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_set_usar_modular_texto()
#-------------------------------------------------#
    LET m_usar_modular_texto = TRUE
 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_carrega_txt_expedicao(l_pedido, l_tabela)
#-------------------------------------------------#
  DEFINE l_pedido   LIKE pedidos.num_pedido
  DEFINE l_tabela   CHAR(20)

   CALL vdpy154_carrega_txt_exped(l_pedido, l_tabela)
      RETURNING mr_ped_info_compl.*
 END FUNCTION

#-------------------------------------------------#
 FUNCTION vdpy154_set_txt_expedicao(lr_ped_info_compl)
#-------------------------------------------------#
     DEFINE lr_ped_info_compl    RECORD
                                     texto_1   CHAR(070),
                                     texto_2   CHAR(070),
                                     texto_3   CHAR(070),
                                     texto_4   CHAR(070)
                                 END RECORD

  LET mr_ped_info_compl.* = lr_ped_info_compl.*
 END FUNCTION

#-------------------------------#
 FUNCTION vdpy154_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/funcoes/vdpy154.4gl $|$Revision: 4 $|$Date: 23/08/11 17:32 $|$Modtime: 31/05/11 11:08 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION