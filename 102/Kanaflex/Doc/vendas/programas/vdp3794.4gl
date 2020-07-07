###PARSER-Não remover esta linha(Framework Logix)###
#-----------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                     #
# PROGRAMA: VDP3794                                               #
# MODULOS.: VDP3794 - LOG0010 - LOG0040 - LOG0050 - LOG0060       #
#           LOG0280 - LOG0380 - LOG1300 - LOG1400                 #
# OBJETIVO: EMISSAO DE NOTAS FISCAIS SAIDA - KANAFLEX             #
# AUTOR...: HELTON R. HEDLER                                      #
# DATA....: 21/06/2001                                            #
#-----------------------------------------------------------------#
# OBJETIVO: AUMENTAR A QTD. DE CASAS INTEIRAS DO PESO UNITÁRIO    #
#           IMPRESSO                                              #
# AUTOR...: RAFAELA BOSSE                                         #
# DATA....: 19/12/2003                                            #
#-----------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
         p_user                   LIKE usuario.nom_usuario,
         p_status                 SMALLINT,
         p_nom_arquivo            CHAR(100),
         p_nom_arquivo_lst        CHAR(100),
         p_ies_impressao          CHAR(01),
         p_num_nff_ini            LIKE nf_mestre.num_nff,
         p_num_nff_fim            LIKE nf_mestre.num_nff,
         comando                  CHAR(80),
         p_max                    CHAR(01),
         p_teste                  SMALLINT,
         p_ies_reimp              CHAR(01),
         p_texto_aux_1            CHAR(50),
         p_texto_aux_2            CHAR(50),
         p_historico              CHAR(600),
         p_texto                  CHAR(600),
         p_dat_saida              DATE,
         p_hora_saida             DATETIME HOUR TO MINUTE

  DEFINE p_wfat_mestre            RECORD LIKE wfat_mestre.*,
         p_wfat_item              RECORD LIKE wfat_item.*,
         p_wfat_item_fiscal       RECORD LIKE wfat_item_fiscal.*,
         p_wfat_historico         RECORD LIKE wfat_historico.*,
         p_cidades                RECORD LIKE cidades.*,
         p_empresa                RECORD LIKE empresa.*,
         p_embalagem              RECORD LIKE embalagem.*,
         p_clientes               RECORD LIKE clientes.*,
         p_transport              RECORD LIKE clientes.*,
         p_ped_itens_texto        RECORD LIKE ped_itens_texto.*,
         p_subst_trib_uf          RECORD LIKE subst_trib_uf.*,
         p_cli_end_cobr           RECORD LIKE cli_end_cob.*

  DEFINE p_nff                    RECORD
                     num_nff             LIKE wfat_mestre.num_nff,
                     cod_cliente         LIKE wfat_mestre.cod_cliente,
                     den_nat_oper        LIKE nat_operacao.den_nat_oper,
                     cod_fiscal          LIKE wfat_mestre.cod_fiscal,
                     den_cod_fiscal1     LIKE codigo_fiscal.den_cod_fiscal,
                     den_cod_fiscal2     LIKE codigo_fiscal.den_cod_fiscal,
                     cod_fiscal1         LIKE wfat_mestre_ent.cod_fiscal,
                     cod_fiscal2         LIKE wfat_mestre_ent.cod_fiscal,
                     ins_estadual_trib   LIKE subst_trib_uf.ins_estadual,
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

                     num_duplic1         LIKE wfat_duplic.num_duplicata,
                     dig_duplic1         LIKE wfat_duplic.dig_duplicata,
                     val_duplic1         LIKE wfat_duplic.val_duplic,
                     dat_vencto1         LIKE wfat_duplic.dat_vencto_sd,
                     num_duplic2         LIKE wfat_duplic.num_duplicata,
                     dig_duplic2         LIKE wfat_duplic.dig_duplicata,
                     val_duplic2         LIKE wfat_duplic.val_duplic,
                     dat_vencto2         LIKE wfat_duplic.dat_vencto_sd,
                     num_duplic3         LIKE wfat_duplic.num_duplicata,
                     dig_duplic3         LIKE wfat_duplic.dig_duplicata,
                     val_duplic3         LIKE wfat_duplic.val_duplic,
                     dat_vencto3         LIKE wfat_duplic.dat_vencto_sd,
                     num_duplic4         LIKE wfat_duplic.num_duplicata,
                     dig_duplic4         LIKE wfat_duplic.dig_duplicata,
                     val_duplic4         LIKE wfat_duplic.val_duplic,
                     dat_vencto4         LIKE wfat_duplic.dat_vencto_sd,
                     num_duplic5         LIKE wfat_duplic.num_duplicata,
                     dig_duplic5         LIKE wfat_duplic.dig_duplicata,
                     val_duplic5         LIKE wfat_duplic.val_duplic,
                     dat_vencto5         LIKE wfat_duplic.dat_vencto_sd,

                     val_extenso1        CHAR(068),
                     val_extenso2        CHAR(068),
                     val_extenso3        CHAR(068),
                     val_extenso4        CHAR(068),

                     end_cob_cli         LIKE cli_end_cob.end_cobr,
                     den_bairro_cob      LIKE cli_end_cob.den_bairro,
                     cod_cep_cob         LIKE cli_end_cob.cod_cep,
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
                     qtd_volume          LIKE wfat_mestre.qtd_volumes1,
                     des_especie         CHAR(035),
                     den_marca           LIKE clientes.den_marca,
                     num_pri_volume      LIKE wfat_mestre.num_pri_volume,
                     num_ult_volume      LIKE wfat_mestre.num_pri_volume,
                     pes_tot_bruto       LIKE wfat_mestre.pes_tot_bruto,
                     pes_tot_liquido     LIKE wfat_mestre.pes_tot_liquido,
                     cubagem             DECIMAL(9,3),

                     num_pedido          LIKE wfat_item.num_pedido,
                     cod_repres          LIKE wfat_mestre.cod_repres,
                     nom_repres          LIKE representante.nom_repres,
                     num_suframa         LIKE clientes.num_suframa,
                     num_pedido_repres   LIKE pedidos.num_pedido_repres,
                     num_pedido_cli      LIKE pedidos.num_pedido_cli
                                  END RECORD

  DEFINE pa_corpo_nff             ARRAY[999] OF RECORD
                     cod_item            CHAR(016),   #  LIKE wfat_item.cod_item,
                     num_sequencia       LIKE wfat_item.num_sequencia,
                     num_pedido          LIKE wfat_item.num_pedido,
                     den_item1           CHAR(036),
                     den_item2           CHAR(036),
                     pes_unit            LIKE wfat_item.pes_unit,
                     cod_fiscal          LIKE wfat_item_fiscal.cod_fiscal,
                     cod_cla_fisc        LIKE wfat_item.cod_cla_fisc,
                     cod_origem          LIKE wfat_mestre.cod_origem,
                     cod_tributacao      LIKE wfat_mestre.cod_tributacao,
                     cod_unid_med        LIKE wfat_item.cod_unid_med,
                     qtd_item            LIKE wfat_item.qtd_item,
                     qtd_item_t          LIKE wfat_item.qtd_item,
                     pre_unit            LIKE wfat_item.pre_unit_nf,
                     desconto            CHAR(010),
                     val_liq_item        LIKE wfat_item.val_liq_item,
                     pct_icm             LIKE wfat_mestre.pct_icm,
                     pct_ipi             LIKE wfat_item.pct_ipi,
                     val_ipi             LIKE wfat_item.val_ipi,
                     val_icm_ret         LIKE wfat_item.val_icm_ret,
                     ies_bonificacao     CHAR(001),
                     num_seq_nfitem      LIKE nf_item.num_sequencia
                                  END RECORD

  DEFINE p_wnotakana              RECORD
                     num_seq             SMALLINT,
                     ies_tip_info        SMALLINT,
                     cod_item            CHAR(016),   #  LIKE wfat_item.cod_item,
                     pes_unit            LIKE wfat_item.pes_unit,
                     den_item            CHAR(36),
                     cod_fiscal          LIKE wfat_item_fiscal.cod_fiscal,
                     cod_cla_fisc        LIKE wfat_item.cod_cla_fisc,
                     cod_origem          LIKE wfat_mestre.cod_origem,
                     cod_tributacao      LIKE wfat_mestre.cod_tributacao,
                     cod_unid_med        LIKE wfat_item.cod_unid_med,
                     qtd_item            LIKE wfat_item.qtd_item,
                     pre_unit            LIKE wfat_item.pre_unit_nf,
                     desconto            CHAR(010),
                     val_liq_item        LIKE wfat_item.val_liq_item,
                     pct_icm             LIKE wfat_mestre.pct_icm,
                     pct_ipi             LIKE wfat_item.pct_ipi,
                     val_ipi             LIKE wfat_item.val_ipi,
                     des_texto           CHAR(120),
                     num_pedido          LIKE pedidos.num_pedido,
                     num_seq_nfitem      LIKE nf_item.num_sequencia,
                     ies_bonificacao     CHAR(01),
                     num_nff             LIKE wfat_mestre.num_nff
                                  END RECORD

   DEFINE p_end_entrega           RECORD
                     end_entrega         LIKE clientes.end_cliente,
                     den_bairro          LIKE clientes.den_bairro,
                     den_cidade          LIKE cidades.den_cidade,
                     cod_uni_feder       LIKE cidades.cod_uni_feder
                                  END RECORD

   DEFINE p_consignat             RECORD
                     den_consignat       LIKE clientes.nom_cliente,
                     end_consignat       LIKE clientes.end_cliente,
                     num_cgc_cpf         LIKE clientes.num_cgc_cpf,
                     ins_estadual        LIKE clientes.ins_estadual,
                     den_cidade          LIKE cidades.den_cidade,
                     cod_uni_feder       LIKE cidades.cod_uni_feder
                                  END RECORD

   DEFINE p_comprime, p_descomprime      CHAR(01),
          p_6lpp,     p_8lpp             CHAR(02)

   DEFINE pa_historico            ARRAY[08] OF RECORD
                     texto               CHAR(100)
                                  END RECORD

   DEFINE pa_texto                ARRAY[20] OF RECORD
                     texto               CHAR(50)
                                  END RECORD

   DEFINE pa_cla_fisc             ARRAY[50] OF RECORD          #ARRAY[400] OF RECORD
                     cod_cla_fisc      LIKE wfat_item.cod_cla_fisc,
                     index             CHAR(01),
                     cla_fisc_nff      CHAR(02)
                                  END RECORD

   DEFINE pa_texto_ped_it         ARRAY[05] OF RECORD
                     texto               CHAR(076)
                                  END RECORD

   DEFINE pa_texto_obs            ARRAY[18] OF RECORD
                     texto               CHAR(050)
                                  END RECORD

   DEFINE ma_array                ARRAY[9] OF RECORD
          den_cod_fiscal          LIKE codigo_fiscal.den_cod_fiscal,
          cod_fiscal              LIKE codigo_fiscal.cod_fiscal
                                  END RECORD

   DEFINE p_num_linhas            SMALLINT,
          p_num_pagina            SMALLINT,
          p_tot_paginas           SMALLINT

   DEFINE p_houve_end_ent         SMALLINT,
          p_houve_consig          SMALLINT,
          p_ies_lista             SMALLINT,
          p_ies_termina_relat     SMALLINT,
          p_ult_linha             SMALLINT,
          p_linhas                SMALLINT,
          p_qtd_lin_obs           SMALLINT,
          p_seq                   SMALLINT,
          p_array                 SMALLINT,
          m_cla                   SMALLINT

   DEFINE p_desc_prom             LIKE wfat_mestre.val_tot_nff,
          p_des_texto             CHAR(120),
          p_des_texto2            CHAR(120),
          p_val_tot_ipi_acum      LIKE wfat_mestre.val_tot_ipi,
          p_vol_item              DECIMAL(9,3),
          p_vol_nf                DECIMAL(9,3)

   DEFINE m_cod_fiscal_compl       INTEGER,
          m_ser_nff                CHAR(02),
          m_cod_fiscal             LIKE codigo_fiscal.cod_fiscal,
          m_cod_nat_oper           INTEGER

   DEFINE p_impr_novo_cnpj         CHAR(001)

   DEFINE m_ind  SMALLINT

   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)

   DEFINE g_ies_ambiente             CHAR(001)

END GLOBALS

   DEFINE p_ind, p_num_seq         SMALLINT

   DEFINE ma_n_trib               ARRAY[99] OF RECORD
                     pct_icm             LIKE wfat_item_fiscal.pct_icm,
                     val_base_icm        LIKE wfat_item_fiscal.val_base_icm,
                     pct_desc_base_icm   LIKE wfat_item_fiscal.pct_desc_base_icm,
                     val_icm             LIKE wfat_item_fiscal.val_icm
                                   END RECORD

   DEFINE m_cod_consig_ped LIKE pedidos.cod_consig,
          m_ascii          SMALLINT

MAIN

     CALL log0180_conecta_usuario()

LET p_versao = "VDP3794-05.10.03p" #Favor nao alterar esta linha (SUPORTE)
  WHENEVER ERROR CONTINUE
  CALL log1400_isolation()
  SET LOCK MODE TO WAIT 180
  WHENEVER ERROR STOP

  DEFER INTERRUPT
  CALL log140_procura_caminho("vdp.iem") RETURNING comando
  OPTIONS
    HELP    FILE comando

  CALL log001_acessa_usuario("VDP","LOGERP")
       RETURNING p_status, p_cod_empresa, p_user
  IF p_status = 0 THEN
     CALL vdp3794_controle()
  END IF

END MAIN

#---------------------------#
 FUNCTION vdp3794_controle()
#---------------------------#
  CALL log006_exibe_teclas("01", p_versao)

  CALL log130_procura_caminho("vdp3794") RETURNING comando
  OPEN WINDOW w_vdp3794 AT 2,02 WITH FORM comando
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

  MENU "OPCAO"
    COMMAND "Informar"   "Informar parametros "
      HELP 0009
      MESSAGE ""
      CALL vdp3794_inicializa_campos()
      IF log005_seguranca(p_user,"VDP","vdp3794","CO") THEN
         IF vdp3794_entrada_parametros() THEN
            NEXT OPTION "Listar"
         END IF
      END IF
    COMMAND "Listar"  "Lista as Notas Fiscais Fatura"
      HELP 1053
      IF log005_seguranca(p_user,"VDP","vdp3794","CO") THEN
         IF vdp3794_imprime_nff() THEN
            IF  vdp3794_verifica_param_exportacao() = TRUE
            THEN
#                CALL vdp785_controle()
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


  #lds COMMAND KEY ("F11") "Sobre" "Informações sobre a aplicação (F11)."
  #lds CALL LOG_info_sobre(sourceName(),p_versao)

  END MENU

  CLOSE WINDOW w_vdp3794
END FUNCTION

#-------------------------------------#
 FUNCTION vdp3794_entrada_parametros()
#-------------------------------------#
  CALL log006_exibe_teclas("01 02 07", p_versao)
  CURRENT WINDOW IS w_vdp3794

  INITIALIZE p_hora_saida, p_dat_saida TO NULL

  LET p_impr_novo_cnpj = 'S'

  INPUT p_ies_reimp,
        p_impr_novo_cnpj,
        p_num_nff_ini,
        p_num_nff_fim,
        p_dat_saida,
        p_hora_saida  WITHOUT DEFAULTS
   FROM ies_reimp,
        impr_novo_cnpj,
        num_nff_ini,
        num_nff_fim,
        dat_saida,
        hora_saida

      AFTER FIELD ies_reimp
         IF p_ies_reimp IS NULL THEN
            ERROR " Campo de Preechimento Obrigatorio."
            NEXT FIELD ies_reimp
         END IF

      AFTER FIELD num_nff_ini
         IF p_ies_reimp = "S" THEN
            IF vdp3794_verifica_nota(p_num_nff_ini) = FALSE THEN
               ERROR " Nota Fiscal nao existe na tabela wfat_mestre"
               NEXT FIELD num_nff_ini
            END IF
         END IF

      AFTER FIELD num_nff_fim
         IF p_ies_reimp = "S" THEN
            IF vdp3794_verifica_nota(p_num_nff_fim) = FALSE THEN
               ERROR " Nota Fiscal nao existe na tabela wfat_mestre"
               NEXT FIELD num_nff_fim
            END IF
         END IF

     AFTER FIELD dat_saida
          IF vdp3794_verifica_data(p_dat_saida) = FALSE THEN
              ERROR " Data de Emissão maior que Data de Saída "
              NEXT FIELD dat_saida
          END IF

    ON KEY (control-w)
       #lds IF NOT LOG_logix_versao5() THEN
       #lds CONTINUE INPUT
       #lds END IF
           CASE
             WHEN INFIELD(num_nff_ini)   CALL showhelp(3187)
             WHEN INFIELD(num_nff_fim)   CALL showhelp(3188)
             WHEN INFIELD(dat_saida)     CALL SHOWHELP(4931)
             WHEN INFIELD(hora_saida)    CALL SHOWHELP(5425)
           END CASE
  END INPUT

  CALL log006_exibe_teclas("01", p_versao)
  CURRENT WINDOW IS w_vdp3794

  IF int_flag THEN
     LET int_flag = 0
     CLEAR FORM
     RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
FUNCTION vdp3794_verifica_data(l_dat_saida)
#---------------------------------------#
   DEFINE l_dat_saida     LIKE wfat_mestre.dat_emissao


DECLARE cq_data CURSOR WITH HOLD FOR
   SELECT num_nff FROM wfat_mestre
           WHERE dat_emissao > l_dat_saida
             AND cod_empresa  = p_cod_empresa
             AND num_nff     >= p_num_nff_ini
             AND num_nff     <= p_num_nff_fim
   FOREACH cq_data
        IF sqlca.sqlcode = 0 THEN
           RETURN FALSE
        END IF
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------------------#
FUNCTION vdp3794_verifica_nota(p_num_nff)
#---------------------------------------#
   DEFINE p_num_nff     LIKE wfat_mestre.num_nff

   SELECT num_nff
     FROM wfat_mestre
    WHERE cod_empresa  = p_cod_empresa
      AND num_nff      = p_num_nff
      AND ies_impr_nff = "R"
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   END IF
   RETURN FALSE
END FUNCTION

#------------------------------------#
 FUNCTION vdp3794_inicializa_campos()
#------------------------------------#
  INITIALIZE p_nff.*,
             p_consignat.*,
             pa_corpo_nff,
             pa_texto,
             pa_texto_obs,
             p_end_entrega.*,
             p_cidades.*,
             p_empresa.*,
             p_embalagem.*,
             p_clientes.*,
             p_transport.*,
             p_ped_itens_texto.*,
             p_subst_trib_uf.* ,
             pa_cla_fisc      TO NULL

  LET p_num_nff_ini               = 0
  LET p_num_nff_fim               = 999999

  LET p_houve_end_ent             = FALSE
  LET p_houve_consig              = FALSE
  LET p_ies_termina_relat         = TRUE
  LET p_array                     = 1
  LET p_linhas                    = 0
  LET p_qtd_lin_obs               = 0
  LET p_seq                       = 0
  LET p_val_tot_ipi_acum          = 0
  LET p_desc_prom                 = 0
  LET p_vol_item                  = 0
  LET p_vol_nf                    = 0
  LET m_cla                       = 1
 # LET pa_cla_fisc[1].cod_cla_fisc = "39173229"
 # LET pa_cla_fisc[2].cod_cla_fisc = "39173290"
 # LET pa_cla_fisc[3].cod_cla_fisc = "39173300"
 # LET pa_cla_fisc[4].cod_cla_fisc = "39174000"
 # LET pa_cla_fisc[1].index        = "A"
 # LET pa_cla_fisc[2].index        = "B"
 # LET pa_cla_fisc[3].index        = "C"
 # LET pa_cla_fisc[4].index        = "D"
  LET p_max                       = "D"
  LET p_ies_reimp                 = "N"
  LET m_ascii              = 69
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp3794_verifica_param_exportacao()
#--------------------------------------------#
  DEFINE p_ies_export           CHAR(01),
         p_cod_mercado          LIKE cli_dist_geog.cod_mercado

  SELECT par_vdp_txt[151,151]
    INTO p_ies_export
    FROM par_vdp
   WHERE cod_empresa = p_cod_empresa

  IF  sqlca.sqlcode <> 0
  THEN RETURN FALSE
  END IF

  SELECT cod_mercado
    INTO p_cod_mercado
    FROM cli_dist_geog
   WHERE cod_cliente = p_wfat_mestre.cod_cliente

  IF  sqlca.sqlcode <> 0
  THEN RETURN FALSE
  END IF

  IF  p_ies_export  = "S"
  AND p_cod_mercado = "EX"
  THEN RETURN TRUE
  ELSE RETURN FALSE
  END IF

END FUNCTION

#------------------------------#
 FUNCTION vdp3794_imprime_nff()
#------------------------------#
  DEFINE p_sit_nff          CHAR(01),
#         p_cod_fisc         INTEGER,
         p_val_merc_frete   LIKE wfat_mestre.val_tot_mercadoria,
         l_num_om           LIKE nf_item.num_om ,
         p_ies_tran         SMALLINT

  IF  log028_saida_relat(16,40) IS NOT NULL THEN
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)

      IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "W" THEN
            CALL log150_procura_caminho("LST") RETURNING p_nom_arquivo_lst
            LET p_nom_arquivo_lst = p_nom_arquivo_lst CLIPPED,"vdp3794.tmp"
            START REPORT vdp3794_relat TO p_nom_arquivo_lst
         ELSE
            START REPORT vdp3794_relat TO PIPE p_nom_arquivo
         END IF
      ELSE
         START REPORT vdp3794_relat TO p_nom_arquivo
      END IF

  ELSE
      RETURN TRUE
  END IF

  LET p_comprime    = ascii(15)
  LET p_descomprime = ascii(18)
  LET p_6lpp        = ascii 27, "2"
  LET p_8lpp        = ascii 27, "0"

   IF p_ies_reimp = "S" THEN
      LET p_sit_nff = "R"
   ELSE
      LET p_sit_nff = "N"
   END IF

  DECLARE cq_wfat_mestre CURSOR WITH HOLD FOR
    SELECT * FROM wfat_mestre
     WHERE cod_empresa = p_cod_empresa
       AND num_nff    >= p_num_nff_ini
       AND num_nff    <= p_num_nff_fim
#       AND nom_usuario = p_user
       AND ies_impr_nff = p_sit_nff
     ORDER BY num_nff

  FOREACH cq_wfat_mestre INTO p_wfat_mestre.*

    DISPLAY p_wfat_mestre.num_nff TO num_nff_proces {mostra nf em processamento}

    CALL vdp3794_cria_tabela_temporaria()

 #   LET pa_cla_fisc[1].cod_cla_fisc = "39173229"           {A}
 #   LET pa_cla_fisc[2].cod_cla_fisc = "39173290"           {B}
 #   LET pa_cla_fisc[3].cod_cla_fisc = "39173300"           {C}
 #   LET pa_cla_fisc[4].cod_cla_fisc = "39174000"           {D}
###############################cod_fiscal################################
  INITIALIZE m_ser_nff,
             m_cod_fiscal_compl TO NULL

      SELECT ser_nff
        INTO m_ser_nff
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_wfat_mestre.num_nff

      SELECT cod_fiscal_compl
        INTO m_cod_fiscal_compl
        FROM nf_mestre_compl
       WHERE cod_empresa  = p_cod_empresa
         AND num_nff      = p_wfat_mestre.num_nff
         AND ser_nff      = m_ser_nff

    LET m_ind = 1
    INITIALIZE ma_array TO NULL

    DECLARE cq_item CURSOR FOR
    SELECT unique cod_fiscal, cod_nat_oper
      INTO m_cod_fiscal, m_cod_nat_oper
      FROM nf_item_fiscal
     WHERE cod_empresa = p_cod_empresa
       AND num_nff = p_wfat_mestre.num_nff
       #AND ser_nff = m_ser_nff
       #AND nom_usuario = p_user

    FOREACH cq_item
      LET ma_array[m_ind].den_cod_fiscal     = vdp3794_den_cod_fiscal()
      LET ma_array[m_ind].cod_fiscal         = m_cod_fiscal
      LET m_ind = m_ind + 1
    END FOREACH
    LET p_nff.den_cod_fiscal1      = ma_array[1].den_cod_fiscal
    LET p_nff.den_cod_fiscal2      = ma_array[2].den_cod_fiscal
    LET p_nff.cod_fiscal1          = ma_array[1].cod_fiscal
    LET p_nff.cod_fiscal2          = ma_array[2].cod_fiscal
###############################cod_fiscal################################
    LET p_nff.num_nff            = p_wfat_mestre.num_nff
    LET p_nff.cod_fiscal         = p_wfat_mestre.cod_fiscal
    LET p_nff.cod_cliente        = p_wfat_mestre.cod_cliente

    CALL vdp3794_busca_dados_subst_trib_uf()
    LET p_nff.ins_estadual_trib  = p_subst_trib_uf.ins_estadual
    LET p_nff.den_nat_oper       = vdp3794_den_nat_oper()
    LET p_nff.dat_emissao        = p_wfat_mestre.dat_emissao

    CALL vdp3794_busca_dados_clientes(p_wfat_mestre.cod_cliente)
    LET p_nff.nom_destinatario   = p_clientes.nom_cliente
    LET p_nff.num_cgc_cpf        = p_clientes.num_cgc_cpf
    LET p_nff.end_destinatario   = p_clientes.end_cliente
    LET p_nff.den_bairro         = p_clientes.den_bairro
    LET p_nff.cod_cep            = p_clientes.cod_cep
    LET p_nff.dat_saida          = p_dat_saida

    CALL vdp3794_busca_dados_cidades(p_clientes.cod_cidade)

    LET p_nff.den_cidade         = p_cidades.den_cidade
    LET p_nff.num_telefone       = p_clientes.num_telefone
    LET p_nff.cod_uni_feder      = p_cidades.cod_uni_feder
    LET p_nff.ins_estadual       = p_clientes.ins_estadual
    LET p_nff.hora_saida         = p_hora_saida
    LET p_nff.num_suframa        = p_clientes.num_suframa

    CALL vdp3794_busca_dados_duplicatas()

    LET p_ies_tran = FALSE

    DECLARE cq_ord_mont_tran CURSOR FOR
     SELECT UNIQUE(num_om) FROM wfat_item
      WHERE num_nff = p_wfat_mestre.num_nff
        AND cod_empresa = p_cod_empresa

    FOREACH cq_ord_mont_tran INTO l_num_om
     SELECT UNIQUE(num_om) FROM ordem_montag_tran
      WHERE num_om = l_num_om
        AND cod_empresa = p_cod_empresa

     IF sqlca.sqlcode = 0 THEN
        LET p_ies_tran = TRUE
     END IF
    END FOREACH

    IF p_ies_tran THEN
       LET  p_val_merc_frete = p_wfat_mestre.val_tot_mercadoria +
                               p_wfat_mestre.val_frete_cli
    ELSE
       LET  p_val_merc_frete = p_wfat_mestre.val_tot_nff
    END IF

    CALL log038_extenso(p_val_merc_frete, 68, 68, 68, 68)
        RETURNING p_nff.val_extenso1, p_nff.val_extenso2,
                  p_nff.val_extenso3, p_nff.val_extenso4

    CALL vdp3794_carrega_corpo_nff()  {le os itens pertencentes a nf}
    CALL vdp3794_carrega_tabela_temporaria() {sera o corpo todo da nota}


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

    IF  m_cod_consig_ped IS NOT NULL
    AND m_cod_consig_ped <> " " THEN
        LET p_wfat_mestre.cod_transpor = m_cod_consig_ped
    ELSE
       IF  p_clientes.cod_consig IS NOT NULL
       AND p_clientes.cod_consig <> " " THEN
           LET p_wfat_mestre.cod_transpor = p_clientes.cod_consig
       END IF
    END IF

    CALL vdp3794_busca_dados_transport(p_wfat_mestre.cod_transpor)
    CALL vdp3794_busca_dados_cidades(p_transport.cod_cidade)
    LET p_nff.nom_transpor       = p_transport.nom_cliente
    IF  p_wfat_mestre.ies_frete = 3
    THEN LET p_nff.ies_frete     = 2
    ELSE LET p_nff.ies_frete     = 1
    END IF
    LET p_nff.num_placa          = p_wfat_mestre.num_placa
    LET p_nff.num_cgc_trans      = p_transport.num_cgc_cpf
    LET p_nff.end_transpor       = p_transport.end_cliente
    LET p_nff.den_cidade_trans   = p_cidades.den_cidade
    LET p_nff.cod_uni_feder_trans= p_cidades.cod_uni_feder
    LET p_nff.ins_estadual_trans = p_transport.ins_estadual
    LET p_nff.qtd_volume         = p_wfat_mestre.qtd_volumes1 +
                                   p_wfat_mestre.qtd_volumes2 +
                                   p_wfat_mestre.qtd_volumes3 +
                                   p_wfat_mestre.qtd_volumes4 +
                                   p_wfat_mestre.qtd_volumes5
    LET p_nff.den_marca          = p_clientes.den_marca
    LET p_nff.num_pri_volume     = p_wfat_mestre.num_pri_volume
    LET p_nff.num_ult_volume     = p_wfat_mestre.num_pri_volume +
                                   p_nff.qtd_volume
#   IF  p_wfat_mestre.cod_fiscal <= 699
        LET p_nff.pes_tot_bruto      = p_wfat_mestre.pes_tot_bruto
        LET p_nff.pes_tot_liquido    = p_wfat_mestre.pes_tot_liquido
#   END IF
    LET p_nff.cubagem            = p_vol_nf

    LET p_nff.num_pedido         = p_wfat_item.num_pedido
    LET p_nff.cod_repres         = p_wfat_mestre.cod_repres

    CALL vdp3794_busca_nome_representante(p_nff.cod_repres)
    CALL vdp3794_prepara_linhas_texto()
    CALL vdp3794_busca_dados_historicos()  {le wfat_historico}
    CALL vdp3794_busca_dados_end_entrega()

    LET p_nff.des_especie        = vdp3794_especie()

    LET p_ies_lista = TRUE
    CALL vdp3794_grava_dados_consig(p_wfat_mestre.cod_consig)
    CALL vdp3794_carrega_end_cobranca()
    CALL vdp3794_imprime_comp_cobranca()
    CALL vdp3794_imprime_clas_fisc()
    CALL vdp3794_calcula_total_de_paginas()

########
##  OUTPUT TO REPORT vdp3794_relat()
########
    CALL vdp3794_monta_relat()
########

  #### marca nf que ja foi impressa ####
    UPDATE wfat_mestre SET wfat_mestre.ies_impr_nff = "R"
     WHERE wfat_mestre.cod_empresa = p_cod_empresa
       AND wfat_mestre.num_nff     = p_wfat_mestre.num_nff
      #AND wfat_mestre.nom_usuario = p_user

    CALL vdp3794_inicializa_campos()

  END FOREACH

  FINISH REPORT vdp3794_relat

  IF p_ies_impressao = "S" AND
      g_ies_ambiente  = "W" THEN
      LET comando = "lpdos.bat ", p_nom_arquivo_lst CLIPPED, " ", p_nom_arquivo
      RUN comando
  END IF

  IF p_ies_lista THEN
     IF  p_ies_impressao = "S"
     THEN MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                                                     ATTRIBUTE(REVERSE)
     ELSE MESSAGE "Relatorio gravado no arquivo ", p_nom_arquivo
                                                     ATTRIBUTE(REVERSE)
     END IF
     ERROR " Fim de processamento ..."
  ELSE
     MESSAGE ""
     ERROR " Nao existem dados para serem listados. "
  END IF

  RETURN TRUE
END FUNCTION

#------------------------------------------#
 FUNCTION vdp3794_cria_tabela_temporaria()
#------------------------------------------#

  WHENEVER ERROR CONTINUE
    CALL log085_transacao("BEGIN")

    LOCK TABLE wnotakana IN EXCLUSIVE MODE

    CALL log085_transacao("COMMIT")

    DROP TABLE wnotakana;

    IF  sqlca.sqlcode <> 0
    THEN DELETE FROM wnotakana;
    END IF

    CREATE TEMP TABLE wnotakana
     (
      num_seq            smallint,
      ies_tip_info       smallint,
      cod_item           char(16),
      pes_unit           DECIMAL(9,4),
      den_item           char(37),
      cod_fiscal         INTEGER,
      cod_cla_fisc       char(1),
      cod_origem         DECIMAL(2,0),
      cod_tributacao     decimal(2,0),
      cod_unid_med       char(3),
      qtd_item           decimal(12,3),
      pre_unit           decimal(17,6),
      desconto           char(010),
      val_liq_item       decimal(15,2),
      pct_icm            decimal(5,2),
      pct_ipi            decimal(6,3),
      val_ipi            decimal(15,2),
      des_texto          char(120),
      num_pedido         decimal(6,0),
      num_seq_nfitem     decimal(5,0),
      ies_bonificacao    char(01),
      num_nff            decimal(6,0)
     ) WITH NO LOG;
      IF  sqlca.sqlcode <> 0
      THEN CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
      END IF
  WHENEVER ERROR STOP

END FUNCTION

#-------------------------------#
 FUNCTION vdp3794_monta_relat()
#-------------------------------#

  DECLARE cq_wnotakana CURSOR FOR
   SELECT * FROM wnotakana
    ORDER BY 1

  FOREACH cq_wnotakana INTO p_wnotakana.*

    LET p_wnotakana.num_nff = p_wfat_mestre.num_nff
########
    OUTPUT TO REPORT vdp3794_relat(p_wnotakana.*)
########

  END FOREACH

  IF  p_ies_termina_relat = TRUE THEN
      LET p_wnotakana.num_nff         = p_wfat_mestre.num_nff
      LET p_wnotakana.num_seq         = p_wnotakana.num_seq + 1
      LET p_wnotakana.ies_tip_info    = 4

      OUTPUT TO REPORT vdp3794_relat(p_wnotakana.*)
  END IF

END FUNCTION

#-------------------------------#
FUNCTION vdp3794_den_cod_fiscal()
#-------------------------------#
   DEFINE l_den_cod_fiscal LIKE codigo_fiscal.den_cod_fiscal

   LET l_den_cod_fiscal  = " "

   SELECT den_cod_fiscal
     INTO l_den_cod_fiscal
     FROM codigo_fiscal
    WHERE cod_fiscal  = m_cod_fiscal #p_wfat_mestre.cod_fiscal
   RETURN l_den_cod_fiscal
END FUNCTION

#---------------------------------------#
 FUNCTION vdp3794_carrega_end_cobranca()
#---------------------------------------#

 INITIALIZE p_cli_end_cobr.* TO NULL

   SELECT cli_end_cob.*
     INTO p_cli_end_cobr.*
     FROM cli_end_cob
    WHERE cod_cliente = p_wfat_mestre.cod_cliente

      LET p_nff.end_cob_cli     = p_cli_end_cobr.end_cobr
      LET p_nff.den_bairro_cob  = p_cli_end_cobr.den_bairro
      LET p_nff.cod_cep_cob     = p_cli_end_cobr.cod_cep

   SELECT den_cidade,
          cod_uni_feder
     INTO p_nff.den_cidade_cob,
          p_nff.cod_uni_feder_cobr
     FROM cidades
    WHERE cidades.cod_cidade = p_cli_end_cobr.cod_cidade_cob

END FUNCTION

#-----------------------------------------------------------#
 FUNCTION vdp3794_busca_nome_representante(l_cod_repres)
#-----------------------------------------------------------#
  DEFINE l_cod_repres        LIKE wfat_mestre.cod_repres

  SELECT nom_repres
    INTO p_nff.nom_repres
    FROM representante
   WHERE cod_repres  = l_cod_repres

END FUNCTION

#------------------------------------------#
 FUNCTION vdp3794_busca_dados_duplicatas()
#------------------------------------------#
  DEFINE p_wfat_duplic       RECORD LIKE wfat_duplic.*,
         p_contador          SMALLINT

  LET p_contador = 0

  DECLARE cq_duplic CURSOR FOR
   SELECT * FROM wfat_duplic
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_wfat_mestre.num_nff
    ORDER BY cod_empresa,
             num_duplicata,
             dig_duplicata

  FOREACH cq_duplic INTO p_wfat_duplic.*

     LET p_contador = p_contador + 1
     CASE p_contador
        WHEN 1      LET p_nff.num_duplic1 = p_wfat_duplic.num_duplicata
                    LET p_nff.dig_duplic1 = p_wfat_duplic.dig_duplicata
                    LET p_nff.val_duplic1 = p_wfat_duplic.val_duplic
                    LET p_nff.dat_vencto1 = p_wfat_duplic.dat_vencto_sd
        WHEN 2      LET p_nff.num_duplic2 = p_wfat_duplic.num_duplicata
                    LET p_nff.dig_duplic2 = p_wfat_duplic.dig_duplicata
                    LET p_nff.val_duplic2 = p_wfat_duplic.val_duplic
                    LET p_nff.dat_vencto2 = p_wfat_duplic.dat_vencto_sd
        WHEN 3      LET p_nff.num_duplic3 = p_wfat_duplic.num_duplicata
                    LET p_nff.dig_duplic3 = p_wfat_duplic.dig_duplicata
                    LET p_nff.val_duplic3 = p_wfat_duplic.val_duplic
                    LET p_nff.dat_vencto3 = p_wfat_duplic.dat_vencto_sd
        WHEN 4      LET p_nff.num_duplic4 = p_wfat_duplic.num_duplicata
                    LET p_nff.dig_duplic4 = p_wfat_duplic.dig_duplicata
                    LET p_nff.val_duplic4 = p_wfat_duplic.val_duplic
                    LET p_nff.dat_vencto4 = p_wfat_duplic.dat_vencto_sd
        WHEN 5      LET p_nff.num_duplic5 = p_wfat_duplic.num_duplicata
                    LET p_nff.dig_duplic5 = p_wfat_duplic.dig_duplicata
                    LET p_nff.val_duplic5 = p_wfat_duplic.val_duplic
                    LET p_nff.dat_vencto5 = p_wfat_duplic.dat_vencto_sd
        OTHERWISE   EXIT FOREACH
     END CASE
  END FOREACH
END FUNCTION

#------------------------------------#
 FUNCTION vdp3794_carrega_corpo_nff()
#------------------------------------#
 DEFINE p_qtd_item_t     LIKE wfat_item.qtd_item,
        p_ies_bonif      CHAR(01),
        l_sql_stmt       CHAR(500),
        l_vez            SMALLINT,
        l_cont           SMALLINT
 DEFINE p_qtd_padr_embal LIKE item_embalagem.qtd_padr_embal,
        p_vol_padr_embal LIKE item_embalagem.vol_padr_embal

 INITIALIZE ma_n_trib TO NULL
 LET p_ind  = 1
 LET l_vez  = 0
 LET l_cont = 0

 WHILE l_vez < 2
   LET l_vez = l_vez + 1
   INITIALIZE l_sql_stmt TO NULL

   IF l_vez = 1 THEN
      LET p_ies_bonif = "N"

      LET l_sql_stmt  =
        ' SELECT wfat_item.*, TRUNC(qtd_item,1), wfat_item_fiscal.* ',
          ' FROM wfat_item, wfat_item_fiscal ',
         ' WHERE wfat_item.cod_empresa          = "', p_cod_empresa, '" ',
           ' AND wfat_item.num_nff              =  ', p_wfat_mestre.num_nff,
           ' AND wfat_item_fiscal.cod_empresa   = wfat_item.cod_empresa ',
           ' AND wfat_item_fiscal.num_nff       = wfat_item.num_nff ',
           ' AND wfat_item_fiscal.num_pedido    = wfat_item.num_pedido ',
           ' AND wfat_item_fiscal.num_sequencia = wfat_item.num_sequencia ',
         ' ORDER BY wfat_item.num_sequencia '

   ELSE
      LET p_ies_bonif = "S"

      LET l_sql_stmt  =
        ' SELECT wfat_item_bnf.*, TRUNC(qtd_item,1), wfat_item_bnf_fisc.* ',
          ' FROM wfat_item_bnf, wfat_item_bnf_fisc ',
         ' WHERE wfat_item_bnf.cod_empresa        = "', p_cod_empresa, '" ',
           ' AND wfat_item_bnf.num_nff            =  ', p_wfat_mestre.num_nff,
           ' AND wfat_item_bnf_fisc.cod_empresa   = wfat_item_bnf.cod_empresa ',
           ' AND wfat_item_bnf_fisc.num_nff       = wfat_item_bnf.num_nff ',
           ' AND wfat_item_bnf_fisc.num_pedido    = wfat_item_bnf.num_pedido ',
           ' AND wfat_item_bnf_fisc.num_sequencia = wfat_item_bnf.num_sequencia ',
         ' ORDER BY wfat_item_bnf.num_sequencia '

   END IF

   PREPARE var_query_sql FROM l_sql_stmt
   DECLARE cq_wfat_item CURSOR FOR var_query_sql

   FOREACH cq_wfat_item INTO p_wfat_item.*, p_qtd_item_t, p_wfat_item_fiscal.*

     LET pa_corpo_nff[p_ind].cod_item       = p_wfat_item.cod_item
     LET pa_corpo_nff[p_ind].num_sequencia  = p_wfat_item.num_sequencia
     LET pa_corpo_nff[p_ind].num_pedido     = p_wfat_item.num_pedido

     IF ((p_wfat_item.den_item[33,68] IS NULL) OR (p_wfat_item.den_item[33,68] = " ")) THEN
        LET pa_corpo_nff[p_ind].den_item1      = p_wfat_item.den_item[01,32] CLIPPED," ", p_wfat_item_fiscal.cod_fiscal USING "####"
        #LET pa_corpo_nff[p_ind].den_item2      = p_wfat_item.den_item[33,68]
     ELSE
        LET pa_corpo_nff[p_ind].den_item1      = p_wfat_item.den_item[01,36]
        LET pa_corpo_nff[p_ind].den_item2      = p_wfat_item.den_item[37,68] CLIPPED," ", p_wfat_item_fiscal.cod_fiscal USING "####"
     END IF
     CALL vdp3794_busca_dados_pedido()
     LET pa_corpo_nff[p_ind].pes_unit       = p_wfat_item.pes_unit * p_wfat_item.qtd_item
     LET pa_corpo_nff[p_ind].cod_fiscal     = p_wfat_item_fiscal.cod_fiscal
     LET pa_corpo_nff[p_ind].cod_cla_fisc   = vdp3794_carrega_clas_fiscal()
     LET pa_corpo_nff[p_ind].cod_origem     = p_wfat_item_fiscal.cod_origem
     LET pa_corpo_nff[p_ind].cod_tributacao = p_wfat_item_fiscal.cod_tributacao
     LET pa_corpo_nff[p_ind].cod_unid_med   = p_wfat_item.cod_unid_med
     LET pa_corpo_nff[p_ind].qtd_item       = p_wfat_item.qtd_item
     LET pa_corpo_nff[p_ind].qtd_item_t     = p_qtd_item_t
     LET pa_corpo_nff[p_ind].num_seq_nfitem = p_wfat_item.num_sequencia
     LET pa_corpo_nff[p_ind].pre_unit       = p_wfat_item.pre_unit_nf
     LET pa_corpo_nff[p_ind].desconto       =
              p_wfat_item.pct_desc_adic_mest USING "#&.&" CLIPPED,
              "+", p_wfat_item.pct_desc_adic USING "#&.&"

     IF  p_wfat_item.val_ipi > 0
     AND (p_wfat_item.pct_desc_adic_mest > 0 OR p_wfat_item.pct_desc_adic > 0 )
     THEN LET pa_corpo_nff[p_ind].desconto = " 0.0+ 0.0"
          LET pa_corpo_nff[p_ind].pre_unit = p_wfat_item.pre_unit_nf
     END IF

     LET pa_corpo_nff[p_ind].val_liq_item = p_wfat_item.val_liq_item
     LET pa_corpo_nff[p_ind].pct_icm      = p_wfat_item_fiscal.pct_icm

     IF p_wfat_mestre.val_tot_icm = 0
     OR p_wfat_mestre.val_tot_base_icm = 0 THEN
        LET pa_corpo_nff[p_ind].pct_icm = 0
     END IF

     LET pa_corpo_nff[p_ind].pct_ipi         = p_wfat_item.pct_ipi
     LET pa_corpo_nff[p_ind].val_ipi         = p_wfat_item.val_ipi
     LET pa_corpo_nff[p_ind].val_icm_ret     = p_wfat_item.val_icm_ret
     LET pa_corpo_nff[p_ind].ies_bonificacao = p_ies_bonif

     IF p_ies_bonif = "S" THEN
        LET p_desc_prom = p_desc_prom + p_wfat_item.val_liq_item
                        + p_wfat_item.val_ipi
     END IF

   { ** calcula/acumula a cubagem ** }
     SELECT qtd_padr_embal, vol_padr_embal
       INTO p_qtd_padr_embal, p_vol_padr_embal
       FROM item_embalagem, item_vdp
      WHERE item_embalagem.cod_empresa = p_cod_empresa
        AND item_embalagem.cod_item    = p_wfat_item.cod_item
        AND item_vdp.cod_empresa       = p_cod_empresa
        AND item_vdp.cod_item          = p_wfat_item.cod_item
        AND item_embalagem.ies_tip_embal IN ("N","I")

     IF sqlca.sqlcode = 0
     THEN LET p_vol_item = (p_wfat_item.qtd_item * p_vol_padr_embal ) /
                                                   p_qtd_padr_embal
          LET p_vol_nf   = p_vol_nf + p_vol_item
     END IF
   { ** fim                       ** }
     SELECT qtd_padr_embal, vol_padr_embal
       INTO p_qtd_padr_embal, p_vol_padr_embal
       FROM item_embalagem, item_vdp
      WHERE item_embalagem.cod_empresa = p_cod_empresa
        AND item_embalagem.cod_item    = p_wfat_item.cod_item
        AND item_vdp.cod_empresa       = p_cod_empresa
        AND item_vdp.cod_item          = p_wfat_item.cod_item
        AND item_embalagem.ies_tip_embal IN ("C","E")

     IF sqlca.sqlcode = 0
     THEN LET p_vol_item = (p_wfat_item.qtd_item * p_vol_padr_embal ) /
                                                   p_qtd_padr_embal
          LET p_vol_nf   = p_vol_nf + p_vol_item
     END IF

     LET p_val_tot_ipi_acum = p_val_tot_ipi_acum + p_wfat_item.val_ipi
     CALL vdp3794_n_tributacao()

     LET l_cont = 0

     IF p_ind = 999 THEN
        EXIT FOREACH
     END IF
     LET p_ind = p_ind + 1
   END FOREACH

   FREE cq_wfat_item

 END WHILE
END FUNCTION

#--------------------------------------#
 FUNCTION vdp3794_carrega_clas_fiscal()
#--------------------------------------#
   DEFINE l_cont          SMALLINT,
          l_ind           SMALLINT,
          l_index         CHAR(01),
          l_cod_cla_fisc  LIKE wfat_item.cod_cla_fisc,
          l_cod_cla_fisc_aux  LIKE wfat_item.cod_cla_fisc


   WHENEVER ERROR CONTINUE
     SELECT cod_cla_fisc
       INTO l_cod_cla_fisc
       FROM item
      WHERE cod_empresa = p_cod_empresa
        AND cod_item    = pa_corpo_nff[p_ind].cod_item
   WHENEVER ERROR STOP

   FOR l_cont = 1 TO 12
      IF pa_cla_fisc[l_cont].cod_cla_fisc = l_cod_cla_fisc THEN
         RETURN pa_cla_fisc[l_cont].cla_fisc_nff
      END IF
   END FOR
   FOR m_cla = 1 TO 99
      IF pa_cla_fisc[m_cla].cla_fisc_nff IS NULL THEN
         IF l_cod_cla_fisc = "39173210" OR
            l_cod_cla_fisc = "39173290" OR
            l_cod_cla_fisc = "39173100" OR
            l_cod_cla_fisc = "39174000" OR
            l_cod_cla_fisc = "3917.32.10" OR
            l_cod_cla_fisc = "3917.32.90" OR
            l_cod_cla_fisc = "3917.31.00" OR
            l_cod_cla_fisc = "3917.40.00" OR
            l_cod_cla_fisc = "0039173210" OR
            l_cod_cla_fisc = "0039173290" OR
            l_cod_cla_fisc = "0039173100" OR
            l_cod_cla_fisc = "0039174000" THEN

            IF l_cod_cla_fisc = "39173210"    OR
               l_cod_cla_fisc = "0039173210"  OR
               l_cod_cla_fisc = "3917.32.10" THEN
               LET l_index = "A"
            END IF
            IF l_cod_cla_fisc = "39173290"    OR
               l_cod_cla_fisc = "0039173290"  OR
               l_cod_cla_fisc = "3917.32.90" THEN
               LET l_index = "B"
            END IF
            IF l_cod_cla_fisc = "39173100"    OR
               l_cod_cla_fisc = "0039173100"  OR
               l_cod_cla_fisc = "3917.31.00" THEN
               LET l_index = "C"
            END IF
            IF l_cod_cla_fisc = "39174000"    OR
               l_cod_cla_fisc = "0039174000"  OR
               l_cod_cla_fisc = "3917.40.00" THEN
               LET l_index = "D"
            END IF

            LET pa_cla_fisc[m_cla].cod_cla_fisc = l_cod_cla_fisc
            LET pa_cla_fisc[m_cla].cla_fisc_nff = l_index

         ELSE
            ###  m_ascii é inicializada em 65, e declarado como modular
            LET l_cod_cla_fisc_aux = ascii m_ascii
            LET m_ascii = m_ascii + 1
            LET l_index = l_cod_cla_fisc_aux
         END IF

         LET pa_cla_fisc[m_cla].cod_cla_fisc = l_cod_cla_fisc
         LET pa_cla_fisc[m_cla].cla_fisc_nff = l_index
         EXIT FOR
      END IF

   END FOR

   RETURN l_index

END FUNCTION

#-------------------------------#
 FUNCTION vdp3794_n_tributacao()
#-------------------------------#
   DEFINE x SMALLINT

   FOR x = 1 TO 99
      IF ma_n_trib[x].pct_icm IS NULL THEN
         LET ma_n_trib[x].pct_icm      = pa_corpo_nff[p_ind].pct_icm
         LET ma_n_trib[x].val_base_icm = p_wfat_item_fiscal.val_base_icm
         LET ma_n_trib[x].val_icm      = p_wfat_item_fiscal.val_icm
         LET ma_n_trib[x].pct_desc_base_icm = p_wfat_item_fiscal.pct_desc_base_icm
         EXIT FOR
      END IF

      IF  ma_n_trib[x].pct_desc_base_icm = p_wfat_item_fiscal.pct_desc_base_icm
      AND ma_n_trib[x].pct_icm           = pa_corpo_nff[p_ind].pct_icm THEN
         LET ma_n_trib[x].val_base_icm =
             ma_n_trib[x].val_base_icm + p_wfat_item_fiscal.val_base_icm

         LET ma_n_trib[x].val_icm =
             ma_n_trib[x].val_icm + p_wfat_item_fiscal.val_icm

         EXIT FOR
      END IF
   END FOR
END FUNCTION

#---------------------------------------------#
 FUNCTION vdp3794_carrega_tabela_temporaria()
#---------------------------------------------#
  DEFINE i, j                      SMALLINT
  DEFINE p_val_desconto            LIKE nf_item_bettanin.val_desconto

  LET p_val_desconto = 0
  LET i = 1
  LET j = 0
  LET p_num_seq = 0
  LET p_ult_linha = 1

  FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}

     IF pa_corpo_nff[i].cod_item     IS NULL AND
        pa_corpo_nff[i].cod_cla_fisc IS NULL AND
        pa_corpo_nff[i].pct_ipi      IS NULL AND
        pa_corpo_nff[i].qtd_item     IS NULL AND
        pa_corpo_nff[i].pre_unit     IS NULL THEN
        CONTINUE FOR
     END IF

     LET p_ult_linha = i

     LET p_num_seq = p_num_seq + 1
     INSERT INTO wnotakana VALUES ( p_num_seq,1,
                                     pa_corpo_nff[i].cod_item,
                                     pa_corpo_nff[i].pes_unit,
                                     pa_corpo_nff[i].den_item1,
                                     pa_corpo_nff[i].cod_fiscal,
                                     pa_corpo_nff[i].cod_cla_fisc,
                                     pa_corpo_nff[i].cod_origem,
                                     pa_corpo_nff[i].cod_tributacao,
                                     pa_corpo_nff[i].cod_unid_med,
                                     pa_corpo_nff[i].qtd_item,
                                     pa_corpo_nff[i].pre_unit,
                                     pa_corpo_nff[i].desconto,
                                     pa_corpo_nff[i].val_liq_item,
                                     pa_corpo_nff[i].pct_icm,
                                     pa_corpo_nff[i].pct_ipi,
                                     pa_corpo_nff[i].val_ipi,"",
                                     pa_corpo_nff[i].num_pedido,
                                     pa_corpo_nff[i].num_seq_nfitem,
                                     pa_corpo_nff[i].ies_bonificacao,
                                     "")

     { insere segunda parte da denominacao do item, se esta existir }

     IF pa_corpo_nff[i].den_item2 IS NOT NULL AND
        pa_corpo_nff[i].den_item2 <> " " THEN
        LET p_num_seq = p_num_seq + 1
        INSERT INTO wnotakana VALUES (p_num_seq,2,"","",pa_corpo_nff[i].den_item2,
                                      "","","","","","","","","","","","","",null,null,"","")
     END IF
     #IF pa_corpo_nff[i].val_icm_ret > 0 THEN
     #   LET p_des_texto = "ICMS RET. SUBST. TRI",
     #                     "B. ",
     #                     pa_corpo_nff[i].val_icm_ret USING "##########&.&&"
     #   LET p_num_seq = p_num_seq + 1
     #   INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
     #                                   "","","","","",p_des_texto,null,null,"","")
     #END IF

     { imprime texto do item, se este existir }

     IF vdp3794_verifica_texto_ped_it(pa_corpo_nff[i].num_pedido,pa_corpo_nff[i].num_sequencia) THEN
        FOR j = 1 TO 05
           IF  pa_texto_ped_it[j].texto IS NOT NULL AND
               pa_texto_ped_it[j].texto <> " " THEN
               LET p_num_seq = p_num_seq + 1
               INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","",
                                               "","","","","","","",
                                               pa_texto_ped_it[j].texto,null,null,"","")
           END IF
        END FOR
     END IF

  END FOR

   # Verif. se existe desconto de propaganda para a N.F.

   SELECT SUM(val_desconto)
     INTO p_val_desconto
     FROM nf_item_bettanin
    WHERE cod_empresa = p_cod_empresa
      AND num_nff     = p_wfat_mestre.num_nff
   IF p_val_desconto IS NOT NULL AND
      p_val_desconto > 0         THEN
      LET p_des_texto = "Desconto condicionado para propaganda cooperada => ",
                         p_val_desconto                USING "##,###,##&.&&"
      LET p_num_seq = p_num_seq + 1
      INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                      "","","","","", p_des_texto,null,null,"","")
   END IF

  IF p_clientes.ies_zona_franca  = "S" AND
     p_nff.num_suframa           > 0   AND
     p_wfat_mestre.val_desc_merc > 0  THEN
     LET p_des_texto = "DESCONTO DE ",
                        p_wfat_mestre.pct_icm      USING "#&.&", "%",
                       "PERC. ",
                       p_wfat_mestre.val_desc_merc USING "#######,###,##&.&&"
     LET p_num_seq = p_num_seq + 1
     INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                     "","","","","", p_des_texto,null,null,"","")
  END IF

  IF p_desc_prom > 0 THEN
     LET p_des_texto = "DESCONTO PROMOCI",
                       "ONAL SOMENTE NESTE PEDIDO ",
                       p_desc_prom USING "##########&.&&"
     LET p_num_seq = p_num_seq + 1
     INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                     "","","","","", p_des_texto,null,null,"","")
  END IF

  #IF p_wfat_mestre.val_tot_base_ret > 0 THEN
  #   LET p_des_texto = "BASE CALC. SUBSTIT. TRIB. ",
  #                     p_wfat_mestre.val_tot_base_ret USING "###########&.&&",
  #                     " ICMS RETIDO: ",
  #                     p_wfat_mestre.val_tot_icm_ret  USING "###########&.&&"
  #   LET p_num_seq = p_num_seq + 1
  #   INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
  #                                   "","","","","", p_des_texto,null,null,"","")
  #END IF      
  
  IF (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum) > 0 THEN
     LET p_des_texto = "IPI S/ FRETE ....> ",
                       (p_wfat_mestre.val_tot_ipi - p_val_tot_ipi_acum)
                                                      USING "#######&.&&"
     LET p_num_seq = p_num_seq + 1
     INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                     "","","","","", p_des_texto,null,null,"","")
  END IF

END FUNCTION

#-----------------------------#
 FUNCTION vdp3794_msg_n_trib()
#-----------------------------#
   DEFINE x SMALLINT

   IF ma_n_trib[2].pct_icm IS NULL THEN
      RETURN
   END IF

   INITIALIZE p_des_texto TO NULL
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotakana VALUES
      ( p_num_seq, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
        NULL, NULL, NULL, NULL, NULL, p_des_texto, NULL, NULL, NULL, NULL)

   LET p_des_texto = " ICMS    BASE CALC.    BASE RED.ICM        VAL.ICM"
   LET p_num_seq = p_num_seq + 1

   INSERT INTO wnotakana VALUES
      ( p_num_seq, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,
        NULL, NULL, NULL, NULL, NULL, p_des_texto, NULL, NULL, NULL, NULL)

   FOR x = 1 TO 99
      IF ma_n_trib[x].pct_icm IS NULL THEN
         EXIT FOR
      END IF

      LET p_des_texto =
          ma_n_trib[x].pct_icm            USING "#&.&&",        "   ",
          ma_n_trib[x].val_base_icm       USING "####,##&.&&",  "        ",
          ma_n_trib[x].pct_desc_base_icm  USING "##&.&&&&",     "   ",
          ma_n_trib[x].val_icm            USING "#,###,##&.&&"

      LET p_num_seq = p_num_seq + 1

      INSERT INTO wnotakana VALUES
         ( p_num_seq, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,NULL,NULL,
           NULL, NULL, NULL, NULL, NULL, p_des_texto, NULL, NULL, NULL, NULL)
   END FOR
END FUNCTION

#--------------------------------------------#
 FUNCTION vdp3794_calcula_total_de_paginas()
#--------------------------------------------#

  SELECT COUNT(*)
    INTO p_num_linhas
    FROM wnotakana

  { 24 = numero de linhas do corpo da nota fiscal }

  IF p_num_linhas IS NOT NULL AND p_num_linhas > 0 THEN
     LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 24)) / 24
     IF (p_num_linhas MOD 24) > 0 THEN
        LET p_tot_paginas = p_tot_paginas + 1
     ELSE
        LET p_ies_termina_relat = FALSE
     END IF
  ELSE
     LET p_tot_paginas = 1
  END IF

END FUNCTION

#-------------------------------------#
 FUNCTION vdp3794_busca_dados_pedido()
#-------------------------------------#
   INITIALIZE m_cod_consig_ped TO NULL
   SELECT num_pedido_repres,
          num_pedido_cli,
          cod_consig
     INTO p_nff.num_pedido_repres,
          p_nff.num_pedido_cli,
          m_cod_consig_ped
     FROM pedidos
    WHERE cod_empresa  = p_wfat_mestre.cod_empresa
      AND num_pedido   = p_wfat_item.num_pedido

END FUNCTION
#--------------------------------------------#
 FUNCTION vdp3794_busca_dados_subst_trib_uf()
#--------------------------------------------#
 INITIALIZE p_subst_trib_uf.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT subst_trib_uf.*
    INTO p_subst_trib_uf.*
    FROM clientes, cidades, subst_trib_uf
   WHERE clientes.cod_cliente        = p_wfat_mestre.cod_cliente
     AND cidades.cod_cidade          = clientes.cod_cidade
     AND subst_trib_uf.cod_uni_feder = cidades.cod_uni_feder
     AND subst_trib_uf.cod_empresa   = p_cod_empresa
 WHENEVER ERROR STOP

END FUNCTION

#-------------------------------#
 FUNCTION vdp3794_den_nat_oper()
#-------------------------------#
  DEFINE p_nat_operacao      RECORD LIKE nat_operacao.*

  WHENEVER ERROR CONTINUE
   SELECT nat_operacao.*
     INTO p_nat_operacao.*
     FROM nat_operacao
    WHERE nat_operacao.cod_nat_oper = p_wfat_mestre.cod_nat_oper
  WHENEVER ERROR STOP

  IF  sqlca.sqlcode = 0
  THEN IF p_nat_operacao.ies_subst_tribut <> "S"
       THEN LET p_nff.ins_estadual_trib = NULL
       END IF
       RETURN p_nat_operacao.den_nat_oper
  ELSE RETURN "NATUREZA NAO CADASTRADA"
  END IF

END FUNCTION

#---------------------------#
 FUNCTION vdp3794_especie()
#---------------------------#
 DEFINE p_des_especie    CHAR(100)

 WHENEVER ERROR CONTINUE
  SELECT embalagem.*
    INTO p_embalagem.*
    FROM embalagem
   WHERE embalagem.cod_embal = p_wfat_mestre.cod_embal_1
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 THEN LET p_des_especie = p_embalagem.den_embal[1,8]
 END IF

 WHENEVER ERROR CONTINUE
  SELECT embalagem.*
    INTO p_embalagem.*
    FROM embalagem
   WHERE embalagem.cod_embal = p_wfat_mestre.cod_embal_2
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 THEN LET p_des_especie = p_des_especie CLIPPED, "/",
                          p_embalagem.den_embal[1,8]
 END IF

 WHENEVER ERROR CONTINUE
  SELECT embalagem.*
    INTO p_embalagem.*
    FROM embalagem
   WHERE embalagem.cod_embal = p_wfat_mestre.cod_embal_3
 WHENEVER ERROR STOP

 IF sqlca.sqlcode = 0
 THEN LET p_des_especie = p_des_especie CLIPPED, "/",
                          p_embalagem.den_embal[1,8]
 END IF

 RETURN p_des_especie

END FUNCTION

#----------------------------------------------------#
 FUNCTION vdp3794_busca_dados_clientes(p_cod_cliente)
#----------------------------------------------------#
 DEFINE p_cod_cliente    LIKE clientes.cod_cliente

 INITIALIZE p_clientes.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT clientes.*
    INTO p_clientes.*
    FROM clientes
   WHERE clientes.cod_cliente = p_wfat_mestre.cod_cliente
 WHENEVER ERROR STOP

END FUNCTION

#------------------------------------------------------#
 FUNCTION vdp3794_busca_dados_transport(p_cod_transpor)
#------------------------------------------------------#
 DEFINE p_cod_transpor  LIKE clientes.cod_cliente

 INITIALIZE p_transport.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT clientes.*
    INTO p_transport.*
    FROM clientes
   WHERE clientes.cod_cliente = p_cod_transpor
 WHENEVER ERROR STOP

END FUNCTION

#--------------------------------------------------#
 FUNCTION vdp3794_busca_dados_cidades(p_cod_cidade)
#--------------------------------------------------#
 DEFINE p_cod_cidade     LIKE cidades.cod_cidade

 INITIALIZE p_cidades.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT cidades.*
    INTO p_cidades.*
    FROM cidades
   WHERE cidades.cod_cidade = p_cod_cidade
 WHENEVER ERROR STOP

END FUNCTION

#--------------------------------------------------#
 FUNCTION vdp3794_grava_dados_consig(p_cod_consig)
#--------------------------------------------------#
 DEFINE p_cod_consig  LIKE clientes.cod_cliente

 INITIALIZE p_consignat.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT clientes.nom_cliente,
         clientes.end_cliente,
         clientes.num_cgc_cpf,
         clientes.ins_estadual,
         cidades.den_cidade,
         cidades.cod_uni_feder
    INTO p_consignat.*
    FROM clientes, cidades
   WHERE clientes.cod_cliente = p_cod_consig
     AND clientes.cod_cidade  = cidades.cod_cidade
 WHENEVER ERROR STOP

 IF  sqlca.sqlcode = 0
 THEN LET p_houve_consig = TRUE
 END IF

END FUNCTION

#----------------------------------------#
 FUNCTION vdp3794_imprime_comp_cobranca()
#----------------------------------------#

 DEFINE l_legenda        CHAR(50),
        l_texto          CHAR(50),
        l_texto2         CHAR(50)

 INITIALIZE p_des_texto2 TO NULL

 LET p_num_seq = p_num_seq + 1
 IF (p_nff.den_cidade_cob IS NOT NULL AND
     p_nff.den_cidade_cob <> " ") THEN
     LET l_legenda = "       COMPLEMENTO COBRANCA"
     LET p_qtd_lin_obs = p_qtd_lin_obs + 1
     IF p_qtd_lin_obs < 9 THEN
        LET pa_texto_obs[p_qtd_lin_obs].texto = l_legenda
     ELSE
        INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                       "","","","","",l_legenda,"","","","")
     END IF
 END IF

 IF p_nff.den_cidade_cob IS NOT NULL AND
    p_nff.den_cidade_cob <> " " THEN
      LET p_num_seq = p_num_seq + 1
      LET l_texto = "Cidade: ", p_nff.den_cidade_cob CLIPPED,
                    " - ",      p_nff.cod_uni_feder_cobr
 END IF

 IF p_nff.den_bairro_cob IS NOT NULL AND
    p_nff.den_bairro_cob <> " " THEN
      LET l_texto2 = "Bairro: ", p_nff.den_bairro_cob CLIPPED
      IF p_nff.cod_cep IS NOT NULL AND
         p_nff.cod_cep <> " " THEN
           LET l_texto2 = l_texto2 CLIPPED, "   CEP: ", p_nff.cod_cep_cob
      END IF
 END IF
 LET p_qtd_lin_obs = p_qtd_lin_obs + 1
 IF p_qtd_lin_obs >= 10 THEN

      LET p_des_texto2 = l_texto CLIPPED, "   ", l_texto2 CLIPPED
      INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                     "","","","","", p_des_texto2,"","","","")
 ELSE
      LET pa_texto_obs[p_qtd_lin_obs].texto = l_texto
      LET p_num_seq = p_num_seq + 1
      LET p_qtd_lin_obs = p_qtd_lin_obs + 1
      IF p_qtd_lin_obs < 10 THEN
         LET pa_texto_obs[p_qtd_lin_obs].texto = l_texto2
      ELSE
         LET p_num_seq = p_num_seq + 1
         INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                        "","","","","", l_texto2,"","","","")
      END IF
 END IF

END FUNCTION

#-------------------------------------------#
 FUNCTION vdp3794_busca_dados_end_entrega()
#-------------------------------------------#
  SELECT wfat_end_ent.end_entrega,
         wfat_end_ent.den_bairro,
         cidades.den_cidade,
         cidades.cod_uni_feder
    INTO p_end_entrega.*
    FROM wfat_end_ent, cidades
   WHERE wfat_end_ent.cod_empresa = p_cod_empresa
     AND wfat_end_ent.num_nff     = p_wfat_mestre.num_nff
     AND wfat_end_ent.cod_cidade  = cidades.cod_cidade

   IF sqlca.sqlcode = 0 THEN
      IF p_end_entrega.end_entrega IS NOT NULL OR
         p_end_entrega.end_entrega  <> "  "    THEN
         LET p_des_texto = "End. Entrega.: ",
                            p_end_entrega.end_entrega CLIPPED, " - ",
                            p_end_entrega.den_bairro
         CALL vdp3794_insert_array(p_des_texto)

         IF p_end_entrega.den_cidade IS NOT NULL THEN
            LET p_des_texto   = "CIDADE.: ",
                                p_end_entrega.den_cidade,
                                " UF.: ",
                                p_end_entrega.cod_uni_feder
            CALL vdp3794_insert_array(p_des_texto)
         END IF

      END IF
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION vdp3794_prepara_linhas_texto()
#---------------------------------------#
 DEFINE i                    SMALLINT,
        p_count              SMALLINT

  INITIALIZE pa_texto_obs TO NULL
  LET p_count = 0

  #
  # Imprime informações de ST 
  #
  IF p_wfat_mestre.val_tot_icm_ret > 0 THEN
     LET p_des_texto = "ICMS OPER.PROP.: ", p_nff.val_tot_icm USING "######,##&.&&";
     CALL vdp3794_insert_array(p_des_texto)
  END IF
  
  { imprime texto da nota, se este existir }

  IF (p_wfat_mestre.cod_texto1 <> 0  OR
      p_wfat_mestre.cod_texto2 <> 0  OR
      p_wfat_mestre.cod_texto3 <> 0) THEN
     DECLARE cq_texto_nf CURSOR FOR
      SELECT des_texto
        FROM texto_nf
       WHERE cod_texto IN (p_wfat_mestre.cod_texto1,
                           p_wfat_mestre.cod_texto2,
                           p_wfat_mestre.cod_texto3)

     FOREACH cq_texto_nf INTO p_des_texto2
        IF p_des_texto2[1,50] IS NOT NULL AND
           p_des_texto2[1,50] <> " " THEN
           LET p_count = p_count + 1
           LET p_qtd_lin_obs = p_qtd_lin_obs + 1
           LET pa_texto_obs[p_qtd_lin_obs].texto = p_des_texto2[1,50]
        END IF
        IF p_des_texto2[51,100] IS NOT NULL AND
           p_des_texto2[51,100] <> " " THEN
           LET p_count = p_count + 1
           LET p_qtd_lin_obs = p_qtd_lin_obs + 1
           LET pa_texto_obs[p_qtd_lin_obs].texto = p_des_texto2[51,100]
        END IF
        IF p_des_texto2[101,120] IS NOT NULL AND
           p_des_texto2[101,120] <> " " THEN
           LET p_count = p_count + 1
           LET p_qtd_lin_obs = p_qtd_lin_obs + 1
           LET pa_texto_obs[p_qtd_lin_obs].texto = p_des_texto2[101,120]
        END IF
     END FOREACH
  END IF

  { imprime texto do pedido, se este existir }

  IF vdp3794_verifica_texto_ped_it(pa_corpo_nff[1].num_pedido,0) THEN
     FOR i = 1 TO 05
        IF pa_texto_ped_it[i].texto IS NOT NULL AND
            pa_texto_ped_it[i].texto <> " " THEN
            LET p_count = p_count + 1
            LET p_qtd_lin_obs = p_qtd_lin_obs + 1
            LET pa_texto_obs[p_qtd_lin_obs].texto = pa_texto_ped_it[i].texto
        END IF
     END FOR
  END IF

END FUNCTION

#---------------------------------------------------------------------#
 FUNCTION vdp3794_verifica_texto_ped_it(p_num_pedido, p_num_sequencia)
#---------------------------------------------------------------------#
 DEFINE p_num_pedido     LIKE pedidos.num_pedido,
        p_num_sequencia  LIKE ped_itens_texto.num_sequencia

 INITIALIZE pa_texto_ped_it     TO NULL
 INITIALIZE p_ped_itens_texto.* TO NULL

 WHENEVER ERROR CONTINUE
  SELECT ped_itens_texto.*
    INTO p_ped_itens_texto.*
    FROM ped_itens_texto
   WHERE ped_itens_texto.cod_empresa   = p_cod_empresa
     AND ped_itens_texto.num_pedido    = p_num_pedido
     AND ped_itens_texto.num_sequencia = p_num_sequencia
 WHENEVER ERROR STOP
 IF sqlca.sqlcode = 0 THEN
    LET pa_texto_ped_it[1].texto = p_ped_itens_texto.den_texto_1
    LET pa_texto_ped_it[2].texto = p_ped_itens_texto.den_texto_2
    LET pa_texto_ped_it[3].texto = p_ped_itens_texto.den_texto_3
    LET pa_texto_ped_it[4].texto = p_ped_itens_texto.den_texto_4
    LET pa_texto_ped_it[5].texto = p_ped_itens_texto.den_texto_5
    RETURN TRUE
 ELSE
    RETURN FALSE
 END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION vdp3794_busca_dados_historicos()
#-----------------------------------------#

  INITIALIZE p_wfat_historico.*   TO NULL

  SELECT * INTO p_wfat_historico.*
    FROM wfat_historico
   WHERE cod_empresa = p_cod_empresa
     AND num_nff = p_wfat_mestre.num_nff

  IF p_wfat_historico.tex_hist1_1 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist1_1)
  END IF

  IF p_wfat_historico.tex_hist2_1 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist2_1)
  END IF

  IF p_wfat_historico.tex_hist3_1 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist3_1)
  END IF

  IF p_wfat_historico.tex_hist4_1 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist4_1)
  END IF

  IF p_wfat_historico.tex_hist1_2 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist1_2)
  END IF

  IF p_wfat_historico.tex_hist2_2 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist2_2)
  END IF

  IF p_wfat_historico.tex_hist3_2 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist3_2)
  END IF

  IF p_wfat_historico.tex_hist4_2 <> " " THEN
     CALL vdp3794_insert_array(p_wfat_historico.tex_hist4_2)
  END IF

 END FUNCTION

#------------------------------------#
 FUNCTION vdp3794_imprime_clas_fisc()
#------------------------------------#

  DEFINE l_ind            SMALLINT

  { LET p_num_seq = p_num_seq + 1
    LET p_qtd_lin_obs = p_qtd_lin_obs + 1
    LET p_des_texto = "      CLASSIFICACOES FISCAIS"
    IF p_qtd_lin_obs < 9 THEN
       LET pa_texto_obs[p_qtd_lin_obs].texto = p_des_texto
    ELSE
       INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                      "","","","","",p_des_texto,"","","","")
    END IF }

    FOR l_ind = 1 TO 12
       IF pa_cla_fisc[l_ind].cod_cla_fisc IS NOT NULL AND
          pa_cla_fisc[l_ind].cod_cla_fisc <> " " AND
          pa_cla_fisc[l_ind].cla_fisc_nff <> "A" AND
          pa_cla_fisc[l_ind].cla_fisc_nff <> "B" AND
          pa_cla_fisc[l_ind].cla_fisc_nff <> "C" AND
          pa_cla_fisc[l_ind].cla_fisc_nff <> "D" THEN
          LET p_num_seq = p_num_seq + 1
          LET p_qtd_lin_obs = p_qtd_lin_obs + 1
          LET p_des_texto = "   ", pa_cla_fisc[l_ind].cla_fisc_nff, " - ",
              pa_cla_fisc[l_ind].cod_cla_fisc USING "&&&&&&&&&&"
          IF p_qtd_lin_obs < 10 THEN
             LET pa_texto_obs[p_qtd_lin_obs].texto = p_des_texto
          ELSE
             INSERT INTO wnotakana VALUES ( p_num_seq,3,"","","","","","","","","","",
                                            "","","","","", p_des_texto,"","","","")
          END IF
       END IF
    END FOR

END FUNCTION

#------------------------------------#
# FUNCTION vdp8077_monta_clas_fiscal()
##------------------------------------#
# DEFINE l_ind       SMALLINT
#
# LET p_des_texto = NULL
#
# FOR l_ind = 1 TO 99
#    IF ma_clas_fisc[l_ind].cod_cla_fisc_nf IS NULL OR
#       ma_clas_fisc[l_ind].cod_cla_fisc_nf = " " THEN
#       EXIT FOR
#    END IF
#
#    IF (LENGTH(p_des_texto) + 16) <= 120 THEN
#       LET p_des_texto = p_des_texto CLIPPED, '  ', ma_clas_fisc[l_ind].cla_fisc_nff CLIPPED, " - ",
#                         ma_clas_fisc[l_ind].cod_cla_fisc_nf CLIPPED
#    ELSE
#       CALL vdp3794_insert_array(m_des_texto)
#       LET p_des_texto = NULL
#       LET p_des_texto = ma_clas_fisc[l_ind].cla_fisc_nff CLIPPED , " - ",
#                         ma_clas_fisc[l_ind].cod_cla_fisc_nf CLIPPED
#
#    END IF
#    LET l_ind = l_ind + 1
# END FOR
#
# CALL vdp3794_insert_array(p_des_texto)
#
#END FUNCTION
#


#-----------------------------------------#
 FUNCTION vdp3794_insert_array(l_des_texto)
#-----------------------------------------#
  DEFINE l_des_texto               CHAR(120),
         l_texto_1                 CHAR(50),
         l_texto_2                 CHAR(50),
         l_texto_3                 CHAR(50)

  LET l_texto_1     = l_des_texto[1,50]
  LET l_texto_2     = l_des_texto[51,100]
  LET l_texto_3     = l_des_texto[101,120]

  IF LENGTH(l_texto_1) > 0 THEN
     LET p_num_seq     = p_num_seq + 1
     LET p_qtd_lin_obs = p_qtd_lin_obs + 1

     IF p_qtd_lin_obs < 10 THEN
        LET pa_texto_obs[p_qtd_lin_obs].texto = l_texto_1
     ELSE
        INSERT INTO wnotakana
            VALUES ( p_num_seq,3,"","","","","","","","","","","","","","","",
                        l_des_texto,"","","","")
        RETURN
     END IF
  END IF

  IF LENGTH(l_texto_2) > 0 THEN
     LET p_num_seq     = p_num_seq + 1
     LET p_qtd_lin_obs = p_qtd_lin_obs + 1

     IF p_qtd_lin_obs < 10 THEN
        LET pa_texto_obs[p_qtd_lin_obs].texto = l_texto_2
     ELSE
        INSERT INTO wnotakana
            VALUES ( p_num_seq,3,"","","","","","","","","","","","","","","",
                        l_texto_2,"","","","")
        RETURN
     END IF
  END IF

  IF LENGTH(l_texto_3) > 0 THEN
     LET p_num_seq     = p_num_seq + 1
     LET p_qtd_lin_obs = p_qtd_lin_obs + 1

     IF p_qtd_lin_obs < 10 THEN
        LET pa_texto_obs[p_qtd_lin_obs].texto = l_texto_3
     ELSE
        INSERT INTO wnotakana
            VALUES ( p_num_seq,3,"","","","","","","","","","","","","","","",
                        l_texto_3,"","","","")
        RETURN
     END IF
  END IF

END FUNCTION

#--------------------------------------------#
REPORT vdp3794_relat(p_wnotakana)
#--------------------------------------------#
  DEFINE p_wnotakana       RECORD
                 num_seq         SMALLINT,
                 ies_tip_info    SMALLINT,
                 cod_item        CHAR(016),   #  LIKE wfat_item.cod_item,
                 pes_unit        LIKE wfat_item.pes_unit,
                 den_item        CHAR(37),
                 cod_fiscal      LIKE wfat_item_fiscal.cod_fiscal,
                 cod_cla_fisc    LIKE wfat_item.cod_cla_fisc,
                 cod_origem      LIKE wfat_mestre.cod_origem,
                 cod_tributacao  LIKE wfat_mestre.cod_tributacao,
                 cod_unid_med    LIKE wfat_item.cod_unid_med,
                 qtd_item        LIKE wfat_item.qtd_item,
                 pre_unit        LIKE wfat_item.pre_unit_nf,
                 desconto        CHAR(010),
                 val_liq_item    LIKE wfat_item.val_liq_item,
                 pct_icm         LIKE wfat_mestre.pct_icm,
                 pct_ipi         LIKE wfat_item.pct_ipi,
                 val_ipi         LIKE wfat_item.val_ipi,
                 des_texto       CHAR(120),
                 num_pedido      LIKE pedidos.num_pedido,
                 num_seq_nfitem  LIKE nf_item.num_sequencia,
                 ies_bonificacao CHAR(01),
                 num_nff         LIKE wfat_mestre.num_nff
                            END RECORD

  DEFINE i, j, x          SMALLINT,
         l_texto          CHAR(120),
         p_ies_origem     CHAR(01)

  DEFINE l_cont                      SMALLINT

  DEFINE  p_des_folha            CHAR(100)

  OUTPUT LEFT   MARGIN   0
         TOP    MARGIN   0
         BOTTOM MARGIN   0
         PAGE   LENGTH  96

  ORDER EXTERNAL BY p_wnotakana.num_nff,
                    p_wnotakana.num_seq

  FORMAT

       PAGE HEADER

       LET p_num_pagina = p_num_pagina + 1
{01}   PRINT p_comprime, p_8lpp

       #----------------CABECALHO----------------#
       SKIP 1 LINES
{04}   PRINT COLUMN 108, "XX",
             COLUMN 143, p_nff.num_nff         USING "######"
       SKIP 4 LINES

       LET l_texto = 'NOVO C.N.P.J.:43.942.598/0004-93 - I.E.:298.134.378.112'

       IF  p_impr_novo_cnpj = 'N' THEN
           LET l_texto = ' '
       END IF

       PRINT COLUMN 045, l_texto

       SKIP 1 LINES
{11}   PRINT COLUMN 003, p_nff.den_nat_oper;
      IF p_nff.cod_fiscal2 IS NOT NULL THEN
         PRINT COLUMN 066, p_nff.cod_fiscal1      USING "#&&&",
                           m_cod_fiscal_compl     USING "&",
                           "/",
                           p_nff.cod_fiscal2      USING "#&&&",
                           m_cod_fiscal_compl     USING "&",
               COLUMN 083, " ",p_nff.ins_estadual_trib
      ELSE
         PRINT COLUMN 066, p_nff.cod_fiscal1      USING "#&&&",
                           m_cod_fiscal_compl     USING "&",
               COLUMN 083, " ",p_nff.ins_estadual_trib
      END IF
             {COLUMN 067, p_nff.cod_fiscal      USING "&&&",
                         m_cod_fiscal_compl    USING "&",
             COLUMN 083, p_nff.ins_estadual_trib}
       SKIP 3 LINES

       #----------------DESTINATARIO / REMETENTE----------------#

{15}   PRINT COLUMN 003, p_nff.nom_destinatario,
             COLUMN 089, p_nff.cod_cliente,
             COLUMN 113, p_nff.num_cgc_cpf,
             COLUMN 145, p_nff.dat_emissao     USING "dd/mm/yyyy"
       SKIP 2 LINES
{18}   PRINT COLUMN 003, p_nff.end_destinatario,
             COLUMN 088, p_nff.den_bairro,
             COLUMN 123, p_nff.cod_cep,
             COLUMN 145, p_nff.dat_saida
       SKIP 1 LINE
{20}   PRINT COLUMN 003, p_nff.den_cidade,
             COLUMN 073, p_nff.num_telefone,
             COLUMN 102, p_nff.cod_uni_feder,
             COLUMN 114, p_nff.ins_estadual,
             COLUMN 147, p_nff.hora_saida

       SKIP 3 LINES {24 linhas ate aqui}

       #----------------FATURA----------------#

{25}   PRINT COLUMN 069, p_nff.dat_vencto1,
             COLUMN 087, p_nff.dat_vencto2,
             COLUMN 106, p_nff.dat_vencto3,
             COLUMN 125, p_nff.dat_vencto4,
             COLUMN 144, p_nff.dat_vencto5
       SKIP 2 LINES
{27}   PRINT COLUMN 069, p_nff.val_duplic1  USING "####,###,###.##",
             COLUMN 087, p_nff.val_duplic2  USING "####,###,###.##",
             COLUMN 106, p_nff.val_duplic3  USING "####,###,###.##",
             COLUMN 125, p_nff.val_duplic4  USING "####,###,###.##",
             COLUMN 144, p_nff.val_duplic5  USING "####,###,###.##"
       SKIP 4 LINES

       #----------------DADOS DO PRODUTO----------------#

       BEFORE GROUP OF p_wnotakana.num_nff
         SKIP TO TOP OF PAGE

       ON EVERY ROW

       CASE
         WHEN p_wnotakana.ies_tip_info = 1
              IF p_wnotakana.ies_bonificacao = "S"
              THEN LET p_ies_origem = "B"
              ELSE LET p_ies_origem = "I"
              END IF

{32 - 57}     PRINT COLUMN 003, p_wnotakana.cod_item[1,12],
                    COLUMN 016, p_wnotakana.pes_unit       USING "#####&.&&",
                    COLUMN 025, p_wnotakana.den_item CLIPPED,
                    #COLUMN 058, p_wnotakana.cod_fiscal  USING "&&&",
                     #           m_cod_fiscal_compl      USING "&",
                    COLUMN 063, p_wnotakana.cod_cla_fisc[1,1],
                    COLUMN 067, p_wnotakana.cod_origem     USING "&",
                    COLUMN 068, p_wnotakana.cod_tributacao USING "&&",
                    COLUMN 072, p_wnotakana.cod_unid_med,
                    COLUMN 080, p_wnotakana.qtd_item       USING "####&.&&&",
                    COLUMN 093, p_wnotakana.pre_unit       USING "#######&.&&&&&",
                    COLUMN 116, p_wnotakana.val_liq_item   USING "#########&.&&",
                    COLUMN 133, p_wnotakana.pct_icm        USING "#&",
                    COLUMN 138, p_wnotakana.pct_ipi        USING "#&",
                    COLUMN 148, p_wnotakana.val_ipi        USING "######&.&&"

              LET p_linhas = p_linhas + 1
              LET p_seq =  p_seq   +  1
              LET p_array = p_array + 1

              WHENEVER ERROR CONTINUE
                DELETE FROM nf_item_sequencia
                 WHERE cod_empresa   = p_cod_empresa
                   AND num_nff       = p_wnotakana.num_nff
                   AND num_pedido    = p_wnotakana.num_pedido
                   AND num_sequencia = p_wnotakana.num_seq
                INSERT INTO nf_item_sequencia
                VALUES (p_cod_empresa,
                        p_wnotakana.num_nff,
                        p_wnotakana.num_pedido,
                        p_wnotakana.cod_item,
                        p_wnotakana.num_seq_nfitem,
                        p_seq,
                        p_ies_origem
                       )
              WHENEVER ERROR STOP

         WHEN p_wnotakana.ies_tip_info = 2
              PRINT COLUMN 025, p_wnotakana.den_item
              LET p_linhas = p_linhas + 1

         WHEN p_wnotakana.ies_tip_info = 3
             PRINT COLUMN 025, p_wnotakana.des_texto
             LET p_linhas = p_linhas + 1

        #   IF p_status THEN
        #       IF (24 - (p_linhas + p_qtd_lin_obs) ) > 0 THEN
        #          LET p_status = FALSE
        #       END IF
        #       WHILE (24 - (p_linhas + p_qtd_lin_obs) ) > 0
        #          PRINT COLUMN 002, " "
        #          LET p_linhas = p_linhas + 1
        #       END WHILE
        #    END IF
        #    PRINT COLUMN 025, p_wnotakana.des_texto


         WHEN p_wnotakana.ies_tip_info = 4
              WHILE TRUE
                 IF p_linhas < 24 THEN
                    PRINT
                    LET p_linhas = p_linhas + 1
                 ELSE
                    EXIT WHILE
                 END IF
              END WHILE
       END CASE

       IF p_linhas = 24 THEN { numero de linhas do corpo da nota }{52 ate aqui}

          IF p_num_pagina = p_tot_paginas THEN
             LET p_des_folha = "Folha ", p_num_pagina  USING "&&","/",
                               p_tot_paginas USING "&&"
          ELSE
             LET p_des_folha = "Folha ", p_num_pagina  USING "&&","/",
                               p_tot_paginas USING "&&"," - Continua"
          END IF
          PRINT COLUMN 005, p_des_folha
          IF p_num_pagina = p_tot_paginas THEN
             LET p_nff.val_tot_base_icm = 0

             FOR x = 1 TO 99
                IF ma_n_trib[x].pct_icm IS NULL THEN
                   EXIT FOR
                END IF

                IF ma_n_trib[x].pct_icm > 0 THEN
                   LET p_nff.val_tot_base_icm = p_nff.val_tot_base_icm
                                            + ma_n_trib[x].val_base_icm
                END IF
                
                IF p_nff.val_tot_icm_ret > 0 THEN
                  
                  INITIALIZE p_nff.val_tot_base_icm TO NULL
                  
                  WHENEVER ERROR CONTINUE
                    SELECT val_tot_base_icm
                      INTO p_nff.val_tot_base_icm
                      FROM nf_mestre
                     WHERE cod_empresa = p_cod_empresa
                       AND num_nff = p_wnotakana.num_nff                      
                  WHENEVER ERROR STOP
                  
                  IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
                    CALL log003_err_sql("SELECT","NF_MESTRE")
                    RETURN
                  END IF
                  
                END IF
                                                
             END FOR

             SKIP 3 LINES

           #----------------CALCULO DO IMPOSTO----------------#

{61}         PRINT COLUMN 017, p_nff.val_tot_base_icm    USING "####,###,##&.&&";
             ##IF p_nff.val_tot_icm > 0  THEN
             #PRINT  COLUMN 048, p_nff.val_tot_icm  USING "######,##&.&&";
             ##END IF
             
             IF p_nff.val_tot_icm_ret = 0 THEN
               PRINT  COLUMN 048, p_nff.val_tot_icm  USING "######,##&.&&";
             END IF
             
{61}         PRINT COLUMN 084, p_nff.val_tot_base_ret    USING "######,##&.&&",
                   COLUMN 112, p_nff.val_tot_icm_ret     USING "######,##&.&&",
                   COLUMN 143, p_nff.val_tot_mercadoria  USING "#####,###,##&.&&"
             SKIP 2 LINES
{64}         PRINT COLUMN 010, p_nff.val_frete_cli       USING "####,###,##&.&&",
                   COLUMN 035, p_nff.val_seguro_cli      USING "######,##&.&&",
                   COLUMN 071, p_nff.val_tot_despesas    USING "######,##&.&&",
                   COLUMN 109, p_nff.val_tot_ipi         USING "#####,###,##&.&&",
                   COLUMN 143, p_nff.val_tot_nff         USING "#####,###,##&.&&"
             SKIP 3 LINES

             #----------------TRANSPORTADOR / VOLUMES TRANSPORTADOS----------------#

{68}         PRINT COLUMN 003, p_nff.nom_transpor, #p_consignat.den_consignat,
                   COLUMN 103, p_nff.ies_frete,
                   COLUMN 113, p_nff.num_placa,
                   COLUMN 126, "",
                   COLUMN 135, p_nff.num_cgc_trans #p_consignat.num_cgc_cpf
             SKIP 2 LINES
{71}         PRINT COLUMN 003, p_nff.end_transpor, #p_consignat.end_consignat,
                   COLUMN 091, p_nff.den_cidade_trans, #p_consignat.den_cidade,
                   COLUMN 126, p_nff.cod_uni_feder_trans, #p_consignat.cod_uni_feder,
                   COLUMN 137, p_nff.ins_estadual_trans #p_consignat.ins_estadual
             SKIP 2 LINES
{74}         PRINT COLUMN 013, p_nff.qtd_volume          USING "#####",
                   COLUMN 033, p_nff.des_especie,
                   COLUMN 075, "KANAFLEX",     # Cliente solicitou valor fixo.
                   COLUMN 091, p_nff.num_pri_volume      USING "###&", "/",
                   COLUMN 091, p_nff.num_ult_volume      USING "###&.&&&&",
                   COLUMN 118, p_nff.pes_tot_bruto       USING "#####&.&&&&",
                   COLUMN 148, p_nff.pes_tot_liquido     USING "#####&.&&&&"
             SKIP 2 LINES
             LET p_num_pagina = 0
          ELSE
             SKIP 2 LINES
             PRINT COLUMN 011, "**********",
                   COLUMN 040, "**********",
                   COLUMN 070, "**********",
                   COLUMN 107, "**********",
                   COLUMN 134, "**********"
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 011, "**********",
                   COLUMN 030, "**********",
                   COLUMN 070, "**********",
                   COLUMN 097, "**********",
                   COLUMN 134, "**********"
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             PRINT COLUMN 001, " "
             SKIP 06 LINES
          END IF
           #----------------DADOS ADICIONAIS----------------#

{77}      PRINT COLUMN 041, p_nff.end_cob_cli
{78}      PRINT COLUMN 011, p_nff.nom_repres[1,15];
          IF p_nff.den_cidade_cob IS NOT NULL THEN
             PRINT COLUMN 041, p_nff.den_cidade_cob     CLIPPED, "  -  ",
                               p_nff.cod_uni_feder_cobr
          ELSE
             PRINT
          END IF
{79}      PRINT COLUMN 011, p_nff.num_pedido                 USING "######"
{80}      PRINT COLUMN 011, p_nff.num_pedido_cli             USING "######",
                COLUMN 027, pa_texto_obs[1].texto
{81}      PRINT COLUMN 027, pa_texto_obs[2].texto
{82}      PRINT COLUMN 011, p_nff.num_pedido_repres,
                COLUMN 027, pa_texto_obs[3].texto
{83}      PRINT COLUMN 027, pa_texto_obs[4].texto
{84}      PRINT COLUMN 027, pa_texto_obs[5].texto
{85}      PRINT COLUMN 027, pa_texto_obs[6].texto
{86}      PRINT COLUMN 027, pa_texto_obs[7].texto
{87}      PRINT COLUMN 027, pa_texto_obs[8].texto
{88}      PRINT COLUMN 027, pa_texto_obs[9].texto

          SKIP 5 LINES

           #----------------CANHOTO----------------#

{94}      PRINT COLUMN 068, p_nff.num_nff             USING "######",
                COLUMN 149, p_nff.num_nff             USING "######"


          LET p_linhas = 0

          SKIP 3 LINES

          PRINT p_comprime, p_8lpp
       END IF
END REPORT
