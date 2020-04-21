#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0322                                                 #
# MODULOS.: POL0322 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA TIPO_CARACT_PETROM                 #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 11/02/2005                                              #
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

    DEFINE mr_tipo_caract_petrom  RECORD LIKE tipo_caract_petrom.*,
           mr_tipo_caract_petromr RECORD LIKE tipo_caract_petrom.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0322-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0322.iem") RETURNING p_nom_help
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
      CALL pol0322_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION pol0322_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0322") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0322 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0322","IN") THEN
            CALL pol0322_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_tipo_caract_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0322","MO") THEN
               CALL pol0322_modificacao()
               LET p_ies_cons = TRUE
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificacao"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_tipo_caract_petrom.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol0322","EX") THEN
               CALL pol0322_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusao"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0322","CO") THEN
            CALL pol0322_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Proximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0322_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0322_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0322_sobre()
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
   CLOSE WINDOW w_pol0322

END FUNCTION

#--------------------------#
 FUNCTION pol0322_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0322_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET mr_tipo_caract_petrom.cod_empresa = p_cod_empresa
      INSERT INTO tipo_caract_petrom VALUES (mr_tipo_caract_petrom.*)
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","NIVEL_KB_DESTACO")       
      ELSE
         CALL log085_transacao("COMMIT")
      #  COMMIT WORK 
         MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         LET p_ies_cons = FALSE
      END IF
   ELSE
      CLEAR FORM
      ERROR "Inclusao Cancelada"
      RETURN FALSE
   END IF

   RETURN TRUE

END FUNCTION

#---------------------------------------#
 FUNCTION pol0322_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0322
   DISPLAY p_cod_empresa TO cod_empresa
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_tipo_caract_petrom.* TO NULL
   END IF

   INPUT BY NAME mr_tipo_caract_petrom.tip_analise,
                 mr_tipo_caract_petrom.val_caracter,
                 mr_tipo_caract_petrom.den_caracter WITHOUT DEFAULTS  

      BEFORE FIELD tip_analise
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_caracter
         END IF

      AFTER FIELD tip_analise  
         IF mr_tipo_caract_petrom.tip_analise IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD tip_analise  
         ELSE
            IF pol0322_verifica_tip_analise() = FALSE THEN
               ERROR "Tipo de análise não Cadastrada."
               NEXT FIELD tip_analise
            END IF
         END IF

      BEFORE FIELD val_caracter
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_caracter
         END IF
      
      AFTER FIELD val_caracter    
         IF mr_tipo_caract_petrom.val_caracter IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD val_caracter
         ELSE
            IF pol0322_verifica_val_caracter() THEN
               ERROR "Código já cadastrado."
               NEXT FIELD val_caracter 
            END IF
         END IF
      
      AFTER FIELD den_caracter    
         IF mr_tipo_caract_petrom.den_caracter IS NULL OR 
            mr_tipo_caract_petrom.den_caracter = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_caracter
         END IF

      ON KEY (control-z)
         CALL pol0322_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0322
   IF INT_FLAG = 0 THEN
      LET p_ies_cons = FALSE
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
 FUNCTION pol0322_popup()
#-----------------------#

   DEFINE p_codigo CHAR(15)
  
   CASE
      WHEN INFIELD(tip_analise)
         CALL log009_popup(6,25,"TIPO DE ANALISES","it_analise_petrom","tip_analise",
                           "den_analise","","S","") 
            RETURNING p_codigo
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0322 
         IF p_cod_nat_oper IS NOT NULL THEN 
            LET mr_tipo_caract_petrom.tip_analise = p_codigo
            DISPLAY p_codigo TO tip_analise
         END IF
   END CASE

END FUNCTION  


#--------------------------------------#
 FUNCTION pol0322_verifica_tip_analise()
#--------------------------------------#
    DEFINE l_den_analise      LIKE it_analise_petrom.den_analise

    SELECT den_analise
      INTO l_den_analise
      FROM it_analise_petrom
     WHERE cod_empresa = p_cod_empresa  
       AND tip_analise = mr_tipo_caract_petrom.tip_analise
    IF sqlca.sqlcode = 0 THEN
       DISPLAY l_den_analise TO den_analise
       RETURN TRUE
    ELSE
       DISPLAY l_den_analise TO den_analise
       RETURN FALSE
    END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0322_verifica_val_caracter()
#---------------------------------------#

    SELECT *
      FROM tipo_caract_petrom
     WHERE cod_empresa  = p_cod_empresa  
       AND tip_analise  = mr_tipo_caract_petrom.tip_analise
       AND val_caracter = mr_tipo_caract_petrom.val_caracter 
    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0322_consulta()
#--------------------------#

   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON tipo_caract_petrom.tip_analise,
                                     tipo_caract_petrom.val_caracter, 
                                     tipo_caract_petrom.den_caracter 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0322

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_tipo_caract_petrom.* = mr_tipo_caract_petromr.*
      CALL pol0322_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM tipo_caract_petrom ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY tip_analise, val_caracter "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_tipo_caract_petrom.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa nao Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0322_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0322_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_tipo_caract_petrom.*
   
   CALL pol0322_verifica_tip_analise() RETURNING p_status
 
END FUNCTION

#-----------------------------------#
 FUNCTION pol0322_paginacao(p_funcao)
#-----------------------------------#

   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_tipo_caract_petromr.* = mr_tipo_caract_petrom.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_tipo_caract_petrom.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_tipo_caract_petrom.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção."
            LET mr_tipo_caract_petrom.* = mr_tipo_caract_petromr.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_tipo_caract_petrom.* 
           FROM tipo_caract_petrom   
          WHERE cod_empresa  = mr_tipo_caract_petrom.cod_empresa
            AND tip_analise  = mr_tipo_caract_petrom.tip_analise
            AND val_caracter = mr_tipo_caract_petrom.val_caracter
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0322_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0322_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR FOR
   SELECT *                            
     INTO mr_tipo_caract_petrom.*                                              
     FROM tipo_caract_petrom 
    WHERE cod_empresa  = mr_tipo_caract_petrom.cod_empresa
      AND tip_analise  = mr_tipo_caract_petrom.tip_analise
      AND val_caracter = mr_tipo_caract_petrom.val_caracter 
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usua",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro nao mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","NIVEL_KB_DESTACO")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0322_modificacao()
#-----------------------------#

   IF pol0322_cursor_for_update() THEN
      LET mr_tipo_caract_petromr.* = mr_tipo_caract_petrom.*
      IF pol0322_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE tipo_caract_petrom
            SET den_caracter = mr_tipo_caract_petrom.den_caracter  
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","TIPO_CARACT_PETROM")
            ELSE
               MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","TIPO_CARACT_PETROM")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_tipo_caract_petrom.* = mr_tipo_caract_petromr.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         CALL pol0322_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0322_exclusao()
#--------------------------#

   IF pol0322_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM tipo_caract_petrom 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-EXC","TIPO_CARACT_PETROM")
            ELSE
               MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_tipo_caract_petrom.* TO NULL
               CLEAR FORM
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","TIPO_CARACT_PETROM")
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
 FUNCTION pol0322_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#