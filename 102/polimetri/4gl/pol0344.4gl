#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0344                                                 #
# MODULOS.: POL0344 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA EVENTO_POLIMETRI                   #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 04/05/2005                                              #
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
          p_msg          CHAR(500)

END GLOBALS

    DEFINE mr_evento_polimetri   RECORD LIKE evento_polimetri.*,
           mr_evento_polimetrir  RECORD LIKE evento_polimetri.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0344-10.02.00"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0344.iem") RETURNING p_nom_help
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
      CALL pol0344_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0344_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0344") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0344 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela EVENTO_POLIMETRI"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0344","IN") THEN
            CALL pol0344_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela EVENTO_POLIMETRI"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0344","MO") THEN
               CALL pol0344_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela EVENTO_POLIMETRI"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF p_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0344","EX") THEN
               CALL pol0344_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela EVENTO_POLIMETRI"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0344","CO") THEN
            CALL pol0344_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0344_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0344_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol0344_sobre()
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
   CLOSE WINDOW w_pol0344

END FUNCTION

#--------------------------#
 FUNCTION pol0344_inclusao()
#--------------------------#

   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol0344_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
   #  BEGIN WORK
      LET mr_evento_polimetri.cod_empresa = p_cod_empresa
      WHENEVER ERROR CONTINUE
      INSERT INTO evento_polimetri VALUES (mr_evento_polimetri.*)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","EVENTO_POLIMETRI")       
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
 FUNCTION pol0344_entrada_dados(p_funcao)
#---------------------------------------#

   DEFINE p_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0344
   IF p_funcao = "INCLUSAO" THEN
      INITIALIZE mr_evento_polimetri.* TO NULL
      LET mr_evento_polimetri.cod_empresa = p_cod_empresa
  #    DISPLAY BY NAME mr_evento_polimetri.cod_empresa
   END IF

   INPUT BY NAME mr_evento_polimetri.* WITHOUT DEFAULTS  

      BEFORE FIELD cod_evento 
         IF p_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_evento
         END IF

      AFTER FIELD cod_evento  
         IF mr_evento_polimetri.cod_evento IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_evento  
         ELSE
            IF pol0344_verifica_evento() THEN
               ERROR "Evento já Cadastrado."
               NEXT FIELD cod_evento 
            END IF
         END IF

      AFTER FIELD den_evento    
         IF mr_evento_polimetri.den_evento IS NULL OR
            mr_evento_polimetri.den_evento = ' ' THEN 
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD den_evento
         END IF

      AFTER FIELD cta_debito  
         IF mr_evento_polimetri.cta_debito IS NULL OR
            mr_evento_polimetri.cta_debito = ' ' THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cta_debito  
         ELSE
            IF pol0344_verifica_conta_debito() = FALSE THEN
               ERROR "Conta Débito não Cadastrada."
               NEXT FIELD cta_debito 
            END IF
         END IF

      AFTER FIELD cod_hist_deb  
         IF mr_evento_polimetri.cod_hist_deb IS NULL THEN
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_hist_deb  
         ELSE
            IF pol0344_verifica_historico() = FALSE THEN
               ERROR "Histórico não Cadastrado."
               NEXT FIELD cod_hist_deb 
            END IF
         END IF

      ON KEY (control-z)
         CALL pol0344_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0344
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------#
 FUNCTION pol0344_verifica_evento()
#---------------------------------#
   SELECT den_evento
     FROM evento_polimetri
    WHERE cod_empresa = p_cod_empresa  
      AND cod_evento  = mr_evento_polimetri.cod_evento
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0344_verifica_conta_debito()
#---------------------------------------#
   DEFINE l_den_conta         LIKE plano_contas.den_conta

   WHENEVER ERROR CONTINUE
     SELECT den_conta
       INTO l_den_conta 
       FROM plano_contas
      WHERE cod_empresa = p_cod_empresa  
        AND num_conta   = mr_evento_polimetri.cta_debito 
   WHENEVER ERROR STOP 
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_conta TO den_conta
      RETURN TRUE
   ELSE
      DISPLAY l_den_conta TO den_conta
      RETURN FALSE
   END IF

END FUNCTION

#------------------------------------#
 FUNCTION pol0344_verifica_historico()
#------------------------------------#
   DEFINE l_tex_hist         LIKE hist_padrao.tex_hist

   WHENEVER ERROR CONTINUE
     SELECT tex_hist 
       INTO l_tex_hist 
       FROM hist_padrao 
      WHERE cod_empresa = p_cod_empresa  
        AND cod_hist    = mr_evento_polimetri.cod_hist_deb 
   WHENEVER ERROR STOP 
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_tex_hist TO tex_hist
      RETURN TRUE
   ELSE
      DISPLAY l_tex_hist TO tex_hist
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0344_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON evento_polimetri.cod_evento,
                                     evento_polimetri.den_evento,
                                     evento_polimetri.cta_debito,
                                     evento_polimetri.cod_hist_deb 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0344

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_evento_polimetri.* = mr_evento_polimetrir.*
      CALL pol0344_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM evento_polimetri ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_evento "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_evento_polimetri.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol0344_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol0344_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_evento_polimetri.*
   CALL pol0344_verifica_conta_debito() RETURNING p_status
   CALL pol0344_verifica_historico() RETURNING p_status

END FUNCTION

#-----------------------------------#
 FUNCTION pol0344_paginacao(p_funcao)
#-----------------------------------#
   DEFINE p_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_evento_polimetrir.* = mr_evento_polimetri.*
      WHILE TRUE
         CASE
            WHEN p_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_evento_polimetri.*
            WHEN p_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_evento_polimetri.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_evento_polimetri.* = mr_evento_polimetrir.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_evento_polimetri.* 
           FROM evento_polimetri   
          WHERE cod_empresa = mr_evento_polimetri.cod_empresa
            AND cod_evento  = mr_evento_polimetri.cod_evento
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0344_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0344_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR FOR
    SELECT *                            
      INTO mr_evento_polimetri.*                                              
      FROM evento_polimetri 
     WHERE cod_empresa = mr_evento_polimetri.cod_empresa
       AND cod_evento  = mr_evento_polimetri.cod_evento
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
      OTHERWISE CALL log003_err_sql("LEITURA","EVENTO_POLIMETRI")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0344_modificacao()
#-----------------------------#
   IF pol0344_cursor_for_update() THEN
      LET mr_evento_polimetrir.* = mr_evento_polimetri.*
      IF pol0344_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
           UPDATE evento_polimetri
              SET den_evento   = mr_evento_polimetri.den_evento,
                  cta_debito   = mr_evento_polimetri.cta_debito,
                  cod_hist_deb = mr_evento_polimetri.cod_hist_deb  
            WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            MESSAGE "Modificacao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
         ELSE
            CALL log003_err_sql("MODIFICACAO","EVENTO_POLIMETRI")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         LET mr_evento_polimetri.* = mr_evento_polimetrir.*
         ERROR "Modificacao Cancelada"
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         CALL pol0344_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0344_exclusao()
#--------------------------#
   IF pol0344_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
           DELETE FROM evento_polimetri 
            WHERE CURRENT OF cm_padrao
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE mr_evento_polimetri.* TO NULL
            CLEAR FORM
         ELSE
            CALL log003_err_sql("EXCLUSAO","EVENTO_POLIMETRI")
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION pol0344_popup()
#-----------------------#
   CASE 
      WHEN INFIELD(cta_debito)
         LET mr_evento_polimetri.cta_debito = 
             con010_popup_selecao_plano_contas(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0344
         IF mr_evento_polimetri.cta_debito IS NOT NULL THEN
            DISPLAY BY NAME mr_evento_polimetri.cta_debito
            CALL pol0344_verifica_conta_debito() RETURNING p_status
         END IF
      
      WHEN INFIELD(cod_hist_deb)
         CALL log009_popup(6,25,"HISTORICO","hist_padrao","cod_hist",
                           "tex_hist","","S","")
                 RETURNING mr_evento_polimetri.cod_hist_deb
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0344
         IF mr_evento_polimetri.cod_hist_deb IS NOT NULL THEN
            DISPLAY BY NAME mr_evento_polimetri.cod_hist_deb
            CALL pol0344_verifica_historico() RETURNING p_status
         END IF

   END CASE

END FUNCTION

#-----------------------#
 FUNCTION pol0344_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#----------------------------- FIM DE PROGRAMA --------------------------------#
