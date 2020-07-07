#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1026                                                 #
# OBJETIVO: CADASTRO DE MENSAGENS POR ITEM                          #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 29/03/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_familia        LIKE familia.den_familia,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_ind                SMALLINT 
         
  
   DEFINE p_texto_item_547     RECORD LIKE texto_item_547.*

   DEFINE p_cod_item           LIKE texto_item_547.cod_item,
          p_cod_item_ant       LIKE texto_item_547.cod_item,
          p_den_item_reduz     LIKE item.den_item_reduz
          
   DEFINE p_tela               RECORD
          cod_item             LIKE texto_item_547.cod_item
   END RECORD
   
   DEFINE pr_mensagens         ARRAY[500] OF RECORD 
          sequencia_texto      LIKE texto_item_547.sequencia_texto,
          texto                LIKE texto_item_547.texto
   END RECORD 
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1026-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1026_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1026_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1026") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1026 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1026_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1026_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol1026_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1026_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1026_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1026_modificacao() RETURNING p_retorno  
            IF p_retorno THEN
               DISPLAY p_cod_item TO cod_item
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1026_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol1026_listagem()    
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1026_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1026

END FUNCTION

#-----------------------#
 FUNCTION pol1026_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
 FUNCTION pol1026_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1026_inclusao()
#--------------------------#
   
   CALL pol1026_limpa_tela()
   
   CALL log085_transacao("BEGIN") 
   
   IF NOT pol1026_consiste_item() THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF NOT pol1026_digita_texto("I") THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   IF NOT pol1026_grava_dados() THEN 
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   CALL log085_transacao("COMMIT")
   
   RETURN TRUE 

END FUNCTION

#-------------------------------#
 FUNCTION pol1026_consiste_item()
#-------------------------------#
   
   LET INT_FLAG = FALSE 
   CALL pol1026_limpa_tela()
   INITIALIZE p_tela.* TO NULL
   
   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
      
#------------------- CONSISTINDO O ITEM -------------------# 
         
      AFTER FIELD cod_item
      IF p_tela.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item   
      END IF
          
      SELECT COUNT (cod_item)
        INTO p_count
        FROM texto_item_547
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_tela.cod_item
      
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "texto_item_547")
         RETURN FALSE
      END IF
          
      IF p_count > 0 THEN 
         ERROR 'Item já cadastrado na tabela texto_item_547 !!!'
         NEXT FIELD cod_item
      END IF 
         
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_tela.cod_item
         
      IF STATUS = 100 THEN 
         ERROR "Item não cadastrado na tabela item !!!"
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql("Lendo", "item")
            RETURN FALSE
         END IF 
      END IF 
      
      DISPLAY p_den_item_reduz TO den_item_reduz
      
      ON KEY(control-z)
         CALL pol1026_popup()
            
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1026_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1026_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1026
         IF p_codigo IS NOT NULL THEN
           LET p_tela.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   
   END CASE 
   
END FUNCTION 
   
#----------------------------------------#
 FUNCTION pol1026_digita_texto(p_funcao)
#----------------------------------------#      
   
   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE
   LET p_index = 1 

   IF p_funcao = "I" THEN 
      INITIALIZE pr_mensagens TO NULL
   END IF 
   
   INPUT ARRAY pr_mensagens
      WITHOUT DEFAULTS FROM sr_mensagens.*
      ATTRIBUTES(INSERT ROW = FALSE)
      
      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
       
         LET pr_mensagens[p_index].sequencia_texto = p_index
         #DISPLAY p_index TO sr_mensagens[s_index].sequencia_texto
         
#------------------ CONSISTINDO O TEXTO ------------------# 
         
         BEFORE FIELD texto
            DISPLAY p_index TO sr_mensagens[s_index].sequencia_texto   
                
         AFTER FIELD texto
         
         IF FGL_LASTKEY() = FGL_KEYVAL("DOWN")   OR 
            FGL_LASTKEY() = FGL_KEYVAL("RETURN") THEN  
         
            IF pr_mensagens[p_index].texto IS NULL THEN 
               ERROR 'O texto não pode ser nulo !!!'
               NEXT FIELD texto
            END IF
         END IF          
   
   END INPUT 
      
   IF INT_FLAG THEN
      RETURN FALSE
   ELSE
      LET INT_FLAG = TRUE
      RETURN TRUE
   END IF   
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1026_grava_dados()
#-----------------------------#  

   IF NOT pol1026_deleta_dados() THEN 
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF p_ind                     IS NOT NULL AND
          pr_mensagens[p_ind].texto IS NOT NULL THEN
          
		       INSERT INTO texto_item_547
		       VALUES (p_cod_empresa,
		               p_tela.cod_item,
		               p_ind,
		               pr_mensagens[p_ind].texto)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Gravando","texto_item_547")
		          RETURN FALSE
		       END IF
      
       END IF
   END FOR
                  
   RETURN TRUE
      
END FUNCTION 
   
#------------------------------#
 FUNCTION pol1026_deleta_dados()
#------------------------------#

   DELETE FROM texto_item_547
         WHERE cod_empresa = p_cod_empresa
           AND cod_item    = p_tela.cod_item
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Deletando", "texto_item_547")
      RETURN FALSE
   END IF 
   
   RETURN TRUE 
   
END FUNCTION           
  
#--------------------------#
 FUNCTION pol1026_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1026_limpa_tela()
      
   LET p_cod_item_ant = p_cod_item
   LET INT_FLAG       = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      texto_item_547.cod_item
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_item = p_cod_item_ant
         CALL pol1026_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT DISTINCT cod_item",
                  "  FROM texto_item_547 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1026_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1026_exibe_dados()
#------------------------------#

   IF NOT pol1026_carrega_array() THEN 
      RETURN FALSE
   END IF 
   
   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "Item")
      RETURN FALSE
   END IF 
   
   DISPLAY p_cod_item                            TO cod_item
   DISPLAY p_den_item_reduz                      TO den_item_reduz
   
   CALL SET_COUNT(p_index - 1)

   INPUT ARRAY pr_mensagens WITHOUT DEFAULTS FROM sr_mensagens.*
      BEFORE INPUT
      EXIT INPUT
   END INPUT
   
   RETURN TRUE
   
END FUNCTION

#-------------------------------#
 FUNCTION pol1026_carrega_array()
#-------------------------------#
   
   LET p_index = 1
   
   DECLARE cq_array CURSOR FOR
   
   SELECT sequencia_texto,
          texto
     FROM texto_item_547
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   FOREACH cq_array
      INTO pr_mensagens[p_index].sequencia_texto,
           pr_mensagens[p_index].texto
           
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("Lendo", "Cursor: cq_array")
         RETURN FALSE
      END IF
      
      LET p_index = p_index + 1
      
      IF p_index > 1000 THEN 
         ERROR "Limite de grade ultrapassado !!!"
         EXIT FOREACH
      END IF 
      
   END FOREACH 
   
   RETURN TRUE
   
END FUNCTION  

#-----------------------------------#
 FUNCTION pol1026_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_item_ant = p_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
         
      END CASE

      IF STATUS = 0 THEN
         SELECT DISTINCT cod_item
           FROM texto_item_547
          WHERE cod_empresa = p_cod_empresa
            AND cod_item    = p_cod_item
             
         IF STATUS = 0 THEN
            CALL pol1026_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_item = p_cod_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1026_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    
    SELECT cod_item 
      FROM texto_item_547  
     WHERE cod_empresa = p_cod_empresa
       AND cod_item    = p_cod_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","texto_item_547")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1026_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1026_prende_registro() THEN
      IF pol1026_digita_texto("M") THEN
         LET p_tela.cod_item = p_cod_item
         IF pol1026_grava_dados() THEN    
            LET p_retorno = TRUE 
         END IF 
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
 FUNCTION pol1026_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1026_prende_registro() THEN
      DELETE FROM texto_item_547
			WHERE cod_item = p_cod_item
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_texto_item_547 TO NULL
         CALL pol1026_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","texto_item_547")
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
 FUNCTION pol1026_listagem()
#--------------------------#     

   IF NOT pol1026_escolhe_saida() THEN
   		RETURN 
   END IF
   
   IF NOT pol1026_le_empresa() THEN
      RETURN
   END IF 
      
   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT cod_item,
           sequencia_texto,
           texto
      FROM texto_item_547
     ORDER BY cod_item, sequencia_texto
   
   FOREACH cq_impressao INTO 
           p_cod_item,
           p_texto_item_547.sequencia_texto,
           p_texto_item_547.texto
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','texto_item_547:cq_impressao')
         EXIT FOREACH
      END IF      
      
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','item')
         EXIT FOREACH
      END IF
      
      OUTPUT TO REPORT pol1026_relat(p_cod_item) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1026_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF
  
END FUNCTION 

#-------------------------------#
 FUNCTION pol1026_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1026.tmp"
         START REPORT pol1026_relat TO p_caminho
      ELSE
         START REPORT pol1026_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#----------------------------#
 FUNCTION pol1026_le_empresa()
#----------------------------#

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

#-------------------------------#
 REPORT pol1026_relat(p_cod_item)
#-------------------------------#
   
   DEFINE p_cod_item CHAR(15)
   
   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
   
   ORDER EXTERNAL BY p_cod_item
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001, p_den_empresa,
               COLUMN 070, "PAG.: ", PAGENO USING "####&" 
               
         PRINT COLUMN 001, "pol1026",
               COLUMN 016, "CADASTRO DE MENSAGENS POR ITEM",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         
      BEFORE GROUP OF p_cod_item
         
         SKIP 3 LINES 
         PRINT COLUMN 021, "Item: ",p_cod_item, ' - ', p_den_item_reduz
         PRINT
         PRINT COLUMN 001, '    Sequência                         Mensagem'
         PRINT COLUMN 001, '    ---------- ------------------------------------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 005, p_texto_item_547.sequencia_texto USING "##########",
               COLUMN 016, p_texto_item_547.texto 
         
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