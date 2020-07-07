#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA:pol0986                                                  #
# MODULOS.: pol0986-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: CADASTRO DE OPERADOR POR TURNO  -  POLIMETRI            #
# AUTOR...: POLO  INFORMATICA  - Thiago		                          #
# DATA....: 08/06/2007                                              #
# ALTERADO: 08/06/2007 por Ana Paula - versao 00                    #
#-------------------------------------------------------------------#

 DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_index              SMALLINT,
          s_index              SMALLINT,
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
          p_caminho            CHAR(80),
		  p_msg               CHAR(500),
          p_den_turno          LIKE turno.den_turno,
          p_nom_funcionario    LIKE funcionario.nom_funcionario
          
   DEFINE p_rovoperad_pad_man912   RECORD LIKE rovoperad_pad_man912.*,
          p_rovoperad_pad_man912a  RECORD LIKE rovoperad_pad_man912.* 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0986-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0986.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0986_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0986_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0986") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0986 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0986_inclusao() THEN
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
            IF pol0986_modificacao() THEN
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
            IF pol0986_exclusao() THEN
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
         CALL pol0986_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0986_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0986_paginacao("ANTERIOR")
	  COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0986_sobre()
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
   CLOSE WINDOW w_pol0986

END FUNCTION

#--------------------------#
 FUNCTION pol0986_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   INITIALIZE p_rovoperad_pad_man912.* TO NULL
   LET p_rovoperad_pad_man912.cod_empresa = p_cod_empresa

   IF pol0986_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO rovoperad_pad_man912 VALUES (p_rovoperad_pad_man912.*)
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
 FUNCTION pol0986_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0986

   INPUT BY NAME p_rovoperad_pad_man912.*
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_turno
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD operador_padrao
      END IF

      AFTER FIELD cod_turno
      IF p_rovoperad_pad_man912.cod_turno IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_turno
      END IF

      INITIALIZE p_den_turno TO NULL
      
      SELECT den_turno
        INTO p_den_turno
        FROM turno
       WHERE cod_empresa  = p_cod_empresa 
         AND cod_turno    = p_rovoperad_pad_man912.cod_turno

      IF STATUS <> 0 THEN
         ERROR 'Turno não cadastrado !!!'
         NEXT FIELD cod_turno
      END IF
         
      DISPLAY p_den_turno TO den_turno

      SELECT *
        FROM rovoperad_pad_man912
       WHERE cod_empresa = p_cod_empresa
         AND cod_turno   = p_rovoperad_pad_man912.cod_turno
         
      IF STATUS = 0 THEN
         ERROR "Turno já cadastrado na rovoperad_pad_man912 !!!"
         NEXT FIELD cod_turno
      END IF         
      
      AFTER FIELD operador_padrao
      IF p_rovoperad_pad_man912.operador_padrao IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD operador_padrao
      END IF

      INITIALIZE p_nom_funcionario TO NULL

      SELECT nom_funcionario
        INTO p_nom_funcionario
        FROM funcionario
       WHERE cod_empresa   = p_cod_empresa 
         AND num_matricula = p_rovoperad_pad_man912.operador_padrao

      IF STATUS <> 0 THEN
         ERROR 'Operador não cadastrado !!!'
         NEXT FIELD operador_padrao
      END IF

      DISPLAY p_nom_funcionario TO nom_funcionario
      
      ON KEY (control-z)
         CALL pol0986_popup()

    END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0986

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0986_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_rovoperad_pad_man912a.* = p_rovoperad_pad_man912.*

   CONSTRUCT BY NAME where_clause ON
        rovoperad_pad_man912.cod_turno

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0986

   IF INT_FLAG <> 0 THEN
      LET INT_FLAG = 0 
      LET p_rovoperad_pad_man912.* = p_rovoperad_pad_man912a.*
      CALL pol0986_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM rovoperad_pad_man912 ",
                  " where cod_empresa = '",p_cod_empresa,"' ",
                  " and ", where_clause CLIPPED,                 
                  "ORDER BY cod_turno "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_rovoperad_pad_man912.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0986_exibe_dados()
   END IF
        
END FUNCTION

#------------------------------#
 FUNCTION pol0986_exibe_dados()
#------------------------------#

   INITIALIZE p_den_turno TO NULL 

   SELECT den_turno
     INTO p_den_turno
     FROM turno
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno   = p_rovoperad_pad_man912.cod_turno
    
   SELECT nom_funcionario
     INTO p_nom_funcionario
     FROM funcionario
    WHERE cod_empresa   = p_cod_empresa
      AND num_matricula = p_rovoperad_pad_man912.operador_padrao
      
   DISPLAY BY NAME p_rovoperad_pad_man912.*
   DISPLAY p_den_turno       TO den_turno
   DISPLAY p_nom_funcionario TO nom_funcioanrio
      
END FUNCTION

#-----------------------------------#
 FUNCTION pol0986_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_rovoperad_pad_man912.*                                              
     FROM rovoperad_pad_man912
    WHERE cod_empresa = p_cod_empresa
      AND cod_turno   = p_rovoperad_pad_man912.cod_turno
   FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","rovoperad_pad_man912")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0986_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0986_cursor_for_update() THEN
      LET p_rovoperad_pad_man912a.* = p_rovoperad_pad_man912.*
      IF pol0986_entrada_dados("MODIFICACAO") THEN
         UPDATE rovoperad_pad_man912
            SET operador_padrao = p_rovoperad_pad_man912.operador_padrao
          WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","rovoperad_pad_man912")
         END IF
      ELSE
         LET p_rovoperad_pad_man912.* = p_rovoperad_pad_man912a.*
         CALL pol0986_exibe_dados()
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
 FUNCTION pol0986_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0986_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM rovoperad_pad_man912
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_rovoperad_pad_man912.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","rovoperad_pad_man912")
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
 FUNCTION pol0986_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_rovoperad_pad_man912a.* =  p_rovoperad_pad_man912.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_rovoperad_pad_man912.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_rovoperad_pad_man912.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_rovoperad_pad_man912.* = p_rovoperad_pad_man912a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_rovoperad_pad_man912.*
           FROM rovoperad_pad_man912
          WHERE cod_empresa = p_cod_empresa
            AND cod_turno   = p_rovoperad_pad_man912.cod_turno
                            
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0986_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION

#-----------------------#
FUNCTION pol0986_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_turno)
         CALL log009_popup(8,15,"TURNO","turno",
              "cod_turno","den_turno","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0986
         IF p_codigo IS NOT NULL THEN
            LET p_rovoperad_pad_man912.cod_turno = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_turno
         END IF
      WHEN INFIELD(operador_padrao)
         CALL log009_popup(8,15,"OPERADOR","funcionario",
              "num_matricula","nom_funcionario","","N","") 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0986
         IF p_codigo IS NOT NULL THEN
            LET p_rovoperad_pad_man912.operador_padrao = p_codigo CLIPPED
            DISPLAY p_codigo TO operador_padrao
         END IF
   END CASE
END FUNCTION
#-----------------------#
 FUNCTION pol0986_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#


