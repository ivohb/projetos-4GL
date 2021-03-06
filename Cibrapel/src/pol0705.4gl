#-------------------------------------------------------------------#
# PROGRAMA: pol0705                                                 #
# MODULOS.: pol0705-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: DE PARA TURNO - CIBRAPEL                                #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 26/12/2007                                              #
# CONVERS�O 10.02: 17/07/2014 - IVO                                 #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_turno          LIKE turno.cod_turno,
          p_den_turno          LIKE turno.den_turno,
          p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_cod_turnos         char(03),
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          p_cod_formulario     CHAR(03),
          pr_index             SMALLINT,
          sr_index             SMALLINT

END GLOBALS
          
DEFINE p_de_para_turno_885  RECORD 
   cod_empresa    char(02),
   turno_simula   char(03),
   turno_logix    decimal(3,0)
END RECORD
   
DEFINE p_de_para_turno_885a  RECORD 
   cod_empresa    char(02),
   turno_simula   char(03),
   turno_logix    decimal(3,0)
END RECORD

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0705-05.10.01  "
   CALL func002_versao_prg(p_versao)
   
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0705.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0705_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0705_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0705") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0705 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0705_inclusao() THEN
            MESSAGE 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Opera��o cancelada !!!'
         END IF
       COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0705_modificacao() THEN
               MESSAGE 'Modifica��o efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0705_exclusao() THEN
               MESSAGE 'Exclus�o efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0705_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0705_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0705_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0705

END FUNCTION

#--------------------------#
 FUNCTION pol0705_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_de_para_turno_885.* TO NULL
   LET p_de_para_turno_885.cod_empresa = p_cod_empresa

   IF pol0705_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO de_para_turno_885 VALUES (p_de_para_turno_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
   END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0705_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0705

   INPUT BY NAME p_de_para_turno_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD turno_simula
      IF p_funcao = "M" THEN
         NEXT FIELD turno_logix
      END IF   

      AFTER FIELD turno_simula
      IF p_de_para_turno_885.turno_simula IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD turno_simula
      END IF 

      SELECT turno_logix
        FROM de_para_turno_885
       WHERE cod_empresa = p_cod_empresa 
         AND turno_simula = p_de_para_turno_885.turno_simula
        
      IF STATUS = 0 THEN
         ERROR "C�digo do Turno Trim j� Cadastrado na Tabela de_para_turno_885!!!"
         NEXT FIELD turno_simula
      END IF
      
      AFTER FIELD turno_logix
      IF p_de_para_turno_885.turno_logix IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD turno_logix
      ELSE
          SELECT den_turno
           INTO p_den_turno
           FROM turno
          WHERE cod_empresa = p_cod_empresa 
            AND cod_turno = p_de_para_turno_885.turno_logix
       
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Turno nao Cadastrado na Tabela TURNO !!!" 
            NEXT FIELD turno_logix
         END IF
       
         SELECT turno_logix
           FROM de_para_turno_885
          WHERE cod_empresa = p_cod_empresa 
            AND turno_logix = p_de_para_turno_885.turno_logix
        
         IF STATUS = 0 THEN
            ERROR "C�digo do Turno j� Cadastrado na Tabela de_para_turno_885!!!"
            NEXT FIELD turno_logix
         END IF
  
         DISPLAY  p_de_para_turno_885.turno_logix TO turno_logix   
         DISPLAY p_den_turno TO den_turno  
         
      
      END IF
               
    ON KEY (control-z)
      CALL pol0705_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0705

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0705_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_de_para_turno_885a.* = p_de_para_turno_885.*

   CONSTRUCT BY NAME where_clause ON 
      de_para_turno_885.turno_simula
  
      ON KEY (control-z)
     #    CALL pol0705_popup()
          LET p_cod_turnos = pol0705_carrega_empresa() 
               DISPLAY p_den_turno TO den_turno 
            IF p_cod_turnos IS NOT NULL THEN
               LET p_de_para_turno_885.turno_logix = p_cod_turnos CLIPPED
               CURRENT WINDOW IS w_pol0705
         DISPLAY p_de_para_turno_885.turno_logix TO turno_logix         
         DISPLAY p_den_turno TO den_turno
            END IF
        
        
   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0705

         IF SQLCA.sqlcode <> 0 THEN
            CLEAR FORM
         END IF

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_de_para_turno_885.* = p_de_para_turno_885a.*
      CALL pol0705_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM de_para_turno_885",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY turno_logix"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_de_para_turno_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0705_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0705_exibe_dados()
#------------------------------#
 
   SELECT den_turno
     INTO p_den_turno
     FROM turno
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno = p_de_para_turno_885.turno_logix

   DISPLAY BY NAME p_de_para_turno_885.*
   DISPLAY p_den_turno TO den_turno
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0705_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_de_para_turno_885.*                                              
     FROM de_para_turno_885
     WHERE cod_empresa = p_cod_empresa 
       AND turno_simula = p_de_para_turno_885.turno_simula
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","de_para_turno_885")   
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------#
 FUNCTION pol0705_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0705_cursor_for_update() THEN
      LET p_de_para_turno_885a.* = p_de_para_turno_885.*
      IF pol0705_entrada_dados("M") THEN
         UPDATE de_para_turno_885
            SET turno_logix = p_de_para_turno_885.turno_logix
              WHERE cod_empresa = p_cod_empresa
                AND turno_simula = p_de_para_turno_885.turno_simula
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","de_para_turno_885")
         END IF
      ELSE
         LET p_de_para_turno_885.* = p_de_para_turno_885a.*
         CALL pol0705_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION 


#--------------------------#
 FUNCTION pol0705_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0705_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM de_para_turno_885
         #WHERE CURRENT OF cm_padrao
         WHERE cod_empresa = p_cod_empresa
         AND turno_simula = p_de_para_turno_885.turno_simula
         
         
         
         IF STATUS = 0 THEN
            INITIALIZE p_de_para_turno_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","de_para_turno_885")
         END IF
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  

#-----------------------------------#
 FUNCTION pol0705_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_de_para_turno_885a.* = p_de_para_turno_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_de_para_turno_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_de_para_turno_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_de_para_turno_885.* = p_de_para_turno_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_de_para_turno_885.*
           FROM de_para_turno_885
           WHERE cod_empresa = p_cod_empresa 
             AND turno_logix = p_de_para_turno_885.turno_logix
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0705_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0705_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         turno_logix        LIKE turno.cod_turno,
         den_turno          LIKE turno.den_turno
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07051") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07051 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE turno_logix
        FROM de_para_turno_885
        ORDER BY turno_logix

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].turno_logix 
                         
        SELECT den_turno
        INTO pr_empresa[pr_index].den_turno
        FROM turno
       WHERE cod_turno = pr_empresa[pr_index].turno_logix                                

      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_empresa TO sr_empresa.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0705
  
   RETURN pr_empresa[pr_index].turno_logix
      
END FUNCTION 



#-----------------------#
FUNCTION pol0705_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(turno_logix)
         CALL log009_popup(5,12,"Turno","turno",
              "cod_turno","den_turno","pol0705","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0705
         IF p_codigo IS NOT NULL THEN
           LET p_de_para_turno_885.turno_logix = p_codigo CLIPPED
           DISPLAY p_de_para_turno_885.turno_logix TO turno_logix
         END IF
      
         
   END CASE
END FUNCTION 





#-------------------------------- FIM DE PROGRAMA -----------------------------#

