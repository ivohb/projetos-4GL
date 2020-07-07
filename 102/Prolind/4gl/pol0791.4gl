#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0791                                                 #
# MODULOS.: pol0791-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: Trata Cliente Atlas                                     #
# AUTOR...: POLO INFORMATICA - Ana Paula QF                         #
# DATA....: 14/04/2008 por Ana Paula - versao 00                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_cliente        LIKE clientes.cod_cliente,
          p_den_cliente        LIKE clientes.nom_cliente,
          p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
          p_retorno            SMALLINT,
          p_msg                CHAR(300),
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
          p_nom_cliente        LIKE clientes.nom_cliente
          
   DEFINE p_cliente_1054       RECORD 
          cod_cliente          LIKE clientes.cod_cliente
   END RECORD
   
   DEFINE p_cliente_1054a      RECORD 
          cod_cliente          LIKE clientes.cod_cliente
   END RECORD
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0791-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0791.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0791_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0791_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0791") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0791 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0791_inclusao() THEN
            MESSAGE 'Inclus�o efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Opera��o cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0791_exclusao() THEN
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
         CALL pol0791_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0791_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0791_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
         CALL pol0791_sobre() 
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
   CLOSE WINDOW w_pol0791

END FUNCTION

#-----------------------#
FUNCTION pol0791_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0791_inclusao()
#--------------------------#

   CLEAR FORM
   
   INITIALIZE p_cliente_1054.* TO NULL

   IF pol0791_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO cliente_1054 VALUES (p_cliente_1054.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
      ELSE
      CLEAR FORM
      END IF 
   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0791_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0791

   INPUT BY NAME p_cliente_1054.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_cliente
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD nom_cliente
      END IF 
      
      AFTER FIELD cod_cliente
      IF p_cliente_1054.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
         INTO p_nom_cliente
         FROM clientes
         WHERE cod_cliente = p_cliente_1054.cod_cliente
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Cliente nao Cadastrado !!!" 
            NEXT FIELD cod_cliente
         END IF
                  
           SELECT cod_cliente
           INTO p_cod_cliente
           FROM cliente_1054
          WHERE cod_cliente = p_cliente_1054.cod_cliente
            
          
         IF STATUS = 0 THEN
            ERROR "C�digo do Cliente j� Cadastrado na Tabela cliente_1054 !!!"
            NEXT FIELD cod_cliente
         END IF
         DISPLAY p_nom_cliente TO nom_cliente 
      END IF
         
         ON KEY (control-z)
               LET p_cod_cliente = vdp372_popup_cliente()
         IF p_cod_cliente IS NOT NULL THEN
            LET p_cliente_1054.cod_cliente = p_cod_cliente
            CURRENT WINDOW IS w_pol0791
            DISPLAY p_cliente_1054.cod_cliente TO cod_cliente
         END IF
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0791

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0791_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   
   LET p_cliente_1054a.* = p_cliente_1054.*

   CONSTRUCT BY NAME where_clause ON cliente_1054.cod_cliente
  
      ON KEY (control-z)
              LET p_cod_cliente = pol0791_carrega_cliente()
         IF p_cod_cliente IS NOT NULL THEN
            LET p_cliente_1054.cod_cliente = p_cod_cliente  CLIPPED
            CURRENT WINDOW IS w_pol0791
            DISPLAY p_cliente_1054.cod_cliente TO cod_cliente
         END IF

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0791

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_cliente_1054.* = p_cliente_1054a.*
      CALL pol0791_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM cliente_1054 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_cliente_1054.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0791_exibe_dados()
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0791_carrega_cliente() 
#-------------------------------#
 
  DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_cliente    LIKE clientes.cod_cliente,
         nom_cliente    LIKE clientes.nom_cliente
     END RECORD

    INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07911") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07911 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item1 CURSOR FOR 
    SELECT cod_cliente 
      FROM cliente_1054
     ORDER BY cod_cliente

   LET pr_index = 1

   FOREACH cq_item1 INTO pr_item[pr_index].cod_cliente
   
      SELECT nom_cliente
        INTO pr_item[pr_index].nom_cliente
        FROM clientes
       WHERE cod_cliente = pr_item[pr_index].cod_cliente

      LET pr_index = pr_index + 1
      IF pr_index > 3000 THEN
         ERROR "Limite de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

      LET pr_index = ARR_CURR()
      LET sr_index = SCR_LINE() 
      
   CLOSE WINDOW w_pol0791
   
   RETURN pr_item[pr_index].cod_cliente
      
END FUNCTION 

#------------------------------#
 FUNCTION pol0791_exibe_dados()
#------------------------------#
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cliente_1054.cod_cliente

   DISPLAY BY NAME p_cliente_1054.*
   DISPLAY p_nom_cliente TO nom_cliente
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0791_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_cliente_1054.*                                              
     FROM cliente_1054
    WHERE cod_cliente = p_cliente_1054.cod_cliente
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","cliente_1054")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 {FUNCTION pol0791_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0791_cursor_for_update() THEN
      LET p_cliente_1054a.* = p_cliente_1054.*
      IF pol0791_entrada_dados("MODIFICACAO") THEN
         UPDATE cliente_1054
            SET cod_cliente = p_cliente_1054.cod_cliente
              WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","cliente_1054")
         END IF
      ELSE
         LET p_cliente_1054.* = p_cliente_1054a.*
         CALL pol0791_exibe_dados()
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
 FUNCTION pol0791_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0791_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM cliente_1054
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_cliente_1054.* TO NULL
            CLEAR FORM
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","cliente_1054")
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
 FUNCTION pol0791_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cliente_1054a.* = p_cliente_1054.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cliente_1054.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cliente_1054.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_cliente_1054.* = p_cliente_1054a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_cliente_1054.*
           FROM cliente_1054
          WHERE cod_cliente = p_cliente_1054.cod_cliente 
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0791_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#
