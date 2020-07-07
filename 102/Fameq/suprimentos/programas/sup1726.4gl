#-----------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                           #
# PROGRAMA: SUP1726                                               #
# OBJETIVO: MOVIMENTACAO DE ESTOQUE POR CÓDIGO DE BARRAS          #
# AUTOR...: ANA PAULA CASAS DE ALMEIDA                            #
# DATA....: 23/02/2011                                            #
#-----------------------------------------------------------------#
DATABASE logix

 GLOBALS

  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_status               SMALLINT,
         g_ies_ambiente         CHAR(001),
         p_nom_arquivo          CHAR(100),
         p_ies_impressao        CHAR(001),
         g_ies_grafico          SMALLINT

  DEFINE p_versao               CHAR(18)

 END GLOBALS

 DEFINE mr_tela                 RECORD
                                   codigo_barras      CHAR(65),
                                   cod_item           LIKE item.cod_item,
                                   den_item_reduz     LIKE item.den_item_reduz,
                                   cod_unid_med       LIKE item.cod_unid_med,
                                   num_lote           LIKE estoque_lote.num_lote,
                                   qtd_movto          LIKE estoque_lote.qtd_saldo,
                                   cod_operacao       LIKE estoque_operac.cod_operacao,
                                   den_operacao       LIKE estoque_operac.den_operacao
                                END RECORD

 DEFINE mr_tela2                RECORD
                                   ult_cod_item        LIKE item.cod_item,
                                   num_transac         LIKE estoque_lote.num_transac,
                                   ult_den_item_reduz  LIKE item.den_item_reduz,
                                   ult_cod_unid_med    LIKE item.cod_unid_med,
                                   ult_num_lote        LIKE estoque_lote.num_lote,
                                   ult_qtd_movto       LIKE estoque_lote.qtd_saldo,
                                   ult_cod_operacao    LIKE estoque_operac.cod_operacao,
                                   ult_den_operacao    LIKE estoque_operac.den_operacao
                                END RECORD

 DEFINE m_operacao_estoque_baixa         LIKE estoque_operac.cod_operacao,
        m_operacao_estoque_devolucao     LIKE estoque_operac.cod_operacao,
        m_ultima_operacao                LIKE estoque_operac.cod_operacao,
        m_num_conta                      LIKE estoque_trans.num_conta,
        m_cod_local                      LIKE local.cod_local,
        m_comando_sup                    CHAR(80)

MAIN

 CALL log0180_conecta_usuario()

 LET p_versao = "SUP1726-05.10.00"

 WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
 WHENEVER ERROR STOP

 DEFER INTERRUPT
 CALL log140_procura_caminho("sup1726.iem") RETURNING m_comando_sup

 OPTIONS
    HELP FILE    m_comando_sup,
    HELP KEY     control-w

 CALL log001_acessa_usuario("SUPRIMEN","LOGERP")
      RETURNING p_status, p_cod_empresa, p_user

 IF p_status = 0 THEN
    CALL sup1726_controle()
 END IF

END MAIN

#--------------------------#
 FUNCTION sup1726_controle()
#--------------------------#
 DEFINE l_informou       SMALLINT

 CALL log006_exibe_teclas("01",p_versao)

 LET l_informou = FALSE

 IF NOT sup1726_busca_parametros() THEN
    RETURN
 END IF

 CALL log130_procura_caminho("sup1726") RETURNING m_comando_sup
 OPEN WINDOW w_sup1726 AT 2,2 WITH FORM m_comando_sup
      ATTRIBUTE (BORDER,MESSAGE LINE LAST , PROMPT LINE LAST )

 CALL log0010_close_window_screen()
 DISPLAY p_cod_empresa TO empresa

 MENU "OPÇÃO"
   COMMAND "Informar"  "Informar parâmetros para movimentação de estoque por código de barras."
       HELP 001
       MESSAGE ""
       LET int_flag = 0
       IF log005_seguranca(p_user,"SUPRIMEN","sup1726","CO") THEN
          IF sup1726_informar() THEN
             LET l_informou = TRUE
          END IF
       END IF

   {COMMAND 'Processar'  'Gera a movimentação de estoque conforme parâmetros em tela.'
       HELP 002
       MESSAGE ''
       IF l_informou THEN
          IF log0040_confirm(10,20,"Confirma o processamento?") THEN
             CALL sup1726_processar() RETURNING p_status
          END IF
       ELSE
          CALL log0030_mensagem("Informe os parâmetros em tela antes de processar.","info")
       END IF}

   COMMAND "Fim" "Retorna ao menu anterior."
       HELP 005
       EXIT MENU
 END MENU

 CLOSE WINDOW w_sup1726

 END FUNCTION

#----------------------#
 FUNCTION sup1726_help()
#----------------------#
 CASE
    WHEN infield(mes_refer)           CALL showhelp(101)
    WHEN infield(ano_refer)           CALL showhelp(101)
    WHEN infield(mes_inicial)         CALL showhelp(102)
    WHEN infield(ano_inicial)         CALL showhelp(102)
    WHEN infield(mes_final)           CALL showhelp(102)
    WHEN infield(ano_final)           CALL showhelp(102)
    WHEN infield(linha_produto)       CALL showhelp(103)
    WHEN infield(linha_receita)       CALL showhelp(104)
    WHEN infield(segmto_mercado)      CALL showhelp(105)
    WHEN infield(classe_uso)          CALL showhelp(106)
    WHEN infield(usuario_respons)     CALL showhelp(107)
 END CASE

 END FUNCTION

#-------------------------------#
 FUNCTION sup1726_exibe_dados()
#-------------------------------#
 DISPLAY BY NAME mr_tela.*
 DISPLAY p_cod_empresa TO empresa

 END FUNCTION

#-------------------------------#
 FUNCTION sup1726_informar()
#-------------------------------#
 CALL log006_exibe_teclas("01 02 03", p_versao)
 CURRENT WINDOW IS w_sup1726

 INITIALIZE mr_tela.*, mr_tela2.* TO NULL
 CALL log006_exibe_teclas("01 02 07", p_versao)
 CURRENT WINDOW IS w_sup1726

 LET INT_FLAG = FALSE

 INPUT BY NAME mr_tela.* WITHOUT DEFAULTS

   BEFORE FIELD codigo_barras
      CALL sup1726_carrega_dados_informados()

   AFTER FIELD codigo_barras
      IF mr_tela.codigo_barras IS NULL THEN
         CALL log0030_mensagem("Informe o código de barras.","excl")
         NEXT FIELD codigo_barras
      ELSE
         CALL sup1726_retorna_info()
         IF NOT sup1726_verifica_item() THEN
            NEXT FIELD codigo_barras
         END IF
         DISPLAY BY NAME mr_tela.*
         NEXT FIELD cod_operacao
      END IF

   BEFORE FIELD cod_operacao
      IF m_ultima_operacao IS NOT NULL THEN
         LET mr_tela.cod_operacao = m_ultima_operacao
         DISPLAY BY NAME mr_tela.cod_operacao
      END IF

   AFTER FIELD cod_operacao
      IF mr_tela.cod_operacao IS NULL THEN
         CALL log0030_mensagem("Operação de estoque deve ser informada.","excl")
         NEXT FIELD cod_operacao
      ELSE
         IF (mr_tela.cod_operacao <> m_operacao_estoque_baixa) AND (mr_tela.cod_operacao <> m_operacao_estoque_devolucao) THEN
            CALL log0030_mensagem("Operação de estoque diferente da parametrizada no LOG2240.","excl")
            NEXT FIELD cod_operacao
         END IF
         IF NOT sup1726_verifica_operacao_estoque() THEN
            NEXT FIELD cod_operacao
         END IF
         IF NOT sup1726_verifica_quantidade_x_lote() THEN
            NEXT FIELD cod_operacao
         END IF
      END IF

   AFTER INPUT
      IF NOT int_flag THEN
         IF mr_tela.cod_operacao IS NULL THEN
            CALL log0030_mensagem("Operação de estoque deve ser informada.","excl")
            NEXT FIELD cod_operacao
         ELSE
            IF (mr_tela.cod_operacao <> m_operacao_estoque_baixa) AND (mr_tela.cod_operacao <> m_operacao_estoque_devolucao) THEN
               CALL log0030_mensagem("Operação de estoque diferente da parametrizada no LOG2240.","excl")
               NEXT FIELD cod_operacao
            END IF
            IF NOT sup1726_verifica_operacao_estoque() THEN
               NEXT FIELD cod_operacao
            END IF
			         IF NOT sup1726_verifica_quantidade_x_lote() THEN
			            NEXT FIELD cod_operacao
			         END IF
         END IF
      END IF

  ON KEY (control-w, f1)
     CALL sup1726_help()

 END INPUT

 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_sup1726

 DISPLAY "--------" AT 3,68

 IF int_flag <> 0 THEN
    LET int_flag = 0
    RETURN FALSE
 END IF

 IF log0040_confirm(10,20,"Confirma o processamento?") THEN
    CALL sup1726_processar() RETURNING p_status
 ELSE
    MESSAGE "Processamento cancelado." ATTRIBUTE(REVERSE)
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION sup1726_verifica_item()
#------------------------------------#
 LET mr_tela.den_item_reduz = NULL
 LET mr_tela.cod_unid_med   = NULL

 WHENEVER ERROR CONTINUE
  SELECT den_item_reduz, cod_unid_med, cod_local_estoq
    INTO mr_tela.den_item_reduz, mr_tela.cod_unid_med, m_cod_local
    FROM item
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = mr_tela.cod_item
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log0030_mensagem("Item não cadastrado.","excl")
    RETURN FALSE
 END IF

 {WHENEVER ERROR CONTINUE
  SELECT cod_empresa
    FROM item_ctr_grade
   WHERE cod_empresa = p_cod_empresa
     AND cod_item    = mr_tela.cod_item
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE = 0 THEN
    CALL log0030_mensagem("Item possui outros controles dimensionais.","excl")
    RETURN FALSE
 END IF}

 RETURN TRUE

 END FUNCTION

#--------------------------------------------#
 FUNCTION sup1726_verifica_operacao_estoque()
#--------------------------------------------#
 DEFINE l_ies_tipo              LIKE estoque_operac.ies_tipo,
        l_ies_custo             LIKE estoque_operac.ies_custo,
        l_ies_com_quantidade    LIKE estoque_operac.ies_com_quantidade,
        l_ies_acumulado         LIKE estoque_operac.ies_acumulado,
        l_ies_origem            LIKE estoque_operac.ies_origem,
        l_ies_destino           LIKE estoque_operac.ies_destino

 LET mr_tela.den_operacao = NULL

 WHENEVER ERROR CONTINUE
 SELECT den_operacao, ies_tipo, ies_custo, ies_com_quantidade, ies_acumulado, ies_origem, ies_destino
   INTO mr_tela.den_operacao, l_ies_tipo, l_ies_custo, l_ies_com_quantidade, l_ies_acumulado, l_ies_origem, l_ies_destino
   FROM estoque_operac
  WHERE cod_empresa  = p_cod_empresa
    AND cod_operacao = mr_tela.cod_operacao
 WHENEVER ERROR STOP

 DISPLAY BY NAME mr_tela.den_operacao

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log0030_mensagem("Operação de estoque não cadastrada.","excl")
    RETURN FALSE
 END IF

 IF l_ies_custo <> "M" THEN
    CALL log0030_mensagem("Operação de estoque não é CUSTO MÉDIO.","excl")
    RETURN FALSE
 END IF

 IF l_ies_com_quantidade = "N" THEN
    CALL log0030_mensagem("Operação de estoque não é COM QUANTIDADE.","excl")
    RETURN FALSE
 END IF

 IF l_ies_origem <> "L" THEN
    CALL log0030_mensagem("Operação de estoque não possui origem LOCAL.","excl")
    RETURN FALSE
 END IF

 IF l_ies_destino <> "U" THEN
    CALL log0030_mensagem("Operação de estoque não possui destino CENTRO DE CUSTO.","excl")
    RETURN FALSE
 END IF

 IF mr_tela.cod_operacao = m_operacao_estoque_baixa THEN
    IF l_ies_acumulado <> "1" THEN
       CALL log0030_mensagem("Operação de estoque não é SAÍDA POSITIVA.","excl")
       RETURN FALSE
    END IF
 END IF

 IF l_ies_tipo <> "S" THEN
    CALL log0030_mensagem("Operação de estoque não é SAÍDA.","excl")
    RETURN FALSE
 END IF

 IF mr_tela.cod_operacao = m_operacao_estoque_devolucao THEN
    IF l_ies_acumulado <> "2" THEN
       CALL log0030_mensagem("Operação de estoque não é SAÍDA NEGATIVA.","excl")
       RETURN FALSE
    END IF
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION sup1726_busca_parametros()
#------------------------------------#
 DEFINE l_status   SMALLINT

 INITIALIZE m_operacao_estoque_baixa TO NULL
 CALL log2250_busca_parametro(p_cod_empresa,"operacao_estoque_baixa")
   RETURNING m_operacao_estoque_baixa, l_status

 IF m_operacao_estoque_baixa IS NULL OR m_operacao_estoque_baixa = " " OR l_status = FALSE THEN
    CALL log0030_mensagem("Falta parametrizar a operação de estoque de baixa no LOG2240.","excl")
    RETURN FALSE
 END IF

 INITIALIZE m_operacao_estoque_devolucao TO NULL
 CALL log2250_busca_parametro(p_cod_empresa,"operacao_estoque_devolucao")
   RETURNING m_operacao_estoque_devolucao, l_status

 IF m_operacao_estoque_devolucao IS NULL OR m_operacao_estoque_devolucao = " " OR l_status = FALSE THEN
    CALL log0030_mensagem("Falta parametrizar a operação de estoque de devolução no LOG2240.","excl")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT par_txt
    INTO m_ultima_operacao
    FROM par_sup_pad
   WHERE cod_empresa = p_cod_empresa
     AND cod_parametro = "ultima_operacao_1080"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE = 0 THEN
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------------------------#
 FUNCTION sup1726_verifica_quantidade_x_lote()
#----------------------------------------------#
 DEFINE l_qtd_saldo         LIKE estoque_lote.qtd_saldo,
        l_num_lote          LIKE estoque_lote.num_lote,
        l_msg               CHAR(150)

 IF mr_tela.cod_operacao = m_operacao_estoque_baixa THEN
    WHENEVER ERROR CONTINUE
     SELECT qtd_saldo
       INTO l_qtd_saldo
       FROM estoque_lote
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = mr_tela.cod_item
        AND num_lote    = mr_tela.num_lote
        AND cod_local   = "ALMOX" # Deixar fixo a pedido do cliente
        AND ies_situa_qtd = "L"
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql("SELECT","ESTOQUE_LOTE")
       RETURN FALSE
    END IF

    IF l_qtd_saldo < mr_tela.qtd_movto THEN
       CALL log0030_mensagem("Saldo de estoque insuficiente para atender a quantidade solicitada.","excl")
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cl_lote CURSOR FOR
     SELECT num_lote, qtd_saldo
       FROM estoque_lote
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = mr_tela.cod_item
        AND ies_situa_qtd = "L"
        AND num_lote    < mr_tela.num_lote
        AND cod_local   = "ALMOX" # Deixar fixo a pedido do cliente
        ORDER BY num_lote ASC
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql("DECLARE","CL_LOTE")
       RETURN FALSE
    END IF

    WHENEVER ERROR CONTINUE
    FOREACH cl_lote INTO l_num_lote, l_qtd_saldo
    WHENEVER ERROR STOP

        IF SQLCA.SQLCODE <> 0 THEN
           CALL log003_err_sql("FOREACH","CL_LOTE")
           RETURN FALSE
        END IF

        IF l_num_lote <> mr_tela.num_lote THEN
           IF l_qtd_saldo > 0 THEN
              LET l_msg = "Lote informado não poderá ser baixado pois existe um lote menor: ",l_num_lote CLIPPED, " com quantidade ",l_qtd_saldo
              CALL log0030_mensagem(l_msg,"excl")
              RETURN FALSE
           END IF
        END IF

    END FOREACH
 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------------#
 FUNCTION sup1726_carrega_dados_informados()
#---------------------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT MAX(num_transac)
    INTO mr_tela2.num_transac
    FROM estoque_trans
   WHERE cod_empresa = p_cod_empresa
     AND num_prog    = "SUP1726"
 WHENEVER ERROR STOP

 IF SQLCA.SQLCODE <> 0 THEN
    CALL log003_err_sql("SELECT","ESTOQUE_TRANS")
    RETURN
 END IF

 IF mr_tela2.num_transac IS NOT NULL THEN
    WHENEVER ERROR CONTINUE
     SELECT cod_item, qtd_movto, cod_operacao, num_lote_orig
       INTO mr_tela2.ult_cod_item, mr_tela2.ult_qtd_movto, mr_tela2.ult_cod_operacao, mr_tela2.ult_num_lote
       FROM estoque_trans
      WHERE cod_empresa = p_cod_empresa
        AND num_transac = mr_tela2.num_transac
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE = 0 THEN
       WHENEVER ERROR CONTINUE
       SELECT den_operacao
         INTO mr_tela2.ult_den_operacao
         FROM estoque_operac
        WHERE cod_empresa  = p_cod_empresa
          AND cod_operacao = mr_tela2.ult_cod_operacao
       WHENEVER ERROR STOP

       IF SQLCA.SQLCODE <> 0 THEN
          LET mr_tela2.ult_den_operacao = NULL
       END IF

       WHENEVER ERROR CONTINUE
        SELECT den_item_reduz, cod_unid_med
          INTO mr_tela2.ult_den_item_reduz, mr_tela2.ult_cod_unid_med
          FROM item
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = mr_tela2.ult_cod_item
       WHENEVER ERROR STOP

       IF SQLCA.SQLCODE <> 0 THEN
          INITIALIZE mr_tela2.ult_den_item_reduz, mr_tela2.ult_cod_unid_med TO NULL
       END IF
    END IF
 END IF

 DISPLAY BY NAME mr_tela2.*

 END FUNCTION

#--------------------------------#
 FUNCTION sup1726_processar()
#--------------------------------#
 DEFINE lr_estoque_trans       RECORD LIKE estoque_trans.*
 DEFINE lr_estoque_obs         RECORD LIKE estoque_obs.*,
        lr_estoque_trans_end   RECORD LIKE estoque_trans_end.*
 DEFINE l_hora                 LIKE estoque_trans.hor_operac

 LET l_hora = TIME
 INITIALIZE lr_estoque_trans.* TO NULL
 INITIALIZE lr_estoque_obs.*   TO NULL

 IF NOT sup1726_busca_num_conta() THEN
    RETURN FALSE
 END IF

 LET lr_estoque_trans.cod_empresa        = p_cod_empresa
 LET lr_estoque_trans.num_transac        = 0
 LET lr_estoque_trans.cod_item           = mr_tela.cod_item
 LET lr_estoque_trans.dat_movto          = TODAY
 LET lr_estoque_trans.dat_ref_moeda_fort = NULL
 LET lr_estoque_trans.cod_operacao       = mr_tela.cod_operacao
 LET lr_estoque_trans.num_docum          = NULL
 LET lr_estoque_trans.num_seq            = NULL
 LET lr_estoque_trans.ies_tip_movto      = "N"
 LET lr_estoque_trans.qtd_movto          = mr_tela.qtd_movto
 LET lr_estoque_trans.cus_unit_movto_p   = 0
 LET lr_estoque_trans.cus_tot_movto_p    = 0
 LET lr_estoque_trans.cus_unit_movto_f   = 0
 LET lr_estoque_trans.cus_tot_movto_f    = 0
 LET lr_estoque_trans.num_conta          = m_num_conta
 LET lr_estoque_trans.num_secao_requis   = NULL
 LET lr_estoque_trans.cod_local_est_orig = m_cod_local
 LET lr_estoque_trans.cod_local_est_dest = NULL
 LET lr_estoque_trans.num_lote_orig      = mr_tela.num_lote
 LET lr_estoque_trans.num_lote_dest      = NULL
 LET lr_estoque_trans.ies_sit_est_orig   = "L"
 LET lr_estoque_trans.ies_sit_est_dest   = NULL
 LET lr_estoque_trans.cod_turno          = NULL
 LET lr_estoque_trans.nom_usuario        = p_user
 LET lr_estoque_trans.dat_proces         = TODAY
 LET lr_estoque_trans.hor_operac         = l_hora
 LET lr_estoque_trans.num_prog           = "SUP1726"

 INITIALIZE lr_estoque_trans_end.* TO NULL

 LET lr_estoque_trans_end.cod_empresa       = p_cod_empresa
 LET lr_estoque_trans_end.num_transac       = 0
 LET lr_estoque_trans_end.endereco          = " "
 LET lr_estoque_trans_end.num_volume        = 0
 LET lr_estoque_trans_end.qtd_movto         = lr_estoque_trans.qtd_movto
 LET lr_estoque_trans_end.cod_grade_1       = " "
 LET lr_estoque_trans_end.cod_grade_2       = " "
 LET lr_estoque_trans_end.cod_grade_3       = " "
 LET lr_estoque_trans_end.cod_grade_4       = " "
 LET lr_estoque_trans_end.cod_grade_5       = " "
 LET lr_estoque_trans_end.dat_hor_prod_ini  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.dat_hor_prod_fim  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.vlr_temperatura   = 0
 LET lr_estoque_trans_end.endereco_origem   = " "
 LET lr_estoque_trans_end.num_ped_ven       = 0
 LET lr_estoque_trans_end.num_seq_ped_ven   = 0
 LET lr_estoque_trans_end.dat_hor_producao  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.dat_hor_validade  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.num_peca          = " "
 LET lr_estoque_trans_end.num_serie         = " "
 LET lr_estoque_trans_end.comprimento       = 0
 LET lr_estoque_trans_end.largura           = 0
 LET lr_estoque_trans_end.altura            = 0
 LET lr_estoque_trans_end.diametro          = 0
 LET lr_estoque_trans_end.dat_hor_reserv_1  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.dat_hor_reserv_2  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.dat_hor_reserv_3  = EXTEND("1900-01-01 00:00:00", YEAR TO SECOND)
 LET lr_estoque_trans_end.qtd_reserv_1      = 0
 LET lr_estoque_trans_end.qtd_reserv_2      = 0
 LET lr_estoque_trans_end.qtd_reserv_3      = 0
 LET lr_estoque_trans_end.num_reserv_1      = 0
 LET lr_estoque_trans_end.num_reserv_2      = 0
 LET lr_estoque_trans_end.num_reserv_3      = 0
 LET lr_estoque_trans_end.tex_reservado     = " "
 LET lr_estoque_trans_end.cus_unit_movto_p  = 0
 LET lr_estoque_trans_end.cus_unit_movto_f  = 0
 LET lr_estoque_trans_end.cus_tot_movto_p   = 0
 LET lr_estoque_trans_end.cus_tot_movto_f   = 0

 IF NOT sup097_movto_estoque(lr_estoque_trans.*,
                             lr_estoque_obs.*,
                             lr_estoque_trans_end.*,
                             0) THEN
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  SELECT par_txt
    FROM par_sup_pad
   WHERE cod_empresa = p_cod_empresa
     AND cod_parametro = "ultima_operacao_1080"
  WHENEVER ERROR STOP

 IF SQLCA.SQLCODE = 100 THEN
    WHENEVER ERROR CONTINUE
     INSERT INTO par_sup_pad (cod_empresa, cod_parametro, den_parametro, par_ies, par_txt, par_val, par_num, par_data)
                      VALUES (p_cod_empresa, "ultima_operacao_1080", "Ultima operacao estoque do sup1726", "S", mr_tela.cod_operacao,
                              NULL, NULL, NULL)
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql("INSERT","PAR_SUP_PAD")
       RETURN FALSE
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
     UPDATE par_sup_pad
        SET par_txt = mr_tela.cod_operacao
      WHERE cod_empresa   = p_cod_empresa
        AND cod_parametro = "ultima_operacao_1080"
    WHENEVER ERROR STOP

    IF SQLCA.SQLCODE <> 0 THEN
       CALL log003_err_sql("UPDATE","PAR_SUP_PAD")
       RETURN FALSE
    END IF
 END IF

 CALL log0030_mensagem("Movimentação efetuada com sucesso.","info")

 RETURN TRUE

 END FUNCTION

#----------------------------------#
 FUNCTION sup1726_busca_num_conta()
#----------------------------------#
 WHENEVER ERROR CONTINUE
  SELECT num_conta
    INTO m_num_conta
    FROM item_sup
   WHERE cod_empresa  = p_cod_empresa
     AND cod_item     = mr_tela.cod_item
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("SELECT","ESTOQUE_OPERAC_CT")
    RETURN FALSE
 END IF

  RETURN TRUE

 END FUNCTION

#-----------------------------------#
 FUNCTION sup1726_retorna_info()
#-----------------------------------#
 DEFINE l_cont, l_ind, l_ind1         SMALLINT

 FOR l_cont = 1 TO 65
    IF mr_tela.codigo_barras[l_cont] = "." THEN
       LET mr_tela.cod_item = mr_tela.codigo_barras[1,l_cont-1]
       EXIT FOR
    END IF
 END FOR
 LET l_cont = l_cont + 1

 FOR l_ind = l_cont TO 65
    IF mr_tela.codigo_barras[l_ind] = "." THEN
       LET mr_tela.num_lote = mr_tela.codigo_barras[l_cont, l_ind-1]
       EXIT FOR
    END IF
 END FOR
 LET l_ind = l_ind + 1

 LET mr_tela.qtd_movto = mr_tela.codigo_barras[l_ind, 65]

 END FUNCTION

#-------------------------------#
 FUNCTION sup1726_version_info()
#-------------------------------#
  RETURN "$Archive: /especificos/logix10R2/fab_de_maquinas_e_equip_fameq_ltda/suprimentos/suprimentos/programas/sup1726.4gl $|$Revision: 2 $|$Date: 16/03/11 9:40 $|$Modtime: 16/03/11 9:04 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION
