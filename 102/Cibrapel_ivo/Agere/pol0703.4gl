#---------------------------------------------------------------------------#  
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: POL0703                                                         #
# MODULOS.: POL0703  - LOG0010 - LOG0040 - LOG0050 - LOG0060                #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                          #
# OBJETIVO: IMPRESSAO DAS NOTAS FISCAIS FATURA - SAIDA - CIBRAPEL           # 
# AUTOR...: POLO INFORMATICA                                                #
# DATA....: 21/12/2007                                                      #
#---------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_cod_item_cliente       LIKE cliente_item.cod_item_cliente,
          p_ies_situacao           LIKE nf_mestre.ies_situacao,
          p_cod_texto              LIKE fiscal_hist.cod_hist,
          p_num_seq_fr             LIKE frete_solicit_885.num_sequencia,
          p_uf_cli                 LIKE cidades.cod_uni_feder,
          p_lot_ped                LIKE estoque_trans.num_lote_orig,
          p_nota_imp               SMALLINT,
          p_tip_trim               CHAR(01),
          p_cod_emp_ger            CHAR(02),
          p_num_nf_ch              LIKE estoque_trans.num_docum,
          p_val_mo                 DECIMAL(15,2), 
          p_salto                  SMALLINT,
          p_campo_pis              CHAR(30),
          p_campo_cofins           CHAR(30),
          p_des_especie            CHAR(20), 
          p_qtd_volumes            CHAR(30),
          p_qtdvolumes             INTEGER,
          p_cont_nf_rt             SMALLINT,
          p_nf_ant                 DECIMAL(7,0),
          p_num_seq                SMALLINT,
          p_repres                 CHAR(15),
          p_qtd_vol_aux            CHAR(5),
          p_tip_info               SMALLINT,
          p_cod_clas_fisc          CHAR(10),
          p_cod_ref_clas           CHAR(01),
          p_num_item               CHAR(01),
          p_ies_cons               SMALLINT,
          p_status                 SMALLINT,
          p_linha                  SMALLINT,
          p_cont_ind               SMALLINT,
          p_num_romaneio           INTEGER,
          p_nom_arquivo            CHAR(100),
          p_posi                   SMALLINT,
          p_qtd_carac              SMALLINT,
          p_caminho                CHAR(80),
          p_desc_suframa           DECIMAL(5,3),
          p_ies_impressao          CHAR(01),
          p_ies_lote               CHAR(01),
          l_cla_fisc_nff           CHAR(02),
          p_reimpressao            CHAR(01),
          p_num_nff_ini            LIKE nf_mestre.num_nff,       
          p_num_nff_fim            LIKE nf_mestre.num_nff,       
          p_num_lote               CHAR(37),                        
          p_num_lot                CHAR(15),                        
          p_num_reserva            LIKE ordem_montag_grade.num_reserva,
          comando                  CHAR(80),
          p_cod_fiscal             LIKE nf_mestre.cod_fiscal,    
          cod_cla_h                LIKE wfat_item.cod_cla_fisc,
          cod_cla_i                LIKE wfat_item.cod_cla_fisc,
          cod_cla_j                LIKE wfat_item.cod_cla_fisc,
          p_qtd_tot_recebida       LIKE item_de_terc.qtd_tot_recebida,
          p_num_nf_retorno         LIKE item_dev_terc.num_nf_retorno,
          p_qtd_devolvida          LIKE item_dev_terc.qtd_devolvida,
          p_dat_emis_nf            LIKE item_dev_terc.dat_emis_nf,
          p_qtd_devolve            LIKE item_dev_terc.qtd_devolvida,
          p_numsequencia           LIKE romaneio_885.numsequencia,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_ies_especie_nf         LIKE nf_sup.ies_especie_nf,
          p_cod_fornecedor         LIKE nf_sup.cod_fornecedor,
          #p_dat_emis_nf            LIKE nf_sup.dat_emis_nf,       
          p_val_tot_nf_d           LIKE nf_sup.val_tot_nf_d,      
          p_cod_nat_oper           LIKE nat_operacao.cod_nat_oper,
          p_cod_nat_oper_ref       LIKE nat_operacao.cod_nat_oper,
          p_den_item_reduz         LIKE item.den_item_reduz, 
          p_den_item               CHAR(80),
          p_qtd_item               LIKE nf_item.qtd_item,
          p_pre_unit_nf            LIKE nf_item.pre_unit_nf,
          p_pre_tot_nf             LIKE nf_mestre.val_tot_nff,
          p_unid_med               LIKE item.cod_unid_med, 
          p_den_motivo_remessa     LIKE motivo_remessa.den_motivo_remessa,
          p_cod_fiscal_compl       DECIMAL(1,0),
          p_onu                    INTEGER,
          p_risco_abnt             INTEGER,
          p_nom_tecnico_item       CHAR(80),
          p_cod_origem             LIKE wfat_mestre.cod_origem,
          p_cod_tributacao         LIKE wfat_mestre.cod_tributacao,
          p_val_liq_item           LIKE wfat_item.val_liq_item,
          p_nat_oper               LIKE wfat_mestre.cod_nat_oper,
          p_cod_grupo_item         LIKE grupo_item.cod_grupo_item,
          p_situacao               CHAR(120),
          p_pct_icm                DECIMAL(5,2),    
          p_valor_icms             DECIMAL(15,2),
          p_cod_fornec_cliente     CHAR(15),
          n_i                      SMALLINT,
          p_unid_terc              CHAR(03),
          m_data                   DATE,
          data_nf                  DATE,
          p_indice                 DECIMAL(2,0),
          p_cod_cla_fisc           CHAR(10),
          p_pre_impresso           CHAR(01),
          p_cod_item               CHAR(15),
          p_val_remessa            DECIMAL(17,2),  
          p_qtd_remessa            DECIMAL(15,3),
          p_val_unit               DECIMAL(17,2),
          p_val_mat_dev            DECIMAL(17,2),
          p_letra_corresp          CHAR(01),
          p_cont                   SMALLINT,
          p_cod_cla_reduz          CHAR(02),
          p_comprimento            INTEGER,
          p_largura                DECIMAL(5),
          p_num_pedido             DECIMAL(6,0),
          p_num_om                 DECIMAL(6,0),
          #p_cod_clas_fisc          CHAR(10),
          #p_num_item               CHAR(01),
          p_tip_transp_auto        CHAR(02),
          p_val_icms_auton         DECIMAL(12,2),
          p_valor_base_frt         DECIMAL(12,2),
          p_ies_tipo_pgto          LIKE cond_pgto.ies_tipo,
          #p_num_seq                SMALLINT,
          p_num_solicit            LIKE frete_roma_885.num_solicit,
          p_num_solic_trim         LIKE frete_roma_885.num_solicit,
          p_cod_emp                CHAR(02) 
          
                    
   DEFINE p_wfat_mestre            RECORD LIKE wfat_mestre.*,
          p_wfat_item              RECORD LIKE wfat_item.*,
          p_nf_item_fiscal         RECORD LIKE nf_item_fiscal.*,
          p_wfat_historico         RECORD LIKE wfat_historico.*,
          p_fiscal_hist            RECORD LIKE fiscal_hist.*,
          p_cidades                RECORD LIKE cidades.*,
          p_nf_carga               RECORD LIKE nf_carga.*,
          p_empresa                RECORD LIKE empresa.*,
          p_embalagem              RECORD LIKE embalagem.*,
          p_clientes               RECORD LIKE clientes.*,
          p_paises                 RECORD LIKE paises.*,
          p_uni_feder              RECORD LIKE uni_feder.*,
          p_transport              RECORD LIKE clientes.*,
          p_ped_itens_texto        RECORD LIKE ped_itens_texto.*,
          p_fator_cv_unid          RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf          RECORD LIKE subst_trib_uf.*,
          p_nat_operacao           RECORD LIKE nat_operacao.*,
          p_cli_end_cobr           RECORD LIKE cli_end_cob.*,
          p_pedidos                RECORD LIKE pedidos.*,
          p_tipo_venda             RECORD LIKE tipo_venda.*,
          p_par_vdp_pad            RECORD LIKE par_vdp_pad.*,
          p_empresas_885           RECORD LIKE empresas_885.*, 
          p_obf_par_fret_auton     RECORD LIKE obf_par_fret_auton.*, 
          p_nf_referencia          RECORD LIKE nf_referencia.*,
          p_tipo_pedido_885        RECORD LIKE tipo_pedido_885.*

   {variaveis utilizadas para separar textos longos. Na NF da Squadroni}
   {é possivel imprimir até 75 caracteres por linha de texto}
  
   DEFINE p_texto1                 CHAR(55), 
          p_texto2                 CHAR(55),
          p_texto3                 CHAR(55)
          
   DEFINE p_texto_1                CHAR(75),
          p_texto_2                CHAR(75),
          p_texto_3                CHAR(75),
          p_texto_4                CHAR(75)
          
   DEFINE p_txt     ARRAY[24] OF RECORD 
          texto     CHAR(55)
   END RECORD

   DEFINE tab_larg   ARRAY[40] OF RECORD
          largura          DECIMAL(5),
          comprimento      INTEGER,
          qtd_larg         LIKE estoque_trans.qtd_movto
   END RECORD       


   DEFINE p_clas_fisc_temp         RECORD
          cod_cla_fisc             CHAR(010),
          num_item                 DECIMAL(1,0)
                                  END RECORD 	
                                  	
   #--------------------------------------------------------#
   
   DEFINE p_nff                  RECORD
             num_nff             LIKE wfat_mestre.num_nff,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             cod_fiscal          LIKE wfat_mestre.cod_fiscal,
             cod_fiscal1         LIKE wfat_mestre.cod_fiscal,
             den_nat_oper1       LIKE nat_operacao.den_nat_oper, 
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         LIKE wfat_mestre.dat_emissao,
             nom_destinatario    LIKE clientes.nom_cliente,
             num_cgc_cpf         LIKE clientes.num_cgc_cpf,
             dat_saida           LIKE wfat_mestre.dat_emissao,
             end_destinatario    LIKE clientes.end_cliente,
             den_bairro          LIKE clientes.den_bairro,
             cod_cep             LIKE clientes.cod_cep,
             den_cidade          LIKE cidades.den_cidade,
             num_telefone        LIKE clientes.num_telefone,
             num_telex           LIKE clientes.num_telefone,
             cod_uni_feder       LIKE cidades.cod_uni_feder,
             ins_estadual        LIKE clientes.ins_estadual,
             hora_saida          DATETIME HOUR TO MINUTE,
             cod_cliente         LIKE clientes.cod_cliente,
             den_pais            LIKE paises.den_pais,    
             frt_auton           CHAR (01), 

             num_duplic1         LIKE wfat_duplic.num_duplicata,
             dig_duplic1         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd1      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic1         LIKE wfat_duplic.val_duplic,

             num_duplic2         LIKE wfat_duplic.num_duplicata,
             dig_duplic2         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd2      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic2         LIKE wfat_duplic.val_duplic,

             num_duplic3         LIKE wfat_duplic.num_duplicata,
             dig_duplic3         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd3      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic3         LIKE wfat_duplic.val_duplic,

             num_duplic4         LIKE wfat_duplic.num_duplicata,
             dig_duplic4         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd4      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic4         LIKE wfat_duplic.val_duplic,

             num_duplic5         LIKE wfat_duplic.num_duplicata,
             dig_duplic5         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd5      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic5         LIKE wfat_duplic.val_duplic,

             num_duplic6         LIKE wfat_duplic.num_duplicata,
             dig_duplic6         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd6      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic6         LIKE wfat_duplic.val_duplic,

             num_duplic7          LIKE  wfat_duplic.num_duplicata,
             dig_duplic7          LIKE  wfat_duplic.dig_duplicata,
             dat_vencto_sd7       LIKE  wfat_duplic.dat_vencto_sd,
             val_duplic7          LIKE  wfat_duplic.val_duplic,

             num_duplic8         LIKE wfat_duplic.num_duplicata,
             dig_duplic8         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd8      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic8         LIKE wfat_duplic.val_duplic,

             num_duplic9         LIKE wfat_duplic.num_duplicata,
             dig_duplic9         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd9      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic9         LIKE wfat_duplic.val_duplic,

             num_duplic10        LIKE wfat_duplic.num_duplicata,
             dig_duplic10        LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd10     LIKE wfat_duplic.dat_vencto_sd,
             val_duplic10        LIKE wfat_duplic.val_duplic,

             num_duplic11        LIKE wfat_duplic.num_duplicata,
             dig_duplic11        LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd11     LIKE wfat_duplic.dat_vencto_sd,
             val_duplic11        LIKE wfat_duplic.val_duplic,

             num_duplic12        LIKE wfat_duplic.num_duplicata,
             dig_duplic12        LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd12     LIKE wfat_duplic.dat_vencto_sd,
             val_duplic12        LIKE wfat_duplic.val_duplic,

             val_extenso1        CHAR(130),
             val_extenso2        CHAR(130),
             val_extenso3        CHAR(001), 
             val_extenso4        CHAR(001),

             end_cobr_cli        LIKE cli_end_cob.end_cobr,
             den_cidade_cli      LIKE cidades.den_cidade,
             cod_uni_feder_cli   LIKE cidades.cod_uni_feder,
             cod_cep_cli         LIKE cli_end_cob.cod_cep,

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_base_icm    LIKE wfat_mestre.val_tot_base_icm,
             val_tot_icm         LIKE wfat_mestre.val_tot_icm,
             val_tot_base_ret    LIKE wfat_mestre.val_tot_base_ret,
             val_tot_icm_ret     LIKE wfat_mestre.val_tot_icm_ret,
             val_tot_mercadoria  LIKE wfat_mestre.val_tot_mercadoria,
             val_frete_cli       LIKE wfat_mestre.val_frete_cli,
             val_seguro_cli      LIKE wfat_mestre.val_seguro_cli,
             val_tot_despesas    LIKE wfat_mestre.val_seguro_cli, 
             val_tot_ipi         LIKE wfat_mestre.val_tot_ipi,
             val_tot_nff         LIKE wfat_mestre.val_tot_nff,

             nom_transpor        LIKE clientes.nom_cliente,
             ies_frete           LIKE wfat_mestre.ies_frete,
             num_placa           LIKE wfat_mestre.num_placa,
             cod_uni_feder_trans LIKE cidades.cod_uni_feder,
             num_cgc_trans       LIKE clientes.num_cgc_cpf,
             end_transpor        LIKE clientes.end_cliente,
             den_cidade_trans    LIKE cidades.den_cidade,
             ins_estadual_trans  LIKE clientes.ins_estadual,
             qtd_volumes         LIKE wfat_mestre.qtd_volumes1,
             des_especie1        CHAR(15), # A SQUADRONI TEM ATÉ 3 ESPÉCIES E
             des_especie2        CHAR(06), # PEDIU P/ IMPRIMIR TODAS TRUNCANDO
             des_especie3        CHAR(06), # CADA UMA NA SEXTA POSIÇÃO
             des_especie4        CHAR(06),
             des_especie5        CHAR(06),
             den_marca           LIKE clientes.den_marca,
             num_pri_volume      LIKE wfat_mestre.num_pri_volume,
             num_ult_volume      LIKE wfat_mestre.num_pri_volume,
             pes_tot_bruto       LIKE wfat_mestre.pes_tot_bruto,
             pes_tot_liquido     LIKE wfat_mestre.pes_tot_liquido,
             cod_repres          LIKE wfat_mestre.cod_repres,
             nom_guerra          LIKE representante.nom_guerra,
             den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
             num_pedido          LIKE wfat_item.num_pedido,
             num_suframa         LIKE clientes.num_suframa,
             num_om              LIKE wfat_item.num_om,
             num_pedido_repres   LIKE pedidos.num_pedido_repres,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             nat_oper            LIKE nat_operacao.cod_nat_oper,
             ies_tipo_pgto       LIKE cond_pgto.ies_tipo
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] OF RECORD 
             cod_item            LIKE wfat_item.cod_item,
             cod_item_cliente    LIKE cliente_item.cod_item_cliente,
             num_pedido          LIKE wfat_item.num_pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(80),
             cod_fiscal          LIKE nf_item_fiscal.cod_fiscal,
             onu                 LIKE fat_item_emerg.onu,
             risco_abnt          LIKE fat_item_emerg.risco_abnt,
             den_item2           CHAR(80),
             den_item22          CHAR(80),
             den_item23          CHAR(80),
             den_item24          CHAR(80),
             den_item25          CHAR(80),
             den_item26          CHAR(80),
             den_item27          CHAR(80),
             den_item28          CHAR(80),
             den_item29          CHAR(80),
             den_item210         CHAR(80),
             den_item3           CHAR(80), 
             den_item4           CHAR(80),
             cod_cla_fisc        CHAR(10),              
             cod_origem          LIKE wfat_mestre.cod_origem,
             cod_tributacao      LIKE wfat_mestre.cod_tributacao,
             pes_unit            LIKE wfat_item.pes_unit,
             cod_unid_med        LIKE wfat_item.cod_unid_med,
             qtd_item            LIKE wfat_item.qtd_item,
             pre_unit            LIKE wfat_item.pre_unit_nf,
             val_liq_item        LIKE wfat_item.val_liq_item,
             pct_icm             LIKE wfat_mestre.pct_icm,
             pct_ipi             LIKE wfat_item.pct_ipi,
             val_ipi             LIKE wfat_item.val_ipi,
             val_icm_ret         LIKE wfat_item.val_icm_ret,
             num_sequencia       LIKE wfat_item.num_sequencia
          END RECORD

   DEFINE p_wnotalev       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          LIKE wfat_item.cod_item,
             den_item          CHAR(080),
             cod_fiscal        LIKE nf_item_fiscal.cod_fiscal,
             onu               LIKE fat_item_emerg.onu,
             risco_abnt        LIKE fat_item_emerg.risco_abnt,
             cod_item_cli      CHAR(30),
             cod_cla_fisc      CHAR(10),
             cod_origem        LIKE wfat_mestre.cod_origem,
             cod_tributacao    LIKE wfat_mestre.cod_tributacao,
             pes_unit          LIKE wfat_item.pes_unit,   
             cod_unid_med      LIKE wfat_item.cod_unid_med,
             qtd_item          LIKE wfat_item.qtd_item,
             pre_unit          LIKE wfat_item.pre_unit_nf,
             val_liq_item      LIKE wfat_item.val_liq_item,
             pct_icm           LIKE wfat_mestre.pct_icm,
             pct_ipi           LIKE wfat_item.pct_ipi,
             val_ipi           LIKE wfat_item.val_ipi,
             des_texto         CHAR(120),
             num_nff           LIKE wfat_mestre.num_nff 
          END RECORD
          
   DEFINE p_consignat 
          RECORD
             den_consignat       LIKE clientes.nom_cliente,
             end_consignat       LIKE clientes.end_cliente,
             den_bairro          LIKE clientes.den_bairro,
             den_cidade          LIKE cidades.den_cidade,
             cod_uni_feder       LIKE cidades.cod_uni_feder
          END RECORD

   DEFINE p_end_entrega 
          RECORD
             end_entrega         LIKE clientes.end_cliente,
             num_cgc             LIKE wfat_end_ent.num_cgc,
             ins_estadual        LIKE wfat_end_ent.ins_estadual,
             cod_cep             LIKE wfat_end_ent.cod_cep,
             den_cidade          LIKE cidades.den_cidade,
             cod_uni_feder       LIKE cidades.cod_uni_feder
          END RECORD
 
   DEFINE p_end_cobranca
          RECORD
             end_cobr            LIKE cli_end_cob.end_cobr,
             den_bairro          LIKE cli_end_cob.den_bairro,
             cod_cidade_cob      LIKE cli_end_cob.cod_cidade_cob,
             cod_cep             LIKE cli_end_cob.cod_cep,
             den_cidade          LIKE cidades.den_cidade,
             cod_uni_feder       LIKE cidades.cod_uni_feder
          END RECORD

   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_6lpp                     CHAR(02),
          p_8lpp                     CHAR(02)
 
   DEFINE pa_texto_ped_it            ARRAY[05] 
          OF RECORD
             texto                   CHAR(76)
          END RECORD
 
   DEFINE pa_texto_obs               ARRAY[05] 
          OF RECORD
             den_texto               CHAR(32)
          END RECORD
  
   DEFINE p_textos RECORD
          texto1                    CHAR(50),
          texto2                    CHAR(50),
          texto3                    CHAR(50),
          texto4                    CHAR(50),
          texto5                    CHAR(50)
   END RECORD

   DEFINE p_num_linhas               SMALLINT,
          p_num_pagina               SMALLINT,
          p_tot_paginas              SMALLINT
 
   DEFINE p_saltar_linhas            SMALLINT,
          p_linhas_print             SMALLINT
 
   DEFINE p_des_texto                CHAR(120),
          p_des_texto1               CHAR(120),
          p_des_texto6               CHAR(120),          
          p_val_tot_ipi_acum         DECIMAL(15,3)

   DEFINE p_base_icms     ARRAY[2]
          OF RECORD
          val_liq_item    LIKE wfat_item.val_liq_item,
          pct_icm         LIKE wfat_mestre.pct_icm
          END RECORD

   DEFINE p_txt_base_icms            CHAR(300)
   DEFINE p_versao                   CHAR(18)
   DEFINE g_ies_ambiente             CHAR(01)

END GLOBALS

   DEFINE g_cod_item_cliente  LIKE cliente_item.cod_item_cliente

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0703-05.10.47"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("vdp.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0703_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0703_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0703") RETURNING comando    
   OPEN WINDOW w_pol0703 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

    SELECT tip_trim,
           cod_emp_gerencial
      INTO p_tip_trim,
           p_cod_emp_ger
      FROM empresas_885
     WHERE cod_emp_oficial = p_cod_empresa 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresas_885')
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0001
         IF log005_seguranca(p_user,"VDP","POL0703","CO") THEN
            IF pol0703_entrada_parametros() THEN
               LET p_ies_cons = TRUE
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar" "Lista as Notas Fiscais Fatura"
         HELP 0002
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL0703","CO") THEN
               LET p_ies_cons = FALSE
               IF pol0703_imprime_nff() THEN 
                  NEXT OPTION "Fim"
               END IF
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0703

END FUNCTION

#-----------------------------------#
FUNCTION pol0703_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 09", p_versao)
   CURRENT WINDOW IS w_pol0703

   LET p_saltar_linhas = TRUE
   LET p_linhas_print  = 0
   LET p_reimpressao   = "N"
   LET p_num_nff_ini   = 0
   LET p_num_nff_fim   = 999999
   LET m_data          = TODAY

   INPUT p_reimpressao,
         m_data,
         p_num_nff_ini,
         p_num_nff_fim WITHOUT DEFAULTS
   FROM reimpressao,
        data_nf,
        num_nff_ini,
        num_nff_fim 

      AFTER FIELD reimpressao
         IF p_reimpressao IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD reimpressao
         ELSE
            IF p_reimpressao <> "S" AND 
               p_reimpressao <> "N" THEN
               ERROR 'Valor ilegal p/ o campo'
               NEXT FIELD reimpressao
            END IF
         END IF
         IF p_reimpressao = "S" THEN
            LET p_num_nff_ini = NULL  
            LET p_num_nff_fim = NULL   
            DISPLAY p_num_nff_ini TO num_nff_ini
            DISPLAY p_num_nff_fim TO num_nff_fim
         END IF
{
      AFTER FIELD data_nf
         IF m_data IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD data_nf
         END IF
 }     
      AFTER FIELD num_nff_ini
         IF p_num_nff_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD num_nff_ini
         END IF
         
      AFTER FIELD num_nff_fim
         IF p_num_nff_fim IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD num_nff_fim
         END IF

         IF p_num_nff_fim < p_num_nff_ini THEN
            ERROR 'Número da NF final < número NF inicial'
            NEXT FIELD num_nff_ini
         END IF

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0703

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0703_imprime_nff()
#----------------------------#    

   DEFINE p_indice        DECIMAL(2,0),
          p_cod_cla_fisc  CHAR(10),
          l_des_texto     CHAR(120),
          l_count         INTEGER

   IF log028_saida_relat(16,41) IS NOT NULL THEN 
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0703_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0703.tmp' 
            START REPORT pol0703_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0703_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE
   END IF

   CURRENT WINDOW IS w_pol0703

   CALL pol0703_busca_dados_empresa()
   CALL pol0703_param_frt_auton()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 

   IF p_reimpressao = "S" THEN
      LET p_reimpressao = "R"
   END IF

   LET p_nota_imp = FALSE
   
   DECLARE cq_wfat_mestre CURSOR WITH HOLD FOR
   SELECT *
      FROM wfat_mestre
   WHERE cod_empresa  = p_cod_empresa
     AND num_nff     >= p_num_nff_ini
     AND num_nff     <= p_num_nff_fim
#     AND nom_usuario  = p_user
     AND ies_impr_nff = p_reimpressao       
   ORDER BY num_nff

   FOREACH cq_wfat_mestre INTO p_wfat_mestre.*

      LET p_nat_oper     = p_wfat_mestre.cod_nat_oper
      LET p_nff.nat_oper = p_nat_oper
      
      SELECT ies_situacao
        INTO p_ies_situacao
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_wfat_mestre.num_nff
      
      IF STATUS <> 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_ies_situacao <> 'N' THEN
         CONTINUE FOREACH
      END IF
      
      DISPLAY p_wfat_mestre.num_nff TO num_nff_proces 

      CALL pol0703_cria_tabela_temporaria()

      INITIALIZE pa_corpo_nff, p_nff TO NULL
      INITIALIZE cod_cla_h, cod_cla_i, cod_cla_j TO  NULL

      LET p_nff.num_nff       = p_wfat_mestre.num_nff
      LET p_nff.cod_fiscal    = NULL
      LET p_nff.cod_fiscal1   = NULL
      LET p_nff.den_nat_oper  = NULL
      LET p_nff.den_nat_oper1 = NULL
          
      DECLARE cq_codf CURSOR FOR
       SELECT UNIQUE cod_fiscal,
                     cod_nat_oper
         FROM nf_item_fiscal
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = p_wfat_mestre.num_nff
          AND cod_nat_oper > 0

      FOREACH cq_codf INTO p_cod_fiscal,
                           p_cod_nat_oper 

         IF p_nff.cod_fiscal IS NULL THEN
            LET p_nff.cod_fiscal           = p_cod_fiscal
            LET p_wfat_mestre.cod_nat_oper = p_cod_nat_oper
            LET p_nff.den_nat_oper         = pol0703_den_nat_oper()
         ELSE
            LET p_nff.cod_fiscal1          = p_cod_fiscal
            LET p_wfat_mestre.cod_nat_oper = p_cod_nat_oper
            LET p_nff.den_nat_oper1        = pol0703_den_nat_oper()
            EXIT FOREACH
         END IF

      END FOREACH
      
      CALL pol0703_busca_dados_subst_trib_uf()
      
      LET p_nff.ins_estadual_trib  = p_subst_trib_uf.ins_estadual
      #LET p_nff.den_nat_oper       = pol0703_den_nat_oper()
      LET p_nff.nat_oper           = p_wfat_mestre.cod_nat_oper
      LET p_nff.dat_emissao        = p_wfat_mestre.dat_emissao

      CALL pol0703_busca_dados_clientes()
 
      LET p_nff.nom_destinatario = p_clientes.nom_cliente
      LET p_nff.num_cgc_cpf      = p_clientes.num_cgc_cpf
 
      IF p_nff.num_cgc_cpf[1] = "0" THEN
         LET p_nff.num_cgc_cpf = p_nff.num_cgc_cpf[2,19]
      END IF
 
      LET p_nff.end_destinatario   = p_clientes.end_cliente
      LET p_nff.den_bairro         = p_clientes.den_bairro
      LET p_nff.cod_cep            = p_clientes.cod_cep
      LET p_nff.cod_cliente        = p_clientes.cod_cliente

      IF p_clientes.ies_zona_franca = "S" OR
         p_clientes.ies_zona_franca = "A" OR
         p_nff.cod_fiscal = 6109 THEN
  
         LET p_wfat_mestre.pct_icm = 0
        
      END IF   

      CALL pol0703_busca_dados_cidades(p_clientes.cod_cidade)
      LET p_uf_cli = p_cidades.cod_uni_feder
      

      LET p_nff.den_cidade         = p_cidades.den_cidade          
      LET p_nff.num_telefone       = p_clientes.num_telefone
      LET p_nff.num_telex          = p_clientes.num_telex
      LET p_nff.cod_uni_feder      = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual       = p_clientes.ins_estadual
      LET p_nff.hora_saida         = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0703_busca_cof_compl()

      CALL pol0703_busca_nome_pais()
      LET p_nff.den_pais = p_paises.den_pais              

      CALL pol0703_busca_dados_duplicatas()

      CALL log038_extenso(p_wfat_mestre.val_tot_nff,130,130,1,1)
            RETURNING p_nff.val_extenso1, p_nff.val_extenso2,
                      p_nff.val_extenso3, p_nff.val_extenso4
    
      INITIALIZE p_num_seq_fr TO NULL
      
      CALL pol0703_carrega_corpo_nff() 
      
      CALL pol0703_carrega_corpo_nota()

      CALL pol0703_carrega_end_cobranca()
      LET p_nff.end_cobr_cli      = p_end_cobranca.end_cobr
      LET p_nff.den_cidade_cli    = p_end_cobranca.den_cidade
      LET p_nff.cod_uni_feder_cli = p_end_cobranca.cod_uni_feder
      LET p_nff.cod_cep_cli       = p_end_cobranca.cod_cep

      IF p_nat_operacao.ies_tip_controle = "3" THEN
         CALL pol0703_retorno_terceiro()
      END IF
         
      CALL pol0703_carrega_val_mdo()
      
      CALL pol0703_trata_zona_franca()

      LET l_count = 0
      SELECT COUNT(*)
        INTO l_count
        FROM nf_consig_ref
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_wfat_mestre.num_nff

      IF l_count > 0 THEN   
         CALL pol0703_trata_consignacao()
      END IF    
       
      LET p_nff.val_tot_base_icm   = p_wfat_mestre.val_tot_base_icm 
      LET p_nff.val_tot_icm        = p_wfat_mestre.val_tot_icm

      IF p_nff.val_tot_icm = 0 THEN
         LET p_nff.val_tot_base_icm = 0
      END IF

      LET p_nff.val_tot_base_ret   = p_wfat_mestre.val_tot_base_ret
      LET p_nff.val_tot_icm_ret    = p_wfat_mestre.val_tot_icm_ret
      LET p_nff.val_tot_mercadoria = p_wfat_mestre.val_tot_mercadoria
      LET p_nff.val_frete_cli      = p_wfat_mestre.val_frete_cli
      LET p_nff.val_seguro_cli     = p_wfat_mestre.val_seguro_cli
      LET p_nff.val_tot_despesas   = 0
      LET p_nff.val_tot_ipi        = p_wfat_mestre.val_tot_ipi

      IF p_wfat_mestre.cod_fiscal = 5124 OR
         p_wfat_mestre.cod_fiscal = 6124 THEN
         LET p_nff.val_tot_nff = p_nff.val_tot_mercadoria
             #p_val_tot_nf + p_wfat_mestre.val_frete_rod + p_wfat_mestre.val_seguro_rod
      ELSE
         LET p_nff.val_tot_nff = p_wfat_mestre.val_tot_nff
      END IF

      CALL pol0703_busca_dados_transport(p_wfat_mestre.cod_transpor)
      CALL pol0703_busca_dados_cidades(p_transport.cod_cidade)
      LET p_nff.nom_transpor = p_transport.nom_cliente  
      
      IF p_wfat_mestre.ies_frete = 3 THEN 
         LET p_nff.ies_frete = 2
      ELSE 
         LET p_nff.ies_frete = 1
      END IF
               
      LET p_nff.num_placa = p_wfat_mestre.num_placa
      
      IF p_transport.num_cgc_cpf[1] = "0" THEN
         LET p_nff.num_cgc_trans = p_transport.num_cgc_cpf[2,19]
      ELSE
         LET p_nff.num_cgc_trans = p_transport.num_cgc_cpf
      END IF
           
      LET p_nff.end_transpor        = p_transport.end_cliente
      LET p_nff.den_cidade_trans    = p_cidades.den_cidade
      LET p_nff.cod_uni_feder_trans = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual_trans  = p_transport.ins_estadual
      
      IF p_transport.cod_tip_cli = p_tip_transp_auto  THEN
         IF pol0703_frete_auton(p_nff.nat_oper)= FALSE THEN
            LET p_nff.frt_auton   = 'N'
         ELSE
            LET p_nff.frt_auton   = 'S'
          END IF   
      ELSE   
         LET p_nff.frt_auton   = 'N'
      END IF
      

      {LET p_nff.des_especie1 = pol0703_especie(1)
      LET p_nff.des_especie2  = pol0703_especie(2)
      LET p_nff.des_especie3  = pol0703_especie(3)
      LET p_nff.des_especie4  = pol0703_especie(4)
      LET p_nff.des_especie5  = pol0703_especie(5)}

      LET p_nff.qtd_volumes  = p_wfat_mestre.qtd_volumes1 +
                               p_wfat_mestre.qtd_volumes2 +
                               p_wfat_mestre.qtd_volumes3 +
                               p_wfat_mestre.qtd_volumes4 +
                               p_wfat_mestre.qtd_volumes5

      IF p_tip_trim = 'P' THEN #numero de bobinas da NF
         IF p_qtdvolumes > 0 THEN
            LET p_nff.qtd_volumes = p_qtdvolumes
         END IF
      END IF

      #CALL pol0703_junta_volumes()
      
      #LET p_nff.den_marca       = p_clientes.den_marca
      LET p_nff.den_marca       = "CIBRAPEL"
      LET p_nff.pes_tot_bruto   = p_wfat_mestre.pes_tot_bruto
      LET p_nff.pes_tot_liquido = p_wfat_mestre.pes_tot_liquido
      LET p_nff.num_pedido      = p_wfat_item.num_pedido
      LET p_nff.cod_repres      = p_wfat_mestre.cod_repres
      LET p_nff.nom_guerra      = pol0703_representante()
      LET p_nff.num_suframa     = p_clientes.num_suframa
      LET p_nff.num_om          = p_wfat_item.num_om
      LET p_nff.den_cnd_pgto    = pol0703_den_cnd_pgto()
      LET p_nff.ies_tipo_pgto   = p_ies_tipo_pgto

      #--- cria indice de classificação fiscal

      LET p_indice     = 0
      LET p_num_pagina = 0
      
      DECLARE cq_ind_cla CURSOR FOR
      SELECT cod_cla_fisc
     FROM wnotalev
    WHERE ies_tip_info = 1
      AND cod_cla_fisc IS NOT NULL 
      AND cod_cla_fisc <> ' '
    ORDER BY cod_cla_fisc 

   FOREACH cq_ind_cla INTO p_cod_cla_fisc

      SELECT cod_cla_fisc
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_cod_cla_fisc
       
      IF SQLCA.sqlcode = NOTFOUND THEN
         LET p_indice = p_indice + 1
         INSERT INTO clas_fisc_temp 
            VALUES(p_cod_cla_fisc, p_indice)
      END IF
     
   END FOREACH
   
   #--- cria arquivo de texto para impressao 
   LET p_num_seq = 0
   INITIALIZE p_txt TO NULL
   INITIALIZE p_des_texto TO NULL

   DECLARE cq_cl_t CURSOR FOR
   SELECT * 
     FROM clas_fisc_temp
    ORDER BY 2
   FOREACH cq_cl_t INTO p_clas_fisc_temp.* 
      IF p_clas_fisc_temp.num_item = 1 THEN 
         LET p_des_texto = 'Class.Fiscal: ', p_clas_fisc_temp.num_item USING "&", '-', p_clas_fisc_temp.cod_cla_fisc
      ELSE
         LET p_des_texto = '              ', p_clas_fisc_temp.num_item USING "&", '-', p_clas_fisc_temp.cod_cla_fisc
      END IF  
      CALL pol0703_insert_array(p_des_texto,4)
      INITIALIZE p_des_texto TO NULL
   END FOREACH 
   # fim criação indice de classificação fiscal

      {SELECT COUNT(*)
        INTO p_cont
        FROM clas_fisc_temp
	     WHERE pre_impresso <> 'S'
   
      LET p_des_texto = NULL
  
      IF p_cont > 0 THEN
         LET p_cont = 0
         DECLARE cq_imp_cla CURSOR FOR
          SELECT cod_cla_fisc,
                 cod_cla_reduz
	          FROM clas_fisc_temp
           WHERE pre_impresso <> 'S'
 
         FOREACH cq_imp_cla INTO p_cod_cla_fisc,
                                 p_cod_cla_reduz

            IF p_des_texto IS NULL THEN
               LET p_des_texto = "Class.Fiscal: ",p_cod_cla_reduz CLIPPED,'=',p_cod_cla_fisc
            ELSE
               LET p_des_texto = p_des_texto CLIPPED, '//',p_cod_cla_reduz CLIPPED,'=',p_cod_cla_fisc
            END IF
                    
         END FOREACH            	       
         CALL pol0703_insert_array(p_des_texto,4)
      END IF}
      
      #--- FIM ---#
      SELECT COUNT(*)
        INTO p_cont
        FROM romaneio_temp
   
      IF p_cont > 0 THEN
         LET p_cont = 0
         LET p_des_texto = NULL
         DECLARE cq_romaneio1 CURSOR FOR
         SELECT UNIQUE num_pedido
           FROM romaneio_temp
        
         FOREACH cq_romaneio1 INTO p_num_pedido
                                
            IF p_des_texto IS NULL THEN
               IF p_num_pedido IS NOT NULL THEN
                  LET p_des_texto = "Pedido Venda:", p_num_pedido USING "<<<<<&"
               END IF
            ELSE 
               LET p_des_texto = p_des_texto CLIPPED,'/', p_num_pedido USING "<<<<<&"
            END IF
         END FOREACH
         CALL pol0703_insert_array(p_des_texto,4)
      END IF
   
      SELECT COUNT(*)
        INTO p_cont
        FROM romaneio_temp
   
      IF p_cont > 0 THEN
         LET p_cont = 0
         LET p_des_texto = NULL
         DECLARE cq_romaneio2 CURSOR FOR
          SELECT UNIQUE num_om
            FROM romaneio_temp
        
         FOREACH cq_romaneio2 INTO p_num_om
                               
            IF p_des_texto IS NULL THEN
               IF p_num_om IS NOT NULL THEN
                  LET p_des_texto = "OM :", p_num_om USING "<<<<<&"
               END IF
            ELSE 
               LET p_des_texto = p_des_texto CLIPPED,'/', p_num_om USING "<<<<<&"
            END IF
         END FOREACH
         CALL pol0703_insert_array(p_des_texto,4)
      END IF      

      SELECT COUNT(*)
        INTO p_cont
        FROM romaneio_temp
   
      IF p_cont > 0 THEN
         LET p_cont = 0
         LET p_des_texto = NULL
         DECLARE cq_romaneio5 CURSOR FOR
          SELECT UNIQUE num_romaneio
            FROM romaneio_temp
             
         FOREACH cq_romaneio5 INTO p_num_romaneio
            IF p_num_romaneio = 0 THEN
               EXIT FOREACH
            END IF 
                                         
            IF p_des_texto IS NULL THEN
               IF p_num_om IS NOT NULL THEN
                  LET p_des_texto = "Laudo:", p_num_romaneio USING "<<<<<<<<<&"
               END IF
            ELSE 
               LET p_des_texto = p_des_texto CLIPPED,'/', p_num_romaneio USING "<<<<<<<<<<&"
            END IF
         END FOREACH
         CALL pol0703_insert_array(p_des_texto,4)
      END IF      

      CALL pol0703_carrega_end_entrega()
      CALL pol0703_carrega_historico_fiscal()
      CALL pol0703_grava_dados_consig()
      CALL pol0703_grava_historico_nf_pedido()
      CALL pol0703_checa_nf_contra_ordem()
      
      IF p_num_om > 0 THEN 
         CALL pol0703_pega_lacre()
      END IF 
      
      CALL pol0703_calcula_total_de_paginas()
{
   IF p_tot_paginas = 1 THEN
  
      LET p_des_texto = " "
      IF p_nff.num_duplic1 IS NOT NULL THEN 
         LET p_des_texto = "Duplicata: ", p_cod_empresa,p_nff.num_duplic5 USING "&&&&&&",p_nff.dig_duplic5 USING "&&",
                                          "   ",
                                          p_nff.dat_vencto_sd5 USING "DD/MM/YY","   ",
                                          p_nff.val_duplic5    USING "###,###,##&.&&" 
         CALL pol0703_insert_array(p_des_texto,3)
      END IF

      LET p_des_texto = " "
      IF p_nff.num_duplic2 IS NOT NULL THEN
         LET p_des_texto = "           ", p_cod_empresa,p_nff.num_duplic6 USING "&&&&&&",p_nff.dig_duplic2 USING "&&",
                                          "   ",
                                          p_nff.dat_vencto_sd6 USING "DD/MM/YY","   ",
                                          p_nff.val_duplic6    USING "###,###,##&.&&" 
         CALL pol0703_insert_array(p_des_texto,3)
      END IF

      LET p_des_texto = " "
      IF p_nff.num_duplic7 IS NOT NULL THEN 
         LET p_des_texto = "           ", p_cod_empresa,p_nff.num_duplic7 USING "&&&&&&",p_nff.dig_duplic7 USING "&&",
                                          "   ",
                                          p_nff.dat_vencto_sd7 USING "DD/MM/YY","   ",
                                          p_nff.val_duplic7    USING "###,###,##&.&&" 
            CALL pol0703_insert_array(p_des_texto,3)
      END IF

      LET p_des_texto = " "           
      IF p_nff.num_duplic8 IS NOT NULL THEN 
         LET p_des_texto = "           ", p_cod_empresa,p_nff.num_duplic8 USING "&&&&&&",p_nff.dig_duplic8 USING "&&",
                                          "   ",
                                          p_nff.dat_vencto_sd8 USING "DD/MM/YY","   ",
                                          p_nff.val_duplic8    USING "###,###,##&.&&" 
         CALL pol0703_insert_array(p_des_texto,3)
      END IF
   END IF 
}
      CALL pol0703_monta_relat()

      # marca nf que ja foi impressa #
      
      UPDATE wfat_mestre 
         SET ies_impr_nff = "R"
      WHERE cod_empresa   = p_cod_empresa
        AND num_nff       = p_wfat_mestre.num_nff
##        AND nom_usuario   = p_user
        
        LET p_nota_imp = TRUE

   END FOREACH

   FINISH REPORT pol0703_relat

   IF p_nota_imp THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo
            ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
   ELSE
      MESSAGE ""
      ERROR " Nao Existem Dados para serem Listados"
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0703_junta_volumes()
#-------------------------------#

   DEFINE p_volumes   CHAR(05),
          p_descricao CHAR(06)
   
      INITIALIZE p_qtd_volumes, p_des_especie TO NULL

      IF p_wfat_mestre.qtd_volumes1 > 0 AND LENGTH(p_nff.des_especie1) > 0 THEN
         INSERT INTO volumes_temp 
            VALUES(p_nff.des_especie1,p_wfat_mestre.qtd_volumes1)
      END IF

      IF p_wfat_mestre.qtd_volumes2 > 0 AND LENGTH(p_nff.des_especie2) > 0 THEN
         INSERT INTO volumes_temp 
            VALUES(p_nff.des_especie2,p_wfat_mestre.qtd_volumes2)
      END IF

      IF p_wfat_mestre.qtd_volumes3 > 0 AND LENGTH(p_nff.des_especie3) > 0 THEN
         INSERT INTO volumes_temp 
            VALUES(p_nff.des_especie3,p_wfat_mestre.qtd_volumes3)
      END IF

      IF p_wfat_mestre.qtd_volumes4 > 0 AND LENGTH(p_nff.des_especie4) > 0 THEN
         INSERT INTO volumes_temp 
            VALUES(p_nff.des_especie4,p_wfat_mestre.qtd_volumes4)
      END IF

      IF p_wfat_mestre.qtd_volumes5 > 0 AND LENGTH(p_nff.des_especie5) > 0 THEN
         INSERT INTO volumes_temp 
            VALUES(p_nff.des_especie5,p_wfat_mestre.qtd_volumes5)
      END IF

   DECLARE cq_volumes CURSOR FOR
    SELECT den_volume,
           SUM(qtd_volume)
      FROM volumes_temp
     GROUP BY den_volume
     ORDER BY den_volume
        
   FOREACH cq_volumes INTO
           p_descricao,
           p_volumes
      
      IF p_qtd_volumes IS NULL THEN
         LET p_qtd_volumes = p_volumes CLIPPED
      ELSE
         LET p_qtd_volumes = p_qtd_volumes CLIPPED,'/', p_volumes
      END IF
      
{      IF p_des_especie IS NULL THEN
         LET p_des_especie = p_descricao CLIPPED
      ELSE
         LET p_des_especie = p_des_especie CLIPPED,'/', p_descricao
      END IF}
   
   END FOREACH

END FUNCTION

#---------------------------------------#
FUNCTION pol0703_cria_tabela_temporaria()
#---------------------------------------#

   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN") 

   DROP TABLE txt_excecao
   CREATE TEMP TABLE txt_excecao
     (
      cod_hist     INTEGER,
      texto1       CHAR(75),
      texto2       CHAR(75),
      texto3       CHAR(75),
      texto4       CHAR(75)
     );

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-txt_excecao")
   END IF
   
   DROP TABLE wnotalev;
   CREATE TABLE wnotalev
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(015),
      den_item           CHAR(080),
      cod_fiscal         INTEGER,
      onu                INTEGER,
      risco_abnt         INTEGER,
      cod_item_cli       CHAR(30),
      cod_cla_fisc       CHAR(010),
      cod_origem         CHAR(1),
      cod_tributacao     CHAR(2),
      pes_unit           DECIMAL(9,4),
      cod_unid_med       CHAR(3),
      qtd_item           DECIMAL(12,3),
      pre_unit           DECIMAL(17,6),
      val_liq_item       DECIMAL(15,2),
      pct_icm            DECIMAL(5,2),
      pct_ipi            DECIMAL(6,3),
      val_ipi            DECIMAL(15,2),
      des_texto          CHAR(120),
      num_nff            DECIMAL(6,0)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WNOTALEV")
   END IF

   DROP TABLE wnotalev_aux;
   CREATE TABLE wnotalev_aux
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(015),
      den_item           CHAR(080),
      cod_fiscal         INTEGER,
      onu                INTEGER,
      risco_abnt         INTEGER,
      cod_item_cli       CHAR(30),
      cod_cla_fisc       CHAR(010),
      cod_origem         CHAR(1),
      cod_tributacao     CHAR(2),
      pes_unit           DECIMAL(9,4),
      cod_unid_med       CHAR(3),
      qtd_item           DECIMAL(12,3),
      pre_unit           DECIMAL(17,6),
      val_liq_item       DECIMAL(15,2),
      pct_icm            DECIMAL(5,2),
      pct_ipi            DECIMAL(6,3),
      val_ipi            DECIMAL(15,2),
      des_texto          CHAR(120),
      num_nff            DECIMAL(6,0)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WNOTALEV_AUX")
   END IF

   DROP TABLE retorno_embal;
   CREATE TEMP TABLE retorno_embal
     (
      num_nf         DECIMAL(7,0),
      dat_emis_nf    DATE,
      cod_unid_med   CHAR(03)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-retorno_embal")
   END IF
   
{   DROP TABLE clas_fisc_temp;
   CREATE TABLE clas_fisc_temp
     (
      cod_cla_fisc       CHAR(10),
      cod_cla_reduz      CHAR(02), 
      pre_impresso       CHAR(01)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF}
   
   DROP TABLE clas_fisc_temp;
   CREATE TEMP TABLE clas_fisc_temp
     (
      cod_cla_fisc       CHAR(010),
      num_item           DECIMAL(1,0)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF
      
   DROP TABLE situa_trib_temp;
   CREATE TEMP TABLE situa_trib_temp
     (
      cod_origem      DECIMAL(1,0),
      cod_tributacao  DECIMAL(2,0),
      val_liq_item    DECIMAL(15,2)
      );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:situa_trib_temp")
   END IF

   DROP TABLE base_icms_temp;
   CREATE TEMP TABLE base_icms_temp
     (
      pct_icm            DECIMAL(5,2),
      val_liq_item       DECIMAL(15,2)
      );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:base_icms_temp")
   END IF

   DROP TABLE volumes_temp;
   CREATE TEMP TABLE volumes_temp
     (
      den_volume CHAR(20),
      qtd_volume DECIMAL(5,0)
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:VOLUMES_TEMP")
   END IF

   DROP TABLE romaneio_temp;
   CREATE TEMP TABLE romaneio_temp
     (
      cod_item       CHAR(15),
      num_pedido     DECIMAL(6,0),
      num_om         DECIMAL(6,0),
      num_romaneio   INTEGER
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:VOLUMES_TEMP")
   END IF

   CALL log085_transacao("COMMIT") 

   DELETE FROM txt_excecao
   DELETE FROM wnotalev
   DELETE FROM wnotalev_aux
   DELETE FROM retorno_embal
   DELETE FROM clas_fisc_temp     
   DELETE FROM situa_trib_temp
   DELETE FROM base_icms_temp       
   DELETE FROM volumes_temp

   WHENEVER ERROR STOP
 
END FUNCTION

#----------------------------#
FUNCTION pol0703_monta_relat()
#----------------------------#

   DEFINE p_cod_cla_fisc CHAR(10)

   DEFINE p_num_nf      LIKE item_dev_terc.num_nf,
          p_dat_emis_nf LIKE item_de_terc.dat_emis_nf,
          p_qtd_nf      SMALLINT

   INITIALIZE p_num_nf,
              p_des_texto,
              p_des_texto1,
              p_dat_emis_nf,
              p_unid_terc,
              p_qtd_devolvida TO NULL

   LET p_indice       = 0
   LET p_cont         = 0
   LET p_cod_cla_fisc = NULL 
   LET p_num_pagina   = 0
   
   #--- agrupa os produtos do corpo da nota --- #  
 {  
   INITIALIZE p_wnotalev TO NULL
   
   DECLARE cq_agrupa CURSOR FOR
   SELECT ies_tip_info,
          cod_item,
          den_item,
          cod_fiscal,
          onu,
          risco_abnt,
          cod_cla_fisc, 
          cod_origem, 
          cod_tributacao,
          cod_unid_med,
          SUM(qtd_item), 
          pre_unit, 
          SUM(val_liq_item),
          pct_icm, 
          pct_ipi, 
          SUM(val_ipi)
     FROM wnotalev 
    WHERE ies_tip_info = 1
    GROUP BY ies_tip_info, 
             cod_item,
             den_item,
             cod_fiscal, 
             onu,
             risco_abnt,
             cod_cla_fisc, 
             cod_origem, 
             cod_tributacao,
             cod_unid_med,
             pre_unit,
             pct_icm,
             pct_ipi 
    ORDER BY cod_item

   FOREACH cq_agrupa INTO 
           p_wnotalev.ies_tip_info,
           p_wnotalev.cod_item,
           p_wnotalev.den_item,
           p_wnotalev.cod_fiscal, 
           p_wnotalev.onu,
           p_wnotalev.risco_abnt,
           p_wnotalev.cod_cla_fisc,
           p_wnotalev.cod_origem,
           p_wnotalev.cod_tributacao,
           p_wnotalev.cod_unid_med,
           p_wnotalev.qtd_item,
           p_wnotalev.pre_unit,
           p_wnotalev.val_liq_item,
           p_wnotalev.pct_icm,
           p_wnotalev.pct_ipi,
           p_wnotalev.val_ipi

      INSERT INTO wnotalev_aux
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INSERÇÃO","TABELA-WNOTALEV_AUX")
      END IF
         
   END FOREACH
   
   INSERT INTO wnotalev_aux
   SELECT *
     FROM wnotalev
    WHERE ies_tip_info > 1
   DELETE FROM wnotalev

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("DELEÇÃO","TABELA-WNOTALEV")
   END IF
   
   LET p_num_seq = 0
   
   DECLARE cq_aux_1 CURSOR FOR
    SELECT *
      FROM wnotalev_aux
     WHERE ies_tip_info = 1
  
   FOREACH cq_aux_1 INTO p_wnotalev.*
   
      LET p_num_seq = p_num_seq + 1
      LET p_wnotalev.num_seq = p_num_seq
      
      INSERT INTO wnotalev
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
      END IF

      DECLARE cq_aux_2 CURSOR FOR
       SELECT *
         FROM wnotalev_aux
        WHERE ies_tip_info = 2
          AND cod_item     = p_wnotalev.cod_item
         ORDER BY num_seq
  
      FOREACH cq_aux_2 INTO p_wnotalev.*
   
         LET p_num_seq          = p_num_seq + 1
         LET p_wnotalev.num_seq = p_num_seq
      
         INSERT INTO wnotalev
            VALUES(p_wnotalev.*)

         IF sqlca.sqlcode <> 0 THEN 
            CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
         END IF
         
      END FOREACH
   END FOREACH
    }     
      #CALL pol0703_retorno_embal()
      DECLARE cq_aux_3_4 CURSOR FOR
       SELECT *
         FROM wnotalev_aux
        WHERE ies_tip_info >= 3 
        ORDER BY 1
  
      FOREACH cq_aux_3_4 INTO p_wnotalev.*
   
         LET p_num_seq = p_num_seq + 1
         LET p_wnotalev.num_seq = p_num_seq
      
         INSERT INTO wnotalev
            VALUES(p_wnotalev.*)

         IF SQLCA.sqlcode <> 0 THEN 
            CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
         END IF

      END FOREACH

{   DECLARE cq_aux_3 CURSOR FOR
    SELECT *
      FROM wnotalev_aux
     WHERE ies_tip_info = 3 
     ORDER BY num_seq,ies_tip_info
  
   FOREACH cq_aux_3 INTO p_wnotalev.*
   
      LET p_num_seq = p_num_seq + 1
      LET p_wnotalev.num_seq = p_num_seq
      
      INSERT INTO wnotalev
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
      END IF

   END FOREACH

   DECLARE cq_aux_4 CURSOR FOR
    SELECT *
      FROM wnotalev_aux
     WHERE ies_tip_info = 4 
     ORDER BY ies_tip_info
  
   FOREACH cq_aux_4 INTO p_wnotalev.*
   
      LET p_num_seq = p_num_seq + 1
      LET p_wnotalev.num_seq = p_num_seq
      
      INSERT INTO wnotalev
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
      END IF

   END FOREACH}

   #--- cria indice de situacao tributaria com valores

   DECLARE cq_sit_trib1 CURSOR FOR
   SELECT cod_origem,
          cod_tributacao,
          SUM(val_liq_item)
     FROM wnotalev
    WHERE ies_tip_info = 1
    GROUP BY cod_origem,cod_tributacao
    ORDER BY cod_origem,cod_tributacao

   FOREACH cq_sit_trib1 INTO p_cod_origem,
                             p_cod_tributacao,
                             p_val_liq_item

      INSERT INTO situa_trib_temp
         VALUES(p_cod_origem, p_cod_tributacao, p_val_liq_item)

   END FOREACH
   
   INITIALIZE p_situacao TO NULL
   DECLARE cq_sit_trib2 CURSOR FOR
    SELECT cod_origem,
           cod_tributacao,
           val_liq_item
      FROM situa_trib_temp

   FOREACH cq_sit_trib2 INTO
           p_cod_origem,
           p_cod_tributacao,
           p_val_liq_item
     
      IF p_situacao IS NULL THEN
         LET p_situacao = p_cod_origem USING "&", p_cod_tributacao USING "&&"," - ",p_val_liq_item  USING "<<<#,##&.&&"
      ELSE
         LET p_situacao = p_situacao CLIPPED , " // ", p_cod_origem USING "&",
                          p_cod_tributacao USING "&&"," - ",p_val_liq_item  USING "<<<#,##&.&&"
      END IF
   END FOREACH

   #--- verifica se tem 2 percentual de icms diferentes
   
   INITIALIZE p_base_icms TO NULL

   LET n_i = 1

   DECLARE cq_base_icms CURSOR FOR
    SELECT pct_icm,
           SUM(val_liq_item)
      FROM base_icms_temp
     GROUP BY pct_icm
     ORDER BY pct_icm

   FOREACH cq_base_icms INTO 
           p_pct_icm,
           p_val_liq_item
           
      LET p_base_icms[n_i].pct_icm      = p_pct_icm
      LET p_base_icms[n_i].val_liq_item = p_val_liq_item
      LET p_valor_icms = ((p_base_icms[n_i].val_liq_item * p_base_icms[n_i].pct_icm) / 100 )
      LET p_txt_base_icms = "Base de Calculo" 
           
      LET n_i = n_i + 1
      
   END FOREACH

   #--- cria arquivo de texto para impressao 

   LET p_num_seq = 0
   INITIALIZE p_txt TO NULL
      
   INITIALIZE p_texto1,
              p_texto2,
              p_texto3,
              p_des_texto TO NULL
                 
   DECLARE cq_texto1 CURSOR FOR
   SELECT des_texto
     FROM wnotalev
    WHERE ies_tip_info = 4
    ORDER BY num_seq,des_texto

   FOREACH cq_texto1 INTO p_des_texto
     
#     IF LENGTH(p_des_texto) > 0 THEN        
        IF LENGTH(p_des_texto) <= 55 THEN
           CALL pol0703_insere_texto(p_des_texto)
        ELSE
           IF LENGTH(p_des_texto) <= 110 THEN
              #CALL substr(p_des_texto,55,2,'N') RETURNING p_texto1, p_texto2
              LET p_texto1 = p_des_texto[01,55]
              LET p_texto2 = p_des_texto[56,110]
              CALL pol0703_insere_texto(p_texto1)
              CALL pol0703_insere_texto(p_texto2)
           ELSE
              #CALL substr(p_des_texto,55,3,'N') RETURNING p_texto1, p_texto2, p_texto3
              LET p_texto1 = p_des_texto[01,55]
              LET p_texto2 = p_des_texto[56,110]
              LET p_texto3 = p_des_texto[111,120]
              CALL pol0703_insere_texto(p_texto1)
              CALL pol0703_insere_texto(p_texto2)
              CALL pol0703_insere_texto(p_texto3)
           END IF
        END IF 
#     END IF

     IF p_num_seq > 24 THEN
        EXIT FOREACH
     END IF
   
#     DELETE FROM wnotalev
#      WHERE ies_tip_info = 4
        
   END FOREACH
  
   LET p_linha = 1

   DECLARE cq_wnotalev CURSOR FOR
    SELECT *
      FROM wnotalev
     WHERE ies_tip_info <= 3
     ORDER BY num_seq

   FOREACH cq_wnotalev INTO p_wnotalev.*
      
      LET p_wnotalev.num_nff = p_wfat_mestre.num_nff

      SELECT num_item
        INTO p_cod_ref_clas
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_wnotalev.cod_cla_fisc
      IF SQLCA.sqlcode <> 0 THEN 
         LET p_cod_ref_clas = ' '
      END IF    
             
      {SELECT cod_cla_reduz
        INTO p_cod_cla_reduz
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_wnotalev.cod_cla_fisc
        
      IF STATUS <> 0 THEN
         INITIALIZE p_cod_cla_reduz TO NULL
      END IF}
      
      OUTPUT TO REPORT pol0703_relat(p_wnotalev.num_nff)
      
  END FOREACH
  
    DECLARE cq_wnotalev_6 CURSOR FOR
    SELECT *
      FROM wnotalev
     WHERE ies_tip_info = 6
     ORDER BY num_seq

   FOREACH cq_wnotalev_6 INTO p_wnotalev.*
         
      OUTPUT TO REPORT pol0703_relat(p_wnotalev.num_nff)
      
   END FOREACH

  { pula linhas até completar o número de linhas do corpo da página (18)}
  { somente se o numero de linhas da nota nao for multiplo de 18 }
  
  IF p_saltar_linhas THEN
     LET p_wnotalev.num_nff      = p_wfat_mestre.num_nff
     LET p_wnotalev.ies_tip_info = 5

     OUTPUT TO REPORT pol0703_relat(p_wnotalev.num_nff)

  END IF 
  

  
  
END FUNCTION

#------------------------------------#
FUNCTION pol0703_insere_texto(p_texto)
#------------------------------------#

   DEFINE p_texto CHAR(55)
   
   LET p_num_seq = p_num_seq + 1
   
   IF p_num_seq < 24 THEN
      LET p_txt[p_num_seq].texto = p_texto
   END IF

END FUNCTION

#---------------------------------------#
FUNCTION pol0703_busca_dados_duplicatas()
#---------------------------------------#
   DEFINE p_wfat_duplic    RECORD LIKE wfat_duplic.*,
          p_contador       DECIMAL(2,0)

   LET p_nff.val_duplic1  = NULL
   LET p_nff.val_duplic2  = NULL
   LET p_nff.val_duplic3  = NULL
   LET p_nff.val_duplic4  = NULL
   LET p_nff.val_duplic5  = NULL
   LET p_nff.val_duplic6  = NULL
   LET p_nff.val_duplic7  = NULL
   LET p_nff.val_duplic8  = NULL
   LET p_nff.val_duplic9  = NULL
   LET p_nff.val_duplic10 = NULL
   LET p_nff.val_duplic11 = NULL
   LET p_nff.val_duplic12 = NULL
   
   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT * 
     FROM wfat_duplic
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_wfat_mestre.num_nff
    ORDER BY cod_empresa,
             num_duplicata,
             dig_duplicata,
             dat_vencto_sd

   FOREACH cq_duplic INTO p_wfat_duplic.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1  
            LET p_nff.num_duplic1    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic1    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd1 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic1    = p_wfat_duplic.val_duplic
         WHEN 2      
            LET p_nff.num_duplic2    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic2    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd2 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic2    = p_wfat_duplic.val_duplic
         WHEN 3      
            LET p_nff.num_duplic3    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic3    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd3 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic3    = p_wfat_duplic.val_duplic
         WHEN 4
            LET p_nff.num_duplic4    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic4    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd4 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic4    = p_wfat_duplic.val_duplic
         WHEN 5
            LET p_nff.num_duplic5    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic5    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd5 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic5    = p_wfat_duplic.val_duplic
         WHEN 6
            LET p_nff.num_duplic6    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic6    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd6 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic6    = p_wfat_duplic.val_duplic
         WHEN 7
            LET p_nff.num_duplic7    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic7    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd7 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic7    = p_wfat_duplic.val_duplic
         WHEN 8
            LET p_nff.num_duplic8    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic8    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd8 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic8    = p_wfat_duplic.val_duplic
         WHEN 9
            LET p_nff.num_duplic9    = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic9    = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd9 = p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic9    = p_wfat_duplic.val_duplic
         WHEN 10
            LET p_nff.num_duplic10   = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic10   = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd10= p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic10   = p_wfat_duplic.val_duplic
         WHEN 11
            LET p_nff.num_duplic11   = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic11   = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd11= p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic11   = p_wfat_duplic.val_duplic
         WHEN 12
            LET p_nff.num_duplic12   = p_wfat_duplic.num_duplicata
            LET p_nff.dig_duplic12   = p_wfat_duplic.dig_duplicata
            LET p_nff.dat_vencto_sd12= p_wfat_duplic.dat_vencto_sd
            LET p_nff.val_duplic12   = p_wfat_duplic.val_duplic
         OTHERWISE   
            EXIT FOREACH
      END CASE
   END FOREACH
END FUNCTION

#-------------------------------------#
FUNCTION pol0703_carrega_end_entrega()
#-------------------------------------#

   INITIALIZE p_end_entrega.*  TO NULL
 
   SELECT wfat_end_ent.end_entrega,
          wfat_end_ent.cod_cep,
          wfat_end_ent.num_cgc,
          wfat_end_ent.ins_estadual,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_end_entrega.*
     FROM wfat_end_ent,
          cidades
    WHERE wfat_end_ent.cod_empresa = p_cod_empresa
      AND wfat_end_ent.num_nff     = p_wfat_mestre.num_nff
      AND wfat_end_ent.cod_cidade  = cidades.cod_cidade

   IF p_end_entrega.end_entrega IS NOT NULL THEN
      LET p_des_texto = "Local de Entr.: ",p_end_entrega.end_entrega
      CALL pol0703_insert_array(p_des_texto,4)
      LET p_des_texto = "                ",p_end_entrega.den_cidade CLIPPED,"-",p_end_entrega.cod_uni_feder CLIPPED,
                        "- CEP: ",p_end_entrega.cod_cep 
      CALL pol0703_insert_array(p_des_texto,4)
      LET p_des_texto = "                ","CNPJ: ", p_end_entrega.num_cgc
      CALL pol0703_insert_array(p_des_texto,4)
      LET p_des_texto = "                ","Insc. Estadual: ", p_end_entrega.ins_estadual
      CALL pol0703_insert_array(p_des_texto,4)
   END IF

   #LET p_des_texto = p_end_entrega.end_entrega
   #CALL pol0703_insert_array(p_des_texto,4)

END FUNCTION

#-------------------------------------#
FUNCTION pol0703_carrega_end_cobranca()
#-------------------------------------#

   INITIALIZE p_end_cobranca.* TO NULL 

   SELECT cli_end_cob.end_cobr,
          cli_end_cob.den_bairro,
          cli_end_cob.cod_cidade_cob,
          cli_end_cob.cod_cep,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_end_cobranca.end_cobr,
          p_end_cobranca.den_bairro,
          p_end_cobranca.cod_cidade_cob,
          p_end_cobranca.cod_cep,
          p_end_cobranca.den_cidade,
          p_end_cobranca.cod_uni_feder
     FROM cli_end_cob,
          cidades
    WHERE cli_end_cob.cod_cliente    = p_nff.cod_cliente
      AND cli_end_cob.cod_cidade_cob = cidades.cod_cidade

   {IF p_end_cobranca.end_cobr IS NOT NULL THEN
      LET p_des_texto = "COBRANCA: ", p_end_cobranca.end_cobr
      LET p_des_texto = p_des_texto CLIPPED, " ", p_end_cobranca.den_cidade
      LET p_des_texto = p_des_texto CLIPPED, " ", p_end_cobranca.cod_uni_feder
      CALL pol0703_insert_array(p_des_texto,4)
   END IF}
END FUNCTION

#----------------------------------#
FUNCTION pol0703_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao
          
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          p_achou              SMALLINT,
          sql_stmt             CHAR(2000)

  DEFINE l_num_solicit   LIKE frete_roma_885.num_solicit,
         l_cod_emp       CHAR(02),
         l_qtd_pacotes   DECIMAL(5) 

   LET p_ind = 0
   LET p_count = 0 
   LET p_numsequencia = NULL
   LET p_qtdvolumes = 0

   IF p_wfat_mestre.ies_origem = 'P' THEN
      LET sql_stmt =
           "SELECT * FROM wfat_item ",
           "WHERE cod_empresa ='",p_cod_empresa,"' ",
             "AND num_nff     ='",p_wfat_mestre.num_nff,"' ",
             "AND num_pedido  > 0 "
   ELSE
      LET sql_stmt = 
          "SELECT * FROM wfat_item ",
           "WHERE cod_empresa ='",p_cod_empresa,"' ",
             "AND num_nff     ='",p_wfat_mestre.num_nff,"' "
   END IF
     
   PREPARE var_query FROM sql_stmt
   DECLARE cq_wfat_item CURSOR FOR var_query

   FOREACH cq_wfat_item INTO p_wfat_item.*
   
      LET p_ind = p_ind + 1
      
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF

      LET pa_corpo_nff[p_ind].cod_cla_fisc    = p_wfat_item.cod_cla_fisc
      LET pa_corpo_nff[p_ind].cod_item        = p_wfat_item.cod_item
      LET pa_corpo_nff[p_ind].num_sequencia   = p_wfat_item.num_sequencia
      LET pa_corpo_nff[p_ind].num_pedido      = p_wfat_item.num_pedido
      LET pa_corpo_nff[p_ind].den_item1       = p_wfat_item.den_item

      IF p_wfat_item.num_sequencia > 0 THEN 
         CALL pol0703_larg_comp(p_ind)
      END IF 
      
      SELECT num_solicit
        INTO p_num_romaneio
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_wfat_item.num_om 
      
      CALL pol0703_carrega_romaneio()

      IF p_wfat_item.num_pedido > 0 THEN 
         CALL pol0703_grava_ped_at()
      END IF 
      
      LET p_ies_lote = "N"
      INITIALIZE p_num_lote to NULL 

      DECLARE cq_lote_rt CURSOR FOR
       SELECT num_reserva  
         FROM ordem_montag_grade        
        WHERE cod_empresa   = p_cod_empresa
          AND num_om        = p_wfat_item.num_om    
          AND cod_item      = p_wfat_item.cod_item  
          AND num_sequencia = p_wfat_item.num_sequencia
          AND num_pedido    = p_wfat_item.num_pedido

      FOREACH cq_lote_rt  INTO p_num_reserva     

         SELECT num_lote 
           INTO p_num_lot
           FROM estoque_loc_reser
          WHERE cod_empresa = p_cod_empresa 
            AND num_reserva = p_num_reserva 
      
         IF SQLCA.SQLCODE <> 0 THEN
            CONTINUE FOREACH
         END IF 

         IF p_ies_lote = "N"  THEN
            LET p_num_lote = p_num_lot     
         ELSE 
            LET p_num_lote = p_num_lote CLIPPED, "/",p_num_lot 
         END IF

         LET p_ies_lote = "S"        

      END FOREACH

      SELECT *
        INTO p_tipo_pedido_885.*
        FROM tipo_pedido_885
       WHERE cod_empresa =  p_cod_emp_ger
         AND num_pedido  =  p_wfat_item.num_pedido

      IF p_tipo_pedido_885.tipo_pedido = 1 THEN
         SELECT num_pedido_cli
           INTO p_nff.num_pedido_cli
           FROM item_bobina_885
          WHERE cod_empresa = p_cod_emp_ger
            AND num_pedido  = p_wfat_item.num_pedido
            AND num_sequencia = p_wfat_item.num_sequencia
      ELSE
         IF p_tipo_pedido_885.tipo_pedido = 3 THEN
            SELECT num_pedido_cli
              INTO p_nff.num_pedido_cli
              FROM item_caixa_885
             WHERE cod_empresa = p_cod_emp_ger
               AND num_pedido  = p_wfat_item.num_pedido
               AND num_sequencia = p_wfat_item.num_sequencia
         ELSE
            SELECT num_pedido_cli
              INTO p_nff.num_pedido_cli
              FROM item_chapa_885
             WHERE cod_empresa = p_cod_emp_ger
               AND num_pedido  = p_wfat_item.num_pedido
               AND num_sequencia = p_wfat_item.num_sequencia
         END IF 
      END IF    

#     CALL pol0703_busca_dados_pedido()

      IF p_num_seq_fr IS NULL THEN 
         SELECT cod_emp_gerencial
           INTO p_cod_emp
           FROM empresas_885
          WHERE cod_emp_oficial = p_cod_empresa 
           
         SELECT DISTINCT
                num_solicit
           INTO p_num_solicit
           FROM frete_roma_885
          WHERE cod_empresa = p_cod_empresa
            AND num_om      = p_wfat_item.num_om
         
         LET p_num_solic_trim = p_num_solicit
         
         SELECT DISTINCT
                num_sequencia
           INTO p_num_seq_fr    
           FROM frete_solicit_885
          WHERE cod_empresa = p_cod_empresa
            AND num_solicit = p_num_solicit
         
         LET p_numsequencia = p_num_seq_fr
      END IF
      
#      IF p_tip_trim = 'B' THEN
      IF p_cod_grupo_item <> '04' THEN      
         SELECT SUM(qtdpacote)
           INTO l_qtd_pacotes
           FROM roma_item_885
          WHERE codempresa = p_cod_emp
            AND numseqpai  = p_num_seq_fr
            AND numpedido  = p_wfat_item.num_pedido
            AND numseqitem = p_wfat_item.num_sequencia
            AND coditem    = p_wfat_item.cod_item
         IF STATUS <> 0 THEN
            LET l_qtd_pacotes = 0
         END IF
      ELSE
         LET l_qtd_pacotes = 0
      END IF     

      IF p_wfat_mestre.ies_frete = '3' THEN 
         LET p_num_solic_trim = p_num_romaneio
         SELECT MAX(numsequencia)
           INTO p_numsequencia 
           FROM romaneio_885
          WHERE codempresa  =  p_cod_emp_ger
            AND numromaneio =  p_num_romaneio
            AND statusregistro = '1'
      END IF 
      
      IF p_tip_trim = 'P' THEN #calcula numero de bobinas da NF
         IF p_numsequencia IS NOT NULL THEN
            SELECT COUNT(numseqpai)
              INTO p_count
              FROM roma_item_885
             WHERE codempresa  = p_cod_emp_ger
               AND numromaneio = p_num_solic_trim
               AND numseqpai   = p_numsequencia
               AND numpedido   = p_wfat_item.num_pedido
               AND numseqitem  = p_wfat_item.num_sequencia
            
            IF p_count IS NOT NULL THEN
               LET p_qtdvolumes = p_qtdvolumes + p_count
            END IF
         END IF
      END IF
    
      IF p_nff.num_pedido_cli IS NOT NULL THEN
         IF pa_corpo_nff[p_ind].den_item4 IS NULL THEN
            LET pa_corpo_nff[p_ind].den_item4 = " OC: ", p_nff.num_pedido_cli CLIPPED
            IF l_qtd_pacotes > 0 THEN 
               LET pa_corpo_nff[p_ind].den_item4 = pa_corpo_nff[p_ind].den_item4 CLIPPED, ' PACOTES :',l_qtd_pacotes USING '<<<<<'
            END IF    
         ELSE
            LET pa_corpo_nff[p_ind].den_item4 = pa_corpo_nff[p_ind].den_item4, " OC: ", p_nff.num_pedido_cli CLIPPED
            IF l_qtd_pacotes > 0 THEN 
               LET pa_corpo_nff[p_ind].den_item4 = pa_corpo_nff[p_ind].den_item4 CLIPPED, ' PACOTES :',l_qtd_pacotes USING '<<<<<'
            END IF    
         END IF
      ELSE
         IF l_qtd_pacotes > 0 THEN 
            LET pa_corpo_nff[p_ind].den_item4 = ' PACOTES : ',l_qtd_pacotes USING '<<<<<'
         END IF    
      END IF
      
      CALL pol0703_verifica_texto_ped_it()

      IF p_wfat_item.num_sequencia > 0 THEN
         IF LENGTH(pa_texto_ped_it[1].texto) > 0 THEN
            LET pa_corpo_nff[p_ind].den_item3 = 
                pa_corpo_nff[p_ind].den_item3 CLIPPED, pa_texto_ped_it[1].texto
         END IF
      END IF

      LET pa_corpo_nff[p_ind].pes_unit       = p_wfat_item.pes_unit 
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit       = p_wfat_item.pre_unit_nf
      LET pa_corpo_nff[p_ind].val_liq_item   = p_wfat_item.val_liq_item
 
      SELECT UNIQUE pct_icm,
                    cod_fiscal,
                    cod_origem,
                    cod_tributacao 
        INTO p_nf_item_fiscal.pct_icm,
             p_nf_item_fiscal.cod_fiscal,
             p_nf_item_fiscal.cod_origem,
             p_nf_item_fiscal.cod_tributacao
             
        FROM nf_item_fiscal 
       WHERE cod_empresa   = p_wfat_item.cod_empresa 
         AND num_nff       = p_wfat_item.num_nff 
         AND num_pedido    = p_wfat_item.num_pedido 
         AND num_sequencia = p_wfat_item.num_sequencia

      LET pa_corpo_nff[p_ind].pct_icm        = p_nf_item_fiscal.pct_icm
      LET pa_corpo_nff[p_ind].cod_fiscal     = p_nf_item_fiscal.cod_fiscal 
      LET pa_corpo_nff[p_ind].cod_origem     = p_nf_item_fiscal.cod_origem
      LET pa_corpo_nff[p_ind].cod_tributacao = p_nf_item_fiscal.cod_tributacao

      IF p_wfat_mestre.val_tot_icm = 0 OR 
         p_wfat_mestre.val_tot_base_icm = 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = 0
      END IF

      LET pa_corpo_nff[p_ind].pct_ipi     = p_wfat_item.pct_ipi
      LET pa_corpo_nff[p_ind].val_ipi     = p_wfat_item.val_ipi

      LET pa_corpo_nff[p_ind].val_icm_ret = p_wfat_item.val_icm_ret
      LET p_val_tot_ipi_acum              = p_val_tot_ipi_acum + 
                                            p_wfat_item.val_ipi

      SELECT cod_nat_oper
        INTO p_cod_nat_oper
        FROM nf_item_fiscal
       WHERE cod_empresa   = p_wfat_item.cod_empresa
         AND num_nff       = p_wfat_item.num_nff
         AND num_pedido    = p_wfat_item.num_pedido
         AND num_sequencia = p_wfat_item.num_sequencia
         AND ordem_montag  = p_wfat_item.num_om

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","nf_item_fiscal")       
      END IF

      INITIALIZE p_cod_texto TO NULL
      
      DECLARE cq_icms CURSOR FOR
       SELECT hist_icms
         FROM vdp_excecao_icms
        WHERE empresa = p_cod_empresa
          AND cliente = p_wfat_mestre.cod_cliente
          AND (classif_fisc = p_wfat_item.cod_cla_fisc OR
               item = p_wfat_item.cod_item)

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LEITURA","vdp_excecao_icms")       
       END IF

      FOREACH cq_icms INTO p_cod_texto
         CALL pol0703_le_fiscal_hist(p_cod_texto)
      END FOREACH

      DECLARE cq_ipi CURSOR FOR
       SELECT hist_excecao
         FROM vdp_exc_ipi_cli
        WHERE empresa = p_cod_empresa
          AND cliente = p_wfat_mestre.cod_cliente
          AND (classif_fiscal = p_wfat_item.cod_cla_fisc OR
               item = p_wfat_item.cod_item)

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LEITURA","vdp_exc_ipi_cli")       
       END IF

      FOREACH cq_ipi INTO p_cod_texto
         CALL pol0703_le_fiscal_hist(p_cod_texto)
      END FOREACH

   END FOREACH

   LET p_cod_nat_oper = p_wfat_mestre.cod_nat_oper
   CALL pol0703_pega_texto()
   IF p_wfat_mestre.ies_origem = 'P' THEN
      CALL pol0703_troca_hist()
   END IF 
END FUNCTION

#--------------------------------#
 FUNCTION pol0703_grava_ped_at()
#--------------------------------#
 DEFINE l_count  INTEGER
  
 LET l_count = 0  
 SELECT COUNT(*)  
   INTO l_count
   FROM ped_at_885
  WHERE cod_empresa = p_cod_empresa
    AND num_pedido  = p_wfat_item.num_pedido
 
 IF l_count = 0 THEN 
    INSERT INTO ped_at_885 VALUES (p_cod_empresa,p_wfat_item.num_pedido,2,'N')
 END IF    

END FUNCTION

#--------------------------------#
 FUNCTION pol0703_larg_comp(p_ind)
#--------------------------------#

   DEFINE p_descricao CHAR(06),
          p_txt_dimen CHAR(20),
          p_ind       SMALLINT,
          p_dimen     CHAR(10),
          l_ind       INTEGER,
          l_qtd_larg  LIKE estoque_trans.qtd_movto,
          l_num_nf_vd LIKE nf_mestre.num_nff 

   INITIALIZE p_largura,
              p_comprimento,
              p_cod_grupo_item,  
              p_descricao, 
              p_txt_dimen, 
              p_dimen, 
              tab_larg TO NULL

   SELECT grupo_item.cod_grupo_item
     INTO p_cod_grupo_item
     FROM item_vdp
     LEFT OUTER join grupo_item ON
     item_vdp.cod_grupo_item      =  grupo_item.cod_grupo_item
    WHERE item_vdp.cod_empresa= p_cod_empresa
      AND item_vdp.cod_item   = p_wfat_item.cod_item

   IF SQLCA.sqlcode = 0 THEN
      IF p_cod_grupo_item   =   '01'   THEN
         LET p_descricao = "CAIXA"
      ELSE    
         IF p_cod_grupo_item   =   '02' OR 
            p_cod_grupo_item   =   '03'  THEN
            LET p_descricao = "CHAPA"
         ELSE          
            IF p_cod_grupo_item   =   '04'   THEN
               LET p_descricao = "BOBINA"
            END IF 
         END IF 
      END IF 
   END IF                        

   LET p_nff.des_especie1 = p_descricao CLIPPED

   LET l_num_nf_vd = 0 
   
   SELECT MAX(num_nff) 
     INTO l_num_nf_vd
     FROM nf_referencia
    WHERE cod_empresa  = p_cod_empresa
##      AND num_pedido   = p_wfat_item.num_pedido
      AND num_nff_ref  = p_wfat_mestre.num_nff

   IF l_num_nf_vd > 0 THEN 
      LET p_num_nf_ch = l_num_nf_vd
   ELSE
      LET p_num_nf_ch = p_wfat_item.num_nff
   END IF 
   
   LET l_ind = 0 
   IF p_cod_grupo_item   =   '04'   THEN
      IF p_wfat_item.num_pedido > 0 THEN 
         LET p_lot_ped = p_wfat_item.num_pedido USING '&&&&&&' CLIPPED,'%'
         DECLARE cq_contp CURSOR FOR
           SELECT largura, comprimento,SUM(a.qtd_movto)
             FROM estoque_trans a, 
                  estoque_trans_end b,
                  estoque_obs c
            WHERE a.cod_empresa = b.cod_empresa 
              AND a.num_transac = b.num_transac
              AND a.cod_empresa = c.cod_empresa 
              AND a.num_transac = c.num_transac  
              AND a.cod_empresa = p_cod_empresa
              AND a.num_docum   = p_num_nf_ch
              AND a.num_seq     = p_wfat_item.num_sequencia
              AND a.cod_item    = p_wfat_item.cod_item
              AND c.tex_observ  LIKE p_lot_ped
            GROUP BY  largura, comprimento 
         FOREACH cq_contp INTO p_largura, p_comprimento, l_qtd_larg  
           LET l_ind = l_ind + 1
           LET tab_larg[l_ind].largura = p_largura
           LET tab_larg[l_ind].comprimento = p_comprimento     
           LET tab_larg[l_ind].qtd_larg = l_qtd_larg   
         END FOREACH    
      ELSE
         DECLARE cq_cont CURSOR FOR
           SELECT largura, comprimento,SUM(a.qtd_movto)
             FROM estoque_trans a, 
                  estoque_trans_end b 
            WHERE a.cod_empresa = b.cod_empresa 
              AND a.num_transac = b.num_transac
              AND a.cod_empresa = p_cod_empresa
              AND a.num_docum   = p_num_nf_ch
              AND a.num_seq     = p_wfat_item.num_sequencia
              AND a.cod_item    = p_wfat_item.cod_item
            GROUP BY  largura, comprimento 
         FOREACH cq_cont INTO p_largura, p_comprimento, l_qtd_larg  
           LET l_ind = l_ind + 1
           LET tab_larg[l_ind].largura = p_largura
           LET tab_larg[l_ind].comprimento = p_comprimento     
           LET tab_larg[l_ind].qtd_larg = l_qtd_larg   
         END FOREACH    
      END IF    
   ELSE
      IF p_wfat_item.num_pedido > 0 THEN
         LET p_lot_ped = p_wfat_item.num_pedido USING '<<<<<<' CLIPPED,'/',p_wfat_item.num_sequencia USING '<<<'
         DECLARE cq_contp2 CURSOR FOR   
           SELECT  largura, comprimento,SUM(a.qtd_movto)
             FROM estoque_trans a, 
                  estoque_trans_end b 
            WHERE a.cod_empresa = b.cod_empresa 
              AND a.num_transac = b.num_transac
              AND a.cod_empresa = p_cod_empresa
              AND a.num_docum   = p_num_nf_ch
              AND a.num_seq     = p_wfat_item.num_sequencia
              AND a.cod_item    = p_wfat_item.cod_item
              AND a.num_lote_orig = p_lot_ped
            GROUP BY  largura, comprimento 
         FOREACH  cq_contp2  INTO p_largura, p_comprimento, l_qtd_larg  
           LET l_ind = l_ind + 1
           LET tab_larg[l_ind].largura = p_largura
           LET tab_larg[l_ind].comprimento = p_comprimento     
           LET tab_larg[l_ind].qtd_larg = l_qtd_larg   
         END FOREACH    
         IF tab_larg[l_ind].largura IS NULL THEN          
            LET p_lot_ped = p_wfat_item.num_pedido USING '&&&&&&' CLIPPED,'%'
            DECLARE cq_contpo2 CURSOR FOR
              SELECT largura, comprimento,SUM(a.qtd_movto)
                FROM estoque_trans a, 
                     estoque_trans_end b,
                     estoque_obs c
               WHERE a.cod_empresa = b.cod_empresa 
                 AND a.num_transac = b.num_transac
                 AND a.cod_empresa = c.cod_empresa 
                 AND a.num_transac = c.num_transac  
                 AND a.cod_empresa = p_cod_empresa
                 AND a.num_docum   = p_num_nf_ch
                 AND a.num_seq     = p_wfat_item.num_sequencia
                 AND a.cod_item    = p_wfat_item.cod_item
                 AND c.tex_observ  LIKE p_lot_ped
               GROUP BY  largura, comprimento 
            FOREACH cq_contpo2 INTO p_largura, p_comprimento, l_qtd_larg  
              LET l_ind = l_ind + 1
              LET tab_larg[l_ind].largura = p_largura
              LET tab_larg[l_ind].comprimento = p_comprimento     
              LET tab_larg[l_ind].qtd_larg = l_qtd_larg   
            END FOREACH    
         END IF  
      ELSE
         DECLARE cq_cont2 CURSOR FOR
           SELECT largura, comprimento,SUM(a.qtd_movto)
             FROM estoque_trans a, 
                  estoque_trans_end b 
            WHERE a.cod_empresa = b.cod_empresa 
              AND a.num_transac = b.num_transac
              AND a.cod_empresa = p_cod_empresa
              AND a.num_docum   = p_num_nf_ch
              AND a.num_seq     = p_wfat_item.num_sequencia
              AND a.cod_item    = p_wfat_item.cod_item
            GROUP BY  largura, comprimento 
         FOREACH cq_cont2 INTO p_largura, p_comprimento, l_qtd_larg  
           LET l_ind = l_ind + 1
           LET tab_larg[l_ind].largura = p_largura
           LET tab_larg[l_ind].comprimento = p_comprimento     
           LET tab_larg[l_ind].qtd_larg = l_qtd_larg   
         END FOREACH    
      END IF    
   END IF 

  IF l_ind > 1 THEN 
     FOR l_ind = 1 TO 40
       
       IF tab_larg[l_ind].qtd_larg = 0 OR 
          tab_larg[l_ind].qtd_larg IS NULL THEN 
          EXIT FOR
       END IF 
       
       IF tab_larg[l_ind].largura IS NULL THEN 
          EXIT FOR
       END IF 
          
       IF tab_larg[l_ind].largura = 0 THEN 
          INITIALIZE tab_larg[l_ind].largura TO NULL
       END IF    
      
       IF tab_larg[l_ind].comprimento = 0 THEN 
          INITIALIZE tab_larg[l_ind].comprimento TO NULL
       END IF    
      
       IF tab_larg[l_ind].largura IS NOT NULL THEN
          IF p_cod_grupo_item   =   '03'   THEN
             IF l_ind = 1 THEN 
                LET p_txt_dimen = 'LARGURA: ', tab_larg[l_ind].largura  USING '<<<<<'
             ELSE
                LET p_txt_dimen = '         ', tab_larg[l_ind].largura  USING '<<<<<'
             END IF    
          ELSE   
             LET p_txt_dimen = tab_larg[l_ind].largura  
          END IF    
       END IF
      
       IF tab_larg[l_ind].comprimento IS NOT NULL THEN
          IF p_cod_grupo_item <> '03'   THEN
             LET p_dimen = tab_larg[l_ind].comprimento USING '<<<<<<<<<<'
             IF p_txt_dimen IS NULL THEN
                LET p_txt_dimen = p_dimen
             ELSE
                LET p_txt_dimen = p_txt_dimen CLIPPED, ' X ', p_dimen
             END IF
          ELSE
             LET p_txt_dimen = p_txt_dimen CLIPPED,' QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
          END IF    
       END IF
      
       IF p_txt_dimen IS NOT NULL THEN
          IF l_ind = 1 THEN 
             IF p_cod_grupo_item  = '02'   OR 
                p_cod_grupo_item  = '03' THEN
                LET pa_corpo_nff[p_ind].den_item2 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
             ELSE
                LET pa_corpo_nff[p_ind].den_item2 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
             END IF     
          ELSE
             IF l_ind = 2 THEN 
                IF p_cod_grupo_item  = '02'   OR 
                   p_cod_grupo_item  = '03' THEN
                   LET pa_corpo_nff[p_ind].den_item22 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                ELSE
                   LET pa_corpo_nff[p_ind].den_item22 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                END IF     
             ELSE
                IF l_ind = 3 THEN 
                   IF p_cod_grupo_item  = '02'   OR 
                      p_cod_grupo_item  = '03' THEN
                      LET pa_corpo_nff[p_ind].den_item23 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                   ELSE
                      LET pa_corpo_nff[p_ind].den_item23 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                   END IF     
                ELSE
                   IF l_ind = 4 THEN 
                      IF p_cod_grupo_item  = '02'   OR 
                         p_cod_grupo_item  = '03' THEN
                         LET pa_corpo_nff[p_ind].den_item24 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                      ELSE
                         LET pa_corpo_nff[p_ind].den_item24 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                      END IF     
                   ELSE
                      IF l_ind = 5 THEN 
                         IF p_cod_grupo_item  = '02'   OR 
                            p_cod_grupo_item  = '03' THEN
                            LET pa_corpo_nff[p_ind].den_item25 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                         ELSE
                            LET pa_corpo_nff[p_ind].den_item25 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                         END IF     
                      ELSE
                         IF l_ind = 6 THEN 
                            IF p_cod_grupo_item  = '02'   OR 
                               p_cod_grupo_item  = '03' THEN
                               LET pa_corpo_nff[p_ind].den_item26 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                            ELSE
                               LET pa_corpo_nff[p_ind].den_item26 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                            END IF     
                         ELSE
                            IF l_ind = 7 THEN 
                               IF p_cod_grupo_item  = '02'   OR 
                                  p_cod_grupo_item  = '03' THEN
                                  LET pa_corpo_nff[p_ind].den_item27 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                               ELSE
                                  LET pa_corpo_nff[p_ind].den_item27 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                               END IF     
                            ELSE
                               IF l_ind = 8 THEN 
                                  IF p_cod_grupo_item  = '02'   OR 
                                     p_cod_grupo_item  = '03' THEN
                                     LET pa_corpo_nff[p_ind].den_item28 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                  ELSE
                                     LET pa_corpo_nff[p_ind].den_item28 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                  END IF
                               ELSE       
                                  IF l_ind = 9 THEN 
                                     IF p_cod_grupo_item  = '02'   OR 
                                        p_cod_grupo_item  = '03' THEN
                                        LET pa_corpo_nff[p_ind].den_item29 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                     ELSE
                                        LET pa_corpo_nff[p_ind].den_item29 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                     END IF    
                                  ELSE   
                                     IF l_ind = 10 THEN 
                                        IF p_cod_grupo_item  = '02'   OR 
                                           p_cod_grupo_item  = '03' THEN
                                           LET pa_corpo_nff[p_ind].den_item210 = p_txt_dimen CLIPPED,' MM - QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                        ELSE
                                           LET pa_corpo_nff[p_ind].den_item210 = p_txt_dimen CLIPPED,'- QTD: ', tab_larg[l_ind].qtd_larg USING '<<<<<<<<<'
                                        END IF    
                                     END IF     
                                  END IF     
                               END IF
                            END IF 
                         END IF 
                      END IF 
                   END IF 
                END IF 
             END IF              
          END IF 
       END IF 
     END FOR   
  ELSE 
    IF l_ind = 1 THEN 
       LET p_largura = tab_larg[1].largura
       LET p_comprimento = tab_larg[1].comprimento
    
       IF p_largura = 0 THEN 
          INITIALIZE p_largura TO NULL
       END IF    
      
       IF p_comprimento = 0 THEN 
          INITIALIZE p_comprimento TO NULL
       END IF    
      
       IF p_largura IS NOT NULL THEN
          IF p_cod_grupo_item   =   '04'   THEN
             LET p_txt_dimen = 'LARGURA: ', p_largura  USING '<<<<<'
          ELSE   
             LET p_txt_dimen = p_largura  
          END IF    
       END IF
      
       IF p_comprimento IS NOT NULL THEN
          IF p_cod_grupo_item <> '04'   THEN
             LET p_dimen = p_comprimento USING '<<<<<<<<<<'
             IF p_txt_dimen IS NULL THEN
                LET p_txt_dimen = p_dimen
             ELSE
                LET p_txt_dimen = p_txt_dimen CLIPPED, ' X ', p_dimen
             END IF
          END IF    
       END IF
      
       IF p_txt_dimen IS NOT NULL THEN
          IF p_cod_grupo_item  = '02' OR 
             p_cod_grupo_item  = '03' THEN
             LET pa_corpo_nff[p_ind].den_item2 = p_txt_dimen CLIPPED,' MM'
          ELSE
             LET pa_corpo_nff[p_ind].den_item2 = pa_corpo_nff[p_ind].den_item2 CLIPPED, ' ', p_txt_dimen
          END IF     
       END IF 
      
    END IF 
  END IF    

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol0703_carrega_clas_reduz()
#-------------------------------------#
    
   INITIALIZE p_cod_cla_reduz, p_pre_impresso TO NULL
    
   SELECT classif_fisc_reduz,
          pre_imp
     INTO p_cod_cla_reduz,
          p_pre_impresso
     FROM obf_compl_cl_fisc
    WHERE classif_fisc = p_wfat_item.cod_cla_fisc
      
   IF SQLCA.sqlcode = 0 THEN

      SELECT *
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_wfat_item.cod_cla_fisc
       ORDER BY cod_cla_fisc
         
      IF SQLCA.sqlcode <> 0 THEN              
         INSERT INTO clas_fisc_temp 
            VALUES(p_wfat_item.cod_cla_fisc, p_cod_cla_reduz, p_pre_impresso)
      END IF 
   END IF
END FUNCTION

#-----------------------------------#
 FUNCTION pol0703_carrega_romaneio()
#-----------------------------------#
   
   INSERT INTO romaneio_temp 
          VALUES(p_wfat_item.cod_item, p_wfat_item.num_pedido, p_wfat_item.num_om,p_num_romaneio)

END FUNCTION

#------------------------------#
FUNCTION pol0703_retorno_embal()
#------------------------------#

   DEFINE p_num_nf      LIKE item_dev_terc.num_nf,
          p_dat_emis_nf LIKE item_de_terc.dat_emis_nf,
          p_qtd_nf      SMALLINT
   
   INITIALIZE p_num_nf,
              p_des_texto,
              p_dat_emis_nf,
              p_unid_terc,
              p_qtd_devolvida TO NULL

    LET p_unid_terc = p_wfat_item.cod_unid_med 
              
    DECLARE cq_retorno CURSOR FOR
     SELECT a.num_nf,
            a.qtd_devolvida,
            b.cod_unid_med
       FROM item_dev_terc a,
            item_de_terc b
      WHERE a.cod_empresa    = p_cod_empresa
        AND a.num_nf_retorno = p_nff.num_nff
        AND b.cod_empresa    = a.cod_empresa
        AND b.num_nf         = a.num_nf
        AND b.ser_nf         = a.ser_nf
        AND b.ssr_nf         = a.ssr_nf
        AND b.ies_especie_nf = a.ies_especie_nf
        AND b.cod_fornecedor = a.cod_fornecedor
        AND b.num_sequencia  = a.num_sequencia
        AND b.cod_item       = p_wfat_item.cod_item
    
   FOREACH cq_retorno INTO p_num_nf,
                           p_qtd_devolvida,
                           p_unid_terc

      IF p_qtd_devolvida > 0 THEN

         INSERT INTO retorno_embal
            VALUES ( p_num_nf,
                     p_dat_emis_nf,
                     p_unid_terc )
      END IF

   END FOREACH

END FUNCTION

#----------------------------#
FUNCTION pol0703_pega_texto()
#----------------------------#

   DEFINE p_cod_hist_1 LIKE fiscal_par.cod_hist_1,
          p_cod_hist_2 LIKE fiscal_par.cod_hist_2,
          p_qtd_reg    SMALLINT

   SELECT cod_hist_1,
          cod_hist_2
     INTO p_cod_hist_1,
          p_cod_hist_2
     FROM fiscal_par
    WHERE cod_empresa   = p_cod_empresa
      AND cod_uni_feder = p_cidades.cod_uni_feder 
      AND cod_nat_oper  = p_cod_nat_oper
      
   IF SQLCA.sqlcode = NOTFOUND THEN
      SELECT cod_hist_1,
             cod_hist_2
        INTO p_cod_hist_1,
             p_cod_hist_2
        FROM fiscal_par
       WHERE cod_empresa   = p_cod_empresa
         AND cod_nat_oper  = p_cod_nat_oper
         AND cod_uni_feder IS NULL

      IF sqlca.sqlcode <> 0 THEN
         RETURN
      END IF
   END IF

   CALL pol0703_le_fiscal_hist(p_cod_hist_1)
   CALL pol0703_le_fiscal_hist(p_cod_hist_2)

END FUNCTION

#-----------------------------------------#
FUNCTION pol0703_le_fiscal_hist(p_cod_hist)
#-----------------------------------------#

   DEFINE p_txt_1      LIKE fiscal_hist.tex_hist_1,
          p_txt_2      LIKE fiscal_hist.tex_hist_2,
          p_txt_3      LIKE fiscal_hist.tex_hist_3,
          p_txt_4      LIKE fiscal_hist.tex_hist_4,
          p_cod_hist   LIKE fiscal_hist.cod_hist,
          p_contador   SMALLINT

   INITIALIZE p_txt_1,
              p_txt_2,
              p_txt_3,
              p_txt_4,
              p_contador TO NULL
 
   SELECT COUNT(*)
     INTO p_contador
     FROM txt_excecao
    WHERE cod_hist = p_cod_hist
   
   IF p_contador = 0 OR
      p_contador = NULL THEN
              
      SELECT tex_hist_1,
             tex_hist_2,
             tex_hist_3,
             tex_hist_4
        INTO p_txt_1,
             p_txt_2,
             p_txt_3,
             p_txt_4
        FROM fiscal_hist
       WHERE cod_hist = p_cod_hist

      IF sqlca.sqlcode = 0 THEN
         INSERT INTO txt_excecao VALUES(p_cod_hist,
                                        p_txt_1,   
                                        p_txt_2,
                                        p_txt_3,
                                        p_txt_4)
 
         IF SQLCA.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSÃO", "txt_excecao")
         END IF
      END IF
   END IF             

END FUNCTION

#----------------------------#
FUNCTION pol0703_troca_hist()
#----------------------------#

   DEFINE p_wfat_historico RECORD LIKE wfat_historico.*,
          p_texto          CHAR(75),
          p_qtd_reg        SMALLINT
   
   DELETE FROM wfat_historico
    WHERE cod_empresa = p_wfat_item.cod_empresa
      AND num_nff     = p_wfat_item.num_nff
      AND nom_usuario = p_wfat_item.nom_usuario
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("DELEÇÃO","wfat_historico")     
      RETURN  
   END IF

   LET p_qtd_reg = 0
   
   DECLARE cq_txt_hist CURSOR FOR
    SELECT texto1,
           texto2,
           texto3,
           texto4
      FROM txt_excecao
   FOREACH cq_txt_hist INTO 
           p_texto_1,
           p_texto_2,
           p_texto_3,
           p_texto_4

      LET p_qtd_reg = p_qtd_reg + 1
   
      IF p_qtd_reg = 1 THEN
         LET p_wfat_historico.tex_hist1_1 = p_texto_1
         LET p_wfat_historico.tex_hist2_1 = p_texto_2
         LET p_wfat_historico.tex_hist3_1 = p_texto_3
         LET p_wfat_historico.tex_hist4_1 = p_texto_4
      ELSE
         LET p_wfat_historico.tex_hist1_2 = p_texto_1
         LET p_wfat_historico.tex_hist2_2 = p_texto_2
         LET p_wfat_historico.tex_hist3_2 = p_texto_3
         LET p_wfat_historico.tex_hist4_2 = p_texto_4
         EXIT FOREACH
      END IF

   END FOREACH

   IF p_qtd_reg > 0 THEN
   
      LET p_wfat_historico.cod_empresa = p_wfat_item.cod_empresa
      LET p_wfat_historico.num_nff     = p_wfat_item.num_nff
      LET p_wfat_historico.nom_usuario = p_wfat_item.nom_usuario

      IF p_wfat_historico.cod_empresa IS NOT NULL THEN
      
         INSERT INTO wfat_historico
            VALUES(p_wfat_historico.*)

         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("INCLUSAO","wfat_historico")     
         END IF
      
      END IF       
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0703_item_cliente()
#-----------------------------#

   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
      INTO g_cod_item_cliente    
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_wnotalev.cod_item

END FUNCTION

#-----------------------------#
FUNCTION pol0703_busca_risco()
#-----------------------------#

   INITIALIZE p_onu              TO NULL
   INITIALIZE p_risco_abnt       TO NULL
   INITIALIZE p_nom_tecnico_item TO NULL
   
   DECLARE cq_emerg CURSOR FOR
   SELECT onu,
          risco_abnt,
          nom_tecnico_item
     FROM fat_item_emerg
    WHERE empresa = p_cod_empresa
      AND item    = p_wfat_item.cod_item
      
   FOREACH cq_emerg INTO p_onu,
                         p_risco_abnt,
                         p_nom_tecnico_item
      EXIT FOREACH
   END FOREACH
   
END FUNCTION
#---------------------------------------------------------------------------#
FUNCTION pol0703_frete_auton(w_cod_nat_oper)
#---------------------------------------------------------------------------#
   DEFINE w_cod_nat_oper  				LIKE  obf_par_fret_auton.natureza_operacao

          
   INITIALIZE p_obf_par_fret_auton.*, p_fiscal_hist.* , p_des_texto6 TO NULL
   LET p_valor_base_frt = 0 
   
   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_obf_par_fret_auton.*
     FROM obf_par_fret_auton
    WHERE empresa       = p_cod_empresa
      AND natureza_operacao = w_cod_nat_oper 
      AND estado   					= p_uf_cli
      
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF
   
   IF p_obf_par_fret_auton.cod_hist_fiscal  IS NULL THEN
         RETURN FALSE
   END IF
   
   SELECT *
   INTO p_fiscal_hist.*
   FROM fiscal_hist
   WHERE cod_hist      = p_obf_par_fret_auton.cod_hist_fiscal
      
   WHENEVER ERROR STOP
   IF sqlca.sqlcode <> 0 THEN
      RETURN FALSE
   END IF
   
   LET p_valor_base_frt = p_wfat_mestre.val_frete_rod - 
                          ((p_wfat_mestre.val_frete_rod * p_obf_par_fret_auton.pct_red_base_icms)/100)
   
   LET p_val_icms_auton = ((p_valor_base_frt * p_obf_par_fret_auton.pct_icms_frete)/100)
   
   INITIALIZE  p_des_texto6 TO NULL  
   CALL pol0703_insert_array(p_des_texto6,3)    
   
   LET p_des_texto6 =  p_fiscal_hist.tex_hist_1 CLIPPED, p_fiscal_hist.tex_hist_2[1,45]
   CALL pol0703_insert_array(p_des_texto6,3)         
         
   INITIALIZE  p_des_texto6 TO NULL     
         
   LET p_des_texto6 = "Vr: R$ ",p_wfat_mestre.val_frete_rod  USING "<<<##,##&.&&",
                      "  Bc: R$ ",p_valor_base_frt USING "<<<##,##&.&&",
                        " Aliq: ",p_obf_par_fret_auton.pct_icms_frete USING "<<<##&.&&",
                        "% ICMS: ",p_val_icms_auton  USING  "<<<##,##&.&&"  
   CALL pol0703_insert_array(p_des_texto6,3)
 
   RETURN TRUE
END FUNCTION
#--------------------------------------#
FUNCTION pol0703_verifica_ctr_unid_med()
#--------------------------------------#
   DEFINE p_ctr_unid_med   RECORD LIKE  ctr_unid_med.*
   

   WHENEVER ERROR CONTINUE
   SELECT ctr_unid_med.*
     INTO p_ctr_unid_med.*
     FROM ctr_unid_med
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = p_wfat_mestre.cod_cliente
      AND cod_item    = p_wfat_item.cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      RETURN p_ctr_unid_med.fat_conver,
             p_ctr_unid_med.cod_unid_med_cli
   ELSE
      RETURN 1, p_wfat_item.cod_unid_med
   END IF
END FUNCTION

#-----------------------------------------#
FUNCTION pol0703_carrega_historico_fiscal()
#-----------------------------------------#  

   INITIALIZE p_wfat_historico.* TO NULL

   DECLARE cq_whist CURSOR FOR
    SELECT *
      FROM wfat_historico
     WHERE cod_empresa = p_cod_empresa
       AND num_nff = p_wfat_mestre.num_nff

   FOREACH cq_whist INTO p_wfat_historico.* 

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist1_1 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist1_1,4)
      END IF

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist2_1 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist2_1,4)
      END IF
      
#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist3_1 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist3_1,4)
      END IF

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist4_1 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist4_1,4)
      END IF    

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist1_2 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist1_2,4)
      END IF

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist2_2 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist2_2,4)
      END IF

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist3_2 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist3_2,4)
      END IF

#      LET p_des_texto = " "
#      CALL pol0703_insert_array(p_des_texto,4)
      IF p_wfat_historico.tex_hist4_2 <> " " THEN
         CALL pol0703_insert_array(p_wfat_historico.tex_hist4_2,4)
      END IF    
  
   END FOREACH

END FUNCTION

#---------------------------------#
FUNCTION pol0703_carrega_val_mdo()
#---------------------------------#  

   DECLARE cq_wfat_nat CURSOR FOR
    SELECT b.ies_tip_controle
      FROM nf_item_fiscal a, nat_operacao b
     WHERE a.cod_empresa  = p_cod_empresa
       AND a.num_nff      = p_wfat_mestre.num_nff
       AND a.cod_nat_oper = b.cod_nat_oper
       AND a.cod_fiscal IN (p_nff.cod_fiscal, p_nff.cod_fiscal1)

   FOREACH cq_wfat_nat INTO p_nat_operacao.ies_tip_controle

      IF p_nat_operacao.ies_tip_controle = "3" THEN
         EXIT FOREACH
      END IF

   END FOREACH 
  
   IF p_nat_operacao.ies_tip_controle = "3" THEN
     IF p_wfat_mestre.cod_cliente = '1100 MO' OR 
        p_wfat_mestre.cod_cliente = '1101 MO' THEN      

       IF p_nff.cod_fiscal  = 5902 OR
          p_nff.cod_fiscal1 = 5902 OR
          p_nff.cod_fiscal  = 6902 OR
          p_nff.cod_fiscal1 = 6902 THEN
    
          SELECT SUM(a.val_liq_item + a.val_ipi) 
            INTO p_val_mo
            FROM wfat_item a,
                 nf_item_fiscal b,
                 item c
           WHERE a.cod_empresa   = b.cod_empresa 
             AND a.num_nff       = b.num_nff
             AND a.num_sequencia = b.num_sequencia
             AND a.cod_empresa   = c.cod_empresa
             AND a.cod_item      = c.cod_item
             AND c.cod_item LIKE 'MO%'          
             AND a.cod_empresa = p_cod_empresa
             AND a.num_nff = p_wfat_mestre.num_nff
   
          LET p_des_texto = "VALOR Mao de Obra : ", p_val_mo 
          CALL pol0703_insert_array(p_des_texto,3)
       END IF
     END IF   
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0703_trata_zona_franca()
#-----------------------------------#  

   DEFINE p_valor         CHAR(08), 
          p_valor_pis     DEC(15,2), 
          p_valor_cofins  DEC(15,2), 
          p_val_desc_merc DEC(15,2), 
          p_pct_pis       DEC(5,2),
          p_pct_cofins    DEC(5,2),
          l_coef          DEC(7,6),
          l_bas_pis       DEC(15,2)

    DEFINE p_txt_1      LIKE fiscal_hist.tex_hist_1,
           p_txt_2      LIKE fiscal_hist.tex_hist_2,
           p_txt_3      LIKE fiscal_hist.tex_hist_3,
           p_txt_4      LIKE fiscal_hist.tex_hist_4,
           p_cod_hist   LIKE fiscal_hist.cod_hist

   INITIALIZE p_txt_1,
              p_txt_2,
              p_txt_3,
              p_txt_4 TO NULL
                           
   LET p_valor_pis = 0
   LET p_valor_cofins = 0
   IF p_clientes.ies_zona_franca = "S" OR
      p_clientes.ies_zona_franca = "A" OR
      p_nff.cod_fiscal = 6109 THEN

      SELECT par_vdp_txt[422,429]
        INTO p_valor
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa
      
      LET p_pct_pis = p_valor[1,4] 
      LET p_pct_cofins = p_valor[5,8] 
      LET p_pct_pis = p_pct_pis / 100 
      LET p_pct_cofins = p_pct_cofins / 100

      SELECT par_ies
        INTO p_par_vdp_pad.par_ies
        FROM par_vdp_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = "abat_pis_cofins"

      IF p_clientes.ies_zona_franca = "S" THEN
         LET p_campo_pis    = "PIS DESC ZONA FRANCA - ITEM"
         LET p_campo_cofins = "COFINS DESC ZONA FRANCA - ITEM"
      ELSE
         LET p_campo_pis    = "VALOR_PIS_ITEM"
         LET p_campo_cofins = "VALOR_COFINS_ITEM"
      END IF      

      IF (p_clientes.ies_zona_franca = "S" AND p_par_vdp_pad.par_ies = "S") OR 
         (p_clientes.ies_zona_franca = "A" AND p_par_vdp_pad.par_ies = "C") THEN
         
         IF p_wfat_mestre.cod_cliente = '1601' THEN  ###  yamaha 
            LET l_coef = 1 - ((p_pct_pis + p_pct_cofins)/100) 
            LET l_bas_pis = p_wfat_mestre.val_tot_nff / l_coef
            LET p_valor_pis = l_bas_pis * p_pct_pis/100
            LET p_valor_cofins =  l_bas_pis * p_pct_cofins/100
         ELSE   
            SELECT SUM(parametro_val)
              INTO p_valor_pis
              FROM fat_nf_item_compl
             WHERE empresa     = p_cod_empresa
               AND nota_fiscal = p_wfat_mestre.num_nff
               AND campo       = p_campo_pis

            IF p_valor_pis IS NULL THEN
               LET p_valor_pis = 0
            END IF
            
            SELECT SUM(parametro_val)
              INTO p_valor_cofins
              FROM fat_nf_item_compl
             WHERE empresa     = p_cod_empresa
               AND nota_fiscal = p_wfat_mestre.num_nff
               AND campo       = p_campo_cofins
      
            IF p_valor_cofins IS NULL THEN
               LET p_valor_cofins = 0
            END IF
         END IF   
      END IF

      LET p_val_desc_merc = p_wfat_mestre.val_desc_merc - (p_valor_pis + p_valor_cofins)
      LET p_des_texto = NULL
      
      IF p_valor_pis > 0 THEN
         LET p_des_texto = "      PIS: ", p_pct_pis USING "<<&.&&", "% = R$ ", p_valor_pis USING "<<,<<<,<#&.&&"
      END IF

      IF p_valor_cofins > 0 THEN
         IF p_des_texto IS NULL THEN
            LET p_des_texto = "COFINS: ", p_pct_cofins USING "<<&.&&", "% = R$ ", p_valor_cofins USING "<<,<<<,<#&.&&"
         ELSE
            LET p_des_texto = p_des_texto CLIPPED, ' - ','        ', 
                "COFINS: ", p_pct_cofins USING "<<&.&&", "% = R$ ", p_valor_cofins USING "<<,<<<,<#&.&&"
         END IF
      END IF
      
      IF p_des_texto IS NOT NULL THEN
         CALL pol0703_insert_array(p_des_texto,4)
      END IF
   END IF   

   IF ((p_clientes.ies_zona_franca = "S" OR p_clientes.ies_zona_franca = "A") AND
        p_clientes.num_suframa > 0 AND p_wfat_mestre.val_desc_merc > 0) THEN
      LET p_des_texto = "R$ ",p_wfat_mestre.val_desc_merc USING "<<,<<<,<#&.&&",
                        " - ", p_wfat_mestre.pct_icm USING "#&.&", 
                        " % ICMS COMO SE DEVIDO FOSSE"
      CALL pol0703_insert_array(p_des_texto,4)

      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&"
      CALL pol0703_insert_array(p_des_texto,4)
   END IF   

END FUNCTION

#----------------------------------#
FUNCTION pol0703_trata_consignacao()
#-----------------------------------#  
  DEFINE l_num_nff_ref  DECIMAL (6,0),
         l_dat_emissao  DATE 

   DECLARE cq_consig CURSOR FOR
      SELECT UNIQUE num_nff_ref
        FROM nf_consig_ref
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_wfat_mestre.num_nff
   FOREACH cq_consig INTO l_num_nff_ref
      LET p_des_texto = NULL
      SELECT dat_emissao 
        INTO l_dat_emissao
        FROM nf_mestre 
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = l_num_nff_ref
      
      LET p_des_texto = "NOTA DE REMESSA: ",l_num_nff_ref CLIPPED," EMISSAO: ",l_dat_emissao

      IF p_des_texto IS NOT NULL THEN
         CALL pol0703_insert_array(p_des_texto,4)
      END IF
            
   END FOREACH      

END FUNCTION

#-----------------------------------#
FUNCTION pol0703_carrega_corpo_nota()
#-----------------------------------#

   DEFINE i,j          SMALLINT,
          p_pes_unit   LIKE item.pes_unit,    
          p_pes_tot    LIKE item.pes_unit
          
   LET p_num_seq = 0               

   FOR i = 1 TO 999

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF
      
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    1,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item1,
                                    pa_corpo_nff[i].cod_fiscal,
                                    pa_corpo_nff[i].onu,
                                    pa_corpo_nff[i].risco_abnt,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)

      INSERT INTO base_icms_temp VALUES (pa_corpo_nff[i].pct_icm,pa_corpo_nff[i].val_liq_item)

      IF pa_corpo_nff[i].den_item2 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item2,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item22 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item22,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item23 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item23,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item24 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item24,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item25 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item25,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item26 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item26,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item27 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item27,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item28 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item28,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item29 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item29,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF pa_corpo_nff[i].den_item210 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item210,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF


      IF pa_corpo_nff[i].den_item3 IS NOT NULL THEN                                 
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item3,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)                                    
      END IF
      IF pa_corpo_nff[i].den_item4 IS NOT NULL THEN
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                    2,
                                    pa_corpo_nff[i].cod_item,
                                    pa_corpo_nff[i].den_item4,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    pa_corpo_nff[i].cod_cla_fisc,     
                                    pa_corpo_nff[i].cod_origem,
                                    pa_corpo_nff[i].cod_tributacao,
                                    pa_corpo_nff[i].pes_unit,
                                    pa_corpo_nff[i].cod_unid_med,
                                    pa_corpo_nff[i].qtd_item,
                                    pa_corpo_nff[i].pre_unit,
                                    pa_corpo_nff[i].val_liq_item,
                                    pa_corpo_nff[i].pct_icm,
                                    pa_corpo_nff[i].pct_ipi,
                                    pa_corpo_nff[i].val_ipi,
                                    NULL,NULL)
      END IF

      IF p_nat_operacao.ies_tip_controle = "2" THEN
            
         LET p_pes_tot = pa_corpo_nff[i].pes_unit *  pa_corpo_nff[i].qtd_item
      
         IF p_wfat_mestre.ies_origem = 'P' THEN      
            DECLARE cq_num_ct CURSOR FOR
            SELECT den_motivo_remessa
              FROM item_em_terc a,
                   motivo_remessa b
             WHERE a.cod_empresa        = b.cod_empresa 
               AND a.cod_motivo_remessa = b.cod_motivo_remessa
               AND a.cod_empresa        = p_cod_empresa            
               AND a.num_sequencia      = pa_corpo_nff[i].num_sequencia
               AND a.num_nf             = p_wfat_mestre.num_nff
 
            FOREACH cq_num_ct INTO p_den_motivo_remessa

              LET p_des_texto = "PEDIDO : ", p_den_motivo_remessa , "   Peso :  "  , p_pes_tot
         	
              LET p_num_seq = p_num_seq + 1
              #INSERT INTO wnotalev VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
              #                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
              #                             p_des_texto,NULL)
            END FOREACH
         ELSE
            LET p_des_texto = "Peso :  "  , p_pes_tot
         	
            LET p_num_seq = p_num_seq + 1
            #INSERT INTO wnotalev VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
            #                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
            #                             p_des_texto,NULL)
         END IF
      END IF   
   END FOR

END FUNCTION

#----------------------------------#
FUNCTION pol0703_retorno_terceiro()
#----------------------------------#

   INITIALIZE p_des_texto TO NULL
   
   DECLARE cq_ret_terc CURSOR FOR
    SELECT a.num_nf,
           b.cod_item,
           a.qtd_devolvida,
           b.dat_emis_nf,
           b.cod_unid_med,
           b.val_remessa,
           b.qtd_tot_recebida
      FROM item_dev_terc a,
           item_de_terc b
      WHERE a.cod_empresa    = p_cod_empresa
        AND a.num_nf_retorno = p_nff.num_nff
        AND b.cod_empresa    = a.cod_empresa
        AND b.num_nf         = a.num_nf
        AND b.ser_nf         = a.ser_nf
        AND b.ssr_nf         = a.ssr_nf
        AND b.ies_especie_nf = a.ies_especie_nf
        AND b.cod_fornecedor = a.cod_fornecedor
        AND b.num_sequencia  = a.num_sequencia

   FOREACH cq_ret_terc INTO p_num_nf,
                            p_cod_item,
                            p_qtd_devolvida,
                            p_dat_emis_nf,
                            p_unid_med,
                            p_val_remessa,
                            p_qtd_remessa
     
      LET p_des_texto = " "
      CALL pol0703_insert_array(p_des_texto,3)
      
      IF p_des_texto IS NULL THEN
         LET p_des_texto = "MATERIAL DE SUA PROPRIEDADE QUE NOS FOI ENVIADO E QUE ORA DEVOLVEMOS:"
         CALL pol0703_insert_array(p_des_texto,3)
      END IF

      LET p_val_unit = p_val_remessa / p_qtd_remessa
      LET p_val_mat_dev = p_qtd_devolvida * p_val_unit

      LET p_des_texto = p_cod_item," ",p_qtd_devolvida," ", p_unid_med CLIPPED," ",
                        p_val_unit," ",p_val_mat_dev," S/NF:",
                        p_num_nf USING "&&&&&&"," - ",p_dat_emis_nf USING 'dd/mm/yy'                               
      
      CALL pol0703_insert_array(p_des_texto,3)        

   END FOREACH
            
END FUNCTION

#-----------------------------------------#
FUNCTION pol0703_calcula_total_de_paginas()
#-----------------------------------------#

   INITIALIZE p_tot_paginas TO NULL
   
   SELECT COUNT(*)
     INTO p_num_linhas
     FROM wnotalev
    WHERE ies_tip_info <= 3 

   IF p_num_linhas > 0 THEN 
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 18 )) / 18 
 
      IF (p_num_linhas MOD 18 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_saltar_linhas = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0703_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM clientes, cidades, subst_trib_uf
    WHERE clientes.cod_cliente        = p_wfat_mestre.cod_cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
      AND subst_trib_uf.cod_empresa   = p_cod_empresa
      
END FUNCTION

#-----------------------------#
FUNCTION pol0703_den_nat_oper()
#-----------------------------#

   SELECT *
     INTO p_nat_operacao.*
     FROM nat_operacao
    WHERE cod_nat_oper = p_wfat_mestre.cod_nat_oper
 
   IF sqlca.sqlcode = 0 THEN 

      IF p_nat_operacao.ies_subst_tribut <> "S" THEN 
         LET p_nff.ins_estadual_trib = NULL
      END IF  

      RETURN p_nat_operacao.den_nat_oper
   ELSE 
      RETURN "NATUREZA NAO CADASTRADA"
   END IF 

END FUNCTION

#------------------------------------#
FUNCTION pol0703_busca_cof_compl()
#------------------------------------#

   LET p_cod_fiscal_compl = 0

   WHENEVER ERROR CONTINUE

      SELECT cod_fiscal_compl
        INTO p_cod_fiscal_compl
        FROM fiscal_par_compl
       WHERE cod_empresa   = p_cod_empresa
         AND cod_nat_oper  = p_wfat_mestre.cod_nat_oper
         AND cod_uni_feder = p_cidades.cod_uni_feder

       IF sqlca.sqlcode <> 0 THEN
          LET p_cod_fiscal_compl = 0
       END IF

   WHENEVER ERROR STOP

END FUNCTION

#------------------------------------#
FUNCTION pol0703_busca_dados_empresa()            
#------------------------------------#
   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
     INTO p_empresa.*
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   WHENEVER ERROR STOP
END FUNCTION
#---------------------------------#
FUNCTION pol0703_param_frt_auton()            
#---------------------------------#
   INITIALIZE p_tip_transp_auto TO NULL

   WHENEVER ERROR CONTINUE

   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF STATUS <> 0 THEN
      LET p_tip_transp_auto = '98'
   END IF

   WHENEVER ERROR STOP
END FUNCTION
#------------------------------#
FUNCTION pol0703_representante()
#------------------------------#
   DEFINE p_nom_guerra LIKE representante.nom_guerra

   SELECT nom_guerra
     INTO p_nom_guerra
     FROM representante
    WHERE cod_repres = p_wfat_mestre.cod_repres

   RETURN p_nom_guerra
   
END FUNCTION
 
#-----------------------------#
FUNCTION pol0703_especie(p_ind)
#-----------------------------#

   DEFINE p_des_especie CHAR(30),
          p_ind         INTEGER

   WHENEVER ERROR CONTINUE
   CASE 
    WHEN p_ind = 1
         SELECT *
           INTO p_embalagem.*
           FROM embalagem
          WHERE cod_embal = p_wfat_mestre.cod_embal_1
    WHEN p_ind = 2
         SELECT *
           INTO p_embalagem.*
           FROM embalagem
          WHERE cod_embal = p_wfat_mestre.cod_embal_2
    WHEN p_ind = 3
         SELECT *
           INTO p_embalagem.*
           FROM embalagem
          WHERE cod_embal = p_wfat_mestre.cod_embal_3
    WHEN p_ind = 4
         SELECT *
           INTO p_embalagem.*
           FROM embalagem
          WHERE cod_embal = p_wfat_mestre.cod_embal_4
    WHEN p_ind = 5
         SELECT *
           INTO p_embalagem.*
           FROM embalagem
          WHERE cod_embal = p_wfat_mestre.cod_embal_5
   END CASE 
   WHENEVER ERROR STOP

   IF SQLCA.SQLCODE = 0 THEN 
      LET p_des_especie = p_embalagem.den_embal
   ELSE
      INITIALIZE p_des_especie TO NULL
   END IF

   RETURN p_des_especie

END FUNCTION 

#-----------------------------#
FUNCTION pol0703_den_cnd_pgto()
#-----------------------------#
   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(5,3)


   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,pct_desp_finan, ies_tipo
     INTO p_den_cnd_pgto,p_pct_desp_finan, p_ies_tipo_pgto
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_wfat_mestre.cod_cnd_pgto
   WHENEVER ERROR STOP
 
   IF p_pct_desp_finan IS NOT NULL
      AND p_pct_desp_finan > 1 THEN
      LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
      LET p_des_texto = "ENCARGO FINANCEIRO: ",  p_pct_enc_finan USING "#&.&&&"," %"
      CALL pol0703_insert_array(p_des_texto,3)
   END IF 

   RETURN p_den_cnd_pgto

END FUNCTION 

#--------------------------------------#
FUNCTION pol0703_busca_dados_clientes()
#--------------------------------------#

   INITIALIZE p_clientes.* TO NULL
   INITIALIZE p_cod_fornec_cliente TO NULL
   
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_wfat_mestre.cod_cliente
    
  SELECT cod_fornec_cliente
    INTO p_cod_fornec_cliente
    FROM cli_info_adic
   WHERE cod_cliente = p_wfat_mestre.cod_cliente

  {IF p_cod_fornec_cliente IS NOT NULL THEN 
     LET p_des_texto = "COD.FORNECEDOR: ", p_cod_fornec_cliente
     CALL pol0703_insert_array(p_des_texto,4)
  END IF}

END FUNCTION

#--------------------------------#
FUNCTION pol0703_busca_nome_pais()                   
#--------------------------------#
   INITIALIZE p_paises.* ,
              p_uni_feder.*    TO NULL 
 
   WHENEVER ERROR CONTINUE
   SELECT *  
     INTO p_uni_feder.*
     FROM uni_feder
    WHERE cod_uni_feder = p_cidades.cod_uni_feder      
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_paises.*
     FROM paises   
    WHERE cod_pais = p_uni_feder.cod_pais       
   WHENEVER ERROR STOP
END FUNCTION
 
#----------------------------------------------------#
FUNCTION pol0703_busca_dados_transport(p_cod_transpor)
#----------------------------------------------------#
   DEFINE p_cod_transpor  LIKE clientes.cod_cliente

   INITIALIZE p_transport.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_transport.*
     FROM clientes
    WHERE cod_cliente = p_cod_transpor
   WHENEVER ERROR STOP

END FUNCTION

#------------------------------------------------#
FUNCTION pol0703_busca_dados_cidades(p_cod_cidade)
#------------------------------------------------#
   DEFINE p_cod_cidade     LIKE cidades.cod_cidade

   INITIALIZE p_cidades.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_cidades.*
     FROM cidades
    WHERE cod_cidade = p_cod_cidade
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------#
FUNCTION pol0703_busca_dados_pedido()
#-----------------------------------#  

   INITIALIZE p_nff.num_pedido_repres,                       
              p_nff.num_pedido_cli   TO  NULL                    

   SELECT pedidos.num_pedido_repres, 
          pedidos.num_pedido_cli
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli
     FROM pedidos
    WHERE pedidos.cod_empresa = p_wfat_mestre.cod_empresa 
      AND pedidos.num_pedido  = p_wfat_item.num_pedido
  
END FUNCTION

#-----------------------------------------------#
FUNCTION pol0703_grava_dados_consig()
#-----------------------------------------------#

   INITIALIZE p_consignat.* TO NULL

   SELECT clientes.nom_cliente,
          clientes.end_cliente,
          clientes.den_bairro,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_consignat.*
     FROM clientes, 
          cidades
    WHERE clientes.cod_cliente = p_wfat_mestre.cod_consig
      AND clientes.cod_cidade  = cidades.cod_cidade

END FUNCTION

#------------------------------------------#
FUNCTION pol0703_grava_historico_nf_pedido()
#------------------------------------------#

   INITIALIZE p_des_texto1 TO NULL 
      
   IF p_wfat_mestre.cod_texto1 <> 0 OR
      p_wfat_mestre.cod_texto2 <> 0 OR   
      p_wfat_mestre.cod_texto3 <> 0 THEN
      DECLARE cq_texto_nf CURSOR FOR
       SELECT des_texto
         FROM texto_nf
        WHERE cod_texto IN (p_wfat_mestre.cod_texto1,
                            p_wfat_mestre.cod_texto2,
                            p_wfat_mestre.cod_texto3)

      FOREACH cq_texto_nf INTO p_des_texto1

         IF LENGTH(p_des_texto1)> 0 THEN 
            CALL pol0703_insert_array(p_des_texto1,4)
         END IF
      END FOREACH               
   END IF
 
END FUNCTION

#----------------------------#
FUNCTION pol0703_pega_lacre()
#----------------------------#

DEFINE l_num_solicit   LIKE frete_roma_885.num_solicit,
       l_num_sequencia LIKE frete_solicit_885.num_sequencia,
       l_obs           LIKE romaneio_885.numlacre,
       l_cod_emp       CHAR(02) 


  IF p_num_seq_fr IS NULL THEN 

      SELECT cod_emp_gerencial
        INTO p_cod_emp
        FROM empresas_885
       WHERE cod_emp_oficial = p_cod_empresa 
      
      SELECT num_solicit
        INTO p_num_solicit
        FROM frete_roma_885
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_num_om
         
      SELECT num_sequencia
        INTO l_num_sequencia    
        FROM frete_solicit_885
       WHERE cod_empresa = p_cod_empresa
         AND num_solicit = p_num_solicit
  ELSE
     LET l_num_sequencia = p_num_seq_fr
  END IF 
  
  INITIALIZE l_obs TO NULL 
       
  SELECT numlacre
    INTO l_obs
    FROM romaneio_885
   WHERE codempresa = p_cod_emp
     AND numsequencia = l_num_sequencia
  
  IF l_obs IS NOT NULL THEN 
     INITIALIZE p_des_texto  TO NULL          
     LET p_des_texto = l_obs
     CALL pol0703_insert_array(p_des_texto,4)
  END IF    
  
END FUNCTION

#---------------------------------------#
FUNCTION pol0703_checa_nf_contra_ordem()
#---------------------------------------#
DEFINE l_nom_cliente  LIKE clientes.nom_cliente,
       l_end_cliente  LIKE clientes.end_cliente,
       l_num_cgc_cpf  LIKE clientes.num_cgc_cpf,
       l_ins_estadual LIKE clientes.ins_estadual,
       l_dat_emissao  LIKE nf_mestre.dat_emissao

   DECLARE cq_nf_ref CURSOR FOR
    SELECT * 
      FROM nf_referencia
     WHERE cod_empresa  = p_cod_empresa
       AND num_pedido   = pa_corpo_nff[1].num_pedido
       AND num_nff_ref  = p_wfat_mestre.num_nff

   FOREACH cq_nf_ref INTO p_nf_referencia.*

      IF p_nf_referencia.num_nff IS NOT NULL THEN 
         SELECT a.nom_cliente,
                a.end_cliente,
                a.num_cgc_cpf,
                a.ins_estadual
           INTO l_nom_cliente,
                l_end_cliente,
                l_num_cgc_cpf,
                l_ins_estadual
           FROM clientes a, nf_mestre b
          WHERE b.cod_empresa =  p_nf_referencia.cod_empresa
            AND b.num_nff     =  p_nf_referencia.num_nff
            AND a.cod_cliente =  b.cod_cliente
         INITIALIZE p_des_texto  TO NULL          
         LET p_des_texto = "Mercadoria de propriedade da "
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = l_nom_cliente
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = l_end_cliente
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = 'CNPJ ',l_num_cgc_cpf, ' IE: ',l_ins_estadual
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = 'Adquirida pela NF ',p_nf_referencia.num_nff USING "&&&&&&",
             " DE ", p_wfat_mestre.dat_emissao,'.'
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET  p_des_texto = "Pela qual os impostos foram pagos."
         CALL pol0703_insert_array(p_des_texto,4)
      END IF

   END FOREACH               

   DECLARE cq_nf_rem CURSOR FOR
    SELECT * 
      FROM nf_referencia
     WHERE cod_empresa  = p_cod_empresa
       AND num_pedido   = pa_corpo_nff[1].num_pedido
       AND num_nff  = p_wfat_mestre.num_nff

   FOREACH cq_nf_rem INTO p_nf_referencia.*
      
      IF p_nf_referencia.num_nff_ref IS NOT NULL THEN 
         SELECT a.nom_cliente,
                a.end_cliente,
                a.num_cgc_cpf,
                a.ins_estadual,
                b.dat_emissao
           INTO l_nom_cliente,
                l_end_cliente,
                l_num_cgc_cpf,
                l_ins_estadual,
                l_dat_emissao
           FROM clientes a, nf_mestre b
          WHERE b.cod_empresa =  p_nf_referencia.cod_empresa
            AND b.num_nff     =  p_nf_referencia.num_nff_ref
            AND a.cod_cliente =  b.cod_cliente
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = "Mercadoria enviada a sua ordem a "
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = l_nom_cliente
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = l_end_cliente
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = 'CNPJ ',l_num_cgc_cpf, ' IE: ',l_ins_estadual
         CALL pol0703_insert_array(p_des_texto,4)
         INITIALIZE p_des_texto  TO NULL
         LET p_des_texto = 'Atraves da NF ', p_nf_referencia.num_nff_ref USING "&&&&&&",
             " DE ", l_dat_emissao
         CALL pol0703_insert_array(p_des_texto,4)
      END IF

   END FOREACH               
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0703_verifica_texto_ped_it()
#---------------------------------------#

   INITIALIZE pa_texto_ped_it TO NULL

   INITIALIZE p_ped_itens_texto.* TO NULL
   
{   SELECT des_esp_item[1,30]
     INTO pa_texto_ped_it[1].texto
     FROM item_esp        
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_wfat_item.cod_item
      AND num_seq     = 1}

   SELECT *
     INTO p_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_wfat_item.num_pedido
      AND num_sequencia = p_wfat_item.num_sequencia

      IF p_ped_itens_texto.den_texto_1 IS NOT NULL THEN 
         LET pa_texto_ped_it[1].texto = p_ped_itens_texto.den_texto_1
      END IF 
      IF p_ped_itens_texto.den_texto_2 IS NOT NULL THEN 
         LET pa_texto_ped_it[2].texto = p_ped_itens_texto.den_texto_2 
      END IF 
      IF p_ped_itens_texto.den_texto_3 IS NOT NULL THEN 
         LET pa_texto_ped_it[3].texto = p_ped_itens_texto.den_texto_3
      END IF 
      IF p_ped_itens_texto.den_texto_4 IS NOT NULL THEN 
         LET pa_texto_ped_it[4].texto = p_ped_itens_texto.den_texto_4
      END IF 
      IF p_ped_itens_texto.den_texto_5 IS NOT NULL THEN 
         LET pa_texto_ped_it[5].texto = p_ped_itens_texto.den_texto_5
      END IF 

END FUNCTION

#------------------------------------------------#
FUNCTION pol0703_insert_array(p_des_texto, p_info)
#------------------------------------------------#

   DEFINE p_des_texto CHAR(120),
          p_info      SMALLINT
   
   LET p_tip_info = p_info
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotalev
      VALUES (p_num_seq,p_tip_info,NULL,NULL,NULL,NULL,NULL,
              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
              NULL,NULL,NULL,p_des_texto,NULL)

END FUNCTION   

#-----------------------------#
REPORT pol0703_relat(p_num_nff)
#-----------------------------#

   DEFINE i            SMALLINT,
          l_nulo       CHAR(10),
          p_nf_ant     DECIMAL(7,0),
          p_cont_nf_rt SMALLINT,
          p_num_nff    LIKE wfat_mestre.num_nff

   DEFINE p_for        SMALLINT,
          p_sal        SMALLINT,
          p_des_folha  CHAR(100),
          p_imp_desc   SMALLINT

   
   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   68

   ORDER EXTERNAL BY p_num_nff
  
   FORMAT

      PAGE HEADER
      LET p_imp_desc = 0
    
      LET p_num_pagina = p_num_pagina + 1
      PRINT p_8lpp, p_comprime
      PRINT COLUMN 001, p_txt[1].texto

      PRINT COLUMN 001, p_txt[2].texto,
            COLUMN 191, p_nff.num_nff USING "&&&&&&"            

      PRINT COLUMN 001, p_txt[3].texto,
            COLUMN 154, "X"
                       
       
      PRINT COLUMN 001, p_txt[4].texto

      PRINT COLUMN 001, p_txt[5].texto

      PRINT COLUMN 001, p_txt[6].texto

      PRINT COLUMN 001, p_txt[7].texto

      PRINT COLUMN 001, p_txt[8].texto
 
#      PRINT COLUMN 001, p_txt[9].texto

      IF p_nff.cod_fiscal1 IS NOT NULL THEN
          
          PRINT COLUMN 001, p_txt[9].texto,
                COLUMN 060, p_nff.den_nat_oper[1,12] CLIPPED,"/",p_nff.den_nat_oper1[1,12],
                COLUMN 104, p_nff.cod_fiscal         USING "&&&&",
                COLUMN 108, "/",
                COLUMN 109, p_nff.cod_fiscal1        USING "&&&&",
                COLUMN 120, p_nff.ins_estadual_trib    
      ELSE
          PRINT COLUMN 001, p_txt[9].texto, 
                COLUMN 060, p_nff.den_nat_oper[1,30],
                COLUMN 104, p_nff.cod_fiscal         USING "&&&&",
                COLUMN 120, p_nff.ins_estadual_trib
      END IF 

      PRINT COLUMN 001, p_txt[10].texto

      PRINT COLUMN 001, p_txt[11].texto

      PRINT COLUMN 001, p_txt[12].texto

      PRINT COLUMN 001, p_txt[13].texto,
            COLUMN 060, p_nff.nom_destinatario, 
            COLUMN 151, p_nff.num_cgc_cpf,
            COLUMN 187, p_nff.dat_emissao USING "DD/MM/YYYY"

      PRINT COLUMN 001, p_txt[14].texto
            
      PRINT COLUMN 001, p_txt[15].texto,
            COLUMN 060, p_nff.end_destinatario,
            COLUMN 132, p_nff.den_bairro,
            COLUMN 167, p_nff.cod_cep
            #COLUMN 071, TODAY USING "DD/MM/YYYY"

      PRINT COLUMN 001, p_txt[16].texto      

      PRINT COLUMN 001, p_txt[17].texto,      
            COLUMN 060, p_nff.den_cidade[1,22],
            COLUMN 116, p_nff.num_telefone[1,13],
            COLUMN 143, p_nff.cod_uni_feder,
            COLUMN 160, p_nff.ins_estadual
            #COLUMN 071, TIME

      PRINT COLUMN 001, p_txt[18].texto      

      IF (p_num_pagina=1 AND p_tot_paginas >=1) THEN

         IF p_nff.num_duplic2 IS NULL THEN 
            IF p_nff.ies_tipo_pgto  = 'A'  
            OR p_nff.ies_tipo_pgto  = 'V'
            OR p_nff.ies_tipo_pgto  = 'C'  THEN 
               PRINT COLUMN 001, p_txt[19].texto,
                     COLUMN 159, p_cod_empresa,      
                     COLUMN 161, p_nff.num_duplic1    USING "&&&&&&",
                     COLUMN 167, p_nff.dig_duplic1    USING "&&",
                     COLUMN 175, p_nff.den_cnd_pgto[1,10],
                     COLUMN 185, p_nff.val_duplic1    USING "###,###,##&.&&"
               PRINT COLUMN 001, p_txt[20].texto,                 
                     COLUMN 070, p_nff.val_extenso1[1,80]
               PRINT COLUMN 001, p_txt[21].texto,                 
                    COLUMN 070, p_nff.val_extenso2[1,80]                     
               PRINT COLUMN 001, p_txt[22].texto    
            ELSE  
               PRINT COLUMN 001, p_txt[19].texto,
                     COLUMN 159, p_cod_empresa,      
                     COLUMN 161, p_nff.num_duplic1    USING "&&&&&&",
                     COLUMN 167, p_nff.dig_duplic1    USING "&&",
                     COLUMN 175, p_nff.dat_vencto_sd1 USING "DD/MM/YY",
                     COLUMN 185, p_nff.val_duplic1    USING "###,###,##&.&&"
               PRINT COLUMN 001, p_txt[20].texto,                 
                     COLUMN 070, p_nff.val_extenso1[1,80]
               PRINT COLUMN 001, p_txt[21].texto,                 
                    COLUMN 070, p_nff.val_extenso2[1,80]                     
               PRINT COLUMN 001, p_txt[22].texto    
            END IF                  
         ELSE
            IF p_nff.num_duplic3 IS NULL THEN 
               PRINT COLUMN 001, p_txt[19].texto,               
                     COLUMN 159, p_cod_empresa,      
                     COLUMN 161, p_nff.num_duplic1    USING "&&&&&&",
                     COLUMN 167, p_nff.dig_duplic1    USING "&&",
                     COLUMN 175, p_nff.dat_vencto_sd1 USING "DD/MM/YY",
                     COLUMN 185, p_nff.val_duplic1    USING "###,###,##&.&&"
               PRINT COLUMN 001, p_txt[20].texto,               
                     COLUMN 070, p_nff.val_extenso1[1,80],
                     COLUMN 159, p_cod_empresa,      
                     COLUMN 161, p_nff.num_duplic2    USING "&&&&&&",
                     COLUMN 167, p_nff.dig_duplic2    USING "&&",
                     COLUMN 175, p_nff.dat_vencto_sd2 USING "DD/MM/YY",
                     COLUMN 185, p_nff.val_duplic2    USING "###,###,##&.&&"
               PRINT COLUMN 001, p_txt[21].texto,                 
                     COLUMN 070, p_nff.val_extenso2[1,80]
               PRINT COLUMN 001, p_txt[22].texto                 
            ELSE
               IF p_nff.num_duplic4 IS NULL THEN 
                  PRINT COLUMN 001, p_txt[19].texto,        
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic1    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic1    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd1 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic1    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[20].texto,               
                        COLUMN 070, p_nff.val_extenso1[1,80],
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic2    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic2    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd2 USING "DD/MM/YY", 
                        COLUMN 185, p_nff.val_duplic2    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[21].texto,                 
                        COLUMN 070, p_nff.val_extenso2[1,80],    
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic3    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic3    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd3 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic3    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[22].texto
               ELSE
                  PRINT COLUMN 001, p_txt[19].texto,        
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic1    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic1    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd1 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic1    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[20].texto,               
                        COLUMN 070, p_nff.val_extenso1[1,80],
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic2    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic2    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd2 USING "DD/MM/YY", 
                        COLUMN 185, p_nff.val_duplic2    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[21].texto,                 
                        COLUMN 070, p_nff.val_extenso2[1,80],    
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic3    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic3    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd3 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic3    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[22].texto,                 
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic4    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic4    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd4 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic4    USING "###,###,##&.&&"
               END IF
            END IF
         END IF
      ELSE      
            IF p_nff.num_duplic6 IS NULL THEN 
               PRINT COLUMN 001, p_txt[19].texto,      
                     COLUMN 159, p_cod_empresa,      
                     COLUMN 161, p_nff.num_duplic5      USING "&&&&&&",
                     COLUMN 167, p_nff.dig_duplic5    USING "&&",
                     COLUMN 175, p_nff.dat_vencto_sd5   USING "DD/MM/YY",
                     COLUMN 185, p_nff.val_duplic5      USING "###,###,##&.&&"
               PRINT COLUMN 001, p_txt[20].texto,                 
                     COLUMN 068, p_nff.val_extenso1[1,80]
               PRINT COLUMN 001, p_txt[21].texto,                 
                     COLUMN 068, p_nff.val_extenso2[1,80]                     
               PRINT COLUMN 001, p_txt[22].texto                 
            ELSE
               IF p_nff.num_duplic7 IS NULL THEN 
                  PRINT COLUMN 001, p_txt[19].texto,               
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic5    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic5    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd5 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic5    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[20].texto,               
                        COLUMN 068, p_nff.val_extenso1[1,80],
                        COLUMN 159, p_cod_empresa,      
                        COLUMN 161, p_nff.num_duplic6    USING "&&&&&&",
                        COLUMN 167, p_nff.dig_duplic6    USING "&&",
                        COLUMN 175, p_nff.dat_vencto_sd6 USING "DD/MM/YY",
                        COLUMN 185, p_nff.val_duplic6    USING "###,###,##&.&&"
                  PRINT COLUMN 001, p_txt[21].texto,                 
                        COLUMN 068, p_nff.val_extenso2[1,80]
                  PRINT COLUMN 001, p_txt[22].texto                 
               ELSE
                  IF p_nff.num_duplic8 IS NULL THEN 
                     PRINT COLUMN 001, p_txt[19].texto,        
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic5    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic5    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd5 USING "DD/MM/YY",
                           COLUMN 185, p_nff.val_duplic5    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[20].texto,               
                           COLUMN 068, p_nff.val_extenso1[1,80],
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic6    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic6    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd6 USING "DD/MM/YY", 
                           COLUMN 185, p_nff.val_duplic6    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[21].texto,                 
                           COLUMN 068, p_nff.val_extenso2[1,80],    
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic7    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic7    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd7 USING "DD/MM/YY",
                           COLUMN 185, p_nff.val_duplic7    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[22].texto
                  ELSE
                     PRINT COLUMN 001, p_txt[19].texto,        
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic5    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic5    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd5 USING "DD/MM/YY",
                           COLUMN 185, p_nff.val_duplic5    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[20].texto,               
                           COLUMN 068, p_nff.val_extenso1[1,80],
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic6    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic6    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd6 USING "DD/MM/YY", 
                           COLUMN 185, p_nff.val_duplic6    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[21].texto,                 
                           COLUMN 068, p_nff.val_extenso2[1,80],    
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic7    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic7    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd7 USING "DD/MM/YY",
                           COLUMN 185, p_nff.val_duplic7    USING "###,###,##&.&&"
                     PRINT COLUMN 001, p_txt[22].texto,                 
                           COLUMN 159, p_cod_empresa,      
                           COLUMN 161, p_nff.num_duplic8    USING "&&&&&&",
                           COLUMN 167, p_nff.dig_duplic8    USING "&&",
                           COLUMN 175, p_nff.dat_vencto_sd8 USING "DD/MM/YY",
                           COLUMN 185, p_nff.val_duplic8    USING "###,###,##&.&&"
                  END IF
               END IF  
            END IF
         END IF
      
#      PRINT COLUMN 001, p_txt[23].texto
      
      IF p_nff.cod_cep_cli IS NOT NULL THEN
         PRINT COLUMN 001, p_txt[23].texto,
               COLUMN 060, p_nff.end_cobr_cli CLIPPED," - ",p_nff.den_cidade_cli CLIPPED," - ",p_nff.cod_uni_feder_cli CLIPPED,
                           " - CEP: ", p_nff.cod_cep_cli
      ELSE
         PRINT COLUMN 001, p_txt[23].texto
      END IF
      IF p_cod_empresa = '01' THEN 
         PRINT COLUMN 002, '** NOVO TELEFONE - (21) 30178787 **' 
      ELSE
         PRINT
      END IF 
          
      SKIP 3 LINES
      
   BEFORE GROUP OF p_num_nff

      SKIP TO TOP OF PAGE

   ON EVERY ROW

      INITIALIZE p_den_item, p_cod_item_cliente TO NULL
      
      CASE
         WHEN p_wnotalev.ies_tip_info = 1   
            PRINT COLUMN 001, p_wnotalev.cod_item,
                  COLUMN 023, p_wnotalev.den_item,
#                  COLUMN 108, p_cod_cla_reduz,
                  COLUMN 109, p_cod_ref_clas,
                  COLUMN 117, p_wnotalev.cod_origem     USING "&",
                  COLUMN 118, p_wnotalev.cod_tributacao USING "&&",
                  COLUMN 124, p_wnotalev.cod_unid_med,
                  COLUMN 133, p_wnotalev.qtd_item       USING "##,##&.&&&",
                  COLUMN 146, p_wnotalev.pre_unit       USING "#,###,##&.&&&&&&";
       
            IF p_nff.cod_uni_feder = "AM" AND 
               (p_clientes.ies_zona_franca = "S" OR p_clientes.ies_zona_franca = "A") THEN
               PRINT COLUMN 166, p_wnotalev.val_liq_item USING "###,###,##&.&&",
                     COLUMN 184, p_wfat_mestre.pct_icm USING "#&"
            ELSE  
               PRINT COLUMN 166, p_wnotalev.val_liq_item USING "###,###,##&.&&",
                     COLUMN 184, p_wnotalev.pct_icm USING "#&",
                     COLUMN 189, p_wnotalev.pct_ipi USING "#&",
                     COLUMN 191, p_wnotalev.val_ipi USING "###,###&.&&"
            END IF
            LET p_linhas_print = p_linhas_print + 1
        
         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 030, p_wnotalev.den_item[1,55]
            LET p_linhas_print = p_linhas_print + 1
  
         WHEN p_wnotalev.ies_tip_info = 3
            PRINT
            IF p_wnotalev.des_texto IS NOT NULL THEN
               PRINT COLUMN 022, p_wnotalev.des_texto 
               LET p_linhas_print = p_linhas_print + 1
            END IF
  
         WHEN p_wnotalev.ies_tip_info = 5
            WHILE TRUE
               IF p_linhas_print < 18 THEN 
                  PRINT 
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF   
            END WHILE         
                    
      END CASE
      #---------------------------------------------------------------------------
      IF p_linhas_print = 18 THEN { nr. de linhas do corpo da nota }
         IF p_num_pagina = p_tot_paginas THEN 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&" 
         ELSE 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&"," - Continua" 
         END IF
         IF p_num_pagina = p_tot_paginas THEN
            #PRINT
            PRINT COLUMN 023, p_des_folha 
            PRINT
            PRINT
            PRINT COLUMN 008, p_nff.val_tot_base_icm    USING "###,###,##&.&&",
                  COLUMN 036, p_nff.val_tot_icm         USING "###,###,##&.&&",
                  COLUMN 064, p_nff.val_tot_base_ret    USING "###,###,##&.&&",
                  COLUMN 090, p_nff.val_tot_icm_ret     USING "###,###,##&.&&",
                  COLUMN 118, p_nff.val_tot_mercadoria  USING "###,###,##&.&&"
            SKIP 1 LINES
            PRINT COLUMN 008, p_nff.val_frete_cli       USING "###,###,##&.&&", 
                  COLUMN 036, p_nff.val_seguro_cli      USING "###,###,##&.&&",
                  COLUMN 064, p_nff.val_tot_despesas    USING "###,###,##&.&&",
                  COLUMN 090, p_nff.val_tot_ipi         USING "###,###,##&.&&",
                  COLUMN 118, p_nff.val_tot_nff         USING "###,###,##&.&&"
            SKIP 2 LINES
            PRINT COLUMN 001, p_nff.nom_transpor,                  
                  COLUMN 075, p_nff.ies_frete           USING "&",
                  COLUMN 086, p_nff.num_placa,
                  COLUMN 100, p_nff.cod_uni_feder_trans,
                  COLUMN 118, p_nff.num_cgc_trans
            SKIP 1 LINES
            PRINT COLUMN 001, p_nff.end_transpor[1,32],
                  COLUMN 065, p_nff.den_cidade_trans[1,22],   
                  COLUMN 100, p_nff.cod_uni_feder_trans,
                  COLUMN 121, p_nff.ins_estadual_trans   
            SKIP 1 LINES
            PRINT COLUMN 008, p_nff.qtd_volumes, 
                  COLUMN 020, p_nff.des_especie1,
                  COLUMN 052, p_nff.den_marca,
                  #COLUMN 082, p_nff.num_nff          USING "&&&&&&",
                  COLUMN 099, p_nff.pes_tot_bruto    USING "###,##&.&&&",
                  COLUMN 119, p_nff.pes_tot_liquido  USING "###,##&.&&&"
            LET p_num_pagina = 0
            SKIP 3 LINES
            PRINT COLUMN 183, p_nff.num_nff USING "&&&&&&" 
            SKIP 3 LINES    
         ELSE
            #PRINT
            PRINT COLUMN 023, p_des_folha 
            PRINT
            PRINT
            PRINT COLUMN 008, "**************",
                  COLUMN 036, "**************",
                  COLUMN 064, "**************",
                  COLUMN 090, "**************",
                  COLUMN 118, "**************"
            SKIP 1 LINES
            PRINT COLUMN 008, "**************", 
                  COLUMN 036, "**************",
                  COLUMN 064, "**************",
                  COLUMN 090, "**************",
                  COLUMN 118, "**************"
            SKIP 11 LINES
            PRINT COLUMN 183, p_nff.num_nff USING "&&&&&&"
            SKIP 5 LINES
         END IF
         LET p_linhas_print = 0
      END IF
END REPORT

#------------------------------- FIM DE PROGRAMA ------------------------------#

