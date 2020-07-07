#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1044                                                 #
# OBJETIVO: CADASTRO DE ITENS (NOVOS PRODUTOS)                      #
# AUTOR...: WILLIANS MORAES BARBOSA                                 #
# DATA....: 21/06/10                                                #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
   DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_cod_emp_ger        LIKE empresa.cod_empresa,
          p_cod_emp_ofic       LIKE empresa.cod_empresa,
          p_den_item_reduz     LIKE item.den_item_reduz,
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
         
  
   DEFINE p_kana_novos_produtos_itens_retira RECORD
          cod_item                           CHAR(15),          
          idinpir                            INTEGER,
          data_inicio                        DATE,             
          data_termino                       DATE
   END RECORD 

   DEFINE p_cod_item        LIKE kana_novos_produtos_itens_retira.cod_item,
          p_cod_item_ant    LIKE kana_novos_produtos_itens_retira.cod_item
          
END GLOBALS

MAIN
   #CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 5
   DEFER INTERRUPT
   LET p_versao = "pol1044-10.02.01"
   OPTIONS 
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("VDP","LIC_LIB")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0 THEN
      CALL pol1044_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol1044_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL 
   CALL log130_procura_caminho("pol1044") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1044 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
   
   CALL pol1044_limpa_tela()
   
   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela"
         CALL pol1044_inclusao() RETURNING p_status
         IF p_status THEN
            LET p_ies_cons = FALSE
            ERROR 'Inclus�o efetuada com sucesso !!!'
         ELSE
            ERROR 'Opera��o cancelada !!!'
         END IF 
      COMMAND "Consultar" "Consulta dados da tabela"
          IF pol1044_consulta() THEN
            LET p_ies_cons = TRUE
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte" 
         ELSE
            ERROR 'consulta cancela !!!'
         END IF 
      COMMAND "Seguinte" "Exibe o pr�ximo item encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1044_paginacao("S")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Anterior" "Exibe o item anterior encontrado na consulta"
         IF p_ies_cons THEN
            CALL pol1044_paginacao("A")
         ELSE
            ERROR "N�o existe nenhuma consulta ativa !!!"
         END IF 
      COMMAND "Modificar" "Modifica dados da tabela"
         IF p_ies_cons THEN
            CALL pol1044_modificacao() RETURNING p_status  
            IF p_status THEN
               DISPLAY p_cod_item TO cod_item
               ERROR 'Modifica��o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a modificacao !!!"
         END IF
      COMMAND "Excluir" "Exclui dados da tabela"
         IF p_ies_cons THEN
            CALL pol1044_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclus�o efetuada com sucesso !!!'
            ELSE
               ERROR 'Opera��o cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclus�o !!!"
         END IF  
	  COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa"
              CALL pol1044_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
      COMMAND "Fim"       "Retorna ao menu anterior"
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol1044

END FUNCTION

#----------------------------#
 FUNCTION pol1044_limpa_tela()
#----------------------------#
   
   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa
   
END FUNCTION 
   
#--------------------------#
 FUNCTION pol1044_inclusao()
#--------------------------#
   
   IF pol1044_edita_dados("I") THEN
      CALL log085_transacao("BEGIN")
      INSERT INTO kana_novos_produtos_itens_retira VALUES (p_kana_novos_produtos_itens_retira.idinpir,
                                                           p_kana_novos_produtos_itens_retira.cod_item,
                                                           p_kana_novos_produtos_itens_retira.data_inicio,
                                                           p_kana_novos_produtos_itens_retira.data_termino)
      IF STATUS <> 0 THEN 
	       CALL log003_err_sql("incluindo","kana_novos_produtos_itens_retira")       
         CALL log085_transacao("ROLLBACK")
      ELSE
         CALL log085_transacao("COMMIT")
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1044_edita_dados(p_funcao)
#-------------------------------------#

   DEFINE p_funcao CHAR(01)
   
   LET INT_FLAG = FALSE 
   
   IF p_funcao = "I" THEN 
      CALL pol1044_limpa_tela()
      INITIALIZE p_kana_novos_produtos_itens_retira.* TO NULL
      IF NOT pol1044_busca_identificador() THEN
         RETURN FALSE
      END IF
   END IF 
   
   INPUT BY NAME p_kana_novos_produtos_itens_retira.* WITHOUT DEFAULTS
      
      BEFORE FIELD cod_item
      IF p_funcao = "M" THEN 
         DISPLAY p_cod_item TO cod_item
         NEXT FIELD data_inicio
      END IF 
      
      AFTER FIELD cod_item
      IF p_kana_novos_produtos_itens_retira.cod_item IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD cod_item   
      END IF
          
      SELECT den_item_reduz
        INTO p_den_item_reduz
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = p_kana_novos_produtos_itens_retira.cod_item
          
      IF STATUS = 100 THEN 
         ERROR 'Item n�o cadastrado na tabela item !!!'
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 0 THEN 
            CALL log003_err_sql('lendo','item')
            RETURN FALSE
         END IF 
      END IF  
      
      DISPLAY p_den_item_reduz TO den_item_reduz
      
      SELECT cod_item
        FROM kana_novos_produtos_itens_retira
       WHERE cod_item = p_kana_novos_produtos_itens_retira.cod_item
          
      IF STATUS = 0 THEN 
         ERROR 'Item j� cadastrado na tabela kana_novos_produtos_itens_retira !!!'
         NEXT FIELD cod_item
      ELSE
         IF STATUS <> 100 THEN 
            CALL log003_err_sql('lendo','kana_novos_produtos_itens_retira')
            RETURN FALSE
         END IF 
      END IF
      
      AFTER FIELD data_inicio
      IF p_kana_novos_produtos_itens_retira.data_inicio IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD data_inicio   
      END IF
      
      AFTER FIELD data_termino
      IF p_kana_novos_produtos_itens_retira.data_termino IS NULL THEN 
         ERROR "Campo com preenchimento obrigat�rio !!!"
         NEXT FIELD data_termino   
      END IF
      
      IF p_kana_novos_produtos_itens_retira.data_termino < TODAY THEN 
         ERROR "A data final n�o pode ser inferior a data atual !!!"
         NEXT FIELD data_termino
      ELSE
         IF p_kana_novos_produtos_itens_retira.data_inicio > p_kana_novos_produtos_itens_retira.data_termino THEN 
            ERROR "A data inicial n�o pode ser superior a data final !!!"
            NEXT FIELD data_inicio
         END IF  
      END IF
      
      ON KEY (control-z)
         CALL pol1044_popup()
      
   END INPUT 

   IF INT_FLAG  THEN
      CALL pol1044_limpa_tela()
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#-------------------------------------#
 FUNCTION pol1044_busca_identificador()
#-------------------------------------#

   SELECT MAX (idinpir)
     INTO p_kana_novos_produtos_itens_retira.idinpir
     FROM kana_novos_produtos_itens_retira
    
   IF STATUS <> 0 THEN 
      CALL log003_err_sql("Lendo", "kana_novos_produtos_itens_retira")
      RETURN FALSE
   END IF 
   
   IF p_kana_novos_produtos_itens_retira.idinpir IS NULL THEN 
      LET p_kana_novos_produtos_itens_retira.idinpir = 1
   ELSE
      LET p_kana_novos_produtos_itens_retira.idinpir = p_kana_novos_produtos_itens_retira.idinpir + 1
   END IF 
   
   RETURN TRUE
   
END FUNCTION 


#-----------------------#
 FUNCTION pol1044_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
     WHEN INFIELD(cod_item)
         LET p_codigo = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol1044
         IF p_codigo IS NOT NULL THEN
           LET p_kana_novos_produtos_itens_retira.cod_item = p_codigo
           DISPLAY p_codigo TO cod_item
         END IF
   END CASE 
   
END FUNCTION 
  
#--------------------------#
 FUNCTION pol1044_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(500)  

   CALL pol1044_limpa_tela()
      
   LET p_cod_item_ant = p_cod_item
   LET INT_FLAG       = FALSE
   
   CONSTRUCT BY NAME where_clause ON 
      kana_novos_produtos_itens_retira.cod_item,
      kana_novos_produtos_itens_retira.idinpir,
      kana_novos_produtos_itens_retira.data_inicio,
      kana_novos_produtos_itens_retira.data_termino
      
   IF INT_FLAG THEN
      IF p_ies_cons THEN 
         LET p_cod_item = p_cod_item_ant
         CALL pol1044_exibe_dados() RETURNING p_status
      END IF    
      RETURN FALSE 
   END IF

   LET sql_stmt = "SELECT cod_item",
                  "  FROM kana_novos_produtos_itens_retira ",
                  " WHERE ", where_clause CLIPPED,
                  " ORDER BY cod_item"

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_cod_item

   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa n�o encontrados !!!","excla")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE 
      IF pol1044_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF
   
   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1044_exibe_dados()
#------------------------------#

   SELECT idinpir,
          data_inicio,
          data_termino
     INTO p_kana_novos_produtos_itens_retira.idinpir,
          p_kana_novos_produtos_itens_retira.data_inicio,
          p_kana_novos_produtos_itens_retira.data_termino
     FROM kana_novos_produtos_itens_retira
    WHERE cod_item = p_cod_item 
   
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'kana_novos_produtos_itens_retira')
      RETURN FALSE 
   END IF
   
   SELECT den_item_reduz
     INTO p_den_item_reduz
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = p_cod_item
      
   IF STATUS <> 0 THEN 
      CALL log003_err_sql('lendo', 'item')
      RETURN FALSE 
   END IF
   
   LET p_kana_novos_produtos_itens_retira.cod_item = p_cod_item
   
   DISPLAY BY NAME p_kana_novos_produtos_itens_retira.*
   DISPLAY p_den_item_reduz TO den_item_reduz
   
   RETURN TRUE
   
END FUNCTION

#-----------------------------------#
 FUNCTION pol1044_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(01)

   LET p_cod_item_ant = p_cod_item

   WHILE TRUE
      CASE
         WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_cod_item
                                                       
         WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_cod_item
         
      END CASE

      IF STATUS = 0 THEN
         SELECT cod_item
           FROM kana_novos_produtos_itens_retira
          WHERE cod_item = p_cod_item
             
         IF STATUS = 0 THEN
            CALL pol1044_exibe_dados() RETURNING p_status
            EXIT WHILE
         END IF
      ELSE
         IF STATUS = 100 THEN
            ERROR "N�o existem mais itens nesta dire��o !!!"
            LET p_cod_item = p_cod_item_ant
         ELSE
            CALL log003_err_sql('Lendo','cq_padrao')
         END IF
         EXIT WHILE
      END IF    

   END WHILE

END FUNCTION

#----------------------------------#
 FUNCTION pol1044_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_item 
      FROM kana_novos_produtos_itens_retira  
     WHERE cod_item = p_cod_item
           FOR UPDATE 
    
    OPEN cq_prende
   FETCH cq_prende
      
   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","kana_novos_produtos_itens_retira")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1044_modificacao()
#-----------------------------#
   
   LET p_retorno = FALSE

   IF pol1044_prende_registro() THEN
      IF pol1044_edita_dados("M") THEN
         
         UPDATE kana_novos_produtos_itens_retira
            SET idinpir       = p_kana_novos_produtos_itens_retira.idinpir,
                data_inicio  = p_kana_novos_produtos_itens_retira.data_inicio,
                data_termino = p_kana_novos_produtos_itens_retira.data_termino
          WHERE cod_item     = p_cod_item
             
         IF STATUS = 0 THEN
            LET p_retorno = TRUE
         ELSE
            CALL log003_err_sql("Modificando","kana_novos_produtos_itens_retira")
         END IF
      ELSE
         CALL pol1044_exibe_dados() RETURNING p_status
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
 FUNCTION pol1044_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN      
      RETURN FALSE
   END IF
   
   LET p_retorno = FALSE   

   IF pol1044_prende_registro() THEN
      
      DELETE FROM kana_novos_produtos_itens_retira
			 WHERE cod_item = p_cod_item
    		
      IF STATUS = 0 THEN               
         INITIALIZE p_kana_novos_produtos_itens_retira TO NULL
         CALL pol1044_limpa_tela()
         LET p_retorno = TRUE                       
      ELSE
         CALL log003_err_sql("Excluindo","kana_novos_produtos_itens_retira")
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
#-----------------------#
 FUNCTION pol1044_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
#-------------------------------- FIM DE PROGRAMA -----------------------------#