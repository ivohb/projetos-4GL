#-------------------------------------------------------------------#
# SISTEMA.: VENDAS E DISTRIBUICAO DE PRODUTOS                       #
# PROGRAMA: POL0337                                                 #
# MODULOS.: POL0337 - LOG0010 - LOG0030 - LOG0040 - LOG0050         #
#           LOG0060 - LOG1300 - LOG1400                             #
# OBJETIVO: MANUTENCAO DA TABELA ITEM_PETROM E ITEM_REFER_PETROM    #
# AUTOR...: LOGOCENTER ABC - ANTONIO CEZAR VIEIRA JUNIOR            #
# DATA....: 28/03/2005                                              #
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
          p_last_row     SMALLINT,
          pa_curr        SMALLINT,
          sc_curr        SMALLINT,
          p_msg          CHAR(100)

END GLOBALS

   DEFINE mr_item_petrom  RECORD LIKE item_petrom.*,
          mr_item_petromm RECORD LIKE item_petrom.*
         
   DEFINE m_ies_cons      SMALLINT,
          m_item          LIKE item_petrom.cod_item_petrom

   DEFINE ma_tela ARRAY[50] OF RECORD
      cod_item            LIKE item.cod_item,
      den_item            LIKE item.den_item
   END RECORD
   
MAIN
   CALL log0180_conecta_usuario()
   WHENEVER ANY ERROR CONTINUE
      SET ISOLATION TO DIRTY READ
      SET LOCK MODE TO WAIT 300 
   WHENEVER ANY ERROR STOP
   DEFER INTERRUPT
   LET p_versao = "POL0337-10.02.02"
   INITIALIZE p_nom_help TO NULL  
   CALL log140_procura_caminho("pol0337.iem") RETURNING p_nom_help
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
      CALL pol0337_controle()
   END IF

END MAIN

#--------------------------#
 FUNCTION pol0337_controle()
#--------------------------#

   CALL log006_exibe_teclas("01",p_versao)
   INITIALIZE p_nom_tela TO NULL
   CALL log130_procura_caminho("POL0337") RETURNING p_nom_tela
   LET p_nom_tela = p_nom_tela CLIPPED 
   OPEN WINDOW w_pol0337 AT 2,2 WITH FORM p_nom_tela 
      ATTRIBUTE(BORDER, MESSAGE LINE LAST, PROMPT LINE LAST)

   MENU "OPCAO"
      COMMAND "Incluir" "Inclui Dados na Tabela ITEM_PETROM"
         HELP 001
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0337","IN") THEN
            CALL pol0337_inclusao() RETURNING p_status
         END IF
      COMMAND "Modificar" "Modifica Dados da Tabela ITEM_PETROM"
         HELP 002
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0337","MO") THEN
               CALL pol0337_modificacao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Modificação"
         END IF
      COMMAND "Excluir" "Exclui Dados da Tabela ITEM_PETROM"
         HELP 003
         MESSAGE ""
         LET INT_FLAG = 0
         IF m_ies_cons THEN
            IF log005_seguranca(p_user,"VDP","pol0337","EX") THEN
               CALL pol0337_exclusao()
            END IF
         ELSE
            ERROR "Consulte Previamente para fazer a Exclusão"
         END IF 
      COMMAND "Consultar" "Consulta Dados da Tabela ITEM_PETROM"
         HELP 004
         MESSAGE ""
         LET INT_FLAG = 0
         IF log005_seguranca(p_user,"VDP","pol0337","CO") THEN
            CALL pol0337_consulta()
            IF m_ies_cons THEN
               NEXT OPTION "Seguinte"
            END IF
         END IF
      COMMAND "Seguinte" "Exibe o Próximo Item Encontrado na Consulta"
         HELP 005
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0337_paginacao("SEGUINTE")
      COMMAND "Anterior" "Exibe o Item Anterior Encontrado na Consulta"
         HELP 006
         MESSAGE ""
         LET INT_FLAG = 0
         CALL pol0337_paginacao("ANTERIOR") 
      COMMAND KEY ("O") "sObre" "Exibe a versão do programa !!!"
         CALL pol0337_sobre()
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
   CLOSE WINDOW w_pol0337

END FUNCTION

#--------------------------#
 FUNCTION pol0337_inclusao()
#--------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE
   CLEAR FORM
   
   IF pol0337_entrada_dados("INCLUSAO") THEN
      IF pol0337_entrada_item("INCLUSAO") THEN 
         CALL log085_transacao("BEGIN")
      #  BEGIN WORK
         LET mr_item_petrom.cod_empresa = p_cod_empresa
         WHENEVER ERROR CONTINUE
         INSERT INTO item_petrom VALUES (mr_item_petrom.*)
         WHENEVER ERROR STOP 
         IF SQLCA.SQLCODE <> 0 THEN 
	    LET p_houve_erro = TRUE
	    CALL log003_err_sql("INCLUSAO","ITEM_PETROM")       
         END IF
           
         FOR l_ind = 1 TO 50
            IF ma_tela[l_ind].cod_item IS NOT NULL AND
               ma_tela[l_ind].cod_item <> ' ' THEN
               WHENEVER ERROR CONTINUE
                 INSERT INTO item_refer_petrom 
                 VALUES (p_cod_empresa,
                         mr_item_petrom.cod_item_petrom,
                         ma_tela[l_ind].cod_item)
               WHENEVER ERROR STOP 
               IF SQLCA.SQLCODE <> 0 THEN 
	          LET p_houve_erro = TRUE
	          CALL log003_err_sql("INCLUSAO","ITEM_REFER_PETROM")       
                  EXIT FOR
               END IF
            END IF
         END FOR
         
         IF p_houve_erro THEN 
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK 
            MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
            RETURN FALSE
         ELSE
            CALL log085_transacao("COMMIT")
         #  COMMIT WORK 
            MESSAGE "Inclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            RETURN TRUE 
         END IF
      ELSE
         CLEAR FORM
         MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
         RETURN FALSE
      END IF
   ELSE
      CLEAR FORM
      MESSAGE "Inclusão Cancelada." ATTRIBUTE(REVERSE)
      RETURN FALSE
   END IF

END FUNCTION

#---------------------------------------#
 FUNCTION pol0337_entrada_dados(l_funcao)
#---------------------------------------#

   DEFINE l_funcao CHAR(30)

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0337
   DISPLAY p_cod_empresa TO cod_empresa
   IF l_funcao = "INCLUSAO" THEN
      INITIALIZE mr_item_petrom.* TO NULL
      LET mr_item_petrom.ies_tip_item = 'S'
   END IF

   INPUT BY NAME mr_item_petrom.ies_tip_item,
                 mr_item_petrom.cod_item_petrom,
                 mr_item_petrom.qtd_dia_validade,
                 mr_item_petrom.ies_indeterminada,
                 mr_item_petrom.den_item_petrom, 
                 mr_item_petrom.den_ingles_petrom, 
                 mr_item_petrom.cod_item_exxon,
                 mr_item_petrom.den_item_exxon,
                 mr_item_petrom.den_ingles_exxon WITHOUT DEFAULTS  

      BEFORE FIELD cod_item_petrom 
         IF l_funcao = "MODIFICACAO" THEN 
            NEXT FIELD qtd_dia_validade
         END IF

      AFTER FIELD cod_item_petrom  
         IF mr_item_petrom.cod_item_petrom IS NOT NULL AND 
            mr_item_petrom.cod_item_petrom <> ' ' THEN
            IF pol0337_verifica_duplicidade() THEN
               ERROR "Item já Cadastrado."
               NEXT FIELD cod_item_petrom 
            END IF
         ELSE
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD cod_item_petrom  
            END IF
         END IF
      
      AFTER FIELD qtd_dia_validade
         IF mr_item_petrom.qtd_dia_validade IS NOT NULL AND
            mr_item_petrom.qtd_dia_validade < 0         THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD qtd_dia_validade
         END IF 
         
         IF mr_item_petrom.ies_indeterminada = "S"       AND
            mr_item_petrom.qtd_dia_validade  IS NOT NULL THEN 
            ERROR "Neste caso não deve haver uma quantidade de dias de validade determinada !!!"
            NEXT FIELD qtd_dia_validade
         END IF 
         
      AFTER FIELD ies_indeterminada
         IF mr_item_petrom.ies_indeterminada IS NOT NULL AND
            mr_item_petrom.ies_indeterminada <> "S"      AND 
            mr_item_petrom.ies_indeterminada <> "N"      THEN 
            ERROR "Valor ilegal para o campo em questão !!!"
            NEXT FIELD ies_indeterminada
         END IF
         
         IF mr_item_petrom.qtd_dia_validade  IS NOT NULL AND
            mr_item_petrom.qtd_dia_validade  > 0         AND
            mr_item_petrom.ies_indeterminada = "S"       THEN 
            ERROR "Neste caso a validade não pode ser indeterminada !!!"
            NEXT FIELD ies_indeterminada
         END IF   
         
      AFTER FIELD den_item_petrom    
         IF mr_item_petrom.den_item_petrom IS NULL OR 
            mr_item_petrom.den_item_petrom = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD den_item_petrom
            END IF
         END IF

      AFTER FIELD den_ingles_petrom    
         IF mr_item_petrom.den_ingles_petrom IS NULL OR 
            mr_item_petrom.den_ingles_petrom = ' ' THEN
            IF INT_FLAG = 0 THEN
               ERROR "Campo de preenchimento obrigatório."
               NEXT FIELD den_ingles_petrom
            END IF
         END IF

      ON KEY (Control-z)
         CALL pol0337_popup()

   END INPUT 

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0337
   IF INT_FLAG = 0 THEN
      RETURN TRUE 
   ELSE
      LET m_ies_cons = FALSE
      LET INT_FLAG = 0
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------------------#
 FUNCTION pol0337_entrada_item(p_funcao)
#--------------------------------------#
   DEFINE p_funcao           CHAR(11),
          l_ind              SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0337

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
            IF pol0337_verifica_item() = FALSE THEN
               ERROR 'Item não cadastrado.'
               NEXT FIELD cod_item 
            ELSE
               IF pol0337_verifica_duplic_refer() THEN
                  ERROR 'Item já cadastrado para o Item Petrom ',m_item 
                  NEXT FIELD cod_item 
               END IF                            
            END IF                            
         END IF

      ON KEY (control-z)
         CALL pol0337_popup()

   END INPUT

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0337

   IF INT_FLAG THEN
      IF p_funcao = "MODIFICACAO" THEN
         RETURN FALSE
      ELSE
         CLEAR FORM
         ERROR "Inclusão Cancelada"
         RETURN FALSE
      END IF
   ELSE
      RETURN TRUE
   END IF  

END FUNCTION

#-------------------------------#
 FUNCTION pol0337_verifica_item()
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
 FUNCTION pol0337_verifica_duplic_refer()
#---------------------------------------#
   DEFINE l_item_existe         SMALLINT

   LET l_item_existe = FALSE

   DECLARE cq_refer CURSOR FOR
    SELECT cod_item_petrom
      FROM item_refer_petrom
     WHERE cod_empresa = p_cod_empresa 
       AND cod_item    = ma_tela[pa_curr].cod_item

   FOREACH cq_refer INTO m_item
      IF m_item <> mr_item_petrom.cod_item_petrom THEN
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
 FUNCTION pol0337_verifica_duplicidade()
#--------------------------------------#
   DEFINE l_den_item_petrom         LIKE item_petrom.den_item_petrom

   SELECT den_item_petrom
     INTO l_den_item_petrom
     FROM item_petrom
    WHERE cod_empresa     = p_cod_empresa  
      AND cod_item_petrom = mr_item_petrom.cod_item_petrom
   IF sqlca.sqlcode = 0 THEN
      DISPLAY l_den_item_petrom TO den_item_petrom
      RETURN TRUE
   ELSE
      DISPLAY l_den_item_petrom TO den_item_petrom
      RETURN FALSE
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0337_consulta()
#--------------------------#
   DEFINE sql_stmt, 
          where_clause CHAR(300)  

   CLEAR FORM
   DISPLAY p_cod_empresa TO cod_empresa

   CONSTRUCT BY NAME where_clause ON item_petrom.cod_item_petrom,
                                     item_petrom.den_item_petrom

   CALL log006_exibe_teclas("01",p_versao)
   CURRENT WINDOW IS w_pol0337

   IF INT_FLAG THEN
      LET INT_FLAG = 0 
      LET mr_item_petrom.* = mr_item_petromm.*
      CALL pol0337_exibe_dados()
      ERROR "Consulta Cancelada"
      LET m_ies_cons = FALSE
      RETURN
   END IF

   LET sql_stmt = "SELECT * FROM item_petrom ",
                  " WHERE cod_empresa = '",p_cod_empresa,"'",
                  "   AND ", where_clause CLIPPED,                 
                  " ORDER BY cod_item_petrom "

   PREPARE var_query FROM sql_stmt   
   DECLARE cq_padrao SCROLL CURSOR WITH HOLD FOR var_query
   OPEN cq_padrao
   FETCH cq_padrao INTO mr_item_petrom.*
   IF SQLCA.SQLCODE = NOTFOUND THEN
      ERROR "Argumentos de Pesquisa não Encontrados"
      LET m_ies_cons = FALSE
   ELSE 
      LET m_ies_cons = TRUE
      CALL pol0337_carrega_array()
      CALL pol0337_exibe_dados()
   END IF

END FUNCTION

#-------------------------------#
 FUNCTION pol0337_carrega_array()
#-------------------------------#
   DEFINE l_ind          SMALLINT

   CALL log006_exibe_teclas("01 02 07",p_versao)
   CURRENT WINDOW IS w_pol0337
   INITIALIZE ma_tela TO NULL
   CLEAR FORM

   LET l_ind = 1
   
   DECLARE c_item CURSOR WITH HOLD FOR
    SELECT cod_item 
      FROM item_refer_petrom
     WHERE cod_empresa     = p_cod_empresa
       AND cod_item_petrom = mr_item_petrom.cod_item_petrom
     ORDER BY cod_item 

   FOREACH c_item INTO ma_tela[l_ind].cod_item           

      SELECT den_item
        INTO ma_tela[l_ind].den_item
        FROM item
       WHERE cod_empresa = p_cod_empresa
         AND cod_item    = ma_tela[l_ind].cod_item

      LET l_ind = l_ind + 1

   END FOREACH 

   DISPLAY BY NAME mr_item_petrom.*
   CALL pol0337_verifica_duplicidade() RETURNING p_status

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
 FUNCTION pol0337_exibe_dados()
#-----------------------------#

   DISPLAY BY NAME mr_item_petrom.*

END FUNCTION

#-----------------------------------#
 FUNCTION pol0337_paginacao(l_funcao)
#-----------------------------------#
   DEFINE l_funcao             CHAR(20)

   IF m_ies_cons THEN
      LET mr_item_petromm.* = mr_item_petrom.*
      WHILE TRUE
         CASE
            WHEN l_funcao = "SEGUINTE" FETCH NEXT cq_padrao INTO 
                            mr_item_petrom.*
            WHEN l_funcao = "ANTERIOR" FETCH PREVIOUS cq_padrao INTO 
                            mr_item_petrom.*
         END CASE
     
         IF SQLCA.SQLCODE = NOTFOUND THEN
            ERROR "Não Existem mais Registros nesta Direção"
            LET mr_item_petrom.* = mr_item_petromm.* 
            EXIT WHILE
         END IF
        
         SELECT * 
           INTO mr_item_petrom.* 
           FROM item_petrom   
          WHERE cod_empresa     = mr_item_petrom.cod_empresa
            AND cod_item_petrom = mr_item_petrom.cod_item_petrom
         IF SQLCA.SQLCODE = 0 THEN 
            CALL pol0337_carrega_array()
            CALL pol0337_exibe_dados()
            EXIT WHILE
         END IF
      END WHILE
   ELSE
      ERROR "Não Existe Nenhuma Consulta Ativa"
   END IF

END FUNCTION 
 
#-----------------------------------#
 FUNCTION pol0337_cursor_for_update()
#-----------------------------------#
   WHENEVER ERROR CONTINUE
    DECLARE cm_padrao CURSOR FOR
     SELECT *                            
       INTO mr_item_petrom.*                                              
       FROM item_petrom 
      WHERE cod_empresa     = mr_item_petrom.cod_empresa
        AND cod_item_petrom = mr_item_petrom.cod_item_petrom
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
      OTHERWISE CALL log003_err_sql("LEITURA","ITEM_PETROM")
   END CASE
   WHENEVER ERROR STOP

   RETURN FALSE

END FUNCTION

#-----------------------------#
 FUNCTION pol0337_modificacao()
#-----------------------------#
   DEFINE l_ind SMALLINT

   LET p_houve_erro = FALSE

   IF pol0337_cursor_for_update() THEN
      LET mr_item_petromm.* = mr_item_petrom.*
      IF pol0337_entrada_dados("MODIFICACAO") THEN
         IF pol0337_entrada_item("MODIFICACAO") THEN 
            WHENEVER ERROR CONTINUE
            UPDATE item_petrom
               SET den_item_petrom   = mr_item_petrom.den_item_petrom,
                   den_ingles_petrom = mr_item_petrom.den_ingles_petrom,
                   cod_item_exxon    = mr_item_petrom.cod_item_exxon,
                   den_item_exxon    = mr_item_petrom.den_item_exxon,
                   den_ingles_exxon  = mr_item_petrom.den_ingles_exxon,
                   qtd_dia_validade  = mr_item_petrom.qtd_dia_validade,
                   ies_indeterminada = mr_item_petrom.ies_indeterminada,
                   ies_tip_item      = mr_item_petrom.ies_tip_item
                   
            WHERE CURRENT OF cm_padrao
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("MODIFICACAO","ITEM_PETROM")
               LET p_houve_erro = TRUE
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
            END IF

            WHENEVER ERROR CONTINUE
            DELETE FROM item_refer_petrom
             WHERE cod_empresa     = p_cod_empresa
               AND cod_item_petrom = mr_item_petrom.cod_item_petrom
            WHENEVER ERROR STOP 
            IF SQLCA.SQLCODE <> 0 THEN
               CALL log003_err_sql("EXCLUSAO","ITEM_REFER_PETROM")
               LET p_houve_erro = TRUE
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
            END IF

            FOR l_ind = 1 TO 50
               IF ma_tela[l_ind].cod_item IS NOT NULL AND
                  ma_tela[l_ind].cod_item <> ' ' THEN
                  WHENEVER ERROR CONTINUE
                    INSERT INTO item_refer_petrom 
                    VALUES (p_cod_empresa,
                            mr_item_petrom.cod_item_petrom,
                            ma_tela[l_ind].cod_item)
                  WHENEVER ERROR STOP
                  IF SQLCA.SQLCODE <> 0 THEN
                     LET p_houve_erro = TRUE
                     CALL log003_err_sql("INCLUSAO","ITEM_REFER_PETROM")
                     EXIT FOR
                  END IF
               END IF
            END FOR
 
            IF p_houve_erro = FALSE THEN
               CALL log085_transacao("COMMIT")
            #  COMMIT WORK
               MESSAGE "Modificação Efetuada com Sucesso" ATTRIBUTE(REVERSE)
            ELSE
               MESSAGE "Houve problemas na Modificação." ATTRIBUTE(REVERSE)
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
            END IF
         ELSE
            LET mr_item_petrom.* = mr_item_petromm.*
            ERROR "Modificação Cancelada."
            CALL log085_transacao("ROLLBACK")
         #  ROLLBACK WORK
            CALL pol0337_exibe_dados()
         END IF
      ELSE
         LET mr_item_petrom.* = mr_item_petromm.*
         ERROR "Modificação Cancelada."
         CALL log085_transacao("ROLLBACK")
      #  ROLLBACK WORK
         CALL pol0337_exibe_dados()
      END IF
      CLOSE cm_padrao
   END IF

END FUNCTION

#--------------------------#
 FUNCTION pol0337_exclusao()
#--------------------------#
   IF pol0337_cursor_for_update() THEN
      IF log004_confirm(13,42) THEN
         WHENEVER ERROR CONTINUE
         DELETE FROM item_petrom 
         WHERE CURRENT OF cm_padrao
         WHENEVER ERROR STOP
         IF SQLCA.SQLCODE = 0 THEN
            DELETE FROM item_refer_petrom 
            WHERE cod_empresa = p_cod_empresa
              AND cod_item_petrom = mr_item_petrom.cod_item_petrom
            IF SQLCA.SQLCODE = 0 THEN
               CALL log085_transacao("COMMIT")
            #  COMMIT WORK
               MESSAGE "Exclusão Efetuada com Sucesso" ATTRIBUTE(REVERSE)
               INITIALIZE mr_item_petrom.* TO NULL
               CLEAR FORM
            ELSE
               CALL log003_err_sql("EXCLUSAO","ITEM_REFER_PETROM")
               CALL log085_transacao("ROLLBACK")
            #  ROLLBACK WORK
            END IF
         ELSE
            CALL log003_err_sql("EXCLUSAO","ITEM_PETROM")
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
 FUNCTION pol0337_popup()
#-----------------------#
   CASE
      WHEN INFIELD(cod_item)
         LET ma_tela[pa_curr].cod_item = min071_popup_item(p_cod_empresa)
         CALL log006_exibe_teclas("01 02 03 07", p_versao)
         CURRENT WINDOW IS w_pol0337
         IF ma_tela[pa_curr].cod_item IS NOT NULL THEN
            DISPLAY ma_tela[pa_curr].cod_item TO s_itens[sc_curr].cod_item
         END IF
   END CASE

END FUNCTION

#-----------------------#
 FUNCTION pol0337_sobre()
#-----------------------#

   LET p_msg = p_versao CLIPPED,"\n","\n",
               " LOGIX 10.02 ","\n","\n",
               " Home page: www.aceex.com.br ","\n","\n",
               " (0xx11) 4991-6667 ","\n","\n"

   CALL log0030_mensagem(p_msg,'excla')
                  
END FUNCTION
       
#----------------------------- FIM DE PROGRAMA --------------------------------#