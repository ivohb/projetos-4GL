#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: pol1197                                                 #
# OBJETIVO: MATERIAS PARA O EDI DA VW                               #
# AUTOR...: IVO BL                                                  #
# DATA....: 16/05/2013                                              #
#-------------------------------------------------------------------#
DATABASE logix

GLOBALS
   DEFINE p_cod_empresa  LIKE empresa.cod_empresa,
          p_den_empresa  LIKE empresa.den_empresa,  
          p_user         LIKE usuario.nom_usuario,
          p_status       SMALLINT,
          p_houve_erro   SMALLINT,
          comando        CHAR(80),
          p_versao       CHAR(18),
          p_nom_tela     CHAR(080),
          p_nom_help     CHAR(200),
          p_ies_cons     SMALLINT,
          p_last_row     SMALLINT,
          p_msg          CHAR(300),
          p_cod_unid_log CHAR(02),
          p_ies_tip_item LIKE item.ies_tip_item

END GLOBALS

    DEFINE mr_item_edi_vw_5054  RECORD LIKE item_edi_vw_5054.*,
           mr_item_edi_vw_5054r RECORD LIKE item_edi_vw_5054.*

MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 12 
   DEFER INTERRUPT
   LET p_versao = "pol1197-10.02.01"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol1197.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
      RETURNING p_status, p_cod_empresa, p_user

   IF p_status = 0  THEN
      CALL pol1197_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol1197_controle()
#--------------------------#
   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("pol1197") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol1197 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela item_edi_vw_5054"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol1197","IN") THEN
            CALL pol1197_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela item_edi_vw_5054"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_item_edi_vw_5054.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol1197","MO") THEN
               CALL pol1197_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela item_edi_vw_5054"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF mr_item_edi_vw_5054.cod_empresa IS NOT NULL THEN
            IF log005_seguranca(p_user,"VDP","pol1197","EX") THEN
               CALL pol1197_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela item_edi_vw_5054"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol1197","CO") THEN
            CALL pol1197_consulta()
            IF p_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1197_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol1197_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa"
         CALL pol1197_sobre()
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
   CLOSE WINDOW w_pol1197

END FUNCTION

#-----------------------#
 FUNCTION pol1197_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n\n",
               " Autor: Ivo H Barbosa\n",
               "ibarbosa@totvs.com.br\n ",
               " ivohb.me@gmail.com\n\n ",
               "     GrupoAceex\n",
               " www.grupoaceex.com.br\n",
               "   (0xx11) 4991-6667"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION

#--------------------------#
 FUNCTION pol1197_inclusao()
#--------------------------#
   LET p_houve_erro = FALSE
   CLEAR FORM
   IF pol1197_entrada_dados("INCLUSAO") THEN
      CALL log085_transacao("BEGIN")
      LET mr_item_edi_vw_5054.cod_empresa = p_cod_empresa
 
      
        INSERT INTO item_edi_vw_5054 VALUES (mr_item_edi_vw_5054.*)
      
      IF SQLCA.SQLCODE <> 0 THEN 
         CALL log085_transacao("ROLLBACK")
	 LET p_houve_erro = TRUE
	 CALL log003_err_sql("INCLUSAO","item_edi_vw_5054")       
      ELSE
         CALL log085_transacao("COMMIT")
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
 FUNCTION pol1197_entrada_dados(l_funcao)
#---------------------------------------#
   DEFINE l_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol1197
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_item_edi_vw_5054.* TO NULL
   END IF
   LET mr_item_edi_vw_5054.cod_empresa = p_cod_empresa

   INPUT BY NAME mr_item_edi_vw_5054.* WITHOUT DEFAULTS  

      BEFORE FIELD cod_item 
         IF l_funcao = "MODIFICACAO" THEN 
            NEXT FIELD cod_item_vw 
         END IF

      AFTER FIELD cod_item  
         IF mr_item_edi_vw_5054.cod_item IS NOT NULL AND
            mr_item_edi_vw_5054.cod_item <> ' ' THEN
            IF pol1197_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item
            ELSE
               IF pol1197_verifica_duplicidade() THEN
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
	 
      AFTER FIELD cod_uni_med 	  
         IF mr_item_edi_vw_5054.cod_uni_med IS NOT NULL AND
            mr_item_edi_vw_5054.cod_uni_med  <> ' ' THEN
            IF pol1197_verifica_um() = FALSE THEN
               ERROR 'Unidade de medida não cadastrado.'
               NEXT FIELD cod_uni_med 
            END IF
         ELSE 
            ERROR "Campo de preenchimento obrigatório."
            NEXT FIELD cod_uni_med  
         END IF

      BEFORE FIELD pct_refugo
         IF mr_item_edi_vw_5054.pct_refugo IS NULL THEN
            LET mr_item_edi_vw_5054.pct_refugo = 0
         END IF
      
      AFTER FIELD pct_refugo
         IF mr_item_edi_vw_5054.pct_refugo IS NULL THEN
            LET mr_item_edi_vw_5054.pct_refugo = 0
         END IF

      AFTER FIELD num_ped_vw
         IF mr_item_edi_vw_5054.num_ped_vw IS NULL OR
            mr_item_edi_vw_5054.num_ped_vw = ' ' THEN
            #ERROR 'Campo de preenchimento obrigatório.'
            #NEXT FIELD num_ped_vw
         END IF

    
      ON KEY (Control-z)
         CALL pol1197_popup()
 
      END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1197
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET p_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol1197_verifica_item()
#-------------------------------#
   DEFINE l_den_item         LIKE item.den_item
  
   SELECT den_item, ies_tip_item, cod_unid_med
     INTO l_den_item, p_ies_tip_item, p_cod_unid_log
     FROM item
    WHERE cod_empresa = p_cod_empresa
      AND cod_item    = mr_item_edi_vw_5054.cod_item
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item TO den_item
      DISPLAY p_cod_unid_log TO cod_unid_log
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   
#-------------------------------#
 FUNCTION pol1197_verifica_um()
#-------------------------------#

   DEFINE l_cod_uni_med  CHAR(02)
  
   SELECT cod_uni_med
     INTO l_cod_uni_med 
     FROM unimed_edi_vw_5054
    WHERE  cod_uni_med = mr_item_edi_vw_5054.cod_uni_med
  
   IF sqlca.sqlcode = 0 THEN
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION   
#--------------------------------------#
 FUNCTION pol1197_verifica_duplicidade()
#--------------------------------------#

    SELECT *
      FROM item_edi_vw_5054
     WHERE cod_empresa = p_cod_empresa  
       AND cod_item    = mr_item_edi_vw_5054.cod_item
    IF sqlca.sqlcode = 0 THEN
       RETURN TRUE
    ELSE
       RETURN FALSE
    END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1197_consulta()
#--------------------------#
   DEFINE sql_stmt         CHAR(500), 
          where_clause     CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON 
      item_edi_vw_5054.cod_item,
      item_edi_vw_5054.cod_item_vw,
  	  item_edi_vw_5054.cod_uni_med,
      item_edi_vw_5054.pct_refugo,
      item_edi_vw_5054.contato, 
      item_edi_vw_5054.num_ped_vw

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol1197

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_item_edi_vw_5054.* = mr_item_edi_vw_5054r.*
      CALL pol1197_exibe_dados()
      ERROR "Consulta Cancelada"
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_edi_vw_5054 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  " AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_item_edi_vw_5054.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET p_ies_cons = FALSE
   ELSE 
      LET p_ies_cons = TRUE
      CALL pol1197_exibe_dados()
   END IF

END FUNCTION

#-----------------------------#
 FUNCTION pol1197_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_item_edi_vw_5054.cod_item,
                   mr_item_edi_vw_5054.pct_refugo,
                   mr_item_edi_vw_5054.num_ped_vw,
                   mr_item_edi_vw_5054.cod_item_vw,
                   mr_item_edi_vw_5054.contato,
                   mr_item_edi_vw_5054.cod_uni_med

   CALL pol1197_verifica_item() RETURNING p_status

END FUNCTION

#-----------------------------------#
 FUNCTION pol1197_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao CHAR(20)

   IF p_ies_cons THEN
      LET mr_item_edi_vw_5054r.* = mr_item_edi_vw_5054.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_item_edi_vw_5054.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_item_edi_vw_5054.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_item_edi_vw_5054.* = mr_item_edi_vw_5054r.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_item_edi_vw_5054.* 
           FROM item_edi_vw_5054   
          WHERE cod_empresa = mr_item_edi_vw_5054.cod_empresa
            AND cod_item    = mr_item_edi_vw_5054.cod_item 
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol1197_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol1197_cursor_for_update()
#-----------------------------------#

   
   DECLARE cm_padrao CURSOR WITH HOLD FOR
    SELECT *                            
      INTO mr_item_edi_vw_5054.*                                              
      FROM item_edi_vw_5054 
     WHERE cod_empresa = mr_item_edi_vw_5054.cod_empresa
       AND cod_item    = mr_item_edi_vw_5054.cod_item 
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
      OTHERWISE CALL log003_err_sql("LEITURA","item_edi_vw_5054")
   END CASE
   

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol1197_modificacao()
#-----------------------------#
   IF pol1197_cursor_for_update() THEN
      LET mr_item_edi_vw_5054r.* = mr_item_edi_vw_5054.*
      IF pol1197_entrada_dados("MODIFICACAO") THEN
         
         UPDATE item_edi_vw_5054
            SET pct_refugo    = mr_item_edi_vw_5054.pct_refugo,
                num_ped_vw    = mr_item_edi_vw_5054.num_ped_vw,
                cod_item_vw   = mr_item_edi_vw_5054.cod_item_vw,
                contato       = mr_item_edi_vw_5054.contato,
                cod_uni_med   = mr_item_edi_vw_5054.cod_uni_med      
          WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            # COMMIT WORK
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EFET-COMMIT-ALT","item_edi_vw_5054")
            ELSE
               MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            END IF
         ELSE
            CALL log003_err_sql("MODIFICACAO","item_edi_vw_5054")
            CALL log085_transacao("ROLLBACK")
            # ROLLBACK WORK
         END IF
      ELSE
         LET mr_item_edi_vw_5054.* = mr_item_edi_vw_5054r.*
         ERROR "Modificação Cancelada"
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK
         DISPLAY BY NAME mr_item_edi_vw_5054.cod_item
         DISPLAY BY NAME mr_item_edi_vw_5054.pct_refugo 
         DISPLAY BY NAME mr_item_edi_vw_5054.num_ped_vw
         DISPLAY BY NAME mr_item_edi_vw_5054.cod_item_vw
         DISPLAY BY NAME mr_item_edi_vw_5054.contato 
         DISPLAY BY NAME mr_item_edi_vw_5054.cod_uni_med
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol1197_exclusao()
#--------------------------#
   IF pol1197_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         
         DELETE FROM item_edi_vw_5054 
         WHERE CURRENT OF cm_padrao
         IF SQLCA.SQLCODE = 0 THEN
            CALL log085_transacao("COMMIT")
            # COMMIT WORK
            MESSAGE "Exclusao Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            INITIALIZE mr_item_edi_vw_5054.* TO NULL
            CLEAR FORM
         ELSE
            CALL log003_err_sql("EXCLUSAO","item_edi_vw_5054")
            CALL log085_transacao("ROLLBACK")
            # ROLLBACK WORK
         END IF
         
      ELSE
         CALL log085_transacao("ROLLBACK")
         # ROLLBACK WORK
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION pol1197_popup()
#-----------------------#
   
   DEFINE p_codigo CHAR(15)
   
   CASE
     WHEN infield(cod_item)
         LET mr_item_edi_vw_5054.cod_item = min071_popup_item(p_cod_empresa)
         CURRENT WINDOW IS w_pol1197
         IF mr_item_edi_vw_5054.cod_item IS NOT NULL THEN
            DISPLAY BY NAME mr_item_edi_vw_5054.cod_item
            CALL pol1197_verifica_item() RETURNING p_status
         END IF

       WHEN INFIELD(cod_uni_med)
         CALL log009_popup(8,10,"UNIDADES","unimed_edi_vw_5054",
                     "cod_uni_med","des_uni_med","pol1198","N","")
              RETURNING p_codigo
         CURRENT WINDOW is w_pol1197
         IF p_codigo IS NOT NULL THEN
            LET mr_item_edi_vw_5054.cod_uni_med = p_codigo CLIPPED
            DISPLAY p_codigo TO cod_uni_med
         END IF

   END CASE
                                 
END FUNCTION
#----------------------------- FIM DE PROGRAMA --------------------------------#
