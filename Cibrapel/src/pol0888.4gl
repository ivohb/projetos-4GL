#-------------------------------------------------------------------#
# OBJETIVO: INTEGRAÇÃO CONTAS A PAGAR DE APARAS                     #
# DATA....: 28/04/2008                                              #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_orig       LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_ar             LIKE aviso_rec.num_aviso_rec,
          p_cod_status         CHAR(01),
          p_ies_apara          SMALLINT,
          p_val_parcela        DECIMAL(15,2),
          p_dat_vencto         DATETIME YEAR TO DAY,
          p_descarta           SMALLINT,
          p_ies_info           SMALLINT,
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
          p_cod_operacao       LIKE estoque_trans.cod_operacao,
          p_dat_movto          LIKE estoque_trans.dat_movto,
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
          p_ad_mestre          RECORD LIKE ad_mestre_885.*,
          p_ap                 RECORD LIKE ap_885.*,
          p_lanc_cont_cap      RECORD LIKE lanc_cont_cap_885.*,
          p_insumo             RECORD LIKE insumo_885.*

   DEFINE p_cod_tip_movto      CHAR(01),
          p_ies_situa          CHAR(01),
          p_ies_financeiro     CHAR(01)
          
         
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
   LET p_versao = "pol0888-10.02.01"
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
      COMMAND "Consultar" "Consulta os movimentos de entrada de aparas "
         CALL pol0888_consultar() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            LET p_ies_lista = FALSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Integrar" "Integra o contas a pagar "
         CALL pol0888_exportar() RETURNING p_status
         IF p_status THEN
            CALL log0030_mensagem(p_msg,'excla')
         ELSE
            ERROR 'Operação cancelada!'
         END IF
      COMMAND "Reverter" "Reverte o contas a pagar"
         CALL pol0888_reverter() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada comn sucesso.'
         ELSE
            ERROR 'Operação cancelada!'
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
FUNCTION pol0888_exportar()#
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08882") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08882 AT 8,8 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   
   CALL pol0888_proces_exportacao() RETURNING p_status
   
   CLOSE WINDOW w_pol08882
   
   RETURN p_status
   
END FUNCTION

#-----------------------------------#
FUNCTION pol0888_proces_exportacao()#
#-----------------------------------#
   
   IF NOT pol0888_informar('E') THEN
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF

   DROP TABLE contas_tmp_885

   CREATE TEMP TABLE contas_tmp_885(
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

   LET p_houve_erro = FALSE
        
   DELETE FROM contas_tmp_885
   LET p_sequencia = 0
  
   CALL log085_transacao("BEGIN")
   IF NOT pol0896_inspciona_ar() THEN
      CALL log085_transacao("ROLLBACK")
      LET p_houve_erro = TRUE
   ELSE
      CALL log085_transacao("COMMIT")
   END IF
          
   IF p_houve_erro THEN
      LET p_msg = "Devido ao ploblema já exposto, o AR não foi integrado!"
   ELSE
      LET p_msg = "Processamento efetuado com sucesso!"
      DISPLAY 'P' TO ies_status
   END IF
      
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
FUNCTION pol0888_informar(p_opcao)#
#---------------------------------#
   
   DEFINE p_opcao CHAR(01)
   
   LET INT_FLAG = FALSE
   LET p_num_ar = NULL
   
   INPUT p_num_ar WITHOUT DEFAULTS FROM num_aviso

      AFTER FIELD num_aviso
      
         IF p_num_ar IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório !!!'
            NEXT FIELD num_aviso
         END IF
         
         SELECT num_aviso_rec,
                val_pedagio,
                cod_status,
                ies_financeiro
           INTO p_num_aviso, 
                p_val_pedagio,
                p_cod_status,
                p_ies_financeiro
           FROM ar_aparas_885 
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_num_ar
         
         IF STATUS <> 0 THEN
            ERROR 'AR não consta do processo de entrada de aparas !!!'
            NEXT FIELD num_aviso
         END IF

         IF p_opcao = 'E' THEN
            IF p_cod_status <> 'I' THEN
               ERROR 'AR não está disponível p/ o CAP !!!'
               NEXT FIELD num_aviso
            END IF
         ELSE
            IF p_cod_status <> 'P' THEN
               ERROR 'AR não está disponível p/ reversão !!!'
               NEXT FIELD num_aviso
            END IF
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

   DECLARE cq_umd CURSOR FOR
    SELECT num_seq_ar,
           preco_cotacao,
           cod_item_tr
      FROM umd_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso
     ORDER BY num_seq_ar

   FOREACH cq_umd INTO p_num_seq, p_pre_unit, p_cod_item_tr
 
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_umd')
         RETURN FALSE
      END IF                        

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
      
      IF p_cod_item_tr IS NOT NULL THEN
         LET p_cod_item = p_cod_item_tr
      END IF
                              
      IF NOT pol0888_le_conta_deb() THEN
         RETURN FALSE
      END IF

      IF NOT pol0888_le_conta_cred() THEN
         RETURN FALSE
      END IF
     
      DECLARE cq_cont CURSOR FOR                                            
       SELECT num_lote,                                                       
              qtd_fardo,                                                      
              qtd_liber,                                                      
              qtd_liber_excep,                                                
              qtd_rejeit,                                                     
              pre_calculado,                #qtd_calculada * preco_cotacao    
              dat_inspecao,
              num_transac                                                    
         FROM cont_aparas_885                                                 
        WHERE cod_empresa = p_cod_empresa                                   
          AND num_aviso_rec = p_num_aviso
          AND num_seq_ar = p_num_seq                                   
        ORDER BY num_lote                                                   
                                                                              
      FOREACH cq_cont INTO                                                  
              p_num_lote,                                                     
              p_qtd_fardo,                                                    
              p_qtd_liber,                                                    
              p_qtd_liber_excep,                                              
              p_qtd_rejeit,                                                   
              p_pre_calculado,                                                
              p_dat_movto,
              p_num_transac                                                     
                                                                              
         IF STATUS <> 0 THEN                                                  
            CALL log003_err_sql('Lendo','cq_cont')                          
            RETURN FALSE                                                      
         END IF                                                               
                        
         LET p_val_calculado = p_val_calculado + p_pre_calculado
         LET p_val_movto = p_pre_calculado 

         IF NOT pol0888_insere_contas() THEN
            RETURN FALSE
         END IF
                        
         {LET p_cod_tip_movto = 'N'

         IF p_qtd_liber > 0 THEN 
            LET p_qtd_movto = p_qtd_liber
            LET p_ies_situa = 'L'
            IF NOT pol0888_exporta_trim() THEN 
               RETURN FALSE 
            END IF
         END IF  
      
         IF p_qtd_liber_excep > 0 THEN 
            LET p_qtd_movto = p_qtd_liber_excep
            LET p_ies_situa = 'E'
            IF NOT pol0888_exporta_trim() THEN 
               RETURN FALSE 
            END IF
         END IF  

         IF p_qtd_rejeit > 0 THEN 
            LET p_qtd_movto = p_qtd_rejeit
            LET p_ies_situa = 'R'
            IF NOT pol0888_exporta_trim() THEN 
               RETURN FALSE 
            END IF
         END IF } 
  
      END FOREACH
      
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

   UPDATE ar_aparas_885
      SET cod_status = "P",
          ies_financeiro = p_ies_financeiro
     WHERE cod_empresa = p_cod_empresa
       AND num_aviso_rec = p_num_aviso

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualisando','ar_aparas_885')
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
    WHERE cod_empresa_orig = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_empresa = p_cod_empresa
   END IF

   RETURN (p_empresa)
   
END FUNCTION

#-------------------------#
FUNCTION pol0888_gera_ad()
#-------------------------#
   
   LET p_ies_financeiro = 'T'
   
   LET p_val_difer = p_val_calculado - p_val_liq_ar
   
   LET p_cod_emp_orig = pol0888_le_emp_orig_dest()
   
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

   CALL log0030_mensagem(p_msg,'info')
   
   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0888_le_par_ad()
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
   
{
   SELECT ult_num_ad
     INTO p_num_ad
     FROM par_ad 
    WHERE cod_empresa = p_cod_emp_orig

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
   WHERE cod_empresa = p_cod_emp_orig

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ad')
      RETURN FALSE
   END IF
}   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0888_le_par_ap()
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
{
   SELECT ult_num_ap 
     INTO p_num_ap
     FROM par_ap
    WHERE cod_empresa = p_cod_emp_orig

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
   WHERE cod_empresa = p_cod_emp_orig

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ap')
      RETURN FALSE
   END IF
 }  
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
   LET p_ad_mestre.cod_empresa_orig  = p_cod_empresa
   LET p_ad_mestre.ies_situacao = 'N'

   INSERT INTO ad_mestre_885
      VALUES(p_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_mestre_885')
      RETURN FALSE
   END IF

   LET p_msg = p_ad_mestre.num_ad
   LET p_msg = 'pol0888 - INCLUSAO DA AD No. ', p_msg CLIPPED
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
      
      DELETE FROM lanc_cont_cap_885
       WHERE cod_empresa = p_lanc_cont_cap.cod_empresa
         AND num_ad_ap = p_lanc_cont_cap.num_ad_ap
         AND ies_ad_ap = p_lanc_cont_cap.ies_ad_ap 
         AND num_seq = p_lanc_cont_cap.num_seq 
      
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
         CALL log003_err_sql('Inserindo','lanc_cont_cap_885')
         RETURN FALSE
      END IF

      LET p_lanc_cont_cap.ies_tipo_lanc  = 'C'
      LET p_lanc_cont_cap.num_conta_cont = p_num_conta_cred
      LET p_num_seq = p_num_seq + 1
      LET p_lanc_cont_cap.num_seq        = p_num_seq
      LET p_lanc_cont_cap.ies_ad_ap          = '2'

      DELETE FROM lanc_cont_cap_885
       WHERE cod_empresa = p_lanc_cont_cap.cod_empresa
         AND num_ad_ap = p_lanc_cont_cap.num_ad_ap
         AND ies_ad_ap = p_lanc_cont_cap.ies_ad_ap 
         AND num_seq = p_lanc_cont_cap.num_seq 
      
      INSERT INTO lanc_cont_cap_885
         VALUES(p_lanc_cont_cap.*)

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Inserindo','lanc_cont_cap_885')
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
   
   IF NOT pol0888_le_conta_cred() THEN
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
   LET p_msg = 'pol0888 - INCLUSAO DA AP No. ', p_msg CLIPPED
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

#-----------------------------------#
FUNCTION pol0888_gera_adiantamento()
#-----------------------------------#

   LET p_ies_financeiro = 'A'
   
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

#------------------------------#
FUNCTION pol0888_exporta_trim()#
#------------------------------#

   SELECT COUNT(num_sequencia)
     INTO p_count
     FROM insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND num_sequencia = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','insumo_885')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      RETURN TRUE
   END IF
                  
   LET p_insumo.num_sequencia = p_num_transac
   LET p_insumo.cod_empresa = p_cod_empresa
   LET p_insumo.num_lote = p_num_lote  
   LET p_insumo.cod_item = p_cod_item
   LET p_insumo.largura = 0
   LET p_insumo.diametro = 0   
   LET p_insumo.tubete = 0  
   LET p_insumo.num_nf = p_num_nf
   LET p_insumo.dat_emis_nf = p_dat_emis_nf
   LET p_insumo.dat_entrada_nf = p_dat_entrada_nf
   LET p_insumo.num_ar = p_num_aviso
   LET p_insumo.num_seq_ar = p_num_seq
   LET p_insumo.cod_fornecedor = p_cod_fornecedor
   LET p_insumo.nom_fornecedor = p_raz_social
   LET p_insumo.dat_movto = p_dat_movto
   LET p_insumo.qtd_movto = p_qtd_movto
   LET p_insumo.val_movto = p_qtd_movto * p_pre_unit
   LET p_insumo.qtd_fardos = p_qtd_fardo
   LET p_insumo.tip_movto = p_cod_tip_movto
   LET p_insumo.cod_status = 0
   LET p_insumo.ies_bobina = 'N'   
   LET p_insumo.dat_geracao = CURRENT
   LET p_insumo.tipestoque = p_ies_situa
           
   INSERT INTO insumo_885
    VALUES(p_insumo.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','insumo_885')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0888_reverter()#
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol08882") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol08882 AT 8,8 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   
   CALL pol0888_proces_reversao() RETURNING p_status
   
   CLOSE WINDOW w_pol08882
   
   RETURN p_status
   
END FUNCTION

#--------------------------------#
FUNCTION pol0888_proces_reversao()
#--------------------------------#

   LET p_cod_emp_orig = pol0888_le_emp_orig_dest()

   IF NOT pol0888_informar('R') THEN
      RETURN FALSE
   END IF

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
      AND num_aviso_rec = p_num_aviso

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup")       
      RETURN FALSE
   END IF

   LET p_msg = NULL
   
   IF p_ies_financeiro = 'T' THEN
      IF NOT pol0888_checa_ad() THEN
         RETURN FALSE
      END IF
   ELSE
      IF p_ies_financeiro = 'A' THEN
         IF NOT pol0888_checa_adiant() THEN
            RETURN FALSE
         END IF
      END IF
   END IF
   
   IF p_msg IS NOT NULL THEN
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
                  
   IF NOT log004_confirm(6,10) THEN
      RETURN FALSE
   END IF
   
   CALL log085_transacao("BEGIN")
   
   IF NOT pol0888_exec_reversao() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")   
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0888_checa_ad()#
#--------------------------#

   SELECT num_ad,
          ies_situacao
     INTO p_num_ad,
          p_ies_situa
     FROM ad_mestre_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_nf = p_num_nf
      AND ser_nf = p_ser_nf
      AND ssr_nf = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","ad_mestre_885")       
      RETURN FALSE
   END IF
   
   IF p_ies_situa = 'P' THEN
      LET p_msg = 'AD já contém pagamento.\n Reversão não permitida.'
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0888_checa_adiant()#
#------------------------------#

   DEFINE p_val_saldo     LIKE mov_adiant.val_saldo_novo
      
   SELECT val_mov,
          val_saldo_novo
     INTO p_val_movto,
          p_val_saldo
     FROM mov_adiant
    WHERE cod_empresa    = p_cod_emp_orig
      AND num_ad_nf_orig = p_num_nf
      AND ser_nf         = p_ser_nf
      AND ssr_nf         = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","mov_adiant")       
      RETURN FALSE
   END IF

   IF p_val_movto <> p_val_saldo THEN
      LET p_msg = 'Esse AR gerou um adiantamento de ',p_val_movto, '\n',
                  'o qual já foi compensado.\n',
                  'Conclusão: o processo de exportação\n não pode ser revertido.'
   END IF

   RETURN TRUE
  
END FUNCTION

#-------------------------------#
FUNCTION pol0888_exec_reversao()
#-------------------------------#

   IF p_ies_financeiro = 'A' THEN   
      IF NOT pol0888_del_adiant() THEN
         RETURN FALSE
      END IF
   END IF
   
   IF p_ies_financeiro = 'T' THEN   
      IF NOT pol0888_del_cap() THEN
         RETURN FALSE
      END IF
   END IF
   
   #IF NOT pol0888_rev_estoq() THEN
   #   RETURN FALSE
   #END IF
   
   UPDATE ar_aparas_885
      SET cod_status = 'I',
          ies_financeiro = ''
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
FUNCTION pol0888_del_adiant()
#----------------------------#
      
   DELETE FROM adiant
    WHERE cod_empresa    = p_cod_emp_orig
      AND num_ad_nf_orig = p_num_nf
      AND ser_nf         = p_ser_nf
      AND ssr_nf         = p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','adiant')
      RETURN FALSE
   END IF
   
   DELETE FROM mov_adiant
    WHERE cod_empresa    = p_cod_emp_orig
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
 
   DELETE FROM ad_mestre_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_ad      = p_num_ad
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ad_mestre_885')
      RETURN FALSE
   END IF
 
   DELETE FROM audit_cap_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_nf = p_num_nf
      AND ser_nf = p_ser_nf
      AND ssr_nf= p_ssr_nf
      AND cod_fornecedor = p_cod_fornecedor
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','audit_cap_885')
      RETURN FALSE
   END IF

   DELETE FROM lanc_cont_cap_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_ad_ap   = p_num_ad
      AND ies_ad_ap   = '1'
      AND ies_tipo_lanc = 'D'
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','lanc_cont_cap_885:ad')
      RETURN FALSE
   END IF

   DELETE FROM lanc_cont_cap_885
    WHERE cod_empresa = p_cod_emp_orig
      AND ies_ad_ap   = '2'
      AND ies_tipo_lanc = 'C'
      AND num_ad_ap IN
          (SELECT num_ap FROM ad_ap_885
            WHERE cod_empresa = p_cod_emp_orig
              AND num_ad = p_num_ad)
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','lanc_cont_cap_885:ap')
      RETURN FALSE
   END IF

   DELETE FROM ap_tip_desp_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_ap IN
          (SELECT num_ap FROM ad_ap_885
            WHERE cod_empresa = p_cod_emp_orig
              AND num_ad = p_num_ad)
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ap_tip_desp_885')
      RETURN FALSE
   END IF

   DELETE FROM ap_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_ap IN
          (SELECT num_ap FROM ad_ap_885
            WHERE cod_empresa = p_cod_emp_orig
              AND num_ad = p_num_ad)
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ap_885')
      RETURN FALSE
   END IF

   DELETE FROM ad_ap_885
    WHERE cod_empresa = p_cod_emp_orig
      AND num_ad      = p_num_ad
            
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Deletando','ad_ap_885')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION



#--------------------------#
FUNCTION pol0888_rev_estoq()
#--------------------------#

   MESSAGE 'Aguarde!... processando.', p_num_ar
   
   DECLARE cq_le_cont CURSOR WITH HOLD FOR
    SELECT num_transac
      FROM cont_aparas_885
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
     ORDER BY num_transac

   FOREACH cq_le_cont INTO p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","cq_le_cont")       
         RETURN FALSE
      END IF   

      SELECT *
        INTO p_insumo.*
        FROM insumo_885
       WHERE cod_empresa = p_cod_empresa
         AND num_sequencia = p_num_transac

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","insumo_885:cq_le_cont")       
         RETURN FALSE
      END IF   
      
      IF p_insumo.cod_status = 0 THEN
         IF NOT pol0888_del_insumo() THEN
            RETURN FALSE
         END IF
      ELSE
         IF NOT pol0888_ins_insumo() THEN
            RETURN FALSE
         END IF
      END IF      
   
   END FOREACH

END FUNCTION
   
#----------------------------#
FUNCTION pol0888_del_insumo()#
#----------------------------#

   DELETE FROM insumo_885
    WHERE cod_empresa = p_cod_empresa
      AND num_sequencia = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETE","insumo_885")       
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION pol0888_ins_insumo()#
#----------------------------#            

   LET p_insumo.cod_status = 0
   LET p_insumo.tip_movto = 'R'
   LET p_insumo.dat_geracao = CURRENT
   
   INSERT INTO insumo_885
    VALUES(p_insumo.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql('INSERT','insumo_885')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------FIM DO PROGRAMA-----------#
