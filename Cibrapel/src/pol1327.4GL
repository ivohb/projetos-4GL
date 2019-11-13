#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1327                                                 #
# OBJETIVO: CADASTRO DE CRIENTES COM UM PEDIDO POR NOTA             #
# AUTOR...: IVO                                                     #
# DATA....: 17/07/17                                                #
# FUNÇÕES: FUNC002                                                  #
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
         
  
   DEFINE p_tela               RECORD 
          cod_cliente          LIKE clientes.cod_cliente,
          nom_cliente          LIKE clientes.nom_cliente
   END RECORD

END GLOBALS

DEFINE p_cod_cliente      CHAR(15),
       p_cod_cliente_ant  CHAR(15)

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1327-12.00.01  "
   CALL func002_versao_prg(p_versao)
   
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1327_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1327_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1327") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1327 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
  
    DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1327_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1327_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão"
         END IF  
      COMMAND "Consultar" "Consulta dados da tabela"
         IF pol1327_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1327_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1327_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa"
         END IF 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL func002_exibe_versao(p_versao)
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1327

END FUNCTION

#--------------------------#
 FUNCTION pol1327_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_tela.* TO NULL

   IF pol1327_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO nao_agrupar_885 
       VALUES (p_cod_empresa, p_tela.cod_cliente)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","nao_agrupar_885")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#---------------------------------------#
 FUNCTION pol1327_edita_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(01)

   INPUT BY NAME p_tela.* WITHOUT DEFAULTS
         
      AFTER FIELD cod_cliente
      IF p_tela.cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente   
      END IF
         
      SELECT nom_cliente
        INTO p_tela.nom_cliente
        FROM clientes
       WHERE cod_cliente  = p_tela.cod_cliente
      
      IF STATUS = 100 THEN
         ERROR "Cliente não cadastrado no Logix"
         NEXT FIELD cod_cliente
      END IF    

      SELECT 1
        FROM nao_agrupar_885
       WHERE cod_empresa = p_cod_empresa
         AND cod_cliente  = p_tela.cod_cliente
      
      IF STATUS = 0 THEN
         ERROR "Cliente já cadastrado no pol1327."
         NEXT FIELD cod_cliente
      END IF    
      
      DISPLAY p_tela.nom_cliente TO nom_cliente
      
    ON KEY (control-z)
      CALL pol1327_popup()
           
   END INPUT 


   IF INT_FLAG  THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1327_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_tela.cod_cliente = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_cliente
         END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1327_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_cliente_ant = p_cod_cliente
   LET p_ies_cons = FALSE
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      nao_agrupar_885.cod_cliente
      
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_cliente = p_cod_cliente_ant
         CALL pol1327_exibe_dados() RETURNING p_status
      END IF 
      RETURN FALSE  
   END IF

   LET sql_stmt = "SELECT cod_cliente ",
                  "  FROM nao_agrupar_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_cliente"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_cliente

   IF STATUS = NOTFOUND THEN
      ERROR "Argumentos de pesquisa não encontrados"
      LET p_ies_cons = FALSE
      RETURN FALSE 
   ELSE 
      IF pol1327_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE 

END FUNCTION

#------------------------------#
 FUNCTION pol1327_exibe_dados()
#------------------------------#

  LET p_tela.cod_cliente = p_cod_cliente

  SELECT nom_cliente
    INTO p_tela.nom_cliente
    FROM clientes
   WHERE cod_cliente  = p_cod_cliente

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','clientes')
      LET p_tela.nom_cliente = ''
   END IF

   DISPLAY BY NAME p_tela.*
   
   RETURN TRUE

END FUNCTION

#-----------------------------------#
 FUNCTION pol1327_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_cliente_ant = p_cod_cliente

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_cliente
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_cliente
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_cliente
           FROM nao_agrupar_885
          WHERE cod_empresa = p_cod_empresa
            AND cod_cliente  = p_cod_cliente
         
         IF STATUS = 0 THEN 
            CALL pol1327_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF 
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção"
            LET p_cod_cliente = p_cod_cliente_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    
      
   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1327_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa 
      FROM nao_agrupar_885  
     WHERE cod_empresa = p_cod_empresa
       AND cod_cliente  = p_cod_cliente
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","nao_agrupar_885")
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1327_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1327_prende_registro() THEN
      DELETE FROM nao_agrupar_885
			WHERE cod_empresa = p_cod_empresa
    		AND cod_cliente  = p_cod_cliente

      IF STATUS = 0 THEN               
         INITIALIZE p_tela TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","nao_agrupar_885")
      END IF
      CLOSE cq_prende
   END IF

   IF p_retorno THEN
      CALL log085_transacao("COMMIT")
   ELSE
      CALL log085_transacao("ROLLBACK")
   END IF

   RETURN p_retorno

END FUNCTION  



#-------------------------------- FIM DE PROGRAMA -----------------------------#