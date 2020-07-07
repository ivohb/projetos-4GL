#-------------------------------------------------------------------#
# OBJETIVO:  NOTAS DE ENTRADA NÂO COMPLEMENTADAS                    #
# DATA....: 28/04/2008                                              #
# 06/10/09: Colocar item no filtro da consulta                      #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_num_ar             LIKE aviso_rec.num_aviso_rec,
          p_descarta           SMALLINT,
          p_ies_copiar         SMALLINT,
          p_imprimiu           SMALLINT,
          p_salto              SMALLINT,
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
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_chave              CHAR(400),
          p_query              CHAR(600)
          
   DEFINE p_cod_item           LIKE item.cod_item,
          p_ies_liberacao_cont LIKE aviso_rec.ies_liberacao_cont,
          p_ies_liberacao_insp LIKE aviso_rec.ies_liberacao_insp

   DEFINE p_tela               RECORD
          cod_fornecedor       LIKE fornecedor.cod_fornecedor,
          raz_social           LIKE fornecedor.raz_social,
          dat_ini              DATE,
          dat_fim              DATE,
          cod_item             CHAR(15)
   END RECORD 

   DEFINE pr_nf                ARRAY[5000] OF RECORD
          cod_fornecedor       LIKE nf_sup.cod_fornecedor,
          nom_reduzido         LIKE fornecedor.raz_social_reduz,
          num_nf               LIKE nf_sup.num_nf,
          ser_nf               LIKE nf_sup.ser_nf,
          ssr_nf               LIKE nf_sup.ssr_nf,
          especie              LIKE nf_sup.ies_especie_nf,
          dat_entrada_nf       LIKE nf_sup.dat_entrada_nf,
          val_nf               LIKE nf_sup.val_tot_nf_c,
          num_ar               LIKE nf_sup.num_aviso_rec,
          copiar               CHAR(01)   
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

#variáveis para utilização na rotina processa
   
  DEFINE p_dat_inclusao_seq   LIKE aviso_rec.dat_inclusao_seq,
         #p_num_ar             LIKE aviso_rec.num_aviso_rec,
         p_num_ar_atu         LIKE aviso_rec.num_aviso_rec,
         p_ies_ctr_estoque    LIKE item.ies_ctr_estoque,
         p_num_lote           LIKE estoque_lote.num_lote,
         p_largura            LIKE estoque_trans_end.largura,
         p_altura             LIKE estoque_trans_end.altura,
         p_diametro           LIKE estoque_trans_end.diametro,
         p_comprimento        LIKE estoque_trans_end.comprimento,
         p_qtd_movto          LIKE estoque_trans.qtd_movto,
         p_ies_situa          LIKE estoque_lote.ies_situa_qtd,
         p_cod_local          LIKE aviso_rec.cod_local_estoq,
         p_oper_insp          LIKE estoque_trans.cod_operacao,
         p_val_movto          LIKE estoque_trans.cus_tot_movto_p,
         p_cod_emp_dest       LIKE empresa.cod_empresa,
         p_num_pedido         LIKE aviso_rec.num_pedido,
         p_num_ped_compra     LIKE aviso_rec.num_pedido,
         p_num_oc             LIKE aviso_rec.num_oc,
         p_num_nf             LIKE nf_sup.num_nf,
       	 p_cod_operacao       LIKE estoque_trans.cod_operacao,
       	 p_pct_desc           LIKE desc_ped_sup_885.pct_desc,
       	 p_dat_movto          LIKE estoque_trans.dat_movto,
         p_cod_familia        LIKE item.cod_familia,
         p_dat_emis_nf        LIKE nf_sup.dat_emis_nf,
       	 p_num_conta          LIKE item_sup.num_conta,
         p_cod_fornecedor     LIKE nf_sup.cod_fornecedor,
         p_raz_social         LIKE fornecedor.raz_social,
         p_pct_umid_pad       LIKE parametros_885.pct_umid_pad,
         p_pct_umid_med       LIKE parametros_885.pct_umid_pad,
         p_apara_nobre        LIKE parametros_885.cod_apara_nobre,
         p_num_docum          LIKE estoque_trans.num_docum,
         p_num_prx_ar         LIKE aviso_rec.num_aviso_rec,
         p_cod_oper_cval      LIKE parametros_885.cod_oper_ent_valor,
         p_cod_oper_cqv       LIKE parametros_885.cod_oper_ent_vrqtd,
         p_fat_conversao      LIKE ordem_sup.fat_conver_unid,
         p_qtd_item           LIKE estoque_trans.qtd_movto,
         p_den_item           LIKE item.den_item,
         p_num_seq            LIKE aviso_rec.num_seq,
         #p_cod_item           LIKE aviso_rec.cod_item,
         p_cod_itema          LIKE aviso_rec.cod_item,
         p_qtd_lote           LIKE aviso_rec.qtd_declarad_nf,
         p_qtd_calculada      LIKE aviso_rec.qtd_declarad_nf,
         p_val_lote           LIKE aviso_rec.val_liquido_item,
         p_val_gravado        LIKE aviso_rec.val_liquido_item,
         p_pct_valor_liquido  LIKE aviso_rec.val_liquido_item,
         p_cod_cnd_pgto       LIKE cotacao_preco_885.cnd_pgto,
         p_num_ad             LIKE ad_mestre.num_ad,
         p_cod_tip_despesa    LIKE ad_mestre.cod_tip_despesa,
         p_val_nf             LIKE nf_sup.val_tot_nf_c,
         p_num_ap             LIKE ap.num_ap,
         p_num_conta_cred     LIKE grupo_despesa.num_conta_fornec,
         p_num_conta_deb      LIKE dest_aviso_rec.num_conta_deb_desp,
         p_cod_grp_despesa    LIKE grupo_despesa.cod_grp_despesa,
         p_cod_hist_deb_ap    LIKE tipo_despesa.cod_hist_deb_ap,
         p_qtd_dias_sd        LIKE cond_pgto_item.qtd_dias_sd,
         p_cod_emp_atu        LIKE empresa.cod_empresa

  DEFINE p_ies_apara          CHAR(01),
         p_sem_movto          SMALLINT,
         p_qtd_fardos         DECIMAL(04,0),
         p_preco_item         DECIMAL(17,6),
         p_val_item           DECIMAL(17,6),
         p_val_nota_ofic      DECIMAL(17,6),
         p_val_nota_ger       DECIMAL(17,6),
         #p_ies_liberacao_cont CHAR(01),
         #p_ies_liberacao_insp CHAR(01),
         p_pre_unit           DECIMAL(17,6),
         p_msg                CHAR(75),
         p_gerar              CHAR(01),
         sql_stmt             CHAR(500),
         where_clause         CHAR(500),
         p_hora               DATETIME HOUR TO SECOND,
         p_qtd_parcelas       INTEGER,
         p_val_parcela        DECIMAL(15,2),
         p_dat_vencto         DATETIME YEAR TO DAY,
         p_num_parcela        SMALLINT,
         p_qtd_cont           DECIMAL(10,3),
         p_val_calc           DECIMAL(12,2),
         p_num_seqa           SMALLINT,
         p_num_transac        INTEGER,
         p_num_transaca       INTEGER,
         p_transac_orig       INTEGER,
         p_inseriu_ar         SMALLINT,
         p_ind                SMALLINT

   DEFINE p_nf_sup             RECORD LIKE nf_sup.*,
          p_aviso_rec          RECORD LIKE aviso_rec.*,
          p_ar_sq              RECORD LIKE aviso_rec_compl_sq.*,
          p_ar_compl           RECORD LIKE aviso_rec_compl.*,
          p_dest_ar            RECORD LIKE dest_aviso_rec.*,
          p_estoque_auditoria  RECORD LIKE estoque_auditoria.*,
          p_audit_ar           RECORD LIKE audit_ar.*,
          p_estoque_trans      RECORD LIKE estoque_trans.*,
          p_estoque_trans_end  RECORD LIKE estoque_trans_end.*,
          p_estoque_lote       RECORD LIKE estoque_lote.*,
          p_estoque_lote_ender RECORD LIKE estoque_lote_ender.*,
          p_adiant             RECORD LIKE adiant.*,
          p_mov_adiant         RECORD LIKE mov_adiant.*,
          p_ad_mestre          RECORD LIKE ad_mestre.*,
          p_ap                 RECORD LIKE ap.*,
          p_lanc_cont_cap      RECORD LIKE lanc_cont_cap.*
          
   DEFINE pr_itens             ARRAY[50] OF RECORD
          num_seq              DECIMAL(2,0),
          cod_item             CHAR(15),
          num_lote             CHAR(15),
          qtd_lote             DECIMAL(10,3),
          val_lote             DECIMAL(12,2),
          qtd_fardos           DECIMAL(04,0),
          pct_umid             DECIMAL(04,2),
          qtd_contagem         DECIMAL(10,3),
          val_calculado        DECIMAL(12,2)
   END RECORD

   DEFINE p_aen              RECORD 
          cod_lin_prod       LIKE item.cod_lin_prod,
          cod_lin_recei      LIKE item.cod_lin_recei,
          cod_seg_merc       LIKE item.cod_seg_merc,
          cod_cla_uso        LIKE item.cod_cla_uso
   END RECORD
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "POL0796-05.10.08"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0796.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0796_controle()
   END IF
   
END MAIN

#--------------------------#
 FUNCTION pol0796_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0796") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0796 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa

   IF NOT pol0796_le_parametros() THEN
      RETURN
   END IF

   IF NOT pol0796_cria_tab() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Informar" "Iforma os parâmetros p/ a consulta "
         CALL pol0796_informar() RETURNING p_status
         IF p_status THEN
            ERROR 'Parâmetros informados com sucesso'
            LET p_ies_cons = TRUE
            NEXT OPTION 'Consultar'
         ELSE
            ERROR "Operação Cancelada !!!"
            LET p_ies_cons = FALSE
         END IF
      COMMAND "Consultar" "Exibe NF's e seleciona-as p/ processamento"
         IF p_ies_cons THEN
            CALL pol0796_consultar() RETURNING p_status
            IF p_status THEN
               ERROR 'Operação efetuada com sucesso !!!'
               LET p_ies_copiar = TRUE
            ELSE
               ERROR 'Operação cancelada !!!'
               LET p_ies_copiar = FALSE
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!'
            NEXT OPTION 'Informar'
         END IF
      COMMAND "Processar" "Processa a complementação do estoque "
         IF p_ies_copiar THEN
            CALL pol0796_processar() RETURNING p_status
            IF p_status THEN
               LET p_msg = 'Processamento Concluído! '
            ELSE
               LET p_msg = "Processo interrompido - algumas NF's não foram copiadas"
            END IF
            CALL log0030_mensagem(p_msg,'excla')
            LET p_ies_cons = FALSE
            LET p_ies_copiar = FALSE
         ELSE
            ERROR 'Execute a consulta previamente !!!'
            NEXT OPTION "Consultar"
         END IF 
      COMMAND "Listar" "Lista as notas não complementadas "
         IF p_ies_cons THEN
            CALL pol0796_emite_relatorio()
         ELSE
            ERROR 'Informe os parâmetros previamente!'
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         EXIT MENU
   END MENU

   CLOSE WINDOW w_pol0796

END FUNCTION

#-------------------------------#
FUNCTION pol0796_le_parametros()
#-------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
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
         LET p_cod_emp_ger = p_cod_empresa
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0796_cria_tab()
#--------------------------#
 
      CREATE TEMP TABLE mov_tmp_885(
          num_transac      INTEGER,
          num_seq          DECIMAL(2,0),
          dat_inclusao_seq DATETIME YEAR TO DAY,
          cod_item         CHAR(15),
          num_conta        CHAR(25),
          num_oc           INTEGER,
          num_pedido       INTEGER,
          cod_tip_despesa  INTEGER,
          cod_local        CHAR(10),
          num_lote         CHAR(15),
          qtd_lote         DECIMAL(10,3),
          val_lote         DECIMAL(12,2),
          qtd_fardos       DECIMAL(04,0),              
          pct_umid         DECIMAL(5,2),
          qtd_cont         DECIMAL(10,3),
          val_calc         DECIMAL(12,2),
          ies_aparas       CHAR(01)
       );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","mov_tmp_885")
         RETURN FALSE
      END IF
 
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
      
      CREATE TEMP TABLE ar_tmp_885(
         num_seq  DECIMAL(3,0),
         qtd_lote DECIMAL(10,3),
         val_lote DECIMAL(12,2)
       );

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","ar_tmp_885")
         RETURN FALSE
      END IF

      RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol0796_informar()
#--------------------------#

   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD cod_fornecedor

         IF p_tela.cod_fornecedor IS NOT NULL THEN
            IF NOT pol0796_le_fornecedor() THEN
               ERROR p_msg
               NEXT FIELD cod_fornecedor
            END IF
         END IF
      
         DISPLAY p_tela.raz_social TO raz_social

      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_tela.dat_fim IS NOT NULL THEN
               IF p_tela.dat_ini IS NOT NULL THEN
                  IF p_tela.dat_ini > p_tela.dat_fim THEN
                     ERROR "Data Inicial nao pode ser maior que data Final"
                     NEXT FIELD dat_ini
                  END IF
               END IF 
            END IF
         END IF
            
      ON KEY (control-z)
         CALL pol0796_popup()

   END INPUT

   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0796_le_fornecedor()
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
FUNCTION pol0796_popup()
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
         
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
   
END FUNCTION

#------------------------------#
FUNCTION pol0796_monta_select()
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

   LET p_query =
    "SELECT cod_fornecedor, num_nf, ser_nf, ssr_nf, dat_entrada_nf, ",
    "       val_tot_nf_c, num_aviso_rec, ies_especie_nf ",
    "  FROM nf_sup WHERE ",p_chave CLIPPED,
    " ORDER BY cod_fornecedor, dat_entrada_nf "

   PREPARE var_query FROM p_query 

END FUNCTION

#---------------------------#
FUNCTION pol0796_consultar()
#---------------------------#

   DEFINE p_num_aviso LIKE aviso_rec.num_aviso_rec
   
   IF p_tela.dat_ini IS NULL THEN
      LET p_tela.dat_ini = '01/01/2009'
   END IF
   
   CALL pol0796_monta_select()

   DECLARE cq_nf CURSOR FOR var_query
   
   INITIALIZE pr_nf TO NULL
   
   LET p_index = 1
   
   FOREACH cq_nf INTO 
           pr_nf[p_index].cod_fornecedor,
           pr_nf[p_index].num_nf,
           pr_nf[p_index].ser_nf,
           pr_nf[p_index].ssr_nf,
           pr_nf[p_index].dat_entrada_nf,
           pr_nf[p_index].val_nf,
           pr_nf[p_index].num_ar,
           pr_nf[p_index].especie
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Cursor','cq_nf')
         RETURN FALSE
      END IF
      
      {SELECT num_nf
        FROM nf_sup
       WHERE cod_empresa = p_cod_emp_ger
         AND cod_fornecedor = pr_nf[p_index].cod_fornecedor
         AND num_nf         = pr_nf[p_index].num_nf
         AND ser_nf         = pr_nf[p_index].ser_nf
         AND ssr_nf         = pr_nf[p_index].ssr_nf
         AND ies_especie_nf = pr_nf[p_index].especie
   
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','nf_sup:cq_nf')
            RETURN FALSE
         END IF
      END IF}
      
      LET p_num_aviso = pr_nf[p_index].num_ar

      SELECT num_aviso_rec
        FROM ar_proces_885
       WHERE cod_empresa  = p_cod_empresa
        AND num_aviso_rec = p_num_aviso
    
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','ar_proces_885')
            LET p_imprimiu = FALSE
            EXIT FOREACH
         END IF
      END IF

      LET p_descarta = FALSE
      
      DECLARE cq_ar CURSOR FOR
       SELECT ies_liberacao_cont,
              ies_liberacao_insp ,
              cod_item      
         FROM aviso_rec
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_num_aviso
      
      FOREACH cq_ar INTO 
              p_ies_liberacao_cont,
              p_ies_liberacao_insp,
              p_cod_item           

         IF p_ies_liberacao_insp != 'S' OR
            p_ies_liberacao_cont != 'S' THEN
            LET p_descarta = TRUE
            EXIT FOREACH
         END IF
                  
      END FOREACH
      
      IF p_descarta THEN
         CONTINUE FOREACH
      END IF

      LET p_descarta = TRUE
      
      DECLARE cq_ar2 CURSOR FOR
       SELECT cod_item
         FROM aviso_rec
        WHERE cod_empresa   = p_cod_empresa
          AND num_aviso_rec = p_num_aviso
      
      FOREACH cq_ar2 INTO 
              p_cod_item
      
         SELECT cod_item
           FROM item
          WHERE cod_empresa     = p_cod_empresa
            AND cod_item        = p_cod_item
            AND ies_ctr_estoque = 'S'
         
         IF STATUS = 0 THEN
            LET p_descarta = FALSE
            EXIT FOREACH
         END IF
         
      END FOREACH
      
      IF p_descarta THEN
         CONTINUE FOREACH
      END IF

      IF p_tela.cod_item IS NOT NULL THEN
         SELECT COUNT(cod_item)
           INTO p_count
           FROM aviso_rec
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_num_aviso
            AND cod_item      = p_tela.cod_item
 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','aviso_rec:count')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            CONTINUE FOREACH
         END IF
      END IF

      SELECT raz_social_reduz
        INTO pr_nf[p_index].nom_reduzido
        FROM fornecedor
       WHERE cod_fornecedor = pr_nf[p_index].cod_fornecedor
       
      IF STATUS <> 100 AND STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','nf_sup:cq_nf')
         RETURN FALSE
      END IF

      LET pr_nf[p_index].copiar = 'S'
      LET p_index = p_index + 1
              
   END FOREACH

   IF p_index = 1 THEN
      LET p_msg = 'Não há notas para os parâmetros informados'
      CALL log0030_mensagem(p_msg,'excla')
      LET p_ies_cons = FALSE
      RETURN FALSE
   END IF
   
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_index - 1)
      
   INPUT ARRAY pr_nf 
      WITHOUT DEFAULTS FROM sr_nf.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION

#---------------------------------#
FUNCTION pol0796_emite_relatorio()
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
         LET p_caminho = p_caminho CLIPPED, "pol0796.tmp"
         START REPORT pol0796_notas_lista TO p_caminho
      ELSE
         START REPORT pol0796_notas_lista TO p_nom_arquivo
      END IF
   END IF

   MESSAGE "Aguarde!... Imprimindo..." ATTRIBUTE(REVERSE)

   CALL pol0796_monta_select()

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
        FROM ar_proces_885
       WHERE cod_empresa  = p_cod_empresa
        AND num_aviso_rec = p_relat.num_ar
    
      IF STATUS = 0 THEN
         CONTINUE FOREACH
      ELSE
         IF STATUS <> 100 THEN
            CALL log003_err_sql('Lendo','ar_proces_885')
            LET p_imprimiu = FALSE
            EXIT FOREACH
         END IF
      END IF

      IF p_tela.cod_item IS NOT NULL THEN
         SELECT COUNT(cod_item)
           INTO p_count
           FROM aviso_rec
          WHERE cod_empresa   = p_cod_empresa
            AND num_aviso_rec = p_relat.num_ar
            AND cod_item      = p_tela.cod_item
 
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Lendo','aviso_rec:count')
            RETURN FALSE
         END IF
         
         IF p_count = 0 THEN
            CONTINUE FOREACH
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

      OUTPUT TO REPORT pol0796_notas_lista()

      LET p_imprimiu = TRUE
         
   
   END FOREACH
   
   FINISH REPORT pol0796_notas_lista

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
 REPORT pol0796_notas_lista()
#--------------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 069, "PAG. ", PAGENO USING "&&&&"
               
         PRINT COLUMN 001, "pol0796",
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

#---------------------------#
FUNCTION pol0796_processar()
#---------------------------#

   MESSAGE 'Copiando AR:'

   FOR p_index = 1 TO ARR_COUNT()
       IF pr_nf[p_index].copiar = 'S' THEN
          LET p_num_ar = pr_nf[p_index].num_ar
          DISPLAY p_num_ar AT 21,15
          CALL log085_transacao("BEGIN")
          IF NOT pol0796_copia_ar() THEN
             CALL log085_transacao("ROLLBACK")
          END IF
          CALL log085_transacao("COMMIT")
       END IF
   END FOR
   
   RETURN TRUE
   
END FUNCTION

#--------------------------#
FUNCTION pol0796_copia_ar()
#--------------------------#

   DEFINE p_cod_emp_ofic CHAR(02)
   
   LET p_cod_emp_dest = p_cod_emp_ger

   SELECT cod_operac_estoq_l
     INTO p_oper_insp
     FROM par_sup
    WHERE cod_empresa = p_cod_empresa
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","PAR_SUP")       
      RETURN FALSE
   END IF

   DELETE FROM mov_tmp_885
   DELETE FROM contas_tmp_885
   DELETE FROM ar_tmp_885
   
   LET p_sem_movto = TRUE
   INITIALIZE p_num_ped_compra TO NULL

   SELECT dat_entrada_nf
     INTO p_dat_inclusao_seq
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup:2")       
      RETURN FALSE
   END IF
   
   LET p_num_docum = p_num_ar

   DECLARE cq_ct CURSOR FOR
    SELECT num_seq,
           cod_item,
           cod_local_estoq,
           pre_unit_nf,
           num_oc,
           num_pedido,
           cod_tip_despesa
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
     ORDER BY num_seq
   
   FOREACH cq_ct INTO 
           p_num_seq,
           p_cod_item,
           p_cod_local,
           p_pre_unit,
           p_num_oc,
           p_num_pedido,
           p_cod_tip_despesa

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","aviso_rec:cq_cc")       
         RETURN FALSE
      END IF
      
      IF p_cod_item = p_apara_nobre THEN
         CONTINUE FOREACH
      END IF
      
      IF NOT pol0796_le_item(p_cod_item) THEN
         RETURN FALSE
      END IF
  
      SELECT cod_familia
        FROM familia_insumo_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_familia = p_cod_familia
         AND ies_apara   = 'S'
   
      IF STATUS = 100 THEN
         LET p_ies_apara = 'N'
      ELSE
         IF STATUS = 0 THEN
            LET p_ies_apara = 'S'
         ELSE
            CALL log003_err_sql("LENDO","familia_insumo_885")       
            RETURN FALSE
         END IF
      END IF

      SELECT num_conta_deb_desp 
        INTO p_num_conta
        FROM dest_aviso_rec
       WHERE cod_empresa   = p_cod_empresa
         AND num_aviso_rec = p_num_ar
         AND num_seq       = p_num_seq

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','dest_aviso_rec')
         RETURN FALSE
      END IF     
      
      DECLARE cq_lm CURSOR FOR
       SELECT num_transac,
              dat_movto,
              qtd_movto,
              num_lote_dest,
              ies_sit_est_dest
         FROM estoque_trans
        WHERE cod_empresa   = p_cod_empresa
          AND num_docum     = p_num_docum
          AND num_seq       = p_num_seq
          AND cod_item      = p_cod_item
          AND cod_operacao  = p_oper_insp
          AND ies_tip_movto = 'N'
          AND dat_movto     >= '01/01/2009'
          ORDER BY 1
                             
      FOREACH cq_lm INTO 
              p_num_transac,
              p_dat_movto,
              p_qtd_movto,
              p_num_lote,
              p_ies_situa
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans:1")       
            RETURN FALSE 
         END IF

         SELECT COUNT(num_transac)
           INTO p_count
           FROM estoque_trans
          WHERE cod_empresa      = p_cod_empresa
            AND num_docum        = p_num_docum
            AND num_seq          = p_num_seq
            AND cod_item         = p_cod_item
            AND cod_operacao     = p_oper_insp
            AND dat_movto        = p_dat_movto
            AND qtd_movto        = p_qtd_movto
            AND num_lote_dest    = p_num_lote
            AND ies_sit_est_dest = p_ies_situa
            AND ies_tip_movto    = 'R'
            AND num_transac      > p_num_transac
          
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans:2")       
            RETURN FALSE 
         END IF

         IF p_count > 0 THEN
            CONTINUE FOREACH
         END IF

         SELECT *
           INTO p_estoque_trans.*
           FROM estoque_trans
          WHERE cod_empresa = p_cod_empresa
            AND num_transac = p_num_transac
         
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","estoque_trans:3")       
            RETURN FALSE 
         END IF
         
         LET p_sem_movto = FALSE
         LET p_val_movto = p_estoque_trans.qtd_movto * p_pre_unit
         
         
         INSERT INTO mov_tmp_885 VALUES(
             p_estoque_trans.num_transac,
             p_estoque_trans.num_seq,
             p_dat_inclusao_seq,
             p_estoque_trans.cod_item,
             p_num_conta,
             p_num_oc,
             p_num_pedido,
             p_cod_tip_despesa,
             p_estoque_trans.cod_local_est_dest,
             p_estoque_trans.num_lote_dest,
             p_estoque_trans.qtd_movto,
             p_val_movto,
             NULL, 
             NULL, 
             NULL,
             NULL,
             p_ies_apara)

         IF STATUS <> 0 THEN
            CALL log003_err_sql("Inserindo","mov_tmp_885")       
            RETURN FALSE 
         END IF      
         
      END FOREACH
      
   END FOREACH

   IF p_sem_movto THEN
      LET p_msg = 'Não há dados a serem movimentos' 
      CALL log0030_mensagem(p_msg,'exclamation')
      RETURN FALSE
   END IF


   SELECT cod_oper_ent_vrqtd,
          cod_oper_ent_valor,
          pct_umid_pad,
          cod_apara_nobre
     INTO p_cod_oper_cqv,
          p_cod_oper_cval,
          p_pct_umid_pad,
          p_apara_nobre
     FROM parametros_885
    WHERE cod_empresa = p_cod_emp_dest

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","parametros_885")       
      RETURN FALSE
   END IF

   IF NOT pol0796_processa_entradas() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
FUNCTION pol0796_le_item(p_cod_item)
#----------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   SELECT cod_unid_med,
          cod_lin_prod, 
          cod_lin_recei,
          cod_seg_merc, 
          cod_cla_uso,
          ies_ctr_estoque,
          cod_familia,
          den_item          
     INTO p_aviso_rec.cod_unid_med_nf,
          p_aen.cod_lin_prod,
          p_aen.cod_lin_recei,
          p_aen.cod_seg_merc,
          p_aen.cod_cla_uso,
          p_ies_ctr_estoque,
          p_cod_familia,
          p_den_item
     FROM item  
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item

   IF SQLCA.SQLCODE <> 0 THEN 
      CALL log003_err_sql("Lendo","item:1")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#-----------------------------------#
FUNCTION pol0796_processa_entradas()
#-----------------------------------#

   SELECT COUNT(num_seq) 
     INTO p_count
     FROM mov_tmp_885
    WHERE ies_aparas = 'S'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","mov_tmp_885:1")       
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      IF NOT pol0796_processa_aparas() THEN
         RETURN FALSE
      END IF
   END IF
  
   SELECT COUNT(num_seq) 
     INTO p_count
     FROM mov_tmp_885
    WHERE ies_aparas = 'N'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","mov_tmp_885:2")       
      RETURN FALSE
   END IF
    
   IF p_count > 0 THEN
      IF NOT pol0796_processa_nao_aparas() THEN
         RETURN FALSE
      END IF
   END IF

   {IF NOT pol0796_update_na_zero() THEN
      RETURN FALSE
   END IF}

   IF NOT pol0796_insere_ar_proces() THEN
      RETURN FALSE
   END IF
  
   RETURN TRUE
   
END FUNCTION


#---------------------------------#
FUNCTION pol0796_processa_aparas()
#---------------------------------#

   IF NOT pol0796_informa_dados() THEN
      RETURN FALSE
   END IF

   LET p_inseriu_ar = FALSE
   LET p_val_nota_ofic = 0
   LET p_val_nota_ger  = 0
   LET p_val_item = 0

   DECLARE cq_apara CURSOR FOR 
    SELECT num_transac,
           num_seq,
           dat_inclusao_seq,
           cod_item,
           num_conta,
           num_oc,
           cod_tip_despesa,
           cod_local,
           num_lote,
           qtd_lote,
           val_lote,
           qtd_fardos,
           pct_umid,
           qtd_cont,
           val_calc
      FROM mov_tmp_885
     WHERE ies_aparas = 'S'
       
   FOREACH cq_apara INTO 
           p_num_transac,
           p_num_seq,
           p_dat_inclusao_seq,
           p_cod_item,
           p_num_conta,
           p_num_oc,
           p_cod_tip_despesa,
           p_cod_local,
           p_num_lote,
           p_qtd_lote,
           p_val_lote,
           p_qtd_fardos,
           p_pct_umid_med,
           p_qtd_cont,
           p_val_calc

       INSERT INTO pesagem_aparas_885
         VALUES(p_cod_empresa,
                p_num_ar,
                p_num_seq,
                p_cod_item,
                p_num_lote,
                p_qtd_lote,
                p_qtd_cont,
                p_qtd_fardos,
                p_pct_umid_med)
       
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Insert','pesagem_aparas_885')
          RETURN FALSE
       END IF   
                
       LET p_val_nota_ofic = p_val_nota_ofic + p_val_lote
       LET p_val_nota_ger  = p_val_nota_ger  + p_val_calc

       IF NOT pol0796_le_ordem_sup() THEN
          RETURN FALSE
       END IF

       IF NOT pol0796_le_item(p_cod_item) THEN
          RETURN FALSE
       END IF

       IF p_ies_ctr_estoque <> 'S' THEN     
          CONTINUE FOREACH
       END IF

       LET p_val_movto = 0
       LET p_pre_unit  = 0
       
       LET p_qtd_lote = p_qtd_cont

       LET p_gerar = 'E'
       LET p_cod_operacao = p_cod_oper_cqv

       IF NOT pol0796_insere_estoque() THEN
          RETURN FALSE
       END IF

   END FOREACH

   IF p_val_nota_ofic < p_val_nota_ger THEN
      IF NOT pol0796_gera_ad() THEN
         RETURN FALSE
      END IF
   END IF 
   
   IF p_val_nota_ofic > p_val_nota_ger THEN
      IF NOT pol0796_gera_adiantamento() THEN
         RETURN FALSE
      END IF
   END IF
  
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol0796_insere_aviso()
#------------------------------#

   LET p_val_nf = 0
   
   DECLARE cq_aviso CURSOR FOR
    SELECT num_seq,
       SUM (qtd_lote),
       SUM (val_lote)
      FROM ar_tmp_885
     GROUP BY num_seq
     ORDER BY num_seq
   
   FOREACH cq_aviso INTO p_num_seq, p_qtd_lote, p_val_lote
      LET p_pre_unit = p_val_lote / p_qtd_lote
      LET p_val_nf = p_val_nf + p_val_lote
      IF NOT pol0796_insere_ar() THEN
         RETURN FALSE
      END IF
   END FOREACH
   
   IF NOT pol0662_insere_ar_compl() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0796_insere_nf_sup() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#------------------------------#
FUNCTION pol0796_informa_dados()
#------------------------------#

   IF NOT pol0796_exib_cabec() THEN
      RETURN FALSE
   END IF

   INITIALIZE pr_itens TO NULL
   
   LET INT_FLAG = FALSE
   
   LET p_index = 1

   DECLARE cq_dados CURSOR FOR
    SELECT num_seq,
           cod_item,
           num_lote,
           qtd_lote,
           val_lote
      FROM mov_tmp_885
     ORDER BY num_seq
   
   FOREACH cq_dados INTO 
           pr_itens[p_index].num_seq,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].num_lote, 
           pr_itens[p_index].qtd_lote,
           pr_itens[p_index].val_lote

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","mov_tmp_885:3")       
         RETURN FALSE
      END IF

      LET p_index = p_index + 1
      
      IF p_index > 50 THEN
         CALL log0030_mensagem('Limite de Itens do AR Ultrapassado.','exclamation')
         RETURN FALSE
      END IF
      
   END FOREACH
   
   LET INT_FLAG = FALSE
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_itens 
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE INPUT
         FOR p_ind = 1 TO ARR_COUNT()
             DISPLAY '' TO sr_itens[p_ind].val_lote
         END FOR
         
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()

         IF pr_itens[p_index].cod_item IS NOT NULL THEN
            IF NOT pol0796_le_item(pr_itens[p_index].cod_item) THEN
               RETURN FALSE
            END IF
            DISPLAY p_den_item TO den_item
         END IF

      AFTER FIELD qtd_fardos
         IF pr_itens[p_index].cod_item IS NOT NULL THEN
            IF pr_itens[p_index].qtd_fardos IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório !!!'
               NEXT FIELD qtd_fardos
            END IF
         END IF
         
      AFTER FIELD pct_umid
         IF pr_itens[p_index].cod_item IS NOT NULL THEN
            IF pr_itens[p_index].pct_umid IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório !!!'
               NEXT FIELD pct_umid
            END IF
         END IF

      AFTER FIELD qtd_contagem
         IF pr_itens[p_index].cod_item IS NOT NULL THEN

            IF pr_itens[p_index].qtd_contagem IS NULL THEN
               ERROR 'Campo com preenchimento obrigatório !!!'
               NEXT FIELD qtd_contagem
            END IF

            IF NOT pol0796_le_cotacao(pr_itens[p_index].cod_item) THEN
               RETURN FALSE
            END IF

            IF p_preco_item IS NULL THEN
               SELECT pre_unit_nf
                 INTO p_preco_item
                 FROM aviso_rec
                WHERE cod_empresa   = p_cod_empresa
                  AND num_aviso_rec = p_num_ar
                  AND num_seq       = pr_itens[p_index].num_seq
                  AND cod_item      = pr_itens[p_index].cod_item

               IF STATUS <> 0 THEN
                  CALL log003_err_sql('Lendo','aviso_rec')
                  RETURN FALSE
               END IF
            END IF
                      
            LET p_qtd_calculada = pr_itens[p_index].qtd_contagem -
                                  pr_itens[p_index].qtd_contagem * pr_itens[p_index].pct_umid / 100
            LET p_qtd_calculada = p_qtd_calculada + pr_itens[p_index].qtd_contagem * p_pct_umid_pad / 100
            LET pr_itens[p_index].val_calculado = p_qtd_calculada * p_preco_item
            
         END IF

      AFTER INPUT
         IF NOT INT_FLAG THEN
            FOR p_ind = 1 TO ARR_COUNT()
                IF pr_itens[p_ind].val_calculado IS NULL THEN
                   ERROR 'Favor informar Umidade e/ou Contagem p/ todos os itens!'
                   NEXT FIELD pct_umid
                ELSE
                   UPDATE mov_tmp_885
                      SET qtd_fardos = pr_itens[p_ind].qtd_fardos,
                          pct_umid   = pr_itens[p_ind].pct_umid,
                          qtd_cont   = pr_itens[p_ind].qtd_contagem,
                          val_calc   = pr_itens[p_ind].val_calculado
                    WHERE num_seq  = pr_itens[p_ind].num_seq
                      AND cod_item = pr_itens[p_ind].cod_item
                      AND num_lote = pr_itens[p_ind].num_lote
                   IF STATUS <> 0 THEN
                      CALL log003_err_sql('Update','mov_tmp_885:1')
                      RETURN FALSE
                   END IF
                END IF
            END FOR
         END IF
         
   END INPUT
   
   IF NOT INT_FLAG THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#----------------------------#
FUNCTION pol0796_exib_cabec()
#----------------------------#

   SELECT *
     INTO p_nf_sup.*
     FROM nf_sup
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","nf_sup:1")       
      RETURN FALSE
   END IF
   
   SELECT raz_social
     INTO p_raz_social
     FROM fornecedor
    WHERE cod_fornecedor = p_nf_sup.cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","fornecedor")       
      RETURN FALSE
   END IF

   DISPLAY p_nf_sup.num_nf         TO num_nf
   DISPLAY p_nf_sup.dat_emis_nf    TO dat_emis
   DISPLAY p_nf_sup.num_aviso_rec  TO num_ar
   DISPLAY p_nf_sup.cod_fornecedor TO cod_fornecedor
   DISPLAY p_raz_social            TO raz_social
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0796_le_cotacao(p_cod_item)
#-------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item
   
   INITIALIZE p_preco_item TO NULL

   DECLARE cq_cota CURSOR FOR
    SELECT pre_unit_fob,
           cnd_pgto
      FROM cotacao_preco_885
     WHERE cod_empresa      = p_cod_empresa
       AND cod_fornecedor   = p_nf_sup.cod_fornecedor
       AND cod_item         = p_cod_item
       
    IF STATUS <> 0 AND STATUS <> 100 THEN
       CALL log003_err_sql('LENDO','cotacao_preco')
       RETURN FALSE
    END IF

   FOREACH cq_cota INTO p_preco_item, p_cod_cnd_pgto
      EXIT FOREACH
   END FOREACH
   
   IF p_cod_cnd_pgto IS NULL THEN
      LET p_cod_cnd_pgto = p_nf_sup.cnd_pgto_nf
   END IF
   
   RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol0796_le_ordem_sup()
#------------------------------#

   INITIALIZE p_fat_conversao TO NULL
   
   DECLARE cq_conv CURSOR FOR
    SELECT fat_conver_unid
      FROM ordem_sup
     WHERE cod_empresa      = p_cod_empresa
       AND num_oc           = p_num_oc
       AND cod_item         = p_cod_item
       AND ies_versao_atual = 'S'
       
   FOREACH cq_conv INTO p_fat_conversao

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','Ordem_sup')
         RETURN FALSE
      END IF

      EXIT FOREACH

   END FOREACH
   
   IF p_fat_conversao IS NULL THEN
      LET p_fat_conversao = 1
   END IF

   RETURN TRUE
   
END FUNCTION




#-----------------------------#
 FUNCTION pol0258_gera_num_ar()
#-----------------------------#

   SELECT par_val    
     INTO p_num_prx_ar 
     FROM par_sup_pad
    WHERE cod_empresa   = p_cod_emp_dest   
      AND cod_parametro = "num_prx_ar" 

    IF sqlca.sqlcode <>   0   THEN 
       CALL log003_err_sql("SELECT" ,"PAR_SUP_PAD")
       RETURN FALSE
    END IF

    UPDATE par_sup_pad  
       SET par_val = (par_val + 1)
     WHERE cod_empresa   = p_cod_emp_dest    
       AND cod_parametro = "num_prx_ar" 

   RETURN TRUE
          
END FUNCTION

#-----------------------------#
FUNCTION pol0662_grava_ar_tmp()
#-----------------------------#

   INSERT INTO ar_tmp_885
      VALUES(p_num_seq, p_qtd_lote, p_val_movto)
   
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","ar_tmp_885")
      RETURN FALSE
   END IF       
  
   IF NOT pol0796_insere_estoque() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
          
END FUNCTION

#---------------------------#
FUNCTION pol0796_insere_ar()
#---------------------------#

   LET p_inseriu_ar = TRUE
   
   SELECT * 
     INTO p_aviso_rec.*
     FROM aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND num_seq       = p_num_seq
      AND cod_item      = p_cod_item
      
   IF sqlca.sqlcode <> 0   THEN 
      CALL log003_err_sql("SELECT" ,"aviso_rec")
      RETURN FALSE
   END IF

   LET p_cod_emp_atu = p_cod_emp_dest
   LET p_num_ar_atu  = p_num_prx_ar
   
   LET p_aviso_rec.qtd_declarad_nf      = p_qtd_lote
   LET p_aviso_rec.qtd_recebida         = p_qtd_lote
   LET p_aviso_rec.qtd_liber            = p_qtd_lote
   LET p_aviso_rec.val_liquido_item     = p_val_lote
   LET p_aviso_rec.val_contabil_item    = p_val_lote
   LET p_aviso_rec.val_base_c_item_d    = p_val_lote
   LET p_aviso_rec.val_base_c_item_c    = p_val_lote
   LET p_aviso_rec.pre_unit_nf          = p_pre_unit
   LET p_aviso_rec.cod_empresa          = p_cod_emp_dest
   LET p_aviso_rec.num_aviso_rec        = p_num_prx_ar
   LET p_aviso_rec.num_seq              = p_num_seq
   LET p_aviso_rec.ies_situa_ar         = "E"                         
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

   INSERT INTO aviso_rec VALUES (p_aviso_rec.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","AVISO_REC")
      RETURN FALSE
   END IF

   LET p_audit_ar.nom_usuario    = p_user
   LET p_audit_ar.dat_hor_proces = CURRENT
   LET p_audit_ar.ies_tipo_auditoria = '1'
   LET p_audit_ar.cod_empresa    = p_aviso_rec.cod_empresa
   LET p_audit_ar.num_aviso_rec  = p_aviso_rec.num_aviso_rec
   LET p_audit_ar.num_seq        = p_aviso_rec.num_seq
   LET p_audit_ar.num_prog       = 'pol0796'
      
   INSERT INTO audit_ar VALUES(p_audit_ar.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","audit_ar")
      RETURN FALSE
   END IF       

   SELECT *
     INTO p_dest_ar.*
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar
      AND num_seq       = p_aviso_rec.num_seq

   IF STATUS = 0 THEN
      LET p_dest_ar.cod_empresa        = p_aviso_rec.cod_empresa  
      LET p_dest_ar.num_aviso_rec      = p_aviso_rec.num_aviso_rec

      INSERT INTO dest_aviso_rec VALUES (p_dest_ar.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","DEST_AVISO_REC")
         RETURN FALSE
      END IF       

   END IF
   
   SELECT *
     INTO p_ar_sq.*
     FROM aviso_rec_compl_sq
    WHERE cod_empresa       = p_cod_empresa
      AND num_aviso_rec     = p_num_ar
      AND num_seq           = p_aviso_rec.num_seq
    
   IF STATUS = 0 THEN     
      LET p_ar_sq.cod_empresa       =  p_aviso_rec.cod_empresa
      LET p_ar_sq.num_aviso_rec     =  p_aviso_rec.num_aviso_rec
      LET p_ar_sq.val_base_d_ipi_it =  0

      INSERT INTO aviso_rec_compl_sq VALUES (p_ar_sq.*)

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("INSERT","AVISO_REC_COMPL_SQ")
         RETURN FALSE
      END IF       
   END IF

   IF NOT pol0796_grava_tmp() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#--------------------------------#
FUNCTION pol0796_insere_estoque()
#--------------------------------#

   IF p_gerar = 'E' THEN
      IF NOT grava_estoque_trans() THEN
         RETURN FALSE
      END IF
   ELSE
      IF NOT pol0796_insere_trans() THEN
         RETURN FALSE
      END IF
   END IF

   IF p_ies_situa = 'L' THEN
      UPDATE estoque
         SET qtd_liberada    = qtd_liberada + p_qtd_lote,
             dat_ult_entrada = TODAY
       WHERE cod_empresa = p_cod_emp_dest
         AND cod_item    = p_cod_item
   ELSE
      IF p_ies_situa = 'E' THEN
         UPDATE estoque
            SET qtd_lib_excep   = qtd_lib_excep + p_qtd_lote,
                dat_ult_entrada = TODAY
          WHERE cod_empresa = p_cod_emp_dest
            AND cod_item    = p_cod_item
      ELSE
         LET p_msg = 'Situação do estoque inválida: ', p_ies_situa
         CALL log0030_mensagem(p_msg,'excla')
         RETURN FALSE
      END IF
   END IF
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Atualizando','estoque')
      RETURN FALSE
   END IF   

   IF NOT grava_estoque_lote() THEN
      RETURN FALSE
   END IF

   IF NOT grava_estoque_lote_ender() THEN
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#----------------------------#
FUNCTION grava_estoque_lote()
#----------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_emp_dest
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      = p_num_lote
   ELSE 
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote
       WHERE cod_empresa   = p_cod_emp_dest
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      IS NULL
   END IF
      
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','estoque_lote')
      RETURN FALSE
   END IF

   IF STATUS = 0 THEN
      UPDATE estoque_lote
         SET qtd_saldo = qtd_saldo + p_qtd_lote
       WHERE cod_empresa = p_cod_emp_dest
         AND num_transac = p_num_transac
   ELSE
      INSERT INTO estoque_lote(
         cod_empresa, 
         cod_item, 
         cod_local, 
         num_lote, 
         ies_situa_qtd, 
         qtd_saldo)  VALUES(p_cod_emp_dest,
                            p_cod_item,
                            p_cod_local,
                            p_num_lote,
                            p_ies_situa,
                            p_qtd_lote)
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','estoque_lote')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION grava_estoque_lote_ender()
#---------------------------------#

   IF p_num_lote IS NOT NULL THEN
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_emp_dest
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND num_lote      = p_num_lote
         AND largura       = p_estoque_trans_end.largura
         AND altura        = p_estoque_trans_end.altura
         AND diametro      = p_estoque_trans_end.diametro
         AND comprimento   = p_estoque_trans_end.comprimento
   ELSE 
      SELECT num_transac
        INTO p_num_transac
        FROM estoque_lote_ender
       WHERE cod_empresa   = p_cod_emp_dest
         AND cod_item      = p_cod_item
         AND cod_local     = p_cod_local
         AND ies_situa_qtd = p_ies_situa
         AND largura       = p_estoque_trans_end.largura
         AND altura        = p_estoque_trans_end.altura
         AND diametro      = p_estoque_trans_end.diametro
         AND comprimento   = p_estoque_trans_end.comprimento
         AND num_lote      IS NULL
   END IF
      
   IF STATUS <> 0 AND STATUS <> 100 THEN
      CALL log003_err_sql('Lendo','estoque_lote_ender:1')
      RETURN FALSE
   END IF

   IF STATUS = 0 THEN
      UPDATE estoque_lote_ender
         SET qtd_saldo = qtd_saldo + p_qtd_lote
       WHERE cod_empresa = p_cod_emp_dest
         AND num_transac = p_num_transac
   ELSE

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
          VALUES(p_estoque_trans_end.cod_empresa,
                 p_cod_item,
                 p_cod_local,
                 p_num_lote,
                 p_estoque_trans_end.endereco,
                 p_estoque_trans_end.num_volume,
                 p_estoque_trans_end.cod_grade_1,
                 p_estoque_trans_end.cod_grade_2,
                 p_estoque_trans_end.cod_grade_3,
                 p_estoque_trans_end.cod_grade_4,
                 p_estoque_trans_end.cod_grade_5,
                 p_estoque_trans_end.dat_hor_producao,
                 p_estoque_trans_end.num_ped_ven,
                 p_estoque_trans_end.num_seq_ped_ven,
                 p_ies_situa,
                 p_qtd_lote, ' ',
                 p_estoque_trans_end.dat_hor_validade,
                 p_estoque_trans_end.num_peca,
                 p_estoque_trans_end.num_serie,
                 p_estoque_trans_end.comprimento,
                 p_estoque_trans_end.largura,
                 p_estoque_trans_end.altura,
                 p_estoque_trans_end.diametro,
                 p_estoque_trans_end.dat_hor_reserv_1,
                 p_estoque_trans_end.dat_hor_reserv_2,
                 p_estoque_trans_end.dat_hor_reserv_3,
                 p_estoque_trans_end.qtd_reserv_1,
                 p_estoque_trans_end.qtd_reserv_2,
                 p_estoque_trans_end.qtd_reserv_3,
                 p_estoque_trans_end.num_reserv_1,
                 p_estoque_trans_end.num_reserv_2,
                 p_estoque_trans_end.num_reserv_3,
                 p_estoque_trans_end.tex_reservado)
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Gravando','estoque_lote_ender')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------------#
FUNCTION grava_estoque_trans()
#-----------------------------#

   INITIALIZE p_estoque_trans TO NULL 
   
   LET p_sem_movto = TRUE
   
   SELECT * 
     INTO p_estoque_trans.*
     FROM estoque_trans
    WHERE cod_empresa   = p_cod_empresa
      AND num_transac   = p_num_transac

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Foreach','cq_trans')
      RETURN FALSE
   END IF
      
   LET p_ies_situa = p_estoque_trans.ies_sit_est_dest
   LET p_sem_movto = FALSE
   LET p_transac_orig = p_num_transac
      
   IF NOT pol0796_insere_trans() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#------------------------------#
FUNCTION pol0796_insere_trans()
#------------------------------#

   LET p_estoque_trans.cod_empresa = p_cod_emp_dest
   LET  p_estoque_trans.qtd_movto  = p_qtd_lote
   LET p_estoque_trans.dat_movto   = p_dat_inclusao_seq

   IF p_gerar = 'E' THEN
      LET p_estoque_trans.cod_operacao     = p_cod_operacao 
      LET p_estoque_trans.cus_unit_movto_p = p_pre_unit
      LET p_estoque_trans.cus_tot_movto_p  = p_val_movto
      LET p_estoque_trans.num_conta        = p_num_conta
      LET p_estoque_trans.num_lote_dest    = p_num_lote
      LET p_estoque_trans.num_lote_orig    = NULL
      LET p_estoque_trans.ies_sit_est_orig = NULL
      LET p_estoque_trans.cod_local_est_orig = NULL
   ELSE
      LET  p_estoque_trans.cus_unit_movto_p = 0 
      LET  p_estoque_trans.cus_tot_movto_p  = 0 
      LET  p_estoque_trans.cus_unit_movto_f = 0
      LET  p_estoque_trans.cus_tot_movto_f  = 0
      LET  p_estoque_trans.num_docum        = p_num_prx_ar
      LET  p_estoque_trans.num_seq          = p_num_seq
   END IF

   LET  p_estoque_trans.num_prog           = "pol0796"
   LET  p_estoque_trans.nom_usuario        =  p_user

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
       

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("INSERT","ESTOQUE_TRANS")
       RETURN FALSE
    END IF       

    INITIALIZE p_estoque_trans_end TO NULL

    LET p_num_transac = SQLCA.SQLERRD[2]

    SELECT *
      INTO p_estoque_trans_end.*
      FROM estoque_trans_end
     WHERE cod_empresa = p_cod_empresa
       AND num_transac = p_transac_orig

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("LENDO","ESTOQUE_TRANS_END")
       RETURN FALSE
    END IF       
       
    LET p_estoque_trans_end.num_transac      = p_num_transac
    LET p_estoque_trans_end.cod_empresa      = p_estoque_trans.cod_empresa
    LET p_estoque_trans_end.qtd_movto        = p_estoque_trans.qtd_movto
    LET p_estoque_trans_end.cus_unit_movto_p = p_estoque_trans.cus_unit_movto_p
    LET p_estoque_trans_end.cus_unit_movto_f = p_estoque_trans.cus_unit_movto_f
    LET p_estoque_trans_end.cus_tot_movto_p  = p_estoque_trans.cus_tot_movto_p
    LET p_estoque_trans_end.cus_tot_movto_f  = p_estoque_trans.cus_tot_movto_f 
    LET p_estoque_trans_end.cod_item         = p_estoque_trans.cod_item
    LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
    LET p_estoque_trans_end.cod_operacao     = p_estoque_trans.cod_operacao
    LET p_estoque_trans_end.dat_movto        = p_estoque_trans.dat_movto
    LET p_estoque_trans_end.ies_tip_movto    = p_estoque_trans.ies_tip_movto
    LET p_estoque_trans_end.num_prog         = p_estoque_trans.num_prog

    INSERT INTO estoque_trans_end VALUES (p_estoque_trans_end.*)

    IF SQLCA.SQLCODE <> 0 THEN 
       CALL log003_err_sql("INSERÇÃO","ESTOQUE_TRANS_END")
       RETURN FALSE
    END IF

    LET p_estoque_auditoria.cod_empresa    = p_estoque_trans.cod_empresa
    LET p_estoque_auditoria.num_transac    = p_num_transac
    LET p_estoque_auditoria.nom_usuario    = p_user
    LET p_estoque_auditoria.dat_hor_proces = CURRENT
    LET p_estoque_auditoria.num_programa   = p_estoque_trans.num_prog
    
    INSERT INTO estoque_auditoria VALUES (p_estoque_auditoria.*)

    IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","estoque_auditoria")
        RETURN FALSE
    END IF

    INSERT INTO ar_transac_885
     VALUES(p_cod_emp_dest, p_num_transac, p_num_ar, p_estoque_trans.num_seq, p_qtd_fardos)

    IF SQLCA.SQLCODE <> 0 THEN 
        CALL log003_err_sql("INSERÇÃO","ar_transac_885")
        RETURN FALSE
    END IF
    
    RETURN TRUE
     
END FUNCTION 


#---------------------------------#
FUNCTION pol0662_insere_ar_compl()
#---------------------------------#

   SELECT *
     INTO p_ar_compl.*
     FROM aviso_rec_compl
    WHERE cod_empresa   = p_cod_empresa
      AND num_aviso_rec = p_num_ar

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Lendo","aviso_rec_compl")
      RETURN FALSE
   END IF       
      
   LET p_ar_compl.cod_empresa       = p_aviso_rec.cod_empresa
   LET p_ar_compl.num_aviso_rec     = p_aviso_rec.num_aviso_rec

   INSERT INTO aviso_rec_compl          
       VALUES (p_ar_compl.*)
      
   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","AVISO_REC_COMPL")
      RETURN FALSE
   END IF       
          
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0796_insere_nf_sup()
#-------------------------------#

   LET p_nf_sup.cod_empresa       = p_cod_emp_dest
   LET p_nf_sup.num_aviso_rec     = p_num_prx_ar
   LET p_nf_sup.cnd_pgto_nf       = p_cod_cnd_pgto
   LET p_nf_sup.val_tot_nf_c      = p_val_nf
   LET p_nf_sup.val_tot_nf_d      = p_val_nf
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
   LET p_nf_sup.ies_nf_com_erro   = 'S'
   
   INSERT INTO nf_sup VALUES (p_nf_sup.*)

   IF sqlca.sqlcode <> 0 THEN
      CALL log003_err_sql("INSERT","NF_SUP")
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF 

END FUNCTION

#-----------------------------------#
FUNCTION pol0796_gera_adiantamento()
#-----------------------------------#

   INITIALIZE p_adiant, p_mov_adiant TO NULL

   SELECT cod_empresa_destin
     INTO p_adiant.cod_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_empresa
   
   IF STATUS <> 0 THEN
      LET p_adiant.cod_empresa = p_cod_empresa
   END IF
      
   LET p_adiant.cod_fornecedor    = p_nf_sup.cod_fornecedor
   LET p_adiant.num_pedido        = p_num_ped_compra
   LET p_adiant.num_ad_nf_orig    = p_nf_sup.num_nf
   LET p_adiant.ser_nf            = p_nf_sup.ser_nf
   LET p_adiant.ssr_nf            = p_nf_sup.ssr_nf
   LET p_adiant.dat_ref           = p_nf_sup.dat_entrada_nf
   LET p_adiant.val_adiant        = p_val_nota_ofic - p_val_nota_ger
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
   LET p_mov_adiant.cod_fornecedor  = p_nf_sup.cod_fornecedor
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

#-------------------------#
FUNCTION pol0796_gera_ad()
#-------------------------#

   SELECT cod_empresa_destin
     INTO p_nf_sup.cod_empresa
     FROM emp_orig_destino
    WHERE cod_empresa_orig = p_cod_emp_dest
   
   IF STATUS <> 0 THEN
      LET p_nf_sup.cod_empresa = p_cod_emp_dest
   END IF

   IF NOT pol0796_le_par_ad() THEN 
      RETURN FALSE
   END IF

   IF NOT pol0796_insere_ad() THEN
      RETURN FALSE
   END IF

   IF NOT pol0796_insere_lanc() THEN
      RETURN FALSE
   END IF

   IF NOT pol0796_grava_aps() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0796_le_par_ad()
#---------------------------#

   SELECT ult_num_ad
     INTO p_num_ad
     FROM par_ad 
    WHERE cod_empresa = p_nf_sup.cod_empresa

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
   WHERE cod_empresa = p_nf_sup.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ad')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0796_le_par_ap()
#---------------------------#

   SELECT ult_num_ap 
     INTO p_num_ap
     FROM par_ap
    WHERE cod_empresa = p_nf_sup.cod_empresa

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
   WHERE cod_empresa = p_nf_sup.cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Update','par_ap')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol0796_insere_ad()
#---------------------------#

   IF NOT pol0796_calc_dat_vencto() THEN
      RETURN FALSE
   END IF
   
   LET p_ad_mestre.cod_empresa       = p_nf_sup.cod_empresa
   LET p_ad_mestre.num_ad            = p_num_ad
   LET p_ad_mestre.cod_tip_despesa   = p_cod_tip_despesa 
   LET p_ad_mestre.ser_nf            = p_nf_sup.ser_nf
   LET p_ad_mestre.ssr_nf            = p_nf_sup.ssr_nf
   LET p_ad_mestre.num_nf            = p_nf_sup.num_nf
   LET p_ad_mestre.dat_emis_nf       = p_nf_sup.dat_emis_nf
   LET p_ad_mestre.dat_rec_nf        = p_nf_sup.dat_entrada_nf
   LET p_ad_mestre.cod_empresa_estab = p_nf_sup.cod_empresa_estab
   LET p_ad_mestre.mes_ano_compet    = NULL
   LET p_ad_mestre.num_ord_forn      = NULL
   LET p_ad_mestre.cnd_pgto          = NULL
   LET p_ad_mestre.dat_venc          = p_dat_vencto
   LET p_ad_mestre.cod_fornecedor    = p_nf_sup.cod_fornecedor
   LET p_ad_mestre.cod_portador      = NULL
   LET p_ad_mestre.val_tot_nf        = p_val_nota_ger - p_val_nota_ofic
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
   LET p_ad_mestre.cod_empresa_orig  = p_cod_emp_dest

   INSERT INTO ad_mestre
      VALUES(p_ad_mestre.*)
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Inserindo','ad_mestre')
      RETURN FALSE
   END IF

   LET p_msg = p_ad_mestre.num_ad
   LET p_msg = 'pol0796 - INCLUSAO DA AD No. ', p_msg CLIPPED
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
FUNCTION pol0796_calc_dat_vencto()
#---------------------------------#

   SELECT qtd_dias_sd
     INTO p_qtd_dias_sd
     FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_nf_sup.cnd_pgto_nf
      AND sequencia    = 1
     
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','cond_pgto_item')
      RETURN FALSE
   END IF

   LET p_dat_vencto  = p_nf_sup.dat_emis_nf + p_qtd_dias_sd

   RETURN TRUE

END FUNCTION 

#-----------------------------#
FUNCTION pol0796_insere_lanc()
#-----------------------------#

   DEFINE p_num_seq SMALLINT
   
   LET p_num_seq = 0
   
   DECLARE cq_lanc CURSOR FOR
    SELECT cod_tip_despesa,
           num_conta_cred,
           num_conta_deb,
           val_movto
      FROM contas_tmp_885
     WHERE num_aviso_rec = p_num_ar_atu

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
      LET p_lanc_cont_cap.ies_ad_ap          = 1
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
FUNCTION pol0796_grava_aps()
#---------------------------#

   SELECT COUNT(cod_cnd_pgto)
     INTO p_qtd_parcelas
     FROM cond_pgto_item
    WHERE cod_cnd_pgto = p_nf_sup.cnd_pgto_nf

   IF p_qtd_parcelas IS NULL THEN
      RETURN FALSE
   END IF
  
   DECLARE cq_cnd_pagto CURSOR FOR
    SELECT qtd_dias_sd,
           pct_valor_liquido,
           pct_desc_financ
      FROM cond_pgto_item
     WHERE cod_cnd_pgto = p_nf_sup.cnd_pgto_nf
       
   LET p_num_parcela = 1
   LET p_val_gravado = 0
   
   FOREACH cq_cnd_pagto INTO 
           p_qtd_dias_sd,
           p_pct_valor_liquido

      IF p_num_parcela = p_qtd_parcelas THEN
         LET p_val_parcela = p_ad_mestre.val_tot_nf - p_val_gravado
      ELSE
         LET p_val_parcela  = 
             p_ad_mestre.val_tot_nf * p_pct_valor_liquido / 100
      END IF
      
      LET p_val_gravado = p_val_gravado + p_val_parcela    
      LET p_dat_vencto  = p_nf_sup.dat_emis_nf + p_qtd_dias_sd
      
      IF NOT pol0796_insere_ap() THEN
         RETURN FALSE
      END IF
      
      LET p_num_parcela = p_num_parcela + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION 

#---------------------------#
FUNCTION pol0796_insere_ap()
#---------------------------#

    IF NOT pol0796_le_par_ap() THEN 
       RETURN FALSE
    END IF

    LET p_ap.cod_empresa       = p_cod_emp_dest
    LET p_ap.num_ap            = p_num_ap
    LET p_ap.num_versao        = 1
    LET p_ap.ies_versao_atual  = 'S'
    LET p_ap.num_parcela       = p_num_parcela
    LET p_ap.cod_portador      = NULL
    LET p_ap.cod_bco_pagador   = NULL
    LET p_ap.num_conta_banc    = NULL
    LET p_ap.cod_fornecedor    = p_nf_sup.cod_fornecedor
    LET p_ap.cod_banco_for     = NULL
    LET p_ap.num_agencia_for   = NULL
    LET p_ap.num_conta_bco_for = NULL
    LET p_ap.num_nf            = p_nf_sup.num_nf
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
   
   LET p_cod_emp_atu = p_cod_emp_dest

   IF NOT pol0885_le_conta_cred() THEN
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
   LET p_msg = 'pol0796 - INCLUSAO DA AP No. ', p_msg CLIPPED
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


#------------------------------------#
FUNCTION pol0796_processa_nao_aparas()
#------------------------------------#

   IF NOT pol0796_exib_cabec() THEN
      RETURN FALSE
   END IF

   LET p_pct_umid_pad  = 0
   LET p_val_nota_ofic = 0
   LET p_val_nota_ger  = 0
   LET p_num_seqa = 0
   LET p_gerar = 'E'
   LET p_num_ar_atu = p_num_ar
   LET p_cod_emp_atu = p_cod_empresa
   LET p_qtd_fardos = 0

   DECLARE cq_nap CURSOR FOR
    SELECT num_transac,
           num_seq,
           dat_inclusao_seq,
           cod_item,
           num_conta,
           num_oc,
           num_pedido,
           cod_tip_despesa,
           cod_local,
           num_lote,
           qtd_lote,
           val_lote
      FROM mov_tmp_885
     WHERE ies_aparas = 'N'

   FOREACH cq_nap INTO 
           p_num_transac,
           p_num_seq,
           p_dat_inclusao_seq,
           p_cod_item,
           p_num_conta,
           p_num_oc,
           p_num_pedido,
           p_cod_tip_despesa,
           p_cod_local,
           p_num_lote,
           p_qtd_lote,
           p_val_lote   
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','mov_tmp_885')
         RETURN FALSE
      END IF

      IF p_num_oc IS NULL THEN
         LET p_fat_conversao = 1
      ELSE
         IF NOT pol0796_le_ordem_sup() THEN
            RETURN FALSE
         END IF
      END IF

      LET p_val_nota_ofic = p_val_nota_ofic + p_val_lote
      LET p_val_nota_ger  = p_val_nota_ger  + p_val_lote

      LET p_val_movto = 0
      LET p_pre_unit  = 0

      LET p_cod_operacao = p_cod_oper_cqv

      IF NOT pol0796_insere_estoque() THEN
         RETURN FALSE
      END IF
      
      LET p_pct_desc = 0
      
      IF p_num_pedido IS NOT NULL THEN
         SELECT a.pct_desc,
                b.cnd_pgto
           INTO p_pct_desc,
                p_nf_sup.cnd_pgto_nf
           FROM desc_ped_sup_885 a,
                pedido_sup_885   b
          WHERE b.cod_empresa = p_cod_empresa
            AND b.num_pedido  = p_num_pedido
            AND a.cod_empresa = b.cod_empresa
            AND a.cod_tipo    = b.cod_tipo
         
         IF STATUS = 100 THEN
            LET p_pct_desc = 0
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('Lendo','pedido_sup_885:cq_cop_mov')
               RETURN FALSE
            END IF
         END IF
      END IF
            
      IF p_pct_desc > 0 THEN
         
         LET p_qtd_lote  = 0
         LET p_val_movto = (p_val_lote * p_pct_desc) / (100 - p_pct_desc)
         LET p_pre_unit  = p_val_movto
   
         LET p_cod_operacao = p_cod_oper_cval
         
         IF NOT pol0796_insere_trans() THEN
            RETURN FALSE
         END IF

         LET p_val_nota_ger  = p_val_nota_ger + p_val_movto
         
         IF p_num_seqa <> p_num_seq THEN
            LET p_num_seqa = p_num_seq
            IF NOT pol0796_grava_tmp() THEN
               RETURN FALSE
            END IF
         END IF
         
      END IF

   END FOREACH

   IF p_val_nota_ger > p_val_nota_ofic THEN

      IF NOT pol0796_gera_ad() THEN
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE        

END FUNCTION

#---------------------------#
FUNCTION pol0796_grava_tmp()
#---------------------------#

   IF NOT pol0885_le_conta_deb() THEN
      RETURN FALSE
   END IF

   IF NOT pol0885_le_conta_cred() THEN
      RETURN FALSE
   END IF

   IF NOT pol0796_insere_tmp() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION
   
#------------------------------#
FUNCTION pol0885_le_conta_deb()
#------------------------------#

   SELECT num_conta_deb_desp
     INTO p_num_conta_deb
     FROM dest_aviso_rec
    WHERE cod_empresa   = p_cod_emp_atu
      AND num_aviso_rec = p_num_ar_atu
      AND num_seq       = p_num_seq
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','dest_aviso_rec')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------#
FUNCTION pol0885_le_conta_cred()
#-------------------------------#
   
   SELECT cod_grp_despesa,
          cod_hist_deb_ap
     INTO p_cod_grp_despesa,
          p_cod_hist_deb_ap
     FROM tipo_despesa
    WHERE cod_empresa     = p_cod_emp_atu
      AND cod_tip_despesa = p_cod_tip_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','tipo_despesa')
      RETURN FALSE
   END IF
    
   SELECT num_conta_fornec
     INTO p_num_conta_cred
     FROM grupo_despesa
    WHERE cod_empresa     = p_cod_emp_atu
      AND cod_grp_despesa = p_cod_grp_despesa

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','grupo_despesa')
      RETURN FALSE
   END IF
   
   RETURN TRUE        

END FUNCTION

#----------------------------#
FUNCTION pol0796_insere_tmp()
#----------------------------#

   INSERT INTO contas_tmp_885
    VALUES(p_num_ar_atu,
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
FUNCTION pol0796_insere_ar_proces()
#----------------------------------#
  
   LET p_dat_movto = TODAY
   
   INSERT INTO ar_proces_885
    VALUES(p_cod_empresa, 
           p_num_ar, 
           p_pct_umid_pad, 
           p_dat_movto,
           p_nf_sup.num_nf,
           p_nf_sup.cod_fornecedor)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERINDO","AR_PROCES_885")       
      RETURN FALSE
   END IF
   
   RETURN TRUE
    
END FUNCTION

#--------------------------------#
FUNCTION pol0796_update_na_zero()
#--------------------------------#
   
   LET p_num_docum = p_num_ar
   
   DECLARE cq_aviso_rec CURSOR FOR
    SELECT num_seq,
           cod_item
      FROM aviso_rec
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_ar
     ORDER BY num_seq
   
   FOREACH cq_aviso_rec INTO p_num_seq, p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo', 'cq_aviso')
         RETURN FALSE
      END IF
      
      DECLARE cq_trans CURSOR FOR
       SELECT num_transac
         FROM estoque_trans
        WHERE cod_empresa   = p_cod_empresa
          AND num_docum     = p_num_docum
          AND num_seq       = p_num_seq
          AND cod_item      = p_cod_item
          AND num_prog LIKE '%SUP%'
          AND num_transac   > 7000000
          ORDER BY num_transac
                             
      FOREACH cq_trans INTO p_num_transac
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","cq_trans")       
            RETURN FALSE
         END IF
         
        UPDATE estoque_trans
           SET dat_movto = p_dat_inclusao_seq
         WHERE cod_empresa = p_cod_empresa
           AND num_transac = p_num_transac
    
        IF STATUS <> 0 THEN
           CALL log003_err_sql('Atualisando', 'estoque_trans')
           RETURN FALSE
        END IF

        UPDATE estoque_trans_end
           SET dat_movto = p_dat_inclusao_seq
         WHERE cod_empresa = p_cod_empresa
           AND num_transac = p_num_transac
    
        IF STATUS <> 0 THEN
           CALL log003_err_sql('Atualisando', 'estoque_trans_end')
           RETURN FALSE
        END IF

      END FOREACH
      
   END FOREACH
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

