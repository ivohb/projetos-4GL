
#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0926                                                 #
# OBJETIVO: CADASTRO DE OPERAÇÕES                                   #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 16/04/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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
          p_msg                CHAR(100),
          p_last_row           SMALLINT,
          p_ies_inclu          SMALLINT,
          P_consulta_ent       CHAR(100),
          P_consulta_sai       CHAR(100)
  
   DEFINE P_operacao_885       RECORD LIKE operacao_885.*

   DEFINE p_cod_operacao       LIKE operacao_885.cod_operacao,
          p_cod_operacao_ant   LIKE operacao_885.cod_operacao,
          p_den_operacao       LIKE estoque_operac.den_operacao,
          p_ies_tipo           LIKE estoque_operac.ies_tipo
   
   DEFINE pr_operacao          ARRAY[1000] OF RECORD
          cod_operacao         LIKE estoque_operac.cod_operacao,
          den_operacao         LIKE estoque_operac.den_operacao,
          ies_tipo             LIKE estoque_operac.ies_tipo
   END RECORD      
   
   DEFINE p_cod_operacao       LIKE operacao_885.cod_operacao,
          P_cod_operacao_ant   LIKE operacao_885.cod_operacao
   
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0926-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0926_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0926_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0926") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0926 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   IF NOT pol0926_le_empresa_ofic() THEN
      RETURN
   END IF
   
   LET p_ies_cons  = FALSE
   CALL pol0926_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol0926_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
         ELSE
            CALL pol0926_limpa_tela()
            ERROR 'Operação cancelada !!!'
         END IF 
       COMMAND "Consultar" "Consulta dados da tabela"
          CALL pol0926_consulta() RETURNING p_status
          IF p_status THEN
             IF p_ies_cons THEN
                ERROR 'Consulta efetuada com sucesso !!!'
                NEXT OPTION "Seguinte" 
             ELSE
                CALL pol0926_limpa_tela()
                ERROR 'Argumentos de pesquisa não encontrados !!!'
             END IF 
          ELSE
             CALL pol0926_limpa_tela()
             ERROR 'Operação cancelada!!!'
             NEXT OPTION 'Incluir'
          END IF 
       COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
          IF p_ies_cons THEN
             CALL pol0926_paginacao("S")
          ELSE
             ERROR "Não existe nenhuma consulta ativa"
          END IF
       COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
          IF p_ies_cons THEN
             CALL pol0926_paginacao("A")
          ELSE
             ERROR "Não existe nenhuma consulta ativa"
          END IF
       COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0926_exclusao() RETURNING p_retorno
            IF p_retorno THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF  
      COMMAND "Listar" "Listagem"
         CALL pol0926_listagem()     
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0926_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0926

END FUNCTION

#---------------------------------#
 FUNCTION pol0926_le_empresa_ofic()
#---------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
      LET p_cod_emp_ofic = p_cod_empresa
      LET p_cod_empresa  = p_cod_emp_ger
   ELSE
      IF STATUS <> 100 THEN
         CALL log003_err_sql("LENDO","EMPRESA_885")       
         RETURN FALSE
      ELSE
         SELECT cod_emp_oficial
           INTO p_cod_emp_ofic
           FROM empresas_885
          WHERE cod_emp_gerencial = p_cod_empresa
         IF STATUS <> 0 THEN
            CALL log003_err_sql("LENDO","EMPRESA_885")       
            RETURN FALSE
         END IF
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#----------------------------#
 FUNCTION pol0926_limpa_tela()
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_empresa

END FUNCTION

#--------------------------#
 FUNCTION pol0926_inclusao()
#--------------------------#

   CALL pol0926_limpa_tela()
   INITIALIZE P_operacao_885.* TO NULL
   LET P_operacao_885.cod_empresa = p_cod_empresa

   IF pol0926_edita_dados("I") THEN
      INSERT INTO operacao_885
       VALUES(p_operacao_885.*)
      IF STATUS <> 0 THEN
         CALL log003_err_sql("Inserindo", "operacao_885")   
      ELSE
         LET p_cod_empresa = p_operacao_885.cod_empresa         
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol0926_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME P_operacao_885.* WITHOUT DEFAULTS
   
      
      AFTER FIELD cod_operacao
      IF P_operacao_885.cod_operacao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_operacao   
      END IF

    
      SELECT den_operacao,
             ies_tipo
        INTO p_den_operacao,
             p_ies_tipo
        FROM estoque_operac
       WHERE cod_empresa   = p_cod_empresa
         AND cod_operacao  = P_operacao_885.cod_operacao
         
      IF STATUS = 100 THEN
         ERROR 'Operação não cadastrada!!!'
         NEXT FIELD cod_operacao
      ELSE
         IF STATUS <> 0 THEN
            CALL log003_err_sql('lendo','estoque_operac')
            NEXT FIELD cod_operacao
         END IF
      END IF
      
      IF p_ies_tipo MATCHES '[SE]' THEN
      ELSE
         ERROR "O tipo de operacao encontrado não é de entrada ou de saída!!!"
         NEXT FIELD cod_operacao
      END IF
                  
      DISPLAY p_den_operacao TO den_operacao
      DISPLAY p_ies_tipo     TO ies_tipo
      
      LET P_operacao_885.ies_tipo = p_ies_tipo  
      
      SELECT cod_operacao
        FROM operacao_885
       WHERE cod_empresa  = p_cod_empresa
         AND cod_operacao = P_operacao_885.cod_operacao
         
      IF STATUS = 0 THEN 
         ERROR "Código já cadastrado!!!"
         NEXT FIELD cod_operacao
      ELSE 
         IF STATUS = 100 THEN 
         ELSE       
            CALL log003_err_sql("lendo","operacao_885")
            NEXT FIELD cod_operacao
         END IF
      END IF  
            
      ON KEY (control-z)
         CALL pol0926_popup()
       
   END INPUT 


   IF INT_FLAG  THEN
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION


#-----------------------#
 FUNCTION pol0926_popup()
#-----------------------#

    DEFINE p_codigo CHAR(15)
 
    CASE
       WHEN INFIELD(cod_operacao)
       CALL pol0926_popup_operacao() RETURNING p_codigo
       CURRENT WINDOW IS w_pol0926
       IF p_codigo IS NOT NULL THEN
          LET P_operacao_885.cod_operacao = p_codigo CLIPPED
          DISPLAY p_codigo TO cod_operacao
       END IF
    END CASE 
    
END FUNCTION         

#--------------------------------#
 FUNCTION pol0926_popup_operacao()
#--------------------------------#
   
   LET p_index = 1
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol09261") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol09261 AT 8,10 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, FORM LINE FIRST)
       
   DECLARE cq_operacao CURSOR FOR
    SELECT cod_operacao,
           den_operacao,
           ies_tipo 
      FROM estoque_operac
     WHERE cod_empresa  =  p_cod_empresa
       AND ies_tipo IN ("S","E")
       AND cod_operacao NOT IN (SELECT cod_operacao 
                                  FROM operacao_885 
                                 WHERE cod_empresa = p_cod_empresa)
  ORDER BY cod_operacao

      
   FOREACH cq_operacao INTO 
           pr_operacao[p_index].cod_operacao, 
           pr_operacao[p_index].den_operacao,
           pr_operacao[p_index].ies_tipo

       IF STATUS <> 0 THEN 
          CALL log003_err_sql("lendo","estoque_operac")
          RETURN 
       END IF 
              
       LET p_index = p_index + 1
       
       IF p_index > 1000 THEN
          ERROR 'Limite de Grades ultrapassado'
          EXIT FOREACH
       END IF
       
   END FOREACH
   
   CALL SET_COUNT(P_index - 1)
    
   DISPLAY ARRAY pr_operacao TO sr_operacao.*
      LET p_index = ARR_CURR()
    
   CLOSE WINDOW w_pol09261
   
   RETURN pr_operacao[p_index].cod_operacao
           
END FUNCTION

#--------------------------#
 FUNCTION pol0926_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol0926_limpa_tela()
   
   LET p_cod_operacao_ant = p_cod_operacao
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      operacao_885.cod_operacao
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN
         LET p_cod_operacao = p_cod_operacao_ant   
         CALL pol0926_exibe_dados() RETURNING p_status
      ELSE
         CALL pol0926_limpa_tela()
      END IF
      RETURN FALSE
   END IF

   LET sql_stmt = "SELECT cod_operacao ",
                  "  FROM operacao_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " order by cod_operacao "
                  

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_operacao

   IF STATUS = 0 THEN
      IF pol0926_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   ELSE   
      IF STATUS = 100 THEN
         CALL log0030_mensagem("Argumentos de pesquisa não encontrados!","excla")
      ELSE
         CALL log003_err_sql('Lendo','operacao_885')
      END IF
   END IF

   CALL pol0926_limpa_tela()
   
   LET p_ies_cons = FALSE
         
   RETURN FALSE
   
END FUNCTION

#------------------------------#
 FUNCTION pol0926_exibe_dados()
#------------------------------#
  
  SELECT cod_empresa 
    FROM operacao_885
   WHERE cod_empresa  = p_cod_empresa
     AND cod_operacao = p_cod_operacao
   
  IF STATUS <> 0 THEN 
     RETURN FALSE 
  END IF  
  
  SELECT den_operacao,
         ies_tipo
    INTO p_den_operacao,
         p_ies_tipo
    FROM estoque_operac
   WHERE cod_empresa  = p_cod_empresa
     AND cod_operacao = p_cod_operacao
     

   IF STATUS = 0 THEN
      DISPLAY p_cod_operacao TO cod_operacao
      DISPLAY p_den_operacao TO den_operacao
      DISPLAY p_ies_tipo     TO ies_tipo
      RETURN TRUE
   ELSE
      CALL log003_err_sql('Lendo','estoque_operac')
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0926_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_operacao_ant = p_cod_operacao

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_operacao
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_operacao
         
      END CASE

      IF STATUS = 0 THEN
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais operações nesta direção"
            LET p_cod_operacao = p_cod_operacao_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0926_exibe_dados() THEN
         EXIT WHILE
      END IF
       
    END WHILE

END FUNCTION


#----------------------------------#
 FUNCTION pol0926_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR WITH HOLD FOR
    SELECT cod_empresa 
      FROM operacao_885  
     WHERE cod_empresa = p_cod_empresa
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","operacao_885")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0926_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0926_prende_registro() THEN
      DELETE FROM operacao_885
			WHERE cod_empresa   = p_cod_empresa
			  AND cod_operacao  = p_cod_operacao
    		
      IF STATUS = 0 THEN               
         INITIALIZE P_operacao_885 TO NULL
         CALL pol0926_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","operacao_885")
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

#-------------------------#
FUNCTION pol0926_listagem()
#-------------------------#     

   IF NOT pol0926_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0926_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT cod_operacao,
           ies_tipo
      FROM operacao_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_operacao
   
   FOREACH cq_impressao INTO 
           P_operacao_885.cod_operacao,
           P_operacao_885.ies_tipo

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','operacao_885')
         EXIT FOREACH
      END IF      
      
      SELECT den_operacao
        INTO p_den_operacao
        FROM estoque_operac
       WHERE cod_empresa  = p_cod_empresa
         AND cod_operacao = P_operacao_885.cod_operacao
    
      IF STATUS <> 0 THEN 
         CALL log003_err_sql("lendo","estoque_operac")
         RETURN 
      END IF 
     
      OUTPUT TO REPORT pol0926_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0926_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados. "
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
      ERROR 'Relatório gerado com sucesso!!!'
   END IF
  
END FUNCTION 

#------------------------------#
FUNCTION pol0926_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0926.tmp"
         START REPORT pol0926_relat TO p_caminho
      ELSE
         START REPORT pol0926_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol0926_le_empresa()
#---------------------------#

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
 REPORT pol0926_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "POL0926",
               COLUMN 021, "CADASTRO DE OPERACOES",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "-------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'OPERACAO                       DESCRICAO                             E/S'
         PRINT COLUMN 002, '-------- ----------------------------------------------------------- ---'
                            
      ON EVERY ROW

         PRINT COLUMN 002, P_operacao_885.cod_operacao,
               COLUMN 011, p_den_operacao,
               COLUMN 071, P_operacao_885.ies_tipo
         

      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 030, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-----------------------#
 FUNCTION pol0926_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#