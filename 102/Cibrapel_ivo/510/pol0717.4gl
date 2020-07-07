#---------------------------------------------------------------------------#  
# PROGRAMA: POL0717                                                         #
# OBJETIVO: OCOMPANHAMENTO DE CARGA                                         # 
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_den_empresa            LIKE empresa.den_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_num_list_preco         LIKE pedidos.num_list_preco,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_caminho                CHAR(80),
          p_ies_impressao          CHAR(01),
          p_num_nff_ini            LIKE nf_mestre.num_nff,       
          p_num_nff_fim            LIKE nf_mestre.num_nff,
          p_ies_impr_nff           LIKE wfat_mestre.ies_impr_nff,       
          comando                  CHAR(80),
          p_negrito                CHAR(02),
          p_normal                 CHAR(02),
          p_cod_fiscal_ind         LIKE nf_item_fiscal.cod_fiscal,
          p_num_nf_retorno         LIKE item_dev_terc.num_nf_retorno,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_ies_especie_nf         LIKE nf_sup.ies_especie_nf,
          p_cod_fornecedor         LIKE nf_sup.cod_fornecedor,
          p_dat_emis_nf            LIKE nf_sup.dat_emis_nf,       
          p_den_item_reduz         LIKE item.den_item_reduz, 
          p_qtd_item               LIKE nf_item.qtd_item,
          p_fat_conver             LIKE ctr_unid_med.fat_conver,
          p_pre_unit_nf            LIKE nf_item.pre_unit_nf,
          p_pre_tot_nf             LIKE nf_mestre.val_tot_nff,
          p_val_tot_it             LIKE wfat_item.val_liq_item,
          p_val_jur_dia            LIKE wfat_item.val_liq_item,
          p_per_jur_dia            LIKE par_desc_oper.per_jur_dia,
          p_cod_emp_ofic           LIKE par_desc_oper.cod_emp_ofic,
          p_juros                  DECIMAL(5,3),      
#          p_num_recibo             LIKE ref_nota_885.num_recibo,                  
          p_num_recibo             DECIMAL(6,0),                  
          p_unid_med               LIKE item.cod_unid_med,
          p_msg                    CHAR(100) 

   DEFINE p_fat_numero_885         RECORD LIKE fat_numero_885.*,
          p_ref_nota_885           RECORD LIKE ref_nota_885.*   

   DEFINE p_num_seq                SMALLINT,
          p_qtd_lin_obs            SMALLINT

   DEFINE p_wfat_mestre          RECORD LIKE wfat_mestre.*,
          p_wfat_item            RECORD LIKE wfat_item.*,
          p_wfat_historico       RECORD LIKE wfat_historico.*,
          p_cidades1             RECORD LIKE cidades.*,
          p_empresa              RECORD LIKE empresa.*,
          p_embalagem            RECORD LIKE embalagem.*,
          p_empresas_885         RECORD LIKE empresas_885.*,
          p_clientes             RECORD LIKE clientes.*,
          p_paises               RECORD LIKE paises.*,
          p_uni_feder            RECORD LIKE uni_feder.*,
          p_transport            RECORD LIKE clientes.*,
          p_ped_itens_texto      RECORD LIKE ped_itens_texto.*,
          p_fator_cv_unid        RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf        RECORD LIKE subst_trib_uf.*,
          p_nat_operacao         RECORD LIKE nat_operacao.*,
          p_cli_end_cobr         RECORD LIKE cli_end_cob.*

   DEFINE p_nff       
          RECORD
             num_nff             LIKE wfat_mestre.num_nff,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             cod_fiscal          LIKE wfat_mestre.cod_fiscal,
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
             cod_uni_feder       LIKE cidades.cod_uni_feder,
             ins_estadual        LIKE clientes.ins_estadual,
             hora_saida          DATETIME HOUR TO MINUTE,
             cod_cliente         LIKE clientes.cod_cliente,
             den_pais            LIKE paises.den_pais,    
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
             val_desc_cred_icm   LIKE wfat_mestre.val_desc_cred_icm,
             nom_transpor        LIKE clientes.nom_cliente,
             ies_frete           LIKE wfat_mestre.ies_frete,
             num_placa           LIKE wfat_mestre.num_placa,
             cod_uni_feder_trans LIKE cidades.cod_uni_feder,
             num_cgc_trans       LIKE clientes.num_cgc_cpf,
             end_transpor        LIKE clientes.end_cliente,
             den_cidade_trans    LIKE cidades.den_cidade,
             ins_estadual_trans  LIKE clientes.ins_estadual,
             num_telefone_trans  LIKE clientes.num_telefone,
             qtd_volume          LIKE wfat_mestre.qtd_volumes1,
             qtd_volume1         LIKE wfat_mestre.qtd_volumes1,
             qtd_volume2         LIKE wfat_mestre.qtd_volumes2,
             des_especie1        CHAR(030),
             des_especie2        CHAR(030),
             des_especie3        CHAR(030),
             den_marca           LIKE clientes.den_marca,
             num_pri_volume      LIKE wfat_mestre.num_pri_volume,
             num_ult_volume      LIKE wfat_mestre.num_pri_volume,
             pes_tot_bruto       LIKE wfat_mestre.pes_tot_bruto,
             pes_tot_liquido     LIKE wfat_mestre.pes_tot_liquido,
             cod_repres          LIKE wfat_mestre.cod_repres,
             raz_social          LIKE representante.raz_social,
             den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
             num_pedido          LIKE wfat_item.num_pedido,
             num_suframa         LIKE clientes.num_suframa,
             num_om              LIKE wfat_item.num_om,
             num_pedido_repres   LIKE pedidos.num_pedido_repres,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             nat_oper            LIKE nat_operacao.cod_nat_oper,
             num_nf_orig         LIKE wfat_mestre.num_nff
          END RECORD

   DEFINE p_duplic RECORD
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
      den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
      val_desc_cred_icm   LIKE wfat_mestre.val_desc_cred_icm,
      num_nf_orig         LIKE wfat_mestre.num_nff
   END RECORD
 
   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE wfat_item.cod_item,
             cod_item_cliente    LIKE cliente_item.cod_item_cliente,
             num_pedido          LIKE wfat_item.num_pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(060),
             den_item2           CHAR(026),
             cod_cla_fisc        CHAR(001),              
             cod_origem          LIKE wfat_mestre.cod_origem,
             cod_tributacao      LIKE wfat_mestre.cod_tributacao,
             cod_unid_med        LIKE wfat_item.cod_unid_med,
             qtd_item            LIKE wfat_item.qtd_item,
             pre_bruto           LIKE wfat_item.pre_unit_ped,
             val_desc            LIKE wfat_item.val_desc_adicional,
             pct_desc            LIKE wfat_item.pct_desc_adic,
             pre_unit            LIKE wfat_item.pre_unit_nf,
             val_liq_item        LIKE wfat_item.val_liq_item,
             pct_icm             LIKE wfat_mestre.pct_icm,
             pct_ipi             LIKE wfat_item.pct_ipi,
             val_ipi             LIKE wfat_item.val_ipi,
             val_icm_ret         LIKE wfat_item.val_icm_ret
          END RECORD

   DEFINE p_wnotacop       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          CHAR(15),                  
             den_item          CHAR(060),
             qtd_it_conv       DEC(5,0),
             cod_cla_fisc      CHAR(001),               
             cod_origem        DECIMAL(1,0),
             cod_tributacao    DECIMAL(2,0),                    
             cod_unid_med      CHAR(3),                    
             qtd_item          DECIMAL(12,3),            
             pre_bruto         DECIMAL(17,6),
             val_desc          DECIMAL(15,2),   
             pct_desc          DECIMAL(5,2),  
             pre_unit          DECIMAL(17,6),              
             val_liq_item      DECIMAL(15,2),                
             pct_icm           DECIMAL(5,2),             
             pct_ipi           DECIMAL(6,3),            
             val_ipi           DECIMAL(15,2),           
             des_texto         CHAR(120),
             num_nff           DECIMAL(6,0)
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
             num_telefone        LIKE clientes.num_telefone,
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
 
   DEFINE pa_texto_obs               ARRAY[05] 
          OF RECORD
             den_texto               CHAR(32)
          END RECORD

   DEFINE p_num_linhas               SMALLINT,
          p_num_pagina               SMALLINT,
          p_tot_paginas              SMALLINT
 
   DEFINE p_ies_lista                SMALLINT,
          p_ies_termina_relat        SMALLINT,
          p_linhas_print             SMALLINT
 
   DEFINE p_des_texto                CHAR(120),
          p_val_tot_ipi_acum         DECIMAL(15,3)

   DEFINE p_versao                   CHAR(18)
 
   DEFINE g_ies_ambiente             CHAR(001)
END GLOBALS

   DEFINE g_cod_item_cliente  LIKE cliente_item.cod_item_cliente

   DEFINE g_cla_fisc   ARRAY[10]
          OF RECORD
             num_seq         CHAR(2), 
             cod_cla_fisc    CHAR(10) 
          END RECORD

MAIN
   LET p_versao = "POL0717-10.02.00" 
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("vdp.iem") RETURNING comando
   OPTIONS
      HELP    FILE comando

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0717_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0717_controle()
#-------------------------#
   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("pol0717") RETURNING comando    
   OPEN WINDOW w_pol0717 AT 2,3 WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         CALL pol0717_inicializa_campos()
         SELECT * INTO p_empresas_885.* 
           FROM empresas_885 
          WHERE cod_emp_gerencial = p_cod_empresa   
         IF log005_seguranca(p_user,"VDP","pol0717","CO") THEN
            IF pol0717_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
         HELP 1053
         IF log005_seguranca(p_user,"VDP","pol0717","CO") THEN
            IF pol0717_imprime_nff() THEN
               IF  pol0717_verifica_param_exportacao() = TRUE THEN 
               END IF
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0717_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0717
END FUNCTION

#-----------------------------------#
FUNCTION pol0717_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 08", p_versao)
   CURRENT WINDOW IS w_pol0717

   INPUT p_ies_impr_nff,
         p_num_nff_ini,
         p_num_nff_fim
  WITHOUT DEFAULTS
    FROM ies_impr_nff,
         num_nff_ini,
         num_nff_fim
      ON KEY (control-w)
         CASE
            WHEN infield(num_nff_ini)   CALL showhelp(3187)
            WHEN infield(num_nff_fim)   CALL showhelp(3188)
         END CASE

      BEFORE FIELD ies_impr_nff
         LET p_num_nff_ini = 0
         LET p_num_nff_fim = 999999
      AFTER FIELD ies_impr_nff
         IF p_ies_impr_nff IS NULL OR
            p_ies_impr_nff = "N" THEN
            LET p_ies_impr_nff = "N"
            DISPLAY p_ies_impr_nff TO ies_impr_nff
            DISPLAY p_num_nff_ini TO num_nff_ini
            DISPLAY p_num_nff_fim TO num_nff_fim
         ELSE
            IF p_ies_impr_nff <> "S" THEN
               NEXT FIELD ies_impr_nff
            ELSE
               LET p_ies_impr_nff = "R"
               DISPLAY p_num_nff_ini TO num_nff_ini
               DISPLAY p_num_nff_fim TO num_nff_fim
            END IF
         END IF

      AFTER FIELD num_nff_ini
         IF p_ies_impr_nff = "R" THEN
            IF p_num_nff_ini = 0 THEN
               NEXT FIELD num_nff_ini
            END IF
         END IF

      AFTER FIELD num_nff_fim 
         IF p_ies_impr_nff = "R" THEN
            IF p_num_nff_fim = 999999 THEN
               NEXT FIELD num_nff_fim 
            END IF
         END IF
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0717

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION

#----------------------------------#
FUNCTION pol0717_inicializa_campos()
#----------------------------------#
   INITIALIZE p_nff.*, 
              p_duplic.*, 
              pa_corpo_nff, 
              p_end_entrega.*, 
              p_consignat.*, 
              p_cidades1.*, 
              p_embalagem.*, 
              p_clientes.*, 
              p_paises.*, 
              p_transport.*, 
              p_uni_feder.*, 
              p_ped_itens_texto.*,
              p_subst_trib_uf.*,
              pa_texto_obs,
              pa_clas_fisc TO NULL
 
   LET p_num_nff_ini = 0
   LET p_num_nff_fim = 999999
   LET p_ies_impr_nff = "N" 

   LET p_ies_termina_relat = TRUE

   LET p_linhas_print     = 0
   LET p_val_tot_ipi_acum = 0

   SELECT den_empresa 
      INTO p_den_empresa 
   FROM empresa       
   WHERE cod_empresa = p_cod_empresa
   IF SQLCA.SQLCODE <> 0 THEN
      LET p_den_empresa = "EMPRESA NAO CADASTRADA"
   END IF
      
END FUNCTION

#------------------------------------------#
FUNCTION pol0717_verifica_param_exportacao()
#------------------------------------------#
   DEFINE p_ies_export           CHAR(01),
          p_cod_mercado          LIKE cli_dist_geog.cod_mercado

   SELECT par_vdp_txt[151,151]
     INTO p_ies_export
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa

   IF sqlca.sqlcode <> 0 THEN 
      RETURN FALSE
   END IF

   SELECT cod_mercado
     INTO p_cod_mercado
     FROM cli_dist_geog
    WHERE cod_cliente = p_wfat_mestre.cod_cliente

   IF sqlca.sqlcode <> 0 THEN 
      RETURN FALSE
   END IF

   IF p_ies_export  = "S"  AND 
      p_cod_mercado = "EX" THEN 
      RETURN TRUE
   ELSE 
      RETURN FALSE
   END IF
END FUNCTION

#----------------------------#
FUNCTION pol0717_imprime_nff()
#----------------------------#    
 IF log028_saida_relat(14,40) IS NOT NULL THEN 
    MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
    IF p_ies_impressao = "S" THEN 
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0717_relat TO PIPE p_nom_arquivo
       ELSE 
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0717.tmp' 
          START REPORT pol0717_relat TO p_caminho 
       END IF 
    ELSE
       START REPORT pol0717_relat TO p_nom_arquivo
    END IF
 ELSE 
    RETURN TRUE  
 END IF

   CALL pol0717_busca_dados_empresa()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_8lpp        = ascii 27, "0" 
   LET p_6lpp        = ascii 27, "2" 
   LET p_negrito     = ascii 27, "E"
   LET p_normal      = ascii 27, "F"

   DECLARE cq_wfat_mestre CURSOR WITH HOLD FOR
    SELECT *
      FROM wfat_mestre
     WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
       AND num_nff    >= p_num_nff_ini
       AND num_nff    <= p_num_nff_fim
       AND ies_impr_nff = p_ies_impr_nff  
       AND num_nff NOT IN(SELECT num_nff
 												FROM nf_mestre
											 WHERE cod_empresa=p_empresas_885.cod_emp_gerencial
											   AND num_nff    >= p_num_nff_ini
       									 AND num_nff    <= p_num_nff_fim
 												 AND ies_situacao='C')
     ORDER BY num_nff

   FOREACH cq_wfat_mestre INTO p_wfat_mestre.*

      DISPLAY p_wfat_mestre.num_nff TO num_nff_proces {mostra nf em processam.}

      CALL pol0717_cria_temp_w_cla_fisc()

      CALL pol0717_cria_tabela_temporaria()

      LET p_nff.num_nff            = p_wfat_mestre.num_nff
      LET p_nff.cod_fiscal         = p_wfat_mestre.cod_fiscal
      
      CALL pol0717_le_num_recibo()
      
      CALL pol0717_busca_dados_subst_trib_uf()
      LET p_nff.ins_estadual_trib  = p_subst_trib_uf.ins_estadual
      LET p_nff.den_nat_oper       = pol0717_den_nat_oper()
      LET p_nff.nat_oper           = p_wfat_mestre.cod_nat_oper
      LET p_nff.dat_emissao        = p_wfat_mestre.dat_emissao

      CALL pol0717_busca_dados_clientes(p_wfat_mestre.cod_cliente)
      LET p_nff.nom_destinatario   = p_clientes.nom_cliente
      LET p_nff.num_cgc_cpf        = p_clientes.num_cgc_cpf
      LET p_nff.end_destinatario   = p_clientes.end_cliente
      LET p_nff.den_bairro         = p_clientes.den_bairro
      LET p_nff.cod_cep            = p_clientes.cod_cep
      LET p_nff.cod_cliente        = p_clientes.cod_cliente

      CALL pol0717_busca_dados_cidades(p_clientes.cod_cidade)

      LET p_nff.den_cidade         = p_cidades1.den_cidade          
      LET p_nff.num_telefone       = p_clientes.num_telefone
      LET p_nff.cod_uni_feder      = p_cidades1.cod_uni_feder
      LET p_nff.ins_estadual       = p_clientes.ins_estadual
      LET p_nff.hora_saida         = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0717_busca_nome_pais()
      LET p_nff.den_pais           = p_paises.den_pais              

      CALL pol0717_busca_dados_duplicatas()

      CALL pol0717_carrega_end_cobranca()
    
      CALL pol0717_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0717_busca_dados_pedido() 

      LET p_val_tot_it = 0

      CALL pol0717_carrega_tabela_temporaria() {corpo todo da nota}

      LET p_nff.val_tot_base_icm   = p_wfat_mestre.val_tot_base_icm
      LET p_nff.val_tot_icm        = p_wfat_mestre.val_tot_icm
      LET p_nff.val_tot_base_ret   = p_wfat_mestre.val_tot_base_ret
      LET p_nff.val_tot_icm_ret    = p_wfat_mestre.val_tot_icm_ret
      LET p_nff.val_tot_mercadoria = p_wfat_mestre.val_tot_mercadoria
      LET p_nff.val_frete_cli      = p_wfat_mestre.val_frete_cli
      LET p_nff.val_seguro_cli     = p_wfat_mestre.val_seguro_cli
      LET p_nff.val_tot_despesas   = 0
      LET p_nff.val_tot_ipi        = p_wfat_mestre.val_tot_ipi
      LET p_nff.val_tot_nff        = p_wfat_mestre.val_tot_nff
      LET p_nff.val_desc_cred_icm  = p_wfat_mestre.val_desc_cred_icm  

      CALL pol0717_busca_dados_transport(p_wfat_mestre.cod_transpor)
      CALL pol0717_busca_dados_cidades(p_transport.cod_cidade)
      LET p_nff.nom_transpor       = p_transport.nom_cliente  
      IF p_wfat_mestre.ies_frete = 3 THEN 
         LET p_nff.ies_frete = 2
      ELSE 
         LET p_nff.ies_frete = 1
      END IF
      LET p_nff.num_placa          = p_wfat_mestre.num_placa
      LET p_nff.num_cgc_trans      = p_transport.num_cgc_cpf
      LET p_nff.end_transpor       = p_transport.end_cliente
      LET p_nff.den_cidade_trans   = p_cidades1.den_cidade
      LET p_nff.cod_uni_feder_trans= p_cidades1.cod_uni_feder
      LET p_nff.ins_estadual_trans = p_transport.ins_estadual
      LET p_nff.num_telefone_trans = p_transport.num_telefone
      LET p_nff.qtd_volume1        = p_wfat_mestre.qtd_volumes1 
      LET p_nff.qtd_volume2        = p_wfat_mestre.qtd_volumes2 
      LET p_nff.qtd_volume         = p_wfat_mestre.qtd_volumes1 +
                                     p_wfat_mestre.qtd_volumes2 +
                                     p_wfat_mestre.qtd_volumes3 +
                                     p_wfat_mestre.qtd_volumes4 +
                                     p_wfat_mestre.qtd_volumes5
      LET p_nff.den_marca          = " "              
      LET p_nff.num_pri_volume     = p_wfat_mestre.num_pri_volume
      LET p_nff.num_ult_volume     = p_wfat_mestre.num_pri_volume +
                                     p_nff.qtd_volume - 1
      
      LET p_nff.pes_tot_bruto      = p_wfat_mestre.pes_tot_bruto
      LET p_nff.pes_tot_liquido    = p_wfat_mestre.pes_tot_liquido

      LET p_nff.num_pedido   = p_wfat_item.num_pedido
      LET p_nff.cod_repres   = p_wfat_mestre.cod_repres
      LET p_nff.raz_social   = pol0717_representante()
      LET p_nff.num_suframa  = p_clientes.num_suframa
      LET p_nff.num_om       = p_wfat_item.num_om
      LET p_nff.des_especie1 = pol0717_especie(1)
      LET p_nff.des_especie2 = pol0717_especie(2)
      LET p_nff.des_especie3 = pol0717_especie(3)
      LET p_nff.den_cnd_pgto = pol0717_den_cnd_pgto()

      LET p_ies_lista = TRUE

      CALL pol0717_grava_dados_end_entrega()

      CALL pol0717_grava_dados_consig(p_wfat_mestre.cod_consig)

      CALL pol0717_grava_historico_nf_pedido()

      CALL pol0717_calcula_total_de_paginas()

      CALL pol0717_monta_relat()

      #### marca nf que ja foi impressa ####
      UPDATE wfat_mestre 
         SET ies_impr_nff = "R"
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND num_nff     = p_wfat_mestre.num_nff
#         AND nom_usuario = p_user

      CALL pol0717_inicializa_campos()

   END FOREACH

   FINISH REPORT pol0717_relat

   IF p_ies_lista THEN
     IF  p_ies_impressao = "S" THEN
         MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
     ELSE 
         MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " ATTRIBUTE(REVERSE)
     END IF
   ELSE
      MESSAGE ""
      ERROR " Nao Existem dados para serem Listados. "
   END IF

   RETURN TRUE

END FUNCTION


#---------------------------------------#
FUNCTION pol0717_cria_tabela_temporaria()
#---------------------------------------#
   WHENEVER ERROR CONTINUE
   BEGIN WORK

   LOCK TABLE wnotacop  IN EXCLUSIVE MODE

   COMMIT WORK

   DROP TABLE wnotacop;

   IF sqlca.sqlcode <> 0 THEN 
      DELETE FROM wnotacop;
   END IF

   CREATE TEMP TABLE wnotacop
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(015),
      den_item           CHAR(060),
      qtd_it_conv        DECIMAL(5,0),
      cod_cla_fisc       CHAR(001),
      cod_origem         CHAR(1),
      cod_tributacao     CHAR(1),
      cod_unid_med       CHAR(3),
      qtd_item           DECIMAL(12,3),
      pre_bruto          DECIMAL(17,6),
      val_desc           DECIMAL(15,2),   
      pct_desc           DECIMAL(5,2),  
      pre_unit           DECIMAL(17,6),
      val_liq_item       DECIMAL(15,2),
      pct_icm            DECIMAL(5,2),
      pct_ipi            DECIMAL(6,3),
      val_ipi            DECIMAL(15,2),
      des_texto          CHAR(120),
      num_nff            DECIMAL(6,0)
     ) WITH NO LOG;
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF

   WHENEVER ERROR STOP
 
END FUNCTION

#---------------------------------------#
FUNCTION pol0717_cria_temp_w_cla_fisc()
#---------------------------------------#
  WHENEVER ERROR CONTINUE

   DROP TABLE w_cla_fisc;

   CREATE TEMP TABLE w_cla_fisc
     (
      num_seq            SMALLINT,
      cod_cla_fisc       CHAR(10)
     ) WITH NO LOG;
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF

   WHENEVER ERROR STOP
 
END FUNCTION
#------------------------------#
FUNCTION pol0717_le_num_recibo()
#------------------------------#
  WHENEVER ERROR CONTINUE

    LET p_num_recibo = 0 

    SELECT num_recibo
     INTO p_num_recibo
     FROM ref_nota_885
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND num_nff     = p_wfat_mestre.num_nff
    
   IF sqlca.sqlcode = NOTFOUND  THEN
      SELECT *   
      INTO p_fat_numero_885.*
      FROM fat_numero_885 
      WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      
      IF SQLCA.SQLCODE <> 0 THEN 
         LET p_num_recibo = 0 
      ELSE   
         LET p_fat_numero_885.num_recibo = p_fat_numero_885.num_recibo + 1   
         LET p_num_recibo = p_fat_numero_885.num_recibo
         UPDATE fat_numero_885  
         SET    num_recibo = p_fat_numero_885.num_recibo 
         WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

         IF SQLCA.SQLCODE <> 0 THEN 
            LET p_num_recibo = 0 
         ELSE   
            INSERT   INTO ref_nota_885 VALUES (p_empresas_885.cod_emp_gerencial,
                                               p_wfat_mestre.num_nff,
                                               p_fat_numero_885.num_recibo,
                                              TODAY)
            IF SQLCA.SQLCODE <> 0 THEN 
               LET p_num_recibo = 0 
            END IF
         END IF         
       END IF
   ELSE
      IF sqlca.sqlcode <> 0 THEN 
         LET p_num_recibo = 0 
      END IF
   END IF

   WHENEVER ERROR STOP
 
END FUNCTION
#----------------------------#
FUNCTION pol0717_monta_relat()
#----------------------------#

   DECLARE cq_wnotacop CURSOR FOR
   SELECT *
      FROM wnotacop
   ORDER BY 1

   FOREACH cq_wnotacop INTO p_wnotacop.*

      IF p_wnotacop.ies_tip_info > 2 THEN 
         CONTINUE FOREACH
      END IF

      LET p_wnotacop.num_nff = p_wfat_mestre.num_nff
      LET p_duplic.den_cnd_pgto = p_nff.den_cnd_pgto
      LET p_duplic.val_desc_cred_icm = p_nff.val_desc_cred_icm
      LET p_duplic.num_nf_orig       = p_nff.num_nf_orig
      OUTPUT TO REPORT pol0717_relat(p_wnotacop.*, p_duplic.*)

   END FOREACH

  {imprimir as linhas que faltam para completar o corpo da nota}
  {somente se o numero de linhas da nota nao for multiplo de 8 }

#  IF p_ies_termina_relat = TRUE THEN
#     LET p_wnotacop.num_nff      = p_wfat_mestre.num_nff
#     LET p_wnotacop.num_seq      = p_wnotacop.num_seq + 1
#     LET p_wnotacop.ies_tip_info = 4
#  
#     OUTPUT TO REPORT pol0717_relat(p_wnotacop.*)
#  END IF

END FUNCTION

#---------------------------------------#
FUNCTION pol0717_busca_dados_duplicatas()
#---------------------------------------#

   DEFINE p_wfat_duplic RECORD LIKE wfat_duplic.*,
          p_contador    SMALLINT

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT * 
   FROM wfat_duplic
   WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
     AND num_nff     = p_wfat_mestre.num_nff
   ORDER BY cod_empresa,
            num_duplicata,
            dig_duplicata,
            dat_vencto_sd

   FOREACH cq_duplic INTO p_wfat_duplic.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1  
            LET p_duplic.num_duplic1    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic1    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd1 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic1    = p_wfat_duplic.val_duplic
         WHEN 2      
            LET p_duplic.num_duplic2    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic2    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd2 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic2    = p_wfat_duplic.val_duplic
         WHEN 3      
            LET p_duplic.num_duplic3    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic3    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd3 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic3    = p_wfat_duplic.val_duplic
         WHEN 4
            LET p_duplic.num_duplic4    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic4    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd4 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic4    = p_wfat_duplic.val_duplic
         WHEN 5
            LET p_duplic.num_duplic5    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic5    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd5 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic5    = p_wfat_duplic.val_duplic
         WHEN 6
            LET p_duplic.num_duplic6    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic6    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd6 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic6    = p_wfat_duplic.val_duplic
         WHEN 7
            LET p_duplic.num_duplic7    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic7    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd7 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic7    = p_wfat_duplic.val_duplic
         WHEN 8
            LET p_duplic.num_duplic8    = p_wfat_duplic.num_duplicata
            LET p_duplic.dig_duplic8    = p_wfat_duplic.dig_duplicata
            LET p_duplic.dat_vencto_sd8 = p_wfat_duplic.dat_vencto_sd
            LET p_duplic.val_duplic8    = p_wfat_duplic.val_duplic
         OTHERWISE   
            EXIT FOREACH
      END CASE

   END FOREACH

END FUNCTION


#-------------------------------------#
FUNCTION pol0717_carrega_end_cobranca()
#-------------------------------------#
   INITIALIZE p_cli_end_cobr.* TO NULL
  
   SELECT cli_end_cob.*
     INTO p_cli_end_cobr.*
     FROM cli_end_cob
    WHERE cod_cliente = p_nff.cod_cliente
  
   LET p_nff.end_cob_cli = p_cli_end_cobr.end_cobr
  
   SELECT den_cidade,
          cod_uni_feder
     INTO p_nff.den_cidade_cob,
          p_nff.cod_uni_feder_cobr
     FROM cidades
    WHERE cidades.cod_cidade = p_cli_end_cobr.cod_cidade_cob

END FUNCTION


#----------------------------------#
FUNCTION pol0717_carrega_corpo_nff()
#----------------------------------#
   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT

   LET p_ind = 1
   LET p_count = 0 
   LET p_nff.num_nf_orig = 0

 IF p_nat_operacao.ies_tip_controle = "4" THEN
   DECLARE cq_wfat_item_rt CURSOR FOR
    SELECT wfat_item.*
      FROM wfat_item, OUTER item
     WHERE wfat_item.cod_empresa = p_empresas_885.cod_emp_gerencial
       AND wfat_item.num_nff     = p_wfat_mestre.num_nff
       AND item.cod_empresa      = p_empresas_885.cod_emp_gerencial
       AND item.cod_item         = wfat_item.cod_item 
       AND wfat_item.num_pedido  > 0
    ORDER BY 1,2,3,4,5,7

   FOREACH cq_wfat_item_rt INTO p_wfat_item.*

          IF p_wfat_item.cod_cla_fisc IS NOT NULL AND
             p_wfat_item.cod_cla_fisc <> " " THEN
             SELECT COUNT(*) INTO p_count FROM w_cla_fisc
              WHERE cod_cla_fisc = p_wfat_item.cod_cla_fisc
                 IF p_count = 0 THEN
               CALL pol0717_carrega_classificacoes(p_wfat_item.cod_cla_fisc)
                 END IF
          END IF 

     IF p_wfat_item.num_pedido > 0 THEN  
        IF p_nff.num_nf_orig = 0 THEN
           SELECT a.num_nff
             INTO p_nff.num_nf_orig
             FROM nf_item a, nf_mestre b 
            WHERE a.cod_empresa = p_cod_emp_ofic
              AND a.num_om      = p_wfat_item.num_om
              AND a.cod_item    = p_wfat_item.cod_item
              AND a.num_pedido  = p_wfat_item.num_pedido
              AND a.num_sequencia = p_wfat_item.num_sequencia
              AND a.cod_empresa = b.cod_empresa
              AND a.num_nff     = b.num_nff
              AND b.ies_situacao = "N"   
        END IF
      END IF

      UPDATE ordem_montag_mest set ies_sit_om = "F"
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND num_om = p_wfat_item.num_om

      CALL pol0717_item_cliente()

      LET pa_corpo_nff[p_ind].cod_cla_fisc     = pol0717_carrega_clas_fiscal()
      LET pa_corpo_nff[p_ind].cod_item         = p_wfat_item.cod_item
      LET pa_corpo_nff[p_ind].cod_item_cliente = g_cod_item_cliente
      LET pa_corpo_nff[p_ind].num_pedido       = p_wfat_item.num_pedido

      IF g_cod_item_cliente IS NULL THEN
         LET pa_corpo_nff[p_ind].den_item1   = p_wfat_item.den_item[01,60]
         LET pa_corpo_nff[p_ind].den_item2   = p_wfat_item.den_item[61,76]
      ELSE
         LET pa_corpo_nff[p_ind].den_item1   = g_cod_item_cliente
         LET pa_corpo_nff[p_ind].den_item2   = " "
      END IF

      CALL pol0717_busca_dados_pedido()
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli
      LET pa_corpo_nff[p_ind].cod_origem     = p_wfat_mestre.cod_origem
      LET pa_corpo_nff[p_ind].cod_tributacao = p_wfat_mestre.cod_tributacao
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_item.qtd_item

      SELECT pre_unit 
        INTO pa_corpo_nff[p_ind].pre_bruto
        FROM desc_preco_item 
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND cod_item    = p_wfat_item.cod_item 
         AND num_list_preco = p_num_list_preco
      IF sqlca.sqlcode <> 0 THEN
         LET pa_corpo_nff[p_ind].pre_bruto      = p_wfat_item.pre_unit_ped
      END IF
      LET pa_corpo_nff[p_ind].val_desc       = p_wfat_item.val_desc_adicional
      LET pa_corpo_nff[p_ind].pct_desc       = (1 - (p_wfat_item.pre_unit_nf / 
                                                p_wfat_item.pre_unit_ped)) * 100

###   IF p_wfat_mestre.ies_origem = "I" THEN 
         LET pa_corpo_nff[p_ind].pre_unit = p_wfat_item.pre_unit_nf
###   ELSE 
###      LET pa_corpo_nff[p_ind].pre_unit = p_wfat_item.pre_unit_ped 
###   END IF
      LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_item.val_liq_item
      LET pa_corpo_nff[p_ind].pct_icm      = p_wfat_mestre.pct_icm

      IF p_wfat_mestre.val_tot_icm      = 0 OR 
         p_wfat_mestre.val_tot_base_icm = 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = 0
      END IF

      LET pa_corpo_nff[p_ind].pct_ipi     = p_wfat_item.pct_ipi
      LET pa_corpo_nff[p_ind].val_ipi     = p_wfat_item.val_ipi
      LET pa_corpo_nff[p_ind].val_icm_ret = p_wfat_item.val_icm_ret
      LET p_val_tot_ipi_acum              = p_val_tot_ipi_acum + 
                                            p_wfat_item.val_ipi

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1
   END FOREACH
 ELSE
   DECLARE cq_wfat_item CURSOR FOR
    SELECT wfat_item.*
      FROM wfat_item, OUTER item
     WHERE wfat_item.cod_empresa = p_empresas_885.cod_emp_gerencial
       AND wfat_item.num_nff     = p_wfat_mestre.num_nff
       AND item.cod_empresa      = p_empresas_885.cod_emp_gerencial
       AND item.cod_item         = wfat_item.cod_item
    ORDER BY 1,2,3,4,5,7

   FOREACH cq_wfat_item INTO p_wfat_item.*

          IF p_wfat_item.cod_cla_fisc IS NOT NULL AND
             p_wfat_item.cod_cla_fisc <> " " THEN
             SELECT COUNT(*) INTO p_count FROM w_cla_fisc
              WHERE cod_cla_fisc = p_wfat_item.cod_cla_fisc
                 IF p_count = 0 THEN
               CALL pol0717_carrega_classificacoes(p_wfat_item.cod_cla_fisc)
                 END IF
          END IF 

     IF p_wfat_item.num_pedido > 0 THEN  
        IF p_nff.num_nf_orig = 0 THEN
           SELECT UNIQUE a.num_nff
             INTO p_nff.num_nf_orig
             FROM nf_item a, nf_mestre b 
            WHERE a.cod_empresa = p_cod_emp_ofic
              AND a.num_om      = p_wfat_item.num_om
              AND a.cod_item    = p_wfat_item.cod_item
              AND a.num_pedido  = p_wfat_item.num_pedido
              AND a.num_sequencia = p_wfat_item.num_sequencia
              AND a.cod_empresa = b.cod_empresa
              AND a.num_nff     = b.num_nff
              AND b.ies_situacao = "N"   
        END IF
      END IF

      UPDATE ordem_montag_mest set ies_sit_om = "F"
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial 
         AND num_om = p_wfat_item.num_om

      CALL pol0717_item_cliente()

      LET pa_corpo_nff[p_ind].cod_cla_fisc     = pol0717_carrega_clas_fiscal()
      LET pa_corpo_nff[p_ind].cod_item         = p_wfat_item.cod_item
      LET pa_corpo_nff[p_ind].cod_item_cliente = g_cod_item_cliente
      LET pa_corpo_nff[p_ind].num_pedido       = p_wfat_item.num_pedido

      IF g_cod_item_cliente IS NULL THEN
         LET pa_corpo_nff[p_ind].den_item1   = p_wfat_item.den_item[01,60]
         LET pa_corpo_nff[p_ind].den_item2   = p_wfat_item.den_item[61,76]
      ELSE
         LET pa_corpo_nff[p_ind].den_item1   = g_cod_item_cliente
         LET pa_corpo_nff[p_ind].den_item2   = " "
      END IF

      CALL pol0717_busca_dados_pedido()
      LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli
      LET pa_corpo_nff[p_ind].cod_origem     = p_wfat_mestre.cod_origem
      LET pa_corpo_nff[p_ind].cod_tributacao = p_wfat_mestre.cod_tributacao
      LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_item.qtd_item

{      SELECT pre_unit 
        INTO pa_corpo_nff[p_ind].pre_bruto
        FROM desc_preco_item 
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND cod_item    = p_wfat_item.cod_item 
         AND num_list_preco = p_num_list_preco 
      IF sqlca.sqlcode <> 0 THEN }
         LET pa_corpo_nff[p_ind].pre_bruto      = p_wfat_item.pre_unit_ped
 #     END IF
      LET pa_corpo_nff[p_ind].val_desc       = p_wfat_item.val_desc_adicional
      LET pa_corpo_nff[p_ind].pct_desc       = (1 - (p_wfat_item.pre_unit_nf / 
                                                p_wfat_item.pre_unit_ped)) * 100

###   IF p_wfat_mestre.ies_origem = "I" THEN 
         LET pa_corpo_nff[p_ind].pre_unit = p_wfat_item.pre_unit_nf
###   ELSE 
###      LET pa_corpo_nff[p_ind].pre_unit = p_wfat_item.pre_unit_ped 
###   END IF
      LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_item.val_liq_item
      LET pa_corpo_nff[p_ind].pct_icm      = p_wfat_mestre.pct_icm

      IF p_wfat_mestre.val_tot_icm      = 0 OR 
         p_wfat_mestre.val_tot_base_icm = 0 THEN
         LET pa_corpo_nff[p_ind].pct_icm = 0
      END IF

      LET pa_corpo_nff[p_ind].pct_ipi     = p_wfat_item.pct_ipi
      LET pa_corpo_nff[p_ind].val_ipi     = p_wfat_item.val_ipi
      LET pa_corpo_nff[p_ind].val_icm_ret = p_wfat_item.val_icm_ret
      LET p_val_tot_ipi_acum              = p_val_tot_ipi_acum + 
                                            p_wfat_item.val_ipi

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1
   END FOREACH 
  END IF
END FUNCTION

#-----------------------------#
FUNCTION pol0717_item_cliente()
#-----------------------------#
   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
     INTO g_cod_item_cliente    
     FROM cliente_item
    WHERE cod_empresa        = p_empresas_885.cod_emp_gerencial
      AND cod_cliente_matriz = p_wfat_mestre.cod_cliente
      AND cod_item           = p_wfat_item.cod_item

END FUNCTION

#------------------------------------------------------#
FUNCTION pol0717_carrega_classificacoes(l_cod_cla_fisc)
#------------------------------------------------------#
 DEFINE l_cod_cla_fisc   LIKE wfat_item.cod_cla_fisc,
        l_num_seq        SMALLINT

   LET l_num_seq = 0

   SELECT MAX(num_seq) INTO l_num_seq FROM w_cla_fisc
   
   IF l_num_seq IS NULL THEN
      LET l_num_seq = 1
   ELSE
      LET l_num_seq = l_num_seq + 1
   END IF 

   INSERT INTO w_cla_fisc values(l_num_seq,l_cod_cla_fisc)
  
END FUNCTION

#------------------------------------#
FUNCTION pol0717_carrega_clas_fiscal()
#------------------------------------#
   DEFINE l_cont          SMALLINT,
          l_cla_fisc_nff  CHAR(02),
          l_aux_cla_fisc  CHAR(02)

   INITIALIZE l_aux_cla_fisc TO NULL
   LET l_cla_fisc_nff = "A"
   
    IF p_wfat_item.cod_cla_fisc = "73182100" THEN 
       LET l_cla_fisc_nff = "A" 
    ELSE 
       IF p_wfat_item.cod_cla_fisc = "73181500" THEN 
          LET l_cla_fisc_nff = "B" 
       ELSE 
          IF p_wfat_item.cod_cla_fisc = "83021000" THEN 
             LET l_cla_fisc_nff = "C" 
          ELSE 
             IF p_wfat_item.cod_cla_fisc = "83013000" THEN 
                LET l_cla_fisc_nff = "D" 
             ELSE 
                IF p_wfat_item.cod_cla_fisc = "79070000" THEN 
                   LET l_cla_fisc_nff = "E" 
                ELSE  
                   IF p_wfat_item.cod_cla_fisc = "39263000" THEN 
                      LET l_cla_fisc_nff = "F" 
                   ELSE  
                      IF p_wfat_item.cod_cla_fisc = "83024200" THEN 
                         LET l_cla_fisc_nff = "G" 
                      ELSE  
                         IF p_wfat_item.cod_cla_fisc = "72042900" THEN 
                            LET l_cla_fisc_nff = "H" 
                         ELSE  
                            IF p_wfat_item.cod_cla_fisc = "74032100" THEN 
                               LET l_cla_fisc_nff = "I" 
                            ELSE  
                               IF p_wfat_item.cod_cla_fisc = "48119000" THEN 
                                  LET l_cla_fisc_nff = "J" 
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


   RETURN l_cla_fisc_nff            
END FUNCTION

#-----------------------------------------#
FUNCTION pol0717_carrega_historico_fiscal()
#-----------------------------------------#  
   INITIALIZE p_wfat_historico.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_wfat_historico.*
     FROM wfat_historico
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND num_nff     = p_wfat_mestre.num_nff
   WHENEVER ERROR STOP

   IF p_wfat_historico.tex_hist1_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist1_1)
   END IF
   IF p_wfat_historico.tex_hist2_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist2_1)
   END IF
   IF p_wfat_historico.tex_hist3_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist3_1)
   END IF
   IF p_wfat_historico.tex_hist4_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist4_1)
   END IF
   IF p_wfat_historico.tex_hist1_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist1_2)
   END IF
   IF p_wfat_historico.tex_hist2_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist2_2)
   END IF
   IF p_wfat_historico.tex_hist3_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist3_2)
   END IF
   IF p_wfat_historico.tex_hist4_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist4_2)
   END IF
   
   IF   p_wfat_mestre.val_tot_icm_ret > 0
   THEN LET p_des_texto = "BASE DE CALCULO ICMS ST.... R$ ", p_wfat_mestre.val_tot_base_ret USING "###,###,##&.&&",
                          "   - ALIQ UF DEST.: ",p_subst_trib_uf.pct_icm USING "#&","%"   
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "ICMS S/ OPERACAO DE VENDA.. R$ ", p_wfat_mestre.val_tot_icm USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "ICMS RETIDO................ R$ ", p_wfat_mestre.val_tot_icm_ret USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "TOTAL DO ICMS.............. R$ ", (p_wfat_mestre.val_tot_icm_ret + p_wfat_mestre.val_tot_icm) USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
   END IF

   IF p_clientes.ies_zona_franca  = "S" AND
      p_clientes.num_suframa      >  0  AND
      p_wfat_mestre.val_desc_merc >  0  THEN
      LET p_des_texto = "DESCONTO ESPECIAL DE ", p_wfat_mestre.pct_icm
                         USING "#&.&", "%  ICMS.........:",
                         p_wfat_mestre.val_desc_merc USING "###,###,##&.&&"
      CALL pol0717_insert_array(p_des_texto)
   END IF

   IF (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum) > 0 THEN
      LET p_des_texto = "IPI S/ FRETE  ",
                        (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum)
                         USING "#######&.&&"
      CALL pol0717_insert_array(p_des_texto)
   END IF
   IF p_clientes.num_suframa > 0 THEN
      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&";
      CALL pol0717_insert_array(p_des_texto)
   END IF
END FUNCTION

#------------------------------------------#
FUNCTION pol0717_carrega_tabela_temporaria()
#------------------------------------------#
   DEFINE i, j          SMALLINT,
          p_val_merc    DECIMAL(15,2)   

   LET i                  = 1
   LET p_num_seq          = 0
   LET p_qtd_lin_obs      = 0
   LET p_val_merc         = 0

   FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      { grava o codigo do item }

      SELECT fat_conver
        INTO p_fat_conver
        FROM ctr_unid_med
       WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
         AND cod_item = pa_corpo_nff[i].cod_item
      IF sqlca.sqlcode <> 0 THEN
         LET p_fat_conver = 0 
      END IF

      LET p_wnotacop.qtd_it_conv     =  pa_corpo_nff[i].qtd_item * p_fat_conver

      LET p_num_seq = p_num_seq + 1

      LET p_wnotacop.num_seq         =  p_num_seq
      LET p_wnotacop.ies_tip_info    =  1       
      LET p_wnotacop.cod_item        =  pa_corpo_nff[i].cod_item
      LET p_wnotacop.den_item        =  pa_corpo_nff[i].den_item1
      LET p_wnotacop.cod_unid_med    =  pa_corpo_nff[i].cod_unid_med
      LET p_wnotacop.qtd_item        =  pa_corpo_nff[i].qtd_item

      LET p_wnotacop.pre_bruto       =  pa_corpo_nff[i].pre_bruto
      LET p_wnotacop.val_desc        =  pa_corpo_nff[i].val_desc
      LET p_wnotacop.pct_desc        =  pa_corpo_nff[i].pct_desc

      LET p_wnotacop.pre_unit        =  pa_corpo_nff[i].pre_unit
      LET p_wnotacop.val_liq_item    =  pa_corpo_nff[i].val_liq_item
      LET p_wnotacop.num_nff         =  0 
      INSERT INTO wnotacop VALUES ( p_wnotacop.* )
 
      LET p_val_tot_it = p_val_tot_it + pa_corpo_nff[i].val_liq_item

      { insere segunda parte da denominacao do item, se esta existir }

      IF pa_corpo_nff[i].den_item2 IS NOT NULL AND 
         pa_corpo_nff[i].den_item2 <> "  "     THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotacop 
                VALUES (p_num_seq,2,NULL,pa_corpo_nff[i].den_item2,NULL,
                       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
      END IF

      { imprime texto do item, se este existir }

      FOR j = 1 TO 05
         IF pol0717_verifica_texto_ped_it(pa_corpo_nff[i].num_pedido,i) THEN
            IF pa_texto_ped_it[j].texto IS NOT NULL AND 
               pa_texto_ped_it[j].texto <> " " THEN
               LET p_num_seq = p_num_seq + 1
               INSERT INTO wnotacop VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,
                                            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                            pa_texto_ped_it[j].texto,NULL)
            END IF
         END IF
      END FOR
      LET p_val_merc = p_val_merc + pa_corpo_nff[i].val_liq_item 
    
      IF p_nat_operacao.ies_tip_controle = "4" THEN
 
         LET p_des_texto=null   
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotacop VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,
                                      NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                      NULL,NULL,p_des_texto,NULL) 

         DECLARE cq_wfat_itret CURSOR WITH HOLD FOR
         SELECT den_item_reduz,qtd_item,pre_unit_nf,pre_unit_nf*qtd_item,item.cod_unid_med
           FROM wfat_item , item   
          WHERE wfat_item.cod_empresa = p_empresas_885.cod_emp_gerencial
            AND wfat_item.cod_empresa = item.cod_empresa 
            AND wfat_item.cod_item    = item.cod_item    
            AND wfat_item.num_nff     = p_wfat_mestre.num_nff
            AND wfat_item.num_pedido  = 0                     

         FOREACH cq_wfat_itret INTO p_den_item_reduz,p_qtd_item,p_pre_unit_nf,p_pre_tot_nf,p_unid_med

           LET p_des_texto = p_den_item_reduz,"qtd ",p_qtd_item," ",p_unid_med," unit. ",p_pre_unit_nf," total ",p_pre_tot_nf
         	
           LET p_num_seq = p_num_seq + 1
           INSERT INTO wnotacop VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                        NULL,NULL,p_des_texto,NULL)
         END FOREACH
      END IF   

   END FOR
   
#   LET p_des_texto = " "
#   CALL pol0717_insert_array(p_des_texto)
   
 { IF p_clientes.ies_zona_franca  = "S" AND
      p_clientes.num_suframa      >  0  AND
      p_wfat_mestre.val_desc_merc >  0  THEN
      LET p_des_texto = "DESCONTO ESPECIAL DE ", p_wfat_mestre.pct_icm
                         USING "#&.&", "%  ICMS.........:",
                         p_wfat_mestre.val_desc_merc USING "###,###,##&.&&"
      CALL pol0717_insert_array(p_des_texto)
   END IF

   IF (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum) > 0 THEN
      LET p_des_texto = "IPI S/ FRETE  ",
                        (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum)
                         USING "#######&.&&"
      CALL pol0717_insert_array(p_des_texto)
   END IF
   IF p_clientes.num_suframa > 0 THEN
      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&";
      CALL pol0717_insert_array(p_des_texto)
   END IF  }  
END FUNCTION


#-----------------------------------------#
FUNCTION pol0717_calcula_total_de_paginas()
#-----------------------------------------#

   SELECT COUNT(*)
      INTO p_num_linhas
   FROM wnotacop
   WHERE ies_tip_info <> 3

   { 33 = numero de linhas do corpo da nota fiscal }

   IF p_num_linhas IS NOT NULL AND 
      p_num_linhas > 0         THEN 

      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 11 )) / 11 
 
      IF (p_num_linhas MOD 11 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_ies_termina_relat = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION


#------------------------------------------#
FUNCTION pol0717_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM clientes, cidades, subst_trib_uf
    WHERE clientes.cod_cliente        = p_wfat_mestre.cod_cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
   WHENEVER ERROR STOP
END FUNCTION


#-----------------------------#
FUNCTION pol0717_den_nat_oper()
#-----------------------------#

   WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
     INTO p_nat_operacao.*
     FROM nat_operacao
    WHERE cod_nat_oper = p_wfat_mestre.cod_nat_oper
   WHENEVER ERROR STOP
 
   IF sqlca.sqlcode = 0 THEN 
      IF p_nat_operacao.ies_tip_controle = "4" THEN 
         SELECT unique cod_fiscal 
           INTO p_cod_fiscal_ind
           FROM nf_item_fiscal 
          WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
            AND num_nff = p_wfat_mestre.num_nff 
            AND cod_fiscal <> p_wfat_mestre.cod_fiscal
      END IF 	 			

      IF p_nat_operacao.ies_subst_tribut <> "S" THEN 
         LET p_nff.ins_estadual_trib = NULL
      END IF  

      RETURN p_nat_operacao.den_nat_oper
   ELSE 
      RETURN "NATUREZA NAO CADASTRADA"
   END IF 

END FUNCTION

#------------------------------------#
FUNCTION pol0717_busca_dados_empresa()            
#------------------------------------#
   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
     INTO p_empresa.*
     FROM empresa
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial

   WHENEVER ERROR STOP
END FUNCTION

#------------------------------#
FUNCTION pol0717_representante()
#------------------------------#
   DEFINE p_nom_guerra LIKE representante.raz_social

   SELECT raz_social
     INTO p_nom_guerra
     FROM representante
    WHERE cod_repres = p_wfat_mestre.cod_repres

   RETURN p_nom_guerra
END FUNCTION

#---------------------------------------#
FUNCTION pol0717_grava_dados_historicos()
#---------------------------------------#
   INITIALIZE p_wfat_historico.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_wfat_historico.*
     FROM wfat_historico
    WHERE cod_empresa = p_empresas_885.cod_emp_gerencial
      AND num_nff     = p_wfat_mestre.num_nff
   WHENEVER ERROR STOP

   IF p_wfat_historico.tex_hist1_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist1_1)
   END IF
   IF p_wfat_historico.tex_hist2_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist2_1)
   END IF
   IF p_wfat_historico.tex_hist3_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist3_1)
   END IF
   IF p_wfat_historico.tex_hist4_1 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist4_1)
   END IF
   IF p_wfat_historico.tex_hist1_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist1_2)
   END IF
   IF p_wfat_historico.tex_hist2_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist2_2)
   END IF
   IF p_wfat_historico.tex_hist3_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist3_2)
   END IF
   IF p_wfat_historico.tex_hist4_2 <> " " THEN
      CALL pol0717_insert_array(p_wfat_historico.tex_hist4_2)
   END IF
   
   IF   p_wfat_mestre.val_tot_icm_ret > 0
   THEN LET p_des_texto = "BASE DE CALCULO ICMS ST.... R$ ", p_wfat_mestre.val_tot_base_ret USING "###,###,##&.&&",
                          "   - ALIQ UF DEST.: ",p_subst_trib_uf.pct_icm USING "#&","%"   
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "ICMS S/ OPERACAO DE VENDA.. R$ ", p_wfat_mestre.val_tot_icm USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "ICMS RETIDO................ R$ ", p_wfat_mestre.val_tot_icm_ret USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
        LET p_des_texto = "TOTAL DO ICMS.............. R$ ", (p_wfat_mestre.val_tot_icm_ret + p_wfat_mestre.val_tot_icm) USING "###,###,##&.&&"
        CALL pol0717_insert_array(p_des_texto)
   END IF
END FUNCTION
 
#------------------------------#
FUNCTION pol0717_especie(p_ind)
#------------------------------#
   DEFINE p_des_especie    CHAR(30),
          p_ind            INTEGER

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
   END CASE 
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN 
      LET p_des_especie = p_embalagem.den_embal
   END IF

   RETURN p_des_especie
END FUNCTION 

#-----------------------------#
FUNCTION pol0717_den_cnd_pgto()
#-----------------------------#
   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(05,3)

   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,pct_desp_finan
     INTO p_den_cnd_pgto,p_pct_desp_finan
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_wfat_mestre.cod_cnd_pgto
   WHENEVER ERROR STOP
 
   IF p_pct_desp_finan IS NOT NULL
      AND p_pct_desp_finan > 1 THEN
      LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
      LET p_des_texto = "ENCARGO FINANCEIRO: ",  p_pct_enc_finan USING "#&.&&&"," %"
      CALL pol0717_insert_array(p_des_texto)
   END IF 

   RETURN p_den_cnd_pgto

END FUNCTION 


#---------------------------------------------------#
FUNCTION pol0717_busca_dados_clientes(p_cod_cliente)
#---------------------------------------------------#
   DEFINE p_cod_cliente      LIKE clientes.cod_cliente,
          p_aux_nom_cliente  LIKE clientes.nom_cliente

   INITIALIZE p_clientes.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_wfat_mestre.cod_cliente

END FUNCTION

#--------------------------------#
FUNCTION pol0717_busca_nome_pais()                   
#--------------------------------#
   INITIALIZE p_paises.* ,
              p_uni_feder.*    TO NULL 
 
   WHENEVER ERROR CONTINUE
   SELECT *  
     INTO p_uni_feder.*
     FROM uni_feder
    WHERE cod_uni_feder = p_cidades1.cod_uni_feder      
   WHENEVER ERROR STOP

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_paises.*
     FROM paises   
    WHERE cod_pais = p_uni_feder.cod_pais       
   WHENEVER ERROR STOP
END FUNCTION
 
#----------------------------------------------------#
FUNCTION pol0717_busca_dados_transport(p_cod_transpor)
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
FUNCTION pol0717_busca_dados_cidades(p_cod_cidade)
#------------------------------------------------#
   DEFINE p_cod_cidade     LIKE cidades.cod_cidade

   INITIALIZE p_cidades1.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_cidades1.*
     FROM cidades
    WHERE cod_cidade = p_cod_cidade
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------#
FUNCTION pol0717_busca_dados_pedido()
#-----------------------------------#  

   SELECT pedidos.num_pedido_repres, 
          pedidos.num_pedido_cli,
          pedidos.num_list_preco
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli,
          p_num_list_preco
     FROM pedidos
    WHERE pedidos.cod_empresa         = p_wfat_mestre.cod_empresa 
      AND pedidos.num_pedido          = p_wfat_item.num_pedido

END FUNCTION

#-----------------------------------------------#
FUNCTION pol0717_grava_dados_consig(p_cod_consig)
#-----------------------------------------------#
   DEFINE p_cod_consig  LIKE clientes.cod_cliente

   INITIALIZE p_consignat.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT clientes.nom_cliente,
          clientes.end_cliente,
          clientes.den_bairro,
          clientes.num_telefone,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_consignat.*
     FROM clientes, 
          cidades
    WHERE clientes.cod_cliente = p_cod_consig
      AND clientes.cod_cidade  = cidades.cod_cidade
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN 
      IF p_consignat.den_consignat IS NOT NULL OR
         p_consignat.den_consignat  <> "  "    THEN 
         LET p_des_texto = "Consig.: ", p_consignat.den_consignat       
         CALL pol0717_insert_array(p_des_texto)

         IF p_consignat.end_consignat IS NOT NULL OR
            p_consignat.end_consignat <> "  "     THEN
            LET p_des_texto   = p_consignat.end_consignat        
            CALL pol0717_insert_array(p_des_texto)
         END IF

         IF p_consignat.den_bairro IS NOT NULL OR
            p_consignat.den_bairro <> "  "     THEN
            LET p_des_texto   = p_consignat.den_bairro        
            CALL pol0717_insert_array(p_des_texto)
         END IF

         IF p_consignat.den_cidade IS NOT NULL OR
            p_consignat.den_cidade <> "  "     THEN
            LET p_des_texto   = p_consignat.den_cidade        
            CALL pol0717_insert_array(p_des_texto)
         END IF
      END IF
   END IF
END FUNCTION

#----------------------------------------#
FUNCTION pol0717_grava_dados_end_entrega()
#----------------------------------------#
   WHENEVER ERROR CONTINUE
   SELECT wfat_end_ent.end_entrega,
          wfat_end_ent.num_cgc,
          wfat_end_ent.ins_estadual,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_end_entrega.*
     FROM wfat_end_ent,
          cidades
    WHERE wfat_end_ent.cod_empresa = p_empresas_885.cod_emp_gerencial
      AND wfat_end_ent.num_nff     = p_wfat_mestre.num_nff
      AND wfat_end_ent.cod_cidade  = cidades.cod_cidade
   WHENEVER ERROR STOP

END FUNCTION

#------------------------------------------#
FUNCTION pol0717_grava_historico_nf_pedido()
#------------------------------------------#
   DEFINE i       SMALLINT

   { imprime texto da nota, se este existir  } 

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
         IF p_des_texto IS NOT NULL OR
            p_des_texto <> "  "     THEN
            CALL pol0717_insert_array(p_des_texto[1,75])
            IF p_des_texto[76,120] IS NOT NULL AND
               p_des_texto[76,120] <> " " THEN
               CALL pol0717_insert_array(p_des_texto[76,120])
            END IF
         END IF
      END FOREACH
   END IF

   { grava_texto do pedido, se este existir  
     tirar seq. 0 da impressao da nota CERSA.

   IF pol0717_verifica_texto_ped_it(pa_corpo_nff[1].num_pedido,0) THEN
      FOR i = 1 TO 05
         IF pa_texto_ped_it[i].texto IS NOT NULL AND 
            pa_texto_ped_it[i].texto <> " "      THEN
            LET p_des_texto = pa_texto_ped_it[i].texto
            CALL pol0717_insert_array(p_des_texto)
         END IF
      END FOR
   END IF } 
  
END FUNCTION

#-------------------------------------------------------------------#
FUNCTION pol0717_verifica_texto_ped_it(p_num_pedido, p_num_sequencia)
#-------------------------------------------------------------------#
   DEFINE p_num_pedido     LIKE pedidos.num_pedido,
          p_num_sequencia  LIKE ped_itens_texto.num_sequencia,
          p_des_esp_item   CHAR(30),                              
          p_cod_item       LIKE item.cod_item,                    
          p_junt_texto     CHAR(76)                          

   INITIALIZE pa_texto_ped_it     ,         
              p_junt_texto ,
              p_des_esp_item ,
              p_ped_itens_texto.*    TO NULL

   WHENEVER ERROR CONTINUE
   SELECT cod_item 
     INTO p_cod_item           
     FROM ped_itens       
    WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
      AND num_pedido    = p_num_pedido
      AND num_sequencia = p_num_sequencia 

   SELECT des_esp_item[1,30]
     INTO p_des_esp_item       
     FROM item_esp        
    WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
      AND cod_item      = p_cod_item  
      AND num_seq       = 1                

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_empresas_885.cod_emp_gerencial
      AND num_pedido    = p_num_pedido
      AND num_sequencia = p_num_sequencia
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN 
      IF p_des_esp_item IS NOT NULL THEN 
         LET pa_texto_ped_it[1].texto = p_des_esp_item,p_ped_itens_texto.den_texto_1[1,30]
      ELSE 
         LET pa_texto_ped_it[1].texto = p_ped_itens_texto.den_texto_1
      END IF
   ELSE 
      IF p_des_esp_item IS NOT NULL THEN 
         LET pa_texto_ped_it[1].texto = p_des_esp_item 
      ELSE
         RETURN FALSE
      END IF
    END IF
    RETURN TRUE
END FUNCTION

#----------------------------------------------#
FUNCTION pol0717_carrega_classificacao_fiscal()
#----------------------------------------------#
 DEFINE p_count        INTEGER

   FOR p_count=1  TO 10
       INITIALIZE g_cla_fisc[p_count].* TO NULL
   END FOR

   LET p_count = 1
   
   DECLARE cq_w_cla_fisc CURSOR WITH HOLD FOR
    SELECT *
      FROM w_cla_fisc
     ORDER BY num_seq

   FOREACH cq_w_cla_fisc INTO g_cla_fisc[p_count].*

   LET p_count = p_count +1

    IF p_count = 11 THEN
       EXIT FOREACH
    END IF

   END FOREACH 
 
END FUNCTION

#----------------------------------------#
FUNCTION pol0717_insert_array(p_des_texto)
#----------------------------------------#

   DEFINE p_des_texto CHAR(120)

   LET p_num_seq = p_num_seq + 1
   
   # No corpo da Nf. tem espaco para imprimir toda a OBS, nao precisa
   # quebrar em partes.

   INSERT INTO wnotacop
      VALUES (p_num_seq,3,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, 
              NULL,NULL,NULL,p_des_texto,NULL)

END FUNCTION 

#----------------------------------------#
REPORT pol0717_relat(p_wnotacop, p_duplic)
#----------------------------------------#

   DEFINE i            SMALLINT,
          l_nulo       CHAR(10),
          p_nf_ant     DECIMAL(7,0),
          p_traco      CHAR(115), 
          p_cont_nf_rt SMALLINT

   DEFINE p_wnotacop RECORD
      num_seq          SMALLINT,
      ies_tip_info     SMALLINT,
      cod_item         LIKE wfat_item.cod_item,
      den_item         CHAR(060),
      qtd_it_conv      DEC(5,0),
      cod_cla_fisc     CHAR(001),
      cod_origem       LIKE wfat_mestre.cod_origem,
      cod_tributacao   LIKE wfat_mestre.cod_tributacao,
      cod_unid_med     LIKE wfat_item.cod_unid_med,
      qtd_item         LIKE wfat_item.qtd_item,
      pre_bruto        DECIMAL(17,6),
      val_desc         DECIMAL(15,2),   
      pct_desc         DECIMAL(5,2),  
      pre_unit         DEC(17,6),
      val_liq_item     LIKE wfat_item.val_liq_item,
      pct_icm          LIKE wfat_mestre.pct_icm,
      pct_ipi          LIKE wfat_item.pct_ipi,
      val_ipi          LIKE wfat_item.val_ipi,
      des_texto        CHAR(120),
      num_nff          LIKE wfat_mestre.num_nff
   END RECORD

   DEFINE p_duplic RECORD
      num_duplic1       LIKE wfat_duplic.num_duplicata,
      dig_duplic1       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd1    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic1       LIKE wfat_duplic.val_duplic,
      num_duplic2       LIKE wfat_duplic.num_duplicata,
      dig_duplic2       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd2    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic2       LIKE wfat_duplic.val_duplic,
      num_duplic3       LIKE wfat_duplic.num_duplicata,
      dig_duplic3       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd3    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic3       LIKE wfat_duplic.val_duplic,
      num_duplic4       LIKE wfat_duplic.num_duplicata,
      dig_duplic4       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd4    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic4       LIKE wfat_duplic.val_duplic,
      num_duplic5       LIKE wfat_duplic.num_duplicata,
      dig_duplic5       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd5    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic5       LIKE wfat_duplic.val_duplic,
      num_duplic6       LIKE wfat_duplic.num_duplicata,
      dig_duplic6       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd6    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic6       LIKE wfat_duplic.val_duplic,
      num_duplic7       LIKE wfat_duplic.num_duplicata,
      dig_duplic7       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd7    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic7       LIKE wfat_duplic.val_duplic,
      num_duplic8       LIKE wfat_duplic.num_duplicata,
      dig_duplic8       LIKE wfat_duplic.dig_duplicata,
      dat_vencto_sd8    LIKE wfat_duplic.dat_vencto_sd,
      val_duplic8       LIKE wfat_duplic.val_duplic,
      den_cnd_pgto      LIKE cond_pgto.den_cnd_pgto,
      val_desc_cred_icm LIKE wfat_mestre.val_desc_cred_icm,
      num_nf_orig       LIKE wfat_mestre.num_nff 
   END RECORD

   DEFINE p_for        SMALLINT,
          p_sal        SMALLINT,
          p_des_folha  CHAR(100)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   #      PAGE   LENGTH 32 

   ORDER EXTERNAL BY p_wnotacop.num_nff,
                     p_wnotacop.num_seq  

   FORMAT

      PAGE HEADER

         LET p_num_pagina = p_num_pagina + 1
         LET p_traco = "----------------------------------------",
                       "----------------------------------------",
                       "-----------------------------------"
             
                       
         PRINT log500_determina_cpp(132) CLIPPED;
         PRINT log500_condensado(true) CLIPPED;
         
         PRINT COLUMN 001, "P0L0717",
               COLUMN 041, "PEDIDO DE VENDA",
               COLUMN 058, "DATA: ", TODAY,
               COLUMN 082, "HORA: ", TIME,
               COLUMN 103, "PAG.: ", PAGENO USING "###&"
         PRINT COLUMN 001, "",
               COLUMN 097, "NUMERO: ",
               COLUMN 105, p_num_recibo
#              COLUMN 114, "PEDIDO FATURA TOTAL"
         PRINT COLUMN 001,  p_traco                         


         PRINT COLUMN 004, "NOME ....: ", p_nff.nom_destinatario
         PRINT COLUMN 004, "REFERENCIA : ",
               COLUMN 022, p_nff.num_nff USING "#####&",
               COLUMN 034, "ORIGEM: ", p_empresas_885.cod_emp_gerencial, 
               COLUMN 055, "DATA : ", p_nff.dat_emissao
#        PRINT COLUMN 004, "QUANTIDADE......: ", p_nff.qtd_volume,
#              COLUMN 030, "PESO BRUTO: ", p_nff.pes_tot_bruto,
#              COLUMN 065, "LIQ.: ", p_nff.pes_tot_liquido
         PRINT COLUMN 001,  p_traco 
                          
         PRINT COLUMN 001, "PRODUTO",              
               COLUMN 017, "DESCRICAO",               
               COLUMN 062, "UM",               
               COLUMN 067, "QUANTIDADE",                                       
#               COLUMN 086, "PR BRUTO",                                       
#               COLUMN 095, "VL.DESC",                                       
#               COLUMN 103, "%DESC",                                       
               COLUMN 083, "PRECO UNITARIO",                                       
               COLUMN 099, "PRECO LIQUIDO"                                       
         PRINT COLUMN 001, p_traco                          

      BEFORE GROUP OF p_wnotacop.num_nff
         SKIP TO TOP OF PAGE

      ON EVERY ROW

         CASE
            WHEN p_wnotacop.ies_tip_info = 1   
               PRINT COLUMN 001, p_wnotacop.cod_item,
                     COLUMN 017, p_wnotacop.den_item[1,45],
                     COLUMN 062, p_wnotacop.cod_unid_med,
                     COLUMN 070, p_wnotacop.qtd_item     USING "#######",
#                     COLUMN 084, p_wnotacop.pre_bruto    USING "#####.###&",
#                     COLUMN 095, p_wnotacop.val_desc     USING "###&.&&",
#                     COLUMN 103, p_wnotacop.pct_desc     USING "##&.&&",
                     COLUMN 081, p_wnotacop.pre_unit     USING "##,###,##&.&&&&&",
                     COLUMN 099, p_wnotacop.val_liq_item USING "##,###,##&.&&" 

#               PRINT COLUMN 001, p_traco       
								PRINT                        

        
            WHEN p_wnotacop.ies_tip_info = 2
               PRINT COLUMN 017, p_wnotacop.den_item[1,45] 
               PRINT COLUMN 001, p_traco                         
   
            WHEN p_wnotacop.ies_tip_info = 3
               PRINT                                  
               LET p_linhas_print = p_linhas_print + 1
                       
            WHEN p_wnotacop.ies_tip_info = 4
               WHILE TRUE
                  IF p_linhas_print < 11  THEN 
                     PRINT 
                     LET p_linhas_print = p_linhas_print + 1        
                  ELSE 
                     EXIT WHILE
                  END IF          
               END WHILE
         END CASE  

      AFTER GROUP OF p_wnotacop.num_nff

         NEED 15 LINES
         PRINT COLUMN 001, p_traco
         PRINT COLUMN 064, "VALOR MERCADORIAS E SERVICOS.: ", 
               COLUMN 095, GROUP SUM(p_wnotacop.val_liq_item)
                           USING "###,###,###,##&.&&"
         PRINT COLUMN 064, "ABATIMENTO...................: ",
               COLUMN 095, p_duplic.val_desc_cred_icm 
               USING "###,###,###,##&.&&" 
         PRINT COLUMN 064, "VALOR LIQUIDO DO PEDIDO......: ",
               COLUMN 095, GROUP SUM(p_wnotacop.val_liq_item) - 
               p_duplic.val_desc_cred_icm USING "###,###,###,##&.&&" 
         SKIP 1 LINE
   
#         PRINT COLUMN 003, "CONDICAO PAGAMENTO: ", p_wfat_mestre.cod_cnd_pgto,
#               " - ", p_duplic.den_cnd_pgto
         PRINT COLUMN 003, "CONDICAO PAGAMENTO: ", p_duplic.den_cnd_pgto

         SKIP 1 LINE
         PRINT COLUMN 003, "PARCELA",
               COLUMN 015, "VENCIMENTO",
               COLUMN 040, "VALOR",
               COLUMN 057, "PARCELA",
               COLUMN 069, "VENCIMENTO",
               COLUMN 094, "VALOR" 
         PRINT COLUMN 001, p_traco             
         PRINT COLUMN 006, p_duplic.dig_duplic1,
               COLUMN 015, p_duplic.dat_vencto_sd1 USING "dd/mm/yyyy",
               COLUMN 026, p_duplic.val_duplic1    USING "####,###,###,##&.&&",
               COLUMN 060, p_duplic.dig_duplic2,
               COLUMN 069, p_duplic.dat_vencto_sd2 USING "dd/mm/yyyy",
               COLUMN 080, p_duplic.val_duplic2    USING "####,###,###,##&.&&"
         PRINT COLUMN 006, p_duplic.dig_duplic3,
               COLUMN 015, p_duplic.dat_vencto_sd3 USING "dd/mm/yyyy",
               COLUMN 026, p_duplic.val_duplic3    USING "####,###,###,##&.&&",
               COLUMN 060, p_duplic.dig_duplic4,
               COLUMN 069, p_duplic.dat_vencto_sd4 USING "dd/mm/yyyy",
               COLUMN 080, p_duplic.val_duplic4    USING "####,###,###,##&.&&"
         PRINT COLUMN 006, p_duplic.dig_duplic5,
               COLUMN 015, p_duplic.dat_vencto_sd5 USING "dd/mm/yyyy",
               COLUMN 026, p_duplic.val_duplic5    USING "####,###,###,##&.&&",
               COLUMN 060, p_duplic.dig_duplic6,
               COLUMN 069, p_duplic.dat_vencto_sd6 USING "dd/mm/yyyy",
               COLUMN 080, p_duplic.val_duplic6    USING "####,###,###,##&.&&"
         PRINT COLUMN 006, p_duplic.dig_duplic7,
               COLUMN 015, p_duplic.dat_vencto_sd7 USING "dd/mm/yyyy",
               COLUMN 026, p_duplic.val_duplic7    USING "####,###,###,##&.&&",
               COLUMN 060, p_duplic.dig_duplic8,
               COLUMN 069, p_duplic.dat_vencto_sd8 USING "dd/mm/yyyy",
               COLUMN 080, p_duplic.val_duplic8    USING "####,###,###,##&.&&"

      NEED 12 LINES

      ON LAST ROW

      PRINT log500_condensado(false) CLIPPED;

END REPORT

#-----------------------#
 FUNCTION pol0717_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#

