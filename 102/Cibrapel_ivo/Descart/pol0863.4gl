#-------------------------------------------------------------------#
#  SISTEMA..: CONTAS A RECEBER                                      #
#  PROGRAMA.: pol0863                                               #
#  OBJETIVO.: IMPRESSÃO DE DUPLICATAS                               #
#  CLIENTE..: MAX DEL                                               #
#  AUTOR....: Ana Paula                                             #
#  CRIAÇÃO..: 27/06/2008                                            #
#  ALTERADO.: 27/06/2008 por ANA PAULA                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa           LIKE empresa.cod_empresa,
          p_ies_tip_cliente       LIKE clientes_cre.ies_tip_cliente,
          p_dat_emis_docum        LIKE docum.dat_emis_docum,
          p_num_docum_orig        LIKE docum.num_docum_origem,
          p_val_fat               LIKE docum.val_fat,
          p_cod_nat_oper          LIKE nat_operacao.cod_nat_oper,
          p_cod_fiscal            LIKE nf_mestre.cod_fiscal,
          p_den_nat_oper          LIKE nat_operacao.den_nat_oper,
          p_cod_via_transporte    LIKE via_transporte.cod_via_transporte,
          p_den_via_transporte    LIKE via_transporte.den_via_transporte,
          p_user                  LIKE usuario.nom_usuario,
          p_dat_proces_doc        LIKE par_cre.dat_proces_doc,
          p_status                SMALLINT,
          comando                 CHAR(80),
          p_caminho               CHAR(80),
          p_nom_arquivo           CHAR(100),
          p_nom_arquivo1          CHAR(100),
          p_ies_impressao         CHAR(001),
          g_ies_ambiente          CHAR(01),
          p_versao                CHAR(18), 
          p_ies_ctr_cotacao       LIKE empresa_cre.ies_ctr_cotacao,
          p_cod_moeda_1           LIKE empresa_cre.cod_moeda_1,
          p_den_empresa           LIKE empresa.den_empresa,
          sql_order               CHAR(500),
          where_clause            CHAR(1000),
          var_query               CHAR(1300),
          sql_stmt                CHAR(2000),
          sql_query               CHAR(2000),
          p_nom_log               CHAR(14),
          p_qtd_rel               SMALLINT,
          p_comp_l1               SMALLINT,
          p_comp_l2               SMALLINT,
          p_comp_l3               SMALLINT,
          p_comp_l4               SMALLINT,
          p_lin1                  CHAR(200),
          p_lin2                  CHAR(200),
          p_lin3                  CHAR(200),
          p_lin4                  CHAR(200),
          p_houve_erro            SMALLINT,
          p_comprime              CHAR(01),
          p_descomprime           CHAR(01),
          p_8lpp                  CHAR(02),
          p_emi_duplicata         CHAR(03),
          p_selecionou            CHAR(03),
          p_listou_dupl           CHAR(03),
          p_mes_extenso           CHAR(09)
          #p_den_nat_oper          CHAR(30)

   DEFINE p_tela        RECORD
      num_docum         LIKE docum.num_docum
   END RECORD 


   DEFINE p_par_cre_txt      RECORD LIKE par_cre_txt.*

   DEFINE l_p_dados_doc      RECORD
          cod_empresa        LIKE  docum_emis.cod_empresa,
          cod_portador       LIKE  docum_emis.cod_portador ,
          ies_tip_portador   LIKE  docum_emis.ies_tip_portador,
          ies_tip_cobr       LIKE  docum_emis.ies_tip_cobr,
          ies_protesto_cli   LIKE  docum_emis.ies_protesto_cli,
          cod_emp_filial     LIKE  docum_emis.cod_emp_filial,
          num_docum          LIKE  docum_emis.num_docum,
          ies_tip_docum      LIKE  docum_emis.ies_tip_docum,
          dat_emis           LIKE  docum_emis.dat_emis,
          dat_vencto_c_desc  LIKE  docum_emis.dat_vencto_c_desc,
          pct_desc           LIKE  adocum.pct_desc,
          dat_vencto_s_desc  LIKE  docum_emis.dat_vencto_s_desc,
          val_bruto          LIKE  docum_emis.val_bruto,
          val_liquido        LIKE  docum_emis.val_liquido,
          num_docum_orig     LIKE  docum_emis.num_docum_orig,
          ies_tip_docum_orig LIKE  docum.ies_tip_docum,
          ies_serie_fat      LIKE  docum_emis.ies_serie_fat,
          val_fat            LIKE  docum_emis.val_fat,
          ies_cnd_bordero    LIKE  docum_emis.ies_cnd_bordero,
          cod_cnd_pgto       LIKE  docum_emis.cod_cnd_pgto,
          cod_cliente        LIKE  docum_emis.cod_cliente,
          nom_cliente        LIKE  docum_emis.nom_cliente,
          end_cliente        LIKE  docum_emis.end_cliente,
          den_bairro         LIKE  docum_emis.den_bairro,
          cod_cidade         LIKE  docum_emis.cod_cidade,
          cod_cep            LIKE  docum_emis.cod_cep,
          end_cliente_cob    LIKE  docum_emis.end_cliente_cob,
          den_bairro_cob     LIKE  docum_emis.den_bairro_cob,
          cod_cidade_cob     LIKE  docum_emis.cod_cidade_cob,
          cod_cep_cob        LIKE  docum_emis.cod_cep_cob,
          num_cgc_cpf        LIKE  docum_emis.num_cgc_cpf,
          ins_estadual       LIKE  docum_emis.ins_estadual,
          cod_deb_cred_cl    DECIMAL(2,0),
          val_desc_dia       LIKE  docum_emis.val_desc_dia,
          ies_impressao      LIKE  docum_emis.ies_impressao,
          num_telex_cli      LIKE  clientes.num_telex,
          num_fax_cli        LIKE  clientes.num_fax,
          tex_obs            LIKE  clientes_cre.tex_obs,
          num_conta          LIKE  clientes_cre.num_conta,
          num_agencia        LIKE  clientes_cre.num_agencia, 
          cod_empresa_emp    LIKE  empresa.cod_empresa,
          den_empresa        LIKE  empresa.den_empresa,
          den_reduz          LIKE  empresa.den_reduz,
          end_empresa        LIKE  empresa.end_empresa,
          den_bairro_emp     LIKE  empresa.den_bairro,
          den_munic          LIKE  empresa.den_munic,
          uni_feder          LIKE  empresa.uni_feder,
          ins_estadual_emp   LIKE  empresa.ins_estadual,
          num_cgc            LIKE  empresa.num_cgc,
          num_caixa_postal   LIKE  empresa.num_caixa_postal,
          cod_cep_emp        LIKE  empresa.cod_cep,
          num_telefone       LIKE  empresa.num_telefone,
          num_telex          LIKE  empresa.num_telex,
          num_fax            LIKE  empresa.num_fax,
          end_telegraf       LIKE  empresa.end_telegraf,
          num_reg_junta      LIKE  empresa.num_reg_junta,
          dat_inclu_junta    LIKE  empresa.dat_inclu_junta,
          ies_filial         LIKE  empresa.ies_filial,
          dat_fundacao       LIKE  empresa.dat_fundacao,
          cod_cliente_emp    LIKE  empresa.cod_cliente,
          den_cidade_cliente LIKE  cidades.den_cidade,
          uni_feder_cliente  LIKE  cidades.cod_uni_feder,
          den_cidade_cob     LIKE  cidades.den_cidade,
          uni_feder_cob      LIKE  cidades.cod_uni_feder,
          ies_impr_descr     LIKE  cond_pgto_cre.ies_imprime_descr, 
          des_cnd_pgto       LIKE  cond_pgto_cre.des_abrev_cnd_pgto,
          num_pedido         LIKE  docum.num_pedido, 
          cod_repres_1       LIKE  docum.cod_repres_1, 
          des_valor_1        CHAR(70),
          des_valor_2        CHAR(70),
          ies_cotacao        CHAR(03)  
    END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0863-05.10.06" 
   WHENEVER ERROR CONTINUE
   SET ISOLATION TO DIRTY READ
   WHENEVER ERROR STOP
   DEFER INTERRUPT
   CALL log140_procura_caminho("pol.iem") RETURNING comando
   OPTIONS
      FIELD ORDER UNCONSTRAINED,
      HELP FILE comando,
      INSERT KEY CONTROL-I,
      DELETE KEY CONTROL-E
    

   CALL log001_acessa_usuario("CRECEBER","LIC_LIB")
          RETURNING p_status,p_cod_empresa,p_user

   IF p_status = 0 THEN 
      SELECT * 
        INTO p_par_cre_txt.*
        FROM par_cre_txt
       CALL pol0863_controle()
   END IF
END MAIN

#--------------------------------------#
 FUNCTION pol0863_controle()
#--------------------------------------#
  DEFINE i        SMALLINT,
         p_resp   CHAR(01)

  INITIALIZE i, p_resp  TO NULL

  LET p_selecionou    = "NAO" 
  LET p_listou_dupl   = "NAO"
  LET p_qtd_rel       = 0

  INITIALIZE p_nom_log TO NULL
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE comando TO NULL 
  CALL log130_procura_caminho("pol0863") RETURNING comando    
  OPEN WINDOW w_pol0863 AT 2,2 WITH FORM comando
         ATTRIBUTE (BORDER,MESSAGE LINE LAST , PROMPT LINE LAST )
  DISPLAY p_cod_empresa TO cod_empresa

  MENU "OPCAO"
      COMMAND  "Lista duplicata" "Imprime as duplicatas" HELP 1
         MESSAGE " "
         IF log005_seguranca(p_user,"CRECEBER","pol0863","CO") THEN
             IF  pol0863_informar() = FALSE
                 THEN NEXT OPTION "Fim"
             END IF
             IF p_selecionou = "SIM" THEN
                CALL pol0863_listar()
                LET p_listou_dupl = "SIM"
                NEXT OPTION "Fim"
             ELSE 
                MESSAGE " Selecione Duplicatas Primeiro para depois Listar" ATTRIBUTE(REVERSE)
                NEXT OPTION "Lista duplicata"
             END IF
         END IF
      COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR  comando
         RUN comando
         PROMPT "\n Tecle ENTER para Continuar" FOR CHAR comando
         LET int_flag = 0
      COMMAND "Fim" "Retorna ao Menu Anterior" HELP 3
          IF p_emi_duplicata = "SIM" THEN 
             PROMPT "Duplicatas Emitidas Corretamente (S/N) ? : " FOR p_resp
             IF p_resp = "S" OR p_resp = "s" THEN
                IF l_p_dados_doc.ies_impressao = 'N' THEN 
                   CALL log085_transacao("BEGIN")
                   IF pol0863_atualiza_docum_emis() = FALSE THEN
                      CALL log085_transacao("ROLLBACK")
                      NEXT OPTION "Fim"
                   ELSE 
                      CALL log085_transacao("COMMIT")
                      EXIT MENU
                   END IF
                ELSE
                   EXIT MENU
                END IF    
             ELSE 
                NEXT OPTION  "Lista duplicata" 
             END IF
          ELSE
             EXIT MENU
          END IF
    END MENU
    CLOSE WINDOW w_pol0863
 END FUNCTION

#--------------------------#
 FUNCTION pol0863_informar() 
#--------------------------#
   INITIALIZE p_tela TO NULL
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET INT_FLAG = FALSE

   INPUT BY NAME p_tela.*
      WITHOUT DEFAULTS

      AFTER FIELD num_docum   
      IF p_tela.num_docum IS NULL THEN
         ERROR "Campo de Preenchimento Obrigatorio"
         NEXT FIELD num_docum
      END IF 

      CALL pol0863_pesquisa_par_cre()
      CALL pol0863_mes_extenso()
      CALL pol0863_selecionar_todas()
      LET p_selecionou = "SIM"
      LET int_flag = 0
      
   END INPUT

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol0863_selecionar_todas()
#----------------------------------#
 INITIALIZE sql_stmt, sql_order, sql_query TO NULL

  LET sql_stmt = "SELECT docum_emis.*, clientes.num_telex, ",
                 "clientes.num_fax, clientes_cre.tex_obs, ",
                 "clientes_cre.num_conta, clientes_cre.num_agencia, ", 
                 "empresa.*, a.den_cidade, a.cod_uni_feder, ",
                 "a.den_cidade, a.cod_uni_feder, ",
                 "cond_pgto_cre.ies_imprime_descr, ",
                 "cond_pgto_cre.des_abrev_cnd_pgto ",
                 "FROM  docum_emis, clientes, OUTER clientes_cre, empresa, ",
                 " cidades a, cond_pgto_cre ",
                 "WHERE docum_emis.ies_tip_docum = 'DP' ",
                 "AND docum_emis.cod_empresa     = '",p_cod_empresa,"'",  
                 "AND docum_emis.num_docum       = '",p_tela.num_docum,"'",  
                 "AND empresa.cod_empresa        = docum_emis.cod_empresa ",
                 "AND a.cod_cidade               = docum_emis.cod_cidade ",
                 "AND cond_pgto_cre.cod_cnd_pgto = docum_emis.cod_cnd_pgto ",
                 "AND clientes.cod_cliente       = docum_emis.cod_cliente ",
                 "AND clientes_cre.cod_cliente   = docum_emis.cod_cliente "

 LET sql_order = " ORDER BY docum_emis.cod_empresa, ",
                 "docum_emis.cod_portador, docum_emis.ies_tip_portador, ",
                 "docum_emis.ies_tip_cobr, docum_emis.num_docum"

 LET sql_query = sql_stmt CLIPPED, sql_order CLIPPED
 
END FUNCTION

#------------------------#
 FUNCTION pol0863_listar()
#------------------------#

  DEFINE p_count       SMALLINT
  INITIALIZE p_count TO NULL

  LET p_comprime     = ascii 15
  LET p_descomprime  = ascii 18
  LET p_8lpp         = ascii 27, "0"

  IF log028_saida_relat(11,15) IS NULL THEN
     RETURN
  END IF

  LET p_qtd_rel = p_qtd_rel + 1
  
  MESSAGE "Processando a Impressão das Duplicatas..." ATTRIBUTE(REVERSE)
  
  IF g_ies_ambiente = "W"   THEN 
     IF p_ies_impressao = "S"  THEN 
        CALL log150_procura_caminho('LST') RETURNING p_caminho
        LET p_caminho = p_caminho CLIPPED, 'cre9680.tmp'
        START REPORT pol0863_relat TO p_caminho
     ELSE 
        LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
        START REPORT pol0863_relat TO p_nom_arquivo1
     END IF
  ELSE
     IF p_ies_impressao = "S" THEN
        START REPORT pol0863_relat TO PIPE p_nom_arquivo
     ELSE 
        LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
        START REPORT pol0863_relat TO p_nom_arquivo1
     END IF
  END IF
  LET p_emi_duplicata = "NAO"
  LET p_houve_erro    = FALSE

  PREPARE var_query FROM sql_query
  DECLARE cl_dados_doc CURSOR WITH HOLD FOR var_query
  LET p_count = 0

  FOREACH cl_dados_doc INTO l_p_dados_doc.*

     IF p_par_cre_txt.parametro[102] = "2" THEN
        SELECT parametro[1,6]
          INTO l_p_dados_doc.pct_desc
          FROM docum_txt
         WHERE cod_empresa   = l_p_dados_doc.cod_empresa
           AND num_docum     = l_p_dados_doc.num_docum
           AND ies_tip_docum = l_p_dados_doc.ies_tip_docum 
     END IF

     SELECT num_pedido,
            cod_repres_1
       INTO l_p_dados_doc.num_pedido,
            l_p_dados_doc.cod_repres_1
       FROM docum
      WHERE docum.cod_empresa   = l_p_dados_doc.cod_empresa
        AND docum.ies_tip_docum = l_p_dados_doc.ies_tip_docum
        AND docum.num_docum     = l_p_dados_doc.num_docum

     IF SQLCA.sqlcode <> 0 THEN
        LET l_p_dados_doc.num_pedido   = " "
        LET l_p_dados_doc.cod_repres_1 = 0 
     END IF

     IF l_p_dados_doc.cod_cidade_cob = "     " OR  
        l_p_dados_doc.cod_cidade_cob IS NULL THEN 
        INITIALIZE l_p_dados_doc.den_cidade_cob TO NULL
     ELSE   
        SELECT den_cidade
          INTO l_p_dados_doc.den_cidade_cob
          FROM cidades
         WHERE cod_cidade =  l_p_dados_doc.cod_cidade_cob
     END IF    
    
     SELECT ies_tip_cliente  
       INTO p_ies_tip_cliente  
       FROM clientes_cre
      WHERE cod_cliente = l_p_dados_doc.cod_cliente

     IF SQLCA.sqlcode <> 0 THEN 
        LET p_ies_tip_cliente = "O"
     END IF

     IF p_ies_tip_cliente = "N" THEN
        CONTINUE FOREACH
     END IF

     LET p_count = p_count + 1

     CALL pol0863_verifica_docum_emis_cot()
     CALL pol0863_extenso() 

     OUTPUT TO REPORT pol0863_relat()

     LET p_emi_duplicata = "SIM"
     LET p_listou_dupl   = "SIM"

      UPDATE docum 
         SET dat_emis_docum     = p_dat_proces_doc,
             num_lote_remessa   = 0
      WHERE docum.cod_empresa   = l_p_dados_doc.cod_empresa
        AND docum.num_docum     = l_p_dados_doc.num_docum
        AND docum.ies_tip_docum = l_p_dados_doc.ies_tip_docum

      IF sqlca.sqlcode <> 0 THEN
         CALL log003_err_sql("ALTERACAO","DOCUM")
         SLEEP 3
         LET p_listou_dupl = "NAO"
         RETURN
      END IF  

   END FOREACH  

   FINISH REPORT pol0863_relat

   IF p_count = 0 THEN
      MESSAGE "Nao Existem Duplicatas a Serem Listadas" ATTRIBUTE(REVERSE)
      RETURN
   END IF

   ERROR "Fim de Processamento..." 

   IF p_ies_impressao = "S" THEN 
      MESSAGE "Impressao do Relatorio Concluida ", " " ATTRIBUTE(REVERSE)
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando 
      END IF
   ELSE  
      MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo1, " " 
                      ATTRIBUTE(REVERSE)
   END IF

END FUNCTION

#-----------------------------------------#
 FUNCTION pol0863_verifica_docum_emis_cot()
#-----------------------------------------#

 INITIALIZE p_ies_ctr_cotacao, p_cod_moeda_1 TO NULL

 SELECT ies_ctr_cotacao, cod_moeda_1  
   INTO p_ies_ctr_cotacao, p_cod_moeda_1
   FROM empresa_cre
  WHERE empresa_cre.cod_empresa = l_p_dados_doc.cod_empresa 

 IF sqlca.sqlcode = 0 THEN 
    IF p_ies_ctr_cotacao = "S" THEN 
       IF cre053_busca_docum_emis_cotacao() THEN 
       ELSE 
          LET p_ies_ctr_cotacao = "N"
       END IF
    END IF
 ELSE 
    LET p_ies_ctr_cotacao = "N"
 END IF
 
 CALL pol0863_busca_val_origem()
 
END FUNCTION

#------------------------------------------#
 FUNCTION cre053_busca_docum_emis_cotacao()
#------------------------------------------#
 
 SELECT val_bruto, val_fat
   INTO l_p_dados_doc.val_bruto, l_p_dados_doc.val_fat
   FROM docum_emis_cotacao
  WHERE docum_emis_cotacao.cod_empresa   = l_p_dados_doc.cod_empresa
    AND docum_emis_cotacao.num_docum     = l_p_dados_doc.num_docum
    AND docum_emis_cotacao.ies_tip_docum = l_p_dados_doc.ies_tip_docum
    AND docum_emis_cotacao.cod_cotacao   = p_cod_moeda_1
 
  IF SQLCA.sqlcode = 0 THEN
     LET l_p_dados_doc.ies_cotacao = "URV"
     RETURN TRUE
  ELSE
     LET l_p_dados_doc.ies_cotacao = "CR$"
     RETURN FALSE
  END IF
 
END FUNCTION

#------------------------------------#
 FUNCTION pol0863_busca_val_origem()
#------------------------------------#

  SELECT val_bruto, val_fat, nom_log
    INTO l_p_dados_doc.val_bruto, l_p_dados_doc.val_fat, p_nom_log
    FROM val_origem
   WHERE val_origem.cod_empresa   = l_p_dados_doc.cod_empresa
     AND val_origem.num_docum     = l_p_dados_doc.num_docum
     AND val_origem.ies_tip_docum = l_p_dados_doc.ies_tip_docum

  IF sqlca.sqlcode = 100 THEN
     LET p_nom_log = "log038_extenso"
  END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0863_extenso()
#--------------------------#
   INITIALIZE p_lin1, p_lin2, p_lin3, p_lin4 TO NULL
    
   LET p_comp_l1 = 100
   LET p_comp_l2 = 100
   LET p_comp_l3 = 100
   LET p_comp_l4 = 100

   IF p_nom_log = "log038_extenso"  THEN
      CALL log038_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF

   IF p_nom_log = "log036_extenso"  THEN
      CALL log036_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF

   IF p_nom_log = "log033_extenso"  THEN
      CALL log033_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
           RETURNING p_lin1, p_lin2, p_lin3, p_lin4
   END IF  

END FUNCTION

#----------------------------------#
 FUNCTION pol0863_pesquisa_par_cre()
#----------------------------------#

   INITIALIZE p_dat_proces_doc TO NULL
   SELECT par_cre.dat_proces_doc
     INTO p_dat_proces_doc
     FROM par_cre

END FUNCTION

#-----------------------------#
 FUNCTION pol0863_mes_extenso()
#-----------------------------#

CASE MONTH(p_dat_proces_doc)
   WHEN 1
       LET p_mes_extenso = "JANEIRO"
   WHEN 2
       LET p_mes_extenso = "FEVEREIRO"
   WHEN 3
       LET p_mes_extenso = "MARCO"
   WHEN 4
       LET p_mes_extenso = "ABRIL"
   WHEN 5
       LET p_mes_extenso = "MAIO"
   WHEN 6
       LET p_mes_extenso = "JUNHO"
   WHEN 7
       LET p_mes_extenso = "JULHO"
   WHEN 8
       LET p_mes_extenso = "AGOSTO"
   WHEN 9
       LET p_mes_extenso = "SETEMBRO"
   WHEN 10
       LET p_mes_extenso = "OUTUBRO"
   WHEN 11
       LET p_mes_extenso = "NOVEMBRO"
   WHEN 12
       LET p_mes_extenso = "DEZEMBRO"
  END CASE
END FUNCTION

#--------------------------------------#
 FUNCTION pol0863_atualiza_docum_emis()
#--------------------------------------#

 WHENEVER ERROR CONTINUE

 LET p_houve_erro = FALSE

 FOREACH cl_dados_doc INTO l_p_dados_doc.*
 
    UPDATE docum_emis SET ies_impressao = "S"
     WHERE cod_empresa      = l_p_dados_doc.cod_empresa
       AND cod_portador     = l_p_dados_doc.cod_portador
       AND ies_tip_portador = l_p_dados_doc.ies_tip_portador
       AND ies_tip_cobr     = l_p_dados_doc.ies_tip_cobr
       AND ies_protesto_cli = l_p_dados_doc.ies_protesto_cli
       AND cod_emp_filial   = l_p_dados_doc.cod_emp_filial
       AND num_docum        = l_p_dados_doc.num_docum
       AND ies_tip_docum    = l_p_dados_doc.ies_tip_docum 

    IF sqlca.sqlcode <> 0 THEN
       CALL log003_err_sql("ATUALIZACAO", "DOCUM_EMIS")
       LET p_houve_erro = TRUE 
       EXIT FOREACH
    END IF
 
 END FOREACH  
 
 WHENEVER ERROR STOP 
 
 IF p_houve_erro = FALSE THEN 
    RETURN TRUE
 ELSE 
    RETURN FALSE
 END IF
 
END FUNCTION

#------------------------#
 REPORT pol0863_relat()
#------------------------#

 DEFINE  p_num                     SMALLINT ,
         p_last_row                SMALLINT

 OUTPUT  LEFT MARGIN 0
         TOP MARGIN 0
         BOTTOM MARGIN 1
         PAGE LENGTH 36

 FORMAT

  ON EVERY ROW 

   IF l_p_dados_doc.num_pedido IS NULL OR 
      l_p_dados_doc.num_pedido = " "  THEN
      LET p_cod_fiscal = '6101'
      LET p_den_nat_oper = 'VENDA '
   ELSE    
      SELECT dat_emissao,
             val_tot_nff,
             cod_nat_oper,
             cod_fiscal
        INTO p_dat_emis_docum,
             p_val_fat,
             p_cod_nat_oper,
             p_cod_fiscal 
        FROM nf_mestre
       WHERE cod_empresa = p_cod_empresa
         AND num_nff     = l_p_dados_doc.num_docum_orig
      
      IF SQLCA.sqlcode <> 0 THEN 
         LET p_cod_fiscal = '6101'
         LET p_den_nat_oper = 'VENDA '
      ELSE 
         SELECT den_nat_oper
           INTO p_den_nat_oper
           FROM nat_operacao
          WHERE cod_nat_oper = p_cod_nat_oper
      END IF 
   END IF 
    
   SKIP 6 LINES
   PRINT p_comprime
   PRINT COLUMN 001, p_den_nat_oper,
         COLUMN 017, p_cod_fiscal
   SKIP 2 LINES            
   PRINT COLUMN 001, l_p_dados_doc.nom_cliente, 
         COLUMN 090, l_p_dados_doc.num_cgc_cpf
   SKIP 1 LINES
   PRINT COLUMN 001, l_p_dados_doc.end_cliente[1,32],
         COLUMN 062, l_p_dados_doc.den_bairro[1,12],
         COLUMN 090, l_p_dados_doc.cod_cep
   SKIP 1 LINES
   PRINT COLUMN 001, l_p_dados_doc.den_cidade_cliente,
         COLUMN 042, l_p_dados_doc.num_telefone,
         COLUMN 062, l_p_dados_doc.uni_feder_cliente,
         COLUMN 090, l_p_dados_doc.ins_estadual
   SKIP 2 LINES      
   PRINT COLUMN 001, l_p_dados_doc.dat_emis USING "DD/MM/YYYY",
         COLUMN 020, l_p_dados_doc.num_docum_orig,
         COLUMN 035, l_p_dados_doc.val_bruto USING "######,##&.&&",
         COLUMN 069, l_p_dados_doc.num_docum,
         COLUMN 090, l_p_dados_doc.dat_vencto_s_desc USING "DD/MM/YYYY"
   SKIP 4 LINES
   IF l_p_dados_doc.end_cliente_cob IS NOT NULL THEN 
      PRINT COLUMN 001, l_p_dados_doc.end_cliente_cob[1,32],
            COLUMN 035, l_p_dados_doc.den_bairro_cob[1,12],
            COLUMN 051, l_p_dados_doc.cod_cep_cob,
            COLUMN 072, l_p_dados_doc.den_cidade_cob[1,20]
   ELSE
      PRINT
   END IF
   PRINT COLUMN 001, p_lin1[1,100]
#   PRINT COLUMN 005, p_lin2[1,100]
#   PRINT COLUMN 005, p_lin3[1,100]
   SKIP TO TOP OF PAGE

END REPORT 

# -------------------- FIM DE PROGRAMA --------------------#