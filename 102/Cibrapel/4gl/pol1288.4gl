#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: pol1288                                                 #
# OBJETIVO: Tabelas de preço de frete por rota                      #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 22/07/2015                                              #
# FUNÇÕES: FUNC002                                                  #
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

DEFINE p_val_tonelada DECIMAL(12,2),
       p_num_versao   INTEGER,
       p_den_rota     CHAR(50),
       p_count        INTEGER
      
MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 5
    DEFER INTERRUPT
    LET p_versao = "pol1288-10.02.00  "
   CALL func002_versao_prg(p_versao)
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
            IF p_ies_cons AND p_tab_frete_885.tabela IS NOT NULL THEN
                CALL pol1288_modificacao() RETURNING p_status
                IF p_status THEN
                    ERROR 'Modificação efetuada com sucesso !!!'
                    LET p_ies_cons = FALSE
                ELSE
                    ERROR 'Operação cancelada !!!'
                END IF
            ELSE
                ERROR "Consulte previamente para fazer a modificacao !!!"
            END IF
        COMMAND "Excluir" "Exclui dados da tabela."
            IF p_ies_cons AND p_tab_frete_885.tabela IS NOT NULL THEN
                CALL pol1288_exclusao() RETURNING p_status
                IF p_status THEN
                    ERROR 'Operação efetuada com sucesso !!!'
                ELSE
                    ERROR 'Operação cancelada !!!'
                END IF
            ELSE
                ERROR "Consulte previamente a tabela"
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
    
	CLEAR FORM
    DISPLAY p_cod_empresa TO cod_empresa
    INITIALIZE p_tab_frete_885.* TO NULL
    LET INT_FLAG  = FALSE
    LET p_tab_frete_885.cod_empresa = p_cod_empresa 
    
   SELECT MAX(tabela)
     INTO p_id_tabela
     FROM tab_frete_885
    WHERE cod_empresa = p_cod_empresa 
    
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
    
    IF NOT pol1288_edita_dados() THEN
        RETURN FALSE
    END IF

    CALL log085_transacao("BEGIN")
    
    IF NOT pol1288_insere() THEN
        CALL log085_transacao("ROLLBACK")
       RETURN FALSE
    END IF

    CALL log085_transacao("COMMIT")
    
    RETURN TRUE

END FUNCTION


#------------------------------#
FUNCTION pol1288_edita_dados()
#------------------------------#
    
   LET INT_FLAG = FALSE
    
    INPUT p_tab_frete_885.tabela,
          p_tab_frete_885.versao,
          p_tab_frete_885.versao_atual,
          p_tab_frete_885.cod_rota,
          p_tab_frete_885.val_tonelada
        WITHOUT DEFAULTS
           FROM tabela,
                versao,
                versao_atual,
                cod_rota,
                val_tonelada

        AFTER FIELD cod_rota
            IF p_tab_frete_885.cod_rota IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD cod_rota
            END IF
            
            IF NOT pol1288_le_rota(p_tab_frete_885.cod_rota) THEN
               NEXT FIELD cod_rota
            END IF
            
            DISPLAY p_den_rota TO den_rota

            IF NOT pol1288_tabela_existe(p_tab_frete_885.cod_rota) THEN
               NEXT FIELD cod_rota
            END IF
            
            DISPLAY p_den_rota TO den_rota
            
        AFTER FIELD val_tonelada
            IF p_tab_frete_885.val_tonelada IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD val_tonelada
            END IF

      ON KEY (control-z)
         CALL pol1288_popup()

    END INPUT

    IF INT_FLAG THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO cod_empresa
        RETURN FALSE
    END IF
       
   RETURN TRUE
       
END FUNCTION

#------------------------------------#
 FUNCTION pol1288_le_rota(l_cod_rota)
#------------------------------------#

   DEFINE l_cod_rota INTEGER
   
   SELECT den_rota
     INTO p_den_rota
     FROM rotas_885
    WHERE cod_rota = l_cod_rota

   IF STATUS <> 0 THEN
      LET p_msg = 'Não foi possivel ler a rota\n',
                  'do POL1297. Erro: ', STATUS
      CALL log0030_mensagem(p_msg,'info')
      LET p_den_rota = NULL
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------------------#
 FUNCTION pol1288_tabela_existe(l_cod_rota)
#------------------------------------------#

   DEFINE l_cod_rota INTEGER
   
   SELECT COUNT(cod_rota)
     INTO p_count
     FROM tab_frete_885
    WHERE cod_empresa = p_cod_empresa
      AND cod_rota = l_cod_rota

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','tab_frete_885')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Já existe tabela para eesa rota.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION
     
#-----------------------#
 FUNCTION pol1288_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)

   CASE
      WHEN INFIELD(cod_rota)
         CALL log009_popup(8,25,"ROTAS","rotas_885",
                     "cod_rota","den_rota","pol1297","N","") 
            RETURNING p_codigo
            
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         
         CURRENT WINDOW IS w_pol1288
         
         IF p_codigo IS NOT NULL THEN
            LET p_tab_frete_885.cod_rota = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_rota
         END IF

   END CASE

END FUNCTION

#-----------------------#
FUNCTION pol1288_insere()
#-----------------------#
    
    INSERT INTO tab_frete_885 (
                cod_empresa,
                tabela,
                versao,
                versao_atual,
                cod_rota,
                val_tonelada )
     VALUES (p_tab_frete_885.cod_empresa,
             p_tab_frete_885.tabela,
             p_tab_frete_885.versao,
             p_tab_frete_885.versao_atual,
             p_tab_frete_885.cod_rota,
             p_tab_frete_885.val_tonelada )
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "INSERT", "tab_frete_885" )
        RETURN FALSE
    END IF
    
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
                      p_tab_frete_885.cod_rota

      ON KEY (control-z)
         CALL pol1288_popup()
    
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
                   "   AND cod_empresa = '",p_cod_empresa,"' ",
                   " ORDER BY tabela, versao "
    
    PREPARE var_query FROM sql_stmt
    DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
    
    OPEN cq_padrao
    
    FETCH cq_padrao INTO p_tab_frete_885.*
    
   IF STATUS = 100 THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      RETURN FALSE
   ELSE
      IF STATUS = 0 THEN
         IF pol1288_exibe_dados() THEN
            LET p_ies_cons = TRUE
            RETURN TRUE
         END IF
      ELSE
         CALL log003_err_sql('FETCH','cq_padrao')
         RETURN FALSE
      END IF
   END IF
    
    RETURN FALSE
    
END FUNCTION

#------------------------------#
FUNCTION pol1288_exibe_dados()
#------------------------------#
    
    DISPLAY BY NAME p_tab_frete_885.*
    
    CALL pol1288_le_rota(p_tab_frete_885.cod_rota) RETURNING p_status
            
    DISPLAY p_den_rota TO den_rota
    
    RETURN TRUE

END FUNCTION

#--------------------------------#
FUNCTION pol1288_prende_registro()
#--------------------------------#
    
    CALL log085_transacao("BEGIN")
    
    DECLARE cq_prende CURSOR FOR
    SELECT *
      FROM tab_frete_885
     WHERE cod_empresa = p_cod_empresa
       AND tabela = p_tab_frete_885.tabela
       AND versao = p_tab_frete_885.versao
    
    FOR UPDATE
    
    OPEN cq_prende
    FETCH cq_prende
    
    IF STATUS = 0 THEN
        RETURN TRUE
    ELSE
        CALL log003_err_sql("Lendo","tab_frete_885")
        CALL log085_transacao("ROLLBACK")
        RETURN FALSE
    END IF
    
END FUNCTION

#------------------------------#
FUNCTION pol1288_checa_versao()
#------------------------------#

   IF p_tab_frete_885.versao_atual = 'S' THEN
   ELSE
      LET p_msg = 'Somente a versão autal\n pode ser alterada.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF
   
   RETURN TRUE

END FUNCTION

#------------------------------#
FUNCTION pol1288_modificacao()
#------------------------------#
   
   DEFINE p_retorno SMALLINT
   
   IF NOT pol1288_checa_versao() THEN
      RETURN FALSE
   END IF
      
   LET p_val_tonelada = p_tab_frete_885.val_tonelada
   LET p_num_versao = p_tab_frete_885.versao
   
   IF pol1288_prende_registro() THEN
      IF pol1288_edita_valor() THEN
		     IF pol1288_altera() THEN
            LET p_retorno = TRUE
         END IF
      END IF
      CLOSE cq_prende
   END IF
      
   IF p_retorno THEN
       CALL log085_transacao("COMMIT")
   ELSE
       CALL log085_transacao("ROLLBACK")
       LET p_tab_frete_885.val_tonelada = p_val_tonelada
       DISPLAY p_tab_frete_885.val_tonelada TO val_tonelada
       LET p_tab_frete_885.versao = p_num_versao
       DISPLAY p_tab_frete_885.versao TO versao
   END IF
    
   RETURN p_retorno
    
END FUNCTION

#-----------------------------#
FUNCTION pol1288_edita_valor()
#-----------------------------#
   
   LET INT_FLAG = FALSE
         
   LET p_tab_frete_885.versao = p_tab_frete_885.versao + 1
   DISPLAY p_tab_frete_885.versao TO versao
   
    INPUT p_tab_frete_885.val_tonelada
        WITHOUT DEFAULTS
           FROM val_tonelada

        AFTER FIELD val_tonelada
            IF p_tab_frete_885.val_tonelada IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD val_tonelada
            END IF
    END INPUT
    
    IF INT_FLAG THEN
        RETURN FALSE
    END IF
   
   RETURN TRUE
       
END FUNCTION

#-----------------------#
FUNCTION pol1288_altera()
#-----------------------#
        
    UPDATE tab_frete_885
       SET versao_atual = 'N'
     WHERE cod_empresa = p_cod_empresa
       AND tabela = p_tab_frete_885.tabela
       AND versao = p_num_versao
    
    IF status <> 0 then
        CALL log003_err_sql('UPDATE','tab_frete_885')
        RETURN FALSE
    END IF

    IF NOT pol1288_insere() THEN
       RETURN FALSE
    END IF
        
    RETURN TRUE
    
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
            IF pol1288_le_tabela() THEN
               CALL pol1288_exibe_dados() RETURNING p_status
               EXIT WHILE
            END IF
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

#---------------------------#
FUNCTION pol1288_le_tabela()
#---------------------------#

   SELECT tabela
     FROM tab_frete_885
    WHERE cod_empresa = p_cod_empresa
      AND tabela = p_tab_frete_885.tabela
      AND versao = p_tab_frete_885.versao

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1288_exclusao()
#--------------------------#

   IF pol1288_ja_usou() THEN
      RETURN FALSE
   END IF
   
   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF

   LET p_retorno = FALSE

   IF pol1288_prende_registro() THEN

      DELETE FROM tab_frete_885
       WHERE cod_empresa = p_cod_empresa
         AND tabela = p_tab_frete_885.tabela

      IF STATUS = 0 THEN
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
         LET p_tab_frete_885.tabela = NULL
      ELSE
         CALL log003_err_sql("Excluindo","tab_frete_885")
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

#-------------------------#
FUNCTION pol1288_ja_usou()
#-------------------------#

   SELECT COUNT(tabela)
     INTO p_count
     FROM nf_x_tab_frete_885
    WHERE cod_empresa = p_cod_empresa
      AND tabela = p_tab_frete_885.tabela

   IF STATUS <> 0 THEN
      CALL log003_err_sql('SELECT','nf_x_tab_frete_885')
      RETURN FALSE
   END IF
   
   IF p_count > 0 THEN
      LET p_msg = 'Tabela já utilizada no controle\n de frete não pode ser excluida.'
      CALL log0030_mensagem(p_msg,'info')
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

  
      
    
#-------------------------------- FIM DE PROGRAMA -----------------------------#