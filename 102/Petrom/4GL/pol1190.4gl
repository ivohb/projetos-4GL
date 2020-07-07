#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1190                                                 #
# OBJETIVO: CADASTRO DE PERGUNTAS P/ ANALISE DE CRÉDITO             #
# AUTOR...: IVO H BARBOSA                                           #
# DATA....: 18/04/2013                                              #
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
          p_excluiu            SMALLINT,
          p_opcao              CHAR(01),
          p_ind                INTEGER,
          s_ind                INTEGER
         
  
   DEFINE p_perguntas_455  RECORD LIKE perguntas_455.*
          
   DEFINE p_cod_pergunta      LIKE perguntas_455.cod_pergunta,
          p_cod_perguntaa     LIKE perguntas_455.cod_pergunta
          
END GLOBALS

DEFINE sql_stmt, where_clause CHAR(500)  

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1190-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1190_menu()
   END IF
   
END MAIN

#----------------------#
 FUNCTION pol1190_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1190") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1190 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1190_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1190_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1190_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1190_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1190_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_pergunta TO cod_pergunta
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1190_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1190_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1190_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1190

END FUNCTION

#-----------------------#
 FUNCTION pol1190_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#---------------------------#
FUNCTION pol1190_limpa_tela()
#---------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol1190_inclusao()
#--------------------------#

   CALL pol1190_limpa_tela()
   INITIALIZE p_perguntas_455 TO NULL
   LET p_perguntas_455.tipo = 'C'
   LET p_perguntas_455.val_comparativo = 0
   LET p_perguntas_455.condicao_debitar = ' '
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1190_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      IF pol1190_insere() THEN
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
   END IF
   
   CALL pol1190_limpa_tela()
   RETURN FALSE

END FUNCTION

#------------------------#
FUNCTION pol1190_insere()
#------------------------#

   INSERT INTO perguntas_455 VALUES (p_perguntas_455.*)

   IF STATUS <> 0 THEN 
	    CALL log003_err_sql("incluindo","perguntas_455")       
      RETURN FALSE
   END IF
     
   RETURN TRUE

END FUNCTION
   
#-------------------------------------#
 FUNCTION pol1190_edita_dados(p_opcao)
#-------------------------------------#

   DEFINE p_opcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT BY NAME p_perguntas_455.*
      WITHOUT DEFAULTS
                       
      BEFORE FIELD cod_pergunta

         IF p_opcao = "M" THEN
            NEXT FIELD descricao
         END IF
      
      AFTER FIELD cod_pergunta

         IF p_perguntas_455.cod_pergunta IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_pergunta   
         END IF

         IF pol1190_registro_existe() THEN
            ERROR 'Pergunta já existente.'
            NEXT FIELD cod_pergunta
         END IF

      AFTER FIELD tipo
         IF p_perguntas_455.tipo = 'R' THEN
            LET p_perguntas_455.val_comparativo = 0
            DISPLAY 0 TO val_comparativo
         END IF
      
      BEFORE FIELD val_comparativo
         IF p_perguntas_455.tipo = 'R' THEN
            NEXT FIELD pct_peso
         END IF

      AFTER FIELD condicao_debitar
         IF NOT valida_condicao() THEN
            NEXT FIELD condicao_debitar
         END IF
         
      AFTER INPUT
         IF NOT INT_FLAG THEN
            IF p_perguntas_455.descricao IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD descricao   
            END IF
            IF p_perguntas_455.pct_peso IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD pct_peso   
            END IF
            IF p_perguntas_455.val_comparativo IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD val_comparativo   
            END IF
            IF p_perguntas_455.condicao_debitar IS NULL THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD condicao_debitar   
            END IF
         END IF

      ON KEY (control-z)
         CALL pol1190_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#---------------------------------#
FUNCTION pol1190_registro_existe()#
#---------------------------------#

   SELECT descricao
     FROM perguntas_455
    WHERE cod_pergunta = p_perguntas_455.cod_pergunta
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF
   
END FUNCTION   

#-------------------------#
FUNCTION valida_condicao()#
#-------------------------#

   IF p_perguntas_455.condicao_debitar = '>'  OR
      p_perguntas_455.condicao_debitar = '>=' OR
      p_perguntas_455.condicao_debitar = '<'  OR
      p_perguntas_455.condicao_debitar = '<=' OR
      p_perguntas_455.condicao_debitar = '='  OR
      p_perguntas_455.condicao_debitar = '<>' THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   

#-----------------------#
 FUNCTION pol1190_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      
      WHEN INFIELD(condicao_debitar)
         LET p_codigo = pol1190_exibe_simbolos()
                   
         IF p_codigo IS NOT NULL THEN
            LET p_perguntas_455.condicao_debitar = p_codigo CLIPPED
            DISPLAY p_codigo TO condicao_debitar
         END IF
      
   END CASE 

END FUNCTION 

#-------------------------------#
FUNCTION pol1190_exibe_simbolos()
#-------------------------------#

   DEFINE pr_simbolo           ARRAY[6] OF RECORD
          simbolo              CHAR(02)
   END RECORD

   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1190a") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1190a AT 20,60 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)

   LET INT_FLAG = FALSE
   
   LET p_ind = 6
   LET pr_simbolo[1].simbolo = '>'
   LET pr_simbolo[2].simbolo = '>='
   LET pr_simbolo[3].simbolo = '<'
   LET pr_simbolo[4].simbolo = '<='
   LET pr_simbolo[5].simbolo = '='
   LET pr_simbolo[6].simbolo = '<>'
   
   
   CALL SET_COUNT(p_ind)
      
   DISPLAY ARRAY pr_simbolo TO sr_simbolo.*

      LET p_ind = ARR_CURR()
      LET s_ind = SCR_LINE() 
      
   CLOSE WINDOW w_pol1190a
   
   IF NOT INT_FLAG THEN
      RETURN pr_simbolo[p_ind].simbolo
   ELSE
      RETURN NULL
   END IF
   
END FUNCTION
            
#--------------------------#
 FUNCTION pol1190_consulta()
#--------------------------#

   CALL pol1190_limpa_tela()
   LET p_cod_perguntaa = p_cod_pergunta
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      perguntas_455.cod_pergunta,
      perguntas_455.descricao,
      perguntas_455.tipo,
      perguntas_455.pct_peso
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CALL pol1190_limpa_tela()
         ELSE
            LET p_cod_pergunta = p_cod_perguntaa
            CALL pol1190_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt = "SELECT cod_pergunta, descricao ",
                  "  FROM perguntas_455 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY descricao"

   IF p_opcao = 'L' THEN
      RETURN TRUE
   END IF

   LET p_excluiu = FALSE

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_pergunta

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1190_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1190_exibe_dados()
#------------------------------#

   SELECT *
     INTO p_perguntas_455.*
     FROM perguntas_455
    WHERE cod_pergunta = p_cod_pergunta
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "perguntas_455")
      RETURN FALSE
   END IF
   
   DISPLAY BY NAME p_perguntas_455.*

   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1190_paginacao(p_opcao)
#-----------------------------------#

   DEFINE p_opcao CHAR(01)

   LET p_cod_perguntaa = p_cod_pergunta
   
   WHILE TRUE
      CASE
         WHEN p_opcao = "S" FETCH NEXT cq_padrao INTO p_cod_pergunta
                                                       
         WHEN p_opcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_pergunta
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_pergunta
           FROM perguntas_455
          WHERE cod_pergunta = p_cod_pergunta
            
         IF STATUS = 0 THEN
            CALL pol1190_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_pergunta = p_cod_perguntaA
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1190_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_pergunta 
      FROM perguntas_455  
     WHERE cod_pergunta = p_cod_pergunta
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","perguntas_455")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1190_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   
   IF pol1190_prende_registro() THEN
      IF pol1190_edita_dados("M") THEN
         IF pol11163_atualiza() THEN
            LET p_retorno = TRUE
         END IF
      ELSE
         CALL pol1190_exibe_dados() RETURNING p_status
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
FUNCTION pol11163_atualiza()
#--------------------------#

   UPDATE perguntas_455
      SET perguntas_455.* = p_perguntas_455.*
    WHERE cod_pergunta = p_cod_pergunta
       
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Modificando", "perguntas_455")
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION   

#--------------------------#
 FUNCTION pol1190_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1190_prende_registro() THEN
      IF pol1190_deleta() THEN
         INITIALIZE p_perguntas_455 TO NULL
         CALL pol1190_limpa_tela()
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
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

#------------------------#
FUNCTION pol1190_deleta()
#------------------------#

   DELETE FROM perguntas_455
    WHERE cod_pergunta = p_cod_pergunta

   IF STATUS <> 0 THEN               
      CALL log003_err_sql("Excluindo","perguntas_455")
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION   

#--------------------------#
 FUNCTION pol1190_listagem()
#--------------------------#     
   
   LET p_cod_perguntaa = p_cod_pergunta
   
   LET p_opcao = 'L'
   
   IF NOT pol1190_consulta() THEN
      ERROR 'Operação cancelada.'
      RETURN FALSE
   END IF
   
   IF NOT pol1190_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1190_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   PREPARE query FROM sql_stmt   
   DECLARE cq_impressao CURSOR  FOR query

   FOREACH cq_impressao 
      INTO p_cod_pergunta
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_impressao')
         RETURN
      END IF 

      SELECT *
        INTO p_perguntas_455.*
        FROM perguntas_455
       WHERE cod_pergunta = p_cod_pergunta

      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'perguntas_455:cq_impressao')
         RETURN
      END IF 
   
      OUTPUT TO REPORT pol1190_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1190_relat   
   
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

   IF p_ies_cons THEN
      LET p_cod_pergunta = p_cod_perguntaa
      CALL pol1190_exibe_dados()
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1190_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1190_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1190.tmp'
         START REPORT pol1190_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1190_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1190_le_den_empresa()
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
 REPORT pol1190_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 000, "pol1190",
               COLUMN 019, "PERGUNTAS PARA ANALISE DE CREDITO",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'CODIGO DESCRICAO                                TIPO       %PESO VR COMPARATIVO'
         PRINT COLUMN 001, '------ ---------------------------------------- ---------- ----- --------------'

      PAGE HEADER  
         
         PRINT COLUMN 072, "PAG. ", PAGENO USING "##&"
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, 'CODIGO DESCRICAO                                TIPO       %PESO VR COMPARATIVO'
         PRINT COLUMN 001, '------ ---------------------------------------- ---------- ----- --------------'

      ON EVERY ROW

         PRINT COLUMN 001, p_perguntas_455.cod_pergunta,
               COLUMN 008, p_perguntas_455.descricao,
               COLUMN 049, p_perguntas_455.tipo,
               COLUMN 060, p_perguntas_455.pct_peso USING '#&.&&',
               COLUMN 066, p_perguntas_455.val_comparativo USING '###,###,##&.&&'
         
      ON LAST ROW
        
        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT


#-------------------------------- FIM DE PROGRAMA -----------------------------#