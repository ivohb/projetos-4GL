#-------------------------------------------------------------------#
# PROGRAMA: pol0778                                                 #
# OBJETIVO: FRETE DE SAIDA - CIBRAPEL                               #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 18/03/2008                                              #
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
          p_msg                CHAR(100),
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
          p_num_om             LIKE frete_roma_885.num_om,
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
          p_dat_cadastro       CHAR(10),
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
          p_frete_solicit      RECORD LIKE frete_solicit_885.*


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
   END RECORD 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT
   LET p_versao = "POL0778-05.10.09"
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
      COMMAND "Listar" "Listagem de fretes p/ confer�ncia"
         IF log005_seguranca(p_user,"VDP","pol0778","IN")  THEN
            CALL pol0778_listagem()
         END IF 
      COMMAND "NotaEntrada" "Pagamento de fretes c/ NF de entrada"
         IF log005_seguranca(p_user,"VDP","pol0778","IN")  THEN
            CALL pol0778_notas()
         END IF 
      COMMAND "Conhecimento" "Pagamento de fretes c/ conhecimento de frete"
         IF log005_seguranca(p_user,"VDP","pol0778","IN")  THEN
            LET p_ies_validado = 'N'
            CALL pol0778_conhec()
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
  
   CLOSE WINDOW w_pol0778

END FUNCTION

#-------------------------------#
FUNCTION pol0778_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF sqlca.sqlcode = 0 THEN
   ELSE
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_emp_ger = p_cod_empresa
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

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
            ERROR 'Romaneio inexistente !!!'
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
    WHERE codempresa   = p_cod_emp_ger
      AND numsequencia = p_num_sequencia
    
   IF sqlca.sqlcode = 100 THEN
      CALL log0030_mensagem('Dados do Trim n�o localizado','excla')
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
    WHERE cod_empresa  = p_cod_emp_ger
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
     WHERE codempresa  = p_cod_emp_ger
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
       frete_solicit_885.num_chapa,
       frete_solicit_885.cod_cid_dest
   
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

   IF log028_saida_relat(16,32) IS NULL THEN
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
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0732.tmp"
         START REPORT pol0778_relat TO p_caminho
      ELSE
         START REPORT pol0778_relat TO p_nom_arquivo
      END IF
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

      IF sqlca.sqlcode <> 0 THEN
         LET p_relat.preco_compl = 0
      END IF
      
      LET p_relat.val_frete = p_relat.val_frete + p_relat.preco_compl      
      LET p_dat_movto = p_relat.dat_movto
      
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
   
   FINISH REPORT pol0778_relat

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF NOT p_imprimiu THEN
      ERROR "N�o existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relat�rio impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relat�rio gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
   END IF

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
         CALL log003_err_sql('lendo','frete_roma_885:cq_lst')
         RETURN FALSE
      END IF

      SELECT codciddest
        INTO p_cid_dest
        FROM romaneio_885
       WHERE codempresa     = p_cod_emp_ger
         AND numromaneio    = p_num_solicit
         AND statusregistro = '1'
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('lendo','romaneio_885:cq_oms')
         RETURN FALSE
      END IF
      
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
    
      IF sqlca.sqlcode = 100 THEN
         LET p_relat.nom_cliente = 'NAO CADASTRADO'
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','Clientes')
            LET p_imprimiu = FALSE
            EXIT FOREACH
         END IF
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

   IF p_count > 0 THEN
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
   END IF
         
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

   IF sqlca.sqlcode = 0 OR sqlca.sqlcode -206 THEN 
 
      CREATE TABLE nf_tmp_885(
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

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","nf_tmp_885")
         RETURN FALSE
      END IF
   ELSE
      RETURN FALSE
   END IF

   RETURN TRUE
   
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
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_comprime, p_den_empresa, 
               COLUMN 054, "FRETES PARA CONFERENCIA",
               COLUMN 130, "PAG: ", PAGENO USING "&&&&&"
               
         PRINT COLUMN 001, "POL0778",                   
               COLUMN 111, "PERIODO: ",p_dat_ini USING 'dd/mm/yy', ' - ',p_dat_fim USING 'dd/mm/yy'

         PRINT COLUMN 001, "-------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, " ROMANEIO  DT CARGA NUM NF   PESO          CLIENTE         DESTINO       CHAPA   VEICULO TC  NORMAL    GERENC   VR COMP VR FRETE  VR TABELA"
         PRINT COLUMN 001, "---------- -------- ------ ------------ --------------- ---------------- ------- ------- -- --------- --------- ------- --------- ---------"
         PRINT

      BEFORE GROUP OF p_cod_transpor

         PRINT      
         PRINT COLUMN 001, "TRASNPORTADOR: ",p_cod_transpor, ' - ', p_nom_transpor
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
               COLUMN 113, GROUP SUM(p_relat.val_frete)      USING '#####&.&&',
               COLUMN 123, GROUP SUM(p_relat.val_tabela)     USING '#####&.&&'

      ON LAST ROW

         SKIP 2 LINES
         
         PRINT COLUMN 005, "T O T A L  G E R A L: ",
               COLUMN 028, SUM(p_relat.pes_nf)   USING '#######&.&&&',
               COLUMN 093, SUM(p_relat.val_frete_ofic) USING '#####&.&&',
               COLUMN 103, SUM(p_relat.val_frete_ger)  USING '#####&.&&',
               COLUMN 113, SUM(p_relat.val_frete)      USING '#####&.&&',
               COLUMN 123, SUM(p_relat.val_tabela)     USING '#####&.&&'
         
         PRINT
         
         WHILE LINENO < 64
            PRINT
         END WHILE

         PRINT COLUMN 030, p_descomprime, '* * * ULTIMA FOLHA * * *'
         
END REPORT

#------------------------#
FUNCTION pol0778_conhec()
#------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07782") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07782 AT 3,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar par�metros para o processamento "
         IF pol0778_inform_param() THEN
            CALL pol0778_carrega_dados() RETURNING p_status
            IF p_status THEN
               ERROR 'Par�metros informados com sucesso'
               LET p_ies_cons = TRUE
               NEXT OPTION "Modificar"
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF 
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modifica Valores"
         IF p_ies_cons THEN
            CALL pol0778_modificacao() RETURNING p_status
            IF p_status THEN
               ERROR 'Modifica��o efetuada com sucesso !!!'
               NEXT OPTION "Processar"
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Informe os par�metros previamente !!!"
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0778_paginacao("S")
         ELSE
            ERROR "Informe os par�metros previamente !!!"
         END IF
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         IF p_ies_cons THEN
            CALL pol0778_paginacao("A")
         ELSE
            ERROR "Informe os par�metros previamente !!!"
         END IF
      COMMAND "Processar" "Processa o gera��o do conhec de complemento "
         IF p_ies_cons THEN
            CALL pol0778_conhec_processar() RETURNING p_status
            IF p_status THEN
               LET p_msg = 'Gera��o de conhecimento efetuada com sucesso '
               CALL log0030_mensagem(p_msg,'excla')
            ELSE
               ERROR "Opera��o Cancelada !!!"
            END IF
         ELSE
            ERROR 'Informe previamente os par�metros !!!'
            NEXT OPTION "Informar"
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
  
   CLOSE WINDOW w_pol07782

END FUNCTION

#------------------------------#
FUNCTION pol0778_inform_param()
#------------------------------#

   INITIALIZE p_info TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

   INPUT BY NAME p_info.*
      WITHOUT DEFAULTS

      AFTER FIELD dat_ini    
         
         IF p_info.dat_ini IS NULL THEN
            INITIALIZE p_info.dat_fim TO NULL
            DISPLAY p_info.dat_fim TO dat_fim
            NEXT FIELD cod_transpor
         END IF

      AFTER FIELD dat_fim   
         IF p_info.dat_fim IS NULL THEN
            IF p_info.dat_ini IS NOT NULL THEN
               NEXT FIELD dat_fim
            END IF
         ELSE
            IF p_info.dat_ini > p_info.dat_fim THEN
               ERROR "Data Inicial nao pode ser maior que data Final"
               NEXT FIELD dat_ini
            END IF 
            CALL pol0778_checa_existencia('C')
            IF p_msg IS NOT NULL THEN
               ERROR p_msg
               NEXT FIELD dat_ini
            END IF
         END IF

      BEFORE FIELD cod_transpor
         LET p_info.nom_transpor = NULL
      
      AFTER FIELD cod_transpor

         IF p_info.cod_transpor IS NOT NULL THEN
            CALL pol0778_checa_existencia('C')
            IF p_msg IS NOT NULL THEN
               ERROR p_msg
               NEXT FIELD cod_transpor
            END IF
            LET p_cod_transpor = p_info.cod_transpor
            CALL pol0778_le_nome_transpor()
         END IF
      
         DISPLAY p_info.nom_transpor TO nom_transpor

      AFTER FIELD num_conhec
      
         IF p_info.num_conhec IS NULL THEN
            INITIALIZE p_info.ser_conhec, p_info.ssr_conhec TO NULL
            DISPLAY p_info.ser_conhec TO ser_conhec
            DISPLAY p_info.ssr_conhec TO ssr_conhec
         ELSE
            CALL pol0778_checa_existencia('C')
            IF p_msg IS NOT NULL THEN
               ERROR p_msg
               NEXT FIELD num_conhec
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0778_popup()

   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0778_checa_existencia(p_op)
#-------------------------------------#
   
   DEFINE p_op CHAR(01)
   
   INITIALIZE p_chave, p_cod_transpor, p_msg TO NULL
   
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "

   IF p_info.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED,    
          " AND dat_emis_conhec BETWEEN '",p_info.dat_ini,"' AND '",p_info.dat_fim,"' "
   END IF

   IF p_info.cod_transpor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_transpor = '",p_info.cod_transpor,"' "
   END IF

   IF p_info.num_conhec IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND num_conhec = '",p_info.num_conhec,"' "
   END IF

   IF p_info.ser_conhec IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND ser_conhec = '",p_info.ser_conhec,"' "
   END IF

   IF p_info.ssr_conhec IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND ssr_conhec = '",p_info.ssr_conhec,"' "
   END IF

   LET p_query =  "SELECT cod_transpor, num_conhec, ser_conhec, ",
                  " ssr_conhec, dat_emis_conhec, val_frete, ",
                  " val_tot_icms_frt_d, val_tot_icms_frt_c ",
                  " FROM frete_sup WHERE ",p_chave CLIPPED,
                  " ORDER BY cod_transpor, dat_emis_conhec"

   PREPARE query_frete_sup FROM p_query    
   
   IF p_op = 'C' THEN
      
      DECLARE cq_checa CURSOR FOR query_frete_sup
      
      FOREACH cq_checa INTO p_cod_transpor
         EXIT FOREACH
      END FOREACH
      
      IF p_cod_transpor IS NULL THEN
         LET p_msg = 'NAO H� CONHECIMENTO DE FRETE P/ OS PAR�METROS INFORMADOS!!!'
      END IF
   
   END IF   
              
END FUNCTION



#------------------------------#
FUNCTION pol0778_carrega_dados()
#------------------------------#

   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR query_frete_sup

   OPEN cq_padrao

   FETCH cq_padrao INTO 
         p_info.cod_transpor,
         p_info.num_conhec,
         p_info.ser_conhec,
         p_info.ssr_conhec,
         p_info.dat_emissao,
         p_info.val_frete_c,
         p_info.val_icms,
         p_val_icms_c

   IF SQLCA.SQLCODE = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de Pesquisa nao Encontrados",'excla')
      LET p_retorno = FALSE
   ELSE 
      CALL pol0778_exibe_dados() RETURNING p_retorno
   END IF

   RETURN(p_retorno)

END FUNCTION

#-----------------------------#
FUNCTION pol0778_exibe_dados()
#-----------------------------#


   IF p_info.val_icms IS NULL OR p_info.val_icms = 0 THEN
      LET p_info.val_icms = p_val_icms_c
   END IF

   LET p_cod_transpor = p_info.cod_transpor
   CALL pol0778_le_nome_transpor()

   DISPLAY BY NAME p_info.*
   
   IF NOT pol0778_le_solicit() THEN
      RETURN FALSE
   END IF

   DISPLAY BY NAME p_edita.*

   CALL SET_COUNT(p_index - 1)
 
   INPUT ARRAY pr_conhec 
      WITHOUT DEFAULTS FROM sr_conhec.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0778_le_solicit()
#----------------------------#

   INITIALIZE p_edita, pr_conhec TO NULL
   LET p_index = 1
   
   DECLARE cq_nf CURSOR FOR
    SELECT num_nff
      FROM frete_sup_x_nff
     WHERE cod_empresa = p_cod_empresa
       AND cod_transpor = p_info.cod_transpor
       AND num_conhec   = p_info.num_conhec
       AND ser_conhec   = p_info.ser_conhec
       AND ssr_conhec   = p_info.ssr_conhec
   
   FOREACH cq_nf INTO pr_conhec[p_index].num_nff

      SELECT num_nff_ref
        INTO p_num_nff
        FROM nf_referencia
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = pr_conhec[p_index].num_nff
         
      IF sqlca.sqlcode = 100 THEN
         LET p_num_nff = pr_conhec[p_index].num_nff
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','nf_referencia')
            RETURN FALSE
         END IF
      END IF
   
      SELECT cliente,
             peso_bruto
        INTO p_cod_cliente,
             pr_conhec[p_index].pes_nf
        FROM fat_nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = p_num_nff
         AND tip_nota_fiscal = 'FATPRDSV'
         AND espc_nota_fiscal = 'NFF'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre:2')
         RETURN FALSE
      END IF

      SELECT nom_reduzido
        INTO pr_conhec[p_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = p_cod_cliente

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','Clientes')
         RETURN FALSE
      END IF
         
      IF pr_conhec[p_index].nom_cliente IS NULL THEN
         LET pr_conhec[p_index].nom_cliente = p_cod_cliente
      END IF
      
      DECLARE cq_num_om CURSOR FOR
       SELECT num_om
         FROM ordem_montag_mest
        WHERE cod_empresa = p_cod_empresa
          AND num_nff     = pr_conhec[p_index].num_nff
      
      FOREACH cq_num_om INTO p_num_om
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','ordem_montag_mest')
            RETURN FALSE
         END IF
         EXIT FOREACH
      END FOREACH
      
      SELECT num_solicit,
             cod_cid_dest,
             val_frete,
             val_ger
        INTO p_num_solicit,
             p_cod_cidade,
             pr_conhec[p_index].val_frete_rod,
             pr_conhec[p_index].val_compl
        FROM solicit_fat_885
       WHERE cod_empresa = p_cod_empresa
         AND num_om      = p_num_om
         
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','solicit_fat_885')
         RETURN FALSE
      END IF

      IF p_edita.num_solicit IS NULL THEN
         LET p_edita.num_solicit = p_num_solicit
      END IF

      IF p_cod_cidade IS NULL THEN
         IF NOT pol0778_pega_cidade() THEN
            RETURN FALSE
         END IF
      END IF
      
      SELECT den_cidade
        INTO pr_conhec[p_index].cid_destino
        FROM cidades
       WHERE cod_cidade = p_cod_cidade
         
      IF sqlca.sqlcode = 100 THEN         
         LET pr_conhec[p_index].cid_destino = p_cod_cidade
      ELSE
         IF sqlca.sqlcode <> 0 THEN
            CALL log003_err_sql('Lendo','cidades:1')
            RETURN FALSE
         END IF
      END IF  

      LET p_index = p_index + 1
        
   END FOREACH
   
   SELECT num_chapa,
          cod_veiculo,
          cod_tip_carga,
          val_frete_tab,
          val_frete,
          val_frete_ofic,
          val_frete_ger,
          ies_validado
     INTO p_edita.num_chapa,
          p_edita.cod_veiculo,
          p_edita.cod_tip_carga,
          p_edita.val_frete_tab,
          p_edita.val_frete,
          p_edita.val_frete_ofic,
          p_edita.val_frete_ger,
          p_edita.ies_validado
     FROM frete_solicit_885
    WHERE cod_empresa  = p_cod_empresa
      AND num_solicit  = p_edita.num_solicit
      AND versao_atual = 'S'
            
   IF sqlca.sqlcode <> 0 AND sqlca.sqlcode <> 100 THEN
      CALL log003_err_sql('Lendo','frete_solicit_885')
      RETURN FALSE
   END IF
       
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0778_le_nome_transpor()
#---------------------------------#

   SELECT nom_cliente,
          nom_reduzido
     INTO p_nom_transpor,
          p_info.nom_transpor
     FROM clientes
    WHERE cod_cliente = p_cod_transpor
      AND cod_tip_cli IN (p_tip_transp, p_tip_transp_auto)

   IF sqlca.sqlcode <> 0 THEN
      LET p_nom_transpor      = 'Transportador n�o cadastrado!!!'
      LET p_info.nom_transpor = 'T. Inexistente'
   END IF
 
END FUNCTION

#-------------------------------#
FUNCTION pol0778_paginacao(p_fun)
#-------------------------------#

   DEFINE p_fun CHAR(01)

   IF p_fun = "S" THEN
      FETCH NEXT cq_padrao INTO 
         p_info.cod_transpor,
         p_info.num_conhec,
         p_info.ser_conhec,
         p_info.ssr_conhec,
         p_info.dat_emissao,
         p_info.val_frete_c,
         p_info.val_icms,
         p_val_icms_c
   ELSE
      FETCH PREVIOUS cq_padrao INTO 
         p_info.cod_transpor,
         p_info.num_conhec,
         p_info.ser_conhec,
         p_info.ssr_conhec,
         p_info.dat_emissao,
         p_info.val_frete_c,
         p_info.val_icms,
         p_val_icms_c
   END IF

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Nao Existem Mais Itens Nesta Dire��o"
   ELSE
      CALL pol0778_exibe_dados() RETURNING p_retorno
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0778_modificacao()
#-----------------------------#
   
   IF p_edita.ies_validado = 'S' THEN
      CALL log0030_mensagem('Frete est� validado. Modifica��o n�o permitida.','excla')
      RETURN FALSE
   END IF

   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_edita.*
         WITHOUT DEFAULTS 

      AFTER FIELD cod_veiculo
         SELECT cod_veiculo
           FROM veiculo_885
          WHERE cod_veiculo = p_edita.cod_veiculo
         
         IF sqlca.sqlcode = 100 THEN
            ERROR 'Veiculo n�o cadastrado !!!'
            NEXT FIELD cod_veiculo
         ELSE
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql('Lendo','veiculo_885')
               NEXT FIELD cod_veiculo
            END IF
         END IF
      
      AFTER FIELD cod_tip_carga
         IF p_edita.cod_tip_carga MATCHES '[MPB]' THEN
         ELSE
            ERROR 'Tipo inv�lido !!!'
            NEXT FIELD cod_tip_carga
         END IF

      AFTER FIELD val_frete_tab
         IF p_edita.val_frete_tab IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD val_frete_tab
         END IF
      
      AFTER FIELD val_frete
         IF p_edita.val_frete IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD val_frete
         END IF

      AFTER FIELD val_frete_ofic
         IF p_edita.val_frete_ofic IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD val_frete_ofic
         END IF

         IF p_edita.val_frete_ofic > p_edita.val_frete THEN
            ERROR 'Valor normal > valor contratado !!!'
            NEXT FIELD val_frete_ofic
         END IF
         
         LET p_edita.val_frete_ger = p_edita.val_frete - p_edita.val_frete_ofic
         DISPLAY p_edita.val_frete_ger TO val_frete_ger
         
      AFTER FIELD val_frete_ger
         IF p_edita.val_frete_ger IS NULL THEN
            ERROR 'Campo com preenchimento obrigat�rio!!!'
            NEXT FIELD val_frete_ger
         END IF
         LET p_tot_frete = p_edita.val_frete_ofic + p_edita.val_frete_ger
         IF p_tot_frete > p_edita.val_frete THEN
            ERROR 'Frete normal + frete ger. > valor contratado !!!'
            NEXT FIELD val_frete_ger
         END IF

      ON KEY (control-z)
         CALL pol0778_popup()
         
   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_checa_frete_solicit() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------------#
FUNCTION pol0778_checa_frete_solicit()
#------------------------------------#

   SELECT *
     INTO p_frete_solicit.*
     FROM frete_solicit_885
    WHERE cod_empresa  = p_cod_empresa
      AND num_solicit  = p_edita.num_solicit
      AND versao_atual = 'S'

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','frete_solicit_885')
      RETURN FALSE
   END IF

   IF p_frete_solicit.cod_veiculo    <> p_edita.cod_veiculo    OR
      p_frete_solicit.cod_tip_carga  <> p_edita.cod_tip_carga  OR
      p_frete_solicit.val_frete_tab  <> p_edita.val_frete_tab  OR
      p_frete_solicit.val_frete      <> p_edita.val_frete      OR
      p_frete_solicit.val_frete_ofic <> p_edita.val_frete_ofic OR
      p_frete_solicit.val_frete_ger  <> p_edita.val_frete_ger THEN

      SELECT COUNT(num_solicit)
        INTO p_count
        FROM frete_solicit_885
       WHERE cod_empresa  = p_cod_empresa
         AND num_solicit  = p_edita.num_solicit
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','frete_solicit_885')
         RETURN FALSE
      END IF
      
      IF p_count = 1 THEN
         IF NOT pol0778_insere_solicit() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0778_altera_solicit() THEN
            RETURN FALSE
         END IF
      END IF         
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------------#
FUNCTION pol0778_insere_solicit()
#--------------------------------#

   UPDATE frete_solicit_885
      SET versao_atual = 'N'
    WHERE cod_empresa  = p_cod_empresa
      AND num_solicit  = p_edita.num_solicit
      AND versao_atual = 'S'
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','frete_solicit_885')
      RETURN FALSE
   END IF

   LET p_frete_solicit.cod_veiculo    = p_edita.cod_veiculo
   LET p_frete_solicit.cod_tip_carga  = p_edita.cod_tip_carga
   LET p_frete_solicit.val_frete_tab  = p_edita.val_frete_tab
   LET p_frete_solicit.val_frete      = p_edita.val_frete
   LET p_frete_solicit.val_frete_ofic = p_edita.val_frete_ofic
   LET p_frete_solicit.val_frete_ger  = p_edita.val_frete_ger
   LET p_frete_solicit.versao_atual   = 'S'
   
   INSERT INTO frete_solicit_885
    VALUES(p_frete_solicit.*)
    
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Inserindo','frete_solicit_885')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0778_altera_solicit()
#--------------------------------#

   UPDATE frete_solicit_885
      SET cod_veiculo    = p_edita.cod_veiculo,
          cod_tip_carga  = p_edita.cod_tip_carga,
          val_frete_tab  = p_edita.val_frete_tab,
          val_frete      = p_edita.val_frete,
          val_frete_ofic = p_edita.val_frete_ofic,
          val_frete_ger  = p_edita.val_frete_ger
    WHERE cod_empresa  = p_cod_empresa
      AND num_solicit  = p_edita.num_solicit
      AND versao_atual = 'S'

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Alterado','frete_solicit_885')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0778_conhec_processar()
#----------------------------------#

   IF p_edita.ies_validado = 'S' THEN
      CALL log0030_mensagem('Frete j� est� validado.','excla')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN") 

   IF NOT pol0778_atualiza_solicit() THEN
      RETURN FALSE
   END IF

   LET p_edita.ies_validado = 'S'
   DISPLAY p_edita.ies_validado TO ies_validado
   
   IF NOT pol0778_copia_frete() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT") 

   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0778_atualiza_solicit()
#---------------------------------#
   
   UPDATE frete_solicit_885
      SET ies_validado = 'S'
    WHERE cod_empresa  = p_cod_empresa
      AND num_solicit  = p_edita.num_solicit
      AND versao_atual = 'S'
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','frete_solicit_885')
      RETURN FALSE
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0778_copia_frete()
#-----------------------------#

   IF NOT pol0778_copia_frete_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_copia_frete_sup_compl() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_copia_dest_frete_sup() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_copia_pedagio_frete() THEN
      RETURN FALSE
   END IF

   IF NOT pol0778_copia_sup_par_frete() THEN
      RETURN FALSE
   END IF
     
   IF NOT pol0778_insere_audit_frete() THEN
      RETURN FALSE
   END IF

#   IF NOT pol0778_insere_frete_sup_erro() THEN
#      RETURN FALSE
#   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0778_copia_frete_sup()
#---------------------------------#

   SELECT *
     INTO p_frete_sup.*
     FROM frete_sup
    WHERE cod_empresa  = p_cod_empresa
      AND num_conhec   = p_info.num_conhec
      AND ser_conhec   = p_info.ser_conhec
      AND ssr_conhec   = p_info.ssr_conhec
      AND cod_transpor = p_info.cod_transpor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','frete_sup')
      RETURN FALSE
   END IF

   LET p_frete_sup.cod_empresa         = p_cod_emp_ger

   LET p_frete_sup.ies_incid_icms_fre  = "C"

   LET p_frete_sup.val_tot_icms_frt_c  = 0
   LET p_frete_sup.val_tot_icms_frt_d  = 0
   LET p_frete_sup.val_icms_diferen    = 0

   LET p_frete_sup.val_frete           = p_edita.val_frete_ger
   LET p_frete_sup.val_frete_c         = p_frete_sup.val_frete
   LET p_frete_sup.val_base_c_frete_c  = p_frete_sup.val_frete
   LET p_frete_sup.val_base_c_frete_d  = p_frete_sup.val_frete
   LET p_frete_sup.val_adiant          = 0
   
   LET p_frete_sup.pct_icms_frete_c    = 0
   LET p_frete_sup.pct_red_bc_frete_c  = 0
   LET p_frete_sup.pct_diferen_fret_c  = 0

   LET p_frete_sup.ies_conhec_erro     = "N"
   LET p_frete_sup.ies_incl_cap        = "N"
   LET p_frete_sup.ies_incl_contab     = "N"

   INSERT INTO frete_sup VALUES(p_frete_sup.*)

   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","FRETE_SUP")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0778_copia_frete_sup_compl()
#--------------------------------------#

   SELECT *
     INTO p_frete_sup_compl.*
     FROM frete_sup_compl
    WHERE cod_empresa  = p_cod_empresa
      AND num_conhec   = p_info.num_conhec
      AND ser_conhec   = p_info.ser_conhec
      AND ssr_conhec   = p_info.ssr_conhec
      AND cod_transpor = p_info.cod_transpor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','frete_sup_compl')
      RETURN FALSE
   END IF

   LET p_frete_sup_compl.cod_empresa = p_frete_sup.cod_empresa

   INSERT INTO frete_sup_compl
        VALUES (p_frete_sup_compl.*)
        
   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","frete_sup_compl")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0778_copia_dest_frete_sup()
#--------------------------------------#

   SELECT *
     INTO p_dest_frete_sup.*
     FROM dest_frete_sup
    WHERE cod_empresa  = p_cod_empresa
      AND num_conhec   = p_info.num_conhec
      AND ser_conhec   = p_info.ser_conhec
      AND ssr_conhec   = p_info.ssr_conhec
      AND cod_transpor = p_info.cod_transpor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','dest_frete_sup')
      RETURN FALSE
   END IF

   LET p_dest_frete_sup.cod_empresa = p_frete_sup.cod_empresa
   
   INSERT INTO dest_frete_sup VALUES(p_dest_frete_sup.*)

   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","DEST_FRETE_SUP")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0778_copia_pedagio_frete()
#-------------------------------------#

   SELECT *
     INTO p_pedagio_frete.*
     FROM pedagio_frete
    WHERE cod_empresa    = p_cod_empresa
      AND num_nf_conhec  = p_info.num_conhec
      AND ser_nf_conhec  = p_info.ser_conhec
      AND ssr_nf_conhec  = p_info.ssr_conhec
      AND cod_fornecedor = p_info.cod_transpor

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','pedagio_frete')
      RETURN FALSE
   END IF

   LET p_pedagio_frete.cod_empresa = p_frete_sup.cod_empresa
   LET p_pedagio_frete.val_pedagio = 0
   
   INSERT INTO pedagio_frete VALUES(p_pedagio_frete.*)

   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","pedagio_frete")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol0778_copia_sup_par_frete()
#-------------------------------------#

   DECLARE cq_sup_par CURSOR FOR
    SELECT *
      FROM sup_par_frete
     WHERE empresa         = p_cod_empresa
       AND num_conhec      = p_info.num_conhec
       AND serie_conhec    = p_info.ser_conhec
       AND subserie_conhec = p_info.ssr_conhec
       AND transportadora  = p_info.cod_transpor

   FOREACH cq_sup_par  INTO p_sup_par_frete.*
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','sup_par_frete')
         RETURN FALSE
      END IF

      LET p_sup_par_frete.empresa = p_frete_sup.cod_empresa
   
      INSERT INTO sup_par_frete
           VALUES (p_sup_par_frete.*)
        
      IF sqlca.sqlcode <>  0 THEN
         CALL log003_err_sql("INSERT","sup_par_frete")
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0778_insere_audit_frete()
#-----------------------------------#
   
   LET p_audit_frete.cod_empresa    = p_frete_sup.cod_empresa
   LET p_audit_frete.num_conhec     = p_frete_sup.num_conhec
   LET p_audit_frete.ser_conhec     = p_frete_sup.ser_conhec
   LET p_audit_frete.ssr_conhec     = p_frete_sup.ssr_conhec
   LET p_audit_frete.cod_transpor   = p_frete_sup.cod_transpor
   LET p_audit_frete.nom_usuario    = p_user
   LET p_audit_frete.dat_hor_proces = CURRENT 
   LET p_audit_frete.num_prog       = 'POL0778'
   LET p_audit_frete.ies_tipo_auditoria = '1'
   
   INSERT INTO audit_frete
        VALUES (p_audit_frete.*)
        
   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","audit_frete")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol0778_insere_frete_sup_erro()
#--------------------------------------#

   LET p_frete_sup_erro.cod_empresa     = p_frete_sup.cod_empresa
   LET p_frete_sup_erro.cod_transpor    = p_frete_sup.cod_transpor
   LET p_frete_sup_erro.num_conhec      = p_frete_sup.num_conhec
   LET p_frete_sup_erro.ser_conhec      = p_frete_sup.ser_conhec
   LET p_frete_sup_erro.ssr_conhec      = p_frete_sup.ssr_conhec
   LET p_frete_sup_erro.des_pendencia   = 'FALTA CONSISTIR O DOCUMENTO'
   LET p_frete_sup_erro.ies_origem_erro = '2'
   LET p_frete_sup_erro.ies_erro_grave  = 'S'

   INSERT INTO frete_sup_erro
        VALUES (p_frete_sup_erro.*)
        
   IF sqlca.sqlcode <>  0 THEN
      CALL log003_err_sql("INSERT","frete_sup_erro")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#----------------------#
FUNCTION pol0778_notas()
#----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07781") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07781 AT 3,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar nota fiscal de servi�o "
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0778","IN")  THEN
            CALL pol0778_nota_informar() RETURNING p_status
            IF p_status THEN
               ERROR 'Par�metros informados com sucesso'
               NEXT OPTION 'Modificar'
            ELSE
               CLEAR FORM
               DISPLAY p_cod_empresa TO cod_empresa
               ERROR "Opera��o Cancelada !!!"
            END IF
         END IF 
      COMMAND "Modificar" "Modifica relacionamento com as notas de sa�da"
         IF p_ies_cons THEN
            IF p_ies_validado = 'N' THEN
               IF pol0778_notas_modificar() THEN
                  ERROR 'Opera��o efetuada com sucesso'
               ELSE
                  ERROR "Opera��o Cancelada !!!"
               END IF
            ELSE
               LET p_msg = 'Relacionamento j� efetivado!!!... modifica��o n�o permitida'
               CALL log0030_mensagem(p_msg,'exclamation')
               NEXT OPTION 'Informar'
            END IF
         ELSE
            ERROR 'Informe previamente os par�metros!!!'
            NEXT OPTION 'Informar'
         END IF 
      COMMAND "Processar" "Processa a efetiva��o do relacionamento "
         IF p_ies_validado = 'N' THEN
            CALL pol0778_nota_processar() RETURNING p_status
            IF p_status THEN
               ERROR 'Gera��o de nota efetuada com sucesso'
            ELSE
               ERROR "Opera��o Cancelada !!!"
            END IF
         ELSE
            LET p_msg = 'Relacionamento j� efetivado!!!... Opera��o n�o permitida'
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT OPTION 'Informar'
         END IF         
      COMMAND "Excluir" "Cancela a efetiva��o do relacionamento "
         IF p_ies_cons THEN
            IF p_ies_validado = 'S' THEN
               IF pol0778_nota_excluir() THEN
                  ERROR 'Opera��o efetuada com sucesso'
               ELSE
                  ERROR "Opera��o Cancelada !!!"
               END IF
            ELSE
               LET p_msg = 'Relacionamento n�o efetivado!!!... opera��o n�o permitida'
               CALL log0030_mensagem(p_msg,'exclamation')
               NEXT OPTION 'Informar'
            END IF
         ELSE
            ERROR 'Informe previamente os par�metros!!!'
            NEXT OPTION 'Informar'
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
FUNCTION pol0778_nota_informar()
#-------------------------------#

   INITIALIZE p_nota TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
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
            ERROR "NF inexistente ou n�o � nota de servi�o!!!"
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
                num_aviso_rec
           INTO p_nota.ser_nfe,
                p_nota.ssr_nfe,
                p_nota.esp_nfe,
                p_nota.dat_nfe,
                p_nota.val_nfe,
                p_val_tot_nf_c,
                p_nota.val_icm,
                p_val_tot_icms_nf_c,
                p_num_aviso_rec
           FROM nf_sup
          WHERE cod_empresa     = p_cod_empresa
            AND num_nf          = p_nota.num_nfe
            AND cod_fornecedor  = p_nota.cod_for
            AND (ies_especie_nf = 'NFS' OR 
                 ies_especie_nf = 'CON')
            
         IF sqlca.sqlcode <> 0 THEN
            LET p_msg = 'Nota de entrada inexistente!... ',
                        'Informe corretamente os par�metros.'
            CALL log0030_mensagem(p_msg,'exclamation')
            NEXT FIELD num_nfe
         END IF
         
         IF p_nota.val_nfe = 0  THEN
            LET p_nota.val_nfe = p_val_tot_nf_c
         END IF
         
         IF p_nota.val_icm = 0  THEN
            LET p_nota.val_icm = p_val_tot_icms_nf_c
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

      ON KEY (control-z)
         CALL pol0778_popup()

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
           val_compl,
           ies_validado
      FROM nfe_x_nff_885
     WHERE cod_empresa = p_cod_empresa
       AND num_nfe     = p_nota.num_nfe
       AND ser_nfe     = p_nota.ser_nfe
       AND ssr_nfe     = p_nota.ssr_nfe
       AND cod_for     = p_nota.cod_for

   FOREACH cq_n_x_s INTO 
           pr_nota[p_index].num_nff,
           pr_nota[p_index].val_frete_rod,
           pr_nota[p_index].val_frete_ger,
           p_ies_validado

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

   DISPLAY p_ies_validado TO ies_validado

   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_nota 
      WITHOUT DEFAULTS FROM sr_nota.*
   BEFORE INPUT
      EXIT INPUT
   END INPUT

   CALL pol0778_calc_tot_frete() 
   
   LET p_pct_desc = 100 - p_nota.pct_desc
   LET p_val_devido = p_nota.val_nfe * p_nota.pct_desc / p_pct_desc
   LET p_val_devido = p_val_devido + p_nota.val_nfe
   DISPLAY p_val_devido TO val_devido

   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0778_le_nf_mestre()
#------------------------------#

      SELECT a.peso_bruto,
             b.nom_reduzido,
             c.den_cidade,
             a.serie_nota_fiscal,
             a.status_nota_fiscal
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
         AND b.cod_cliente = a.cod_cliente
         AND c.cod_cidade  = b.cod_cidade
         AND tip_nota_fiscal = 'FATPRDSV'
         AND espc_nota_fiscal = 'NFF'

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql('Lendo','fat_nf_mestre:3')
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
FUNCTION pol0778_notas_modificar()
#--------------------------------#

   LET INT_FLAG = FALSE
   
   INPUT ARRAY pr_nota WITHOUT DEFAULTS FROM sr_nota.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
         CALL pol0778_calc_tot_frete() 

      AFTER FIELD val_frete_ger

         IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 THEN
         ELSE
            IF pr_nota[p_index].val_frete_ger IS NULL THEN
               ERROR 'Campo c/ preenchimento obrigat�rio!!!'
               NEXT FIELD val_frete_ger
            END IF
         END IF
         
         LET pr_nota[p_index].val_frete_tot =
             pr_nota[p_index].val_frete_rod + pr_nota[p_index].val_frete_ger
         
         DISPLAY pr_nota[p_index].val_frete_tot TO sr_nota[s_index].val_frete_tot
        
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0778_grava_nota() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF
   
   CALL log085_transacao("COMMIT")

   RETURN TRUE

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

   LET p_soma_nfs = p_tot_frete_ger + p_nota.val_nfe
   DISPLAY p_tot_frete_rod TO tot_frete_rod
   DISPLAY p_tot_frete_ger TO tot_frete_ger
   DISPLAY p_tot_frete_tot TO tot_frete_tot
   DISPLAY p_soma_nfs      TO soma_nfs

END FUNCTION


#----------------------------#
FUNCTION pol0778_grava_nota()
#----------------------------#

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_nota[p_ind].num_nff IS NOT NULL THEN
          UPDATE nfe_x_nff_885
             SET val_compl = pr_nota[p_ind].val_frete_ger
           WHERE cod_empresa = p_cod_empresa
             AND num_nff     = pr_nota[p_ind].num_nff

          IF sqlca.sqlcode <> 0 THEN
             CALL log003_err_sql('Update','nfe_x_nff_885')
             RETURN FALSE
          END IF
       END IF
   END FOR
       
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0778_nota_processar()
#--------------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0778_copia_nfe() THEN
      CALL log085_transacao("ROLLBACK") 
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT") 
      RETURN TRUE
   END IF   

END FUNCTION

#---------------------------#
FUNCTION pol0778_copia_nfe()
#---------------------------#

   IF NOT pol0778_gera_num_ar() THEN
      RETURN FALSE
   END IF

   IF NOT pol078_copia_nf_sup() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol078_copia_aviso_rec() THEN
      RETURN FALSE
   END IF

   LET p_num_nota = p_nota.num_nfe
   LET p_flag = 'S'
   
   IF NOT pol0778_atualiza_nfe() THEN
      RETURN FALSE
   END IF

   LET p_ies_validado = 'S'
   DISPLAY p_ies_validado TO ies_validado
   
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

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Atualizando','nfe_x_nff_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE
       
END FUNCTION

#-----------------------------#
 FUNCTION pol0778_gera_num_ar()
#-----------------------------#

   SELECT par_val    
     INTO p_num_prx_ar 
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_emp_ger   
      AND cod_parametro = "num_prx_ar" 

    IF sqlca.sqlcode <>   0   THEN 
       CALL log003_err_sql("SELECT" ,"PAR_SUP_PAD")
       RETURN FALSE
    END IF

    UPDATE par_sup_pad  
       SET par_val = (par_val + 1)
     WHERE cod_empresa   = p_cod_emp_ger    
       AND cod_parametro = "num_prx_ar" 

   RETURN TRUE
          
END FUNCTION

#-----------------------------#
FUNCTION pol078_copia_nf_sup()
#-----------------------------#

   SELECT *
     INTO p_nf_sup.*
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Lendo','nf_sup:2')
      RETURN FALSE
   END IF
   
   LET p_nf_sup.cod_empresa       = p_cod_emp_ger
   LET p_nf_sup.num_aviso_rec     = p_num_prx_ar
   LET p_nf_sup.val_tot_nf_c      = p_tot_frete_ger
   LET p_nf_sup.val_tot_nf_d      = p_tot_frete_ger
   LET p_nf_sup.val_tot_icms_nf_d = 0
   LET p_nf_sup.val_tot_icms_nf_c = 0
   LET p_nf_sup.val_tot_desc      = 0
   LET p_nf_sup.val_tot_acresc    = 0
   LET p_nf_sup.val_ipi_nf        = 0
   LET p_nf_sup.val_ipi_calc      = 0
   LET p_nf_sup.val_despesa_aces  = 0
   LET p_nf_sup.val_adiant        = 0
   LET p_nf_sup.ies_incl_contab   = 'N'
   LET p_nf_sup.val_bc_subst_d    = 0
   LET p_nf_sup.val_icms_subst_d  = 0
   LET p_nf_sup.val_bc_subst_c    = 0
   LET p_nf_sup.val_icms_subst_c  = 0
   LET p_nf_sup.val_imp_renda     = 0
   LET p_nf_sup.val_bc_imp_renda  = 0
   LET p_nf_sup.ies_incl_cap      = 'N'
   LET p_nf_sup.ies_nf_com_erro   = 'N'
   
   INSERT INTO nf_sup VALUES (p_nf_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","NF_SUP")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol078_copia_aviso_rec()
#--------------------------------#

   DECLARE cq_ar CURSOR FOR
    SELECT * 
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso_rec
   
   FOREACH cq_ar INTO p_aviso_rec.*
   
      IF sqlca.sqlcode <> 0   THEN 
         CALL log003_err_sql("Lendo" ,"aviso_rec:1")
         RETURN FALSE
      END IF
      
      LET p_val_liq = p_aviso_rec.val_liquido_item / p_nota.val_nfe * p_tot_frete_ger

      LET p_aviso_rec.cod_empresa          = p_nf_sup.cod_empresa
      LET p_aviso_rec.num_aviso_rec        = p_nf_sup.num_aviso_rec
      LET p_aviso_rec.val_liquido_item     = p_val_liq
      LET p_aviso_rec.val_base_c_item_d    = p_val_liq
      LET p_aviso_rec.val_base_c_item_c    = p_val_liq
      LET p_aviso_rec.pre_unit_nf          = p_val_liq / p_aviso_rec.qtd_declarad_nf

      CALL pol0778_inicializa_campos()
      
      INSERT INTO aviso_rec VALUES (p_aviso_rec.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","AVISO_REC")
         RETURN FALSE
      END IF

      IF NOT pol0778_copia_tabs_compl() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
FUNCTION pol0778_inicializa_campos()
#-----------------------------------#

   LET p_aviso_rec.val_despesa_aces_i   = 0
   LET p_aviso_rec.pct_ipi_declarad     = 0
   LET p_aviso_rec.pct_ipi_tabela       = 0
   LET p_aviso_rec.ies_tip_incid_ipi    = 'O'
   LET p_aviso_rec.ies_incid_icms_ite   = 'O'
   LET p_aviso_rec.cod_incid_ipi        = 3 
   LET p_aviso_rec.val_base_c_ipi_it    = 0
   LET p_aviso_rec.val_base_c_ipi_da    = 0
   LET p_aviso_rec.val_ipi_decl_item    = 0
   LET p_aviso_rec.val_ipi_calc_item    = 0
   LET p_aviso_rec.val_ipi_desp_aces    = 0
   LET p_aviso_rec.val_desc_item        = 0
   LET p_aviso_rec.val_desc_item        = 0
   LET p_aviso_rec.qtd_devolvid         = 0
   LET p_aviso_rec.val_devoluc          = 0
   LET p_aviso_rec.qtd_rejeit           = 0
   LET p_aviso_rec.qtd_liber_excep      = 0 
   LET p_aviso_rec.cus_tot_item         = 0 
   LET p_aviso_rec.num_lote             = NULL
   LET p_aviso_rec.pct_icms_item_c      = 0
   LET p_aviso_rec.pct_icms_item_d      = 0
   LET p_aviso_rec.pct_red_bc_item_d    = 0                             
   LET p_aviso_rec.pct_red_bc_item_c    = 0                             
   LET p_aviso_rec.pct_diferen_item_d   = 0                             
   LET p_aviso_rec.pct_diferen_item_c   = 0
   LET p_aviso_rec.val_icms_item_d      = 0
   LET p_aviso_rec.val_icms_item_c      = 0
   LET p_aviso_rec.val_base_c_icms_da   = 0                                
   LET p_aviso_rec.val_icms_diferen_i   = 0                                
   LET p_aviso_rec.val_icms_desp_aces   = 0                                
   LET p_aviso_rec.val_icms_desp_aces   = 0                                
   LET p_aviso_rec.val_frete            = 0 
   LET p_aviso_rec.val_base_c_frete_d   = 0 
   LET p_aviso_rec.val_base_c_frete_c   = 0 
   LET p_aviso_rec.val_icms_frete_d     = 0 
   LET p_aviso_rec.val_icms_frete_c     = 0 
   LET p_aviso_rec.pct_icms_frete_d     = 0 
   LET p_aviso_rec.pct_icms_frete_c     = 0 
   LET p_aviso_rec.val_icms_diferen_f   = 0                                
   LET p_aviso_rec.pct_red_bc_frete_d   = 0                                
   LET p_aviso_rec.pct_red_bc_frete_c   = 0                                
   LET p_aviso_rec.pct_diferen_fret_d   = 0                                
   LET p_aviso_rec.pct_diferen_fret_c   = 0                                
   LET p_aviso_rec.val_acrescimos       = 0                                
   LET p_aviso_rec.val_enc_financ       = 0                                
   LET p_aviso_rec.val_compl_estoque    = 0                                
   LET p_aviso_rec.pct_enc_financ       = 0                                

END FUNCTION

#----------------------------------#
FUNCTION pol0778_copia_tabs_compl()
#----------------------------------#

   LET p_audit_ar.nom_usuario    = p_user
   LET p_audit_ar.dat_hor_proces = CURRENT
   LET p_audit_ar.ies_tipo_auditoria = '1'
   LET p_audit_ar.cod_empresa    = p_aviso_rec.cod_empresa
   LET p_audit_ar.num_aviso_rec  = p_aviso_rec.num_aviso_rec
   LET p_audit_ar.num_seq        = p_aviso_rec.num_seq
   LET p_audit_ar.num_prog       = 'pol0778'
      
   INSERT INTO audit_ar VALUES(p_audit_ar.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","audit_ar")
      RETURN FALSE
   END IF       

   SELECT *
     INTO p_dest_ar.*
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq       = p_aviso_rec.num_seq

   IF sqlca.sqlcode = 0 THEN
      LET p_dest_ar.cod_empresa        = p_aviso_rec.cod_empresa  
      LET p_dest_ar.num_aviso_rec      = p_aviso_rec.num_aviso_rec

      INSERT INTO dest_aviso_rec VALUES (p_dest_ar.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","DEST_AVISO_REC")
         RETURN FALSE
      END IF       

   END IF

   SELECT *
     INTO p_ar_compl.*
     FROM aviso_rec_compl
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq       = p_aviso_rec.num_seq

   IF sqlca.sqlcode = 0 THEN     
      INSERT INTO aviso_rec_compl          
          VALUES (p_ar_compl.*)
      
      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","AVISO_REC_COMPL")
         RETURN FALSE
      END IF       
   END IF
   
   SELECT *
     INTO p_ar_sq.*
     FROM aviso_rec_compl_sq
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
      AND num_seq       = p_aviso_rec.num_seq
    
   IF sqlca.sqlcode = 0 THEN     
      LET p_ar_sq.cod_empresa       =  p_aviso_rec.cod_empresa
      LET p_ar_sq.num_aviso_rec     =  p_aviso_rec.num_aviso_rec
      LET p_ar_sq.val_base_d_ipi_it =  0

      INSERT INTO aviso_rec_compl_sq VALUES (p_ar_sq.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","AVISO_REC_COMPL_SQ")
         RETURN FALSE
      END IF       
   END IF

{   INSERT INTO 
      nf_sup_erro(empresa,
                  num_aviso_rec,
                  num_seq,
                  des_pendencia_item,
                  ies_origem_erro,
                  ies_erro_grave)
           VALUES(p_aviso_rec.cod_empresa,
                  p_aviso_rec.num_aviso_rec,
                  p_aviso_rec.num_seq,
                  'Falta efetuar a consistencia do documento',
                  '2',
                  'S')

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERINDO","NF_SUP_ERRO")
      RETURN FALSE
   END IF       
}
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0778_nota_excluir()
#------------------------------#

   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   CALL log085_transacao("BEGIN")

   IF NOT pol0778_nota_exclui_relac() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   ELSE
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   END IF   

END FUNCTION

#----------------------------------#
FUNCTION pol0778_nota_exclui_relac()
#----------------------------------#

   SELECT num_aviso_rec,
          ies_nf_com_erro
     INTO p_num_aviso_ger,
          p_ies_nf_com_erro
     FROM nf_sup
    WHERE cod_empresa = p_cod_emp_ger
      AND num_nf      = p_nota.num_nfe
      AND ser_nf      = p_nota.ser_nfe
      AND ssr_nf      = p_nota.ssr_nfe
      AND ies_especie_nf = 'NFS'
      AND cod_fornecedor = p_nota.cod_for

   IF sqlca.sqlcode = 0 THEN 
      IF p_ies_nf_com_erro <> 'S' THEN
         CALL log0030_mensagem('NF j� consistida. Opera��o n�o permitida','exclamation')
         RETURN TRUE
      END IF
      IF NOT pol0778_nota_exclui_nf_sup() THEN
         RETURN FALSE
      END IF
      IF NOT pol0778_nota_exclui_ar() THEN
         RETURN FALSE
      END IF
   ELSE
      IF sqlca.sqlcode <> 100 THEN
         CALL log003_err_sql('Lendo','nf_sup:3')
         RETURN FALSE 
      END IF
   END IF
   
   LET p_num_nota = NULL
   LET p_flag = 'N'

   IF NOT pol0778_atualiza_nfe() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_validado = 'N'
   DISPLAY p_ies_validado TO ies_validado
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0778_nota_exclui_nf_sup()
#------------------------------------#

   DELETE FROM nf_sup
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','nf_sup:')
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0778_nota_exclui_ar()
#--------------------------------#

   DELETE FROM aviso_rec
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','aviso_rec:')
      RETURN FALSE 
   END IF

   DELETE FROM aviso_rec_compl_sq
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','aviso_rec_compl_sq:')
      RETURN FALSE 
   END IF

   DELETE FROM audit_ar
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','audit_ar:')
      RETURN FALSE 
   END IF

   DELETE FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','dest_aviso_rec:')
      RETURN FALSE 
   END IF

   DELETE FROM aviso_rec_compl_sq
    WHERE cod_empresa   = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','aviso_rec_compl_sq:')
      RETURN FALSE 
   END IF

   DELETE FROM nf_sup_erro
    WHERE empresa       = p_cod_emp_ger
      AND num_aviso_rec = p_num_aviso_ger
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql('Deletando','nf_sup_erro:')
      RETURN FALSE 
   END IF

   RETURN TRUE

END FUNCTION


#--------------FIM DO PROGRAMA----------------------#