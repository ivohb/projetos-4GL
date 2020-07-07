#---------------------------------------------------------------------------#  
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                               #
# PROGRAMA: pol0949                                                         #
# MODULOS.: pol0949  - LOG0010 - LOG0040 - LOG0050 - LOG0060                #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                          #
# OBJETIVO: IMPRESSAO DAS NOTAS FISCAIS FATURA - SERVICO - ETHOS/COBSEN     #
#						EMPRESA 7																												#
# AUTOR...: JUCILANE ROSA CITADIN                                           #
# DATA....: 05/09/2003                                                      #
# ALTERADO: 24/09/2007 por Ana Paula - versao 13                            #
#---------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_cod_moeda              LIKE moeda.cod_moeda,      
          p_den_moeda              LIKE moeda.den_moeda,      
          p_val_cotacao            LIKE cotacao.val_cotacao,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_caminho                CHAR(80),
          p_ies_impressao          CHAR(01),
          p_reimpressao            CHAR(01),
          p_num_nff_ini            LIKE fat_nf_mestre.nota_fiscal,
          p_num_nff_fim            LIKE fat_nf_mestre.nota_fiscal,
          p_val_tot_servico        LIKE fat_nf_mestre.val_nota_fiscal,
          comando                  CHAR(80),
          p_texto 								 CHAR(400),
          p_msg                    CHAR(500)
          
   DEFINE texto      VARCHAR(255),
          tam_linha  SMALLINT,
          qtd_linha  SMALLINT,
          justificar CHAR(01)
          
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
      
   
   DEFINE num_carac  SMALLINT,
          ret        VARCHAR(255)
   
   

   DEFINE p_num_seq                SMALLINT,
          p_qtd_lin_obs            SMALLINT

   DEFINE p_fat_nf_mestre_serv   RECORD LIKE fat_nf_mestre.*,
          p_fat_nf_item_serv   	 RECORD LIKE fat_nf_item.*,
          p_fat_nf_texto_hist   RECORD LIKE fat_nf_texto_hist.*,
          p_cidades              RECORD LIKE cidades.*,
          p_empresa              RECORD LIKE empresa.*,
          p_embalagem            RECORD LIKE embalagem.*,
          p_clientes             RECORD LIKE clientes.*,
          p_paises               RECORD LIKE paises.*,
          p_uni_feder            RECORD LIKE uni_feder.*,
          p_transport            RECORD LIKE clientes.*,
          p_ped_itens_texto      RECORD LIKE ped_itens_texto.*,
          p_fator_cv_unid        RECORD LIKE fator_cv_unid.*,  
          p_subst_trib_uf        RECORD LIKE subst_trib_uf.*,
          p_cli_end_cobr         RECORD LIKE cli_end_cob.*,
          p_obf_par_fisc_compl   RECORD LIKE obf_par_fisc_compl.*,
          p_par_vdp_pad          RECORD LIKE par_vdp_pad.*,
          p_cod_fiscal_compl     INTEGER,
          p_pct_iss							 LIKE servico_par.pct_iss,
          p_pct_irrf						 LIKE servico_par.pct_irrf
          

   DEFINE p_nff       
          RECORD
             num_nff             LIKE fat_nf_mestre.nota_fiscal,
             den_nat_oper        LIKE nat_operacao.den_nat_oper,
             cod_fiscal          INTEGER,                          
             ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp    LIKE empresa.ins_estadual,
             dat_emissao         LIKE fat_nf_mestre.dat_hor_emissao,     
             nom_destinatario    LIKE clientes.nom_cliente,
             num_cgc_cpf         LIKE clientes.num_cgc_cpf,
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

             num_duplic1         LIKE fat_nf_duplicata.trans_nota_fiscal,
             dig_duplic1         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd1      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic1         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic2         LIKE fat_nf_duplicata.trans_nota_fiscal,
             dig_duplic2         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd2      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic2         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic3         LIKE fat_nf_duplicata.trans_nota_fiscal,
             dig_duplic3         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd3      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic3         LIKE fat_nf_duplicata.val_duplicata,

             num_duplic4         LIKE fat_nf_duplicata.trans_nota_fiscal,
             dig_duplic4         LIKE fat_nf_duplicata.seq_duplicata,
             dat_vencto_sd4      LIKE fat_nf_duplicata.dat_vencto_sdesc,
             val_duplic4         LIKE fat_nf_duplicata.val_duplicata,

             val_extenso1        CHAR(130),
             val_extenso2        CHAR(130),
             val_extenso3        CHAR(001), 
             val_extenso4        CHAR(001),

             end_cob_cli         LIKE cli_end_cob.end_cobr,
             cod_uni_feder_cobr  LIKE cidades.cod_uni_feder,
             den_cidade_cob      LIKE cidades.den_cidade,

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

             val_tot_servico     LIKE fat_nf_mestre.val_nota_fiscal,
             pct_irrf            LIKE servico_par.pct_irrf,   
             val_tot_irrf        LIKE fat_mestre_fiscal.bc_tributo_tot,   
             val_tot_base_iss    LIKE fat_mestre_fiscal.bc_tributo_tot,
             val_tot_iss         LIKE fat_mestre_fiscal.bc_tributo_tot,
             val_tot_nff         LIKE fat_nf_mestre.val_nota_fiscal,
             den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
             nat_oper            LIKE nat_operacao.cod_nat_oper
          END RECORD

   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE fat_nf_item.item,
             cod_item_cliente    LIKE cliente_item.cod_item_cliente,
             den_item1           CHAR(060),
             den_item2           CHAR(060),
             cod_unid_med        LIKE fat_nf_item.unid_medida,
             qtd_item            LIKE fat_nf_item.qtd_item,
             pre_unit            LIKE fat_nf_item.preco_unit_bruto,
             val_liq_item        LIKE fat_nf_item.val_liquido_item,
             pct_iss             LIKE servico_par.pct_iss,
             val_tot_iss         LIKE fat_nf_mestre.val_nota_fiscal
          END RECORD

   DEFINE p_wnotalev       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          LIKE fat_nf_item.item,
             den_item          CHAR(060),
             cod_unid_med      LIKE fat_nf_item.unid_medida,
             qtd_item          LIKE fat_nf_item.qtd_item,
             pre_unit          LIKE fat_nf_item.preco_unit_bruto,
             val_liq_item      LIKE fat_nf_item.val_liquido_item,
             pct_iss           DECIMAL(5,2),
             val_tot_iss       LIKE fat_mestre_fiscal.bc_tributo_tot,   
             des_texto         CHAR(120),
             num_nff           LIKE fat_nf_mestre.trans_nota_fiscal 
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
          p_8lpp                     CHAR(02),
          p_6lpp                     CHAR(02)
 
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
   CALL log0180_conecta_usuario()
   LET p_versao = "pol0949-10.02.00"
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("pol0949.iem") RETURNING comando
   OPTIONS
      HELP    FILE comando

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0949_controle()
   END IF
END MAIN

#-------------------------#
FUNCTION pol0949_controle()
#-------------------------#
   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("pol0949") RETURNING comando    
   OPEN WINDOW w_pol0949 AT 2,3 WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         CALL pol0949_inicializa_campos()
         IF log005_seguranca(p_user,"VDP","pol0949","CO") THEN
            IF pol0949_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
         HELP 1053
         IF log005_seguranca(p_user,"VDP","pol0949","CO") THEN
            IF pol0949_imprime_nff() THEN
               IF  pol0949_verifica_param_exportacao() = TRUE THEN 
               END IF
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0949_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0949
END FUNCTION

#-----------------------------------#
FUNCTION pol0949_entrada_parametros()
#-----------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0949

   LET p_reimpressao = NULL 
   LET p_num_nff_ini = NULL  
   LET p_num_nff_fim = NULL   

   INPUT p_reimpressao,
         p_num_nff_ini,
         p_num_nff_fim 
      WITHOUT DEFAULTS
   FROM reimpressao,
        num_nff_ini,
        num_nff_fim 
      ON KEY (control-w)
         CASE
            WHEN infield(num_nff_ini) CALL showhelp(3187)
            WHEN infield(num_nff_fim) CALL showhelp(3188)
         END CASE
      BEFORE FIELD reimpressao
         LET p_reimpressao = "N"
         LET p_num_nff_ini = 0
         LET p_num_nff_fim = 999999 
      AFTER FIELD reimpressao
         IF p_reimpressao IS NULL OR
            p_reimpressao = "N" THEN
            LET p_reimpressao = "N"
         ELSE
            IF p_reimpressao <> "S" THEN
               NEXT FIELD reimpressao
            END IF
         END IF
         DISPLAY p_reimpressao TO reimpressao
         DISPLAY p_num_nff_ini TO num_nff_ini
         DISPLAY p_num_nff_fim TO num_nff_fim

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0949

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0949_inicializa_campos()
#----------------------------------#

   INITIALIZE p_nff.*         , 
              pa_corpo_nff    , 
              p_end_entrega.* , 
              p_cidades.*     , 
              p_embalagem.*   , 
              p_clientes.*    , 
              p_paises.*      , 
              p_transport.*   , 
              p_uni_feder.*   , 
              p_ped_itens_texto.*,
              p_subst_trib_uf.*,
              p_par_vdp_pad.*,
              p_obf_par_fisc_compl.*,
              pa_texto_obs TO NULL
 
   LET p_num_nff_ini        = 0
   LET p_num_nff_fim        = 999999

   LET p_ies_termina_relat  = TRUE

   LET p_linhas_print       = 0
   LET p_val_tot_ipi_acum   = 0
   LET p_val_tot_servico    = 0

END FUNCTION

#------------------------------------------#
FUNCTION pol0949_verifica_param_exportacao()
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
    WHERE cod_cliente = p_fat_nf_mestre_serv.cliente

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
FUNCTION pol0949_imprime_nff()
#----------------------------#    

   #IF log028_saida_relat(18,52) IS NOT NULL THEN 
 IF log028_saida_relat(14,41) IS NOT NULL THEN 
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN 
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0949_relat TO PIPE p_nom_arquivo
         ELSE 
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0949.tmp' 
            START REPORT pol0949_relat TO p_caminho 
         END IF 
      ELSE
         START REPORT pol0949_relat TO p_nom_arquivo
      END IF
   ELSE
      RETURN TRUE
   END IF  

   CURRENT WINDOW IS w_pol0949

   CALL pol0949_busca_dados_empresa()
 
   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_8lpp        = ascii 27, "0" 
   LET p_6lpp        = ascii 27, "2" 

   IF p_reimpressao = "S" THEN
      LET p_reimpressao = "R"
   END IF

   DECLARE cq_fat_nf_mestre CURSOR WITH HOLD FOR
  	SELECT a.* from fat_nf_mestre a, fiscal_par b, servico_par c
		WHERE a.empresa = c.cod_empresa
		 AND a.empresa = b.cod_empresa
		 AND a.natureza_operacao = c.cod_nat_oper
		 AND a.natureza_operacao = b.cod_nat_oper
   	 AND a.empresa  				= p_cod_empresa
		 AND a.nota_fiscal     >= p_num_nff_ini
		 AND a.nota_fiscal     <= p_num_nff_fim
		 AND a.tip_nota_fiscal   = "FATPRDSV" 
		 AND a.usu_incl_nf  		 = p_user
		 AND a.sit_impressao		= p_reimpressao
		 AND a.status_nota_fiscal='F'   
   ORDER BY nota_fiscal

   LET p_ies_lista = FALSE
   FOREACH cq_fat_nf_mestre INTO p_fat_nf_mestre_serv.*

      {mostra nf em processam.}
      DISPLAY p_fat_nf_mestre_serv.nota_fiscal TO num_nff_proces 

      CALL pol0949_cria_tabela_temporaria()

      LET p_nff.num_nff            = p_fat_nf_mestre_serv.nota_fiscal

      LET p_nff.den_nat_oper       = pol0949_den_nat_oper()
      LET p_nff.nat_oper           = p_fat_nf_mestre_serv.natureza_operacao
      LET p_nff.dat_emissao        = p_fat_nf_mestre_serv.dat_hor_emissao    

      CALL pol0949_busca_dados_clientes(p_fat_nf_mestre_serv.cliente)
      LET p_nff.nom_destinatario   = p_clientes.nom_cliente
      LET p_nff.num_cgc_cpf        = p_clientes.num_cgc_cpf
      LET p_nff.end_destinatario   = p_clientes.end_cliente
      LET p_nff.den_bairro         = p_clientes.den_bairro
      LET p_nff.cod_cep            = p_clientes.cod_cep
      LET p_nff.cod_cliente        = p_clientes.cod_cliente

      CALL pol0949_busca_dados_cidades(p_clientes.cod_cidade)

      LET p_nff.den_cidade         = p_cidades.den_cidade          
      LET p_nff.num_telefone       = p_clientes.num_telefone
      LET p_nff.cod_uni_feder      = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual       = p_clientes.ins_estadual
      LET p_nff.hora_saida         = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0949_busca_cof_compl()

      CALL pol0949_busca_nome_pais()
      LET p_nff.den_pais = p_paises.den_pais              

      CALL pol0949_busca_dados_duplicatas()

      CALL pol0949_carrega_end_cobranca()

      CALL pol0949_carrega_historico()
    	SELECT PCT_IRRF, PCT_ISS 
			INTO p_pct_irrf, p_pct_iss
			FROM SERVICO_PAR
			WHERE COD_EMPRESA = p_cod_empresa
			 AND COD_NAT_OPER = p_fat_nf_mestre_serv.natureza_operacao
			 
			 IF SQLCA.SQLCODE <> 0 THEN
			 		CALL log003_err_sql('select','info')
			 		LET p_pct_irrf= 0
			 		LET p_pct_iss = 0
			 END IF 
			 
      CALL pol0949_carrega_corpo_nff()  {le os itens pertencentes a nf}

      LET p_nff.val_tot_nff = p_fat_nf_mestre_serv.val_nota_fiscal

      CALL pol0949_carrega_tabela_temporaria() {corpo todo da nota}

			

      LET p_nff.pct_irrf           = p_pct_irrf
      LET p_nff.val_tot_irrf       = p_fat_nf_mestre_serv.val_mercadoria * (1+( p_pct_irrf/100 ))
      LET p_nff.val_tot_base_iss   = p_fat_nf_mestre_serv.val_mercadoria 
      LET p_nff.val_tot_iss        = p_fat_nf_mestre_serv.val_mercadoria * (1+( p_pct_iss/100 ))

      LET p_nff.den_cnd_pgto = pol0949_den_cnd_pgto()
      LET p_ies_lista = TRUE

      CALL pol0949_calcula_total_de_paginas()

      CALL pol0949_monta_relat()

      #### marca nf que ja foi impressa ####
      UPDATE fat_nf_mestre 
         SET sit_impressao = "R"
       WHERE empresa = p_cod_empresa
       	 AND trans_nota_fiscal = p_fat_nf_mestre_serv.trans_nota_fiscal
         AND nota_fiscal	     = p_fat_nf_mestre_serv.nota_fiscal
         AND usu_incl_nf = p_user

      CALL pol0949_inicializa_campos()

   END FOREACH

   FINISH REPORT pol0949_relat

   IF p_ies_lista THEN
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                  ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando 
         END IF
      ELSE 
         MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo, " " 
            ATTRIBUTE(REVERSE)
      END IF
   ELSE
      MESSAGE ""
      ERROR "Nao Existem Dados para serem Listados"
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol0949_cria_tabela_temporaria()
#---------------------------------------#

   WHENEVER ERROR CONTINUE

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
      cod_unid_med       CHAR(3),
      qtd_item           DECIMAL(12,3),
      pre_unit           DECIMAL(17,6),
      val_liq_item       DECIMAL(15,2),
      pct_iss            DECIMAL(5,2),
      val_tot_iss        DECIMAL(15,2),
      des_texto          CHAR(120),
      num_nff            DECIMAL(6,0)
     ) WITH NO LOG;
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF

   WHENEVER ERROR STOP
 
END FUNCTION

#----------------------------#
FUNCTION pol0949_monta_relat()
#----------------------------#

   DECLARE cq_wnotalev CURSOR FOR
   SELECT *
      FROM wnotalev
   ORDER BY 1

   FOREACH cq_wnotalev INTO p_wnotalev.*

      LET p_wnotalev.num_nff = p_fat_nf_mestre_serv.nota_fiscal
      OUTPUT TO REPORT pol0949_relat(p_wnotalev.*)

   END FOREACH

   { imprimir as linhas que faltam para completar o corpo da nota}
   { somente se o numero de linhas da nota nao for multiplo de 8 }
   IF p_ies_termina_relat = TRUE THEN
      LET p_wnotalev.num_nff      = p_fat_nf_mestre_serv.nota_fiscal
      LET p_wnotalev.num_seq      = p_wnotalev.num_seq + 1
      LET p_wnotalev.ies_tip_info = 4
   
      OUTPUT TO REPORT pol0949_relat(p_wnotalev.*)
   END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION pol0949_busca_dados_duplicatas()
#-----------------------------------------#

   DEFINE p_fat_nf_duplicata RECORD LIKE fat_nf_duplicata.*,
          p_contador          SMALLINT

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT * 
   FROM fat_nf_duplicata
   WHERE empresa = p_cod_empresa
     AND trans_nota_fiscal = p_fat_nf_mestre_serv.trans_nota_fiscal
   ORDER BY empresa,
   					trans_nota_fiscal,
   					seq_duplicata,
            dat_vencto_sdesc

   FOREACH cq_duplic INTO p_fat_nf_duplicata.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1  
            LET p_nff.num_duplic1    = p_fat_nf_duplicata.trans_nota_fiscal
            LET p_nff.dig_duplic1    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd1 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic1    = p_fat_nf_duplicata.val_duplicata
         WHEN 2      
            LET p_nff.num_duplic2    = p_fat_nf_duplicata.trans_nota_fiscal
            LET p_nff.dig_duplic2    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd2 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic2    = p_fat_nf_duplicata.val_duplicata
         WHEN 3      
            LET p_nff.num_duplic3    = p_fat_nf_duplicata.trans_nota_fiscal
            LET p_nff.dig_duplic3    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd3 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic3    = p_fat_nf_duplicata.val_duplicata
         WHEN 4
            LET p_nff.num_duplic4    = p_fat_nf_duplicata.trans_nota_fiscal
            LET p_nff.dig_duplic4    = p_fat_nf_duplicata.seq_duplicata
            LET p_nff.dat_vencto_sd4 = p_fat_nf_duplicata.dat_vencto_sdesc
            LET p_nff.val_duplic4    = p_fat_nf_duplicata.val_duplicata
         OTHERWISE   
            EXIT FOREACH
      END CASE
   END FOREACH

END FUNCTION     

#-------------------------------------#
FUNCTION pol0949_carrega_end_cobranca()
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
FUNCTION pol0949_carrega_historico()
#----------------------------------#
DEFINE l_texto			CHAR(300)

  WHENEVER ERROR CONTINUE
	  DECLARE cq_texto CURSOR FOR SELECT des_texto  FROM fat_nf_texto_hist
															   WHERE empresa = p_cod_empresa
															     AND trans_nota_fiscal = p_fat_nf_mestre_serv.trans_nota_fiscal
		FOREACH cq_texto INTO  l_texto
			IF LENGTH(p_texto) = 0 THEN 
				LET p_texto = l_texto
			ELSE
				LET p_texto = p_texto CLIPPED,' ',l_texto CLIPPED
				IF LENGTH(p_texto) > 384 THEN
					EXIT FOREACH
				END IF 
			END IF 
		END FOREACH  
	WHENEVER ERROR STOP

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


#------------------------#
 FUNCTION limpa_retorno()#
#------------------------#

   INITIALIZE r_01, r_02, r_03, r_04, r_05, r_06, r_07, r_08, r_09, r_10,
              r_11, r_12, r_13 TO NULL 
              
END FUNCTION

#---------------------------#
 FUNCTION checa_parametros()#
#---------------------------#

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


#-----------------------#
 FUNCTION separa_texto()#
#-----------------------#
          
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

#----------------------#
FUNCTION quebra_texto()#
#----------------------#

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

#-------------------#
FUNCTION justifica()#
#-------------------#

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

#----------------------------------#
FUNCTION pol0949_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT

   LET p_ind = 1
   LET p_count = 0   
   LET p_nff.val_tot_servico    = 0

   DECLARE cq_fat_nf_item CURSOR FOR
   SELECT fat_nf_item.*
      FROM fat_nf_item, OUTER item
   WHERE fat_nf_item.empresa = p_cod_empresa
     AND fat_nf_item.trans_nota_fiscal	 = p_fat_nf_mestre_serv.trans_nota_fiscal
     AND item.cod_empresa = p_cod_empresa
     AND item.cod_item    = fat_nf_item.item

   FOREACH cq_fat_nf_item INTO p_fat_nf_item_serv.*

      CALL pol0949_item_cliente()

      LET pa_corpo_nff[p_ind].cod_item         = p_fat_nf_item_serv.item
      LET pa_corpo_nff[p_ind].cod_item_cliente = g_cod_item_cliente

      IF g_cod_item_cliente IS NULL THEN
         LET pa_corpo_nff[p_ind].den_item1   = p_fat_nf_item_serv.des_item[01,60]
         LET pa_corpo_nff[p_ind].den_item2   = p_fat_nf_item_serv.des_item[61,76]
      ELSE
         LET pa_corpo_nff[p_ind].den_item1   = g_cod_item_cliente
         LET pa_corpo_nff[p_ind].den_item2   = " "
      END IF

      LET pa_corpo_nff[p_ind].cod_unid_med   = p_fat_nf_item_serv.unid_medida
      LET pa_corpo_nff[p_ind].qtd_item       = p_fat_nf_item_serv.qtd_item

      LET pa_corpo_nff[p_ind].pre_unit       = p_fat_nf_item_serv.preco_unit_liquido

      LET pa_corpo_nff[p_ind].val_liq_item = p_fat_nf_item_serv.val_liquido_item

      LET pa_corpo_nff[p_ind].pct_iss      = p_pct_iss

      LET pa_corpo_nff[p_ind].val_tot_iss  = (p_pct_iss *
                                              p_fat_nf_item_serv.val_liquido_item)/100
                                             

      LET p_nff.val_tot_servico = p_nff.val_tot_servico + 
                                  p_fat_nf_item_serv.val_liquido_item

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1

   END FOREACH

END FUNCTION

#-----------------------------#
FUNCTION pol0949_item_cliente()
#-----------------------------#

   INITIALIZE g_cod_item_cliente TO NULL
 
   SELECT cod_item_cliente
      INTO g_cod_item_cliente    
   FROM cliente_item
   WHERE cod_empresa        = p_cod_empresa
     AND cod_cliente_matriz = p_fat_nf_mestre_serv.cliente
     AND cod_item           = p_fat_nf_item_serv.item

END FUNCTION

#--------------------------------------#
FUNCTION pol0949_verifica_ctr_unid_med()
#--------------------------------------#

   DEFINE p_ctr_unid_med   RECORD LIKE  ctr_unid_med.*

   WHENEVER ERROR CONTINUE
   SELECT ctr_unid_med.*
      INTO p_ctr_unid_med.*
   FROM ctr_unid_med
   WHERE cod_empresa = p_cod_empresa
     AND cod_cliente = p_fat_nf_mestre_serv.cliente
     AND cod_item    = p_fat_nf_item_serv.item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      RETURN p_ctr_unid_med.fat_conver,
             p_ctr_unid_med.cod_unid_med_cli
   ELSE
      RETURN 1, p_fat_nf_item_serv.cod_unid_med
   END IF

END FUNCTION

#------------------------------------------#
FUNCTION pol0949_carrega_tabela_temporaria()
#------------------------------------------#

   DEFINE i, j       SMALLINT,
          p_val_merc DECIMAL(15,2)   

   LET i             = 1
   LET p_num_seq     = 0
   LET p_qtd_lin_obs = 0
   LET p_val_merc    = 0

   FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}

      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      { grava o codigo do item }

      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotalev VALUES (p_num_seq,
                                   1,
                                   pa_corpo_nff[i].cod_item,
                                   pa_corpo_nff[i].den_item1,
                                   pa_corpo_nff[i].cod_unid_med,
                                   pa_corpo_nff[i].qtd_item,
                                   pa_corpo_nff[i].pre_unit,
                                   pa_corpo_nff[i].val_liq_item,
                                   pa_corpo_nff[i].pct_iss, 
                                   pa_corpo_nff[i].val_tot_iss, 
                                   "",
                                   p_nff.val_tot_nff)

      { insere segunda parte da denominacao do item, se esta existir }

      IF pa_corpo_nff[i].den_item2 IS NOT NULL AND 
         pa_corpo_nff[i].den_item2 <> "  " THEN
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotalev 
            VALUES (p_num_seq,2,"",pa_corpo_nff[i].den_item2,
                    "","","","","","","","")
      END IF

   END FOR

#  osvaldo

   LET p_des_texto = " "
   CALL pol0949_insert_array(p_des_texto)
   LET p_des_texto = " "
   CALL pol0949_insert_array(p_des_texto)
   
   DECLARE cq_obf_par CURSOR FOR
   SELECT * 
   FROM obf_par_fisc_compl
   WHERE empresa = p_cod_empresa
     AND nat_oper_grp_desp = p_fat_nf_mestre_serv.natureza_operacao
     AND tip_registro = "N" 

   FOREACH cq_obf_par INTO p_obf_par_fisc_compl.*

   IF p_obf_par_fisc_compl.campo = "retencao_csll" AND
      p_obf_par_fisc_compl.par_existencia = "S" THEN
      SELECT par_val
         INTO p_par_vdp_pad.par_val
      FROM par_vdp_pad
      WHERE cod_empresa = p_cod_empresa
        AND cod_parametro = "pct_csll"
      IF p_par_vdp_pad.par_val > 0 THEN
         LET p_des_texto = "Retencao CSLL   de ", 
             p_par_vdp_pad.par_val USING "#&.&&", " % ", " = ",
             p_fat_nf_mestre_serv.val_nota_fiscal * p_par_vdp_pad.par_val / 100
             USING "###,###,##&.&&"
         CALL pol0949_insert_array(p_des_texto)
      END IF
   ELSE
      IF p_obf_par_fisc_compl.campo = "retencao_pis" AND
         p_obf_par_fisc_compl.par_existencia = "S" THEN
         SELECT par_val
            INTO p_par_vdp_pad.par_val
         FROM par_vdp_pad
         WHERE cod_empresa = p_cod_empresa
           AND cod_parametro = "pct_pis_ret"
         IF p_par_vdp_pad.par_val > 0 THEN
            LET p_des_texto = "Retencao PIS    de ", 
                p_par_vdp_pad.par_val USING "#&.&&", " % ", " = ",
                p_fat_nf_mestre_serv.val_nota_fiscal * p_par_vdp_pad.par_val / 100
                USING "###,###,##&.&&"
            CALL pol0949_insert_array(p_des_texto)
         END IF
      ELSE
         IF p_obf_par_fisc_compl.campo = "retencao_cofins" AND
            p_obf_par_fisc_compl.par_existencia = "S" THEN
            SELECT par_val
               INTO p_par_vdp_pad.par_val
            FROM par_vdp_pad
            WHERE cod_empresa = p_cod_empresa
              AND cod_parametro = "pct_cofins_ret"
            IF p_par_vdp_pad.par_val > 0 THEN
               LET p_des_texto = "Retencao COFINS de ",
                   p_par_vdp_pad.par_val USING "#&.&&", " % ", " = ",
                   p_fat_nf_mestre_serv.val_nota_fiscal * p_par_vdp_pad.par_val / 100
                   USING "###,###,##&.&&"
               CALL pol0949_insert_array(p_des_texto)
            END IF
         END IF
      END IF
   END IF

   END FOREACH

#  osvaldo
END FUNCTION

#-----------------------------------------#
FUNCTION pol0949_calcula_total_de_paginas()
#-----------------------------------------#

   SELECT COUNT(*)
      INTO p_num_linhas
   FROM wnotalev

   { 10 = numero de linhas do corpo da nota fiscal }

   IF p_num_linhas IS NOT NULL AND 
      p_num_linhas > 0 THEN 
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 23 )) / 23
      IF (p_num_linhas MOD 23 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         LET p_ies_termina_relat = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0949_den_nat_oper()
#-----------------------------#

   DEFINE p_nat_operacao RECORD LIKE nat_operacao.*

   WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
      INTO p_nat_operacao.*
   FROM nat_operacao
   WHERE cod_nat_oper = p_fat_nf_mestre_serv.natureza_operacao
   WHENEVER ERROR STOP
 
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
FUNCTION pol0949_busca_cof_compl()
#------------------------------------#

   LET p_cod_fiscal_compl = 0
   LET p_nff.cod_fiscal   = 0

   WHENEVER ERROR CONTINUE

      SELECT cod_fiscal
         INTO p_nff.cod_fiscal
      FROM fiscal_par
      WHERE cod_empresa   = p_cod_empresa
        AND cod_nat_oper  = p_fat_nf_mestre_serv.natureza_operacao
        AND cod_uni_feder = p_cidades.cod_uni_feder
      IF sqlca.sqlcode <> 0 THEN
         LET p_nff.cod_fiscal = 0
      END IF   

      SELECT cod_fiscal_compl
         INTO p_cod_fiscal_compl
      FROM fiscal_par_compl
      WHERE cod_empresa=p_cod_empresa
        AND cod_nat_oper=p_fat_nf_mestre_serv.natureza_operacao
        AND cod_uni_feder=p_cidades.cod_uni_feder
      IF sqlca.sqlcode <> 0 THEN
         LET p_cod_fiscal_compl = 0
      END IF   

   WHENEVER ERROR STOP

END FUNCTION

#------------------------------------#
FUNCTION pol0949_busca_dados_empresa()            
#------------------------------------#

   INITIALIZE p_empresa.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT empresa.*
      INTO p_empresa.*
   FROM empresa
   WHERE cod_empresa = p_cod_empresa

   WHENEVER ERROR STOP

END FUNCTION

#-----------------------------#
FUNCTION pol0949_den_cnd_pgto()
#-----------------------------#

   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(05,3)

   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,pct_desp_finan
      INTO p_den_cnd_pgto,p_pct_desp_finan
   FROM cond_pgto
   WHERE cod_cnd_pgto = p_fat_nf_mestre_serv.cond_pagto
   WHENEVER ERROR STOP

   RETURN p_den_cnd_pgto

END FUNCTION 

#---------------------------------------------------#
FUNCTION pol0949_busca_dados_clientes(p_cod_cliente)
#---------------------------------------------------#

   DEFINE p_cod_cliente      LIKE clientes.cod_cliente,
          p_aux_nom_cliente  LIKE clientes.nom_cliente

   INITIALIZE p_clientes.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT *
      INTO p_clientes.*
   FROM clientes
   WHERE cod_cliente = p_fat_nf_mestre_serv.cliente
   WHENEVER ERROR STOP

END FUNCTION

#--------------------------------#
FUNCTION pol0949_busca_nome_pais()                   
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
 
#------------------------------------------------#
FUNCTION pol0949_busca_dados_cidades(p_cod_cidade)
#------------------------------------------------#

   DEFINE p_cod_cidade LIKE cidades.cod_cidade

   INITIALIZE p_cidades.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
      INTO p_cidades.*
   FROM cidades
   WHERE cod_cidade = p_cod_cidade
   WHENEVER ERROR STOP

END FUNCTION

#----------------------------------------#
FUNCTION pol0949_insert_array(p_des_texto)
#----------------------------------------#

   DEFINE p_des_texto CHAR(120)

   LET p_num_seq = p_num_seq + 1
   
   # No corpo da Nf. tem espaco para imprimir toda a OBS, nao precisa
   # quebrar em partes.

   INSERT INTO wnotalev
      VALUES (p_num_seq,3,"","","","","","","","", 
              p_des_texto,"")
	
END FUNCTION 

#------------------------------#
REPORT pol0949_relat(p_wnotalev)
#------------------------------#

   DEFINE i         SMALLINT,
          l_nulo    CHAR(10),
          p_contt   SMALLINT,
          l_tex_1, l_tex_2, l_tex_3, l_tex_4, l_tex_5, l_tex_6, l_tex_7, l_tex_8 CHAR(48) 

   DEFINE p_wnotalev  
          RECORD
             num_seq             SMALLINT,
             ies_tip_info        SMALLINT,
             cod_item            LIKE fat_nf_item.item,
             den_item            CHAR(060),
             cod_unid_med        LIKE fat_nf_item.unid_medida,
             qtd_item            LIKE fat_nf_item.qtd_item,
             pre_unit            LIKE fat_nf_item.preco_unit_bruto,
             val_liq_item        LIKE fat_nf_item.preco_unit_liquido,
             pct_iss             LIKE servico_par.pct_iss,
             val_tot_iss         LIKE fat_nf_mestre.val_nota_fiscal,
             des_texto           CHAR(120),
             num_nff             LIKE fat_nf_mestre.nota_fiscal
          END RECORD

   DEFINE p_for                  SMALLINT,
          p_sal                  SMALLINT,
          p_des_folha            CHAR(100) 

   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
         	PAGE   LENGTH  66

   ORDER EXTERNAL BY p_wnotalev.num_nff,
                     p_wnotalev.num_seq

   FORMAT

   PAGE HEADER
      LET p_num_pagina = p_num_pagina + 1
      PRINT COLUMN 001,p_6lpp, p_descomprime,
            COLUMN 129, p_nff.num_nff USING "&&&&&&"
  
      SKIP 5 LINES           
      IF p_cod_empresa = "02" THEN
         PRINT
         #PRINT COLUMN 054, "FONE: ", p_empresa.num_telefone,
         #      COLUMN 079, "FAX: ", p_empresa.num_fax
      ELSE
         PRINT 
      END IF 
			CALL substr(p_texto,48,8,'N')	RETURNING l_tex_1, l_tex_2, 
												           						l_tex_3, l_tex_4, 
												           						l_tex_5, l_tex_6, 
												           						l_tex_7, l_tex_8
      PRINT
      PRINT COLUMN 001, l_tex_1, #p_fat_nf_texto_hist.tex_hist_1_1[1,48],
            COLUMN 051, p_nff.den_nat_oper[1,24],
            COLUMN 076, p_nff.cod_fiscal      USING "&&&&",
            COLUMN 082, p_nff.ins_estadual_trib
      PRINT COLUMN 001, l_tex_2 #p_fat_nf_texto_hist.tex_hist_2_1[1,48]
      PRINT COLUMN 001, l_tex_3 #p_fat_nf_texto_hist.tex_hist_3_1[1,48]
      PRINT COLUMN 001, l_tex_4, #p_fat_nf_texto_hist.tex_hist_4_1[1,48],
            COLUMN 052, p_nff.nom_destinatario,
            COLUMN 101, p_nff.num_cgc_cpf,
            COLUMN 122, p_nff.dat_emissao           USING "dd/mm/yyyy"
      PRINT COLUMN 001, l_tex_5 #p_fat_nf_texto_hist.tex_hist_1_2[1,48]
      PRINT COLUMN 001, l_tex_6, # p_fat_nf_texto_hist.tex_hist_2_2[1,48],
            COLUMN 052, p_nff.end_destinatario,
            COLUMN 089, p_nff.den_bairro[1,17], 
            COLUMN 109, p_nff.cod_cep,
            COLUMN 122, TODAY                       USING "dd/mm/yyyy"
      PRINT COLUMN 001, l_tex_7 # p_fat_nf_texto_hist.tex_hist_3_2[1,48]
      PRINT COLUMN 001, l_tex_8, #p_fat_nf_texto_hist.tex_hist_4_2[1,48],
            COLUMN 052, p_nff.den_cidade, 
            COLUMN 080, p_nff.num_telefone,
            COLUMN 099, p_nff.cod_uni_feder,
            COLUMN 102, p_nff.ins_estadual,
            COLUMN 122, TIME 
      SKIP 3 LINES

      IF p_nff.val_duplic2 > 0 THEN
         PRINT COLUMN 001, p_comprime,
               COLUMN 090, p_nff.num_nff            USING "&&&&&&",
               COLUMN 105, p_nff.dat_vencto_sd1     USING "dd/mm/yyyy",   
               COLUMN 143, p_nff.val_duplic1        USING "###,##&.&&", 
               COLUMN 160, p_nff.num_nff            USING "&&&&&&", 
               COLUMN 174, p_nff.dat_vencto_sd2     USING "dd/mm/yyyy",   
               COLUMN 214, p_nff.val_duplic2        USING "###,##&.&&"
         PRINT COLUMN 090, p_nff.num_nff            USING "&&&&&&",
               COLUMN 105, p_nff.dat_vencto_sd3     USING "dd/mm/yyyy",   
               COLUMN 143, p_nff.val_duplic3        USING "###,##&.&&", 
               COLUMN 160, p_nff.num_nff            USING "&&&&&&", 
               COLUMN 174, p_nff.dat_vencto_sd4     USING "dd/mm/yyyy",
               COLUMN 214, p_nff.val_duplic4        USING "###,##&.&&"
      ELSE 
         PRINT COLUMN 001, p_comprime,
               COLUMN 090, p_nff.num_nff            USING "&&&&&&",
               COLUMN 105, p_nff.dat_vencto_sd1     USING "dd/mm/yyyy",
               COLUMN 145, p_nff.val_duplic1        USING "###,##&.&&"
         PRINT 
      END IF                 

  {30}SKIP 3 LINES

   BEFORE GROUP OF p_wnotalev.num_nff
      SKIP TO TOP OF PAGE

   ON EVERY ROW

      CASE
         WHEN p_wnotalev.ies_tip_info = 1             
            PRINT COLUMN 001, p_wnotalev.cod_item, 
                  COLUMN 027, p_wnotalev.den_item,
                  COLUMN 123, p_wnotalev.cod_unid_med,                        
                  COLUMN 130, p_wnotalev.qtd_item       USING "####&.&&&",
                  COLUMN 150, p_wnotalev.pre_unit       USING "##,##&.&&",
                  COLUMN 174, p_wnotalev.val_liq_item   USING "#,###,##&.&&",
                  COLUMN 188, p_wnotalev.pct_iss        USING "###.&&",
                  COLUMN 213, p_wnotalev.val_tot_iss    USING "#,###,##&.&&" 
            LET p_linhas_print = p_linhas_print + 1 

         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 030, p_wnotalev.den_item 
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 3
            PRINT COLUMN 030, p_wnotalev.des_texto 
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 4
            WHILE TRUE
               IF p_linhas_print < 23 THEN 
                  PRINT
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF          
            END WHILE
      END CASE

      IF p_linhas_print = 23  THEN { nr. de linhas do corpo da nota }
         SKIP 1 LINES  
         IF p_num_pagina = p_tot_paginas THEN 
            PRINT
            PRINT COLUMN 001, p_descomprime
            PRINT COLUMN 001, p_nff.val_tot_base_iss USING "###,###,##&.&&",
                  COLUMN 015, p_nff.val_tot_iss USING "####,###,##&.&&",
                  COLUMN 070, p_nff.val_tot_servico USING "###,###,###,##&.&&"
            SKIP 1 LINES
            PRINT COLUMN 070, p_nff.val_tot_nff USING "###,###,###,##&.&&"
            SKIP 10 LINES 
            PRINT COLUMN 117, p_nff.num_nff  USING "&&&&&&" 
            LET p_linhas_print = 0
            LET p_num_pagina = 0
         ELSE
            PRINT
            PRINT
            PRINT COLUMN 001, p_descomprime, 
                  COLUMN 003, "**************",
                  COLUMN 019, "**************",
                  COLUMN 036, "**************",
                  COLUMN 054, "**************",
                  COLUMN 075, "**************"
            PRINT
            PRINT COLUMN 002, "**************", 
                  COLUMN 018, "**************",
                  COLUMN 035, "**************",
                  COLUMN 053, "**************",
                  COLUMN 074, "**************"
            SKIP 10 LINES
            PRINT COLUMN 117, p_nff.num_nff  USING "&&&&&&" 
            LET p_linhas_print = 0
            SKIP TO TOP OF PAGE
         END IF
      END IF

END REPORT

#-----------------------#
 FUNCTION pol0949_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#------------------------------- FIM DE PROGRAMA ------------------------------#
