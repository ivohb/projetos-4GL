#-------------------------------------------------------------------#
# SISTEMA.: PLANEJAMENTO                                            #
# PROGRAMA: POL0102                                                 #
# MODULOS.: POL0102 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA PAR_DESC_OPER                      #
# AUTOR...: ALBRAS - INTERNO                                        #
# DATA....: 20/06/2000                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
  DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
         p_cod_empo          LIKE empresa.cod_empresa,
         p_user              LIKE usuario.nom_usuario,
         p_status            SMALLINT,
         p_houve_erro        SMALLINT,
         pa_curr             SMALLINT,
         sc_curr             SMALLINT,
         comando             CHAR(80),
      #  p_versao            CHAR(17),
         p_versao            CHAR(18),
         p_nom_arquivo       CHAR(100),
         p_nom_tel           CHAR(200),
         p_nom_help          CHAR(200),
         p_ies_cons          SMALLINT,
         p_last_row          SMALLINT
  DEFINE p_empresa           RECORD LIKE empresa.*,         
         p_par_desc_oper     RECORD LIKE par_desc_oper.*,   
         p_par_desc_operr    RECORD LIKE par_desc_oper.*    
END GLOBALS

MAIN
  CALL log0180_conecta_usuario()
  WHENEVER ANY ERROR CONTINUE
       SET ISOLATION TO DIRTY READ
       SET LOCK MODE TO WAIT 300 
  WHENEVER ANY ERROR STOP
  DEFER INTERRUPT
  LET p_versao = "POL0102-10.02.00"
  INITIALIZE p_nom_help TO NULL  
  CALL log140_procura_caminho("pol0102.iem") RETURNING p_nom_help
  LET  p_nom_help = p_nom_help CLIPPED
  OPTIONS HELP FILE p_nom_help,
       NEXT KEY control-f,
       INSERT KEY control-i,
       DELETE KEY control-e,
       PREVIOUS KEY control-b

  CALL log001_acessa_usuario("VDP","LIC_LIB")
       RETURNING p_status, p_cod_empresa, p_user
  IF  p_status = 0  THEN
      CALL pol0102_controle()
  END IF
END MAIN

#--------------------------#
 FUNCTION pol0102_controle()
#--------------------------#
  CALL log006_exibe_teclas("01",p_versao)
  INITIALIZE p_nom_tel TO NULL 
  CALL log130_procura_caminho("pol0102") RETURNING p_nom_tel
  LET  p_nom_tel = p_nom_tel CLIPPED 
  OPEN WINDOW w_pol0102 AT 2,5 WITH FORM p_nom_tel 
       ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  MENU "OPCAO"
    COMMAND "Incluir" "Inclui dados na tabela"
      HELP 001
      MESSAGE ""
      LET int_flag = 0
      IF  log005_seguranca(p_user,"VDP","pol0102","IN") THEN
        CALL pol0102_inclusao() RETURNING p_status
      END IF
     COMMAND "Modificar" "Modifica dados da tabela"
       HELP 002
       MESSAGE ""
       LET int_flag = 0
       IF  p_par_desc_oper.cod_emp_ofic IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0102","MO") THEN
               CALL pol0102_modificacao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a modificacao. "
       END IF
      COMMAND "Excluir"  "Exclui dados da tabela"
       HELP 003
       MESSAGE ""
       LET int_flag = 0
       IF  p_par_desc_oper.cod_emp_ofic IS NOT NULL THEN
           IF  log005_seguranca(p_user,"VDP","pol0102","EX") THEN
               CALL pol0102_exclusao()
           END IF
       ELSE
           ERROR " Consulte previamente para fazer a exclusao. "
       END IF 
     COMMAND "Consultar"    "Consulta dados da tabela TABELA"
       HELP 004
       MESSAGE "" 
       DISPLAY "                                    "  at 7,32
       DISPLAY "                                    "  at 9,32
       LET int_flag = 0
       IF  log005_seguranca(p_user,"VDP","pol0102","CO") THEN
           CALL pol0102_consulta()
       END IF
    COMMAND KEY ("!")
      PROMPT "Digite o comando : " FOR comando
      RUN comando
      PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
      DATABASE logix
      LET int_flag = 0
    COMMAND "Fim"       "Retorna ao Menu Anterior"
      HELP 008
      MESSAGE ""
      EXIT MENU
  END MENU
  CLOSE WINDOW w_pol0102
END FUNCTION

#--------------------------------------#
 FUNCTION pol0102_inclusao()
#--------------------------------------#
  LET p_houve_erro = FALSE
  IF  pol0102_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO par_desc_oper VALUES (p_par_desc_oper.*)
      IF sqlca.sqlcode <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","TABELA")       
      ELSE
          CALL log085_transacao("COMMIT")
          MESSAGE " Inclusao efetuada com sucesso. " ATTRIBUTE(REVERSE)
          LET p_ies_cons = FALSE
      END IF
  ELSE
      CLEAR FORM
      ERROR " Inclusao Cancelada. "
      RETURN FALSE
  END IF

  RETURN TRUE
END FUNCTION

#---------------------------------------#
 FUNCTION pol0102_entrada_dados(p_funcao)
#---------------------------------------#

  DEFINE p_funcao            CHAR(30)

  CALL log006_exibe_teclas("01 02 07",p_versao)
  CURRENT WINDOW IS w_pol0102
  IF p_funcao = "INCLUSAO" THEN
     INITIALIZE p_par_desc_oper.* TO NULL
     DISPLAY BY NAME p_par_desc_oper.cod_emp_ofic,
                     p_par_desc_oper.cod_emp_oper,
                     p_par_desc_oper.max_desc_oper,
                     p_par_desc_oper.per_jur_dia   
  END IF

  LET int_flag = false
  INPUT BY NAME p_par_desc_oper.cod_emp_ofic,
                p_par_desc_oper.cod_emp_oper,
                p_par_desc_oper.max_desc_oper,
                p_par_desc_oper.per_jur_dia   
    WITHOUT DEFAULTS

    BEFORE FIELD cod_emp_ofic  
      IF p_funcao = "MODIFICACAO"
      THEN  NEXT FIELD cod_emp_oper
      END IF

    AFTER FIELD cod_emp_ofic 
      IF p_par_desc_oper.cod_emp_ofic IS NOT NULL THEN 
         LET p_cod_empo = p_par_desc_oper.cod_emp_ofic 
         IF pol0102_verifica_empresa() THEN
            ERROR "Empresa nao cadastrada" 
            NEXT FIELD cod_emp_ofic  
         ELSE 
            DISPLAY p_empresa.den_empresa at 7,32 
         END IF
      ELSE ERROR "O campo COD_EMP_OFIC nao pode ser nulo."
           NEXT FIELD cod_emp_ofic 
      END IF

    AFTER FIELD cod_emp_oper
      IF p_par_desc_oper.cod_emp_oper = p_par_desc_oper.cod_emp_ofic THEN
         ERROR "Empresa oficial e Empresa Oper devem ser diferentes" 
         NEXT FIELD cod_emp_ofic  
      END IF
      IF p_par_desc_oper.cod_emp_oper IS NOT NULL THEN
         LET p_cod_empo = p_par_desc_oper.cod_emp_oper
         IF pol0102_verifica_empresa() THEN
            ERROR "Empresa nao cadastrada" 
            NEXT FIELD cod_emp_oper  
         ELSE 
            DISPLAY p_empresa.den_empresa at 9,32 
            IF p_funcao <> "MODIFICACAO" THEN	
               IF pol0102_verifica_duplicidade() THEN
                  ERROR "EMPRESA OFICIAL JA CADASTRADA" 
                  NEXT FIELD cod_emp_ofic 
               END IF
            END IF
         END IF
      ELSE ERROR "O campo COD_EMP_OPER nao pode ser nulo."
           NEXT FIELD cod_emp_oper    
      END IF 

    AFTER FIELD max_desc_oper  
      IF p_par_desc_oper.max_desc_oper IS NULL  OR     
         p_par_desc_oper.max_desc_oper = 0 THEN        
         ERROR "PERCENTUAL DESCONTO DEVE SER MAIOR QUE 0" 
         NEXT FIELD max_desc_oper
      END IF

    AFTER FIELD per_jur_dia    
      IF p_par_desc_oper.per_jur_dia IS NULL OR     
         p_par_desc_oper.per_jur_dia = 0 THEN        
         ERROR "PERCENTUAL DE JUROS DEVE SER MAIOR QUE 0" 
         NEXT FIELD per_jur_dia  
      END IF

 END INPUT 
 CALL log006_exibe_teclas("01",p_versao)
  CURRENT WINDOW IS w_pol0102
  IF  int_flag = 0 THEN
    RETURN TRUE
  ELSE
    LET int_flag = 0
    RETURN FALSE
  END IF
END FUNCTION


#--------------------------#
 FUNCTION pol0102_consulta()
#--------------------------#
 DEFINE sql_stmt, where_clause    CHAR(300)  
 CLEAR FORM

 CONSTRUCT BY NAME where_clause ON par_desc_oper.cod_emp_ofic,
                                   par_desc_oper.cod_emp_oper 
 CALL log006_exibe_teclas("01",p_versao)
 CURRENT WINDOW IS w_pol0102
 IF int_flag THEN
   LET int_flag = 0 
   LET p_par_desc_oper.* = p_par_desc_operr.*
   CALL pol0102_exibe_dados()
   ERROR " Consulta Cancelada"
   RETURN
 END IF
 LET sql_stmt = "SELECT * FROM par_desc_oper ",
                " WHERE ", where_clause CLIPPED,                 
                " ORDER BY cod_emp_ofic "

 PREPARE var_query FROM sql_stmt   
 DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
 OPEN cq_padrao
 FETCH cq_padrao INTO p_par_desc_oper.*
   IF sqlca.sqlcode = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao encontrados"
      LET p_ies_cons = FALSE
      CLEAR FORM
   ELSE 
      LET p_cod_empo = p_par_desc_oper.cod_emp_ofic
      IF pol0102_verifica_empresa() THEN
         DISPLAY  "NAO CADASTRADO" at 7,32                 
      ELSE 
         DISPLAY  p_empresa.den_empresa at 7,32                 
      END IF
      LET p_cod_empo = p_par_desc_oper.cod_emp_oper
      IF pol0102_verifica_empresa() THEN
         DISPLAY  "NAO CADASTRADO" at 9,32                 
      ELSE 
         DISPLAY  p_empresa.den_empresa at 9,32                 
      END IF
      LET p_ies_cons = TRUE
   END IF
   CALL pol0102_exibe_dados()
END FUNCTION

#------------------------------#
 FUNCTION pol0102_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_par_desc_oper.cod_emp_ofic,
                   p_par_desc_oper.cod_emp_oper, 
                   p_par_desc_oper.max_desc_oper,
                   p_par_desc_oper.per_jur_dia   

END FUNCTION

#------------------------------------#
 FUNCTION pol0102_cursor_for_update()
#------------------------------------#
 WHENEVER ERROR CONTINUE
 DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT *                            
     INTO p_par_desc_oper.*                                              
     FROM par_desc_oper       
    WHERE cod_emp_ofic = p_par_desc_oper.cod_emp_ofic 
 FOR UPDATE 
   CALL log085_transacao("BEGIN")
   OPEN cm_padrao
   FETCH cm_padrao
   CASE sqlca.sqlcode
     
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","TABELA")
   END CASE
   WHENEVER ERROR STOP
   RETURN FALSE

 END FUNCTION


#----------------------------------#
 FUNCTION pol0102_modificacao()
#----------------------------------#
   IF pol0102_cursor_for_update() THEN
      LET p_par_desc_operr.* = p_par_desc_oper.*
      IF pol0102_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE par_desc_oper SET cod_emp_oper = p_par_desc_oper.cod_emp_oper, 
                                  max_desc_oper= p_par_desc_oper.max_desc_oper, 
                                  per_jur_dia  = p_par_desc_oper.per_jur_dia    
         WHERE CURRENT OF cm_padrao
         IF sqlca.sqlcode = 0 THEN
            CALL log085_transacao("COMMIT")
            IF sqlca.sqlcode <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TABELA")
            ELSE
               MESSAGE "Modificacao efetuada com sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TABELA")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         LET p_par_desc_oper.* = p_par_desc_operr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
         DISPLAY BY NAME p_par_desc_oper.cod_emp_ofic 
         DISPLAY   p_empresa.den_empresa  at 9,32
         DISPLAY BY NAME p_par_desc_oper.cod_emp_oper
         DISPLAY BY NAME p_par_desc_oper.max_desc_oper 
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#----------------------------------------#
 FUNCTION pol0102_exclusao()
#----------------------------------------#
   IF pol0102_cursor_for_update() THEN
      IF log004_confirm(18,38) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM par_desc_oper     
          WHERE CURRENT OF cm_padrao
          IF sqlca.sqlcode = 0 THEN
             CALL log085_transacao("COMMIT")
             IF sqlca.sqlcode <> 0 THEN
                CALL log003_err_sql("EFET-COMMIT-EXC","TABELA")
             ELSE
                MESSAGE "Exclusao efetuada com sucesso." ATTRIBUTE(REVERSE)
                INITIALIZE p_par_desc_oper.* TO NULL
                CLEAR FORM
             END IF
          ELSE
             CALL log003_err_sql("EXCLUSAO","TABELA")
             CALL log085_transacao("ROLLBACK")
          END IF
          WHENEVER ERROR STOP
       ELSE
          CALL log085_transacao("ROLLBACK")
       END IF
       CLOSE cm_padrao
   END IF
 END FUNCTION  

#------------------------------------#
 FUNCTION pol0102_verifica_empresa()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT *              
  INTO p_empresa.*                 
  FROM empresa                
 WHERE cod_empresa = p_cod_empo                 

IF sqlca.sqlcode = 0 THEN
   RETURN FALSE
ELSE
   RETURN TRUE
END IF

END FUNCTION 


#------------------------------------#
 FUNCTION pol0102_verifica_duplicidade()
#------------------------------------#
DEFINE p_cont      SMALLINT

SELECT COUNT(*) 
  INTO p_cont
  FROM par_desc_oper 
 WHERE cod_emp_ofic = p_par_desc_oper.cod_emp_ofic 

IF p_cont > 0 THEN
   RETURN TRUE
ELSE
   RETURN FALSE
END IF

END FUNCTION   
