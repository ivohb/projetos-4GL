#-------------------------------------------------------------------#
# SISTEMA.: EMBALAGEM                                               #
# PROGRAMA: pol0419                                                 #
# OBJETIVO: FATURAMENTO/EMBALAGENS                                  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 26/01/2006                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa LIKE empresa.cod_empresa,
          p_den_empresa LIKE empresa.den_empresa,  
          p_user        LIKE usuario.nom_usuario,
          p_den_embal   LIKE embalagem.den_embal,
          p_den_item    LIKE item.den_item,
          p_cod_transpor CHAR(15),
          p_pes_tot     DECIMAL(10,3),
          p_qtd_embal   DEC(12,3),
          p_status      SMALLINT,
          p_des_texto   CHAR(75),
          p_cod_texto   CHAR(10),
          p_houve_erro  SMALLINT,
          comando       CHAR(80),
          p_versao      CHAR(18),
          p_nom_tela    CHAR(080),
          p_nom_help    CHAR(200),
          p_ies_cons    SMALLINT,
          p_last_row    SMALLINT,
          p_count       SMALLINT,
          pa_curr       SMALLINT,  
          sc_curr       SMALLINT,
          p_msg         CHAR (500),
          p_num_om      INTEGER,
          p_num_nf      INTEGER,
          p_especie     CHAR(03),
          p_modelo      CHAR(05)
END GLOBALS

   DEFINE w_i            SMALLINT,
          p_ind          SMALLINT,
          p_cod_unid_med LIKE item.cod_unid_med,  
          p_pes_unit     LIKE item.pes_unit,       
          p_cod_cla_fisc LIKE item.cod_cla_fisc,  
          p_pct_ipi      LIKE item.pct_ipi,         
          p_val_liq_item DECIMAL(12,2),
          p_val_ipi      DECIMAL(12,2),
          p_val_tot_liq  DECIMAL(12,2),
          p_val_tot_ipi  DECIMAL(12,2),
          p_val_tot_nff  DECIMAL(12,2),
          p_val_merc     DECIMAL(12,2),
          p_val_tot_icm  DECIMAL(12,2),
          p_saldo        DECIMAL(10,3),
          p_resto        DECIMAL(10,3),
          p_cod_embal    CHAR(03),
          p_qtd_volume   INTEGER,
          p_val_icm_it   DECIMAL(12,2),
          p_nom_cliente  CHAR(36),
          p_trans_nf     INTEGER,
          p_num_seq      INTEGER,
          p_cod_item     CHAR(15),
          p_pre_unit_nf  DECIMAL(12,2),
          p_val_base_trib DECIMAL(17,2),
          p_val_tribruto  DECIMAL(17,2),
          p_aliquota      DECIMAL(5,2),
          p_tip_item      CHAR(01),
          p_tributo_benef CHAR(30),
          p_ies_tributo   SMALLINT,
          p_cod_nat_oper  INTEGER,
          p_cod_cnd_pgto  CHAR(05)

   DEFINE p_fat_mestre         RECORD LIKE fat_nf_mestre.*,
          p_fat_item           RECORD LIKE fat_nf_item.*,
          p_txt_hist           RECORD LIKE fat_nf_texto_hist.*,
          p_mest_fisc          RECORD LIKE fat_mestre_fiscal.*,
          p_nf_duplicata       RECORD LIKE fat_nf_duplicata.*,
          p_obf_config_fiscal  RECORD LIKE obf_config_fiscal.*,
		  p_cod_fiscal         LIKE obf_config_fiscal.cod_fiscal,
		  p_regiao_fiscal      CHAR(10),
		  p_cod_cidade         LIKE clientes.cod_cidade,
		  p_cod_uni_feder      CHAR(02)

          

   DEFINE t_fat_emb  ARRAY[100] OF RECORD 
      cod_embal      LIKE embal_plast_regina.cod_embal,
      cod_item       LIKE embal_plast_regina.cod_item, 
      den_item       LIKE item.den_item, 
      qtd_embal      LIKE embal_plast_regina.qtd_embal, 
      pre_unit_nf    LIKE embal_plast_regina.pre_unit
   END RECORD 

   DEFINE t_fat_ret ARRAY[100] OF RECORD 
          num_nf            LIKE item_de_terc.num_nf,
          ser_nf            LIKE item_de_terc.ser_nf, 
          ssr_nf            LIKE item_de_terc.ssr_nf,
          esp_nf            LIKE item_de_terc.ies_especie_nf,
          num_seq           LIKE item_de_terc.num_sequencia,
          dat_emis          LIKE item_de_terc.dat_emis_nf, 
          qtd_dev           LIKE item_de_terc.qtd_tot_devolvida,
          cod_item          LIKE embal_plast_regina.cod_item
   END RECORD 

   DEFINE p_embal RECORD 
      cod_item    LIKE embal_plast_regina.cod_item,
      qtd_embal   LIKE embal_plast_regina.qtd_embal,
      pre_unit    LIKE embal_plast_regina.pre_unit
   END RECORD 

   DEFINE p_item_de_terc RECORD 
      num_nf            LIKE item_de_terc.num_nf,
      ser_nf            LIKE item_de_terc.ser_nf,
      ssr_nf            LIKE item_de_terc.ssr_nf,
      ies_especie_nf    LIKE item_de_terc.ies_especie_nf, 
      num_sequencia     LIKE item_de_terc.num_sequencia,
      dat_emis_nf       LIKE item_de_terc.dat_emis_nf,
      qtd_tot_recebida  LIKE item_de_terc.qtd_tot_recebida,
      qtd_tot_devolvida LIKE item_de_terc.qtd_tot_devolvida
   END RECORD 

DEFINE p_wfat RECORD 
      trans_nota_fiscal1 INTEGER,
      num_nff1           INTEGER, 
      trans_nota_fiscal2 INTEGER,
      num_nff2           INTEGER, 
      trans_nota_fiscal3 INTEGER,
      num_nff3           INTEGER, 
      trans_nota_fiscal4 INTEGER,
      num_nff4           INTEGER,
      trans_nota_fiscal5 INTEGER,
      num_nff5           INTEGER,
      trans_nota_fiscal6 INTEGER,
      num_nff6           INTEGER,
      cod_cliente1       CHAR(15),
      cod_cliente2       CHAR(15),
      cod_cliente3       CHAR(15),
      cod_cliente4       CHAR(15),
      cod_cliente5       CHAR(15),
      cod_cliente6       CHAR(15),
      ies_tip_controle   CHAR(01),
      num_solicit        INTEGER,
      cod_cliente        CHAR(15),
      nom_cliente        CHAR(36),
      cod_nat_oper       INTEGER,
      den_nat_oper       CHAR(30),
      cod_cnd_pgto       CHAR(05),
      den_cnd_pgto       CHAR(30),
      cod_texto          DECIMAL(3,0),
      des_texto          CHAR(120), 
      tex_obs            CHAR(30),
      ser_nf             CHAR(03),
      ssr_nf             INTEGER
END RECORD 
   
DEFINE p_fat_item_fisc  RECORD
    empresa            char(2),
    trans_nota_fiscal  INTEGER,
    seq_item_nf        INTEGER,
    tributo_benef      char(20),
    trans_config       INTEGER,
    bc_trib_mercadoria decimal(17,2),
    bc_tributo_frete   decimal(17,2),
    bc_trib_calculado  decimal(17,2),
    bc_tributo_tot     decimal(17,2),
    val_trib_merc      decimal(17,2),
    val_tributo_frete  decimal(17,2),
    val_trib_calculado decimal(17,2),
    val_tributo_tot    decimal(17,2),
    acresc_desc        char(1),
    aplicacao_val      char(1), 
    incide             char(1),
    origem_produto     smallint, 
    tributacao         smallint, 
    hist_fiscal        integer, 
    sit_tributo        char(1), 
    motivo_retencao    char(1), 
    retencao_cre_vdp   char(3), 
    cod_fiscal         integer, 
    inscricao_estadual char(16), 
    dipam_b            char(3), 
    aliquota           decimal(7,4), 
    val_unit           decimal(17,6), 
    pre_uni_mercadoria decimal(17,6), 
    pct_aplicacao_base decimal(7,4), 
    pct_acre_bas_calc  decimal(7,4), 
    pct_red_bas_calc   decimal(7,4), 
    pct_diferido_base  decimal(7,4), 
    pct_diferido_val   decimal(7,4), 
    pct_acresc_val     decimal(7,4), 
    pct_reducao_val    decimal(7,4), 
    pct_margem_lucro   decimal(7,4), 
    pct_acre_marg_lucr decimal(7,4), 
    pct_red_marg_lucro decimal(7,4), 
    taxa_reducao_pct   decimal(7,4), 
    taxa_acresc_pct    decimal(7,4), 
    cotacao_moeda_upf  decimal(7,2), 
    simples_nacional   decimal(5,0),
    iden_processo      integer
 END RECORD
   DEFINE p_obf_controle_chave RECORD 
			empresa 			char(2),
			tributo_benef 		char(20),
			natureza_operacao 	char(1),
			ctr_nat_operacao 	integer,
			grp_fiscal_regiao 	char(1),
    		ctr_grp_fisc_regi 	integer,
    		estado 				char(1),
    		controle_estado 	integer,
   			municipio 			char(1),
			controle_municipio  integer,
			carteira 			char(1),
			controle_carteira 	integer,
			finalidade 			char(1),
			ctr_finalidade 		integer,
			familia_item 		char(1),
			ctr_familia_item 	integer,
			grp_fiscal_classif 	char(1),
			ctr_grp_fisc_clas 	integer,
			classif_fisc 		char(1),
			ctr_classif_fisc 	integer,
			linha_produto 		char(1),
			ctr_linha_produto 	integer,
			linha_receita 		char(1),
			ctr_linha_receita 	integer,
			segmto_mercado 		char(1),
			ctr_segmto_mercado 	integer,
			classe_uso 			char(1),
			ctr_classe_uso 		integer,
			unid_medida 		char(1),
			ctr_unid_medida 	integer,
			produto_bonific 	char(1),
			ctr_prod_bonific 	integer,
			grupo_fiscal_item 	char(1),
			ctr_grp_fisc_item 	integer,
			item 				char(1),
			controle_item 		integer,
			micro_empresa 		char(1),
			ctr_micro_empresa 	integer,
			grp_fiscal_cliente 	char(1),
			ctr_grp_fisc_cli 	integer,
			cliente 			char(1),
			controle_cliente 	integer,
			via_transporte 		char(1),
			ctr_via_transporte 	integer,
			tem_valid_config 	char(1),
			ctrl_valid_config 	integer 
	END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL0419-10.02.11"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0419.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0419_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0419_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0419") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0419 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Faturamento"
         IF pol0419_informar() THEN
            LET p_ies_cons = TRUE
            ERROR 'Operação efetuada com sucesso!'
            NEXT OPTION "Processar"
         ELSE
            LET p_ies_cons = FALSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Processar" "Processa o Faturamento da Embalagem"
         IF p_ies_cons THEN 
            IF pol0419_processa() THEN
               ERROR "Processamento Efetuado com Sucesso !!!" 
            ELSE
               ERROR "Processamento Cancelado !!!"
            END IF
            LET p_ies_cons = FALSE
         ELSE
            ERROR "Informe os parâmetros previamente !!!"
            NEXT OPTION "Informar"
         END IF
	  COMMAND KEY ("T") "faTurar"  "Fatura as solicitações de  faturas"
			HELP 0001
			CALL log120_procura_caminho("VDP0747") RETURNING comando
		  LET comando = comando CLIPPED
		  RUN comando RETURNING p_status
		  CURRENT WINDOW IS w_pol0419
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0419_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0419

END FUNCTION

#-----------------------#
 FUNCTION pol0419_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Conversão para 10.02.00\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
 FUNCTION pol0419_informar()
#---------------------------#
 
   LET p_houve_erro = FALSE

   IF NOT pol0419_entrada_dados() THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF 	

   IF NOT pol0419_cria_tabela_temporaria() THEN
      RETURN FALSE
   END IF

   IF NOT pol0419_ins_wtransac() THEN
      RETURN FALSE
   END IF

   IF NOT pol0419_le_embalagens() THEN
      RETURN FALSE
   END IF

   IF NOT pol0419_edita_embal() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0419_verifi_solic(p_nf)#
#----------------------------------#

   DEFINE p_nf  INTEGER,
          p_txt CHAR(10)
   
   LET p_txt = p_nf          
   LET p_msg = NULL
   
   SELECT cliente
     FROM fat_nf_mestre
    WHERE empresa = p_cod_empresa
      AND nota_fiscal = p_nf
      AND tip_nota_fiscal = 'SOLPRDSV'
      
   IF STATUS = 0 THEN
      LET p_msg = 'NF ',p_txt CLIPPED, ' Já comtém solicitação sem faturar.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql('SELECT','fat_nf_mestre:SOLPRDSV')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION   
   
   
#-------------------------------#
 FUNCTION pol0419_entrada_dados()
#-------------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   INITIALIZE p_wfat TO NULL
   LET p_wfat.ser_nf = '01'
   LET p_wfat.ssr_nf = 0
   
   INPUT BY NAME p_wfat.num_nff1,
                 p_wfat.num_nff2,
                 p_wfat.num_nff3,
                 p_wfat.num_nff4,
                 p_wfat.num_nff5,
                 p_wfat.num_nff6,
                 p_wfat.cod_cliente,  
                 p_wfat.cod_nat_oper, 
                 p_wfat.cod_cnd_pgto,
                 p_wfat.cod_texto,
                 p_wfat.tex_obs,
                 p_wfat.ser_nf,
                 p_wfat.ssr_nf
      WITHOUT DEFAULTS  

      AFTER FIELD num_nff1
      
         IF p_wfat.num_nff1 IS NULL THEN
            ERROR "Campo com preenchimento obrigatório!"
            NEXT FIELD num_nff1
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff1) THEN
            NEXT FIELD num_nff1
         END IF
                        
         SELECT cliente,
                transportadora,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente1,
                p_cod_transpor,
                p_wfat.trans_nota_fiscal1
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff1
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:1')
            NEXT FIELD num_nff1     
         END IF
         
         SELECT nom_cliente   
           INTO p_wfat.nom_cliente    
           FROM clientes
          WHERE cod_cliente = p_wfat.cod_cliente1
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','clientes')
            NEXT FIELD num_nff1     
         END IF

         LET p_wfat.cod_cliente = p_wfat.cod_cliente1
         
         DISPLAY p_wfat.cod_cliente1 TO cod_cli_nota
         DISPLAY p_wfat.nom_cliente  TO nom_cli_nota

      BEFORE FIELD num_nff2
         LET p_wfat.trans_nota_fiscal2 = NULL
         
      AFTER FIELD num_nff2
      
         IF p_wfat.num_nff2 IS NULL THEN
            NEXT FIELD cod_cliente  
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff2) THEN
            NEXT FIELD num_nff2
         END IF

         SELECT cliente,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente2,
                p_wfat.trans_nota_fiscal2
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff2
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:2')
            NEXT FIELD num_nff2
         END IF
         
         IF p_wfat.cod_cliente1 <> p_wfat.cod_cliente2 THEN
            ERROR "Cliente Diferente da Nota Anterior"
            NEXT FIELD num_nff2     
         END IF

      BEFORE FIELD num_nff3
         LET p_wfat.trans_nota_fiscal3 = NULL

      AFTER FIELD num_nff3

         IF p_wfat.num_nff3 IS NULL THEN
            NEXT FIELD cod_cliente  
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff3) THEN
            NEXT FIELD num_nff2
         END IF

         SELECT cliente,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente3,
                p_wfat.trans_nota_fiscal3
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff3
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:3')
            NEXT FIELD num_nff3
         END IF
         
         IF p_wfat.cod_cliente1 <> p_wfat.cod_cliente3 THEN
            ERROR "Cliente Diferente da Nota Anterior"
            NEXT FIELD num_nff3
         END IF

      BEFORE FIELD num_nff4
         LET p_wfat.trans_nota_fiscal4 = NULL

      AFTER FIELD num_nff4

         IF p_wfat.num_nff4 IS NULL THEN
            NEXT FIELD cod_cliente  
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff4) THEN
            NEXT FIELD num_nff2
         END IF

         SELECT cliente,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente4,
                p_wfat.trans_nota_fiscal4
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff4
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:4')
            NEXT FIELD num_nff4
         END IF
         
         IF p_wfat.cod_cliente1 <> p_wfat.cod_cliente4 THEN
            ERROR "Cliente Diferente da Nota Anterior"
            NEXT FIELD num_nff4
         END IF

      BEFORE FIELD num_nff5
         LET p_wfat.trans_nota_fiscal5 = NULL

      AFTER FIELD num_nff5

         IF p_wfat.num_nff5 IS NULL THEN
            NEXT FIELD cod_cliente  
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff5) THEN
            NEXT FIELD num_nff2
         END IF

         SELECT cliente,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente5,
                p_wfat.trans_nota_fiscal5
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff5
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:5')
            NEXT FIELD num_nff5
         END IF
         
         IF p_wfat.cod_cliente1 <> p_wfat.cod_cliente5 THEN
            ERROR "Cliente Diferente da Nota Anterior"
            NEXT FIELD num_nff5
         END IF

      BEFORE FIELD num_nff6
         LET p_wfat.trans_nota_fiscal6 = NULL

      AFTER FIELD num_nff6

         IF p_wfat.num_nff6 IS NULL THEN
            NEXT FIELD cod_cliente  
         END IF

         IF NOT pol0419_verifi_solic(p_wfat.num_nff6) THEN
            NEXT FIELD num_nff2
         END IF

         SELECT cliente,
                trans_nota_fiscal 
           INTO p_wfat.cod_cliente6,
                p_wfat.trans_nota_fiscal6
           FROM fat_nf_mestre
          WHERE empresa = p_cod_empresa
            AND nota_fiscal = p_wfat.num_nff6
#            AND usu_incl_nf = p_user

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fat_nf_mestre:6')
            NEXT FIELD num_nff6
         END IF
         
         IF p_wfat.cod_cliente1 <> p_wfat.cod_cliente6 THEN
            ERROR "Cliente Diferente da Nota Anterior"
            NEXT FIELD num_nff6
         END IF

      BEFORE FIELD cod_cliente  
      
         IF p_wfat.cod_cliente IS NULL THEN
            LET p_wfat.cod_cliente = p_wfat.cod_cliente1 
         END IF

      AFTER FIELD cod_cliente  

         IF p_wfat.cod_cliente IS NULL THEN
            ERROR "O Campo Cod Cliente nao pode ser Nulo"
            DISPLAY '' TO nom_cliente
            NEXT FIELD cod_cliente  
         END IF 
      
         SELECT nom_cliente   
           INTO p_wfat.nom_cliente    
           FROM clientes
          WHERE cod_cliente = p_wfat.cod_cliente
         
         IF STATUS <> 0 THEN
            ERROR "Cod Cliente nao Cadastrado"
            NEXT FIELD cod_cliente  
         END IF
         
         DISPLAY BY NAME p_wfat.nom_cliente

      AFTER FIELD cod_nat_oper 

         IF p_wfat.cod_nat_oper IS NULL THEN
            ERROR "O Campo Cod Nat Oper nao pode ser Nulo"
            NEXT FIELD cod_nat_oper 
         END IF
      
         SELECT den_nat_oper,
                ies_tip_controle  
           INTO p_wfat.den_nat_oper,
                p_wfat.ies_tip_controle
           FROM nat_operacao
          WHERE cod_nat_oper = p_wfat.cod_nat_oper
         
         IF STATUS <> 0 THEN
            ERROR "Cod Nat Oper nao Cadastrado"
            NEXT FIELD cod_nat_oper 
         END IF
         
         DISPLAY BY NAME p_wfat.den_nat_oper 

      AFTER FIELD cod_cnd_pgto 

         IF p_wfat.cod_cnd_pgto IS NULL THEN
            ERROR "O Campo Cond Pagto nao pode ser Nulo"
            NEXT FIELD cod_cnd_pgto 
         END IF

         SELECT den_cnd_pgto  
           INTO p_wfat.den_cnd_pgto 
           FROM cond_pgto   
          WHERE cod_cnd_pgto = p_wfat.cod_cnd_pgto
          
         IF STATUS <> 0 THEN
            ERROR "Cond Pagto nao Cadastrada"
            NEXT FIELD cod_cnd_pgto 
         END IF
         
         DISPLAY BY NAME p_wfat.den_cnd_pgto 

      AFTER FIELD cod_texto
      
         IF p_wfat.cod_texto IS NOT NULL THEN
            
            SELECT tex_hist_1     
              INTO p_wfat.des_texto    
              FROM fiscal_hist    
             WHERE cod_hist = p_wfat.cod_texto

            IF STATUS <> 0 THEN
               ERROR "Texto da Nota Fiscal nao Cadastrado"
               NEXT FIELD cod_texto
            END IF
            
            DISPLAY BY NAME p_wfat.des_texto
            
         END IF
      
      AFTER INPUT
         IF NOT INT_FLAG THEN
            SELECT num_ultimo_docum
              INTO p_num_nf
              FROM vdp_num_docum
             WHERE empresa = p_cod_empresa
               AND tip_solicitacao = 'SOLPRDSV'
               AND serie_docum = p_wfat.ser_nf
               AND subserie_docum = p_wfat.ssr_nf
            IF STATUS <> 0 THEN
               LET p_msg = 'Não há parâmetros na tabela vdp_num_docum\n',
                           'para a série e sub-série informadas!' 
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD ser_nf
            END IF
         END IF
            
      ON KEY (control-z)
         CALL pol0419_popup()
         
   END INPUT 
 
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0419_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

       WHEN INFIELD(num_nff1)
            CALL pol0419_le_nff() RETURNING
               p_wfat.trans_nota_fiscal1, p_wfat.num_nff1
            CURRENT WINDOW IS w_pol0419
            DISPLAY p_wfat.num_nff1 TO num_nff1

       WHEN INFIELD(cod_cliente) 
            LET p_wfat.cod_cliente = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0419
            DISPLAY BY NAME p_wfat.cod_cliente

       WHEN INFIELD(cod_nat_oper) 
            CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao",
                              "cod_nat_oper","den_nat_oper",
                              "pol0419","N","") 
            RETURNING p_wfat.cod_nat_oper
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0419
            DISPLAY p_wfat.cod_nat_oper TO cod_nat_oper
         
       WHEN INFIELD(cod_cnd_pgto) 
            CALL log009_popup(6,25,"CND. PAGAMENTO","cond_pgto",
                              "cod_cnd_pgto","den_cnd_pgto",
                              "pol0419","N","") 
            RETURNING p_wfat.cod_cnd_pgto
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0419 
            DISPLAY p_wfat.cod_cnd_pgto TO cod_cnd_pgto

       WHEN INFIELD(cod_texto) 
            CALL log009_popup(6,25,"TEXTO DA N.F.","fiscal_hist",
                              "cod_hist","tex_hist_1",
                              "","N","") 
            RETURNING p_wfat.cod_texto 
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0419
            DISPLAY p_wfat.cod_texto TO cod_texto

   END CASE

END FUNCTION
   
#------------------------#
FUNCTION pol0419_le_nff()#
#------------------------#

   DEFINE pr_mpop  ARRAY[5000] OF RECORD
          nota_fiscal        INTEGER,
          serie_nota_fiscal  CHAR(02),
          subserie_nf        INTEGER,
          cliente            CHAR(15),
          nom_cliente        CHAR(30),
          trans_nota_fiscal  INTEGER
   END RECORD
   
   DEFINE m_ind, s_ind INTEGER
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0419a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol0419a AT 3,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   LET m_ind = 1
    
   DECLARE cq_mpop CURSOR FOR
    SELECT nota_fiscal,      
           serie_nota_fiscal,
           subserie_nf,      
           cliente,          
           nom_cliente,      
           trans_nota_fiscal
      FROM fat_nf_mestre
     WHERE empresa = p_cod_empresa
       AND status_nota_fiscal <> 'C'
     ORDER BY cliente, nota_fiscal

   FOREACH cq_mpop INTO pr_mpop[m_ind].*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre:cq_mpop')
         EXIT FOREACH
      END IF
      
      LET m_ind = m_ind + 1
      
      IF m_ind > 5000 THEN
         LET p_msg = 'Limite de grade ultrapassado !!!'
         CALL log0030_mensagem(p_msg,'exclamation')
         EXIT FOREACH
      END IF
           
   END FOREACH
      
   CALL SET_COUNT(m_ind - 1)
   
   DISPLAY ARRAY pr_mpop TO sr_mpop.*

      LET m_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol0419a
   
   IF NOT INT_FLAG THEN
      RETURN pr_mpop[m_ind].trans_nota_fiscal,
             pr_mpop[m_ind].nota_fiscal
   ELSE
      RETURN "", ""
   END IF
   
END FUNCTION

#---------------------------------------#
FUNCTION pol0419_cria_tabela_temporaria()
#---------------------------------------#

   DROP TABLE wtransac
   CREATE TABLE wtransac(
      trans_nota_fiscal INTEGER
   );
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","wtransac")
      RETURN FALSE
   END IF

   DROP TABLE tributo_tmp
   CREATE TABLE tributo_tmp(
      tributo_benef CHAR(20)
   );
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","tributo_tmp")
      RETURN FALSE
   END IF

   DROP TABLE wnota
   CREATE TABLE wnota(
      cod_embal  CHAR(03), 
      qtd_volume DECIMAL(5,0)
   );
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","wnota")
      RETURN FALSE
   END IF

   DROP TABLE nf_embal_tmp
   CREATE TABLE nf_embal_tmp(
      cod_embal      LIKE embal_plast_regina.cod_embal,
      cod_item       LIKE embal_plast_regina.cod_item, 
      den_item       LIKE item.den_item, 
      qtd_embal      LIKE embal_plast_regina.qtd_embal, 
      pre_unit_nf    LIKE embal_plast_regina.pre_unit
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","nf_embal_tmp")
      RETURN FALSE
   END IF

   RETURN TRUE
 
END FUNCTION

#------------------------------#
FUNCTION pol0419_ins_wtransac()
#------------------------------#

   IF p_wfat.trans_nota_fiscal1 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal1)
   END IF

   IF p_wfat.trans_nota_fiscal2 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal2)
   END IF

   IF p_wfat.trans_nota_fiscal3 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal3)
   END IF

   IF p_wfat.trans_nota_fiscal4 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal4)
   END IF

   IF p_wfat.trans_nota_fiscal5 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal5)
   END IF

   IF p_wfat.trans_nota_fiscal6 IS NOT NULL THEN
      INSERT INTO wtransac VALUES(p_wfat.trans_nota_fiscal6)
   END IF
   
   SELECT COUNT(*)
     INTO p_count
     FROM wtransac

   IF p_count = 0 THEN
      LET p_msg = 'Não há notas de saída a serem processadas!'
      CALL log0030_mensagem(p_msg, 'excla')
      RETURN FALSE
   END IF     
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0419_le_embalagens()#
#-------------------------------#

   DECLARE cu_fat_emb CURSOR FOR
   SELECT DISTINCT
          ord_montag
     FROM fat_nf_item      
    WHERE empresa = p_cod_empresa 
      AND ord_montag > 0
      AND trans_nota_fiscal IN (SELECT trans_nota_fiscal FROM wtransac)
  
   FOREACH cu_fat_emb INTO p_num_om

      DECLARE cu_om_emb CURSOR FOR
      SELECT cod_embal_int,
             qtd_embal_int 
        FROM ordem_montag_embal      
       WHERE cod_empresa = p_cod_empresa 
         AND num_om = p_num_om

      FOREACH cu_om_emb INTO p_cod_embal, p_qtd_volume

         INSERT INTO wnota 
            VALUES (p_cod_embal, p_qtd_volume) 
         
         IF STATUS <> 0 THEN 
            LET p_houve_erro = TRUE
            CALL log003_err_sql("INCLUSAO","wnota")
            EXIT FOREACH
         END IF
     
      END FOREACH

      IF p_houve_erro THEN 
         EXIT FOREACH
      END IF

   END FOREACH         

   IF p_houve_erro THEN 
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0419_edita_embal()#
#-----------------------------#   
 
   DECLARE cu_fat_emb1 CURSOR FOR
    SELECT cod_embal,
           SUM(qtd_volume)
      FROM wnota            
    GROUP BY cod_embal
    ORDER BY cod_embal
 
   LET p_count = 1
   
   FOREACH cu_fat_emb1 INTO 
      p_cod_embal, p_qtd_volume

      DECLARE cq_embal CURSOR FOR
       SELECT cod_item, qtd_embal, pre_unit
         FROM embal_plast_regina
        WHERE cod_empresa = p_cod_empresa
          AND cod_embal   = p_cod_embal

      FOREACH cq_embal INTO p_embal.*

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'embal_plast_regina')
            RETURN FALSE
         END IF
         
         SELECT den_item 
           INTO p_den_item
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item = p_embal.cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo', 'item:1')
            RETURN FALSE
         END IF

         LET p_qtd_embal = p_qtd_volume * p_embal.qtd_embal
             
         DECLARE cq_val_ret CURSOR FOR       
          SELECT num_nf,
                 ser_nf,
                 ssr_nf,
                 ies_especie_nf,
                 num_sequencia,
                 dat_emis_nf,
                (qtd_tot_recebida - qtd_tot_devolvida),
                (val_remessa/qtd_tot_recebida) 
            FROM item_de_terc
           WHERE cod_empresa = p_cod_empresa
             AND cod_fornecedor = p_wfat.cod_cliente
             AND cod_item = p_embal.cod_item
             AND (qtd_tot_recebida - qtd_tot_devolvida) > 0
   			     AND dat_emis_nf >= '01/09/2009'
           ORDER BY dat_emis_nf 

         FOREACH cq_val_ret INTO 
            p_item_de_terc.num_nf, p_item_de_terc.ser_nf ,p_item_de_terc.ssr_nf,
            p_item_de_terc.ies_especie_nf, p_item_de_terc.num_sequencia,
            p_item_de_terc.dat_emis_nf, p_saldo, t_fat_emb[p_count].pre_unit_nf

            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo', 'cq_val_ret')
               RETURN FALSE
            END IF

            IF p_count > 1 THEN 
               
               FOR p_ind = 1 TO 100 
                   IF t_fat_ret[p_ind].num_nf  IS NULL THEN
                      EXIT FOR
                   END IF
                   IF t_fat_ret[p_ind].num_nf  =  p_item_de_terc.num_nf AND
                      t_fat_ret[p_ind].ser_nf  =  p_item_de_terc.ser_nf AND
                      t_fat_ret[p_ind].ssr_nf  =  p_item_de_terc.ssr_nf AND 
                      t_fat_ret[p_ind].esp_nf  =  p_item_de_terc.ies_especie_nf AND  
                      t_fat_ret[p_ind].num_seq =  p_item_de_terc.num_sequencia  THEN
                      LET p_saldo = p_saldo - t_fat_emb[p_ind].qtd_embal
                   END IF 
               END FOR
            END IF

            IF p_saldo > 0 THEN
               LET t_fat_ret[p_count].num_nf         =  p_item_de_terc.num_nf
               LET t_fat_ret[p_count].ser_nf         =  p_item_de_terc.ser_nf
               LET t_fat_ret[p_count].ssr_nf         =  p_item_de_terc.ssr_nf
               LET t_fat_ret[p_count].esp_nf         =  p_item_de_terc.ies_especie_nf
               LET t_fat_ret[p_count].num_seq        =  p_item_de_terc.num_sequencia
               LET t_fat_ret[p_count].dat_emis       =  p_item_de_terc.dat_emis_nf
               LET t_fat_ret[p_count].cod_item       =  p_embal.cod_item
               LET t_fat_emb[p_count].cod_embal      =  p_cod_embal
               LET t_fat_emb[p_count].cod_item       =  p_embal.cod_item
               LET t_fat_emb[p_count].den_item       =  p_den_item 
               IF p_saldo >= p_qtd_embal THEN
                  LET t_fat_emb[p_count].qtd_embal = p_qtd_embal
                  LET t_fat_ret[p_count].qtd_dev  = p_qtd_embal
                  LET p_qtd_embal = 0 
                  LET p_count = p_count + 1
                  EXIT FOREACH
               ELSE
                  LET t_fat_emb[p_count].qtd_embal = p_saldo
                  LET t_fat_ret[p_count].qtd_dev  =  p_saldo
                  LET p_qtd_embal = p_qtd_embal - p_saldo
                  LET p_count = p_count + 1
               END IF   
               IF t_fat_emb[p_count].pre_unit_nf  IS NULL  THEN  
                  LET t_fat_emb[p_count].pre_unit_nf = p_embal.pre_unit
               END IF
            END IF
            
         END FOREACH
            
         IF p_qtd_embal > 0 THEN
            LET p_msg = 'ITEM ', p_embal.cod_item, 'SEM SALDO\n SUFICIENTE PARA RETORNO'
            CALL log0030_mensagem(p_msg,'excla')
            RETURN FALSE
         END IF

      END FOREACH

   END FOREACH 

   CALL SET_COUNT(p_count - 1)

   LET INT_FLAG = 0

   INPUT ARRAY t_fat_emb WITHOUT DEFAULTS FROM s_fat_emb.*
    
      BEFORE ROW
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
    
         INITIALIZE p_den_embal TO NULL 
         SELECT den_embal
           INTO p_den_embal
           FROM embalagem
          WHERE cod_embal = t_fat_emb[pa_curr].cod_embal
      
         DISPLAY p_den_embal TO den_embal
         
      AFTER FIELD qtd_embal
      
      IF t_fat_emb[pa_curr].qtd_embal IS NULL THEN 
         LET t_fat_emb[pa_curr].qtd_embal = 0
         DISPLAY t_fat_emb[pa_curr].qtd_embal TO s_fat_emb[sc_curr].qtd_embal
      END IF
      
      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN 
         IF t_fat_emb[pa_curr+1].qtd_embal IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD qtd_embal   
         END IF  
      END IF  
      
      AFTER FIELD pre_unit_nf     
      
      IF t_fat_emb[pa_curr].pre_unit_nf IS NULL THEN
         LET t_fat_emb[pa_curr].pre_unit_nf = 0
         DISPLAY t_fat_emb[pa_curr].pre_unit_nf TO
                 s_fat_emb[sc_curr].pre_unit_nf    
      END IF
      
      IF t_fat_emb[pa_curr].qtd_embal > 0 AND
         t_fat_emb[pa_curr].pre_unit_nf = 0 THEN
         ERROR "Preco Unitario nao pode ser Zero"
         NEXT FIELD pre_unit_nf
      END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_fat_emb[pa_curr+1].qtd_embal IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD pre_unit_nf
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN 
      LET INT_FLAG = 0  
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO 100
     IF t_fat_emb[p_ind].cod_embal IS NOT NULL THEN
       
       INSERT INTO nf_embal_tmp
        VALUES(t_fat_emb[p_ind].cod_embal,  
               t_fat_emb[p_ind].cod_item,   
               t_fat_emb[p_ind].den_item,   
               t_fat_emb[p_ind].qtd_embal,  
               t_fat_emb[p_ind].pre_unit_nf)
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Inserindo','nf_embal_tmp')
          RETURN FALSE
       END IF
       
     END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0419_processa()                        
#--------------------------#
 
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF
 
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0419_gera_solicit() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF   
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0419_gera_solicit()#
#------------------------------#
   
   LET p_val_tot_nff = 0
   LET p_val_merc = 0
   LET p_pes_tot = 0
   
   IF NOT pol0419_le_num_nf() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0419_ins_fat_nf_mestre() THEN
      RETURN FALSE
   END IF

   IF NOT pol0419_ins_fat_nf_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol0419_mestre_fisc() THEN 
      RETURN FALSE
   END IF

   IF NOT POL0419_ins_duplicatas() THEN 
      RETURN FALSE
   END IF
   
   IF NOT POL0419_ins_embalagem() THEN 
      RETURN FALSE
   END IF
   
   IF p_wfat.cod_texto IS NOT NULL THEN
      IF NOT pol0419_ins_texto_nf(p_wfat.cod_texto) THEN 
         RETURN FALSE
      END IF
   END IF
   
   UPDATE fat_nf_mestre
      SET val_mercadoria = p_val_merc,
          val_acre_nf    = p_val_ipi,
          val_duplicata  = p_val_tot_nff,
          val_nota_fiscal = p_val_tot_nff,
          peso_liquido = p_pes_tot,
          peso_bruto = p_pes_tot
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'fat_nf_mestre')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0419_le_num_nf()#
#---------------------------#

   SELECT num_ultimo_docum,
          especie_docum,
          modelo_docum
     INTO p_num_nf,
          p_especie,
          p_modelo
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      AND tip_solicitacao = 'SOLPRDSV'
      AND serie_docum = p_wfat.ser_nf
      AND subserie_docum = p_wfat.ssr_nf
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_num_docum:2')
      RETURN FALSE
   END IF
       
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0419_ins_fat_nf_mestre()#
#-----------------------------------#

   INITIALIZE p_fat_mestre TO NULL
   LET p_cod_cnd_pgto = p_wfat.cod_cnd_pgto

   LET p_fat_mestre.empresa            =  p_cod_empresa            
   LET p_fat_mestre.trans_nota_fiscal  =  0                        
   LET p_fat_mestre.tip_nota_fiscal    =  'SOLPRDSV'             
   LET p_fat_mestre.serie_nota_fiscal  =  p_wfat.ser_nf                    
   LET p_fat_mestre.subserie_nf        =  p_wfat.ssr_nf
   LET p_fat_mestre.espc_nota_fiscal   =  p_especie                   
   LET p_fat_mestre.nota_fiscal        =  p_num_nf
   LET p_fat_mestre.status_nota_fiscal =  'S'                      
   LET p_fat_mestre.modelo_nota_fiscal =  p_modelo                      
   LET p_fat_mestre.origem_nota_fiscal =  'M'                      
   LET p_fat_mestre.tip_processamento  =  'A'                      
   LET p_fat_mestre.sit_nota_fiscal    =  'N'
   LET p_fat_mestre.cliente            =  p_wfat.cod_cliente
   LET p_fat_mestre.remetent           =  ' '                      
   LET p_fat_mestre.zona_franca        =  'N'                      
   LET p_fat_mestre.natureza_operacao  =  p_wfat.cod_nat_oper
   LET p_fat_mestre.finalidade         =  '1'   
   LET p_fat_mestre.cond_pagto         =  p_wfat.cod_cnd_pgto 
   LET p_fat_mestre.tip_carteira       =  '01'       
   LET p_fat_mestre.ind_despesa_financ =  0                        
   LET p_fat_mestre.moeda              =  1                        
   LET p_fat_mestre.plano_venda        =  'N'     
   LET p_fat_mestre.transportadora     =  p_cod_transpor
   LET p_fat_mestre.tip_frete          =  1 
   LET p_fat_mestre.via_transporte     =  1                      
   LET p_fat_mestre.peso_liquido       =  0 #calcular                       
   LET p_fat_mestre.peso_bruto         =  0 #calcular              
   LET p_fat_mestre.peso_tara          =  0                        
   LET p_fat_mestre.num_prim_volume    =  0                        
   LET p_fat_mestre.volume_cubico      =  0                        
   LET p_fat_mestre.usu_incl_nf        =  p_user   
   LET p_fat_mestre.dat_hor_emissao    =  CURRENT
   LET p_fat_mestre.sit_impressao      =  'N'                      
   LET p_fat_mestre.val_frete_rodov    =  0                        
   LET p_fat_mestre.val_seguro_rodov   =  0                        
   LET p_fat_mestre.val_fret_consig    =  0                        
   LET p_fat_mestre.val_segr_consig    =  0                        
   LET p_fat_mestre.val_frete_cliente  =  0                        
   LET p_fat_mestre.val_seguro_cliente =  0                        
   LET p_fat_mestre.val_desc_merc      =  0                        
   LET p_fat_mestre.val_desc_nf        =  0                        
   LET p_fat_mestre.val_desc_duplicata =  0                        
   LET p_fat_mestre.val_acre_merc      =  0                        
   LET p_fat_mestre.val_acre_nf        =  0                        
   LET p_fat_mestre.val_acre_duplicata =  0                        
   LET p_fat_mestre.val_mercadoria     =  0 #calcular
   LET p_fat_mestre.val_duplicata      =  0 #calcular
   LET p_fat_mestre.val_nota_fiscal    =  0 #calcular
                                                                                          
   INSERT INTO fat_nf_mestre VALUES (p_fat_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERINDO','FAT_NF_MESTRE')
      RETURN FALSE
   END IF
   
   LET p_trans_nf = SQLCA.SQLERRD[2]

   RETURN TRUE

END FUNCTION   

#---------------------------------#
FUNCTION pol0419_ins_fat_nf_item()#
#---------------------------------#
 
 INITIALIZE p_fat_item TO NULL
  
 LET p_fat_item.empresa            = p_fat_mestre.empresa                  
 LET p_fat_item.trans_nota_fiscal  = p_trans_nf  

 LET p_num_seq = 0

 DECLARE cq_nf_embal CURSOR FOR
  SELECT cod_embal,    
         cod_item,   
         den_item,   
         qtd_embal,  
         pre_unit_nf
    FROM nf_embal_tmp
 
 FOREACH cq_nf_embal INTO
   p_cod_embal, p_cod_item, p_den_item, p_qtd_embal, p_pre_unit_nf
  
   SELECT cod_nat_oper_ref                                  
     INTO p_cod_nat_oper                                            
     FROM nat_oper_refer                                            
    WHERE cod_empresa  = p_fat_mestre.empresa                               
      AND cod_nat_oper = p_fat_mestre.natureza_operacao                
      AND cod_item     = p_cod_item                
                                                                     
   IF STATUS = 100 THEN                                             
      LET p_cod_nat_oper = p_fat_mestre.natureza_operacao                                     
   ELSE                                                             
      IF STATUS <> 0 THEN                                           
         CALL log003_err_sql('Lendo','nat_oper_refer')            
         RETURN FALSE
      END IF                                                        
   END IF                                                           
   
   LET p_num_seq = p_num_seq + 1

   LET p_fat_item.pedido  			    = 0
	 LET p_fat_item.seq_item_pedido   = 0                             
   LET p_fat_item.ord_montag        = 0                              
   LET p_fat_item.seq_item_nf  	 	  = p_num_seq          
	 LET p_fat_item.item     				  = p_cod_item
   LET p_fat_item.tip_item          = 'N'                           
   LET p_fat_item.tip_preco         = 'F'                            
   LET p_fat_item.natureza_operacao = p_fat_mestre.natureza_operacao                
   LET p_fat_item.qtd_item          = p_qtd_embal

   SELECT cod_unid_med,
          den_item,
          pes_unit,
          cod_cla_fisc,
          fat_conver
     INTO p_fat_item.unid_medida,
          p_fat_item.des_item,
          p_fat_item.peso_unit,
          p_fat_item.classif_fisc,
          p_fat_item.fator_conv
     FROM item
    WHERE cod_empresa = p_fat_mestre.empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN                                           
      CALL log003_err_sql('Lendo','item:2')            
      RETURN FALSE
   END IF                                                        
                                                                      
    LET p_fat_item.preco_unit_bruto   = p_pre_unit_nf
    LET p_fat_item.pre_uni_desc_incnd = 0
    LET p_fat_item.preco_unit_liquido = p_fat_item.preco_unit_bruto
    LET p_fat_item.pct_frete          = 0                              
    LET p_fat_item.val_desc_item      = 0
    LET p_fat_item.val_desc_merc      = p_fat_item.val_desc_item
    LET p_fat_item.val_desc_contab    = p_fat_item.val_desc_item
    LET p_fat_item.val_desc_duplicata = p_fat_item.val_desc_item
    LET p_fat_item.val_acresc_item    = 0                             
    LET p_fat_item.val_acre_merc      = p_fat_item.val_acresc_item
    LET p_fat_item.val_acresc_contab  = p_fat_item.val_acresc_item
    LET p_fat_item.val_acre_duplicata = p_fat_item.val_acresc_item
    LET p_fat_item.val_fret_consig    = 0
    LET p_fat_item.val_segr_consig    = 0
    LET p_fat_item.val_frete_cliente  = 0
    LET p_fat_item.val_seguro_cliente = 0
    LET p_fat_item.val_liquido_item   = p_fat_item.preco_unit_liquido * p_fat_item.qtd_item
    LET p_fat_item.val_contab_item    = p_fat_item.val_liquido_item
    LET p_val_base_trib               = p_fat_item.val_liquido_item

    LET p_val_ipi = 0
    
    IF NOT pol0419_ins_tributo() THEN 
       RETURN FALSE
    END IF    
    
   LET p_fat_item.val_duplicata_item = p_fat_item.val_liquido_item + p_val_ipi
   LET p_fat_item.preco_unit_bruto   = p_fat_item.preco_unit_liquido               
   LET p_fat_item.pre_uni_desc_incnd = p_fat_item.preco_unit_liquido
   LET p_fat_item.val_merc_item      = p_fat_item.val_liquido_item
   LET p_fat_item.val_bruto_item     = p_fat_item.val_liquido_item + p_val_ipi  
   LET p_fat_item.val_brt_desc_incnd = p_fat_item.val_bruto_item
   LET p_fat_item.item_prod_servico  = p_tip_item                     
   
   LET p_val_tot_nff = p_val_tot_nff + p_fat_item.val_duplicata_item
   LET p_val_merc = p_val_merc + p_fat_item.val_liquido_item
   LET p_pes_tot = p_pes_tot + (p_fat_item.peso_unit * p_fat_item.qtd_item)

   INSERT INTO fat_nf_item VALUES(p_fat_item.*) 

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERCAO","fat_nf_item")
      RETURN FALSE
   END IF
   
 END FOREACH
 
 RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0419_ins_tributo()#
#-----------------------------#

   IF NOT pol0419_le_tributo() THEN 
      RETURN FALSE
   END IF
   
   DECLARE cq_tmp CURSOR FOR
    SELECT tributo_benef
      FROM tributo_tmp
   
   FOREACH cq_tmp INTO p_tributo_benef
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tributo_tmp:2')
         RETURN FALSE
      END IF
      
	  # O programa lê os parametros do icms primeiro para pegar o codigo fiscal 
	  
  
	  
      IF NOT pol0419_le_obf_config_icms() THEN 
         RETURN FALSE
      END IF
	  
      LET p_ies_tributo = FALSE

      IF NOT pol0419_le_obf_config() THEN 
         RETURN FALSE
      END IF
      
      IF NOT p_ies_tributo THEN
         LET p_msg = 'Tributo ',p_tributo_benef CLIPPED, 'não cadastrado\n',
                     'na tabela obf_config_fiscal!'
         CALL log0030_mensagem(p_msg, 'excla')
         CONTINUE FOREACH
      END IF

      IF NOT pol0419_ins_fat_item_fisc() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION
             
#----------------------------#
FUNCTION pol0419_le_tributo()#
#----------------------------#

   DELETE FROM tributo_tmp
   
   SELECT parametro_ind
    INTO p_tip_item                  # P = Produto ; S = Serviço
    FROM vdp_parametro_item 
   WHERE empresa   = p_cod_empresa
     AND item      = p_cod_item
     AND parametro = 'tipo_item'
  
   IF STATUS <> 0 THEN
      LET p_tip_item = 'P'
   END IF

   DECLARE cq_tributos CURSOR FOR
    SELECT a.tributo_benef, b.tip_config, b.prioridade 
      FROM obf_oper_fiscal a, obf_tributo_benef b
     WHERE a.empresa           = p_cod_empresa
       AND a.origem            = 'S'
       AND a.nat_oper_grp_desp = p_cod_nat_oper
       AND a.tip_item          IN ('A',p_tip_item) 
       AND b.empresa           = a.empresa 
       AND b.tributo_benef     = a.tributo_benef 
       AND b.ativo             IN ('S','A') 
     ORDER BY b.tip_config, b.prioridade   

   FOREACH  cq_tributos INTO
            p_tributo_benef

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tributos')
         RETURN FALSE
      END IF
      
      INSERT INTO tributo_tmp VALUES(p_tributo_benef)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','tributo_tmp')
         RETURN FALSE
      END IF

   END FOREACH

   SELECT COUNT(tributo_benef)
     INTO p_count
     FROM tributo_tmp

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tributo_tmp:1')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET p_msg = 'Não há tributos parametrizados\n',
                  'para a nutureza de operação ',p_cod_nat_oper
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
#------------------------------------#
FUNCTION pol0419_le_obf_config_icms()
#------------------------------------#
      
    INITIALIZE p_regiao_fiscal  TO NULL
	  
	  IF NOT pol0419_verifica_tributo() THEN 
         RETURN FALSE
      END IF

        INITIALIZE p_cod_fiscal   TO NULL 

			SELECT cod_fiscal 
			  INTO p_cod_fiscal
			  FROM obf_config_fiscal 		  
			 WHERE empresa = p_cod_empresa
				 AND tributo_benef = 'ICMS'
				 AND nat_oper_grp_desp =  p_cod_nat_oper
				 AND origem = 'S'
                 AND grp_fiscal_regiao = p_regiao_fiscal 				 
					 
			  IF STATUS <> 0 THEN 
				 CALL log003_err_sql('Lendo','obf_config_fiscal')
				 RETURN FALSE
			  END IF

			  
   RETURN TRUE

END FUNCTION
#-------------------------------#
FUNCTION pol0419_le_obf_config()#
#-------------------------------#
   
    INITIALIZE p_regiao_fiscal  TO NULL
	  
	  IF p_tributo_benef = 'ICMS'  THEN 
		   IF NOT pol0419_verifica_tributo() THEN 
			    RETURN FALSE
		   END IF
		  
	  DECLARE cq_obf_cfg1 CURSOR FOR 
		SELECT *
			  FROM obf_config_fiscal 
			 WHERE empresa = p_cod_empresa
				 AND tributo_benef = p_tributo_benef
				 AND nat_oper_grp_desp =  p_cod_nat_oper
				 AND origem = 'S' 
				 AND grp_fiscal_regiao = p_regiao_fiscal 
	 
	   FOREACH cq_obf_cfg1 INTO p_obf_config_fiscal.*

		  IF STATUS <> 0 THEN 
			 CALL log003_err_sql('Lendo','cq_obf_cfg')
			 RETURN FALSE
		  END IF
		  
		  LET p_ies_tributo = TRUE
		  EXIT FOREACH
	   
	   END FOREACH
   ELSE
		  DECLARE cq_obf_cfg2 CURSOR FOR 
		   SELECT *
			  FROM obf_config_fiscal 
			 WHERE empresa = p_cod_empresa
				 AND tributo_benef = p_tributo_benef
				 AND nat_oper_grp_desp =  p_cod_nat_oper
				 AND origem = 'S' 
	 
	   FOREACH cq_obf_cfg2 INTO p_obf_config_fiscal.*

		  IF STATUS <> 0 THEN 
			 CALL log003_err_sql('Lendo','cq_obf_cfg')
			 RETURN FALSE
		  END IF
		  
		  LET p_ies_tributo = TRUE
		  EXIT FOREACH
	   
	   END FOREACH
   END IF 
   
   IF p_obf_config_fiscal.hist_fiscal IS NOT NULL THEN
      IF NOT pol0419_ins_texto_nf(p_obf_config_fiscal.hist_fiscal ) THEN 
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0419_ins_fat_item_fisc()#
#-----------------------------------#

   INITIALIZE p_fat_item_fisc TO NULL
   
   LET p_aliquota = p_obf_config_fiscal.aliquota
   
   IF p_aliquota IS NULL THEN
      LET p_aliquota = 0
   END IF
   
   LET p_val_tribruto = p_val_base_trib * (p_aliquota / 100)

   IF p_tributo_benef = 'IPI' THEN
      LET p_val_ipi = p_val_tribruto
   END IF

   LET p_fat_item_fisc.empresa            = p_fat_item.empresa
   LET p_fat_item_fisc.trans_nota_fiscal  = p_fat_item.trans_nota_fiscal
   LET p_fat_item_fisc.seq_item_nf        = p_fat_item.seq_item_nf
   LET p_fat_item_fisc.tributo_benef      = p_obf_config_fiscal.tributo_benef
   LET p_fat_item_fisc.trans_config       = p_obf_config_fiscal.trans_config
   LET p_fat_item_fisc.bc_trib_mercadoria = p_val_base_trib
   LET p_fat_item_fisc.bc_tributo_frete   = 0
   LET p_fat_item_fisc.bc_trib_calculado  = 0
   LET p_fat_item_fisc.bc_tributo_tot     = p_fat_item_fisc.bc_trib_mercadoria
   LET p_fat_item_fisc.val_trib_merc      = p_val_tribruto
   LET p_fat_item_fisc.val_tributo_frete  = 0
   LET p_fat_item_fisc.val_trib_calculado = 0
   LET p_fat_item_fisc.val_tributo_tot    = p_fat_item_fisc.val_trib_merc
   LET p_fat_item_fisc.acresc_desc        = 0
   LET p_fat_item_fisc.aplicacao_val      = p_fat_item_fisc.aplicacao_val
   LET p_fat_item_fisc.incide             = p_obf_config_fiscal.incide
   LET p_fat_item_fisc.origem_produto     = p_obf_config_fiscal.origem_produto
   LET p_fat_item_fisc.tributacao         = p_obf_config_fiscal.tributacao
   LET p_fat_item_fisc.hist_fiscal        = p_obf_config_fiscal.hist_fiscal
   LET p_fat_item_fisc.sit_tributo        = p_obf_config_fiscal.sit_tributo
   LET p_fat_item_fisc.motivo_retencao    = p_obf_config_fiscal.motivo_retencao
   LET p_fat_item_fisc.retencao_cre_vdp   = p_obf_config_fiscal.retencao_cre_vdp
   LET p_fat_item_fisc.cod_fiscal         = p_cod_fiscal
   LET p_fat_item_fisc.inscricao_estadual = p_obf_config_fiscal.inscricao_estadual
   LET p_fat_item_fisc.dipam_b            = p_obf_config_fiscal.dipam_b
   LET p_fat_item_fisc.aliquota           = p_aliquota
   LET p_fat_item_fisc.val_unit           = p_obf_config_fiscal.val_unit
   LET p_fat_item_fisc.pre_uni_mercadoria = p_obf_config_fiscal.pre_uni_mercadoria
   LET p_fat_item_fisc.pct_aplicacao_base = p_obf_config_fiscal.pct_aplicacao_base
   LET p_fat_item_fisc.pct_acre_bas_calc  = p_obf_config_fiscal.pct_acre_bas_calc
   LET p_fat_item_fisc.pct_red_bas_calc   = p_obf_config_fiscal.pct_red_bas_calc
   LET p_fat_item_fisc.pct_diferido_base  = p_obf_config_fiscal.pct_diferido_base
   LET p_fat_item_fisc.pct_diferido_val   = p_obf_config_fiscal.pct_diferido_val
   LET p_fat_item_fisc.pct_acresc_val     = p_obf_config_fiscal.pct_acresc_val
   LET p_fat_item_fisc.pct_reducao_val    = p_obf_config_fiscal.pct_reducao_val
   LET p_fat_item_fisc.pct_margem_lucro   = p_obf_config_fiscal.pct_margem_lucro
   LET p_fat_item_fisc.pct_acre_marg_lucr = p_obf_config_fiscal.pct_acre_marg_lucr
   LET p_fat_item_fisc.pct_red_marg_lucro = p_obf_config_fiscal.pct_red_marg_lucro
   LET p_fat_item_fisc.taxa_reducao_pct   = p_obf_config_fiscal.taxa_reducao_pct
   LET p_fat_item_fisc.taxa_acresc_pct    = p_obf_config_fiscal.taxa_acresc_pct
   LET p_fat_item_fisc.cotacao_moeda_upf  = p_obf_config_fiscal.cotacao_moeda_upf
   LET p_fat_item_fisc.simples_nacional   = p_obf_config_fiscal.simples_nacional
   LET p_fat_item_fisc.iden_processo      = p_obf_config_fiscal.iden_processo
                                                                
   INSERT INTO fat_nf_item_fisc(
         empresa,           
         trans_nota_fiscal, 
         seq_item_nf,       
         tributo_benef,     
         trans_config,      
         bc_trib_mercadoria,
         bc_tributo_frete,  
         bc_trib_calculado, 
         bc_tributo_tot,    
         val_trib_merc,     
         val_tributo_frete, 
         val_trib_calculado,
         val_tributo_tot,   
         acresc_desc,       
         aplicacao_val,     
         incide,            
         origem_produto,    
         tributacao,        
         hist_fiscal,       
         sit_tributo,       
         motivo_retencao,   
         retencao_cre_vdp,  
         cod_fiscal,        
         inscricao_estadual,
         dipam_b,           
         aliquota,          
         val_unit,         
         pre_uni_mercadoria,
         pct_aplicacao_base,
         pct_acre_bas_calc, 
         pct_red_bas_calc,  
         pct_diferido_base, 
         pct_diferido_val,  
         pct_acresc_val,    
         pct_reducao_val,   
         pct_margem_lucro,  
         pct_acre_marg_lucr,
         pct_red_marg_lucro,
         taxa_reducao_pct,  
         taxa_acresc_pct,   
         cotacao_moeda_upf, 
         simples_nacional,  
         iden_processo) 
    VALUES(p_fat_item_fisc.*)                                  
                                                                
   IF STATUS <> 0 THEN                                       
      CALL log003_err_sql('Inserindo','fat_nf_item_fisc')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION POL0419_mestre_fisc()#
#-----------------------------#

   MESSAGE 'Gravando fat_mestre_fiscal!'
   
   INITIALIZE p_mest_fisc TO NULL

   LET p_mest_fisc.empresa            = p_fat_mestre.empresa  
   LET p_mest_fisc.trans_nota_fiscal  = p_trans_nf

   DECLARE cq_sum CURSOR FOR
    SELECT tributo_benef,
           SUM(bc_trib_mercadoria),
           SUM(bc_tributo_tot),
           SUM(val_trib_merc),
           SUM(val_tributo_tot)
      FROM fat_nf_item_fisc
     WHERE empresa = p_cod_empresa
       AND trans_nota_fiscal = p_trans_nf
     GROUP BY tributo_benef

   FOREACH cq_sum INTO 
           p_mest_fisc.tributo_benef,
           p_mest_fisc.bc_trib_mercadoria,
           p_mest_fisc.bc_tributo_tot,
           p_mest_fisc.val_trib_merc,
           p_mest_fisc.val_tributo_tot
          
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_item_fisc')
         RETURN FALSE
      END IF

      LET p_mest_fisc.bc_tributo_frete   = 0
      LET p_mest_fisc.bc_trib_calculado  = 0
      LET p_mest_fisc.val_tributo_frete  = 0
      LET p_mest_fisc.val_trib_calculado = 0

      INSERT INTO fat_mestre_fiscal
       VALUES(p_mest_fisc.*)
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','fat_mestre_fiscal')
         RETURN FALSE
      END IF
      
      IF p_tributo_benef = 'IPI' THEN
         LET p_val_ipi = p_mest_fisc.val_trib_merc
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0419_ins_duplicatas()
#-------------------------------#

   DEFINE p_nf_integr         RECORD LIKE fat_nf_integr.*,
          p_ies_emite_dupl    CHAR(01),
          p_sequencia         LIKE cond_pgto_item.sequencia,
          p_pct_valor_liquido LIKE cond_pgto_item.pct_valor_liquido,
          p_qtd_dias_sd       LIKE cond_pgto_item.qtd_dias_sd,
          p_val_tot_dupl      DECIMAL(17,2),
          p_ind               INTEGER,
          p_val_gravado       DECIMAL(17,2),
          p_val_duplic        DECIMAL(17,2),
          p_dat_vencto        DATE

 SELECT ies_emite_dupl
   INTO p_ies_emite_dupl
   FROM nat_operacao
  WHERE cod_nat_oper = p_wfat.cod_nat_oper

 IF STATUS <> 0 THEN
    CALL log003_err_sql('Lendo','nat_operacao')
    RETURN FALSE
 END IF

 IF p_ies_emite_dupl = 'N' THEN
    RETURN TRUE
 END IF
 
 SELECT ies_emite_dupl
   INTO p_ies_emite_dupl
   FROM cond_pgto
  WHERE cod_cnd_pgto = p_cod_cnd_pgto
 
 IF p_ies_emite_dupl = 'N' THEN
    RETURN TRUE
 END IF

   SELECT COUNT(cod_cnd_pgto)
     INTO p_count
    FROM cond_pgto_item
   WHERE cod_cnd_pgto = p_cod_cnd_pgto

   IF p_count IS NULL THEN
      RETURN TRUE
   END IF
   
  LET  p_nf_integr.empresa           	= p_cod_empresa
  LET  p_nf_integr.trans_nota_fiscal 	= p_trans_nf
  LET  p_nf_integr.sit_nota_fiscal   	= 'N'
  LET  p_nf_integr.status_intg_est   	= 'P' 	 
  LET  p_nf_integr.status_intg_contab	= 'P'	 
  LET  p_nf_integr.status_intg_creceb	= 'P'	 
  LET  p_nf_integr.status_integr_obf	= 'P'	 
  LET  p_nf_integr.status_intg_migr		= 'P'	 
	
	INSERT INTO fat_nf_integr
	 VALUES(p_nf_integr.*)	        
	 
	IF STATUS <> 0 THEN 
	   CALL log003_err_sql('Inserindo','fat_nf_integr')
      RETURN FALSE
	END IF 

  LET p_val_tot_dupl = p_val_tot_nff
  LET p_ind = 1
  LET p_val_gravado = 0
	
  DECLARE cq_cond CURSOR FOR
   SELECT sequencia,
          pct_valor_liquido,
          qtd_dias_sd
     FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_fat_mestre.cod_cnd_pgto

    FOREACH cq_cond INTO 
          p_sequencia,
          p_pct_valor_liquido,
          p_qtd_dias_sd    

	    IF STATUS <> 0 THEN 
	       CALL log003_err_sql('lendo','cond_pgto_item:cq_cond')
         RETURN FALSE
	    END IF 

      IF p_ind = p_count THEN
         LET p_val_duplic = p_val_tot_dupl - p_val_gravado
      ELSE
         LET p_val_duplic  = 
             p_val_tot_dupl * p_pct_valor_liquido / 100
      END IF
      
      LET p_val_gravado = p_val_gravado + p_val_duplic    
      LET p_dat_vencto  = TODAY + p_qtd_dias_sd

      LET  p_nf_duplicata.empresa           = p_cod_empresa 
      LET  p_nf_duplicata.trans_nota_fiscal = p_trans_nf    
      LET  p_nf_duplicata.seq_duplicata     = p_sequencia            
      LET  p_nf_duplicata.val_duplicata     = p_val_duplic   
      LET  p_nf_duplicata.dat_vencto_sdesc  = p_dat_vencto  
      LET  p_nf_duplicata.dat_vencto_cdesc  = ''
      LET  p_nf_duplicata.pct_desc_financ   = 0             
      LET  p_nf_duplicata.val_bc_comissao   = 0             
      LET  p_nf_duplicata.agencia           = 0             
      LET  p_nf_duplicata.dig_agencia       = ' '           
      LET  p_nf_duplicata.titulo_bancario   = ' '           
      LET  p_nf_duplicata.docum_cre         = ' '           
      LET  p_nf_duplicata.empresa_cre       = ' '           
      
      INSERT INTO fat_nf_duplicata
       VALUES(p_nf_duplicata.*)

	    IF STATUS <> 0 THEN 
	       CALL log003_err_sql('Inserindo','fat_nf_duplicata')
         RETURN FALSE
	    END IF 

      LET p_ind = p_ind + 1
      
   END FOREACH

	RETURN TRUE

END FUNCTION
#------------------------------#
FUNCTION POL0419_ins_embalagem()
#------------------------------#

 DEFINE p_qtd_embal DEC(17,6)
   
   LET p_qtd_embal = 0

   SELECT SUM(qtd_item)
     INTO p_qtd_embal 
     FROM FAT_NF_ITEM
	WHERE EMPRESA = p_fat_mestre.empresa
	AND   TRANS_NOTA_FISCAL = p_trans_nf
	
	IF STATUS <> 0 THEN 
	       CALL log003_err_sql('LENDO 2','fat_nf_item')
         RETURN FALSE
	END IF 

   INSERT INTO fat_nf_embalagem  
    VALUES(p_fat_mestre.empresa,
           p_trans_nf, 
		   999,
           p_qtd_embal,
           0)
           
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Inserindo','fat_nf_embalagem')
      RETURN FALSE
	 END IF 
   
   RETURN TRUE

END FUNCTION
#----------------------------------------#
FUNCTION pol0419_ins_texto_nf(p_cod_hist)#
#----------------------------------------#

   DEFINE p_cod_hist   LIKE fiscal_hist.cod_hist,
          p_tex_hist_1 LIKE fiscal_hist.tex_hist_1,         
          p_tex_hist_2 LIKE fiscal_hist.tex_hist_2,         
          p_tex_hist_3 LIKE fiscal_hist.tex_hist_3,         
          p_tex_hist_4 LIKE fiscal_hist.tex_hist_4
   
   LET p_cod_texto = p_cod_hist

   SELECT COUNT(sequencia_texto)
     INTO p_count
     FROM fat_nf_texto_hist
    WHERE empresa = p_fat_mestre.empresa
      AND trans_nota_fiscal = p_trans_nf
      AND texto = p_cod_texto

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','fat_nf_texto_hist')
      RETURN FALSE
   END IF     
   
   IF p_count > 0 THEN
      RETURN TRUE
   END IF
             
   SELECT tex_hist_1,
          tex_hist_2,
          tex_hist_3,
          tex_hist_4
     INTO p_tex_hist_1,
          p_tex_hist_2,
          p_tex_hist_3,
          p_tex_hist_4
     FROM fiscal_hist
    WHERE cod_hist = p_cod_hist

   IF STATUS = 0 THEN   

      LET p_des_texto = p_tex_hist_1 CLIPPED
      
      IF p_des_texto IS NULL OR p_des_texto = '' THEN
      ELSE
         IF NOT pol0419_grava_texto() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_des_texto = p_tex_hist_2 CLIPPED
      
      IF p_des_texto IS NULL OR p_des_texto = '' THEN
      ELSE
         IF NOT pol0419_grava_texto() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_des_texto = p_tex_hist_3 CLIPPED
      
      IF p_des_texto IS NULL OR p_des_texto = '' THEN
      ELSE
         IF NOT pol0419_grava_texto() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_des_texto = p_tex_hist_4 CLIPPED
      
      IF p_des_texto IS NULL OR p_des_texto = '' THEN
      ELSE
         IF NOT pol0419_grava_texto() THEN
            RETURN FALSE
         END IF
      END IF
   
   END IF   

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0419_grava_texto()#
#---------------------------#
   
   DEFINE p_seq_texto INTEGER
   
   SELECT MAX(sequencia_texto)
     INTO p_seq_texto
     FROM fat_nf_texto_hist
    WHERE empresa = p_fat_mestre.empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','fat_nf_texto_hist')
      RETURN FALSE
   END IF      
   
   IF p_seq_texto IS NULL THEN
      LET p_seq_texto = 0
   END IF
   
   LET p_seq_texto = p_seq_texto + 1
      
   INSERT INTO fat_nf_texto_hist   
    VALUES(p_fat_mestre.empresa,
           p_trans_nf, 
           p_seq_texto,
           p_cod_texto,
           p_des_texto, 2)
           
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Inserindo','fat_nf_texto_hist')
      RETURN FALSE
	 END IF 
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0419_verifica_tributo()
#--------------------------------#
 INITIALIZE p_obf_controle_chave.*  TO NULL 
   SELECT   empresa,
			tributo_benef,
			natureza_operacao,
			ctr_nat_operacao, 	
			grp_fiscal_regiao, 	
    		ctr_grp_fisc_regi, 	
    		estado, 				
    		controle_estado, 	
   			municipio, 			
			controle_municipio,  
			carteira, 			
			controle_carteira, 	
			finalidade, 			
			ctr_finalidade, 		
			familia_item, 		
			ctr_familia_item, 	
			grp_fiscal_classif, 	
			ctr_grp_fisc_clas, 	
			classif_fisc, 		
			ctr_classif_fisc, 	
			linha_produto, 		
			ctr_linha_produto, 	
			linha_receita, 		
			ctr_linha_receita, 	 
			segmto_mercado, 		 
			ctr_segmto_mercado, 	 
			classe_uso, 			 
			ctr_classe_uso, 		 
			unid_medida, 		 
			ctr_unid_medida, 	 
			produto_bonific, 	 
			ctr_prod_bonific, 	 
			grupo_fiscal_item, 	 
			ctr_grp_fisc_item,	 
			item, 				 
			controle_item, 		 
			micro_empresa, 		 
			ctr_micro_empresa, 	 
			grp_fiscal_cliente, 	 
			ctr_grp_fisc_cli, 	 
			cliente, 			 
			controle_cliente, 	 
			via_transporte, 		 
			ctr_via_transporte, 	 
			tem_valid_config, 	 
			ctrl_valid_config  
	 INTO p_obf_controle_chave.*
	 FROM obf_controle_chave
    WHERE empresa         = p_cod_empresa
      AND tributo_benef   = 'ICMS'
  
     IF STATUS <> 0 THEN
       INITIALIZE p_obf_controle_chave.*  TO NULL 
       RETURN FALSE
     END IF
  
     IF p_obf_controle_chave.grp_fiscal_regiao  = 'S'  THEN
         IF NOT pol0419_le_obf_regiao() THEN
            RETURN FALSE
         END IF
	  END IF 
  
    RETURN TRUE
         
END FUNCTION
#-------------------------------#
FUNCTION pol0419_le_obf_regiao()
#-------------------------------#


   CALL pol0419_le_uf()

   INITIALIZE p_regiao_fiscal  TO NULL 
   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = 'ICMS'
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = p_cod_empresa
         AND tributo_benef = 'ICMS'
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo 3', 'obf_regiao_fiscal')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION
#----------------------#
FUNCTION pol0419_le_uf()
#----------------------#
   INITIALIZE p_cod_uni_feder, p_cod_cidade  TO NULL  
	
   SELECT b.cod_uni_feder,
          b.cod_cidade   
     INTO p_cod_uni_feder,
          p_cod_cidade    
     FROM clientes a, cidades b
    WHERE a.cod_cliente = p_wfat.cod_cliente1
      AND b.cod_cidade  = a.cod_cidade

   IF STATUS <> 0 THEN
		INITIALIZE p_cod_uni_feder, p_cod_cidade  TO NULL  
   END IF
END FUNCTION
#----------------------------- FIM DE PROGRAMA BL--------------------------------#
