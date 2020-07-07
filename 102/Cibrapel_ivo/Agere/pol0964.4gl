#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0964                                                 #
# OBJETIVO: CADASTRO DE EXPLICAÇÕES PARA AS MENSAGENS DO LOGIX      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 17/09/09                                                #
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
          p_last_row           SMALLINT
         
  
   DEFINE p_apont_critica_885  RECORD LIKE apont_critica_885.*
 
   DEFINE p_mensagem           LIKE apont_critica_885.mensagem,
          p_mensagem_ant       LIKE apont_critica_885.mensagem
          
          

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0964-05.00.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0964_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0964_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0964") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0964 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui explicações para as mensagens do logix"
         CALL pol0964_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta explicações para as mensagens do logix"
          IF pol0964_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela!!!'
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol0964_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               CLEAR FORM 
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificação !!!"
         END IF
      COMMAND "Excluir" "Exclui explicações para as mensagens do logix"
         IF p_ies_cons THEN
            CALL pol0964_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão"
         END IF  
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0964_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol0964_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0964

END FUNCTION

#--------------------------#
 FUNCTION pol0964_inclusao()
#--------------------------#

   CLEAR FORM
   INITIALIZE p_apont_critica_885.* TO NULL
   
   IF pol0964_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO apont_critica_885 VALUES (p_apont_critica_885.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","apont_critica_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0964_edita_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_apont_critica_885.* WITHOUT DEFAULTS
   
      BEFORE FIELD mensagem
         IF p_funcao = 'M' THEN 
            NEXT FIELD help_1
         END IF 
         
      AFTER FIELD mensagem
      IF p_apont_critica_885.mensagem IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD mensagem   
      END IF
          
      SELECT mensagem
        INTO p_mensagem
        FROM apont_critica_885
       WHERE mensagem = p_apont_critica_885.mensagem
         
      IF STATUS = 0 THEN 
         ERROR 'mensagem já cadastrada na tabela apont_critica_885 !!!'
         NEXT FIELD mensagem
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','apont_critica_885')
            NEXT FIELD mensagem
         END IF 
      END IF  
     
      AFTER FIELD help_1
      IF p_apont_critica_885.help_1 IS NULL THEN 
         ERROR "A explicação para a mensagem é obrigatória !!!"
         NEXT FIELD help_1   
      END IF
           
   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#--------------------------#
 FUNCTION pol0964_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(670)  

   CLEAR FORM
   LET p_mensagem_ant = p_mensagem
   LET p_ies_cons = FALSE
   LET INT_FLAG   = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      apont_critica_885.mensagem
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_mensagem = p_mensagem_ant
         CALL pol0964_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT mensagem ",
                  "  FROM apont_critica_885 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY mensagem"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_mensagem

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol0964_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol0964_exibe_dados()
#------------------------------#

   SELECT mensagem,
          help_1,
          help_2,
          help_3,
          help_4,
          help_5,
          help_6,
          help_7,
          help_8,
          help_9,
          help_10
          
     INTO p_apont_critica_885.mensagem,
          p_apont_critica_885.help_1,
          p_apont_critica_885.help_2,
          p_apont_critica_885.help_3,
          p_apont_critica_885.help_4,
          p_apont_critica_885.help_5,
          p_apont_critica_885.help_6,
          p_apont_critica_885.help_7,
          p_apont_critica_885.help_8,
          p_apont_critica_885.help_9,
          p_apont_critica_885.help_10
          
     FROM apont_critica_885
    WHERE mensagem = p_mensagem
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo','apont_critica_885')
      RETURN FALSE 
   END IF
   
   IF STATUS = 0 THEN
      
      DISPLAY p_apont_critica_885.mensagem TO mensagem
      DISPLAY p_apont_critica_885.help_1   TO help_1
      DISPLAY p_apont_critica_885.help_2   TO help_2
      DISPLAY p_apont_critica_885.help_3   TO help_3
      DISPLAY p_apont_critica_885.help_4   TO help_4
      DISPLAY p_apont_critica_885.help_5   TO help_5
      DISPLAY p_apont_critica_885.help_6   TO help_6
      DISPLAY p_apont_critica_885.help_7   TO help_7
      DISPLAY p_apont_critica_885.help_8   TO help_8
      DISPLAY p_apont_critica_885.help_9   TO help_9
      DISPLAY p_apont_critica_885.help_10  TO help_10
      
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------------#
 FUNCTION pol0964_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_mensagem_ant = p_mensagem

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_mensagem
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_mensagem
         
      END CASE

      IF STATUS = 0 THEN
         SELECT mensagem
           FROM apont_critica_885
          WHERE mensagem = p_mensagem
             
         IF STATUS = 0 THEN
            CALL pol0964_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_mensagem = p_mensagem_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol0964_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT mensagem 
      FROM apont_critica_885  
     WHERE mensagem = p_mensagem
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","apont_critica_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0964_modificacao()
#-----------------------------#
 
   LET p_retorno = FALSE

   IF pol0964_prende_registro() THEN
      IF pol0964_edita_dados("M") THEN
         UPDATE apont_critica_885
            SET help_1   = P_apont_critica_885.help_1,
                help_2   = P_apont_critica_885.help_2,
                help_3   = P_apont_critica_885.help_3,
                help_4   = P_apont_critica_885.help_4,
                help_5   = P_apont_critica_885.help_5,
                help_6   = P_apont_critica_885.help_6,
                help_7   = P_apont_critica_885.help_7,
                help_8   = P_apont_critica_885.help_8,
                help_9   = P_apont_critica_885.help_9,
                help_10  = P_apont_critica_885.help_10
                
          WHERE mensagem = p_mensagem
          
          IF STATUS <> 0 THEN
             CALL log003_err_sql("Modificando","apont_critica_885")
          ELSE
             LET p_retorno = TRUE
          END IF 
      ELSE
         CALL pol0964_exibe_dados()
      END IF
   END IF

   CLOSE cq_prende

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
      RETURN TRUE
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION

#--------------------------#
 FUNCTION pol0964_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol0964_prende_registro() THEN
      DELETE FROM apont_critica_885
			WHERE mensagem = p_mensagem 

      IF STATUS = 0 THEN               
         INITIALIZE p_apont_critica_885 TO NULL
         CLEAR FORM
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","apont_critica_885")
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

#-------------------------------- FIM DE PROGRAMA -----------------------------#