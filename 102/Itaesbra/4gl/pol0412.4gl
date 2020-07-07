#-------------------------------------------------------------------#
# SISTEMA.: EMBALAGEM                                               #
# PROGRAMA: POL0412                                                 #
# MODULOS.: POL0412 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: FATURAMENTO/EMBALAGENS                                  #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 26/12/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa LIKE empresa.cod_empresa,
          p_den_empresa LIKE empresa.den_empresa,  
          p_user        LIKE usuario.nom_usuario,
          p_trans_nf    INTEGER,
          p_qtd_item    INTEGER,
          p_num_nf      INTEGER,
          p_cod_cliente CHAR(15),
          p_ind         SMALLINT,
          p_status      SMALLINT,
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
          p_msg         CHAR(100)

   DEFINE m_msg                CHAR(600),
          p_tip_item           CHAR(01),
          p_sem_tributo        SMALLINT,
          p_num_ctr_acesso     INTEGER,
          p_query              CHAR(600),
          p_ies_tributo        SMALLINT,
          p_tributo_benef      CHAR(20),
          p_grp_classif_fisc   CHAR(10),
          p_grp_fiscal_item    CHAR(10),
          p_grp_fisc_cliente   CHAR(10),
          p_trans_config       INTEGER,
          p_chave              CHAR(11),
          p_matriz             CHAR(22),
          p_regiao_fiscal      CHAR(10),
          p_cod_uni_feder      CHAR(02),
          p_micro_empresa      CHAR(01),
          p_cod_cidade         LIKE clientes.cod_cidade,
          p_cod_lin_prod       LIKE item.cod_lin_prod,
          p_cod_lin_recei      LIKE item.cod_lin_recei,
          p_cod_seg_merc       LIKE item.cod_seg_merc,
          p_cod_cla_uso        LIKE item.cod_cla_uso,
          p_cod_cla_fisc       LIKE item.cod_cla_fisc,
          p_cod_familia        LIKE item.cod_familia, 
          p_gru_ctr_estoq      LIKE item.gru_ctr_estoq,           
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_cod_nat_oper       LIKE wfat_mestre.cod_nat_oper,
          p_cod_cnd_pgto       LIKE wfat_mestre.cod_cnd_pgto,
          p_ies_tipo           LIKE estoque_operac.ies_tipo,
          p_cod_item           LIKE item.cod_item,
          p_seq_acesso         LIKE obf_ctr_acesso.sequencia_acesso,
          p_cod_fiscal         LIKE fat_nf_item_fisc.cod_fiscal,
          p_tot_peso           LIKE fat_nf_mestre.peso_bruto

   DEFINE p_val_icm_it         LIKE fit_itemes_fiscal.val_icm,
          p_pes_unit           LIKE item.pes_unit,
          p_fat_conver         LIKE item.fat_conver      

   DEFINE p_wfat_mestre        RECORD LIKE wfat_mestre.*,
          p_fiscal_par         RECORD LIKE fiscal_par.*,
          p_fat_mestre         RECORD LIKE fat_nf_mestre.*,
          p_fat_item           RECORD LIKE fat_nf_item.*,
          p_item_fisc          RECORD LIKE fat_nf_item_fisc.*,
          p_txt_hist           RECORD LIKE fat_nf_texto_hist.*,
          p_mest_fisc          RECORD LIKE fat_mestre_fiscal.*
          
   DEFINE t_fat_emb ARRAY[30] OF RECORD 
      cod_item       LIKE wfat_item.cod_item, 
      den_item       LIKE item.den_item, 
      qtd_item       LIKE wfat_item.qtd_item, 
      pre_unit_nf    LIKE wfat_item.pre_unit_nf 
   END RECORD 

   DEFINE pr_nf     ARRAY[8] OF RECORD 
          num_nf    LIKE fat_nf_mestre.nota_fiscal
   END RECORD

   DEFINE p_texto RECORD 
      cod_texto      LIKE fit_mestre.cod_texto_2,
      des_texto      CHAR(120),                    
      tex_obs        CHAR(120)
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
      tip_carteira     LIKE pedidos.cod_tip_carteira,     
      ies_finalidade   LIKE pedidos.ies_finalidade,       
      cod_moeda        LIKE fat_nf_mestre.moeda, 
      tip_frete        LIKE fat_nf_mestre.tip_frete,          
      via_transp       LIKE fat_nf_mestre.via_transporte,      
      num_nff1         LIKE wfat_mestre.num_nff, 
      num_nff2         LIKE wfat_mestre.num_nff, 
      num_nff3         LIKE wfat_mestre.num_nff, 
      num_nff4         LIKE wfat_mestre.num_nff, 
      num_nff5         LIKE wfat_mestre.num_nff, 
      num_nff6         LIKE wfat_mestre.num_nff,
      num_nff7         LIKE wfat_mestre.num_nff,
      num_nff8         LIKE wfat_mestre.num_nff,
      ies_tip_controle LIKE nat_operacao.ies_tip_controle,
      num_solicit      LIKE fit_mestre.num_solicit,           
      den_nat_oper     LIKE nat_operacao.den_nat_oper,
      den_cnd_pgto     LIKE cond_pgto.den_cnd_pgto,
      nom_cliente      LIKE clientes.nom_cliente
   END RECORD 

   DEFINE p_cod_hist_1   LIKE fiscal_hist.cod_hist, 
          p_tex_hist_1_1 LIKE fiscal_hist.tex_hist_1,
          p_tex_hist_2_1 LIKE fiscal_hist.tex_hist_2,
          p_tex_hist_3_1 LIKE fiscal_hist.tex_hist_3,
          p_tex_hist_4_1 LIKE fiscal_hist.tex_hist_4,
          p_cod_hist_2   LIKE fiscal_hist.cod_hist,
          p_tex_hist_1_2 LIKE fiscal_hist.tex_hist_1,
          p_tex_hist_2_2 LIKE fiscal_hist.tex_hist_2,
          p_tex_hist_3_2 LIKE fiscal_hist.tex_hist_3,
          p_tex_hist_4_2 LIKE fiscal_hist.tex_hist_4,
          p_pct_ipi      LIKE item.pct_ipi,         
          p_val_liq_item LIKE fit_itemes.val_liq_item,
          p_val_ipi      LIKE fit_itemes.val_ipi,     
          p_val_tot_liq  LIKE fit_itemes.val_liq_item, 
          p_val_tot_ipi  LIKE fit_itemes.val_ipi,
          p_val_tot_nff  LIKE fit_totais.val_tot_nff,
          p_val_tot_icm  LIKE fit_totais.val_tot_icm,
          p_saldo        LIKE item_de_terc.qtd_tot_devolvida,
          p_resto        LIKE wfat_item.qtd_item,
          p_tip_docum    LIKE vdp_num_docum.tip_docum,
          p_tip_solic    LIKE vdp_num_docum.tip_solicitacao,
          p_ser          LIKE vdp_num_docum.serie_docum,
          p_ssr          LIKE vdp_num_docum.subserie_docum,
          p_esp          LIKE vdp_num_docum.especie_docum,
          p_cod_embal    LIKE fat_nf_embalagem.embalagem,
          p_qtd_volume   LIKE fat_nf_embalagem.qtd_volume,
          p_qtd_fat      LIKE wfat_item.qtd_item, 
          p_pre_unit     LIKE wfat_item.pre_unit_nf,
          p_val_item     LIKE wfat_item.pre_unit_nf

         

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
      DEFER INTERRUPT
   LET p_versao = "POL0412-10.02.03"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0412.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0412_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0412_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0412") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0412 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa
   
   CALL pol0412_cria_temporaria()

   IF NOT pol0412_le_param() THEN
      RETURN FALSE
   END IF

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         HELP 001
         MESSAGE ""
         LET int_flag = 0
            CALL pol0412_inclusao() 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0412_sobre() 
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
   CLOSE WINDOW w_pol0412

END FUNCTION

#-----------------------#
FUNCTION pol0412_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------------------#
 FUNCTION pol0412_inclusao()
#--------------------------------------#
 
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0412_entrada_dados() THEN
      LET p_cod_cliente  = p_wfat_mestre.cod_cliente
      LET p_cod_nat_oper = p_wfat_mestre.cod_nat_oper
      LET p_cod_cnd_pgto = p_wfat_mestre.cod_cnd_pgto
      IF pol0412_info_preco() THEN
         CALL log085_transacao("BEGIN")
         IF pol0412_processa() THEN
            CALL log085_transacao("COMMIT")
            CALL log0030_mensagem("Operação Efetuada com Sucesso !",'excla')
            RETURN
         END IF
         CALL log085_transacao("ROLLBACK")
      END IF 	
   END IF

   INITIALIZE p_wfat_mestre.* TO NULL
   INITIALIZE p_wfat.* TO NULL
   CLEAR FORM
   DISPLAY cod_empresa TO p_cod_empresa
   
   CALL log0030_mensagem("Operação cancelada !",'excla')

END FUNCTION

#-------------------------------#
 FUNCTION pol0412_entrada_dados()
#-------------------------------#

   DISPLAY p_cod_empresa TO cod_empresa
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0412
   INITIALIZE p_wfat_mestre.* TO NULL
   INITIALIZE p_item_de_terc.* TO NULL
   INITIALIZE p_texto.*, pr_nf TO NULL
   LET p_wfat.tip_carteira     = '07'
   LET p_wfat.ies_finalidade   = '1'
   LET p_wfat.tip_frete        = '3'
   LET p_wfat.cod_moeda        = '1'
   LET p_wfat.via_transp       = '1'

   DELETE FROM wnota_cli
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_wfat_mestre.cod_cliente, 
                 p_wfat.num_solicit,
                 p_wfat.tip_carteira,
                 p_wfat.ies_finalidade,
                 p_wfat.tip_frete,
                 p_wfat.cod_moeda,
                 p_wfat.via_transp,
                 p_wfat.num_nff1,
                 p_wfat.num_nff2,
                 p_wfat.num_nff3,
                 p_wfat.num_nff4,
                 p_wfat.num_nff5,
                 p_wfat.num_nff6,
                 p_wfat.num_nff7,
                 p_wfat.num_nff8,
                 p_wfat_mestre.cod_nat_oper, 
                 p_wfat_mestre.cod_cnd_pgto,
                 p_texto.cod_texto,
                 p_texto.tex_obs
      WITHOUT DEFAULTS  

      AFTER FIELD cod_cliente  
      
         IF p_wfat_mestre.cod_cliente IS NULL THEN
            ERROR "O Campo Cod Cliente nao pode ser Nulo"
            NEXT FIELD cod_cliente  
         END IF
      
         SELECT nom_cliente,
                cod_cidade   
           INTO p_wfat.nom_cliente,
                p_cod_cidade    
           FROM clientes
          WHERE cod_cliente = p_wfat_mestre.cod_cliente
       
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cliente nao Cadastrado"
            NEXT FIELD cod_cliente  
         END IF
      
         DISPLAY BY NAME p_wfat.nom_cliente

         SELECT cod_uni_feder
           INTO p_cod_uni_feder
           FROM cidades
          WHERE cod_cidade = p_cod_cidade

         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','cidades')
            NEXT FIELD cod_cliente
         END IF

      AFTER FIELD num_solicit

         IF p_wfat.num_solicit IS NULL OR 
            p_wfat.num_solicit = 0     THEN
             ERROR "Valor inválido para o campo"
            NEXT FIELD num_solicit  
         END IF
         
      BEFORE FIELD num_nff1
         LET pr_nf[1].num_nf = NULL
         
      AFTER FIELD num_nff1

         IF p_wfat.num_nff1 IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório!'
            NEXT FIELD num_nff1
         END IF
      
         IF NOT pol0412_checa_nf(p_wfat.num_nff1) THEN
            NEXT FIELD num_nff1
         END IF
         
         LET pr_nf[1].num_nf = p_wfat.num_nff1
         
      BEFORE FIELD num_nff2
         LET pr_nf[2].num_nf = NULL
         
      AFTER FIELD num_nff2

         IF p_wfat.num_nff2 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff2) THEN
               NEXT FIELD num_nff2
            END IF
            LET pr_nf[2].num_nf = p_wfat.num_nff2
         END IF

      BEFORE FIELD num_nff3
         LET pr_nf[3].num_nf = NULL

      AFTER FIELD num_nff3

         IF p_wfat.num_nff3 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff3) THEN
               NEXT FIELD num_nff3
            END IF
            LET pr_nf[3].num_nf = p_wfat.num_nff3
         END IF

      BEFORE FIELD num_nff4
         LET pr_nf[4].num_nf = NULL

      AFTER FIELD num_nff4

         IF p_wfat.num_nff4 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff4) THEN
               NEXT FIELD num_nff4
            END IF
            LET pr_nf[4].num_nf = p_wfat.num_nff4
         END IF

      BEFORE FIELD num_nff5
         LET pr_nf[5].num_nf = NULL

      AFTER FIELD num_nff5

         IF p_wfat.num_nff5 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff5) THEN
               NEXT FIELD num_nff5
            END IF
            LET pr_nf[5].num_nf = p_wfat.num_nff5
         END IF

      BEFORE FIELD num_nff6
         LET pr_nf[6].num_nf = NULL

      AFTER FIELD num_nff6

         IF p_wfat.num_nff6 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff6) THEN
               NEXT FIELD num_nff6
            END IF
            LET pr_nf[6].num_nf = p_wfat.num_nff6
         END IF

      BEFORE FIELD num_nff7
         LET pr_nf[7].num_nf = NULL

      AFTER FIELD num_nff7

         IF p_wfat.num_nff7 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff7) THEN
               NEXT FIELD num_nff7
            END IF
            LET pr_nf[7].num_nf = p_wfat.num_nff7
         END IF

      BEFORE FIELD num_nff8
         LET pr_nf[8].num_nf = NULL

      AFTER FIELD num_nff8

         IF p_wfat.num_nff8 IS NOT NULL THEN
            IF NOT pol0412_checa_nf(p_wfat.num_nff8) THEN
               NEXT FIELD num_nff8
            END IF
            LET pr_nf[8].num_nf = p_wfat.num_nff8
         END IF

      AFTER FIELD cod_nat_oper 
      
         IF p_wfat_mestre.cod_nat_oper IS NULL THEN
            ERROR "O Campo Cod Nat Oper nao pode ser Nulo"
            NEXT FIELD cod_nat_oper 
         END IF
      
         SELECT den_nat_oper,
                ies_tip_controle  
           INTO p_wfat.den_nat_oper,
                p_wfat.ies_tip_controle
           FROM nat_operacao
          WHERE cod_nat_oper = p_wfat_mestre.cod_nat_oper
         
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cod Nat Oper nao Cadastrado"
            NEXT FIELD cod_nat_oper 
         END IF
         
         DISPLAY BY NAME p_wfat.den_nat_oper 
            
      AFTER FIELD cod_cnd_pgto 
      
         IF p_wfat_mestre.cod_cnd_pgto IS NULL THEN
            ERROR "O Campo Cond Pagto nao pode ser Nulo"
            NEXT FIELD cod_cnd_pgto 
         END IF
      
         SELECT den_cnd_pgto  
           INTO p_wfat.den_cnd_pgto 
           FROM cond_pgto   
          WHERE cod_cnd_pgto = p_wfat_mestre.cod_cnd_pgto
         
         IF SQLCA.SQLCODE <> 0 THEN
            ERROR "Cond Pagto nao Cadastrada"
            NEXT FIELD cod_cnd_pgto 
         END IF
         
         DISPLAY BY NAME p_wfat.den_cnd_pgto 

      AFTER FIELD cod_texto

         IF p_texto.cod_texto IS NOT NULL THEN
            SELECT des_texto     
              INTO p_texto.des_texto    
              FROM texto_nf    
             WHERE cod_texto = p_texto.cod_texto
         
            IF SQLCA.SQLCODE <> 0 THEN
               ERROR "Texto da Nota Fiscal nao Cadastrado"
               NEXT FIELD cod_texto    
            END IF
            DISPLAY BY NAME p_texto.des_texto
         END IF

      ON KEY (control-z)
         IF infield(cod_cliente) THEN
            LET p_wfat_mestre.cod_cliente = vdp372_popup_cliente()
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0412
            DISPLAY BY NAME p_wfat_mestre.cod_cliente
         END IF
         IF infield(cod_nat_oper) THEN
            CALL log009_popup(6,25,"NAT. OPERACAO","nat_operacao",
                              "cod_nat_oper","den_nat_oper",
                              "pol0412","N","") 
            RETURNING p_wfat_mestre.cod_nat_oper
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0412
            DISPLAY p_wfat_mestre.cod_nat_oper TO cod_nat_oper
         END IF
         IF INFIELD(cod_cnd_pgto) THEN
            CALL log009_popup(6,25,"CND. PAGAMENTO","cond_pgto",
                              "cod_cnd_pgto","den_cnd_pgto",
                              "pol0412","N","") 
            RETURNING p_wfat_mestre.cod_cnd_pgto
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0412 
            DISPLAY p_wfat_mestre.cod_cnd_pgto TO cod_cnd_pgto
         END IF
         IF INFIELD(cod_texto) THEN
            CALL log009_popup(6,25,"TEXTO DA N.F.","texto_nf",
                              "cod_texto","des_texto",
                              "vdp0390","N","") 
            RETURNING p_texto.cod_texto
            CALL log006_exibe_teclas("01 02 03 07", p_versao)
            CURRENT WINDOW IS w_pol0412
            DISPLAY p_texto.cod_texto TO cod_texto
         END IF
   
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_wfat_mestre.cod_nat_oper IS NULL THEN
               ERROR "O Campo Cod Nat Oper nao pode ser Nulo"
               NEXT FIELD cod_nat_oper 
            END IF
            IF p_wfat_mestre.cod_cnd_pgto IS NULL THEN
               ERROR "O Campo Cod pagamento nao pode ser Nulo"
               NEXT FIELD cod_cnd_pgto 
            END IF
         END IF
                  
   END INPUT 
 
   IF INT_FLAG  THEN
      RETURN FALSE 
   END IF

   FOR p_ind = 1 TO 8
       IF pr_nf[p_ind].num_nf IS NOT NULL THEN
          INSERT INTO wnota_cli
           VALUES(pr_nf[p_ind].num_nf, p_wfat_mestre.cod_cliente)
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Inserindo','wnota_cli')
             RETURN FALSE
          END IF
       END IF
   END FOR
   
   RETURN TRUE          

END FUNCTION

#----------------------------------#
FUNCTION pol0412_checa_nf(p_num_nf)
#----------------------------------#

   DEFINE p_num_nf       LIKE fat_nf_mestre.nota_fiscal
   
   SELECT tip_carteira
     FROM fat_nf_mestre
    WHERE empresa     = p_cod_empresa
      AND nota_fiscal = p_num_nf
      AND tip_nota_fiscal = p_tip_docum
      AND cliente     = p_wfat_mestre.cod_cliente
      
   IF STATUS = 0 THEN
   ELSE
      IF STATUS = 100 THEN
         LET p_msg = 'Nota fiscal inexistente ou\n',
                     'não é do cliente informado!'
         CALL log0030_mensagem(p_msg,'excla')
      ELSE
         CALL log003_err_sql('Lendo','fat_nf_mestre')
      END IF
      RETURN FALSE
   END IF
     
   FOR p_ind = 1 TO 8
       IF pr_nf[p_ind].num_nf = p_num_nf THEN
          CALL log0030_mensagem('Nota fiscal já informada!','excla')
          RETURN FALSE
       END IF
   END FOR
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0412_cria_temporaria()
#--------------------------------#
   DROP TABLE wnota_cli
   CREATE  TABLE wnota_cli
      (
      num_nff     DEC(6,0), 
      cod_cliente CHAR(15)
      );
      
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-wnota_cli")
      RETURN FALSE
   END IF

   DROP TABLE wnota
   CREATE  TABLE wnota
      (
      cod_embal  CHAR(03), 
      qtd_volume DECIMAL(5,0)
      );
      
   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("CRIACAO","TABELA-wnota")
      RETURN FALSE
   END IF

   DROP TABLE chave_tmp
   CREATE TABLE chave_tmp (
      chave CHAR(11)
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','chave_tmp')
      RETURN FALSE
   END IF  

   DROP TABLE tributo_tmp
   CREATE TABLE tributo_tmp (
      tributo_benef CHAR(11),
      trans_config  INTEGER
   );

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','tributo_tmp')
      RETURN FALSE
   END IF  

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0412_le_param()
#--------------------------#

   SELECT tip_docum,
          tip_solicitacao,
          serie_docum,
          subserie_docum,
          especie_docum
     INTO p_tip_docum,
          p_tip_solic,
          p_ser,
          p_ssr,
          p_esp
     FROM vdp_num_docum
    WHERE empresa = p_cod_empresa
      and tip_docum = 'FATPRDSV'

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Lendo","vdp_num_docum")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
 FUNCTION pol0412_info_preco()                        
#-----------------------------#
    
   INITIALIZE t_fat_emb, p_cod_hist_1, p_tex_hist_1_1,
              p_tex_hist_2_1, p_tex_hist_3_1, p_tex_hist_4_1,
              p_cod_hist_2, p_tex_hist_1_2, p_tex_hist_2_2,
              p_tex_hist_3_2, p_tex_hist_4_2, p_cod_cla_fisc TO NULL

   LET p_pes_unit         = 0 
   LET p_pct_ipi          = 0
   LET p_val_liq_item     = 0 
   LET p_val_ipi          = 0 
   LET p_val_tot_liq      = 0 
   LET p_val_tot_ipi      = 0 
   LET p_val_tot_nff      = 0 
   LET p_val_tot_icm      = 0 
   LET p_saldo            = 0 
   LET p_resto            = 0 
   LET p_houve_erro       = FALSE 

   DELETE FROM wnota

   DECLARE cq_tmp CURSOR FOR
   SELECT DISTINCT
          num_nff,
          cod_cliente
     FROM wnota_cli
   
   FOREACH cq_tmp INTO p_num_nf, p_cod_cliente

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("Lendo","wnota_cli")
         RETURN FALSE
      END IF
   
      DECLARE cq_embal CURSOR FOR
       SELECT b.embalagem, 
              b.qtd_volume
         FROM fat_nf_mestre a,
              fat_nf_embalagem b
        WHERE a.empresa     = p_cod_empresa
          AND a.nota_fiscal = p_num_nf
          AND a.cliente     = p_cod_cliente
          AND a.trans_nota_fiscal = b.trans_nota_fiscal 
          AND a.empresa = b.empresa 

       
      FOREACH cq_embal INTO p_cod_embal, p_qtd_volume

         IF SQLCA.SQLCODE <> 0 THEN 
            CALL log003_err_sql("Lendo","embalagens")
            RETURN FALSE
         END IF

         IF p_qtd_volume > 0 THEN
           
            INSERT INTO wnota 
             VALUES(p_cod_embal, p_qtd_volume) 
         
            IF SQLCA.SQLCODE <> 0 THEN 
               CALL log003_err_sql("Inserindo","wnota")
               RETURN FALSE
            END IF
         
         END IF

      END FOREACH 
      
   END FOREACH 

   DECLARE cu_fat_emb1 CURSOR FOR
   SELECT cod_embal,
          SUM(qtd_volume)
   FROM wnota            
   GROUP BY cod_embal
   ORDER BY cod_embal

   LET p_count = 1
   
   FOREACH cu_fat_emb1 INTO p_cod_embal, p_qtd_volume

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("Lendo","wnota")
         RETURN FALSE
      END IF

      SELECT cod_embal_item
        INTO t_fat_emb[p_count].cod_item
        FROM de_para_embal
      WHERE cod_empresa   = p_cod_empresa
        AND cod_embal_vdp = p_cod_embal
      
      IF t_fat_emb[p_count].cod_item IS NULL THEN
         CONTINUE FOREACH
      END IF

      SELECT den_item 
        INTO t_fat_emb[p_count].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item = t_fat_emb[p_count].cod_item

      LET t_fat_emb[p_count].qtd_item    = p_qtd_volume
      LET t_fat_emb[p_count].pre_unit_nf = 0

      LET p_count = p_count + 1

   END FOREACH 

   LET p_qtd_item = p_count - 1
   
   CALL SET_COUNT(p_count-1)

   LET INT_FLAG = FALSE
   
   INPUT ARRAY t_fat_emb WITHOUT DEFAULTS FROM s_fat_emb.*
    ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
    
      BEFORE ROW
         LET pa_curr = arr_curr()
         LET sc_curr = scr_line()
    
      AFTER FIELD qtd_item
     
      IF t_fat_emb[pa_curr].qtd_item IS NULL THEN 
         LET t_fat_emb[pa_curr].qtd_item = 0
         DISPLAY t_fat_emb[pa_curr].qtd_item TO s_fat_emb[sc_curr].qtd_item
      END IF
      
      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") THEN 
         IF t_fat_emb[pa_curr+1].qtd_item IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD qtd_item   
         END IF  
      END IF  

      AFTER FIELD pre_unit_nf     
    
      IF t_fat_emb[pa_curr].pre_unit_nf IS NULL THEN
         LET t_fat_emb[pa_curr].pre_unit_nf = 0
         DISPLAY t_fat_emb[pa_curr].pre_unit_nf TO
                 s_fat_emb[sc_curr].pre_unit_nf    
      END IF
     
      IF t_fat_emb[pa_curr].qtd_item > 0 AND
         t_fat_emb[pa_curr].pre_unit_nf = 0 THEN
         ERROR "Preco Unitario nao pode ser Zero"
         NEXT FIELD pre_unit_nf
      END IF

      IF FGL_LASTKEY() = FGL_KEYVAL("DOWN") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RIGHT") OR  
         FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN
         IF t_fat_emb[pa_curr+1].qtd_item IS NULL THEN 
            ERROR "Nao Existem mais Registros Nesta Direcao"
            NEXT FIELD pre_unit_nf
         END IF  
      END IF  

   END INPUT

   IF INT_FLAG THEN 
      LET INT_FLAG = 0  
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0412_processa()
#--------------------------#

   IF NOT pol0412_fat_mestre() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0412_le_me() THEN
      RETURN FALSE
   END IF
   
   LET p_tot_peso = 0
   
   FOR p_ind = 1 TO p_qtd_item
       
       IF t_fat_emb[p_ind].cod_item IS NULL THEN
          CONTINUE FOR
       END IF
       
       LET p_cod_item = t_fat_emb[p_ind].cod_item
       
       IF NOT pol0412_le_item() THEN
          RETURN FALSE
       END IF
       
       MESSAGE 'Lendo parâmetros fiscais'
       
       IF NOT pol0412_le_param_fisc() THEN
          RETURN FALSE
       END IF

       LET p_qtd_fat  = t_fat_emb[p_ind].qtd_item
       LET p_pre_unit = t_fat_emb[p_ind].pre_unit_nf
          
       IF NOT pol0412_fat_item() THEN
          RETURN FALSE
       END IF
          
       IF NOT pol0412_item_fisc() THEN
          RETURN FALSE
       END IF

   END FOR

   IF NOT pol0412_mestre_fisc() THEN
      RETURN FALSE
   END IF

   IF NOT pol0412_atu_fat_mestre() THEN
      RETURN FALSE
   END IF

   IF NOT pol0412_ins_embalagem() THEN 
      RETURN FALSE
   END IF

   IF NOT pol0412_grava_texto() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION    

#------------------------------#
FUNCTION pol0412_ins_embalagem()
#------------------------------#

 DEFINE p_qtd_embal DEC(17,6)
   
   LET p_qtd_embal = 0

   SELECT SUM(qtd_item)
     INTO p_qtd_embal 
     FROM fat_nf_item
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf
	
	IF STATUS <> 0 THEN 
	       CALL log003_err_sql('LENDO 2','fat_nf_item')
         RETURN FALSE
	END IF 

   INSERT INTO fat_nf_embalagem  
    VALUES(p_cod_empresa,
           p_trans_nf, 
		       99,
           p_qtd_embal,
           0)
           
	 IF STATUS <> 0 THEN 
	    CALL log003_err_sql('Inserindo','fat_nf_embalagem')
      RETURN FALSE
	 END IF 
   
   RETURN TRUE

END FUNCTION

#--rotinas para leitura dos parâmetros fiscais--#

#-------------------------#
FUNCTION pol0412_le_item()
#-------------------------#

   SELECT cod_lin_prod,                                         
          cod_lin_recei,                                     
          cod_seg_merc,                                      
          cod_cla_uso,                                       
          cod_familia,                                       
          gru_ctr_estoq,                                     
          cod_cla_fisc,                                      
          cod_unid_med,
          pes_unit,
          fat_conver                                      
     INTO p_cod_lin_prod,                                    
          p_cod_lin_recei,                                   
          p_cod_seg_merc,                                    
          p_cod_cla_uso,                                     
          p_cod_familia,                                     
          p_gru_ctr_estoq,                                   
          p_cod_cla_fisc,                                    
          p_cod_unid_med,
          p_pes_unit,
          p_fat_conver                          
     FROM item                                               
    WHERE cod_empresa  = p_cod_empresa                       
      AND cod_item     = p_cod_item          

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0412_le_me()
#-----------------------#

   SELECT tip_parametro
     INTO p_micro_empresa
     FROM vdp_cli_parametro
    WHERE cliente   = p_cod_cliente 
      AND parametro = 'microempresa'
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_cli_parametro')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0412_le_param_fisc()
#-------------------------------#
   
   LET m_msg = NULL
   LET p_sem_tributo = FALSE
   DELETE FROM tributo_tmp
   LET p_ies_tipo = 'S'                   #S-Saida
   
   IF NOT pol0412_le_tip_item() THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(a.tributo_benef)                 #Verifica se tem tribustos 
     INTO p_count                                #cadastrados
     FROM obf_oper_fiscal a, obf_tributo_benef b
    WHERE a.empresa           = p_cod_empresa
      AND a.origem            = p_ies_tipo
      AND a.nat_oper_grp_desp = p_cod_nat_oper
      AND a.tip_Item          IN ('A',p_tip_item) 
      AND b.empresa           = a.empresa 
      AND b.tributo_benef     = a.tributo_benef 
      AND b.ativo             IN ('S','A') 

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tributos')
      RETURN FALSE
   END IF
   
   IF p_count = 0 THEN
      LET m_msg = 'Nenhum tributo foi encontrado na tabela\n',
                  'obf_oper_fiscal para os parmâmetros:\n',
                  'Empresa..:',p_cod_empresa,'\n',
                  'Origem...:',p_ies_tipo,'\n',
                  'Operação.:',p_cod_nat_oper,'\n',
                  'Tipo item: A ou ',p_tip_item,'\n',
                  'Continuar assim mesmo?'
                  
      IF log0040_confirm(20,25,m_msg) THEN
         RETURN TRUE
      ELSE
         RETURN FALSE
      END IF
      
   END IF
   
   LET m_msg = NULL
   
   DECLARE cq_tributos CURSOR FOR                  #Lê os tributos (ICMS/PIS/Etc
    SELECT DISTINCT
           a.tributo_benef
      FROM obf_oper_fiscal a, obf_tributo_benef b
     WHERE a.empresa           = p_cod_empresa
       AND a.origem            = p_ies_tipo
       AND a.nat_oper_grp_desp = p_cod_nat_oper
       AND a.tip_item          IN ('A',p_tip_item) 
       AND b.empresa           = a.empresa 
       AND b.tributo_benef     = a.tributo_benef 
       AND b.ativo             IN ('S','A') 

   FOREACH  cq_tributos INTO
            p_tributo_benef

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_tributos')
         RETURN FALSE
      END IF

      LET p_ies_tributo = FALSE
      
      DECLARE cq_acesso CURSOR FOR
       SELECT num_ctr_acesso,
              sequencia_acesso
         FROM obf_ctr_acesso
        WHERE empresa         = p_cod_empresa
          AND controle_acesso = p_tributo_benef
          AND origem          = p_ies_tipo
        ORDER BY num_ctr_acesso DESC
      
      FOREACH cq_acesso INTO p_num_ctr_acesso, p_seq_acesso
      
         LET p_seq_acesso = p_seq_acesso CLIPPED
         
         IF LENGTH(p_seq_acesso) = 0 THEN
            CONTINUE FOREACH
         END IF
         
         CALL pol0412_pega_chave()

         IF NOT pol0412_checa_tributo() THEN
            RETURN FALSE
         END IF
         
         IF p_ies_tributo THEN
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      IF NOT p_ies_tributo THEN
         
         IF m_msg IS NULL THEN
            LET m_msg = 'Configuração fiscal não encontrada\n',
                        'para o(s) tributo(s) abaixo:\n'
         END IF 
         
         LET m_msg = m_msg CLIPPED, p_tributo_benef,"\n"
         LET p_sem_tributo = TRUE
         
      END IF

   END FOREACH
   
   IF p_sem_tributo THEN
      
      LET m_msg = m_msg CLIPPED,
                 "   Empresa...: ", p_cod_empresa  CLIPPED,"\n",
                 "   Nat oper..: ", p_cod_nat_oper USING '<<<<<<<<&',"\n",
                 "   Carteira..: ", p_wfat.tip_carteira CLIPPED,"\n",
                 "   Finalidade: ", p_wfat.ies_finalidade CLIPPED,"\n",
                 "   Clas fisc.: ", p_cod_cla_fisc  CLIPPED,"\n",
                 "   Linha prod: ", p_cod_lin_prod  USING '<<<<&',"\n",
                 "   Lin recei.: ", p_cod_lin_recei USING '<<<<&',"\n",
                 "   Segto merc: ", p_cod_seg_merc  USING '<<<<&',"\n",
                 "   Classe uso: ", p_cod_cla_uso   USING '<<<<&',"\n",
                 "   Unid med..: ", p_cod_unid_med  CLIPPED,"\n",
                 "   Item......: ", p_cod_item      CLIPPED,"\n",
                 "   Cliente...: ", p_cod_cliente   CLIPPED,"\n"
    
      CALL log0030_mensagem(m_msg,'excla')
      RETURN FALSE

   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0412_le_tip_item()
#----------------------------#

   SELECT parametro_ind
    INTO p_tip_item                       #P-Produto S-Serviço
    FROM vdp_parametro_item 
   WHERE empresa   = p_cod_empresa
     AND item      = p_cod_item
     AND parametro = 'tipo_item'
  
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','vdp_parametro_item')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0412_pega_chave()
#----------------------------#

   DEFINE m_ind       SMALLINT,
          p_letra     CHAR(01)
   
   DELETE FROM chave_tmp
   INITIALIZE p_chave TO NULL
   
   FOR m_ind = 2 TO LENGTH(p_seq_acesso)
       
       LET p_letra = p_seq_acesso[m_ind]
       
       IF p_letra = '|' THEN
          IF p_chave IS NOT NULL THEN
             INSERT INTO chave_tmp VALUES(p_chave)
             INITIALIZE p_chave TO NULL
          END IF
       ELSE
          LET p_chave = p_chave CLIPPED, p_letra
       END IF
   
   END FOR
      
END FUNCTION

#-------------------------------#
FUNCTION pol0412_checa_tributo()
#-------------------------------#

   DEFINE p_chave_ok SMALLINT
   
   LET p_chave_ok = FALSE
   LET p_matriz = 'SSSSSSSSSSSSSSSSSSSSSS'

   LET p_query = 
       "SELECT trans_config FROM obf_config_fiscal ",
       " WHERE empresa = '",p_cod_empresa,"' ",
       " AND origem  = '",p_ies_tipo,"' ",
       " AND tributo_benef = '",p_tributo_benef,"' "
       

   DECLARE cq_chave CURSOR FOR
    SELECT chave
      FROM chave_tmp
   
   FOREACH cq_chave INTO p_chave
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_chave')
         RETURN FALSE
      END IF
      
      LET p_chave_ok = TRUE
      
      CASE p_chave
      
      WHEN 'NAT_OPER' 
         LET p_query  = p_query CLIPPED, " AND nat_oper_grp_desp = '",p_cod_nat_oper,"' "
         LET p_matriz[1] = 'N'
      
      WHEN 'REGIAO' 
         IF NOT pol0412_le_obf_regiao() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_regiao = '",p_regiao_fiscal,"' "
         LET p_matriz[2] = 'N'

      WHEN 'ESTADO'
         LET p_query  = p_query CLIPPED, " AND estado = '",p_cod_uni_feder,"' "
         LET p_matriz[3] = 'N'

      WHEN 'MUNICIPIO' 
         LET p_query  = p_query CLIPPED, " AND municipio = '",p_cod_cidade,"' "
         LET p_matriz[4] = 'N'

      WHEN 'CARTEIRA' 
         LET p_query  = p_query CLIPPED, " AND carteira = '",p_wfat.tip_carteira,"' "
         LET p_matriz[5] = 'N'

      WHEN 'FINALIDADE' 
         LET p_query  = p_query CLIPPED, " AND finalidade = '",p_wfat.ies_finalidade,"' "
         LET p_matriz[6] = 'N'

      WHEN 'FAMILIA_IT' 
         LET p_query  = p_query CLIPPED, " AND familia_item = '",p_cod_familia,"' "
         LET p_matriz[7] = 'N'

      WHEN 'GRP_ESTOQUE' 
         LET p_query  = p_query CLIPPED, " AND grupo_estoque = '",p_gru_ctr_estoq,"' "
         LET p_matriz[8] = 'N'

      WHEN 'GRP_CLASSIF' 
         IF NOT pol0412_le_obf_cl_fisc() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_classif = '",p_grp_classif_fisc,"' "
         LET p_matriz[9] = 'N'

      WHEN 'CLAS_FISC' 
         LET p_query  = p_query CLIPPED, " AND classif_fisc = '",p_cod_cla_fisc,"' "
         LET p_matriz[10] = 'N'

      WHEN 'LIN_PROD' 
         LET p_query  = p_query CLIPPED, " AND linha_produto = '",p_cod_lin_prod,"' "
         LET p_matriz[11] = 'N'

      WHEN 'LIN_REC' 
         LET p_query  = p_query CLIPPED, " AND linha_receita = '",p_cod_lin_recei,"' "
         LET p_matriz[12] = 'N'

      WHEN 'SEGTO_MERC' 
         LET p_query  = p_query CLIPPED, " AND segmto_mercado = '",p_cod_seg_merc,"' "
         LET p_matriz[13] = 'N'

      WHEN 'CLASSE_USO' 
         LET p_query  = p_query CLIPPED, " AND classe_uso = '",p_cod_cla_uso,"' "
         LET p_matriz[14] = 'N'

      WHEN 'UNID_MED' 
         LET p_query  = p_query CLIPPED, " AND unid_medida = '",p_cod_unid_med,"' "
         LET p_matriz[15] = 'N'

      WHEN 'GRP_ITEM' 
         IF NOT pol0412_le_obf_fisc_item() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grupo_fiscal_item = '",p_grp_fiscal_item,"' "
         LET p_matriz[17] = 'N'

      WHEN 'ITEM' 
         LET p_query  = p_query CLIPPED, " AND item = '",p_cod_item,"' "
         LET p_matriz[18] = 'N'

      WHEN 'MICRO_EMPR' 
         LET p_query  = p_query CLIPPED, " AND micro_empresa = '",p_micro_empresa,"' "
         LET p_matriz[19] = 'N'

      WHEN 'GRP_CLIENTE' 
         IF NOT pol0412_le_obf_fisc_cli() THEN
            RETURN FALSE
         END IF
         LET p_query  = p_query CLIPPED, " AND grp_fiscal_cliente = '",p_grp_fisc_cliente,"' "
         LET p_matriz[20] = 'N'

      WHEN 'CLIENTE' 
         LET p_query  = p_query CLIPPED, " AND cliente = '",p_cod_cliente,"' "
         LET p_matriz[21] = 'N'

      WHEN 'X'
      WHEN 'BONIF'
      WHEN 'VIA_TRANSP'
      
      OTHERWISE 
         LET p_chave_ok = FALSE
  
   END CASE
   
   END FOREACH

   IF p_chave_ok THEN

      LET p_query  = p_query CLIPPED, 
          " AND (matriz = '",p_matriz,"' OR matriz IS NULL) "
   
      PREPARE var_query FROM p_query   
      DECLARE cq_obf_cfg CURSOR FOR var_query

      FOREACH cq_obf_cfg INTO p_trans_config

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('Lendo','cq_obf_cfg')
            RETURN FALSE
         END IF
         
         INSERT INTO tributo_tmp
          VALUES(p_tributo_benef, p_trans_config)

         IF STATUS <> 0 THEN 
            CALL log003_err_sql('inserindo','tributo_tmp')
            RETURN FALSE
         END IF
          
         LET p_ies_tributo = TRUE
         
         EXIT FOREACH
      
   
      END FOREACH
   
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0412_le_obf_regiao()
#-------------------------------#

   SELECT regiao_fiscal
     INTO p_regiao_fiscal
     FROM obf_regiao_fiscal
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND municipio     = p_cod_cidade
   
   IF STATUS = 100 THEN
      SELECT regiao_fiscal
        INTO p_regiao_fiscal
        FROM obf_regiao_fiscal
       WHERE empresa       = p_cod_empresa
         AND tributo_benef = p_tributo_benef
         AND estado        = p_cod_uni_feder
      
      IF STATUS = 100 THEN
         LET p_regiao_fiscal = NULL
      END IF
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo', 'obf_regiao_fiscal')
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#-------------------------------#
FUNCTION pol0412_le_obf_cl_fisc()
#-------------------------------#

   SELECT grupo_classif_fisc
     INTO p_grp_classif_fisc
     FROM obf_grp_cl_fisc
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND classif_fisc  = p_cod_cla_fisc
   
   IF STATUS = 100 THEN
      LET p_grp_classif_fisc = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_regiao_fiscal')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0412_le_obf_fisc_item()
#---------------------------------#

   SELECT grupo_fiscal_item
     INTO p_grp_fiscal_item
     FROM obf_grp_fisc_item
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND item          = p_cod_item
   
   IF STATUS = 100 THEN
      LET p_grp_fiscal_item = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_item')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------------#
FUNCTION pol0412_le_obf_fisc_cli()
#---------------------------------#

   SELECT grp_fiscal_cliente
     INTO p_grp_fisc_cliente
     FROM obf_grp_fisc_cli
    WHERE empresa       = p_cod_empresa
      AND tributo_benef = p_tributo_benef
      AND cliente       = p_cod_cliente
   
   IF STATUS = 100 THEN
      LET p_grp_fisc_cliente = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'obf_grp_fisc_cli')
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
         
END FUNCTION

#---------------------------#
FUNCTION pol0412_fat_mestre()
#---------------------------#

   MESSAGE 'Gravando fat_nf_mestre!'
   
   INITIALIZE p_fat_mestre TO NULL
   
   LET p_fat_mestre.empresa            =  p_cod_empresa            
   LET p_fat_mestre.trans_nota_fiscal  =  0                        
   LET p_fat_mestre.tip_nota_fiscal    =  p_tip_solic              
   LET p_fat_mestre.serie_nota_fiscal  =  p_ser                    
   LET p_fat_mestre.subserie_nf        =  p_ssr                    
   LET p_fat_mestre.espc_nota_fiscal   =  p_esp                    
   LET p_fat_mestre.nota_fiscal        =  p_wfat.num_solicit              
   LET p_fat_mestre.status_nota_fiscal =  'S'                      
   LET p_fat_mestre.modelo_nota_fiscal =  '1'                      
   LET p_fat_mestre.origem_nota_fiscal =  'M'                      
   LET p_fat_mestre.tip_processamento  =  'A'                      
   LET p_fat_mestre.sit_nota_fiscal    =  'N'                      
   LET p_fat_mestre.cliente            =  p_cod_cliente            
   LET p_fat_mestre.remetent           =  ' '                      
   LET p_fat_mestre.zona_franca        =  'N'                      
   LET p_fat_mestre.natureza_operacao  =  p_cod_nat_oper           
   LET p_fat_mestre.finalidade         =  p_wfat.ies_finalidade         
   LET p_fat_mestre.cond_pagto         =  p_cod_cnd_pgto           
   LET p_fat_mestre.tip_carteira       =  p_wfat.tip_carteira       
   LET p_fat_mestre.ind_despesa_financ =  1                        
   LET p_fat_mestre.moeda              =  p_wfat.cod_moeda                        
   LET p_fat_mestre.plano_venda        =  'N'                      
   LET p_fat_mestre.tip_frete          =  p_wfat.tip_frete  
   LET p_fat_mestre.via_transporte     =  p_wfat.via_transp                       
   LET p_fat_mestre.peso_liquido       =  0                        
   LET p_fat_mestre.peso_bruto         =  0                        
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
   LET p_fat_mestre.val_mercadoria     =  0                        
   LET p_fat_mestre.val_duplicata      =  0                        
   LET p_fat_mestre.val_nota_fiscal    =  0                        
   LET p_fat_mestre.tip_venda          =  1                        
                                                                   
   INSERT INTO fat_nf_mestre VALUES (p_fat_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_nf_mestre')
      RETURN FALSE
   END IF
   
   LET p_trans_nf = SQLCA.SQLERRD[2]
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0412_fat_item()
#--------------------------#

   MESSAGE 'Gravando fat_nf_item!'
   
   INITIALIZE p_fat_item TO NULL

   IF NOT pol0412_le_item() THEN
      RETURN FALSE
   END IF

   IF NOT pol0412_le_tip_item() THEN
      RETURN FALSE
   END IF
   
   LET p_tot_peso = p_tot_peso + (p_qtd_fat * p_pes_unit)
   
   LET p_fat_item.empresa              = p_cod_empresa                
   LET p_fat_item.trans_nota_fiscal    = p_trans_nf                   
   LET p_fat_item.seq_item_nf          = p_ind                        
   LET p_fat_item.pedido               = 0                            
   LET p_fat_item.seq_item_pedido      = 0                            
   LET p_fat_item.ord_montag           = 0                            
   LET p_fat_item.tip_item             = 'N'                          
   LET p_fat_item.item                 = p_cod_item                   
   LET p_fat_item.des_item             = t_fat_emb[p_ind].den_item    
   LET p_fat_item.unid_medida          = p_cod_unid_med               
   LET p_fat_item.peso_unit            = p_pes_unit                   
   LET p_fat_item.qtd_item             = p_qtd_fat                    
   LET p_fat_item.fator_conv           = p_fat_conver                 
   LET p_fat_item.tip_preco            = 'F'                          
   LET p_fat_item.natureza_operacao    = p_cod_nat_oper               
   LET p_fat_item.classif_fisc         = p_cod_cla_fisc               
   LET p_fat_item.item_prod_servico    = p_tip_item               
   LET p_fat_item.preco_unit_bruto     = p_pre_unit   
   LET p_fat_item.pre_uni_desc_incnd   = p_pre_unit   
   LET p_fat_item.preco_unit_liquido   = p_pre_unit   
   LET p_fat_item.pct_frete            = 0   
   LET p_fat_item.val_desc_item        = 0   
   LET p_fat_item.val_desc_merc        = 0   
   LET p_fat_item.val_desc_contab      = 0   
   LET p_fat_item.val_desc_duplicata   = 0   
   LET p_fat_item.val_acresc_item      = 0   
   LET p_fat_item.val_acre_merc        = 0   
   LET p_fat_item.val_acresc_contab    = 0   
   LET p_fat_item.val_acre_duplicata   = 0     
   LET p_fat_item.val_fret_consig      = 0   
   LET p_fat_item.val_segr_consig      = 0   
   LET p_fat_item.val_frete_cliente    = 0   
   LET p_fat_item.val_seguro_cliente   = 0   

   LET p_val_item = p_qtd_fat * p_pre_unit

   LET p_fat_item.val_bruto_item       = p_val_item
   LET p_fat_item.val_brt_desc_incnd   = p_val_item
   LET p_fat_item.val_liquido_item     = p_val_item
   LET p_fat_item.val_merc_item        = p_val_item
   LET p_fat_item.val_duplicata_item   = p_val_item
   LET p_fat_item.val_contab_item      = p_val_item
               
   INSERT INTO fat_nf_item VALUES(p_fat_item.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_nf_item')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0412_item_fisc()
#---------------------------#

   MESSAGE 'LENDO TRIBUTOS!'

   SELECT DISTINCT cod_fiscal 
     INTO p_cod_fiscal
     FROM obf_config_fiscal 
    WHERE empresa = p_cod_empresa
      AND cod_fiscal IS NOT NULL  
      AND trans_config IN 
         (SELECT trans_config FROM tributo_tmp)
   
   DECLARE cq_if CURSOR FOR
    SELECT tributo_benef,
           trans_config
      FROM tributo_tmp

   FOREACH cq_if INTO p_tributo_benef, p_trans_config
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','tributo_tmp')
         RETURN FALSE
      END IF
      
      IF NOT pol0412_ins_fisc() THEN
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION
        
#---------------------------#
FUNCTION pol0412_ins_fisc()
#---------------------------#

   DEFINE p_incide    LIKE obf_config_fiscal.incide,             
          p_aliquota  LIKE obf_config_fiscal.aliquota        

   MESSAGE 'Gravando fat_nf_item!'
   
   INITIALIZE p_item_fisc TO NULL

   SELECT incide,                      
          aliquota, 
          acresc_desc,              
          aplicacao_val,               
          origem_produto,              
          hist_fiscal,                 
          sit_tributo,                 
          inscricao_estadual,          
          dipam_b,                     
          retencao_cre_vdp,            
          motivo_retencao,             
          val_unit,                    
          pre_uni_mercadoria,          
          pct_aplicacao_base,          
          pct_acre_bas_calc,           
          pct_diferido_base,           
          pct_diferido_val,            
          pct_acresc_val,              
          pct_reducao_val,             
          pct_margem_lucro,            
          pct_acre_marg_lucr,          
          pct_red_marg_lucro,          
          taxa_reducao_pct,            
          taxa_acresc_pct
     INTO p_incide,                    
          p_aliquota,
          p_item_fisc.acresc_desc,               
          p_item_fisc.aplicacao_val,             
          p_item_fisc.origem_produto,            
          p_item_fisc.hist_fiscal,               
          p_item_fisc.sit_tributo,               
          p_item_fisc.inscricao_estadual,        
          p_item_fisc.dipam_b,                   
          p_item_fisc.retencao_cre_vdp,          
          p_item_fisc.motivo_retencao,           
          p_item_fisc.val_unit,                  
          p_item_fisc.pre_uni_mercadoria,        
          p_item_fisc.pct_aplicacao_base,        
          p_item_fisc.pct_acre_bas_calc,         
          p_item_fisc.pct_diferido_base,         
          p_item_fisc.pct_diferido_val,          
          p_item_fisc.pct_acresc_val,            
          p_item_fisc.pct_reducao_val,           
          p_item_fisc.pct_margem_lucro,          
          p_item_fisc.pct_acre_marg_lucr,        
          p_item_fisc.pct_red_marg_lucro,        
          p_item_fisc.taxa_reducao_pct,          
          p_item_fisc.taxa_acresc_pct            
     FROM obf_config_fiscal
    WHERE empresa      = p_cod_empresa
      AND trans_config = p_trans_config                             

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','obf_config_fiscal')
      RETURN FALSE
   END IF
 
   LET p_item_fisc.empresa              = p_cod_empresa   
   LET p_item_fisc.trans_nota_fiscal    = p_trans_nf      
   LET p_item_fisc.seq_item_nf          = p_ind           
   LET p_item_fisc.incide               = p_incide        
   LET p_item_fisc.aliquota             = p_aliquota      
   LET p_item_fisc.tributo_benef        = p_tributo_benef 
   LET p_item_fisc.trans_config         = p_trans_config  
   LET p_item_fisc.bc_trib_mercadoria   = p_val_item                   
   LET p_item_fisc.bc_tributo_frete     = 0                               
   LET p_item_fisc.bc_trib_calculado    = 0                            
   LET p_item_fisc.bc_tributo_tot       = p_val_item                   
   LET p_item_fisc.val_trib_merc        = p_val_item * p_aliquota / 100
   LET p_item_fisc.val_tributo_frete    = 0                               
   LET p_item_fisc.val_trib_calculado   = 0                            
   LET p_item_fisc.val_tributo_tot      = p_item_fisc.val_trib_merc    
   LET p_item_fisc.cod_fiscal           = p_cod_fiscal
      
   INSERT INTO fat_nf_item_fisc
      VALUES(p_item_fisc.*)
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_nf_item_fisc')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0412_mestre_fisc()
#-----------------------------#

   MESSAGE 'Gravando fat_mestre_fiscal!'
   
   INITIALIZE p_mest_fisc TO NULL

   LET p_mest_fisc.empresa            = p_cod_empresa  
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
   
   END FOREACH
    
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0412_atu_fat_mestre()
#--------------------------------#

   MESSAGE 'Atualizando fat_nf_mestre!'

   UPDATE fat_nf_mestre
      SET peso_bruto      = p_tot_peso,
          peso_liquido    = p_tot_peso,
          val_mercadoria  = p_mest_fisc.bc_trib_mercadoria,
          val_duplicata   = p_mest_fisc.bc_trib_mercadoria,
          val_nota_fiscal = p_mest_fisc.bc_trib_mercadoria
    WHERE empresa = p_cod_empresa
      AND trans_nota_fiscal = p_trans_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','fat_nf_mestre')
      RETURN FALSE
   END IF
    
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0412_grava_texto()
#----------------------------#
   
   MESSAGE 'Inserindo texto!'
   
   LET p_ind = 0
   
   INITIALIZE p_txt_hist TO NULL
   LET p_txt_hist.empresa = p_cod_empresa
   LET p_txt_hist.trans_nota_fiscal = p_trans_nf
   
   IF LENGTH(p_texto.des_texto) > 0 THEN
      LET p_txt_hist.texto      = p_texto.cod_texto
      LET p_txt_hist.des_texto  = p_texto.des_texto
      LET p_txt_hist.tip_txt_nf = 1
      IF NOT pol0412_ins_texto() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF LENGTH(p_texto.tex_obs) > 0 THEN
      IF p_txt_hist.texto IS NULL THEN
         LET p_txt_hist.texto =  1
      ELSE
         LET p_txt_hist.texto = p_txt_hist.texto + 1
      END IF
      LET p_txt_hist.des_texto  = p_texto.tex_obs
      LET p_txt_hist.tip_txt_nf = 2
      IF NOT pol0412_ins_texto() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0412_ins_texto()
#---------------------------#

   LET p_ind = p_ind + 1
   LET p_txt_hist.sequencia_texto = p_ind

   INSERT INTO fat_nf_texto_hist
    VALUES(p_txt_hist.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','fat_nf_texto_hist')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

   


#----------------------------- FIM DE PROGRAMA --------------------------------#
