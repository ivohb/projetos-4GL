#-------------------------------------------------------------------#
# SISTEMA.: LOGIX                                                   #
# PROGRAMA: POL1290                                                 #
# OBJETIVO: PERÍODO DE APURAÇÃO                                     #
# AUTOR...: DOUGLAS GREGORIO                                        #
# DATA....: 29/07/15                                                #
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
           p_ies_ambiente       char(01),
           p_ini_periodo        DATE,
           p_fim_periodo        DATE
          
END GLOBALS

DEFINE p_dat_atu CHAR(10)

MAIN
    CALL log0180_conecta_usuario()
    WHENEVER ANY ERROR CONTINUE
        SET ISOLATION TO DIRTY READ
        SET LOCK MODE TO WAIT 5
    DEFER INTERRUPT
    LET p_versao = "pol1290-10.02.00  "
   CALL func002_versao_prg(p_versao)
    OPTIONS
        NEXT KEY control-f,
        INSERT KEY control-i,
        DELETE KEY control-e,
        PREVIOUS KEY control-b

    CALL log001_acessa_usuario("ESPEC999","")
        RETURNING p_status, p_cod_empresa, p_user
        
    {LET p_cod_empresa = '01'; LET p_user = 'admlog'; LET p_status = 0      }
    	
    IF p_status = 0 THEN
        CALL pol1290_menu()
    END IF
END MAIN

#----------------------#
 FUNCTION pol1290_menu()
#----------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1290") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED
   OPEN WINDOW w_pol1290 AT 2,2 WITH FORM p_nom_tela
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   DISPLAY p_cod_empresa TO cod_empresa

   LET p_dat_atu = EXTEND(CURRENT, YEAR TO DAY)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui dados na tabela."
         CALL pol1290_inclusao() RETURNING p_status
         IF p_status THEN
            ERROR 'Inclusão efetuada com sucesso !!!'
            LET p_ies_cons = FALSE
         END IF
      COMMAND "Consultar" "Consulta dados da tabela."
         IF pol1290_consulta() THEN
            ERROR 'Consulta efetuada com sucesso !!!'
            NEXT OPTION "Seguinte"
         ELSE
            ERROR 'consulta cancela !!!'
         END IF
      COMMAND "Modificar" "Modifica dados da tabela."
         IF p_ies_cons THEN
            CALL pol1290_modificacao() RETURNING p_status
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
            CALL pol1290_exclusao() RETURNING p_status
            IF p_status THEN
               ERROR 'Exclusão efetuada com sucesso !!!'
            ELSE
               ERROR 'Operação cancelada !!!'
            END IF
         ELSE
            ERROR "Consulte previamente para fazer a exclusão !!!"
         END IF
      COMMAND "Listar" "Listagem dos registros cadastrados."
         CALL pol1290_listagem()
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
   CLOSE WINDOW w_pol1290

END FUNCTION

#--------------------------#
FUNCTION pol1290_inclusao()
#--------------------------#

    CLEAR FORM
    DISPLAY p_cod_empresa       TO cod_empresa
    INITIALIZE p_cod_fornecedor TO NULL
    LET p_opcao = 'I'
    LET p_ini_periodo = NULL
    LET p_fim_periodo = NULL
    
    SELECT COUNT(cod_empresa)
      INTO p_count
      FROM periodo_apuracao_885
     WHERE cod_empresa = p_cod_empresa

      IF STATUS <> 0 THEN
         CALL log003_err_sql("Lendo","periodo_apuracao_885")
         RETURN FALSE
      END IF

      IF p_count > 0 THEN
         ERROR "Já existe registro para esta empresa!!! - Use a opção modificar"
         RETURN FALSE
      END IF
      
    IF pol1290_edita_dados(p_opcao) THEN
        RETURN TRUE
    END IF
    
    RETURN FALSE

END FUNCTION

#------------------------------------#
FUNCTION pol1290_edita_dados(p_funcao)
#------------------------------------#

	DEFINE p_funcao CHAR(01)
  
  LET INT_FLAG  = FALSE

    INPUT p_ini_periodo,
          p_fim_periodo
        WITHOUT DEFAULTS
           FROM ini_periodo,
                fim_periodo
        

       AFTER INPUT
          
          IF NOT INT_FLAG THEN
             
             IF p_ini_periodo IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD ini_periodo
             END IF

             IF p_fim_periodo IS NULL THEN
                ERROR "Campo com preenchimento obrigatório !!!"
                NEXT FIELD fim_periodo
             END IF

             IF p_ini_periodo > p_fim_periodo THEN
                ERROR "Período inválido !!!"
                NEXT FIELD ini_periodo
             END IF
          
          END IF
                
    END INPUT
    
    IF INT_FLAG THEN
        CLEAR FORM
        DISPLAY p_cod_empresa TO cod_empresa
        RETURN FALSE
    END IF

    IF p_funcao = 'I' THEN
        IF pol1290_insere() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF

    IF p_funcao = 'M' THEN
        IF pol1290_altera() THEN
            RETURN TRUE
        ELSE
            RETURN FALSE
        END IF
    END IF
    
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1290_insere()
#-----------------------#

    CALL log085_transacao("BEGIN")
    
    INSERT INTO periodo_apuracao_885 (
                cod_empresa,
                ini_periodo,
                fim_periodo)
     VALUES (p_cod_empresa,
             p_ini_periodo,
             p_fim_periodo)
    
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "INSERT", "periodo_apuracao_885" )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE

END FUNCTION

#-----------------------#
FUNCTION pol1290_altera()
#-----------------------#
    
    CALL log085_transacao("BEGIN")
    
    IF pol1290_prende_registro() THEN
    ELSE
        RETURN FALSE
    END IF
    
    UPDATE periodo_apuracao_885
        SET ini_periodo = p_ini_periodo,
            fim_periodo = p_fim_periodo
     WHERE cod_empresa  = p_cod_empresa
    IF STATUS <> 0 THEN
        CALL log003_err_sql( "UPDATE", "periodo_apuracao_885" )
        CALL log085_transacao("ROLLBACK")
    
        RETURN FALSE
    END IF
    
    CALL log085_transacao("COMMIT")
    
    RETURN TRUE
    
END FUNCTION

#--------------------------#
 FUNCTION pol1290_consulta()
#--------------------------#

   DEFINE sql_stmt,
          where_clause CHAR(500)

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   LET INT_FLAG = FALSE

   CONSTRUCT BY NAME where_clause ON
                     ini_periodo,
                     fim_periodo   
   END CONSTRUCT

   LET sql_stmt = "SELECT ini_periodo, fim_periodo ",
                  "  FROM periodo_apuracao_885 ",
                  " WHERE ", where_clause CLIPPED,
                  "   AND cod_empresa = '",p_cod_empresa,"' "

   PREPARE var_query FROM sql_stmt
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query

   OPEN cq_padrao

   FETCH cq_padrao INTO p_ini_periodo,p_fim_periodo

   IF STATUS = NOTFOUND THEN
      CALL log0030_mensagem("Argumentos de pesquisa não encontrados !!!","exclamation")
      LET p_ies_cons = FALSE
      RETURN FALSE
   ELSE
      IF pol1290_exibe_dados() THEN
         LET p_ies_cons = TRUE
         RETURN TRUE
      END IF
   END IF

   RETURN FALSE

END FUNCTION

#------------------------------#
 FUNCTION pol1290_exibe_dados()
#------------------------------#

    DISPLAY p_ini_periodo TO ini_periodo
    DISPLAY p_fim_periodo TO fim_periodo 
    
    RETURN TRUE

END FUNCTION

#----------------------------------#
FUNCTION pol1290_prende_registro()
#----------------------------------#

   CALL log085_transacao("BEGIN")

   DECLARE cq_prende CURSOR FOR
    SELECT cod_empresa, ini_periodo, fim_periodo
      FROM periodo_apuracao_885
     WHERE cod_empresa = p_cod_empresa
       FOR UPDATE

    OPEN cq_prende
   FETCH cq_prende

   IF STATUS = 0 THEN
      RETURN TRUE
   ELSE
      CALL log003_err_sql("Lendo","periodo_apuracao_885")
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1290_modificacao()
#-----------------------------#

   LET p_retorno = FALSE
   LET INT_FLAG  = FALSE
   LET p_opcao   = 'M'

   IF pol1290_prende_registro() THEN
      IF pol1290_edita_dados(p_opcao) THEN
            LET p_retorno = TRUE
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
 FUNCTION pol1290_exclusao()
#--------------------------#

   IF NOT log004_confirm(18,35) THEN
      RETURN FALSE
   END IF

   LET p_retorno = FALSE

   IF pol1290_prende_registro() THEN
      DELETE FROM periodo_apuracao_885
			 WHERE cod_empresa = p_cod_empresa
      IF STATUS = 0 THEN
         INITIALIZE p_ini_periodo TO NULL
         INITIALIZE p_fim_periodo TO NULL
         CLEAR FORM
         DISPLAY p_cod_empresa TO cod_empresa
         LET p_retorno = TRUE
      ELSE
         CALL log003_err_sql("DELETE","periodo_apuracao_885")
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