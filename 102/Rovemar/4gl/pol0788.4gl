#---------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: POL0788                                                         #
# MODULOS.: POL0788  - LOG0010 - LOG0040 - LOG0050 - LOG0060                #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                          #
# OBJETIVO: IMPRESSAO DAS NOTAS FISCAIS FATURA - SAIDA - ROVEMAR            #
# AUTOR...: POLO INFORMATICA                                                #
# DATA....: 16/09/2008                                                      #
# ALTERADO: 16/09/2008 por ANA PAULA - versao 00	                          #
#---------------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_caminho                CHAR(80),
          p_ies_impressao          CHAR(01),
          comando                  CHAR(80),
          p_cod_texto              LIKE fiscal_hist.cod_hist,
          p_cod_item_cliente       LIKE cliente_item.cod_item_cliente,
          g_cod_item_cliente       LIKE cliente_item.cod_item_cliente,
          g_tex_complementar       LIKE cliente_item.tex_complementar,
          p_val_duplic             LIKE wfat_duplic.val_duplic,
          p_cod_moeda              LIKE pedidos.cod_moeda,
          p_ies_situacao           LIKE nf_mestre.ies_situacao,
          p_imprime_nf             SMALLINT,
          p_val_cotacao            DECIMAL(12,2),
          p_val_cotacao_imp        CHAR(20),
          p_den_nat_oper           CHAR(60),
          p_val_tot_nf             DECIMAL(15,2), 
          p_val_mo                 DECIMAL(15,2), 
          p_ies_bene               SMALLINT,
          p_clientes_oclinha       SMALLINT,
          p_num_oclinha            CHAR(15),
          p_qtd_itens              SMALLINT,
          p_salto                  SMALLINT,
          p_campo_pis              CHAR(30),
          p_campo_cofins           CHAR(30),
          p_des_especie            CHAR(20), 
          p_qtd_volumes            CHAR(30),
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
          p_linha                  SMALLINT,
          p_cont_ind               SMALLINT,
          p_count                  SMALLINT,
          p_posi                   SMALLINT,
          p_qtd_carac              SMALLINT,
          p_ret_embal              SMALLINT,
          p_desc_suframa           DECIMAL(5,3),
          p_ies_lote               CHAR(01),
          l_cla_fisc_nff           CHAR(02),
          p_reimpressao            CHAR(01),
          p_den_item2              CHAR(52),
          p_den_item5              CHAR(52),
          p_den_item6              CHAR(52),
          p_den_item7              CHAR(52),
          p_den_item8              CHAR(52),
          p_den_item9              CHAR(52),
          p_den_item10             CHAR(52),
          p_den_item11             CHAR(52),
          p_den_item12             CHAR(52),
          p_den_item13             CHAR(52),
          p_den_item14             CHAR(52),
          p_den_item15             CHAR(52),
          p_num_nff_ini            LIKE nf_mestre.num_nff,       
          p_num_nff_fim            LIKE nf_mestre.num_nff,       
          p_num_lote               CHAR(37),                        
          p_num_lot                CHAR(15),                        
          p_num_reserva            LIKE ordem_montag_grade.num_reserva,
          p_cod_fiscal             LIKE nf_mestre.cod_fiscal,    
          p_qtd_tot_recebida       LIKE item_de_terc.qtd_tot_recebida,
          p_num_nf_retorno         LIKE item_dev_terc.num_nf_retorno,
          p_qtd_devolvida          LIKE item_dev_terc.qtd_devolvida,
          p_qtd_txt                CHAR(10),
          p_ies_especie_nf         LIKE item_dev_terc.ies_especie_nf,
          p_qtd_tot_dev            DECIMAL(10,3),
          p_qtd_devolve            LIKE item_dev_terc.qtd_devolvida,
          p_num_sequencia          LIKE item_dev_terc.num_sequencia,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_cod_fornecedor         LIKE nf_sup.cod_fornecedor,
          p_dat_emis_nf            LIKE nf_sup.dat_emis_nf,
          p_val_remessa            LIKE item_de_terc.val_remessa,
          p_val_mat_dev            DECIMAL(13,2),
          p_val_tot_mat            DECIMAL(13,2),
          p_qtd_remessa            LIKE item_de_terc.qtd_tot_recebida,
          p_cod_material           LIKE item.cod_item,
          p_cod_unid_med           LIKE item.cod_unid_med,
          p_den_material           LIKE item.den_item_reduz,
          p_val_tot_nf_d           LIKE nf_sup.val_tot_nf_d,      
          p_cod_nat_oper           LIKE nat_operacao.cod_nat_oper,
          p_den_item_reduz         LIKE item.den_item_reduz, 
          p_den_item               CHAR(52),
          p_qtd_item               LIKE nf_item.qtd_item,
          p_pre_unit_nf            LIKE nf_item.pre_unit_nf,
          p_pre_tot_nf             LIKE nf_mestre.val_tot_nff,
          p_unid_med               LIKE item.cod_unid_med, 
          p_den_motivo_remessa     LIKE motivo_remessa.den_motivo_remessa,
          p_cod_fiscal_compl       DECIMAL(1,0),
          p_unid_terc              CHAR(03),
          p_item_cliente           LIKE item.cod_item,
          p_den_item_cli           LIKE item.den_item_reduz,
          p_val_unit               DECIMAL(12,6),
          p_cod_item               LIKE wfat_item.cod_item,
          p_num_pedido             CHAR(25),
          p_txt_ped                CHAR(25),
          p_txta                   CHAR(90),
          p_txtb                   CHAR(90),
          p_todos_textos           CHAR(416)
          
   DEFINE p_wfat_mestre          RECORD LIKE wfat_mestre.*,
          p_wfat_item            RECORD LIKE wfat_item.*,
          p_nf_item_fiscal       RECORD LIKE nf_item_fiscal.*,
          p_wfat_item_fiscal     RECORD LIKE wfat_item_fiscal.*,
          p_wfat_historico       RECORD LIKE wfat_historico.*,
          p_fiscal_hist          RECORD LIKE fiscal_hist.*,
          p_cidades              RECORD LIKE cidades.*,
          p_nf_carga             RECORD LIKE nf_carga.*,
          p_empresa              RECORD LIKE empresa.*,
          p_embalagem            RECORD LIKE embalagem.*,
          p_clientes             RECORD LIKE clientes.*,
          p_paises               RECORD LIKE paises.*,
          p_uni_feder            RECORD LIKE uni_feder.*,
          p_transport            RECORD LIKE clientes.*,
          p_ped_itens_texto      RECORD LIKE ped_itens_texto.*,
          p_fator_cv_unid        RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf        RECORD LIKE subst_trib_uf.*,
          p_nat_operacao         RECORD LIKE nat_operacao.*,
          p_cli_end_cobr         RECORD LIKE cli_end_cob.*,
          p_pedidos              RECORD LIKE pedidos.*,
          p_tipo_venda           RECORD LIKE tipo_venda.*,
          p_par_vdp_pad          RECORD LIKE par_vdp_pad.*,
          p_nf_referencia        RECORD LIKE nf_referencia.*

   {variaveis utilizadas para separar textos longos. Na NF }
   {é possivel imprimir até 75 caracteres por linha de texto}
   
   DEFINE p_texto_1          CHAR(75),
          p_texto_2          CHAR(75),
          p_texto_3          CHAR(75),
          p_texto_4          CHAR(75)
   #--------------------------------------------------------#
   
   DEFINE p_nff       
          RECORD
             num_nff             LIKE wfat_mestre.num_nff,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             den_nat_oper1       LIKE nat_operacao.den_nat_oper, 
             cod_fiscal          LIKE wfat_mestre.cod_fiscal,
             cod_fiscal1         LIKE wfat_mestre.cod_fiscal,
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

             num_duplic7         LIKE wfat_duplic.num_duplicata,
             dig_duplic7         LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd7      LIKE wfat_duplic.dat_vencto_sd,
             val_duplic7         LIKE wfat_duplic.val_duplic,

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

             end_cob_cli         LIKE cli_end_cob.end_cobr,
             cod_uni_feder_cobr  LIKE cidades.cod_uni_feder,
             den_cidade_cob      LIKE cidades.den_cidade,

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
             des_especie1        CHAR(06),
             des_especie2        CHAR(06),
             des_especie3        CHAR(06),
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
             cod_operacao        LIKE nat_operacao.cod_nat_oper
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE wfat_item.cod_item,
             cod_item_cli        LIKE cliente_item.cod_item_cliente,
             num_pedido          LIKE wfat_item.num_pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(166),
             den_item2           CHAR(80),
             den_item3           CHAR(80),
             den_item4           CHAR(80),
             den_item5           CHAR(80),
             den_item6           CHAR(80),                                       
             cod_fiscal          LIKE nf_item_fiscal.cod_fiscal,
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
             den_item          CHAR(52),
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

   DEFINE pa_clas_fisc       ARRAY[99]
          OF RECORD
             cla_fisc_nff    CHAR(001), 
             cod_cla_fisc    CHAR(014) 
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
          
   DEFINE pa_texto_ped_ite           ARRAY[01]
          OF RECORD
             texto                   CHAR(76) 
          END RECORD
 
   DEFINE pa_texto_obs               ARRAY[05] 
          OF RECORD
             den_texto               CHAR(32)
          END RECORD

   DEFINE p_txt_pedido      ARRAY[06] OF RECORD
          pedido            CHAR(25)
   END RECORD

   DEFINE p_txt              ARRAY[08] OF RECORD 
          texto              CHAR(90)
   END RECORD
         
   DEFINE p_textos RECORD
          texto1                     CHAR(50),
          texto2                     CHAR(50),
          texto3                     CHAR(50),
          texto4                     CHAR(50),
          texto5                     CHAR(50)
   END RECORD

   DEFINE p_num_linhas               SMALLINT,
          p_num_pagina               SMALLINT,
          p_tot_paginas              SMALLINT
 
   DEFINE p_saltar_linhas            SMALLINT,
          p_linhas_print             SMALLINT
 
   DEFINE p_des_texto                CHAR(120),
          p_des_texto1               CHAR(110),
          p_des_texto2               CHAR(60),
          p_des_texto3               CHAR(60),
          p_val_tot_ipi_acum         DECIMAL(15,3)

   DEFINE p_versao                   CHAR(18)
 
   DEFINE g_ies_ambiente             CHAR(001)
END GLOBALS


   DEFINE g_cla_fisc   ARRAY[10]
          OF RECORD
             num_seq         CHAR(2), 
             cod_cla_fisc    CHAR(10) 
          END RECORD

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0788-05.10.00"
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
      CALL pol0788_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0788_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0788") RETURNING comando    
   OPEN WINDOW w_pol0788 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0001
         IF log005_seguranca(p_user,"VDP","POL0788","CO") THEN
            IF pol0788_entrada_parametros() THEN
               LET p_ies_cons = TRUE
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar" "Lista as Notas Fiscais Fatura"
         HELP 0002
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL0788","CO") THEN
               LET p_ies_cons = FALSE
               IF pol0788_imprime_nff() THEN 
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
   CLOSE WINDOW w_pol0788

END FUNCTION

#-----------------------------------#
FUNCTION pol0788_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0788

   LET p_saltar_linhas = TRUE
   LET p_linhas_print  = 0
   LET p_reimpressao = "N"
   LET p_num_nff_ini   = 0
   LET p_num_nff_fim   = 999999

   INPUT p_reimpressao,
         p_num_nff_ini,
         p_num_nff_fim 
      WITHOUT DEFAULTS
   FROM reimpressao,
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
         IF p_reimpressao = "N" THEN
            DISPLAY p_reimpressao TO reimpressao
            DISPLAY p_num_nff_ini TO num_nff_ini
            DISPLAY p_num_nff_fim TO num_nff_fim
         ELSE
            LET p_num_nff_ini = NULL  
            LET p_num_nff_fim = NULL   
            DISPLAY p_reimpressao TO reimpressao
            DISPLAY p_num_nff_ini TO num_nff_ini
            DISPLAY p_num_nff_fim TO num_nff_fim
         END IF

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
   CURRENT WINDOW IS w_pol0788

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0788_imprime_nff()
#----------------------------#    

   IF log028_saida_relat(16,41) IS NOT NULL THEN 
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0788_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0788.tmp' 
            START REPORT pol0788_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0788_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE
   END IF

   CURRENT WINDOW IS w_pol0788

   CALL pol0788_busca_dados_empresa()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 

   IF p_reimpressao = "S" THEN
      LET p_reimpressao = "R"
   END IF

   LET p_imprime_nf = FALSE
   
   DECLARE cq_wfat_mestre CURSOR WITH HOLD FOR
   SELECT *
      FROM wfat_mestre
   WHERE cod_empresa  = p_cod_empresa
     AND num_nff     >= p_num_nff_ini
     AND num_nff     <= p_num_nff_fim
     AND nom_usuario  = p_user
     AND ies_impr_nff = p_reimpressao       
   ORDER BY num_nff

   FOREACH cq_wfat_mestre INTO p_wfat_mestre.*

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

      #--- cria tabela temporaria
      CALL pol0788_cria_tabela_temporaria()
      
      #--- inicializa variaveis
      INITIALIZE pa_corpo_nff, p_nff TO NULL


      LET p_nff.num_nff       = p_wfat_mestre.num_nff
      LET p_nff.cod_fiscal    = NULL 
      LET p_nff.cod_fiscal1   = NULL
      LET p_nff.den_nat_oper  = NULL
      LET p_nff.den_nat_oper1 = NULL
 
      DECLARE cq_codf CURSOR FOR
       SELECT UNIQUE cod_fiscal,
                     cod_nat_oper
         FROM wfat_item_fiscal
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = p_wfat_mestre.num_nff

      FOREACH cq_codf INTO p_cod_fiscal,
                           p_cod_nat_oper 

         IF p_nff.cod_fiscal IS NULL THEN
            LET p_nff.cod_fiscal           = p_cod_fiscal
            LET p_wfat_mestre.cod_nat_oper = p_cod_nat_oper
            LET p_nff.den_nat_oper         = pol0788_den_nat_oper()
            LET p_nff.cod_operacao         = p_nat_operacao.cod_movto_estoq
         ELSE
            LET p_nff.cod_fiscal1          = p_cod_fiscal
            LET p_wfat_mestre.cod_nat_oper = p_cod_nat_oper
            LET p_nff.den_nat_oper1        = pol0788_den_nat_oper()
            LET p_nff.cod_operacao         = p_nat_operacao.cod_movto_estoq
            EXIT FOREACH
         END IF
      END FOREACH

      IF p_nat_operacao.ies_subst_tribut = "S" THEN
         CALL pol0788_busca_dados_subst_trib_uf()
         LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      END IF

      LET p_nff.nat_oper          = p_wfat_mestre.cod_nat_oper
      LET p_cod_nat_oper          = p_wfat_mestre.cod_nat_oper
      LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      LET p_nff.nat_oper          = p_wfat_mestre.cod_nat_oper
      LET p_nff.dat_emissao       = p_wfat_mestre.dat_emissao

      #--- carrega dados do cliente
      CALL pol0788_busca_dados_clientes()
      LET p_nff.nom_destinatario = p_clientes.nom_cliente
      LET p_nff.end_destinatario = p_clientes.end_cliente
      LET p_nff.den_bairro       = p_clientes.den_bairro
      LET p_nff.cod_cep          = p_clientes.cod_cep
      LET p_nff.cod_cliente      = p_clientes.cod_cliente

      IF p_nff.num_cgc_cpf[1] = "0" THEN
         LET p_nff.num_cgc_cpf = p_nff.num_cgc_cpf[2,19]
      ELSE
         LET p_nff.num_cgc_cpf = p_clientes.num_cgc_cpf
      END IF

      IF p_clientes.ies_zona_franca = "S" OR
         p_clientes.ies_zona_franca = "A" THEN
         LET p_wfat_mestre.pct_icm = 0
      END IF   

      #--- carrega dados da cidade
      CALL pol0788_busca_dados_cidades(p_clientes.cod_cidade)
      LET p_nff.den_cidade    = p_cidades.den_cidade          
      LET p_nff.num_telefone  = p_clientes.num_telefone
      LET p_nff.num_telex     = p_clientes.num_telex
      LET p_nff.cod_uni_feder = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual  = p_clientes.ins_estadual
      LET p_nff.hora_saida    = EXTEND(CURRENT, HOUR TO MINUTE)

      #--- codigo fiscal complementar
      CALL pol0788_busca_cof_compl()

      #--- busca nome do pais
      CALL pol0788_busca_nome_pais()
      LET p_nff.den_pais = p_paises.den_pais              

      #--- busca dados das duplicatas
      CALL pol0788_busca_dados_duplicatas()

      #--- busca extenso do valor total da nota
      CALL log038_extenso(p_wfat_mestre.val_tot_nff,130,130,1,1)
            RETURNING p_nff.val_extenso1, p_nff.val_extenso2,
                      p_nff.val_extenso3, p_nff.val_extenso4

      #--- carrega itens da nota fiscal
      CALL pol0788_carrega_corpo_nota()
      
      #--- carrega historico fiscal
      CALL pol0788_carrega_historico_fiscal()

      #--- grava corpo da nota fiscal
      CALL pol0788_grava_corpo_nota()
    
      #--- busca retorno de industrialização
      IF p_nat_operacao.ies_tip_controle = "3" THEN
         CALL pol0788_retorno_terceiro()
      END IF
            
      SELECT num_pedido_repres,
             cod_tip_venda
        INTO p_pedidos.num_pedido_repres,  
             p_pedidos.cod_tip_venda
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = pa_corpo_nff[1].num_pedido

      IF p_pedidos.cod_tip_venda <> 1 THEN
         SELECT den_tip_venda
           INTO p_tipo_venda.den_tip_venda
           FROM tipo_venda
          WHERE cod_tip_venda = p_pedidos.cod_tip_venda
      END IF

      #--- grava daods endereco de entrega
      CALL pol0788_grava_dados_end_entrega()

      #--- carrega endereco de cobranca
      CALL pol0788_carrega_end_cobranca()

      #--- carrega valor da mao de obra
      CALL pol0788_carrega_val_mdo()

      #--- trata zona franca
      CALL pol0788_trata_zona_franca()

      LET p_nff.val_tot_base_icm = p_wfat_mestre.val_tot_base_icm 
      LET p_nff.val_tot_icm      = p_wfat_mestre.val_tot_icm

      IF p_nff.val_tot_icm = 0 THEN
         LET p_nff.val_tot_base_icm = 0
      END IF
            
      LET p_nff.val_tot_base_ret = p_wfat_mestre.val_tot_base_ret
      LET p_nff.val_tot_icm_ret  = p_wfat_mestre.val_tot_icm_ret

      IF p_nff.val_tot_icm_ret = 0 THEN
         LET p_nff.val_tot_base_ret = 0
      END IF

      LET p_nff.val_tot_mercadoria = p_wfat_mestre.val_tot_mercadoria
      LET p_nff.val_frete_cli      = p_wfat_mestre.val_frete_cli
      LET p_nff.val_seguro_cli     = p_wfat_mestre.val_seguro_cli
      LET p_nff.val_tot_despesas   = 0
      LET p_nff.val_tot_ipi        = p_wfat_mestre.val_tot_ipi
      
      IF p_nat_operacao.ies_tip_controle = "3" THEN
         LET p_nff.val_tot_nff = p_nff.val_tot_mercadoria + p_nff.val_tot_ipi + p_nff.val_tot_despesas
      ELSE
         LET p_nff.val_tot_nff = p_wfat_mestre.val_tot_nff
      END IF

      #--- busca dados da transportadora
      CALL pol0788_busca_dados_transport(p_wfat_mestre.cod_transpor)
      CALL pol0788_busca_dados_cidades(p_transport.cod_cidade)

      LET p_nff.num_placa    = p_wfat_mestre.num_placa
      LET p_nff.nom_transpor = p_transport.nom_cliente  
      
      IF p_wfat_mestre.ies_frete = 3 THEN 
         LET p_nff.ies_frete = 2
      ELSE 
         LET p_nff.ies_frete = 1
      END IF
      
      IF p_transport.num_cgc_cpf[1] = "0" THEN
         LET p_nff.num_cgc_trans = p_transport.num_cgc_cpf[2,19]
      ELSE
         LET p_nff.num_cgc_trans = p_transport.num_cgc_cpf
      END IF
      
      LET p_nff.end_transpor        = p_transport.end_cliente
      LET p_nff.den_cidade_trans    = p_cidades.den_cidade
      LET p_nff.cod_uni_feder_trans = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual_trans  = p_transport.ins_estadual

      LET p_nff.des_especie1 = pol0788_especie(1)
      LET p_nff.des_especie2 = pol0788_especie(2)
      LET p_nff.des_especie3 = pol0788_especie(3)
      LET p_nff.des_especie4 = pol0788_especie(4)
      LET p_nff.des_especie5 = pol0788_especie(5)

      LET p_nff.qtd_volumes  = p_wfat_mestre.qtd_volumes1 +
                               p_wfat_mestre.qtd_volumes2 +
                               p_wfat_mestre.qtd_volumes3 +
                               p_wfat_mestre.qtd_volumes4 +
                               p_wfat_mestre.qtd_volumes5

      #--- relaciona qtdes e descricoes dos volumes
      CALL pol0788_junta_volumes()

      LET p_nff.den_marca       = p_clientes.den_marca
      LET p_nff.pes_tot_bruto   = p_wfat_mestre.pes_tot_bruto
      LET p_nff.pes_tot_liquido = p_wfat_mestre.pes_tot_liquido
      LET p_nff.num_pedido      = p_wfat_item.num_pedido
      LET p_nff.cod_repres      = p_wfat_mestre.cod_repres
      LET p_nff.nom_guerra      = pol0788_representante()
      LET p_nff.num_suframa     = p_clientes.num_suframa
      LET p_nff.num_om          = p_wfat_item.num_om
      
      #--- carrega descricao da condicao de pagamento
      CALL pol0788_den_cnd_pgto()
      
      #--- grava dados consignados
      CALL pol0788_grava_dados_consig()
      
      #--- grava historico do pedido
      CALL pol0788_grava_historico_nf_pedido()
      
      #--- checa nota fiscal de contra ordem
      CALL pol0788_checa_nf_contra_ordem()
      
      #--- monta relatorio
      CALL pol0788_monta_relat()

      #--- marca nf que ja foi impressa
      UPDATE wfat_mestre 
         SET ies_impr_nff = "R"
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = p_wfat_mestre.num_nff
        AND nom_usuario = p_user

      LET p_imprime_nf = TRUE

   END FOREACH

   FINISH REPORT pol0788_relat

   IF p_imprime_nf THEN
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
FUNCTION pol0788_junta_volumes()
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
     GROUP BY 1
     ORDER BY 1
   
   FOREACH cq_volumes INTO p_descricao,
                           p_volumes
      
      IF p_qtd_volumes IS NULL THEN
         LET p_qtd_volumes = p_volumes CLIPPED
      ELSE
         LET p_qtd_volumes = p_qtd_volumes CLIPPED,'/', p_volumes
      END IF
      
      IF p_des_especie IS NULL THEN
         LET p_des_especie = p_descricao CLIPPED
      ELSE
         LET p_des_especie = p_des_especie CLIPPED,'/', p_descricao
      END IF
   
   END FOREACH

END FUNCTION

#---------------------------------------#
FUNCTION pol0788_cria_tabela_temporaria()
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
 
   DROP TABLE retorno_embal;
   CREATE TEMP TABLE retorno_embal
     (
      num_nf         DECIMAL(7,0),
      dat_emis_nf    DATE,
      cod_unid_med   CHAR(03)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-RETORNO_EMBAL")
   END IF
     
   DROP TABLE ret_mat_1072;
   CREATE TEMP TABLE ret_mat_1072
     (
      cod_material CHAR(015),
      des_texto    CHAR(120)
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","RET_MAT_1072")
   END IF

   DROP TABLE wnotalev;
   CREATE TABLE wnotalev
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(15),
      den_item           CHAR(52),
      cod_item_cli       CHAR(30),
      cod_cla_fisc       CHAR(10),
      cod_origem         CHAR(01),
      cod_tributacao     CHAR(02),
      pes_unit           DECIMAL(9,4),
      cod_unid_med       CHAR(03),
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
      den_item           CHAR(52),
      cod_item_cli       CHAR(30),
      cod_cla_fisc       CHAR(10),
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

   DROP TABLE clas_fisc_temp;
   CREATE TEMP TABLE clas_fisc_temp
     (
      cod_cla_fisc       CHAR(010),
      num_item           DECIMAL(2,0)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF

   DROP TABLE volumes_temp;
   CREATE TEMP TABLE volumes_temp
     (
      den_volume CHAR(06),
      qtd_volume DECIMAL(5,0)
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:VOLUMES_TEMP")
   END IF

   DROP TABLE pedidos_temp;
   CREATE TEMP TABLE  pedidos_temp
     (
      cod_empresa  CHAR(02),
      num_pedido   CHAR(25)
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:PEDIDOS_TEMP")
   END IF
   
   CALL log085_transacao("COMMIT") 

   WHENEVER ERROR STOP
 
END FUNCTION

#-------------------------------#
 FUNCTION pol0788_retorno_embal()
#-------------------------------#

   DEFINE p_num_nf      LIKE item_dev_terc.num_nf,
          p_dat_emis_nf LIKE item_de_terc.dat_emis_nf,
          p_qtd_nf      SMALLINT
   
   INITIALIZE p_num_nf,
              p_des_texto,
              p_des_texto1,
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
        AND b.cod_item       = p_wnotalev.cod_item

   LET p_des_texto  = NULL
   LET p_des_texto1 = NULL
   LET p_qtd_nf     = 1
     
   FOREACH cq_retorno INTO p_num_nf,
                           p_qtd_devolvida,
                           p_unid_terc

      INSERT INTO retorno_embal VALUES ( p_num_nf,
                                         p_dat_emis_nf,
                                         p_unid_terc )      
   END FOREACH

END FUNCTION

#----------------------------------#
FUNCTION pol0788_retorno_terceiro()
#----------------------------------#

   DEFINE p_des_texto CHAR(120),
          p_item      CHAR(15)
   
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

   FOREACH cq_ret_terc INTO
              p_num_nf,
              p_cod_item,
              p_qtd_devolvida,
              p_dat_emis_nf,
              p_unid_med,
              p_val_remessa,
              p_qtd_remessa

      IF p_des_texto IS NULL THEN
         LET p_des_texto = 'MATERIAL DE SUA PROPRIEDADE QUE RECEBEMOS P/BENEFICIAMENTO'
         CALL pol0788_insert_array(p_des_texto,3)
         LET p_des_texto = 'ATRAVES DE SUAS NF E QUE ESTAMOS DEVOLVEMOS CONFORME SEGUE:'
         CALL pol0788_insert_array(p_des_texto,3)
      END IF

      LET p_item_cliente = p_cod_item
      
      SELECT cod_item_cliente,
             tex_complementar
        INTO p_item,
             p_den_item_cli
        FROM cliente_item
       WHERE cod_empresa        = p_cod_empresa
         AND cod_cliente_matriz = p_wfat_mestre.cod_cliente
         AND cod_item           = p_cod_item      

      IF STATUS <> 0 THEN
         LET p_item = p_cod_item
         LET p_den_item_cli = NULL
      END IF

      LET p_val_unit = p_val_remessa / p_qtd_remessa
      LET p_val_mat_dev = p_qtd_devolvida * p_val_unit

      LET p_des_texto = NULL 
      IF p_den_item_cli IS NULL OR p_den_item_cli = ' ' THEN
         LET p_des_texto = p_item," Qtd:",p_qtd_devolvida USING "<<<<&.&&"," ", 
                           p_unid_med CLIPPED,
                           " V.Unit: ",p_val_unit USING "<,<<<,<<&.&&",
                           " V.Tot: ",p_val_mat_dev USING "<,<<<,<<&.&&",
                           " S/NF:",p_num_nf USING "&&&&&&"," - ",
                           p_dat_emis_nf USING 'dd/mm/yy'                               
      ELSE
         LET p_des_texto = p_item,' ',p_den_item_cli,
                           " Qtd:",p_qtd_devolvida USING "<<<<&.&&"," ",
                           p_unid_med CLIPPED,
                           " V.Unit: ",p_val_unit USING "<,<<<,<<&.&&",
                           " V.Tot: ",p_val_mat_dev USING "<,<<<,<<&.&&",
                           " S/NF:",p_num_nf USING "&&&&&&"," - ",
                           p_dat_emis_nf USING 'dd/mm/yy'                               
      END IF
      IF p_des_texto IS NOT NULL THEN
         IF LENGTH(p_des_texto) > 60 THEN
            INITIALIZE p_des_texto2, p_des_texto3 TO NULL
            LET p_des_texto2 = p_des_texto[1,60]
            LET p_des_texto3 = p_des_texto[61,120]
            IF p_des_texto2 IS NOT NULL THEN
               CALL pol0788_insert_array(p_des_texto2,3)
            END IF
            IF p_des_texto3 IS NOT NULL THEN
               CALL pol0788_insert_array(p_des_texto3,3)
            END IF
         ELSE
            CALL pol0788_insert_array(p_des_texto,3)
         END IF
      END IF
   END FOREACH

END FUNCTION

#----------------------------#
FUNCTION pol0788_pega_texto()
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

   CALL pol0788_le_fiscal_hist(p_cod_hist_1)
   CALL pol0788_le_fiscal_hist(p_cod_hist_2)

END FUNCTION

#-----------------------------------------#
FUNCTION pol0788_le_fiscal_hist(p_cod_hist)
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
FUNCTION pol0788_troca_hist()
#----------------------------#

   DEFINE p_wfat_historico RECORD LIKE wfat_historico.*,
          p_texto          CHAR(75),
          p_qtd_reg        SMALLINT
          
   INITIALIZE p_texto_1,
              p_texto_2,
              p_texto_3,
              p_texto_4 TO NULL
              
   IF p_wfat_mestre.ies_origem = "P" THEN
     
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
      FOREACH cq_txt_hist INTO p_texto_1,
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
      
   ELSE

      DELETE FROM wfat_historico
       WHERE cod_empresa = p_wfat_item.cod_empresa
         AND num_nff     = p_wfat_item.num_nff
         AND nom_usuario = p_wfat_item.nom_usuario
  
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("DELEÇÃO","wfat_historico")     
         RETURN  
      END IF
   
      LET p_qtd_reg = 0
    
      DECLARE cq_txt_hist1 CURSOR FOR
       SELECT texto1,
              texto2,
              texto3,
              texto4
         FROM txt_excecao
      FOREACH cq_txt_hist1 INTO p_texto_1,
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
   END IF
   
END FUNCTION

#----------------------------#
FUNCTION pol0788_monta_relat()
#----------------------------#

   DEFINE p_indice       DECIMAL(2,0),
          p_cod_cla_fisc CHAR(10),
          p_descricao    CHAR(104),
          p_den_ite_ant  CHAR(52)

   DEFINE p_num_nf      LIKE item_dev_terc.num_nf,
          p_dat_emis_nf LIKE item_de_terc.dat_emis_nf,
          p_qtd_nf      SMALLINT
  
   #--- agrupa os produtos do corpo da nota --- #  
   INITIALIZE p_wnotalev TO NULL
   
   DECLARE cq_agrupa CURSOR FOR
   SELECT num_seq,
          ies_tip_info,
          cod_item,
          den_item,
          cod_item_cli,
          cod_cla_fisc, 
          cod_origem, 
          cod_tributacao,
          pes_unit,
          cod_unid_med,
          SUM(qtd_item), 
          pre_unit, 
          SUM(val_liq_item),
          pct_icm, 
          pct_ipi, 
          SUM(val_ipi) 
     FROM wnotalev 
    WHERE ies_tip_info = 1
    GROUP BY num_seq,
             ies_tip_info, 
             cod_item,
             den_item,
             cod_item_cli, 
             cod_cla_fisc, 
             cod_origem, 
             cod_tributacao,
             pes_unit,
             cod_unid_med,
             pre_unit,
             pct_icm,
             pct_ipi 
    ORDER BY num_seq

   FOREACH cq_agrupa INTO 
           p_wnotalev.num_seq,
           p_wnotalev.ies_tip_info,
           p_wnotalev.cod_item,
           p_wnotalev.den_item,
           p_wnotalev.cod_item_cli,
           p_wnotalev.cod_cla_fisc,
           p_wnotalev.cod_origem,
           p_wnotalev.cod_tributacao,
           p_wnotalev.pes_unit,
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
     ORDER BY ies_tip_info,num_seq
       
   FOREACH cq_aux_1 INTO p_wnotalev.*
   
      LET p_num_seq = p_num_seq + 1
      LET p_wnotalev.num_seq = p_num_seq
      
      INSERT INTO wnotalev
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
      END IF

      LET p_den_item2 = NULL
      LET p_den_ite_ant = NULL
      DECLARE cq_den_item2 CURSOR FOR
       SELECT den_item
         FROM wnotalev_aux
        WHERE ies_tip_info   = 2
          AND cod_item       = p_wnotalev.cod_item
          AND cod_cla_fisc   = p_wnotalev.cod_cla_fisc
          AND cod_origem     = p_wnotalev.cod_origem
          AND cod_tributacao = p_wnotalev.cod_tributacao
          AND pre_unit       = p_wnotalev.pre_unit
          AND pct_icm        = p_wnotalev.pct_icm
          AND pct_ipi        = p_wnotalev.pct_ipi

      FOREACH cq_den_item2 INTO p_den_item2

         IF p_den_ite_ant = p_den_item2 THEN
            LET p_den_item2 = NULL  
            EXIT FOREACH
         ELSE
            LET p_den_ite_ant = p_den_item2
         END IF
                                           
         INITIALIZE p_wnotalev TO NULL
         LET p_num_seq               = p_num_seq + 1
         LET p_wnotalev.num_seq      = p_num_seq
         LET p_wnotalev.ies_tip_info = 2
         LET p_wnotalev.den_item     = p_den_item2
          
         IF p_wnotalev.den_item IS NOT NULL OR
            p_wnotalev.den_item <> " " THEN
            INSERT INTO wnotalev
               VALUES(p_wnotalev.*)
   
            IF sqlca.sqlcode <> 0 THEN 
               CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
            END IF
            INITIALIZE p_wnotalev TO NULL
            LET p_den_item2 = NULL
         END IF
      END FOREACH
   END FOREACH

   LET p_des_texto = " "
   CALL pol0788_insert_array(p_des_texto,3)

   DECLARE cq_aux_3 CURSOR FOR
    SELECT *
      FROM wnotalev_aux
     WHERE ies_tip_info = 3 
  
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
  
   FOREACH cq_aux_4 INTO p_wnotalev.*
   
      LET p_num_seq = p_num_seq + 1
      LET p_wnotalev.num_seq = p_num_seq
      
      INSERT INTO wnotalev
         VALUES(p_wnotalev.*)

      IF sqlca.sqlcode <> 0 THEN 
         CALL log003_err_sql("INCLUSÃO","TABELA-WNOTALEV")
      END IF

   END FOREACH

   #--- cria indice de classificação fiscal
   LET p_indice = 0
   LET p_num_pagina = 0
   
   DECLARE cq_ind_cla CURSOR FOR
   SELECT cod_cla_fisc
     FROM wnotalev
    WHERE ies_tip_info = 1
    ORDER BY 1

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

   LET p_txt_ped = NULL
   LET p_num_seq = 0 
   INITIALIZE p_num_pedido TO NULL
      
   DECLARE cq_num_ped CURSOR FOR
    SELECT UNIQUE num_pedido
	    FROM pedidos_temp

   FOREACH cq_num_ped INTO p_num_pedido
      IF p_num_pedido IS NOT NULL THEN
         LET p_txt_ped = p_num_pedido
         CALL pol0788_insere_pedido(p_txt_ped)
      END IF
      IF p_num_seq > 6 THEN
         EXIT FOREACH
      END IF
   END FOREACH
      
      
   LET p_txta = NULL
   LET p_txtb = NULL
   LET p_num_seq = 0 
   INITIALIZE p_textos,
              p_des_texto,
              p_txt  TO NULL
      
   DECLARE cq_texto CURSOR FOR
    SELECT des_texto
      FROM wnotalev
     WHERE ies_tip_info = 4

   FOREACH cq_texto INTO p_des_texto
      IF p_des_texto IS NOT NULL THEN
         IF LENGTH(p_des_texto) > 60 THEN
            LET p_txta = p_des_texto[1,60]
            LET p_txtb = p_des_texto[61,120]
            CALL pol0788_insere_texto(p_txta)
            CALL pol0788_insere_texto(p_txtb)
         ELSE
            LET p_txta = p_des_texto[1,60]
            CALL pol0788_insere_texto(p_txta)
         END IF  
      END IF
      IF p_num_seq > 8 THEN
         EXIT FOREACH
      END IF
   END FOREACH            	       

  #--- Finalmente, Imprime a NF---#
   CALL pol0788_calcula_total_de_paginas()

   LET p_num_pagina = 0
   LET p_linha = 1

   DECLARE cq_wnotalev CURSOR FOR
   SELECT *
   FROM wnotalev
  WHERE ies_tip_info < 4
   ORDER BY 1
   
   FOREACH cq_wnotalev INTO p_wnotalev.*
      
      LET p_wnotalev.num_nff = p_wfat_mestre.num_nff
      
      SELECT num_item
        INTO p_cod_ref_clas
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_wnotalev.cod_cla_fisc
      
      OUTPUT TO REPORT pol0788_relat(p_wnotalev.num_nff)
      
  END FOREACH

  { pula linhas até completar o número de linhas do corpo da página (30)}
  { somente se o numero de linhas da nota nao for multiplo de 8 }
  
  IF p_saltar_linhas THEN
     LET p_wnotalev.num_nff      = p_wfat_mestre.num_nff
     LET p_wnotalev.ies_tip_info = 5
     OUTPUT TO REPORT pol0788_relat(p_wnotalev.num_nff)
  END IF 
  
END FUNCTION

#----------------------------------------#
FUNCTION pol0788_insere_pedido(p_pedido)
#----------------------------------------#

   DEFINE p_pedido CHAR(25)
   
   LET p_num_seq = p_num_seq + 1
   IF p_num_seq <= 6 THEN
      LET p_txt_pedido[p_num_seq].pedido = p_pedido
   END IF

END FUNCTION

#-------------------------------------#
FUNCTION pol0788_insere_texto(p_texto)
#-------------------------------------#

   DEFINE p_texto CHAR(90)
   
   LET p_num_seq = p_num_seq + 1
   IF p_num_seq <= 8 THEN
      LET p_txt[p_num_seq].texto = p_texto
   END IF

END FUNCTION

#---------------------------------------#
FUNCTION pol0788_busca_dados_duplicatas()
#---------------------------------------#
   DEFINE p_wfat_duplic       RECORD LIKE wfat_duplic.*,
          p_contador          DECIMAL(2,0)

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
FUNCTION pol0788_carrega_end_cobranca()
#-------------------------------------#

   INITIALIZE p_cli_end_cobr.* TO NULL
  
   SELECT cli_end_cob.*
     INTO p_cli_end_cobr.*
     FROM cli_end_cob
    WHERE cod_cliente = p_nff.cod_cliente

   IF SQLCA.sqlcode <> 0 THEN
      INITIALIZE p_cli_end_cobr.* TO NULL
   ELSE
   
      LET p_nff.end_cob_cli = p_cli_end_cobr.end_cobr
      SELECT den_cidade,
             cod_uni_feder
        INTO p_nff.den_cidade_cob,
             p_nff.cod_uni_feder_cobr
        FROM cidades
       WHERE cidades.cod_cidade = p_cli_end_cobr.cod_cidade_cob

      IF SQLCA.sqlcode <> 0 THEN
         LET p_nff.den_cidade_cob = NULL
         LET p_nff.cod_uni_feder_cobr = NULL
      END IF
   END IF
   
END FUNCTION

#------------------------------------#
FUNCTION pol0788_carrega_corpo_nota()
#------------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao

   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          sql_stmt             CHAR(2000)

   LET p_ind   = 0						
   LET p_count = 0 

   IF p_wfat_mestre.ies_origem = 'P' THEN
      LET sql_stmt =
           "SELECT * FROM wfat_item ",
           "WHERE cod_empresa ='",p_cod_empresa,"' ",
             "AND num_nff     ='",p_wfat_mestre.num_nff,"' ",
             "AND num_pedido  > 0"
   ELSE
      LET sql_stmt = 
          "SELECT * FROM wfat_item ",
           "WHERE cod_empresa ='",p_cod_empresa,"' ",
             "AND num_nff     ='",p_wfat_mestre.num_nff,"' ",
             "ORDER BY num_nff,num_sequencia"
   END IF
     
   PREPARE var_query FROM sql_stmt
   DECLARE cq_wfat_item_rt CURSOR FOR var_query

   FOREACH cq_wfat_item_rt INTO p_wfat_item.*

      LET p_ind = p_ind + 1
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF  

      LET pa_corpo_nff[p_ind].cod_cla_fisc    = p_wfat_item.cod_cla_fisc
      LET pa_corpo_nff[p_ind].cod_item        = p_wfat_item.cod_item
      LET pa_corpo_nff[p_ind].num_sequencia   = p_wfat_item.num_sequencia
      LET pa_corpo_nff[p_ind].num_pedido      = p_wfat_item.num_pedido

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

      CALL pol0788_busca_dados_pedido()
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli

      CALL pol0788_item_cliente()
      LET pa_corpo_nff[p_ind].cod_item_cli = g_cod_item_cliente
      #LET p_wnotalev.cod_item_cli = g_cod_item_cliente

      #------
      INITIALIZE pa_corpo_nff[p_ind].den_item1 TO NULL

      IF LENGTH(pa_corpo_nff[p_ind].cod_item_cli) > 0 THEN
         LET pa_corpo_nff[p_ind].den_item1 = pa_corpo_nff[p_ind].cod_item_cli CLIPPED," ",p_wfat_item.den_item      
      ELSE 
         LET pa_corpo_nff[p_ind].den_item1 = p_wfat_item.den_item   
      END IF
      
      CALL pol0788_verifica_texto_ped_it()
      IF pa_texto_ped_it[1].texto IS NOT NULL OR
         pa_texto_ped_it[1].texto <> " " THEN
         LET pa_corpo_nff[p_ind].den_item1 = pa_corpo_nff[p_ind].cod_item_cli CLIPPED," ",pa_texto_ped_it[1].texto CLIPPED
      ELSE
         IF pa_texto_ped_ite[1].texto IS NOT NULL OR
            pa_texto_ped_ite[1].texto <> " " THEN
            LET pa_corpo_nff[p_ind].den_item1 = pa_corpo_nff[p_ind].cod_item_cli CLIPPED," ",pa_texto_ped_ite[1].texto CLIPPED
         END IF
      END IF
      
      IF pa_texto_ped_it[2].texto IS NOT NULL OR
         pa_texto_ped_it[2].texto <> " " THEN
         LET pa_corpo_nff[p_ind].den_item2 = pa_texto_ped_it[2].texto CLIPPED
      END IF
      IF pa_texto_ped_it[3].texto IS NOT NULL OR
         pa_texto_ped_it[3].texto <> " " THEN
         LET pa_corpo_nff[p_ind].den_item3 = pa_texto_ped_it[3].texto CLIPPED
      END IF
      IF pa_texto_ped_it[4].texto IS NOT NULL OR
         pa_texto_ped_it[4].texto <> " " THEN
         LET pa_corpo_nff[p_ind].den_item4 = pa_texto_ped_it[4].texto CLIPPED
      END IF
      IF pa_texto_ped_it[5].texto IS NOT NULL OR
         pa_texto_ped_it[5].texto <> " " THEN
         LET pa_corpo_nff[p_ind].den_item5 = pa_texto_ped_it[5].texto CLIPPED
      END IF
      
      LET pa_corpo_nff[p_ind].cod_origem     = p_wfat_mestre.cod_origem
      LET pa_corpo_nff[p_ind].cod_tributacao = p_wfat_mestre.cod_tributacao
      LET pa_corpo_nff[p_ind].pes_unit       = p_wfat_item.pes_unit 
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit       = p_wfat_item.pre_unit_nf

      LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_item.val_liq_item
      
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
      LET p_val_tot_ipi_acum              = p_val_tot_ipi_acum + p_wfat_item.val_ipi

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
 
      IF p_cod_nat_oper <> p_wfat_mestre.cod_nat_oper THEN
         CALL pol0788_pega_texto() 
      END IF

      DECLARE cq_icms CURSOR FOR
       SELECT hist_icms
         FROM vdp_excecao_icms
        WHERE empresa      = p_cod_empresa
          AND cliente      = p_wfat_mestre.cod_cliente
          AND classif_fisc = p_wfat_item.cod_cla_fisc
           OR item         = p_wfat_item.cod_item

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LEITURA","vdp_excecao_icms")
       END IF
       
      FOREACH cq_icms INTO p_cod_texto
         CALL pol0788_le_fiscal_hist(p_cod_texto)
      END FOREACH
          
      DECLARE cq_ipi CURSOR FOR
       SELECT hist_excecao
         FROM vdp_exc_ipi_cli
        WHERE empresa        = p_cod_empresa
          AND cliente        = p_wfat_mestre.cod_cliente
          AND classif_fiscal = p_wfat_item.cod_cla_fisc
           OR item           = p_wfat_item.cod_item

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","vdp_exc_ipi_cli")       
      END IF

      FOREACH cq_ipi INTO p_cod_texto
         CALL pol0788_le_fiscal_hist(p_cod_texto)
      END FOREACH
      
   END FOREACH
   
   LET p_cod_nat_oper = p_wfat_mestre.cod_nat_oper
   
   CALL pol0788_pega_texto()
   CALL pol0788_troca_hist() 

END FUNCTION

#-----------------------------#
FUNCTION pol0788_item_cliente()
#-----------------------------#

   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
      INTO g_cod_item_cliente    
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_wfat_item.cod_item

   IF SQLCA.sqlcode <> 0 THEN
      LET g_cod_item_cliente = NULL
   END IF
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0788_verifica_ctr_unid_med()
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
FUNCTION pol0788_carrega_historico_fiscal()
#-----------------------------------------#  

   INITIALIZE p_wfat_historico.* TO NULL

   DECLARE cq_whist CURSOR FOR
   SELECT *
   FROM wfat_historico
   WHERE cod_empresa = p_cod_empresa
     AND num_nff     = p_wfat_mestre.num_nff

   FOREACH cq_whist INTO p_wfat_historico.* 

      IF p_wfat_historico.tex_hist1_1 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist1_1,4)
      END IF
      IF p_wfat_historico.tex_hist2_1 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist2_1,4)
      END IF
      IF p_wfat_historico.tex_hist3_1 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist3_1,4)
      END IF
      IF p_wfat_historico.tex_hist4_1 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist4_1,4)
      END IF    
      IF p_wfat_historico.tex_hist1_2 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist1_2,4)
      END IF
      IF p_wfat_historico.tex_hist2_2 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist2_2,4)
      END IF
      IF p_wfat_historico.tex_hist3_2 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist3_2,4)
      END IF
      IF p_wfat_historico.tex_hist4_2 <> " " THEN
         CALL pol0788_insert_array(p_wfat_historico.tex_hist4_2,4)
      END IF    

   END FOREACH

END FUNCTION

#---------------------------------#
FUNCTION pol0788_carrega_val_mdo()
#---------------------------------#  

   DECLARE cq_wfat_nat CURSOR FOR
    SELECT b.ies_tip_controle
      FROM wfat_item_fiscal a, nat_operacao b
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
                 wfat_item_fiscal b,
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
          CALL pol0788_insert_array(p_des_texto,3)
       END IF
     END IF   
   END IF

END FUNCTION

#----------------------------------#
FUNCTION pol0788_trata_zona_franca()
#-----------------------------------#  

   DEFINE p_valor         CHAR(08), 
          p_valor_pis     DEC(15,2), 
          p_valor_cofins  DEC(15,2), 
          p_val_desc_merc DEC(15,2), 
          p_pct_pis       DEC(5,2),
          p_pct_cofins    DEC(5,2),
          l_coef          DEC(7,6),
          l_bas_pis       DEC(15,2)
   
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
         LET p_des_texto = "PIS: ", p_pct_pis, " % = R$ ", p_valor_pis USING "##,###,##&.&&"
      END IF

      IF p_valor_cofins > 0 THEN
         IF p_des_texto IS NULL THEN
            LET p_des_texto = "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "##,###,##&.&&"
         ELSE
            LET p_des_texto = p_des_texto CLIPPED, ' - ', 
                              "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "##,###,##&.&&"
         END IF
      END IF
      
      IF p_des_texto IS NOT NULL THEN
         CALL pol0788_insert_array(p_des_texto,3)
      END IF
   END IF   

   IF ((p_clientes.ies_zona_franca = "S" OR p_clientes.ies_zona_franca = "A") AND
        p_clientes.num_suframa > 0 AND p_wfat_mestre.val_desc_merc > 0) THEN
      LET p_des_texto = "R$ ",p_val_desc_merc USING "##,###,##&.&&",
                        " - ", p_wfat_mestre.pct_icm USING "#&.&", 
                        " % ICMS COMO SE DEVIDO FOSSE"
      CALL pol0788_insert_array(p_des_texto,3)
      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&"
      CALL pol0788_insert_array(p_des_texto,3)
   END IF   
END FUNCTION

#-----------------------------------#
FUNCTION pol0788_grava_corpo_nota()
#-----------------------------------#

   DEFINE i,j        SMALLINT,
          p_pes_unit LIKE item.pes_unit,    
          p_pes_tot  LIKE item.pes_unit


   LET p_num_seq = 0               

   FOR i = 1 TO 999

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      INITIALIZE p_den_item5,
                 p_den_item6,
                 p_den_item7,
                 p_den_item8,
                 p_den_item9,
                 p_den_item10,
                 p_den_item11,
                 p_den_item12,
                 p_den_item13,
                 p_den_item14,
                 p_todos_textos TO NULL

      LET p_den_item5 = pa_corpo_nff[i].den_item1[1,52]
      LET p_den_item6 = pa_corpo_nff[i].den_item1[53,104]
      LET p_den_item7 = pa_corpo_nff[i].den_item1[105,120]

      LET p_todos_textos = p_den_item6 CLIPPED," ",
                           p_den_item7 CLIPPED," ",
                           pa_corpo_nff[i].den_item2 CLIPPED," ",
                           pa_corpo_nff[i].den_item3 CLIPPED," ",
                           pa_corpo_nff[i].den_item4 CLIPPED," ",
                           pa_corpo_nff[i].den_item5 CLIPPED

      LET p_den_item8  = p_todos_textos[1,52]
      LET p_den_item9  = p_todos_textos[53,104]
      LET p_den_item10 = p_todos_textos[105,156]
      LET p_den_item11 = p_todos_textos[157,208]
      LET p_den_item12 = p_todos_textos[209,260]
      LET p_den_item13 = p_todos_textos[261,312]
      LET p_den_item14 = p_todos_textos[313,364]
      LET p_den_item15 = p_todos_textos[365,416]             
     
      IF p_den_item5 IS NOT NULL OR
         p_den_item5 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       1,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item5,
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
      {IF p_den_item6 IS NOT NULL OR
         p_den_item6 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item6,
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
      IF p_den_item7 IS NOT NULL OR 
         p_den_item7 <> " "  THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item7,
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
      END IF}
      IF p_den_item8 IS NOT NULL OR 
         p_den_item8 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item8,
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
      IF p_den_item9 IS NOT NULL OR 
         p_den_item9 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item9,
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
      IF p_den_item10 IS NOT NULL OR
         p_den_item10 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item10,
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
      IF p_den_item11 IS NOT NULL OR
         p_den_item11 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item11,
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
      IF p_den_item12 IS NOT NULL OR
         p_den_item12 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item12,
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
      IF p_den_item13 IS NOT NULL OR
         p_den_item13 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item13,
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
      IF p_den_item14 IS NOT NULL OR
         p_den_item14 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item14,
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
      IF p_den_item15 IS NOT NULL OR
         p_den_item15 <> " " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,
                                       2,
                                       pa_corpo_nff[i].cod_item,
                                       p_den_item15,
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
         
      IF pa_corpo_nff[i].num_pedido_cli IS NOT NULL OR
         pa_corpo_nff[i].num_pedido_cli <> " " THEN

         INSERT INTO pedidos_temp VALUES (p_cod_empresa,
                                          pa_corpo_nff[i].num_pedido_cli)    
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
              INSERT INTO wnotalev VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,NULL,
                                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                           p_des_texto,NULL)
            END FOREACH
         #ELSE
         #   LET p_des_texto = "Peso :  "  , p_pes_tot
         #	
         #   LET p_num_seq = p_num_seq + 1
         #   INSERT INTO wnotalev VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,NULL,
         #                                NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
         # 0                                p_des_texto,NULL)
         END IF
      END IF   
   END FOR

END FUNCTION

#-----------------------------------------#
FUNCTION pol0788_calcula_total_de_paginas()
#-----------------------------------------#

   { No corpo da nota fiscal da squadroni cabem 30 linhas
     A squadroni imprime no corpo da NF os itens, nº de lotes/PV/PC, 
     endereço de entrega, PIS e COFINS, ou sejam, informações da 
     tabela temporária WNOTALEV com ies_tip_info = 1/2/3
     Os texto históricos (ies_tip_info = 4 da WNOTALEV), a classificação
     fiscal e os dados do representante são impressos nos dados adicionais}

   SELECT COUNT(*)
     INTO p_num_linhas
     FROM wnotalev
    WHERE ies_tip_info < 4 

   IF p_num_linhas > 0 THEN 
 
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 30 )) / 30
  
      IF (p_num_linhas MOD 30 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_saltar_linhas = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0788_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM clientes, cidades, subst_trib_uf
    WHERE clientes.cod_cliente        = p_wfat_mestre.cod_cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder

END FUNCTION

#-----------------------------#
FUNCTION pol0788_den_nat_oper()
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

#----------------------------------#
FUNCTION pol0788_busca_cof_compl()
#----------------------------------#

   INITIALIZE p_cod_fiscal_compl TO NULL

   WHENEVER ERROR CONTINUE
   SELECT cod_fiscal_compl
     INTO p_cod_fiscal_compl
     FROM fiscal_par_compl
    WHERE cod_empresa   = p_cod_empresa
      AND cod_nat_oper  = p_wfat_mestre.cod_nat_oper
      AND cod_uni_feder = p_cidades.cod_uni_feder

   IF SQLCA.sqlcode <> 0 THEN
      INITIALIZE p_cod_fiscal_compl TO NULL
   END IF
   WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------#
FUNCTION pol0788_busca_dados_empresa()            
#-------------------------------------#
   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
     INTO p_empresa.*
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   WHENEVER ERROR STOP
END FUNCTION

#-------------------------------#
FUNCTION pol0788_representante()
#-------------------------------#
   DEFINE p_nom_guerra LIKE representante.nom_guerra

   SELECT nom_guerra
     INTO p_nom_guerra
     FROM representante
    WHERE cod_repres = p_wfat_mestre.cod_repres

   RETURN p_nom_guerra
   
END FUNCTION
 
#------------------------------#
FUNCTION pol0788_especie(p_ind)
#------------------------------#

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
FUNCTION pol0788_den_cnd_pgto()
#-----------------------------#
   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(05,3)

   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,
          pct_desp_finan
     INTO p_den_cnd_pgto,
          p_pct_desp_finan
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_wfat_mestre.cod_cnd_pgto
   WHENEVER ERROR STOP

   LET p_nff.den_cnd_pgto = p_den_cnd_pgto
 
   IF p_pct_desp_finan IS NOT NULL
      AND p_pct_desp_finan > 1 THEN
      LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
      LET p_des_texto = "ENCARGO FINANCEIRO: ",  p_pct_enc_finan USING "#&.&&&"," %"
      CALL pol0788_insert_array(p_des_texto,3)
   END IF 
   #RETURN p_den_cnd_pgto
END FUNCTION 

#--------------------------------------------------#
FUNCTION pol0788_busca_dados_clientes()
#--------------------------------------------------#

   INITIALIZE p_clientes.* TO NULL
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_wfat_mestre.cod_cliente

END FUNCTION

#--------------------------------#
FUNCTION pol0788_busca_nome_pais()                   
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
FUNCTION pol0788_busca_dados_transport(p_cod_transpor)
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
FUNCTION pol0788_busca_dados_cidades(p_cod_cidade)
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
FUNCTION pol0788_busca_dados_pedido()
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
FUNCTION pol0788_grava_dados_consig()
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

#----------------------------------------#
FUNCTION pol0788_grava_dados_end_entrega()
#----------------------------------------#

   SELECT wfat_end_ent.end_entrega,
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

   {IF p_end_entrega.end_entrega IS NOT NULL THEN
      LET p_des_texto = "ENDERECO DE ENTREGA: ", p_end_entrega.end_entrega 
                        CLIPPED," ", p_end_entrega.num_cgc," ", 
                        p_end_entrega.ins_estadual,
                        " ",p_end_entrega.den_cidade CLIPPED, " ", 
                        p_end_entrega.cod_uni_feder
      CALL pol0788_insert_array(p_des_texto,3)
   END IF }

END FUNCTION

#------------------------------------------#
FUNCTION pol0788_grava_historico_nf_pedido()
#------------------------------------------#

   IF p_wfat_mestre.cod_texto1 <> 0 OR
      p_wfat_mestre.cod_texto2 <> 0 OR   
      p_wfat_mestre.cod_texto3 <> 0 THEN
      DECLARE cq_texto_nf CURSOR FOR
       SELECT des_texto
         FROM texto_nf
        WHERE cod_texto IN (p_wfat_mestre.cod_texto1,
                            p_wfat_mestre.cod_texto2,
                            p_wfat_mestre.cod_texto3)

      FOREACH cq_texto_nf INTO p_des_texto
         IF LENGTH(p_des_texto) > 60 THEN 
            INITIALIZE p_des_texto2, p_des_texto3 TO NULL
            LET p_des_texto2 = p_des_texto[1,60]
            LET p_des_texto3 = p_des_texto[61,120]
            CALL pol0788_insert_array(p_des_texto2,4)
            CALL pol0788_insert_array(p_des_texto3,4)
         ELSE
            CALL pol0788_insert_array(p_des_texto,4)
         END IF
      END FOREACH               
   END IF

   END FUNCTION
   
#----------------------------------------#
FUNCTION pol0788_checa_nf_contra_ordem()
#----------------------------------------#

   DECLARE cq_nf_ref CURSOR FOR
    SELECT * 
      FROM nf_referencia
     WHERE cod_empresa = p_cod_empresa
       AND num_pedido = pa_corpo_nff[1].num_pedido
       AND (num_nff = p_wfat_mestre.num_nff OR 
            num_nff_ref = p_wfat_mestre.num_nff)

   FOREACH cq_nf_ref INTO p_nf_referencia.*

      IF p_nf_referencia.num_nff IS NOT NULL THEN 
         LET p_des_texto = "N.F. DE VENDA Nro. ", p_nf_referencia.num_nff 
             USING "&&&&&&", " DE ", p_wfat_mestre.dat_emissao
         CALL pol0788_insert_array(p_des_texto,4)
      END IF
      IF p_nf_referencia.num_nff_ref IS NOT NULL THEN 
         LET p_des_texto = "N.F. DE REMESSA Nro. ", p_nf_referencia.num_nff_ref
             USING "&&&&&&"
         CALL pol0788_insert_array(p_des_texto,4)
      END IF

   END FOREACH               
   
END FUNCTION

#------------------------------#
#FUNCTION pol0788_dev_mat_terc()
#------------------------------#

   {DEFINE p_serie         CHAR(15),
          p_seq_ar        DECIMAL(3,0),
          p_seq_tabulacao DECIMAL(3,0),
          p_tem_mat       SMALLINT

   INITIALIZE p_des_texto TO NULL
   LET p_qtd_tot_dev = 0
   LET p_val_tot_mat = 0
   LET p_tem_mat = FALSE

   DECLARE cq_dev_terc CURSOR FOR
    SELECT nf_entrada,
           serie_nf_entrada,
           subserie_nfe,
           especie_nf_entrada,
           seq_aviso_recebto,
           seq_tabulacao,
           qtd_devolvida
      FROM fat_retn_terc_grd
     WHERE empresa           = p_cod_empresa
       AND nota_fiscal       = p_nff.num_nff
       AND fornecedor        = p_nff.cod_cliente

   FOREACH cq_dev_terc INTO
           p_num_nf,
           p_ser_nf,
           p_ssr_nf,
           p_ies_especie_nf,
           p_seq_ar,         
           p_seq_tabulacao,     
           p_qtd_devolvida

      SELECT serie
        INTO p_serie
        FROM sup_item_terc_end
       WHERE empresa          = p_cod_empresa
        AND nota_fiscal       = p_num_nf
        AND serie_nota_fiscal = p_ser_nf
        AND subserie_nf       = p_ssr_nf
        AND espc_nota_fiscal  = p_ies_especie_nf
        AND fornecedor        = p_nff.cod_cliente
        AND seq_aviso_recebto = p_seq_ar
        AND seq_tabulacao     = p_seq_tabulacao

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","SUP_ITEM_TERC_END")
         RETURN FALSE
      END IF
              
      SELECT dat_emis_nf,
             cod_item,
             cod_unid_med,
             val_remessa,
             qtd_tot_recebida
        INTO p_dat_emis_nf,
             p_cod_material,
             p_cod_unid_med,
             p_val_remessa,
             p_qtd_remessa
        FROM item_de_terc
       WHERE cod_empresa    = p_cod_empresa
  		   AND num_nf         = p_num_nf
				 AND ser_nf         = p_ser_nf
				 AND ssr_nf         = p_ssr_nf
				 AND ies_especie_nf = p_ies_especie_nf
				 AND num_sequencia  = p_seq_ar
				 AND cod_fornecedor = p_nff.cod_cliente
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEITURA","ITEM_DE_TERC")
         RETURN FALSE
      END IF
              
      LET p_val_mat_dev = p_qtd_devolvida * p_val_remessa / p_qtd_remessa
      
      CALL pol0788_le_cliente_item(p_cod_material)

      LET p_cod_material = g_tex_complementar
      LET p_des_texto = ' - NF ', p_num_nf, ' de ', p_dat_emis_nf

      IF p_serie IS NOT NULL THEN
         IF p_cod_moeda = 2 THEN
            LET p_des_texto = p_des_texto CLIPPED, ' ',p_serie
         ELSE
            LET p_des_texto = p_des_texto CLIPPED, ' Lote:',p_serie
         END IF
      END IF
      
      LET p_qtd_tot_dev = p_qtd_tot_dev + p_qtd_devolvida
      LET p_val_tot_mat = p_val_tot_mat + p_val_mat_dev
      LET p_tem_mat = TRUE

   END FOREACH

   IF p_tem_mat THEN
      CALL pol0788_insert_array("",4)
      LET p_des_texto ='MATERIAL RECEBIDO COM SUA NF'
      CALL pol0788_insert_array(p_des_texto,4)
   END IF

   DECLARE cq_ret CURSOR FOR
    SELECT cod_material,
           des_texto
      FROM ret_mat_1072
     ORDER BY cod_material
     
   FOREACH cq_ret INTO 
           p_cod_material,
           p_des_texto   
   
      LET p_des_texto = p_cod_material, p_des_texto
      
      CALL pol0788_insert_array(p_des_texto,4)
        
   END FOREACH
   
   IF p_qtd_tot_dev > 0 OR p_val_tot_mat > 0 THEN
      LET p_des_texto = '               ------------          ---------------'
      CALL pol0788_insert_array(p_des_texto,4)
      LET p_des_texto = '               ',p_qtd_tot_dev,
                        '          ',p_val_tot_mat
      CALL pol0788_insert_array(p_des_texto,4)
   END IF
   
END FUNCTION
}

#---------------------------------------#
FUNCTION pol0788_verifica_texto_ped_it()
#---------------------------------------#

   INITIALIZE pa_texto_ped_ite[1].texto,
              pa_texto_ped_it[1].texto,
              pa_texto_ped_it[2].texto,
              pa_texto_ped_it[3].texto,
              pa_texto_ped_it[4].texto,
              pa_texto_ped_it[5].texto,
              p_ped_itens_texto TO NULL

   SELECT des_esp_item[1,30]
     INTO pa_texto_ped_ite[1].texto
     FROM item_esp        
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_wfat_item.cod_item
      AND num_seq     = 1
      
   IF SQLCA.sqlcode <> 0 THEN
      LET pa_texto_ped_ite[1].texto = NULL
   END IF

   SELECT *
     INTO p_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_wfat_item.num_pedido
      AND num_sequencia = p_wfat_item.num_sequencia
  
   IF SQLCA.sqlcode <> 0 THEN 
      LET pa_texto_ped_it[1].texto = NULL
      LET pa_texto_ped_it[2].texto = NULL
      LET pa_texto_ped_it[3].texto = NULL
      LET pa_texto_ped_it[4].texto = NULL
      LET pa_texto_ped_it[5].texto = NULL
   ELSE
      LET pa_texto_ped_it[1].texto = p_ped_itens_texto.den_texto_1
      LET pa_texto_ped_it[2].texto = p_ped_itens_texto.den_texto_2
      LET pa_texto_ped_it[3].texto = p_ped_itens_texto.den_texto_3
      LET pa_texto_ped_it[4].texto = p_ped_itens_texto.den_texto_4
      LET pa_texto_ped_it[5].texto = p_ped_itens_texto.den_texto_5
   END IF
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol0788_le_cliente_item(p_codi_item)
#-------------------------------------------#

   DEFINE p_codi_item LIKE item.cod_item
   
   INITIALIZE g_cod_item_cliente,
              g_tex_complementar TO NULL
 
   SELECT cod_item_cliente,
          tex_complementar
     INTO g_cod_item_cliente,
          g_tex_complementar
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_codi_item

END FUNCTION

#------------------------------------------------#
FUNCTION pol0788_insert_array(p_des_texto,p_info)
#------------------------------------------------#

   DEFINE p_des_texto CHAR(120),
          p_info      SMALLINT
   
   LET p_tip_info = p_info
   LET p_num_seq  = p_num_seq + 1

   INSERT INTO wnotalev
      VALUES (p_num_seq,p_tip_info,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
              NULL,NULL,p_des_texto,NULL)
END FUNCTION   

#-----------------------------#
REPORT pol0788_relat(p_num_nff)
#-----------------------------#

   DEFINE i            SMALLINT,
          l_nulo       CHAR(10),
          p_nf_ant     DECIMAL(7,0),
          p_cont_nf_rt SMALLINT,
          p_num_nff    LIKE wfat_mestre.num_nff

   DEFINE p_for        SMALLINT,
          p_sal        SMALLINT,
          p_des_folha  CHAR(100)

   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   93

   ORDER EXTERNAL BY p_num_nff
  
   FORMAT

      PAGE HEADER

      LET p_num_pagina = p_num_pagina + 1
      PRINT p_8lpp, p_comprime
      
      SKIP 2 LINES
      PRINT COLUMN 130, p_nff.num_nff USING "&&&&&&"
      SKIP 2 LINES
      PRINT COLUMN 095, "X"
      SKIP 6 LINES

      IF p_nff.cod_fiscal1 IS NOT NULL THEN
         PRINT COLUMN 005, p_nff.den_nat_oper[1,20] CLIPPED,"/",p_nff.den_nat_oper1[1,20] CLIPPED,
               COLUMN 053, p_nff.cod_fiscal         USING "&&&&",
               COLUMN 057, "/",
               COLUMN 058, p_nff.cod_fiscal1        USING "&&&&",
               COLUMN 100, p_nff.ins_estadual_trib    
      ELSE
         PRINT COLUMN 005, p_nff.den_nat_oper[1,30],
               COLUMN 053, p_nff.cod_fiscal USING "&&&&",
               COLUMN 100, p_nff.ins_estadual_trib
      END IF 

      SKIP 3 LINES
      PRINT COLUMN 006, p_nff.nom_destinatario, 
            COLUMN 100, p_nff.num_cgc_cpf,
            COLUMN 125, p_nff.dat_emissao USING "DD/MM/YYYY"
      SKIP 2 LINES
      PRINT COLUMN 006, p_nff.end_destinatario,
            COLUMN 075, p_nff.den_bairro,
            COLUMN 105, p_nff.cod_cep
            #COLUMN 071, TODAY USING "DD/MM/YYYY"
      SKIP 1 LINES 
      PRINT COLUMN 006, p_nff.den_cidade[1,22],
            COLUMN 060, p_nff.num_telefone[1,13],
            COLUMN 087, p_nff.cod_uni_feder,
            COLUMN 108, p_nff.ins_estadual
            #COLUMN 071, TIME
      SKIP 3 LINES
 
      IF p_nff.val_duplic3 <> 0 THEN
         PRINT COLUMN 033, p_nff.dat_vencto_sd1 USING "DD/MM/YYYY",
               COLUMN 046, p_nff.val_duplic1    USING "####,###,##&.&&",
               COLUMN 072, p_nff.dat_vencto_sd2 USING "DD/MM/YYYY",
               COLUMN 084, p_nff.val_duplic2    USING "####,###,##&.&&",
               COLUMN 112, p_nff.dat_vencto_sd3 USING "DD/MM/YYYY",
               COLUMN 124, p_nff.val_duplic3    USING "####,###,##&.&&"
      ELSE
         IF p_nff.val_duplic2 <> 0 THEN 
            PRINT COLUMN 030, p_nff.dat_vencto_sd1 USING "DD/MM/YYYY",
                  COLUMN 046, p_nff.val_duplic1    USING "####,###,##&.&&",
                  COLUMN 072, p_nff.dat_vencto_sd2 USING "DD/MM/YYYY",
                  COLUMN 084, p_nff.val_duplic2    USING "####,###,##&.&&"
         ELSE
            IF p_nff.val_duplic1 <> 0 THEN
               PRINT COLUMN 030, p_nff.dat_vencto_sd1 USING "DD/MM/YYYY",
                     COLUMN 046, p_nff.val_duplic1    USING "####,###,##&.&&"
            ELSE
               PRINT
            END IF       
         END IF
      END IF

      IF p_nff.val_duplic6 <> 0 THEN
         PRINT COLUMN 033, p_nff.dat_vencto_sd4 USING "DD/MM/YYYY",
               COLUMN 046, p_nff.val_duplic4    USING "####,###,##&.&&",
               COLUMN 072, p_nff.dat_vencto_sd5 USING "DD/MM/YYYY",
               COLUMN 084, p_nff.val_duplic5    USING "####,###,##&.&&",
               COLUMN 112, p_nff.dat_vencto_sd6 USING "DD/MM/YYYY",
               COLUMN 124, p_nff.val_duplic6    USING "####,###,##&.&&"
      ELSE
         IF p_nff.val_duplic5 <> 0 THEN 
            PRINT COLUMN 030, p_nff.dat_vencto_sd4 USING "DD/MM/YYYY",
                  COLUMN 046, p_nff.val_duplic4    USING "####,###,##&.&&",
                  COLUMN 072, p_nff.dat_vencto_sd5 USING "DD/MM/YYYY",
                  COLUMN 084, p_nff.val_duplic5    USING "####,###,##&.&&"
         ELSE
            IF p_nff.val_duplic4 <> 0 THEN
               PRINT COLUMN 030, p_nff.dat_vencto_sd4 USING "DD/MM/YYYY",
                     COLUMN 046, p_nff.val_duplic4    USING "####,###,##&.&&"
            ELSE
               PRINT
            END IF       
         END IF
      END IF
      
      SKIP 1 LINES

   BEFORE GROUP OF p_num_nff
      SKIP TO TOP OF PAGE
   ON EVERY ROW

      INITIALIZE p_den_item, p_cod_item_cliente TO NULL
      CASE
         WHEN p_wnotalev.ies_tip_info = 1   
            PRINT COLUMN 005, p_wnotalev.cod_item,
                  COLUMN 030, p_wnotalev.den_item[1,52],
                  COLUMN 065, p_cod_ref_clas  USING "&",
                  COLUMN 068, p_wnotalev.cod_origem USING "&",    
                  COLUMN 069, p_wnotalev.cod_tributacao USING "&&",
                  COLUMN 078, p_wnotalev.cod_unid_med,
                  COLUMN 082, p_wnotalev.qtd_item USING "#####&",
                  COLUMN 089, p_wnotalev.pre_unit USING "##,###,##&.&&&&";
            IF p_nff.cod_uni_feder = "AM" AND 
               (p_clientes.ies_zona_franca = "S" OR  p_clientes.ies_zona_franca = "A") THEN
               PRINT COLUMN 105, p_wnotalev.val_liq_item USING "##,###,##&.&&",
                     COLUMN 117, p_wfat_mestre.pct_icm USING "#&"
            ELSE  
               PRINT COLUMN 105, p_wnotalev.val_liq_item USING "##,###,##&.&&",
                     COLUMN 117, p_wnotalev.pct_icm USING "#&.&&",
                     COLUMN 122, p_wnotalev.pct_ipi USING "#&.&&",
                     COLUMN 126, p_wnotalev.val_ipi USING "##,###,##&.&&"
            END IF
            LET p_linhas_print = p_linhas_print + 1
        
         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 008, p_wnotalev.den_item[1,52]
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 3
            PRINT COLUMN 008, p_wnotalev.des_texto 
            LET p_linhas_print = p_linhas_print + 1
              
         WHEN p_wnotalev.ies_tip_info = 5
            WHILE TRUE
               IF p_linhas_print < 30 THEN 
                  PRINT 
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF          
            END WHILE
      END CASE
#---------------------------------------------------------------------------
      IF p_linhas_print = 30 THEN { nr. de linhas do corpo da nota }
         IF p_num_pagina = p_tot_paginas THEN 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&" 
         ELSE 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&"," - Continua" 
         END IF
         IF p_num_pagina = p_tot_paginas THEN 
            PRINT COLUMN 040, p_des_folha 
            SKIP 1 LINES  
            PRINT COLUMN 013, p_nff.val_tot_base_icm    USING "###,###,##&.&&",
                  COLUMN 040, p_nff.val_tot_icm         USING "###,###,##&.&&",
                  COLUMN 070, p_nff.val_tot_base_ret    USING "###,###,##&.&&",
                  COLUMN 097, p_nff.val_tot_icm_ret     USING "###,###,##&.&&",
                  COLUMN 123, p_nff.val_tot_mercadoria  USING "###,###,##&.&&"
            SKIP 1 LINES  
            PRINT COLUMN 013, p_nff.val_frete_cli       USING "###,###,##&.&&", 
                  COLUMN 040, p_nff.val_seguro_cli      USING "###,###,##&.&&",
                  COLUMN 070, p_nff.val_tot_despesas    USING "###,###,##&.&&",
                  COLUMN 097, p_nff.val_tot_ipi         USING "###,###,##&.&&",
                  COLUMN 123, p_nff.val_tot_nff         USING "###,###,##&.&&"
            SKIP 4 LINES
            PRINT COLUMN 007, p_nff.nom_transpor,                  
                  COLUMN 070, p_nff.ies_frete USING "&",
                  COLUMN 080, p_nff.num_placa,
                  COLUMN 088, p_nff.cod_uni_feder_trans,
                  COLUMN 118, p_nff.num_cgc_trans
            SKIP 1 LINES
            PRINT COLUMN 007, p_nff.end_transpor[1,32],
                  COLUMN 066, p_nff.den_cidade_trans[1,22],   
                  COLUMN 088, p_nff.cod_uni_feder_trans,
                  COLUMN 120, p_nff.ins_estadual_trans   
            SKIP 2 LINES
            PRINT COLUMN 007, p_qtd_volumes,
                  COLUMN 017, p_des_especie,
                  COLUMN 049, p_nff.den_marca,
                  COLUMN 092, p_nff.num_nff          USING "&&&&&&",
                  COLUMN 105, p_nff.pes_tot_bruto    USING "###,##&.&&&",
                  COLUMN 123, p_nff.pes_tot_liquido  USING "###,##&.&&&"
            LET p_num_pagina = 0
            #SKIP 10 LINES

            {PRINT COLUMN 006, p_txt[1].texto,
                  COLUMN 125, p_txt_pedido[1].pedido
            PRINT COLUMN 006, p_txt[2].texto,
                  COLUMN 125, p_txt_pedido[2].pedido
            PRINT COLUMN 006, p_txt[3].texto,
                  COLUMN 125, p_txt_pedido[3].pedido
            PRINT COLUMN 006, p_txt[4].texto,
                  COLUMN 125, p_txt_pedido[4].pedido
            PRINT COLUMN 006, p_txt[5].texto,
                  COLUMN 125, p_txt_pedido[5].pedido
            PRINT COLUMN 006, p_txt[6].texto,
                  COLUMN 125, p_txt_pedido[6].pedido
            PRINT COLUMN 006, p_txt[7].texto,
                  COLUMN 125, p_nff.den_cnd_pgto
            PRINT COLUMN 006, p_txt[8].texto}
            SKIP 16 LINES
            PRINT COLUMN 110, p_nff.num_nff USING "&&&&&&" 
            LET p_num_pagina = 0
         ELSE 
            PRINT COLUMN 040, p_des_folha 
            PRINT
            PRINT COLUMN 013, "**************",
                  COLUMN 040, "**************",
                  COLUMN 070, "**************",
                  COLUMN 097, "**************",
                  COLUMN 123, "**************"
            SKIP 1 LINES 
            PRINT COLUMN 013, "**************", 
                  COLUMN 040, "**************",
                  COLUMN 070, "**************",
                  COLUMN 097, "**************",
                  COLUMN 123, "**************"
            SKIP 26 LINES
            PRINT COLUMN 110, p_nff.num_nff USING "&&&&&&"
            SKIP TO TOP OF PAGE
         END IF
         LET p_linhas_print = 0
      END IF

END REPORT
#------------------------------- FIM DE PROGRAMA ------------------------------#