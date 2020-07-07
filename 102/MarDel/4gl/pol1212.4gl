#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1212                                                 #
# OBJETIVO: ITENS P/ ENVIO DE NOTAS                                 #
# AUTOR...: ACEEX - BL                                              #
# DATA....: 15/07/2013                                              #
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
          p_ind                SMALLINT,
          s_ind                SMALLINT,
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
          p_erro               CHAR(10)

END GLOBALS

DEFINE p_cod_item              CHAR(15),
       p_cod_ant               CHAR(15),
       p_descricao             CHAR(80),
       p_excluiu               SMALLINT,
       p_tip_item              CHAR(01)

DEFINE p_cod_cliente           CHAR(15),
       p_cod_cli_ant           CHAR(15),
       p_nom_cliente           CHAR(80),
       p_id_registro           INTEGER

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1212-10.02.00"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
      
   IF p_status = 0 THEN
      CALL pol1212_menu()
   END IF
   
END MAIN

#-----------------------#
 FUNCTION pol1212_menu()#
#-----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1212") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1212 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
   DISPLAY p_cod_empresa TO cod_empresa

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1212_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         ELSE
            ERROR 'Operação cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1212_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1212_paginacao("S")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
         IF p_ies_cons THEN
            CALL pol1212_paginacao("A")
         ELSE
            ERROR "Não existe nenhuma consulta ativa !!!"
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1212_modificacao() RETURNING p_status  
            IF p_status THEN
               ERROR 'Modificação efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela."
         IF p_ies_cons THEN
            CALL pol1212_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF   
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
				CALL pol1212_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior."
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1212   

END FUNCTION

#------------------------#
 FUNCTION pol1212_sobre()#
#------------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               " ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     LOGIX 10.02\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------#
FUNCTION pol1212_limpa_tela()#
#----------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION


#--------------------------#
 FUNCTION pol1212_inclusao()
#--------------------------#

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   INITIALIZE p_cod_item, p_cod_cliente, p_tip_item TO NULL
   LET INT_FLAG  = FALSE
   LET p_excluiu = FALSE

   IF pol1212_edita_dados("I") THEN
      
      CALL log085_transacao("BEGIN")
      
      INSERT INTO item_cliente_5054 (
         cod_empresa,
         cod_cliente,
         cod_item,   
         tip_item)   
       VALUES (
         p_cod_empresa, 
         p_cod_cliente, 
         p_cod_item, 
         p_tip_item)
      
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","item_cliente_5054")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1212_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   LET INT_FLAG = FALSE
      
   INPUT p_cod_cliente, p_cod_item, p_tip_item
      WITHOUT DEFAULTS
         FROM cod_cliente, cod_item, tip_item

      BEFORE FIELD cod_cliente
         IF p_funcao = 'M' THEN
            NEXT FIELD cod_item
         END IF
      
      AFTER FIELD cod_cliente
      
         IF p_cod_cliente IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_cliente   
         END IF
          
         SELECT nom_cliente
           INTO p_nom_cliente
           FROM clientes
          WHERE cod_cliente = p_cod_cliente

         IF STATUS = 100 THEN 
            ERROR 'Cliente inexistente!'
            NEXT FIELD cod_cliente
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','clientes')
               RETURN FALSE
            END IF 
         END IF  

         DISPLAY p_nom_cliente TO nom_cliente
                            
      AFTER FIELD cod_item
      
         IF p_cod_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD cod_item   
         END IF
          
         SELECT den_item,
                ies_tip_item
           INTO p_descricao,
                p_tip_item
           FROM item
          WHERE cod_item = p_cod_item
            AND cod_empresa = p_cod_empresa
         
         IF STATUS = 100 THEN 
            ERROR 'Item inexistente!'
            NEXT FIELD cod_item
         ELSE
            IF STATUS <> 0 THEN 
               CALL log003_err_sql('lendo','item')
               RETURN FALSE
            END IF 
         END IF  
          
         IF p_tip_item MATCHES '[CBPF]' THEN
         ELSE
            ERROR 'O tipo desse item não é válido'
            NEXT FIELD cod_item
         END IF
      
         IF p_funcao = 'I' THEN   
         SELECT cod_item
           FROM item_cliente_5054
          WHERE cod_item = p_cod_item
            AND cod_cliente = p_cod_cliente
            AND cod_empresa = p_cod_empresa
         ELSE
         SELECT cod_item
           FROM item_cliente_5054
          WHERE cod_item = p_cod_item
            AND cod_cliente = p_cod_cliente
            AND cod_empresa = p_cod_empresa
            AND id_registro <> p_id_registro
         END IF
         
         IF STATUS = 0 THEN
            ERROR "Cliente/item já cadastrados p/ envio de saldos"
            NEXT FIELD cod_item
         ELSE 
            IF STATUS <> 100 THEN   
               CALL log003_err_sql('lendo','item_cliente_5054')
               RETURN FALSE
            END IF 
         END IF    
      
         DISPLAY p_descricao TO descricao
         DISPLAY p_tip_item TO tip_item
      
      {AFTER FIELD tip_item

         IF p_tip_item IS NULL THEN 
            ERROR "Campo com preenchimento obrigatório !!!"
            NEXT FIELD tip_item   
         END IF

         IF p_tip_item MATCHES '[MP]' THEN 
         ELSE
            ERROR "Informe M ou P, para o tipo "
            NEXT FIELD tip_item   
         END IF}
         
      ON KEY (control-z)
         CALL pol1212_popup()
           
   END INPUT 

   IF INT_FLAG THEN
      CALL pol1212_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-----------------------#
 FUNCTION pol1212_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE

      WHEN INFIELD(cod_cliente)
         LET p_codigo = vdp372_popup_cliente()
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1211
         IF p_codigo IS NOT NULL THEN
            LET p_cod_cliente = p_codigo
            DISPLAY p_cod_cliente TO cod_cliente
         END IF

      WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1212
         IF p_codigo IS NOT NULL THEN
            LET p_cod_item = p_codigo
            DISPLAY p_cod_item TO cod_item
         END IF

   END CASE 

END FUNCTION 

#--------------------------#
 FUNCTION pol1212_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   LET p_cod_ant = p_cod_item
   LET p_cod_cli_ant = p_cod_cliente
   
   LET INT_FLAG = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      item_cliente_5054.cod_cliente,
      item_cliente_5054.cod_item,
      item_cliente_5054.tip_item
      
      ON KEY (control-z)
         CALL pol1212_popup()
         
   END CONSTRUCT   
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         IF p_excluiu THEN
            CLEAR FORM
            DISPLAY p_cod_empresa TO cod_empresa
         ELSE
            LET p_cod_item = p_cod_ant
            LET p_cod_cliente = p_cod_cli_ant
            CALL pol1212_exibe_dados() RETURNING p_status
         END IF
      END IF    
      RETURN FALSE 
   END IF
   
   LET p_excluiu = FALSE
   
   LET sql_stmt = "SELECT id_registro, cod_item, cod_cliente, tip_item ",
                  "  FROM item_cliente_5054 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' ",
                  " ORDER BY cod_item, cod_cliente"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_id_registro, p_cod_item, p_cod_cliente, p_tip_item

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1212_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1212_exibe_dados()
#------------------------------#
   
   SELECT den_item
     INTO p_descricao
     FROM item
    WHERE cod_item = p_cod_item
      AND cod_empresa = p_cod_empresa
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "item")
      RETURN FALSE
   END IF

   SELECT nom_cliente
     INTO p_nom_cliente
     FROM clientes
    WHERE cod_cliente = p_cod_cliente
    
   IF STATUS <> 0 THEN
      CALL log003_err_sql("lendo", "clientes")
      RETURN FALSE
   END IF
   
   DISPLAY p_cod_item        TO cod_item
   DISPLAY p_descricao       TO descricao
   DISPLAY p_tip_item        TO tip_item

   DISPLAY p_cod_cli_ant     TO cod_cliente
   DISPLAY p_nom_cliente     TO nom_cliente
      
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1212_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_ant = p_cod_item
   LET p_cod_cli_ant = p_cod_cliente
   
   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao 
           INTO p_id_registro, p_cod_item, p_cod_cliente, p_tip_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao 
           INTO p_id_registro, p_cod_item, p_cod_cliente, p_tip_item
      
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item
           FROM item_cliente_5054
          WHERE id_registro = p_id_registro
            
         IF STATUS = 0 THEN
            CALL pol1212_exibe_dados() RETURNING p_status
            LET p_excluiu = FALSE
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "Não existem mais itens nesta direção !!!"
            LET p_cod_item = p_cod_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE
   
END FUNCTION

#----------------------------------#
 FUNCTION pol1212_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_item 
      FROM item_cliente_5054  
     WHERE id_registro = p_id_registro
       FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","item_cliente_5054")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1212_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem modificados !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   LET INT_FLAG  = FALSE
   LET p_opcao   = "M"
   
   IF pol1212_prende_registro() THEN
      IF pol1212_edita_dados("M") THEN
         
         UPDATE item_cliente_5054
            SET cod_item = p_cod_item,
                tip_item = p_tip_item
          WHERE id_registro = p_id_registro
       
         IF STATUS <> 0 THEN
            CALL log003_err_sql("Modificando", "item_cliente_5054")
         ELSE
            LET p_retorno = TRUE
         END IF
      
      ELSE
         CALL pol1212_exibe_dados() RETURNING p_status
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
 FUNCTION pol1212_exclusao()
#--------------------------#
   
   LET p_retorno = FALSE
   
   IF p_excluiu THEN
      CALL log0030_mensagem("Não há dados á serem excluídos !!!", "exclamation")
      RETURN p_retorno
   END IF
   
   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF   

   IF pol1212_prende_registro() THEN
      DELETE FROM item_cliente_5054
			 WHERE id_registro = p_id_registro

      IF STATUS = 0 THEN               
         INITIALIZE p_cod_item TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_excluiu = TRUE                     
      ELSE
         CALL log003_err_sql("Excluindo","item_cliente_5054")
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
