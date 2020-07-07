#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1141                                                 #
# OBJETIVO: CADASTRO DE GRUPOS                                      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 01/04/12                                                #
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
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
         
  
   DEFINE p_grupo_item_509     RECORD LIKE grupo_item_509.*

   DEFINE p_consulta           RECORD
          grupo_item           LIKE grupo_item_509.grupo_item,
          cod_item             LIKE grupo_item_509.cod_item
   END RECORD
   
   DEFINE p_consulta_ant       RECORD
          grupo_item           LIKE grupo_item_509.grupo_item,
          cod_item             LIKE grupo_item_509.cod_item
   END RECORD   
          
   DEFINE p_den_item           LIKE item.den_item,
          p_den_grupo          LIKE grupo_ctr_estoq.den_gru_ctr_estoq,
          p_den_item_reduz     LIKE item.den_item_reduz
          
   DEFINE p_relat              RECORD 
          grupo_item           LIKE grupo_item_509.grupo_item,
          cod_item             LIKE grupo_item_509.cod_item
   END RECORD      
         
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1141-10.03.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
  
   IF p_status = 0 THEN
      CALL pol1141_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1141_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1141") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1141 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1141_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1141_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1141_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1141_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1141_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_consulta.grupo_item TO grupo_item
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1141_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1141_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1141_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1141

END FUNCTION

#--------------------------#
 FUNCTION pol1141_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_grupo_item_509.* TO NULL
   LET p_grupo_item_509.cod_empresa = p_cod_empresa
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1141_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO grupo_item_509 VALUES (p_grupo_item_509.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","grupo_item_509")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1141_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_grupo_item_509.*
      WITHOUT DEFAULTS
   
      BEFORE FIELD grupo_item
      IF p_funcao = "M" THEN
         NEXT FIELD cod_item
      END IF
      
      AFTER FIELD grupo_item
      IF p_grupo_item_509.grupo_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD grupo_item   
      END IF
          
      SELECT cod_item
        FROM grupo_item_509
       WHERE cod_empresa = p_cod_empresa
         AND grupo_item  = p_grupo_item_509.grupo_item
         
      IF STATUS = 0 THEN 
         ERROR 'Grupo já cadastrado !!!'
         NEXT FIELD grupo_item
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','grupo_item_509')
            RETURN FALSE
         END IF 
      END IF  
      
      SELECT den_gru_ctr_estoq
        INTO p_den_grupo
        FROM grupo_ctr_estoq
       WHERE cod_empresa   = p_cod_empresa
         AND gru_ctr_estoq = p_grupo_item_509.grupo_item
      
      IF STATUS = 100 THEN 
         ERROR 'Grupo não cadastrado !!!'
         NEXT FIELD grupo_item
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','grupo_ctr_estoq')
            RETURN FALSE
         END IF 
      END IF
      
      DISPLAY p_den_grupo TO den_grupo
      
      AFTER FIELD cod_item
      IF p_grupo_item_509.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item   
      END IF
      
      SELECT den_item
        INTO p_den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_grupo_item_509.cod_item
         
      IF STATUS = 100 THEN
         ERROR "Item não cadastrado !!!"
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Lendo", "Item")
            RETURN FALSE
         END IF
      END IF
      
      DISPLAY p_den_item TO den_item
      
      AFTER INPUT
      IF NOT INT_FLAG THEN
         IF p_grupo_item_509.grupo_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD grupo_item   
         END IF
         IF p_grupo_item_509.cod_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         END IF   
      END IF
      
      ON KEY (control-z)
         CALL pol1141_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1141_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(grupo_item)
         CALL log009_popup(8,25,"GRUPO DE CTR ESTOQUE","grupo_ctr_estoq",
              "gru_ctr_estoq","den_gru_ctr_estoq","","S","1=1 order by den_gru_ctr_estoq") 
         RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1141
         IF p_codigo IS NOT NULL THEN
            LET p_grupo_item_509.grupo_item = p_codigo CLIPPED
            DISPLAY p_codigo TO grupo_item
         END IF
     
      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1141
         IF p_codigo IS NOT NULL THEN
           LET p_grupo_item_509.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1141_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   INITIALIZE p_grupo_item_509.* TO NULL
   LET p_grupo_item_509.cod_empresa = p_cod_empresa
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_consulta_ant.* = p_consulta.*
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      grupo_item_509.grupo_item,
      grupo_item_509.cod_item
      
      ON KEY (control-z)
         CALL pol1141_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_consulta.* = p_consulta_ant.*
            CALL pol1141_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT grupo_item, cod_item ",
                  "  FROM grupo_item_509 ",
                  " WHERE ", where_clause CLIPPED,
                  "   and cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY grupo_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_consulta.*

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1141_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1141_exibe_dados()
#------------------------------#
   
   SELECT den_gru_ctr_estoq
     INTO p_den_grupo
     FROM grupo_ctr_estoq
    WHERE cod_empresa   = p_cod_empresa
      AND gru_ctr_estoq = p_consulta.grupo_item
      
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "grupo_ctr_estoq")
      RETURN FALSE
   END IF 
   
   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_consulta.cod_item
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "item")
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_consulta.*             
   DISPLAY p_den_item TO den_item 
   DISPLAY p_den_grupo TO den_grupo
         
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1141_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_consulta_ant.* = p_consulta.*
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_consulta.*
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_consulta.*
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item
           INTO p_consulta.cod_item
           FROM grupo_item_509
          WHERE cod_empresa = p_cod_empresa
            AND grupo_item  = p_consulta.grupo_item
            
         IF STATUS = 0 THEN
            CALL pol1141_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_consulta.* = p_consulta_ant.*
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1141_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT grupo_item 
      FROM grupo_item_509  
     WHERE cod_empresa = p_cod_empresa
       AND grupo_item  = p_consulta.grupo_item
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","grupo_item_509")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1141_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_grupo_item_509.grupo_item = p_consulta.grupo_item 
   
   IF pol1141_prende_registro() THEN
      IF pol1141_edita_dados("M") THEN
         
         UPDATE grupo_item_509
            SET cod_item    = p_grupo_item_509.cod_item
          WHERE cod_empresa = p_cod_empresa
            AND grupo_item  = p_consulta.grupo_item
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "grupo_item_509")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1141_exibe_dados() RETURNING p_status
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
 FUNCTION pol1141_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1141_prende_registro() THEN
      DELETE FROM grupo_item_509
			WHERE cod_empresa = p_cod_empresa
			  AND grupo_item  = p_consulta.grupo_item

      IF STATUS = 0 THEN               
         INITIALIZE p_consulta.* TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","grupo_item_509")
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
 FUNCTION pol1141_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1141_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1141_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT grupo_item,
          cod_item
     FROM grupo_item_509
 ORDER BY grupo_item                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
      
      SELECT den_gru_ctr_estoq
        INTO p_den_grupo
        FROM grupo_ctr_estoq
       WHERE cod_empresa   = p_cod_empresa
         AND gru_ctr_estoq = p_relat.grupo_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql("lendo", "grupo_ctr_estoq")
         RETURN FALSE
      END IF
      
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_relat.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'item')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1141_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1141_relat   
   
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

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1141_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1141.tmp"
         START REPORT pol1141_relat TO p_caminho
      ELSE
         START REPORT pol1141_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1141_le_den_empresa()
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

#---------------------#
 REPORT pol1141_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 071, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1141",
               COLUMN 021, "CADASTRO DE GRUPOS",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, '     Grupo          Descricao                 Item            Descricao     '
         PRINT COLUMN 002, '     ----- ------------------------------ --------------- ------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 007, p_relat.grupo_item USING "##",
               COLUMN 013, p_den_grupo,
               COLUMN 044, p_relat.cod_item,
               COLUMN 060, p_den_item_reduz
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 020, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol1141_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#