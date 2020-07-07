#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0722                                                 #
# MODULOS.: pol0722-LOG0010-LOG0030-LOG0040-LOG0050-LOG0060         #
#           LOG0090-LOG0280-LOG1200-LOG1300-LOG1400-LOG1500         #
# OBJETIVO: Trata Cliente FERRERO - FERRERO                         #
# AUTOR...: POLO INFORMATICA - Ana Paula QF                         #
# DATA....: 22/01/2008 por Ana Paula - versao 00                    #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_cliente        LIKE cli_ferrero_713.cod_cliente,
          p_den_cliente        LIKE clientes.nom_cliente,
          p_user               LIKE usuario.nom_usuario,
          p_cod_empresa        LIKE empresa.cod_empresa,
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
          sr_index             SMALLINT,
          p_msg                CHAR(500),          
          p_nom_cliente        LIKE clientes.nom_cliente
          
   DEFINE p_cli_ferrero_713   RECORD LIKE cli_ferrero_713.*,
          p_cli_ferrero_713a  RECORD LIKE cli_ferrero_713.* 
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0722-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0722.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0722_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0722_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0722") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0722 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0722_inclusao() THEN
            MESSAGE 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            MESSAGE 'Operação cancelada !!!'
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF pol0722_exclusao() THEN
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
         CALL pol0722_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0722_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0722_paginacao("ANTERIOR")
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol0722_sobre()
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
   CLOSE WINDOW w_pol0722

END FUNCTION

#-----------------------#
 FUNCTION pol0722_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Conversão para 10.02.00\n",
               " Autor: Ivo H Barbosa\n",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol0722_inclusao()
#--------------------------#

   CLEAR FORM
   
   INITIALIZE p_cli_ferrero_713.* TO NULL

   IF pol0722_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO cli_ferrero_713 VALUES (p_cli_ferrero_713.*)
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
 FUNCTION pol0722_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0722

   INPUT BY NAME p_cli_ferrero_713.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_cliente
      IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD nom_cliente
      END IF 
      
      AFTER FIELD cod_cliente
      IF p_cli_ferrero_713.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente
      ELSE
         SELECT nom_cliente
         INTO p_nom_cliente
         FROM clientes
         WHERE cod_cliente = p_cli_ferrero_713.cod_cliente
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Cliente nao Cadastrado !!!" 
            NEXT FIELD cod_cliente
         END IF
                  
           SELECT cod_cliente
           INTO p_cod_cliente
           FROM cli_ferrero_713
          WHERE cod_cliente = p_cli_ferrero_713.cod_cliente
            
          
         IF STATUS = 0 THEN
            ERROR "Código do Cliente já Cadastrado na Tabela cli_ferrero_713 !!!"
            NEXT FIELD cod_cliente
         END IF
         DISPLAY p_nom_cliente TO nom_cliente 
      END IF
         
         ON KEY (control-z)
               LET p_cod_cliente = vdp372_popup_cliente()
         IF p_cod_cliente IS NOT NULL THEN
            LET p_cli_ferrero_713.cod_cliente = p_cod_cliente
            CURRENT WINDOW IS w_pol0722
            DISPLAY p_cli_ferrero_713.cod_cliente TO cod_cliente
         END IF
      
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0722

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION


#--------------------------#
 FUNCTION pol0722_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   
   LET p_cli_ferrero_713a.* = p_cli_ferrero_713.*

   CONSTRUCT BY NAME where_clause ON cli_ferrero_713.cod_cliente
  
      ON KEY (control-z)
              LET p_cod_cliente = pol0722_carrega_cliente()
         IF p_cod_cliente IS NOT NULL THEN
            LET p_cli_ferrero_713.cod_cliente = p_cod_cliente  CLIPPED
            CURRENT WINDOW IS w_pol0722
            DISPLAY p_cli_ferrero_713.cod_cliente TO cod_cliente
         END IF

   END CONSTRUCT      
  
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0722

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_cli_ferrero_713.* = p_cli_ferrero_713a.*
      CALL pol0722_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM cli_ferrero_713 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_cliente "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_cli_ferrero_713.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0722_exibe_dados()
   END IF

END FUNCTION


#-------------------------------#   
 FUNCTION pol0722_carrega_cliente() 
#-------------------------------#
 
  DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_cliente    LIKE cli_ferrero_713.cod_cliente,
         nom_cliente    LIKE clientes.nom_cliente
     END RECORD

    INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol07221") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol07221 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item1 CURSOR FOR 
    SELECT cod_cliente 
      FROM cli_ferrero_713
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
      
   CLOSE WINDOW w_pol0722
   
   RETURN pr_item[pr_index].cod_cliente
      
END FUNCTION 

#------------------------------#
 FUNCTION pol0722_exibe_dados()
#------------------------------#
   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cli_ferrero_713.cod_cliente

   DISPLAY BY NAME p_cli_ferrero_713.*
   DISPLAY p_nom_cliente TO nom_cliente
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0722_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_cli_ferrero_713.*                                              
     FROM cli_ferrero_713
    WHERE cod_cliente = p_cli_ferrero_713.cod_cliente
    FOR UPDATE 
   
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","cli_ferrero_713")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 {FUNCTION pol0722_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0722_cursor_for_update() THEN
      LET p_cli_ferrero_713a.* = p_cli_ferrero_713.*
      IF pol0722_entrada_dados("MODIFICACAO") THEN
         UPDATE cli_ferrero_713
            SET cod_cliente = p_cli_ferrero_713.cod_cliente
              WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","cli_ferrero_713")
         END IF
      ELSE
         LET p_cli_ferrero_713.* = p_cli_ferrero_713a.*
         CALL pol0722_exibe_dados()
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
 FUNCTION pol0722_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0722_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM cli_ferrero_713
         WHERE CURRENT OF cm_padrao
         IF STATUS = 0 THEN
            INITIALIZE p_cli_ferrero_713.* TO NULL
            CLEAR FORM
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","cli_ferrero_713")
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
 FUNCTION pol0722_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_cli_ferrero_713a.* = p_cli_ferrero_713.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_cli_ferrero_713.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_cli_ferrero_713.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Direção"
            LET p_cli_ferrero_713.* = p_cli_ferrero_713a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_cli_ferrero_713.*
           FROM cli_ferrero_713
          WHERE cod_cliente = p_cli_ferrero_713.cod_cliente 
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0722_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#

