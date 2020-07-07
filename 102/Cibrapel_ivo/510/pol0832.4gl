#------------------------------------------------------------------#
# OBJETIVO: IMPRESSAO AR (CIBRAPEL)                                #
#------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa            LIKE empresa.cod_empresa,
          p_den_reduz              LIKE empresa.den_reduz,
          p_user                   LIKE usuario.nom_usuario,
          p_status                 SMALLINT,
          p_nom_arquivo            CHAR(100),
          p_ies_impressao          CHAR(01),
          p_caminho                CHAR(080),
          comando                  CHAR(80),
          g_ies_ambiente           CHAR(001),
          p_par_val                SMALLINT,
          p_texto1                 CHAR(75),
          p_texto2                 CHAR(75),
          p_controle               SMALLINT,
          p_ind                    SMALLINT,
          p_den_texto              CHAR(120),
          p_cod_clas_fisc          CHAR(10),
          p_num_item               CHAR(01),
          p_cod_ref_clas           CHAR(01),
          p_nom_comprador          LIKE comprador.nom_comprador,
          p_cod_progr              LIKE programador.nom_progr,
          p_num_seq                SMALLINT,
          p_msg                    CHAR(100)
           
   DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

   DEFINE p_dat_ult_fat            DATE,
          p_dat_fat_numero         DATE,
          p_ies_nfe_emit           CHAR(01),
          p_cod_operacao           CHAR(06),
          p_cod_fiscal             CHAR(06),
          p_cod_cla_h              CHAR(10),
          p_cod_cla_i              CHAR(10),
          p_cod_fiscal_compl       INTEGER, 
          p_cont_dados             SMALLINT,
          p_contador               SMALLINT,
          p_cont_fisc              SMALLINT,
          p_des_texto              CHAR(120),
          p_des_texto1             LIKE texto_nf.des_texto,
          p_des_texto2             LIKE texto_nf.des_texto,
          p_ies_informou           SMALLINT,
          p_atualiza               SMALLINT,
          p_qtd_linhas_dispon      INTEGER,
          p_cod_texto              LIKE texto_nf.cod_texto,
          p_num_aviso_rec          LIKE nf_sup.num_aviso_rec,
          p_ser_nf                 LIKE nf_sup.ser_nf,
          p_ssr_nf                 LIKE nf_sup.ssr_nf,
          p_num_ar_ini             LIKE aviso_rec.num_aviso_rec,     
          p_num_ar_fim             LIKE aviso_rec.num_aviso_rec,     
          p_nr_aviso_rec           LIKE nf_sup.num_aviso_rec,
          p_ies_num_nf_vdp         LIKE par_sup_pad.par_ies,
          p_num_nf                 LIKE nf_sup.num_nf,
          p_num_pedido             LIKE aviso_rec.num_pedido,
          p_num_oc                 LIKE aviso_rec.num_oc,
          p_cod_secao_receb        LIKE dest_aviso_rec.cod_secao_receb,
          p_par_sup_pad            RECORD LIKE par_sup_pad.*,
          p_fiscal_par             RECORD LIKE fiscal_par.*,
          p_nf_sup                 RECORD LIKE nf_sup.*,
          p_nfe_sup_compl          RECORD LIKE nfe_sup_compl.*,
          p_aviso_rec              RECORD LIKE aviso_rec.*

   DEFINE p_clas_fisc              RECORD
          denominacao              CHAR(10),
          percentual               CHAR(02)
                                  END RECORD 	
 
   DEFINE p_clas_fisc_temp         RECORD
          cod_cla_fisc             CHAR(010),
          num_item                 DECIMAL(1,0)
                                  END RECORD 	

   DEFINE p_cidades                RECORD LIKE cidades.*,
          p_embalagem              RECORD LIKE embalagem.*,
          p_fornecedor             RECORD LIKE fornecedor.*,
          p_transport              RECORD LIKE transport.*,
          p_subst_trib_uf          RECORD LIKE subst_trib_uf.*
 
   DEFINE p_nff                    RECORD
          num_nff                  LIKE wfat_mestre_ent.num_nff,
          den_nat_oper             LIKE nat_operacao.den_nat_oper,
          cod_fiscal               CHAR(06),
          cod_fiscal_compl         LIKE aviso_rec_compl.cod_fiscal_compl,
          num_di                   LIKE aviso_rec_compl.num_di,
          ins_estadual_trib        LIKE subst_trib_uf.ins_estadual,
          nom_destinatario         LIKE clientes.nom_cliente,
          num_cgc_cpf              LIKE clientes.num_cgc_cpf,
          dat_emissao              LIKE wfat_mestre_ent.dat_emissao,
          end_destinatario         LIKE clientes.end_cliente,
          den_bairro               LIKE clientes.den_bairro,
          cod_cep                  LIKE clientes.cod_cep,
          dat_entrada_saida        LIKE wfat_mestre_ent.dat_emissao,
          den_cidade               LIKE cidades.den_cidade,
          num_telefone             LIKE clientes.num_telefone,
          cod_uni_feder            LIKE cidades.cod_uni_feder,
          ins_estadual             LIKE clientes.ins_estadual,
          hora_impres               DATETIME HOUR TO MINUTE,

   { Corpo da nota contendo os itens da mesma. Pode conter ate 999 itens }

          val_tot_base_icm         LIKE wfat_mestre_ent.val_tot_base_icm,
          val_tot_icm              LIKE wfat_mestre_ent.val_tot_icm,
          val_tot_base_ret         LIKE wfat_mestre_ent.val_tot_base_ret,
          val_tot_icm_ret          LIKE wfat_mestre_ent.val_tot_icm_ret,
          val_tot_mercadoria       LIKE wfat_mestre_ent.val_tot_mercadoria,
          val_tot_frete            LIKE wfat_mestre_ent.val_tot_frete,
          val_tot_seguro           LIKE wfat_mestre_ent.val_tot_seguro,
          val_tot_despesas         LIKE wfat_mestre_ent.val_tot_seguro,
          val_tot_ipi              LIKE wfat_mestre_ent.val_tot_ipi,
          val_tot_nff              LIKE wfat_mestre_ent.val_tot_nff,
          nom_transpor             LIKE clientes.nom_cliente,
          ies_frete                LIKE wfat_mestre_ent.ies_frete,
          num_placa                LIKE wfat_mestre_ent.num_placa,
          cod_uni_feder_trans      LIKE cidades.cod_uni_feder,
          num_cgc_trans            LIKE clientes.num_cgc_cpf,
          end_transpor             LIKE clientes.end_cliente,
          den_cidade_trans         LIKE cidades.den_cidade,
          ins_estadual_trans       LIKE clientes.ins_estadual,
          qtd_volume               LIKE wfat_mestre_ent.qtd_volumes1,
          des_especie              CHAR(035),
          den_marca                LIKE clientes.den_marca,
          pes_tot_bruto            LIKE wfat_mestre_ent.pes_tot_bruto,
          pes_tot_liquido          LIKE wfat_mestre_ent.pes_tot_liquido,
          nom_progr                LIKE programador.nom_progr,
          nom_receb                CHAR(30) 
       END RECORD

   DEFINE pa_corpo_nff             ARRAY[999] OF RECORD
            cod_item                 LIKE wfat_item_ent.cod_item,
            num_pedido               LIKE wfat_item_ent.num_pedido,
            den_item1                CHAR(030),
            cod_cla_fisc             CHAR(010),
            cod_origem               LIKE wfat_mestre_ent.cod_origem,
            cod_tributacao           LIKE tributacao.cod_tributacao,
            cod_unid_med             LIKE wfat_item_ent.cod_unid_med,
            qtd_item                 LIKE wfat_item_ent.qtd_item,
            peso_liq                 DECIMAL(10,5),
            pre_unit                 LIKE wfat_item_ent.pre_unit_nf,
            val_liq_item             LIKE wfat_item_ent.val_liq_item,
            pct_icm                  LIKE wfat_mestre_ent.pct_icm,
            pct_ipi                  LIKE wfat_item_ent.pct_ipi,
            val_ipi                  LIKE wfat_item_ent.val_ipi
                                   END RECORD

   DEFINE p_dados_nota             RECORD
             num_seq                  SMALLINT,
             ies_tip_info             SMALLINT,
             cod_item                 LIKE wfat_item.cod_item,
             den_item                 CHAR(30),
             cod_cla_fisc             CHAR(010),
             cod_origem               LIKE wfat_mestre_ent.cod_origem,
             cod_tributacao           LIKE tributacao.cod_tributacao,
             cod_unid_med             LIKE wfat_item_ent.cod_unid_med,
             qtd_item                 LIKE wfat_item_ent.qtd_item,
             peso_liq                 DECIMAL(10,5),
             pre_unit                 LIKE wfat_item_ent.pre_unit_nf,
             val_liq_item             LIKE wfat_item_ent.val_liq_item,
             pct_icm                  LIKE wfat_mestre_ent.pct_icm,
             pct_ipi                  LIKE wfat_item_ent.pct_ipi,
             val_ipi                  LIKE wfat_item_ent.val_ipi,
             des_texto                CHAR(120),
             num_nff                  LIKE wfat_mestre_ent.num_nff,
             num_ar                   LIKE nf_sup.num_aviso_rec,
             ies_tipo                 CHAR(01)
                                   END RECORD

   DEFINE p_consignat              RECORD
             den_consignat            LIKE clientes.nom_cliente,
             end_consignat            LIKE clientes.end_cliente,
             den_bairro               LIKE clientes.den_bairro,
             den_cidade               LIKE cidades.den_cidade,
             cod_uni_feder            LIKE cidades.cod_uni_feder
                                   END RECORD

   DEFINE p_comprime               CHAR(01),
          p_descomprime            CHAR(01),
          p_6lpp                   CHAR(02),
          p_8lpp                   CHAR(02)

   DEFINE pa_historico             ARRAY[08] OF RECORD
          texto                    CHAR(150)
                                   END RECORD

   DEFINE pa_texto                 ARRAY[12] OF RECORD
          texto                    CHAR(150)
                                   END RECORD

   DEFINE p_txt                    ARRAY[24] OF RECORD
          texto                    CHAR(53)
          END RECORD
          
   DEFINE p_textos                 RECORD
          texto1                   CHAR(120),
          texto2                   CHAR(120),
          texto3                   CHAR(120),
          texto4                   CHAR(120),
          texto5                   CHAR(120),
          texto6                   CHAR(120),
          texto7                   CHAR(120),
          texto8                   CHAR(120),
          texto9                   CHAR(120),
          texto10                  CHAR(120),
          texto11                  CHAR(120),
          texto12                  CHAR(120)
                                   END RECORD

   DEFINE p_texto1               CHAR(55), 
          p_texto2               CHAR(55),
          p_texto3               CHAR(55)


   DEFINE p_num_linhas             SMALLINT,
          p_num_pagina             SMALLINT,
          p_tot_paginas            SMALLINT,
          p_houve_consig           SMALLINT,
          p_ies_lista              SMALLINT,
          p_linhas_print           SMALLINT,
          p_ies_termina_relat      SMALLINT,
          p_vol_item               DECIMAL(9,3),
          p_vol_nf                 DECIMAL(9,3)

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0832-10.02.00" 
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 180
   WHENEVER ERROR STOP

   DEFER INTERRUPT

   CALL log140_procura_caminho("pol.iem") RETURNING comando
   OPTIONS
      FIELD ORDER UNCONSTRAINED,
      HELP FILE comando

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   SELECT den_reduz
     INTO p_den_reduz
     FROM empresa
    WHERE cod_empresa = p_cod_empresa 

   IF p_status = 0 THEN
      CALL pol0832_controle()
   END IF
END MAIN

#---------------------------#
 FUNCTION pol0832_controle()
#---------------------------#
   CALL log006_exibe_teclas("01", p_versao)
   CALL log130_procura_caminho("pol0832") RETURNING comando    

   OPEN WINDOW w_pol0832 AT 2,2  WITH FORM comando
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 2926
         MESSAGE ""
         CALL pol0832_inicializa_campos()
         IF log005_seguranca(p_user,"SUPRIMEN","pol0832","CO") THEN
            LET p_ies_informou = FALSE
            IF pol0832_entrada_parametros() THEN
               NEXT OPTION "Listar"
            END IF
         END IF
         
      COMMAND "Listar" "Lista as Notas Fiscais de Entrada"
         HELP 2927
         IF log005_seguranca(p_user,"SUPRIMEN","pol0832","CO") THEN
            IF p_ies_informou THEN
               IF pol0832_imprime_nff() THEN
                  NEXT OPTION "Fim"
               END IF 
            ELSE
               ERROR "Informe os Parametros para Listar"
               NEXT OPTION "Informar"
            END IF
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0832_sobre()   
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 509
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0832

END FUNCTION

#------------------------------------#
 FUNCTION pol0832_entrada_parametros()
#------------------------------------#

   CALL log006_exibe_teclas("01 02 07", p_versao)
   CURRENT WINDOW IS w_pol0832

   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_num_ar_ini, p_num_ar_fim TO NULL
   INITIALIZE p_nff.*, p_nf_sup.* TO NULL

   CALL pol0832_busca_par_sup_pad("ies_num_nf_entrada")

   IF p_par_sup_pad.par_ies IS NOT NULL THEN
      LET p_ies_num_nf_vdp = p_par_sup_pad.par_ies
      LET p_num_nf         = p_par_sup_pad.par_val - 1
   ELSE
      LET p_ies_num_nf_vdp = "N"
      LET p_num_nf         = 0 
   END IF

   INPUT BY NAME p_num_ar_ini,
                 p_num_ar_fim WITHOUT DEFAULTS 
 
     AFTER FIELD p_num_ar_ini
         IF p_num_ar_ini IS NOT NULL THEN
            IF pol0832_verifica_aviso_rec(p_num_ar_ini) = FALSE THEN
               ERROR "Aviso de recebimento nao cadastrado na nota fiscal do suprimentos."
               NEXT FIELD p_num_ar_ini
            END IF
         ELSE
            ERROR "Informe o numero de aviso de recebimento "
            NEXT FIELD p_num_ar_ini
         END IF
      
      AFTER FIELD p_num_ar_fim
         IF p_num_ar_ini IS NOT NULL THEN
            IF p_num_ar_fim < p_num_ar_ini THEN
               ERROR " A.R. final menor que A.R. inicial "
               NEXT FIELD p_num_ar_fim
            END IF

            IF pol0832_verifica_aviso_rec(p_num_ar_fim) = FALSE THEN
               ERROR "Aviso de recebimento nao cadastrado na nota fiscal do suprimentos."
               NEXT FIELD p_num_ar_fim
            END IF
         ELSE
            ERROR "Informe o numero de aviso de recebimento "
            NEXT FIELD p_num_ar_fim   
         END IF
  
      ON KEY(control-w,f1)
         CALL pol0832_help()
  
   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0832
        
   IF int_flag THEN
      LET int_flag = 0
      CLEAR FORM
      LET p_status = FALSE
      RETURN FALSE
   ELSE
      LET p_ies_informou = TRUE
      LET p_status = TRUE
      RETURN TRUE
   END IF
END FUNCTION

#---------------------------------------------------#
 FUNCTION pol0832_busca_par_sup_pad(p_cod_parametro)
#---------------------------------------------------#
 DEFINE p_cod_parametro LIKE par_sup_pad.cod_parametro 

   INITIALIZE p_par_sup_pad.* TO NULL

   SELECT *
     INTO p_par_sup_pad.*
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = p_cod_parametro

END FUNCTION

#---------------------------------------------#
 FUNCTION pol0832_verifica_aviso_rec(p_num_ar)
#---------------------------------------------#
 DEFINE p_num_ar LIKE aviso_rec.num_aviso_rec

   DECLARE cq_ver_aviso_rec  CURSOR FOR
    SELECT *
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar

   OPEN cq_ver_aviso_rec
   FETCH cq_ver_aviso_rec
   IF sqlca.sqlcode <> 0 THEN
      CLOSE cq_ver_aviso_rec 
      RETURN FALSE
   ELSE
      CLOSE cq_ver_aviso_rec 
      RETURN TRUE
   END IF
END FUNCTION

#-----------------------#
 FUNCTION pol0832_help()
#-----------------------#
   CASE
      WHEN infield(p_num_ar_ini)            CALL showhelp(3099) 
      WHEN infield(p_num_ar_fim)            CALL showhelp(3100)
   END CASE
END FUNCTION

#------------------------------#
 FUNCTION pol0832_imprime_nff()
#------------------------------#

   DEFINE sql_stmt CHAR(1000)

   LET p_qtd_linhas_dispon = 31
 
   IF log028_saida_relat(14,34) IS NOT NULL THEN
      MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
       
    IF p_ies_impressao = "S" THEN
         IF g_ies_ambiente = "W" THEN
            CALL log150_procura_caminho("LST") RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, "pol0832.tmp"
            START REPORT pol0832_relat TO p_caminho
         ELSE
            START REPORT pol0832_relat TO PIPE p_nom_arquivo
         END IF 
      ELSE
         START REPORT pol0832_relat TO p_nom_arquivo
      END IF
  
      WHENEVER ERROR CONTINUE
       CALL sup997_cria_t_pol0832()
      WHENEVER ERROR STOP

      INITIALIZE  p_nr_aviso_rec TO NULL

      DECLARE cq_nf_sup_temp CURSOR FOR
      SELECT num_aviso_rec 
      FROM nf_sup
      WHERE cod_empresa = p_cod_empresa
        AND num_aviso_rec BETWEEN p_num_ar_ini AND p_num_ar_fim

      FOREACH cq_nf_sup_temp INTO p_nr_aviso_rec
         INSERT INTO t_pol0832 VALUES (p_nr_aviso_rec)
      END FOREACH

      IF pol0832_imprime_relat() = FALSE THEN
         RETURN TRUE
      END IF

      FINISH REPORT pol0832_relat
      IF g_ies_ambiente  = "W" AND
         p_ies_impressao = "S" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo CLIPPED
         RUN comando
      END IF 
 
      IF p_ies_lista THEN
         IF p_ies_impressao = "S" THEN
            MESSAGE "Relatorio impresso na impressora ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
         ELSE
            MESSAGE "Relatorio gravado no arquivo ", p_nom_arquivo
                     ATTRIBUTE(REVERSE)
         END IF
         ERROR " Fim de processamento ..."  
      ELSE
         MESSAGE ""
         ERROR " Nao existem dados para serem listados. "
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
 FUNCTION pol0832_imprime_relat()
#--------------------------------#
   DECLARE cq_nf_sup CURSOR WITH HOLD FOR 
    SELECT num_aviso_rec FROM t_pol0832 ORDER BY num_aviso_rec

   OPEN cq_nf_sup
   FETCH cq_nf_sup INTO p_num_aviso_rec
   WHILE sqlca.sqlcode = 0
  
      CALL pol0832_imprime_dados() 

      FETCH cq_nf_sup INTO p_num_aviso_rec
      
   END WHILE

   RETURN TRUE
END FUNCTION

#------------------------------------#
 FUNCTION pol0832_inicializa_campos()
#------------------------------------#
   INITIALIZE p_transport.*    , p_nff.*   , pa_corpo_nff , p_consignat.* , 
              p_embalagem.*    , pa_texto  , p_cidades.*  , p_fornecedor.*, 
              p_subst_trib_uf.*, p_textos.*, p_clas_fisc.*  TO NULL
 
   LET p_houve_consig      = FALSE
   LET p_linhas_print      = 0
   LET p_vol_item          = 0
   LET p_vol_nf            = 0
   LET p_cont_fisc         = 0
   LET p_ies_termina_relat = TRUE
END FUNCTION

#--------------------------------#
 FUNCTION pol0832_imprime_dados()
#--------------------------------#
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_8lpp        = ascii 27, "0"
   LET p_6lpp        = ascii 27, "2"

   DECLARE cq_nf_sup_mst CURSOR WITH HOLD FOR
    SELECT * FROM nf_sup
     WHERE cod_empresa           = p_cod_empresa
       AND num_aviso_rec         = p_num_aviso_rec

   FOREACH cq_nf_sup_mst INTO p_nf_sup.*

      CALL pol0832_cria_tabela_temporaria()

      LET p_nff.ins_estadual_trib = p_subst_trib_uf.ins_estadual
      LET p_nff.dat_emissao       = p_nf_sup.dat_emis_nf
      LET p_nff.dat_entrada_saida = p_nf_sup.dat_entrada_nf

      CALL pol0832_busca_dados_fornec(p_nf_sup.cod_fornecedor)

      LET p_nff.nom_destinatario = p_fornecedor.raz_social
      LET p_nff.num_cgc_cpf      = p_fornecedor.num_cgc_cpf
      LET p_nff.end_destinatario = p_fornecedor.end_fornec
      LET p_nff.den_bairro       = p_fornecedor.den_bairro
      LET p_nff.cod_cep          = p_fornecedor.cod_cep
      LET p_nff.num_telefone     = p_fornecedor.num_telefone
      LET p_nff.ins_estadual     = p_fornecedor.ins_estadual
  
      CALL pol0832_busca_dados_cidades(p_fornecedor.cod_cidade)
      LET p_nff.den_cidade       = p_cidades.den_cidade[1,21]
      LET p_nff.cod_uni_feder    = p_cidades.cod_uni_feder
      LET p_nff.hora_impres       = EXTEND(CURRENT, HOUR TO MINUTE)

      # soma nos itens

      LET p_nff.val_tot_base_icm   = 0
      LET p_nff.val_tot_mercadoria = 0
      LET p_nff.pes_tot_bruto      = 0
      LET p_nff.pes_tot_liquido    = 0

      CALL pol0832_carrega_corpo_nff()  {le os itens pertencentes a nf}

      CALL pol0832_carrega_tabela_temporaria() {sera o corpo todo da nota}

      CALL pol0832_calcula_total_de_paginas()

# imprime base de calculo
      IF p_nf_sup.val_bc_subst_d > 0 THEN
         LET p_nff.val_tot_base_ret   = p_nf_sup.val_bc_subst_d
      ELSE
         LET p_nff.val_tot_base_ret   = p_nf_sup.val_bc_subst_c
      END IF

      IF p_nf_sup.val_icms_subst_d > 0 THEN
         LET p_nff.val_tot_icm_ret    = p_nf_sup.val_icms_subst_d
      ELSE
         LET p_nff.val_tot_icm_ret    = p_nf_sup.val_icms_subst_c
      END IF

      IF p_nf_sup.val_tot_icms_nf_d > 0 THEN
         LET p_nff.val_tot_icm = p_nf_sup.val_tot_icms_nf_d
      ELSE
         LET p_nff.val_tot_icm = p_nf_sup.val_tot_icms_nf_c
      END IF

      IF p_nf_sup.val_ipi_nf > 0 THEN
         LET p_nff.val_tot_ipi = p_nf_sup.val_ipi_nf
      ELSE
         LET p_nff.val_tot_ipi = p_nf_sup.val_ipi_calc
      END IF

      IF p_nf_sup.val_tot_nf_d > 0 THEN
         LET p_nff.val_tot_nff = p_nf_sup.val_tot_nf_d
      ELSE
         LET p_nff.val_tot_nff = p_nf_sup.val_tot_nf_c
      END IF

      LET p_nff.ies_frete           = 1
      LET p_nff.num_cgc_trans[1,3]  = p_transport.num_cgc[1,3]
      LET p_nff.num_cgc_trans[4,6]  = p_transport.num_cgc[5,7]
      LET p_nff.num_cgc_trans[7,9]  = p_transport.num_cgc[9,11]
      LET p_nff.num_cgc_trans[10,13] = p_transport.num_cgc[13,16]
      LET p_nff.num_cgc_trans[14,15] = p_transport.num_cgc[18,19]
      LET p_nff.end_transpor        = p_transport.end_transpor
      LET p_nff.den_cidade_trans    = p_cidades.den_cidade
      LET p_nff.cod_uni_feder_trans = p_cidades.cod_uni_feder
      LET p_nff.ins_estadual_trans  = p_transport.ins_estadual
      LET p_nff.qtd_volume          = p_nfe_sup_compl.qtd_volumes
      LET p_nff.den_marca           = "         "
      LET p_nff.pes_tot_bruto       = p_nfe_sup_compl.peso_bruto
      LET p_nff.pes_tot_liquido     = p_nfe_sup_compl.peso_liquido

      LET p_ies_lista  = TRUE
      CALL pol0832_monta_relat()
      CALL pol0832_inicializa_campos()
   END FOREACH

END FUNCTION

#--------------------------------#
 FUNCTION sup997_cria_t_pol0832()
#--------------------------------#

   WHENEVER ERROR CONTINUE

    DROP TABLE t_pol0832 
    IF sqlca.sqlcode <> 0 THEN
       DELETE FROM t_pol0832
    END IF
 
    CREATE TEMP TABLE t_pol0832
    (num_aviso_rec    DECIMAL(6,0));

   WHENEVER ERROR STOP

 END FUNCTION

#----------------------------------------#
 FUNCTION pol0832_cria_tabela_temporaria()
#----------------------------------------#
   WHENEVER ERROR CONTINUE

   DROP TABLE dados_nota;

   IF sqlca.sqlcode <> 0 THEN
      DELETE FROM dados_nota;
   END IF

   CREATE TEMP TABLE dados_nota
   (num_seq            SMALLINT,
    ies_tip_info       SMALLINT,
    cod_item           CHAR(16),
    den_item           CHAR(30),
    cod_cla_fisc       CHAR(10),
    cod_origem         DECIMAL(1,0),
    cod_tributacao     DECIMAL(2,0),
    cod_unid_med       CHAR(3),
    qtd_item           DECIMAL(12,3),
    peso_liq           DECIMAL(10,5),
    pre_unit           DECIMAL(17,6),
    val_liq_item       DECIMAL(15,2),
    pct_icm            DECIMAL(5,2),
    pct_ipi            DECIMAL(6,3),
    val_ipi            DECIMAL(12,2),
    des_texto          CHAR(120),
    num_nff            DECIMAL(6,0)
   ) WITH NO LOG;

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("CRIACAO","TABELA-TEMPORARIA")
   END IF
   
   DROP TABLE clas_fisc_temp;
   CREATE TEMP TABLE clas_fisc_temp
     (
      cod_cla_fisc       CHAR(010),
      num_item           DECIMAL(1,0)
     ) ;

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-clas_fisc_temp")
   END IF
   
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------------------------#
 FUNCTION pol0832_busca_dados_fornec(p_cod_fornecedor)
#-----------------------------------------------------#
 DEFINE p_cod_fornecedor    LIKE fornecedor.cod_fornecedor

   INITIALIZE p_fornecedor.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT fornecedor.*
     INTO p_fornecedor.*
     FROM fornecedor
    WHERE fornecedor.cod_fornecedor = p_cod_fornecedor
   WHENEVER ERROR STOP
END FUNCTION

#--------------------------------------------------#
 FUNCTION pol0832_busca_dados_cidades(p_cod_cidade)
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

#-----------------------------#
 FUNCTION pol0832_monta_relat()
#-----------------------------#

# cria indice de classificação fiscal

   DEFINE p_indice       DECIMAL(2,0),
          p_cod_cla_fisc CHAR(10),
          l_des_texto    CHAR(120)
          
   LET p_cont_dados = 0
   SELECT COUNT(*) 
     INTO p_cont_dados
     FROM dados_nota
    WHERE ies_tip_info < 3
     
   DECLARE cq_dados_notar CURSOR FOR
    SELECT *
      FROM dados_nota  
     WHERE ies_tip_info <= 2
     ORDER BY ies_tip_info

   FOREACH cq_dados_notar INTO p_dados_nota.*
      LET p_dados_nota.num_nff = p_nf_sup.num_nf
      LET p_dados_nota.num_ar  = p_nf_sup.num_aviso_rec
      LET p_dados_nota.ies_tipo = 'R'
      OUTPUT TO REPORT pol0832_relat(p_dados_nota.*) 
   END FOREACH

   LET p_num_pagina = 0
   LET p_linhas_print = 0 
   DECLARE cq_dados_notai CURSOR FOR
    SELECT *
      FROM dados_nota  
     WHERE ies_tip_info <= 2
     ORDER BY ies_tip_info

   FOREACH cq_dados_notai INTO p_dados_nota.*
      LET p_dados_nota.num_nff = p_nf_sup.num_nf
      LET p_dados_nota.num_ar  = p_nf_sup.num_aviso_rec
      LET p_dados_nota.ies_tipo = 'I'
      OUTPUT TO REPORT pol0832_relat(p_dados_nota.*) 
   END FOREACH

   LET p_num_pagina = 0
   LET p_linhas_print = 0 
   DECLARE cq_dados_notac CURSOR FOR
    SELECT *
      FROM dados_nota  
     WHERE ies_tip_info <= 2
     ORDER BY ies_tip_info

   FOREACH cq_dados_notac INTO p_dados_nota.*
      LET p_dados_nota.num_nff = p_nf_sup.num_nf
      LET p_dados_nota.num_ar  = p_nf_sup.num_aviso_rec
      LET p_dados_nota.ies_tipo = 'C'
      OUTPUT TO REPORT pol0832_relat(p_dados_nota.*) 
   END FOREACH

END FUNCTION

#------------------------------------#
 FUNCTION pol0832_carrega_corpo_nff()
#------------------------------------#
 DEFINE p_qtd_item_t     LIKE wfat_item_ent.qtd_item,
        p_ies_bonif      CHAR(01)

 DEFINE p_qtd_padr_embal LIKE item_embalagem.qtd_padr_embal,
        p_vol_padr_embal LIKE item_embalagem.vol_padr_embal

 DEFINE p_item           LIKE item.pes_unit
 
 DEFINE p_ind            SMALLINT

   LET p_ind = 1

   DECLARE cq_wfat_item_ent CURSOR FOR
    SELECT *
      FROM aviso_rec
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_nf_sup.num_aviso_rec
     ORDER BY num_seq

   FOREACH cq_wfat_item_ent INTO p_aviso_rec.*
       
      LET pa_corpo_nff[p_ind].cod_item       = p_aviso_rec.cod_item
      LET pa_corpo_nff[p_ind].den_item1      = p_aviso_rec.den_item[1,30]

      LET pa_corpo_nff[p_ind].cod_unid_med   = p_aviso_rec.cod_unid_med_nf
      LET pa_corpo_nff[p_ind].qtd_item       = p_aviso_rec.qtd_declarad_nf

      IF p_ind = 999 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1
   END FOREACH
   
   SELECT nom_comprador
     INTO p_nom_comprador
     FROM comprador
    WHERE cod_comprador =  p_aviso_rec.cod_comprador
      AND cod_empresa   =  p_cod_empresa 

   SELECT MAX(cod_progr)
     INTO p_cod_progr
     FROM ordem_sup
    WHERE cod_empresa =  p_cod_empresa
      AND num_oc      =  p_aviso_rec.num_oc

   SELECT nom_progr
     INTO p_nff.nom_progr
     FROM programador
    WHERE cod_progr   =  p_cod_progr
      AND cod_empresa =  p_cod_empresa 
    
   SELECT MAX(cod_secao_receb) 
     INTO p_cod_secao_receb
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_nf_sup.num_aviso_rec

   IF p_cod_secao_receb IS NULL THEN 
      LET p_nff.nom_receb = 'MATERIAL ESTOQUE'
   ELSE    
      SELECT MAX(den_uni_funcio)
        INTO p_nff.nom_receb
        FROM unidade_funcional
       WHERE cod_empresa    = p_cod_empresa
         AND cod_uni_funcio = p_cod_secao_receb    
   END IF 
     
   LET p_num_pedido =  p_aviso_rec.num_pedido
   LET p_num_oc     =  p_aviso_rec.num_oc
END FUNCTION
  
#--------------------------------------------#
 FUNCTION pol0832_carrega_tabela_temporaria()
#--------------------------------------------#
 DEFINE i, j         SMALLINT
#DEFINE p_num_seq    SMALLINT

   LET i = 1
   LET j = 0
   LET p_num_seq = 0

   FOR i = 1 TO 999   {insere as linhas de corpo da nota na TEMP}
      IF pa_corpo_nff[i].cod_item     IS NULL AND
         pa_corpo_nff[i].cod_cla_fisc IS NULL AND
         pa_corpo_nff[i].pct_ipi      IS NULL AND 
         pa_corpo_nff[i].qtd_item     IS NULL AND
         pa_corpo_nff[i].pre_unit     IS NULL THEN
         CONTINUE FOR
      END IF

      LET p_num_seq = p_num_seq + 1

      INSERT INTO dados_nota VALUES (p_num_seq,1,
                                     pa_corpo_nff[i].cod_item,
                                     pa_corpo_nff[i].den_item1,
                                     pa_corpo_nff[i].cod_cla_fisc,
                                     pa_corpo_nff[i].cod_origem,
                                     pa_corpo_nff[i].cod_tributacao,
                                     pa_corpo_nff[i].cod_unid_med,
                                     pa_corpo_nff[i].qtd_item,
                                     pa_corpo_nff[i].peso_liq,
                                     pa_corpo_nff[i].pre_unit,  
                                     pa_corpo_nff[i].val_liq_item,
                                     pa_corpo_nff[i].pct_icm,
                                     pa_corpo_nff[i].pct_ipi,
                                     pa_corpo_nff[i].val_ipi,NULL,NULL)

   END FOR
END FUNCTION

#-------------------------------------------#
 FUNCTION pol0832_calcula_total_de_paginas()
#-------------------------------------------#

   SELECT COUNT(*)
      INTO p_num_linhas
   FROM dados_nota
   WHERE ies_tip_info < 3

   { p_qtd_linhas_dispon = numero de linhas do corpo da nota fiscal }

   IF p_num_linhas IS NOT NULL AND
      p_num_linhas > 0 THEN
      LET p_tot_paginas = (p_num_linhas - (p_num_linhas MOD 
                           p_qtd_linhas_dispon)) / p_qtd_linhas_dispon

      IF (p_num_linhas MOD p_qtd_linhas_dispon) > 0 THEN
         LET p_tot_paginas = p_tot_paginas + 1
      ELSE
         LET p_ies_termina_relat = FALSE
      END IF
   ELSE 
      LET p_tot_paginas = 1
   END IF

END FUNCTION

#------------------------------------------------------#
 FUNCTION pol0832_busca_dados_transport(p_cod_transpor)
#------------------------------------------------------#
 DEFINE p_cod_transpor LIKE clientes.cod_cliente

   INITIALIZE p_transport.* TO NULL

   WHENEVER ERROR CONTINUE
   SELECT *
     INTO p_transport.*
     FROM transport
    WHERE transport.cod_transpor = p_cod_transpor

    IF sqlca.sqlcode <> 0 THEN
       SELECT nom_cliente, end_cliente,  num_cgc_cpf, cod_cidade, ins_estadual
        INTO p_transport.den_transpor, p_transport.end_transpor,
             p_transport.num_cgc, p_transport.cod_cidade, 
             p_transport.ins_estadual
        FROM clientes                 
        WHERE cod_cliente = p_cod_transpor

       IF sqlca.sqlcode <> 0 THEN
          SELECT raz_social, end_fornec, ins_estadual, cod_cidade, num_cgc_cpf
           INTO p_transport.den_transpor, p_transport.end_transpor,
                p_transport.ins_estadual, p_transport.cod_cidade, 
                p_transport.num_cgc
            FROM fornecedor
            WHERE cod_fornecedor = p_cod_transpor
       END IF 
    END IF
   WHENEVER ERROR STOP
END FUNCTION

#-----------------------------------#
 REPORT pol0832_relat(p_dados_nota)
#-----------------------------------#

 DEFINE p_dados_nota    RECORD
        num_seq         SMALLINT,
        ies_tip_info    SMALLINT,
        cod_item        LIKE wfat_item_ent.cod_item,
        den_item        CHAR(30),
        cod_cla_fisc    CHAR(10),
        cod_origem      LIKE wfat_mestre_ent.cod_origem,
        cod_tributacao  LIKE tributacao.cod_tributacao,
        cod_unid_med    LIKE wfat_item_ent.cod_unid_med,
        qtd_item        LIKE wfat_item_ent.qtd_item,
        peso_liq        DECIMAL(10,5),
        pre_unit        LIKE wfat_item_ent.pre_unit_nf,
        val_liq_item    LIKE wfat_item_ent.val_liq_item,
        pct_icm         LIKE wfat_mestre_ent.pct_icm,
        pct_ipi         LIKE wfat_item_ent.pct_ipi,
        val_ipi         LIKE wfat_item_ent.val_ipi,
        des_texto       CHAR(120),
        num_nff         LIKE wfat_mestre_ent.num_nff,
        num_ar          LIKE nf_sup.num_aviso_rec,
        ies_tipo        CHAR(01)
        END RECORD

 DEFINE p_des_folha     CHAR(100)
 
 DEFINE p_clas_fisc     RECORD
        denominacao     CHAR(10),
        percentual      CHAR(02)
        END RECORD 	

 DEFINE p_textos       RECORD
        texto1         CHAR(120),
        texto2         CHAR(120),
        texto3         CHAR(120),
        texto4         CHAR(120),
        texto5         CHAR(120),
        texto6         CHAR(120),
        texto7         CHAR(120),
        texto8         CHAR(120),
        texto9         CHAR(120),
        texto10        CHAR(120),
        texto11        CHAR(120),
        texto12        CHAR(120)
        END RECORD
 
 DEFINE p_cod_cla_h    CHAR(10),
        p_cod_cla_i    CHAR(10),
        p_cod_ref_clas CHAR(01) 

 DEFINE i, j    SMALLINT

 OUTPUT LEFT   MARGIN   1 
        TOP    MARGIN   0
        BOTTOM MARGIN   0
        PAGE   LENGTH   60

 ORDER EXTERNAL BY p_dados_nota.ies_tipo, p_dados_nota.num_nff

 FORMAT

   PAGE HEADER
      LET p_num_pagina = p_num_pagina + 1
      PRINT COLUMN 001, p_8lpp
#      PRINT log500_determina_cpp(122) CLIPPED;
#      PRINT log500_condensado(true) CLIPPED;
      PRINT COLUMN 030, 'AVISO DE RECEBIMENTO',
            COLUMN 060, 'AR : ', p_dados_nota.num_ar
      PRINT 
      IF p_dados_nota.ies_tipo = 'R' THEN 
         PRINT COLUMN 031, 'VIA :  RECEBIMENTO'
      ELSE
         IF p_dados_nota.ies_tipo = 'C' THEN 
            PRINT COLUMN 031, 'VIA :     CONTAGEM'
         ELSE
            PRINT COLUMN 031, 'VIA :     INSPECAO'
         END IF 
      END IF 
      PRINT COLUMN 001,'_______________________________________________________________________________' 
      PRINT COLUMN 001, 'Empresa:     ', p_cod_empresa,' - ', p_den_reduz,
            COLUMN 060, 'Emissao: ', p_nf_sup.dat_emis_nf
      PRINT COLUMN 001, 'Comprador:   ', p_nom_comprador,
            COLUMN 060, 'Entrada: ', p_nf_sup.dat_entrada_nf
      PRINT
      PRINT COLUMN 001, 'Recebedor:   ', p_nff.nom_receb,
            COLUMN 060, 'Hora     :   ', p_nff.hora_impres
      PRINT
      PRINT COLUMN 001, 'Solicitante: ', p_nff.nom_progr
      PRINT
      PRINT COLUMN 001, 'Fornecedor:  ',p_nff.nom_destinatario
      PRINT
      PRINT COLUMN 001, 'Nota Fiscal: ',p_dados_nota.num_nff,
            COLUMN 030, 'Pedido: ',p_num_pedido,
            COLUMN 060, 'Ordem: ',p_num_oc
      PRINT 
      PRINT COLUMN 001, '_______________________________________________________________________________' 
      PRINT COLUMN 001, 'Item ',
            COLUMN 012, 'Material',
            COLUMN 044, '  Quantidade',
            COLUMN 058, 'UM',
            COLUMN 061, 'Efetuada por'  
      PRINT COLUMN 001, '_______________________________________________________________________________' 
  
   BEFORE GROUP OF p_dados_nota.ies_tipo 
      SKIP TO TOP OF PAGE 

   ON EVERY ROW

      CASE
         WHEN p_dados_nota.ies_tip_info = 1
            PRINT COLUMN 001, p_dados_nota.cod_item[1,10],
                  COLUMN 012, p_dados_nota.den_item;
                  IF p_dados_nota.ies_tipo = 'C' THEN
                     PRINT COLUMN 044,  "____________";
                  ELSE 
                     PRINT COLUMN 044, p_dados_nota.qtd_item      USING "####,##&.&&&";
                  END IF 
            PRINT COLUMN 058, p_dados_nota.cod_unid_med,
                  COLUMN 061, '___________________'
            LET p_linhas_print = p_linhas_print + 1

      END CASE

      IF p_num_pagina = p_tot_paginas THEN { numero de linhas corpo da nota }
         IF (p_cont_dados MOD p_qtd_linhas_dispon) > 0 THEN
            IF p_num_pagina > 1 AND
               p_cont_dados = (((p_num_pagina - 1) * p_qtd_linhas_dispon) +
                              p_linhas_print) THEN
               FOR p_contador = 1 TO (p_qtd_linhas_dispon - p_linhas_print)
                  PRINT " "
               END FOR
            ELSE
               IF p_cont_dados = p_linhas_print THEN
                  FOR p_contador = 1 TO (p_qtd_linhas_dispon-p_linhas_print)
                     PRINT " "
                  END FOR
               END IF
            END IF
         END IF

         IF p_num_pagina > 1 AND
            p_cont_dados = (((p_num_pagina - 1) * p_qtd_linhas_dispon) +
                           p_linhas_print) OR
           (p_num_pagina = 1 AND
            p_cont_dados = p_linhas_print) THEN
            SKIP 2 LINES
            PRINT COLUMN 001, '_______________________________________________________________________________' 
            PRINT COLUMN 001, 'OBS . '
            SKIP 5 LINES
            PRINT COLUMN 001, '_______________________________________________________________________________' 
            IF p_dados_nota.ies_tipo = 'C' THEN
               LET p_num_pagina = 0
            END IF    
         END IF
      ELSE
         IF p_qtd_linhas_dispon = p_linhas_print THEN
            SKIP 2 LINES
            PRINT COLUMN 001, '_______________________________________________________________________________' 
            PRINT COLUMN 001, 'OBS . '
            SKIP 5 LINES
            PRINT COLUMN 001, '_______________________________________________________________________________' 
            LET p_linhas_print = 0
         END IF
      END IF
END REPORT

#-----------------------#
 FUNCTION pol0832_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION