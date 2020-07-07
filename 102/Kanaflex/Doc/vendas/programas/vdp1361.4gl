###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP1361                                               #
# OBJETIVO: IMPRESSAO DO PEDIDO INTERNO (COPIA DO VDP1360)        #
# AUTOR...: EDUARDO LUIS PRIM                                     #
# DATA....: 14/12/2007                                            #
#-----------------------------------------------------------------#
DATABASE logix
GLOBALS
   DEFINE
      p_par_vdp               RECORD LIKE par_vdp.*,
      p_pedido_list           RECORD LIKE pedido_list.*,
      p_pedidos               RECORD LIKE pedidos.*,
      p_cod_empresa           LIKE empresa.cod_empresa,
      p_den_empresa           LIKE empresa.den_empresa,
      p_user                  LIKE usuario.nom_usuario,
      p_cod_cons_cli          LIKE clientes.cod_consig,
      p_ies_cons, p_last_row  SMALLINT,
      p_page                  SMALLINT,
      p_linhas                SMALLINT,
      p_ies_bonificacao       CHAR(01),
      p_val_cot_moeda         LIKE cotacao.val_cotacao,
      p_cod_tip_carteira_ant  LIKE tipo_carteira.cod_tip_carteira,
      p_val_unit_seguro       LIKE ped_itens.val_seguro_unit,
      p_pct_desc_ipi          LIKE fiscal_par.pct_desc_ipi,
      p_pct_base_ipi          LIKE fiscal_par.pct_desc_base_ipi,
      p_val_unit_frete        DECIMAL(17,6),
      p_qtd_decimais          DECIMAL(01,0),
      p_qtd_decimais_cart     DECIMAL(01,0),
      p_qtd_decimais_par      DECIMAL(01,0),
      p_val_frete_fisc        DECIMAL(15,2),
      p_val_seguro_fisc       DECIMAL(15,2),
      p_val_ipi_seg           DECIMAL(15,2),
      p_val_ipi_fre           DECIMAL(15,2)

   DEFINE p_relatm            RECORD
                              num_pedido        LIKE pedidos.num_pedido,
                              dat_pedido        LIKE pedidos.dat_pedido,
                              cod_cliente       LIKE pedidos.cod_cliente,
                              nom_cliente       LIKE clientes.nom_cliente,
                              num_cgc_cpf       LIKE clientes.num_cgc_cpf,
                              cod_rota          LIKE rotas.cod_rota,
                              den_rota          LIKE rotas.den_rota,
                              cod_repres        LIKE pedidos.cod_repres,
                              raz_social        LIKE representante.raz_social,
                              cod_repres_adic   LIKE pedidos.cod_repres_adic,
                              nom_promotor      LIKE representante.raz_social,
                              end_cliente       LIKE clientes.end_cliente,
                              den_bairro        LIKE clientes.den_bairro,
                              den_cidade        LIKE cidades.den_cidade,
                              cod_cep           LIKE clientes.cod_cep,
                              cod_uni_feder     LIKE cidades.cod_uni_feder,
                              end_entrega       LIKE ped_end_ent.end_entrega,
                              den_cidade_ent    LIKE cidades.den_cidade,
                              cod_cep_ent       LIKE ped_end_ent.cod_cep,
                              den_frete_posto   LIKE clientes.den_frete_posto,
                              den_marca         LIKE clientes.den_marca,
                              cod_transpor      LIKE pedidos.cod_transpor,
                              den_transpor      LIKE transport.den_transpor,
                              cod_consig        LIKE pedidos.cod_transpor,
                              den_consig        LIKE transport.den_transpor,
                              num_telefone      LIKE transport.num_telefone,
                              des_frete         CHAR(15),
                              des_sit_pedido    CHAR(15),
                              des_preco         CHAR(15),
                              des_aceite_comerc CHAR(03),
                              des_aceite_financ CHAR(03),
                              des_tip_pedido    CHAR(15),
                              des_finalidade    CHAR(30),
                              des_entrega       CHAR(20),
                              den_operac        CHAR(30),
                              den_tip_venda     CHAR(20),
                              des_embalagem     CHAR (020),
                              prioridade        CHAR (003),
                              den_cnd_pgto      LIKE cond_pgto.den_cnd_pgto,
                              num_pedido_cli    LIKE pedidos.num_pedido_cli,
                              pct_desc_financ   LIKE pedidos.pct_desc_financ,
                              pct_comissao      LIKE pedidos.pct_comissao,
                              dat_emis_repres   LIKE pedidos.dat_emis_repres,
                              num_pedido_repres LIKE pedidos.num_pedido_repres,
                              pct_desc_adic     LIKE pedidos.pct_desc_adic,
                              num_list_preco    LIKE pedidos.num_list_preco,
                              cod_tip_venda     LIKE pedidos.cod_tip_venda,
                              cod_moeda         LIKE pedidos.cod_moeda,
                              den_moeda         LIKE moeda.den_moeda,
                              pct_frete         LIKE pedidos.pct_frete,
                              cod_nat_oper      LIKE nat_operacao.cod_nat_oper,
                              cod_local_estoq   LIKE pedidos.cod_local_estoq,
                              den_local_estoq   LIKE local.den_local,
                              cod_tip_carteira  LIKE tipo_carteira.cod_tip_carteira,
                              den_tip_carteira  LIKE tipo_carteira.den_tip_carteira
                              END RECORD

   DEFINE p_peso_total        DECIMAL(12,5),
          p_qtd_pecas_total   DECIMAL(15,0),
          p_pre_unit          LIKE ped_itens.pre_unit,
          p_pre_unit1         DECIMAL(17,1),
          p_pre_unit2         DECIMAL(17,2),
          p_pre_unit3         DECIMAL(17,3),
          p_pre_unit4         DECIMAL(17,4),
          p_pre_unit5         DECIMAL(17,5),
          p_pre_unit6         DECIMAL(17,6),
          p_valor_total_liq   DECIMAL(15,2),
          p_valor_total_bru   DECIMAL(15,2),
          p_valor_total_fre   DECIMAL(15,2),
          p_valor_total_seg   DECIMAL(15,2),
          p_valor_ipi         DECIMAL(15,2),
          p_valor_base_ipi    DECIMAL(15,2),
          p_valor_total_ipi   DECIMAL(15,2),
          p_tot_ipi_fre       DECIMAL(15,2),
          p_pes_unit          DECIMAL(12,5),
          p_den_item          CHAR(78),
          p_den_item_1        CHAR(26),
          p_den_item_2        CHAR(26),
          p_den_item_3        CHAR(26),
          p_cod_unid_med      CHAR(03),
          p_pct_desp_finan    LIKE cond_pgto.pct_desp_finan

   DEFINE p_relato            RECORD
                              tex_observ_1     LIKE ped_observacao.tex_observ_1,
                              tex_observ_2     LIKE ped_observacao.tex_observ_2
                              END RECORD
   DEFINE p_itens             RECORD
                              cod_empresa       LIKE ped_itens.cod_empresa,
                              num_pedido        LIKE ped_itens.num_pedido,
                              num_sequencia     LIKE ped_itens.num_sequencia,
                              cod_item          LIKE ped_itens.cod_item     ,
                              pct_desc_adic     LIKE ped_itens.pct_desc_adic,
                              pre_unit          LIKE ped_itens.pre_unit     ,
                              qtd_pecas_solic   LIKE ped_itens.qtd_pecas_solic,
                              qtd_pecas_atend   LIKE ped_itens.qtd_pecas_atend,
                              qtd_pecas_cancel  LIKE ped_itens.qtd_pecas_cancel,
                              qtd_pecas_reserv  LIKE ped_itens.qtd_pecas_reserv,
                              prz_entrega       LIKE ped_itens.prz_entrega     ,
                              val_desc_com_unit LIKE ped_itens.val_desc_com_unit,
                              val_frete_unit    LIKE ped_itens.val_frete_unit   ,
                              val_seguro_unit   LIKE ped_itens.val_seguro_unit  ,
                              qtd_pecas_romaneio LIKE ped_itens.qtd_pecas_romaneio,
                              pct_desc_bruto    LIKE ped_itens.pct_desc_bruto,
                              pct_ipi           LIKE item.pct_ipi,
                              ies_bonificacao   CHAR(01),
                              pre_unit_liq      LIKE ped_itens.pre_unit,
                              num_serie         LIKE ped_itens_serie.num_serie
                              END RECORD
   DEFINE p_ped_texto         RECORD
                              num_pedido      LIKE ped_itens_texto.num_pedido,
                              num_sequencia   LIKE ped_itens_texto.num_sequencia,
                              den_texto_1     LIKE ped_itens_texto.den_texto_1,
                              den_texto_2     LIKE ped_itens_texto.den_texto_2,
                              den_texto_3     LIKE ped_itens_texto.den_texto_3,
                              den_texto_4     LIKE ped_itens_texto.den_texto_4,
                              den_texto_5     LIKE ped_itens_texto.den_texto_5
                              END RECORD
   DEFINE p_nom_arquivo       CHAR(100),
          p_msg               CHAR(100),
          p_comando           CHAR(080),
          p_caminho           CHAR(080),
          p_nom_tela          CHAR(080),
          p_help              CHAR(080),
          p_cancel            INTEGER,
          p_ies_impressao     CHAR(01),
          g_ies_ambiente      CHAR(01)

   DEFINE g_outer_ifx        CHAR(07),
          g_outer_ora        CHAR(05)

   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS
   DEFINE m_caminho          CHAR(080),
          m_status           SMALLINT

   DEFINE m_tem_texto SMALLINT
   DEFINE m_column_grade1  SMALLINT,
           m_column_grade2  SMALLINT,
           m_column_grade3  SMALLINT,
           m_column_grade4  SMALLINT,
           m_column_grade5  SMALLINT

   DEFINE mr_tela          RECORD
                           ies_embute      CHAR(01),
                           ies_saldo       CHAR(01),
                           ies_texto_item  CHAR(01)
                          #ies_formulario  SMALLINT
                           END RECORD

   DEFINE ma_ctr_grade     ARRAY[5] OF RECORD
                           den_grade        CHAR(10),
                           nom_tabela_zoom  LIKE ctr_grade.nom_tabela_zoom,
                           descr_col_1_zoom LIKE ctr_grade.descr_col_1_zoom,
                           descr_col_2_zoom LIKE ctr_grade.descr_col_2_zoom,
                           ies_ctr_empresa  LIKE ctr_grade.ies_ctr_empresa,
                           den_cod_grade    CHAR(30)
                           END RECORD

   DEFINE mr_item_ctr_grade   RECORD LIKE item_ctr_grade.*,
          mr_ped_itens_grade  RECORD LIKE ped_itens_grade.*

  #E# - 469670
  DEFINE mr_txt_exped     RECORD
                              texto_1   CHAR(076),
                              texto_2   CHAR(076),
                              texto_3   CHAR(076),
                              texto_4   CHAR(076)
                          END RECORD
  #E# - 469670
   DEFINE m_consis_trib_pedido CHAR(02), #773477
          m_obf_consist_fat    CHAR(01)
MAIN

     CALL log0180_conecta_usuario()

   LET p_versao = "VDP1361-10.02.00p" #Favor nao alterar esta linha (SUPORTE)
   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   CALL log140_procura_caminho("VDP1361.IEM") RETURNING p_caminho
   LET p_help = p_caminho
   OPTIONS HELP FILE p_help

   CALL log001_acessa_usuario("VDP","LOGERP") RETURNING m_status, p_cod_empresa, p_user
   IF m_status = 0 THEN
     CALL vdp1361_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION vdp1361_controle()
#--------------------------#
   CALL log006_exibe_teclas("01", p_versao)
   INITIALIZE p_ped_texto.*  TO NULL
   CALL log1300_procura_caminho("VDP1361","VDP13611") RETURNING p_nom_tela
   OPEN WINDOW w_vdp1361 AT 2,02 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   WHENEVER ERROR CONTINUE
   SELECT par_vdp_txt
     INTO p_par_vdp.par_vdp_txt
     FROM par_vdp
    WHERE par_vdp.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET p_par_vdp.par_vdp_txt = NULL
   END IF
   LET p_qtd_decimais_par = p_par_vdp.par_vdp_txt[43,43]
   IF p_par_vdp.par_vdp_txt[98] <> "N" THEN
     LET p_par_vdp.par_vdp_txt[98] = "S"
   END IF

  #Ini 773477
     CALL log2250_busca_parametro(p_cod_empresa,'obf_consist_fat')
     RETURNING m_obf_consist_fat, m_status

   IF m_status = FALSE OR
      m_obf_consist_fat IS NULL OR
      m_obf_consist_fat = " " THEN
      LET m_obf_consist_fat = "N"
   END IF
   IF NOT vdpr57_create_temp_tables() THEN
     RETURN
   END IF

  CALL log2250_busca_parametro(p_cod_empresa,'consist_trib_pedido')
     RETURNING m_consis_trib_pedido, m_status

  IF NOT m_status OR
     m_consis_trib_pedido IS NULL OR m_consis_trib_pedido = ' ' THEN
     LET m_consis_trib_pedido = 'S'
  END IF
  #Fim 773477

   DISPLAY p_cod_empresa TO cod_empresa
   MENU "OPCAO"
     COMMAND "Listar" "Lista relatório."
       HELP 009
       MESSAGE ""
       IF log005_seguranca(p_user,"VDP","VDP1361","CO") THEN
         IF vdp1361_lista_pedido() THEN
            CALL vdp1361_deleta_pedidos_list()
            IF m_obf_consist_fat = 'S' THEN
               IF NOT obf9999_obf_controle_sid_excluir("CONFIGURACAO_FISCAL") THEN
                  CALL log0030_processa_mensagem("Não foi feita a deleção do sid.",
                                                "exclamation",FALSE)
               END IF
            END IF
            NEXT OPTION "Fim"
         END IF
       END IF

     COMMAND KEY ("!")
       PROMPT "Digite o comando : " FOR p_comando
       RUN p_comando
       PROMPT "nTecle ENTER para continuar" FOR p_comando

     COMMAND "Fim" "Retorna ao Menu Anterior"
       HELP 008
       EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

   END MENU
   CLOSE WINDOW w_vdp1361
END FUNCTION

#-----------------------------#
FUNCTION vdp1361_lista_pedido()
#-----------------------------#
   DEFINE l_gerou_relat     SMALLINT,
          l_primeira_vez    SMALLINT
   DEFINE sql_stmt          CHAR(1000),
          l_pct_ipi         LIKE item.pct_ipi
   INITIALIZE p_msg         TO NULL
   INITIALIZE sql_stmt      TO NULL
   WHENEVER ERROR CONTINUE
   SELECT empresa.den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = NOTFOUND THEN
      LET p_den_empresa = "NÃO CADASTRADA"
   END IF
   LET mr_tela.ies_embute     = "N"
   LET mr_tela.ies_saldo      = "N"
   LET mr_tela.ies_texto_item = "N"
#   LET mr_tela.ies_formulario = 1
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_vdp1361
   LET int_flag = 0
   INPUT BY NAME mr_tela.* WITHOUT DEFAULTS
     ON KEY ('control-w', f1)
        #lds IF NOT LOG_logix_versao5() THEN
        #lds CONTINUE INPUT
        #lds END IF
        CASE
          WHEN INFIELD(ies_embute)        CALL SHOWHELP(101)
          WHEN INFIELD(ies_saldo)         CALL SHOWHELP(102)
          WHEN INFIELD(ies_texto_item)    CALL SHOWHELP(103)
#         WHEN infield(ies_formulario)    CALL showhelp(104)
        END CASE
   END INPUT
   IF int_flag <> 0 THEN
     CALL log0030_mensagem( "Opção cancelada pelo usuário.","excl")
     RETURN FALSE
   END IF
   LET p_last_row = FALSE
   IF log0280_saida_relat(14,40) IS NULL THEN
     CALL log0030_mensagem( "Opção cancelada pelo usuário.","excl")
     RETURN FALSE
   END IF
   ERROR  "Processando a extração do relatório..."
   IF p_ies_impressao = "S" THEN
     IF g_ies_ambiente = "U" THEN
       START REPORT vdp1361_relat TO PIPE p_nom_arquivo
     ELSE
       CALL log150_procura_caminho("LST") RETURNING m_caminho
       LET m_caminho = m_caminho CLIPPED, "vdp1361.tmp"
       START REPORT vdp1361_relat TO m_caminho
     END IF
   ELSE
     START REPORT vdp1361_relat TO p_nom_arquivo
   END IF
   WHENEVER ERROR CONTINUE
   DECLARE cq_pedido_list_1 CURSOR FOR
    SELECT cod_empresa, num_pedido, nom_usuario
      FROM pedido_list
     WHERE cod_empresa = p_cod_empresa
       AND nom_usuario = p_user
     ORDER BY num_pedido
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_PEDIDO_LIST_1")
     RETURN FALSE
   END IF
   LET l_gerou_relat = FALSE
   WHENEVER ERROR CONTINUE
   FOREACH cq_pedido_list_1 INTO p_pedido_list.*
   WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","CQ_PEDIDO_LIST_1")
       EXIT FOREACH
     END IF
      INITIALIZE p_relatm.*, p_ped_texto.*, p_relato.* TO NULL
      LET p_valor_total_liq = 0
      LET p_valor_total_bru = 0
      LET p_valor_total_fre = 0
      LET p_valor_total_seg = 0
      LET p_valor_ipi       = 0
      LET p_valor_base_ipi  = 0
      LET p_valor_total_ipi = 0
      LET p_val_frete_fisc  = 0
      LET p_val_seguro_fisc = 0
      LET p_tot_ipi_fre     = 0
      LET p_peso_total      = 0
      LET p_qtd_pecas_total = 0
      CALL vdp1361_monta_relat_mest_obs()
      OUTPUT TO REPORT vdp1361_relat("MESTRE")
      LET l_gerou_relat = TRUE
      LET sql_stmt =
          ' SELECT ped_itens.*, item.pct_ipi, "N" ',
            ' FROM ped_itens, ', g_outer_ifx, ' item ',
           ' WHERE ped_itens.cod_empresa = "', p_cod_empresa, '" ',
             ' AND ped_itens.num_pedido  =  ', p_pedido_list.num_pedido,
             ' AND ped_itens.cod_empresa = item.cod_empresa ', g_outer_ora,
             ' AND ped_itens.cod_item    = item.cod_item ', g_outer_ora,
           ' UNION ALL ',
          ' SELECT ped_itens_bnf.*, 0, 0, 0, item.pct_ipi, "S" ',
            ' FROM ped_itens_bnf, ', g_outer_ifx, ' item ',
           ' WHERE ped_itens_bnf.cod_empresa = "', p_cod_empresa, '" ',
             ' AND ped_itens_bnf.num_pedido  =  ', p_pedido_list.num_pedido,
             ' AND ped_itens_bnf.cod_empresa = item.cod_empresa ', g_outer_ora,
             ' AND ped_itens_bnf.cod_item    = item.cod_item ', g_outer_ora,
           ' ORDER BY 18,3 '
      WHENEVER ERROR CONTINUE
      PREPARE var_query FROM sql_stmt
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("PREPARE","VAR_QUERY")
        RETURN FALSE
      END IF
      WHENEVER ERROR CONTINUE
      DECLARE cq_ped_itens CURSOR FOR var_query
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql("DECLARE","CQ_PED_ITENS")
        RETURN FALSE
      END IF
      LET l_primeira_vez = TRUE
      WHENEVER ERROR CONTINUE
      FOREACH cq_ped_itens INTO p_itens.*
      WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("FOREACH","CQ_PED_ITENS")
          EXIT FOREACH
        END IF
        IF p_itens.ies_bonificacao = "S" THEN
          LET p_itens.val_desc_com_unit = 0
          LET p_itens.val_frete_unit    = 0
        END IF
        WHENEVER ERROR CONTINUE
        SELECT pct_ipi
          INTO l_pct_ipi
          FROM ped_item_compl
         WHERE cod_empresa = p_cod_empresa
           AND num_pedido  = p_itens.num_pedido
           AND cod_item    = p_itens.cod_item
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 0 THEN
          LET p_itens.pct_ipi = l_pct_ipi
        END IF
        LET p_ies_bonificacao = p_itens.ies_bonificacao
        IF p_itens.ies_bonificacao = "S" AND l_primeira_vez = TRUE THEN
          OUTPUT TO REPORT vdp1361_relat("BNF")
          LET l_primeira_vez = FALSE
        END IF
        IF p_ies_bonificacao <> p_itens.ies_bonificacao THEN
          OUTPUT TO REPORT vdp1361_relat("TOTAL")
          LET p_valor_total_liq = 0
          LET p_valor_total_bru = 0
          LET p_valor_total_fre = 0
          LET p_valor_total_seg = 0
          LET p_valor_ipi       = 0
          LET p_valor_base_ipi  = 0
          LET p_valor_total_ipi = 0
          LET p_tot_ipi_fre     = 0
          LET p_peso_total      = 0
          LET p_qtd_pecas_total = 0
          LET p_ies_bonificacao = p_itens.ies_bonificacao
          OUTPUT TO REPORT vdp1361_relat("BNF")
        END IF
        CALL vdp1361_monta_relat_item()
        IF mr_tela.ies_saldo = "S" THEN
          IF (p_itens.qtd_pecas_solic - p_itens.qtd_pecas_atend - p_itens.qtd_pecas_cancel) > 0 THEN
            OUTPUT TO REPORT vdp1361_relat("ITENS")
            CALL vdp1361_imp_grade()
            IF mr_tela.ies_texto_item = "S" THEN
              OUTPUT TO REPORT vdp1361_relat("TEXTO ITEM")
            END IF
          END IF
        ELSE
          OUTPUT TO REPORT vdp1361_relat("ITENS")
          CALL vdp1361_imp_grade()
          IF mr_tela.ies_texto_item = "S" THEN
            OUTPUT TO REPORT vdp1361_relat("TEXTO ITEM")
          END IF
        END IF
      END FOREACH
      FREE cq_ped_itens
      CALL vdp1361_busca_texto(0)
      OUTPUT TO REPORT vdp1361_relat("TOTAL")
      OUTPUT TO REPORT vdp1361_relat("OBSERVACAO")
      OUTPUT TO REPORT vdp1361_relat("TEXTO PEDIDO")
      OUTPUT TO REPORT vdp1361_relat("OBS EXPEDICAO") #E# - 469670
      LET p_page = 0
   END FOREACH
   FREE cq_pedido_list_1
   FINISH REPORT vdp1361_relat
   IF l_gerou_relat THEN
     IF p_ies_impressao = "S" THEN
       IF g_ies_ambiente = "W" THEN
         LET p_comando = "lpdos.bat ", m_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
         RUN p_comando
       END IF
       CALL log0030_mensagem("Relatório impresso com sucesso. ","info")
     ELSE
       LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo CLIPPED,"."
       CALL log0030_mensagem(p_msg,"info")
     END IF
     ERROR "Fim de processamento."
   ELSE
     CALL log0030_mensagem("Não existem dados para serem listados.", "exclamation")
   END IF
   RETURN TRUE
END FUNCTION

#--------------------------#
FUNCTION vdp1361_imp_grade()
#--------------------------#
   DEFINE l_ies_grade  SMALLINT
   DEFINE la_tam1       ARRAY[100]  OF  SMALLINT,
          la_tam2       ARRAY[100]  OF  SMALLINT,
          la_tam3       ARRAY[100]  OF  SMALLINT,
          la_tam4       ARRAY[100]  OF  SMALLINT,
          la_tam5       ARRAY[100]  OF  SMALLINT
   DEFINE l_ind        SMALLINT
   DEFINE l_ind2       SMALLINT
   DEFINE l_maior1     SMALLINT,
            l_maior2     SMALLINT,
            l_maior3     SMALLINT,
            l_maior4     SMALLINT,
            l_maior5     SMALLINT
   LET l_ies_grade  = FALSE
   LET l_ind = 1
   WHENEVER ERROR CONTINUE
   DECLARE cq_ped_itens_grade CURSOR FOR
    SELECT cod_empresa, num_pedido, num_sequencia, cod_item, cod_grade_1, cod_grade_2,
           cod_grade_3, cod_grade_4, cod_grade_5, qtd_pecas_solic, qtd_pecas_atend,
           qtd_pecas_cancel, qtd_pecas_reserv, qtd_pecas_romaneio
      FROM ped_itens_grade
     WHERE cod_empresa   = p_cod_empresa
       AND num_pedido    = p_itens.num_pedido
       AND num_sequencia = p_itens.num_sequencia
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE","CQ_PED_ITENS_GRADE")
   END IF
##JU
   WHENEVER ERROR CONTINUE
   FOREACH cq_ped_itens_grade INTO mr_ped_itens_grade.*
   WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","CQ_PED_ITENS_GRADE")
       EXIT FOREACH
     END IF
     CALL vdp1361_busca_den_grade()
     LET la_tam1[l_ind] = length(ma_ctr_grade[1].den_cod_grade)
     LET la_tam2[l_ind] = length(ma_ctr_grade[2].den_cod_grade)
     LET la_tam3[l_ind] = length(ma_ctr_grade[3].den_cod_grade)
     LET la_tam4[l_ind] = length(ma_ctr_grade[4].den_cod_grade)
     LET la_tam5[l_ind] = length(ma_ctr_grade[5].den_cod_grade)
     LET l_ind = l_ind + 1
   END FOREACH
   LET l_maior1 = la_tam1[1]
   LET l_maior1 = la_tam2[1]
   LET l_maior1 = la_tam3[1]
   LET l_maior1 = la_tam4[1]
   LET l_maior1 = la_tam5[1]
## Verifica qual o tamanho da maior variavel "ma_ctr_grade[1].den_cod_grade"
   FOR l_ind2 = 1 TO l_ind
     IF l_maior1 > la_tam1[l_ind2] THEN
     ELSE
       LET l_maior1 = la_tam1[l_ind2]
     END IF
   END FOR
## Verifica qual o tamanho da maior variavel "ma_ctr_grade[2].den_cod_grade"
   FOR l_ind2 = 1 TO l_ind
     IF l_maior2 > la_tam2[l_ind2] THEN
     ELSE
       LET l_maior2 = la_tam2[l_ind2]
     END IF
   END FOR
## Verifica qual o tamanho da maior variavel "ma_ctr_grade[3].den_cod_grade"
   FOR l_ind2 = 1 TO l_ind
     IF l_maior3 > la_tam3[l_ind2] THEN
     ELSE
       LET l_maior3 = la_tam3[l_ind2]
     END IF
   END FOR
## Verifica qual o tamanho da maior variavel "ma_ctr_grade[4].den_cod_grade"
   FOR l_ind2 = 1 TO l_ind
     IF l_maior4 > la_tam4[l_ind2] THEN
     ELSE
       LET l_maior4 = la_tam4[l_ind2]
     END IF
   END FOR
## Verifica qual o tamanho da maior variavel "ma_ctr_grade[5].den_cod_grade"
   FOR l_ind2 = 1 TO l_ind
     IF l_maior5 > la_tam5[l_ind2] THEN
     ELSE
       LET l_maior5 = la_tam5[l_ind2]
     END IF
   END FOR
##JU
   WHENEVER ERROR CONTINUE
   FOREACH cq_ped_itens_grade INTO mr_ped_itens_grade.*
   WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","CQ_PED_ITENS_GRADE")
       EXIT FOREACH
     END IF
     IF mr_tela.ies_saldo = "S" THEN
       IF (mr_ped_itens_grade.qtd_pecas_solic - mr_ped_itens_grade.qtd_pecas_atend -
           mr_ped_itens_grade.qtd_pecas_cancel) > 0 THEN
       ELSE
         CONTINUE FOREACH
       END IF
     END IF
     LET m_column_grade1 = 9 + length(ma_ctr_grade[1].den_grade) + l_maior1
     LET m_column_grade2 = m_column_grade1 + 2 + length(ma_ctr_grade[2].den_grade)+ l_maior2
     LET m_column_grade3 = m_column_grade2 + 2 + length(ma_ctr_grade[3].den_grade)+ l_maior3
     LET m_column_grade4 = m_column_grade3 + 2 + length(ma_ctr_grade[4].den_grade)+ l_maior4
     LET m_column_grade5 = m_column_grade4 + 2 + length(ma_ctr_grade[5].den_grade)+ l_maior5
     CALL vdp1361_busca_den_grade()
     LET l_ies_grade  = TRUE
     OUTPUT TO REPORT vdp1361_relat("GRADE")
   END FOREACH
   FREE cq_ped_itens_grade
   IF l_ies_grade THEN
     OUTPUT TO REPORT vdp1361_relat("GRADE_PRINT")
   END IF
END FUNCTION

#--------------------------------#
FUNCTION vdp1361_busca_den_grade()
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
      AND cod_item           = p_itens.cod_item
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
        CALL vdp1361_busca_codigo_grade(1, mr_ped_itens_grade.cod_grade_1)
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
        CALL vdp1361_busca_codigo_grade(2, mr_ped_itens_grade.cod_grade_2)
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
        CALL vdp1361_busca_codigo_grade(3, mr_ped_itens_grade.cod_grade_3)
      END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT den_grade_reduz
     INTO ma_ctr_grade[4].den_grade
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = mr_item_ctr_grade.num_grade_4
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
        CALL vdp1361_busca_codigo_grade(4, mr_ped_itens_grade.cod_grade_4)
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
        CALL vdp1361_busca_codigo_grade(5, mr_ped_itens_grade.cod_grade_5)
      END IF
   END IF
END FUNCTION

#----------------------------------------------------------#
FUNCTION vdp1361_busca_codigo_grade(l_nr_grade, l_cod_grade)
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
      LET sql_stmt = sql_stmt CLIPPED, ' AND  cod_empresa = "', p_cod_empresa, '" '
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

#-------------------------------------#
 FUNCTION vdp1361_monta_relat_mest_obs()
#-------------------------------------#
  DEFINE l_cod_cidade     LIKE  cidades.cod_cidade,
         lr_cli_cond_pgto RECORD LIKE cli_cond_pgto.*
  WHENEVER ERROR CONTINUE
  SELECT cod_empresa, num_pedido, cod_cliente, pct_comissao, num_pedido_repres, dat_emis_repres,
         cod_nat_oper, cod_transpor, cod_consig, ies_finalidade, ies_frete, ies_preco, cod_cnd_pgto,
         pct_desc_financ,ies_embal_padrao, ies_tip_entrega, ies_aceite, ies_sit_pedido, dat_pedido,
         num_pedido_cli, pct_desc_adic, num_list_preco, cod_repres, cod_repres_adic, dat_alt_sit,
         dat_cancel, cod_tip_venda, cod_motivo_can, dat_ult_fatur, cod_moeda, ies_comissao, pct_frete,
         cod_tip_carteira, num_versao_lista, cod_local_estoq
    INTO p_pedidos.cod_empresa, p_pedidos.num_pedido, p_pedidos.cod_cliente, p_pedidos.pct_comissao,
         p_pedidos.num_pedido_repres, p_pedidos.dat_emis_repres, p_pedidos.cod_nat_oper,
         p_pedidos.cod_transpor, p_pedidos.cod_consig, p_pedidos.ies_finalidade, p_pedidos.ies_frete,
         p_pedidos.ies_preco, p_pedidos.cod_cnd_pgto, p_pedidos.pct_desc_financ, p_pedidos.ies_embal_padrao,
         p_pedidos.ies_tip_entrega, p_pedidos.ies_aceite, p_pedidos.ies_sit_pedido, p_pedidos.dat_pedido,
         p_pedidos.num_pedido_cli, p_pedidos.pct_desc_adic, p_pedidos.num_list_preco, p_pedidos.cod_repres,
         p_pedidos.cod_repres_adic, p_pedidos.dat_alt_sit, p_pedidos.dat_cancel, p_pedidos.cod_tip_venda,
         p_pedidos.cod_motivo_can, p_pedidos.dat_ult_fatur, p_pedidos.cod_moeda, p_pedidos.ies_comissao,
         p_pedidos.pct_frete, p_pedidos.cod_tip_carteira, p_pedidos.num_versao_lista, p_pedidos.cod_local_estoq
    FROM pedidos
   WHERE cod_empresa = p_cod_empresa
     AND num_pedido  = p_pedido_list.num_pedido
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_pedidos.* TO NULL
  END IF
  LET p_relatm.num_pedido        = p_pedidos.num_pedido
  LET p_relatm.dat_emis_repres   = p_pedidos.dat_emis_repres
  LET p_relatm.cod_cliente       = p_pedidos.cod_cliente
  LET p_relatm.cod_repres        = p_pedidos.cod_repres
  LET p_relatm.num_list_preco    = p_pedidos.num_list_preco
  LET p_relatm.pct_desc_financ   = p_pedidos.pct_desc_financ
  LET p_relatm.num_pedido_cli    = p_pedidos.num_pedido_cli
  LET p_relatm.num_pedido_repres = p_pedidos.num_pedido_repres
  LET p_relatm.cod_repres_adic   = p_pedidos.cod_repres_adic
  LET p_relatm.cod_transpor      = p_pedidos.cod_transpor
  LET p_relatm.cod_consig        = p_pedidos.cod_consig
  LET p_relatm.pct_comissao      = p_pedidos.pct_comissao
  LET p_relatm.cod_tip_venda     = p_pedidos.cod_tip_venda
  LET p_relatm.pct_desc_adic     = p_pedidos.pct_desc_adic
  LET p_relatm.cod_local_estoq   = p_pedidos.cod_local_estoq
  CALL vdp784_busca_desc_adic_unico( p_cod_empresa, p_relatm.num_pedido, 0, p_relatm.pct_desc_adic )
       RETURNING p_relatm.pct_desc_adic
  LET p_relatm.dat_pedido        = p_pedidos.dat_pedido
  LET p_relatm.cod_moeda         = p_pedidos.cod_moeda
  LET p_relatm.pct_frete         = p_pedidos.pct_frete
  LET p_relatm.cod_tip_carteira  = p_pedidos.cod_tip_carteira
  WHENEVER ERROR CONTINUE
  SELECT den_tip_carteira
    INTO p_relatm.den_tip_carteira
    FROM tipo_carteira
   WHERE cod_tip_carteira = p_pedidos.cod_tip_carteira
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relatm.den_tip_carteira TO NULL
  END IF
  #OS 398225
  WHENEVER ERROR CONTINUE
  SELECT rota
    INTO p_relatm.cod_rota
    FROM vdp_rota_emp_cli
   WHERE empresa = p_cod_empresa
     AND cliente = p_pedidos.cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT cod_rota
      INTO p_relatm.cod_rota
      FROM clientes
     WHERE cod_cliente = p_pedidos.cod_cliente
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_relatm.cod_rota TO NULL
    END IF
  END IF
  #OS 398225
  WHENEVER ERROR CONTINUE
  SELECT nom_cliente, num_cgc_cpf, end_cliente, cod_cep, den_frete_posto,
         den_marca, cod_cidade, cod_consig, den_bairro
    INTO p_relatm.nom_cliente, p_relatm.num_cgc_cpf, p_relatm.end_cliente,
         p_relatm.cod_cep, p_relatm.den_frete_posto, p_relatm.den_marca,
         l_cod_cidade, p_cod_cons_cli, p_relatm.den_bairro
    FROM clientes
   WHERE clientes.cod_cliente = p_pedidos.cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relatm.nom_cliente, p_relatm.num_cgc_cpf, p_relatm.end_cliente,
               p_relatm.cod_cep, p_relatm.den_frete_posto, p_relatm.den_marca,
               l_cod_cidade, p_cod_cons_cli, p_relatm.den_bairro TO NULL
  END IF
  IF p_relatm.cod_consig IS NULL OR p_relatm.cod_consig = " " OR p_relatm.cod_consig = "0" THEN
    LET p_relatm.cod_consig  = p_cod_cons_cli
    LET p_pedidos.cod_consig = p_cod_cons_cli
  END IF
  WHENEVER ERROR CONTINUE
   SELECT raz_social
     INTO p_relatm.raz_social
     FROM representante
    WHERE cod_repres = p_pedidos.cod_repres
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.raz_social = " "
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_moeda
    INTO p_relatm.den_moeda
    FROM moeda
   WHERE moeda.cod_moeda = p_relatm.cod_moeda
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_moeda = " "
  END IF
  WHENEVER ERROR CONTINUE
  SELECT raz_social
    INTO p_relatm.nom_promotor
    FROM representante
   WHERE cod_repres = p_pedidos.cod_repres_adic
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.nom_promotor = " "
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_cidade, cod_uni_feder
    INTO p_relatm.den_cidade, p_relatm.cod_uni_feder
    FROM cidades
   WHERE cod_cidade = l_cod_cidade
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relatm.den_cidade, p_relatm.cod_uni_feder TO NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_transpor
    INTO p_relatm.den_transpor
    FROM transport
   WHERE transport.cod_transpor = p_pedidos.cod_transpor
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
    WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO p_relatm.den_transpor
      FROM clientes
     WHERE clientes.cod_cliente = p_pedidos.cod_transpor
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_relatm.den_transpor TO NULL
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT num_telefone # os 403877
    INTO p_relatm.num_telefone
    FROM transport
   WHERE transport.cod_transpor = p_pedidos.cod_transpor
  IF sqlca.sqlcode = NOTFOUND THEN
    SELECT num_telefone
      INTO p_relatm.num_telefone
      FROM clientes
     WHERE clientes.cod_cliente = p_pedidos.cod_transpor
    IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_relatm.num_telefone TO NULL
    END IF
  END IF
  WHENEVER ERROR STOP
  WHENEVER ERROR CONTINUE
  SELECT den_transpor
    INTO p_relatm.den_consig
    FROM transport
   WHERE cod_transpor = p_pedidos.cod_consig
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = NOTFOUND THEN
    WHENEVER ERROR CONTINUE
    SELECT nom_cliente
      INTO p_relatm.den_consig
      FROM clientes
     WHERE cod_cliente = p_pedidos.cod_consig
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_relatm.den_consig TO NULL
    END IF
  END IF
  WHENEVER ERROR CONTINUE
  SELECT end_entrega, cod_cep, cod_cidade
    INTO p_relatm.end_entrega, p_relatm.cod_cep_ent, l_cod_cidade
    FROM ped_end_ent
   WHERE ped_end_ent.num_pedido  = p_pedidos.num_pedido
     AND ped_end_ent.cod_empresa = p_cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relatm.end_entrega, p_relatm.cod_cep_ent, l_cod_cidade TO NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_cidade
    INTO p_relatm.den_cidade_ent
    FROM cidades
   WHERE cidades.cod_cidade = l_cod_cidade
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_cidade_ent = NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_tip_venda
    INTO p_relatm.den_tip_venda
    FROM tipo_venda
   WHERE cod_tip_venda = p_pedidos.cod_tip_venda
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_tip_venda = NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_local
    INTO p_relatm.den_local_estoq
    FROM local
   WHERE local.cod_empresa = p_cod_empresa
     AND local.cod_local   = p_relatm.cod_local_estoq
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_local_estoq = NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_nat_oper
    INTO p_relatm.den_operac
    FROM nat_operacao
   WHERE cod_nat_oper = p_pedidos.cod_nat_oper
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_operac = NULL
  END IF
  LET p_relatm.cod_nat_oper = p_pedidos.cod_nat_oper
  WHENEVER ERROR CONTINUE
  SELECT den_rota
    INTO p_relatm.den_rota
    FROM rotas
   WHERE rotas.cod_rota = p_relatm.cod_rota
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    LET p_relatm.den_rota = " "
  END IF
  WHENEVER ERROR CONTINUE
  SELECT den_cnd_pgto, pct_desp_finan
    INTO p_relatm.den_cnd_pgto, p_pct_desp_finan
    FROM cond_pgto
   WHERE cond_pgto.cod_cnd_pgto = p_pedidos.cod_cnd_pgto
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relatm.den_cnd_pgto, p_pct_desp_finan TO NULL
  END IF
  WHENEVER ERROR CONTINUE
  SELECT cod_cnd_pgto, pct_desp_financ
    INTO lr_cli_cond_pgto.cod_cnd_pgto, lr_cli_cond_pgto.pct_desp_financ
    FROM cli_cond_pgto
   WHERE cod_cliente = p_pedidos.cod_cliente
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
    IF lr_cli_cond_pgto.cod_cnd_pgto = p_pedidos.cod_cnd_pgto THEN
      IF lr_cli_cond_pgto.pct_desp_financ > 0 THEN
        LET p_pct_desp_finan = lr_cli_cond_pgto.pct_desp_financ
      END IF
    END IF
  END IF
  IF p_par_vdp.par_vdp_txt[204,204] = "S" THEN
    IF p_pedidos.num_list_preco = 0 THEN
      LET p_pct_desp_finan = 1
    END IF
  END IF
  IF p_par_vdp.par_vdp_txt[352,352] = "S" THEN
      LET p_pct_desp_finan = 1
  END IF

  IF p_pct_desp_finan = 0 THEN
    LET p_pct_desp_finan = 1
  END IF
  LET p_val_cot_moeda = 0
  IF p_pedidos.cod_moeda > 0 THEN
    WHENEVER ERROR CONTINUE
    SELECT val_cotacao
      INTO p_val_cot_moeda
      FROM cotacao
     WHERE cod_moeda = p_pedidos.cod_moeda
       AND dat_ref   = p_pedidos.dat_pedido
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
    ELSE
      LET p_val_cot_moeda = 1
    END IF
  ELSE
    LET p_val_cot_moeda = 1
  END IF
  CASE p_pedidos.ies_frete
      WHEN 1 LET p_relatm.des_frete = "CIF"
      WHEN 2 LET p_relatm.des_frete = "CIF - COBRADO"
      WHEN 3 LET p_relatm.des_frete = "FOB"
      WHEN 4 LET p_relatm.des_frete = "CIF Com Pct"
      WHEN 5 LET p_relatm.des_frete = "CIF Unitario"
      WHEN 6 LET p_relatm.des_frete = "CIF IT Total"
  END CASE
  CASE p_pedidos.ies_preco
     WHEN "F" LET p_relatm.des_preco = "Firme"
     WHEN "R" LET p_relatm.des_preco = "Reajustavel"
  END CASE
  CASE p_pedidos.ies_finalidade
     WHEN "1" LET p_relatm.des_finalidade = "Industrializar/Comercializar"
     WHEN "2" LET p_relatm.des_finalidade = "Consumo Nao Contribuinte"
     WHEN "3" LET p_relatm.des_finalidade = "Consumo Contribuinte"
  END CASE
  CASE p_pedidos.ies_tip_entrega
     WHEN 1 LET p_relatm.des_entrega = "Total / Total"
     WHEN 2 LET p_relatm.des_entrega = "Parcial / Total"
     WHEN 3 LET p_relatm.des_entrega = "Parcial / Parcial"
     WHEN 4 LET p_relatm.des_entrega = "Total / Separado"
  END CASE
  CASE p_pedidos.ies_embal_padrao
     WHEN "1" LET p_relatm.des_embalagem = "Embal. Interna"
     WHEN "2" LET p_relatm.des_embalagem = "Embal. Externa"
     WHEN "3" LET p_relatm.des_embalagem = "Sem Padrao"
     WHEN "4" LET p_relatm.des_embalagem = "Cx. Embal. Int."
     WHEN "5" LET p_relatm.des_embalagem = "Cx. Embal. Ext."
     WHEN "6" LET p_relatm.des_embalagem = "Pallet"
  END CASE
  CASE p_pedidos.ies_aceite
     WHEN "N" LET p_relatm.des_aceite_financ = "Nao"
              LET p_relatm.des_aceite_comerc = "Nao"
     WHEN "F" LET p_relatm.des_aceite_financ = "Sim"
              LET p_relatm.des_aceite_comerc = "Nao"
     WHEN "C" LET p_relatm.des_aceite_financ = "Nao"
              LET p_relatm.des_aceite_comerc = "Sim"
     WHEN "A" LET p_relatm.des_aceite_financ = "Sim"
              LET p_relatm.des_aceite_comerc = "Sim"
  END CASE
  CASE p_pedidos.ies_sit_pedido
     WHEN "N"  LET p_relatm.des_sit_pedido = "Normal"
     WHEN "B"  LET p_relatm.des_sit_pedido = "Bloqueado"
     WHEN "P"  LET p_relatm.des_sit_pedido = "Provisorio"
     WHEN "L"  LET p_relatm.des_sit_pedido = "Licenciado"
     WHEN "9"  LET p_relatm.des_sit_pedido = "Cancelado"
     OTHERWISE LET p_relatm.des_sit_pedido = "Outros"
  END CASE
  LET p_relatm.des_tip_pedido = "Normal"
  #DECLARE cq_ped_obs CURSOR WITH HOLD FOR
  WHENEVER ERROR CONTINUE
  SELECT tex_observ_1, tex_observ_2
    INTO p_relato.tex_observ_1, p_relato.tex_observ_2
    FROM ped_observacao
   WHERE ped_observacao.num_pedido  = p_pedidos.num_pedido
     AND ped_observacao.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
    INITIALIZE p_relato.tex_observ_1, p_relato.tex_observ_2 TO NULL
  END IF

  CALL vdpy154_carrega_txt_exped(p_pedido_list.num_pedido, 'ped_info_compl') RETURNING mr_txt_exped.*  #E# - 469670

#  FOREACH cq_ped_obs INTO p_relato.tex_observ_1, p_relato.tex_observ_2
#     EXIT FOREACH
#  END FOREACH
END FUNCTION

#---------------------------------------#
 FUNCTION vdp1361_busca_texto(l_num_seq)
#---------------------------------------#
   DEFINE l_num_seq DECIMAL(5,0)
   INITIALIZE p_ped_texto.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT den_texto_1, den_texto_2, den_texto_3, den_texto_4, den_texto_5
     INTO p_ped_texto.den_texto_1, p_ped_texto.den_texto_2, p_ped_texto.den_texto_3,
          p_ped_texto.den_texto_4, p_ped_texto.den_texto_5
     FROM ped_itens_texto
    WHERE ped_itens_texto.cod_empresa   = p_cod_empresa
      AND ped_itens_texto.num_pedido    = p_pedidos.num_pedido
      AND ped_itens_texto.num_sequencia = l_num_seq
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
     LET m_tem_texto = TRUE
   ELSE
     LET m_tem_texto = FALSE
   END IF
END FUNCTION

#----------------------------------#
 FUNCTION vdp1361_monta_relat_item()
#----------------------------------#
   DEFINE lr_nat_oper_refer  RECORD LIKE  nat_oper_refer.*,
          l_ies_incid_ipi    LIKE  fiscal_par.ies_incid_ipi
   DEFINE l_status           SMALLINT
   DEFINE l_pct_ipi          DECIMAL(7,4)

   LET l_pct_ipi = 0

   WHENEVER ERROR CONTINUE
   SELECT den_item, pes_unit, cod_unid_med
     INTO p_den_item, p_pes_unit, p_cod_unid_med
     FROM item
    WHERE item.cod_item    = p_itens.cod_item
      AND item.cod_empresa = p_cod_empresa
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET p_den_item      = " "
     LET p_pes_unit      = 0
     LET p_cod_unid_med  = NULL
   END IF
   LET p_den_item_1 = p_den_item[1,26]
   LET p_den_item_2 = p_den_item[27,52]
   LET p_den_item_3 = p_den_item[53,78]
   CALL vdp784_busca_desc_adic_unico(p_cod_empresa, p_itens.num_pedido, p_itens.num_sequencia,
        p_itens.pct_desc_adic) RETURNING p_itens.pct_desc_adic
   IF p_pedidos.cod_tip_carteira = p_cod_tip_carteira_ant THEN
     LET p_qtd_decimais = p_qtd_decimais_cart
   ELSE
     CALL vdp1519_busca_qtd_decimais_preco( p_cod_empresa, p_pedidos.cod_tip_carteira )
          RETURNING p_qtd_decimais_cart
     LET p_qtd_decimais         = p_qtd_decimais_cart
     LET p_cod_tip_carteira_ant = p_pedidos.cod_tip_carteira
   END IF
   IF p_qtd_decimais = 0 THEN
     LET p_qtd_decimais = p_qtd_decimais_par
   END IF
   IF p_ies_bonificacao = "N" THEN
     CASE p_qtd_decimais
       WHEN 1 LET p_pre_unit1 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit1
       WHEN 2 LET p_pre_unit2 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit2
       WHEN 3 LET p_pre_unit3 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit3
       WHEN 4 LET p_pre_unit4 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit4
       WHEN 5 LET p_pre_unit5 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit5
       WHEN 6 LET p_pre_unit6 = p_itens.pre_unit * p_pct_desp_finan
              LET p_pre_unit  = p_pre_unit6
    END CASE
   ELSE
     LET p_pre_unit = p_itens.pre_unit
   END IF
   IF p_relatm.pct_desc_adic > 0 THEN
     CALL vdp1519_calcula_pre_unit( p_pre_unit, p_relatm.pct_desc_adic, p_qtd_decimais )
          RETURNING p_pre_unit
   END IF
   IF p_itens.pct_desc_adic > 0 THEN
     CALL vdp1519_calcula_pre_unit(p_pre_unit, p_itens.pct_desc_adic, p_qtd_decimais)
          RETURNING p_pre_unit
   ELSE
     LET p_pre_unit = p_pre_unit
   END IF

######## new
   INITIALIZE lr_nat_oper_refer.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT cod_nat_oper_ref
     INTO lr_nat_oper_refer.cod_nat_oper_ref
     FROM nat_oper_refer
    WHERE cod_empresa  = p_cod_empresa
      AND cod_item     = p_itens.cod_item
      AND cod_nat_oper = p_pedidos.cod_nat_oper
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET lr_nat_oper_refer.cod_nat_oper_ref = p_pedidos.cod_nat_oper
   END IF
   LET l_ies_incid_ipi = 0


   #708417
   LET l_status = TRUE
   IF m_consis_trib_pedido = "S" THEN
      #inicio 578427
      CALL vdpr99_consiste_fiscal('',
                                  p_cod_empresa,                #empresa
                                  #inicio 594190
                                  #p_pedidos.dat_emis_repres,    #data emissão representante
                                  TODAY,
                                  #fim 594190
                                  p_pedidos.cod_nat_oper,       #codigo natureza operacao
                                  p_pedidos.cod_cliente,        #codigo cliente
                                  p_pedidos.cod_tip_carteira,   #codigo tipo carteira
                                  p_pedidos.ies_finalidade,     #finalidade
                                  '',                           #classificação fiscal
                                  '',                           #unidade de medida busca do item
                                  'N',                          #bonificação
                                  p_itens.cod_item,             #item
                                  '',                           #linha de produto
                                  '',                           #linha de receita
                                  '',                           #segmento de mercado
                                  '',                           #classe de uso
                                  '',                           #via de transporte
                                  'S',                          #
                                  '',                           #codigo cidade
                                  0)
         RETURNING l_status
   END IF
   IF NOT l_status THEN
      LET l_ies_incid_ipi = NULL
      LET p_pct_desc_ipi  = NULL
      LET p_pct_base_ipi  = NULL
   ELSE
      IF vdpr99_encontra_fiscal('IPI',
                                 p_cod_empresa,                #empresa
                                 #inicio 594190
                                 #p_pedidos.dat_emis_repres,    #data emissão representante
                                 TODAY,
                                 #fim 594190
                                 p_pedidos.cod_nat_oper,       #codigo natureza operacao
                                 p_pedidos.cod_cliente,        #codigo cliente
                                 p_pedidos.cod_tip_carteira,   #codigo tipo carteira
                                 p_pedidos.ies_finalidade,     #finalidade
                                 '',                           #classificação fiscal
                                 '',                           #unidade de medida busca do item
                                 'N',                          #bonificação
                                 p_itens.cod_item,             #item
                                 '',                           #linha de produto
                                 '',                           #linha de receita
                                 '',                           #segmento de mercado
                                 '',                           #classe de uso
                                 '',                           #via de transporte
                                 'S',                          #
                                 '',                           #codigo cidade
                                 1) THEN
         LET l_ies_incid_ipi = vdpr99_fiscal_get_incidencia()
         LET p_pct_desc_ipi  = vdpr99_fiscal_get_pct_reducao_val()
         LET p_pct_base_ipi  = vdpr99_fiscal_get_pct_red_bas_calc()
         LET l_pct_ipi       = vdpr99_fiscal_get_aliquota()
      ELSE
         LET l_ies_incid_ipi = NULL
         LET p_pct_desc_ipi  = NULL
         LET p_pct_base_ipi  = NULL
      END IF
   END IF

#   WHENEVER ERROR CONTINUE
#   SELECT ies_incid_ipi, pct_desc_ipi, pct_desc_base_ipi
#     INTO l_ies_incid_ipi, p_pct_desc_ipi, p_pct_base_ipi
#     FROM fiscal_par
#    WHERE cod_empresa   = p_cod_empresa
#      AND cod_nat_oper  = lr_nat_oper_refer.cod_nat_oper_ref
#      AND cod_uni_feder = p_relatm.cod_uni_feder
#   WHENEVER ERROR STOP
#   IF sqlca.sqlcode <> 0 THEN
#     WHENEVER ERROR CONTINUE
#     SELECT ies_incid_ipi, pct_desc_ipi, pct_desc_base_ipi
#       INTO l_ies_incid_ipi, p_pct_desc_ipi, p_pct_base_ipi
#       FROM fiscal_par
#      WHERE cod_empresa = p_cod_empresa
#        AND cod_nat_oper = lr_nat_oper_refer.cod_nat_oper_ref
#        AND cod_uni_feder IS NULL
#     WHENEVER ERROR STOP
#     IF sqlca.sqlcode <> 0 THEN
#       LET l_ies_incid_ipi = NULL
#       LET p_pct_desc_ipi  = NULL
#       LET p_pct_base_ipi  = NULL
#     END IF
#   END IF


   IF l_ies_incid_ipi <> 1 THEN
     LET p_itens.pct_ipi = 0
   ELSE
      IF l_pct_ipi IS NOT NULL THEN
         IF p_itens.pct_ipi = 0 THEN
            LET p_itens.pct_ipi = l_pct_ipi
         END IF
      END IF
   END IF
   LET p_valor_base_ipi  = 0
   LET p_valor_ipi       = 0
   IF mr_tela.ies_saldo  = "S" THEN
     LET p_valor_base_ipi = ((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_pre_unit)
   ELSE
     LET p_valor_base_ipi  = ((p_itens.qtd_pecas_solic - p_itens.qtd_pecas_cancel) *  p_pre_unit)
   END IF
   LET p_valor_base_ipi  = p_valor_base_ipi - ((p_valor_base_ipi * p_pct_base_ipi) / 100)
   LET p_valor_ipi       = (p_valor_base_ipi * p_itens.pct_ipi / 100)
   LET p_valor_ipi       = p_valor_ipi - ((p_valor_ipi * p_pct_desc_ipi) / 100)
   LET p_valor_total_ipi = p_valor_total_ipi + (p_valor_ipi)
######## new
   LET p_itens.pre_unit_liq = p_pre_unit
   IF mr_tela.ies_saldo = "S" THEN
     IF (p_itens.qtd_pecas_solic-p_itens.qtd_pecas_atend-p_itens.qtd_pecas_cancel) > 0 THEN
       LET p_valor_total_liq = p_valor_total_liq+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_pre_unit)
       LET p_valor_total_bru = p_valor_total_bru+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_itens.pre_unit)
       LET p_peso_total = p_peso_total+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_pes_unit)
       LET p_qtd_pecas_total = p_qtd_pecas_total+(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)
       LET p_val_unit_seguro = p_itens.val_seguro_unit * p_val_cot_moeda
       IF p_pedidos.ies_frete  = "4" THEN
         LET p_val_unit_frete = p_itens.pre_unit_liq*p_relatm.pct_frete/100
       ELSE
         IF p_pedidos.ies_frete = "5" THEN
           LET p_val_unit_frete = p_itens.val_frete_unit*p_val_cot_moeda
         ELSE
           LET p_val_unit_frete = 0
         END IF
       END IF
       IF p_pedidos.ies_frete = 4 OR p_pedidos.ies_frete = 5 THEN
         LET p_val_frete_fisc  = (p_val_unit_frete*(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend))
         LET p_val_seguro_fisc = (p_val_unit_seguro*(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend))
       END IF
       LET p_val_ipi_seg = (p_val_frete_fisc+p_val_seguro_fisc)
       LET p_val_ipi_seg = p_val_ipi_seg-((p_val_ipi_seg*p_pct_base_ipi)/100)
       LET p_val_ipi_fre   = p_val_ipi_seg*p_itens.pct_ipi/100
       LET p_val_ipi_fre   = p_val_ipi_fre-((p_val_ipi_fre*p_pct_desc_ipi)/100)
       LET p_tot_ipi_fre = p_tot_ipi_fre+p_val_ipi_fre
       IF p_pedidos.ies_frete = 4 THEN
         LET p_valor_total_fre = (p_valor_total_liq * p_relatm.pct_frete)/100
       END IF
       IF p_pedidos.ies_frete = 6 THEN
         LET p_valor_total_fre = p_valor_total_fre + p_itens.val_frete_unit
         LET p_valor_total_seg = p_valor_total_seg + p_itens.val_seguro_unit
       ELSE
         LET p_valor_total_fre = p_valor_total_fre+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_itens.val_frete_unit)
         LET p_valor_total_seg = p_valor_total_seg+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_itens.val_seguro_unit)
       END IF
     END IF
   ELSE
     LET p_valor_total_liq = p_valor_total_liq+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel)*p_pre_unit)
     LET p_valor_total_bru = p_valor_total_bru+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel)*p_itens.pre_unit)
     LET p_peso_total = p_peso_total+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel)*p_pes_unit)
     LET p_qtd_pecas_total = p_qtd_pecas_total+(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel)
     LET p_val_unit_seguro = p_itens.val_seguro_unit*p_val_cot_moeda
     IF p_pedidos.ies_frete  = "4" THEN
       LET p_val_unit_frete = p_itens.pre_unit_liq*p_relatm.pct_frete/100
     ELSE
       IF p_pedidos.ies_frete = "5" THEN
         LET p_val_unit_frete = p_itens.val_frete_unit*p_val_cot_moeda
       ELSE
         LET p_val_unit_frete = 0
         END IF
     END IF
     IF p_pedidos.ies_frete = 4 OR p_pedidos.ies_frete = 5 THEN
       LET p_val_frete_fisc  = (p_val_unit_frete*(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend))
       LET p_val_seguro_fisc = (p_val_unit_seguro*(p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend))
     END IF
     LET p_val_ipi_seg = (p_val_frete_fisc+p_val_seguro_fisc)
     LET p_val_ipi_seg = p_val_ipi_seg-((p_val_ipi_seg*p_pct_base_ipi)/100)
     LET p_val_ipi_fre = p_val_ipi_seg*p_itens.pct_ipi/100
     LET p_val_ipi_fre = p_val_ipi_fre-((p_val_ipi_fre*p_pct_desc_ipi)/100)
     LET p_tot_ipi_fre = p_tot_ipi_fre+p_val_ipi_fre
     IF p_pedidos.ies_frete = 4 THEN
       LET p_valor_total_fre = (p_valor_total_liq*p_relatm.pct_frete)/100
     END IF
     IF p_pedidos.ies_frete = 6 THEN
       LET p_valor_total_fre = p_valor_total_fre+p_itens.val_frete_unit
       LET p_valor_total_seg = p_valor_total_seg+p_itens.val_seguro_unit
     ELSE
       LET p_valor_total_fre = p_valor_total_fre+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend) * p_itens.val_frete_unit)
       LET p_valor_total_seg = p_valor_total_seg+((p_itens.qtd_pecas_solic-p_itens.qtd_pecas_cancel-p_itens.qtd_pecas_atend)*p_itens.val_seguro_unit)
     END IF
   END IF
   WHENEVER ERROR CONTINUE
   SELECT num_serie
     INTO p_itens.num_serie
     FROM ped_itens_serie
    WHERE cod_empresa   = p_itens.cod_empresa
      AND num_pedido    = p_itens.num_pedido
      AND num_sequencia = p_itens.num_sequencia
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
     LET p_itens.num_serie = ""
   END IF
   IF mr_tela.ies_texto_item = "S" THEN
     CALL vdp1361_busca_texto(p_itens.num_sequencia)
   END IF
END FUNCTION

#--------------------------#
REPORT vdp1361_relat(p_relat)
#--------------------------#
   DEFINE p_relat            CHAR(15)
   DEFINE p_qtd_pecas_saldo  LIKE ped_itens.qtd_pecas_solic
   DEFINE p_valor_total_tot  DECIMAL(15,2)
   DEFINE l_item_onu         CHAR(27) #OS 337056

   OUTPUT TOP    MARGIN  0
          LEFT   MARGIN  0
          BOTTOM MARGIN  1
          PAGE   LENGTH 66

   FORMAT
   PAGE HEADER
{      CASE mr_tela.ies_formulario
         WHEN 1
              PRINT ASCII 15;
              PRINT log500_determina_cpp(80) CLIPPED;
         WHEN 2
              PRINT log500_determina_cpp(132) CLIPPED;
              PRINT ASCII 18;
         WHEN 3
              PRINT log500_determina_cpp(132) CLIPPED;
      END CASE
}
      LET p_page = p_page + 1
      PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
      PRINT COLUMN   1, p_den_empresa,
            COLUMN 101, "PEDIDO NUMERO ***",
            COLUMN 121, p_relatm.num_pedido  USING "########",
            COLUMN 130, "***"
      SKIP 1 LINE
      PRINT COLUMN   1, "VDP1361",
            COLUMN  36, "P E D I D O ",
            COLUMN  58, "I N T E R N O",
            COLUMN 125, "FL. ", p_page USING "####"
      PRINT ### COLUMN   1, "UNIDADE DE MEDIDA - PESO = KG , VALOR = R$", # os 113526
            COLUMN  96, "EXTRAIDO EM ", TODAY USING "dd/mm/yy",
            COLUMN 117, "AS ", TIME,
            COLUMN 129, "HRS."
      SKIP 1 LINE
      PRINT COLUMN   1, "DATA EMISSAO.:",
            COLUMN  18, p_relatm.dat_pedido USING "dd/mm/yy"
      PRINT COLUMN   1, "*----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "-------------------------------------*"
      PRINT COLUMN  38, "*** D A D O S      D O      C L I E N T E  ***"
      PRINT COLUMN   1, "COD. CLIENTE..:",
            COLUMN  17, p_relatm.cod_cliente,
            COLUMN  33, "CNPJ.CPF.:",
            COLUMN  45, p_relatm.num_cgc_cpf,
            COLUMN  65, p_relatm.nom_cliente
      PRINT COLUMN   1, "REPRESENTANTE.:",
            COLUMN  17, p_relatm.cod_repres USING "####",
            COLUMN  22, p_relatm.raz_social
      PRINT COLUMN   1, "ENDERECO......:",
            COLUMN  17, p_relatm.end_cliente,
            COLUMN  74, "PROMOTOR:",
            COLUMN  84, p_relatm.cod_repres_adic,
            COLUMN  88, p_relatm.nom_promotor
      IF p_relatm.den_bairro IS NOT NULL THEN
         PRINT COLUMN   1, "BAIRRO........:",
               COLUMN  17, p_relatm.den_bairro,
               COLUMN  39, "CIDADE........:",
               COLUMN  55, p_relatm.den_cidade[1,18],
               COLUMN  74, "CEP.....:",
               COLUMN  84, p_relatm.cod_cep,
               COLUMN 104, "UF...:",
               COLUMN 111, p_relatm.cod_uni_feder
      ELSE
         PRINT COLUMN   1, "CIDADE........:",
               COLUMN  17, p_relatm.den_cidade[1,18],
               COLUMN  74, "CEP.....:",
               COLUMN  84, p_relatm.cod_cep,
               COLUMN 104, "UF...:",
               COLUMN 111, p_relatm.cod_uni_feder
      END IF
      PRINT COLUMN   1, "CIDADE ENTREG.:",
            COLUMN  17, p_relatm.den_cidade_ent,
            COLUMN  74, "CEP.....:",
            COLUMN  84, p_relatm.cod_cep_ent
      PRINT COLUMN   1, "ENDERECO ENTR.:",
            COLUMN  17, p_relatm.end_entrega,
            COLUMN  74, "FRT POSTO",
            COLUMN  84, p_relatm.den_frete_posto,
            COLUMN 104, "MARCA:",
            COLUMN 111, p_relatm.den_marca
      PRINT COLUMN   1, "*----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "-------------------------------------*"
      PRINT COLUMN  38, "*** D A D O S      D O      P E D I D O  ***"
      PRINT COLUMN   1, "TIPO DE VENDA.:",
            COLUMN  17, p_relatm.den_tip_venda,
            COLUMN  44, "ROTA..........:",
            COLUMN  60, p_relatm.cod_rota USING "#####",
            COLUMN  69, p_relatm.den_rota,
            COLUMN  96, "FRETE.........:",
            COLUMN 112, p_relatm.des_frete
      PRINT COLUMN   1, "SIT. PEDIDO...:",
            COLUMN  17, p_relatm.des_sit_pedido,
            COLUMN  44, "OPERACAO......:",
            COLUMN  60, p_relatm.cod_nat_oper USING "####" ,
            COLUMN  65, p_relatm.den_operac,
            COLUMN  96, "PRECO.........:",
            COLUMN 112, p_relatm.des_preco
      PRINT COLUMN   1, "ACEITE COMERC.:",
            COLUMN  17, p_relatm.des_aceite_comerc,
            COLUMN  44, "FINALIDADE....:",
            COLUMN  60, p_relatm.des_finalidade,
            COLUMN  96, "ENTREGA.......:",
            COLUMN 112, p_relatm.des_entrega
      PRINT COLUMN   1, "ACEITE FINANC.:",
            COLUMN  17, p_relatm.des_aceite_financ,
            COLUMN  44, "COND. PGTO....:", p_pedidos.cod_cnd_pgto USING "####",
            COLUMN  65, p_relatm.den_cnd_pgto,
            COLUMN  96, "TIPO PEDIDO...:",
            COLUMN 112, p_relatm.des_tip_pedido
      PRINT COLUMN   1, "PEDIDO CLIENTE:",
            COLUMN  17, p_relatm.num_pedido_cli,
            COLUMN  44, "%DESC. FINANC.:",
            COLUMN  60, p_relatm.pct_desc_financ USING "#&.&&",
            COLUMN  96, "%COMIS........:",
            COLUMN 112, p_relatm.pct_comissao USING "#&.&&"
      PRINT COLUMN   1, "DATA EMISS....:",
            COLUMN  17, p_relatm.dat_emis_repres USING "dd/mm/yy",
            COLUMN  44, "PEDIDO REPRES.:",
            COLUMN  60, p_relatm.num_pedido_repres,
            COLUMN  96, "PADRAO EMBAL..:",
            COLUMN 112, p_relatm.des_embalagem
      PRINT COLUMN   1, "% DESC. ADIC..:",
            COLUMN  17, p_relatm.pct_desc_adic USING "#&.&&",
            COLUMN  44, "TABELA PRECO..:",
            COLUMN  60, p_relatm.num_list_preco,
            COLUMN  96, "       MOEDA..:",
            COLUMN 112, p_relatm.den_moeda
      PRINT COLUMN   1, "LOCAL ESTOQUE.:",
            COLUMN  17, p_relatm.cod_local_estoq," - ",
            COLUMN  30, p_relatm.den_local_estoq,
            COLUMN  96, "CARTEIRA......:",
            COLUMN 112, p_relatm.cod_tip_carteira, " -  ",
                        p_relatm.den_tip_carteira
      PRINT COLUMN   1, "TRANSPORTADORA:",
            COLUMN  17, p_relatm.cod_transpor,
            COLUMN  33, p_relatm.den_transpor, " - FONE: ", p_relatm.num_telefone;
      IF p_pedidos.ies_frete = "1" OR
         p_pedidos.ies_frete = "2" OR
         p_pedidos.ies_frete = "3" THEN
         PRINT " "
      ELSE
         PRINT COLUMN  96, "% FRETE.......:",
               COLUMN 112, p_relatm.pct_frete    USING "#&.&&"
      END IF
      PRINT COLUMN   1, "CONSIGNATARIO.:",
            COLUMN  17, p_relatm.cod_consig,
            COLUMN  33, p_relatm.den_consig
      PRINT COLUMN   1, "*----------------------------------------------",
            COLUMN  48, "-----------------------------------------------",
            COLUMN  95, "-------------------------------------*"
      IF p_par_vdp.par_vdp_txt[98] = "S" THEN
         PRINT COLUMN   1, " ITEM PRODUTO         UN  DESCRICAO DO PRODUTO"
         PRINT COLUMN  22, " SOLICITADA      ATENDIDA    CANCELADA       SALDO  DESC.BRUTO  PRECO UNIT.   PRECO LIQ.  %DESC PCT.IPI ENTREGA"
      ELSE
         PRINT COLUMN   1, " ITEM PRODUTO         DESCRICAO DO PRODUTO       UN    SOLICITADA  DESC.BRUTO  PRECO UNIT.   PRECO LIQ. PCT.IPI %DESC.ADIC   ENTREGA"
         PRINT COLUMN   1, "-----------------------------------------------",
               COLUMN  48, "-----------------------------------------------",
               COLUMN  95, "--------------------------------------"
      END IF

   ON EVERY ROW
      IF p_relat = "MESTRE" THEN
         SKIP TO TOP OF PAGE
      END IF

      IF p_relat = "ITENS" THEN
         NEED 8 LINES
         LET p_qtd_pecas_saldo = p_itens.qtd_pecas_solic -
             p_itens.qtd_pecas_atend - p_itens.qtd_pecas_cancel
         IF p_qtd_pecas_saldo < 0 THEN
            LET p_qtd_pecas_saldo = 0
         END IF

         IF p_par_vdp.par_vdp_txt[98] = "S" THEN
            PRINT COLUMN   1, p_itens.num_sequencia USING "#####",
                  COLUMN   7, p_itens.cod_item,
                  COLUMN  23, p_cod_unid_med,
                  COLUMN  27, p_den_item
            PRINT COLUMN  21, p_itens.qtd_pecas_solic  USING "#######&.&&&",
                  COLUMN  35, p_itens.qtd_pecas_atend  USING "#######&.&&&",
                  COLUMN  49, p_itens.qtd_pecas_cancel USING "######&.&&&",
                  COLUMN  61, p_qtd_pecas_saldo        USING "######&.&&&",
                  COLUMN  75, p_itens.pct_desc_bruto   USING "##&.&&&&",
                  COLUMN  83, p_itens.pre_unit         USING "######&.&&&&&&",
                  COLUMN  98, p_itens.pre_unit_liq     USING "######&.&&&&&",
                  COLUMN 112, p_itens.pct_desc_adic    USING "#&.&&",
                  COLUMN 119, p_itens.pct_ipi          USING "#&.&&",
                  COLUMN 125, p_itens.prz_entrega      USING "dd/mm/yy"
         ELSE
            PRINT COLUMN   1, p_itens.num_sequencia    USING "#####",
                  COLUMN   7, p_itens.cod_item,
                  COLUMN  23, p_den_item_1,
                  COLUMN  50, p_cod_unid_med,
                  COLUMN  52, p_qtd_pecas_saldo        USING "#######&.&&&",
                  COLUMN  67, p_itens.pct_desc_bruto   USING "##&.&&&&&&",
                  COLUMN  77, p_itens.pre_unit         USING "#####&.&&&&&&",
                  COLUMN  91, p_itens.pre_unit_liq     USING "#####&.&&&&&&",
                  COLUMN 107, p_itens.pct_ipi          USING "#&.&&",
                  COLUMN 117, p_itens.pct_desc_adic    USING "#&.&&",
                  COLUMN 123, p_itens.prz_entrega      USING "dd/mm/yyyy"

            IF p_den_item_2 <> " " THEN
               PRINT COLUMN  23, p_den_item_2
               IF p_den_item_3 <> " " THEN
                  PRINT COLUMN  23, p_den_item_3
               END IF
            END IF
         END IF

         WHENEVER ERROR CONTINUE
         SELECT item
           FROM fat_item_emerg
          WHERE empresa = p_cod_empresa
            AND item    = p_itens.cod_item
         WHENEVER ERROR STOP

         IF sqlca.sqlcode = 0 THEN
            LET l_item_onu = "ITEM CONTROLADO OU PERIGOSO"
            PRINT COLUMN  27, l_item_onu
         ELSE
            WHENEVER ERROR CONTINUE
            SELECT item
             FROM fat_item_controle
            WHERE empresa = p_cod_empresa
              AND item    = p_itens.cod_item
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 THEN
               LET l_item_onu = "ITEM CONTROLADO OU PERIGOSO"
               PRINT COLUMN  27, l_item_onu
            END IF
         END IF

         IF p_itens.num_serie IS NOT NULL THEN
            PRINT COLUMN 023, "NUMERO DE SERIE: ", p_itens.num_serie
         END IF
       END IF
       IF p_relat = "GRADE" THEN
         PRINT COLUMN   7,        ma_ctr_grade[1].den_grade       CLIPPED," ",
                                  ma_ctr_grade[1].den_cod_grade   CLIPPED,
               COLUMN   m_column_grade1, ma_ctr_grade[2].den_grade       CLIPPED, " ",
                            ma_ctr_grade[2].den_cod_grade   CLIPPED,
          COLUMN   m_column_grade2, ma_ctr_grade[3].den_grade       CLIPPED, " ",
                            ma_ctr_grade[3].den_cod_grade   CLIPPED,
          COLUMN   m_column_grade3, ma_ctr_grade[4].den_grade       CLIPPED, " ",
                            ma_ctr_grade[4].den_cod_grade   CLIPPED,
          COLUMN   m_column_grade4, ma_ctr_grade[5].den_grade       CLIPPED, " ",
                         ma_ctr_grade[5].den_cod_grade   CLIPPED,
               COLUMN   m_column_grade5, "QTDE: ", (mr_ped_itens_grade.qtd_pecas_solic  -
                                        mr_ped_itens_grade.qtd_pecas_atend  -
                                        mr_ped_itens_grade.qtd_pecas_cancel  )
                                                       USING "<<<,<<<,<<&.&&&"
      END IF

      IF p_relat = "GRADE_PRINT" THEN
         PRINT COLUMN   1, " "
      END IF

      IF p_relat = "BNF" THEN
         PRINT COLUMN  55, "*** ITENS DE BONIFICACAO ***"
      END IF

      IF p_relat = "TOTAL" THEN
         LET p_valor_total_tot = p_valor_total_liq +
                                 p_valor_total_ipi +
                                 p_tot_ipi_fre     +
                                 p_valor_total_fre +
                                 p_valor_total_seg
         NEED 4 LINES
         PRINT COLUMN   1, "-----------------------------------------------",
               COLUMN  48, "-----------------------------------------------",
               COLUMN  95, "--------------------------------------"
         PRINT COLUMN   2, "T O T A I S...:  PESO...:",
               COLUMN  28, p_peso_total      USING "#,###,##&.&&&",
               COLUMN  55, "VALOR BRUTO..:",
               COLUMN  65, p_valor_total_bru USING "##,###,###,##&.&&",
               COLUMN  90, "VALOR LIQ....:",
               COLUMN 110, p_valor_total_liq USING "##,###,###,##&.&&"
         PRINT COLUMN  19, "PECAS..:",
               COLUMN  28, p_qtd_pecas_total USING "###,###,###,###,###",
               COLUMN  55, "FRETE .......:",
               COLUMN  65, p_valor_total_fre USING "##,###,###,##&.&&",
               COLUMN  90, "SEGURO ......:",
               COLUMN 110, p_valor_total_seg USING "##,###,###,##&.&&"
         IF mr_tela.ies_embute = "S" THEN
            PRINT COLUMN  55, "VALOR IPI....:",
                  COLUMN  65, p_valor_total_ipi +
                              p_tot_ipi_fre       USING "##,###,###,##&.&&",
                  COLUMN  90, "VALOR TOTAL..:",
                  COLUMN 110, p_valor_total_tot USING "##,###,###,##&.&&"
         END IF
         PRINT COLUMN   1, "-----------------------------------------------",
               COLUMN  48, "-----------------------------------------------",
               COLUMN  95, "--------------------------------------"
      END IF

      IF p_relat = "OBSERVACAO" THEN
         PRINT COLUMN   3, "OBSERVACAO...:",
               COLUMN  18, p_relato.tex_observ_1
         IF p_relato.tex_observ_2 IS NULL OR p_relato.tex_observ_2 = " " THEN
            ELSE PRINT COLUMN  18, p_relato.tex_observ_2
         END IF
      END IF

      IF p_relat[1,5] = "TEXTO" AND
         m_tem_texto            THEN
         LET m_tem_texto = FALSE

         IF p_relat = "TEXTO PEDIDO" THEN
            PRINT
            PRINT COLUMN   3, "TEXTO PEDIDO.:";
         ELSE
            PRINT COLUMN   3, "TEXTO ITEM...:";
         END IF
         PRINT COLUMN  18, p_ped_texto.den_texto_1

         IF p_ped_texto.den_texto_2 IS NULL OR
            p_ped_texto.den_texto_2 = " " THEN
         ELSE
            PRINT COLUMN  18, p_ped_texto.den_texto_2
         END IF

         IF p_ped_texto.den_texto_3 IS NULL OR
            p_ped_texto.den_texto_3 = " " THEN
            ELSE PRINT COLUMN  18, p_ped_texto.den_texto_3
         END IF

         IF p_ped_texto.den_texto_4 IS NULL OR
            p_ped_texto.den_texto_4 = " " THEN
            ELSE PRINT COLUMN  18, p_ped_texto.den_texto_4
         END IF

         IF p_ped_texto.den_texto_5 IS NULL OR
            p_ped_texto.den_texto_5 = " " THEN
            ELSE PRINT COLUMN  18, p_ped_texto.den_texto_5
         END IF
      END IF

      #E# - 469670
      IF  p_relat = 'OBS EXPEDICAO' THEN
          IF  (mr_txt_exped.texto_1 IS NOT NULL AND mr_txt_exped.texto_1 <> ' ') OR
              (mr_txt_exped.texto_2 IS NOT NULL AND mr_txt_exped.texto_2 <> ' ') OR
              (mr_txt_exped.texto_3 IS NOT NULL AND mr_txt_exped.texto_3 <> ' ') OR
              (mr_txt_exped.texto_4 IS NOT NULL AND mr_txt_exped.texto_4 <> ' ') THEN

              IF  mr_txt_exped.texto_1 IS NOT NULL AND mr_txt_exped.texto_1 <> ' ' THEN
                  PRINT
                  PRINT COLUMN   3, "OBS EXPEDICAO:",
                        COLUMN  18, mr_txt_exped.texto_1
              END IF

              IF  mr_txt_exped.texto_2 IS NOT NULL AND
                  mr_txt_exped.texto_2 <> ' '      THEN
                  IF  mr_txt_exped.texto_1 IS NOT NULL AND mr_txt_exped.texto_1 <> ' ' THEN
                      PRINT COLUMN  18, mr_txt_exped.texto_2
                  ELSE
                      PRINT
                      PRINT COLUMN   3, "OBS EXPEDICAO:",
                            COLUMN  18, mr_txt_exped.texto_2
                  END IF
              END IF

              IF  mr_txt_exped.texto_3 IS NOT NULL AND
                  mr_txt_exped.texto_3 <> ' '      THEN
                  IF  (mr_txt_exped.texto_1 IS NOT NULL AND mr_txt_exped.texto_1 <> ' ') OR
                      (mr_txt_exped.texto_2 IS NOT NULL AND mr_txt_exped.texto_2 <> ' ') THEN
                      PRINT COLUMN  18, mr_txt_exped.texto_3
                  ELSE
                      PRINT
                      PRINT COLUMN   3, "OBS EXPEDICAO:",
                            COLUMN  18, mr_txt_exped.texto_3
                  END IF
              END IF

              IF  mr_txt_exped.texto_4 IS NOT NULL AND
                  mr_txt_exped.texto_4 <> ' '      THEN
                  IF  (mr_txt_exped.texto_1 IS NOT NULL AND mr_txt_exped.texto_1 <> ' ') OR
                      (mr_txt_exped.texto_2 IS NOT NULL AND mr_txt_exped.texto_2 <> ' ') OR
                      (mr_txt_exped.texto_3 IS NOT NULL AND mr_txt_exped.texto_3 <> ' ') THEN
                      PRINT COLUMN  18, mr_txt_exped.texto_4
                  ELSE
                      PRINT
                      PRINT COLUMN   3, "OBS EXPEDICAO:",
                            COLUMN  18, mr_txt_exped.texto_4
                  END IF
              END IF
          END IF
      END IF
      #E# - 469670

   ON LAST ROW
      LET p_last_row = TRUE

   PAGE TRAILER
      IF p_last_row = true THEN
         PRINT "* * * ULTIMA FOLHA * * *";
         PRINT log5211_termino_impressao() CLIPPED
         LET p_last_row = FALSE
         LET p_page = 0
      ELSE
         PRINT " "
      END IF
END REPORT

#------------------------------------#
 FUNCTION vdp1361_deleta_pedidos_list()
#------------------------------------#
   CALL log085_transacao("BEGIN")
   IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("BEGIN","DELETA_PEDIDOS")
   END IF
   WHENEVER ERROR CONTINUE
   DELETE FROM pedido_list
    WHERE cod_empresa = p_cod_empresa
      AND nom_usuario = p_user
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("EXCLUSAO_1","PEDIDO")
      CALL log085_transacao("ROLLBACK")
   ELSE
      CALL log085_transacao("COMMIT")
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("EXCLUSAO_2","PEDIDO")
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
END FUNCTION

#-------------------------------#
 FUNCTION vdp1361_version_info()
#-------------------------------#

 RETURN "$Archive: /especificos/logix10R2/kanaflex_sa_industria_de_plasticos/vendas/vendas/programas/vdp1361.4gl $|$Revision: 2 $|$Date: 2/06/11 15:08 $|$Modtime: 31/05/11 11:07 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

END FUNCTION
