#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0768                                                 #
# MODULOS.: pol0768-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE VEICULO - CIBRAPEL                          #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 03/03/2008                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_veiculo        CHAR(15),
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
          
   DEFINE p_veiculo_885   RECORD LIKE veiculo_885.*,
          p_veiculo_885a  RECORD LIKE veiculo_885.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0768-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0768.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0768_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0768_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0768") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0768 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  # DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0768_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
    {  COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0768_modificacao() THEN
               MESSAGE 'Modificação efetuada com sucesso !!!'
            ELSE
               MESSAGE 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF}
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0768_exclusao() THEN
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
         CALL pol0768_consulta()
         IF p_ies_cons THEN
       #     NEXT OPTION "Seguinte" 
         END IF
     { COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0768_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0768_paginacao("ANTERIOR")
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
        LET INT_FLAG = 0}
      COMMAND "Fim"       "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0768

END FUNCTION

#--------------------------#
 FUNCTION pol0768_inclusao()
#--------------------------#

   CLEAR FORM
   #DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_veiculo_885.* TO NULL
  # LET p_veiculo_885.cod_empresa = p_cod_empresa

   IF pol0768_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO veiculo_885 VALUES (p_veiculo_885.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   ELSE
      CLEAR FORM
      #DISPLAY p_cod_empresa TO cod_empresa
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0768_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0768

   INPUT BY NAME p_veiculo_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_veiculo
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD cod_veiculo
      END IF 
      
      AFTER FIELD cod_veiculo
      IF p_veiculo_885.cod_veiculo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_veiculo
      ELSE
                
         SELECT cod_veiculo
           FROM veiculo_885
          WHERE cod_veiculo = p_veiculo_885.cod_veiculo
          
         IF STATUS = 0 THEN
            ERROR "Código do Veiculo já Cadastrado na Tabela veiculo_885 !!!"
            NEXT FIELD cod_veiculo
         END IF
         NEXT FIELD den_veiculo
      END IF
    
           AFTER FIELD den_veiculo
      IF p_veiculo_885.den_veiculo IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD den_veiculo
      ELSE
                
         SELECT den_veiculo
           FROM veiculo_885
       
            WHERE den_veiculo = p_veiculo_885.den_veiculo
          
         IF STATUS = 0 THEN
            ERROR "Nome do Veiculo já Cadastrado na Tabela veiculo_885 !!!"
            NEXT FIELD den_veiculo
         END IF
      END IF

      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0768

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0768_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   #DISPLAY p_cod_empresa TO cod_empresa
   LET p_veiculo_885a.* = p_veiculo_885.*

   CONSTRUCT BY NAME where_clause ON veiculo_885.cod_veiculo
  
      ON KEY (control-z)
      LET p_cod_veiculo = pol0768_carrega_form()
      IF p_cod_veiculo IS NOT NULL THEN
         LET p_veiculo_885.cod_veiculo = p_cod_veiculo
         CURRENT WINDOW IS w_pol0768
         DISPLAY p_veiculo_885.cod_veiculo TO cod_veiculo
      END IF

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0768

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_veiculo_885.* = p_veiculo_885a.*
      CALL pol0768_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM veiculo_885 ",
                  " where cod_veiculo = '",p_veiculo_885.cod_veiculo,"' ",
                 # " and den_veiculo = '",p_veiculo_885.den_veiculo,"' ",
                 # " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_veiculo "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_veiculo_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0768_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0768_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_veiculo_885.*
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0768_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_veiculo_885.*                                              
     FROM veiculo_885
     WHERE cod_veiculo = p_veiculo_885.cod_veiculo
    # AND den_veiculo = p_veiculo_885.den_veiculo
      #FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","VEICULO_885")   
      RETURN FALSE
   END IF

END FUNCTION

{#-----------------------------#
 FUNCTION pol0768_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0768_cursor_for_update() THEN
      LET p_veiculo_885a.* = p_veiculo_885.*
      IF pol0768_entrada_dados("MODIFICACAO") THEN
         UPDATE veiculo_885
            SET cod_veiculo = p_veiculo_885.cod_veiculo,
                den_veiculo = p_veiculo_885.den_veiculo
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","veiculo_885")
         END IF
      ELSE
         LET p_veiculo_885.* = p_veiculo_885a.*
         CALL pol0768_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION}

#--------------------------#
 FUNCTION pol0768_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0768_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM veiculo_885
         WHERE cod_veiculo = p_veiculo_885.cod_veiculo
         #AND den_veiculo = p_veiculo_885.den_veiculo
         IF STATUS = 0 THEN
            INITIALIZE p_veiculo_885.* TO NULL
            CLEAR FORM
        #    DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","veiculo_885")
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
 FUNCTION pol0768_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_veiculo_885a.* = p_veiculo_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_veiculo_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_veiculo_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_veiculo_885.* = p_veiculo_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_veiculo_885.*
           FROM veiculo_885
          WHERE cod_veiculo = p_veiculo_885.cod_veiculo
          #AND den_veiculo = p_veiculo_885.den_veiculo
          
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0768_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#   
 FUNCTION pol0768_carrega_form() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_veiculo LIKE veiculo_885.cod_veiculo,
         den_veiculo LIKE veiculo_885.den_veiculo
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07681") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07681 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_veiculo,
           den_veiculo
     FROM veiculo_885
     #WHERE cod_veiculo = p_veiculo_885.cod_veiculo 
     
     ORDER BY cod_veiculo

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_veiculo, 
                         pr_lista[pr_index].den_veiculo
                                               
       {   SELECT den_veiculo
        INTO pr_lista[pr_index].den_veiculo
        FROM veiculo_885
       WHERE cod_veiculo = pr_lista[pr_index].cod_veiculo }

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_lista TO sr_lista.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0768

  # LET p_veiculo_885.cod_veiculo = pr_lista[pr_index].cod_veiculo
   
   RETURN pr_lista[pr_index].cod_veiculo
      
END FUNCTION 



#-------------------------------- FIM DE PROGRAMA -----------------------------#

