###PARSER-Não remover esta linha(Framework Logix)###
#------------------------------------------------------------#
# SISTEMA.: GEO                                              #
# PROGRAMA: geo1019 (COPIA ADAPTADA/AUTOMATIZADA DE mcx0801) #
# OBJETIVO: MANUTENCAO EM LANCAMENTOS CONTABEIS              #
# AUTOR...: EVANDRO SIMENES                                  #
# DATA....: 15/03/2016                                       #
#------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
         p_user         LIKE usuario.nom_usuario,
         p_status       SMALLINT,
         p_comando      CHAR(80),
         p_caminho      CHAR(80),
         p_nom_tela     CHAR(80),
         m_nom_help     CHAR(200),
         g_ies_grafico  SMALLINT

END GLOBALS

# MODULARES
  DEFINE mr_tela        RECORD
                           deb_cred_cx     CHAR(01),
                           conta_caixa     LIKE mcx_caixa.conta_caixa
                        END RECORD

  DEFINE ma_tela        ARRAY[200] OF RECORD
                           deb_cre         LIKE mcx_movto_trb.debito_credito,
                           num_conta_cont  LIKE mcx_lancto_contab.conta_contab,
                           centro_custo    CHAR(04),
                           val_lancto      LIKE mcx_lancto_contab.val_lancto,
                           num_lote_lanc   CHAR(03),
                           dat_lanc        DATE,
                           hist_lancto     LIKE mcx_lancto_contab.hist_lancto,
                           num_seq_lancto  SMALLINT
                        END RECORD

  DEFINE ma_telar       ARRAY[200] OF RECORD
                           deb_cre         LIKE mcx_movto_trb.debito_credito,
                           num_conta_cont  LIKE mcx_lancto_contab.conta_contab,
                           centro_custo    CHAR(04),
                           val_lancto      LIKE mcx_lancto_contab.val_lancto,
                           num_lote_lanc   CHAR(03),
                           dat_lanc        DATE,
                           hist_lancto     LIKE mcx_lancto_contab.hist_lancto,
                           num_seq_lancto  SMALLINT
                        END RECORD

  DEFINE m_arr_curr         SMALLINT,
         m_scr_lin          SMALLINT,
         m_tot_reg          SMALLINT,
         m_excluiu          SMALLINT,
         m_versao_funcao    CHAR(100),
         m_plano_contas     RECORD LIKE plano_contas.*,
         m_cad_cc           RECORD LIKE cad_cc.*,
         m_conta            LIKE mcx_operacao_caixa.conta_contab,
         m_tip_contab_conta LIKE mcx_operacao_caixa.tip_contab_conta,
         m_tip_contab_cc    LIKE mcx_operacao_caixa.tip_contab_cc,
         m_caixa            LIKE mcx_movto.caixa,
         m_dat_movto        LIKE mcx_movto.dat_movto,
         m_operacao         LIKE mcx_movto.operacao,
         m_tip_operacao     LIKE mcx_movto.tip_operacao,
         m_num_docum        LIKE mcx_movto.docum,
         m_val_docum        LIKE mcx_movto.val_docum,
         m_historico        LIKE mcx_movto.hist_movto,
         m_sequencia        LIKE mcx_movto.sequencia_caixa,
         m_centro_custo     LIKE cad_cc.cod_cent_cust

# END MODULARES

#-------------------------------------------------------------------------------#
 FUNCTION geo1019_lanc_cont(l_caixa, l_dat_movto, l_operacao, l_tip_operacao,
                            l_num_docum, l_val_docum, l_historico, l_sequencia, l_centro_custo)
#-------------------------------------------------------------------------------#
 DEFINE l_max_lote         DECIMAL(3,0),
        l_qtd_registros    SMALLINT,
        l_caixa            LIKE mcx_movto.caixa,
        l_dat_movto        LIKE mcx_movto.dat_movto,
        l_operacao         LIKE mcx_movto.operacao,
        l_tip_operacao     LIKE mcx_movto.tip_operacao,
        l_num_docum        LIKE mcx_movto.docum,
        l_val_docum        LIKE mcx_movto.val_docum,
        l_historico        LIKE mcx_movto.hist_movto,
        l_sequencia        LIKE mcx_movto.sequencia_caixa,
        l_lote             LIKE mcx_lancto_contab.lote_lancto,
        l_centro_custo     LIKE cad_cc.cod_cent_cust

# OPTIONS
#   HELP     FILE m_nom_help,
#   PREVIOUS KEY  control-b,
#   NEXT     KEY  control-f

 LET m_versao_funcao = "geo1019-05.10.01p"

 INITIALIZE p_nom_tela TO NULL

 CALL log130_procura_caminho("geo1019") RETURNING p_nom_tela
 #OPEN WINDOW w_geo1019 AT 2,2 WITH FORM p_nom_tela
 #   ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

 #DISPLAY p_cod_empresa TO empresa
 INITIALIZE mr_tela.*, ma_tela TO NULL

 LET m_caixa        = l_caixa
 LET m_dat_movto    = l_dat_movto
 LET m_operacao     = l_operacao
 LET m_tip_operacao = l_tip_operacao
 LET m_num_docum    = l_num_docum
 LET m_val_docum    = l_val_docum
 LET m_historico    = l_historico
 LET m_sequencia    = l_sequencia
 LET m_centro_custo = l_centro_custo

 #CURRENT WINDOW IS w_geo1019

 LET l_max_lote      = 0
 LET l_qtd_registros = 0

 WHENEVER ERROR CONTINUE
  SELECT COUNT(*), MAX(lote_lancto)
    INTO l_qtd_registros, l_max_lote
    FROM mcx_lancto_contab
   WHERE empresa       = p_cod_empresa
     AND caixa         = m_caixa
     AND dat_movto     = m_dat_movto
     AND sequencia_caixa = m_sequencia
     AND eh_conta_caixa = "N"
 WHENEVER ERROR STOP

 IF l_qtd_registros > 0 THEN
    IF l_max_lote = 0 THEN
       CALL geo1019_consulta(1)
       IF NOT geo1019_modificacao("MODIFICACAO") THEN
          CLOSE WINDOW w_geo1019
          RETURN FALSE
       END IF
    ELSE
       CALL geo1019_consulta(2)
    END IF
 ELSE
    IF NOT geo1019_modificacao("INCLUSAO") THEN
       CLOSE WINDOW w_geo1019
       RETURN FALSE
    END IF
 END IF

 CLOSE WINDOW w_geo1019
 RETURN TRUE

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1019_entrada_dados(l_funcao)
#---------------------------------------#
 DEFINE l_valor            LIKE mcx_movto.val_docum,
        l_num_seq_lancto   LIKE mcx_lancto_contab.sequencia_lancto,
        l_ies_tip_conta    LIKE plano_contas.ies_tip_conta,
        l_conta_ant        LIKE mcx_lancto_contab.conta_contab,
        l_abre_aen         LIKE par_con.ies_contab_aen,
        l_linha_produto    LIKE mcx_aen_4.linha_produto,
        l_linha_receita    LIKE mcx_aen_4.linha_receita,
        l_segmto_mercado   LIKE mcx_aen_4.segmto_mercado,
        l_classe_uso       LIKE mcx_aen_4.classe_uso,
        l_status, l_erro   SMALLINT,
        l_cont, l_entrou   SMALLINT,
        l_ind              SMALLINT,
        l_cc_ant           CHAR(04),
        l_funcao           CHAR(20),
        l_msg              CHAR(100)

 #CALL log006_exibe_teclas("01 02 03 17 18", m_versao_funcao)

 LET INT_FLAG = FALSE
 LET m_excluiu = FALSE

 WHENEVER ERROR CONTINUE
  SELECT ies_contab_aen
    INTO l_abre_aen
    FROM par_con
   WHERE cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP

 CALL mcx0304_busca_parametros(p_cod_empresa, m_tip_operacao)
      RETURNING l_linha_produto, l_linha_receita, l_segmto_mercado, l_classe_uso

 #CURRENT WINDOW IS w_geo1019
 CALL geo1019_busca_dados()
 CALL geo1019_busca_sequencia() RETURNING l_num_seq_lancto
 CALL geo1019_busca_ind()
 
 LET m_arr_curr = 1
 
 #BEFORE FIELD deb_cre
 IF ma_tela[m_arr_curr].deb_cre IS NULL THEN
    IF m_arr_curr = 1 THEN
       LET ma_tela[m_arr_curr].val_lancto  = m_val_docum
    END IF
    IF NOT m_excluiu THEN
       LET ma_tela[m_arr_curr].dat_lanc      = m_dat_movto
       LET ma_tela[m_arr_curr].hist_lancto   = m_historico
       LET ma_tela[m_arr_curr].num_lote_lanc = 0
    END IF

    IF mr_tela.deb_cred_cx = "D" THEN
       LET ma_tela[m_arr_curr].deb_cre = "C"
    ELSE
       LET ma_tela[m_arr_curr].deb_cre = "D"
    END IF
    #DISPLAY ma_tela[m_arr_curr].* TO s_lanc[m_scr_lin].*
 END IF
 LET l_erro = FALSE

 #BEFORE FIELD num_conta_cont
 IF ma_tela[m_arr_curr].num_conta_cont IS NULL THEN
    IF NOT l_erro THEN
       IF m_arr_curr = 1 THEN
          CALL geo1019_busca_conta_operacao()
       ELSE
          LET ma_tela[m_arr_curr].num_conta_cont = ma_tela[m_arr_curr - 1].num_conta_cont
 #         DISPLAY ma_tela[m_arr_curr].num_conta_cont TO s_lanc[m_scr_lin].num_conta_cont
       END IF
    END IF
 END IF
 IF m_tip_contab_conta = "A" THEN
    # Contabilizacao automatica
    IF m_plano_contas.ies_tip_conta = 8 THEN
       CALL geo1019_substitui_cc_conta(1)
#       NEXT FIELD centro_custo
    END IF
#       NEXT FIELD val_lancto
 END IF
 
 #AFTER FIELD num_conta_cont
 IF ma_tela[m_arr_curr].num_conta_cont IS NOT NULL THEN
    CALL con088_verifica_cod_conta(p_cod_empresa,
                                   ma_tela[m_arr_curr].num_conta_cont,
                                   "S",TODAY)
         RETURNING m_plano_contas.*, l_status
    IF l_status THEN
       IF m_tip_contab_cc = "M" THEN
          # Contabilizacao manual
#          NEXT FIELD centro_custo
       ELSE
          # Contabilizacao automatica
          IF m_plano_contas.ies_tip_conta = 8 THEN
             CALL geo1019_substitui_cc_conta(1)
          END IF
#          NEXT FIELD val_lancto
       END IF
    ELSE
       ERROR "Conta Contábil não cadastrada."
#       NEXT FIELD num_conta_cont
    END IF
    LET l_conta_ant = ma_tela[m_arr_curr].num_conta_cont
 END IF

 #BEFORE FIELD centro_custo
 IF m_plano_contas.ies_tip_conta = 8 THEN
    IF l_conta_ant <> ma_tela[m_arr_curr].num_conta_cont THEN
       LET ma_tela[m_arr_curr].centro_custo = NULL
#       DISPLAY ma_tela[m_arr_curr].centro_custo TO s_lanc[m_scr_lin].centro_custo
    END IF

    IF ma_tela[m_arr_curr].centro_custo IS NOT NULL THEN
       LET l_cc_ant = ma_tela[m_arr_curr].centro_custo
    ELSE
       LET l_cc_ant = "0"
    END IF
 ELSE
 #   NEXT FIELD val_lancto
 END IF


 LET ma_tela[m_arr_curr].centro_custo = m_centro_custo


 #AFTER FIELD centro_custo
 IF ma_tela[m_arr_curr].centro_custo IS NOT NULL THEN
    CALL con200_verifica_cod_ccusto(p_cod_empresa,
                                    ma_tela[m_arr_curr].centro_custo," ")
         RETURNING m_cad_cc.*, l_status

    IF NOT l_status THEN
       ERROR "Centro de Custo não cadastrado."
 #      NEXT FIELD centro_custo
    END IF
    CALL geo1019_substitui_cc_conta(2)

    CALL con088_verifica_cod_conta(p_cod_empresa,
                                   ma_tela[m_arr_curr].num_conta_cont,
                                   "S",TODAY)
         RETURNING m_plano_contas.*, l_status

    IF NOT l_status THEN
       ERROR "Conta Contábil não cadastrada."
       LET l_erro = TRUE
       IF m_tip_contab_cc = "A" THEN
          IF m_tip_contab_conta = "M" THEN
 #            NEXT FIELD num_conta_cont
          END IF
       ELSE
          IF m_tip_contab_conta = "M" THEN
  #           NEXT FIELD num_conta_cont
          ELSE
   #          NEXT FIELD centro_custo
          END IF
       END IF
    END IF
 END IF

 #AFTER FIELD val_lancto
 IF ma_tela[m_arr_curr].val_lancto IS NULL THEN
    ERROR "Valor do Lançamento deve ser informado."
 #   NEXT FIELD val_lancto
 END IF
 IF ma_tela[m_arr_curr].num_conta_cont IS NOT NULL THEN
    CALL con088_verifica_cod_conta(p_cod_empresa,
                                   ma_tela[m_arr_curr].num_conta_cont,
                                   "S",TODAY)
         RETURNING m_plano_contas.*, l_status

    IF NOT l_status THEN
       ERROR "Conta Contábil não cadastrada."
#       NEXT FIELD num_conta_cont
    END IF
 END IF

 #AFTER FIELD hist_lancto
 IF ma_tela[m_arr_curr].num_seq_lancto IS NULL THEN
    LET ma_tela[m_arr_curr].num_seq_lancto = 0
    IF l_num_seq_lancto IS NULL OR l_num_seq_lancto = 0 THEN
       LET ma_tela[m_arr_curr].num_seq_lancto = m_arr_curr
    ELSE
       LET ma_tela[m_arr_curr].num_seq_lancto = ma_tela[m_arr_curr-1].num_seq_lancto + 1
    END IF
#    DISPLAY ma_tela[m_arr_curr].num_seq_lancto TO s_lanc[m_scr_lin].num_seq_lancto
 END IF
 
 #AFTER INPUT
 IF NOT INT_FLAG THEN
    FOR l_cont = 1 TO 200
        IF ma_tela[l_cont].deb_cre IS NOT NULL THEN
           IF ma_tela[l_cont].num_conta_cont IS NULL THEN
              IF ma_tela[l_cont].val_lancto IS NOT NULL THEN
                 ERROR "Conta Contábil deve ser informada."
 #                NEXT FIELD num_conta_cont
              END IF
           ELSE
              CALL con088_verifica_cod_conta(p_cod_empresa,
                                             ma_tela[l_cont].num_conta_cont,
                                             "S",TODAY)
                   RETURNING m_plano_contas.*, l_status
              IF NOT l_status THEN
                 ERROR "Conta Contábil não cadastrada."
#                 NEXT FIELD num_conta_cont
              END IF
           END IF

           IF ma_tela[l_cont].centro_custo IS NOT NULL THEN
              CALL con200_verifica_cod_ccusto(p_cod_empresa,
                                              ma_tela[l_cont].centro_custo," ")
                 RETURNING m_cad_cc.*, l_status
              IF NOT l_status THEN
                 ERROR "Centro de Custo não cadastrado."
#                 NEXT FIELD centro_custo
              END IF
           END IF

           IF ma_tela[l_cont].val_lancto IS NULL THEN
              ERROR "Valor do Lançamento Contábil deve ser informado."
#              NEXT FIELD val_lancto
           END IF
           LET l_valor = 0
           FOR l_ind = 1 TO 200
               IF ma_tela[l_ind].val_lancto IS NOT NULL THEN
                  LET l_valor = l_valor + ma_tela[l_ind].val_lancto
               END IF
               LET l_entrou = TRUE
           END FOR
           IF l_entrou THEN
              IF m_val_docum <> l_valor THEN
                 ERROR "Valor informado do Lanç. Contábil está diferente do valor original: ",m_val_docum
#                 NEXT FIELD val_lancto
              END IF
           END IF

           IF ma_tela[l_cont].dat_lanc IS NULL THEN
              ERROR "Data do Lançamento Contábil deve ser informada."
 #             NEXT FIELD dat_lanc
           END IF
        END IF
    END FOR
 #   IF NOT log004_confirm(10,20) THEN
 #      NEXT FIELD num_conta_cont
 #   END IF
 END IF
 #END INPUT

 IF INT_FLAG THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#--------------------------------#
 FUNCTION geo1019_delete_array()
#--------------------------------#
 DEFINE l_cont   SMALLINT

 IF m_tot_reg > 0 AND m_tot_reg >= m_arr_curr THEN
    INITIALIZE ma_tela[m_arr_curr].* TO NULL
    FOR l_cont = m_arr_curr TO m_tot_reg
        IF ma_tela[l_cont+1].num_conta_cont IS NOT NULL THEN
           LET ma_tela[l_cont].* = ma_tela[l_cont+1].*
           LET ma_tela[l_cont].num_seq_lancto = ma_tela[l_cont].num_seq_lancto - 1
           DISPLAY ma_tela[l_cont].* TO s_lanc[l_cont].*
        END IF
    END FOR
    INITIALIZE ma_tela[m_tot_reg].* TO NULL
    #DISPLAY ma_tela[m_tot_reg].* TO s_lanc[m_tot_reg].*
    LET m_tot_reg = m_tot_reg - 1
 END IF

 END FUNCTION

#------------------------#
 FUNCTION geo1019_help()
#------------------------#
 CASE
    WHEN infield(num_conta_cont)  CALL showhelp(107)
    WHEN infield(centro_custo)    CALL showhelp(108)
    WHEN infield(val_lancto)      CALL showhelp(109)
    WHEN infield(dat_lanc)        CALL showhelp(110)
    WHEN infield(hist_lancto)     CALL showhelp(111)
 END CASE
END FUNCTION

#----------------------------------#
 FUNCTION geo1019_busca_sequencia()
#----------------------------------#
 DEFINE l_seq     LIKE mcx_lancto_contab.sequencia_lancto

 LET l_seq = 0

 WHENEVER ERROR CONTINUE
  SELECT MAX(sequencia_lancto)
    INTO l_seq
    FROM mcx_lancto_contab
   WHERE empresa       = p_cod_empresa
     AND caixa         = m_caixa
     AND dat_movto     = m_dat_movto
     AND sequencia_caixa = m_sequencia
 WHENEVER ERROR STOP

 RETURN l_seq

 END FUNCTION

#------------------------------#
 FUNCTION geo1019_busca_dados()
#------------------------------#
 DEFINE l_conta   LIKE mcx_caixa.conta_caixa

 CASE m_tip_operacao
   WHEN "E" LET mr_tela.deb_cred_cx = "D"
   WHEN "S" LET mr_tela.deb_cred_cx = "C"
 END CASE

 WHENEVER ERROR CONTINUE
  SELECT conta_caixa
    INTO mr_tela.conta_caixa
    FROM mcx_caixa
   WHERE empresa = p_cod_empresa
     AND caixa   = m_caixa
 WHENEVER ERROR STOP

 #DISPLAY BY NAME mr_tela.deb_cred_cx, mr_tela.conta_caixa

 END FUNCTION

#---------------------------------------#
 FUNCTION geo1019_verifica_existe_lote()
#---------------------------------------#
 DEFINE l_lote     DECIMAL(3,0)

 LET l_lote = 0

 WHENEVER ERROR CONTINUE
  SELECT lote_lancto
    INTO l_lote
    FROM mcx_lancto_contab
   WHERE empresa          = p_cod_empresa
     AND caixa            = m_caixa
     AND dat_movto        = m_dat_movto
     AND sequencia_caixa  = m_sequencia
     AND sequencia_lancto = ma_tela[m_arr_curr].num_seq_lancto
 WHENEVER ERROR STOP

 IF l_lote IS NOT NULL OR l_lote <> 0 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#----------------------------#
 FUNCTION geo1019_busca_ind()
#----------------------------#
 WHENEVER ERROR CONTINUE
  SELECT tip_contab_conta, tip_contab_cc
    INTO m_tip_contab_conta, m_tip_contab_cc
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = m_operacao
 WHENEVER ERROR STOP

 END FUNCTION

#----------------------------------------#
 FUNCTION geo1019_busca_conta_operacao()
#----------------------------------------#
 DEFINE l_status   SMALLINT

 WHENEVER ERROR CONTINUE
  SELECT conta_contab
    INTO ma_tela[m_arr_curr].num_conta_cont
    FROM mcx_operacao_caixa
   WHERE empresa  = p_cod_empresa
     AND operacao = m_operacao
 WHENEVER ERROR STOP

 CALL con088_verifica_cod_conta(p_cod_empresa,
                                ma_tela[m_arr_curr].num_conta_cont,
                                "S",TODAY)
      RETURNING m_plano_contas.*, l_status

 DISPLAY ma_tela[m_arr_curr].num_conta_cont TO s_lanc[m_scr_lin].num_conta_cont

 END FUNCTION

#--------------------------------------------#
 FUNCTION geo1019_substitui_cc_conta(l_ind)
#--------------------------------------------#
 DEFINE l_ies_mao_obra  LIKE par_con.ies_mao_obra,
        l_plano_contas  RECORD LIKE plano_contas.*,
        l_status        SMALLINT,
        l_ind           SMALLINT,
        l_tip_conta     CHAR(01)

 CALL con088_verifica_cod_conta(p_cod_empresa,
                                ma_tela[m_arr_curr].num_conta_cont,
                                "S",TODAY)
      RETURNING l_plano_contas.*, l_status

 IF l_plano_contas.num_conta = ma_tela[m_arr_curr].num_conta_cont THEN
    LET l_tip_conta = "N" #Normal
 ELSE
    LET l_tip_conta = "R" #Reduzida
 END IF

 WHENEVER ERROR CONTINUE
  SELECT ies_mao_obra
    INTO l_ies_mao_obra
    FROM par_con
   WHERE cod_empresa = l_plano_contas.cod_empresa
 WHENEVER ERROR STOP

 IF l_ies_mao_obra = "S" THEN
    IF l_tip_conta = "N" THEN
       IF l_ind = 1 THEN
          LET ma_tela[m_arr_curr].centro_custo = ma_tela[m_arr_curr].num_conta_cont[6,9]
       ELSE
          LET ma_tela[m_arr_curr].num_conta_cont[6,9] = ma_tela[m_arr_curr].centro_custo USING "&&&&"
       END IF
    ELSE
       IF l_ind = 1 THEN
          LET ma_tela[m_arr_curr].centro_custo = ma_tela[m_arr_curr].num_conta_cont[3,6]
       ELSE
          LET ma_tela[m_arr_curr].num_conta_cont[3,6] = ma_tela[m_arr_curr].centro_custo USING "&&&&"
       END IF
    END IF
 ELSE
    IF l_tip_conta = "N" THEN
       IF l_ind = 1 THEN
          LET ma_tela[m_arr_curr].centro_custo = ma_tela[m_arr_curr].num_conta_cont[3,6]
       ELSE
          LET ma_tela[m_arr_curr].num_conta_cont[3,6] = ma_tela[m_arr_curr].centro_custo USING "&&&&"
       END IF
    ELSE
       IF l_ind = 1 THEN
          LET ma_tela[m_arr_curr].centro_custo = ma_tela[m_arr_curr].num_conta_cont[1,4]
       ELSE
          LET ma_tela[m_arr_curr].num_conta_cont[1,4] = ma_tela[m_arr_curr].centro_custo USING "&&&&"
       END IF
    END IF
 END IF

# DISPLAY ma_tela[m_arr_curr].* TO s_lanc[m_scr_lin].*

 END FUNCTION

#---------------------------#
 FUNCTION geo1019_inclusao()
#---------------------------#
 DEFINE l_cont, l_ind      SMALLINT,
        l_where_clause     CHAR(250),
        l_conta            LIKE plano_contas.num_conta_reduz

 WHENEVER ERROR CONTINUE
  INSERT INTO mcx_lancto_contab VALUES (p_cod_empresa,
                                        m_caixa, m_dat_movto, m_sequencia, 1,
                                        m_tip_contab_cc,
                                        mr_tela.deb_cred_cx,
                                        mr_tela.conta_caixa, m_val_docum, NULL, "0","S")
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("INSERT 1","mcx_lancto_contab")
    RETURN FALSE
 END IF
 FOR l_cont = 1 TO 200
     IF ma_tela[l_cont].val_lancto IS NOT NULL THEN
        LET l_ind = l_cont + 1
        WHENEVER ERROR CONTINUE
         INSERT INTO mcx_lancto_contab VALUES (p_cod_empresa,
                                               m_caixa, ma_tela[l_cont].dat_lanc,
                                               m_sequencia, l_ind,
                                               m_tip_contab_cc,
                                               ma_tela[l_cont].deb_cre,
                                               ma_tela[l_cont].num_conta_cont,
                                               ma_tela[l_cont].val_lancto,
                                               ma_tela[l_cont].hist_lancto,
                                               ma_tela[l_cont].num_lote_lanc, "N")
        WHENEVER ERROR STOP

        IF SQLCA.sqlcode <> 0 THEN
           CALL log003_err_sql("INSERT 2","mcx_lancto_contab")
           RETURN FALSE
        END IF

        {
        LET l_where_clause = " mcx_lancto_contab.empresa = """,p_cod_empresa, """ ",
                             " AND mcx_lancto_contab.caixa = ",m_caixa,
                             " AND mcx_lancto_contab.dat_movto = """,m_dat_movto,""" ",
                             " AND mcx_lancto_contab.sequencia_caixa = ",m_sequencia,
                             " AND mcx_lancto_contab.sequencia_lancto = ",l_ind

        IF NOT mcx0812_geracao_auditoria('mcx_lancto_contab',l_where_clause,'I','geo1019') THEN
           CALL log003_err_sql('INSERT 2','mcx_auditoria')
           RETURN FALSE
        END IF}
     END IF
 END FOR

 RETURN TRUE

 END FUNCTION

#------------------------------------#
 FUNCTION geo1019_consulta(l_cont1)
#------------------------------------#
 DEFINE l_cont,l_ind      SMALLINT,
        l_tot_array       SMALLINT,
        l_enter, l_cont1  SMALLINT,
        l_conta           LIKE plano_contas.num_conta,
        l_ies_mao_obra    LIKE par_con.ies_mao_obra,
        l_plano_contas    RECORD LIKE plano_contas.*,
        l_status          SMALLINT,
        l_tip_conta       CHAR(01)

 WHENEVER ERROR CONTINUE
 SELECT tip_lancto, conta_contab
   INTO mr_tela.deb_cred_cx, mr_tela.conta_caixa
   FROM mcx_lancto_contab
  WHERE empresa          = p_cod_empresa
    AND caixa            = m_caixa
    AND dat_movto        = m_dat_movto
    AND sequencia_caixa  = m_sequencia
    AND sequencia_lancto = 1
    AND eh_conta_caixa = 'S'
 WHENEVER ERROR STOP

 #DISPLAY BY NAME mr_tela.*

 LET l_cont = 1

 DECLARE cl_lancto CURSOR FOR
  SELECT sequencia_lancto, tip_lancto, conta_contab, val_lancto,
         dat_movto, hist_lancto, lote_lancto
    FROM mcx_lancto_contab
   WHERE empresa       = p_cod_empresa
     AND caixa         = m_caixa
     AND dat_movto     = m_dat_movto
     AND sequencia_caixa = m_sequencia
     AND eh_conta_caixa = "N"
   ORDER BY sequencia_lancto

 FOREACH cl_lancto INTO ma_tela[l_cont].num_seq_lancto, ma_tela[l_cont].deb_cre,
                        ma_tela[l_cont].num_conta_cont, ma_tela[l_cont].val_lancto,
                        ma_tela[l_cont].dat_lanc, ma_tela[l_cont].hist_lancto,
                        ma_tela[l_cont].num_lote_lanc

	   CALL con088_verifica_cod_conta(p_cod_empresa,
   	                               ma_tela[l_cont].num_conta_cont,
          	                        "S",TODAY)
	        RETURNING l_plano_contas.*, l_status

	   IF l_plano_contas.ies_tip_conta = 8 THEN

	      WHENEVER ERROR CONTINUE
	       SELECT ies_mao_obra
         	INTO l_ies_mao_obra
	         FROM par_con
	        WHERE cod_empresa = l_plano_contas.cod_empresa
	      WHENEVER ERROR STOP

	      IF l_ies_mao_obra = "S" THEN
	         LET ma_tela[l_cont].centro_custo = l_plano_contas.num_conta_reduz[3,6]
	      ELSE
	         LET ma_tela[l_cont].centro_custo = l_plano_contas.num_conta_reduz[1,4]
       END IF
    END IF

    LET l_cont = l_cont + 1

 END FOREACH

 LET l_tot_array = l_cont - 1
 CALL SET_COUNT(l_cont - 1)
 LET m_tot_reg = l_tot_array

 IF l_cont1 = 2 THEN
    IF l_tot_array > 4 THEN
       #DISPLAY ARRAY ma_tela TO s_lanc.*
       #END DISPLAY
    ELSE
       #FOR l_ind = 1 TO 4
       #   DISPLAY ma_tela[l_ind].* TO s_lanc[l_ind].*
       #END FOR
    END IF
    #PROMPT "Tecle ENTER para Continuar." FOR l_enter
 ELSE
    #DISPLAY ma_tela[l_tot_array].* TO s_lanc[l_tot_array].*
 END IF

 END FUNCTION

#-------------------------#
 FUNCTION geo1019_delete()
#-------------------------#
 DEFINE l_where_clause     CHAR(250)

 WHENEVER ERROR CONTINUE
  DELETE FROM mcx_lancto_contab
   WHERE empresa       = p_cod_empresa
     AND caixa         = m_caixa
     AND dat_movto     = m_dat_movto
     AND sequencia_caixa = m_sequencia
 WHENEVER ERROR STOP

 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql("DELETE","mcx_lancto_contab")
    RETURN FALSE
 END IF

 { LET l_where_clause = " mcx_lancto_contab.empresa = """,p_cod_empresa, """ ",
                      " AND mcx_lancto_contab.caixa   = ",m_caixa,
                      " AND mcx_lancto_contab.dat_movto = """,m_dat_movto,""" ",
                      " AND mcx_lancto_contab.sequencia_caixa = ",m_sequencia

 IF NOT mcx0812_geracao_auditoria('mcx_lancto_contab',l_where_clause,'E','geo1019') THEN
    CALL log003_err_sql('INSERT','mcx_auditoria')
    RETURN FALSE
 END IF}

 RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION geo1019_modificacao(l_funcao)
#-------------------------------------#
 DEFINE l_funcao     CHAR(20)

 IF geo1019_entrada_dados(l_funcao) THEN
    IF geo1019_delete() THEN
       IF geo1019_inclusao() THEN
          RETURN TRUE
       END IF
    END IF
 END IF

 RETURN FALSE

 END FUNCTION

#-------------------------#
 FUNCTION geo1019_popup()
#-------------------------#
 CASE
  WHEN INFIELD(num_conta_cont)
    LET ma_tela[m_arr_curr].num_conta_cont = con010_popup_selecao_plano_contas(p_cod_empresa)
    CURRENT WINDOW IS w_geo1019

    IF ma_tela[m_arr_curr].num_conta_cont IS NOT NULL THEN
       DISPLAY ma_tela[m_arr_curr].num_conta_cont TO s_lanc[m_scr_lin].num_conta_cont
    END IF

  WHEN INFIELD(centro_custo)
    LET ma_tela[m_arr_curr].centro_custo = con075_popup_cod_cad_cc(p_cod_empresa)
    CURRENT WINDOW IS w_geo1019

    IF ma_tela[m_arr_curr].centro_custo IS NOT NULL THEN
       DISPLAY ma_tela[m_arr_curr].centro_custo TO s_lanc[m_scr_lin].centro_custo
    END IF
 END CASE

 END FUNCTION

#-------------------------------#
 FUNCTION geo1019_version_info()
#-------------------------------#
  RETURN "$Archive: /Logix/Fontes_Doc/Sustentacao/10R2-11R0/10R2-11R0/financeiro/controle_movimento_caixa/funcoes/geo1019.4gl $|$Revision: 8 $|$Date: 15/09/11 18:13 $|$Modtime: 18/03/11 11:05 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)
 END FUNCTION

