#---------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: pol0942                                                         #
# MODULOS.: pol0942  - LOG0010 - LOG0040 - LOG0050 - LOG0060                #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                          #
# OBJETIVO: IMPRESSAO DAS N.F FATURA MULTIPLAS SERIES- SAIDA - ALBRAS       # 
# AUTOR...: Thiago              					                                  #
# DATA....: 21/07/2006                                                      #
# ALTERADO: 																			                          #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_agrupa                 SMALLINT,
          p_ant                    SMALLINT,
          p_num_lote               CHAR(37),                        
          p_ies_lote               CHAR(01),
          p_num_lot                CHAR(15),                        
          p_nom_arquivo            CHAR(100),
          p_msg                    CHAR(100),
          l_cla_fisc_nff           CHAR(01),
          p_caminho                CHAR(80),
          p_ies_impressao          CHAR(01),
          p_tipo_desc              CHAR(01),
          p_brancos                CHAR(01),
          p_num_nff_ini            LIKE fat_nf_mestre.nota_fiscal,       
          p_num_nff_fim            LIKE fat_nf_mestre.nota_fiscal,       
          comando                  CHAR(80),
          p_cod_fiscal_compl       DECIMAL(1,0),
          p_cod_fiscal_ind         LIKE fat_nf_item_fisc.cod_fiscal,
          p_num_nf_retorno         LIKE item_dev_terc.num_nf_retorno,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_desc_pes               LIKE desc_nat_oper.pct_desc_valor,
          p_ies_especie_nf         LIKE nf_sup.ies_especie_nf,
          p_cod_fornecedor         LIKE nf_sup.cod_fornecedor,
          p_dat_emis_nf            LIKE nf_sup.dat_emis_nf,       
          p_den_item_reduz         LIKE item.den_item_reduz, 
          p_qtd_item               LIKE fat_nf_item.qtd_item,
          p_pre_unit_nf            LIKE fat_nf_item.preco_unit_liquido,
          p_pct_icm_ant            LIKE fat_nf_item_fisc.aliquota,     
          p_base_icm_ant           LIKE fat_nf_item_fisc.aliquota,
          p_num_reserva            LIKE ordem_montag_grade.num_reserva,
          p_base_ipi_antf          LIKE fat_nf_item_fisc.val_trib_merc,
          p_val_icm_ant            LIKE fat_nf_item_fisc.val_trib_merc,
          p_val_ipi_antf           LIKE fat_nf_item_fisc.val_trib_merc,
          p_pre_unit               LIKE fat_nf_item.preco_unit_liquido,
          p_pre_tot_nf             LIKE fat_nf_mestre.val_nota_fiscal,
          p_val_tot_nf_d           LIKE fat_nf_mestre.val_nota_fiscal,
          p_unid_med               LIKE item.cod_unid_med,
          p_cod_cla_fisc           CHAR(10),
          p_letra                  CHAR(01),
          p_num_ped_ant            LIKE fat_nf_item.pedido,
          p_reimpressao						CHAR(01) 

   DEFINE p_num_seq                SMALLINT,
          p_qtd_lin_obs            SMALLINT

   DEFINE p_fat_nf_mestre      	 RECORD LIKE fat_nf_mestre.*,
   				p_fat_mestre_fiscal		 RECORD LIKE fat_mestre_fiscal.*,
          p_fat_nf_item       	 RECORD LIKE fat_nf_item.*,
          p_fat_nf_item_fisc  	 RECORD LIKE fat_nf_item_fisc.*,
          p_fat_nf_texto_hist  	 RECORD LIKE fat_nf_texto_hist.*,
          p_fat_conver_albras    RECORD LIKE fat_conver_albras.*,
          p_cidades              RECORD LIKE cidades.*,
          p_empresa              RECORD LIKE empresa.*,
          p_embalagem            RECORD LIKE embalagem.*,
          p_clientes             RECORD LIKE clientes.*,
          p_paises               RECORD LIKE paises.*,
          p_uni_feder            RECORD LIKE uni_feder.*,
          p_transport            RECORD LIKE clientes.*,
          p_ped_itens_texto      RECORD LIKE ped_itens_texto.*,
          p_ped_agrupa_albras    RECORD LIKE ped_agrupa_albras.*,
          p_fator_cv_unid        RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf        RECORD LIKE subst_trib_uf.*,
          p_nat_operacao         RECORD LIKE nat_operacao.*,
          p_desc_nat_oper        RECORD LIKE desc_nat_oper.*,
          p_cli_end_cobr         RECORD LIKE cli_end_cob.*, 
          p_serie_nf						 LIKE fat_nf_mestre.serie_nota_fiscal

   DEFINE p_nff       
          RECORD
             num_nff             LIKE fat_nf_mestre.nota_fiscal,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             cod_fiscal          LIKE fat_nf_item_fisc.cod_fiscal,
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         LIKE fat_nf_mestre.dat_hor_emissao,
             nom_destinatario    LIKE clientes.nom_cliente,
             num_cgc_cpf         LIKE clientes.num_cgc_cpf,
             dat_saida           LIKE fat_nf_mestre.dat_hor_emissao,
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

             num_duplic1         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic1         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd1      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic1         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic2         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic2         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd2      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic2         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic3         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic3         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd3      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic3         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic4         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic4         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd4      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic4         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic5         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic5         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd5      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic5         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic6         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic6         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd6      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic6         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic7         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic7         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd7      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic7         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic8         LIKE fat_nf_duplicata.docum_cre,
             dig_duplic8         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd8      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic8         LIKE fat_nf_duplicata.val_duplicata,

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
             val_seguro_cli      LIKE fat_nf_mestre.val_frete_cliente,
             val_tot_despesas    LIKE fat_nf_mestre.val_frete_cliente,
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
             qtd_volume          LIKE fat_nf_embalagem.qtd_volume,
             #qtd_volume1         LIKE fat_nf_mestre.qtd_volumes1,
            # qtd_volume2         LIKE fat_nf_mestre.qtd_volumes2,
             des_especie1        CHAR(030),
             des_especie2        CHAR(030),
             des_especie3        CHAR(030),
             den_marca           LIKE clientes.den_marca,
             num_pri_volume      LIKE fat_nf_mestre.num_prim_volume,
             num_ult_volume      LIKE fat_nf_mestre.num_prim_volume,
             pes_tot_bruto       LIKE fat_nf_mestre.peso_bruto,
             pes_tot_liquido     LIKE fat_nf_mestre.peso_liquido,
             cod_repres          LIKE pedidos.cod_repres,
             raz_social          LIKE representante.raz_social,
             den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
             num_pedido          LIKE fat_nf_item.pedido,
             num_suframa         LIKE clientes.num_suframa,
             num_om              LIKE fat_nf_item.ord_montag,
             num_pedido_repres   LIKE pedidos.num_pedido_repres,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             nat_oper            LIKE nat_operacao.cod_nat_oper
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE fat_nf_item.item,
             cod_item_cliente    LIKE fat_nf_item.item,
             num_pedido          LIKE fat_nf_item.pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,
             den_item1           CHAR(069),
             den_item2           CHAR(069),
             cod_cla_fisc        CHAR(010),              
             cod_origem          LIKE fat_nf_item_fisc.origem_produto,
             cod_tributacao      LIKE fat_nf_item_fisc.tributacao,
             cod_unid_med        LIKE fat_nf_item.unid_medida,
             qtd_item            LIKE fat_nf_item.qtd_item,
             pre_unit            LIKE fat_nf_item.preco_unit_liquido,
             val_liq_item        LIKE fat_nf_item.val_liquido_item,
             pct_icm             LIKE fat_nf_item_fisc.aliquota,
             pct_ipi             LIKE fat_nf_item_fisc.aliquota,
             val_ipi             LIKE fat_nf_item_fisc.val_trib_merc,
             val_icm_ret         LIKE fat_nf_item_fisc.val_trib_merc
          END RECORD

   DEFINE p_wnotalev       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          LIKE fat_nf_item.item,
             den_item          CHAR(060),
             cod_cla_fisc      CHAR(010),               
             cod_origem        LIKE fat_nf_item_fisc.origem_produto,
             cod_tributacao    LIKE fat_nf_item_fisc.tributacao,
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
             num_cgc             LIKE wfat_end_ent_ser.num_cgc,
             ins_estadual        LIKE wfat_end_ent_ser.ins_estadual,
             den_cidade          LIKE cidades.den_cidade,
             cod_uni_feder       LIKE cidades.cod_uni_feder
          END RECORD
 
   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_8lpp                     CHAR(02)
 
   DEFINE pa_texto_ped_it            ARRAY[23] 
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
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0942-10.02.07" 
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
      CALL pol0942_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0942_controle()
#-------------------------#
   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("pol0942") RETURNING comando    
   OPEN WINDOW w_pol0942 AT 5,3 WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         CALL pol0942_inicializa_campos()
         IF log005_seguranca(p_user,"VDP","pol0942","CO") THEN
            IF pol0942_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
         HELP 1053
         IF log005_seguranca(p_user,"VDP","pol0942","CO") THEN
            IF pol0942_imprime_nff() THEN
               IF  pol0942_verifica_param_exportacao() = TRUE THEN 
               END IF
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0942_sobre() 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0942
END FUNCTION

#-----------------------#
FUNCTION pol0942_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-----------------------------------#
FUNCTION pol0942_entrada_parametros()
#-----------------------------------#
	CALL log006_exibe_teclas("01 02 07", p_versao)
	CURRENT WINDOW IS w_pol0942
	
	LET p_reimpressao = "N"
	LET p_num_nff_ini   = 0
	LET p_num_nff_fim   = pol0942_retorna_max()
	LET p_serie_nf      = "  "
	
	INPUT p_reimpressao,
	p_serie_nf,
	p_num_nff_ini,
	p_num_nff_fim 
	WITHOUT DEFAULTS
	FROM reimpressao,
	serie_nf,
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
		
		AFTER FIELD serie_nf
			IF p_serie_nf IS NULL THEN
				ERROR 'Campo com preenchimento obrigatório'
				NEXT FIELD serie_nf
			ELSE
				IF NOT  pol0942_valida_serie() THEN
					ERROR "Nenhuma nota cadastrada com esta serie!" 
					NEXT FIELD serie_nf       		
				END IF 
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
		ON KEY (control-w)
		CASE
			WHEN infield(num_nff_ini)   CALL showhelp(3187)
			WHEN infield(num_nff_fim)   CALL showhelp(3188)
		END CASE
	END INPUT
	
	CALL log006_exibe_teclas("01", p_versao)
	CURRENT WINDOW IS w_pol0942
	
	IF int_flag THEN
		LET int_flag = 0
		CLEAR FORM
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION
#------------------------------#
FUNCTION pol0942_valida_serie()#
#------------------------------# 
DEFINE l_count 			SMALLINT

	SELECT COUNT (*)
	INTO l_count
	FROM vdp_num_docum
	WHERE empresa  = p_cod_empresa
	AND serie_docum    = p_serie_nf
	
	IF l_count > 0 THEN
		RETURN TRUE 
	ELSE
		RETURN FALSE 
	END IF 
END FUNCTION 
#-----------------------------#
FUNCTION pol0942_retorna_max()#
#-----------------------------# 
DEFINE l_max			LIKE wfat_mestre.num_nff
	SELECT MAX(nota_fiscal)
	INTO l_max
	FROM fat_nf_mestre
	WHERE empresa  = p_cod_empresa
	AND tip_nota_fiscal   = "FATPRDSV" 
	IF SQLCA.SQLCODE <> 0 THEN
		RETURN 99999
	ELSE
		RETURN l_max
	END IF 
END FUNCTION 

#----------------------------------#
FUNCTION pol0942_inicializa_campos()
#----------------------------------#
   INITIALIZE p_nff.*         , 
              pa_corpo_nff    , 
              p_end_entrega.* , 
              p_consignat.*   , 
              p_cidades.*     , 
              p_embalagem.*   , 
              p_clientes.*    , 
              p_paises.*      , 
              p_transport.*   , 
              p_uni_feder.*   , 
              p_ped_itens_texto.*,
              p_subst_trib_uf.*  ,
              p_fat_conver_albras.*,
              pa_texto_obs       ,
              pa_clas_fisc        TO NULL
 
   LET p_num_nff_ini        = 0
   LET p_num_nff_fim        = 999999

   LET p_ies_termina_relat  = TRUE

   LET p_linhas_print       = 0
   LET p_val_tot_ipi_acum   = 0

END FUNCTION

#------------------------------------------#
FUNCTION pol0942_verifica_param_exportacao()
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
    WHERE cod_cliente = p_fat_nf_mestre.cliente

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
FUNCTION pol0942_imprime_nff()
#----------------------------#
DEFINE p_cod_fiscal			LIKE fat_nf_item_fisc.cod_fiscal 
   
 IF log028_saida_relat(17,40) IS NOT NULL THEN 
    MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
    IF p_ies_impressao = "S" THEN 
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0942_relat TO PIPE p_nom_arquivo
       ELSE 
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0942.tmp' 
          START REPORT pol0942_relat TO p_caminho 
       END IF 
    ELSE
       START REPORT pol0942_relat TO p_nom_arquivo
    END IF
 END IF

   CALL pol0942_busca_dados_empresa()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_8lpp        = ascii 27, "0" 
   
   IF p_reimpressao = 'S' THEN
   	LET p_reimpressao = 'R'
   END IF 

   DECLARE cq_fat_nf_mestre CURSOR WITH HOLD FOR
   SELECT *
     FROM fat_nf_mestre
    WHERE empresa          = p_cod_empresa
      AND nota_fiscal     >= p_num_nff_ini
      AND nota_fiscal     <= p_num_nff_fim
      AND tip_nota_fiscal  = "FATPRDSV"  
      AND sit_impressao    = p_reimpressao
    ORDER BY nota_fiscal
       

   FOREACH cq_fat_nf_mestre INTO p_fat_nf_mestre.*

      DISPLAY p_fat_nf_mestre.nota_fiscal TO num_nff_proces {mostra nf em processam.}

      CALL pol0942_cria_temp_w_cla_fisc()

      CALL pol0942_cria_tabela_temporaria()

      IF p_fat_nf_mestre.origem_nota_fiscal = "P" THEN 
         #CALL pol0942_atualiza_ipi()      ivo         
         #CALL pol0942_atual_nfipi()       ivo    
      END IF  
 
      LET p_nff.num_nff            = p_fat_nf_mestre.nota_fiscal
      
      DECLARE cq_codf CURSOR FOR
          
      SELECT DISTINCT 
             cod_fiscal
         FROM fat_nf_item_fisc
        WHERE empresa           = p_cod_empresa
          AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal

      FOREACH cq_codf INTO p_cod_fiscal

         IF p_nff.cod_fiscal IS NULL THEN
            LET p_nff.cod_fiscal   = p_cod_fiscal
            LET p_nff.den_nat_oper = pol0942_den_nat_oper()
           # LET p_nff.cod_operacao = p_nat_operacao.cod_movto_estoq
            EXIT FOREACH
         END IF
      END FOREACH
      
      CALL pol0942_busca_dados_subst_trib_uf()
      LET p_nff.ins_estadual_trib  = p_subst_trib_uf.ins_estadual
      #LET p_nff.den_nat_oper       = pol0942_den_nat_oper()
      LET p_nff.nat_oper           = p_fat_nf_mestre.natureza_operacao
      LET p_nff.dat_emissao        = p_fat_nf_mestre.dat_hor_emissao

      CALL pol0942_busca_dados_clientes(p_fat_nf_mestre.cliente)
      LET p_nff.nom_destinatario   = p_clientes.nom_cliente
      LET p_nff.num_cgc_cpf        = p_clientes.num_cgc_cpf
      LET p_nff.end_destinatario   = p_clientes.end_cliente
      LET p_nff.den_bairro         = p_clientes.den_bairro
      LET p_nff.cod_cep            = p_clientes.cod_cep
      LET p_nff.cod_cliente        = p_clientes.cod_cliente

      CALL pol0942_busca_dados_cidades(p_clientes.cod_cidade)

      LET p_nff.den_cidade         = p_cidades.den_cidade          
      LET p_nff.num_telefone       = p_clientes.num_telefone
      LET p_nff.cod_uni_feder      = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual       = p_clientes.ins_estadual
      LET p_nff.hora_saida         = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0942_busca_dados_descont()
      
      CALL pol0942_busca_coef_compl()      

      CALL pol0942_busca_nome_pais()
      LET p_nff.den_pais           = p_paises.den_pais              

      CALL pol0942_busca_dados_duplicatas()

#     CALL log038_extenso(p_fat_nf_mestre.val_nota_fiscal,130,130,1,1)
#          RETURNING p_nff.val_extenso1, p_nff.val_extenso2,
#                    p_nff.val_extenso3, p_nff.val_extenso4
    
      CALL pol0942_carrega_end_cobranca()

      CALL pol0942_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0942_busca_dados_pedido()

      CALL pol0942_carrega_tabela_temporaria() {corpo todo da nota}

      CALL pol0942_grava_dados_historicos()  {le fat_nf_texto_hist}

     # IF p_fat_nf_mestre.ies_incid_icm <> 1 THEN 
     #    LET p_nff.val_tot_base_icm = 0 
     # ELSE
#        IF p_fat_nf_item_fisc.cod_fiscal = 513 THEN
         {IF p_fat_nf_item_fisc.cod_fiscal = 5124 THEN
					SELECT *
					INTO p_fat_mestre_fiscal.*
					FROM fat_mestre_fiscal
					WHERE tributo_benef ="ICMS"
					AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
					AND empresa =p_cod_empresa
         END IF }
    #  END IF 

      IF p_fat_nf_mestre.zona_franca = 'S' THEN
         CALL pol0942_le_icms('ICMS_ZF')
         #CALL pol0942_le_param_zf()
      ELSE
         CALL pol0942_le_icms('ICMS')
      END IF
 
      LET p_nff.val_tot_base_icm   = p_fat_mestre_fiscal.bc_trib_mercadoria 
      LET p_nff.val_tot_icm        = p_fat_mestre_fiscal.val_trib_merc
      LET p_nff.val_tot_base_ret   = p_fat_mestre_fiscal.bc_trib_mercadoria
      LET p_nff.val_tot_icm_ret    = p_fat_mestre_fiscal.val_trib_merc
      LET p_nff.val_tot_mercadoria = p_fat_nf_mestre.val_mercadoria
      LET p_nff.val_frete_cli      = p_fat_nf_mestre.val_frete_cliente
      LET p_nff.val_seguro_cli     = p_fat_nf_mestre.val_frete_cliente
      LET p_nff.val_tot_despesas   = 0
      LET p_nff.val_tot_nff        = p_fat_nf_mestre.val_nota_fiscal

      SELECT val_trib_merc
        INTO p_nff.val_tot_ipi
        FROM fat_mestre_fiscal
       WHERE empresa           = p_cod_empresa
         AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
         AND tributo_benef     = "IPI"         

#     IF p_fat_nf_item_fisc.cod_fiscal = 513 THEN
      IF p_fat_nf_item_fisc.cod_fiscal = 5124 THEN
           DECLARE cq_nf_retg  CURSOR WITH HOLD FOR
           SELECT num_nf,ser_nf,ssr_nf,
                  ies_especie_nf,
                  cod_fornecedor
             FROM item_dev_terc
            WHERE cod_empresa = p_cod_empresa
              AND num_nf_retorno = p_fat_nf_mestre.nota_fiscal
              AND ser_nff 		 	 = p_fat_nf_mestre.serie_nff

           FOREACH cq_nf_retg INTO p_num_nf,p_ser_nf,p_ssr_nf,
                                  p_ies_especie_nf,p_cod_fornecedor

            SELECT val_tot_nf_d   
              INTO p_val_tot_nf_d
              FROM nf_sup
             WHERE cod_empresa = p_cod_empresa 
               AND num_nf = p_num_nf 
               AND ser_nf = p_ser_nf 
               AND ssr_nf = p_ssr_nf 
               AND ies_especie_nf = p_ies_especie_nf
               AND cod_fornecedor = p_cod_fornecedor 
  
            EXIT FOREACH

           END FOREACH 
           IF p_val_tot_nf_d IS NULL THEN
              LET p_val_tot_nf_d = 0
           END IF
  
           LET p_nff.val_tot_nff = p_fat_nf_mestre.val_nota_fiscal - p_val_tot_nf_d
      END IF  

      CALL pol0942_busca_dados_transport(p_fat_nf_mestre.transportadora)
      CALL pol0942_busca_dados_cidades(p_transport.cod_cidade)
      LET p_nff.nom_transpor       = p_transport.nom_cliente  
      IF p_fat_nf_mestre.tip_frete = 3 THEN 
         LET p_nff.ies_frete = 2
      ELSE 
         LET p_nff.ies_frete = 1
      END IF
      LET p_nff.num_placa          = p_fat_nf_mestre.placa_veiculo
      LET p_nff.num_cgc_trans      = p_transport.num_cgc_cpf
      LET p_nff.end_transpor       = p_transport.end_cliente
      LET p_nff.den_cidade_trans   = p_cidades.den_cidade
      LET p_nff.cod_uni_feder_trans= p_cidades.cod_uni_feder
      LET p_nff.ins_estadual_trans = p_transport.ins_estadual
      #LET p_nff.qtd_volume1        = p_fat_nf_mestre.qtd_volumes1 
     # LET p_nff.qtd_volume2        = p_fat_nf_mestre.qtd_volumes2 
     
     	SELECT sum(qtd_volume) 
     	INTO p_nff.qtd_volume
     	FROM fat_nf_embalagem
			WHERE empresa =p_cod_empresa
			AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
     
      {LET p_nff.qtd_volume         = p_fat_nf_mestre.qtd_volumes1 +
                                     p_fat_nf_mestre.qtd_volumes2 +
                                     p_fat_nf_mestre.qtd_volumes3 +
                                     p_fat_nf_mestre.qtd_volumes4 +
                                     p_fat_nf_mestre.qtd_volumes5}
      LET p_nff.den_marca          = "      "              
#     LET p_nff.den_marca          = p_fat_nf_mestre.cond_pagto
      LET p_nff.num_pri_volume     = p_fat_nf_mestre.num_prim_volume
      LET p_nff.num_ult_volume     = p_fat_nf_mestre.num_prim_volume +
                                     p_nff.qtd_volume - 1
 
# solicitado SR. Mario em 20/11/00
     
      IF p_tipo_desc = "Q"  THEN     
        LET p_desc_pes = 100 - p_desc_nat_oper.pct_desc_qtd
        LET p_fat_nf_mestre.peso_bruto = p_fat_nf_mestre.peso_bruto / (p_desc_pes/100)
        LET p_fat_nf_mestre.peso_liquido = p_fat_nf_mestre.peso_liquido / (p_desc_pes/100)
      END IF        

      LET p_nff.pes_tot_bruto      = p_fat_nf_mestre.peso_bruto
      LET p_nff.pes_tot_liquido    = p_fat_nf_mestre.peso_liquido

      LET p_nff.num_pedido   = p_fat_nf_item.pedido
      
      CALL pol0942_representante() RETURNING p_nff.raz_social,p_nff.cod_repres
     # LET p_nff.cod_repres   = p_fat_nf_mestre.cod_repres
     # LET p_nff.raz_social   = pol0942_representante()
      LET p_nff.num_suframa  = p_clientes.num_suframa
      LET p_nff.num_om       = p_fat_nf_item.ord_montag
      
      CALL pol0942_especie() RETURNING p_nff.des_especie1,p_nff.des_especie2,p_nff.des_especie3
      
      #LET p_nff.des_especie1 = pol0942_especie(1)
      #LET p_nff.des_especie2 = pol0942_especie(2)
      #LET p_nff.des_especie3 = pol0942_especie(3)
      LET p_nff.den_cnd_pgto = pol0942_den_cnd_pgto()

      LET p_ies_lista = TRUE

      CALL pol0942_grava_dados_end_entrega()

      CALL pol0942_grava_dados_consig()

      CALL pol0942_calcula_total_de_paginas()

      CALL pol0942_monta_relat()

      #### marca nf que ja foi impressa ####
      UPDATE fat_nf_mestre 
         SET sit_impressao = "R"
       WHERE empresa = p_cod_empresa
         AND trans_nota_fiscal     = p_fat_nf_mestre.trans_nota_fiscal

      CALL pol0942_inicializa_campos()

   END FOREACH

   FINISH REPORT pol0942_relat

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
      ERROR " Nao existem dados para serem listados. "
   END IF

   RETURN TRUE
END FUNCTION


#------------------------------------#
FUNCTION pol0942_le_icms(p_cod_nenef)
#------------------------------------#

   DEFINE p_cod_nenef CHAR(10)

   SELECT *
     INTO p_fat_mestre_fiscal.*
     FROM fat_mestre_fiscal
    WHERE empresa           = p_cod_empresa
      AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
      AND tributo_benef     = p_cod_nenef
         
END FUNCTION


#---------------------------------------#
FUNCTION pol0942_cria_tabela_temporaria()
#---------------------------------------#

   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN") 

   DROP TABLE wnotalev;

   CREATE TABLE wnotalev
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(015),
      den_item           CHAR(080),
      cod_cla_fisc       CHAR(010),
      cod_origem         CHAR(1),
      cod_tributacao     CHAR(2),
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
   
   DROP TABLE clas_fisc_temp;
   CREATE TABLE clas_fisc_temp
    (    
      cod_cla_fisc       CHAR(10),
      letra              CHAR(01)
     );
     
   CREATE UNIQUE INDEX clas_fisc_temp_1 ON clas_fisc_temp(cod_cla_fisc);

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF

   CALL log085_transacao("COMMIT")
   
{   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")
#  BEGIN WORK

   LOCK TABLE wnotalev  IN EXCLUSIVE MODE

   CALL log085_transacao("COMMIT")
#  COMMIT WORK

   DROP TABLE wnotalev;

   IF sqlca.sqlcode <> 0 THEN 
      DELETE FROM wnotalev;
   END IF

   CREATE TEMP TABLE wnotalev
     (
      num_seq            SMALLINT,
      ies_tip_info       SMALLINT,
      cod_item           CHAR(015),
      den_item           CHAR(060),
      cod_cla_fisc       CHAR(001),
      cod_origem         CHAR(1),
      cod_tributacao     CHAR(2),
      cod_unid_med       CHAR(3),
      qtd_item           DECIMAL(12,3),
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
   END IF}

   WHENEVER ERROR STOP
 
END FUNCTION

#---------------------------------------#
FUNCTION pol0942_cria_temp_w_cla_fisc()
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

#-----------------------------#
FUNCTION pol0942_atualiza_ipi()          
#-----------------------------# 

  DEFINE p_num_agrup    LIKE ped_agrupa_albras.num_agrup,
         p_num_agr_ant  LIKE ped_agrupa_albras.num_agrup, 
         p_cod_it_ant   LIKE fat_nf_item.item,              
         p_num_seq_ant  LIKE fat_nf_item.seq_item_pedido,
         p_ipi_ant      LIKE fat_nf_item_fisc.aliquota           

   WHENEVER ERROR STOP

   LET p_num_agrup = 0 

   DECLARE cq_fat_nf_item_ip CURSOR FOR
   	SELECT fat_nf_item.*
		FROM fat_nf_item
		WHERE fat_nf_item.empresa = p_cod_empresa
		AND fat_nf_item.trans_nota_fiscal =p_fat_nf_mestre.trans_nota_fiscal
		AND fat_nf_item.pedido  > 0
		ORDER BY fat_nf_item.seq_item_nf

   FOREACH cq_fat_nf_item_ip INTO p_fat_nf_item.*

    IF p_num_agrup = 0 THEN 
      SELECT num_agrup 
        INTO p_num_agrup 
        FROM ped_agrupa_albras 
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_fat_nf_item.pedido      
         AND cod_item      = p_fat_nf_item.item 
         AND num_sequencia = p_fat_nf_item.seq_item_nf
         
      SELECT bc_trib_mercadoria,val_trib_merc,aliquota						#icms do item para agrupar
			INTO p_pct_icm_ant,p_base_icm_ant,p_val_icm_ant
			FROM fat_nf_item_fisc
			WHERE fat_nf_item_fisc.empresa = p_cod_empresa
			AND  fat_nf_item_fisc.trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
			AND fat_nf_item_fisc.SEQ_ITEM_NF = p_fat_nf_item.seq_item_nf
			AND tributo_benef = "ICMS"
			IF p_pct_icm_ant IS NULL THEN
				LET p_pct_icm_ant = 0
			END IF
			
			IF p_base_icm_ant IS NULL THEN
				LET p_base_icm_ant = 0
			END IF
			
			IF p_val_icm_ant IS NULL THEN
				LET p_val_icm_ant = 0
			END IF 
			
      {LET p_pct_icm_ant   = p_fat_nf_item_fisc.val_trib_merc  
      LET p_base_icm_ant  = p_fat_nf_item_fisc.bc_trib_mercadoria  
      LET p_val_icm_ant   = p_fat_nf_item_fisc.aliquota}  
      
      SELECT bc_trib_mercadoria,val_trib_merc,aliquota						#ipi do item para agruapar
      INTO p_val_ipi_antf,p_base_ipi_antf,p_ipi_ant
			FROM fat_nf_item_fisc
			WHERE fat_nf_item_fisc.empresa = p_cod_empresa
			AND  fat_nf_item_fisc.trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
			AND fat_nf_item_fisc.SEQ_ITEM_NF = p_fat_nf_item.seq_item_nf
			AND tributo_benef = "IPI"
			
			IF p_val_ipi_antf IS NULL THEN
				LET p_val_ipi_antf = 0
			END IF
			
			IF p_base_ipi_antf IS NULL THEN
				LET p_base_ipi_antf = 0
			END IF
			
			IF p_ipi_ant IS NULL THEN
				LET p_ipi_ant = 0
			END IF
      
      {LET p_val_ipi_antf  = p_fat_nf_item_fisc.val_trib_merc   
      LET p_base_ipi_antf = p_fat_nf_item_fisc.bc_trib_mercadoria
      LET p_ipi_ant       = p_fat_nf_item_fisc.aliquota }
      
      LET p_num_agr_ant   = p_num_agrup 
      LET p_num_seq_ant   = fat_nf_item.seq_item_nf
      #---alterado Toni/Ana 12/06/08
      LET p_num_ped_ant   = p_fat_nf_item.pedido 
      #---
      LET p_cod_it_ant    = p_fat_nf_item.item    
      
    ELSE 
      SELECT num_agrup 
        INTO p_num_agrup 
        FROM ped_agrupa_albras 
       WHERE cod_empresa = p_cod_empresa
         AND num_pedido  = p_fat_nf_item.pedido      
         AND cod_item    = p_fat_nf_item.item 
         AND num_sequencia = fat_nf_item.seq_item_nf
         

      IF p_num_agrup = p_num_agr_ant AND
         #---alterado Toni/Ana 12/06/08
         p_num_ped_ant = p_fat_nf_item.pedido THEN      
         
         LET p_fat_nf_item_fisc.val_trib_merc   = p_fat_nf_item.val_liquido_item * p_ipi_ant/100

        { UPDATE fat_nf_item  SET val_ipi  = 0, 
                               pct_ipi  = p_ipi_ant,
                               val_liq_item = 0,  
                               nom_usuario = "agrupa"  
          WHERE fat_nf_item.cod_empresa   = p_cod_empresa 
            AND fat_nf_item.num_nff       = p_fat_nf_item.num_nff 
            AND fat_nf_item.item      = p_fat_nf_item.item 
            AND fat_nf_item.num_sequencia = fat_nf_item.seq_item_nf
            
 
         UPDATE fat_nf_item  SET val_ipi  = val_ipi + p_fat_nf_item_fisc.val_trib_merc,
                       val_liq_item = val_liq_item + p_fat_nf_item.val_liquido_item,
                       pre_unit_nf  = pre_unit_nf  + p_fat_nf_item.preco_unit_liquido,
                       pre_unit_ped = pre_unit_ped + p_fat_nf_item.pre_unit_ped  
          WHERE fat_nf_item.cod_empresa   = p_cod_empresa 
            AND fat_nf_item.num_nff       = p_fat_nf_item.num_nff 
            AND fat_nf_item.item      = p_cod_it_ant    
          AND fat_nf_item.num_sequencia = p_num_seq_ant   }

         UPDATE fat_nf_item_fisc  
         SET val_trib_merc      = 0 , 
          	 bc_trib_mercadoria = 0
          WHERE empresa = p_cod_empresa
          	AND fat_nf_item_fisc.trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal 
          	AND fat_nf_item_fisc.seq_item_nf = p_fat_nf_item.seq_item_nf
          	AND tributo_benef ="IPI"
 
         UPDATE fat_nf_item_fisc  SET
                val_trib_merc      = val_trib_merc + p_fat_nf_item_fisc.val_trib_merc,
                bc_trib_mercadoria = bc_trib_mercadoria + p_fat_nf_item_fisc.bc_trib_mercadoria
          WHERE empresa = p_cod_empresa
          	AND fat_nf_item_fisc.trans_nota_fiscal       = p_fat_nf_item.trans_nota_fiscal 
          	AND fat_nf_item_fisc.seq_item_nf = p_num_seq_ant
          	AND tributo_benef ="IPI"
           

         {UPDATE nf_item SET val_ipi  = 0, 
                            pct_ipi  = p_ipi_ant,
                            val_liq_item = 0  
          WHERE cod_empresa   = p_cod_empresa 
            AND num_nff       = p_fat_nf_item.num_nff 
            AND cod_item      = p_fat_nf_item.item 
            AND num_sequencia = fat_nf_item.seq_item_nf
 
         UPDATE nf_item  SET val_ipi  = val_ipi + p_fat_nf_item_fisc.val_trib_merc, 
                       val_liq_item = val_liq_item + p_fat_nf_item.val_liquido_item,
                       pre_unit_nf  = pre_unit_nf  + p_fat_nf_item.preco_unit_liquido,
                       pre_unit_ped = pre_unit_ped + p_fat_nf_item.pre_unit_ped  
          WHERE cod_empresa   = p_cod_empresa 
            AND num_nff       = p_fat_nf_item.num_nff 
            AND cod_item      = p_cod_it_ant  
            AND num_sequencia = p_num_seq_ant  } 

      {   UPDATE nf_item_fiscal_ser  SET val_ipi  = 0, 
                                    val_base_ipi = 0,  
                                    val_base_icm = 0,  
                                    val_icm = 0   
          WHERE nf_item_fiscal_ser.cod_empresa   = p_cod_empresa 
            AND nf_item_fiscal_ser.num_nff       = p_fat_nf_item.num_nff 
            AND nf_item_fiscal_ser.num_pedido    = p_fat_nf_item.pedido
            AND nf_item_fiscal_ser.num_sequencia = fat_nf_item.seq_item_nf
 
         UPDATE nf_item_fiscal_ser  SET
                val_ipi  = val_ipi + p_fat_nf_item_fisc.val_ipi,
                val_base_ipi = val_base_ipi + p_fat_nf_item_fisc.val_base_ipi,
                val_base_icm = val_base_icm + p_fat_nf_item_fisc.val_base_icm,
                val_icm = val_icm + p_fat_nf_item_fisc.val_icm
          WHERE nf_item_fiscal_ser.cod_empresa   = p_cod_empresa 
            AND nf_item_fiscal_ser.num_nff       = p_fat_nf_item.num_nff 
            AND nf_item_fiscal_ser.num_pedido    = p_fat_nf_item.pedido
          AND nf_item_fiscal_ser.num_sequencia = p_num_seq_ant   }
      ELSE
      	 SELECT fat_nf_item_fisc.aliquota 
      	 INTO p_fat_nf_item_fisc.aliquota
      	 FROM fat_nf_item_fisc
      	 WHERE empresa = p_cod_empresa
      	 		AND fat_nf_item_fisc.trans_nota_fiscal       = p_fat_nf_item.trans_nota_fiscal 
          	AND fat_nf_item_fisc.seq_item_nf = fat_nf_item.seq_item_nf
          	AND tributo_benef ="IPI"
        
        IF SQLCA.SQLCODE <> 0 THEN
         		LET p_fat_nf_item_fisc.aliquota = 0
         END IF 
      	 
         LET p_ipi_ant     =  p_fat_nf_item_fisc.aliquota  
         LET p_num_agr_ant =  p_num_agrup 
         LET p_num_seq_ant =  fat_nf_item.seq_item_nf
         #--- alterado Toni/Ana 12/06/08
         LET p_num_ped_ant   = p_fat_nf_item.pedido 
         #---         
         LET p_cod_it_ant  =  p_fat_nf_item.item      
      END IF 
    END IF 
   END FOREACH       
END FUNCTION 

#-----------------------------#
FUNCTION pol0942_atual_nfipi()          
#-----------------------------# 
  DEFINE p_val_ipi      LIKE fat_mestre_fiscal.val_tributo_tot,
         p_val_dif_ipi  LIKE fat_mestre_fiscal.val_tributo_tot,
         p_cont_dpl     SMALLINT 	
     
   WHENEVER ERROR STOP 
   
   	SELECT sum(val_trib_merc)
   	INTO p_val_ipi 
		FROM fat_nf_item_fisc
		WHERE fat_nf_item_fisc.empresa = p_cod_empresa
		AND fat_nf_item_fisc.trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
		AND tributo_benef ="IPI"
   

    LET p_val_dif_ipi = p_fat_mestre_fiscal.val_tributo_tot - p_val_ipi 

    UPDATE fat_nf_mestre 
       SET val_trib_merc = p_val_ipi,
           val_tot_nff = val_tot_nff - p_val_dif_ipi  
    	WHERE fat_mestre_fiscal.empresa = p_cod_empresa
			AND fat_mestre_fiscal.trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal
			AND tributo_benef ="IPI"

   { UPDATE nf_mestre_ser 
       SET val_tot_ipi = p_val_ipi,
           val_tot_nff = val_tot_nff - p_val_dif_ipi  
     WHERE cod_empresa = p_cod_empresa 
       AND num_nff = p_fat_nf_mestre.nota_fiscal
       AND ser_nff =  p_fat_nf_mestre.serie_nota_fiscal}

    LET p_fat_mestre_fiscal.val_tributo_tot = p_fat_mestre_fiscal.val_tributo_tot - p_val_dif_ipi
    LET p_fat_nf_mestre.val_nota_fiscal = p_fat_nf_mestre.val_nota_fiscal - p_val_dif_ipi

    SELECT count(*) 
      INTO p_cont_dpl
      FROM fat_nf_duplicata
     WHERE cod_empresa = p_cod_empresa 
       AND num_nff = p_fat_nf_mestre.nota_fiscal
       AND fat_nf_duplicata.serie_nota_fiscal = p_fat_nf_mestre.serie_nota_fiscal

    IF p_cont_dpl > 0 THEN 
       UPDATE fat_nf_duplicata 
          SET val_duplic = val_duplic - p_val_dif_ipi 
        WHERE cod_empresa = p_cod_empresa 
          AND num_nff = p_fat_nf_mestre.nota_fiscal 
          AND fat_nf_duplicata.serie_nota_fiscal = p_fat_nf_mestre.serie_nota_fiscal
          AND dig_duplicata = 1

       UPDATE nf_duplicata_ser 
          SET val_duplic = val_duplic - p_val_dif_ipi 
        WHERE cod_empresa = p_cod_empresa 
          AND num_nff = p_fat_nf_mestre.nota_fiscal
          AND ser_nff =  p_fat_nf_mestre.serie_nota_fiscal
          AND dig_duplicata = 1
    END IF

END FUNCTION  

#----------------------------#
FUNCTION pol0942_monta_relat()
#----------------------------#

   #LET p_indice     = 0
   #LET p_letra      = 'KLMNOP'
   #LET p_num_pagina = 0

   DECLARE cq_ind_cla CURSOR FOR
    SELECT UNIQUE cod_cla_fisc
      FROM wnotalev
     WHERE ies_tip_info = 1
     ORDER BY 1
     
   FOREACH cq_ind_cla INTO p_cod_cla_fisc
   
      #INITIALIZE p_cod_cla_reduz, p_pre_impresso TO NULL
      INITIALIZE p_letra TO NULL
      
       CALL pol0942_pega_classif()
       #--LET pa_corpo_nff[p_ind].cod_cla_fisc = l_cla_fisc_nff  
      
      INSERT INTO clas_fisc_temp
         VALUES (p_cod_cla_fisc,p_letra)
      
      #DECLARE cq_clas CURSOR FOR
      # SELECT classif_fisc_reduz,
      #        pre_imp
      #   FROM obf_comp_cl_fisc
      #  WHERE classif_fisc = p_cod_cla_fisc
      # 
      #FOREACH cq_clas INTO 
      #        p_cod_cla_reduz,
      #        p_pre_impresso
      #        
      #   EXIT FOREACH
      #END FOREACH
      
      #IF p_cod_cla_reduz IS NULL THEN
      #   LET p_indice = p_indice + 1
      #   LET p_cod_cla_reduz = p_letra[p_indice]
      #   LET p_pre_impresso = 'N'
      #END IF
      
      #INSERT INTO clas_fisc_temp
      #   VALUES (p_cod_cla_fisc,p_cod_cla_reduz, p_pre_impresso)
         
      #IF p_indice >= 9 THEN
      #   EXIT FOREACH
      #END IF
         
   END FOREACH

   DECLARE cq_wnotalev CURSOR FOR
    SELECT *
      FROM wnotalev
     ORDER BY 1

   FOREACH cq_wnotalev INTO p_wnotalev.*
   		

   
      LET p_wnotalev.num_nff = p_fat_nf_mestre.nota_fiscal
      
      SELECT letra
        INTO p_letra
        FROM clas_fisc_temp
       WHERE cod_cla_fisc = p_wnotalev.cod_cla_fisc
       
       IF STATUS <> 0 THEN
          INITIALIZE p_letra TO NULL
       END IF
       
      OUTPUT TO REPORT pol0942_relat(p_wnotalev.*)
      
  END FOREACH

  { imprimir as linhas que faltam para completar o corpo da nota}
  { somente se o numero de linhas da nota nao for multiplo de 8 }
  IF p_ies_termina_relat = TRUE THEN
     LET p_wnotalev.num_nff      = p_fat_nf_mestre.nota_fiscal
     LET p_wnotalev.num_seq      = p_wnotalev.num_seq + 1
     LET p_wnotalev.ies_tip_info = 4
   
     OUTPUT TO REPORT pol0942_relat(p_wnotalev.*)
  END IF
END FUNCTION

#------------------------------------#
FUNCTION pol0942_busca_dados_descont()   
#------------------------------------#

   LET p_tipo_desc = "N"
   SELECT *            
     INTO p_desc_nat_oper.*    
     FROM desc_nat_oper
    WHERE cod_cliente = p_fat_nf_mestre.cliente              
      AND cod_nat_oper = p_fat_nf_mestre.natureza_operacao

    IF sqlca.sqlcode = 0 THEN 
       IF p_desc_nat_oper.pct_desc_valor > 0 THEN 
          LET p_tipo_desc = "V"
       ELSE 
      	 LET p_tipo_desc = "Q"
       END IF
    ELSE 
       LET p_tipo_desc = "N"
    END IF
END FUNCTION


#---------------------------------------#
FUNCTION pol0942_busca_dados_duplicatas()
#---------------------------------------#
   DEFINE p_fat_nf_duplicata       RECORD LIKE fat_nf_duplicata.*,
          p_contador          SMALLINT

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT * 
     FROM fat_nf_duplicata
    WHERE empresa 							= p_cod_empresa
      AND trans_nota_fiscal     = p_fat_nf_mestre.trans_nota_fiscal
    ORDER BY empresa,
             seq_duplicata,
             dat_vencto_sdesc

   FOREACH cq_duplic INTO p_fat_nf_duplicata.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1  
            LET p_nff.num_duplic1    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic1    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd1 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic1    = p_fat_nf_duplicata.val_duplicata
         WHEN 2      
            LET p_nff.num_duplic2    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic2    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd2 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic2    = p_fat_nf_duplicata.val_duplicata
         WHEN 3      
            LET p_nff.num_duplic3    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic3    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd3 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic3    = p_fat_nf_duplicata.val_duplicata
         WHEN 4
            LET p_nff.num_duplic4    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic4    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd4 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic4    = p_fat_nf_duplicata.val_duplicata
         WHEN 5
            LET p_nff.num_duplic5    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic5    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd5 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic5    = p_fat_nf_duplicata.val_duplicata
         WHEN 6
            LET p_nff.num_duplic6    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic6    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd6 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic6    = p_fat_nf_duplicata.val_duplicata
         WHEN 7
            LET p_nff.num_duplic7    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic7    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd7 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic7    = p_fat_nf_duplicata.val_duplicata
         WHEN 8
            LET p_nff.num_duplic8    = p_fat_nf_duplicata.docum_cre
            LET p_nff.dig_duplic8    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd8 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic8    = p_fat_nf_duplicata.val_duplicata
         OTHERWISE   
            EXIT FOREACH
      END CASE
   END FOREACH
END FUNCTION


#-------------------------------------#
FUNCTION pol0942_carrega_end_cobranca()
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
{-----------FUNÇAO RESPONSAVEL POR DEMONSTRAR ITEM-------THIAGO--27/02/2009}
#----------------------------------#
FUNCTION pol0942_den_item_cliente()#
#----------------------------------#
DEFINE l_den_item            LIKE item.den_item

	SELECT i.den_item
	INTO l_den_item
	FROM item i , cliente_item c
	WHERE i.cod_empresa =p_cod_empresa
	AND c.cod_empresa = i.cod_empresa
	AND i.cod_Item = c.cod_item_cliente
	AND c.cod_item = p_fat_nf_item.item
	AND cod_cliente_matriz = p_fat_nf_mestre.cliente
	
	IF SQLCA.SQLCODE <> 0 THEN 
		SELECT UNIQUE des_item
		INTO l_den_item
		FROM fat_nf_item
		WHERE item            = p_fat_nf_item.item
		AND seq_item_nf       = p_fat_nf_item.seq_item_nf
		AND trans_nota_fiscal = p_fat_nf_item.trans_nota_fiscal
		AND empresa           = p_cod_empresa	
	END IF 										
	
	RETURN l_den_item[1,60]
	
END FUNCTION
{
#--------------------------#
FUNCTION pol0942_den_item()#
#--------------------------#
DEFINE l_den_item            LIKE item.den_item
	SELECT DES_ITEM 
	INTO l_den_item
	FROM NF_ITEM_ESP_SER
	WHERE COD_EMPRESA =p_cod_empresa
	AND NUM_NFF=p_fat_nf_item.tr
	AND NUM_SEQUENCIA=fat_nf_item.seq_item_nf
	
	IF SQLCA.SQLCODE <> 0 THEN 
		RETURN p_fat_nf_item.des_item
	ELSE
		RETURN l_den_item
	END IF 
END FUNCTION 
}
#----------------------------------#
FUNCTION pol0942_carrega_corpo_nff()
#----------------------------------#
   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT,
          p_count2              SMALLINT,
          sql_stmt             CHAR(2000)
          

   LET p_ind = 1
   LET p_count = 0 

   INITIALIZE pa_corpo_nff TO NULL
   
   DECLARE cq_wfat_item_rt CURSOR FOR
    SELECT * 
      FROM fat_nf_item
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal  = p_fat_nf_mestre.trans_nota_fiscal
       AND (natureza_operacao = p_fat_nf_mestre.natureza_operacao
        OR pedido            > 0)

    FOREACH cq_wfat_item_rt INTO p_fat_nf_item.*

       IF STATUS <> 0 THEN
          CALL log003_err_sql('Lendo','cq_wfat_item_rt')
          RETURN
       END IF
       
       SELECT * 
         INTO p_fat_conver_albras.*
         FROM fat_conver_albras
        WHERE cod_empresa = p_cod_empresa 
          AND cod_cliente = p_fat_nf_mestre.cliente
          AND cod_item    = p_fat_nf_item.item

       IF SQLCA.sqlcode = 0 THEN
          LET p_fat_nf_item.preco_unit_liquido  =  p_fat_nf_item.preco_unit_liquido * p_fat_conver_albras.fat_conver 
          LET p_fat_nf_item.qtd_item     = p_fat_nf_item.qtd_item / p_fat_conver_albras.fat_conver
          LET p_fat_nf_item.unid_medida = p_fat_conver_albras.cod_unid_med
       END IF

       CALL pol0942_item_cliente()
       LET pa_corpo_nff[p_ind].cod_item         = p_fat_nf_item.item
       LET pa_corpo_nff[p_ind].cod_item_cliente = g_cod_item_cliente
       LET pa_corpo_nff[p_ind].num_pedido       = p_fat_nf_item.pedido 

       IF g_cod_item_cliente IS NULL THEN
       		LET p_fat_nf_item.des_item				=	 pol0942_den_item_cliente()
          LET pa_corpo_nff[p_ind].den_item1   = p_fat_nf_item.des_item[01,60]
          LET pa_corpo_nff[p_ind].den_item2   = p_fat_nf_item.des_item[61,76]
       ELSE
          LET pa_corpo_nff[p_ind].den_item1   = pol0942_den_item_cliente() {<--------alterar------------}
          LET pa_corpo_nff[p_ind].den_item2   = "cod. do cliente  ",g_cod_item_cliente
       END IF

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

      IF p_num_lote IS NOT NULL THEN
         LET pa_corpo_nff[p_ind].den_item2 = 
             pa_corpo_nff[p_ind].den_item2 CLIPPED," LT:", p_num_lote
      END IF

       CALL pol0942_busca_dados_pedido()
       LET pa_corpo_nff[p_ind].num_pedido_cli = p_nff.num_pedido_cli
       LET pa_corpo_nff[p_ind].cod_unid_med   = p_fat_nf_item.unid_medida  
       LET pa_corpo_nff[p_ind].qtd_item       = p_fat_nf_item.qtd_item

      LET pa_corpo_nff[p_ind].pre_unit = p_fat_nf_item.preco_unit_liquido
      LET pa_corpo_nff[p_ind].val_liq_item = p_fat_nf_item.val_liquido_item
      LET pa_corpo_nff[p_ind].cod_cla_fisc = p_fat_nf_item.classif_fisc


      SELECT UNIQUE aliquota,
                    origem_produto,
                    tributacao 
        INTO pa_corpo_nff[p_ind].pct_icm,
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

      LET pa_corpo_nff[p_ind].val_icm_ret = p_fat_nf_item_fisc.val_trib_merc
      LET p_val_tot_ipi_acum              = p_val_tot_ipi_acum + 
                                            p_fat_nf_item_fisc.val_trib_merc

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1

   END FOREACH

END FUNCTION

#-----------------------------#
FUNCTION pol0942_item_cliente()
#-----------------------------#
   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
     INTO g_cod_item_cliente    
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = p_fat_nf_mestre.cliente
      AND cod_item           = p_fat_nf_item.item

END FUNCTION

#------------------------------------------------------#
FUNCTION pol0942_carrega_classificacoes(l_cod_cla_fisc)
#------------------------------------------------------#
 DEFINE l_cod_cla_fisc   LIKE fat_nf_item.classif_fisc,
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

#--------------------------------#
FUNCTION pol0942_pega_classif()
#--------------------------------#
	CASE
		WHEN p_cod_cla_fisc		= "73182100"
			LET p_letra 	="A"
		WHEN p_cod_cla_fisc		= "73181500"
			LET p_letra 	="B"
		WHEN p_cod_cla_fisc		= "83021000"
			LET p_letra 	="C"
		WHEN p_cod_cla_fisc		= "83013000" 
			LET p_letra 	="D"
		WHEN p_cod_cla_fisc		= "79070090"
			LET p_letra 	="E"
		WHEN p_cod_cla_fisc		= "39263000"
			LET p_letra 	="F"
		WHEN p_cod_cla_fisc		= "83024200"
			LET p_letra 	="G" 	
		WHEN p_cod_cla_fisc		= "72042900"
			LET p_letra 	="H"
		WHEN p_cod_cla_fisc		= "74022100"
			LET p_letra 	="I"
		WHEN p_cod_cla_fisc		= "48119090"
			LET p_letra 	="J" 
		WHEN p_cod_cla_fisc		= '94032000'
			LET p_letra 	= 'K' 
		WHEN p_cod_cla_fisc 	= '94039090'
			LET p_letra 	= 'L'
		WHEN p_cod_cla_fisc 	= '39269090'
			LET p_letra 	= 'M'
	END CASE 
END FUNCTION 

#------------------------------------#
FUNCTION pol0942_carrega_clas_fiscal()
#------------------------------------#
   DEFINE l_cont          SMALLINT,
          l_aux_cla_fisc  CHAR(02)

   INITIALIZE l_aux_cla_fisc TO NULL
   LET l_cla_fisc_nff = "A"

	CASE
		WHEN p_fat_nf_item.cod_cla_fisc		= "73182100"
			LET l_cla_fisc_nff 	="A"
		WHEN p_fat_nf_item.cod_cla_fisc		= "73181500"
			LET l_cla_fisc_nff 	="B"
		WHEN p_fat_nf_item.cod_cla_fisc		= "83021000"
			LET l_cla_fisc_nff 	="C"
		WHEN p_fat_nf_item.cod_cla_fisc		= "83013000" 
			LET l_cla_fisc_nff 	="D"
		WHEN p_fat_nf_item.cod_cla_fisc		= "79070090"
			LET l_cla_fisc_nff 	="E"
		WHEN p_fat_nf_item.cod_cla_fisc		= "39263000"
			LET l_cla_fisc_nff 	="F"
		WHEN p_fat_nf_item.cod_cla_fisc		= "83024200"
			LET l_cla_fisc_nff 	="G" 	
		WHEN p_fat_nf_item.cod_cla_fisc		= "72042900"
			LET l_cla_fisc_nff 	="H"
		WHEN p_fat_nf_item.cod_cla_fisc		= "74022100"
			LET l_cla_fisc_nff 	="I"
		WHEN p_fat_nf_item.cod_cla_fisc		= "48119090"
			LET l_cla_fisc_nff 	="J" 
		WHEN p_fat_nf_item.cod_cla_fisc		= '94032000'
			LET l_cla_fisc_nff 	= 'K' 
		WHEN p_fat_nf_item.cod_cla_fisc 	= '94039090'
			LET l_cla_fisc_nff 	= 'L'
		WHEN p_fat_nf_item.cod_cla_fisc 	= '39269090'
			LET l_cla_fisc_nff 	= 'M'
	END CASE 
	RETURN l_cla_fisc_nff  
             
END FUNCTION

#--------------------------------------#
FUNCTION pol0942_verifica_ctr_unid_med()
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

#------------------------------------------#
FUNCTION pol0942_carrega_tabela_temporaria()
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

      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES ( p_num_seq,
                                     1,
                                     pa_corpo_nff[i].cod_item,
                                     pa_corpo_nff[i].den_item1,
                                     pa_corpo_nff[i].cod_cla_fisc,     
                                     pa_corpo_nff[i].cod_origem,
                                     pa_corpo_nff[i].cod_tributacao,
                                     pa_corpo_nff[i].cod_unid_med,
                                     pa_corpo_nff[i].qtd_item,
                                     pa_corpo_nff[i].pre_unit,
                                     pa_corpo_nff[i].val_liq_item,
                                     pa_corpo_nff[i].pct_icm,
                                     pa_corpo_nff[i].pct_ipi,
                                     pa_corpo_nff[i].val_ipi,
                                     "","")

      { insere segunda parte da denominacao do item, se esta existir }

         display pa_corpo_nff[i].den_item2 at 6,3 

      IF pa_corpo_nff[i].den_item2 IS NOT NULL AND 
         pa_corpo_nff[i].den_item2 <> "  "     AND
         p_tipo_desc <> "V"   THEN 
         LET p_num_seq = p_num_seq + 1 
 
         display pa_corpo_nff[i].den_item2 at 6,3 
  
         INSERT INTO wnotalev 
               VALUES (p_num_seq,2,"cod_item_cliente",pa_corpo_nff[i].den_item2,
                        "","","","","","","","","","","","")
      END IF

#     IF pa_corpo_nff[i].val_icm_ret > 0 THEN
#       LET p_des_texto = "               ICMS RET. SUBST. TRI",
#                         "B.                                 ",
#                         "                                    ",
#                         pa_corpo_nff[i].val_icm_ret USING "##########&.&&"
#       LET p_num_seq = p_num_seq + 1
#       INSERT INTO wnotalev VALUES ( p_num_seq,3,"","","","","",
#                                     "","","","","","","",
#                                     p_des_texto,"")
#    END IF

      { imprime texto do item, se este existir }
####  aquioooooooo
      FOR j = 1 TO 23
         IF pol0942_verifica_texto_ped_it(pa_corpo_nff[i].num_pedido,i) THEN
            IF pa_texto_ped_it[j].texto IS NOT NULL AND 
               pa_texto_ped_it[j].texto <> " " THEN
               LET p_num_seq = p_num_seq + 1
               INSERT INTO wnotalev VALUES ( p_num_seq,3,"","","","","",
                                               "","","","","","","",
                                               pa_texto_ped_it[j].texto,"")
            END IF
         END IF
      END FOR
      LET p_val_merc = p_val_merc + pa_corpo_nff[i].val_liq_item 
    
      IF p_nat_operacao.ies_tip_controle = "4" THEN
 
         LET p_des_texto = NULL   
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev VALUES ( p_num_seq,3,"","","","","",
                                       "","","","","","","",
                                       p_des_texto,"") 

         DECLARE cq_wfat_itret  CURSOR WITH HOLD FOR
         SELECT den_item_reduz,qtd_item,pre_unit_nf,pre_unit_nf*qtd_item,item.cod_unid_med
           FROM fat_nf_item , item   
          WHERE fat_nf_item.cod_empresa = p_cod_empresa 
            AND fat_nf_item.cod_empresa = item.cod_empresa 
            AND fat_nf_item.item    = item.cod_item    
            AND fat_nf_item.num_nff     = p_fat_nf_mestre.nota_fiscal
            AND fat_nf_item.serie_nota_fiscal = p_fat_nf_mestre.serie_nota_fiscal
            AND fat_nf_item.pedido  = 0                     

         FOREACH cq_wfat_itret  INTO p_den_item_reduz,p_qtd_item,p_pre_unit_nf,p_pre_tot_nf,p_unid_med


           LET p_des_texto = p_den_item_reduz,"qtd ",p_qtd_item," ",p_unid_med," unit. ",p_pre_unit_nf," total ",p_pre_tot_nf
         	
           LET p_num_seq = p_num_seq + 1
           INSERT INTO wnotalev VALUES ( p_num_seq,3,"","","","","",
                                         "","","","","","","",
                                         p_des_texto,"")
         END FOREACH
      END IF   

   END FOR
   
   LET p_des_texto = " "
   CALL pol0942_insert_array(p_des_texto)
   
   IF p_clientes.ies_zona_franca  = "S" AND
      p_clientes.num_suframa      >  0  AND
      p_fat_nf_mestre.val_desc_merc >  0  THEN
      LET p_des_texto = "DESCONTO ESPECIAL DE ", p_fat_nf_item_fisc.aliquota
                         USING "#&.&", "%  ICMS.........:",
                         p_fat_nf_mestre.val_desc_merc USING "###,###,##&.&&"
      CALL pol0942_insert_array(p_des_texto)
   END IF

   {IF (p_fat_mestre_fiscal.val_tributo_tot - p_val_tot_ipi_acum) > 0 THEN
      LET p_des_texto = "IPI S/ FRETE  ",
                        (p_fat_mestre_fiscal.val_tributo_tot - p_val_tot_ipi_acum)
                         USING "#######&.&&"
      CALL pol0942_insert_array(p_des_texto)
   END IF}
   
   IF p_clientes.num_suframa > 0 THEN
      LET p_des_texto = "CODIGO SUFRAMA: ",
                         p_clientes.num_suframa USING "&&&&&&&&&";
      CALL pol0942_insert_array(p_des_texto)
   END IF    
END FUNCTION


#-----------------------------------------#
FUNCTION pol0942_calcula_total_de_paginas()
#-----------------------------------------#

   SELECT COUNT(*)
     INTO p_num_linhas
     FROM wnotalev

   { 33 = numero de linhas do corpo da nota fiscal }

   IF p_num_linhas IS NOT NULL AND 
      p_num_linhas > 0         THEN 
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 33 )) / 33 
      IF (p_num_linhas MOD 33 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_ies_termina_relat = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF
END FUNCTION


#------------------------------------------#
FUNCTION pol0942_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE p_subst_trib_uf.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT subst_trib_uf.*
     INTO p_subst_trib_uf.*
     FROM clientes, cidades, subst_trib_uf
    WHERE clientes.cod_cliente        = p_fat_nf_mestre.cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
   WHENEVER ERROR STOP
END FUNCTION


#-----------------------------#
FUNCTION pol0942_den_nat_oper()
#-----------------------------#

   WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
     INTO p_nat_operacao.*
     FROM nat_operacao
    WHERE cod_nat_oper = p_fat_nf_mestre.natureza_operacao
   WHENEVER ERROR STOP
 
   IF sqlca.sqlcode = 0 THEN 
      IF p_nat_operacao.ies_tip_controle = "4" THEN 
         SELECT UNIQUE cod_fiscal 
           INTO p_cod_fiscal_ind
           FROM fat_nf_item_fisc 
          WHERE empresa=p_cod_empresa 
            AND trans_nota_fiscal = p_fat_nf_mestre.trans_nota_fiscal 
            AND cod_fiscal <> p_fat_nf_item_fisc.cod_fiscal
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
FUNCTION pol0942_busca_coef_compl()
#------------------------------------#

   LET p_cod_fiscal_compl = 0

   WHENEVER ERROR CONTINUE

      SELECT cod_fiscal_compl
        INTO p_cod_fiscal_compl
        FROM fiscal_par_compl
       WHERE cod_empresa=p_cod_empresa
         AND cod_nat_oper=p_fat_nf_mestre.natureza_operacao
         AND cod_uni_feder=p_cidades.cod_uni_feder

       IF sqlca.sqlcode <> 0 THEN
          LET p_cod_fiscal_compl = 0
       END IF   

   WHENEVER ERROR STOP

END FUNCTION

#------------------------------------#
FUNCTION pol0942_busca_dados_empresa()            
#------------------------------------#
   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
     INTO p_empresa.*
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   WHENEVER ERROR STOP
END FUNCTION

#------------------------------#
FUNCTION pol0942_representante()
#------------------------------#
   DEFINE p_nom_guerra 			LIKE representante.nom_guerra,
					p_representante	 	LIKE FAT_NF_REPR.REPRESENTANTE
					
		SELECT FAT_NF_REPR.REPRESENTANTE, REPRESENTANTE.NOM_REPRES
		INTO p_representante,p_nom_guerra
		FROM FAT_NF_REPR,REPRESENTANTE
		WHERE FAT_NF_REPR.EMPRESA=p_cod_empresa
		AND FAT_NF_REPR.TRANS_NOTA_FISCAL = p_fat_nf_mestre.TRANS_NOTA_FISCAL
		AND REPRESENTANTE.COD_REPRES=FAT_NF_REPR.REPRESENTANTE
    

   RETURN p_nom_guerra ,p_representante
END FUNCTION

#---------------------------------------#
FUNCTION pol0942_grava_dados_historicos()
#---------------------------------------#
   INITIALIZE p_fat_nf_texto_hist.* TO NULL

  
   DECLARE cq_texto_hist  CURSOR FOR 
   SELECT *
     FROM fat_nf_texto_hist
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal     = p_fat_nf_mestre.trans_nota_fiscal
    ORDER BY sequencia_texto
   FOREACH cq_texto_hist INTO p_fat_nf_texto_hist.*
			CALL pol0942_insert_array(p_fat_nf_texto_hist.des_texto)
   END FOREACH
   
   {IF   p_fat_mestre_fiscal.val_trib_merc > 0
   THEN LET p_des_texto = "BASE DE CALCULO ICMS ST.... R$ ", p_fat_mestre_fiscal.bc_trib_mercadoria USING "###,###,##&.&&",
                          "   - ALIQ UF DEST.: ",p_subst_trib_uf.pct_icm USING "#&","%"   
        CALL pol0942_insert_array(p_des_texto)
        LET p_des_texto = "ICMS S/ OPERACAO DE VENDA.. R$ ", p_fat_mestre_fiscal.val_trib_merc USING "###,###,##&.&&"
        CALL pol0942_insert_array(p_des_texto)
        LET p_des_texto = "ICMS RETIDO................ R$ ", p_fat_mestre_fiscal.val_trib_merc USING "###,###,##&.&&"
        CALL pol0942_insert_array(p_des_texto)
        LET p_des_texto = "TOTAL DO ICMS.............. R$ ", (p_fat_mestre_fiscal.val_trib_merc + p_fat_mestre_fiscal.val_trib_merc) USING "###,###,##&.&&"
        CALL pol0942_insert_array(p_des_texto)
   END IF}
END FUNCTION
 
#------------------------------#
FUNCTION pol0942_especie()
#------------------------------#
   DEFINE p_des_especie    CHAR(30),
   				p_des_especie1    CHAR(30),
   				p_des_especie2    CHAR(30),
   				p_des_especie3    CHAR(30)

   WHENEVER ERROR CONTINUE
   DECLARE cq_den_embal CURSOR FOR 
						   	SELECT DEN_EMBAL
								FROM FAT_NF_EMBALAGEM,EMBALAGEM
								WHERE FAT_NF_EMBALAGEM.EMPRESA=p_cod_empresa
								AND FAT_NF_EMBALAGEM.TRANS_NOTA_FISCAL= p_fat_nf_mestre.trans_nota_fiscal
								AND FAT_NF_EMBALAGEM.EMBALAGEM=COD_EMBAL
						
								
		FOREACH cq_den_embal INTO p_des_especie
			CASE 
				WHEN p_des_especie1 IS NULL 
					LET p_des_especie1 =p_des_especie
				WHEN p_des_especie2 IS NULL AND p_des_especie1 AND NOT NULL 
					LET p_des_especie2 =p_des_especie
				WHEN p_des_especie3 IS NULL AND p_des_especie3 AND NOT NULL
					LET p_des_especie3 =p_des_especie
				WHEN p_des_especie3 IS NOT NULL 
					EXIT FOREACH
			END CASE
		END FOREACH
   WHENEVER ERROR STOP
  
   RETURN p_des_especie1,p_des_especie2,p_des_especie3
   
END FUNCTION 

#-----------------------------#
FUNCTION pol0942_den_cnd_pgto()
#-----------------------------#
   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(05,3)

   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,pct_desp_finan
     INTO p_den_cnd_pgto,p_pct_desp_finan
     FROM cond_pgto
    WHERE cod_cnd_pgto = p_fat_nf_mestre.cond_pagto
   WHENEVER ERROR STOP
 
   IF p_pct_desp_finan IS NOT NULL
      AND p_pct_desp_finan > 1 THEN
      LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
      LET p_des_texto = "ENCARGO FINANCEIRO: ",  p_pct_enc_finan USING "#&.&&&"," %"
      CALL pol0942_insert_array(p_des_texto)
   END IF 

   RETURN p_den_cnd_pgto

END FUNCTION 


#---------------------------------------------------#
FUNCTION pol0942_busca_dados_clientes(p_cod_cliente)
#---------------------------------------------------#
   DEFINE p_cod_cliente      LIKE clientes.cod_cliente,
          p_aux_nom_cliente  LIKE clientes.nom_cliente

   INITIALIZE p_clientes.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_clientes.*
     FROM clientes
    WHERE cod_cliente = p_fat_nf_mestre.cliente

{  SELECT UNIQUE tex_complementar 
     INTO p_aux_nom_cliente
     FROM cliente_item a,fat_nf_item b,item c
    WHERE cod_cliente_matriz = p_cod_cliente
      AND b.num_nff          = p_fat_nf_mestre.nota_fiscal
      AND c.cod_empresa      = p_cod_empresa
      AND c.cod_item         = b.cod_item
      AND a.cod_item         = b.cod_item
       IF p_aux_nom_cliente IS NOT NULL 
          AND p_aux_nom_cliente <> " "
          THEN LET p_clientes.nom_cliente = p_aux_nom_cliente 
       END IF
}
   WHENEVER ERROR STOP
END FUNCTION

#--------------------------------#
FUNCTION pol0942_busca_nome_pais()                   
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
FUNCTION pol0942_busca_dados_transport(p_cod_transpor)
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
FUNCTION pol0942_busca_dados_cidades(p_cod_cidade)
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
FUNCTION pol0942_busca_dados_pedido()
#-----------------------------------#  

   SELECT pedidos.num_pedido_repres, 
          pedidos.num_pedido_cli
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli
     FROM pedidos
    WHERE pedidos.cod_empresa         = p_fat_nf_mestre.empresa 
      AND pedidos.num_pedido          = p_fat_nf_item.pedido

END FUNCTION

#-----------------------------------------------#
FUNCTION pol0942_grava_dados_consig()
#-----------------------------------------------#
  # DEFINE p_cod_consig  LIKE clientes.cod_cliente

   INITIALIZE p_consignat.* TO NULL

   WHENEVER ERROR CONTINUE
   DECLARE cq_consignat CURSOR FOR 
	  SELECT clientes.nom_cliente,
	          clientes.end_cliente,
	          clientes.den_bairro,
	          cidades.den_cidade,
	          cidades.cod_uni_feder
	     FROM clientes,
	          cidades,
	          FAT_CONSIG_NF
	    WHERE clientes.cod_cliente = FAT_CONSIG_NF.CONSIGNATARIO
	      AND clientes.cod_cidade  = cidades.cod_cidade
	      AND FAT_CONSIG_NF.EMPRESA=p_cod_empresa
	      AND FAT_CONSIG_NF.TRANS_NOTA_FISCAL= p_fat_nf_mestre.trans_nota_fiscal
	  
	 	FOREACH cq_consignat INTO p_consignat.*
	 		IF p_consignat.den_consignat IS NOT NULL THEN 
	 			EXIT FOREACH
	 		END IF 
	 	END FOREACH
   WHENEVER ERROR STOP

   IF sqlca.sqlcode = 0 THEN 
      IF p_consignat.den_consignat IS NOT NULL OR
         p_consignat.den_consignat  <> "  "    THEN 
         LET p_des_texto = "Consig.: ", p_consignat.den_consignat       
         CALL pol0942_insert_array(p_des_texto)

         IF p_consignat.end_consignat IS NOT NULL OR
            p_consignat.end_consignat <> "  "     THEN
            LET p_des_texto   = p_consignat.end_consignat        
            CALL pol0942_insert_array(p_des_texto)
         END IF

         IF p_consignat.den_bairro IS NOT NULL OR
            p_consignat.den_bairro <> "  "     THEN
            LET p_des_texto   = p_consignat.den_bairro        
            CALL pol0942_insert_array(p_des_texto)
         END IF

         IF p_consignat.den_cidade IS NOT NULL OR
            p_consignat.den_cidade <> "  "     THEN
            LET p_des_texto   = p_consignat.den_cidade        
            CALL pol0942_insert_array(p_des_texto)
         END IF
      END IF
   END IF
END FUNCTION

#----------------------------------------#
FUNCTION pol0942_grava_dados_end_entrega()
#----------------------------------------#
   WHENEVER ERROR CONTINUE
   SELECT wfat_end_ent_ser.end_entrega,
          wfat_end_ent_ser.num_cgc,
          wfat_end_ent_ser.ins_estadual,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO p_end_entrega.*
     FROM wfat_end_ent_ser,
          cidades
    WHERE wfat_end_ent_ser.cod_empresa = p_cod_empresa
      AND wfat_end_ent_ser.num_nff     = p_fat_nf_mestre.nota_fiscal
      AND wfat_end_ent_ser.cod_cidade  = cidades.cod_cidade
      AND wfat_end_ent_ser.serie_nota_fiscal = p_fat_nf_mestre.serie_nota_fiscal
   WHENEVER ERROR STOP

END FUNCTION

#-------------------------------------------------------------------#
FUNCTION pol0942_verifica_texto_ped_it(p_num_pedido, p_num_sequencia)
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
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_num_pedido
      AND num_sequencia = p_num_sequencia 

   SELECT des_esp_item[1,30]
     INTO p_des_esp_item       
     FROM item_esp        
    WHERE cod_empresa   = p_cod_empresa
      AND cod_item      = p_cod_item  
      AND num_seq       = 1                

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
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
#     LET pa_texto_ped_it[2].texto = p_ped_itens_texto.den_texto_2
#     LET pa_texto_ped_it[3].texto = p_ped_itens_texto.den_texto_3
#     LET pa_texto_ped_it[4].texto = p_ped_itens_texto.den_texto_4
#     LET pa_texto_ped_it[5].texto = p_ped_itens_texto.den_texto_5
      RETURN TRUE
#  ELSE
#     RETURN FALSE
#  END IF
END FUNCTION

#----------------------------------------------#
FUNCTION pol0942_carrega_classificacao_fiscal()
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
FUNCTION pol0942_insert_array(p_des_texto)
#----------------------------------------#
   DEFINE p_des_texto               CHAR(120)

   LET p_num_seq     = p_num_seq + 1
   
   # No corpo da Nf. tem espaco para imprimir toda a OBS, nao precisa
   # quebrar em partes.
   INSERT INTO wnotalev
        VALUES ( p_num_seq,3,"","","","","","","","","","","","", 
                 p_des_texto,"")

END FUNCTION 


#--------------------------------#
REPORT pol0942_relat(p_wnotalev)
#--------------------------------#
   DEFINE i         SMALLINT,
          l_nulo    CHAR(10),
          p_nf_ant  DECIMAL(7,0),
          p_cont_nf_rt SMALLINT

   DEFINE p_wnotalev  
          RECORD
             num_seq             SMALLINT,
             ies_tip_info        SMALLINT,
             cod_item            LIKE fat_nf_item.item,
             den_item            CHAR(060),
             cod_cla_fisc        CHAR(001),
             cod_origem          LIKE fat_nf_item_fisc.origem_produto,
             cod_tributacao      LIKE fat_nf_item_fisc.tributacao,
             cod_unid_med        LIKE fat_nf_item.unid_medida,
             qtd_item            LIKE fat_nf_item.qtd_item,
             pre_unit            LIKE fat_nf_item.preco_unit_liquido,
             val_liq_item        LIKE fat_nf_item.val_liquido_item,
             pct_icm             LIKE fat_nf_item_fisc.aliquota,
             pct_ipi             LIKE fat_nf_item_fisc.aliquota,
             val_ipi             LIKE fat_nf_item_fisc.val_trib_merc,
             des_texto           CHAR(120),
             num_nff             LIKE fat_nf_mestre.nota_fiscal
          END RECORD

   DEFINE p_for                  SMALLINT,
          p_sal                  SMALLINT,
          p_des_folha            CHAR(100)

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH  96 

   ORDER EXTERNAL BY p_wnotalev.num_nff,
                     p_wnotalev.num_seq
   FORMAT
   PAGE HEADER
      LET p_num_pagina = p_num_pagina + 1
      PRINT p_8lpp,
            p_descomprime
      SKIP 1 LINES
      PRINT COLUMN 083, p_nff.num_nff   USING "&&&&&&"
      # PRINT
      PRINT COLUMN 061, "X"
      SKIP 6 LINES 
      IF p_nat_operacao.ies_tip_controle = "4" THEN
#        IF p_cod_fiscal_compl = 0 THEN
            PRINT COLUMN 001, p_nff.den_nat_oper,
                  COLUMN 037, p_nff.cod_fiscal         USING "&&&&",
                  COLUMN 041, "/",
                  COLUMN 042, p_cod_fiscal_ind         USING "&&&&",
                  COLUMN 046, p_nff.ins_estadual_trib
#        ELSE
#           PRINT COLUMN 001, p_nff.den_nat_oper,
#                 COLUMN 037, p_nff.cod_fiscal         USING "&&&",
#                 COLUMN 040, ".",
#                 COLUMN 041,p_cod_fiscal_compl        USING "&",
#                 COLUMN 042, "/",
#                 COLUMN 043, p_cod_fiscal_ind         USING "&&&",
#                 COLUMN 046, p_nff.ins_estadual_trib
#        END IF     
      ELSE  
#        IF p_nff.cod_fiscal = 513   THEN                     
         IF p_nff.cod_fiscal = 5124  THEN                     
            PRINT COLUMN 001, p_nff.den_nat_oper,
                  COLUMN 037, p_nff.cod_fiscal         USING "&&&&",
#                 COLUMN 041, "/594",
                  COLUMN 041, "/5902",
                  COLUMN 046, p_nff.ins_estadual_trib
         ELSE  
#           IF p_cod_fiscal_compl = 0 THEN
               PRINT COLUMN 001, p_nff.den_nat_oper[1,21],
                     COLUMN 038, p_nff.cod_fiscal         USING "&&&&",
                     COLUMN 044, p_nff.ins_estadual_trib
#           ELSE 
#              PRINT COLUMN 001, p_nff.den_nat_oper[1,21],
#                    COLUMN 037, p_nff.cod_fiscal         USING "&&&",
#                    COLUMN 040, ".",                                   
#                    COLUMN 041, p_cod_fiscal_compl       USING "&",
#                    COLUMN 044, p_nff.ins_estadual_trib
#           END IF
         END IF
      END IF
      SKIP 3 LINES
      PRINT COLUMN 001, p_nff.nom_destinatario,
            COLUMN 061, p_nff.num_cgc_cpf,
            COLUMN 081, p_nff.dat_emissao        USING "dd/mm/yyyy"
      SKIP 2 LINES
      PRINT COLUMN 001, p_nff.end_destinatario,
            COLUMN 049, p_nff.den_bairro,       
            COLUMN 068, p_nff.cod_cep 
      SKIP 2 LINES
      PRINT COLUMN 001, p_nff.den_cidade, 
            COLUMN 040, p_nff.num_telefone,
            COLUMN 058, p_nff.cod_uni_feder,
            COLUMN 061, p_nff.ins_estadual 
      SKIP 3 LINES
      PRINT COLUMN 038, p_nff.dat_vencto_sd1     USING "dd/mm/yyyy",
            COLUMN 048, p_nff.dat_vencto_sd2     USING "dd/mm/yyyy",
            COLUMN 059, p_nff.dat_vencto_sd3     USING "dd/mm/yyyy",
            COLUMN 070, p_nff.dat_vencto_sd4     USING "dd/mm/yyyy",
            COLUMN 080, p_nff.dat_vencto_sd5     USING "dd/mm/yyyy"
      SKIP 1 LINES
      PRINT COLUMN 038, p_nff.val_duplic1        USING "###,##&.&&", 
            COLUMN 049, p_nff.val_duplic2        USING "###,##&.&&", 
            COLUMN 060, p_nff.val_duplic3        USING "###,##&.&&", 
            COLUMN 071, p_nff.val_duplic4        USING "###,##&.&&", 
            COLUMN 081, p_nff.val_duplic5        USING "###,##&.&&"  
 {27} SKIP 5 LINES

   BEFORE GROUP OF p_wnotalev.num_nff
      SKIP TO TOP OF PAGE

   ON EVERY ROW
      CASE
         WHEN p_wnotalev.ies_tip_info = 1             
            PRINT COLUMN 001, p_comprime,
                              p_wnotalev.cod_item[1,10], 
                  COLUMN 011, p_descomprime,
                  COLUMN 011, p_wnotalev.den_item[1,40],
                  COLUMN 041, p_comprime,
                  #COLUMN 055, p_wnotalev.cod_cla_fisc,
                  COLUMN 055, p_letra,
                  COLUMN 057, p_wnotalev.cod_origem USING "&",
                  COLUMN 058, p_wnotalev.cod_tributacao USING "&&",
                  COLUMN 063, p_wnotalev.cod_unid_med,
                  COLUMN 070, p_wnotalev.qtd_item       USING "#######&.&&&",
                  COLUMN 079, p_wnotalev.pre_unit       USING "###,##&.&&&&&&",
                  COLUMN 099, p_wnotalev.val_liq_item   USING "#,###,##&.&&",
                  COLUMN 112, p_wnotalev.pct_icm        USING "#&", 
                  COLUMN 118, p_wnotalev.pct_ipi        USING "#&", 
                  COLUMN 121, p_wnotalev.val_ipi        USING "###,##&.&&" 
            LET p_linhas_print = p_linhas_print + 1
        
         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 012, p_comprime,
                  COLUMN 013, p_wnotalev.den_item,
                              p_descomprime
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 3
            PRINT COLUMN 012, p_comprime,
                              p_wnotalev.des_texto,
                              p_descomprime
            LET p_linhas_print = p_linhas_print + 1
                    
         WHEN p_wnotalev.ies_tip_info = 4
            WHILE TRUE
               IF p_linhas_print < 23  THEN 
                  PRINT 
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF          
            END WHILE
      END CASE

      IF p_linhas_print = 23 THEN { nr. de linhas do corpo da nota }
 
####     PRINT COLUMN 001, p_descomprime,
####           COLUMN 010, "NOVO ENDERECO AV JOAO PAULO I, 1280 JD DAS OLIVEIRAS - EMBU SP 06816600"
####     PRINT COLUMN 010, "VISITE NOSSO SITE WWW.ALBRAS.IND.BR - NOVO TELEFONE 0XX11-7965-1700" 
        PRINT 
        PRINT 
   {34}  PRINT COLUMN 001, p_des_folha      
         SKIP 2 LINES
         IF p_num_pagina = p_tot_paginas THEN 
            PRINT COLUMN 001, p_descomprime,
                  COLUMN 003, p_nff.val_tot_base_icm    USING "###,###,##&.&&",
                  COLUMN 019, p_nff.val_tot_icm         USING "###,###,##&.&&",
                  #COLUMN 040, p_nff.val_tot_base_ret    USING "###,###,##&.&&",
                  #COLUMN 058, p_nff.val_tot_icm_ret     USING "###,###,##&.&&",
                  COLUMN 074, p_nff.val_tot_mercadoria  USING "###,###,##&.&&"
            SKIP 1 LINES
            PRINT COLUMN 001, p_nff.val_frete_cli       USING "#,###,##&.&&", 
                  COLUMN 011, p_nff.val_seguro_cli      USING "#,###,##&.&&",
                  COLUMN 029, p_nff.val_tot_despesas    USING "###,###,##&.&&",
                  COLUMN 053, p_nff.val_tot_ipi         USING "###,###,##&.&&",
                  COLUMN 074, p_nff.val_tot_nff         USING "###,###,##&.&&"
            SKIP 4 LINES
            PRINT COLUMN 001, p_nff.nom_transpor,                  
                  COLUMN 059, p_nff.ies_frete           USING "&",
                  COLUMN 062, p_nff.num_placa,
                  COLUMN 071, p_nff.cod_uni_feder_trans,
                  COLUMN 074, p_nff.num_cgc_trans
            SKIP 2 LINES
            PRINT COLUMN 001, p_nff.end_transpor,    
                  COLUMN 052, p_nff.den_cidade_trans[1,17],
                  COLUMN 072, p_nff.cod_uni_feder_trans,
                  COLUMN 074, p_nff.ins_estadual_trans   
            SKIP 1 LINES
         #  PRINT COLUMN 001, p_nff.qtd_volume1    USING "####",    
         #        COLUMN 015, p_nff.des_especie1,
            PRINT COLUMN 039, p_nff.den_marca,
         #        COLUMN 061, p_nff.pes_tot_bruto     USING "#,###,##&.&&&",
                  COLUMN 074, p_nff.pes_tot_liquido   USING "#,###,##&.&&&" 
    
            SKIP 3 LINES
            PRINT COLUMN 001, p_comprime 
            PRINT COLUMN 007, p_nff.cod_repres
########### SKIP 1 LINES
            PRINT COLUMN 015, p_nff.cod_cliente
            SKIP 1 LINES
            PRINT COLUMN 007, p_nff.num_pedido_repres

            SKIP 2 LINES
            IF p_nff.num_pedido_cli <> "               " AND  
               p_nff.num_pedido_cli IS NOT NULL THEN
               PRINT COLUMN 001, p_nff.num_pedido_cli 
            END IF
            IF p_end_entrega.end_entrega IS NOT NULL THEN       
               PRINT COLUMN 001, "END.ENTREGA: ",  
                     COLUMN 014, p_end_entrega.end_entrega 
               PRINT COLUMN 014, p_end_entrega.den_cidade,
                     COLUMN 039, p_end_entrega.cod_uni_feder  
            END IF 
            #PRINT COLUMN 001, "Codigo Reparticao Fisca: PFC 298 - EMBU/SP" 
            PRINT 
            SKIP 7 LINES
            LET p_num_pagina = 0 
         ELSE 
            PRINT COLUMN 005, "**************",
                  COLUMN 024, "**************",
                  COLUMN 043, "**************",
                  COLUMN 062, "**************",
                  COLUMN 082, "**************"
            PRINT
            PRINT COLUMN 005, "**************", 
                  COLUMN 024, "**************",
                  COLUMN 043, "**************",
                  COLUMN 062, "**************",
                  COLUMN 082, "**************"
            SKIP 20 LINES
         END IF
         PRINT COLUMN 010, p_nff.num_nff USING "&&&&&&"
         SKIP 1 LINES
      END IF

END REPORT

#-------------------------- FIM DE PROGRAMA ---------------------------#
