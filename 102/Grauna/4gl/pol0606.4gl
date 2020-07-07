#-------------------------------------------------------------------#
# SISTEMA.: INTEGRAÇÃO LOGIX X TRIM                                 #
# PROGRAMA: pol0606                                                 #
# OBJETIVO: CADASTRO ITEM NÃO ENVIADO OU CEDIDO POR OUTRA OC-LINHA  #
# AUTOR...: IVO HONÓRIO BARBOSA                                     #
# DATA....: 05/06/2007                                              #
# TABELA..: ITEM_EMPREST_1040                                       #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_salto              SMALLINT,
          p_erro_critico       SMALLINT,
          p_existencia         SMALLINT,
          p_num_seq            SMALLINT,
          P_Comprime           CHAR(01),
          p_descomprime        CHAR(01),
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
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080)
          
   DEFINE p_item_emprest_1040   RECORD LIKE item_emprest_1040.*,
          p_item_emprest_1040a  RECORD LIKE item_emprest_1040.* 

   DEFINE p_den_item          LIKE item.den_item

END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0606-05.00.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0606.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0606_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0606_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0606") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0606 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0606_inclusao() THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0606_modificacao() THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0606_exclusao() THEN
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
         CALL pol0606_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0606_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0606_paginacao("ANTERIOR")
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
   CLOSE WINDOW w_pol0606

END FUNCTION

#--------------------------#
 FUNCTION pol0606_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_item_emprest_1040.* TO NULL
   LET p_item_emprest_1040.cod_empresa = p_cod_empresa
   LET p_item_emprest_1040.cod_usuario = p_user
   LET p_item_emprest_1040.dat_hor = CURRENT YEAR TO SECOND
   DISPLAY p_item_emprest_1040.cod_usuario TO cod_usuario
   DISPLAY p_item_emprest_1040.dat_hor TO dat_hor

   IF pol0606_entrada_dados("I") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO item_emprest_1040 VALUES (p_item_emprest_1040.*)
      IF SQLCA.SQLCODE <> 0 THEN 
	 CALL log003_err_sql("INCLUSAO","item_emprest_1040")       
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
 FUNCTION pol0606_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_item_emprest_1040.* WITHOUT DEFAULTS
                 
      BEFORE FIELD oc_linha_orig
         IF p_funcao = 'M' THEN
            NEXT FIELD oc_linha_emp
         END IF
      
      AFTER FIELD oc_linha_orig
         IF LENGTH(p_item_emprest_1040.oc_linha_orig) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD oc_linha_orig   
         END IF

      BEFORE FIELD cod_item
         IF p_funcao = 'M' THEN
            NEXT FIELD oc_linha_emp
         END IF
      
      AFTER FIELD cod_item
         IF LENGTH(p_item_emprest_1040.cod_item) = 0 THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         END IF

         CALL pol0606_le_item()

         IF STATUS = 100 THEN
            ERROR 'Item Inexistente !!!'
            NEXT FIELD cod_item
         ELSE
            IF STATUS = 0 THEN
               DISPLAY p_den_item TO den_item
            ELSE
               CALL log003_err_sql("LEITURA","ITEM")       
               LET INT_FLAG = TRUE
               EXIT INPUT
            END IF
         END IF

      AFTER INPUT
         IF NOT INT_FLAG AND p_funcao = 'I' THEN
            IF LENGTH(p_item_emprest_1040.cod_item) = 0 THEN 
               ERROR "Campo com preenchimento obrigatório !!!"
               NEXT FIELD cod_item   
            END IF
            CALL pol0606_le_item_emprest_1040()
            IF STATUS = 0 THEN
               ERROR 'Item Já Cadastrado !!!'
               NEXT FIELD cod_item
            ELSE
               IF STATUS <> 100 THEN
                  CALL log003_err_sql("LEITURA","ITEM_EMPREST_1040")       
                  LET INT_FLAG = TRUE
                  EXIT INPUT
               END IF
            END IF
         END IF
         
      ON KEY (control-z)
         CALL pol0606_popup()

   END INPUT 

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
FUNCTION pol0606_le_item_emprest_1040()
#--------------------------------------#

   SELECT cod_empresa
     FROM item_emprest_1040
    WHERE cod_empresa   = p_cod_empresa
      AND oc_linha_orig = p_item_emprest_1040.oc_linha_orig
      AND cod_item      = p_item_emprest_1040.cod_item

END FUNCTION

#-------------------------#
FUNCTION pol0606_le_item()
#-------------------------#

   SELECT den_item
     INTO p_den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item   = p_item_emprest_1040.cod_item

END FUNCTION


#-----------------------#
FUNCTION pol0606_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_item)

         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01", p_versao)
         CURRENT WINDOW IS w_pol0606

         IF p_codigo IS NOT NULL THEN
           LET p_item_emprest_1040.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE

END FUNCTION 

#--------------------------#
 FUNCTION pol0606_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_item_emprest_1040a.* = p_item_emprest_1040.*

   CONSTRUCT BY NAME where_clause ON
      item_emprest_1040.oc_linha_orig,
      item_emprest_1040.cod_item,
      item_emprest_1040.oc_linha_emp

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_item_emprest_1040.* = p_item_emprest_1040a.*
      CALL pol0606_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * ",
                  "  FROM item_emprest_1040 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY oc_linha_orig, cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","item_emprest_1040")            
      LET p_ies_cons = FALSE
      RETURN
   END IF
   OPEN cq_padrao

   FETCH cq_padrao INTO p_item_emprest_1040.*

   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0606_exibe_dados()
   END IF

END FUNCTION

#------------------------------#
 FUNCTION pol0606_exibe_dados()
#------------------------------#

   CLEAR FORM
   DISPLAY BY NAME p_item_emprest_1040.*
   
   CALL pol0606_le_item()

   IF STATUS <> 0 THEN
      CALL log003_err_sql("LEITURA","ITEM")            
   END IF
   
   DISPLAY p_den_item TO den_item
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0606_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_item_emprest_1040a.* = p_item_emprest_1040.*
      WHILE TRUE
         
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao 
                                       INTO p_item_emprest_1040.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao 
                                       INTO p_item_emprest_1040.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_item_emprest_1040.* = p_item_emprest_1040a.*
            EXIT WHILE
         END IF

				 SELECT *
				   INTO p_item_emprest_1040.*
			  	 FROM item_emprest_1040
				  WHERE cod_empresa   = p_cod_empresa
				    AND oc_linha_orig = p_item_emprest_1040.oc_linha_orig
				    AND cod_item      = p_item_emprest_1040.cod_item
				   
				 IF STATUS = 0 THEN
            CALL pol0606_exibe_dados()
            EXIT WHILE
				 ELSE
				    IF STATUS <> 100 THEN
    				   CALL log003_err_sql("LEITURA","item_emprest_1040")            
				       LET p_ies_cons = FALSE
				       RETURN
				    END IF
				 END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------------------#
 FUNCTION pol0606_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
   SELECT * 
     INTO p_item_emprest_1040.*                                              
     FROM item_emprest_1040  
    WHERE cod_empresa  = p_cod_empresa
	    AND oc_linha_orig = p_item_emprest_1040.oc_linha_orig
	    AND cod_item      = p_item_emprest_1040.cod_item
      FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","item_emprest_1040")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0606_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0606_cursor_for_update() THEN
      LET p_item_emprest_1040a.* = p_item_emprest_1040.*
      IF pol0606_entrada_dados("M") THEN
         UPDATE item_emprest_1040 
            SET item_emprest_1040.* = p_item_emprest_1040.*
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","item_emprest_1040")
         END IF
      ELSE
         LET p_item_emprest_1040.* = p_item_emprest_1040a.*
         CALL pol0606_exibe_dados()
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
 FUNCTION pol0606_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0606_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_emprest_1040
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_item_emprest_1040.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","item_emprest_1040")
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


