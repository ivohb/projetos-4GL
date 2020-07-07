###PARSER-Não remover esta linha(Framework Logix)###
#---------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                               #
# PROGRAMA: SUP0290                                                   #
# OBJETIVO: MANUTENCAO ORDEM DE COMPRA - MATERIAL DE ESTOQUE          #
# AUTOR...: IVO - CÓPIA DO SUP0290                                    #
#           APENAS ALTEREI O FONTE ORIGINAL, PARA CHAMAR UMA ROTINA   #
#           QUE IRÁ ANALIZAR ALGUMAS REGRAS E ATUALIZAR O STATUS DA   #
#           OC COM A (ABERTA) OU X (BLOQUEADA)                        #
# DATA....: 28/10/2013                                                #
#---------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE g_pais                 CHAR(02),
         p_status_oc            CHAR(01)
  
  DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
         p_user                 LIKE usuario.nom_usuario,
         p_ies_item_estoq       LIKE item.ies_ctr_estoque,
         p_ies_situacao         LIKE item.ies_situacao,
         p_cod_unid_med         LIKE item.cod_unid_med,
         p_cod_comprador        LIKE item_sup.cod_comprador,
         p_cod_local_estoq      LIKE item.cod_local_estoq,
         p_ies_tip_item         LIKE item.ies_tip_item,
         p_tip_ajuste           CHAR(01),
         p_outro_prog           SMALLINT,
         p_conta                SMALLINT,
         p_dat_origem           DATE,
         p_data_processamento   LIKE mapa_dias_mes_454.data_processamento,
         p_qtd_solic            LIKE ordem_sup.qtd_solic, #ivo
         p_num_oc               LIKE ordem_sup.num_oc,    #ivo
         p_par_sup_compl        RECORD LIKE par_sup_compl.*,
         p_par_logix            RECORD LIKE par_logix.*,
         p_item                 RECORD LIKE item.*,
         p_arg_cod_item         LIKE item.cod_item,
         p_arg_cod_empresa      LIKE ordem_sup.cod_empresa,
         p_arg_num_oc           LIKE ordem_sup.num_oc,
         p_plano_contas         RECORD LIKE plano_contas.*,
         p_estrut_ordem_sup     RECORD LIKE estrut_ordem_sup.*,
         p_data                 DATE,
         p_nr_itens             SMALLINT,
         p_chave_processo       INTEGER,
         g_ies_considera_mult   CHAR(01),
         p_cod_emp_ant_input    LIKE empresa.cod_empresa,
         p_gru_ctr_desp         LIKE item_sup.gru_ctr_desp,
         p_total                LIKE dest_ordem_sup.pct_particip_comp,
         p_cod_cla_fisc         LIKE item.cod_cla_fisc,
         p_pct_ipi              LIKE item.pct_ipi,
         p_cod_lin_prod         LIKE item.cod_lin_prod,
         p_cod_lin_recei        LIKE item.cod_lin_recei,
         p_pct_particip         LIKE dest_ordem_sup.pct_particip_comp,
         p_num_conta            LIKE item_sup.num_conta,
         p_cod_empresa_ativ     LIKE empresa.cod_empresa,
         p_cod_empresa_sal      LIKE empresa.cod_empresa,
         p_status               SMALLINT,
         p_num_args             SMALLINT,
         p_cod_item             LIKE ordem_sup.cod_item,
         m_gru_ctr_estoq        LIKE item.gru_ctr_estoq,
         p_cancel               INTEGER,
         p_lead_time            DECIMAL(6,0),
         p_indica               SMALLINT,
         p_ies_uni_funcio       CHAR(1),
         p_ies_estoque_fisico   CHAR(1),
         g_ies_grafico          SMALLINT,
         p_ies_inf_fisc_item_oc CHAR(01),
         p_ies_oc_planejada     CHAR(01),
         g_grade                SMALLINT,
         g_ies_genero           SMALLINT,
         p_id_prog_ord          INTEGER

#ivo
DEFINE p_parametro         RECORD
       cod_empresa         LIKE ordem_sup.cod_empresa,
       num_oc              LIKE ordem_sup.num_oc,
       nom_programa        CHAR(08),
       dat_programacao     DATE,
       qtd_ajuste          DECIMAL(10,3),
       seq_periodo         INTEGER,
       chave_processo      DECIMAL(12,0),
       id_prog_ord         INTEGER
END RECORD
#-----------------------------------------------------

DEFINE p_ordem_sup         RECORD LIKE ordem_sup.*,
       p_ordem_supr        RECORD LIKE ordem_sup.*,
       p_prog_ordem_sup    RECORD LIKE prog_ordem_sup.*,
       p_ordem_sup_compl   RECORD LIKE ordem_sup_compl.*,
       p_par_con           RECORD LIKE par_con.*,
       p_area              ARRAY[670] OF RECORD
                           seq              DECIMAL(3,0),
                           num_conta        LIKE plano_contas.num_conta,
                           cod_area_negocio LIKE dest_ordem_sup.cod_area_negocio,
                           cod_lin_negocio  LIKE dest_ordem_sup.cod_lin_negocio,
                           cod_seg_merc     LIKE linha_prod.cod_seg_merc,
                           cod_cla_uso      LIKE linha_prod.cod_cla_uso,
                           pct_particip_comp LIKE dest_ordem_sup.pct_particip_comp,
                           den_conta        LIKE plano_contas.den_conta
                           END RECORD,
       gr_dados_tela_com   RECORD #Voltar para p_dados_tela
                           cod_empresa      LIKE ordem_sup.cod_empresa,
                           num_oc           LIKE ordem_sup.num_oc,
                           num_oc_origem    LIKE ordem_sup.num_oc_origem,
                           cod_item         LIKE ordem_sup.cod_item,
                           ies_situa_oc     LIKE ordem_sup.ies_situa_oc,
                           ies_origem_oc    LIKE ordem_sup.ies_origem_oc,
                           dat_emis         LIKE ordem_sup.dat_emis,
                           dat_abertura_oc  LIKE ordem_sup.dat_abertura_oc,
                           num_docum        LIKE ordem_sup.num_docum,
                           qtd_solic        LIKE ordem_sup.qtd_solic,
                           qtd_origem       LIKE ordem_sup.qtd_origem,
                           dat_entrega_prev LIKE ordem_sup.dat_entrega_prev,
                           dat_origem       LIKE ordem_sup.dat_origem,
                           gru_ctr_desp     LIKE ordem_sup.gru_ctr_desp,
                           cod_tip_despesa  LIKE ordem_sup.cod_tip_despesa,
                           cod_progr        LIKE ordem_sup.cod_progr,
                           cod_comprador    LIKE ordem_sup.cod_comprador,
                           cod_uni_funcio   LIKE uni_funcional.cod_uni_funcio
                           END RECORD
#--inicio--OS704186 Antonio#
 DEFINE ga_area_gao ARRAY[500] OF RECORD
                           seq               DECIMAL(3,0),
                           num_docum         LIKE dest_ordem_sup.num_docum,
                           cod_secao_receb   LIKE dest_ordem_sup.cod_secao_receb,
                           cod_cc_aplic      LIKE cad_cc.cod_cent_cust,
                           cod_mao_obra      LIKE mao_obra.cod_mao_obra,
                           num_conta         LIKE plano_contas.num_conta,
                           den_conta         LIKE plano_contas.den_conta,
                           cod_area_negocio  LIKE dest_ordem_sup.cod_area_negocio,
                           cod_lin_negocio   LIKE dest_ordem_sup.cod_lin_negocio,
                           cod_seg_merc      LIKE dest_ordem_sup4.cod_seg_merc,
                           cod_cla_uso       LIKE dest_ordem_sup4.cod_cla_uso,
                           qtd_particip_comp LIKE dest_ordem_sup.qtd_particip_comp,
                           pct_particip_comp LIKE dest_ordem_sup.pct_particip_comp
                    END RECORD
#---fim----OS#

DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

DEFINE     p_msg             CHAR(300)

DEFINE m_ies_excl_aberta     CHAR(01),
       m_possui_centraliz    SMALLINT,
       comando               CHAR(100),
       m_window              CHAR(008),
       m_valid_fim           SMALLINT,
       m_dat_fim_valid       LIKE par_sup_pad.par_data,
       m_controles           CHAR(300),
       m_lin_consig          SMALLINT,
       m_col_consig          SMALLINT,
       m_consulta_decres     CHAR(01),
       m_consid_pct_refugo   CHAR(01),
       m_status              SMALLINT,
       m_codigo_comprador_pr SMALLINT,
       m_controla_gao        CHAR(01),
       m_usa_cond_pagto      CHAR(01),
       m_orcamento_periodo   CHAR(01),
       m_atua_somente_desig  CHAR(01),
       m_ies_valor_desig     CHAR(01),
       m_msg                 CHAR(80)

DEFINE p_estrutura           RECORD
                               cod_item_pai     LIKE estrutura.cod_item_pai,
                               cod_item_compon  LIKE estrutura.cod_item_compon,
                               qtd_necessaria   LIKE estrutura.qtd_necessaria,
                               pct_refug        LIKE estrutura.pct_refug,
                               tmp_ressup       LIKE item_man.tmp_ressup,
                               tmp_ressup_sobr  LIKE estrutura.tmp_ressup_sobr
                             END RECORD,
       p_ies_item_prod_oc    CHAR(01),
       m_ies_ajuste_data_oc  CHAR(01)

DEFINE p_ies_sup0301       LIKE par_sup_pad.par_ies,
       p_cont              SMALLINT,
       p_sub               SMALLINT,
       p_ies_cons          SMALLINT,
       p_ies_incid_benef   LIKE par_sup_pad.par_ies,
       g_ies_conta_item    CHAR(01)

DEFINE p_ind_arr, p_ind1   SMALLINT

DEFINE p_dest_ordem_sup    RECORD
                           cod_empresa          LIKE dest_ordem_sup.cod_empresa,
                           num_oc               LIKE dest_ordem_sup.num_oc,
                           cod_area_negocio     LIKE dest_ordem_sup.cod_area_negocio,
                           cod_lin_negocio      LIKE dest_ordem_sup.cod_lin_negocio,
                           pct_particip_comp    LIKE dest_ordem_sup.pct_particip_comp,
                           num_conta_deb_desp   LIKE dest_ordem_sup.num_conta_deb_desp,
                           cod_secao_receb      LIKE dest_ordem_sup.cod_secao_receb,
                           qtd_particip_comp    LIKE dest_ordem_sup.qtd_particip_comp,
                           num_docum            LIKE dest_ordem_sup.num_docum
                           END RECORD,
       p_item_sup          RECORD LIKE item_sup.*,
       p_linha_prod        RECORD LIKE linha_prod.*,
       p_tex_situa_oc      CHAR(11),
       p_formonly          RECORD
                           den_item_reduz    LIKE item.den_item_reduz,
                           cod_unid_med      LIKE item.cod_unid_med,
                           den_item          LIKE item.den_item,
                           tex_situa_oc      CHAR(011),
                           tex_origem_oc     CHAR(011),
                           den_gru_ctr_desp  LIKE grupo_ctr_desp.den_gru_ctr_desp,
                           nom_tip_despesa   LIKE tipo_despesa.nom_tip_despesa,
                           nom_progr         LIKE programador.nom_progr,
                           nom_comprador     LIKE comprador.nom_comprador,
                           den_local         CHAR(20)
                           END RECORD
DEFINE mr_usuario          RECORD
                           cod_progr     LIKE programador.cod_progr,
                           cod_comprador LIKE comprador.cod_comprador
                           END RECORD

DEFINE p_item_sup_compl                RECORD LIKE item_sup_compl.*,
       m_ies_aen_4_niveis              CHAR(01),
       m_ies_dat_retro                 LIKE par_sup_pad.par_ies,
       m_req_benef_cc_td               CHAR(01),
       m_verif_comp                    CHAR(01),
       m_informa_val_previsto          CHAR(01),
       m_data_lead_time                CHAR(01),
       m_ies_bloqueia_oc_igual_zero    CHAR(01), #730768#
       m_oc_frotas                     SMALLINT,
       m_busca_aen_unidade_funcional   CHAR(01),
       m_exibir_oc_designada_aprov_tec CHAR(01), # 779618
       m_unid_func_todas_empresas      CHAR(01)

DEFINE mr_tela                      RECORD
                                    pre_unit_oc  LIKE ordem_sup.pre_unit_oc
                                    END RECORD

DEFINE m_abre_aut_tela_comp         CHAR(01),
       l_houve_erro                 SMALLINT,
       p_count                      INTEGER
             
  DEFINE ma_secao_recebimento ARRAY[670] OF LIKE sup_part_item_aen.secao_recebimento, #OS528621
         m_des_rateio         LIKE sup_part_item_aen.des_rateio

MAIN

  CALL log0180_conecta_usuario()

  #CALL fgl_setenv("VERSION_INFO","L10-SUP0290-10.02.$Revision: 22 $p") #Informacao da versao do programa controlado pelo SourceSafe - Nao remover esta linha.
  LET p_versao = "POL1233-10.03.02" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  SET LOCK MODE TO WAIT 120
  WHENEVER ERROR STOP

  DEFER INTERRUPT
    CALL log140_procura_caminho("sup0290.iem") RETURNING comando
  OPTIONS
    HELP FILE comando,
    NEXT KEY control-f,
    DELETE KEY control-e,
    PREVIOUS KEY control-b

  CALL log001_acessa_usuario("SUPRIMEN","LOGERP;LOGLQ2")
       RETURNING p_status, p_cod_empresa, p_user
              
  IF p_status = 0  THEN
     LET p_cod_empresa_ativ = p_cod_empresa

     INITIALIZE p_arg_cod_item, p_arg_cod_empresa, p_arg_num_oc TO NULL

     LET p_num_args = num_args()
     IF p_num_args > 0 THEN
        LET p_cod_item = arg_val(1)
     ELSE
        LET p_cod_item = NULL
     END IF

     CALL sup029_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION sup029_controle()
#--------------------------#
  DEFINE l_cod_local       LIKE local.cod_local,
         l_num_lote        CHAR(15),
         l_ies_situa       CHAR(01),
         l_retorno         SMALLINT,
         lr_est_lote_ender RECORD LIKE estoque_lote_ender.*,
         l_ies_item_integr CHAR(01)


  CALL log006_exibe_teclas("01",p_versao)

  INITIALIZE gr_dados_tela_com.* TO NULL

  CALL sup0063_cria_temp_controle()

  INITIALIZE p_ies_item_estoq, p_data, p_ies_situacao, p_cod_unid_med  ,p_cod_comprador  TO NULL
  INITIALIZE p_gru_ctr_desp  ,p_cod_cla_fisc  TO NULL
  INITIALIZE p_num_conta   ,p_ies_cons  TO NULL
  INITIALIZE p_ordem_sup.*,p_prog_ordem_sup.*,p_dest_ordem_sup.* TO NULL
  INITIALIZE p_formonly.* TO NULL
  INITIALIZE p_ordem_supr.* TO NULL

  CALL sup0290_leitura_parametros()

  IF g_pais = "AR" THEN
     LET m_window = "sup0290b"
  ELSE
     LET m_window = "sup02901"
  END IF

  CALL log130_procura_caminho(m_window) RETURNING comando
  OPEN WINDOW w_sup02901 AT 2,2  WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  LET p_conta = NULL
  WHENEVER ERROR CONTINUE
  SELECT COUNT(*) INTO p_conta FROM centraliz_emp_sup WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  LET m_possui_centraliz = (p_conta > 0)

  IF p_num_args <> 0 THEN
     IF arg_val(4) <> " " AND arg_val(4) IS NOT NULL THEN
        IF arg_val(4) = "CONSULTA" THEN
           LET p_arg_cod_item    = arg_val(1)
           LET p_arg_cod_empresa = arg_val(2)
           LET p_arg_num_oc      = arg_val(3)
           LET p_cod_empresa_sal = p_cod_empresa
           LET p_cod_empresa     = p_cod_empresa_ativ
           IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","CO")  THEN
              LET p_cod_empresa = p_cod_empresa_sal
              CALL sup029_consulta_ordem_sup()
           ELSE
              LET p_cod_empresa = p_cod_empresa_sal
           END IF
        ELSE
           LET p_cod_empresa_sal = p_cod_empresa
           LET p_cod_empresa     = p_cod_empresa_ativ
           IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","IN")  THEN
              LET p_cod_empresa = p_cod_empresa_sal
              CALL sup029_inclusao_ordem_sup()
           ELSE
              LET p_cod_empresa = p_cod_empresa_sal
           END IF
        END IF
     ELSE
        LET p_cod_empresa_sal = p_cod_empresa
        LET p_cod_empresa     = p_cod_empresa_ativ
        IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","IN")  THEN
           LET p_cod_empresa = p_cod_empresa_sal
           CALL sup029_inclusao_ordem_sup()
        ELSE
           LET p_cod_empresa = p_cod_empresa_sal
        END IF
     END IF
  END IF

  IF m_informa_val_previsto = "N" THEN
     DISPLAY "                              " AT 11,49
  END IF

  MENU "OPCAO"
  BEFORE MENU
     IF m_informa_val_previsto = "S" THEN
        SHOW OPTION "aProvacao_oc"
     ELSE
        HIDE OPTION "aProvacao_oc"
     END IF

     #OS 523974
     IF find4GLFunction('supy71_cliente_907') THEN
        IF supy71_cliente_907() = FALSE THEN
           HIDE OPTION "J_texto_local"
        END IF
     ELSE
        HIDE OPTION "J_texto_local"
     END IF

     IF NOT LOG_existe_epl('sup0290y_before_menu') THEN
        #EPL Executado antes da menu
        HIDE OPTION 'N_Outros'
     END IF

  COMMAND "Incluir" "Inclui um nova ordem de compra na tabela ORDEM_SUP"
    HELP 001
    MESSAGE ""
    LET p_cod_empresa_sal   = p_cod_empresa
    LET p_cod_empresa = p_cod_empresa_ativ
    DISPLAY '                                                                             ' AT 18,01
    IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","IN")  THEN
       LET p_cod_empresa = p_cod_empresa_sal
       IF mr_usuario.cod_progr IS NULL THEN
          ERROR "USUARIO nao cadastrado como PROGRAMADOR"
          NEXT OPTION "Incluir"
       ELSE
          INITIALIZE gr_dados_tela_com.* TO NULL
          INITIALIZE p_formonly.* TO NULL
          LET gr_dados_tela_com.num_oc = NULL
          CALL sup029_inclusao_ordem_sup()
          IF l_houve_erro THEN
             CLEAR FORM
             DISPLAY p_cod_empresa TO cod_empresa
             ERROR 'Operação cancelada.'
          ELSE
             ERROR 'Operação efetuada com sucesso.'
          END IF
          INITIALIZE gr_dados_tela_com TO NULL
       END IF
    ELSE
       LET p_cod_empresa = p_cod_empresa_sal
    END IF
    
  COMMAND "Modificar" "Modifica as informacoes da ordem de compra"
    HELP 002
    MESSAGE ""
    IF gr_dados_tela_com.num_oc IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_cod_empresa_ativ
       IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","MO") THEN
          LET p_cod_empresa = p_cod_empresa_sal
          LET l_retorno = sup0290_acesso_oc("MODIFICACAO")
          IF l_retorno <> 0 THEN
             IF sup029_pesq_td_compl(p_ordem_sup.cod_empresa,p_ordem_sup.cod_tip_despesa) THEN
                IF sup029_verifica_oc_centralizada() = FALSE THEN
                   IF log305_permissao_item(gr_dados_tela_com.cod_item,"SUP0290") THEN
                      CALL sup029_modificacao_ordem_sup(l_retorno)
                   ELSE
                      ERROR "Usuario nao tem permissao para acessar o item"
                      NEXT OPTION "Modificar"
                   END IF
                ELSE
                   ERROR " Ordem de Compra Centralizada. Modificacao nao permitida. Alterar pelo SUP0767. "
                END IF
             ELSE
                ERROR "Nao e' permitida modificacao. Tipo de despesa BLOQUEADO"
             END IF
          END IF
       ELSE
          LET p_cod_empresa = p_cod_empresa_sal
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF
    LET m_codigo_comprador_pr = gr_dados_tela_com.cod_comprador

  COMMAND "Excluir" "Exclui uma ordem de compra existente na tabela ORDEM_SUP"
    HELP 003
    MESSAGE ""
    IF gr_dados_tela_com.num_oc IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_cod_empresa_ativ
       IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","EX")  THEN
          LET p_cod_empresa = p_cod_empresa_sal
          LET l_retorno = sup0290_acesso_oc("EXCLUSAO")
          IF sup029_verifica_oc_centralizada() = FALSE THEN
             IF l_retorno = 1 THEN
                IF log305_permissao_item(gr_dados_tela_com.cod_item,"SUP0290") THEN
                   CALL sup029_exclusao_ordem_sup()
                ELSE
                   ERROR "Usuario nao tem permissao para acessar o item"
                   NEXT OPTION "Incluir"
                END IF
             END IF
          ELSE
             ERROR " Ordem de Compra Centralizada. Exclusao nao permitida. Excluir pelo SUP0767. "
          END IF
       ELSE
          LET p_cod_empresa = p_cod_empresa_sal
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND "Consultar"    "Consulta a tabela ORDEM_SUP"
    HELP 004
    MESSAGE ""
    LET p_cod_empresa_sal = p_cod_empresa
    LET p_cod_empresa = p_cod_empresa_ativ
    IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","CO")  THEN
       LET p_cod_empresa = p_cod_empresa_sal
       CALL sup029_consulta_ordem_sup()
       IF p_ies_cons THEN
          NEXT OPTION "Seguinte"
       END IF
    ELSE
       LET p_cod_empresa = p_cod_empresa_sal
    END IF
    LET m_codigo_comprador_pr = gr_dados_tela_com.cod_comprador
  COMMAND "Seguinte"   "Exibe a proxima ordem encontrada na consulta"
    HELP 005
    MESSAGE ""
    CALL sup029_paginacao("SEGUINTE")
    LET m_codigo_comprador_pr = gr_dados_tela_com.cod_comprador
  COMMAND "Anterior"   "Exibe a ordem anterior encontrada na consulta"
    HELP 006
    MESSAGE ""
    CALL sup029_paginacao("ANTERIOR")
    LET m_codigo_comprador_pr = gr_dados_tela_com.cod_comprador

  COMMAND KEY ("G") "Grade/Dimensional" "Consulta da grade/dimensional da OC."
    HELP 025
    MESSAGE ""
    IF gr_dados_tela_com.num_oc IS NOT NULL THEN
       CALL sup1016_grade(p_cod_empresa,gr_dados_tela_com.num_oc)
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND "Q_prog.entrega" "Modifica os programas de entrega "
    HELP 009
    MESSAGE ""

    CALL log120_procura_caminho("pol1236") RETURNING comando
    IF p_ordem_sup.num_oc IS NOT NULL THEN
       LET comando = comando CLIPPED," ",p_ordem_sup.cod_empresa," ",
                                         p_ordem_sup.num_oc," ",
                                         p_ordem_sup.num_versao
    END IF
    RUN comando RETURNING p_cancel

    IF p_ordem_sup.num_oc IS NOT NULL THEN
       SELECT * INTO p_ordem_sup.*  FROM ordem_sup
        WHERE cod_empresa      = p_ordem_sup.cod_empresa
          AND num_oc           = p_ordem_sup.num_oc
          AND ies_versao_atual = "S"
       CALL sup029_exibe_dados()

    END IF
    
  COMMAND KEY ("1") "1_info_adicion" "Manutencao de informacoes adicionais da ordem."
    HELP 010
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup543_info_compl(p_ordem_sup.cod_empresa,p_ordem_sup.num_oc)
       SELECT num_docum, gru_ctr_desp, cod_tip_despesa
         INTO gr_dados_tela_com.num_docum, gr_dados_tela_com.gru_ctr_desp,
              gr_dados_tela_com.cod_tip_despesa
         FROM ordem_sup
        WHERE cod_empresa      = p_ordem_sup.cod_empresa
          AND num_oc           = p_ordem_sup.num_oc
          AND ies_versao_atual = "S"
       LET p_cod_empresa = p_cod_empresa_sal
       CALL log006_exibe_teclas("01",p_versao)
       CURRENT WINDOW IS w_sup02901
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND "R_oRcamento"  "Modifica status da ordem de compra."
    HELP 024
    MESSAGE ""
    IF gr_dados_tela_com.num_oc IS NOT NULL THEN
       IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","MO") THEN
          IF sup029_orcamento_ordem_sup(TRUE) THEN
             ERROR "Funcao executada com sucesso "
          ELSE
             ERROR "Funcao cancelada "
          END IF
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND "Ordem_cotacao"   " Exibe as cotacoes de preco para esta O.C."
    HELP 979
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET l_ies_item_integr = 'N'
       IF sup0290_verifica_item_integracao(p_ordem_sup.cod_item) THEN
           CALL log0030_mensagem('Este processo deve ser feito através do portal de compras.','exclamation')
           SLEEP 3
           LET l_ies_item_integr = 'S'
       END IF
       IF l_ies_item_integr = 'N' THEN
          LET p_cod_empresa_sal = p_cod_empresa
          LET p_cod_empresa     = p_ordem_sup.cod_empresa
          CALL sup0342_ordem_cotacao(p_ordem_sup.*)
          CALL log006_exibe_teclas("01",p_versao)
          CURRENT WINDOW IS w_sup02901
          LET p_cod_empresa = p_cod_empresa_sal
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("H") "Historico"   " Exibe historico das ordens."
    HELP 011
    MESSAGE ""
    IF find4GLFunction('supy62_valida_comprador_subst') THEN
       IF supy62_valida_comprador_subst(p_ordem_sup.num_oc, TRUE) THEN #717837#
          IF p_ordem_sup.cod_item IS NOT NULL THEN
             LET p_cod_empresa_sal = p_cod_empresa
             LET p_cod_empresa = p_ordem_sup.cod_empresa
             CALL sup137_mostra_historico_ordens(p_ordem_sup.cod_item)
             LET p_cod_empresa = p_cod_empresa_sal
          ELSE
             ERROR "Nao existe nenhuma consulta ativa"
          END IF
       END IF
    ELSE
       IF p_ordem_sup.cod_item IS NOT NULL THEN
          LET p_cod_empresa_sal = p_cod_empresa
          LET p_cod_empresa = p_ordem_sup.cod_empresa
          CALL sup137_mostra_historico_ordens(p_ordem_sup.cod_item)
          LET p_cod_empresa = p_cod_empresa_sal
       ELSE
          ERROR "Nao existe nenhuma consulta ativa"
       END IF
    END IF

  COMMAND KEY ("6") "6_fornecedor"   " Exibe e designa fornecedores deste material."
    HELP 012
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET l_ies_item_integr = 'N'
       IF sup0290_verifica_item_integracao(p_ordem_sup.cod_item) THEN
           CALL log0030_mensagem('Este processo deve ser feito através do portal de compras.','exclamation')
           SLEEP 3
           LET l_ies_item_integr = 'S'
       END IF
       IF l_ies_item_integr = 'N' THEN
          LET p_cod_empresa_sal = p_cod_empresa
          LET p_cod_empresa = p_ordem_sup.cod_empresa
          CALL sup135_mostra_fornecedores(p_ordem_sup.cod_item, gr_dados_tela_com.num_oc)
          LET p_cod_empresa = p_cod_empresa_sal
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("2") "2_material"   " Exibe as pendencias do material."
    HELP 013
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup136_mostra_pendencias_material(p_ordem_sup.cod_item)
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("3") "3_estoque"   " Exibe informacoes de estoque."
    HELP 014
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup131_mostra_info_estoque(p_ordem_sup.cod_item)
            RETURNING l_cod_local,
                      l_num_lote,
                      l_ies_situa,
                      lr_est_lote_ender.*
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("4") "4_consumo"   " Consulta estoque / consumo "
    HELP 015
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL log120_procura_caminho("sup1320") RETURNING comando
       LET comando = comando CLIPPED, " ",  p_cod_empresa, " ",
                                         p_ordem_sup.cod_item
       RUN comando RETURNING p_cancel
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("7") "7_zoom_conta_aen" "Exibe relacionamento Conta x Area x Linha"
    HELP 016
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup029_zoom_aen()
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("T") "Texto"   "Exibe a tela de TEXTO DA ORDEM DE COMPRA"
    HELP 017
    MESSAGE ""
    CALL log120_procura_caminho("sup0410") RETURNING comando
    IF p_ordem_sup.num_oc IS NOT NULL THEN
       LET comando = comando CLIPPED, " ", p_ordem_sup.cod_empresa," ",p_ordem_sup.num_oc
    END IF
    RUN comando RETURNING p_cancel

  COMMAND KEY ("8") "8_zoom_mat"   "Exibe as ordens do material"
    HELP 015
    MESSAGE ""
    IF p_ordem_sup.cod_item IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup678_zoom_por_material(p_ordem_sup.cod_item,"S")
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("9") "9_zoom_cpr"   "Exibe as ordens deste comprador"
    HELP 019
    MESSAGE ""
    IF p_ordem_sup.cod_comprador IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup677_zoom_por_comprador(p_ordem_sup.cod_comprador, "S")
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("0") "0_zoom_pgr"   "Exibe as ordens deste programador"
    HELP 020
    MESSAGE ""
    IF p_ordem_sup.cod_progr IS NOT NULL THEN
       LET p_cod_empresa_sal = p_cod_empresa
       LET p_cod_empresa = p_ordem_sup.cod_empresa
       CALL sup676_zoom_por_programador(p_ordem_sup.cod_progr)
       LET p_cod_empresa = p_cod_empresa_sal
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("5") "5_componentes"   "Exibe os componentes para beneficiamento desta ordem"
    HELP 021
    MESSAGE ""
    IF p_ordem_sup.num_oc IS NOT NULL THEN
       CALL sup411_zoom_componentes_beneficia(p_ordem_sup.cod_empresa, p_ordem_sup.num_oc)
       CURRENT WINDOW IS w_sup02901
       IF sup029_verifica_componentes() THEN
          IF NOT g_ies_genero THEN
             DISPLAY " BENEFICIAMENTO " AT 04,55 ATTRIBUTE(REVERSE)
          ELSE
             CALL log4050_altera_atributo("benef","text","BENEFICIAMENTO")
          END IF
          CALL sup0290_atualiza_oc_benef()
       ELSE
          IF NOT g_ies_genero THEN
             DISPLAY "                " AT 04,55
          ELSE
             CALL log4050_altera_atributo("benef","text","")
          END IF
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY("Y") "Y_assinaturas" "Mostra as assinaturas relacionadas a esta O.C."
    HELP 022
    MESSAGE ""
    IF p_ordem_sup.num_oc IS NOT NULL THEN
       IF log005_seguranca(p_user,"SUPRIMEN","SUP0290","CO") THEN
         CALL sup667_assinaturas_oc(p_ordem_sup.cod_empresa,p_ordem_sup.num_oc,p_ordem_sup.num_versao)
       END IF
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("K") "K_imprime" "Imprimir relatorio da ordem de compra."
    HELP 023
    MESSAGE ""
    IF p_ordem_sup.num_oc IS NOT NULL THEN
       CALL log120_procura_caminho("sup1380") RETURNING comando
       LET comando = comando CLIPPED," ",p_ordem_sup.cod_empresa, " ",
                                         p_ordem_sup.num_oc
       RUN comando RETURNING p_cancel
    ELSE
       ERROR "Nao existe nenhuma consulta ativa"
    END IF

  COMMAND KEY ("P") "aProvacao_oc" "Chama o programa de aprovação de Ordens."
    HELP 026
    MESSAGE ""
    CALL log120_procura_caminho("sup8273") RETURNING comando
    LET comando = comando CLIPPED," ",p_ordem_sup.cod_empresa, " ",
                                      p_ordem_sup.num_oc
    RUN comando RETURNING p_cancel

  #OS 523974
  COMMAND KEY ("J") "J_texto_local" "Texto descritivo do local da ordem de compra de estoque."
    HELP 027
    MESSAGE ""

    IF p_ordem_sup.num_oc IS NOT NULL AND
       p_ordem_sup.num_oc <> " " THEN
       IF find4GLFunction('supy71_texto_local') THEN
          IF supy71_texto_local(p_ordem_sup.num_oc) = FALSE THEN
             CALL log0030_mensagem("Alteração do texto local cancelada.","excla")
          ELSE
             MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
          END IF
       ELSE
          MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
       END IF
    ELSE
       CALL log0030_mensagem("Nao existe nenhuma consulta ativa","excla")
    END IF

  COMMAND KEY ("N") "N_Outros" "Menu específico."
       MESSAGE ""
       #PASSAGEM DE PARAMETRO PARA A FUNCAO EPL sup0300y
       CALL LOG_setVar('cod_empresa', p_ordem_sup.cod_empresa)
       #EPL Código da empresa
       #EPL TIPO: ordem_sup.cod_empresa

       CALL LOG_setVar('num_oc', p_ordem_sup.num_oc)
       #EPL Número da ordem de compra
       #EPL TIPO: ordem_sup.num_oc

       IF LOG_existe_epl('sup0290y_menu_outros') THEN
          CALL sup0290y_menu_outros() RETURNING p_cancel
       END IF

  COMMAND KEY ("!")
    PROMPT "Digite o comando: " FOR comando
    RUN comando
    PROMPT "\nTecle ENTER para continuar" FOR CHAR comando

  COMMAND "Fim" "Retorna ao Menu Anterior"
    HELP 008
    EXIT MENU

  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_sup02901
END FUNCTION

#-----------------------#
 FUNCTION pol1233_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#----------------------------------------------------#
 FUNCTION sup029_busca_par_sup_pad(p_cod_par,p_campo)
#----------------------------------------------------#
 DEFINE p_cod_par   CHAR(25),
        p_campo     SMALLINT,
        p_valor     DECIMAL(17,2),
        p_variavel  FLOAT,
        p_texto     CHAR(100),
        p_ies       CHAR(01),
        p_data      DATE

 INITIALIZE p_valor, p_variavel, p_texto, p_ies, p_data TO NULL

 SELECT par_ies, par_val, par_txt, par_num, par_data
   INTO p_ies, p_valor, p_texto, p_variavel, p_data
   FROM par_sup_pad
  WHERE par_sup_pad.cod_empresa   = p_cod_empresa
    AND par_sup_pad.cod_parametro = p_cod_par

 CASE p_campo
 WHEN 1 RETURN p_ies
 WHEN 2 RETURN p_valor
 WHEN 3 RETURN p_texto
 WHEN 4 RETURN p_variavel
 WHEN 5 RETURN p_data
 END CASE
END FUNCTION

#------------------------------------#
 FUNCTION sup029_inclusao_ordem_sup()
#------------------------------------#
  DEFINE 
         l_processa_sup4110   SMALLINT            #Vanderlei - OS 426389 #
  DEFINE l_ind                SMALLINT

  LET p_ordem_supr.* = p_ordem_sup.*

  IF NOT g_ies_genero THEN
     DISPLAY "                   " AT 05,26
     DISPLAY "               "     AT 14,50
     DISPLAY "                "    AT 04,55
     DISPLAY "                "    AT 11,30
     IF m_informa_val_previsto = "N" THEN
        DISPLAY "                              " AT 11,49
     END IF
  ELSE
     CALL log4050_altera_atributo("numped","text","")
     CALL log4050_altera_atributo("numseq","text","")
     CALL log4050_altera_atributo("benef","text","")
     CALL log4050_altera_atributo("emerg","text","")
  END IF

  INITIALIZE p_ordem_sup.* TO NULL
  INITIALIZE p_ordem_sup_compl.* TO NULL
  INITIALIZE p_area TO NULL

  CLEAR FORM
  CALL sup029_inicializa_campos()
  IF sup029_entrada_dados("INCLUSAO",1)  THEN
     LET l_houve_erro = FALSE

     IF NOT l_houve_erro THEN
        CALL sup029_move_campos("INCLUSAO")

        ### OS 180358 ###
        CALL sup0063_verifica_controles(15,
                                        p_ordem_sup.cod_item,
                                        "INCLUSAO",
                                        "SUP0290")
          RETURNING m_controles
        IF m_controles IS NOT NULL AND
           m_controles <> " " THEN
           CALL sup1016_movto_controles(m_lin_consig,              ### linha
                                        m_col_consig,              ### coluna
                                        "INCLUSAO",                ### Tipo de movimento (INCLUSAO/EXCLUSAO)
                                        p_ordem_sup.num_oc,        ### Número da Ordem de compra
                                        p_ordem_sup.cod_item,      ### codigo do item
                                        p_ordem_sup.qtd_solic,     ### quantidade do processamento
                                        p_ordem_sup.qtd_recebida,
                                        p_ordem_sup.ies_situa_oc,
                                        p_ordem_sup.dat_entrega_prev)
              RETURNING p_status
              CURRENT WINDOW IS w_sup02901
           IF p_status = TRUE THEN
              CALL sup029_exibe_dados()
              MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)

              #523974
              IF find4GLFunction('supy71_cliente_907') THEN
                 IF supy71_cliente_907() = TRUE THEN

                    IF find4GLFunction('supy71_texto_local') THEN
                       IF supy71_texto_local(p_ordem_sup.num_oc) = FALSE THEN
                          CALL log0030_mensagem("Alteração do texto local cancelada.","excla")
                       ELSE
                          MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
                       END IF
                    ELSE
                       MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
                    END IF

                 END IF
              END IF

              RETURN
           ELSE
              ERROR " Inclusao Cancelada. "
              RETURN
           END IF

           RETURN
        ELSE
           ##--inicio--OS704186 Antonio#
           INITIALIZE ga_area_gao TO NULL
           FOR l_ind = 1 TO 500
              IF p_area[l_ind].seq IS NULL AND p_area[l_ind].num_conta IS NULL
              AND p_area[l_ind].cod_area_negocio IS NULL THEN
                  CONTINUE FOR
              END IF
              LET ga_area_gao[l_ind].seq               = 1
              LET ga_area_gao[l_ind].num_conta         = p_area[l_ind].num_conta
              LET ga_area_gao[l_ind].cod_area_negocio  = p_area[l_ind].cod_area_negocio
              LET ga_area_gao[l_ind].cod_lin_negocio   = p_area[l_ind].cod_lin_negocio
              LET ga_area_gao[l_ind].cod_seg_merc      = p_area[l_ind].cod_seg_merc
              LET ga_area_gao[l_ind].cod_cla_uso       = p_area[l_ind].cod_cla_uso
              LET ga_area_gao[l_ind].pct_particip_comp = 100
              LET ga_area_gao[l_ind].qtd_particip_comp = p_dest_ordem_sup.qtd_particip_comp
              LET ga_area_gao[l_ind].den_conta         = p_area[l_ind].den_conta
              LET ga_area_gao[l_ind].cod_secao_receb   = " "
              LET ga_area_gao[l_ind].num_docum         = " "
           END FOR

           IF m_informa_val_previsto = "S" THEN
              IF (p_ordem_sup.ies_situa_oc <> 'P' AND
                  p_ordem_sup.ies_situa_oc <> 'D' AND
                  p_ordem_sup.ies_situa_oc <> 'T' AND
                  p_ordem_sup.ies_situa_oc <> 'S') THEN

                  IF m_unid_func_todas_empresas = "N" THEN
                     CALL sup0772_valida_oc_oln_gao(gr_dados_tela_com.cod_empresa,
                                                    gr_dados_tela_com.cod_item,
                                                    gr_dados_tela_com.qtd_solic,
                                                    mr_tela.pre_unit_oc,
                                                    TODAY,
                                                    gr_dados_tela_com.qtd_solic,
                                                    gr_dados_tela_com.ies_situa_oc,
                                                    gr_dados_tela_com.cod_tip_despesa,
                                                    gr_dados_tela_com.dat_entrega_prev)
                                                    RETURNING p_status
                     IF p_status = FALSE THEN
                        RETURN
                     END IF
                  END IF
              END IF
           END IF
           #---fim----OSOS704186 Antonio  #
          WHENEVER ERROR CONTINUE
           CALL log085_transacao("BEGIN")
           WHENEVER ERROR STOP
           IF NOT sup029_verifica_par_sup() THEN
              LET l_houve_erro = TRUE
           END IF

           IF m_informa_val_previsto = "S" THEN
              CALL sup0290_insere_valor_previsto(p_ordem_sup.num_oc, mr_tela.pre_unit_oc)
           END IF

           IF m_informa_val_previsto = "N" THEN
              DISPLAY "                              " AT 11,49
           END IF

           WHENEVER ERROR CONTINUE
           INSERT INTO ordem_sup VALUES(p_ordem_sup.*)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INCLUSAO","ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF
     END IF

     IF NOT l_houve_erro THEN
        WHENEVER ERROR CONTINUE
        INSERT INTO ordem_sup_compl VALUES(p_ordem_sup_compl.*)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSAO","ORDEM_SUP_COMPL")
           LET l_houve_erro = TRUE
        END IF
     END IF

     IF NOT l_houve_erro THEN
        IF NOT sup029_insere_dest_ord_sup() THEN
           LET l_houve_erro = TRUE
        END IF
     END IF

     IF NOT l_houve_erro THEN
        IF NOT sup029_insere_estrut_ordem_sup() THEN
           LET l_houve_erro = TRUE
        END IF
     END IF

     #--inicio--vanderlei OS 426389 #
     IF NOT l_houve_erro THEN
        # -- Executa Zoom para componentes de beneficiamento, caso os        -- #
        # -- compenentes não sejam informado a inclusão da OC será cancelada -- #


        IF find4GLFunction('supy14_valida_item_benef') THEN
           CASE supy14_valida_item_benef(p_ordem_sup.cod_empresa, p_ordem_sup.num_oc, p_ies_tip_item)
              WHEN 0 ERROR " Inclusão cancelada. "
                     INITIALIZE p_ordem_sup.* TO NULL
                     LET l_houve_erro       = 1 # Cancela inclusão
              WHEN 1 LET l_processa_sup4110 = 1 # EPL Padrão, deverá executar normal(sup4110_zoom_componentes_beneficia)
              WHEN 2 LET l_processa_sup4110 = 0 # EPL específica, não deverá executar sup4110_zoom_componentes_beneficia
           END CASE
        ELSE
           LET l_processa_sup4110 = 1
        END IF
     END IF
     CURRENT WINDOW IS w_sup02901
     #---fim----vanderlei OS 426389 #

     IF NOT l_houve_erro THEN
        CALL sup029_prepara_prog_entrega()
        WHENEVER ERROR CONTINUE
        #LET p_prog_ordem_sup.dat_origem = TODAY
        INSERT INTO prog_ordem_sup VALUES (p_prog_ordem_sup.*)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("INCLUSAO","PROG_ORDEM_SUP")
           LET l_houve_erro = TRUE
        END IF
     END IF
     
     IF NOT l_houve_erro THEN
        IF NOT fcl1150_integra_oc_fcx(p_ordem_sup.cod_empresa,
                                      p_ordem_sup.num_oc,"IN") THEN
           LET l_houve_erro = TRUE
        END IF
     END IF


     #---inicio----OS704186 Antonio  #
     IF NOT l_houve_erro THEN
        IF (gr_dados_tela_com.ies_situa_oc <> "P" AND
            gr_dados_tela_com.ies_situa_oc <> "D" AND
            gr_dados_tela_com.ies_situa_oc <> "T" AND
            gr_dados_tela_com.ies_situa_oc <> "S") THEN
           # A O.C. já nasceu APROVADA, deve incluir no GAO
           IF m_informa_val_previsto = "S" THEN
              IF (m_orcamento_periodo  = "S"
              OR  m_usa_cond_pagto     = "S")
              OR (m_orcamento_periodo  = "N"
              AND m_usa_cond_pagto     = "N"
              AND m_atua_somente_desig = "N") THEN

                 IF m_unid_func_todas_empresas = "N" THEN
                    CALL sup0772_atualiza_oc_oln_gao(gr_dados_tela_com.cod_empresa,
                                                     gr_dados_tela_com.num_oc,
                                                     gr_dados_tela_com.qtd_solic,
                                                     mr_tela.pre_unit_oc,
                                                     TODAY,
                                                     "OC",
                                                     "SUP0290",
                                                     0,
                                                     0,
                                                     0,
                                                     TRUE,  # Somente atualizar se a OC
                                                            # estiver APROVADA
                                                     TRUE,  # Buscar VAL_PREVISTO caso o
                                                            # preço estiver zerado
                                                     FALSE, # Considerar o Valor do IPI
                                                     FALSE, # Trata-se de Recebimento
                                                     FALSE, # Trata-se de Devolução à Fornecedor
                                                     "IN")
                         RETURNING p_status, m_msg

                    IF p_status = FALSE THEN
                       LET l_houve_erro = TRUE
                    END IF
                 END IF
              END IF
           END IF
        END IF
     END IF
     #---fim----OS704186 Antonio  #

     #--inicio--vanderlei OS 384141 #
     IF NOT l_houve_erro THEN
        IF sup0290_item_industr_ctr_cust_n_produt(p_ordem_sup.cod_item,
                                                  p_ordem_sup.num_oc,
                                                  p_ordem_sup.gru_ctr_desp,
                                                  p_ordem_sup.dat_emis) THEN
           IF NOT log0040_confirm(21, 10, "Item de industr.para centro de custo não produtivo.Confirma?") THEN
              CLEAR FORM
              CALL log0030_mensagem("Inclusão cancelada.","exclamation")
              LET l_houve_erro = 1
           END IF
        END IF
     END IF
     #---fim----vanderlei OS 384141 #

     IF NOT l_houve_erro THEN
        IF LOG_existe_epl("sup0290y_before_commit") THEN
           #EPL Executado depois de efetuar a inclusão da
           #EPL ordem de compra no processo do MRP.

           CALL LOG_setVar("empresa",p_ordem_sup.cod_empresa)
           #EPL Empresa corrente
           #EPL Tipo: empresa.cod_empresa
           CALL LOG_setVar("num_oc",p_ordem_sup.num_oc)
           #EPL Número da ordem de compra
           #EPL Tipo: ordem_sup.num_oc
           CALL LOG_setVar("cod_item",p_ordem_sup.cod_item)
           #EPL Código do item da ordem de compra
           #EPL Tipo: ordem_sup.cod_item

           IF NOT sup0290y_before_commit() THEN
              LET l_houve_erro = 1
           END IF
        END IF
     END IF


     IF NOT l_houve_erro THEN
        IF find4GLFunction('supy174_abre_tela_oc') THEN
           IF NOT supy174_abre_tela_oc(p_ordem_sup.cod_empresa,
                                       p_ordem_sup.num_oc,
                                       p_ordem_sup.num_versao,
                                       p_ordem_sup.ies_situa_oc) THEN
             LET l_houve_erro = 1
           END IF
        END IF
     END IF

     IF NOT l_houve_erro THEN
        WHENEVER ERROR CONTINUE
        LET p_tip_ajuste = 'A'
        IF NOT pol1233_grava_prog_ord() THEN
           LET l_houve_erro = TRUE
        END IF
        WHENEVER ERROR STOP
     END IF

     IF NOT l_houve_erro THEN
        WHENEVER ERROR CONTINUE
        LET p_parametro.cod_empresa = p_prog_ordem_sup.cod_empresa
        LET p_parametro.num_oc = p_prog_ordem_sup.num_oc
        LET p_parametro.nom_programa = 'POL1233'
        LET p_parametro.dat_programacao = p_prog_ordem_sup.dat_entrega_prev
        LET p_parametro.qtd_ajuste = p_prog_ordem_sup.qtd_solic
        LET p_parametro.seq_periodo = 0 #p_prog_ordem_sup.num_prog_entrega
        
        IF pol1233_le_processo() THEN
           LET p_parametro.chave_processo = p_chave_processo
           LET p_parametro.id_prog_ord = p_id_prog_ord

           IF NOT pol1234_trava90(p_parametro) THEN 
              LET l_houve_erro = TRUE   
           ELSE
             SELECT ies_situa_oc INTO p_status_oc
               FROM ordem_sup
              WHERE cod_empresa = p_cod_empresa
                AND num_oc = p_prog_ordem_sup.num_oc
                AND ies_versao_atual = 'S'
             DISPLAY p_status_oc TO ies_situa_oc
           END IF   
        ELSE
           LET l_houve_erro = TRUE   
        END IF
        WHENEVER ERROR STOP                                
     END IF
     
     IF NOT l_houve_erro THEN
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("EFETIVACAO-COMMIT","PROG_ORDEM_SUP")
           RETURN
        END IF

        IF m_exibir_oc_designada_aprov_tec = "S" THEN # 779618
           IF NOT sup029_orcamento_ordem_sup(FALSE) THEN
              CALL log0030_mensagem("Problemas ao atualizar OC para condicional.","exclamation")
           END IF
        END IF

        #CALL supy15_verifica_nivel_aprov_usuario(p_cod_empresa,
        #                                         gr_dados_tela_com.num_oc)
        #CURRENT WINDOW IS w_sup02901

        IF m_abre_aut_tela_comp = "S" THEN
          CALL sup411_zoom_componentes_beneficia(p_ordem_sup.cod_empresa, p_ordem_sup.num_oc)
          CURRENT WINDOW IS w_sup02901
        END IF
        CALL sup029_verifica_emergencia()
        MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
        LET p_ies_cons = FALSE

        #523974
        IF find4GLFunction('supy71_cliente_907') THEN
           IF supy71_cliente_907() = TRUE  THEN

              IF find4GLFunction('supy71_texto_local') THEN
                 IF supy71_texto_local(p_ordem_sup.num_oc) = FALSE THEN
                    CALL log0030_mensagem("Alteração do texto local cancelada.","excla")
                 ELSE
                    MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
                 END IF
              ELSE
                 MESSAGE "Alteração do texto local efetuada com sucesso. " ATTRIBUTE(REVERSE)
              END IF

           END IF
        END IF

        IF sup029_verifica_componentes() THEN
           CALL sup0290_atualiza_oc_benef()
           IF NOT g_ies_genero THEN
              DISPLAY " BENEFICIAMENTO " AT 04,55 ATTRIBUTE(REVERSE)
           ELSE
              CALL log4050_altera_atributo("benef","text","BENEFICIAMENTO")
           END IF

           CALL sup135_mostra_fornecedores(p_ordem_sup.cod_item, gr_dados_tela_com.num_oc)
        ELSE
           IF NOT g_ies_genero THEN
              DISPLAY "                " AT 04,55
           ELSE
              CALL log4050_altera_atributo("benef","text","")
           END IF
        END IF

        #IF  p_item.ies_tip_item = "B" THEN
        IF  p_ies_tip_item = "B" THEN
        #AND p_par_sup_compl.ies_baixa_benef = "2" THEN ## precisa dos componentes
        ### para baixa do saldo em terceiros
           IF l_processa_sup4110 THEN                  #Vanderlei - OS 426389 #
              CALL sup411_zoom_componentes_beneficia(p_cod_empresa, p_ordem_sup.num_oc)
           END IF
        END IF
     ELSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP
     END IF
  ELSE
     IF p_status = 0 THEN
        LET p_ordem_sup.* = p_ordem_supr.*
        CALL sup029_exibe_dados()
        CALL sup029_exibe_area()
     END IF
  END IF

 END FUNCTION

#-----------------------------#
FUNCTION pol1233_le_processo()#
#-----------------------------#

		SELECT MAX(chave_processo) 
		INTO p_chave_processo
		FROM mapa_compras_data_454
		WHERE cod_empresa = p_cod_empresa
		
		IF STATUS <> 0 THEN
       CALL log003_err_sql('SELECT','MAPA_COMPRAS_DATA_454')
		   RETURN FALSE
    END IF
    
    IF p_chave_processo IS NULL THEN
       LET p_chave_processo = 0
    END IF
    
    RETURN TRUE
    
END FUNCTION

#---------------------------------------------------------#
 FUNCTION sup029_entrada_dados(p_funcao,l_permite_alterar)
#---------------------------------------------------------#
  DEFINE p_funcao          CHAR(30)
  DEFINE p_primeira_vez    SMALLINT
  DEFINE l_qtd_mult        DECIMAL(15,3),
         l_qtd_inteiro     CHAR(25),
         l_qtd_solic       DECIMAL(15,3),
         l_mult1           DECIMAL(15,3),
         l_mult2           DECIMAL(15,3),
         l_ind             SMALLINT,
         l_msg             CHAR(70),
         l_permite_alterar SMALLINT,
         l_fat_conver      LIKE fat_conver.fat_conver_unid,
         l_qtd_solicitada  DECIMAL(15,3),
         l_programa        CHAR(10)

  IF NOT g_ies_genero THEN
     DISPLAY "               " AT 14,50
  ELSE
     CALL log4050_altera_atributo("numseq","text","")
  END IF

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_sup02901

  DISPLAY BY NAME gr_dados_tela_com.cod_progr
  DISPLAY BY NAME p_formonly.nom_progr
  DISPLAY BY NAME gr_dados_tela_com.cod_comprador
  DISPLAY BY NAME p_formonly.nom_comprador
  DISPLAY BY NAME gr_dados_tela_com.ies_situa_oc

  LET p_status       = 0
  LET p_primeira_vez = TRUE
  IF p_funcao = "INCLUSAO" THEN
     LET l_programa = "SUP0290"
     IF m_informa_val_previsto = "N" THEN
        DISPLAY "                              " AT 11,49
     END IF

     LET int_flag = 0
     INPUT BY NAME gr_dados_tela_com.cod_empresa,
                   gr_dados_tela_com.num_oc,
                   gr_dados_tela_com.cod_item,
                   gr_dados_tela_com.qtd_solic,
                   gr_dados_tela_com.cod_uni_funcio,
                   gr_dados_tela_com.dat_entrega_prev,
                   mr_tela.pre_unit_oc,
                   gr_dados_tela_com.cod_progr,
                   gr_dados_tela_com.cod_comprador    WITHOUT DEFAULTS

     BEFORE FIELD cod_empresa
       IF p_primeira_vez = TRUE THEN
          LET p_primeira_vez = FALSE
          IF NOT sup029_verifica_centra_emp_sup() THEN
             NEXT FIELD cod_empresa
          END IF
          LET p_cod_empresa = gr_dados_tela_com.cod_empresa
          IF p_num_args <> 0 AND p_cod_item IS NOT NULL THEN
             LET gr_dados_tela_com.cod_item = p_cod_item
             DISPLAY BY NAME gr_dados_tela_com.cod_item
          END IF
          NEXT FIELD cod_item
       END IF
       IF NOT m_possui_centraliz THEN
          NEXT FIELD cod_item
       END IF

     AFTER FIELD cod_empresa
       IF gr_dados_tela_com.cod_empresa IS NOT NULL THEN
          IF NOT sup029_verifica_centra_emp_sup() THEN
             NEXT FIELD cod_empresa
          END IF
          IF p_cod_empresa <> gr_dados_tela_com.cod_empresa THEN
             LET p_cod_empresa = gr_dados_tela_com.cod_empresa
             CALL sup0290_leitura_parametros()
             LET gr_dados_tela_com.cod_progr = mr_usuario.cod_progr
             CALL sup029_verifica_programador() RETURNING p_status
             IF mr_usuario.cod_progr IS NULL THEN
                ERROR "USUARIO nao cadastrado como PROGRAMADOR nesta empresa"
                NEXT FIELD cod_empresa
             END IF
          END IF
          IF p_num_args <> 0 THEN
             LET gr_dados_tela_com.cod_item = p_cod_item
          END IF
          NEXT FIELD cod_item
       ELSE
          ERROR "Informe o codigo da empresa"
          NEXT FIELD cod_empresa
       END IF

     BEFORE FIELD cod_item
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('Control-Z','Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

       IF gr_dados_tela_com.ies_situa_oc = "P" THEN
          DISPLAY "PLANEJADA" TO tex_situa_oc
       ELSE
          DISPLAY "EM ABERTO" TO tex_situa_oc
       END IF

     AFTER FIELD cod_item
       IF gr_dados_tela_com.cod_item IS NULL THEN
          IF  fgl_lastkey() <> fgl_keyval("UP")
          AND fgl_lastkey() <> fgl_keyval("LEFT") THEN
             ERROR "Codigo do item deve ser informado"
             NEXT FIELD cod_item
          END IF
       ELSE
          IF sup029_verifica_item() = FALSE THEN
             ERROR "Item nao cadastrado"
             NEXT FIELD cod_item
          END IF
       END IF
      
       SELECT COUNT(num_oc)
         INTO p_count
         FROM ordem_sup
        WHERE cod_empresa = p_cod_empresa
          AND ies_versao_atual = 'S'
          AND cod_item = gr_dados_tela_com.cod_item
          AND ies_situa_oc = 'X'

       IF STATUS <> 0 THEN
          CALL log003_err_sql('SELECT','ordem_sup:count')
          RETURN FALSE
       END IF
      
       IF p_count > 0 THEN
          LET p_msg = 'Esse item ja possui ordens bloqueadas\n ',
                      'pelas regras do trava90. Só será per-\n',
                      'mitida a geração de novas ordens após\n',
                      'a liberação das anteriores.'
          CALL log0030_mensagem(p_msg,'info')
          NEXT FIELD cod_item
       END IF
       
       
       IF find4GLFunction('supy31_valida_unid_med_fixa') THEN
          IF NOT supy31_valida_unid_med_fixa(p_ies_tip_item, p_formonly.cod_unid_med) THEN
             NEXT FIELD cod_item
          END IF
       END IF

       #O.S. 542737
       IF find4GLFunction('supy87_programdor_item') THEN
          IF NOT supy87_programdor_item(p_cod_empresa, gr_dados_tela_com.cod_item, mr_usuario.cod_progr) THEN
             NEXT FIELD cod_item
          END IF
       END IF
       #O.S. 542737

       #736097#
       IF find4GLFunction('supy62_empresa_55') THEN
          IF supy62_empresa_55() THEN
             IF find4GLFunction('supy62_valida_programador_subst') THEN
                IF NOT supy62_valida_programador_subst(p_cod_empresa, gr_dados_tela_com.cod_item, p_user, TRUE) THEN
                   NEXT FIELD cod_item
                END IF
             END IF
          END IF
       END IF
       #---fim--- 736097#

       IF NOT sup029_verifica_item_sup() THEN
          NEXT FIELD cod_item
       END IF

       IF gr_dados_tela_com.cod_item IS NOT NULL AND
          gr_dados_tela_com.cod_item <> " " THEN
          IF p_ies_situacao = 'I' THEN
             CALL log0030_mensagem("Item inativo.","excla")
             NEXT FIELD cod_item
          ELSE
             IF p_ies_situacao = 'C' THEN
                CALL log0030_mensagem("Item cancelado.","excla")
                NEXT FIELD cod_item
             END IF
          END IF
       END IF

       IF NOT log305_permissao_item(gr_dados_tela_com.cod_item,"SUP0290") THEN
         ERROR "Usuario nao tem permissao para acessar o item"
         NEXT FIELD cod_item
       END IF

       IF p_ies_item_prod_oc = "N" THEN
         IF p_ies_tip_item <> "C" AND p_ies_tip_item <> "B" THEN
            ERROR "Item deve ser do tipo COMPRADO ou BENEFICIADO"
            NEXT FIELD cod_item
         END IF
       END IF
       #IF p_ies_situacao = "C" THEN
       #   ERROR "So' e' possivel criar ordens para itens ativos"
       #   NEXT FIELD cod_item
       #END IF
       #IF p_ies_situacao = "I" THEN
       #   ERROR "Nao e' permitido criar ordens para itens inativos"
       #   NEXT FIELD cod_item
       #END IF
       IF sup0290_item_controle_estoque_fisico(gr_dados_tela_com.cod_empresa,
                                               gr_dados_tela_com.cod_item) THEN
          ERROR "Item com controle de estoque fisico, utilizar tela de Debito Direto"
          NEXT FIELD cod_item
       END IF
       IF p_ies_item_estoq = "N" THEN
          ERROR "Esta funcao so' pode ser utilizada para material de estoque"
          NEXT FIELD cod_item
       END IF
       IF p_ies_tip_item = "B" THEN
          IF sup029_verifica_estrutura() = FALSE THEN
             ERROR "Nao existe componentes para o Item tipo BENEFICIADO"
             IF NOT log004_confirm(19,40) THEN
                NEXT FIELD cod_item
             END IF
          END IF
       END IF

       LET gr_dados_tela_com.cod_tip_despesa = p_item_sup.cod_tip_despesa

       LET gr_dados_tela_com.gru_ctr_desp  = p_gru_ctr_desp
       LET gr_dados_tela_com.cod_comprador = p_cod_comprador

       DISPLAY BY NAME gr_dados_tela_com.cod_comprador
       IF sup029_verifica_comprador() = FALSE THEN
           CALL log0030_mensagem("Comprador nao cadastrado","info")
           NEXT FIELD cod_comprador
       END IF

       IF sup029_pesq_td_compl(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.cod_tip_despesa) = FALSE THEN
          ERROR "Tipo de despesa do item esta BLOQUEADO"
          NEXT FIELD cod_item
       END IF

       INITIALIZE m_req_benef_cc_td TO NULL
       WHENEVER ERROR CONTINUE
       SELECT parametros[167,167]
         INTO m_req_benef_cc_td
         FROM item_parametro
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = gr_dados_tela_com.cod_item
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 OR
          m_req_benef_cc_td IS NULL OR
          m_req_benef_cc_td = " " THEN
          LET m_req_benef_cc_td = "N"
       END IF

       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z', NULL)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
     BEFORE FIELD dat_entrega_prev
     IF m_data_lead_time = 'S' THEN
        CALL sup0290_busca_lead_time(gr_dados_tela_com.cod_item)
        LET gr_dados_tela_com.dat_origem = gr_dados_tela_com.dat_entrega_prev
        LET gr_dados_tela_com.dat_abertura_oc = TODAY
        DISPLAY BY NAME gr_dados_tela_com.dat_entrega_prev
        IF fgl_lastkey() <> FGL_KEYVAL("UP") AND
           FGL_LASTKEY() <> FGL_KEYVAL("LEFT") THEN
           NEXT FIELD cod_progr
        ELSE
           NEXT FIELD cod_uni_funcio
        END IF
     END IF

     AFTER FIELD dat_entrega_prev
       IF gr_dados_tela_com.dat_entrega_prev IS NOT NULL THEN
          IF m_ies_dat_retro = "N" AND gr_dados_tela_com.dat_entrega_prev < TODAY THEN
             ERROR "Data de entrega menor que data atual"
             NEXT FIELD dat_entrega_prev
          END IF
          IF gr_dados_tela_com.dat_entrega_prev < p_ordem_sup.dat_entrega_prev THEN
             ERROR "Data de entrega menor que data atual"
             NEXT FIELD dat_entrega_prev
          ELSE
             IF NOT sup029_verifica_data_valida() THEN
                ERROR "Data de entrega nao e data util"
                NEXT FIELD dat_entrega_prev
             END IF
          END IF
       END IF
       LET gr_dados_tela_com.dat_abertura_oc = gr_dados_tela_com.dat_entrega_prev -
                                          p_lead_time UNITS DAY
       LET gr_dados_tela_com.dat_origem = gr_dados_tela_com.dat_entrega_prev

       IF m_informa_val_previsto = "N" THEN
          IF fgl_lastkey() <> FGL_KEYVAL("UP") AND
             FGL_LASTKEY() <> FGL_KEYVAL("LEFT") THEN
             NEXT FIELD cod_progr
          END IF
       END IF

     AFTER FIELD qtd_solic
       IF p_funcao = "INCLUSAO" THEN
          LET m_codigo_comprador_pr = gr_dados_tela_com.cod_comprador
       END IF
       IF gr_dados_tela_com.qtd_solic < 0 THEN
          ERROR "Informe quantidade maior que zero"
          NEXT FIELD qtd_solic
       END IF
       IF g_ies_considera_mult = "S" THEN
          LET l_qtd_mult = p_item_sup.qtd_lote_multiplo
          IF l_qtd_mult = 0 OR l_qtd_mult IS NULL THEN
             LET l_qtd_mult = 1
          END IF
          LET l_qtd_solic = gr_dados_tela_com.qtd_solic
          LET l_mult1 = (gr_dados_tela_com.qtd_solic / l_qtd_mult)
          LET l_qtd_inteiro = l_mult1
          FOR l_ind = 1 TO 25
             IF l_qtd_inteiro[l_ind] <> " " THEN
                IF l_qtd_inteiro[l_ind] = "." OR l_qtd_inteiro[l_ind] = "," THEN
                   LET l_qtd_inteiro[l_ind,25] = " "
                   EXIT FOR
                END IF
             ELSE
                EXIT FOR
             END IF
          END FOR
          LET l_mult1 = l_qtd_inteiro
          LET l_mult2 = l_mult1 * l_qtd_mult
          IF l_mult2 <> gr_dados_tela_com.qtd_solic THEN
             MESSAGE "Lote múltiplo do item: ",
                      p_item_sup.qtd_lote_multiplo USING "<<<<<<<<<.<<<",
                      " ",p_formonly.cod_unid_med CLIPPED ATTRIBUTE(REVERSE)
             IF NOT log0040_confirm(17,13,"Qtde nao e' MULTIPLA do lote multiplo do item. Continua?") THEN
                MESSAGE ""
                NEXT FIELD qtd_solic
             END IF
             MESSAGE ""
          END IF
       END IF

       IF sup0538_existe_unid_compra_item(p_cod_empresa,gr_dados_tela_com.cod_item) THEN
          LET l_fat_conver = sup0538_fat_conver_estoque_compra_item(p_cod_empresa,
                                                                    gr_dados_tela_com.cod_item)
       ELSE
          LET l_fat_conver = 1
       END IF

       LET l_qtd_solicitada = gr_dados_tela_com.qtd_solic * l_fat_conver

       IF l_qtd_solicitada > 999999999.999 THEN
          CALL log0030_mensagem("Estouro quantidade solicitada, necessário diferentes ordens para atender quantidade desejada.","exclamation")
          NEXT FIELD qtd_solic
       END IF

     BEFORE FIELD cod_uni_funcio
       IF g_ies_grafico THEN
         --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
       ELSE
         DISPLAY "( Zoom )" AT 3,68
       END IF
       IF m_req_benef_cc_td = "N" THEN
          IF p_ies_uni_funcio = "N" THEN
             IF fgl_lastkey() = fgl_keyval("UP") OR
                fgl_lastkey() = fgl_keyval("LEFT")  THEN
                NEXT FIELD qtd_solic
             ELSE
                NEXT FIELD dat_entrega_prev
             END IF
          END IF
       END IF

     AFTER FIELD cod_uni_funcio
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z',NULL)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF gr_dados_tela_com.cod_uni_funcio IS NOT NULL THEN
          IF sup029_verifica_cod_uni_funcio() = FALSE THEN
             ERROR "Unidade funcional nao cadastrada"
             NEXT FIELD cod_uni_funcio
          END IF
       ELSE
          IF m_req_benef_cc_td = "S" THEN
             ERROR " Unidade Funcional deve ser informada. "
             NEXT FIELD cod_uni_funcio
          END IF
       END IF

     BEFORE FIELD cod_comprador

       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

       IF m_verif_comp = "N" THEN

          #COD_ITEM
          IF gr_dados_tela_com.cod_item IS NULL THEN
             CALL log0030_mensagem("Código do item deve ser informado","info")
             NEXT FIELD cod_item
          END IF

          #DAT_ENTREGA_PREV
          IF gr_dados_tela_com.dat_entrega_prev IS NULL THEN
             CALL log0030_mensagem('Data de entrega deve ser informada','info')
             NEXT FIELD dat_entrega_prev
          END IF

          #QTD_SOLIC
          IF gr_dados_tela_com.qtd_solic IS NULL THEN
             CALL log0030_mensagem('Quantidade deve ser informada','info')
             NEXT FIELD qtd_solic
          END IF

          #COD_UNI_FUNCIO
          IF p_ies_uni_funcio = "S" THEN
             IF gr_dados_tela_com.cod_uni_funcio IS NULL THEN
                CALL log0030_mensagem('Unidade funcional deve ser informada','info')
                NEXT FIELD cod_uni_funcio
             END IF
          END IF

          #COD_COMPRADOR
          IF gr_dados_tela_com.cod_comprador IS NULL THEN
             CALL log0030_mensagem('Comprador deve ser informado','info')
             NEXT FIELD cod_comprador
          END IF

          EXIT INPUT
       END IF

     AFTER FIELD cod_comprador
       IF find4GLFunction('supy15_valida_comprador_solicitante') THEN
          IF NOT supy15_valida_comprador_solicitante(l_programa,p_funcao,gr_dados_tela_com.cod_empresa,
                                                     gr_dados_tela_com.num_oc,
                                                     m_codigo_comprador_pr,gr_dados_tela_com.cod_comprador,
                                                     gr_dados_tela_com.cod_progr)THEN
             IF FGL_LASTKEY() = FGL_KEYVAL("UP")
             OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
                NEXT FIELD cod_progr
             ELSE
                NEXT FIELD cod_comprador
             END IF
          END IF
       END IF

       IF gr_dados_tela_com.cod_comprador IS NOT NULL THEN
          IF sup029_verifica_comprador() = FALSE THEN
             ERROR "Comprador nao cadastrado"
             NEXT FIELD cod_comprador
          END IF
          IF NOT supr22_comprador_ativo(p_cod_empresa, gr_dados_tela_com.cod_comprador) THEN
             CALL log0030_mensagem("Código do comprador não está ativo.","exclamation")
             NEXT FIELD cod_comprador
          END IF
       END IF
       IF g_ies_grafico THEN
         --# CALL fgl_dialog_setkeylabel ('Control-Z',NULL)
       ELSE
         DISPLAY "--------" AT 3,68
       END IF
        IF m_informa_val_previsto = "N" THEN
           IF fgl_lastkey() = FGL_KEYVAL("UP") OR
              FGL_LASTKEY() = FGL_KEYVAL("LEFT") THEN
              NEXT FIELD dat_entrega_prev
           END IF
        END IF

     BEFORE FIELD pre_unit_oc
#--inicio--OS704186 Antonio#
        IF  m_controla_gao = "S"
        AND m_informa_val_previsto = "S"
        AND sup0772_verifica_oc_aprovada(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.num_oc)
        AND m_orcamento_periodo  = "N"
        AND m_usa_cond_pagto     = "N"
        AND m_atua_somente_desig = "N" THEN
           # Se utiliza o GAO e a OC está aprovada
           # não permitir alteração do valor previsto
           IF FGL_LASTKEY() = FGL_KEYVAL("UP")
           OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
              NEXT FIELD dat_entrega_prev
           ELSE
              NEXT FIELD cod_comprador
           END IF
        END IF
#---fim----OS704186#
        IF m_informa_val_previsto = "S" THEN
           IF mr_tela.pre_unit_oc IS NULL
           OR mr_tela.pre_unit_oc = " "
           OR mr_tela.pre_unit_oc = 0 THEN
              LET mr_tela.pre_unit_oc = sup0290_busca_item_custo(gr_dados_tela_com.cod_item)
           END IF
        END IF

     AFTER FIELD pre_unit_oc
        IF m_informa_val_previsto = "S" THEN
           IF mr_tela.pre_unit_oc IS NULL
           OR mr_tela.pre_unit_oc = " " THEN
              CALL log0030_mensagem("Preço previsto não informado.","exclamation")
              NEXT FIELD pre_unit_oc
           END IF
        END IF

     AFTER INPUT
       IF int_flag = 0 THEN
          #730768#
          IF m_controla_gao = "S"               AND
             m_atua_somente_desig = "N"         AND
             m_ies_bloqueia_oc_igual_zero = "S" THEN
             IF mr_tela.pre_unit_oc <= 0 THEN
                CALL log0030_mensagem("Preço unitário menor ou igual a zero","info")
                NEXT FIELD pre_unit_oc
             END IF
          END IF
          #---fim--- 730768#
          IF NOT supr22_programador_ativo(p_cod_empresa, gr_dados_tela_com.cod_progr) THEN
             CALL log0030_mensagem("Código do programador não está ativo.","exclamation")
             LET int_flag = 1
             EXIT INPUT
          END IF
          #COD_ITEM

          IF gr_dados_tela_com.cod_item IS NULL THEN
             CALL log0030_mensagem('Código do item deve ser informado','info')
             NEXT FIELD cod_item
          END IF

          IF find4GLFunction('supy31_valida_unid_med_fixa') THEN
             IF NOT supy31_valida_unid_med_fixa(p_ies_tip_item, p_formonly.cod_unid_med) THEN
                NEXT FIELD cod_item
             END IF
          END IF

          #O.S. 542737
          IF find4GLFunction('supy87_programdor_item') THEN
             IF NOT supy87_programdor_item(p_cod_empresa, gr_dados_tela_com.cod_item, mr_usuario.cod_progr) THEN
                NEXT FIELD cod_item
             END IF
          END IF
          #O.S. 542737

          #736097#
          IF find4GLFunction('supy62_empresa_55') THEN
             IF supy62_empresa_55() THEN
                IF find4GLFunction('supy62_valida_programador_subst') THEN
                   IF NOT supy62_valida_programador_subst(p_cod_empresa, gr_dados_tela_com.cod_item, p_user, TRUE) THEN
                      NEXT FIELD cod_item
                   END IF
                END IF
             END IF
          END IF
          #---fim--- 736097#

          #DAT_ENTREGA_PREV
          IF gr_dados_tela_com.dat_entrega_prev IS NULL THEN
             CALL log0030_mensagem('Data de entrega deve ser informada','info')
             NEXT FIELD dat_entrega_prev
          END IF

          #QTD_SOLIC
          IF gr_dados_tela_com.qtd_solic IS NULL THEN
             CALL log0030_mensagem('Quantidade deve ser informada','info')
             NEXT FIELD qtd_solic
          END IF

          #COD_UNI_FUNCIO
          IF p_ies_uni_funcio = "S" THEN
             IF gr_dados_tela_com.cod_uni_funcio IS NULL THEN
                CALL log0030_mensagem('Unidade funcional deve ser informada','info')
                NEXT FIELD cod_uni_funcio
             END IF
          END IF

          #--inicio--OS704186  #
          IF m_informa_val_previsto = "S" THEN
             LET p_ordem_sup.cod_moeda = p_par_con.cod_moeda_padrao
          END IF
          #---fim----OS704186  #

          #COD_COMPRADOR
          IF gr_dados_tela_com.cod_comprador IS NULL THEN
             CALL log0030_mensagem('Comprador deve ser informado','info')
             NEXT FIELD cod_comprador
          END IF
          IF find4GLFunction('supy15_valida_comprador_solicitante') THEN
             IF NOT supy15_valida_comprador_solicitante(l_programa,p_funcao,gr_dados_tela_com.cod_empresa,
                                                        gr_dados_tela_com.num_oc,
                                                        m_codigo_comprador_pr,gr_dados_tela_com.cod_comprador,
                                                        gr_dados_tela_com.cod_progr)THEN
                IF FGL_LASTKEY() = FGL_KEYVAL("UP")
                OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
                   NEXT FIELD cod_progr
                ELSE
                   NEXT FIELD cod_comprador
                END IF
             END IF
          END IF
       END IF

     ON KEY (f1, control-w)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
       CALL sup029_help()

     ON KEY (control-z, f4)
       CALL sup029_popups()
     END INPUT
  ELSE
     LET l_programa = "SUP0290"
     IF m_informa_val_previsto = "N" THEN
        DISPLAY "                              " AT 11,49
     END IF

     LET int_flag = 0
     INPUT BY NAME gr_dados_tela_com.cod_uni_funcio,
                   gr_dados_tela_com.cod_comprador WITHOUT DEFAULTS

     BEFORE FIELD cod_uni_funcio

       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF

       INITIALIZE m_req_benef_cc_td TO NULL
       WHENEVER ERROR CONTINUE
       SELECT parametros[167,167]
         INTO m_req_benef_cc_td
         FROM item_parametro
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = gr_dados_tela_com.cod_item
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 OR
          m_req_benef_cc_td IS NULL OR
          m_req_benef_cc_td = " " THEN
          LET m_req_benef_cc_td = "N"
       END IF

       IF m_req_benef_cc_td = "N" THEN
          IF p_ies_uni_funcio = "N" THEN
             NEXT FIELD cod_comprador
          END IF
       END IF

     AFTER FIELD cod_uni_funcio

       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z',NULL)
       ELSE
          DISPLAY "--------" AT 3,68
       END IF
       IF gr_dados_tela_com.cod_uni_funcio IS NOT NULL THEN
          IF NOT sup029_verifica_cod_uni_funcio() THEN
             ERROR "Unidade funcional nao cadastrada"
             NEXT FIELD cod_uni_funcio
          END IF
       ELSE
          IF m_req_benef_cc_td = "S" THEN
             ERROR " Unidade Funcional deve ser informada. "
             NEXT FIELD cod_uni_funcio
          END IF
       END IF

     BEFORE FIELD cod_comprador
       IF g_ies_grafico THEN
         --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
       ELSE
         DISPLAY "( Zoom )" AT 3,68
       END IF

       IF p_ies_uni_funcio = "S" THEN
          IF gr_dados_tela_com.cod_uni_funcio IS NULL THEN
             CALL log0030_mensagem("Unidade funcional deve ser informada", "info")
             NEXT FIELD cod_uni_funcio
          END IF
       END IF

       IF m_verif_comp = "N" THEN
          EXIT INPUT
       END IF

     AFTER FIELD cod_comprador
     # p_ies_uni_funcio = "N" AND
       IF find4GLFunction('supy15_valida_comprador_solicitante') THEN
          IF NOT supy15_valida_comprador_solicitante(l_programa,p_funcao,gr_dados_tela_com.cod_empresa,
                                                      gr_dados_tela_com.num_oc,
                                                      m_codigo_comprador_pr,gr_dados_tela_com.cod_comprador,
                                                      gr_dados_tela_com.cod_progr)THEN
             IF FGL_LASTKEY() = FGL_KEYVAL("UP")
             OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
                NEXT FIELD cod_uni_funcio
             ELSE
                NEXT FIELD cod_comprador
             END IF
          END IF
       END IF

       IF gr_dados_tela_com.cod_comprador IS NOT NULL THEN
          IF sup029_verifica_comprador() = FALSE THEN
             ERROR "Comprador nao cadastrado"
             NEXT FIELD cod_comprador
          END IF
          IF NOT supr22_comprador_ativo(p_cod_empresa, gr_dados_tela_com.cod_comprador) THEN
             CALL log0030_mensagem("Código do comprador não está ativo.","exclamation")
             NEXT FIELD cod_comprador
          END IF
       END IF
       IF g_ies_grafico THEN
         --# CALL fgl_dialog_setkeylabel ('Control-Z',NULL)
       ELSE
         DISPLAY "--------" AT 3,68
       END IF

     AFTER INPUT
       IF int_flag = 0 THEN
          #COD_UNI_FUNCIO
          IF p_ies_uni_funcio = "S" THEN
             IF gr_dados_tela_com.cod_uni_funcio IS NULL THEN
                ERROR "Unidade funcional deve ser informada"
                NEXT FIELD cod_uni_funcio
             END IF
          END IF

          #COD_COMPRADOR
          IF gr_dados_tela_com.cod_comprador IS NULL THEN
             ERROR "Comprador deve ser informado"
             NEXT FIELD cod_comprador
          END IF
          IF NOT supr22_programador_ativo(p_cod_empresa, gr_dados_tela_com.cod_progr) then
             CALL log0030_mensagem("Código do Programador esta inativo.","exclamation")
             LET INT_FLAG = 1
             EXIT INPUT
          END IF
       END IF

     ON KEY (f1, control-w)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
       CALL sup029_help()

     ON KEY (control-z, f4)
       CALL sup029_popups()
     END INPUT
  END IF

  IF NOT g_ies_grafico THEN
     DISPLAY "--------" AT 3,68
  END IF

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup02901
  IF int_flag = 0 THEN
     IF sup029_processa_area(p_funcao) THEN
        RETURN TRUE
     END IF
     IF p_funcao = "INCLUSAO" THEN
        ERROR "Inclusao cancelada"
     ELSE
        ERROR "Modificacao cancelada"
     END IF
  ELSE
     IF p_funcao = "INCLUSAO" THEN
        ERROR "Inclusao cancelada"
     ELSE
        ERROR "Modificacao cancelada"
     END IF
  END IF
  RETURN FALSE
 END FUNCTION

#---------------------------------------#
 FUNCTION sup029_processa_area(p_funcao)
#---------------------------------------#
  DEFINE p_funcao                CHAR(30),
         l_arr_curr              SMALLINT,
         l_aux                   SMALLINT

  CALL log006_exibe_teclas("02 06 07 17 18",p_versao)
  CURRENT WINDOW IS w_sup02901

  IF p_funcao = "INCLUSAO" THEN
     INITIALIZE p_area TO NULL
  END IF

  IF p_par_con.ies_contab_aen = "S" OR p_par_con.ies_contab_aen = "4" THEN
     IF p_funcao = "INCLUSAO" THEN
        CALL sup029_busca_dados_prev_cons()
        CALL sup029_busca_dados_item()
     END IF
  ELSE
     IF p_funcao = "INCLUSAO" THEN
        LET p_ind_arr = 1
        LET p_area[1].seq = 1
        LET p_area[1].cod_area_negocio = 0
        LET p_area[1].cod_lin_negocio  = 0
        LET p_area[1].pct_particip_comp = 100
        SELECT num_conta INTO p_area[1].num_conta
          FROM item_sup
         WHERE item_sup.cod_empresa = p_cod_empresa AND
               item_sup.cod_item = gr_dados_tela_com.cod_item
        IF sqlca.sqlcode <> 0 THEN
           INITIALIZE p_area[1].num_conta TO NULL
        END IF
     END IF
## 422118
     IF p_area[1].num_conta IS NULL THEN
        LET p_area[1].num_conta = 0
     END IF

     CALL con088_verifica_cod_conta(p_cod_empresa,
                                    p_area[1].num_conta,
                                    "S", TODAY)
          RETURNING p_plano_contas.*, p_status

     IF p_plano_contas.ies_titulo <> "N" THEN
        LET  p_area[1].den_conta = NULL
     END IF
     IF p_status = FALSE THEN
        IF p_plano_contas.den_conta IS NOT NULL AND p_plano_contas.den_conta <> " " THEN
           CALL log0030_mensagem(p_plano_contas.den_conta, "exclamation")
        END IF

        LET p_area[1].den_conta = p_plano_contas.den_conta
        #LET p_area[1].den_conta = NULL
     ELSE
        LET p_area[1].den_conta = p_plano_contas.den_conta
     END IF
  END IF

  CALL set_count(670)
  LET p_total  = 0

  IF log0150_verifica_se_tabela_existe("sup_part_item_aen") THEN #OS528621
     IF sup0290_seleciona_des_rateio() THEN
        CALL sup0290_carrega_array()
     END IF
  END IF

  CALL set_count(670)

  LET int_flag = 0
  INPUT ARRAY p_area WITHOUT DEFAULTS FROM s_area.*

  BEFORE FIELD cod_area_negocio
    LET p_ind_arr = arr_curr()
    LET p_ind1  = scr_line()
    LET p_area[p_ind_arr].seq = p_ind_arr
    DISPLAY p_area[p_ind_arr].seq TO s_area[p_ind1].seq
    DISPLAY p_area[1].num_conta TO s_area[p_ind1].num_conta
    DISPLAY p_area[1].den_conta  TO s_area[p_ind1].den_conta
    LET p_area[p_ind_arr].num_conta = p_area[1].num_conta
    LET p_area[p_ind_arr].den_conta = p_area[1].den_conta
    IF (p_par_con.ies_contab_aen = "N")
    OR (g_ies_conta_item = "S" AND p_ind_arr > 1) THEN
       EXIT INPUT
    END IF
#--inicio--OS704186Antonio#
    IF  m_controla_gao = "S"
    AND m_informa_val_previsto = "S"
    AND sup0772_verifica_oc_aprovada(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.num_oc)
    AND m_orcamento_periodo  = "N"
    AND m_usa_cond_pagto     = "N"
    AND m_atua_somente_desig = "N" THEN
       # Se utiliza o GAO e a OC está aprovada
       # não permitir alteração do valor previsto
       IF FGL_LASTKEY() = FGL_KEYVAL("UP")
       OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
          NEXT FIELD pct_particip_comp
       ELSE
          NEXT FIELD pct_particip_comp
       END IF
    END IF
#---fim----OS704186#
    IF g_ies_grafico THEN
       --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
    ELSE
       DISPLAY "( Zoom )" AT 3,68
    END IF

  AFTER FIELD cod_area_negocio
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    IF p_par_con.ies_contab_aen = "S" THEN
       IF p_area[p_ind_arr].cod_area_negocio IS NOT NULL THEN
          IF sup029_verifica_area_negocio() = FALSE THEN
             ERROR "Area de negocio nao cadastrada"
             NEXT FIELD cod_area_negocio
          END IF
       END IF
    END IF
    IF g_ies_grafico THEN
       --# CALL fgl_dialog_setkeylabel ('Control-Z',NULL)
    ELSE
       DISPLAY "--------" AT 3,68
    END IF

  BEFORE FIELD cod_lin_negocio
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    LET p_area[p_ind_arr].seq = p_ind_arr
    DISPLAY p_area[p_ind_arr].seq TO s_area[p_ind1].seq
    IF p_par_con.ies_contab_aen = "S" THEN
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
       ELSE
          DISPLAY "( Zoom )" AT 3,68
       END IF
    END IF

  AFTER FIELD cod_lin_negocio
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    IF p_par_con.ies_contab_aen = "S" THEN
       IF p_area[p_ind_arr].cod_lin_negocio IS NOT NULL THEN
          IF sup029_verifica_linha_negocio() = FALSE THEN
             ERROR "Linha de negocio nao cadastrada"
             NEXT FIELD cod_lin_negocio
          END IF
          IF sup029_verifica_area_linha_negocio() = FALSE THEN
             ERROR "Relacionamento Area/Linha de negocio nao cadastrado"
             NEXT FIELD cod_area_negocio
          END IF
       END IF
       IF g_ies_grafico THEN
          --# CALL fgl_dialog_setkeylabel('control-z',NULL)
       ELSE
          DISPLAY "--------" AT 03,68
       END IF
    END IF

  BEFORE FIELD cod_seg_merc
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    IF p_par_con.ies_contab_aen = "S" THEN
       LET p_area[p_ind_arr].cod_seg_merc = 0
       LET p_area[p_ind_arr].cod_cla_uso  = 0
       IF fgl_lastkey() = fgl_keyval("LEFT") THEN
          NEXT FIELD cod_lin_negocio
       ELSE
          NEXT FIELD pct_particip_comp
       END IF
    END IF
    LET p_area[p_ind_arr].seq = p_ind_arr
    DISPLAY p_area[p_ind_arr].seq TO s_area[p_ind1].seq

  BEFORE FIELD cod_cla_uso
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    IF p_par_con.ies_contab_aen = "S" THEN
       LET p_area[p_ind_arr].cod_seg_merc = 0
       LET p_area[p_ind_arr].cod_cla_uso  = 0
       IF fgl_lastkey() = fgl_keyval("LEFT") THEN
          NEXT FIELD cod_lin_negocio
       END IF
    END IF
    LET p_area[p_ind_arr].seq = p_ind_arr
    DISPLAY p_area[p_ind_arr].seq TO s_area[p_ind1].seq

  AFTER FIELD cod_cla_uso
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    IF  p_area[p_ind_arr].cod_cla_uso IS NOT NULL
    AND p_area[p_ind_arr].cod_cla_uso <> " " THEN
       IF p_area[p_ind_arr].cod_area_negocio IS NULL OR
          p_area[p_ind_arr].cod_area_negocio = " " THEN
          ERROR "Informe codigo area de negocio"
          NEXT FIELD cod_area_negocio
       END IF
       IF p_area[p_ind_arr].cod_lin_negocio IS NULL  OR
          p_area[p_ind_arr].cod_lin_negocio = " " THEN
          ERROR "Informe codigo linha de negocio"
          NEXT FIELD cod_lin_negocio
       END IF
       IF p_area[p_ind_arr].cod_seg_merc IS NULL  OR
          p_area[p_ind_arr].cod_seg_merc = " " THEN
          ERROR "Informe codigo segmento de mercado"
          NEXT FIELD cod_seg_merc
       END IF
       IF sup029_verifica_linha_prod() = FALSE THEN
          ERROR "Linha de Produto nao cadastrada"
          NEXT FIELD cod_area_negocio
       ELSE
          IF (p_par_con.area_livre[9,9] = 1 OR
              p_par_con.area_livre[9,9] = 2 OR
              p_par_con.area_livre[9,9] = 3 OR
              p_par_con.area_livre[9,9] = 4) AND
              m_ies_aen_4_niveis = "S" THEN
              IF sup029_pesquisa_linha_prod_cmi() = FALSE THEN
                 ERROR "Relacionamento para Linha de Produto X CMI nao cadastrado no TRB0780."
                 NEXT FIELD cod_area_negocio
              END IF
          END IF
       END IF
    END IF

  BEFORE FIELD pct_particip_comp
    LET p_ind_arr = arr_curr()
    LET p_ind1    = scr_line()
    LET p_area[p_ind_arr].seq = p_ind_arr
    DISPLAY p_area[p_ind_arr].seq TO s_area[p_ind1].seq
#--inicio--OS704186 Antonio#
    IF  m_controla_gao = "S"
    AND m_informa_val_previsto = "S"
    AND sup0772_verifica_oc_aprovada(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.num_oc)
    AND m_orcamento_periodo  = "N"
    AND m_usa_cond_pagto     = "N"
    AND m_atua_somente_desig = "N" THEN
       # Se utiliza o GAO e a OC está aprovada
       # não permitir alteração do valor previsto
       IF FGL_LASTKEY() = FGL_KEYVAL("UP")
       OR fgl_lastkey() = FGL_KEYVAL("LEFT") THEN
          #NEXT FIELD
          EXIT INPUT
       END IF
    END IF
#---fim----OS704186#

  AFTER FIELD pct_particip_comp
    LET p_ind_arr = arr_curr()
    LET p_ind1 = scr_line()
    IF p_area[p_ind_arr].pct_particip_comp IS NOT NULL THEN
       LET p_total = p_total + p_area[p_ind_arr].pct_particip_comp
       IF p_area[p_ind_arr].pct_particip_comp < 0 THEN
          ERROR "Informe percentual de participacao maior que zero"
          NEXT FIELD pct_particip_comp
       END IF
    END IF
    IF g_ies_conta_item = "S" AND p_area[p_ind_arr].pct_particip_comp <> 100 THEN
       ERROR "Informe participacao 100% para OC de conta unica"
       NEXT FIELD pct_particip_comp
    END IF

  AFTER INPUT
    IF int_flag = 0 THEN
       FOR p_indica = 1 TO 670
          IF p_area[p_indica].num_conta IS NULL
          OR p_area[p_indica].num_conta = " " THEN
             EXIT FOR
          END IF
          IF p_area[p_indica].cod_area_negocio IS NULL AND
             p_area[p_indica].cod_lin_negocio IS NULL AND
             (p_area[p_indica].pct_particip_comp IS NULL OR
              p_area[p_indica].pct_particip_comp = 0) THEN
             INITIALIZE p_area[p_indica].* TO NULL
          END IF
       END FOR
       IF sup029_verifica_percent(p_total) = FALSE THEN
          ERROR "Percentual nao fecha em 100%"
          NEXT FIELD pct_particip_comp
       END IF
       IF sup029_verifica_duplicacao()= FALSE THEN
          ERROR "Area/Linha Negocio duplicadas"
          NEXT FIELD cod_area_negocio
       END IF

       FOR p_ind_arr = 1 TO 670
          IF (p_area[p_ind_arr].num_conta IS NULL OR
              p_area[p_ind_arr].num_conta = " " ) AND
              p_area[p_ind_arr].pct_particip_comp IS NOT NULL THEN
             ERROR "Informe conta contabil"
             NEXT FIELD num_conta
          END IF
          IF p_area[p_ind_arr].num_conta IS NOT NULL
          OR p_area[p_ind_arr].num_conta <> " " THEN
             IF p_area[p_ind_arr].pct_particip_comp IS NULL
             OR p_area[p_ind_arr].pct_particip_comp = " "THEN
                ERROR "Informe Percentual de Participacao"
                NEXT FIELD pct_particip_comp
             END IF
             IF p_area[p_ind_arr].cod_area_negocio IS NULL
             OR p_area[p_ind_arr].cod_area_negocio = " " THEN
                ERROR "Informe codigo area de negocio"
                NEXT FIELD cod_area_negocio
             END IF
             IF p_area[p_ind_arr].cod_lin_negocio IS NULL
             OR p_area[p_ind_arr].cod_lin_negocio = " " THEN
                ERROR "Informe codigo linha de negocio"
                NEXT FIELD cod_lin_negocio
             END IF
             IF p_par_con.ies_contab_aen = "4" THEN
                IF p_area[p_ind_arr].cod_seg_merc IS NULL  OR
                   p_area[p_ind_arr].cod_seg_merc = " " THEN
                   ERROR "Informe codigo segmento de mercado"
                   NEXT FIELD cod_seg_merc
                END IF
                IF p_area[p_ind_arr].cod_cla_uso IS NULL  OR
                   p_area[p_ind_arr].cod_cla_uso = " " THEN
                   ERROR "Informe codigo classe de uso"
                   NEXT FIELD cod_cla_uso
                END IF
                IF sup029_verifica_linha_prod() = FALSE THEN
                   ERROR "Linha de Produto nao cadastrada"
                   NEXT FIELD cod_area_negocio
                ELSE
                   IF (p_par_con.area_livre[9,9] = 1 OR
                       p_par_con.area_livre[9,9] = 2 OR
                       p_par_con.area_livre[9,9] = 3 OR
                       p_par_con.area_livre[9,9] = 4) AND
                       m_ies_aen_4_niveis = "S" THEN
                       IF sup029_pesquisa_linha_prod_cmi() = FALSE THEN
                          ERROR "Relacionamento para Linha de Produto X CMI nao cadastrado no TRB0780."
                          NEXT FIELD cod_area_negocio
                       END IF
                   END IF
                END IF
             ELSE
                IF p_par_con.ies_contab_aen = "S" THEN
                   IF sup029_verifica_area_negocio() = FALSE THEN
                      ERROR "Area de negocio nao cadastrada"
                      NEXT FIELD cod_area_negocio
                   END IF
                   IF sup029_verifica_linha_negocio() = FALSE THEN
                      ERROR "Linha de negocio nao cadastrada"
                      NEXT FIELD cod_lin_negocio
                   END IF
                   IF sup029_verifica_area_linha_negocio() = FALSE THEN
                      ERROR "Relacionamento Area/Linha de negocio nao cadastrado"
                      NEXT FIELD cod_area_negocio
                   END IF
                END IF
             END IF
          END IF
       END FOR
    END IF

  ON KEY (f1, control-w)
     #lds IF NOT LOG_logix_versao5() THEN
     #lds CONTINUE INPUT
     #lds END IF
    LET p_ind_arr = arr_curr()
    LET p_ind1 = scr_line()
    CALL sup029_help()

  ON KEY (control-z, f4)
    LET p_ind_arr = arr_curr()
    LET p_ind1 = scr_line()
    CALL sup029_popup()
#--inicio--OS704186 Antonio#
  ON KEY (DELETE, control-e)
     IF  m_controla_gao = "S"
     AND m_informa_val_previsto = "S"
     AND sup0772_verifica_oc_aprovada(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.num_oc)
     AND m_orcamento_periodo  = "N"
     AND m_usa_cond_pagto     = "N"
     AND m_atua_somente_desig = "N" THEN
        # Se utiliza o GAO e a OC está aprovada
        # não permitir exclusão da linha
        CALL log0030_mensagem("Esta O.C. está aprovada. Exclusão de Conta/AEN não permitida.","exclamation")
        CONTINUE INPUT
     ELSE
        LET l_arr_curr = ARR_CURR()
        FOR l_aux = l_arr_curr TO 499
           LET p_area[l_aux].* = p_area[l_aux + 1].*
        END FOR
        INITIALIZE p_area[500].* TO NULL
        DISPLAY p_area[p_ind_arr].* TO s_area[1].*
     END IF
#---fim----OS704186      #
  END INPUT
  LET p_ind_arr = arr_curr()
  LET p_ind1 = scr_line()

  IF NOT g_ies_grafico THEN
     DISPLAY "--------" AT 3,68
  END IF

  CURRENT WINDOW IS w_sup02901

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup02901
  IF int_flag = 0 THEN
     IF p_funcao = "MODIFICACAO" THEN
        IF NOT sup029_insere_dest_ord_sup() THEN
           RETURN FALSE
        END IF
     END IF
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
END FUNCTION

#-------------------------------------#
 FUNCTION sup029_verifica_linha_prod()
#-------------------------------------#
  DEFINE l_cod_lin_prod  LIKE linha_prod.cod_lin_prod,
         l_cod_lin_recei LIKE linha_prod.cod_lin_recei

  LET l_cod_lin_prod  = p_area[p_ind_arr].cod_area_negocio
  LET l_cod_lin_recei = p_area[p_ind_arr].cod_lin_negocio

  SELECT cod_lin_prod,
         cod_lin_recei,
         cod_seg_merc,
         cod_cla_uso
    FROM linha_prod
   WHERE linha_prod.cod_lin_prod  = l_cod_lin_prod
     AND linha_prod.cod_lin_recei = l_cod_lin_recei
     AND linha_prod.cod_seg_merc  = p_area[p_ind_arr].cod_seg_merc
     AND linha_prod.cod_cla_uso   = p_area[p_ind_arr].cod_cla_uso
  IF sqlca.sqlcode = 0 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
 END FUNCTION

#-----------------------------------------#
 FUNCTION sup029_pesquisa_linha_prod_cmi()
#-----------------------------------------#
  DEFINE l_indicador SMALLINT

  SELECT * FROM linha_prod_cmi
   WHERE cod_empresa   = p_cod_empresa
     AND cod_lin_prod  = p_area[p_ind_arr].cod_area_negocio
     AND cod_lin_recei = p_area[p_ind_arr].cod_lin_negocio
     AND cod_seg_merc  = p_area[p_ind_arr].cod_seg_merc
     AND cod_cla_uso   = p_area[p_ind_arr].cod_cla_uso

  RETURN (sqlca.sqlcode = 0)
 END FUNCTION

#---------------------------------------#
 FUNCTION sup029_verifica_area_negocio()
#---------------------------------------#
  DEFINE l_cod_area_negocio CHAR(03)

  LET l_cod_area_negocio = p_area[p_ind_arr].cod_area_negocio

  SELECT * FROM area_negocio
    WHERE area_negocio.cod_empresa      = p_cod_empresa
      AND area_negocio.cod_area_negocio = l_cod_area_negocio
  IF sqlca.sqlcode = 0
     THEN RETURN TRUE
     ELSE RETURN FALSE
  END IF
END FUNCTION

#----------------------------------------#
 FUNCTION sup029_verifica_linha_negocio()
#----------------------------------------#
  DEFINE l_cod_lin_negocio   LIKE linha_negocio.cod_lin_negocio

  LET l_cod_lin_negocio = p_area[p_ind_arr].cod_lin_negocio
  SELECT * FROM linha_negocio
     WHERE linha_negocio.cod_empresa     = p_cod_empresa
       AND linha_negocio.cod_lin_negocio = l_cod_lin_negocio
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF
   RETURN TRUE
END FUNCTION

#---------------------------------------------#
 FUNCTION sup029_verifica_area_linha_negocio()
#---------------------------------------------#
 DEFINE l_soma             SMALLINT,
        l_cod_area_negocio LIKE area_lin_negocio.cod_area_negocio,
        l_cod_lin_negocio  LIKE area_lin_negocio.cod_lin_negocio

 LET l_soma = 0

 LET l_cod_area_negocio = p_area[p_ind_arr].cod_area_negocio
 LET l_cod_lin_negocio  = p_area[p_ind_arr].cod_lin_negocio

 SELECT COUNT(*) INTO l_soma
   FROM area_lin_negocio
  WHERE area_lin_negocio.cod_empresa        = p_cod_empresa
    AND area_lin_negocio.cod_area_negocio   = l_cod_area_negocio
    AND area_lin_negocio.cod_lin_negocio    = l_cod_lin_negocio

 IF l_soma > 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#---------------------------------------#
 FUNCTION sup029_busca_dados_prev_cons()
#---------------------------------------#
   DECLARE cl_area CURSOR FOR
    SELECT cod_area_negocio,
           cod_lin_negocio,
           cod_seg_merc,
           cod_cla_uso,
           pct_particip_cons
      FROM prev_cons_area
     WHERE prev_cons_area.cod_empresa = p_cod_empresa
       AND prev_cons_area.cod_item    = gr_dados_tela_com.cod_item
     ORDER BY prev_cons_area.cod_area_negocio,
              prev_cons_area.cod_lin_negocio,
              prev_cons_area.cod_seg_merc,
              prev_cons_area.cod_cla_uso
    LET p_ind_arr = 1
    FOREACH cl_area INTO p_area[p_ind_arr].cod_area_negocio,
                         p_area[p_ind_arr].cod_lin_negocio,
                         p_area[p_ind_arr].cod_seg_merc,
                         p_area[p_ind_arr].cod_cla_uso,
                         p_area[p_ind_arr].pct_particip_comp
      LET p_area[p_ind_arr].seq = p_ind_arr

      IF p_par_con.ies_contab_aen <> "4" THEN
         LET p_area[p_ind_arr].cod_seg_merc = NULL
         LET p_area[p_ind_arr].cod_cla_uso = NULL
      END IF

      SELECT item_sup.num_conta INTO p_area[p_ind_arr].num_conta
        FROM item_sup
       WHERE item_sup.cod_empresa = p_cod_empresa AND
             item_sup.cod_item = gr_dados_tela_com.cod_item
      IF sqlca.sqlcode <> 0 THEN
         INITIALIZE p_area[p_ind_arr].num_conta TO NULL
      ELSE
         CALL con088_verifica_cod_conta(p_cod_empresa,
                                        p_area[p_ind_arr].num_conta,
                                        "S", TODAY)
              RETURNING p_plano_contas.*, p_status

         IF NOT p_status THEN
            IF p_plano_contas.den_conta IS NOT NULL AND p_plano_contas.den_conta <> " " THEN
               CALL log0030_mensagem(p_plano_contas.den_conta, "exclamation")
            END IF
         END IF

         IF p_plano_contas.ies_titulo <> "N" THEN
            LET  p_area[p_ind_arr].den_conta = NULL
         ELSE
            IF p_status = FALSE THEN
               LET  p_area[p_ind_arr].den_conta = NULL
            ELSE
               LET  p_area[p_ind_arr].den_conta = p_plano_contas.den_conta
            END IF
         END IF
      END IF
      LET p_ind_arr = p_ind_arr + 1
      IF p_ind_arr > 50 THEN
         EXIT FOREACH
      END IF
    END FOREACH

 END FUNCTION

#----------------------------------#
 FUNCTION sup029_busca_dados_item()
#----------------------------------#

    IF find4GLFunction('supy95_verifica_cliente_310') THEN
       IF supy95_verifica_cliente_310() THEN
          IF m_busca_aen_unidade_funcional = 'S' THEN
             IF gr_dados_tela_com.cod_uni_funcio IS NOT NULL AND
                gr_dados_tela_com.cod_uni_funcio <> ' ' THEN
                CALL supy95_busca_aen(p_cod_empresa,
                                       gr_dados_tela_com.cod_item,
                                       gr_dados_tela_com.cod_uni_funcio)
                   RETURNING p_status, p_area[p_ind_arr].cod_area_negocio, p_area[p_ind_arr].cod_lin_negocio, p_area[p_ind_arr].cod_seg_merc, p_area[p_ind_arr].cod_cla_uso
                IF p_status = FALSE THEN #caso nao encontre a parametrização faz o processo padrão
                   IF p_ind_arr = 1 THEN
                      SELECT cod_lin_prod,
                             cod_lin_recei,
                             cod_seg_merc,
                             cod_cla_uso
                        INTO p_area[p_ind_arr].cod_area_negocio,
                             p_area[p_ind_arr].cod_lin_negocio,
                             p_area[p_ind_arr].cod_seg_merc,
                             p_area[p_ind_arr].cod_cla_uso
                        FROM item
                       WHERE item.cod_empresa = p_cod_empresa AND
                             item.cod_item = gr_dados_tela_com.cod_item
                          IF sqlca.sqlcode <> 0 THEN
                             LET p_area[p_ind_arr].cod_area_negocio = NULL
                             LET p_area[p_ind_arr].cod_lin_negocio  = NULL
                             LET p_area[p_ind_arr].cod_seg_merc     = NULL
                             LET p_area[p_ind_arr].cod_cla_uso      = NULL
                          END IF

                      IF p_par_con.ies_contab_aen <> "4" THEN
                         LET p_area[p_ind_arr].cod_seg_merc     = NULL
                         LET p_area[p_ind_arr].cod_cla_uso      = NULL
                      END IF
                   END IF
                END IF
             END IF
          END IF
       END IF
    ELSE #caso nao encontre o EPL faz o processo padrão
       IF p_ind_arr = 1 THEN
          SELECT cod_lin_prod,
                 cod_lin_recei,
                 cod_seg_merc,
                 cod_cla_uso
            INTO p_area[p_ind_arr].cod_area_negocio,
                 p_area[p_ind_arr].cod_lin_negocio,
                 p_area[p_ind_arr].cod_seg_merc,
                 p_area[p_ind_arr].cod_cla_uso
            FROM item
           WHERE item.cod_empresa = p_cod_empresa AND
                 item.cod_item = gr_dados_tela_com.cod_item
              IF sqlca.sqlcode <> 0 THEN
                 LET p_area[p_ind_arr].cod_area_negocio = NULL
                 LET p_area[p_ind_arr].cod_lin_negocio  = NULL
                 LET p_area[p_ind_arr].cod_seg_merc     = NULL
                 LET p_area[p_ind_arr].cod_cla_uso      = NULL
              END IF

          IF p_par_con.ies_contab_aen <> "4" THEN
             LET p_area[p_ind_arr].cod_seg_merc     = NULL
             LET p_area[p_ind_arr].cod_cla_uso      = NULL
          END IF
       END IF
    END IF

    IF p_ind_arr = 1 THEN
       SELECT item_sup.num_conta INTO p_area[p_ind_arr].num_conta
         FROM item_sup
        WHERE item_sup.cod_empresa = p_cod_empresa AND
              item_sup.cod_item = gr_dados_tela_com.cod_item
       IF sqlca.sqlcode <> 0 THEN
          LET p_area[p_ind_arr].num_conta = NULL
       ELSE
          CALL con088_verifica_cod_conta(p_cod_empresa,
                                         p_area[p_ind_arr].num_conta,
                                         "S", TODAY)
                                         RETURNING p_plano_contas.*, p_status
          IF NOT p_status THEN
             IF p_plano_contas.den_conta IS NOT NULL AND p_plano_contas.den_conta <> " " THEN
                CALL log0030_mensagem(p_plano_contas.den_conta, "exclamation")
             END IF
          END IF
       END IF

       IF p_plano_contas.ies_titulo <> "N" THEN
          LET  p_area[p_ind_arr].den_conta = NULL
       ELSE
         IF p_status = FALSE THEN
            LET  p_area[p_ind_arr].den_conta = NULL
         ELSE
            LET  p_area[p_ind_arr].den_conta = p_plano_contas.den_conta
         END IF
       END IF
       LET p_area[p_ind_arr].pct_particip_comp = 100
    END IF

END FUNCTION

#-------------------------------------#
 FUNCTION sup029_insere_dest_ord_sup()
#-------------------------------------#
  DEFINE p_soma SMALLINT

  LET p_soma = 0
  SELECT COUNT(*) INTO p_soma FROM dest_ordem_sup
   WHERE cod_empresa = p_cod_empresa
     AND num_oc      = gr_dados_tela_com.num_oc
  IF p_soma > 0 THEN
     WHENEVER ERROR CONTINUE
     DELETE FROM dest_ordem_sup
       WHERE cod_empresa = p_cod_empresa
         AND num_oc      = gr_dados_tela_com.num_oc
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DELECAO","DEST_ORDEM_SUP")
        RETURN FALSE
     END IF

     IF p_par_con.ies_contab_aen = "4" THEN
        WHENEVER ERROR CONTINUE
        DELETE FROM dest_ordem_sup4
         WHERE cod_empresa = p_cod_empresa
           AND num_oc      = gr_dados_tela_com.num_oc
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("DELECAO","DEST_ORDEM_SUP4")
           RETURN FALSE
        END IF
     END IF
  END IF

  FOR p_ind1 = 1 TO 50
     IF gr_dados_tela_com.cod_uni_funcio IS NOT NULL THEN
        LET p_dest_ordem_sup.cod_secao_receb = gr_dados_tela_com.cod_uni_funcio
     ELSE
        LET p_dest_ordem_sup.cod_secao_receb = " "
     END IF
     LET p_dest_ordem_sup.qtd_particip_comp =
        (p_ordem_sup.qtd_solic * p_area[p_ind1].pct_particip_comp) / 100
     IF  p_area[p_ind1].cod_area_negocio IS NOT NULL
     AND p_area[p_ind1].num_conta IS NOT NULL THEN
        IF log0150_verifica_se_tabela_existe("sup_part_item_aen") THEN #OS528621
           WHENEVER ERROR CONTINUE
             SELECT UNIQUE sup_part_item_aen.item
               FROM sup_part_item_aen
              WHERE sup_part_item_aen.empresa = gr_dados_tela_com.cod_empresa
                AND sup_part_item_aen.item    = gr_dados_tela_com.cod_item
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              WHENEVER ERROR CONTINUE
                INSERT INTO dest_ordem_sup(cod_empresa,
                                           num_oc,
                                           cod_area_negocio,
                                           cod_lin_negocio,
                                           pct_particip_comp,
                                           num_conta_deb_desp,
                                           cod_secao_receb,
                                           qtd_particip_comp,
                                           num_docum)
                VALUES (p_cod_empresa,
                        gr_dados_tela_com.num_oc,
                        p_area[p_ind1].cod_area_negocio,
                        p_area[p_ind1].cod_lin_negocio,
                        p_area[p_ind1].pct_particip_comp,
                        p_area[p_ind1].num_conta ,
                        p_dest_ordem_sup.cod_secao_receb,
                        p_dest_ordem_sup.qtd_particip_comp,
                        " ")
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP")
                 RETURN FALSE
              END IF
           ELSE
              IF  ma_secao_recebimento[p_ind1] IS NOT NULL
              AND ma_secao_recebimento[p_ind1] <> " " THEN
                 WHENEVER ERROR CONTINUE
                   INSERT INTO dest_ordem_sup(cod_empresa,
                                              num_oc,
                                              cod_area_negocio,
                                              cod_lin_negocio,
                                              pct_particip_comp,
                                              num_conta_deb_desp,
                                              cod_secao_receb,
                                              qtd_particip_comp,
                                              num_docum)
                   VALUES (p_cod_empresa,
                           gr_dados_tela_com.num_oc,
                           p_area[p_ind1].cod_area_negocio,
                           p_area[p_ind1].cod_lin_negocio,
                           p_area[p_ind1].pct_particip_comp,
                           p_area[p_ind1].num_conta ,
                           ma_secao_recebimento[p_ind1],
                           p_dest_ordem_sup.qtd_particip_comp,
                           " ")
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP")
                    RETURN FALSE
                 END IF
              ELSE
                 WHENEVER ERROR CONTINUE
                   INSERT INTO dest_ordem_sup(cod_empresa,
                                              num_oc,
                                              cod_area_negocio,
                                              cod_lin_negocio,
                                              pct_particip_comp,
                                              num_conta_deb_desp,
                                              cod_secao_receb,
                                              qtd_particip_comp,
                                              num_docum)
                   VALUES (p_cod_empresa,
                           gr_dados_tela_com.num_oc,
                           p_area[p_ind1].cod_area_negocio,
                           p_area[p_ind1].cod_lin_negocio,
                           p_area[p_ind1].pct_particip_comp,
                           p_area[p_ind1].num_conta ,
                           p_dest_ordem_sup.cod_secao_receb,
                           p_dest_ordem_sup.qtd_particip_comp,
                           " ")
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP")
                    RETURN FALSE
                 END IF
              END IF
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
             INSERT INTO dest_ordem_sup(cod_empresa,
                                        num_oc,
                                        cod_area_negocio,
                                        cod_lin_negocio,
                                        pct_particip_comp,
                                        num_conta_deb_desp,
                                        cod_secao_receb,
                                        qtd_particip_comp,
                                        num_docum)
             VALUES (p_cod_empresa,
                     gr_dados_tela_com.num_oc,
                     p_area[p_ind1].cod_area_negocio,
                     p_area[p_ind1].cod_lin_negocio,
                     p_area[p_ind1].pct_particip_comp,
                     p_area[p_ind1].num_conta ,
                     p_dest_ordem_sup.cod_secao_receb,
                     p_dest_ordem_sup.qtd_particip_comp,
                     " ")
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP")
              RETURN FALSE
           END IF
        END IF

        IF p_par_con.ies_contab_aen = "4" THEN
           IF log0150_verifica_se_tabela_existe("sup_part_item_aen") THEN #OS528621
              WHENEVER ERROR CONTINUE
                SELECT UNIQUE sup_part_item_aen.item
                  FROM sup_part_item_aen
                 WHERE sup_part_item_aen.empresa = gr_dados_tela_com.cod_empresa
                   AND sup_part_item_aen.item    = gr_dados_tela_com.cod_item
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 WHENEVER ERROR CONTINUE
                   INSERT INTO dest_ordem_sup4(cod_empresa,
                                               num_oc,
                                               cod_area_negocio,
                                               cod_lin_negocio,
                                               pct_particip_comp,
                                               num_conta_deb_desp,
                                               cod_secao_receb,
                                               qtd_particip_comp,
                                               num_docum,
                                               cod_seg_merc,
                                               cod_cla_uso)
                   VALUES (p_cod_empresa,
                           gr_dados_tela_com.num_oc,
                           p_area[p_ind1].cod_area_negocio,
                           p_area[p_ind1].cod_lin_negocio,
                           p_area[p_ind1].pct_particip_comp,
                           p_area[p_ind1].num_conta ,
                           p_dest_ordem_sup.cod_secao_receb,
                           p_dest_ordem_sup.qtd_particip_comp,
                           " ",
                           p_area[p_ind1].cod_seg_merc,
                           p_area[p_ind1].cod_cla_uso)
                 WHENEVER ERROR STOP
                 IF sqlca.sqlcode <> 0 THEN
                    CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP4")
                    RETURN FALSE
                 END IF
              ELSE
                 IF  ma_secao_recebimento[p_ind1] IS NOT NULL
                 AND ma_secao_recebimento[p_ind1] <> " " THEN
                    WHENEVER ERROR CONTINUE
                      INSERT INTO dest_ordem_sup4(cod_empresa,
                                                  num_oc,
                                                  cod_area_negocio,
                                                  cod_lin_negocio,
                                                  pct_particip_comp,
                                                  num_conta_deb_desp,
                                                  cod_secao_receb,
                                                  qtd_particip_comp,
                                                  num_docum,
                                                  cod_seg_merc,
                                                  cod_cla_uso)
                      VALUES (p_cod_empresa,
                              gr_dados_tela_com.num_oc,
                              p_area[p_ind1].cod_area_negocio,
                              p_area[p_ind1].cod_lin_negocio,
                              p_area[p_ind1].pct_particip_comp,
                              p_area[p_ind1].num_conta ,
                              ma_secao_recebimento[p_ind1],
                              p_dest_ordem_sup.qtd_particip_comp,
                              " ",
                              p_area[p_ind1].cod_seg_merc,
                              p_area[p_ind1].cod_cla_uso)
                    WHENEVER ERROR STOP
                    IF sqlca.sqlcode <> 0 THEN
                       CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP4")
                       RETURN FALSE
                    END IF
                 ELSE
                    WHENEVER ERROR CONTINUE
                      INSERT INTO dest_ordem_sup4(cod_empresa,
                                                  num_oc,
                                                  cod_area_negocio,
                                                  cod_lin_negocio,
                                                  pct_particip_comp,
                                                  num_conta_deb_desp,
                                                  cod_secao_receb,
                                                  qtd_particip_comp,
                                                  num_docum,
                                                  cod_seg_merc,
                                                  cod_cla_uso)
                      VALUES (p_cod_empresa,
                              gr_dados_tela_com.num_oc,
                              p_area[p_ind1].cod_area_negocio,
                              p_area[p_ind1].cod_lin_negocio,
                              p_area[p_ind1].pct_particip_comp,
                              p_area[p_ind1].num_conta ,
                              p_dest_ordem_sup.cod_secao_receb,
                              p_dest_ordem_sup.qtd_particip_comp,
                              " ",
                              p_area[p_ind1].cod_seg_merc,
                              p_area[p_ind1].cod_cla_uso)
                    WHENEVER ERROR STOP
                    IF sqlca.sqlcode <> 0 THEN
                       CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP4")
                       RETURN FALSE
                    END IF
                 END IF
              END IF
           ELSE
              WHENEVER ERROR CONTINUE
                INSERT INTO dest_ordem_sup4(cod_empresa,
                                            num_oc,
                                            cod_area_negocio,
                                            cod_lin_negocio,
                                            pct_particip_comp,
                                            num_conta_deb_desp,
                                            cod_secao_receb,
                                            qtd_particip_comp,
                                            num_docum,
                                            cod_seg_merc,
                                            cod_cla_uso)
                VALUES (p_cod_empresa,
                        gr_dados_tela_com.num_oc,
                        p_area[p_ind1].cod_area_negocio,
                        p_area[p_ind1].cod_lin_negocio,
                        p_area[p_ind1].pct_particip_comp,
                        p_area[p_ind1].num_conta ,
                        p_dest_ordem_sup.cod_secao_receb,
                        p_dest_ordem_sup.qtd_particip_comp,
                        " ",
                        p_area[p_ind1].cod_seg_merc,
                        p_area[p_ind1].cod_cla_uso)
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("INSERCAO","DEST_ORDEM_SUP4")
                 RETURN FALSE
              END IF
           END IF
        END IF
     ELSE
        EXIT FOR
     END IF
  END FOR
  RETURN TRUE
 END FUNCTION

#-----------------------------------------#
 FUNCTION sup029_insere_estrut_ordem_sup()
#-----------------------------------------#
  DEFINE l_qtd_necessaria LIKE estrut_ordem_sup.qtd_necessaria

  IF p_ies_item_prod_oc = "E" OR
    (p_ies_item_prod_oc = "N" AND p_ies_tip_item = "B") THEN #Rafael - OS293939

     IF p_par_logix.parametros[61,61] = "S" THEN
           IF NOT man7847_cria_temp_estrut(p_ordem_sup.cod_item,
                                           " "," "," "," "," ",TODAY) THEN
              CALL log003_err_sql("SELECAO","ESTRUT_GRADE")
              RETURN FALSE
        END IF
     ELSE
        IF NOT man7840_cria_temp_estrut(p_ordem_sup.cod_item, TODAY) THEN
           CALL log003_err_sql("SELECAO","ESTRUTURA")
           RETURN FALSE
        END IF
     END IF

     DECLARE cq_estrutura CURSOR FOR
      SELECT t_estrut.cod_item_pai,
             t_estrut.cod_item_compon,
             t_estrut.qtd_necessaria,
             t_estrut.pct_refug,
             t_estrut.tmp_ressup,
             t_estrut.tmp_ressup_sobr
        FROM t_estrut
     FOREACH cq_estrutura INTO p_estrutura.*
        LET p_estrut_ordem_sup.cod_empresa    = p_cod_empresa
        LET p_estrut_ordem_sup.num_oc         = p_ordem_sup.num_oc
        LET p_estrut_ordem_sup.cod_item_comp  = p_estrutura.cod_item_compon
        LET p_estrut_ordem_sup.qtd_necessaria = p_estrutura.qtd_necessaria
        IF p_estrutura.pct_refug IS NOT NULL AND
           m_consid_pct_refugo = "S" THEN
           LET p_estrut_ordem_sup.qtd_necessaria = p_estrut_ordem_sup.qtd_necessaria *
                                                   (100 / (100 - p_estrutura.pct_refug))
        END IF

        INITIALIZE l_qtd_necessaria TO NULL
        SELECT qtd_necessaria INTO l_qtd_necessaria
          FROM estrut_ordem_sup
         WHERE cod_empresa   = p_estrut_ordem_sup.cod_empresa
           AND num_oc        = p_estrut_ordem_sup.num_oc
           AND cod_item_comp = p_estrut_ordem_sup.cod_item_comp

        IF sqlca.sqlcode = 0 THEN
           LET p_estrut_ordem_sup.qtd_necessaria =
               p_estrut_ordem_sup.qtd_necessaria + l_qtd_necessaria

           WHENEVER ERROR CONTINUE
           UPDATE estrut_ordem_sup
              SET qtd_necessaria = p_estrut_ordem_sup.qtd_necessaria
            WHERE cod_empresa   = p_estrut_ordem_sup.cod_empresa
              AND num_oc        = p_estrut_ordem_sup.num_oc
              AND cod_item_comp = p_estrut_ordem_sup.cod_item_comp
           WHENEVER ERROR STOP

           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("ATUALIZACAO","ESTRUT_ORDEM_SUP")
              RETURN FALSE
           END IF
        ELSE
           WHENEVER ERROR CONTINUE
           INSERT INTO estrut_ordem_sup VALUES (p_estrut_ordem_sup.*)
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("INCLUSAO","ESTRUT_ORDEM_SUP")
              RETURN FALSE
           END IF
        END IF
     END FOREACH
  END IF
  RETURN TRUE
 END FUNCTION

#----------------------#
 FUNCTION sup029_help()
#----------------------#
  CASE
    WHEN infield(num_oc)            CALL showhelp(117)
    WHEN infield(cod_item)          CALL showhelp(101)
    WHEN infield(ies_situa_oc)      CALL showhelp(102)
    WHEN infield(dat_emis)          CALL showhelp(103)
    WHEN infield(dat_entrega_prev)  CALL showhelp(104)
    WHEN infield(qtd_solic)         CALL showhelp(105)
    WHEN infield(gru_ctr_desp)      CALL showhelp(106)
    WHEN infield(cod_comprador)     CALL showhelp(107)
    WHEN infield(cod_tip_despesa)   CALL showhelp(108)
    WHEN infield(num_conta)         CALL showhelp(109)
    WHEN infield(cod_area_negocio)  CALL showhelp(110)
    WHEN infield(cod_lin_negocio)   CALL showhelp(111)
    WHEN infield(cod_seg_merc)      CALL showhelp(112)
    WHEN infield(cod_cla_uso)       CALL showhelp(113)
    WHEN infield(pct_particip_comp) CALL showhelp(114)
    WHEN infield(cod_uni_funcio)    CALL showhelp(115)
    WHEN infield(pre_unit_oc)       CALL showhelp(118)
    WHEN infield(texto)             CALL showhelp(119)
  END CASE
 END FUNCTION

#------------------------------------------#
 FUNCTION sup029_verifica_cod_tip_despesa()
#------------------------------------------#
  SELECT nom_tip_despesa INTO p_formonly.nom_tip_despesa FROM tipo_despesa
   WHERE tipo_despesa.cod_empresa = p_cod_empresa
     AND tipo_despesa.cod_tip_despesa = gr_dados_tela_com.cod_tip_despesa
   IF sqlca.sqlcode = 0 THEN
      DISPLAY BY NAME p_formonly.nom_tip_despesa
      RETURN TRUE
   ELSE
      INITIALIZE p_formonly.nom_tip_despesa TO NULL
      DISPLAY BY NAME p_formonly.nom_tip_despesa
      RETURN FALSE
   END IF
 END FUNCTION

#---------------------------------------------------#
 FUNCTION sup029_verifica_informacoes_fiscais_item()
#---------------------------------------------------#
 DEFINE l_count_aux         SMALLINT,
        l_status            SMALLINT,
        l_cod_fiscal_compl  LIKE item_sup_compl.cod_fiscal_compl

   SELECT den_gru_ctr_desp
     FROM grupo_ctr_desp
    WHERE grupo_ctr_desp.cod_empresa  = p_cod_empresa
      AND grupo_ctr_desp.gru_ctr_desp = p_item_sup.gru_ctr_desp
   IF SQLCA.sqlcode <> 0 THEN
      RETURN FALSE
   END IF

   SELECT nom_tip_despesa
     FROM tipo_despesa
    WHERE tipo_despesa.cod_empresa    = p_cod_empresa
      AND tipo_despesa.cod_tip_despesa= p_item_sup.cod_tip_despesa
   IF SQLCA.sqlcode <> 0 THEN
      RETURN FALSE
   END IF

   SELECT UNIQUE cod_cla_fisc
     FROM clas_fiscal
    WHERE clas_fiscal.cod_cla_fisc = p_cod_cla_fisc
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF

   IF p_pct_ipi IS NULL THEN
      RETURN FALSE
   END IF

   SELECT count(*) INTO l_count_aux
     FROM clas_fiscal
    WHERE clas_fiscal.cod_cla_fisc = p_cod_cla_fisc
      AND clas_fiscal.pct_ipi      = p_pct_ipi

   IF l_count_aux IS NULL OR l_count_aux = 0 THEN
      RETURN FALSE
   END IF

   IF p_item_sup.ies_tip_incid_ipi IS NULL THEN
      RETURN FALSE
   END IF

   IF p_item_sup.ies_tip_incid_icms IS NULL THEN
      RETURN FALSE
   END IF

   IF p_item_sup.cod_fiscal IS NULL THEN
      RETURN FALSE
   END IF

   INITIALIZE l_status, l_cod_fiscal_compl TO NULL
   SELECT cod_fiscal_compl
     INTO l_cod_fiscal_compl
     FROM item_sup_compl
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = p_item_sup.cod_item
   IF sqlca.sqlcode <> 0 THEN
      LET l_cod_fiscal_compl = 0
   END IF

   CALL sup0686_cod_fiscal_final_existe(p_item_sup.cod_fiscal,
                                        l_cod_fiscal_compl)
                                        RETURNING l_status
   IF l_status = FALSE THEN
      RETURN FALSE
   END IF

   IF l_count_aux IS NULL OR l_count_aux = 0 THEN
      RETURN FALSE
   END IF

   RETURN TRUE
 END FUNCTION

#-----------------------------------#
 FUNCTION sup029_verifica_item_sup()
#-----------------------------------#
  DEFINE l_fat_conver LIKE fat_conver.fat_conver_unid,
         l_ies_ativo  CHAR(01)

  SELECT * INTO p_item_sup.*
    FROM item_sup
   WHERE item_sup.cod_empresa = p_cod_empresa
     AND item_sup.cod_item    = gr_dados_tela_com.cod_item
  IF sqlca.sqlcode <> 0 THEN
     RETURN FALSE
  END IF

  IF p_ies_inf_fisc_item_oc = "N" THEN
     IF NOT sup029_verifica_informacoes_fiscais_item() THEN
        ERROR "Informacoes fiscais do item incompletas. Verificar com setor fiscal."
        RETURN FALSE
     END IF
  END IF

  IF sup0538_existe_unid_compra_item(p_cod_empresa,gr_dados_tela_com.cod_item) THEN
     LET l_fat_conver = sup0538_fat_conver_estoque_compra_item(p_cod_empresa,gr_dados_tela_com.cod_item)
  ELSE
     LET l_fat_conver = 1
  END IF

  LET p_item_sup.qtd_lote_multiplo = p_item_sup.qtd_lote_multiplo / l_fat_conver

  LET l_ies_ativo = NULL

  SELECT tipo_despesa_compl.ies_ativo
    INTO l_ies_ativo
    FROM tipo_despesa_compl
   WHERE tipo_despesa_compl.cod_empresa     = p_cod_empresa
     AND tipo_despesa_compl.cod_tip_despesa = p_item_sup.cod_tip_despesa

  IF sqlca.sqlcode = 0 THEN
     IF l_ies_ativo = "N" THEN
        ERROR " Tipo de Despesa do item nao esta' ativo. "
        RETURN FALSE
     END IF
  END IF

  RETURN TRUE

 END FUNCTION

#--------------------------------------#
 FUNCTION sup029_verifica_data_valida()
#--------------------------------------#
 DEFINE p_semana_sup     RECORD LIKE semana_sup.*,
        p_feriado_sup    RECORD LIKE feriado_sup.*,
        p_ies_dia_semana LIKE semana_sup.ies_dia_semana

 LET p_ies_dia_semana = WEEKDAY(gr_dados_tela_com.dat_entrega_prev)

 SELECT * INTO p_feriado_sup.* FROM feriado_sup
  WHERE feriado_sup.cod_empresa = p_cod_empresa
    AND feriado_sup.dat_ref     = gr_dados_tela_com.dat_entrega_prev

 SELECT * INTO p_semana_sup.* FROM semana_sup
  WHERE semana_sup.cod_empresa    = p_cod_empresa
    AND semana_sup.ies_dia_semana = p_ies_dia_semana
     IF sqlca.sqlcode = 0 THEN
        IF p_semana_sup.ies_situa <> "3"
        THEN IF (p_feriado_sup.ies_situa <> "3")  OR
                (p_feriado_sup.ies_situa IS NULL) THEN
                RETURN TRUE
             END IF
        ELSE IF (p_feriado_sup.ies_situa = "1")   OR
                (p_feriado_sup.ies_situa = "2")   THEN
                RETURN TRUE
             END IF
        END IF
     END IF

 RETURN FALSE

 END FUNCTION

#------------------------#
 FUNCTION sup029_popups()
#------------------------#
  DEFINE p_cod_comprador    LIKE ordem_sup.cod_comprador,
         p_cod_tip_despesa  LIKE ordem_sup.cod_tip_despesa,
         p_gru_ctr_desp     LIKE ordem_sup.gru_ctr_desp,
         l_cod_uni_funcio   LIKE ordem_sup.cod_secao_receb,
         l_cod_item         LIKE ordem_sup.cod_item,
         l_cod_progr        LIKE programador.cod_progr

  INITIALIZE p_cod_tip_despesa,p_cod_comprador,p_gru_ctr_desp,
             l_cod_uni_funcio,l_cod_item,l_cod_progr TO NULL

  CASE
  WHEN infield(ies_situa_oc)
     LET gr_dados_tela_com.ies_situa_oc = log0830_list_box(10,25,
      "A {Aberto},P {Planejada},D {Condicional},S {Suspensa},T {Tomada de preco} ")
     DISPLAY gr_dados_tela_com.ies_situa_oc TO ies_situa_oc
  WHEN infield(cod_item)
     
     #ivo
     {IF p_ies_sup0301 = "N" THEN
        LET l_cod_item = sup702_popup_item() #min071_popup_item(p_cod_empresa)
     ELSE
        LET l_cod_item = sup0301_consulta_item()
     END IF}
     LET l_cod_item = min071_popup_item(p_cod_empresa)
     #até aqui
     
     IF l_cod_item IS NOT NULL THEN
        LET gr_dados_tela_com.cod_item = l_cod_item
        CURRENT WINDOW IS w_sup02901
        DISPLAY BY NAME gr_dados_tela_com.cod_item
     END IF
  WHEN infield(gru_ctr_desp)
     LET p_gru_ctr_desp = sup100_popup_gru_ctr_desp(p_cod_empresa)
     IF p_gru_ctr_desp IS NOT NULL  THEN
        CURRENT WINDOW IS w_sup02906
        LET gr_dados_tela_com.gru_ctr_desp = p_gru_ctr_desp
        DISPLAY BY NAME gr_dados_tela_com.gru_ctr_desp
     END IF
  WHEN infield(cod_tip_despesa)
     LET p_cod_tip_despesa = cap058_popup_tipo_despesa()
     IF p_cod_tip_despesa IS NOT NULL THEN
        CURRENT WINDOW IS w_sup02906
        LET gr_dados_tela_com.cod_tip_despesa = p_cod_tip_despesa
        DISPLAY BY NAME gr_dados_tela_com.cod_tip_despesa
     END IF
     LET p_status = 0
  WHEN infield(cod_comprador)
     LET p_cod_comprador = sup104_popup_comprador(p_cod_empresa)
     IF p_cod_comprador IS NOT NULL  THEN
        CURRENT WINDOW IS w_sup02901
        LET gr_dados_tela_com.cod_comprador = p_cod_comprador
        DISPLAY BY NAME gr_dados_tela_com.cod_comprador
     END IF
  WHEN infield(cod_progr)
     LET l_cod_progr = sup103_popup_programador(p_cod_empresa)
     IF l_cod_progr IS NOT NULL  THEN
        CURRENT WINDOW IS w_sup02901
        LET gr_dados_tela_com.cod_progr = l_cod_progr
        DISPLAY BY NAME gr_dados_tela_com.cod_progr
     END IF
  WHEN infield(cod_uni_funcio)
     LET l_cod_uni_funcio = rhu053_popup_uni_funcional(gr_dados_tela_com.cod_empresa)
     CURRENT WINDOW IS w_sup02901
     IF l_cod_uni_funcio IS NOT NULL THEN
        LET gr_dados_tela_com.cod_uni_funcio = l_cod_uni_funcio
        DISPLAY BY NAME gr_dados_tela_com.cod_uni_funcio
     END IF
  END CASE

  CALL log006_exibe_teclas("01 02 03 07",p_versao)
  CURRENT WINDOW IS w_sup02901
  LET int_flag = 0
 END FUNCTION

#-----------------------------------#
 FUNCTION sup029_inicializa_campos()
#-----------------------------------#
  LET gr_dados_tela_com.cod_empresa      = p_cod_empresa
  LET gr_dados_tela_com.dat_emis         = TODAY
  IF p_ies_oc_planejada = "S" THEN
     LET gr_dados_tela_com.ies_situa_oc  = "P"
  ELSE
     LET gr_dados_tela_com.ies_situa_oc  = "A"
  END IF
  LET gr_dados_tela_com.ies_origem_oc    = "C"
  LET gr_dados_tela_com.cod_progr        = mr_usuario.cod_progr
  LET p_ordem_sup.num_versao        = 1
  LET p_ordem_sup.ies_versao_atual  = "S"
  LET p_ordem_sup.ies_item_estoq    = "S"
  LET p_ordem_sup.ies_imobilizado   = "N"
  LET p_ordem_sup.ies_insp_recebto  = "4"
  LET p_ordem_sup.ies_tipo_inspecao = NULL
  LET p_ordem_sup.num_pedido        = 0
  LET p_ordem_sup.num_versao_pedido = 0
  LET p_ordem_sup.fat_conver_unid   = 1
  LET p_ordem_sup.qtd_recebida      = 0
  LET p_ordem_sup.pre_unit_oc       = 0
  LET p_ordem_sup.dat_ref_cotacao   = NULL
  LET p_ordem_sup.ies_tip_cotacao   = NULL
  LET p_ordem_sup.cod_moeda         = 0
  LET p_ordem_sup.cod_fornecedor    = " "
  LET p_ordem_sup.cnd_pgto          = 0
  LET p_ordem_sup.cod_mod_embar     = 0
  LET p_ordem_sup.num_docum         = "0"
  LET p_ordem_sup.pct_ipi           = 0
  LET p_ordem_sup.cod_secao_receb   = NULL
  LET p_ordem_sup.pct_aceite_dif    = 0
  LET p_ordem_sup.ies_tip_entrega   = "D"
  LET p_ordem_sup.ies_liquida_oc    = "2"
  INITIALIZE mr_tela.pre_unit_oc TO NULL

  CALL sup029_verifica_programador() RETURNING p_status
 END FUNCTION

#-------------------------------------#
 FUNCTION sup029_move_campos(l_funcao)
#-------------------------------------#
  DEFINE l_funcao     CHAR(30),
         l_fat_conver LIKE fat_conver.fat_conver_unid

  IF l_funcao = "INCLUSAO" THEN
     IF sup0538_existe_unid_compra_item(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.cod_item) THEN
        LET l_fat_conver = sup0538_fat_conver_estoque_compra_item(gr_dados_tela_com.cod_empresa,gr_dados_tela_com.cod_item)
     ELSE
        LET l_fat_conver = 1
     END IF

     LET p_ordem_sup.cod_empresa        = gr_dados_tela_com.cod_empresa
     LET p_ordem_sup.num_oc             = gr_dados_tela_com.num_oc
     LET p_ordem_sup.cod_item           = gr_dados_tela_com.cod_item
     LET p_ordem_sup.ies_situa_oc       = gr_dados_tela_com.ies_situa_oc
     LET p_ordem_sup.ies_origem_oc      = gr_dados_tela_com.ies_origem_oc
     LET p_ordem_sup.dat_emis           = gr_dados_tela_com.dat_emis
     LET p_ordem_sup.dat_entrega_prev   = gr_dados_tela_com.dat_entrega_prev
     LET p_ordem_sup.qtd_solic          = gr_dados_tela_com.qtd_solic * l_fat_conver
     LET p_ordem_sup.gru_ctr_desp       = gr_dados_tela_com.gru_ctr_desp
     LET p_ordem_sup.cod_progr          = gr_dados_tela_com.cod_progr
     LET p_ordem_sup.cod_unid_med       = p_cod_unid_med
     LET p_ordem_sup.ies_tip_incid_ipi  = p_item_sup.ies_tip_incid_ipi
     LET p_ordem_sup.ies_tip_incid_icms = p_item_sup.ies_tip_incid_icms
     LET p_ordem_sup.cod_fiscal         = p_item_sup.cod_fiscal
     LET p_ordem_sup.cod_tip_despesa    = gr_dados_tela_com.cod_tip_despesa
     LET p_ordem_sup.dat_abertura_oc    = gr_dados_tela_com.dat_abertura_oc
     LET p_ordem_sup.num_oc_origem      = gr_dados_tela_com.num_oc_origem
     LET p_ordem_sup.qtd_origem         = gr_dados_tela_com.qtd_solic * l_fat_conver
     LET p_ordem_sup.dat_origem         = gr_dados_tela_com.dat_origem
     LET p_ordem_sup.num_oc_origem      = p_ordem_sup.num_oc
     LET p_ordem_sup.pct_ipi            = p_pct_ipi
     LET p_ordem_sup.cod_secao_receb    = p_cod_local_estoq
  END IF

  LET p_ordem_sup.cod_comprador = gr_dados_tela_com.cod_comprador

  IF m_ies_ajuste_data_oc = "S" AND p_ordem_sup.ies_situa_oc = "P" THEN
     LET p_ordem_sup.dat_emis         = TODAY
     LET p_ordem_sup.dat_abertura_oc  = p_ordem_sup.dat_entrega_prev - p_lead_time UNITS DAY
     LET p_ordem_sup.dat_origem       = p_ordem_sup.dat_entrega_prev
     LET gr_dados_tela_com.dat_emis        = p_ordem_sup.dat_emis
     LET gr_dados_tela_com.dat_abertura_oc = p_ordem_sup.dat_abertura_oc
     LET gr_dados_tela_com.dat_origem      = p_ordem_sup.dat_origem
  END IF

  IF l_funcao = "INCLUSAO" THEN
     INITIALIZE p_item_sup_compl.* TO NULL
     SELECT * INTO p_item_sup_compl.*
       FROM item_sup_compl
      WHERE cod_empresa = gr_dados_tela_com.cod_empresa
        AND cod_item    = gr_dados_tela_com.cod_item

     LET p_ordem_sup_compl.cod_empresa  = gr_dados_tela_com.cod_empresa
     LET p_ordem_sup_compl.num_oc       = gr_dados_tela_com.num_oc
     LET p_ordem_sup_compl.val_item_moeda = 0
     IF p_item_sup_compl.cod_fiscal_compl IS NULL THEN
        LET p_ordem_sup_compl.cod_fiscal_compl = 0
     ELSE
        LET p_ordem_sup_compl.cod_fiscal_compl = p_item_sup_compl.cod_fiscal_compl
     END IF
     IF sup0290_sistema_argentino() THEN
        LET p_ordem_sup_compl.possui_remito = "S"
        LET p_ordem_sup_compl.tip_compra    = "S"
     END IF

     LET p_ordem_sup.num_oc_origem = p_ordem_sup.num_oc
     LET p_ordem_sup.num_docum     = "0"
  END IF
 END FUNCTION

#--------------------------------------#
 FUNCTION sup029_prepara_prog_entrega()
#--------------------------------------#
  LET p_prog_ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
  LET p_prog_ordem_sup.num_oc           = p_ordem_sup.num_oc
  LET p_prog_ordem_sup.num_versao       = 1
  LET p_prog_ordem_sup.num_prog_entrega = 1

  IF p_ordem_sup.ies_situa_oc = "P" THEN
     LET p_prog_ordem_sup.ies_situa_prog = "P"
  ELSE
     LET p_prog_ordem_sup.ies_situa_prog = "F"
  END IF

  LET p_prog_ordem_sup.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
  LET p_prog_ordem_sup.qtd_solic        = p_ordem_sup.qtd_solic
  LET p_prog_ordem_sup.qtd_recebida     = 0
  LET p_prog_ordem_sup.dat_origem       = p_ordem_sup.dat_entrega_prev
  LET p_prog_ordem_sup.dat_palpite      = NULL
  LET p_prog_ordem_sup.qtd_em_transito  = NULL
  LET p_prog_ordem_sup.tex_observacao   = NULL
 END FUNCTION

#-----------------------------#
 FUNCTION sup029_exibe_dados()
#-----------------------------#
  DEFINE l_fat_conver LIKE fat_conver.fat_conver_unid,
         l_msg        CHAR (30)

  IF p_ordem_sup.cod_empresa <> p_cod_empresa THEN
     LET p_cod_empresa = p_ordem_sup.cod_empresa
     CALL sup0290_leitura_parametros()
  END IF

  IF sup0538_existe_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item) THEN
     LET l_fat_conver = sup0538_fat_conver_estoque_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item)
  ELSE
     LET l_fat_conver = 1
  END IF

  LET gr_dados_tela_com.cod_empresa      = p_ordem_sup.cod_empresa
  LET gr_dados_tela_com.num_oc           = p_ordem_sup.num_oc
  LET gr_dados_tela_com.cod_item         = p_ordem_sup.cod_item
  IF sup0538_existe_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item) THEN
     LET p_formonly.cod_unid_med    = sup0538_unid_compra_item(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item)
  ELSE
     LET p_formonly.cod_unid_med    = p_ordem_sup.cod_unid_med
  END IF
  LET gr_dados_tela_com.num_docum        = p_ordem_sup.num_docum
  LET gr_dados_tela_com.ies_situa_oc     = p_ordem_sup.ies_situa_oc
  LET gr_dados_tela_com.ies_origem_oc    = p_ordem_sup.ies_origem_oc
  LET gr_dados_tela_com.dat_emis         = p_ordem_sup.dat_emis
  LET gr_dados_tela_com.dat_entrega_prev = p_ordem_sup.dat_entrega_prev
  LET gr_dados_tela_com.qtd_solic        = p_ordem_sup.qtd_solic / l_fat_conver
  LET gr_dados_tela_com.gru_ctr_desp     = p_ordem_sup.gru_ctr_desp
  LET gr_dados_tela_com.cod_progr        = p_ordem_sup.cod_progr
  LET gr_dados_tela_com.cod_comprador    = p_ordem_sup.cod_comprador
  LET gr_dados_tela_com.cod_tip_despesa  = p_ordem_sup.cod_tip_despesa
  LET gr_dados_tela_com.dat_abertura_oc  = p_ordem_sup.dat_abertura_oc
  LET gr_dados_tela_com.num_oc_origem    = p_ordem_sup.num_oc_origem
  LET gr_dados_tela_com.qtd_origem       = p_ordem_sup.qtd_origem / l_fat_conver
  LET gr_dados_tela_com.dat_origem       = p_ordem_sup.dat_origem

  IF m_informa_val_previsto = "S" THEN
     LET mr_tela.pre_unit_oc              = sup0290_busca_valor_previsto(gr_dados_tela_com.num_oc)
     DISPLAY BY NAME mr_tela.pre_unit_oc
  END IF

  #IF p_ies_uni_funcio = "N" THEN
     LET gr_dados_tela_com.cod_uni_funcio = " "
  #ELSE
     DECLARE cq_secao CURSOR FOR
      SELECT cod_secao_receb
        FROM dest_ordem_sup
       WHERE cod_empresa = gr_dados_tela_com.cod_empresa
         AND num_oc      = gr_dados_tela_com.num_oc
     OPEN cq_secao
     FETCH cq_secao INTO gr_dados_tela_com.cod_uni_funcio
     CLOSE cq_secao
  #END IF

  DISPLAY BY NAME gr_dados_tela_com.cod_empresa,
                  gr_dados_tela_com.num_oc,
                  gr_dados_tela_com.ies_situa_oc,
                  gr_dados_tela_com.cod_item,
                  gr_dados_tela_com.qtd_solic,
                  gr_dados_tela_com.cod_uni_funcio,
                  gr_dados_tela_com.dat_entrega_prev,
                  gr_dados_tela_com.cod_progr,
                  gr_dados_tela_com.cod_comprador

  IF NOT g_ies_genero THEN
     DISPLAY "            " AT 11,30
  ELSE
     CALL log4050_altera_atributo("emerg","text","")
  END IF

  IF p_ordem_sup.num_pedido <> 0 THEN
     IF NOT g_ies_genero THEN
        DISPLAY "                   " AT 05,26
        DISPLAY "Nr. Pedido: ",p_ordem_sup.num_pedido," " AT 05,26 ATTRIBUTE(REVERSE)
     ELSE
        LET l_msg = "Nr. Pedido: ",p_ordem_sup.num_pedido CLIPPED
        CALL log4050_altera_atributo("numped","text","")
        CALL log4050_altera_atributo("numped","text",l_msg)
     END IF
  ELSE
     IF NOT g_ies_genero THEN
        DISPLAY "                   " AT 05,26
     ELSE
        CALL log4050_altera_atributo("numped","text","")
     END IF
  END IF

  CASE gr_dados_tela_com.ies_situa_oc
  WHEN  "A" LET p_tex_situa_oc = "EM ABERTO"
  WHEN  "R" LET p_tex_situa_oc = "REALIZADA"
  WHEN  "C" LET p_tex_situa_oc = "CANCELADA"
  WHEN  "L" LET p_tex_situa_oc = "LIQUIDADA"
  WHEN  "P" LET p_tex_situa_oc = "PLANEJADA"
  WHEN  "D" LET p_tex_situa_oc = "CONDICIONAL"
  WHEN  "S" LET p_tex_situa_oc = "SUSPENSA"
  WHEN  "T" LET p_tex_situa_oc = "COM COTACAO"
  OTHERWISE LET p_tex_situa_oc = NULL
  END CASE
  DISPLAY p_tex_situa_oc TO tex_situa_oc

  CALL sup029_verifica_programador() RETURNING p_status
  CALL sup029_verifica_comprador()   RETURNING p_status
  CALL sup029_verifica_item()        RETURNING p_status
  CALL sup029_verifica_item_sup()    RETURNING p_status
  CALL sup029_verifica_emergencia()
  IF sup029_verifica_componentes() THEN
     IF NOT g_ies_genero THEN
        DISPLAY " BENEFICIAMENTO " AT 04,55 ATTRIBUTE(REVERSE)
     ELSE
        CALL log4050_altera_atributo("benef","text","BENEFICIAMENTO")
     END IF
  ELSE
     IF NOT g_ies_genero THEN
        DISPLAY "                " AT 04,55
     ELSE
        CALL log4050_altera_atributo("benef","text","")
     END IF
  END IF

  #523974
  IF find4GLFunction('supy71_cliente_907') THEN
     IF supy71_cliente_907() = TRUE THEN
        IF find4GLFunction('supy71_busca_texto_local') THEN
           CALL supy71_busca_texto_local(p_ordem_sup.num_oc)
        END IF
     END IF
  END IF

 END FUNCTION

#-------------------------------#
 FUNCTION sup029_verifica_item()
#-------------------------------#
  DEFINE l_sqlcode SMALLINT

  LET p_formonly.den_item_reduz = NULL
  LET p_ies_tip_item = NULL

  SELECT den_item_reduz,
         cod_unid_med,
         den_item,
         cod_comprador,
         item.ies_ctr_estoque,
         gru_ctr_desp,
         item.pct_ipi,
         item.cod_cla_fisc,
         cod_lin_prod,
         cod_lin_recei,
         num_conta,
         (tmp_necessar_p_ped + tmp_necessar_fabr + tmp_transpor +
          tmp_inspecao + tmp_necessar_cont),
         item.ies_situacao,
         ies_tip_item,
         item.cod_local_estoq,
         item.gru_ctr_estoq
    INTO p_formonly.den_item_reduz,
         p_cod_unid_med,
         p_formonly.den_item,
         p_cod_comprador,
         p_ies_item_estoq,
         p_gru_ctr_desp,
         p_pct_ipi,
         p_cod_cla_fisc,
         p_cod_lin_prod,
         p_cod_lin_recei,
         p_num_conta,
         p_lead_time,
         p_ies_situacao,
         p_ies_tip_item,
         p_cod_local_estoq,
         m_gru_ctr_estoq
    FROM item,item_sup
    WHERE item.cod_empresa  = item_sup.cod_empresa
      AND item.cod_empresa  = p_cod_empresa
      AND item.cod_item     = gr_dados_tela_com.cod_item
      AND item.cod_item     = item_sup.cod_item

  LET l_sqlcode = sqlca.sqlcode

## 422118
  IF p_gru_ctr_desp IS NULL THEN
     LET p_gru_ctr_desp = 0
  END IF

  IF sup0538_existe_unid_compra_item(p_cod_empresa,gr_dados_tela_com.cod_item) THEN
     LET p_formonly.cod_unid_med = sup0538_unid_compra_item(p_cod_empresa,gr_dados_tela_com.cod_item)
  ELSE
     LET p_formonly.cod_unid_med = p_cod_unid_med
  END IF

  DISPLAY BY NAME p_formonly.den_item_reduz
  DISPLAY BY NAME p_formonly.den_item
  DISPLAY BY NAME p_formonly.cod_unid_med

  RETURN (l_sqlcode = 0)
 END FUNCTION

#-----------------------------------------#
 FUNCTION sup029_verifica_grupo_ctr_desp()
#-----------------------------------------#
  LET p_formonly.den_gru_ctr_desp = NULL
  SELECT den_gru_ctr_desp INTO p_formonly.den_gru_ctr_desp
    FROM grupo_ctr_desp
    WHERE grupo_ctr_desp.cod_empresa  = p_cod_empresa
      AND grupo_ctr_desp.gru_ctr_desp = gr_dados_tela_com.gru_ctr_desp
  DISPLAY BY NAME p_formonly.den_gru_ctr_desp

  RETURN (sqlca.sqlcode = 0)
 END FUNCTION

#--------------------------------------#
 FUNCTION sup029_verifica_programador()
#--------------------------------------#
  LET p_formonly.nom_progr = NULL
  WHENEVER ERROR CONTINUE
  SELECT nom_progr INTO p_formonly.nom_progr
    FROM programador
   WHERE programador.cod_empresa = p_cod_empresa
     AND programador.cod_progr   = gr_dados_tela_com.cod_progr
  WHENEVER ERROR STOP
  DISPLAY BY NAME p_formonly.nom_progr

  RETURN (sqlca.sqlcode = 0)
 END FUNCTION

#------------------------------------#
 FUNCTION sup029_verifica_comprador()
#------------------------------------#
  LET p_formonly.nom_comprador = NULL
  SELECT nom_comprador INTO p_formonly.nom_comprador
    FROM comprador
   WHERE comprador.cod_empresa   = p_cod_empresa
     AND comprador.cod_comprador = gr_dados_tela_com.cod_comprador
  DISPLAY BY NAME p_formonly.nom_comprador

  RETURN (sqlca.sqlcode = 0)
 END FUNCTION

#----------------------------------#
 FUNCTION sup029_verifica_par_sup()
#----------------------------------#
  LET gr_dados_tela_com.num_oc = NULL

  DECLARE cm_par_sup CURSOR FOR
   SELECT prx_num_oc INTO gr_dados_tela_com.num_oc
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
  FOR UPDATE

  OPEN cm_par_sup
  FETCH cm_par_sup
  CASE sqlca.sqlcode
  WHEN  0
     UPDATE par_sup SET prx_num_oc = prx_num_oc + 1
      WHERE CURRENT OF cm_par_sup
     IF sqlca.sqlcode = 0  THEN
        DISPLAY BY NAME gr_dados_tela_com.num_oc
        LET p_ordem_sup.num_oc        = gr_dados_tela_com.num_oc
        LET p_ordem_sup_compl.num_oc  = gr_dados_tela_com.num_oc
        LET p_prog_ordem_sup.num_oc   = gr_dados_tela_com.num_oc
        LET p_estrut_ordem_sup.num_oc = gr_dados_tela_com.num_oc
        CLOSE cm_par_sup
        RETURN TRUE
     ELSE
        CALL log003_err_sql("MODIFICACAO","PAR_SUP")
     END IF
  WHEN -250
     ERROR "Obtendo numero da ordem de compra na tabela PAR_SUP_PAD..."
     CALL log003_err_sql("LEITURA","PAR_SUP")
  WHEN  100
     ERROR "Parametros do sistema nao mais existem"
     CALL log003_err_sql("LEITURA","PAR_SUP")
  OTHERWISE
     CALL log003_err_sql("LEITURA","PAR_SUP")
  END CASE
  CLOSE cm_par_sup

  RETURN FALSE
 END FUNCTION

#-----------------------------------#
 FUNCTION sup029_cursor_for_update()
#-----------------------------------#
  DECLARE cm_ordem_sup CURSOR FOR
   SELECT * INTO p_ordem_sup.*  FROM ordem_sup
    WHERE ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
      AND ordem_sup.num_oc           = p_ordem_sup.num_oc
      AND ordem_sup.ies_versao_atual = "S"
  FOR UPDATE

  WHENEVER ERROR CONTINUE
  CALL log085_transacao("BEGIN")
  OPEN cm_ordem_sup
  FETCH cm_ordem_sup
  CASE sqlca.sqlcode
  WHEN    0 RETURN TRUE
  WHEN -250 CALL log0030_mensagem(" Registro sendo atualizado por outro usuario. Aguarde e tente novamente. ","exclamation")
  WHEN  100 CALL log0030_mensagem(" Registro nao mais existe na tabela. Execute a CONSULTA novamente. ","info")
  OTHERWISE CALL log003_err_sql("LEITURA","ORDEM_SUP")
  END CASE

  CALL log085_transacao("ROLLBACK")
  WHENEVER ERROR STOP

  RETURN FALSE
 END FUNCTION

#--------------------------------------------------------#
 FUNCTION sup029_modificacao_ordem_sup(l_permite_alterar)
#--------------------------------------------------------#
 DEFINE l_permite_alterar   SMALLINT

 IF find4GLFunction('supy23_verifica_ordem_compra_frota') THEN
    IF supy23_verifica_ordem_compra_frota(p_ordem_sup.cod_empresa,
                                          p_ordem_sup.num_oc) THEN
       CALL log0030_mensagem("OC gerada pelo sistema de frotas. Impossivel modificar.","exclamation")
       RETURN
    END IF
 END IF
 
 

 ### Nao retirar criacao da tabela daqui, pois em Oracle o CREATE TEMP
 ### efetiva a transacao e qdo volta ao sup0290 nao atualiza a ordem_sup
 ### pois ja foi dado COMMIT

 CALL sup1016_cria_temp()

 IF sup029_cursor_for_update() THEN
     LET p_ordem_supr.* = p_ordem_sup.*
     IF sup029_entrada_dados("MODIFICACAO",l_permite_alterar)  THEN
#--inicio--OS704186 Antonio#
           IF (m_orcamento_periodo  = "S"
           OR  m_usa_cond_pagto     = "S")
           OR (m_orcamento_periodo  = "N"
           AND m_usa_cond_pagto     = "N"
           AND m_atua_somente_desig = "N") THEN
              IF m_informa_val_previsto = "S" THEN
                 IF m_unid_func_todas_empresas = "N" THEN
                    CALL sup0772_atualiza_oc_oln_gao(gr_dados_tela_com.cod_empresa,
                                                     gr_dados_tela_com.num_oc,
                                                     gr_dados_tela_com.qtd_solic,
                                                     mr_tela.pre_unit_oc,
                                                     TODAY,
                                                     "OC",
                                                     "SUP0290",
                                                     0,
                                                     0,
                                                     0,
                                                     TRUE,  # Somente atualizar se a OC
                                                            # estiver APROVADA
                                                     TRUE,  # Buscar VAL_PREVISTO caso o
                                                            # preço estiver zerado
                                                     FALSE, # Considerar o Valor do IPI
                                                     FALSE, # Trata-se de Recebimento
                                                     FALSE, # Trata-se de Devolução à Fornecedor
                                                     "EX")
                    RETURNING p_status, m_msg
                    CALL sup0772_atualiza_oc_oln_gao(gr_dados_tela_com.cod_empresa,
                                                     gr_dados_tela_com.num_oc,
                                                     gr_dados_tela_com.qtd_solic,
                                                     mr_tela.pre_unit_oc,
                                                     TODAY,
                                                     "OC",
                                                     "SUP0290",
                                                     0,
                                                     0,
                                                     0,
                                                     TRUE,  # Somente atualizar se a OC
                                                            # estiver APROVADA
                                                     TRUE,  # Buscar VAL_PREVISTO caso o
                                                            # preço estiver zerado
                                                     FALSE, # Considerar o Valor do IPI
                                                     FALSE, # Trata-se de Recebimento
                                                     FALSE, # Trata-se de Devolução à Fornecedor
                                                     "IN")
                    RETURNING p_status, m_msg
                 END IF
              END IF
           END IF
#---fim----OS704186#
        IF sup0290_oc_com_recebimento() = FALSE THEN
           ### OS 180358 ###
           WHENEVER ERROR CONTINUE
           SELECT sup_oc_grade.empresa
             FROM sup_oc_grade
            WHERE sup_oc_grade.empresa       = p_cod_empresa
              AND sup_oc_grade.ordem_compra  = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 OR
              sqlca.sqlcode = -284 THEN

              CALL sup1016_movto_controles(m_lin_consig,              ### linha
                                           m_col_consig,              ### coluna
                                           "MODIFICACAO",             ### Tipo de movimento (INCLUSAO/EXCLUSAO)
                                           p_ordem_sup.num_oc,        ### Número da Ordem de compra
                                           p_ordem_sup.cod_item,      ### codigo do item
                                           p_ordem_sup.qtd_solic,     ### quantidade do processamento
                                           p_ordem_sup.qtd_recebida,
                                           p_ordem_sup.ies_situa_oc,
                                           p_ordem_sup.dat_entrega_prev)

                 RETURNING p_status

              CURRENT WINDOW IS w_sup02901

              IF p_status = FALSE THEN
                 ERROR " Modificacao cancelada "
                 CALL log085_transacao("ROLLBACK")
                 RETURN
              END IF
           ELSE
              #-Inicio-OS-544096#
              IF p_ordem_sup.ies_origem_oc <> 'C' THEN

                 CALL sup0063_verifica_controles(15, p_ordem_sup.cod_item, "INCLUSAO", "SUP0290")
                    RETURNING m_controles

                 IF m_controles IS NOT NULL AND m_controles <> " " THEN
                    INITIALIZE p_item_sup_compl.* TO NULL
                    WHENEVER ERROR CONTINUE
                    SELECT cod_empresa       ,
                           cod_item          ,
                           cod_fiscal_compl  ,
                           dat_hr_ult_atualiz,
                           usuario           ,
                           programa          ,
                           observacao        ,
                           reservado         ,
                           demanda_intelig   ,
                           demanda_media     ,
                           desvio_demanda    ,
                           desv_tempo_ressup ,
                           desvio_combinado  ,
                           val_funcao        ,
                           ind_distrib_normal
                      INTO p_item_sup_compl.cod_empresa       ,
                           p_item_sup_compl.cod_item          ,
                           p_item_sup_compl.cod_fiscal_compl  ,
                           p_item_sup_compl.dat_hr_ult_atualiz,
                           p_item_sup_compl.usuario           ,
                           p_item_sup_compl.programa          ,
                           p_item_sup_compl.observacao        ,
                           p_item_sup_compl.reservado         ,
                           p_item_sup_compl.demanda_intelig   ,
                           p_item_sup_compl.demanda_media     ,
                           p_item_sup_compl.desvio_demanda    ,
                           p_item_sup_compl.desv_tempo_ressup ,
                           p_item_sup_compl.desvio_combinado  ,
                           p_item_sup_compl.val_funcao        ,
                           p_item_sup_compl.ind_distrib_normal
                      FROM item_sup_compl
                     WHERE cod_empresa = p_ordem_sup.cod_empresa
                       AND cod_item    = gr_dados_tela_com.cod_item
                    WHENEVER ERROR STOP
                    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                       CALL log003_err_sql("select","item_sup_compl")
                    END IF

                    LET p_ordem_sup_compl.cod_empresa  = p_ordem_sup.cod_empresa
                    LET p_ordem_sup_compl.num_oc       = p_ordem_sup.num_oc
                    LET p_ordem_sup_compl.val_item_moeda = 0
                    IF p_item_sup_compl.cod_fiscal_compl IS NULL THEN
                       LET p_ordem_sup_compl.cod_fiscal_compl = 0
                    ELSE
                       LET p_ordem_sup_compl.cod_fiscal_compl = p_item_sup_compl.cod_fiscal_compl
                    END IF
                    IF sup0290_sistema_argentino() THEN
                       LET p_ordem_sup_compl.possui_remito = "S"
                       LET p_ordem_sup_compl.tip_compra    = "S"
                    END IF

                    CALL sup1016_movto_controles(m_lin_consig,              ### linha
                                                 m_col_consig,              ### coluna
                                                 "MODIFICACAO",                ### Tipo de movimento (INCLUSAO/EXCLUSAO)
                                                 p_ordem_sup.num_oc,        ### Número da Ordem de compra
                                                 p_ordem_sup.cod_item,      ### codigo do item
                                                 p_ordem_sup.qtd_solic,     ### quantidade do processamento
                                                 p_ordem_sup.qtd_recebida,
                                                 p_ordem_sup.ies_situa_oc,
                                                 p_ordem_sup.dat_entrega_prev)
                       RETURNING p_status
                    CURRENT WINDOW IS w_sup02901
                    IF p_status = FALSE THEN
                       ERROR " Modificação cancelada "
                       CALL log085_transacao("ROLLBACK")
                       RETURN
                    END IF
                 END IF
                #CALL log085_transacao("BEGIN")
                #OPEN cm_ordem_sup
                #FETCH cm_ordem_sup
              END IF
              #-Fim-OS-544096#
           END IF
        ELSE
           ERROR "OC com recebimento efetuado. Grade/dimens nao podem ser alterados"
        END IF

        CALL sup029_move_campos("MODIFICACAO")

        WHENEVER ERROR CONTINUE
        UPDATE ordem_sup SET ordem_sup.* = p_ordem_sup.*
          WHERE CURRENT OF cm_ordem_sup
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("MODIFICACAO","ORDEM_SUP")
           WHENEVER ERROR CONTINUE
           CALL log085_transacao("ROLLBACK")
           WHENEVER ERROR STOP
           RETURN
        END IF

        IF find4GLFunction('supy174_abre_tela_oc') THEN
           IF NOT supy174_abre_tela_oc(p_ordem_sup.cod_empresa,
                                       p_ordem_sup.num_oc,
                                       p_ordem_sup.num_versao,
                                       p_ordem_sup.ies_situa_oc) THEN
              WHENEVER ERROR CONTINUE
              CALL log085_transacao("ROLLBACK")
              WHENEVER ERROR STOP
              RETURN
           END IF
        END IF

        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("EFETIVACAO-COMMIT","PROG_ORDEM_SUP")
        ELSE
           MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
        END IF
     ELSE
        LET p_ordem_sup.* = p_ordem_supr.*
        CALL sup029_exibe_dados()
        CALL sup029_exibe_area()
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP
     END IF
  END IF
 END FUNCTION

#----------------------------------------------#
 FUNCTION sup029_orcamento_ordem_sup(l_pergunta)
#----------------------------------------------#
   DEFINE l_pergunta  SMALLINT,
          l_resposta  SMALLINT,
          l_retorno   SMALLINT

   LET l_retorno = sup0290_acesso_oc("ORCAMENTO")
   IF l_retorno = 0 THEN
      RETURN FALSE
   END IF

   IF gr_dados_tela_com.ies_situa_oc <> "P" THEN
      ERROR "Funcao não permitida. Ordem deve estar Planejada "
      RETURN FALSE
   END IF

   LET l_resposta = FALSE
   IF sup029_cursor_for_update() THEN

      IF l_pergunta THEN
         CALL log0040_confirm(21,51,"---Deseja Continuar?---") RETURNING l_resposta
      ELSE
         LET l_resposta = TRUE
      END IF

      IF l_resposta THEN
         WHENEVER ERROR CONTINUE
         UPDATE ordem_sup
            SET ies_situa_oc = "D"
          WHERE cod_empresa = p_cod_empresa
            AND num_oc = gr_dados_tela_com.num_oc
            AND ordem_sup.ies_versao_atual = "S"
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("MODIFICACAO","ORDEM_SUP")
            CALL log085_transacao("ROLLBACK")
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
            LET gr_dados_tela_com.ies_situa_oc = "D"
            LET p_formonly.tex_situa_oc = "CONDICIONAL"
            DISPLAY BY NAME gr_dados_tela_com.ies_situa_oc
            DISPLAY BY NAME p_formonly.tex_situa_oc
            RETURN TRUE
         END IF
         WHENEVER ERROR STOP
      END IF
      RETURN FALSE
   END IF

 END FUNCTION

#------------------------------------#
 FUNCTION sup029_exclusao_ordem_sup()
#------------------------------------#

  DEFINE l_valor_atualiza LIKE ordem_sup.pre_unit_oc,
         l_val_previsto   LIKE ordem_sup_txt.tex_observ_oc,
         l_pre_unit_oc    LIKE ordem_sup.pre_unit_oc

  IF find4GLFunction('supy23_verifica_ordem_compra_frota') THEN
     IF supy23_verifica_ordem_compra_frota(p_ordem_sup.cod_empresa,
                                           p_ordem_sup.num_oc) THEN
        CALL log0030_mensagem("OC gerada pelo sistema de frotas. Impossivel excluir.","exclamation")
     END IF
  END IF

  LET l_houve_erro = FALSE

  IF NOT sup0290_verifica_integracao_webb() THEN #OS. 423988
     CALL log0030_mensagem('Ordem de compra não pode ser excluída pois possui integração com portal de compras.','exclamation')
     RETURN
  END IF                                         #OS. 423988

  IF sup029_cursor_for_update() THEN
     IF log004_confirm(7,40) THEN
        IF NOT fcl1150_integra_oc_fcx(p_ordem_sup.cod_empresa,
                                      p_ordem_sup.num_oc,"EX") THEN
           LET l_houve_erro = TRUE
        END IF
#--inicio--OS704186 Antonio #
        IF (m_orcamento_periodo  = "S"
        OR  m_usa_cond_pagto     = "S")
        OR (m_orcamento_periodo  = "N"
        AND m_usa_cond_pagto     = "N"
        AND m_atua_somente_desig = "N") THEN
           IF m_informa_val_previsto = "S" THEN
              LET l_val_previsto = sup0772_busca_val_previsto(gr_dados_tela_com.cod_empresa, gr_dados_tela_com.num_oc)

              WHENEVER ERROR CONTINUE
              SELECT pre_unit_oc
                INTO l_pre_unit_oc
                FROM ordem_sup
               WHERE cod_empresa      = p_cod_empresa
                 AND num_oc           = gr_dados_tela_com.num_oc
                 AND ies_versao_atual = "S"
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0 THEN
                 CALL log003_err_sql("SELECT","ordem_sup")
              END IF

              IF  l_val_previsto >= l_pre_unit_oc
              AND m_ies_valor_desig = "S" THEN
                 LET l_valor_atualiza = l_val_previsto
              ELSE
                 IF l_pre_unit_oc = 0 OR
                    l_pre_unit_oc IS NULL THEN
                    LET l_valor_atualiza = l_val_previsto
                 ELSE
                    LET l_valor_atualiza = l_pre_unit_oc
                 END IF
              END IF

              IF m_unid_func_todas_empresas = "N" THEN
                 CALL sup0772_atualiza_oc_oln_gao(gr_dados_tela_com.cod_empresa,
                                                  gr_dados_tela_com.num_oc,
                                                  gr_dados_tela_com.qtd_solic,
                                                  l_valor_atualiza,
                                                  TODAY,
                                                  "OC",
                                                  "SUP0290",
                                                  0,
                                                  0,
                                                  0,
                                                  TRUE,  # Somente atualizar se a OC
                                                         # estiver APROVADA
                                                  TRUE,  # Buscar VAL_PREVISTO caso o
                                                         # preço estiver zerado
                                                  FALSE, # Considerar o Valor do IPI
                                                  FALSE, # Trata-se de Recebimento
                                                  FALSE, # Trata-se de Devolução à Fornecedor
                                                  "EX")
                      RETURNING p_status, m_msg
                 IF p_status = FALSE THEN
                    LET l_houve_erro = TRUE
                 END IF
              END IF
           END IF
        END IF
#---fim----OS704186#

        IF NOT l_houve_erro THEN
           IF NOT sup1310_exclui_reserva_oc(p_ordem_sup.cod_empresa,p_ordem_sup.num_oc) THEN
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM ordem_sup
            WHERE ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
              AND ordem_sup.num_oc           = p_ordem_sup.num_oc
              AND ordem_sup.ies_versao_atual = "S"
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM sup_oc_grade
            WHERE empresa      = p_ordem_sup.cod_empresa
              AND ordem_compra = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","SUP_OC_GRADE")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM ordem_sup_compl
            WHERE cod_empresa = p_ordem_sup.cod_empresa
              AND num_oc      = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","ORDEM_SUP_COMPL")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           IF NOT pol1233_grava_corte() THEN
              LET l_houve_erro = TRUE
           END IF
           WHENEVER ERROR STOP
        END IF
        
        IF NOT l_houve_erro THEN                   
           WHENEVER ERROR CONTINUE
           DELETE FROM prog_ordem_sup
            WHERE prog_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
              AND prog_ordem_sup.num_oc      = p_ordem_sup.num_oc
              AND prog_ordem_sup.num_versao  = p_ordem_sup.num_versao
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","PROG_ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM dest_ordem_sup
            WHERE dest_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
              AND dest_ordem_sup.num_oc      = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","DEST_ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM estrut_ordem_sup
            WHERE estrut_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
              AND estrut_ordem_sup.num_oc      = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","ESTRUT_ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM sup_estrut_oc_grd
            WHERE empresa      = p_cod_empresa
              AND ordem_compra = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 AND
              sqlca.sqlcode <> -206 THEN
              CALL log003_err_sql("EXCLUSAO","SUP_ESTRUT_OC_GRD")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM ordem_sup_txt
            WHERE ordem_sup_txt.cod_empresa = p_ordem_sup.cod_empresa
              AND ordem_sup_txt.num_oc      = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","ORDEM_SUP_TXT")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM prog_ordem_sup_com
            WHERE prog_ordem_sup_com.cod_empresa = p_ordem_sup.cod_empresa
              AND prog_ordem_sup_com.num_oc      = p_ordem_sup.num_oc
              AND prog_ordem_sup_com.num_versao  = p_ordem_sup.num_versao
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("EXCLUSAO","PROG_ORDEM_SUP_COM")
              LET l_houve_erro = TRUE
           END IF
        END IF

        IF NOT l_houve_erro THEN
           IF p_par_con.ies_contab_aen = "4" THEN
              WHENEVER ERROR CONTINUE
              DELETE FROM dest_ordem_sup4
               WHERE dest_ordem_sup4.cod_empresa = p_ordem_sup.cod_empresa
                 AND dest_ordem_sup4.num_oc      = p_ordem_sup.num_oc
              WHENEVER ERROR STOP
              IF sqlca.sqlcode <> 0  THEN
                 CALL log003_err_sql("EXCLUSAO","DEST_ORDEM_SUP4")
                 LET l_houve_erro = TRUE
              END IF
           END IF
        END IF

        IF NOT l_houve_erro THEN
           WHENEVER ERROR CONTINUE
           DELETE FROM aprov_ordem_sup
            WHERE aprov_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
              AND aprov_ordem_sup.num_oc      = p_ordem_sup.num_oc
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0  THEN
              CALL log003_err_sql("EXCLUSAO","APROV_ORDEM_SUP")
              LET l_houve_erro = TRUE
           END IF
        END IF
     ELSE
        ERROR "Exclusao cancelada"
        LET l_houve_erro = TRUE
     END IF

     IF NOT l_houve_erro THEN
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("COMMIT")
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CALL log003_err_sql("EFETIVACAO-COMMIT","ORDEM_SUP")
        ELSE
           MESSAGE " Exclusão efetuada com sucesso. " ATTRIBUTE(REVERSE)
           INITIALIZE gr_dados_tela_com.* TO NULL
           INITIALIZE p_formonly.* TO NULL
           INITIALIZE p_ordem_sup.* TO NULL
           INITIALIZE p_ordem_supr.* TO NULL
           DISPLAY '                                                                             ' AT 18,01
           CLEAR FORM
           IF NOT g_ies_genero THEN
              DISPLAY "                   " AT 05,26
              DISPLAY "               "     AT 14,50
              DISPLAY "                "    AT 04,55
              DISPLAY "                "    AT 11,30
           ELSE
              CALL log4050_altera_atributo("numped","text","")
              CALL log4050_altera_atributo("numseq","text","")
              CALL log4050_altera_atributo("benef","text","")
              CALL log4050_altera_atributo("emerg","text","")
           END IF
        END IF
     ELSE
        LET l_houve_erro = FALSE
        WHENEVER ERROR CONTINUE
        CALL log085_transacao("ROLLBACK")
        WHENEVER ERROR STOP
     END IF
  END IF

 END FUNCTION

#-----------------------------#
FUNCTION pol1233_grava_corte()#
#-----------------------------#
   
   LET p_tip_ajuste = 'C'
   
   DECLARE cq_corte CURSOR FOR
    SELECT * FROM prog_ordem_sup
     WHERE prog_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
       AND prog_ordem_sup.num_oc      = p_ordem_sup.num_oc
       AND prog_ordem_sup.num_versao  = p_ordem_sup.num_versao
   
   FOREACH cq_corte INTO p_prog_ordem_sup.*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'CQ_CORTE')
         RETURN FALSE
      END IF
      
      IF NOT pol1233_grava_prog_ord() THEN
         RETURN FALSE
      END IF
   
   END FOREACH

   DELETE FROM oc_bloqueada_454
    WHERE cod_empresa = p_ordem_sup.cod_empresa
      AND num_oc = p_ordem_sup.num_oc 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'OC_BLOQUEADA_454')
      RETURN FALSE
   END IF

   {DELETE FROM prog_ord_sup_454
    WHERE cod_empresa = p_ordem_sup.cod_empresa
      AND num_oc = p_ordem_sup.num_oc 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'PROG_ORD_SUP_454')
      RETURN FALSE
   END IF}

   DELETE FROM item_criticado_bi_454
    WHERE cod_empresa = p_ordem_sup.cod_empresa
      AND num_oc = p_ordem_sup.num_oc 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('DELETE', 'item_criticado_bi_454')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#--------------------------------#      
FUNCTION pol1233_grava_prog_ord()#
#--------------------------------#

   SELECT MAX(id_registro)
     INTO p_id_prog_ord
     FROM prog_ord_sup_454

   IF STATUS <> 0 THEN
      CALL log003_err_sql("SELECT","prog_ord_sup_454")
      RETURN FALSE
   END IF
   
   IF p_id_prog_ord IS NULL THEN
      LET p_id_prog_ord = 1
   ELSE
      LET p_id_prog_ord = p_id_prog_ord + 1
   END IF

   SELECT data_processamento
     INTO p_data_processamento
     FROM mapa_dias_mes_454
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','mapa_dias_mes_454')
      RETURN FALSE
   END IF
   
   LET p_dat_origem = DATE(p_data_processamento)
   
   INSERT INTO prog_ord_sup_454 VALUES (
      p_prog_ordem_sup.cod_empresa,
      p_ordem_sup.cod_item,
      p_prog_ordem_sup.num_oc,
      p_prog_ordem_sup.num_versao,
      p_prog_ordem_sup.num_prog_entrega,
      p_prog_ordem_sup.qtd_solic,
      p_prog_ordem_sup.dat_entrega_prev,
      p_dat_origem,
      p_tip_ajuste,
      p_id_prog_ord)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","prog_ord_sup_454")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
   

#------------------------------------#
 FUNCTION sup029_consulta_ordem_sup()
#------------------------------------#
 DEFINE p_ies_primeira           SMALLINT,
        where_clause, sql_stmt   CHAR(500),
        p_funcao CHAR(30)

  CALL log006_exibe_teclas("02 07",p_versao)
  CURRENT WINDOW IS w_sup02901

  LET p_ordem_supr.*  = p_ordem_sup.*

  INITIALIZE p_funcao TO NULL
  INITIALIZE gr_dados_tela_com.* TO NULL
  INITIALIZE p_formonly.* TO NULL
  INITIALIZE where_clause, sql_stmt TO NULL
  CALL sup0538_inicializa_variaveis()
  IF NOT g_ies_genero THEN
     DISPLAY "                   " AT 05,26
     DISPLAY "               "     AT 14,50
     DISPLAY "                "    AT 04,55
     DISPLAY "                "    AT 11,30
  ELSE
     CALL log4050_altera_atributo("numped","text","")
     CALL log4050_altera_atributo("numseq","text","")
     CALL log4050_altera_atributo("benef","text","")
     CALL log4050_altera_atributo("emerg","text","")
  END IF

  CLEAR FORM
  INITIALIZE p_area TO NULL
  DISPLAY  p_cod_empresa TO cod_empresa

  ### quando o sup0290 he chamado com parametros entao passa
  ### diretamente para a consulta atraves dos parametros:
  ### arg_val(1) = cod_item
  ### arg_val(2) = cod_empresa
  ### arg_val(3) = num_oc
  ### arg_val(4) = "CONSULTA"

  IF p_arg_cod_item IS NOT NULL AND p_arg_num_oc IS NOT NULL THEN
     LET sql_stmt =
       "SELECT ordem_sup.* FROM ordem_sup WHERE ",
       "ordem_sup.cod_empresa = """,p_arg_cod_empresa,""" AND ",
       "ordem_sup.ies_versao_atual = ""S"" AND ",
       "ordem_sup.ies_item_estoq = ""S"" "
     IF p_arg_num_oc > 0 THEN
        LET sql_stmt = sql_stmt CLIPPED,
            " AND ordem_sup.num_oc = ",p_arg_num_oc," "
     ELSE
        LET sql_stmt = sql_stmt CLIPPED,
            " AND ordem_sup.cod_item = """,p_arg_cod_item,""" "
     END IF

     IF m_consulta_decres = "S" THEN
        LET sql_stmt = sql_stmt CLIPPED,
            " ORDER BY ordem_sup.cod_empresa, ordem_sup.num_oc DESC "
     ELSE
        LET sql_stmt = sql_stmt CLIPPED,
            " ORDER BY ordem_sup.cod_empresa, ordem_sup.num_oc "
     END IF

  ELSE
     IF m_possui_centraliz THEN
        LET p_ies_primeira = TRUE
        LET int_flag = 0
        CONSTRUCT BY NAME where_clause ON ordem_sup.cod_empresa,
                                          ordem_sup.num_oc,
                                          ordem_sup.ies_situa_oc,
                                          ordem_sup.cod_item,
                                          ordem_sup.qtd_solic,
                                          ordem_sup.cod_progr,
                                          ordem_sup.cod_comprador
        BEFORE FIELD cod_empresa
          IF p_ies_primeira = TRUE THEN
             LET p_ies_primeira = FALSE
             DISPLAY p_cod_empresa TO cod_empresa
             NEXT FIELD num_oc
          END IF

        BEFORE FIELD ies_situa_oc
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD ies_situa_oc
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_item
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_item
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_progr
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_progr
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_comprador
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_comprador
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        ON KEY (control-z, f4)
          CALL sup029_popups()

        ON KEY (control-w,f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE CONSTRUCT
           #lds END IF
          CALL sup029_help()
        END CONSTRUCT
     ELSE
        LET int_flag = 0
        CONSTRUCT BY NAME where_clause ON ordem_sup.num_oc,
                                          ordem_sup.ies_situa_oc,
                                          ordem_sup.cod_item,
                                          ordem_sup.qtd_solic,
                                          ordem_sup.cod_progr,
                                          ordem_sup.cod_comprador
        BEFORE FIELD ies_situa_oc
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD ies_situa_oc
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_item
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_item
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_progr
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_progr
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        BEFORE FIELD cod_comprador
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','Zoom')
          ELSE
             DISPLAY "( Zoom )" AT 3,68
          END IF

        AFTER FIELD cod_comprador
          IF g_ies_grafico THEN
             --# CALL fgl_dialog_setkeylabel ('Control-Z','')
          ELSE
             DISPLAY "--------" AT 3,68
          END IF

        ON KEY (control-z, f4)
          CALL sup029_popups()

        ON KEY (control-w,f1)
           #lds IF NOT LOG_logix_versao5() THEN
           #lds CONTINUE CONSTRUCT
           #lds END IF
          CALL sup029_help()
        END CONSTRUCT
     END IF

     CALL log006_exibe_teclas("01",p_versao)
     CURRENT WINDOW IS w_sup02901

     IF int_flag THEN
        LET p_ordem_sup.* = p_ordem_supr.*
        CALL sup029_exibe_dados()
        CALL sup029_exibe_area()
        ERROR "Consulta cancelada"
        RETURN
     END IF

     IF m_possui_centraliz THEN
        LET sql_stmt = "SELECT ordem_sup.* FROM ordem_sup, centraliz_emp_sup WHERE ",
                       "ordem_sup.cod_empresa = centraliz_emp_sup.cod_empresa AND ",
                       "ordem_sup.ies_versao_atual = ""S"" AND ",
                       "ordem_sup.ies_item_estoq   = ""S"" AND ",
                       where_clause CLIPPED
     ELSE
        LET sql_stmt = "SELECT ordem_sup.* FROM ordem_sup WHERE ",
                       "ordem_sup.cod_empresa = """,p_cod_empresa,""" AND ",
                       "ordem_sup.ies_versao_atual = ""S"" AND ",
                       "ordem_sup.ies_item_estoq   = ""S"" AND ",
                       where_clause CLIPPED
     END IF

     IF m_consulta_decres = "S" THEN
        LET sql_stmt = sql_stmt CLIPPED,
            " ORDER BY 1, 2 DESC "
     ELSE
        LET sql_stmt = sql_stmt CLIPPED,
            " ORDER BY 1, 2"
     END IF
  END IF

  PREPARE var_query FROM sql_stmt
  DECLARE cq_ordem_sup SCROLL CURSOR WITH HOLD FOR var_query
  OPEN cq_ordem_sup
  FETCH cq_ordem_sup INTO p_ordem_sup.*
  IF sqlca.sqlcode = NOTFOUND THEN
     CLEAR FORM
     CALL log0030_mensagem("Argumentos de pesquisa nao encontrados","exclamation")
     LET p_ies_cons = FALSE
  ELSE
     WHILE TRUE
        IF sup0290_item_controle_estoque_fisico(p_ordem_sup.cod_empresa,p_ordem_sup.cod_item) THEN
           FETCH cq_ordem_sup INTO p_ordem_sup.*
           IF sqlca.sqlcode = NOTFOUND THEN
              CLEAR FORM
              CALL log0030_mensagem("Argumentos de pesquisa nao encontrados","exclamation")
              LET p_ies_cons = FALSE
              RETURN
           END IF
        ELSE
           EXIT WHILE
        END IF
     END WHILE
     LET p_ies_cons = TRUE
     CALL sup029_exibe_dados()
     CALL sup029_exibe_area()
  END IF
 END FUNCTION

#----------------------------#
 FUNCTION sup029_exibe_area()
#----------------------------#
  DEFINE l_msg CHAR(30)

  INITIALIZE p_area TO NULL

  IF p_par_con.ies_contab_aen <> "4" THEN
     DECLARE cl_area3 CURSOR FOR
      SELECT cod_area_negocio,
             cod_lin_negocio,
             num_conta_deb_desp,
             pct_particip_comp
        FROM dest_ordem_sup
       WHERE dest_ordem_sup.cod_empresa = p_ordem_sup.cod_empresa
         AND dest_ordem_sup.num_oc      = p_ordem_sup.num_oc
       ORDER BY dest_ordem_sup.cod_area_negocio, dest_ordem_sup.cod_lin_negocio
     LET p_ind_arr = 1
     FOREACH cl_area3 INTO p_area[p_ind_arr].cod_area_negocio,
                           p_area[p_ind_arr].cod_lin_negocio,
                           p_area[p_ind_arr].num_conta,
                           p_area[p_ind_arr].pct_particip_comp
        LET p_area[p_ind_arr].seq = p_ind_arr
        LET p_area[p_ind_arr].cod_seg_merc = NULL
        LET p_area[p_ind_arr].cod_cla_uso  = NULL

        CALL con088_verifica_cod_conta(p_ordem_sup.cod_empresa,
                                       p_area[p_ind_arr].num_conta,
                                       "S", TODAY)
             RETURNING p_plano_contas.*, p_status

        IF NOT p_status THEN
           IF p_plano_contas.den_conta IS NOT NULL AND p_plano_contas.den_conta <> " " THEN
              CALL log0030_mensagem(p_plano_contas.den_conta, "exclamation")
           END IF
        END IF

        IF p_plano_contas.ies_titulo <> "N" THEN
           LET p_area[p_ind_arr].den_conta = NULL
        ELSE
           IF p_status = FALSE THEN
              LET p_area[p_ind_arr].den_conta = NULL
           ELSE
              LET p_area[p_ind_arr].den_conta = p_plano_contas.den_conta
           END IF
        END IF
        LET p_ind_arr = p_ind_arr + 1
        IF p_ind_arr > 50 THEN
           EXIT FOREACH
        END IF
     END FOREACH
  ELSE
     DECLARE cl_area4 CURSOR FOR
      SELECT cod_area_negocio,
             cod_lin_negocio,
             cod_seg_merc,
             cod_cla_uso,
             num_conta_deb_desp,
             pct_particip_comp
        FROM dest_ordem_sup4
       WHERE dest_ordem_sup4.cod_empresa = p_ordem_sup.cod_empresa
         AND dest_ordem_sup4.num_oc      = p_ordem_sup.num_oc
       ORDER BY dest_ordem_sup4.cod_area_negocio,
                dest_ordem_sup4.cod_lin_negocio,
                dest_ordem_sup4.cod_seg_merc,
                dest_ordem_sup4.cod_cla_uso
     LET p_ind_arr = 1
     FOREACH cl_area4 INTO p_area[p_ind_arr].cod_area_negocio,
                           p_area[p_ind_arr].cod_lin_negocio,
                           p_area[p_ind_arr].cod_seg_merc,
                           p_area[p_ind_arr].cod_cla_uso,
                           p_area[p_ind_arr].num_conta,
                           p_area[p_ind_arr].pct_particip_comp
        LET p_area[p_ind_arr].seq = p_ind_arr

        CALL con088_verifica_cod_conta(p_ordem_sup.cod_empresa,
                                       p_area[p_ind_arr].num_conta,
                                       "S", TODAY)
             RETURNING p_plano_contas.*, p_status

        IF NOT p_status THEN
           IF p_plano_contas.den_conta IS NOT NULL AND p_plano_contas.den_conta <> " " THEN
              CALL log0030_mensagem(p_plano_contas.den_conta, "exclamation")
           END IF
        END IF

        IF p_plano_contas.ies_titulo <> "N" THEN
           LET p_area[p_ind_arr].den_conta = NULL
        ELSE
           IF p_status = FALSE THEN
              LET p_area[p_ind_arr].den_conta = NULL
           ELSE
              LET p_area[p_ind_arr].den_conta = p_plano_contas.den_conta
           END IF
        END IF
        LET p_ind_arr = p_ind_arr + 1
        IF p_ind_arr > 50 THEN
           EXIT FOREACH
        END IF
     END FOREACH
  END IF
  LET p_nr_itens = p_ind_arr - 1
  IF p_nr_itens > 0 THEN
     IF NOT g_ies_genero THEN
        DISPLAY "Nr.seq.", p_nr_itens AT 14,50 ATTRIBUTE(REVERSE)
     ELSE
        LET l_msg = "Nr.seq.", p_nr_itens CLIPPED
        CALL log4050_altera_atributo("numseq","text",l_msg)
     END IF
  END IF
  DISPLAY p_area[1].* TO s_area[1].*
 END FUNCTION

#-----------------------------------#
 FUNCTION sup029_paginacao(p_funcao)
#-----------------------------------#
  DEFINE p_funcao CHAR(20)

  IF p_ies_cons THEN
     LET p_ordem_supr.* = p_ordem_sup.*
     WHILE TRUE
        CASE
        WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_ordem_sup INTO p_ordem_sup.*
        WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_ordem_sup INTO p_ordem_sup.*
        END CASE
        IF sqlca.sqlcode = NOTFOUND THEN
           ERROR "Nao existem mais itens nesta direcao"
           LET p_ordem_sup.* = p_ordem_supr.*
           EXIT WHILE
        END IF

        WHILE TRUE
           IF sup0290_item_controle_estoque_fisico(p_ordem_sup.cod_empresa,
                                                   p_ordem_sup.cod_item) THEN
              CASE
              WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_ordem_sup INTO p_ordem_sup.*
              WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_ordem_sup INTO p_ordem_sup.*
              END CASE
              IF sqlca.sqlcode = NOTFOUND THEN
                 ERROR "Nao existem mais itens nesta direcao"
                 LET p_ordem_sup.* = p_ordem_supr.*
                 EXIT WHILE
              END IF
           ELSE
              EXIT WHILE
           END IF
        END WHILE

        SELECT * INTO p_ordem_sup.* FROM ordem_sup
         WHERE ordem_sup.cod_empresa      = p_ordem_sup.cod_empresa
           AND ordem_sup.num_oc           = p_ordem_sup.num_oc
           AND ordem_sup.ies_versao_atual = "S"
        IF sqlca.sqlcode = 0 THEN
           CALL sup029_exibe_dados()
           LET p_funcao = "CONSULTA"
           CALL sup029_exibe_area()
           EXIT WHILE
        END IF
     END WHILE
  ELSE
     ERROR "Nao existe nenhuma consulta ativa"
  END IF
 END FUNCTION

#--------------------------#
 FUNCTION sup029_zoom_aen()
#--------------------------#
  DEFINE p_area_z ARRAY[1000] OF
                  RECORD
                  num_conta         LIKE plano_contas.num_conta,
                  cod_area_negocio  LIKE dest_ordem_sup.cod_area_negocio,
                  cod_lin_negocio   LIKE dest_ordem_sup.cod_lin_negocio,
                  cod_seg_merc      LIKE linha_prod.cod_seg_merc,
                  cod_cla_uso       LIKE linha_prod.cod_cla_uso,
                  pct_particip_comp LIKE dest_ordem_sup.pct_particip_comp
                  END RECORD,
         p_cont   SMALLINT

  INITIALIZE p_area_z TO NULL

  IF g_pais = "AR" THEN
     LET m_window = "sup0290d"
  ELSE
     LET m_window = "sup02905"
  END IF

  CALL log006_exibe_teclas("02 17 18",p_versao)
  CALL log130_procura_caminho(m_window) RETURNING comando
  OPEN WINDOW w_sup02905 AT 11,15 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

  IF p_par_con.ies_contab_aen <> "4" THEN
     DECLARE cp_array_z_aen CURSOR FOR
      SELECT num_conta_deb_desp,
             cod_area_negocio,
             cod_lin_negocio,
             pct_particip_comp
        FROM dest_ordem_sup
       WHERE dest_ordem_sup.cod_empresa = p_cod_empresa
         AND dest_ordem_sup.num_oc      = gr_dados_tela_com.num_oc

     LET p_cont = 1
     FOREACH cp_array_z_aen INTO p_area_z[p_cont].num_conta,
                                 p_area_z[p_cont].cod_area_negocio,
                                 p_area_z[p_cont].cod_lin_negocio,
                                 p_area_z[p_cont].pct_particip_comp
        LET p_area_z[p_cont].cod_seg_merc = NULL
        LET p_area_z[p_cont].cod_cla_uso  = NULL
        LET p_cont = p_cont + 1
        IF p_cont > 1000
           THEN EXIT FOREACH
        END IF
     END FOREACH
  ELSE
     DECLARE cp_array_z_aen2 CURSOR FOR
      SELECT num_conta_deb_desp,
             cod_area_negocio,
             cod_lin_negocio,
             cod_seg_merc,
             cod_cla_uso,
             pct_particip_comp
        FROM dest_ordem_sup4
       WHERE dest_ordem_sup4.cod_empresa = p_cod_empresa
         AND dest_ordem_sup4.num_oc      = gr_dados_tela_com.num_oc

     LET p_cont = 1
     FOREACH cp_array_z_aen2 INTO p_area_z[p_cont].num_conta,
                                  p_area_z[p_cont].cod_area_negocio,
                                  p_area_z[p_cont].cod_lin_negocio,
                                  p_area_z[p_cont].cod_seg_merc,
                                  p_area_z[p_cont].cod_cla_uso,
                                  p_area_z[p_cont].pct_particip_comp
        LET p_cont = p_cont + 1
        IF p_cont > 1000
           THEN EXIT FOREACH
        END IF
     END FOREACH
  END IF
  CALL set_count(p_cont - 1)
  DISPLAY ARRAY p_area_z TO s_sup02905.*
  CLOSE WINDOW w_sup02905
  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup02901
  LET int_flag = 0
 END FUNCTION

#------------------------------------#
 FUNCTION sup029_zoom_por_comprador()
#------------------------------------#
  DEFINE p_num_versao       LIKE prog_ordem_sup.num_versao,
         p_ind_arr, p_ind2  SMALLINT,
         p_qtd_reservada    LIKE ar_ped.qtd_reservada,
         p_num_prog_entrega LIKE prog_ordem_sup.num_prog_entrega,
         l_fat_conver       LIKE fat_conver.fat_conver_unid

  DEFINE p_array_cpr        ARRAY[1000] OF
                            RECORD
                            cod_empresa      LIKE ordem_sup.cod_empresa,
                            cod_item         LIKE ordem_sup.cod_item,
                            num_oc           LIKE ordem_sup.num_oc,
                            dat_emis         LIKE ordem_sup.dat_emis,
                            dat_entrega_prev CHAR(10),
                            qtd_saldo        DECIMAL(12,3),
                            ies_situa_oc     LIKE ordem_sup.ies_situa_oc,
                            num_pedido       LIKE ordem_sup.num_pedido
                            END RECORD

  INITIALIZE p_array_cpr TO NULL

  IF g_pais = "AR" THEN
     LET m_window = "sup0290c"
  ELSE
     LET m_window = "sup02903"
  END IF

  CALL log006_exibe_teclas("02 17 18",p_versao)
  CALL log130_procura_caminho(m_window) RETURNING comando
  OPEN WINDOW w_sup02903 AT 7,2 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)

  DECLARE cp_array_cpr CURSOR FOR
    SELECT cod_empresa, cod_item, num_oc, dat_emis, " ",
           qtd_solic - qtd_recebida, ies_situa_oc, num_pedido, num_versao
      FROM ordem_sup, empresa
      WHERE ordem_sup.cod_empresa      = empresa.cod_empresa
        AND ordem_sup.cod_comprador    = p_ordem_sup.cod_comprador
        AND ordem_sup.ies_versao_atual = "S"
        AND ordem_sup.ies_item_estoq   = "S"
        AND ordem_sup.ies_situa_oc    <> "C"
        AND ordem_sup.ies_situa_oc    <> "L"
        AND ordem_sup.qtd_solic - ordem_sup.qtd_recebida  > 0
    ORDER BY cod_empresa, num_oc

  LET p_ind_arr = 1
  FOREACH cp_array_cpr INTO p_array_cpr[p_ind_arr].*, p_num_versao
     IF m_possui_centraliz THEN
        WHENEVER ERROR CONTINUE
        SELECT * FROM centraliz_emp_sup
         WHERE centraliz_emp_sup.cod_empresa = p_array_cpr[p_ind_arr].cod_empresa
        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
           CONTINUE FOREACH
        END IF
     ELSE
        IF p_array_cpr[p_ind_arr].cod_empresa <> p_cod_empresa THEN
           CONTINUE FOREACH
        END IF
     END IF
     LET p_array_cpr[p_ind_arr].dat_entrega_prev = "**/**/****"
     LET p_array_cpr[p_ind_arr].qtd_saldo = ""

     DECLARE cp_prog CURSOR FOR
      SELECT qtd_solic - qtd_recebida, dat_entrega_prev,
             ies_situa_prog, num_prog_entrega
        FROM prog_ordem_sup
       WHERE prog_ordem_sup.cod_empresa  = p_array_cpr[p_ind_arr].cod_empresa
         AND prog_ordem_sup.num_oc       = p_array_cpr[p_ind_arr].num_oc
         AND prog_ordem_sup.num_versao   = p_num_versao
         AND prog_ordem_sup.qtd_solic    > prog_ordem_sup.qtd_recebida
         AND prog_ordem_sup.ies_situa_prog IN ("P","F")
       ORDER BY dat_entrega_prev

     LET p_ind2 = 1

     FOREACH cp_prog INTO p_array_cpr[p_ind_arr + p_ind2].qtd_saldo,
                          p_array_cpr[p_ind_arr + p_ind2].dat_entrega_prev,
                          p_array_cpr[p_ind_arr + p_ind2].ies_situa_oc,
                          p_num_prog_entrega

        CALL sup477_baixa_saldo_pedido(p_array_cpr[p_ind_arr].cod_empresa,
                                       p_array_cpr[p_ind_arr].num_pedido,
                                       p_array_cpr[p_ind_arr].num_oc,
                                       p_num_prog_entrega)
             RETURNING p_qtd_reservada
        LET p_array_cpr[p_ind_arr + p_ind2].qtd_saldo =
            p_array_cpr[p_ind_arr + p_ind2].qtd_saldo - p_qtd_reservada

        IF p_array_cpr[p_ind_arr + p_ind2].qtd_saldo <> 0 THEN
           IF sup0538_existe_unid_compra_item(p_array_cpr[p_ind_arr].cod_empresa,
                                              p_array_cpr[p_ind_arr].cod_item) THEN
              LET l_fat_conver = sup0538_fat_conver_estoque_compra_item(
                                              p_array_cpr[p_ind_arr].cod_empresa,
                                              p_array_cpr[p_ind_arr].cod_item)
           ELSE
              LET l_fat_conver = 1
           END IF

           LET p_array_cpr[p_ind_arr + p_ind2].qtd_saldo =
               p_array_cpr[p_ind_arr + p_ind2].qtd_saldo / l_fat_conver

           LET p_ind2 = p_ind2 + 1
        END IF
        IF p_ind_arr + p_ind2 >= 400 THEN
           EXIT FOREACH
        END IF
     END FOREACH
     LET p_ind_arr = p_ind_arr + p_ind2

     IF p_ind_arr > 400 THEN
        EXIT FOREACH
     END IF
  END FOREACH
  DISPLAY BY NAME p_ordem_sup.cod_comprador, p_formonly.nom_comprador

  CALL set_count(p_ind_arr - 1)
  DISPLAY ARRAY p_array_cpr TO s_sup02903.*
  CLOSE WINDOW w_sup02903

  CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_sup02901
  LET int_flag = 0
 END FUNCTION

#-------------------------------------#
 FUNCTION sup029_verifica_duplicacao()
#-------------------------------------#
  DEFINE p_inicio,p_cont SMALLINT

  LET p_inicio = 1
  LET p_cont   = 0

  WHILE p_inicio <= 49
     FOR p_cont = (p_inicio+1) TO 50
        IF p_par_con.ies_contab_aen <> "4" THEN
           IF  (p_area[p_inicio].cod_area_negocio = p_area[p_cont].cod_area_negocio)
           AND (p_area[p_inicio].cod_lin_negocio  = p_area[p_cont].cod_lin_negocio) THEN
              RETURN FALSE
           END IF
        ELSE
           IF  (p_area[p_inicio].cod_area_negocio = p_area[p_cont].cod_area_negocio)
           AND (p_area[p_inicio].cod_lin_negocio  = p_area[p_cont].cod_lin_negocio)
           AND (p_area[p_inicio].cod_seg_merc     = p_area[p_cont].cod_seg_merc)
           AND (p_area[p_inicio].cod_cla_uso      = p_area[p_cont].cod_cla_uso) THEN
              RETURN FALSE
           END IF
        END IF
     END FOR
     LET p_inicio = p_inicio + 1
  END WHILE
  RETURN TRUE
 END FUNCTION

#-------------------------------------------#
 FUNCTION sup029_verifica_percent(p_total_r)
#-------------------------------------------#
  DEFINE p_cont    SMALLINT,
         p_total_r LIKE dest_ordem_sup.pct_particip_comp

  LET p_total_r = 0
  FOR p_cont = 1 TO 670
     IF p_area[p_cont].pct_particip_comp IS NOT NULL THEN
        LET p_total_r = p_total_r + p_area[p_cont].pct_particip_comp
     END IF
  END FOR
  IF p_total_r = 100 THEN
     RETURN TRUE
  ELSE
     RETURN FALSE
  END IF
 END FUNCTION

#-----------------------#
 FUNCTION sup029_popup()
#-----------------------#
 DEFINE p_cod_area_negocio LIKE area_negocio.cod_area_negocio,
        p_num_conta        LIKE plano_contas.num_conta,
        p_cod_lin_negocio  LIKE linha_negocio.cod_lin_negocio,
        l_cod_lin_prod     LIKE linha_prod.cod_lin_prod,
        l_cod_lin_recei    LIKE linha_prod.cod_lin_recei,
        p_cod_seg_merc     LIKE linha_prod.cod_seg_merc,
        p_cod_cla_uso      LIKE linha_prod.cod_cla_uso

 LET p_cod_area_negocio = NULL
 LET p_cod_lin_negocio  = NULL
 LET l_cod_lin_prod     = NULL
 LET l_cod_lin_recei    = NULL
 LET p_cod_seg_merc = NULL
 LET p_cod_cla_uso  = NULL
 LET p_num_conta = NULL

 CASE
 WHEN infield(cod_area_negocio)
    IF p_par_con.ies_contab_aen = "4" THEN
       IF (p_par_con.area_livre[9,9] = 1 OR
           p_par_con.area_livre[9,9] = 2 OR
           p_par_con.area_livre[9,9] = 3 OR
           p_par_con.area_livre[9,9] = 4) AND
           m_ies_aen_4_niveis = "S" THEN
           CALL trb080_popup_linha_prod()
                RETURNING l_cod_lin_prod, l_cod_lin_recei, p_cod_seg_merc, p_cod_cla_uso
       ELSE
           CALL vdp035_popup_linha_prod()
                RETURNING l_cod_lin_prod, l_cod_lin_recei, p_cod_seg_merc, p_cod_cla_uso
       END IF
       IF l_cod_lin_prod IS NOT NULL THEN
          CURRENT WINDOW IS w_sup02901
          LET p_area[p_ind_arr].cod_area_negocio = l_cod_lin_prod
          LET p_area[p_ind_arr].cod_lin_negocio  = l_cod_lin_recei
          LET p_area[p_ind_arr].cod_seg_merc     = p_cod_seg_merc
          LET p_area[p_ind_arr].cod_cla_uso      = p_cod_cla_uso
          DISPLAY p_area[p_ind_arr].cod_area_negocio TO s_area[p_ind1].cod_area_negocio
          DISPLAY p_area[p_ind_arr].cod_lin_negocio  TO s_area[p_ind1].cod_lin_negocio
          DISPLAY p_area[p_ind_arr].cod_seg_merc     TO s_area[p_ind1].cod_seg_merc
          DISPLAY p_area[p_ind_arr].cod_cla_uso      TO s_area[p_ind1].cod_cla_uso
       END IF
    ELSE
       IF (p_par_con.area_livre[9,9] = 1 OR
           p_par_con.area_livre[9,9] = 2 OR
           p_par_con.area_livre[9,9] = 3 OR
           p_par_con.area_livre[9,9] = 4) AND
           m_ies_aen_4_niveis = "S" THEN
           CALL trb080_popup_linha_prod()
                RETURNING l_cod_lin_prod, l_cod_lin_recei, p_cod_seg_merc, p_cod_cla_uso
           IF l_cod_lin_prod IS NOT NULL THEN
              CURRENT WINDOW IS w_sup02901
              LET p_area[p_ind_arr].cod_area_negocio = l_cod_lin_prod
              LET p_area[p_ind_arr].cod_lin_negocio  = l_cod_lin_recei
              LET p_area[p_ind_arr].cod_seg_merc     = p_cod_seg_merc
              LET p_area[p_ind_arr].cod_cla_uso      = p_cod_cla_uso
              DISPLAY p_area[p_ind_arr].cod_area_negocio TO s_area[p_ind1].cod_area_negocio
              DISPLAY p_area[p_ind_arr].cod_lin_negocio  TO s_area[p_ind1].cod_lin_negocio
              DISPLAY p_area[p_ind_arr].cod_seg_merc     TO s_area[p_ind1].cod_seg_merc
              DISPLAY p_area[p_ind_arr].cod_cla_uso      TO s_area[p_ind1].cod_cla_uso
           END IF
       ELSE
          LET p_cod_area_negocio = sup128_popup_area_negocio(p_cod_empresa)
          IF p_cod_area_negocio IS NOT NULL THEN
             CURRENT WINDOW IS w_sup02901
             LET p_area[p_ind_arr].cod_area_negocio = p_cod_area_negocio
             DISPLAY p_area[p_ind_arr].cod_area_negocio TO s_area[p_ind1].cod_area_negocio
          END IF
       END IF
    END IF

 WHEN infield(cod_lin_negocio)
    IF p_par_con.ies_contab_aen = "S" THEN
       IF (p_par_con.area_livre[9,9] = 1 OR
           p_par_con.area_livre[9,9] = 2 OR
           p_par_con.area_livre[9,9] = 3 OR
           p_par_con.area_livre[9,9] = 4) AND
           m_ies_aen_4_niveis = "S" THEN
           CALL trb080_popup_linha_prod()
                RETURNING l_cod_lin_prod, l_cod_lin_recei, p_cod_seg_merc, p_cod_cla_uso
           IF l_cod_lin_prod IS NOT NULL THEN
              CURRENT WINDOW IS w_sup02901
              LET p_area[p_ind_arr].cod_area_negocio = l_cod_lin_prod
              LET p_area[p_ind_arr].cod_lin_negocio  = l_cod_lin_recei
              LET p_area[p_ind_arr].cod_seg_merc     = p_cod_seg_merc
              LET p_area[p_ind_arr].cod_cla_uso      = p_cod_cla_uso
              DISPLAY p_area[p_ind_arr].cod_area_negocio TO s_area[p_ind1].cod_area_negocio
              DISPLAY p_area[p_ind_arr].cod_lin_negocio  TO s_area[p_ind1].cod_lin_negocio
              DISPLAY p_area[p_ind_arr].cod_seg_merc     TO s_area[p_ind1].cod_seg_merc
              DISPLAY p_area[p_ind_arr].cod_cla_uso      TO s_area[p_ind1].cod_cla_uso
           END IF
       ELSE
          LET p_cod_lin_negocio = sup374_popup_area_lin_negocio(p_cod_empresa, p_area[p_ind_arr].cod_area_negocio)
          IF p_cod_lin_negocio IS NOT NULL THEN
             CURRENT WINDOW IS w_sup02901
             LET p_area[p_ind_arr].cod_lin_negocio    = p_cod_lin_negocio
             DISPLAY p_area[p_ind_arr].cod_lin_negocio TO s_area[p_ind1].cod_lin_negocio
          END IF
       END IF
    END IF
 END CASE
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_sup02901
 LET int_flag = 0
END FUNCTION

#--------------------------------------#
 FUNCTION sup029_verifica_componentes()
#--------------------------------------#
 DEFINE p_comp  SMALLINT

 LET p_comp = 0
 WHENEVER ERROR CONTINUE
 SELECT COUNT(*)
   INTO p_comp
   FROM estrut_ordem_sup
  WHERE estrut_ordem_sup.cod_empresa = p_cod_empresa
    AND estrut_ordem_sup.num_oc      = gr_dados_tela_com.num_oc
 WHENEVER ERROR STOP
 IF p_comp > 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------#
 FUNCTION sup029_verifica_estrutura()
#------------------------------------#
 DEFINE l_cont SMALLINT

 LET l_cont = 0

 IF p_par_logix.parametros[61,61] = "S" THEN
    WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_cont
      FROM estrut_grade
     WHERE estrut_grade.cod_empresa  = p_cod_empresa
       AND estrut_grade.cod_item_pai = gr_dados_tela_com.cod_item
    WHENEVER ERROR STOP
 ELSE
    WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_cont
      FROM estrutura
     WHERE estrutura.cod_empresa  = p_cod_empresa
       AND estrutura.cod_item_pai = gr_dados_tela_com.cod_item
    WHENEVER ERROR STOP
 END IF

 IF l_cont = 0 OR l_cont IS NULL THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#-----------------------------------------#
 FUNCTION sup029_verifica_cod_uni_funcio()
#-----------------------------------------#
 DEFINE l_sql_stmt     CHAR(1000)

 LET l_sql_stmt = "SELECT den_uni_funcio ",
                  "  FROM uni_funcional "

 IF m_unid_func_todas_empresas = "N" THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED,
                  " WHERE uni_funcional.cod_empresa    = """,gr_dados_tela_com.cod_empresa,""" "
 ELSE
    LET l_sql_stmt = l_sql_stmt CLIPPED,
                  " WHERE 1=1 "
 END IF
 LET l_sql_stmt = l_sql_stmt CLIPPED,
                  "   AND uni_funcional.cod_uni_funcio = """,gr_dados_tela_com.cod_uni_funcio, """ ",
                  "   AND uni_funcional.dat_validade_fim > CURRENT YEAR TO SECOND "

 WHENEVER ERROR CONTINUE
 PREPARE var_query1 FROM l_sql_stmt
 DECLARE cl_empresa CURSOR FOR var_query1
 OPEN cl_empresa
 FETCH cl_empresa
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION sup029_verifica_centra_emp_sup()
#-----------------------------------------#
  IF NOT m_possui_centraliz THEN
     RETURN TRUE
  END IF

  WHENEVER ERROR CONTINUE
  SELECT * FROM centraliz_emp_sup
   WHERE centraliz_emp_sup.cod_empresa = gr_dados_tela_com.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     ERROR "Empresa nao cadastrada na tabela CENTRALIZ_EMP_SUP"
     RETURN FALSE
  END IF
  RETURN TRUE
 END FUNCTION

#----------------------------------------------------------#
 FUNCTION sup029_pesq_td_compl(p_empresa,p_cod_tip_despesa)
#----------------------------------------------------------#
  DEFINE p_empresa         LIKE empresa.cod_empresa,
         p_cod_tip_despesa LIKE ordem_sup.cod_tip_despesa,
         p_ies_ativo       CHAR(01)

  LET p_ies_ativo = "S"

  WHENEVER ERROR CONTINUE
  SELECT ies_ativo INTO p_ies_ativo
    FROM tipo_despesa_compl
   WHERE cod_empresa     = p_empresa
     AND cod_tip_despesa = p_cod_tip_despesa
  WHENEVER ERROR STOP

  IF p_ies_ativo = "N" THEN
     RETURN FALSE
  ELSE
     RETURN TRUE
  END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION sup029_verifica_emergencia()
#-------------------------------------#
  IF p_ordem_sup.dat_abertura_oc < p_ordem_sup.dat_emis THEN
     IF NOT g_ies_grafico THEN
        DISPLAY " EMERGÊNCIA " AT 11,30 ATTRIBUTE(REVERSE)
     ELSE
        CALL log4050_altera_atributo("emerg","text","EMERGÊNCIA")
     END IF
  ELSE
     IF NOT g_ies_grafico THEN
        DISPLAY "            " AT 11,30
     ELSE
        CALL log4050_altera_atributo("emerg","text","")
     END IF
  END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION sup0290_leitura_parametros()
#-------------------------------------#

  INITIALIZE m_verif_comp TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"altera_comprador_oc") RETURNING m_verif_comp, m_status
  IF m_status = FALSE OR m_verif_comp IS NULL OR m_verif_comp = " " THEN
     LET m_verif_comp = "S"
  END IF

  #730768#
  INITIALIZE m_ies_bloqueia_oc_igual_zero TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"ies_bloqueia_oc_igual_zero")
     RETURNING m_ies_bloqueia_oc_igual_zero, m_status
  IF m_status = FALSE OR
     m_ies_bloqueia_oc_igual_zero IS NULL OR
     m_ies_bloqueia_oc_igual_zero = " "   THEN
     LET m_ies_bloqueia_oc_igual_zero = "N"
  END IF
  #---fim--- 730768#

  INITIALIZE m_informa_val_previsto TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"informa_val_previsto_sup0290") RETURNING m_informa_val_previsto, m_status
  IF m_status = FALSE OR m_informa_val_previsto IS NULL OR m_informa_val_previsto = " " THEN
     LET m_informa_val_previsto = "N"
  END IF

  INITIALIZE p_par_sup_compl.* TO NULL
  SELECT * INTO p_par_sup_compl.*
    FROM par_sup_compl
   WHERE cod_empresa = p_cod_empresa

  INITIALIZE p_ies_sup0301 TO NULL
  SELECT par_ies INTO p_ies_sup0301
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_sup0301"
  IF sqlca.sqlcode <> 0 OR p_ies_sup0301 IS NULL OR p_ies_sup0301 = "  " THEN
     LET p_ies_sup0301 = "N"
  END IF

  INITIALIZE p_par_con.* TO NULL
  SELECT * INTO p_par_con.*
    FROM par_con
   WHERE cod_empresa = p_cod_empresa

  INITIALIZE p_ies_inf_fisc_item_oc TO NULL
  SELECT par_ies INTO p_ies_inf_fisc_item_oc
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_inf_fisc_item_oc"
  IF sqlca.sqlcode <> 0
  OR p_ies_inf_fisc_item_oc IS NULL OR p_ies_inf_fisc_item_oc = " " THEN
     LET p_ies_inf_fisc_item_oc = "N"
  END IF

  INITIALIZE g_ies_considera_mult TO NULL
  SELECT par_ies INTO g_ies_considera_mult
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_considera_mult"
  IF sqlca.sqlcode <> 0
  OR g_ies_considera_mult IS NULL OR g_ies_considera_mult = " " THEN
     LET g_ies_considera_mult = "N"
  END IF

  INITIALIZE m_ies_excl_aberta TO NULL
  SELECT par_ies INTO m_ies_excl_aberta
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_excl_oc_aberta"
  IF sqlca.sqlcode <> 0 OR m_ies_excl_aberta IS NULL OR m_ies_excl_aberta = " " THEN
     LET m_ies_excl_aberta = "N"
  END IF

  INITIALIZE p_ies_oc_planejada TO NULL
  SELECT par_ies INTO p_ies_oc_planejada
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_oc_planejada"
  IF sqlca.sqlcode <> 0 OR p_ies_oc_planejada IS NULL OR p_ies_oc_planejada = " " THEN
     LET p_ies_oc_planejada = "N"
  END IF

  # OS 66954 (Daniella)
  INITIALIZE g_ies_conta_item TO NULL
  SELECT par_ies INTO g_ies_conta_item
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_conta_item"
  IF sqlca.sqlcode <> 0 OR g_ies_conta_item IS NULL OR g_ies_conta_item = " " THEN
     LET g_ies_conta_item = "N"
  END IF

  INITIALIZE p_par_logix.* TO NULL
  SELECT * INTO p_par_logix.*
    FROM par_logix
   WHERE cod_empresa = p_cod_empresa
  IF sqlca.sqlcode <> 0 THEN
     LET p_par_logix.parametros[61,61] = "N"
  END IF

  INITIALIZE m_ies_ajuste_data_oc TO NULL
  SELECT par_ies INTO m_ies_ajuste_data_oc
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_ajuste_data_oc"
  IF sqlca.sqlcode <> 0
  OR m_ies_ajuste_data_oc IS NULL OR m_ies_ajuste_data_oc = " " THEN
     LET m_ies_ajuste_data_oc = "N"
  END IF

  LET p_ies_uni_funcio = sup029_busca_par_sup_pad("ies_uni_funcional",1)
  IF p_ies_uni_funcio IS NULL OR p_ies_uni_funcio = " " THEN
     LET p_ies_uni_funcio = "N"
  END IF

  INITIALIZE p_ies_item_prod_oc TO NULL
  SELECT par_ies INTO p_ies_item_prod_oc
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_item_prod_oc"
  IF sqlca.sqlcode <> 0
  OR p_ies_item_prod_oc = " " OR p_ies_item_prod_oc IS NULL THEN
     LET p_ies_item_prod_oc = "N"
  END IF

  INITIALIZE p_ies_incid_benef TO NULL
  SELECT par_ies INTO p_ies_incid_benef
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "incidencia_benef"

  INITIALIZE mr_usuario.* TO NULL
  SELECT cod_progr INTO mr_usuario.cod_progr
    FROM programador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user

  SELECT cod_comprador INTO mr_usuario.cod_comprador
    FROM comprador
   WHERE cod_empresa = p_cod_empresa
     AND login       = p_user

  SELECT par_sup_pad.par_num
    INTO m_lin_consig
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "lin_consig"
  IF sqlca.sqlcode <> 0 OR
     m_lin_consig IS NULL THEN
     LET m_lin_consig = 3
  END IF

  SELECT par_sup_pad.par_num
    INTO m_col_consig
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "col_consig"
  IF sqlca.sqlcode <> 0 OR
     m_col_consig IS NULL THEN
     LET m_col_consig = 5
  END IF

  INITIALIZE m_ies_dat_retro TO NULL
  SELECT par_ies INTO m_ies_dat_retro
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_dat_retro_prog"
  IF sqlca.sqlcode <> 0 OR m_ies_dat_retro IS NULL OR m_ies_dat_retro = " " THEN
     LET m_ies_dat_retro = "N"
  END IF

#OS 153405
  INITIALIZE m_ies_aen_4_niveis TO NULL
  SELECT par_ies INTO m_ies_aen_4_niveis
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "ies_aen_4_niveis"
  IF m_ies_aen_4_niveis IS NULL OR m_ies_aen_4_niveis = " " THEN
     LET m_ies_aen_4_niveis = "N"
  END IF
#FIM OS 153405

  INITIALIZE m_valid_fim TO NULL
  IF sup0686_cod_fiscal_tem_dat_fim_valid() THEN
     LET m_valid_fim = TRUE
  ELSE
     LET m_valid_fim = FALSE
  END IF

  LET m_dat_fim_valid = MDY("12","31","2002")
  SELECT par_data INTO m_dat_fim_valid
    FROM par_sup_pad
   WHERE cod_empresa   = p_cod_empresa
     AND cod_parametro = "dat_fim_valid"
  IF sqlca.sqlcode <> 0 OR m_dat_fim_valid IS NULL THEN
     LET m_dat_fim_valid = MDY("12","31","2002")
  END IF

  INITIALIZE m_consulta_decres TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"consulta_registro_ordem_decres") RETURNING m_consulta_decres, p_status
  IF p_status = FALSE OR m_consulta_decres IS NULL OR m_consulta_decres = " " THEN
     LET m_consulta_decres = "N"
  END IF

  INITIALIZE m_consid_pct_refugo TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"consid_pct_refugo_carga_compon")
       RETURNING m_consid_pct_refugo, p_status
  IF p_status = FALSE OR
     m_consid_pct_refugo IS NULL OR
     m_consid_pct_refugo = " " THEN
     LET m_consid_pct_refugo = "N"
  END IF

  INITIALIZE m_abre_aut_tela_comp TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"abre_aut_tela_comp")
       RETURNING m_abre_aut_tela_comp, p_status
  IF p_status = FALSE OR
     m_abre_aut_tela_comp IS NULL OR
     m_abre_aut_tela_comp = " " THEN
     LET m_abre_aut_tela_comp = "N"
  END IF
 #563650
  INITIALIZE m_data_lead_time TO NULL #OS 467250
  CALL log2250_busca_parametro(p_cod_empresa,"dt_ent_prev_oc_atual_lead_time")
       RETURNING m_data_lead_time, p_status
  IF p_status = FALSE OR
     m_data_lead_time IS NULL OR
     m_data_lead_time = " " THEN
     LET m_data_lead_time = "N"
  END IF
  #563650

#--inicio--OS704186 Antonio  #
  INITIALIZE m_controla_gao TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_controla_gao
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "controla_gao"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_controla_gao IS NULL OR
     m_controla_gao = " " THEN
     LET m_controla_gao = "N"
  END IF

  INITIALIZE m_usa_cond_pagto TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_usa_cond_pagto
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "usa_cond_pagto"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_usa_cond_pagto IS NULL OR
     m_usa_cond_pagto = " " THEN
     LET m_usa_cond_pagto = "N"
  END IF

  INITIALIZE m_orcamento_periodo TO NULL
  WHENEVER ERROR CONTINUE
  SELECT par_ind_especial
    INTO m_orcamento_periodo
    FROM gao_par_padrao
   WHERE empresa = p_cod_empresa
     AND parametro = "orcamento_periodo"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0
  OR m_orcamento_periodo IS NULL
  OR m_orcamento_periodo = " " THEN
     LET m_orcamento_periodo = "N"
  END IF

  INITIALIZE m_atua_somente_desig TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"atualiz_somente_na_designacao")
       RETURNING m_atua_somente_desig, p_status
  IF p_status = FALSE
  OR m_atua_somente_desig IS NULL
  OR m_atua_somente_desig = " " THEN
     LET m_atua_somente_desig = "N"
  END IF

  #739236
  INITIALIZE m_busca_aen_unidade_funcional TO NULL
  CALL log2250_busca_parametro(p_cod_empresa,"busca_aen_unidade_funcional")
       RETURNING m_busca_aen_unidade_funcional, p_status
  IF p_status = FALSE
  OR m_busca_aen_unidade_funcional IS NULL
  OR m_busca_aen_unidade_funcional = " " THEN
     LET m_busca_aen_unidade_funcional = "N"
  END IF
  #739236


  WHENEVER ERROR CONTINUE
  SELECT par_ies
    INTO m_ies_valor_desig
    FROM par_sup_pad
   WHERE par_sup_pad.cod_empresa   = p_cod_empresa
     AND par_sup_pad.cod_parametro = "ies_valor_desig"
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR
     m_ies_valor_desig = " " OR
     m_ies_valor_desig IS NULL THEN
     LET m_ies_valor_desig = "N"
  END IF
#---fim----OS704186 Antonio   #

  CALL log2250_busca_parametro(p_cod_empresa, "exibir_oc_designada_aprov_tec")
       RETURNING m_exibir_oc_designada_aprov_tec, p_status # 779618

  IF p_status = FALSE OR
     m_exibir_oc_designada_aprov_tec IS NULL OR
     m_exibir_oc_designada_aprov_tec = " " THEN
     LET m_exibir_oc_designada_aprov_tec = "N"
  END IF

 # Inicio chamado 794.492
 CALL log2250_busca_parametro(p_cod_empresa, "unid_func_todas_empresas")
      RETURNING m_unid_func_todas_empresas, p_status

 IF p_status = FALSE OR m_unid_func_todas_empresas IS NULL OR m_unid_func_todas_empresas = " " THEN
    LET m_unid_func_todas_empresas = "N"
 END IF
 # Fim chamado 794.492

 END FUNCTION

#------------------------------------#
 FUNCTION sup0290_acesso_oc(l_funcao)
#------------------------------------#
  DEFINE l_funcao CHAR(11)

  IF NOT sup029_verifica_centra_emp_sup() THEN
     RETURN 0
  END IF

  IF p_ordem_sup.ies_situa_oc = "L" THEN
     LET l_funcao = DOWNSHIFT(l_funcao)
     ERROR "Ordem de compra LIQUIDADA nao permite ",l_funcao
     RETURN 0
  END IF

  IF p_ordem_sup.ies_situa_oc = "C" THEN
     LET l_funcao = DOWNSHIFT(l_funcao)
     ERROR "Ordem de compra CANCELADA nao permite ",l_funcao
     RETURN 0
  END IF

  IF p_ordem_sup.ies_situa_oc = "S" THEN
     LET l_funcao = DOWNSHIFT(l_funcao)
     ERROR "Ordem de compra SUSPENSA nao permite ",l_funcao
     RETURN 0
  END IF

  IF p_ordem_sup.num_pedido > 0 THEN
     IF l_funcao = "EXCLUSAO" THEN
        ERROR "Ordem de compra ligada a pedido. Nao pode ser excluida"
        RETURN 0
     END IF
     IF p_ordem_sup.ies_situa_oc <> "A" THEN
        LET l_funcao = DOWNSHIFT(l_funcao)
        ERROR "Somente ordens ABERTAS ligadas a pedido podem sofrer ",l_funcao
        RETURN 0
     END IF
     #736097#
     IF find4GLFunction('supy62_empresa_55') THEN
        IF supy62_empresa_55() THEN
           IF find4GLFunction('supy62_valida_programador_subst') THEN
              IF NOT supy62_valida_comprador_subst(p_ordem_sup.num_oc, FALSE) THEN
                 IF NOT supy62_valida_programador_subst(p_ordem_sup.cod_empresa, p_ordem_sup.cod_item, p_user, TRUE) THEN
                    RETURN FALSE
                 END IF
              END IF
           END IF
        END IF
     ELSE
        IF mr_usuario.cod_comprador IS NULL THEN
           ERROR "Usuario nao cadastrado como COMPRADOR"
           RETURN 0
        END IF
        IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
           ERROR "Ordem de compra de outro COMPRADOR"
           RETURN 0
        END IF
     END IF
  ELSE
     #736097#
     IF find4GLFunction('supy62_empresa_55') THEN
        IF supy62_empresa_55() THEN
           IF find4GLFunction('supy62_valida_programador_subst') THEN
              IF NOT supy62_valida_comprador_subst(p_ordem_sup.num_oc, FALSE) THEN
                 IF NOT supy62_valida_programador_subst(p_ordem_sup.cod_empresa, p_ordem_sup.cod_item, p_user, TRUE) THEN
                    RETURN FALSE
                 END IF
              END IF
           END IF
        END IF
     ELSE
        CASE gr_dados_tela_com.ies_situa_oc
        WHEN "P"
           IF mr_usuario.cod_progr IS NULL THEN
              ERROR "Usuario nao cadastrado como PROGRAMADOR"
              RETURN 0
           END IF
           IF p_ordem_sup.cod_progr <> mr_usuario.cod_progr THEN
              ERROR "Usuario nao e' PROGRAMADOR desta ordem de compra"
              RETURN 0
           END IF
        WHEN ("D" OR "T")
           IF p_ordem_sup.cod_comprador = mr_usuario.cod_comprador THEN
              RETURN 1
           END IF
           IF  p_ordem_sup.cod_progr = mr_usuario.cod_progr
           AND (l_funcao = "MODIFICACAO" OR l_funcao = "ORCAMENTO") THEN
              RETURN 2
           END IF
           IF mr_usuario.cod_comprador IS NULL THEN
              ERROR "Usuario nao cadastrado como COMPRADOR"
              RETURN 0
           END IF
           IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
              IF l_funcao = "ORCAMENTO" THEN
                 IF p_ordem_sup.cod_progr <> mr_usuario.cod_progr THEN
                    ERROR "Ordem de compra de outro COMPRADOR/PROGRAMADOR"
                    RETURN 0
                 ELSE
                    ERROR "Ordem de compra de outro COMPRADOR"
                    RETURN 0
                 END IF
              ELSE
                 ERROR "Ordem de compra de outro COMPRADOR"
                 RETURN 0
              END IF
           END IF
        WHEN "A"
           #apos designacao do fornecedor somente o comprador
           #podera' modificar a ordem de compra
           IF p_ordem_sup.cod_fornecedor = " " THEN
              IF m_ies_excl_aberta = "S" THEN
                 IF  (mr_usuario.cod_progr IS NULL
                 OR   p_ordem_sup.cod_progr     <> mr_usuario.cod_progr)
                 AND (mr_usuario.cod_comprador IS NULL
                 OR   p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador) THEN
                    ERROR "Ordem de compra de outro PROGRAMADOR/COMPRADOR"
                    RETURN 0
                 END IF
              ELSE
                 IF p_ordem_sup.cod_comprador = mr_usuario.cod_comprador THEN
                    RETURN 1
                 END IF
                 IF  p_ordem_sup.cod_progr = mr_usuario.cod_progr
                 AND l_funcao = "MODIFICACAO" THEN
                    RETURN 2
                 END IF
                 IF mr_usuario.cod_comprador IS NULL
                 OR p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                    ERROR "Ordem de compra de outro COMPRADOR"
                    RETURN 0
                 END IF
              END IF
           ELSE
              IF p_ordem_sup.cod_comprador = mr_usuario.cod_comprador THEN
                 RETURN 1
              END IF
              IF  p_ordem_sup.cod_progr = mr_usuario.cod_progr
              AND l_funcao = "MODIFICACAO" THEN
                 RETURN 2
              END IF
              IF mr_usuario.cod_comprador IS NULL THEN
                 ERROR "Usuario nao cadastrado como COMPRADOR"
                 RETURN 0
              END IF
              IF p_ordem_sup.cod_comprador <> mr_usuario.cod_comprador THEN
                 ERROR "Ordem de compra de outro COMPRADOR"
                 RETURN 0
              END IF
           END IF
        END CASE
     END IF
  END IF
  RETURN 1
 END FUNCTION

#-----------------------------------------------------------------------#
 FUNCTION sup0290_item_controle_estoque_fisico(l_cod_empresa,l_cod_item)
#-----------------------------------------------------------------------#
  DEFINE l_cod_empresa LIKE empresa.cod_empresa,
         l_cod_item    CHAR(15),
         l_ies_ctr     CHAR(01)

  LET l_ies_ctr = NULL
  SELECT parametros[17] INTO l_ies_ctr
    FROM item_parametro
   WHERE cod_empresa = l_cod_empresa
     AND cod_item    = l_cod_item
  IF l_ies_ctr = "S" THEN
     RETURN TRUE
  END IF
  RETURN FALSE
 END FUNCTION

#------------------------------------#
 FUNCTION sup0290_sistema_argentino()
#------------------------------------#
  DEFINE l_char CHAR(01)

  LET l_char = "N"
  SELECT parametros[76,76] INTO l_char
    FROM par_logix
   WHERE par_logix.cod_empresa = p_cod_empresa

  RETURN (l_char = "S")
 END FUNCTION

#------------------------------------------#
 FUNCTION sup029_verifica_oc_centralizada()
#------------------------------------------#
 DEFINE l_contador       SMALLINT

 IF p_ordem_sup.num_pedido = 0 THEN
    RETURN FALSE
 END IF

 LET l_contador = NULL

 SELECT COUNT(*)
   INTO l_contador
   FROM sup_ped_com_cetl
  WHERE sup_ped_com_cetl.emp_relacionada    = p_ordem_sup.cod_empresa
    AND sup_ped_com_cetl.pedido_relacionado = p_ordem_sup.num_pedido

 IF sqlca.sqlcode <> 0 OR
    l_contador IS NULL THEN
    LET l_contador = 0
 END IF

 IF l_contador > 0 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#------------------------------------#
 FUNCTION sup0290_atualiza_oc_benef()
#------------------------------------#
  WHENEVER ERROR CONTINUE
  IF p_ies_incid_benef <> " " THEN
     IF p_ies_incid_benef = "I" THEN
        LET p_ordem_sup.pct_ipi = 0
     END IF
     ### Tabela COD_FISCAL_SUP ja convertida
     IF  m_valid_fim
     AND p_ordem_sup.dat_entrega_prev > m_dat_fim_valid THEN
        UPDATE ordem_sup
           SET ies_tip_incid_ipi  = p_ies_incid_benef,
               ies_tip_incid_icms = p_ies_incid_benef,
               pct_ipi            = p_ordem_sup.pct_ipi,
               cod_fiscal         = "124"
         WHERE cod_empresa      = p_cod_empresa
           AND num_oc           = p_ordem_sup.num_oc
           AND ies_versao_atual = "S"
     ELSE
        UPDATE ordem_sup
           SET ies_tip_incid_ipi  = p_ies_incid_benef,
               ies_tip_incid_icms = p_ies_incid_benef,
               pct_ipi            = p_ordem_sup.pct_ipi,
               cod_fiscal         = "13"
         WHERE cod_empresa      = p_cod_empresa
           AND num_oc           = p_ordem_sup.num_oc
           AND ies_versao_atual = "S"
     END IF
  ELSE
     SELECT ies_tip_incid_ipi,
            ies_tip_incid_icms,
            cod_fiscal
       INTO p_ordem_sup.ies_tip_incid_ipi,
            p_ordem_sup.ies_tip_incid_icms,
            p_ordem_sup.cod_fiscal
       FROM item_sup
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = p_ordem_sup.cod_item

     IF p_ordem_sup.ies_tip_incid_ipi = "I" THEN
        LET p_ordem_sup.pct_ipi = 0
     END IF

     UPDATE ordem_sup
        SET ies_tip_incid_ipi  = p_ordem_sup.ies_tip_incid_ipi,
            ies_tip_incid_icms = p_ordem_sup.ies_tip_incid_icms,
            pct_ipi            = p_ordem_sup.pct_ipi,
            cod_fiscal         = p_ordem_sup.cod_fiscal
      WHERE cod_empresa      = p_cod_empresa
        AND num_oc           = p_ordem_sup.num_oc
        AND ies_versao_atual = "S"

  END IF
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("MODIFICACAO","ORDEM_SUP")
  END IF
 END FUNCTION

#-------------------------------------#
 FUNCTION sup0290_oc_com_recebimento()
#-------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT qtd_recebida
   FROM aviso_rec
  WHERE cod_empresa  = p_cod_empresa
    AND num_oc       = p_ordem_sup.num_oc
    AND qtd_recebida > 0
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR
    sqlca.sqlcode = -284 THEN
    RETURN TRUE
 END IF

 RETURN FALSE
 END FUNCTION

#----------------------------------------------------#
 FUNCTION sup0290_verifica_item_integracao(l_cod_item)
#----------------------------------------------------#
 DEFINE l_cod_item        LIKE item.cod_item,
        l_bloqueio_ativo  CHAR(01),
        l_integracao      CHAR(01)

 INITIALIZE l_bloqueio_ativo TO NULL

 CALL log2250_busca_parametro(p_cod_empresa,"integr_logix_webb_ativa") RETURNING l_integracao, p_status

 IF p_status = FALSE OR
    l_integracao IS NULL OR
    l_integracao = " " THEN
    LET l_integracao = "S"
 END IF

 IF p_status = TRUE THEN
    IF l_integracao = 'S' THEN
       WHENEVER ERROR CONTINUE
       SELECT bloqueio_ativo
         INTO l_bloqueio_ativo
         FROM sup_item_integr_55
        WHERE empresa     = p_cod_empresa
          AND item_integr = l_cod_item
       WHENEVER ERROR STOP

       IF SQLCA.sqlcode <> 0 THEN
          RETURN FALSE
       END IF

       IF l_bloqueio_ativo = 'S' THEN
          RETURN TRUE
       ELSE
          RETURN FALSE
       END IF
    END IF
 END IF

 RETURN FALSE
 END FUNCTION

#--inicio--vanderlei OS 384141 #
#---------------------------------------------------------------#
 FUNCTION sup0290_item_industr_ctr_cust_n_produt(l_cod_item,
                                                 l_num_oc,
                                                 l_gru_ctr_desp,
                                                 l_dat_emis)
#---------------------------------------------------------------#
 DEFINE l_cod_item              LIKE item.cod_item,
        l_num_oc                LIKE ordem_sup.num_oc,
        l_dat_emis              LIKE ordem_sup.dat_emis,
        l_gru_ctr_desp          LIKE grupo_ctr_desp.gru_ctr_desp,
        l_cent_custo            LIKE cad_cc.cod_cent_cust

 #-- Verifica se o centro de custo não é Produtivo --#
 IF NOT sup0290_busca_centr_custo(l_num_oc, l_dat_emis) THEN
    RETURN FALSE
 END IF

 #-- Verifica se é grupo de despesa industrializado --#
 WHENEVER ERROR CONTINUE
 SELECT gru_ctr_desp
   FROM grupo_ctr_desp
  WHERE cod_empresa     = p_cod_empresa
    AND gru_ctr_desp    = l_gru_ctr_desp
    AND ies_obj_entrada = '1'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode != 0 THEN
    IF sqlca.sqlcode != 100 THEN
       CALL log003_err_sql("LEITURA","GRUPO_CTR_DESP")
    END IF
    RETURN FALSE
 END IF

 RETURN TRUE
 END FUNCTION

#-------------------------------------------------------#
 FUNCTION sup0290_busca_centr_custo(l_num_oc,l_dat_emis)
#-------------------------------------------------------#
 DEFINE l_num_oc                LIKE ordem_sup.num_oc,
        l_dat_emis              LIKE ordem_sup.dat_emis,
        l_num_conta_deb_desp    LIKE dest_ordem_sup.num_conta_deb_desp,
        l_cod_secao_receb       LIKE dest_ordem_sup.cod_secao_receb,
        lr_plano_contas         RECORD LIKE plano_contas.*,
        l_ies_mao_obra          LIKE par_con.ies_mao_obra,
        l_cent_custo            LIKE cad_cc.cod_cent_cust,
        l_cent_cust_ok          SMALLINT

 WHENEVER ERROR CONTINUE
 DECLARE cq_dest_ordem_sup CURSOR FOR
 SELECT num_conta_deb_desp,
        cod_secao_receb
   FROM dest_ordem_sup
  WHERE cod_empresa = p_cod_empresa
    AND num_oc      = l_num_oc
 WHENEVER ERROR STOP
 IF sqlca.sqlcode != 0 THEN
    CALL log003_err_sql("LEITURA","DEST_ORDEM_SUP")
 END IF

 LET l_cent_cust_ok = 0

 WHENEVER ERROR CONTINUE
 FOREACH cq_dest_ordem_sup INTO l_num_conta_deb_desp,
                                l_cod_secao_receb
    IF sqlca.sqlcode != 0 THEN
       CALL log003_err_sql("FOREACH","CQ_DEST_ORDEM_SUP")
       EXIT FOREACH
    END IF

    INITIALIZE l_cent_custo TO NULL
    IF (l_cod_secao_receb IS NOT NULL AND l_cod_secao_receb != " ") THEN
       WHENEVER ERROR CONTINUE
       SELECT cod_centro_custo
         INTO l_cent_custo
         FROM uni_funcional
        WHERE cod_empresa      = p_cod_empresa
          AND cod_uni_funcio   = l_cod_secao_receb
          AND dat_validade_fim > CURRENT YEAR TO SECOND
       WHENEVER ERROR STOP
       IF sqlca.sqlcode != 0 AND sqlca.sqlcode != 100 THEN
          CALL log003_err_sql("LEITURA","UNI_FUNCIONAL")
          EXIT FOREACH
       END IF
    ELSE
       CALL con088_verifica_cod_conta(p_cod_empresa,
                                      l_num_conta_deb_desp,
                                      "S",TODAY)
                                      RETURNING lr_plano_contas.*, p_status

       IF lr_plano_contas.ies_tip_conta = 8 THEN
          WHENEVER ERROR CONTINUE
          SELECT ies_mao_obra
            INTO l_ies_mao_obra
            FROM par_con
           WHERE par_con.cod_empresa = p_cod_empresa
          WHENEVER ERROR STOP
          IF sqlca.sqlcode != 0 AND sqlca.sqlcode != 100 THEN
             CALL log003_err_sql("LEITURA","PAR_CON")
             EXIT FOREACH
          END IF

          IF l_ies_mao_obra = "S" THEN
             LET l_cent_custo = lr_plano_contas.num_conta_reduz[3,6]
          ELSE
             LET l_cent_custo = lr_plano_contas.num_conta_reduz[1,4]
          END IF
       END IF
    END IF

    WHENEVER ERROR CONTINUE
    SELECT cod_cent_cust
      FROM cad_cc
     WHERE cod_empresa     =  p_cod_empresa
       AND cod_cent_cust   =  l_cent_custo
       AND ies_cod_versao  =  0
       AND ies_tipo_cc     <> 'P'
    WHENEVER ERROR STOP
    IF sqlca.sqlcode != 0 THEN
       IF sqlca.sqlcode != 100 THEN
          CALL log003_err_sql("LEITURA","CAD_CC")
       END IF
       LET l_cent_cust_ok = 0
    ELSE
       LET l_cent_cust_ok = 1
       EXIT FOREACH
    END IF

 END FOREACH
 WHENEVER ERROR STOP
 FREE cq_dest_ordem_sup

 RETURN l_cent_cust_ok
 END FUNCTION
#---fim----vanderlei OS 384141 #

#------------------------------------------#
 FUNCTION sup0290_verifica_integracao_webb()
#------------------------------------------#

 WHENEVER ERROR CONTINUE
 SELECT empresa
   FROM sup_par_oc
  WHERE empresa       = p_ordem_sup.cod_empresa
    AND parametro     = 'oc_gerada_webb'
    AND seq_parametro = 1
    AND ordem_compra  = p_ordem_sup.num_oc
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 OR sqlca.sqlcode = -284 THEN
    RETURN FALSE
 ELSE
    RETURN TRUE
 END IF

 END FUNCTION

#----------------------------------------------#
 FUNCTION sup0290_busca_valor_previsto(l_num_oc)
#----------------------------------------------#
 DEFINE l_num_oc       LIKE ordem_sup.num_oc,
        l_val_previsto LIKE ordem_sup_txt.tex_observ_oc

 WHENEVER ERROR CONTINUE
 SELECT tex_observ_oc
   INTO l_val_previsto
   FROM ordem_sup_txt
  WHERE cod_empresa   = p_cod_empresa
    AND num_oc        = l_num_oc
    AND ies_tip_texto = "K"
    AND num_seq       = 1
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_val_previsto = '0'
 END IF

 RETURN l_val_previsto
END FUNCTION

#---------------------------------------------------------------#
 FUNCTION sup0290_insere_valor_previsto(l_num_oc, l_val_previsto)
#---------------------------------------------------------------#
 DEFINE l_num_oc       LIKE ordem_sup.num_oc,
        l_val_previsto LIKE ordem_sup.pre_unit_oc

 WHENEVER ERROR CONTINUE
 SELECT cod_empresa
   FROM ordem_sup_txt
  WHERE cod_empresa   = p_cod_empresa
    AND num_oc        = l_num_oc
    AND ies_tip_texto = "K"
    AND num_seq       = 1
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
    UPDATE ordem_sup_txt
       SET tex_observ_oc = l_val_previsto
     WHERE cod_empresa   = p_cod_empresa
       AND num_oc        = l_num_oc
       AND ies_tip_texto = "K"
       AND num_seq       = 1
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("MODIFICACAO","ORDEM_SUP_TXT")
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
    INSERT INTO ordem_sup_txt (cod_empresa,
                               num_oc,
                               ies_tip_texto,
                               num_seq,
                               tex_observ_oc)
                       VALUES (p_cod_empresa,
                               l_num_oc,
                               "K",
                               1,
                               l_val_previsto)
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INCLUSAO","ORDEM_SUP_TXT")
    END IF
 END IF

END FUNCTION

#--------------------------------------------#
 FUNCTION sup0290_busca_item_custo(l_cod_item)
#--------------------------------------------#
 DEFINE l_cod_item     LIKE item.cod_item,
        l_preco        LIKE item_custo.cus_unit_medio

 WHENEVER ERROR CONTINUE
 SELECT cus_unit_medio
   INTO l_preco
   FROM item_custo
  WHERE cod_empresa = p_cod_empresa
    AND cod_item    = l_cod_item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
 END IF

 IF l_preco IS NULL OR
    l_preco = 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT item_sup.pre_unit_ult_compr
      INTO l_preco
      FROM item_sup
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = l_cod_item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       LET l_preco = 0
    END IF
 END IF

 RETURN l_preco
 END FUNCTION

#---------------------------------------#
 FUNCTION sup0290_seleciona_des_rateio()
#---------------------------------------#

  DEFINE la_des_rateio ARRAY[500] OF RECORD
                         sequencia  SMALLINT,
                         des_rateio LIKE sup_part_item_aen.des_rateio
                       END RECORD

  DEFINE l_ind         SMALLINT,
         l_arr_curr    SMALLINT

  INITIALIZE la_des_rateio TO NULL

  WHENEVER ERROR CONTINUE
   DECLARE cq_des_rateio CURSOR WITH HOLD FOR
    SELECT UNIQUE sup_part_item_aen.des_rateio
      FROM sup_part_item_aen
     WHERE sup_part_item_aen.empresa = gr_dados_tela_com.cod_empresa
       AND sup_part_item_aen.item    = gr_dados_tela_com.cod_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql('DECLARE','CQ_DES_RATEIO')
     END IF

     RETURN FALSE
  END IF

  LET l_ind = 1

  WHENEVER ERROR CONTINUE
   FOREACH cq_des_rateio INTO la_des_rateio[l_ind].des_rateio
      IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode <> 100 THEN
            CALL log003_err_sql('FOREACH CURSOR','CQ_DES_RATEIO')
         END IF

         RETURN FALSE
      END IF

      LET la_des_rateio[l_ind].sequencia = l_ind
      LET l_ind = l_ind + 1
      IF l_ind > 500 THEN
         EXIT FOREACH
      END IF
   END FOREACH
  WHENEVER ERROR STOP

  IF l_ind > 1 THEN
     CALL log130_procura_caminho("sup0290e") RETURNING comando
     OPEN WINDOW w_sup0290e AT 7,20 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, COMMENT LINE LAST)

     CALL set_count(l_ind - 1)
     DISPLAY ARRAY la_des_rateio TO sr_des_rateio.*

     LET l_arr_curr = arr_curr()

     CLOSE WINDOW w_sup0290e

     CURRENT WINDOW IS w_sup02901

     IF int_flag THEN
        LET int_flag = 0
        RETURN FALSE
     ELSE
        IF la_des_rateio[l_arr_curr].des_rateio IS NULL
        OR la_des_rateio[l_arr_curr].des_rateio = " " THEN
           RETURN FALSE
        ELSE
           LET m_des_rateio = la_des_rateio[l_arr_curr].des_rateio
           RETURN TRUE
        END IF
     END IF
  END IF

  RETURN FALSE

END FUNCTION

#--------------------------------#
 FUNCTION sup0290_carrega_array()
#--------------------------------#

  DEFINE l_ind SMALLINT

  LET l_ind = 1

  WHENEVER ERROR CONTINUE
   DECLARE cq_sup_part_item_aen SCROLL CURSOR FOR
    SELECT sup_part_item_aen.secao_recebimento,
           sup_part_item_aen.conta_ctbl,
           sup_part_item_aen.area_negocio,
           sup_part_item_aen.linha_negocio,
           sup_part_item_aen.segmento_mercado,
           sup_part_item_aen.classe_uso,
           sup_part_item_aen.pct_participacao
      FROM sup_part_item_aen
     WHERE sup_part_item_aen.empresa    = gr_dados_tela_com.cod_empresa
       AND sup_part_item_aen.item       = gr_dados_tela_com.cod_item
       AND sup_part_item_aen.des_rateio = m_des_rateio
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('DECLARE','CQ_SUP_PART_ITEM_AEN')
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_sup_part_item_aen INTO ma_secao_recebimento[l_ind],
                                     p_area[l_ind].num_conta,
                                     p_area[l_ind].cod_area_negocio,
                                     p_area[l_ind].cod_lin_negocio,
                                     p_area[l_ind].cod_seg_merc,
                                     p_area[l_ind].cod_cla_uso,
                                     p_area[l_ind].pct_particip_comp
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FOREACH","CQ_SUP_PART_ITEM_AEN")
         LET l_ind = l_ind - 1
      END IF

      LET p_area[l_ind].seq = l_ind
      LET l_ind = l_ind + 1
   END FOREACH
  WHENEVER ERROR STOP

END FUNCTION
#------------------------------------------#
FUNCTION sup0290_busca_lead_time(l_cod_item)
#------------------------------------------#
DEFINE l_cod_item            LIKE item.cod_item,
       l_lead_time           DATE,
       l_status              SMALLINT

 LET gr_dados_tela_com.dat_entrega_prev =  TODAY + p_lead_time UNITS DAY
 LET l_status = FALSE

 WHILE NOT l_status
    CALL sup029_verifica_data_valida()
       RETURNING l_status
    IF l_status = FALSE THEN
       LET gr_dados_tela_com.dat_entrega_prev = gr_dados_tela_com.dat_entrega_prev + 1 UNITS DAY
    END IF
 END WHILE

END FUNCTION

