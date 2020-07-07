#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0312                                                 #
# MODULOS.: POL0312 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA IT_ANALISE_PETROM                  #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 05/02/2005                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
      #   p_versao       CHAR(17),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(100)

END GLOBALS

    DEFINE mr_it_analise_petrom  RECORD LIKE it_analise_petrom.*,
           mr_it_analise_petromr RECORD LIKE it_analise_petrom.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0312-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0312.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

#  CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL pol0312_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0312_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0312") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0312 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela IT_ANALISE_PETROM"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0312","IN") THEN
            CALL pol0312_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela IT_ANALISE_PETROM"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_it_analise_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0312","MO") THEN
               CALL pol0312_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela IT_ANALISE_PETROM"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_it_analise_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0312","EX") THEN
               CALL pol0312_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela IT_ANALISE_PETROM"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0312","CO") THEN
            CALL pol0312_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0312_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0312_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0312_sobre()
      COMMAND KEY ("!")
         PROMPT "Digite o comando : " FOR comando
         RUN comando
         PROMPT "\nTecle ENTER para continuar" FOR CHAR comando
         DATABASE logix
         LET INT_FLAG = 0
      COMMAND "Fim" "Retorna ao Menu Anterior"
         HELP 008
         MESSAGE ""
         EXIT MENU
   END MENU
   CLOSE WINDOW w_pol0312

END FUNCTION

#--------------------------#
 FUNCTION pol0312_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0312_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET mr_it_analise_petrom.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO it_analise_petrom VALUES (mr_it_analise_petrom.*)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","IT_ANALISE_PETROM")       
      ELSE
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK 
         MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusão Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0312_entrada_dados(p_funcao)
#---------------------------------------#
   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0312
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_it_analise_petrom.* TO NULL
   END IF

   INPUT BY NAME mr_it_analise_petrom.tip_analise,
                 mr_it_analise_petrom.den_analise,
                 mr_it_analise_petrom.den_analise_ing WITHOUT DEFAULTS  

      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_analise
         END IF

      AFTER FIELD tip_analise  
         IF mr_it_analise_petrom.tip_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD tip_analise  
         ELSE
            IF pol0312_verifica_tip_analise() THEN
               ERROR "Tipo de análise já Cadastrada."
               NEXT FIELD tip_analise
            END IF
         END IF

      AFTER FIELD den_analise    
         IF mr_it_analise_petrom.den_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_analise
         END IF

      END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0312
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0312_verifica_tip_analise()
#--------------------------------------#

    SELECT *
      FROM it_analise_petrom
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_it_analise_petrom.tip_analise
    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0312_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON it_analise_petrom.tip_analise,
                                     it_analise_petrom.den_analise,
                                     it_analise_petrom.den_analise_ing 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0312

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_it_analise_petrom.* = mr_it_analise_petromr.*
      CALL pol0312_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM it_analise_petrom ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY tip_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_it_analise_petrom.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0312_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0312_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_it_analise_petrom.tip_analise,
                   mr_it_analise_petrom.den_analise,
                   mr_it_analise_petrom.den_analise_ing

END FUNCTION

#-----------------------------------#
 FUNCTION pol0312_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_it_analise_petromr.* = mr_it_analise_petrom.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_it_analise_petrom.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_it_analise_petrom.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_it_analise_petrom.* = mr_it_analise_petromr.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_it_analise_petrom.* 
           FROM it_analise_petrom   
          WHERE cod_empresa = mr_it_analise_petrom.cod_empresa
            AND tip_analise = mr_it_analise_petrom.tip_analise
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0312_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0312_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
      INTO mr_it_analise_petrom.*                                              
   FROM it_analise_petrom 
   WHERE cod_empresa = mr_it_analise_petrom.cod_empresa
     AND tip_analise = mr_it_analise_petrom.tip_analise
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usuá",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro não mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","IT_ANALISE_PETROM")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0312_modificacao()
#-----------------------------#

   IF pol0312_cursor_for_update() THEN
      LET mr_it_analise_petromr.* = mr_it_analise_petrom.*
      IF pol0312_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE it_analise_petrom
            SET den_analise     = mr_it_analise_petrom.den_analise,
                den_analise_ing = mr_it_analise_petrom.den_analise_ing  
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","IT_ANALISE_PETROM")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","IT_ANALISE_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_it_analise_petrom.* = mr_it_analise_petromr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         DISPLAY BY NAME mr_it_analise_petrom.tip_analise
         DISPLAY BY NAME mr_it_analise_petrom.den_analise
         DISPLAY BY NAME mr_it_analise_petrom.den_analise_ing
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0312_exclusao()
#--------------------------#

   IF pol0312_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM it_analise_petrom 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","IT_ANALISE_PETROM")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_it_analise_petrom.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","IT_ANALISE_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION pol0312_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#