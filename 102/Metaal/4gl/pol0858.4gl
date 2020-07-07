#---------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: POL0858                                                         #
# MODULOS.: POL0858  - LOG0010 - LOG0040 - LOG0050 - LOG0060                #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                          #
# OBJETIVO: IMPRESSAO DAS NOTAS FISCAIS FATURA - SAIDA - METAAL             #
# AUTOR...: ANA PAULA                                                       #
# DATA....: 15/10/2008                                                      #
# ALTERADO: MOTIVO                                                          #
# 09/12/08  Imprimir num NF venda no texto da NF contra ordem               #
#           não agrupar itens iguais no corpo da NF                         #
# 14/05/09: Não considerar o texto da tab item_esp, se o mesmo for = espaços#
# 30/06/09: acerto de erro na rotina impressão da classificação fiscal      #
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
          i                        SMALLINT,
          p_texto_item_ped         CHAR(80),   
          p_cod_reduz              CHAR(01),
          p_ret_terc               SMALLINT,
          p_pct_icms               DECIMAL(5,2),
          p_cod_texto              LIKE fiscal_hist.cod_hist,
          p_cod_item_cliente       LIKE cliente_item.cod_item_cliente,
          g_tex_complementar       LIKE cliente_item.tex_complementar,
          p_val_duplic             LIKE fat_nf_duplicata.val_duplicata,
          p_cod_moeda              LIKE pedidos.cod_moeda,
          p_sit_nota_fiscal        LIKE fat_nf_mestre.sit_nota_fiscal,
          p_cods_fiscal            CHAR(18),
          p_imprime_nf             SMALLINT,
          p_val_cotacao            DECIMAL(12,2),
          p_val_cotacao_imp        CHAR(20),
          p_den_nat_oper           CHAR(52),
          p_den2_nat_oper          CHAR(20),
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
          p_num_nff_ini            LIKE fat_nf_mestre.nota_fiscal,       
          p_num_nff_fim            LIKE fat_nf_mestre.nota_fiscal,       
          p_num_lote               CHAR(37),                        
          p_num_lot                CHAR(15),                        
          p_num_reserva            LIKE ordem_montag_grade.num_reserva,
          p_cod_fiscal             LIKE fat_nf_item_fisc.cod_fiscal,    
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
          p_qtd_item               LIKE fat_nf_item.qtd_item,
          p_pre_unit_nf            LIKE fat_nf_item.preco_unit_liquido,
          p_pre_tot_nf             LIKE fat_nf_mestre.val_nota_fiscal,
          p_unid_med               LIKE item.cod_unid_med, 
          p_den_motivo_remessa     LIKE motivo_remessa.den_motivo_remessa,
          p_cod_fiscal_compl       DECIMAL(1,0),
          p_unid_terc              CHAR(03),
          p_den_item_cli           LIKE item.den_item_reduz,
          p_val_unit               DECIMAL(12,6),
          p_val_remessa            LIKE item_de_terc.val_remessa,
          p_cod_item               LIKE fat_nf_item.item,
          p_num_pedido             CHAR(25),
          p_txt_ped                CHAR(25),
          p_txta                   CHAR(90),
          p_txtb                   CHAR(90),
          p_todos_textos           CHAR(416),
          p_cod_cla_reduz          CHAR(01)
          
   DEFINE p_fat_nf_mestre        RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_item          RECORD LIKE fat_nf_item.*,
          p_fat_nf_item_fisc     RECORD LIKE fat_nf_item_fisc.*,
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
          p_nf_referencia        RECORD LIKE nf_referencia.*,
          p_fat_nf_end_entrega   RECORD LIKE fat_nf_end_entrega.*,
          p_fat_mestre_fiscal    RECORD LIKE fat_mestre_fiscal.*

   {variaveis utilizadas para separar textos longos. Na NF }
   {é possivel imprimir até 75 caracteres por linha de texto}
   
   DEFINE p_texto_1          CHAR(75),
          p_texto_2          CHAR(75),
          p_texto_3          CHAR(75),
          p_texto_4          CHAR(75)
   #--------------------------------------------------------#
   
   DEFINE p_nff       
          RECORD
             num_nff             LIKE fat_nf_mestre.nota_fiscal,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             den_nat_oper1       LIKE nat_operacao.den_nat_oper, 
             cod_fiscal          LIKE fat_nf_item_fisc.cod_fiscal,
             cod_fiscal1         LIKE fat_nf_item_fisc.cod_fiscal,
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         DATETIME DAY TO MINUTE,
             nom_destinatario    LIKE clientes.nom_cliente,
             num_cgc_cpf         LIKE clientes.num_cgc_cpf,
             dat_saida           DATETIME DAY TO MINUTE,
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

             num_dig_duplic1     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata1      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd1      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic1         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic2     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata2      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd2      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic2         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic3     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata3      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd3      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic3         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic4     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata4      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd4      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic4         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic5     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata5      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd5      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic5         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic6     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata6      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd6      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic6         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic7     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata7      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd7      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic7         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic8     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata8      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd8      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic8         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic9     LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata9      LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd9      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic9         LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic10    LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata10     LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd10     LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic10        LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic11    LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata11     LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd11     LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic11        LIKE fat_nf_duplicata.val_duplicata,

             num_dig_duplic12    LIKE fat_nf_duplicata.docum_cre,
             seq_duplicata12     LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd12     LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic12        LIKE fat_nf_duplicata.val_duplicata,

             val_extenso1        CHAR(130),
             val_extenso2        CHAR(130),
             val_extenso3        CHAR(001), 
             val_extenso4        CHAR(001),

             end_cob_cli         LIKE cli_end_cob.end_cobr,
             cod_uni_feder_cobr  LIKE cidades.cod_uni_feder,
             den_cidade_cob      LIKE cidades.den_cidade,

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_base_icm    LIKE fat_mestre_fiscal.bc_trib_mercadoria,
             val_tot_icm         LIKE fat_mestre_fiscal.val_trib_merc,
             val_tot_base_ret    LIKE fat_mestre_fiscal.bc_trib_mercadoria,
             val_tot_icm_ret     LIKE fat_mestre_fiscal.val_trib_merc,
             val_tot_mercadoria  LIKE fat_nf_mestre.val_mercadoria,
             val_frete_cli       LIKE fat_nf_mestre.val_frete_cliente,
             val_seguro_cli      LIKE fat_nf_mestre.val_seguro_cliente,
             val_out_despesas    LIKE fat_nf_mestre.val_seguro_cliente,
             val_tot_ipi         LIKE fat_mestre_fiscal.val_tributo_tot,
             val_tot_nff         LIKE fat_nf_mestre.val_nota_fiscal,

             nom_transpor        LIKE clientes.nom_cliente,
             ies_frete           LIKE fat_nf_mestre.tip_frete,
             num_placa           LIKE fat_nf_mestre.placa_veiculo,
             cod_uni_feder_trans LIKE cidades.cod_uni_feder,
             num_cgc_trans       LIKE clientes.num_cgc_cpf,
             end_transpor        LIKE clientes.end_cliente,
             den_cidade_trans    LIKE cidades.den_cidade,
             ins_estadual_trans  LIKE clientes.ins_estadual,
             #qtd_volumes         LIKE fat_nf_mestre.qtd_volumes1,
             des_especie1        CHAR(06),
             des_especie2        CHAR(06),
             des_especie3        CHAR(06),
             des_especie4        CHAR(06),
             des_especie5        CHAR(06),
             den_marca           LIKE clientes.den_marca,
             num_pri_volume      LIKE fat_nf_mestre.num_prim_volume,
             num_ult_volume      LIKE fat_nf_mestre.num_prim_volume,
             pes_tot_bruto       LIKE fat_nf_mestre.peso_bruto,
             pes_tot_liquido     LIKE fat_nf_mestre.peso_liquido,
             cod_repres          LIKE pedidos.cod_repres,
             nom_guerra          LIKE representante.nom_guerra,
             den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
             num_pedido          LIKE fat_nf_item.pedido,
             num_suframa         LIKE clientes.num_suframa,
             num_om              LIKE fat_nf_item.ord_montag,
             num_pedido_repres   LIKE pedidos.num_pedido_repres,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             nat_oper            LIKE nat_operacao.cod_nat_oper,
             cod_operacao        LIKE nat_operacao.cod_nat_oper
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE fat_nf_item.item,
             cod_item_cli        LIKE cliente_item.cod_item_cliente,
             num_pedido          LIKE fat_nf_item.pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(76),
             den_item2           CHAR(76),
             cod_fiscal          LIKE nf_item_fiscal.cod_fiscal,
             cod_cla_fisc        CHAR(10),              		
             cod_origem          LIKE fat_nf_item_fisc.origem_produto,
             cod_tributacao      LIKE fat_nf_item_fisc.tributacao,
             pes_unit            LIKE fat_nf_item.peso_unit,
             cod_unid_med        LIKE fat_nf_item.unid_medida,
             qtd_item            LIKE fat_nf_item.qtd_item,
             pre_unit            LIKE fat_nf_item.preco_unit_liquido,
             val_liq_item        LIKE fat_nf_item.val_liquido_item,
             pct_icm             LIKE fat_nf_item_fisc.aliquota,
             pct_ipi             LIKE fat_nf_item_fisc.aliquota,
             val_ipi             LIKE fat_nf_item_fisc.val_trib_merc,
             val_icm_ret         LIKE fat_nf_item_fisc.val_trib_merc,
             num_sequencia       LIKE fat_nf_item.seq_item_nf
          END RECORD

   DEFINE p_wnotalev       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          CHAR(15),
             den_item          CHAR(76),
             num_ped_cli       CHAR(30),
             cod_item_cli      CHAR(30),
             cod_cla_fisc      CHAR(10),               
             cod_origem        LIKE fat_nf_item_fisc.origem_produto,
             cod_tributacao    LIKE fat_nf_item_fisc.tributacao,
             pes_unit          LIKE fat_nf_item.peso_unit,   
             cod_unid_med      LIKE fat_nf_item.unid_medida,
             qtd_item          LIKE fat_nf_item.qtd_item,
             pre_unit          LIKE fat_nf_item.preco_unit_liquido,
             val_liq_item      LIKE fat_nf_item.val_liquido_item,
             pct_icm           LIKE fat_nf_item_fisc.aliquota,
             pct_ipi           LIKE fat_nf_item_fisc.aliquota,
             val_ipi           LIKE fat_nf_item_fisc.val_trib_merc,
             des_texto         CHAR(120),
             num_nff           LIKE fat_nf_mestre.nota_fiscal 
          END RECORD

   DEFINE p_end_entrega 
          RECORD
             end_entrega         LIKE clientes.end_cliente,
             num_cgc             LIKE fat_nf_end_entrega.cnpj_entrega,
             ins_estadual        LIKE fat_nf_end_entrega.inscr_est_entrega,
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

   DEFINE p_classif ARRAY[9]   OF RECORD
          legenda              CHAR(12) 
   END RECORD
 
   DEFINE p_txt              ARRAY[09] OF RECORD 
          texto              CHAR(55)
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
          p_des_texto2               CHAR(80),
          p_des_texto3               CHAR(80),
          p_val_tot_ipi_acum         DECIMAL(15,3)

   DEFINE p_versao                   CHAR(18)
 
   DEFINE g_ies_ambiente             CHAR(001)


   DEFINE r_01 VARCHAR(255),
          r_02 VARCHAR(255),
          r_03 VARCHAR(255),
          r_04 VARCHAR(255),
          r_05 VARCHAR(255),
          r_06 VARCHAR(255),
          r_07 VARCHAR(255),
          r_08 VARCHAR(255),
          r_09 VARCHAR(255),
          r_10 VARCHAR(255),
          r_11 VARCHAR(255),
          r_12 VARCHAR(255),
          r_13 VARCHAR(255)
    
    # parâmetros recebidos #
          
   DEFINE texto      VARCHAR(255),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)

   DEFINE num_carac  SMALLINT,
          ret        VARCHAR(255)


END GLOBALS

   DEFINE g_cod_item_cliente  LIKE cliente_item.cod_item_cliente

   DEFINE g_cla_fisc   ARRAY[10]
          OF RECORD
             num_seq         CHAR(2), 
             cod_cla_fisc    CHAR(10) 
          END RECORD

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0858-31"
   WHENEVER ERROR CONTINUE 
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("pol.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

  
   IF p_status = 0 THEN
      CALL pol0858_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0858_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0858") RETURNING comando    
   OPEN WINDOW w_pol0858 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO empresa

   CALL log085_transacao("BEGIN") 

   IF NOT pol0858_cria_tabs_tmp() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN
   END IF
   
   CALL log085_transacao("COMMIT") 

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0001
         IF pol0858_entrada_parametros() THEN
            LET p_ies_cons = TRUE
            NEXT OPTION "Listar"
         END IF
      COMMAND "Listar" "Lista as Notas Fiscais Fatura"
         HELP 0002
         IF p_ies_cons THEN
            LET p_ies_cons = FALSE
            IF pol0858_imprime_nff() THEN 
               NEXT OPTION "Fim"
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
   CLOSE WINDOW w_pol0858

END FUNCTION

#-----------------------------------#
FUNCTION pol0858_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0858

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
   CURRENT WINDOW IS w_pol0858

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0858_imprime_nff()
#----------------------------#    

   DEFINE p_seq_item_nf INTEGER
   
   IF log028_saida_relat(16,41) IS NOT NULL THEN 
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0858_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0858.tmp' 
            START REPORT pol0858_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0858_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE
   END IF

   CURRENT WINDOW IS w_pol0858

   CALL pol0858_busca_dados_empresa()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 

   IF p_reimpressao = "S" THEN
      LET p_reimpressao = "R"
   END IF

   LET p_imprime_nf = FALSE
   
   DECLARE cq_fat_nf_mestre CURSOR WITH HOLD FOR
   SELECT *
     FROM fat_nf_mestre
    WHERE empresa           = p_cod_empresa
      AND nota_fiscal >= p_num_nff_ini
      AND nota_fiscal <= p_num_nff_fim
      AND tip_nota_fiscal   = "FATPRDSV"  
      AND sit_impressao     = p_reimpressao       
   ORDER BY nota_fiscal

   FOREACH cq_fat_nf_mestre INTO p_fat_nf_mestre.*

      IF p_fat_nf_mestre.sit_nota_fiscal <> 'N' THEN
         CONTINUE FOREACH
      END IF

      DISPLAY p_fat_nf_mestre.nota_fiscal TO num_nff_proces 

      CALL log085_transacao("BEGIN") 
      IF NOT pol0858_deleta_tabs_tmp() THEN
         CALL log0030_mensagem('Erro deletando tabelas temporárias','excla')
         CALL log085_transacao("ROLLBACK") 
         RETURN
      END IF
      CALL log085_transacao("COMMIT") 
      
      INITIALIZE pa_corpo_nff, p_nff TO NULL

      LET p_nff.num_nff       = p_fat_nf_mestre.nota_fiscal
      LET p_nff.cod_fiscal    = NULL 
      LET p_nff.cod_fiscal1   = NULL
      LET p_nff.den_nat_oper  = NULL
      LET p_nff.den_nat_oper1 = NULL
 
      DECLARE cq_codf CURSOR FOR
          
      SELECT DISTINCT 
             cod_fiscal
         FROM fat_nf_item_fisc
        WHERE empresa           = p_cod_empresa
          AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal

      FOREACH cq_codf INTO p_cod_fiscal

         IF p_nff.cod_fiscal IS NULL THEN
            LET p_nff.cod_fiscal   = p_cod_fiscal
            LET p_nff.den_nat_oper = pol0858_den_nat_oper()
            LET p_nff.cod_operacao = p_nat_operacao.cod_movto_estoq
         ELSE
            LET p_nff.cod_fiscal1  = p_cod_fiscal
            EXIT FOREACH
         END IF
      END FOREACH

      LET p_den2_nat_oper = NULL
      
      IF p_nff.cod_fiscal1 IS NOT NULL THEN
         DECLARE cq_seq CURSOR FOR
         SELECT seq_item_nf 
           FROM fat_nf_item_fisc
          WHERE empresa           = p_cod_empresa
            AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
            AND cod_fiscal        = p_nff.cod_fiscal1

         FOREACH cq_seq INTO p_seq_item_nf   
       
            SELECT DISTINCT 
                   natureza_operacao
              INTO p_cod_nat_oper
              FROM fat_nf_item
             WHERE empresa            = p_cod_empresa
               AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
               AND seq_item_nf        = p_seq_item_nf
         
            IF STATUS = 0 THEN
               SELECT den_nat_oper
                 INTO p_den2_nat_oper
                 FROM nat_operacao
                WHERE cod_nat_oper = p_cod_nat_oper
            END IF
           
            LET p_den_nat_oper = p_nff.den_nat_oper[1,20]
            IF p_den2_nat_oper IS NOT NULL THEN
               LET p_den_nat_oper = p_den_nat_oper CLIPPED,"/",p_den2_nat_oper
            END IF               
                                       
            LET p_cods_fiscal =
                p_nff.cod_fiscal using '<<<<', '/', p_nff.cod_fiscal1 using '<<<<'
            
            EXIT FOREACH
            
         END FOREACH
      ELSE
         LET p_den_nat_oper = p_nff.den_nat_oper[1,30]
         LET p_cods_fiscal  = p_nff.cod_fiscal using '<<<<'
      END IF
      
      IF p_nat_operacao.ies_subst_tribut = "S" THEN
         CALL pol0858_busca_dados_subst_trib_uf()
         LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      END IF

      LET p_nff.nat_oper          = p_fat_nf_mestre.natureza_operacao
      LET p_cod_nat_oper          = p_fat_nf_mestre.natureza_operacao
      LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      LET p_nff.dat_emissao       = p_fat_nf_mestre.dat_hor_emissao

      #--- carrega dados do cliente
      CALL pol0858_busca_dados_clientes()
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

      #--- carrega dados da cidade
      CALL pol0858_busca_dados_cidades(p_clientes.cod_cidade)
      
      LET p_nff.den_cidade    = p_cidades.den_cidade          
      LET p_nff.num_telefone  = p_clientes.num_telefone
      LET p_nff.num_telex     = p_clientes.num_telex
      LET p_nff.cod_uni_feder = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual  = p_clientes.ins_estadual
      LET p_nff.hora_saida    = EXTEND(CURRENT, HOUR TO MINUTE)

      #--- codigo fiscal complementar
      CALL pol0858_busca_cof_compl()

      #--- busca nome do pais
      CALL pol0858_busca_nome_pais()
      LET p_nff.den_pais = p_paises.den_pais              

      #--- busca dados das duplicatas
      CALL pol0858_busca_dados_duplicatas()

      #--- busca extenso do valor total da nota
      CALL log038_extenso(p_fat_nf_mestre.val_nota_fiscal,130,130,1,1)
            RETURNING p_nff.val_extenso1, p_nff.val_extenso2,
                      p_nff.val_extenso3, p_nff.val_extenso4

      CALL pol0858_carrega_corpo_nff()

      CALL pol0858_grava_corpo_nota()

      IF p_nat_operacao.ies_tip_controle = "2" THEN
         #CALL pol0858_obtem_peso_item()
      END IF
    
      SELECT cod_repres,
             #num_pedido_repres,
             cod_tip_venda
        INTO p_pedidos.cod_repres,
             #p_pedidos.num_pedido_repres,  
             p_pedidos.cod_tip_venda
        FROM pedidos
       WHERE cod_empresa    = p_cod_empresa
         AND num_pedido = pa_corpo_nff[1].num_pedido

      {IF p_pedidos.cod_tip_venda <> 1 THEN
         SELECT den_tip_venda
           INTO p_tipo_venda.den_tip_venda
           FROM tipo_venda
          WHERE cod_tip_venda = p_pedidos.cod_tip_venda
      END IF}

      #--- grava daods endereco de entrega
      CALL pol0858_grava_dados_end_entrega()

      #--- carrega endereco de cobranca
      CALL pol0858_carrega_end_cobranca()

      #--- trata zona franca
      IF p_fat_nf_mestre.zona_franca = 'S' THEN
         CALL pol0858_le_icms('ICMS_ZF')
         CALL pol0858_le_param_zf()
      ELSE
         CALL pol0858_le_icms('ICMS')
      END IF
     
      SELECT val_trib_merc
        INTO p_nff.val_tot_ipi
        FROM fat_mestre_fiscal
       WHERE empresa           = p_cod_empresa
         AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
         AND tributo_benef     = "IPI"         

      LET p_nff.val_tot_icm_ret    = 0 
      LET p_nff.val_tot_base_ret   = 0
      LET p_nff.val_tot_mercadoria = p_fat_nf_mestre.val_mercadoria
      LET p_nff.val_frete_cli      = p_fat_nf_mestre.val_frete_cliente
      LET p_nff.val_seguro_cli     = p_fat_nf_mestre.val_seguro_cliente
      LET p_nff.val_out_despesas   = 0

      #--- busca retorno de industrialização
      CALL pol0858_retorno_terceiro()

      #--- busca dados da transportadora
      CALL pol0858_busca_dados_transport(p_fat_nf_mestre.transportadora)
      CALL pol0858_busca_dados_cidades(p_transport.cod_cidade)

      LET p_nff.num_placa    = p_fat_nf_mestre.placa_veiculo
      LET p_nff.nom_transpor = p_transport.nom_cliente  
      
      IF p_fat_nf_mestre.tip_frete = 3 THEN 
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

      #--- relaciona qtdes e descricoes dos volumes
      CALL pol0858_junta_volumes()

      LET p_nff.den_marca       = p_clientes.den_marca
      LET p_nff.pes_tot_bruto   = p_fat_nf_mestre.peso_bruto
      LET p_nff.pes_tot_liquido = p_fat_nf_mestre.peso_liquido
      LET p_nff.num_pedido      = p_fat_nf_item.pedido
      LET p_nff.cod_repres      = p_pedidos.cod_repres
      LET p_nff.nom_guerra      = pol0858_representante()
      LET p_nff.num_suframa     = p_clientes.num_suframa
      LET p_nff.num_om          = p_fat_nf_item.ord_montag
      
      #--- carrega descricao da condicao de pagamento
      CALL pol0858_den_cnd_pgto()
      
      #--- grava dados consignados
      #CALL pol0858_grava_dados_consig()
      
      IF NOT p_ret_terc THEN
         CALL pol0858_checa_nf_contra_ordem()
      END IF

      CALL pol0858_carrega_historico_fiscal()
      
      CALL pol0858_monta_relat()

      #--- marca nf que ja foi impressa
      UPDATE fat_nf_mestre 
         SET sit_impressao = "R"
      WHERE empresa     = p_cod_empresa
        AND nota_fiscal = p_fat_nf_mestre.nota_fiscal

      LET p_imprime_nf = TRUE

   END FOREACH

   FINISH REPORT pol0858_relat

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
FUNCTION pol0858_junta_volumes()
#-------------------------------#

   DEFINE p_volumes   CHAR(05),
          p_descricao CHAR(06),          
          p_qtdvol    DECIMAL(5,0),
          p_den       CHAR(26)          
   
   INITIALIZE p_qtd_volumes, p_des_especie, p_qtdvol, p_den TO NULL
      
   DECLARE cq_embalagens CURSOR FOR
       SELECT a.qtd_volume,
              b.den_embal
       FROM fat_nf_embalagem a 
            inner join embalagem b on a.embalagem = b.cod_embal
       WHERE a.empresa = p_cod_empresa
         AND a.trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal                        
            
      FOREACH cq_embalagens INTO p_qtdvol,
                                 p_den                                 
                                 
	      IF p_qtdvol > 0 AND LENGTH(p_den) > 0 THEN
	         INSERT INTO volumes_temp 
	            VALUES(p_den,p_qtdvol)
	      END IF
	
   END FOREACH

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

#-------------------------------#
FUNCTION pol0858_cria_tabs_tmp()
#-------------------------------#

   WHENEVER ERROR CONTINUE
    
   CREATE TEMP TABLE wnotalev
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(15),
      den_item           CHAR(76),
      num_ped_cli        CHAR(30),
      cod_item_cli       CHAR(30),
      cod_cla_fisc       CHAR(10),
      cod_origem         SMALLINT,
      cod_tributacao     SMALLINT,
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
      RETURN FALSE
   END IF

   CREATE TEMP TABLE clas_fisc_temp
     (
        cod_cla_fisc       CHAR(10),
        letra              CHAR(01),
        pre_impresso       CHAR(01)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
      RETURN FALSE
   END IF

   CREATE TEMP TABLE volumes_temp
     (
      den_volume CHAR(06),
      qtd_volume DECIMAL(5,0)
     );

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA:VOLUMES_TEMP")
      RETURN FALSE
   END IF

   WHENEVER ERROR STOP
   
   RETURN TRUE
 
END FUNCTION

#---------------------------------#
FUNCTION pol0858_deleta_tabs_tmp()
#---------------------------------#

   DELETE FROM volumes_temp
   IF STATUS = 0 THEN
      DELETE FROM clas_fisc_temp
      IF STATUS = 0 THEN
         DELETE FROM wnotalev
         IF STATUS = 0 THEN
            RETURN TRUE
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION      

#----------------------------------#
FUNCTION pol0858_retorno_terceiro()
#----------------------------------#

   DEFINE p_des_texto CHAR(120),
          p_item      CHAR(15)
  

   LET p_ret_terc = FALSE
   
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

      IF NOT p_ret_terc THEN
         LET p_des_texto = 'MATERIAL DE SUA PROPRIEDADE QUE RECEBEMOS ATRAVES DE SUAS'
         CALL pol0858_insere_texto(p_des_texto,3)
         LET p_des_texto = 'NOTAS FISCAIS E QUE ESTAMOS DEVOLVENDO CONFORME SEGUE:'
         CALL pol0858_insere_texto(p_des_texto,3)
      END IF

      LET p_ret_terc = TRUE
      
      SELECT cod_item_cliente,
             tex_complementar
        INTO p_item,
             p_den_item_cli
        FROM cliente_item
       WHERE cod_empresa        = p_cod_empresa
         AND cod_cliente_matriz = p_fat_nf_mestre.cliente
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
         CALL pol0858_insere_texto(p_des_texto,3)
      END IF

   END FOREACH

   IF p_ret_terc THEN
      LET p_nff.val_tot_nff = p_nff.val_tot_mercadoria
   ELSE
      LET p_nff.val_tot_nff = p_fat_nf_mestre.val_nota_fiscal
   END IF

END FUNCTION
                                   
#----------------------------#
FUNCTION pol0858_monta_relat()
#----------------------------#

   DEFINE p_cod_cla_fisc  CHAR(10),
          p_pre_imp       CHAR(01),                                    	
          p_letras        CHAR(14)
   DEFINE p_num_nf      LIKE item_dev_terc.num_nf,
          p_dat_emis_nf LIKE item_de_terc.dat_emis_nf,
          p_qtd_nf      SMALLINT,
          p_indice      SMALLINT

   LET p_letras = 'MNOPQRSTUVWXYZ'

          
   #--- Tratamento da classificação fiscal

   LET p_indice = 0
   LET p_num_pagina = 0
   
   DECLARE cq_ind_cla CURSOR FOR
   SELECT cod_cla_fisc
     FROM wnotalev
    WHERE ies_tip_info = 1
    ORDER BY 1

   FOREACH cq_ind_cla INTO p_cod_cla_fisc
   
      INITIALIZE  p_pre_imp TO NULL

      SELECT DISTINCT
             classif_fisc,
             classif_fisc_reduz,
             pre_imp
        INTO p_cod_cla_fisc,
             p_cod_reduz,
             p_pre_imp
        FROM obf_compl_cl_fisc
       WHERE classif_fisc = p_cod_cla_fisc
      
      IF STATUS = 100        OR 
         p_cod_reduz IS NULL OR 
         p_cod_reduz = ' '   OR
         (p_pre_imp <> 'S'   AND 
          p_pre_imp <> 'N')  THEN
         
         SELECT letra
           FROM clas_fisc_temp
          WHERE cod_cla_fisc = p_cod_cla_fisc
     
         IF STATUS = 100 THEN
            LET p_indice = p_indice + 1
            IF p_indice <= 14 THEN 
               LET p_cod_reduz = p_letras[p_indice]
            ELSE
               CALL log0030_mensagem('Limite de classif fiscal da NF ultrapassado!','excla')
               RETURN
            END IF
            LET p_pre_imp = 'N'
         END IF
      ELSE
         IF STATUS <> 0 THEN
            ERROR 'Classificação fiscal: ', p_dados_nota.cod_cla_fisc
            CALL log003_err_sql('Lendo','obf_compl_cl_fisc')
            RETURN
         END IF
      END IF
      
      {IF p_pre_imp MATCHES '[SN]' THEN
      ELSE
         ERROR 'Campo obf_compl_cl_fisc.pre_imp com conteúdo inválido'
         CALL log0030_mensagem('Favor checar seu cadastro de classificação fiscal','excla')
         RETURN
      END IF

      IF p_cod_reduz IS NULL OR p_cod_reduz = ' ' THEN
         ERROR 'Campo obf_compl_cl_fisc.classif_fisc_reduz com conteúdo inválido'
         CALL log0030_mensagem('Favor checar seu cadastro de classificação fiscal','excla')
         RETURN
      END IF}
      
      SELECT letra
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_cod_cla_fisc
     
      IF STATUS = 100 THEN
         INSERT INTO clas_fisc_temp 
            VALUES(p_cod_cla_fisc,
                   p_cod_reduz,
                   p_pre_imp)
      END IF
          
   END FOREACH

   LET p_num_seq = 5
   LET p_classif = NULL
   
   DECLARE cq_classif CURSOR FOR
    SELECT cod_cla_fisc,
           letra
     FROM clas_fisc_temp
    WHERE pre_impresso = "N"
    ORDER BY letra

   FOREACH cq_classif INTO p_cod_cla_fisc, p_cod_reduz

      LET p_classif[p_num_seq].legenda = p_cod_reduz,'-',p_cod_cla_fisc
      
      LET p_num_seq = p_num_seq + 1

      IF p_num_seq > 9 THEN
         EXIT FOREACH
      END IF
    
   END FOREACH
   
   #-----Fim tratamento classificação fiscal
   
   LET p_num_seq = 1
   
   INITIALIZE p_txt  TO NULL
      
   DECLARE cq_texto CURSOR FOR
    SELECT des_texto
      FROM wnotalev
     WHERE ies_tip_info = 4

   FOREACH cq_texto INTO p_txt[p_num_seq].texto

      LET p_num_seq = p_num_seq + 1

      IF p_num_seq > 9 THEN
         EXIT FOREACH
      END IF

   END FOREACH            	       

   CALL pol0858_calcula_total_de_paginas()

   LET p_num_pagina = 0
   LET p_linha = 1

   DECLARE cq_wnotalev CURSOR FOR
   SELECT *
   FROM wnotalev
   WHERE ies_tip_info < 4
   ORDER BY 1
   
   FOREACH cq_wnotalev INTO p_wnotalev.*
      
      LET p_wnotalev.num_nff = p_fat_nf_mestre.nota_fiscal
      INITIALIZE p_cod_reduz TO NULL
      
      IF p_wnotalev.ies_tip_info = 1 THEN
         SELECT letra
           INTO p_cod_reduz
           FROM clas_fisc_temp
          WHERE cod_cla_fisc = p_wnotalev.cod_cla_fisc
       
         IF SQLCA.sqlcode <> 0 THEN
            CALL log003_err_sql('lendo','Clas_fisc_temp')
            LET p_cod_reduz = NULL
         END IF 
      END IF
        
      OUTPUT TO REPORT pol0858_relat(p_wnotalev.num_nff)
      
  END FOREACH

  { pula linhas até completar o número de linhas do corpo da página (30)}
  { somente se o numero de linhas da nota nao for multiplo de 8 }
  
  IF p_saltar_linhas THEN
     LET p_wnotalev.num_nff      = p_fat_nf_mestre.nota_fiscal
     LET p_wnotalev.ies_tip_info = 5
     OUTPUT TO REPORT pol0858_relat(p_wnotalev.num_nff)
  END IF 
  
END FUNCTION

#---------------------------------------#
FUNCTION pol0858_busca_dados_duplicatas()
#---------------------------------------#

   DEFINE p_docum_cre         LIKE fat_nf_duplicata.docum_cre,
          p_seq_duplicata     LIKE fat_nf_duplicata.seq_duplicata,
          p_dat_vencto_sdesc  LIKE fat_nf_duplicata.dat_vencto_sdesc,
          p_val_duplicata     LIKE fat_nf_duplicata.val_duplicata,
          p_contador          DECIMAL(2,0)

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT docum_cre,
          seq_duplicata,
          dat_vencto_sdesc,
          val_duplicata
     FROM fat_nf_duplicata
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
    ORDER BY empresa,
             docum_cre,
             dat_vencto_sdesc

   FOREACH cq_duplic INTO 
           p_docum_cre,
           p_seq_duplicata,
           p_dat_vencto_sdesc,
           p_val_duplicata
           
      LET p_contador  = p_contador + 1
      LET p_docum_cre = p_fat_nf_mestre.nota_fiscal #exclusivo da metall
      
      CASE p_contador
         WHEN 1  
            LET p_nff.num_dig_duplic1 = p_docum_cre
            LET p_nff.seq_duplicata1  = p_seq_duplicata
            LET p_nff.dat_vencto_sd1  = p_dat_vencto_sdesc
            LET p_nff.val_duplic1     = p_val_duplicata
         WHEN 2      
            LET p_nff.num_dig_duplic2 = p_docum_cre
            LET p_nff.seq_duplicata2  = p_seq_duplicata
            LET p_nff.dat_vencto_sd2  = p_dat_vencto_sdesc
            LET p_nff.val_duplic2     = p_val_duplicata
         WHEN 3      
            LET p_nff.num_dig_duplic3 = p_docum_cre
            LET p_nff.seq_duplicata3  = p_seq_duplicata
            LET p_nff.dat_vencto_sd3  = p_dat_vencto_sdesc
            LET p_nff.val_duplic3     = p_val_duplicata
         WHEN 4
            LET p_nff.num_dig_duplic4 = p_docum_cre
            LET p_nff.seq_duplicata4  = p_seq_duplicata
            LET p_nff.dat_vencto_sd4  = p_dat_vencto_sdesc
            LET p_nff.val_duplic4     = p_val_duplicata
         WHEN 5
            LET p_nff.num_dig_duplic5 = p_docum_cre
            LET p_nff.seq_duplicata5  = p_seq_duplicata
            LET p_nff.dat_vencto_sd5  = p_dat_vencto_sdesc
            LET p_nff.val_duplic5     = p_val_duplicata
         WHEN 6
            LET p_nff.num_dig_duplic6 = p_docum_cre
            LET p_nff.seq_duplicata6  = p_seq_duplicata
            LET p_nff.dat_vencto_sd6  = p_dat_vencto_sdesc
            LET p_nff.val_duplic6     = p_val_duplicata
         WHEN 7
            LET p_nff.num_dig_duplic7 = p_docum_cre
            LET p_nff.seq_duplicata7  = p_seq_duplicata
            LET p_nff.dat_vencto_sd7  = p_dat_vencto_sdesc
            LET p_nff.val_duplic7     = p_val_duplicata
         WHEN 8
            LET p_nff.num_dig_duplic8 = p_docum_cre            
            LET p_nff.seq_duplicata8  = p_seq_duplicata
            LET p_nff.dat_vencto_sd8  = p_dat_vencto_sdesc
            LET p_nff.val_duplic8     = p_val_duplicata
         WHEN 9
            LET p_nff.num_dig_duplic9 = p_docum_cre
            LET p_nff.seq_duplicata9  = p_seq_duplicata
            LET p_nff.dat_vencto_sd9  = p_dat_vencto_sdesc
            LET p_nff.val_duplic9     = p_val_duplicata
         WHEN 10
            LET p_nff.num_dig_duplic10 = p_docum_cre
            LET p_nff.seq_duplicata10  = p_seq_duplicata
            LET p_nff.dat_vencto_sd10  = p_dat_vencto_sdesc
            LET p_nff.val_duplic10     = p_val_duplicata
         WHEN 11
            LET p_nff.num_dig_duplic11 = p_docum_cre
            LET p_nff.seq_duplicata11  = p_seq_duplicata
            LET p_nff.dat_vencto_sd11  = p_dat_vencto_sdesc
            LET p_nff.val_duplic11     = p_val_duplicata
         WHEN 12
            LET p_nff.num_dig_duplic12 = p_docum_cre
            LET p_nff.seq_duplicata12  = p_seq_duplicata
            LET p_nff.dat_vencto_sd12  = p_dat_vencto_sdesc
            LET p_nff.val_duplic12     = p_val_duplicata
         OTHERWISE   
            EXIT FOREACH
      END CASE
   END FOREACH
END FUNCTION

#-------------------------------------#
FUNCTION pol0858_carrega_end_cobranca()
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

#-----------------------------------#
FUNCTION pol0858_carrega_corpo_nff()
#-----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          p_hist_icms          LIKE vdp_excecao_icms.hist_icms,
          p_hist_excecao       LIKE vdp_exc_ipi_cli.hist_excecao

   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          sql_stmt             CHAR(2000)

   LET p_ind   = 0						
   LET p_count = 0 
   INITIALIZE pa_corpo_nff TO NULL
   
   DECLARE cq_wfat_item_rt CURSOR FOR
    SELECT * FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
       AND (natureza_operacao = p_fat_nf_mestre.natureza_operacao
        OR pedido            > 0)

   FOREACH cq_wfat_item_rt INTO p_fat_nf_item.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item')
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      IF p_ind > 999 THEN
         EXIT FOREACH
      END IF  

      LET pa_corpo_nff[p_ind].cod_cla_fisc  = p_fat_nf_item.classif_fisc
      LET pa_corpo_nff[p_ind].cod_item      = p_fat_nf_item.item
      LET pa_corpo_nff[p_ind].num_sequencia = p_fat_nf_item.seq_item_nf
      LET pa_corpo_nff[p_ind].num_pedido    = p_fat_nf_item.pedido

      LET p_ies_lote = "N"
      INITIALIZE p_num_lote TO NULL 

      IF p_fat_nf_mestre.origem_nota_fiscal = 'O' THEN
         LET sql_stmt = "SELECT num_reserva FROM ordem_montag_grade ",
                        " WHERE cod_empresa   ='",p_cod_empresa,"' ",
                        "   AND num_om        ='",p_fat_nf_item.ord_montag,"' ",   
                        "   AND cod_item      ='",p_fat_nf_item.item,"' ",
                        "   AND num_sequencia ='",p_fat_nf_item.seq_item_pedido,"' ",
                        "   AND num_pedido    ='",p_fat_nf_item.pedido,"' "
      ELSE
         LET sql_stmt =
             "SELECT reserva_estoque FROM fat_resv_item_nf ",
             " WHERE empresa           ='",p_cod_empresa,"' ",
             "   AND seq_item_nf       ='",p_fat_nf_item.seq_item_nf,"' ",
             "   AND trans_nota_fiscal ='",p_fat_nf_item.trans_nota_fiscal,"' "
      END IF       

      PREPARE cq_cursor FROM sql_stmt   
      DECLARE cq_lote_rt CURSOR FOR cq_cursor
      FOREACH cq_lote_rt INTO p_num_reserva     

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
            LET p_num_lote = p_num_lote CLIPPED, ", ",p_num_lot 
         END IF

         LET p_ies_lote = "S"        
 
      END FOREACH

      CALL pol0858_busca_dados_pedido()
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli

      CALL pol0858_item_cliente()
      LET pa_corpo_nff[p_ind].cod_item_cli = g_cod_item_cliente

      #------
      INITIALIZE pa_corpo_nff[p_ind].den_item1, pa_corpo_nff[p_ind].den_item2 TO NULL

      #especifico Metaal#
      #IF LENGTH(pa_corpo_nff[p_ind].cod_item_cli) > 0 THEN
      #   LET pa_corpo_nff[p_ind].den_item1 = pa_corpo_nff[p_ind].cod_item_cli CLIPPED,"-",
      #       p_fat_nf_item.des_item      
      #ELSE 
         LET pa_corpo_nff[p_ind].den_item1 = p_fat_nf_item.des_item   
      #END IF
      #----------------#
      
      CALL pol0858_verifica_texto_ped_it()
      IF p_texto_item_ped IS NOT NULL THEN
         LET pa_corpo_nff[p_ind].den_item2 = p_texto_item_ped
      END IF
      
      #especifico da Metaal-#
      IF  pa_corpo_nff[p_ind].num_pedido_cli IS NULL OR
          pa_corpo_nff[p_ind].num_pedido_cli = ' '   OR
          LENGTH(pa_corpo_nff[p_ind].num_pedido_cli) = 0 THEN
         LET pa_corpo_nff[p_ind].num_pedido_cli = p_ped_itens_texto.den_texto_2[1,10]
      END IF
      #---------------------#
      
      IF p_fat_nf_item.pedido IS NULL OR
         p_fat_nf_item.pedido = 0 THEN
      ELSE
         IF pa_corpo_nff[p_ind].den_item2 IS NULL THEN 
            LET pa_corpo_nff[p_ind].den_item2 = "PV:", p_fat_nf_item.pedido USING "<<<<<&"
         ELSE
            LET pa_corpo_nff[p_ind].den_item2 = pa_corpo_nff[p_ind].den_item2 CLIPPED,
                " PV:", p_fat_nf_item.pedido USING "<<<<<&"
         END IF
      END IF

      IF p_num_lote IS NOT NULL THEN
         LET pa_corpo_nff[p_ind].den_item2 = 
             pa_corpo_nff[p_ind].den_item2 CLIPPED," LT:", p_num_lote
      END IF
      
      LET pa_corpo_nff[p_ind].pes_unit       = p_fat_nf_item.peso_unit 
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_fat_nf_item.unid_medida
      LET pa_corpo_nff[p_ind].qtd_item       = p_fat_nf_item.qtd_item
      LET pa_corpo_nff[p_ind].pre_unit       = p_fat_nf_item.preco_unit_liquido

      LET pa_corpo_nff[p_ind].val_liq_item = p_fat_nf_item.val_liquido_item
      
      SELECT UNIQUE aliquota,
                    cod_fiscal,
                    origem_produto,
                    tributacao 
        INTO pa_corpo_nff[p_ind].pct_icm,
             pa_corpo_nff[p_ind].cod_fiscal,
             pa_corpo_nff[p_ind].cod_origem,
             pa_corpo_nff[p_ind].cod_tributacao
        FROM fat_nf_item_fisc
       WHERE empresa           = p_fat_nf_item.empresa 
         AND trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
         AND seq_item_nf       = p_fat_nf_item.seq_item_nf
         AND tributo_benef     = "ICMS"
      
        SELECT UNIQUE aliquota,
                      val_trib_merc 
        INTO p_fat_nf_item_fisc.aliquota,
             p_fat_nf_item_fisc.val_trib_merc
        FROM fat_nf_item_fisc
       WHERE empresa           = p_fat_nf_item.empresa 
         AND trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
         AND seq_item_nf       = p_fat_nf_item.seq_item_nf
         AND tributo_benef     = "IPI"    

      IF p_fat_nf_item_fisc.aliquota IS NULL OR
         p_fat_nf_item_fisc.aliquota = " "    THEN 
         LET pa_corpo_nff[p_ind].pct_ipi = 0
      ELSE
         LET pa_corpo_nff[p_ind].pct_ipi = p_fat_nf_item_fisc.aliquota
      END IF
      
      IF p_fat_nf_item_fisc.val_trib_merc IS NULL OR 
         p_fat_nf_item_fisc.val_trib_merc = " "   THEN
         LET pa_corpo_nff[p_ind].val_ipi = 0
      ELSE
         LET pa_corpo_nff[p_ind].val_ipi = p_fat_nf_item_fisc.val_trib_merc
      END IF
       
   END FOREACH
   
END FUNCTION

#-----------------------------#
FUNCTION pol0858_item_cliente()
#-----------------------------#

   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
      INTO g_cod_item_cliente    
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_nff.cod_cliente
      AND cod_item           = p_fat_nf_item.item

   IF SQLCA.sqlcode <> 0 THEN
      LET g_cod_item_cliente = NULL
   END IF
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0858_verifica_ctr_unid_med()
#--------------------------------------#
   DEFINE p_ctr_unid_med   RECORD LIKE  ctr_unid_med.*

   WHENEVER ERROR CONTINUE
   SELECT ctr_unid_med.*
     INTO p_ctr_unid_med.*
     FROM ctr_unid_med
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = p_fat_nf_mestre.cliente
      AND cod_item    = p_fat_nf_item.item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      RETURN p_ctr_unid_med.fat_conver,
             p_ctr_unid_med.cod_unid_med_cli
   ELSE
      RETURN 1, p_fat_nf_item.unid_medida
   END IF
END FUNCTION

#-----------------------------------------#
FUNCTION pol0858_carrega_historico_fiscal()
#-----------------------------------------#  

   DEFINE p_fat_texto       CHAR(300),
          p_sequencia_texto SMALLINT

   DECLARE cq_whist CURSOR FOR
   SELECT des_texto, sequencia_texto
   FROM fat_nf_texto_hist
   WHERE empresa           = p_cod_empresa
     AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
     ORDER BY sequencia_texto

   FOREACH cq_whist INTO p_fat_texto, p_sequencia_texto
      
      CALL pol0858_insere_texto(p_fat_texto,4)
      
   END FOREACH

END FUNCTION

#-------------------------#
FUNCTION substr(parametro)
#-------------------------#

 DEFINE parametro  RECORD 
        texto      VARCHAR(255),
        tam_linha  SMALLINT,
        qtd_linha  SMALLINT,
        justificar CHAR(01)
 END RECORD

   LET texto      = parametro.texto CLIPPED
   LET tam_linha  = parametro.tam_linha
   LET qtd_linha  = parametro.qtd_linha
   LET justificar = parametro.justificar
   
   CALL limpa_retorno()
   
   IF checa_parametros() THEN
      CALL separa_texto()
   END IF
   
   CASE qtd_linha

      WHEN  1 RETURN r_01
      WHEN  2 RETURN r_01,r_02
      WHEN  3 RETURN r_01,r_02,r_03
      WHEN  4 RETURN r_01,r_02,r_03,r_04
      WHEN  5 RETURN r_01,r_02,r_03,r_04,r_05
      WHEN  6 RETURN r_01,r_02,r_03,r_04,r_05,r_06
      WHEN  7 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07
      WHEN  8 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08
      WHEN  9 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09
      WHEN 10 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10
      WHEN 11 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11
      WHEN 12 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12
      WHEN 13 RETURN r_01,r_02,r_03,r_04,r_05,r_06,r_07,r_08,r_09,r_10,r_11,r_12,r_13

   END CASE
   
   
END FUNCTION 


#--------------------------------#
 FUNCTION limpa_retorno()
#--------------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13 TO NULL 
              
END FUNCTION

#----------------------------------#
 FUNCTION checa_parametros()
#----------------------------------#

   IF texto IS NULL OR texto = ' ' THEN
      RETURN FALSE
   END IF
   
   IF tam_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF tam_linha < 20 OR tam_linha > 255 THEN
         RETURN FALSE
      END IF 
   END IF

   IF qtd_linha IS NULL THEN
      RETURN FALSE
   ELSE
      IF qtd_linha < 1 OR qtd_linha > 13 THEN
         RETURN FALSE
      END IF 
   END IF

   IF justificar IS NULL THEN
      RETURN FALSE
   ELSE
      IF justificar <> 'S' AND justificar <> 'N' THEN
         RETURN FALSE
      END IF 
   END IF
   
   RETURN TRUE

END FUNCTION


#--------------------------------#
 FUNCTION separa_texto()
#--------------------------------#
          
   LET r_01 = quebra_texto()
   LET r_02 = quebra_texto()
   LET r_03 = quebra_texto()
   LET r_04 = quebra_texto()
   LET r_05 = quebra_texto()
   LET r_06 = quebra_texto()
   LET r_07 = quebra_texto()
   LET r_08 = quebra_texto()
   LET r_09 = quebra_texto()
   LET r_10 = quebra_texto()
   LET r_11 = quebra_texto()
   LET r_12 = quebra_texto()
   LET r_13 = quebra_texto()
      
              
END FUNCTION

#-----------------------------#
FUNCTION quebra_texto()
#-----------------------------#

   DEFINE ind SMALLINT,
          p_des_texto CHAR(255)

   LET num_carac = LENGTH(texto)
   IF num_carac = 0 THEN
      RETURN ''
   END IF
   
   IF num_carac <= tam_linha THEN
      LET p_des_texto = texto
      INITIALIZE texto TO NULL
      RETURN(p_des_texto)
   END IF

   FOR ind = tam_linha+1 TO 1 step -1
      IF texto[ind] = ' ' then
         LET ret = texto[1,ind-1]
         LET texto = texto[ind+1,num_carac]
         EXIT FOR
      END IF
   END FOR 

   LET ret = ret CLIPPED
   IF justificar = 'S' THEN
      IF LENGTH(ret) < tam_linha THEN
         CALL justifica()
      END IF
   END IF 
              
   RETURN(ret)
   
END FUNCTION

#---------------------------#
FUNCTION justifica()
#---------------------------#

   DEFINE ind, y, p_branco, p_tam, p_tem_branco SMALLINT
   DEFINE p_tex VARCHAR(255)
   
   LET y = 1
   LET p_branco = tam_linha - LENGTH(ret)

   WHILE p_branco > 0   
      LET p_tam = LENGTH(ret)
      LET p_tem_branco = FALSE
      FOR ind = y TO p_tam
         IF ret[ind] = ' ' THEN
            LET p_tem_branco = TRUE
            LET p_tex = ret[1,ind],' ',ret[ind+1,p_tam]
            LET p_branco = p_branco - 1
            LET ret = p_tex
            LET y = ind + 2
            WHILE ret[y] = ' '
               LET y = y + 1
            END WHILE
            IF y >= LENGTH(ret) THEN
               LET y = 1
            END IF
            EXIT FOR
         END IF
      END FOR
      IF NOT p_tem_branco THEN
         LET y = 1
      END IF
   END WHILE 
      
END FUNCTION

#------------------------------------#
FUNCTION pol0858_le_icms(p_cod_nenef)
#------------------------------------#

   DEFINE p_cod_nenef CHAR(10)

   SELECT bc_trib_mercadoria,
          val_trib_merc
     INTO p_nff.val_tot_base_icm,
          p_nff.val_tot_icm
     FROM fat_mestre_fiscal
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
      AND tributo_benef     = p_cod_nenef
         
   IF p_nff.val_tot_icm = 0 THEN
      LET p_nff.val_tot_base_icm = 0
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0858_le_param_zf()
#-----------------------------#  

   DEFINE p_valor_pis     DEC(15,2), 
          p_valor_cofins  DEC(15,2), 
          p_val_base      DEC(15,2), 
          p_pct_pis       DEC(5,2),
          p_pct_cofins    DEC(5,2)
  
   LET p_valor_pis = 0
   LET p_valor_cofins = 0
   
   SELECT bc_trib_mercadoria,
          val_trib_merc
     INTO p_val_base,
          p_valor_pis
     FROM fat_mestre_fiscal
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
      AND tributo_benef     = 'PIS_REC_ZF'

   IF STATUS <> 0 THEN
      LET p_valor_pis = 0
   END IF

   SELECT bc_trib_mercadoria,
          val_trib_merc
     INTO p_val_base,
          p_valor_cofins
     FROM fat_mestre_fiscal
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
      AND tributo_benef     = 'COFINS_REC_ZF'

   IF STATUS <> 0 THEN
      LET p_valor_cofins = 0
   END IF
            
   LET p_des_texto = NULL
      
   IF p_valor_pis > 0 THEN
      LET p_pct_pis = pol0858_le_pct('PIS_REC')
      LET p_des_texto = "PIS: ", p_pct_pis, " % = R$ ", p_valor_pis USING "##,###,##&.&&"
   END IF

   IF p_valor_cofins > 0 THEN
      LET p_pct_cofins = pol0858_le_pct('COFINS_REC')
      IF p_des_texto IS NULL THEN
         LET p_des_texto = "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "##,###,##&.&&"
      ELSE
         LET p_des_texto = p_des_texto CLIPPED, ' - ', 
                           "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "##,###,##&.&&"
      END IF
   END IF
      
   IF p_des_texto IS NOT NULL THEN
      CALL pol0858_insere_texto(p_des_texto,3)
   END IF

   LET p_pct_icms = pol0858_le_pct('ICMS')
      
   IF p_clientes.num_suframa > 0 AND p_fat_nf_mestre.val_desc_merc > 0 THEN
  
      LET p_des_texto = "R$ ",p_fat_nf_mestre.val_desc_merc USING "##,###,##&.&&",
                        " - ", p_pct_icms USING "#&.&", 
                        " % ICMS COMO SE DEVIDO FOSSE"
                        
      CALL pol0858_insere_texto(p_des_texto,3)

      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&"
      CALL pol0858_insere_texto(p_des_texto,3)

      LET p_nff.val_tot_base_icm = 0
      LET p_nff.val_tot_icm      = 0
      
   END IF   
   
END FUNCTION

#---------------------------------#
FUNCTION pol0858_le_pct(p_tributo)
#---------------------------------#
   
   DEFINE p_tributo  CHAR(15),
          p_aliquota DECIMAL(5,2)
   
   SELECT aliquota
     INTO p_aliquota
     FROM obf_config_fiscal 
    WHERE empresa           = p_cod_empresa
      AND nat_oper_grp_desp = p_fat_nf_mestre.natureza_operacao
      AND tributo_benef     = p_tributo
      AND tip_acresc_desc   = 'ZF'

   IF STATUS <> 0 THEN
      LET p_aliquota = 0
   END IF
   
   RETURN(p_aliquota)

END FUNCTION

#-----------------------------------#
FUNCTION pol0858_grava_corpo_nota()
#-----------------------------------#

   LET p_num_seq = 0               

   FOR i = 1 TO 999

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      CALL pol0858_insere_item(pa_corpo_nff[i].den_item1, 1)
      CALL pol0858_insere_item(pa_corpo_nff[i].den_item2, 2)
         
   END FOR

END FUNCTION

#--------------------------------------------------#
FUNCTION pol0858_insere_item(p_den_item,p_tip_info)
#--------------------------------------------------#

   DEFINE p_den_item CHAR(76),
          p_tip_info SMALLINT
   
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotalev 
     VALUES ( p_num_seq,  
              p_tip_info,
              pa_corpo_nff[i].cod_item,
              p_den_item, 
              pa_corpo_nff[i].num_pedido_cli,
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

END FUNCTION

#---------------------------------------------------#
FUNCTION pol0858_insere_texto(p_den_texto,p_tip_info)
#---------------------------------------------------#

   DEFINE p_den_texto CHAR(255),
          p_tip_info  SMALLINT,
          p_ind       SMALLINT
   
   DEFINE p_txt_hist  ARRAY[6] OF RECORD 
          texto       CHAR(80)
   END RECORD

   IF LENGTH(p_den_texto) = 0 THEN
      RETURN
   END IF
   
   INITIALIZE p_txt_hist TO NULL
   
   IF p_tip_info = 3 THEN
      CALL substr(p_den_texto,80,2,'N') 
           RETURNING p_txt_hist[1].texto, p_txt_hist[2].texto
   ELSE
      CALL substr(p_den_texto,55,6,'N') 
           RETURNING p_txt_hist[1].texto, p_txt_hist[2].texto, 
                     p_txt_hist[3].texto, p_txt_hist[4].texto,
                     p_txt_hist[5].texto, p_txt_hist[6].texto
   END IF
   
   FOR p_ind = 1 TO 6

       IF p_txt_hist[p_ind].texto IS NULL OR
          p_txt_hist[p_ind].texto = ' '   OR
          LENGTH(p_txt_hist[p_ind].texto) = 0 THEN
       ELSE
          LET p_num_seq  = p_num_seq + 1

          INSERT INTO wnotalev
          VALUES (p_num_seq,
                  p_tip_info,
                  NULL,NULL,
                  NULL,NULL,
                  NULL,NULL,
                  NULL,NULL,
                  NULL,NULL,
                  NULL,NULL,
                  NULL,NULL,NULL,
                  p_txt_hist[p_ind].texto,
                  NULL)
       END IF
   END FOR              

END FUNCTION   

#---------------------------------#
FUNCTION pol0858_obtem_peso_item()
#---------------------------------#

   DEFINE i          SMALLINT,
          p_pes_unit LIKE item.pes_unit,    
          p_pes_tot  LIKE item.pes_unit

   FOR i = 1 TO 999

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      LET p_pes_tot = pa_corpo_nff[i].pes_unit *  pa_corpo_nff[i].qtd_item
         
      IF p_fat_nf_mestre.origem_nota_fiscal MATCHES '[PO]' THEN
         DECLARE cq_num_ct CURSOR FOR
         SELECT den_motivo_remessa
           FROM item_em_terc a,
                motivo_remessa b
          WHERE a.cod_empresa        = b.cod_empresa 
            AND a.cod_motivo_remessa = b.cod_motivo_remessa
            AND a.cod_empresa        = p_cod_empresa            
            AND a.num_sequencia      = pa_corpo_nff[i].num_sequencia
            AND a.num_nf             = p_fat_nf_mestre.nota_fiscal
 
         FOREACH cq_num_ct INTO p_den_motivo_remessa

           LET p_des_texto = "PEDIDO: ", p_den_motivo_remessa,
                             " Peso:  ", p_pes_tot
         	
           CALL pol0858_insere_texto(p_des_texto, 3)

         END FOREACH
      ELSE
         LET p_des_texto = "Peso do item: ", p_pes_tot
         CALL pol0858_insere_texto(p_des_texto, 3)
      END IF
         
   END FOR
           
END FUNCTION

#-----------------------------------------#
FUNCTION pol0858_calcula_total_de_paginas()
#-----------------------------------------#

   DEFINE p_resto SMALLINT

   LET p_saltar_linhas = TRUE

   SELECT COUNT(*)
     INTO p_num_linhas
     FROM wnotalev
    WHERE ies_tip_info < 4 

   IF p_num_linhas > 34 THEN 
      
      LET p_resto = p_num_linhas MOD 34 
      
      LET p_tot_paginas = p_num_linhas / 34
  
      IF p_resto > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_saltar_linhas = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0858_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM clientes, cidades, subst_trib_uf
    WHERE clientes.cod_cliente        = p_fat_nf_mestre.cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder

END FUNCTION

#-----------------------------#
FUNCTION pol0858_den_nat_oper()
#-----------------------------#

   SELECT *
     INTO p_nat_operacao.*
     FROM nat_operacao
    WHERE cod_nat_oper = p_fat_nf_mestre.natureza_operacao
 
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
FUNCTION pol0858_busca_cof_compl()
#----------------------------------#

   INITIALIZE p_cod_fiscal_compl TO NULL

   WHENEVER ERROR CONTINUE
   SELECT cod_fiscal_compl
     INTO p_cod_fiscal_compl
     FROM fiscal_par_compl
    WHERE cod_empresa   = p_cod_empresa
      AND cod_nat_oper  = p_fat_nf_mestre.natureza_operacao
      AND cod_uni_feder = p_cidades.cod_uni_feder

   IF SQLCA.sqlcode <> 0 THEN
      INITIALIZE p_cod_fiscal_compl TO NULL
   END IF
   WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------#
FUNCTION pol0858_busca_dados_empresa()            
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
FUNCTION pol0858_representante()
#-------------------------------#
   DEFINE p_nom_guerra LIKE representante.nom_guerra

   SELECT nom_guerra
     INTO p_nom_guerra
     FROM representante
    WHERE cod_repres = p_pedidos.cod_repres

   RETURN p_nom_guerra
   
END FUNCTION

#-----------------------------#
FUNCTION pol0858_den_cnd_pgto()
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
    WHERE cod_cnd_pgto = p_fat_nf_mestre.cond_pagto
   WHENEVER ERROR STOP

   LET p_nff.den_cnd_pgto = p_den_cnd_pgto
 
   IF p_pct_desp_finan IS NOT NULL
      AND p_pct_desp_finan > 1 THEN
      LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
      LET p_des_texto = "ENCARGO FINANCEIRO: ",  p_pct_enc_finan USING "#&.&&&"," %"
      CALL pol0858_insere_texto(p_des_texto,3)
   END IF 

END FUNCTION 

#--------------------------------------------------#
FUNCTION pol0858_busca_dados_clientes()
#--------------------------------------------------#

   INITIALIZE p_clientes.* TO NULL
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_fat_nf_mestre.cliente

END FUNCTION

#--------------------------------#
FUNCTION pol0858_busca_nome_pais()                   
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
FUNCTION pol0858_busca_dados_transport(p_cod_transpor)
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
FUNCTION pol0858_busca_dados_cidades(p_cod_cidade)
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
FUNCTION pol0858_busca_dados_pedido()
#-----------------------------------#  

   INITIALIZE p_nff.num_pedido_repres,                       
              p_nff.num_pedido_cli   TO  NULL                    

   SELECT num_pedido_repres, 
          num_pedido_cli
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli
     FROM pedidos
    WHERE pedidos.cod_empresa = p_fat_nf_mestre.empresa 
      AND pedidos.num_pedido  = p_fat_nf_item.pedido

END FUNCTION

#-----------------------------------------------#
FUNCTION pol0858_grava_dados_consig()
#-----------------------------------------------#

   SELECT clientes.nom_cliente,
          clientes.end_cliente,
          clientes.den_bairro,
          cidades.den_cidade,
          cidades.cod_uni_feder
     FROM clientes,
          cidades, fat_consig_nf
    WHERE clientes.cod_cliente = fat_consig_nf.consignatario
      AND clientes.cod_cidade  = cidades.cod_cidade
      AND (fat_consig_nf.empresa = p_cod_empresa
      AND  fat_consig_nf.trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
      AND  fat_consig_nf.seq_consignatario = 1)      

END FUNCTION

#----------------------------------------#
FUNCTION pol0858_grava_dados_end_entrega()
#----------------------------------------#
                                            
   SELECT endereco_entrega,
          cnpj_entrega,
          inscr_est_entrega,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_end_entrega.*
     FROM fat_nf_end_entrega,
          cidades
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal           
      AND cidade_entrega    = cidades.cod_cidade      

   {IF p_end_entrega.end_entrega IS NOT NULL THEN
      LET p_des_texto = "ENDERECO DE ENTREGA: ", p_end_entrega.end_entrega 
                        CLIPPED," ", p_end_entrega.num_cgc," ", 
                        p_end_entrega.ins_estadual,
                        " ",p_end_entrega.den_cidade CLIPPED, " ", 
                        p_end_entrega.cod_uni_feder
      CALL pol0858_insere_texto(p_des_texto,3)
   END IF }

END FUNCTION
  
#----------------------------------------#
FUNCTION pol0858_checa_nf_contra_ordem()
#----------------------------------------#

   DEFINE p_nf_refer          INTEGER,
          p_trans_nota_fiscal integer,
          p_nota_fiscal       integer,
          p_dat_hor_emissao   DATETIME YEAR TO SECOND

   SELECT DISTINCT nota_fiscal_refer
     INTO p_nf_refer
     FROM fat_nf_refer_item
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal

   IF STATUS = 0 THEN
      LET p_des_texto = "N.F. DE VENDA Nro ", p_nf_refer USING "&&&&&&", 
                        " DE ", p_fat_nf_mestre.dat_hor_emissao
      CALL pol0858_insere_texto(p_des_texto,4)
   ELSE 
      IF STATUS = 100 then
        
         SELECT DISTINCT trans_nota_fiscal
           INTO p_trans_nota_fiscal
           FROM fat_nf_refer_item
          WHERE empresa           = p_cod_empresa
            AND nota_fiscal_refer = p_fat_nf_mestre.nota_fiscal
         
         IF STATUS = 0 then
            SELECT nota_fiscal,
                   dat_hor_emissao
              INTO p_nota_fiscal,
                   p_dat_hor_emissao
              FROM fat_nf_mestre
             WHERE empresa           = p_cod_empresa
               AND trans_nota_fiscal = p_trans_nota_fiscal
            
            IF STATUS = 0 THEN
               LET p_des_texto = "N.F. DE REMESSA Nro ", p_nota_fiscal USING "&&&&&&", " DE ", p_dat_hor_emissao
               CALL pol0858_insere_texto(p_des_texto,4)
            END IF 
            
         END IF 
      END IF
   END IF
      
END FUNCTION

#---------------------------------------#
FUNCTION pol0858_verifica_texto_ped_it()
#---------------------------------------#

   INITIALIZE p_texto_item_ped TO NULL
   
   SELECT des_esp_item
     INTO p_texto_item_ped
     FROM item_esp        
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_fat_nf_item.item
      AND num_seq     = 1
   
   IF p_texto_item_ped IS NOT NULL AND LENGTH(p_texto_item_ped) > 0 THEN
      RETURN
   END IF   

   #Metaal só considera os 2 primeiros textos
   
   SELECT *
     INTO p_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_fat_nf_item.pedido
      AND num_sequencia = p_fat_nf_item.seq_item_pedido
  
   IF SQLCA.sqlcode = 0 THEN 
      IF p_ped_itens_texto.den_texto_1 IS NOT NULL THEN
         LET p_texto_item_ped = 'OC ',p_ped_itens_texto.den_texto_1 #Metaal
      ELSE
         {IF p_ped_itens_texto.den_texto_2 IS NOT NULL THEN
            LET p_texto_item_ped = p_ped_itens_texto.den_texto_2
         ELSE
            IF p_ped_itens_texto.den_texto_3 IS NOT NULL THEN
               LET p_texto_item_ped = p_ped_itens_texto.den_texto_3
            ELSE
               IF p_ped_itens_texto.den_texto_4 IS NOT NULL THEN
                  LET p_texto_item_ped = p_ped_itens_texto.den_texto_4
               ELSE
                  IF p_ped_itens_texto.den_texto_5 IS NOT NULL THEN
                     LET p_texto_item_ped = p_ped_itens_texto.den_texto_5
                  END IF
               END IF
            END IF
         END IF}
      END IF
   END IF
   
END FUNCTION


#-----------------------------#
REPORT pol0858_relat(p_num_nff)
#-----------------------------#

   DEFINE i            SMALLINT,
          l_nulo       CHAR(10),
          p_nf_ant     DECIMAL(7,0),
          p_cont_nf_rt SMALLINT,
          p_num_nff    LIKE fat_nf_mestre.nota_fiscal

   DEFINE p_for        SMALLINT,
          p_sal        SMALLINT,
          p_des_folha  CHAR(100),
          p_pula_linha SMALLINT

   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   104
          
          
   ORDER EXTERNAL BY p_num_nff
  
   FORMAT

      PAGE HEADER

      LET p_num_pagina = p_num_pagina + 1
      LET p_pula_linha = TRUE
      
      PRINT p_8lpp, p_comprime
      
      SKIP 2 LINES
      PRINT COLUMN 110, "X"
      PRINT COLUMN 148, p_nff.num_nff USING "&&&&&&"
      SKIP 5 LINES

      PRINT COLUMN 002, p_den_nat_oper,
            COLUMN 055, p_cods_fiscal,
            COLUMN 100, p_nff.ins_estadual_trib    

      SKIP 2 LINES
      PRINT COLUMN 002, p_nff.nom_destinatario, 
            COLUMN 115, p_nff.num_cgc_cpf,
            COLUMN 145, p_nff.dat_emissao USING "DD/MM/YYYY"
      SKIP 1 LINES
      PRINT COLUMN 002, p_nff.end_destinatario,
            #COLUMN 075, p_nff.den_bairro,
            COLUMN 125, p_nff.cod_cep
            #COLUMN 145, TODAY USING "DD/MM/YYYY"
      SKIP 1 LINES 
      PRINT COLUMN 002, p_nff.den_cidade[1,22],
            COLUMN 077, p_nff.num_telefone[1,13],
            COLUMN 103, p_nff.cod_uni_feder,
            COLUMN 118, p_nff.ins_estadual
            #COLUMN 145, TIME
      SKIP 3 LINES

      PRINT COLUMN 005, p_nff.num_dig_duplic1[1,10],
            COLUMN 016, p_nff.seq_duplicata1 USING '&&',
            COLUMN 021, p_nff.dat_vencto_sd1 USING "DD/MM/YYYY",
            COLUMN 031, p_nff.val_duplic1    USING "###,###,###,##&.&&",
            COLUMN 052, p_nff.num_dig_duplic2[1,10],
            COLUMN 063, p_nff.seq_duplicata2 USING '&&',
            COLUMN 068, p_nff.dat_vencto_sd2 USING "DD/MM/YYYY",
            COLUMN 078, p_nff.val_duplic2    USING "###,###,###,##&.&&",
            COLUMN 099, p_nff.num_dig_duplic3[1,10],
            COLUMN 110, p_nff.seq_duplicata3 USING '&&',
            COLUMN 115, p_nff.dat_vencto_sd3 USING "DD/MM/YYYY",
            COLUMN 125, p_nff.val_duplic3    USING "###,###,###,##&.&&"

      PRINT COLUMN 005, p_nff.num_dig_duplic4[1,10],
            COLUMN 016, p_nff.seq_duplicata4 USING '&&',
            COLUMN 021, p_nff.dat_vencto_sd4 USING "DD/MM/YYYY",
            COLUMN 031, p_nff.val_duplic4    USING "###,###,###,##&.&&",
            COLUMN 052, p_nff.num_dig_duplic5[1,10],
            COLUMN 063, p_nff.seq_duplicata5 USING '&&',
            COLUMN 068, p_nff.dat_vencto_sd5 USING "DD/MM/YYYY",
            COLUMN 078, p_nff.val_duplic5    USING "###,###,###,##&.&&",
            COLUMN 099, p_nff.num_dig_duplic6[1,10],
            COLUMN 110, p_nff.seq_duplicata6 USING '&&',
            COLUMN 115, p_nff.dat_vencto_sd6 USING "DD/MM/YYYY",
            COLUMN 125, p_nff.val_duplic6    USING "###,###,###,##&.&&"
                  
      SKIP 2 LINES
      PRINT COLUMN 002, p_nff.end_cob_cli CLIPPED," - ",
                        p_nff.den_cidade_cob CLIPPED, " - ",
                        p_nff.cod_uni_feder_cobr CLIPPED,
            COLUMN 091, p_end_entrega.end_entrega CLIPPED," - ",
                        p_end_entrega.den_cidade CLIPPED, " - ", 
                        p_end_entrega.cod_uni_feder
      SKIP 1 LINES
      PRINT COLUMN 002, p_nff.val_extenso1
      PRINT COLUMN 002, p_nff.val_extenso2
      SKIP 3 LINES

   BEFORE GROUP OF p_num_nff
      SKIP TO TOP OF PAGE
   ON EVERY ROW

      INITIALIZE p_den_item, p_cod_item_cliente TO NULL
      CASE
         WHEN p_wnotalev.ies_tip_info = 1   
            PRINT COLUMN 001, p_wnotalev.cod_item,
                  COLUMN 019, p_wnotalev.den_item[1,73],
                  COLUMN 095, p_wnotalev.num_ped_cli[1,10],
                  COLUMN 105, p_cod_reduz,
                  COLUMN 107, p_wnotalev.cod_origem USING "&",
                  COLUMN 108, p_wnotalev.cod_tributacao USING "&&",
                  COLUMN 112, p_wnotalev.cod_unid_med,
                  COLUMN 115, p_wnotalev.qtd_item USING "#####&",
                  COLUMN 122, p_wnotalev.pre_unit USING "###,##&.&&";
            IF p_nff.cod_uni_feder = "AM" AND 
               (p_clientes.ies_zona_franca = "S" OR  p_clientes.ies_zona_franca = "A") THEN
                PRINT COLUMN 132, p_wnotalev.val_liq_item USING "####,##&.&&",
                      COLUMN 145, p_pct_icms USING "#&"
            ELSE  
                PRINT COLUMN 132, p_wnotalev.val_liq_item USING "####,##&.&&",
                      COLUMN 145, p_wnotalev.pct_icm USING "#&",
                      COLUMN 150, p_wnotalev.pct_ipi USING "#&",
                      COLUMN 154, p_wnotalev.val_ipi USING "#,##&.&&"
            END IF
            LET p_linhas_print = p_linhas_print + 1
        
         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 019, p_wnotalev.den_item[1,52]
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 3
            IF p_pula_linha THEN
               PRINT
               LET p_linhas_print = p_linhas_print + 1
               LET p_pula_linha = FALSE
            END IF
            
            PRINT COLUMN 019, p_wnotalev.des_texto 
            LET p_linhas_print = p_linhas_print + 1
              
         WHEN p_wnotalev.ies_tip_info = 5
            WHILE TRUE
               IF p_linhas_print < 34 THEN 
                  PRINT 
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF          
            END WHILE
      END CASE
#---------------------------------------------------------------------------
      IF p_linhas_print = 34 THEN { nr. de linhas do corpo da nota }
         IF p_num_pagina = p_tot_paginas THEN 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&" 
         ELSE 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&"," - Continua" 
         END IF
         IF p_num_pagina = p_tot_paginas THEN 
            PRINT COLUMN 040, p_des_folha 
            SKIP 2 LINES  
            PRINT COLUMN 013, p_nff.val_tot_base_icm    USING "###,###,##&.&&",
                  COLUMN 045, p_nff.val_tot_icm         USING "###,###,##&.&&",
                  COLUMN 075, p_nff.val_tot_base_ret    USING "###,###,##&.&&",
                  COLUMN 110, p_nff.val_tot_icm_ret     USING "###,###,##&.&&",
                  COLUMN 145, p_nff.val_tot_mercadoria  USING "###,###,##&.&&"
            SKIP 1 LINES  
            PRINT COLUMN 013, p_nff.val_frete_cli       USING "###,###,##&.&&", 
                  COLUMN 045, p_nff.val_seguro_cli      USING "###,###,##&.&&",
                  COLUMN 075, p_nff.val_out_despesas    USING "###,###,##&.&&",
                  COLUMN 110, p_nff.val_tot_ipi         USING "###,###,##&.&&",
                  COLUMN 145, p_nff.val_tot_nff         USING "###,###,##&.&&"
            SKIP 2 LINES
            PRINT COLUMN 002, p_nff.nom_transpor,                  
                  COLUMN 093, p_nff.ies_frete USING "&",
                  COLUMN 110, p_nff.num_placa,
                  COLUMN 122, p_nff.cod_uni_feder_trans,
                  COLUMN 142, p_nff.num_cgc_trans
            SKIP 1 LINES
            PRINT COLUMN 002, p_nff.end_transpor[1,32],
                  COLUMN 078, p_nff.den_cidade_trans[1,22],   
                  COLUMN 122, p_nff.cod_uni_feder_trans,
                  COLUMN 142, p_nff.ins_estadual_trans   
            SKIP 2 LINES
            PRINT COLUMN 002, p_qtd_volumes,
                  COLUMN 017, p_des_especie,
                  COLUMN 049, p_nff.den_marca,
                  COLUMN 092, p_nff.num_nff          USING "&&&&&&",
                  COLUMN 115, p_nff.pes_tot_bruto    USING "###,##&.&&&",
                  COLUMN 140, p_nff.pes_tot_liquido  USING "###,##&.&&&"
            SKIP 2 LINES
            PRINT COLUMN 042, p_txt[1].texto
            PRINT COLUMN 042, p_txt[2].texto
            PRINT COLUMN 042, p_txt[3].texto
            PRINT COLUMN 042, p_txt[4].texto
            FOR p_num_seq = 5 TO 9
                PRINT COLUMN 016, p_classif[p_num_seq].legenda,
                      COLUMN 042, p_txt[p_num_seq].texto
            END FOR
            SKIP 6 LINES
            PRINT COLUMN 010, p_nff.num_nff USING "&&&&&&" 
            LET p_num_pagina = 0
         ELSE 
            PRINT COLUMN 040, p_des_folha 
            SKIP 2 LINES
            PRINT COLUMN 013, "**************",
                  COLUMN 045, "**************",
                  COLUMN 075, "**************",
                  COLUMN 110, "**************",
                  COLUMN 145, "**************"
            SKIP 1 LINES 
            PRINT COLUMN 013, "**************", 
                  COLUMN 045, "**************",
                  COLUMN 075, "**************",
                  COLUMN 110, "**************",
                  COLUMN 145, "**************"
            SKIP 26 LINES
            PRINT COLUMN 010, p_nff.num_nff USING "&&&&&&"
            SKIP TO TOP OF PAGE
         END IF
         LET p_linhas_print = 0
      END IF

END REPORT
#------------------------------- FIM DE PROGRAMA ------------------------------#