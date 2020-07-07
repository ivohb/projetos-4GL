#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL1118                                                 #
# OBJETIVO: ITENS PARA AN�LISES                                     #
# DATA....: 03/11/2011                                              #
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
          p_last_row     SMALLINT,
          pa_curr        SMALLINT,
          sc_curr        SMALLINT,
          p_msg          CHAR(100)

END GLOBALS

   DEFINE mr_item  RECORD LIKE item_915.*,
          mr_itemm RECORD LIKE item_915.*
         
   DEFINE m_ies_cons      SMALLINT,
          m_item          LIKE item_915.cod_item_analise

   DEFINE ma_tela ARRAY[50] OF RECORD
      cod_item            LIKE item.cod_item,
      den_item            LIKE item.den_item
   END RECORD
   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   DEFER INTERRUPT
   LET p_versao = "POL1118-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("POL1118.iem") RETURNING p_nom_help
   LET p_nom_help = p_nom_help CLIPPED
   OPTIONS HELP FILE p_nom_help,
      NEXT KEY control-f,
      INSERT KEY control-i,
      DELETE KEY control-e,
      PREVIOUS KEY control-b

   CALL log001_acessa_usuario("ESPEC999","")
     RETURNING p_status, p_cod_empresa, p_user

   #LET p_cod_empresa = '11' ;    LET p_user = 'admlog' ;    LET p_status = 0

   IF p_status = 0  THEN
      CALL POL1118_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION POL1118_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL1118") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_POL1118 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1118","IN") THEN
            CALL POL1118_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1118","MO") THEN
               CALL POL1118_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modifica��o"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","POL1118","EX") THEN
               CALL POL1118_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclus�o"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","POL1118","CO") THEN
            CALL POL1118_consulta()
            IF m_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Pr�ximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1118_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL POL1118_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a vers�o do programa !!!"
         CALL POL1118_sobre()
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
   CLOSE WINDOW w_POL1118

END FUNCTION

#--------------------------#
 FUNCTION POL1118_inclusao()
#--------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE
   CLEAR FORM
   
   IF POL1118_entrada_dados("INCLUSAO") THEN
      IF POL1118_entrada_item("INCLUSAO") THEN 
         CALL log085_transacao("BEGIN")
         LET mr_item.cod_empresa = p_cod_empresa
         INSERT INTO item_915 VALUES (mr_item.cod_empresa,
                                         mr_item.cod_item_analise,
                                         mr_item.den_item_portugues, 
                                         mr_item.den_item_ingles,
                                         mr_item.den_item_espanhol, 
                                         mr_item.qtd_dia_validade,
                                         mr_item.ies_indeterminada)
        IF SQLCA.SQLCODE <> 0 THEN 
      	    LET p_houve_erro = TRUE
	          CALL log003_err_sql("INCLUSAO","ITEM_915")       
        Else
          FOR l_ind = 1 TO 50
            IF ma_tela[l_ind].cod_item IS NOT NULL AND
               ma_tela[l_ind].cod_item <> ' ' THEN
                 INSERT INTO item_refer_915 
                 VALUES (p_cod_empresa,
                         mr_item.cod_item_analise,
                         ma_tela[l_ind].cod_item)
               IF SQLCA.SQLCODE <> 0 THEN 
	                LET p_houve_erro = TRUE
	                CALL log003_err_sql("INCLUSAO","ITEM_REFER_915")       
                  EXIT FOR
               END IF
            END IF
          END FOR
        End if
       
         IF p_houve_erro THEN 
            CALL log085_transacao("ROLLBACK")
            MESSAGE "Inclus�o Cancelada." ATTRIBUTE(REVERSE)
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
            MESSAGE "Inclus�o Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            RETURN TRUE 
         END IF
      ELSE
         CLEAR FORM
         MESSAGE "Inclus�o Cancelada." ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF
   ELSE
      CLEAR FORM
      MESSAGE "Inclus�o Cancelada." ATTRIBUTE(REVERSE)
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION POL1118_entrada_dados(l_funcao)
#---------------------------------------#

   DEFINE l_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1118
   DISPLAY p_cod_empresa TO cod_empresa
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_item.* TO NULL
   END IF

   INPUT BY NAME mr_item.cod_item_analise,
                 mr_item.den_item_portugues, 
                 mr_item.den_item_ingles, 
                 mr_item.den_item_espanhol WITHOUT DEFAULTS  


      BEFORE FIELD cod_item_analise 

         IF l_funcao = "MODIFICACAO" THEN 
            NEXT FIELD den_item_portugues
         END IF

      AFTER FIELD cod_item_analise  
         IF mr_item.cod_item_analise IS NOT NULL AND 
            mr_item.cod_item_analise <> ' ' THEN
            IF POL1118_verifica_duplicidade() THEN
               ERROR "Item j� Cadastrado."
               NEXT FIELD cod_item_analise 
            END IF
            select den_item
               into mr_item.den_item_portugues
               from item
              where cod_item = mr_item.cod_item_analise
                and cod_empresa = p_cod_empresa
            if status = 100 then
               ERROR "Item n�o cadastrado no Logix"
               NEXT FIELD cod_item_analise
            else
               if status <> 0 then
                  call log003_err_sql('Lendo','item')
                  NEXT FIELD cod_item_analise
               else
                  display mr_item.den_item_portugues to den_item_portugues
               end if
            end if
         ELSE
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigat�rio."
               NEXT FIELD cod_item_analise  
            END IF
         END IF
      
      AFTER FIELD den_item_portugues    
         IF mr_item.den_item_portugues IS NULL OR 
            mr_item.den_item_portugues = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigat�rio."
               NEXT FIELD den_item_portugues
            END IF
         END IF

      AFTER FIELD den_item_ingles   
         IF mr_item.den_item_ingles IS NULL OR 
            mr_item.den_item_ingles = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigat�rio."
               NEXT FIELD den_item_ingles
            END IF
         END IF

      AFTER FIELD den_item_espanhol
         IF mr_item.den_item_espanhol IS NULL OR 
            mr_item.den_item_espanhol = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigat�rio."
               NEXT FIELD den_item_espanhol
            END IF
         END IF

      ON KEY (Control-z)
         CALL POL1118_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1118
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET m_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#-----------------------#
 FUNCTION POL1118_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_item_analise)
         LET mr_item.cod_item_analise = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1118
         IF mr_item.cod_item_analise IS NOT NULL THEN
            DISPLAY mr_item.cod_item_analise TO cod_item_analise
         END IF

      WHEN INFIELD(cod_item)
         LET ma_tela[pa_curr].cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_POL1118
         IF ma_tela[pa_curr].cod_item IS NOT NULL THEN
            DISPLAY ma_tela[pa_curr].cod_item TO s_itens[sc_curr].cod_item
         END IF

   END CASE

END FUNCTION

#--------------------------------------#
 FUNCTION POL1118_entrada_item(p_funcao)
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1118

   IF p_funcao = 'INCLUSAO' THEN
      INITIALIZE ma_tela TO NULL
   END IF
 
   LET INT_FLAG =  FALSE

   INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*

      BEFORE FIELD cod_item
         LET pa_curr = ARR_CURR()
         LET sc_curr = SCR_LINE()

      AFTER FIELD cod_item 
         IF ma_tela[pa_curr].cod_item IS NOT NULL AND 
            ma_tela[pa_curr].cod_item <> ' ' THEN
            IF POL1118_verifica_item() = FALSE THEN
               ERROR 'Item n�o cadastrado.'
               NEXT FIELD cod_item 
            ELSE
               IF POL1118_verifica_duplic_refer() THEN
                  ERROR 'Item j� cadastrado para o Item an�lise ',m_item 
                  NEXT FIELD cod_item 
               END IF                            
            END IF                            
         END IF

      ON KEY (control-z)
         CALL POL1118_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1118

   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclus�o Cancelada"
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE
   END IF  

END FUNCTION

#-------------------------------#
 FUNCTION POL1118_verifica_item()
#-------------------------------#

   SELECT den_item 
     INTO ma_tela[pa_curr].den_item
     FROM item
    WHERE cod_empresa = p_cod_empresa  
      AND cod_item    = ma_tela[pa_curr].cod_item

   IF sqlca.sqlcode = 0 THEN
      DISPLAY ma_tela[pa_curr].den_item TO s_itens[sc_curr].den_item
      RETURN TRUE
   ELSE
      DISPLAY ma_tela[pa_curr].den_item TO s_itens[sc_curr].den_item
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION POL1118_verifica_duplic_refer()
#---------------------------------------#

   DEFINE l_item_existe         SMALLINT

   LET l_item_existe = FALSE

   DECLARE cq_refer CURSOR FOR
    SELECT cod_item_analise
      FROM item_refer_915
     WHERE cod_empresa = p_cod_empresa 
       AND cod_item    = ma_tela[pa_curr].cod_item

   FOREACH cq_refer INTO m_item
      IF m_item <> mr_item.cod_item_analise THEN
         LET l_item_existe = TRUE
         EXIT FOREACH
      END IF
   END FOREACH

   IF l_item_existe THEN 
      RETURN TRUE
   ELSE
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION POL1118_verifica_duplicidade()
#--------------------------------------#

   DEFINE l_den_item_portugues  LIKE item_915.den_item_portugues

   SELECT den_item_portugues
     INTO l_den_item_portugues
     FROM item_915
    WHERE cod_empresa      = p_cod_empresa  
      AND cod_item_analise = mr_item.cod_item_analise
 
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item_portugues TO den_item_portugues
      RETURN TRUE
   ELSE
      DISPLAY l_den_item_portugues TO den_item_portugues
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1118_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON item_915.cod_item_analise,
                                     item_915.den_item_portugues

ON KEY (control-z)
      CALL pol1118_popup()
	END CONSTRUCT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_POL1118

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_item.* = mr_itemm.*
      CALL POL1118_exibe_dados()
      ERROR "Consulta Cancelada"
      LET m_ies_cons = FALSE
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_915 ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item_analise "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_item.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa n�o Encontrados"
      LET m_ies_cons = FALSE
   ELSE 
      LET m_ies_cons = TRUE
      CALL POL1118_carrega_array()
      CALL POL1118_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION POL1118_carrega_array()
#-------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_POL1118
   INITIALIZE ma_tela TO NULL
   CLEAR FORM

   LET l_ind = 1
   
   DECLARE c_item CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM item_refer_915
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item_analise = mr_item.cod_item_analise
     ORDER BY cod_item 

   FOREACH c_item INTO ma_tela[l_ind].cod_item           

      SELECT den_item
        INTO ma_tela[l_ind].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela[l_ind].cod_item

      LET l_ind = l_ind + 1

   END FOREACH 

   DISPLAY BY NAME mr_item.*
   CALL POL1118_verifica_duplicidade() RETURNING p_status

   IF l_ind > 1 THEN
      LET l_ind = l_ind - 1
   END IF

   CALL SET_COUNT(l_ind)

   IF l_ind > 10 THEN
      DISPLAY ARRAY ma_tela TO s_itens.*
      END DISPLAY
   ELSE
      INPUT ARRAY ma_tela WITHOUT DEFAULTS FROM s_itens.*
         BEFORE INPUT
            EXIT INPUT
      END INPUT
   END IF                    

END FUNCTION

#-----------------------------#
 FUNCTION POL1118_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME 
      mr_item.cod_item_analise,
      mr_item.den_item_portugues,
      mr_item.den_item_ingles,
      mr_item.den_item_espanhol

END FUNCTION

#-----------------------------------#
 FUNCTION POL1118_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao             CHAR(20)

   IF m_ies_cons THEN
      LET mr_itemm.* = mr_item.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_item.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_item.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "N�o Existem mais Registros nesta Dire��o"
            LET mr_item.* = mr_itemm.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_item.* 
           FROM item_915   
          WHERE cod_empresa     = p_cod_empresa
            AND cod_item_analise = mr_item.cod_item_analise
         IF SQLCA.SQLCODE = 0 THEN 
            CALL POL1118_carrega_array()
            CALL POL1118_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "N�o Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION POL1118_cursor_for_update()
#-----------------------------------#

    DECLARE cm_padrao CURSOR FOR
     SELECT *                            
       INTO mr_item.*                                              
       FROM item_915 
      WHERE cod_empresa     = p_cod_empresa
        AND cod_item_analise = mr_item.cod_item_analise
   FOR UPDATE 
   CALL log085_transacao("BEGIN")
#  BEGIN WORK
   OPEN cm_padrao
   FETCH cm_padrao
   CASE SQLCA.SQLCODE
      WHEN    0 RETURN TRUE 
      WHEN -250 ERROR " Registro sendo atualizado por outro usu�",
                      "rio. Aguarde e tente novamente."
      WHEN  100 ERROR " Registro n�o mais existe na tabela. Exec",
                      "ute a CONSULTA novamente."
      OTHERWISE CALL log003_err_sql("LEITURA","ITEM_915")
   END CASE

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION POL1118_modificacao()
#-----------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE

   IF POL1118_cursor_for_update() THEN
      LET mr_itemm.* = mr_item.*
      IF POL1118_entrada_dados("MODIFICACAO") THEN
         IF POL1118_entrada_item("MODIFICACAO") THEN 

            UPDATE item_915
               SET den_item_portugues = mr_item.den_item_portugues,
                   den_item_ingles    = mr_item.den_item_ingles,
                   den_item_espanhol  = mr_item.den_item_espanhol,
                   qtd_dia_validade   = mr_item.qtd_dia_validade,
                   ies_indeterminada  = mr_item.ies_indeterminada
            WHERE CURRENT OF cm_padrao

            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","ITEM_915")
               LET p_houve_erro = TRUE
            else
               DELETE FROM item_refer_915
                WHERE cod_empresa     = p_cod_empresa
                  AND cod_item_analise = mr_item.cod_item_analise

               IF SQLCA.SQLCODE <> 0 THEN
                  CALL log003_err_sql("EXCLUSAO","ITEM_REFER_915")
                  LET p_houve_erro = TRUE
               else
                  FOR l_ind = 1 TO 50
                     IF ma_tela[l_ind].cod_item IS NOT NULL AND ma_tela[l_ind].cod_item <> ' ' THEN
                        INSERT INTO item_refer_915
                          VALUES (p_cod_empresa,
                                  mr_item.cod_item_analise,
                                  ma_tela[l_ind].cod_item)

                        IF SQLCA.SQLCODE <> 0 THEN
                           LET p_houve_erro = TRUE
                           CALL log003_err_sql("INCLUSAO","ITEM_REFER_915")
                           EXIT FOR
                        END IF
                     END IF
                  END FOR
               end if
            end if
 
            IF p_houve_erro = FALSE THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Modifica��o Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Houve problemas na Modifica��o." ATTRIBUTE(REVERSE)
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            LET mr_item.* = mr_itemm.*
            ERROR "Modifica��o Cancelada."
            CALL log085_transacao("ROLLBACK")
            CALL POL1118_exibe_dados()
         END IF
      ELSE
         LET mr_item.* = mr_itemm.*
         ERROR "Modifica��o Cancelada."
         CALL log085_transacao("ROLLBACK")
         CALL POL1118_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION POL1118_exclusao()
#--------------------------#
   IF POL1118_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN

         DELETE FROM item_915 
         WHERE CURRENT OF cm_padrao

         IF SQLCA.SQLCODE = 0 THEN
            DELETE FROM item_refer_915 
            WHERE cod_empresa = p_cod_empresa
              AND cod_item_analise = mr_item.cod_item_analise
            IF SQLCA.SQLCODE = 0 THEN
               CALL log085_transacao("COMMIT")
               MESSAGE "Exclus�o Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_item.* TO NULL
               CLEAR FORM
            ELSE
               CALL log003_err_sql("EXCLUSAO","ITEM_REFER_915")
               CALL log085_transacao("ROLLBACK")
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ITEM_915")
            CALL log085_transacao("ROLLBACK")
         END IF
      ELSE
         CALL log085_transacao("ROLLBACK")
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION  

#-----------------------#
 FUNCTION POL1118_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
       
#----------------------------- FIM DE PROGRAMA --------------------------------#