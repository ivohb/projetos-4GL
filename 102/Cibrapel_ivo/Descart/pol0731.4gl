#-------------------------------------------------------------------#
# SISTEMA.: VENDAS                                                  #
# PROGRAMA: pol0731                                                 #
# OBJETIVO: CADASTRO DE ITEM FT - CIBRAPEL                          #
# AUTOR...: POLO INFORMATICA - Bruno                                #
# DATA....: 01/02/2008                                              #
# CONVERS�O 10.02: 17/07/2014 - IVO                                 #
# FUN��ES: FUNC002                                                  #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_nom_cliente        LIKE clientes.nom_cliente,
          p_nom_item           LIKE item.den_item,
          p_nom_item_reduz     LIKE item.den_item_reduz,
          p_cod_cliente        LIKE ft_item_885.cod_cliente,
          p_cod_item           LIKE ft_item_885.cod_item,
          p_user               LIKE usuario.nom_usuario,
          p_retorno            SMALLINT,
          p_status             SMALLINT,
          p_count              SMALLINT,
          p_houve_erro         SMALLINT,
          comando              CHAR(80),
          p_ies_impressao      CHAR(01),
          g_ies_ambiente       CHAR(01),
          p_trim               CHAR(10),
          p_versao             CHAR(18),
          p_nom_arquivo        CHAR(100),
          p_nom_tela           CHAR(200),
          p_nom_help           CHAR(200),
          p_ies_cons           SMALLINT,
          p_caminho            CHAR(080),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          pr_index2            SMALLINT,  
          sr_index2            SMALLINT,
          p_msg                CHAR(100)

                           
   DEFINE p_ft_item_885   RECORD LIKE ft_item_885.*,
          p_ft_item_885a  RECORD LIKE ft_item_885.* 
          
                    
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "pol0731-10.02.00  "
   CALL func002_versao_prg(p_versao)

   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0731.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0731_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0731_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol0731") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0731 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF pol0731_inclusao() THEN
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
            IF pol0731_modificacao() THEN
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
            IF pol0731_exclusao() THEN
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
         CALL pol0731_consulta()
         IF p_ies_cons THEN
            NEXT OPTION "Seguinte" 
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0731_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0731_paginacao("ANTERIOR")
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
   CLOSE WINDOW w_pol0731

END FUNCTION

#--------------------------#
 FUNCTION pol0731_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
  
   INITIALIZE p_ft_item_885.* TO NULL
   LET p_ft_item_885.cod_empresa = p_cod_empresa
   LET p_ft_item_885.num_sequencia = 1

   IF pol0731_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      WHENEVER ANY ERROR CONTINUE
      INSERT INTO ft_item_885 VALUES (p_ft_item_885.*)
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
 FUNCTION pol0731_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)
    
   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0731

  INPUT BY NAME p_ft_item_885.* 
      WITHOUT DEFAULTS  

      BEFORE FIELD cod_item
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD medidas_internas
      END IF 
                           
      AFTER FIELD cod_item
        IF p_ft_item_885.cod_item IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_item
      ELSE  
         SELECT den_item,den_item_reduz
         INTO p_nom_item,p_nom_item_reduz
         FROM item
         WHERE cod_empresa = p_ft_item_885.cod_empresa
         AND cod_item = p_ft_item_885.cod_item
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Item nao Cadastrado na Tabela ITEM !!!" 
            NEXT FIELD cod_item
         END IF       

         DISPLAY p_nom_item TO nom_item
         DISPLAY p_nom_item_reduz TO nom_reduzido                           
                   
     END IF 

      BEFORE FIELD cod_cliente
        IF p_funcao = "MODIFICACAO" THEN
         NEXT FIELD medidas_internas
      END IF 
      
      
      AFTER FIELD cod_cliente
        IF p_ft_item_885.cod_cliente IS NULL THEN 
          ERROR "Campo com preenchimento obrigat�rio !!!"
          NEXT FIELD cod_item

       END IF

       SELECT nom_cliente
         INTO p_nom_cliente
         FROM clientes
        WHERE cod_cliente = p_ft_item_885.cod_cliente
         
         IF SQLCA.sqlcode <> 0 THEN
            ERROR "Codigo do Cliente nao Cadastrado na Tabela CLIENTES !!!" 
            NEXT FIELD cod_cliente
         END IF
               
         DISPLAY p_nom_cliente TO nom_cliente         

        SELECT cod_item
          FROM ft_item_885
         WHERE cod_item = p_ft_item_885.cod_item 
           AND cod_cliente   = p_ft_item_885.cod_cliente 
         
        IF STATUS = 0 THEN
           ERROR "C�digo do ITEM/CLIENTE j� Cadastrada na Tabela ft_item_885 !!!"
           NEXT FIELD cod_item
        END IF         

          
      ON KEY (control-z)
          CALL pol0731_popup()
                          
   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0731

   IF INT_FLAG = 0 THEN
      RETURN TRUE
   ELSE
      LET INT_FLAG = 0
      RETURN FALSE 
   END IF 

END FUNCTION

#--------------------------#
 FUNCTION pol0731_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause  CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_ft_item_885.* TO NULL
   LET p_ft_item_885a.* = p_ft_item_885.*

   CONSTRUCT BY NAME where_clause ON 
      ft_item_885.cod_item,
      ft_item_885.cod_cliente,
      ft_item_885.nom_item,
      ft_item_885.nom_reduzido
  
      ON KEY (control-z)
         CALL pol0731_popup()

          
   END CONSTRUCT      
    
   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0731

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET p_ft_item_885.* = p_ft_item_885a.*
      CALL pol0731_exibe_dados()
      CLEAR FORM         
      ERROR "Consulta Cancelada"  
      RETURN
   END IF

    LET sql_stmt = "SELECT * FROM ft_item_885 ",
                  " where ", where_clause CLIPPED,                 
                  "ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO p_ft_item_885.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0731_exibe_dados()
   END IF

END FUNCTION


#------------------------------#
 FUNCTION pol0731_exibe_dados()
#------------------------------#
 SELECT den_item,den_item_reduz
 INTO p_nom_item,p_nom_item_reduz
 FROM item
 WHERE cod_empresa = p_ft_item_885.cod_empresa
 AND cod_item = p_ft_item_885.cod_item
 

 DISPLAY BY NAME p_ft_item_885.*
 DISPLAY p_nom_item TO nom_item
 DISPLAY p_nom_item_reduz TO nom_reduzido  
   
   
    
END FUNCTION

#-----------------------------------#
 FUNCTION pol0731_cursor_for_update()
#-----------------------------------#

   CALL log085_transacao("BEGIN")
   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR

   SELECT * 
     INTO p_ft_item_885.*                                              
     FROM ft_item_885
    WHERE cod_empresa = p_ft_item_885.cod_empresa
    AND   cod_item = p_ft_item_885.cod_item
   FOR UPDATE 
   OPEN cm_padrao
   FETCH cm_padrao
   
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("LEITURA","ft_item_885")   
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0731_modificacao()
#-----------------------------#

   LET p_retorno = FALSE

   IF pol0731_cursor_for_update() THEN
      LET p_ft_item_885a.* = p_ft_item_885.*
      IF pol0731_entrada_dados("MODIFICACAO") THEN
         UPDATE ft_item_885
            SET ft_item_885.* = p_ft_item_885.*
         WHERE cod_empresa = p_ft_item_885.cod_empresa
           AND cod_item = p_ft_item_885.cod_item
           AND cod_cliente = p_ft_item_885.cod_cliente
                        
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("MODIFICACAO","ft_item_885")
         END IF
      ELSE
         LET p_ft_item_885.* = p_ft_item_885a.*
         CALL pol0731_exibe_dados()
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
 FUNCTION pol0731_exclusao()
#--------------------------#

   LET p_retorno = FALSE
   IF pol0731_cursor_for_update() THEN
      IF log004_confirm(18,35) THEN
         DELETE FROM ft_item_885
        WHERE cod_empresa = p_ft_item_885.cod_empresa
        AND cod_item = p_ft_item_885.cod_item
        

         IF STATUS = 0 THEN
            INITIALIZE p_ft_item_885.* TO NULL
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("EXCLUSAO","ft_item_885")
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
 FUNCTION pol0731_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET p_ft_item_885a.* = p_ft_item_885.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            p_ft_item_885.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            p_ft_item_885.*
         END CASE

         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Nao Existem Mais Itens Nesta Dire��o"
            LET p_ft_item_885.* = p_ft_item_885a.* 
            EXIT WHILE
         END IF

         SELECT *
           INTO p_ft_item_885.*
           FROM ft_item_885
          WHERE cod_empresa = p_ft_item_885.cod_empresa 
          AND cod_item = p_ft_item_885.cod_item
           
                
         IF SQLCA.SQLCODE = 0 THEN  
            CALL pol0731_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Nao Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION


#-----------------------#
FUNCTION pol0731_popup()
#-----------------------#
    DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0721
         IF p_codigo IS NOT NULL THEN
            LET p_ft_item_885.cod_cliente = p_codigo CLIPPED
            DISPLAY p_codigo TO p_ft_item_885.cod_cliente
         END IF
   END CASE
         
         
   CASE

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0731
         IF p_codigo IS NOT NULL THEN
           LET p_ft_item_885.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF

   END CASE
END FUNCTION 

                  

#-------------------------------- FIM DE PROGRAMA -----------------------------#