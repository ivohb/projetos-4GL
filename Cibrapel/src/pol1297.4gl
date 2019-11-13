#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1297                                                 #
# OBJETIVO: ROTAS PARA CONTROLE DE FRETE                            #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 18/08/2015                                              #
# FUNÇÕES:  FUNC002                                                 #
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

DEFINE p_rotas        RECORD 
       cod_rota       INTEGER,
       den_rota       CHAR(50)
END RECORD

DEFINE p_rotasa       RECORD 
       cod_rota       INTEGER,
       den_rota       CHAR(50)
END RECORD
                     

MAIN
	CALL log0180_conecta_usuario()
	WHENEVER ANY ERROR CONTINUE
 		SET ISOLATION TO DIRTY READ
		SET LOCK MODE TO WAIT 5
	DEFER INTERRUPT
	LET p_versao = "pol1297-10.02.01  "
  CALL func002_versao_prg(p_versao)
	
	OPTIONS 
		NEXT KEY control-f,
		INSERT KEY control-i,
		DELETE KEY control-e,
		PREVIOUS KEY control-b

	CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
	#LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0
	
	IF p_status = 0 THEN
 		CALL pol1297_menu()
	END IF
   
END MAIN

#---------------------#
FUNCTION pol1297_menu()
#---------------------#

	CALL log006_exibe_teclas("01",p_versao)
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol1297") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED
	OPEN WINDOW w_pol1297 AT 2,1 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
	
	DISPLAY p_cod_empresa TO cod_empresa
	
	MENU "OPCAO"
		COMMAND "Incluir" "Inclui dados na tabela."
			CALL pol1297_inclusao() RETURNING p_status
			IF p_status THEN
				ERROR 'Inclusão efetuada com sucesso !!!'
				LET p_ies_cons = FALSE
			ELSE
				ERROR 'Operação cancelada !!!'
			END IF
		COMMAND "Consultar" "Consulta dados da tabela."
			IF pol1297_consulta() THEN
				ERROR 'Consulta efetuada com sucesso !!!'
				NEXT OPTION "Seguinte"
			ELSE
				ERROR 'consulta cancelada!!!'
			END IF
		COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
			IF p_ies_cons THEN
				CALL pol1297_paginacao("S")
			ELSE
				ERROR "Não existe nenhuma consulta ativa !!!"
			END IF
		COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
			IF p_ies_cons THEN
				CALL pol1297_paginacao("A")
			ELSE
				ERROR "Não existe nenhuma consulta ativa !!!"
			END IF
		 COMMAND "Modificar" "Modifica dados da tabela."
			IF p_ies_cons THEN
				CALL pol1297_modificacao() RETURNING p_status
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
				CALL pol1297_exclusao() RETURNING p_status
				IF p_status THEN
					ERROR 'Exclusão efetuada com sucesso !!!'
				ELSE
					ERROR 'Operação cancelada !!!'
				END IF
			ELSE
				ERROR "Consulte previamente para fazer a exclusão !!!"
			END IF
		COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
      CALL func002_exibe_versao(p_versao)
		COMMAND KEY ("!")
			PROMPT "Digite o comando : " FOR comando
			RUN comando
			PROMPT "\Tecle ENTER para continuar" FOR CHAR comando
			DATABASE logix
		COMMAND "Fim"       "Retorna ao menu anterior."
			EXIT MENU
	END MENU
   
	CLOSE WINDOW w_pol1297

END FUNCTION

#---------------------------#
FUNCTION pol1297_limpa_tela()
#---------------------------#

	CLEAR FORM
	DISPLAY p_cod_empresa TO cod_empresa
	
END FUNCTION

#-------------------------#
FUNCTION pol1297_inclusao()
#-------------------------#
	
	CALL pol1297_limpa_tela()
	
	INITIALIZE p_rotas TO NULL
	
	LET INT_FLAG  = FALSE
	LET p_excluiu = FALSE
	
	IF pol1297_edita_dados() THEN
		CALL log085_transacao("BEGIN")
		IF pol1297_insere() THEN
			CALL log085_transacao("COMMIT")
			RETURN TRUE
		ELSE
			CALL log085_transacao("ROLLBACK")
		END IF
	END IF
	
	CALL pol1297_limpa_tela()
	RETURN FALSE
	
END FUNCTION

#-----------------------#
FUNCTION pol1297_insere()
#-----------------------#
		
	INSERT INTO rotas_885(den_rota) VALUES (p_rotas.den_rota)
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "Incluindo", "rotas_885" )
		CALL pol1297_limpa_tela()
		RETURN FALSE
	END IF
	
	SELECT cod_rota
	  INTO p_rotas.cod_rota
	  FROM rotas_885
	 WHERE cod_rota IN (SELECT MAX(cod_rota) FROM rotas_885)

  DISPLAY p_rotas.cod_rota TO cod_rota
		
	RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1297_edita_dados()
#----------------------------#
	
	LET INT_FLAG = FALSE
	
	INPUT BY NAME p_rotas.*
		WITHOUT DEFAULTS
		     
     AFTER INPUT
   	    
   	    IF INT_FLAG THEN
		       RETURN FALSE
	      END IF
     		
     		IF p_rotas.den_rota IS NULL THEN
     		   ERROR 'Campo com preenchimento obrigatório.'
     		   NEXT FIELD den_rota
     		END IF
     		
	END INPUT
		
	RETURN TRUE
	
END FUNCTION

#-------------------------#
FUNCTION pol1297_consulta()
#-------------------------#
	
	DEFINE sql_stmt, 
	       where_clause CHAR(500)
	
	CALL pol1297_limpa_tela()
	LET p_rotasa.* = p_rotas.*
	LET INT_FLAG = FALSE
	
	CONSTRUCT BY NAME where_clause ON
		p_rotas.cod_rota
			
	IF INT_FLAG THEN
		IF p_ies_cons THEN
			IF p_excluiu THEN
				CALL pol1297_limpa_tela()
			ELSE
				LET p_rotas.* = p_rotasa.*
				CALL pol1297_exibe_dados() RETURNING p_status
			END IF
		END IF
		RETURN FALSE
	END IF
	
	LET p_excluiu = FALSE
	
	LET sql_stmt = " SELECT * ",
				   "   FROM rotas_885 ",
				   "  WHERE ", where_clause CLIPPED, 
				   "  ORDER BY cod_rota "
	
	PREPARE var_query FROM sql_stmt
	DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
	
	OPEN cq_padrao
	
	FETCH cq_padrao INTO p_rotas.*
	
	IF STATUS <> 0 THEN
		CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","excla")
		LET p_ies_cons = FALSE
		RETURN FALSE
	ELSE
		IF pol1297_exibe_dados() THEN
			LET p_ies_cons = TRUE
			RETURN TRUE
		END IF
	END IF
	
	RETURN FALSE
	
END FUNCTION

#----------------------------#
FUNCTION pol1297_exibe_dados()
#----------------------------#
	
	DEFINE p_rota INTEGER
	
	LET p_rota = p_rotas.cod_rota
	
	SELECT *
	  INTO p_rotas.*
	  FROM rotas_885
	 WHERE cod_rota = p_rota
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql("Lendo","rotas_885")
		RETURN FALSE
	END IF
	
	DISPLAY BY NAME p_rotas.*
	
	RETURN TRUE
	
END FUNCTION

#----------------------------#
FUNCTION pol1297_modificacao()
#----------------------------#
	
	LET p_retorno = FALSE
	LET p_rotasa.* = p_rotas.*
	
	IF p_excluiu THEN
		CALL log0030_mensagem("Não há dados a serem modificados !!!", "exclamation")
		RETURN p_retorno
	END IF
	
	LET p_opcao = "M"
	
	IF pol1297_prende_registro() THEN
		IF pol1297_edita_dados() THEN
			IF pol1297_atualiza() THEN
				LET p_retorno = TRUE
			END IF
		END IF
		CLOSE cq_prende
	END IF
	
	IF p_retorno THEN
		CALL log085_transacao("COMMIT")
	ELSE
		CALL log085_transacao("ROLLBACK")
		LET p_rotas.* = p_rotasa.*
		
		CALL pol1297_exibe_dados() RETURNING p_status
	END IF
	
RETURN p_retorno

END FUNCTION

#--------------------------------#
FUNCTION pol1297_prende_registro()
#--------------------------------#
	
	CALL log085_transacao("BEGIN")
	
	DECLARE cq_prende CURSOR FOR
	 SELECT cod_rota
	   FROM rotas_885
	  WHERE cod_rota = p_rotas.cod_rota

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
FUNCTION pol1297_atualiza()
#-------------------------#
	
	UPDATE rotas_885
	   SET den_rota = p_rotas.den_rota
	 WHERE cod_rota = p_rotas.cod_rota
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "UPDATE", "rotas_885" )
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

#-------------------------#
FUNCTION pol1297_exclusao()
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
	
	IF pol1297_prende_registro() THEN
		IF pol1297_deleta() THEN
			INITIALIZE p_rotas TO NULL
			CALL pol1297_limpa_tela()
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
FUNCTION pol1297_deleta()
#-----------------------#
	
	DELETE FROM rotas_885
	 WHERE cod_rota = p_rotas.cod_rota
	
	IF STATUS <> 0 THEN
		CALL log003_err_sql( "Excluindo", "rotas_885" )
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

#-------------------------#
FUNCTION pol1297_sel_item()
#-------------------------#
	
	DEFINE pr_item        ARRAY[5000] OF RECORD
		   cod_rota       CHAR(15),
		   den_item       CHAR(76)
	END RECORD
	
	DEFINE p_where, p_query CHAR(150)
	
	INITIALIZE p_nom_tela TO NULL
	CALL log130_procura_caminho("pol1297a") RETURNING p_nom_tela
	LET p_nom_tela = p_nom_tela CLIPPED
	OPEN WINDOW w_pol1297a AT 5,15 WITH FORM p_nom_tela
		ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST, FORM LINE FIRST)
	
	LET INT_FLAG = FALSE
	LET p_ind = 1
	
	CONSTRUCT BY NAME p_where ON
		item.cod_rota,
		item.den_item

	IF INT_FLAG THEN
		RETURN ""
	END IF
	
	LET p_query = " SELECT cod_rota, den_item",
				  "   FROM item ",
				  "  WHERE cod_empresa = '",p_cod_empresa,"' ",
				  "    AND ", p_where CLIPPED,
				  "  ORDER BY cod_rota"
	
	PREPARE sql_item FROM p_query
	DECLARE cq_item CURSOR FOR sql_item
	
	FOREACH cq_item INTO
		pr_item[p_ind].cod_rota,
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
		RETURN pr_item[p_ind].cod_rota
	ELSE
		RETURN ""
	END IF
	
END FUNCTION


#----------------------------------#
FUNCTION pol1297_paginacao(p_funcao)
#----------------------------------#
	
	DEFINE p_funcao   CHAR(01)
	
	LET p_rotasa.* = p_rotas.*

	WHILE TRUE
		CASE
			WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_rotas.*

			WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_rotas.*
		END CASE
		
		IF STATUS = 0 THEN
			SELECT cod_rota
			  FROM rotas_885
			 WHERE cod_rota = p_rotas.cod_rota

			IF STATUS = 0 THEN
				IF pol1297_exibe_dados() THEN
					LET p_excluiu = FALSE
					EXIT WHILE
				END IF
			END IF
		ELSE
			IF STATUS = 100 THEN
				ERROR "Não existem mais itens nesta direção !!!"
				LET p_rotas.* = p_rotasa.*
			ELSE
				CALL log003_err_sql('Lendo','cq_padrao')
			END IF
			EXIT WHILE
		END IF

	END WHILE

END FUNCTION

