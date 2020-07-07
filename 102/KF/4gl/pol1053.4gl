#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1053                                                 #
# MODULOS.: POL1053 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ITEM_PROG_KF_1099                  #
# AUTOR...: TOTVS - GSP - MANUEL PIER SOBRIDO                       #
# DATA....: 08/09/2010                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
          # p_versao       CHAR(17),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(300),
          p_ies_tip_item LIKE item.ies_tip_item

END GLOBALS

    DEFINE mr_item_prog_kf_1099  RECORD LIKE item_prog_kf_1099.*,
           mr_item_prog_kf_1099r RECORD LIKE item_prog_kf_1099.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL1053-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1053.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   # CALL log001_acessa_usuario("VDP")
   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user
   IF p_status = 0  THEN
      CALL POL1053_controle()
   END IF
END MAIN

#--------------------------#
 FUNCTION POL1053_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1053") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1053 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela item_prog_kf_1099"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1053","IN") THEN
            CALL POL1053_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela item_prog_kf_1099"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_item_prog_kf_1099.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1053","MO") THEN
               CALL POL1053_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela item_prog_kf_1099"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_item_prog_kf_1099.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","POL1053","EX") THEN
               CALL POL1053_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela item_prog_kf_1099"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1053","CO") THEN
            CALL POL1053_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1053_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1053_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1053_sobre()
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
   CLOSE WINDOW w_POL1053

END FUNCTION

#-----------------------#
 FUNCTION pol1053_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION POL1053_inclusao()
#--------------------------#
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF POL1053_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      # BEGIN WORK
      LET mr_item_prog_kf_1099.cod_empresa = p_cod_empresa
 
      WHENEVER ERROR CONTINUE
        INSERT INTO item_prog_kf_1099 VALUES (mr_item_prog_kf_1099.*)
      WHENEVER ERROR STOP 
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK 
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","item_prog_kf_1099")       
      ELSE
         CALL log085_transacao("COMMIT")
         # COMMIT WORK 
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
 FUNCTION POL1053_entrada_dados(l_funcao)
#---------------------------------------#
   DEFINE l_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1053
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_item_prog_kf_1099.* TO NULL
   END IF
   LET mr_item_prog_kf_1099.cod_empresa = p_cod_empresa

   INPUT BY NAME mr_item_prog_kf_1099.* WITHOUT DEFAULTS  

      BEFORE FIELD cod_item 
         IF l_funcao = "MODIFICACAO" THEN 
            NEXT FIELD pct_refugo 
         END IF

      AFTER FIELD cod_item  
         IF mr_item_prog_kf_1099.cod_item IS NOT NULL AND
            mr_item_prog_kf_1099.cod_item <> ' ' THEN
            IF POL1053_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            ELSE
               IF POL1053_verifica_duplicidade() THEN
                  ERROR 'Registro já cadastrado.'
                  NEXT FIELD cod_item
               ELSE
               	  IF p_ies_tip_item <> 'C' THEN    
                     ERROR 'Tipo do item deve ser C - Comprado'
                     NEXT FIELD cod_item
                  END IF   
               END IF 
            END IF
         ELSE 
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_item  
         END IF

      AFTER FIELD pct_refugo
         IF mr_item_prog_kf_1099.pct_refugo IS NULL THEN
            LET mr_item_prog_kf_1099.pct_refugo = 0
         END IF
    
      AFTER FIELD num_ped_wv
         IF mr_item_prog_kf_1099.num_ped_wv IS NULL OR
            mr_item_prog_kf_1099.num_ped_wv = ' ' THEN
            ERROR 'Campo de preenchimento obrigatório.'
            NEXT FIELD num_ped_wv
         END IF

		 
      AFTER FIELD cod_uni_med 	  
         IF mr_item_prog_kf_1099.cod_uni_med IS NOT NULL AND
            mr_item_prog_kf_1099.cod_uni_med  <> ' ' THEN
            IF POL1053_verifica_um() = FALSE THEN
               ERROR 'Unidade de medida não cadastrado.'
               NEXT FIELD cod_uni_med 
            END IF
         ELSE 
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_uni_med  
         END IF

      ON KEY (Control-z)
         CALL POL1053_popup()
 
      END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1053
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION POL1053_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item
  
   SELECT den_item, ies_tip_item
     INTO l_den_item, p_ies_tip_item 
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_item_prog_kf_1099.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item TO den_item
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   
#-------------------------------#
 FUNCTION POL1053_verifica_um()
#-------------------------------#
   DEFINE l_cod_uni_med         LIKE  UNIMED_EDI_1099.cod_uni_med
  
   SELECT cod_uni_med
     INTO l_cod_uni_med 
     FROM UNIMED_EDI_1099
    WHERE  cod_uni_med    = mr_item_prog_kf_1099.cod_uni_med
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   
#--------------------------------------#
 FUNCTION POL1053_verifica_duplicidade()
#--------------------------------------#

    SELECT *
      FROM item_prog_kf_1099
     WHERE cod_empresa = p_cod_empresa  
       AND cod_item    = mr_item_prog_kf_1099.cod_item
    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1053_consulta()
#--------------------------#
   DEFINE sql_stmt         CHAR(500), 
          where_clause     CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON item_prog_kf_1099.cod_item,
                                     item_prog_kf_1099.pct_refugo,
                                     item_prog_kf_1099.num_ped_wv,
                                     item_prog_kf_1099.cod_item_wv,
                                     item_prog_kf_1099.contato, 
									 item_prog_kf_1099.cod_uni_med

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1053

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_item_prog_kf_1099.* = mr_item_prog_kf_1099r.*
      CALL POL1053_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_prog_kf_1099 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_item_prog_kf_1099.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL POL1053_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION POL1053_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_item_prog_kf_1099.cod_item,
                   mr_item_prog_kf_1099.pct_refugo,
                   mr_item_prog_kf_1099.num_ped_wv,
                   mr_item_prog_kf_1099.cod_item_wv,
                   mr_item_prog_kf_1099.contato,
                   mr_item_prog_kf_1099.cod_uni_med

   CALL POL1053_verifica_item() RETURNING p_status

END FUNCTION

#-----------------------------------#
 FUNCTION POL1053_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_item_prog_kf_1099r.* = mr_item_prog_kf_1099.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_item_prog_kf_1099.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_item_prog_kf_1099.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_item_prog_kf_1099.* = mr_item_prog_kf_1099r.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_item_prog_kf_1099.* 
           FROM item_prog_kf_1099   
          WHERE cod_empresa = mr_item_prog_kf_1099.cod_empresa
            AND cod_item    = mr_item_prog_kf_1099.cod_item 
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1053_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1053_cursor_for_update()
#-----------------------------------#

   WHENEVER ERROR CONTINUE
   DECLARE cm_padrao CURSOR WITH HOLD FOR
    SELECT *                            
      INTO mr_item_prog_kf_1099.*                                              
      FROM item_prog_kf_1099 
     WHERE cod_empresa = mr_item_prog_kf_1099.cod_empresa
       AND cod_item    = mr_item_prog_kf_1099.cod_item 
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
   # BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usuá",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro não mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","item_prog_kf_1099")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION POL1053_modificacao()
#-----------------------------#
   IF POL1053_cursor_for_update() THEN
      LET mr_item_prog_kf_1099r.* = mr_item_prog_kf_1099.*
      IF POL1053_entrada_dados("MODIFICACAO") THEN
         WHENEVER ERROR CONTINUE
         UPDATE item_prog_kf_1099
            SET pct_refugo    = mr_item_prog_kf_1099.pct_refugo,
                num_ped_wv    = mr_item_prog_kf_1099.num_ped_wv,
                cod_item_wv   = mr_item_prog_kf_1099.cod_item_wv,
                contato       = mr_item_prog_kf_1099.contato,
                cod_uni_med   = mr_item_prog_kf_1099.cod_uni_med      
          WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            # COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","item_prog_kf_1099")
            ELSE
               MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","item_prog_kf_1099")
            CALL log085_transacao("ROLLBACK")
            # ROLLBACK WORK
         END IF
      ELSE
         LET mr_item_prog_kf_1099.* = mr_item_prog_kf_1099r.*
         ERROR "Modificação Cancelada"
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK
         DISPLAY BY NAME mr_item_prog_kf_1099.cod_item
         DISPLAY BY NAME mr_item_prog_kf_1099.pct_refugo 
         DISPLAY BY NAME mr_item_prog_kf_1099.num_ped_wv
         DISPLAY BY NAME mr_item_prog_kf_1099.cod_item_wv
         DISPLAY BY NAME mr_item_prog_kf_1099.contato 
         DISPLAY BY NAME mr_item_prog_kf_1099.cod_uni_med
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1053_exclusao()
#--------------------------#
   IF POL1053_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_prog_kf_1099 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            # COMMIT WORK
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE mr_item_prog_kf_1099.* TO NULL
            CLEAR FORM
         ELSE
            CALL log003_err_sql("EXCLUSAO","item_prog_kf_1099")
            CALL log085_transacao("ROLLBACK")
            # ROLLBACK WORK
         END IF
         WHENEVER ERROR STOP
      ELSE
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION POL1053_popup()
#-----------------------#
   CASE
     WHEN infield(cod_item)
         LET mr_item_prog_kf_1099.cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1053
         IF mr_item_prog_kf_1099.cod_item IS NOT NULL THEN
            DISPLAY BY NAME mr_item_prog_kf_1099.cod_item
            CALL POL1053_verifica_item() RETURNING p_status
         END IF
   END CASE
                                 
END FUNCTION
#----------------------------- FIM DE PROGRAMA --------------------------------#
