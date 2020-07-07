#-------------------------------------------------------------------#
# OBJETIVO:  CÓPIA ENTRADA DE APARAS                                #
# DATA....: 28/04/2008                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_cod_emp_ad         LIKE empresa.cod_empresa,
          p_cod_emp_docum      LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_ar             LIKE aviso_rec.num_aviso_rec,
          p_cod_status         CHAR(01),
          p_ies_apara          SMALLINT,
          p_val_parcela        DECIMAL(15,2),
          p_dat_vencto         DATETIME YEAR TO DAY,
          p_descarta           SMALLINT,
          p_ies_info         SMALLINT,
          p_qtd_parcelas       INTEGER,
          p_imprimiu           SMALLINT,
          p_msg                CHAR(200),
          p_salto              SMALLINT,
          p_num_parcela        SMALLINT,
          p_comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_hora               DATETIME HOUR TO SECOND,
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_lista           SMALLINT,
          p_caminho            CHAR(080),
          p_chave              CHAR(600),
          p_query              CHAR(800),
          p_num_transac        INTEGER,
          p_de_para            SMALLINT,
          p_num_transac_de     INTEGER,
          p_sequencia          INTEGER,
          p_tip_movto          CHAR(01),
          p_qtd_txt            CHAR(11),
          p_val_pedagio        DECIMAL(10,2)          

END GLOBALS

   DEFINE p_dat_fecha_ultimo   LIKE par_sup.dat_fecha_ultimo
             
   DEFINE p_cod_item           LIKE item.cod_item,
          p_ies_liberacao_cont LIKE aviso_rec.ies_liberacao_cont,
          p_ies_liberacao_insp LIKE aviso_rec.ies_liberacao_insp,
          p_cod_familia        LIKE item.cod_familia,
          p_num_aviso          LIKE aviso_rec.num_aviso_rec,
          p_val_liq_ar         LIKE aviso_rec.val_liquido_item,
          p_val_gravado        LIKE aviso_rec.val_liquido_item,
          p_val_difer          LIKE aviso_rec.val_liquido_item,
          p_val_calculado      LIKE aviso_rec.val_liquido_item,
          p_val_movto          LIKE aviso_rec.val_liquido_item,
          p_pre_unit           LIKE aviso_rec.val_liquido_item,
          p_pre_calculado      LIKE cont_aparas_885.pre_calculado,
          p_num_ped_compra     LIKE aviso_rec.num_pedido,
          p_num_seq            LIKE cont_aparas_885.num_seq_ar,
          p_num_lote           LIKE cont_aparas_885.num_lote,
          p_qtd_fardo          LIKE cont_aparas_885.qtd_fardo,
          p_qtd_liber          LIKE cont_aparas_885.qtd_liber,
          p_qtd_liber_excep    LIKE cont_aparas_885.qtd_liber_excep,
          p_qtd_rejeit         LIKE cont_aparas_885.qtd_rejeit,
          p_tot_insp           LIKE cont_aparas_885.qtd_rejeit,
          p_pct_val_vencto     LIKE cond_pg_item_cap.pct_val_vencto,
          p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
          p_cod_oper_cval      LIKE parametros_885.cod_oper_ent_valor,
          p_cod_oper_cqv       LIKE parametros_885.cod_oper_ent_vrqtd,
          p_apara_nobre        LIKE parametros_885.cod_apara_nobre,
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_dat_movto          LIKE estoque_trans.dat_movto,
          p_num_docum          LIKE estoque_trans.num_docum,
          p_cod_cnd_pgto       LIKE cotacao_preco_885.cnd_pgto,
          p_cod_local          LIKE item.cod_local_estoq,
          p_num_nf             LIKE nf_sup.num_nf,
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
          p_cod_grp_despesa    LIKE grupo_despesa.cod_grp_despesa,
          p_cod_hist_deb_ap    LIKE tipo_despesa.cod_hist_deb_ap,
          p_qtd_dias           LIKE cond_pg_item_cap.qtd_dias,
          p_raz_social         LIKE fornecedor.raz_social,
          p_qtd_movto          LIKE estoque_trans.qtd_movto,
          p_num_conta          LIKE estoque_trans.num_conta,
          p_item_ar            LIKE aviso_rec.cod_item,
          p_cod_item_tr        LIKE aviso_rec.cod_item,
          p_local_item         LIKE item.cod_local_estoq,
          p_num_seq_ar         LIKE aviso_rec.num_seq,
          p_qtd_saldo          LIKE estoque_lote.qtd_saldo,
          p_qtd_excep          LIKE aviso_rec.qtd_liber_excep
          
         
   DEFINE p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_adiant             RECORD LIKE adiant.*,
          p_mov_adiant         RECORD LIKE mov_adiant.*,
          p_ad_mestre          RECORD LIKE ad_mestre.*,
          p_ap                 RECORD LIKE ap.*,
          p_lanc_cont_cap      RECORD LIKE lanc_cont_cap.*

   DEFINE p_cod_tip_movto      CHAR(01),
          p_ies_situa          CHAR(01)
         
   DEFINE p_tela               RECORD
          cod_fornecedor       LIKE fornecedor.cod_fornecedor,
          raz_social           LIKE fornecedor.raz_social,
          dat_ini              DATE,
          dat_fim              DATE
   END RECORD 

   DEFINE pr_nf                ARRAY[5000] OF RECORD
          cod_for              LIKE nf_sup.cod_fornecedor,
          nom_for              LIKE fornecedor.raz_social,
          num_nf               LIKE nf_sup.num_nf,
          dat_entrada          LIKE nf_sup.dat_entrada_nf,
          num_ar               LIKE nf_sup.num_aviso_rec,
          cod_status           CHAR(01)
   END RECORD

   DEFINE p_relat              RECORD
          cod_fornecedor       LIKE nf_sup.cod_fornecedor,
          nom_reduzido         LIKE fornecedor.raz_social_reduz,
          num_nf               LIKE nf_sup.num_nf,
          ser_nf               LIKE nf_sup.ser_nf,
          ssr_nf               LIKE nf_sup.ssr_nf,
          especie              LIKE nf_sup.ies_especie_nf,
          dat_entrada_nf       LIKE nf_sup.dat_entrada_nf,
          val_nf               LIKE nf_sup.val_tot_nf_c,
          num_ar               LIKE nf_sup.num_aviso_rec
   END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0888-10.02.00"
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0888.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0888_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0888_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0888") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0888 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0888_le_parametros() THEN
      RETURN FALSE
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar AR para o processamento "
         LET p_ies_lista = FALSE
         CALL pol0888_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
            LET p_ies_info = TRUE
            IF p_cod_status = 'I' THEN
               NEXT OPTION 'Exportar'
            ELSE
               IF p_cod_status = 'P' THEN
                  NEXT OPTION 'Reverter'
               END IF            
            END IF
         ELSE
            ERROR 'Operação cancelada !!!'
            LET p_ies_info = FALSE
         END IF
      COMMAND "Consultar" "Consulta os movimentos de entrada de aparas "
         LET p_ies_info = FALSE
         CALL pol0888_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Exportar" "Exportação AR para p/ Trim "
         IF p_ies_info THEN
            CALL pol0888_exportar() RETURNING p_status
            IF p_status THEN
               LET p_ies_info = FALSE
               CALL log0030_mensagem(p_msg,'excla')
            ELSE
               ERROR 'Operação cancelada!'
            END IF
         ELSE
            ERROR 'Informe o AR priviamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Reverter" "Reverção da exportação do AR"
         IF p_ies_info THEN
            CALL pol0888_reverter() RETURNING p_status
            IF p_status THEN
               LET p_msg="Operação efetuada com sucesso !!!"
               CALL log0030_mensagem(p_msg,'exclamation')
               LET p_ies_info = FALSE
            ELSE
               ERROR "Operação Cancelada !!!"
            END IF
         ELSE
            ERROR 'Informe o AR priviamente !!!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Listar" "Lista os dados da consulta "
         IF p_ies_lista THEN
            CALL pol0888_emite_relatorio()
         ELSE
            ERROR 'Execute a consulta previamente!'
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0888
   CLOSE WINDOW w_pol08882

END FUNCTION

#-------------------------------#
FUNCTION pol0888_le_parametros()
#-------------------------------#

   SELECT dat_fecha_ultimo
     INTO p_dat_fecha_ultimo
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","par_sup")       
      RETURN FALSE
   END IF
   
   SELECT cod_oper_ent_vrqtd,
          cod_oper_ent_valor,
          cod_apara_nobre
     INTO p_cod_oper_cqv,
          p_cod_oper_cval,
          p_apara_nobre
     FROM parametros_885
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","parametros_885")       
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0888_limpa_tela()
#----------------------------#

   INITIALIZE pr_nf, p_num_ar TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol0888_informar()
#--------------------------#
   
   CALL pol0888_limpa_tela()
      
   LET INT_FLAG = FALSE
   LET p_num_ar = NULL
   
   INPUT p_num_ar WITHOUT DEFAULTS FROM num_aviso

      AFTER FIELD num_aviso
      
         IF p_num_ar IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_aviso
         END IF
         
         SELECT cod_status
           INTO p_cod_status
           FROM ar_aparas_885 
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_num_ar
         
         IF STATUS <> 0 THEN
            ERROR 'AR não consta do processo de entrada de aparas !!!'
            NEXT FIELD num_aviso
         END IF
         
         DISPLAY p_cod_status TO ies_status 
         
   END INPUT

   IF INT_FLAG THEN
      CALL pol0888_limpa_tela()
      RETURN FALSE   
   END IF

   SELECT a.cod_fornecedor,
          b.raz_social
     INTO p_cod_fornecedor,
          p_raz_social
     FROM nf_sup a,
          fornecedor b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.num_aviso_rec  = p_num_ar
      AND b.cod_fornecedor = a.cod_fornecedor

   IF STATUS <> 0 THEN
      INITIALIZE p_cod_fornecedor,  p_raz_social TO NULL 
   END IF

   DISPLAY p_cod_fornecedor TO cod_fornecedor
   DISPLAY p_raz_social     TO raz_social
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0888_consultar()
#--------------------------#

   CALL pol0888_limpa_tela()
   
   LET INT_FLAG = FALSE
   LET p_tela.dat_ini = p_dat_fecha_ultimo + 1
   LET p_tela.dat_fim = TODAY
   DISPLAY p_dat_fecha_ultimo TO dat_fec
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD cod_fornecedor

         IF p_tela.cod_fornecedor IS NOT NULL THEN
            IF NOT pol0888_le_fornecedor() THEN
               ERROR p_msg
               NEXT FIELD cod_fornecedor
            END IF
         END IF
      
         DISPLAY p_tela.raz_social TO raz_social

      AFTER FIELD dat_ini
         IF p_tela.dat_ini IS NULL THEN
            ERROR 'Campo com preenchimento obrigatorio!!!'
            NEXT FIELD dat_ini
         END IF
         
         IF p_tela.dat_ini <= p_dat_fecha_ultimo THEN
            ERROR 'Data inicial deve ser maior que data do ultimo fechamento!!!'
            NEXT FIELD dat_ini
         END IF
         

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_fim IS NOT NULL THEN
               IF p_tela.dat_ini > p_tela.dat_fim THEN
                  ERROR "Data final menor que data inicial !!!"
                  NEXT FIELD dat_fim
               END IF 
            END IF
         END IF
            
      ON KEY (control-z)
         CALL pol0888_popup()

   END INPUT

   IF INT_FLAG  THEN
      CALL pol0888_limpa_tela()
      RETURN FALSE
   END IF
   
   IF NOT pol0888_exibe_dados() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0888_le_fornecedor()
#-------------------------------#

   SELECT raz_social
     INTO p_tela.raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_tela.cod_fornecedor

   IF STATUS <> 0 THEN
      LET p_msg = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol0888_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF

   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol0888_monta_select()
#------------------------------#
  
   LET p_chave = " cod_empresa = '", p_cod_empresa,"' "
   LET p_chave = p_chave CLIPPED, " AND ies_especie_nf != 'NFS' "
   LET p_chave = p_chave CLIPPED, " AND ies_especie_nf != 'CON' "
   
   IF p_tela.cod_fornecedor IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND cod_fornecedor = '",p_tela.cod_fornecedor,"' "
   END IF
 
   IF p_tela.dat_ini IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND dat_entrada_nf >= '",p_tela.dat_ini,"' "
   END IF

   IF p_tela.dat_fim IS NOT NULL THEN
      LET p_chave = p_chave CLIPPED, 
          " AND dat_entrada_nf <= '",p_tela.dat_fim,"' "
   END IF
       
   LET p_query = "SELECT DISTINCT cod_fornecedor, num_nf, ser_nf, ssr_nf, dat_entrada_nf, ",
                 "       val_tot_nf_c, num_aviso_rec, ies_especie_nf ",
                 "  FROM nf_sup WHERE ", p_chave CLIPPED,
                 " ORDER BY cod_fornecedor, num_aviso_rec "

   PREPARE var_query FROM p_query 

END FUNCTION

#-----------------------------#
FUNCTION pol0888_exibe_dados()
#-----------------------------#
   
   CALL pol0888_monta_select()

   DECLARE cq_nf CURSOR FOR var_query
   
   INITIALIZE pr_nf TO NULL
   
   LET p_index = 1
   
   FOREACH cq_nf INTO 
           pr_nf[p_index].cod_for,
           pr_nf[p_index].num_nf,
           p_ser_nf,
           p_ssr_nf,
           pr_nf[p_index].dat_entrada,
           p_val_nf,
           pr_nf[p_index].num_ar,
           p_especie

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Cursor','cq_nf')
         RETURN FALSE
      END IF
      
      LET p_num_aviso = pr_nf[p_index].num_ar

      DECLARE cq_aviso CURSOR FOR
       SELECT cod_item,
              ies_liberacao_cont,
              ies_liberacao_insp
         FROM aviso_rec
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_num_aviso
      
      LET p_ies_apara = FALSE
      
      FOREACH cq_aviso INTO p_cod_item, p_ies_liberacao_cont, p_ies_liberacao_insp
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Cursor','cq_aviso')
            RETURN FALSE
         END IF
         
         IF p_ies_liberacao_cont = 'N' AND p_ies_liberacao_insp = 'N' THEN
         ELSE
            SELECT cod_status
              FROM ar_aparas_885
             WHERE cod_empresa  = p_cod_empresa
               AND num_aviso_rec = p_num_aviso
               AND cod_status = 'I'
            IF STATUS = 100 THEN
               CONTINUE FOREACH
            ELSE 
               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo', 'ar_aparas_885:1')
                  RETURN FALSE
               END IF
            END IF
         END IF
         
         SELECT cod_familia
           INTO p_cod_familia
           FROM item
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item

         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF
           
         SELECT cod_empresa
           FROM familia_insumo_885 
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_cod_familia
            AND ies_apara   = 'S' 

         IF STATUS = 0 THEN
            LET p_ies_apara = TRUE
            EXIT FOREACH
         ELSE
            IF STATUS <> 100 THEN
               CALL log003_err_sql('lendo','familia_insumo_885')
               RETURN FALSE
            END IF
         END IF
      
      END FOREACH
      
      IF NOT p_ies_apara THEN
        CONTINUE FOREACH
      END IF
                  
      SELECT cod_status
        INTO pr_nf[p_index].cod_status
        FROM ar_aparas_885
       WHERE cod_empresa  = p_cod_empresa
         AND num_aviso_rec = p_num_aviso

      IF STATUS = 100 THEN
         LET pr_nf[p_index].cod_status = 'X'
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Cursor','ar_aparas_885:2')
            RETURN FALSE
         END IF
      END IF
            
      SELECT raz_social
        INTO pr_nf[p_index].nom_for
        FROM fornecedor
       WHERE cod_fornecedor = pr_nf[p_index].cod_for
       
      IF STATUS = 100 THEN
         LET pr_nf[p_index].nom_for = 'NÃO CADASTRADO'
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','fornecedor')
            RETURN FALSE
         END IF
      END IF
     
      LET p_index = p_index + 1
      
      IF p_index > 5000 THEN
         CALL log0030_mensagem('Limite de linhas da grade ultrapassou.','excla')
         EXIT FOREACH
      END IF
              
   END FOREACH
   
   IF p_index = 1 THEN
      LET p_msg = 'Não há notas para os parâmetros informados'
      CALL log0030_mensagem(p_msg,'excla')
      LET p_ies_lista = FALSE
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   LET p_index = p_index - 1
   CALL SET_COUNT(p_index)

   IF p_index > 9 THEN
      DISPLAY ARRAY pr_nf TO sr_nf.*
   ELSE
      INPUT ARRAY pr_nf
         WITHOUT DEFAULTS FROM sr_nf.*
         
         BEFORE INPUT
            EXIT INPUT
            
      END INPUT
   END IF         

   LET p_ies_lista = TRUE
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0888_e_aparas()
#--------------------------#

   DECLARE cq_ar2 CURSOR FOR
    SELECT cod_item
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso
      
   FOREACH cq_ar2 INTO 
           p_cod_item
      
      IF NOT pol0888_le_item() THEN
         RETURN FALSE
      END IF
      
      SELECT cod_familia
        FROM familia_insumo_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
         AND ies_apara   = 'S'
   
      IF STATUS = 100 THEN
         RETURN FALSE
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","familia_insumo_885")       
            RETURN FALSE
         END IF
      END IF
         
   END FOREACH
      
   RETURN TRUE 
   
END FUNCTION

#-------------------------#
FUNCTION pol0888_le_item()
#-------------------------#

   SELECT cod_familia,
          ies_ctr_estoque,
          cod_local_estoq
     INTO p_cod_familia,
          p_ies_ctr_estoque,
          p_cod_local
     FROM item
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item        = p_cod_item
         
   IF STATUS <> 0 THEN
      ERROR 'AR:',p_num_aviso,' Item:',p_cod_item
      CALL log003_err_sql('Lendo','item')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#---------------------------------#
FUNCTION pol0888_emite_relatorio()
#---------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0888.tmp"
         START REPORT pol0888_notas_lista TO p_caminho
      ELSE
         START REPORT pol0888_notas_lista TO p_nom_arquivo
      END IF
   END IF

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   CALL pol0888_monta_select()

   DECLARE cq_notas CURSOR FOR var_query
   
   INITIALIZE p_relat TO NULL
   
   FOREACH cq_notas INTO 
           p_relat.cod_fornecedor,
           p_relat.num_nf,
           p_relat.ser_nf,
           p_relat.ssr_nf,
           p_relat.dat_entrada_nf,
           p_relat.val_nf,
           p_relat.num_ar,
           p_relat.especie
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Cursor','cq_notas')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF
      
      SELECT num_aviso_rec
        FROM ar_aparas_885
       WHERE cod_empresa  = p_cod_empresa
        AND num_aviso_rec = p_relat.num_ar
    
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','ar_aparas_885')
            LET p_imprimiu = FALSE
            EXIT FOREACH
         END IF
      END IF

      SELECT raz_social_reduz
        INTO p_relat.nom_reduzido
        FROM fornecedor
       WHERE cod_fornecedor = p_relat.cod_fornecedor
       
      IF STATUS <> 100 AND STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_sup:cq_nf')
         LET p_imprimiu = FALSE
         EXIT FOREACH
      END IF

      DISPLAY p_relat.num_ar AT 21,35

      OUTPUT TO REPORT pol0888_notas_lista()

      LET p_imprimiu = TRUE
         
   
   END FOREACH
   
   FINISH REPORT pol0888_notas_lista

   MESSAGE "Fim do processamento " ATTRIBUTE(REVERSE)
   
   IF NOT p_imprimiu THEN
      ERROR "Não existem dados para serem listados. "
   ELSE
      IF p_ies_impressao = "S" THEN
         ERROR "Relatório impresso na impressora ", p_nom_arquivo
      ELSE
         ERROR "Relatório gravado no arquivo ", p_nom_arquivo
      END IF
   END IF

END FUNCTION

#--------------------------#
 REPORT pol0888_notas_lista()
#--------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 069, "PAG. ", PAGENO USING "&&&&"
               
         PRINT COLUMN 001, "pol0888",
               COLUMN 018, 'AVISOS DE RECEBIMENTOS NAO CONTEMPLADOS',
               COLUMN 059, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-----------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "  FORNECEDOR       NOME    NUM NF  SER SS ESP  EMISSAO     VALOR      NUM AR"
         PRINT COLUMN 001, "--------------- ---------- ------- --- -- --- ---------- ------------ -------"
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.cod_fornecedor,
               COLUMN 017, p_relat.nom_reduzido,
               COLUMN 028, p_relat.num_nf USING '#######',
               COLUMN 036, p_relat.ser_nf,
               COLUMN 040, p_relat.ssr_nf USING '##',
               COLUMN 043, p_relat.especie,
               COLUMN 047, p_relat.dat_entrada_nf USING 'dd/mm/yyyy',
               COLUMN 058, p_relat.val_nf USING '#,###,##&.&&',
               COLUMN 071, p_relat.num_ar USING '######'

      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 030, '* * * ULTIMA FOLHA * * *'
         
END REPORT


#--------------------------#
FUNCTION pol0888_exportar()
#--------------------------#

   IF p_cod_status <> 'I' THEN
      LET p_msg = 'O status atual do processo não permite essa operação !!!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
       
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   DROP TABLE contas_tmp_885

   IF STATUS = 0 OR STATUS -206 THEN 
 
      CREATE  TABLE contas_tmp_885(
          num_aviso_rec    DECIMAL(7,0),
          num_seq          DECIMAL(2,0),
          cod_tip_despesa  INTEGER,
          num_conta_deb    CHAR(15),
          num_conta_cred   CHAR(15),
          val_movto        DECIMAL(12,2)
       );
                 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","contas_tmp_885")
         RETURN FALSE
      END IF
   ELSE
      CALL log003_err_sql("Deleção","contas_tmp_885")
      RETURN FALSE
   END IF

   LET p_houve_erro = FALSE
   
   DECLARE cq_insp CURSOR WITH HOLD FOR
    SELECT num_aviso_rec,
           val_pedagio
      FROM ar_aparas_885
     WHERE cod_empresa = p_cod_empresa
       AND cod_status  = 'I'
       AND num_aviso_rec = p_num_ar
   
   FOREACH cq_insp INTO p_num_aviso, p_val_pedagio

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_insp')
         RETURN FALSE
      END IF
      
      DELETE FROM contas_tmp_885
      LET p_sequencia = 0
  
      CALL log085_transacao("BEGIN")
      IF NOT pol0896_inspciona_ar() THEN
         CALL log085_transacao("ROLLBACK")
         LET p_houve_erro = TRUE
      ELSE
         CALL log085_transacao("COMMIT")
      END IF
       
   END FOREACH
   
   IF p_houve_erro THEN
      LET p_msg = "Devido ao ploblema já exposto, o AR não foi exportado!"
   ELSE
      LET p_msg = "Processamento efetuado com sucesso!"
      DISPLAY 'P' TO ies_status
   END IF
      
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0896_inspciona_ar()
#------------------------------#

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
      AND num_aviso_rec = p_num_aviso

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup")       
      RETURN FALSE
   END IF

   UPDATE ar_aparas_885
      SET cod_status = "P"
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_num_aviso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','ar_aparas_885')
      RETURN FALSE
   END IF
  
   SELECT SUM(val_liquido_item)
     INTO p_val_liq_ar
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','aviso_rec')
      RETURN FALSE
   END IF
   
   IF p_val_liq_ar IS NULL THEN
      LET p_val_liq_ar = 0
   END IF
   
   LET p_val_calculado = 0
   
   DECLARE cq_aparas CURSOR FOR
    SELECT num_seq_ar,
           num_lote,
           qtd_fardo,
           qtd_liber,
           qtd_liber_excep,
           qtd_rejeit,
           pre_calculado,                #qtd_calculada * preco_cotacao
           dat_inspecao
      FROM cont_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso
     ORDER BY num_seq_ar

   FOREACH cq_aparas INTO
           p_num_seq,
           p_num_lote,
           p_qtd_fardo,
           p_qtd_liber,
           p_qtd_liber_excep,
           p_qtd_rejeit,
           p_pre_calculado,
           p_dat_movto
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_aparas')
         RETURN FALSE
      END IF
      
      LET p_num_docum = p_num_aviso
      LET p_val_calculado = p_val_calculado + p_pre_calculado
      LET p_tot_insp  = p_qtd_liber + p_qtd_liber_excep + p_qtd_rejeit # = qtd_contagem
      LET p_val_movto = p_pre_calculado 
      LET p_pre_unit  = p_pre_calculado / p_tot_insp 
      
      SELECT cod_item,
             cod_tip_despesa,
             num_pedido
        INTO p_cod_item,
             p_cod_tip_despesa,
             p_num_ped_compra
        FROM aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso
         AND num_seq       = p_num_seq
         
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','aviso_rec')
         RETURN FALSE
      END IF
                  
      IF NOT pol0888_le_item() THEN
         RETURN FALSE
      END IF

      IF p_ies_ctr_estoque <> 'S' THEN 
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0888_le_conta_deb() THEN
         RETURN FALSE
      END IF

      IF NOT pol0888_le_conta_cred() THEN
         RETURN FALSE
      END IF

      IF NOT pol0888_insere_contas() THEN
         RETURN FALSE
      END IF

      LET p_item_ar    = p_cod_item
      LET p_local_item = p_cod_local
      
      SELECT cod_item_tr
        INTO p_cod_item_tr
        FROM umd_aparas_885
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_aviso
         AND num_seq_ar    = p_num_seq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','umd_aparas_885')
         RETURN FALSE
      END IF
            
      LET p_cod_tip_movto = 'N'

      IF p_qtd_liber > 0 THEN 
         LET p_qtd_movto = p_qtd_liber
         LET p_ies_situa = 'L'
         IF NOT pol0888_insere_estoque() THEN 
            RETURN FALSE 
         END IF
      END IF  
      
      IF p_qtd_liber_excep > 0 THEN 
         LET p_qtd_movto = p_qtd_liber_excep
         LET p_ies_situa = 'E'
         IF NOT pol0888_insere_estoque() THEN 
            RETURN FALSE 
         END IF
      END IF  

      IF p_qtd_rejeit > 0 THEN 
         LET p_qtd_movto = p_qtd_rejeit
         LET p_ies_situa = 'R'
         IF NOT pol0888_insere_estoque() THEN 
            RETURN FALSE 
         END IF
      END IF  
  
      IF p_cod_item_tr IS NOT NULL THEN
         LET p_cod_item = p_cod_item_tr
      END IF
      
      IF NOT pol0888_atu_estoque() THEN
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET p_val_calculado = p_val_calculado + p_val_pedagio
   
   IF p_val_calculado > p_val_liq_ar THEN
      IF NOT pol0888_gera_ad() THEN
         RETURN FALSE
      END IF
   END IF 
   
   IF p_val_calculado < p_val_liq_ar THEN
      IF NOT pol0888_gera_adiantamento() THEN
         RETURN FALSE
      END IF
   END IF
  
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol0888_insere_estoque()
#--------------------------------#

   LET p_cod_item  = p_item_ar       
   LET p_cod_local = p_local_item 
   LET p_cod_operacao = p_cod_oper_cqv

   CALL pol0888_prep_est_trans()
   CALL pol0888_prep_trans_end() 
   
   LET p_tip_movto = 'E'
   
   IF NOT pol0888_insere_movtos() THEN
      RETURN FALSE
   END IF

   IF p_cod_item_tr IS NOT NULL THEN
      IF NOT pol0888_de_para() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF NOT pol0888_grava_lotes() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION
   
#--------------------------------#
FUNCTION pol0888_insere_movtos()
#--------------------------------#

   IF NOT pol0888_ins_est_trans() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0888_ins_trans_end() THEN
      RETURN FALSE
   END IF

   IF NOT pol0888_ins_est_auditoria() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0888_ins_insp_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0888_de_para()
#-------------------------#

   SELECT par_txt                                                                
     INTO p_cod_operacao                                                         
     FROM par_sup_pad                                                            
    WHERE cod_empresa   = p_cod_empresa                                          
      AND den_parametro = 'Operacao de Baixa de estoque itens orig.'             
                                                                                    
   IF STATUS <> 0 THEN     
      CALL log003_err_sql('Lendo','par_sup_pad:de')
      RETURN FALSE
   END IF
   
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.cod_local_est_orig = p_cod_local
   LET p_estoque_trans.num_lote_orig      = p_num_lote
   LET p_estoque_trans.ies_sit_est_orig   = p_ies_situa
   LET p_estoque_trans.num_lote_dest      = NULL
   LET p_estoque_trans.cod_local_est_dest = NULL
   LET p_estoque_trans.ies_sit_est_dest   = NULL   
   LET p_estoque_trans_end.cod_operacao   = p_estoque_trans.cod_operacao

   LET p_tip_movto = 'S'
   
  IF NOT pol0888_insere_movtos() THEN
      RETURN FALSE
   END IF

   LET p_num_transac_de = p_num_transac

   LET p_cod_item   = p_cod_item_tr
      
   SELECT cod_local_estoq
     INTO p_cod_local
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","item:local")       
      RETURN FALSE
   END IF      

   SELECT par_txt 
     INTO p_cod_operacao
	   FROM par_sup_pad
	  WHERE cod_empresa = p_cod_empresa
	    AND den_parametro = 'Operacao de Baixa de estoque itens dest.'        

   IF STATUS <> 0 THEN     
      CALL log003_err_sql('Lendo','par_sup_pad:para')
      RETURN FALSE
   END IF

   LET p_estoque_trans.cod_item           = p_cod_item
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.ies_sit_est_orig   = NULL
   LET p_estoque_trans.num_lote_orig      = NULL
   LET p_estoque_trans.cod_local_est_orig = NULL
   LET p_estoque_trans.num_lote_dest      = p_num_lote
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa   

   LET p_estoque_trans_end.cod_operacao   = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.cod_item       = p_estoque_trans.cod_item

   LET p_tip_movto = 'E'                                                       
   
   IF NOT pol0888_insere_movtos() THEN
      RETURN FALSE
   END IF

   IF NOT pol0888_ins_trans_relac() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol0888_ins_trans_relac()
#---------------------------------#

   DEFINE p_est_trans_relac RECORD LIKE est_trans_relac.*,
          p_num_nivel       INTEGER
   
   SELECT num_nivel
     INTO p_num_nivel
     FROM item_man
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_item_ar
   
   IF STATUS <> 0 THEN
      LET p_num_nivel = 0
   END IF

   LET p_est_trans_relac.cod_empresa      = p_cod_empresa
   LET p_est_trans_relac.num_transac_orig = p_num_transac_de
   LET p_est_trans_relac.num_transac_dest = p_num_transac
   LET p_est_trans_relac.cod_item_orig    = p_item_ar
   LET p_est_trans_relac.cod_item_dest    = p_estoque_trans.cod_item
   LET p_est_trans_relac.dat_movto        = p_estoque_trans.dat_movto
   LET p_est_trans_relac.num_nivel        = p_num_nivel
   
   INSERT INTO est_trans_relac
     VALUES(p_est_trans_relac.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','est_trans_relac')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION	 

#-------------------------------#
FUNCTION pol0888_prep_est_trans()
#-------------------------------#

   LET p_estoque_trans.cod_empresa        = p_cod_emp_ger
   LET p_estoque_trans.num_transac        = 0
   LET p_estoque_trans.cod_item           = p_cod_item
   LET p_estoque_trans.dat_movto          = p_dat_movto
   LET p_estoque_trans.dat_ref_moeda_fort = p_dat_emis_nf
   LET p_estoque_trans.cod_operacao       = p_cod_operacao
   LET p_estoque_trans.num_docum          = p_num_docum
   LET p_estoque_trans.num_seq            = p_num_seq
   LET p_estoque_trans.ies_tip_movto      = p_cod_tip_movto
   LET p_estoque_trans.qtd_movto          = p_qtd_movto
   LET p_estoque_trans.cus_unit_movto_p   = p_pre_unit
   LET p_estoque_trans.cus_tot_movto_p    = p_val_movto
   LET p_estoque_trans.cus_unit_movto_f   = 0
   LET p_estoque_trans.cus_tot_movto_f    = 0
   LET p_estoque_trans.num_conta          = p_num_conta
   LET p_estoque_trans.num_secao_requis   = NULL
   LET p_estoque_trans.cod_local_est_orig = NULL
   LET p_estoque_trans.cod_local_est_dest = p_cod_local
   LET p_estoque_trans.num_lote_orig      = NULL
   LET p_estoque_trans.num_lote_dest      = p_num_lote
   LET p_estoque_trans.ies_sit_est_orig   = NULL
   LET p_estoque_trans.ies_sit_est_dest   = p_ies_situa
   LET p_estoque_trans.cod_turno          = p_qtd_fardo
   LET p_estoque_trans.nom_usuario        = p_user
   LET p_estoque_trans.dat_proces         = TODAY
   LET p_estoque_trans.hor_operac         = TIME
   LET p_estoque_trans.num_prog           = "POL0888"
   
END FUNCTION

#------------------------------#
FUNCTION pol0888_ins_est_trans()
#------------------------------#
   
    INSERT INTO estoque_trans(
          cod_empresa,
          cod_item,
          dat_movto,
          dat_ref_moeda_fort,
          cod_operacao,
          num_docum,
          num_seq,
          ies_tip_movto,
          qtd_movto,
          cus_unit_movto_p,
          cus_tot_movto_p,
          cus_unit_movto_f,
          cus_tot_movto_f,
          num_conta,
          num_secao_requis,
          cod_local_est_orig,
          cod_local_est_dest,
          num_lote_orig,
          num_lote_dest,
          ies_sit_est_orig,
          ies_sit_est_dest,
          cod_turno,
          nom_usuario,
          dat_proces,
          hor_operac,
          num_prog)   
          VALUES (p_estoque_trans.cod_empresa,
                  p_estoque_trans.cod_item,
                  p_estoque_trans.dat_movto,
                  p_estoque_trans.dat_ref_moeda_fort,
                  p_estoque_trans.cod_operacao,
                  p_estoque_trans.num_docum,
                  p_estoque_trans.num_seq,
                  p_estoque_trans.ies_tip_movto,
                  p_estoque_trans.qtd_movto,
                  p_estoque_trans.cus_unit_movto_p,
                  p_estoque_trans.cus_tot_movto_p,
                  p_estoque_trans.cus_unit_movto_f,
                  p_estoque_trans.cus_tot_movto_f,
                  p_estoque_trans.num_conta,
                  p_estoque_trans.num_secao_requis,
                  p_estoque_trans.cod_local_est_orig,
                  p_estoque_trans.cod_local_est_dest,
                  p_estoque_trans.num_lote_orig,
                  p_estoque_trans.num_lote_dest,
                  p_estoque_trans.ies_sit_est_orig,
                  p_estoque_trans.ies_sit_est_dest,
                  p_estoque_trans.cod_turno,
                  p_estoque_trans.nom_usuario,
                  p_estoque_trans.dat_proces,
                  p_estoque_trans.hor_operac,
                  p_estoque_trans.num_prog)   


   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_trans')
     RETURN FALSE
   END IF

   LET p_num_transac = SQLCA.SQLERRD[2]

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0888_prep_trans_end()
#--------------------------------#

   INITIALIZE p_estoque_trans_end.*   TO NULL

   LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
   LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
   LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
   LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
   LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
   LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
   LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog
   LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
   LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
   LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
   LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f
   LET p_estoque_trans_end.endereco         =  " "
   LET p_estoque_trans_end.num_volume       = 0
   LET p_estoque_trans_end.cod_grade_1      = " "
   LET p_estoque_trans_end.cod_grade_2      = " "
   LET p_estoque_trans_end.cod_grade_3      = " "
   LET p_estoque_trans_end.cod_grade_4      = " "
   LET p_estoque_trans_end.cod_grade_5      = " "
   LET p_estoque_trans_end.dat_hor_prod_ini = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_prod_fim = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.vlr_temperatura  = 0
   LET p_estoque_trans_end.endereco_origem  = " "
   LET p_estoque_trans_end.num_ped_ven      = 0
   LET p_estoque_trans_end.num_seq_ped_ven  = 0
   LET p_estoque_trans_end.dat_hor_producao = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_validade = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.num_peca         = " "
   LET p_estoque_trans_end.num_serie        = " "
   LET p_estoque_trans_end.comprimento      = 0
   LET p_estoque_trans_end.largura          = 0
   LET p_estoque_trans_end.altura           = 0
   LET p_estoque_trans_end.diametro         = 0
   LET p_estoque_trans_end.dat_hor_reserv_1 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_2 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.dat_hor_reserv_3 = "1900-01-01 00:00:00"
   LET p_estoque_trans_end.qtd_reserv_1     = 0
   LET p_estoque_trans_end.qtd_reserv_2     = 0
   LET p_estoque_trans_end.qtd_reserv_3     = 0
   LET p_estoque_trans_end.num_reserv_1     = 0
   LET p_estoque_trans_end.num_reserv_2     = 0
   LET p_estoque_trans_end.num_reserv_3     = 0
   LET p_estoque_trans_end.tex_reservado    = " "
   
END FUNCTION

#-------------------------------#
FUNCTION pol0888_ins_trans_end()
#-------------------------------#

   LET p_estoque_trans_end.num_transac = p_num_transac

   INSERT INTO estoque_trans_end 
      VALUES (p_estoque_trans_end.*)
      
      
   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_trans_end')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0888_ins_est_auditoria()
#----------------------------------#

  DEFINE p_dat_corrent DATETIME YEAR TO SECOND
  
  LET p_dat_corrent = CURRENT

  INSERT INTO estoque_auditoria 
     VALUES(p_estoque_trans.cod_empresa,
            p_num_transac, 
            p_user, 
            p_dat_corrent,
            p_estoque_trans.num_prog)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_auditoria')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0888_ins_insp_trans()
#--------------------------------#

   LET p_sequencia = p_sequencia + 1

   INSERT INTO insp_trans_885
    VALUES(p_estoque_trans.cod_empresa,
           p_num_aviso,
           p_num_seq,
           p_num_transac,
           p_cod_operacao,
           p_tip_movto,
           p_sequencia)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo','insp_trans_885')
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0888_le_lote_ender()
#-------------------------------#

   SELECT *
     INTO p_estoque_lote_ender.*
     FROM estoque_lote_ender
    WHERE cod_empresa   = p_cod_emp_ger
      AND cod_item      = p_cod_item
      AND cod_local     = p_cod_local
      AND ies_situa_qtd = p_ies_situa
      AND num_lote      = p_num_lote

END FUNCTION

#-------------------------#
FUNCTION pol0888_le_lote()
#-------------------------#

   SELECT num_transac,
          qtd_saldo
     INTO p_num_transac,
          p_qtd_saldo
     FROM estoque_lote
    WHERE cod_empresa   = p_cod_emp_ger
      AND cod_item      = p_cod_item
      AND cod_local     = p_cod_local
      AND ies_situa_qtd = p_ies_situa
      AND num_lote      = p_num_lote

END FUNCTION

#-----------------------------#
FUNCTION pol0888_grava_lotes()
#-----------------------------#

   CALL pol0888_le_lote_ender()
   
   IF STATUS = 0 THEN
      IF NOT pol0888_atu_est_lote_ender() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         CALL pol0888_carrega_lote_ender()
         IF NOT pol0888_ins_est_lote_ender() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LENDO","estoque_lote_ender")       
         RETURN FALSE
      END IF
   END IF   

   CALL pol0888_le_lote()

   IF STATUS = 0 THEN
      IF NOT pol0888_atu_est_lote() THEN
         RETURN FALSE
      END IF
   ELSE
      IF STATUS = 100 THEN
         IF NOT pol0888_ins_est_lote() THEN
            RETURN FALSE
         END IF
      ELSE
         CALL log003_err_sql("LENDO","estoque_lote_ender")       
         RETURN FALSE
      END IF
   END IF   

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0888_atu_est_lote_ender()
#-----------------------------------#

   UPDATE estoque_lote_ender
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_emp_ger
      AND num_transac = p_estoque_lote_ender.num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote_ender")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0888_atu_est_lote()
#------------------------------#

   UPDATE estoque_lote
      SET qtd_saldo = qtd_saldo + p_qtd_movto
    WHERE cod_empresa = p_cod_emp_ger
      AND num_transac = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque_lote")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0888_carrega_lote_ender()
#-----------------------------------#

   LET p_estoque_lote_ender.cod_empresa        = p_cod_emp_ger
	 LET p_estoque_lote_ender.cod_item           = p_cod_item
	 LET p_estoque_lote_ender.cod_local          = p_cod_local
	 LET p_estoque_lote_ender.num_lote           = p_num_lote
	 LET p_estoque_lote_ender.ies_situa_qtd      = p_ies_situa
	 LET p_estoque_lote_ender.qtd_saldo          = p_qtd_movto
   LET p_estoque_lote_ender.largura            = 0
   LET p_estoque_lote_ender.altura             = 0
   LET p_estoque_lote_ender.num_serie          = ' '
   LET p_estoque_lote_ender.diametro           = 0
   LET p_estoque_lote_ender.comprimento        = 0
   LET p_estoque_lote_ender.dat_hor_producao   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.endereco           = ' '
   LET p_estoque_lote_ender.num_volume         = '0'
   LET p_estoque_lote_ender.cod_grade_1        = ' '
   LET p_estoque_lote_ender.cod_grade_2        = ' '
   LET p_estoque_lote_ender.cod_grade_3        = ' '
   LET p_estoque_lote_ender.cod_grade_4        = ' '
   LET p_estoque_lote_ender.cod_grade_5        = ' '
   LET p_estoque_lote_ender.num_ped_ven        = 0
   LET p_estoque_lote_ender.num_seq_ped_ven    = 0
   LET p_estoque_lote_ender.num_transac        = 0
   LET p_estoque_lote_ender.ies_origem_entrada = ' '
   LET p_estoque_lote_ender.dat_hor_validade   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.num_peca           = ' '
   LET p_estoque_lote_ender.dat_hor_reserv_1   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_2   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.dat_hor_reserv_3   = "1900-01-01 00:00:00"
   LET p_estoque_lote_ender.qtd_reserv_1       = 0
   LET p_estoque_lote_ender.qtd_reserv_2       = 0
   LET p_estoque_lote_ender.qtd_reserv_3       = 0
   LET p_estoque_lote_ender.num_reserv_1       = 0
   LET p_estoque_lote_ender.num_reserv_2       = 0
   LET p_estoque_lote_ender.num_reserv_3       = 0
   LET p_estoque_lote_ender.tex_reservado      = ' '
   
END FUNCTION

#------------------------------------#
FUNCTION pol0888_ins_est_lote_ender()
#------------------------------------#

   INSERT INTO estoque_lote_ender(
          cod_empresa,
          cod_item,
          cod_local,
          num_lote,
          endereco,
          num_volume,
          cod_grade_1,
          cod_grade_2,
          cod_grade_3,
          cod_grade_4,
          cod_grade_5,
          dat_hor_producao,
          num_ped_ven,
          num_seq_ped_ven,
          ies_situa_qtd,
          qtd_saldo,
          ies_origem_entrada,
          dat_hor_validade,
          num_peca,
          num_serie,
          comprimento,
          largura,
          altura,
          diametro,
          dat_hor_reserv_1,
          dat_hor_reserv_2,
          dat_hor_reserv_3,
          qtd_reserv_1,
          qtd_reserv_2,
          qtd_reserv_3,
          num_reserv_1,
          num_reserv_2,
          num_reserv_3,
          tex_reservado) 
          VALUES(p_estoque_lote_ender.cod_empresa,
                 p_estoque_lote_ender.cod_item,
                 p_estoque_lote_ender.cod_local,
                 p_estoque_lote_ender.num_lote,
                 p_estoque_lote_ender.endereco,
                 p_estoque_lote_ender.num_volume,
                 p_estoque_lote_ender.cod_grade_1,
                 p_estoque_lote_ender.cod_grade_2,
                 p_estoque_lote_ender.cod_grade_3,
                 p_estoque_lote_ender.cod_grade_4,
                 p_estoque_lote_ender.cod_grade_5,
                 p_estoque_lote_ender.dat_hor_producao,
                 p_estoque_lote_ender.num_ped_ven,
                 p_estoque_lote_ender.num_seq_ped_ven,
                 p_estoque_lote_ender.ies_situa_qtd,
                 p_estoque_lote_ender.qtd_saldo,
                 p_estoque_lote_ender.ies_origem_entrada,
                 p_estoque_lote_ender.dat_hor_validade,
                 p_estoque_lote_ender.num_peca,
                 p_estoque_lote_ender.num_serie,
                 p_estoque_lote_ender.comprimento,
                 p_estoque_lote_ender.largura,
                 p_estoque_lote_ender.altura,
                 p_estoque_lote_ender.diametro,
                 p_estoque_lote_ender.dat_hor_reserv_1,
                 p_estoque_lote_ender.dat_hor_reserv_2,
                 p_estoque_lote_ender.dat_hor_reserv_3,
                 p_estoque_lote_ender.qtd_reserv_1,
                 p_estoque_lote_ender.qtd_reserv_2,
                 p_estoque_lote_ender.qtd_reserv_3,
                 p_estoque_lote_ender.num_reserv_1,
                 p_estoque_lote_ender.num_reserv_2,
                 p_estoque_lote_ender.num_reserv_3,
                 p_estoque_lote_ender.tex_reservado)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_lote_ender')
     RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0888_ins_est_lote()
#------------------------------#

   INSERT INTO estoque_lote(
          cod_empresa, 
          cod_item, 
          cod_local, 
          num_lote, 
          ies_situa_qtd, 
          qtd_saldo)  
          VALUES(p_cod_emp_ger,
                 p_cod_item,
                 p_cod_local,
                 p_num_lote,
                 p_ies_situa,
                 p_qtd_movto)

   IF STATUS <> 0 THEN
     CALL log003_err_sql('Inserindo', 'estoque_lote')
     RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0888_atu_estoque()
#----------------------------#

   UPDATE estoque
      SET qtd_liberada    = qtd_liberada  + p_qtd_liber,
          qtd_lib_excep   = qtd_lib_excep + p_qtd_liber_excep,
          qtd_rejeitada   = qtd_rejeitada + p_qtd_rejeit,
          dat_ult_entrada = p_dat_movto
    WHERE cod_empresa = p_cod_emp_ger
      AND cod_item    = p_cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Atualiando","estoque")       
      RETURN FALSE
   END IF   
       
   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0888_le_conta_deb()
#------------------------------#

   SELECT num_conta_deb_desp
     INTO p_num_conta_deb
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_aviso
      AND num_seq       = p_num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dest_aviso_rec')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0888_le_conta_cred()
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
   
   RETURN TRUE        

END FUNCTION

#-------------------------------#
FUNCTION pol0888_insere_contas()
#-------------------------------#

   INSERT INTO contas_tmp_885
    VALUES(p_num_aviso,
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

#----------------------------------#
FUNCTION pol0888_le_emp_orig_dest()
#----------------------------------#

   DEFINE p_empresa CHAR(02)
   
   SELECT cod_empresa_destin
     INTO p_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_emp_ger
   
   IF STATUS <> 0 THEN
      LET p_empresa = p_cod_emp_ger
   END IF

   RETURN (p_empresa)

END FUNCTION

#-------------------------#
FUNCTION pol0888_gera_ad()
#-------------------------#

   LET p_val_difer = p_val_calculado - p_val_liq_ar
   
   LET p_cod_emp_ad = pol0888_le_emp_orig_dest()
   
   IF NOT pol0888_le_par_ad() THEN 
      RETURN FALSE
   END IF

   {IF NOT pol0888_le_cnd_pgto() THEN 
      RETURN FALSE
   END IF}
   
   LET p_cod_cnd_pgto = p_cnd_pgto_nf

   IF NOT pol0888_insere_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol0888_insere_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT pol0888_grava_aps() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0888_le_par_ad()
#---------------------------#

   SELECT ult_num_ad
     INTO p_num_ad
     FROM par_ad 
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ad = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_ad')
         RETURN FALSE
      END IF
   END IF
   
   LET p_num_ad = p_num_ad + 1
   
   UPDATE par_ad SET ult_num_ad = p_num_ad
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ad')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0888_le_par_ap()
#---------------------------#

   SELECT ult_num_ap 
     INTO p_num_ap
     FROM par_ap
    WHERE cod_empresa = p_cod_emp_ad

   IF STATUS = 100 THEN
      LET p_num_ap = 0
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','par_ap')
         RETURN FALSE
      END IF
   END IF
   
   LET p_num_ap = p_num_ap + 1
   
   UPDATE par_ap SET ult_num_ap = p_num_ap
   WHERE cod_empresa = p_cod_emp_ad

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ap')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------------#
FUNCTION pol0888_le_cnd_pgto()
#-----------------------------#

   SELECT cnd_pgto
     INTO p_cod_cnd_pgto
     FROM cotacao_preco_885
    WHERE cod_empresa      = p_cod_empresa
      AND cod_fornecedor   = p_cod_fornecedor
      AND cod_item         = p_cod_item
      AND dat_val_ini     <= p_dat_emis_nf                
      AND dat_val_fim     >= p_dat_emis_nf                
       
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('LENDO','cotacao_preco')
      RETURN FALSE
   END IF
     
   IF p_cod_cnd_pgto IS NULL OR p_cod_cnd_pgto = 0 THEN
      LET p_cod_cnd_pgto = p_cnd_pgto_nf
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0888_insere_ad()
#---------------------------#

   IF NOT pol0888_calc_dat_vencto() THEN
      RETURN FALSE
   END IF
   
   LET p_ad_mestre.cod_empresa       = p_cod_emp_ad
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
   LET p_ad_mestre.cnd_pgto          = p_cod_cnd_pgto
   LET p_ad_mestre.dat_venc          = p_dat_vencto
   LET p_ad_mestre.cod_fornecedor    = p_cod_fornecedor
   LET p_ad_mestre.cod_portador      = NULL
   LET p_ad_mestre.val_tot_nf        = p_val_difer
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
   LET p_ad_mestre.cod_empresa_orig  = p_cod_emp_ger

   INSERT INTO ad_mestre
      VALUES(p_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_mestre')
      RETURN FALSE
   END IF

   LET p_msg = p_ad_mestre.num_ad
   LET p_msg = 'pol0888 - INCLUSAO DA AD No. ', p_msg CLIPPED
   LET p_hora = CURRENT HOUR TO SECOND

   INSERT INTO audit_cap
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
FUNCTION pol0888_calc_dat_vencto()
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
FUNCTION pol0888_insere_lanc()
#-----------------------------#
   
   DEFINE p_num_seq SMALLINT
   
   LET p_num_seq = 0

   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","fornecedor")       
      RETURN FALSE
   END IF
   
   DECLARE cq_lanc CURSOR FOR
    SELECT cod_tip_despesa,
           num_conta_cred,
           num_conta_deb,
           val_movto
      FROM contas_tmp_885
     WHERE num_aviso_rec = p_num_aviso

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

      INSERT INTO lanc_cont_cap
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
      
      INSERT INTO lanc_cont_cap
         VALUES(p_lanc_cont_cap.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','lanc_cont_cap')
         RETURN FALSE
      END IF
      
   END FOREACH

   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0888_grava_aps()
#---------------------------#

   SELECT COUNT(cnd_pgto)
     INTO p_qtd_parcelas
     FROM cond_pg_item_cap
    WHERE cnd_pgto = p_cod_cnd_pgto

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
     WHERE cnd_pgto = p_cod_cnd_pgto
       
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
      
      IF NOT pol0888_insere_ap() THEN
         RETURN FALSE
      END IF
      
      LET p_num_parcela = p_num_parcela + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol0888_insere_ap()
#---------------------------#

    IF NOT pol0888_le_par_ap() THEN 
       RETURN FALSE
    END IF

    LET p_ap.cod_empresa       = p_cod_emp_ad
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
   
   INSERT INTO ap
      VALUES(p_ap.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ap')
      RETURN FALSE
   END IF
   
   IF NOT pol0888_le_conta_cred() THEN
      RETURN FALSE
   END IF

   INSERT INTO ap_tip_desp
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
      
   INSERT INTO ad_ap
      VALUES(p_ap.cod_empresa,
             p_ad_mestre.num_ad,
             p_ap.num_ap,
             p_ap.num_lote_transf)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_ap')
      RETURN FALSE
   END IF

   LET p_msg = p_ap.num_ap
   LET p_msg = 'pol0888 - INCLUSAO DA AP No. ', p_msg CLIPPED
   LET p_hora = CURRENT HOUR TO SECOND

   INSERT INTO audit_cap
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

#-----------------------------------#
FUNCTION pol0888_gera_adiantamento()
#-----------------------------------#

   INITIALIZE p_adiant, p_mov_adiant TO NULL

   LET p_val_difer = p_val_liq_ar - p_val_calculado 
   LET p_adiant.cod_empresa = pol0888_le_emp_orig_dest()
      
   LET p_adiant.cod_fornecedor    = p_cod_fornecedor
   LET p_adiant.num_pedido        = p_num_ped_compra
   LET p_adiant.num_ad_nf_orig    = p_num_nf
   LET p_adiant.ser_nf            = p_ser_nf
   LET p_adiant.ssr_nf            = p_ssr_nf
   LET p_adiant.dat_ref           = p_dat_entrada_nf
   LET p_adiant.val_adiant        = p_val_difer
   LET p_adiant.val_saldo_adiant  = p_adiant.val_adiant
   LET p_adiant.tex_observ_adiant = 'QUANTIDADE ENVIADA < QUANTIDADE DECLARADA NA NF'
   LET p_adiant.ies_forn_div      = 'V'
   LET p_adiant.ies_adiant_transf = 'N'
   LET p_adiant.ies_bx_automatica = 'S'
   
   INSERT INTO adiant VALUES(p_adiant.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','adiant')
      RETURN FALSE
   END IF
   
   LET p_mov_adiant.cod_empresa     = p_adiant.cod_empresa
   LET p_mov_adiant.dat_mov         = p_adiant.dat_ref
   LET p_mov_adiant.ies_ent_bx      = 'E'
   LET p_mov_adiant.cod_fornecedor  = p_adiant.cod_fornecedor
   LET p_mov_adiant.num_ad_nf_orig  = p_adiant.num_ad_nf_orig
   LET p_mov_adiant.ser_nf          = p_adiant.ser_nf 
   LET p_mov_adiant.ssr_nf          = p_adiant.ssr_nf
   LET p_mov_adiant.val_mov         = p_adiant.val_adiant
   LET p_mov_adiant.val_saldo_novo  = p_mov_adiant.val_mov 
   LET p_mov_adiant.ies_ad_ap_mov   = 1
   LET p_mov_adiant.num_ad_ap_mov   = p_mov_adiant.num_ad_nf_orig
   LET p_mov_adiant.cod_tip_val_mov = 3
   LET p_mov_adiant.hor_mov         = CURRENT HOUR TO SECOND
   
   INSERT INTO mov_adiant VALUES(p_mov_adiant.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','mov_adiant')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0888_reverter()
#--------------------------#

   IF p_cod_status <> 'P' THEN
      LET p_msg = 'O status atual do processo não permite essa operação !!!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF

   IF NOT log004_confirm(6,10) THEN 
      RETURN FALSE
   END IF 

   CALL log085_transacao("BEGIN")
   
   IF NOT pol0888_proc_reversao() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")   
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0888_proc_reversao()
#-------------------------------#

   DEFINE p_val_saldo     LIKE mov_adiant.val_saldo_novo
   
   LET p_cod_emp_docum = pol0888_le_emp_orig_dest()
   
   SELECT num_nf,
          ser_nf,
          ssr_nf,
          cod_fornecedor
     INTO p_num_nf,
          p_ser_nf,
          p_ssr_nf,
          p_cod_fornecedor
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup")       
      RETURN FALSE
   END IF

   SELECT val_mov,
          val_saldo_novo
     INTO p_val_movto,
          p_val_saldo
     FROM mov_adiant
    WHERE cod_empresa    = p_cod_emp_docum
      AND num_ad_nf_orig = p_num_nf
      AND ser_nf         = p_ser_nf
      AND ssr_nf         = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor

   IF STATUS = 0 THEN
      IF p_val_movto <> p_val_saldo THEN
         LET p_msg = 'Esse AR gerou um adiantamento de \n',
                     'número ',p_num_nf,'o qual já foi compensado.\n',
                     'Conclusão: para reverter o processo,\n',
                     'você precisa reverter a compensação\n',
                     'do adiantamento previamente!'
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
      IF NOT pol0888_del_adiant() THEN
         RETURN FALSE
      END IF
   ELSE
      SELECT num_ad
        INTO p_num_ad
        FROM ad_mestre
       WHERE cod_empresa    = p_cod_emp_docum
         AND num_nf         = p_num_nf          
         AND ser_nf         = p_ser_nf          
         AND ssr_nf         = p_ssr_nf          
         AND cod_fornecedor = p_cod_fornecedor  
     
      IF STATUS = 0 THEN
         IF NOT pol0888_ve_pgto_ap() THEN
            RETURN FALSE
         END IF
         IF NOT pol0888_del_cap() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF NOT pol0888_rev_estoq() THEN
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   UPDATE ar_aparas_885
      SET cod_status = 'I'
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_ar
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update', 'ar_aparas_885')
      RETURN FALSE
   END IF
   
   LET p_cod_status = 'I'
   DISPLAY p_cod_status TO ies_status
   
   RETURN TRUE
   
END FUNCTION

#----------------------------#
FUNCTION pol0888_ve_pgto_ap()
#----------------------------#

   DEFINE p_dat_pgto DATE
   
   DECLARE cq_ap CURSOR FOR
    SELECT num_ap
      FROM ad_ap
     WHERE cod_empresa = p_cod_emp_docum
       AND num_ad      = p_num_ad
   
   FOREACH cq_ap INTO p_num_ap
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ad_ap')
         RETURN FALSE
      END IF
      INITIALIZE p_dat_pgto TO NULL
      
      SELECT dat_pgto
        INTO p_dat_pgto
        FROM ap
       WHERE cod_empresa = p_cod_emp_docum
         AND num_ap      = p_num_ap
         AND ies_versao_atual = 'S'
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','ap')
         RETURN FALSE
      END IF
      
      IF p_dat_pgto IS NOT NULL THEN
         LET p_msg = 'Esse AR gerou a AP ',p_num_ap,'\n',
                     'a qual já foi paga.\n',
                     'Conclusão: reverta o pagamento \n',
                     'da AP previamente!'
         RETURN FALSE
      END IF
   
   END FOREACH
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0888_del_adiant()
#----------------------------#
      
   DELETE FROM adiant
    WHERE cod_empresa    = p_cod_emp_docum
      AND num_ad_nf_orig = p_num_nf
      AND ser_nf         = p_ser_nf
      AND ssr_nf         = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','adiant')
      RETURN FALSE
   END IF
   
   DELETE FROM mov_adiant
    WHERE cod_empresa    = p_cod_emp_docum
      AND num_ad_nf_orig = p_num_nf
      AND ser_nf         = p_ser_nf
      AND ssr_nf         = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','mov_adiant')
      RETURN FALSE
   END IF
                  
   RETURN TRUE
   
END FUNCTION

#-------------------------#
FUNCTION pol0888_del_cap()
#-------------------------#
 
   DELETE FROM audit_cap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad_ap   = p_num_ad
      AND ies_ad_ap   = '1'
      AND num_nf      = p_num_nf
      AND cod_fornecedor = p_cod_fornecedor
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','audit_cap:ad')
      RETURN FALSE
   END IF

   DELETE FROM audit_cap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad_ap   = p_num_ap
      AND ies_ad_ap   = '2'
      AND num_nf      = p_num_nf
      AND cod_fornecedor = p_cod_fornecedor
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','audit_cap:ap')
      RETURN FALSE
   END IF

   DELETE FROM lanc_cont_cap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad_ap   = p_num_ad
      AND ies_ad_ap   = '1'
      AND ies_tipo_lanc = 'D'
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','lanc_cont_cap:ad')
      RETURN FALSE
   END IF

   DELETE FROM lanc_cont_cap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad_ap   = p_num_ap
      AND ies_ad_ap   = '2'
      AND ies_tipo_lanc = 'C'
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','lanc_cont_cap:ap')
      RETURN FALSE
   END IF

   DELETE FROM ap_tip_desp
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ap      = p_num_ap
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ap_tip_desp')
      RETURN FALSE
   END IF

   DELETE FROM ad_mestre
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad      = p_num_ad
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ad_mestre')
      RETURN FALSE
   END IF

   DELETE FROM ap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ap IN
          (SELECT num_ap FROM ad_ap
            WHERE cod_empresa = p_cod_emp_docum
              AND num_ad = p_num_ad)
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ap')
      RETURN FALSE
   END IF

   DELETE FROM ad_ap
    WHERE cod_empresa = p_cod_emp_docum
      AND num_ad      = p_num_ad
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ad_ap')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0888_rev_estoq()
#--------------------------#

   MESSAGE 'Aguarde!... processando.', p_num_ar
   
   DECLARE cq_le_umd CURSOR WITH HOLD FOR
    SELECT num_seq_ar
      FROM umd_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
     ORDER BY num_seq_ar

   FOREACH cq_le_umd INTO p_num_seq_ar

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","cq_le_umd")       
         RETURN FALSE
      END IF   

      DECLARE cq_le_insp CURSOR WITH HOLD FOR
       SELECT num_transac,
              tip_movto,
              sequencia
         FROM insp_trans_885
        WHERE cod_empresa   = p_cod_emp_ger
          AND num_aviso_rec = p_num_ar
          AND num_seq_ar    = p_num_seq_ar
        ORDER BY sequencia DESC
      
      FOREACH cq_le_insp INTO p_num_transac, p_tip_movto, p_sequencia
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","cq_le_insp")       
            RETURN FALSE
         END IF   
     
         IF NOT pol0888_le_transacoes() THEN
            RETURN FALSE
         END IF
 
         LET p_estoque_trans.ies_tip_movto = 'R'
         LET p_estoque_trans.dat_proces    = TODAY
         LET p_estoque_trans.hor_operac    = TIME
         
         IF NOT pol0888_ins_est_trans() THEN           
            RETURN FALSE                               
         END IF                                        

         IF NOT pol0888_ins_trans_rev() THEN           
            RETURN FALSE                               
         END IF                                        
                                                       
         LET p_estoque_trans_end.ies_tip_movto = 'R'

         IF NOT pol0888_ins_trans_end() THEN       
            RETURN FALSE                               
         END IF                                        
                                                       
         IF NOT pol0888_ins_est_auditoria() THEN       
            RETURN FALSE                               
         END IF                                        

         IF p_tip_movto IS NULL THEN
            CONTINUE FOREACH
         END IF
         
         LET p_cod_item  = p_estoque_trans.cod_item                                                
         LET p_qtd_movto = p_estoque_trans_end.qtd_movto                                           
                                                                                                   
         IF p_tip_movto = 'S' THEN   #saída no movimento = entrada no estorno                                                             
            LET p_cod_local = p_estoque_trans.cod_local_est_orig                                   
            LET p_num_lote  = p_estoque_trans.num_lote_orig                                        
            LET p_ies_situa = p_estoque_trans.ies_sit_est_orig                                     
         ELSE                        #entrada no movimento = saída no estorno                                                                 
            LET p_cod_local = p_estoque_trans.cod_local_est_dest                                   
            LET p_num_lote  = p_estoque_trans.num_lote_dest                                        
            LET p_ies_situa = p_estoque_trans.ies_sit_est_dest                                     
         END IF                                                                                    
                                                                                                                                                                                                      
         LET p_qtd_txt  = p_qtd_movto                                                              
                                                                                                   
         CALL pol0888_le_lote_ender()
         
         IF STATUS <> 0 THEN                                                        
            IF p_tip_movto = 'S' THEN      #saida na inspeção = entrada no estorno   
               CALL pol0888_carrega_lote_ender()                                                   
               IF NOT pol0888_ins_est_lote_ender() THEN                                                
                  RETURN FALSE                                                                     
               END IF                                                                              
            ELSE                                                                                   
               LET p_msg = 'TAB: ESTOQUE_LOTE_ENDER: \n',
                           'NAO HA ESTOQUE NO ITEM ',p_cod_item CLIPPED, '\n',                          
                           'PARA FAZER A SAIDA DE ',p_qtd_txt CLIPPED,' POR ESTORNO' 
               CALL log0030_mensagem(p_msg,'excla')                
               RETURN FALSE                                                                        
            END IF                                                                                 
         ELSE                                                                                      
            IF p_tip_movto = 'S' THEN     #saida na inspeção = entrada no estorno  
               IF NOT pol0888_atu_est_lote_ender() THEN                                           
                  RETURN FALSE                                                                     
               END IF                                                                              
            ELSE                                                                                   
               IF p_qtd_movto <= p_estoque_lote_ender.qtd_saldo THEN                               
                  LET p_qtd_movto = -p_qtd_movto                                                   
                  IF NOT pol0888_atu_est_lote_ender() THEN                                        
                     RETURN FALSE                                                                  
                  END IF                                                                           
                  LET p_qtd_movto = p_estoque_trans_end.qtd_movto                                  
               ELSE                                                                                
                  LET p_msg = 'TAB: ESTOQUE_LOTE_ENDER: \n',
                              'NAO HA ESTOQUE SUFICIENTE NO ITEM ',p_cod_item CLIPPED,'\n',                          
                              'PARA FAZER A SAIDA DE ',p_qtd_txt CLIPPED,' POR ESTORNO' 
                  RETURN FALSE                                                                     
               END IF                                                                              
            END IF                                                                                 
         END IF                                                                                    

         CALL pol0888_le_lote()
                                                                                                        
         IF STATUS <> 0 THEN                                                                         
            IF p_tip_movto = 'S' THEN     #saida na inspeção = entrada no estorno        
               IF NOT pol0888_ins_est_lote() THEN                                                       
                  RETURN FALSE                                                                          
               END IF                                                                                   
            ELSE                                                                                        
               LET p_msg = 'TAB: ESTOQUE_LOTE: \n',
                           'NAO HA ESTOQUE NO ITEM ',p_cod_item CLIPPED, '\n',                          
                           'PARA FAZER A SAIDA DE ',p_qtd_txt CLIPPED,' POR ESTORNO' 
               RETURN FALSE                                                                             
            END IF                                                                                      
         ELSE                                                                                           
            IF p_tip_movto = 'S' THEN    #saida na inspeção = entrada no estorno          
               IF NOT pol0888_atu_est_lote() THEN                                                      
                  RETURN FALSE                                                                         
               END IF                                                                                   
            ELSE                                                                                        
               IF p_qtd_movto <= p_qtd_saldo THEN                                          
                  LET p_qtd_movto = -p_qtd_movto                                                        
                  IF NOT pol0888_atu_est_lote() THEN                                                   
                     RETURN FALSE                                                                       
                  END IF                                                                                
               ELSE                                                                                     
                  LET p_msg = 'TAB: ESTOQUE_LOTE_ENDER: \n',
                              'NAO HA ESTOQUE SUFUCIENTE NO ITEM ',p_cod_item CLIPPED,'\n',                          
                              'PARA FAZER A SAIDA DE ',p_qtd_txt CLIPPED,' POR ESTORNO' 
                  RETURN FALSE                                                                          
               END IF                                                                                   
            END IF                                                                                      
         END IF                                                                                         

         LET p_qtd_liber  = 0
         LET p_qtd_liber_excep  = 0
         LET p_qtd_rejeit = 0
         
         IF p_ies_situa = 'L' THEN
            LET p_qtd_liber = p_qtd_movto
         ELSE
            IF p_ies_situa = 'E' THEN
               LET p_qtd_liber_excep = p_qtd_movto
            ELSE
               IF p_ies_situa = 'R' THEN
                  LET p_qtd_rejeit = p_qtd_movto
               END IF
            END IF
         END IF
                                                                                          
         IF NOT pol0888_atu_estoque() THEN                                                         
            RETURN FALSE                                                                                
         END IF                                                                                         
      
      END FOREACH
   
   END FOREACH
   
   CALL pol0888_del_lote_zerado()

   DELETE FROM insp_trans_885
    WHERE cod_empresa = p_cod_emp_ger
      AND num_aviso_rec = p_num_ar
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','insp_trans_885')
      RETURN FALSE
   END IF   
   
   RETURN TRUE
   
END FUNCTION
 
#-------------------------------#
FUNCTION pol0888_le_transacoes()
#-------------------------------#

   SELECT *
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa = p_cod_emp_ger
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_trans')
      RETURN FALSE
   END IF

   SELECT *
     INTO p_estoque_trans_end.*
     FROM estoque_trans_end
    WHERE cod_empresa = p_cod_emp_ger
      AND num_transac = p_num_transac
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','estoque_trans_end')
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0888_del_lote_zerado()
#--------------------------------#
   
   DELETE FROM estoque_lote
    WHERE cod_empresa = p_cod_emp_ger
      AND qtd_saldo   <= 0


   DELETE FROM estoque_lote_ender
    WHERE cod_empresa = p_cod_emp_ger
      AND qtd_saldo   <= 0
   
END FUNCTION 

#-------------------------------#
FUNCTION pol0888_ins_trans_rev()
#-------------------------------#

   INSERT INTO estoque_trans_rev
    VALUES(p_estoque_trans.cod_empresa,
           p_estoque_trans.num_transac,
           p_num_transac)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','estoque_trans_rev')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
