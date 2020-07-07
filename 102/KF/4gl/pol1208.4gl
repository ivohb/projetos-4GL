#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1208                                                 #
# OBJETIVO: EFETIVAÇÃO DE FORNECEDORES                              #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 04/07/2013                                              #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
          p_rowid              INTEGER,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_index              SMALLINT,
          s_index              SMALLINT,
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_6lpp               CHAR(100),
          p_8lpp               CHAR(100),
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01)

END GLOBALS

DEFINE p_cod_fornecedor        LIKE fornecedor.cod_fornecedor

DEFINE p_situacao              CHAR(7),
       p_cod_erro              CHAR(10),
       p_ies_ativo             CHAR(01),
       p_qtd_linha             INTEGER

DEFINE pr_item ARRAY[500] OF RECORD
       codigo             LIKE fornecedor.cod_fornecedor,
       nome               LIKE fornecedor.raz_social,
       situacao           CHAR(07),
       marcado            CHAR(01)
END RECORD       


MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1208-10.02.02"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1208_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1208_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1208") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1208 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO empresa
   
   IF NOT POL1208_cria_tabela() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Ativar" "ATIVAR fornecedoroes"
         LET p_opcao = 'I'
         LET p_ies_ativo = 'A'
         LET p_situacao = 'Inativo'
         CALL pol1208_processa() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1208_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Inativar" "INATIVAR fornecedoroes"
         LET p_opcao = 'A'
         LET p_ies_ativo = 'I'
         LET p_situacao = 'Ativo'
         CALL pol1208_processa() RETURNING p_status
         IF p_status THEN
            ERROR 'Operação efetuada com sucesso !!!'
         ELSE
            CALL pol1208_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1208_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1208

END FUNCTION

#------------------------#
 FUNCTION pol1208_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1208_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO empresa

END FUNCTION

#-----------------------------#
FUNCTION POL1208_cria_tabela()#
#-----------------------------#

   LET p_msg = 'fornec_1099'

   IF NOT log0150_verifica_se_tabela_existe(p_msg) THEN
      CREATE TABLE fornec_1099 (
         cod_fornecedor  CHAR(15)
      );

      IF STATUS <> 0 THEN
         RETURN FALSE
      END IF
   END IF      

   RETURN TRUE

END FUNCTION

#--------------------------#
FUNCTION pol1208_processa()#
#--------------------------#

   IF NOT pol1208_informar() THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1208_selecionar() THEN
      RETURN FALSE
   END IF

   IF p_opcao = 'I' THEN
      LET p_msg = 'Tem certeza que quer ATIVAR\n',
                  'os fornecedores selecionados?'
   ELSE
      LET p_msg = 'Tem certeza que quer INATIVAR\n',
                  'os fornecedores selecionados?'
   END IF
      
   IF NOT log0040_confirm(20,25,p_msg) THEN
      RETURN FALSE
   END IF

   LET p_msg = NULL
   
   FOR p_ind = 1 to p_qtd_linha
      IF pr_item[p_ind].marcado = 'S' THEN
         IF NOT pol1208_grava_tabs() THEN
            EXIT FOR
         END IF
      END IF
   END FOR
   
   IF p_msg IS NOT NULL THEN
      CALL log0030_mensagem(p_msg,'excla')
   END IF   
   
   RETURN TRUE

END FUNCTION   

#--------------------------#
FUNCTION pol1208_informar()#
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1208_limpa_tela()
   LET INT_FLAG = FALSE
   DISPLAY p_opcao TO ies_fornec_ativo
   
   CONSTRUCT BY NAME where_clause ON 
      fornecedor.cod_fornecedor,
      fornecedor.num_cgc_cpf,
      fornecedor.raz_social,
      fornecedor.cod_uni_feder
      
      ON KEY (control-z)
         CALL pol1208_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      CALL pol1208_limpa_tela()
      RETURN FALSE 
   END IF

   LET sql_stmt = 
       "SELECT cod_fornecedor, raz_social ",
                  "  FROM fornecedor ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND ies_fornec_ativo = '",p_opcao,"' ",
                  " ORDER BY raz_social"

   INITIALIZE pr_item TO NULL
   LET p_ind = 1
   
   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao CURSOR FOR var_query

   FOREACH cq_padrao INTO 
           pr_item[p_ind].codigo,
           pr_item[p_ind].nome

      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_padrao')
         RETURN FALSE
      END IF
      
      LET pr_item[p_ind].situacao = p_situacao
         
      LET pr_item[p_ind].marcado = 'N'
      
      LET p_ind = p_ind + 1
      
      IF p_ind > 500 THEN
         LET p_msg = 'Limite de linhas da\n',
                     'grade ultrapassou.'
         CALL log0030_mensagem(p_msg,'excla')
         EXIT FOREACH
      END IF
   
   END FOREACH
   
   IF p_ind = 1 THEN
      LET p_msg = 'Não há fornecedores ',p_situacao,'s, para\n',
                  'os parâmetros informados.'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE;
   END IF
                     
   RETURN TRUE

END FUNCTION


#-----------------------#
 FUNCTION pol1208_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_fornecedor)
         CALL sup162_popup_fornecedor() RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1208
         
         IF p_codigo IS NOT NULL THEN
            #LET p_tela.cod_fornecedor = p_codigo
            DISPLAY p_codigo TO cod_fornecedor
         END IF
   
   END CASE 

END FUNCTION 

#----------------------------#
FUNCTION pol1208_selecionar()#
#----------------------------#

   IF p_opcao = 'I' THEN
      LET p_msg = 'Selecione os fornecedores a serem ATIVADOS'
   ELSE
      LET p_msg = 'Selecione os fornecedores a serem INATIVADOS'
   END IF
   
   DISPLAY p_msg AT 20,15
   
   LET p_qtd_linha = p_ind - 1

   CALL SET_COUNT(p_ind - 1)
   
   INPUT ARRAY pr_item
      WITHOUT DEFAULTS FROM sr_item.*
         ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
   
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  

      AFTER FIELD marcado
      
         IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
              OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
         ELSE
            IF p_ind >= p_qtd_linha THEN
               NEXT FIELD marcado
            END IF
         END IF
      
      AFTER INPUT
         IF NOT INT_FLAG THEN
            LET p_count = 0
            FOR p_index = 1 TO ARR_COUNT()
                IF pr_item[p_index].codigo IS NOT NULL THEN
                   IF pr_item[p_index].marcado = 'S' THEN
                      LET p_count = p_count + 1
                   END IF
                END IF
            END FOR       
            IF p_count = 0 THEN
               LET p_msg = 'Por favor, selecione\n pelomenos um fornecedor!'
               CALL log0030_mensagem(p_msg,'excla')
               NEXT FIELD marcado
            END IF
         END IF

   END INPUT
   
   IF INT_FLAG THEN
      RETURN FALSE
   END IF

   RETURN TRUE
      
END FUNCTION

#----------------------------#
FUNCTION pol1208_grava_tabs()#
#----------------------------#

   CALL log085_transacao("BEGIN")
   
   IF NOT pol1208_grav_fornecs() THEN
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF

   CALL log085_transacao("COMMIT")
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1208_grav_fornecs()#
#------------------------------#

   LET p_cod_fornecedor = pr_item[p_ind].codigo
      
   UPDATE fornecedor
      SET ies_fornec_ativo = p_ies_ativo
    WHERE cod_fornecedor = p_cod_fornecedor
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql('UPDATE','FORNECEDOR')
      LET p_msg = 'Processo interronmpido no\n',
                  'Fornecedor: ',p_cod_fornecedor
      RETURN FALSE
   END IF
   
   IF p_ies_ativo = 'A' THEN
      INSERT INTO fornec_1099(cod_fornecedor)
         VALUES(p_cod_fornecedor)
   ELSE
      DELETE FROM fornec_1099
       WHERE cod_fornecedor = p_cod_fornecedor
   END IF
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('ATUALIZANDO','FORNEC_1099')
      LET p_msg = 'Processo interronmpido no\n',
                  'Fornecedor: ',p_cod_fornecedor
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION   

#--------------FIM DO PROGRAMA--------------#
{
      