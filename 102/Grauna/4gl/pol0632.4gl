#-------------------------------------------------------------------#
# PROGRAMA: pol0632                                                 #
# OBJETIVO: CADASTRO DO CETIFICADO DE QUALIDADE DO ITEM             #
# AUTOR...: POLO INFORMATICA - IVO                                  #
# DATA....: 13/09/07                                                #
# ALTERADO: 17/09/2007 por Ana Paula - versão 02                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_empresa            LIKE empresa.cod_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_den_empresa        CHAR(25), 
          p_retorno            SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_status             SMALLINT,
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
          sql_stmt             CHAR(300),
          where_clause         CHAR(300)  
          
   DEFINE p_num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          p_num_lote           LIKE ar_certif_1040.num_lote
   
   DEFINE p_ar_certif_1040 RECORD LIKE ar_certif_1040.*

   DEFINE p_cabec            RECORD
          num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          num_nf             LIKE nf_sup.num_nf,
          ser_nf             LIKE nf_sup.ser_nf,
          ssr_nf             LIKE nf_sup.ssr_nf,
          ies_especie_nf     LIKE nf_sup.ies_especie_nf,
          cod_fornecedor     LIKE nf_sup.cod_fornecedor,
          raz_social         LIKE fornecedor.raz_social
   END RECORD
    
   DEFINE p_cabeca           RECORD
          num_aviso_rec      LIKE aviso_rec.num_aviso_rec,
          num_nf             LIKE nf_sup.num_nf,
          cod_fornecedor     LIKE nf_sup.cod_fornecedor
   END RECORD

   DEFINE pr_itens           ARRAY[200] OF RECORD
          num_seq            LIKE aviso_rec.num_seq,
          cod_item           LIKE aviso_rec.cod_item,
          num_lote           LIKE ar_certif_1040.num_lote,
          certificado        LIKE ar_certif_1040.certificado,
          tipo               LIKE ar_certif_1040.tipo
   END RECORD
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0632-05.10.03"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0632.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0632_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0632_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0632") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0632 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Informar" "Informar Parametros"
         HELP 0001
         IF log005_seguranca(p_user,"VDP","POL0632","CO") THEN
            IF pol0632_entrada_parametros() THEN
               CALL pol0632_processa()
               LET p_ies_cons = TRUE
               NEXT OPTION "Fim"
            END IF
         END IF
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0632
   
{   IF NUM_ARGS() > 0  THEN
      LET p_num_aviso_rec = ARG_VAL(1)
      CALL pol0632_processa()
   ELSE
     CALL log0030_mensagem("Parâmetro obrigatório não enviado","exclamation")      
   END IF
   CLOSE WINDOW w_pol0632}

END FUNCTION

#-----------------------------------#
FUNCTION pol0632_entrada_parametros()
#-----------------------------------#
   CLEAR FORM
   CALL log006_exibe_teclas("01 01 07", p_versao)
   CURRENT WINDOW IS w_pol0632

   LET p_num_aviso_rec = NULL

   INPUT p_num_aviso_rec
      WITHOUT DEFAULTS
   FROM num_aviso_rec

      AFTER FIELD num_aviso_rec
         IF p_num_aviso_rec IS NULL THEN
            ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD num_aviso_rec
         ELSE
            SELECT num_aviso_rec
              FROM nf_sup
             WHERE cod_empresa   = p_cod_empresa
               AND num_aviso_rec = p_num_aviso_rec
         
            IF SQLCA.sqlcode = NOTFOUND THEN
               ERROR "Aviso nao cadastrado na Tabela NF_SUP !!!"  
               NEXT FIELD num_aviso_rec
            END IF
         
         END IF

   END INPUT

   CALL log006_exibe_teclas("01", p_versao)
   CURRENT WINDOW IS w_pol0632

   IF INT_FLAG THEN
      LET INT_FLAG = 0
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#-------------------------#
FUNCTION pol0632_processa()
#-------------------------#

   WHENEVER ERROR CONTINUE

   SELECT a.num_aviso_rec,
          a.num_nf,
          a.ser_nf,
          a.ssr_nf,
          a.ies_especie_nf,
          a.cod_fornecedor,
          b.raz_social
     INTO p_cabec.*
     FROM nf_sup a,
          fornecedor b
    WHERE a.cod_empresa    = p_cod_empresa
      AND a.num_aviso_rec  = p_num_aviso_rec
      AND b.cod_fornecedor = a.cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Leitura","nf_sup")
      RETURN
   END IF

   DISPLAY BY NAME p_cabec.*

   SELECT COUNT(num_aviso_rec)
     INTO p_count
     FROM ar_certif_1040
    WHERE cod_empresa = p_cod_empresa
      AND num_aviso_rec = p_num_aviso_rec
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Leitura","ar_certif_1040")
      RETURN
   END IF
   
   IF p_count = 0 THEN
      CALL pol0632_incluir() RETURNING p_status
   ELSE
      CALL pol0632_modificar() RETURNING p_status
   END IF
   
   IF p_status THEN
      CALL log0030_mensagem("Operação efetuada c/ sucesso","exclamation")      
   ELSE
      CALL log0030_mensagem("Operação cancelada","exclamation")      
   END IF
         
END FUNCTION

#-------------------------#
FUNCTION pol0632_incluir()
#-------------------------#

   INITIALIZE pr_itens TO NULL
   LET p_index = 1

   DECLARE cq_ar CURSOR FOR 
    SELECT a.num_seq,
           a.cod_item,
           b.ies_tip_item
      FROM aviso_rec a, item b
     WHERE a.cod_empresa   = p_cod_empresa 
       AND a.num_aviso_rec = p_num_aviso_rec
       AND b.cod_empresa = a.cod_empresa
       AND b.cod_item = a.cod_item

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Leitura","aviso_rec")
      RETURN FALSE
   END IF
   
   FOREACH cq_ar INTO 
           pr_itens[p_index].num_seq,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].tipo
 
	    DECLARE cq_lote CURSOR FOR
	     SELECT DISTINCT lote
	       FROM item_ret_terc a, 
	            sup_itterc_grade b
	      WHERE a.cod_empresa      = b.empresa
	        AND a.num_nf_remessa   = b.nota_fiscal
	        AND a.num_sequencia_nf = b.seq_item_nf
          AND a.cod_empresa      = p_cod_empresa
	        AND a.num_nf           = p_cabec.num_nf
	        AND a.cod_fornecedor   = p_cabec.cod_fornecedor
	        AND a.num_sequencia_ar = pr_itens[p_index].num_seq
	
	     IF STATUS <> 0 THEN
	        CALL log003_err_sql("Leitura","item_ret_terc/sup_itterc_grade")
	        RETURN FALSE
	     END IF

      FOREACH cq_lote INTO pr_itens[p_index].num_lote
         EXIT FOREACH
      END FOREACH

      LET p_index = p_index + 1

      IF p_index > 200 THEN
         CALL log0030_mensagem("Limite de linhas do array esturou","exclamation")      
         EXIT FOREACH
      END IF

   END FOREACH

   IF pol0632_aceita_itens() THEN
      IF pol0632_gravar() THEN
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#--------------------------#
FUNCTION pol0632_modificar()
#--------------------------#
   
   DELETE FROM ar_certif_1040
         WHERE cod_empresa   = p_cod_empresa
           AND num_aviso_rec = p_num_aviso_rec
           AND num_seq NOT IN
              (SELECT num_seq from aviso_rec
                WHERE cod_empresa   = p_cod_empresa
                  AND num_aviso_rec = p_num_aviso_rec)
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando", "ar_certif_1040")
      RETURN FALSE
   END IF 
   
   INSERT INTO ar_certif_1040
      SELECT a.cod_empresa,
             a.cod_fornecedor,
             b.num_aviso_rec,
             b.num_seq,
             '',
             '',
             ''
       FROM nf_sup a, 
            aviso_rec b
      WHERE a.cod_empresa   = p_cod_empresa
        AND a.cod_empresa   = b.cod_empresa
        AND b.num_aviso_rec = p_num_aviso_rec
        AND a.num_aviso_rec = b.num_aviso_rec
        AND b.num_seq NOT IN (SELECT num_seq 
                                FROM ar_certif_1040 c 
                               WHERE c.cod_empresa   = b.cod_empresa
                                 AND c.num_aviso_rec = b.num_aviso_rec)
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Inserindo", "ar_certif_1040")
      RETURN FALSE
   END IF
   
   INITIALIZE pr_itens TO NULL
   LET p_index = 1

   DECLARE cq_certif CURSOR FOR 
    SELECT a.num_seq,
           a.num_lote,
           a.certificado,
           b.cod_item,
           a.tipo
      FROM ar_certif_1040 a,
           aviso_rec b
     WHERE a.cod_empresa   = p_cod_empresa 
       AND a.num_aviso_rec = p_num_aviso_rec
       AND b.cod_empresa   = a.cod_empresa
       AND b.num_aviso_rec = a.num_aviso_rec
       AND b.num_seq       = a.num_seq

   IF STATUS <> 0 THEN
      CALL log003_err_sql("Leitura","ar_certif_1040/aviso_rec")
      RETURN FALSE
   END IF
   
   FOREACH cq_certif INTO 
           pr_itens[p_index].num_seq,
           pr_itens[p_index].num_lote,
           pr_itens[p_index].certificado,
           pr_itens[p_index].cod_item,
           pr_itens[p_index].tipo
           
 
      LET p_index = p_index + 1

      IF p_index > 200 THEN
         CALL log0030_mensagem("Limite de linhas do array esturou","exclamation")      
         EXIT FOREACH
      END IF

   END FOREACH

   IF pol0632_aceita_itens() THEN
      IF pol0632_gravar() THEN
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol0632_aceita_itens()
#------------------------------#

   CALL SET_COUNT(p_index - 1)
   
   INPUT ARRAY pr_itens
      WITHOUT DEFAULTS FROM sr_itens.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      AFTER FIELD tipo
         
         IF NOT FGL_LASTKEY() = 2016 THEN 
            IF pr_itens[p_index + 1].num_seq IS NULL THEN
               NEXT FIELD tipo
            END IF 
         END IF 
         
   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF   

END FUNCTION

#------------------------#
FUNCTION pol0632_gravar()
#------------------------#

   CALL log085_transacao("BEGIN")
   
   IF pol0632_grava_itens() THEN
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
FUNCTION pol0632_grava_itens()
#-----------------------------#
   
   DEFINE p_ind SMALLINT 

   DELETE FROM ar_certif_1040
     WHERE cod_empresa   = p_cod_empresa
       AND num_aviso_rec = p_num_aviso_rec

   IF sqlca.sqlcode <> 0 THEN 
      CALL log003_err_sql("Deletando","ar_certif_1040")
      RETURN FALSE
   END IF

   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_itens[p_ind].num_seq IS NOT NULL THEN
          INSERT INTO ar_certif_1040
           VALUES (p_cod_empresa,
                   p_cabec.cod_fornecedor,
                   p_cabec.num_aviso_rec,
                   pr_itens[p_ind].num_seq,
                   pr_itens[p_ind].num_lote,
                   pr_itens[p_ind].certificado,
                   pr_itens[p_ind].tipo)
                  
          IF sqlca.sqlcode <> 0 THEN 
             CALL log003_err_sql("Inserindo","ar_certif_1040")
             RETURN FALSE
          END IF
       END IF
   END FOR
         
   RETURN TRUE
      
END FUNCTION


{
#-------------------------------#
FUNCTION pol0632_repetiu_cod()
#-------------------------------#

   DEFINE p_ind SMALLINT
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind = p_index THEN
          CONTINUE FOR
       END IF
       IF pr_itens[p_ind].num_lote = pr_itens[p_index].num_lote THEN
          RETURN TRUE
          EXIT FOR
       END IF
   END FOR
   RETURN FALSE
   
END FUNCTION


#-------------------------#
FUNCTION pol0632_informar() 
#-------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   CONSTRUCT BY NAME where_clause ON 
      ar_certif_1040.cod_tabela

      ON KEY (control-z)
         LET p_cod_tabela = pol0632_pega_codigo()
         IF p_cod_tabela IS NOT NULL THEN 
            LET p_ar_certif_1040.cod_tabela = p_cod_tabela
            CURRENT WINDOW IS w_pol0632       
            DISPLAY p_ar_certif_1040.cod_tabela TO cod_tabela
         END IF


   END CONSTRUCT
   
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0632

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      RETURN FALSE
   ELSE
      RETURN TRUE
   END IF

END FUNCTION


#------------------------#
FUNCTION pol0632_excluir()
#------------------------#

   LET p_retorno = FALSE

   IF log004_confirm(18,35) THEN
      WHENEVER ERROR CONTINUE
      CALL log085_transacao("BEGIN")
      DELETE FROM ar_certif_1040
        WHERE cod_tabela = p_tela.cod_tabela
      IF STATUS = 0 THEN 
         CALL log085_transacao("COMMIT")
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         INITIALIZE p_tela.cod_tabela TO NULL
      ELSE
#         CALL log085_transacao("ROLLBACK")
         CALL log003_err_sql("DELEÇÃO","ar_certif_1040")
      END IF
   END IF
   WHENEVER ERROR STOP
   RETURN(p_retorno)
   
END FUNCTION


#--------------------------#
 FUNCTION pol0632_consulta()
#--------------------------#

   LET p_cod_tabela = p_tela.cod_tabela
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
      
   CONSTRUCT BY NAME where_clause ON 
      ar_certif_1040.cod_tabela

      ON KEY (control-z)
         LET p_cod_tabela = pol0632_pega_codigo()
         IF p_cod_tabela IS NOT NULL THEN 
            LET p_ar_certif_1040.cod_tabela = p_cod_tabela
            CURRENT WINDOW IS w_pol0632       
            DISPLAY p_ar_certif_1040.cod_tabela TO cod_tabela
         END IF

   END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0632

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_tela.cod_tabela = p_cod_tabela
      CALL pol0632_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT cod_tabela FROM ar_certif_1040 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_tabela "

   PREPARE var_queri FROM sql_stmt   
   DECLARE cq_consulta SCROLL CURSOR WITH HOLD FOR var_queri
   OPEN cq_consulta
   FETCH cq_consulta INTO p_tela.*
   
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0632_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0632_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_tela.*
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_den_tabela TO NULL
   
   SELECT den_tabela INTO p_den_tabela
     FROM tabela_kana
    WHERE cod_empresa = p_cod_empresa
      AND cod_tabela  = p_tela.cod_tabela
   
   DISPLAY p_den_tabela TO den_tabela
   
   CALL pol0632_exibe_codigos()
   
 END FUNCTION

#-------------------------------#
 FUNCTION pol0632_exibe_codigos()
#-------------------------------#

   DECLARE cq_codigo CURSOR FOR 
    SELECT num_lote
      FROM ar_certif_1040
     WHERE cod_empresa = p_cod_empresa
       AND cod_tabela  = p_tela.cod_tabela

   LET p_index = 1
   
   FOREACH cq_codigo INTO pr_itens[p_index].num_lote

      INITIALIZE pr_itens[p_index].den_cnd_pgto TO NULL
      
      SELECT den_cnd_pgto
        INTO pr_itens[p_index].den_cnd_pgto
       FROM cond_pgto
      WHERE num_lote = pr_itens[p_index].num_lote

      LET p_index = p_index + 1

   END FOREACH
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_itens WITHOUT DEFAULTS FROM sr_condicao.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol0632_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cod_tabela = p_tela.cod_tabela
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_consulta INTO 
                            p_tela.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_consulta INTO 
                            p_tela.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_tela.cod_tabela = p_cod_tabela
            EXIT WHILE
         END IF

         IF p_tela.cod_tabela = p_cod_tabela THEN
            CONTINUE WHILE
         END IF 
         
         SELECT COUNT(cod_tabela) INTO p_count
           FROM ar_certif_1040
          WHERE cod_empresa = p_cod_empresa
            AND cod_tabela  = p_tela.cod_tabela
     
         IF p_count > 0 THEN  
            CALL pol0632_exibe_dados()
            EXIT WHILE
         END IF
     
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0632_emite_relatorio()
#-----------------------------------#

   SELECT den_empresa INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
  
   LET sql_stmt = "SELECT UNIQUE cod_tabela FROM ar_certif_1040 ",
                  " WHERE ", where_clause CLIPPED,                 
                  "ORDER BY cod_tabela"

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO p_cod_tabela
   
      INITIALIZE p_den_tabela TO NULL
      SELECT den_tabela
        INTO p_den_tabela
        FROM tabela_kana
       WHERE cod_empresa = p_cod_empresa
         AND cod_tabela  = p_cod_tabela

      OUTPUT TO REPORT pol0632_relat(p_cod_tabela) 
 
      LET p_count = p_count + 1
      
   END FOREACH


  
END FUNCTION 

#----------------------------------#
 REPORT pol0632_relat(p_cod_tabela)
#----------------------------------#

   DEFINE p_cod_tabela LIKE ar_certif_1040.cod_tabela

   DEFINE p_relat RECORD
          num_lote LIKE cond_pgto.num_lote,
          den_cnd_pgto LIKE cond_pgto.den_cnd_pgto
   END RECORD
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 3
   
   FORMAT
          
      PAGE HEADER  

         PRINT COLUMN 001, p_den_empresa,
               COLUMN 044, "DATA: ", TODAY USING "DD/MM/YY", ' - ', TIME,
               COLUMN 074, "PAG: ", PAGENO USING "#&"
         PRINT 
         PRINT COLUMN 001, "pol0632              RELATORIO DE CONDIÇÃO POR TABELA DE PAGAMENTO"
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"

         PRINT
                           

      BEFORE GROUP OF p_cod_tabela

         PRINT
         PRINT COLUMN 018, "Tabela: ", p_cod_tabela," - ", p_den_tabela
                              
         PRINT
         PRINT COLUMN 017, "CONDICAO              DESCRICAO"
               
         PRINT COLUMN 017, "--------   ------------------------------"
         
         PRINT
                           
      ON EVERY ROW

         DECLARE cq_tab CURSOR FOR
            SELECT a.num_lote,
                   b.den_cnd_pgto
              FROM ar_certif_1040 a,
                   cond_pgto b
             WHERE cod_empresa    = p_cod_empresa
               AND cod_tabela     = p_cod_tabela
               AND b.num_lote = a.num_lote
             ORDER BY a.cod_tabela, a.num_lote
               
         FOREACH cq_tab INTO p_relat.*
         
            PRINT COLUMN 019, p_relat.num_lote,'      ',p_relat.den_cnd_pgto
   
         END FOREACH
         
         PRINT
         
END REPORT

#-----------------------#
FUNCTION pol0632_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_tabela)
         LET p_codigo = pol0632_pega_tabela()
         CALL log006_exibe_teclas("01 01 03 07", p_versao)
         CURRENT WINDOW IS w_pol0632
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_tabela = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_tabela
         END IF
         
      WHEN INFIELD(num_lote)
         LET p_codigo = pol0632_pega_condicao()
         CALL log006_exibe_teclas("01 01 03 07", p_versao)
         CURRENT WINDOW IS w_pol0632
         IF p_codigo IS NOT NULL THEN
           LET pr_itens[p_index].num_lote = p_codigo
           DISPLAY p_codigo TO sr_condicao[s_index].num_lote
         END IF
   END CASE

END FUNCTION 

#-----------------------------#
FUNCTION pol0632_pega_tabela()
#-----------------------------#

   DEFINE p_index SMALLINT
   DEFINE s_index SMALLINT 
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol06322") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol06322 AT 7,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_tab_popup CURSOR FOR 
      SELECT cod_tabela,
             den_tabela
        FROM tabela_kana
       ORDER BY 1
       
   LET p_index = 1
   
   FOREACH cq_tab_popup INTO pr_tab_popup[p_index].*
      LET p_index = p_index + 1
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_tab_popup TO sr_tab_popup.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol06322
   
   IF INT_FLAG = 0 THEN
      RETURN pr_tab_popup[p_index].cod_tabela
   ELSE
      LET INT_FLAG = 0
      RETURN ''
   END IF
   
END FUNCTION

#------------------------------#
FUNCTION pol0632_pega_condicao()
#------------------------------#

   DEFINE p_index SMALLINT
   DEFINE s_index SMALLINT
   
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol06323") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol06323 AT 7,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_cond_popup CURSOR FOR 
      SELECT num_lote,
             den_cnd_pgto
        FROM cond_pgto
       ORDER BY 2
       
   LET p_index = 1
   
   FOREACH cq_cond_popup INTO pr_cond_popup[p_index].*
      LET p_index = p_index + 1
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   DISPLAY ARRAY pr_cond_popup TO sr_cond_popup.*

      LET p_index = ARR_CURR()
      LET s_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol06323
   
   IF INT_FLAG = 0 THEN
      RETURN pr_cond_popup[p_index].num_lote
   ELSE
      LET INT_FLAG = 0
      RETURN ''
   END IF

END FUNCTION


#-----------------------------#
FUNCTION pol0632_pega_codigo()
#-----------------------------#

   DEFINE p_ind, s_ind SMALLINT
   LET p_ind = 1
   LET INT_FLAG = 0
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol06321") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol06321 AT 7,6 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   DECLARE cq_tabela CURSOR FOR
    SELECT UNIQUE a.cod_tabela, b.den_tabela
      FROM ar_certif_1040 a, tabela_kana b
     WHERE b.cod_tabela = a.cod_tabela
     ORDER BY a.cod_tabela
   
   FOREACH cq_tabela INTO pr_tabela[p_ind].*

      IF p_ind > 200 THEN
         ERROR 'Limite de Linhas Ultrapassado !!!'
         EXIT FOREACH
      END IF
      
      LET p_ind = p_ind + 1
      
   END FOREACH
   
   CALL SET_COUNT(p_ind - 1)

   DISPLAY ARRAY pr_tabela TO sr_tabela.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol06321
   
   IF INT_FLAG = 0 THEN
      RETURN pr_tabela[p_ind].cod_tabela
   ELSE
      LET INT_FLAG = 0
      RETURN ''
   END IF
   

END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#
