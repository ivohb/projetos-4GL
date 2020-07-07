#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1088                                                 #
# OBJETIVO: MANUTENÇÃO DA TABELA PEDIDO_VOLVO_512                   #
# AUTOR...: PAULO CESAR MARTINEZ                                    #
# DATA....: 10/03/2011                                              #
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
          p_msg                CHAR(500),
          p_last_row           SMALLINT,
          p_opcao              CHAR(01),
          p_den_item_reduz     CHAR(34),
          p_cod_item           CHAR(15),
          p_nom_cliente        CHAR(36),
          p_cod_cliente        CHAR(15),
          p_where              CHAR(50),
          pr_index             SMALLINT,
          sr_index             SMALLINT,
          p_excluiu            SMALLINT
         
  
   DEFINE p_pedido_volvo_512   RECORD LIKE pedido_volvo_512.*

   DEFINE p_num_pedido         LIKE pedido_volvo_512.num_pedido,
          p_num_pedido_ant     LIKE pedido_volvo_512.num_pedido
          
   DEFINE p_relat              RECORD LIKE pedido_volvo_512.*      
          
END GLOBALS

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1088-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1088_menu()
   END IF
END MAIN

#----------------------#
 FUNCTION pol1088_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1088") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1088 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1088_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1088_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1088_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1088_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1088_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_num_pedido TO num_pedido
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1088_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1088_listagem()
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
	    	CALL pol1088_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1088

END FUNCTION

#--------------------------#
 FUNCTION pol1088_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_cliente TO NULL
   INITIALIZE p_pedido_volvo_512.* TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE
   LET p_pedido_volvo_512.cod_empresa = p_cod_empresa
   
   IF pol1088_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO pedido_volvo_512 VALUES (p_pedido_volvo_512.*)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","pedido_volvo_512")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1088_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
   
   INPUT p_cod_cliente,
         p_pedido_volvo_512.num_pedido,   
         p_pedido_volvo_512.num_pedido_cli,   
         p_pedido_volvo_512.cod_item   
      WITHOUT DEFAULTS
         FROM cod_cliente,
              num_pedido,   
              num_pedido_cli,
              cod_item
                       
      BEFORE FIELD cod_cliente
      IF p_funcao = "M" THEN
         NEXT FIELD num_pedido
      END IF
      
      AFTER FIELD cod_cliente
      IF p_cod_cliente IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_cliente   
      END IF
          
      BEFORE FIELD num_pedido
      IF p_funcao = "M" THEN
         NEXT FIELD cod_item
      END IF
      
      AFTER FIELD num_pedido
      IF p_pedido_volvo_512.num_pedido IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD num_pedido   
      END IF
          
      SELECT num_pedido_cli
        INTO p_pedido_volvo_512.num_pedido_cli
        FROM pedidos
       WHERE cod_empresa = p_cod_empresa
       AND num_pedido = p_pedido_volvo_512.num_pedido
         
      IF STATUS = 100 THEN 
         ERROR 'Pedido não cadastrado na tabela Pedidos!!!'
         NEXT FIELD num_pedido
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','pedidos')
            RETURN FALSE
         END IF 
      END IF  
     
      

      AFTER FIELD cod_item
      IF p_pedido_volvo_512.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigatório !!!"
         NEXT FIELD cod_item   
      END IF
      
      
      ON KEY (control-z)
         CALL pol1088_popup()
           
      SELECT num_pedido
        FROM pedido_volvo_512
       WHERE num_pedido = p_pedido_volvo_512.num_pedido
         AND cod_item   = p_pedido_volvo_512.cod_item   
      
      IF STATUS = 0 THEN
         ERROR "número de pedido já cadastrado para este item!!!"
         NEXT FIELD num_pedido
      ELSE 
         IF STATUS <> 100 THEN   
            CALL log003_err_sql('lendo','pedidos')
            RETURN FALSE
         END IF 
      END IF    

   END INPUT 

   IF INT_FLAG THEN
      CLEAR FORM
      DISPLAY p_cod_empresa TO cod_empresa
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
  FUNCTION pol1088_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_cliente)
         CALL log009_popup(8,10,"CLIENTE","clientes",
              "cod_cliente","nom_cliente","","S","") 
              RETURNING p_cod_cliente
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_cod_cliente IS NOT NULL THEN
            DISPLAY p_cod_cliente TO cod_cliente
            SELECT nom_cliente 
            INTO p_nom_cliente
            FROM clientes
            WHERE cod_cliente = p_cod_cliente
            DISPLAY p_nom_cliente TO nom_cliente
         END IF
   END CASE 

   CASE
      WHEN INFIELD(num_pedido)
         LET p_where = "cod_cliente = ",p_cod_cliente CLIPPED
         
         CALL log009_popup(8,10,"PEDIDOS","pedidos",
              "num_pedido","num_pedido_cli","","S",p_where) 
              RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 07", p_versao)
                   
         IF p_codigo IS NOT NULL THEN
            LET p_pedido_volvo_512.num_pedido = p_codigo CLIPPED
            DISPLAY p_codigo TO num_pedido
         END IF
   END CASE 

   CASE WHEN INFIELD (cod_item)
   		LET p_cod_item = pol1088_carrega_item() 
   		IF p_cod_item IS NOT NULL THEN
      	LET p_pedido_volvo_512.cod_item = p_cod_item CLIPPED
#        CURRENT WINDOW IS w_pol1088
        DISPLAY p_pedido_volvo_512.cod_item TO cod_item
      END IF
   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1088_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_num_pedido_ant = p_num_pedido
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      pedido_volvo_512.num_pedido,
      pedido_volvo_512.num_pedido_cli,
      pedido_volvo_512.cod_item
      
      ON KEY (control-z)
         CALL pol1088_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_num_pedido = p_num_pedido_ant
            CALL pol1088_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT num_pedido, num_pedido_cli, cod_item ",
                  "  FROM pedido_volvo_512 ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY num_pedido"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_num_pedido

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1088_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1088_exibe_dados()
#------------------------------#
   
   SELECT num_pedido,
          num_pedido_cli, 
          cod_item
     INTO p_pedido_volvo_512.num_pedido,
          p_pedido_volvo_512.num_pedido_cli,
          p_pedido_volvo_512.cod_item
     FROM pedido_volvo_512
    WHERE num_pedido = p_num_pedido
    AND cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "pedido_volvo_512")
      RETURN FALSE
   END IF
   
   
   DISPLAY p_num_pedido                        TO num_pedido
   DISPLAY p_pedido_volvo_512.num_pedido_cli   TO num_pedido_cli 
   DISPLAY p_pedido_volvo_512.cod_item         TO cod_item 

   SELECT den_item
     INTO p_den_item_reduz
     FROM item
    WHERE cod_item = p_pedido_volvo_512.cod_item
      AND cod_empresa = p_cod_empresa
   DISPLAY p_den_item_reduz                   TO den_item_reduz   

   SELECT c.cod_cliente,c.nom_cliente 
   INTO p_cod_cliente,p_nom_cliente
   FROM pedidos p, clientes c
   WHERE p.cod_empresa = p_cod_empresa
   AND num_pedido = p_num_pedido
   AND c.cod_cliente = p.cod_cliente   
   DISPLAY p_cod_cliente                      TO cod_cliente   
   DISPLAY p_nom_cliente                      TO nom_cliente   
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1088_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_num_pedido_ant = p_num_pedido
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_num_pedido
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_num_pedido
      
      END CASE

      IF STATUS = 0 THEN
         SELECT num_pedido
           FROM pedido_volvo_512
          WHERE num_pedido = p_num_pedido
          AND cod_empresa = p_cod_empresa
            
         IF STATUS = 0 THEN
            CALL pol1088_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_num_pedido = p_num_pedido_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1088_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT num_pedido 
      FROM pedido_volvo_512  
     WHERE num_pedido = p_num_pedido
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","pedido_volvo_512")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1088_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   LET p_pedido_volvo_512.num_pedido = p_num_pedido 
   
   IF pol1088_prende_registro() THEN
      IF pol1088_edita_dados("M") THEN
         
         UPDATE pedido_volvo_512
            SET num_pedido_cli = p_pedido_volvo_512.num_pedido_cli,
                cod_item       = p_pedido_volvo_512.cod_item
          WHERE num_pedido     = p_num_pedido
          AND cod_empresa      = p_cod_empresa
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "pedido_volvo_512")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1088_exibe_dados() RETURNING p_status
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

#--------------------------#
 FUNCTION pol1088_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1088_prende_registro() THEN
      DELETE FROM pedido_volvo_512
			WHERE num_pedido = p_num_pedido
			AND cod_empresa  = p_cod_empresa

      IF STATUS = 0 THEN               
         INITIALIZE p_pedido_volvo_512 TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","pedido_volvo_512")
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

#--------------------------#
 FUNCTION pol1088_listagem()
#--------------------------#     
   
   LET p_excluiu = FALSE
   
   IF NOT pol1088_escolhe_saida() THEN
   		RETURN 
   END IF
      
   IF NOT pol1088_le_den_empresa() THEN
      RETURN
   END IF   

   LET p_comprime    = ascii 15
   LET p_descomprime = ascii 18
   LET p_6lpp        = ascii 27, "2" 
   LET p_8lpp        = ascii 27, "0" 
   
   LET p_count = 0

   DECLARE cq_impressao CURSOR FOR
    
   SELECT num_pedido,
          num_pedido_cli,
          cod_item
     FROM pedido_volvo_512
 ORDER BY num_pedido                          
  
   FOREACH cq_impressao 
      INTO p_relat.*
                      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'CURSOR: cq_impressao')
         RETURN
      END IF 
   
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_item = p_relat.cod_item
      
      IF STATUS <> 0 THEN
         CALL log003_err_sql('lendo', 'item')
         RETURN
      END IF 
   
   OUTPUT TO REPORT pol1088_relat() 

      LET p_count = 1
      
   END FOREACH

   FINISH REPORT pol1088_relat   
   
   IF p_count = 0 THEN
      ERROR "Não existem dados há serem listados !!!"
   ELSE
      IF p_ies_impressao = "S" THEN
         LET p_msg = "Relatório impresso na impressora ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
         IF g_ies_ambiente = "W" THEN
            LET comando = "lpdos.bat ", p_caminho CLIPPED, " ", p_nom_arquivo
            RUN comando
         END IF
      ELSE
         LET p_msg = "Relatório gravado no arquivo ", p_nom_arquivo
         CALL log0030_mensagem(p_msg, 'excla')
      END IF
      ERROR 'Relatório gerado com sucesso !!!'
   END IF

   RETURN
     
END FUNCTION 

#-------------------------------#
 FUNCTION pol1088_escolhe_saida()
#-------------------------------#

   IF log028_saida_relat(16,32) IS NULL THEN
      RETURN FALSE
   END IF
   
   IF g_ies_ambiente = "W" THEN
      IF p_ies_impressao = "S" THEN
         CALL log150_procura_caminho("LST") RETURNING p_caminho
         LET p_caminho = p_caminho CLIPPED, "pol1088.tmp"
         START REPORT pol1088_relat TO p_caminho
      ELSE
         START REPORT pol1088_relat TO p_nom_arquivo
      END IF
   END IF
   
   RETURN TRUE
   
END FUNCTION   

#--------------------------------#
 FUNCTION pol1088_le_den_empresa()
#--------------------------------#

   SELECT den_empresa
     INTO p_den_empresa
     FROM empresa
    WHERE cod_empresa = p_cod_empresa
   
   IF STATUS <> 0 THEN
      CALL log003_err_sql('Lendo','empresa')
      RETURN FALSE
   END IF

   RETURN TRUE
   
END FUNCTION

#---------------------#
 REPORT pol1088_relat()
#---------------------#

   OUTPUT LEFT   MARGIN 0
          TOP    MARGIN 0
          BOTTOM MARGIN 0
          PAGE   LENGTH 63
          
   FORMAT
          
      PAGE HEADER  
         
         PRINT COLUMN 002,  p_comprime, p_den_empresa, 
               COLUMN 135, "PAG. ", PAGENO USING "####&"
               
         PRINT COLUMN 002, "pol1088",
               COLUMN 042, "PEDIDOS VOLVO",
               COLUMN 114, "EMISSAO: ", TODAY USING "dd/mm/yyyy", " - ", TIME
         
         PRINT COLUMN 002, "---------------------------------------------------------------------"
         PRINT
         PRINT COLUMN 002, 'Pedido Pedido Cliente      Item                Descrição              '
         PRINT COLUMN 002, '------ -------------- ---------------- ------------------------------ '
                            
      ON EVERY ROW

         PRINT COLUMN 003, p_relat.num_pedido   USING "#####",
               COLUMN 010, p_relat.num_pedido_cli,
               COLUMN 025, p_relat.cod_item,
               COLUMN 042, p_den_item_reduz
                              
      ON LAST ROW

        LET p_last_row = TRUE

      PAGE TRAILER

        IF p_last_row = TRUE THEN 
           PRINT COLUMN 055, "* * * ULTIMA FOLHA * * *"
        ELSE 
           PRINT " "
        END IF
        
END REPORT

#-------------------------------#   
 FUNCTION pol1088_carrega_item() 
#-------------------------------#
 
    DEFINE pr_item       ARRAY[3000]
     OF RECORD
         cod_item          LIKE item.cod_item,
         den_item          LIKE item.den_item
     END RECORD

   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol10881") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol10881 AT 5,4 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
   
   DECLARE cq_item CURSOR FOR 
   SELECT i.cod_item,i.den_item
   FROM   ped_itens p, item i
   WHERE  p.num_pedido = p_pedido_volvo_512.num_pedido
   AND i.cod_empresa   = p_cod_empresa
   AND p.cod_empresa   = i.cod_empresa
   AND p.cod_item      = i.cod_item
   ORDER BY i.den_item

   LET pr_index = 1

   FOREACH cq_item INTO pr_item[pr_index].cod_item,
                        pr_item[pr_index].den_item
                         
      LET pr_index = pr_index + 1
       IF pr_index > 3000 THEN
         ERROR "Limit e de Linhas Ultrapassado !!!"
         EXIT FOREACH
      END IF
      
   END FOREACH
   
   CALL SET_COUNT(pr_index - 1)

   DISPLAY ARRAY pr_item TO sr_item.*

   LET pr_index = ARR_CURR()
   LET sr_index = SCR_LINE() 
      
  CLOSE WINDOW w_pol10881

   RETURN pr_item[pr_index].cod_item
      
END FUNCTION 


#-----------------------#
 FUNCTION pol1088_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION


#-------------------------------- FIM DE PROGRAMA -----------------------------#