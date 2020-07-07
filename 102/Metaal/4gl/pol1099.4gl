#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1099                                                 #
# OBJETIVO: CADASTRO DO CONTE�DO DAS COLUNAS                        #
# AUTOR...: IVO                                                     #
# DATA....: 02/06/11                                                #
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
          m_ind                SMALLINT,
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
          p_msg                CHAR(300),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_total              INTEGER
         
   DEFINE p_seq_oper           INTEGER,
          p_linha              INTEGER,
          p_conteudo           CHAR(75)

  
   DEFINE pr_coluna            ARRAY[300] OF RECORD
          editar               CHAR(01),
          cod_roteiro          LIKE op_coluna_item_912.cod_roteiro,
          cod_operac           LIKE op_coluna_item_912.cod_operac,
          seq_oper             LIKE op_coluna_item_912.seq_oper,
          coluna               LIKE op_coluna_912.coluna,
          tamanho              LIKE op_coluna_912.tamanho
   END RECORD

   DEFINE pr_linha            ARRAY[6] OF RECORD             
          linha               LIKE op_col_dados_912.linha,
          conteudo            LIKE op_col_dados_912.conteudo
   END RECORD

   DEFINE p_cod_item           LIKE item.cod_item,
          p_cod_item_ant       LIKE item.cod_item,
          p_den_item           LIKE item.den_item,
          p_cod_operac         LIKE consumo.cod_operac,
          p_cod_roteiro        LIKE consumo.cod_roteiro,
          p_cod_coluna         LIKE op_coluna_912.cod_coluna,
          p_den_coluna         LIKE op_coluna_912.coluna,
          p_den_operac         CHAR(25)
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1099-10.02.05"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1099_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1099_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1099") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1099 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   IF NOT pol1099_cria_temp() THEN
      RETURN
   END IF
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1099_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1099_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1099_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1099_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1099_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modifica��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1099_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1099_listar()
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol1099_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1099

END FUNCTION

#-----------------------#
 FUNCTION pol1099_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
FUNCTION pol1099_cria_temp()
#--------------------------#
   
   DROP TABLE linha_tmp_912
   
   CREATE  TABLE linha_tmp_912(
      cod_item      char(15),    
      cod_operac    char(5),     
      cod_roteiro   char(15),    
      seq_oper      decimal(2,0),
      linha         decimal(1,0),
      conteudo      char(75)
   );

   IF STATUS <> 0 THEN 
      CALL log003_err_sql("CRIACAO","linha_tmp_912")
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol1099_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE pr_coluna TO NULL
   INITIALIZE p_cod_item TO NULL
   LET p_opcao = 'I'
   
   IF pol1099_edita_item() THEN   
      IF pol1099_edita_coluna('I') THEN  
         CALL log085_transacao("BEGIN")
         IF pol1099_grava_op_conteudo() THEN
            CALL log085_transacao("COMMIT")
            RETURN TRUE                                                                    
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1099_edita_item()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_cod_item WITHOUT DEFAULTS
    FROM cod_item
            
      AFTER FIELD cod_item
      IF p_cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_item   
      END IF
                            
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_item = p_cod_item
       
      IF STATUS = 100 THEN
         ERROR "Item inexistente !!!"
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF

      DISPLAY p_den_item TO den_item
      
      LET p_count = 0
      
      SELECT COUNT(cod_item)
        INTO p_count
        FROM op_col_dados_912
       WHERE cod_item = p_cod_item
       
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo','op_col_dados_912')
         RETURN FALSE
      END IF 
  
      IF p_count > 0 THEN
         ERROR 'J� existem conte�dos cadastrados ',
               'p/ esse item !!! - Use a op��o modificar'
         NEXT FIELD cod_item
      END IF
      
      IF NOT pol1099_le_colunas() THEN   
         NEXT FIELD cod_item
      END IF
      
      ON KEY (control-z)
         CALL pol1099_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#---------------------------#
FUNCTION pol1099_le_colunas()
#---------------------------#
   
   DELETE FROM linha_tmp_912
   
   INITIALIZE pr_coluna TO NULL
   LET p_index = 1
   
   DECLARE cq_cols CURSOR FOR
    SELECT DISTINCT
           cod_roteiro,
           cod_operac,
           seq_oper,
           cod_coluna
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
     ORDER BY cod_operac, seq_oper
   
   FOREACH cq_cols INTO    
           pr_coluna[p_index].cod_roteiro,
           pr_coluna[p_index].cod_operac,
           pr_coluna[p_index].seq_oper,
           p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_item_912:cq_cols')    
         RETURN FALSE
      END IF
      
      SELECT coluna,
             tamanho
        INTO pr_coluna[p_index].coluna,
             pr_coluna[p_index].tamanho
        FROM op_coluna_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_coluna  = p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_912:cq_cols')    
         RETURN FALSE
      END IF

      IF NOT pol1099_gera_tab_temp() THEN
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 300 THEN
         LET p_msg = 'Limite de opera�oes\n do item ultrapassou'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   LET p_index = p_index - 1

   IF p_index = 0 THEN
      LET p_msg = 'Item sem colunas cadastradas!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION    

#------------------------------#
FUNCTION pol1099_gera_tab_temp()
#------------------------------#

   FOR m_ind = 1 TO 6
   
       INSERT INTO linha_tmp_912
        VALUES(p_cod_item,
               pr_coluna[p_index].cod_operac,
               pr_coluna[p_index].cod_roteiro,
               pr_coluna[p_index].seq_oper,
               m_ind,'')
                  
       IF STATUS <> 0 THEN
          CALL log003_err_sql('Insert','linha_tmp_912')  
          EXIT FOR
       END IF    
   
   END FOR
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1099_edita_coluna(p_op)
#---------------------------------#

   DEFINE p_op CHAR (01)
   
   CALL SET_COUNT(p_index)
   
   INPUT ARRAY pr_coluna
      WITHOUT DEFAULTS FROM sr_coluna.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  

         IF NOT pol1099_exibe_conteudo() THEN
            RETURN FALSE
         END IF
         
      BEFORE FIELD editar
      
         IF p_op <> 'C' THEN
            ERROR '<Enter> = Edita conte�do' 
         END IF

      AFTER FIELD editar
      
         IF pr_coluna[p_index].editar IS NOT NULL THEN
            LET pr_coluna[p_index].editar = NULL
            NEXT FIELD editar
         END IF
         
         IF pr_coluna[p_index].cod_roteiro IS NULL THEN
            IF FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 27 THEN
            ELSE
               NEXT FIELD editar
            END IF
         END IF
         
         IF FGL_LASTKEY() = 13 AND p_op <> 'C' THEN
            IF pr_coluna[p_index].cod_roteiro IS NOT NULL THEN
               CALL pol1099_edita_conteudo()
            END IF
         END IF         

      AFTER INPUT
         
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF   
   
   RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1099_todas_operacoes()
#--------------------------------#

   FOR m_ind = 1 TO ARR_COUNT()
       IF pr_coluna[m_ind].cod_operac IS NOT NULL THEN
          SELECT COUNT(cod_coluna)
            INTO p_count
            FROM coluna_tmp_912
           WHERE cod_item   = p_cod_item
             AND cod_operac = pr_coluna[m_ind].cod_operac
          IF p_count = 0 THEN
             LET p_msg = 'Opera��o ', pr_coluna[m_ind].cod_operac CLIPPED,
                         ' sem associa��o de colunas!'
             CALL log0030_mensagem(p_msg,'excla')
             RETURN FALSE
          END IF
       END IF
   END FOR
    
   RETURN TRUE

END FUNCTION

#-------------------------------#
FUNCTION pol1099_exibe_conteudo()
#-------------------------------#
 
   INITIALIZE pr_linha TO NULL
   LET p_ind = 1

   DECLARE cq_lin CURSOR FOR 
    SELECT linha,
           conteudo
      FROM linha_tmp_912
     WHERE cod_item   = p_cod_item
       AND cod_operac = pr_coluna[p_index].cod_operac
       AND seq_oper   = pr_coluna[p_index].seq_oper
     ORDER BY linha
   
   FOREACH cq_lin INTO 
           pr_linha[p_ind].linha,
           pr_linha[p_ind].conteudo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','linha_tmp_912:cq_lin')
         RETURN FALSE
      END IF

      IF p_ind = 6 THEN
         EXIT FOREACH
      END IF

      LET p_ind = p_ind + 1      

   END FOREACH

   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_linha WITHOUT DEFAULTS FROM sr_linha.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT
     
   RETURN TRUE
   
END FUNCTION

#---------------------------------#
 FUNCTION pol1099_edita_conteudo()
#---------------------------------#     
   
   DEFINE p_tamanho CHAR(3)
   
   LET p_tamanho = pr_coluna[p_index].tamanho
   LET p_tamanho = p_tamanho CLIPPED, ' caracteres'
   
   CALL SET_COUNT(p_ind)
   
   INPUT ARRAY pr_linha
      WITHOUT DEFAULTS FROM sr_linha.*
      ATTRIBUTES(INSERT ROW = FALSE, DELETE ROW = FALSE)
      
      BEFORE ROW
         LET p_ind = ARR_CURR()
         LET s_ind = SCR_LINE()  
      
      AFTER FIELD conteudo

         IF LENGTH(pr_linha[p_ind].conteudo) > pr_coluna[p_index].tamanho THEN
            ERROR 'Informe um texto com no m�ximo ',p_tamanho
            NEXT FIELD conteudo
         END IF
                  
   END INPUT 

   IF INT_FLAG THEN
      LET INT_FLAG = FALSE
      RETURN
   END IF

   CALL pol1099_grava_tmp()
               
END FUNCTION

#--------------------------#
FUNCTION pol1099_grava_tmp()
#--------------------------#

   DELETE FROM linha_tmp_912
    WHERE cod_item   = p_cod_item  
      AND cod_operac = pr_coluna[p_index].cod_operac
      AND seq_oper   = pr_coluna[p_index].seq_oper

   IF STATUS <> 0 THEN
      CALL log003_err_sql('Delete','linha_tmp_912')  
      RETURN
   END IF    

   FOR m_ind = 1 TO 6
          INSERT INTO linha_tmp_912
           VALUES(p_cod_item,
                  pr_coluna[p_index].cod_operac,
                  pr_coluna[p_index].cod_roteiro,
                  pr_coluna[p_index].seq_oper,
                  pr_linha[m_ind].linha,
                  pr_linha[m_ind].conteudo)
                  
          IF STATUS <> 0 THEN
             CALL log003_err_sql('Insert','linha_tmp_912')  
             EXIT FOR
          END IF    
   END FOR

END FUNCTION

#-----------------------#
 FUNCTION pol1099_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)
      
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1099
         
         IF p_codigo IS NOT NULL THEN
           LET p_cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE 

END FUNCTION 

#-----------------------------------#
 FUNCTION pol1099_grava_op_conteudo()
#-----------------------------------#
   
   DELETE 
     FROM op_col_dados_912
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Delete','op_col_dados_912')
      RETURN FALSE
   END IF

   DECLARE cq_col_tmp CURSOR FOR
    SELECT cod_operac,
           cod_roteiro,
           seq_oper,
           linha,
           conteudo
      FROM linha_tmp_912
     WHERE cod_item = p_cod_item
     ORDER BY cod_operac, seq_oper

   FOREACH cq_col_tmp INTO              
           p_cod_operac,
           p_cod_roteiro,
           p_seq_oper,
           p_linha,
           p_conteudo
          
      INSERT INTO op_col_dados_912
		    VALUES (p_cod_empresa,
		            p_cod_item,
		            p_cod_operac,
		            p_cod_roteiro,
		            p_seq_oper,
		            p_linha,
		            p_conteudo)
		
		  IF STATUS <> 0 THEN 
		     CALL log003_err_sql("Incluindo", "op_col_dados_912")
         RETURN FALSE
      END IF
		          
   END FOREACH
     
   RETURN TRUE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1099_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_item_ant = p_cod_item
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      op_col_dados_912.cod_item
      
      ON KEY (control-z)
         CALL pol1099_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_item = p_cod_item_ant
         CALL pol1099_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_item ",
                  "  FROM op_col_dados_912 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1099_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1099_exibe_dados()
#------------------------------#

   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','item')
      RETURN FALSE 
   END IF
   
   DISPLAY p_cod_item TO cod_item
   DISPLAY p_den_item TO den_item
        
   IF NOT pol1099_carrega_coluna() THEN
      RETURN FALSE
   END IF
   
   CALL pol1099_edita_coluna('C') RETURNING p_status
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
 FUNCTION pol1099_carrega_coluna()
#---------------------------------#
   
   INITIALIZE pr_coluna, pr_linha TO NULL
   
   DELETE FROM linha_tmp_912
   
   LET p_index = 1
   
   DECLARE cq_exibe CURSOR FOR
    SELECT DISTINCT
           cod_roteiro,
           cod_operac,
           seq_oper,
           cod_coluna
      FROM op_coluna_item_912
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
     ORDER BY cod_operac, seq_oper
   
   FOREACH cq_exibe INTO    
           pr_coluna[p_index].cod_roteiro,
           pr_coluna[p_index].cod_operac,
           pr_coluna[p_index].seq_oper,
           p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "op_coluna_item_912:cq_exibe")
         RETURN FALSE
      END IF
      
      SELECT coluna,
             tamanho
        INTO pr_coluna[p_index].coluna,
             pr_coluna[p_index].tamanho
        FROM op_coluna_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_coluna  = p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "op_coluna_912:cq_exibe")
         RETURN FALSE
      END IF

      DECLARE cq_le_lin CURSOR FOR
       SELECT linha,
              conteudo
         FROM op_col_dados_912
        WHERE cod_empresa = p_cod_empresa
          AND cod_item    = p_cod_item
          AND cod_operac  = pr_coluna[p_index].cod_operac
          AND seq_oper    = pr_coluna[p_index].seq_oper
        ORDER BY linha

      FOREACH cq_le_lin INTO p_linha, p_conteudo
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "op_col_dados_912:cq_le_lin")
            RETURN FALSE
         END IF

         INSERT INTO linha_tmp_912
           VALUES(p_cod_item,
                  pr_coluna[p_index].cod_operac,
                  pr_coluna[p_index].cod_roteiro,
                  pr_coluna[p_index].seq_oper,
                  p_linha,
                  p_conteudo)
      
         IF STATUS <> 0 THEN
            CALL log003_err_sql('Insert','linha_tmp_912')  
            RETURN FALSE
         END IF    
      
      END FOREACH
            
      LET p_index = p_index + 1
      
      IF p_index > 300 THEN
         LET p_msg = 'Limite de opera�oes\n do item ultrapassou'
         CALL log0030_mensagem(p_msg,'info')
         EXIT FOREACH
      END IF
      
   END FOREACH
         
   CALL SET_COUNT(p_index - 1)
     
   {INPUT ARRAY pr_coluna WITHOUT DEFAULTS FROM sr_coluna.*
      BEFORE INPUT
         EXIT INPUT
   END INPUT}
   
   RETURN TRUE
   
END FUNCTION 

#-----------------------------------#
 FUNCTION pol1099_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_item_ant = p_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_item)
           INTO p_count
           FROM op_col_dados_912
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "op_coluna_item_912")
            RETURN FALSE
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1099_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_cod_item = p_cod_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1099_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM op_col_dados_912  
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","op_coluna_item_912")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1099_modificacao()
#-----------------------------#
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'

   IF NOT pol1099_carrega_coluna() THEN
      RETURN FALSE
   END IF
   
   IF pol1099_prende_registro() THEN
      IF pol1099_edita_coluna('M') THEN  
         CALL log085_transacao("BEGIN")
         IF pol1099_grava_op_conteudo() THEN
            CALL log085_transacao("COMMIT")
            CLOSE cq_prende
            RETURN TRUE                                                                    
         ELSE
            CALL log085_transacao("ROLLBACK")
         END IF
      END IF
      CLOSE cq_prende
   END IF

   RETURN FALSE
   
END FUNCTION

#--------------------------#
 FUNCTION pol1099_exclusao()
#--------------------------#

   IF p_cod_item IS NULL THEN
      LET p_msg = 'N�o a dados na tela a serem exclu�dos!'
      CALL log0030_mensagem(p_msg,'excla')
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1099_prende_registro() THEN
      DELETE FROM op_col_dados_912
			 WHERE cod_empresa = p_cod_empresa
			   AND cod_item    = p_cod_item
         
      IF STATUS = 0 THEN               
         INITIALIZE p_cod_item, pr_coluna TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","op_coluna_item_912")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#--------------------------#
 FUNCTION pol1099_listar()
#--------------------------#     

   IF NOT pol1099_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1099_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_imp CURSOR FOR
    SELECT cod_item,
           cod_operac,
           seq_oper,
           linha,
           conteudo
      FROM op_col_dados_912
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_item, cod_operac, seq_oper, linha                         
  
   FOREACH cq_imp INTO
           p_cod_item,
           p_cod_operac,
           p_seq_oper,
           p_linha,
           p_conteudo
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'op_col_dados_912:cq_imp')
         RETURN
      END IF 
   
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'item:cq_imp')
         EXIT FOREACH
      END IF                                                             
      
      SELECT den_operac
        INTO p_den_operac
        FROM operacao
       WHERE cod_empresa = p_cod_empresa
         AND cod_operac  = p_cod_operac
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','operacao:cq_imp')    
         RETURN FALSE
      END IF
                                                                                
      SELECT cod_coluna
        INTO p_cod_coluna
        FROM op_coluna_item_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
         AND cod_operac  = p_cod_operac
         AND seq_oper    = p_seq_oper
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_item_912:cq_imp')    
         RETURN FALSE
      END IF
      
      SELECT coluna
        INTO p_den_coluna
        FROM op_coluna_912
       WHERE cod_empresa = p_cod_empresa
         AND cod_coluna  = p_cod_coluna
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','op_coluna_912:cq_imp')    
         RETURN FALSE
      END IF
      
      OUTPUT TO REPORT pol1099_relat(p_cod_item) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1099_relat   
   
   IF p_count = 0 THEN
      ERROR "N�o existem dados h� serem listados !!!"
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relat�rio gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1099_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1099.tmp"
         START REPORT pol1099_relat TO p_caminho
      ELSE
         START REPORT pol1099_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1099_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#--------------------------------#
 REPORT pol1099_relat(p_cod_item)
#--------------------------------#
    
   DEFINE p_cod_item LIKE item.cod_item
   
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 122, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol1099",
               COLUMN 048, "CONTEUDO DAS COLUNAS",
               COLUMN 102, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "-----------------------------------------------------------------------------------------------------------------------------------"
         PRINT
               
      BEFORE GROUP OF p_cod_item
         
         PRINT
         PRINT COLUMN 003, "Item: ", p_cod_item, " - ", p_den_item
         PRINT
         PRINT COLUMN 001, 'Operac          Descricao                  Coluna       Linha                        Conteudo'
         PRINT COLUMN 001, '------ ----------------------------- ------------------ ----- ---------------------------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 001, p_cod_operac,
               COLUMN 008, p_den_operac,
               COLUMN 038, p_den_coluna,
               COLUMN 059, p_linha USING '&',
               COLUMN 063, p_conteudo
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------- FIM DE PROGRAMA -----------------------------#

