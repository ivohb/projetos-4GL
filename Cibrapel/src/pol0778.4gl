#-------------------------------------------------------------------#
# PROGRAMA: pol0778                                                 #
# OBJETIVO: FRETE DE SAIDA - CIBRAPEL                               #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 18/03/2008                                              #
# CONVERSÃO 10.02: 11/12/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_dat_movto          DATE,
          p_retorno            SMALLINT,
          p_val_icms_c         DECIMAL(10,2),
          p_imprimiu           SMALLINT,
          p_msg                CHAR(150),
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_negrito            CHAR(02),
          p_normal             CHAR(02),
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_ies_conf           SMALLINT,
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_query              CHAR(600),
          where_clause         CHAR(500),
          p_ies_efetivado      CHAR(01)

END GLOBALS

DEFINE    p_num_nf             LIKE nf_sup.num_nf,
          p_ser_nf             LIKE nf_sup.ser_nf,
          p_ssr_nf             LIKE nf_sup.ssr_nf,
          p_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
          p_dat_entrada_nf     LIKE nf_sup.dat_entrada_nf,
          p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          p_val_nf             LIKE nf_sup.val_tot_nf_c,
          p_cnd_pgto_nf        LIKE nf_sup.cnd_pgto_nf,
          p_cod_empresa_estab  LIKE nf_sup.cod_empresa_estab,
          p_especie            LIKE nf_sup.ies_especie_nf,
          p_num_ap             LIKE ap.num_ap,
          p_num_ad             LIKE ad_mestre.num_ad,
          p_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa,
          p_num_conta_cred     LIKE grupo_despesa.num_conta_fornec,
          p_num_conta_deb      LIKE dest_aviso_rec.num_conta_deb_desp,
          p_val_movto          LIKE aviso_rec.val_liquido_item,
          p_cod_emp_orig       LIKE empresa.cod_empresa,
          p_qtd_dias           LIKE cond_pg_item_cap.qtd_dias,
          p_val_gravado        LIKE aviso_rec.val_liquido_item,
          p_pct_val_vencto     LIKE cond_pg_item_cap.pct_val_vencto,
          p_raz_social         LIKE fornecedor.raz_social,
          p_cod_hist_deb_ap    LIKE tipo_despesa.cod_hist_deb_ap,
          p_cod_grp_despesa    LIKE grupo_despesa.cod_grp_despesa

DEFINE p_dat_vencto         DATETIME YEAR TO DAY,
       p_hora               DATETIME HOUR TO SECOND,
       p_num_parcela        SMALLINT,
       p_qtd_parcelas       INTEGER,
       p_val_parcela        DECIMAL(15,2)

   DEFINE p_nom_reduzido       LIKE clientes.nom_reduzido,
          p_cod_transpor       LIKE clientes.cod_cliente,
          p_cod_cliente        LIKE clientes.cod_cliente,
          p_num_pedido         LIKE pedidos.num_pedido,
          p_num_docum          LIKE nf_sup.num_nf,
          p_num_seq            LIKE ped_itens.num_sequencia,
          p_cod_cidade         LIKE cidades.cod_cidade,
          p_num_chapa          LIKE frete_solicit_885.num_chapa,
          p_num_solicit        LIKE frete_solicit_885.num_solicit,
          p_num_sequencia      LIKE frete_solicit_885.num_sequencia,
          p_num_solicit_ant    LIKE frete_solicit_885.num_solicit,
          p_num_sequencia_ant  LIKE frete_solicit_885.num_sequencia,
          p_num_prx_ar         LIKE aviso_rec.num_aviso_rec,
          p_val_soma           LIKE frete_solicit_885.val_frete_ofic,
          p_num_om             LIKE ordem_montag_mest.num_om,
          p_num_nff            LIKE nf_mestre.num_nff,
          p_num_nota           LIKE nf_mestre.num_nff,
          p_num_conhec         LIKE frete_sup_x_nff.num_conhec,
          p_ser_conhec         LIKE frete_sup_x_nff.ser_conhec,
          p_ssr_conhec         LIKE frete_sup_x_nff.ssr_conhec,
          p_tot_frete          LIKE frete_solicit_885.val_frete,
          p_num_aviso_rec      LIKE nf_sup.num_aviso_rec,
          p_num_aviso_ger      LIKE nf_sup.num_aviso_rec,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_val_liq            LIKE aviso_rec.val_liquido_item,
          p_val_contrat        LIKE aviso_rec.val_liquido_item,
          p_val_tot_icms_nf_c  LIKE nf_sup.val_tot_icms_nf_c,
          p_val_tot_nf_c       LIKE nf_sup.val_tot_nf_c,
          p_ies_nf_com_erro    LIKE nf_sup.ies_nf_com_erro,
          p_ies_situacao       LIKE nf_mestre.ies_situacao,
          p_ser_nff            LIKE nf_mestre.ser_nff,
          p_nom_transpor       CHAR(30),
          p_tip_docum          CHAR(01),
          p_dat_cadastro       DATE,
          p_zoom               SMALLINT,
          p_flag               CHAR(01),
          p_tot_relac          DECIMAL(10,2),
          p_val_tot_cop        DECIMAL(10,2),
          p_tot_frete_rod      DECIMAL(09,2),
          p_tot_frete_ger      DECIMAL(09,2),
          p_tot_frete_tot      DECIMAL(09,2),
          p_soma_nfs           DECIMAL(09,2),
          p_val_devido         DECIMAL(09,2),
          p_pct_desc           DECIMAL(05,2),
          p_val_normal         DECIMAL(08,2),
          p_val_ger            DECIMAL(08,2),
          p_ies_validado       CHAR(01),
          p_chave              CHAR(500),          
          p_tip_transp         CHAR(02),
          p_tip_transp_auto    CHAR(02),
          p_dat_ini            DATE,
          p_dat_fim            DATE,
          p_dat_ant            DATE,
          p_dat_dep            DATE
          
   DEFINE p_nf_sup             RECORD LIKE nf_sup.*,
          p_aviso_rec          RECORD LIKE aviso_rec.*,
          p_ar_compl           RECORD LIKE aviso_rec_compl.*,
          p_dest_ar            RECORD LIKE dest_aviso_rec.*,
          p_audit_ar           RECORD LIKE audit_ar.*,
          p_ar_sq              RECORD LIKE aviso_rec_compl_sq.*,
          p_frete_sup          RECORD LIKE frete_sup.*,
          p_dest_frete_sup     RECORD LIKE dest_frete_sup.*,
          p_pedagio_frete      RECORD LIKE pedagio_frete.*,
          p_frete_sup_compl    RECORD LIKE frete_sup_compl.*,
          p_sup_par_frete      RECORD LIKE sup_par_frete.*,
          p_audit_frete        RECORD LIKE audit_frete.*,
          p_frete_sup_erro     RECORD LIKE frete_sup_erro.*,
          p_frete_solicit      RECORD LIKE frete_solicit_885.*,
          p_ad_mestre          RECORD LIKE ad_mestre_885.*,
          p_ap                 RECORD LIKE ap_885.*,
          p_lanc_cont_cap      RECORD LIKE lanc_cont_cap_885.*


   DEFINE p_nota         RECORD
          num_nfe        LIKE nfe_x_nff_885.num_nfe,
          cod_for        LIKE fornecedor.cod_fornecedor,
          nom_for        LIKE fornecedor.raz_social,
          pct_desc       LIKE desc_transp_885.pct_desc,
          dat_nfe        LIKE nf_sup.dat_emis_nf,
          ser_nfe        LIKE nfe_x_nff_885.ser_nfe,
          ssr_nfe        LIKE nfe_x_nff_885.ser_nfe,
          esp_nfe        LIKE nf_sup.ies_especie_nf,
          val_nfe        LIKE nf_sup.val_tot_nf_c,
          val_icm        LIKE nf_sup.val_tot_nf_c
   END RECORD

   DEFINE pr_nota        ARRAY[1000] OF RECORD
          num_nff        LIKE nf_mestre.num_nff,
          val_frete_rod  DECIMAL(08,2),
          val_frete_ger  DECIMAL(08,2),
          val_frete_tot  DECIMAL(08,2),
          pes_tot_bruto  DECIMAL(09,3),
          nom_reduzido   LIKE clientes.nom_reduzido,
          den_cidade     LIKE cidades.den_cidade
   END RECORD

   DEFINE p_info        RECORD
      dat_ini           DATE,
      dat_fim           DATE,
      cod_transpor      CHAR(15),
      nom_transpor      CHAR(15),
      num_conhec        DECIMAL(6,0),
      ser_conhec        CHAR(03),
      ssr_conhec        DECIMAL(2,0),
      dat_emissao       DATE,
      val_frete_c       DECIMAL(8,2),
      val_icms          DECIMAL(8,2)
   END RECORD 

   DEFINE p_edita        RECORD
          ies_validado   CHAR(01),
          num_solicit    INTEGER,
          num_chapa      CHAR(07),
          cod_veiculo    CHAR(15),
          cod_tip_carga  CHAR(01),
          val_frete_tab  DECIMAL(9,2),
          val_frete      DECIMAL(9,2),
          val_frete_ofic DECIMAL(9,2),
          val_frete_ger  DECIMAL(9,2)
   END RECORD 

   DEFINE pr_conf        ARRAY[1000] OF RECORD
          num_nff        DECIMAL(6,0),
          peso_nff       DECIMAL(7,3),
          cod_cliente    CHAR(15),
          cid_destino    CHAR(12),
          val_cotacao    DECIMAL(6,2),
          val_tab        DECIMAL(6,2),
          val_nor        DECIMAL(6,2),
          val_ger        DECIMAL(6,2)
   END RECORD

   DEFINE p_transp      RECORD
      cod_transpor      LIKE clientes.cod_cliente,
      num_chapa         LIKE frete_solicit_885.num_chapa
   END RECORD 

   DEFINE pr_conhec      ARRAY[500] OF RECORD
          num_nff        DECIMAL(6,0),
          val_frete_rod  DECIMAL(9,2),
          val_compl      DECIMAL(9,2),
          pes_nf         DECIMAL(9,3),
          nom_cliente    CHAR(15),
          cid_destino    CHAR(20)
   END RECORD

   DEFINE pr_solic       ARRAY[500] OF RECORD
          dat_cadastro   CHAR(10),
          num_chapa      LIKE frete_solicit_885.num_chapa,
          cod_transpor   LIKE frete_solicit_885.cod_transpor,
          num_solicit    LIKE frete_solicit_885.num_solicit,
          num_sequencia  LIKE frete_solicit_885.num_sequencia
   END RECORD

   DEFINE p_relat       RECORD
         num_romaneio   INTEGER,
         dat_movto      DATETIME YEAR TO DAY,
         num_nff        DECIMAL(6,0),
         pes_nf         DECIMAL(10,3),
         nom_cliente    CHAR(15),
         cid_destino    CHAR(16),
         num_chapa      CHAR(07),
         cod_veiculo    CHAR(07),
         tip_carga      CHAR(01),
         val_frete_ofic DECIMAL(9,2),
         val_frete_ger  DECIMAL(9,2),
         preco_compl    DECIMAL(9,2),
         val_frete      DECIMAL(9,2),
         val_tabela     DECIMAL(9,2),
         seq_impres     INTEGER
   END RECORD 


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "POL0778-10.02.01  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0778.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0  THEN
      CALL pol0778_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0778_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0778") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0778 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0778_le_parametros() THEN
      RETURN
   END IF

   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados enviados pelo Trim"
         CALL pol0778_consultar()
      COMMAND "Listar" "Listagem de fretes p/ conferência"
         IF log005_seguranca(p_user,"VDP","pol0778","IN")  THEN
            CALL pol0778_listagem()
         END IF 
      COMMAND "NotaDeServiço" "Pagamento de fretes c/ NF de Serviço"
         CALL pol0778_notas()
      {COMMAND "Conhecimento" "Pagamento de fretes c/ conhecimento de frete"
         CALL pol0778_conhec()}
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol0778

END FUNCTION

#-------------------------------#
FUNCTION pol0778_le_parametros()
#-------------------------------#

   SELECT substring(par_vdp_txt,215,2)
     INTO p_tip_transp
     FROM par_vdp
    WHERE cod_empresa = p_cod_empresa
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp')
      RETURN FALSE
   END IF

   SELECT par_txt
     INTO p_tip_transp_auto
     FROM par_vdp_pad
    WHERE cod_empresa   = p_cod_empresa
      AND cod_parametro = 'cod_tip_transp_aut'
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','par_vdp_pad')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0778_consultar()
#---------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07783") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07783 AT 3,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_num_solicit TO NULL
   LET INT_FLAG = FALSE
   
   INPUT p_num_solicit
      WITHOUT DEFAULTS FROM numromaneio

      AFTER FIELD numromaneio
         SELECT num_sequencia,
                dat_cadastro
           INTO p_num_sequencia,
                p_dat_cadastro
           FROM frete_solicit_885
          WHERE cod_empresa = p_cod_empresa
            AND num_solicit = p_num_solicit
         
         IF sqlca.sqlcode = 100 THEN
            ERROR 'Romaneio inexistente ou não integrado !!!'
            NEXT FIELD numromaneio
         ELSE
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql('Lendo','frete_solicit_885')
               EXIT INPUT
            END IF
         END IF
         
         DISPLAY p_dat_cadastro TO datcadastro
         
         IF p_num_solicit IS NOT NULL THEN
            IF NOT pol0778_mostra_dados() THEN
               EXIT INPUT
            END IF
         END IF
         
         NEXT FIELD numromaneio

   END INPUT
   
   CLOSE WINDOW w_pol07782

END FUNCTION

#-----------------------------#
FUNCTION pol0778_mostra_dados()
#-----------------------------#

   DEFINE p_romaneio     RECORD
          despachante    LIKE romaneio_885.despachante,
          coderptranspor LIKE romaneio_885.coderptranspor,
          nomreduzido    LIKE clientes.nom_reduzido,
          placaveiculo   LIKE romaneio_885.placaveiculo,
          codveiculo     LIKE romaneio_885.codveiculo,
          codtipcarga    LIKE romaneio_885.codtipcarga,
          pesobalanca    LIKE romaneio_885.pesobalanca,
          pesocarregado  LIKE romaneio_885.pesocarregado,
          codtipfrete    LIKE romaneio_885.codtipfrete,
          valfrete       LIKE romaneio_885.valfrete,
          pctdesc        LIKE desc_nat_oper_885.pct_desc_valor,
          cidadebase     LIKE romaneio_885.codciddest,
          nomcidade      LIKE cidades.den_cidade
   END RECORD 

   DEFINE pr_itens       ARRAY[500] OF RECORD
          numpedido      LIKE roma_item_885.numpedido,
          numseqitem     LIKE roma_item_885.numseqitem,
          coditem        LIKE roma_item_885.coditem,
          codciddest     LIKE roma_item_885.codciddest,
          cidadedestino  LIKE cidades.den_cidade,
          pesobrutoitem  LIKE roma_item_885.pesobrutoitem
   END RECORD

   SELECT despachante,
          coderptranspor,
          codtipfrete,
          valfrete,
          codciddest,
          codveiculo,
          codtipcarga,
          placaveiculo,
          pesobalanca,
          pesocarregado
     INTO p_romaneio.despachante,
          p_romaneio.coderptranspor,
          p_romaneio.codtipfrete,
          p_romaneio.valfrete,
          p_romaneio.cidadebase,
          p_romaneio.codveiculo,
          p_romaneio.codtipcarga,
          p_romaneio.placaveiculo,
          p_romaneio.pesobalanca,
          p_romaneio.pesocarregado
     FROM romaneio_885
    WHERE codempresa   = p_cod_empresa
      AND numsequencia = p_num_sequencia
    
   IF sqlca.sqlcode = 100 THEN
      CALL log0030_mensagem('Dados do Trim não localizado','excla')
      RETURN TRUE
   ELSE
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','romaneio_885')
         RETURN FALSE
      END IF
   END IF
   
   SELECT nom_reduzido
     INTO p_romaneio.nomreduzido
     FROM clientes
    WHERE cod_cliente = p_romaneio.coderptranspor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','clientes')
      RETURN FALSE
   END IF
   
   SELECT den_cidade
     INTO p_romaneio.nomcidade
     FROM cidades
    WHERE cod_cidade = p_romaneio.cidadebase
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','cidades')
      RETURN FALSE
   END IF
   
   SELECT pct_desc
     INTO p_romaneio.pctdesc
     FROM desc_transp_885
    WHERE cod_empresa  = p_cod_empresa
      AND cod_transpor = p_romaneio.coderptranspor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','desc_transp_885')
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_romaneio.*
   
   LET p_ind = 1
   
   INITIALIZE pr_itens TO NULL
   
   DECLARE cq_itens CURSOR FOR
    SELECT numpedido,
           numseqitem,
           coditem,
           codciddest,
           pesobrutoitem
      FROM roma_item_885
     WHERE codempresa  = p_cod_empresa
       AND numseqpai   = p_num_sequencia
   
   FOREACH cq_itens INTO 
          pr_itens[p_ind].numpedido,
          pr_itens[p_ind].numseqitem,
          pr_itens[p_ind].coditem,
          pr_itens[p_ind].codciddest,
          pr_itens[p_ind].pesobrutoitem

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','cq_itens')
         RETURN FALSE
      END IF
      
      SELECT den_cidade
        INTO pr_itens[p_ind].cidadedestino
        FROM cidades
       WHERE cod_cidade = pr_itens[p_ind].codciddest
       
      IF sqlca.sqlcode = 100 THEN
         LET pr_itens[p_ind].cidadedestino = NULL
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','cidades')
            RETURN FALSE
         END IF
      END IF

      LET p_ind = p_ind + 1
      
   END FOREACH
   
   LET p_index = p_ind - 1
   
   CALL SET_COUNT(p_ind - 1)
   
   IF p_index > 8 THEN
      DISPLAY ARRAY pr_itens TO sr_itens.*       
   ELSE
      INPUT ARRAY pr_itens 
         WITHOUT DEFAULTS FROM sr_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
   RETURN TRUE       

END FUNCTION

#--------------------------#
FUNCTION pol0778_listagem()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07785") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07785 AT 5,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   IF pol0778_info_transp() THEN
      CALL pol0778_listar()
   END IF
  
   CLOSE WINDOW w_pol07785

END FUNCTION

#-----------------------------#
FUNCTION pol0778_info_transp()
#-----------------------------#
   
   DEFINE p_data_inicial DATE,
          p_data_final   DATE
   
   LET INT_FLAG = FALSE
   LET p_ies_conf = FALSE
   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa
   INITIALIZE p_transp.* TO NULL
   
   CONSTRUCT BY NAME where_clause ON
       frete_solicit_885.cod_transpor,
       frete_solicit_885.num_chapa
   
      ON KEY (control-z)
         CALL pol0778_popup()
   
   END CONSTRUCT
   
   IF INT_FLAG <> 0 THEN
      INITIALIZE p_transp.* TO NULL
      DISPLAY BY NAME p_transp.*
      RETURN FALSE
   END IF

   INITIALIZE p_dat_ini, p_dat_fim TO NULL
   
   INPUT p_dat_ini, p_dat_fim
      WITHOUT DEFAULTS FROM dat_ini, dat_fim
      
      AFTER FIELD dat_ini    
         IF p_dat_ini IS NULL THEN
            #INITIALIZE p_dat_fim TO NULL 
            #EXIT INPUT
         END IF 

      AFTER FIELD dat_fim   
         IF p_dat_fim IS NULL THEN
            #INITIALIZE p_dat_ini TO NULL 
         ELSE
            IF p_dat_ini IS NOT NULL THEN
               IF p_dat_ini > p_dat_fim THEN
                  ERROR "Data Inicial nao pode ser maior que data Final"
                  NEXT FIELD dat_ini
               END IF 
               IF p_dat_fim - p_dat_ini > 720 THEN 
                  ERROR "Periodo nao pode ser maior que 720 Dias"
                  NEXT FIELD dat_ini
               END IF 
            END IF
         END IF

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   LET p_data_inicial = EXTEND(p_dat_ini, YEAR TO DAY)
   LET p_data_final   = EXTEND(p_dat_fim, YEAR TO DAY)
    
   LET p_query  = 
       "SELECT num_solicit, cod_transpor, num_chapa ",
       "  FROM frete_solicit_885 ",
       " WHERE ", where_clause CLIPPED,
       "   AND cod_empresa = '",p_cod_empresa,"' ",
       "   AND versao_atual = 'S' "

   IF p_dat_ini IS NOT NULL THEN
      LET p_dat_ant = p_dat_ini - 1
      LET p_query  = p_query CLIPPED,
          " AND EXTEND(dat_cadastro, YEAR TO DAY) >= '",p_data_inicial,"' "
   END IF
   
   IF p_dat_fim IS NOT NULL THEN
      LET p_dat_dep = p_dat_fim + 1
      LET p_query  = p_query CLIPPED,
          " AND EXTEND(dat_cadastro, YEAR TO DAY) <= '",p_data_final,"' "
   END IF
   
   LET p_query  = p_query CLIPPED, " ORDER BY cod_transpor, dat_cadastro "
   
   RETURN TRUE
   
END FUNCTION

#------------------------#
FUNCTION pol0778_listar()
#------------------------#

   IF NOT pol0778_escolhe_saida() THEN
   		RETURN 
   END IF

   IF NOT pol0778_cria_nf_tmp() THEN
      RETURN
   END IF
   
   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN
   END IF
   
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   LET p_imprimiu = FALSE

   PREPARE var_query FROM p_query   
   DECLARE cq_lst CURSOR FOR var_query

   FOREACH cq_lst INTO 
           p_num_solicit,
           p_cod_transpor,
           p_num_chapa

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('lendo','frete_solicit_885:cq_lst_1')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF
      
      INITIALIZE p_relat TO NULL
      
      SELECT cod_transpor,
             num_chapa,
             val_frete_ofic,
             val_frete_ger,
             val_frete,
             val_frete_tab,
             dat_cadastro,
             cod_tip_carga,
             cod_veiculo
        INTO p_cod_transpor,
             p_relat.num_chapa,
             p_relat.val_frete_ofic,
             p_relat.val_frete_ger,
             p_relat.val_frete,
             p_relat.val_tabela,
             p_relat.dat_movto,
             p_relat.tip_carga,
             p_relat.cod_veiculo
        FROM frete_solicit_885
       WHERE cod_empresa  = p_cod_empresa
         AND num_solicit  = p_num_solicit
         AND versao_atual = 'S'

      IF sqlca.sqlcode <> 0 THEN
         ERROR p_num_solicit
         CALL log003_err_sql('lendo','frete_solicit_885:cq_lst_2')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF
      
      SELECT preco_compl
        INTO p_relat.preco_compl
        FROM frete_compl_885
      WHERE cod_empresa  = p_cod_empresa
        AND num_solicit  = p_num_solicit

      IF STATUS <> 0 THEN
         LET p_relat.preco_compl = 0
      END IF
      
      LET p_relat.val_frete = p_relat.val_frete + p_relat.preco_compl      
      LET p_dat_movto = DATE(p_relat.dat_movto)
      
      SELECT nom_cliente
        INTO p_nom_transpor
        FROM clientes
       WHERE cod_cliente = p_cod_transpor
    
      IF sqlca.sqlcode = 100 THEN
         LET p_cod_transpor = 'NAO CADASTRADO !!!'
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','Clientes')
            LET p_imprimiu = FALSE
            EXIT FOREACH
         END IF
      END IF

      IF NOT pol0778_carrega_tmp() THEN
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF

      DECLARE cq_tmp CURSOR FOR
       SELECT *
         FROM nf_tmp_885
        ORDER BY seq_impres

      FOREACH cq_tmp INTO p_relat.*
                           
         LET p_imprimiu = TRUE
         
         DISPLAY p_relat.num_nff AT 14,25

         IF p_relat.seq_impres > 1 THEN
            INITIALIZE 
               p_relat.num_chapa,    
               p_relat.cod_veiculo,  
               p_relat.tip_carga,    
               p_relat.val_frete_ofic,
               p_relat.val_frete_ger, 
               p_relat.preco_compl,   
               p_relat.val_frete,     
               p_relat.val_tabela TO NULL    
         END IF
         
         OUTPUT TO REPORT pol0778_relat(p_cod_transpor)

         INITIALIZE p_relat TO NULL
         
      END FOREACH
         
   END FOREACH
   
   CALL pol0778_finaliza_relat()

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
END FUNCTION

#------------------------------#
FUNCTION pol0778_carrega_tmp()
#------------------------------#

   DEFINE p_inseriu SMALLINT,
          p_cid_dest CHAR(05),
          p_setou_um SMALLINT
          
   LET p_inseriu = FALSE
   LET p_setou_um = FALSE
   LET p_count = 0
   
   DELETE FROM nf_tmp_885
         
   DECLARE cq_oms CURSOR FOR
    SELECT num_om,
           cod_cid_dest
      FROM solicit_fat_885
     WHERE cod_empresa = p_cod_empresa
       AND num_solicit = p_num_solicit
         
   FOREACH cq_oms INTO p_num_om, p_cod_cidade

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('lendo','solicit_fat_885:cq_lst')
         RETURN FALSE
      END IF
      
      LET p_cid_dest = NULL
      
      DECLARE cq_cid CURSOR FOR
       SELECT codciddest
        FROM romaneio_885
       WHERE codempresa     = p_cod_empresa
         AND numromaneio    = p_num_solicit

      FOREACH cq_cid INTO p_cid_dest
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('FOREACH','romaneio_885:cq_oms')
            RETURN FALSE
         END IF
         
         EXIT FOREACH
      
      END FOREACH
      
      IF p_cid_dest = p_cod_cidade AND p_setou_um = FALSE THEN #cidade mais distante
         LET p_relat.seq_impres = 1
         LET p_setou_um = TRUE
      ELSE
         LET p_relat.seq_impres = 2
      END IF
            
      SELECT num_nff
        INTO p_relat.num_nff
        FROM ordem_montag_mest
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_num_om
            
      IF sqlca.sqlcode <> 0 THEN
         CONTINUE FOREACH
      END IF

      IF p_relat.num_nff IS NULL THEN
         CONTINUE FOREACH
      END IF

      SELECT cliente,
             peso_bruto
        INTO p_cod_cliente,
             p_relat.pes_nf
        FROM fat_nf_mestre
       WHERE empresa = p_cod_empresa
         AND nota_fiscal = p_relat.num_nff
         AND tip_nota_fiscal = 'FATPRDSV'
         AND espc_nota_fiscal = 'NFF'
               
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre:1')
         RETURN FALSE
      END IF  

      SELECT nom_reduzido
        INTO p_relat.nom_cliente
        FROM clientes
       WHERE cod_cliente = p_cod_cliente
    
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','clientes')
         RETURN FALSE
      END IF  

      SELECT COUNT(num_nff)
        INTO p_count
        FROM nf_tmp_885
       WHERE num_nff = p_relat.num_nff
      
      IF p_count > 0 THEN
         CONTINUE FOREACH
      END IF
      
      IF p_cod_cidade IS NULL THEN
         IF NOT pol0778_pega_cidade() THEN
            RETURN FALSE
         END IF
      END IF
      
      SELECT den_cidade
        INTO p_relat.cid_destino
        FROM cidades
       WHERE cod_cidade = p_cod_cidade
          
      IF sqlca.sqlcode <> 0 THEN         
         CALL log003_err_sql('Lendo','cidades:1')
         RETURN FALSE
      END IF  
      
      LET p_relat.num_romaneio = p_num_solicit
      
      INSERT INTO nf_tmp_885 VALUES(p_relat.*)
 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','nf_tmp_885')
         RETURN FALSE
      END IF  
      
      LET p_inseriu = TRUE
      LET p_count = p_count + 1
      
      #INITIALIZE p_relat TO NULL
                             
   END FOREACH
   
   IF NOT p_inseriu THEN
      INSERT INTO nf_tmp_885 VALUES(p_relat.*)
 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','nf_tmp_885')
         RETURN FALSE
      END IF  
   END IF

   {IF p_count > 0 THEN
      INITIALIZE p_relat TO NULL
      SELECT SUM(pes_nf)
        INTO p_relat.pes_nf
        FROM nf_tmp_885
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Somando','nf_tmp_885:pes_nf')
         RETURN FALSE
      END IF 
      
      IF p_relat.pes_nf IS NULL THEN
         LET p_relat.pes_nf = 0
      END IF
      
      INSERT INTO nf_tmp_885 VALUES(p_relat.*)
 
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Inserindo','nf_tmp_885:peso_total')
         RETURN FALSE
      END IF  
   END IF}
         
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0778_pega_cidade()
#-----------------------------#

   SELECT DISTINCT num_pedido
     INTO p_num_pedido
     FROM ordem_montag_item
    WHERE cod_empresa = p_cod_empresa
      AND num_om      = p_num_om

   IF sqlca.sqlcode <> 0 THEN         
      CALL log003_err_sql('Lendo','ordem_montag_item')
      RETURN FALSE
   END IF  
      
   SELECT MAX(num_sequencia)
     INTO p_num_seq
     FROM ped_end_ent
    WHERE cod_empresa   = p_cod_empresa
      AND num_pedido    = p_Num_Pedido
   
   IF sqlca.sqlcode <> 0 THEN         
      CALL log003_err_sql('Lendo','ped_end_ent:1')
      RETURN FALSE
   END IF  
      
   IF p_num_seq IS NOT NULL THEN
      SELECT cod_cidade
        INTO p_cod_cidade
        FROM ped_end_ent
       WHERE cod_empresa   = p_cod_empresa
         AND num_pedido    = p_Num_Pedido
         AND num_sequencia = p_num_seq

      IF sqlca.sqlcode <> 0 THEN         
         CALL log003_err_sql('Lendo','ped_end_ent:2')
         RETURN FALSE
      END IF  
   ELSE
      SELECT cod_cidade
        INTO p_cod_cidade
        FROM clientes
       WHERE cod_cliente = p_cod_cliente

      IF sqlca.sqlcode <> 0 THEN         
         CALL log003_err_sql('Lendo','clientes:3')
         RETURN FALSE
      END IF  
   END IF

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0778_cria_nf_tmp()
#-----------------------------#

   DROP TABLE nf_tmp_885

   CREATE TEMP TABLE nf_tmp_885(
         num_romaneio   INTEGER,
         dat_movto      CHAR(10),
         num_nff        DECIMAL(6,0),
         pes_nf         DECIMAL(10,3),
         nom_cliente    CHAR(15),
         cid_destino    CHAR(16),
         num_chapa      CHAR(07),
         cod_veiculo    CHAR(07),
         tip_carga      CHAR(01),
         val_frete_ofic DECIMAL(9,2),
         val_frete_ger  DECIMAL(9,2),
         preco_compl    DECIMAL(9,2),
         val_frete      DECIMAL(9,2),
         val_tabela     DECIMAL(9,2),
         seq_impres     INTEGER
    );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","nf_tmp_885")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol0778_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN 
      IF g_ies_ambiente = "U" THEN
         START REPORT pol0778_relat TO PIPE p_nom_arquivo
      ELSE 
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol0778.tmp' 
         START REPORT pol0778_relat TO p_caminho 
      END IF 
   ELSE
      START REPORT pol0778_relat TO p_nom_arquivo
   END IF
      
   RETURN TRUE
   
END FUNCTION   

#---------------------------------#
 FUNCTION pol0778_finaliza_relat()#
#---------------------------------#

   FINISH REPORT pol0778_relat   
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

END FUNCTION

#------------------------------------#
 REPORT pol0778_relat(p_cod_transpor)
#------------------------------------#

   DEFINE p_cod_transpor CHAR(15)

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 1
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
      
      ORDER EXTERNAL BY p_cod_transpor
      
   FORMAT

      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 054, "FRETES PARA CONFERENCIA",
               COLUMN 130, "PAG: ", PAGENO USING "&&&&&"
               
         PRINT COLUMN 001, "POL0778",                   
               COLUMN 111, "PERIODO: ",p_dat_ini USING 'dd/mm/yy', ' - ',p_dat_fim USING 'dd/mm/yy'

         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 054, "FRETES PARA CONFERENCIA",
               COLUMN 130, "PAG: ", PAGENO USING "&&&&&"
               
         PRINT COLUMN 001, "POL0778",                   
               COLUMN 111, "PERIODO: ",p_dat_ini USING 'dd/mm/yy', ' - ',p_dat_fim USING 'dd/mm/yy'

         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT

      BEFORE GROUP OF p_cod_transpor

         PRINT      
         PRINT COLUMN 001, "TRASNPORTADOR: ",p_cod_transpor, ' - ', p_nom_transpor
         PRINT
         PRINT COLUMN 001, " ROMANEIO  DT CARGA NUM NF   PESO          CLIENTE         DESTINO       CHAPA   VEICULO TC  NORMAL    GERENC   VR COMP VR FRETE  VR TABELA"
         PRINT COLUMN 001, "---------- -------- ------ ------------ --------------- ---------------- ------- ------- -- --------- --------- ------- --------- ---------"
         PRINT
         #SKIP TO TOP OF PAGE  
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_romaneio USING '##########',
               COLUMN 012, p_dat_movto USING 'dd/mm/yy',
               COLUMN 021, p_relat.num_nff USING '&&&&&&',
               COLUMN 028, p_relat.pes_nf USING '#######&.&&&',
               COLUMN 041, p_relat.nom_cliente,
               COLUMN 057, p_relat.cid_destino,
               COLUMN 074, p_relat.num_chapa,
               COLUMN 082, p_relat.cod_veiculo,
               COLUMN 090, p_relat.tip_carga,
               COLUMN 093, p_relat.val_frete_ofic USING '#####&.&&',
               COLUMN 103, p_relat.val_frete_ger  USING '#####&.&&',
               COLUMN 113, p_relat.preco_compl    USING '###&.&&',
               COLUMN 121, p_relat.val_frete      USING '#####&.&&',
               COLUMN 131, p_relat.val_tabela     USING '#####&.&&'
               

      AFTER GROUP OF p_cod_transpor
      
         SKIP 1 LINES
         PRINT COLUMN 006, "TOTAL TRANSPORTADOR: ",
               COLUMN 028, GROUP SUM(p_relat.pes_nf)         USING '#######&.&&&',
               COLUMN 093, GROUP SUM(p_relat.val_frete_ofic) USING '#####&.&&',
               COLUMN 103, GROUP SUM(p_relat.val_frete_ger)  USING '#####&.&&',
               COLUMN 113, GROUP SUM(p_relat.preco_compl)    USING '###&.&&',
               COLUMN 121, GROUP SUM(p_relat.val_frete)      USING '#####&.&&',
               COLUMN 131, GROUP SUM(p_relat.val_tabela)     USING '#####&.&&'
         PRINT
         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT

      ON LAST ROW

         SKIP 2 LINES
         
         PRINT COLUMN 005, "T O T A L  G E R A L: ",
               COLUMN 028, SUM(p_relat.pes_nf)   USING '#######&.&&&',
               COLUMN 093, SUM(p_relat.val_frete_ofic) USING '#####&.&&',
               COLUMN 103, SUM(p_relat.val_frete_ger)  USING '#####&.&&',
               COLUMN 113, SUM(p_relat.preco_compl)    USING '###&.&&',
               COLUMN 121, SUM(p_relat.val_frete)      USING '#####&.&&',
               COLUMN 131, SUM(p_relat.val_tabela)     USING '#####&.&&'
         
         PRINT
         
         WHILE LINENO < 64
            PRINT
         END WHILE

         PRINT COLUMN 030, p_descomprime, '* * * ULTIMA FOLHA * * *'
         
END REPORT

#---ROTINAS PARA FRETE PAGO COM NOTA DE SERVIÇO---#

#----------------------------#
FUNCTION pol0778_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#----------------------#
FUNCTION pol0778_notas()
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07781") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07781 AT 2,1 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta pagamento com nota de serviço "
         CALL pol0778_nota_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso'
         ELSE
            CALL pol0778_limpa_tela()
            ERROR "Operação Cancelada !!!"
         END IF
      COMMAND "Processar" "Processa a integração com o CAP "
         IF p_ies_validado = 'C' THEN
            CALL pol0778_nota_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso'
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF
         ELSE
            ERROR 'Somente processo com status C pode ser integrado'
         END IF         
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 000
         MESSAGE ""
         EXIT MENU
   END MENU
  
   CLOSE WINDOW w_pol07781

END FUNCTION

#-------------------------------#
FUNCTION pol0778_nota_consultar()
#-------------------------------#

   INITIALIZE p_nota TO NULL
   CALL pol0778_limpa_tela()
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_nota.* WITHOUT DEFAULTS

      AFTER FIELD num_nfe
         IF p_nota.num_nfe IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD num_nfe       
         END IF 

         SELECT COUNT(num_nf)
           INTO p_count
           FROM nf_sup
          WHERE cod_empresa     = p_cod_empresa
            AND num_nf          = p_nota.num_nfe
            AND (ies_especie_nf = 'NFS' OR 
                 ies_especie_nf = 'CON')
         
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','nf_sup:1')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            ERROR "NF inexistente ou não é nota de serviço!!!"
            NEXT FIELD num_nfe       
         END IF 

         NEXT FIELD cod_for

      AFTER FIELD cod_for

         IF p_nota.cod_for IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD cod_for       
         END IF 

         SELECT raz_social
           INTO p_nota.nom_for
           FROM fornecedor
          WHERE cod_fornecedor = p_nota.cod_for
         
         IF sqlca.sqlcode <> 0 THEN
            ERROR 'Fornecedor inexistente!!!'
            NEXT FIELD cod_for
         END IF

         SELECT ser_nf,
                ssr_nf,
                ies_especie_nf,
                dat_emis_nf,
                val_tot_nf_d, 
                val_tot_nf_c, 
                val_tot_icms_nf_d,
                val_tot_icms_nf_c,
                num_aviso_rec,
                cnd_pgto_nf
           INTO p_nota.ser_nfe,
                p_nota.ssr_nfe,
                p_nota.esp_nfe,
                p_nota.dat_nfe,
                p_nota.val_nfe,
                p_val_tot_nf_c,
                p_nota.val_icm,
                p_val_tot_icms_nf_c,
                p_num_aviso_rec,
                p_cnd_pgto_nf
           FROM nf_sup
          WHERE cod_empresa     = p_cod_empresa
            AND num_nf          = p_nota.num_nfe
            AND cod_fornecedor  = p_nota.cod_for
            AND (ies_especie_nf = 'NFS' OR 
                 ies_especie_nf = 'CON')
            
         IF STATUS <> 0 THEN
            ERROR 'Nota e/ou fornecedor inexistente '
            NEXT FIELD num_nfe
         END IF
         
         IF p_nota.val_nfe = 0  THEN
            LET p_nota.val_nfe = p_val_tot_nf_c
         END IF
         
         IF p_nota.val_icm = 0  THEN
            LET p_nota.val_icm = p_val_tot_icms_nf_c
         END IF
         
         SELECT DISTINCT ies_validado
           INTO p_ies_validado
           FROM nfe_x_nff_885
          WHERE cod_empresa = p_cod_empresa
            AND num_nfe     = p_nota.num_nfe
            AND ser_nfe     = p_nota.ser_nfe
            AND ssr_nfe     = p_nota.ssr_nfe
            AND cod_for     = p_nota.cod_for
         
         IF STATUS = 100 THEN
            ERROR 'Nota de serviço sem relacionamento '
            NEXT FIELD num_nfe
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('SELECT','nfe_x_nff_885')
               NEXT FIELD num_nfe
            END IF
         END IF

         SELECT pct_desc
           INTO p_nota.pct_desc
           FROM desc_transp_885
          WHERE cod_empresa  = p_cod_empresa
            AND cod_transpor = p_nota.cod_for
         
         IF sqlca.sqlcode = 100 THEN
            LET p_nota.pct_desc = 0
         ELSE
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql('Lendo','desc_transp_885')
               RETURN FALSE
            END IF
         END IF
            
         DISPLAY p_nota.pct_desc TO pct_desc
         DISPLAY p_nota.ser_nfe TO ser_nfe
         DISPLAY p_nota.ssr_nfe TO ssr_nfe
         DISPLAY p_nota.esp_nfe TO esp_nfe
         DISPLAY p_nota.val_nfe TO val_nfe
         DISPLAY p_nota.val_icm TO val_icm
         DISPLAY p_nota.dat_nfe TO dat_nfe
         DISPLAY p_nota.nom_for TO nom_for
         DISPLAY p_ies_validado TO ies_validado
         DISPLAY p_cnd_pgto_nf  TO cnd_pgto_nf
         
      ON KEY (control-z)
         CALL pol0778_popup()

      AFTER INPUT
       IF NOT INT_FLAG THEN
         IF p_nota.cod_for IS NULL THEN
            ERROR "Campo de Preenchimento Obrigatorio"
            NEXT FIELD cod_for       
         END IF   
       END IF       
   
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_carrega_notas() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_cons = TRUE
   
   RETURN TRUE
   
END FUNCTION


#------------------------------#
FUNCTION pol0778_carrega_notas()
#------------------------------#

   INITIALIZE pr_nota TO NULL

   LET p_index = 1

   DECLARE cq_n_x_s CURSOR FOR
    SELECT num_nff,
           val_frete,
           val_compl
      FROM nfe_x_nff_885
     WHERE cod_empresa = p_cod_empresa
       AND num_nfe     = p_nota.num_nfe
       AND ser_nfe     = p_nota.ser_nfe
       AND ssr_nfe     = p_nota.ssr_nfe
       AND cod_for     = p_nota.cod_for

   FOREACH cq_n_x_s INTO 
           pr_nota[p_index].num_nff,
           pr_nota[p_index].val_frete_rod,
           pr_nota[p_index].val_frete_ger

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','nfe_x_nff_885')
         RETURN FALSE
      END IF

      IF NOT pol0778_le_nf_mestre() THEN
         RETURN FALSE
      END IF

     LET pr_nota[p_index].val_frete_tot = 
         pr_nota[p_index].val_frete_rod + pr_nota[p_index].val_frete_ger
      
      LET p_index = p_index + 1

      IF p_index > 1000 THEN
         CALL log0030_mensagem('Linite de linhas da grade ultapassado','exclamation')
         EXIT FOREACH
      END IF
      
   END FOREACH   

   CALL SET_COUNT(p_index - 1)

   CALL pol0778_calc_tot_frete() 
   
   LET p_pct_desc = 100 - p_nota.pct_desc
   LET p_val_devido = p_tot_frete_ger # p_nota.val_nfe * p_nota.pct_desc / p_pct_desc
   #LET p_val_devido = p_val_devido + p_nota.val_nfe
   DISPLAY p_val_devido TO val_devido

   DISPLAY ARRAY pr_nota TO sr_nota.*  

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0778_le_nf_mestre()
#------------------------------#

      SELECT a.peso_bruto,
             b.nom_reduzido,
             c.den_cidade,
             a.serie_nota_fiscal,
             a.sit_nota_fiscal
        INTO pr_nota[p_index].pes_tot_bruto,
             pr_nota[p_index].nom_reduzido,
             pr_nota[p_index].den_cidade,
             p_ser_nff,
             p_ies_situacao
        FROM fat_nf_mestre a,
             clientes  b,
             cidades   c
       WHERE a.empresa = p_cod_empresa
         AND a.nota_fiscal = pr_nota[p_index].num_nff
         AND b.cod_cliente = a.cliente
         AND c.cod_cidade  = b.cod_cidade
         #AND tip_nota_fiscal = 'FATPRDSV'
         #AND espc_nota_fiscal = 'NFF'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre')
         RETURN FALSE
      END IF
      
      RETURN TRUE
      
END FUNCTION

#-----------------------#
FUNCTION pol0778_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_transpor)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_info.cod_transpor   = p_codigo
            LET p_transp.cod_transpor = p_codigo
            DISPLAY p_codigo TO cod_transpor
         END IF

      WHEN INFIELD(cod_cid_dest)
         CALL log009_popup(5,12,"CIDADES","cidades",
              "cod_cidade","den_cidade","","N","1=1 order by den_cidade") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
           #LET p_info.cod_cid_dest = p_codigo
           DISPLAY p_codigo TO cod_cid_dest
         END IF

      WHEN INFIELD(cod_for)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_nota.cod_for = p_codigo
            DISPLAY p_codigo TO cod_for
         END IF

      WHEN INFIELD(cod_veiculo)
         CALL log009_popup(5,12,"VEICULO_885","veiculo_885",
              "cod_veiculo","den_veiculo","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
           LET p_edita.cod_veiculo = p_codigo
           DISPLAY p_codigo TO cod_veiculo
         END IF

{      WHEN INFIELD(cod_tra)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_nota.cod_tra = p_codigo
            DISPLAY p_codigo TO cod_tra
         END IF
}
   END CASE
   
END FUNCTION



#--------------------------------#
FUNCTION pol0778_calc_tot_frete()
#--------------------------------#

   LET p_tot_frete_rod = 0
   LET p_tot_frete_ger = 0
   LET p_tot_frete_tot = 0

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_nota[p_ind].val_frete_rod IS NOT NULL THEN
          LET p_tot_frete_rod = p_tot_frete_rod + pr_nota[p_ind].val_frete_rod
          LET p_tot_frete_ger = p_tot_frete_ger + pr_nota[p_ind].val_frete_ger
          LET p_tot_frete_tot = p_tot_frete_tot + pr_nota[p_ind].val_frete_tot
       END IF
   END FOR

   DISPLAY p_tot_frete_rod TO tot_frete_rod
   DISPLAY p_tot_frete_ger TO tot_frete_ger
   DISPLAY p_tot_frete_tot TO tot_frete_tot

END FUNCTION


#--------------------------------#
FUNCTION pol0778_nota_processar()
#--------------------------------#

   IF p_tot_frete_rod <> p_nota.val_nfe THEN
      LET p_msg = 'Valor cobrado pela  NFS não confere\n',
                  'com o valor calculado, a partir das\n',
                  'das notas de saida. Gerar titulo as-\n',
                  'mesmo?'
   ELSE
      LET p_msg = 'Confirma a geração do titulo?'
   END IF

   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF
   
   LET p_val_movto = p_tot_frete_ger
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0778_integra_cap() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF   

   CALL log085_transacao("COMMIT") 

   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0778_integra_cap()
#-----------------------------#

   LET p_flag = 'I'
   
   IF NOT pol0778_atualiza_nfe() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0778_cria_tmp() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0778_gera_cap() THEN
      RETURN FALSE
   END IF
   
   DISPLAY p_flag TO ies_validado
   
   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0778_cria_tmp()
#-------------------------#

   DROP TABLE contas_tmp_885

   CREATE TEMP TABLE contas_tmp_885(
          num_aviso_rec    DECIMAL(7,0),
          num_seq          DECIMAL(2,0),
          cod_tip_despesa  INTEGER,
          num_conta_deb    CHAR(15),
          num_conta_cred   CHAR(15),
          val_movto        DECIMAL(12,2)
    );
                 
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","contas_tmp_885")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol0778_atualiza_nfe()
#-----------------------------#

   UPDATE nfe_x_nff_885
      SET ies_validado = p_flag
     WHERE cod_empresa = p_cod_empresa
       AND num_nfe     = p_nota.num_nfe
       AND ser_nfe     = p_nota.ser_nfe
       AND ssr_nfe     = p_nota.ssr_nfe
       AND cod_for     = p_nota.cod_for

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','nfe_x_nff_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
       
END FUNCTION

#-------------------------#
FUNCTION pol0778_gera_cap()
#-------------------------#

   IF NOT pol0778_le_nf_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_le_conta_deb() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_le_conta_cred() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_insere_contas() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_gera_ad() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0778_le_nf_sup()
#---------------------------#

   SELECT dat_emis_nf,
          dat_entrada_nf,
          num_nf,
          ser_nf,
          ssr_nf,
          cod_fornecedor,
          cnd_pgto_nf,
          cod_empresa_estab
     INTO p_dat_emis_nf,
          p_dat_entrada_nf,
          p_num_nf,
          p_ser_nf,
          p_ssr_nf,
          p_cod_fornecedor,
          p_cnd_pgto_nf,
          p_cod_empresa_estab
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup")       
      RETURN FALSE
   END IF
   
   LET p_num_seq =  1

   SELECT cod_tip_despesa
     INTO p_cod_tip_despesa
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq       = p_num_seq
         
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aviso_rec')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0778_le_conta_deb()
#------------------------------#

   SELECT num_conta_deb_desp
     INTO p_num_conta_deb
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq       = p_num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dest_aviso_rec')
      RETURN FALSE
   END IF

   IF p_num_conta_deb IS NULL THEN
      LET p_num_conta_deb = ' '
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0778_le_conta_cred()
#-------------------------------#
   
   SELECT cod_grp_despesa,
          cod_hist_deb_ap
     INTO p_cod_grp_despesa,
          p_cod_hist_deb_ap
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_empresa
      AND cod_tip_despesa = p_cod_tip_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tipo_despesa')
      RETURN FALSE
   END IF
    
   SELECT num_conta_fornec
     INTO p_num_conta_cred
     FROM grupo_despesa
    WHERE cod_empresa     = p_cod_empresa
      AND cod_grp_despesa = p_cod_grp_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','grupo_despesa')
      RETURN FALSE
   END IF
   
   IF p_num_conta_cred IS NULL THEN
      LET p_num_conta_cred = ' '
   END IF
   
   RETURN TRUE        

END FUNCTION

#-------------------------------#
FUNCTION pol0778_insere_contas()
#-------------------------------#

   INSERT INTO contas_tmp_885
    VALUES(p_num_aviso_rec,
           p_num_seq,
           p_cod_tip_despesa,
           p_num_conta_deb,
           p_num_conta_cred,
           p_val_movto)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','contas_tmp_885')
      RETURN FALSE
   END IF

   RETURN TRUE        

END FUNCTION

#-------------------------#
FUNCTION pol0778_gera_ad()
#-------------------------#
   
   LET p_cod_emp_orig = pol0778_le_emp_orig_dest()
   
   IF NOT pol0778_le_par_ad() THEN 
      RETURN FALSE
   END IF
         
   IF NOT pol0778_insere_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_insere_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_grava_aps() THEN
      RETURN FALSE
   END IF

   CALL log0030_mensagem(p_msg,'info')
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0778_le_emp_orig_dest()
#----------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT cod_empresa_destin
     INTO p_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_empresa = p_cod_empresa
   END IF

   RETURN (p_empresa)
   
END FUNCTION


#---------------------------#
FUNCTION pol0778_le_par_ad()
#---------------------------#

   SELECT MAX(num_ad)
     INTO p_num_ad
     FROM ad_mestre_885
    WHERE cod_empresa = p_cod_emp_orig

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','par_ad')
      RETURN FALSE
   END IF

   IF p_num_ad IS NULL THEN
      LET p_num_ad = 0
   END IF
   
   LET p_num_ad = p_num_ad + 1
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0778_le_par_ap()
#---------------------------#

   SELECT MAX(num_aP)
     INTO p_num_ap
     FROM ap_885
    WHERE cod_empresa = p_cod_emp_orig

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','ap_885')
      RETURN FALSE
   END IF

   IF p_num_ap IS NULL THEN
      LET p_num_ap = 0
   END IF
   
   LET p_num_ap = p_num_ap + 1

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0778_insere_ad()
#---------------------------#

   IF NOT pol0778_calc_dat_vencto() THEN
      RETURN FALSE
   END IF
   
   LET p_ad_mestre.cod_empresa       = p_cod_emp_orig
   LET p_ad_mestre.num_ad            = p_num_ad
   LET p_ad_mestre.cod_tip_despesa   = p_cod_tip_despesa 
   LET p_ad_mestre.ser_nf            = p_ser_nf
   LET p_ad_mestre.ssr_nf            = p_ssr_nf
   LET p_ad_mestre.num_nf            = p_num_nf
   LET p_ad_mestre.dat_emis_nf       = p_dat_emis_nf
   LET p_ad_mestre.dat_rec_nf        = p_dat_entrada_nf
   LET p_ad_mestre.cod_empresa_estab = p_cod_empresa_estab
   LET p_ad_mestre.mes_ano_compet    = NULL
   LET p_ad_mestre.num_ord_forn      = NULL
   LET p_ad_mestre.cnd_pgto          = p_cnd_pgto_nf
   LET p_ad_mestre.dat_venc          = p_dat_vencto
   LET p_ad_mestre.cod_fornecedor    = p_cod_fornecedor
   LET p_ad_mestre.cod_portador      = NULL
   LET p_ad_mestre.val_tot_nf        = p_val_movto
   LET p_ad_mestre.val_saldo_ad      = p_ad_mestre.val_tot_nf
   LET p_ad_mestre.cod_moeda         = 1
   LET p_ad_mestre.set_aplicacao     = NULL
   LET p_ad_mestre.cod_lote_pgto     = 1
   LET p_ad_mestre.observ            = NULL
   LET p_ad_mestre.cod_tip_ad        = 5
   LET p_ad_mestre.ies_ap_autom      = 'S'
   LET p_ad_mestre.ies_sup_cap       = 'S'
   LET p_ad_mestre.ies_fatura        = 'N'
   LET p_ad_mestre.ies_ad_cont       = 'S' # verificar
   LET p_ad_mestre.num_lote_transf   = 0
   LET p_ad_mestre.ies_dep_cred      = 'N'
   LET p_ad_mestre.num_lote_pat      = 0
   LET p_ad_mestre.cod_empresa_orig  = p_cod_empresa
   LET p_ad_mestre.ies_situacao = 'N'

   INSERT INTO ad_mestre_885
      VALUES(p_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_mestre_885')
      RETURN FALSE
   END IF

   LET p_msg = p_ad_mestre.num_ad
   LET p_msg = 'pol0778 - INCLUSAO DA AD No. ', p_msg CLIPPED
   LET p_hora = CURRENT HOUR TO SECOND

   INSERT INTO audit_cap_885
      VALUES(p_ad_mestre.cod_empresa,
             '1',
             p_user,
             p_ad_mestre.num_ad,
             '1',
             p_ad_mestre.num_nf,
             p_ad_mestre.ser_nf,
             p_ad_mestre.ssr_nf,
             p_ad_mestre.cod_fornecedor,
             'I',
             '1',
             p_msg,
             getdate(),
             p_hora,
             p_ad_mestre.num_lote_transf)
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_cap')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0778_calc_dat_vencto()
#---------------------------------#

   SELECT qtd_dias 
     INTO p_qtd_dias
     FROM cond_pg_item_cap
    WHERE cnd_pgto    = p_cnd_pgto_nf
      AND num_parcela = 1
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cond_pg_item_cap')
      RETURN FALSE
   END IF

   IF p_qtd_dias > 0 THEN
      LET p_qtd_dias = p_qtd_dias - 1
   END IF
   
   LET p_dat_vencto  = p_dat_emis_nf + p_qtd_dias

   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol0778_insere_lanc()
#-----------------------------#
   
   DEFINE p_num_seq SMALLINT
   
   LET p_num_seq = 0
   
   DECLARE cq_lanc CURSOR FOR
    SELECT cod_tip_despesa,
           num_conta_cred,
           num_conta_deb,
           val_movto
      FROM contas_tmp_885
     WHERE num_aviso_rec = p_num_aviso_rec

   FOREACH cq_lanc  INTO 
           p_cod_tip_despesa, 
           p_num_conta_cred, 
           p_num_conta_deb, 
           p_val_movto

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','contas_tmp_885')
         RETURN FALSE
      END IF
   
      LET p_msg = p_ad_mestre.num_nf
      LET p_num_seq = p_num_seq + 1
      
      LET p_lanc_cont_cap.cod_empresa        = p_ad_mestre.cod_empresa
      LET p_lanc_cont_cap.num_ad_ap          = p_ad_mestre.num_ad
      LET p_lanc_cont_cap.ies_ad_ap          = '1'
      LET p_lanc_cont_cap.num_seq            = p_num_seq
      LET p_lanc_cont_cap.cod_tip_desp_val   = p_cod_tip_despesa
      LET p_lanc_cont_cap.ies_desp_val       = 'D'
      LET p_lanc_cont_cap.ies_man_aut        = 'A'
      LET p_lanc_cont_cap.ies_tipo_lanc      = 'D'
      LET p_lanc_cont_cap.num_conta_cont     = p_num_conta_deb
      LET p_lanc_cont_cap.val_lanc           = p_val_movto
      LET p_lanc_cont_cap.tex_hist_lanc      = 'NF ',p_msg CLIPPED,' DO ', p_raz_social
      LET p_lanc_cont_cap.ies_cnd_pgto       = 'S'
      LET p_lanc_cont_cap.num_lote_lanc      = 0
      LET p_lanc_cont_cap.ies_liberad_contab = 'S'
      LET p_lanc_cont_cap.num_lote_transf    = p_ad_mestre.num_lote_transf
      LET p_lanc_cont_cap.dat_lanc           = p_ad_mestre.dat_rec_nf

      INSERT INTO lanc_cont_cap_885
         VALUES(p_lanc_cont_cap.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','lanc_cont_cap')
         RETURN FALSE
      END IF

      LET p_lanc_cont_cap.ies_tipo_lanc  = 'C'
      LET p_lanc_cont_cap.num_conta_cont = p_num_conta_cred
      LET p_num_seq = p_num_seq + 1
      LET p_lanc_cont_cap.num_seq        = p_num_seq
      LET p_lanc_cont_cap.ies_ad_ap          = '2'
      
      INSERT INTO lanc_cont_cap_885
         VALUES(p_lanc_cont_cap.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','lanc_cont_cap')
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0778_grava_aps()
#---------------------------#

   SELECT COUNT(cnd_pgto)
     INTO p_qtd_parcelas
     FROM cond_pg_item_cap
    WHERE cnd_pgto = p_cnd_pgto_nf

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cond_pg_item_cap:1')
      RETURN FALSE
   END IF
   
   IF p_qtd_parcelas IS NULL THEN
      RETURN FALSE
   END IF

   LET p_num_parcela = 1
   LET p_val_gravado = 0
     
   DECLARE cq_cnd_pagto CURSOR FOR
    SELECT qtd_dias,
           pct_val_vencto
      FROM cond_pg_item_cap
     WHERE cnd_pgto = p_cnd_pgto_nf
       
   FOREACH cq_cnd_pagto INTO 
           p_qtd_dias,
           p_pct_val_vencto

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_cnd_pagto')
         RETURN FALSE
      END IF
      
      IF p_qtd_dias > 0 THEN
         LET p_qtd_dias = p_qtd_dias - 1
      END IF
      
      IF p_num_parcela = p_qtd_parcelas THEN
         LET p_val_parcela = p_ad_mestre.val_tot_nf - p_val_gravado
      ELSE
         LET p_val_parcela  = 
             p_ad_mestre.val_tot_nf * p_pct_val_vencto / 100
      END IF
      
      LET p_val_gravado = p_val_gravado + p_val_parcela    
      LET p_dat_vencto  = p_dat_emis_nf + p_qtd_dias
      
      IF NOT pol0778_insere_ap() THEN
         RETURN FALSE
      END IF
      
      LET p_num_parcela = p_num_parcela + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol0778_insere_ap()
#---------------------------#

    IF NOT pol0778_le_par_ap() THEN 
       RETURN FALSE
    END IF

    LET p_ap.cod_empresa       = p_cod_emp_orig
    LET p_ap.num_ap            = p_num_ap
    LET p_ap.num_versao        = 1
    LET p_ap.ies_versao_atual  = 'S'
    LET p_ap.num_parcela       = p_num_parcela
    LET p_ap.cod_portador      = NULL
    LET p_ap.cod_bco_pagador   = NULL
    LET p_ap.num_conta_banc    = NULL
    LET p_ap.cod_fornecedor    = p_cod_fornecedor
    LET p_ap.cod_banco_for     = NULL
    LET p_ap.num_agencia_for   = NULL
    LET p_ap.num_conta_bco_for = NULL
    LET p_ap.num_nf            = p_num_nf
    LET p_ap.num_duplicata     = NULL
    LET p_ap.num_bl_awb        = NULL
    LET p_ap.compl_docum       = NULL
    LET p_ap.val_nom_ap        = p_val_parcela
    LET p_ap.val_ap_dat_pgto   = 0
    LET p_ap.cod_moeda         = p_ad_mestre.cod_moeda
    LET p_ap.val_jur_dia       = 0
    LET p_ap.taxa_juros        = NULL
    LET p_ap.cod_formula       = NULL
    LET p_ap.dat_emis          = TODAY
    LET p_ap.dat_vencto_s_desc = p_dat_vencto
    LET p_ap.dat_vencto_c_desc = NULL
    LET p_ap.val_desc          = NULL
    LET p_ap.dat_pgto          = NULL
    LET p_ap.dat_proposta      = NULL
    LET p_ap.cod_lote_pgto     = 1
    LET p_ap.num_docum_pgto    = NULL
    LET p_ap.ies_lib_pgto_cap  = 'N'
    LET p_ap.ies_lib_pgto_sup  = 'S'
    LET p_ap.ies_baixada       = 'N'
    LET p_ap.ies_docum_pgto    = NULL
    LET p_ap.ies_ap_impressa   = 'N'
    LET p_ap.ies_ap_contab     = 'N'
    LET p_ap.num_lote_transf   = p_ad_mestre.num_lote_transf
    LET p_ap.ies_dep_cred      = 'N'
    LET p_ap.data_receb        = NULL
    LET p_ap.num_lote_rem_escr = 0
    LET p_ap.num_lote_ret_escr = 0
    LET p_ap.dat_rem           = NULL
    LET p_ap.dat_ret           = NULL
    LET p_ap.status_rem        = 0
    LET p_ap.ies_form_pgto_escr= NULL
   
   INSERT INTO ap_885
      VALUES(p_ap.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ap')
      RETURN FALSE
   END IF
   
   INSERT INTO ap_tip_desp_885
    VALUES(p_ap.cod_empresa,
           p_ap.num_ap,
           p_num_conta_cred,
           p_cod_hist_deb_ap,
           p_cod_tip_despesa,
           p_ap.val_nom_ap)
           
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ap_tip_desp')
      RETURN FALSE
   END IF
      
   INSERT INTO ad_ap_885
      VALUES(p_ap.cod_empresa,
             p_ad_mestre.num_ad,
             p_ap.num_ap,
             p_ap.num_lote_transf)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_ap')
      RETURN FALSE
   END IF

   LET p_msg = p_ap.num_ap
   LET p_msg = 'pol0778 - INCLUSAO DA AP No. ', p_msg CLIPPED
   LET p_hora = CURRENT HOUR TO SECOND

   INSERT INTO audit_cap_885
      VALUES(p_ap.cod_empresa,
             '1',
             p_user,
             p_ap.num_ap,
             '2',
             p_ad_mestre.num_nf,
             p_ad_mestre.ser_nf,
             p_ad_mestre.ssr_nf,
             p_ad_mestre.cod_fornecedor,
             'I',
             p_num_parcela,
             p_msg,
             getdate(),
             p_hora,
             p_ad_mestre.num_lote_transf)
             
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','audit_cap')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------FIM DO PROGRAMA----------------------#
