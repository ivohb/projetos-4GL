#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1288                                                 #
# OBJETIVO: Tabelas de preço de Transportadores                     #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 22/07/2015                                              #
# FUNÇÕES:                                                          #
#-------------------------------------------------------------------#

DATABASE logix

GLOBALS
DEFINE p_cod_empresa        LIKE empresa.cod_empresa,
       p_den_empresa        LIKE empresa.den_empresa,
       p_user               LIKE usuario.nom_usuario,
       p_alterado           SMALLINT,
       p_versao             CHAR(18),
       p_status             SMALLINT,
       p_nom_tela           CHAR(200),
       p_ies_cons           SMALLINT,
       p_sem_saldo          SMALLINT,
       p_retorno            SMALLINT,
       p_opcao              CHAR(1),
       p_ind                SMALLINT,
       s_ind                SMALLINT,
       p_msg                CHAR(500),
       ies_finalizar        CHAR(1),
       p_id_tabela          INTEGER,
       p_id_versao          INTEGER
END GLOBALS

DEFINE p_tab_frete_885         RECORD LIKE tab_frete_885.*,
       p_tab_frete_885_a       RECORD LIKE tab_frete_885.*

MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 5
    DEFER INTERRUPT
    LET p_versao = "pol1288-10.02.00 "
    OPTIONS
        NEXT KEY control-f,
        INSERT KEY control-i,
        DELETE KEY control-e,
        PREVIOUS KEY control-b

    CALL log001_acessa_usuario("ESPEC999","") RETURNING p_status, p_cod_empresa, p_user
    {LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0}
    
    IF p_status = 0 THEN
        CALL pol1288_menu()
    END IF
    
END MAIN

#---------------------#
FUNCTION pol1288_menu()
#---------------------#

    CALL log006_exibe_teclas("01",p_versao)
    INITIALIZE p_nom_tela TO NULL
    CALL log130_procura_caminho( "pol1288" ) RETURNING p_nom_tela
    LET p_nom_tela = p_nom_tela CLIPPED
    OPEN WINDOW w_pol1288 AT 2,1 WITH FORM p_nom_tela
        ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)
    
    DISPLAY p_cod_empresa TO cod_empresa
    
    MENU "OPCAO"
        COMMAND "Incluir" "Inclui dados na tabela."
            CALL pol1288_inclusao() RETURNING p_status
            IF p_status THEN
                ERROR 'Inclusão efetuada com sucesso !!!'
                LET p_ies_cons = FALSE
            ELSE
                ERROR 'Operação cancelada !!!'
            END IF
        COMMAND "Consultar" "Consulta dados da tabela."
            IF pol1288_consulta() THEN
                ERROR 'Consulta efetuada com sucesso !!!'
                NEXT OPTION "Seguinte"
            ELSE
                ERROR 'consulta cancela !!!'
            END IF
        COMMAND "Seguinte" "Exibe o próximo item encontrado na consulta."
            IF p_ies_cons THEN
                CALL pol1288_paginacao("S")
            ELSE
                ERROR "Não existe nenhuma consulta ativa !!!"
            END IF
        COMMAND "Anterior" "Exibe o item anterior encontrado na consulta."
            IF p_ies_cons THEN
                CALL pol1288_paginacao("A")
            ELSE
                ERROR "Não existe nenhuma consulta ativa !!!"
            END IF
        COMMAND "Modificar" "Modifica dados da tabela."
            IF p_ies_cons THEN
                CALL pol1288_modificacao() RETURNING p_status
                IF p_status THEN
                    DISPLAY p_tab_frete_885.tabela TO tabela
                    DISPLAY p_tab_frete_885.versao TO versao
                    DISPLAY p_tab_frete_885.versao_atual TO versao_atual
                    ERROR 'Modificação efetuada com sucesso !!!'
                ELSE
                    ERROR 'Operação cancelada !!!'
                END IF
            ELSE
                ERROR "Consulte previamente para fazer a modificacao !!!"
            END IF
        COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
            CALL pol1288_exibe_versao()
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
FUNCTION pol1288_limpa_tela()
#---------------------------#

    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa

END FUNCTION

#--------------------------#
FUNCTION pol1288_inclusao()
#--------------------------#
    
	DEFINE p_funcao CHAR(01)
    LET p_funcao   = 'I'
    
	CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    INITIALIZE p_tab_frete_885.* TO NULL
    LET INT_FLAG  = FALSE
    
    IF pol1288_edita_dados(p_funcao) THEN
        RETURN TRUE
    END IF
    
    IF INT_FLAG = 0 THEN
        RETURN TRUE
    ELSE
        LET INT_FLAG = 0
        CLEAR FORM
    END IF

    RETURN FALSE

END FUNCTION


#-------------------------------------#
FUNCTION pol1288_edita_dados(p_funcao)
#-------------------------------------#
    
    DEFINE p_funcao CHAR(01)
    LET INT_FLAG = FALSE
    
    IF p_funcao = 'I' THEN
        SELECT MAX(tabela)
          INTO p_id_tabela
          FROM tab_frete_885
    
        IF STATUS = 0 THEN
        ELSE
            CALL log003_err_sql("Lendo","tab_frete_885")
            RETURN FALSE
        END IF
    
        IF p_id_tabela IS NULL THEN
            LET p_id_tabela = 1
        ELSE
            LET p_id_tabela = p_id_tabela + 1
        END IF
    
        LET p_tab_frete_885.tabela = p_id_tabela
        LET p_tab_frete_885.versao = 1
        LET p_tab_frete_885.versao_atual = 'S'
    ELSE
        IF p_funcao = 'M' THEN
            SELECT MAX(versao)
              INTO p_id_versao
              FROM tab_frete_885
             WHERE tabela = p_tab_frete_885.tabela
    
            IF STATUS = 0 THEN
            ELSE
                CALL log003_err_sql("Lendo","tab_frete_885")
                RETURN FALSE
            END IF
    
            IF p_id_tabela IS NULL THEN
                LET p_id_versao = 1
            ELSE
                LET p_id_versao = p_id_versao + 1
            END IF
    
            LET p_tab_frete_885.versao = p_id_versao
            LET p_tab_frete_885.versao_atual = 'S'
        END IF
    END IF
    
    INPUT p_tab_frete_885.tabela,
          p_tab_frete_885.versao,
          p_tab_frete_885.versao_atual,
          p_tab_frete_885.origem,
          p_tab_frete_885.destino,
          p_tab_frete_885.val_tonelada
        WITHOUT DEFAULTS
           FROM tabela,
                versao,
                versao_atual,
                origem,
                destino,
                val_tonelada
    
        BEFORE FIELD origem
            IF p_funcao = "M" THEN
                NEXT FIELD val_tonelada
            END IF
    
        AFTER FIELD origem
            IF p_tab_frete_885.origem IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD origem
            END IF
    
        BEFORE FIELD destino
            IF p_funcao = "M" THEN
                NEXT FIELD val_tonelada
            END IF

        AFTER FIELD destino
            IF p_tab_frete_885.destino IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD destino
            END IF
   
        AFTER FIELD val_tonelada
            IF p_tab_frete_885.val_tonelada IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD val_tonelada
            END IF
    END INPUT
    
    IF INT_FLAG THEN
        RETURN FALSE
    END IF
    
    IF p_funcao = 'I' THEN
        IF pol1288_insere() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF

    IF p_funcao = 'M' THEN
        IF pol1288_altera() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF

END FUNCTION

#-----------------------#
FUNCTION pol1288_insere()
#-----------------------#

    CALL log085_transacao("BEGIN")
    
    INSERT INTO tab_frete_885 (
                tabela,
                versao,
                versao_atual,
                origem,
                destino,
                val_tonelada )
     VALUES (p_tab_frete_885.tabela,
             p_tab_frete_885.versao,
             p_tab_frete_885.versao_atual,
             p_tab_frete_885.origem,
             p_tab_frete_885.destino,
             p_tab_frete_885.val_tonelada )
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "INSERT", "tab_frete_885" )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1288_altera()
#-----------------------#
    
    CALL log085_transacao("BEGIN")
    
    IF pol1288_prende_registro() THEN
    ELSE
        RETURN FALSE
    END IF
    
    UPDATE tab_frete_885
       SET versao_atual = 'N'
     WHERE tabela = p_tab_frete_885.tabela
       AND versao  = p_tab_frete_885.versao-1
       AND versao_atual = 'S'
    
    IF status <> 0 then
        CALL log003_err_sql('UPDATE','tab_frete_885')
        RETURN FALSE
    END IF
    
    INSERT INTO tab_frete_885 (tabela,
                               versao,
                               versao_atual,
                               origem,
                               destino,
                               val_tonelada )
        VALUES (p_tab_frete_885.tabela,
                p_tab_frete_885.versao,
                p_tab_frete_885.versao_atual,
                p_tab_frete_885.origem,
                p_tab_frete_885.destino,
                p_tab_frete_885.val_tonelada )
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "INSERT", "tab_frete_885" )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
FUNCTION pol1288_consulta()
#--------------------------#
    
    DEFINE sql_stmt,
           where_clause CHAR(500)
    
    CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    LET p_tab_frete_885_a = p_tab_frete_885
    LET INT_FLAG = FALSE
    
    CONSTRUCT BY NAME where_clause ON
                      p_tab_frete_885.tabela,
                      p_tab_frete_885.versao,
                      p_tab_frete_885.versao_atual,
                      p_tab_frete_885.origem,
                      p_tab_frete_885.destino,
                      p_tab_frete_885.val_tonelada
    
    END CONSTRUCT
    
    IF INT_FLAG THEN
        IF p_ies_cons THEN
            LET p_tab_frete_885 = p_tab_frete_885_a
            CALL pol1288_exibe_dados() RETURNING p_status
        END IF
        RETURN FALSE
    END IF
    
    LET sql_stmt = "SELECT * ",
                   "  FROM tab_frete_885 ",
                   " WHERE ", where_clause CLIPPED,
                   " ORDER BY tabela, versao "
    
    PREPARE var_query FROM sql_stmt
    DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
    
    OPEN cq_padrao
    
    FETCH cq_padrao INTO p_tab_frete_885.*
    
    IF STATUS = NOTFOUND THEN
        CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
        LET p_ies_cons = FALSE
        RETURN FALSE
    ELSE
        IF pol1288_exibe_dados() THEN
            LET p_ies_cons = TRUE
            RETURN TRUE
        END IF
    END IF
    
    RETURN FALSE
    
END FUNCTION

#--------------------------------------#
FUNCTION pol1288_modificacao()
#--------------------------------------#
    
    DEFINE p_funcao CHAR(01)
    
    LET p_retorno = FALSE
    LET INT_FLAG  = FALSE
    LET p_funcao   = 'M'
    
    IF pol1288_edita_dados(p_funcao) THEN
		RETURN p_retorno
	ELSE
		RETURN FALSE
    END IF
    
    IF p_retorno THEN
        CALL log085_transacao("COMMIT")
    ELSE
        CALL log085_transacao("ROLLBACK")
    END IF
    
    RETURN p_retorno
    
END FUNCTION

#--------------------------------#
FUNCTION pol1288_prende_registro()
#--------------------------------#
    
    CALL log085_transacao("BEGIN")
    
    DECLARE cq_prende CURSOR FOR
    SELECT *
      FROM tab_frete_885
     WHERE tabela = p_tab_frete_885.tabela
       AND versao  = p_tab_frete_885.versao-1
       AND versao_atual = p_tab_frete_885.versao_atual
    
    FOR UPDATE
    
    OPEN cq_prende
    FETCH cq_prende
    
    IF STATUS = 0 THEN
        RETURN TRUE
    ELSE
        CALL log003_err_sql("Lendo","tab_frete_885")
        RETURN FALSE
    END IF
    
END FUNCTION

#----------------------------------#
FUNCTION pol1288_paginacao(p_funcao)
#----------------------------------#
    
    DEFINE p_funcao   CHAR(01)
    
    LET p_tab_frete_885_a.* = p_tab_frete_885.*
    
    WHILE TRUE
        CASE
            WHEN p_funcao = "S" FETCH NEXT cq_padrao INTO p_tab_frete_885.*
    
            WHEN p_funcao = "A" FETCH PREVIOUS cq_padrao INTO p_tab_frete_885.*
        END CASE
    
        IF STATUS = 0 THEN
            CALL pol1288_exibe_dados() RETURNING p_status
            EXIT WHILE
        ELSE
            IF STATUS = 100 THEN
                ERROR "Não existem mais itens nesta direção !!!"
                LET p_tab_frete_885.* = p_tab_frete_885_a.*
            ELSE
                CALL log003_err_sql('Lendo','cq_padrao_2')
            END IF
            EXIT WHILE
        END IF
    END WHILE
    
END FUNCTION

#------------------------------#
FUNCTION pol1288_exibe_dados()
#------------------------------#
    
    DISPLAY by NAME p_tab_frete_885.*
    
    RETURN TRUE

END FUNCTION

#-------------------------------------#
FUNCTION pol1288_exibe_versao()
#-------------------------------------#
    
    LET p_msg = p_versao CLIPPED, "\n","\n",
                "LOGIX 10.02 ","\n","\n",
                " Home page: www.aceex.com.br","\n","\n",
                " (0xx11) 4991-6667 ","\n","\n"
                
    CALL log0030_mensagem(p_msg,"excla")
    
END FUNCTION

#-------------------------------- FIM DE PROGRAMA -----------------------------#