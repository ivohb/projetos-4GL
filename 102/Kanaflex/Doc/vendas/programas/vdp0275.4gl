###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP0275                                               #
# MODULOS.: VDP0275 - LOG0010 - LOG0050 - LOG0060 - LOG1200       #
#           LOG1300 - LOG1400 - VDP2.01 - VDP3720 - VDP3850       #
#           VDP5420 - VDP6800 - VDP7810                           #
# OBJETIVO: CONSULTA PEDIDOS MESTRE                               #
# AUTOR...: ANTONIO CEZAR VIEIRA JUNIOR                           #
# DATA....: 05/04/2004                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_ind               SMALLINT,
         p_args              SMALLINT,
         p_flag              SMALLINT,
         p_tip_consulta      SMALLINT,
         p_tip_consul_ent    SMALLINT,
         p_tip_consul_obs    SMALLINT,
         p_char              CHAR(22),
         p_ies_cons_pedidos1 SMALLINT,
         p_ies_cons_itens    SMALLINT,
         p_ies_cons_entrega  SMALLINT,
         p_ies_cons_obs      SMALLINT,
#        p_den_carteira      CHAR(15),
         p_cliente_itens     SMALLINT,
         p_pedido_itens      SMALLINT,
         p_ies_opera_estoq   CHAR(1),
         pa_curr             INTEGER,
         sc_curr             INTEGER

  DEFINE p_pedidos1          RECORD
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
  DEFINE p_pedidos1r         RECORD
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
  DEFINE p_pedidos2          RECORD
                             cod_empresa        LIKE pedidos.cod_empresa,
                             pct_desc_adic      LIKE pedidos.pct_desc_adic,
                             pct_desc_financ    LIKE pedidos.pct_desc_financ,
                             ies_finalidade     LIKE pedidos.ies_finalidade,
                             ies_frete          LIKE pedidos.ies_frete,
                             pct_frete          LIKE pedidos.pct_frete,
                             ies_preco          LIKE pedidos.ies_preco,
                             ies_tip_entrega    LIKE pedidos.ies_tip_entrega,
                             ies_aceite         LIKE pedidos.ies_aceite,
                             num_list_preco     LIKE pedidos.num_list_preco,
                             dat_alt_sit        LIKE pedidos.dat_alt_sit,
                             dat_ult_fatur      LIKE pedidos.dat_ult_fatur,
                             ies_embal_padrao   LIKE pedidos.ies_embal_padrao,
                             num_versao_lista   LIKE pedidos.num_versao_lista,
                             cod_local_estoq    LIKE pedidos.cod_local_estoq,
                             cod_moeda          LIKE pedidos.cod_moeda,
                             den_moeda          LIKE moeda.den_moeda,
                             cod_motivo_can     LIKE pedidos.cod_motivo_can,
                             den_motivo_can     LIKE mot_cancel.den_motivo
                             END RECORD

  DEFINE p_pedidos2r         RECORD
                             cod_empresa        LIKE pedidos.cod_empresa,
                             pct_desc_adic      LIKE pedidos.pct_desc_adic,
                             pct_desc_financ    LIKE pedidos.pct_desc_financ,
                             ies_finalidade     LIKE pedidos.ies_finalidade,
                             ies_frete          LIKE pedidos.ies_frete,
                             pct_frete          LIKE pedidos.pct_frete,
                             ies_preco          LIKE pedidos.ies_preco,
                             ies_tip_entrega    LIKE pedidos.ies_tip_entrega,
                             ies_aceite         LIKE pedidos.ies_aceite,
                             num_list_preco     LIKE pedidos.num_list_preco,
                             dat_alt_sit        LIKE pedidos.dat_alt_sit,
                             dat_ult_fatur      LIKE pedidos.dat_ult_fatur,
                             ies_embal_padrao   LIKE pedidos.ies_embal_padrao,
                             num_versao_lista   LIKE pedidos.num_versao_lista,
                             cod_local_estoq    LIKE pedidos.cod_local_estoq,
                             cod_moeda          LIKE pedidos.cod_moeda,
                             den_moeda          LIKE moeda.den_moeda,
                             cod_motivo_can     LIKE pedidos.cod_motivo_can,
                             den_motivo_can     LIKE mot_cancel.den_motivo
                             END RECORD

  DEFINE p_ped_itens1        RECORD
                             cod_empresa        LIKE ped_itens.cod_empresa,
                             num_pedido         LIKE ped_itens.num_pedido,
                             num_sequencia      LIKE ped_itens.num_sequencia,
                             cod_item           LIKE ped_itens.cod_item,
                             den_item     LIKE item.den_item,
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
                             prz_entrega        LIKE ped_itens.prz_entrega
                             END RECORD
  DEFINE p_ped_itens_bnf1    RECORD
                             cod_empresa        LIKE ped_itens.cod_empresa,
                             num_pedido         LIKE ped_itens.num_pedido,
                             num_sequencia      LIKE ped_itens.num_sequencia,
                             cod_item           LIKE ped_itens.cod_item,
                             den_item     LIKE item.den_item,
                             pre_unit           LIKE ped_itens.pre_unit,
                             pct_desc_adic      LIKE ped_itens.pct_desc_adic,
                             qtd_pecas_solic    LIKE ped_itens.qtd_pecas_solic,
                             qtd_pecas_atend    LIKE ped_itens.qtd_pecas_atend,
                             qtd_pecas_cancel   LIKE ped_itens.qtd_pecas_cancel,
                             qtd_pecas_reserv   LIKE ped_itens.qtd_pecas_reserv,
                             prz_entrega        LIKE ped_itens.prz_entrega
                             END RECORD

  DEFINE p_cod_motivo_remessa      LIKE ped_itens_rem.cod_motivo_remessa,
         p_ies_tip_controle        LIKE nat_operacao.ies_tip_controle

  DEFINE p_ped_itens_rem1   RECORD
                      cod_empresa         LIKE ped_itens_rem.cod_empresa,
                      num_pedido          LIKE ped_itens_rem.num_pedido,
                      num_sequencia       LIKE ped_itens_rem.num_sequencia,
                      cod_item            LIKE ped_itens.cod_item,
                      den_item      LIKE item.den_item,
                      dat_emis_nf_usina   LIKE ped_itens_rem.dat_emis_nf_usina,
                      dat_retorno_prev    LIKE ped_itens_rem.dat_retorno_prev,
                      cod_motivo_remessa  LIKE ped_itens_rem.cod_motivo_remessa,
                      val_estoque         LIKE ped_itens_rem.val_estoque,
                      cod_area_negocio    LIKE ped_itens_rem.cod_area_negocio,
                      cod_lin_negocio     LIKE ped_itens_rem.cod_lin_negocio,
                      num_conta           LIKE ped_itens_rem.num_conta,
                      tex_observ          LIKE ped_itens_rem.tex_observ
                             END RECORD

  DEFINE p_pedido_comis      RECORD LIKE pedido_comis.*

  DEFINE p_entrega           RECORD LIKE ped_end_ent.*,
         p_entregar          RECORD LIKE ped_end_ent.*

  DEFINE p_observacoes       RECORD LIKE ped_observacao.*,
         p_observacoesr      RECORD LIKE ped_observacao.*

  DEFINE p_tex_observ_1      CHAR(39),
         p_tex_observ_2      CHAR(39),
         p_tex_observ_3      CHAR(39),
         p_tex_observ_4      CHAR(39)

  DEFINE p_empresa           LIKE pedidos.cod_empresa,
         p_num_pedido        LIKE pedidos.num_pedido,
         p_num_pedidor       LIKE pedidos.num_pedido,
         p_den_list_preco    LIKE desc_preco_mest.den_list_preco,
         p_txt_padr_embal    CHAR(15),
#        p_txt_carteira      CHAR(15),
         p_cod_cliente       LIKE pedidos.cod_cliente

  DEFINE p_nom_arquivo          CHAR(100),
         p_comando              CHAR(080),
         p_caminho              CHAR(080),
         p_nom_tela             CHAR(080),
         p_help                 CHAR(080),
         p_cancel               INTEGER
DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

# definicoes de variaveis que passaram de locais para modulares - 18.11.96

DEFINE sql_stmt          CHAR(3000)
DEFINE where_clause      CHAR(1500)

DEFINE ar_ped_itens_rem ARRAY[50] OF RECORD
               num_pedido          LIKE ped_itens_rem.num_pedido,
               num_sequencia       LIKE ped_itens_rem.num_sequencia,
               cod_item            LIKE ped_itens.cod_item,
               den_item      LIKE item.den_item,
               dat_emis_nf_usina   LIKE ped_itens_rem.dat_emis_nf_usina,
               dat_retorno_prev    LIKE ped_itens_rem.dat_retorno_prev,
               cod_motivo_remessa  LIKE ped_itens_rem.cod_motivo_remessa,
               val_estoque         LIKE ped_itens_rem.val_estoque,
               cod_area_negocio    LIKE ped_itens_rem.cod_area_negocio,
               cod_lin_negocio     LIKE ped_itens_rem.cod_lin_negocio,
               num_conta           LIKE ped_itens_rem.num_conta,
               tex_observ          LIKE ped_itens_rem.tex_observ
                             END RECORD

  DEFINE ar_ped_itens_rem_h ARRAY[50] OF RECORD
                num_pedido          LIKE ped_itens_rem.num_pedido,
                num_sequencia       LIKE ped_itens_rem.num_sequencia,
                cod_item            LIKE ped_itens.cod_item,
                den_item            LIKE item.den_item,
                dat_emis_nf_usina   LIKE ped_itens_rem.dat_emis_nf_usina,
                dat_retorno_prev    LIKE ped_itens_rem.dat_retorno_prev,
                cod_motivo_remessa  LIKE ped_itens_rem.cod_motivo_remessa,
                val_estoque         LIKE ped_itens_rem.val_estoque,
                cod_area_negocio    LIKE ped_itens_rem.cod_area_negocio,
                cod_lin_negocio     LIKE ped_itens_rem.cod_lin_negocio,
                num_conta           LIKE ped_itens_rem.num_conta,
                tex_observ          LIKE ped_itens_rem.tex_observ
                            END RECORD

  DEFINE ar_ped_itens_h   ARRAY[50] OF RECORD
                        num_pedido        LIKE  ped_itens.num_pedido,
                        num_sequencia     LIKE  ped_itens.num_sequencia,
                        cod_item          LIKE  ped_itens.cod_item,
                        den_item          LIKE  item.den_item,
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
                        prz_entrega       LIKE  ped_itens.prz_entrega
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
                        ies_texto         CHAR(01)
                        END RECORD

  DEFINE t_ped_itens_gr_h   ARRAY[1000] OF RECORD
               num_pedido         LIKE ped_itens_grade.num_pedido,
               num_sequencia      LIKE ped_itens_grade.num_sequencia,
               cod_item           LIKE ped_itens_grade.cod_item,
               den_item           LIKE item.den_item,
               cod_grade_1        LIKE ped_itens_grade.cod_grade_1,
               cod_grade_2        LIKE ped_itens_grade.cod_grade_2,
               cod_grade_3        LIKE ped_itens_grade.cod_grade_3,
               cod_grade_4        LIKE ped_itens_grade.cod_grade_4,
               cod_grade_5        LIKE ped_itens_grade.cod_grade_5,
               qtd_pecas_solic    LIKE ped_itens_grade.qtd_pecas_solic,
               qtd_pecas_atend    LIKE ped_itens_grade.qtd_pecas_atend,
               qtd_pecas_cancel   LIKE ped_itens_grade.qtd_pecas_cancel,
               qtd_pecas_reserv   LIKE ped_itens_grade.qtd_pecas_reserv,
               qtd_pecas_romaneio LIKE ped_itens_grade.qtd_pecas_romaneio,
               saldo              LIKE ped_itens_grade.qtd_pecas_solic
                          END RECORD

  DEFINE t_ped_itens_gr   ARRAY[1000] OF RECORD
                 num_pedido         LIKE ped_itens_grade.num_pedido,
                 num_sequencia      LIKE ped_itens_grade.num_sequencia,
                 cod_item           LIKE ped_itens_grade.cod_item,
                 den_item           LIKE item.den_item,
                 den_grade_1        LIKE grade.den_grade_reduz,
                 cod_grade_1        LIKE ped_itens_grade.cod_grade_1,
                 den_grade_2        LIKE grade.den_grade_reduz,
                 cod_grade_2        LIKE ped_itens_grade.cod_grade_2,
                 den_grade_3        LIKE grade.den_grade_reduz,
                 cod_grade_3        LIKE ped_itens_grade.cod_grade_3,
                 den_grade_4        LIKE grade.den_grade_reduz,
                 cod_grade_4        LIKE ped_itens_grade.cod_grade_4,
                 den_grade_5        LIKE grade.den_grade_reduz,
                 cod_grade_5        LIKE ped_itens_grade.cod_grade_5,
                 qtd_pecas_solic    LIKE ped_itens_grade.qtd_pecas_solic,
                 qtd_pecas_atend    LIKE ped_itens_grade.qtd_pecas_atend,
                 qtd_pecas_cancel   LIKE ped_itens_grade.qtd_pecas_cancel,
                 qtd_pecas_reserv   LIKE ped_itens_grade.qtd_pecas_reserv,
                 qtd_pecas_romaneio LIKE ped_itens_grade.qtd_pecas_romaneio,
                 saldo              LIKE ped_itens_grade.qtd_pecas_solic
                               END RECORD

  DEFINE t_ped_itens_ca_h   ARRAY[50] OF RECORD
               num_pedido         LIKE ped_itens_cancel.num_pedido,
               num_sequencia      LIKE ped_itens_cancel.num_sequencia,
               cod_item           LIKE ped_itens_cancel.cod_item,
               den_item           LIKE item.den_item,
               dat_cancel         LIKE ped_itens_cancel.dat_cancel,
               qtd_pecas_cancel   LIKE ped_itens_cancel.qtd_pecas_cancel,
               cod_motivo_can     LIKE ped_itens_cancel.cod_motivo_can,
               den_motivo         LIKE mot_cancel.den_motivo
                          END RECORD

  DEFINE t_ped_itens_ca     ARRAY[50] OF RECORD
               num_pedido         LIKE ped_itens_cancel.num_pedido,
               num_sequencia      LIKE ped_itens_cancel.num_sequencia,
               cod_item           LIKE ped_itens_cancel.cod_item,
               den_item           LIKE item.den_item,
               dat_cancel         LIKE ped_itens_cancel.dat_cancel,
               qtd_pecas_cancel   LIKE ped_itens_cancel.qtd_pecas_cancel,
               cod_motivo_can     LIKE ped_itens_cancel.cod_motivo_can,
               den_motivo         LIKE mot_cancel.den_motivo
                          END RECORD

  DEFINE ar_ped_itens_bnf ARRAY[50] OF RECORD
                   num_pedido        LIKE  ped_itens_bnf.num_pedido,
                   num_sequencia     LIKE  ped_itens_bnf.num_sequencia,
                   cod_item          LIKE  ped_itens_bnf.cod_item,
                   den_item          LIKE  item.den_item,
                   pre_unit          LIKE  ped_itens_bnf.pre_unit,
                   pct_desc_adic     LIKE  ped_itens_bnf.pct_desc_adic,
                   qtd_pecas_solic   LIKE  ped_itens_bnf.qtd_pecas_solic,
                   qtd_pecas_atend   LIKE  ped_itens_bnf.qtd_pecas_atend,
                   qtd_pecas_cancel  LIKE  ped_itens_bnf.qtd_pecas_cancel,
                   qtd_pecas_reserv  LIKE  ped_itens_bnf.qtd_pecas_reserv,
                   prz_entrega       LIKE  ped_itens_bnf.prz_entrega ,
                   saldo             LIKE  ped_itens_bnf.qtd_pecas_solic
                          END RECORD

  DEFINE ar_ped_itens_bnf_h    ARRAY[50] OF RECORD
                   num_pedido        LIKE  ped_itens_bnf.num_pedido,
                   num_sequencia     LIKE  ped_itens_bnf.num_sequencia,
                   cod_item          LIKE  ped_itens_bnf.cod_item,
                   den_item          LIKE  item.den_item,
                   pre_unit          LIKE  ped_itens_bnf.pre_unit,
                   pct_desc_adic     LIKE  ped_itens_bnf.pct_desc_adic,
                   qtd_pecas_solic   LIKE  ped_itens_bnf.qtd_pecas_solic,
                   qtd_pecas_atend   LIKE  ped_itens_bnf.qtd_pecas_atend,
                   qtd_pecas_cancel  LIKE  ped_itens_bnf.qtd_pecas_cancel,
                   qtd_pecas_reserv  LIKE  ped_itens_bnf.qtd_pecas_reserv,
                   prz_entrega       LIKE  ped_itens_bnf.prz_entrega,
                   saldo             LIKE  ped_itens_bnf.qtd_pecas_solic
                        END RECORD
# fim da alteracao
  DEFINE m_ies_item_adic             CHAR(01),
         m_prog_item_adic            CHAR(08),
         m_versao_funcao             CHAR(018),
         m_parte                     SMALLINT,
         m_texto_parte1              CHAR(026),
         m_texto_parte2              CHAR(026),
         m_texto_parte3              CHAR(026)

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "VDP0275-05.10.02p" #Favor nao alterar esta linha (SUPORTE)

  WHENEVER ERROR CONTINUE

  CALL log1400_isolation()

  WHENEVER ERROR STOP

  DEFER INTERRUPT

  CALL log140_procura_caminho("VDP.IEM") RETURNING p_caminho
  LET p_help = p_caminho
  OPTIONS
    HELP FILE p_help,
    NEXT KEY control-f,
    PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0  THEN
    LET p_args = TRUE
    LET p_cliente_itens = 1
    LET p_pedido_itens = 1
    CALL vdp426_controle()
  END IF
END MAIN

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle()
#---------------------------------------------------------------------#
  INITIALIZE p_pedidos1.*, p_pedidos1r.* TO NULL
  INITIALIZE p_entrega.*, p_entregar.*, p_observacoes.*, p_observacoesr.*
              TO NULL
  LET p_tip_consulta = 1

  CALL log006_exibe_teclas("01", p_versao)
  CALL log130_procura_caminho("VDP02751") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02751 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF p_args = TRUE THEN
    IF num_args() > 0 THEN
      LET p_args = FALSE
      CALL vdp426_consulta_pedidos1()
    END IF
  END IF

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta a tabela Pedidos - Tela Mestre 1"
      HELP 4
      MESSAGE ""
      LET int_flag = 0
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         LET p_tip_consulta = 1
         CALL vdp426_consulta_pedidos1()
         IF   p_ies_cons_pedidos1 = FALSE
         THEN NEXT OPTION "Historico"
         END IF
      END IF
    COMMAND "Historico"   "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL vdp426_consulta_pedidos1_hist()
         IF   p_ies_cons_pedidos1 = FALSE
         THEN LET p_tip_consulta = 1
              NEXT OPTION "Consultar"
         ELSE LET p_tip_consulta = 2
         END IF
      END IF
    COMMAND "Seguinte"   "Exibe Pedido seguinte "
      HELP 5
      MESSAGE ""
      IF   p_tip_consulta = 1
      THEN CALL vdp426_paginacao_pedidos1("SEGUINTE")
      ELSE CALL vdp426_paginacao_pedidos1_hist("SEGUINTE")
      END IF
    COMMAND "Anterior"   "Exibe Pedido anterior"
      HELP 6
      MESSAGE ""
      IF   p_tip_consulta = 1
      THEN CALL vdp426_paginacao_pedidos1("ANTERIOR")
      ELSE CALL vdp426_paginacao_pedidos1_hist("ANTERIOR")
      END IF
    COMMAND "Tela"     "Exibe Tela Mestre 2 "
      HELP 2035
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         IF   p_tip_consulta = 1
         THEN CALL vdp426_controle_pedidos2()
         ELSE CALL vdp426_controle_pedidos2_hist()
         END IF
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND "Item"     "Consulta Itens do pedido"
      HELP 2022
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         LET p_flag = FALSE
         CALL vdp426_controle_ped_itens()
      END IF
    COMMAND KEY ("B") "itens_Bonif." "Consulta Itens Bonificacao do pedido"
      HELP 2023
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         LET p_flag = FALSE
         CALL vdp426_controle_ped_itens_bnf()
      END IF
    COMMAND KEY ("M") "itens_reMessa" "Consulta Itens Remessa do pedido"
      HELP 2024
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         LET p_flag = FALSE
         CALL vdp426_controle_ped_itens_remessa()
      END IF
    COMMAND KEY ("G") "item_Grade"     "Consulta Grades do pedido"
      HELP 2503
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
      THEN LET  p_flag = FALSE
           CALL vdp426_controle_ped_itens_grade()
      END IF
    COMMAND KEY ("Y") "item_cancel_Y"    "Consulta itens cancelados"
      HELP 9999
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
      THEN LET  p_flag = FALSE
           CALL vdp426_controle_ped_itens_cancel()
      END IF
    COMMAND "Observacoes"   "Consulta Observacoes do pedido"
      HELP 2025
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL vdp426_controle_observacoes()
      END IF
    COMMAND "Endereco"   "Consulta Endereco Entrega do pedido"
      HELP 2026
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL vdp426_controle_entrega()
      END IF
    COMMAND KEY("X") "teXtos"   "Consulta Textos do pedido"
      HELP 2027
      MESSAGE ""
      {
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP2500") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.num_pedido," ","0"
         RUN p_comando
      END IF
   }
         IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN      #os 400868
            CALL log120_procura_caminho("VDP2500") RETURNING p_comando
            IF p_pedidos1.cod_empresa IS NULL THEN
               LET p_pedidos1.cod_empresa= p_cod_empresa
            END IF
            LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_empresa," ",p_pedidos1.num_pedido," ","0"
            RUN p_comando
         END IF

    COMMAND KEY("D") "Descontos"   "Consulta Descontos do pedido"
      HELP 2028
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         IF p_tip_consulta = 1 THEN
            CALL log120_procura_caminho("VDP7810") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_pedidos1.num_pedido," ","0"
            RUN p_comando
         ELSE
            CALL log120_procura_caminho("VDP3791") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_pedidos1.num_pedido," ","0"
            RUN p_comando
         END IF
      END IF
    COMMAND KEY("N") "clieNte_itens " "Consulta Itens por cliente"
      HELP 2029
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL log120_procura_caminho("VDP5420") RETURNING p_comando
          LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
          RUN p_comando
          CALL log006_exibe_teclas("01", p_versao)
          CURRENT WINDOW IS w_vdp02751
          IF   p_cliente_itens = 0 AND p_num_pedido > 0
          THEN CALL vdp426_consulta_pedidos1()
               LET p_tip_consulta = 1
               LET p_cliente_itens = 1
          END IF
      END IF
    COMMAND KEY("P") "Pedido_itens " "Consulta Itens por pedido"
      HELP 2030
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL log120_procura_caminho("VDP6800") RETURNING p_comando
          LET p_comando = p_comando CLIPPED," ",p_pedidos1.num_pedido
          RUN p_comando
          CALL log006_exibe_teclas("01", p_versao)
          CURRENT WINDOW IS w_vdp02751
          IF   p_pedido_itens = 0 AND p_num_pedido > 0
          THEN CALL vdp426_consulta_pedidos1()
               LET p_tip_consulta = 1
               LET p_pedido_itens  = 1
          END IF
      END IF
    COMMAND KEY("2") "total2 " "Consulta total do pedido"
      HELP 2166
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL log120_procura_caminho("VDP3460") RETURNING p_comando
          LET p_comando = p_comando CLIPPED," ",
                          p_pedidos1.num_pedido, " ",
                          p_pedidos1.cod_cliente
          RUN p_comando
          CALL log006_exibe_teclas("01", p_versao)
          CURRENT WINDOW IS w_vdp02751
          IF   p_cliente_itens = 0 AND p_num_pedido > 0
          THEN CALL vdp426_consulta_pedidos1()
               LET p_tip_consulta = 1
               LET p_cliente_itens = 1
          END IF
      END IF
{    COMMAND KEY("R") "item_Refer." "Consulta Itens Referencia do pedido"
      HELP 2031
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
          CALL log120_procura_caminho("VDP8790") RETURNING p_comando
          LET p_comando = p_comando CLIPPED," ",p_pedidos1.num_pedido
          RUN p_comando
          CALL log006_exibe_teclas("01", p_versao)
          CURRENT WINDOW IS w_vdp02751
          IF   p_pedido_itens = 0 AND p_num_pedido > 0
          THEN CALL vdp426_consulta_pedidos1()
               LET p_tip_consulta = 1
               LET p_pedido_itens  = 1
          END IF
      END IF }
   COMMAND KEY("R") "inteRmediario" " Alteracao do Cliente Intermediario. "
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP1558","CO")
      THEN LET p_num_pedidor = p_num_pedido
           CALL vdp1558_cliente_inter()
           LET p_num_pedido = p_num_pedidor
      END IF
    COMMAND KEY("3") "item_adicional(3)" " Consulta as especificacoes de adicionais do pedido. "
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP4149","CO")
      THEN CALL vdp0275_busca_parametros()
           IF m_ies_item_adic = 'S'
           THEN LET p_num_pedidor = p_num_pedido
                IF m_prog_item_adic IS NOT NULL THEN
                   CALL log120_procura_caminho(m_prog_item_adic) RETURNING p_comando
                   LET p_comando = p_comando CLIPPED,
                                   ' VDP0275 ',
                                   p_num_pedido,' ',
                                   p_empresa
                   RUN p_comando
                ELSE
                   ERROR 'Programa de itens adicionais nao cadastrado. '
                END IF
                LET p_num_pedido = p_num_pedidor
           ELSE
              ERROR 'Nao possui itens adicionais de pedido. '
           END IF
      END IF
    COMMAND KEY ("4") "complementos(4)" "Manutencao dos Complementos do Pedido"
      MESSAGE ""
      CALL log120_procura_caminho("VDP4323") RETURNING p_comando
      LET p_comando = p_comando CLIPPED, " ", p_pedidos1.num_pedido,
                                         " ", p_pedidos1.cod_empresa
      RUN p_comando RETURNING p_cancel
      LET p_cancel = p_cancel / 256
      IF   p_cancel = 0
      THEN CALL log006_exibe_teclas("01", p_versao)
           CURRENT WINDOW IS w_vdp02751
      ELSE PROMPT "Tecle ENTER para continuar" FOR p_comando
      END IF
    #OS 591777
    COMMAND KEY ("5") 'texto_expedicao(5)' 'Textos da observação da expedição.'
      HELP 030
      MESSAGE ""
      IF p_num_pedido IS NOT NULL THEN
         CALL vdp0275_consulta_texto_exped(p_num_pedido)
      ELSE
         CALL log0030_mensagem("Consulte pedido previamente. ","excl")
      END IF
      CALL log006_exibe_teclas("01 02 07", p_versao)
      CURRENT WINDOW IS w_vdp02751
    #OS 591777
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02751
END FUNCTION

#-------------------------------#
 FUNCTION vdp426_declare_cursor()
#-------------------------------#
  PREPARE var_query_pedidos1 FROM sql_stmt
  DECLARE cq_pedidos1 SCROLL CURSOR FOR var_query_pedidos1
 END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_pedidos1()
#---------------------------------------------------------------------#
  LET p_pedidos1r.* = p_pedidos1.*
# INITIALIZE p_pedidos1.* TO NULL
  LET int_flag = 0
  LET p_cliente_itens = 1
  LET p_pedido_itens = 1

  INITIALIZE p_pedidos1.parametro_texto TO NULL

  CALL log006_exibe_teclas("02 03 07", p_versao)
  IF   num_args() = 0 AND
       (p_cliente_itens <> 0 OR p_pedido_itens <> 0)
  THEN CURRENT WINDOW IS w_vdp02751
       CLEAR FORM
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
                                         pedidos.num_pedido_repres,
                                         pedidos.dat_emis_repres,
                                         pedidos.num_pedido_cli,
                                         pedidos.cod_nat_oper,
                                         pedidos.cod_transpor,
                                         pedidos.cod_consig,
                                         pedidos.cod_cnd_pgto,
                                         ped_compl_pedido.forma_pagto,
                                         pedidos.cod_tip_venda,
                                         pedidos.cod_tip_carteira

           BEFORE FIELD cod_empresa
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           BEFORE FIELD ies_sit_pedido
                  DISPLAY "( Zoom )" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           AFTER  FIELD ies_sit_pedido
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           BEFORE FIELD cod_cliente
                  DISPLAY "( Zoom )" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           AFTER  FIELD cod_cliente
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           AFTER  FIELD parametro_texto
                  LET p_pedidos1.parametro_texto = GET_FLDBUF(parametro_texto)

           ON KEY (control-z, f4)
             CALL vdp0275_popup()

       END CONSTRUCT
  END IF
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  IF   int_flag
  THEN LET int_flag = 0
       LET p_pedidos1.* = p_pedidos1r.*
       CALL vdp426_exibe_dados_pedidos1()
       ERROR " Consulta Cancelada "
       RETURN
  ELSE MESSAGE "Aguarde processamento... "
  END IF

  IF   num_args() > 0 OR
      (p_cliente_itens = 0 OR p_pedido_itens = 0) THEN
       IF p_cliente_itens = 0 OR p_pedido_itens = 0 THEN
          IF   p_num_pedido = p_pedidos1.num_pedido THEN
               CALL vdp426_exibe_dados_pedidos1()
               RETURN
          END IF
          LET p_pedidos1.cod_empresa = p_cod_empresa
          LET p_pedidos1.num_pedido = p_num_pedido
       ELSE
          LET p_char=arg_val(1)
          LET p_pedidos1.cod_empresa = p_char[1,2]
          LET p_pedidos1.num_pedido  = p_char[3,8] USING "######"
       END IF
       LET sql_stmt = "SELECT cod_empresa,     num_pedido,        ",
                             "dat_pedido,      cod_cliente, ies_sit_pedido , ",
                             "cod_repres,      cod_repres_adic,   ",
                             "ies_comissao,     ",
                             "pct_comissao,    num_pedido_repres, ",
                             "dat_emis_repres, num_pedido_cli,    ",
                             "cod_nat_oper,    cod_transpor,      ",
                             "cod_consig,      cod_cnd_pgto,  ' ', ",
                             "cod_tip_venda,   cod_tip_carteira   ",
                             " FROM pedidos ",
                            " WHERE pedidos.cod_empresa = '", p_pedidos1.cod_empresa,"' ",
                              " AND pedidos.num_pedido  = ", p_pedidos1.num_pedido,
                            " ORDER BY pedidos.dat_pedido desc "
  ELSE
       IF  p_pedidos1.parametro_texto <> ' '      AND
           p_pedidos1.parametro_texto IS NOT NULL THEN
           LET sql_stmt = " SELECT cod_empresa, num_pedido,",
                                 " dat_pedido,cod_cliente, ies_sit_pedido,",
                                 " cod_repres, cod_repres_adic,",
                                 " ies_comissao,",
                                 " ped_info_compl.parametro_texto,",
                                 " pct_comissao, num_pedido_repres,",
                                 " dat_emis_repres, num_pedido_cli,",
                                 " cod_nat_oper, cod_transpor,",
                                 " cod_consig, cod_cnd_pgto, ' ', ",
                                 " cod_tip_venda, cod_tip_carteira",
                            " FROM pedidos, ped_info_compl",
                           " WHERE ", where_clause CLIPPED,
                             " AND pedidos.cod_empresa  = ped_info_compl.empresa",
                             " AND pedidos.num_pedido   = ped_info_compl.pedido",
                             " AND ped_info_compl.campo = 'linha_produto'",
                           " ORDER BY pedidos.dat_pedido desc"
       ELSE
           LET sql_stmt = " SELECT cod_empresa, num_pedido,",
                                 " dat_pedido,cod_cliente, ies_sit_pedido,",
                                 " cod_repres, cod_repres_adic,",
                                 " ies_comissao,",
                                 " ' ',",
                                 " pct_comissao, num_pedido_repres,",
                                 " dat_emis_repres, num_pedido_cli,",
                                 " cod_nat_oper, cod_transpor,",
                                 " cod_consig, cod_cnd_pgto, ' ', ",
                                 " cod_tip_venda, cod_tip_carteira",
                              " FROM pedidos",
                             " WHERE ", where_clause CLIPPED,
                             " ORDER BY pedidos.dat_pedido desc"
       END IF
  END IF

  {CALL log0030_mensagem(sql_stmt[1,200],'info')
  CALL log0030_mensagem(sql_stmt[201,400],'info')
  CALL log0030_mensagem(sql_stmt[401,600],'info')
  CALL log0030_mensagem(sql_stmt[601,800],'info')}

  CALL vdp426_declare_cursor()

  OPEN cq_pedidos1
  FETCH cq_pedidos1 INTO p_pedidos1.*
  LET p_status = SQLCA.sqlcode
  MESSAGE ""
  IF p_status = NOTFOUND
     THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados ou pedido ja liquidado", "exclamation")
          LET p_ies_cons_pedidos1 = FALSE
     ELSE LET p_ies_cons_pedidos1 = TRUE
          SELECT UNIQUE forma_pagto
            INTO p_pedidos1.forma_pagto
            FROM ped_compl_pedido
           WHERE empresa = p_pedidos1.cod_empresa
             AND pedido  = p_pedidos1.num_pedido

           IF  p_pedidos1.parametro_texto IS NULL OR
               p_pedidos1.parametro_texto = ' '   THEN
               WHENEVER ERROR CONTINUE
                 SELECT parametro_texto
                   INTO p_pedidos1.parametro_texto
                   FROM ped_info_compl
                  WHERE ped_info_compl.empresa = p_pedidos1.cod_empresa
                    AND ped_info_compl.pedido  = p_pedidos1.num_pedido
                    AND ped_info_compl.campo   = 'linha_produto'
               WHENEVER ERROR STOP
               IF  SQLCA.sqlcode <> 0 THEN
               END IF
           END IF

          CALL vdp426_exibe_dados_pedidos1()
          RETURN
  END IF

END FUNCTION

#-------------------------#
 FUNCTION vdp0275_popup()
#------------------------#
DEFINE  p_cod_cliente     LIKE clientes.cod_cliente
 CASE
    WHEN infield(cod_cliente)
         LET p_cod_cliente = vdp372_popup_cliente()
         CURRENT WINDOW IS w_vdp02751
         IF p_cod_cliente IS NOT NULL
           THEN DISPLAY p_cod_cliente TO cod_cliente
         END IF

    WHEN infield(ies_sit_pedido)
         LET p_pedidos1.ies_sit_pedido = log0830_list_box(12, 20,'N {Normal}, F {Liberacao Financeira}, C {Liberacao Comercial},  S {Suspenso}, B {Bloqueado}, 9 {Cancelado}')
         DISPLAY p_pedidos1.ies_sit_pedido TO ies_sit_pedido

    WHEN infield(ies_finalidade)
         LET p_pedidos2.ies_finalidade = log0830_list_box(11, 26,'1 {Contrib.(Ind/Com)}, 2 {Nao Contrib.}, 3 {Contrib.(Uso/Cons)}')
         DISPLAY p_pedidos2.ies_finalidade TO ies_finalidade

    WHEN infield(ies_frete)
         LET p_pedidos2.ies_frete = log0830_list_box(11, 26,'1 {CIF Pago}, 2 {CIF Cobr.}, 3 {FOB}, 4 {CIF Pct.}, 5 {CIF Unit.}')
         DISPLAY p_pedidos2.ies_frete TO ies_frete

    WHEN infield(ies_preco)
         LET p_pedidos2.ies_preco = log0830_list_box(11, 26,'F {Fixo},  R {Reajustavel}')
         DISPLAY p_pedidos2.ies_preco TO ies_preco

    WHEN infield(ies_tip_entrega)
         LET p_pedidos2.ies_tip_entrega = log0830_list_box(11, 26,'1 {Total},  2 {Item Total},  3 {Item Parcial} , 4 {Total Separado}')
         DISPLAY p_pedidos2.ies_tip_entrega TO ies_tip_entrega

    WHEN infield(ies_aceite)
         LET p_pedidos2.ies_aceite = log0830_list_box(11, 26,'N {Normal}, F {Financeiro},  C {Comercial}, A {Ambos}')
         DISPLAY p_pedidos2.ies_aceite TO ies_aceite

 END CASE
END FUNCTION


#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_pedidos1(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_pedidos1  THEN
     LET p_pedidos1r.* = p_pedidos1.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_pedidos1 INTO p_pedidos1.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_pedidos1 INTO p_pedidos1.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_pedidos1.* = p_pedidos1r.*
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
       SELECT UNIQUE cod_empresa,num_pedido,
              dat_pedido, cod_cliente,ies_sit_pedido,
              cod_repres, cod_repres_adic,
              ies_comissao, ' ', pct_comissao, num_pedido_repres,
              dat_emis_repres, num_pedido_cli,
              cod_nat_oper, cod_transpor,
              cod_consig, cod_cnd_pgto,
              forma_pagto, cod_tip_venda,
              cod_tip_carteira
         INTO p_pedidos1.*
         FROM pedidos, OUTER ped_compl_pedido
        WHERE pedidos.cod_empresa   = p_pedidos1.cod_empresa
          AND pedidos.num_pedido    = p_pedidos1.num_pedido
          AND pedidos.cod_cliente   = p_pedidos1.cod_cliente
          AND pedidos.cod_empresa   = ped_compl_pedido.empresa
          AND pedidos.num_pedido    = ped_compl_pedido.pedido
       WHENEVER ERROR STOP

       IF  sqlca.sqlcode = 0 THEN

           WHENEVER ERROR CONTINUE
             SELECT parametro_texto
               INTO p_pedidos1.parametro_texto
               FROM ped_info_compl
              WHERE ped_info_compl.empresa = p_pedidos1.cod_empresa
                AND ped_info_compl.pedido  = p_pedidos1.num_pedido
                AND ped_info_compl.campo   = 'linha_produto'
           WHENEVER ERROR STOP
           IF  SQLCA.sqlcode <> 0 THEN
           END IF

           CALL vdp426_exibe_dados_pedidos1()
           EXIT WHILE
       END IF
     END WHILE
  ELSE
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_exibe_dados_pedidos1()
#---------------------------------------------------------------------#
 LET p_empresa     = p_pedidos1.cod_empresa
 LET p_num_pedido  = p_pedidos1.num_pedido
 LET p_cod_cliente = p_pedidos1.cod_cliente
 INITIALIZE p_pedidos1.nom_cliente,
            p_pedidos1.den_cidade,
            p_pedidos1.cod_uni_feder,
            p_pedidos1.den_transpor,
            p_pedidos1.den_consig,
            p_pedidos1.raz_social,
            p_pedidos1.raz_social_adic,
            p_pedidos1.den_cnd_pgto,
            p_pedidos1.den_nat_oper,
            p_pedidos1.den_tip_venda,
            p_pedidos1.den_tip_carteira,
            p_pedidos1.des_forma_pagto TO NULL

  IF p_pedidos1.cod_transpor IS NOT NULL
  THEN CALL vdp426_verifica_cod_transport()
  END IF
  IF p_pedidos1.cod_consig IS NOT NULL
  THEN CALL vdp426_verifica_cod_consig()
  END IF
  IF p_pedidos1.cod_cliente   IS NOT NULL
  THEN CALL vdp426_verifica_cod_cliente()
  END IF
  IF p_pedidos1.cod_cnd_pgto  IS NOT NULL
  THEN CALL vdp426_verifica_cod_cnd_pgto()
  END IF
  IF p_pedidos1.cod_nat_oper  IS NOT NULL
  THEN CALL vdp426_verifica_cod_nat_oper()
  END IF
  IF p_pedidos1.cod_tip_venda IS NOT NULL
  THEN CALL vdp426_verifica_cod_tip_venda()
  END IF
  IF   p_pedidos1.cod_tip_carteira IS NOT NULL
  THEN CALL vdp426_verifica_cod_tip_carteira()
  END IF
  IF p_pedidos1.forma_pagto IS NOT NULL
  THEN CALL vdp426_verifica_forma_pagto()
  END IF

  INITIALIZE p_pedido_comis.* TO NULL

  SELECT *
    INTO p_pedido_comis.*
    FROM pedido_comis
   WHERE cod_empresa = p_pedidos1.cod_empresa
     AND num_pedido  = p_pedidos1.num_pedido

  IF p_pedido_comis.cod_repres_3 = 0 THEN
     LET p_pedido_comis.cod_repres_3 = NULL
     LET p_pedido_comis.pct_comissao_3 = NULL
  END IF
  DISPLAY p_pedido_comis.pct_comissao_2 TO pct_comissao_2
  DISPLAY p_pedido_comis.cod_repres_3 TO cod_repres_3
  DISPLAY p_pedido_comis.pct_comissao_3 TO pct_comissao_3

  IF p_pedidos1.cod_repres    IS NOT NULL
  THEN CALL vdp426_verifica_cod_repres()
  END IF

  DISPLAY BY NAME p_pedidos1.*
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_pedidos2()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02752") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02752 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF p_num_pedido IS NULL
  THEN ERROR " Primeira pagina dos PEDIDOS MESTRE nao foi consultada !"
  ELSE CALL vdp426_consulta_pedidos2()
  END IF

  MENU "OPCAO"
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes "
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02752
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_pedidos2()
#---------------------------------------------------------------------#
  DEFINE p_par_vdp_txt     LIKE par_vdp.par_vdp_txt,
         p_den_local       LIKE local.den_local
  DEFINE l_dat_hor         DATETIME YEAR TO SECOND,
         l_usuario         CHAR(8)

  LET p_pedidos2r.* = p_pedidos2.*
  INITIALIZE p_pedidos2.* TO NULL
  CLEAR FORM

  SELECT cod_empresa,
         pct_desc_adic,
         pct_desc_financ,
    #    ies_sit_pedido,
         ies_finalidade,
         ies_frete,
         pct_frete,
         ies_preco,
         ies_tip_entrega,
         ies_aceite,
         num_list_preco,
         dat_alt_sit,
         dat_ult_fatur,
         ies_embal_padrao,
         num_versao_lista,
         cod_local_estoq,
         cod_moeda," ",
         cod_motivo_can
    INTO p_pedidos2.*
    FROM pedidos
    WHERE pedidos.num_pedido  = p_pedidos1.num_pedido
      AND pedidos.cod_empresa = p_pedidos1.cod_empresa
  IF sqlca.sqlcode = 0
 THEN LET p_ies_cons_pedidos1 = TRUE
 ELSE LET p_ies_cons_pedidos1 = FALSE
 END IF
 SELECT den_list_preco
   INTO p_den_list_preco
   FROM desc_preco_mest
  WHERE desc_preco_mest.num_list_preco = p_pedidos2.num_list_preco
    AND desc_preco_mest.cod_empresa    = p_cod_empresa

  SELECT par_vdp_txt
    INTO p_par_vdp_txt
    FROM par_vdp
   WHERE cod_empresa = p_cod_empresa
  LET p_ies_opera_estoq = p_par_vdp_txt[157,157]

  LET p_pedidos2.den_moeda = " "
  IF   p_pedidos2.cod_moeda IS NOT NULL
  THEN CALL vdp426_verifica_cod_moeda()
  END IF

  IF   p_ies_opera_estoq = "S"
  THEN SELECT den_local
         INTO p_den_local
         FROM local
        WHERE cod_empresa = p_cod_empresa
          AND cod_local   = p_pedidos2.cod_local_estoq
  ELSE LET p_pedidos2.cod_local_estoq = NULL
       LET p_den_local                = NULL
  END IF

  SELECT den_motivo
    INTO p_pedidos2.den_motivo_can
    FROM mot_cancel
   WHERE cod_motivo  = p_pedidos2.cod_motivo_can
  IF   sqlca.sqlcode <> 0
  THEN LET p_pedidos2.den_motivo_can = NULL
  END IF

  SELECT UNIQUE dat_hor_inclusao, usuario_inclusao
    INTO l_dat_hor, l_usuario
    FROM ped_compl_pedido
   WHERE ped_compl_pedido.empresa = p_pedidos1.cod_empresa
     AND ped_compl_pedido.pedido  = p_pedidos1.num_pedido
     AND ped_compl_pedido.dat_hor_inclusao =
         (SELECT MIN(dat_hor_inclusao)
            FROM ped_compl_pedido
           WHERE ped_compl_pedido.empresa = p_pedidos1.cod_empresa
             AND ped_compl_pedido.pedido  = p_pedidos1.num_pedido)

 DISPLAY l_dat_hor        TO dat_hor_inclusao
 DISPLAY l_usuario        TO usuario_inclusao

 DISPLAY BY NAME p_pedidos2.*
 DISPLAY p_den_list_preco TO den_list_preco
 DISPLAY p_den_local      TO den_local

  CASE p_pedidos2.ies_embal_padrao
   WHEN "1" DISPLAY "Embal. Interna"  TO txt_padr_embal
   WHEN "2" DISPLAY "Embal. Externa"  TO txt_padr_embal
   WHEN "3" DISPLAY "Sem Padrao"      TO txt_padr_embal
   WHEN "4" DISPLAY "Cx. Embal. Int." TO txt_padr_embal
   WHEN "5" DISPLAY "Cx. Embal. Ext." TO txt_padr_embal
   WHEN "6" DISPLAY "Pallet"          TO txt_padr_embal
 END CASE

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_ped_itens()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02753") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02753 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF log005_seguranca(p_user,"VDP","VDP0275","CO") THEN
    IF   p_pedidos1.num_pedido <> 0
    THEN IF   p_tip_consulta = 1
         THEN CALL vdp426_consulta_itens_do_pedido()
         ELSE CALL vdp426_consulta_itens_do_pedido_hist()
         END IF
    ELSE
    END IF
  END IF
  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Itens do pedido"
      HELP 4
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CURRENT WINDOW  IS w_vdp02753
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_do_pedido()
      END IF
    COMMAND "Historico"    "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         CURRENT WINDOW  IS w_vdp02753
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_do_pedido_hist()
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY("X") "teXtos"   "Consulta Textos do pedido"
      HELP 2027
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP2500") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_ped_itens1.num_pedido," ",p_ped_itens1.num_sequencia
         RUN p_comando
      END IF
    COMMAND KEY("D") "Descontos"   "Consulta Descontos do pedido"
      HELP 2028
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         IF p_tip_consulta = 1 THEN
            CALL log120_procura_caminho("VDP7810") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens1.num_pedido," ",p_ped_itens1.num_sequencia
            RUN p_comando
         ELSE
            CALL log120_procura_caminho("VDP3791") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens1.num_pedido," ",p_ped_itens1.num_sequencia
            RUN p_comando
         END IF
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02753
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_ped_itens_bnf()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02756") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02756 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF log005_seguranca(p_user,"VDP","VDP0275","CO") THEN
    IF   p_pedidos1.num_pedido <> 0
    THEN IF   p_tip_consulta = 1
         THEN CALL vdp426_consulta_itens_bnf_pedido()
         ELSE CALL vdp426_consulta_itens_bnf_pedido_hist()
         END IF
    ELSE
    END IF
  END IF
  MENU "OPCAO"
    COMMAND "Consultar"  "Consulta Itens Bonificacao do pedido"
      HELP 4
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CURRENT WINDOW  IS w_vdp02756
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_bnf_pedido()
      END IF
    COMMAND "Historico" "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         CURRENT WINDOW  IS w_vdp02756
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_bnf_pedido_hist()
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY("X") "teXtos"   "Consulta Textos do pedido"
      HELP 2027
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP2500") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_ped_itens_bnf1.num_pedido," ",p_ped_itens_bnf1.num_sequencia
         RUN p_comando
      END IF
    COMMAND KEY("D") "Descontos"   "Consulta Descontos do pedido"
      HELP 2028
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         IF p_tip_consulta = 1 THEN
            CALL log120_procura_caminho("VDP7810") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens_bnf1.num_pedido," ",p_ped_itens_bnf1.num_sequencia
            RUN p_comando
         ELSE
            CALL log120_procura_caminho("VDP3791") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens_bnf1.num_pedido," ",p_ped_itens_bnf1.num_sequencia
            RUN p_comando
         END IF
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02756
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp426_controle_ped_itens_remessa()
#--------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02757") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02757 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF log005_seguranca(p_user,"VDP","VDP0275","CO") THEN
    IF   p_pedidos1.num_pedido <> 0
    THEN IF   p_tip_consulta = 1
         THEN CALL vdp426_consulta_itens_rem_pedido()
         ELSE CALL vdp426_consulta_itens_rem_pedido_hist()
         END IF
    ELSE
    END IF
  END IF
  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Itens Remessa do pedido"
      HELP 4
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CURRENT WINDOW  IS w_vdp02757
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_rem_pedido()
      END IF
    COMMAND "Historico"    "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         CURRENT WINDOW  IS w_vdp02757
         CLEAR FORM
         LET p_flag = TRUE
         CALL vdp426_consulta_itens_rem_pedido_hist()
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF

    COMMAND KEY("X") "teXtos"   "Consulta Textos do pedido"
      HELP 2027
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP2500") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_ped_itens_rem1.num_pedido," ",p_ped_itens_rem1.num_sequencia
         RUN p_comando
      END IF
    COMMAND KEY("D") "Descontos"   "Consulta Descontos do pedido"
      HELP 2028
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         IF p_tip_consulta = 1 THEN
            CALL log120_procura_caminho("VDP7810") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens_rem1.num_pedido," ",p_ped_itens_rem1.num_sequencia
            RUN p_comando
         ELSE
            CALL log120_procura_caminho("VDP3791") RETURNING p_comando
            LET p_comando = p_comando CLIPPED," ",p_cod_empresa," ",p_ped_itens_rem1.num_pedido," ",p_ped_itens_rem1.num_sequencia
         END IF
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02757
END FUNCTION

#------------------------------------------#
 FUNCTION vdp426_controle_ped_itens_grade()
#------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02759") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02759 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
  THEN IF   p_pedidos1.num_pedido <> 0
       THEN IF   p_tip_consulta = 1
            THEN CALL vdp426_consulta_itens_grade_do_pedido()
            ELSE CALL vdp426_consulta_itens_grade_do_pedido_hist()
            END IF
       END IF
  END IF

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Itens do pedido"
      HELP 0004
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
      THEN CURRENT WINDOW IS w_vdp02759
           CLEAR FORM
           LET  p_flag = TRUE
           CALL vdp426_consulta_itens_grade_do_pedido()
      END IF
    COMMAND "Historico"    "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
      THEN INITIALIZE p_num_pedido TO NULL
           CURRENT WINDOW IS w_vdp02759
           CLEAR FORM
           LET  p_flag = TRUE
           CALL vdp426_consulta_itens_grade_do_pedido_hist()
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02759
END FUNCTION

#------------------------------------------#
 FUNCTION vdp426_controle_ped_itens_cancel()
#------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP0275a") RETURNING p_nom_tela
  OPEN WINDOW w_vdp0275a AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
  THEN IF   p_pedidos1.num_pedido <> 0
       THEN CALL vdp426_consulta_itens_cancel_do_pedido()
        END IF
   END IF

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Itens do pedido"
      HELP 0004
      MESSAGE ""
      IF   log005_seguranca(p_user,"VDP","VDP0275","CO")
      THEN CURRENT WINDOW IS w_vdp0275a
           CLEAR FORM
           LET  p_flag = TRUE
           CALL vdp426_consulta_itens_cancel_do_pedido()
       END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp0275a
END FUNCTION

#-------------------------------------------#
FUNCTION vdp426_consulta_itens_rem_pedido()
#-------------------------------------------#

    IF   p_flag
    THEN CLEAR FORM
         CONSTRUCT BY NAME where_clause ON ped_itens_rem.cod_empresa,
                                           ped_itens_rem.num_pedido,
                                           ped_itens_rem.num_sequencia,
                                           ped_itens_rem.dat_emis_nf_usina,
                                           ped_itens_rem.dat_retorno_prev ,
                                           ped_itens_rem.cod_motivo_remessa,
                                           ped_itens_rem.val_estoque,
                                           ped_itens_rem.cod_area_negocio,
                                           ped_itens_rem.cod_lin_negocio,
                                           ped_itens_rem.num_conta,
                                           ped_itens_rem.tex_observ
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento... "
         END IF
         LET sql_stmt = " SELECT ped_itens_rem.cod_empresa, ",
                     " ped_itens_rem.num_pedido, ped_itens_rem.num_sequencia, ",
                     " ped_itens.cod_item,   item.den_item,     ",
                     " ped_itens_rem.dat_emis_nf_usina, ped_itens_rem.dat_retorno_prev,  ",
                     " ped_itens_rem.cod_motivo_remessa, ped_itens_rem.val_estoque,  ",
                     " ped_itens_rem.cod_area_negocio, ped_itens_rem.cod_lin_negocio, ",
                     " ped_itens_rem.num_conta, ped_itens_rem.tex_observ ",
                     "  FROM ped_itens_rem, ped_itens, OUTER item ",
                     " WHERE ", where_clause CLIPPED,
                     "  AND ped_itens.cod_empresa = ped_itens_rem.cod_empresa ",
                     "  AND ped_itens.num_pedido  = ped_itens_rem.num_pedido ",
                     "  AND ped_itens.num_sequencia = ped_itens_rem.num_sequencia ",
                     "  AND item.cod_empresa = ped_itens.cod_empresa ",
                     "  AND item.cod_item    = ped_itens.cod_item "  CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens_rem.cod_empresa, ",
                     " ped_itens_rem.num_pedido, ped_itens_rem.num_sequencia, ",
                     " ped_itens.cod_item,   item.den_item,     ",
                     " ped_itens_rem.dat_emis_nf_usina, ped_itens_rem.dat_retorno_prev,  ",
                     " ped_itens_rem.cod_motivo_remessa, ped_itens_rem.val_estoque,  ",
                     " ped_itens_rem.cod_area_negocio, ped_itens_rem.cod_lin_negocio, ",
                     " ped_itens_rem.num_conta, ped_itens_rem.tex_observ",
                     " FROM ped_itens_rem ,ped_itens, OUTER item ",
                    " WHERE ped_itens_rem.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                     "  AND ped_itens_rem.num_pedido  = ", p_pedidos1.num_pedido,
                     "  AND ped_itens.cod_empresa = ped_itens_rem.cod_empresa ",
                     "  AND ped_itens.num_pedido  = ped_itens_rem.num_pedido ",
                     "  AND ped_itens.num_sequencia = ped_itens_rem.num_sequencia ",
                     "  AND item.cod_empresa = ped_itens.cod_empresa",
                     "  AND item.cod_item    = ped_itens.cod_item"  CLIPPED
  END IF
 PREPARE var_query4 FROM sql_stmt
  DECLARE cq_itens_rem CURSOR FOR var_query4
  LET p_ind = 1
 INITIALIZE ar_ped_itens_rem  TO NULL
  FOREACH cq_itens_rem INTO p_ped_itens_rem1.*

      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens_rem[p_ind].num_pedido       = p_ped_itens_rem1.num_pedido
      LET ar_ped_itens_rem[p_ind].num_sequencia    = p_ped_itens_rem1.num_sequencia
      LET ar_ped_itens_rem[p_ind].cod_item         = p_ped_itens_rem1.cod_item
      LET ar_ped_itens_rem[p_ind].den_item   = p_ped_itens_rem1.den_item
      LET ar_ped_itens_rem[p_ind].dat_emis_nf_usina = p_ped_itens_rem1.dat_emis_nf_usina
      LET ar_ped_itens_rem[p_ind].dat_retorno_prev = p_ped_itens_rem1.dat_retorno_prev
      LET ar_ped_itens_rem[p_ind].cod_motivo_remessa = p_ped_itens_rem1.cod_motivo_remessa
      LET ar_ped_itens_rem[p_ind].val_estoque        = p_ped_itens_rem1.val_estoque
      LET ar_ped_itens_rem[p_ind].cod_area_negocio   = p_ped_itens_rem1.cod_area_negocio
      LET ar_ped_itens_rem[p_ind].cod_lin_negocio    = p_ped_itens_rem1.cod_lin_negocio
      LET ar_ped_itens_rem[p_ind].num_conta          = p_ped_itens_rem1.num_conta
      LET ar_ped_itens_rem[p_ind].tex_observ         = p_ped_itens_rem1.tex_observ
  LET p_ind = p_ind + 1
  { 300 eh o limite maximo para 4GL-FOR WINDOWS }
  { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
  { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
  IF  p_ind >= 50
  THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
       EXIT FOREACH
  END IF
END FOREACH
MESSAGE ""
IF p_ind = 1
THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
     LET p_ies_cons_itens = FALSE
ELSE CALL set_count(p_ind - 1 )
     DISPLAY BY NAME p_ped_itens_rem1.cod_empresa
     DISPLAY ARRAY ar_ped_itens_rem TO s_ar_itens_rem.*
END IF
LET int_flag = 0

END FUNCTION

#----------------------------------------------#
FUNCTION vdp426_consulta_itens_rem_pedido_hist()
#----------------------------------------------#

    IF   p_flag
    THEN CLEAR FORM
         CONSTRUCT BY NAME where_clause ON ped_itens_rem_hist.cod_empresa,
                                           ped_itens_rem_hist.num_pedido,
                                           ped_itens_rem_hist.num_sequencia,
                                           ped_itens_rem_hist.dat_emis_nf_usina,
                                           ped_itens_rem_hist.dat_retorno_prev,
                                           ped_itens_rem_hist.cod_motivo_remessa,
                                           ped_itens_rem_hist.val_estoque,
                                           ped_itens_rem_hist.cod_area_negocio,
                                           ped_itens_rem_hist.cod_lin_negocio,
                                           ped_itens_rem_hist.num_conta,
                                           ped_itens_rem_hist.tex_observ
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento... "
         END IF
         LET sql_stmt = " SELECT ped_itens_rem_hist.cod_empresa, ",
                     " ped_itens_rem_hist.num_pedido, ped_itens_rem_hist.num_sequencia, ",
                     " ped_itens_hist.cod_item,   item.den_item,     ",
                     " ped_itens_rem_hist.dat_emis_nf_usina, ped_itens_rem_hist.dat_retorno_prev,  ",
                     " ped_itens_rem_hist.cod_motivo_remessa, ped_itens_rem_hist.val_estoque,  ",
                     " ped_itens_rem_hist.cod_area_negocio, ped_itens_rem_hist.cod_lin_negocio, ",
                     " ped_itens_rem_hist.num_conta, ped_itens_rem_hist.tex_observ ",
                     "  FROM ped_itens_rem_hist,ped_itens_hist, OUTER item ",
                     " WHERE ", where_clause CLIPPED,
                     "  AND ped_itens_hist.cod_empresa = ped_itens_rem_hist.cod_empresa ",
                     "  AND ped_itens_hist.num_pedido  = ped_itens_rem_hist.num_pedido ",
                     "  AND ped_itens_hist.num_sequencia = ped_itens_rem_hist.num_sequencia ",
                     "  AND item.cod_empresa = ped_itens_hist.cod_empresa ",
                     "  AND item.cod_item    = ped_itens_hist.cod_item "  CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens_rem_hist.cod_empresa, ",
                     " ped_itens_rem_hist.num_pedido, ped_itens_rem_hist.num_sequencia, ",
                     " ped_itens_hist.cod_item,   item.den_item,     ",
                     " ped_itens_rem_hist.dat_emis_nf_usina, ped_itens_rem_hist.dat_retorno_prev,  ",
                     " ped_itens_rem_hist.cod_motivo_remessa, ped_itens_rem_hist.val_estoque,  ",
                     " ped_itens_rem_hist.cod_area_negocio, ped_itens_rem_hist.cod_lin_negocio, ",
                     " ped_itens_rem_hist.num_conta, ped_itens_rem_hist.tex_observ",
                     " FROM ped_itens_rem_hist ,ped_itens_hist, OUTER item ",
               " WHERE ped_itens_rem_hist.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                     "  AND ped_itens_rem_hist.num_pedido  = ", p_pedidos1.num_pedido,
                     "  AND ped_itens_hist.cod_empresa = ped_itens_rem_hist.cod_empresa ",
                     "  AND ped_itens_hist.num_pedido  = ped_itens_rem_hist.num_pedido ",
                     "  AND ped_itens_hist.num_sequencia = ped_itens_rem_hist.num_sequencia ",
                     "  AND item.cod_empresa = ped_itens_hist.cod_empresa",
                     "  AND item.cod_item    = ped_itens_hist.cod_item"  CLIPPED
  END IF
 PREPARE var_query5 FROM sql_stmt
  DECLARE cq_itens_rem_hist CURSOR FOR var_query5
  LET p_ind = 1
  FOREACH cq_itens_rem_hist INTO p_ped_itens_rem1.*

      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens_rem_h[p_ind].num_pedido       = p_ped_itens_rem1.num_pedido
      LET ar_ped_itens_rem_h[p_ind].num_sequencia    = p_ped_itens_rem1.num_sequencia
      LET ar_ped_itens_rem_h[p_ind].cod_item         = p_ped_itens_rem1.cod_item
      LET ar_ped_itens_rem_h[p_ind].den_item   = p_ped_itens_rem1.den_item
      LET ar_ped_itens_rem_h[p_ind].dat_emis_nf_usina = p_ped_itens_rem1.dat_emis_nf_usina
      LET ar_ped_itens_rem_h[p_ind].dat_retorno_prev = p_ped_itens_rem1.dat_retorno_prev
      LET ar_ped_itens_rem_h[p_ind].cod_motivo_remessa = p_ped_itens_rem1.cod_motivo_remessa
      LET ar_ped_itens_rem_h[p_ind].val_estoque        = p_ped_itens_rem1.val_estoque
      LET ar_ped_itens_rem_h[p_ind].cod_area_negocio   = p_ped_itens_rem1.cod_area_negocio
      LET ar_ped_itens_rem_h[p_ind].cod_lin_negocio    = p_ped_itens_rem1.cod_lin_negocio
      LET ar_ped_itens_rem_h[p_ind].num_conta          = p_ped_itens_rem1.num_conta
      LET ar_ped_itens_rem_h[p_ind].tex_observ         = p_ped_itens_rem1.tex_observ
  LET p_ind = p_ind + 1

  { 300 eh o limite maximo para 4GL-FOR WINDOWS }
  { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
  { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
  IF  p_ind >= 50
  THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
       EXIT FOREACH
  END IF
END FOREACH
MESSAGE ""
IF p_ind = 1
THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
     LET p_ies_cons_itens = FALSE
ELSE CALL set_count(p_ind - 1 )
     DISPLAY BY NAME p_ped_itens_rem1.cod_empresa
     DISPLAY ARRAY ar_ped_itens_rem_h TO s_ar_itens_rem.*
END IF
LET int_flag = 0
END FUNCTION


#----------------------------------#
 FUNCTION vdp426_verifica_empresa()
#----------------------------------#
SELECT cod_empresa FROM empresa
  WHERE empresa.cod_empresa = p_cod_empresa
IF sqlca.sqlcode = 0
   THEN RETURN FALSE
ELSE
   RETURN TRUE
END IF
END FUNCTION

#----------------------------------#
 FUNCTION vdp426_verifica_pedido()
#----------------------------------#
SELECT num_pedido FROM pedidos
  WHERE pedidos.num_pedido = p_num_pedido
    AND pedidos.cod_empresa = p_cod_empresa
IF sqlca.sqlcode = 0
   THEN RETURN FALSE
ELSE
   RETURN TRUE
END IF
END FUNCTION

#-------------------------------------#
 FUNCTION vdp426_verifica_pedido_hist()
#-------------------------------------#
SELECT num_pedido
  FROM pedidos_hist
  WHERE pedidos_hist.num_pedido = p_num_pedido
    AND pedidos_hist.cod_empresa = p_cod_empresa
IF sqlca.sqlcode = 0
   THEN RETURN FALSE
ELSE
   RETURN TRUE
END IF
END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION vdp426_consulta_itens_do_pedido()
#---------------------------------------------------------------------#
    IF   p_flag
    THEN CLEAR FORM
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
                                           ped_itens.prz_entrega
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento... "
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
                     " ped_itens.prz_entrega FROM ped_itens, OUTER item ",
                     "WHERE ", where_clause CLIPPED,
                     "  AND item.cod_empresa = ped_itens.cod_empresa",
                     "  AND item.cod_item    = ped_itens.cod_item",
                     " ORDER BY ped_itens.num_sequencia " CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens.cod_empresa, ",
                     " ped_itens.num_pedido, ped_itens.num_sequencia, ",
                     " ped_itens.cod_item,   item.den_item,     ",
                     " ped_itens.pre_unit, ped_itens.pct_desc_adic,  ",
                     " ped_itens.pct_desc_bruto, ",
                     " ped_itens.val_seguro_unit, ped_itens.val_frete_unit,  ",
                     " ped_itens.qtd_pecas_solic, ped_itens.qtd_pecas_atend, ",
                     " ped_itens.qtd_pecas_cancel, ped_itens.qtd_pecas_reserv,",
                     " ped_itens.qtd_pecas_romaneio, ",
                     " ped_itens.prz_entrega FROM ped_itens, OUTER item ",
               "WHERE ped_itens.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                     "  AND ped_itens.num_pedido  = ", p_pedidos1.num_pedido,
                     "  AND item.cod_empresa = ped_itens.cod_empresa",
                     "  AND item.cod_item    = ped_itens.cod_item",
                     " ORDER BY ped_itens.num_sequencia " CLIPPED
  END IF
 PREPARE var_query FROM sql_stmt
  DECLARE cq_itens CURSOR FOR var_query
  LET p_ind = 1
  FOREACH cq_itens INTO p_ped_itens1.*

      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens[p_ind].num_pedido       = p_ped_itens1.num_pedido
      LET ar_ped_itens[p_ind].num_sequencia    = p_ped_itens1.num_sequencia
      LET ar_ped_itens[p_ind].cod_item         = p_ped_itens1.cod_item
      LET ar_ped_itens[p_ind].pct_desc_adic    = p_ped_itens1.pct_desc_adic
      LET ar_ped_itens[p_ind].pct_desc_bruto   = p_ped_itens1.pct_desc_bruto
      LET ar_ped_itens[p_ind].pre_unit         = p_ped_itens1.pre_unit
      LET ar_ped_itens[p_ind].val_seguro_unit  = p_ped_itens1.val_seguro_unit
      LET ar_ped_itens[p_ind].val_frete_unit   = p_ped_itens1.val_frete_unit
      LET ar_ped_itens[p_ind].qtd_pecas_solic  = p_ped_itens1.qtd_pecas_solic
      LET ar_ped_itens[p_ind].qtd_pecas_atend  = p_ped_itens1.qtd_pecas_atend
      LET ar_ped_itens[p_ind].qtd_pecas_cancel = p_ped_itens1.qtd_pecas_cancel
      LET ar_ped_itens[p_ind].qtd_pecas_reserv = p_ped_itens1.qtd_pecas_reserv
    LET ar_ped_itens[p_ind].qtd_pecas_romaneio = p_ped_itens1.qtd_pecas_romaneio
      LET ar_ped_itens[p_ind].prz_entrega      = p_ped_itens1.prz_entrega
      LET ar_ped_itens[p_ind].den_item   = p_ped_itens1.den_item
      LET ar_ped_itens[p_ind].saldo = (p_ped_itens1.qtd_pecas_solic -
                                       p_ped_itens1.qtd_pecas_atend -
                                       p_ped_itens1.qtd_pecas_cancel)
      IF ar_ped_itens[p_ind].saldo < 0
      THEN LET ar_ped_itens[p_ind].saldo = 0
      END IF
      LET ar_ped_itens[p_ind].ies_texto = vdp0275_verifica_texto_item()

  LET p_ind = p_ind + 1

  { 300 eh o limite maximo para 4GL-FOR WINDOWS }
  { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
  { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
  IF  p_ind >= 1000
  THEN ERROR "Pesquisa ultrapassou 1000 ocorrencias. Restrinja sua pesquisa."
       EXIT FOREACH
  END IF
END FOREACH
# tupy
MESSAGE ""
IF p_ind = 1
THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
     LET p_ies_cons_itens = FALSE
ELSE CALL set_count(p_ind - 1 )
     DISPLAY BY NAME p_ped_itens1.cod_empresa
     #DISPLAY ARRAY ar_ped_itens TO s_ar_itens.*
     CALL log006_exibe_teclas('01 02 23', p_versao)
     CURRENT WINDOW IS w_vdp02753
     INPUT ARRAY ar_ped_itens WITHOUT DEFAULTS FROM s_ar_itens.*
        BEFORE ROW
           LET pa_curr = ARR_CURR()
           LET sc_curr = SCR_LINE()

        ON KEY (control-t)
           IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
              CALL log120_procura_caminho("VDP2500") RETURNING p_comando
              LET p_comando = p_comando CLIPPED," ",ar_ped_itens[pa_curr].num_pedido," ",ar_ped_itens[pa_curr].num_sequencia
              RUN p_comando
           END IF
           CURRENT WINDOW IS w_vdp02753
     END INPUT
END IF
LET int_flag = 0
# tupy
END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION vdp426_consulta_itens_do_pedido_hist()
#---------------------------------------------------------------------#
    IF   p_flag
    THEN CLEAR FORM
         CONSTRUCT BY NAME where_clause ON ped_itens_hist.cod_empresa,
                                           ped_itens_hist.num_pedido,
                                           ped_itens_hist.num_sequencia,
                                           ped_itens_hist.cod_item,
                                           ped_itens_hist.pre_unit,
                                           ped_itens_hist.pct_desc_adic,
                                           ped_itens_hist.pct_desc_bruto,
                                           ped_itens_hist.val_seguro_unit,
                                           ped_itens_hist.val_frete_unit,
                                           ped_itens_hist.qtd_pecas_solic,
                                           ped_itens_hist.qtd_pecas_atend,
                                           ped_itens_hist.qtd_pecas_cancel,
                                           ped_itens_hist.qtd_pecas_reserv,
                                           ped_itens_hist.qtd_pecas_romaneio,
                                           ped_itens_hist.prz_entrega
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento... "
         END IF
         LET sql_stmt = " SELECT ped_itens_hist.cod_empresa, ",
          " ped_itens_hist.num_pedido,ped_itens_hist.num_sequencia, ",
          " ped_itens_hist.cod_item,         item.den_item,     ",
          " ped_itens_hist.pre_unit,         ped_itens_hist.pct_desc_adic,  ",
          " ped_itens_hist.pct_desc_bruto, ",
          " ped_itens_hist.val_seguro_unit,  ped_itens_hist.val_frete_unit,  ",
          " ped_itens_hist.qtd_pecas_solic,  ped_itens_hist.qtd_pecas_atend, ",
          " ped_itens_hist.qtd_pecas_cancel, ped_itens_hist.qtd_pecas_reserv,",
          " ped_itens_hist.qtd_pecas_romaneio, ",
          " ped_itens_hist.prz_entrega FROM  ped_itens_hist, OUTER item ",
          "WHERE ", where_clause CLIPPED,
          "  AND item.cod_empresa = ped_itens_hist.cod_empresa",
          "  AND item.cod_item    = ped_itens_hist.cod_item"  CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens_hist.cod_empresa, ",
          " ped_itens_hist.num_pedido, ped_itens_hist.num_sequencia, ",
          " ped_itens_hist.cod_item,   item.den_item,     ",
          " ped_itens_hist.pre_unit, ped_itens_hist.pct_desc_adic,  ",
          " ped_itens_hist.pct_desc_bruto, ",
          " ped_itens_hist.val_seguro_unit,  ped_itens_hist.val_frete_unit,  ",
          " ped_itens_hist.qtd_pecas_solic, ped_itens_hist.qtd_pecas_atend, ",
          " ped_itens_hist.qtd_pecas_cancel, ped_itens_hist.qtd_pecas_reserv,",
          " ped_itens_hist.qtd_pecas_romaneio, ",
          " ped_itens_hist.prz_entrega FROM ped_itens_hist, OUTER item ",
          "WHERE ped_itens_hist.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
          "  AND ped_itens_hist.num_pedido  = ", p_pedidos1.num_pedido,
          "  AND item.cod_empresa = ped_itens_hist.cod_empresa",
          "  AND item.cod_item    = ped_itens_hist.cod_item"  CLIPPED
  END IF

  PREPARE var_query1 FROM sql_stmt
  DECLARE cq_itens1 CURSOR FOR var_query1
  OPEN cq_itens1
  LET p_ind = 1

  FETCH cq_itens1 INTO p_ped_itens1.*
  IF sqlca.sqlcode = NOTFOUND
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
       LET p_ies_cons_itens = FALSE
  ELSE
     WHILE sqlca.sqlcode <> NOTFOUND

      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens_h[p_ind].num_pedido       = p_ped_itens1.num_pedido
      LET ar_ped_itens_h[p_ind].num_sequencia    = p_ped_itens1.num_sequencia
      LET ar_ped_itens_h[p_ind].cod_item         = p_ped_itens1.cod_item
      LET ar_ped_itens_h[p_ind].pct_desc_adic    = p_ped_itens1.pct_desc_adic
      LET ar_ped_itens_h[p_ind].pct_desc_bruto   = p_ped_itens1.pct_desc_bruto
      LET ar_ped_itens_h[p_ind].pre_unit         = p_ped_itens1.pre_unit
      LET ar_ped_itens_h[p_ind].val_seguro_unit  = p_ped_itens1.val_seguro_unit
      LET ar_ped_itens_h[p_ind].val_frete_unit   = p_ped_itens1.val_frete_unit
      LET ar_ped_itens_h[p_ind].qtd_pecas_solic  = p_ped_itens1.qtd_pecas_solic
      LET ar_ped_itens_h[p_ind].qtd_pecas_atend  = p_ped_itens1.qtd_pecas_atend
      LET ar_ped_itens_h[p_ind].qtd_pecas_cancel = p_ped_itens1.qtd_pecas_cancel
      LET ar_ped_itens_h[p_ind].qtd_pecas_reserv = p_ped_itens1.qtd_pecas_reserv
      LET ar_ped_itens_h[p_ind].qtd_pecas_romaneio = p_ped_itens1.qtd_pecas_romaneio
      LET ar_ped_itens_h[p_ind].prz_entrega      = p_ped_itens1.prz_entrega
      LET ar_ped_itens_h[p_ind].den_item   = p_ped_itens1.den_item
      LET ar_ped_itens_h[p_ind].saldo = (p_ped_itens1.qtd_pecas_solic -
                                       p_ped_itens1.qtd_pecas_atend -
                                       p_ped_itens1.qtd_pecas_cancel)
      IF ar_ped_itens_h[p_ind].saldo < 0
      THEN LET ar_ped_itens_h[p_ind].saldo = 0
      END IF

      LET p_ind = p_ind + 1

      { 300 eh o limite maximo para 4GL-FOR WINDOWS }
      { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
      { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
      IF  p_ind >= 50
      THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
           EXIT WHILE
      END IF

      FETCH cq_itens1 INTO p_ped_itens1.*
     END WHILE
  END IF
MESSAGE ""
CALL set_count(p_ind - 1 )
DISPLAY BY NAME p_ped_itens1.cod_empresa
DISPLAY ARRAY ar_ped_itens_h TO s_ar_itens.*
CLOSE cq_itens1
END FUNCTION

#------------------------------------------------#
 FUNCTION vdp426_consulta_itens_grade_do_pedido()
#------------------------------------------------#

  IF   p_flag
  THEN CLEAR FORM
       CONSTRUCT BY NAME where_clause ON ped_itens_grade.cod_empresa,
                                         ped_itens_grade.num_pedido,
                                         ped_itens_grade.num_sequencia,
                                         ped_itens_grade.cod_item,
                                         ped_itens_grade.cod_grade_1,
                                         ped_itens_grade.cod_grade_2,
                                         ped_itens_grade.cod_grade_3,
                                         ped_itens_grade.cod_grade_4,
                                         ped_itens_grade.cod_grade_5,
                                         ped_itens_grade.qtd_pecas_solic,
                                         ped_itens_grade.qtd_pecas_atend,
                                         ped_itens_grade.qtd_pecas_cancel,
                                         ped_itens_grade.qtd_pecas_reserv,
                                         ped_itens_grade.qtd_pecas_romaneio
       IF   int_flag
       THEN LET int_flag = 0
            ERROR " Consulta Cancelada "
            CLEAR FORM
            RETURN
       ELSE MESSAGE "Aguarde processamento..."
       END IF
       LET sql_stmt = " SELECT ped_itens_grade.num_pedido,    ",
                              "ped_itens_grade.num_sequencia, ",
                              "ped_itens_grade.cod_item,      ",
                              "item.den_item,                 ","' ',",
                              "ped_itens_grade.cod_grade_1,   ","' ',",
                              "ped_itens_grade.cod_grade_2,   ","' ',",
                              "ped_itens_grade.cod_grade_3,   ","' ',",
                              "ped_itens_grade.cod_grade_4,   ","' ',",
                              "ped_itens_grade.cod_grade_5,   ",
                              "ped_itens_grade.qtd_pecas_solic, ",
                              "ped_itens_grade.qtd_pecas_atend, ",
                              "ped_itens_grade.qtd_pecas_cancel,",
                              "ped_itens_grade.qtd_pecas_reserv,",
                              "ped_itens_grade.qtd_pecas_romaneio ",
                      "   FROM ped_itens_grade, OUTER item ",
                      "  WHERE ", where_clause CLIPPED,
                      "    AND item.cod_empresa = ped_itens_grade.cod_empresa",
                      "    AND item.cod_item    = ped_itens_grade.cod_item",
                      "  ORDER BY ped_itens_grade.num_sequencia " CLIPPED
  ELSE LET sql_stmt = " SELECT ped_itens_grade.num_pedido,    ",
                              "ped_itens_grade.num_sequencia, ",
                              "ped_itens_grade.cod_item,      ",
                              "item.den_item,                 ","' ',",
                              "ped_itens_grade.cod_grade_1,   ","' ',",
                              "ped_itens_grade.cod_grade_2,   ","' ',",
                              "ped_itens_grade.cod_grade_3,   ","' ',",
                              "ped_itens_grade.cod_grade_4,   ","' ',",
                              "ped_itens_grade.cod_grade_5,   ",
                              "ped_itens_grade.qtd_pecas_solic, ",
                              "ped_itens_grade.qtd_pecas_atend, ",
                              "ped_itens_grade.qtd_pecas_cancel,",
                              "ped_itens_grade.qtd_pecas_reserv,",
                              "ped_itens_grade.qtd_pecas_romaneio ",
                      "   FROM ped_itens_grade, OUTER item ",
                      "  WHERE ped_itens_grade.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                      "    AND ped_itens_grade.num_pedido  = ", p_pedidos1.num_pedido,
                      "    AND item.cod_empresa            = ped_itens_grade.cod_empresa",
                      "    AND item.cod_item               = ped_itens_grade.cod_item",
                      "  ORDER BY ped_itens_grade.num_sequencia " CLIPPED
  END IF

  PREPARE var_query_gr FROM sql_stmt
  DECLARE cq_itens_grade CURSOR FOR var_query_gr

  LET p_ind = 1

  FOREACH cq_itens_grade INTO t_ped_itens_gr[p_ind].*
     LET p_ies_cons_itens = TRUE
     LET t_ped_itens_gr[p_ind].saldo = (t_ped_itens_gr[p_ind].qtd_pecas_solic -
                                        t_ped_itens_gr[p_ind].qtd_pecas_atend -
                                        t_ped_itens_gr[p_ind].qtd_pecas_cancel)
     IF t_ped_itens_gr[p_ind].saldo < 0 THEN
        LET t_ped_itens_gr[p_ind].saldo = 0
     END IF

     CALL vdp4267_busca_cab_grade()

     LET p_ind = p_ind + 1
     IF p_ind >= 1000 THEN
        ERROR "Pesquisa ultrapassou 1000 ocorrencias. Restrinja sua pesquisa."
        EXIT FOREACH
     END IF
  END FOREACH

  MESSAGE ""
  IF   p_ind = 1
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
       LET  p_ies_cons_itens = FALSE
  ELSE CALL set_count(p_ind - 1 )
       DISPLAY BY NAME p_pedidos1.cod_empresa
       DISPLAY ARRAY t_ped_itens_gr TO s_ped_itens_gr.*
  END IF
  LET int_flag = 0
END FUNCTION


#--------------------------------#
FUNCTION vdp4267_busca_cab_grade()
#--------------------------------#
   DEFINE lr_item_ctr_grade      RECORD LIKE item_ctr_grade.*

   SELECT *
     INTO lr_item_ctr_grade.*
     FROM item_ctr_grade
    WHERE cod_empresa        = p_cod_empresa
      AND cod_lin_prod       = 0
      AND cod_lin_recei      = 0
      AND cod_seg_merc       = 0
      AND cod_cla_uso        = 0
      AND cod_familia        = 0
      AND cod_item           = t_ped_itens_gr[p_ind].cod_item
   IF sqlca.sqlcode <> 0 THEN
      RETURN
   END IF

   SELECT den_grade_reduz
     INTO t_ped_itens_gr[p_ind].den_grade_1
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = lr_item_ctr_grade.num_grade_1

   SELECT den_grade_reduz
     INTO t_ped_itens_gr[p_ind].den_grade_2
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = lr_item_ctr_grade.num_grade_2

   SELECT den_grade_reduz
     INTO t_ped_itens_gr[p_ind].den_grade_3
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = lr_item_ctr_grade.num_grade_3

   SELECT den_grade_reduz
     INTO t_ped_itens_gr[p_ind].den_grade_4
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = lr_item_ctr_grade.num_grade_4

   SELECT den_grade_reduz
     INTO t_ped_itens_gr[p_ind].den_grade_5
     FROM grade
    WHERE cod_empresa    = p_cod_empresa
      AND cod_grade      = lr_item_ctr_grade.num_grade_5

END FUNCTION


#-----------------------------------------------------#
 FUNCTION vdp426_consulta_itens_grade_do_pedido_hist()
#-----------------------------------------------------#

  IF   p_flag
  THEN CLEAR FORM
       CONSTRUCT BY NAME where_clause ON ped_itens_grade_h.cod_empresa,
                                         ped_itens_grade_h.num_pedido,
                                         ped_itens_grade_h.num_sequencia,
                                         ped_itens_grade_h.cod_item,
                                         ped_itens_grade_h.cod_grade_1,
                                         ped_itens_grade_h.cod_grade_2,
                                         ped_itens_grade_h.cod_grade_3,
                                         ped_itens_grade_h.cod_grade_4,
                                         ped_itens_grade_h.cod_grade_5,
                                         ped_itens_grade_h.qtd_pecas_solic,
                                         ped_itens_grade_h.qtd_pecas_atend,
                                         ped_itens_grade_h.qtd_pecas_cancel,
                                         ped_itens_grade_h.qtd_pecas_reserv,
                                         ped_itens_grade_h.qtd_pecas_romaneio
       IF   int_flag
       THEN LET int_flag = 0
            ERROR " Consulta Cancelada "
            CLEAR FORM
            RETURN
       ELSE MESSAGE "Aguarde processamento... "
       END IF
       LET sql_stmt = " SELECT ped_itens_grade_h.num_pedido,    ",
                              "ped_itens_grade_h.num_sequencia, ",
                              "ped_itens_grade_h.cod_item,      ",
                              "item.den_item,                   ","' ',",
                              "ped_itens_grade_h.cod_grade_1,   ","' ',",
                              "ped_itens_grade_h.cod_grade_2,   ","' ',",
                              "ped_itens_grade_h.cod_grade_3,   ","' ',",
                              "ped_itens_grade_h.cod_grade_4,   ","' ',",
                              "ped_itens_grade_h.cod_grade_5,   ",
                              "ped_itens_grade_h.qtd_pecas_solic, ",
                              "ped_itens_grade_h.qtd_pecas_atend, ",
                              "ped_itens_grade_h.qtd_pecas_cancel,",
                              "ped_itens_grade_h.qtd_pecas_reserv,",
                              "ped_itens_grade_h.qtd_pecas_romaneio ",
                      "   FROM ped_itens_grade_h, OUTER item ",
                      "  WHERE ", where_clause CLIPPED,
                      "    AND item.cod_empresa = ped_itens_grade_h.cod_empresa",
                      "    AND item.cod_item    = ped_itens_grade_h.cod_item",
                      "  ORDER BY ped_itens_grade_h.num_sequencia " CLIPPED
  ELSE LET sql_stmt = " SELECT ped_itens_grade_h.num_pedido,    ",
                              "ped_itens_grade_h.num_sequencia, ",
                              "ped_itens_grade_h.cod_item,      ",
                              "item.den_item,                   ","' ',",
                              "ped_itens_grade_h.cod_grade_1,   ","' ',",
                              "ped_itens_grade_h.cod_grade_2,   ","' ',",
                              "ped_itens_grade_h.cod_grade_3,   ","' ',",
                              "ped_itens_grade_h.cod_grade_4,   ","' ',",
                              "ped_itens_grade_h.cod_grade_5,   ",
                              "ped_itens_grade_h.qtd_pecas_solic, ",
                              "ped_itens_grade_h.qtd_pecas_atend, ",
                              "ped_itens_grade_h.qtd_pecas_cancel,",
                              "ped_itens_grade_h.qtd_pecas_reserv,",
                              "ped_itens_grade_h.qtd_pecas_romaneio ",
                      "   FROM ped_itens_grade_h, OUTER item ",
                      "  WHERE ped_itens_grade_h.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                      "    AND ped_itens_grade_h.num_pedido          = ", p_pedidos1.num_pedido,
                      "    AND item.cod_empresa              = ped_itens_grade_h.cod_empresa",
                      "    AND item.cod_item                 = ped_itens_grade_h.cod_item",
                      "  ORDER BY ped_itens_grade_h.num_sequencia " CLIPPED
  END IF

  PREPARE var_query_gr1 FROM sql_stmt
  DECLARE cq_itens_grade_h CURSOR FOR var_query_gr1

  LET p_ind = 1

  FOREACH cq_itens_grade_h INTO t_ped_itens_gr_h[p_ind].*
     LET  p_ies_cons_itens = TRUE
     LET  t_ped_itens_gr_h[p_ind].saldo = (t_ped_itens_gr_h[p_ind].qtd_pecas_solic -
                                         t_ped_itens_gr_h[p_ind].qtd_pecas_atend -
                                         t_ped_itens_gr_h[p_ind].qtd_pecas_cancel)
     IF   t_ped_itens_gr_h[p_ind].saldo < 0
     THEN LET t_ped_itens_gr_h[p_ind].saldo = 0
     END IF
     LET p_ind = p_ind + 1
     IF  p_ind >= 1000
     THEN ERROR "Pesquisa ultrapassou 1000 ocorrencias. Restrinja sua pesquisa."
          EXIT FOREACH
     END IF
  END FOREACH
  MESSAGE ""
  IF   p_ind = 1
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados","exclamation")
       LET  p_ies_cons_itens = FALSE
  ELSE CALL set_count(p_ind - 1 )
       DISPLAY BY NAME p_pedidos1.cod_empresa
       DISPLAY ARRAY t_ped_itens_gr_h TO s_ped_itens_gr.*
  END IF
  LET int_flag = 0
END FUNCTION

#------------------------------------------------#
 FUNCTION vdp426_consulta_itens_cancel_do_pedido()
#------------------------------------------------#
  IF   p_flag
  THEN CLEAR FORM
       CONSTRUCT BY NAME where_clause ON ped_itens_cancel.cod_empresa,
                                         ped_itens_cancel.num_pedido,
                                         ped_itens_cancel.num_sequencia,
                                         ped_itens_cancel.cod_item,
                                         ped_itens_cancel.dat_cancel,
                                         ped_itens_cancel.qtd_pecas_cancel,
                                         ped_itens_cancel.cod_motivo_can
       IF   int_flag
       THEN LET int_flag = 0
            ERROR " Consulta Cancelada "
            CLEAR FORM
            RETURN
       ELSE MESSAGE "Aguarde processamento..."
       END IF
       LET sql_stmt = " SELECT ped_itens_cancel.num_pedido,      ",
                              "ped_itens_cancel.num_sequencia,   ",
                              "ped_itens_cancel.cod_item,        ",
                              "item.den_item,                    ",
                              "ped_itens_cancel.dat_cancel,      ",
                              "ped_itens_cancel.qtd_pecas_cancel,",
                              "ped_itens_cancel.cod_motivo_can,  ",
                              "mot_cancel.den_motivo             ",
                      "   FROM ped_itens_cancel, OUTER item, OUTER mot_cancel ",
                      "  WHERE ", where_clause CLIPPED,
                      "    AND item.cod_empresa      = ped_itens_cancel.cod_empresa",
                      "    AND item.cod_item         = ped_itens_cancel.cod_item",
                      "    AND mot_cancel.cod_motivo = ped_itens_cancel.cod_motivo_can",
                      "  ORDER BY ped_itens_cancel.num_sequencia " CLIPPED
  ELSE LET sql_stmt = " SELECT ped_itens_cancel.num_pedido,      ",
                              "ped_itens_cancel.num_sequencia,   ",
                              "ped_itens_cancel.cod_item,        ",
                              "item.den_item,                    ",
                              "ped_itens_cancel.dat_cancel,      ",
                              "ped_itens_cancel.qtd_pecas_cancel,",
                              "ped_itens_cancel.cod_motivo_can,  ",
                              "mot_cancel.den_motivo             ",
                      "   FROM ped_itens_cancel, OUTER item, OUTER mot_cancel ",
                      "  WHERE ped_itens_cancel.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                      "    AND ped_itens_cancel.num_pedido  = ", p_pedidos1.num_pedido,
                      "    AND item.cod_empresa             = ped_itens_cancel.cod_empresa",
                      "    AND item.cod_item                = ped_itens_cancel.cod_item",
                      "    AND mot_cancel.cod_motivo        = ped_itens_cancel.cod_motivo_can",
                      "  ORDER BY ped_itens_cancel.num_sequencia " CLIPPED
  END IF

  PREPARE var_query_ca FROM sql_stmt
  DECLARE cq_itens_cancel CURSOR FOR var_query_ca

  LET p_ind = 1

  FOREACH cq_itens_cancel INTO t_ped_itens_ca[p_ind].*
     LET  p_ies_cons_itens = TRUE

     LET p_ind = p_ind + 1
     { 150 eh o limite maximo para 4GL-FOR WINDOWS }
     { A quantidade de 150 foi alterada para 50 para atender a pasa 12280. }
     { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
     IF  p_ind >= 50
     THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
          EXIT FOREACH
     END IF
  END FOREACH

  MESSAGE ""
  IF   p_ind = 1
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
       LET  p_ies_cons_itens = FALSE
  ELSE CALL set_count(p_ind - 1 )
       DISPLAY BY NAME p_pedidos1.cod_empresa
       DISPLAY ARRAY t_ped_itens_ca TO s_ped_itens_ca.*
  END IF
  LET int_flag = 0
END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION vdp426_consulta_itens_bnf_pedido()
#---------------------------------------------------------------------#
    IF   p_flag
    THEN CLEAR FORM
         CONSTRUCT BY NAME where_clause ON ped_itens_bnf.cod_empresa,
                                           ped_itens_bnf.num_pedido,
                                           ped_itens_bnf.num_sequencia,
                                           ped_itens_bnf.cod_item,
                                           ped_itens_bnf.pre_unit,
                                           ped_itens_bnf.pct_desc_adic,
                                           ped_itens_bnf.qtd_pecas_solic,
                                           ped_itens_bnf.qtd_pecas_atend,
                                           ped_itens_bnf.qtd_pecas_cancel,
                                           ped_itens_bnf.qtd_pecas_reserv,
                                           ped_itens_bnf.prz_entrega
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento..."
         END IF
         LET sql_stmt = " SELECT ped_itens_bnf.cod_empresa, ",
                     " ped_itens_bnf.num_pedido, ped_itens_bnf.num_sequencia, ",
                     " ped_itens_bnf.cod_item, item.den_item,     ",
                     " ped_itens_bnf.pre_unit, ped_itens_bnf.pct_desc_adic,  ",
                     " ped_itens_bnf.qtd_pecas_solic, ped_itens_bnf.qtd_pecas_atend, ",
                     " ped_itens_bnf.qtd_pecas_cancel, ped_itens_bnf.qtd_pecas_reserv,",
                     " ped_itens_bnf.prz_entrega FROM ped_itens_bnf, OUTER item ",
                     "WHERE ", where_clause CLIPPED,
                     "  AND item.cod_empresa = ped_itens_bnf.cod_empresa",
                     "  AND item.cod_item    = ped_itens_bnf.cod_item"  CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens_bnf.cod_empresa, ",
                     " ped_itens_bnf.num_pedido, ped_itens_bnf.num_sequencia, ",
                     " ped_itens_bnf.cod_item,   item.den_item,     ",
                     " ped_itens_bnf.pre_unit, ped_itens_bnf.pct_desc_adic,  ",
                     " ped_itens_bnf.qtd_pecas_solic, ped_itens_bnf.qtd_pecas_atend, ",
                     " ped_itens_bnf.qtd_pecas_cancel, ped_itens_bnf.qtd_pecas_reserv,",
                     " ped_itens_bnf.prz_entrega FROM ped_itens_bnf, OUTER item ",
               "WHERE ped_itens_bnf.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                     "  AND ped_itens_bnf.num_pedido  = ", p_pedidos1.num_pedido,
                     "  AND item.cod_empresa = ped_itens_bnf.cod_empresa",
                     "  AND item.cod_item    = ped_itens_bnf.cod_item"  CLIPPED
  END IF
  PREPARE var_query2 FROM sql_stmt
  DECLARE cq_itens_bnf CURSOR FOR var_query2
  LET p_ind = 1
  FOREACH cq_itens_bnf INTO p_ped_itens_bnf1.*

      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens_bnf[p_ind].num_pedido       = p_ped_itens_bnf1.num_pedido
      LET ar_ped_itens_bnf[p_ind].num_sequencia    = p_ped_itens_bnf1.num_sequencia
      LET ar_ped_itens_bnf[p_ind].cod_item         = p_ped_itens_bnf1.cod_item
      LET ar_ped_itens_bnf[p_ind].pct_desc_adic    = p_ped_itens_bnf1.pct_desc_adic
      LET ar_ped_itens_bnf[p_ind].pre_unit         = p_ped_itens_bnf1.pre_unit
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_solic  = p_ped_itens_bnf1.qtd_pecas_solic
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_atend  = p_ped_itens_bnf1.qtd_pecas_atend
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_cancel = p_ped_itens_bnf1.qtd_pecas_cancel
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_reserv = p_ped_itens_bnf1.qtd_pecas_reserv
      LET ar_ped_itens_bnf[p_ind].prz_entrega      = p_ped_itens_bnf1.prz_entrega
      LET ar_ped_itens_bnf[p_ind].den_item   = p_ped_itens_bnf1.den_item
      LET ar_ped_itens_bnf[p_ind].saldo = (p_ped_itens_bnf1.qtd_pecas_solic -
                                       p_ped_itens_bnf1.qtd_pecas_atend -
                                       p_ped_itens_bnf1.qtd_pecas_cancel)
      IF ar_ped_itens_bnf[p_ind].saldo < 0
      THEN LET ar_ped_itens_bnf[p_ind].saldo = 0
      END IF
  LET p_ind = p_ind + 1

  { 300 eh o limite maximo para 4GL-FOR WINDOWS }
  { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
  { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
  IF  p_ind >= 50
  THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
       EXIT FOREACH
  END IF
END FOREACH
# tupy
MESSAGE ""
IF p_ind = 1
THEN  CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
      LET p_ies_cons_itens = FALSE
ELSE CALL set_count(p_ind - 1 )
     DISPLAY BY NAME p_ped_itens_bnf1.cod_empresa
     DISPLAY ARRAY ar_ped_itens_bnf TO s_ar_itens_bnf.*
END IF
LET int_flag = 0
# tupy
END FUNCTION

#----------------------------------------------------------------------#
 FUNCTION vdp426_consulta_itens_bnf_pedido_hist()
#---------------------------------------------------------------------#
    IF   p_flag
    THEN CLEAR FORM
         CONSTRUCT BY NAME where_clause ON ped_itens_bnf_hist.cod_empresa,
                                           ped_itens_bnf_hist.num_pedido,
                                           ped_itens_bnf_hist.num_sequencia,
                                           ped_itens_bnf_hist.cod_item,
                                           ped_itens_bnf_hist.pre_unit,
                                           ped_itens_bnf_hist.pct_desc_adic,
                                           ped_itens_bnf_hist.qtd_pecas_solic,
                                           ped_itens_bnf_hist.qtd_pecas_atend,
                                           ped_itens_bnf_hist.qtd_pecas_cancel,
                                           ped_itens_bnf_hist.qtd_pecas_reserv,
                                           ped_itens_bnf_hist.prz_entrega
         IF   int_flag
         THEN LET int_flag = 0
              ERROR " Consulta Cancelada "
              CLEAR FORM
              RETURN
         ELSE MESSAGE "Aguarde processamento... "
         END IF
         LET sql_stmt = " SELECT ped_itens_bnf_hist.cod_empresa, ",
          " ped_itens_bnf_hist.num_pedido,ped_itens_bnf_hist.num_sequencia, ",
          " ped_itens_bnf_hist.cod_item,         item.den_item,     ",
          " ped_itens_bnf_hist.pre_unit,         ped_itens_bnf_hist.pct_desc_adic,  ",
          " ped_itens_bnf_hist.qtd_pecas_solic,  ped_itens_bnf_hist.qtd_pecas_atend, ",
          " ped_itens_bnf_hist.qtd_pecas_cancel, ped_itens_bnf_hist.qtd_pecas_reserv,",
          " ped_itens_bnf_hist.prz_entrega FROM  ped_itens_bnf_hist, OUTER item ",
          "WHERE ", where_clause CLIPPED,
          "  AND item.cod_empresa = ped_itens_bnf_hist.cod_empresa",
          "  AND item.cod_item    = ped_itens_bnf_hist.cod_item"  CLIPPED
    ELSE LET sql_stmt = " SELECT ped_itens_bnf_hist.cod_empresa, ",
          " ped_itens_bnf_hist.num_pedido, ped_itens_bnf_hist.num_sequencia, ",
          " ped_itens_bnf_hist.cod_item,   item.den_item,     ",
          " ped_itens_bnf_hist.pre_unit, ped_itens_bnf_hist.pct_desc_adic,  ",
          " ped_itens_bnf_hist.qtd_pecas_solic, ped_itens_bnf_hist.qtd_pecas_atend, ",
          " ped_itens_bnf_hist.qtd_pecas_cancel, ped_itens_bnf_hist.qtd_pecas_reserv,",
          " ped_itens_bnf_hist.prz_entrega FROM ped_itens_bnf_hist, OUTER item ",
          "WHERE ped_itens_bnf_hist.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
          "  AND ped_itens_bnf_hist.num_pedido  = ", p_pedidos1.num_pedido,
          "  AND item.cod_empresa = ped_itens_bnf_hist.cod_empresa",
          "  AND item.cod_item    = ped_itens_bnf_hist.cod_item"  CLIPPED
  END IF

  PREPARE var_query3 FROM sql_stmt
  DECLARE cq_itens_bnf1 CURSOR FOR var_query3
  OPEN cq_itens_bnf1
  LET p_ind = 1
  FETCH cq_itens_bnf1 INTO p_ped_itens_bnf1.*
  IF sqlca.sqlcode = NOTFOUND
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
       LET p_ies_cons_itens = FALSE
  ELSE
     WHILE sqlca.sqlcode <> NOTFOUND
      LET p_ies_cons_itens = TRUE
      LET ar_ped_itens_bnf[p_ind].num_pedido       = p_ped_itens_bnf1.num_pedido
      LET ar_ped_itens_bnf[p_ind].num_sequencia    = p_ped_itens_bnf1.num_sequencia
      LET ar_ped_itens_bnf[p_ind].cod_item         = p_ped_itens_bnf1.cod_item
      LET ar_ped_itens_bnf[p_ind].pct_desc_adic    = p_ped_itens_bnf1.pct_desc_adic
      LET ar_ped_itens_bnf[p_ind].pre_unit         = p_ped_itens_bnf1.pre_unit
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_solic  = p_ped_itens_bnf1.qtd_pecas_solic
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_atend  = p_ped_itens_bnf1.qtd_pecas_atend
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_cancel = p_ped_itens_bnf1.qtd_pecas_cancel
      LET ar_ped_itens_bnf[p_ind].qtd_pecas_reserv = p_ped_itens_bnf1.qtd_pecas_reserv
      LET ar_ped_itens_bnf[p_ind].prz_entrega      = p_ped_itens_bnf1.prz_entrega
      LET ar_ped_itens_bnf[p_ind].den_item   = p_ped_itens_bnf1.den_item
      LET ar_ped_itens_bnf[p_ind].saldo = (p_ped_itens_bnf1.qtd_pecas_solic -
                                           p_ped_itens_bnf1.qtd_pecas_atend -
                                           p_ped_itens_bnf1.qtd_pecas_cancel)
      IF ar_ped_itens_bnf[p_ind].saldo < 0
      THEN LET ar_ped_itens_bnf[p_ind].saldo = 0
      END IF
      LET p_ind = p_ind + 1
      { 300 eh o limite maximo para 4GL-FOR WINDOWS }
      { A quantidade de 300 foi alterada para 50 para atender a pasa 12280. }
      { Favor nao alterar esta quantidade antes de consultar o Sr. Rubens.  }
      IF  p_ind >= 50
      THEN ERROR "Pesquisa ultrapassou 50 ocorrencias. Restrinja sua pesquisa."
           EXIT WHILE
      END IF
      FETCH cq_itens_bnf1 INTO p_ped_itens_bnf1.*
     END WHILE
  END IF
MESSAGE ""
IF p_ind = 1
THEN  CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
      LET p_ies_cons_itens = FALSE
ELSE CALL set_count(p_ind - 1 )
     DISPLAY BY NAME p_ped_itens_bnf1.cod_empresa
     DISPLAY ARRAY ar_ped_itens_bnf_h TO s_ar_itens_bnf.*
END IF
LET int_flag = 0
CLOSE cq_itens_bnf1

END FUNCTION


#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_entrega()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02754") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02754 AT 6,03 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
     IF p_tip_consulta = 1 THEN
        CALL vdp426_consulta_entrega_do_pedido()
        LET p_tip_consul_ent = 1
     ELSE
        CALL vdp426_consulta_entrega_do_pedido_hist()
        LET p_tip_consul_ent = 2
     END IF
  END IF
  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Endereco Entrega do pedido"
      HELP 4
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         LET  p_tip_consul_ent = 1
         CALL vdp426_consulta_entrega_do_pedido()
         LET p_num_pedido = p_pedidos1.num_pedido
      END IF
    COMMAND "Historico"    "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         LET  p_tip_consul_ent = 2
         CALL vdp426_consulta_entrega_do_pedido_hist()
         LET p_num_pedido = p_pedidos1.num_pedido
      END IF
    COMMAND "Seguinte"   "Exibe Endereco Entrega seguinte"
      HELP 5
      MESSAGE ""
      IF   p_tip_consul_ent = 1
      THEN CALL vdp426_paginacao_entrega("SEGUINTE")
      ELSE CALL vdp426_paginacao_entrega_hist("SEGUINTE")
      END IF
    COMMAND "Anterior"   "Exibe Endereco Entrega anterior"
      HELP 6
      MESSAGE ""
      IF   p_tip_consul_ent = 1
      THEN CALL vdp426_paginacao_entrega("ANTERIOR")
      ELSE CALL vdp426_paginacao_entrega_hist("ANTERIOR")
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED ," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02754
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_entrega_do_pedido()
#---------------------------------------------------------------------#
  IF p_num_pedido IS NULL
  THEN LET int_flag = 0
       LET p_entregar.* = p_entrega.*
       INITIALIZE p_entrega.* TO NULL
       CLEAR FORM
       CALL log006_exibe_teclas("02 07", p_versao)
       CURRENT WINDOW IS w_vdp02754
       CONSTRUCT BY NAME where_clause ON ped_end_ent.*
       CALL log006_exibe_teclas("01", p_versao)
       CURRENT WINDOW IS w_vdp02754
       IF int_flag
       THEN LET int_flag = 0
            LET p_entrega.* = p_entregar.*
            CALL vdp426_exibe_dados_entrega()
            ERROR " Consulta Cancelada "
            RETURN
       ELSE MESSAGE "Aguarde processamento... "
       END IF
       LET sql_stmt = "SELECT cod_empresa,      num_pedido,  ",
                             "end_entrega,      den_bairro,  ",
                             "cod_cidade,       cod_cep,     ",
                             "num_cgc,          ins_estadual, ",
                             "num_sequencia ",
                             " FROM ped_end_ent WHERE ", where_clause CLIPPED
  ELSE LET sql_stmt = "SELECT cod_empresa,      num_pedido,  ",
                             "end_entrega,      den_bairro,  ",
                             "cod_cidade,       cod_cep,     ",
                             "num_cgc,          ins_estadual, ",
                             "num_sequencia ",
                             " FROM ped_end_ent WHERE ",
                             "      ped_end_ent.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                             "  AND ped_end_ent.num_pedido  = ", p_pedidos1.num_pedido
  END IF
  PREPARE var_query_entrega FROM sql_stmt
  DECLARE cq_entrega SCROLL CURSOR FOR var_query_entrega
  OPEN cq_entrega
  FETCH cq_entrega INTO p_entrega.*
  IF sqlca.sqlcode = NOTFOUND
     THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados ou pedido liquidado", "exclamation")
          LET p_ies_cons_entrega = FALSE
     ELSE MESSAGE ""
          LET p_ies_cons_entrega = TRUE
  END IF
  CALL vdp426_exibe_dados_entrega()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_entrega(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_entrega  THEN
     LET p_entregar.* = p_entrega.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_entrega INTO p_entrega.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_entrega INTO p_entrega.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_entrega.* = p_entregar.*
          EXIT WHILE
       END IF
       SELECT cod_empresa,      num_pedido,
              end_entrega,      den_bairro,
              cod_cidade,       cod_cep,
              num_cgc,          ins_estadual,
              num_sequencia
         INTO p_entrega.* FROM ped_end_ent
         WHERE ped_end_ent.cod_empresa   = p_entrega.cod_empresa
           AND ped_end_ent.num_pedido    = p_entrega.num_pedido
           AND ped_end_ent.num_sequencia = p_entrega.num_sequencia
       IF sqlca.sqlcode = 0 THEN
          CALL vdp426_exibe_dados_entrega()
          EXIT WHILE
       END IF
     END WHILE
  ELSE
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_exibe_dados_entrega()
#---------------------------------------------------------------------#
  DEFINE p_den_cidade        LIKE cidades.den_cidade,
         p_cod_uni_feder     LIKE cidades.cod_uni_feder
  INITIALIZE p_den_cidade, p_cod_uni_feder TO NULL
  SELECT den_cidade, cod_uni_feder
    INTO p_den_cidade, p_cod_uni_feder
    FROM cidades
    WHERE cidades.cod_cidade = p_entrega.cod_cidade

  DISPLAY BY NAME p_entrega.*
  DISPLAY p_den_cidade, p_cod_uni_feder TO den_cidade, cod_uni_feder
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_observacoes()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02755") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02755 AT 6,03 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
     IF p_tip_consulta = 1 THEN
        CALL vdp426_consulta_obs_do_pedido()
        LET p_tip_consul_obs = 1
     ELSE
        CALL vdp426_consulta_obs_do_pedido_hist()
        LET p_tip_consul_obs = 2
     END IF
  END IF

  MENU "OPCAO"
    COMMAND "Consultar"    "Consulta Observacoes do pedido"
      HELP 4
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         LET p_tip_consul_obs = 1
         CALL vdp426_consulta_obs_do_pedido()
         LET p_num_pedido = p_pedidos1.num_pedido
      END IF
    COMMAND "Historico"    "Consulta dados dos pedidos Liquidados/Cancelados"
      HELP 2020
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         INITIALIZE p_num_pedido TO NULL
         LET p_tip_consul_obs = 2
         CALL vdp426_consulta_obs_do_pedido_hist()
         LET p_num_pedido = p_pedidos1.num_pedido
      END IF
    COMMAND "Seguinte"   "Exibe Observacao seguinte"
      HELP 5
      MESSAGE ""
      IF   p_tip_consul_obs = 1
      THEN CALL vdp426_paginacao_observacoes("SEGUINTE")
      ELSE CALL vdp426_paginacao_observacoes_hist("SEGUINTE")
      END IF
    COMMAND "Anterior"   "Exibe Observacao anterior"
      HELP 6
      MESSAGE ""
      IF   p_tip_consul_obs = 1
      THEN CALL vdp426_paginacao_observacoes("ANTERIOR")
      ELSE CALL vdp426_paginacao_observacoes_hist("ANTERIOR")
      END IF
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED ," " ,p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02755
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_obs_do_pedido()
#---------------------------------------------------------------------#
  IF p_num_pedido IS NULL
  THEN LET int_flag = 0
       LET p_observacoesr.* = p_observacoes.*
       INITIALIZE p_observacoes.* TO NULL
       CLEAR FORM
       CALL log006_exibe_teclas("02 07", p_versao)
       CURRENT WINDOW IS w_vdp02755
       CONSTRUCT BY NAME where_clause ON ped_observacao.*
       CALL log006_exibe_teclas("01", p_versao)
       CURRENT WINDOW IS w_vdp02755
       IF int_flag
       THEN LET int_flag = 0
            LET p_observacoes.* = p_observacoesr.*
            CALL vdp426_exibe_dados_observacoes()
            ERROR " Consulta Cancelada "
            RETURN
       ELSE MESSAGE "Aguarde processamento... "
       END IF
       LET sql_stmt = "SELECT * FROM ped_observacao WHERE ", where_clause CLIPPED
  ELSE LET sql_stmt = "SELECT * FROM ped_observacao WHERE ",
                             "       ped_observacao.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                             "   AND ped_observacao.num_pedido  = ", p_pedidos1.num_pedido
  END IF
  PREPARE var_query_observ FROM sql_stmt
  DECLARE cq_observacoes SCROLL CURSOR FOR var_query_observ
  OPEN cq_observacoes
  FETCH cq_observacoes INTO p_observacoes.*
  IF sqlca.sqlcode = NOTFOUND
     THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
          INITIALIZE p_observacoes.*   TO NULL
          LET p_ies_cons_obs = FALSE
     ELSE MESSAGE ""
          LET p_ies_cons_obs = TRUE
  END IF
  CALL vdp426_exibe_dados_observacoes()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_observacoes(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_obs  THEN
     LET p_observacoesr.* = p_observacoes.*
     INITIALIZE p_observacoes.*  TO NULL
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_observacoes INTO p_observacoes.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_observacoes INTO p_observacoes.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_observacoes.* = p_observacoesr.*
          EXIT WHILE
       END IF
       SELECT cod_empresa,      num_pedido,
              tex_observ_1,     tex_observ_2
          INTO p_observacoes.* FROM ped_observacao
         WHERE ped_observacao.cod_empresa   = p_observacoes.cod_empresa
           AND ped_observacao.num_pedido    = p_observacoes.num_pedido
       IF sqlca.sqlcode = 0 THEN
          CALL vdp426_exibe_dados_observacoes()
          EXIT WHILE
       END IF
     END WHILE
  ELSE
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_exibe_dados_observacoes()
#---------------------------------------------------------------------#
  LET p_tex_observ_1 = p_observacoes.tex_observ_1[1, 38]
  LET p_tex_observ_2 = p_observacoes.tex_observ_1[39,75]
  LET p_tex_observ_3 = p_observacoes.tex_observ_2[1, 38]
  LET p_tex_observ_4 = p_observacoes.tex_observ_2[39,75]

  DISPLAY BY NAME p_observacoes.cod_empresa,
                  p_observacoes.num_pedido

  DISPLAY p_tex_observ_1  TO tex_observ_1
  DISPLAY p_tex_observ_2  TO tex_observ_2
  DISPLAY p_tex_observ_3  TO tex_observ_3
  DISPLAY p_tex_observ_4  TO tex_observ_4

END FUNCTION

#----------------------------------------------------#
 FUNCTION vdp426_verifica_cod_cliente()
#----------------------------------------------------#
  SELECT nom_cliente,
         den_cidade,
         cod_uni_feder
    INTO p_pedidos1.nom_cliente,
         p_pedidos1.den_cidade,
         p_pedidos1.cod_uni_feder
    FROM  clientes, OUTER cidades
    WHERE clientes.cod_cliente = p_pedidos1.cod_cliente
      AND clientes.cod_cidade  = cidades.cod_cidade
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_transport()
#---------------------------------------------------------------------#
  SELECT den_transpor
    INTO p_pedidos1.den_transpor
    FROM transport
    WHERE transport.cod_transpor  = p_pedidos1.cod_transpor
  IF   sqlca.sqlcode = 0
  THEN RETURN
  ELSE SELECT nom_cliente
         INTO p_pedidos1.den_transpor
         FROM clientes
        WHERE clientes.cod_cliente  = p_pedidos1.cod_transpor
       IF sqlca.sqlcode = 0
       THEN RETURN
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_consig()
#---------------------------------------------------------------------#
  SELECT den_transpor
    INTO p_pedidos1.den_consig
    FROM transport
    WHERE transport.cod_transpor  = p_pedidos1.cod_consig
  IF   sqlca.sqlcode = 0
  THEN RETURN
  ELSE SELECT nom_cliente
         INTO p_pedidos1.den_consig
         FROM clientes
        WHERE clientes.cod_cliente  = p_pedidos1.cod_consig
       IF sqlca.sqlcode = 0
       THEN RETURN
       END IF
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_repres()
#---------------------------------------------------------------------#
  DEFINE l_raz_social LIKE representante.raz_social

  SELECT raz_social
    INTO p_pedidos1.raz_social
    FROM representante
    WHERE representante.cod_repres = p_pedidos1.cod_repres
  SELECT raz_social
    INTO p_pedidos1.raz_social_adic
    FROM representante
    WHERE representante.cod_repres = p_pedidos1.cod_repres_adic
  SELECT raz_social
    INTO l_raz_social
    FROM representante
   WHERE representante.cod_repres  = p_pedido_comis.cod_repres_3

  DISPLAY l_raz_social TO raz_social_3
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_cnd_pgto()
#---------------------------------------------------------------------#
  SELECT den_cnd_pgto
    INTO p_pedidos1.den_cnd_pgto
    FROM cond_pgto
    WHERE cond_pgto.cod_cnd_pgto = p_pedidos1.cod_cnd_pgto
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_nat_oper()
#---------------------------------------------------------------------#
  SELECT den_nat_oper
    INTO p_pedidos1.den_nat_oper
    FROM nat_operacao
    WHERE nat_operacao.cod_nat_oper = p_pedidos1.cod_nat_oper
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_tip_venda()
#---------------------------------------------------------------------#
  SELECT den_tip_venda
    INTO p_pedidos1.den_tip_venda
    FROM tipo_venda
    WHERE tipo_venda.cod_tip_venda = p_pedidos1.cod_tip_venda
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_tip_carteira()
#---------------------------------------------------------------------#
  INITIALIZE p_pedidos1.den_tip_carteira TO NULL

  SELECT den_tip_carteira
    INTO p_pedidos1.den_tip_carteira
    FROM tipo_carteira
   WHERE tipo_carteira.cod_tip_carteira = p_pedidos1.cod_tip_carteira
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_forma_pagto()
#---------------------------------------------------------------------#
  INITIALIZE p_pedidos1.des_forma_pagto TO NULL

  IF p_pedidos1.forma_pagto = 'BO' THEN
     LET p_pedidos1.des_forma_pagto = 'BOLETO  '
  ELSE
     IF p_pedidos1.forma_pagto = 'CH' THEN
        LET p_pedidos1.des_forma_pagto = 'CHEQUE  '
     ELSE
        IF p_pedidos1.forma_pagto = 'DN' THEN
           LET p_pedidos1.des_forma_pagto = 'DINHEIRO'
        ELSE
           LET p_pedidos1.des_forma_pagto = '        '
        END IF
     END IF
  END IF

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_verifica_cod_moeda()
#---------------------------------------------------------------------#
  SELECT den_moeda
    INTO p_pedidos2.den_moeda
    FROM moeda
   WHERE moeda.cod_moeda = p_pedidos2.cod_moeda
END FUNCTION

###############
# HISTORICO
###############

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_pedidos1_hist()
#---------------------------------------------------------------------#
  LET p_pedidos1r.* = p_pedidos1.*
  INITIALIZE p_pedidos1.* TO NULL
  LET int_flag = 0
  CALL log006_exibe_teclas("02 03 07", p_versao)
  IF   num_args() = 0
  THEN CURRENT WINDOW IS w_vdp02751
       CLEAR FORM
       CONSTRUCT BY NAME where_clause ON pedidos_hist.cod_empresa,
                                         pedidos_hist.num_pedido,
                                         pedidos_hist.ies_sit_pedido,
                                         pedidos_hist.dat_pedido,
                                         pedidos_hist.cod_cliente,
                                         pedidos_hist.ies_comissao,
                                         pedidos_hist.cod_repres,
                                         pedidos_hist.pct_comissao,
                                         pedidos_hist.cod_repres_adic,
                                         pedidos_hist.num_pedido_repres,
                                         pedidos_hist.dat_emis_repres,
                                         pedidos_hist.num_pedido_cli,
                                         pedidos_hist.cod_nat_oper,
                                         pedidos_hist.cod_transpor,
                                         pedidos_hist.cod_consig,
                                         pedidos_hist.cod_cnd_pgto,
                                         pedidos_hist.cod_tip_venda,
                                         pedidos_hist.cod_tip_carteira


           BEFORE FIELD cod_empresa
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           BEFORE FIELD cod_cliente
                  DISPLAY "( Zoom )" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           AFTER  FIELD cod_cliente
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           BEFORE FIELD ies_sit_pedido
                  DISPLAY "( Zoom )" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', 'Zoom')
           AFTER  FIELD ies_sit_pedido
                  DISPLAY "--------" AT 3,60
--#               CALL fgl_dialog_setkeylabel('control-z', NULL)

           ON KEY (control-z, f4)
             CALL vdp0275_popup()

       END CONSTRUCT
  END IF
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  IF   int_flag
  THEN LET int_flag = 0
       LET p_pedidos1.* = p_pedidos1r.*
       CALL vdp426_exibe_dados_pedidos1()
       ERROR " Consulta Cancelada "
       RETURN
  ELSE MESSAGE "Aguarde processamento..."
  END IF

  IF   num_args() > 0
  THEN LET p_char=arg_val(1)
       LET p_pedidos1.cod_empresa = p_char[1,2]
       LET p_pedidos1.num_pedido  = p_char[3,8] USING "######"
       LET sql_stmt = "SELECT cod_empresa,     num_pedido,        ",
                             "dat_pedido,   cod_cliente, ies_sit_pedido, ",
                             "cod_repres,      cod_repres_adic,   ",
                             "ies_comissao,pct_comissao, num_pedido_repres, ",
                             "dat_emis_repres, num_pedido_cli,    ",
                             "cod_nat_oper,    cod_transpor,      ",
                             "cod_consig,      cod_cnd_pgto,      ",
                             "cod_tip_venda,   cod_tip_carteira   ",
                             " FROM pedidos_hist WHERE ",
                             " pedidos_hist.cod_empresa = """, p_pedidos1.cod_empresa,
                             """ AND pedidos_hist.num_pedido  = ", p_pedidos1.num_pedido
  ELSE LET sql_stmt = "SELECT cod_empresa,     num_pedido,        ",
                             "dat_pedido,  cod_cliente, ies_sit_pedido , ",
                             "cod_repres,      cod_repres_adic,   ",
                             "ies_comissao,pct_comissao, num_pedido_repres, ",
                             "dat_emis_repres, num_pedido_cli,    ",
                             "cod_nat_oper,    cod_transpor,      ",
                             "cod_consig,      cod_cnd_pgto,      ",
                             "cod_tip_venda,   cod_tip_carteira   ",
                             " FROM pedidos_hist WHERE ", where_clause CLIPPED
  END IF

  CALL vdp426_declare_cursor()

  OPEN cq_pedidos1
  FETCH cq_pedidos1 INTO p_pedidos1.*
  LET p_status = sqlca.sqlcode
  MESSAGE ""
  IF   p_status = NOTFOUND
  THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
       LET p_ies_cons_pedidos1 = FALSE
  ELSE LET p_ies_cons_pedidos1 = TRUE
       SELECT UNIQUE forma_pagto
         INTO p_pedidos1.forma_pagto
         FROM ped_compl_pedido
        WHERE empresa = p_pedidos1.cod_empresa
          AND pedido  = p_pedidos1.num_pedido

       INITIALIZE p_pedidos1.cod_tip_carteira,
                  p_pedidos1.den_tip_carteira TO NULL
       CALL vdp426_exibe_dados_pedidos1()
       RETURN
  END IF

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_pedidos1_hist(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_pedidos1  THEN
     LET p_pedidos1r.* = p_pedidos1.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_pedidos1 INTO p_pedidos1.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_pedidos1 INTO p_pedidos1.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_pedidos1.* = p_pedidos1r.*
          EXIT WHILE
       END IF

       WHENEVER ERROR CONTINUE
         SELECT cod_empresa, num_pedido,
                dat_pedido, cod_cliente,ies_sit_pedido,
                cod_repres, cod_repres_adic,
                ies_comissao, ' ', pct_comissao,
                num_pedido_repres, dat_emis_repres,
                num_pedido_cli, cod_nat_oper,
                cod_transpor, cod_consig,
                cod_cnd_pgto, cod_tip_venda
           INTO p_pedidos1.*
           FROM pedidos_hist
          WHERE pedidos_hist.cod_empresa   = p_pedidos1.cod_empresa
            AND pedidos_hist.num_pedido    = p_pedidos1.num_pedido
            AND pedidos_hist.cod_cliente   = p_pedidos1.cod_cliente
       WHENEVER ERROR STOP

       IF  sqlca.sqlcode = 0 THEN

           WHENEVER ERROR CONTINUE
             SELECT parametro_texto
               INTO p_pedidos1.parametro_texto
               FROM ped_info_compl
              WHERE ped_info_compl.empresa = p_pedidos1.cod_empresa
                AND ped_info_compl.pedido  = p_pedidos1.num_pedido
                AND ped_info_compl.campo   = 'linha_produto'
           WHENEVER ERROR STOP
           IF  SQLCA.sqlcode <> 0 THEN
           END IF

           CALL vdp426_exibe_dados_pedidos1()
           EXIT WHILE
       END IF
       END WHILE
  ELSE ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_controle_pedidos2_hist()
#---------------------------------------------------------------------#
  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp02751
  CALL log130_procura_caminho("VDP02752") RETURNING p_nom_tela
  OPEN WINDOW w_vdp02752 AT 2,02 WITH FORM p_nom_tela
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  IF   p_num_pedido IS NULL
  THEN ERROR " Primeira pagina dos PEDIDOS MESTRE nao foi consultada !"
  ELSE CALL vdp426_consulta_pedidos2_hist()
  END IF

  MENU "OPCAO"
    COMMAND KEY ("L") "cLientes"  "Consulta dados de Clientes"
      HELP 2021
      MESSAGE ""
      IF log005_seguranca(p_user,"VDP","VDP0275","CO")  THEN
         CALL log120_procura_caminho("VDP3850") RETURNING p_comando
         LET p_comando = p_comando CLIPPED," ",p_pedidos1.cod_cliente
         RUN p_comando
      END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR p_comando
      RUN p_comando
      PROMPT "\nTecle ENTER para continuar" FOR p_comando
    COMMAND "Fim"        "Retorna ao Menu Anterior"
      HELP 8
      EXIT MENU


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU
  CLOSE WINDOW w_vdp02752
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_pedidos2_hist()
#---------------------------------------------------------------------#
  LET p_pedidos2r.* = p_pedidos2.*
  INITIALIZE p_pedidos2.* TO NULL
  CLEAR FORM

  SELECT cod_empresa,
         pct_desc_adic,
         pct_desc_financ,
#         ies_sit_pedido,
         ies_finalidade,
         ies_frete,
         pct_frete,
         ies_preco,
         ies_tip_entrega,
         ies_aceite,
         num_list_preco,
         dat_alt_sit,
         dat_ult_fatur,
         ies_embal_padrao,
         num_versao_lista,
         cod_moeda
    INTO p_pedidos2.*
    FROM pedidos_hist
    WHERE pedidos_hist.num_pedido  = p_pedidos1.num_pedido
      AND pedidos_hist.cod_empresa = p_pedidos1.cod_empresa
 IF   sqlca.sqlcode = 0
 THEN LET p_ies_cons_pedidos1 = TRUE
 ELSE LET p_ies_cons_pedidos1 = FALSE
 END IF
 SELECT den_list_preco
   INTO p_den_list_preco
   FROM desc_preco_mest
   WHERE desc_preco_mest.num_list_preco = p_pedidos2.num_list_preco
     AND desc_preco_mest.cod_empresa    = p_cod_empresa

  LET p_pedidos2.den_moeda = " "
  IF   p_pedidos2.cod_moeda IS NOT NULL
  THEN CALL vdp426_verifica_cod_moeda()
  END IF

 DISPLAY BY NAME p_pedidos2.*
 DISPLAY p_den_list_preco TO den_list_preco
 CASE p_pedidos2.ies_embal_padrao
   WHEN "1" DISPLAY "Embal. Interna"  TO txt_padr_embal
   WHEN "2" DISPLAY "Embal. Externa"  TO txt_padr_embal
   WHEN "3" DISPLAY "Sem Padrao"      TO txt_padr_embal
   WHEN "4" DISPLAY "Cx. Embal. Int." TO txt_padr_embal
   WHEN "5" DISPLAY "Cx. Embal. Ext." TO txt_padr_embal
   WHEN "6" DISPLAY "Pallet"          TO txt_padr_embal
 END CASE
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_entrega_do_pedido_hist()
#---------------------------------------------------------------------#
  IF p_num_pedido IS NULL
  THEN LET int_flag = 0
       LET p_entregar.* = p_entrega.*
       INITIALIZE p_entrega.* TO NULL
       CLEAR FORM
       CALL log006_exibe_teclas("02 07", p_versao)
       CURRENT WINDOW IS w_vdp02754
       CONSTRUCT BY NAME where_clause ON ped_end_ent_hist.*
       CALL log006_exibe_teclas("01", p_versao)
       CURRENT WINDOW IS w_vdp02754
       IF int_flag
       THEN LET int_flag = 0
            LET p_entrega.* = p_entregar.*
            CALL vdp426_exibe_dados_entrega()
            ERROR " Consulta Cancelada "
            RETURN
       ELSE MESSAGE "Aguarde processamento... "
       END IF
       LET sql_stmt = "SELECT cod_empresa,      num_pedido,  ",
                             "end_entrega,      den_bairro,  ",
                             "cod_cidade,       cod_cep,     ",
                             "num_cgc,          ins_estadual, ",
                             "num_sequencia ",
                             " FROM ped_end_ent_hist WHERE ", where_clause CLIPPED
  ELSE LET sql_stmt = "SELECT cod_empresa,      num_pedido,  ",
                             "end_entrega,      den_bairro,  ",
                             "cod_cidade,       cod_cep,     ",
                             "num_cgc,          ins_estadual ",
                             "num_sequencia ",
                             " FROM ped_end_ent_hist WHERE ",
                             "      ped_end_ent_hist.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                             "  AND ped_end_ent_hist.num_pedido  = ", p_pedidos1.num_pedido
  END IF
  PREPARE var_query_entrega1 FROM sql_stmt
  DECLARE cq_entrega1 SCROLL CURSOR FOR var_query_entrega1
  OPEN cq_entrega1
  FETCH cq_entrega1 INTO p_entrega.*
  IF sqlca.sqlcode = NOTFOUND
     THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
          LET p_ies_cons_entrega = FALSE
     ELSE MESSAGE ""
          LET p_ies_cons_entrega = TRUE
  END IF
  CALL vdp426_exibe_dados_entrega()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_entrega_hist(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_entrega  THEN
     LET p_entregar.* = p_entrega.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_entrega1 INTO p_entrega.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_entrega1 INTO p_entrega.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_entrega.* = p_entregar.*
          EXIT WHILE
       END IF
       SELECT cod_empresa,      num_pedido,
              end_entrega,      den_bairro,
              cod_cidade,       cod_cep,
              num_cgc,          ins_estadual,
              num_sequencia
         INTO p_entrega.* FROM ped_end_ent_hist
         WHERE ped_end_ent_hist.cod_empresa   = p_entrega.cod_empresa
           AND ped_end_ent_hist.num_pedido    = p_entrega.num_pedido
           AND ped_end_ent_hist.num_sequencia = p_entrega.num_sequencia
       IF sqlca.sqlcode = 0 THEN
          CALL vdp426_exibe_dados_entrega()
          EXIT WHILE
       END IF
     END WHILE
  ELSE
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_consulta_obs_do_pedido_hist()
#---------------------------------------------------------------------#
  IF p_num_pedido IS NULL
  THEN LET int_flag = 0
       LET p_observacoesr.* = p_observacoes.*
       INITIALIZE p_observacoes.* TO NULL
       CLEAR FORM
       CALL log006_exibe_teclas("02 07", p_versao)
       CURRENT WINDOW IS w_vdp02755
       CONSTRUCT BY NAME where_clause ON ped_observ_hist.*
       CALL log006_exibe_teclas("01", p_versao)
       CURRENT WINDOW IS w_vdp02755
       IF int_flag
       THEN LET int_flag = 0
            LET p_observacoes.* = p_observacoesr.*
            CALL vdp426_exibe_dados_observacoes()
            ERROR " Consulta Cancelada "
            RETURN
       ELSE MESSAGE "Aguarde processamento..."
       END IF
       LET sql_stmt = "SELECT * FROM ped_observ_hist WHERE ", where_clause CLIPPED
  ELSE LET sql_stmt = "SELECT * FROM ped_observ_hist WHERE ",
                             "       ped_observ_hist.cod_empresa = \"", p_pedidos1.cod_empresa ,"\"",
                             "   AND ped_observ_hist.num_pedido  = ", p_pedidos1.num_pedido
  END IF
  PREPARE var_query_observ1 FROM sql_stmt
  DECLARE cq_observacoes1 SCROLL CURSOR FOR var_query_observ1
  OPEN cq_observacoes1
  FETCH cq_observacoes1 INTO p_observacoes.*
  IF sqlca.sqlcode = NOTFOUND
     THEN CALL log0030_mensagem("Argumentos de pesquisa nao encontrados", "exclamation")
          LET p_ies_cons_obs = FALSE
     ELSE MESSAGE ""
          LET p_ies_cons_obs = TRUE
  END IF
  CALL vdp426_exibe_dados_observacoes()
END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp426_paginacao_observacoes_hist(p_funcao)
#---------------------------------------------------------------------#
  DEFINE p_funcao            CHAR(20)
  IF p_ies_cons_obs  THEN
     LET p_observacoesr.* = p_observacoes.*
     WHILE TRUE
       CASE
         WHEN p_funcao = "SEGUINTE" FETCH NEXT     cq_observacoes1 INTO p_observacoes.*
         WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_observacoes1 INTO p_observacoes.*
       END CASE
       IF sqlca.sqlcode = NOTFOUND  THEN
          ERROR " Nao existem mais itens nesta direcao "
          LET p_observacoes.* = p_observacoesr.*
          EXIT WHILE
       END IF
       SELECT cod_empresa,      num_pedido,
              tex_observ_1,     tex_observ_2
          INTO p_observacoes.* FROM ped_observ_hist
         WHERE ped_observ_hist.cod_empresa   = p_observacoes.cod_empresa
           AND ped_observ_hist.num_pedido    = p_observacoes.num_pedido
       IF sqlca.sqlcode = 0 THEN
          CALL vdp426_exibe_dados_observacoes()
          EXIT WHILE
       END IF
     END WHILE
  ELSE
     ERROR " Nao existe nenhuma consulta ativa "
  END IF
END FUNCTION

#-----------------------------------#
 FUNCTION vdp0275_busca_parametros()
#-----------------------------------#
 SELECT par_ies
   INTO m_ies_item_adic
   FROM par_vdp_pad
  WHERE cod_empresa   = p_empresa #p_cod_empresa
    AND cod_parametro = 'ies_item_adic_ped'

 IF sqlca.sqlcode <> 0 THEN
    LET m_ies_item_adic = ' '
 END IF

 SELECT par_txt
   INTO m_prog_item_adic
   FROM par_vdp_pad
  WHERE cod_empresa   = p_empresa #p_cod_empresa
    AND cod_parametro = 'cod_prog_item_adic'

 IF sqlca.sqlcode <> 0 THEN
    LET m_prog_item_adic = NULL
 END IF

END FUNCTION

#--------------------------------------#
 FUNCTION vdp0275_verifica_texto_item()
#--------------------------------------#
 DEFINE l_count   SMALLINT

 LET l_count = 0

 SELECT COUNT(*)
   INTO l_count
   FROM ped_itens_texto
  WHERE cod_empresa   = p_ped_itens1.cod_empresa
    AND num_pedido    = p_ped_itens1.num_pedido
    AND num_sequencia = p_ped_itens1.num_sequencia
    AND den_texto_1 IS NOT NULL

 IF l_count IS NULL THEN
    LET l_count = 0
 END IF

 IF l_count > 0 THEN
    RETURN 'S'
 ELSE
    RETURN 'N'
 END IF

END FUNCTION

#---------------------------------------------------#
 FUNCTION vdp0275_consulta_texto_exped(l_num_pedido)
#---------------------------------------------------#
   DEFINE l_num_pedido         LIKE pedidos.num_pedido,
          l_nom_tela           CHAR(080)

   DEFINE lr_ped_info_compl    RECORD
                                   texto_1   CHAR(076),
                                   texto_2   CHAR(076),
                                   texto_3   CHAR(076),
                                   texto_4   CHAR(076)
                               END RECORD

   LET m_versao_funcao = 'VDPY154-05.10.02e'

   CALL log006_exibe_teclas("01 02 07", m_versao_funcao)
   CALL log130_procura_caminho("VDPY154") RETURNING l_nom_tela

   OPEN WINDOW w_vdpy154 AT 2,2 WITH FORM l_nom_tela
        ATTRIBUTE(BORDER, PROMPT LINE LAST, MESSAGE LINE LAST, FORM LINE 1)

   LET INT_FLAG = FALSE
   INITIALIZE lr_ped_info_compl.* TO NULL

   CALL vdp0275_carrega_txt_exped(l_num_pedido, 'ped_inf_cpl')
      RETURNING lr_ped_info_compl.*

   DISPLAY BY NAME lr_ped_info_compl.texto_1,
                   lr_ped_info_compl.texto_2,
                   lr_ped_info_compl.texto_3,
                   lr_ped_info_compl.texto_4

   PROMPT "Tecle ENTER para sair... " FOR p_comando
   CLOSE WINDOW w_vdpy154

 END FUNCTION

#--------------------------------------------#
 FUNCTION vdp0275_carrega_txt_exped(l_pedido,
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
                    " WHERE empresa = '", p_cod_empresa CLIPPED, "'",
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
                   CALL vdp0275_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_1
              WHEN '2'
                   CALL vdp0275_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_2
              WHEN '3'
                   CALL vdp0275_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_3
              WHEN '4'
                   CALL vdp0275_carrega_variavel_texto(l_texto) RETURNING lr_txt_exped.texto_4
         END CASE

     END FOREACH

     RETURN lr_txt_exped.*

 END FUNCTION

#------------------------------------------------#
 FUNCTION vdp0275_carrega_variavel_texto(l_texto)
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
