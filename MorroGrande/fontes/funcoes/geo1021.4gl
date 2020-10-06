###PARSER-Não remover esta linha(Framework Logix)###
#------------------------------------------------------------#
# SISTEMA.: GEO                                              #
# PROGRAMA: geo1021 (COPIA ADAPTADA/AUTOMATIZADA DE MCX0810) #
# OBJETIVO: FUNCAO PARA CHAMAR A INTEGRACAO ENTRE OS MODULOS #
#           USADA NOS PROGRAMAS MCX0007 E MCX0008            #
# AUTOR...: EVANDRO SIMENES                                  #
# DATA....: 22/03/2016                                       #
#------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa     LIKE empresa.cod_empresa,
         p_user            LIKE usuario.nom_usuario,
         p_status          SMALLINT,
         p_versao          CHAR(18),
         p_comando         CHAR(80),
         p_caminho         CHAR(80),
         p_nom_tela        CHAR(80),
         g_control_e       SMALLINT,
         g_erro            SMALLINT,
         g_modulo          CHAR(04),
         g_val_docum       LIKE mcx_movto.val_docum,
         # g_operacao = Variável utilizada pelo mcx0007 para identificar se uma
         # operacao é de estorno.
         g_operacao        LIKE mcx_movto.operacao,
         g_docum_baixado   SMALLINT,
         g_seq_docum_cre   LIKE docum_pgto.num_seq_docum

END GLOBALS

# MODULARES

 DEFINE m_empresa_destino   LIKE mcx_oper_cx_transf.empresa_destino,
        m_caixa_destino     LIKE mcx_oper_cx_transf.caixa_destino,
        m_oper_destino      LIKE mcx_oper_cx_transf.operacao_destino,
        m_mcx_movto         RECORD LIKE mcx_movto.*,
        m_empresa           LIKE empresa.cod_empresa,
        m_tip_docum         LIKE mcx_mov_baixa_cre.tip_docum,
        m_lote              LIKE mcx_movto_gera_cre.lote,
        m_empresa1          LIKE empresa.cod_empresa,
        m_cod_cliente       LIKE clientes.cod_cliente,
        m_cod_empresa       LIKE empresa.cod_empresa,
        m_num_ap            LIKE ap.num_ap,
        m_baixa_ap          SMALLINT

# END MODULARES

#------------------------------------------------------------#
 FUNCTION geo1021_gera_integracao(l_mcx_movto, l_comando, l_cod_titulo, l_cod_cliente, l_tip_docum)
#------------------------------------------------------------#
 DEFINE l_mcx_movto  RECORD LIKE mcx_movto.*,
        l_historico  LIKE mcx_movto.hist_movto,
        l_comando    CHAR(10),
        l_cod_titulo CHAR(14),
        l_cod_cliente CHAR(15),
        l_tip_docum  LIKE docum.ies_tip_docum

 LET m_mcx_movto.*   = l_mcx_movto.*
 LET g_control_e     = TRUE
 LET g_docum_baixado = TRUE
 LET g_erro          = FALSE
 LET m_baixa_ap      = FALSE

 IF l_comando = "mcx0007" THEN
    # Se a operacao for estorno, fazer as consistencias com a operacao destino.
    IF g_operacao IS NOT NULL THEN
       LET m_mcx_movto.operacao = g_operacao
    END IF
 END IF

 # Verificar se a operação gera alguma informação em algum módulo.
 CALL geo1021_verifica_modulo(l_comando) RETURNING g_modulo

 CASE g_modulo
    WHEN "TRA" # Transferência
       CASE l_comando
          WHEN "mcx0007"
              CALL mcx0809_gera_transf(m_mcx_movto.*, m_empresa_destino,
                                       m_caixa_destino, m_oper_destino)
                   RETURNING m_mcx_movto.*
          WHEN "mcx0008"
              CALL geo1021_verifica_gerou_transf(l_comando)
          WHEN "control-e"
              CALL geo1021_verifica_gerou_transf(l_comando)
       END CASE

    WHEN "TRB"
       CASE l_comando
          WHEN "mcx0007"
              IF g_operacao IS NULL THEN
                 CALL geo1021_gera_trb()
              END IF
              IF m_mcx_movto.docum <> "X" THEN
                 CALL geo1021_verifica_gerou_trb(l_comando)
              END IF
          WHEN "mcx0008"
              CALL geo1021_verifica_gerou_trb(l_comando)
          WHEN "control-e"
              CALL geo1021_verifica_gerou_trb(l_comando)
       END CASE

    WHEN "SUP"
       CASE l_comando
          WHEN "mcx0007"
             IF g_operacao IS NULL THEN
                CALL geo1021_gera_sup()
             END IF
             IF m_mcx_movto.docum <> "X" THEN
                CALL geo1021_verifica_gerou_sup(l_comando)
             END IF
          WHEN "mcx0008"
             CALL geo1021_verifica_gerou_sup(l_comando)
          WHEN "control-e"
             CALL geo1021_verifica_gerou_sup(l_comando)
       END CASE

    WHEN "CAP" # Gerar um documento no CAP
       CASE l_comando
          WHEN "mcx0007"
             IF g_operacao IS NULL THEN
                CALL geo1021_gera_baixa_cap()
             END IF
             IF m_mcx_movto.docum <> "X" THEN
                CALL geo1021_verifica_gerou_cap(l_comando)
             END IF
          WHEN "mcx0008"
             CALL geo1021_verifica_gerou_cap(l_comando)
          WHEN "control-e"
             CALL geo1021_verifica_gerou_cap(l_comando)
       END CASE

    WHEN "CAP1" # Baixar um documento do CAP
       CASE l_comando
          WHEN "mcx0007"
             IF g_operacao IS NULL THEN
                CALL geo1021_gera_baixa_cap()
             END IF
             IF m_mcx_movto.docum <> "X" THEN
                CALL geo1021_verifica_baixou_cap(l_comando)
             END IF
          WHEN "mcx0008"
             CALL geo1021_verifica_baixou_cap(l_comando)
          WHEN "control-e"
             CALL geo1021_verifica_baixou_cap(l_comando)
       END CASE

    WHEN "CRE" # Gerar um documento no CRE
       CASE l_comando
          WHEN "mcx0007"
             IF g_operacao IS NULL THEN
                CALL geo1021_gera_baixa_cre(l_cod_titulo, l_cod_cliente, l_tip_docum)
                IF m_mcx_movto.docum <> "X" THEN
                   CALL geo1021_verifica_gerou_cre(l_comando)
                END IF
             ELSE
                CALL geo1021_verifica_gerou_cre(l_comando)
             END IF
          WHEN "mcx0008"
             CALL geo1021_verifica_gerou_cre(l_comando)
          WHEN "control-e"
             CALL geo1021_verifica_gerou_cre(l_comando)
       END CASE

    WHEN "CRE1" # Baixar um documento do CRE
       CASE l_comando
          WHEN "mcx0007"
             IF g_operacao IS NULL THEN
                CALL geo1021_gera_baixa_cre(l_cod_titulo, l_cod_cliente, l_tip_docum)
             END IF
             IF m_mcx_movto.docum <> "X" THEN
                CALL geo1021_verifica_baixou_cre(l_comando)
             END IF
          WHEN "mcx0008"
             CALL geo1021_verifica_baixou_cre(l_comando)
          WHEN "control-e"
             CALL geo1021_verifica_baixou_cre(l_comando)
       END CASE
 END CASE

 RETURN m_mcx_movto.*, m_baixa_ap, m_cod_empresa, m_num_ap

END FUNCTION

#----------------------------------#
 FUNCTION geo1021_verifica_modulo(l_comando)
#----------------------------------#
 DEFINE l_gera_baixa_docum   LIKE mcx_oper_caixa_cap.gera_baixa_docum,
        l_comando             CHAR(10)

 # Verifica se a operacao gera ou baixa CAP
 WHENEVER ERROR CONTINUE
  SELECT gera_baixa_docum
    INTO l_gera_baixa_docum
    FROM mcx_oper_caixa_cap
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF l_gera_baixa_docum MATCHES "[GA]" AND l_comando <> "control-e" THEN
       RETURN "CAP"
    ELSE
       RETURN "CAP1"
    END IF
 END IF

 # Verifica se a operacao gera ou baixa CRE
 WHENEVER ERROR CONTINUE
  SELECT gera_baixa_docum
    INTO l_gera_baixa_docum
    FROM mcx_oper_caixa_cre
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF l_gera_baixa_docum MATCHES "[GA]" THEN
       RETURN "CRE"
    ELSE
       RETURN "CRE1"
    END IF
 END IF

 # Verifica se a operacao gera SUP
 WHENEVER ERROR CONTINUE
  SELECT gera_pend_sup_autm
    FROM mcx_oper_caixa_sup
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN "SUP"
 END IF

 # Verifica se a operacao gera TRB
 WHENEVER ERROR CONTINUE
  SELECT *
    FROM mcx_oper_caixa_trb
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN "TRB"
 END IF

 # Verifica se a operacao gera TRANSFERENCIA
 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, caixa_destino, operacao_destino
    INTO m_empresa_destino, m_caixa_destino, m_oper_destino
    FROM mcx_oper_cx_transf
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    RETURN "TRA"
 END IF

 # Se não atender a nenhuma situacao acima, será uma movimentação normal.
 RETURN "MCX"

END FUNCTION

#-------------------------------------------------#
 FUNCTION geo1021_verifica_gerou_transf(l_comando)
#-------------------------------------------------#
 DEFINE l_val_docum      LIKE mcx_movto.val_docum,
        l_comando        CHAR(10)

 WHENEVER ERROR CONTINUE
  SELECT val_docum
    INTO l_val_docum
    FROM mcx_movto
   WHERE empresa   = m_empresa_destino
     AND caixa     = m_caixa_destino
     AND dat_movto = m_mcx_movto.dat_movto
     AND operacao  = m_oper_destino
     AND docum     = m_mcx_movto.docum
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 OR log0030_err_sql_registro_duplicado() THEN
    IF l_val_docum <> m_mcx_movto.val_docum THEN
       IF l_comando = "mcx0008" THEN
          CALL geo1021_gera_pendencias(2)
       ELSE
          LET g_control_e = FALSE
       END IF
    ELSE
       IF l_comando = "control-e" THEN
          CALL geo1021_verifica_caixa_fechado()
       END IF
    END IF
 ELSE
    IF l_comando <> "mcx0007" THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento de Transferência não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#------------------------------------------#
 FUNCTION geo1021_verifica_caixa_fechado()
#------------------------------------------#
 DEFINE l_max_data  LIKE mcx_saldo.dat_saldo

 LET l_max_data  = NULL

 WHENEVER ERROR CONTINUE
  SELECT MAX(dat_saldo)
    INTO l_max_data
    FROM mcx_saldo
   WHERE empresa = m_empresa_destino
     AND caixa   = m_caixa_destino
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF m_mcx_movto.dat_movto <= l_max_data THEN
       LET g_control_e = FALSE
    END IF
 END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION geo1021_verifica_gerou_cap(l_comando)
#----------------------------------------------#
 DEFINE l_num_ad            LIKE ad_mestre.num_ad,
        l_num_ap            LIKE ap.num_ap,
        l_empresa_destino   LIKE mcx_movto_gera_cap.empresa_destino,
        l_num_nf            LIKE mcx_movto_gera_cap.nota_fiscal,
        l_ser_nf            LIKE mcx_movto_gera_cap.serie_nota_fiscal,
        l_ssr_nf            LIKE mcx_movto_gera_cap.subserie_nf,
        l_fornecedor        LIKE mcx_movto_gera_cap.fornecedor,
        l_val_docum         LIKE ap.val_nom_ap,
        l_num_versao        LIKE ap.num_versao,
        l_moeda_padrao      LIKE par_cap.cod_moeda_padrao,
        l_val_nom_ap        LIKE ap.val_nom_ap,
        l_cod_moeda         LIKE ap.cod_moeda,
        l_val_ap_dat_pgto   LIKE ap.val_ap_dat_pgto,
        l_comando           CHAR(10)

 WHENEVER ERROR CONTINUE
 SELECT cod_moeda_padrao
   INTO l_moeda_padrao
   FROM par_cap
  WHERE cod_empresa = m_mcx_movto.empresa
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, nota_fiscal, serie_nota_fiscal, subserie_nf, fornecedor
    INTO l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf, l_fornecedor
    FROM mcx_movto_gera_cap
   WHERE empresa         = m_mcx_movto.empresa
     AND caixa           = m_mcx_movto.caixa
     AND dat_movto       = m_mcx_movto.dat_movto
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     SELECT num_ad
       INTO l_num_ad
       FROM ad_mestre
      WHERE cod_empresa    = l_empresa_destino
        AND num_nf         = l_num_nf
        AND ser_nf         = l_ser_nf
        AND ssr_nf         = l_ssr_nf
        AND cod_fornecedor = l_fornecedor
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       WHENEVER ERROR CONTINUE
        SELECT num_ap
          INTO l_num_ap
          FROM ad_ap
         WHERE cod_empresa = l_empresa_destino
           AND num_ad      = l_num_ad
       WHENEVER ERROR STOP

       IF sqlca.sqlcode = 0 THEN
           WHENEVER ERROR CONTINUE
            SELECT num_versao, val_nom_ap, cod_moeda, val_ap_dat_pgto
              INTO l_num_versao, l_val_nom_ap, l_cod_moeda, l_val_ap_dat_pgto
              FROM ap
             WHERE cod_empresa = l_empresa_destino
               AND num_ap      = l_num_ap
               AND ies_versao_atual = "S"
           WHENEVER ERROR STOP

           IF SQLCA.sqlcode = 0 THEN
              IF g_operacao IS NOT NULL THEN
                 IF l_comando <> "control-e" THEN
                    CALL geo1021_gera_pendencias(5)
                 ELSE
                    LET g_control_e = FALSE
                 END IF
              ELSE
                 # Só pode baixar uma AP se esta estiver com o valor liquido zerado
                 CALL geo1021_busca_valor_liquido(l_empresa_destino, l_num_ap,
                                                  l_num_versao, l_cod_moeda,
                                                  l_val_ap_dat_pgto, l_val_nom_ap,
                                                  l_moeda_padrao, l_comando)
                      RETURNING l_val_docum

                 # Se o valor do documento for diferente do valor do movimento, gerar pendencia
                 CASE l_comando
                   WHEN "mcx0007" LET m_mcx_movto.val_docum = l_val_docum
                         CALL geo1021_zerar_ap(l_empresa_destino, l_num_versao, l_num_ap,
                                               l_val_docum) RETURNING p_status
                   WHEN "mcx0008"
                      IF l_val_docum <> m_mcx_movto.val_docum THEN
                         CALL geo1021_gera_pendencias(2)
                      ELSE
                         CALL geo1021_zerar_ap(l_empresa_destino, l_num_versao, l_num_ap,
                                               l_val_docum) RETURNING p_status
                      END IF
                   WHEN "control-e" LET g_control_e = FALSE
                 END CASE
              END IF
           ELSE
              # Se não encontrar o documento, gerar pendencia.
              IF l_comando <> "control-e" THEN
                 CALL geo1021_gera_pendencias(1)
              END IF
           END IF
       ELSE
          # Se não encontrar AP, gerar pendencia.
          IF sqlca.sqlcode = 100 THEN
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(4)
             END IF
          END IF
       END IF
    ELSE
       IF sqlca.sqlcode = 100 THEN
          # Se a operacao for de estorno, eliminar o relacionamento.
          IF g_operacao IS NOT NULL THEN
             IF NOT geo1021_elimina_relacionamento(l_empresa_destino, l_num_nf,
                                                   l_ser_nf, l_ssr_nf,
                                                   l_fornecedor, " ", " ",
                                                   " "," "," "," ") THEN
                LET g_erro = TRUE
             END IF
          ELSE
             # Se não encontrar AD, gerar pendencia.
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(3)
             END IF
          END IF
       END IF
    END IF
 ELSE
    IF g_operacao IS NULL THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento do CONTAS A PAGAR não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#----------------------------------------------------------------------------------#
 FUNCTION geo1021_busca_valor_liquido(l_empresa, l_num_ap, l_num_versao, l_cod_moeda,
                                      l_val_ap_dat_pgto, l_val_nom_ap, l_moeda_padrao,
                                      l_comando)
#----------------------------------------------------------------------------------#
 DEFINE l_num_versao        LIKE ap.num_versao,
        l_cod_moeda         LIKE ap.cod_moeda,
        l_valor_liquido     LIKE ap.val_nom_ap,
        l_val_nom_ap        LIKE ap.val_nom_ap,
        l_val_ap_dat_pgto   LIKE ap.val_ap_dat_pgto,
        l_empresa           LIKE empresa.cod_empresa,
        l_num_ap            LIKE ap.num_ap,
        l_moeda_padrao      LIKE par_cap.cod_moeda_padrao,
        l_tipo_valor        LIKE mcx_par_padrao.parametro_val,
        l_comando           CHAR(10)

 DEFINE l_mostra_val_liq RECORD
                           cod_tip_val     LIKE tipo_valor.cod_tip_val,
                           ies_alt_val_pag LIKE tipo_valor.ies_alt_val_pag,
                           valor           LIKE ap_valores.valor
                         END RECORD

 WHENEVER ERROR CONTINUE
  SELECT parametro_val
    INTO l_tipo_valor
    FROM mcx_par_padrao
   WHERE empresa   = l_empresa
     AND parametro = "tip_val_baixa_cap"
 WHENEVER ERROR STOP

 IF l_moeda_padrao = l_cod_moeda THEN
    LET l_valor_liquido = l_val_nom_ap
 ELSE
    IF l_val_ap_dat_pgto <> 0 THEN
       LET l_valor_liquido = l_val_ap_dat_pgto
    ELSE
       LET l_valor_liquido = l_val_nom_ap
    END IF
 END IF

 IF l_comando = "control-e" THEN
    WHENEVER ERROR CONTINUE
     SELECT * FROM ap_valores
      WHERE cod_empresa = l_empresa
        AND num_ap      = l_num_ap
        AND cod_tip_val = l_tipo_valor
        AND ies_versao_atual = "S"
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       LET g_control_e = FALSE
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cl_mostra_liq CURSOR FOR
  SELECT a.cod_tip_val, a.ies_alt_val_pag, b.valor
    FROM tipo_valor a, ap_valores b
   WHERE b.cod_empresa      = l_empresa
     AND b.num_ap           = l_num_ap
     AND b.ies_versao_atual = "S"
     AND b.cod_tip_val      = a.cod_tip_val
     AND b.cod_empresa      = a.cod_empresa
     AND b.cod_tip_val     <> l_tipo_valor
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECAO","TIPO_VALOR-AP_VALORES")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cl_mostra_liq INTO l_mostra_val_liq.*
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("FOREACH","cl_mostra_liq")
 END IF

    IF l_mostra_val_liq.ies_alt_val_pag = "+" THEN
       LET l_valor_liquido = l_valor_liquido + l_mostra_val_liq.valor
    ELSE
       IF l_mostra_val_liq.ies_alt_val_pag = "-" THEN
          LET l_valor_liquido = l_valor_liquido - l_mostra_val_liq.valor
       END IF
    END IF

 END FOREACH

 RETURN l_valor_liquido

END FUNCTION

#-------------------------------------------------------------------------#
 FUNCTION geo1021_zerar_ap(l_empresa, l_num_versao, l_num_ap, l_val_docum)
#-------------------------------------------------------------------------#
 DEFINE l_tipo_valor   LIKE tipo_despesa.cod_tip_despesa,
        l_num_versao   LIKE ap.num_versao,
        l_num_ap       LIKE ap.num_ap,
        l_lote_pgto    LIKE ap.cod_lote_pgto,
        l_num_seq      LIKE ap_valores.num_seq,
        l_val_docum    LIKE ap.val_nom_ap,
        l_empresa      LIKE empresa.cod_empresa

 WHENEVER ERROR CONTINUE
  SELECT parametro_val
    INTO l_tipo_valor
    FROM mcx_par_padrao
   WHERE empresa   = l_empresa
     AND parametro = "tip_val_baixa_cap"
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  DELETE FROM ap_valores
   WHERE cod_empresa = l_empresa
     AND num_ap      = l_num_ap
     AND num_versao  = l_num_versao
     AND ies_versao_atual = "S"
     AND cod_tip_val = l_tipo_valor
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","AP_VALORES")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT MAX(num_seq)
    INTO l_num_seq
    FROM ap_valores
   WHERE cod_empresa = l_empresa
     AND num_ap      = l_num_ap
     AND num_versao  = l_num_versao
 WHENEVER ERROR STOP

 IF l_num_seq IS NULL THEN
    LET l_num_seq = 1
 ELSE
    LET l_num_seq = l_num_seq + 1
 END IF

 WHENEVER ERROR CONTINUE
  INSERT INTO ap_valores VALUES (l_empresa, l_num_ap,
                                 l_num_versao, "S", l_num_seq,
                                 l_tipo_valor, l_val_docum)
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT","AP_VALORES")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 {Este parametro "cod_lote_pgto_div" encontra-se no cap2360, opcao 7,
  opcao "Informacoes referentes a lotes de pagamentos defaults".
  É o campo Codigo do Lote para Pgto Diver.}

 WHENEVER ERROR CONTINUE
  SELECT par_num
    INTO l_lote_pgto
    FROM par_cap_pad
   WHERE cod_empresa   = l_empresa
     AND cod_parametro = 'cod_lote_pgto_div'
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  UPDATE ap
     SET dat_proposta     = m_mcx_movto.dat_movto,
         cod_lote_pgto    = l_lote_pgto,
         dat_pgto         = m_mcx_movto.dat_movto,
         ies_docum_pgto   = "3",
         ies_lib_pgto_cap = "S"
   WHERE cod_empresa = l_empresa
     AND num_versao  = l_num_versao
     AND num_ap      = l_num_ap
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("UPDATE","AP")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1021_verifica_baixou_cap(l_comando)
#-----------------------------------------------#
 DEFINE l_empresa_destino   LIKE mcx_mov_baixa_cap.empresa_destino,
        l_num_ap            LIKE mcx_mov_baixa_cap.autoriz_pagto,
        l_val_docum         LIKE ap_valores.valor,
        l_num_versao        LIKE ap.num_versao,
        l_moeda_padrao      LIKE par_cap.cod_moeda_padrao,
        l_val_nom_ap        LIKE ap.val_nom_ap,
        l_cod_moeda         LIKE ap.cod_moeda,
        l_val_ap_dat_pgto   LIKE ap.val_ap_dat_pgto,
        l_dat_pgto          LIKE ap.dat_pgto,
        l_dat_proposta      LIKE ap.dat_proposta,
        l_comando           CHAR(10),
        l_tipo_valor        LIKE mcx_par_padrao.parametro_val

 # Quando faço a baixa de uma AP, não permitir que o usuário consiga excluir
 # este lançamento no caixa.

 WHENEVER ERROR CONTINUE
 SELECT cod_moeda_padrao
   INTO l_moeda_padrao
   FROM par_cap
  WHERE cod_empresa = m_mcx_movto.empresa
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, autoriz_pagto
    INTO l_empresa_destino, l_num_ap
    FROM mcx_mov_baixa_cap
   WHERE empresa   = m_mcx_movto.empresa
     AND caixa     = m_mcx_movto.caixa
     AND dat_movto = m_mcx_movto.dat_movto
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT num_versao, val_nom_ap, cod_moeda, val_ap_dat_pgto, dat_pgto, dat_proposta
      INTO l_num_versao, l_val_nom_ap, l_cod_moeda, l_val_ap_dat_pgto, l_dat_pgto,
           l_dat_proposta
      FROM ap
     WHERE cod_empresa = l_empresa_destino
       AND num_ap      = l_num_ap
       AND ies_versao_atual = "S"
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       IF l_dat_pgto IS NOT NULL THEN
          LET g_control_e = FALSE
          IF g_operacao IS NOT NULL THEN
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(5)
             END IF
          ELSE
             CALL geo1021_busca_valor_liquido(l_empresa_destino, l_num_ap,
                                              l_num_versao, l_cod_moeda,
                                              l_val_ap_dat_pgto, l_val_nom_ap,
                                              l_moeda_padrao, l_comando)
                  RETURNING l_val_docum

             # Se o valor do documento for diferente do valor do movimento, gerar pendencia
             IF l_val_docum <> m_mcx_movto.val_docum THEN
                IF l_comando <> "control-e" THEN
                   CALL geo1021_gera_pendencias(2)
                END IF
             END IF
          END IF
       ELSE
          WHENEVER ERROR CONTINUE
          SELECT parametro_val
            INTO l_tipo_valor
            FROM mcx_par_padrao
           WHERE empresa   = l_empresa_destino
             AND parametro =  'tip_val_baixa_cap'
          WHENEVER ERROR STOP

          WHENEVER ERROR CONTINUE
          SELECT * from ap_valores
           WHERE cod_empresa      = l_empresa_destino
             AND num_ap           = l_num_ap
             AND cod_tip_val      = l_tipo_valor
             AND ies_versao_atual = 'S'
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> NOTFOUND THEN
             LET g_control_e = FALSE
          END IF

       END IF
       IF l_dat_proposta IS NOT NULL THEN
          LET g_control_e = FALSE
       END IF
    ELSE
       IF sqlca.sqlcode = 100 THEN
          IF g_operacao IS NOT NULL THEN
             IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ",
                                                   " ", l_num_ap, " ", " ", " ", " ",
                                                   " ") THEN
                LET g_erro = TRUE
             END IF
          ELSE
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(1)
             END IF
          END IF
       END IF
    END IF
 ELSE
    IF g_operacao IS NULL THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento de Baixa do CONTAS A PAGAR não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#-----------------------------#
 FUNCTION geo1021_gerou_movto()
#-----------------------------#
 WHENEVER ERROR CONTINUE
  SELECT * FROM mcx_movto
   WHERE empresa   = m_mcx_movto.empresa
     AND caixa     = m_mcx_movto.caixa
     AND dat_movto = m_mcx_movto.dat_movto
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    # Significa que é um registro novo.
    RETURN TRUE
 END IF

 RETURN FALSE

END FUNCTION

#-------------------------------------------------------------#
 FUNCTION geo1021_busca_tratamento_mcx(l_empresa, l_tip_docum)
#-------------------------------------------------------------#
 DEFINE l_par_existencia   CHAR(01),
        l_empresa          CHAR(02),
        l_tip_docum        LIKE cre_tip_doc_compl.tip_docum

 INITIALIZE l_par_existencia TO NULL

 #---------#
 #OS 473239#
 #---------#
 WHENEVER ERROR CONTINUE
 SELECT par_existencia
        #parametro_texto
   INTO l_par_existencia
   FROM cre_tip_doc_compl
  WHERE empresa   = l_empresa
    AND tip_docum = l_tip_docum
    AND campo     = 'tratamento mcx'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 100 THEN
 ELSE
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("LEITURA","CRE_TIP_DOC_COMPL")
    END IF
 END IF

 RETURN l_par_existencia

END FUNCTION

#-----------------------------------------------#
 FUNCTION geo1021_verifica_baixou_cre(l_comando)
#-----------------------------------------------#
 DEFINE l_comando          CHAR(10),
        l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_seq_docum        LIKE mcx_mov_baixa_cre.sequencia_docum,
        l_tip_docum        LIKE mcx_mov_baixa_cre.tip_docum,
        l_cod_cliente      LIKE mcx_mov_baixa_cre.cliente,
        l_encontrou        SMALLINT,
        l_par_existencia   CHAR(01)

 # Quando faço a baixa de uma duplicata, não permitir que o usuário consiga excluir
 # este lançamento no caixa.

 LET l_encontrou = TRUE

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, tip_docum, sequencia_docum, cliente
    INTO l_empresa_destino, l_tip_docum, l_seq_docum, l_cod_cliente
    FROM mcx_mov_baixa_cre
   WHERE empresa   = m_mcx_movto.empresa
     AND caixa     = m_mcx_movto.caixa
     AND dat_movto = m_mcx_movto.dat_movto
     AND docum     = m_mcx_movto.docum
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    LET l_encontrou       = FALSE
    LET l_empresa_destino = m_empresa
    LET l_tip_docum       = m_tip_docum
    LET l_cod_cliente     = m_cod_cliente
 ELSE
    LET m_empresa     = l_empresa_destino
    LET m_tip_docum   = l_tip_docum
    LET m_cod_cliente = l_cod_cliente
 END IF

 IF l_empresa_destino IS NULL OR l_empresa_destino = " " THEN
    LET l_empresa_destino = m_mcx_movto.empresa
 END IF

 CALL geo1021_busca_tratamento_mcx(l_empresa_destino,m_tip_docum)
      RETURNING l_par_existencia

 IF l_par_existencia IS NOT NULL THEN
    CASE l_par_existencia
      WHEN '1'
         CALL geo1021_verifica_adto_dev(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN '2'
         CALL geo1021_verifica_dp(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN '3'
         CALL geo1021_verifica_docum1(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
    END CASE
 ELSE
    CASE m_tip_docum
      WHEN "AD" CALL geo1021_verifica_adto_dev(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN "DP" CALL geo1021_verifica_dp(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN "ND" CALL geo1021_verifica_dp(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN "NC" CALL geo1021_verifica_docum1(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN "NS" CALL geo1021_verifica_docum1(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
      WHEN "NP" CALL geo1021_verifica_docum1(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
    END CASE
 END IF

END FUNCTION

#---------------------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_dp(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
#---------------------------------------------------------------------------------------#
 DEFINE l_ies_pgto_docum   LIKE docum.ies_pgto_docum,
        l_docum_pgto       RECORD LIKE docum_pgto.*,
        l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_max_seq_docum    LIKE docum_pgto.num_seq_docum,
        l_seq_docum        LIKE mcx_mov_baixa_cre.sequencia_docum,
        l_comando          CHAR(10),
        l_encontrou        SMALLINT

 IF NOT l_encontrou THEN
    IF l_comando = "mcx0007" THEN
       SELECT MAX(num_seq_docum)
         INTO l_max_seq_docum
         FROM docum_pgto
        WHERE cod_empresa   = l_empresa_destino
          AND num_docum     = m_mcx_movto.docum
          AND ies_tip_docum = m_tip_docum

       IF l_max_seq_docum <= g_seq_docum_cre OR
          l_max_seq_docum IS NULL THEN
#          CALL log0030_mensagem('Baixa não efetuada com sucesso no CRE2','info')
 #         LET l_max_seq_docum = NULL
       END IF
    ELSE
       LET l_max_seq_docum = l_seq_docum
    END IF
 ELSE
    LET l_max_seq_docum = l_seq_docum
 END IF

 WHENEVER ERROR CONTINUE
  SELECT *
    INTO l_docum_pgto.*
    FROM docum_pgto
   WHERE cod_empresa   = l_empresa_destino
     AND num_docum     = m_mcx_movto.docum
     AND ies_tip_docum = m_tip_docum
     AND num_seq_docum = l_max_seq_docum
   ORDER BY num_seq_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF l_comando = "control-e" THEN
       LET g_control_e = FALSE
       RETURN
    END IF
    WHENEVER ERROR CONTINUE
     SELECT * FROM mcx_mov_baixa_cre
      WHERE empresa         = m_mcx_movto.empresa
        AND caixa           = m_mcx_movto.caixa
        AND dat_movto       = m_mcx_movto.dat_movto
        AND sequencia_caixa = m_mcx_movto.sequencia_caixa
        AND empresa_destino = l_empresa_destino
        AND docum           = m_mcx_movto.docum
        AND tip_docum       = m_tip_docum
        AND sequencia_docum = l_docum_pgto.num_seq_docum
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 100 THEN
       WHENEVER ERROR CONTINUE
        INSERT INTO mcx_mov_baixa_cre VALUES (m_mcx_movto.empresa,
                                              m_mcx_movto.caixa,
                                              m_mcx_movto.dat_movto,
                                              m_mcx_movto.sequencia_caixa,
                                              l_empresa_destino,
                                              m_mcx_movto.docum,
                                              m_tip_docum,
                                              l_docum_pgto.num_seq_docum,
                                              m_cod_cliente)
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT 1","mcx_mov_baixa_cre")
          LET g_erro = TRUE
          RETURN
       END IF
    END IF
 END IF

 WHENEVER ERROR CONTINUE
  SELECT ies_pgto_docum
    INTO l_ies_pgto_docum
    FROM docum
   WHERE cod_empresa   = l_empresa_destino
     AND num_docum     = m_mcx_movto.docum
     AND ies_tip_docum = m_tip_docum
 WHENEVER ERROR STOP

 IF l_ies_pgto_docum = 'A' THEN
    IF l_comando <> "control-e" THEN
       LET g_control_e = FALSE
       LET g_docum_baixado = FALSE
    END IF
    RETURN
 END IF

 CALL geo1021_verifica_baixa_total(l_comando,l_empresa_destino,l_ies_pgto_docum,
                                   l_docum_pgto.num_seq_docum)

END FUNCTION

#--------------------------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_baixa_total(l_comando, l_empresa_destino, l_ies_pgto_docum, l_seq)
#--------------------------------------------------------------------------------------------#
 DEFINE l_tip_docum        LIKE mcx_mov_baixa_cre.tip_docum,
        l_val_docum        LIKE mcx_movto.val_docum,
        l_ies_pgto_docum   LIKE docum.ies_pgto_docum,
        l_seq              LIKE docum_pgto.num_seq_docum,
        l_comando          CHAR(10),
        l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino

 WHENEVER ERROR CONTINUE
 SELECT (a.val_pago + a.val_desp_cartorio + a.val_despesas), b.ies_tip_docum
   INTO l_val_docum, l_tip_docum
   FROM docum_pgto a, docum b
  WHERE a.cod_empresa    = l_empresa_destino
    AND a.num_docum      = m_mcx_movto.docum
    AND a.cod_empresa    = b.cod_empresa
    AND a.num_docum      = b.num_docum
    AND a.ies_tip_docum  = b.ies_tip_docum
    AND num_seq_docum    = l_seq
    AND ies_pgto_docum   = l_ies_pgto_docum
    AND b.ies_tip_docum  = m_tip_docum 
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    IF g_operacao IS NOT NULL THEN
       IF l_comando <> "control-e" THEN
          CALL geo1021_gera_pendencias(5)
       END IF
    ELSE
       #Verificar o valor pago somente no fechamento.
       CASE l_comando
         WHEN "mcx0007" LET m_mcx_movto.val_docum = l_val_docum
         WHEN "mcx0008"
          IF l_val_docum <> m_mcx_movto.val_docum THEN
             CALL geo1021_gera_pendencias(2)
          END IF
       END CASE
    END IF
 ELSE
    IF sqlca.sqlcode = 100 THEN
       IF g_operacao IS NOT NULL THEN
          IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ", " ",
                                                " ",m_mcx_movto.docum,
                                                l_tip_docum, " ", " ", l_seq) THEN
             LET g_erro = TRUE
          END IF
       ELSE
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(9)
          END IF
       END IF
    END IF
 END IF

END FUNCTION

#-------------------------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_adto_dev(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
#-------------------------------------------------------------------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_seq_docum        LIKE mcx_mov_baixa_cre.sequencia_docum,
        l_dev_adiant       RECORD LIKE dev_adiant.*,
        l_num_seq_devol    LIKE dev_adiant.num_seq_devol,
        l_saldo_atual      LIKE adiant_cred.val_adiant,
        l_comando          CHAR(10),
        l_encontrou        SMALLINT

 IF NOT l_encontrou THEN
    IF l_comando = "mcx0007" THEN
       SELECT MAX(num_seq_devol)
         INTO l_num_seq_devol
         FROM dev_adiant
        WHERE cod_empresa = l_empresa_destino
          AND num_pedido  = m_mcx_movto.docum
          AND ies_tip_reg = "A"
          AND cod_cliente = m_cod_cliente

       IF l_num_seq_devol <= g_seq_docum_cre OR
          l_num_seq_devol IS NULL THEN
          CALL log0030_mensagem('Baixa não efetuada com sucesso no CRE3','info')
          LET l_num_seq_devol = NULL
       END IF
    ELSE
       LET l_num_seq_devol = l_seq_docum
    END IF
 ELSE
    LET l_num_seq_devol = l_seq_docum
 END IF

 WHENEVER ERROR CONTINUE
  SELECT *
    INTO l_dev_adiant.*
    FROM dev_adiant
   WHERE cod_empresa   = l_empresa_destino
     AND num_pedido    = m_mcx_movto.docum
     AND ies_tip_reg   = "A"
     AND num_seq_devol = l_num_seq_devol
     AND cod_cliente   = m_cod_cliente
   ORDER BY num_seq_devol
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     SELECT * FROM mcx_mov_baixa_cre
      WHERE empresa         = m_mcx_movto.empresa
        AND caixa           = m_mcx_movto.caixa
        AND dat_movto       = m_mcx_movto.dat_movto
        AND sequencia_caixa = m_mcx_movto.sequencia_caixa
        AND empresa_destino = l_empresa_destino
        AND docum           = m_mcx_movto.docum
        AND tip_docum       = m_tip_docum
        AND sequencia_docum = l_dev_adiant.num_seq_devol
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 100 THEN
       WHENEVER ERROR CONTINUE
        INSERT INTO mcx_mov_baixa_cre VALUES (m_mcx_movto.empresa,
                                              m_mcx_movto.caixa,
                                              m_mcx_movto.dat_movto,
                                              m_mcx_movto.sequencia_caixa,
                                              l_empresa_destino,
                                              m_mcx_movto.docum,
                                              m_tip_docum,
                                              l_dev_adiant.num_seq_devol,
                                              m_cod_cliente)
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT 2","mcx_mov_baixa_cre")
          LET g_erro = TRUE
          RETURN
       END IF
    END IF
    LET g_control_e = FALSE
    CALL geo1021_verifica_dev_total(l_comando,l_empresa_destino,l_dev_adiant.num_seq_devol)
         RETURNING l_saldo_atual

    #Verificar o valor da devolução somente no fechamento.
    CASE l_comando
      WHEN "mcx0007" LET m_mcx_movto.val_docum = l_dev_adiant.val_devol
      WHEN "mcx0008"
       IF l_dev_adiant.val_devol <> m_mcx_movto.val_docum THEN
          CALL geo1021_gera_pendencias(2)
       END IF
    END CASE
 ELSE
    IF sqlca.sqlcode = 100 THEN
       IF g_operacao IS NOT NULL THEN
          IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ", " ",
                                                " ",m_mcx_movto.docum,
                                                m_tip_docum, " ", " ",
                                                m_mcx_movto.sequencia_caixa) THEN
             LET g_erro = TRUE
          END IF
          LET g_control_e = TRUE
       ELSE
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(1)
          END IF
       END IF
    END IF
 END IF

END FUNCTION

#--------------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_dev_total(l_comando,l_empresa_destino,l_num_seq_devol)
#--------------------------------------------------------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_seq_devol    LIKE dev_adiant.num_seq_devol,
        l_saldo            LIKE adiant_cred.val_adiant,
        l_saldo_atual      LIKE adiant_cred.val_adiant,
        l_pgto_atual       LIKE adiant_cred.val_adiant,
        l_juro_atual       LIKE adiant_cred.val_adiant,
        l_devol_atual      LIKE adiant_cred.val_adiant,
        l_comando          CHAR(10)

 INITIALIZE l_saldo, l_saldo_atual, l_pgto_atual, l_juro_atual, l_devol_atual TO NULL

 SELECT SUM(val_adiant)
   INTO l_saldo
   FROM adiant_cred
  WHERE cod_empresa = l_empresa_destino
    AND cod_cliente = m_cod_cliente
    AND ies_tip_reg = "A"
    AND num_pedido  = m_mcx_movto.docum

 IF sqlca.sqlcode <> 0 OR l_saldo IS NULL THEN
    LET l_saldo = 0
 END IF

 SELECT SUM(val_pgto), SUM(val_juro)
   INTO l_pgto_atual, l_juro_atual
   FROM bxa_adiant
  WHERE cod_emp_adiant = l_empresa_destino
    AND cod_cliente = m_cod_cliente
    AND ies_tip_reg = "A"
    AND num_pedido  = m_mcx_movto.docum

 IF sqlca.sqlcode <> 0 THEN
    LET l_pgto_atual = 0
    LET l_juro_atual = 0
 END IF

 IF l_pgto_atual IS NULL THEN
    LET l_pgto_atual = 0
 END IF
 IF l_juro_atual IS NULL THEN
    LET l_juro_atual = 0
 END IF

	SELECT SUM(val_devol)
	 INTO l_devol_atual
	 FROM dev_adiant
	WHERE cod_empresa = l_empresa_destino
	  AND cod_cliente = m_cod_cliente
	  AND ies_tip_reg = "A"
	  AND num_pedido  = m_mcx_movto.docum

	IF sqlca.sqlcode <> 0 OR l_devol_atual IS NULL THEN
	   LET l_devol_atual = 0
	END IF

 LET l_saldo_atual = l_saldo - (l_juro_atual + l_pgto_atual + l_devol_atual)

 RETURN l_saldo_atual

END FUNCTION

#-----------------------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_docum1(l_empresa_destino, l_seq_docum, l_comando, l_encontrou)
#-----------------------------------------------------------------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_gera_cre.empresa_destino,
        l_docum            RECORD LIKE docum.*,
        l_val_docum        LIKE docum_pgto.val_pago,
        l_ies_pgto_docum   LIKE docum.ies_pgto_docum,
        l_seq_docum        LIKE docum_pgto.num_seq_docum,
        l_max_seq_docum    LIKE docum_pgto.num_seq_docum,
        l_comando          CHAR(10),
        l_encontrou        SMALLINT

 IF NOT l_encontrou THEN
    IF l_comando = "mcx0007" THEN
       SELECT MAX(num_seq_docum)
         INTO l_max_seq_docum
         FROM docum_pgto
        WHERE cod_empresa   = l_empresa_destino
          AND num_docum     = m_mcx_movto.docum
          AND ies_tip_docum = m_tip_docum

       IF l_max_seq_docum <= g_seq_docum_cre OR
          l_max_seq_docum IS NULL THEN
          CALL log0030_mensagem('Baixa não efetuada com sucesso no CRE1','info')
          LET l_max_seq_docum = NULL
       END IF
    ELSE
       LET l_max_seq_docum = l_seq_docum
    END IF
 ELSE
    LET l_max_seq_docum = l_seq_docum
 END IF


 WHENEVER ERROR CONTINUE
  SELECT *
    INTO l_docum.*
    FROM docum
   WHERE cod_empresa   = l_empresa_destino
     AND num_docum     = m_mcx_movto.docum
     AND ies_tip_docum = m_tip_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     SELECT cod_empresa
       FROM docum_pgto
      WHERE cod_empresa   = l_empresa_destino
        AND num_docum     = m_mcx_movto.docum
        AND ies_tip_docum = m_tip_docum
        AND num_seq_docum = l_max_seq_docum
      ORDER BY num_seq_docum
    WHENEVER ERROR STOP
 END IF

 IF SQLCA.sqlcode = 0 THEN
    IF l_docum.ies_pgto_docum = 'A' THEN
       IF l_comando <> "control-e" THEN
          LET g_control_e = FALSE
          LET g_docum_baixado = FALSE
       END IF
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
     SELECT * FROM mcx_mov_baixa_cre
      WHERE empresa         = m_mcx_movto.empresa
        AND caixa           = m_mcx_movto.caixa
        AND dat_movto       = m_mcx_movto.dat_movto
        AND sequencia_caixa = m_mcx_movto.sequencia_caixa
        AND empresa_destino = l_empresa_destino
        AND docum           = m_mcx_movto.docum
        AND tip_docum       = m_tip_docum
        AND sequencia_docum = l_max_seq_docum
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 100 THEN
       WHENEVER ERROR CONTINUE
        INSERT INTO mcx_mov_baixa_cre VALUES (m_mcx_movto.empresa,
                                              m_mcx_movto.caixa,
                                              m_mcx_movto.dat_movto,
                                              m_mcx_movto.sequencia_caixa,
                                              l_empresa_destino,
                                              m_mcx_movto.docum,
                                              m_tip_docum,
                                              l_max_seq_docum,
                                              m_cod_cliente)
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("INSERT 3","mcx_mov_baixa_cre")
          LET g_erro = TRUE
          RETURN
       END IF
    END IF
    LET g_control_e = FALSE

    # Buscar o valor líquido do documento, sem juros nem acréscimos.
    WHENEVER ERROR CONTINUE
    SELECT (a.val_pago + a.val_desp_cartorio + a.val_despesas)
      INTO l_val_docum
      FROM docum_pgto a, docum b
     WHERE a.cod_empresa    = l_empresa_destino
       AND a.num_docum      = m_mcx_movto.docum
       AND a.cod_empresa    = b.cod_empresa
       AND a.num_docum      = b.num_docum
       AND a.ies_tip_docum  = b.ies_tip_docum
       AND num_seq_docum    = l_max_seq_docum
       AND b.ies_tip_docum  = m_tip_docum
    WHENEVER ERROR STOP

    #Verificar o valor do documento somente no fechamento.
    CASE l_comando
      WHEN "mcx0007" LET m_mcx_movto.val_docum = l_val_docum
      WHEN "mcx0008"
       IF l_val_docum <> m_mcx_movto.val_docum THEN
          CALL geo1021_gera_pendencias(2)
       END IF
    END CASE
 ELSE
    IF sqlca.sqlcode = 100 THEN
       IF g_operacao IS NOT NULL THEN
          IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ", " ",
                                                " ",m_mcx_movto.docum,
                                                m_tip_docum, " ", " ",
                                                m_mcx_movto.sequencia_caixa) THEN
             LET g_erro = TRUE
          END IF
          LET g_control_e = TRUE
       ELSE
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(1)
          END IF
       END IF
    END IF
 END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION geo1021_verifica_gerou_cre(l_comando)
#----------------------------------------------#
 DEFINE l_empresa_destino    LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_lote           LIKE mcx_movto_gera_cre.lote,
        l_num_docum          LIKE mcx_movto_gera_cre.docum,
        l_tip_docum          LIKE mcx_movto_gera_cre.tip_docum,
        l_dat_vencto_s_desc  LIKE mcx_movto_gera_cre.dat_vencto_sdesc,
        l_cliente            LIKE mcx_movto_gera_cre.cliente,
        l_val_bruto          LIKE mcx_movto_gera_cre.val_bruto,
        l_dat_emis           LIKE mcx_movto_gera_cre.dat_emissao,
        l_comando            CHAR(10),
        l_par_existencia     CHAR(01)

 LET l_par_existencia =  NULL

 #---------#
 #OS 473239#
 #---------#
 CALL geo1021_busca_tratamento_mcx(l_empresa_destino,l_tip_docum)
      RETURNING l_par_existencia

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, lote_cre, docum, tip_docum, cliente,
         val_bruto, dat_emissao
    INTO l_empresa_destino, l_num_lote, l_num_docum, l_tip_docum, l_cliente,
         l_val_bruto, l_dat_emis
    FROM mcx_movto_gera_cre
   WHERE empresa   = m_mcx_movto.empresa
     AND caixa     = m_mcx_movto.caixa
     AND dat_movto = m_mcx_movto.dat_movto
     AND docum     = m_mcx_movto.docum
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    IF l_par_existencia IS NOT NULL THEN
       CASE l_par_existencia
          WHEN "1" CALL geo1021_verifica_adto(l_empresa_destino, l_cliente,
                                               l_num_docum, l_tip_docum, l_num_lote,
                                               l_val_bruto, l_dat_emis, l_comando)
          WHEN "2" CALL geo1021_verifica_adocum(l_empresa_destino, l_num_lote, l_num_docum,
                                                 l_tip_docum, l_val_bruto, l_comando)
          WHEN "3" CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                                l_val_bruto, l_num_lote, l_comando, 2)

       END CASE
    ELSE
       CASE l_tip_docum
          WHEN "AD" CALL geo1021_verifica_adto(l_empresa_destino, l_cliente,
                                               l_num_docum, l_tip_docum, l_num_lote,
                                               l_val_bruto, l_dat_emis, l_comando)

          WHEN "DP" CALL geo1021_verifica_adocum(l_empresa_destino, l_num_lote, l_num_docum,
                                                 l_tip_docum, l_val_bruto, l_comando)

          WHEN "ND" CALL geo1021_verifica_adocum(l_empresa_destino, l_num_lote, l_num_docum,
                                                 l_tip_docum, l_val_bruto, l_comando)

          WHEN "NS" CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                                l_val_bruto, l_num_lote, l_comando, 2)

          WHEN "NP" CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                                l_val_bruto, l_num_lote, l_comando, 2)

          WHEN "NC" CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                                l_val_bruto, l_num_lote, l_comando, 2)

       END CASE
    END IF
 ELSE
    IF g_operacao IS NULL THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento do CONTAS A RECEBER não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_adto(l_empresa_destino, l_cliente, l_num_docum,
                                l_tip_docum, l_num_lote, l_val_bruto,
                                l_dat_emis,l_comando)
#----------------------------------------------------------------------------#
 DEFINE l_empresa_destino    LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_lote           LIKE mcx_movto_gera_cre.lote,
        l_num_docum          LIKE mcx_movto_gera_cre.docum,
        l_tip_docum          LIKE mcx_movto_gera_cre.tip_docum,
        l_cliente            LIKE mcx_movto_gera_cre.cliente,
        l_val_bruto          LIKE mcx_movto_gera_cre.val_bruto,
        l_val_adiant         LIKE adiant_cred.val_adiant,
        l_portador_cre       LIKE mcx_oper_caixa_cre.portador_cre,
        l_tip_portador_cre   LIKE mcx_oper_caixa_cre.tip_portador_cre,
        l_dat_emis           LIKE mcx_movto_gera_cre.dat_emissao,
        l_comando            CHAR(10)

 SELECT portador_cre, tip_portador_cre
   INTO l_portador_cre, l_tip_portador_cre
   FROM mcx_oper_caixa_cre
  WHERE empresa  = p_cod_empresa
    AND operacao = m_mcx_movto.operacao

 WHENEVER ERROR CONTINUE
  SELECT val_adiant
    INTO l_val_adiant
    FROM adiant_cred
   WHERE cod_empresa   = l_empresa_destino
     AND cod_cliente   = l_cliente
     AND ies_tip_reg   = "A"
     AND num_pedido    = l_num_docum
     AND cod_portador  = l_portador_cre
     AND ies_tip_portador = l_tip_portador_cre
     AND dat_emissao   = l_dat_emis
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    LET g_control_e = FALSE
    IF g_operacao IS NOT NULL THEN
       IF l_comando <> "control-e" THEN
          CALL geo1021_gera_pendencias(5)
       END IF
    ELSE
       IF l_comando <> "control-e" THEN
          IF l_val_adiant <> l_val_bruto THEN
             CALL geo1021_gera_pendencias(2)
          END IF
       END IF
    END IF
 ELSE
    IF g_operacao IS NOT NULL THEN
       IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ", " ", " ",
                                             l_num_docum, l_tip_docum, l_num_lote, " ",
                                             " ") THEN
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#-----------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_adocum(l_empresa_destino, l_num_lote, l_num_docum,
                                  l_tip_docum, l_val_bruto, l_comando)
#-----------------------------------------------------------------------------#
 DEFINE l_empresa_destino    LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_lote           LIKE mcx_movto_gera_cre.lote,
        l_num_docum          LIKE mcx_movto_gera_cre.docum,
        l_tip_docum          LIKE mcx_movto_gera_cre.tip_docum,
        l_val_bruto          LIKE mcx_movto_gera_cre.val_bruto,
        l_valor              LIKE adocum.val_bruto,
        l_situa_dados        LIKE adocum.ies_situa_dados,
        l_comando            CHAR(10)

 WHENEVER ERROR CONTINUE
  SELECT ies_situa_dados, val_liquido
    INTO l_situa_dados, l_valor
    FROM adocum
   WHERE cod_empresa   = l_empresa_destino
     AND num_lote      = l_num_lote
     AND ies_tip_reg   = "I"
     AND num_docum     = l_num_docum
     AND ies_tip_docum = l_tip_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    LET g_control_e = FALSE
    IF l_comando = "mcx0007" THEN
       IF l_valor <> l_val_bruto THEN
          CALL geo1021_gera_pendencias(2)
       END IF
    ELSE
       IF l_comando = "mcx0008" THEN
          IF l_situa_dados IS NOT NULL OR l_situa_dados <> " " THEN
             CASE l_situa_dados
               WHEN "S" LET m_empresa1 = l_empresa_destino
                        LET m_lote     = l_num_lote
                        CALL geo1021_gera_pendencias(7)
               WHEN "N" LET m_empresa1 = l_empresa_destino
                        LET m_lote     = l_num_lote
                        CALL geo1021_gera_pendencias(6)
               WHEN "A" CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum,
                                                    l_tip_docum, l_val_bruto,
                                                    l_num_lote, l_comando, 1)
             END CASE
          ELSE
             LET m_empresa1 = l_empresa_destino
             LET m_lote     = l_num_lote
             CALL geo1021_gera_pendencias(6)
          END IF
       END IF
    END IF
 ELSE
    CALL geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                l_val_bruto, l_num_lote, l_comando, 2)
 END IF

END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION geo1021_verifica_docum(l_empresa_destino, l_num_docum, l_tip_docum,
                                 l_val_bruto, l_num_lote, l_comando, l_ind)
#----------------------------------------------------------------------------#
 DEFINE l_empresa_destino    LIKE mcx_movto_gera_cre.empresa_destino,
        l_num_docum          LIKE mcx_movto_gera_cre.docum,
        l_tip_docum          LIKE mcx_movto_gera_cre.tip_docum,
        l_val_bruto          LIKE mcx_movto_gera_cre.val_bruto,
        l_valor              LIKE docum.val_saldo,
        l_num_lote           LIKE mcx_movto_gera_cre.lote,
        l_comando            CHAR(10),
        l_ind                SMALLINT

 WHENEVER ERROR CONTINUE
  SELECT val_liquido
    INTO l_valor
    FROM docum
   WHERE cod_empresa = l_empresa_destino
     AND num_docum   = l_num_docum
     AND ies_tip_docum = l_tip_docum
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 0 THEN
    LET g_control_e = FALSE
    IF l_valor IS NOT NULL OR l_valor <> " " THEN
       IF l_val_bruto <> l_valor THEN
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(2)
          END IF
       END IF
    END IF
 ELSE
    IF l_ind = 1 THEN
       LET m_empresa1 = l_empresa_destino
       LET m_lote     = l_num_lote
       CALL geo1021_gera_pendencias(6)
    ELSE
       CALL geo1021_gera_pendencias(1)
    END IF
 END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION geo1021_verifica_gerou_sup(l_comando)
#----------------------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_sup.empresa_destino,
        l_num_nf           LIKE mcx_movto_sup.nota_fiscal,
        l_ser_nf           LIKE mcx_movto_sup.serie_nota_fiscal,
        l_ssr_nf           LIKE mcx_movto_sup.subserie_nf,
        l_especie_nf       LIKE mcx_movto_sup.espc_nota_fiscal,
        l_fornecedor       LIKE mcx_movto_sup.fornecedor,
        l_val_docum        LIKE nf_sup.val_tot_nf_d,
        l_comando          CHAR(10)

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, nota_fiscal, serie_nota_fiscal, subserie_nf, espc_nota_fiscal, fornecedor
    INTO l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf, l_especie_nf, l_fornecedor
    FROM mcx_movto_sup
   WHERE empresa         = m_mcx_movto.empresa
     AND caixa           = m_mcx_movto.caixa
     AND dat_movto       = m_mcx_movto.dat_movto
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    WHENEVER ERROR CONTINUE
     SELECT empresa_destino, nota_fiscal, serie_nota_fiscal, subserie_nf, espc_nota_fiscal, fornecedor
       INTO l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf, l_especie_nf, l_fornecedor
       FROM mcx_movto_sup
      WHERE empresa   = m_mcx_movto.empresa
        AND caixa     = m_mcx_movto.caixa
        AND dat_movto = m_mcx_movto.dat_movto
        AND nota_fiscal = m_mcx_movto.docum
    WHENEVER ERROR STOP
 END IF

 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT val_tot_nf_d
      INTO l_val_docum
      FROM nf_sup, cond_pgto_cap
     WHERE cod_empresa    = l_empresa_destino
       AND num_nf         = l_num_nf
       AND ser_nf         = l_ser_nf
       AND ssr_nf         = l_ssr_nf
       AND ies_especie_nf = l_especie_nf
       AND cod_fornecedor = l_fornecedor
       AND cnd_pgto_nf    = cnd_pgto
       AND ies_pagamento  = "3"

    IF SQLCA.sqlcode = 0 THEN
       IF g_operacao IS NOT NULL THEN
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(5)
          ELSE
             LET g_control_e = FALSE
          END IF
       ELSE
          IF l_val_docum <> m_mcx_movto.val_docum THEN
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(2)
             ELSE
                LET g_control_e = FALSE
             END IF
          ELSE
             IF l_comando = "control-e" THEN
                LET g_control_e = FALSE
             END IF
          END IF
       END IF
    ELSE
       IF sqlca.sqlcode = 100 THEN
          IF g_operacao IS NOT NULL THEN
             IF NOT geo1021_elimina_relacionamento(l_empresa_destino, l_num_nf, l_ser_nf,
                                                   l_ssr_nf, l_fornecedor, " ", " ", " ",
                                                   " ", l_especie_nf, " ") THEN
                LET g_erro = TRUE
             END IF
          ELSE
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(1)
             END IF
          END IF
       END IF
    END IF
 ELSE
    IF g_operacao IS NULL THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento do SUPRIMENTOS não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#----------------------------------------------#
 FUNCTION geo1021_verifica_gerou_trb(l_comando)
#----------------------------------------------#
 DEFINE l_empresa_destino  LIKE mcx_movto_trb.empresa_destino,
        l_lote             LIKE mcx_movto_trb.lote,
        l_sequencia        LIKE mcx_movto_trb.sequencia_docum,
        l_val_docum        LIKE mcx_movto.val_docum,
        l_comando          CHAR(10)

 WHENEVER ERROR CONTINUE
  SELECT empresa_destino, lote, sequencia_docum
    INTO l_empresa_destino, l_lote, l_sequencia
    FROM mcx_movto_trb
   WHERE empresa   = m_mcx_movto.empresa
     AND caixa     = m_mcx_movto.caixa
     AND dat_movto = m_mcx_movto.dat_movto
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
     SELECT val_docum
       INTO l_val_docum
       FROM movfin
      WHERE cod_empresa = l_empresa_destino
        AND num_lote    = l_lote
        AND seq_dig     = l_sequencia
    WHENEVER ERROR STOP

    IF SQLCA.sqlcode = 0 THEN
       IF g_operacao IS NOT NULL THEN
          IF l_comando <> "control-e" THEN
             CALL geo1021_gera_pendencias(5)
          ELSE
             LET g_control_e = TRUE
          END IF
       ELSE
          IF l_val_docum <> m_mcx_movto.val_docum THEN
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(2)
             ELSE
                LET g_control_e = FALSE
             END IF
          ELSE
             IF l_comando = "control-e" THEN
                LET g_control_e = TRUE
             END IF
          END IF
       END IF
    ELSE
       IF sqlca.sqlcode = 100 THEN
          IF g_operacao IS NOT NULL THEN
             IF NOT geo1021_elimina_relacionamento(l_empresa_destino, " ", " ", " ",
                                                   " ", " ", " ", " ", l_lote,
                                                   " ", l_sequencia) THEN
                LET g_erro = TRUE
             END IF
          ELSE
             IF l_comando <> "control-e" THEN
                CALL geo1021_gera_pendencias(1)
             END IF
          END IF
       END IF
    END IF
 ELSE
    IF g_operacao IS NULL THEN
       IF m_mcx_movto.docum IS NOT NULL THEN
          CALL log0030_mensagem("Movimento do TRANSAÇÕES BANCÁRIAS não existente no MCX.","info")
          LET g_erro = TRUE
       END IF
    END IF
 END IF

END FUNCTION

#----------------------------------------#
 FUNCTION geo1021_gera_pendencias(l_cont)
#----------------------------------------#
 DEFINE l_cont       SMALLINT,
        l_modulo     CHAR(03),
        l_historico  LIKE mcx_pendencia.hist,
        l_lote       CHAR(03)

 CASE g_modulo
    WHEN "CAP"  LET l_modulo = "CAP"
    WHEN "CAP1" LET l_modulo = "CAP"
    WHEN "SUP"  LET l_modulo = "SUP"
    WHEN "CRE"  LET l_modulo = "CRE"
    WHEN "CRE1" LET l_modulo = "CRE"
    WHEN "TRB"  LET l_modulo = "TRB"
    WHEN "TRA"  LET l_modulo = "TRA"
 END CASE

 LET l_lote = m_lote

 CASE l_cont
    WHEN 1 LET l_historico = "DOCUMENTO NAO GERADO NO MODULO ",l_modulo,"."
    WHEN 2 LET l_historico = "VALOR DOCUMENTO DIFERE NO ",l_modulo,"."
    WHEN 3 LET l_historico = "AD NAO ENCONTRADA NO MODULO CAP."
    WHEN 4 LET l_historico = "AP NAO ENCONTRADA NO MODULO CAP."
    WHEN 5 LET l_historico = "MOVIMENTO ESTORNADO AINDA EM ABERTO NO ",l_modulo,"."
    WHEN 6 LET l_historico = "LOTE ",l_lote, " DA EMPRESA ",m_empresa1," NAO CONSISTIDO NO CRE."
    WHEN 7 LET l_historico = "LOTE ",l_lote, " DA EMPRESA ",m_empresa1, " COM ERRO CONSISTENCIA."
    WHEN 8 LET l_historico = "DOCUMENTO EM ABERTO, NAO FOI BAIXADO PELO CRE."
    WHEN 9 LET l_historico = "DOCUMENTO NAO BAIXADO NO MODULO ",l_modulo,"."
 END CASE

 IF m_mcx_movto.docum <> "X" THEN
    IF m_mcx_movto.docum IS NOT NULL THEN
       IF m_mcx_movto.val_docum IS NULL THEN
          LET m_mcx_movto.val_docum = 0
       END IF
       IF geo1021_verifica_pend(l_modulo) THEN
          WHENEVER ERROR CONTINUE
           INSERT INTO mcx_pendencia VALUES (m_mcx_movto.empresa,
                                             m_mcx_movto.caixa,
                                             m_mcx_movto.dat_movto, l_modulo,
                                             m_mcx_movto.docum,
                                             m_mcx_movto.val_docum,
                                             l_historico, m_mcx_movto.sequencia_caixa)
          WHENEVER ERROR STOP

          IF SQLCA.sqlcode <> 0 THEN
             CALL log003_err_sql("INSERT","MCX_PENDENCIA")
             LET g_erro = TRUE
          END IF
       END IF
    END IF
 END IF

END FUNCTION

#------------------------------------------#
 FUNCTION geo1021_verifica_pend(l_modulo)
#------------------------------------------#
 DEFINE l_modulo   CHAR(03)

 WHENEVER ERROR CONTINUE
  SELECT * FROM mcx_pendencia
   WHERE empresa         = m_mcx_movto.empresa
     AND caixa           = m_mcx_movto.caixa
     AND dat_movto       = m_mcx_movto.dat_movto
     AND modulo_origem   = l_modulo
     AND docum           = m_mcx_movto.docum
     AND sequencia_caixa = m_mcx_movto.sequencia_caixa
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode = 100 THEN
    RETURN TRUE
 END IF

 RETURN FALSE

END FUNCTION

#---------------------------------#
 FUNCTION geo1021_gera_baixa_cap()
#---------------------------------#
 DEFINE l_gera_baixa_docum  LIKE mcx_oper_caixa_cap.gera_baixa_docum,
        l_num_docum         LIKE mcx_movto.docum,
        l_docum             LIKE mcx_movto.docum

 WHENEVER ERROR CONTINUE
  SELECT gera_baixa_docum
    INTO l_gera_baixa_docum
    FROM mcx_oper_caixa_cap
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF m_mcx_movto.docum IS NULL THEN
    LET l_num_docum = "X"
 ELSE
    LET l_num_docum = m_mcx_movto.docum
 END IF

 IF l_gera_baixa_docum MATCHES "[GA]" THEN
    CALL mcx0803_gera_cap(m_mcx_movto.caixa, m_mcx_movto.dat_movto,
                          m_mcx_movto.operacao,
                          m_mcx_movto.sequencia_caixa,
                          l_num_docum)
    RETURNING l_docum

    LET m_mcx_movto.docum = l_docum

 ELSE
    CALL mcx0807_baixa_cap(m_mcx_movto.caixa, m_mcx_movto.dat_movto, l_num_docum,
                           m_mcx_movto.sequencia_caixa)
    RETURNING l_docum, m_baixa_ap, m_cod_empresa, m_num_ap

    LET m_mcx_movto.docum = l_docum
 END IF

 LET m_mcx_movto.docum = l_docum

 IF g_val_docum IS NOT NULL THEN
    LET m_mcx_movto.val_docum = g_val_docum
 END IF

END FUNCTION

#----------------------------#
 FUNCTION geo1021_gera_sup()
#----------------------------#
 DEFINE l_num_docum       LIKE mcx_movto.docum,
        l_docum           LIKE mcx_movto.docum

 IF m_mcx_movto.docum IS NULL THEN
    LET l_num_docum = "X"
 ELSE
    LET l_num_docum = m_mcx_movto.docum
 END IF

 CALL mcx0804_gera_sup(m_mcx_movto.caixa, m_mcx_movto.dat_movto,
                       m_mcx_movto.operacao,
                       m_mcx_movto.sequencia_caixa,
                       l_num_docum)
     RETURNING l_docum

 LET m_mcx_movto.docum = l_docum

 IF g_val_docum IS NOT NULL THEN
    LET m_mcx_movto.val_docum = g_val_docum
 END IF

END FUNCTION

#----------------------------#
 FUNCTION geo1021_gera_trb()
#----------------------------#
 DEFINE l_num_docum       LIKE mcx_movto.docum,
        l_docum           LIKE mcx_movto.docum

 IF m_mcx_movto.docum IS NULL THEN
    LET l_num_docum = "X"
 ELSE
    LET l_num_docum = m_mcx_movto.docum
 END IF

 CALL geo1028_gera_trb(m_mcx_movto.caixa, m_mcx_movto.dat_movto,
                       m_mcx_movto.operacao,
                       m_mcx_movto.sequencia_caixa,
                       l_num_docum) RETURNING l_docum

 LET m_mcx_movto.docum = l_docum

 IF g_val_docum IS NOT NULL THEN
    LET m_mcx_movto.val_docum = g_val_docum
 END IF

END FUNCTION

#---------------------------------#
 FUNCTION geo1021_gera_baixa_cre(l_cod_titulo, l_cod_cliente, l_tip_docum)
#---------------------------------#
 DEFINE l_gera_baixa_docum  LIKE mcx_oper_caixa_cre.gera_baixa_docum,
        l_num_docum         LIKE mcx_movto.docum,
        l_docum             LIKE mcx_movto.docum,
        l_cod_titulo        CHAR(14),
        l_cod_cliente       CHAR(15),
        l_tip_docum         LIKE docum.ies_tip_docum

 WHENEVER ERROR CONTINUE
  SELECT gera_baixa_docum
    INTO l_gera_baixa_docum
    FROM mcx_oper_caixa_cre
   WHERE empresa  = m_mcx_movto.empresa
     AND operacao = m_mcx_movto.operacao
 WHENEVER ERROR STOP

 IF m_mcx_movto.docum IS NULL THEN
    LET l_num_docum = "X"
 ELSE
    LET l_num_docum = m_mcx_movto.docum
 END IF

 IF l_gera_baixa_docum MATCHES "[GA]" THEN
    CALL mcx0806_gera_cre(m_mcx_movto.caixa, m_mcx_movto.dat_movto,
                          m_mcx_movto.sequencia_caixa, m_mcx_movto.operacao,
                          m_mcx_movto.tip_operacao, l_num_docum)
         RETURNING l_docum
 ELSE
    CALL geo1022_baixa_cre(m_mcx_movto.caixa, m_mcx_movto.dat_movto,
                           m_mcx_movto.sequencia_caixa, l_num_docum,l_cod_titulo, l_cod_cliente, l_tip_docum)
         RETURNING m_empresa, l_docum, m_tip_docum, m_cod_cliente
 END IF

 LET m_mcx_movto.docum = l_docum

 IF g_val_docum IS NOT NULL THEN
    LET m_mcx_movto.val_docum = g_val_docum
 END IF

END FUNCTION

#-----------------------------------------------------------------------------------------#
 FUNCTION geo1021_elimina_relacionamento(l_empresa_destino, l_num_nf, l_ser_nf, l_ssr_nf,
                                         l_fornecedor, l_num_ap, l_num_docum, l_tip_docum,
                                         l_num_lote, l_especie_nf, l_sequencia)
#-----------------------------------------------------------------------------------------#
 DEFINE l_empresa_destino LIKE mcx_movto_gera_cap.empresa_destino,
        l_num_nf          LIKE mcx_movto_gera_cap.nota_fiscal,
        l_ser_nf          LIKE mcx_movto_gera_cap.serie_nota_fiscal,
        l_ssr_nf          LIKE mcx_movto_gera_cap.subserie_nf,
        l_fornecedor      LIKE mcx_movto_gera_cap.fornecedor,
        l_num_ap          LIKE mcx_mov_baixa_cap.autoriz_pagto,
        l_num_docum       LIKE mcx_mov_baixa_cre.docum,
        l_tip_docum       LIKE mcx_mov_baixa_cre.tip_docum,
        l_especie_nf      LIKE mcx_movto_sup.espc_nota_fiscal,
        l_num_lote        LIKE mcx_movto_trb.lote,
        l_sequencia       LIKE mcx_movto_trb.sequencia_docum

 CASE g_modulo
    WHEN "CAP"
       WHENEVER ERROR CONTINUE
       SELECT * FROM mcx_movto_gera_cap
         WHERE empresa           = m_mcx_movto.empresa
           AND caixa             = m_mcx_movto.caixa
           AND dat_movto         = m_mcx_movto.dat_movto
           AND sequencia_caixa   = m_mcx_movto.sequencia_caixa
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 THEN
          WHENEVER ERROR CONTINUE
           DELETE FROM mcx_movto_gera_cap
            WHERE empresa         = m_mcx_movto.empresa
              AND caixa           = m_mcx_movto.caixa
              AND dat_movto       = m_mcx_movto.dat_movto
              AND sequencia_caixa = m_mcx_movto.sequencia_caixa
          WHENEVER ERROR STOP
       ELSE
          WHENEVER ERROR CONTINUE
           DELETE FROM mcx_movto_gera_cap
            WHERE empresa    = m_mcx_movto.empresa
              AND caixa      = m_mcx_movto.caixa
              AND dat_movto  = m_mcx_movto.dat_movto
              AND empresa_destino   = l_empresa_destino
              AND nota_fiscal       = l_num_nf
              AND serie_nota_fiscal = l_ser_nf
              AND subserie_nf       = l_ssr_nf
              AND fornecedor        = l_fornecedor
          WHENEVER ERROR STOP
       END IF

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_GERA_CAP")
          RETURN FALSE
       END IF

    WHEN "CAP1"
       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_mov_baixa_cap
         WHERE empresa   = m_mcx_movto.empresa
           AND caixa     = m_mcx_movto.caixa
           AND dat_movto = m_mcx_movto.dat_movto
           AND sequencia_caixa = m_mcx_movto.sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND autoriz_pagto   = l_num_ap
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOV_BAIXA_CAP")
          RETURN FALSE
       END IF

    WHEN "SUP"

       WHENEVER ERROR CONTINUE
       SELECT * FROM mcx_movto_sup
        WHERE empresa         = m_mcx_movto.empresa
          AND caixa           = m_mcx_movto.caixa
          AND dat_movto       = m_mcx_movto.dat_movto
          AND sequencia_caixa = m_mcx_movto.sequencia_caixa
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode = 0 THEN
          WHENEVER ERROR CONTINUE
           DELETE FROM mcx_movto_sup
            WHERE empresa         = m_mcx_movto.empresa
              AND caixa           = m_mcx_movto.caixa
              AND dat_movto       = m_mcx_movto.dat_movto
              AND sequencia_caixa = m_mcx_movto.sequencia_caixa
          WHENEVER ERROR STOP
       ELSE
          WHENEVER ERROR CONTINUE
           DELETE FROM mcx_movto_sup
            WHERE empresa    = m_mcx_movto.empresa
              AND caixa      = m_mcx_movto.caixa
              AND dat_movto  = m_mcx_movto.dat_movto
              AND empresa_destino   = l_empresa_destino
              AND nota_fiscal       = l_num_nf
              AND serie_nota_fiscal = l_ser_nf
              AND subserie_nf       = l_ssr_nf
              AND espc_nota_fiscal  = l_especie_nf
              AND fornecedor        = l_fornecedor
          WHENEVER ERROR STOP
       END IF

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_SUP")
          RETURN FALSE
       END IF

    WHEN "CRE"
       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_gera_cre
         WHERE empresa   = m_mcx_movto.empresa
           AND caixa     = m_mcx_movto.caixa
           AND dat_movto = m_mcx_movto.dat_movto
           AND sequencia_caixa = m_mcx_movto.sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND lote_cre        = l_num_lote
           AND docum           = l_num_docum
           AND tip_docum       = l_tip_docum
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_GERA_CRE")
          RETURN FALSE
       END IF

    WHEN "CRE1"
       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_mov_baixa_cre
         WHERE empresa   = m_mcx_movto.empresa
           AND caixa     = m_mcx_movto.caixa
           AND dat_movto = m_mcx_movto.dat_movto
           AND sequencia_caixa = m_mcx_movto.sequencia_caixa
           AND empresa_destino = l_empresa_destino
           AND docum           = l_num_docum
           AND tip_docum       = l_tip_docum
           AND sequencia_docum = l_sequencia
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOV_BAIXA_CRE")
          RETURN FALSE
       END IF

    WHEN "TRB"
       WHENEVER ERROR CONTINUE
        DELETE FROM mcx_movto_trb
         WHERE empresa   = m_mcx_movto.empresa
           AND caixa     = m_mcx_movto.caixa
           AND dat_movto = m_mcx_movto.dat_movto
           AND empresa_destino = l_empresa_destino
           AND lote            = l_num_lote
           AND sequencia_caixa = m_mcx_movto.sequencia_caixa
           AND sequencia_docum = l_sequencia
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          CALL log003_err_sql("DELETE","MCX_MOVTO_TRB")
          RETURN FALSE
       END IF

 END CASE

 IF NOT geo1021_elimina_pendencia(m_mcx_movto.empresa, m_mcx_movto.caixa,
                                  m_mcx_movto.dat_movto, m_mcx_movto.docum,
                                  m_mcx_movto.sequencia_caixa) THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------------------------------#
 FUNCTION geo1021_elimina_pendencia(l_empresa, l_caixa, l_dat_movto, l_num_docum, l_seq_dig)
#---------------------------------------------------------------------------------------------#
 DEFINE l_modulo        CHAR(03),
        l_empresa       LIKE mcx_movto.empresa,
        l_caixa         LIKE mcx_movto.caixa,
        l_dat_movto     LIKE mcx_movto.dat_movto,
        l_num_docum     LIKE mcx_movto.docum,
        l_seq_dig       LIKE mcx_movto.sequencia_caixa

 CASE g_modulo
    WHEN "CAP"  LET l_modulo = "CAP"
    WHEN "CAP1" LET l_modulo = "CAP"
    WHEN "SUP"  LET l_modulo = "SUP"
    WHEN "CRE"  LET l_modulo = "CRE"
    WHEN "CRE1" LET l_modulo = "CRE"
    WHEN "TRB"  LET l_modulo = "TRB"
    WHEN "TRA"  LET l_modulo = "TRA"
 END CASE

 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_pendencia
   WHERE empresa       = l_empresa
     AND caixa         = l_caixa
     AND dat_movto     = l_dat_movto
     AND modulo_origem = l_modulo
     AND docum           = l_num_docum
     AND sequencia_caixa = l_seq_dig
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","MCX_PENDENCIA")
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION geo1021_version_info()
#--------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/financeiro/controle_movimento_caixa/funcoes/geo1021.4gl $|$Revision: 1 $|$Date: 08/01/13 10:06 $|$Modtime: $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION

