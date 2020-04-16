#-------------------------------------------------------------------#
# PROGRAMA: pol0700                                                 #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 10/12/2007                                              #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_familia        LIKE familia_insumo_885.cod_familia,
          p_den_familia        LIKE familia.den_familia,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_cod_empresa        LIKE empresa.cod_empresa,
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
          sr_index             SMALLINT,
          p_msg                CHAR(100)
          
   DEFINE p_familia_insumo_885   RECORD LIKE familia_insumo_885.*,
          p_familia_insumo_885a  RECORD LIKE familia_insumo_885.* 
         

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol0700-10.02.01  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0700.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0700_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0700_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0700") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0700 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0700_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
          COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0700_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF 
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0700_exclusao() THEN
               MESSAGE 'Exclusão efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE "" 
         LET INT_FLAG = 0
         CALL pol0700_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0700_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0700_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
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
   CLOSE WINDOW w_pol0700

END FUNCTION

#--------------------------#
 FUNCTION pol0700_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_familia_insumo_885.* TO NULL
   INITIALIZE p_den_familia TO NULL
   LET p_familia_insumo_885.cod_empresa = p_cod_empresa
   LET p_familia_insumo_885.ies_apara  = 'N'
   LET p_familia_insumo_885.ies_bobina  = 'N'
   LET p_familia_insumo_885.ies_canudo  = 'N'

   IF pol0700_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO familia_insumo_885 VALUES (p_familia_insumo_885.*)
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
 FUNCTION pol0700_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0700

   INPUT BY NAME p_familia_insumo_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_familia
        IF p_funcao = "MODIFICACAO" THEN
           NEXT FIELD ies_apara
        END IF 
      
       

       AFTER FIELD cod_familia
      IF p_familia_insumo_885.cod_familia IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_familia
      ELSE 
         SELECT den_familia
         INTO p_den_familia
         FROM familia
         WHERE cod_empresa = p_cod_empresa 
         AND cod_familia = p_familia_insumo_885.cod_familia
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Familia Inexistente !!!" 
            CLEAR FORM
            NEXT FIELD cod_familia
         END IF 
        
                            
           SELECT cod_familia
           FROM familia_insumo_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_familia = p_familia_insumo_885.cod_familia
            
          
         IF SQLCA.sqlcode = 0 THEN
            ERROR "Familia já parametrizada !!!"
            CLEAR FORM 
            NEXT FIELD cod_familia
         END IF 

         DISPLAY p_den_familia TO den_familia

      END IF
         
      AFTER FIELD ies_apara
        IF p_familia_insumo_885.ies_apara IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD ies_apara
        END IF  

        IF p_familia_insumo_885.ies_apara = 'S' THEN 
           LET p_familia_insumo_885.ies_bobina = 'N'
           DISPLAY p_familia_insumo_885.ies_bobina TO ies_bobina
           LET p_familia_insumo_885.ies_canudo = 'N'
           DISPLAY p_familia_insumo_885.ies_canudo TO ies_canudo
           EXIT INPUT
        END IF  

      AFTER FIELD ies_bobina
        IF p_familia_insumo_885.ies_bobina IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD ies_bobina
        END IF  

        IF p_familia_insumo_885.ies_bobina = 'S' THEN 
           LET p_familia_insumo_885.ies_apara = 'N'
           DISPLAY p_familia_insumo_885.ies_apara TO ies_apara
           LET p_familia_insumo_885.ies_canudo = 'N'
           DISPLAY p_familia_insumo_885.ies_canudo TO ies_canudo
           EXIT INPUT
        END IF  

      AFTER FIELD ies_canudo
        IF p_familia_insumo_885.ies_canudo IS NULL THEN 
           ERROR "Campo com preenchimento obrigatório !!!"
           NEXT FIELD ies_canudo
        END IF  

      ON KEY (control-z)
         CALL pol0700_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0700

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0700_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_familia_insumo_885a.* = p_familia_insumo_885.*

   CONSTRUCT BY NAME where_clause ON familia_insumo_885.cod_familia
  
        ON KEY (control-z)
     #    CALL pol0700_popup()
     
                  LET p_cod_familia = pol0700_carrega_familia() 
               DISPLAY p_den_familia TO den_familia
            IF p_cod_familia IS NOT NULL THEN
               LET p_familia_insumo_885.cod_familia = p_cod_familia CLIPPED
               CURRENT WINDOW IS w_pol0700
               DISPLAY p_familia_insumo_885.cod_familia TO cod_familia
               DISPLAY p_den_familia TO den_familia
            END IF
     
  
  END CONSTRUCT  
  
   CALL log006_exibe_teclas("01",p_versao)

   CURRENT WINDOW IS w_pol0700

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_familia_insumo_885.* = p_familia_insumo_885a.*
      CALL pol0700_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM familia_insumo_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_familia "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_familia_insumo_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0700_exibe_dados()
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0700_carrega_familia() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_familia        LIKE familia_insumo_885.cod_familia,
         den_familia        LIKE familia.den_familia
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07001") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07001 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_familia
        FROM familia_insumo_885
        ORDER BY cod_familia

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_familia 
                         
        SELECT den_familia
        INTO pr_empresa[pr_index].den_familia
        FROM familia
       WHERE cod_familia = pr_empresa[pr_index].cod_familia

      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_empresa TO sr_empresa.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0700
  
   RETURN pr_empresa[pr_index].cod_familia
      
END FUNCTION 


#------------------------------#
 FUNCTION pol0700_exibe_dados()
#------------------------------#
   SELECT den_familia
     INTO p_den_familia
     FROM familia
    WHERE cod_empresa = p_cod_empresa
      AND cod_familia = p_familia_insumo_885.cod_familia

   DISPLAY BY NAME p_familia_insumo_885.*
   DISPLAY p_den_familia TO den_familia
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0700_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cm_padrao CURSOR FOR

   SELECT * 
     FROM familia_insumo_885
     WHERE cod_empresa = p_cod_empresa 
       AND cod_familia = p_familia_insumo_885.cod_familia
      FOR UPDATE

   OPEN cm_padrao
   FETCH cm_padrao
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","familia_insumo_885")   
      RETURN FALSE
   END IF

END FUNCTION


#-----------------------------#
 FUNCTION pol0700_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0700_cursor_for_update() THEN
      LET p_familia_insumo_885a.* = p_familia_insumo_885.*
      IF pol0700_entrada_dados("MODIFICACAO") THEN
         UPDATE familia_insumo_885
            SET ies_apara  = p_familia_insumo_885.ies_apara,
                ies_bobina = p_familia_insumo_885.ies_bobina
              WHERE cod_empresa = p_cod_empresa
                AND cod_familia = p_familia_insumo_885.cod_familia
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","familia_insumo_885")
         END IF
      ELSE
         LET p_familia_insumo_885.* = p_familia_insumo_885a.*
         CALL pol0700_exibe_dados()
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
 FUNCTION pol0700_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0700_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM familia_insumo_885
          WHERE cod_empresa = p_cod_empresa 
            AND cod_familia = p_familia_insumo_885.cod_familia
         
         IF STATUS = 0 THEN
            INITIALIZE p_familia_insumo_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","familia_insumo_885")
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
 FUNCTION pol0700_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_familia_insumo_885a.* = p_familia_insumo_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_familia_insumo_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_familia_insumo_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_familia_insumo_885.* = p_familia_insumo_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_familia_insumo_885.*
           FROM familia_insumo_885
           WHERE cod_empresa    = p_cod_empresa 
             AND cod_familia = p_familia_insumo_885.cod_familia
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0700_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0700_popup()
#-----------------------#
   DEFINE p_codigo CHAR(15)

    CASE
      WHEN INFIELD(cod_familia)
         CALL log009_popup(5,12,"FAMILIAS","familia",
              "cod_familia","den_familia","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0700
         IF p_codigo IS NOT NULL THEN
           LET p_familia_insumo_885.cod_familia = p_codigo
           DISPLAY p_familia_insumo_885.cod_familia TO cod_familia
         END IF
END CASE
END FUNCTION 

#-------------------------------- FIM DE PROGRAMA -----------------------------#

