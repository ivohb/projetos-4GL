#----------------------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                                      #
# PROGRAMA: pol0708                                                                #
# MODULOS.: pol0708  - LOG0010 - LOG0040 - LOG0050 - LOG0060                       #
#           LOG0280  - LOG0380 - LOG1300 - LOG1400                                 #
# OBJETIVO: IMPRESSAO DAS NOTAS FISCAIS FATURAS - PRODUTO-LATICÍNIOS TIROLEZ LTDA  #
# AUTOR...: LUCIANA TORRENS WAGNER                                                 #
# DATA....: 26/12/2007                                                             #
# ALTERADO: 08/01/2008 por Ana Paula - versão 37                                   #
# OBSERVACAO: mudança no layout da nota fiscal para empresas 02,03 e 04            #
# 17/02/09 - imprimir todos os códigos fiscais da wfat_item_fiscal                 #
#----------------------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_msg                    CHAR(300),
          p_cod_nat_oper           INTEGER,
          p_ies_impressao          CHAR(01),
          comando                  CHAR(80),
          p_caminho                CHAR(80),
          p_caminho_relat          CHAR(100),
          p_caminho_etiq           CHAR(100),
          p_cod_fiscal             LIKE nf_mestre.cod_fiscal,
          p_cod_fiscal_compl       DECIMAL(1,0),
          p_campo_pis              CHAR(30),
          p_campo_cofins           CHAR(30),
          m_total_desc             DECIMAL(10,2),
          p_tip_info               SMALLINT,
          p_linha                  SMALLINT,
          p_nota_imp               SMALLINT,
          p_cods_fisc              CHAR(15),
          p_txt_fisc               CHAR(10)

   DEFINE p_texto1               CHAR(75), 
          p_texto2               CHAR(75) 
          
   DEFINE p_versao                 CHAR(18)

   DEFINE g_ies_ambiente           CHAR(01)

   ### VARIAVEIS MODULARES
   DEFINE m_num_seq               SMALLINT,
          m_status_pular          SMALLINT,
          m_qtd_lin_obs           SMALLINT,
          m_qtd_lin_obs_tab       SMALLINT,
          m_hora_status           CHAR(08),
          m_data_status           DATE

   DEFINE m_cod_fiscal_compl      INTEGER ,
          m_ser_nff               CHAR(02),
          m_ies_emite_dupl        LIKE cond_pgto.ies_emite_dupl,
          m_cod_fiscal_item       INTEGER,
          # m_cod_nat_oper        CHAR(04), 
          m_cod_nat_oper          LIKE nat_operacao.cod_nat_oper,
          m_cod_fiscal            CHAR(15)

   DEFINE m_ies_reimp             CHAR(01),
          m_num_nff_ini           LIKE nf_mestre.num_nff,
          m_num_nff_fim           LIKE nf_mestre.num_nff,
          m_ind                   SMALLINT,
          m_ies_origem            LIKE wfat_mestre.ies_origem,
          m_ies_tipo              LIKE cond_pgto.ies_tipo,
          m_dat_saida             DATE,
          m_des_nr_pedido         CHAR(600),
          m_des_nr_ped_cli        CHAR(600),
          m_des_nr_om             CHAR(600),
          m_des_nff_consig        CHAR(120),
          m_cont_dados            SMALLINT,
          m_qtd_linhas_dispon     INTEGER
          
   DEFINE mr_wfat_mestre          RECORD LIKE wfat_mestre.*,
          mr_wfat_item            RECORD LIKE wfat_item.*,
          mr_wfat_item_fiscal     RECORD LIKE wfat_item_fiscal.*,
          mr_wfat_historico       RECORD LIKE wfat_historico.*,
          mr_cidades              RECORD LIKE cidades.*,
          mr_empresa              RECORD LIKE empresa.*,
          mr_embalagem            RECORD LIKE embalagem.*,
          mr_clientes             RECORD LIKE clientes.*,
          mr_paises               RECORD LIKE paises.*,
          mr_uni_feder            RECORD LIKE uni_feder.*,
          mr_transport            RECORD LIKE clientes.*,
          mr_ped_itens_texto      RECORD LIKE ped_itens_texto.*,
          mr_fator_cv_unid        RECORD LIKE fator_cv_unid.*,
          mr_subst_trib_uf        RECORD LIKE subst_trib_uf.*,
          mr_nat_operacao         RECORD LIKE nat_operacao.*,
          mr_par_vdp_pad          RECORD LIKE par_vdp_pad.*

   DEFINE mr_cli_end_cobr         RECORD
          cod_cliente             LIKE cli_end_cob.cod_cliente,
          end_cobr                LIKE cli_end_cob.end_cobr,
          den_bairro              LIKE cli_end_cob.den_bairro,
          cod_cidade_cob          LIKE cli_end_cob.cod_cidade_cob,
          cod_cep                 LIKE cli_end_cob.cod_cep,
          num_cgc_cob             LIKE  clientes.num_cgc_cpf,
          ins_estadual_cob        LIKE clientes.ins_estadual
                                  END RECORD

   DEFINE mr_nff                  RECORD
             num_nff              LIKE wfat_mestre.num_nff,
             den_nat_oper         LIKE nat_operacao.den_nat_oper,
             cod_fiscal           LIKE wfat_mestre.cod_fiscal,
             cod_fiscal1          LIKE wfat_mestre.cod_fiscal,
             den_cod_fiscal       LIKE codigo_fiscal.den_cod_fiscal,
             #cod_fiscal          LIKE wfat_mestre.cod_fiscal,
             ins_estadual_trib    LIKE subst_trib_uf.ins_estadual,
             ins_estadual_emp  	  LIKE empresa.ins_estadual,
             den_cod_fiscal1      LIKE codigo_fiscal.den_cod_fiscal,
             den_cod_fiscal2      LIKE codigo_fiscal.den_cod_fiscal,
             dat_emissao     	    LIKE wfat_mestre.dat_emissao,
             nom_destinatario	    LIKE clientes.nom_cliente,
             num_cgc_cpf    	    LIKE clientes.num_cgc_cpf,
             dat_saida            LIKE wfat_mestre.dat_emissao,
             end_destinatario 	  LIKE clientes.end_cliente,
             den_bairro      	    LIKE clientes.den_bairro,
             cod_cep         	    LIKE clientes.cod_cep,
             den_cidade           LIKE cidades.den_cidade,
             num_telefone         LIKE clientes.num_telefone,
             cod_uni_feder        LIKE cidades.cod_uni_feder,
             ins_estadual         LIKE clientes.ins_estadual,
             hora_nf              DATETIME HOUR TO MINUTE,
             cod_cliente          LIKE clientes.cod_cliente,
             den_pais             LIKE paises.den_pais,

             num_duplic1          LIKE wfat_duplic.num_duplicata,
             dig_duplic1          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd1       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd1       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic1          LIKE wfat_duplic.val_duplic,

             num_duplic2  	      LIKE wfat_duplic.num_duplicata,
             dig_duplic2          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd2       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd2       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic2          LIKE wfat_duplic.val_duplic,

             num_duplic3          LIKE wfat_duplic.num_duplicata,
             dig_duplic3          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd3       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd3       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic3          LIKE wfat_duplic.val_duplic,

             num_duplic4          LIKE wfat_duplic.num_duplicata,
             dig_duplic4          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd4       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd4       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic4          LIKE wfat_duplic.val_duplic,

             num_duplic5          LIKE wfat_duplic.num_duplicata,
             dig_duplic5          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd5       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd5       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic5          LIKE wfat_duplic.val_duplic,

             num_duplic6          LIKE wfat_duplic.num_duplicata,
             dig_duplic6          LIKE wfat_duplic.dig_duplicata,
             dat_vencto_sd6       LIKE wfat_duplic.dat_vencto_sd,
             dat_vencto_cd6       LIKE wfat_duplic.dat_vencto_cd,
             val_duplic6          LIKE wfat_duplic.val_duplic,

             end_cob_cli          LIKE cli_end_cob.end_cobr,
             cod_uni_feder_cobr   LIKE cidades.cod_uni_feder,
             den_cidade_cob       LIKE cidades.den_cidade,
             den_bairro_cob       LIKE cli_end_cob.den_bairro,
             cod_cep_cob          LIKE cli_end_cob.cod_cep,
             num_cgc_cob          LIKE clientes.num_cgc_cpf,
             ins_estadual_cob     LIKE clientes.ins_estadual,

             val_tot_base_icm     LIKE wfat_mestre.val_tot_base_icm,
             val_tot_icm          LIKE wfat_mestre.val_tot_icm,
             val_tot_base_ret     LIKE wfat_mestre.val_tot_base_ret,
             val_tot_icm_ret      LIKE wfat_mestre.val_tot_icm_ret,
             val_tot_mercadoria   LIKE wfat_mestre.val_tot_mercadoria,
             val_frete_cli        LIKE wfat_mestre.val_frete_cli,
             val_seguro_cli       LIKE wfat_mestre.val_seguro_cli,
             val_tot_despesas     LIKE wfat_mestre.val_seguro_cli,
             val_tot_ipi          LIKE wfat_mestre.val_tot_ipi,
             val_tot_nff          LIKE wfat_mestre.val_tot_nff,

             nom_transpor         LIKE clientes.nom_cliente,
             ies_frete            LIKE wfat_mestre.ies_frete,
             num_placa            LIKE wfat_mestre.num_placa,
             cod_uni_feder_trans  LIKE cidades.cod_uni_feder,
             num_cgc_trans        LIKE clientes.num_cgc_cpf,
             end_transpor         LIKE clientes.end_cliente,
             den_cidade_trans     LIKE cidades.den_cidade,
             ins_estadual_trans   LIKE clientes.ins_estadual,
             qtd_volume           LIKE wfat_mestre.qtd_volumes1,
             des_especie          CHAR(038),
             den_marca            LIKE clientes.den_marca,
             num_pri_volume       DECIMAL(10,0),
             num_ult_volume       DECIMAL(10,0),
             pes_tot_bruto        LIKE wfat_mestre.pes_tot_bruto,
             pes_tot_liquido      LIKE wfat_mestre.pes_tot_liquido,
             tel_transpor         LIKE clientes.num_telefone,
             cod_repres           LIKE wfat_mestre.cod_repres,
             raz_social           LIKE representante.raz_social,
             cod_cnd_pgto         LIKE cond_pgto.cod_cnd_pgto,
             den_cnd_pgto         LIKE cond_pgto.den_cnd_pgto,
             num_pedido           LIKE wfat_item.num_pedido,
             num_suframa          LIKE clientes.num_suframa,
             num_om               LIKE wfat_item.num_om,
             num_pedido_repres    LIKE pedidos.num_pedido_repres,
             num_pedido_cli       LIKE pedidos.num_pedido_cli,
             nat_oper             LIKE nat_operacao.cod_nat_oper
          END RECORD

   DEFINE ma_corpo_nff            ARRAY[999]
          OF RECORD
             cod_item             LIKE wfat_item.cod_item,
             cod_item_cliente     LIKE cliente_item.cod_item_cliente,
             num_pedido           LIKE wfat_item.num_pedido,
             num_pedido_cli       LIKE pedidos.num_pedido_cli,
             pct_desc_total       DECIMAL(5,2),
             total_desc           DECIMAL(10,2),
             den_item             CHAR(060),
             m_den_item2          CHAR(023),
             pes_item             DECIMAL(15,4),
             cod_fiscal           LIKE wfat_item_fiscal.cod_fiscal,
             cod_cla_fisc         CHAR(10),
             cod_origem           LIKE wfat_mestre.cod_origem,
             cod_tributacao       LIKE wfat_mestre.cod_tributacao,
             cod_unid_med         LIKE wfat_item.cod_unid_med,
             qtd_item_cx          LIKE wfat_item.qtd_item,
             qtd_item_kg          LIKE wfat_item.qtd_item,
             pre_unit             LIKE wfat_item.pre_unit_nf,
             val_liq_item         LIKE wfat_item.val_liq_item,
             pct_icm              LIKE wfat_mestre.pct_icm,
             pct_ipi              LIKE wfat_item.pct_ipi,
             val_ipi              LIKE wfat_item.val_ipi,
             num_sequencia        LIKE nf_item.num_sequencia,
             num_om               LIKE wfat_item.num_om
          END RECORD

   DEFINE mr_tirolez
          RECORD
             num_seq              SMALLINT,
             ies_tip_info         SMALLINT,
             cod_item             LIKE wfat_item.cod_item,
             cod_item_cliente     LIKE cliente_item.cod_item_cliente,
             den_item             CHAR(060),
             pes_item             DECIMAL(15,4),
             cod_fiscal           LIKE wfat_item_fiscal.cod_fiscal,
             cod_cla_fisc         CHAR(10),
             cod_origem           LIKE wfat_mestre.cod_origem,
             cod_tributacao       LIKE wfat_mestre.cod_tributacao,
             cod_unid_med         LIKE wfat_item.cod_unid_med,
             qtd_item_cx          LIKE wfat_item.qtd_item,
             qtd_item_kg          LIKE wfat_item.qtd_item,
             pre_unit             LIKE wfat_item.pre_unit_nf,
             val_liq_item         LIKE wfat_item.val_liq_item,
             pct_icm              LIKE wfat_mestre.pct_icm,
             pct_ipi              LIKE wfat_item.pct_ipi,
             val_ipi              LIKE wfat_item.val_ipi,
             des_texto            CHAR(120),
             num_nff              LIKE wfat_mestre.num_nff ,
             #num_pedido          LIKE wfat_item.num_pedido,
             num_sequencia        LIKE nf_item.num_sequencia,
             pct_desc_total       DECIMAL(5,2)
          END RECORD

   DEFINE mr_consignat
          RECORD
             den_consignat        LIKE clientes.nom_cliente,
             end_consignat        LIKE clientes.end_cliente,
             den_bairro           LIKE clientes.den_bairro,
             den_cidade           LIKE cidades.den_cidade,
             cod_uni_feder        LIKE cidades.cod_uni_feder
          END RECORD

   DEFINE mr_end_entrega
          RECORD
             end_entrega          LIKE clientes.end_cliente,
             den_bairro           LIKE clientes.den_bairro,
             cod_cep              LIKE wfat_end_ent.cod_cep,
             num_cgc              LIKE wfat_end_ent.num_cgc,
             ins_estadual         LIKE wfat_end_ent.ins_estadual,
             den_cidade           LIKE cidades.den_cidade,
             cod_uni_feder        LIKE cidades.cod_uni_feder
          END RECORD

   DEFINE p_comprime,
          p_descomprime           CHAR(01),
          p_8lpp                  CHAR(02),
          p_6lpp                  CHAR(02)

   DEFINE ma_texto_ped_it         ARRAY[06]
          OF RECORD
             texto                CHAR(76)
          END RECORD

   DEFINE ma_array                ARRAY[20] OF
          RECORD
             den_cod_fiscal       LIKE codigo_fiscal.den_cod_fiscal,
             cod_fiscal           LIKE codigo_fiscal.cod_fiscal
          END RECORD

   DEFINE ma_n_trib               ARRAY[99]
          OF RECORD
             pct_icm              LIKE wfat_item_fiscal.pct_icm,
             val_base_icm         LIKE wfat_item_fiscal.val_base_icm,
             pct_desc_base_icm    LIKE wfat_item_fiscal.pct_desc_base_icm,
             val_icm              LIKE wfat_item_fiscal.val_icm
          END RECORD

   DEFINE ma_texto_obs            ARRAY[5]
          OF RECORD
             den_texto            CHAR(74)
          END RECORD

   DEFINE ma_pedido               ARRAY[50]
          OF RECORD
             pedido               LIKE wfat_item.num_pedido,
             ped_cli              LIKE pedidos.num_pedido_cli,
             num_om	              LIKE wfat_item.num_om
          END RECORD

   DEFINE m_num_linhas            SMALLINT,
          m_num_pagina            SMALLINT,
          m_tot_paginas           SMALLINT 

   DEFINE m_ies_lista             SMALLINT,
          m_ies_termina_relat     SMALLINT,
          m_linhas_print          SMALLINT

   DEFINE m_des_texto             CHAR(120),
          l_des_texto_1           CHAR(120),
          m_val_tot_ipi_acum      DECIMAL(15,3),
          m_for                   SMALLINT,
          m_sit_nff               CHAR(01),
          m_data                  DATE,
          m_hora                  CHAR(10),
          m_des_texto1            CHAR(30)

          
END GLOBALS

MAIN

   CALL log0180_conecta_usuario()
   LET p_versao = "POL0708-10.02.00"
   WHENEVER ERROR CONTINUE
   CALL log1400_isolation()
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("pol0708.iem") RETURNING comando
   OPTIONS
      HELP FILE comando

   CALL log001_acessa_usuario("VDP","LOGERP")
        RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0708_controle()
   END IF

END MAIN

#-------------------------#
FUNCTION pol0708_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0708") RETURNING comando
   OPEN WINDOW w_pol0708 AT 2,2 WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   #DISPLAY "( Última atualização: 17/02/2004     Hora: 16:00 h )" AT 19,02

   CALL log0010_close_window_screen()
   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 001
         MESSAGE ""
         CALL pol0708_inicializa_campos()
         IF log005_seguranca(p_user,"VDP","pol0708","CO") THEN
            IF pol0708_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
         HELP 002
         IF log005_seguranca(p_user,"VDP","pol0708","CO") THEN
            IF pol0708_imprime_nff() THEN
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0708_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 003
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0708
END FUNCTION

#-----------------------#
 FUNCTION pol0708_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-----------------------------------#
FUNCTION pol0708_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0708

   LET m_ies_reimp   = "N"
   LET m_num_nff_ini = 0
   LET m_num_nff_fim = 999999
   
   #LET m_ies_lista = FALSE
   LET m_ies_lista = TRUE
   LET m_data = TODAY
   LET m_hora = TIME

   INPUT m_ies_reimp,
         m_data,
         m_hora,
         m_num_nff_ini,
         m_num_nff_fim WITHOUT DEFAULTS
    FROM ies_reimp,
         data_nf,
         hora_nf,
         num_nff_ini,
         num_nff_fim
         
      AFTER FIELD ies_reimp
         IF m_ies_reimp IS NULL THEN
            ERROR " Campo de Preechimento Obrigatorio."
            NEXT FIELD ies_reimp
         END IF

      AFTER FIELD num_nff_ini
         IF m_ies_reimp = "S" THEN
            IF pol0708_verifica_nota(m_num_nff_ini) = FALSE THEN
               ERROR " Nota Fiscal nao existe na tabela wfat_mestre"
               NEXT FIELD num_nff_ini
            END IF
         END IF

      AFTER FIELD num_nff_fim
         IF m_ies_reimp = "S" THEN
            IF pol0708_verifica_nota(m_num_nff_fim) = FALSE THEN
               ERROR " Nota Fiscal nao existe na tabela wfat_mestre"
               NEXT FIELD num_nff_ini
            END IF
         END IF

      ON KEY (control-w)
         CASE
            WHEN INFIELD(ies_reimp)     CALL SHOWHELP(101)
            WHEN INFIELD(dat_saida)     CALL SHOWHELP(104)
            WHEN INFIELD(num_nff_ini)   CALL SHOWHELP(102)
            WHEN INFIELD(num_nff_fim)   CALL SHOWHELP(103)
            WHEN INFIELD(hora_saida)    CALL SHOWHELP(104)
        END CASE
   END INPUT

   CURRENT WINDOW IS w_pol0708

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE
END FUNCTION


#-----------------------------------------#
 FUNCTION pol0708_verifica_nota(p_num_nff)
#-----------------------------------------#
   DEFINE p_num_nff     LIKE wfat_mestre.num_nff

   SELECT num_nff
     FROM wfat_mestre
    WHERE cod_empresa  = p_cod_empresa
      AND num_nff      = p_num_nff
      AND ies_impr_nff = "R"

   IF SQLCA.sqlcode = 0 THEN
      RETURN TRUE
   END IF

   RETURN FALSE
 END FUNCTION


#----------------------------------#
FUNCTION pol0708_inicializa_campos()
#----------------------------------#
   INITIALIZE mr_nff         ,
              ma_corpo_nff    ,
              ma_n_trib       ,
              mr_end_entrega ,
              mr_consignat   ,
              mr_cidades     ,
              mr_embalagem   ,
              mr_clientes    ,
              mr_paises      ,
              mr_transport   ,
              mr_uni_feder   ,
              mr_ped_itens_texto,
              mr_subst_trib_uf  ,
              ma_texto_obs   ,
              ma_pedido,
              m_des_texto  TO NULL

   LET m_num_nff_ini        = 0
   LET m_num_nff_fim        = 999999

   LET m_qtd_lin_obs        = 0
   LET m_qtd_lin_obs_tab    = 0
   LET m_linhas_print       = 0
   LET m_tot_paginas        = 0
   LET m_val_tot_ipi_acum   = 0
   LET m_cod_fiscal_item    = 0 
   LET m_num_pagina         = 0 
  
   LET m_ies_termina_relat  = TRUE
   LET m_status_pular       = TRUE
   LET m_ies_reimp          = "N"
   LET m_des_nr_pedido      = ""
   LET m_des_nr_ped_cli     = ""
   LET m_des_nr_om          = ""
   LET m_des_nff_consig     = ""
   LET m_cod_fiscal         = ""

END FUNCTION

#----------------------------#
FUNCTION pol0708_imprime_nff()
#----------------------------#
DEFINE l_num_rel  DECIMAL(3,0),
       l_nom_rel  CHAR(80)

   IF log028_saida_relat(12,30) IS NOT NULL THEN
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
      IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "U" THEN
            START REPORT pol0708_relatorio TO PIPE p_nom_arquivo
         ELSE
            CALL log150_procura_caminho('LST') RETURNING p_caminho
            LET p_caminho_relat = p_caminho_relat CLIPPED, "pol0708.tmp"
            START REPORT pol0708_relatorio TO p_caminho_relat
         END IF
      ELSE
         SELECT nom_caminho 
           INTO p_caminho_relat
           FROM log_usu_dir_relat 
          WHERE empresa   = p_cod_empresa 
            AND usuario       = p_user
            AND sistema_fonte = 'VDP'
         IF SQLCA.sqlcode <> 0 OR 
            p_caminho_relat IS NULL THEN
            START REPORT pol0708_relatorio TO p_nom_arquivo    
         ELSE
            SELECT prx_num_rel
              INTO l_num_rel 
              FROM w_log0250
             WHERE cod_empresa = p_cod_empresa
               AND nom_usuario = p_user
#            LET l_nom_rel = 'pol0708.',l_num_rel CLIPPED,'.',p_user CLIPPED,'.','lst'   
            LET l_nom_rel = 'pol0708.',l_num_rel
            LET p_nom_arquivo = p_caminho_relat CLIPPED, l_nom_rel
            START REPORT pol0708_relatorio TO p_nom_arquivo   
         END IF    
      END IF
   ELSE
      START REPORT pol0708_relatorio TO p_nom_arquivo
   END IF
   
   CALL pol0708_busca_dados_empresa()

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_8lpp        = ascii 27, "0"
   LET p_6lpp        = ascii 27, "2"
   LET m_qtd_linhas_dispon = 20

   IF m_ies_reimp = "S" THEN
      LET m_sit_nff = "R"
   ELSE
      LET m_sit_nff = "N"
   END IF

###   LET p_nota_imp = FALSE
   
   DECLARE cq_wfat_mestre CURSOR WITH HOLD FOR
    SELECT *
      FROM wfat_mestre
     WHERE cod_empresa  = p_cod_empresa             
       AND num_nff     >= m_num_nff_ini
       AND num_nff     <= m_num_nff_fim
       AND ies_impr_nff = m_sit_nff
     ORDER BY num_nff

   FOREACH cq_wfat_mestre INTO mr_wfat_mestre.*

      DISPLAY mr_wfat_mestre.num_nff TO num_nff_proces 
      ## mostra nf em processam.

      CALL pol0708_cria_tabela_temporaria()

      INITIALIZE m_ser_nff,
                 m_cod_fiscal_compl TO NULL

      SELECT ser_nff
        INTO m_ser_nff
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = mr_wfat_mestre.num_nff

      SELECT cod_fiscal_compl
        INTO m_cod_fiscal_compl
        FROM nf_mestre_compl
       WHERE cod_empresa  = p_cod_empresa
         AND num_nff      = mr_wfat_mestre.num_nff
         AND ser_nff      = m_ser_nff

      LET mr_nff.num_nff    = mr_wfat_mestre.num_nff
      INITIALIZE p_cods_fisc TO NULL
      LET mr_nff.cod_fiscal = mr_wfat_mestre.cod_fiscal

      LET p_cods_fisc = mr_wfat_mestre.cod_fiscal
  
      DECLARE cq_codf CURSOR FOR
       SELECT UNIQUE cod_fiscal
         FROM wfat_item_fiscal
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = mr_wfat_mestre.num_nff

      FOREACH cq_codf INTO p_cod_fiscal

         IF p_cod_fiscal <> mr_nff.cod_fiscal THEN
            LET p_txt_fisc = p_cod_fiscal
            LET p_cods_fisc = p_cods_fisc CLIPPED,'/',p_txt_fisc CLIPPED
         END IF
          
      END FOREACH

      LET m_ies_origem  = mr_wfat_mestre.ies_origem

      CALL pol0708_busca_dados_subst_trib_uf()
      
      LET mr_nff.ins_estadual_trib = mr_subst_trib_uf.ins_estadual
      LET mr_nff.den_nat_oper      = pol0708_den_nat_oper()
      LET mr_nff.nat_oper          = mr_wfat_mestre.cod_nat_oper
      LET mr_nff.dat_emissao       = mr_wfat_mestre.dat_emissao

      CALL pol0708_busca_dados_clientes(mr_wfat_mestre.cod_cliente)
      
      LET mr_nff.nom_destinatario = mr_clientes.nom_cliente
      LET mr_nff.num_cgc_cpf      = mr_clientes.num_cgc_cpf
      LET mr_nff.end_destinatario = mr_clientes.end_cliente
      LET mr_nff.den_bairro       = mr_clientes.den_bairro
      LET mr_nff.cod_cep          = mr_clientes.cod_cep
      LET mr_nff.cod_cliente      = mr_clientes.cod_cliente

      CALL pol0708_busca_dados_cidades(mr_clientes.cod_cidade)
      
      LET mr_nff.den_cidade    = mr_cidades.den_cidade
      LET mr_nff.num_telefone  = mr_clientes.num_telefone
      LET mr_nff.cod_uni_feder = mr_cidades.cod_uni_feder
      LET mr_nff.ins_estadual  = mr_clientes.ins_estadual
      LET mr_nff.hora_nf       = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0708_busca_nome_pais()
      
      LET mr_nff.den_pais = mr_paises.den_pais

      CALL pol0708_busca_dados_duplicatas()

      CALL pol0708_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0708_carrega_corpo_nota() {corpo todo da nota}
      	
      CALL pol0708_grava_dados_historicos()
      
      CALL pol0708_trata_zona_franca()

      CALL pol0708_grava_historico_nf_pedido()

      CALL pol0708_grava_dados_end_entrega()
      
      CALL pol0708_msg_n_trib()

      CALL pol0708_grava_des_repres()

      CALL pol0708_grava_cond_pagto()

      CALL pol0708_msg_consig()

      CALL pol0708_imprime_ret_terc()

      #CALL pol0708_impr_duplic() atual

      CALL pol0708_grava_dados_consig(mr_wfat_mestre.cod_consig)
      #CALL pol0708_grava_dados_historicos()  {le wfat_historico}

      IF mr_nat_operacao.ies_tip_controle = "9" THEN
         CALL pol0708_carrega_msg_remessa()
      END IF

      CALL pol0708_grava_conta_ordem()

      LET mr_nff.val_tot_base_icm   = mr_wfat_mestre.val_tot_base_icm
      LET mr_nff.val_tot_icm        = mr_wfat_mestre.val_tot_icm
      LET mr_nff.val_tot_base_ret   = mr_wfat_mestre.val_tot_base_ret
      LET mr_nff.val_tot_icm_ret    = mr_wfat_mestre.val_tot_icm_ret
      LET mr_nff.val_tot_mercadoria = mr_wfat_mestre.val_tot_mercadoria + mr_wfat_mestre.val_desc_merc
      LET mr_nff.val_frete_cli      = mr_wfat_mestre.val_frete_cli
      LET mr_nff.val_seguro_cli     = mr_wfat_mestre.val_seguro_cli
      LET mr_nff.val_tot_despesas   = 0
      LET mr_nff.val_tot_ipi        = mr_wfat_mestre.val_tot_ipi
      LET mr_nff.val_tot_nff        = mr_wfat_mestre.val_tot_nff

      CALL pol0708_busca_dados_transport(mr_wfat_mestre.cod_transpor)
      CALL pol0708_busca_dados_cidades(mr_transport.cod_cidade)
      LET mr_nff.nom_transpor       = mr_transport.nom_cliente

      IF mr_wfat_mestre.ies_frete = 3 THEN
         LET mr_nff.ies_frete = 2
      ELSE
         LET mr_nff.ies_frete = 1
      END IF

      LET mr_nff.num_placa          = mr_wfat_mestre.num_placa
      LET mr_nff.num_cgc_trans      = mr_transport.num_cgc_cpf
      LET mr_nff.end_transpor       = mr_transport.end_cliente
      LET mr_nff.den_cidade_trans   = mr_cidades.den_cidade
      LET mr_nff.cod_uni_feder_trans= mr_cidades.cod_uni_feder
      LET mr_nff.ins_estadual_trans = mr_transport.ins_estadual
      LET mr_nff.den_marca          = ""

      LET mr_nff.num_pri_volume     = mr_nff.num_pri_volume
      LET mr_nff.qtd_volume         = mr_wfat_mestre.qtd_volumes1 +
                                      mr_wfat_mestre.qtd_volumes2 +
                                      mr_wfat_mestre.qtd_volumes3 +
                                      mr_wfat_mestre.qtd_volumes4 +
                                      mr_wfat_mestre.qtd_volumes5
      LET mr_nff.num_ult_volume     = mr_nff.num_pri_volume       +
                                      mr_nff.qtd_volume - 1
      LET mr_nff.pes_tot_bruto      = mr_wfat_mestre.pes_tot_bruto
      LET mr_nff.pes_tot_liquido    = mr_wfat_mestre.pes_tot_liquido

      LET mr_nff.cod_repres         = mr_wfat_mestre.cod_repres
      LET mr_nff.raz_social         = pol0708_representante()
      LET mr_nff.num_suframa        = mr_clientes.num_suframa
      LET mr_nff.des_especie        = pol0708_especie()
      LET mr_nff.cod_cnd_pgto       = mr_wfat_mestre.cod_cnd_pgto
      LET mr_nff.den_cnd_pgto       = pol0708_den_cnd_pgto()


      IF m_sit_nff = 'N' THEN  
         CALL pol0708_update_pedidos_status()
      END IF 
      #CALL pol0708_imprime_pedido()
      
      CALL pol0708_msg_nr_pedidos_om()
      
      LET m_ies_lista = TRUE

#      IF m_total_desc > 0 THEN
#         LET m_des_texto = NULL
#         LET m_des_texto = 'TOTAL DESC: ', m_total_desc
#         LET m_num_seq = m_num_seq + 1
#         INSERT INTO wtirolez
#            VALUES (m_num_seq,4,"","","","","","","","","","","","","","","","",
#                 m_des_texto,"","","")
#      END IF

      CALL pol0708_busca_dados_pedido()

      IF mr_nff.num_pedido_cli IS NOT NULL THEN
         LET m_des_texto = NULL
         LET m_des_texto = "Pedido Cliente: ", mr_nff.num_pedido_cli
         LET m_num_seq = m_num_seq + 1
         INSERT INTO wtirolez
            VALUES (m_num_seq,4,"","","","","","","","","","","","","","","","",
                    m_des_texto,"","","")
         INITIALIZE  mr_nff.num_pedido_cli TO NULL          
      END IF 
      
      CALL pol0708_texto_nat_oper()
      
      CALL pol0708_calcula_total_de_paginas()
      CALL pol0708_monta_relat()

      # marca nf que ja foi impressa #
      UPDATE wfat_mestre
         SET ies_impr_nff = "R"
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = mr_wfat_mestre.num_nff

###      LET p_nota_imp = TRUE 
      
      CALL pol0708_inicializa_campos()

   END FOREACH

   FINISH REPORT pol0708_relatorio

  IF m_ies_lista THEN
###    IF p_nota_imp THEN
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

#--------------------------------#
FUNCTION pol0708_texto_nat_oper()
#--------------------------------#

      DECLARE cq_cnp CURSOR FOR
       SELECT UNIQUE
              cod_nat_oper
         FROM wfat_item_fiscal
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = mr_wfat_mestre.num_nff

      FOREACH cq_cnp INTO p_cod_nat_oper

         CALL pol0708_pega_texto() 

          
      END FOREACH

END FUNCTION

#----------------------------#
FUNCTION pol0708_pega_texto()
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
      AND cod_uni_feder = mr_nff.cod_uni_feder
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

   IF p_cod_hist_1 IS NOT NULL THEN
      CALL pol0708_le_fiscal_hist(p_cod_hist_1)
   END IF
   
   IF p_cod_hist_2 IS NOT NULL THEN
      CALL pol0708_le_fiscal_hist(p_cod_hist_2)
   END IF

END FUNCTION

#-----------------------------------------#
FUNCTION pol0708_le_fiscal_hist(p_cod_hist)
#-----------------------------------------#

   DEFINE p_txt_1      LIKE fiscal_hist.tex_hist_1,
          p_txt_2      LIKE fiscal_hist.tex_hist_2,
          p_txt_3      LIKE fiscal_hist.tex_hist_3,
          p_txt_4      LIKE fiscal_hist.tex_hist_4,
          p_cod_hist   LIKE fiscal_hist.cod_hist

   SELECT cod_hist
     FROM txt_nat_oper_912
    WHERE cod_hist = p_cod_hist
   
   IF STATUS = 0 THEN
      RETURN
   END IF

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

   IF sqlca.sqlcode <> 0 THEN
      RETURN
   END IF

   INSERT INTO txt_nat_oper_912
     VALUES(p_cod_hist, p_txt_1, p_txt_2, p_txt_3, p_txt_4 )
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INCLUSÃO","txt_nat_oper_912")       
   END IF
   
   IF LENGTH(p_txt_1) > 0 THEN
      CALL pol0708_insert_array(p_txt_1, 4)
   END IF
   
   IF LENGTH(p_txt_2) > 0 THEN
      CALL pol0708_insert_array(p_txt_2, 4)
   END IF

   IF LENGTH(p_txt_3) > 0 THEN
      CALL pol0708_insert_array(p_txt_3, 4)
   END IF

   IF LENGTH(p_txt_4) > 0 THEN
      CALL pol0708_insert_array(p_txt_4, 4)
   END IF
   
END FUNCTION

#------------------------------------------#
 FUNCTION pol0708_update_pedidos_status()
#------------------------------------------#

   IF m_ies_reimp = 'N' THEN

      LET m_hora_status = TIME
      LET m_data_status = TODAY
     
      UPDATE tirolez_pedidos_status
         SET ies_sit_fat     = 'S',
             dat_fat         = m_data_status,
             hor_fat         = m_hora_status,
             nom_usuario_fat = p_user
       WHERE cod_empresa     = p_cod_empresa
         AND num_pedido      = mr_nff.num_pedido
   
   END IF
END FUNCTION 

#-----------------------------#
FUNCTION pol0708_n_tributacao()
#-----------------------------#

   FOR m_for = 1 TO 99
      IF ma_n_trib[m_for].pct_icm IS NULL THEN
         LET ma_n_trib[m_for].pct_icm = ma_corpo_nff[m_ind].pct_icm
         LET ma_n_trib[m_for].val_base_icm = mr_wfat_item_fiscal.val_base_icm
         LET ma_n_trib[m_for].val_icm = mr_wfat_item_fiscal.val_icm
         EXIT FOR
      ELSE
         IF ma_n_trib[m_for].pct_icm = ma_corpo_nff[m_ind].pct_icm THEN
            LET ma_n_trib[m_for].val_base_icm = ma_n_trib[m_for].val_base_icm +
                                                mr_wfat_item_fiscal.val_base_icm
            LET ma_n_trib[m_for].val_icm      = ma_n_trib[m_for].val_icm +
                                                mr_wfat_item_fiscal.val_icm
            EXIT FOR
         END IF
      END IF
   END FOR
   
END FUNCTION

#---------------------------#
FUNCTION pol0708_msg_n_trib()
#---------------------------#
   IF ma_n_trib[2].pct_icm IS NULL THEN   # Existe somente uma tributacao
      RETURN
   END IF

   LET m_des_texto = "ICMS     BASE CALC.     BASE RED.ICM     VAL.ICM"
   CALL pol0708_insert_array(m_des_texto,3)

   FOR m_for = 1 TO 99
      IF ma_n_trib[m_for].pct_icm IS NULL THEN
         EXIT FOR
      END IF 
      LET m_des_texto = ma_n_trib[m_for].pct_icm           USING "#&.&&",
                        " ",
                        ma_n_trib[m_for].val_base_icm      USING "####,##&.&&",
                        "           ",
                        ma_n_trib[m_for].pct_desc_base_icm USING "#&.&&",
                        "   ",
                        ma_n_trib[m_for].val_icm           USING "#,###,##&.&&"

      CALL pol0708_insert_array(m_des_texto,3)
   END FOR

END FUNCTION

#----------------------------------#
FUNCTION pol0708_msg_nr_pedidos_om()
#----------------------------------#
   DEFINE l_texto_1   CHAR(120),
          l_texto_2   CHAR(120),
          l_texto_3   CHAR(120),
          l_texto_4   CHAR(120),
          l_texto_5   CHAR(120)

{
   IF m_des_nr_pedido IS NOT NULL AND
      m_des_nr_pedido <> " "      AND
      m_des_nr_om     IS NOT NULL AND
      m_des_nr_om     <> " "     THEN
      LET m_des_nr_pedido  = "NR. PEDIDO: ",
                              m_des_nr_pedido,' / OM', m_des_nr_om
      LET l_texto_1 = m_des_nr_pedido[1,120]  #, ' / OM', m_des_nr_om[1,120]
      LET l_texto_2 = m_des_nr_pedido[121,240]#, ' / OM', m_des_nr_om[121,240]
      LET l_texto_3 = m_des_nr_pedido[241,360]#, ' / OM', m_des_nr_om[241,360]
      LET l_texto_4 = m_des_nr_pedido[361,480]#, ' / OM', m_des_nr_om[361,480]
      LET l_texto_5 = m_des_nr_pedido[481,600]#, ' / OM', m_des_nr_om[481,600]
   ELSE
      IF m_des_nr_pedido IS NOT NULL AND
         m_des_nr_pedido <> " "     THEN
         LET m_des_nr_pedido  = "NR. PEDIDO: ",
                                 m_des_nr_pedido
         LET l_texto_1 = m_des_nr_pedido[1,120]
         LET l_texto_2 = m_des_nr_pedido[121,240]
         LET l_texto_3 = m_des_nr_pedido[241,360]
         LET l_texto_4 = m_des_nr_pedido[361,480]
         LET l_texto_5 = m_des_nr_pedido[481,600]
      END IF
   END IF
}
{
   IF m_des_nr_ped_cli IS NOT NULL AND
      m_des_nr_ped_cli <> " "      THEN
      LET m_des_nr_ped_cli = "NR. PEDIDO CLIENTE: ",
                              m_des_nr_ped_cli

      LET l_texto_1 = m_des_nr_ped_cli[1,120]
      LET l_texto_2 = m_des_nr_ped_cli[121,240]
      LET l_texto_3 = m_des_nr_ped_cli[241,360]
      LET l_texto_4 = m_des_nr_ped_cli[361,480]
      LET l_texto_5 = m_des_nr_ped_cli[481,600]

      IF LENGTH(l_texto_1) > 0 THEN
         CALL pol0708_insert_array(l_texto_1,4)
      END IF
      IF LENGTH(l_texto_2) > 0 THEN
         CALL pol0708_insert_array(l_texto_2,4)
      END IF
      IF LENGTH(l_texto_3) > 0 THEN
         CALL pol0708_insert_array(l_texto_3,4)
      END IF
      IF LENGTH(l_texto_4) > 0 THEN
         CALL pol0708_insert_array(l_texto_4,4)
      END IF
      IF LENGTH(l_texto_5) > 0 THEN
         CALL pol0708_insert_array(l_texto_5,4)
      END IF
   END IF
}
{
   IF m_des_nr_om IS NOT NULL AND
      m_des_nr_om <> " "      THEN
      LET m_des_nr_om  = "NR. ORDEM DE MONTAGEM: ",
                          m_des_nr_om

      LET l_texto_1 = m_des_nr_om[1,120]
      LET l_texto_2 = m_des_nr_om[121,240]
      LET l_texto_3 = m_des_nr_om[241,360]
      LET l_texto_4 = m_des_nr_om[361,480]
      LET l_texto_5 = m_des_nr_om[481,600]
   END IF
}

END FUNCTION

#---------------------------#
FUNCTION pol0708_msg_consig()
#---------------------------#
   DEFINE l_num_nff     LIKE wfat_mestre.num_nff,
          l_dat_emissao LIKE nf_mestre.dat_emissao

   DECLARE cq_consig CURSOR FOR
   SELECT UNIQUE a.num_nff_ref
     FROM nf_consig_ref a, nf_mestre b
    WHERE a.cod_empresa  = p_cod_empresa
      AND a.num_nff      = mr_wfat_mestre.num_nff
      AND a.cod_empresa  = b.cod_empresa
      AND a.num_nff      = b.num_nff
      AND a.ser_nf_refer = b.ser_nff

   FOREACH cq_consig INTO l_num_nff

      SELECT dat_emissao
        INTO l_dat_emissao
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = l_num_nff
         AND ser_nff     = m_ser_nff

      LET m_des_nff_consig = "NOTA FISCAL DE REMESSA: ",
                             l_num_nff USING "&&&&&&",
                             " DATA DE EMISSAO: ",l_dat_emissao #mr_wfat_mestre.dat_emissao
      CALL pol0708_insert_array(m_des_nff_consig,4)
   END FOREACH

END FUNCTION

#---------------------------------------#
FUNCTION pol0708_cria_tabela_temporaria()
#---------------------------------------#

   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN")
   LOCK TABLE wtirolez IN EXCLUSIVE MODE
   CALL log085_transacao("COMMIT")

   DROP TABLE wtirolez;
   CREATE TABLE wtirolez
   ( num_seq            SMALLINT,
     ies_tip_info       SMALLINT,
     cod_item           CHAR(015),
     cod_item_cliente   CHAR(030),
     den_item           CHAR(060),
     pes_item           DECIMAL(15,4),
     cod_fiscal         INTEGER,
     cod_cla_fisc       CHAR(10),
     cod_origem         DECIMAL(1,0),
     cod_tributacao     DECIMAL(2,0),
     cod_unid_med       CHAR(3),
     qtd_item_cx        DECIMAL(12,3),
     qtd_item_kg        DECIMAL(12,3),
     pre_unit           DECIMAL(17,6),
     val_liq_item       DECIMAL(15,2),
     pct_icm            DECIMAL(5,2),
     pct_ipi            DECIMAL(6,3),
     val_ipi            DECIMAL(15,2),
     des_texto          CHAR(120),
     num_nff            DECIMAL(6,0),
     #num_pedido         DECIMAL(6,0),
     num_sequencia      DECIMAL(05,0),
     pct_desc_total     DECIMAL(5,2)
   );
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF

  DELETE FROM wtirolez;

   DROP TABLE txt_nat_oper_912
   CREATE TEMP TABLE txt_nat_oper_912
     (
      cod_hist     INTEGER,
      texto1        CHAR(75),
      texto2        CHAR(75),
      texto3        CHAR(75),
      texto4        CHAR(75)
     );

   IF SQLCA.SQLCODE = -958 THEN 
      DELETE FROM txt_nat_oper_912
   END IF
   
   WHENEVER ERROR STOP

END FUNCTION

#----------------------------#
FUNCTION pol0708_monta_relat()
#----------------------------#
   DEFINE l_pedido          SMALLINT,
          p_tot_pct_desc    DECIMAL(5,2),
          p_tot_val_liq     DECIMAL(10,2), 
          p_num_nff         LIKE wfat_mestre.num_nff
   
   SELECT num_nff,
          SUM(pct_desc_total),
          SUM(val_liq_item)
     INTO p_num_nff,
           p_tot_pct_desc,
           p_tot_val_liq
     FROM wtirolez
     WHERE ies_tip_info <> 4
     GROUP BY num_nff       
    
    DECLARE cq_wtirolez CURSOR FOR
    SELECT *
      FROM wtirolez
     WHERE ies_tip_info <> 4
     ORDER BY 1

   FOREACH cq_wtirolez INTO mr_tirolez.*
      LET m_cont_dados = 0
      LET mr_tirolez.num_nff    = mr_wfat_mestre.num_nff
      # LET mr_tirolez.num_pedido = ma_corpo_nff[1].num_pedido
      
      SELECT COUNT(*)
  	    INTO m_cont_dados
    	  FROM wtirolez
    	 WHERE ies_tip_info <> 4
      OUTPUT TO REPORT pol0708_relatorio(mr_tirolez.*)
   END FOREACH
   #FREE cq_wtirolez

   IF m_ies_termina_relat = TRUE THEN
      LET mr_tirolez.num_nff      = mr_wfat_mestre.num_nff
      LET mr_tirolez.num_seq      = mr_tirolez.num_seq + 1
      LET mr_tirolez.ies_tip_info = 5

      OUTPUT TO REPORT pol0708_relatorio(mr_tirolez.*)
   END IF
END FUNCTION

#---------------------------------------#
FUNCTION pol0708_busca_dados_duplicatas()
#---------------------------------------#
   DEFINE p_wfat_duplic       RECORD LIKE wfat_duplic.*,
          p_contador          SMALLINT

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT *
     FROM wfat_duplic
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = mr_wfat_mestre.num_nff
    ORDER BY cod_empresa,
             num_duplicata,
             dig_duplicata,
             dat_vencto_sd

   FOREACH cq_duplic INTO p_wfat_duplic.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1
            LET mr_nff.num_duplic1    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic1    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd1 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd1 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic1    = p_wfat_duplic.val_duplic
         WHEN 2
            LET mr_nff.num_duplic2    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic2    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd2 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd2 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic2    = p_wfat_duplic.val_duplic
         WHEN 3
            LET mr_nff.num_duplic3    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic3    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd3 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd3 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic3    = p_wfat_duplic.val_duplic
         WHEN 4
            LET mr_nff.num_duplic4    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic4    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd4 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd4 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic4    = p_wfat_duplic.val_duplic
      {   WHEN 5
            LET mr_nff.num_duplic5    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic5    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd5 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd5 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic5    = p_wfat_duplic.val_duplic
         WHEN 6
            LET mr_nff.num_duplic6    = p_wfat_duplic.num_duplicata
            LET mr_nff.dig_duplic6    = p_wfat_duplic.dig_duplicata
            LET mr_nff.dat_vencto_sd6 = p_wfat_duplic.dat_vencto_sd
            LET mr_nff.dat_vencto_cd6 = p_wfat_duplic.dat_vencto_cd
            LET mr_nff.val_duplic6    = p_wfat_duplic.val_duplic
   }      OTHERWISE
            EXIT FOREACH
      END CASE
   END FOREACH
END FUNCTION

#-----------------------------#
FUNCTION pol0708_impr_duplic()
#-----------------------------#
  DEFINE l_dat_vencto_sd   LIKE wfat_duplic.dat_vencto_sd,
         l_val_duplic      LIKE wfat_duplic.val_duplic,
         l_num_duplicata   LIKE wfat_duplic.num_duplicata,
         l_dig_duplicata   LIKE wfat_duplic.dig_duplicata,
         l_for             SMALLINT

   LET l_for = 0

   DECLARE cq_duplic2 CURSOR FOR
    SELECT dat_vencto_sd,
           val_duplic,
           num_duplicata,
           dig_duplicata
      FROM wfat_duplic
     WHERE cod_empresa    = p_cod_empresa
       AND num_nff        = mr_wfat_mestre.num_nff
       AND dig_duplicata  > 4

   FOREACH cq_duplic2 INTO l_dat_vencto_sd,
                           l_val_duplic,
                           l_num_duplicata,
                           l_dig_duplicata
      IF l_for = 0 THEN
         LET l_for             = 1
         LET m_num_seq         = m_num_seq + 1
         LET m_qtd_lin_obs     = m_qtd_lin_obs + 1
         LET m_qtd_lin_obs_tab = m_qtd_lin_obs_tab + 1
         LET m_des_texto       =
             "COMPL. DUPLICATAS: VENCIMENTO NUMERO    VALOR      VENCIMENTO  NUMERO      VALOR      "
         INSERT INTO wtirolez
             VALUES ( m_num_seq,3,"","","","","","","","","","","","","","","","",
                      m_des_texto,"","","")

         LET m_num_seq         = m_num_seq + 1
         LET m_qtd_lin_obs     = m_qtd_lin_obs + 1
         LET m_qtd_lin_obs_tab = m_qtd_lin_obs_tab + 1
         LET m_des_texto       =
             "                   ---------- --------- ---------- ----------- ----------- -----------"
         INSERT INTO wtirolez
             VALUES ( m_num_seq,3,"","","","","","","","","","","","","","","","",
                      m_des_texto,"","","")
      END IF

      LET m_num_seq         = m_num_seq + 1
      LET m_qtd_lin_obs     = m_qtd_lin_obs + 1
      LET m_qtd_lin_obs_tab = m_qtd_lin_obs_tab + 1
      LET m_des_texto       = "                   ",
                              l_dat_vencto_sd           USING "dd/mm/yyyy", " ",
                              l_num_duplicata           USING "&&&&&&"," ",
                              l_dig_duplicata           USING "&&"," ",
                              l_val_duplic              USING "####,##&.&&"

      INITIALIZE l_dat_vencto_sd,
                 l_val_duplic     TO NULL

      FETCH cq_duplic2 INTO l_dat_vencto_sd,
                            l_val_duplic,
                            l_num_duplicata,
                            l_dig_duplicata

      LET m_des_texto       = m_des_texto clipped, " ",
                              l_dat_vencto_sd           USING "dd/mm/yyyy", " ",
                              l_num_duplicata           USING "&&&&&&"," ",
                              l_dig_duplicata           USING "&&"," ",
                              l_val_duplic              USING "####,##&.&&"

      INSERT INTO wtirolez
             VALUES ( m_num_seq,3,"","","","","","","","","","","","","","","","",
                      m_des_texto,"","","")
   END FOREACH

END FUNCTION


{#-------------------------------------#
FUNCTION pol0708_carrega_end_cobranca()
#-------------------------------------#
   INITIALIZE mr_cli_end_cobr.* TO NULL

   SELECT cli_end_cob.*,
          clientes.num_cgc_cpf,
          clientes.ins_estadual
     INTO mr_cli_end_cobr.*
     FROM cli_end_cob, clientes
    WHERE cli_end_cob.cod_cliente = mr_nff.cod_cliente
      AND clientes.cod_cliente    = cli_end_cob.cod_cliente
    IF sqlca.sqlcode = 0 THEN
       LET mr_nff.end_cob_cli      = mr_cli_end_cobr.end_cobr
       LET mr_nff.den_bairro_cob   = mr_cli_end_cobr.den_bairro
       LET mr_nff.cod_cep_cob      = mr_cli_end_cobr.cod_cep
       LET mr_nff.num_cgc_cob      = mr_cli_end_cobr.num_cgc_cob
       LET mr_nff.ins_estadual_cob = mr_cli_end_cobr.ins_estadual_cob

       SELECT den_cidade,
              cod_uni_feder
         INTO mr_nff.den_cidade_cob,
              mr_nff.cod_uni_feder_cobr
         FROM cidades
        WHERE cidades.cod_cidade = mr_cli_end_cobr.cod_cidade_cob
     ELSE
       LET mr_nff.end_cob_cli        = mr_clientes.end_cliente
       LET mr_nff.den_bairro_cob     = mr_clientes.den_bairro
       LET mr_nff.cod_cep_cob        = mr_clientes.cod_cep
       LET mr_nff.num_cgc_cob        = mr_clientes.num_cgc_cpf
       LET mr_nff.ins_estadual_cob   = mr_clientes.ins_estadual
       LET mr_nff.den_cidade_cob     = mr_nff.den_cidade
       LET mr_nff.cod_uni_feder_cobr = mr_nff.cod_uni_feder
     END IF

     LET m_des_texto = "END. COBRANCA: ",
                        mr_nff.end_cob_cli CLIPPED, "  ",
                        mr_nff.den_bairro_cob CLIPPED, "  ",
                        mr_nff.cod_cep_cob CLIPPED, "  ",
                        "CGC: ", mr_nff.num_cgc_cob CLIPPED, "  ",
                        "I.E.: ",  mr_nff.ins_estadual_cob CLIPPED, "  ",
                        mr_nff.den_cidade_cob CLIPPED,"  ",
      			mr_nff.cod_uni_feder_cobr CLIPPED

     CALL pol0708_insert_array(m_des_texto)
END FUNCTION
}
#----------------------------------#
FUNCTION pol0708_carrega_corpo_nff()
#----------------------------------#
   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli,
          l_num_pedido_ant     LIKE wfat_item.num_pedido,
          l_num_om_ant         LIKE wfat_item.num_om,
          l_ind                SMALLINT
          
   LET l_num_pedido_ant  = 0
   LET l_num_om_ant      = 0
   LET m_ind             = 1
   LET m_total_desc      = 0

   DECLARE cq_wfat_item CURSOR FOR
    SELECT wfat_item.*,
           wfat_item_fiscal.*
      FROM wfat_item,
           wfat_item_fiscal
     WHERE wfat_item.cod_empresa          = p_cod_empresa
       AND wfat_item.num_nff              = mr_wfat_mestre.num_nff
       AND wfat_item_fiscal.cod_empresa   = wfat_item.cod_empresa
       AND wfat_item_fiscal.num_nff       = wfat_item.num_nff
       AND wfat_item_fiscal.num_pedido    = wfat_item.num_pedido
       AND wfat_item_fiscal.num_sequencia = wfat_item.num_sequencia

     UNION ALL
    SELECT wfat_item_bnf.*,
           wfat_item_bnf_fisc.*
      FROM wfat_item_bnf,
           wfat_item_bnf_fisc
     WHERE wfat_item_bnf.cod_empresa        = p_cod_empresa
       AND wfat_item_bnf.num_nff            = mr_wfat_mestre.num_nff
       AND wfat_item_bnf_fisc.cod_empresa   = wfat_item_bnf.cod_empresa
       AND wfat_item_bnf_fisc.num_nff       = wfat_item_bnf.num_nff
       AND wfat_item_bnf_fisc.num_pedido    = wfat_item_bnf.num_pedido
       AND wfat_item_bnf_fisc.num_sequencia = wfat_item_bnf.num_sequencia
     ORDER BY 1,2,3,4,5,7

   FOREACH cq_wfat_item INTO mr_wfat_item.*,
                             mr_wfat_item_fiscal.*

      LET ma_corpo_nff[m_ind].num_sequencia     = mr_wfat_item.num_sequencia
      LET ma_corpo_nff[m_ind].cod_cla_fisc      = mr_wfat_item.cod_cla_fisc
      LET ma_corpo_nff[m_ind].cod_fiscal        = mr_wfat_item_fiscal.cod_fiscal
      LET ma_corpo_nff[m_ind].cod_item          = mr_wfat_item.cod_item
      LET ma_corpo_nff[m_ind].cod_item_cliente  = pol0708_item_cliente()
      LET ma_corpo_nff[m_ind].num_pedido        = mr_wfat_item_fiscal.num_pedido
      LET ma_corpo_nff[m_ind].num_om            = mr_wfat_item.num_om
      LET ma_corpo_nff[m_ind].den_item          = mr_wfat_item.den_item
     #LET ma_corpo_nff[m_ind].den_item2         = mr_wfat_item.den_item[58,76]
      LET ma_corpo_nff[m_ind].pes_item          = mr_wfat_item.pes_unit * mr_wfat_item.qtd_item

      LET mr_nff.num_pedido                     = mr_wfat_item.num_pedido
      LET mr_nff.num_om                         = mr_wfat_item.num_om

      CALL pol0708_busca_dados_pedido()
      
      LET ma_corpo_nff[m_ind].num_pedido_cli = mr_nff.num_pedido_cli
      LET ma_corpo_nff[m_ind].cod_origem     = mr_wfat_item_fiscal.cod_origem
      LET ma_corpo_nff[m_ind].cod_tributacao = mr_wfat_item_fiscal.cod_tributacao

      #Alter Rafaela - Calcula Desconto  - Início Os 361341
      LET ma_corpo_nff[m_ind].pct_desc_total = 100 - mr_wfat_item.pct_desc_adic_mest
      LET ma_corpo_nff[m_ind].pct_desc_total = 100 - (ma_corpo_nff[m_ind].pct_desc_total -
                                                     (ma_corpo_nff[m_ind].pct_desc_total *
                                                      mr_wfat_item.pct_desc_adic  / 100))
      #Fim

      CALL pol0708_verifica_ctr_unid_med()
          RETURNING p_fat_conver, p_cod_unid_med_cli

      LET ma_corpo_nff[m_ind].cod_unid_med   = p_cod_unid_med_cli # mr_wfat_item.cod_unid_med


      IF ma_corpo_nff[m_ind].cod_unid_med ='PC' THEN

         LET ma_corpo_nff[m_ind].qtd_item_cx = mr_wfat_item.qtd_item / p_fat_conver
         LET ma_corpo_nff[m_ind].qtd_item_kg = mr_wfat_item.qtd_item / p_fat_conver

      ELSE
         SELECT qtd_embal_separado
           INTO ma_corpo_nff[m_ind].qtd_item_kg
           FROM vdp_ped_item_575
          WHERE empresa           = p_cod_empresa
            AND pedido            = ma_corpo_nff[m_ind].num_pedido
            AND sequencial_pedido = mr_wfat_item.num_sequencia 
            AND item              = mr_wfat_item.cod_item

         IF STATUS <> 0 THEN
            LET ma_corpo_nff[m_ind].qtd_item_kg = NULL
            LET ma_corpo_nff[m_ind].qtd_item_cx = mr_wfat_item.qtd_item / p_fat_conver
         ELSE 
            LET ma_corpo_nff[m_ind].qtd_item_cx = mr_wfat_item.qtd_item / p_fat_conver
         END IF
         
         #IF ma_corpo_nff[m_ind].cod_unid_med ='KG' THEN
         #   LET ma_corpo_nff[m_ind].qtd_item_kg = mr_wfat_item.qtd_item / p_fat_conver
         #   LET ma_corpo_nff[m_ind].qtd_item_cx = ma_corpo_nff[m_ind].qtd_item_kg  
         #END IF
          
      END IF 
         
      LET ma_corpo_nff[m_ind].pre_unit     = mr_wfat_item.pre_unit_nf / p_fat_conver
      LET ma_corpo_nff[m_ind].val_liq_item = mr_wfat_item.val_liq_item

      #LET ma_corpo_nff[m_ind].total_desc = (ma_corpo_nff[m_ind].pct_desc_total * ma_corpo_nff[m_ind].val_liq_item) / 100
      LET m_total_desc = m_total_desc + mr_wfat_item.val_desc_adicional

      IF mr_wfat_item_fiscal.pct_icm <> 0 THEN
         LET ma_corpo_nff[m_ind].pct_icm      = mr_wfat_item_fiscal.pct_icm
      ELSE
         LET ma_corpo_nff[m_ind].pct_icm      = mr_wfat_mestre.pct_icm
      END IF

      LET ma_corpo_nff[m_ind].pct_ipi = mr_wfat_item.pct_ipi
      LET ma_corpo_nff[m_ind].val_ipi = mr_wfat_item.val_ipi
      LET m_val_tot_ipi_acum          = m_val_tot_ipi_acum + mr_wfat_item.val_ipi

      CALL pol0708_n_tributacao()

#      LET m_total_desc = m_total_desc + ma_corpo_nff[m_ind].total_desc

{      IF mr_wfat_mestre.ies_origem = "P" THEN
         IF l_num_pedido_ant <> mr_wfat_item.num_pedido THEN
            LET m_des_nr_pedido   = m_des_nr_pedido  CLIPPED, " ",
                                    mr_wfat_item.num_pedido  USING "######"
            LET m_des_nr_ped_cli  = m_des_nr_ped_cli CLIPPED, " ",
                                    mr_nff.num_pedido_cli
            LET l_num_pedido_ant  = mr_wfat_item.num_pedido
         END IF
         IF l_num_om_ant <> mr_wfat_item.num_om THEN
            LET m_des_nr_om       = m_des_nr_om      CLIPPED, " ",
                                    mr_wfat_item.num_om      USING "######"
            LET l_num_om_ant      = mr_wfat_item.num_om
         END IF
      END IF
}      
      FOR l_ind = 1 TO 50
         IF ma_pedido[l_ind].pedido = ma_corpo_nff[m_ind].num_pedido THEN
            EXIT FOR
         ELSE
            IF ma_pedido[l_ind].pedido IS NULL THEN
               LET ma_pedido[l_ind].pedido = ma_corpo_nff[m_ind].num_pedido
               EXIT FOR
            END IF
         END IF
      END FOR

      LET l_des_texto_1 = NULL
      FOR l_ind = 1 TO 50
         IF ma_pedido[l_ind].ped_cli = ma_corpo_nff[m_ind].num_pedido_cli THEN
            EXIT FOR
         ELSE
            IF ma_pedido[l_ind].ped_cli IS NULL THEN
               LET ma_pedido[l_ind].ped_cli = ma_corpo_nff[m_ind].num_pedido_cli
               EXIT FOR
            END IF
         END IF
{         IF ma_pedido[l_ind].ped_cli IS NOT NULL THEN
            IF l_des_texto_1 IS NULL THEN
               LET l_des_texto_1 = 'PED. CLIENTE.: ', ma_pedido[l_ind].ped_cli CLIPPED
            ELSE
               LET l_des_texto_1 = l_des_texto_1 CLIPPED,' - ',
                                   ma_pedido[l_ind].ped_cli CLIPPED
            END IF
         END IF}
      END FOR
      FOR l_ind = 1 TO 50
         IF ma_pedido[l_ind].num_om = ma_corpo_nff[m_ind].num_om THEN
            EXIT FOR
         ELSE
            IF ma_pedido[l_ind].num_om IS NULL THEN
               LET ma_pedido[l_ind].num_om = ma_corpo_nff[m_ind].num_om
               EXIT FOR
            END IF
         END IF
      END FOR

      IF m_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET m_ind = m_ind + 1

   END FOREACH
   
{
   IF ma_pedido[l_ind].ped_cli IS NOT NULL THEN
      IF l_des_texto_1 IS NULL THEN
         LET l_des_texto_1 = 'PED. CLIENTE.: ', ma_pedido[l_ind].ped_cli CLIPPED
      ELSE
         LET l_des_texto_1 = l_des_texto_1 CLIPPED,' - ',
                             ma_pedido[l_ind].ped_cli CLIPPED
      END IF
   END IF
   INSERT INTO wtirolez
          VALUES ( m_num_seq,4,"","","","","","","","","","","","","","","","",
                   l_des_texto_1,"","","")
}                   

END FUNCTION

#-------------------------------#
#FUNCTION pol0708_imprime_pedido()
#-------------------------------#

# DEFINE l_des_texto_1,
#        l_des_texto_2,
#        l_des_texto_3   CHAR(120)
# DEFINE l_ind,
#        l_ind1,
#        l_primeira_om,
#        l_count         SMALLINT

# LET mr_nff.num_pedido     = NULL
# LET mr_nff.num_pedido_cli = NULL
# LET mr_nff.num_om         = NULL
# LET l_des_texto_1     = NULL
# LET l_des_texto_2     = NULL
# LET l_count           = 0
{
 FOR l_ind = 1 TO 50
    IF ma_pedido[l_ind].pedido IS NOT NULL AND
       ma_pedido[l_ind].pedido <> 0       THEN
       IF l_count < 1 AND ma_pedido[2].pedido IS NULL THEN {imprimir ate 1 pedidos no campo PEDIDO
          IF mr_nff.num_pedido IS NULL THEN
             LET mr_nff.num_pedido = ma_pedido[l_ind].pedido USING '######'
          ELSE
             LET mr_nff.num_pedido = mr_nff.num_pedido CLIPPED,' ',
                                     ma_pedido[l_ind].pedido USING '######'
          END IF
          LET l_count = l_count + 1
       ELSE
          LET l_primeira_om = TRUE
          IF l_des_texto_1 IS NULL THEN
             LET l_des_texto_1 = 'No PEDIDO: ', ma_pedido[l_ind].pedido USING '######'
             FOR l_ind1 = 1 TO 50
                 IF ma_pedido[l_ind1].num_om IS NOT NULL AND
                    ma_pedido[l_ind1].num_om <> 0       THEN
       	            IF l_primeira_om = TRUE THEN
                       LET l_des_texto_1 = l_des_texto_1 CLIPPED,
                                          ' OM: ', ma_pedido[l_ind1].num_om CLIPPED
                       LET l_primeira_om = FALSE
                    ELSE
                       LET l_des_texto_1 = l_des_texto_1 CLIPPED,' - ',
                                           ma_pedido[l_ind1].num_om CLIPPED
                    END IF
                 END IF
             END FOR
          END IF
      END IF
    END IF
}
{
    IF ma_pedido[l_ind].ped_cli IS NOT NULL THEN
       IF l_des_texto_1 IS NULL THEN
          LET l_des_texto_1 = 'PED. CLIENTE.: ', ma_pedido[l_ind].ped_cli CLIPPED
       ELSE
          LET l_des_texto_1 = l_des_texto_1 CLIPPED,' - ',
                              ma_pedido[l_ind].ped_cli CLIPPED
       END IF
     END IF
}     
{
    IF ma_pedido[l_ind].num_om IS NOT NULL THEN
       IF l_des_texto_3 IS NULL THEN
          LET l_des_texto_3 = 'OM: ', ma_pedido[l_ind].num_om CLIPPED
       ELSE
          LET l_des_texto_3 = l_des_texto_3 CLIPPED,' - ',
                              ma_pedido[l_ind].num_om CLIPPED
       END IF
    END IF
 END FOR
}
{
 IF l_des_texto_1 IS NOT NULL THEN
    CALL pol0708_insert_array(l_des_texto_1)
 END IF
 IF l_des_texto_2 IS NOT NULL THEN
    CALL pol0708_insert_array(l_des_texto_2)
 END IF
 }
 {
 IF l_des_texto_1 IS NOT NULL THEN
    CALL pol0708_insert_array(l_des_texto_1)
 END IF
}
#END FUNCTION

#-----------------------------#
FUNCTION pol0708_item_cliente()
#-----------------------------#
   DEFINE l_cod_item_cliente  LIKE cliente_item.cod_item_cliente

   SELECT cod_item_cliente
     INTO l_cod_item_cliente
     FROM cliente_item
    WHERE cod_empresa        = p_cod_empresa
      AND cod_cliente_matriz = mr_wfat_mestre.cod_cliente
      AND cod_item           = mr_wfat_item.cod_item

   RETURN l_cod_item_cliente
END FUNCTION

#--------------------------------------#
FUNCTION pol0708_verifica_ctr_unid_med()
#--------------------------------------#
   DEFINE p_ctr_unid_med   RECORD LIKE  ctr_unid_med.*

   WHENEVER ERROR CONTINUE
   SELECT ctr_unid_med.*
     INTO p_ctr_unid_med.*
     FROM ctr_unid_med
    WHERE cod_empresa = p_cod_empresa
      AND cod_cliente = mr_wfat_mestre.cod_cliente
      AND cod_item    = mr_wfat_item.cod_item
   WHENEVER ERROR STOP
   IF sqlca.sqlcode = 0 THEN
      RETURN p_ctr_unid_med.fat_conver,
             p_ctr_unid_med.cod_unid_med_cli
   ELSE
      RETURN 1, mr_wfat_item.cod_unid_med
   END IF
END FUNCTION

#------------------------------------------#
FUNCTION pol0708_carrega_corpo_nota()
#------------------------------------------#
   DEFINE i, j            SMALLINT,
          p_valor_pis     DECIMAL(15,2), 
          p_valor_cofins  DECIMAL(15,2)

   LET i         = 1
   LET m_num_seq = 0

   FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}

      IF ma_corpo_nff[i].cod_item     IS NULL AND
         ma_corpo_nff[i].cod_cla_fisc IS NULL AND
         ma_corpo_nff[i].pct_ipi      IS NULL AND
         ma_corpo_nff[i].qtd_item_kg  IS NULL AND
         ma_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      { grava o codigo do item }

      LET m_num_seq = m_num_seq + 1
      INSERT INTO wtirolez VALUES (m_num_seq,
                                  1,
                                  ma_corpo_nff[i].cod_item,
                                  ma_corpo_nff[i].cod_item_cliente,
                                  ma_corpo_nff[i].den_item,
                                  ma_corpo_nff[i].pes_item,
                                  ma_corpo_nff[i].cod_fiscal,
                                  ma_corpo_nff[i].cod_cla_fisc,
                                  ma_corpo_nff[i].cod_origem,
                                  ma_corpo_nff[i].cod_tributacao,
                                  ma_corpo_nff[i].cod_unid_med,
                                  ma_corpo_nff[i].qtd_item_cx,
                                  ma_corpo_nff[i].qtd_item_kg,
                                  ma_corpo_nff[i].pre_unit,
                                  ma_corpo_nff[i].val_liq_item,
                                  ma_corpo_nff[i].pct_icm,
                                  ma_corpo_nff[i].pct_ipi,
                                  ma_corpo_nff[i].val_ipi,
                                  "",
                                  "",
                                  ma_corpo_nff[i].num_sequencia,
                                  ma_corpo_nff[i].pct_desc_total)

      IF ma_corpo_nff[i].m_den_item2 IS NOT NULL AND
         ma_corpo_nff[i].m_den_item2 <> " " THEN
         LET m_num_seq = m_num_seq + 1
         INSERT INTO wpomp VALUES ( m_num_seq,2,"","","",ma_corpo_nff[i].m_den_item2,"","","","","",
                                    "","","","","","","","","","","","","","")
      END IF

   END FOR

END FUNCTION

#-----------------------------------#
 FUNCTION pol0708_imprime_ret_terc()
#-----------------------------------#
   DEFINE la_retorno_nff ARRAY[100]
      OF RECORD
         num_nf       LIKE  wfat_terc_ret.num_nf,
         dat_emis_nf  LIKE  item_de_terc.dat_emis_nf
      END RECORD

   DEFINE lr_wfat_terc_ret     RECORD LIKE wfat_terc_ret.*,
          l_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          l_dat_emis_nf        LIKE item_de_terc.dat_emis_nf,
          l_cont               SMALLINT,
          l_texto_nff_terc     CHAR(500)

   INITIALIZE la_retorno_nff TO NULL
   LET l_cont = 0

   IF mr_nat_operacao.ies_tip_controle = "3" THEN
      SELECT cod_fornecedor
        INTO l_cod_fornecedor
        FROM fornecedor
       WHERE num_cgc_cpf = mr_nff.num_cgc_cpf
      IF sqlca.sqlcode = 0 THEN

         DECLARE cq_terc_ret CURSOR FOR
          SELECT wfat_terc_ret.*
            FROM wfat_terc_ret
           WHERE wfat_terc_ret.cod_empresa = p_cod_empresa
             AND wfat_terc_ret.num_nff     = mr_wfat_mestre.num_nff

         LET l_texto_nff_terc = ""

         FOREACH cq_terc_ret INTO lr_wfat_terc_ret.*
            SELECT dat_emis_nf
              INTO l_dat_emis_nf
              FROM item_de_terc
             WHERE item_de_terc.cod_empresa    = p_cod_empresa
               AND item_de_terc.num_nf         = lr_wfat_terc_ret.num_nf
               AND item_de_terc.ser_nf         = lr_wfat_terc_ret.ser_nf
               AND item_de_terc.ssr_nf         = lr_wfat_terc_ret.ssr_nf
               AND item_de_terc.ies_especie_nf = lr_wfat_terc_ret.ies_especie_nf
               AND item_de_terc.num_sequencia  = lr_wfat_terc_ret.num_seq
               AND item_de_terc.cod_fornecedor = l_cod_fornecedor

            IF sqlca.sqlcode = 0 THEN
               FOR l_cont = 1 TO 100
                  IF la_retorno_nff[l_cont].num_nf IS NULL THEN
                     LET la_retorno_nff[l_cont].num_nf      = lr_wfat_terc_ret.num_nf
                     LET la_retorno_nff[l_cont].dat_emis_nf = l_dat_emis_nf
                  END IF

                  IF  la_retorno_nff[l_cont].num_nf      = lr_wfat_terc_ret.num_nf
                  AND la_retorno_nff[l_cont].dat_emis_nf = l_dat_emis_nf THEN
                     EXIT FOR
                  END IF
               END FOR
            END IF
         END FOREACH

         FOR l_cont = 1 TO 100
            IF la_retorno_nff[l_cont].num_nf IS NULL THEN
               EXIT FOR
            END IF

            IF l_cont = 1 THEN
               LET l_texto_nff_terc = "RETORNO NFF: ",
                                      la_retorno_nff[l_cont].num_nf USING "<<<&&&", " DE ",
                                      la_retorno_nff[l_cont].dat_emis_nf USING "dd/mm/yyyy"
            ELSE
               LET l_texto_nff_terc = l_texto_nff_terc CLIPPED, ", ",
                                      la_retorno_nff[l_cont].num_nf USING "<<<&&&", " DE ",
                                      la_retorno_nff[l_cont].dat_emis_nf USING "dd/mm/yyyy"
            END IF
         END FOR

         IF l_texto_nff_terc IS NOT NULL AND l_texto_nff_terc <> " " THEN
            IF LENGTH (l_texto_nff_terc[1,75]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[1,75],4)
            END IF
            IF LENGTH (l_texto_nff_terc[76,150]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[76,150],4)
            END IF
            IF LENGTH (l_texto_nff_terc[151,225]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[151,225],4)
            END IF
            IF LENGTH (l_texto_nff_terc[226,300]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[226,300],4)
            END IF
            IF LENGTH (l_texto_nff_terc[301,375]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[301,375],4)
            END IF
            IF LENGTH (l_texto_nff_terc[376,450]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[376,450],4)
            END IF
            IF LENGTH (l_texto_nff_terc[451,500]) > 0 THEN
               CALL pol0708_insert_array(l_texto_nff_terc[450,500],4)
            END IF

         END IF
      END IF
   END IF

END FUNCTION

#-----------------------------------------#
FUNCTION pol0708_calcula_total_de_paginas()
#-----------------------------------------#

   SELECT COUNT(*)
     INTO m_num_linhas
     FROM wtirolez
    WHERE ies_tip_info <> 4

   { 20 = numero de linhas do corpo da nota fiscal }

   IF m_num_linhas IS NOT NULL AND
      m_num_linhas > 0         THEN
      LET m_tot_paginas = (m_num_linhas - (m_num_linhas MOD 20)) / 20
      IF (m_num_linhas MOD 20) > 0 THEN
          LET m_tot_paginas = m_tot_paginas + 1
      ELSE
          LET m_ies_termina_relat = FALSE
      END IF
   ELSE
      LET m_tot_paginas = 1
   END IF

END FUNCTION
#------------------------------------------#
FUNCTION pol0708_busca_dados_subst_trib_uf()
#------------------------------------------#
   INITIALIZE mr_subst_trib_uf.* TO NULL

   SELECT subst_trib_uf.*
     INTO mr_subst_trib_uf.*
     FROM clientes,
          cidades,
          subst_trib_uf
    WHERE clientes.cod_cliente        = mr_wfat_mestre.cod_cliente
      AND cidades.cod_cidade          = clientes.cod_cidade
      AND subst_trib_uf.cod_empresa   = p_cod_empresa
      AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
END FUNCTION

#-----------------------------#
FUNCTION pol0708_den_nat_oper()
#-----------------------------#

   WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
     INTO mr_nat_operacao.*
     FROM nat_operacao
    WHERE cod_nat_oper = mr_wfat_mestre.cod_nat_oper
   WHENEVER ERROR STOP
   
   IF SQLCA.sqlcode = 0 THEN
      IF mr_nat_operacao.ies_subst_tribut <> "S" THEN
         LET mr_nff.ins_estadual_trib = NULL
      END IF
      RETURN mr_nat_operacao.den_nat_oper
   ELSE
      RETURN "NATUREZA NAO CADASTRADA"
   END IF
    
END FUNCTION

#------------------------------------#
FUNCTION pol0708_busca_dados_empresa()
#------------------------------------#
   INITIALIZE mr_empresa.* TO NULL

   SELECT empresa.*
     INTO mr_empresa.*
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

END FUNCTION

#------------------------------#
FUNCTION pol0708_representante()
#------------------------------#
   DEFINE p_nom_guerra LIKE representante.nom_guerra

   SELECT nom_guerra
     INTO p_nom_guerra
     FROM representante
    WHERE cod_repres = mr_wfat_mestre.cod_repres

   RETURN p_nom_guerra
END FUNCTION

#---------------------------------------#
FUNCTION pol0708_grava_dados_historicos()
#---------------------------------------#
   INITIALIZE mr_wfat_historico.* TO NULL

   SELECT *
     INTO mr_wfat_historico.*
     FROM wfat_historico
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = mr_wfat_mestre.num_nff
      AND nom_usuario = mr_wfat_mestre.nom_usuario

   IF mr_wfat_historico.tex_hist1_1 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist1_1,4)
   END IF

   IF mr_wfat_historico.tex_hist2_1 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist2_1,4)
   END IF

   IF mr_wfat_historico.tex_hist3_1 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist3_1,4)
   END IF

   IF mr_wfat_historico.tex_hist4_1 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist4_1,4)
   END IF

   IF mr_wfat_historico.tex_hist1_2 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist1_2,4)
   END IF

   IF mr_wfat_historico.tex_hist2_2 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist2_2,4)
   END IF

   IF mr_wfat_historico.tex_hist3_2 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist3_2,4)
   END IF

   IF mr_wfat_historico.tex_hist4_2 <> " " THEN
      CALL pol0708_insert_array(mr_wfat_historico.tex_hist4_2,4)
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0708_carrega_msg_remessa()
#--------------------------------------#
 DEFINE lr_nf_item_base    RECORD LIKE nf_item_base_icm.*,
        l_dat_emissao      LIKE nf_mestre.dat_emissao

 INITIALIZE lr_nf_item_base.* TO NULL
 INITIALIZE l_dat_emissao     TO NULL

   SELECT *
     INTO lr_nf_item_base.*
     FROM nf_item_base_icm
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = mr_wfat_item.num_pedido
      AND num_sequencia = mr_wfat_item.num_sequencia

   IF lr_nf_item_base.num_nff IS NOT NULL THEN
      SELECT dat_emissao
        INTO l_dat_emissao
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = lr_nf_item_base.num_nff

      LET m_des_texto = "NOTA FISCAL DE REMESSA, CONFORME NOTA FISCAL DE ENTREGA FUTURA/SIMPLES FATURAMENTO Nº",
                        lr_nf_item_base.num_nff,
                        " DE ",
                        l_dat_emissao
      CALL pol0708_insert_array(m_des_texto,4)
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0708_grava_conta_ordem()
#------------------------------------#
 DEFINE l_num_nff       LIKE nf_referencia.num_nff_ref,
        l_cod_cliente   LIKE clientes.cod_cliente,
        l_dat_emissao   LIKE wfat_mestre.dat_emissao,
        lr_clientes     RECORD LIKE clientes.*,
        j               SMALLINT,
        l_val_ipi       LIKE wfat_item.val_ipi,
        l_den_cidade    LIKE cidades.den_cidade,
        l_cod_uni_feder LIKE cidades.cod_uni_feder

 DEFINE la_texto        ARRAY[10] OF
        RECORD
           texto        CHAR(100)
        END RECORD

 DECLARE cq_ref CURSOR FOR
  SELECT num_nff_ref
    FROM nf_referencia
   WHERE cod_empresa = p_cod_empresa
     AND num_nff     = mr_wfat_mestre.num_nff

    OPEN cq_ref
   FETCH cq_ref INTO l_num_nff

 IF SQLCA.sqlcode = 0 THEN
    DECLARE cq_mest CURSOR FOR
     SELECT cod_cliente,
            dat_emissao
       FROM nf_mestre
      WHERE cod_empresa = p_cod_empresa
        AND num_nff     = l_num_nff

     OPEN cq_mest
    FETCH cq_mest INTO l_cod_cliente, l_dat_emissao

    IF SQLCA.sqlcode = 0 THEN
       SELECT *
        INTO lr_clientes.*
        FROM clientes
       WHERE cod_cliente = l_cod_cliente
    END IF

    LET la_texto[1].texto = "MERCADORIA SENDO ENTREGUE POR CONTA E ORDEM A: ",
                            lr_clientes.nom_cliente CLIPPED,"  ",
                            lr_clientes.end_cliente CLIPPED
    LET la_texto[2].texto = "CNPJ: ",lr_clientes.num_cgc_cpf,
                            "  IE: ",lr_clientes.ins_estadual,
                            "  CONF.NF: ",l_num_nff," DE ",l_dat_emissao USING "dd/mm/yyyy"

    FOR j = 1 TO 2
        CALL pol0708_insert_array(la_texto[j].texto,4)
    END FOR
 ELSE
    SELECT num_nff
      INTO l_num_nff
      FROM nf_referencia
     WHERE cod_empresa = p_cod_empresa
       AND num_nff_ref = mr_wfat_mestre.num_nff

     IF SQLCA.sqlcode = 0 THEN
        SELECT cod_cliente,
               dat_emissao,
               val_tot_ipi
          INTO l_cod_cliente,
               l_dat_emissao,
               l_val_ipi
          FROM nf_mestre
         WHERE cod_empresa = p_cod_empresa
           AND num_nff     = l_num_nff

        IF SQLCA.sqlcode = 0 THEN
           SELECT *
             INTO lr_clientes.*
             FROM clientes
            WHERE cod_cliente = l_cod_cliente

           IF SQLCA.sqlcode = 0 THEN
              SELECT den_cidade,
                     cod_uni_feder
                INTO l_den_cidade,
                     l_cod_uni_feder
                FROM cidades
               WHERE cod_cidade = lr_clientes.cod_cidade
            END IF

         END IF

         LET la_texto[1].texto = "MERCADORIA SENDO ENTREGUE POR CONTA E ORDEM DE: ",
                                 lr_clientes.nom_cliente
         LET la_texto[2].texto = lr_clientes.end_cliente CLIPPED," - ",l_den_cidade CLIPPED,"-",l_cod_uni_feder,
                                 " CNPJ: ",lr_clientes.num_cgc_cpf
         LET la_texto[3].texto = "IE: ",lr_clientes.ins_estadual,
                                 " CONF.NF: ",l_num_nff CLIPPED," DE ",l_dat_emissao USING "dd/mm/yyyy"
         LET la_texto[4].texto = "ONDE OS IMPOSTOS FORAM DESTACADOS." # Valor IPI = ",
                                 #l_val_ipi USING "###,##&.&&"

         LET mr_wfat_mestre.val_tot_nff = mr_wfat_mestre.val_tot_mercadoria + l_val_ipi

         {UPDATE wtirolez
            SET val_ipi = " ",
                pct_ipi = " ",
                pct_icm = " "
         }
         FOR j = 1 TO 4
             CALL pol0708_insert_array(la_texto[j].texto,4)
         END FOR
     END IF
 END IF

END FUNCTION

#------------------------#
FUNCTION pol0708_especie()
#------------------------#
   DEFINE p_des_especie    CHAR(25)

   SELECT *
     INTO mr_embalagem.*
     FROM embalagem
    WHERE cod_embal = mr_wfat_mestre.cod_embal_1
   IF sqlca.sqlcode = 0 THEN
      LET p_des_especie = mr_embalagem.den_embal
   END IF

   RETURN p_des_especie
END FUNCTION

#-----------------------------#
FUNCTION pol0708_den_cnd_pgto()
#-----------------------------#
   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto

   SELECT den_cnd_pgto,
          ies_tipo,
          ies_emite_dupl
     INTO p_den_cnd_pgto,
          m_ies_tipo,
          m_ies_emite_dupl
     FROM cond_pgto
    WHERE cod_cnd_pgto = mr_wfat_mestre.cod_cnd_pgto

   RETURN p_den_cnd_pgto
END FUNCTION

#---------------------------------------------------#
FUNCTION pol0708_busca_dados_clientes(p_cod_cliente)
#---------------------------------------------------#
   DEFINE p_cod_cliente    LIKE clientes.cod_cliente

   INITIALIZE mr_clientes.* TO NULL

   SELECT *
     INTO mr_clientes.*
     FROM clientes
    WHERE cod_cliente = mr_wfat_mestre.cod_cliente

END FUNCTION

#--------------------------------#
FUNCTION pol0708_busca_nome_pais()
#--------------------------------#
   INITIALIZE mr_paises.* ,
              mr_uni_feder.*    TO NULL

   SELECT *
     INTO mr_uni_feder.*
     FROM uni_feder
    WHERE cod_uni_feder = mr_cidades.cod_uni_feder

   SELECT *
     INTO mr_paises.*
     FROM paises
    WHERE cod_pais = mr_uni_feder.cod_pais
END FUNCTION

#----------------------------------------------------#
FUNCTION pol0708_busca_dados_transport(p_cod_transpor)
#----------------------------------------------------#
   DEFINE p_cod_transpor  LIKE clientes.cod_cliente

   INITIALIZE mr_transport.* TO NULL

   SELECT *
     INTO mr_transport.*
     FROM clientes
    WHERE cod_cliente = p_cod_transpor

END FUNCTION

#------------------------------------------------#
FUNCTION pol0708_busca_dados_cidades(p_cod_cidade)
#------------------------------------------------#
   DEFINE p_cod_cidade     LIKE cidades.cod_cidade

   INITIALIZE mr_cidades.* TO NULL

   SELECT *
     INTO mr_cidades.*
     FROM cidades
    WHERE cod_cidade = p_cod_cidade
END FUNCTION

#-----------------------------------#
FUNCTION pol0708_busca_dados_pedido()
#-----------------------------------#
   DEFINE l_ped_repres  LIKE pedidos.num_pedido_repres,
          l_ped_cli     LIKE pedidos.num_pedido_cli

   SELECT num_pedido_repres,
          num_pedido_cli
     INTO mr_nff.num_pedido_repres,
          mr_nff.num_pedido_cli
     FROM pedidos
    WHERE cod_empresa  = mr_wfat_mestre.cod_empresa
      AND num_pedido   = mr_wfat_item.num_pedido

END FUNCTION

#-----------------------------------------------#
FUNCTION pol0708_grava_dados_consig(p_cod_consig)
#-----------------------------------------------#
   DEFINE p_cod_consig  LIKE clientes.cod_cliente

   INITIALIZE mr_consignat.* TO NULL

   SELECT clientes.nom_cliente,
          clientes.end_cliente,
          clientes.den_bairro,
          cidades.den_cidade,
          cidades.cod_uni_feder
     INTO mr_consignat.*
     FROM clientes,
          cidades
    WHERE clientes.cod_cliente = p_cod_consig
      AND clientes.cod_cidade  = cidades.cod_cidade
   IF sqlca.sqlcode = 0 THEN
      IF mr_consignat.den_consignat IS NOT NULL OR
         mr_consignat.den_consignat  <> "  "    THEN
         LET m_des_texto = "Consig.: ", mr_consignat.den_consignat
         CALL pol0708_insert_array(m_des_texto,4)

         IF mr_consignat.end_consignat IS NOT NULL OR
            mr_consignat.end_consignat <> "  "     THEN
            LET m_des_texto = mr_consignat.end_consignat
            CALL pol0708_insert_array(m_des_texto,4)
         END IF

         IF mr_consignat.den_bairro IS NOT NULL OR
            mr_consignat.den_bairro <> "  "     THEN
            LET m_des_texto = mr_consignat.den_bairro
            CALL pol0708_insert_array(m_des_texto,4)
         END IF

         IF mr_consignat.den_cidade IS NOT NULL OR
            mr_consignat.den_cidade <> "  "     THEN
            LET m_des_texto = mr_consignat.den_cidade
            CALL pol0708_insert_array(m_des_texto,4)
         END IF
      END IF
   END IF

END FUNCTION

#----------------------------------------#
FUNCTION pol0708_grava_dados_end_entrega()
#----------------------------------------#

   DECLARE cq_end_ent CURSOR FOR
    SELECT ped_end_ent.end_entrega,
           ped_end_ent.den_bairro,
           ped_end_ent.cod_cep,
           ped_end_ent.num_cgc,
           ped_end_ent.ins_estadual,
           cidades.den_cidade,
           cidades.cod_uni_feder
      FROM ped_end_ent,
           cidades
     WHERE ped_end_ent.num_pedido = ma_corpo_nff[1].num_pedido
       AND cidades.cod_cidade     = ped_end_ent.cod_cidade

   OPEN  cq_end_ent
   FETCH cq_end_ent INTO mr_end_entrega.*

    IF sqlca.sqlcode = 0 THEN
       LET m_des_texto       = "END. ENTREGA: ",
                                mr_end_entrega.end_entrega CLIPPED,'  ',
                                mr_end_entrega.den_bairro, '  ',
                               "CNPJ: ", mr_end_entrega.num_cgc CLIPPED, '  ',
                               "I.E.: ", mr_end_entrega.ins_estadual CLIPPED, '  ',
                                mr_end_entrega.den_cidade CLIPPED, '  ',
                                mr_end_entrega.cod_uni_feder CLIPPED, '  ',
                                "CEP: ",mr_end_entrega.cod_cep CLIPPED
         CALL pol0708_insert_array(m_des_texto,4)
    END IF

END FUNCTION

#----------------------------------------#
FUNCTION pol0708_grava_des_repres()
#----------------------------------------#

  DEFINE l_des_cliente        CHAR(36),
         l_cod_repres         DECIMAL(4,0),
         mr_cli_canal_venda   RECORD LIKE cli_canal_venda.*,
         l_raz_social         LIKE representante.raz_social

  LET l_des_cliente = ' '
  LET l_raz_social  = ' '

  SELECT *
    INTO mr_cli_canal_venda.*
    FROM cli_canal_venda
   WHERE cod_cliente      = mr_wfat_mestre.cod_cliente
     AND cod_tip_carteira = mr_wfat_mestre.cod_tip_carteira

  CASE
     WHEN mr_cli_canal_venda.ies_nivel = '01'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_1
     WHEN mr_cli_canal_venda.ies_nivel = '02'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_2
     WHEN mr_cli_canal_venda.ies_nivel = '03'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_3
     WHEN mr_cli_canal_venda.ies_nivel = '04'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_4
     WHEN mr_cli_canal_venda.ies_nivel = '05'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_5
     WHEN mr_cli_canal_venda.ies_nivel = '06'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_6
     WHEN mr_cli_canal_venda.ies_nivel = '07'
        LET l_cod_repres = mr_cli_canal_venda.cod_nivel_7
  END CASE

  SELECT raz_social
    INTO l_raz_social
    FROM representante
   WHERE cod_repres = l_cod_repres

     IF sqlca.sqlcode = 0 THEN
        IF l_raz_social IS NULL OR
           l_raz_social = ' ' THEN
        ELSE
##           LET m_des_texto = l_cod_repres CLIPPED, "-", l_raz_social CLIPPED
#           LET m_des_texto       = "REPRES.: ",
#                                    l_raz_social CLIPPED,' '
#           CALL pol0708_insert_array(m_des_texto)
        END IF
     END IF

END FUNCTION

#----------------------------------------#
FUNCTION pol0708_grava_cond_pagto()
#----------------------------------------#

  DEFINE l_cond_pagto         DECIMAL(3,0),
         l_den_cond_pgto      CHAR(30)

   LET l_cond_pagto    = ' '
   LET l_den_cond_pgto = ' '

{   DECLARE cq_cond_pgto CURSOR FOR
    SELECT MIN(cod_cnd_pgto)
      FROM cli_cond_pgto
     WHERE cod_cliente = mr_wfat_mestre.cod_cliente

   OPEN  cq_cond_pgto
   FETCH cq_cond_pgto INTO l_cond_pagto

    IF sqlca.sqlcode = 0 THEN

       SELECT den_cnd_pgto
         INTO l_den_cond_pgto
         FROM cond_pgto
        WHERE cond_pgto.cod_cnd_pgto = l_cond_pagto

        LET m_des_texto = 'COND. PAGTO: ',l_cond_pagto CLIPPED,' ',
                          l_den_cond_pgto CLIPPED,
                          '  VENC.: ', mr_nff.dat_vencto_sd1
        CALL pol0708_insert_array(m_des_texto)
    ELSE
       IF mr_nff.dat_vencto_sd1 IS NOT NULL THEN
          LET m_des_texto = 'VENC.: ', mr_nff.dat_vencto_sd1
          CALL pol0708_insert_array(m_des_texto)
       END IF
    END IF}

    LET l_cond_pagto = mr_wfat_mestre.cod_cnd_pgto    
    
    SELECT den_cnd_pgto
      INTO l_den_cond_pgto
      FROM cond_pgto
     WHERE cond_pgto.cod_cnd_pgto = l_cond_pagto
{
    LET m_des_texto = 'COND. PAGTO: ',l_cond_pagto CLIPPED,' ',
                      l_den_cond_pgto CLIPPED,
                      '  VENC.: ', mr_nff.dat_vencto_sd1
    CALL pol0708_insert_array(m_des_texto)
}
END FUNCTION

#------------------------------------------#
FUNCTION pol0708_grava_historico_nf_pedido()
#------------------------------------------#
   DEFINE i                       SMALLINT,
          p_cod_cliente_int       LIKE nf_mestre.cod_cliente

   { imprime texto da nota, se este existir }

   IF mr_wfat_mestre.cod_texto1 <> 0 OR
      mr_wfat_mestre.cod_texto2 <> 0 OR
      mr_wfat_mestre.cod_texto3 <> 0 THEN
      DECLARE cq_texto_nf CURSOR FOR
       SELECT des_texto
         FROM texto_nf
        WHERE cod_texto IN (mr_wfat_mestre.cod_texto1,
                            mr_wfat_mestre.cod_texto2,
                            mr_wfat_mestre.cod_texto3)
      FOREACH cq_texto_nf INTO m_des_texto
         IF m_des_texto IS NOT NULL OR
            m_des_texto <> "  "     THEN
            CALL pol0708_insert_array(m_des_texto,4)
         END IF
      END FOREACH
   END IF

   { grava_texto do pedido, se este existir }

   IF pol0708_verifica_texto_ped_it(ma_corpo_nff[1].num_pedido,0) THEN
      FOR i = 1 TO 05
         IF ma_texto_ped_it[i].texto IS NOT NULL AND
            ma_texto_ped_it[i].texto <> " "      THEN
            LET m_des_texto = ma_texto_ped_it[i].texto

            SELECT UNIQUE cod_cliente
              INTO p_cod_cliente_int
              FROM ped_item_nat
             WHERE cod_empresa     = p_cod_empresa
               AND num_pedido      = mr_nff.num_pedido
               AND num_sequencia   = 0
               AND ies_tipo        = "N"
            IF   sqlca.sqlcode = 0
            THEN IF   p_cod_cliente_int = mr_wfat_mestre.cod_cliente
                 THEN CALL pol0708_insert_array(m_des_texto,4)
                 END IF
            ELSE CALL pol0708_insert_array(m_des_texto,4)
            END IF
         END IF
      END FOR
   END IF

END FUNCTION

#-------------------------------------------------------------------#
FUNCTION pol0708_verifica_texto_ped_it(p_num_pedido, m_num_sequencia)
#-------------------------------------------------------------------#
   DEFINE p_num_pedido     LIKE pedidos.num_pedido,
          m_num_sequencia  LIKE ped_itens_texto.num_sequencia

   INITIALIZE ma_texto_ped_it     ,
              mr_ped_itens_texto.*    TO NULL

   SELECT *
     INTO mr_ped_itens_texto.*
     FROM ped_itens_texto
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_num_pedido
      AND num_sequencia = m_num_sequencia
   IF sqlca.sqlcode = 0 THEN
      LET ma_texto_ped_it[1].texto = mr_ped_itens_texto.den_texto_1
      LET ma_texto_ped_it[2].texto = mr_ped_itens_texto.den_texto_2
      LET ma_texto_ped_it[3].texto = mr_ped_itens_texto.den_texto_3
      LET ma_texto_ped_it[4].texto = mr_ped_itens_texto.den_texto_4
      LET ma_texto_ped_it[5].texto = mr_ped_itens_texto.den_texto_5
      RETURN TRUE
   END IF

   RETURN FALSE
END FUNCTION

#---------------------------------#
FUNCTION pol0708_monta_cod_fiscal()
#---------------------------------#
 DEFINE l_cod_fiscal  LIKE nf_item_fiscal.cod_fiscal

 DECLARE c_cod_fiscal CURSOR FOR
 SELECT UNIQUE(cod_fiscal)
   FROM nf_item_fiscal
  WHERE cod_empresa = p_cod_empresa
    AND num_nff     = mr_wfat_mestre.num_nff
    #AND cod_fiscal <> mr_wfat_mestre.cod_fiscal

 FOREACH c_cod_fiscal INTO l_cod_fiscal
    IF mr_wfat_mestre.cod_fiscal IS NOT NULL THEN
       LET m_cod_fiscal = mr_wfat_mestre.cod_fiscal USING "#&&&"
       IF m_cod_fiscal_compl IS NOT NULL  AND
          m_cod_fiscal_compl <> mr_wfat_mestre.cod_fiscal THEN
          LET m_cod_fiscal = m_cod_fiscal CLIPPED,"/",
                             m_cod_fiscal_compl USING "#&&&"
          IF l_cod_fiscal IS NOT NULL  AND
             l_cod_fiscal <> mr_wfat_mestre.cod_fiscal THEN
             LET m_cod_fiscal = m_cod_fiscal CLIPPED,
                 "/",l_cod_fiscal USING "#&&&"
          END IF
       ELSE
          IF l_cod_fiscal IS NOT NULL AND
             l_cod_fiscal <> mr_wfat_mestre.cod_fiscal THEN
             LET m_cod_fiscal = m_cod_fiscal CLIPPED,
                                "/",l_cod_fiscal USING "#&&&"
          END IF
       END IF
    ELSE
       IF l_cod_fiscal IS NOT NULL THEN
             LET m_cod_fiscal = l_cod_fiscal USING "#&&&"
       END IF
    END IF
 END FOREACH

END FUNCTION

#------------------------------------------------#
FUNCTION pol0708_insert_array(m_des_texto, p_info)
#------------------------------------------------#

   DEFINE m_des_texto   CHAR(120),
          p_texto_1     CHAR(74),
          p_texto_2     CHAR(74),
          p_info      SMALLINT

   IF LENGTH(m_des_texto) > 0 THEN
   ELSE
      RETURN
   END IF
   
   LET p_texto_1 = m_des_texto[1,74]
   LET p_texto_2 = m_des_texto[75,120]
      
   LET p_tip_info = p_info

   IF LENGTH(p_texto_1) > 0 THEN  
      LET m_num_seq = m_num_seq + 1
      INSERT INTO wtirolez
                  VALUES ( m_num_seq,p_tip_info,"","","","","","","","","","","","","","","","",
                           p_texto_1,"","","")
   END IF
   IF LENGTH(p_texto_2) > 0 THEN  
      LET m_num_seq = m_num_seq + 1
      INSERT INTO wtirolez
               VALUES ( m_num_seq,p_tip_info,"","","","","","","","","","","","","","","","",
                        p_texto_2,"","","")
   END IF
         
END FUNCTION   

#----------------------------------#
FUNCTION pol0708_trata_zona_franca()
#-----------------------------------#  

   DEFINE p_valor         CHAR(08), 
          p_valor_pis     DEC(15,2), 
          p_valor_cofins  DEC(15,2), 
          p_val_desc_merc DEC(15,2), 
          p_pct_pis       DEC(5,2),
          p_pct_cofins    DEC(5,2),
          l_coef          DEC(7,6),
          l_bas_pis       DEC(15,2),
          l_count         INTEGER,
          l_cod_portador  LIKE clientes.cod_portador
   
   LET p_valor_pis = 0
   LET p_valor_cofins = 0
   IF mr_clientes.ies_zona_franca = "S" OR
      mr_clientes.ies_zona_franca = "A" OR
      mr_nff.cod_fiscal = 6109 THEN

      SELECT par_vdp_txt[422,429]
        INTO p_valor
        FROM par_vdp
       WHERE cod_empresa = p_cod_empresa
      
      LET p_pct_pis    = p_valor[1,4] 
      LET p_pct_cofins = p_valor[5,8] 
      LET p_pct_pis    = p_pct_pis / 100 
      LET p_pct_cofins = p_pct_cofins / 100

      SELECT par_ies
        INTO mr_par_vdp_pad.par_ies
        FROM par_vdp_pad
       WHERE cod_empresa = p_cod_empresa
         AND cod_parametro = "abat_pis_cofins"

      IF mr_clientes.ies_zona_franca = "S" THEN
         LET p_campo_pis    = "PIS DESC ZONA FRANCA - ITEM"
         LET p_campo_cofins = "COFINS DESC ZONA FRANCA - ITEM"
      ELSE
         LET p_campo_pis    = "VALOR_PIS_ITEM"
         LET p_campo_cofins = "VALOR_COFINS_ITEM"
      END IF      

      IF (mr_clientes.ies_zona_franca = "S" AND mr_par_vdp_pad.par_ies = "S") OR 
         (mr_clientes.ies_zona_franca = "A" AND mr_par_vdp_pad.par_ies = "C") THEN
         
         IF mr_wfat_mestre.cod_cliente = '1601' THEN  ###  yamaha 
            LET l_coef         = 1 - ((p_pct_pis + p_pct_cofins)/100) 
            LET l_bas_pis      = mr_wfat_mestre.val_tot_nff / l_coef
            LET p_valor_pis    = l_bas_pis * p_pct_pis/100
            LET p_valor_cofins = l_bas_pis * p_pct_cofins/100
         ELSE   
            SELECT SUM(parametro_val)
              INTO p_valor_pis
              FROM fat_nf_item_compl
             WHERE empresa     = p_cod_empresa
               AND nota_fiscal = mr_wfat_mestre.num_nff
               AND campo       = p_campo_pis

            IF p_valor_pis IS NULL THEN
               LET p_valor_pis = 0
            END IF
            
            SELECT SUM(parametro_val)
              INTO p_valor_cofins
              FROM fat_nf_item_compl
             WHERE empresa     = p_cod_empresa
               AND nota_fiscal = mr_wfat_mestre.num_nff
               AND campo       = p_campo_cofins
      
            IF p_valor_cofins IS NULL THEN
               LET p_valor_cofins = 0
            END IF
         END IF   
      END IF

      LET p_val_desc_merc = mr_wfat_mestre.val_desc_merc - (p_valor_pis + p_valor_cofins)
      LET m_des_texto = NULL

      IF p_valor_pis > 0 THEN
         LET m_des_texto = "PIS: ", p_pct_pis, " % = R$ ", p_valor_pis USING "<<<,##&.&&"
      END IF

      IF p_valor_cofins > 0 THEN
         IF m_des_texto IS NULL THEN
            LET m_des_texto = 
                "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "<<<,##&.&&"
         ELSE
            LET m_des_texto = m_des_texto CLIPPED, ' - ', 
                "COFINS: ", p_pct_cofins, " % = R$ ", p_valor_cofins USING "<<<,##&.&&"
         END IF
      END IF
   END IF   
   IF m_des_texto IS NOT NULL THEN
      CALL pol0708_insert_array(m_des_texto,4)
   END IF
   
   IF ((mr_clientes.ies_zona_franca = "S" OR mr_clientes.ies_zona_franca = "A") AND
      mr_clientes.num_suframa > 0 AND mr_wfat_mestre.val_desc_merc > 0) THEN

      LET m_des_texto = NULL
      LET m_des_texto = "DESCONTO ESPECIAL DE ",mr_wfat_mestre.pct_icm USING "#&.&&",
                        " % ICMS .....:  ",p_val_desc_merc USING "<<<,##&.&&"
      CALL pol0708_insert_array(m_des_texto,4)
   
      LET m_des_texto = NULL 
      LET m_des_texto = "CODIGO SUFRAMA: ",
                         mr_clientes.num_suframa USING "&&&&&&&&&";
      CALL pol0708_insert_array(m_des_texto,4)
   END IF

   LET l_count = 0 
   SELECT COUNT(*) 
     INTO l_count
     FROM nf_duplicata
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     =  mr_wfat_mestre.num_nff
   IF l_count > 0 THEN
      SELECT cod_portador
        INTO l_cod_portador
        FROM clientes
       WHERE cod_cliente =  mr_wfat_mestre.cod_cliente
      IF l_cod_portador >= 1 AND 
         l_cod_portador <= 899 THEN 
         LET m_des_texto = NULL
         LET m_des_texto = "O NAO RECEBIMENTO DO BOLETO NAO ISENTA PGTO. CASO NAO RECEBA ATE O VENCTO" 
         CALL pol0708_insert_array(m_des_texto,4)
         LET m_des_texto = NULL
         LET m_des_texto = "ENTRAR EM CONTATO - (11)3723-7779 OU EMAIL creditocadastro@tirolez.com.br" 
         CALL pol0708_insert_array(m_des_texto,4)
      END IF    
   END IF 
   

END FUNCTION

#----------------------------------#
REPORT pol0708_relatorio(mr_tirolez)
#----------------------------------#

   DEFINE mr_tirolez             RECORD
             num_seq             SMALLINT,
             ies_tip_info        SMALLINT,
             cod_item            LIKE wfat_item.cod_item,
             cod_item_cliente    LIKE cliente_item.cod_item_cliente,
             den_item            CHAR(060),
             pes_item            DECIMAL(15,4),
             cod_fiscal          LIKE wfat_item_fiscal.cod_fiscal,
             cod_cla_fisc        CHAR(10),
             cod_origem          LIKE wfat_mestre.cod_origem,
             cod_tributacao      LIKE wfat_mestre.cod_tributacao,
             cod_unid_med        LIKE wfat_item.cod_unid_med,
             qtd_item_cx         LIKE wfat_item.qtd_item,
             qtd_item_kg         LIKE wfat_item.qtd_item,
             pre_unit            LIKE wfat_item.pre_unit_nf,
             val_liq_item        LIKE wfat_item.val_liq_item,
             pct_icm             LIKE wfat_mestre.pct_icm,
             pct_ipi             LIKE wfat_item.pct_ipi,
             val_ipi             LIKE wfat_item.val_ipi,
             des_texto           CHAR(120),
             num_nff             LIKE wfat_mestre.num_nff,
             num_sequencia       LIKE nf_item.num_sequencia,
             pct_desc_total      DECIMAL(5,2)
   END RECORD

   DEFINE m_for                  SMALLINT,
          p_des_folha            CHAR(100),
          l_cod_item             LIKE cliente_item.cod_item_cliente,
          p_texto                CHAR(75)

   DEFINE i, j,
          l_ultima_pagina,
          l_contador,
          l_ind,l_coluna     SMALLINT

   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   72

   ORDER EXTERNAL BY mr_tirolez.num_nff,
                     mr_tirolez.num_seq

   FORMAT
      PAGE HEADER
         LET m_num_pagina = m_num_pagina + 1

{01} PRINT log500_determina_cpp(132) CLIPPED,
           COLUMN 001, p_comprime, p_6lpp,
              log5211_retorna_configuracao(PAGENO,72,132) CLIPPED
     PRINT COLUMN 099, "X",
           COLUMN 135, mr_nff.num_nff USING "&&&&&&"
            #mr_empresa.cod_empresa = '05' THEN

         IF mr_empresa.cod_empresa = '02' OR
            mr_empresa.cod_empresa = '03' OR
            mr_empresa.cod_empresa = '04' THEN
{02}        PRINT COLUMN 005, mr_empresa.end_empresa CLIPPED,
                       " - ", mr_empresa.den_bairro
{03}        PRINT COLUMN 005, mr_empresa.den_munic CLIPPED,
                         "/", mr_empresa.uni_feder CLIPPED,
                  " - CEP: ", mr_empresa.cod_cep
{04}        PRINT COLUMN 005, "Telefone: ", mr_empresa.num_telefone,
                  COLUMN 095, mr_empresa.num_cgc

{05}        SKIP 1 LINES
         ELSE
{05}        SKIP 4 LINES
         END IF

         IF mr_empresa.cod_empresa = '01' OR
            mr_empresa.cod_empresa = '05' THEN
            LET mr_empresa.ins_estadual = ' '
         END IF 
         
   {06}  PRINT COLUMN 005, mr_nff.den_nat_oper,
               COLUMN 047, p_cods_fisc,
               COLUMN 095, mr_empresa.ins_estadual                  

         SKIP 2 LINES

{09}     PRINT COLUMN 005, mr_nff.nom_destinatario,
               COLUMN 095, mr_nff.num_cgc_cpf,
               COLUMN 130, mr_nff.dat_emissao     USING "dd/mm/yyyy"

         SKIP 1 LINES
{11}     PRINT COLUMN 005, mr_nff.end_destinatario,
               COLUMN 065, mr_nff.den_bairro,
               COLUMN 106, mr_nff.cod_cep

         SKIP 1 LINES
{13}     PRINT COLUMN 005, mr_nff.den_cidade,
               COLUMN 055, mr_nff.num_telefone[1,14],
               COLUMN 085, mr_nff.cod_uni_feder,
               COLUMN 105, mr_nff.ins_estadual

         #----------------DADOS DO PRODUTO----------------#

{16}  SKIP 3 LINES

      BEFORE GROUP OF mr_tirolez.num_nff
         SKIP TO TOP OF PAGE

      ON EVERY ROW
         CASE
            WHEN mr_tirolez.ies_tip_info = 1

               { Verifica a tabela CLIENTE_ITEM }
               IF mr_tirolez.cod_item_cliente IS NOT NULL
               AND mr_tirolez.cod_item_cliente <> " " THEN
                  LET l_cod_item = mr_tirolez.cod_item_cliente
               ELSE
                  LET l_cod_item = mr_tirolez.cod_item
               END IF
               IF mr_tirolez.cod_unid_med <> 'KG' THEN
{17 - 36}         PRINT COLUMN 003, l_cod_item[1,7],
                        COLUMN 012, mr_tirolez.den_item[1,46],
                        COLUMN 059, mr_tirolez.pct_desc_total  USING "&&.&",
                        COLUMN 066, mr_tirolez.cod_origem      USING "&",
                        COLUMN 067, mr_tirolez.cod_tributacao  USING "&&",
                        COLUMN 072, mr_tirolez.cod_unid_med,
                        COLUMN 077, mr_tirolez.qtd_item_cx     USING "###,##&.&&&",
                        COLUMN 090, mr_tirolez.qtd_item_kg     USING "###,##&.&&&",
                        COLUMN 104, mr_tirolez.pre_unit        USING "###,##&.&&&&",
                        COLUMN 124, mr_tirolez.val_liq_item    USING "##,###,##&.&&",
                        COLUMN 140, mr_tirolez.pct_icm         USING "#&.&&"
                  LET m_linhas_print = m_linhas_print + 1
               ELSE
                 PRINT COLUMN 003, l_cod_item[1,7],
                       COLUMN 012, mr_tirolez.den_item[1,46],
                       COLUMN 059, mr_tirolez.pct_desc_total  USING "&&.&",
                       COLUMN 066, mr_tirolez.cod_origem      USING "&",
                       COLUMN 067, mr_tirolez.cod_tributacao  USING "&&",
                       COLUMN 072, mr_tirolez.cod_unid_med,
                       COLUMN 077, mr_tirolez.qtd_item_kg     USING "###,##&.&&&",
                       COLUMN 090, mr_tirolez.qtd_item_cx     USING "###,##&.&&&",
                       COLUMN 104, mr_tirolez.pre_unit        USING "###,##&.&&&&",
                       COLUMN 124, mr_tirolez.val_liq_item    USING "##,###,##&.&&",
                       COLUMN 140, mr_tirolez.pct_icm         USING "#&.&&"
                 LET m_linhas_print = m_linhas_print + 1
              END IF
            WHEN mr_tirolez.ies_tip_info = 2
               PRINT COLUMN 12, mr_tirolez.den_item CLIPPED
               LET m_linhas_print = m_linhas_print + 1

            WHEN mr_tirolez.ies_tip_info = 3              # Complemento da Descricao
               PRINT COLUMN 012, mr_tirolez.des_texto CLIPPED
               LET m_linhas_print = m_linhas_print + 1

            WHEN mr_tirolez.ies_tip_info = 5
               WHILE TRUE
                  IF m_linhas_print < 20 THEN
                     PRINT COLUMN 001, " "
                     LET m_linhas_print = m_linhas_print + 1
                  ELSE
                     EXIT WHILE
                  END IF
               END WHILE
         END CASE

         IF m_linhas_print = 20 THEN { nr. de linhas do corpo da nota}
            IF m_num_pagina = m_tot_paginas THEN
               LET p_des_folha = "FOLHA ", m_num_pagina  USING "&&","/",
                                 m_tot_paginas          USING "&&"
            ELSE
               LET p_des_folha = "FOLHA ", m_num_pagina  USING "&&","/",
                               m_tot_paginas          USING "&&"," - Continua"
            END IF
{37}        PRINT COLUMN 025,' '

            # ------Cálculo de Imposto--------#

            IF m_num_pagina = m_tot_paginas THEN
{38}           SKIP 1 LINES
{39}           PRINT COLUMN 018, mr_nff.val_tot_base_icm   USING "###,###,##&.&&",
                     COLUMN 051, mr_nff.val_tot_icm        USING "#,###,##&.&&",
                     COLUMN 080, mr_nff.val_tot_base_ret   USING "###,##&.&&",
                     COLUMN 099, mr_nff.val_tot_icm_ret    USING "###,##&.&&",
                     COLUMN 127, mr_nff.val_tot_mercadoria USING "###,###,##&.&&"

               SKIP 1 LINES
{41}           PRINT COLUMN 018, mr_nff.val_frete_cli    USING "###,###,##&.&&",
                     COLUMN 051, mr_nff.val_seguro_cli   USING "#,###,##&.&&",
                     COLUMN 080, mr_nff.val_tot_despesas USING "###,##&.&&",
                     COLUMN 099, mr_nff.val_tot_ipi      USING "###,##&.&&",
                     COLUMN 127, mr_nff.val_tot_nff      USING "###,###,##&.&&"

               #----------------TRANSPORTADOR / VOLUMES TRANSPORTADOS----------------#
               SKIP 2 LINES
{44}           PRINT COLUMN 005, mr_nff.nom_transpor;
                  IF mr_nff.tel_transpor IS NOT NULL AND
                     mr_nff.tel_transpor <> ' '     THEN
                     PRINT COLUMN 015, ' [', mr_nff.tel_transpor CLIPPED,']';
                  END IF
               PRINT COLUMN 090, mr_nff.ies_frete USING "&",
                     COLUMN 098, mr_nff.num_placa,
                     COLUMN 113, mr_nff.cod_uni_feder_trans,
                     COLUMN 121, mr_nff.num_cgc_trans
               SKIP 1 LINES
{46}           PRINT COLUMN 005, mr_nff.end_transpor,
                     COLUMN 078, mr_nff.den_cidade_trans,
                     COLUMN 113, mr_nff.cod_uni_feder_trans,
                     COLUMN 125, mr_nff.ins_estadual_trans
               SKIP 1 LINES
{48}           PRINT COLUMN 003, mr_nff.qtd_volume       USING "#########",
                     COLUMN 023, mr_nff.des_especie,
                     COLUMN 050, mr_nff.den_marca,
                     COLUMN 076, mr_nff.num_pri_volume USING "####&";
                     IF (mr_nff.num_pri_volume IS NOT NULL AND
                         mr_nff.num_pri_volume <> 0 ) OR
                        (mr_nff.num_ult_volume IS NOT NULL AND
                         mr_nff.num_ult_volume <> 0 )     THEN
                        PRINT  "/";
                     END IF
               PRINT mr_nff.num_ult_volume USING "####&",
                     COLUMN 100, mr_nff.pes_tot_bruto    USING "#,###,##&.&&&",
                     COLUMN 128, mr_nff.pes_tot_liquido  USING "#,###,##&.&&&"

{50}           SKIP 2 LINES

               LET p_linha = 0
               DECLARE cq_texto CURSOR FOR
                SELECT des_texto
                  FROM wtirolez
                 WHERE ies_tip_info = 4
                             
               FOREACH cq_texto INTO m_des_texto
                  IF LENGTH(m_des_texto) > 0 THEN
{51-59}              PRINT COLUMN 003, m_des_texto
                     LET p_linha = p_linha + 1
                  END IF
                  IF p_linha >= 9 THEN
                     EXIT FOREACH
                  END IF
               END FOREACH
               
               WHILE p_linha < 11 
{60 - 60}         PRINT
                  LET p_linha = p_linha + 1
               END  WHILE 
{61}           PRINT COLUMN 004, mr_nff.dat_vencto_sd1,
                     COLUMN 018, mr_nff.val_duplic1,
                     COLUMN 041, mr_nff.dat_vencto_sd2,
                     COLUMN 055, mr_nff.val_duplic2,
                     COLUMN 077, mr_nff.den_cnd_pgto[1,7],
                     COLUMN 090, mr_nff.num_pedido USING "&&&&&&",
                     COLUMN 105, mr_nff.num_om     USING "&&&&&&",
                     COLUMN 120, mr_nff.cod_repres,'-',mr_nff.raz_social[1,15]
               LET m_num_pagina = 0
{65}           SKIP 4 LINES
{66}           PRINT COLUMN 128, mr_nff.num_nff  USING "&&&&&&"
{68}           SKIP 6 LINES
####           PRINT log500_termina_configuracao() CLIPPED               
            ELSE
{38}           SKIP 1 LINES
{39}           PRINT COLUMN 018, "***,***,***.**",
                     COLUMN 051, "***,***,***.**",
                     COLUMN 080, "***,***,***.**",
                     COLUMN 099, "***,***,***.**",
                     COLUMN 127, "***,***,***.**"

               SKIP 1 LINES
{41}           PRINT COLUMN 018, "***,***,***.**",
                     COLUMN 051, "***,***,***.**",
                     COLUMN 080, "***,***,***.**",
                     COLUMN 099, "***,***,***.**",
                     COLUMN 127, "***,***,***.**"
               SKIP 2 LINES
{44}           PRINT 
               SKIP 1 LINES
{46}           PRINT 
               SKIP 1 LINES
{48}           PRINT 
{50}           SKIP 2 LINES
               DECLARE cq_texti CURSOR FOR
                SELECT des_texto
                  FROM wtirolez
                 WHERE ies_tip_info = 4
                             
               FOREACH cq_texti INTO m_des_texto
                  IF LENGTH(m_des_texto) <= 75 THEN
{51-59}              PRINT 
                     LET p_linha = p_linha + 1
                  END IF
                  IF p_linha >= 9 THEN
                     EXIT FOREACH
                  END IF
               END FOREACH
               
               WHILE p_linha < 11 
{60 - 60}         PRINT
                  LET p_linha = p_linha + 1
               END  WHILE 
{61}           PRINT
{65}           SKIP 4 LINES
{66}           PRINT COLUMN 128, mr_nff.num_nff  USING "&&&&&&"
{68}           SKIP 6 LINES 
##{69}           PRINT 
            END IF
            LET m_linhas_print = 0
         END IF
 END REPORT

#---------------------------- FIM DE PROGRAMA ---------------------------------#