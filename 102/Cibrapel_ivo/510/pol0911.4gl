#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0911                                                 #
# OBJETIVO: CADASTRO DE MOTIVOS                                     #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 05/02/09                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
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
          p_last_row           SMALLINT
         
  
   DEFINE p_motivo_885  RECORD LIKE motivo_885.*

   DEFINE p_cod_motivo      LIKE motivo_885.cod_motivo,
          p_cod_motivo_ant  LIKE motivo_885.cod_motivo

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0911-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0911_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol0911_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0911") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0911 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   IF NOT pol0911_le_empresa_ofic() THEN
      RETURN
   END IF
  
    DISPLAY p_cod_emp_ofic TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol0911_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol0911_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol0911_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão"
         END IF  
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol0911_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela!!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0911_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0911_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF 
      COMMAND "Listar" "Listagem"
         CALL pol0911_listagem()             
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0911_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0911

END FUNCTION

#--------------------------------#
FUNCTION pol0911_le_empresa_ofic()
#--------------------------------#

   SELECT cod_emp_gerencial
     INTO p_cod_emp_ger
     FROM empresas_885
    WHERE cod_emp_oficial = p_cod_empresa
    
   IF STATUS = 0 THEN
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
         LET p_cod_empresa = p_cod_emp_ofic
      END IF
   END IF

   RETURN TRUE 

END FUNCTION

#--------------------------#
 FUNCTION pol0911_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_motivo_885.* TO NULL
   LET p_motivo_885.cod_empresa = p_cod_empresa

   IF pol0911_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO motivo_885 VALUES (p_motivo_885.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","motivo_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0911_edita_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_motivo_885.* WITHOUT DEFAULTS
   
      BEFORE FIELD cod_motivo
      IF p_funcao = 'M' THEN
         NEXT FIELD den_motivo
      END IF
      
      AFTER FIELD cod_motivo
      IF p_motivo_885.cod_motivo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_motivo   
      END IF
         
      SELECT cod_motivo
        FROM motivo_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_motivo  = p_motivo_885.cod_motivo
      
      IF STATUS = 0 THEN
         ERROR "Código já cadastrado"
         NEXT FIELD cod_motivo
      END IF    
           
      
      AFTER FIELD den_motivo
      IF p_motivo_885.den_motivo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_motivo   
      END IF
      
   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0911_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_motivo_ant = p_cod_motivo
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      motivo_885.cod_motivo,
      motivo_885.den_motivo
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_motivo = p_cod_motivo_ant
         CALL pol0911_exibe_dados() RETURNING p_status
      END IF 
      RETURN FALSE  
   END IF

   LET sql_stmt = "SELECT cod_motivo ",
                  "  FROM motivo_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_motivo"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_motivo

   IF STATUS = NOTFOUND THEN
      ERROR "Argumentos de pesquisa não encontrados"
      LET p_ies_cons = FALSE
      RETURN FALSE 
   ELSE 
      IF pol0911_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE 

END FUNCTION

#------------------------------#
 FUNCTION pol0911_exibe_dados()
#------------------------------#

  SELECT *
    INTO p_motivo_885.*
    FROM motivo_885
   WHERE cod_empresa = p_cod_empresa
     AND cod_motivo  = p_cod_motivo

   IF STATUS = 0 THEN
      DISPLAY BY NAME p_motivo_885.*
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0911_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_motivo_ant = p_cod_motivo

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_motivo
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_motivo
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_motivo
           FROM motivo_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_motivo  = p_cod_motivo
         
         IF STATUS = 0 THEN 
            CALL pol0911_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF 
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_cod_motivo = p_cod_motivo_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
      IF pol0911_exibe_dados() THEN
         EXIT WHILE
      END IF

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol0911_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM motivo_885  
     WHERE cod_empresa = p_cod_empresa
       AND cod_motivo  = p_cod_motivo
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","motivo_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0911_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol0911_prende_registro() THEN
      IF pol0911_edita_dados("M") THEN
         UPDATE motivo_885
            SET den_motivo  = p_motivo_885.den_motivo
          WHERE cod_empresa = p_cod_empresa
            AND cod_motivo  = p_cod_motivo

         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","motivo_885")
         END IF
      ELSE
         CALL pol0911_exibe_dados() RETURNING p_status
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
 FUNCTION pol0911_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0911_prende_registro() THEN
      DELETE FROM motivo_885
			WHERE cod_empresa = p_cod_empresa
    		AND cod_motivo  = p_cod_motivo

      IF STATUS = 0 THEN               
         INITIALIZE p_motivo_885 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","motivo_885")
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
FUNCTION pol0911_listagem()
#-------------------------#     

   IF NOT pol0911_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol0911_le_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
    SELECT *
      FROM motivo_885
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_motivo
   
   FOREACH cq_impressao INTO 
           p_motivo_885.*

      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','motivo_885:cq_impressao')
         EXIT FOREACH
      END IF      
      
      OUTPUT TO REPORT pol0911_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol0911_relat   
   
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
FUNCTION pol0911_escolhe_saida()
#------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol0911.tmp"
         START REPORT pol0911_relat TO p_caminho
      ELSE
         START REPORT pol0911_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#---------------------------#
FUNCTION pol0911_le_empresa()
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
 REPORT pol0911_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 1
          TOP    MARGIN 0
          BOTTOM MARGIN 1
          PAGE   LENGTH 66
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 001,  p_den_empresa, 
               COLUMN 070, "PAG.: ", PAGENO USING "####&"
               
         PRINT COLUMN 001, "pol0911",
               COLUMN 021, "CADASTRO DE MOTIVOS",
               COLUMN 051, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 001, "--------------------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 001, '                   MOTIVO          DESCRICAO'
         PRINT COLUMN 001, '                   ------          ------------------------------'
                            
      ON EVERY ROW

         PRINT COLUMN 020, p_motivo_885.cod_motivo,
               COLUMN 036, p_motivo_885.den_motivo 
         

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
 FUNCTION pol0911_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#