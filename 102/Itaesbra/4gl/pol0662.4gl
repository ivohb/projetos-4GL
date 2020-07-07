#-------------------------------------------------------------------#
# PROGRAMA: pol0662                                                 #
# OBJETIVO: RELATÓRIO DE RASTREABILIDADE DE ENTRADA/SAIDA           #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 12/11/2007                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_status             SMALLINT,
          p_salto              SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          p_qtd_nf             SMALLINT,
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
          p_caminho            CHAR(080),
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          sql_stmt             CHAR(500),
          p_msg                CHAR(500)

   DEFINE p_cod_cliente        LIKE fat_nf_mestre.cliente,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_dat_emissao        DATE,
          p_cod_fornecedor     LIKE fornecedor.cod_fornecedor,
          p_cod_companhia      LIKE rastreabilidade.cod_companhia,
          p_raz_social         LIKE fornecedor.raz_social,
          p_num_nf             LIKE fat_nf_mestre.nota_fiscal,
          p_num_nf_imp         LIKE fat_nf_mestre.nota_fiscal,
          p_qtd_movto          LIKE rastreabilidade.qtd_movto,
          p_ser_nf             LIKE fat_nf_mestre.serie_nota_fiscal,
          p_num_lote           LIKE estoque_lote.num_lote,
          p_cod_item           LIKE item.cod_item,
          p_den_item           LIKE item.den_item_reduz,
          p_cod_unid_med       LIKE item.cod_unid_med,
          p_ies_tip_item       LIKE item.ies_tip_item,
          p_qtd_prod           DECIMAL(10,3),
          p_qtd_fat            DECIMAL(10,3),
          p_nom_item           CHAR(26),
          p_tip_rast           CHAR(01),
          p_nivel              CHAR(20),
          p_cod_rast           CHAR(01),
          p_den_rast           CHAR(07),
          p_considera          SMALLINT,
          p_cod_niv            SMALLINT,
          p_num_seq            SMALLINT

   DEFINE p_itens       ARRAY[500] OF RECORD
          num_nf        DECIMAL(6,0),
          cod_item      LIKE nf_item.cod_item,
          den_item      CHAR(18),
          num_lote      CHAR(15),
          qtd_movto     DECIMAL(10,3),
          ies_sel       CHAR(01)
   END RECORD

   DEFINE p_lote        ARRAY[500] OF RECORD
          num_lote      LIKE estoque_lote.num_lote,
          cod_item      LIKE item.cod_item,
          den_item      LIKE item.den_item_reduz
   END RECORD

   DEFINE pr_nf         ARRAY[500] OF RECORD
          ser_nf        LIKE nf_sup.ser_nf,
          dat_emis_nf   LIKE nf_sup.dat_emis_nf,
          num_aviso_rec LIKE nf_sup.num_aviso_rec,
          cod_companhia LIKE nf_sup.cod_fornecedor,
          raz_social    LIKE fornecedor.raz_social
   END RECORD

   DEFINE p_niv1        RECORD
         num_nf         DECIMAL(6,0),
         dat_emissao    DATE,
         cod_companhia  CHAR(15),
         cod_item       CHAR(15),
         num_lote       CHAR(15),
         qtd_movto      DECIMAL(10,3)
   END RECORD

   DEFINE p_niv2        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv3        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv4        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv5        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv6        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv7        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv8        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_niv9        RECORD
          cod_item      LIKE rastreabilidade.cod_item,
          num_lote      LIKE rastreabilidade.num_lote,
          qtd_movto     LIKE rastreabilidade.qtd_movto,
          num_nf        LIKE rastreabilidade.num_nota_fiscal,
          qtd_cons      LIKE rastreabilidade.qtd_consumida
   END RECORD

   DEFINE p_relat        RECORD
					num_seq        INTEGER,
					cod_niv        CHAR(20),
					cod_item       CHAR(15),
					den_item       CHAR(18),
					ies_tip_item   CHAR(01),
					cod_unid_med   CHAR(03),
					num_lote       CHAR(15),
					qtd_prod       DECIMAL(10,3),
					qtd_cons       DECIMAL(10,3),
					qtd_fat        DECIMAL(10,3),
					num_nf         DECIMAL(6,0),
					num_nfc        DECIMAL(6,0),
					dat_emissao    DATE,
					qtd_nota       DECIMAL(10,3),
					cod_companhia  CHAR(15),
					raz_social     CHAR(21)
   END RECORD

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0662-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0662.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0662_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0662_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0662") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0662 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Saída" "Ratreabilidade das Saidas"
         HELP 001 
         MESSAGE ""
         CALL pol0662_saida()
      COMMAND "Entrada" "Ratreabilidade das Entradas"
         HELP 002
         MESSAGE ""
         CALL pol0662_entrada()
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
  
   CLOSE WINDOW w_pol0662

END FUNCTION

#-----------------------#
FUNCTION pol0662_saida()
#-----------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06621") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06621 AT 4,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   #DISPLAY p_cod_empresa TO cod_empresa
   
   LET p_tip_rast = 'S'
   
   MENU "OPCAO"
      COMMAND "Nota Fiscal" "Rastreabilidade por Nota Fiscal"
         HELP 001 
         MESSAGE ""
         CALL pol0662_saida_nf()
      COMMAND "Lote" "Rastreabilidade por Lote"
         HELP 001 
         MESSAGE ""
         CALL pol0662_saida_lote()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0662_sobre()
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
  
   CLOSE WINDOW w_pol06621

END FUNCTION

#--------------------------#
FUNCTION pol0662_saida_nf()
#--------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06625") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06625 AT 6,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Parâmetros p/ Ratreabilidade"
         HELP 002
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF log005_seguranca(p_user,"VDP","pol0662","IN")  THEN
            IF pol0662_cria_temp() THEN
               IF pol0662_informa_nfs() THEN
                  ERROR "Parâmetros informados com sucesso !!!"
                  LET p_ies_cons = TRUE
                  NEXT OPTION "Listar"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            ELSE
               ERROR "Operação cancelada"
            END IF
         END IF 
      COMMAND "Listar" "Lista a Ratreabilidade"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0662","CO") THEN 
               CALL pol0662_escolhe_saida()
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!'
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

END FUNCTION

#---------------------------#
FUNCTION pol0662_saida_lote()
#---------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06623") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06623 AT 6,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Informar" "Informa Lote p/ Ratreabilidade"
         HELP 002
         MESSAGE ""
         LET p_ies_cons = FALSE
         IF log005_seguranca(p_user,"VDP","pol0662","IN")  THEN
            IF pol0662_cria_temp() THEN
               IF pol0662_informa_lote() THEN
                  ERROR "Parâmetros informados com sucesso !!!"
                  LET p_ies_cons = TRUE
                  NEXT OPTION "Listar"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            ELSE
               ERROR "Operação cancelada"
            END IF
         END IF 
      COMMAND "Listar" "Lista a Ratreabilidade"
         HELP 002
         MESSAGE ""
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0662","CO") THEN 
               IF log028_saida_relat(18,35) IS NOT NULL THEN
                  CALL pol0662_lista_lotes()
               END IF
            END IF
         ELSE
            ERROR 'Informe os parâmetros previamente!'
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

END FUNCTION

#-----------------------------#
FUNCTION pol0662_cria_temp()
#-----------------------------#

   WHENEVER ERROR CONTINUE
   
   DELETE FROM nf_rast_970

   IF SQLCA.SQLCODE = -206 THEN 
 
      CREATE TABLE nf_rast_970(
         num_nf        DECIMAL(6,0),
         dat_emissao   DATE,
         cod_companhia CHAR(15),
         cod_item      CHAR(15),
         num_lote      CHAR(15),
         qtd_movto     DECIMAL(10,3)
      )
         
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","NF_RAST_970")
         RETURN FALSE
      END IF
   END IF

   DELETE FROM nf_estrutura_970

   IF SQLCA.SQLCODE = -206 THEN 
 
      CREATE  TABLE nf_estrutura_970(
					num_seq        INTEGER,
					cod_niv        CHAR(20),
					cod_item       CHAR(15),
					den_item       CHAR(18),
					ies_tip_item   CHAR(01),
					cod_unid_med   CHAR(03),
					num_lote       CHAR(15),
					qtd_prod       DECIMAL(10,3),
					qtd_cons       DECIMAL(10,3),
					qtd_fat        DECIMAL(10,3),
					num_nf         DECIMAL(6,0),
					num_nfc        DECIMAL(6,0),
					dat_emissao    DATE,
					qtd_nota       DECIMAL(10,3),
					cod_companhia  CHAR(15),
					raz_social     CHAR(21)
      )

      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log003_err_sql("CRIACAO","NF_ESTRUTURA_970:1")
         RETURN FALSE
      END IF
   END IF

   RETURN TRUE

END FUNCTION


#----------------------------#
FUNCTION pol0662_informa_nfs()
#----------------------------#

   LET p_ies_cons = FALSE
   LET INT_FLAG = 0
   LET p_count = 0

   WHILE TRUE
      INITIALIZE p_num_nf, p_itens TO NULL
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
 
      INPUT p_num_nf
         WITHOUT DEFAULTS FROM num_nf

         AFTER FIELD num_nf    
            IF p_num_nf IS NOT NULL THEN
               SELECT UNIQUE num_nf
                 FROM nf_rast_970
                WHERE num_nf = p_num_nf
               IF STATUS = 0 THEN
                  ERROR 'NF de saída já informada!'
                  NEXT FIELD num_nf
               ELSE
                  IF STATUS <> 100 THEN
                     CALL log003_err_sql("LENDO","NF_RAST_970")
                     RETURN FALSE
                  END IF
               END IF
               
               IF NOT pol0662_le_nf_mestre() THEN
                  RETURN FALSE
               END IF

               IF STATUS = 100 THEN
                  ERROR 'NF de Saída Inexistente!'
                  NEXT FIELD num_nf
               END IF
               
               DISPLAY p_dat_emissao TO dat_emissao
               DISPLAY p_nom_cliente TO nom_cliente

               SELECT UNIQUE num_nota_fiscal
                 FROM rastreabilidade 
                WHERE cod_empresa     = p_cod_empresa
                  AND num_nota_fiscal = p_num_nf
                  AND ies_origem_info = 'F'

               IF STATUS = 100 THEN
                  ERROR 'NF Não Encontrada na Tabela de Rastreabilidade'
                  NEXT FIELD num_nf
               ELSE
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql("LENDO","RASTREABILIDADE:1")
                     RETURN FALSE
                  END IF
               END IF

               LET p_count = p_count + 1
            END IF
            
      END INPUT

      IF INT_FLAG THEN
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         RETURN FALSE
      END IF

      IF p_num_nf IS NULL THEN
         EXIT WHILE
      END IF

      IF NOT pol0662_sel_itens_nf('F') THEN
         RETURN FALSE
      END IF

   END WHILE
   
   IF p_count > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------#
FUNCTION pol0662_informa_lote()
#------------------------------#

   LET p_index = 1
   
   INITIALIZE p_lote TO NULL
   
   INPUT ARRAY p_lote
      WITHOUT DEFAULTS FROM s_lote.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD num_lote

         IF p_lote[p_index].num_lote IS NOT NULL THEN
 
            SELECT UNIQUE cod_item
              INTO p_lote[p_index].cod_item
              FROM rastreabilidade
             WHERE cod_empresa     = p_cod_empresa
               AND num_lote        = p_lote[p_index].num_lote
               AND ies_origem_info = 'F'

            IF STATUS = 100 THEN
               ERROR 'Lote sem dados p/ rastreabilidade!'
               NEXT FIELD num_lote
            ELSE
               IF STATUS <> 0 THEN
                  CALL log003_err_sql("LENDO","rastreabilidade:1")
                  RETURN FALSE
               END IF
            END IF

            IF NOT pol0662_le_descricao() THEN
               RETURN FALSE
            END IF
  
            DISPLAY p_lote[p_index].cod_item TO s_lote[s_index].cod_item
            DISPLAY p_lote[p_index].den_item TO s_lote[s_index].den_item
         ELSE
            IF FGL_LASTKEY() <> 2000 AND FGL_LASTKEY() <> 2016 THEN
               ERROR 'Campo c/ preenchimento obrigatório!!!'
               NEXT FIELD num_lote
            END IF
         END IF
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0662_saida_grava_lotes() THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(num_nf)
     INTO p_count
     FROM nf_rast_970
   
   IF p_count = 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#-----------------------------#
FUNCTION pol0662_le_descricao()
#-----------------------------#

   SELECT den_item_reduz
     INTO p_lote[p_index].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_lote[p_index].cod_item

   IF STATUS = 100 THEN
      LET p_lote[p_index].den_item = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","ITEM")
         RETURN FALSE
      END IF
   END IF
 
   RETURN TRUE
   
END FUNCTION
     



#-----------------------#
FUNCTION pol0662_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol06623
         IF p_codigo IS NOT NULL THEN
           LET p_itens[p_index].cod_item = p_codigo
           DISPLAY p_codigo TO s_itens[s_index].cod_item
         END IF

   END CASE

END FUNCTION

#-----------------------------#
FUNCTION pol0662_le_nf_mestre()
#-----------------------------#

   SELECT serie_nota_fiscal,
          DATE(dat_hor_emissao),
          cliente
     INTO p_ser_nf,
          p_dat_emissao, 
          p_cod_cliente
     FROM fat_nf_mestre
    WHERE empresa     = p_cod_empresa
      AND nota_fiscal = p_num_nf
   
   IF STATUS = 100 THEN
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","NF_MESTRE:1")
         RETURN FALSE
      END IF
   END IF

   IF NOT pol0662_le_cliente() THEN
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------------#
FUNCTION pol0662_le_cliente()
#---------------------------#

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cod_cliente

   IF STATUS = 100 THEN
      LET p_nom_cliente = NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","CLIENTES")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION


#----------------------------------#
FUNCTION pol0662_sel_itens_nf(p_par)
#----------------------------------#

   DEFINE p_par    CHAR(01),
          p_qtd_nf SMALLINT
   
   INITIALIZE p_itens TO NULL
   LET p_index = 1

   IF p_par = 'R' THEN
      SELECT COUNT(num_nf_cons)
        INTO p_qtd_nf
        FROM rastreabilidade 
       WHERE cod_empresa     = p_cod_empresa
         AND num_nota_fiscal = p_num_nf
         AND num_nf_cons IS NOT NULL 

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","RASTREABILIDADE:3")
         RETURN FALSE
      END IF

      IF p_qtd_nf = 0 THEN
         LET sql_stmt = "SELECT num_nota_fiscal, cod_item, ",
                        "       num_lote, qtd_movto, cod_companhia ",
                        "  FROM rastreabilidade ",
                        " WHERE cod_empresa     = '",p_cod_empresa,"' ",
                        "   AND num_nota_fiscal = '",p_num_nf,"' ",
                        "   AND ies_origem_info = 'R' "
      ELSE
         LET sql_stmt = "SELECT num_nf_cons, cod_item_cons, num_lote_cons, ",
                        "       SUM(qtd_consumida), cod_companhia ",
                        "  FROM rastreabilidade ",
                        " WHERE cod_empresa     = '",p_cod_empresa,"' ",
                        "   AND num_nota_fiscal = '",p_num_nf,"' ",
                        "   AND ies_origem_info = 'R' ",
                        " GROUP BY num_nf_cons, cod_item_cons, ",
                        "          num_lote_cons, cod_companhia "
      END IF                        
   ELSE
      LET sql_stmt = "SELECT num_nota_fiscal, cod_item, num_lote, ",
                     "       qtd_movto, cod_companhia ",
                     "  FROM rastreabilidade ",
                     " WHERE cod_empresa     = '",p_cod_empresa,"' ",
                     "   AND num_nota_fiscal = '",p_num_nf,"' ",
                     "   AND ies_origem_info = 'F' "
   END IF
   

   PREPARE var_query FROM sql_stmt   

   DECLARE cq_itens_nf CURSOR FOR var_query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("PREPARE","RASTREABILIDADE")
      RETURN FALSE
   END IF

   FOREACH cq_itens_nf INTO 
           p_itens[p_index].num_nf,
           p_itens[p_index].cod_item,
           p_itens[p_index].num_lote,
           p_itens[p_index].qtd_movto,
           p_cod_companhia

      IF NOT pol0662_le_item(p_itens[p_index].cod_item) THEN
         RETURN FALSE
      END IF
      
      LET p_itens[p_index].den_item = p_den_item
      LET p_itens[p_index].ies_sel = 'S'
      LET p_index = p_index + 1
   
   END FOREACH
   
   IF p_index = 1 THEN
      RETURN FALSE
   END IF
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY p_itens
      WITHOUT DEFAULTS FROM s_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD ies_sel
         IF p_itens[p_index].cod_item IS NOT NULL THEN
            IF p_itens[p_index].ies_sel MATCHES '[SN]' THEN
            ELSE
               ERROR "Valor ilegal p/ o campo !!!"
               NEXT FIELD ies_sel
            END IF
         END IF

   END INPUT 

   IF INT_FLAG THEN
      LET p_count = p_count - 1
      RETURN TRUE
   END IF
   
   IF NOT pol0662_grava_nf() THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF   

END FUNCTION

#--------------------------#
FUNCTION pol0662_grava_nf()
#--------------------------#

   LET p_considera = FALSE

   FOR p_ind = 1 TO ARR_COUNT()
    IF p_itens[p_ind].cod_item IS NOT NULL THEN
       IF p_itens[p_ind].ies_sel = 'S' THEN
          INSERT INTO nf_rast_970
             VALUES(p_itens[p_ind].num_nf, 
                    p_dat_emissao,
                    p_cod_companhia,
                    p_itens[p_ind].cod_item,
                    p_itens[p_ind].num_lote,
                    p_itens[p_ind].qtd_movto)
   
          IF STATUS <> 0 THEN
             CALL log003_err_sql("INSERINDO","NF_RAST_970")
             RETURN FALSE
          END IF

          LET p_considera = TRUE
       END IF
    END IF
   END FOR
   
   IF NOT p_considera THEN
      LET p_count = p_count - 1
   END IF
   
   RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol0662_saida_grava_lotes()
#----------------------------------#

   LET p_considera = FALSE
   
   FOR p_ind = 1 TO ARR_COUNT()
      IF p_lote[p_ind].num_lote IS NOT NULL THEN
         IF NOT pol0662_insere_lote() THEN
            RETURN FALSE
         END IF
      END IF
   END FOR

   RETURN TRUE
      
END FUNCTION

#----------------------------#
FUNCTION pol0662_insere_lote()
#----------------------------#

   DECLARE cq_lotes CURSOR FOR
    SELECT num_nota_fiscal,
           qtd_movto,
           cod_companhia,
           dat_movto
      FROM rastreabilidade
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item        = p_lote[p_ind].cod_item
       AND num_lote        = p_lote[p_ind].num_lote
       AND ies_origem_info = 'F'

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEDNO","RASTREABILIDADE:3")
         RETURN FALSE
      END IF

   FOREACH cq_lotes INTO 
           p_num_nf, 
           p_qtd_movto, 
           p_cod_companhia,
           p_dat_emissao
   
      INSERT INTO nf_rast_970
       VALUES(p_num_nf,
              p_dat_emissao,
              p_cod_companhia,
              p_lote[p_ind].cod_item,
              p_lote[p_ind].num_lote,
              p_qtd_movto)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERINDO","NF_RAST_970")
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION


#----------------------------------#
FUNCTION pol0662_insere_estrutura()
#----------------------------------#

   LET p_num_seq = p_num_seq + 1

   DISPLAY p_num_seq AT 18,36

   IF NOT pol0662_le_item(p_relat.cod_item) THEN
      RETURN FALSE
   END IF

   LET p_relat.num_seq       = p_num_seq
   LET p_relat.cod_niv       = p_nivel
   LET p_relat.num_nf        = p_niv1.num_nf
	 LET p_relat.den_item      = p_den_item
	 LET p_relat.ies_tip_item  = p_ies_tip_item
	 LET p_relat.cod_unid_med  = p_cod_unid_med

   INSERT INTO nf_estrutura_970
    VALUES(p_relat.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERINDO","NF_ESTRUTURA_970:3")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#-------------------------------------------#
FUNCTION pol0662_soma(l_cod_item, l_num_lote)
#-------------------------------------------#

   DEFINE l_cod_item LIKE item.cod_item,
          l_num_lote LIKE estoque_lote.num_lote

   LET p_relat.cod_item    = l_cod_item
   LET p_relat.num_lote    = l_num_lote

   SELECT SUM(qtd_movto) 
     INTO p_relat.qtd_prod
     FROM rastreabilidade
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item        = l_cod_item
      AND num_lote        = l_num_lote
      AND ies_origem_info IN ('P','R')

   IF STATUS <> 0 THEN
      CALL log003_err_sql('LENDO','RASTREABILIDADE24')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
FUNCTION pol0662_processa_saida()
#--------------------------------#

   MESSAGE 'Processando Rastreabilidade...' ATTRIBUTE(REVERSE)
   LET p_num_seq = 0
   
   INITIALIZE p_niv1, p_nivel TO NULL

   DELETE FROM nf_estrutura_970

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETANDO","NF_ESTRUTURA_970:2")
      RETURN FALSE
   END IF

   DECLARE cd_niv1 CURSOR FOR
    SELECT *
      FROM nf_rast_970 
     ORDER BY num_nf, 
              cod_item, 
              num_lote

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LENDO","NF_RAST_970")
       RETURN FALSE
    END IF

   FOREACH cd_niv1 INTO p_niv1.*
      
      INITIALIZE p_relat TO NULL
      
      LET p_cod_cliente = p_niv1.cod_companhia
      
      IF NOT pol0662_le_cliente() THEN
         RETURN FALSE
      END IF
      
      LET p_relat.cod_companhia = p_niv1.cod_companhia
      LET p_relat.raz_social    = p_nom_cliente

      IF NOT pol0662_soma(p_niv1.cod_item, p_niv1.num_lote) THEN
         RETURN FALSE
      END IF

      SELECT SUM(qtd_movto) 
        INTO p_relat.qtd_fat
        FROM rastreabilidade
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_niv1.cod_item
         AND num_lote    = p_niv1.num_lote
         AND ies_origem_info = 'F'

      IF STATUS <> 0 THEN
         CALL log003_err_sql('LENDO',"RASTREABILIDADE:4")
         RETURN FALSE
      END IF

      LET p_nivel             = '01'
      LET p_relat.dat_emissao = p_niv1.dat_emissao
      LET p_relat.qtd_nota    = p_niv1.qtd_movto
      
      IF NOT pol0662_insere_estrutura() THEN
         RETURN FALSE
      END IF
      
      SELECT COUNT(cod_item_cons)
        INTO p_count
        FROM rastreabilidade
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item        = p_niv1.cod_item
         AND num_lote        = p_niv1.num_lote
         AND ies_origem_info = 'P'

      IF p_count = 0 THEN
         LET p_nivel = '  02'
         IF NOT pol0662_le_tipo_r(p_niv1.cod_item,p_niv1.num_lote) THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF            
      
      INITIALIZE p_niv2 TO NULL
      DECLARE cd_niv2 CURSOR FOR 
       SELECT cod_item_cons,
              num_lote_cons,
              qtd_consumida,
              num_nf_cons
         FROM rastreabilidade
        WHERE cod_empresa     = p_cod_empresa
          AND cod_item        = p_niv1.cod_item
          AND num_lote        = p_niv1.num_lote
          AND ies_origem_info = 'P'

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LENDO","RASTREABILIDADE:5")
          RETURN FALSE
       END IF
   
      FOREACH cd_niv2 INTO p_niv2.*
         
         INITIALIZE p_relat TO NULL

         IF NOT pol0662_soma(p_niv2.cod_item, p_niv2.num_lote) THEN
            RETURN FALSE
         END IF

         LET p_nivel             = '  02'
         LET p_relat.qtd_cons    = p_niv2.qtd_movto
         LET p_relat.num_nfc     = p_niv2.num_nf

         IF NOT pol0662_insere_estrutura() THEN
            RETURN FALSE
         END IF

         SELECT COUNT(cod_item_cons)
           INTO p_count
           FROM rastreabilidade
          WHERE cod_empresa     = p_cod_empresa
            AND cod_item        = p_niv2.cod_item
            AND num_lote        = p_niv2.num_lote
            AND ies_origem_info = 'P'

         IF p_count = 0 THEN
            LET p_nivel = '    03'
            IF NOT pol0662_le_tipo_r(p_niv2.cod_item,p_niv2.num_lote) THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF            
         
         INITIALIZE p_niv3 TO NULL
         DECLARE cd_niv3 CURSOR FOR 
          SELECT cod_item_cons,
                 num_lote_cons,
                 qtd_consumida,
                 num_nf_cons
            FROM rastreabilidade
           WHERE cod_empresa     = p_cod_empresa
             AND cod_item        = p_niv2.cod_item
             AND num_lote        = p_niv2.num_lote
             AND ies_origem_info = 'P'

          IF STATUS <> 0 THEN
             CALL log003_err_sql("LENDO","RASTREABILIDADE:6")
             RETURN FALSE
          END IF
   
         FOREACH cd_niv3 INTO p_niv3.*

            INITIALIZE p_relat TO NULL
 
            IF NOT pol0662_soma(p_niv3.cod_item, p_niv3.num_lote) THEN
               RETURN FALSE
            END IF

            LET p_nivel             = '    03'
            LET p_relat.qtd_cons    = p_niv3.qtd_movto
            LET p_relat.num_nfc     = p_niv3.num_nf

            IF NOT pol0662_insere_estrutura() THEN
               RETURN FALSE
            END IF
      
            SELECT COUNT(cod_item_cons)
              INTO p_count
              FROM rastreabilidade
             WHERE cod_empresa     = p_cod_empresa
               AND cod_item        = p_niv3.cod_item
               AND num_lote        = p_niv3.num_lote
               AND ies_origem_info = 'P'

            IF p_count = 0 THEN
               LET p_nivel = '      04'
               IF NOT pol0662_le_tipo_r(p_niv3.cod_item,p_niv3.num_lote) THEN
                  RETURN FALSE
               END IF
               CONTINUE FOREACH
            END IF            
            
            INITIALIZE p_niv4 TO NULL
            DECLARE cd_niv4 CURSOR FOR 
             SELECT cod_item_cons,
                    num_lote_cons,
                    qtd_consumida,
                    num_nf_cons
               FROM rastreabilidade
              WHERE cod_empresa     = p_cod_empresa
                AND cod_item        = p_niv3.cod_item
                AND num_lote        = p_niv3.num_lote
                AND ies_origem_info = 'P'

             IF STATUS <> 0 THEN
                CALL log003_err_sql("LENDO","RASTREABILIDADE:7")
                RETURN FALSE
             END IF
   
            FOREACH cd_niv4 INTO p_niv4.*

               INITIALIZE p_relat TO NULL
 
               IF NOT pol0662_soma(p_niv4.cod_item, p_niv4.num_lote) THEN
                  RETURN FALSE
               END IF

               LET p_nivel             = '      04'
               LET p_relat.qtd_cons    = p_niv4.qtd_movto
               LET p_relat.num_nfc     = p_niv4.num_nf

               IF NOT pol0662_insere_estrutura() THEN
                  RETURN FALSE
               END IF
      
               SELECT COUNT(cod_item_cons)
                 INTO p_count
                 FROM rastreabilidade
                WHERE cod_empresa     = p_cod_empresa
                  AND cod_item        = p_niv4.cod_item
                  AND num_lote        = p_niv4.num_lote
                  AND ies_origem_info = 'P'

               IF p_count = 0 THEN
                  LET p_nivel = '        05'
                  IF NOT pol0662_le_tipo_r(p_niv4.cod_item,p_niv4.num_lote) THEN
                     RETURN FALSE
                  END IF
                  CONTINUE FOREACH
               END IF            

               INITIALIZE p_niv5 TO NULL
               DECLARE cd_niv5 CURSOR FOR 
                SELECT cod_item_cons,
                       num_lote_cons,
                       qtd_consumida,
                       num_nf_cons
                  FROM rastreabilidade
                 WHERE cod_empresa     = p_cod_empresa
                   AND cod_item        = p_niv4.cod_item
                   AND num_lote        = p_niv4.num_lote
                   AND ies_origem_info = 'P'

                IF STATUS <> 0 THEN
                   CALL log003_err_sql("LENDO","RASTREABILIDADE:9")
                   RETURN FALSE
                END IF
   
               FOREACH cd_niv5 INTO p_niv5.*

                  INITIALIZE p_relat TO NULL
 
                  IF NOT pol0662_soma(p_niv5.cod_item, p_niv5.num_lote) THEN
                     RETURN FALSE
                  END IF

                  LET p_nivel             = '        05'
                  LET p_relat.qtd_cons    = p_niv5.qtd_movto
                  LET p_relat.num_nfc     = p_niv5.num_nf

                  IF NOT pol0662_insere_estrutura() THEN
                     RETURN FALSE
                  END IF
      
                  SELECT COUNT(cod_item_cons)
                    INTO p_count
                    FROM rastreabilidade
                   WHERE cod_empresa     = p_cod_empresa
                     AND cod_item        = p_niv5.cod_item
                     AND num_lote        = p_niv5.num_lote
                     AND ies_origem_info = 'P'

                  IF p_count = 0 THEN
                     LET p_nivel = '          06'
                     IF NOT pol0662_le_tipo_r(p_niv5.cod_item,p_niv5.num_lote) THEN
                        RETURN FALSE
                     END IF
                     CONTINUE FOREACH
                  END IF            

                  INITIALIZE p_niv6 TO NULL
                  DECLARE cd_niv6 CURSOR FOR 
                   SELECT cod_item_cons,
                          num_lote_cons,
                          qtd_consumida,
                          num_nf_cons
                     FROM rastreabilidade
                    WHERE cod_empresa     = p_cod_empresa
                      AND cod_item        = p_niv5.cod_item
                      AND num_lote        = p_niv5.num_lote
                      AND ies_origem_info = 'P'

                   IF STATUS <> 0 THEN
                      CALL log003_err_sql("LENDO","RASTREABILIDADE:11")
                      RETURN FALSE
                   END IF
   
                  FOREACH cd_niv6 INTO p_niv6.*

                     INITIALIZE p_relat TO NULL
 
                     IF NOT pol0662_soma(p_niv6.cod_item, p_niv6.num_lote) THEN
                        RETURN FALSE
                     END IF

                     LET p_nivel             = '          06'
                     LET p_relat.qtd_cons    = p_niv6.qtd_movto
                     LET p_relat.num_nfc     = p_niv6.num_nf

                     IF NOT pol0662_insere_estrutura() THEN
                        RETURN FALSE
                     END IF

                     SELECT COUNT(cod_item_cons)
                       INTO p_count
                       FROM rastreabilidade
                      WHERE cod_empresa     = p_cod_empresa
                        AND cod_item        = p_niv6.cod_item
                        AND num_lote        = p_niv6.num_lote
                        AND ies_origem_info = 'P'

                     IF p_count = 0 THEN
                        LET p_nivel = '            07'
                        IF NOT pol0662_le_tipo_r(p_niv6.cod_item,p_niv6.num_lote) THEN
                           RETURN FALSE
                        END IF
                        CONTINUE FOREACH
                     END IF            

                     INITIALIZE p_niv7 TO NULL
                     DECLARE cd_niv7 CURSOR FOR 
                      SELECT cod_item_cons,
                             num_lote_cons,
                             qtd_consumida,
                             num_nf_cons
                        FROM rastreabilidade
                       WHERE cod_empresa     = p_cod_empresa
                         AND cod_item        = p_niv6.cod_item
                         AND num_lote        = p_niv6.num_lote
                         AND ies_origem_info = 'P'

                      IF STATUS <> 0 THEN
                         CALL log003_err_sql("LENDO","RASTREABILIDADE:13")
                         RETURN FALSE
                      END IF
   
                     FOREACH cd_niv7 INTO p_niv7.*
      
                        INITIALIZE p_relat TO NULL
 
                        IF NOT pol0662_soma(p_niv7.cod_item, p_niv7.num_lote) THEN
                           RETURN FALSE
                        END IF

                        LET p_nivel             = '            07'
                        LET p_relat.qtd_cons    = p_niv7.qtd_movto
                        LET p_relat.num_nfc     = p_niv7.num_nf

                        IF NOT pol0662_insere_estrutura() THEN
                           RETURN FALSE
                        END IF

                        SELECT COUNT(cod_item_cons)
                          INTO p_count
                          FROM rastreabilidade
                         WHERE cod_empresa     = p_cod_empresa
                           AND cod_item        = p_niv7.cod_item
                           AND num_lote        = p_niv7.num_lote
                           AND ies_origem_info = 'P'

                        IF p_count = 0 THEN
                           LET p_nivel = '              08'
                           IF NOT pol0662_le_tipo_r(p_niv7.cod_item,p_niv7.num_lote) THEN
                              RETURN FALSE
                           END IF
                           CONTINUE FOREACH
                        END IF            

                        INITIALIZE p_niv8 TO NULL
                        DECLARE cd_niv8 CURSOR FOR 
                         SELECT cod_item_cons,
                                num_lote_cons,
                                qtd_consumida,
                                num_nf_cons
                           FROM rastreabilidade
                          WHERE cod_empresa     = p_cod_empresa
                            AND cod_item        = p_niv7.cod_item
                            AND num_lote        = p_niv7.num_lote
                            AND ies_origem_info = 'P'

                         IF STATUS <> 0 THEN
                            CALL log003_err_sql("LENDO","RASTREABILIDADE:15")
                            RETURN FALSE
                         END IF
   
                        FOREACH cd_niv8 INTO p_niv8.*
      
                           INITIALIZE p_relat TO NULL
 
                           IF NOT pol0662_soma(p_niv8.cod_item, p_niv8.num_lote) THEN
                              RETURN FALSE
                           END IF

                           LET p_nivel             = '              08'
                           LET p_relat.qtd_cons    = p_niv8.qtd_movto
                           LET p_relat.num_nfc     = p_niv8.num_nf

                           IF NOT pol0662_insere_estrutura() THEN
                              RETURN FALSE
                           END IF

                           SELECT COUNT(cod_item_cons)
                             INTO p_count
                             FROM rastreabilidade
                            WHERE cod_empresa     = p_cod_empresa
                              AND cod_item        = p_niv8.cod_item
                              AND num_lote        = p_niv8.num_lote
                              AND ies_origem_info = 'P'

                           IF p_count = 0 THEN
                              LET p_nivel = '                09'
                              IF NOT pol0662_le_tipo_r(p_niv8.cod_item,p_niv8.num_lote) THEN
                                 RETURN FALSE
                              END IF
                              CONTINUE FOREACH
                           END IF            

                           INITIALIZE p_niv9 TO NULL
                           DECLARE cd_niv9 CURSOR FOR 
                            SELECT cod_item_cons,
                                   num_lote_cons,
                                   qtd_consumida,
                                   num_nf_cons
                              FROM rastreabilidade
                             WHERE cod_empresa     = p_cod_empresa
                               AND cod_item        = p_niv8.cod_item
                               AND num_lote        = p_niv8.num_lote
                               AND ies_origem_info = 'P'

                            IF STATUS <> 0 THEN
                               CALL log003_err_sql("LENDO","RASTREABILIDADE:17")
                               RETURN FALSE
                            END IF
   
                           FOREACH cd_niv9 INTO p_niv9.*
      
                              INITIALIZE p_relat TO NULL
 
                              IF NOT pol0662_soma(p_niv9.cod_item, p_niv9.num_lote) THEN
                                 RETURN FALSE
                              END IF

                              LET p_nivel             = '                09'
                              LET p_relat.qtd_cons    = p_niv9.qtd_movto
                              LET p_relat.num_nfc     = p_niv9.num_nf

                              IF NOT pol0662_insere_estrutura() THEN
                                 RETURN FALSE
                              END IF

                              LET p_nivel = '                  10'
                              IF NOT pol0662_le_tipo_f(p_niv9.cod_item,p_niv9.num_lote) THEN
                                 RETURN FALSE
                              END IF
                              
                           END FOREACH
                           
                        END FOREACH
                        
                     END FOREACH
                     
                  END FOREACH
                  
               END FOREACH        

            END FOREACH

         END FOREACH

      END FOREACH

   END FOREACH
   
   RETURN TRUE              

END FUNCTION

#-------------------------------------------------#
FUNCTION pol0662_le_tipo_r(p_cod_item, p_num_lote)
#-------------------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item,
          p_num_lote LIKE estoque_lote.num_lote

   INITIALIZE p_relat TO NULL
             
   DECLARE cq_niv_r CURSOR FOR 
    SELECT num_nota_fiscal,
           cod_companhia,
           qtd_movto,
           cod_item_cons,
           num_lote_cons,
           qtd_consumida,
           num_nf_cons
      FROM rastreabilidade
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item        = p_cod_item
       AND num_lote        = p_num_lote
       AND ies_origem_info = 'R'

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LENDO","RASTREABILIDADE:19")
          RETURN FALSE
       END IF
   
   FOREACH cq_niv_r INTO 
           p_relat.num_nfc,
           p_relat.cod_companhia,
           p_relat.qtd_nota,
           p_relat.cod_item,
           p_relat.num_lote,
           p_relat.qtd_cons,
           p_num_nf

      IF NOT pol0662_le_nf_sup(p_relat.num_nfc) THEN
         RETURN FALSE
      END IF

      UPDATE nf_estrutura_970
         SET num_nfc       = p_relat.num_nfc,
             dat_emissao   = p_relat.dat_emissao,
             qtd_nota      = p_relat.qtd_nota,
             cod_companhia = p_relat.cod_companhia,
             raz_social    = p_relat.raz_social
       WHERE num_seq = p_num_seq
      
      LET p_num_seq = p_num_seq + 1
      
      IF p_relat.num_nfc IS NOT NULL THEN
         IF NOT pol0662_le_nf_mestre() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET p_relat.num_nfc       = p_num_nf
      LET p_relat.cod_companhia = p_cod_cliente
      LET p_relat.raz_social    = p_nom_cliente
      LET p_relat.dat_emissao   = p_dat_emissao
      
      IF NOT pol0662_insere_estrutura() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE p_relat TO NULL
            
   END FOREACH        

   RETURN TRUE

END FUNCTION


#-------------------------------#
FUNCTION pol0662_le_nf_sup(p_nf)
#-------------------------------#

   DEFINE p_nf DECIMAL(6,0)
   
   SELECT a.dat_emis_nf,
          b.raz_social
     INTO p_relat.dat_emissao,
          p_relat.raz_social
     FROM nf_sup a,
          fornecedor b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.num_nf         = p_nf
      AND a.cod_fornecedor = p_relat.cod_companhia
      AND b.cod_fornecedor = a.cod_fornecedor
      
   IF STATUS <> 0 AND STATUS <> 100 THEN
     CALL log003_err_sql("LENDO","NF_SUP/FORNECEDOR")
     RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol0662_escolhe_saida()
#-------------------------------#
   
   IF log005_seguranca(p_user,"VDP","pol0662","MO") THEN
      IF log028_saida_relat(18,35) IS NOT NULL THEN
         IF p_tip_rast = 'S' THEN
            IF NOT pol0662_processa_saida() THEN
               RETURN
            END IF
         ELSE
            IF NOT pol0662_processa_entrada() THEN
               RETURN
            END IF
         END IF
         IF p_ies_impressao = "S" THEN
            CALL log150_procura_caminho ('LST') RETURNING p_caminho
            LET p_caminho = p_caminho CLIPPED, 'pol0662.tmp'
            IF p_tip_rast = 'S' THEN
               START REPORT pol0662_relats  TO p_caminho
            ELSE
               START REPORT pol0662_relate  TO p_caminho
            END IF
         ELSE
            IF p_tip_rast = 'S' THEN
               START REPORT pol0662_relats  TO p_nom_arquivo
            ELSE
               START REPORT pol0662_relate  TO p_nom_arquivo
            END IF
         END IF

         CALL pol0662_emite_relatorio() RETURNING p_status

         IF p_tip_rast = 'S' THEN
            FINISH REPORT pol0662_relats
         ELSE
            FINISH REPORT pol0662_relate
         END IF

         IF NOT p_status THEN
            RETURN
         END IF

         IF p_count = 0 THEN
            ERROR "Nao Existem Dados para serem Listados" 
         ELSE
            ERROR "Relatorio Processado com Sucesso" 
         END IF

      ELSE
        RETURN
      END IF         
                                                        
      IF p_ies_impressao = "S" THEN
         MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo ATTRIBUTE(REVERSE)
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo, " " ATTRIBUTE(REVERSE)
      END IF                              
   END IF 

END FUNCTION

#-----------------------------------#
 FUNCTION pol0662_emite_relatorio()
#-----------------------------------#

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_count = 0
   LET p_num_nf = 0

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   DECLARE cq_relat CURSOR FOR
    SELECT *
      FROM nf_estrutura_970
     ORDER BY num_seq

   FOREACH cq_relat INTO p_relat.*
   
      IF p_tip_rast = 'S' THEN
         OUTPUT TO REPORT pol0662_relats(p_num_nf)
      ELSE
         OUTPUT TO REPORT pol0662_relate(p_num_nf)
      END IF
      
      LET p_count = p_count + 1
      
   END FOREACH

   RETURN TRUE
   
END FUNCTION

#----------------------------------------#
FUNCTION pol0662_le_item(m_cod_item)
#----------------------------------------#

   DEFINE m_cod_item LIKE item.cod_item

   SELECT den_item_reduz,
          den_item,
          ies_tip_item,
          cod_unid_med
     INTO p_den_item,
          p_nom_item,
          p_ies_tip_item,
          p_cod_unid_med
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = m_cod_item

   IF STATUS = 100 THEN
      INITIALIZE p_den_item, p_nom_item, p_ies_tip_item, p_cod_unid_med TO  NULL
   ELSE
      IF STATUS <> 0 THEN
         CALL log003_err_sql("LENDO","ITEM")
         RETURN FALSE
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------#
REPORT pol0662_relats(p_num_nf)
#-----------------------------#

   DEFINE p_num_nf CHAR(06)
   
   OUTPUT LEFT   MARGIN   0
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   66

   ORDER EXTERNAL BY p_num_nf
  
   FORMAT

      PAGE HEADER
         PRINT COLUMN 001, p_comprime,p_den_empresa, 
               COLUMN 183, "PAG: ", PAGENO USING "&&&&"

         PRINT COLUMN 001, "POL0662",
               COLUMN 066, "RELATORIO DE RASTREABILIDADE DAS SAIDAS",
               COLUMN 164, "EMISSAO: ", TODAY USING "dd/mm/yyyy", "-", TIME

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'N I V E L            COD ITEM        DESCRICAO          TP UND NUM LOTE        QTD PROD   QTD CONS   TOT SAIDA  NUM NF EMISSAO    QTD DA NF  COD COMPANHIA   RAZAO SOCIAL'
         PRINT COLUMN 001, '-------------------- --------------- ------------------ -- --- --------------- ---------- ---------- ---------- ------ ---------- ---------- --------------- -----------------------------------'

      BEFORE GROUP OF p_num_nf

         SKIP TO TOP OF PAGE

      
      ON EVERY ROW

          LET p_num_nf_imp = p_relat.num_nfc
          IF p_relat.cod_niv = '01' THEN
             LET p_num_nf_imp = p_relat.num_nf 
             PRINT
          END IF
          
          PRINT COLUMN 001, p_relat.cod_niv,
                COLUMN 022, p_relat.cod_item,
                COLUMN 038, p_relat.den_item,
                COLUMN 057, p_relat.ies_tip_item,
                COLUMN 060, p_relat.cod_unid_med,
                COLUMN 064, p_relat.num_lote,
                COLUMN 080, p_relat.qtd_prod    USING '#####&.&&&',
                COLUMN 091, p_relat.qtd_cons    USING '#####&.&&&',
                COLUMN 102, p_relat.qtd_fat     USING '#####&.&&&',
                COLUMN 113, p_num_nf_imp        USING '######',
                COLUMN 120, p_relat.dat_emissao,
                COLUMN 131, p_relat.qtd_nota    USING '#####&.&&&',
                COLUMN 142, p_relat.cod_companhia,
                COLUMN 158, p_relat.raz_social

      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 027, p_descomprime,'* * * ULTIMA FOLHA * * *'
         
                        
END REPORT
        
#------------------------#
FUNCTION pol0662_entrada()
#------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06622") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06622 AT 5,3 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   LET p_tip_rast = 'E'
   
   MENU "OPCAO"
      COMMAND "Informar" "Informar Parâmetros p/ Rastreabilidade"
         HELP 001 
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0662","IN")  THEN
            IF pol0662_cria_temp() THEN
               IF pol0662_informa_nfe() THEN
                  ERROR "Parâmetros informados com sucesso !!!"
                  LET p_ies_cons = TRUE
                  NEXT OPTION "Listar"
               ELSE
                  ERROR "Operação Cancelada !!!"
               END IF
            ELSE
               ERROR "Operação cancelada"
            END IF
         END IF 
      COMMAND "Listar" "Lista a Ratreabilidade"
         HELP 002
         MESSAGE ""
         IF log005_seguranca(p_user,"VDP","pol0662","CO") THEN 
            CALL pol0662_escolhe_saida()
         END IF
         NEXT OPTION "Fim"
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
  
   CLOSE WINDOW w_pol06622

END FUNCTION
        
#----------------------------#
FUNCTION pol0662_informa_nfe()
#----------------------------#

   LET p_ies_cons = FALSE
   LET INT_FLAG = 0
   LET p_count = 0

   WHILE TRUE
      INITIALIZE p_num_nf, p_itens TO NULL
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
 
      INPUT p_num_nf
         WITHOUT DEFAULTS FROM num_nf

         AFTER FIELD num_nf    
            IF p_num_nf IS NOT NULL THEN

               LET p_ind = 1
               INITIALIZE pr_nf TO NULL
               DECLARE cq_cia CURSOR FOR

                SELECT a.ser_nf,
                       a.dat_emis_nf,
                       a.num_aviso_rec,
                       a.cod_fornecedor,
                       b.raz_social
                 FROM nf_sup a,
                      fornecedor b
                WHERE a.cod_empresa    = p_cod_empresa
                  AND a.num_nf         = p_num_nf
                  AND b.cod_fornecedor = a.cod_fornecedor
       
               FOREACH cq_cia INTO pr_nf[p_ind].*
                  LET p_ind = p_ind + 1
               END FOREACH

               IF p_ind = 1 THEN
                  ERROR 'NF ou Fornecedor da NF Inexistente!!!'
                  NEXT FIELD num_nf
               END IF
               
               LET p_ind = p_ind - 1
               
               IF p_ind > 1 THEN
                  IF NOT pol0662_select_fornecedor() THEN
                     ERROR 'NF Descartada!'
                     NEXT FIELD num_nf
                  END IF
               END IF

               LET p_cod_fornecedor = pr_nf[p_ind].cod_companhia
               LET p_raz_social     = pr_nf[p_ind].raz_social

               SELECT UNIQUE num_nota_fiscal
                 FROM rastreabilidade 
                WHERE cod_empresa     = p_cod_empresa
                  AND num_nota_fiscal = p_num_nf
                  AND ies_origem_info = 'R'

               IF STATUS = 100 THEN
                  ERROR 'NFE Não Encontrada na Tabela de Rastreabilidade'
                  NEXT FIELD num_nf
               ELSE
                  IF STATUS <> 0 THEN
                     CALL log003_err_sql("LENDO","RASTREABILIDADE:20")
                     RETURN FALSE
                  END IF
               END IF

               SELECT num_nf
                 FROM nf_rast_970
                WHERE num_nf = p_num_nf
                  AND cod_companhia = p_cod_fornecedor

               IF STATUS = 0 THEN
                  ERROR 'NF de entrada já informada!'
                  NEXT FIELD num_nf
               ELSE
                  IF STATUS <> 100 THEN
                     CALL log003_err_sql("LENDO","NF_RAST_970")
                     RETURN FALSE
                  END IF
               END IF
               
               DISPLAY p_dat_emissao TO dat_emissao
               DISPLAY p_raz_social  TO raz_social

               LET p_count = p_count + 1
            END IF
            
      END INPUT

      IF INT_FLAG THEN
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET int_flag = 0
         RETURN FALSE
      END IF

      IF p_num_nf IS NULL THEN
         EXIT WHILE
      END IF

      IF NOT pol0662_sel_itens_nf('R') THEN
         RETURN FALSE
      END IF

   END WHILE
   
   IF p_count > 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
   
END FUNCTION

#------------------------------------#
FUNCTION pol0662_select_fornecedor()
#------------------------------------#

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol06624") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol06624 AT 7,19 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   CALL SET_COUNT(p_ind - 1)

   DISPLAY ARRAY pr_nf TO  sr_nf.*
      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE()
   
   CLOSE WINDOW w_pol06624
   
   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#-------------------------------------#
FUNCTION pol0662_entrada_informa_item()
#-------------------------------------#

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06623") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06623 AT 9,12 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   INITIALIZE p_lote TO NULL
   
   INPUT ARRAY p_lote
      WITHOUT DEFAULTS FROM s_lote.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

      AFTER FIELD cod_item
         IF p_lote[p_index].cod_item IS NOT NULL THEN
            IF NOT pol0662_le_descricao() THEN
              RETURN FALSE
            END IF
            IF STATUS = 100 THEN
               ERROR 'Item não cadastrado!!!'
               NEXT FIELD cod_item
            END IF
            DISPLAY p_lote[p_index].den_item TO s_lote[s_index].den_item
         END IF

      BEFORE FIELD num_lote
         IF p_lote[p_index].cod_item IS NULL THEN
            NEXT FIELD cod_item
         END IF
         
      AFTER FIELD num_lote
         IF p_lote[p_index].num_lote IS NULL THEN
            ERROR 'Campo c/ preenchimento obrigatório!!!'
            NEXT FIELD num_lote
         END IF

         IF NOT pol0662_tem_rastreabilidade_e() THEN
            RETURN FALSE
         END IF
                
         IF p_count = 0 THEN
            ERROR 'Item/Lote não encontrado na tabela Rastreabilidade!!!'
            NEXT FIELD num_lote
         END IF
            
      ON KEY (control-z)
         CALL pol0662_popup()

   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol0662_entrada_grava_itens() THEN
      RETURN FALSE
   END IF
   
   SELECT COUNT(num_nf)
     INTO p_count
     FROM nf_rast_970
   
   IF p_count = 0 THEN
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF
   
END FUNCTION

#--------------------------------------#
FUNCTION pol0662_tem_rastreabilidade_e()
#--------------------------------------#

   SELECT COUNT(cod_item_cons)
     INTO p_count
     FROM rastreabilidade
    WHERE cod_empresa     = p_cod_empresa
      AND cod_item_cons   = p_lote[p_index].cod_item
      AND num_lote_cons   = p_lote[p_index].num_lote
      AND ies_origem_info = 'R'

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LENDO","rastreabilidade:1")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------#
FUNCTION pol0662_entrada_grava_itens()
#------------------------------------#
  
   FOR p_ind = 1 TO ARR_COUNT()
      IF p_lote[p_ind].cod_item IS NOT NULL THEN
         IF NOT pol0662_insere_item_e() THEN
            RETURN FALSE
         END IF
      END IF
   END FOR

   RETURN TRUE
      
END FUNCTION

#------------------------------#
FUNCTION pol0662_insere_item_e()
#------------------------------#

   DECLARE cq_itens_e CURSOR FOR
    SELECT num_nota_fiscal,
           SUM(qtd_consumida)
      FROM rastreabilidade
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item_cons   = p_lote[p_ind].cod_item
       AND num_lote_cons   = p_lote[p_ind].num_lote
       AND ies_origem_info = 'R'
     GROUP BY num_nota_fiscal

      IF STATUS <> 0 THEN
         CALL log003_err_sql("LEDNO","RASTREABILIDADE:21")
         RETURN FALSE
      END IF

   FOREACH cq_itens_e INTO p_num_nf, p_qtd_movto
   
      INSERT INTO nf_rast_970
       VALUES(p_num_nf, 
              p_lote[p_ind].cod_item,
              p_lote[p_ind].num_lote,
              p_qtd_movto)
   
      IF STATUS <> 0 THEN
         CALL log003_err_sql("INSERINDO","NF_RAST_970")
         RETURN FALSE
      END IF

   END FOREACH
   
   RETURN TRUE

END FUNCTION


#--------------------------------------#
FUNCTION pol0662_ent_insere_estrutura()
#--------------------------------------#

   LET p_num_seq = p_num_seq + 1

   DISPLAY p_num_seq AT 18,36

   IF NOT pol0662_le_item(p_relat.cod_item) THEN
      RETURN FALSE
   END IF

   LET p_relat.num_seq       = p_num_seq
   LET p_relat.cod_niv       = p_nivel
   LET p_relat.num_nf        = p_niv1.num_nf
	 LET p_relat.den_item      = p_den_item
	 LET p_relat.ies_tip_item  = p_ies_tip_item
	 LET p_relat.cod_unid_med  = p_cod_unid_med

   INSERT INTO nf_estrutura_970
    VALUES(p_relat.*)

   IF STATUS <> 0 THEN
      CALL log003_err_sql("INSERINDO","NF_ESTRUTURA_970:4")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION


#--------------------------------#
FUNCTION pol0662_processa_entrada()
#--------------------------------#

   MESSAGE 'Processando a Rastreabilidade...' ATTRIBUTE(REVERSE)

   LET p_num_seq = 0
   
   INITIALIZE p_niv1 TO NULL

   DELETE FROM nf_estrutura_970

   IF STATUS <> 0 THEN
      CALL log003_err_sql("DELETANDO","NF_ESTRUTURA_970:2")
      RETURN FALSE
   END IF

   DECLARE cd_niv11 CURSOR FOR
    SELECT *
      FROM nf_rast_970 
     ORDER BY num_nf, 
              cod_item, 
              num_lote

    IF STATUS <> 0 THEN
       CALL log003_err_sql("LENDO","NF_RAST_970")
       RETURN FALSE
    END IF

   FOREACH cd_niv11 INTO p_niv1.*
      
      INITIALIZE p_relat TO NULL      
      
      LET p_relat.cod_item      = p_niv1.cod_item
      LET p_relat.num_lote      = p_niv1.num_lote
      LET p_relat.qtd_nota      = p_niv1.qtd_movto
      LET p_relat.cod_companhia = p_niv1.cod_companhia
      LET p_nivel = '01'
      
      LET p_num_nf = p_niv1.num_nf
      IF NOT pol0662_le_nf_mestre() THEN
         RETURN FALSE
      END IF
      
      LET p_relat.dat_emissao   = p_dat_emissao
      LET p_relat.cod_companhia = p_cod_cliente
      LET p_relat.raz_social    = p_nom_cliente
      
      IF NOT pol0662_ent_insere_estrutura() THEN
         RETURN FALSE
      END IF
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM rastreabilidade
       WHERE cod_empresa     = p_cod_empresa
         AND cod_item_cons   = p_niv1.cod_item
         AND num_lote_cons   = p_niv1.num_lote
         AND ies_origem_info IN ('R','P')

      IF p_count = 0 THEN
         LET p_nivel = '  02'
         IF NOT pol0662_le_tipo_f(p_niv1.cod_item,p_niv1.num_lote) THEN
            RETURN FALSE
         END IF
         CONTINUE FOREACH
      END IF            
      
      INITIALIZE p_niv2 TO NULL
      DECLARE cd_niv21 CURSOR FOR 
       SELECT cod_item,
              num_lote,
              qtd_movto,
              num_nota_fiscal,
              qtd_consumida
         FROM rastreabilidade
        WHERE cod_empresa     = p_cod_empresa
          AND cod_item_cons   = p_niv1.cod_item
          AND num_lote_cons   = p_niv1.num_lote
          AND ies_origem_info IN ('R','P')
        ORDER BY cod_item, num_lote

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LENDO","RASTREABILIDADE:22")
          RETURN FALSE
       END IF
   
      FOREACH cd_niv21 INTO p_niv2.*

         INITIALIZE p_relat TO NULL

         IF NOT pol0662_soma(p_niv2.cod_item, p_niv2.num_lote) THEN
            RETURN FALSE
         END IF
         
         LET p_relat.qtd_fat  = p_niv2.qtd_movto
         LET p_relat.qtd_cons = p_niv2.qtd_cons
         LET p_relat.num_nfc  = p_niv2.num_nf
         LET p_nivel = '  02'

         IF p_niv2.num_nf IS NOT NULL AND p_niv2.num_nf <> 0 THEN
            LET p_num_nf = p_niv2.num_nf
            IF NOT pol0662_le_nf_mestre() THEN
               RETURN FALSE
            END IF
            LET p_relat.qtd_nota      = p_niv2.qtd_movto
            LET p_relat.dat_emissao   = p_dat_emissao
            LET p_relat.cod_companhia = p_cod_cliente
            LET p_relat.raz_social    = p_nom_cliente
         END IF
      
         IF NOT pol0662_ent_insere_estrutura() THEN
            RETURN FALSE
         END IF
         
         SELECT COUNT(cod_item)
           INTO p_count
           FROM rastreabilidade
          WHERE cod_empresa     = p_cod_empresa
            AND cod_item_cons   = p_niv2.cod_item
            AND num_lote_cons   = p_niv2.num_lote
            AND ies_origem_info = 'P'

         IF p_count = 0 THEN
            LET p_nivel = '    03'
            IF NOT pol0662_le_tipo_f(p_niv2.cod_item,p_niv2.num_lote) THEN
               RETURN FALSE
            END IF
            CONTINUE FOREACH
         END IF            
         
         INITIALIZE p_niv3 TO NULL
         DECLARE cd_niv31 CURSOR FOR 
          SELECT cod_item,
                 num_lote,
                 qtd_movto,
                 '',
                 qtd_consumida
            FROM rastreabilidade
           WHERE cod_empresa     = p_cod_empresa
             AND cod_item_cons   = p_niv2.cod_item
             AND num_lote_cons   = p_niv2.num_lote
             AND ies_origem_info = 'P'

          IF STATUS <> 0 THEN
             CALL log003_err_sql("LENDO","RASTREABILIDADE:23")
             RETURN FALSE
          END IF
   
         FOREACH cd_niv31 INTO p_niv3.*
      
            INITIALIZE p_relat TO NULL

            IF NOT pol0662_soma(p_niv3.cod_item, p_niv3.num_lote) THEN
               RETURN FALSE
            END IF

            LET p_relat.qtd_fat  = p_niv3.qtd_movto
            LET p_relat.qtd_cons = p_niv3.qtd_cons
            LET p_relat.num_nfc  = p_niv3.num_nf
            LET p_nivel = '    03'
         
            IF NOT pol0662_ent_insere_estrutura() THEN
               RETURN FALSE
            END IF

            SELECT COUNT(cod_item)
              INTO p_count
              FROM rastreabilidade
             WHERE cod_empresa     = p_cod_empresa
               AND cod_item_cons   = p_niv3.cod_item
               AND num_lote_cons   = p_niv3.num_lote
               AND ies_origem_info = 'P'

            IF p_count = 0 THEN
               LET p_nivel = '      04'
               IF NOT pol0662_le_tipo_f(p_niv3.cod_item,p_niv3.num_lote) THEN
                  RETURN FALSE
               END IF
               CONTINUE FOREACH
            END IF            
            
            INITIALIZE p_niv4 TO NULL
            DECLARE cd_niv41 CURSOR FOR 
             SELECT cod_item,
                    num_lote,
                    qtd_movto,
                    '',
                    qtd_consumida
               FROM rastreabilidade
              WHERE cod_empresa     = p_cod_empresa
                AND cod_item_cons   = p_niv3.cod_item
                AND num_lote_cons   = p_niv3.num_lote
                AND ies_origem_info = 'P'

             IF STATUS <> 0 THEN
                CALL log003_err_sql("LENDO","RASTREABILIDADE:24")
                RETURN FALSE
             END IF
   
            FOREACH cd_niv41 INTO p_niv4.*
   
               INITIALIZE p_relat TO NULL

               IF NOT pol0662_soma(p_niv4.cod_item, p_niv4.num_lote) THEN
                  RETURN FALSE
               END IF

               LET p_relat.qtd_fat  = p_niv4.qtd_movto
               LET p_relat.qtd_cons = p_niv4.qtd_cons
               LET p_relat.num_nfc  = p_niv4.num_nf
               LET p_nivel = '      04'
      
               IF NOT pol0662_ent_insere_estrutura() THEN
                  RETURN FALSE
               END IF

               SELECT COUNT(cod_item)
                 INTO p_count
                 FROM rastreabilidade
                WHERE cod_empresa     = p_cod_empresa
                  AND cod_item_cons   = p_niv4.cod_item
                  AND num_lote_cons   = p_niv4.num_lote
                  AND ies_origem_info = 'P'

               IF p_count = 0 THEN
                  LET p_nivel = '        05'
                  IF NOT pol0662_le_tipo_f(p_niv4.cod_item,p_niv4.num_lote) THEN
                     RETURN FALSE
                  END IF
                  CONTINUE FOREACH
               END IF            

               INITIALIZE p_niv5 TO NULL
               DECLARE cd_niv51 CURSOR FOR 
                SELECT cod_item,
                       num_lote,
                       qtd_movto,
                       '',
                       qtd_consumida
                  FROM rastreabilidade
                 WHERE cod_empresa     = p_cod_empresa
                   AND cod_item_cons   = p_niv4.cod_item
                   AND num_lote_cons   = p_niv4.num_lote
                   AND ies_origem_info = 'P'

                IF STATUS <> 0 THEN
                   CALL log003_err_sql("LENDO","RASTREABILIDADE:25")
                   RETURN FALSE
                END IF
   
               FOREACH cd_niv51 INTO p_niv5.*
      
                  INITIALIZE p_relat TO NULL

                  IF NOT pol0662_soma(p_niv5.cod_item, p_niv5.num_lote) THEN
                     RETURN FALSE
                  END IF

                  LET p_relat.qtd_fat  = p_niv5.qtd_movto
                  LET p_relat.qtd_cons = p_niv5.qtd_cons
                  LET p_relat.num_nfc  = p_niv5.num_nf
                  LET p_nivel = '        05'
      
                  IF NOT pol0662_ent_insere_estrutura() THEN
                     RETURN FALSE
                  END IF

                  SELECT COUNT(cod_item)
                    INTO p_count
                    FROM rastreabilidade
                   WHERE cod_empresa     = p_cod_empresa
                     AND cod_item_cons   = p_niv5.cod_item
                     AND num_lote_cons   = p_niv5.num_lote
                     AND ies_origem_info = 'P'

                  IF p_count = 0 THEN
                     LET p_nivel = '          06'
                     IF NOT pol0662_le_tipo_f(p_niv5.cod_item,p_niv5.num_lote) THEN
                        RETURN FALSE
                     END IF
                     CONTINUE FOREACH
                  END IF            

                  INITIALIZE p_niv6 TO NULL
                  DECLARE cd_niv61 CURSOR FOR 
                   SELECT cod_item,
                          num_lote,
                          qtd_movto,
                          '',
                          qtd_consumida
                     FROM rastreabilidade
                    WHERE cod_empresa     = p_cod_empresa
                      AND cod_item_cons   = p_niv5.cod_item
                      AND num_lote_cons   = p_niv5.num_lote
                      AND ies_origem_info = 'P'

                   IF STATUS <> 0 THEN
                      CALL log003_err_sql("LENDO","RASTREABILIDADE:26")
                      RETURN FALSE
                   END IF
     
                  FOREACH cd_niv61 INTO p_niv6.*

                     INITIALIZE p_relat TO NULL

                     IF NOT pol0662_soma(p_niv6.cod_item, p_niv6.num_lote) THEN
                        RETURN FALSE
                     END IF

                     LET p_relat.qtd_fat  = p_niv6.qtd_movto
                     LET p_relat.qtd_cons = p_niv6.qtd_cons
                     LET p_relat.num_nfc  = p_niv6.num_nf
                     LET p_nivel = '          06'
      
                     IF NOT pol0662_ent_insere_estrutura() THEN
                        RETURN FALSE
                     END IF
      
                     SELECT COUNT(cod_item)
                       INTO p_count
                       FROM rastreabilidade
                      WHERE cod_empresa     = p_cod_empresa
                        AND cod_item_cons   = p_niv6.cod_item
                        AND num_lote_cons   = p_niv6.num_lote
                        AND ies_origem_info = 'P'

                     IF p_count = 0 THEN
                        LET p_nivel = '            07'
                        IF NOT pol0662_le_tipo_f(p_niv6.cod_item,p_niv6.num_lote) THEN
                           RETURN FALSE
                        END IF
                        CONTINUE FOREACH
                     END IF            

                     INITIALIZE p_niv7 TO NULL
                     DECLARE cd_niv71 CURSOR FOR 
                      SELECT cod_item,
                             num_lote,
                             qtd_movto,
                             '',
                             qtd_consumida
                        FROM rastreabilidade
                       WHERE cod_empresa     = p_cod_empresa
                         AND cod_item_cons   = p_niv6.cod_item
                         AND num_lote_cons   = p_niv6.num_lote
                         AND ies_origem_info = 'P'

                      IF STATUS <> 0 THEN
                        CALL log003_err_sql("LENDO","RASTREABILIDADE:27")
                         RETURN FALSE
                      END IF
     
                     FOREACH cd_niv71 INTO p_niv7.*

                        INITIALIZE p_relat TO NULL

                        IF NOT pol0662_soma(p_niv7.cod_item, p_niv7.num_lote) THEN
                           RETURN FALSE
                        END IF

                        LET p_relat.qtd_fat  = p_niv7.qtd_movto
                        LET p_relat.qtd_cons = p_niv7.qtd_cons
                        LET p_relat.num_nfc  = p_niv7.num_nf
                        LET p_nivel = '            07'
      
                        IF NOT pol0662_ent_insere_estrutura() THEN
                           RETURN FALSE
                        END IF

                        SELECT COUNT(cod_item)
                          INTO p_count
                          FROM rastreabilidade
                         WHERE cod_empresa     = p_cod_empresa
                           AND cod_item_cons   = p_niv7.cod_item
                           AND num_lote_cons   = p_niv7.num_lote
                           AND ies_origem_info = 'P'

                        IF p_count = 0 THEN
                           LET p_nivel = '              08'
                           IF NOT pol0662_le_tipo_f(p_niv7.cod_item,p_niv7.num_lote) THEN
                              RETURN FALSE
                           END IF
                           CONTINUE FOREACH
                        END IF            

                        INITIALIZE p_niv8 TO NULL
                        DECLARE cd_niv81 CURSOR FOR 
                         SELECT cod_item,
                                num_lote,
                                qtd_movto,
                                '',
                                qtd_consumida
                           FROM rastreabilidade
                          WHERE cod_empresa     = p_cod_empresa
                            AND cod_item_cons   = p_niv7.cod_item
                            AND num_lote_cons   = p_niv7.num_lote
                            AND ies_origem_info = 'P'

                         IF STATUS <> 0 THEN
                           CALL log003_err_sql("LENDO","RASTREABILIDADE:28")
                            RETURN FALSE
                         END IF
     
                        FOREACH cd_niv81 INTO p_niv8.*
       
                           INITIALIZE p_relat TO NULL

                           IF NOT pol0662_soma(p_niv8.cod_item, p_niv8.num_lote) THEN
                              RETURN FALSE
                           END IF

                           LET p_relat.qtd_fat  = p_niv8.qtd_movto
                           LET p_relat.qtd_cons = p_niv8.qtd_cons
                           LET p_relat.num_nfc  = p_niv8.num_nf
                           LET p_nivel = '              08'
      
                           IF NOT pol0662_ent_insere_estrutura() THEN
                              RETURN FALSE
                           END IF

                           SELECT COUNT(cod_item)
                             INTO p_count
                             FROM rastreabilidade
                            WHERE cod_empresa     = p_cod_empresa
                              AND cod_item_cons   = p_niv8.cod_item
                              AND num_lote_cons   = p_niv8.num_lote
                              AND ies_origem_info = 'P'

                           IF p_count = 0 THEN
                              LET p_nivel = '                09'
                              IF NOT pol0662_le_tipo_f(p_niv8.cod_item,p_niv8.num_lote) THEN
                                 RETURN FALSE
                              END IF
                              CONTINUE FOREACH
                           END IF            

                           INITIALIZE p_niv9 TO NULL
                           DECLARE cd_niv91 CURSOR FOR 
                            SELECT cod_item,
                                   num_lote,
                                   qtd_movto,
                                   '',
                                   qtd_consumida
                              FROM rastreabilidade
                             WHERE cod_empresa     = p_cod_empresa
                               AND cod_item_cons   = p_niv8.cod_item
                               AND num_lote_cons   = p_niv8.num_lote
                               AND ies_origem_info = 'P'

                            IF STATUS <> 0 THEN
                              CALL log003_err_sql("LENDO","RASTREABILIDADE:29")
                               RETURN FALSE
                            END IF
     
                           FOREACH cd_niv91 INTO p_niv9.*

                              INITIALIZE p_relat TO NULL

                              IF NOT pol0662_soma(p_niv9.cod_item, p_niv9.num_lote) THEN
                                 RETURN FALSE
                              END IF

                              LET p_relat.qtd_fat  = p_niv9.qtd_movto
                              LET p_relat.qtd_cons = p_niv9.qtd_cons
                              LET p_relat.num_nfc  = p_niv9.num_nf
                              LET p_nivel = '                09'
      
                              IF NOT pol0662_ent_insere_estrutura() THEN
                                 RETURN FALSE
                              END IF
       
                              LET p_nivel = '                  10'
                              IF NOT pol0662_le_tipo_f(p_niv9.cod_item,p_niv9.num_lote) THEN
                                 RETURN FALSE
                              END IF
                              
                           END FOREACH
                           
                        END FOREACH
                        
                     END FOREACH
                     
                  END FOREACH
                  
               END FOREACH        

            END FOREACH

         END FOREACH

      END FOREACH

   END FOREACH
   
   RETURN TRUE              

END FUNCTION

#-------------------------------------------------#
FUNCTION pol0662_le_tipo_f(p_cod_item, p_num_lote)
#-------------------------------------------------#

   DEFINE p_cod_item LIKE item.cod_item,
          p_num_lote LIKE estoque_lote.num_lote

#----------#
RETURN TRUE
#----------#



   INITIALIZE p_relat TO NULL
             
   DECLARE cq_niv_f CURSOR FOR 
    SELECT cod_item,
           num_lote,
           qtd_movto,
           num_nota_fiscal
      FROM rastreabilidade
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item        = p_cod_item
       AND num_lote        = p_num_lote
       AND ies_origem_info = 'F'

       IF STATUS <> 0 THEN
          CALL log003_err_sql("LENDO","RASTREABILIDADE:30")
          RETURN FALSE
       END IF
   
   FOREACH cq_niv_f INTO 
           p_relat.cod_item,
           p_relat.num_lote,
           p_relat.qtd_nota,
           p_relat.num_nfc
           
      IF p_relat.num_nfc IS NOT NULL THEN
         LET p_num_nf = p_relat.num_nfc
         IF NOT pol0662_le_nf_mestre() THEN
            RETURN FALSE
         END IF
      END IF
      
      LET p_relat.cod_companhia = p_cod_cliente
      
      IF NOT pol0662_le_cliente() THEN
         RETURN FALSE
      END IF
      
      LET p_relat.raz_social = p_nom_cliente
      
      IF NOT pol0662_ent_insere_estrutura() THEN
         RETURN FALSE
      END IF
      
      INITIALIZE p_relat TO NULL
            
   END FOREACH        

   RETURN TRUE

END FUNCTION

#-----------------------------#
REPORT pol0662_relate(p_num_nf)
#-----------------------------#

   DEFINE p_num_nf CHAR(06)
   
   OUTPUT LEFT   MARGIN   1
          TOP    MARGIN   0
          BOTTOM MARGIN   0
          PAGE   LENGTH   66

   ORDER EXTERNAL BY p_num_nf
  
   FORMAT

      PAGE HEADER
         PRINT COLUMN 001, p_comprime,p_den_empresa, 
               COLUMN 183, "PAG: ", PAGENO USING "&&&&"

         PRINT COLUMN 001, "POL0662",
               COLUMN 066, "RELATORIO DE RASTREABILIDADE DAS ENTRADAS",
               COLUMN 164, "EMISSAO: ", TODAY USING "dd/mm/yyyy", "-", TIME

         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'N I V E L            COD ITEM        DESCRICAO          TP UND NUM LOTE        QTD PROD   QTD CONS   TOT LOTE   NUM NF EMISSAO    QTD DA NF  COD COMPANHIA   RAZAO SOCIAL'
         PRINT COLUMN 001, '-------------------- --------------- ------------------ -- --- --------------- ---------- ---------- ---------- ------ ---------- ---------- --------------- -----------------------------------'

      BEFORE GROUP OF p_num_nf

         SKIP TO TOP OF PAGE

      
      ON EVERY ROW

          LET p_num_nf_imp = p_relat.num_nfc
          IF p_relat.cod_niv = '01' THEN
             LET p_num_nf_imp = p_relat.num_nf 
             PRINT
          END IF
          
          PRINT COLUMN 001, p_relat.cod_niv,
                COLUMN 022, p_relat.cod_item,
                COLUMN 038, p_relat.den_item,
                COLUMN 057, p_relat.ies_tip_item,
                COLUMN 060, p_relat.cod_unid_med,
                COLUMN 064, p_relat.num_lote,
                COLUMN 080, p_relat.qtd_fat     USING '#####&.&&&',
                COLUMN 091, p_relat.qtd_cons    USING '#####&.&&&',
                COLUMN 102, p_relat.qtd_prod    USING '#####&.&&&',
                COLUMN 113, p_num_nf_imp        USING '######',
                COLUMN 120, p_relat.dat_emissao,
                COLUMN 131, p_relat.qtd_nota    USING '#####&.&&&',
                COLUMN 142, p_relat.cod_companhia,
                COLUMN 158, p_relat.raz_social


      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 027, p_descomprime,'* * * ULTIMA FOLHA * * *'
         
                        
END REPORT
        
#-----------------------------#        
FUNCTION pol0662_lista_lotes()
#-----------------------------#


   MESSAGE " Processando a Extracao do Relatorio..." ATTRIBUTE(REVERSE)
   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol0662_imp_lote TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'manut_1.tmp'
         START REPORT pol0662_imp_lote  TO p_caminho
      END IF
   ELSE
      START REPORT pol0662_imp_lote TO p_nom_arquivo
   END IF

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","EMPRESA")            
      RETURN
   END IF

   DECLARE cq_imp_lot CURSOR FOR
    SELECT * 
      FROM nf_rast_970
     ORDER BY num_lote

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","nf_rast_970")            
      RETURN
   END IF

   FOREACH cq_imp_lot INTO 
           p_relat.num_nf,
           p_relat.dat_emissao,
           p_relat.cod_companhia,
           p_relat.cod_item,
           p_relat.num_lote,
           p_relat.qtd_nota
      
      LET p_cod_cliente = p_relat.cod_companhia
      
      IF NOT pol0662_le_cliente() THEN
         EXIT FOREACH
      END IF

      IF NOT pol0662_le_item(p_relat.cod_item) THEN
         EXIT FOREACH
      END IF
   
      OUTPUT TO REPORT pol0662_imp_lote(p_relat.num_lote) 

   END FOREACH
   
   FINISH REPORT pol0662_imp_lote   
   ERROR "Relatorio Processado com Sucesso" 
   
   IF p_ies_impressao = "S" THEN
      MESSAGE "Relatorio Impresso na Impressora ", p_nom_arquivo ATTRIBUTE(REVERSE)
      IF g_ies_ambiente = "W" THEN
         LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
         RUN comando
      END IF
   ELSE
      MESSAGE "Relatorio Gravado no Arquivo ",p_nom_arquivo ATTRIBUTE(REVERSE)
   END IF                              

END FUNCTION

#----------------------------------#
 REPORT pol0662_imp_lote(p_num_lote)
#----------------------------------#

   DEFINE p_num_lote LIKE estoque_lote.num_lote

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66

         ORDER EXTERNAL BY p_num_lote

   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa, 
               COLUMN 122, "PAG.: ", PAGENO USING "&&&&&"
               
         PRINT COLUMN 001, "POL0662",
               COLUMN 046, "RASTREABILIDADE DAS SAIDAS POR LOTE",
               COLUMN 112, TODAY USING "dd/mm/yyyy", " - ", TIME

         PRINT COLUMN 001, "------------------------------------------------------------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, "NUM LOTE        COD ITEM        DESCRICAO                  NUM NF CLIENTE         RAZAO SOCIAL                         QUANTIDADE"
         PRINT COLUMN 001, "--------------- --------------- -------------------------- ------ --------------- ------------------------------------ -------------"
      
      ON EVERY ROW

         PRINT COLUMN 001, p_relat.num_lote,
               COLUMN 017, p_relat.cod_item,
               COLUMN 033, p_nom_item,
               COLUMN 060, p_relat.num_nf USING "######",
               COLUMN 067, p_relat.cod_companhia,
               COLUMN 083, p_nom_cliente,
               COLUMN 120, p_relat.qtd_nota USING "#,###,##&.&&&"

      AFTER GROUP OF p_num_lote
         PRINT

      ON LAST ROW

         LET p_salto = 64 - LINENO          
         SKIP p_salto LINES
         
         PRINT COLUMN 027, '* * * ULTIMA FOLHA * * *'
                        
END REPORT

#-----------------------#
 FUNCTION pol0662_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#

