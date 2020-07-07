#-------------------------------------------------------------------#
#  SISTEMA..: CONTAS A RECEBER                                      #
#  PROGRAMA.: pol0597                                               #
#  OBJETIVO.: IMPRESSÃO NF DE SERVIÇOS - GRAUNA                     #
#  CLIENTE..: GRAUNA                                                #
#  AUTOR....: Ana Paula                                             #
#  CRIAÇÃO..: 05/06/2007                                            #
#  ALTERADO.:                                                       #
#  12/12/08(Ivo) - Colocar opção de reimpressão                     #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_caminho                CHAR(80),
          p_ies_cons               SMALLINT,
          p_ies_impressao          CHAR(01),
          p_reimpressao            CHAR(01),
          p_num_nff_ini            LIKE nf_mestre.num_nff,
          p_num_nff_fim            LIKE nf_mestre.num_nff,
          comando                  CHAR(80),
          p_num_seq                SMALLINT,
          p_cod_fiscal_compl       INTEGER,
          p_controle               SMALLINT,
          p_salto                  SMALLINT,
          p_tip_info               SMALLINT

   DEFINE p_wfat_servico_mest    RECORD LIKE wfat_servico_mest.*,
          p_wfat_serv_item       RECORD LIKE wfat_serv_item.*,
          p_wfat_servico_hist    RECORD LIKE wfat_servico_hist.*,
          p_cidades              RECORD LIKE cidades.*,
          p_clientes             RECORD LIKE clientes.*,
          p_paises               RECORD LIKE paises.*,
          p_uni_feder            RECORD LIKE uni_feder.*,
          p_cli_end_cobr         RECORD LIKE cli_end_cob.*,
          p_obf_par_fisc_compl   RECORD LIKE obf_par_fisc_compl.*,
          p_par_vdp_pad          RECORD LIKE par_vdp_pad.*

   DEFINE p_nff               RECORD
          num_nff             LIKE wfat_servico_mest.num_nff,
          den_nat_oper        LIKE nat_operacao.den_nat_oper,
          cod_fiscal          INTEGER,                          
          ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
          ins_estadual_emp    LIKE empresa.ins_estadual,
          dat_emissao         LIKE wfat_servico_mest.dat_refer,
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
          num_pedido          LIKE wfat_serv_item.num_pedido,
          num_pedido_cli      LIKE pedidos.num_pedido_cli,
          cod_repres          LIKE pedidos.cod_repres,
           
          num_duplic1         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic1         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd1      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic1         LIKE wfat_servico_dupl.val_duplic,

          num_duplic2         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic2         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd2      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic2         LIKE wfat_servico_dupl.val_duplic,
 
          num_duplic3         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic3         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd3      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic3         LIKE wfat_servico_dupl.val_duplic,

          num_duplic4         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic4         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd4      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic4         LIKE wfat_servico_dupl.val_duplic,

          num_duplic5         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic5         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd5      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic5         LIKE wfat_servico_dupl.val_duplic,

          num_duplic6         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic6         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd6      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic6         LIKE wfat_servico_dupl.val_duplic,

          num_duplic7         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic7         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd7      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic7         LIKE wfat_servico_dupl.val_duplic,

          num_duplic8         LIKE wfat_servico_dupl.num_duplicata,
          dig_duplic8         LIKE wfat_servico_dupl.dig_duplicata,
          dat_vencto_sd8      LIKE wfat_servico_dupl.dat_vencto_sd,
          val_duplic8         LIKE wfat_servico_dupl.val_duplic,   

          val_extenso1        CHAR(130),
          val_extenso2        CHAR(130),
          val_extenso3        CHAR(001), 
          val_extenso4        CHAR(001),

          end_cob_cli         LIKE cli_end_cob.end_cobr,
          cod_uni_feder_cobr  LIKE cidades.cod_uni_feder,
          den_cidade_cob      LIKE cidades.den_cidade,
          
          pct_iss             LIKE wfat_servico_mest.pct_iss,
          val_tot_iss         LIKE wfat_servico_mest.val_tot_iss,
          val_tot_base_iss    LIKE wfat_servico_mest.val_tot_base_iss,
          val_tot_nff         LIKE wfat_servico_mest.val_tot_nff,
          
          den_cnd_pgto        LIKE cond_pgto.den_cnd_pgto,
          nat_oper            LIKE nat_operacao.cod_nat_oper
       END RECORD

 { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

   DEFINE pa_corpo_nff           ARRAY[999] 
          OF RECORD 
             cod_item            LIKE wfat_serv_item.cod_item,
             cod_item_cliente    LIKE cliente_item.cod_item_cliente,
             den_item1           CHAR(050),
             den_item2           CHAR(050),
             cod_unid_med        LIKE wfat_serv_item.cod_unid_med,
             qtd_item            LIKE wfat_serv_item.qtd_item,
             pre_unit            LIKE wfat_serv_item.pre_unit,
             val_liq_item        LIKE wfat_serv_item.val_liq_item,
             num_pedido          LIKE wfat_serv_item.num_pedido,
             num_pedido_cli      LIKE pedidos.num_pedido_cli,             
             pct_iss             LIKE wfat_servico_mest.pct_iss,
             val_tot_iss         LIKE wfat_servico_mest.val_tot_iss
          END RECORD

   DEFINE p_wnotalev       
          RECORD
             num_seq           SMALLINT,
             ies_tip_info      SMALLINT,
             cod_item          LIKE wfat_serv_item.cod_item,
             den_item          CHAR(060),
             cod_unid_med      LIKE wfat_serv_item.cod_unid_med,
             qtd_item          LIKE wfat_serv_item.qtd_item,
             pre_unit          LIKE wfat_serv_item.pre_unit,
             val_liq_item      LIKE wfat_serv_item.val_liq_item,
             pct_iss           LIKE wfat_servico_mest.pct_iss,
             val_tot_iss       LIKE wfat_servico_mest.val_tot_iss,  
             des_texto         CHAR(120),
             num_nff           LIKE wfat_servico_mest.num_nff 
          END RECORD

    DEFINE p_comprime, p_descomprime  CHAR(01),
           p_8lpp                     CHAR(02),
           p_6lpp                     CHAR(02)
 
   DEFINE pa_texto_ped_it            ARRAY[05] 
          OF RECORD
             texto                   CHAR(76)
          END RECORD
 
   DEFINE p_num_linhas               SMALLINT,
          p_num_pagina               SMALLINT,
          p_tot_paginas              SMALLINT
 
   DEFINE p_ies_lista                SMALLINT,
          p_ies_termina_relat        SMALLINT,
          p_linhas_print             SMALLINT

   DEFINE p_saltar_linhas            SMALLINT,
          p_linha                    SMALLINT

   DEFINE p_des_texto                CHAR(120),
          p_val_tot_ipi_acum         DECIMAL(15,3)

   DEFINE p_txt1                     CHAR(60),
          p_txt2                     CHAR(60)
   
   DEFINE { variaveis para o log038 valor por extenso } 
          p_comp_l1                  SMALLINT,
          p_comp_l2                  SMALLINT,
          p_comp_l3                  SMALLINT,
          p_comp_l4                  SMALLINT,
          p_lin1                     CHAR(200),
          p_lin2                     CHAR(200),
          p_lin3                     CHAR(200),
          p_lin4                     CHAR(200)

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
   LET p_versao = "pol0597-05.10.14" 
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT
   CALL log140_procura_caminho("pol0597.iem") RETURNING comando
   OPTIONS
      HELP    FILE comando

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0 THEN
      CALL pol0597_controle()
   END IF

END MAIN

#-------------------------#
FUNCTION pol0597_controle()
#-------------------------#

   CALL log006_exibe_teclas("01", p_versao)

   CALL log130_procura_caminho("pol0597") RETURNING comando    
   OPEN WINDOW w_pol0597 AT 2,2 WITH FORM comando
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar"   "Informar parametros "
         HELP 0009
         MESSAGE ""
         CALL pol0597_inicializa_campos()
         IF log005_seguranca(p_user,"VDP","pol0597","CO") THEN
            IF pol0597_entrada_parametros() THEN
               LET p_ies_cons = TRUE
               NEXT OPTION "Listar"
            END IF
         END IF
      COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
         HELP 1053
         IF NOT p_ies_cons THEN
            ERROR 'Informe previamente os parâmetros!!!'
            CONTINUE MENU
         END IF
         LET p_ies_cons = FALSE
         IF log005_seguranca(p_user,"VDP","pol0597","CO") THEN
            IF pol0597_imprime_nff() THEN
               IF  pol0597_verifica_param_exportacao() = TRUE THEN 
               END IF
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0597
END FUNCTION

#-----------------------------------#
FUNCTION pol0597_entrada_parametros()
#-----------------------------------#
   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0597

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
   CURRENT WINDOW IS w_pol0597

   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0597_inicializa_campos()
#----------------------------------#
   INITIALIZE p_nff.*         , 
              pa_corpo_nff    , 
              p_cidades.*     , 
              p_clientes.*    , 
              p_paises.*      , 
              p_uni_feder.*   , 
              p_par_vdp_pad.*,
              p_obf_par_fisc_compl.* TO NULL
 
   LET p_num_nff_ini        = 0
   LET p_num_nff_fim        = 999999

   LET p_ies_termina_relat  = TRUE

   LET p_linhas_print       = 0
   LET p_val_tot_ipi_acum   = 0
   
END FUNCTION


#----------------------------#
FUNCTION pol0597_imprime_nff()
#----------------------------#    

 IF log028_saida_relat(14,41) IS NOT NULL THEN 
    MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
    IF p_ies_impressao = "S" THEN 
       IF g_ies_ambiente = "U" THEN
          START REPORT pol0597_relat TO PIPE p_nom_arquivo
       ELSE 
          CALL log150_procura_caminho ('LST') RETURNING p_caminho
          LET p_caminho = p_caminho CLIPPED, 'pol0597.tmp' 
          START REPORT pol0597_relat TO p_caminho 
       END IF 
    ELSE
       START REPORT pol0597_relat TO p_nom_arquivo
    END IF
 ELSE
    RETURN FALSE
 END IF  

   CURRENT WINDOW IS w_pol0597

   LET p_comprime    = ascii 15 
   LET p_descomprime = ascii 18 
   LET p_8lpp        = ascii 27, "0" 
   LET p_6lpp        = ascii 27, "2" 
   LET p_tot_paginas = 0
   LET p_num_pagina  = 0

   IF p_reimpressao = "S" THEN
       LET p_reimpressao = "R"
   END IF
   
   DECLARE cq_wfat_servico_mest CURSOR WITH HOLD FOR
    SELECT *
      FROM wfat_servico_mest
     WHERE cod_empresa  = p_cod_empresa
       AND num_nff     >= p_num_nff_ini
       AND num_nff     <= p_num_nff_fim
       AND ies_impr_nff = p_reimpressao
       #AND nom_usuario = p_user
     ORDER BY num_nff

   FOREACH cq_wfat_servico_mest INTO p_wfat_servico_mest.*

      {mostra nf em processam.}
      DISPLAY p_wfat_servico_mest.num_nff TO num_nff_proces 

      CALL pol0597_cria_tabela_temporaria()

      LET p_nff.num_nff            = p_wfat_servico_mest.num_nff
      #LET p_nff.cod_fiscal         = p_wfat_servico_mest.cod_fiscal

      LET p_nff.den_nat_oper       = pol0597_den_nat_oper()
      LET p_nff.nat_oper           = p_wfat_servico_mest.cod_nat_oper
      LET p_nff.dat_emissao        = p_wfat_servico_mest.dat_refer    

      LET p_nff.pct_iss            = p_wfat_servico_mest.pct_iss
      LET p_nff.val_tot_iss        = p_wfat_servico_mest.val_tot_iss
      LET p_nff.val_tot_base_iss   = p_wfat_servico_mest.val_tot_base_iss

      LET p_nff.val_tot_nff        = p_wfat_servico_mest.val_tot_nff

      CALL pol0597_busca_dados_clientes(p_wfat_servico_mest.cod_cliente)
      LET p_nff.nom_destinatario   = p_clientes.nom_cliente
      LET p_nff.num_cgc_cpf        = p_clientes.num_cgc_cpf
      LET p_nff.end_destinatario   = p_clientes.end_cliente
      LET p_nff.den_bairro         = p_clientes.den_bairro
      LET p_nff.cod_cep            = p_clientes.cod_cep
      LET p_nff.cod_cliente        = p_clientes.cod_cliente

      CALL pol0597_busca_dados_cidades(p_clientes.cod_cidade)
      LET p_nff.den_cidade         = p_cidades.den_cidade          
      LET p_nff.num_telefone       = p_clientes.num_telefone
      LET p_nff.cod_uni_feder      = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual       = p_clientes.ins_estadual
      LET p_nff.hora_saida         = EXTEND(CURRENT, HOUR TO MINUTE)

      CALL pol0597_busca_cof_compl()

      CALL pol0597_busca_nome_pais()
      LET p_nff.den_pais = p_paises.den_pais              

      CALL pol0597_busca_dados_duplicatas()

      CALL pol0597_carrega_end_cobranca()

      CALL pol0597_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0597_carrega_tabela_temporaria() {corpo todo da nota}

      CALL pol0597_grava_hist_faturamento()
      
      CALL pol0597_carrega_historico()

      LET p_nff.den_cnd_pgto = pol0597_den_cnd_pgto()
      LET p_ies_lista = TRUE

      LET p_nff.num_pedido = p_wfat_serv_item.num_pedido
      
      CALL pol0597_busca_dados_pedido()
    
      CALL pol0597_calcula_total_de_paginas()

      CALL pol0597_monta_relat()

      #### marca nf que ja foi impressa ####

      UPDATE wfat_servico_mest 
         SET ies_impr_nff = p_reimpressao
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_wfat_servico_mest.num_nff
         #AND nom_usuario = p_user

      CALL pol0597_inicializa_campos()

   END FOREACH

   FINISH REPORT pol0597_relat

   IF p_ies_lista THEN
     IF  p_ies_impressao = "S" THEN
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
      ERROR " Nao existem dados para serem listados. "
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION pol0597_cria_tabela_temporaria()
#---------------------------------------#
   WHENEVER ERROR CONTINUE
   CALL log085_transacao("BEGIN") 

   DROP TABLE wnotalev;
   CREATE  TABLE wnotalev
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
     ) ;
     
   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-WNOTALEV")
   END IF

   CALL log085_transacao("COMMIT") 
   WHENEVER ERROR STOP
 
END FUNCTION

#----------------------------#
FUNCTION pol0597_monta_relat()
#----------------------------#

   LET p_linha = 0
   LET p_num_pagina = 0
   CALL pol0597_calcula_total_de_paginas()
   
   DECLARE cq_wnotalev CURSOR FOR
    SELECT *
      FROM wnotalev
     WHERE ies_tip_info < 3
   ORDER BY 1

   FOREACH cq_wnotalev INTO p_wnotalev.*

      LET p_wnotalev.num_nff     = p_wfat_servico_mest.num_nff
      OUTPUT TO REPORT pol0597_relat(p_wnotalev.*)

   END FOREACH

   { imprimir as linhas que faltam para completar o corpo da nota}
   { somente se o numero de linhas da nota nao for multiplo de 8 }
   #IF p_ies_termina_relat = TRUE THEN
   IF p_saltar_linhas THEN
      LET p_wnotalev.num_nff      = p_wfat_servico_mest.num_nff
      LET p_wnotalev.num_seq      = p_wnotalev.num_seq + 1
      LET p_wnotalev.ies_tip_info = 4
   
      OUTPUT TO REPORT pol0597_relat(p_wnotalev.*)
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0597_busca_dados_duplicatas()
#----------------------------------------#

   DEFINE p_wfat_servico_dupl RECORD LIKE wfat_servico_dupl.*,
          p_contador          SMALLINT

   LET p_contador = 0

   DECLARE cq_duplic CURSOR FOR
   SELECT * 
   FROM wfat_servico_dupl
   WHERE cod_empresa = p_cod_empresa
     AND num_solicit = p_wfat_servico_mest.num_solicit
   ORDER BY cod_empresa,
            num_duplicata,
            dig_duplicata,
            dat_vencto_sd

   FOREACH cq_duplic INTO p_wfat_servico_dupl.*

      LET p_contador = p_contador + 1
      CASE p_contador
         WHEN 1  
            LET p_nff.num_duplic1    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic1    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd1 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic1    = p_wfat_servico_dupl.val_duplic
         WHEN 2      
            LET p_nff.num_duplic2    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic2    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd2 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic2    = p_wfat_servico_dupl.val_duplic
         WHEN 3      
            LET p_nff.num_duplic3    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic3    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd3 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic3    = p_wfat_servico_dupl.val_duplic
        WHEN 4
            LET p_nff.num_duplic4    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic4    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd4 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic4    = p_wfat_servico_dupl.val_duplic
{         WHEN 5
            LET p_nff.num_duplic5    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic5    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd5 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic5    = p_wfat_servico_dupl.val_duplic
         WHEN 6
            LET p_nff.num_duplic6    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic6    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd6 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic6    = p_wfat_servico_dupl.val_duplic
         WHEN 7
            LET p_nff.num_duplic7    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic7    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd7 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic7    = p_wfat_servico_dupl.val_duplic
         WHEN 8
            LET p_nff.num_duplic8    = p_wfat_servico_dupl.num_duplicata
            LET p_nff.dig_duplic8    = p_wfat_servico_dupl.dig_duplicata
            LET p_nff.dat_vencto_sd8 = p_wfat_servico_dupl.dat_vencto_sd
            LET p_nff.val_duplic8    = p_wfat_servico_dupl.val_duplic   
}
         OTHERWISE   
            EXIT FOREACH
      END CASE

   END FOREACH

   CALL pol0597_extenso()

END FUNCTION     

#-----------------------------------#
FUNCTION pol0597_busca_dados_pedido()
#-----------------------------------#  

   SELECT num_pedido_cli,
          cod_repres
     INTO p_nff.num_pedido_cli,
          p_nff.cod_repres
     FROM pedidos
    WHERE cod_empresa  = p_cod_empresa 
      AND num_pedido   = p_wfat_serv_item.num_pedido

   IF sqlca.sqlcode <> 0 THEN
      INITIALIZE p_nff.num_pedido_cli,                       
                 p_nff.cod_repres TO  NULL                    
   END IF

END FUNCTION


#-------------------------#
 FUNCTION pol0597_extenso()
#-------------------------#

   INITIALIZE p_lin1,
              p_lin2,
              p_lin3,
              p_lin4 TO NULL

   LET p_comp_l1 = 130
   LET p_comp_l2 = 130
   LET p_comp_l3 = 130
   LET p_comp_l4 = 130

  CALL log038_extenso(p_nff.val_duplic1,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
      RETURNING p_lin1, p_lin2, p_lin3, p_lin4

END FUNCTION

#-------------------------------------#
FUNCTION pol0597_carrega_end_cobranca()
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
FUNCTION pol0597_carrega_historico()
#----------------------------------#

   INITIALIZE p_wfat_servico_hist.* TO NULL
   WHENEVER ERROR CONTINUE
  
   DECLARE cq_whist CURSOR FOR
   SELECT *
   FROM wfat_servico_hist
   WHERE cod_empresa = p_cod_empresa
     AND num_solicit = p_wfat_servico_mest.num_solicit
#     AND nom_usuario = p_user

   FOREACH cq_whist INTO p_wfat_servico_hist.* 

      IF p_wfat_servico_hist.tex_hist_1_1 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_1_1,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_2_1 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_2_1,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_3_1 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_3_1,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_4_1 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_4_1,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_1_2 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_1_2,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_2_2 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_2_2,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_3_2 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_3_2,3)
      END IF
      IF p_wfat_servico_hist.tex_hist_4_2 <> " " THEN
         CALL pol0597_insert_array(p_wfat_servico_hist.tex_hist_4_2,3)
      END IF

   END FOREACH 

END FUNCTION

#----------------------------------#
FUNCTION pol0597_carrega_corpo_nff()
#----------------------------------#

   DEFINE p_fat_conver         LIKE ctr_unid_med.fat_conver,
          p_cod_unid_med_cli   LIKE ctr_unid_med.cod_unid_med_cli
   DEFINE p_ind                SMALLINT,
          p_count              SMALLINT

   LET p_ind = 1
   LET p_count = 0   
#  LET p_nff.val_tot_mercadoria = 0

   DECLARE cq_wfat_serv_item CURSOR FOR
   SELECT wfat_serv_item.*
      FROM wfat_serv_item, OUTER item
   WHERE wfat_serv_item.cod_empresa = p_cod_empresa
     AND wfat_serv_item.num_solicit = p_wfat_servico_mest.num_solicit
     AND item.cod_empresa = p_cod_empresa
     AND item.cod_item    = wfat_serv_item.cod_item

   FOREACH cq_wfat_serv_item INTO p_wfat_serv_item.*

      INITIALIZE g_cod_item_cliente TO NULL
 
      SELECT cod_item_cliente
        INTO g_cod_item_cliente    
        FROM cliente_item
       WHERE cod_empresa        = p_cod_empresa
         AND cod_cliente_matriz = p_wfat_servico_mest.cod_cliente
         AND cod_item           = p_wfat_serv_item.cod_item

      LET pa_corpo_nff[p_ind].cod_item         = p_wfat_serv_item.cod_item
      LET pa_corpo_nff[p_ind].cod_item_cliente = g_cod_item_cliente

      IF LENGTH(p_wfat_serv_item.den_item) > 50 THEN
         CALL substr(p_wfat_serv_item.den_item,50,2,'N') 
              RETURNING pa_corpo_nff[p_ind].den_item1,
                        pa_corpo_nff[p_ind].den_item2
      ELSE
         LET pa_corpo_nff[p_ind].den_item1   = p_wfat_serv_item.den_item[01,50]
         LET pa_corpo_nff[p_ind].den_item2   = ""
      END IF

      LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_serv_item.cod_unid_med  
      LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_serv_item.qtd_item

      LET pa_corpo_nff[p_ind].pre_unit       = p_wfat_serv_item.pre_unit 

      LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_serv_item.val_liq_item

      LET pa_corpo_nff[p_ind].pct_iss      = p_wfat_servico_mest.pct_iss

      LET pa_corpo_nff[p_ind].val_tot_iss  = (p_wfat_servico_mest.pct_iss *
                                              p_wfat_serv_item.val_liq_item)/100
                                             
      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1

   END FOREACH

END FUNCTION

#------------------------------------------#
FUNCTION pol0597_carrega_tabela_temporaria()
#------------------------------------------#

   DEFINE i, j       SMALLINT,
          p_val_merc DECIMAL(15,2)   

   LET i             = 1
   LET p_num_seq     = 0
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

   DECLARE cq_obf_par CURSOR FOR
   SELECT * 
   FROM obf_par_fisc_compl
   WHERE empresa = p_cod_empresa
     AND nat_oper_grp_desp = p_wfat_servico_mest.cod_nat_oper
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
             p_wfat_servico_mest.val_tot_nff * p_par_vdp_pad.par_val / 100
             USING "###,###,##&.&&"
         CALL pol0597_insert_array(p_des_texto,3)
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
                p_wfat_servico_mest.val_tot_nff * p_par_vdp_pad.par_val / 100
                USING "###,###,##&.&&"
            CALL pol0597_insert_array(p_des_texto,3)
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
                   p_wfat_servico_mest.val_tot_nff * p_par_vdp_pad.par_val / 100
                   USING "###,###,##&.&&"
               CALL pol0597_insert_array(p_des_texto,3)
            END IF
         END IF
      END IF
   END IF

   END FOREACH

END FUNCTION

#-----------------------------------------#
FUNCTION pol0597_calcula_total_de_paginas()
#-----------------------------------------#

   LET p_saltar_linhas = TRUE
   
   SELECT COUNT(*)
     INTO p_num_linhas
     FROM wnotalev
    WHERE ies_tip_info < 3
    
   { 08 = numero de linhas do corpo da nota fiscal }

   #IF p_num_linhas IS NOT NULL AND 
   IF p_num_linhas > 0 THEN 
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 06 )) / 06
      IF (p_num_linhas MOD 06 ) > 0 THEN 
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE 
         #LET p_ies_termina_relat = FALSE
         LET p_saltar_linhas = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0597_den_nat_oper()
#-----------------------------#

   DEFINE p_nat_operacao RECORD LIKE nat_operacao.*

   WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
      INTO p_nat_operacao.*
   FROM nat_operacao
   WHERE cod_nat_oper = p_wfat_servico_mest.cod_nat_oper
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
FUNCTION pol0597_busca_cof_compl()
#------------------------------------#

   LET p_cod_fiscal_compl = 0
   LET p_nff.cod_fiscal   = 0

   WHENEVER ERROR CONTINUE

      SELECT cod_fiscal
         INTO p_nff.cod_fiscal
      FROM fiscal_par
      WHERE cod_empresa   = p_cod_empresa
        AND cod_nat_oper  = p_wfat_servico_mest.cod_nat_oper
        AND cod_uni_feder = p_cidades.cod_uni_feder
      IF sqlca.sqlcode <> 0 THEN
         LET p_nff.cod_fiscal = 0
      END IF   

      SELECT cod_fiscal_compl
         INTO p_cod_fiscal_compl
      FROM fiscal_par_compl
      WHERE cod_empresa=p_cod_empresa
        AND cod_nat_oper=p_wfat_servico_mest.cod_nat_oper
        AND cod_uni_feder=p_cidades.cod_uni_feder
      IF sqlca.sqlcode <> 0 THEN
         LET p_cod_fiscal_compl = 0
      END IF   

   WHENEVER ERROR STOP

END FUNCTION

#-----------------------------#
FUNCTION pol0597_den_cnd_pgto()
#-----------------------------#

   DEFINE p_den_cnd_pgto    LIKE cond_pgto.den_cnd_pgto,
          p_pct_desp_finan  LIKE cond_pgto.pct_desp_finan,
          p_pct_enc_finan   DECIMAL(05,3)

   WHENEVER ERROR CONTINUE
   SELECT den_cnd_pgto,pct_desp_finan
      INTO p_den_cnd_pgto,p_pct_desp_finan
   FROM cond_pgto
   WHERE cod_cnd_pgto = p_wfat_servico_mest.cod_cnd_pgto
   WHENEVER ERROR STOP
 
#  IF p_pct_desp_finan IS NOT NULL
#     AND p_pct_desp_finan > 1 THEN
#     LET p_pct_enc_finan = (( p_pct_desp_finan - 1 ) * 100 )
#     LET p_des_texto = "ENCARGO FINANCEIRO: ",  
#         p_pct_enc_finan USING "#&.&&&"," %"
#     CALL pol0597_insert_array(p_des_texto)
#  END IF 

   RETURN p_den_cnd_pgto

END FUNCTION 

#---------------------------------------------------#
FUNCTION pol0597_busca_dados_clientes(p_cod_cliente)
#---------------------------------------------------#

   DEFINE p_cod_cliente      LIKE clientes.cod_cliente,
          p_aux_nom_cliente  LIKE clientes.nom_cliente

   INITIALIZE p_clientes.* TO NULL
   WHENEVER ERROR CONTINUE
   SELECT *
      INTO p_clientes.*
   FROM clientes
   WHERE cod_cliente = p_wfat_servico_mest.cod_cliente
   WHENEVER ERROR STOP

END FUNCTION

#--------------------------------#
FUNCTION pol0597_busca_nome_pais()                   
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
FUNCTION pol0597_busca_dados_cidades(p_cod_cidade)
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

#------------------------------------------#
FUNCTION pol0597_verifica_param_exportacao()
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
    WHERE cod_cliente = p_wfat_servico_mest.cod_cliente

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

#ivo - A NF da GRAF só comporta 50 caracteres por linha.
#      Daí a necessidade de dividir o texto se o mesmo
#      posuir mais de 50 caracteres

#------------------------------------------------#
FUNCTION pol0597_insert_array(p_des_texto,p_info)
#------------------------------------------------#

   DEFINE p_des_texto CHAR(120),
          p_info      SMALLINT 

   LET p_tip_info = p_info
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotalev
      VALUES (p_num_seq,p_tip_info,"","","","","","","","", 
              p_des_texto,"")

END FUNCTION   

#----------------------------------------#
FUNCTION pol0597_insert_texto(p_des_texto)
#----------------------------------------#

   DEFINE p_des_texto CHAR(120)
   
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotalev
      VALUES (p_num_seq,3,"","","","","","","","",
              p_des_texto,"")

END FUNCTION 

#----------------------------------------#
FUNCTION pol0597_grava_hist_faturamento()
#----------------------------------------#

   IF p_wfat_servico_mest.cod_texto_1 <> 0 OR
      p_wfat_servico_mest.cod_texto_2 <> 0 OR   
      p_wfat_servico_mest.cod_texto_3 <> 0 THEN
  
      DECLARE cq_texto_nf CURSOR FOR
       SELECT des_texto
         FROM texto_nf
        WHERE cod_texto IN (p_wfat_servico_mest.cod_texto_1,
                            p_wfat_servico_mest.cod_texto_2,
                            p_wfat_servico_mest.cod_texto_3)

      FOREACH cq_texto_nf INTO p_des_texto
         IF p_des_texto IS NOT NULL THEN
            CALL pol0597_insert_array(p_des_texto,3)
         END IF
                  
         {IF LENGTH(p_des_texto) > 0 AND
            LENGTH(p_des_texto) <= 60 THEN
            CALL pol0597_insert_array(p_des_texto,3)
         ELSE
            LET p_txt1 = p_des_texto[1,60]
            LET p_txt2 = p_des_texto[61,120]
            CALL pol0597_insert_array(p_txt1,3)
            CALL pol0597_insert_array(p_txt2,3)
            LET p_txt1 = NULL
            LET p_txt2 = NULL
         END IF}
      END FOREACH               
   END IF

END FUNCTION

#------------------------------#
REPORT pol0597_relat(p_wnotalev)
#------------------------------#

   DEFINE i         SMALLINT,
          l_nulo    CHAR(10),
          p_contt   SMALLINT 

   DEFINE p_wnotalev  
          RECORD
             num_seq             SMALLINT,
             ies_tip_info        SMALLINT,
             cod_item            LIKE wfat_serv_item.cod_item,
             den_item            CHAR(060),
             cod_unid_med        LIKE wfat_serv_item.cod_unid_med,
             qtd_item            LIKE wfat_serv_item.qtd_item,
             pre_unit            LIKE wfat_serv_item.pre_unit,
             val_liq_item        LIKE wfat_serv_item.val_liq_item,
             pct_iss             LIKE wfat_servico_mest.pct_iss,
             val_tot_iss         LIKE wfat_servico_mest.val_tot_iss,
             des_texto           CHAR(120),
             num_nff             LIKE wfat_servico_mest.num_nff
          END RECORD

   DEFINE p_for                  SMALLINT,
          p_sal                  SMALLINT,
          p_des_folha            CHAR(100) 

   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   66

   ORDER EXTERNAL BY p_wnotalev.num_nff,
                     p_wnotalev.num_seq

   FORMAT

   PAGE HEADER

      LET p_num_pagina = p_num_pagina + 1
      PRINT COLUMN 001, p_comprime
      PRINT COLUMN 149, "X",
            COLUMN 193, p_nff.num_nff USING "&&&&&&"
      SKIP 3 LINES
      PRINT COLUMN 015, p_nff.den_nat_oper,
            COLUMN 099, p_nff.cod_fiscal      USING "&&&&"
      SKIP 1 LINES
      PRINT COLUMN 015, p_nff.nom_destinatario CLIPPED," - ",p_nff.cod_cliente CLIPPED,
            COLUMN 153, p_nff.num_cgc_cpf,
            COLUMN 193, p_nff.dat_emissao USING "DD/MM/YYYY"
      SKIP 1 LINES
      PRINT COLUMN 015, p_nff.end_destinatario,
            COLUMN 118, p_nff.den_bairro,
            COLUMN 165, p_nff.cod_cep
      #SKIP 1 LINES
      PRINT COLUMN 015, p_nff.den_cidade,
            COLUMN 118, p_nff.num_telefone[1,13],
            COLUMN 140, p_nff.cod_uni_feder,
            COLUMN 150, p_nff.ins_estadual
      SKIP 2 LINES
      #PRINT COLUMN 062, p_nff.num_pedido_cli
      PRINT COLUMN 015, p_lin1[1,130],
            COLUMN 110, p_lin2[1,38],
      #PRINT COLUMN 016, p_lin3[1,61]
            COLUMN 193, p_nff.dat_vencto_sd1
    SKIP 18 LINES
    
   BEFORE GROUP OF p_wnotalev.num_nff
      SKIP TO TOP OF PAGE

   ON EVERY ROW

      LET p_linhas_print = 1         
      CASE
         WHEN p_wnotalev.ies_tip_info = 1

            IF p_linhas_print = 1 AND p_wnotalev.cod_item IS NOT NULL THEN
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med
            END IF

            IF p_linhas_print = 2 AND p_wnotalev.cod_item IS NOT NULL THEN 
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med
            ELSE
               PRINT
            END IF

            IF p_linhas_print = 3 AND p_wnotalev.cod_item IS NOT NULL THEN
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med
            ELSE
               PRINT
            END IF

            IF p_linhas_print = 4 AND p_wnotalev.cod_item IS NOT NULL THEN 
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med,
                     COLUMN 183, p_nff.pct_iss            USING "&&",
                     COLUMN 195, p_nff.val_tot_iss        USING "##,###,##&.&&"
            ELSE
               PRINT  
               PRINT COLUMN 183, p_nff.pct_iss            USING "&&",
                     COLUMN 195, p_nff.val_tot_iss        USING "##,###,##&.&&"
            END IF
            
            IF p_linhas_print = 5 AND p_wnotalev.cod_item IS NOT NULL THEN
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med
            ELSE
               PRINT
            END IF

            IF p_linhas_print = 6 AND p_wnotalev.cod_item IS NOT NULL THEN 
               PRINT COLUMN 014, p_wnotalev.cod_item[1,6],
                     COLUMN 024, p_wnotalev.den_item[1,50],
                     COLUMN 080, p_wnotalev.qtd_item      USING "##,##&.&&&",
                     COLUMN 097, p_wnotalev.cod_unid_med, 
                     COLUMN 190, p_nff.val_tot_base_iss   USING "##,###,##&.&&"
            ELSE
               PRINT
               PRINT COLUMN 190, p_nff.val_tot_base_iss   USING "##,###,##&.&&"
               SKIP 1 LINES
               PRINT COLUMN 190, p_nff.val_tot_nff    USING "##,###,##&.&&"
             	SKIP 1 LINES
	             PRINT COLUMN 190, p_nff.val_tot_nff    USING "##,###,##&.&&"
            END IF

            LET p_linhas_print = p_linhas_print + 1              
            
         WHEN p_wnotalev.ies_tip_info = 2
            PRINT COLUMN 012, p_wnotalev.den_item[1,50]
            LET p_linhas_print = p_linhas_print + 1

         WHEN p_wnotalev.ies_tip_info = 4
            WHILE TRUE
               IF p_linhas_print < 6 THEN 
                  PRINT 
                  LET p_linhas_print = p_linhas_print + 1        
               ELSE 
                  EXIT WHILE
               END IF          
            END WHILE

      END CASE
      
      IF p_linhas_print = 6 THEN { nr. de linhas do corpo da nota }
         IF p_num_pagina = p_tot_paginas THEN 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&" 
         ELSE 
            LET p_des_folha = "Folha ", p_num_pagina    USING "&&","/",
                               p_tot_paginas USING "&&"," - Continua" 
         END IF
         IF p_num_pagina = p_tot_paginas THEN
      
       	    SKIP 1 LINES 

           LET p_controle = 0
           DECLARE cq_texto CURSOR FOR
           SELECT num_seq,
                  des_texto
             FROM wnotalev
            WHERE ies_tip_info = 3
           ORDER BY 1
           FOREACH cq_texto INTO p_num_seq,
                                 p_des_texto
                  
              PRINT COLUMN 015,p_des_texto
              LET p_controle = p_controle + 1
   
              IF p_controle = 8 THEN 
                 EXIT FOREACH
              END IF
                
           END FOREACH
           SKIP 6 LINES
           PRINT COLUMN 190, p_nff.num_nff USING "&&&&&&" 
           LET p_num_pagina = 0
       END IF
       LET p_linhas_print = 0
   END IF
END REPORT
#------------------------------- FIM DE PROGRAMA ------------------------------#
