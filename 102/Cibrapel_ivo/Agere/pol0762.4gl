#-------------------------------------------------------------------#
# SISTEMA.: SUPRIMENTOS                                             #
# PROGRAMA: pol0762                                                 #
# OBJETIVO: CONSULTA MOVIMENTOS DE ENTADA                           #
# CLIENTE.: CIBRAPEL                                                #
# DATA....: 29/02/08                                                #
# POR.....: IVO H BARBOSA                                           #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS

   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
        	p_den_empresa        LIKE empresa.den_empresa,
        	p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa

   DEFINE p_tela               RECORD         
          num_ar               LIKE aviso_rec.num_aviso_rec,
          num_nf               LIKE nf_sup.num_nf,
          ser_nf               LIKE nf_sup.ser_nf,
          ssr_nf               LIKE nf_sup.ssr_nf,
          dat_emis_nf          LIKE nf_sup.dat_emis_nf,
          cod_fornecedor       LIKE nf_sup.cod_fornecedor,
          raz_social           LIKE fornecedor.raz_social,
          dat_movto            LIKE ar_proces_885.dat_movto,
          pct_umid_pad         LIKE ar_proces_885.pct_umid_pad
   END RECORD

   DEFINE p_cabec              RECORD
          num_nf               LIKE nf_sup.num_nf,
          val_nf               LIKE nf_sup.val_tot_nf_c,
          num_aviso_rec        LIKE aviso_rec.num_aviso_rec,
          num_ad               LIKE ad_mestre.num_ad,
          val_ad               LIKE ad_mestre.val_tot_nf,
          val_adiant           LIKE adiant.val_adiant
   END RECORD
   
   DEFINE p_num_transac        INTEGER,
          p_index              SMALLINT,
          s_index              SMALLINT,
        	p_nom_arquivo        CHAR(100),
        	p_count              SMALLINT,
          p_rowid              SMALLINT,
        	p_houve_erro         SMALLINT,
          p_ies_cons           SMALLINT,
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
        	p_retorno            SMALLINT,
        	p_ind                SMALLINT,
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),       	 
        	p_status             SMALLINT,
       	  p_caminho            CHAR(100),
       	  comando              CHAR(80),
          p_versao             CHAR(18),
          p_msg                CHAR(75),
          sql_stmt             CHAR(500),
          where_clause         CHAR(500)
         
   DEFINE pr_itens             ARRAY[50] OF RECORD
          num_sequencia        LIKE pesagem_aparas_885.num_sequencia,
          cod_item             LIKE pesagem_aparas_885.cod_item,
          num_lote             LIKE pesagem_aparas_885.num_lote,
          qtd_lote             LIKE pesagem_aparas_885.qtd_lote,
          qtd_fardos           LIKE pesagem_aparas_885.qtd_fardos,
          pct_umid_med         LIKE pesagem_aparas_885.pct_umid_med,
          qtd_pesagem          LIKE pesagem_aparas_885.qtd_pesagem
   END RECORD

   DEFINE pr_movto             ARRAY[50] OF RECORD
          cod_item             LIKE estoque_trans.cod_item,
          num_lote             LIKE estoque_trans.num_lote_dest,
          cod_operacao         LIKE estoque_trans.cod_operacao,
          qtd_movto            LIKE estoque_trans.qtd_movto,
          val_movto            LIKE estoque_trans.cus_tot_movto_p
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 10
   DEFER INTERRUPT 
   LET p_versao = "pol0762-05.10.01"
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0762.iem") RETURNING p_nom_help
   LET  p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
        NEXT KEY control-f,
        PREVIOUS KEY control-b,
        DELETE KEY control-e

   CALL log001_acessa_usuario("VDP","LIC_LIB")     
       RETURNING p_status, p_cod_empresa, p_user
   
   IF p_status = 0 THEN
      CALL pol0762_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0762_controle()
#--------------------------#
   
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol0762") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0762 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0762_le_parametros() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros p/ Consulta"
         IF pol0762_informar() THEN
            CALL pol0762_exibe_dados()
         END IF
         ERROR p_msg
      COMMAND "Movimentos" "Exibe os Movimentos Efetuados"
         IF p_ies_cons THEN
            CALL pol0762_exibe_movtos()
         ELSE
            ERROR 'Informe previamente os parâmetros!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
 
   CLOSE WINDOW w_pol0762

END FUNCTION

#------------------------------#
FUNCTION pol0762_le_parametros()
#------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------#
FUNCTION pol0762_informar()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela TO NULL
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS

      AFTER FIELD num_ar
 
         IF p_tela.num_ar IS NULL THEN
            ERROR 'Campo com preenchimento obrigatário'
            NEXT FIELD num_ar
         END IF
 
         SELECT dat_movto,
                pct_umid_pad
           INTO p_tela.dat_movto,
                p_tela.pct_umid_pad
           FROM ar_proces_885
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_tela.num_ar
         
         IF STATUS = 100 THEN
            ERROR 'Aviso de Recebimento sem Movimentos'
            NEXT FIELD num_ar
         END IF
         
         IF NOT pol0762_le_nf_sup() THEN
            NEXT FIELD num_ar
         END IF

         DISPLAY BY NAME p_tela.*

   END INPUT

   IF INT_FLAG THEN
      LET p_ies_cons = FALSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      LET p_msg = 'Operação Cancelada'
      RETURN FALSE
   ELSE
      LET p_msg = 'Parâmetros Informados c/ Sucesso'
      LET p_ies_cons = TRUE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0762_le_nf_sup()
#---------------------------#

   SELECT num_nf,
          ser_nf,
          ssr_nf,
          dat_emis_nf,
          cod_fornecedor
     INTO p_tela.num_nf,
          p_tela.ser_nf,
          p_tela.ssr_nf,
          p_tela.dat_emis_nf,
          p_tela.cod_fornecedor
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup:1")       
      RETURN FALSE
   END IF
   
   SELECT raz_social
     INTO p_tela.raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","fornecedor")       
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-----------------------------#
FUNCTION pol0762_exibe_dados()
#-----------------------------#

   INITIALIZE pr_itens TO NULL
   
   SELECT COUNT(num_aviso_rec)
     INTO p_count
     FROM pesagem_aparas_885
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_tela.num_ar

   IF p_count = 0 THEN
      RETURN
   END IF

   LET p_index = 1
   
   DECLARE cq_dados CURSOR FOR
    SELECT num_sequencia,
           cod_item,
           num_lote,
           qtd_lote,
           qtd_fardos,
           pct_umid_med,
           qtd_pesagem
      FROM pesagem_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_tela.num_ar

   FOREACH cq_dados INTO pr_itens[p_index].*
      LET p_index = p_index + 1
      IF p_index > 50 THEN
         CALL log0030_mensagem('Linite de linhas da grade ultapassado','exclamation')
         EXIT FOREACH
      END IF
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
    
   IF ARR_COUNT() > 10 THEN
      DISPLAY ARRAY pr_itens TO sr_itens.*
   ELSE
      INPUT ARRAY pr_itens WITHOUT DEFAULTS FROM sr_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol0762_exibe_movtos()
#------------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol07621") RETURNING p_nom_tela
   LET  p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07621 AT 4,3 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE p_cabec TO NULL
   
   SELECT num_nf,
          val_tot_nf_c,
          num_aviso_rec
     INTO p_cabec.num_nf,
          p_cabec.val_nf,
          p_cabec.num_aviso_rec
     FROM nf_sup
    WHERE cod_empresa    = p_cod_emp_ger
      AND num_nf         = p_tela.num_nf
      AND ser_nf         = p_tela.ser_nf
      AND ssr_nf         = p_tela.ssr_nf
      AND cod_fornecedor = p_tela.cod_fornecedor
   
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','nf_sup')
      RETURN 
   END IF
   
   SELECT val_adiant
     INTO p_cabec.val_adiant
     FROM adiant
    WHERE cod_empresa    = p_cod_emp_ofic
      AND num_ad_nf_orig = p_tela.num_nf
      AND ser_nf         = p_tela.ser_nf
      AND ssr_nf         = p_tela.ssr_nf
      AND cod_fornecedor = p_tela.cod_fornecedor

   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','adiant')
      RETURN 
   END IF
   
   SELECT num_ad,
          val_tot_nf
     INTO p_cabec.num_ad,
          p_cabec.val_ad
     FROM ad_mestre
    WHERE cod_empresa    = p_cod_emp_ger
      AND num_nf         = p_tela.num_nf
      AND ser_nf         = p_tela.ser_nf
      AND ssr_nf         = p_tela.ssr_nf
      AND cod_fornecedor = p_tela.cod_fornecedor
    
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','ad_mestre')
      RETURN 
   END IF
   
   DISPLAY BY NAME p_cabec.*

   LET p_ind = 1
   
   DECLARE cq_trans CURSOR FOR
    SELECT cod_item,
           num_lote_dest,
           cod_operacao,
           qtd_movto,
           cus_tot_movto_p
      FROM estoque_trans  a,
           ar_transac_885 b        
     WHERE a.cod_empresa = p_cod_emp_ger
       AND a.cod_empresa = b.cod_empresa
       AND a.num_transac = b.num_transac
       AND b.num_ar      = p_tela.num_ar
   
   FOREACH cq_trans INTO 
           pr_movto[p_ind].cod_item,
           pr_movto[p_ind].num_lote,
           pr_movto[p_ind].cod_operacao,
           pr_movto[p_ind].qtd_movto,
           pr_movto[p_ind].val_movto
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Estoque_trans')
         RETURN
      END IF
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 50 THEN
         CALL log0030_mensagem('Linite de linhas da grade ultapassado','exclamation')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)
   
   DISPLAY ARRAY pr_movto TO sr_movto.*
   
   CLOSE WINDOW w_pol07621
   
END FUNCTION
