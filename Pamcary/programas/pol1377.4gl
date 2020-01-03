#-----------------------------------------------------------------#
# SISTEMA.: CONTAS A RECEBER                                      #
# PROGRAMA: POL1377                                               #
# OBJETIVO: IMPRESSAO DE BOLETOS A LASER                          #
# AUTOR...: ANDREI DAGOBERTO STREIT                               #
# DATA....: 24/10/2003                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa          LIKE empresa.cod_empresa,
          p_user                 LIKE usuario.nom_usuario,
          p_status               SMALLINT,
          m_den_empresa          LIKE emp_raz_soc.den_razao_social,
          p_den_empresa          LIKE empresa.den_empresa,
          m_den_cedente          CHAR(100),
          m_den_cedente_repre    CHAR(100),
          g_comando              CHAR(200),
          p_par_bloqueto         RECORD LIKE par_bloqueto_laser.*,
          p_nf_bloqueto          RECORD LIKE nf_bloqueto.*,
          g_cod_impressora       LIKE impressoras.cod_impressora,
          g_novo_numero          CHAR(20),
          g_cod_carteira         CHAR(02)

   DEFINE gr_par_bloq_laser      RECORD LIKE par_bloqueto_laser.*
   DEFINE gr_par_escrit_txt      RECORD LIKE par_escritural_txt.*

   DEFINE gr_relat               RECORD
           cod_cliente               LIKE clientes.cod_cliente,
           nom_banco                 CHAR(30),
           cod_banco                 CHAR(05),
           den_empresa               CHAR(36),
           cod_agencia               CHAR(06),
           cod_cedente               CHAR(15),
           dat_vencto                DATE,
           cod_carteira              CHAR(06),
           nosso_numero              CHAR(20),
           dat_emissao               DATE,
           dat_proces                DATE,
           num_docum                 CHAR(14),
           esp_docum                 CHAR(08),
           cod_aceite                CHAR(05),
           val_docum                 DECIMAL(16,2),
           esp_moeda                 CHAR(10),
           nom_cliente               CHAR(36),
           end_cliente               CHAR(36),
           den_bairro                CHAR(20),
           cod_cep                   CHAR(09),
           den_cidade                CHAR(30),
           cod_uni_feder             CHAR(02),
           num_cgc_cpf               CHAR(19),
           loc_pgto_1                CHAR(60),
           loc_pgto_2                CHAR(60),
           instrucoes1               CHAR(74),
           instrucoes2               CHAR(74),
           instrucoes3               CHAR(74),
           instrucoes4               CHAR(74),
           instrucoes5               CHAR(74),
           instrucoes6               CHAR(74),
           txt_barras                CHAR(54),
           cod_barras                CHAR(44),
           out_deducoes              DECIMAL(16,2)
                                 END RECORD

   DEFINE p_ies_impressao        CHAR(001),
          g_ies_ambiente         CHAR(001),
          p_nom_arquivo          CHAR(100),
          p_nom_arquivo1         CHAR(100),
          g_todos_sistemas       CHAR(001)

   DEFINE g_ies_grafico          SMALLINT

   DEFINE p_versao               CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

   DEFINE mr_dados_empresa       RECORD LIKE empresa.*,
          mr_dados_cliente       RECORD LIKE clientes.*,
          mr_dados_vend          RECORD LIKE representante.*,
          mr_par_cre             RECORD LIKE par_cre.*,
          mr_par_cre_txt         RECORD LIKE par_cre_txt.*,
          mr_docum               RECORD LIKE docum.*,
          mr_par_escrit_txt      RECORD LIKE par_escritural_txt.*,
          mr_par_bloq_laser      RECORD LIKE par_bloqueto_laser.*,
          mr_dados_banco         RECORD LIKE portador.*,
          mr_docum_banco         RECORD LIKE docum_banco.*

   DEFINE mr_tela1               RECORD
                                 empresa           CHAR(02),
                                 docum_ini         CHAR(14),
                                 portador          DECIMAL(4,0),
                                 tip_portador      CHAR(01),
                                 nom_abr_portador  CHAR(12)
                                 END RECORD

   DEFINE mr_tela2               RECORD
                                 empresa           CHAR(02),
                                 ies_num_docum     CHAR(01),
                                 documento_de      CHAR(14),
                                 documento_ate     CHAR(14),
                                 portador          DECIMAL(4,0),
                                 tip_portador      CHAR(01),
                                 nom_abr_portador  CHAR(12),
                                 carta_de          CHAR(10),
                                 carta_ate         CHAR(10),
                                 mes_competencia   CHAR(02),
                                 ano_competencia   CHAR(04)
                                 END RECORD

   DEFINE m_dados_relat          ARRAY[9999]OF RECORD
                                 cod_cliente       CHAR(02),
                                 nom_cliente       CHAR(36),
                                 end_cliente       CHAR(36),
                                 den_bairro        CHAR(19),
                                 den_cidade        CHAR(30),
                                 cod_uni_feder     CHAR(02),
                                 cod_cep           CHAR(09)
                                 END RECORD


    DEFINE ma_instrucoes         ARRAY[10] OF RECORD
                                 texto             CHAR(74)
                                 END RECORD

   DEFINE mr_relat               RECORD
                                 cod_cliente       LIKE clientes.cod_cliente,
                                 nom_banco         CHAR(30),
                                 cod_banco         CHAR(05),
                                 den_empresa       CHAR(36),
                                 cod_agencia       CHAR(06),
                                 cod_cedente       CHAR(25),
                                 dat_vencto        DATE,
                                 cod_carteira      CHAR(06),
                                 nosso_numero      CHAR(20),
                                 dat_emissao       DATE,
                                 dat_proces        DATE,
                                 num_docum         CHAR(14),
                                 esp_docum         CHAR(08),
                                 cod_aceite        CHAR(05),
                                 val_docum         DECIMAL(16,2),
                                 esp_moeda         CHAR(10),
                                 nom_cliente       CHAR(36),
                                 end_cliente       CHAR(36),
                                 den_bairro        CHAR(20),
                                 cod_cep           CHAR(09),
                                 den_cidade        CHAR(30),
                                 cod_uni_feder     CHAR(02),
                                 num_cgc_cpf       CHAR(19),
                                 loc_pgto_1        CHAR(60),
                                 loc_pgto_2        CHAR(60),
                                 instrucoes1       CHAR(74),
                                 instrucoes2       CHAR(74),
                                 instrucoes3       CHAR(74),
                                 instrucoes4       CHAR(74),
                                 instrucoes5       CHAR(74),
                                 instrucoes6       CHAR(74),
                                 txt_barras        CHAR(54),
                                 cod_barras        CHAR(44),
                                 out_deducoes      DECIMAL(16,2)
                                 END RECORD



   DEFINE g_reimpressao             SMALLINT

   DEFINE p_relat
          RECORD
             cod_cliente            LIKE clientes.cod_cliente,
             nom_banco              CHAR(30),
             cod_banco              CHAR(05),
             den_empresa            CHAR(36),
             cod_agencia            CHAR(06),
             cod_cedente            CHAR(25),
             dat_vencto             DATE,
             cod_carteira           CHAR(06),
             nosso_numero           CHAR(20),
             dat_emissao            DATE,
             dat_proces             DATE,
             num_docum              CHAR(14),
             esp_docum              CHAR(08),
             cod_aceite             CHAR(05),
             val_docum              DECIMAL(16,2),
             esp_moeda              CHAR(10),
             nom_cliente            CHAR(36),
             end_cliente            CHAR(36),
             den_bairro             CHAR(20),
             cod_cep                CHAR(09),
             den_cidade             CHAR(30),
             cod_uni_feder          CHAR(02),
             num_cgc_cpf            CHAR(19),
             loc_pgto_1             CHAR(60),
             loc_pgto_2             CHAR(60),
             instrucoes1            CHAR(74),
             instrucoes2            CHAR(74),
             instrucoes3            CHAR(74),
             instrucoes4            CHAR(74),
             instrucoes5            CHAR(74),
             instrucoes6            CHAR(74),
             txt_barras             CHAR(54),
             cod_barras             CHAR(44),
             out_deducoes           DECIMAL(16,2)
          END RECORD

   DEFINE m_instrucoes7                            CHAR(74),
          m_instrucoes8                            CHAR(74)

   DEFINE m_portador2                      RECORD
                              cod_portador  LIKE portador.cod_portador,
                              ies_tip_portador LIKE portador.ies_tip_portador
                              END RECORD

   DEFINE m_caminho              CHAR(100),
          m_caminho2             CHAR(100),
          m_ies_protesto         CHAR(01),
          m_qtd_dias_protesto    CHAR(02),
          x                      SMALLINT,
          y                      SMALLINT,
          z                      SMALLINT,
          i                      SMALLINT,
          m_num_duplicata        CHAR(14),
          m_num_docum            CHAR(20),
          m_msg                  CHAR(100),
          m_emitiu               SMALLINT,
          m_erro                 SMALLINT,
          m_ind                  SMALLINT,
          m_ind2                 SMALLINT,
          p_cod_programa         CHAR(07),
          m_pct_desc_financ      LIKE cond_pgto_item.pct_desc_financ,
          m_portador             LIKE docum.cod_portador,
          m_houve_erro           SMALLINT,
          m_grupo                LIKE cre_escrit_compl.grupo

 DEFINE g_nao_exclui_par        SMALLINT
 DEFINE g_numero_convenio       CHAR(07)  #os TEJNN4
END GLOBALS



#MODULARES
   DEFINE m_reimpressao          SMALLINT,
          m_cod_hist_fiscal      DECIMAL(12,2),
          m_msg_de               CHAR(76),
          m_msg_para             CHAR(76),
          m_msg_meio             CHAR(76),
          m_msg_roteiro          CHAR(76),
          m_msg_ref              CHAR(76),
          m_msg_carta            CHAR(20),
          m_data_extenso         CHAR(76),
          m_qtd_linhas_pagina    INTEGER ,
          m_total_paginas        SMALLINT,
          m_pagina               SMALLINT,
          m_last_row             SMALLINT,
          m_sequencia_carta      INTEGER ,
          m_dat_competencia_ant  DATE

   DEFINE ma_config     ARRAY[10000] OF RECORD
            linha CHAR(10000)
          END RECORD

   #497350
   DEFINE m_ind_pdf INTEGER
   DEFINE mr_demonst             RECORD
                                 #Topo do demonstrativo
                                 dem_telerisco_num  LIKE docum.num_docum,
                                 val_adm            CHAR(10),
                                 val_emissao        DATE,
                                 val_vencimento     DATE,
                                 val_raz_soc        CHAR(40),
                                 val_cnpj_cpf       LIKE clientes.num_cgc_cpf,
                                 val_insc_est       CHAR(16),
                                 #Valores totais do demonstrativo
                                 val_cedente        CHAR(40),
                                 val_age_cod_ced    CHAR(25), #CHAR(04),
                                 val_nosso_num      CHAR(20),
                                 val_cons_pesq      DECIMAL(15,2),
                                 val_outros_desc    DECIMAL(15,2),
                                 val_desconto       DECIMAL(15,2),
                                 val_val_acom       DECIMAL(15,2),
                                 val_iss_1          DECIMAL(15,2),
                                 val_iss_2          DECIMAL(15,2),
                                 val_pis_1          DECIMAL(15,2),
                                 val_pis_2          DECIMAL(15,2),
                                 val_confins_1      DECIMAL(15,2),
                                 val_confins_2      DECIMAL(15,2),
                                 val_csll_1         DECIMAL(15,2),
                                 val_csll_2         DECIMAL(15,2),
                                 val_sub_total      DECIMAL(15,2),
                                 val_irrf_1         DECIMAL(15,2),
                                 val_irrf_2         DECIMAL(15,2),
                                 val_inss_1         DECIMAL(15,2),
                                 val_inss_2         DECIMAL(15,2),
                                 val_total_fat      DECIMAL(15,2),
                                 #verso do boleto
                                 txt_aviso_1        CHAR(80),
                                 txt_aviso_2        CHAR(80),
                                 txt_aviso_3        CHAR(80),
                                 txt_aviso_4        CHAR(80),
                                 aling_aviso        SMALLINT,
                                 #dados cedente
                                 val_v_cedente      CHAR(40),
                                 val_v_end_cedente  CHAR(60),
                                 val_v_comp_cedente CHAR(60),
                                 val_dados_cobranca CHAR(60),
                                 val_end_1_cob      CHAR(60),
                                 val_end_2_cob      CHAR(60),
                                 val_end_3_cob      CHAR(60),
                                 val_end_4_cob      CHAR(60),
                                 cod_cip            CHAR(10)
     END RECORD

   DEFINE ma_demonst_item ARRAY[10000] OF RECORD
          praca              CHAR(28),
          qtd_sem_desconto   DECIMAL(12,3),
          qtd_com_desconto   DECIMAL(12,3),
          qtd_carreteiro     DECIMAL(12,3),
          qtd_agregado       DECIMAL(12,3),
          qtd_frota          DECIMAL(12,3),
          qtd_out_func       DECIMAL(12,3),
          qtd_repesquisa     DECIMAL(12,3),
          qtd_recad_agr      DECIMAL(12,3),
          qtd_recad_fro      DECIMAL(12,3),
          qtd_recad_out_f    DECIMAL(12,3),
          val_sem_desconto   DECIMAL(15,2),
          val_com_desconto   DECIMAL(15,2),
          val_carreteiro     DECIMAL(15,2),
          val_agregado       DECIMAL(15,2),
          val_frota          DECIMAL(15,2),
          val_out_func       DECIMAL(15,2),
          val_repesquisa     DECIMAL(15,2),
          val_recad_agr      DECIMAL(15,2),
          val_recad_fro      DECIMAL(15,2),
          val_recad_out_f    DECIMAL(15,2)
   END RECORD

   DEFINE mr_demonst_totais RECORD
            qtd_sem_desconto   DECIMAL(12,3),
            qtd_com_desconto   DECIMAL(12,3),
            qtd_carreteiro     DECIMAL(12,3),
            qtd_agregado       DECIMAL(12,3),
            qtd_frota          DECIMAL(12,3),
            qtd_out_func       DECIMAL(12,3),
            qtd_repesquisa     DECIMAL(12,3),
            qtd_recad_agr      DECIMAL(12,3),
            qtd_recad_fro      DECIMAL(12,3),
            qtd_recad_out_f    DECIMAL(12,3),
            val_sem_desconto   DECIMAL(15,2),
            val_com_desconto   DECIMAL(15,2),
            val_carreteiro     DECIMAL(15,2),
            val_agregado       DECIMAL(15,2),
            val_frota          DECIMAL(15,2),
            val_out_func       DECIMAL(15,2),
            val_repesquisa     DECIMAL(15,2),
            val_recad_agr      DECIMAL(15,2),
            val_recad_fro      DECIMAL(15,2),
            val_recad_out_f    DECIMAL(15,2)
          END RECORD

   DEFINE m_qtd_itens_por_pag     SMALLINT, #Qtde de itens por página do demonstrativo (default 18)
          m_qtd_itens_demonst     INTEGER,  #Qtde total de itens do demonstrativo
          m_qtd_pag_demonst       INTEGER,  #Qtde de páginas do demonstrativo
          m_qtd_itens_demonst_pdf SMALLINT  #Qtde de itens que serão impressos no demonstrativo,
                                            #utilizado na função pol1377_carrega_demonstrativo_detalhado (Default 41)
   DEFINE m_qtd_itens_por_pag_pdf SMALLINT
   DEFINE m_qtd_pag_demonst_pdf   INTEGER

   DEFINE ma_valores             ARRAY[100] OF RECORD
                                 valor             DECIMAL(15,03),
                                 cod_cla_uso       LIKE linha_prod.den_estr_linprod
                                 END RECORD

   DEFINE mr_relat_imp           RECORD
           endereco               CHAR(46),
           complemento            CHAR(30),
           bairro                 CHAR(56),
           cidade                 CHAR(40),
           unid_feder             CHAR(02)
                                 END RECORD

   DEFINE mr_cre_itcompl_docum   RECORD LIKE cre_itcompl_docum.*,
          mr_cre_compl_docum     RECORD LIKE cre_compl_docum.*

   DEFINE m_cod_unid_med         LIKE item.cod_unid_med,
          m_cod_lin_prod         LIKE item.cod_lin_prod,
          m_cod_lin_recei        LIKE item.cod_lin_recei,
          m_cod_seg_merc         LIKE item.cod_seg_merc,
          m_cod_cla_uso          LIKE item.cod_cla_uso,
          m_den_estr_clauso      LIKE linha_prod.den_estr_linprod,
          m_val_tot_item         DECIMAL(15,02),
          m_tem_dados            SMALLINT,
          m_imprime_bloqueto     CHAR(01),
          m_imprime_extrato      CHAR(01),
          m_cod_cliente          LIKE clientes.cod_cliente,
          m_nom_cliente          LIKE clientes.nom_cliente,
          m_pct_abat_honor       DECIMAL(5,2),
          m_cla_uso_honor        DECIMAL(2,0),
          m_mes                  CHAR(10),
          m_sinistro             LIKE cre_docum_incluido.dat_emis_bilhetag,
          m_cliente              LIKE clientes.nom_cliente,
          m_cobranca             LIKE clientes.nom_cliente,
          m_den_item             LIKE item.den_item,
          m_valor_total          DECIMAL(15,03),
          comando                CHAR(100),
          m_informou_dados       SMALLINT,
          m_controle_portador    LIKE par_bloqueto_laser.cod_portador

   DEFINE mr_selecao             RECORD
                                 todas_empresas   CHAR(01),
                                 todos_tip_docum  CHAR(01),
                                 todos_documentos CHAR(01),
                                 todos_portadores CHAR(01)
                                 END RECORD

   DEFINE m_instrucao_1,
          m_instrucao_2,
          m_instrucao_3,
          m_instrucao_4,
          m_instrucao_5,
          m_instrucao_6        CHAR(40)

   DEFINE m_pct_cofins          DECIMAL(5,2),
          m_val_cofins_retencao LIKE cre_docum_compl.parametro_val, #497350
          m_pct_pis             DECIMAL(5,2),
          m_val_pis_retencao    LIKE cre_docum_compl.parametro_val, #497350
          m_pct_csll            DECIMAL(5,2),
          m_val_csll_retencao   LIKE cre_docum_compl.parametro_val, #497350
          m_pct_irrf            DECIMAL(5,2),
          m_val_irrf            LIKE cre_docum_compl.parametro_val  #497350

   DEFINE ma_sistema           ARRAY[50] OF
          RECORD
             sistema           LIKE cre_par_sist_781.sistema,
             usa_sistema       CHAR(01)
          END RECORD

   DEFINE m_tem_erros_temp     SMALLINT,
          m_erro_docum         SMALLINT

   DEFINE m_portador_docum     LIKE docum.cod_portador,
          m_nom_abr_portador   CHAR(12)

   DEFINE m_val_iss_retencao   LIKE cre_docum_compl.parametro_val,
          m_pct_iss            LIKE obf_config_fiscal.aliquota,
          m_pct_desconto_base  LIKE obf_config_fiscal.aliquota

   DEFINE m_diretorio_pdf      LIKE vdp_par_blqt_compl.parametro_texto,
          m_nom_arquivo_pdf    LIKE vdp_par_blqt_compl.parametro_texto,
          m_nom_arquivo        CHAR(200)

   DEFINE m_total_ordena           SMALLINT #CHAR(02) #SMALLINT
   DEFINE m_cnpj_cli_agrupado_aux  LIKE cre_itcompl_docum.cnpj_cli_agrupado
   DEFINE m_count                  SMALLINT
   DEFINE m_count_aux              SMALLINT
   DEFINE m_count_praca            SMALLINT
   DEFINE m_count_praca_aux        SMALLINT
   DEFINE m_val_iss_2              DECIMAL(15,2)
   DEFINE m_val_pis_2              DECIMAL(15,2)
   DEFINE m_val_confins_2          DECIMAL(15,2)
   DEFINE m_val_csll_2             DECIMAL(15,2)
   DEFINE m_val_irrf_2             DECIMAL(15,2)
   DEFINE m_tem_demonst_agrupado   SMALLINT
   DEFINE m_ind3                   SMALLINT
   DEFINE m_deletou_arquivo_atual  SMALLINT

#USADO PARA A IMPRESSÃO NO BLOQUETO
   DEFINE ma_total_demonst_p_bloqueto ARRAY[10000] OF RECORD
                   praca              CHAR(28)     ,
                   qtd_sem_desconto   DECIMAL(12,3),
                   qtd_com_desconto   DECIMAL(12,3),
                   qtd_carreteiro     DECIMAL(12,3),
                   qtd_agregado       DECIMAL(12,3),
                   qtd_frota          DECIMAL(12,3),
                   qtd_out_func       DECIMAL(12,3),
                   qtd_repesquisa     DECIMAL(12,3),
                   qtd_recad_agr      DECIMAL(12,3),
                   qtd_recad_fro      DECIMAL(12,3),
                   qtd_recad_out_f    DECIMAL(12,3),
                   val_sem_desconto   DECIMAL(15,2),
                   val_com_desconto   DECIMAL(15,2),
                   val_carreteiro     DECIMAL(15,2),
                   val_agregado       DECIMAL(15,2),
                   val_frota          DECIMAL(15,2),
                   val_out_func       DECIMAL(15,2),
                   val_repesquisa     DECIMAL(15,2),
                   val_recad_agr      DECIMAL(15,2),
                   val_recad_fro      DECIMAL(15,2),
                   val_recad_out_f    DECIMAL(15,2)
          END RECORD

   DEFINE m_ind_p_bloqueto    INTEGER
   DEFINE m_cnpj_cli_agrupado LIKE cre_itcompl_docum.cnpj_cli_agrupado
#-----

   DEFINE m_total_pag     INTEGER
   DEFINE m_total_pag_aux INTEGER

   DEFINE m_caminho_carta_2_via CHAR(100)
   DEFINE m_caminho_carta_2_via_aux CHAR(200)

   #UTILIZADO PARA SEQUENCIA INFORMAÇÃO DA CARTA
   DEFINE m_meio_envio_anterior      LIKE cre_compl_docum.meio_envio
   DEFINE m_roteiro_anterior         LIKE cre_compl_docum.roteiro
   DEFINE m_filial_cobranca_anterior LIKE cre_compl_docum.filial_cobranca
   #-----

   DEFINE m_msg_rodape CHAR(80)

   #UTILIZADO NO PREMIO MINIMO
   DEFINE m_total_itens_demonst      DECIMAL(12,3)
   #-----

   DEFINE ma_tela_2 ARRAY[10000] OF RECORD
                       praca              CHAR(50)     ,
                       qtd_preco_minimo   SMALLINT     ,
                       val_tot_pre_minimo DECIMAL(15,2)
                    END RECORD

   DEFINE ma_tip_consulta ARRAY[10000] OF RECORD
                             qtd_sem_desconto   DECIMAL(12,3),
                             qtd_com_desconto   DECIMAL(12,3),
                             val_sem_desconto   DECIMAL(15,2),
                             val_com_desconto   DECIMAL(15,2)
                          END RECORD

   DEFINE mr_tip_consulta RECORD
                             qtd_sem_desconto   DECIMAL(12,3),
                             qtd_com_desconto   DECIMAL(12,3),
                             val_sem_desconto   DECIMAL(15,2),
                             val_com_desconto   DECIMAL(15,2)
                          END RECORD
   DEFINE m_texto_compl CHAR(80)

   DEFINE m_deleta_caminho_aux        CHAR(200)
   DEFINE m_verifica_tip_consulta_pdf SMALLINT
   DEFINE m_ja_pulou_linha            SMALLINT
   DEFINE m_num_lote                  SMALLINT
   DEFINE m_caminho_diretorio_pdf     CHAR(200)
   DEFINE m_classif_item              CHAR(9)
   DEFINE m_tem_premio_minimo         SMALLINT

   DEFINE m_texto_retencao_fat        CHAR(100),
          m_texto_retencao_cre1       CHAR(100),
          m_texto_retencao_cre2       CHAR(100)

   DEFINE m_roteiro_especifico LIKE cre_compl_docum.roteiro
   DEFINE m_seq_rot_especifico SMALLINT
   DEFINE m_cod_cliente_ant    LIKE clientes.cod_cliente
   DEFINE m_seq_geral_boleto   SMALLINT
   DEFINE m_tem_cartas         SMALLINT

   DEFINE m_data_corte_contabilidade_L10 DATE
   DEFINE m_qtd_dia_protesto_L10         CHAR(02)

#END MODULARES

MAIN
   CALL log0180_conecta_usuario()

   LET p_versao = 'POL1377-12.02.04' 
   LET p_cod_programa = "CRE1055" 

   WHENEVER ERROR CONTINUE
      CALL log1400_isolation()
      LET m_caminho = log140_procura_caminho('pol1377.iem')

      CALL log001_acessa_usuario('CRECEBER','LOGERP')
         RETURNING p_status, p_cod_empresa, p_user
   WHENEVER ERROR STOP
   DEFER INTERRUPT

   OPTIONS
      PREVIOUS KEY control-b,
      NEXT     KEY control-f

   IF p_status = 0 THEN
      CALL pol1377_acha_parcre()
      CALL pol1377_controle()
   END IF
END MAIN

#-----------------------------#
 FUNCTION pol1377_acha_parcre()
#-----------------------------#
   INITIALIZE mr_par_cre.*,
              mr_par_cre_txt.* TO NULL

   SELECT *
     INTO mr_par_cre.*
     FROM par_cre

   IF SQLCA.sqlcode <> 0 THEN
      RETURN
   END IF

   SELECT *
     INTO mr_par_cre_txt.*
     FROM par_cre_txt

 CALL pol1377_verifica_data_corte_logix_10()

 END FUNCTION

#-----------------------------------------------#
 FUNCTION pol1377_verifica_data_corte_logix_10()
#-----------------------------------------------#

 INITIALIZE m_data_corte_contabilidade_L10 TO NULL

 #Verifica se há a tabela de data de corte, indicando que é o banco da versão 10.
 IF log0150_verifica_se_tabela_existe("ctb_dat_contab_logix_10") THEN
    WHENEVER ERROR CONTINUE
      SELECT data_contabilizacao
        INTO m_data_corte_contabilidade_L10
        FROM ctb_dat_contab_logix_10
       WHERE empresa = p_cod_empresa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CTB_DAT_CONTAB_LOGIX_10")
    END IF
 END IF

 END FUNCTION

#--------------------------#
 FUNCTION pol1377_controle()
#--------------------------#

   LET m_tem_erros_temp = FALSE
   LET m_qtd_itens_por_pag = 35
   LET m_qtd_itens_por_pag_pdf = 78

   CALL log006_exibe_teclas("01",p_versao)
   LET comando = log130_procura_caminho("pol13772")

   OPEN WINDOW w_pol13772 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)


   LET m_informou_dados = FALSE
   LET m_total_ordena = 0

   CALL pol1377_consulta_sistema()

   CURRENT WINDOW IS w_pol13772

   MENU "OPÇÃO"
      COMMAND KEY ("I") "Informar" "Informar parâmetros para processar a atualização de documentos."
         MESSAGE " "

         IF log005_seguranca(p_user,'CRECEBER','POL1377','IN') THEN
            IF  pol1377_informa_selecao_atualizacao() THEN
                IF log0040_confirm(12,20,' Processar atualização de documentos ? ') THEN
                    CALL pol1377_processa_selecao_atualizacao()
                END IF
            END IF
         END IF

      COMMAND KEY ("P") "Processar_Impressão" "Processar impressão do(s) bloqueto(s)."
         MESSAGE " "

         IF log005_seguranca(p_user,'CRECEBER','POL1377','IN') THEN
            IF pol1377_informa_impressao() THEN

               #Variavel Global utilizada nas funções crexxx_calcula_barras()
               LET m_reimpressao = FALSE

               CALL pol1377_processa_impressao()

               IF m_tem_erros_temp THEN
                  NEXT OPTION 'Listar_erros'
               ELSE
                  NEXT OPTION "Fim"
               END IF
            END IF
            CLOSE WINDOW w_pol1377
         END IF

      COMMAND KEY ("R") "processar_Reimpressão" "Processar Reimpressão do(s) bloqueto(s)."
         MESSAGE " "

         IF log005_seguranca(p_user, 'CRECEBER', 'pol1377', 'IN') THEN
            IF pol1377_informa_reimpressao() THEN
               #Variavel Global utilizada nas funções crexxx_calcula_barras()
               LET m_reimpressao = TRUE
               LET m_deleta_caminho_aux = "caminho temporario"
               CALL pol1377_processa_reimpressao()
            END IF
            CLOSE WINDOW w_pol13771
            NEXT OPTION "Fim"
         END IF

      COMMAND 'Listar_erros'
         IF m_tem_erros_temp THEN
            CALL pol1377_lista_erros()
         ELSE
            CALL log0030_mensagem("Não existem erros para serem listados.","Info")
         END IF

      COMMAND 'Fim' 'Retorna ao menu anterior.'
         IF m_tem_erros_temp THEN
            CALL log0030_mensagem('Existem erros para serem listados. ','exclamation')
         ELSE
            EXIT MENU
         END IF

   END MENU

  #---------------------------OS 451380---------------------#
   WHENEVER ERROR CONTINUE
     DELETE FROM cre_popup_sist_781
      WHERE programa = p_cod_programa
        AND usuario  = p_user
   WHENEVER ERROR CONTINUE
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELETE","cre_popup_sist_781")
   END IF
  #--------------------------OS 451380----------------------#

   WHENEVER ERROR CONTINUE
      DELETE FROM cre0270_empresa
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_tip_doc
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_num_docum
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_portador
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa
   WHENEVER ERROR STOP

   CLOSE WINDOW w_pol13772

END FUNCTION


########################
## OS 285293 - Início ##
########################
#----------------------------------------------#
 FUNCTION pol1377_informa_selecao_atualizacao()
#----------------------------------------------#
   CALL log006_exibe_teclas('01',p_versao)
   CURRENT WINDOW IS w_pol13772

   LET m_total_ordena = 0


   WHENEVER ERROR CONTINUE
      DELETE FROM cre0270_empresa
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_tip_doc
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_num_docum
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      DELETE FROM cre0270_portador
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa
   WHENEVER ERROR STOP

   INITIALIZE mr_selecao.* TO NULL

   LET mr_selecao.todas_empresas   = 'S'
   LET mr_selecao.todos_tip_docum  = 'S'
   LET mr_selecao.todos_documentos = 'S'
   LET mr_selecao.todos_portadores = 'S'

   DISPLAY BY NAME mr_selecao.*

   INPUT BY NAME mr_selecao.* WITHOUT DEFAULTS
      AFTER FIELD todas_empresas
         IF mr_selecao.todas_empresas = 'N' THEN
            CALL log006_exibe_teclas('01 02 03 05 06 07',p_versao)
            CURRENT WINDOW IS w_pol13772

            IF cre027_gerencia_entrada_dados(7, 54, p_user, p_cod_programa, 'EMPRESAS') = FALSE THEN
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
               LET mr_selecao.todas_empresas = 'S'
               DISPLAY BY NAME mr_selecao.todas_empresas
            ELSE
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
            END IF
         END IF

      AFTER FIELD todos_tip_docum
         IF mr_selecao.todos_tip_docum = 'N' THEN
            CALL log006_exibe_teclas('01 02 03 05 06 07',p_versao)
            CURRENT WINDOW IS w_pol13772

            IF cre027_gerencia_entrada_dados(12, 58, p_user, p_cod_programa, 'TIP_DOCUM') = FALSE THEN
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
               LET mr_selecao.todos_tip_docum = 'S'
               DISPLAY BY NAME mr_selecao.todos_tip_docum
            ELSE
               IF pol1377_verifica_tip_docum() = FALSE THEN
                  NEXT FIELD todos_tip_docum
               END IF
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
            END IF
         END IF

      AFTER FIELD todos_documentos
         IF mr_selecao.todos_documentos = 'N' THEN
            CALL log006_exibe_teclas('01 02 03 05 06 07',p_versao)
            CURRENT WINDOW IS w_pol13772

            IF cre027_gerencia_entrada_dados(12, 54, p_user, p_cod_programa, 'NUM_DOCUM') = FALSE THEN
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
               LET mr_selecao.todos_documentos = 'S'
               DISPLAY BY NAME mr_selecao.todos_documentos
            ELSE
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
            END IF
         END IF

      AFTER FIELD todos_portadores
         IF mr_selecao.todos_portadores = 'N' THEN
            CALL log006_exibe_teclas('01 02 03 05 06 07',p_versao)
            CURRENT WINDOW IS w_pol13772

            IF cre027_gerencia_entrada_dados(7, 44, p_user, p_cod_programa, 'PORTADOR') = FALSE THEN
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
               LET mr_selecao.todos_portadores = 'S'
               DISPLAY BY NAME mr_selecao.todos_portadores
            ELSE
               CALL log006_exibe_teclas('01',p_versao)
               CURRENT WINDOW IS w_pol13772
            END IF
         END IF

   END INPUT

   IF int_flag THEN
      LET int_flag = FALSE
      RETURN FALSE
   ELSE
      LET m_informou_dados = TRUE
      RETURN TRUE
   END IF

END FUNCTION

#-------------------------------------#
 FUNCTION pol1377_verifica_tip_docum()
#-------------------------------------#
   DEFINE l_tip_docum  LIKE docum.ies_tip_docum,
          l_eh_credito SMALLINT

   INITIALIZE l_tip_docum,
              l_eh_credito TO NULL

   LET l_eh_credito = FALSE
   DECLARE cq_tip_docum CURSOR FOR
    SELECT ies_tip_docum FROM cre0270_tip_doc
     WHERE nom_usuario  = p_user
       AND cod_programa = p_cod_programa

   FOREACH cq_tip_docum INTO l_tip_docum
      SELECT *
        FROM par_tipo_docum
       WHERE cod_empresa   = p_cod_empresa
         AND ies_tip_docum = l_tip_docum
         AND deb_cre       = 'D'

      IF sqlca.sqlcode <> 0 THEN
         ERROR "Não podem ser informados documentos de crédito: ", l_tip_docum CLIPPED
         LET l_eh_credito = TRUE
      END IF
   END FOREACH

   IF l_eh_credito THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION

#-----------------------------------------------#
 FUNCTION pol1377_processa_selecao_atualizacao()
#-----------------------------------------------#
   DEFINE lr_cre9300     RECORD
                         empresa           LIKE docum_banco.cod_empresa,
                         docum             LIKE docum_banco.num_docum,
                         tip_docum         LIKE docum_banco.ies_tip_docum,
                         portador          LIKE docum_banco.cod_portador,
                         agencia           LIKE docum_banco.cod_agencia,
                         dig_agencia       LIKE docum_banco.dig_agencia,
                         num_titulo_banco  LIKE docum_banco.num_titulo_banco,
                         dat_confirm_banco LIKE docum_banco.dat_confirm_banco,
                         emissao_boleto    LIKE docum_banco.ies_emis_boleto
   END RECORD

   DEFINE sql_stmt       CHAR(3000),
          sql_where      CHAR(2500)

   DEFINE l_count        SMALLINT,
          l_achou        SMALLINT,
          i              SMALLINT,
          l_agencia      CHAR(06),
          l_agencia_aux  CHAR(06) ,
          l_portador_ant LIKE docum.cod_portador

   INITIALIZE lr_cre9300.*,
              l_count,
              l_agencia,
              l_agencia_aux TO NULL

   MESSAGE "Processando..."

   LET l_portador_ant = 0

   LET sql_stmt = "SELECT docum.cod_empresa, docum.num_docum,",
                  " docum.ies_tip_docum, docum.cod_portador",
                  " FROM docum"

   LET sql_where = " WHERE docum.ies_situa_docum <> 'C'",
                   " AND docum.ies_cnd_bordero IN ('B','T')",
                   " AND docum.ies_tip_emis_docum = 'N'",
                   " AND docum.ies_tip_portador = 'B' ",
                   " AND docum.ies_tip_cobr IS NOT NULL ",
                   " AND docum.cod_empresa <> '1R' "

   IF g_todos_sistemas = "N" THEN
      SELECT COUNT(*)
        INTO l_count
        FROM cre_popup_sist_781 # t_sistema  #OS 451380
       WHERE cre_popup_sist_781.usuario      = p_user
         AND cre_popup_sist_781.sit_sistema  = 'S'
         AND cre_popup_sist_781.programa     = p_cod_programa



      IF l_count > 0 THEN
         LET sql_stmt  = sql_stmt CLIPPED, ", ctr_titulo_mestre, cre_popup_sist_781"#t_sistema "
         LET sql_where = sql_where CLIPPED,
                         " AND ctr_titulo_mestre.empresa = docum.cod_empresa ",

                         " AND ctr_titulo_mestre.titulo   = docum.num_docum ",
                         " AND ctr_titulo_mestre.tip_titulo = docum.ies_tip_docum ",
                         " AND ctr_titulo_mestre.sistema_gerador = cre_popup_sist_781.sistema ",#t_sistema.sistema_gerador "
                         " AND cre_popup_sist_781.usuario      = '",p_user,"'",
                         " AND cre_popup_sist_781.sit_sistema  = 'S'",
                         " AND cre_popup_sist_781.programa     = '",p_cod_programa,"'"

      END IF
   END IF

   IF mr_selecao.todas_empresas = 'N' THEN
      SELECT COUNT(*)
        INTO l_count
        FROM cre0270_empresa
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      IF l_count > 0 THEN
         LET sql_stmt  = sql_stmt CLIPPED, ", cre0270_empresa"
         LET sql_where = sql_where CLIPPED,
                         " AND cre0270_empresa.nom_usuario = '",p_user,"'",
                         " AND cre0270_empresa.cod_programa = '",p_cod_programa,"'",
                         " AND cre0270_empresa.cod_empresa = docum.cod_empresa"
      END IF
   END IF

   IF mr_selecao.todos_tip_docum = 'N' THEN
      SELECT COUNT(*)
        INTO l_count
        FROM cre0270_tip_doc
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      IF l_count > 0 THEN
         LET sql_stmt  = sql_stmt CLIPPED, ", cre0270_tip_doc"
         LET sql_where = sql_where CLIPPED,
                         " AND cre0270_tip_doc.nom_usuario = '",p_user,"'",
                         " AND cre0270_tip_doc.cod_programa = '",p_cod_programa,"'",
                         " AND cre0270_tip_doc.ies_tip_docum = docum.ies_tip_docum"
      END IF
   END IF

   IF mr_selecao.todos_documentos = 'N' THEN
      SELECT COUNT(*)
        INTO l_count
        FROM cre0270_num_docum
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa

      IF l_count > 0 THEN
         LET sql_stmt  = sql_stmt CLIPPED, ", cre0270_num_docum"
         LET sql_where = sql_where CLIPPED,
                         " AND cre0270_num_docum.nom_usuario = '",p_user,"'",
                         " AND cre0270_num_docum.cod_programa = '",p_cod_programa,"'",
                         " AND cre0270_num_docum.cod_empresa = docum.cod_empresa",
                         " AND cre0270_num_docum.num_docum = docum.num_docum",
                         " AND cre0270_num_docum.ies_tip_docum = docum.ies_tip_docum"
      END IF
   END IF

   IF mr_selecao.todos_portadores = 'N' THEN
      SELECT COUNT(*) INTO l_count
        FROM cre0270_portador
       WHERE nom_usuario = p_user
         AND cod_programa = p_cod_programa
      IF l_count > 0 THEN
         LET sql_stmt = sql_stmt CLIPPED, ", cre0270_portador"
         LET sql_where = sql_where CLIPPED,
             " AND cre0270_portador.nom_usuario = '",p_user,"'",
             " AND cre0270_portador.cod_programa = '",p_cod_programa,"'",
             " AND cre0270_portador.cod_portador = docum.cod_portador"
      END IF
   END IF

   LET sql_stmt = sql_stmt CLIPPED, sql_where CLIPPED

   PREPARE var_query_9300 FROM sql_stmt
   DECLARE cq_cre9300 CURSOR FOR var_query_9300

   FOREACH cq_cre9300 INTO lr_cre9300.empresa,
                           lr_cre9300.docum,
                           lr_cre9300.tip_docum,
                           lr_cre9300.portador
      LET l_achou = TRUE

      #--inicio--OS 719260 Jefe #
      #Potador parametrizado para não emitir boleto.Ver cre0340.
      IF NOT pol1377_verifica_emite_boleto(lr_cre9300.portador, 'B') THEN
         CONTINUE FOREACH
      END IF
      #---fim----OS 719260  #

      SELECT *
        FROM docum_banco
       WHERE cod_empresa   = lr_cre9300.empresa
         AND num_docum     = lr_cre9300.docum
         AND ies_tip_docum = lr_cre9300.tip_docum
         AND cod_portador  = lr_cre9300.portador

      IF sqlca.sqlcode = 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF lr_cre9300.portador = l_portador_ant THEN                                                                      
         LET lr_cre9300.num_titulo_banco  = NULL                                                                         
         LET lr_cre9300.dat_confirm_banco = NULL                                                                         
         LET lr_cre9300.emissao_boleto    = 'C'                                                                          
                                                                                                                      
         WHENEVER ERROR CONTINUE                                                                                         
            INSERT INTO docum_banco VALUES(lr_cre9300.*)                                                                 
         WHENEVER ERROR STOP                                                                                             
                                                                                                                      
         IF sqlca.sqlcode <> 0 THEN                                                                                      
            CALL log003_err_sql('INCLUSÃO','DOCUM_BANCO')                                                                
         END IF                                                                                                          
      ELSE                                                                                                               
         INITIALIZE l_agencia,                                                                                           
                    l_agencia_aux TO NULL                                                                                
         LET l_portador_ant = lr_cre9300.portador                                                                        
                                                                                                                      
         SELECT num_agencia                                                                                              
           INTO l_agencia                                                                                                
           FROM portador_banco                                                                                           
          WHERE cod_empresa   = lr_cre9300.empresa                                                                       
            AND cod_portador  = lr_cre9300.portador                                                                      
            AND ies_tip_docum = lr_cre9300.tip_docum                                                                     
                                                                                                                      
         IF sqlca.sqlcode = 0 THEN                                                                                       
            FOR i = 1 TO 6                                                                                               
               IF l_agencia[i] = '-' THEN                                                                                
                  EXIT FOR                                                                                               
               ELSE                                                                                                      
                  LET l_agencia_aux = l_agencia_aux CLIPPED, l_agencia[i]                                                
               END IF                                                                                                    
            END FOR                                                                                                      
                                                                                                                      
            LET lr_cre9300.agencia = l_agencia_aux[1,4]                                                                  
                                                                                                                      
            ## ACHA DIGITO ##                                                                                            
            FOR i= 1 TO 6                                                                                                
               LET lr_cre9300.dig_agencia = l_agencia[i]                                                                 
               IF lr_cre9300.dig_agencia = '-' THEN                                                                      
                  LET lr_cre9300.dig_agencia = l_agencia[i + 1]                                                          
                  IF lr_cre9300.dig_agencia = ' ' THEN                                                                   
                     LET lr_cre9300.dig_agencia = l_agencia[i + 2]                                                       
                  END IF                                                                                                 
                  EXIT FOR                                                                                               
               END IF                                                                                                    
            END FOR                                                                                                      
            LET lr_cre9300.num_titulo_banco  = NULL                                                                      
            LET lr_cre9300.dat_confirm_banco = NULL                                                                      
            LET lr_cre9300.emissao_boleto    = 'C'                                                                       
                                                                                                                      
            WHENEVER ERROR CONTINUE                                                                                      
               INSERT INTO docum_banco VALUES (lr_cre9300.*)                                                             
            WHENEVER ERROR STOP                                                                                          
                                                                                                                      
            IF sqlca.sqlcode <> 0 THEN                                                                                   
               CALL log003_err_sql('INCLUSÃO','DOCUM_BANCO')                                                             
            END IF                                                                                                       
         ELSE                                                                                                            
            ERROR "Conta/Agência não cadastradas para o portador ", lr_cre9300.portador USING '<<<<', '.'                
            LET l_achou = FALSE                                                                                          
            EXIT FOREACH                                                                                                 
         END IF                                                                                                          
      END IF                                                                                                                   
      
   END FOREACH

   IF l_achou = 1 THEN
      CALL log0030_mensagem(" Documentos prontos para impressão de Bloquetos. ","info")
   ELSE
      IF l_achou = 0 THEN
      ELSE
         CALL log0030_mensagem(" Não existem documentos a serem atualizados para impressão. ","info")
      END IF
   END IF

 END FUNCTION

#####################
## OS 285293 - Fim ##
#####################

#-----------------------------------#
 FUNCTION pol1377_informa_impressao()
#-----------------------------------#
   DEFINE l_cont   SMALLINT,
          l_ind    SMALLINT,
          l_status smallint

   CALL log006_exibe_teclas("01",p_versao)
   LET comando = log130_procura_caminho("pol1377")

   OPEN WINDOW w_pol1377 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER,MESSAGE LINE LAST,PROMPT LINE LAST)

   LET m_total_ordena = 0

   IF pol1377_sist_gerad_ordena_impressao() = FALSE THEN
      RETURN
   END IF

   DELETE FROM cre0270_empresa
         WHERE nom_usuario = p_user
           AND cod_programa = p_cod_programa

   DELETE FROM cre0270_tip_doc
         WHERE nom_usuario = p_user
           AND cod_programa = p_cod_programa

   DELETE FROM cre0270_num_docum
         WHERE nom_usuario = p_user
           AND cod_programa = p_cod_programa

   IF mr_selecao.todos_portadores = 'N' THEN
      CALL pol1377_carrega_portadores()
   END IF

   INITIALIZE mr_tela1.* TO NULL
   DISPLAY BY NAME mr_tela1.*

   INPUT BY NAME mr_tela1.* WITHOUT DEFAULTS
      BEFORE FIELD empresa
         LET mr_tela1.empresa = p_cod_empresa
         DISPLAY BY NAME mr_tela1.empresa

      AFTER FIELD empresa
         IF mr_tela1.empresa IS NOT NULL THEN
            IF pol1377_verifica_empresa(mr_tela1.empresa) = FALSE THEN
               ERROR "Empresa não cadastrada."
               NEXT FIELD empresa
            END IF
         END IF

      BEFORE FIELD portador
         LET l_ind = l_ind + 1
         LET mr_tela1.portador = m_portador2.cod_portador
         LET mr_tela1.tip_portador = m_portador2.ies_tip_portador

      AFTER FIELD portador
         IF FGL_LASTKEY() = fgl_keyval("UP") THEN
            NEXT FIELD docum_ini
         END IF

      AFTER FIELD tip_portador
         
         IF FGL_LASTKEY() = fgl_keyval("UP") THEN
            NEXT FIELD portador
         END IF
         
         IF mr_tela1.portador IS NOT NULL THEN
            IF mr_tela1.tip_portador NOT MATCHES '[BCRE]' THEN
               ERROR "Informe o portador para Emissão do Boleto."
               NEXT FIELD portador
            ELSE
               CALL pol1377_verifica_portador(mr_tela1.empresa, mr_tela1.portador, mr_tela1.tip_portador)
               RETURNING l_status
               
               IF NOT l_status THEN
                  ERROR "Portador não cadastrado"
                  NEXT FIELD portador
               END IF
               
               LET mr_tela1.nom_abr_portador = m_nom_abr_portador

               IF mr_tela1.nom_abr_portador IS NULL THEN
                  ERROR "Portador não cadastrado (CRE0340)."
                  NEXT FIELD portador
               END IF

               IF m_portador <> 237 AND m_portador <> 275 AND
                  m_portador <> 356 AND m_portador <> 33  AND
                  m_portador <> 341 AND m_portador <> 453 AND
                  m_portador <> 320 AND m_portador <> 1   AND
                  m_portador <> 001 AND m_portador <> 104 THEN
                  ERROR "Não existe impressão de boleto para o Portador."
                  NEXT FIELD portador
               END IF

               LET l_cont = 0

               SELECT COUNT(*)
                 INTO l_cont
                 FROM par_bloqueto_laser
                WHERE cod_portador = mr_tela1.portador

               IF l_cont = 0 THEN
                  ERROR "Parâmetros para o Portador não cadastrados (VDP2822)."
                  NEXT FIELD portador
               END IF
            END IF
            
            #--inicio--OS 719260 Jefe #
            #Potador parametrizado para não emitir boleto.Ver cre0340.
            
            IF NOT pol1377_verifica_emite_boleto(mr_tela1.portador, mr_tela1.tip_portador) THEN
               CALL LOG0030_mensagem('Portador cadastrado para não emitir Boleto.Ver CRE0340.','exclamation')
               NEXT FIELD portador
            END IF
            
            #---fim----OS 719260  #
            DISPLAY BY NAME mr_tela1.nom_abr_portador
         END IF

      ON KEY (control-z, f4)
         CALL pol1377_popup()
   END INPUT

   IF INT_FLAG = 1 THEN
      LET INT_FLAG = 0
      ERROR "Processamento Cancelado."
      RETURN FALSE
   END IF
   RETURN TRUE
END FUNCTION

#------------------------------------#
 FUNCTION pol1377_carrega_portadores()
#------------------------------------#

 DEFINE l_count        SMALLINT,
        l_ind          SMALLINT

 INITIALIZE l_count      TO NULL

 LET m_tem_dados = FALSE

 WHENEVER ERROR CONTINUE
 SELECT COUNT(*) INTO l_count
   FROM cre0270_portador
  WHERE nom_usuario = p_user
    AND cod_programa = p_cod_programa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET l_count = NULL
 END IF

 LET l_ind = 1
 IF l_count = 1 THEN
    LET m_tem_dados = TRUE
    DECLARE cq_portador CURSOR FOR
    SELECT cod_portador, ies_tip_portador
      FROM cre0270_portador
     WHERE nom_usuario = p_user
       AND cod_programa = p_cod_programa
    OPEN  cq_portador
    FETCH cq_portador INTO m_portador2.cod_portador, m_portador2.ies_tip_portador


 END IF

 END FUNCTION

#-------------------------------------#
 FUNCTION pol1377_informa_reimpressao()
#-------------------------------------#
   DEFINE l_portador     LIKE portador.cod_portador,
          l_tip_portador LIKE portador.ies_tip_portador,
          l_cont         SMALLINT,
          l_status       smallint

   INITIALIZE mr_tela2.* TO NULL

   CALL log130_procura_caminho("pol13771") RETURNING comando
   LET comando = log130_procura_caminho("pol13771")

   OPEN WINDOW w_pol13771 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY mr_tela2.*

   CALL pol1377_cria_temp()

   INPUT BY NAME mr_tela2.* WITHOUT DEFAULTS
      BEFORE FIELD empresa
         IF mr_par_cre_txt.parametro[217,217] ="S" THEN
            LET mr_tela2.empresa = p_cod_empresa
            DISPLAY BY NAME mr_tela2.empresa
            NEXT FIELD ies_num_docum
         END IF

      AFTER FIELD empresa
         IF mr_tela2.empresa IS NOT NULL THEN
            IF pol1377_verifica_empresa(mr_tela2.empresa) = FALSE THEN
               ERROR "Empresa não cadastrada."
               NEXT FIELD empresa
            END IF
         END IF

      BEFORE FIELD ies_num_docum
         IF mr_tela2.ies_num_docum IS NULL THEN
            LET mr_tela2.ies_num_docum = "N"
            DISPLAY BY NAME mr_tela2.ies_num_docum
         END IF

      AFTER FIELD ies_num_docum
         IF mr_tela2.ies_num_docum = "N" THEN
            IF pol1377_popup_docum() = FALSE THEN
               CALL log006_exibe_teclas("01",p_versao)
               CURRENT WINDOW IS w_pol13771
               LET mr_tela2.ies_num_docum = 'S'
               DISPLAY BY NAME mr_tela2.ies_num_docum
            ELSE
               CALL log006_exibe_teclas("01",p_versao)
               CURRENT WINDOW IS w_pol13771
               LET mr_tela2.documento_de  = NULL
               LET mr_tela2.documento_ate = NULL

            END IF
         END IF

         IF mr_tela2.ies_num_docum IS NULL THEN
            LET mr_tela2.ies_num_docum = "S"
            DISPLAY BY NAME mr_tela2.ies_num_docum
         END IF

         IF mr_tela2.ies_num_docum = 'N' THEN
            EXIT INPUT
         END IF

      BEFORE FIELD documento_de
          IF mr_tela2.ies_num_docum = "N" THEN
             NEXT FIELD portador
          END IF

      AFTER FIELD documento_de
         IF  mr_tela2.documento_de  IS NOT NULL
         AND mr_tela2.documento_ate IS NOT NULL THEN
            IF mr_tela2.documento_de > mr_tela2.documento_ate THEN
               CALL log0030_mensagem("Documento inicial deve ser maior que o documento final.","Info")
               NEXT FIELD documento_de
            END IF
         END IF

      AFTER FIELD documento_ate
         IF  mr_tela2.documento_de  IS NOT NULL
         AND mr_tela2.documento_ate IS NOT NULL THEN
            IF mr_tela2.documento_ate < mr_tela2.documento_de THEN
               CALL log0030_mensagem("Documento final deve ser maior que o documento inicial.","Info")
               NEXT FIELD documento_ate
            END IF
         END IF

      BEFORE FIELD portador
         IF mr_tela2.ies_num_docum = "N" THEN
            NEXT FIELD carta_de
         END IF

      AFTER FIELD portador
         IF FGL_LASTKEY() = fgl_keyval("UP") THEN
            NEXT FIELD ies_num_docum
         END IF

         IF mr_tela2.portador IS NULL THEN
            NEXT FIELD carta_de
         END IF

         DISPLAY BY NAME mr_tela2.nom_abr_portador

      AFTER FIELD tip_portador
         IF FGL_LASTKEY() = fgl_keyval("UP") THEN
            NEXT FIELD portador
         END IF
         IF m_tem_dados = FALSE THEN
            IF mr_tela2.tip_portador NOT MATCHES '[BCRE]' THEN
               ERROR "Informe o portador para Emissão do Boleto."
               NEXT FIELD portador
            ELSE

               CALL pol1377_verifica_portador(mr_tela2.empresa, mr_tela2.portador,mr_tela2.tip_portador)
               RETURNING l_status
               IF NOT l_status THEN
                  LET INT_FLAG = 1
                  EXIT INPUT
               END IF

               LET mr_tela2.nom_abr_portador = m_nom_abr_portador
               IF mr_tela2.nom_abr_portador IS NULL THEN
                  ERROR "Portador não cadastrado (CRE0340)."
                  NEXT FIELD portador
               END IF

               IF m_portador <> 237 AND m_portador <> 275 AND
                  m_portador <> 356 AND m_portador <> 33  AND
                  m_portador <> 341 AND m_portador <> 453 AND
                  m_portador <> 320 AND m_portador <> 1   AND
                  m_portador <> 001 AND m_portador <> 104 THEN
                  ERROR "Não existe impressão de boleto para o Portador."
                  NEXT FIELD portador
               END IF

              ###controle para portador representante e portador correpondente
              LET l_cont = 0

               SELECT COUNT(*)
                 INTO l_cont
                 FROM par_bloqueto_laser
                WHERE cod_portador = mr_tela2.portador

               IF l_cont = 0 THEN
                  ERROR "Parâmetros para o Portador não cadastrados (VDP2822)."
                  NEXT FIELD portador
               END IF
            END IF
         END IF
         DISPLAY BY NAME mr_tela2.nom_abr_portador

      # O.S 719260
      AFTER FIELD carta_de
         IF FGL_LASTKEY() = fgl_keyval("UP")
         OR FGL_LASTKEY() = fgl_keyval("LEFT")  THEN
            NEXT FIELD portador
         END IF

      AFTER FIELD carta_ate
         IF mr_tela2.carta_ate IS NOT NULL THEN
            IF mr_tela2.carta_de IS NOT NULL THEN
               IF mr_tela2.carta_ate < mr_tela2.carta_de THEN
                  CALL LOG0030_mensagem('O número da Carta De não pode ser maior que o número da Carta até.','exclamation')
                  NEXT FIELD carta_de
               END IF
            ELSE
               CALL LOG0030_mensagem('Faixa de valor não informada.','exclamation')
               NEXT FIELD carta_de
            END IF
         ELSE
            IF mr_tela2.carta_de IS NOT NULL THEN
               CALL LOG0030_mensagem('Faixa de valor não informada.','exclamation')
               NEXT FIELD carta_de
            ELSE
               EXIT INPUT
            END IF
         END IF


      AFTER FIELD mes_competencia
         IF mr_tela2.mes_competencia IS NULL THEN
            CALL LOG0030_mensagem('Informe a competência.','exclamation')
            NEXT FIELD mes_competencia
         ELSE
            IF NOT pol1377_trata_mes_competencia() THEN
               CALL LOG0030_mensagem('Mês de competência inválido.','exclamation')
               NEXT FIELD mes_competencia
            END IF
         END IF

      AFTER FIELD ano_competencia
         IF mr_tela2.ano_competencia IS NULL THEN
            CALL LOG0030_mensagem('Informe a competencia.','exclamation')
            NEXT FIELD ano_competencia
         END IF
         LET mr_tela2.ano_competencia = mr_tela2.ano_competencia USING '&&&&'
         DISPLAY BY NAME mr_tela2.ano_competencia
         IF mr_tela2.ano_competencia[1] < 1 OR mr_tela2.ano_competencia[1] > 9 THEN
            CALL log0030_mensagem("Ano de competência inválido.","exclamation")
            NEXT FIELD ano_competencia
         END IF

      ON KEY (control-z, f4)
         CASE
            WHEN INFIELD(portador)
               CALL cre305_popup_portador()
                  RETURNING l_portador, l_tip_portador

               CURRENT WINDOW IS w_pol13771

               IF l_portador IS NOT NULL THEN
                  LET mr_tela2.portador = l_portador
                  LET mr_tela2.tip_portador = l_tip_portador

                  DISPLAY BY NAME mr_tela2.portador
                  DISPLAY BY NAME mr_tela2.tip_portador
                  DISPLAY BY NAME mr_tela2.nom_abr_portador
               END IF

            WHEN INFIELD(tip_portador)
               LET mr_tela2.tip_portador = log0830_list_box(18, 44, 'B {Banco}, C {Carteira}, R {Representante}, E {Escritório Cobrança}')
               DISPLAY BY NAME mr_tela2.tip_portador
         END CASE
   END INPUT

   IF INT_FLAG = 1 THEN
      LET INT_FLAG = 0
      ERROR "Processamento Cancelado."
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION

#-------------------------------------------#
 FUNCTION pol1377_verifica_empresa(l_empresa)
#-------------------------------------------#
   DEFINE l_empresa  LIKE empresa.cod_empresa

   SELECT *
     FROM empresa
    WHERE cod_empresa = l_empresa

   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF
   RETURN TRUE
END FUNCTION

#----------------------------------------------------------------------------#
 FUNCTION pol1377_verifica_portador(l_cod_empresa, l_portador, l_tip_portador)
#----------------------------------------------------------------------------#

 DEFINE l_cod_empresa       CHAR(02),
        l_portador          DECIMAL(4,0),
        l_tip_portador      CHAR(01),
        l_portador_repres   CHAR(04),
        l_portador_corresp  CHAR(04),
        l_msg               CHAR(100),
        l_par_bloq_txt      CHAR(200)

 INITIALIZE m_nom_abr_portador TO NULL

 WHENEVER ERROR CONTINUE
   SELECT nom_abr_portador
     INTO m_nom_abr_portador
     FROM portador
    WHERE cod_portador     = l_portador
      AND ies_tip_portador = l_tip_portador
 WHENEVER ERROR STOP
 
 IF SQLCA.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECT','portador')
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
   SELECT par_bloq_txt
     INTO l_par_bloq_txt
     FROM par_bloqueto_laser
    WHERE cod_empresa  = l_cod_empresa
      AND cod_portador = l_portador
 WHENEVER ERROR STOP
 
 IF SQLCA.sqlcode = 0 THEN
    LET l_portador_repres = l_par_bloq_txt[147,150]

    IF l_portador_repres IS NULL   OR
       l_portador_repres = '     ' THEN
       #portador corresponde como esta fazendo agora
       WHENEVER ERROR CONTINUE
         SELECT cod_port_corresp
           INTO m_portador
           FROM port_corresp
          WHERE cod_portador = l_portador
       WHENEVER ERROR STOP
       IF SQLCA.sqlcode <> 0 THEN
          LET m_portador         = l_portador
          LET l_portador_corresp = l_portador
       END IF
    ELSE
       WHENEVER ERROR CONTINUE
        SELECT  cod_portador
         FROM portador
        WHERE cod_portador = l_portador_repres
          AND ies_tip_portador = 'B'
       WHENEVER ERROR STOP
       IF SQLCA.sqlcode <> 0 THEN
          LET l_msg = 'Portador representante: 'CLIPPED,l_portador_repres,' não cadastrado.' CLIPPED
          CALL log0030_mensagem(l_msg,'excl')
          RETURN FALSE
       ELSE
          # validar l_portador_represen dentro dos 5 tipos se positivo verificar correspon caso contrario
          # return false, portador represent não é valido para o partador documento
           WHENEVER ERROR CONTINUE
             SELECT cod_port_corresp
               INTO l_portador_corresp
               FROM port_corresp
              WHERE cod_portador = l_portador_repres
           WHENEVER ERROR STOP
          IF SQLCA.sqlcode <> 0 THEN
             LET l_portador_corresp = l_portador_repres
          END IF
       END IF
    END IF
 END IF

 IF l_portador_corresp <> 237 AND
    l_portador_corresp <> 275 AND
    l_portador_corresp <> 356 AND
    l_portador_corresp <> 33  AND
    l_portador_corresp <> 341 AND
    l_portador_corresp <> 453 AND
    l_portador_corresp <> 320 AND
    l_portador_corresp <> 1   AND
    l_portador_corresp <> 001 AND
    l_portador_corresp <> 104 THEN
    IF l_portador_repres IS NOT NULL OR
       l_portador_repres <> '  '   THEN
       LET l_msg = 'Não existe impressão de boleto para o portador representante: ',l_portador_repres CLIPPED
       IF l_portador_corresp IS NOT NULL          AND
          l_portador_corresp <> l_portador_repres THEN
          LET l_msg = l_msg CLIPPED, ' com portador correspondente: ', l_portador_corresp CLIPPED
       END IF
       LET l_msg = l_msg CLIPPED, '.'
    ELSE
       LET l_msg = 'Não existe impressão de boleto para o portador: ',l_portador CLIPPED
       IF l_portador_corresp IS NOT NULL   AND
          l_portador_corresp <> l_portador THEN
          LET l_msg = l_msg CLIPPED, ' com portador correspondente: ', l_portador_corresp CLIPPED
       END IF
       LET l_msg = l_msg CLIPPED, '.'
    END IF
    CALL log0030_mensagem(l_msg,'excl')
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#---------------------------------------------------#
 FUNCTION pol1377_verifica_desconto_base()
#---------------------------------------------------#

 DEFINE l_nat_oper         LIKE cre_compl_docum.natureza_operacao,
        l_pct_desc_bc_iss  LIKE obf_config_fiscal.pct_red_bas_calc

 WHENEVER ERROR CONTINUE
    SELECT natureza_operacao
      INTO l_nat_oper
      FROM ctr_titulo_mestre
     WHERE empresa    = mr_docum.cod_empresa #497350 p_cod_empresa
        AND titulo     = mr_relat.num_docum
        AND tip_titulo = mr_docum.ies_tip_docum
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('LEITURA','ctr_titulo_mestre')
    RETURN FALSE
 ELSE

#    WHENEVER ERROR CONTINUE
#    SELECT pct_desc_bc_iss
#      INTO l_pct_desc_bc_iss
#      FROM vdp_serv_par_compl
#     WHERE empresa           = mr_docum.cod_empresa #497350 p_cod_empresa
#       AND natureza_operacao = l_nat_oper
#    WHENEVER ERROR STOP

    WHENEVER ERROR CONTINUE
    SELECT pct_red_bas_calc
      INTO l_pct_desc_bc_iss
      FROM obf_config_fiscal
     WHERE empresa = mr_docum.cod_empresa
       AND nat_oper_grp_desp = l_nat_oper
       AND tributo_benef = 'IRRF_RET'
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       IF sqlca.sqlcode = 100 THEN
          WHENEVER ERROR CONTINUE
          SELECT pct_red_bas_calc
            INTO l_pct_desc_bc_iss
            FROM obf_config_fiscal
           WHERE empresa = mr_docum.cod_empresa
             AND tributo_benef = 'IRRF_RET'
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode = 100 THEN
             CALL log003_err_sql('LEITURA','obf_config_fiscal')
             RETURN FALSE
          END IF
       ELSE
          CALL log003_err_sql('LEITURA','obf_config_fiscal')
          RETURN FALSE
       END IF
    END IF

    IF l_pct_desc_bc_iss IS NULL THEN
       LET l_pct_desc_bc_iss = 0
    END IF

    LET m_pct_desconto_base = 100 - l_pct_desc_bc_iss

    RETURN TRUE

 END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol1377_acha_par_bloqueto() #frank aqui carrega os valores da função para representante
#------------------------------------#
  DEFINE l_portador_repres  CHAR(05),
         l_par_bloq_txt     CHAR(200),
         l_msg              CHAR(100),
         l_existe           SMALLINT

  INITIALIZE mr_par_bloq_laser.* TO NULL

########inicio função controle para portador representante
  WHENEVER ERROR CONTINUE
    SELECT par_bloq_txt
      INTO l_par_bloq_txt
      FROM par_bloqueto_laser
     WHERE cod_empresa  = mr_docum.cod_empresa
       AND cod_portador = mr_docum.cod_portador
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
  END IF

  LET l_existe = TRUE
  LET l_portador_repres = l_par_bloq_txt[147,150]

  IF l_portador_repres IS NULL OR l_portador_repres = '     ' THEN
     LET l_existe = FALSE
  ELSE
     WHENEVER ERROR CONTINUE
       SELECT nom_portador
         FROM portador
        WHERE cod_portador = l_portador_repres
          AND ies_tip_portador = 'B'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        LET l_existe = FALSE
        LET l_msg = 'Portador representante : 'CLIPPED,l_portador_repres,' não cadastrado ' CLIPPED,
                    ' na tabela de portadores.'
        CALL log0030_mensagem(l_msg,'excl')
     END IF
  END IF
#############fim do controle para portador representante

  WHENEVER ERROR CONTINUE
    SELECT par_bloqueto_laser.*
      INTO mr_par_bloq_laser.*
      FROM par_bloqueto_laser
     WHERE cod_empresa  = mr_docum.cod_empresa
       AND cod_portador = mr_docum.cod_portador
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","PAR_BLOQUETO_LASER")
     END IF
     RETURN FALSE
  END IF

  IF l_existe THEN
     LET m_controle_portador = l_portador_repres

     IF NOT pol1377_valida_portador_representante() THEN
        RETURN FALSE
     END IF

     WHENEVER ERROR CONTINUE
       SELECT num_agencia,
              num_conta,
              dig_portador,
              num_ult_bloqueto,
              cod_cedente,
              par_bloq_txt
         INTO mr_par_bloq_laser.num_agencia,
              mr_par_bloq_laser.num_conta,
              mr_par_bloq_laser.dig_portador,
              mr_par_bloq_laser.num_ult_bloqueto,
              mr_par_bloq_laser.cod_cedente,
              l_par_bloq_txt
         FROM par_bloqueto_laser
        WHERE cod_empresa  = mr_docum.cod_empresa
          AND cod_portador = m_controle_portador
     WHENEVER ERROR STOP
      IF sqlca.sqlcode = 0 THEN
         IF m_controle_portador = 237 THEN
            LET mr_par_bloq_laser.par_bloq_txt[20,21] = l_par_bloq_txt[20,21]
         ELSE
            LET mr_par_bloq_laser.par_bloq_txt[20,25] = l_par_bloq_txt[20,25]
         END IF

         LET mr_par_bloq_laser.par_bloq_txt[32,32] = l_par_bloq_txt[32,32] #Cod_aceite
         LET mr_par_bloq_laser.par_bloq_txt[11,19] = l_par_bloq_txt[11,19] #Uso do Banco
         LET mr_par_bloq_laser.par_bloq_txt[26,31] = l_par_bloq_txt[26,31] #esp_docum (Especie Documento)

      ELSE
         LET l_msg = 'Parametros não cadastrados para portador representante :'CLIPPED , l_portador_repres
         CALL log0030_mensagem(l_msg,'excl')
         RETURN FALSE
      END IF
  END IF

  WHENEVER ERROR CONTINUE
  SELECT parametro_texto
    INTO mr_demonst.cod_cip
    FROM vdp_par_blqt_compl
   WHERE empresa  = mr_docum.cod_empresa
     AND portador = mr_docum.cod_portador
     AND campo    = 'codigo_cip'
  WHENEVER ERROR STOP

  IF sqlca.sqlcode <> 0 THEN
     LET mr_demonst.cod_cip = NULL
  END IF

  RETURN TRUE

END FUNCTION

#------------------------------------------------#
 FUNCTION pol1377_valida_portador_representante()
#------------------------------------------------#
  DEFINE l_portador_corres          CHAR(04)

  WHENEVER ERROR CONTINUE
   SELECT cod_port_corresp
     INTO l_portador_corres
     FROM port_corresp
    WHERE cod_portador = m_controle_portador
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_portador_corres = m_controle_portador
     IF l_portador_corres <> 237
         AND l_portador_corres <> 275
         AND l_portador_corres <> 356
         AND l_portador_corres <> 33
         AND l_portador_corres <> 341
         AND l_portador_corres <> 453
         AND l_portador_corres <> 104
         AND l_portador_corres <> 320
         AND l_portador_corres <> 1
         AND l_portador_corres <> 001 THEN
         CALL log0030_mensagem("Portador representante não cadastrado e/ou sem portador correspondente.",'excl')
         RETURN FALSE
     END IF
  ELSE
     #LET m_controle_portador = l_portador_corres
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------#
 FUNCTION pol1377_popup()
#---------------------------#
   DEFINE l_portador     LIKE portador.cod_portador,
          l_tip_portador LIKE portador.ies_tip_portador

   CASE
      WHEN INFIELD(portador)
         CALL cre305_popup_portador()
            RETURNING l_portador, l_tip_portador

         CURRENT WINDOW IS w_pol1377

         IF l_portador IS NOT NULL THEN
            LET mr_tela1.portador = l_portador
            LET mr_tela1.tip_portador = l_tip_portador

            DISPLAY BY NAME mr_tela1.portador
            DISPLAY BY NAME mr_tela1.tip_portador
            DISPLAY BY NAME mr_tela1.nom_abr_portador
         END IF

      WHEN INFIELD(tip_portador)
         LET mr_tela1.tip_portador = log0830_list_box(18, 44, 'B {Banco}, C {Carteira}, R {Representante}, E {Escritório Cobrança}')
         DISPLAY BY NAME mr_tela1.tip_portador
   END CASE
END FUNCTION

#------------------------------------#
 FUNCTION pol1377_processa_impressao()
#------------------------------------#

 DEFINE l_cont                      SMALLINT                            ,
        l_laser                     SMALLINT                            ,
        l_selecao                   SMALLINT                            ,
        l_meio_envio_anterior       LIKE cre_compl_docum.meio_envio     ,
        l_roteiro_anterior          LIKE cre_compl_docum.roteiro        ,
        l_filial_cobranca_anterior  LIKE cre_compl_docum.filial_cobranca,
        l_port_atual_bloq           LIKE docum.cod_portador

 DEFINE l_portador_repres   CHAR(04),
        l_portador          LIKE docum.cod_portador,
        l_par_bloq_txt      CHAR(200)

 DEFINE l_sql_stmt            CHAR(7000),
        l_sql_impres          CHAR(7000) #eduardo

 DEFINE l_cnpj_cli_agrupado   LIKE cre_itcompl_docum.cnpj_cli_agrupado
 DEFINE l_verifica_cnpj_igual SMALLINT
 DEFINE lr_cre_itcompl_docum  RECORD LIKE cre_itcompl_docum.*

 DEFINE l_cod_cliente     LIKE docum.cod_cliente
 DEFINE l_nom_cliente     LIKE clientes.nom_cliente
 DEFINE l_nom_cliente_aux LIKE clientes.nom_cliente

 DEFINE l_num_seq         SMALLINT, #eduardo
        l_ind             SMALLINT

 LET m_houve_erro               = FALSE
 LET l_laser                    = TRUE
 LET m_emitiu                   = FALSE
 LET m_qtd_pag_demonst          = 0
 LET m_qtd_pag_demonst_pdf      = 0
 LET l_meio_envio_anterior      = '@@'
 LET l_roteiro_anterior         = '@@'
 LET l_filial_cobranca_anterior = '@@'
 LET m_deletou_arquivo_atual    = FALSE
 LET m_ind_p_bloqueto           = 1
 LET m_dat_competencia_ant      = 0
 LET m_num_lote                 = 1

 #UTILIZADO PARA SEQUENCIA INFORMAÇÃO CARTA
 LET m_meio_envio_anterior      = '@@'
 LET m_roteiro_anterior         = '@@'
 LET m_filial_cobranca_anterior = '@@'
 #-----

 LET m_seq_rot_especifico = 0
 LET m_tem_cartas         = FALSE

 CALL log2250_busca_parametro(p_cod_empresa,"roteiro")
 RETURNING m_roteiro_especifico, p_status

 IF NOT pol1377_cria_temp_processamento() THEN
    ERROR "Processamento cancelado."
    RETURN
 END IF

 IF NOT pol1377_carrega_textos_retencao() THEN
    ERROR "Processamento cancelado."
    RETURN
 END IF

 #alterado em 04/07/2012 por Eduardo Luis Nogueira
 #a partir desta data estará jogando os valores encontrados na tabela t_impressao
 #para depois ordenar conforme solicitado pelo cliente na impressao
 #ao migrar o programa da versão 0510 para 1002 não estava realizando a mesma ordenação

 LET l_sql_stmt  = " INSERT INTO t_impressao        ",
                   " SELECT d.cod_empresa         , ",      {2}
                          " d.num_docum           , ",      {3}
                          " d.ies_tip_docum       , ",      {4}
                          " d.dat_emis            , ",      {5}
                          " d.dat_vencto_c_desc   , ",      {6}
                          " d.pct_desc            , ",      {7}
                          " d.dat_vencto_s_desc   , ",      {8}
                          " d.dat_prorrogada      , ",      {9}
                          " d.ies_cobr_juros      , ",      {10}
                          " d.cod_cliente         , ",      {11}
                          " d.cod_repres_1        , ",      {12}
                          " d.cod_repres_2        , ",      {13}
                          " d.cod_repres_3        , ",      {14}
                          " d.val_liquido         , ",      {15}
                          " d.val_bruto           , ",      {16}
                          " d.val_saldo           , ",      {17}
                          " d.val_fat             , ",      {18}
                          " d.val_desc_dia        , ",      {19}
                          " d.val_desp_financ     , ",      {20}
                          " d.ies_tip_cobr        , ",      {21}
                          " d.pct_juro_mora       , ",      {22}
                          " d.cod_portador        , ",      {23}
                          " d.ies_tip_portador    , ",      {24}
                          " d.ies_cnd_bordero     , ",      {25}
                          " d.ies_situa_docum     , ",      {26}
                          " d.dat_alter_situa     , ",      {27}
                          " d.ies_pgto_docum      , ",      {28}
                          " d.ies_pendencia       , ",      {29}
                          " d.ies_bloq_justific   , ",      {30}
                          " d.num_pedido          , ",      {31}
                          " d.num_docum_origem    , ",      {32}
                          " d.ies_tip_docum_orig  , ",      {33}
                          " d.ies_serie_fat       , ",      {34}
                          " d.cod_local_fat       , ",      {35}
                          " d.cod_tip_comis       , ",      {36}
                          " d.pct_comis_1         , ",      {37}
                          " d.pct_comis_2         , ",      {38}
                          " d.pct_comis_3         , ",      {39}
                          " d.val_desc_comis      , ",      {40}
                          " d.dat_competencia     , ",      {41}
                          " d.ies_tip_emis_docum  , ",      {42}
                          " d.dat_emis_docum      , ",      {43}
                          " d.num_lote_remessa    , ",      {44}
                          " d.dat_gravacao        , ",      {45}
                          " d.cod_cnd_pgto        , ",      {46}
                          " d.cod_deb_cred_cl     , ",      {47}
                          " d.ies_docum_suspenso  , ",      {48}
                          " d.ies_tip_port_defin  , ",      {49}
                          " d.ies_ctr_endosso     , ",      {50}
                          " d.cod_mercado         , ",      {51}
                          " d.num_lote_lanc_cont  , ",      {52}
                          " d.dat_atualiz         , ",      {53}
                          " o.empresa             , ",      {54}
                          " o.titulo              , ",      {55}
                          " o.tip_titulo          , ",      {56}
                          " o.sistema_gerador     , ",      {57}
                          " 0                     , ",      {58}
                          " 0                     , ",      {59}
                          " 0                     , ",      {60}
                          " 0                     , ",      {61}
                          " o.val_credito         , ",      {62}
                          " o.val_debito          , ",      {63}
                          " o.val_acumulado       , ",      {64}
                          " 0                     , ",      {65}
                          " 0                     , ",      {66}
                          " 0                     , ",      {67}
                          " ' '                 , ",        {68}
                          " ' '                 , ",        {69}
                          " c.endereco_cobranca , ",        {70}
                          " c.compl_endereco    , ",        {71}
                          " c.bairro_cobranca   , ",        {72}
                          " c.cidade_cobranca   , ",        {73}
                          " c.estado_cobranca   , ",        {74}
                          " c.cep_cobranca      , ",        {75}
                          " ' '                 , ",        {76}
                          " 1                   , ",        {77}
                          " o.filial_cobranca   , ",        {78}
                          " o.filial_admin      , ",        {79}
                          " o.tip_nota_fiscal   , ",        {80}
                          " o.tip_cli_contrato  , ",        {81}
                          " 0                   , ",        {82}
                          " o.natureza_operacao , ",        {83}
                          " o.cond_pagamento    , ",        {84}
                          " c.endereco_cobranca , ",        {85}
                          " c.compl_endereco    , ",        {86}
                          " c.bairro_cobranca   , ",        {87}
                          " c.cidade_cobranca   , ",        {88}
                          " c.estado_cobranca   , ",        {89}
                          " c.cep_cobranca      , ",        {90}
                          " ' '                 , ",        {91}
                          " ' '                 , ",        {92}
                          " o.tip_contrato      , ",        {93}
                          " ' '                 , ",        {94}
                          " ' '                 , ",        {95}
                          " o.hierarq_cliente   , ",        {96}
                          " o.gecon_cliente     , ",        {97}
                          " o.hierarq_negocio   , ",        {98}
                          " o.gecon_negocio     , ",        {99}
                          " o.ramo_atividade    , ",        {100}
                          " o.corretor          , ",        {101}
                          " o.contr_agrupado    , ",        {102}
                          " c.emp_item_pminimo  , ",        {103}
                          " c.item_pminimo      , ",        {104}
                          " c.qtde_pminimo      , ",        {105}
                          " c.val_total_pminimo   ",        {106}
                     " FROM docum_banco b, docum d, ctr_titulo_mestre o, ctr_titulo_complementar c "

 IF mr_selecao.todos_portadores <> 'S' THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, ', port_corresp p, cre0270_portador r'
 END IF

 IF g_todos_sistemas = 'N' THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, ', cre_popup_sist_781'
 END IF

 LET l_sql_stmt = l_sql_stmt CLIPPED,
                    " WHERE 1=1 ",
                      " AND (b.num_titulo_banco IS NULL OR b.num_titulo_banco = ' ') ",
                      " AND b.ies_emis_boleto     = 'C' ",
                      " AND b.cod_empresa         = d.cod_empresa ",
                      " AND b.num_docum           = d.num_docum ",
                      " AND b.ies_tip_docum       = d.ies_tip_docum ",
                      " AND o.empresa             = d.cod_empresa ",
                      " AND o.titulo              = d.num_docum ",
                      " AND o.tip_titulo          = d.ies_tip_docum ",
                      " AND d.cod_empresa        <> '1R' ",
                      " AND o.empresa             = c.empresa ",
                      " AND o.titulo              = c.titulo ",
                      " AND o.tip_titulo          = c.tip_titulo "
                      

 IF mr_tela1.empresa IS NOT NULL THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, " AND b.cod_empresa = '",mr_tela1.empresa,"' "
 END IF

 IF mr_tela1.portador IS NOT NULL AND
    mr_tela1.portador > 0 THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, " AND b.cod_portador = ", mr_tela1.portador
 ELSE
    IF mr_selecao.todos_portadores <> 'S' THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                       ' AND p.cod_portador     = b.cod_portador ',
                       ' AND p.cod_port_corresp = r.cod_portador ',
                       ' AND b.cod_portador     = r.cod_portador ',
                       ' AND d.ies_tip_portador = r.ies_tip_portador ',
                       ' AND r.nom_usuario      = "',p_user,'" ',
                       ' AND r.cod_programa     = "',p_cod_programa,'" '
    END IF
 END IF

 IF g_todos_sistemas = 'N' THEN
    SELECT COUNT(*)
      INTO l_cont
      FROM cre_popup_sist_781 #t_sistema # OS 451380
     WHERE cre_popup_sist_781.usuario      = p_user
       AND cre_popup_sist_781.sit_sistema  = 'S'
       AND cre_popup_sist_781.programa     = p_cod_programa


    IF l_cont > 0 THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED,
                       ' AND o.sistema_gerador = cre_popup_sist_781.sistema',
                       ' AND cre_popup_sist_781.usuario      = "',p_user,'"',
                       ' AND cre_popup_sist_781.sit_sistema  = "S"',
                       ' AND cre_popup_sist_781.programa     = "',p_cod_programa,'"'
    END IF
 END IF

 IF  mr_tela1.docum_ini IS NOT NULL THEN
     LET l_sql_stmt = l_sql_stmt CLIPPED, ' AND d.num_docum >= "',mr_tela1.docum_ini,'" '
 END IF

 LET l_sql_stmt = log0810_prepare_sql( l_sql_stmt )

 WHENEVER ERROR CONTINUE
 PREPARE var_query_001 FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    CALL log003_err_sql("PREPARE","var_query_001")
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 EXECUTE var_query_001
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
 ELSE
    CALL log003_err_sql("EXECUTE","var_query_001")
    RETURN
 END IF

 #Alteração realizada por Eduardo Luis Nogueira
 # Foi criada a tabela temporária T_IMPRESSAO para isolar do banco de dados as informações de modo
 #geral que serão utilizadas para impressão dos boletos e carta.
 # Após popular a tabela t_impressao, será selecionado conforme a necessidade de impressão dos itens e os
 #campos serão inclusos numa segunda tabela temporaria T_IMPRESSAO_SEQ que irá obedecer uma sequencia para impressão.
 # É a tabela T_IMPRESSAO_SEQ que gerará os boletos

 SELECT COUNT(*)
   INTO l_cont
  FROM t_impressao

 LET l_num_seq = 0

 FOR l_ind = 1 TO 3

    #inicializa o sql preparado para evitar sujeira na variável
    INITIALIZE l_sql_impres TO NULL

    LET l_sql_impres = " SELECT * ",
                         " FROM t_impressao "

    CASE l_ind
      WHEN 1
          LET l_sql_impres = l_sql_impres CLIPPED,
                             ' WHERE num_docum_origem IS NOT NULL ',
                               ' AND num_docum_origem <> ', log0800_string('0'),
                               ' AND num_docum_origem <> ', log0800_string('000000'),
                               ' AND ies_tip_docum_orig = ', log0800_string('NF')

      WHEN 2
         LET l_sql_impres = l_sql_impres CLIPPED,
                             ' WHERE num_docum_origem IS NOT NULL ',
                               ' AND num_docum_origem <> ', log0800_string('0'),
                               ' AND num_docum_origem <> ', log0800_string('000000'),
                               ' AND ies_tip_docum_orig <> ', log0800_string('NF')
      WHEN 3
         LET l_sql_impres = l_sql_impres CLIPPED,
                             ' WHERE ( num_docum_origem IS NULL ',
                               ' OR num_docum_origem = ', log0800_string('0'),
                               ' OR num_docum_origem = ', log0800_string('000000'), ')'

    END CASE

    IF m_total_ordena = 0 THEN
       LET l_sql_impres = l_sql_impres CLIPPED, " ORDER BY dat_emis, ies_tip_docum, cod_empresa, num_docum" # 5, 4, 2, 3 "
    ELSE
       LET l_sql_impres = l_sql_impres CLIPPED, " ORDER BY meio_envio, filial_cobranca, roteiro, ",
                                                      " ies_tip_docum_orig, cod_empresa, num_docum_origem, num_docum "
    END IF

    WHENEVER ERROR CONTINUE
    PREPARE var_query_002 FROM l_sql_impres
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("PREPARE","VAR_QUERY_002")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
    DECLARE cq_pol1377_001 CURSOR WITH HOLD FOR var_query_002
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("DECLARE","CQ_POL1377_001")
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
    
    FOREACH cq_pol1377_001 INTO mr_docum.*,
                                mr_cre_compl_docum.*
      WHENEVER ERROR STOP
      
       IF sqlca.sqlcode <> 0 THEN
          CALL log003_err_sql("foreach","cq_pol1377_001")
          RETURN
       END IF


       LET l_num_seq = l_num_seq + 1

       WHENEVER ERROR CONTINUE

       SELECT *
         FROM t_impressao_seq
        WHERE cod_empresa    = mr_docum.cod_empresa
          AND num_docum      = mr_docum.num_docum
          AND ies_tip_docum  = mr_docum.ies_tip_docum
       
       IF sqlca.sqlcode = 100 THEN
          INSERT INTO t_impressao_seq VALUES (mr_docum.*,
                                              mr_cre_compl_docum.*,
                                              l_num_seq)
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('INCLUSÃO','t_impressao_seq')
             RETURN
          END IF
       END IF

    END FOREACH


 END FOR


 INITIALIZE l_sql_impres TO NULL

 LET l_sql_impres = " SELECT * ",
                      " FROM t_impressao_seq "
 IF m_total_ordena = 0 THEN
    LET l_sql_impres = l_sql_impres CLIPPED, " ORDER BY dat_emis, ies_tip_docum, cod_empresa, num_docum" # 5, 4, 2, 3 "
 ELSE
    LET l_sql_impres = l_sql_impres CLIPPED, " ORDER BY meio_envio, filial_cobranca, roteiro, sequencia "

 END IF

 WHENEVER ERROR CONTINUE
 PREPARE var_query2 FROM l_sql_impres
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("PREPARE SQL","VAR_QUERY2",l_sql_impres)
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE c_lista_bloqueto1 CURSOR WITH HOLD FOR var_query2
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("DECLARE CURSOR","C_LISTA_BLOQUETO1",l_sql_impres)
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 
 FOREACH c_lista_bloqueto1 INTO mr_docum.*,
                                mr_cre_compl_docum.*,
                                l_num_seq #não utilizada, somente está aqui pq está sendo feito
                                          #select * no sql preparado da tabela t_impressao_seq
     
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql_detalhe("FOREACH CURSOR","C_LISTA_BLOQUETO1",l_sql_impres)
        EXIT FOREACH
     END IF

     #Valida se portador do documento é valido - Robson
     
     IF mr_docum.cod_portador     <> 237
        AND mr_docum.cod_portador <> 275
        AND mr_docum.cod_portador <> 356
        AND mr_docum.cod_portador <> 33
        AND mr_docum.cod_portador <> 341
        AND mr_docum.cod_portador <> 104
        AND mr_docum.cod_portador <> 453
        AND mr_docum.cod_portador <> 320
        AND mr_docum.cod_portador <> 1   THEN
        
        WHENEVER ERROR CONTINUE
          SELECT cod_port_corresp
            FROM port_corresp
           WHERE cod_portador = mr_docum.cod_portador
             AND cod_port_corresp IN (237,275,356,33,341,320,453,1,104)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 100 THEN
           WHENEVER ERROR CONTINUE
             SELECT par_bloq_txt
               INTO l_par_bloq_txt
               FROM par_bloqueto_laser
              WHERE cod_empresa  = mr_docum.cod_empresa
                AND cod_portador = mr_docum.cod_portador
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
           END IF

           LET l_portador_repres = l_par_bloq_txt[147,150]

           IF l_portador_repres IS NULL OR l_portador_repres = '     ' THEN
              CONTINUE FOREACH
           ELSE
              LET l_portador = l_portador_repres

              IF l_portador  <> 237
              AND l_portador <> 275
              AND l_portador <> 356
              AND l_portador <> 33
              AND l_portador <> 341
              AND l_portador <> 104
              AND l_portador <> 453
              AND l_portador <> 320
              AND l_portador <> 1
              AND l_portador <> 001 THEN

                 WHENEVER ERROR CONTINUE
                   SELECT cod_port_corresp
                     FROM port_corresp
                    WHERE cod_portador = l_portador
                      AND cod_port_corresp IN (237,275,356,33,341,340,1,104)
                 WHENEVER ERROR CONTINUE
                 IF sqlca.sqlcode = 100 THEN
                    CONTINUE FOREACH
                 ELSE
                    IF sqlca.sqlcode <> 0 THEN
                       CALL log003_err_sql("LEITURA","PORT_CORRESP")
                    END IF
                 END IF
              END IF
           END IF
        ELSE
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("LEITURA","PORT_CORRESP")
           END IF
        END IF
     END IF
     
     #Valida se portador do documento é valido - Robson

     IF  pol1377_acha_par_bloqueto() = FALSE THEN
         LET l_laser = FALSE
         EXIT FOREACH
     END IF

     IF NOT pol1377_verifica_parametro_geracao_pdf() THEN
        {Mensagem de parâmetros não cadastrados já mostradas dentro da função.}
        EXIT FOREACH
     END IF

     CALL pol1377_impr_ext_bloq()

     LET m_emitiu = TRUE
     
     EXIT FOREACH
     
 END FOREACH

 IF l_laser = FALSE THEN
    LET m_msg = "Parâmetros inexistentes no VDP2822 para empresa ",mr_docum.cod_empresa
    CALL log0030_mensagem(m_msg,"info")
    RETURN
 END IF

 IF  NOT m_emitiu THEN
    CALL log0030_mensagem("Não foram impressos boletos.","info")
    RETURN
 END IF

 IF log0280_saida_relat(20,41) IS NULL THEN
    RETURN
 END IF
 LET g_nao_exclui_par = TRUE

 CALL pol1377_data_extenso_carta()

 LET m_emitiu = FALSE
 LET m_seq_geral_boleto = 0

 WHENEVER ERROR CONTINUE
 PREPARE var_query3 FROM l_sql_impres
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("PREPARE SQL","VAR_QUERY2",l_sql_impres)
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE c_lista_bloqueto3 CURSOR WITH HOLD FOR var_query3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("DECLARE CURSOR","C_LISTA_BLOQUETO1",l_sql_impres)
    RETURN
 END IF
 FREE var_query2

 WHENEVER ERROR CONTINUE
 FOREACH c_lista_bloqueto3 INTO mr_docum.*,
                                mr_cre_compl_docum.*,
                                l_num_seq  #não utilizada, somente está aqui pq está sendo feito
                                           #select * no sql preparado da tabela t_impressao_seq
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql_detalhe("FOREACH CURSOR","C_LISTA_BLOQUETO3",l_sql_impres)
       EXIT FOREACH
    END IF

    LET m_seq_geral_boleto = m_seq_geral_boleto + 1
    LET m_tem_demonst_agrupado = FALSE

    WHENEVER ERROR CONTINUE
    SELECT den_empresa
      INTO m_den_empresa
      FROM empresa
     WHERE cod_empresa = mr_docum.cod_empresa #497350 p_cod_empresa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql('SELEÇÃO','EMPRESA')
    END IF

    #Valida se portador do documento é valido - Robson
    IF mr_docum.cod_portador  <> 237
    AND mr_docum.cod_portador <> 275
    AND mr_docum.cod_portador <> 356
    AND mr_docum.cod_portador <> 104
    AND mr_docum.cod_portador <> 33
    AND mr_docum.cod_portador <> 341
    AND mr_docum.cod_portador <> 453
    AND mr_docum.cod_portador <> 320
    AND mr_docum.cod_portador <> 1   THEN
       WHENEVER ERROR CONTINUE
         SELECT cod_port_corresp
           FROM port_corresp
          WHERE cod_portador = mr_docum.cod_portador
            AND cod_port_corresp IN (237,275,356,33,341,320,453,1,104)
       WHENEVER ERROR CONTINUE
       IF sqlca.sqlcode = 100 THEN
          WHENEVER ERROR CONTINUE
            SELECT par_bloq_txt
              INTO l_par_bloq_txt
              FROM par_bloqueto_laser
             WHERE cod_empresa  = mr_docum.cod_empresa
               AND cod_portador = mr_docum.cod_portador
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 THEN
          END IF

          LET l_portador_repres = l_par_bloq_txt[147,150]

          IF l_portador_repres IS NULL OR l_portador_repres = '     ' THEN
             CONTINUE FOREACH
          ELSE
             LET l_portador = l_portador_repres

             IF l_portador  <> 237
             AND l_portador <> 275
             AND l_portador <> 356
             AND l_portador <> 33
             AND l_portador <> 341
             AND l_portador <> 104
             AND l_portador <> 453
             AND l_portador <> 320
             AND l_portador <> 1
             AND l_portador <> 001 THEN

                WHENEVER ERROR CONTINUE
                  SELECT cod_port_corresp
                    FROM port_corresp
                   WHERE cod_portador = l_portador
                     AND cod_port_corresp IN (237,275,356,33,341,340,1,104)
                WHENEVER ERROR CONTINUE
                IF sqlca.sqlcode = 100 THEN
                   CONTINUE FOREACH
                ELSE
                   IF sqlca.sqlcode <> 0 THEN
                      CALL log003_err_sql("LEITURA","PORT_CORRESP")
                   END IF
                END IF
             END IF
          END IF
       ELSE
          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql("LEITURA","PORT_CORRESP")
          END IF
       END IF
    END IF
    #Valida se portador do documento é valido - Robson

    INITIALIZE m_controle_portador TO NULL

    IF pol1377_acha_par_bloqueto() = FALSE THEN
       LET l_laser = FALSE
       EXIT FOREACH
    END IF

    IF NOT pol1377_verifica_parametro_geracao_pdf() THEN
       {Mensagem de parâmetros não cadastrados já mostradas dentro da função.}
       EXIT FOREACH
    END IF

    IF m_controle_portador IS NULL OR m_controle_portador = '   ' THEN
       SELECT cod_port_corresp
         INTO m_portador
         FROM port_corresp
        WHERE cod_portador = mr_docum.cod_portador
        IF sqlca.sqlcode <> 0 THEN
           LET m_portador = mr_docum.cod_portador
        END IF
    ELSE
      LET l_port_atual_bloq = m_controle_portador

      SELECT cod_port_corresp
        INTO m_portador
        FROM port_corresp
       WHERE cod_portador = m_controle_portador
       IF sqlca.sqlcode <> 0 THEN
          LET m_portador = m_controle_portador
       ELSE
          LET m_controle_portador = m_portador
       END IF
    END IF

    LET m_erro_docum = FALSE

    CALL pol1377_processa_dados()

    IF m_erro_docum THEN
       CONTINUE FOREACH
    END IF

    CALL pol1377_processa_laser()
    CALL pol1377_retencao_381()
    CALL pol1377_impr_ext_bloq()

    IF m_emitiu = TRUE THEN
       IF l_roteiro_anterior = m_roteiro_especifico THEN
          IF mr_docum.cod_cliente <> m_cod_cliente_ant THEN
             LET m_seq_rot_especifico = m_seq_rot_especifico + 1
             CALL log150_procura_caminho('LST') RETURNING m_caminho_carta_2_via
             LET m_caminho_carta_2_via_aux = m_caminho_carta_2_via       CLIPPED,
                                             "CRE1055:"                  CLIPPED, 
                                             p_user                      CLIPPED,'-',
                                             l_meio_envio_anterior       CLIPPED,'-',
                                             l_filial_cobranca_anterior  CLIPPED,'-',
                                             l_roteiro_anterior          CLIPPED,'-',
                                             m_seq_rot_especifico        USING "<<<<<<"

             CALL pol1377_emite_carta_envio(l_filial_cobranca_anterior ,
                                            l_meio_envio_anterior      ,
                                            l_roteiro_anterior         )
          END IF
       ELSE
          IF m_total_ordena <> 0                                                AND
             (mr_cre_compl_docum.meio_envio      <> l_meio_envio_anterior       OR
              mr_cre_compl_docum.roteiro         <> l_roteiro_anterior          OR
              mr_cre_compl_docum.filial_cobranca <> l_filial_cobranca_anterior) THEN

             CALL log150_procura_caminho('LST') RETURNING m_caminho_carta_2_via
             LET m_caminho_carta_2_via_aux = m_caminho_carta_2_via       CLIPPED, 
                                             "CRE1055:"                  CLIPPED, 
                                             p_user                      CLIPPED,'-',
                                             l_meio_envio_anterior       CLIPPED,'-',
                                             l_filial_cobranca_anterior  CLIPPED,'-',
                                             l_roteiro_anterior          CLIPPED

             CALL pol1377_emite_carta_envio(l_filial_cobranca_anterior ,
                                            l_meio_envio_anterior      ,
                                            l_roteiro_anterior         )
          END IF
       END IF
    END IF

    LET l_meio_envio_anterior      = mr_cre_compl_docum.meio_envio
    LET l_roteiro_anterior         = mr_cre_compl_docum.roteiro
    LET l_filial_cobranca_anterior = mr_cre_compl_docum.filial_cobranca

    #A variavel m_cod_cliente_ant foi criada para que sempre que a carta for
    #impressa, o sistema busque corretamente o nome do cliente do campo "Para:"
    #da carta. Veja que o programa ja estava estruturado para chamar a funcao de
    #impressao pol1377_emite_carta_envio() quando o FOREACH ja passou pro
    #registro da proxima carta. Por isso no final quando ja acabou o FOREACH, ele
    #chama a funcao pol1377_emite_carta_envio novamente. Fora do FOREACH ele
    #imprime a ultima carta que faltou.
    #Dessa forma, o LET da variavel m_cod_cliente_ant deve ficar sempre após a chamada da funcao
    #de impressao da carta (pol1377_emite_carta_envio)
    LET m_cod_cliente_ant = mr_docum.cod_cliente

    IF pol1377_insere_informacao_carta() = FALSE THEN
       CONTINUE FOREACH
    END IF

    IF pol1377_verifica_cnpj_item_igual_documento(mr_cre_compl_docum.empresa   ,
                                                  mr_cre_compl_docum.docum     ,
                                                  mr_cre_compl_docum.tip_docum ) = FALSE THEN
       LET l_verifica_cnpj_igual = FALSE
    ELSE
       LET l_verifica_cnpj_igual = TRUE
    END IF

    IF l_verifica_cnpj_igual = TRUE
    OR mr_cre_compl_docum.contrato_agrupado = "N" THEN
       CALL pol1377_calcula_qtd_itens_demonstrativo(TRUE)
    ELSE
       CALL pol1377_calcula_qtd_itens_demonstrativo(FALSE)
    END IF

    IF  mr_cre_compl_docum.contrato_agrupado = "S"
    AND m_imprime_bloqueto                   = "D"
    AND l_verifica_cnpj_igual                = FALSE THEN

       INITIALIZE ma_total_demonst_p_bloqueto TO NULL
       LET m_ind_p_bloqueto                 = 1
       LET m_ja_pulou_linha = FALSE

       CALL pol1377_calcula_qtd_pag_total(mr_cre_compl_docum.empresa   ,
                                          mr_cre_compl_docum.docum     ,
                                          mr_cre_compl_docum.tip_docum )

       WHENEVER ERROR CONTINUE
        DECLARE cq_contrato_agrupado_reimp CURSOR FOR
         SELECT DISTINCT(cnpj_ctr_agrupado)
           FROM ctr_titulo_item
          WHERE ctr_titulo_item.empresa   = mr_cre_compl_docum.empresa
            AND ctr_titulo_item.titulo     = mr_cre_compl_docum.docum
            AND ctr_titulo_item.tip_titulo = mr_cre_compl_docum.tip_docum
            AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
            AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("DECLARE","cq_contrato_agrupado_reimp")
       END IF

       WHENEVER ERROR CONTINUE
        FOREACH cq_contrato_agrupado_reimp INTO l_cnpj_cli_agrupado
       WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("FOREACH","cq_contrato_agrupado_reimp")
          END IF

          CALL pol1377_carrega_demonstrativo_detalhado(l_cnpj_cli_agrupado)

          WHENEVER ERROR CONTINUE
            DELETE FROM t_tip_consulta
             WHERE 1 = 1
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("DELETE","T_TIP_CONSULTA")
          END IF

          LET m_tem_demonst_agrupado = TRUE

       END FOREACH
    END IF

    IF m_tem_demonst_agrupado = FALSE THEN
       CALL pol1377_calcula_qtd_pag_so_bloqueto(mr_cre_compl_docum.empresa   ,
                                                mr_cre_compl_docum.docum     ,
                                                mr_cre_compl_docum.tip_docum )
    END IF

    #RAZÃO SOCIAL NO DEMONSTRATIVO COM BOLETO
    WHENEVER ERROR CONTINUE
      SELECT cod_cliente
        INTO l_cod_cliente
        FROM docum
       WHERE cod_empresa   = mr_cre_compl_docum.empresa
         AND num_docum     = mr_cre_compl_docum.docum
         AND ies_tip_docum = mr_cre_compl_docum.tip_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CLIENTES")
    END IF

    WHENEVER ERROR CONTINUE
      SELECT nom_cliente
        INTO l_nom_cliente
        FROM clientes
       WHERE cod_cliente = l_cod_cliente
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
       LET mr_demonst.val_raz_soc = l_nom_cliente
    END IF
    #-----

    INITIALIZE ma_tip_consulta TO NULL
    INITIALIZE mr_tip_consulta.* TO NULL
    WHENEVER ERROR CONTINUE
      DELETE FROM t_tip_consulta
       WHERE 1 = 1
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("DELETE","T_TIP_CONSULTA")
    END IF

    IF m_imprime_bloqueto = "D" THEN
       CALL pol1377_carrega_demonstrativo_resumo()
    END IF

    IF NOT pol1377_imprime_bloqueto_resumo() THEN
       CALL log0030_mensagem("Erro ao imprimir Bloqueto em PDF.","exclamation")
    ELSE
       CALL pol1377_grava_cre_docum_compl(mr_cre_compl_docum.empresa  ,
                                       mr_cre_compl_docum.docum    ,
                                       mr_cre_compl_docum.tip_docum)
    END IF

    IF m_controle_portador IS NOT NULL
    AND m_controle_portador <> '   ' THEN
       LET m_controle_portador = l_port_atual_bloq
    END IF

    CALL log085_transacao("BEGIN")

    IF pol1377_update_par_bloq() = FALSE THEN
       LET m_houve_erro = TRUE
       CALL log085_transacao("ROLLBACK")
       EXIT FOREACH
    END IF

    IF pol1377_processa_docum_banco() = FALSE THEN
       LET m_houve_erro = TRUE
       CALL log085_transacao("ROLLBACK")
       EXIT FOREACH
    END IF

    CALL log085_transacao("COMMIT")

    LET m_emitiu = TRUE
 END FOREACH
 #FREE c_lista_bloqueto1


 IF m_emitiu = TRUE THEN
    IF l_roteiro_anterior = m_roteiro_especifico THEN
       LET m_seq_rot_especifico = m_seq_rot_especifico + 1
       CALL log150_procura_caminho('LST') RETURNING m_caminho_carta_2_via
       LET m_caminho_carta_2_via_aux = m_caminho_carta_2_via       CLIPPED,
                                       "CRE1055:"                  CLIPPED, 
                                       p_user                      CLIPPED,'-',
                                       l_meio_envio_anterior       CLIPPED,'-',
                                       l_filial_cobranca_anterior  CLIPPED,'-',
                                       l_roteiro_anterior          CLIPPED,'-',
                                       m_seq_rot_especifico        USING "<<<<<<"

       CALL pol1377_emite_carta_envio(l_filial_cobranca_anterior,
                                      l_meio_envio_anterior     ,
                                      l_roteiro_anterior        )
    ELSE
       IF m_total_ordena <> 0 THEN

          LET m_num_lote = m_num_lote + 1

          #GRAVA CAMINHO DO ARQUIVO PDF
          #CALL pol1377_caminho_carta(m_caminho_diretorio_pdf, "PDF")
          #-----

          CALL log150_procura_caminho('LST') RETURNING m_caminho_carta_2_via
          LET m_caminho_carta_2_via_aux = m_caminho_carta_2_via       CLIPPED,
                                          "CRE1055:"                  CLIPPED, 
                                          p_user                      CLIPPED,'-',
                                          l_meio_envio_anterior       CLIPPED,'-',
                                          l_filial_cobranca_anterior  CLIPPED,'-',
                                          l_roteiro_anterior          CLIPPED

          CALL pol1377_emite_carta_envio(l_filial_cobranca_anterior,
                                         l_meio_envio_anterior     ,
                                         l_roteiro_anterior        )

          #GRAVA CAMINHO DA CARTA
          #CALL pol1377_caminho_carta(m_caminho_carta_envio, "TXT")
          #-----
       END IF
    END IF
 END IF

 IF m_tem_cartas = FALSE  THEN
    CALL pol1377_imprime_boletos_sem_carta()
 END IF

 IF l_laser = FALSE THEN
    LET m_msg = "Parâmetros inexistentes no VDP2822 para empresa ",mr_docum.cod_empresa
    CALL log0030_mensagem(m_msg,"info")
 END IF

 IF m_houve_erro = TRUE THEN
    CALL log0030_mensagem("Ocorerram erros no processamento.","INFO")
 END IF

 IF m_emitiu = TRUE THEN
    IF p_ies_impressao <> 'S' THEN
       CALL log0030_mensagem("Boletos em PDF gerados com sucesso.","info")
    ELSE
       IF p_ies_impressao = "S" THEN
          CALL log0030_mensagem("Boletos impressos com sucesso.","info")
       ELSE
          LET m_msg = "Relatório gravado no arquivo: ",m_nom_arquivo_pdf CLIPPED
          CALL log0030_mensagem(m_msg,"info")
       END IF
    END IF
 ELSE
    CALL log0030_mensagem("Não foram impressos boletos.","info")
 END IF

 INITIALIZE mr_tela1.* TO NULL

END FUNCTION

#------------------------------#
FUNCTION pol1377_impr_ext_bloq()
#------------------------------#
 
 DEFINE l_sistema LIKE cre_compl_docum.sistema_gerador

   IF  g_todos_sistemas = 'S' THEN
       WHENEVER ERROR CONTINUE
          SELECT sistema_gerador
            INTO l_sistema
            FROM ctr_titulo_mestre
           WHERE empresa   = mr_docum.cod_empresa
             AND titulo    = mr_docum.num_docum
             AND tip_titulo = mr_docum.ies_tip_docum
       WHENEVER ERROR STOP
   ELSE
       WHENEVER ERROR CONTINUE
          SELECT ctr_titulo_mestre.sistema_gerador
            INTO l_sistema
            FROM ctr_titulo_mestre, cre_popup_sist_781 #t_sistema
           WHERE ctr_titulo_mestre.empresa         = mr_docum.cod_empresa
             AND ctr_titulo_mestre.titulo          = mr_docum.num_docum
             AND ctr_titulo_mestre.tip_titulo      = mr_docum.ies_tip_docum
             AND ctr_titulo_mestre.sistema_gerador = cre_popup_sist_781.sistema #Os 451380
             AND cre_popup_sist_781.usuario      = p_user
             AND cre_popup_sist_781.sit_sistema  = 'S'
             AND cre_popup_sist_781.programa     = p_cod_programa

        WHENEVER ERROR STOP
   END IF

   IF sqlca.sqlcode <> 0 THEN
      LET l_sistema = ' '
   END IF

   WHENEVER ERROR CONTINUE
      SELECT emite_bloqueto,
             emite_extrato
        INTO m_imprime_bloqueto,
             m_imprime_extrato
        FROM cre_par_sist_781
       WHERE empresa = mr_docum.cod_empresa
         AND sistema = l_sistema
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      LET m_imprime_bloqueto = 'B'
      LET m_imprime_extrato  = 'S'
   END IF
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1377_processa_laser()
#-------------------------------#
 DEFINE l_taxa_multa        DECIMAL(05,2),
        l_val_juro_mora     LIKE docum.val_saldo,
        l_cedente           CHAR(70),
        l_titulo_banco      DECIMAL(17,0),
        l_cod_cedente_caixa CHAR(47),
        l_dv_verificador    INTEGER

 DEFINE l_tamanho_uf        SMALLINT

   #-------- OS 343485 --------# Inicio
 DEFINE l_pct_cofins      DECIMAL(5,2),
        l_pct_pis         DECIMAL(5,2),
        l_pct_csll        DECIMAL(5,2),
        l_pct_ret         DECIMAL(5,2),
        l_val_base        DECIMAL(17,2),
        l_pis_impresso    SMALLINT,
        l_pct_irrf        DECIMAL(5,2),
        l_tem_fiscal      CHAR(01),
        lr_fiscal_hist    RECORD LIKE fiscal_hist.*,
        l_motivo_retencao CHAR(01)

 DEFINE l_nom_banco       LIKE bancos.nom_banco,
        l_portador_corres LIKE portador.cod_portador

 INITIALIZE l_pct_csll, l_pct_pis, l_pct_cofins,
            l_val_base, l_pct_ret, l_pct_irrf, l_tem_fiscal TO NULL
  #---------------------------# Fim

   INITIALIZE mr_relat TO NULL #frank aqui controle para impressão dos dados do portador cedente item 6

   LET m_den_cedente         = ' '
   LET m_den_cedente_repre   = " "
   LET mr_relat.cod_cliente  = mr_dados_cliente.cod_cliente

   IF m_controle_portador IS NULL
   OR m_controle_portador = " " THEN
      LET mr_relat.cod_banco = mr_dados_banco.cod_portador CLIPPED USING "&&&", "-" CLIPPED, #frank item 06
                               mr_par_bloq_laser.dig_portador

      LET m_den_cedente = m_den_empresa CLIPPED, ' CNPJ: ', mr_dados_empresa.num_cgc

   ELSE
      {Sempre será impresso o nome do portador correspondente quando ouver
       ou o proprio portador representante quando este não tiver correspondente
       Neste momento a variavel M_CONTROLE_PORTADOR estará com o codigo do portador
       a ser impresso na parte superior do boleto, e é o nome desse portador que
       deverá ser buscado na tabela BANCOS para impressão do mesmo, e logo abaixo
       será atribuido a MR_RELAT.NOM_BANCO                                        }
      WHENEVER ERROR CONTINUE
      SELECT nom_banco
        INTO mr_dados_banco.nom_portador
        FROM bancos
       WHERE cod_banco = m_controle_portador
      WHENEVER ERROR CONTINUE
      IF sqlca.sqlcode <> 0 THEN
      END IF

      LET mr_relat.cod_banco    = m_controle_portador CLIPPED USING "&&&", "-" CLIPPED, mr_par_bloq_laser.dig_portador
      #LET m_den_cedente         = l_cedente
      LET m_den_cedente_repre   = m_den_empresa CLIPPED, ' CNPJ: ', mr_dados_empresa.num_cgc

      INITIALIZE l_nom_banco,
                 l_portador_corres TO NULL

       WHENEVER ERROR CONTINUE
         SELECT cod_port_corresp
           INTO l_portador_corres
           FROM port_corresp
          WHERE cod_portador = mr_docum.cod_portador
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 THEN
          LET l_portador_corres = mr_docum.cod_portador
       END IF

      WHENEVER ERROR CONTINUE
        SELECT nom_banco
          INTO l_nom_banco
          FROM bancos
         WHERE cod_banco = l_portador_corres
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         IF sqlca.sqlcode = 100 THEN
            WHENEVER ERROR CONTINUE
              SELECT nom_portador
                INTO l_nom_banco
                FROM portador
               WHERE cod_portador     = l_portador_corres
                 AND ies_tip_portador = mr_docum.ies_tip_portador
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 THEN
               ERROR "Erro ",sqlca.sqlcode USING"<<<<<<" ," LEITURA tabela PORTADOR."
            END IF
         ELSE
            ERROR "Erro ",sqlca.sqlcode USING"<<<<<<" ," LEITURA tabela BANCOS."
         END IF
      END IF

      LET m_den_cedente = l_nom_banco

   END IF

   LET mr_relat.nom_banco    = mr_dados_banco.nom_portador[1,30]

   #LET mr_relat.den_empresa  = mr_dados_empresa.den_empresa

   CASE
       WHEN mr_relat.cod_banco[1,3]  = "275"
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia USING "&&&&"  #frank item 06

       WHEN mr_relat.cod_banco[1,3]  = "356"
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia USING "&&&&"

       WHEN mr_relat.cod_banco[1,3]  = "033"
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia USING "&&&&"

       WHEN mr_relat.cod_banco[1,3]  = "341"
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia USING "&&&&"

       WHEN mr_relat.cod_banco[1,3]  = "104"
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia USING "&&&&"

       OTHERWISE
            LET mr_relat.cod_agencia = mr_par_bloq_laser.num_agencia
   END CASE

   LET mr_relat.cod_cedente  = mr_par_bloq_laser.cod_cedente  #frank item 05 manter codigo do cedente /fazer dois controle para
                                                              #localizar par_bloq_laser 1 para repserntae outro continua cedente

   IF mr_docum.dat_prorrogada IS NOT NULL THEN
      LET mr_relat.dat_vencto   = mr_docum.dat_prorrogada
   ELSE
      LET mr_relat.dat_vencto   = mr_docum.dat_vencto_s_desc
   END IF

   LET mr_relat.cod_carteira = mr_par_bloq_laser.par_bloq_txt[20,25]
   LET mr_relat.dat_emissao  = mr_docum.dat_emis
   LET mr_relat.dat_proces   = mr_docum.dat_emis
   LET mr_relat.num_docum    = mr_docum.num_docum
   LET mr_relat.esp_docum    = mr_par_bloq_laser.par_bloq_txt[26,31]

   {Parâmetro par_bloq_txt[32] busca com portador representante quando possuir }
   IF mr_par_bloq_laser.par_bloq_txt[32,32] = "S" THEN
      LET mr_relat.cod_aceite   = "SIM"
   ELSE
      LET mr_relat.cod_aceite   = "NAO"
   END IF

   LET mr_relat.val_docum       = mr_docum.val_saldo
   LET mr_relat.esp_moeda       = "R$"
   LET mr_relat.nom_cliente     = mr_dados_cliente.nom_cliente
   LET mr_relat.cod_cep         = mr_cre_compl_docum.cep_cobranca
   LET mr_relat_imp.endereco    = mr_cre_compl_docum.endereco_cobranca
   LET mr_relat_imp.complemento = mr_cre_compl_docum.compl_end_cobranca
   LET mr_relat_imp.bairro      = mr_cre_compl_docum.bairro_cobranca[1,40]
   LET mr_relat_imp.cidade      = mr_cre_compl_docum.cidade_cobranca[1,45]

   #OS455477
   LET l_tamanho_uf = LENGTH(mr_cre_compl_docum.estado_cobranca)
   IF l_tamanho_uf <= 2 THEN
      LET mr_relat_imp.unid_feder = mr_cre_compl_docum.estado_cobranca[1,2]
   ELSE
      LET mr_relat_imp.unid_feder = pol1377_sigla_unidade_federacao(mr_cre_compl_docum.estado_cobranca)
   END IF
   #OS455477

   LET mr_relat.num_cgc_cpf = mr_dados_cliente.num_cgc_cpf
   LET mr_relat.loc_pgto_1  = mr_par_bloq_laser.par_bloq_txt[34,83] CLIPPED, " ",  mr_par_bloq_laser.par_bloq_txt[84,110]
   LET mr_relat.loc_pgto_2  = NULL #mr_par_bloq_laser.par_bloq_txt[84,133]

   LET l_val_juro_mora = 0

   IF  mr_docum.pct_juro_mora IS NOT NULL AND
       mr_docum.pct_juro_mora > 0 THEN
       LET l_val_juro_mora = (mr_docum.pct_juro_mora * mr_docum.val_saldo) / 100
   END IF

   LET l_taxa_multa = pol1377_busca_multa()

   IF l_val_juro_mora > 0 OR l_taxa_multa    > 0 THEN
      LET mr_relat.instrucoes5 = "APOS VENCIMENTO COBRAR "

      IF l_taxa_multa > 0 THEN
         LET mr_relat.instrucoes5 = mr_relat.instrucoes5 CLIPPED, " MULTA DE ", l_taxa_multa USING "<<&.&&","%"
      END IF

      IF l_val_juro_mora > 0 THEN
         LET l_val_juro_mora = l_val_juro_mora / 30

         IF  l_taxa_multa > 0 THEN
             LET mr_relat.instrucoes5 = mr_relat.instrucoes5 CLIPPED, " E "
         END IF

         LET mr_relat.instrucoes5 = mr_relat.instrucoes5 CLIPPED,
                                    " JURO MORA DE R$ ",
                                    l_val_juro_mora USING "<<<<<<<<&.&&", " AO DIA."
      END IF
   END IF

   IF m_pct_desc_financ > 0 THEN
      LET mr_relat.instrucoes6  ="CONCEDER DESCONTO DE ",m_pct_desc_financ,"% ATE O VENCIMENTO"
   END IF

   IF m_ies_protesto = "S" THEN
      LET mr_relat.instrucoes6  ="SUJEITO A PROTESTO / ",m_qtd_dias_protesto USING "&&"," DIAS DE ATRASO NAO RECEBER"
   END IF

   #---------- OS 343485 ------------#
   WHENEVER ERROR CONTINUE
     SELECT parametro_val INTO l_pct_csll
       FROM cre_docum_compl
      WHERE cre_docum_compl.empresa   = mr_docum.cod_empresa
        AND cre_docum_compl.docum     = mr_docum.num_docum
        AND cre_docum_compl.tip_docum = mr_docum.ies_tip_docum
        AND cre_docum_compl.campo     = 'pct_csll'
   WHENEVER ERROR STOP
   IF  SQLCA.sqlcode <> 0 OR
       l_pct_csll IS NULL THEN
       LET l_pct_csll = 0
   END IF

   WHENEVER ERROR CONTINUE
     SELECT parametro_val INTO l_pct_pis
       FROM cre_docum_compl
      WHERE cre_docum_compl.empresa   = mr_docum.cod_empresa
        AND cre_docum_compl.docum     = mr_docum.num_docum
        AND cre_docum_compl.tip_docum = mr_docum.ies_tip_docum
        AND cre_docum_compl.campo     = 'pct_pis'
   WHENEVER ERROR STOP
   IF  SQLCA.sqlcode <> 0 OR
       l_pct_pis IS NULL THEN
       LET l_pct_pis = 0
   END IF

   WHENEVER ERROR CONTINUE
     SELECT parametro_val INTO l_pct_cofins
       FROM cre_docum_compl
      WHERE cre_docum_compl.empresa   = mr_docum.cod_empresa
        AND cre_docum_compl.docum     = mr_docum.num_docum
        AND cre_docum_compl.tip_docum = mr_docum.ies_tip_docum
        AND cre_docum_compl.campo     = 'pct_cofins'
   WHENEVER ERROR STOP
   IF  SQLCA.sqlcode <> 0 OR
       l_pct_cofins IS NULL THEN
       LET l_pct_cofins = 0
   END IF

   WHENEVER ERROR CONTINUE
     SELECT parametro_val INTO l_val_base
       FROM cre_docum_compl
      WHERE cre_docum_compl.empresa   = mr_docum.cod_empresa
        AND cre_docum_compl.docum     = mr_docum.num_docum
        AND cre_docum_compl.tip_docum = mr_docum.ies_tip_docum
        AND cre_docum_compl.campo     = 'val_base'
   WHENEVER ERROR STOP
   IF  SQLCA.sqlcode <> 0 OR
       l_val_base IS NULL THEN
       LET l_val_base = 0
   END IF

    WHENEVER ERROR CONTINUE
    SELECT parametro_val INTO m_cod_hist_fiscal
      FROM cre_docum_compl
     WHERE cre_docum_compl.empresa   = mr_docum.cod_empresa
       AND cre_docum_compl.docum     = mr_docum.num_docum
       AND cre_docum_compl.tip_docum = mr_docum.ies_tip_docum
       AND cre_docum_compl.campo     = 'cod_hist_fiscal'
    WHENEVER ERROR STOP
    IF  SQLCA.sqlcode <> 0 OR
        m_cod_hist_fiscal IS NULL THEN
        LET m_cod_hist_fiscal = 0
    ELSE LET l_tem_fiscal = TRUE
    END IF

# OS 383657 - Removido, pois o processo novo da OS prevê outra forma
# de impressão destes textos.
#    CALL pol1377_consistencias(l_pct_csll, l_pct_pis, l_pct_cofins)


   LET g_reimpressao = m_reimpressao

   CASE m_portador
      WHEN 1  # BANCO DO BRASIL
        LET g_cod_carteira = mr_relat.cod_carteira

        IF g_cod_carteira IS NULL THEN
           LET g_cod_carteira = 17
        END IF

        LET gr_relat.*          = mr_relat.*
        LET gr_par_escrit_txt.* = mr_par_escrit_txt.*
        LET gr_par_bloq_laser.* = mr_par_bloq_laser.*

        INITIALIZE g_numero_convenio TO NULL  #os  TEJNN4
        WHENEVER ERROR CONTINUE
        SELECT DISTINCT(parametro_texto)
          INTO g_numero_convenio
          FROM cre_escrit_compl
         WHERE empresa      = mr_docum.cod_empresa
           AND portador     = m_portador
           AND tip_portador = 'B'
           AND tip_cobranca = 'S'
           AND grupo        IS NOT NULL
           AND padrao_arq   = '01'
           AND campo        = 'Numero contrato'
        WHENEVER ERROR STOP
        IF sqlca.sqlcode < 0 THEN
           CALL log003_err_sql('SELEÇÃO','CRE_ESCRIT_COMPL')
           RETURN FALSE
        END IF

        IF sqlca.sqlcode = 100
        OR g_numero_convenio IS NULL
        OR g_numero_convenio = ' ' THEN
           CALL log0030_mensagem('Parâmetro "número do contrato" não cadastrado para o banco do Brasil (001). ','exclamation')
           RETURN FALSE
        END IF

        CALL cre10601_calcula_barras( mr_docum_banco.num_titulo_banco )

        LET mr_relat.* = gr_relat.*

      WHEN 237  # BRADESCO
         CALL cre1056_calcula_barras() # carrega linha digitavel e barras

      WHEN 275  # REAL
         #CALL cre1057_calcula_barras()
         LET l_titulo_banco      = NULL
         LET gr_par_bloq_laser.* = mr_par_bloq_laser.*
         LET gr_relat.*          = mr_relat.*

         IF g_reimpressao THEN
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&'
         END IF

         CALL cre10638_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
         CALL cre10638_calcula_cod_barras(l_titulo_banco)

         LET mr_relat.* = gr_relat.*

      WHEN 356  # REAL
         #CALL cre1057_calcula_barras()
         LET l_titulo_banco      = NULL
         LET gr_par_bloq_laser.* = mr_par_bloq_laser.*
         LET gr_relat.*          = mr_relat.*

         IF g_reimpressao THEN
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&'
         END IF

         CALL cre10638_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
         CALL cre10638_calcula_cod_barras(l_titulo_banco)

         LET mr_relat.* = gr_relat.*

      WHEN 33  # REAL
         #CALL cre1057_calcula_barras()
         LET l_titulo_banco      = NULL
         LET gr_par_bloq_laser.* = mr_par_bloq_laser.*
         LET gr_relat.*          = mr_relat.*

         IF g_reimpressao THEN
            LET l_titulo_banco = mr_docum_banco.num_titulo_banco[1,7] USING '&&&&&&&'
         END IF

         CALL cre10638_set_parametros(g_reimpressao,mr_docum_banco.num_titulo_banco)
         CALL cre10638_calcula_cod_barras(l_titulo_banco)

         LET mr_relat.* = gr_relat.*

      WHEN 341  #ITAU
         LET gr_par_bloq_laser.* = mr_par_bloq_laser.*
         LET gr_relat.* = mr_relat.*

         CALL cre10602_calcula_barras(mr_docum_banco.num_titulo_banco[1,8])
         LET mr_relat.* = gr_relat.*

      WHEN 320  # BICBANCO
         CALL cre1058_calcula_barras()

      WHEN 453  # RURAL
         LET p_nf_bloqueto.num_titulo_banco = mr_docum_banco.num_titulo_banco
         LET p_par_bloqueto.* = mr_par_bloq_laser.*
         LET p_relat.*        = mr_relat.*
         CALL vdp4018_calcula_cod_barras()
         LET mr_relat.* = p_relat.*
         LET g_comando = 'Nosso numero depois 453: ',mr_relat.nosso_numero

      WHEN 104 #CEF
         LET gr_par_bloq_laser.* = mr_par_bloq_laser.*
         LET gr_relat.* = mr_relat.*
         CALL cre10614_calcula_cod_barras(mr_docum_banco.num_titulo_banco[2,10])
         LET mr_relat.* = gr_relat.*
   END CASE

   LET mr_relat.instrucoes1  = mr_par_bloq_laser.instrucoes_1
   LET mr_relat.instrucoes2  = mr_par_bloq_laser.instrucoes_2
   LET mr_relat.instrucoes3  = mr_par_bloq_laser.instrucoes_3
   # desativado pq passou a receber 7
   #LET mr_relat.instrucoes4  = mr_par_bloq_laser.instrucoes_4

   IF mr_relat.cod_banco[1,3] = "104" THEN
      LET l_cod_cedente_caixa = mr_par_bloq_laser.cod_cedente CLIPPED,'00000000000000000000000000000000'
      LET l_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

      LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                       mr_par_bloq_laser.cod_cedente[5,7],'.',
                                       mr_par_bloq_laser.cod_cedente[8,15],'-',
                                       l_dv_verificador USING '<<<<<<&'

      LET mr_relat.cod_cedente = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                 mr_par_bloq_laser.cod_cedente[5,7],'.',
                                 mr_par_bloq_laser.cod_cedente[8,15],'-',
                                 l_dv_verificador USING '<<<<<<&'
   END IF

END FUNCTION


#----------------------------------------------#
 FUNCTION pol1377_carrega_demonstrativo_resumo()
#----------------------------------------------#
  DEFINE l_ind                INTEGER,
         l_ind2               INTEGER,
         l_dv_verificador     INTEGER,
         l_cod_cedente_caixa  CHAR(47),
         l_praca_ant          LIKE cre_itcompl_docum.praca,
         l_cent_msg           CHAR(01)

  DEFINE l_empresa_den_empresa LIKE empresa.den_empresa,
         l_empresa_end_empresa LIKE empresa.end_empresa,
         l_empresa_den_bairro  LIKE empresa.den_bairro ,
         l_empresa_den_munic   LIKE empresa.den_munic  ,
         l_empresa_uni_feder   LIKE empresa.uni_feder  ,
         l_empresa_cod_cep     LIKE empresa.cod_cep

  DEFINE l_item_praca        LIKE cre_itcompl_docum.praca,
         l_item_qtd_tot_item LIKE cre_itcompl_docum.qtd_item,
         l_item_val_tot_item LIKE cre_itcompl_docum.val_tot_item,
         l_item_classif_item LIKE cre_classif_item.classif_item,
         l_tip_consulta      LIKE cre_classif_item.tip_consulta,
         l_item              LIKE cre_itcompl_docum.item,
         l_dat_servico       LIKE cre_itcompl_docum.dat_servico

  DEFINE l_sistema_gerador     LIKE cre_txt_sist_gerad.sistema_gerador,
         l_cetl_impressao      LIKE cre_txt_sist_gerad.cetl_impressao ,
         l_texto               LIKE cre_txt_sist_gerad.texto          ,
         l_linha_texto         LIKE cre_txt_sist_gerad.linha_texto    ,
         l_sequencia_texto     LIKE cre_txt_sist_gerad.sequencia_texto,
         l_sequencia_texto_aux LIKE cre_txt_sist_gerad.sequencia_texto

  DEFINE l_primeira_vez      SMALLINT
  DEFINE l_den_item          LIKE item.den_item_reduz
  DEFINE l_cnpj_cli_agrupado LIKE cre_itcompl_docum.cnpj_cli_agrupado
  DEFINE l_den_praca         CHAR(28)

  DEFINE l_comparacao        SMALLINT
  DEFINE l_item_ant          LIKE cre_itcompl_docum.item

  DEFINE l_empresa         LIKE cre_itcompl_docum.empresa,
         l_docum           LIKE cre_itcompl_docum.docum,
         l_tip_docum       LIKE cre_itcompl_docum.tip_docum,
         l_item1            LIKE cre_itcompl_docum.item,
         l_sequencia_docum LIKE cre_itcompl_docum.sequencia_docum

  DEFINE l_mes_itcompl     CHAR(02)
  DEFINE l_ano_itcompl     CHAR(04)
  DEFINE l_data_itcompl    CHAR(10)

  DEFINE l_mes_docum       CHAR(02)
  DEFINE l_ano_docum       CHAR(04)
  DEFINE l_data_docum      CHAR(10)
  DEFINE l_achou_itens     SMALLINT
  DEFINE l_achou_pm        SMALLINT
  DEFINE l_total_negativo  LIKE cre_itcompl_docum.val_tot_item
  DEFINE l_val_outros_desc LIKE cre_itcompl_docum.val_tot_item

  DEFINE l_qtd SMALLINT

  LET l_qtd = 0

  INITIALIZE ma_demonst_item TO NULL
  INITIALIZE ma_tip_consulta TO NULL
  INITIALIZE m_texto_compl   TO NULL


  LET m_verifica_tip_consulta_pdf      = FALSE
  LET mr_tip_consulta.qtd_sem_desconto = 0
  LET mr_tip_consulta.qtd_com_desconto = 0
  LET mr_tip_consulta.val_sem_desconto = 0
  LET mr_tip_consulta.val_com_desconto = 0

  LET mr_demonst_totais.qtd_sem_desconto = 0
  LET mr_demonst_totais.qtd_com_desconto = 0
  LET mr_demonst_totais.qtd_carreteiro   = 0
  LET mr_demonst_totais.qtd_agregado     = 0
  LET mr_demonst_totais.qtd_frota        = 0
  LET mr_demonst_totais.qtd_out_func     = 0
  LET mr_demonst_totais.qtd_repesquisa   = 0
  LET mr_demonst_totais.qtd_recad_agr    = 0
  LET mr_demonst_totais.qtd_recad_fro    = 0
  LET mr_demonst_totais.qtd_recad_out_f  = 0
  LET mr_demonst_totais.val_sem_desconto = 0
  LET mr_demonst_totais.val_com_desconto = 0
  LET mr_demonst_totais.val_carreteiro   = 0
  LET mr_demonst_totais.val_agregado     = 0
  LET mr_demonst_totais.val_frota        = 0
  LET mr_demonst_totais.val_out_func     = 0
  LET mr_demonst_totais.val_repesquisa   = 0
  LET mr_demonst_totais.val_recad_agr    = 0
  LET mr_demonst_totais.val_recad_fro    = 0
  LET mr_demonst_totais.val_recad_out_f  = 0

  #Topo do demonstrativo
  LET mr_demonst.dem_telerisco_num  = mr_relat.num_docum
  LET mr_demonst.val_adm            = mr_cre_compl_docum.filial_cobranca
  LET mr_demonst.val_emissao        = mr_relat.dat_emissao
  LET mr_demonst.val_vencimento     = mr_relat.dat_vencto
  LET mr_demonst.val_cnpj_cpf       = mr_relat.num_cgc_cpf
  LET mr_demonst.val_insc_est       = mr_dados_cliente.ins_estadual

  #Itens do demonstrativo
  LET l_ind               = 0
  LET l_praca_ant         = 0
  LET l_comparacao        = FALSE
  LET l_item_ant          = "0"
  LET l_achou_itens       = FALSE
  LET l_achou_pm          = FALSE
  LET l_total_negativo    = 0
  LET l_val_outros_desc   = 0

  #EFETUA OS TRATAMENTOS PARA PREMIO MINIMO.
  CALL pol1377_verifica_classif_premio_minimo()
  CALL pol1377_total_itens_por_demonstrativo()

  IF  mr_cre_compl_docum.qtd_preco_minimo > 0
  AND mr_cre_compl_docum.qtd_preco_minimo >= m_total_itens_demonst THEN
     LET m_tem_premio_minimo = TRUE
  ELSE
     LET m_tem_premio_minimo = FALSE
  END IF

  IF m_tem_premio_minimo = TRUE THEN
     LET l_ind = l_ind + 1
     LET ma_demonst_item[l_ind].val_sem_desconto = 0
     LET ma_demonst_item[l_ind].qtd_sem_desconto = 0
     LET ma_demonst_item[l_ind].val_com_desconto = 0
     LET ma_demonst_item[l_ind].qtd_com_desconto = 0
     LET ma_demonst_item[l_ind].val_carreteiro   = 0
     LET ma_demonst_item[l_ind].qtd_carreteiro   = 0
     LET ma_demonst_item[l_ind].val_agregado     = 0
     LET ma_demonst_item[l_ind].qtd_agregado     = 0
     LET ma_demonst_item[l_ind].val_frota        = 0
     LET ma_demonst_item[l_ind].qtd_frota        = 0
     LET ma_demonst_item[l_ind].val_out_func     = 0
     LET ma_demonst_item[l_ind].qtd_out_func     = 0
     LET ma_demonst_item[l_ind].val_repesquisa   = 0
     LET ma_demonst_item[l_ind].qtd_repesquisa   = 0
     LET ma_demonst_item[l_ind].val_recad_agr    = 0
     LET ma_demonst_item[l_ind].qtd_recad_agr    = 0
     LET ma_demonst_item[l_ind].val_recad_fro    = 0
     LET ma_demonst_item[l_ind].qtd_recad_fro    = 0
     LET ma_demonst_item[l_ind].val_recad_out_f  = 0
     LET ma_demonst_item[l_ind].qtd_recad_out_f  = 0

     LET ma_tela_2[l_ind].val_tot_pre_minimo = mr_cre_compl_docum.val_tot_pre_minimo
     LET ma_tela_2[l_ind].qtd_preco_minimo   = mr_cre_compl_docum.qtd_preco_minimo
     LET l_achou_pm    = TRUE

     WHENEVER ERROR CONTINUE
       SELECT den_item_reduz
         INTO l_den_item
         FROM item
        WHERE cod_empresa = mr_cre_compl_docum.empresa_item
          AND cod_item    = mr_cre_compl_docum.item_preco_minimo
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","ITEM2")
     END IF

     IF l_den_item IS NULL
     OR l_den_item = " " THEN
        LET ma_tela_2[l_ind].praca = mr_cre_compl_docum.item_preco_minimo
     ELSE
        LET ma_tela_2[l_ind].praca = l_den_item
     END IF
  END IF
  #-----

  WHENEVER ERROR CONTINUE
   DECLARE cq_ctr_titulo_item CURSOR FOR
    SELECT DISTINCT(ctr_titulo_item.praca),
           cre_classif_item.classif_item,
           cre_classif_item.tip_consulta,
           SUM(ctr_titulo_item.qtd_item),
           SUM(ctr_titulo_item.val_total_item),
           ctr_titulo_item.item
      FROM ctr_titulo_item, cre_classif_item
     WHERE ctr_titulo_item.empresa    = mr_docum.cod_empresa
       AND ctr_titulo_item.titulo      = mr_docum.num_docum
       AND ctr_titulo_item.tip_titulo  = mr_docum.ies_tip_docum
       AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
       AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
       AND cre_classif_item.empresa     = ctr_titulo_item.empresa
       AND cre_classif_item.item        = ctr_titulo_item.item
     GROUP BY ctr_titulo_item.praca,
              cre_classif_item.classif_item,
              cre_classif_item.tip_consulta,
              ctr_titulo_item.item
     ORDER BY ctr_titulo_item.praca,
              cre_classif_item.classif_item,
              cre_classif_item.tip_consulta
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECAO','ctr_titulo_item1')
     RETURN
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_ctr_titulo_item
      INTO l_item_praca, l_item_classif_item, l_tip_consulta, l_item_qtd_tot_item, l_item_val_tot_item, l_item
  WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        CALL log003_err_sql('FOREACH','CQ_ctr_titulo_item')
        RETURN
     END IF

     LET l_qtd = l_qtd + 1

     IF l_item_val_tot_item < 0 THEN
        LET l_total_negativo = l_total_negativo + l_item_val_tot_item
        CONTINUE FOREACH
     END IF

     LET l_achou_itens = TRUE

     #IRÁ GRAVAR OS ITENS QUE NÃO IRÃO COMPOR O VALOR TOTAL DO DEMOSNTRATIVO.
     #QUANDO O PREMIO MINIMO FOR "01900002" OS ITENS QUE TIVEREM CLASSIFICACAO
     #"5" NÃO IRÃO COMPOR O VALOR TOTAL DO DEMOSNTRATIVO.
     IF m_tem_premio_minimo = TRUE THEN
        IF mr_cre_compl_docum.item_preco_minimo = "01900002" THEN
           IF l_item_classif_item = 5 THEN
              CONTINUE FOREACH
           END IF
        END IF

     #QUANDO O PREMIO MINIMO FOR "01900003" OS ITENS QUE TIVEREM CLASSIFICACAO
     #"5" E "6" NÃO IRÃO COMPOR O VALOR TOTAL DO DEMOSNTRATIVO.
        IF mr_cre_compl_docum.item_preco_minimo = "01900003" THEN
           IF l_item_classif_item = 5
           OR l_item_classif_item = 6 THEN
              CONTINUE FOREACH
           END IF
        END IF
     END IF
     #-----

     #UTILIZADO PARA IMPRIMIR SOMENTE NO FINAL OS ITENS QUE POSSUIREM
     #TIPO DE CONSULTA IGUAL A DEBITO.
     IF  l_tip_consulta = "D"
     AND m_tem_demonst_agrupado = FALSE THEN
        WHENEVER ERROR CONTINUE
          INSERT INTO t_tip_consulta(praca            ,
                                     classif_item     ,
                                     qtd_item         ,
                                     val_tot_item     ,
                                     cnpj_cli_agrupado,
                                     item             ,
                                     empresa          ,
                                     docum            ,
                                     tip_docum        ,
                                     sequencia_docum  )
                             VALUES (l_item_praca        ,
                                     l_item_classif_item ,
                                     l_item_qtd_tot_item ,
                                     l_item_val_tot_item ,
                                     " "                 ,
                                     l_item              ,
                                     l_empresa           ,
                                     l_docum             ,
                                     l_tip_docum         ,
                                     l_sequencia_docum   )

        WHENEVER ERROR STOP
        IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
           CALL log003_err_sql("INSERT","T_TIP_CONSULTA")
        END IF

        LET m_verifica_tip_consulta_pdf = TRUE

        CONTINUE FOREACH
     END IF
     #-----

     IF l_praca_ant <> l_item_praca THEN
        LET l_praca_ant = l_item_praca
        LET l_ind = l_ind + 1

        IF l_ind > 10000 THEN
          CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
          EXIT FOREACH
        END IF

        #Inicializa com 0 para evitar erro na soma dos valores
        LET ma_demonst_item[l_ind].val_sem_desconto = 0
        LET ma_demonst_item[l_ind].qtd_sem_desconto = 0
        LET ma_demonst_item[l_ind].val_com_desconto = 0
        LET ma_demonst_item[l_ind].qtd_com_desconto = 0
        LET ma_demonst_item[l_ind].val_carreteiro   = 0
        LET ma_demonst_item[l_ind].qtd_carreteiro   = 0
        LET ma_demonst_item[l_ind].val_agregado     = 0
        LET ma_demonst_item[l_ind].qtd_agregado     = 0
        LET ma_demonst_item[l_ind].val_frota        = 0
        LET ma_demonst_item[l_ind].qtd_frota        = 0
        LET ma_demonst_item[l_ind].val_out_func     = 0
        LET ma_demonst_item[l_ind].qtd_out_func     = 0
        LET ma_demonst_item[l_ind].val_repesquisa   = 0
        LET ma_demonst_item[l_ind].qtd_repesquisa   = 0
        LET ma_demonst_item[l_ind].val_recad_agr    = 0
        LET ma_demonst_item[l_ind].qtd_recad_agr    = 0
        LET ma_demonst_item[l_ind].val_recad_fro    = 0
        LET ma_demonst_item[l_ind].qtd_recad_fro    = 0
        LET ma_demonst_item[l_ind].val_recad_out_f  = 0
        LET ma_demonst_item[l_ind].qtd_recad_out_f  = 0


        LET ma_demonst_item[l_ind].praca = pol1377_get_den_praca(l_item_praca)

        CASE l_item_classif_item
          WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_sem_desconto = l_item_qtd_tot_item
          WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_com_desconto = l_item_qtd_tot_item
          WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_carreteiro   = l_item_qtd_tot_item
          WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_agregado     = l_item_qtd_tot_item
          WHEN 05 LET ma_demonst_item[l_ind].val_frota        = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_frota        = l_item_qtd_tot_item
          WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_out_func     = l_item_qtd_tot_item
          WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_repesquisa   = l_item_qtd_tot_item
          WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_agr    = l_item_qtd_tot_item
          WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_fro    = l_item_qtd_tot_item
          WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_out_f  = l_item_qtd_tot_item
        END CASE
     ELSE
        #Aqui
        #LET l_ind = l_ind + 1

        #IF l_ind > 10000 THEN
        #  CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
        #  EXIT FOREACH
        #END IF

        CASE l_item_classif_item
           WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto + l_item_qtd_tot_item
           WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto + l_item_qtd_tot_item
           WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = ma_demonst_item[l_ind].val_carreteiro   + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_carreteiro   = ma_demonst_item[l_ind].qtd_carreteiro   + l_item_qtd_tot_item
           WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = ma_demonst_item[l_ind].val_agregado     + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_agregado     = ma_demonst_item[l_ind].qtd_agregado     + l_item_qtd_tot_item
           WHEN 05 LET ma_demonst_item[l_ind].val_frota        = ma_demonst_item[l_ind].val_frota        + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_frota        = ma_demonst_item[l_ind].qtd_frota        + l_item_qtd_tot_item
           WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = ma_demonst_item[l_ind].val_out_func     + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_out_func     = ma_demonst_item[l_ind].qtd_out_func     + l_item_qtd_tot_item
           WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = ma_demonst_item[l_ind].val_repesquisa   + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_repesquisa   = ma_demonst_item[l_ind].qtd_repesquisa   + l_item_qtd_tot_item
           WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = ma_demonst_item[l_ind].val_recad_agr    + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_recad_agr    = ma_demonst_item[l_ind].qtd_recad_agr    + l_item_qtd_tot_item
           WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = ma_demonst_item[l_ind].val_recad_fro    + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_recad_fro    = ma_demonst_item[l_ind].qtd_recad_fro    + l_item_qtd_tot_item
           WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = ma_demonst_item[l_ind].val_recad_out_f  + l_item_val_tot_item
                   LET ma_demonst_item[l_ind].qtd_recad_out_f  = ma_demonst_item[l_ind].qtd_recad_out_f  + l_item_qtd_tot_item
        END CASE
     END IF

  END FOREACH

  FREE cq_ctr_titulo_item

  FOR l_ind2 = 1 TO l_ind
     LET mr_demonst_totais.val_sem_desconto = mr_demonst_totais.val_sem_desconto + ma_demonst_item[l_ind2].val_sem_desconto
     LET mr_demonst_totais.val_com_desconto = mr_demonst_totais.val_com_desconto + ma_demonst_item[l_ind2].val_com_desconto
     LET mr_demonst_totais.val_carreteiro   = mr_demonst_totais.val_carreteiro   + ma_demonst_item[l_ind2].val_carreteiro
     LET mr_demonst_totais.val_agregado     = mr_demonst_totais.val_agregado     + ma_demonst_item[l_ind2].val_agregado
     LET mr_demonst_totais.val_frota        = mr_demonst_totais.val_frota        + ma_demonst_item[l_ind2].val_frota
     LET mr_demonst_totais.val_out_func     = mr_demonst_totais.val_out_func     + ma_demonst_item[l_ind2].val_out_func
     LET mr_demonst_totais.val_repesquisa   = mr_demonst_totais.val_repesquisa   + ma_demonst_item[l_ind2].val_repesquisa
     LET mr_demonst_totais.val_recad_agr    = mr_demonst_totais.val_recad_agr    + ma_demonst_item[l_ind2].val_recad_agr
     LET mr_demonst_totais.val_recad_fro    = mr_demonst_totais.val_recad_fro    + ma_demonst_item[l_ind2].val_recad_fro
     LET mr_demonst_totais.val_recad_out_f  = mr_demonst_totais.val_recad_out_f  + ma_demonst_item[l_ind2].val_recad_out_f

     LET mr_demonst_totais.qtd_sem_desconto = mr_demonst_totais.qtd_sem_desconto + ma_demonst_item[l_ind2].qtd_sem_desconto
     LET mr_demonst_totais.qtd_com_desconto = mr_demonst_totais.qtd_com_desconto + ma_demonst_item[l_ind2].qtd_com_desconto
     LET mr_demonst_totais.qtd_carreteiro   = mr_demonst_totais.qtd_carreteiro   + ma_demonst_item[l_ind2].qtd_carreteiro
     LET mr_demonst_totais.qtd_agregado     = mr_demonst_totais.qtd_agregado     + ma_demonst_item[l_ind2].qtd_agregado
     LET mr_demonst_totais.qtd_frota        = mr_demonst_totais.qtd_frota        + ma_demonst_item[l_ind2].qtd_frota
     LET mr_demonst_totais.qtd_out_func     = mr_demonst_totais.qtd_out_func     + ma_demonst_item[l_ind2].qtd_out_func
     LET mr_demonst_totais.qtd_repesquisa   = mr_demonst_totais.qtd_repesquisa   + ma_demonst_item[l_ind2].qtd_repesquisa
     LET mr_demonst_totais.qtd_recad_agr    = mr_demonst_totais.qtd_recad_agr    + ma_demonst_item[l_ind2].qtd_recad_agr
     LET mr_demonst_totais.qtd_recad_fro    = mr_demonst_totais.qtd_recad_fro    + ma_demonst_item[l_ind2].qtd_recad_fro
     LET mr_demonst_totais.qtd_recad_out_f  = mr_demonst_totais.qtd_recad_out_f  + ma_demonst_item[l_ind2].qtd_recad_out_f
  END FOR

  #IMPRIME OS ITENS DE DEBITO
  IF m_verifica_tip_consulta_pdf = TRUE THEN
     INITIALIZE l_item_praca       ,
                l_item_classif_item,
                l_item_qtd_tot_item,
                l_item_val_tot_item TO NULL

     LET l_praca_ant = 0
     LET l_item_ant  = '0'
     LET l_ind       = l_ind + 1

     WHENEVER ERROR CONTINUE
      DECLARE cq_tip_consulta CURSOR FOR
       SELECT praca            ,
              classif_item     ,
              qtd_item         ,
              val_tot_item     ,
              cnpj_cli_agrupado,
              item             ,
              empresa          ,
              docum            ,
              tip_docum        ,
              sequencia_docum
         FROM t_tip_consulta
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("DECLARE","CQ_TIP_CONSULTA")
     END IF

     WHENEVER ERROR CONTINUE
      FOREACH cq_tip_consulta INTO l_item_praca       ,
                                   l_item_classif_item,
                                   l_item_qtd_tot_item,
                                   l_item_val_tot_item,
                                   l_cnpj_cli_agrupado,
                                   l_item             ,
                                   l_empresa          ,
                                   l_docum            ,
                                   l_tip_docum        ,
                                   l_sequencia_docum

     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("FOREACH","CQ_TIP_CONSULTA")
     END IF

        IF l_praca_ant <> l_item_praca THEN
           LET l_praca_ant = l_item_praca
           LET l_ind = l_ind + 1

           IF l_ind > 10000 THEN
             CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
             EXIT FOREACH
           END IF

           #Inicializa com 0 para evitar erro na soma dos valores
           LET ma_demonst_item[l_ind].val_sem_desconto = 0
           LET ma_demonst_item[l_ind].qtd_sem_desconto = 0
           LET ma_demonst_item[l_ind].val_com_desconto = 0
           LET ma_demonst_item[l_ind].qtd_com_desconto = 0
           LET ma_demonst_item[l_ind].val_carreteiro   = 0
           LET ma_demonst_item[l_ind].qtd_carreteiro   = 0
           LET ma_demonst_item[l_ind].val_agregado     = 0
           LET ma_demonst_item[l_ind].qtd_agregado     = 0
           LET ma_demonst_item[l_ind].val_frota        = 0
           LET ma_demonst_item[l_ind].qtd_frota        = 0
           LET ma_demonst_item[l_ind].val_out_func     = 0
           LET ma_demonst_item[l_ind].qtd_out_func     = 0
           LET ma_demonst_item[l_ind].val_repesquisa   = 0
           LET ma_demonst_item[l_ind].qtd_repesquisa   = 0
           LET ma_demonst_item[l_ind].val_recad_agr    = 0
           LET ma_demonst_item[l_ind].qtd_recad_agr    = 0
           LET ma_demonst_item[l_ind].val_recad_fro    = 0
           LET ma_demonst_item[l_ind].qtd_recad_fro    = 0
           LET ma_demonst_item[l_ind].val_recad_out_f  = 0
           LET ma_demonst_item[l_ind].qtd_recad_out_f  = 0

           LET ma_tip_consulta[l_ind].val_sem_desconto = 0
           LET ma_tip_consulta[l_ind].val_com_desconto = 0
           LET ma_tip_consulta[l_ind].qtd_sem_desconto = 0
           LET ma_tip_consulta[l_ind].qtd_com_desconto = 0

           WHENEVER ERROR CONTINUE
             SELECT den_item_reduz
               INTO l_den_item
               FROM item
              WHERE cod_empresa = mr_docum.cod_empresa
                AND cod_item    = l_item
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
              CALL log003_err_sql("SELECT","ITEM3")
           END IF


           LET l_den_praca = pol1377_get_den_praca(l_item_praca)
           LET ma_demonst_item[l_ind].praca = "*" CLIPPED, l_den_item CLIPPED, "-", l_den_praca CLIPPED

           CASE l_item_classif_item
             WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_sem_desconto = l_item_qtd_tot_item
             WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_com_desconto = l_item_qtd_tot_item
             WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_carreteiro   = l_item_qtd_tot_item
             WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_agregado     = l_item_qtd_tot_item
             WHEN 05 LET ma_demonst_item[l_ind].val_frota        = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_frota        = l_item_qtd_tot_item
             WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_out_func     = l_item_qtd_tot_item
             WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_repesquisa   = l_item_qtd_tot_item
             WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_recad_agr    = l_item_qtd_tot_item
             WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_recad_fro    = l_item_qtd_tot_item
             WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = l_item_val_tot_item
                     LET ma_demonst_item[l_ind].qtd_recad_out_f  = l_item_qtd_tot_item
           END CASE

           LET ma_tip_consulta[l_ind].val_sem_desconto = ma_tip_consulta[l_ind].val_sem_desconto + ma_demonst_item[l_ind].val_sem_desconto
           LET ma_tip_consulta[l_ind].val_com_desconto = ma_tip_consulta[l_ind].val_com_desconto + ma_demonst_item[l_ind].val_com_desconto
           LET ma_tip_consulta[l_ind].qtd_sem_desconto = ma_tip_consulta[l_ind].qtd_sem_desconto + ma_demonst_item[l_ind].qtd_sem_desconto
           LET ma_tip_consulta[l_ind].qtd_com_desconto = ma_tip_consulta[l_ind].qtd_com_desconto + ma_demonst_item[l_ind].qtd_com_desconto
        ELSE

           #Aqui
           #LET l_ind = l_ind + 1
           #
           #IF l_ind > 10000 THEN
           #  CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
           #  EXIT FOREACH
           #END IF

           CASE l_item_classif_item                                 #Incluido Marlon........................#
              WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto + l_item_qtd_tot_item
              WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto + l_item_qtd_tot_item
              WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = ma_demonst_item[l_ind].val_carreteiro   + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_carreteiro   = ma_demonst_item[l_ind].qtd_carreteiro   + l_item_qtd_tot_item
              WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = ma_demonst_item[l_ind].val_agregado     + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_agregado     = ma_demonst_item[l_ind].qtd_agregado     + l_item_qtd_tot_item
              WHEN 05 LET ma_demonst_item[l_ind].val_frota        = ma_demonst_item[l_ind].val_frota        + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_frota        = ma_demonst_item[l_ind].qtd_frota        + l_item_qtd_tot_item
              WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = ma_demonst_item[l_ind].val_out_func     + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_out_func     = ma_demonst_item[l_ind].qtd_out_func     + l_item_qtd_tot_item
              WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = ma_demonst_item[l_ind].val_repesquisa   + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_repesquisa   = ma_demonst_item[l_ind].qtd_repesquisa   + l_item_qtd_tot_item
              WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = ma_demonst_item[l_ind].val_recad_agr    + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_recad_agr    = ma_demonst_item[l_ind].qtd_recad_agr    + l_item_qtd_tot_item
              WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = ma_demonst_item[l_ind].val_recad_fro    + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_recad_fro    = ma_demonst_item[l_ind].qtd_recad_fro    + l_item_qtd_tot_item
              WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = ma_demonst_item[l_ind].val_recad_out_f  + l_item_val_tot_item
                      LET ma_demonst_item[l_ind].qtd_recad_out_f  = ma_demonst_item[l_ind].qtd_recad_out_f  + l_item_qtd_tot_item
           END CASE

           LET ma_tip_consulta[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto
           LET ma_tip_consulta[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto
           LET ma_tip_consulta[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto
           LET ma_tip_consulta[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto

        END IF
     END FOREACH

     FOR l_ind2 = 1 TO l_ind
        IF ma_tip_consulta[l_ind2].val_sem_desconto IS NULL THEN
           LET ma_tip_consulta[l_ind2].val_sem_desconto = 0
        END IF

        IF ma_tip_consulta[l_ind2].val_com_desconto IS NULL THEN
           LET ma_tip_consulta[l_ind2].val_com_desconto = 0
        END IF

        IF ma_tip_consulta[l_ind2].qtd_sem_desconto IS NULL THEN
           LET ma_tip_consulta[l_ind2].qtd_sem_desconto = 0
        END IF

        IF ma_tip_consulta[l_ind2].qtd_com_desconto IS NULL THEN
           LET ma_tip_consulta[l_ind2].qtd_com_desconto = 0
        END IF


        LET mr_tip_consulta.val_sem_desconto = mr_tip_consulta.val_sem_desconto + ma_tip_consulta[l_ind2].val_sem_desconto
        LET mr_tip_consulta.val_com_desconto = mr_tip_consulta.val_com_desconto + ma_tip_consulta[l_ind2].val_com_desconto
        LET mr_tip_consulta.qtd_sem_desconto = mr_tip_consulta.qtd_sem_desconto + ma_tip_consulta[l_ind2].qtd_sem_desconto
        LET mr_tip_consulta.qtd_com_desconto = mr_tip_consulta.qtd_com_desconto + ma_tip_consulta[l_ind2].qtd_com_desconto
     END FOR
  END IF
  #-----

  IF l_achou_itens = TRUE
  OR l_achou_pm    = TRUE THEN
     #Valores totais do demonstrativo
     #dados cedente
     WHENEVER ERROR CONTINUE
       SELECT den_razao_social
         INTO mr_demonst.val_cedente
         FROM emp_raz_soc
        WHERE cod_empresa = mr_docum.cod_empresa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        LET mr_demonst.val_cedente = mr_dados_empresa.den_empresa
     END IF

     CASE
       WHEN mr_relat.cod_banco[1,3] = "399"
            LET mr_demonst.val_age_cod_ced = mr_relat.cod_cedente

       WHEN mr_relat.cod_banco[1,3] = "275"
            LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],    #frank item 06
                                             "/",
                                             mr_relat.cod_cedente CLIPPED,
                                             "/",
                                             mr_relat.nosso_numero[9,9]  #frank item 06

       WHEN mr_relat.cod_banco[1,3] = "356"
            LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                             "/",
                                             mr_relat.cod_cedente CLIPPED,
                                             "/",
                                             mr_relat.nosso_numero[9,9]

       WHEN mr_relat.cod_banco[1,3] = "033"
            LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                             "/",
                                             mr_relat.cod_cedente CLIPPED,
                                             "/",
                                             mr_relat.nosso_numero[9,9]


       WHEN mr_relat.cod_banco[1,3] = "341"
          LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                           "/",
                                           mr_relat.cod_cedente CLIPPED

       WHEN mr_relat.cod_banco[1,3] = "422"
            LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia,
                                             ".",
                                             mr_relat.cod_cedente

       WHEN mr_relat.cod_banco[1,3] = "453"
            LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED," ",
                                             mr_relat.cod_cedente

       WHEN mr_relat.cod_banco[1,3] = "320"
            LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED," ",
                                             mr_relat.cod_cedente

       WHEN mr_relat.cod_banco[1,3] = "104"
            LET l_cod_cedente_caixa = mr_par_bloq_laser.cod_cedente CLIPPED,'00000000000000000000000000000000'
            LET l_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

            LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                             mr_par_bloq_laser.cod_cedente[5,7],'.',
                                             mr_par_bloq_laser.cod_cedente[8,15],'-',
                                             l_dv_verificador USING '<<<<<<&'

            LET mr_relat.cod_cedente = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                       mr_par_bloq_laser.cod_cedente[5,7],'.',
                                       mr_par_bloq_laser.cod_cedente[8,15],'-',
                                       l_dv_verificador USING '<<<<<<&'

       OTHERWISE
            LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED,"-",
                                             mr_par_bloq_laser.dig_agencia CLIPPED,
                                             " ",
                                             mr_relat.cod_cedente
     END CASE

     CASE
       WHEN mr_relat.cod_banco[1,3] = "275"
           LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7] #frank item 06

       WHEN mr_relat.cod_banco[1,3] = "356"
           LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7]

       WHEN mr_relat.cod_banco[1,3] = "033"
           LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7]

       WHEN mr_relat.cod_banco[1,3] = "341"
          LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,8]

       WHEN mr_relat.cod_banco[1,3] = "237"
           LET mr_demonst.val_nosso_num = mr_relat.cod_carteira[1,2],
                                          "/",
                                          mr_relat.nosso_numero
       OTHERWISE
          LET mr_demonst.val_nosso_num = mr_relat.nosso_numero
     END CASE

     IF m_classif_item = "CONSULTAS" THEN
        IF m_tem_premio_minimo = TRUE THEN
           LET mr_demonst.val_cons_pesq = ma_tela_2[1].val_tot_pre_minimo       +
                                          mr_demonst_totais.val_carreteiro      +
                                          mr_demonst_totais.val_agregado        +
                                          mr_demonst_totais.val_frota           +
                                          mr_demonst_totais.val_out_func        +
                                          mr_demonst_totais.val_repesquisa      +
                                          mr_demonst_totais.val_recad_agr       +
                                          mr_demonst_totais.val_recad_fro       +
                                          mr_demonst_totais.val_recad_out_f

        ELSE
           LET mr_demonst.val_cons_pesq = mr_demonst_totais.val_sem_desconto    +
                                          mr_demonst_totais.val_com_desconto    +
                                          mr_demonst_totais.val_carreteiro      +
                                          mr_demonst_totais.val_agregado        +
                                          mr_demonst_totais.val_frota           +
                                          mr_demonst_totais.val_out_func        +
                                          mr_demonst_totais.val_repesquisa      +
                                          mr_demonst_totais.val_recad_agr       +
                                          mr_demonst_totais.val_recad_fro       +
                                          mr_demonst_totais.val_recad_out_f

        END IF
     ELSE
        IF m_tem_premio_minimo = TRUE THEN
           LET mr_demonst.val_cons_pesq = ma_tela_2[1].val_tot_pre_minimo       +
                                          mr_demonst_totais.val_sem_desconto    +
                                          mr_demonst_totais.val_com_desconto    +
                                          mr_demonst_totais.val_carreteiro      +
                                          mr_demonst_totais.val_agregado        +
                                          mr_demonst_totais.val_frota           +
                                          mr_demonst_totais.val_out_func        +
                                          mr_demonst_totais.val_repesquisa      +
                                          mr_demonst_totais.val_recad_agr       +
                                          mr_demonst_totais.val_recad_fro       +
                                          mr_demonst_totais.val_recad_out_f
        ELSE
           LET mr_demonst.val_cons_pesq = mr_demonst_totais.val_sem_desconto    +
                                          mr_demonst_totais.val_com_desconto    +
                                          mr_demonst_totais.val_carreteiro      +
                                          mr_demonst_totais.val_agregado        +
                                          mr_demonst_totais.val_frota           +
                                          mr_demonst_totais.val_out_func        +
                                          mr_demonst_totais.val_repesquisa      +
                                          mr_demonst_totais.val_recad_agr       +
                                          mr_demonst_totais.val_recad_fro       +
                                          mr_demonst_totais.val_recad_out_f

        END IF
     END IF

     WHENEVER ERROR CONTINUE
       SELECT val_outro_desc
         INTO mr_demonst.val_outros_desc
         FROM ctr_titulo_mestre
        WHERE empresa        = mr_docum.cod_empresa
          AND titulo         = mr_docum.num_docum
          AND tip_titulo     = mr_docum.ies_tip_docum
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","ctr_titulo_mestre")
     END IF

     IF mr_demonst.val_outros_desc IS NULL
     OR mr_demonst.val_outros_desc = " " THEN
        LET mr_demonst.val_outros_desc = 0
     END IF

     LET mr_demonst.val_outros_desc = mr_demonst.val_outros_desc + l_total_negativo

     LET l_val_outros_desc          = mr_demonst.val_outros_desc

     IF l_val_outros_desc < 0 THEN
        LET l_val_outros_desc = l_val_outros_desc * (-1)
     END IF

     LET mr_demonst.val_desconto       = mr_cre_compl_docum.val_desc_comercial
     LET mr_demonst.val_val_acom       = mr_cre_compl_docum.val_acumulado_ant

     LET mr_demonst.val_iss_1          = m_pct_iss
     LET mr_demonst.val_iss_2          = m_val_iss_retencao
     LET mr_demonst.val_pis_1          = m_pct_pis
     LET mr_demonst.val_pis_2          = m_val_pis_retencao
     LET mr_demonst.val_confins_1      = m_pct_cofins
     LET mr_demonst.val_confins_2      = m_val_cofins_retencao
     LET mr_demonst.val_csll_1         = m_pct_csll
     LET mr_demonst.val_csll_2         = m_val_csll_retencao

     IF m_tem_premio_minimo = TRUE THEN
        LET mr_demonst.val_sub_total = (mr_demonst.val_cons_pesq -
                                        #l_val_outros_desc - #mr_demonst.val_outros_desc -
                                        mr_demonst.val_desconto -
                                        mr_demonst.val_iss_2 -
                                        mr_demonst.val_pis_2 -
                                        mr_demonst.val_confins_2 -
                                        mr_demonst.val_csll_2   )

        LET mr_demonst.val_sub_total = mr_demonst.val_sub_total             +
                                       mr_cre_compl_docum.val_acumulado_ant +
                                       mr_tip_consulta.val_sem_desconto     +
                                       mr_tip_consulta.val_com_desconto

        LET mr_demonst.val_sub_total = mr_demonst.val_sub_total - l_val_outros_desc

     ELSE
        IF m_verifica_tip_consulta_pdf = TRUE THEN
           LET mr_demonst.val_sub_total = (#l_val_outros_desc - #mr_demonst.val_outros_desc -
                                           mr_demonst.val_desconto    -
                                           mr_demonst.val_iss_2       -
                                           mr_demonst.val_pis_2       -
                                           mr_demonst.val_confins_2   -
                                           mr_demonst.val_csll_2      )

           LET mr_demonst.val_sub_total = mr_demonst.val_sub_total         +
                                          mr_tip_consulta.val_sem_desconto +
                                          mr_tip_consulta.val_com_desconto +
                                          mr_demonst.val_cons_pesq         +
                                          mr_cre_compl_docum.val_acumulado_ant

           LET mr_demonst.val_sub_total = mr_demonst.val_sub_total - l_val_outros_desc

        ELSE
           LET mr_demonst.val_sub_total = (mr_demonst.val_cons_pesq   -
                                           #l_val_outros_desc - #mr_demonst.val_outros_desc -
                                           mr_demonst.val_desconto    -
                                           mr_demonst.val_iss_2       -
                                           mr_demonst.val_pis_2       -
                                           mr_demonst.val_confins_2   -
                                           mr_demonst.val_csll_2      )

           LET mr_demonst.val_sub_total = mr_demonst.val_sub_total +
                                          mr_cre_compl_docum.val_acumulado_ant

           LET mr_demonst.val_sub_total = mr_demonst.val_sub_total - l_val_outros_desc

        END IF
     END IF

     LET mr_demonst.val_irrf_1    = m_pct_irrf
     LET mr_demonst.val_irrf_2    = m_val_irrf

     #::: Valores de INSS
     CALL pol1377_busca_valores_de_inss( mr_docum.cod_empresa   ,
                                         mr_docum.num_docum     ,
                                         mr_docum.ies_tip_docum )
     RETURNING mr_demonst.val_inss_1, mr_demonst.val_inss_2
     #:::

     LET mr_demonst.val_total_fat = mr_demonst.val_sub_total -
                                    mr_demonst.val_irrf_2    -
                                    mr_demonst.val_inss_2
  ELSE
     LET mr_tip_consulta.val_sem_desconto = 0
     LET mr_tip_consulta.val_com_desconto = 0
     LET mr_demonst.val_cons_pesq         = 0
     LET mr_demonst.val_outros_desc       = 0
     LET mr_demonst.val_desconto          = 0
     LET mr_demonst.val_val_acom          = 0
     LET mr_demonst.val_iss_1             = 0
     LET mr_demonst.val_iss_2             = 0
     LET mr_demonst.val_pis_1             = 0
     LET mr_demonst.val_pis_2             = 0
     LET mr_demonst.val_confins_1         = 0
     LET mr_demonst.val_confins_2         = 0
     LET mr_demonst.val_csll_1            = 0
     LET mr_demonst.val_csll_2            = 0
     LET mr_demonst.val_sub_total         = 0
     LET mr_demonst.val_irrf_1            = 0
     LET mr_demonst.val_irrf_2            = 0
     LET mr_demonst.val_inss_1            = 0
     LET mr_demonst.val_inss_2            = 0
     LET mr_demonst.val_total_fat         = 0
  END IF

  #VERSO DO BOLETO
  LET mr_demonst.txt_aviso_1 = ''
  LET mr_demonst.txt_aviso_2 = ''
  LET mr_demonst.aling_aviso = 0
  LET l_primeira_vez         = TRUE

  WHENEVER ERROR CONTINUE
    SELECT ctr_titulo_mestre.sistema_gerador
      INTO l_sistema_gerador
      FROM ctr_titulo_mestre
     WHERE ctr_titulo_mestre.empresa    = mr_docum.cod_empresa
       AND ctr_titulo_mestre.titulo     = mr_docum.num_docum
       AND ctr_titulo_mestre.tip_titulo = mr_docum.ies_tip_docum
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql('SELECT','ctr_titulo_mestre')
  END IF

  #DADOS REFERENTES AO PRIMEIRO QUADRO DO VERSO DO BOLETO
  WHENEVER ERROR CONTINUE
   DECLARE cq_quadro1 CURSOR FOR
    SELECT texto          ,
           linha_texto    ,
           cetl_impressao ,
           sequencia_texto
      FROM cre_txt_sist_gerad
     WHERE programa        = p_cod_programa
       AND sistema_gerador = l_sistema_gerador
       AND sequencia_texto >= 2
       AND sit_texto       = 'A'
       AND tip_texto       = 'B'
       AND linha_texto IN (1,2,3,4)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("DECLARE","CQ_QUADRO1")
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_quadro1 INTO l_texto          ,
                           l_linha_texto    ,
                           l_cetl_impressao ,
                           l_sequencia_texto
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("FOREACH","CQ_QUADRO1")
  END IF

     IF l_primeira_vez = TRUE THEN
        LET l_sequencia_texto_aux = l_sequencia_texto
        LET l_primeira_vez = FALSE
     END IF

     IF l_sequencia_texto <> l_sequencia_texto_aux THEN
        EXIT FOREACH
     ELSE
        IF l_cetl_impressao = 'S' THEN
           LET mr_demonst.aling_aviso = 1
        ELSE
           LET mr_demonst.aling_aviso = 0
        END IF

        CASE l_linha_texto
           WHEN 1
              LET mr_demonst.txt_aviso_1 = l_texto
           WHEN 2
              LET mr_demonst.txt_aviso_2 = l_texto
           WHEN 3
              LET mr_demonst.txt_aviso_3 = l_texto
           WHEN 4
              LET mr_demonst.txt_aviso_4 = l_texto
        END CASE
     END IF
  END FOREACH
  #-----

  LET l_texto       = NULL
  LET l_linha_texto = NULL

  #DADOS REFERENTES AO SEGUNDO QUADRO DO VERSO DO BOLETO
  WHENEVER ERROR CONTINUE
   DECLARE cq_quadro2 CURSOR FOR
    SELECT texto, linha_texto
      FROM cre_txt_sist_gerad
     WHERE programa        = p_cod_programa
       AND sistema_gerador = l_sistema_gerador
       AND sequencia_texto = 1
       AND sit_texto       = 'A'
       AND tip_texto       = 'B'
       AND linha_texto IN (1,2)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("DECLARE","cq_quadro2")
  END IF

  WHENEVER ERROR CONTINUE
   FOREACH cq_quadro2 INTO l_texto, l_linha_texto
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("FOREACH","cq_quadro2")
  END IF

     CASE l_linha_texto
        WHEN 1
           LET mr_demonst.val_v_end_cedente  = l_texto
        WHEN 2
           LET mr_demonst.val_v_comp_cedente = l_texto
     END CASE

  END FOREACH
  #-----

  IF m_verifica_tip_consulta_pdf = TRUE THEN
     WHENEVER ERROR CONTINUE
       SELECT texto
         INTO m_texto_compl
         FROM cre_txt_sist_gerad
        WHERE programa        = 'CRE1055' 
          AND sistema_gerador = l_sistema_gerador
          AND sequencia_texto = 3
          AND linha_texto     = 1
          AND tip_texto       = 'B'
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
        CALL log003_err_sql("SELECT","CRE_TXT_SIST_GERAD")
     END IF
  END IF

  #dados cedente
  WHENEVER ERROR CONTINUE
    SELECT den_razao_social
      INTO mr_demonst.val_v_cedente
      FROM emp_raz_soc
     WHERE cod_empresa = mr_docum.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     LET mr_demonst.val_v_cedente = mr_dados_empresa.den_empresa
  END IF

  #LET mr_demonst.val_v_end_cedente  = mr_dados_empresa.end_empresa CLIPPED, ' - ', mr_dados_empresa.den_bairro
  #LET mr_demonst.val_v_comp_cedente = mr_dados_empresa.cod_cep CLIPPED, ' - ', mr_dados_empresa.den_munic CLIPPED, ' - ', mr_dados_empresa.uni_feder

  #DADOS REFERENTES AO TERCEIRO QUADRO DO VERSO DO BOLETO
  LET mr_demonst.val_dados_cobranca = mr_cre_compl_docum.tip_cli_contrato CLIPPED, ' ',
                                      mr_cre_compl_docum.tip_contrato CLIPPED, ' ',
                                      mr_cre_compl_docum.meio_envio CLIPPED, '/ ',
                                      mr_cre_compl_docum.roteiro CLIPPED, '   COB:',
                                      mr_cre_compl_docum.filial_cobranca CLIPPED, '     ',
                                      mr_relat.num_docum CLIPPED, '     '
                                      #A pagina é setada na impressao
                                      #m_qtd_pagina CLIPPED, '/' m_qtd_pag_demonst ###### <<---

  LET mr_demonst.val_end_1_cob      = mr_relat.nom_cliente
  LET mr_demonst.val_end_2_cob      = mr_relat_imp.endereco CLIPPED, ' ', mr_relat_imp.complemento
  LET mr_demonst.val_end_3_cob      = mr_relat_imp.bairro CLIPPED, ' - ',
                                      mr_relat_imp.cidade CLIPPED, ' / ',
                                      mr_relat_imp.unid_feder
  LET mr_demonst.val_end_4_cob      = 'CEP ', mr_relat.cod_cep CLIPPED, '   ', pol1377_contato_etiqueta() CLIPPED
  #-----

 END FUNCTION

#-----------------------------------#
 FUNCTION pol1377_contato_etiqueta()
#-----------------------------------#
 DEFINE l_nome              CHAR(50)

 WHENEVER ERROR CONTINUE
 DECLARE cq_contato CURSOR FOR
 SELECT c.nome
   FROM logix@prdshm:vnempre a
  INNER JOIN logix@prdshm:vnxeccon b ON b.cdempre = a.cod and b.cdconf = '04' #Tipo de endereco etiqueta
  INNER JOIN logix@prdshm:vnxecont c ON c.cdempre = a.cod and c.cod = b.cdcont
  WHERE a.cdclierp = mr_docum.cod_cliente
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 OPEN cq_contato
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET l_nome = 'A/C CONTAS A PAGAR'
 END IF

 WHENEVER ERROR CONTINUE
 FETCH cq_contato INTO l_nome
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_nome IS NULL THEN
    LET l_nome = 'A/C CONTAS A PAGAR'
 END IF

 RETURN l_nome

 END FUNCTION

#---------------------------------#
 FUNCTION pol1377_busca_historico()
#---------------------------------#

 DEFINE l_texto                CHAR(74),
        l_tex_hist_1           LIKE fiscal_hist.tex_hist_1,
        l_tex_hist_2           LIKE fiscal_hist.tex_hist_1,
        l_tex_hist_3           LIKE fiscal_hist.tex_hist_1,
        l_tex_hist_4           LIKE fiscal_hist.tex_hist_1,
        l_msg                  CHAR(100),
        l_texto_hist           CHAR(300)

 INITIALIZE l_texto_hist ,l_texto, l_tex_hist_1, l_tex_hist_2, l_tex_hist_3, l_tex_hist_4 TO NULL

  IF m_cod_hist_fiscal > 0 THEN
     WHENEVER ERROR CONTINUE
     SELECT tex_hist_1,
            tex_hist_2,
            tex_hist_3,
            tex_hist_4
       INTO l_tex_hist_1,
            l_tex_hist_2,
            l_tex_hist_3,
            l_tex_hist_4
       FROM fiscal_hist
      WHERE fiscal_hist.cod_hist = m_cod_hist_fiscal
      WHENEVER ERROR STOP

     IF sqlca.sqlcode <> 0 THEN
        LET l_msg = 'Histórico fiscal não cadastrado: ',m_cod_hist_fiscal
        CALL log003_err_sql_detalhe('SELECT','FISCAL_HIST',l_msg)
     ELSE
        LET l_texto_hist = l_tex_hist_1 CLIPPED, l_tex_hist_2 CLIPPED,
                           l_tex_hist_3 CLIPPED, l_tex_hist_4 CLIPPED
        #era 8
        LET m_instrucoes7 = m_instrucoes7 CLIPPED," ", l_texto_hist[1,50]

     END IF
  ELSE
     #era 8
     LET m_instrucoes7 = m_instrucoes7 CLIPPED , ' DE ACORDO COM ART. 5 DA LEI 10.925/04'
  END IF

 END FUNCTION

#--------------------------------------#
 FUNCTION pol1377_processa_reimpressao()
#--------------------------------------#

 DEFINE l_sql_stmt                  CHAR(6000)                          ,
        l_sql_where                 CHAR(5000)                          ,
        l_stmt_completo             CHAR(10000)                          ,
        l_selecao                   SMALLINT                            ,
        l_cont                      SMALLINT                            ,
        l_laser                     SMALLINT                            ,
        l_portador                  DECIMAL(4,0),
        l_par_bloq_txt              CHAR(200),
        l_portador_repres           CHAR(04),
        l_meio_envio_anterior       LIKE cre_compl_docum.meio_envio     ,
        l_roteiro_anterior          LIKE cre_compl_docum.roteiro        ,
        l_filial_cobranca_anterior  LIKE cre_compl_docum.filial_cobranca,
        l_num_titulo_banco          LIKE docum_banco.num_titulo_banco   ,
        lr_cre_compl_docum          RECORD LIKE cre_compl_docum.*

 DEFINE l_cnpj_cli_agrupado         LIKE cre_itcompl_docum.cnpj_cli_agrupado
 DEFINE l_verifica_cnpj_igual       SMALLINT
 DEFINE lr_cre_itcompl_docum        RECORD LIKE cre_itcompl_docum.*
 DEFINE l_cod_cliente               LIKE docum.cod_cliente
 DEFINE l_nom_cliente               LIKE clientes.nom_cliente

 DEFINE l_item_praca        LIKE cre_itcompl_docum.praca

 IF log0280_saida_relat(20,41) IS NULL THEN
    RETURN
 END IF
 LET g_nao_exclui_par = TRUE

 IF NOT pol1377_cria_temp_processamento() THEN
    ERROR "Processamento cancelado."
    RETURN
 END IF

 IF NOT pol1377_carrega_textos_retencao() THEN
    ERROR "Processamento cancelado."
    RETURN
 END IF

 LET m_houve_erro               = FALSE
 LET l_laser                    = TRUE
 LET m_deletou_arquivo_atual    = FALSE
 LET m_ind_p_bloqueto           = 1

 LET l_sql_stmt =  
                 " d.cod_empresa         ,",     
                 " d.num_docum           ,",       
                 " d.ies_tip_docum       ,",       
                 " d.dat_emis            ,",       
                 " d.dat_vencto_c_desc   ,",       
                 " d.pct_desc            ,",       
                 " d.dat_vencto_s_desc   ,",       
                 " d.dat_prorrogada      ,",       
                 " d.ies_cobr_juros      ,",       
                 " d.cod_cliente         ,",       
                 " d.cod_repres_1        ,",       
                 " d.cod_repres_2        ,",       
                 " d.cod_repres_3        ,",       
                 " d.val_liquido         ,",       
                 " d.val_bruto           ,",       
                 " d.val_saldo           ,",       
                 " d.val_fat             ,",       
                 " d.val_desc_dia        ,",       
                 " d.val_desp_financ     ,",       
                 " d.ies_tip_cobr        ,",       
                 " d.pct_juro_mora       ,",       
                 " b.cod_portador        ,",       
                 " 'B'                   ,",       
                 " d.ies_cnd_bordero     ,",       
                 " d.ies_situa_docum     ,",       
                 " d.dat_alter_situa     ,",       
                 " d.ies_pgto_docum      ,",       
                 " d.ies_pendencia       ,",       
                 " d.ies_bloq_justific   ,",       
                 " d.num_pedido          ,",       
                 " d.num_docum_origem    ,",       
                 " d.ies_tip_docum_orig  ,",       
                 " d.ies_serie_fat       ,",       
                 " d.cod_local_fat       ,",       
                 " d.cod_tip_comis       ,",       
                 " d.pct_comis_1         ,",       
                 " d.pct_comis_2         ,",       
                 " d.pct_comis_3         ,",       
                 " d.val_desc_comis      ,",       
                 " d.dat_competencia     ,",       
                 " d.ies_tip_emis_docum  ,",       
                 " d.dat_emis_docum      ,",       
                 " d.num_lote_remessa    ,",       
                 " d.dat_gravacao        ,",       
                 " d.cod_cnd_pgto        ,",       
                 " d.cod_deb_cred_cl     ,",       
                 " d.ies_docum_suspenso  ,",       
                 " d.ies_tip_port_defin  ,",       
                 " d.ies_ctr_endosso     ,",       
                 " d.cod_mercado         ,",       
                 " d.num_lote_lanc_cont  ,",       
                 " d.dat_atualiz         ,",       
                 " b.num_titulo_banco    ,",       
                 " o.empresa             , ",      
                 " o.titulo              , ",      
                 " o.tip_titulo          , ",      
                 " o.sistema_gerador     , ",      
                 " 0                     , ",      
                 " 0                     , ",      
                 " 0                     , ",      
                 " 0                     , ",      
                 " o.val_credito         , ",      
                 " o.val_debito          , ",      
                 " o.val_acumulado       , ",      
                 " 0                     , ",      
                 " 0                     , ",      
                 " 0                     , ",      
                 " ' '                 , ",        
                 " ' '                 , ",        
                 " c.endereco_cobranca , ",        
                 " c.compl_endereco    , ",        
                 " c.bairro_cobranca   , ",        
                 " c.cidade_cobranca   , ",        
                 " c.estado_cobranca   , ",        
                 " c.cep_cobranca      , ",        
                 " ' '                 , ",        
                 " 1                   , ",        
                 " o.filial_cobranca   , ",        
                 " o.filial_admin      , ",        
                 " o.tip_nota_fiscal   , ",        
                 " o.tip_cli_contrato  , ",        
                 " 0                   , ",        
                 " o.natureza_operacao , ",        
                 " o.cond_pagamento    , ",        
                 " c.endereco_cobranca , ",        
                 " c.compl_endereco    , ",        
                 " c.bairro_cobranca   , ",        
                 " c.cidade_cobranca   , ",        
                 " c.estado_cobranca   , ",        
                 " c.cep_cobranca      , ",        
                 " ' '                 , ",        
                 " ' '                 , ",        
                 " o.tip_contrato      , ",        
                 " ' '                 , ",        
                 " ' '                 , ",        
                 " o.hierarq_cliente   , ",        
                 " o.gecon_cliente     , ",        
                 " o.hierarq_negocio   , ",        
                 " o.gecon_negocio     , ",        
                 " o.ramo_atividade    , ",        
                 " o.corretor          , ",        
                 " o.contr_agrupado    , ",        
                 " c.emp_item_pminimo  , ",        
                 " c.item_pminimo      , ",        
                 " c.qtde_pminimo      , ",        
                 " c.val_total_pminimo   ",        
            " FROM docum_banco b, docum d, ctr_titulo_mestre o, ctr_titulo_complementar c "

 LET l_sql_where = " WHERE b.num_titulo_banco IS NOT NULL ",
                   " AND b.ies_emis_boleto  = 'C' ",
                   " AND b.cod_empresa      = d.cod_empresa ",
                   " AND b.num_docum        = d.num_docum ",
                   " AND b.ies_tip_docum    = d.ies_tip_docum ",
                   " AND d.ies_situa_docum <> 'C' ",
                   " AND d.cod_empresa     <> '1R' "

 IF mr_tela2.empresa IS NOT NULL THEN
    LET l_sql_where = l_sql_where CLIPPED,
                      " AND d.cod_empresa      = '",mr_tela2.empresa,"' "
 END IF

 IF  mr_tela2.documento_de  IS NOT NULL
 AND mr_tela2.documento_ate IS NOT NULL THEN
    LET l_sql_where = l_sql_where CLIPPED,
                      " AND d.num_docum >= '",mr_tela2.documento_de,"' ",
                      " AND d.num_docum <= '",mr_tela2.documento_ate,"' "
 END IF

 LET l_sql_where = l_sql_where CLIPPED,
                   " AND o.empresa    = d.cod_empresa ",
                   " AND o.titulo     = d.num_docum ",
                   " AND o.tip_titulo = d.ies_tip_docum ",
                   " AND o.empresa    = c.empresa ",
                   " AND o.titulo     = c.titulo ",
                   " AND o.tip_titulo = c.tip_titulo "

 IF g_todos_sistemas = 'N' THEN
    SELECT COUNT(*)
      INTO l_cont
      FROM cre_popup_sist_781
     WHERE cre_popup_sist_781.usuario      = p_user
       AND cre_popup_sist_781.sit_sistema  = 'S'
       AND cre_popup_sist_781.programa     = p_cod_programa

    IF l_cont > 0 THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED, ", cre_popup_sist_781"
       LET l_sql_where = l_sql_where CLIPPED,
                       " AND o.sistema_gerador = cre_popup_sist_781.sistema",
                       " AND cre_popup_sist_781.usuario      = '",p_user,"' ",
                       " AND cre_popup_sist_781.sit_sistema  = 'S'",
                       " AND cre_popup_sist_781.programa     = '",p_cod_programa,"' "
    END IF
 END IF

 #--inicio--OS 719260  #
 IF mr_tela2.ies_num_docum = "N" THEN
    LET l_cont = 0
    WHENEVER ERROR CONTINUE
    SELECT COUNT(*)
      INTO l_cont
      FROM t_num_docum_selec
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL LOG003_err_sql("SELECT","t_num_docum_selec")
    END IF

    IF l_cont > 0  THEN
       LET l_sql_stmt = l_sql_stmt CLIPPED, ", t_num_docum_selec s "
       LET l_sql_where = l_sql_where CLIPPED,
                     " AND s.nom_usuario   = """,p_user,""" ",
                     " AND s.cod_programa  = """,p_cod_programa,""" ",
                     " AND s.cod_empresa   = d.cod_empresa ",
                     " AND s.num_docum     = d.num_docum ",
                     " AND s.portador      = b.cod_portador ",
                     " AND s.ies_tip_docum = b.ies_tip_docum "
    END IF
 ELSE
    IF mr_tela2.portador IS NOT NULL THEN
        LET l_sql_where = l_sql_where CLIPPED,
        " AND b.cod_portador     = '",mr_tela2.portador,"' "
    END IF
 END IF

 IF mr_tela2.carta_de IS NOT NULL AND mr_tela2.carta_ate IS NOT NULL THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, ", cre_docum_compl t "
    LET l_sql_where = l_sql_where CLIPPED,
                      " AND o.empresa          = t.empresa ",
                      " AND o.titulo           = t.docum ",
                      " AND o.tip_titulo       = t.tip_docum ",
                      " AND t.campo            = 'carta_envio'  ",
                      " AND t.parametro_val    >= '",mr_tela2.carta_de, "' ",
                      " AND t.parametro_val    <= '",mr_tela2.carta_ate, "' ",
                      " AND MONTH(t.parametro_dat) = '", mr_tela2.mes_competencia,"' ",
                      " AND YEAR(t.parametro_dat)  = '", mr_tela2.ano_competencia,"' "

 END IF
 #---fim----OS 719260  #

 LET l_stmt_completo = " SELECT 1 selecao,     ",
                     l_sql_stmt  CLIPPED,
                     l_sql_where CLIPPED,
                     " AND (d.num_docum_origem IS NOT NULL  ",
                     " AND  d.num_docum_origem > '0')  ",
                     " UNION ",
                     " SELECT 2 selecao,     ",
                     l_sql_stmt  CLIPPED,
                     l_sql_where CLIPPED,
                     " AND (d.num_docum_origem  IS NULL  ",
                     "  OR  d.num_docum_origem  = '0')  "

 IF m_total_ordena = 0 THEN
    LET l_stmt_completo = l_stmt_completo CLIPPED, " ORDER BY d.num_docum " #3
 ELSE
    LET l_stmt_completo = l_stmt_completo CLIPPED,
    " ORDER BY o.meio_envio, o.filial_cobranca, o.roteiro, selecao,d.num_docum_origem, d.num_docum  "  #95, 79, 96, 1, 32, 3 "
 END IF

 LET m_seq_geral_boleto = 0

 WHENEVER ERROR CONTINUE
  PREPARE var_query3 FROM l_stmt_completo
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql_detalhe("PREPARE","var_query3",l_stmt_completo)
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE c_lista_bloqueto2 CURSOR WITH HOLD FOR var_query3
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","c_lista_bloqueto2")
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH c_lista_bloqueto2 INTO l_selecao, mr_docum.*, l_num_titulo_banco, lr_cre_compl_docum.*
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       EXIT FOREACH
    END IF

    LET m_seq_geral_boleto = m_seq_geral_boleto + 1

    INITIALIZE m_controle_portador TO NULL
    INITIALIZE mr_cre_compl_docum.* TO NULL

    #ESTES VALORES CHEGAVAM ZERADOS NA FUNÇÃO "pol1377_carrega_demonstrativo_resumo()"
    LET mr_cre_compl_docum.* = lr_cre_compl_docum.*

    LET m_tem_demonst_agrupado = FALSE

    LET m_portador = mr_docum.cod_portador

    #---
    #Valida se portador do documento é valido - Robson
     IF mr_docum.cod_portador  <> 237
     AND mr_docum.cod_portador <> 275
     AND mr_docum.cod_portador <> 356
     AND mr_docum.cod_portador <> 33
     AND mr_docum.cod_portador <> 341
     AND mr_docum.cod_portador <> 453
     AND mr_docum.cod_portador <> 104
     AND mr_docum.cod_portador <> 320
     AND mr_docum.cod_portador <> 1   THEN
        WHENEVER ERROR CONTINUE
          SELECT cod_port_corresp
            FROM port_corresp
           WHERE cod_portador = mr_docum.cod_portador
             AND cod_port_corresp IN (237,275,356,33,341,320,453,1,104)
        WHENEVER ERROR STOP
        IF sqlca.sqlcode = 100 THEN
           WHENEVER ERROR CONTINUE
             SELECT par_bloq_txt
               INTO l_par_bloq_txt
               FROM par_bloqueto_laser
              WHERE cod_empresa  = mr_docum.cod_empresa
                AND cod_portador = mr_docum.cod_portador
           WHENEVER ERROR STOP
           IF sqlca.sqlcode <> 0 THEN
           END IF

           LET l_portador_repres = l_par_bloq_txt[147,150]

           IF l_portador_repres IS NULL OR l_portador_repres = '     ' THEN
              CONTINUE FOREACH
           ELSE
              LET l_portador = l_portador_repres

              IF l_portador  <> 237
              AND l_portador <> 275
              AND l_portador <> 356
              AND l_portador <> 33
              AND l_portador <> 341
              AND l_portador <> 104
              AND l_portador <> 453
              AND l_portador <> 320
              AND l_portador <> 1
              AND l_portador <> 001 THEN

                 WHENEVER ERROR CONTINUE
                   SELECT cod_port_corresp
                     FROM port_corresp
                    WHERE cod_portador = l_portador
                      AND cod_port_corresp IN (237,275,356,33,341,340,1,104)
                 WHENEVER ERROR CONTINUE
                 IF sqlca.sqlcode = 100 THEN
                    CONTINUE FOREACH
                 ELSE
                    IF sqlca.sqlcode <> 0 THEN
                       CALL log003_err_sql("LEITURA","PORT_CORRESP")
                    END IF
                 END IF
              END IF
           END IF
        ELSE
           IF sqlca.sqlcode <> 0 THEN
              CALL log003_err_sql("LEITURA","PORT_CORRESP")
           END IF
        END IF
     END IF
     #Valida se portador do documento é valido - Robson
    #--

    IF pol1377_acha_par_bloqueto() = FALSE THEN
       LET l_laser = FALSE
       EXIT FOREACH
    END IF

    IF m_controle_portador IS NULL OR m_controle_portador = '   ' THEN
       WHENEVER ERROR CONTINUE
       SELECT cod_port_corresp
         INTO m_portador
         FROM port_corresp
        WHERE cod_portador = mr_docum.cod_portador
       WHENEVER ERROR CONTINUE
       IF sqlca.sqlcode <> 0 THEN
       END IF
    ELSE
      WHENEVER ERROR CONTINUE
      SELECT cod_port_corresp
        INTO m_portador
        FROM port_corresp
       WHERE cod_portador = m_controle_portador
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 THEN
         LET m_portador = m_controle_portador
      ELSE
         LET m_controle_portador = m_portador
      END IF
    END IF

    LET m_erro_docum = FALSE

    IF NOT pol1377_verifica_parametro_geracao_pdf() THEN
       {Mensagem de parâmetros não cadastrados já mostradas dentro da função.}
       EXIT FOREACH
    END IF

    CALL pol1377_processa_dados()

    IF m_erro_docum THEN
       CONTINUE FOREACH
    END IF

    LET mr_docum_banco.num_titulo_banco = l_num_titulo_banco

    CALL pol1377_processa_laser()
    CALL pol1377_retencao_381()
    CALL pol1377_impr_ext_bloq()

    IF pol1377_verifica_cnpj_item_igual_documento(lr_cre_compl_docum.empresa   ,
                                                  lr_cre_compl_docum.docum     ,
                                                  lr_cre_compl_docum.tip_docum ) = FALSE THEN
       LET l_verifica_cnpj_igual = FALSE
    ELSE
       LET l_verifica_cnpj_igual = TRUE
    END IF

    IF l_verifica_cnpj_igual = TRUE
    OR mr_cre_compl_docum.contrato_agrupado = "N" THEN
       CALL pol1377_calcula_qtd_itens_demonstrativo(TRUE)
    ELSE
       CALL pol1377_calcula_qtd_itens_demonstrativo(FALSE)
    END IF

    IF  lr_cre_compl_docum.contrato_agrupado = "S"
    AND m_imprime_bloqueto                   = "D"
    AND l_verifica_cnpj_igual                = FALSE  THEN

       INITIALIZE ma_total_demonst_p_bloqueto TO NULL
       LET m_ind_p_bloqueto                 = 1
       LET m_ja_pulou_linha = FALSE


       CALL pol1377_calcula_qtd_pag_total(lr_cre_compl_docum.empresa   ,
                                          lr_cre_compl_docum.docum     ,
                                          lr_cre_compl_docum.tip_docum )

       WHENEVER ERROR CONTINUE
        DECLARE cq_contrato_agrupado CURSOR FOR
         SELECT DISTINCT(cnpj_ctr_agrupado)
           FROM ctr_titulo_item
          WHERE ctr_titulo_item.empresa   = lr_cre_compl_docum.empresa
            AND ctr_titulo_item.titulo     = lr_cre_compl_docum.docum
            AND ctr_titulo_item.tip_titulo = lr_cre_compl_docum.tip_docum
            AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
            AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("DECLARE","cq_contrato_agrupado")
       END IF

       WHENEVER ERROR CONTINUE
        FOREACH cq_contrato_agrupado INTO l_cnpj_cli_agrupado
       WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("FOREACH","CQ_CONTRATO_AGRUPADO")
          END IF

          CALL pol1377_carrega_demonstrativo_detalhado(l_cnpj_cli_agrupado)

          WHENEVER ERROR CONTINUE
            DELETE FROM t_tip_consulta
             WHERE 1 = 1
          WHENEVER ERROR STOP
          IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
             CALL log003_err_sql("DELETE","T_TIP_CONSULTA")
          END IF

          LET m_tem_demonst_agrupado = TRUE

       END FOREACH
    END IF

    IF m_tem_demonst_agrupado = FALSE THEN
       CALL pol1377_calcula_qtd_pag_so_bloqueto(lr_cre_compl_docum.empresa   ,
                                                lr_cre_compl_docum.docum     ,
                                                lr_cre_compl_docum.tip_docum )
    END IF

    #RAZÃO SOCIAL NO DEMONSTRATIVO COM BOLETO
    WHENEVER ERROR CONTINUE
      SELECT cod_cliente
        INTO l_cod_cliente
        FROM docum
       WHERE cod_empresa   = lr_cre_compl_docum.empresa
         AND num_docum     = lr_cre_compl_docum.docum
         AND ies_tip_docum = lr_cre_compl_docum.tip_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CLIENTES")
    END IF

    WHENEVER ERROR CONTINUE
      SELECT nom_cliente
        INTO l_nom_cliente
        FROM clientes
       WHERE cod_cliente = l_cod_cliente
    WHENEVER ERROR STOP
    IF sqlca.sqlcode = 0 THEN
       LET mr_demonst.val_raz_soc = l_nom_cliente
    END IF
    #-----

    INITIALIZE ma_tip_consulta TO NULL
    INITIALIZE mr_tip_consulta.* TO NULL
    WHENEVER ERROR CONTINUE
      DELETE FROM t_tip_consulta
       WHERE 1 = 1
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("DELETE","T_TIP_CONSULTA")
    END IF

    IF m_imprime_bloqueto = 'D' THEN
       CALL pol1377_carrega_demonstrativo_resumo()
    END IF

    IF NOT pol1377_imprime_bloqueto_resumo() THEN
       CALL log0030_mensagem("Erro ao imprimir Bloqueto em PDF.","exclamation")
    ELSE
       LET m_emitiu = TRUE  #os TDQ402  teste
       CALL pol1377_grava_cre_docum_compl(lr_cre_compl_docum.empresa   ,
                                          lr_cre_compl_docum.docum     ,
                                          lr_cre_compl_docum.tip_docum )
    END IF

    #CALL pol1377_imprime_boletos_sem_carta()

    LET m_emitiu = TRUE
 END FOREACH
   CALL conout ("emitiu reimpressao ", m_emitiu)
   CALL conout ("ies_impressao ", p_ies_impressao)

 IF m_houve_erro = TRUE THEN
    CALL log0030_mensagem("Ocorreram erros no processamento.","INFO")
 END IF



 IF m_emitiu = TRUE THEN
#    IF p_ies_impressao = "S" THEN
       CALL log0030_mensagem("Boletos reimpressos com sucesso.","info")
#    ELSE
#          LET m_msg = "Relatório gravado no arquivo: ",m_nom_arquivo_pdf CLIPPED
#          CALL log0030_mensagem(m_msg,"info")
#    END IF
#
 ELSE
    CALL log0030_mensagem("Não foram reimpressos boletos.","info")
 END IF


 INITIALIZE mr_tela1.* TO NULL

END FUNCTION

#---------------------------------------------------------------#
 FUNCTION pol1377_verifica_cnpj_item_igual_documento(l_empresa  ,
                                                     l_docum    ,
                                                     l_tip_docum)
#---------------------------------------------------------------#
 {Se todos os itens tiverem CNPJ igual ao do documento não será
 necessário a impressão de demonstrativos.}

 DEFINE l_empresa           LIKE cre_compl_docum.empresa            ,
        l_docum             LIKE cre_compl_docum.docum              ,
        l_tip_docum         LIKE cre_compl_docum.tip_docum          ,
        l_cnpj_cli_agrupado LIKE cre_itcompl_docum.cnpj_cli_agrupado,
        l_count             SMALLINT                                ,
        l_qtd_cnpj_igual    SMALLINT

 LET l_count          = 0
 LET l_qtd_cnpj_igual = 0

 WHENEVER ERROR CONTINUE
   SELECT COUNT(cnpj_ctr_agrupado)
     INTO l_count
     FROM ctr_titulo_item
    WHERE ctr_titulo_item.empresa   = l_empresa
      AND ctr_titulo_item.titulo     = l_docum
      AND ctr_titulo_item.tip_titulo = l_tip_docum
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","CQ_VERIFICA_CNPJ_ITEM")
 END IF

 WHENEVER ERROR CONTINUE
   SELECT COUNT(cnpj_ctr_agrupado)
     INTO l_qtd_cnpj_igual
     FROM ctr_titulo_item
    WHERE ctr_titulo_item.empresa           = l_empresa
      AND ctr_titulo_item.titulo             = l_docum
      AND ctr_titulo_item.tip_titulo         = l_tip_docum
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
      AND ctr_titulo_item.cnpj_ctr_agrupado = mr_relat.num_cgc_cpf
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","ctr_titulo_item")
 END IF

 IF l_qtd_cnpj_igual = l_count THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION


#--------------------------------#
 FUNCTION pol1377_processa_dados()
#--------------------------------#
 DEFINE l_cod_banco       LIKE bancos.cod_banco,
        l_nom_banco       LIKE bancos.nom_banco

 INITIALIZE mr_dados_empresa.*,
            mr_dados_cliente.*,
            mr_par_escrit_txt.*,
            mr_dados_vend.*,
            mr_dados_banco.*,
            mr_docum_banco.*      TO NULL

 INITIALIZE m_ies_protesto,
            m_qtd_dias_protesto,
            m_pct_desc_financ     TO NULL

 IF mr_docum.dat_emis < m_data_corte_contabilidade_L10 THEN
    WHENEVER ERROR CONTINUE
      SELECT cod_empresa     ,
             cod_portador    ,
             ies_tip_portador,
             ies_tip_cobr    ,
             ies_tip_docum   ,
             parametros
        INTO mr_par_escrit_txt.cod_empresa     ,
             mr_par_escrit_txt.cod_portador    ,
             mr_par_escrit_txt.ies_tip_portador,
             mr_par_escrit_txt.ies_tip_cobr    ,
             mr_par_escrit_txt.ies_tip_docum   ,
             mr_par_escrit_txt.parametros
        FROM par_escritural_txt
       WHERE cod_empresa = mr_docum.cod_empresa
         AND cod_portador = mr_docum.cod_portador
         AND ies_tip_portador = mr_docum.ies_tip_portador
         AND ies_tip_cobr = "S"
         AND ies_tip_docum = mr_docum.ies_tip_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       INITIALIZE mr_par_escrit_txt.* TO NULL
    END IF
 ELSE
    IF NOT pol1377_busca_dados_logix_10() THEN
       LET m_qtd_dia_protesto_L10 = 0
    END IF
 END IF

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO mr_dados_empresa.*
   FROM empresa
  WHERE cod_empresa = mr_docum.cod_empresa
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO mr_dados_cliente.*
   FROM clientes
  WHERE cod_cliente = mr_docum.cod_cliente
 WHENEVER ERROR STOP

 CALL pol1377_busca_endereco_cliente()

 IF m_erro_docum THEN
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 SELECT ies_protesto,qtd_dias_protesto
   INTO m_ies_protesto,m_qtd_dias_protesto
   FROM clientes_cre
  WHERE cod_cliente = mr_docum.cod_cliente
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET m_ies_protesto = "N"
 ELSE
    IF m_qtd_dias_protesto <= 0 THEN
       IF mr_docum.dat_emis < m_data_corte_contabilidade_L10 THEN
          IF mr_par_escrit_txt.parametros IS NOT NULL AND
             mr_par_escrit_txt.parametros <> ' '     THEN
             IF  mr_par_escrit_txt.parametros[06,07] IS NOT NULL
             AND mr_par_escrit_txt.parametros[06,07]> 0 THEN
                 LET m_qtd_dias_protesto = mr_par_escrit_txt.parametros[06,07]
             ELSE
                 LET m_ies_protesto = "N"
             END IF
          ELSE
             LET m_ies_protesto = "N"
          END IF
       ELSE
          IF m_qtd_dia_protesto_L10 = 0 THEN
             LET m_ies_protesto = "N"
          ELSE
             LET m_qtd_dias_protesto = m_qtd_dia_protesto_L10
          END IF
       END IF

    END IF
 END IF

 LET m_pct_desc_financ = 0

 WHENEVER ERROR CONTINUE
 DECLARE cq_pct CURSOR FOR
  SELECT UNIQUE(cond_pgto_item.pct_desc_financ)
    FROM cond_pgto_item, cli_cond_pgto
   WHERE cli_cond_pgto.cod_cliente   = mr_dados_cliente.cod_cliente
     AND cond_pgto_item.cod_cnd_pgto = cli_cond_pgto.cod_cnd_pgto

 FOREACH cq_pct INTO m_pct_desc_financ
    IF SQLCA.sqlcode <> 0 THEN
       EXIT FOREACH
    END IF

    IF m_pct_desc_financ > 0 THEN
       EXIT FOREACH
    END IF
 END FOREACH
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO mr_dados_vend.*
   FROM representante
  WHERE cod_repres = mr_docum.cod_repres_1
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO mr_dados_banco.*
   FROM portador
  WHERE cod_portador = m_portador
    AND ies_tip_portador = mr_docum.ies_tip_portador
 WHENEVER ERROR STOP

 LET l_cod_banco = m_portador

 WHENEVER ERROR CONTINUE
 SELECT nom_banco
   INTO l_nom_banco
   FROM bancos
  WHERE cod_banco = l_cod_banco
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0 THEN
    LET mr_dados_banco.nom_portador = l_nom_banco
 END IF

 WHENEVER ERROR CONTINUE
 SELECT *
   INTO mr_docum_banco.*
   FROM docum_banco
  WHERE cod_empresa = mr_docum.cod_empresa
    AND num_docum = mr_docum.num_docum
    AND ies_tip_docum = mr_docum.ies_tip_docum
    AND cod_portador = m_portador
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 SELECT emp_raz_soc.den_razao_social
   INTO m_den_empresa
   FROM emp_raz_soc
  WHERE cod_empresa = mr_docum.cod_empresa
 WHENEVER ERROR STOP

 CASE MONTH(mr_docum.dat_competencia)
    WHEN 01
       LET m_mes = 'Janeiro'
    WHEN 02
       LET m_mes = 'Fevereiro'
    WHEN 03
       LET m_mes = 'Marco'
    WHEN 04
       LET m_mes = 'Abril'
    WHEN 05
       LET m_mes = 'Maio'
    WHEN 06
       LET m_mes = 'Junho'
    WHEN 07
       LET m_mes = 'Julho'
    WHEN 08
       LET m_mes = 'Agosto'
    WHEN 09
       LET m_mes = 'Setembro'
    WHEN 10
       LET m_mes = 'Outubro'
    WHEN 11
       LET m_mes = 'Novembro'
    WHEN 12
       LET m_mes = 'Dezembro'
 END CASE

 END FUNCTION

#-----------------------------------------#
 FUNCTION pol1377_busca_endereco_cliente()
#-----------------------------------------#
 DEFINE l_total_erros         SMALLINT,
        l_ind                 SMALLINT,
        l_endereco            SMALLINT,
        l_bairro              SMALLINT,
        l_cidade              SMALLINT

 INITIALIZE m_msg              TO NULL
 LET l_endereco = FALSE
 LET l_bairro   = FALSE
 LET l_cidade   = FALSE

 WHENEVER ERROR CONTINUE
 SELECT c.endereco_cobranca,
        c.compl_end_cobranca,
        c.bairro_cobranca,
        c.cidade_cobranca,
        c.estado_cobranca,
        c.cep_cobranca,
        o.filial_admin,
        o.filial_cobranca,
        o.tip_cli_contrato,
        o.tip_contrato,
        ' ',
        ' ',
        0,
        o.val_acumulado
   INTO mr_cre_compl_docum.endereco_cobranca,
        mr_cre_compl_docum.compl_end_cobranca,
        mr_cre_compl_docum.bairro_cobranca,
        mr_cre_compl_docum.cidade_cobranca,
        mr_cre_compl_docum.estado_cobranca,
        mr_cre_compl_docum.cep_cobranca,
        mr_cre_compl_docum.filial_admin,
        mr_cre_compl_docum.filial_cobranca,
        mr_cre_compl_docum.tip_cli_contrato,
        mr_cre_compl_docum.tip_contrato,
        mr_cre_compl_docum.meio_envio,
        mr_cre_compl_docum.roteiro,
        mr_cre_compl_docum.val_desc_comercial,
        mr_cre_compl_docum.val_acumulado_ant
   FROM ctr_titulo_mestre o, ctr_titulo_complementar c
  WHERE o.empresa     = mr_docum.cod_empresa
    AND o.titulo      = mr_docum.num_docum
    AND o.tip_titulo  = mr_docum.ies_tip_docum
    AND c.empresa     = o.empresa
    AND c.titulo      = o.titulo
    AND c.tip_titulo  = o.tip_titulo
    
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    IF sqlca.sqlcode = 100 THEN
       LET m_msg = 'DADOS DE ENDERECO DO CLIENTE NAO ENCONTRADOS PARA O DOCUMENTO.'
       CALL pol1377_grava_temp_erros()
    ELSE
       CALL log003_err_sql('SELEÇÃO','ctr_titulo_mestre:1')

       LET m_msg = 'PROBLEMA NA SELECAO DOS DADOS DE ENDERECO DO CLIENTE.'
       CALL pol1377_grava_temp_erros()
    END IF
    RETURN
 END IF

 LET l_total_erros = 0

 IF mr_cre_compl_docum.endereco_cobranca IS NULL
 OR mr_cre_compl_docum.endereco_cobranca = '                                    ' THEN
    LET l_total_erros = l_total_erros + 1
 END IF

 IF mr_cre_compl_docum.bairro_cobranca IS NULL
 OR mr_cre_compl_docum.bairro_cobranca = '                    ' THEN
    LET l_total_erros = l_total_erros + 1
 END IF

 IF mr_cre_compl_docum.cidade_cobranca IS NULL
 OR mr_cre_compl_docum.cidade_cobranca = '                              ' THEN
    LET l_total_erros = l_total_erros + 1
 END IF

 IF mr_cre_compl_docum.estado_cobranca IS NULL
 OR mr_cre_compl_docum.estado_cobranca = '                                    ' THEN
    LET l_total_erros = l_total_erros + 1
 END IF

 IF l_total_erros = 0 THEN
    RETURN
 END IF

 LET l_ind = 1

 WHILE l_ind <= l_total_erros

    IF l_ind < l_total_erros AND
       l_ind > 1 THEN
       LET m_msg = m_msg CLIPPED,
                   ', '
    END IF

    IF l_ind = l_total_erros AND
       l_ind > 1 THEN
       LET m_msg = m_msg CLIPPED,
                   ' E '
    END IF

    IF mr_cre_compl_docum.endereco_cobranca IS NULL
    OR mr_cre_compl_docum.endereco_cobranca = '                                    ' THEN
       IF NOT l_endereco THEN
          IF l_ind = 1 THEN
             LET m_msg = 'ENDERECO'
          ELSE
             LET m_msg = m_msg CLIPPED,
                         ' ENDERECO'
          END IF

          LET l_endereco = TRUE
          LET l_ind = l_ind + 1
          CONTINUE WHILE
       END IF
    END IF

    IF mr_cre_compl_docum.bairro_cobranca IS NULL
    OR mr_cre_compl_docum.bairro_cobranca = '                    ' THEN
       IF NOT l_bairro THEN
          IF l_ind = 1 THEN
             LET m_msg = 'BAIRRO'
          ELSE
             LET m_msg = m_msg CLIPPED,
                         ' BAIRRO'
          END IF

          LET l_ind = l_ind + 1
          LET l_bairro = TRUE
          CONTINUE WHILE
       END IF
    END IF

    IF mr_cre_compl_docum.cidade_cobranca IS NULL
    OR mr_cre_compl_docum.cidade_cobranca = '                              ' THEN
       IF NOT l_cidade THEN
          IF l_ind = 1 THEN
             LET m_msg = 'CIDADE'
          ELSE
             LET m_msg = m_msg CLIPPED,
                         ' CIDADE'
          END IF

          LET l_ind = l_ind + 1
          LET l_cidade = TRUE
          CONTINUE WHILE
       END IF
    END IF

    IF mr_cre_compl_docum.estado_cobranca IS NULL
    OR mr_cre_compl_docum.estado_cobranca = '                                    ' THEN
       IF l_ind = 1 THEN
          LET m_msg = 'ESTADO'
       ELSE
          LET m_msg = m_msg CLIPPED,
                      ' ESTADO'
       END IF
    END IF

    LET l_ind = l_ind + 1

 END WHILE

 IF l_total_erros = 1 THEN
    LET m_msg = m_msg CLIPPED,
                ' NAO CADASTRADO'
 ELSE
    LET m_msg = m_msg CLIPPED,
                ' NAO CADASTRADOS'
 END IF

 CALL pol1377_grava_temp_erros()

END FUNCTION


#------------------------------------------#
 FUNCTION pol1377_cria_temp_processamento()
#------------------------------------------#

   LET m_tem_erros_temp = FALSE

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_temp_erros
     (
      docum               CHAR(14),
      tip_docum           CHAR(02),
      msg_erro            CHAR(100)
     ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_temp_erros
          WHERE 1 = 1
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_TEMP_ERROS')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','T_TEMP_ERROS')
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_carta
     (
      docum               CHAR(14),
      vencimento          DATE    ,
      nome_cliente        CHAR(15),
      competencia         CHAR(06),
      empresa             CHAR(02),
      nota_fiscal         CHAR(06),
      ies_tip_docum_orig  CHAR(02),
      nfe                 DECIMAL(10,0),
      valor               DECIMAL(15,2)
     ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_carta
          WHERE 1 = 1
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_CARTA')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','T_CARTA')
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_carta_aux
     (
      sequencia           DECIMAL(6,0),
      docum               CHAR(14),
      vencimento          DATE    ,
      nome_cliente        CHAR(15),
      competencia         CHAR(06),
      empresa             CHAR(02),
      nota_fiscal         CHAR(06),
      ies_tip_docum_orig  CHAR(02),
      nfe                 DECIMAL(10,0),
      valor               DECIMAL(15,2)
     ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_carta_aux
          WHERE 1 = 1
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_CARTA')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','T_CARTA')
         RETURN FALSE
      END IF
   END IF

   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_caminho_boleto
     (
      empresa           CHAR(02),
      documento         CHAR(14),
      tipo              CHAR(01),
      sequencia         SMALLINT,
      caminho           CHAR(200),
      caminho2          CHAR(200),
      impressao         CHAR(01)
     ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_caminho_boleto
          WHERE 1 = 1
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_CARTA')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','T_CARTA')
         RETURN FALSE
      END IF
   END IF


   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_tip_consulta
     (
      praca             INTEGER,
      classif_item      INTEGER,
      qtd_item          DECIMAL(12,3),
      val_tot_item      DECIMAL(15,2),
      cnpj_cli_agrupado CHAR(19),
      item              CHAR(15),
      empresa           CHAR(02),
      docum             CHAR(15),
      tip_docum         CHAR(02),
      sequencia_docum   SMALLINT
     ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_tip_consulta
          WHERE 1 = 1
         WHENEVER ERROR STOP

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_TIP_CONSULTA')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','T_TIP_CONSULTA')
         RETURN FALSE
      END IF
   END IF

 #tabelas abaixo foram criadas por Eduardo Luis Nogueira
 #as tabelas t_impressao e t_impressao_seq foram criadas para auxiliarem
 #na impressão dos boletos e cartas conforme necessidade do cliente
 #devido há um problema na tecnologia ao migrar da v0510 para 1002

 #a tabela T_IMPRESSAO irá receber as informações filtradas do banco de dados
 #que deverão ser impressas em forma de boleto e carta
   WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_impressao
    (
     cod_empresa        CHAR(02),      {2}
     num_docum          CHAR(14),      {3}
     ies_tip_docum      CHAR(02),      {4}
     dat_emis           DATE,          {5}
     dat_vencto_c_desc  DATE,          {6}
     pct_desc           DECIMAL(3,1),  {7}
     dat_vencto_s_desc  DATE,          {8}
     dat_prorrogada     DATE,          {9}
     ies_cobr_juros     CHAR(01),      {10}
     cod_cliente        CHAR(15),      {11}
     cod_repres_1       DECIMAL(4,0),  {12}
     cod_repres_2       DECIMAL(4,0),  {13}
     cod_repres_3       DECIMAL(4,0),  {14}
     val_liquido        DECIMAL(15,2), {15}
     val_bruto          DECIMAL(15,2), {16}
     val_saldo          DECIMAL(15,2), {17}
     val_fat            DECIMAL(15,2), {18}
     val_desc_dia       DECIMAL(15,2), {19}
     val_desp_financ    DECIMAL(15,2), {20}
     ies_tip_cobr       CHAR(01),      {21}
     pct_juro_mora      DECIMAL(5,2),  {22}
     cod_portador       DECIMAL(4,0),  {23}
     ies_tip_portador   CHAR(01),      {24}
     ies_cnd_bordero    CHAR(01),      {25}
     ies_situa_docum    CHAR(01),      {26}
     dat_alter_situa    DATE,          {27}
     ies_pgto_docum     CHAR(01),      {28}
     ies_pendencia      CHAR(01),      {29}
     ies_bloq_justific  CHAR(01),      {30}
     num_pedido         CHAR(16),      {31}
     num_docum_origem   CHAR(14),      {32}
     ies_tip_docum_orig CHAR(02),      {33}
     ies_serie_fat      CHAR(02),      {34}
     cod_local_fat      DECIMAL(2,0),  {35}
     cod_tip_comis      DECIMAL(1,0),  {36}
     pct_comis_1        DECIMAL(5,2),  {37}
     pct_comis_2        DECIMAL(5,2),  {38}
     pct_comis_3        DECIMAL(5,2),  {39}
     val_desc_comis     DECIMAL(15,2), {40}
     dat_competencia    DATE,          {41}
     ies_tip_emis_docum CHAR(01),      {42}
     dat_emis_docum     DATE,          {43}
     num_lote_remessa   DECIMAL(8,0),  {44}
     dat_gravacao       DATE,          {45}
     cod_cnd_pgto       DECIMAL(2,0),  {46}
     cod_deb_cred_cl    DECIMAL(2,0),  {47}
     ies_docum_suspenso CHAR(01),      {48}
     ies_tip_port_defin CHAR(01),      {49}
     ies_ctr_endosso    CHAR(01),      {50}
     cod_mercado        CHAR(01),      {51}
     num_lote_lanc_cont DECIMAL(3,0),  {52}
     dat_atualiz        DATE,          {53}
     empresa            CHAR(02),      {54}
     docum              CHAR(14),      {55}
     tip_docum          CHAR(02),      {56}
     sistema_gerador    CHAR(20),      {57}
     val_desc_comercial DECIMAL(15,2), {58}
     val_cons_pesquisa  DECIMAL(15,2), {59}
     val_outro_desc     DECIMAL(15,2), {60}
     val_desc_pamcard   DECIMAL(15,2), {61}
     val_credito        DECIMAL(15,2), {62}
     val_debito         DECIMAL(15,2), {63}
     val_acumulado_ant  DECIMAL(15,2), {64}
     val_honorar        DECIMAL(15,2), {65}
     pct_irrf           DECIMAL(5,2),  {66}
     val_irrf           DECIMAL(15,2), {67}
     tip_portador_pagto CHAR(01),      {68}
     dat_bilhetag       DATE,          {69}
     endereco_cobranca  CHAR(46),      {70}
     compl_end_cobranca CHAR(30),      {71}
     bairro_cobranca    CHAR(60),      {72}
     cidade_cobranca    CHAR(60),      {73}
     estado_cobranca    CHAR(20),      {74}
     cep_cobranca       CHAR(09),      {75}
     sucursal           CHAR(10),      {76}
     moeda_fatura       DECIMAL(2,0),  {77}
     filial_cobranca    CHAR(10),      {78}
     filial_admin       CHAR(10),      {79}
     tip_nota_fiscal    CHAR(02),      {80}
     tip_cli_contrato   CHAR(15),      {81}
     grupo_economico    SMALLINT,      {82}
     natureza_operacao  SMALLINT,      {83}
     cond_pagto         DECIMAL(3,0),  {84}
     endereco_etiq      CHAR(46),      {85}
     compl_end_etiq     CHAR(30),      {86}
     bairro_etiq        CHAR(60),      {87}
     cidade_etiq        CHAR(60),      {88}
     estado_etiq        CHAR(20),      {89}
     cep_etiq           CHAR(09),      {90}
     caixa_postal_etiq  CHAR(05),      {91}
     obs_endereco_etiq  CHAR(60),      {92}
     tip_contrato       CHAR(10),      {93}
     meio_envio         CHAR(10),      {94}
     roteiro            CHAR(10),      {95}
     dirigente_cliente  CHAR(05),      {96}
     geren_cta_cliente  CHAR(10),      {97}
     dirigente_negocio  CHAR(05),      {98}
     geren_cta_negocio  CHAR(10),      {99}
     ramo_ativ          CHAR(05),      {100}
     corretor           CHAR(10),      {101}
     contrato_agrupado  CHAR(01),      {102}
     empresa_item       CHAR(02),      {103}
     item_preco_minimo  CHAR(15),      {104}
     qtd_preco_minimo   SMALLINT,      {105}
     val_tot_pre_minimo DECIMAL(15,2)  {106}
    )WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_impressao
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_impressao')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','t_impressao')
         RETURN FALSE
      END IF
   END IF

  #a tabela T_IMPRESSAO_SEQ é espelho da tabela T_IMPRESSAO mais o campo SEQUENCIA
  #é esta tabela a responsável pela impressão dos boletos obedecendo a ordenção solicitada
  #pelo cliente. Maiores detalhes estão descritos na função onde a mesma está sendo utilizada.
  WHENEVER ERROR CONTINUE
  CREATE TEMP TABLE t_impressao_seq
    (
     cod_empresa        CHAR(02),      {2}
     num_docum          CHAR(14),      {3}
     ies_tip_docum      CHAR(02),      {4}
     dat_emis           DATE,          {5}
     dat_vencto_c_desc  DATE,          {6}
     pct_desc           DECIMAL(3,1),  {7}
     dat_vencto_s_desc  DATE,          {8}
     dat_prorrogada     DATE,          {9}
     ies_cobr_juros     CHAR(01),      {10}
     cod_cliente        CHAR(15),      {11}
     cod_repres_1       DECIMAL(4,0),  {12}
     cod_repres_2       DECIMAL(4,0),  {13}
     cod_repres_3       DECIMAL(4,0),  {14}
     val_liquido        DECIMAL(15,2), {15}
     val_bruto          DECIMAL(15,2), {16}
     val_saldo          DECIMAL(15,2), {17}
     val_fat            DECIMAL(15,2), {18}
     val_desc_dia       DECIMAL(15,2), {19}
     val_desp_financ    DECIMAL(15,2), {20}
     ies_tip_cobr       CHAR(01),      {21}
     pct_juro_mora      DECIMAL(5,2),  {22}
     cod_portador       DECIMAL(4,0),  {23}
     ies_tip_portador   CHAR(01),      {24}
     ies_cnd_bordero    CHAR(01),      {25}
     ies_situa_docum    CHAR(01),      {26}
     dat_alter_situa    DATE,          {27}
     ies_pgto_docum     CHAR(01),      {28}
     ies_pendencia      CHAR(01),      {29}
     ies_bloq_justific  CHAR(01),      {30}
     num_pedido         CHAR(16),      {31}
     num_docum_origem   CHAR(14),      {32}
     ies_tip_docum_orig CHAR(02),      {33}
     ies_serie_fat      CHAR(02),      {34}
     cod_local_fat      DECIMAL(2,0),  {35}
     cod_tip_comis      DECIMAL(1,0),  {36}
     pct_comis_1        DECIMAL(5,2),  {37}
     pct_comis_2        DECIMAL(5,2),  {38}
     pct_comis_3        DECIMAL(5,2),  {39}
     val_desc_comis     DECIMAL(15,2), {40}
     dat_competencia    DATE,          {41}
     ies_tip_emis_docum CHAR(01),      {42}
     dat_emis_docum     DATE,          {43}
     num_lote_remessa   DECIMAL(8,0),  {44}
     dat_gravacao       DATE,          {45}
     cod_cnd_pgto       DECIMAL(2,0),  {46}
     cod_deb_cred_cl    DECIMAL(2,0),  {47}
     ies_docum_suspenso CHAR(01),      {48}
     ies_tip_port_defin CHAR(01),      {49}
     ies_ctr_endosso    CHAR(01),      {50}
     cod_mercado        CHAR(01),      {51}
     num_lote_lanc_cont DECIMAL(3,0),  {52}
     dat_atualiz        DATE,          {53}
     empresa            CHAR(02),      {54}
     docum              CHAR(14),      {55}
     tip_docum          CHAR(02),      {56}
     sistema_gerador    CHAR(20),      {57}
     val_desc_comercial DECIMAL(15,2), {58}
     val_cons_pesquisa  DECIMAL(15,2), {59}
     val_outro_desc     DECIMAL(15,2), {60}
     val_desc_pamcard   DECIMAL(15,2), {61}
     val_credito        DECIMAL(15,2), {62}
     val_debito         DECIMAL(15,2), {63}
     val_acumulado_ant  DECIMAL(15,2), {64}
     val_honorar        DECIMAL(15,2), {65}
     pct_irrf           DECIMAL(5,2),  {66}
     val_irrf           DECIMAL(15,2), {67}
     tip_portador_pagto CHAR(01),      {68}
     dat_bilhetag       DATE,          {69}
     endereco_cobranca  CHAR(46),      {70}
     compl_end_cobranca CHAR(30),      {71}
     bairro_cobranca    CHAR(60),      {72}
     cidade_cobranca    CHAR(60),      {73}
     estado_cobranca    CHAR(20),      {74}
     cep_cobranca       CHAR(09),      {75}
     sucursal           CHAR(10),      {76}
     moeda_fatura       DECIMAL(2,0),  {77}
     filial_cobranca    CHAR(10),      {78}
     filial_admin       CHAR(10),      {79}
     tip_nota_fiscal    CHAR(02),      {80}
     tip_cli_contrato   CHAR(15),      {81}
     grupo_economico    SMALLINT,      {82}
     natureza_operacao  SMALLINT,      {83}
     cond_pagto         DECIMAL(3,0),  {84}
     endereco_etiq      CHAR(46),      {85}
     compl_end_etiq     CHAR(30),      {86}
     bairro_etiq        CHAR(60),      {87}
     cidade_etiq        CHAR(60),      {88}
     estado_etiq        CHAR(20),      {89}
     cep_etiq           CHAR(09),      {90}
     caixa_postal_etiq  CHAR(05),      {91}
     obs_endereco_etiq  CHAR(60),      {92}
     tip_contrato       CHAR(10),      {93}
     meio_envio         CHAR(10),      {94}
     roteiro            CHAR(10),      {95}
     dirigente_cliente  CHAR(05),      {96}
     geren_cta_cliente  CHAR(10),      {97}
     dirigente_negocio  CHAR(05),      {98}
     geren_cta_negocio  CHAR(10),      {99}
     ramo_ativ          CHAR(05),      {100}
     corretor           CHAR(10),      {101}
     contrato_agrupado  CHAR(01),      {102}
     empresa_item       CHAR(02),      {103}
     item_preco_minimo  CHAR(15),      {104}
     qtd_preco_minimo   SMALLINT,      {105}
     val_tot_pre_minimo DECIMAL(15,2), {106}
     sequencia          INTEGER        #utilizado apenas para sequenciar corretamente na impressao
    ) WITH NO LOG;
   WHENEVER ERROR STOP

   IF sqlca.sqlcode <> 0 THEN
      IF log0030_err_sql_tabela_duplicada() THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM t_impressao_seq
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('EXCLUSÃO','T_impressao_seq')
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql('CRIAÇÃO','t_impressao_seq')
         RETURN FALSE
      END IF
   END IF


   RETURN TRUE

END FUNCTION


#-----------------------------------#
 FUNCTION pol1377_grava_temp_erros()
#-----------------------------------#

    WHENEVER ERROR CONTINUE
    INSERT INTO t_temp_erros
           (
            docum,
            tip_docum,
            msg_erro
           )
     VALUES
           (
            mr_docum.num_docum,
            mr_docum.ies_tip_docum,
            m_msg
           )
    WHENEVER ERROR STOP

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('INCLUSÃO','T_TEMP_ERROS')
    ELSE
       LET m_tem_erros_temp  = TRUE
       LET m_erro_docum      = TRUE
       LET m_houve_erro      = TRUE
    END IF

END FUNCTION


#------------------------------#
 FUNCTION pol1377_lista_erros()
#------------------------------#
 DEFINE lr_relat_erros        RECORD
        docum                 CHAR(14),
        tip_docum             CHAR(02),
        msg_erro              CHAR(100)
                              END RECORD

 DEFINE l_achou_dados SMALLINT
 DEFINE l_msg         CHAR(200)

 LET l_achou_dados = FALSE

 IF log0280_saida_relat(18,35) IS NOT NULL THEN
    MESSAGE "Processando a extração do relatório... "

    IF g_ies_ambiente = "W" THEN
       IF p_ies_impressao = "S" THEN
          CALL log150_procura_caminho("LST") RETURNING m_caminho
          LET m_caminho = m_caminho CLIPPED, "pol1377.tmp"
          START REPORT pol1377_relat_erros TO m_caminho
       ELSE
          START REPORT pol1377_relat_erros TO p_nom_arquivo
       END IF
    ELSE
       IF p_ies_impressao = "S" THEN
          START REPORT pol1377_relat_erros TO PIPE p_nom_arquivo
       ELSE
          START REPORT pol1377_relat_erros TO p_nom_arquivo
       END IF
    END IF

    LET g_nao_exclui_par = TRUE

    LET m_tem_erros_temp = FALSE

    WHENEVER ERROR CONTINUE
      SELECT den_empresa
        INTO m_den_empresa
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR CONTINUE
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('SELEÇÃO','EMPRESA')
       RETURN
    END IF

    MESSAGE 'Listando os dados... ' ATTRIBUTE(REVERSE)

    WHENEVER ERROR CONTINUE
     DECLARE cq_relat_erros CURSOR FOR
      SELECT docum     ,
             tip_docum ,
             msg_erro
        FROM t_temp_erros
       ORDER BY docum, tip_docum, msg_erro
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('SELEÇÃO','T_TEMP_ERROS')
       RETURN
    END IF

    WHENEVER ERROR CONTINUE
     FOREACH cq_relat_erros INTO lr_relat_erros.docum     ,
                                 lr_relat_erros.tip_docum ,
                                 lr_relat_erros.msg_erro
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('SELEÇÃO','T_TEMP_ERROS')
       RETURN
    END IF

       LET l_achou_dados = TRUE
       OUTPUT TO REPORT pol1377_relat_erros ( lr_relat_erros.* )

    END FOREACH

    FREE cq_relat_erros

    FINISH REPORT pol1377_relat_erros

    IF g_ies_ambiente = "W" AND p_ies_impressao = "S" THEN
       LET g_comando = "lpdos.bat ", m_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
       RUN g_comando
    END IF

    IF l_achou_dados = FALSE  THEN
       CALL log0030_mensagem("Não existem documentos para esta seleção.","exclamation")
    ELSE
       IF p_ies_impressao <> "S" THEN
          LET l_msg = "Relatório gravado no arquivo: ",p_nom_arquivo
          CALL log0030_mensagem(l_msg, "info")
          MESSAGE "Fim de processamento."
       ELSE
          CALL log0030_mensagem("Impressão do relatório efetuada com sucesso.", "info")
          MESSAGE "Fim de processamento."
       END IF
    END IF
 ELSE
    CALL log0030_mensagem("Processamento cancelado.","Info")
    MESSAGE "Processamento cancelado."
 END IF

 END FUNCTION

#--------------------------------------#
 FUNCTION pol1377_processa_docum_banco()
#--------------------------------------#
  DEFINE l_nosso_numero    CHAR(20)

   #OS 462352
   #CASE mr_docum.cod_portador
   CASE m_portador
        WHEN 237  # BRADESCO
             LET l_nosso_numero = mr_relat.nosso_numero[01,11],
                                  mr_relat.nosso_numero[13,13]
        WHEN 275  # REAL
             LET l_nosso_numero = mr_relat.nosso_numero[01,07],
                                  mr_relat.nosso_numero[09,09]
        WHEN 356  # REAL
             LET l_nosso_numero = mr_relat.nosso_numero[01,07],
                                  mr_relat.nosso_numero[09,09]

        WHEN 33  # REAL
             LET l_nosso_numero = mr_relat.nosso_numero[01,07],
                                  mr_relat.nosso_numero[09,09]

        WHEN 341 #ITAU
           LET l_nosso_numero   = g_novo_numero

        WHEN 320  # BICBANCO
              LET l_nosso_numero = mr_relat.nosso_numero[01,06],
                                   mr_relat.nosso_numero[08,08]
        WHEN 453  # RURAL
              LET l_nosso_numero = mr_relat.nosso_numero[01,06],
                                   mr_relat.nosso_numero[08,08]
        WHEN 104
              LET l_nosso_numero = mr_relat.nosso_numero[02,10]
        OTHERWISE
              LET l_nosso_numero = mr_relat.nosso_numero #inclusive o Banco do Brasil
   END CASE

   SELECT num_docum
     FROM docum_banco
    WHERE num_docum     = mr_docum.num_docum
      AND cod_empresa   = mr_docum.cod_empresa
      AND ies_tip_docum = mr_docum.ies_tip_docum
      AND cod_portador  = mr_docum.cod_portador

   IF sqlca.sqlcode = 0 THEN
      UPDATE docum_banco SET num_titulo_banco = l_nosso_numero,
                             dat_confirm_banco = NULL,
                             ies_emis_boleto = "C"
       WHERE cod_empresa   = mr_docum.cod_empresa
         AND num_docum     = mr_docum.num_docum
         AND ies_tip_docum = mr_docum.ies_tip_docum

      IF sqlca.sqlcode = 0 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql("UPDATE","DOCUM_BANCO")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   ELSE
      INSERT INTO docum_banco VALUES(mr_docum.cod_empresa,
                                     mr_docum.num_docum,
                                     mr_docum.ies_tip_docum,
                                     mr_docum.cod_portador,
                                     0,
                                     0,
                                     l_nosso_numero,
                                     NULL,
                                     "C")
      IF sqlca.sqlcode = 0 THEN
         RETURN TRUE
      ELSE
         CALL log003_err_sql("INSERCAO","DOCUM_BANCO")
         CALL log085_transacao("ROLLBACK")
         RETURN FALSE
      END IF
   END IF
END FUNCTION

#----------------------------------#
 FUNCTION pol1377_update_par_bloq()
#----------------------------------#
  DEFINE l_portador CHAR(04)

  IF m_controle_portador IS NULL OR m_controle_portador = '    ' THEN
     LET l_portador = mr_docum.cod_portador
  ELSE
     LET l_portador = m_controle_portador
  END IF

   WHENEVER ERROR CONTINUE
     UPDATE par_bloqueto_laser
        SET num_ult_bloqueto = mr_relat.nosso_numero
      WHERE cod_empresa = mr_docum.cod_empresa  #frank prever portador representante e cedente.
        AND cod_portador = l_portador  # mr_docum.cod_portador #m_portador
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("UPDATE","PAR_BLOQUETO_LASER")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
END FUNCTION


#------------------------------------------#
 REPORT pol1377_relat_erros(lr_relat_erros)
#------------------------------------------#

   DEFINE lr_relat_erros        RECORD
           docum                 CHAR(14),
           tip_docum             CHAR(02),
           msg_erro              CHAR(100)
                                END RECORD

   OUTPUT LEFT MARGIN   0
          TOP MARGIN    0
          BOTTOM MARGIN 1
          PAGE LENGTH   66

   ORDER EXTERNAL BY lr_relat_erros.docum,
                     lr_relat_erros.tip_docum,
                     lr_relat_erros.msg_erro

   FORMAT

   PAGE HEADER
      PRINT COLUMN 001, log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;
      PRINT COLUMN 001, m_den_empresa
      PRINT COLUMN 001, 'POL1377',
            COLUMN 027, 'LISTAGEM DOS ERROS ENCONTRADOS DURANTE O PROCESSAMENTO DOS BOLETOS ',
            COLUMN 125, 'FL. ', PAGENO USING '&&&&'
      PRINT COLUMN 094, 'EXTRAIDO EM ', TODAY USING 'dd/mm/yyyy',
            COLUMN 117, 'AS ', TIME,
            COLUMN 129, 'HRS.'
      PRINT
      PRINT COLUMN 001, 'DOCUMENTO       TIPO  OBSERVACAO                                                                                                    '
      PRINT COLUMN 001, '--------------  ----  --------------------------------------------------------------------------------------------------------------'

   ON EVERY ROW
      PRINT COLUMN 001, lr_relat_erros.docum,
            COLUMN 018, lr_relat_erros.tip_docum,
            COLUMN 023, lr_relat_erros.msg_erro

   ON LAST ROW
      LET m_last_row = TRUE

   PAGE TRAILER
      IF m_last_row = TRUE THEN
         PRINT '* * * ULTIMA FOLHA * * *', log5211_termino_impressao() CLIPPED
      ELSE
         PRINT ' '
      END IF

END REPORT

#--------------------------------#
 FUNCTION pol1377_retencao_381()
#--------------------------------#
 DEFINE l_parametro_texto LIKE cre_docum_compl.parametro_texto
 DEFINE l_val_pis         LIKE cre_imp_item_781.parametro_val
 DEFINE l_val_csll        LIKE cre_imp_item_781.parametro_val
 DEFINE l_val_cofins      LIKE cre_imp_item_781.parametro_val
 DEFINE l_val_min_irrf    LIKE par_vdp_pad.par_val

 DEFINE lr_fiscal         RECORD
                             tex_hist_1 LIKE fiscal_hist.tex_hist_1,
                             tex_hist_2 LIKE fiscal_hist.tex_hist_2,
                             tex_hist_3 LIKE fiscal_hist.tex_hist_3,
                             tex_hist_4 LIKE fiscal_hist.tex_hist_4
                          END RECORD

 DEFINE l_nom_cliente    LIKE clientes.nom_cliente,
        l_pct_cofins     DECIMAL(5,2),
        l_pct_pis        DECIMAL(5,2),
        l_pct_csll       DECIMAL(5,2),
        l_pct_ret        DECIMAL(5,2),
        l_val_base       DECIMAL(17,2),
        l_pis_impresso   SMALLINT,
        l_tipo_imposto   LIKE cre_docum_compl.parametro_texto

 INITIALIZE l_pct_csll, l_pct_pis, l_pct_cofins, l_val_base, l_pct_ret, l_tipo_imposto TO NULL
 INITIALIZE m_val_csll_retencao  ,
            m_val_pis_retencao   ,
            m_val_cofins_retencao,
            m_pct_irrf           ,
            m_val_irrf           ,
            m_val_iss_retencao   ,
            m_pct_iss            ,
            m_pct_csll           ,
            m_pct_pis            ,
            m_pct_cofins         ,
            mr_relat.instrucoes4 ,
            m_instrucoes7        ,
            m_instrucoes8        TO NULL

 WHENEVER ERROR CONTINUE
 SELECT parametro_texto
   INTO l_parametro_texto
   FROM cre_docum_compl
  WHERE empresa   = mr_docum.cod_empresa #497350 p_cod_empresa
    AND docum     = mr_docum.num_docum   #mr_relat.num_docum
    AND tip_docum = mr_docum.ies_tip_docum
    AND campo     = 'tipo_imposto'
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 THEN
    LET l_parametro_texto = NULL
 END IF

 {OS 383657
 Se o documento foi gravado com esta informação, significa que
 o cálculo dos impostos foi realizado pelo VDP (conforme parâ-
 metro do VDP4942). Sendo assim, para cada tipo (Híbrido, faturamento e
 creceber) será exibida uma mensagem diferente para a impressão do bloqueto}
 IF l_parametro_texto = 'faturamento' OR l_parametro_texto = 'hibrido_fat' THEN
    LET l_val_csll   = pol1377_get_cre_docum_compl_valor('val_csll')
    LET l_val_pis    = pol1377_get_cre_docum_compl_valor('val_pis')
    LET l_val_cofins = pol1377_get_cre_docum_compl_valor('val_cofins')
 END IF

 LET l_pct_csll            = pol1377_get_cre_docum_compl_valor('pct_csll')
 LET l_pct_pis             = pol1377_get_cre_docum_compl_valor('pct_pis')
 LET l_pct_cofins          = pol1377_get_cre_docum_compl_valor('pct_cofins')
 LET m_val_csll_retencao   = pol1377_get_cre_docum_compl_valor('val_csll')
 LET m_val_pis_retencao    = pol1377_get_cre_docum_compl_valor('val_pis')
 LET m_val_cofins_retencao = pol1377_get_cre_docum_compl_valor('val_cofins')
 LET m_pct_irrf            = pol1377_get_cre_docum_compl_valor('pct_irrf')
 LET m_val_irrf            = pol1377_get_cre_docum_compl_valor('val_irrf')
 LET m_val_iss_retencao    = pol1377_get_cre_docum_compl_valor('val_iss_retencao')
 LET m_pct_iss             = pol1377_get_cre_docum_compl_valor('pct_iss')
 LET m_pct_csll            = l_pct_csll
 LET m_pct_pis             = l_pct_pis
 LET m_pct_cofins          = l_pct_cofins

 WHENEVER ERROR CONTINUE
   SELECT par_val
     INTO l_val_min_irrf
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = "val_min_ret_irrf"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0
 OR l_val_min_irrf IS NULL
 OR l_val_min_irrf = " "   THEN { 10 reais fixo conforme edital }
    LET l_val_min_irrf = 10     { informativo semanal 20/98     }
 END IF

 IF m_val_irrf <= l_val_min_irrf THEN
    LET m_val_irrf = 0
    LET m_pct_irrf = 0
 END IF

 LET l_val_base = pol1377_get_cre_docum_compl_valor('val_base')

 IF l_pct_csll         = 0 AND
    l_pct_pis          = 0 AND
    l_pct_cofins       = 0 AND
    l_val_base         = 0 AND
    m_val_iss_retencao = 0 AND
    m_pct_iss          = 0 THEN
    RETURN
 END IF

 IF l_parametro_texto = 'faturamento' OR l_parametro_texto = 'hibrido_fat' THEN

    LET mr_relat.instrucoes4 = m_texto_retencao_fat

    IF l_pct_pis > 0 THEN
       LET m_instrucoes7 = l_pct_pis USING "#&.&&", '% DE PIS ',
                           '(',l_val_pis USING '<<<<&.&&',')'
    END IF

    IF l_pct_cofins > 0 THEN
       LET m_instrucoes7 = m_instrucoes7 CLIPPED, l_pct_cofins USING "#&.&&", '% DE COFINS ',
                                                  '(',l_val_cofins USING '<<<<&.&&',')'
    END IF

    IF l_pct_csll > 0 THEN
       LET m_instrucoes7 = m_instrucoes7 CLIPPED, l_pct_csll USING "#&.&&", '% DE CSLL ',
                                                  '(',l_val_csll USING '<<<<&.&&',')'
    END IF

 ELSE
   IF l_parametro_texto = 'creceber' OR l_parametro_texto = 'hibrido_cre' THEN

      LET l_pct_ret = l_pct_csll + l_pct_pis + l_pct_cofins

      LET mr_relat.instrucoes4 = m_texto_retencao_cre1 CLIPPED," ", l_pct_ret  USING "<#&.&&", '%'
      LET mr_relat.instrucoes4 = mr_relat.instrucoes4 CLIPPED," ", m_texto_retencao_cre2

   END IF
 END IF

 IF m_val_iss_retencao > 0 AND m_pct_iss > 0 THEN #497350
    LET m_pct_desconto_base = 100

    IF NOT pol1377_verifica_desconto_base() THEN
       LET m_pct_desconto_base = 0
    END IF

    IF m_pct_desconto_base <> 0 AND m_pct_desconto_base <> 100 THEN
       LET m_instrucoes8 = 'R$ ', m_val_iss_retencao USING '<<<&.&&', ' DE ISS RETIDO ',
                           '(-', m_pct_iss USING '<&.&&','% BASE CALCULO ', m_pct_desconto_base USING '<&.&&', '% SOBRE SERVICOS)'

    ELSE
       LET m_instrucoes8 = 'R$ ', m_val_iss_retencao USING '<<<&.&&', ' DE ISS JA RETIDO (-', m_pct_iss USING '<&.&&','%)'
    END IF
 END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol1377_get_cre_docum_compl_valor(l_param)
#-----------------------------------#

  DEFINE l_param LIKE cre_docum_compl.campo
  DEFINE l_retorno LIKE cre_docum_compl.parametro_val

  WHENEVER ERROR CONTINUE
    SELECT SUM(parametro_val)
      INTO l_retorno
      FROM cre_docum_compl
     WHERE empresa   = mr_docum.cod_empresa #497350 p_cod_empresa
       AND docum     = mr_docum.num_docum   #mr_relat.num_docum
       AND tip_docum = mr_docum.ies_tip_docum
       AND campo     = l_param
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 OR l_retorno IS NULL THEN
     LET l_retorno = 0
  END IF

  RETURN l_retorno
 END FUNCTION

#-----------------------------------#
 FUNCTION pol1377_consulta_sistema()
#-----------------------------------#

 #IF pol1377_cria_temp_sistema() = FALSE THEN
 #   RETURN
 #END IF

 IF log0040_confirm(12,15,'Atualiza documentos para todos os sistemas?') THEN
    LET g_todos_sistemas = 'S'
 ELSE
    LET g_todos_sistemas = 'N'
    #CALL pol1377_carrega_sistema()
    #IF pol1377_informa_sistema() = FALSE THEN
    #   LET g_todos_sistemas = 'S'
    #END IF

    IF g_todos_sistemas = "N" THEN    #OS 451380
       IF cre0146_popup_sist_ger("CRE1055") THEN 
       ELSE
          LET g_todos_sistemas = 'S'
       END IF
    END IF

 END IF

END FUNCTION

#----------------------------------#
 FUNCTION pol1377_carrega_sistema()
#----------------------------------#
 DEFINE l_ind              SMALLINT

 LET l_ind = 1

 WHENEVER ERROR CONTINUE
 DECLARE cq_sistema CURSOR FOR
 SELECT sistema
   FROM cre_par_sist_781
  WHERE empresa = p_cod_empresa
 FOREACH cq_sistema INTO ma_sistema[l_ind].sistema
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql('FOREACH','CQ_SISTEMA')
       EXIT FOREACH
    END IF
    LET ma_sistema[l_ind].usa_sistema = 'N'
    LET l_ind = l_ind + 1
 END FOREACH
 WHENEVER ERROR STOP

 CALL SET_COUNT(l_ind-1)

END FUNCTION

#------------------------------#
 FUNCTION pol1377_busca_multa()
#------------------------------#
 DEFINE l_num_cgc_cpf      CHAR(019),
        l_ies_tip_cliente  CHAR(001),
        l_taxa_multa       DECIMAL(05,2)

 INITIALIZE l_num_cgc_cpf, l_ies_tip_cliente TO NULL

 WHENEVER ERROR CONTINUE
 SELECT num_cgc_cpf
   INTO l_num_cgc_cpf
   FROM clientes
  WHERE clientes.cod_cliente = mr_docum.cod_cliente
 WHENEVER ERROR STOP

 IF  l_num_cgc_cpf[13,16] = '0000' THEN
     LET l_ies_tip_cliente = 'F'
 ELSE
     LET l_ies_tip_cliente = 'J'
 END IF

 LET l_taxa_multa = 0

 WHENEVER ERROR CONTINUE
 DECLARE cl_multa CURSOR WITH HOLD FOR
  SELECT taxa_multa
    FROM multa_cli_atraso
   WHERE cod_empresa     = mr_docum.cod_empresa
     AND ies_tip_cliente = l_ies_tip_cliente
 WHENEVER ERROR STOP

 WHENEVER ERROR CONTINUE
 OPEN cl_multa
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    WHENEVER ERROR CONTINUE
    FETCH cl_multa INTO l_taxa_multa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
       CALL log003_err_sql('FETCH','CL_MULTA')
       RETURN 0
    END IF
 END IF

 #A multa por cliente é prioridade
 IF l_taxa_multa IS NOT NULL AND l_taxa_multa > 0 THEN
    RETURN l_taxa_multa
 END IF

 WHENEVER ERROR CONTINUE
 SELECT pct_multa
   INTO l_taxa_multa
   FROM cre_multa
  WHERE empresa  = mr_docum.cod_empresa
    AND dat_ini IN (SELECT MAX(dat_ini)
                      FROM cre_multa
                     WHERE empresa  = mr_docum.cod_empresa
                       AND dat_ini <= mr_docum.dat_emis)
 WHENEVER ERROR STOP

 IF sqlca.sqlcode <> 0 OR l_taxa_multa IS NULL THEN
    LET l_taxa_multa = 0
 END IF

 RETURN l_taxa_multa

 END FUNCTION

#--------------------------------------------------#
 FUNCTION pol1377_sigla_unidade_federacao(l_estado)
#--------------------------------------------------#
  DEFINE l_estado     CHAR(20),
         l_estado_aux CHAR(20),
         l_uf_retorno CHAR(02)

  LET l_estado_aux = UPSHIFT(l_estado CLIPPED)

  CASE l_estado_aux
     WHEN 'ACRE'
        LET l_uf_retorno = 'AC'
     WHEN 'ALAGOAS'
        LET l_uf_retorno = 'AL'
     WHEN 'AMAZONAS'
        LET l_uf_retorno = 'AM'
     WHEN 'AMAPA'
        LET l_uf_retorno = 'AP'
     WHEN 'BAHIA'
        LET l_uf_retorno = 'BA'
     WHEN 'CEARA'
        LET l_uf_retorno = 'CE'
     WHEN 'DISTRITO FEDERAL'
        LET l_uf_retorno = 'DF'
     WHEN 'ESPIRITO SANTO'
        LET l_uf_retorno = 'ES'
     WHEN 'GOIAS'
        LET l_uf_retorno = 'GO'
     WHEN 'MARANHAO'
        LET l_uf_retorno = 'MA'
     WHEN 'MINAS GERAIS'
        LET l_uf_retorno = 'MG'
     WHEN 'MATO GROSSO DO SUL'
        LET l_uf_retorno = 'MS'
     WHEN 'MATO GROSSO'
        LET l_uf_retorno = 'MT'
     WHEN 'PARA'
        LET l_uf_retorno = 'PA'
     WHEN 'PARAIBA'
        LET l_uf_retorno = 'PB'
     WHEN 'PERNAMBUCO'
        LET l_uf_retorno = 'PE'
     WHEN 'PIAUI'
        LET l_uf_retorno = 'PI'
     WHEN 'PARANA'
        LET l_uf_retorno = 'PR'
     WHEN 'RIO DE JANEIRO'
        LET l_uf_retorno = 'RJ'
     WHEN 'RIO GRANDE DO NORTE'
        LET l_uf_retorno = 'RN'
     WHEN 'RONDONIA'
        LET l_uf_retorno = 'RO'
     WHEN 'RORAIMA'
        LET l_uf_retorno = 'RR'
     WHEN 'RIO GRANDE DO SUL'
        LET l_uf_retorno = 'RS'
     WHEN 'SANTA CATARINA'
        LET l_uf_retorno = 'SC'
     WHEN 'SERGIPE'
        LET l_uf_retorno = 'SE'
     WHEN 'SAO PAULO'
        LET l_uf_retorno = 'SP'
     WHEN 'TOCANTINS'
        LET l_uf_retorno = 'TO'
     OTHERWISE
        LET l_uf_retorno = ' '
  END CASE

  RETURN l_uf_retorno

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol1377_verifica_parametro_geracao_pdf()
#-------------------------------------------------#
  DEFINE l_portador     LIKE par_bloqueto_laser.cod_portador,
         l_empresa      LIKE empresa.cod_empresa,
         l_campo        LIKE vdp_par_blqt_compl.campo

  DEFINE l_par_texto    LIKE vdp_par_blqt_compl.parametro_texto,
         l_cod_portador LIKE vdp_par_blqt_compl.portador

  DEFINE l_status       SMALLINT,
         l_mensagem     CHAR(500)

  {OS471520 - Robson Mafra
              Verifica parâmetros complementares de geração de arquivo PDF
              Verifica parâmetro do LOG2240 'Tipo da geração de boleto'
              Se parâmetro estiver PDF verifica se os parâmetros do (VDP2822)
              estão informados, se NÃO estiverem informados cancela a geração
              do arquivo PDF. }

  LET l_empresa = mr_docum.cod_empresa

  IF m_controle_portador IS NULL OR m_controle_portador = '   ' THEN
     LET l_portador = mr_docum.cod_portador
  ELSE
     LET l_portador = m_controle_portador
  END IF

  INITIALIZE m_diretorio_pdf,
             m_nom_arquivo_pdf TO NULL

  CALL pol1377_busca_parametro_complementar(l_empresa,l_portador,"diretorio_781")
     RETURNING l_status, m_diretorio_pdf
  
  IF NOT l_status THEN
     RETURN FALSE
  END IF

  IF m_diretorio_pdf IS NULL OR m_diretorio_pdf = " " THEN
     LET l_mensagem = pol1377_mensagem_parametro_nao_informado(l_empresa,l_portador,"diretorio_781")
     CALL log0030_mensagem(l_mensagem,"exclamation")
     RETURN FALSE
  END IF
  
  CALL pol1377_busca_parametro_complementar(l_empresa,l_portador,"mont_nom_arquivo_781")
     RETURNING l_status, m_nom_arquivo_pdf
     
  IF NOT l_status THEN
     RETURN FALSE
  END IF

  IF m_diretorio_pdf IS NULL OR m_diretorio_pdf = " " THEN
     LET l_mensagem = pol1377_mensagem_parametro_nao_informado(l_empresa,l_portador,"diretorio_781")
     CALL log0030_mensagem(l_mensagem,"exclamation")
     RETURN FALSE
  END IF

  RETURN TRUE

END FUNCTION

#---------------------------------------------------------------------------#
 FUNCTION pol1377_busca_parametro_complementar(l_empresa,l_portador,l_campo)
#---------------------------------------------------------------------------#
  DEFINE l_empresa      LIKE empresa.cod_empresa,
         l_portador     LIKE par_bloqueto_laser.cod_portador,
         l_campo        LIKE vdp_par_blqt_compl.campo

  DEFINE l_par_texto    LIKE vdp_par_blqt_compl.parametro_texto,
         l_cod_portador LIKE vdp_par_blqt_compl.portador,
         l_mensagem     CHAR(500)

  LET l_cod_portador = l_portador

  INITIALIZE l_par_texto TO NULL

  WHENEVER ERROR CONTINUE
    SELECT parametro_texto
      INTO l_par_texto
      FROM vdp_par_blqt_compl
     WHERE empresa   = l_empresa
       AND portador  = l_cod_portador
       AND campo     = l_campo
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     IF sqlca.sqlcode = 100 THEN
        LET l_mensagem = pol1377_mensagem_parametro_nao_informado(l_empresa,l_portador,l_campo)
        CALL log0030_mensagem(l_mensagem,"exclamation")
     ELSE
        CALL log003_err_sql("SELECT","VDP_PAR_BLQT_COMPL")
     END IF
     RETURN FALSE, l_par_texto
  END IF

  RETURN TRUE, l_par_texto

END FUNCTION

#-------------------------------------------------------------------------------#
 FUNCTION pol1377_mensagem_parametro_nao_informado(l_empresa,l_portador,l_campo)
#-------------------------------------------------------------------------------#
  DEFINE l_empresa      LIKE empresa.cod_empresa,
         l_portador     LIKE par_bloqueto_laser.cod_portador,
         l_campo        LIKE vdp_par_blqt_compl.campo

  DEFINE l_mensagem     CHAR(500)

  LET l_mensagem = "Parâmetro de Geração em PDF"

  IF l_campo = "diretorio_781" THEN
     LET l_mensagem = l_mensagem CLIPPED," 'Diretório' "
  ELSE
     IF l_campo = "mont_nom_arquivo_781" THEN
        LET l_mensagem = l_mensagem CLIPPED," 'Montagem nome arquivo' "
     END IF
  END IF

  LET l_mensagem = l_mensagem CLIPPED," não informados no VDP2822 (Manutenção dos Parâmetros de Bloquetos (Laser)) ",
                                      " para empresa ",l_empresa," e portador ",l_portador USING "<<<<","."

  RETURN l_mensagem

END FUNCTION


#---------------------------------------#
 FUNCTION pol1377_imprime_bloqueto_resumo()
#---------------------------------------#
  DEFINE l_ind2             SMALLINT,
         l_ind_item         SMALLINT,
         l_ind_item_aux     INTEGER,
         l_num_pag          SMALLINT

  DEFINE l_diretorio_config CHAR(100),
         l_diretorio_pdf    CHAR(100),
         l_nom_banco        CHAR(30),
         l_caminho_pdf      CHAR(100),
         l_caminho_imp      CHAR(200),
         l_arquivo_remove   CHAR(200)

  FOR l_num_pag = m_qtd_pag_demonst TO 1 step -1
    LET m_ind_pdf = 1
    LET ma_config[m_ind_pdf].linha = "cod_cliente = ",mr_relat.cod_cliente

    CASE mr_relat.cod_banco[1,3]
       WHEN 001 LET l_nom_banco = "bancoBrasil"
       WHEN 237 LET l_nom_banco = "bancoBradesco"
       WHEN 320 LET l_nom_banco = "bicBanco"
       WHEN 275 LET l_nom_banco = "bancoReal"
       WHEN 356 LET l_nom_banco = "bancoReal"
       WHEN 33  LET l_nom_banco = "bancoReal"
       WHEN 341 LET l_nom_banco = "bancoItau"
       WHEN 453 LET l_nom_banco = "bancoRural"
       WHEN 104 LET l_nom_banco = "bancoCaixa" #"CAIXA ECONOMICA FEDERAL"
    END CASE

    #497350 1-com demonstrativo 0-sem demonstrativo
    IF m_imprime_bloqueto = 'D' THEN
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'tipo_layout=1'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'print_verso=1'
    ELSE
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'tipo_layout=0'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'print_verso=0'
    END IF

    #LET ma_config[m_ind_pdf].linha = 'num_pagina = ', l_num_pag USING '<<<&', '/', m_qtd_pag_demonst USING '<<<&'

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "nom_banco = ",l_nom_banco #mr_relat.nom_banco
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_banco = ",mr_relat.cod_banco
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "den_empresa = ",m_den_cedente
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_agencia = ",mr_relat.cod_agencia
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_cedente = ",mr_relat.cod_cedente
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "dat_vencto = ",mr_relat.dat_vencto
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_carteira = ",mr_relat.cod_carteira
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "nosso_numero = ",mr_relat.nosso_numero
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "usu_banco = ", mr_par_bloq_laser.par_bloq_txt[11,19] #Mesmo utilizado no Uso do Banco
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "dat_emissao = ",mr_relat.dat_emissao
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "dat_proces = ",TODAY
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "num_docum = ",mr_relat.num_docum
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "esp_docum = ",mr_relat.esp_docum
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_aceite = ",mr_relat.cod_aceite
    LET m_ind_pdf = m_ind_pdf + 1

    #Chama direto a funcao troca_ponto_por_virgula pois o valor deve sempre ser numérico, nao podendo ser *****
    LET ma_config[m_ind_pdf].linha = 'valor_docum = ', pol1377_troca_ponto_por_virgula(mr_relat.val_docum, 2)

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "esp_moeda = ",mr_relat.esp_moeda
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "nom_cliente = ",mr_relat.nom_cliente
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "end_cliente = ",mr_relat_imp.endereco #mr_relat.end_cliente

    LET m_ind_pdf = m_ind_pdf + 1
    IF mr_relat_imp.complemento IS NOT NULL
    AND mr_relat_imp.complemento <> " " THEN
       LET ma_config[m_ind_pdf].linha = ma_config[m_ind_pdf].linha CLIPPED,"    COMPL.: ",mr_relat_imp.complemento
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "den_bairro = ",mr_relat_imp.bairro
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "cod_cep = ",mr_relat.cod_cep
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "den_cidade = ",mr_relat_imp.cidade

    LET m_ind_pdf = m_ind_pdf + 1
    IF mr_relat_imp.unid_feder IS NOT NULL AND mr_relat_imp.unid_feder <> " " THEN
       LET ma_config[m_ind_pdf].linha = "cod_uni_feder = ",mr_relat_imp.unid_feder
    ELSE
       LET ma_config[m_ind_pdf].linha = "cod_uni_feder = ",mr_cre_compl_docum.estado_cobranca
    END IF


    IF m_controle_portador IS NULL OR m_controle_portador = '    ' THEN
       LET m_den_cedente_repre = " "
    END IF
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "sacador_avalista = ",m_den_cedente_repre

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "num_cgc_cpf = ",mr_relat.num_cgc_cpf
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "loc_pgto_1 = ",mr_relat.loc_pgto_1
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "loc_pgto_2 = ",mr_relat.loc_pgto_2
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes1 = ",mr_relat.instrucoes1
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes2 = ",mr_relat.instrucoes2
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes3 = ",mr_relat.instrucoes3
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes4 = ",mr_relat.instrucoes4
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes5 = ",m_instrucoes7
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes6 = ",m_instrucoes8
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes7 = ",mr_relat.instrucoes5
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "instrucoes8 = ",mr_relat.instrucoes6
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "codBaixa = ", mr_par_bloq_laser.par_bloq_txt[11,19] #Mesmo utilizado no Uso do Banco


    IF l_num_pag = m_qtd_pag_demonst THEN
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = "txt_barras = ",mr_relat.txt_barras
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = "cod_barras = ",mr_relat.cod_barras
    ELSE
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = "txt_barras = "
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = "cod_barras = "
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "out_deducoes = ",mr_relat.out_deducoes

    LET m_ind_pdf = m_ind_pdf + 1
    IF m_tem_demonst_agrupado = FALSE  THEN
       IF l_num_pag = m_qtd_pag_demonst THEN
          LET ma_config[m_ind_pdf].linha = "concatenar = nao"
       ELSE
          LET ma_config[m_ind_pdf].linha = "concatenar = sim"
       END IF
    ELSE
       LET ma_config[m_ind_pdf].linha = "concatenar = sim"
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET l_caminho_pdf = m_diretorio_pdf CLIPPED,pol1377_processa_nome_arquivo()
    LET ma_config[m_ind_pdf].linha = "caminho = ",l_caminho_pdf

    #PEGA O CAMINHO ONDE SERÁ GRAVADO O ARQUIVO PDF
    LET m_caminho_diretorio_pdf = l_caminho_pdf
    #-----

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "temporario = ",m_diretorio_pdf CLIPPED

    IF m_reimpressao = TRUE THEN
       IF m_tem_demonst_agrupado = FALSE THEN
          IF m_deleta_caminho_aux <> l_caminho_pdf THEN

             LET m_deleta_caminho_aux = l_caminho_pdf

             INITIALIZE l_arquivo_remove TO NULL
             IF g_ies_ambiente <> "W" THEN
                LET l_arquivo_remove = 'chmod 664 ',l_caminho_pdf CLIPPED
             END IF
             RUN l_arquivo_remove


             INITIALIZE l_arquivo_remove TO NULL
             IF g_ies_ambiente = "W" THEN
                LET l_arquivo_remove = 'del ',l_caminho_pdf CLIPPED
             ELSE
                LET l_arquivo_remove = 'rm ',l_caminho_pdf CLIPPED
             END IF
             RUN l_arquivo_remove

          END IF
       END IF
    END IF

    #497350 Indica a impressão de demonstrativo
    IF m_imprime_bloqueto = 'D' THEN

       #Topo do demonstrativo
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'tit_documento = DEMONSTRATIVO TELERISCO Nº'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'dem_telerisco_num = ', mr_demonst.dem_telerisco_num
       LET m_ind_pdf = m_ind_pdf + 1

       #linha 1
       LET ma_config[m_ind_pdf].linha = 'txt_adm = ADM:'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_adm = ', mr_demonst.val_adm
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_emissao = EMISSAO:'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_emissao = ', mr_demonst.val_emissao USING 'DD/MM/YYYY'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_vencimento = VENCIMENTO:'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_vencimento = ', mr_demonst.val_vencimento USING 'DD/MM/YYYY'

       #Linha 2
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_raz_soc = RAZAO SOCIAL'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_raz_soc = ', mr_demonst.val_raz_soc
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_cnpj_cpf = CNPJ/CPF'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_cnpj_cpf = ', mr_demonst.val_cnpj_cpf
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_insc_est = INSCR.ESTADUAL'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_insc_est = ', mr_demonst.val_insc_est

       #Cabeçalho
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_consultas = CONSULTAS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_sem_descont = SEM DESCONTO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_com_descnt = COM DESCONTO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_total = TOTAL'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_pesquisas = PESQUISAS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_carreteiro = CARRETEIRO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_agregado = AGREGADO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_frota = FROTA'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_out_func = OUT.FUNC'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_repesquisa = REPESQUISA'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_recad_agr = RECAD.AGR'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_recad_fro = RECAD.FRO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_recad_out_f = RECAD.OUT.F'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_pracas = PRACAS'

       IF m_tem_demonst_agrupado = FALSE THEN
          FOR l_ind_item = 1 TO m_qtd_itens_por_pag
             LET l_ind_item_aux = ( m_qtd_itens_por_pag * (l_num_pag - 1) ) + l_ind_item

             IF  m_tem_premio_minimo = TRUE
             AND l_ind_item_aux = 1    THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 0, ma_tela_2[l_ind_item_aux].praca)
             ELSE
                CALL pol1377_preenche_celula_dem(l_ind_item, 0, ma_demonst_item[l_ind_item_aux].praca)
             END IF

             IF  m_tem_premio_minimo = TRUE
             AND m_classif_item      = "CONSULTAS"
             AND l_ind_item_aux      = 1 THEN
                #SE TIVER PREMIO MINIMO, QUANDO O INDICE FOR "1" ESTA CAMPO VAI ESTA = '0'
                CALL pol1377_preenche_celula_dem(l_ind_item, 1, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_sem_desconto, FALSE))
                CALL pol1377_preenche_celula_dem(l_ind_item, 2, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_com_desconto, FALSE))
                #-----
             ELSE
                IF ma_tip_consulta[l_ind_item_aux].qtd_sem_desconto > 0
                OR ma_tip_consulta[l_ind_item_aux].qtd_com_desconto > 0 THEN
                   CALL pol1377_preenche_celula_dem(l_ind_item, 1, pol1377_mostra_valor_demonst({ma_tip_consulta[l_ind_item_aux].qtd_sem_desconto}" ", FALSE))
                   CALL pol1377_preenche_celula_dem(l_ind_item, 2, pol1377_mostra_valor_demonst({ma_tip_consulta[l_ind_item_aux].qtd_com_desconto}" ", FALSE))
                ELSE
                   CALL pol1377_preenche_celula_dem(l_ind_item, 1, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_sem_desconto, FALSE))
                   CALL pol1377_preenche_celula_dem(l_ind_item, 2, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_com_desconto, FALSE))
                END IF
             END IF

             IF m_tem_premio_minimo = TRUE
             AND m_classif_item     = "CONSULTAS"
             AND l_ind_item_aux     = 1 THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_tela_2[l_ind_item_aux].qtd_preco_minimo, FALSE))
             ELSE
                IF ma_tip_consulta[l_ind_item_aux].qtd_sem_desconto > 0
                OR ma_tip_consulta[l_ind_item_aux].qtd_com_desconto > 0 THEN
                   CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_tip_consulta[l_ind_item_aux].qtd_sem_desconto +
                                                                                                ma_tip_consulta[l_ind_item_aux].qtd_com_desconto, FALSE))
                ELSE
                   CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_sem_desconto +
                                                                                                ma_demonst_item[l_ind_item_aux].qtd_com_desconto, FALSE))
                END IF
             END IF

             #SE TIVER PREMIO MINIMO, QUANDO O INDICE FOR "1" ESTA CAMPO VAI ESTA = '0'
             CALL pol1377_preenche_celula_dem(l_ind_item, 4, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_carreteiro, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 5, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_agregado, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 6, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_frota, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 7, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_out_func, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 8, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_repesquisa, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 9, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_agr, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 10, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_fro, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 11, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_out_f, FALSE))
             #-----

             IF  m_tem_premio_minimo = TRUE
             AND m_classif_item      = "PESQUISAS"
             AND l_ind_item_aux      = 1 THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 12, pol1377_mostra_valor_demonst(ma_tela_2[l_ind_item_aux].qtd_preco_minimo, FALSE))
             ELSE
                CALL pol1377_preenche_celula_dem(l_ind_item, 12, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_carreteiro  +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_agregado    +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_frota       +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_out_func    +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_repesquisa  +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_recad_agr   +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_recad_fro   +
                                                                                              ma_demonst_item[l_ind_item_aux].qtd_recad_out_f, FALSE))
             END IF
          END FOR
       END IF

       IF m_tem_demonst_agrupado = TRUE THEN
          FOR l_ind_item = 1 TO m_qtd_itens_por_pag
             LET l_ind_item_aux = ( m_qtd_itens_por_pag * (l_num_pag - 1) ) + l_ind_item

             #APRESENTA A PRAÇA
             IF  m_tem_premio_minimo = TRUE
             AND l_ind_item_aux      = 1 THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 0, ma_tela_2[l_ind_item_aux].praca)
             ELSE
                CALL pol1377_preenche_celula_dem(l_ind_item, 0, ma_total_demonst_p_bloqueto[l_ind_item_aux].praca)
             END IF
             #-----

             #SE TIVER PREMIO MINIMO, QUANDO O INDICE FOR "1" ESTA CAMPO VAI ESTA = '0'
             CALL pol1377_preenche_celula_dem(l_ind_item, 1, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_sem_desconto, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 2, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_com_desconto, FALSE))
             #-----

             IF  m_tem_premio_minimo = TRUE
             AND m_classif_item      = "CONSULTAS"
             AND l_ind_item_aux      = 1 THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_tela_2[l_ind_item_aux].qtd_preco_minimo, FALSE))
             ELSE
                CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_sem_desconto +
                                                                                             ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_com_desconto, FALSE))
             END IF

             #SE TIVER PREMIO MINIMO, QUANDO O INDICE FOR "1" ESTA CAMPO VAI ESTA = '0'
             CALL pol1377_preenche_celula_dem(l_ind_item, 4, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_carreteiro, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 5, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_agregado, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 6, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_frota, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 7, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_out_func, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 8, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_repesquisa, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 9, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_agr, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 10, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_fro, FALSE))
             CALL pol1377_preenche_celula_dem(l_ind_item, 11, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_out_f, FALSE))
             #-----

             IF  m_tem_premio_minimo = TRUE
             AND m_classif_item      = "PESQUISAS"
             AND l_ind_item_aux      = 1 THEN
                CALL pol1377_preenche_celula_dem(l_ind_item, 12, pol1377_mostra_valor_demonst(ma_tela_2[l_ind_item_aux].qtd_preco_minimo, FALSE))
             ELSE
                CALL pol1377_preenche_celula_dem(l_ind_item, 12, pol1377_mostra_valor_demonst(ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_carreteiro  +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_agregado    +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_frota       +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_out_func    +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_repesquisa  +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_agr   +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_fro   +
                                                                                              ma_total_demonst_p_bloqueto[l_ind_item_aux].qtd_recad_out_f, FALSE))
             END IF
          END FOR
       END IF

       #TOTAIS DO DEMONSTRATIVO
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 0, 'TOTAIS')
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 0, 'VALOR  TOTAL')

       #SÓ IMPRIME O TOTAL NA ÚLTIMA PAGINA
       IF l_num_pag = m_qtd_pag_demonst THEN
          IF  m_tem_premio_minimo = TRUE
          AND m_classif_item      = "CONSULTAS" THEN
             LET mr_demonst_totais.val_sem_desconto = 0
             LET mr_demonst_totais.val_com_desconto = 0

             LET mr_demonst_totais.qtd_sem_desconto = 0
             LET mr_demonst_totais.qtd_com_desconto = 0
          END IF

          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 1, pol1377_mostra_valor_demonst((mr_demonst_totais.qtd_sem_desconto),FALSE))

          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 1, pol1377_troca_ponto_por_virgula((mr_demonst_totais.val_sem_desconto),2))

          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 2, pol1377_mostra_valor_demonst((mr_demonst_totais.qtd_com_desconto),FALSE))

          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 2, pol1377_troca_ponto_por_virgula((mr_demonst_totais.val_com_desconto),2))

          IF  m_tem_premio_minimo = TRUE
          AND m_classif_item      = "CONSULTAS" THEN
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 3, pol1377_mostra_valor_demonst(mr_cre_compl_docum.qtd_preco_minimo,FALSE))
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 3, pol1377_troca_ponto_por_virgula(mr_cre_compl_docum.val_tot_pre_minimo,2))
          ELSE
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 3, pol1377_mostra_valor_demonst((mr_demonst_totais.qtd_sem_desconto +
                                                                                                        mr_demonst_totais.qtd_com_desconto),FALSE))

             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 3, pol1377_troca_ponto_por_virgula((mr_demonst_totais.val_sem_desconto +
                                                                                                           mr_demonst_totais.val_com_desconto),2))
          END IF

          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 4, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_carreteiro,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 4, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_carreteiro,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 5, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_agregado,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 5, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_agregado,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 6, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_frota,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 6, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_frota,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 7, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_out_func,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 7, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_out_func,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 8, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_repesquisa,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 8, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_repesquisa,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 9, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_agr,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 9, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_agr,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 10, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_fro,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 10, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_fro,2))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 11, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_out_f,FALSE))
          CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 11, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_out_f,2))

          IF  m_tem_premio_minimo = TRUE
          AND m_classif_item      = "PESQUISAS" THEN
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 12, pol1377_mostra_valor_demonst(mr_cre_compl_docum.qtd_preco_minimo,FALSE))
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 12, pol1377_troca_ponto_por_virgula(mr_cre_compl_docum.val_tot_pre_minimo,2))
          ELSE
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 1, 12, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_carreteiro +
                                                                                                        mr_demonst_totais.qtd_agregado   +
                                                                                                        mr_demonst_totais.qtd_frota      +
                                                                                                        mr_demonst_totais.qtd_out_func   +
                                                                                                        mr_demonst_totais.qtd_repesquisa +
                                                                                                        mr_demonst_totais.qtd_recad_agr  +
                                                                                                        mr_demonst_totais.qtd_recad_fro  +
                                                                                                        mr_demonst_totais.qtd_recad_out_f,FALSE))
             CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag + 2, 12, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_carreteiro +
                                                                                                           mr_demonst_totais.val_agregado   +
                                                                                                           mr_demonst_totais.val_frota      +
                                                                                                           mr_demonst_totais.val_out_func   +
                                                                                                           mr_demonst_totais.val_repesquisa +
                                                                                                           mr_demonst_totais.val_recad_agr  +
                                                                                                           mr_demonst_totais.val_recad_fro  +
                                                                                                           mr_demonst_totais.val_recad_out_f,2))
          END IF
       END IF

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_recibo_do = RECIBO DO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_sacado   = SACADO'

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_extra = DEBITO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_extra = ', pol1377_mostra_valor_bloqueto((mr_tip_consulta.val_sem_desconto + mr_tip_consulta.val_com_desconto), l_num_pag, FALSE)

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_cedente = CEDENTE'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_cedente = ', mr_demonst.val_cedente
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_age_cod_ced = AGENCIA/COD.CEDENTE'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_age_cod_ced = ', mr_demonst.val_age_cod_ced
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_nosso_num = NOSSO NUMERO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_nosso_num = ', mr_demonst.val_nosso_num
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_cons_pesq = TOTAL CONS+PESQ'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_cons_pesq = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_cons_pesq, l_num_pag, FALSE)

       LET m_ind_pdf = m_ind_pdf + 1
       IF mr_demonst.val_outros_desc > 0 THEN #mr_cre_compl_docum.val_outro_desc
          LET ma_config[m_ind_pdf].linha = 'txt_outros_desc = (-)CONSULTAS GRATIS'
       ELSE
          LET ma_config[m_ind_pdf].linha = 'txt_outros_desc = (-)OUTROS DESC'
       END IF

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_outros_desc = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_outros_desc, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_desconto = (-)DESCONTO'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_desconto = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_desconto, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_val_acom = (+) VLR ACUMULADO ANT'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_val_acom = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_val_acom, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_iss = ISS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_iss_1 = (', pol1377_mostra_valor_bloqueto(mr_demonst.val_iss_1, l_num_pag, TRUE) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_iss_2 = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_iss_2, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_pis = PIS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_pis_1 = (', pol1377_mostra_valor_bloqueto(mr_demonst.val_pis_1, l_num_pag, TRUE) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_pis_2 = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_pis_2, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_confins = COFINS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_confins_1 = (', pol1377_mostra_valor_bloqueto(mr_demonst.val_confins_1, l_num_pag, TRUE) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_confins_2 = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_confins_2, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_csll = CSLL'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_csll_1 = (', pol1377_mostra_valor_bloqueto(mr_demonst.val_csll_1, l_num_pag, TRUE) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_csll_2 = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_csll_2, l_num_pag, FALSE)
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_sub_total = SUB TOTAL'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_sub_total = ', pol1377_mostra_valor_bloqueto( mr_demonst.val_sub_total ,
                                                                                           l_num_pag                ,
                                                                                           FALSE                    )
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_irrf = IRRF'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_irrf_1 = (', pol1377_mostra_valor_bloqueto(mr_demonst.val_irrf_1, l_num_pag, TRUE) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_irrf_2 = ', pol1377_mostra_valor_bloqueto(mr_demonst.val_irrf_2, l_num_pag, FALSE)

       #::: Valor de INSS
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_inss = INSS'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_inss_1 = (', pol1377_mostra_valor_bloqueto( mr_demonst.val_inss_1, l_num_pag, TRUE ) CLIPPED, '%)'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_inss_2 = ', pol1377_mostra_valor_bloqueto( mr_demonst.val_inss_2, l_num_pag, FALSE )
       #:::

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_total_fat = TOTAL DESTA FATURA'
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_total_fat = ', pol1377_mostra_valor_bloqueto( mr_demonst.val_total_fat ,
                                                                                           l_num_pag                ,
                                                                                           FALSE                    )

       IF m_verifica_tip_consulta_pdf = TRUE THEN
          IF m_texto_compl IS NULL
          OR m_texto_compl = " " THEN
             LET m_texto_compl = "*Este servico nao consta no relatorio."
          END IF
       END IF

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'texto_comp = ', m_texto_compl

       #------------verso do boleto
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'aling_aviso = ', mr_demonst.aling_aviso
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_aviso_1 = ', mr_demonst.txt_aviso_1
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_aviso_2 = ', mr_demonst.txt_aviso_2
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_aviso_3 = ', mr_demonst.txt_aviso_3
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'txt_aviso_4 = ', mr_demonst.txt_aviso_4


       #------------dados cedente
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_v_cedente = ', mr_demonst.val_v_cedente
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_v_end_cedente = ', mr_demonst.val_v_end_cedente
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_v_comp_cedente = ', mr_demonst.val_v_comp_cedente
       #------------dados cobrança
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_dados_cobranca = ', mr_demonst.val_dados_cobranca CLIPPED,
                                        '    ', l_num_pag USING '<<<&', '/', m_qtd_pag_demonst USING '<<<&'

       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_end_1_cob = ', mr_demonst.val_end_1_cob
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_end_2_cob = ', mr_demonst.val_end_2_cob
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_end_3_cob = ', mr_demonst.val_end_3_cob
       LET m_ind_pdf = m_ind_pdf + 1
       LET ma_config[m_ind_pdf].linha = 'val_end_4_cob = ', mr_demonst.val_end_4_cob

    END IF
    #Fim 497350

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'cod_cip = ',mr_demonst.cod_cip

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'num_pagina = ', m_total_pag_aux USING '<<<&', '/', m_total_pag USING '<<<&'
    LET m_total_pag_aux = m_total_pag_aux - 1

    IF m_reimpressao = FALSE THEN
       LET l_diretorio_config = m_diretorio_pdf CLIPPED, m_seq_geral_boleto USING "<<<<<", "configuracao.",p_user CLIPPED,".txt"
       LET m_seq_geral_boleto = m_seq_geral_boleto + 1
    ELSE
       LET l_diretorio_config = m_diretorio_pdf CLIPPED, "configuracao.",p_user CLIPPED,".txt"
    END IF

    CALL pol1377_grava_sequencia_carta( l_diretorio_config ,
                                        l_caminho_pdf      ,
                                        "B"                )

    CALL log4070_channel_open_file("configuracao",l_diretorio_config,"w")

    CALL log4070_channel_set_delimiter("configuracao","")

    FOR l_ind2=1 TO m_ind_pdf
       CALL log4070_channel_write("configuracao",ma_config[l_ind2].linha)
    END FOR

    CALL log4070_channel_close("configuracao")

    INITIALIZE l_arquivo_remove TO NULL
    IF g_ies_ambiente <> "W" THEN
       LET l_arquivo_remove = 'chmod 664 ',l_diretorio_config CLIPPED
    END IF
    RUN l_arquivo_remove

    IF m_reimpressao = TRUE  THEN
       LET g_comando = "java  BoletoBancarioPamcary ",l_diretorio_config

       RUN g_comando
    END IF

  END FOR

  WHENEVER ERROR CONTINUE
    UPDATE t_caminho_boleto
       SET impressao = "S"
     WHERE caminho = l_diretorio_config
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     CALL log003_err_sql("UPDATE","T_CAMINHO_BOLETO")
  END IF

  IF m_reimpressao = TRUE THEN
     IF p_ies_impressao = "S" THEN

        LET l_caminho_imp = 'pdftops ', l_caminho_pdf CLIPPED, ' - | lpr -P' CLIPPED, g_cod_impressora

        IF m_imprime_bloqueto = 'D' THEN
           LET l_caminho_imp = l_caminho_imp CLIPPED, ' -o sides=two-sided-long-edge'
        END IF

        RUN l_caminho_imp
     END IF
  END IF

  RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol1377_preenche_celula_dem(l_x, l_y, l_valor)
#--------------------------------#
  DEFINE l_x INTEGER,
         l_y INTEGER,
         l_valor CHAR(40)

  LET m_ind_pdf = m_ind_pdf + 1
  LET ma_config[m_ind_pdf].linha = 'linha_dados[', l_x USING '<&', ',', l_y USING '<&', '] = ', l_valor

 END FUNCTION

#--------------------------------#
 FUNCTION pol1377_mostra_valor_demonst(l_valor, l_ies_total)
#--------------------------------#
  DEFINE l_valor     DECIMAL(16,2),
         l_ies_total SMALLINT

  IF l_ies_total THEN
     RETURN l_valor USING '############&'
  ELSE
     IF (l_valor = 0) OR l_valor IS NULL THEN
        RETURN ' '
     ELSE
        RETURN l_valor USING '############&'
     END IF
  END IF

 END FUNCTION

#--------------------------------#
 FUNCTION pol1377_mostra_valor_bloqueto(l_valor, l_num_pag, l_ies_perc)
#--------------------------------#
  {Parâmetros:
   Valor a ser impresso;
   Número da página: para demonstrativos com mais de uma página, imprime o valor somente no bloqueto
                     da última página. Nos outros, imprime ******;
   Indicador de percentual: indica se o campo a ser impresso é percentual. Passado true no caso da
                            impressão dos % dos impostos. Assim, independente da página será impresso
                            o percentual do imposto. Já para o valor, só será impresso na última página.}

  DEFINE l_valor DECIMAL(16,2),
         l_num_pag SMALLINT,
         l_ies_perc SMALLINT

  IF (l_valor IS NULL) THEN
     RETURN ' '
  ELSE
     IF (l_num_pag = m_qtd_pag_demonst) OR (l_ies_perc = true) THEN
        RETURN pol1377_troca_ponto_por_virgula(l_valor,2) #Fixo 2 decimais para valor
     ELSE
        RETURN '******'
     END IF
  END IF

 END FUNCTION

#--------------------------------#
 FUNCTION pol1377_troca_ponto_por_virgula(l_valor, l_qtd_decimais)
#--------------------------------#
  #Para substituir o ponto(.) por virgula

  DEFINE l_valor            DECIMAL,
         l_qtd_decimais     SMALLINT,
         l_ind              SMALLINT,
         l_decimal          CHAR(17),
         l_decimal2         CHAR(17),
         l_formato          CHAR(17)


  LET l_formato = '############&.'
  FOR l_ind = 1 TO l_qtd_decimais
    LET l_formato = l_formato CLIPPED, '&'
  END FOR

  LET l_decimal2 = ''
  LET l_decimal = l_valor USING l_formato

  FOR l_ind = 1 TO 17
    IF l_decimal[l_ind] <> ' ' THEN
       IF l_decimal[l_ind] = '.' THEN
          LET l_decimal[l_ind] = ','
       END IF

       LET l_decimal2 = l_decimal2 CLIPPED, l_decimal[l_ind]
    END IF
  END FOR

  RETURN l_decimal2

 END FUNCTION

#----------------------------------------#
 FUNCTION pol1377_processa_nome_arquivo()
#----------------------------------------#
  DEFINE l_nom_arquivo  CHAR(80)

  DEFINE l_cont            SMALLINT,
         l_tamanho_nome    SMALLINT,
         l_inicio_palavra  SMALLINT,
         l_inicio_palavra2 SMALLINT,
         l_fim_palavra     SMALLINT,
         l_palavra         CHAR(10)

  LET l_nom_arquivo = " "

  LET l_tamanho_nome   = LENGTH(m_nom_arquivo_pdf)
  LET l_inicio_palavra = 1

  FOR l_cont=1 TO l_tamanho_nome
     {A mairo palavra possivel é DOCUMENTO com 9 letras, considerar 2 espaços + 2 sinais}
     IF (l_cont - l_inicio_palavra) > 13 THEN
        RETURN FALSE
     ELSE
        IF m_nom_arquivo_pdf[l_cont] = "+"
        OR l_cont = l_tamanho_nome THEN
           IF m_nom_arquivo_pdf[l_inicio_palavra] = "+" THEN
              LET l_inicio_palavra2 = l_inicio_palavra + 1
           ELSE
              LET l_inicio_palavra2 = l_inicio_palavra
           END IF

           IF m_nom_arquivo_pdf[l_cont] = "+" THEN
              LET l_fim_palavra = l_cont - 1
           ELSE
              LET l_fim_palavra = l_cont
           END IF

           IF l_inicio_palavra2 > l_fim_palavra THEN
              RETURN FALSE
           END IF

           LET l_palavra = m_nom_arquivo_pdf[l_inicio_palavra2,l_fim_palavra]
           LET l_inicio_palavra = l_cont

           CALL pol1377_trim(l_palavra) RETURNING l_palavra

           CASE l_palavra
              WHEN "EMPRESA"
                 LET l_nom_arquivo = l_nom_arquivo CLIPPED,mr_docum.cod_empresa
              WHEN "DOCUMENTO"
                 LET l_nom_arquivo = l_nom_arquivo CLIPPED,mr_relat.num_docum
              WHEN "TIPO"
                 LET l_nom_arquivo = l_nom_arquivo CLIPPED,mr_docum.ies_tip_docum
              WHEN "CLIENTE"
                 LET l_nom_arquivo = l_nom_arquivo CLIPPED,mr_docum.cod_cliente
              WHEN "PORTADOR"
                 LET l_nom_arquivo = l_nom_arquivo CLIPPED,mr_relat.cod_banco[1,3]
           END CASE
        END IF
     END IF
  END FOR

  LET l_nom_arquivo = l_nom_arquivo CLIPPED,".pdf"

  RETURN l_nom_arquivo

END FUNCTION

#--------------------------------#
 FUNCTION pol1377_trim(l_palavra)
#--------------------------------#
  DEFINE l_palavra  CHAR(10),
         l_tamanho  SMALLINT,
         l_inicio   SMALLINT,
         l_cont     SMALLINT

  {Função retira espaços brancos da esquerda}

  LET l_inicio  = 1
  LET l_tamanho = LENGTH(l_palavra)

  FOR l_cont = 1 TO l_tamanho

     IF l_palavra[l_inicio] IS NULL
     OR l_palavra[l_inicio] = " " THEN
        LET l_inicio = l_inicio + 1
     ELSE
        EXIT FOR
     END IF

  END FOR

  IF l_inicio > l_tamanho THEN
     RETURN " "
  END IF

  RETURN l_palavra[l_inicio,l_tamanho]

END FUNCTION

#-------------------------------------------------#
 FUNCTION pol1377_calcula_qtd_itens_demonstrativo(l_parametro)
#-------------------------------------------------#
 #O CALCULO É REALIZADO DE DUAS FORMAS DIFERENTES:
 #SE O PARAMETRO ESTIVER FALSE, SERÁ IMPRESSO O DEMOSTRATIVO DETALHADO,
 #E NO DEMONSTRATIVO RESUMO SERÁ IMPRESSO SOMENTE OS TOTAIS DE CADA DETALHADO.
 #DESTA FORMA É REALIZADO O SELECT COUNT(DISTINCT ctr_titulo_item.cnpj_ctr_agrupado)

 #SE O PARAMETRO ESTIVER TRUE, SERÁ IMPRESSO SOMENTE O DEMONSTRATIVO RESUMO.
 #SELECT COUNT(DISTINCT ctr_titulo_item.praca)

 DEFINE l_parametro SMALLINT

 IF m_imprime_bloqueto <> 'D' THEN
    LET m_qtd_pag_demonst = 1
    RETURN
 END IF

 IF l_parametro = FALSE THEN
    WHENEVER ERROR CONTINUE
       SELECT COUNT(DISTINCT ctr_titulo_item.cnpj_ctr_agrupado)
         INTO m_qtd_itens_demonst
         FROM ctr_titulo_item, cre_classif_item
        WHERE ctr_titulo_item.empresa   = mr_docum.cod_empresa
          AND ctr_titulo_item.titulo     = mr_docum.num_docum
          AND ctr_titulo_item.tip_titulo = mr_docum.ies_tip_docum
          AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
          AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
          AND cre_classif_item.empresa    = ctr_titulo_item.empresa
          AND cre_classif_item.item       = ctr_titulo_item.item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
       CALL log003_err_sql('SELEÇÃO','ctr_titulo_item2')
       LET m_qtd_pag_demonst = 1
       RETURN
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
       SELECT COUNT(DISTINCT ctr_titulo_item.praca)
         INTO m_qtd_itens_demonst
         FROM ctr_titulo_item, cre_classif_item
        WHERE ctr_titulo_item.empresa   = mr_docum.cod_empresa
          AND ctr_titulo_item.titulo     = mr_docum.num_docum
          AND ctr_titulo_item.tip_titulo = mr_docum.ies_tip_docum
          AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
          AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
          AND cre_classif_item.empresa    = ctr_titulo_item.empresa
          AND cre_classif_item.item       = ctr_titulo_item.item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> NOTFOUND THEN
       CALL log003_err_sql('SELEÇÃO','ctr_titulo_item2')
       LET m_qtd_pag_demonst = 1
       RETURN
    END IF
 END IF

 #EFETUA OS TRATAMENTOS PARA PREMIO MINIMO.
 CALL pol1377_total_itens_por_demonstrativo()
 IF  mr_cre_compl_docum.qtd_preco_minimo > 0
 AND mr_cre_compl_docum.qtd_preco_minimo >= m_total_itens_demonst THEN
    LET m_qtd_itens_demonst = m_qtd_itens_demonst + 1
 END IF

 #AJUSTADO
 IF m_qtd_itens_demonst > 35 THEN
    LET m_qtd_pag_demonst = log_truncate_value((m_qtd_itens_demonst / m_qtd_itens_por_pag), 0) + 1
 ELSE
    LET m_qtd_pag_demonst = 1
 END IF


 END FUNCTION

#--------------------------------#
 FUNCTION pol1377_get_den_praca(l_item_praca)
#--------------------------------#
  DEFINE l_item_praca LIKE cre_itcompl_docum.praca
  DEFINE l_cod_est   CHAR(02),
         l_den_praca CHAR(28)

  WHENEVER ERROR CONTINUE
    SELECT codest, lcnome[1,28]
      INTO l_cod_est, l_den_praca
      FROM cep_loc
     WHERE codloc = l_item_praca
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     LET l_den_praca = l_item_praca
  ELSE
     IF (l_cod_est IS NOT NULL) AND (l_cod_est <> ' ') THEN
        LET l_den_praca = l_den_praca CLIPPED, '-', l_cod_est
     END IF
  END IF

  RETURN l_den_praca

 END FUNCTION

#---------------------------------------------#
 FUNCTION pol1377_sist_gerad_ordena_impressao()
#---------------------------------------------#
 DEFINE l_ordena_impressao LIKE cre_par_sist_781.ordena_impressao
 DEFINE l_count            SMALLINT
 DEFINE l_sql_stmt         CHAR(3000)
 DEFINE l_sql_where        CHAR(5000)

 LET l_count        = 0
 LET m_total_ordena = 0

 LET l_sql_stmt = " SELECT cre_par_sist_781.ordena_impressao ",
                  " FROM cre_par_sist_781 "

 LET l_sql_where = " WHERE cre_par_sist_781.ordena_impressao = ""S"" "

 IF mr_selecao.todas_empresas = 'N' THEN
    WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_count
        FROM cre0270_empresa
       WHERE cre0270_empresa.nom_usuario  = p_user
         AND cre0270_empresa.cod_programa = p_cod_programa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CRE0270_EMPRESA")
       RETURN FALSE
    END IF

    IF l_count > 0 THEN
       LET l_sql_stmt  = l_sql_stmt CLIPPED, ", cre0270_empresa"
       LET l_sql_where = l_sql_where CLIPPED,
          " AND cre0270_empresa.nom_usuario  = '",p_user,"'",
          " AND cre0270_empresa.cod_programa = '",p_cod_programa,"'",
          " AND cre_par_sist_781.empresa     = cre0270_empresa.cod_empresa "
    END IF
 END IF

 IF g_todos_sistemas = 'N' THEN
    LET l_count = 0

    WHENEVER ERROR CONTINUE
      SELECT COUNT(*)
        INTO l_count
        FROM cre_popup_sist_781
       WHERE cre_popup_sist_781.usuario      = p_user
         AND cre_popup_sist_781.sit_sistema  = "S"
         AND cre_popup_sist_781.programa     = p_cod_programa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CRE_POPUP_SIST_781")
       RETURN FALSE
    END IF


    IF l_count > 0 THEN
       LET l_sql_stmt  = l_sql_stmt CLIPPED, ", cre_popup_sist_781 "
       LET l_sql_where = l_sql_where CLIPPED,
          " AND cre_par_sist_781.sistema        = cre_popup_sist_781.sistema ",
          " AND cre_popup_sist_781.usuario      = '",p_user,"' ",
          " AND cre_popup_sist_781.sit_sistema  = ""S"" ",
          " AND cre_popup_sist_781.programa     = '",p_cod_programa,"'"
    END IF
 END IF

 LET l_sql_stmt = l_sql_stmt CLIPPED, l_sql_where CLIPPED

 WHENEVER ERROR CONTINUE
  PREPARE var_query_ordena FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("PREPARE","VAR_QUERY_ORDENA")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_ordena_impressao CURSOR FOR var_query_ordena
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","CQ_ORDENA_IMPRESSAO")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_ordena_impressao INTO l_ordena_impressao
 WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","CQ_ORDENA_IMPRESSAO")
       RETURN FALSE
    END IF

    LET m_total_ordena = m_total_ordena + 1

 END FOREACH

 WHENEVER ERROR CONTINUE
    CLOSE cq_ordena_impressao
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("CLOSE","CQ_ORDENA_IMPRESSAO")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
     FREE cq_ordena_impressao
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("FREE","CQ_ORDENA_IMPRESSAO")
    RETURN FALSE
 END IF

 RETURN TRUE

 END FUNCTION

#------------------------------------------#
 FUNCTION pol1377_insere_informacao_carta()
#------------------------------------------#
 DEFINE l_nom_cliente        LIKE clientes.nom_reduzido,
        l_compentencia       CHAR(06),
        l_mes_extenso        CHAR(15),
        l_nota_fiscal        CHAR(06)

 DEFINE l_nfe LIKE obf_nf_eletr_emit.nf_eletronica
 DEFINE l_ano     CHAR(04)
 DEFINE l_ano_aux CHAR(02)

 IF NOT pol1377_sistema_gerador_imprime_carta(mr_docum.cod_empresa) THEN
    RETURN TRUE #Não é erro, apenas o sistema gerador não imprime carta
 END IF

 WHENEVER ERROR CONTINUE
   SELECT nom_reduzido
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = mr_docum.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'CLIENTE ', mr_docum.cod_cliente,' NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN FALSE
 END IF

 LET l_mes_extenso = pol1377_mes_extenso(mr_docum.dat_competencia)

 IF l_mes_extenso IS NOT NULL THEN
    LET l_ano = YEAR(mr_docum.dat_competencia) USING '&&&&'
    LET l_ano_aux = l_ano[3,4]
    LET l_compentencia = l_mes_extenso CLIPPED,'/', l_ano_aux
 END IF

 IF mr_docum.ies_tip_docum_orig = 'NF' THEN
    IF mr_docum.num_docum_origem[1,6] IS NULL OR
       mr_docum.num_docum_origem[1,6] = 0   THEN
       LET l_nota_fiscal = NULL
       LET l_nfe         = NULL
    ELSE
       LET l_nota_fiscal = mr_docum.num_docum_origem #[1,6]
       LET l_nota_fiscal = l_nota_fiscal USING "&&&&&&"

       CALL pol1377_busca_nf_eletronica( mr_docum.cod_empresa   ,
                                         l_nota_fiscal          ,
                                         mr_docum.ies_serie_fat )
       RETURNING l_nfe

    END IF
 ELSE
    IF mr_docum.num_docum_origem[1,6] IS NULL  THEN
       LET l_nota_fiscal = 0
       LET l_nfe         = NULL
    ELSE
       LET l_nota_fiscal = mr_docum.num_docum_origem
       LET l_nota_fiscal = l_nota_fiscal USING "&&&&&&"
       LET l_nfe         = NULL
    END IF

 END IF

 #-- Grava informações temporárias para listagem

 IF mr_docum.ies_tip_docum_orig IS NULL
 OR mr_docum.ies_tip_docum_orig = "" THEN
    LET mr_docum.ies_tip_docum_orig = "NF"
 END IF

 WHENEVER ERROR CONTINUE
 INSERT INTO t_carta ( docum              ,
                       vencimento         ,
                       nome_cliente       ,
                       competencia        ,
                       empresa            ,
                       nota_fiscal        ,
                       ies_tip_docum_orig ,
                       nfe                ,
                       valor              )
              VALUES ( mr_docum.num_docum          ,
                       mr_docum.dat_vencto_s_desc  ,
                       l_nom_cliente               ,
                       l_compentencia              ,
                       mr_docum.cod_empresa        ,
                       l_nota_fiscal               ,
                       mr_docum.ies_tip_docum_orig ,
                       l_nfe                       ,
                       mr_docum.val_saldo          )
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'ERRO NA INCLUSAO DAS INFORMACOES DA CARTA.'
    CALL pol1377_grava_temp_erros()
    RETURN FALSE
 END IF

 #-- Grava informações de numeração efetiva
 WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cre_docum_compl
    WHERE empresa   = mr_docum.cod_empresa
      AND docum     = mr_docum.num_docum
      AND tip_docum = mr_docum.ies_tip_docum
      AND campo     = 'carta_envio'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    RETURN TRUE
 END IF

 IF (m_meio_envio_anterior          <> mr_cre_compl_docum.meio_envio
 OR  m_roteiro_anterior             <> mr_cre_compl_docum.roteiro
 OR  m_filial_cobranca_anterior     <> mr_cre_compl_docum.filial_cobranca) THEN


    LET m_meio_envio_anterior      = mr_cre_compl_docum.meio_envio
    LET m_roteiro_anterior         = mr_cre_compl_docum.roteiro
    LET m_filial_cobranca_anterior = mr_cre_compl_docum.filial_cobranca
    LET m_dat_competencia_ant      = mr_docum.dat_competencia

    WHENEVER ERROR CONTINUE
      SELECT MAX(parametro_val)
        INTO m_sequencia_carta
        FROM cre_docum_compl
       WHERE campo                = 'carta_envio'
         AND MONTH(parametro_dat) = MONTH(mr_docum.dat_competencia)
         AND YEAR(parametro_dat)  = YEAR(mr_docum.dat_competencia)
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       LET m_msg = 'ERRO NA SELECAO DA SEQUENCIA DA CARTA.'
       CALL pol1377_grava_temp_erros()
       RETURN FALSE
    END IF

    IF m_sequencia_carta IS NULL THEN
       LET m_sequencia_carta = 0
    END IF

    LET m_sequencia_carta = m_sequencia_carta + 1
 END IF

 WHENEVER ERROR CONTINUE
 INSERT INTO cre_docum_compl (empresa      ,
                              docum        ,
                              tip_docum    ,
                              campo        ,
                              parametro_val,
                              parametro_dat)
                      VALUES (mr_docum.cod_empresa    ,
                              mr_docum.num_docum      ,
                              mr_docum.ies_tip_docum  ,
                              'carta_envio'           ,
                              m_sequencia_carta       ,
                              mr_docum.dat_competencia)
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    WHENEVER ERROR CONTINUE
    DELETE FROM t_carta
     WHERE docum = mr_docum.num_docum
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       #não mostra erro, já vai retornar falso
    END IF

    LET m_msg = 'ERRO NA INCLUSAO DA SEQUENCIA DA CARTA.'
    CALL pol1377_grava_temp_erros()
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#----------------------------------------------------------#
 FUNCTION pol1377_busca_nf_eletronica( l_cod_empresa      ,
                                       l_num_docum_origem ,
                                       l_ies_serie_fat    )
#----------------------------------------------------------#
 DEFINE l_cod_empresa      LIKE docum.cod_empresa
 DEFINE l_num_docum_origem LIKE docum.num_docum_origem
 DEFINE l_ies_serie_fat    LIKE docum.ies_serie_fat
 DEFINE l_nf_eletronica    LIKE obf_nf_eletr_emit.nf_eletronica

 WHENEVER ERROR CONTINUE
   SELECT nf_eletronica
     INTO l_nf_eletronica
     FROM obf_nf_eletr_emit
    WHERE empresa       = l_cod_empresa
      AND nf_serv_logix = l_num_docum_origem
      AND serie_nf_serv = l_ies_serie_fat
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","OBF_NF_ELETR_EMIT")
 END IF

 RETURN l_nf_eletronica

 END FUNCTION

#-------------------------------------#
 FUNCTION pol1377_data_extenso_carta()
#-------------------------------------#
 DEFINE l_den_munic     LIKE empresa.den_munic,
        l_mes_extenso   CHAR(15)

 IF NOT pol1377_sistema_gerador_imprime_carta(" ") THEN
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
   SELECT texto
     INTO l_den_munic
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 4
      AND linha_texto     = 1
      AND tip_texto       = 'L'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'CIDADE DA CARTA NAO CADASTRADA.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 IF l_den_munic IS NULL THEN
    WHENEVER ERROR CONTINUE
      SELECT den_munic
        INTO l_den_munic
        FROM empresa
       WHERE cod_empresa = p_cod_empresa
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 THEN
       RETURN
    END IF
 END IF

 LET l_mes_extenso = pol1377_mes_extenso(mr_par_cre.dat_proces_doc)

 LET m_data_extenso = l_den_munic CLIPPED, ', ', DAY(mr_par_cre.dat_proces_doc), ' DE ',
                      l_mes_extenso CLIPPED, ' DE ', YEAR(mr_par_cre.dat_proces_doc)


END FUNCTION

#------------------------------------#
 FUNCTION pol1377_mes_extenso(l_data)
#------------------------------------#
 DEFINE l_data          DATE,
        l_mes_extenso   CHAR(15)

 CASE MONTH(l_data)
    WHEN  1 LET l_mes_extenso = 'JAN'
    WHEN  2 LET l_mes_extenso = 'FEV'
    WHEN  3 LET l_mes_extenso = 'MAR'
    WHEN  4 LET l_mes_extenso = 'ABR'
    WHEN  5 LET l_mes_extenso = 'MAI'
    WHEN  6 LET l_mes_extenso = 'JUN'
    WHEN  7 LET l_mes_extenso = 'JUL'
    WHEN  8 LET l_mes_extenso = 'AGO'
    WHEN  9 LET l_mes_extenso = 'SET'
    WHEN 10 LET l_mes_extenso = 'OUT'
    WHEN 11 LET l_mes_extenso = 'NOV'
    WHEN 12 LET l_mes_extenso = 'DEZ'
 END CASE

 RETURN l_mes_extenso

END FUNCTION

#-----------------------------------------------------#
 FUNCTION pol1377_emite_carta_envio(l_filial_cobranca ,
                                    l_meio_envio      ,
                                    l_roteiro         )
#-----------------------------------------------------#

 DEFINE l_filial_cobranca LIKE cre_compl_docum.filial_cobranca,
        l_meio_envio      LIKE cre_compl_docum.meio_envio,
        l_roteiro         LIKE cre_compl_docum.roteiro,
        l_texto_de        CHAR(76),
        l_texto_ref       CHAR(76),
        l_qtd_registro    INTEGER ,
        l_qtd_linhas      INTEGER ,
        l_existe_carta    SMALLINT

 DEFINE lr_carta RECORD
                    texto              LIKE cre_txt_sist_gerad.texto,
                    docum              LIKE docum.num_docum         ,
                    vencimento         LIKE docum.dat_vencto_s_desc ,
                    nome_cliente       LIKE clientes.nom_reduzido   ,
                    competencia        CHAR(06)                     ,
                    empresa            CHAR(02)                     ,
                    nota_fiscal        CHAR(06)                     ,
                    ies_tip_docum_orig CHAR(02)                     ,
                    nfe                DECIMAL(10,0)                ,
                    valor              LIKE docum.val_bruto
                 END RECORD

 DEFINE l_caminho_imp     CHAR(200)
 DEFINE l_nom_cliente     LIKE clientes.nom_cliente
 DEFINE l_stmt_t_carta    CHAR(2000)
 DEFINE l_sequencia_carta DECIMAL(6,0)

 LET m_last_row     = FALSE
 LET l_existe_carta = FALSE

 IF NOT pol1377_sistema_gerador_imprime_carta(" ") THEN
    RETURN
 END IF

 START REPORT pol1377_carta_envio TO m_caminho_carta_2_via_aux

 LET l_qtd_registro = 4 #Linha da cidade e data + 2 espaços em branco

 CALL pol1377_busca_nome_cliente()
 RETURNING l_nom_cliente

 #MENSAGEM NO RODAPE DA IMPRESSAO
 WHENEVER ERROR CONTINUE
   SELECT texto
     INTO m_msg_rodape
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 5
      AND linha_texto     = 1
      AND tip_texto       = 'L'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'MENSAGEM PARA O RODAPE NÃO CADASTRADA.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF
 #-----

 WHENEVER ERROR CONTINUE
   SELECT texto
     INTO l_texto_de
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 1
      AND linha_texto     = 1
      AND tip_texto       = 'L'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'CABECALHO DA CARTA NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
   SELECT texto
     INTO l_texto_ref
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 2
      AND linha_texto     = 1
      AND tip_texto       = 'L'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = 'CABECALHO DA CARTA NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 INITIALIZE m_msg_de, m_msg_para, m_msg_meio, m_msg_roteiro, m_msg_ref, m_msg_carta, m_pagina TO NULL

 LET m_msg_de   = 'De  : ', l_texto_de CLIPPED
 LET l_qtd_registro = l_qtd_registro + 2 #linha 'de' + 1 espaço em branco


 IF m_roteiro_especifico = l_roteiro THEN
    LET m_msg_para     = 'Para: ', l_nom_cliente CLIPPED
 ELSE
    LET m_msg_para     = 'Para: ', l_filial_cobranca
 END IF

 LET l_qtd_registro = l_qtd_registro + 2 #linha 'para' + 1 espaços em branco

 LET m_msg_meio     = 'Meio envio: ', l_meio_envio CLIPPED
 LET m_msg_roteiro  = '   Roteiro: ', l_roteiro CLIPPED
 LET l_qtd_registro = l_qtd_registro + 3 #linha 'meio_envio/roteiro' + 2 espaços em branco

 LET m_msg_ref  = 'Ref.: ', l_texto_ref CLIPPED
 LET l_qtd_registro = l_qtd_registro + 2 #linha 'ref.' + 1 espaços em branco

 LET m_msg_carta  = 'Carta: ', m_sequencia_carta CLIPPED
 LET l_qtd_registro = l_qtd_registro + 3 #linha 'Carta.' + 2 espaços em branco

 LET l_qtd_registro = l_qtd_registro + 3 #Cabeçalho das informações

 LET m_qtd_linhas_pagina = l_qtd_registro
 LET m_pagina            = 1

 LET l_qtd_linhas = 0
 WHENEVER ERROR CONTINUE
   SELECT MAX(linha_texto)
     INTO l_qtd_linhas
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 3
      AND tip_texto       = 'L'
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(1) TEXTO DA CARTA NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF
 LET l_qtd_registro = l_qtd_registro + l_qtd_linhas #Linhas do texto

 LET l_qtd_linhas = 0

 WHENEVER ERROR CONTINUE
   SELECT COUNT(*)
     INTO l_qtd_linhas
     FROM t_carta
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(1) NAO EXISTEM DOCUMENTOS PARA LISTAR.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 LET l_qtd_registro  = l_qtd_registro + l_qtd_linhas

 LET m_total_paginas = log_truncate_value((l_qtd_registro / 62), 0) + 1

 OUTPUT TO REPORT pol1377_carta_envio('CABECALHO_CARTA', lr_carta.*)

 WHENEVER ERROR CONTINUE
  DECLARE cq_texto_carta CURSOR FOR
   SELECT texto
     FROM cre_txt_sist_gerad
    WHERE programa        = 'CRE1055' 
      AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
      AND sequencia_texto = 3
      AND tip_texto       = 'L'
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(2) TEXTO DA CARTA NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_texto_carta INTO lr_carta.texto
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(3) TEXTO DA CARTA NAO CADASTRADO.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

    OUTPUT TO REPORT pol1377_carta_envio('CABECALHO_TEXTO', lr_carta.*)

    LET m_qtd_linhas_pagina = m_qtd_linhas_pagina + 1

    IF m_qtd_linhas_pagina = 62 THEN
       LET m_pagina = m_pagina + 1
    END IF

 END FOREACH

 WHENEVER ERROR CONTINUE
    CLOSE cq_texto_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("CLOSE","CQ_TEXTO_CARTA")
 END IF

 IF m_qtd_linhas_pagina > 62 THEN
    LET m_pagina = m_pagina + 1
 END IF

 OUTPUT TO REPORT pol1377_carta_envio('CABECALHO_DOCTO', lr_carta.*)

 CALL pol1377_atualiza_tabela_t_carta()

 CALL pol1377_monta_sql_t_carta()
 RETURNING l_stmt_t_carta

 WHENEVER ERROR CONTINUE
  PREPARE var_t_carta FROM l_stmt_t_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql_detalhe("PREPARE","VAR_T_CARTA",l_stmt_t_carta)
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_carta CURSOR FOR var_t_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(2) NAO EXISTEM DOCUMENTOS PARA LISTAR.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_carta INTO l_sequencia_carta           ,
                        lr_carta.docum              ,
                        lr_carta.vencimento         ,
                        lr_carta.nome_cliente       ,
                        lr_carta.competencia        ,
                        lr_carta.empresa            ,
                        lr_carta.nota_fiscal        ,
                        lr_carta.ies_tip_docum_orig ,
                        lr_carta.nfe                ,
                        lr_carta.valor
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 THEN
    LET m_msg = '(3) NAO EXISTEM DOCUMENTOS PARA LISTAR.'
    CALL pol1377_grava_temp_erros()
    RETURN
 END IF

    CALL pol1377_imprime_boletos_gravados( lr_carta.empresa ,
                                           lr_carta.docum   )

    OUTPUT TO REPORT pol1377_carta_envio('CORPO_CARTA', lr_carta.*)

    LET m_qtd_linhas_pagina = m_qtd_linhas_pagina + 1

    IF m_qtd_linhas_pagina = 62 THEN
       LET m_pagina = m_pagina + 1
    END IF

    LET l_existe_carta = TRUE

 END FOREACH

 WHENEVER ERROR CONTINUE
    CLOSE cq_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("CLOSE","CQ_CARTA")
 END IF

 WHENEVER ERROR CONTINUE
   DELETE FROM t_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
   DELETE FROM t_carta_aux
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    RETURN
 END IF

 FINISH REPORT pol1377_carta_envio

 IF  p_ies_impressao = 'S'
 AND l_existe_carta  = TRUE THEN
    LET l_caminho_imp = "lpr -P" CLIPPED, g_cod_impressora CLIPPED," ", m_caminho_carta_2_via_aux
    RUN l_caminho_imp
    INITIALIZE l_caminho_imp TO NULL
    LET l_caminho_imp = "lpr -P" CLIPPED, g_cod_impressora CLIPPED," ", m_caminho_carta_2_via_aux
    RUN l_caminho_imp
 END IF

 END FUNCTION

#-------------------------------------------------#
 REPORT pol1377_carta_envio(l_parametro, lr_carta)
#-------------------------------------------------#
 DEFINE l_parametro                   CHAR(15)

 DEFINE lr_carta                      RECORD
                                         texto         LIKE cre_txt_sist_gerad.texto,
                                         docum         LIKE docum.num_docum         ,
                                         vencimento    LIKE docum.dat_vencto_s_desc ,
                                         nome_cliente  LIKE clientes.nom_reduzido   ,
                                         competencia   CHAR(06)                     ,
                                         empresa       CHAR(02)                     ,
                                         nota_fiscal   CHAR(06)                     ,
                                         ies_tip_docum_orig CHAR(02),
                                         nfe           DECIMAL(10,0)                ,
                                         valor         LIKE docum.val_bruto
                                      END RECORD

 OUTPUT LEFT   MARGIN 0
        TOP    MARGIN 0
        BOTTOM MARGIN 1
        PAGE   LENGTH 66

 FORMAT #{}

 PAGE HEADER
    PRINT log5211_retorna_configuracao(PAGENO,66,80) CLIPPED;

 ON EVERY ROW
    IF m_qtd_linhas_pagina = 62 THEN
       LET m_qtd_linhas_pagina = 0
       SKIP TO TOP OF PAGE
    END IF

    IF l_parametro = 'CABECALHO_CARTA' OR m_qtd_linhas_pagina = 0 THEN
       PRINT COLUMN 71, m_pagina USING '&&','/',m_total_paginas USING '&&'
    END IF

    IF l_parametro = 'CABECALHO_CARTA' THEN
       PRINT COLUMN 01, m_data_extenso CLIPPED
       SKIP 2 LINES
       PRINT COLUMN 01, m_msg_de       CLIPPED
       SKIP 1 LINE
       PRINT COLUMN 01, m_msg_para     CLIPPED
       SKIP 1 LINE
       PRINT COLUMN 01, m_msg_meio     CLIPPED
       PRINT COLUMN 01, m_msg_roteiro  CLIPPED
       SKIP 1 LINE
       PRINT COLUMN 01, m_msg_ref      CLIPPED
       SKIP 1 LINES
       PRINT COLUMN 01, m_msg_carta    CLIPPED
       SKIP 2 LINES
    END IF

    IF l_parametro = 'CABECALHO_TEXTO' THEN
       PRINT COLUMN 01, lr_carta.texto CLIPPED
    END IF

    IF l_parametro = 'CABECALHO_DOCTO' THEN
       SKIP 1 LINE
       PRINT COLUMN 01, 'Titulo          Vencto  Nome Guerra     Compet EMP N.F.  N.F.E              Valor'
       PRINT COLUMN 01, '-------------- -------- --------------- ------ --- ------ ---------- -------------'
    END IF

    IF l_parametro = 'CORPO_CARTA' THEN
       PRINT COLUMN 01, lr_carta.docum         CLIPPED,
             COLUMN 16, lr_carta.vencimento    USING 'dd/mm/yy',
             COLUMN 25, lr_carta.nome_cliente  CLIPPED,
             COLUMN 41, lr_carta.competencia   CLIPPED,
             COLUMN 48, lr_carta.empresa       ,
             COLUMN 52, lr_carta.nota_fiscal   CLIPPED,
             COLUMN 59, lr_carta.nfe           USING "<<<<<<<<<<",
             COLUMN 70, lr_carta.valor         USING '##,###,##&.&&'
    END IF

 ON LAST ROW
    LET m_last_row = TRUE

 PAGE TRAILER
    IF m_last_row = TRUE THEN
       PRINT m_msg_rodape
       LET m_last_row = FALSE
       PRINT ' '
    ELSE
       PRINT ' '
       PRINT ' '
    END IF

 END REPORT


#---------------------------------------------------------#
 FUNCTION pol1377_busca_cre_imp_item_781(l_valor          ,
                                         l_empresa        ,
                                         l_docum          ,
                                         l_tip_docum      ,
                                         l_item           ,
                                         l_sequencia_docum)
#---------------------------------------------------------#

 DEFINE l_valor                 CHAR(20)
 DEFINE l_empresa         LIKE cre_itcompl_docum.empresa,
        l_docum           LIKE cre_itcompl_docum.docum,
        l_tip_docum       LIKE cre_itcompl_docum.tip_docum,
        l_item            LIKE cre_itcompl_docum.item,
        l_sequencia_docum LIKE cre_itcompl_docum.sequencia_docum


 DEFINE l_retorno_parametro_val LIKE cre_imp_item_781.parametro_val

 WHENEVER ERROR CONTINUE
   SELECT parametro_val
     INTO l_retorno_parametro_val
     FROM cre_imp_item_781
    WHERE cre_imp_item_781.empresa        = l_empresa
      AND cre_imp_item_781.docum          = l_docum
      AND cre_imp_item_781.tip_docum      = l_tip_docum
      AND cre_imp_item_781.item           = l_item
      AND cre_imp_item_781.campo          = l_valor
      AND cre_imp_item_781.sequencia_item = l_sequencia_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","cre_imp_item_781")
    LET l_retorno_parametro_val = 0
    RETURN l_retorno_parametro_val
 END IF

 IF l_retorno_parametro_val IS NULL
 OR l_retorno_parametro_val = " " THEN
    LET l_retorno_parametro_val = 0
    RETURN l_retorno_parametro_val
 ELSE
    RETURN l_retorno_parametro_val
 END IF


 END FUNCTION

#--------------------------------------------------------------------#
 FUNCTION pol1377_carrega_demonstrativo_detalhado(l_cnpj_cli_agrupado)
#--------------------------------------------------------------------#

  #497350 Rotina para selecionar as informações do demonstrativo

  DEFINE l_cnpj_cli_agrupado LIKE cre_itcompl_docum.cnpj_cli_agrupado

  DEFINE l_ind       INTEGER,
         l_ind2      INTEGER,
         l_praca_ant LIKE cre_itcompl_docum.praca,
         l_cent_msg  CHAR(01)

  DEFINE l_empresa_den_empresa LIKE empresa.den_empresa,
         l_empresa_end_empresa LIKE empresa.end_empresa,
         l_empresa_den_bairro  LIKE empresa.den_bairro ,
         l_empresa_den_munic   LIKE empresa.den_munic  ,
         l_empresa_uni_feder   LIKE empresa.uni_feder  ,
         l_empresa_cod_cep     LIKE empresa.cod_cep

  DEFINE l_item_praca        LIKE cre_itcompl_docum.praca,
         l_item_qtd_tot_item LIKE cre_itcompl_docum.qtd_item,
         l_item_val_tot_item LIKE cre_itcompl_docum.val_tot_item,
         l_item_classif_item LIKE cre_classif_item.classif_item,
         l_tip_consulta      LIKE cre_classif_item.tip_consulta


 DEFINE l_empresa         LIKE cre_itcompl_docum.empresa,
        l_docum           LIKE cre_itcompl_docum.docum,
        l_tip_docum       LIKE cre_itcompl_docum.tip_docum,
        l_item            LIKE cre_itcompl_docum.item,
        l_sequencia_docum LIKE cre_itcompl_docum.sequencia_docum,
        l_dat_servico     LIKE cre_itcompl_docum.dat_servico

 DEFINE l_praca      LIKE cre_itcompl_docum.praca
 DEFINE l_item_ant   LIKE cre_itcompl_docum.item
 DEFINE l_comparacao SMALLINT


 DEFINE l_nom_cliente     LIKE clientes.nom_cliente
 DEFINE l_qtd_caracteres  SMALLINT
 DEFINE l_ja_formatado    CHAR(30)
 DEFINE l_num_cgc_cpf     CHAR(30)

 DEFINE l_den_item  LIKE item.den_item_reduz
 DEFINE l_den_praca CHAR(28)
 DEFINE l_qtd       SMALLINT
 DEFINE l_nome_praca       LIKE clientes.nom_reduzido
 DEFINE l_qtd_registros  SMALLINT

 DEFINE l_mes_itcompl     CHAR(02)
 DEFINE l_ano_itcompl     CHAR(04)
 DEFINE l_data_itcompl    CHAR(10)

 DEFINE l_mes_docum         CHAR(02)
 DEFINE l_ano_docum         CHAR(04)
 DEFINE l_data_docum        CHAR(10)
 DEFINE l_achou_itens       SMALLINT
 DEFINE l_cod_cedente_caixa CHAR(47)
 DEFINE l_dv_verificador    INTEGER

 DEFINE l_total_negativo  LIKE cre_itcompl_docum.val_tot_item
 DEFINE l_val_outros_desc LIKE cre_itcompl_docum.val_tot_item


 INITIALIZE ma_demonst_item             TO NULL
 INITIALIZE ma_tip_consulta             TO NULL

 LET mr_tip_consulta.qtd_sem_desconto = 0
 LET mr_tip_consulta.qtd_com_desconto = 0
 LET mr_tip_consulta.val_sem_desconto = 0
 LET mr_tip_consulta.val_com_desconto = 0

 LET mr_demonst_totais.qtd_sem_desconto = 0
 LET mr_demonst_totais.qtd_com_desconto = 0
 LET mr_demonst_totais.qtd_carreteiro   = 0
 LET mr_demonst_totais.qtd_agregado     = 0
 LET mr_demonst_totais.qtd_frota        = 0
 LET mr_demonst_totais.qtd_out_func     = 0
 LET mr_demonst_totais.qtd_repesquisa   = 0
 LET mr_demonst_totais.qtd_recad_agr    = 0
 LET mr_demonst_totais.qtd_recad_fro    = 0
 LET mr_demonst_totais.qtd_recad_out_f  = 0
 LET mr_demonst_totais.val_sem_desconto = 0
 LET mr_demonst_totais.val_com_desconto = 0
 LET mr_demonst_totais.val_carreteiro   = 0
 LET mr_demonst_totais.val_agregado     = 0
 LET mr_demonst_totais.val_frota        = 0
 LET mr_demonst_totais.val_out_func     = 0
 LET mr_demonst_totais.val_repesquisa   = 0
 LET mr_demonst_totais.val_recad_agr    = 0
 LET mr_demonst_totais.val_recad_fro    = 0
 LET mr_demonst_totais.val_recad_out_f  = 0


 #Topo do demonstrativo
 LET mr_demonst.dem_telerisco_num  = mr_relat.num_docum
 LET mr_demonst.val_adm            = mr_cre_compl_docum.filial_cobranca
 LET mr_demonst.val_emissao        = mr_relat.dat_emissao
 LET mr_demonst.val_vencimento     = mr_relat.dat_vencto
 LET mr_demonst.val_raz_soc        = mr_relat.nom_cliente
 LET mr_demonst.val_insc_est       = mr_dados_cliente.ins_estadual

 #Itens do demonstrativo
 LET l_ind                  = 0
 LET l_praca_ant            = 0
 LET l_item_ant             = 0
 LET m_count                = 0
 LET m_count_aux            = 0
 LET m_count_praca          = 0
 LET m_count_praca_aux      = 0
 LET m_val_iss_2            = 0
 LET m_val_pis_2            = 0
 LET m_val_confins_2        = 0
 LET m_val_csll_2           = 0
 LET m_val_irrf_2           = 0
 LET l_qtd                  = 0
 LET l_qtd_registros        = 0
 LET l_total_negativo       = 0
 LET l_val_outros_desc      = 0

 LET m_verifica_tip_consulta_pdf = FALSE
 LET l_achou_itens = FALSE #marlon

 #RAZÃO SOCIAL SO NO DEMONSTRATIVO
 WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO mr_demonst.val_raz_soc
     FROM clientes
    WHERE cod_cliente = mr_docum.cod_cliente
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","CLIENTES")
 END IF

 LET m_cnpj_cli_agrupado = l_cnpj_cli_agrupado

 LET l_qtd_caracteres = LENGTH(l_cnpj_cli_agrupado)
 LET l_num_cgc_cpf    = l_cnpj_cli_agrupado

 CASE l_qtd_caracteres
    WHEN 14
       LET l_ja_formatado = l_num_cgc_cpf[1,2] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[3,5] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[6,8] CLIPPED, "/"
                   CLIPPED, l_num_cgc_cpf[9,12] CLIPPED, "-"
                   CLIPPED, l_num_cgc_cpf[13,14]
    WHEN 15
       LET l_ja_formatado = l_num_cgc_cpf[1,3] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[4,6] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[7,9] CLIPPED, "/"
                   CLIPPED, l_num_cgc_cpf[10,13] CLIPPED, "-"
                   CLIPPED, l_num_cgc_cpf[14,15]

    WHEN 11
       LET l_ja_formatado = l_num_cgc_cpf[1,3] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[4,6] CLIPPED, "."
                   CLIPPED, l_num_cgc_cpf[7,9] CLIPPED, "-"
                   CLIPPED, l_num_cgc_cpf[10,11]
 END CASE

 IF l_ja_formatado IS NULL
 OR l_ja_formatado = " " THEN
    LET mr_demonst.val_cnpj_cpf = l_cnpj_cli_agrupado
 ELSE
    LET mr_demonst.val_cnpj_cpf = l_ja_formatado
 END IF

 #RAZÃO SOCIAL SO NO DEMONSTRATIVO
 WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO mr_demonst.val_raz_soc
     FROM clientes
    WHERE num_cgc_cpf = l_ja_formatado
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","CLIENTES")
 END IF

 #BUSCA A QUANTIDADE GERAL DE REGISTROS A SEREM PROCESSADOS
 WHENEVER ERROR CONTINUE
   SELECT COUNT(ctr_titulo_item.praca)
     INTO l_qtd_registros
     FROM ctr_titulo_item, cre_classif_item
    WHERE ctr_titulo_item.empresa           = mr_docum.cod_empresa
      AND ctr_titulo_item.titulo             = mr_docum.num_docum
      AND ctr_titulo_item.tip_titulo         = mr_docum.ies_tip_docum
      AND ctr_titulo_item.cnpj_ctr_agrupado = l_cnpj_cli_agrupado
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
      AND cre_classif_item.empresa            = ctr_titulo_item.empresa
      AND cre_classif_item.item               = ctr_titulo_item.item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","ctr_titulo_item")
 END IF
 #-----

 #VERIFICA A QUANTIDADE DE PAGINAS POR DEMONSTRATIVO
 WHENEVER ERROR CONTINUE
   SELECT COUNT(DISTINCT ctr_titulo_item.praca)
     INTO l_qtd
     FROM ctr_titulo_item, cre_classif_item
    WHERE ctr_titulo_item.empresa           = mr_docum.cod_empresa
      AND ctr_titulo_item.titulo             = mr_docum.num_docum
      AND ctr_titulo_item.tip_titulo         = mr_docum.ies_tip_docum
      AND ctr_titulo_item.cnpj_ctr_agrupado = l_cnpj_cli_agrupado
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
      AND cre_classif_item.empresa            = ctr_titulo_item.empresa
      AND cre_classif_item.item               = ctr_titulo_item.item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","ctr_titulo_item")
 END IF

 IF m_imprime_bloqueto <> 'D' THEN
    LET m_qtd_pag_demonst_pdf = 1
 ELSE
    LET m_qtd_pag_demonst_pdf = log_truncate_value((l_qtd / m_qtd_itens_por_pag_pdf), 0) + 1
 END IF
 #-----

 WHENEVER ERROR CONTINUE
  DECLARE cq_ctr_titulo_item1 CURSOR FOR
   SELECT DISTINCT(ctr_titulo_item.praca)  ,
          cre_classif_item.classif_item      ,
          cre_classif_item.tip_consulta      ,
          SUM(ctr_titulo_item.qtd_item)    ,
          SUM(ctr_titulo_item.val_total_item),
          ctr_titulo_item.empresa          ,
          ctr_titulo_item.titulo            ,
          ctr_titulo_item.tip_titulo        ,
          ctr_titulo_item.item             ,
          ctr_titulo_item.sequencia_item  ,
          ctr_titulo_item.dat_servico
     FROM ctr_titulo_item, cre_classif_item
    WHERE ctr_titulo_item.empresa           = mr_docum.cod_empresa
      AND ctr_titulo_item.titulo             = mr_docum.num_docum
      AND ctr_titulo_item.tip_titulo         = mr_docum.ies_tip_docum
      AND ctr_titulo_item.cnpj_ctr_agrupado = l_cnpj_cli_agrupado
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND  YEAR(ctr_titulo_item.dat_servico)  = YEAR(mr_docum.dat_competencia))
      AND cre_classif_item.empresa            = ctr_titulo_item.empresa
      AND cre_classif_item.item               = ctr_titulo_item.item
    GROUP BY ctr_titulo_item.praca            ,
             ctr_titulo_item.item             ,
             cre_classif_item.classif_item      ,
             cre_classif_item.tip_consulta      ,
             ctr_titulo_item.qtd_item         ,
             ctr_titulo_item.val_total_item     ,
             ctr_titulo_item.empresa          ,
             ctr_titulo_item.titulo            ,
             ctr_titulo_item.tip_titulo        ,
             ctr_titulo_item.sequencia_item  ,
             ctr_titulo_item.dat_servico
    ORDER BY ctr_titulo_item.praca, ctr_titulo_item.item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","CQ_ctr_titulo_item1")
 END IF


 WHENEVER ERROR CONTINUE
  FOREACH cq_ctr_titulo_item1 INTO l_item_praca       ,
                                     l_item_classif_item,
                                     l_tip_consulta     ,
                                     l_item_qtd_tot_item,
                                     l_item_val_tot_item,
                                     l_empresa          ,
                                     l_docum            ,
                                     l_tip_docum        ,
                                     l_item             ,
                                     l_sequencia_docum  ,
                                     l_dat_servico
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('FOREACH','CQ_ctr_titulo_item1')
    RETURN
 END IF

    LET l_achou_itens = TRUE

    IF l_item_val_tot_item < 0 THEN
       LET l_total_negativo    = l_total_negativo + l_item_val_tot_item
       CONTINUE FOREACH
    END IF

    #UTILIZADO PARA IMPRIMIR SOMENTE NO FINAL OS ITENS QUE POSSUIREM
    #TIPO DE CONSULTA IGUAL A DEBITO.
    IF l_tip_consulta = "D" THEN
       WHENEVER ERROR CONTINUE
         INSERT INTO t_tip_consulta(praca            ,
                                    classif_item     ,
                                    qtd_item         ,
                                    val_tot_item     ,
                                    cnpj_cli_agrupado,
                                    item             ,
                                    empresa          ,
                                    docum            ,
                                    tip_docum        ,
                                    sequencia_docum  )
                            VALUES (l_item_praca        ,
                                    l_item_classif_item ,
                                    l_item_qtd_tot_item ,
                                    l_item_val_tot_item ,
                                    l_cnpj_cli_agrupado ,
                                    l_item              ,
                                    l_empresa           ,
                                    l_docum             ,
                                    l_tip_docum         ,
                                    l_sequencia_docum   )
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("INSERT","T_TIP_CONSULTA")
       END IF

       LET m_verifica_tip_consulta_pdf = TRUE

       CONTINUE FOREACH

    END IF


    IF l_praca_ant <> l_item_praca THEN
       LET l_praca_ant = l_item_praca
       LET l_ind = l_ind + 1

       IF l_ind > 10000 THEN
         CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
         EXIT FOREACH
       END IF

       #Inicializa com 0 para evitar erro na soma dos valores
       LET ma_demonst_item[l_ind].val_sem_desconto = 0
       LET ma_demonst_item[l_ind].qtd_sem_desconto = 0
       LET ma_demonst_item[l_ind].val_com_desconto = 0
       LET ma_demonst_item[l_ind].qtd_com_desconto = 0
       LET ma_demonst_item[l_ind].val_carreteiro   = 0
       LET ma_demonst_item[l_ind].qtd_carreteiro   = 0
       LET ma_demonst_item[l_ind].val_agregado     = 0
       LET ma_demonst_item[l_ind].qtd_agregado     = 0
       LET ma_demonst_item[l_ind].val_frota        = 0
       LET ma_demonst_item[l_ind].qtd_frota        = 0
       LET ma_demonst_item[l_ind].val_out_func     = 0
       LET ma_demonst_item[l_ind].qtd_out_func     = 0
       LET ma_demonst_item[l_ind].val_repesquisa   = 0
       LET ma_demonst_item[l_ind].qtd_repesquisa   = 0
       LET ma_demonst_item[l_ind].val_recad_agr    = 0
       LET ma_demonst_item[l_ind].qtd_recad_agr    = 0
       LET ma_demonst_item[l_ind].val_recad_fro    = 0
       LET ma_demonst_item[l_ind].qtd_recad_fro    = 0
       LET ma_demonst_item[l_ind].val_recad_out_f  = 0
       LET ma_demonst_item[l_ind].qtd_recad_out_f  = 0

       LET ma_demonst_item[l_ind].praca = pol1377_get_den_praca(l_item_praca)

       CASE l_item_classif_item
          WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_sem_desconto = l_item_qtd_tot_item
          WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_com_desconto = l_item_qtd_tot_item
          WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_carreteiro   = l_item_qtd_tot_item
          WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_agregado     = l_item_qtd_tot_item
          WHEN 05 LET ma_demonst_item[l_ind].val_frota        = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_frota        = l_item_qtd_tot_item
          WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_out_func     = l_item_qtd_tot_item
          WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_repesquisa   = l_item_qtd_tot_item
          WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_agr    = l_item_qtd_tot_item
          WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_fro    = l_item_qtd_tot_item
          WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_out_f  = l_item_qtd_tot_item
       END CASE
    ELSE

       #Aqui
       #LET l_ind = l_ind + 1
       #
       #IF l_ind > 10000 THEN
       #  CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
       #  EXIT FOREACH
       #END IF

       CASE l_item_classif_item                                 #Incluido Marlon........................#
          WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto + l_item_qtd_tot_item
          WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto + l_item_qtd_tot_item
          WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = ma_demonst_item[l_ind].val_carreteiro   + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_carreteiro   = ma_demonst_item[l_ind].qtd_carreteiro   + l_item_qtd_tot_item
          WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = ma_demonst_item[l_ind].val_agregado     + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_agregado     = ma_demonst_item[l_ind].qtd_agregado     + l_item_qtd_tot_item
          WHEN 05 LET ma_demonst_item[l_ind].val_frota        = ma_demonst_item[l_ind].val_frota        + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_frota        = ma_demonst_item[l_ind].qtd_frota        + l_item_qtd_tot_item
          WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = ma_demonst_item[l_ind].val_out_func     + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_out_func     = ma_demonst_item[l_ind].qtd_out_func     + l_item_qtd_tot_item
          WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = ma_demonst_item[l_ind].val_repesquisa   + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_repesquisa   = ma_demonst_item[l_ind].qtd_repesquisa   + l_item_qtd_tot_item
          WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = ma_demonst_item[l_ind].val_recad_agr    + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_agr    = ma_demonst_item[l_ind].qtd_recad_agr    + l_item_qtd_tot_item
          WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = ma_demonst_item[l_ind].val_recad_fro    + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_fro    = ma_demonst_item[l_ind].qtd_recad_fro    + l_item_qtd_tot_item
          WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = ma_demonst_item[l_ind].val_recad_out_f  + l_item_val_tot_item
                  LET ma_demonst_item[l_ind].qtd_recad_out_f  = ma_demonst_item[l_ind].qtd_recad_out_f  + l_item_qtd_tot_item
       END CASE
    END IF

    LET mr_demonst.val_iss_1          = m_pct_iss
    LET mr_demonst.val_iss_2          = pol1377_busca_cre_imp_item_781('val_iss_retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_iss_retencao
    LET mr_demonst.val_pis_1          = m_pct_pis
    LET mr_demonst.val_pis_2          = pol1377_busca_cre_imp_item_781('val_pis-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_pis_retencao
    LET mr_demonst.val_confins_1      = m_pct_cofins
    LET mr_demonst.val_confins_2      = pol1377_busca_cre_imp_item_781('val_cofins-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_cofins_retencao
    LET mr_demonst.val_csll_1         = m_pct_csll
    LET mr_demonst.val_csll_2         = pol1377_busca_cre_imp_item_781('val_csll-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_csll_retencao
    LET mr_demonst.val_irrf_1         = m_pct_irrf
    LET mr_demonst.val_irrf_2         = pol1377_busca_cre_imp_item_781('val_irrf-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_irrf

    LET m_val_iss_2      = m_val_iss_2       + mr_demonst.val_iss_2
    LET m_val_pis_2      = m_val_pis_2       + mr_demonst.val_pis_2
    LET m_val_confins_2  = m_val_confins_2   + mr_demonst.val_confins_2
    LET m_val_csll_2     = m_val_csll_2      + mr_demonst.val_csll_2
    LET m_val_irrf_2     = m_val_irrf_2      + mr_demonst.val_irrf_2

  END FOREACH

  #::: Valores de INSS
  CALL pol1377_busca_valores_de_inss( mr_docum.cod_empresa   ,
                                      mr_docum.num_docum     ,
                                      mr_docum.ies_tip_docum )
  RETURNING mr_demonst.val_inss_1, mr_demonst.val_inss_2
  #:::

  IF m_verifica_tip_consulta_pdf = TRUE THEN
     LET l_item_ant   = 0
     LET l_praca_ant  = 0
     LET l_ind        = l_ind + 1
     LET l_qtd_registros = l_qtd_registros + 1

     INITIALIZE l_item_praca        ,
                l_item_classif_item ,
                l_item_qtd_tot_item ,
                l_item_val_tot_item ,
                l_cnpj_cli_agrupado ,
                l_item              ,
                l_empresa           ,
                l_docum             ,
                l_tip_docum         ,
                l_sequencia_docum   TO NULL


      WHENEVER ERROR CONTINUE
       DECLARE cq_tip_consulta1 CURSOR FOR
        SELECT praca            ,
               classif_item     ,
               qtd_item         ,
               val_tot_item     ,
               cnpj_cli_agrupado,
               item             ,
               empresa          ,
               docum            ,
               tip_docum        ,
               sequencia_docum
          FROM t_tip_consulta
      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("DECLARE","CQ_TIP_CONSULTA1")
      END IF

      WHENEVER ERROR CONTINUE
       FOREACH cq_tip_consulta1 INTO l_item_praca       ,
                                     l_item_classif_item,
                                     l_item_qtd_tot_item,
                                     l_item_val_tot_item,
                                     l_cnpj_cli_agrupado,
                                     l_item             ,
                                     l_empresa          ,
                                     l_docum            ,
                                     l_tip_docum        ,
                                     l_sequencia_docum

      WHENEVER ERROR STOP
      IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("FOREACH","CQ_TIP_CONSULTA1")
      END IF


         IF l_praca_ant <> l_item_praca THEN
            LET l_praca_ant = l_item_praca
            LET l_ind = l_ind + 1

            IF l_ind > 10000 THEN
              CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
              EXIT FOREACH
            END IF

            #Inicializa com 0 para evitar erro na soma dos valores
            LET ma_demonst_item[l_ind].val_sem_desconto = 0
            LET ma_demonst_item[l_ind].qtd_sem_desconto = 0
            LET ma_demonst_item[l_ind].val_com_desconto = 0
            LET ma_demonst_item[l_ind].qtd_com_desconto = 0
            LET ma_demonst_item[l_ind].val_carreteiro   = 0
            LET ma_demonst_item[l_ind].qtd_carreteiro   = 0
            LET ma_demonst_item[l_ind].val_agregado     = 0
            LET ma_demonst_item[l_ind].qtd_agregado     = 0
            LET ma_demonst_item[l_ind].val_frota        = 0
            LET ma_demonst_item[l_ind].qtd_frota        = 0
            LET ma_demonst_item[l_ind].val_out_func     = 0
            LET ma_demonst_item[l_ind].qtd_out_func     = 0
            LET ma_demonst_item[l_ind].val_repesquisa   = 0
            LET ma_demonst_item[l_ind].qtd_repesquisa   = 0
            LET ma_demonst_item[l_ind].val_recad_agr    = 0
            LET ma_demonst_item[l_ind].qtd_recad_agr    = 0
            LET ma_demonst_item[l_ind].val_recad_fro    = 0
            LET ma_demonst_item[l_ind].qtd_recad_fro    = 0
            LET ma_demonst_item[l_ind].val_recad_out_f  = 0
            LET ma_demonst_item[l_ind].qtd_recad_out_f  = 0

            LET ma_tip_consulta[l_ind].val_sem_desconto = 0
            LET ma_tip_consulta[l_ind].val_com_desconto = 0
            LET ma_tip_consulta[l_ind].qtd_sem_desconto = 0
            LET ma_tip_consulta[l_ind].qtd_com_desconto = 0

            WHENEVER ERROR CONTINUE
              SELECT den_item_reduz
                INTO l_den_item
                FROM item
               WHERE cod_empresa = mr_docum.cod_empresa
                 AND cod_item    = l_item
            WHENEVER ERROR STOP
            IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
               CALL log003_err_sql("SELECT","ITEM4")
            END IF

            LET l_den_praca = pol1377_get_den_praca(l_item_praca)
            LET ma_demonst_item[l_ind].praca = "*" CLIPPED, l_den_item CLIPPED, "-", l_den_praca CLIPPED

            CASE l_item_classif_item
               WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_sem_desconto = l_item_qtd_tot_item
               WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_com_desconto = l_item_qtd_tot_item
               WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_carreteiro   = l_item_qtd_tot_item
               WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_agregado     = l_item_qtd_tot_item
               WHEN 05 LET ma_demonst_item[l_ind].val_frota        = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_frota        = l_item_qtd_tot_item
               WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_out_func     = l_item_qtd_tot_item
               WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_repesquisa   = l_item_qtd_tot_item
               WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_agr    = l_item_qtd_tot_item
               WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_fro    = l_item_qtd_tot_item
               WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_out_f  = l_item_qtd_tot_item
            END CASE
         ELSE

            #Aqui
            #LET l_ind = l_ind + 1
            #
            #IF l_ind > 10000 THEN
            #  CALL log0030_mensagem('Estouro da quantidade de itens do demonstrativo', 'exclamation')
            #  EXIT FOREACH
            #END IF

            CASE l_item_classif_item                                 #Incluido Marlon........................#
               WHEN 01 LET ma_demonst_item[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto + l_item_qtd_tot_item
               WHEN 02 LET ma_demonst_item[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto + l_item_qtd_tot_item
               WHEN 03 LET ma_demonst_item[l_ind].val_carreteiro   = ma_demonst_item[l_ind].val_carreteiro   + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_carreteiro   = ma_demonst_item[l_ind].qtd_carreteiro   + l_item_qtd_tot_item
               WHEN 04 LET ma_demonst_item[l_ind].val_agregado     = ma_demonst_item[l_ind].val_agregado     + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_agregado     = ma_demonst_item[l_ind].qtd_agregado     + l_item_qtd_tot_item
               WHEN 05 LET ma_demonst_item[l_ind].val_frota        = ma_demonst_item[l_ind].val_frota        + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_frota        = ma_demonst_item[l_ind].qtd_frota        + l_item_qtd_tot_item
               WHEN 06 LET ma_demonst_item[l_ind].val_out_func     = ma_demonst_item[l_ind].val_out_func     + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_out_func     = ma_demonst_item[l_ind].qtd_out_func     + l_item_qtd_tot_item
               WHEN 07 LET ma_demonst_item[l_ind].val_repesquisa   = ma_demonst_item[l_ind].val_repesquisa   + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_repesquisa   = ma_demonst_item[l_ind].qtd_repesquisa   + l_item_qtd_tot_item
               WHEN 08 LET ma_demonst_item[l_ind].val_recad_agr    = ma_demonst_item[l_ind].val_recad_agr    + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_agr    = ma_demonst_item[l_ind].qtd_recad_agr    + l_item_qtd_tot_item
               WHEN 09 LET ma_demonst_item[l_ind].val_recad_fro    = ma_demonst_item[l_ind].val_recad_fro    + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_fro    = ma_demonst_item[l_ind].qtd_recad_fro    + l_item_qtd_tot_item
               WHEN 10 LET ma_demonst_item[l_ind].val_recad_out_f  = ma_demonst_item[l_ind].val_recad_out_f  + l_item_val_tot_item
                       LET ma_demonst_item[l_ind].qtd_recad_out_f  = ma_demonst_item[l_ind].qtd_recad_out_f  + l_item_qtd_tot_item
            END CASE

         END IF

         LET ma_tip_consulta[l_ind].val_sem_desconto = ma_demonst_item[l_ind].val_sem_desconto
         LET ma_tip_consulta[l_ind].val_com_desconto = ma_demonst_item[l_ind].val_com_desconto
         LET ma_tip_consulta[l_ind].qtd_sem_desconto = ma_demonst_item[l_ind].qtd_sem_desconto
         LET ma_tip_consulta[l_ind].qtd_com_desconto = ma_demonst_item[l_ind].qtd_com_desconto

         LET mr_demonst.val_iss_1          = m_pct_iss
         LET mr_demonst.val_iss_2          = pol1377_busca_cre_imp_item_781('val_iss_retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_iss_retencao
         LET mr_demonst.val_pis_1          = m_pct_pis
         LET mr_demonst.val_pis_2          = pol1377_busca_cre_imp_item_781('val_pis-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_pis_retencao
         LET mr_demonst.val_confins_1      = m_pct_cofins
         LET mr_demonst.val_confins_2      = pol1377_busca_cre_imp_item_781('val_cofins-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_cofins_retencao
         LET mr_demonst.val_csll_1         = m_pct_csll
         LET mr_demonst.val_csll_2         = pol1377_busca_cre_imp_item_781('val_csll-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_csll_retencao
         LET mr_demonst.val_irrf_1         = m_pct_irrf
         LET mr_demonst.val_irrf_2         = pol1377_busca_cre_imp_item_781('val_irrf-retencao', l_empresa, l_docum, l_tip_docum, l_item, l_sequencia_docum) #m_val_irrf

         LET m_val_iss_2      = m_val_iss_2       + mr_demonst.val_iss_2
         LET m_val_pis_2      = m_val_pis_2       + mr_demonst.val_pis_2
         LET m_val_confins_2  = m_val_confins_2   + mr_demonst.val_confins_2
         LET m_val_csll_2     = m_val_csll_2      + mr_demonst.val_csll_2
         LET m_val_irrf_2     = m_val_irrf_2      + mr_demonst.val_irrf_2

      END FOREACH
  END IF

  IF l_achou_itens = TRUE THEN
  WHENEVER ERROR CONTINUE
    SELECT den_razao_social
      INTO mr_demonst.val_cedente
      FROM emp_raz_soc
     WHERE cod_empresa = mr_docum.cod_empresa
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
     LET mr_demonst.val_cedente        = mr_dados_empresa.den_empresa
  END IF

  CASE
    WHEN mr_relat.cod_banco[1,3] = "399"
         LET mr_demonst.val_age_cod_ced = mr_relat.cod_cedente

    WHEN mr_relat.cod_banco[1,3] = "275"
         LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],    #frank item 06
                                          "/",
                                          mr_relat.cod_cedente CLIPPED,
                                          "/",
                                          mr_relat.nosso_numero[9,9]  #frank item 06

    WHEN mr_relat.cod_banco[1,3] = "356"
         LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                          "/",
                                          mr_relat.cod_cedente CLIPPED,
                                          "/",
                                          mr_relat.nosso_numero[9,9]

    WHEN mr_relat.cod_banco[1,3] = "033"
         LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                          "/",
                                          mr_relat.cod_cedente CLIPPED,
                                          "/",
                                          mr_relat.nosso_numero[9,9]

    WHEN mr_relat.cod_banco[1,3] = "341"
       LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia[1,4],
                                        "/",
                                        mr_relat.cod_cedente CLIPPED

    WHEN mr_relat.cod_banco[1,3] = "422"
         LET mr_demonst.val_age_cod_ced = mr_relat.cod_agencia,
                                          ".",
                                          mr_relat.cod_cedente

    WHEN mr_relat.cod_banco[1,3] = "453"
         LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED," ",
                                          mr_relat.cod_cedente

    WHEN mr_relat.cod_banco[1,3] = "320"
         LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED," ",
                                          mr_relat.cod_cedente

    WHEN mr_relat.cod_banco[1,3] = "104"
         LET l_cod_cedente_caixa = mr_par_bloq_laser.cod_cedente CLIPPED,'00000000000000000000000000000000'
         LET l_dv_verificador    = cap446_calcula_dv_geral('DVB',l_cod_cedente_caixa)

         LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                          mr_par_bloq_laser.cod_cedente[5,7],'.',
                                          mr_par_bloq_laser.cod_cedente[8,15],'-',
                                          l_dv_verificador USING '<<<<<<&'

         LET mr_relat.cod_cedente = mr_par_bloq_laser.cod_cedente[1,4],'.',
                                    mr_par_bloq_laser.cod_cedente[5,7],'.',
                                    mr_par_bloq_laser.cod_cedente[8,15],'-',
                                    l_dv_verificador USING '<<<<<<&'

    OTHERWISE
         LET mr_demonst.val_age_cod_ced = mr_par_bloq_laser.num_agencia CLIPPED,"-",
                                          mr_par_bloq_laser.dig_agencia CLIPPED,
                                          " ",
                                          mr_relat.cod_cedente
  END CASE

  CASE
    WHEN mr_relat.cod_banco[1,3] = "275"
        LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7] #frank item 06

    WHEN mr_relat.cod_banco[1,3] = "356"
        LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7]

    WHEN mr_relat.cod_banco[1,3] = "033"
        LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,7]

    WHEN mr_relat.cod_banco[1,3] = '341' # ITAU
       LET mr_demonst.val_nosso_num = mr_relat.nosso_numero[1,8]


    WHEN mr_relat.cod_banco[1,3] = "237"
        LET mr_demonst.val_nosso_num = mr_relat.cod_carteira[1,2],
                                       "/",
                                       mr_relat.nosso_numero
    OTHERWISE
       LET mr_demonst.val_nosso_num = mr_relat.nosso_numero
  END CASE

  FOR m_ind3 = 1 TO l_qtd_registros
     IF ma_demonst_item[m_ind3].qtd_sem_desconto IS NULL
     OR ma_demonst_item[m_ind3].qtd_sem_desconto = " " THEN
        LET ma_demonst_item[m_ind3].qtd_sem_desconto = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_com_desconto IS NULL
     OR ma_demonst_item[m_ind3].qtd_com_desconto = " " THEN
        LET ma_demonst_item[m_ind3].qtd_com_desconto = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_carreteiro IS NULL
     OR ma_demonst_item[m_ind3].qtd_carreteiro = " " THEN
        LET ma_demonst_item[m_ind3].qtd_carreteiro = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_agregado IS NULL
     OR ma_demonst_item[m_ind3].qtd_agregado = " " THEN
        LET ma_demonst_item[m_ind3].qtd_agregado = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_frota IS NULL
     OR ma_demonst_item[m_ind3].qtd_frota = " " THEN
        LET ma_demonst_item[m_ind3].qtd_frota = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_out_func IS NULL
     OR ma_demonst_item[m_ind3].qtd_out_func = " " THEN
        LET ma_demonst_item[m_ind3].qtd_out_func = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_repesquisa IS NULL
     OR ma_demonst_item[m_ind3].qtd_repesquisa = " " THEN
        LET ma_demonst_item[m_ind3].qtd_repesquisa = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_recad_agr IS NULL
     OR ma_demonst_item[m_ind3].qtd_recad_agr = " " THEN
        LET ma_demonst_item[m_ind3].qtd_recad_agr = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_recad_fro IS NULL
     OR ma_demonst_item[m_ind3].qtd_recad_fro = " " THEN
        LET ma_demonst_item[m_ind3].qtd_recad_fro = 0
     END IF

     IF ma_demonst_item[m_ind3].qtd_recad_out_f IS NULL
     OR ma_demonst_item[m_ind3].qtd_recad_out_f = " " THEN
        LET ma_demonst_item[m_ind3].qtd_recad_out_f = 0
     END IF

     IF ma_demonst_item[m_ind3].val_sem_desconto IS NULL
     OR ma_demonst_item[m_ind3].val_sem_desconto = " " THEN
        LET ma_demonst_item[m_ind3].val_sem_desconto = 0
     END IF

     IF ma_demonst_item[m_ind3].val_com_desconto IS NULL
     OR ma_demonst_item[m_ind3].val_com_desconto = " " THEN
        LET ma_demonst_item[m_ind3].val_com_desconto = 0
     END IF

     IF ma_demonst_item[m_ind3].val_carreteiro IS NULL
     OR ma_demonst_item[m_ind3].val_carreteiro = " " THEN
        LET ma_demonst_item[m_ind3].val_carreteiro = 0
     END IF

     IF ma_demonst_item[m_ind3].val_agregado IS NULL
     OR ma_demonst_item[m_ind3].val_agregado = " " THEN
        LET ma_demonst_item[m_ind3].val_agregado = 0
     END IF

     IF ma_demonst_item[m_ind3].val_frota IS NULL
     OR ma_demonst_item[m_ind3].val_frota = " " THEN
        LET ma_demonst_item[m_ind3].val_frota = 0
     END IF

     IF ma_demonst_item[m_ind3].val_out_func IS NULL
     OR ma_demonst_item[m_ind3].val_out_func = " " THEN
        LET ma_demonst_item[m_ind3].val_out_func = 0
     END IF

     IF ma_demonst_item[m_ind3].val_repesquisa IS NULL
     OR ma_demonst_item[m_ind3].val_repesquisa = " " THEN
        LET ma_demonst_item[m_ind3].val_repesquisa = 0
     END IF

     IF ma_demonst_item[m_ind3].val_recad_agr IS NULL
     OR ma_demonst_item[m_ind3].val_recad_agr = " " THEN
        LET ma_demonst_item[m_ind3].val_recad_agr = 0
     END IF

     IF ma_demonst_item[m_ind3].val_recad_fro IS NULL
     OR ma_demonst_item[m_ind3].val_recad_fro = " " THEN
        LET ma_demonst_item[m_ind3].val_recad_fro = 0
     END IF

     IF ma_demonst_item[m_ind3].val_recad_out_f IS NULL
     OR ma_demonst_item[m_ind3].val_recad_out_f = " " THEN
        LET ma_demonst_item[m_ind3].val_recad_out_f = 0
     END IF

     IF ma_tip_consulta[m_ind3].qtd_sem_desconto IS NULL
     OR ma_tip_consulta[m_ind3].qtd_sem_desconto = " " THEN
        LET ma_tip_consulta[m_ind3].qtd_sem_desconto = 0
     END IF

     IF ma_tip_consulta[m_ind3].qtd_com_desconto IS NULL
     OR ma_tip_consulta[m_ind3].qtd_com_desconto = " " THEN
        LET ma_tip_consulta[m_ind3].qtd_com_desconto = 0
     END IF

     IF ma_tip_consulta[m_ind3].val_sem_desconto IS NULL
     OR ma_tip_consulta[m_ind3].val_sem_desconto = " " THEN
        LET ma_tip_consulta[m_ind3].val_sem_desconto = 0
     END IF

     IF ma_tip_consulta[m_ind3].val_com_desconto IS NULL
     OR ma_tip_consulta[m_ind3].val_com_desconto = " " THEN
        LET ma_tip_consulta[m_ind3].val_com_desconto = 0
     END IF


     #TOTAIS TIPO DE CONSULTA
     LET mr_tip_consulta.qtd_sem_desconto  = mr_tip_consulta.qtd_sem_desconto + ma_tip_consulta[m_ind3].qtd_sem_desconto
     LET mr_tip_consulta.qtd_com_desconto  = mr_tip_consulta.qtd_com_desconto + ma_tip_consulta[m_ind3].qtd_com_desconto
     LET mr_tip_consulta.val_sem_desconto  = mr_tip_consulta.val_sem_desconto + ma_tip_consulta[m_ind3].val_sem_desconto
     LET mr_tip_consulta.val_com_desconto  = mr_tip_consulta.val_com_desconto + ma_tip_consulta[m_ind3].val_com_desconto

     LET mr_demonst_totais.qtd_sem_desconto = (mr_demonst_totais.qtd_sem_desconto   + ma_demonst_item[m_ind3].qtd_sem_desconto) - ma_tip_consulta[m_ind3].qtd_sem_desconto
     LET mr_demonst_totais.qtd_com_desconto = (mr_demonst_totais.qtd_com_desconto   + ma_demonst_item[m_ind3].qtd_com_desconto) - ma_tip_consulta[m_ind3].qtd_com_desconto
     LET mr_demonst_totais.qtd_carreteiro   = mr_demonst_totais.qtd_carreteiro     + ma_demonst_item[m_ind3].qtd_carreteiro
     LET mr_demonst_totais.qtd_agregado     = mr_demonst_totais.qtd_agregado       + ma_demonst_item[m_ind3].qtd_agregado
     LET mr_demonst_totais.qtd_frota        = mr_demonst_totais.qtd_frota          + ma_demonst_item[m_ind3].qtd_frota
     LET mr_demonst_totais.qtd_out_func     = mr_demonst_totais.qtd_out_func       + ma_demonst_item[m_ind3].qtd_out_func
     LET mr_demonst_totais.qtd_repesquisa   = mr_demonst_totais.qtd_repesquisa     + ma_demonst_item[m_ind3].qtd_repesquisa
     LET mr_demonst_totais.qtd_recad_agr    = mr_demonst_totais.qtd_recad_agr      + ma_demonst_item[m_ind3].qtd_recad_agr
     LET mr_demonst_totais.qtd_recad_fro    = mr_demonst_totais.qtd_recad_fro      + ma_demonst_item[m_ind3].qtd_recad_fro
     LET mr_demonst_totais.qtd_recad_out_f  = mr_demonst_totais.qtd_recad_out_f    + ma_demonst_item[m_ind3].qtd_recad_out_f
     LET mr_demonst_totais.val_sem_desconto = (mr_demonst_totais.val_sem_desconto   + ma_demonst_item[m_ind3].val_sem_desconto) - ma_tip_consulta[m_ind3].val_sem_desconto
     LET mr_demonst_totais.val_com_desconto = (mr_demonst_totais.val_com_desconto   + ma_demonst_item[m_ind3].val_com_desconto) - ma_tip_consulta[m_ind3].val_com_desconto
     LET mr_demonst_totais.val_carreteiro   = mr_demonst_totais.val_carreteiro     + ma_demonst_item[m_ind3].val_carreteiro
     LET mr_demonst_totais.val_agregado     = mr_demonst_totais.val_agregado       + ma_demonst_item[m_ind3].val_agregado
     LET mr_demonst_totais.val_frota        = mr_demonst_totais.val_frota          + ma_demonst_item[m_ind3].val_frota
     LET mr_demonst_totais.val_out_func     = mr_demonst_totais.val_out_func       + ma_demonst_item[m_ind3].val_out_func
     LET mr_demonst_totais.val_repesquisa   = mr_demonst_totais.val_repesquisa     + ma_demonst_item[m_ind3].val_repesquisa
     LET mr_demonst_totais.val_recad_agr    = mr_demonst_totais.val_recad_agr      + ma_demonst_item[m_ind3].val_recad_agr
     LET mr_demonst_totais.val_recad_fro    = mr_demonst_totais.val_recad_fro      + ma_demonst_item[m_ind3].val_recad_fro
     LET mr_demonst_totais.val_recad_out_f  = mr_demonst_totais.val_recad_out_f    + ma_demonst_item[m_ind3].val_recad_out_f
  END FOR

  LET mr_demonst.val_outros_desc    = l_total_negativo

  LET l_val_outros_desc          = mr_demonst.val_outros_desc

  IF l_val_outros_desc < 0 THEN
     LET l_val_outros_desc = l_val_outros_desc * (-1)
  END IF

  LET mr_demonst.val_desconto       = mr_cre_compl_docum.val_desc_comercial
  LET mr_demonst.val_val_acom       = mr_cre_compl_docum.val_acumulado_ant

  LET mr_demonst.val_cons_pesq      = mr_demonst_totais.val_sem_desconto    +
                                      mr_demonst_totais.val_com_desconto    +
                                      mr_demonst_totais.val_carreteiro      +
                                      mr_demonst_totais.val_agregado        +
                                      mr_demonst_totais.val_frota           +
                                      mr_demonst_totais.val_out_func        +
                                      mr_demonst_totais.val_repesquisa      +
                                      mr_demonst_totais.val_recad_agr       +
                                      mr_demonst_totais.val_recad_fro       +
                                      mr_demonst_totais.val_recad_out_f



  IF m_verifica_tip_consulta_pdf = TRUE THEN
     LET mr_demonst.val_sub_total = #l_val_outros_desc - #mr_demonst.val_outros_desc       -
                                    mr_demonst.val_desconto          -
                                    m_val_iss_2                      -
                                    m_val_pis_2                      -
                                    m_val_confins_2                  -
                                    m_val_csll_2

     LET mr_demonst.val_sub_total = mr_demonst.val_sub_total         +
                                    mr_tip_consulta.val_sem_desconto +
                                    mr_tip_consulta.val_com_desconto +
                                    mr_demonst.val_cons_pesq         +
                                    mr_cre_compl_docum.val_acumulado_ant

     LET mr_demonst.val_sub_total = mr_demonst.val_sub_total - l_val_outros_desc

  ELSE
     LET mr_demonst.val_sub_total = (mr_demonst.val_cons_pesq   -
                                     #l_val_outros_desc - #mr_demonst.val_outros_desc -
                                     mr_demonst.val_desconto    -
                                     m_val_iss_2                -
                                     m_val_pis_2                -
                                     m_val_confins_2            -
                                     m_val_csll_2               )

     LET mr_demonst.val_sub_total = mr_demonst.val_sub_total +
                                    mr_cre_compl_docum.val_acumulado_ant

     LET mr_demonst.val_sub_total = mr_demonst.val_sub_total - l_val_outros_desc
  END IF

  #marlon
  LET mr_demonst.val_total_fat = mr_demonst.val_sub_total -
                                 m_val_irrf_2             -
                                 mr_demonst.val_inss_2

  #CARREGA TODOS OS TOTAIS PARA SEREM IMPRESSOS NO DEMONSTRATIVO RESUMO.
  IF m_ja_pulou_linha = FALSE THEN
     IF mr_cre_compl_docum.qtd_preco_minimo > 0 THEN
        LET m_ind_p_bloqueto = m_ind_p_bloqueto + 1
        LET m_ja_pulou_linha = TRUE
     END IF
  END IF

  WHENEVER ERROR CONTINUE
    SELECT nom_reduzido
      INTO l_nome_praca
      FROM clientes
     WHERE cod_cliente = m_cnpj_cli_agrupado
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
     LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].praca = l_nome_praca
  ELSE
     LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].praca = m_cnpj_cli_agrupado
  END IF

  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_sem_desconto   = mr_demonst_totais.qtd_sem_desconto + mr_tip_consulta.qtd_sem_desconto
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_com_desconto   = mr_demonst_totais.qtd_com_desconto + mr_tip_consulta.qtd_com_desconto
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_carreteiro     = mr_demonst_totais.qtd_carreteiro
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_agregado       = mr_demonst_totais.qtd_agregado
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_frota          = mr_demonst_totais.qtd_frota
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_out_func       = mr_demonst_totais.qtd_out_func
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_repesquisa     = mr_demonst_totais.qtd_repesquisa
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_recad_agr      = mr_demonst_totais.qtd_recad_agr
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_recad_fro      = mr_demonst_totais.qtd_recad_fro
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].qtd_recad_out_f    = mr_demonst_totais.qtd_recad_out_f
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_sem_desconto   = mr_demonst_totais.val_sem_desconto + mr_tip_consulta.val_sem_desconto
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_com_desconto   = mr_demonst_totais.val_com_desconto + mr_tip_consulta.val_com_desconto
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_carreteiro     = mr_demonst_totais.val_carreteiro
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_agregado       = mr_demonst_totais.val_agregado
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_frota          = mr_demonst_totais.val_frota
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_out_func       = mr_demonst_totais.val_out_func
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_repesquisa     = mr_demonst_totais.val_repesquisa
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_recad_agr      = mr_demonst_totais.val_recad_agr
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_recad_fro      = mr_demonst_totais.val_recad_fro
  LET ma_total_demonst_p_bloqueto[m_ind_p_bloqueto].val_recad_out_f    = mr_demonst_totais.val_recad_out_f
  LET m_ind_p_bloqueto = m_ind_p_bloqueto + 1
  #-----

  IF pol1377_imprime_demonstrativo_detalhado() = FALSE THEN
     CALL log0030_mensagem("Erro ao imprimir Demonstrativo em PDF.","exclamation")
  END IF
  END IF


 END FUNCTION

#-------------------------------------------------#
 FUNCTION pol1377_imprime_demonstrativo_detalhado()
#-------------------------------------------------#
  DEFINE l_ind2             SMALLINT,
         l_ind_item         SMALLINT,
         l_ind_item_aux     INTEGER,
         l_num_pag          SMALLINT

  DEFINE l_diretorio_config CHAR(100),
         l_diretorio_pdf    CHAR(100),
         l_nom_banco        CHAR(30),
         l_caminho_pdf      CHAR(100),
         l_caminho_imp      CHAR(200),
         l_arquivo_remove   CHAR(200)

  DEFINE l_nome_praca       LIKE clientes.nom_reduzido
  DEFINE l_den_item         LIKE item.den_item_reduz
  DEFINE l_texto            CHAR(80)

  FOR l_num_pag = m_qtd_pag_demonst_pdf TO 1 step -1

    LET m_ind_pdf = 1
    LET ma_config[m_ind_pdf].linha = "cod_cliente = ",mr_relat.cod_cliente

    CASE mr_relat.cod_banco[1,3]
       WHEN 237 LET l_nom_banco = "bancoBradesco"
       WHEN 320 LET l_nom_banco = "bicBanco"
       WHEN 275 LET l_nom_banco = "bancoReal"
       WHEN 356 LET l_nom_banco = "bancoReal"
       WHEN 33  LET l_nom_banco = "bancoReal"
       WHEN 341 LET l_nom_banco = "bancoItau"
       WHEN 453 LET l_nom_banco = "bancoRural"
       WHEN 104 LET l_nom_banco = "bancoCaixa" #"CAIXA ECONOMICA FEDERAL"
    END CASE

    #497350 1-com demonstrativo 0-sem demonstrativo

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'tipo_layout=1'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'print_verso=0'

    #LET m_ind_pdf = m_ind_pdf + 1
    #LET ma_config[m_ind_pdf].linha = 'num_pagina = ', l_num_pag USING '<<<&', '/', m_qtd_pag_demonst_pdf USING '<<<&'

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "nom_banco = ",l_nom_banco #mr_relat.nom_banco
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "concatenar=sim"

    LET m_ind_pdf = m_ind_pdf + 1
    LET l_caminho_pdf = m_diretorio_pdf CLIPPED,pol1377_processa_nome_arquivo()
    LET ma_config[m_ind_pdf].linha = "caminho = ",l_caminho_pdf

    IF m_deletou_arquivo_atual = FALSE THEN

       INITIALIZE l_arquivo_remove TO NULL
       IF g_ies_ambiente <> "W" THEN
          LET l_arquivo_remove = 'chmod 664 ',l_caminho_pdf CLIPPED
       END IF
       RUN l_arquivo_remove

       INITIALIZE l_arquivo_remove TO NULL
       IF g_ies_ambiente = "W" THEN
          LET l_arquivo_remove = 'del ',l_caminho_pdf CLIPPED
       ELSE
          LET l_arquivo_remove = 'rm ',l_caminho_pdf CLIPPED
       END IF
       RUN l_arquivo_remove

       LET m_deletou_arquivo_atual = TRUE
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = "temporario = ",m_diretorio_pdf CLIPPED

    #Topo do demonstrativo
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'tit_documento = DEMONSTRATIVO TELERISCO Nº'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'dem_telerisco_num = ', mr_demonst.dem_telerisco_num

    #linha 1
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_adm = ADM:'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_adm = ', mr_demonst.val_adm
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_emissao = EMISSAO:'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_emissao = ', mr_demonst.val_emissao USING 'DD/MM/YYYY'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_vencimento = VENCIMENTO:'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_vencimento = ', mr_demonst.val_vencimento USING 'DD/MM/YYYY'

    #Linha 2
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_raz_soc = RAZAO SOCIAL'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_raz_soc = ', mr_demonst.val_raz_soc
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_cnpj_cpf = CNPJ/CPF'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_cnpj_cpf = ', mr_demonst.val_cnpj_cpf
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_insc_est = INSCR.ESTADUAL'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_insc_est = ', mr_demonst.val_insc_est

    #Cabeçalho
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_consultas = CONSULTAS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_sem_descont = SEM DESCONTO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_com_descnt = COM DESCONTO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_total = TOTAL'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_pesquisas = PESQUISAS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_carreteiro = CARRETEIRO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_agregado = AGREGADO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_frota = FROTA'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_out_func = OUT.FUNC'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_repesquisa = REPESQUISA'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_recad_agr = RECAD.AGR'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_recad_fro = RECAD.FRO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_recad_out_f = RECAD.OUT.F'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_pracas = PRACAS'

    FOR l_ind_item = 1 TO m_qtd_itens_por_pag_pdf
      LET l_ind_item_aux = ( m_qtd_itens_por_pag_pdf * (l_num_pag - 1) ) + l_ind_item

      CALL pol1377_preenche_celula_dem(l_ind_item, 0, ma_demonst_item[l_ind_item_aux].praca)
      CALL pol1377_preenche_celula_dem(l_ind_item, 1, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_sem_desconto, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 2, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_com_desconto, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 3, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_sem_desconto +
                                                                                   ma_demonst_item[l_ind_item_aux].qtd_com_desconto, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 4, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_carreteiro, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 5, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_agregado, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 6, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_frota, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 7, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_out_func, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 8, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_repesquisa, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 9, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_agr, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 10, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_fro, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 11, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_recad_out_f, FALSE))
      CALL pol1377_preenche_celula_dem(l_ind_item, 12, pol1377_mostra_valor_demonst(ma_demonst_item[l_ind_item_aux].qtd_carreteiro  +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_agregado    +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_frota       +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_out_func    +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_repesquisa  +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_recad_agr   +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_recad_fro   +
                                                                                       ma_demonst_item[l_ind_item_aux].qtd_recad_out_f, FALSE))


    END FOR

    #Totais do demonstrativo
    CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 0, 'TOTAIS')
    CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 0, 'VALOR  TOTAL')

    #Só imprime o total na última pagina
    IF l_num_pag = m_qtd_pag_demonst_pdf THEN
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 1, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_sem_desconto,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 1, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_sem_desconto,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 2, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_com_desconto,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 2, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_com_desconto,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 3, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_sem_desconto +
                                                                                               mr_demonst_totais.qtd_com_desconto,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 3, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_sem_desconto +
                                                                                               mr_demonst_totais.val_com_desconto,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 4, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_carreteiro,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 4, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_carreteiro,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 5, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_agregado,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 5, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_agregado,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 6, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_frota,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 6, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_frota,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 7, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_out_func,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 7, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_out_func,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 8, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_repesquisa,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 8, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_repesquisa,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 9, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_agr,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 9, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_agr,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 10, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_fro,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 10, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_fro,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 11, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_recad_out_f,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 11, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_recad_out_f,2))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 1, 12, pol1377_mostra_valor_demonst(mr_demonst_totais.qtd_carreteiro +
                                                                                                     mr_demonst_totais.qtd_agregado   +
                                                                                                     mr_demonst_totais.qtd_frota      +
                                                                                                     mr_demonst_totais.qtd_out_func   +
                                                                                                     mr_demonst_totais.qtd_repesquisa +
                                                                                                     mr_demonst_totais.qtd_recad_agr  +
                                                                                                     mr_demonst_totais.qtd_recad_fro  +
                                                                                                     mr_demonst_totais.qtd_recad_out_f,FALSE))
       CALL pol1377_preenche_celula_dem(m_qtd_itens_por_pag_pdf + 2, 12, pol1377_troca_ponto_por_virgula(mr_demonst_totais.val_carreteiro +
                                                                                                     mr_demonst_totais.val_agregado   +
                                                                                                     mr_demonst_totais.val_frota      +
                                                                                                     mr_demonst_totais.val_out_func   +
                                                                                                     mr_demonst_totais.val_repesquisa +
                                                                                                     mr_demonst_totais.val_recad_agr  +
                                                                                                     mr_demonst_totais.val_recad_fro  +
                                                                                                     mr_demonst_totais.val_recad_out_f,2))
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_recibo_do = RECIBO DO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_sacado   = SACADO'

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_extra = DEBITO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_extra = ', pol1377_mostra_valor_demonstrativo_pdf((mr_tip_consulta.val_sem_desconto + mr_tip_consulta.val_com_desconto), l_num_pag, FALSE)

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_cedente = CEDENTE'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'cedente = ', mr_demonst.val_cedente #m_den_cedente esta variavel vem carregada com o CNPJ tbm.
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_age_cod_ced = AGENCIA/COD.CEDENTE'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'agencia = ', mr_relat.cod_agencia #mr_demonst.val_age_cod_ced
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'contaCorrente = ', mr_relat.cod_cedente
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_nosso_num = NOSSO NUMERO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_nosso_num = ', mr_demonst.val_nosso_num
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_cons_pesq = TOTAL CONS+PESQ'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_cons_pesq = ', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_cons_pesq, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_outros_desc = (-)OUTROS DESC'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_outros_desc = ', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_outros_desc, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_desconto = (-)DESCONTO'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_desconto = ', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_desconto, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_val_acom = (+) VLR ACUMULADO ANT'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_val_acom = ', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_val_acom, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_iss = ISS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_iss_1 = (', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_iss_1, l_num_pag, TRUE) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_iss_2 = ', pol1377_mostra_valor_demonstrativo_pdf(m_val_iss_2, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_pis = PIS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_pis_1 = (', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_pis_1, l_num_pag, TRUE) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_pis_2 = ', pol1377_mostra_valor_demonstrativo_pdf(m_val_pis_2, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_confins = COFINS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_confins_1 = (', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_confins_1, l_num_pag, TRUE) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_confins_2 = ', pol1377_mostra_valor_demonstrativo_pdf(m_val_confins_2, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_csll = CSLL'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_csll_1 = (', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_csll_1, l_num_pag, TRUE) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_csll_2 = ', pol1377_mostra_valor_demonstrativo_pdf(m_val_csll_2, l_num_pag, FALSE)
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_sub_total = SUB TOTAL'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_sub_total = ', pol1377_mostra_valor_demonstrativo_pdf( mr_demonst.val_sub_total ,
                                                                                                 l_num_pag                ,
                                                                                                 FALSE                    )

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_irrf = IRRF'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_irrf_1 = (', pol1377_mostra_valor_demonstrativo_pdf(mr_demonst.val_irrf_1, l_num_pag, TRUE) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_irrf_2 = ', pol1377_mostra_valor_demonstrativo_pdf(m_val_irrf_2, l_num_pag, FALSE)

    #::: Valor de INSS
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_inss = INSS'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_inss_1 = (', pol1377_mostra_valor_demonstrativo_pdf( mr_demonst.val_inss_1, l_num_pag, TRUE ) CLIPPED, '%)'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_inss_2 = ', pol1377_mostra_valor_demonstrativo_pdf( mr_demonst.val_inss_2, l_num_pag, FALSE )
    #:::

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'txt_total_fat = TOTAL DESTA FATURA'
    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'val_total_fat = ', pol1377_mostra_valor_demonstrativo_pdf( mr_demonst.val_total_fat ,
                                                                                                 l_num_pag                ,
                                                                                                 FALSE                    )

    IF m_verifica_tip_consulta_pdf = TRUE THEN
       WHENEVER ERROR CONTINUE
         SELECT texto
           INTO l_texto
           FROM cre_txt_sist_gerad
          WHERE programa        = 'CRE1055' 
            AND sistema_gerador = mr_cre_compl_docum.sistema_gerador
            AND sequencia_texto = 3
            AND linha_texto     = 1
            AND tip_texto       = 'B'
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("SELECT","CRE_TXT_SIST_GERAD")
       END IF

       IF l_texto IS NULL
       OR l_texto = " " THEN
          LET l_texto = "*Este servico nao consta no relatorio."
       END IF
    END IF

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'texto_comp = ', l_texto

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'cod_cip = ', mr_demonst.cod_cip

    LET m_ind_pdf = m_ind_pdf + 1
    LET ma_config[m_ind_pdf].linha = 'num_pagina = ', m_total_pag_aux USING '<<<&', '/', m_total_pag USING '<<<&'
    LET m_total_pag_aux = m_total_pag_aux - 1

    IF m_reimpressao = FALSE THEN
       LET l_diretorio_config = m_diretorio_pdf CLIPPED, m_seq_geral_boleto USING "<<<<<",  "configuracao.",p_user CLIPPED,".txt"
       LET m_seq_geral_boleto = m_seq_geral_boleto + 1
    ELSE
       LET l_diretorio_config = m_diretorio_pdf CLIPPED, "configuracao.",p_user CLIPPED,".txt"
    END IF

    CALL pol1377_grava_sequencia_carta( l_diretorio_config ,
                                        ""                 ,
                                        "D"                )

    CALL log4070_channel_open_file("configuracao",l_diretorio_config,"w")

    CALL log4070_channel_set_delimiter("configuracao","")

    FOR l_ind2=1 TO m_ind_pdf
       CALL log4070_channel_write("configuracao",ma_config[l_ind2].linha)
    END FOR

    CALL log4070_channel_close("configuracao")

    INITIALIZE l_arquivo_remove TO NULL
    IF g_ies_ambiente <> "W" THEN
       LET l_arquivo_remove = 'chmod 664 ',l_diretorio_config CLIPPED
    END IF
    RUN l_arquivo_remove

    LET g_comando = "java DemonstrativoTelerisco ",l_diretorio_config

    RUN g_comando

  END FOR

  RETURN TRUE

 END FUNCTION

#----------------------------------------------------------#
 FUNCTION pol1377_mostra_valor_demonstrativo_pdf(l_valor   ,
                                                 l_num_pag ,
                                                 l_ies_perc)
#----------------------------------------------------------#
  {Parâmetros:
   Valor a ser impresso;
   Número da página: para demonstrativos com mais de uma página, imprime o valor somente no bloqueto
                     da última página. Nos outros, imprime ******;
   Indicador de percentual: indica se o campo a ser impresso é percentual. Passado true no caso da
                            impressão dos % dos impostos. Assim, independente da página será impresso
                            o percentual do imposto. Já para o valor, só será impresso na última página.}

 DEFINE l_valor    DECIMAL(16,2),
        l_num_pag  SMALLINT,
        l_ies_perc SMALLINT

 IF (l_valor IS NULL) THEN
    RETURN ' '
 ELSE
    IF (l_num_pag = m_qtd_pag_demonst_pdf) OR (l_ies_perc = true) THEN
       RETURN pol1377_troca_ponto_por_virgula(l_valor,2) #Fixo 2 decimais para valor
    ELSE
       RETURN '******'
    END IF
 END IF

 END FUNCTION


#---------------------------------------------------#
 FUNCTION pol1377_calcula_qtd_pag_total(l_empresa   ,
                                        l_docum     ,
                                        l_tip_docum )
#---------------------------------------------------#

 DEFINE l_empresa   LIKE cre_compl_docum.empresa  ,
        l_docum     LIKE cre_compl_docum.docum    ,
        l_tip_docum LIKE cre_compl_docum.tip_docum

 DEFINE l_cnpj_cli_agrupado  LIKE cre_itcompl_docum.cnpj_cli_agrupado

 DEFINE l_qtd_itens              INTEGER
 DEFINE l_qtd_itens_aux          INTEGER
 DEFINE l_qtd_praca              INTEGER
 DEFINE l_qtd_itens_bloqueto     INTEGER
 DEFINE l_qtd_itens_bloqueto_aux INTEGER

 LET l_qtd_itens              = 0
 LET l_qtd_itens_aux          = 0
 LET l_qtd_itens_bloqueto     = 0
 LET l_qtd_itens_bloqueto_aux = 0
 LET m_total_pag              = 0
 LET m_total_pag_aux          = 0


 WHENEVER ERROR CONTINUE
  DECLARE cq_qtd_pag CURSOR FOR
   SELECT DISTINCT(cnpj_cli_agrupado)
     FROM ctr_titulo_item
    WHERE ctr_titulo_item.empresa   = l_empresa
      AND ctr_titulo_item.titulo     = l_docum
      AND ctr_titulo_item.tip_titulo = l_tip_docum
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","cq_contrato_agrupado")
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_qtd_pag INTO l_cnpj_cli_agrupado
 WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("FOREACH","CQ_CONTRATO_AGRUPADO")
    END IF

    LET l_qtd_itens_bloqueto = l_qtd_itens_bloqueto + 1

    WHENEVER ERROR CONTINUE
      SELECT COUNT(DISTINCT ctr_titulo_item.praca)
        INTO l_qtd_praca
        FROM ctr_titulo_item, cre_classif_item
       WHERE ctr_titulo_item.empresa           = l_empresa
         AND ctr_titulo_item.titulo             = l_docum
         AND ctr_titulo_item.tip_titulo         = l_tip_docum
         AND ctr_titulo_item.cnpj_ctr_agrupado = l_cnpj_cli_agrupado
         AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
         AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
         AND cre_classif_item.empresa            = ctr_titulo_item.empresa
         AND cre_classif_item.item               = ctr_titulo_item.item
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","ctr_titulo_item")
    END IF

    IF l_qtd_praca > 78 THEN
       LET l_qtd_itens_aux = log_truncate_value((l_qtd_praca / 78), 0) + 1
       LET l_qtd_itens = l_qtd_itens + l_qtd_itens_aux
    ELSE
       LET l_qtd_itens = l_qtd_itens + 1
    END IF

 END FOREACH

 #EFETUA OS TRATAMENTOS PARA PREMIO MINIMO.
 CALL pol1377_total_itens_por_demonstrativo()
 IF  mr_cre_compl_docum.qtd_preco_minimo > 0
 AND mr_cre_compl_docum.qtd_preco_minimo >= m_total_itens_demonst THEN
    LET l_qtd_itens_bloqueto = l_qtd_itens_bloqueto + 1
 END IF

 LET l_qtd_itens_bloqueto_aux = log_truncate_value((l_qtd_itens_bloqueto / 35), 0) + 1

 LET m_total_pag = l_qtd_itens + l_qtd_itens_bloqueto_aux
 LET m_total_pag_aux = m_total_pag

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION pol1377_calcula_qtd_pag_so_bloqueto(l_empresa   ,
                                              l_docum     ,
                                              l_tip_docum )
#---------------------------------------------------------#

 DEFINE l_empresa   LIKE cre_compl_docum.empresa  ,
        l_docum     LIKE cre_compl_docum.docum    ,
        l_tip_docum LIKE cre_compl_docum.tip_docum

 DEFINE l_qtd_praca     INTEGER

 LET m_total_pag        = 0
 LET m_total_pag_aux    = 0

 WHENEVER ERROR CONTINUE
   SELECT COUNT(DISTINCT ctr_titulo_item.praca)
     INTO l_qtd_praca
     FROM ctr_titulo_item, cre_classif_item
    WHERE ctr_titulo_item.empresa   = l_empresa
      AND ctr_titulo_item.titulo     = l_docum
      AND ctr_titulo_item.tip_titulo = l_tip_docum
      AND (MONTH(ctr_titulo_item.dat_servico) = MONTH(mr_docum.dat_competencia)
      AND   YEAR(ctr_titulo_item.dat_servico) =  YEAR(mr_docum.dat_competencia))
      AND cre_classif_item.empresa    = ctr_titulo_item.empresa
      AND cre_classif_item.item       = ctr_titulo_item.item
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql('SELECAO','ctr_titulo_item3')
 END IF

 #EFETUA OS TRATAMENTOS PARA PREMIO MINIMO.
 CALL pol1377_total_itens_por_demonstrativo()
 IF  mr_cre_compl_docum.qtd_preco_minimo > 0
 AND mr_cre_compl_docum.qtd_preco_minimo >= m_total_itens_demonst THEN
    LET l_qtd_praca = l_qtd_praca + 1
 END IF

 IF l_qtd_praca > 35 THEN
    LET m_total_pag = log_truncate_value((l_qtd_praca / 35), 0) + 1
 ELSE
    LET m_total_pag = 1
 END IF

 LET m_total_pag_aux = m_total_pag

 END FUNCTION

#-----------------------------------------------#
 FUNCTION pol1377_total_itens_por_demonstrativo()
#-----------------------------------------------#

 DEFINE sql_stmt             CHAR(3000)

 #INITIALIZE m_total_itens_demonst TO NULL

 #528048 ->
 LET sql_stmt = " SELECT SUM(ctr_titulo_item.qtd_item) ",
                "   FROM ctr_titulo_item, cre_classif_item ",
                "  WHERE ctr_titulo_item.empresa     = '",mr_docum.cod_empresa,"' ",
                "    AND ctr_titulo_item.titulo       = '",mr_docum.num_docum,"' ",
                "    AND ctr_titulo_item.tip_titulo   = '",mr_docum.ies_tip_docum,"' ",
                "    AND ctr_titulo_item.item       <> '",mr_cre_compl_docum.item_preco_minimo,"' ",
                "    AND ctr_titulo_item.item        = cre_classif_item.item ",
                "    AND cre_classif_item.empresa      = ctr_titulo_item.empresa "

 IF mr_cre_compl_docum.item_preco_minimo = "01900001" THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND cre_classif_item.classif_item IN (1,2) "
 END IF

 IF mr_cre_compl_docum.item_preco_minimo = "01900002" THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND cre_classif_item.classif_item IN (5) "
 END IF

 IF mr_cre_compl_docum.item_preco_minimo = "01900003" THEN #TESTES MARLON "000095" THEN
    LET sql_stmt = sql_stmt CLIPPED, " AND cre_classif_item.classif_item IN (5,6) "
 END IF

 WHENEVER ERROR CONTINUE
 PREPARE var_sql FROM sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("PREPARE SQL","var_sql",sql_stmt)
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 DECLARE cq_m_total_itens_demonst CURSOR WITH HOLD FOR var_sql
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql_detalhe("DECLARE CURSOR","CQ_M_TOTAL_ITENS_DEMONST",sql_stmt)
    RETURN
 END IF

 WHENEVER ERROR CONTINUE
 FOREACH cq_m_total_itens_demonst INTO m_total_itens_demonst
    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql_detalhe("FOREACH CURSOR","CQ_M_TOTAL_ITENS_DEMONST",sql_stmt)
       RETURN
    END IF

 END FOREACH

 IF m_total_itens_demonst IS NULL
 OR m_total_itens_demonst = " " THEN
    LET m_total_itens_demonst = 0
 END IF

 END FUNCTION

#------------------------------------------------#
 FUNCTION pol1377_verifica_classif_premio_minimo()
#------------------------------------------------#
 DEFINE l_classif_item DECIMAL(5,0)


 IF mr_cre_compl_docum.item_preco_minimo = "01900001"
 OR mr_cre_compl_docum.item_preco_minimo = "01900002"
 OR mr_cre_compl_docum.item_preco_minimo = "01900003" THEN
    IF mr_cre_compl_docum.item_preco_minimo = "01900001" THEN
       LET m_classif_item = "CONSULTAS"
    END IF

    IF mr_cre_compl_docum.item_preco_minimo = "01900002" THEN
       LET m_classif_item = "PESQUISAS"
    END IF

    IF mr_cre_compl_docum.item_preco_minimo = "01900003" THEN
       LET m_classif_item = "PESQUISAS"
    END IF
 ELSE
    WHENEVER ERROR CONTINUE
      SELECT classif_item
        INTO l_classif_item
        FROM cre_classif_item
       WHERE empresa = mr_docum.cod_empresa
         AND item    = mr_cre_compl_docum.item_preco_minimo
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("SELECT","CLASSIF_ITEM")
    END IF

    IF l_classif_item = 1
    OR l_classif_item = 2 THEN
       LET m_classif_item = "CONSULTAS"
    ELSE
       LET m_classif_item = "PESQUISAS"
    END IF
 END IF

 END FUNCTION

#---------------------------------------------------#
 FUNCTION pol1377_grava_cre_docum_compl(l_empresa  ,
                                        l_docum    ,
                                        l_tip_docum)
#---------------------------------------------------#
 DEFINE l_empresa       LIKE cre_docum_compl.empresa
 DEFINE l_docum         LIKE cre_docum_compl.docum
 DEFINE l_tip_docum     LIKE cre_docum_compl.tip_docum

 WHENEVER ERROR CONTINUE
   SELECT empresa
     FROM cre_docum_compl
    WHERE cre_docum_compl.empresa   = l_empresa
      AND cre_docum_compl.docum     = l_docum
      AND cre_docum_compl.tip_docum = l_tip_docum
      AND cre_docum_compl.campo     = "valor_demonstrativo"
 WHENEVER ERROR STOP
 CASE sqlca.sqlcode
    WHEN 100
       WHENEVER ERROR CONTINUE
         INSERT INTO cre_docum_compl(empresa        ,
                                     docum          ,
                                     tip_docum      ,
                                     campo          ,
                                     par_existencia ,
                                     parametro_texto,
                                     parametro_val  ,
                                     parametro_qtd  ,
                                     parametro_dat  )
         VALUES (l_empresa               ,
                 l_docum                 ,
                 l_tip_docum             ,
                 "valor_demonstrativo"   ,
                 NULL                    ,
                 NULL                    ,
                 mr_demonst.val_total_fat,
                 NULL                    ,
                 NULL                    )
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("INSERT","CRE_DOCUM_COMPL")
       END IF

    WHEN 0
       WHENEVER ERROR CONTINUE
         UPDATE cre_docum_compl
            SET cre_docum_compl.parametro_val = mr_demonst.val_total_fat
          WHERE cre_docum_compl.empresa       = l_empresa
            AND cre_docum_compl.docum         = l_docum
            AND cre_docum_compl.tip_docum     = l_tip_docum
            AND cre_docum_compl.campo         = "valor_demonstrativo"
       WHENEVER ERROR STOP
       IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
          CALL log003_err_sql("UPDATE","CRE_DOCUM_COMPL")
       END IF

    OTHERWISE
       CALL log003_err_sql("SELECT","CRE_DOCUM_COMPL")

 END CASE

 END FUNCTION

#------------------------------------------#
 FUNCTION pol1377_carrega_textos_retencao()
#------------------------------------------#
{USO INTERNO
 OBJETIVO: Carregar os textos de retenção de PIS/COFINS/CSLL conforme
           o parametrizado no programa CRE0140 (Tabela PAR_REL_CRE_TEX).

           Seqüência do texto:
           1     - Texto para a retenção hibrido_fat e faturamento.
           2 e 3 - Texto para a retenção hibrido_cre e cre.
}
  DEFINE l_num_seq_texto     LIKE par_rel_cre_tex.num_seq_texto,
         l_num_seq_linha     LIKE par_rel_cre_tex.num_seq_linha,
         l_des_linha         LIKE par_rel_cre_tex.des_linha,
         l_existe_dados      SMALLINT

  WHENEVER ERROR CONTINUE
  DECLARE cq_txt_retencao CURSOR FOR
   SELECT par_rel_cre_tex.num_seq_texto,
          par_rel_cre_tex.num_seq_linha,
          par_rel_cre_tex.des_linha
     FROM par_rel_cre_tex
    WHERE UPPER(par_rel_cre_tex.num_relat) = "CRE1055" 
    ORDER BY par_rel_cre_tex.num_seq_texto,
             par_rel_cre_tex.num_seq_linha
  WHENEVER ERROR STOP
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE CURSOR","CQ_TXT_RETENCAO")
     RETURN FALSE
  END IF

  LET l_existe_dados        = FALSE
  LET m_texto_retencao_fat  = ""
  LET m_texto_retencao_cre1 = ""
  LET m_texto_retencao_cre2 = ""

  INITIALIZE l_num_seq_texto,
             l_num_seq_linha,
             l_des_linha TO NULL

  WHENEVER ERROR CONTINUE
  
  FOREACH cq_txt_retencao INTO l_num_seq_texto,
                               l_num_seq_linha,
                               l_des_linha
  IF sqlca.sqlcode <> 0 THEN
     CALL log003_err_sql("DECLARE CURSOR","CQ_TXT_RETENCAO")
     RETURN FALSE
  END IF

     CASE l_num_seq_texto
        WHEN 1
           LET m_texto_retencao_fat = m_texto_retencao_fat CLIPPED,l_des_linha

        WHEN 2
           LET m_texto_retencao_cre1 = m_texto_retencao_cre1 CLIPPED,l_des_linha

        WHEN 3
           LET m_texto_retencao_cre2 = m_texto_retencao_cre2 CLIPPED,l_des_linha
     END CASE

     LET l_existe_dados = TRUE

  END FOREACH
  
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
  FREE cq_txt_retencao
  WHENEVER ERROR STOP

  IF NOT l_existe_dados THEN
     CALL log0030_mensagem("Textos referente à retenção de PIS/COFINS/CSLL não parametrizados no CRE0140.","exclamation")
     RETURN FALSE
  END IF

  RETURN TRUE

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION pol1377_busca_valores_de_inss( l_cod_empresa   ,
                                         l_num_docum     ,
                                         l_ies_tip_docum )
#---------------------------------------------------------#
 DEFINE l_cod_empresa   LIKE docum.cod_empresa
 DEFINE l_num_docum     LIKE docum.num_docum
 DEFINE l_ies_tip_docum LIKE docum.ies_tip_docum

 DEFINE l_val_base_inss LIKE cre_docum_compl.parametro_val
 DEFINE l_val_inss      LIKE cre_docum_compl.parametro_val
 DEFINE l_pct_inss      LIKE cre_docum_compl.parametro_val

 WHENEVER ERROR CONTINUE
   SELECT SUM( parametro_val )
     INTO l_val_base_inss
     FROM cre_docum_compl
    WHERE empresa         = l_cod_empresa
      AND docum           = l_num_docum
      AND tip_docum       = l_ies_tip_docum
      AND campo           LIKE "%val_base_inss%"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_val_base_inss IS NULL THEN
    LET l_val_base_inss = 0
 END IF

 WHENEVER ERROR CONTINUE
   SELECT SUM( parametro_val )
     INTO l_val_inss
     FROM cre_docum_compl
    WHERE empresa         = l_cod_empresa
      AND docum           = l_num_docum
      AND tip_docum       = l_ies_tip_docum
      AND campo           LIKE "%val_inss%"
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_val_inss IS NULL THEN
    LET l_val_inss = 0
 END IF

 LET l_pct_inss = ( 100 * l_val_inss ) / l_val_base_inss

 RETURN l_pct_inss, l_val_inss

 END FUNCTION

#-------------------------------------#
 FUNCTION pol1377_busca_nome_cliente()
#-------------------------------------#
 DEFINE l_nom_cliente LIKE clientes.nom_cliente

 WHENEVER ERROR CONTINUE
   SELECT nom_cliente
     INTO l_nom_cliente
     FROM clientes
    WHERE cod_cliente = m_cod_cliente_ant
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql('LEITURA','CLIENTES')
 END IF

 RETURN l_nom_cliente

 END FUNCTION

#------------------------------------------------------------------#
 FUNCTION pol1377_verifica_emite_boleto(l_portador, l_tip_portador)
#------------------------------------------------------------------#
 #Verifica se o portador emite boleto.
 DEFINE   l_portador       DECIMAL(4,0),
          l_tip_portador   CHAR(01),
          l_par_existencia CHAR(01)

 WHENEVER ERROR CONTINUE
   SELECT par_existencia
     INTO l_par_existencia
     FROM cre_compl_portador
    WHERE portador     = l_portador
      AND tip_portador = l_tip_portador
      AND campo        = 'emite_boleto'
      AND par_existencia = 'N'
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_par_existencia IS NULL OR l_par_existencia = " " THEN
    LET l_par_existencia = "S"
 END IF

 IF l_par_existencia = "S" THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#----------------------------------------#
 FUNCTION pol1377_trata_mes_competencia()
#----------------------------------------#
 DEFINE l_mes                    SMALLINT

 LET mr_tela2.mes_competencia = mr_tela2.mes_competencia USING '&&'
 DISPLAY BY NAME mr_tela2.mes_competencia

 LET l_mes = mr_tela2.mes_competencia

 IF l_mes < 1 OR l_mes > 12 THEN
    RETURN FALSE
 END IF

 RETURN TRUE

END FUNCTION

#-------------------------------#
 FUNCTION pol1377_popup_docum()
#-------------------------------#
  DEFINE l_comando      CHAR(120),
         l_cont         SMALLINT,
         l_cont_array   SMALLINT,
         l_arr_curr     SMALLINT,
         l_arr_count    SMALLINT,
         l_scr_line     SMALLINT,
         l_empresa_d    CHAR(02),
         l_portador     DECIMAL(4,0),
         l_numero_docum LIKE docum.num_docum,
         l_tipo_docum   LIKE docum.ies_tip_docum,
         l_status       SMALLINT

  DEFINE la_num_docum          ARRAY[300] OF RECORD
         cod_empresa             LIKE docum.cod_empresa,
         num_docum               LIKE docum.num_docum,
         ies_tip_docum           LIKE docum.ies_tip_docum,
         portador                DECIMAL(4,0)
                               END RECORD


  CALL log130_procura_caminho("pol13776") RETURNING l_comando
    OPEN WINDOW w_pol13776 AT 04,12  WITH FORM l_comando
    ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE 1)


  INITIALIZE la_num_docum TO NULL

  WHENEVER ERROR CONTINUE
   DECLARE cp_num_docum CURSOR FOR
     SELECT cre0270_num_docum.cod_empresa, cre0270_num_docum.num_docum,
            cre0270_num_docum.ies_tip_docum
       FROM cre0270_num_docum
      WHERE cre0270_num_docum.nom_usuario = p_user
        AND cre0270_num_docum.cod_programa = p_cod_programa
     ORDER BY cre0270_num_docum.cod_empresa, cre0270_num_docum.num_docum,
              cre0270_num_docum.ies_tip_docum  #1,2,3
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
   END IF

   LET l_cont = 1
   LET l_cont_array = 0

   WHENEVER ERROR CONTINUE
   FOREACH cp_num_docum INTO la_num_docum[l_cont].*
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql("FOREACH","cp_num_docum")
   END IF
      LET l_cont = l_cont + 1
      IF l_cont > 300 THEN
         EXIT FOREACH
      END IF
   END FOREACH
   FREE cp_num_docum

   LET l_cont = l_cont - 1
   CALL set_count(l_cont)

 LET int_flag = 0
 CALL log006_exibe_teclas("01 02 07",p_versao)
 CURRENT WINDOW IS w_pol13776

  INPUT ARRAY la_num_docum WITHOUT DEFAULTS FROM s_num_docum.*
     BEFORE FIELD cod_empresa
      LET l_arr_curr = arr_curr()
      LET l_scr_line = scr_line()

      IF mr_tela2.empresa IS NOT NULL THEN
         LET la_num_docum[l_arr_curr].cod_empresa = mr_tela2.empresa
         DISPLAY la_num_docum[l_arr_curr].cod_empresa TO s_num_docum[l_scr_line].cod_empresa
         LET l_empresa_d = la_num_docum[l_arr_curr].cod_empresa

         NEXT FIELD num_docum
      END IF

    AFTER  FIELD cod_empresa
      IF l_arr_curr > l_cont THEN
         LET l_cont = l_cont + 1
      END IF

      LET l_empresa_d = la_num_docum[l_arr_curr].cod_empresa

    AFTER  FIELD num_docum
      LET l_numero_docum = la_num_docum[l_arr_curr].num_docum
      IF l_numero_docum IS NOT NULL THEN
      ELSE
         DISPLAY " "         TO s_num_docum[l_scr_line].ies_tip_docum
      END IF
      IF l_arr_curr > l_cont THEN
         LET l_cont = l_cont + 1
      END IF

    BEFORE FIELD ies_tip_docum
       LET la_num_docum[l_arr_curr].ies_tip_docum = "DP"
       DISPLAY la_num_docum[l_arr_curr].ies_tip_docum TO s_num_docum[l_scr_line].ies_tip_docum

    AFTER  FIELD ies_tip_docum
      LET l_numero_docum = la_num_docum[l_arr_curr].num_docum
      LET l_tipo_docum   = la_num_docum[l_arr_curr].ies_tip_docum
      IF l_numero_docum IS NOT NULL THEN
         IF l_tipo_docum IS NULL THEN
            CALL LOG0030_mensagem('Informe o tipo de documento.','exclamation')
            NEXT FIELD ies_tip_docum
         ELSE
            WHENEVER ERROR CONTINUE
            SELECT cod_empresa, num_docum, ies_tip_docum
              FROM docum
             WHERE cod_empresa   = l_empresa_d
               AND num_docum     = l_numero_docum
               AND ies_tip_docum = l_tipo_docum
               AND ies_situa_docum <> "C"
            WHENEVER ERROR STOP
            IF sqlca.sqlcode = 0 THEN
            ELSE
               CALL LOG0030_mensagem('Numero de documento nao existe ou cancelado.','exclamation')
               NEXT FIELD num_docum
            END IF
         END IF
      ELSE
         DISPLAY " "         TO s_num_docum[l_scr_line].ies_tip_docum
      END IF
      IF l_arr_curr > l_cont THEN
         LET l_cont = l_cont + 1
      END IF

    BEFORE FIELD portador

         WHENEVER ERROR CONTINUE
         DECLARE cq_portador_docum  CURSOR FOR
          SELECT cod_portador
            FROM docum_banco
           WHERE num_docum     = l_numero_docum
             AND cod_empresa   = l_empresa_d
             AND ies_tip_docum = l_tipo_docum
         WHENEVER ERROR STOP
         IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
            CALL LOG003_err_sql('DECLARE','cq_portador_docum')
         END IF

         WHENEVER ERROR CONTINUE
         FOREACH cq_portador_docum INTO l_portador
            IF sqlca.sqlcode <> 0 THEN
               CALL LOG003_err_sql('FOREACH','cq_portador_docum')
               EXIT FOREACH
            END IF
         END FOREACH
         FREE cq_portador_docum
         WHENEVER ERROR STOP
         LET la_num_docum[l_arr_curr].portador = l_portador
         DISPLAY la_num_docum[l_arr_curr].portador TO s_num_docum[l_scr_line].portador

    AFTER FIELD portador
         LET l_portador = la_num_docum[l_arr_curr].portador
         CALL pol1377_verifica_portador(l_empresa_d, l_portador, "B")
               RETURNING l_status
               IF NOT l_status THEN
                  NEXT FIELD portador
               END IF

         IF  m_portador <> 237
         AND m_portador <> 275
         AND m_portador <> 356
         AND m_portador <> 33
         AND m_portador <> 341
         AND m_portador <> 453
         AND m_portador <> 104
         AND m_portador <> 320
         AND m_portador <> 1   THEN
            CALL log0030_mensagem("Não existe impressão de boleto para o Portador.","Info")
            NEXT FIELD portador
         END IF

        ###controle para portador representante e portador correpondente

    AFTER INSERT
      LET l_cont = l_cont + 1

    ON KEY (control-z, f4)
        #-----
        CASE
          WHEN infield(ies_tip_docum)
            LET l_tipo_docum = cre304_popup_tip_docum()
            IF l_tipo_docum IS NOT NULL  THEN
               CURRENT WINDOW IS w_pol13776
               LET la_num_docum[l_arr_curr].ies_tip_docum = l_tipo_docum
               DISPLAY la_num_docum[l_arr_curr].ies_tip_docum to s_num_docum[l_scr_line].ies_tip_docum
            END IF
        END CASE
         #----

       LET int_flag = 0
       CURRENT WINDOW IS w_pol13776

  END INPUT

  IF NOT int_flag  THEN
     WHENEVER ERROR CONTINUE
       DELETE FROM cre0270_num_docum
        WHERE nom_usuario  = p_user
          AND cod_programa = p_cod_programa
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
        #nao validar
     END IF
     FOR l_cont = 1 TO 300

        IF la_num_docum[l_cont].cod_empresa IS NULL THEN
           EXIT FOR
        END IF


         IF  la_num_docum[l_cont].cod_empresa   IS NOT NULL
         AND la_num_docum[l_cont].cod_empresa   IS NOT NULL
         AND la_num_docum[l_cont].num_docum     IS NOT NULL
         AND la_num_docum[l_cont].ies_tip_docum IS NOT NULL
         AND la_num_docum[l_cont].portador      IS NOT NULL THEN
            LET l_empresa_d     = la_num_docum[l_cont].cod_empresa
            LET l_numero_docum  = la_num_docum[l_cont].num_docum
            LET l_tipo_docum    = la_num_docum[l_cont].ies_tip_docum
            LET l_portador      = la_num_docum[l_cont].portador
            CALL pol1377_grava_temp_num_docum(l_empresa_d, l_numero_docum, l_tipo_docum,
                                              l_portador)
         END IF
     END FOR

     WHENEVER ERROR CONTINUE
     SELECT COUNT(*)
       INTO l_cont_array
       FROM t_num_docum_selec
     WHENEVER ERROR STOP
     IF sqlca.sqlcode <> 0 THEN
     END IF
     IF l_cont_array IS NULL OR l_cont_array = 0 THEN
        RETURN FALSE
     END IF
  ELSE
     LET int_flag = 0
     CLOSE WINDOW w_pol13776
     RETURN FALSE
  END IF

  CLOSE WINDOW w_pol13776

  RETURN TRUE

END FUNCTION

#--------------------------------------------------------------------------------#
 FUNCTION pol1377_grava_temp_num_docum(l_empresa_d, l_numero_docum, l_tipo_docum,
                                       l_portador)
#--------------------------------------------------------------------------------#
  DEFINE l_empresa_d    CHAR(02),
         l_numero_docum LIKE docum.num_docum,
         l_tipo_docum   LIKE docum.ies_tip_docum,
         l_portador     DECIMAL(4,0)

  WHENEVER ERROR CONTINUE
   INSERT INTO t_num_docum_selec(nom_usuario    ,
                                 cod_programa   ,
                                 cod_empresa    ,
                                 num_docum      ,
                                 ies_tip_docum  ,
                                 portador)
                                 VALUES (p_user,
                                         p_cod_programa,
                                         l_empresa_d,
                                         l_numero_docum,
                                         l_tipo_docum,
                                         l_portador)
  WHENEVER ERROR STOP
  IF sqlca.sqlcode = 0 THEN
  ELSE
     CALL log003_err_sql("INCLUSAO", "CRE0270_NUM_DOCUM")
  END IF


END FUNCTION

#------------------------------------#
 FUNCTION pol1377_cria_temp()
#------------------------------------#

  WHENEVER ERROR CONTINUE
   DELETE FROM t_num_docum_selec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   DROP TABLE t_num_docum_selec
  WHENEVER ERROR STOP

  WHENEVER ERROR CONTINUE
   CREATE TEMP TABLE t_num_docum_selec
                     (nom_usuario       CHAR(8)  ,
                      cod_programa      CHAR(7)  ,
                      cod_empresa       CHAR(2)  ,
                      num_docum         CHAR(14) ,
                      ies_tip_docum     CHAR(2),
                      portador          DECIMAL(4,0) ) WITH NO LOG;
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('CRIAÇÃO','t_num_docum_selec')
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol1377_monta_sql_t_carta()
#------------------------------------#
 DEFINE l_sql_stmt      CHAR(1000)
 DEFINE l_stmt_completo CHAR(2000)

 LET l_sql_stmt = " SELECT sequencia          ,",
                         " docum              ,",
                         " vencimento         ,",
                         " nome_cliente       ,",
                         " competencia        ,",
                         " empresa            ,",
                         " nota_fiscal        ,",
                         " ies_tip_docum_orig ,",
                         " nfe                ,",
                         " valor               ",
                    " FROM t_carta_aux ",
                   " ORDER BY sequencia "

 RETURN l_sql_stmt

 END FUNCTION

#------------------------------------------#
 FUNCTION pol1377_atualiza_tabela_t_carta()
#------------------------------------------#
# Alterações realizadas nesta função em julho/2012 por Eduardo Luis Nogueira
# Foi alterada a ordem dos sqls no CASE conforme está comentado.
# Esta alteração foi realizada em acordo com o analista da pamcary Luiz Miranda
# para imprimir primeiro as NFs com valor não nulo e diferente de zeros e que o tipo documento seja 'NF'
# após imprimir as NFs com valor não nulo e diferente de zeros e tipo de documento diferente de 'NF' e
# por último as NFs com valor nulo ou zero

 DEFINE l_sql_stmt CHAR(2000)
 DEFINE l_ind      SMALLINT

 FOR l_ind = 1 TO 3 
    INITIALIZE l_sql_stmt TO NULL

    LET l_sql_stmt = " SELECT docum              ,",
                            " vencimento         ,",
                            " nome_cliente       ,",
                            " competencia        ,",
                            " empresa            ,",
                            " nota_fiscal        ,",
                            " ies_tip_docum_orig ,",
                            " nfe                ,",
                            " valor               ",
                       " FROM t_carta "

       CASE l_ind
          WHEN 1  {antigo 2} #alterado junto com Luiz
             LET l_sql_stmt = l_sql_stmt  CLIPPED,
             " WHERE  t_carta.nota_fiscal IS NOT NULL ",
              "  AND  t_carta.nota_fiscal <> '0' and t_carta.nota_fiscal <> '000000'  ",
              "  AND  t_carta.ies_tip_docum_orig = 'NF' ",
             " ORDER BY empresa, nota_fiscal, nfe "
             #incluido campo empresa no ORDER BY após contato com Luiz e Alan 04/07/12


          WHEN 2 {antigo 1} #alterado junto com Luiz para teste
             LET l_sql_stmt = l_sql_stmt  CLIPPED,
             " WHERE  t_carta.nota_fiscal IS NOT NULL ",
             " AND    t_carta.nota_fiscal <> '0' and t_carta.nota_fiscal <> '000000'  ",
             " AND   t_carta.ies_tip_docum_orig <> 'NF'   ",
             " ORDER BY empresa, nota_fiscal, nfe "

          WHEN 3
             LET l_sql_stmt = l_sql_stmt  CLIPPED,
             " WHERE ( t_carta.nota_fiscal  IS NULL   ",
             "  OR   ( t_carta.nota_fiscal  = '0' OR t_carta.nota_fiscal  = '000000')) ",
             " ORDER BY empresa, docum "

       END CASE

       CALL pol1377_processa_atualizacao_temporaria( l_sql_stmt )

 END FOR

 END FUNCTION

#--------------------------------------------------------------#
 FUNCTION pol1377_processa_atualizacao_temporaria( l_sql_stmt )
#--------------------------------------------------------------#
 DEFINE l_sql_stmt CHAR(2000)
 DEFINE lr_carta RECORD
        docum               CHAR(14)     ,
        vencimento          DATE         ,
        nome_cliente        CHAR(15)     ,
        competencia         CHAR(06)     ,
        empresa             CHAR(02)     ,
        nota_fiscal         CHAR(06)     ,
        ies_tip_docum_orig  CHAR(02)     ,
        nfe                 DECIMAL(10,0),
        valor               DECIMAL(15,2)
        END RECORD

 DEFINE l_sequencia DECIMAL(6,0)

 WHENEVER ERROR CONTINUE
   SELECT MAX( sequencia )
     INTO l_sequencia
     FROM t_carta_aux
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_sequencia IS NULL THEN
    LET l_sequencia = 0
 END IF

 WHENEVER ERROR CONTINUE
  PREPARE var_atualiza FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("PREPARE","VAR_ATUALIZA")
 END IF

 WHENEVER ERROR CONTINUE
  DECLARE cq_atualiza CURSOR FOR var_atualiza
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","CQ_ATUALIZA")
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_atualiza INTO lr_carta.docum              ,
                           lr_carta.vencimento         ,
                           lr_carta.nome_cliente       ,
                           lr_carta.competencia        ,
                           lr_carta.empresa            ,
                           lr_carta.nota_fiscal        ,
                           lr_carta.ies_tip_docum_orig ,
                           lr_carta.nfe                ,
                           lr_carta.valor
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("FOREACH","CQ_ATUALIZA")
 END IF

    LET l_sequencia = l_sequencia + 1

    WHENEVER ERROR CONTINUE
      INSERT INTO t_carta_aux ( sequencia          ,
                                docum              ,
                                vencimento         ,
                                nome_cliente       ,
                                competencia        ,
                                empresa            ,
                                nota_fiscal        ,
                                ies_tip_docum_orig ,
                                nfe                ,
                                valor              )
      VALUES ( l_sequencia                 ,
               lr_carta.docum              ,
               lr_carta.vencimento         ,
               lr_carta.nome_cliente       ,
               lr_carta.competencia        ,
               lr_carta.empresa            ,
               lr_carta.nota_fiscal        ,
               lr_carta.ies_tip_docum_orig ,
               lr_carta.nfe                ,
               lr_carta.valor              )
    WHENEVER ERROR STOP
    IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
       CALL log003_err_sql("INSERT","T_CARTA_AUX")
    END IF

 END FOREACH

 END FUNCTION

#-------------------------------------------------------------#
 FUNCTION pol1377_grava_sequencia_carta( l_diretorio_config  ,
                                         l_caminho_impressao ,
                                         l_tipo              )
#-------------------------------------------------------------#
 DEFINE l_diretorio_config  CHAR(200)
 DEFINE l_caminho_impressao CHAR(200)
 DEFINE l_tipo              CHAR(02)
 DEFINE l_sequencia         SMALLINT

 WHENEVER ERROR CONTINUE
   SELECT MAX(sequencia)
     INTO l_sequencia
     FROM t_caminho_boleto
    WHERE empresa   = mr_docum.cod_empresa
      AND documento = mr_docum.num_docum
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 OR l_sequencia IS NULL THEN
    LET l_sequencia = 0
 END IF

 LET l_sequencia = l_sequencia + 1

 #::: l_tipo - B(Boleto) D(Demonstrativo)
 WHENEVER ERROR CONTINUE
   INSERT INTO t_caminho_boleto ( empresa   ,
                                  documento ,
                                  tipo      ,
                                  sequencia ,
                                  caminho   ,
                                  caminho2  ,
                                  impressao )
   VALUES ( mr_docum.cod_empresa ,
            mr_docum.num_docum   ,
            l_tipo               ,
            l_sequencia          ,
            l_diretorio_config   ,
            l_caminho_impressao  ,
            "N"                  )
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("INSERT","T_CAMINHO_BOLETO")
 END IF

 END FUNCTION

#--------------------------------------------------------#
 FUNCTION pol1377_imprime_boletos_gravados( l_empresa   ,
                                            l_documento )
#--------------------------------------------------------#
 DEFINE l_empresa        LIKE docum.cod_empresa
 DEFINE l_documento      LIKE docum.num_docum
 DEFINE l_caminho        CHAR(200)
 DEFINE l_caminho2       CHAR(200)
 DEFINE l_caminho_imp    CHAR(200)
 DEFINE l_tipo           CHAR(1)
 DEFINE l_impressao      CHAR(1)
 DEFINE l_arquivo_remove CHAR(200)

 WHENEVER ERROR CONTINUE
  DECLARE cq_impressao3 CURSOR FOR
   SELECT caminho  ,
          caminho2 ,
          tipo     ,
          impressao
     FROM t_caminho_boleto
    WHERE empresa   = l_empresa
      AND documento = l_documento
   ORDER BY sequencia
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("SELECT","T_CAMINHO_BOLETO")
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_impressao3 INTO l_caminho  ,
                             l_caminho2 ,
                             l_tipo     ,
                             l_impressao
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("FOREACH","cq_impressao4")
 END IF

    LET m_tem_cartas = TRUE

    CASE l_tipo
       WHEN "B"
          LET g_comando = "java  BoletoBancarioPamcary ", l_caminho
          RUN g_comando

       #WHEN "D"
       #   LET g_comando = "java DemonstrativoTelerisco ",l_caminho
       #   RUN g_comando

    END CASE

    IF  p_ies_impressao = "S" AND l_tipo = "B" AND l_impressao = "S" THEN

       LET l_caminho_imp = 'pdftops ', l_caminho2 CLIPPED, ' - | lpr -P' CLIPPED, g_cod_impressora

       IF m_imprime_bloqueto = 'D' THEN
          LET l_caminho_imp = l_caminho_imp CLIPPED, ' -o sides=two-sided-long-edge'
       END IF

       RUN l_caminho_imp
    END IF

 END FOREACH

 END FUNCTION

#--------------------------------------------#
 FUNCTION pol1377_imprime_boletos_sem_carta()
#--------------------------------------------#
 DEFINE l_empresa      LIKE docum.cod_empresa
 DEFINE l_documento    LIKE docum.num_docum
 DEFINE l_caminho      CHAR(200)
 DEFINE l_caminho2     CHAR(200)
 DEFINE l_caminho_imp  CHAR(200)
 DEFINE l_tipo         CHAR(02)
 DEFINE l_impressao    CHAR(01)

 WHENEVER ERROR CONTINUE
  DECLARE cq_impressao4 CURSOR FOR
   SELECT caminho  ,
          caminho2 ,
          tipo     ,
          impressao
     FROM t_caminho_boleto
    ORDER BY caminho
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("DECLARE","cq_impressao4")
 END IF

 WHENEVER ERROR CONTINUE
  FOREACH cq_impressao4 INTO l_caminho   ,
                             l_caminho2  ,
                             l_tipo      ,
                             l_impressao
 WHENEVER ERROR CONTINUE
 IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
    CALL log003_err_sql("FOREACH","cq_impressao4")
 END IF

    CASE l_tipo
       WHEN "B"
          LET g_comando = "java  BoletoBancarioPamcary ", l_caminho
          RUN g_comando

       #WHEN "D"
       #   LET g_comando = "java DemonstrativoTelerisco ",l_caminho
       #   RUN g_comando

    END CASE

    IF  p_ies_impressao = "S" AND l_tipo = "B" AND l_impressao = "S" THEN

       LET l_caminho_imp = 'pdftops ', l_caminho2 CLIPPED, ' - | lpr -P' CLIPPED, g_cod_impressora

       IF m_imprime_bloqueto = 'D' THEN
          LET l_caminho_imp = l_caminho_imp CLIPPED, ' -o sides=two-sided-long-edge'
       END IF

       RUN l_caminho_imp
    END IF

 END FOREACH

 FREE cq_impressao4

 END FUNCTION

#----------------------------------------------#
 FUNCTION pol1377_busca_dados_logix_10()
#----------------------------------------------#

 LET m_grupo = mr_cre_compl_docum.grupo_economico

 IF NOT crem94_cre_escrit_compl_leitura( mr_par_escrit_txt.cod_empresa      ,
	         			                            mr_par_escrit_txt.cod_portador     ,
	         			                            mr_par_escrit_txt.ies_tip_portador ,
	         			                            mr_par_escrit_txt.ies_tip_cobr     ,
	         			                            m_grupo                            ,
	         			                            "01"                               ,
	         			                            "Dias para protestar"              ,
	         			                            FALSE                              ,
	         			                            1                                  ) THEN
    IF NOT crem94_cre_escrit_compl_leitura( mr_par_escrit_txt.cod_empresa      ,
	            			                            mr_par_escrit_txt.cod_portador     ,
	            			                            mr_par_escrit_txt.ies_tip_portador ,
	            			                            mr_par_escrit_txt.ies_tip_cobr     ,
	            			                            m_grupo                            ,
	            			                            "02"                               ,
	            			                            "Dias para protestar"              ,
	            			                            FALSE                              ,
	            			                            1                                  ) THEN
       RETURN FALSE
    END IF

    CALL crem94_cre_escrit_compl_get_parametro_texto()
    RETURNING m_qtd_dia_protesto_L10

 END IF

 RETURN TRUE

 END FUNCTION

#---------------------------------------------------------#
 FUNCTION pol1377_sistema_gerador_imprime_carta(l_empresa)
#---------------------------------------------------------#
 DEFINE l_empresa             LIKE cre_par_781_compl.empresa
 DEFINE l_sql_stmt            CHAR(500)

 LET l_sql_stmt = " SELECT 1 ",
                    " FROM cre_par_781_compl ",
                   " WHERE sistema        = ",mr_cre_compl_docum.sistema_gerador,
                     " AND campo          = 'imprime_carta' ",
                     " AND par_existencia = 'S' "

 IF l_empresa <> ' ' THEN
    LET l_sql_stmt = l_sql_stmt CLIPPED, " AND empresa = '",mr_docum.cod_empresa,"' "
 END IF

 WHENEVER ERROR CONTINUE
 PREPARE var_carta FROM l_sql_stmt
 WHENEVER ERROR STOP
 IF sqlca.sqlcode <> 0 THEN
    CALL log003_err_sql("PREPARE","VAR_CARTA")
    RETURN FALSE
 END IF

 WHENEVER ERROR CONTINUE
 EXECUTE var_carta
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 OR sqlca.sqlcode = -284 THEN
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

 END FUNCTION

#-------------------------------#
 FUNCTION pol1377_version_info()
#-------------------------------#

 RETURN "$Archive: /Logix/Fontes_Doc/Customizacao/10R2/_clientes_sem_guarda/gps_logist_e_gerenc_de_riscos_ltda/financeiro/contas_receber/programas/pol1377.4gl $|$Revision: 04 $|$Date: 27/12/19 09:52 $|$Modtime: 23/05/11 14:07 $" #Informações do controle de versão do SourceSafe - Não remover esta linha (FRAMEWORK)

 END FUNCTION
