#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol0913                                                 #
# OBJETIVO: CONSULTA DE RESERVAS INCONSISTIDAS                      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 20/02/09                                                #
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
   
   DEFINE pr_reserva           ARRAY[1000] OF RECORD
          cod_empresa          CHAR(02),
          num_reserva          INTEGER,
          cod_item             CHAR(15),
          den_item             CHAR(76),
          des_erro             CHAR(70)
   END RECORD
   
          
 
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0913-05.00.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol0913_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0913_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0913") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0913 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   IF NOT pol0913_le_empresa() THEN
      RETURN
   END IF

   DISPLAY p_cod_emp_ofic TO cod_emp_ofic
   
   LET p_ies_cons = FALSE
   
   MENU "OPCAO"
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol0913_consulta() THEN 
            IF p_ies_cons THEN
               ERROR 'Consulta efetuada com sucesso !!!'
            ELSE
               ERROR 'Argumentos de pesquisa não encontrados !!!'
            END IF
         ELSE
            ERROR 'Consulta cancelada!!!'
         END IF   
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0913

END FUNCTION

#----------------------------#
FUNCTION pol0913_le_empresa()
#----------------------------#

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


#--------------------------#
 FUNCTION pol0913_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  
   CLEAR FORM
   DISPLAY p_cod_emp_ofic TO cod_emp_ofic 
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      reserva_erro_885.num_reserva
      
   IF INT_FLAG THEN
      IF p_ies_cons = TRUE THEN  
         CALL pol0913_exibe_dados()
         RETURN TRUE 
      ELSE
         RETURN FALSE 
      END IF
   END IF 

   LET sql_stmt = "SELECT cod_empresa, num_reserva, des_erro ",
                  "  FROM reserva_erro_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_emp_ofic,"' ",
                  "    OR cod_empresa = '",p_cod_emp_ger,"' ",
                  " ORDER BY num_reserva"
   
   LET p_index = 1

   PREPARE var_query FROM sql_stmt   
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Criando','var_query')
      RETURN FALSE
   END IF
   
   DECLARE cq_padrao CURSOR WITH HOLD FOR var_query

   FOREACH cq_padrao INTO 
           pr_reserva[p_index].cod_empresa,
           pr_reserva[p_index].num_reserva,
           pr_reserva[p_index].des_erro
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('Lendo','cq_padrao')
         RETURN FALSE
      END IF
      
      IF pol0913_le_dados() THEN 
         LET p_index = p_index + 1
         IF p_index > 1000 THEN
            ERROR 'Limite de Grades ultrapassado'
            EXIT FOREACH
         END IF
      END IF 
       
   END FOREACH
   
   IF p_index = 1 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados",'excla')
      LET p_ies_cons = FALSE
      RETURN FALSE 
   END IF  
   
   CALL SET_COUNT(P_index - 1)
   
   LET p_ies_cons = TRUE

   CALL pol0913_exibe_dados()

   RETURN TRUE 

END FUNCTION

#----------------------------#
FUNCTION pol0913_exibe_dados()
#----------------------------#

   DISPLAY ARRAY pr_reserva TO sr_reserva.*

END FUNCTION
      
#--------------------------#
 FUNCTION pol0913_le_dados()
#--------------------------#
  
  SELECT DISTINCT cod_item
    INTO pr_reserva[p_index].cod_item
    FROM wpol0801
   WHERE cod_empresa = pr_reserva[p_index].cod_empresa
     AND num_reserva = pr_reserva[p_index].num_reserva
     
  IF STATUS <> 0 THEN
     CALL log003_err_sql('lendo', 'wpol0801')
     RETURN FALSE
  END IF  
  
  SELECT den_item
    INTO pr_reserva[p_index].den_item
    FROM item
   WHERE cod_empresa = pr_reserva[p_index].cod_empresa
     AND cod_item    = pr_reserva[p_index].cod_item
    
  IF STATUS <> 0 THEN
     CALL log003_err_sql('lendo', 'item')
     RETURN FALSE
  END IF 
        
  RETURN TRUE 

END FUNCTION




#-------------------------------- FIM DE PROGRAMA -----------------------------#



