#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1191                                                 #
# OBJETIVO: FÓRMULA PARA AS PERGUNTAS CALCULADAS                    #
# AUTOR...: IVO BL                                                  #
# DATA....: 22/04/2013                                              #
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
          p_opcao              CHAR(01),
          p_excluiu            SMALLINT
                   
END GLOBALS

DEFINE pr_operando         ARRAY[100] OF RECORD
       num_sequencia       LIKE formulas_455.num_sequencia,
       operando            LIKE formulas_455.operando,
       tipo                LIKE formulas_455.tipo,
       desc_indic          LIKE indicadores_455.descricao
END RECORD

DEFINE p_cod_pergunta      LIKE perguntas_455.cod_pergunta,
       p_cod_perguntaa     LIKE perguntas_455.cod_pergunta,
       p_descricao         LIKE perguntas_455.descricao,
       p_tipo              LIKE perguntas_455.tipo,
       p_formula           LIKE analise_pergunta_455.formula,
       p_den_indicador     LIKE indicadores_455.descricao

DEFINE sql_stmt            CHAR(500),
       where_clause        CHAR(500)  

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1191-10.02.03"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
            
   IF p_status = 0 THEN
      CALL pol1191_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1191_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1191") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1191 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1191_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            CALL pol1191_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1191_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1191_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1191_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1191_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1191_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem dos registros cadastrados."
         LET p_opcao = 'L'
         CALL pol1191_listagem() 
         LET p_opcao = ''
         IF p_ies_cons THEN
            LET p_cod_pergunta  = p_cod_perguntaa 
            CALL pol1191_exibe_dados()
         END IF
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1191_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1191

END FUNCTION

#----------------------------#
FUNCTION pol1191_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#-----------------------#
 FUNCTION pol1191_sobre()
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

#--------------------------#
 FUNCTION pol1191_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_pergunta TO NULL
   LET p_opcao = 'I'
   
   IF pol1191_edita_cabec() THEN      
      IF pol1191_edita_itens() THEN      
         IF pol1191_grava_dados() THEN                                                     
            RETURN TRUE                                                                    
         END IF                                                                      
      END IF
   END IF
   
   RETURN FALSE
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1191_edita_cabec()
#-----------------------------#
   
   LET INT_FLAG = FALSE
   
   INPUT p_cod_pergunta WITHOUT DEFAULTS FROM cod_pergunta
            
      AFTER FIELD cod_pergunta
         IF p_cod_pergunta IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_pergunta   
         END IF
                            
         SELECT descricao,
                tipo
           INTO p_descricao,
                p_tipo
           FROM perguntas_455
          WHERE cod_pergunta = p_cod_pergunta
       
         IF STATUS = 100 THEN
            ERROR "Pergunta inixistente."
            NEXT FIELD cod_pergunta
         ELSE
            IF STATUS <> 0 THEN
               CALL log003_err_sql('lendo','perguntas_455')
               RETURN FALSE
            END IF 
         END IF

         DISPLAY p_descricao TO descricao
         DISPLAY p_tipo TO tipo_p

         IF p_tipo = 'C' THEN
         ELSE
            ERROR "Somente pergunta (C)alculada deve ter fórmula"
            NEXT FIELD cod_pergunta
         END IF
         
      ON KEY (control-z)
         CALL pol1191_popup()
      
   END INPUT 

   IF INT_FLAG THEN
      RETURN FALSE
   END IF
   
   IF NOT pol1191_le_itens() THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1191_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_pergunta)
         CALL log009_popup(8,25,"PERGUNTAS","perguntas_455",
                     "cod_pergunta","descricao","pol1190","N","tipo = 'C' order by descricao") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)

         IF p_codigo IS NOT NULL THEN
            LET p_cod_pergunta = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_pergunta
         END IF

      WHEN INFIELD(operando)
         CALL log009_popup(8,25,"INDICADORES","indicadores_455",
                     "cod_indicador","descricao","","N","1=1 order by descricao") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07",p_versao)

         IF p_codigo IS NOT NULL THEN
            LET pr_operando[p_index].operando = p_codigo CLIPPED
            DISPLAY p_codigo TO sr_operando[s_index].operando
         END IF

   END CASE
   
END FUNCTION 

#--------------------------#
FUNCTION pol1191_le_itens()#
#--------------------------#

   INITIALIZE pr_operando TO NULL
   LET p_index = 1
   
   DECLARE cq_itens CURSOR FOR
    SELECT num_sequencia,
           operando, 
           tipo, ""
      FROM formulas_455 
     WHERE cod_pergunta = p_cod_pergunta
     ORDER BY num_sequencia
   
   FOREACH cq_itens INTO pr_operando[p_index].*
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH','cq_itens')
         RETURN FALSE
      END IF

      IF pr_operando[p_index].tipo = 'I' THEN
         LET pr_operando[p_index].desc_indic = pol1191_le_indicador(pr_operando[p_index].operando)
      END IF
      
      LET p_index = p_index + 1
   
   END FOREACH
   
   CALL SET_COUNT(p_index - 1)
   
   IF p_opcao = 'L' THEN
   ELSE
      INPUT ARRAY pr_operando 
         WITHOUT DEFAULTS FROM sr_operando.*
            BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF
   
   CALL pol1191_monta_formula()
   
   RETURN TRUE

END FUNCTION

#--------------------------------------#
FUNCTION pol1191_le_indicador(p_codigo)#
#--------------------------------------#

   DEFINE p_den_ind LIKE indicadores_455.descricao,
          p_codigo  LIKE indicadores_455.cod_indicador
   
   SELECT descricao
     INTO p_den_ind
     FROM indicadores_455
    WHERE cod_indicador = p_codigo
   
   IF STATUS <> 0 THEN
      LET p_den_ind = ''
   END IF
   
   RETURN p_den_ind

END FUNCTION
   

#------------------------------#
 FUNCTION pol1191_edita_itens()#
#------------------------------#     

   INPUT ARRAY pr_operando
      WITHOUT DEFAULTS FROM sr_operando.*
         ATTRIBUTES(INSERT ROW = TRUE, DELETE ROW = TRUE)

      BEFORE ROW
         LET p_index = ARR_CURR()
         LET s_index = SCR_LINE()  
      
      BEFORE FIELD operando
         CALL pol1191_exib_sequencia()
      
      AFTER FIELD operando
      
         IF pr_operando[p_index].operando IS NULL  OR pr_operando[p_index].operando = ' ' THEN
            IF FGL_LASTKEY() = 27 OR FGL_LASTKEY() = 2000 OR FGL_LASTKEY() = 4010
                 OR FGL_LASTKEY() = 2016 OR FGL_LASTKEY() = 2 THEN
            ELSE
               ERROR 'Campo com preenchimento obrigatório'
               NEXT FIELD operando
            END IF
         END IF

      BEFORE FIELD tipo

         IF pr_operando[p_index].operando IS NULL THEN
            NEXT FIELD operando
         END IF

      AFTER FIELD tipo

         IF pr_operando[p_index].tipo IS NULL THEN
         ERROR 'Campo com preenchimento obrigatório'
            NEXT FIELD tipo
         END IF

         IF pr_operando[p_index].tipo = 'I' THEN
            LET p_den_indicador = pol1191_le_indicador(pr_operando[p_index].operando)
            IF p_den_indicador IS NULL THEN
               CALL log0030_mensagem('Indicador inexistente!','excla')
               NEXT FIELD tipo
            END IF
            
         ELSE
            LET p_den_indicador = ''
         END IF
         
         DISPLAY p_den_indicador TO sr_operando[s_index].desc_indic
                     
         AFTER DELETE
            CALL pol1191_exib_sequencia()

         AFTER INSERT
            CALL pol1191_exib_sequencia()
         
         AFTER INPUT
            IF NOT INT_FLAG THEN
               FOR p_ind = 1 TO ARR_COUNT()
                   IF pr_operando[p_ind].operando IS NOT NULL THEN
                      IF pr_operando[p_ind].tipo IS NULL THEN
                         ERROR 'Preencha o tipo de todas as linhas da grade'
                         NEXT FIELD tipo
                      END IF
                   END IF
                END FOR
             END IF
         
         ON KEY (control-z)
            CALL pol1191_popup()

   END INPUT 

   IF INT_FLAG THEN
      IF p_opcao = 'I' THEN
         CLEAR FORM 
         DISPLAY p_cod_empresa TO cod_empresa
      ELSE
        CALL pol1191_le_itens() RETURNING p_status
      END IF
      RETURN FALSE
   END IF
   
   RETURN TRUE
         
END FUNCTION

#--------------------------------#
FUNCTION pol1191_exib_sequencia()
#--------------------------------#
   
   LET p_formula = ''
   
   FOR p_ind = 1 TO ARR_COUNT()
       LET pr_operando[p_ind].num_sequencia = p_ind
       DISPLAY p_ind TO sr_operando[p_ind].num_sequencia
       LET p_formula = p_formula CLIPPED, pr_operando[p_ind].operando
   END FOR
   
   DISPLAY p_formula TO formula

END FUNCTION

#-------------------------------#
FUNCTION pol1191_monta_formula()#
#-------------------------------#
  
   LET p_formula = ''
   
   FOR p_ind = 1 TO ARR_COUNT()
       LET p_formula = p_formula CLIPPED, pr_operando[p_ind].operando
   END FOR
   
   DISPLAY p_formula TO formula
   
END FUNCTION

#-----------------------------#
 FUNCTION pol1191_grava_dados()
#-----------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DELETE FROM formulas_455 
    WHERE cod_pergunta = p_cod_pergunta
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("Deletando", "formulas_455  ")
      CALL log085_transacao("ROLLBACK")
      RETURN FALSE
   END IF 
   
   FOR p_ind = 1 TO ARR_COUNT()
       IF pr_operando[p_ind].operando IS NOT NULL THEN
          
		       INSERT INTO formulas_455  
		       VALUES (p_cod_pergunta,
		               pr_operando[p_ind].num_sequencia,
		               pr_operando[p_ind].operando,
		               pr_operando[p_ind].tipo)
		
		       IF STATUS <> 0 THEN 
		          CALL log003_err_sql("Incluindo", "formulas_455  ")
		          CALL log085_transacao("ROLLBACK")
		          RETURN FALSE
		       END IF
       END IF
   END FOR
         
   CALL log085_transacao("COMMIT")	      
   
   RETURN TRUE
      
END FUNCTION

#--------------------------#
 FUNCTION pol1191_consulta()
#--------------------------#

   CALL pol1191_limpa_tela()
   LET p_cod_pergunta  = p_cod_pergunta 
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      perguntas_455.cod_pergunta,
      perguntas_455.descricao
      
      ON KEY (control-z)
         CALL pol1191_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      CALL pol1191_limpa_tela()
      IF p_ies_cons THEN 
         IF p_excluiu THEN
         ELSE
            LET p_cod_pergunta  = p_cod_perguntaa 
            CALL pol1191_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET sql_stmt = "SELECT perguntas_455.cod_pergunta, ",
                  "  perguntas_455.descricao, perguntas_455.tipo ",
                  "  FROM perguntas_455  ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND perguntas_455.cod_pergunta IN ",
                  "  (SELECT DISTINCT formulas_455.cod_pergunta FROM formulas_455) ",
                  " ORDER BY perguntas_455.descricao"

   IF p_opcao = 'L' THEN
      RETURN TRUE
   END IF

   LET p_excluiu = FALSE
   LET p_ies_cons = FALSE

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO 
      p_cod_pergunta,
      p_descricao,
      p_tipo

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      RETURN FALSE
   END IF
    
   IF NOT pol1191_exibe_dados() THEN
      RETURN FALSE
   END IF
   
   LET p_ies_cons = TRUE
   
   RETURN TRUE

END FUNCTION

#------------------------------#
 FUNCTION pol1191_exibe_dados()
#------------------------------#

   LET p_excluiu = FALSE


   DISPLAY p_cod_pergunta TO cod_pergunta
   DISPLAY p_descricao TO descricao
   DISPLAY p_tipo TO tipo_p
           
   IF NOT pol1191_le_itens() THEN
      RETURN FALSE
   END IF
      
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1191_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_perguntaa  = p_cod_pergunta

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO 
              p_cod_pergunta, p_descricao, p_tipo
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO 
              p_cod_pergunta, p_descricao, p_tipo
         
      END CASE

      IF STATUS = 0 THEN
         
         LET p_count = 0
         
         SELECT COUNT(cod_pergunta)
           INTO p_count
           FROM formulas_455  
          WHERE cod_pergunta  = p_cod_pergunta
                        
         IF STATUS <> 0 THEN
            CALL log003_err_sql("lendo", "formulas_455  ")
         END IF
         
         IF p_count > 0 THEN   
            CALL pol1191_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_pergunta  = p_cod_pergunta 
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1191_prende_registro()
#----------------------------------#
   
   CALL log085_transacao("BEGIN")
   
   DECLARE cq_prende CURSOR FOR
    SELECT cod_pergunta 
      FROM formulas_455    
     WHERE cod_pergunta  = p_cod_pergunta
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","formulas_455  ")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1191_modificacao()
#-----------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o registro a modificar !!!", "exclamation")
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'
   
   IF pol1191_prende_registro() THEN
      IF pol1191_edita_itens() THEN
         IF pol1191_grava_dados() THEN
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
 FUNCTION pol1191_exclusao()
#--------------------------#

   IF p_excluiu THEN
      CALL log0030_mensagem("Selecione o registro a excluír !!!", "exclamation")
      RETURN FALSE
   END IF

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1191_prende_registro() THEN
      DELETE FROM formulas_455  
       WHERE cod_pergunta  = p_cod_pergunta
         
      IF STATUS = 0 THEN               
         CALL pol1191_limpa_tela()
         LET p_excluiu = TRUE
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","formulas_455  ")
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
 FUNCTION pol1191_listagem()
#--------------------------#     

   LET p_cod_perguntaa  = p_cod_pergunta

   IF NOT pol1191_consulta() THEN
      ERROR 'Operação cancelada.'
      RETURN
   END IF
   
   IF NOT pol1191_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1191_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   PREPARE query FROM sql_stmt   
   DECLARE cq_impressao CURSOR  FOR query

   FOREACH cq_impressao INTO
      p_cod_pergunta,
      p_descricao,
      p_tipo
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('FOREACH', 'cq_impressao')
         EXIT FOREACH
      END IF 

      CALL pol1191_le_itens()
         
      OUTPUT TO REPORT pol1191_relat(p_cod_pergunta) 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1191_relat   
   
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
         CALL log0030_mensagem(p_msg, 'exclamation')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1191_escolhe_saida()
#-------------------------------#

   IF log0280_saida_relat(13,29) IS NULL THEN
      RETURN FALSE
   END IF

   IF p_ies_impressao = "S" THEN
      IF g_ies_ambiente = "U" THEN
         START REPORT pol1191_relat TO PIPE p_nom_arquivo
      ELSE
         CALL log150_procura_caminho ('LST') RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, 'pol1191.tmp'
         START REPORT pol1191_relat  TO p_caminho
      END IF
   ELSE
      START REPORT pol1191_relat TO p_nom_arquivo
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1191_le_den_empresa()
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

#-----------------------------------#
 REPORT pol1191_relat(p_cod_pergunta)#
#-----------------------------------#
    
   DEFINE p_cod_pergunta   LIKE perguntas_455.cod_pergunta
          
   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      FIRST PAGE HEADER
	  
   	     PRINT log5211_retorna_configuracao(PAGENO,66,132) CLIPPED;

         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1191      FORMULAS P/ PERGUNTAS CALCULADAS",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"

      PAGE HEADER
	  
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 072, "PAG. ", PAGENO USING "##&"
               
         PRINT COLUMN 001, "pol1191      FORMULAS P/ PERGUNTAS CALCULADAS",
               COLUMN 061, TODAY USING "dd/mm/yyyy", " ", TIME

         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
               
      BEFORE GROUP OF p_cod_pergunta

         PRINT
         PRINT COLUMN 001, 'Pergunta: ', p_cod_pergunta CLIPPED, ' - ', p_descricao CLIPPED, '  Tipo: ', p_tipo
         PRINT
         PRINT COLUMN 001, 'SEQ OPERANDO DESCRICAO                      TIPO'
         PRINT COLUMN 001, '--- -------- ------------------------------ ----'

      ON EVERY ROW


         FOR p_ind = 1 TO ARR_COUNT()   
            
            PRINT COLUMN 001, pr_operando[p_ind].num_sequencia USING '##&',
                  COLUMN 005, pr_operando[p_ind].operando,
                  COLUMN 014, pr_operando[p_ind].desc_indic,
                  COLUMN 046, pr_operando[p_ind].tipo
         END FOR

         PRINT
         
         PRINT COLUMN 001, 'FORMULA: ', p_formula
         PRINT COLUMN 001, "-------------------------------------------------------------------------------"
         
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
