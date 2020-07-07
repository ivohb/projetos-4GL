#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: vdp0534                                               #
# MODULOS.: vdp0534 - LOG0010 - LOG0050 - LOG0060 - LOG1300       #
#           LOG1400                                               #
# OBJETIVO: CONSULTA O ESTOQUE TOTAL                              #
# AUTOR...: AGNES EMANUELE ALVES DE SOUZA                         #
# DATA....: 05/05/2004                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_estoque            RECORD LIKE estoque.*,
          p_estoquer           RECORD LIKE estoque.*,
          p_ped_itens          RECORD LIKE ped_itens.*,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_item           LIKE item.den_item,
          p_pes_unit           LIKE item.pes_unit,
          p_qtd_inicial        DECIMAL(15,3),
          p_peso_inicial       DECIMAL(15,4),
          p_qtd_atual          DECIMAL(15,3),
          p_peso_atual         DECIMAL(15,4),
          p_peso_reservado     DECIMAL(15,4),
          p_qtd_romaneio       DECIMAL(15,3),
          p_peso_romaneio      DECIMAL(15,4),
          p_qtd_dispon_pdr     DECIMAL(15,3),
          p_peso_dispon_pdr    DECIMAL(15,4),
          p_qtd_cart_mes       DECIMAL(15,3),
          p_peso_cart_mes      DECIMAL(15,4),
          p_qtd_dispon_2       DECIMAL(15,3),
          p_peso_dispon_2      DECIMAL(15,4),
          p_qtd_carteira       DECIMAL(15,3),
          p_peso_carteira      DECIMAL(15,4),
          p_est_disponivel     DECIMAL(15,3),
          p_qtd_dispon_3       DECIMAL(15,3),
          p_peso_dispon_3      DECIMAL(15,4),
          p_qtd_carteira_bnf   DECIMAL(15,3),
          p_ies_cons           SMALLINT,
          p_last_row           SMALLINT,
          p_status             SMALLINT,
          p_comando            CHAR(80),
          p_caminho            CHAR(80),
          p_help               CHAR(80),
          p_nom_tela           CHAR(80),
          p_cancel             INTEGER

   DEFINE p_versao             CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN

   CALL log0180_conecta_usuario()

LET p_versao = "VDP0534-05.00.00" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ANY ERROR CONTINUE
      CALL log1400_isolation()
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
   LET p_help = p_caminho CLIPPED
   OPTIONS
      HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LOGERP")
        RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL vdp0534_controle()
   END IF
END MAIN

#-------------------------#
 FUNCTION vdp0534_controle()
#-------------------------#
   DEFINE l_run CHAR(080)

   CALL log006_exibe_teclas("01", p_versao)

   INITIALIZE p_estoque.*,
              p_estoquer.* TO NULL

   CALL log130_procura_caminho("vdp0534") RETURNING p_nom_tela
   OPEN WINDOW w_vdp0534 AT 2,2  WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   CALL log0010_close_window_screen()
   MENU "OPCAO"
      COMMAND "Consultar"    "Consulta Estoque"
         HELP 004
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","vdp0534","CO") THEN
            CALL  vdp0534_query_movto_estoq()
         END IF

      COMMAND "Seguinte"   "Exibe registro seguinte"
         HELP 005
         MESSAGE ""
         CALL vdp0534_paginacao("SEGUINTE")

      COMMAND "Anterior"   "Exibe registro anterior"
         HELP 006
         MESSAGE ""
         CALL vdp0534_paginacao("ANTERIOR")

      COMMAND KEY("E") "situacao_Estoque"   "Consulta informações da Situação dos Estoques"
         MESSAGE ""
         IF log005_seguranca(p_user,"SUPRIMEN","SUP0170","CO")  THEN
            CALL log120_procura_caminho("SUP0170") RETURNING l_run

            IF  p_estoque.cod_item IS NOT NULL
            AND p_estoque.cod_item <> " " THEN
               LET l_run = l_run CLIPPED , " ",
                           p_cod_empresa , " ",
                           p_estoque.cod_item
            END IF

            RUN l_run
            CURRENT WINDOW IS w_vdp0534
         END IF

      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR p_comando
         RUN p_comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
         DATABASE logix

      COMMAND "Fim"        "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_vdp0534
END FUNCTION

#-------------------------------------#
 FUNCTION vdp0534_query_movto_estoq()
#-------------------------------------#
   DEFINE where_clause, sql_stmt   CHAR(500)

   CALL log006_exibe_teclas("02 03 07", p_versao)
   CURRENT WINDOW IS w_vdp0534
   LET p_estoquer.* = p_estoque.*
   INITIALIZE p_estoque.*,
              p_den_item,
              p_qtd_inicial,
              p_peso_inicial,
              p_qtd_atual,
              p_peso_atual,
              p_peso_reservado,
              p_qtd_romaneio,
              p_peso_romaneio,
              p_qtd_dispon_pdr,
              p_peso_dispon_pdr,
              p_qtd_cart_mes,
              p_peso_cart_mes,
              p_qtd_dispon_2,
              p_peso_dispon_2,
              p_qtd_carteira,
              p_peso_carteira,
              p_qtd_carteira_bnf,
              p_qtd_dispon_3,
              p_peso_dispon_3     TO NULL

   CLEAR FORM
   DISPLAY p_cod_empresa   TO cod_empresa

   CONSTRUCT where_clause ON item.cod_item,
                             item.den_item
                        FROM cod_item,
                             den_item

     BEFORE FIELD cod_item
        DISPLAY "( Zoom )" AT 03,67
        --#CALL fgl_dialog_setkeylabel('control-z', 'Zoom')

     AFTER  FIELD cod_item
        DISPLAY "--------" AT 03,67

     ON KEY (control-z, f4)
        CALL vdp0534_popup()
  END CONSTRUCT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp0534
  IF INT_FLAG THEN
     LET  int_flag = 0
     LET  p_estoque.* = p_estoquer.*
     CALL vdp0534_exibe_dados()
     ERROR " Consulta Cancelada "
     RETURN
  END IF

  LET sql_stmt = "SELECT estoque.* ",
                 " FROM item_vdp, item, estoque  ",
                 " WHERE item_vdp.cod_empresa = """,p_cod_empresa,""" ",
                 "   AND item.cod_empresa     = """,p_cod_empresa,""" " ,
                 "   AND item.cod_item        = item_vdp.cod_item  ",
                 "   AND estoque.cod_empresa  = """,p_cod_empresa,""" " ,
                 "   AND estoque.cod_item     = item_vdp.cod_item  ",
                 "   AND  ", where_clause CLIPPED,
                 " ORDER BY estoque.cod_item "

  PREPARE var_query  FROM sql_stmt
  DECLARE cq_estoque SCROLL CURSOR FOR var_query
  OPEN  cq_estoque
  FETCH cq_estoque  INTO p_estoque.*

  IF sqlca.sqlcode = NOTFOUND THEN
     CALL log0030_mensagem("Argumentos de pesquisa não encontrados", "exclamation")
     LET p_ies_cons = FALSE
  ELSE
     LET p_ies_cons = TRUE
  END IF
  CALL vdp0534_exibe_dados()
END FUNCTION

#-----------------------#
 FUNCTION vdp0534_popup()
#-----------------------#
   CASE
     WHEN infield(cod_item)
        LET  p_estoque.cod_item = vdp373_popup_item(p_cod_empresa)
        CALL log006_exibe_teclas("01 02 03 07", p_versao)
        CURRENT WINDOW IS w_vdp0534
        IF p_estoque.cod_item IS NOT NULL THEN
           DISPLAY BY NAME p_estoque.cod_item
        END IF
   END CASE
END FUNCTION

#-----------------------------#
 FUNCTION vdp0534_exibe_dados()
#-----------------------------#
   CALL vdp0534_busca_denominacao()

   DISPLAY BY NAME p_estoque.cod_empresa,
                   p_estoque.cod_item,
                   p_estoque.qtd_reservada

   DISPLAY p_den_item,
           p_qtd_inicial,
           p_peso_inicial,
           p_qtd_atual,
           p_peso_atual,
           p_peso_reservado,
           p_qtd_romaneio,
           p_peso_romaneio,
           p_qtd_dispon_pdr,
           p_peso_dispon_pdr,
           p_qtd_cart_mes,
           p_peso_cart_mes,
           p_qtd_dispon_2,
           p_peso_dispon_2,
           p_qtd_carteira,
           p_peso_carteira,
           p_qtd_dispon_3,
           p_peso_dispon_3
        TO den_item,
           qtd_inicial,
           peso_inicial,
           qtd_atual,
           peso_atual,
           peso_reservado,
           qtd_romaneio,
           peso_romaneio,
           qtd_dispon_pdr,
           peso_dispon_pdr,
           qtd_cart_mes,
           peso_cart_mes,
           qtd_dispon_2,
           peso_dispon_2,
           qtd_carteira,
           peso_carteira,
           qtd_dispon_3,
           peso_dispon_3
END FUNCTION

#------------------------------------#
 FUNCTION vdp0534_busca_denominacao()
#------------------------------------#
   DEFINE p_ano_mes_ref       LIKE estoque_hist.ano_mes_ref

   DEFINE l_ies_abate_terc    CHAR(01),
          l_ies_opera_estoq   CHAR(01),
          l_cod_local_estoq   LIKE pedidos.cod_local_estoq,
          l_qtd_estoque_pdr   LIKE estoque_lote.qtd_saldo,
          l_qtd_reservada_pdr LIKE estoque_loc_reser.qtd_reservada

   LET l_ies_abate_terc  = " "
   LET l_ies_opera_estoq = " "
   LET l_cod_local_estoq = " "

   LET p_pes_unit    = 0
   LET p_qtd_inicial = 0

   SELECT den_item,
          pes_unit
     INTO p_den_item,
          p_pes_unit
     FROM item
    WHERE cod_item    = p_estoque.cod_item
      AND cod_empresa = p_cod_empresa
   IF sqlca.sqlcode <> 0 THEN
      LET p_den_item = NULL
      LET p_pes_unit = 0
   END IF

   SELECT MAX(estoque_hist.ano_mes_ref)
     INTO p_ano_mes_ref
     FROM estoque_hist
    WHERE estoque_hist.cod_empresa = p_cod_empresa
      AND estoque_hist.cod_item    = p_estoque.cod_item

   SELECT estoque_hist.qtd_mes_ant
     INTO p_qtd_inicial
     FROM estoque_hist
    WHERE p_estoque.cod_empresa    = estoque_hist.cod_empresa
      AND p_estoque.cod_item       = estoque_hist.cod_item
      AND estoque_hist.ano_mes_ref = p_ano_mes_ref

   IF p_qtd_inicial IS NULL THEN
      LET p_qtd_inicial = 0
   END IF

   LET p_peso_inicial   = p_qtd_inicial  *  p_pes_unit

   LET p_qtd_atual      = p_estoque.qtd_liberada
   LET p_peso_atual     = p_qtd_atual * p_pes_unit

   LET p_peso_reservado = p_estoque.qtd_reservada * p_pes_unit

   LET p_qtd_romaneio   = 0
   LET p_qtd_cart_mes   = 0
   LET p_qtd_carteira   = 0

   DECLARE c_ped_itens CURSOR WITH HOLD FOR
      SELECT qtd_pecas_romaneio,
             prz_entrega,
             qtd_pecas_solic,
             qtd_pecas_atend,
             qtd_pecas_cancel
        FROM ped_itens
       WHERE ped_itens.cod_empresa = p_estoque.cod_empresa
         AND ped_itens.cod_item    = p_estoque.cod_item
         AND (ped_itens.qtd_pecas_solic   -
              ped_itens.qtd_pecas_atend   -
              ped_itens.qtd_pecas_cancel) > 0
      UNION ALL
      SELECT qtd_pecas_romaneio,
             prz_entrega,
             qtd_pecas_solic,
             qtd_pecas_atend,
             qtd_pecas_cancel
        FROM ped_itens_bnf
       WHERE ped_itens_bnf.cod_empresa = p_estoque.cod_empresa
         AND ped_itens_bnf.cod_item    = p_estoque.cod_item
         AND (ped_itens_bnf.qtd_pecas_solic   -
              ped_itens_bnf.qtd_pecas_atend   -
              ped_itens_bnf.qtd_pecas_cancel) > 0

   FOREACH c_ped_itens INTO p_ped_itens.qtd_pecas_romaneio,
                            p_ped_itens.prz_entrega,
                            p_ped_itens.qtd_pecas_solic,
                            p_ped_itens.qtd_pecas_atend,
                            p_ped_itens.qtd_pecas_cancel
      IF p_ped_itens.qtd_pecas_romaneio > 0 THEN
         LET p_qtd_romaneio = p_qtd_romaneio + p_ped_itens.qtd_pecas_romaneio
      END IF

      IF ((MONTH(p_ped_itens.prz_entrega) <= MONTH(today)
      AND   YEAR(p_ped_itens.prz_entrega)  =  YEAR(today))
      OR    YEAR(p_ped_itens.prz_entrega)  <  YEAR(today)) THEN
         LET p_qtd_cart_mes = p_qtd_cart_mes + (p_ped_itens.qtd_pecas_solic -
                                                p_ped_itens.qtd_pecas_atend -
                                                p_ped_itens.qtd_pecas_cancel)
      END IF

      LET p_qtd_carteira = p_qtd_carteira + (p_ped_itens.qtd_pecas_solic -
                                             p_ped_itens.qtd_pecas_atend -
                                             p_ped_itens.qtd_pecas_cancel)
   END FOREACH

   LET p_peso_romaneio = p_qtd_romaneio * p_pes_unit

   SELECT par_vdp_txt[157,157],par_vdp_txt[325,325]
      INTO l_ies_opera_estoq, l_ies_abate_terc
      FROM par_vdp
     WHERE par_vdp.cod_empresa = p_cod_empresa

   #OS 278.404: somente considerar o Local Padrão para o campo
   #p_qtd_dispon_pdr e p_peso_dispon_pdr, os demais deverã permanecer com
   #o cálculo padrão

   SELECT SUM(estoque_lote.qtd_saldo)
      INTO l_qtd_estoque_pdr
      FROM item, estoque_lote
     WHERE item.cod_empresa         = p_cod_empresa
       AND item.cod_item            = p_estoque.cod_item
       AND estoque_lote.cod_empresa = item.cod_empresa
       AND estoque_lote.cod_item    = item.cod_item
       AND estoque_lote.cod_local   = item.cod_local_estoq

   IF l_qtd_estoque_pdr IS NULL THEN
      LET l_qtd_estoque_pdr = 0
   END IF

   SELECT SUM(estoque_loc_reser.qtd_reservada)
      INTO l_qtd_reservada_pdr
      FROM item, estoque_loc_reser
     WHERE item.cod_empresa              = p_cod_empresa
       AND item.cod_item                 = p_estoque.cod_item
       AND estoque_loc_reser.cod_empresa = item.cod_empresa
       AND estoque_loc_reser.cod_item    = item.cod_item
       AND estoque_loc_reser.cod_local   = item.cod_local_estoq

   IF l_qtd_reservada_pdr IS NULL THEN
      LET l_qtd_reservada_pdr = 0
   END IF

   LET p_qtd_dispon_pdr  = l_qtd_estoque_pdr - l_qtd_reservada_pdr
   LET p_peso_dispon_pdr = p_qtd_dispon_pdr * p_pes_unit

   LET p_peso_cart_mes = p_qtd_cart_mes * p_pes_unit

   LET p_qtd_dispon_2  = p_qtd_atual - p_qtd_cart_mes
   LET p_peso_dispon_2 = p_qtd_dispon_2 * p_pes_unit

#  SELECT SUM(qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel)
#    INTO p_qtd_carteira_bnf
#    FROM ped_itens_bnf
#   WHERE ped_itens_bnf.cod_empresa = p_estoque.cod_empresa
#     AND ped_itens_bnf.cod_item    = p_estoque.cod_item
#     AND (qtd_pecas_solic - qtd_pecas_atend - qtd_pecas_cancel) > 0
# coloquei o union all com a ped_itens pois aqui nao considerava na cart do mes.
# so na cart. geral. - Ju

   IF p_qtd_carteira_bnf IS NULL
   OR p_qtd_carteira_bnf < 0 THEN
      LET p_qtd_carteira_bnf   = 0
   END IF

   LET p_qtd_carteira  = p_qtd_carteira + p_qtd_carteira_bnf
   LET p_peso_carteira = p_qtd_carteira * p_pes_unit

   LET p_qtd_dispon_3  = p_qtd_atual    - p_qtd_carteira
   LET p_peso_dispon_3 = p_qtd_dispon_3 * p_pes_unit
END FUNCTION

#----------------------------------#
 FUNCTION vdp0534_paginacao(p_funcao)
#----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_estoquer.* = p_estoque.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE"
               FETCH NEXT cq_estoque INTO p_estoque.*
            WHEN p_funcao = "ANTERIOR"
               FETCH PREVIOUS cq_estoque INTO p_estoque.*
         END CASE
         IF SQLCA.sqlcode = NOTFOUND THEN
            LET p_estoque.* = p_estoquer.*
            ERROR " Não existem mais itens nesta direção "
            EXIT WHILE
         END IF

         SELECT * INTO p_estoque.* FROM estoque
             WHERE cod_empresa = p_estoque.cod_empresa
               AND cod_item    = p_estoque.cod_item

         IF SQLCA.sqlcode = 0 THEN
            CALL vdp0534_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR " Não existe nenhuma consulta ativa "
   END IF
END FUNCTION
