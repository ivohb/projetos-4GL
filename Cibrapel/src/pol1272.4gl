#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1272                                                 #
# OBJETIVO: CADASTRO DE ITEM APARAS ALTERNATIVO                     #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 05/11/2014                                              #
# FUNÇÕES:                                                          #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
	DEFINE p_cod_empresa       LIKE empresa.cod_empresa,
          p_den_empresa        LIKE empresa.den_empresa,
          p_user               LIKE usuario.nom_usuario,
          p_excluiu            SMALLINT, 
          p_versao             CHAR(18),
          p_status             SMALLINT,
          p_nom_tela           CHAR(200),
          p_ies_cons           SMALLINT,
          p_retorno            SMALLINT,
          p_opcao              CHAR(1),
          p_ind                SMALLINT,
          s_ind                SMALLINT,
          p_msg                CHAR(500)
END GLOBALS

DEFINE p_apara_alternat        RECORD LIKE apara_alternat_885.*,
       p_apara_alternata       RECORD LIKE apara_alternat_885.*

DEFINE p_den_item              LIKE item.den_item


MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
 		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 5
	DEFER INTERRUPT
	LET p_versao = "pol1272-10.02.00 "
	OPTIONS 
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b

	CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
	#LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0
	
	IF p_status = 0 THEN
 		CALL pol1272_menu()
	END IF
   
END MAIN

#---------------------#
FUNCTION pol1272_menu()
#---------------------#

	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol1272") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED
	OPEN WINDOW w_pol1272 AT 2,1 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui dados na tabela."
			CALL pol1272_inclusao() RETURNING p_status
			IF p_status THEN
				ERROR 'Inclusão efetuada com sucesso !!!'
				LET p_ies_cons = FALSE
			ELSE
				ERROR 'Operação cancelada !!!'
			END IF
		COMMAND "Consultar" "Consulta dados da tabela."
			IF pol1272_consulta() THEN
				ERROR 'Consulta efetuada com sucesso !!!'
				NEXT OPTION "Seguinte"
			ELSE
				ERROR 'consulta cancelada!!!'
			END IF
		COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
			IF p_ies_cons THEN
				CALL pol1272_paginacao("S")
			ELSE
				ERROR "Não existe nenhuma consulta ativa !!!"
			END IF
		COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
			IF p_ies_cons THEN
				CALL pol1272_paginacao("A")
			ELSE
				ERROR "Não existe nenhuma consulta ativa !!!"
			END IF
		# COMMAND "Modificar" "Modifica dados da tabela."
		#	IF p_ies_cons THEN
		#		CALL pol1272_modificacao() RETURNING p_status
		#		IF p_status THEN
		#			ERROR 'Modificação efetuada com sucesso !!!'
		#		ELSE
		#			ERROR 'Operação cancelada !!!'
		#		END IF
		#	ELSE
		#		ERROR "Consulte previamente para fazer a modificacao !!!"
		#	END IF
		COMMAND "Excluir" "Exclui dados da tabela."
			IF p_ies_cons THEN
				CALL pol1272_exclusao() RETURNING p_status
				IF p_status THEN
					ERROR 'Exclusão efetuada com sucesso !!!'
				ELSE
					ERROR 'Operação cancelada !!!'
				END IF
			ELSE
				ERROR "Consulte previamente para fazer a exclusão !!!"
			END IF
		COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
			CALL pol1272_exibe_versao()
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
			DATABASE logix
		COMMAND "Fim"       "Retorna ao menu anterior."
			EXIT MENU
	END MENU
   
	CLOSE WINDOW w_pol1272

END FUNCTION

#---------------------------#
FUNCTION pol1272_limpa_tela()
#---------------------------#

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	
END FUNCTION

#-------------------------#
FUNCTION pol1272_inclusao()
#-------------------------#
	
	CALL pol1272_limpa_tela()
	
	INITIALIZE p_apara_alternat TO NULL
	LET p_apara_alternat.cod_empresa = p_cod_empresa
	
	LET INT_FLAG  = FALSE
	LET p_excluiu = FALSE
	
	IF pol1272_edita_dados("I") THEN
		CALL log085_transacao("BEGIN")
		IF pol1272_insere() THEN
			CALL log085_transacao("COMMIT")
			RETURN TRUE
		ELSE
			CALL log085_transacao("ROLLBACK")
		END IF
	END IF
	
	CALL pol1267_limpa_tela()
	RETURN FALSE
	
END FUNCTION

#-----------------------#
FUNCTION pol1272_insere()
#-----------------------#
	
	LET p_apara_alternat.cod_empresa = p_cod_empresa
	
	INSERT INTO apara_alternat_885 VALUES (p_apara_alternat.*)
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "Incluindo", "apara_alternat_885" )
		CALL pol1272_limpa_tela()
		RETURN FALSE
	END IF
	
	DISPLAY p_apara_alternat.cod_item TO cod_item
	
	RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1272_edita_dados()
#----------------------------#
	
	DEFINE p_funcao CHAR(01)
	LET INT_FLAG = FALSE
	
	INPUT BY NAME p_apara_alternat.*
		WITHOUT DEFAULTS
		
		AFTER FIELD cod_item
			
			IF p_apara_alternat.cod_item IS NULL THEN
				ERROR "Campo com preenchimento obrigatório !!!"
				NEXT FIELD cod_item 
			ELSE
				IF pol1272_verifica_duplicidade() THEN
					ERROR "Registro duplicado!!!"
					NEXT FIELD cod_item
				END IF
			END IF
			
			CALL pol1272_le_item( p_apara_alternat.cod_item )
			
			IF p_den_item IS NULL THEN
				ERROR "Item inexistente no Logix."
				NEXT FIELD cod_item
			END IF
			
			DISPLAY p_den_item TO den_item
			
			ON KEY (control-z)
				CALL pol1272_popup()
			
	END INPUT
	
	IF INT_FLAG THEN
		RETURN FALSE
	END IF
	
	RETURN TRUE
	
END FUNCTION

#--------------------------------#
FUNCTION pol1272_le_item(p_codigo)
#--------------------------------#
	
	DEFINE p_codigo CHAR(15)
	
	SELECT den_item
	  INTO p_den_item
	  FROM item
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_item    = p_codigo
	
	IF STATUS <> 0 THEN
		LET p_den_item = NULL
	END IF
	
END FUNCTION

#----------------------#
FUNCTION pol1272_popup()
#----------------------#
	
	DEFINE p_codigo CHAR(15)
	
	CASE
		WHEN INFIELD(cod_item)
			LET p_codigo = min071_popup_item(p_cod_empresa)
			CALL log006_exibe_teclas("01 02 03 07", p_versao)
			CURRENT WINDOW IS w_pol1272
			IF p_codigo IS NOT NULL THEN
				LET p_apara_alternat.cod_item = p_codigo
				DISPLAY p_codigo TO cod_item
			END IF
	END CASE
END FUNCTION

#-------------------------#
FUNCTION pol1272_consulta()
#-------------------------#
	
	DEFINE sql_stmt, 
	       where_clause CHAR(500)
	
	CALL pol1272_limpa_tela()
	LET p_apara_alternata.* = p_apara_alternat.*
	LET INT_FLAG = FALSE
	
	CONSTRUCT BY NAME where_clause ON
		p_apara_alternat.cod_item
		
		ON KEY (control-z)
			CALL pol1272_popup()
	
	END CONSTRUCT
	
	IF INT_FLAG THEN
		IF p_ies_cons THEN
			IF p_excluiu THEN
				CALL pol1272_limpa_tela()
			ELSE
				LET p_apara_alternat.* = p_apara_alternata.*
				CALL pol1272_exibe_dados() RETURNING p_status
			END IF
		END IF
		RETURN FALSE
	END IF
	
	LET p_excluiu = FALSE
	
	LET sql_stmt = " SELECT * ",
				   "   FROM apara_alternat_885 ",
				   "  WHERE ", where_clause CLIPPED, 
				   "  ORDER BY cod_item "
	
	PREPARE var_query FROM sql_stmt
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	
	OPEN cq_padrao
	
	FETCH cq_padrao INTO p_apara_alternat.*
	
	IF STATUS <> 0 THEN
		CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
		LET p_ies_cons = FALSE
		RETURN FALSE
	ELSE
		IF pol1272_exibe_dados() THEN
			LET p_ies_cons = TRUE
			RETURN TRUE
		END IF
	END IF
	
	RETURN FALSE
	
END FUNCTION

#----------------------------#
FUNCTION pol1272_exibe_dados()
#----------------------------#
	
	DEFINE p_item LIKE apara_alternat_885.cod_item
	
	LET p_item = p_apara_alternat.cod_item
	
	SELECT *
	  INTO p_apara_alternat.*
	  FROM apara_alternat_885
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_item    = p_item
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql("Lendo","apara_alternat_885")
		RETURN FALSE
	END IF
	
	DISPLAY BY NAME p_apara_alternat.*
	
	CALL pol1272_le_item(p_apara_alternat.cod_item)
	DISPLAY p_den_item TO den_item
	
	RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1272_modificacao()
#----------------------------#
	
	LET p_retorno = FALSE
	LET p_apara_alternata.* = p_apara_alternat.*
	
	IF p_excluiu THEN
		CALL log0030_mensagem("Não há dados a serem modificados !!!", "exclamation")
		RETURN p_retorno
	END IF
	
	LET p_opcao = "M"
	
	IF pol1272_prende_registro() THEN
		IF pol1272_edita_dados("M") THEN
			IF pol1272_atualiza() THEN
				LET p_retorno = TRUE
			END IF
		END IF
		CLOSE cq_prende
	END IF
	
	IF p_retorno THEN
		CALL log085_transacao("COMMIT")
	ELSE
		CALL log085_transacao("ROLLBACK")
		LET p_apara_alternat.* = p_apara_alternata.*
		
		CALL pol1272_exibe_dados() RETURNING p_status
	END IF
	
RETURN p_retorno

END FUNCTION

#--------------------------------#
FUNCTION pol1272_prende_registro()
#--------------------------------#
	
	CALL log085_transacao("BEGIN")
	
	DECLARE cq_prende CURSOR FOR
	 SELECT cod_item
	   FROM apara_alternat_885
	  WHERE cod_empresa = p_cod_empresa
	    AND cod_item    = p_apara_alternat.cod_item

	FOR UPDATE

	OPEN cq_prende
	FETCH cq_prende

	IF STATUS = 0 THEN
		RETURN TRUE
	ELSE
		CALL log003_err_sql("Lendo","rota_frete_455")
		RETURN FALSE
	END IF
	
END FUNCTION

#-------------------------#
FUNCTION pol1272_atualiza()
#-------------------------#
	
	UPDATE apara_alternat_885
	   SET apara_alternat_885.* = p_apara_alternat.*
	 WHERE cod_empresa = p_apara_alternata.cod_empresa
	   AND cod_item    = p_apara_alternata.cod_item
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "UPDATE", "apara_alternat_885" )
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

#-------------------------#
FUNCTION pol1272_exclusao()
#-------------------------#
	
	LET p_retorno = FALSE
	
	IF p_excluiu THEN
		CALL log0030_mensagem("Não há dados a serem excluídos !!!", "exclamation")
		RETURN p_return
	END IF

	LET p_msg = "Confirma a exclusão do registro?"
	IF NOT log0040_confirm(18,35,p_msg) THEN
		RETURN FALSE
	END IF
	
	IF pol1272_prende_registro() THEN
		IF pol1272_deleta() THEN
			INITIALIZE p_apara_alternat TO NULL
			LET p_apara_alternat.cod_empresa = p_cod_empresa
			CALL pol1272_limpa_tela()
			LET p_retorno = TRUE
			LET p_excluiu = TRUE
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
FUNCTION pol1272_deleta()
#-----------------------#
	
	DELETE FROM apara_alternat_885
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_item    = p_apara_alternat.cod_item
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "Excluindo", "apara_alternat_885" )
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

#-------------------------#
FUNCTION pol1272_sel_item()
#-------------------------#
	
	DEFINE pr_item        ARRAY[5000] OF RECORD
		   cod_item       CHAR(15),
		   den_item       CHAR(76)
	END RECORD
	
	DEFINE p_where, p_query CHAR(150)
	
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol1272a") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED
	OPEN WINDOW w_pol1272a AT 5,15 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
	
	LET INT_FLAG = FALSE
	LET p_ind = 1
	
	CONSTRUCT BY NAME p_where ON
		item.cod_item,
		item.den_item

	IF INT_FLAG THEN
		RETURN ""
	END IF
	
	LET p_query = " SELECT cod_item, den_item",
				  "   FROM item ",
				  "  WHERE cod_empresa = '",p_cod_empresa,"' ",
				  "    AND ", p_where CLIPPED,
				  "  ORDER BY cod_item"
	
	PREPARE sql_item FROM p_query
	DECLARE cq_item CURSOR FOR sql_item
	
	FOREACH cq_item INTO
		pr_item[p_ind].cod_item,
		pr_item[p_ind].den_item
		
		IF STATUS <> 0 THEN
			CALL log003_err_sql("Lendo", "cq_item" )
			RETURN ""
		END IF
		
		LET p_ind = p_ind + 1
		
		IF p_ind > 5000 THEN
			LET p_msg = "Limite de linhas na grade foi ultrapassado!"
			CALL log0030_mensagem( p_msg, "excla")
			EXIT FOREACH
		END IF
	END FOREACH
	
	IF p_ind = 1 THEN
		LET p_msg = "Nenhum registro foi encontrado para os parâmetros informados!"
		CALL log0030_mensagem( p_msg, "excla")
		RETURN ""
	END IF
	
	CALL SET_COUNT(p_ind - 1)
	
	DISPLAY ARRAY pr_item TO sr_item.*
	
	LET p_ind = ARR_CURR()
	LET s_ind = SCR_LINE()
	
	IF NOT INT_FLAG THEN
		RETURN pr_item[p_ind].cod_item
	ELSE
		RETURN ""
	END IF
	
END FUNCTION


#----------------------------------#
FUNCTION pol1272_paginacao(p_funcao)
#----------------------------------#
	
	DEFINE p_funcao   CHAR(01)
	
	LET p_apara_alternata.* = p_apara_alternat.*

	WHILE TRUE
		CASE
			WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_apara_alternat.*

			WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_apara_alternat.*
		END CASE
		
		IF STATUS = 0 THEN
			SELECT cod_item
			  FROM apara_alternat_885
			 WHERE cod_empresa = p_apara_alternat.cod_empresa
			   AND cod_item = p_apara_alternat.cod_item

			IF STATUS = 0 THEN
				IF pol1272_exibe_dados() THEN
					LET p_excluiu = FALSE
					EXIT WHILE
				END IF
			END IF
		ELSE
			IF STATUS = 100 THEN
				ERROR "Não existem mais itens nesta direção !!!"
				LET p_apara_alternat.* = p_apara_alternata.*
			ELSE
				CALL log003_err_sql('Lendo','cq_padrao')
			END IF
			EXIT WHILE
		END IF

	END WHILE

END FUNCTION

#-------------------------------------#
FUNCTION pol1272_exibe_versao()
#-------------------------------------#
	
	LET p_msg = p_versao CLIPPED, "\n","\n",
				"LOGIX 10.02 ","\n","\n",
				" Home page: www.aceex.com.br","\n","\n",
				" (0xx11) 4991-6667 ","\n","\n"
	
	CALL log0030_mensagem(p_msg,"excla")
	
END FUNCTION

#-------------------------------------#
FUNCTION pol1272_verifica_duplicidade()
#-------------------------------------#
	
	DEFINE p_item LIKE apara_alternat_885.cod_item
	
	LET p_item = p_apara_alternat.cod_item
	
	SELECT *
	  INTO p_apara_alternat.*
	  FROM apara_alternat_885
	 WHERE cod_empresa = p_cod_empresa
	   AND cod_item    = p_item
	
	IF STATUS = 100 THEN
		RETURN FALSE
	ELSE 
		IF STATUS = 0 THEN
			RETURN TRUE
		ELSE
			CALL log003_err_sql("Lendo","apara_alternat_885")
			RETURN TRUE
		END IF
	END IF
	
END FUNCTION