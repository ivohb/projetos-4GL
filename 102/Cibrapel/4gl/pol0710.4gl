#-------------------------------------------------------------------#
# PROGRAMA: pol0710                                                 #
# OBJETIVO: CADASTRO DE OPERAÇÃO- CIBRAPEL                          #
# AUTOR...: POLO INFORMATICA                                        #
# DATA....: 03/01/2008                                              #
# CONVERSÃO 10.02: 17/07/2014 - IVO                                 #
# FUNÇÕES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE 
          p_den_operacao       LIKE estoque_operac.den_operacao,
          p_user               LIKE usuario.nom_usuario,
          p_cod_operacao       LIKE oper_entrada_885.cod_operacao,
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
          
   DEFINE p_oper_entrada_885   RECORD LIKE oper_entrada_885.*,
          p_oper_entrada_885a  RECORD LIKE oper_entrada_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0710-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0710.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0710_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0710_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0710") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0710 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0710_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      { COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0710_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
               
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF }
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0710_exclusao() THEN
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
         CALL pol0710_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0710_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0710_paginacao("ANTERIOR")
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
   CLOSE WINDOW w_pol0710

END FUNCTION

#--------------------------#
 FUNCTION pol0710_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_oper_entrada_885.* TO NULL
   LET p_oper_entrada_885.cod_empresa = p_cod_empresa

   IF pol0710_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO oper_entrada_885 VALUES (p_oper_entrada_885.*)
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
 FUNCTION pol0710_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
   
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0710

   INPUT BY NAME p_oper_entrada_885.* 
      WITHOUT DEFAULTS  

    {  BEFORE FIELD cod_operacao
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD data_disp
      END IF   }
      
      AFTER FIELD cod_operacao
      IF p_oper_entrada_885.cod_operacao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_operacao
      ELSE
          SELECT den_operacao
          INTO p_den_operacao
          FROM estoque_operac
          WHERE cod_empresa = p_cod_empresa 
          AND cod_operacao = p_oper_entrada_885.cod_operacao
   
                            
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Grupo nao Cadastrado na Tabela arranjo !!!" 
            NEXT FIELD cod_operacao  
        END IF  
           
         
           
         SELECT cod_operacao
           FROM oper_entrada_885
          WHERE cod_empresa = p_cod_empresa 
            AND cod_operacao = p_oper_entrada_885.cod_operacao   
        
         IF STATUS = 0 THEN
            ERROR "Código do Arranjo já Cadastrado na Tabela oper_entrada_885 !!!"
            NEXT FIELD cod_operacao
         END IF

      IF STATUS <> 0 THEN
                               
         DISPLAY p_oper_entrada_885.cod_operacao TO cod_operacao
         DISPLAY p_den_operacao TO den_operacao 
         
     # NEXT FIELD data_disp
        END IF

          
      END IF
      
 
               
    ON KEY (control-z)
      CALL pol0710_popup()
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0710

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF  

END FUNCTION

#--------------------------#
 FUNCTION pol0710_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_oper_entrada_885a.* = p_oper_entrada_885.*

   CONSTRUCT BY NAME where_clause ON oper_entrada_885.cod_operacao
  
      ON KEY (control-z)
       # CALL pol0710_popup()
        
           LET p_cod_operacao = pol0710_carrega_empresa() 
               DISPLAY p_den_operacao TO den_operacao 
            IF p_cod_operacao IS NOT NULL THEN
               LET p_oper_entrada_885.cod_operacao = p_cod_operacao CLIPPED
               CURRENT WINDOW IS w_pol0710
         DISPLAY p_oper_entrada_885.cod_operacao TO cod_operacao         
         DISPLAY p_den_operacao TO den_operacao 
            END IF   
        
   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0710

         IF SQLCA.sqlcode <> 0 THEN
            CLEAR FORM
         END IF

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_oper_entrada_885.* = p_oper_entrada_885a.*
      CALL pol0710_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM oper_entrada_885 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_operacao"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_oper_entrada_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      CLEAR FORM 
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0710_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0710_exibe_dados()
#------------------------------#
 
   SELECT den_operacao
     INTO p_den_operacao
     FROM estoque_operac
    WHERE cod_empresa = p_cod_empresa
      AND cod_operacao = p_oper_entrada_885.cod_operacao

   DISPLAY BY NAME p_oper_entrada_885.*
   DISPLAY p_den_operacao TO den_operacao
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0710_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_oper_entrada_885.*                                              
     FROM oper_entrada_885
     WHERE cod_empresa = p_cod_empresa 
       AND cod_operacao = p_oper_entrada_885.cod_operacao
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","oper_entrada_885")   
      RETURN FALSE
   END IF

END FUNCTION


{#-----------------------------#
 FUNCTION pol0710_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0710_cursor_for_update() THEN
      LET p_oper_entrada_885a.* = p_oper_entrada_885.*
      IF pol0710_entrada_dados("MODIFICACAO") THEN
         UPDATE oper_entrada_885
            SET data_disp = p_oper_entrada_885.data_disp
              WHERE cod_empresa = p_cod_empresa
                AND cod_operacao = p_oper_entrada_885.cod_operacao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","oper_entrada_885")
         END IF
      ELSE
         LET p_oper_entrada_885.* = p_oper_entrada_885a.*
         CALL pol0710_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION }


#--------------------------#
 FUNCTION pol0710_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0710_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
      
         DELETE FROM oper_entrada_885
         #WHERE CURRENT OF cm_padrao
         WHERE cod_empresa = p_cod_empresa
         AND cod_operacao = p_oper_entrada_885.cod_operacao
         
         
         
         IF STATUS = 0 THEN
            INITIALIZE p_oper_entrada_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","oper_entrada_885")
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
 FUNCTION pol0710_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_oper_entrada_885a.* = p_oper_entrada_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_oper_entrada_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_oper_entrada_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_oper_entrada_885.* = p_oper_entrada_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_oper_entrada_885.*
           FROM oper_entrada_885
           WHERE cod_empresa = p_cod_empresa 
             AND cod_operacao = p_oper_entrada_885.cod_operacao
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0710_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0710_carrega_empresa() 
#-------------------------------#
 
    DEFINE pr_empresa       ARRAY[3000]
     OF RECORD
         cod_operacao          LIKE oper_entrada_885.cod_operacao,
         den_operacao          LIKE estoque_operac.den_operacao
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07101") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07101 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_empresa CURSOR FOR 
    SELECT UNIQUE cod_operacao
        FROM oper_entrada_885
        ORDER BY cod_operacao

   LET pr_index = 1

   FOREACH cq_empresa INTO pr_empresa[pr_index].cod_operacao 
                         
        SELECT den_operacao
        INTO pr_empresa[pr_index].den_operacao
        FROM estoque_operac
       WHERE cod_operacao = pr_empresa[pr_index].cod_operacao                                

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
      
   CLOSE WINDOW w_pol0710
  
  
   RETURN pr_empresa[pr_index].cod_operacao
      
END FUNCTION 


#-----------------------#
FUNCTION pol0710_popup()
#-----------------------#
   DEFINE p_codigo CHAR(05)

   CASE
      WHEN INFIELD(cod_operacao)
         CALL log009_popup(8,10,"OPERACAO","estoque_operac",
              "cod_operacao","den_operacao","","S","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
         CURRENT WINDOW IS w_pol0710
          
         IF p_codigo IS NOT NULL THEN
           LET p_oper_entrada_885.cod_operacao = p_codigo CLIPPED
           DISPLAY p_codigo TO cod_operacao
         END IF 
      
         
   END CASE
END FUNCTION 


#-------------------------------- FIM DE PROGRAMA -----------------------------#

