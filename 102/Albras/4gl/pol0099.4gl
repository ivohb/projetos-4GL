#-------------------------------------------------------------------#
#  SISTEMA..: CONTAS A RECEBER                                      #
#  PROGRAMA.: POL0099                                               #
#  MODULOS..: POL0099 LOG0010                                       #
#  OBJETIVO.: LISTA DUPLICATAS                                      #
#  CLIENTE..: ALBRAS                                                #
#  DATA.....: 26/06/2000                                            #
#-------------------------------------------------------------------#

DATABASE logix
GLOBALS
   DEFINE p_cod_empresa                  LIKE  empresa.cod_empresa,
          p_cod_portador                 LIKE  portador.cod_portador,
          p_ies_tip_portador             LIKE  portador.ies_tip_portador,
          p_ies_tip_cliente              LIKE  clientes_cre.ies_tip_cliente,
          p_msg                          CHAR(100),
          p_ies_quebra                   SMALLINT,
          p_qtd_dup                      SMALLINT,
          p_ies_imp                      SMALLINT,
          p_user                         LIKE  usuario.nom_usuario,
          p_dat_proces_doc               LIKE  par_cre.dat_proces_doc,
          p_status                       SMALLINT,
          comando                        CHAR(80),
          p_caminho                      CHAR(80),
          p_caminho2                     CHAR(80),
          p_caminho3                     CHAR(80),
          p_caminho4                     CHAR(80),
          p_nom_arquivo                  CHAR(100),
          p_nom_arquivo1                 CHAR(100),
          p_ies_impressao                CHAR(001),
          p_ies_ctr_cotacao              LIKE empresa_cre.ies_ctr_cotacao,
          p_cod_moeda_1                  LIKE empresa_cre.cod_moeda_1,
          p_den_empresa                  LIKE empresa.den_empresa,
          p_par_cre_txt                  RECORD LIKE par_cre_txt.*,
          p_ies_relat                    SMALLINT,
          p_ies_todos                    SMALLINT,
          p_tip_cobr                     CHAR(10),
          sql_order                      CHAR(500),
          where_clause                   CHAR(1000),
          var_query                      CHAR(1300),
          var_query2                     CHAR(1300),
          sql_stmt                       CHAR(2000),
          sql_query                      CHAR(2000),
          p_nom_log                      CHAR(14)

   DEFINE p_comprime, p_descomprime  CHAR(01),
          p_8lpp                     CHAR(02)


   DEFINE p_docum_emis                   RECORD LIKE docum_emis.*,
          p_empresas                     ARRAY[50] OF RECORD
                             cod_empresa LIKE empresa.cod_empresa
                                         END RECORD,
          p_portadores                   ARRAY[50] OF RECORD
                        ies_tip_portador LIKE docum.ies_tip_portador,
                        cod_portador     LIKE docum.cod_portador
                                         END RECORD,
          pa_curr,
          sc_curr,
          p_cont,
          p_qtd_rel,
          p_cont_erros                   SMALLINT
  { variaveis criadas por alexandre } 
  DEFINE  p_emi_duplicata          CHAR(03), { para deletar no docum_emis} 
          p_emi_cartas             CHAR(03), { para deletar no docum_emis} 
          p_selecionou             CHAR(03),
          p_listou_dupl            CHAR(03), { para listar borderos } 
          p_mes_extenso            CHAR(09),
          p_val_tot_ban            DECIMAL(21,2),
          p_qtd_tot_ban            SMALLINT ,      
          p_val_tot_rep            DECIMAL(21,2),  
          p_qtd_tot_rep            SMALLINT ,
          p_ind                    SMALLINT,
          p_texto      ARRAY[10] OF RECORD
                           des_linha  LIKE par_rel_cre_tex.des_linha
                        END RECORD  
  DEFINE  l_p_dados_doc RECORD
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
                     END RECORD,
        p_num_prog_dupl             CHAR(16),
        p_listou_bord_b             CHAR(03),
        p_listou_bord_r             CHAR(03)

    DEFINE      { variaveis para o log038 valor por extenso } 
           p_comp_l1              SMALLINT,
           p_comp_l2              SMALLINT,
           p_comp_l3              SMALLINT,
           p_comp_l4              SMALLINT,
           p_lin1                 CHAR(200),
           p_lin2                 CHAR(200),
           p_lin3                 CHAR(200),
           p_lin4                 CHAR(200)
     DEFINE p_houve_erro          SMALLINT  ,
            p_empresa_cre_txt     RECORD LIKE empresa_cre_txt.*
 DEFINE  g_ies_ambiente  CHAR(01)
#DEFINE  p_versao  CHAR(17) #Favor Nao Alterar esta linha (SUPORTE)
 DEFINE  p_versao  CHAR(18) #Favor Nao Alterar esta linha (SUPORTE)
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   LET p_versao = "POL0099-05.10.02" #Favor nao alterar esta linha (SUPORTE)
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
   INITIALIZE p_cod_empresa,p_cod_portador,p_ies_tip_portador,p_user,p_dat_proces_doc TO NULL
   INITIALIZE p_status,comando,p_nom_arquivo TO NULL
   INITIALIZE p_den_empresa,p_ies_relat,p_ies_todos,p_tip_cobr,sql_order TO NULL    
   INITIALIZE where_clause,sql_stmt,sql_query,pa_curr, sc_curr,p_cont TO NULL           
   INITIALIZE p_qtd_rel, p_cont_erros,p_emi_duplicata,p_selecionou,p_listou_dupl,  
              p_mes_extenso,p_val_tot_ban,p_qtd_tot_ban,p_val_tot_rep TO NULL
   INITIALIZE p_qtd_tot_rep,p_ind,p_num_prog_dupl,p_listou_bord_b,p_listou_bord_r,         
              p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4,p_lin1,p_lin2   TO NULL             
   INITIALIZE p_lin3,p_lin4,p_houve_erro, p_ies_tip_cliente TO NULL
   INITIALIZE p_docum_emis.* TO NULL
   INITIALIZE l_p_dados_doc.* TO NULL
   INITIALIZE p_emi_duplicata, p_ies_quebra,p_ies_imp, p_qtd_dup TO NULL
#  CALL log001_acessa_usuario("CRECEBER")
   CALL log001_acessa_usuario("CRECEBER","LIC_LIB")
          RETURNING p_status,p_cod_empresa,p_user
   IF p_status = 0
         THEN SELECT * 
                INTO p_par_cre_txt.*
                FROM par_cre_txt
              CALL cre162_controle()
   END IF
END MAIN

#--------------------------------------#
 FUNCTION cre162_controle()
#--------------------------------------#
  DEFINE i        SMALLINT,
         p_resp   CHAR(01)

  INITIALIZE i, p_resp  TO NULL
  INITIALIZE p_empresas TO NULL
  INITIALIZE p_portadores TO NULL
  INITIALIZE p_texto TO NULL

  LET p_selecionou    = "NAO" 
  LET p_listou_dupl   = "NAO"
  LET p_listou_bord_b = "NAO"
  LET p_listou_bord_r = "NAO"
  LET p_qtd_rel       = 0

  INITIALIZE p_num_prog_dupl , p_nom_log TO NULL
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE comando TO NULL 
  CALL log130_procura_caminho("pol00991") RETURNING comando    
  OPEN WINDOW w_pol00991 AT 6,2 WITH FORM comando
         ATTRIBUTE (BORDER,MESSAGE LINE LAST , PROMPT LINE LAST )
  MENU "OPCAO"
      COMMAND  "Lista duplicata" "Listar as duplicatas selecionadas" HELP 1
         MESSAGE " "
         IF log005_seguranca(p_user,"CRECEBER","POL0099","CO") THEN
             IF  cre162_informar() = FALSE
             THEN NEXT OPTION "Fim"
             END IF
             IF p_selecionou = "SIM"
             THEN CALL cre162_listar()
                  LET p_listou_dupl = "SIM"
                  NEXT OPTION "Fim"
             ELSE MESSAGE " Selecione duplicatas primeiro para depois listar." ATTRIBUTE(REVERSE)
                  NEXT OPTION "Lista duplicata"
             END IF
         END IF
###   COMMAND  "lista Cartas" "Listar cartas para clientes especiais" HELP 1
###      MESSAGE " "
###      IF log005_seguranca(p_user,"CRECEBER","POL0099","CO") THEN
###          IF p_selecionou = "SIM"
###          THEN CALL cre162_cartas()
###               LET p_listou_dupl = "SIM"
###               NEXT OPTION "lista bordero Banco"
###          ELSE MESSAGE " Selecione duplicatas primeiro para depois listar." ATTRIBUTE(REVERSE)
###              NEXT OPTION "Lista duplicata"
###         END IF
###      END IF
###   COMMAND KEY("B") "lista bordero Banco" "Lista os borderos das duplicatas selecionadas." HELP 1
###      MESSAGE " "
###      IF  p_listou_dupl = "SIM" 
###      THEN  CALL cre162_emite_bord_banco()
###            NEXT OPTION "FIM"
###      ELSE  MESSAGE " Liste primeiro as duplicatas para depois listar bordero" ATTRIBUTE(REVERSE) 
###            NEXT OPTION "Lista duplicata"
###      END IF
####  COMMAND KEY("R")  "lista bordero Representante" "Lista os borderos das duplicatas selecionadas." HELP 1
####     MESSAGE " "
####     IF  p_listou_dupl = "SIM" 
####     THEN  CALL cre162_emite_bord_repres()
####           NEXT OPTION "Fim"
####     ELSE  MESSAGE " Liste primeiro as duplicatas para depois listar bordero" ATTRIBUTE (REVERSE) 
####           NEXT OPTION "Lista duplicata"
####     END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0099_sobre() 
       COMMAND KEY("!")
         PROMPT "Digite o comando : " FOR  comando
         RUN comando
         PROMPT "\n Tecle ENTER para continuar" FOR CHAR comando
         LET int_flag = 0
       COMMAND "Fim" "Retorna ao Menu Anterior." HELP 3
        IF   p_emi_duplicata = "SIM"
             THEN PROMPT "Duplicatas emitidas corretamente (S/N) ? : "
                  FOR p_resp
                  IF   p_resp = "S" 
                  OR  	p_resp = "s"
                  THEN IF   cre162_atualiza_docum_emis() = FALSE
                       THEN CALL log085_transacao("ROLLBACK")
                            NEXT OPTION "Fim"
                       ELSE CALL log085_transacao("COMMIT")
                            EXIT MENU
                       END IF
                  ELSE NEXT OPTION  "Lista duplicata" 
                  END IF
        ELSE EXIT MENU
        END IF
    END MENU
    CLOSE WINDOW w_pol00991
 END FUNCTION

#-----------------------#
FUNCTION pol0099_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#--------------------------#
 FUNCTION cre162_informar() 
#--------------------------#
         CALL cre162_pesquisa_par_cre()
         CALL cre162_mes_extenso()
         CALL  cre162_selecionar_todas()
         LET p_selecionou = "SIM"
         LET int_flag = 0
 RETURN TRUE
END FUNCTION

#----------------------------------#
 FUNCTION cre162_selecionar_todas()
#----------------------------------#
 INITIALIZE sql_stmt, sql_order, sql_query TO NULL

  LET sql_stmt = "SELECT docum_emis.*, clientes.num_telex, ",
                 "clientes.num_fax, clientes_cre.tex_obs, ",
                 "clientes_cre.num_conta, clientes_cre.num_agencia, ", 
                 "empresa.*, a.den_cidade, a.cod_uni_feder, ",
                 "b.den_cidade, b.cod_uni_feder, ",
                 "cond_pgto_cre.ies_imprime_descr, ",
                 "cond_pgto_cre.des_abrev_cnd_pgto ",
                 "FROM  docum_emis,  clientes, OUTER clientes_cre, empresa, ",
                 "cidades  a,  OUTER cidades b, cond_pgto_cre ",
                 "WHERE docum_emis.ies_tip_docum = ""DP"" ",
                 "AND docum_emis.ies_impressao   = ""N"" ",  
            #    "AND docum_emis.cod_empresa     = ""01"" ",  
                 "AND docum_emis.cod_empresa     = '",p_cod_empresa,"' ",  
                 "AND empresa.cod_empresa        = docum_emis.cod_empresa ",
                 "AND a.cod_cidade               = docum_emis.cod_cidade ",
                 "AND b.cod_cidade               = docum_emis.cod_cidade_cob ",
                 "AND cond_pgto_cre.cod_cnd_pgto = docum_emis.cod_cnd_pgto ",
                 "AND clientes.cod_cliente       = docum_emis.cod_cliente ",
                 "AND clientes_cre.cod_cliente   = docum_emis.cod_cliente "
 LET sql_order = " ORDER BY docum_emis.cod_empresa, ",
                 "docum_emis.cod_portador, docum_emis.ies_tip_portador, ",
                 "docum_emis.ies_tip_cobr, docum_emis.num_docum"

 LET sql_query = sql_stmt CLIPPED, sql_order CLIPPED
END FUNCTION

#------------------------#
 FUNCTION cre162_listar()
#------------------------#
  DEFINE p_count       SMALLINT
  INITIALIZE p_count TO NULL

  LET p_comprime     = ascii 15
  LET p_descomprime  = ascii 18
  LET p_8lpp         = ascii 27, "0"

  IF   p_qtd_rel = 0 
  THEN IF   log028_saida_relat(15,37) IS NULL 
       THEN RETURN
       END IF
  END IF
  LET p_qtd_rel = p_qtd_rel + 1
  MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
  IF   g_ies_ambiente = "W"   THEN 
       IF   p_ies_impressao = "S"  THEN 
            CALL log150_procura_caminho('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'cre9680.tmp'
            START REPORT cre162_relat TO p_caminho
       ELSE 
            LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_relat TO p_nom_arquivo1
       END IF
  ELSE
       IF   p_ies_impressao = "S" THEN
            START REPORT cre162_relat TO PIPE p_nom_arquivo
       ELSE 
            LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_relat TO p_nom_arquivo1
       END IF
  END IF
  LET p_emi_duplicata = "NAO"
  LET p_houve_erro = FALSE
  PREPARE var_query FROM sql_query
  DECLARE cl_dados_doc  CURSOR WITH HOLD  FOR var_query
  LET p_count = 0
  FOREACH cl_dados_doc INTO l_p_dados_doc.*

   IF p_par_cre_txt.parametro[102] = "2"
   THEN SELECT parametro[1,6]
          INTO l_p_dados_doc.pct_desc
          FROM docum_txt
         WHERE cod_empresa   = l_p_dados_doc.cod_empresa
           AND num_docum     = l_p_dados_doc.num_docum
           AND ies_tip_docum = l_p_dados_doc.ies_tip_docum 
   END IF
    
    SELECT num_pedido, cod_repres_1
      INTO l_p_dados_doc.num_pedido,
           l_p_dados_doc.cod_repres_1
      FROM docum
     WHERE docum.cod_empresa=l_p_dados_doc.cod_empresa
       AND docum.ies_tip_docum=l_p_dados_doc.ies_tip_docum
       AND docum.num_docum=l_p_dados_doc.num_docum

    IF   sqlca.sqlcode <> 0
    THEN LET l_p_dados_doc.num_pedido=" "
         LET l_p_dados_doc.cod_repres_1=0 
    END IF
    
    SELECT ies_tip_cliente  
      INTO p_ies_tip_cliente  
      FROM clientes_cre
     WHERE cod_cliente = l_p_dados_doc.cod_cliente
    IF   sqlca.sqlcode <> 0
    THEN LET p_ies_tip_cliente = "O"
    END IF

    IF  p_ies_tip_cliente = "N"
    THEN CONTINUE FOREACH
    END IF

    LET p_count = p_count + 1
    CALL cre162_verifica_docum_emis_cot()
  
    CALL cre162_extenso() 
    OUTPUT TO REPORT cre162_relat(l_p_dados_doc.*)
    LET p_emi_duplicata = "SIM"
    LET p_listou_dupl = "SIM"
    UPDATE docum SET (dat_emis_docum,num_lote_remessa)
                   = (p_dat_proces_doc,0)
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
  FINISH REPORT cre162_relat
  IF   p_count = 0 THEN
       MESSAGE "Nao existem duplicatas a serem listadas" ATTRIBUTE(REVERSE)
       RETURN
  END IF
  ERROR "Fim de processamento... " 
  IF   p_ies_impressao = "S" 
  THEN MESSAGE "Impressao do relatorio concluida ", " " ATTRIBUTE(REVERSE)
       IF g_ies_ambiente = "W" THEN
          LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
          RUN comando 
       END IF
  ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo1, " " ATTRIBUTE(REVERSE)
  END IF
END FUNCTION

#------------------------#
 FUNCTION cre162_cartas()
#------------------------#
  DEFINE p_count       SMALLINT,
         p_cod_cli_ant LIKE clientes.cod_cliente
  INITIALIZE p_count TO NULL

  IF   p_qtd_rel = 0 
  THEN IF   log028_saida_relat(15,37) IS NULL 
       THEN RETURN
       END IF
  END IF
  LET p_qtd_rel = p_qtd_rel + 1
  MESSAGE " Processando a extracao do relatorio ... " ATTRIBUTE(REVERSE)
  IF   g_ies_ambiente = "W"
  THEN IF   p_ies_impressao = "S"
       THEN LET p_caminho2 = log150_procura_caminho("LST") CLIPPED, "cre9682.tmp"
            START REPORT cre162_rel_car TO p_caminho2
#           START REPORT cre162_rel_car TO PRINTER
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_car TO p_nom_arquivo1
       END IF
  ELSE
       IF   p_ies_impressao = "S"
       THEN START REPORT cre162_rel_car TO PIPE p_nom_arquivo
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_car TO p_nom_arquivo1
       END IF
  END IF

 #LET p_emi_duplicata = "NAO"
  LET p_houve_erro = FALSE
  LET p_count = 0
  LET p_cod_cli_ant = 0
  LET p_ies_quebra  = 0
  LET p_ies_imp = FALSE 

  LET sql_order = " ORDER BY docum_emis.cod_empresa, ",
                  "docum_emis.cod_cliente, docum_emis.num_docum"
  LET sql_query = sql_stmt CLIPPED, sql_order CLIPPED
  PREPARE var_query2 FROM sql_query
  DECLARE cq_cartas CURSOR WITH HOLD  FOR var_query2

  FOREACH cq_cartas INTO l_p_dados_doc.*
    IF   p_cod_cli_ant <> l_p_dados_doc.cod_cliente
    THEN SELECT ies_tip_cliente  
           INTO p_ies_tip_cliente
           FROM clientes_cre
          WHERE cod_cliente = l_p_dados_doc.cod_cliente
         IF   sqlca.sqlcode <> 0
         THEN LET p_ies_tip_cliente = "O"
         END IF
         IF  p_ies_tip_cliente <> "N"
         THEN CONTINUE FOREACH
         END IF
         LET p_qtd_dup    = 0
         LET p_cod_cli_ant = l_p_dados_doc.cod_cliente
    ELSE LET p_qtd_dup = p_qtd_dup + 1
         IF   p_qtd_dup = 10
         THEN LET p_qtd_dup = 0
              LET p_ies_quebra = p_ies_quebra + 1
         END IF
    END IF 

    LET p_count = p_count + 1
    CALL cre162_verifica_docum_emis_cot()
  
    CALL cre162_extenso() 
    OUTPUT TO REPORT cre162_rel_car(l_p_dados_doc.*, p_ies_quebra)
    LET p_emi_duplicata = "SIM"
    LET p_listou_dupl = "SIM"
    UPDATE docum SET (dat_emis_docum,num_lote_remessa)
                   = (p_dat_proces_doc,0)
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
  FINISH REPORT cre162_rel_car
  IF   p_count = 0 THEN
       MESSAGE "Nao existem cartas a serem listadas" ATTRIBUTE(REVERSE)
       RETURN
  END IF
  ERROR "Fim de processamento... " 
  IF p_ies_impressao = "S" 
  THEN MESSAGE "Impressao do relatorio concluida ", " " ATTRIBUTE(REVERSE)
       IF g_ies_ambiente = "W" THEN
          LET comando = "lpdos.bat ", p_caminho2 CLIPPED, " ", p_nom_arquivo
          RUN comando 
       END IF
  ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo1, " " ATTRIBUTE(REVERSE)
  END IF
END FUNCTION

#-----------------------------------------#
 FUNCTION cre162_verifica_docum_emis_cot()
#-----------------------------------------#
 INITIALIZE p_ies_ctr_cotacao, p_cod_moeda_1 TO NULL

 SELECT ies_ctr_cotacao, cod_moeda_1  
   INTO p_ies_ctr_cotacao, p_cod_moeda_1
   FROM empresa_cre
  WHERE empresa_cre.cod_empresa = l_p_dados_doc.cod_empresa 
 IF   sqlca.sqlcode = 0 
 THEN IF   p_ies_ctr_cotacao = "S"
      THEN IF   cre053_busca_docum_emis_cotacao() 
           THEN 
           ELSE LET p_ies_ctr_cotacao = "N"
           END IF
      END IF
 ELSE LET p_ies_ctr_cotacao = "N"
 END IF
 CALL cre162_busca_val_origem()
 
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
  IF   sqlca.sqlcode = 0 THEN
       LET l_p_dados_doc.ies_cotacao = "URV"
       RETURN TRUE
  ELSE LET l_p_dados_doc.ies_cotacao = "CR$"
       RETURN FALSE
  END IF
 END FUNCTION

#------------------------------------------#
 FUNCTION cre162_busca_val_origem()
#------------------------------------------#
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
 FUNCTION cre162_extenso()
#--------------------------#
  INITIALIZE p_lin1,
             p_lin2,
             p_lin3,
             p_lin4  TO NULL

  LET p_comp_l1 = 66
  LET p_comp_l2 = 66
  LET p_comp_l3 = 42
  LET p_comp_l4 = 42

  IF   p_nom_log = "log038_extenso"  THEN
       CALL log038_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
       RETURNING p_lin1, p_lin2, p_lin3, p_lin4
  END IF

  IF   p_nom_log = "log036_extenso"  THEN
       CALL log036_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
       RETURNING p_lin1, p_lin2, p_lin3, p_lin4
  END IF

  IF   p_nom_log = "log033_extenso"  THEN
       CALL log033_extenso(l_p_dados_doc.val_bruto,p_comp_l1,p_comp_l2,p_comp_l3,p_comp_l4)
       RETURNING p_lin1, p_lin2, p_lin3, p_lin4
  END IF  

 END FUNCTION

#--------------------------------------------------------------#
 REPORT cre162_relat(l_p_dados_doc)
#-------------------------------------------------------------#
  DEFINE  l_p_dados_doc RECORD
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
               ies_cotacao  CHAR(03)
                     END RECORD
 DEFINE  p_num                     SMALLINT ,
         p_last_row                SMALLINT

 OUTPUT   PAGE LENGTH 36
          LEFT MARGIN 0
           TOP MARGIN 0
        BOTTOM MARGIN 1

FORMAT
{
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX        XX.XX.XX

           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  CX.POSTAL  XXXXX
   FONE XXXXXXXXXXXXXXX CEP. XXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - XX
           INSCRICAO NO C.G.C.(M.F.)  NUMERO  XXXXXXXXXXXXXXXXXXX
           INSCRICAO ESTADUAL NUMERO - XXXXXXXXXXXXXXXX
                                                      XXXXXXXXXX



 ZZZZ.ZZZ.ZZZ.ZZ9,99  XX-XXXXXXXXXX ZZZZ.ZZZ.ZZZ.ZZ9,99 XXXXXXXXXX   99.99.99


               ZZ,Z         ZZZZ.ZZZ.ZZZ.ZZ9,99     99.99.99



                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXX
                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXX
                 XXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX
                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXXXXX
                 XXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX   XXXX/X.X
                 XXXXXXXXXXXXXXXXXXX                       XXXXXXXXXXXXXXXX


         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
}
  ON EVERY ROW
   IF   l_p_dados_doc.ies_cnd_bordero = "T" THEN
         PRINT COLUMN 53, l_p_dados_doc.dat_emis USING "dd/mm/yyyy",
               COLUMN 66, "TRIPLICATA"
   ELSE
         PRINT COLUMN 53, l_p_dados_doc.dat_emis USING "dd/mm/yyyy" 
   END IF
 
   PRINT                            
   PRINT
   PRINT
   PRINT COLUMN 01, p_comprime,                                            
         COLUMN 27, l_p_dados_doc.num_docum_orig,
         COLUMN 43, l_p_dados_doc.val_fat USING "######,##&.&&",
         COLUMN 58, l_p_dados_doc.num_docum,
         COLUMN 80, l_p_dados_doc.val_bruto USING "######,##&.&&";
         IF   l_p_dados_doc.ies_impr_descr = "S"
         THEN PRINT COLUMN 100, l_p_dados_doc.des_cnd_pgto
         ELSE PRINT COLUMN 100, l_p_dados_doc.dat_vencto_s_desc USING "dd/mm/yyyy"
         END IF
   PRINT COLUMN 01, p_descomprime 
   IF   l_p_dados_doc.pct_desc > 0
   THEN PRINT COLUMN 21, l_p_dados_doc.pct_desc USING "##&.&&",
              COLUMN 33, l_p_dados_doc.val_bruto USING "####,###,###,##&.&&",
              COLUMN 58, l_p_dados_doc.dat_vencto_c_desc USING "dd/mm/yyyy"
   ELSE PRINT
   END IF
   PRINT 
   PRINT 
   PRINT 

   PRINT COLUMN 23, l_p_dados_doc.nom_cliente 

   IF   l_p_dados_doc.end_cliente_cob IS NOT NULL
   THEN PRINT COLUMN 23, l_p_dados_doc.end_cliente_cob[1,32],
              COLUMN 58, l_p_dados_doc.den_bairro_cob[1,12],
              COLUMN 73, p_comprime,           
              COLUMN 68, l_p_dados_doc.cod_cep_cob, 
              COLUMN 95, p_descomprime            
        PRINT COLUMN 23, l_p_dados_doc.den_cidade_cob,
              COLUMN 61, l_p_dados_doc.uni_feder_cob 
        PRINT COLUMN 23, l_p_dados_doc.num_cgc_cpf,
              COLUMN 61, l_p_dados_doc.ins_estadual 
        PRINT COLUMN 23, l_p_dados_doc.den_cidade_cob,
              COLUMN 61, l_p_dados_doc.uni_feder_cob,
              COLUMN 65, l_p_dados_doc.cod_portador USING "####","/",
                 l_p_dados_doc.ies_tip_portador,".",l_p_dados_doc.ies_tip_cobr
   ELSE                                                  
        PRINT COLUMN 23, l_p_dados_doc.end_cliente[1,32],
              COLUMN 58, l_p_dados_doc.den_bairro[1,12],
              COLUMN 73, p_comprime,           
              COLUMN 68, l_p_dados_doc.cod_cep,
              COLUMN 95, p_descomprime            
        PRINT COLUMN 23, l_p_dados_doc.den_cidade_cliente,
              COLUMN 61, l_p_dados_doc.uni_feder_cliente 
        PRINT COLUMN 23, l_p_dados_doc.num_cgc_cpf,
              COLUMN 61, l_p_dados_doc.ins_estadual 
        PRINT COLUMN 23, l_p_dados_doc.den_cidade_cliente,
              COLUMN 61, l_p_dados_doc.uni_feder_cliente,
              COLUMN 65, l_p_dados_doc.cod_portador USING "####","/",
                  l_p_dados_doc.ies_tip_portador,".",l_p_dados_doc.ies_tip_cobr

   END IF

   PRINT
   PRINT
   PRINT COLUMN  19, p_lin1[1,58]
   PRINT COLUMN  19, p_lin2[1,58]
   SKIP TO TOP OF PAGE
###PRINT COLUMN 08, l_p_dados_doc.den_empresa

  END REPORT 
 
#----------------------------#
 REPORT cre162_rel_car(l_p_dados_doc, p_ies_quebra)
#----------------------------#
  DEFINE  l_p_dados_doc RECORD
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
               ies_cotacao  CHAR(03)
                     END RECORD
 DEFINE p_val_total        LIKE docum.val_bruto,
        p_nom_abr_portador LIKE portador.nom_abr_portador,
        p_ies_quebra       SMALLINT

 OUTPUT   LEFT MARGIN 0 
           TOP MARGIN 0 
        BOTTOM MARGIN 1 
        PAGE LENGTH 66
  ORDER  BY l_p_dados_doc.cod_empresa, l_p_dados_doc.cod_cliente,
            p_ies_quebra, l_p_dados_doc.num_docum
FORMAT    
{  
POL0099                                  EXTRAIDO EM XX/XX/XXXX AS XX.XX.XX HRS.
empresa.nom_empresa
999999-999    - CAMPINAS        - SP   (empresa.nom_cidade, empresa.uf_cidade)
ENDER
INSCRICAO ESTADUAL - XXXXXXXXXXXXXXXXXX   (empresa.num_inscr_est)
C.G.C.M.F.         - XXX.XXX.XXX/XXXX-XX  (empresa.num_cgc_cpf)

JOINVILLE, XX DE XXXXXXXXXX DE XXXX

PARA - XXXXXXXXXXXXXXX - COMERCIAL GENTIL MOREIRA S. A.
                         R. PLINIO RAMOS, 50
                         010027-010    -   SAO PAULO       - SP

ATT ............. - (clientes_cre.tex_obs)
TELEX NR. ....... - clientes.num_telex
FAX NR. ......... - clientes.num_fax

REF. FATURAMENTO DO DIA XX/XX/XXXX NA CONDICAO DE PAGAMENTO A VISTA
     --------------------------------------------------------------

          NOTA FISCAL     DUPLICATA                  VALOR
          -----------     ----------     -----------------
          XXXXXXXXXX      XXXXXXXXXX     XX.XXX.XXX.XXX,XX
          XXXXXXXXXX      XXXXXXXXXX     XX.XXX.XXX.XXX,XX
          XXXXXXXXXX      XXXXXXXXXX     XX.XXX.XXX.XXX,XX
                                       -------------------
                                TOTAL: XXXX.XXX.XXX.XXX,XX

                ABATIMENTO AUTORIZADO: ...................

                        VALOR A PAGAR: ...................


OBSERVACOES -
-------------

1) VALORES CONSIDERADOS NO FLUXO DE CAIXA DO DIA -

2) PAGAMENTO - BANCO   - XXXXXXXXXXXXXXXXX
               AGENCIA - XXXXX     CONTA CORRENTE NR - XXXXXXXXXXXXXXX

3) ABATIMENTOS - DEVERAO SER NEGOCIADOS ENTRE AS PARTES, COM ANTECE-
                 DENCIA DE 48 HORAS.

4) CONTATO - CONTAS A RECEBER
             FONE - (empresa.num_telefone)
             FAX  - (empresa.num_fax)




ATENCIOSAMENTE
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

CONTROLES FINANCEIROS 

}
    PAGE HEADER
         LET p_val_total  = 0
         PRINT COLUMN 01, "POL0099",
               COLUMN 42,"EXTRAIDO EM ",TODAY," AS ",TIME ," HRS."
         PRINT COLUMN 01, l_p_dados_doc.den_empresa
         PRINT COLUMN 01, l_p_dados_doc.cod_cep_emp,"  -  ",l_p_dados_doc.den_munic CLIPPED,
                          "  -  ",l_p_dados_doc.uni_feder
         PRINT COLUMN 01, l_p_dados_doc.end_empresa CLIPPED,"  -  ",l_p_dados_doc.den_bairro_emp
         PRINT COLUMN 01, "INSCRICAO ESTADUAL - ",l_p_dados_doc.ins_estadual_emp
         PRINT COLUMN 01, "C.G.C.M.F.         - ",l_p_dados_doc.num_cgc
         PRINT
         PRINT COLUMN 01,l_p_dados_doc.den_munic CLIPPED,", ",DAY(p_dat_proces_doc) USING "##" ," DE ",
                           p_mes_extenso CLIPPED," DE ", YEAR(p_dat_proces_doc) USING "####"
         PRINT
         PRINT COLUMN 01,"PARA - ",l_p_dados_doc.cod_cliente," - ",l_p_dados_doc.nom_cliente
         IF   l_p_dados_doc.end_cliente_cob IS NOT NULL
         THEN PRINT COLUMN 26,l_p_dados_doc.end_cliente_cob
              PRINT COLUMN 26,l_p_dados_doc.cod_cep_cob," - ",
                              l_p_dados_doc.den_cidade_cob CLIPPED," - ",
                              l_p_dados_doc.uni_feder_cob 
         ELSE PRINT COLUMN 26,l_p_dados_doc.end_cliente
              PRINT COLUMN 26,l_p_dados_doc.cod_cep," - ",
                              l_p_dados_doc.den_cidade_cliente CLIPPED," - ",
                              l_p_dados_doc.uni_feder_cliente 
         END IF
         PRINT
         PRINT COLUMN 01,"ATT ............. - ",l_p_dados_doc.tex_obs
         PRINT COLUMN 01,"TELEX NR. ....... - ",l_p_dados_doc.num_telex_cli
         PRINT COLUMN 01,"FAX NR. ......... - ",l_p_dados_doc.num_fax_cli
         PRINT
         PRINT
         PRINT COLUMN 05,"NOTA FISCAL   DUPLICATA      EMISSAO    ", 
                         "VENCIMENTO               VALOR"
         PRINT COLUMN 05,"-----------   ----------   ----------   ",   
                         "----------   -----------------"

    ON EVERY ROW
         LET p_val_total = p_val_total + l_p_dados_doc.val_bruto
         PRINT COLUMN 05,l_p_dados_doc.num_docum_orig,
               COLUMN 19,l_p_dados_doc.num_docum,
               COLUMN 32,l_p_dados_doc.dat_emis,
               COLUMN 45,l_p_dados_doc.dat_vencto_s_desc,  
               COLUMN 58,l_p_dados_doc.val_bruto USING "##,###,###,###.##"

    BEFORE GROUP OF l_p_dados_doc.cod_cliente
        SELECT clientes_cre.num_conta, clientes_cre.num_agencia, 
               portador.nom_abr_portador
          INTO l_p_dados_doc.num_conta, l_p_dados_doc.num_agencia, 
               p_nom_abr_portador
          FROM clientes_cre, OUTER portador
         WHERE clientes_cre.cod_cliente  = l_p_dados_doc.cod_cliente
           AND portador.cod_portador     = clientes_cre.cod_portador
           AND portador.ies_tip_portador = clientes_cre.ies_tip_portador 
        LET p_ies_imp = FALSE
        SKIP TO TOP OF PAGE
 
    AFTER GROUP OF l_p_dados_doc.cod_cliente
      CALL cre162_busca_fone(l_p_dados_doc.cod_empresa)
      IF   p_ies_imp = FALSE
      THEN 
        NEED 30 LINES
        PRINT COLUMN 56,"-------------------"
        PRINT COLUMN 49,"TOTAL: ",p_val_total USING "####,###,###,##&.&&"
        PRINT
        PRINT COLUMN 33,"ABATIMENTO AUTORIZADO: ..................."
        PRINT 
        PRINT COLUMN 41,"VALOR A PAGAR: ..................."
        PRINT
        PRINT
        PRINT
        PRINT COLUMN 01,"OBSERVACOES -"
        PRINT COLUMN 01,"-------------"
        PRINT
     IF p_par_cre_txt.parametro[190] = "S"
     THEN
        PRINT COLUMN 01,"1) PAGAMENTO - BANCO   - ", p_nom_abr_portador
        PRINT COLUMN 16,"AGENCIA - ", l_p_dados_doc.num_agencia ,
              COLUMN 36,"-  CONTA CORRENTE NR - ", l_p_dados_doc.num_conta         
        PRINT
        PRINT COLUMN 01,"2) CONTATO - CONTAS A RECEBER"
        PRINT COLUMN 14,"FONE - ",l_p_dados_doc.num_telefone
        PRINT COLUMN 14,"FAX  - ",l_p_dados_doc.num_fax
     ELSE
        PRINT COLUMN 01,"1) PAGAMENTO - BANCO   - ", p_nom_abr_portador
        PRINT COLUMN 16,"AGENCIA - ", l_p_dados_doc.num_agencia ,
              COLUMN 36,"-  CONTA CORRENTE NR - ", l_p_dados_doc.num_conta         
        PRINT
        PRINT COLUMN 01,"2) ABATIMENTOS - DEVERAO SER NEGOCIADOS ENTRE AS PARTES, COM ANTECE-"
        PRINT COLUMN 18,"DENCIA DE 48 HORAS."
        PRINT
        PRINT COLUMN 01,"3) CONTATO - CONTAS A RECEBER"
        PRINT COLUMN 14,"FONE - ", p_empresa_cre_txt.parametros[31,45]                
        PRINT COLUMN 14,"FAX  - ", p_empresa_cre_txt.parametros[76,90] 
      END IF
        PRINT
        PRINT
        PRINT
        PRINT COLUMN 05,"ATENCIOSAMENTE"
        PRINT
        PRINT
        PRINT COLUMN 05,"CONTROLE FINANCEIROS"
      END IF

    BEFORE GROUP OF p_ies_quebra
        SKIP TO TOP OF PAGE
 
    AFTER GROUP OF p_ies_quebra
        CALL cre162_busca_fone(l_p_dados_doc.cod_empresa)
        NEED 30 LINES
        PRINT COLUMN 56,"-------------------"
        PRINT COLUMN 49,"TOTAL: ",p_val_total USING "####,###,###,##&.&&"
        PRINT
        PRINT COLUMN 33,"ABATIMENTO AUTORIZADO: ..................."
        PRINT 
        PRINT COLUMN 41,"VALOR A PAGAR: ..................."
        PRINT
        PRINT
        PRINT
        PRINT COLUMN 01,"OBSERVACOES -"
        PRINT COLUMN 01,"-------------"
        PRINT
     IF p_par_cre_txt.parametro[190] = "S"
     THEN
        PRINT COLUMN 01,"1) PAGAMENTO - BANCO   - ", p_nom_abr_portador
        PRINT COLUMN 16,"AGENCIA - ", l_p_dados_doc.num_agencia ,
              COLUMN 36,"-  CONTA CORRENTE NR - ", l_p_dados_doc.num_conta         
        PRINT
        PRINT COLUMN 01,"2) CONTATO - CONTAS A RECEBER"
        PRINT COLUMN 14,"FONE - ",l_p_dados_doc.num_telefone
        PRINT COLUMN 14,"FAX  - ",l_p_dados_doc.num_fax
     ELSE
        PRINT COLUMN 01,"1) PAGAMENTO - BANCO   - ", p_nom_abr_portador
        PRINT COLUMN 16,"AGENCIA - ", l_p_dados_doc.num_agencia ,
              COLUMN 36,"-  CONTA CORRENTE NR - ", l_p_dados_doc.num_conta         
        PRINT
        PRINT COLUMN 01,"2) ABATIMENTOS - DEVERAO SER NEGOCIADOS ENTRE AS PARTES, COM ANTECE-"
        PRINT COLUMN 18,"DENCIA DE 48 HORAS."
        PRINT
        PRINT COLUMN 01,"3) CONTATO - CONTAS A RECEBER"
        PRINT COLUMN 14,"FONE - ", p_empresa_cre_txt.parametros[31,45] 
        PRINT COLUMN 14,"FAX  - ", p_empresa_cre_txt.parametros[76,90] 
     END IF
        PRINT
        PRINT
        PRINT
        PRINT COLUMN 05,"ATENCIOSAMENTE"
        PRINT
        PRINT
        PRINT COLUMN 05,"CONTROLE FINANCEIROS"
        LET p_ies_imp = TRUE
 
 END REPORT

#----------------------------------#
  FUNCTION cre162_pesquisa_par_cre()
#----------------------------------#
  INITIALIZE p_dat_proces_doc TO NULL
  SELECT par_cre.dat_proces_doc
    INTO p_dat_proces_doc
    FROM par_cre
  END FUNCTION

#----------------------------------#
  FUNCTION cre162_emite_bord_banco()
#----------------------------------#
  DEFINE   p_bord_banco  RECORD
           cod_empresa        LIKE docum_emis.cod_empresa,
           cod_cliente        LIKE docum_emis.cod_cliente,
           nom_cliente        LIKE clientes.nom_cliente, 
           den_cidade_cli     LIKE cidades.den_cidade,
           cod_portador       LIKE portador.cod_portador , 
           dat_emis           LIKE docum_emis.dat_emis,
           num_docum          LIKE docum_emis.num_docum,
           dat_vencto_s_desc  LIKE docum_emis.dat_vencto_s_desc,
           val_bruto          LIKE docum_emis.val_bruto,
           den_empresa        LIKE empresa.den_empresa,          
           end_empresa        LIKE empresa.end_empresa ,         
           den_bairro_emp     LIKE empresa.den_bairro,           
           den_munic          LIKE empresa.den_munic,            
           uni_feder          LIKE empresa.uni_feder,            
           cod_cep_emp        LIKE empresa.cod_cep,  
           nom_portador       LIKE portador.nom_portador,
           cod_cep_port       LIKE portador.cod_cep,
           den_cidade_port    LIKE cidades.den_cidade,
           cod_uni_feder      LIKE cidades.cod_uni_feder,
           num_conta          LIKE portador_banco.num_conta,
           num_agencia        LIKE portador_banco.num_agencia,
           pct_juro_legal     LIKE juro_mora.pct_juro_legal,
           pct_desp_financ    LIKE juro_mora.pct_desp_financ,
           num_ult_bordero    LIKE empresa_cre.num_ult_bordero,
           ies_cotacao        CHAR(03)
                       END RECORD,
     p_existe_dados     CHAR(03)
 
 LET p_existe_dados = "NAO" 
 LET p_val_tot_rep = 0
 LET p_qtd_tot_rep = 0
  IF   p_qtd_rel = 0 
  THEN IF   log028_saida_relat(15,37) IS NULL 
       THEN RETURN
       END IF
  END IF
  LET p_qtd_rel = p_qtd_rel + 1
  MESSAGE " Inicio da emissao dos borderos para bancos" ATTRIBUTE(REVERSE)
  IF   g_ies_ambiente = "W"
  THEN IF   p_ies_impressao = "S"
       THEN LET p_caminho3 = log150_procura_caminho("LST") CLIPPED, "cre9683.tmp"
            START REPORT cre162_rel_bor_b TO p_caminho3
#           START REPORT cre162_rel_bor_b TO PRINTER
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_bor_b TO p_nom_arquivo1
       END IF
  ELSE
       IF   p_ies_impressao = "S"
       THEN START REPORT cre162_rel_bor_b TO PIPE p_nom_arquivo
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_bor_b TO p_nom_arquivo1
       END IF
  END IF
  
  FOREACH cl_dados_doc INTO l_p_dados_doc.*
    IF   l_p_dados_doc.ies_tip_portador <> "B"
    THEN CONTINUE FOREACH
    END IF
    IF   l_p_dados_doc.ies_cnd_bordero = "T"
    THEN CONTINUE FOREACH
    END IF
    LET p_bord_banco.ies_cotacao        = l_p_dados_doc.ies_cotacao
    LET p_bord_banco.cod_empresa        = l_p_dados_doc.cod_empresa    
    LET p_bord_banco.cod_cliente        = l_p_dados_doc.cod_cliente
    LET p_bord_banco.nom_cliente        = l_p_dados_doc.nom_cliente
    LET p_bord_banco.den_cidade_cli     = l_p_dados_doc.den_cidade_cliente 
    LET p_bord_banco.cod_portador       = l_p_dados_doc.cod_portador
    LET p_bord_banco.dat_emis           = l_p_dados_doc.dat_emis         
    LET p_bord_banco.num_docum          = l_p_dados_doc.num_docum        
    LET p_bord_banco.dat_vencto_s_desc  = l_p_dados_doc.dat_vencto_s_desc

    CALL cre162_verifica_docum_emis_cot()
    LET p_bord_banco.val_bruto          = l_p_dados_doc.val_bruto        
    
    LET p_bord_banco.den_empresa        = NULL    
    LET p_bord_banco.end_empresa        = NULL
    LET p_bord_banco.den_bairro_emp     = NULL
    LET p_bord_banco.uni_feder          = NULL
    LET p_bord_banco.cod_cep_emp        = NULL
    LET p_bord_banco.nom_portador       = NULL
    LET p_bord_banco.cod_cep_port       = NULL
    LET p_bord_banco.den_cidade_port    = NULL
    LET p_bord_banco.cod_uni_feder      = NULL
    LET p_bord_banco.num_conta          = NULL
    LET p_bord_banco.num_agencia        = NULL
    LET p_bord_banco.pct_juro_legal     = NULL
    LET p_bord_banco.pct_desp_financ    = NULL
    LET p_bord_banco.num_ult_bordero    = NULL
    IF   l_p_dados_doc.ies_tip_cobr = "S"
    THEN LET p_tip_cobr = " SIMPLES" 
    ELSE IF   l_p_dados_doc.ies_tip_cobr = "D"
         THEN LET p_tip_cobr = " DESCONTADA"
         ELSE IF   l_p_dados_doc.ies_tip_cobr = "C"
              THEN LET p_tip_cobr = " CAUCAO"
              END IF
         END IF
    END IF
    OUTPUT TO REPORT cre162_rel_bor_b(p_bord_banco.*,p_tip_cobr)
    LET p_existe_dados = "SIM"
    LET p_listou_bord_b = "SIM"
  END FOREACH
  FINISH REPORT cre162_rel_bor_b
  IF   p_existe_dados = "NAO" 
  THEN MESSAGE " Nao foram encontrados informacoes p/bancos" ATTRIBUTE(REVERSE)
       IF g_ies_ambiente = "W" THEN
          LET comando = "lpdos.bat ", p_caminho3 CLIPPED, " ", p_nom_arquivo
          RUN comando 
       END IF
  ELSE MESSAGE " Emissao de borderos para bancos terminada." ATTRIBUTE(REVERSE)
  END IF
  IF   p_houve_erro = TRUE
  THEN ERROR " Transacao cancelada. "
  END IF 
  ERROR "Fim de processamento... " 
  IF   p_existe_dados = "SIM"
  THEN IF p_ies_impressao = "S"
       THEN MESSAGE "Impressao do relatorio concluida ", " " ATTRIBUTE(REVERSE)
       ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo1, " " ATTRIBUTE(REVERSE)
       END IF
  END IF
END FUNCTION

#--------------------------------------------------#
 FUNCTION cre162_port_banco_banco(p_cod_empresa_ba,p_cod_portador_ba)
#--------------------------------------------------#
DEFINE p_cod_portador_ba LIKE docum_emis.cod_portador,
       p_cod_empresa_ba  LIKE docum_emis.cod_empresa, 
       p_num_conta     LIKE portador_banco.num_conta, 
       p_num_agencia   LIKE portador_banco.num_agencia
INITIALIZE p_num_conta, p_num_agencia TO NULL
  

SELECT portador_banco.num_conta,
       portador_banco.num_agencia
INTO p_num_conta,
     p_num_agencia   
 FROM portador_banco
WHERE portador_banco.cod_empresa = p_cod_empresa_ba
  AND portador_banco.cod_portador = p_cod_portador_ba
  AND portador_banco.ies_tip_docum = "DP"
RETURN p_num_conta,p_num_agencia 
END FUNCTION

#------------------------------------------------#
 FUNCTION cre162_portador_banco(p_cod_portador_ba)
#------------------------------------------------#
DEFINE p_cod_portador_ba LIKE portador.cod_portador,
       p_nom_portador    LIKE portador.nom_portador,
       p_cod_cep_port    LIKE portador.cod_cep     ,
       p_den_cidade_port LIKE cidades.den_cidade   ,
       p_cod_uni_feder   LIKE cidades.cod_uni_feder 
INITIALIZE p_nom_portador, p_cod_cep_port, p_den_cidade_port, p_cod_uni_feder TO NULL

SELECT portador.nom_portador,
       portador.cod_cep     ,
       cidades.den_cidade   ,
       cidades.cod_uni_feder 
INTO   p_nom_portador  ,  
       p_cod_cep_port   , 
       p_den_cidade_port,
       p_cod_uni_feder   
FROM portador,cidades
WHERE portador.cod_portador = p_cod_portador_ba
 AND  portador.ies_tip_portador = "B" 
 AND  cidades.cod_cidade  = portador.cod_cidade
#IF sqlca.sqlcode <> 0        
#THEN LET p_houve_erro = TRUE
#END IF   { transacional }   
RETURN p_nom_portador,p_cod_cep_port,p_den_cidade_port,p_cod_uni_feder   
END FUNCTION

#--------------------------------------#
 REPORT cre162_rel_bor_b(p_bord_banco,p_tip_cobr)
#--------------------------------------#
  DEFINE   p_bord_banco  RECORD
           cod_empresa        LIKE docum_emis.cod_empresa ,
           cod_cliente        LIKE docum_emis.cod_cliente,
           nom_cliente        LIKE clientes.nom_cliente, 
           den_cidade_cli     LIKE cidades.den_cidade,
           cod_portador       LIKE portador.cod_portador , 
           dat_emis           LIKE docum_emis.dat_emis,
           num_docum          LIKE docum_emis.num_docum,
           dat_vencto_s_desc  LIKE docum_emis.dat_vencto_s_desc,
           val_bruto          LIKE docum_emis.val_bruto,
           den_empresa        LIKE empresa.den_empresa,          
           end_empresa        LIKE empresa.end_empresa ,         
           den_bairro_emp     LIKE empresa.den_bairro,           
           den_munic          LIKE empresa.den_munic,            
           uni_feder          LIKE empresa.uni_feder,            
           cod_cep_emp        LIKE empresa.cod_cep,  
           nom_portador       LIKE portador.nom_portador,
           cod_cep_port       LIKE portador.cod_cep,
           den_cidade_port    LIKE cidades.den_cidade,
           cod_uni_feder      LIKE cidades.cod_uni_feder,
           num_conta          LIKE portador_banco.num_conta,
           num_agencia        LIKE portador_banco.num_agencia,
           pct_juro_legal     LIKE juro_mora.pct_juro_legal,
           pct_desp_financ    LIKE juro_mora.pct_desp_financ,
           num_ult_bordero    LIKE empresa_cre.num_ult_bordero,
           ies_cotacao        CHAR(03)
                       END RECORD,
           p_pct_juro_legal   LIKE juro_mora.pct_juro_mora,
           p_pct_desp_financ  LIKE juro_mora.pct_desp_financ,
           p_num_ult_bordero  LIKE empresa_cre.num_ult_bordero,  
           p_den_empresa      LIKE empresa.den_empresa,
           p_tip_cobr         CHAR(11)
      { variaveis criadas para armazenar valores para cada grupo }  
 OUTPUT   LEFT MARGIN 0 
           TOP MARGIN 0 
        BOTTOM MARGIN 1 
        PAGE LENGTH 66
  ORDER  BY p_bord_banco.cod_empresa,p_bord_banco.cod_portador
FORMAT    
{  
POL0099                                                                               EXTRAIDO EM dd/mm/yy  AS dd:dd:dd HRS.
+--------------------------------------------------------+     +-----------------------------------------------------------+
I                                                        I     I                                                           I
I        NOME DA EMPRESA                                 I     I   PARA USO DO - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  I
I        ENDERECO DA EMPRESA                             I     I       AGENCIA -                                           I
I        89000-22  - CIDADE     - SC                     I     I      89200-22 - JOINVILLE - SC                            I
I                                                        I     I                                                           I
I                                                        I     I      CARTEIRA -                                           I 
I                                                        I     I                                                           I
I  NOSSA CONTA -                                         I     I                                                           I
I                                                        I     I                                                           I
I                                                        I     I                                                           I
+--------------------------------------------------------+     I                                                           I
                                                               I                                                           I 
                                                               I                                                           I
 AO - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - ####           I                                                           I
                                                               I                                                           I
                                                               +-----------------------------------------------------------+

OFERECEMOS NAS CONDICOES USUAIS DESSE BANCO, O (S) TITULOS ABAIXO
DISCRIMINADO(S). REPONSABILIZANDO-NOS PELA SUA LEGITIMIDADE.
AUTORIZAMOS FAZER TODO MOVIMENTO CONTABIL, RELATIVO AO REGISTRO
E LIQUIDACAO, DIRETAMENTE EM NOSSA CONTA CORRENTE.


      DATA     NUMERO       DATA                                                                                  VALOR DA 
   EMISSAO  DUPLICATA VENCIMENTO NOME DO SACADO                        PRACA                                     DUPLICATA   
---------- ---------- ---------- ------------------------------------- ------------------------------ --------------------
dd/mm/yyyy XXXXXXXXXX dd/mm/yyyy XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #,###,###,###,##&.&&

                                                                                          TOTAL ....  #,###,###,###,##&.&&

NA FALTA DE PAGAMENTO NO VENCIMENTO COBRAR JUROS DE MORA DE ##&.&& % E DESPESAS FINANCEIRAS DE ##&.&& % AO MES

TEXTO DO TEXTOCRE
                                                                                        +----------------------------------+ 
                                                                                        I                                  I
CIDADE     , 20 DE OUTUBRO  DE A987                                                     I   NUMERO DO BORDERO ....   ###   I         
                                                                                        I                                  I
                                                                                        I   NUMERO DE DUPLICATAS..  ####   I 
                    ---------------------------------------                             I                                  I
                    NOME DA EMPRESA                                                     +----------------------------------+
} 
PAGE HEADER 
   CALL cre162_empresa_banco(p_bord_banco.cod_empresa) 
         RETURNING p_den_empresa,
         p_bord_banco.end_empresa,p_bord_banco.den_bairro_emp , 
         p_bord_banco.den_munic,p_bord_banco.uni_feder,p_bord_banco.cod_cep_emp  
   CALL cre162_portador_banco(p_bord_banco.cod_portador)
         RETURNING p_bord_banco.nom_portador,
         p_bord_banco.cod_cep_port,p_bord_banco.den_cidade_port,
         p_bord_banco.cod_uni_feder   
   CALL cre162_port_banco_banco(p_bord_banco.cod_empresa,p_bord_banco.cod_portador)
        RETURNING p_bord_banco.num_conta,p_bord_banco.num_agencia  
   PRINT COLUMN  01,"POL0099",
         COLUMN  85, " EXTRAIDO EM ",p_dat_proces_doc," AS ", TIME, " HRS." 
   PRINT COLUMN  01,"+--------------------------------------------------------+     +-----------------------------------------------------------+"
   PRINT COLUMN  01,"I                                                        I     I                                                           I" 
   PRINT COLUMN  01,"I  ",p_den_empresa,
         COLUMN  58,"I     I   PARA USO DO - ",p_bord_banco.nom_portador,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I  ",p_bord_banco.end_empresa,
         COLUMN  58,"I     I       AGENCIA - ",p_bord_banco.num_agencia,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I  ",p_bord_banco.cod_cep_emp," - ",
                          p_bord_banco.den_munic, " -  ",
                          p_bord_banco.uni_feder ,
         COLUMN  58,"I     I    ",p_bord_banco.cod_cep_port,"  - ",
                                  p_bord_banco.den_cidade_port," - ",
                                  p_bord_banco.cod_uni_feder,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I                                                        I     I      CARTEIRA -",p_tip_cobr,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I                                                        I     I                                                           I"
   PRINT COLUMN  01,"I  NOSSA CONTA - ",p_bord_banco.num_conta,
         COLUMN  58,"I     I                                                           I"
   PRINT COLUMN  01,"I                                                        I     I                                                           I" 
   PRINT COLUMN  01,"I                                                        I     I                                                           I"
   PRINT COLUMN  01,"+--------------------------------------------------------+     I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  01," AO - ",p_bord_banco.nom_portador," - ",
                    p_bord_banco.cod_portador USING "####" ,
         COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"+-----------------------------------------------------------+"
   PRINT 
   PRINT COLUMN  01,"OFERECEMOS NAS CONDICOES USUAIS DESSE BANCO, O (S) TITULOS ABAIXO"
   PRINT COLUMN  01,"DISCRIMINADO(S). REPONSABILIZANDO-NOS PELA SUA LEGITIMIDADE."
   PRINT COLUMN  01,"AUTORIZAMOS FAZER TODO MOVIMENTO CONTABIL, RELATIVO AO REGISTRO"
   PRINT COLUMN  01,"E LIQUIDACAO, DIRETAMENTE EM NOSSA CONTA CORRENTE."
   SKIP 2 LINES
   PRINT COLUMN  01,"   DATA    NUMERO        DATA"
   PRINT COLUMN  01,"  EMISSAO  DUPLICATA  VENCIMENTO NOME DO SACADO                        PRACA                            VALOR DA DUPLICATA"
   PRINT COLUMN  01,"---------- ---------- ---------- ------------------------------------- ------------------------------ --------------------"
 
 ON EVERY ROW
   PRINT COLUMN  01,p_bord_banco.dat_emis USING "dd/mm/yyyy",
         COLUMN  12,p_bord_banco.num_docum ,
         COLUMN  23,p_bord_banco.dat_vencto_s_desc USING "dd/mm/yyyy",
         COLUMN  34,p_bord_banco.nom_cliente,
         COLUMN  72,p_bord_banco.den_cidade_cli,
         COLUMN 103,p_bord_banco.val_bruto USING "#,###,###,###,##&.&&"   
   LET p_val_tot_rep = p_val_tot_rep + p_bord_banco.val_bruto
   LET p_qtd_tot_rep = p_qtd_tot_rep  + 1 

  BEFORE GROUP OF p_bord_banco.cod_empresa
   CALL cre162_juro_mora_banco(p_bord_banco.cod_empresa,"CR$")
        RETURNING p_pct_juro_legal,p_pct_desp_financ 
  BEFORE GROUP OF p_bord_banco.cod_portador
   CALL cre162_empresa_cre_banco(p_bord_banco.cod_empresa)  
         RETURNING  p_num_ult_bordero
   SKIP TO TOP OF PAGE

  AFTER GROUP OF p_bord_banco.cod_portador
   CALL cre162_busca_texto()
   PRINT 
   PRINT COLUMN 91,"TOTAL ...   ",
         COLUMN 103,p_val_tot_rep USING "#,###,###,###,##&.&&"
   PRINT 
   LET p_val_tot_rep =  0
   PRINT COLUMN 01,"NA FALTA DE PAGAMENTO NO VENCIMENTO COBRAR JUROS DE MORA DE ",
                     p_pct_juro_legal USING "##&.&&",
                     " % E DESPESAS FINANCEIRAS DE ",
                     p_pct_desp_financ USING "##&.&&", " % AO MES. "
   SKIP 2 LINES
   CALL set_count(10)
   FOR p_ind = 1 TO 10
      PRINT COLUMN 01,p_texto[p_ind].des_linha
      IF  p_texto[p_ind].des_linha  IS NULL THEN
            EXIT FOR
      END IF
   END FOR
   NEED 6  LINES
   PRINT COLUMN 89,"+----------------------------------+"
   PRINT COLUMN 89,"I                                  I"

   PRINT COLUMN 01,p_bord_banco.den_munic CLIPPED,", ",DAY(p_dat_proces_doc) USING "##", " DE ",
                   p_mes_extenso , " DE " ,
                   YEAR(p_dat_proces_doc) USING "####",
         COLUMN 89,"I   NUMERO DO BORDERO ....  ",
                   p_num_ult_bordero USING "###",
         COLUMN 124,"I"
   PRINT COLUMN 89,"I                                  I"
   PRINT COLUMN 89,"I                                  I"
   PRINT COLUMN 89,"I  NUMERO DE DUPLICATAS ..  ",
                  p_qtd_tot_rep USING "####",
         COLUMN 124,"I"
   PRINT COLUMN 21,"---------------------------------------",
         COLUMN 89,"I                                  I"
   PRINT COLUMN 21,p_den_empresa,
         COLUMN 89,"+----------------------------------+"
   LET p_qtd_tot_rep = 0
#  LET p_pct_juro_legal= 0 
#  LET p_pct_desp_financ = 0
#  LET p_num_ult_bordero = 0
END REPORT 

{ *** fim da rotina que emite bordero para banco ***  } 

{ *** inicio das funcoes iguais para emitir bordero
       para banco e representante ***  } 

#-----------------------------#
 FUNCTION cre162_mes_extenso()
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

#-------------------------------------------------#
 FUNCTION cre162_juro_mora_banco(p_cod_empresa_ba,p_ies_cotacao)
#-------------------------------------------------#
DEFINE p_cod_empresa_ba  LIKE  docum_emis.cod_empresa,
       p_pct_juro_legal  LIKE  juro_mora.pct_juro_legal,
       p_pct_desp_financ LIKE  juro_mora.pct_desp_financ,
       p_ies_cotacao     CHAR(03)
INITIALIZE  p_pct_juro_legal, p_pct_desp_financ TO NULL 

LET p_pct_juro_legal   = 0
LET p_pct_desp_financ  = 0
SELECT juro_mora.pct_juro_legal,
       juro_mora.pct_desp_financ
 INTO  p_pct_juro_legal,
       p_pct_desp_financ 
 FROM juro_mora
 WHERE juro_mora.cod_empresa = p_cod_empresa_ba
   AND juro_mora.ies_cotacao = p_ies_cotacao
   AND juro_mora.dat_ini = (SELECT MAX(dat_ini)
                       FROM juro_mora 
                       WHERE juro_mora.cod_empresa = p_cod_empresa_ba)
                         AND juro_mora.ies_cotacao = p_ies_cotacao
RETURN p_pct_juro_legal,p_pct_desp_financ 
END FUNCTION

#---------------------------------------------------#
 FUNCTION cre162_empresa_cre_banco(p_cod_empresa_cre)
#---------------------------------------------------#
 DEFINE p_cod_empresa_cre LIKE empresa_cre.cod_empresa,
        p_num_ult_bordero   LIKE empresa_cre.num_ult_bordero       
 INITIALIZE  p_num_ult_bordero TO NULL

 SELECT empresa_cre.num_ult_bordero       
 INTO  p_num_ult_bordero  
 FROM empresa_cre
 WHERE empresa_cre.cod_empresa = p_cod_empresa_cre

 IF p_num_ult_bordero = 999
 THEN LET p_num_ult_bordero = 0 
 END IF
  
 LET p_num_ult_bordero = p_num_ult_bordero  + 1
 SET LOCK MODE TO WAIT 
 WHENEVER ERROR CONTINUE
 CALL log085_transacao("BEGIN")
 LOCK TABLE empresa_cre IN SHARE MODE
 UPDATE empresa_cre  SET ( num_ult_bordero,dat_atualiz ) =
                          ( p_num_ult_bordero,p_dat_proces_doc )
   WHERE empresa_cre.cod_empresa = p_cod_empresa_cre 
 IF sqlca.sqlcode != 0
 THEN CALL log003_err_sql("ATUALIZACAO", "DOCUM_EMIS")
      LET p_houve_erro = TRUE 
      CALL log085_transacao("ROLLBACK")
 ELSE CALL log085_transacao("COMMIT")
 END IF
 WHENEVER ERROR STOP

 RETURN p_num_ult_bordero
END FUNCTION

#----------------------------------------------#
 FUNCTION cre162_empresa_banco(p_cod_empresa_ba) 
#----------------------------------------------#
 DEFINE p_cod_empresa_ba LIKE docum_emis.cod_empresa,
        p_den_empresa    LIKE  empresa.den_empresa,
        p_end_empresa    LIKE  empresa.end_empresa,
        p_den_bairro_emp LIKE  empresa.den_bairro,
        p_den_munic      LIKE  empresa.den_munic,  
        p_uni_feder      LIKE  empresa.uni_feder , 
        p_cod_cep_emp    LIKE  empresa.cod_cep     
 INITIALIZE p_den_empresa,p_end_empresa,p_den_bairro_emp,
            p_den_munic,p_uni_feder,p_cod_cep_emp    TO NULL

SELECT  empresa.den_empresa,
        empresa.end_empresa,
        empresa.den_bairro ,
        empresa.den_munic, 
        empresa.uni_feder ,
        empresa.cod_cep       
 INTO   p_den_empresa,
        p_end_empresa,
        p_den_bairro_emp ,
        p_den_munic   ,
        p_uni_feder   ,
        p_cod_cep_emp    
 FROM empresa
WHERE empresa.cod_empresa = p_cod_empresa_ba
 RETURN p_den_empresa,p_end_empresa,p_den_bairro_emp ,p_den_munic,p_uni_feder, 
        p_cod_cep_emp 
END FUNCTION

#-----------------------------#
 FUNCTION cre162_busca_texto()
#-----------------------------#
DEFINE p_num_seq_linha  LIKE par_rel_cre_tex.num_seq_linha 
INITIALIZE p_num_seq_linha TO NULL
 
INITIALIZE p_texto TO NULL
LET p_ind = 1
DECLARE cl_texto CURSOR FOR
  SELECT par_rel_cre_tex.des_linha,par_rel_cre_tex.num_seq_linha 
  FROM par_rel_cre_tex
  WHERE par_rel_cre_tex.num_relat = "POL0099"
    AND par_rel_cre_tex.num_seq_texto = 1
    AND par_rel_cre_tex.ies_situa_texto = "A"
   ORDER BY num_seq_linha
  FOREACH cl_texto INTO p_texto[p_ind].des_linha,p_num_seq_linha 
       LET p_ind  = p_ind  + 1
       IF p_ind  > 10 THEN
            EXIT FOREACH
       END IF 
   END FOREACH
END FUNCTION


{ *** fim das funcoes iguais para emitir bordero
       para banco e representante ***  } 

{ *** inicio da rotina que emite bordero para representante ***  } 
#-----------------------------------#
  FUNCTION cre162_emite_bord_repres()
#-----------------------------------#
  DEFINE   p_bord_repres  RECORD
           cod_empresa        LIKE docum_emis.cod_empresa ,
           cod_cliente        LIKE docum_emis.cod_cliente,
           nom_cliente        LIKE clientes.nom_cliente, 
           den_cidade_cli     LIKE cidades.den_cidade,
           cod_repres         LIKE docum.cod_repres_1 , 
           dat_emis           LIKE docum_emis.dat_emis,
           num_docum          LIKE docum_emis.num_docum,
           dat_vencto_s_desc  LIKE docum_emis.dat_vencto_s_desc,
           val_bruto          LIKE docum_emis.val_bruto,
           den_empresa        LIKE empresa.den_empresa,          
           end_empresa        LIKE empresa.end_empresa ,         
           den_bairro_emp     LIKE empresa.den_bairro,           
           den_munic          LIKE empresa.den_munic,            
           uni_feder          LIKE empresa.uni_feder,            
           cod_cep_emp        LIKE empresa.cod_cep,  
           raz_social         LIKE representante.raz_social,
           cod_cep_repres     LIKE representante.cod_cep,
           den_cidade_repres  LIKE cidades.den_cidade,
           cod_uni_feder      LIKE cidades.cod_uni_feder,
           pct_juro_legal     LIKE juro_mora.pct_juro_legal,
           pct_desp_financ    LIKE juro_mora.pct_desp_financ,
           num_ult_bordero    LIKE empresa_cre.num_ult_bordero
                       END RECORD,
     p_existe_dados     CHAR(03)
 INITIALIZE p_bord_repres.*, p_existe_dados TO NULL 

 LET p_existe_dados = "NAO" 
 LET p_val_tot_ban = 0
 LET p_qtd_tot_ban = 0

  IF   p_qtd_rel = 0 
  THEN IF   log028_saida_relat(15,37) IS NULL 
       THEN RETURN
       END IF
  END IF
  LET p_qtd_rel = p_qtd_rel + 1
  MESSAGE " Inicio da emissao dos borderos para representantes " ATTRIBUTE(REVERSE) 

  IF   g_ies_ambiente = "W"
  THEN IF   p_ies_impressao = "S"
       THEN LET p_caminho4 = log150_procura_caminho("LST") CLIPPED, "cre9684.tmp"
            START REPORT cre162_rel_rep TO p_caminho4
#           START REPORT cre162_rel_rep TO PRINTER
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_rep TO p_nom_arquivo1
       END IF
  ELSE
       IF   p_ies_impressao = "S"
       THEN START REPORT cre162_rel_rep TO PIPE p_nom_arquivo
       ELSE LET p_nom_arquivo1 = log040_monta_sufixo(p_nom_arquivo,p_qtd_rel)
            START REPORT cre162_rel_rep TO p_nom_arquivo1
       END IF
  END IF

  FOREACH cl_dados_doc INTO l_p_dados_doc.*
     IF   l_p_dados_doc.ies_tip_portador = "B"
     THEN CONTINUE FOREACH
     END IF
     LET p_bord_repres.cod_empresa      = l_p_dados_doc.cod_empresa
     LET p_bord_repres.cod_cliente      = l_p_dados_doc.cod_cliente
     LET p_bord_repres.nom_cliente      = l_p_dados_doc.nom_cliente
     LET p_bord_repres.den_cidade_cli   = l_p_dados_doc.den_cidade_cliente
     LET p_bord_repres.dat_emis         = l_p_dados_doc.dat_emis         
     LET p_bord_repres.num_docum        = l_p_dados_doc.num_docum
     LET p_bord_repres.dat_vencto_s_desc= l_p_dados_doc.dat_vencto_s_desc

     CALL cre162_verifica_docum_emis_cot()
     LET p_bord_repres.val_bruto        = l_p_dados_doc.val_bruto

     SELECT cod_repres_1
      INTO p_bord_repres.cod_repres                      
       FROM docum
      WHERE cod_empresa   = l_p_dados_doc.cod_empresa
        AND num_docum     = l_p_dados_doc.num_docum
        AND ies_tip_docum = l_p_dados_doc.ies_tip_docum 
     LET  p_bord_repres.den_empresa       = NULL    
     LET  p_bord_repres.end_empresa       = NULL    
     LET  p_bord_repres.den_bairro_emp    = NULL 
     LET  p_bord_repres.uni_feder         = NULL 
     LET  p_bord_repres.cod_cep_emp       = NULL 
     LET  p_bord_repres.raz_social        = NULL 
     LET  p_bord_repres.cod_cep_repres    = NULL 
     LET  p_bord_repres.den_cidade_repres = NULL 
     LET  p_bord_repres.cod_uni_feder     = NULL 
     LET  p_bord_repres.pct_juro_legal    = NULL 
     LET  p_bord_repres.pct_desp_financ   = NULL 
     LET  p_bord_repres.num_ult_bordero   = NULL 
     IF   l_p_dados_doc.ies_tip_cobr = "S"
     THEN LET p_tip_cobr = " SIMPLES" 
     ELSE IF   l_p_dados_doc.ies_tip_cobr = "D"
          THEN LET p_tip_cobr = " DESCONTADA"
          ELSE IF   l_p_dados_doc.ies_tip_cobr = "C"
               THEN LET p_tip_cobr = " CAUCAO"
               END IF
          END IF
     END IF
     OUTPUT TO REPORT cre162_rel_rep(p_bord_repres.*,p_tip_cobr)
     LET p_existe_dados = "SIM"
     LET p_listou_bord_r = "SIM"
  END FOREACH
  FINISH REPORT cre162_rel_rep
  IF p_existe_dados = "NAO" 
  THEN MESSAGE " Nao foram encontradas informacoes para repres.,carteira e escr.cobr." ATTRIBUTE(REVERSE)
       IF g_ies_ambiente = "W" THEN
          LET comando = "lpdos.bat ", p_caminho4 CLIPPED, " ", p_nom_arquivo
          RUN comando 
       END IF
  ELSE MESSAGE " Emissao de borderos para representante terminada." ATTRIBUTE(REVERSE)
  END IF   
  IF   p_houve_erro = TRUE
  THEN ERROR " Transacao cancelada. "
  END IF 
  ERROR "Fim de processamento... " 
  IF   p_existe_dados = "SIM"
  THEN IF p_ies_impressao = "S" 
       THEN MESSAGE "Impressao do relatorio concluida ", " " ATTRIBUTE(REVERSE)
       ELSE MESSAGE "Relatorio gravado no arquivo ",p_nom_arquivo1, " " ATTRIBUTE(REVERSE)
       END IF
  END IF

END FUNCTION

#-----------------------------------------------#
 FUNCTION cre162_representante_bord(p_cod_repres)
#-----------------------------------------------#
DEFINE p_cod_repres        LIKE representante.cod_repres, 
       p_raz_social        LIKE representante.raz_social,
       p_cod_cep_repres    LIKE representante.cod_cep  , 
       p_den_cidade_repres LIKE cidades.den_cidade   ,
       p_cod_uni_feder     LIKE cidades.cod_uni_feder    
INITIALIZE p_raz_social,p_cod_cep_repres, p_den_cidade_repres,
           p_cod_uni_feder TO NULL
 
SELECT representante.raz_social,
       representante.cod_cep  , 
       cidades.den_cidade   ,
       cidades.cod_uni_feder 
INTO   p_raz_social   ,   
       p_cod_cep_repres , 
       p_den_cidade_repres,
       p_cod_uni_feder    
FROM representante,cidades
WHERE representante.cod_repres = p_cod_repres
  AND cidades.cod_cidade       = representante.cod_cidade
#IF sqlca.sqlcode <> 0        
#THEN LET p_houve_erro = TRUE
#END IF   { transacional }   
RETURN p_raz_social ,p_cod_cep_repres,p_den_cidade_repres,p_cod_uni_feder
END FUNCTION

#-------------------------------------------#
 REPORT cre162_rel_rep(p_bord_repres,p_tip_cobr)
#-------------------------------------------#
  DEFINE   p_bord_repres  RECORD
           cod_empresa        LIKE docum_emis.cod_empresa ,
           cod_cliente        LIKE docum_emis.cod_cliente,
           nom_cliente        LIKE clientes.nom_cliente, 
           den_cidade_cli     LIKE cidades.den_cidade,
           cod_repres         LIKE docum.cod_repres_1, 
           dat_emis           LIKE docum_emis.dat_emis,
           num_docum          LIKE docum_emis.num_docum,
           dat_vencto_s_desc  LIKE docum_emis.dat_vencto_s_desc,
           val_bruto          LIKE docum_emis.val_bruto,
           den_empresa        LIKE empresa.den_empresa,          
           end_empresa        LIKE empresa.end_empresa ,         
           den_bairro_emp     LIKE empresa.den_bairro,           
           den_munic          LIKE empresa.den_munic,            
           uni_feder          LIKE empresa.uni_feder,            
           cod_cep_emp        LIKE empresa.cod_cep,  
           raz_social         LIKE representante.raz_social,
           cod_cep_repres     LIKE representante.cod_cep,
           den_cidade_repres  LIKE cidades.den_cidade,
           cod_uni_feder      LIKE cidades.cod_uni_feder,
           pct_juro_legal     LIKE juro_mora.pct_juro_legal,
           pct_desp_financ    LIKE juro_mora.pct_desp_financ,
           num_ult_bordero    LIKE empresa_cre.num_ult_bordero
                       END RECORD,
           p_den_empresa      LIKE empresa.den_empresa,
           p_pct_juro_legal   LIKE juro_mora.pct_juro_legal,
           p_pct_desp_financ  LIKE juro_mora.pct_desp_financ,
           p_num_ult_bordero  LIKE empresa_cre.num_ult_bordero,
           p_tip_cobr         CHAR(11) 

 OUTPUT   LEFT MARGIN 0 
           TOP MARGIN 0 
        BOTTOM MARGIN 1 
        PAGE LENGTH 66 
  ORDER  BY p_bord_repres.cod_empresa,p_bord_repres.cod_repres
FORMAT    
{  
POL0099                                                                             EXTRAIDO EM dd/mm/yy  AS dd:dd:dd HRS.
+--------------------------------------------------------+     +-----------------------------------------------------------+
I                                                        I     I                                                           I
I        NOME DA EMPRESA                                 I     I   PARA USO DO - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  I
I        ENDERECO DA EMPRESA                             I     I                                                           I
I        89000-22  - CIDADE     - SC                     I     I      89200-22 - JOINVILLE - SC                            I
I                                                        I     I                                                           I
I                                                        I     I      CARTEIRA -                                           I 
I                                                        I     I                                                           I
I                                                        I     I                                                           I
I                                                        I     I                                                           I
+--------------------------------------------------------+     I                                                           I
                                                               I                                                           I 
                                                               I                                                           I
 AO - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - ####           I                                                           I
                                                               I                                                           I
                                                               +-----------------------------------------------------------+

OFERECEMOS NAS CONDICOES USUAIS DESSE REPRESENTANTE, O (S) TITULOS ABAIXO
DISCRIMINADO(S). REPONSABILIZANDO-NOS PELA SUA LEGITIMIDADE.
AUTORIZAMOS FAZER TODO MOVIMENTO CONTABIL, RELATIVO AO REGISTRO
E LIQUIDACAO, DIRETAMENTE EM NOSSA CONTA CORRENTE.               


      DATA     NUMERO       DATA                                                                                  VALOR DA 
   EMISSAO  DUPLICATA VENCIMENTO NOME DO SACADO                        PRACA                                     DUPLICATA   
---------- ---------- ---------- ------------------------------------- ------------------------------ --------------------
dd/mm/yyyy XXXXXXXXXX dd/mm/yyyy XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX #,###,###,###,##&.&&

                                                                                          TOTAL ....  #,###,###,###,##&.&&

NA FALTA DE PAGAMENTO NO VENCIMENTO COBRAR JUROS DE MORA DE ##&.&& % E DESPESAS FINANCEIRAS DE ##&.&& % AO MES
 
TEXTO DO TEXTOCRE
                                                                                        +----------------------------------+ 
                                                                                        I                                  I
CIDADE     , 20 DE OUTUBRO  DE A987                                                     I   NUMERO DO BORDERO ....   ###   I         
                                                                                        I                                  I
                                                                                        I   NUMERO DE DUPLICATAS..  ####   I 
                    ---------------------------------------                             I                                  I
                    NOME DA EMPRESA                                                     +----------------------------------+
} 
PAGE HEADER 
   CALL cre162_empresa_banco(p_bord_repres.cod_empresa)
         RETURNING p_den_empresa,
         p_bord_repres.end_empresa,p_bord_repres.den_bairro_emp , 
         p_bord_repres.den_munic,p_bord_repres.uni_feder,p_bord_repres.cod_cep_emp  
   CALL cre162_representante_bord(p_bord_repres.cod_repres) 
         RETURNING p_bord_repres.raz_social ,
         p_bord_repres.cod_cep_repres,p_bord_repres.den_cidade_repres,
         p_bord_repres.cod_uni_feder    
   PRINT COLUMN  01,"POL0099",
         COLUMN  85, " EXTRAIDO EM ",p_dat_proces_doc," AS ", TIME, " HRS." 
   PRINT COLUMN  01,"+--------------------------------------------------------+     +-----------------------------------------------------------+"
   PRINT COLUMN  01,"I                                                        I     I                                                           I" 
   PRINT COLUMN  01,"I   ",p_den_empresa,
         COLUMN  58,"I     I   PARA USO DO - ",p_bord_repres.raz_social,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I   ",p_bord_repres.end_empresa,
         COLUMN  58,"I     I",
         COLUMN 124,"I"
   PRINT COLUMN  01,"I   ",p_bord_repres.cod_cep_emp," - ",
                           p_bord_repres.den_munic, " -  ",
                           p_bord_repres.uni_feder ,
         COLUMN  58,"I     I    " ,p_bord_repres.cod_cep_repres,"  - ",
                                   p_bord_repres.den_cidade_repres," - ",
                                   p_bord_repres.cod_uni_feder,
         COLUMN 124,"I"
   PRINT COLUMN  01,"I                                                        I     I                                                           I"
   PRINT COLUMN  01,"I                                                        I     I      CARTEIRA -", p_tip_cobr, 
         COLUMN 124,"I"
   PRINT COLUMN  01,"I                                                        I     I                                                           I" 
   PRINT COLUMN  01,"I                                                        I     I                                                           I"
   PRINT COLUMN  01,"+--------------------------------------------------------+     I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  01," AO - ",p_bord_repres.raz_social," - ",
                             p_bord_repres.cod_repres USING "####" ,
         COLUMN  64,"I",
         COLUMN  124,"I"
   PRINT COLUMN  64,"I                                                           I"
   PRINT COLUMN  64,"+-----------------------------------------------------------+"
   PRINT 
   PRINT COLUMN  01,"OFERECEMOS NAS CONDICOES USUAIS DESSE REPRESENTANTE, O (S) TITULOS ABAIXO"
   PRINT COLUMN  01,"DISCRIMINADO(S). REPONSABILIZANDO-NOS PELA SUA LEGITIMIDADE."
   PRINT COLUMN  01,"AUTORIZAMOS FAZER TODO MOVIMENTO CONTABIL, RELATIVO AO REGISTRO"
   PRINT COLUMN  01,"E LIQUIDACAO, DIRETAMENTE EM NOSSA CONTA CORRENTE."
   SKIP 2 LINES
   PRINT COLUMN  01,"   DATA    NUMERO        DATA"
   PRINT COLUMN  01,"  EMISSAO  DUPLICATA  VENCIMENTO NOME DO SACADO                        PRACA                            VALOR DA DUPLICATA"
   PRINT COLUMN  01,"---------- ---------- ---------- ------------------------------------- ------------------------------ --------------------"
 
 ON EVERY ROW
   PRINT COLUMN  01,p_bord_repres.dat_emis USING "dd/mm/yyyy",
         COLUMN  12,p_bord_repres.num_docum ,
         COLUMN  23,p_bord_repres.dat_vencto_s_desc USING "dd/mm/yyyy",
         COLUMN  34,p_bord_repres.nom_cliente,
         COLUMN  72,p_bord_repres.den_cidade_cli,
         COLUMN 103,p_bord_repres.val_bruto USING "#,###,###,###,##&.&&"   
   LET p_val_tot_ban = p_val_tot_ban + p_bord_repres.val_bruto
   LET p_qtd_tot_ban = p_qtd_tot_ban  + 1 
  BEFORE GROUP OF p_bord_repres.cod_empresa
   CALL cre162_juro_mora_banco(p_bord_repres.cod_empresa,"CR$")
        RETURNING p_pct_juro_legal,p_pct_desp_financ 
  BEFORE GROUP OF p_bord_repres.cod_repres
   CALL cre162_empresa_cre_banco(p_bord_repres.cod_empresa)      
            RETURNING  p_num_ult_bordero
   SKIP TO TOP OF PAGE 
  AFTER GROUP OF p_bord_repres.cod_repres
   CALL cre162_busca_texto()
   PRINT
   PRINT COLUMN 91,"TOTAL ...   ",
         COLUMN 103, p_val_tot_ban USING "#,###,###,###,##&.&&"
   PRINT 
   LET p_val_tot_ban =  0
   PRINT COLUMN 01,"NA FALTA DE PAGAMENTO NO VENCIMENTO COBRAR JUROS DE MORA DE ",
                     p_pct_juro_legal USING "##&.&&",
                     " % E DESPESAS FINANCEIRAS DE ",
                     p_pct_desp_financ USING "##&.&&", " % AO MES. "
   SKIP 2 LINES
   CALL set_count(10)
   FOR p_ind = 1 TO 10
      PRINT COLUMN 01,p_texto[p_ind].des_linha
      IF  p_texto[p_ind].des_linha  IS NULL THEN
            EXIT FOR
      END IF
   END FOR
   NEED 8  LINES
   PRINT COLUMN 89,"+----------------------------------+"
   PRINT COLUMN 89,"I                                  I"
   PRINT COLUMN 01,p_bord_repres.den_munic CLIPPED,", ", DAY(p_dat_proces_doc) USING "##", " DE ",
                   p_mes_extenso , " DE " ,
                   YEAR(p_dat_proces_doc) USING "####",
         COLUMN 89,"I   NUMERO DO BORDERO ....  ",
                   p_num_ult_bordero USING "###",
         COLUMN 124,"I"
   PRINT COLUMN 89,"I                                  I"
   PRINT COLUMN 89,"I                                  I"
   PRINT COLUMN 89,"I   NUMERO DE DUPLICATAS .. ",
                   p_qtd_tot_ban USING "####",
         COLUMN 124,"I"
   PRINT COLUMN 21,"---------------------------------------",
         COLUMN 89,"I                                  I"
   PRINT COLUMN 21,p_den_empresa ,
         COLUMN 89,"+----------------------------------+"
   LET p_qtd_tot_ban = 0

END REPORT 

{ *** fim da rotina que emite bordero para representante ***  } 

#--------------------------------------#
 FUNCTION cre162_atualiza_docum_emis()
#--------------------------------------#
 WHENEVER ERROR CONTINUE
 LET p_houve_erro = FALSE
 CALL log085_transacao("BEGIN")
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
    IF sqlca.sqlcode = 0 THEN
    ELSE CALL log003_err_sql("ATUALIZACAO", "DOCUM_EMIS")
         LET p_houve_erro = TRUE 
         EXIT FOREACH
    END IF
 END FOREACH  
 WHENEVER ERROR STOP 
 IF   p_houve_erro = FALSE
 THEN RETURN TRUE
 ELSE RETURN FALSE
 END IF
END FUNCTION

#------------------------------------#
 FUNCTION cre162_busca_fone(p_empresa)
#------------------------------------#
 DEFINE p_empresa LIKE empresa.cod_empresa

 SELECT * INTO p_empresa_cre_txt.*
   FROM empresa_cre_txt
  WHERE cod_empresa = p_empresa
 IF sqlca.sqlcode <> 0 
 THEN LET p_empresa_cre_txt.parametros[31,45] = 15 SPACES  
      LET p_empresa_cre_txt.parametros[76,90] = 15 SPACES
 END IF
END FUNCTION
