#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0656                                                 #
# MODULOS.: pol0656-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE FORMULARIO - GRAUNA                         #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 29/10/2007                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
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
          
   DEFINE p_rev_form_1040   RECORD LIKE rev_form_1040.*,
          p_rev_form_1040a  RECORD LIKE rev_form_1040.* 

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0656-05.10.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0656.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0656_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0656_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0656") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0656 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0656_inclusao() THEN
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
            IF pol0656_modificacao() THEN
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
            IF pol0656_exclusao() THEN
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
         CALL pol0656_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0656_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0656_paginacao("ANTERIOR")
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
   CLOSE WINDOW w_pol0656

END FUNCTION

#--------------------------#
 FUNCTION pol0656_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_rev_form_1040.* TO NULL
   LET p_rev_form_1040.cod_empresa = p_cod_empresa

   IF pol0656_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO rev_form_1040 VALUES (p_rev_form_1040.*)
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
 FUNCTION pol0656_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0656

   INPUT BY NAME p_rev_form_1040.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_formulario
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD descricao
      END IF 
      
      AFTER FIELD cod_formulario
      IF p_rev_form_1040.cod_formulario IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_formulario
      ELSE
                
         SELECT cod_formulario
           FROM rev_form_1040
          WHERE cod_empresa    = p_cod_empresa
            AND cod_formulario = p_rev_form_1040.cod_formulario
          
         IF STATUS = 0 THEN
            ERROR "Código do Formulario já Cadastrado na Tabela REV_FORM_1040 !!!"
            NEXT FIELD cod_formulario
         END IF
         
      END IF
         
      AFTER FIELD descricao
      IF p_rev_form_1040.descricao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD descricao
      END IF

      AFTER FIELD revisao
      
      IF p_rev_form_1040.revisao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD revisao
      END IF
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0656

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0656_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rev_form_1040a.* = p_rev_form_1040.*

   CONSTRUCT BY NAME where_clause ON rev_form_1040.cod_formulario
  
      ON KEY (control-z)
      LET p_cod_formulario = pol0656_carrega_form()
      IF p_cod_formulario IS NOT NULL THEN
         LET p_rev_form_1040.cod_formulario = p_cod_formulario
         CURRENT WINDOW IS w_pol0656
         DISPLAY p_rev_form_1040.cod_formulario TO cod_formulario
      END IF

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0656

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_rev_form_1040.* = p_rev_form_1040a.*
      CALL pol0656_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM rev_form_1040 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_formulario "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_rev_form_1040.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0656_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0656_exibe_dados()
#------------------------------#

   DISPLAY BY NAME p_rev_form_1040.*
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0656_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_rev_form_1040.*                                              
     FROM rev_form_1040
    WHERE cod_empresa    = p_cod_empresa
      AND cod_formulario = p_rev_form_1040.cod_formulario
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","REV_FORM_1040")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0656_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0656_cursor_for_update() THEN
      LET p_rev_form_1040a.* = p_rev_form_1040.*
      IF pol0656_entrada_dados("MODIFICACAO") THEN
         UPDATE rev_form_1040
            SET descricao = p_rev_form_1040.descricao,
                revisao   = p_rev_form_1040.revisao
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","rev_form_1040")
         END IF
      ELSE
         LET p_rev_form_1040.* = p_rev_form_1040a.*
         CALL pol0656_exibe_dados()
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
 FUNCTION pol0656_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0656_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM rev_form_1040
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_rev_form_1040.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","rev_form_1040")
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
 FUNCTION pol0656_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rev_form_1040a.* = p_rev_form_1040.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_rev_form_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_rev_form_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_rev_form_1040.* = p_rev_form_1040a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_rev_form_1040.*
           FROM rev_form_1040
          WHERE cod_empresa    = p_cod_empresa
            AND cod_formulario = p_rev_form_1040.cod_formulario
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0656_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#   
 FUNCTION pol0656_carrega_form() 
#-----------------------------------#
 
  DEFINE pr_lista       ARRAY[3000]
     OF RECORD
         cod_formulario LIKE rev_form_1040.cod_formulario,
         descricao      LIKE rev_form_1040.descricao
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol06561") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol06561 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_lista CURSOR FOR 
    SELECT cod_formulario,
           descricao
      FROM rev_form_1040
     WHERE cod_empresa = p_cod_empresa
     ORDER BY cod_formulario

   LET pr_index = 1

   FOREACH cq_lista INTO pr_lista[pr_index].cod_formulario, 
                         pr_lista[pr_index].descricao                      

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
      
   CLOSE WINDOW w_pol0656

   LET p_rev_form_1040.cod_formulario = pr_lista[pr_index].cod_formulario
   
   RETURN pr_lista[pr_index].cod_formulario
      
END FUNCTION 



#-------------------------------- FIM DE PROGRAMA -----------------------------#

