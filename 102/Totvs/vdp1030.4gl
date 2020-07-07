###PARSER-N�o remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP1030                                               #
# MODULOS.: VDP1030 - LOG0010 - LOG0030 - LOG0050 - LOG0060       #
#           LOG0280 - LOG1300 - LOG1400                           #
# OBJETIVO: IMPRESSAO DA ORDEM DE MONTAGEM                        #
# AUTOR...: MARCIO KLAHR                                          #
# DATA....: 03/07/1992                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_om_list               RECORD LIKE om_list.*,
         p_om_mest               RECORD LIKE ordem_montag_mest.*,
         p_om_item               RECORD LIKE ordem_montag_item.*,
         p_om_embal              RECORD LIKE ordem_montag_embal.*,
         p_par_vdp               RECORD LIKE par_vdp.*,
         p_cod_empresa           LIKE empresa.cod_empresa,
         p_den_empresa           LIKE empresa.den_empresa,
         p_user                  LIKE usuario.nom_usuario,
         p_num_pedido            LIKE ped_itens.num_pedido,
         p_num_sequencia         LIKE ped_itens.num_sequencia,
         p_om                    LIKE ordem_montag_mest.num_om,
         p_lixo                  LIKE ordem_montag_mest.num_om,
         p_pct_desp_finan        LIKE cond_pgto.pct_desp_finan,
         p_ies_cons              SMALLINT,
         p_status                SMALLINT,
         p_ind                   SMALLINT,
         p_dig                   SMALLINT,
         p_aux                   SMALLINT,
         p_dep                   SMALLINT,
         p_ind2                  SMALLINT,
         p_dep2                  SMALLINT,
         p_x                     SMALLINT,
         p_cur                   SMALLINT,
         p_origem_detalhe        SMALLINT,
         p_ies_emite_certif      LIKE ped_itens_adic.ies_emite_certif,
         p_valor_saldo           DECIMAL(15,2),
         p_peso_total            DECIMAL(11,4),
         p_valor_total           DECIMAL(13,2),
         p_volume_total          DECIMAL(10,3),
         p_qtd_total             DECIMAL(15,3),
         p_cod_cnd_pgto          SMALLINT,
         p_ies_frete             SMALLINT,
         p_impres                SMALLINT,
         p_imp_mestre            SMALLINT,
         p_cod_cidade            CHAR(005),
         p_frete_posto           CHAR(020),
         p_des_frete             CHAR(020),
         p_tex_observ_1          CHAR(076),
         p_tex_observ_2          CHAR(076),
         p_den_local_estoq       LIKE local.den_local,
         p_den_tip_carteira      LIKE tipo_carteira.den_tip_carteira,
         l_cod_tip_carteira_ant  LIKE tipo_carteira.cod_tip_carteira,
         p_qtd_decimais          DECIMAL(01,0),
         p_qtd_decimais_cart     DECIMAL(01,0),
         p_qtd_decimais_par      DECIMAL(01,0),
         p_cli_item_txt          RECORD LIKE cli_item_txt.*

  DEFINE p_relat_mest           RECORD
                                num_om                LIKE ordem_montag_mest.num_om,
                                num_lote_om           LIKE ordem_montag_mest.num_lote_om,
                                dat_emis              LIKE ordem_montag_mest.dat_emis,
                                cod_cliente           LIKE pedidos.cod_cliente,
                                nom_cliente           LIKE clientes.nom_cliente,
                                end_cliente           LIKE clientes.end_cliente,
                                den_marca             LIKE clientes.den_marca,
                                cod_repres            LIKE pedidos.cod_repres,
                                cod_rota              LIKE clientes.cod_rota,
                                nom_guerra            LIKE representante.nom_guerra,
                                den_bairro            LIKE clientes.den_bairro,
                                den_rota              LIKE rotas.den_rota,
                                den_cidade            LIKE cidades.den_cidade,
                                cod_cep               LIKE clientes.cod_cep,
                                cod_uni_feder         LIKE cidades.cod_uni_feder,
                                num_cgc_cpf           LIKE clientes.num_cgc_cpf,
                                ins_estadual          LIKE clientes.ins_estadual,
                                end_entrega           LIKE ped_end_ent.end_entrega,
                                cod_cidade_ent        LIKE ped_end_ent.cod_cidade,
                                den_cidade_ent        LIKE cidades.den_cidade,
                                den_bairro_ent        LIKE cidades.den_cidade,
                                cod_uni_feder_ent     LIKE cidades.cod_uni_feder,
                                cod_transpor          LIKE pedidos.cod_transpor,
                                den_transpor          LIKE transport.den_transpor,
                                cod_consig            LIKE pedidos.cod_transpor,
                                den_consig            LIKE transport.den_transpor,
                                end_consig            LIKE transport.end_transpor,
                                cod_cidade_consig     LIKE cidades.cod_cidade,
                                den_cidade_consig     LIKE cidades.den_cidade,
                                den_bairro_consig     LIKE transport.den_bairro,
                                cod_uni_feder_consig  LIKE cidades.cod_uni_feder,
                                cod_nat_oper          LIKE nat_operacao.cod_nat_oper,
                                den_nat_oper          LIKE nat_operacao.den_nat_oper,
                                cod_moeda             LIKE moeda.cod_moeda,
                                den_moeda             LIKE moeda.den_moeda,
                                num_telefone          LIKE clientes.num_telefone,
                                ies_finalidade        LIKE pedidos.ies_finalidade
                                END RECORD
  DEFINE p_relat_item           RECORD
                                num_om             LIKE ordem_montag_item.num_om,
                                num_pedido         LIKE ordem_montag_item.num_pedido,
                                pct_desc_adic_mest LIKE pedidos.pct_desc_adic,
                                num_sequencia      LIKE ordem_montag_item.num_sequencia,
                                cod_item           LIKE ordem_montag_item.cod_item,
                                pct_desc_adic      LIKE ped_itens.pct_desc_adic,
                                qtd_reservada      LIKE ordem_montag_item.qtd_reservada,
                                qtd_volume_m3      LIKE ordem_montag_item.qtd_volume_item,
                                den_item           LIKE item.den_item,
                                den_texto_1        LIKE cli_item_txt.den_texto_1,
                                den_texto_2        LIKE cli_item_txt.den_texto_2,
                                den_texto_3        LIKE cli_item_txt.den_texto_3,
                                den_texto_4        LIKE cli_item_txt.den_texto_4,
                                den_texto_5        LIKE cli_item_txt.den_texto_5,
                                qtd_padr_embal    LIKE item_embalagem.qtd_padr_embal,
                                cod_unid_med      LIKE item.cod_unid_med,
                                pes_item          DECIMAL(11,4),
                                pre_unit          LIKE ped_itens.pre_unit,
                                valor_item        DECIMAL(15,3),
                                qtd_refer_reserv  LIKE ordem_montag_itref.qtd_reservada
                                END RECORD
  DEFINE p_saldo                RECORD
                                pct_desc_adic_m   LIKE pedidos.pct_desc_adic,
                                cod_moeda         LIKE pedidos.cod_moeda,
                                cod_local_estoq   LIKE pedidos.cod_local_estoq,
                                qtd_pecas         LIKE ped_itens.qtd_pecas_solic,
                                pre_unit          LIKE ped_itens.pre_unit,
                                pct_desc_adic     LIKE ped_itens.pct_desc_adic,
				                            cod_tip_carteira  LIKE tipo_carteira.cod_tip_carteira
                                END RECORD
  DEFINE p_con_pedido           ARRAY [99]
                                OF RECORD
                                conta            SMALLINT,
                                num_pedido       LIKE ordem_montag_item.num_pedido
                                END RECORD
  DEFINE t1_pedido              ARRAY [99]
                                OF RECORD
                                num_pedido     LIKE pedidos.num_pedido,
                                tex_observ_1   LIKE ped_observacao.tex_observ_1,
                                tex_observ_2   LIKE ped_observacao.tex_observ_2
                                END RECORD
  DEFINE t2_qtd_embal           ARRAY[99]
                                OF RECORD
                                cod_embal      LIKE ordem_montag_embal.cod_embal_ext,
                                qtd_embal      LIKE ordem_montag_embal.qtd_embal_ext
                                END RECORD
  DEFINE p_nom_arquivo          CHAR(100),
         p_msg                  CHAR(100),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_cancel               INTEGER,
         p_ies_impressao        CHAR(01)
DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
  DEFINE g_ies_ambiente         CHAR(001)
END GLOBALS

   DEFINE mr_rastreab         RECORD
                              cod_local        LIKE estoque_loc_reser.cod_local,
                              num_lote         LIKE estoque_loc_reser.num_lote,
                              qtd_reservada    LIKE estoque_loc_reser.qtd_reservada,
                              qtd_atendida     LIKE estoque_loc_reser.qtd_atendida
                              END RECORD

   DEFINE ma_ctr_grade        ARRAY[5]
                              OF RECORD
                              den_grade        CHAR(10),
                              nom_tabela_zoom  LIKE ctr_grade.nom_tabela_zoom,
                              descr_col_1_zoom LIKE ctr_grade.descr_col_1_zoom,
                              descr_col_2_zoom LIKE ctr_grade.descr_col_2_zoom,
                              ies_ctr_empresa  LIKE ctr_grade.ies_ctr_empresa,
                              den_cod_grade    CHAR(30)
                              END RECORD

   DEFINE mr_est_compon       RECORD
                              item             LIKE ldi_est_comp_vdp.item,
                              cod_unid_med     LIKE item.cod_unid_med,
                              num_serie        LIKE estoque_lote_ender.num_serie,
                              qtd_reservada    LIKE ldi_est_comp_vdp.qtd_reservada
                              END RECORD
   DEFINE mr_om_grade         RECORD LIKE ordem_montag_grade.*,
          mr_item_ctr_grade   RECORD LIKE item_ctr_grade.*
   DEFINE mr_par_logix        RECORD LIKE par_logix.*,
          m_ies_ctr_lote      LIKE item.ies_ctr_lote,
          m_imp_tit_rast      SMALLINT,
          m_prim_vez_comp     SMALLINT,
          m_local_por_item    SMALLINT,
          m_local_estoque     LIKE pedidos.cod_local_estoq
   DEFINE ma_item_embal       ARRAY[100] OF
                              RECORD
                              cod_item      LIKE item.cod_item,
                              cod_embal_int LIKE embalagem.cod_embal,
                              cod_embal_ext LIKE embalagem.cod_embal
                              END RECORD
   #O.S 405745
   DEFINE m_qtd_prest_cta     LIKE prest_cta_retorno.qtd_retornada,
          m_num_prest_cta     CHAR(09),
          m_prz_entrega       LIKE ped_itens.prz_entrega
   #O.S 405745
   #OS 569023
   DEFINE ma_est_loc_reser_end ARRAY [100]
                              OF RECORD
                  identif_estoque CHAR(30),
                  endereco        CHAR(15)
                              END RECORD

   DEFINE m_retorno_vdpr177   SMALLINT,
          m_endereco          CHAR(15),
          m_identif_estoque   CHAR(30)

   DEFINE m_num_serie         LIKE est_loc_reser_end.num_serie
   #OS 569023

   DEFINE m_orig_denomin_item_impr_om CHAR(01)

MAIN
  CALL log0180_conecta_usuario()

  CALL fgl_setenv("VERSION_INFO","L10-VDP1030-10.01.$Revision: 7 $p") #Informacao da versao do programa controlado pelo SourceSafe - Nao remover esta linha.
LET p_versao = "VDP1030-05.10.17p" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  WHENEVER ERROR STOP
  DEFER INTERRUPT
  CALL log140_procura_caminho("VDP1030.IEM") RETURNING p_caminho
  LET p_help = p_caminho CLIPPED
  OPTIONS
    HELP FILE p_help
  CALL log001_acessa_usuario("VDP","LOGERP;LOGLQ2") RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN
    CALL vdp103_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION vdp103_controle()
#--------------------------#

 DEFINE l_status     SMALLINT

  LET m_local_por_item = FALSE            #OS544500

  IF find4GLFunction('vdpy190_verifica_local_estoque') THEN #OS 594503
     LET m_local_por_item = TRUE
  END IF

  IF NUM_ARGS() > 0 THEN
    LET p_cod_empresa = ARG_VAL(1)
  END IF
  #OS 113783 - INICIO
  WHENEVER ERROR CONTINUE
  SELECT parametros
    INTO mr_par_logix.parametros
    FROM par_logix
   WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET mr_par_logix.parametros  = " "
  END IF
  #OS 113783 - FINAL
  WHENEVER ERROR CONTINUE
  SELECT par_vdp_txt
    INTO p_par_vdp.par_vdp_txt
    FROM par_vdp
   WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_par_vdp.par_vdp_txt = " "
  END IF

  CALL log2250_busca_parametro(p_cod_empresa, 'orig_denomin_item_impr_om')
     RETURNING m_orig_denomin_item_impr_om, l_status

  IF l_status = FALSE OR m_orig_denomin_item_impr_om IS NULL OR m_orig_denomin_item_impr_om = ' ' THEN
     LET m_orig_denomin_item_impr_om = '2'
  END IF

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("VDP1030") RETURNING p_nom_tela
  OPEN WINDOW w_vdp1030 AT 5,14 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Listar" "Lista relatorio"
      HELP 009
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP1030","CO") THEN
        IF vdp103_lista_om() THEN
          NEXT OPTION "Fim"
        ELSE
          NEXT OPTION "Listar"
        END IF
      END IF

    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
      DATABASE logix

    COMMAND "Fim" "Retorna ao menu anterior"
      HELP 008
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informa��es sobre a aplica��o (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp1030
END FUNCTION

#-------------------------#
 FUNCTION vdp103_lista_om()
#-------------------------#
  DEFINE l_primeiro_bnf      SMALLINT,
         l_ordem             SMALLINT,
         l_status            SMALLINT

  INITIALIZE ma_item_embal, p_msg TO NULL
  WHENEVER ERROR CONTINUE
  SELECT den_empresa
    INTO p_den_empresa
    FROM empresa
   WHERE cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
    LET p_den_empresa = "NAO CADASTRADA"
  END IF
  LET p_peso_total   = 0
  LET p_cod_cidade   = 0
  LET p_valor_total  = 0
  LET p_volume_total = 0
  LET p_qtd_total    = 0
  LET p_num_pedido   = 0
  LET p_tex_observ_1 = " "
  LET p_tex_observ_2 = " "
  FOR p_ind = 1 TO 99
    LET t1_pedido[p_ind].num_pedido    = 0
    LET p_con_pedido[p_ind].num_pedido = 0
    LET t1_pedido[p_ind].tex_observ_1  = " "
    LET t1_pedido[p_ind].tex_observ_2  = " "
  END FOR
  LET p_ind = 0
  LET p_aux = 0
  LET p_cur = 0
  IF log0280_saida_relat(16,40) IS NOT NULL THEN
    ERROR "Processando a extra��o do relat�rio..."
  ELSE
    RETURN TRUE
  END IF
  IF p_ies_impressao = "S" THEN
    IF g_ies_ambiente = "W" THEN
      CALL log150_procura_caminho("LST") RETURNING p_caminho
      LET p_caminho = p_caminho CLIPPED, "vdp1030.tmp"
      START REPORT vdp103_relat TO p_caminho
    ELSE
      START REPORT vdp103_relat TO PIPE p_nom_arquivo
    END IF
  ELSE
    START REPORT vdp103_relat TO p_nom_arquivo
  END IF
  WHENEVER ERROR CONTINUE
  DECLARE cl_om_list CURSOR FOR
  SELECT cod_empresa, num_om, num_pedido, dat_emis, nom_usuario
    FROM om_list
   WHERE cod_empresa = p_cod_empresa
     AND nom_usuario = p_user
   ORDER BY num_om
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","cl_om_list")
  END IF
  WHENEVER ERROR CONTINUE
  OPEN cl_om_list
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("OPEN","cl_om_list")
  END IF
  WHENEVER ERROR CONTINUE
  FETCH cl_om_list INTO p_om_list.*
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
    INITIALIZE p_relat_mest.* TO NULL
    OUTPUT TO REPORT vdp103_relat("MESTRE")
    CALL log0030_mensagem("N�o existem dados para serem listados", "exclamation")
    RETURN FALSE
  ELSE
    WHILE SQLCA.sqlcode <> NOTFOUND
      LET p_peso_total   = 0
      LET p_cod_cidade   = 0
      LET p_valor_total  = 0
      LET p_volume_total = 0
      LET p_qtd_total    = 0
      LET p_num_pedido   = 0
      LET p_tex_observ_1 = " "
      LET p_tex_observ_2 = " "
      INITIALIZE p_relat_mest.* TO NULL
      CALL vdp103_monta_relat_mest_obs()
      LET p_imp_mestre = TRUE
      LET p_relat_mest.num_om = p_om_list.num_om
      OUTPUT TO REPORT vdp103_relat("MESTRE")
      WHENEVER ERROR CONTINUE
      DECLARE cl_om_item CURSOR FOR
      SELECT 1, ordem_montag_item.cod_empresa, ordem_montag_item.num_om, ordem_montag_item.num_pedido,
             ordem_montag_item.num_sequencia, ordem_montag_item.cod_item,
             ordem_montag_item.qtd_volume_item, ordem_montag_item.qtd_reservada,
             ordem_montag_item.ies_bonificacao, ordem_montag_item.pes_total_item,  ped_itens.prz_entrega
        FROM ordem_montag_item, ped_itens
       WHERE ordem_montag_item.cod_empresa = p_cod_empresa
         AND ordem_montag_item.num_om      = p_om_list.num_om
         AND ped_itens.cod_empresa         = p_cod_empresa
         AND ped_itens.num_pedido          = ordem_montag_item.num_pedido
         AND ped_itens.num_sequencia       = ordem_montag_item.num_sequencia
         AND ordem_montag_item.ies_bonificacao = 'N'
       UNION
       SELECT 2, ordem_montag_item.cod_empresa, ordem_montag_item.num_om, ordem_montag_item.num_pedido,
              ordem_montag_item.num_sequencia, ordem_montag_item.cod_item,
              ordem_montag_item.qtd_volume_item, ordem_montag_item.qtd_reservada,
              ordem_montag_item.ies_bonificacao, ordem_montag_item.pes_total_item, ped_itens_bnf.prz_entrega
         FROM ordem_montag_item, ped_itens_bnf
        WHERE ordem_montag_item.cod_empresa = p_cod_empresa
          AND ordem_montag_item.num_om      = p_om_list.num_om
          AND ped_itens_bnf.cod_empresa     = p_cod_empresa
          AND ped_itens_bnf.num_pedido      = ordem_montag_item.num_pedido
          AND ped_itens_bnf.num_sequencia   = ordem_montag_item.num_sequencia
          AND ordem_montag_item.ies_bonificacao = 'S'
        ORDER BY 1, 5, 9, 4, 11
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","CL_OM_ITEM")
      END IF
      WHENEVER ERROR CONTINUE
      OPEN cl_om_item
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("OPEN","CL_OM_ITEM")
      END IF
      LET l_primeiro_bnf = TRUE
      CALL vdp103_inicializa_t2_qtd_embal()
      CALL vdp1030_inicializa_ma_item_embal()
      LET p_origem_detalhe = FALSE
      WHENEVER ERROR CONTINUE
      FETCH cl_om_item INTO l_ordem,p_om_item.*, m_prz_entrega
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 AND
         sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FETCH CURSOR","cl_om_item")
      END IF
      WHILE SQLCA.sqlcode <> NOTFOUND
        INITIALIZE p_relat_item.* TO NULL
        CALL vdp103_monta_relat_item()
        FOR p_x = 1 TO p_aux
          IF p_con_pedido[p_x].num_pedido = p_relat_item.num_pedido THEN
            EXIT FOR
          END IF
        END FOR
        IF p_x > p_aux THEN
          LET p_con_pedido[p_x].num_pedido       = p_relat_item.num_pedido
          LET p_aux = p_x
        END IF
        CALL vdp103_busca_observ()
        IF p_om_item.ies_bonificacao <> "N" THEN
          IF l_primeiro_bnf = TRUE THEN
            OUTPUT TO REPORT vdp103_relat("BNF")
            LET l_primeiro_bnf = FALSE
          END IF
        END IF
        OUTPUT TO REPORT vdp103_relat("DETALHE")
        IF mr_par_logix.parametros[74,74] = "S" AND m_ies_ctr_lote = "S" THEN
          CALL vdp1030_verifica_rastreabilidade('RASTREAB')
        ELSE
          CALL vdp1030_verifica_rastreabilidade('WMS')
        END IF

        CALL vdp1030_imp_grade()
        CALL vdp1030_imp_est_compon()
        CALL vdp103_tabula_qtd_embal()
        WHENEVER ERROR CONTINUE
        FETCH cl_om_item INTO l_ordem,p_om_item.*
        WHENEVER ERROR STOP
      END WHILE
      OUTPUT TO REPORT vdp103_relat("TOTAL")
      FOR p_ind = 1 TO 99
         LET t1_pedido[p_ind].num_pedido    = 0
         LET p_con_pedido[p_ind].num_pedido = 0
         LET t1_pedido[p_ind].tex_observ_1  = " "
         LET t1_pedido[p_ind].tex_observ_2  = " "
      END FOR
      LET p_ind = 0
      LET p_aux = 0
      LET p_cur = 0
      CLOSE cl_om_item
      FREE cl_om_item
      WHENEVER ERROR CONTINUE
      FETCH cl_om_list INTO p_om_list.*
      IF SQLCA.sqlcode = NOTFOUND THEN
         OUTPUT TO REPORT vdp103_relat("ULT_FOLHA")
         EXIT WHILE
      END IF
      WHENEVER ERROR STOP
    END WHILE
  END IF
  CLOSE cl_om_list
  FREE cl_om_list
  FINISH REPORT vdp103_relat
  IF g_ies_ambiente  = "W"  AND p_ies_impressao = "S"  THEN
    LET p_comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
    RUN p_comando
  END IF
  IF p_ies_impressao = "S" THEN
    CALL log0030_mensagem("Relat�rio impresso com sucesso. ","info")
  ELSE
    LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo CLIPPED,"."
    CALL log0030_mensagem(p_msg,"info")
  END IF
  ERROR "Fim de processamento."
  CALL log085_transacao("BEGIN")
  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("BEGIN","LISTA")
  END IF
  WHENEVER ERROR CONTINUE
  DELETE FROM om_list
   WHERE cod_empresa = p_cod_empresa
     AND om_list.nom_usuario = p_user
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    CALL log085_transacao("COMMIT")
    IF sqlca.sqlcode = 0 THEN
      ERROR "Fim de processamento..."
      RETURN TRUE
    ELSE
      CALL log003_err_sql("EXCLUSAO_1","OM_LIST")
      CALL log085_transacao("ROLLBACK")
    END IF
  ELSE
    CALL log003_err_sql("EXCLUSAO_2","OM_LIST")
    CALL log085_transacao("ROLLBACK")
    RETURN FALSE
  END IF
END FUNCTION

#--------------------------#
FUNCTION vdp1030_imp_grade()
#--------------------------#

  WHENEVER ERROR CONTINUE
   DECLARE cq_om_grade_i CURSOR FOR
    SELECT cod_empresa,
           num_om,
           num_pedido,
           num_sequencia,
           cod_item,
           qtd_reservada,
           num_reserva,
           cod_grade_1,
           cod_grade_2,
           cod_grade_3,
           cod_grade_4,
           cod_grade_5,
           cod_composicao
      FROM ordem_montag_grade
     WHERE cod_empresa   = p_cod_empresa
       AND num_om        = p_om_item.num_om
       AND num_pedido    = p_om_item.num_pedido
       AND num_sequencia = p_om_item.num_sequencia
       AND cod_item      = p_om_item.cod_item
       AND cod_grade_1   IS NOT NULL
       AND cod_grade_1   <> " "
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_OM_GRADE_I")
  END IF

  WHENEVER ERROR CONTINUE
  FOREACH cq_om_grade_i INTO mr_om_grade.*

     IF sqlca.sqlcode <> 0 THEN
        EXIT FOREACH
     END IF

     CALL vdp1030_busca_den_grade()
     OUTPUT TO REPORT vdp103_relat("GRADE")

  END FOREACH
  WHENEVER ERROR STOP

  FREE cq_om_grade_i

  #O.S 405745
  WHENEVER ERROR CONTINUE
  SELECT num_prest_contas,
         qtd_retornada
    INTO m_num_prest_cta,
         m_qtd_prest_cta
    FROM prest_cta_retorno
   WHERE cod_empresa      = p_cod_empresa
     AND num_om           = p_om_item.num_om
     AND num_pedido       = p_om_item.num_pedido
     AND num_sequencia    = p_om_item.num_sequencia
     AND cod_item         = p_om_item.cod_item
  IF sqlca.sqlcode = 0 THEN
     OUTPUT TO REPORT vdp103_relat("RETORNO")
  ELSE
     IF SQLCA.sqlcode <> NOTFOUND THEN
        CALL log003_err_sql("SELECT","PREST_CTA_RETORNO")
     ELSE
        LET m_qtd_prest_cta = 0
        LET m_num_prest_cta = 0
     END IF
  END IF
  WHENEVER ERROR STOP
  #O.S 405745
END FUNCTION

#v-------------------------------------------#
FUNCTION vdp1030_busca_texto_item(l_cod_item)
#--------------------------------------------#
  DEFINE l_cod_item LIKE item.cod_item
  INITIALIZE p_cli_item_txt.* TO NULL
  WHENEVER ERROR CONTINUE
  SELECT den_texto_1, den_texto_2, den_texto_3, den_texto_4, den_texto_5
    INTO p_cli_item_txt.den_texto_1, p_cli_item_txt.den_texto_2,
         p_cli_item_txt.den_texto_3, p_cli_item_txt.den_texto_4,
         p_cli_item_txt.den_texto_5
    FROM cli_item_txt
   WHERE cod_empresa   = p_cod_empresa
     AND cod_cliente   = p_relat_mest.cod_cliente
     AND cod_item      = l_cod_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    RETURN
  END IF
END FUNCTION

#--------------------------------#
FUNCTION vdp1030_busca_den_grade()
#--------------------------------#
  INITIALIZE mr_item_ctr_grade.*, ma_ctr_grade TO NULL
  WHENEVER ERROR CONTINUE
  SELECT num_grade_1, num_grade_2, num_grade_3, num_grade_4, num_grade_5
    INTO mr_item_ctr_grade.num_grade_1, mr_item_ctr_grade.num_grade_2,
         mr_item_ctr_grade.num_grade_3, mr_item_ctr_grade.num_grade_4,
         mr_item_ctr_grade.num_grade_5
    FROM item_ctr_grade
   WHERE cod_empresa        = p_cod_empresa
     AND cod_lin_prod       = 0
     AND cod_lin_recei      = 0
     AND cod_seg_merc       = 0
     AND cod_cla_uso        = 0
     AND cod_familia        = 0
     AND cod_item           = p_om_item.cod_item
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    RETURN
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_grade_reduz
    INTO ma_ctr_grade[1].den_grade
    FROM grade
   WHERE cod_empresa    = p_cod_empresa
     AND cod_grade      = mr_item_ctr_grade.num_grade_1
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    LET ma_ctr_grade[1].den_grade  = ma_ctr_grade[1].den_grade CLIPPED, ":"
    WHENEVER ERROR CONTINUE
    SELECT nom_tabela_zoom, descr_col_1_zoom, descr_col_2_zoom, ies_ctr_empresa
      INTO ma_ctr_grade[1].nom_tabela_zoom, ma_ctr_grade[1].descr_col_1_zoom,
           ma_ctr_grade[1].descr_col_2_zoom, ma_ctr_grade[1].ies_ctr_empresa
      FROM ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_grade     = mr_item_ctr_grade.num_grade_1
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
      CALL vdp1030_busca_codigo_grade(1, mr_om_grade.cod_grade_1)
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_grade_reduz
    INTO ma_ctr_grade[2].den_grade
    FROM grade
   WHERE cod_empresa    = p_cod_empresa
     AND cod_grade      = mr_item_ctr_grade.num_grade_2
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    LET ma_ctr_grade[2].den_grade  = ma_ctr_grade[2].den_grade CLIPPED, ":"
    WHENEVER ERROR CONTINUE
    SELECT nom_tabela_zoom, descr_col_1_zoom, descr_col_2_zoom, ies_ctr_empresa
      INTO ma_ctr_grade[2].nom_tabela_zoom, ma_ctr_grade[2].descr_col_1_zoom,
           ma_ctr_grade[2].descr_col_2_zoom, ma_ctr_grade[2].ies_ctr_empresa
      FROM ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_grade     = mr_item_ctr_grade.num_grade_2
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
      CALL vdp1030_busca_codigo_grade(2, mr_om_grade.cod_grade_2)
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_grade_reduz
    INTO ma_ctr_grade[3].den_grade
    FROM grade
   WHERE cod_empresa    = p_cod_empresa
     AND cod_grade      = mr_item_ctr_grade.num_grade_3
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    LET ma_ctr_grade[3].den_grade  = ma_ctr_grade[3].den_grade CLIPPED, ":"
    WHENEVER ERROR CONTINUE
    SELECT nom_tabela_zoom, descr_col_1_zoom, descr_col_2_zoom, ies_ctr_empresa
      INTO ma_ctr_grade[3].nom_tabela_zoom, ma_ctr_grade[3].descr_col_1_zoom,
           ma_ctr_grade[3].descr_col_2_zoom, ma_ctr_grade[3].ies_ctr_empresa
      FROM ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_grade     = mr_item_ctr_grade.num_grade_3
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
      CALL vdp1030_busca_codigo_grade(3, mr_om_grade.cod_grade_3)
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_grade_reduz
    INTO ma_ctr_grade[4].den_grade
    FROM grade
   WHERE cod_empresa    = p_cod_empresa
     AND cod_grade      = mr_item_ctr_grade.num_grade_4
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    LET ma_ctr_grade[4].den_grade  = ma_ctr_grade[4].den_grade CLIPPED, ":"
    WHENEVER ERROR CONTINUE
    SELECT nom_tabela_zoom, descr_col_1_zoom, descr_col_2_zoom, ies_ctr_empresa
      INTO ma_ctr_grade[4].nom_tabela_zoom, ma_ctr_grade[4].descr_col_1_zoom,
           ma_ctr_grade[4].descr_col_2_zoom, ma_ctr_grade[4].ies_ctr_empresa
      FROM ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_grade     = mr_item_ctr_grade.num_grade_4
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
      CALL vdp1030_busca_codigo_grade(4, mr_om_grade.cod_grade_4)
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_grade_reduz
    INTO ma_ctr_grade[5].den_grade
    FROM grade
   WHERE cod_empresa    = p_cod_empresa
     AND cod_grade      = mr_item_ctr_grade.num_grade_5
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    LET ma_ctr_grade[5].den_grade  = ma_ctr_grade[5].den_grade CLIPPED, ":"
    WHENEVER ERROR CONTINUE
    SELECT nom_tabela_zoom, descr_col_1_zoom, descr_col_2_zoom, ies_ctr_empresa
      INTO ma_ctr_grade[5].nom_tabela_zoom, ma_ctr_grade[5].descr_col_1_zoom,
           ma_ctr_grade[5].descr_col_2_zoom, ma_ctr_grade[5].ies_ctr_empresa
      FROM ctr_grade
     WHERE cod_empresa   = p_cod_empresa
       AND cod_grade     = mr_item_ctr_grade.num_grade_5
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
      CALL vdp1030_busca_codigo_grade(5, mr_om_grade.cod_grade_5)
    END IF
  END IF
END FUNCTION

#----------------------------------------------------------#
FUNCTION vdp1030_busca_codigo_grade(l_nr_grade, l_cod_grade)
#----------------------------------------------------------#
   DEFINE sql_stmt                  CHAR(500),
          l_nr_grade                SMALLINT,
          l_cod_grade               LIKE ordem_montag_grade.cod_grade_1
   LET sql_stmt  =
       'SELECT ', ma_ctr_grade[l_nr_grade].descr_col_2_zoom  CLIPPED,
        ' FROM ', ma_ctr_grade[l_nr_grade].nom_tabela_zoom   CLIPPED,
       ' WHERE ', ma_ctr_grade[l_nr_grade].descr_col_1_zoom  CLIPPED,
           ' = "', l_cod_grade, '" '
   IF ma_ctr_grade[l_nr_grade].ies_ctr_empresa = "S" THEN
      LET sql_stmt = sql_stmt CLIPPED,
          ' AND  cod_empresa = "', p_cod_empresa, '" '
   END IF
   WHENEVER ERROR CONTINUE
   PREPARE var_den_codigo FROM sql_stmt
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("PREPARE","VAR_DEN_CODIGO")
   END IF
   WHENEVER ERROR CONTINUE
   DECLARE cq_den_codigo CURSOR FOR var_den_codigo
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_DEN_CODIGO")
   END IF
   WHENEVER ERROR CONTINUE
   OPEN cq_den_codigo
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("OPEN","CQ_DEN_CODIGO")
   END IF
   WHENEVER ERROR CONTINUE
   FETCH cq_den_codigo INTO ma_ctr_grade[l_nr_grade].den_cod_grade
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET ma_ctr_grade[l_nr_grade].den_cod_grade  = "N/CADAST."
   END IF
   CLOSE cq_den_codigo
   FREE cq_den_codigo
END FUNCTION

#-----------------------------#
 FUNCTION vdp103_busca_num_om()
#-----------------------------#
  LET p_cur = 0
  WHENEVER ERROR CONTINUE
  DECLARE p_vdp_count CURSOR FOR
   SELECT UNIQUE ordem_montag_mest.num_om
     FROM ordem_montag_mest, ordem_montag_item
    WHERE ordem_montag_mest.cod_empresa  = p_cod_empresa
      AND ordem_montag_mest.ies_sit_om   IN ("N", "E", "I", "V")
      AND ordem_montag_mest.cod_empresa  = ordem_montag_item.cod_empresa
      AND ordem_montag_mest.num_om       = ordem_montag_item.num_om
      AND ordem_montag_item.num_pedido   = p_con_pedido[p_dig].num_pedido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","P_VDP_COUNT")
  END IF
  WHENEVER ERROR CONTINUE
  FOREACH p_vdp_count INTO p_om
  WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      EXIT FOREACH
    END IF
    LET  p_cur = p_cur + 1
  END FOREACH
  FREE p_vdp_count
  LET p_con_pedido[p_dig].conta = p_cur
END FUNCTION

#------------------------------------#
 FUNCTION vdp103_busca_saldo_pedido()
#------------------------------------#

 WHENEVER ERROR CONTINUE
 DECLARE cl_pedidos CURSOR FOR
  SELECT pedidos.pct_desc_adic, pedidos.cod_moeda, (ped_itens.qtd_pecas_solic-ped_itens.qtd_pecas_cancel-
         ped_itens.qtd_pecas_reserv-ped_itens.qtd_pecas_atend), ped_itens.pre_unit, ped_itens.pct_desc_adic,
         pedidos.cod_tip_carteira, ped_itens.num_sequencia
   FROM pedidos, ped_itens
  WHERE pedidos.cod_empresa        = p_cod_empresa
    AND pedidos.num_pedido         = p_con_pedido[p_dig].num_pedido
    AND ped_itens.cod_empresa      = pedidos.cod_empresa
    AND ped_itens.num_pedido       = pedidos.num_pedido
    AND (ped_itens.qtd_pecas_solic-ped_itens.qtd_pecas_atend-ped_itens.qtd_pecas_reserv-ped_itens.qtd_pecas_cancel)>0
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   CALL log003_err_sql("DECLARE","CL_PEDIDOS")
 END IF
 WHENEVER ERROR CONTINUE
 FOREACH cl_pedidos INTO p_saldo.pct_desc_adic_m, p_saldo.cod_moeda, p_saldo.qtd_pecas, p_saldo.pre_unit,
                         p_saldo.pct_desc_adic, p_saldo.cod_tip_carteira, p_num_sequencia
 WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     EXIT FOREACH
   END IF
   CALL vdp103_calcula_saldo_pedido()
 END FOREACH
 FREE cl_pedidos
END FUNCTION

#--------------------------------------#
 FUNCTION vdp103_calcula_saldo_pedido()
#--------------------------------------#
  DEFINE l_val_cotacao LIKE cotacao.val_cotacao
  IF p_saldo.cod_moeda > 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO l_val_cotacao
      FROM cotacao
     WHERE cod_moeda = p_saldo.cod_moeda
       AND dat_ref   = TODAY
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      LET l_val_cotacao = 1
    END IF
  ELSE
    LET l_val_cotacao = 1
  END IF
  LET p_saldo.pre_unit = p_saldo.pre_unit * l_val_cotacao
  CALL vdp784_busca_desc_adic_unico(p_cod_empresa, p_con_pedido[p_dig].num_pedido,
                                    0,p_saldo.pct_desc_adic_m) RETURNING p_saldo.pct_desc_adic_m
  IF p_saldo.cod_tip_carteira = l_cod_tip_carteira_ant THEN
    LET p_qtd_decimais = p_qtd_decimais_cart
  ELSE
    CALL vdp1519_busca_qtd_decimais_preco(p_cod_empresa, p_saldo.cod_tip_carteira)
                                          RETURNING p_qtd_decimais_cart
    LET p_qtd_decimais         = p_qtd_decimais_cart
    LET l_cod_tip_carteira_ant = p_saldo.cod_tip_carteira
  END IF
  IF p_qtd_decimais = 0 THEN
    LET p_qtd_decimais = p_qtd_decimais_par
  END IF

  CALL vdp784_busca_desc_adic_unico(p_cod_empresa, p_con_pedido[p_dig].num_pedido, p_num_sequencia,
                                    p_saldo.pct_desc_adic) RETURNING p_saldo.pct_desc_adic

  CALL vdp1519_calcula_pre_unit(p_saldo.pre_unit, p_saldo.pct_desc_adic, p_qtd_decimais)
                               RETURNING p_saldo.pre_unit

  CALL vdp1519_calcula_pre_unit(p_saldo.pre_unit, p_saldo.pct_desc_adic_m,
                                p_qtd_decimais) RETURNING p_saldo.pre_unit

 LET p_valor_saldo = p_valor_saldo + (p_saldo.qtd_pecas * p_saldo.pre_unit)
END FUNCTION

#-------------------------------------#
 FUNCTION vdp103_monta_relat_mest_obs()
#-------------------------------------#
DEFINE l_cli_pct_desp_finan  LIKE cli_cond_pgto.pct_desp_financ,
       l_cod_transpor        LIKE ordem_montag_mest.cod_transpor
 WHENEVER ERROR CONTINUE
 SELECT cod_cliente, cod_repres, cod_transpor, cod_consig, ies_frete, cond_pgto.cod_cnd_pgto,
        cod_nat_oper, cod_moeda, pct_desp_finan, ies_finalidade
   INTO p_relat_mest.cod_cliente, p_relat_mest.cod_repres, p_relat_mest.cod_transpor,
        p_relat_mest.cod_consig, p_ies_frete, p_cod_cnd_pgto, p_relat_mest.cod_nat_oper,
        p_relat_mest.cod_moeda, p_pct_desp_finan, p_relat_mest.ies_finalidade
   FROM pedidos, cond_pgto
  WHERE pedidos.num_pedido    = p_om_list.num_pedido
    AND pedidos.cod_empresa   = p_cod_empresa
    AND pedidos.cod_cnd_pgto  = cond_pgto.cod_cnd_pgto
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   INITIALIZE p_relat_mest.cod_cliente, p_relat_mest.cod_repres, p_relat_mest.cod_transpor,
              p_relat_mest.cod_consig, p_ies_frete, p_cod_cnd_pgto, p_relat_mest.cod_nat_oper,
              p_relat_mest.cod_moeda, p_pct_desp_finan, p_relat_mest.ies_finalidade TO NULL
 END IF
 WHENEVER ERROR CONTINUE
 SELECT pct_desp_financ
   INTO l_cli_pct_desp_finan
   FROM cli_cond_pgto, pedidos
  WHERE pedidos.cod_empresa  = p_cod_empresa
    AND pedidos.num_pedido   = p_om_list.num_pedido
    AND pedidos.cod_cliente  = cli_cond_pgto.cod_cliente
    AND pedidos.cod_cnd_pgto = cli_cond_pgto.cod_cnd_pgto
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
   LET p_pct_desp_finan = l_cli_pct_desp_finan
   IF p_pct_desp_finan = 0 THEN
     LET p_pct_desp_finan = 1
   END IF
 END IF
 LET p_relat_mest.dat_emis = p_om_list.dat_emis
 WHENEVER ERROR CONTINUE
 SELECT end_entrega, den_bairro, cod_cidade, cod_cliente
   INTO p_relat_mest.end_entrega, p_relat_mest.den_bairro_ent,
        p_relat_mest.cod_cidade_ent, p_relat_mest.cod_cliente
   FROM ordem_montag_ender
  WHERE num_om      = p_om_list.num_om
    AND cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 #OS 398225
 WHENEVER ERROR CONTINUE
 SELECT rota
   INTO p_relat_mest.cod_rota
   FROM vdp_rota_emp_cli
  WHERE empresa = p_cod_empresa
    AND cliente = p_relat_mest.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   WHENEVER ERROR CONTINUE
   SELECT cod_rota
     INTO p_relat_mest.cod_rota
     FROM clientes
    WHERE cod_cliente = p_relat_mest.cod_cliente
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_relat_mest.cod_rota TO NULL
   END IF
 END IF
 #OS 398225
 WHENEVER ERROR CONTINUE
 SELECT nom_cliente, end_cliente, cod_cep, den_frete_posto, den_bairro,
        cod_cidade, num_cgc_cpf, ins_estadual, den_marca, num_telefone
   INTO p_relat_mest.nom_cliente, p_relat_mest.end_cliente, p_relat_mest.cod_cep,
        p_frete_posto, p_relat_mest.den_bairro, p_cod_cidade,
        p_relat_mest.num_cgc_cpf, p_relat_mest.ins_estadual, p_relat_mest.den_marca,
        p_relat_mest.num_telefone
   FROM clientes
  WHERE cod_cliente = p_relat_mest.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   INITIALIZE p_relat_mest.nom_cliente, p_relat_mest.end_cliente, p_relat_mest.cod_cep,
              p_frete_posto, p_relat_mest.den_bairro, p_cod_cidade,
              p_relat_mest.num_cgc_cpf, p_relat_mest.ins_estadual, p_relat_mest.den_marca,
              p_relat_mest.num_telefone TO NULL
 END IF
 WHENEVER ERROR CONTINUE
 SELECT den_nat_oper
   INTO p_relat_mest.den_nat_oper
   FROM nat_operacao
  WHERE nat_operacao.cod_nat_oper = p_relat_mest.cod_nat_oper
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   LET p_relat_mest.den_nat_oper = " "
 END IF
 WHENEVER ERROR CONTINUE
 SELECT den_moeda
   INTO p_relat_mest.den_moeda
   FROM moeda
  WHERE cod_moeda = p_relat_mest.cod_moeda
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   LET p_relat_mest.den_moeda = " "
 END IF
 WHENEVER ERROR CONTINUE
 SELECT nom_guerra
   INTO p_relat_mest.nom_guerra
   FROM representante
  WHERE cod_repres  = p_relat_mest.cod_repres
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   LET p_relat_mest.nom_guerra = " "
 END IF
 WHENEVER ERROR CONTINUE
 SELECT den_cidade, cod_uni_feder
   INTO p_relat_mest.den_cidade, p_relat_mest.cod_uni_feder
  FROM cidades
 WHERE cod_cidade = p_cod_cidade
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   INITIALIZE p_relat_mest.den_cidade, p_relat_mest.cod_uni_feder TO NULL
 END IF
 WHENEVER ERROR CONTINUE
 SELECT ordem_montag_mest.cod_transpor
   INTO l_cod_transpor
   FROM ordem_montag_mest
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_list.num_om
 WHENEVER ERROR STOP
 IF  sqlca.sqlcode = 0 AND
   LENGTH(l_cod_transpor) > 0 THEN
   LET p_relat_mest.cod_transpor = l_cod_transpor
 ELSE
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("SELECT","ORDEM_MONTAG_MEST")
   END IF
 END IF
 IF p_relat_mest.cod_transpor IS NULL THEN
 ELSE
   WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO p_relat_mest.den_transpor
     FROM clientes
    WHERE clientes.cod_cliente = p_relat_mest.cod_transpor
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET p_relat_mest.den_transpor = " "
   END IF
 END IF
 #INICIO OS 358122
 WHENEVER ERROR CONTINUE
 SELECT num_lote_om
   INTO p_relat_mest.num_lote_om
   FROM ordem_montag_mest
  WHERE cod_empresa = p_cod_empresa
    AND num_om      = p_om_list.num_om
 WHENEVER ERROR STOP
 #FIM OS 358122
 IF p_relat_mest.cod_consig IS NULL THEN
 ELSE
   WHENEVER ERROR CONTINUE
   SELECT end_cliente, nom_cliente, den_bairro, cod_cidade
     INTO p_relat_mest.end_consig, p_relat_mest.den_consig, p_relat_mest.den_bairro_consig,
          p_relat_mest.cod_cidade_consig
     FROM clientes
    WHERE cod_cliente = p_relat_mest.cod_consig
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_relat_mest.end_consig, p_relat_mest.den_consig, p_relat_mest.den_bairro_consig,
                p_relat_mest.cod_cidade_consig TO NULL
   END IF
   WHENEVER ERROR CONTINUE
   SELECT cidades.den_cidade, cidades.cod_uni_feder
     INTO p_relat_mest.den_cidade_consig, p_relat_mest.cod_uni_feder_consig
     FROM cidades
    WHERE cidades.cod_cidade = p_relat_mest.cod_cidade_consig
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_relat_mest.den_cidade_consig, p_relat_mest.cod_uni_feder_consig TO NULL
   END IF
 END IF
 IF p_relat_mest.end_entrega IS NULL THEN
   WHENEVER ERROR CONTINUE
   SELECT end_entrega, den_bairro, cod_cidade
     INTO p_relat_mest.end_entrega, p_relat_mest.den_bairro_ent, p_relat_mest.cod_cidade_ent
     FROM ped_end_ent
    WHERE num_pedido  = p_om_list.num_pedido
      AND cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_relat_mest.end_entrega, p_relat_mest.den_bairro_ent,
                p_relat_mest.cod_cidade_ent TO NULL
   END IF
 END IF
 IF sqlca.sqlcode = NOTFOUND THEN
 ELSE
   WHENEVER ERROR CONTINUE
   SELECT den_cidade, cod_uni_feder
     INTO p_relat_mest.den_cidade_ent, p_relat_mest.cod_uni_feder_ent
     FROM cidades
    WHERE cod_cidade = p_relat_mest.cod_cidade_ent
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     INITIALIZE p_relat_mest.den_cidade_ent, p_relat_mest.cod_uni_feder_ent TO NULL
   END IF
 END IF
 IF p_relat_mest.den_bairro_ent IS NULL OR
    p_relat_mest.den_bairro_ent = "                   " THEN
   WHENEVER ERROR CONTINUE
   DECLARE cq_end_ent CURSOR FOR
   SELECT den_bairro
     FROM cli_end_ent
    WHERE cod_cliente   = p_relat_mest.cod_cliente
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_END_ENT")
   END IF
   WHENEVER ERROR CONTINUE
   FOREACH cq_end_ent INTO p_relat_mest.den_bairro_ent
   WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
       EXIT FOREACH
     END IF
     EXIT FOREACH
   END FOREACH
   FREE cq_end_ent
 END IF
 CASE
   WHEN p_ies_frete = 1
        LET p_des_frete = "CIF PAGO"
   WHEN p_ies_frete = 2
        LET p_des_frete = "CIF COBRADO"
   WHEN p_ies_frete = 3
        LET p_des_frete = "FOB"
   WHEN p_ies_frete = 4
        LET p_des_frete = "CIF Com Pct"
   WHEN p_ies_frete = 5
        LET p_des_frete = "CIF INFORMADO"
   WHEN p_ies_frete = 6
        LET p_des_frete = "CIF IT TOTAL"
 END CASE
END FUNCTION

#-----------------------------#
 FUNCTION vdp103_busca_observ()
#-----------------------------#
 IF p_relat_item.num_pedido = 0 THEN
   RETURN
 END IF
 FOR p_dep = 1 TO p_ind
   IF t1_pedido[p_dep].num_pedido = p_relat_item.num_pedido THEN
     RETURN
   END IF
 END FOR
 WHENEVER ERROR CONTINUE
 SELECT tex_observ_1, tex_observ_2
   INTO p_tex_observ_1, p_tex_observ_2
   FROM ped_observacao
  WHERE ped_observacao.num_pedido  = p_relat_item.num_pedido
    AND ped_observacao.cod_empresa = p_cod_empresa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   RETURN
 END IF
 IF p_tex_observ_1 = "  " OR p_tex_observ_1 IS NULL THEN
 ELSE
   LET p_ind = p_ind + 1
   LET t1_pedido[p_ind].num_pedido   = p_relat_item.num_pedido
   LET t1_pedido[p_ind].tex_observ_1 = p_tex_observ_1
   IF p_tex_observ_1 = "  " OR p_tex_observ_1 IS NULL THEN
     LET t1_pedido[p_ind].tex_observ_2 = " "
   ELSE
     LET t1_pedido[p_ind].tex_observ_2 = p_tex_observ_2
   END IF
 END IF
END FUNCTION

#---------------------------------#
 FUNCTION vdp103_busca_loc_estoq()
#---------------------------------#
 INITIALIZE p_den_local_estoq TO NULL
 WHENEVER ERROR CONTINUE
 SELECT den_local
   INTO p_den_local_estoq
   FROM local
  WHERE local.cod_empresa = p_cod_empresa
    AND local.cod_local   = m_local_estoque
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   LET p_den_local_estoq = " "
 END IF
END FUNCTION

#-------------------------------------#
 FUNCTION vdp103_busca_tip_carteira()
#-------------------------------------#
 INITIALIZE p_den_tip_carteira TO NULL
 WHENEVER ERROR CONTINUE
 SELECT den_tip_carteira
   INTO p_den_tip_carteira
   FROM tipo_carteira
  WHERE cod_tip_carteira = p_saldo.cod_tip_carteira
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
   LET p_den_tip_carteira = " "
 END IF
END FUNCTION

#---------------------------------#
 FUNCTION vdp103_monta_relat_item()
#---------------------------------#
 DEFINE l_pre_unit         LIKE ped_itens.pre_unit,
        l_pre_unit1        DECIMAL(17,1),
        l_pre_unit2        DECIMAL(17,2),
        l_pre_unit3        DECIMAL(17,3),
        l_pre_unit4        DECIMAL(17,4),
        l_pre_unit5        DECIMAL(17,5),
        l_pre_unit6        DECIMAL(17,6),
        l_pes_unit         LIKE item.pes_unit,
        l_num_list_preco   LIKE pedidos.num_list_preco,
        l_pct_desc_adic    LIKE ped_itens.pct_desc_adic,
        l_den_item_aux     LIKE cliente_item.cod_item_cliente,
        l_cod_tip_carteira LIKE tipo_carteira.cod_tip_carteira
  IF p_num_pedido = p_om_item.num_pedido THEN
    LET p_relat_item.num_pedido = 0
  ELSE
    LET p_relat_item.num_pedido = p_om_item.num_pedido
    LET p_num_pedido            = p_om_item.num_pedido
  END IF
  LET m_ies_ctr_lote = " "
  LET p_qtd_decimais = p_par_vdp.par_vdp_txt[43,43]
  LET p_relat_item.num_sequencia = p_om_item.num_sequencia
  LET p_relat_item.cod_item      = p_om_item.cod_item
  LET p_relat_item.qtd_reservada = p_om_item.qtd_reservada
  LET p_relat_item.qtd_volume_m3 = p_om_item.qtd_volume_item

  WHENEVER ERROR CONTINUE
  SELECT UNIQUE item.den_item, item.pes_unit, item.cod_unid_med, item.ies_ctr_lote
    INTO p_relat_item.den_item, l_pes_unit, p_relat_item.cod_unid_med, m_ies_ctr_lote
    FROM item
   WHERE item.cod_item        = p_om_item.cod_item
     AND item.cod_empresa     = p_cod_empresa
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","ITEM")
  END IF

  IF sqlca.sqlcode = 100 THEN
    INITIALIZE p_relat_item.* TO NULL
  END IF

  WHENEVER ERROR CONTINUE
  SELECT UNIQUE item_embalagem.qtd_padr_embal
    INTO p_relat_item.qtd_padr_embal
    FROM item_embalagem
   WHERE item_embalagem.cod_empresa    = p_cod_empresa
     AND item_embalagem.cod_item       = p_om_item.cod_item
     AND item_embalagem.ies_tip_embal IN ("N", "I")
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","ITEM")
  END IF

  IF sqlca.sqlcode = 100 THEN
    LET p_relat_item.qtd_padr_embal = NULL
  END IF

  IF m_orig_denomin_item_impr_om = "1" THEN
    WHENEVER ERROR CONTINUE
    SELECT cod_item_cliente
      INTO l_den_item_aux
      FROM cliente_item
     WHERE cod_empresa = p_cod_empresa
       AND cod_cliente_matriz = p_relat_mest.cod_cliente
       AND cod_item    = p_om_item.cod_item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
       IF l_den_item_aux <> " " AND l_den_item_aux IS NOT NULL THEN
          LET p_relat_item.den_item = l_den_item_aux
       END IF
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT ies_emite_certif
    INTO p_ies_emite_certif
    FROM ped_itens_adic
   WHERE cod_empresa   = p_cod_empresa
     AND num_pedido    = p_om_item.num_pedido
     AND num_sequencia = p_om_item.num_sequencia
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_ies_emite_certif = " "
  END IF
  WHENEVER ERROR CONTINUE
  SELECT qtd_reservada
    INTO p_relat_item.qtd_refer_reserv
    FROM ordem_montag_itref
   WHERE cod_empresa   = p_cod_empresa
     AND num_om        = p_om_item.num_om
     AND num_pedido    = p_om_item.num_pedido
     AND num_sequencia = p_om_item.num_sequencia
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
    LET p_relat_item.qtd_refer_reserv = 0
  END IF
  IF p_om_item.ies_bonificacao = "N" THEN
    WHENEVER ERROR CONTINUE
    SELECT pedidos.pct_desc_adic, pedidos.num_list_preco, ped_itens.pre_unit,
            ped_itens.pct_desc_adic, pedidos.cod_tip_carteira
       INTO p_relat_item.pct_desc_adic_mest, l_num_list_preco, p_relat_item.pre_unit,
            p_relat_item.pct_desc_adic, l_cod_tip_carteira
       FROM pedidos,ped_itens
      WHERE pedidos.cod_empresa     = p_cod_empresa
        AND pedidos.num_pedido      = p_om_item.num_pedido
        AND ped_itens.cod_empresa   = pedidos.cod_empresa
        AND ped_itens.num_pedido    = pedidos.num_pedido
        AND ped_itens.num_sequencia = p_om_item.num_sequencia
        AND ped_itens.cod_item      = p_om_item.cod_item
    WHENEVER ERROR STOP
    CALL vdp784_busca_desc_adic_unico(p_cod_empresa, p_om_item.num_pedido, 0,
                                      p_relat_item.pct_desc_adic_mest) RETURNING p_relat_item.pct_desc_adic_mest
    CALL vdp784_busca_desc_adic_unico(p_cod_empresa, p_om_item.num_pedido, p_om_item.num_sequencia,
                                      p_relat_item.pct_desc_adic) RETURNING p_relat_item.pct_desc_adic
  ELSE
    WHENEVER ERROR CONTINUE
    SELECT pedidos.pct_desc_adic, pedidos.num_list_preco, ped_itens_bnf.pre_unit,
           ped_itens_bnf.pct_desc_adic, pedidos.cod_tip_carteira
      INTO p_relat_item.pct_desc_adic_mest, l_num_list_preco, p_relat_item.pre_unit,
           p_relat_item.pct_desc_adic, l_cod_tip_carteira
      FROM pedidos,ped_itens_bnf
     WHERE pedidos.cod_empresa         = p_cod_empresa
       AND pedidos.num_pedido          = p_om_item.num_pedido
       AND ped_itens_bnf.cod_empresa   = pedidos.cod_empresa
       AND ped_itens_bnf.num_pedido    = pedidos.num_pedido
       AND ped_itens_bnf.num_sequencia = p_om_item.num_sequencia
       AND ped_itens_bnf.cod_item      = p_om_item.cod_item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_relat_item.* TO NULL
    END IF
  END IF
  IF p_par_vdp.par_vdp_txt[204,204] = "S" THEN
    IF l_num_list_preco <> 0 THEN
    ELSE
      LET p_pct_desp_finan = 1
    END IF
  END IF
  IF p_par_vdp.par_vdp_txt[352,352] = "S" THEN
    LET p_pct_desp_finan = 1
  END IF

  IF p_pct_desp_finan = 0 THEN
     LET p_pct_desp_finan = 1
  END IF

  IF p_om_item.ies_bonificacao = "N" THEN
    CASE
      WHEN p_qtd_decimais = 1
           LET l_pre_unit1 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit1
      WHEN p_qtd_decimais = 2
           LET l_pre_unit2 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit2
      WHEN p_qtd_decimais = 3
           LET l_pre_unit3 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit3
      WHEN p_qtd_decimais = 4
           LET l_pre_unit4 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit4
      WHEN p_qtd_decimais = 5
           LET l_pre_unit5 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit5
      WHEN p_qtd_decimais = 6
           LET l_pre_unit6 = p_relat_item.pre_unit * p_pct_desp_finan
           LET l_pre_unit = l_pre_unit6
    END CASE
  ELSE
    LET l_pre_unit  = p_relat_item.pre_unit
  END IF
  CALL vdp1519_calcula_pre_unit(l_pre_unit, p_relat_item.pct_desc_adic, p_qtd_decimais)
                                RETURNING l_pre_unit
  CALL vdp1519_calcula_pre_unit(l_pre_unit, p_relat_item.pct_desc_adic_mest, p_qtd_decimais)
                                RETURNING l_pre_unit
  LET p_relat_item.valor_item  = p_relat_item.qtd_reservada * l_pre_unit
  LET p_relat_item.pes_item    = p_relat_item.qtd_reservada * l_pes_unit
  LET p_valor_total            = p_valor_total  + p_relat_item.valor_item
  LET p_qtd_total              = p_qtd_total    + p_relat_item.qtd_reservada
  LET p_peso_total             = p_peso_total   + p_relat_item.pes_item
  LET p_volume_total           = p_volume_total + p_relat_item.qtd_volume_m3
  LET p_relat_item.pre_unit    = l_pre_unit
END FUNCTION

#-----------------------------------------#
 FUNCTION vdp103_inicializa_t2_qtd_embal()
#-----------------------------------------#
  FOR p_ind2 = 1 TO 99
    LET t2_qtd_embal[p_ind2].cod_embal = null
    LET t2_qtd_embal[p_ind2].qtd_embal = null
  END FOR
  LET p_dep2 = 0
END FUNCTION

#-------------------------------------------#
 FUNCTION vdp1030_inicializa_ma_item_embal()
#-------------------------------------------#

  INITIALIZE ma_item_embal TO NULL

 END FUNCTION

#----------------------------------#
 FUNCTION vdp103_tabula_qtd_embal()
#----------------------------------#
  WHENEVER ERROR CONTINUE
  SELECT UNIQUE cod_empresa, num_om, num_sequencia, cod_item, cod_embal_int, qtd_embal_int, cod_embal_ext,
                qtd_embal_ext, ies_lotacao, num_embal_inicio, num_embal_final, qtd_pecas
    INTO p_om_embal.cod_empresa, p_om_embal.num_om, p_om_embal.num_sequencia, p_om_embal.cod_item,
         p_om_embal.cod_embal_int, p_om_embal.qtd_embal_int, p_om_embal.cod_embal_ext,
         p_om_embal.qtd_embal_ext, p_om_embal.ies_lotacao, p_om_embal.num_embal_inicio,
         p_om_embal.num_embal_final, p_om_embal.qtd_pecas
    FROM ordem_montag_embal
   WHERE cod_empresa      = p_cod_empresa
     AND num_om           = p_om_list.num_om
     AND cod_item         = p_om_item.cod_item
     AND num_sequencia    = 1
     AND ies_lotacao      = "T"
     AND num_embal_inicio = 1
     AND num_embal_final  = 1
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_om_embal.* TO NULL
  END IF
  IF p_om_embal.cod_embal_int <> "0" THEN
    FOR p_ind2 = 1 TO p_dep2
      IF t2_qtd_embal[p_ind2].cod_embal = p_om_embal.cod_embal_int AND
         vdp1030_verifica_existencia_item(p_om_item.cod_item) = FALSE THEN
        LET t2_qtd_embal[p_ind2].qtd_embal = t2_qtd_embal[p_ind2].qtd_embal + p_om_embal.qtd_embal_int
        EXIT FOR
      END IF
    END FOR
    IF p_ind2 > p_dep2 AND
       vdp1030_verifica_existencia_embal(p_om_embal.cod_embal_int) = FALSE THEN
      LET p_dep2 = p_ind2
      LET t2_qtd_embal[p_ind2].cod_embal = p_om_embal.cod_embal_int
      LET t2_qtd_embal[p_ind2].qtd_embal = p_om_embal.qtd_embal_int
    END IF
  END IF
  IF p_om_embal.cod_embal_ext <> "0" THEN
    FOR p_ind2 = 1 TO p_dep2
      IF t2_qtd_embal[p_ind2].cod_embal = p_om_embal.cod_embal_ext AND
         vdp1030_verifica_existencia_item(p_om_item.cod_item) = FALSE THEN
        LET t2_qtd_embal[p_ind2].qtd_embal = t2_qtd_embal[p_ind2].qtd_embal + p_om_embal.qtd_embal_ext
        EXIT FOR
      END IF
    END FOR
    IF p_ind2 > p_dep2 AND vdp1030_verifica_existencia_embal(p_om_embal.cod_embal_ext) = FALSE THEN
      LET p_dep2 = p_ind2
      LET t2_qtd_embal[p_ind2].cod_embal = p_om_embal.cod_embal_ext
      LET t2_qtd_embal[p_ind2].qtd_embal = p_om_embal.qtd_embal_ext
    END IF
  END IF
  CALL vdp1030_insere_item_embal(p_om_item.cod_item, p_om_embal.cod_embal_int, p_om_embal.cod_embal_ext)

END FUNCTION

#--------------------------#
REPORT vdp103_relat(p_relat)
#--------------------------#
   DEFINE p_num_pedido_aux       LIKE pedidos.num_pedido,
          p_ies_impr_obs         SMALLINT,
          p_relat                CHAR(15),
       	  p_ordem_montag_obs     RECORD LIKE ordem_montag_obs.*
   DEFINE l_item_onu             CHAR(27) #OS 337056

   DEFINE l_ind                  INTEGER,
          l_texto                CHAR(080)
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE LENGTH 66
   FORMAT

   PAGE HEADER
      PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
      PRINT COLUMN   1, p_den_empresa
      SKIP 1 LINE
      PRINT COLUMN   1, "VDP1030",
            COLUMN  31, "O R D E M     D E     M O N T A G E M",
            COLUMN  86, "EMITIDO EM",
            COLUMN  97, p_relat_mest.dat_emis USING "dd/mm/yy",
            COLUMN 110, "NUMERO  ***",
            COLUMN 123, p_relat_mest.num_om   USING "&&&&&&",
            COLUMN 130, "***"
      #INICIO OS 358122
      IF p_relat_mest.num_lote_om > 0 THEN
        PRINT COLUMN 112, "LOTE  ***",
              COLUMN 123, p_relat_mest.num_lote_om   USING "&&&&&&",
              COLUMN 130, "***"
      ELSE
        PRINT COLUMN 112, " "
      END IF
      #FIM OS 358122
      PRINT COLUMN  96, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      PRINT COLUMN   1, "-----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "--------------------------------------"
      PRINT COLUMN   3, "CLIENTE:",
            COLUMN  12, p_relat_mest.cod_cliente,
            COLUMN  33, p_relat_mest.nom_cliente,
            COLUMN  70, "MARCA:",
            COLUMN  77, p_relat_mest.den_marca,
            COLUMN 100, "ROTA:",
            COLUMN 105, p_relat_mest.cod_rota USING "####&",
            COLUMN 111, "TELEF.:", p_relat_mest.num_telefone
      PRINT COLUMN   2, "ENDERECO:",
            COLUMN  12, p_relat_mest.end_cliente,
            COLUMN  69, "BAIRRO:",
            COLUMN  77, p_relat_mest.den_bairro,
            COLUMN 105, p_relat_mest.den_rota
      PRINT COLUMN   1, "MUNICIPIO:",
            COLUMN  12, p_relat_mest.den_cidade,
            COLUMN  73, "UF:",
            COLUMN  77, p_relat_mest.cod_uni_feder,
            COLUMN  98, "C.E.P.:",
            COLUMN 112, p_relat_mest.cod_cep
      PRINT COLUMN   4, "C.G.C.:",
            COLUMN  12, p_relat_mest.num_cgc_cpf,
            COLUMN  64, "INSCR. EST.:",
            COLUMN  77, p_relat_mest.ins_estadual,
            COLUMN  99, "REPR.:",
            COLUMN 106, p_relat_mest.cod_repres USING "####",
            COLUMN 112, p_relat_mest.nom_guerra
      PRINT COLUMN   1, "-----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "--------------------------------------"
      PRINT COLUMN   1, "CONSIGNAT.:",
            COLUMN  13, p_relat_mest.cod_consig,
            COLUMN  28, " - ",
            COLUMN  31, p_relat_mest.den_consig
      PRINT COLUMN   3, "ENDERECO:",
            COLUMN  13, p_relat_mest.end_consig,
            COLUMN  64, "BAIRRO:",
            COLUMN  72, p_relat_mest.den_bairro_consig
      PRINT COLUMN   2, "MUNICIPIO:",
            COLUMN  13, p_relat_mest.den_cidade_consig,
            COLUMN  64, "ESTADO:",
            COLUMN  72, p_relat_mest.cod_uni_feder_consig
      PRINT COLUMN   1, "-----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "--------------------------------------"
      PRINT COLUMN   1, "TRANSPORT:",
            COLUMN  13, p_relat_mest.cod_transpor,
            COLUMN  28, " - ",
            COLUMN  31, p_relat_mest.den_transpor
      PRINT COLUMN   1, "-----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "--------------------------------------"
      PRINT COLUMN   4, "ENTREGA:",
            COLUMN  12, p_relat_mest.end_entrega,
            COLUMN  64, "BAIRRO:",
            COLUMN  72, p_relat_mest.den_bairro_ent
      PRINT COLUMN   2, "MUNICIPIO:",
            COLUMN  13, p_relat_mest.den_cidade_ent,
            COLUMN  64, "ESTADO:",
            COLUMN  72, p_relat_mest.cod_uni_feder_ent
      PRINT COLUMN   1, "*----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "------------------------------------*"
      PRINT COLUMN   1, "I  PEDIDO  ITEM PRODUTO         DESCRICAO           ",
                        "                                                    ",
                        "        ENTREGA           I"
      PRINT COLUMN   1, "I     QUANTIDADE  QTDE A FATUR  UN  PADRAO EMBAL.   ",
                        "VOLUME  PESO ITEM. DESC.ADIC.MT  DESC.ADIC.IT  ",
                        "PRECO UNITARIO     PRECO TOTAL I"
      PRINT COLUMN   1, "I----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "------------------------------------I"
      LET p_imp_mestre = FALSE
   ON EVERY ROW

      CALL vdp1030_busca_estoque_pedido_item(p_cod_empresa,
                                             p_om_item.num_pedido,
                                             p_relat_item.cod_item)


      IF p_relat = "MESTRE" OR p_imp_mestre = TRUE THEN
        SKIP TO TOP OF PAGE
      END IF
      IF p_relat = "DETALHE" THEN
        NEED 2 LINES
        IF LINENO > 63 THEN
          SKIP TO TOP OF PAGE
        END IF
        PRINT COLUMN   1, "I",
              COLUMN   4, p_relat_item.num_pedido     USING "######",
              COLUMN  11, p_relat_item.num_sequencia  USING "#####",
              COLUMN  17, p_relat_item.cod_item,
              COLUMN  33, p_relat_item.den_item,
              COLUMN 113, m_prz_entrega,
              COLUMN 131, "I"

        IF find4glfunction("vdpy287_grava_endereco_item") THEN
           IF vdpy287_grava_endereco_item(p_cod_empresa,
                                          p_om_item.num_om,
                                          p_om_item.num_pedido,
                                          p_om_item.num_sequencia,
                                          p_om_item.cod_item,
                                          "N") THEN
              FOR l_ind = 1 TO 99
                 LET l_texto = ""
                 LET l_texto = vdpy287_busca_endereco_item(l_ind)
                 IF l_texto = "" OR
                    l_texto IS NULL THEN
                    EXIT FOR
                 ELSE
                    PRINT COLUMN 001, "I",
                          COLUMN 033, l_texto CLIPPED,
                          COLUMN 131, "I"
                 END IF
              END FOR
           END IF
        END IF

        CALL vdp1030_busca_texto_item(p_relat_item.cod_item)
        IF p_cli_item_txt.den_texto_1 IS NOT NULL THEN
          PRINT COLUMN   1, "I",
                COLUMN 33, p_cli_item_txt.den_texto_1,
                COLUMN 131, "I"
        END IF
        IF p_cli_item_txt.den_texto_2 IS NOT NULL THEN
          PRINT COLUMN   1, "I",
                COLUMN 33, p_cli_item_txt.den_texto_2,
                COLUMN 131, "I"
        END IF
        IF p_cli_item_txt.den_texto_3 IS NOT NULL THEN
          PRINT COLUMN   1, "I",
                COLUMN 33, p_cli_item_txt.den_texto_3,
                COLUMN 131, "I"
        END IF
        IF p_cli_item_txt.den_texto_4 IS NOT NULL THEN
          PRINT COLUMN   1, "I",
                COLUMN 33, p_cli_item_txt.den_texto_4,
                COLUMN 131, "I"
        END IF
        IF p_cli_item_txt.den_texto_5 IS NOT NULL THEN
          PRINT COLUMN   1, "I",
                COLUMN 33, p_cli_item_txt.den_texto_5,
                COLUMN 131, "I"
        END IF
        #OS 337056
        WHENEVER ERROR CONTINUE
        SELECT item
          FROM fat_item_emerg
         WHERE empresa = p_cod_empresa
           AND item    = p_relat_item.cod_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
           LET l_item_onu = "ITEM CONTROLADO OU PERIGOSO"
           PRINT COLUMN   1, "I ",
                 COLUMN  33, l_item_onu,
                 COLUMN 130, " I"
        ELSE
           WHENEVER ERROR CONTINUE
           SELECT item
             FROM fat_item_controle
            WHERE empresa = p_cod_empresa
              AND item    = p_relat_item.cod_item
           WHENEVER ERROR STOP
           IF sqlca.sqlcode = 0 THEN
              LET l_item_onu = "ITEM CONTROLADO OU PERIGOSO"
              PRINT COLUMN   1, "I ",
                    COLUMN  33, l_item_onu,
                    COLUMN 130, " I"
           END IF
        END IF
        #OS 337056
        PRINT COLUMN   1, "I",
              COLUMN   3, p_relat_item.qtd_reservada   USING "##,###,##&.&&&",
              COLUMN  19, "...........",
              COLUMN  33, p_relat_item.cod_unid_med,
              COLUMN  37, p_relat_item.qtd_padr_embal  USING "####,##&.&&&",
              COLUMN  50, p_relat_item.qtd_volume_m3   USING "####&.&&&",
              COLUMN  60, p_relat_item.pes_item        USING "######&.&&&&",
              COLUMN  76, p_relat_item.pct_desc_adic_mest USING "#&.&&",
              COLUMN  90, p_relat_item.pct_desc_adic   USING "#&.&&",
              COLUMN  99, p_relat_item.pre_unit        USING "#######&.&&&&&&",
              COLUMN 116, p_relat_item.valor_item      USING "##########&.&&",
              COLUMN 131, "I"

        IF m_local_por_item = TRUE THEN
           CALL vdp103_busca_loc_estoq()
           PRINT COLUMN 01, "I",
                 COLUMN 04, "LOCAL ESTOQUE:",
                 COLUMN 19, m_local_estoque CLIPPED ," - ",
                 COLUMN 32, p_den_local_estoq CLIPPED,
                 COLUMN 131, "I"
        END IF

        IF p_ies_emite_certif = "1" OR
           p_ies_emite_certif = "3" THEN
          PRINT COLUMN 001, "I",
                COLUMN 003, "*** Emitir Certificado de Analise para este ",
                            "Item. ***",
                COLUMN 131, "I"
        END IF
      END IF
   IF p_relat = "RASTREAB" THEN
     IF m_num_serie IS NULL OR m_num_serie = " " THEN
     IF NOT m_retorno_vdpr177 THEN
        IF NOT m_imp_tit_rast THEN
          LET m_imp_tit_rast = TRUE
          PRINT COLUMN 001, "I",
                COLUMN 017, "Local",
                COLUMN 033, "Lote",
                COLUMN 054, "  Qtd. Reservada",
                COLUMN 075, "   Qtd. Atendida",
                COLUMN 131, "I"
          PRINT COLUMN 001, "I",
                COLUMN 017, "----------",
                COLUMN 033, "---------------",
                COLUMN 054, "----------------",
                COLUMN 075, "----------------",
                COLUMN 131, "I"
        END IF
        PRINT COLUMN 001, "I",
              COLUMN 017, mr_rastreab.cod_local,
              COLUMN 033, mr_rastreab.num_lote,
              COLUMN 054, mr_rastreab.qtd_reservada USING "###########&.&&&",
              COLUMN 075, mr_rastreab.qtd_atendida USING "###########&.&&&",
              COLUMN 131, "I"
           ELSE
           IF NOT m_imp_tit_rast THEN
             LET m_imp_tit_rast = TRUE
             PRINT COLUMN 001, "I",
                   COLUMN 017, "Local",
                   COLUMN 033, "Lote",
                   COLUMN 049, "Endereco",
                   COLUMN 065, "Identificador Estoque",
                   COLUMN 098, "Qtd. Reservada",
                   COLUMN 116, "Qtd. Atendida",
                   COLUMN 131, "I"
             PRINT COLUMN 001, "I",
                   COLUMN 017, "----------",
                   COLUMN 033, "---------------",
                   COLUMN 049, "---------------",
                   COLUMN 065, "------------------------------",
                   COLUMN 097, "----------------",
                   COLUMN 114, "----------------",
                   COLUMN 131, "I"
           END IF
           PRINT COLUMN 001, "I",
                 COLUMN 017, mr_rastreab.cod_local,
                 COLUMN 033, mr_rastreab.num_lote,
                 COLUMN 049, m_endereco,
                 COLUMN 065, m_identif_estoque,
                 COLUMN 096, mr_rastreab.qtd_reservada USING "###########&.&&&",
                 COLUMN 114, mr_rastreab.qtd_atendida USING "###########&.&&&",
                 COLUMN 131, "I"
        END IF
     ELSE
        IF NOT m_retorno_vdpr177 THEN
           IF NOT m_imp_tit_rast THEN
             LET m_imp_tit_rast = TRUE
             PRINT COLUMN 001, "I",
                   COLUMN 017, "Local",
                   COLUMN 033, "Lote",
                   COLUMN 050, "Serie",
                   COLUMN 070, "  Qtd. Reservada",
                   COLUMN 090, "   Qtd. Atendida",
                   COLUMN 131, "I"
             PRINT COLUMN 001, "I",
                   COLUMN 017, "----------",
                   COLUMN 033, "---------------",
                   COLUMN 050, "---------------",
                   COLUMN 070, "----------------",
                   COLUMN 090, "----------------",
                   COLUMN 131, "I"
           END IF
          PRINT COLUMN 001, "I",
                 COLUMN 017, mr_rastreab.cod_local,
                 COLUMN 033, mr_rastreab.num_lote,
                 COLUMN 050, m_num_serie,
                 COLUMN 070, mr_rastreab.qtd_reservada USING "###########&.&&&",
                 COLUMN 090, mr_rastreab.qtd_atendida USING "###########&.&&&",
                 COLUMN 131, "I"
        ELSE
           IF NOT m_imp_tit_rast THEN
             LET m_imp_tit_rast = TRUE
             PRINT COLUMN 001, "I",
                COLUMN 017, "Local",
                COLUMN 033, "Lote",
                COLUMN 049, "Endereco",
                COLUMN 065, "Identificador Estoque",
                COLUMN 098, "Qtd. Reservada",
                COLUMN 116, "Qtd. Atendida",
                COLUMN 131, "I"
          PRINT COLUMN 001, "I",
                COLUMN 017, "----------",
                COLUMN 033, "---------------",
                COLUMN 049, "---------------",
                COLUMN 065, "------------------------------",
                COLUMN 097, "----------------",
                COLUMN 114, "----------------",
                COLUMN 131, "I"
        END IF
        PRINT COLUMN 001, "I",
              COLUMN 017, mr_rastreab.cod_local,
              COLUMN 033, mr_rastreab.num_lote,
              COLUMN 049, m_endereco,
              COLUMN 065, m_identif_estoque,
              COLUMN 096, mr_rastreab.qtd_reservada USING "###########&.&&&",
              COLUMN 114, mr_rastreab.qtd_atendida USING "###########&.&&&",
              COLUMN 131, "I"
        END IF
     END IF

   END IF
   IF p_relat = "GRADE" THEN
     PRINT COLUMN 001, "I",
           COLUMN 017, ma_ctr_grade[1].den_grade CLIPPED, " ", ma_ctr_grade[1].den_cod_grade CLIPPED, "   ",
                       ma_ctr_grade[2].den_grade CLIPPED, " ", ma_ctr_grade[2].den_cod_grade CLIPPED, "   ",
                       ma_ctr_grade[3].den_grade CLIPPED, " ", ma_ctr_grade[3].den_cod_grade CLIPPED, "   ",
                       ma_ctr_grade[4].den_grade CLIPPED, " ", ma_ctr_grade[4].den_cod_grade CLIPPED, "   ",
                       ma_ctr_grade[5].den_grade CLIPPED, " ", ma_ctr_grade[5].den_cod_grade CLIPPED,
           COLUMN 131, "I"
     PRINT COLUMN 001, "I",
           COLUMN 017, "QTDE: ", mr_om_grade.qtd_reservada USING "##,###,##&.&&&",
           COLUMN 131, "I"
   END IF
   #O.S 405745
   IF p_relat = "RETORNO" THEN
      PRINT COLUMN 001, "I",
            COLUMN 003, "QTDE PREST CONTAS ", m_num_prest_cta CLIPPED, ": ",
            COLUMN 017, m_qtd_prest_cta USING "##,###,##&.&&&",
            COLUMN 131, "I"
   END IF
   #O.S 405745
   IF p_relat = "BNF" THEN
      PRINT COLUMN 001, "I----------------------------------------------",
            COLUMN 048, "-----------------------------------------------",
            COLUMN 095, "------------------------------------I"
      PRINT COLUMN 001,"I",
            COLUMN 052, "*** ITENS DE BONIFICACAO *** ",
            COLUMN 131,"I"
   END IF
   IF p_relat = "ESTRVDP" THEN
     IF m_prim_vez_comp = TRUE THEN
       PRINT COLUMN   1, "I",
             COLUMN  17, "COMPONENTE",
             COLUMN  33, "UN",
             COLUMN  37, "SERIE",
             COLUMN  63, "QTDE. RESERVADA",
             COLUMN 131, "I"
       PRINT COLUMN   1, "I",
             COLUMN  17, "---------------",
             COLUMN  33, "---",
             COLUMN  37, "-------------------------",
             COLUMN  63, "---------------",
             COLUMN 131, "I"
       LET m_prim_vez_comp = FALSE
     END IF
     PRINT COLUMN   1, "I",
           COLUMN  17, mr_est_compon.item,
           COLUMN  33, mr_est_compon.cod_unid_med,
           COLUMN  37, mr_est_compon.num_serie,
           COLUMN  63, mr_est_compon.qtd_reservada USING "###,###,##&.&&&",
           COLUMN 131, "I"
   END IF

   IF p_relat = "TOTAL" THEN
     PRINT COLUMN   1, "I----------------------------------------------",
           COLUMN  48, "-----------------------------------------------",
           COLUMN  95, "------------------------------------I"
     PRINT COLUMN   1, "I",
           COLUMN   7, "T O T A L",
           COLUMN  31, p_qtd_total    USING "####,##&.&&&",
           COLUMN  50, p_volume_total USING "####&.&&&",
           COLUMN  60, p_peso_total   USING "######&.&&&&",
           COLUMN 116, p_valor_total  USING "##########&.&&",
           COLUMN 131, "I"
     PRINT COLUMN   1, "*----------------------------------------------",
           COLUMN  48, "-----------------------------------------------",
           COLUMN  95, "------------------------------------*"
     LET p_ies_impr_obs = FALSE

     WHENEVER ERROR CONTINUE
     SELECT den_obs_1, den_obs_2, den_obs_3, den_obs_4, den_obs_5
       INTO p_ordem_montag_obs.den_obs_1, p_ordem_montag_obs.den_obs_2,
            p_ordem_montag_obs.den_obs_3, p_ordem_montag_obs.den_obs_4,
            p_ordem_montag_obs.den_obs_5
       FROM ordem_montag_obs
      WHERE cod_empresa = p_cod_empresa
        AND num_om      = p_relat_mest.num_om
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
       PRINT COLUMN   2, "OBSERVACOES DA O.M.",
	            COLUMN  23, p_ordem_montag_obs.den_obs_1
	      PRINT COLUMN  23, p_ordem_montag_obs.den_obs_2
	      PRINT COLUMN  23, p_ordem_montag_obs.den_obs_3
	      PRINT COLUMN  23, p_ordem_montag_obs.den_obs_4
	      PRINT COLUMN  23, p_ordem_montag_obs.den_obs_5
       LET p_ies_impr_obs = TRUE
     ELSE
       WHENEVER ERROR CONTINUE
       DECLARE cq_ped_obs CURSOR FOR
        SELECT UNIQUE num_pedido
          FROM ordem_montag_item
         WHERE cod_empresa     = p_cod_empresa
           and num_om          = p_relat_mest.num_om
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DECLARE","CQ_PED_OBS")
       END IF
       WHENEVER ERROR CONTINUE
       FOREACH cq_ped_obs INTO p_num_pedido_aux
       WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
           EXIT FOREACH
         END IF
         WHENEVER ERROR CONTINUE
         SELECT den_texto_1, den_texto_2, den_texto_3, den_texto_4, den_texto_5
           INTO p_ordem_montag_obs.den_obs_1, p_ordem_montag_obs.den_obs_2, p_ordem_montag_obs.den_obs_3,
                p_ordem_montag_obs.den_obs_4, p_ordem_montag_obs.den_obs_5
           FROM ped_itens_texto
          WHERE cod_empresa   = p_cod_empresa
            AND num_pedido    = p_num_pedido_aux
            AND num_sequencia = 0
         WHENEVER ERROR STOP
         IF sqlca.sqlcode = 0 THEN
           LET p_ies_impr_obs = TRUE
           PRINT COLUMN   2, "OBS PEDIDO: ", p_num_pedido_aux,
     	           COLUMN  23, p_ordem_montag_obs.den_obs_1
	          PRINT COLUMN  23, p_ordem_montag_obs.den_obs_2
	          PRINT COLUMN  23, p_ordem_montag_obs.den_obs_3
	          PRINT COLUMN  23, p_ordem_montag_obs.den_obs_4
	          PRINT COLUMN  23, p_ordem_montag_obs.den_obs_5
         END IF
       END FOREACH
       FREE cq_ped_obs
     END IF
     IF p_ies_impr_obs THEN
       PRINT COLUMN   1, "-----------------------------------------------",
             COLUMN  48, "-----------------------------------------------",
             COLUMN  95, "--------------------------------------"
     END IF
     SKIP 1 LINE
     PRINT COLUMN   1, "TRANSPORTADORA : .....     PLACA : ..........",
           COLUMN  51, "FRETE POSTO :",
           COLUMN  65, p_frete_posto,
           COLUMN  82, "FRETE :",
           COLUMN  89, p_des_frete,
           COLUMN 107, "CND. PGTO :",
           COLUMN 119, p_cod_cnd_pgto
     SKIP 1 LINE
     PRINT COLUMN   1, "COD. EMBAL 1 :    ",t2_qtd_embal[1].cod_embal,
           COLUMN  24, "COD. EMBAL 2 :    ",t2_qtd_embal[2].cod_embal,
           COLUMN  47, "COD. EMBAL 3 :    ",t2_qtd_embal[3].cod_embal,
           COLUMN  70, "COD. EMBAL 4 :    ",t2_qtd_embal[4].cod_embal,
           COLUMN  93, "COD. EMBAL 5 :    ",t2_qtd_embal[5].cod_embal
     PRINT COLUMN   1, "QTD. EMBAL 1 : ", t2_qtd_embal[1].qtd_embal USING "&&&&&",
           COLUMN  24, "QTD. EMBAL 2 : ", t2_qtd_embal[2].qtd_embal USING "&&&&&",
           COLUMN  47, "QTD. EMBAL 3 : ", t2_qtd_embal[3].qtd_embal USING "&&&&&",
           COLUMN  70, "QTD. EMBAL 4 : ", t2_qtd_embal[4].qtd_embal USING "&&&&&",
           COLUMN  93, "QTD. EMBAL 5 : ", t2_qtd_embal[5].qtd_embal USING "&&&&&"
      PRINT COLUMN  1, "Nrs VOLUMES : ......./......"
      SKIP 1 LINE
      PRINT COLUMN  1, "OPERACAO : ", p_relat_mest.cod_nat_oper USING "#&&&",
                        " - ", p_relat_mest.den_nat_oper,
            COLUMN 50, "FINALIDADE : ", p_relat_mest.ies_finalidade
                                                                 USING "##"
      PRINT COLUMN  1, "   MOEDA : ", p_relat_mest.cod_moeda USING "&&&",
                        " - ", p_relat_mest.den_moeda
      FOR p_dig = 1 TO p_aux
        CALL vdp103_busca_num_om()
        LET p_valor_saldo = 0
        CALL vdp103_busca_saldo_pedido()
        CALL vdp103_busca_tip_carteira()
        IF p_con_pedido[p_dig].num_pedido <> 0 AND
           p_con_pedido[p_dig].conta      <> 0 THEN
          PRINT COLUMN 1, "  PEDIDO : ", p_con_pedido[p_dig].num_pedido USING "#####&",
                          "  ","- QTD. OMS =", p_con_pedido[p_dig].conta,
                          "  ","- VALOR SALDO PEDIDO =", p_valor_saldo
          PRINT COLUMN 1, " CARTEIRA: ", p_saldo.cod_tip_carteira, " -  ",
                          p_den_tip_carteira
        END IF
      END FOR
      SKIP 1 LINE
      PRINT COLUMN 1, "OBSERVACOES :";
      IF p_ind = 0 THEN
         PRINT " "
      END IF
      FOR p_dep = 1 TO p_ind
        PRINT COLUMN  14, t1_pedido[p_dep].num_pedido USING "#####&", "  ",
                          t1_pedido[p_dep].tex_observ_1
        IF t1_pedido[p_dep].tex_observ_2 = " "   OR
           t1_pedido[p_dep].tex_observ_2 IS NULL THEN
        ELSE
          PRINT COLUMN 23, t1_pedido[p_dep].tex_observ_2
        END IF
      END FOR

      IF m_local_por_item = FALSE THEN
         CALL vdp103_busca_loc_estoq()
         PRINT COLUMN  1, "LOCAL ESTOQUE:",
               COLUMN 15, m_local_estoque CLIPPED ," - ",
               COLUMN 28, p_den_local_estoq CLIPPED
      END IF

      SKIP 2 LINE
      PRINT COLUMN  1, "..../..../....      ..........................",
            COLUMN 57, "................................        ",
                        "................/................"
      PRINT COLUMN  6, "DATA                    MONTADOR",
            COLUMN 65, "CONFERENTE                       ",
                        "TRANSPORTADOR - CONFERENTE"
    END IF
    IF p_relat = "ULT_FOLHA" THEN
       SKIP 1 LINE
       PRINT "* * * ULTIMA FOLHA * * *"
    END IF

  PAGE TRAILER
    PRINT " "

END REPORT
{  >>  OS 113783 - INICIO  <<  }
#-------------------------------------------#
 FUNCTION vdp1030_verifica_rastreabilidade(l_indicador)
#-------------------------------------------#
   DEFINE l_num_reserva LIKE ordem_montag_grade.num_reserva
   DEFINE l_indicador   CHAR(15)

   LET m_imp_tit_rast = FALSE

   WHENEVER ERROR CONTINUE
   DECLARE cq_om_grade CURSOR FOR
   SELECT num_reserva
     FROM ordem_montag_grade
    WHERE cod_empresa    = p_om_item.cod_empresa
      AND num_om         = p_om_item.num_om
      AND num_pedido     = p_om_item.num_pedido
      AND num_sequencia  = p_om_item.num_sequencia
      AND cod_item       = p_om_item.cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_OM_GRADE")
   END IF
   WHENEVER ERROR CONTINUE
   FOREACH cq_om_grade INTO l_num_reserva
   WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        EXIT FOREACH
      END IF
      WHENEVER ERROR CONTINUE
      SELECT cod_local, num_lote, qtd_reservada, qtd_atendida
        INTO mr_rastreab.cod_local, mr_rastreab.num_lote,
             mr_rastreab.qtd_reservada, mr_rastreab.qtd_atendida
        FROM estoque_loc_reser
       WHERE cod_empresa = p_om_item.cod_empresa
         AND num_reserva = l_num_reserva
     WHENEVER ERROR STOP
     IF sqlca.sqlcode = 0 THEN
       IF l_num_reserva IS NOT NULL THEN
          CALL vdpr177_verifica_dimensional(p_cod_empresa, p_om_item.cod_item, l_num_reserva)
               RETURNING m_retorno_vdpr177, m_endereco, m_identif_estoque
       END IF
        CALL vdp1030_busca_serie(l_num_reserva) RETURNING m_num_serie
       IF l_indicador = 'RASTREAB' OR
         (l_indicador = 'WMS' AND m_retorno_vdpr177 = TRUE) THEN
         OUTPUT TO REPORT vdp103_relat("RASTREAB")
       END IF
     END IF
   END FOREACH
   FREE cq_om_grade
END FUNCTION
{  >>  OS 113783 - FINAL  <<  }
#-----------------------------------------#
FUNCTION vdp1030_busca_serie(l_num_reserva)
#-----------------------------------------#
  DEFINE l_num_reserva LIKE ordem_montag_grade.num_reserva,
         l_num_serie   LIKE est_loc_reser_end.num_serie

  WHENEVER ERROR CONTINUE
    SELECT num_serie
      INTO l_num_serie
      FROM est_loc_reser_end
     WHERE cod_empresa = p_om_item.cod_empresa
       AND num_reserva = l_num_reserva
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
  END IF

  RETURN l_num_serie

 END FUNCTION

{  >>  OS 191993 - INICIO <<  }
#-------------------------------#
FUNCTION vdp1030_imp_est_compon()
#-------------------------------#
  DEFINE l_num_trans_est LIKE estoque_lote_ender.num_transac
  LET m_prim_vez_comp = TRUE
  WHENEVER ERROR CONTINUE
  DECLARE cq_comp_vdp CURSOR FOR
  SELECT item, qtd_reservada, num_trans_estoque
    FROM ldi_est_comp_vdp
   WHERE empresa        = p_om_item.cod_empresa
     AND ord_montag     = p_om_item.num_om
     AND sequencia_item = p_om_item.num_sequencia
     AND pedido         = p_om_item.num_pedido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("DECLARE","CQ_COMP_VDP")
  END IF
  WHENEVER ERROR CONTINUE
  FOREACH cq_comp_vdp INTO mr_est_compon.item, mr_est_compon.qtd_reservada, l_num_trans_est
  WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
       EXIT FOREACH
     END IF
     INITIALIZE mr_est_compon.num_serie, mr_est_compon.cod_unid_med TO NULL
     WHENEVER ERROR CONTINUE
     SELECT num_serie
       INTO mr_est_compon.num_serie
       FROM estoque_trans_end
      WHERE cod_empresa = p_om_item.cod_empresa
        AND num_transac = l_num_trans_est
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
       LET mr_est_compon.num_serie = " "
     END IF
     WHENEVER ERROR CONTINUE
     SELECT cod_unid_med
       INTO mr_est_compon.cod_unid_med
       FROM item
      WHERE cod_empresa = p_om_item.cod_empresa
        AND cod_item    = mr_est_compon.item
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
       LET mr_est_compon.cod_unid_med = " "
     END IF
     OUTPUT TO REPORT vdp103_relat("ESTRVDP")
  END FOREACH
  FREE cq_comp_vdp
END FUNCTION
{  >>  OS 191993 - FINAL  <<  }

#--------------------------------------------------------------------#
 FUNCTION vdp1030_insere_item_embal(l_item, l_embal_int, l_embal_ext)
#--------------------------------------------------------------------#
  DEFINE l_item         LIKE item.cod_item,
         l_ind          SMALLINT,
         l_embal_int    LIKE embalagem.cod_embal,
         l_embal_ext    LIKE embalagem.cod_embal
  FOR l_ind = 1 TO 100
    IF ma_item_embal[l_ind].cod_item IS NULL THEN
      LET ma_item_embal[l_ind].cod_item  = l_item
      LET ma_item_embal[l_ind].cod_embal_int = l_embal_int
      LET ma_item_embal[l_ind].cod_embal_ext = l_embal_ext
      EXIT FOR
    END IF
  END FOR
END FUNCTION

#--------------------------------------------------#
 FUNCTION vdp1030_verifica_existencia_item(l_item)
#--------------------------------------------------#
  DEFINE l_item         LIKE item.cod_item,
         l_ind          SMALLINT
  FOR l_ind = 1 TO 100
    IF ma_item_embal[l_ind].cod_item IS NULL THEN
      RETURN FALSE
    ELSE
      IF ma_item_embal[l_ind].cod_item  = l_item THEN
        RETURN TRUE
      END IF
    END IF
  END FOR
 RETURN FALSE
END FUNCTION

#--------------------------------------------------#
 FUNCTION vdp1030_verifica_existencia_embal(l_embal)
#--------------------------------------------------#
  DEFINE l_embal        LIKE embalagem.cod_embal,
         l_ind          SMALLINT
  FOR l_ind = 1 TO 100
    IF ma_item_embal[l_ind].cod_embal_int IS NULL OR
       ma_item_embal[l_ind].cod_embal_ext IS NULL THEN
      RETURN FALSE
    ELSE
      IF ma_item_embal[l_ind].cod_embal_int = l_embal OR
         ma_item_embal[l_ind].cod_embal_ext = l_embal THEN
        RETURN TRUE
      END IF
    END IF
  END FOR
  RETURN FALSE
END FUNCTION

#--------------------------------------------------#
 FUNCTION vdp1030_busca_estoque_pedido_item(l_empresa, l_pedido, l_item)
#--------------------------------------------------#
  DEFINE l_empresa LIKE empresa.cod_empresa,
         l_pedido  LIKE pedidos.num_pedido,
         l_item    LIKE item.cod_item

  LET m_local_estoque = " "
  WHENEVER ERROR CONTINUE
  SELECT cod_local_estoq
    INTO m_local_estoque
    FROM pedidos
   WHERE cod_empresa = l_empresa
     AND num_pedido  = l_pedido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR m_local_estoque IS NULL THEN
    LET m_local_estoque = " "
  END IF

  IF m_local_estoque = " " AND m_local_por_item = TRUE THEN
     WHENEVER ERROR CONTINUE
     SELECT cod_local_estoq
       INTO m_local_estoque
       FROM item
      WHERE cod_empresa = l_empresa
        AND cod_item    = l_item
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 OR m_local_estoque IS NULL THEN
       LET m_local_estoque = " "
     END IF
  END IF

END FUNCTION

#-------------------------------#
 FUNCTION vdp1030_version_info()
#-------------------------------#
  RETURN "$Archive: /logix10R2/vendas/vendas/programas/vdp1030.4gl $|$Revision: 7 $|$Date: 8/02/11 13:51 $|$Modtime: 4/02/11 8:38 $" #Informa��es do controle de vers�o do SourceSafe - N�o remover esta linha (FRAMEWORK)
 END FUNCTION

